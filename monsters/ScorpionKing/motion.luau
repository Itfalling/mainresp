--!nocheck
-- Sandstorm Scorpion King motion: scuttling idle (legs ripple in place, pincers
-- double-clack, tail sways, blinks, chomps) then the VENOM STRIKE:
--   3.30-4.15 ANTICIPATION  body rears back, tail cocks up high, pincers gape, roar
--   4.15-4.38 tremble       coiled spring
--   4.38-4.60 ACTION        rear end kicks up, tail whips over the crown, lunge
--   4.56/4.82 double SNAP   pincers punch + snap twice, venom burst + venom glob
--   4.60-5.15 OVERSHOOT/HOLD (backOut), glob splats in front of the face
--   5.10-6.30 FOLLOW-THROUGH recoil hop back, elastic tail wobble, head shake
--   6.30-8.00 SETTLE        back into the scuttle idle
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave
local sin, rad = math.sin, math.rad

local M = {}
M.Cycle = 8

-- per-segment tail curls (degrees of X rotation in each tail bone's frame)
local COCK = { -2, 11, 10, 9, 10, 6, -3 } -- tail reared back and up, stinger high
local STRIKE = { -27, 15, 12, 4, -3, -7, 20 } -- whipped forward over the crown
-- leg toe positions relative to the Body pivot (z) and sideways reach (x)
local TOE_Z = { -5.1, -0.2, 5.4, 10.6 }
local TOE_X = { 8.4, 9.8, 9.8, 8.3 }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- signature move envelopes
	------------------------------------------------------------------
	local cock = L.env(c, 3.3, 0.85, 0.23, 0.22, "backOut", "expoIn") -- 3.30..4.60
	local strike = L.env(c, 4.38, 0.22, 0.55, 0.95, "backOut", "cubicInOut") -- 4.38..6.10
	local recoil = L.env(c, 5.1, 0.22, 0.12, 0.9, "cubicOut", "elasticOut") -- 5.10..6.34
	local squash = L.env(c, 4.58, 0.05, 0.04, 0.6, "linear", "elasticOut") -- impact
	local tremble = L.env(c, 3.9, 0.2, 0.3, 0.1) * wave(c, 13)
	local shake = L.env(c, 4.65, 0.1, 0.45, 0.35) * wave(c, 6.5)
	local wob = L.env(c, 5.15, 0.15, 0.5, 1.3) -- tail follow-through amount
	local act = math.max(cock, strike, recoil)
	local idleW = 1 - act

	------------------------------------------------------------------
	-- BODY
	------------------------------------------------------------------
	local f = 1.7 -- scuttle frequency
	local bob = L.bounce(t, f * 2) * idleW
	local breathe = wave(t, 0.5)
	local by = 0.28 * bob + 0.5 * cock + 0.6 * strike - 0.7 * squash + 0.7 * recoil
	local bz = 0.9 * cock - 2.2 * strike + 1.2 * recoil
	local pitch = 12 * cock - 16 * strike + 7 * recoil + 1.2 * breathe * idleW + 1.5 * tremble
	local yaw = 4 * wave(t, f / 2) * idleW + 3 * shake
	local roll = 1.5 * wave(t, f) * idleW
	pose.Body = pa(0.3 * tremble, by, bz, pitch, yaw, roll)

	------------------------------------------------------------------
	-- HEAD + FACE
	------------------------------------------------------------------
	local look = L.noise(t, 3.7, 0.4) * 16 * idleW
	pose.Head = ang(-3 * bob + 8 * cock + 10 * strike - 4 * recoil, look + 9 * shake, 4 * L.noise(t, 8.1, 0.5) * idleW + 5 * shake)
	local chomp = math.max(0, wave(t, 0.45, 0.3)) ^ 8 * idleW
	pose.Jaw = ang(-7 - 18 * chomp - 24 * cock - 22 * strike + 6 * shake + 3 * tremble, 0, 0)
	local blink = L.env(t % 3.1, 2.7, 0.06, 0.06, 0.1)
	local lid = math.max(blink * idleW, 0.3 * strike)
	L.both(pose, "Lid", CFrame.new(0, -1.7 * lid, 0))

	------------------------------------------------------------------
	-- PINCERS: idle double clacks, gape on the cock, double SNAP on the strike
	------------------------------------------------------------------
	local function clack(ph)
		local k = (t + ph) % 1.8
		return L.env(k, 0.2, 0.07, 0.03, 0.09, "quadOut", "quadIn") + L.env(k, 0.42, 0.07, 0.03, 0.09, "quadOut", "quadIn")
	end
	local snap = L.track(c, {
		{ 3.3, 0 },
		{ 3.95, 62, "backOut" },
		{ 4.46, 55 },
		{ 4.56, -5, "quadIn" },
		{ 4.7, 48, "cubicOut" },
		{ 4.82, -5, "quadIn" },
		{ 5.0, 8, "quadOut" },
		{ 5.6, 0 },
	})
	local cR, cL = clack(0) * idleW, clack(0.9) * idleW
	L.both(pose, "Pincer", ang(5 + 42 * cR + snap, 0, 0), ang(5 + 42 * cL + snap, 0, 0))
	-- punches: claws thrust forward on each snap
	local punch = L.env(c, 4.48, 0.08, 0.08, 0.12, "backOut", "quadIn") + L.env(c, 4.74, 0.08, 0.08, 0.2, "backOut", "quadIn")
	local function arm(cl, ph)
		local idleX = (7 * wave(t, 0.6, ph) + 9 * cl) * idleW
		return ang(idleX + 30 * cock + 14 * strike - 6 * punch + 2 * tremble, -24 * cock + 8 * punch, 0)
	end
	L.both(pose, "Arm", arm(cR, 0), arm(cL, 0.5))
	local function fore(ph)
		return ang(16 * cock + 6 * strike - 14 * punch + 4 * wave(t, 0.6, ph + 0.2) * idleW, 12 * cock - 14 * punch, 0)
	end
	L.both(pose, "Forearm", fore(0), fore(0.5))
	L.both(pose, "Claw", ang(-12 * cock + 10 * punch - 8 * strike, 0, -12 * cR), ang(-12 * cock + 10 * punch - 8 * strike, 0, -12 * cL))

	------------------------------------------------------------------
	-- LEGS: ripple scuttle in place; toes stay planted while the body
	-- bobs, pitches, rolls and lunges (cartoon splay under the squash)
	------------------------------------------------------------------
	local sp, cp = sin(rad(pitch)), math.cos(rad(pitch))
	local sr = sin(rad(roll))
	local sweep = 8.2 * bz
	for i = 1, 4 do
		local function leg(side, sgn)
			local ph = (i - 1) * 0.22 + side * 0.5
			local lift = math.max(0, wave(t, f, -ph)) ^ 1.5 * idleW
			local swing = wave(t, f, -ph + 0.25) * idleW
			local dy = by - TOE_Z[i] * sp - 4.4 * (cp - 1) + sgn * TOE_X[i] * sr
			local legCF = ang(0, 13 * swing + sweep, 24 * lift - 8.5 * dy)
			local kneeCF = ang(0, 0, -20 * lift - 5 * cock + 6 * squash)
			local footCF = ang(0, 0, 14 * lift)
			return legCF, kneeCF, footCF
		end
		local lR, kR, fR = leg(0, 1)
		local lL, kL, fL = leg(1, -1)
		L.both(pose, "Leg" .. i, lR, lL)
		L.both(pose, "Knee" .. i, kR, kL)
		L.both(pose, "Foot" .. i, fR, fL)
	end

	------------------------------------------------------------------
	-- TAIL: idle sway with lag; cock back; whip forward; elastic follow-through
	------------------------------------------------------------------
	for i = 1, 7 do
		local sway = 7 * wave(t, 0.6, -0.08 * i) * idleW
		local curl = 2.5 * wave(t, 0.5, 0.25 - 0.07 * i) * idleW
		local follow = 12 * wob * wave(c, 2.4, -0.08 * i) * (0.5 + i * 0.1)
		local x = curl + COCK[i] * cock + STRIKE[i] * strike + follow + 1.5 * tremble
		local name = i <= 6 and ("Tail" .. i) or "Stinger"
		if i == 7 then
			x += -8 * wave(t, 0.9) * idleW
		end
		pose[name] = ang(x, sway + 6 * shake * (i / 7), 0)
	end

	------------------------------------------------------------------
	-- FLOATING CUBES: hover + bob + drift loops + tumble; flung by the strike
	------------------------------------------------------------------
	local fling = L.env(c, 4.55, 0.25, 0.3, 1.4, "backOut", "cubicInOut")
	pose.Orbit = ang(0, 6 * wave(t, 0.08), 0)
	local dirs = { { 1, 0.3, 0 }, { -1, 0.2, 0.3 }, { 0.6, 0.8, 0.5 }, { -0.6, 0.8, -0.4 }, { -0.4, 0.2, 1 } }
	for i = 1, 5 do
		local d = dirs[i]
		local spin = i % 2 == 0 and -1 or 1
		local dx = 0.6 * wave(t, 0.23, i * 0.17) + 2.2 * fling * d[1]
		local dy = 0.9 * wave(t, 0.5, i * 0.21) + 2.2 * fling * d[2]
		local dz = 0.6 * wave(t, 0.19, i * 0.29 + 0.25) + 2.2 * fling * d[3]
		pose["Orb" .. i] = pa(dx, dy, dz, 60 * t * spin + 220 * fling * spin, 80 * t, 25)
	end

	------------------------------------------------------------------
	-- VENOM GLOB: spat at 4.58, arcs up over the crown, splats at 4.98
	------------------------------------------------------------------
	local k = L.remap(c, 4.58, 4.98)
	local flying = c > 4.58 and c < 4.98
	pose.Venom = pa(0.8 * k, 8 * k - 21.3 * k * k, -7.4 * (1 - (1 - k) ^ 1.5), -400 * k, 300 * k, 0)
	for _, n in { "VenomA", "VenomB", "VenomC" } do
		ctx.transparency(n, flying and 0 or 1)
	end
	local splatT = L.remap(c, 4.98, 5.9)
	local splatOn = c >= 4.98 and c < 5.9
	pose.Splat = pa(0, 0, 0, 0, 25 * splatT, 0)
	for _, n in { "SplatA", "SplatB", "SplatC" } do
		ctx.transparency(n, splatOn and (0.15 + 0.85 * splatT ^ 2) or 1)
	end

	------------------------------------------------------------------
	-- EFFECTS
	------------------------------------------------------------------
	ctx.light("StingerLight", 1.5 * strike)
	if ctx.crossed(4.58) then
		ctx.emit("VenomBurst", 40)
	end
	if ctx.crossed(4.56) then
		ctx.emit("SnapBurstR", 12)
		ctx.emit("SnapBurstL", 12)
	end
	if ctx.crossed(4.82) then
		ctx.emit("SnapBurstR", 12)
		ctx.emit("SnapBurstL", 12)
	end
	if ctx.crossed(4.6) then
		ctx.emit("StrikeDust", 24)
	end
	if ctx.crossed(4.98) then
		ctx.emit("VenomSplash", 30)
	end
	if ctx.crossed(5.45) then
		ctx.emit("StrikeDust", 14)
	end
end

return M
