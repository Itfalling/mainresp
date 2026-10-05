--!nocheck
-- Thunderhorn Beetle motion: bouncy tripod-gait shuffle in place (antennae
-- twitching, horn bobbing, blinks, a goofy head-wiggle chomp), then THUNDER
-- CHARGE: deep crouch (shell cracks open, horn tilts back) -> elytra BURST
-- open, wings buzz, the beetle launches and hovers -> three violent horn
-- tosses, each with a lightning bolt + spark burst -> drops with a squashy
-- thud and dust -> wobbly settle back into the shuffle.
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 8

-- head pitch (degrees) through the three horn tosses
local TOSS = {
	{ 3.45, 0 },
	{ 3.72, -20, "cubicOut" },
	{ 3.95, 34, "backOut" },
	{ 4.08, 28 },
	{ 4.3, -20, "cubicInOut" },
	{ 4.5, 38, "backOut" },
	{ 4.62, 32 },
	{ 4.8, -22, "cubicInOut" },
	{ 5.0, 44, "backOut" },
	{ 5.15, 38 },
	{ 5.5, 0, "cubicInOut" },
}
local PEAKS = { 3.95, 4.5, 5.0 }

-- Legs in the tripod gait: right F/B + left M lift together, then the rest.
local GROUP = { FR = 0, MR = 0.5, BR = 0, FL = 0.5, ML = 0, BL = 0.5 }
local FEET = { F = { 7.0, -6.2 }, M = { 7.9, -0.35 }, B = { 7.4, 6.2 } } -- approx foot x, z (scaled model)
local ORBS = { { 10.0, -2.5 }, { -9.5, 1.5 }, { 8.0, 6 }, { -7.5, -6.5 } }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- signature move envelopes
	local crouch = L.env(c, 2.3, 0.55, 0.15, 0.12, "cubicOut", "quadIn")
	local open = L.env(c, 3.0, 0.22, 2.3, 0.4, "backOut", "cubicInOut")
	local wings = L.env(c, 3.08, 0.25, 2.1, 0.35, "backOut", "cubicIn")
	local hover = L.env(c, 3.0, 0.55, 1.9, 0.47, "backOut", "quadIn")
	local impact = L.env(c, 5.92, 0.04, 0.08, 1.0, "linear", "elasticOut")
	local toss = L.track(c, TOSS)
	local tossLag = L.track(c - 0.07, TOSS)
	local tossLag2 = L.track(c - 0.13, TOSS)
	local air = math.min(1, hover)
	local idleW = 1 - math.max(crouch, air, impact)
	-- goofy idle beat: head wiggle + double chomp
	local wiggle = L.env(c, 0.55, 0.2, 0.7, 0.3) * idleW

	-- idle rhythm
	local hz = 1.1
	local bob = L.bounce(t, hz * 2) * idleW
	local breathe = wave(t, 0.5)

	-- BODY: bob + waddle, crouch, launch/hover, squash on landing
	local hoverBob = 0.45 * wave(t, 2.2) * air
	local bodyY = 0.45 * bob - 0.2 - 1.0 * crouch + 3.2 * hover + hoverBob - 1.3 * impact
	local bodyPitch = -1 * crouch + 8 * air + 0.18 * toss + 1.5 * breathe
	local bodyRoll = 4.5 * wave(t, hz) * idleW + 5 * wave(t, 1.3) * air
	local bodyYaw = 5 * wave(t, hz * 0.5) * idleW
	pose.Body = pa(0, bodyY, 0, bodyPitch, bodyYaw, bodyRoll)

	-- PRONOTUM + HEAD + HORN: bob/look in idle, whip up on each toss
	local look = L.noise(t, 2.3, 0.4) * 14 * idleW
	pose.Pronotum = ang(0.15 * toss + 2 * breathe - 2 * crouch + 4 * impact, look * 0.3, 0)
	local headBob = 6 * wave(t, hz * 2, 0.15) * idleW
	local wig = 9 * wiggle * wave(t, 2.4)
	local chomp = math.max(0, wave(t, 0.45, 0.3)) ^ 8 * idleW
	local wigChomp = wiggle * math.max(0, wave(c, 2.4, 0.85))
	local idleJaw = 20 * chomp + 28 * wigChomp -- idle mouth opening (deg); the head lifts with it
	pose.Head = ang(0.35 * toss + headBob + 15 * crouch + 12 * impact + 6 * wiggle + 0.75 * idleJaw, look * 0.7 - 22 * wiggle, 5 * L.noise(t, 7.7, 0.5) * idleW + wig - 14 * wiggle)
	pose.Horn1 = ang(0.2 * tossLag + 4 * wave(t, hz * 2, 0.3) * idleW + 10 * crouch - 8 * impact, 0, -0.4 * wig)
	pose.Horn2 = ang(0.3 * tossLag2 + 6 * wave(t, hz * 2, 0.45) * idleW + 6 * crouch - 10 * impact, 0, -0.5 * wig)

	-- JAW: little chomps in idle, double chomp on the wiggle, big yell on every toss
	local yell = L.clamp01(toss / 36)
	pose.Jaw = ang(-idleJaw - 10 * air - 44 * yell + 6 * impact, 0, 0)

	-- BLINKS (lids swing down over the eyes)
	local bt = t % 3.4
	local blink = math.max(L.env(bt, 2.9, 0.06, 0.05, 0.08), L.env(bt, 3.15, 0.05, 0.04, 0.07)) * (1 - air)
	L.both(pose, "Lid", ang(90 * blink, 0, 0))

	-- ANTENNAE: nervous twitches in idle, swept back by the air while flying
	local function ant(ph)
		local tw = 14 * L.noise(t, 5.1 + ph, 1.6)
		local flick = 25 * L.env((t + ph * 1.7) % 2.6, 2.2, 0.06, 0.05, 0.25, "quadOut", "backOut")
		return ang(tw * 0.5 + 40 * air - flick + 10 * crouch, 0, tw + 10 * air * wave(t, 9, ph) - 8 * impact)
	end
	L.both(pose, "Ant", ant(0), ant(0.37))

	-- ELYTRA: crack open + quiver while crouching, BURST open (overshoot), buzz in flight
	local quiver = 4 * crouch * wave(t, 13)
	local buzzE = 3 * air * wave(t, 11)
	local peek = 10 * crouch
	L.both(pose, "Elytron",
		ang(-30 * open - quiver - peek * 0.5 + 6 * impact, 30 * open, 55 * open + buzzE + quiver + peek - 4 * impact),
		ang(-30 * open - quiver - peek * 0.5 + 6 * impact, 30 * open, 55 * open - buzzE + quiver + peek - 4 * impact))

	-- WINGS: swing out from under the shell, then buzz FAST
	local flap = wings * (6 + 26 * wave(t, 11.3))
	L.both(pose, "Wing", ang(0, 0, flap) * ang(0, 72 * wings, 0) * ang(0, 0, -22 * wings))

	-- LEGS: tripod shuffle on the ground, paddling + dangling in the air,
	-- splayed flat by the crouch and the landing squash
	local sinP, sinR = math.sin(math.rad(bodyPitch)), math.sin(math.rad(bodyRoll))
	local legAir = L.smoothstep(L.clamp01(bodyY / 2.2)) -- legs tuck only once actually airborne
	for key, ph in GROUP do
		local n, side = key:sub(1, 1), key:sub(2, 2)
		-- keep planted feet on the ground: undo the body's bob/roll/pitch at this foot
		local fp = FEET[n]
		local footDY = bodyY + (side == "R" and 1 or -1) * fp[1] * sinR - (fp[2] - 0.88) * sinP
		local comp = -19 * footDY * (1 - legAir)
		local s = wave(t, hz, ph)
		local lift = math.max(0, s) ^ 1.5 * idleW
		local swing = 12 * wave(t, hz, ph + 0.25) * idleW
		local paddle = 22 * wave(t, 3.2, ph + (n == "M" and 0.33 or 0)) * legAir
		local femur = ang(0, swing + paddle, 30 * lift + comp + 12 * legAir)
		local tibia = ang(0, 0, -14 * lift - 0.35 * comp - 38 * legAir + 14 * legAir * wave(t, 3.2, ph + 0.2))
		local foot = ang(0, 0, -12 * lift - 0.6 * comp - 25 * legAir)
		local base = "Leg" .. n
		if side == "R" then
			pose[base .. "1R"] = femur
			pose[base .. "2R"] = tibia
			pose[base .. "3R"] = foot
		else
			pose[base .. "1L"] = L.mirror(femur)
			pose[base .. "2L"] = L.mirror(tibia)
			pose[base .. "3L"] = L.mirror(foot)
		end
	end

	-- ORBITING CUBES: slow spin + an extra full lap during the charge
	local extra = 360 * L.smoothstep(L.remap(c, 3.0, 5.9))
	pose.Orbit = ang(0, 30 * t + extra, 0)
	for i = 1, 4 do
		local sp = ORBS[i]
		local len = math.sqrt(sp[1] * sp[1] + sp[2] * sp[2])
		local out = 2.5 * air
		local dir = i % 2 == 0 and -1 or 1
		local bobY = 0.7 * wave(t, 0.6, i * 0.25) + 2.2 * air
		pose["Orb" .. i] = pa(sp[1] / len * out, bobY, sp[2] / len * out, 80 * t * dir, 110 * t, 45)
	end

	-- EFFECTS: lightning bolt + burst on each toss, sparks in flight, thud dust
	local flash = 0
	for _, pk in PEAKS do
		if c > pk - 0.06 and c < pk + 0.14 then
			flash = 1
		end
		if ctx.crossed(pk - 0.03) then
			ctx.emit("TossBurst", 30)
		end
	end
	for i = 1, 4 do
		ctx.transparency("Bolt" .. i, flash > 0 and 0.05 or 1)
	end
	ctx.light("HornLight", math.min(1.5, 1.5 * flash + 0.4 * air))
	ctx.enable("ChargeSparks", air > 0.3)
	if ctx.crossed(5.93) then
		ctx.emit("LandDust", 35)
		ctx.emit("LandBurst", 25)
	end
end

return M
