--!nocheck
-- Jade Mantis motion.
-- IDLE: swaying mantis rock, curious cartoon head tilts, twitchy antennae,
-- blinks, tippy-tap feet, boxer-style scythe pumps and a cute grooming beat
-- (the right scythe is lifted to the mouth and nibbled clean).
-- SIGNATURE "TWIN CRESCENT": crouch + wings flare and buzz, scythes rise high
-- with a battle cry -> crossing X double-slash (wind crescents fly forward) ->
-- scissor slash outward -> hop + 360 spinning flourish inside a whirlwind ring
-- -> squash landing -> elastic return to guard with a cocky head tilt.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, track, track3 = L.ang, L.pa, L.wave, L.track, L.track3

local M = {}
M.Cycle = 8

local function A(c, keys)
	local x, y, z = track3(c, keys)
	return x, y, z
end

-- keyframes (right side; the left side is mirrored)
local K = {
	thY = {
		{ 3.3, 0 }, { 4.0, -1.2, "cubicOut" }, { 4.6, -1.0 }, { 4.85, -1.1, "expoOut" }, { 5.15, -0.9 },
		{ 5.35, -0.8 }, { 5.55, -1.6, "quadOut" }, { 6.0, 2.8, "quadOut" }, { 6.45, 0, "quadIn" },
		{ 6.58, -1.5, "quadOut" }, { 7.1, 0.3, "backOut" }, { 7.5, 0 },
	},
	thZ = {
		{ 3.3, 0 }, { 4.0, 0.8, "cubicOut" }, { 4.6, 0.9 }, { 4.85, -1.4, "expoOut" }, { 5.15, -1.2 },
		{ 5.55, -0.4 }, { 6.45, 0 },
	},
	thRX = { { 3.3, 0 }, { 4.0, 6, "cubicOut" }, { 4.6, 6 }, { 4.85, -3, "expoOut" }, { 5.35, 0 }, { 6.0, -6 }, { 6.45, 0 } },
	spin = { { 5.55, 0 }, { 6.45, 360, "sineInOut" } },
	chest = {
		{ 3.3, { 0, 0, 0 } }, { 4.0, { 15, 0, 0 }, "cubicOut" }, { 4.6, { 18, 0, 0 } }, { 4.85, { -14, 0, 0 }, "expoOut" },
		{ 5.15, { -10, 0, 0 } }, { 5.35, { -4, 0, 0 }, "backOut" }, { 5.55, { -10, 0, 0 } }, { 6.0, { 6, 0, 0 } },
		{ 6.45, { 0, 0, 0 } }, { 6.58, { -16, 0, 0 }, "quadOut" }, { 7.2, { 4, 0, 0 }, "backOut" }, { 7.5, { 0, 0, 0 } },
	},
	head = {
		{ 3.3, { 0, 0, 0 } }, { 4.0, { 18, 0, 0 }, "backOut" }, { 4.6, { 20, 0, 0 } }, { 4.85, { 14, 0, 0 }, "expoOut" },
		{ 5.15, { 12, 0, 10 } }, { 5.35, { 0, 0, 0 } }, { 6.0, { 12, 0, 0 } }, { 6.45, { 0, 0, 0 } },
		{ 6.58, { -14, 0, 0 } }, { 7.0, { 6, 0, -20 }, "backOut" }, { 7.5, { 0, 0, 0 } },
	},
	jaw = {
		{ 3.3, 0 }, { 3.9, -48, "backOut" }, { 4.6, -52 }, { 4.8, -12 }, { 5.15, -10 }, { 5.35, -8 },
		{ 5.8, -40 }, { 6.3, -40 }, { 6.45, 0, "quadIn" },
	},
	wing = {
		{ 3.3, { 0, 0, 0 } }, { 3.75, { -25, -30, 35 }, "backOut" }, { 6.45, { -25, -30, 35 } },
		{ 7.0, { 0, 0, 0 }, "bounceOut" },
	},
}

-- scythe arm chain (right-side convention): guard -> raised high -> X cross ->
-- scissor out -> spin -> guard. The X-cross keys differ per side so the right
-- blade crosses just in front of the left one.
local function armKeys(xArm, xFore, xScy)
	return {
		arm = {
			{ 3.3, { 0, 0, 0 } }, { 4.05, { 80, 0, 42 }, "backOut" }, { 4.6, { 84, 0, 45 } },
			{ 4.85, xArm, "expoOut" }, { 5.15, { xArm[1] - 3, xArm[2], xArm[3] + 3 } }, { 5.35, { 10, -10, 66 }, "expoOut" },
			{ 6.45, { 8, -10, 68 } }, { 6.6, { -10, 0, 44 } }, { 7.5, { 0, 0, 0 }, "elasticOut" },
		},
		fore = {
			{ 3.3, { 0, 0, 0 } }, { 4.05, { -50, 0, 0 }, "backOut" }, { 4.6, { -52, 0, 0 } },
			{ 4.85, { xFore, 0, 0 }, "expoOut" }, { 5.15, { xFore + 2, 0, 0 } }, { 5.35, { -40, 0, 0 }, "expoOut" },
			{ 6.45, { -40, 0, 0 } }, { 6.6, { -20, 0, 0 } }, { 7.5, { 0, 0, 0 }, "elasticOut" },
		},
		scythe = {
			{ 3.3, { 0, 0, 0 } }, { 4.05, { 140, 0, 0 }, "backOut" }, { 4.6, { 146, 0, 0 } },
			{ 4.85, xScy, "expoOut" }, { 5.15, { xScy[1] - 2, xScy[2], xScy[3] + 2 } }, { 5.35, { 60, 0, 60 }, "expoOut" },
			{ 6.45, { 60, 0, 60 } }, { 6.6, { 30, 0, 20 } }, { 7.5, { 0, 0, 0 }, "elasticOut" },
		},
	}
end
local KR = armKeys({ 28, 2, -32 }, -29, { 49, 20, -23 })
local KL = armKeys({ 20, 10, -34 }, 0, { 30, 19, -21 })

-- Walking legs (right side, XY projection): hip, knee, foot, foot z.
local LEGS = {
	M = { 1.9, 5.4, 5.2, 7.6, 6.2, 0.0, -3.0 },
	B = { 1.9, 5.4, 5.2, 7.4, 6.4, 0.0, 7.2 },
}
-- 2-bone IK: femur/shin roll (degrees) that raise the foot by d studs relative
-- to the hip while keeping it at the same sideways spot (planted feet).
local function legIK(g, d)
	local hx, hy, kx, ky, fx, fy = g[1], g[2], g[3], g[4], g[5], g[6]
	local ux, uy, wx, wy = kx - hx, ky - hy, fx - kx, fy - ky
	local a, b = math.sqrt(ux * ux + uy * uy), math.sqrt(wx * wx + wy * wy)
	local px, py = fx - hx, fy - hy
	local tx, ty = px, py + d
	local r0 = math.sqrt(px * px + py * py)
	local r = math.clamp(math.sqrt(tx * tx + ty * ty), math.abs(a - b) + 0.05, a + b - 0.05)
	local al0 = math.acos(math.clamp((a * a + r0 * r0 - b * b) / (2 * a * r0), -1, 1))
	local al = math.acos(math.clamp((a * a + r * r - b * b) / (2 * a * r), -1, 1))
	local fem = math.atan2(ty, tx) + al
	local th = fem - (math.atan2(py, px) + al0)
	local nkx, nky = a * math.cos(fem), a * math.sin(fem)
	local ph = (math.atan2(ty - nky, tx - nkx) - math.atan2(wy, wx)) - th
	return math.deg(th), math.deg(ph)
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle
	local sig = L.env(c, 3.3, 0.35, 3.75, 0.5)
	local idleW = 1 - sig

	------------------------------------------------------------------
	-- idle ingredients
	------------------------------------------------------------------
	local breathe = wave(t, 0.5)
	local sway = wave(t, 0.32) -- slow mantis rock
	local rock = wave(t, 0.64, 0.1)
	local hop = L.bounce(t, 1.25) -- springy boxer bounce
	local bob = (0.55 * hop - 0.3) * idleW
	local pump = wave(t, 0.625) -- alternating scythe pumps in time with the bounce
	local tilt = track(c, {
		{ 0, 0 }, { 0.4, 16, "backOut" }, { 1.1, 16 }, { 1.45, 8, "backOut" }, { 2.7, 8 }, { 3.0, 0, "backOut" },
		{ 7.6, 0 }, { 7.85, 10, "backOut" }, { 8, 0 },
	}) * idleW
	local groom = L.env(c, 1.2, 0.35, 1.0, 0.3, "backOut", "cubicInOut") * idleW
	local tapA = math.max(0, wave(t, 0.9)) ^ 3 * idleW
	local tapB = math.max(0, wave(t, 0.9, 0.5)) ^ 3 * idleW

	------------------------------------------------------------------
	-- signature tracks
	------------------------------------------------------------------
	local thY = track(c, K.thY) + bob
	local thZ = track(c, K.thZ)
	local spin = track(c, K.spin)
	local air = L.env(c, 5.6, 0.15, 0.55, 0.15) -- feet off the ground
	local spinV = L.env(c, 5.6, 0.45, 0, 0.45) -- spin speed (for follow-through)
	local raise = L.env(c, 3.6, 0.45, 0.55, 0.25) -- scythes held high
	local flare = L.env(c, 3.4, 0.35, 3.0, 0.5) -- wings open
	local slashHit = L.env(c, 4.8, 0.05, 0.1, 0.5, "linear", "cubicOut")
	local land = L.env(c, 6.45, 0.08, 0.05, 0.6, "linear", "elasticOut")

	------------------------------------------------------------------
	-- THORAX: bob, rock, crouch, lunge, hop + spin
	------------------------------------------------------------------
	local thRX = track(c, K.thRX)
	pose.Thorax = pa(0.25 * sway * idleW, thY, thZ + 0.25 * rock * idleW, thRX, spin + 4 * sway * idleW, 0)

	-- CHEST: mantis sway + breathing; lean back / lunge on the move
	local cx, cy, cz = A(c, K.chest)
	pose.Chest = ang(cx + 3 * breathe + (5 * rock - 4 * hop) * idleW, cy + 6 * sway * idleW, cz + 8 * sway * idleW + 3 * wave(t, 9) * raise)

	-- HEAD: curious tilts in idle, battle cry on the move
	local hx, hy, hz = A(c, K.head)
	local look = L.noise(t, 3.7, 0.3) * 14 * idleW
	pose.Head = ang(hx + 3 * breathe + (6 * hop - 4 - 2 * rock) * idleW - 6 * groom, hy + look - 8 * sway * idleW - 6 * groom,
		hz + tilt - 5 * sway * idleW + 5 * raise * wave(t, 7))

	-- JAW: idle chatter, wide-open battle cry
	local chatter = L.env(c, 0.25, 0.08, 0.25, 0.1) + 1.4 * L.env(c, 1.45, 0.1, 0.95, 0.15)
	pose.Jaw = ang(-7 * idleW + track(c, K.jaw) - 16 * chatter * L.bounce(t, 6) * idleW + 6 * raise * wave(t, 12), 0, 0)

	-- BLINKS
	local blink = L.env(c, 1.0, 0.05, 0.06, 0.08) + L.env(c, 2.4, 0.05, 0.05, 0.08) + L.env(c, 2.65, 0.05, 0.05, 0.08)
		+ L.env(c, 7.65, 0.05, 0.06, 0.08)
	L.both(pose, "Lid", ang(95 * math.min(1, blink), 0, 0))

	-- ANTENNAE: noisy drift + quick twitches, swept back on the cry, whip on the slash
	local twitch = L.env(c, 0.6, 0.05, 0.25, 0.1) + L.env(c, 2.05, 0.05, 0.2, 0.1) + L.env(c, 7.4, 0.05, 0.2, 0.1)
	local sweep = 28 * raise - 22 * slashHit + 10 * land * wave(t, 6)
	for _, s in { "R", "L" } do
		local ph = s == "R" and 0 or 0.37
		local ax = 8 * L.noise(t, 1.3 + ph, 0.8) + 10 * twitch * wave(t, 17, ph) + sweep - 4 * breathe
		local az = 6 * L.noise(t, 5.1 + ph, 0.6) + 8 * spinV
		local cfA = ang(ax, 0, az)
		local cfB = ang(0.8 * ax + 10 * wave(t, 1.1, ph + 0.2), 0, 1.2 * az + 8 * twitch * wave(t, 15, ph + 0.3))
		if s == "R" then
			pose.AntAR, pose.AntBR = cfA, cfB
		else
			pose.AntAL, pose.AntBL = L.mirror(cfA), L.mirror(cfB)
		end
	end

	------------------------------------------------------------------
	-- SCYTHE ARMS
	------------------------------------------------------------------
	local tremble = 4 * raise * wave(t, 10)
	local idleArm = (7 + 6 * rock) * idleW + 3 * breathe
	-- grooming pose for the right scythe (solved so the blade passes the mouth)
	local GA, GF, GS = { 49, -7, -23 }, -51, { 35, -26, -40 }
	local scrub = 7 * wave(t, 4.2) * groom
	for _, sd in { { "R", KR, 1 }, { "L", KL, -1 } } do
		local s, KK, k = sd[1], sd[2], sd[3]
		local arx, ary, arz = A(c, KK.arm)
		local frx, fry, frz = A(c, KK.fore)
		local srx, sry, srz = A(c, KK.scythe)
		local g = s == "R" and groom or 0
		local jab = math.max(0, pump * k) * (1 - groom) * idleW
		local armCF = ang(arx + idleArm + k * tremble + 16 * jab + GA[1] * g, ary + GA[2] * g,
			arz + (k * 5 * sway + 5 * hop) * idleW * (1 - g) + GA[3] * g)
		local foreCF = ang(frx - 4 * breathe - 16 * jab + GF * g, fry, frz)
		local scyCF = ang(srx + (GS[1] + scrub) * g, sry + GS[2] * g, srz + GS[3] * g)
		if s == "R" then
			pose.ArmR, pose.ForeR, pose.ScytheR = armCF, foreCF, scyCF
		else
			pose.ArmL, pose.ForeL, pose.ScytheL = L.mirror(armCF), L.mirror(foreCF), L.mirror(scyCF)
		end
	end

	------------------------------------------------------------------
	-- WALKING LEGS: planted feet (crouch compensation), tippy taps, air tuck
	------------------------------------------------------------------
	local ground = 1 - air
	local yawComp = math.deg((thZ + 0.25 * rock * idleW) / 4.2) * ground
	local pitch = math.sin(math.rad(thRX))
	local function leg(id, side, tap)
		local g = LEGS[id]
		-- foot rise needed: undo body bob/crouch + pitch, plus a cartoon tap
		local d = (-thY + (g[7] - 1.0) * pitch) * ground
		d = d + 0.14 * math.abs(d) + 0.9 * tap -- the tilted foot block dips a little
		local th, ph = legIK(g, d)
		th += 32 * air
		ph += -40 * air
		local femur, shin = ang(0, yawComp, th), ang(0, 0, ph)
		if side == "R" then
			pose["Leg" .. id .. "R"], pose["Shin" .. id .. "R"] = femur, shin
		else
			pose["Leg" .. id .. "L"], pose["Shin" .. id .. "L"] = L.mirror(femur), L.mirror(shin)
		end
	end
	leg("M", "R", tapA)
	leg("B", "L", tapA)
	leg("M", "L", tapB)
	leg("B", "R", tapB)

	------------------------------------------------------------------
	-- ABDOMEN: lazy wave, curls up on the wind-up, lags behind the spin
	------------------------------------------------------------------
	for i = 1, 4 do
		local lift = -5 * raise - 3 * flare + 5 * land * wave(t, 3, -0.1 * i)
		local yaw = 5 * wave(t, 0.5, -0.12 * i) * idleW - 9 * spinV
		pose["Abd" .. i] = ang(lift + 1.5 * wave(t, 0.5, -0.1 * i), yaw, 0)
	end

	------------------------------------------------------------------
	-- WINGS: flare open and BUZZ during the move, tiny flutters at idle
	------------------------------------------------------------------
	local wx, wy, wz = A(c, K.wing)
	local buzz = flare * wave(t, 14) + (L.env(c, 2.9, 0.05, 0.25, 0.05) + L.env(c, 0.9, 0.05, 0.2, 0.05)) * wave(t, 16)
	L.both(pose, "Wing", ang(wx + 4 * buzz, wy, wz + 12 * buzz + 2 * breathe))

	------------------------------------------------------------------
	-- FLOATING VOXEL CUBES
	------------------------------------------------------------------
	pose.Orbit = ang(0, 28 * wave(t, 0.125), 0)
	for i = 1, 4 do
		local dir = i % 2 == 0 and -1 or 1
		local out = 2.2 * slashHit + 5 * air -- flung clear while the body spins
		local bobO = 0.7 * wave(t, 0.55, i * 0.27)
		pose["Orb" .. i] = pa(out * dir * 0.5, bobO + out * 0.5, out * 0.4, 80 * t * dir, 110 * t, 45)
	end

	------------------------------------------------------------------
	-- VFX
	------------------------------------------------------------------
	pose.SlashFX = CFrame.new(0, 0, -7 * L.remap(c, 4.85, 5.45))
	pose.Whirl = pa(0, math.max(0, thY) * 0.6, 0, 0, -900 * t, 0)

	local function fade(on, off, full)
		if c < on or c > off then return 1 end
		return full + (1 - full) * L.remap(c, off - (off - on) * 0.45, off)
	end
	local trX = fade(4.8, 5.3, 0.15)
	local trC = fade(5.25, 5.65, 0.2)
	for i = 1, 5 do
		ctx.transparency("SlashA" .. i, trX)
		ctx.transparency("SlashB" .. i, trX)
		ctx.transparency("SlashC" .. i, trC)
	end
	local whirlOn = L.env(c, 5.55, 0.12, 0.7, 0.15)
	for i = 1, 12 do
		ctx.transparency("Whirl" .. i, 1 - 0.7 * whirlOn)
	end
	ctx.light("SlashLight", 1.5 * slashHit)

	if ctx.crossed(3.95) then ctx.emit("ShoutBurst", 25) end
	if ctx.crossed(4.86) then ctx.emit("SlashBurst", 45) end
	if ctx.crossed(5.32) then ctx.emit("SlashBurst", 30) end
	if ctx.crossed(5.6) then ctx.emit("SpinBurst", 25) end
	if ctx.crossed(6.46) then
		ctx.emit("LandDust", 30)
		ctx.emit("SpinBurst", 40)
	end
end

return M
