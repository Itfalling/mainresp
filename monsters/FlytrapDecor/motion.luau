--!nocheck
-- Snappy Flytrap motion (10 s seamless loop, cartoon-exaggerated).
--  0.0-3.6  a fly buzzes loop-de-loops round the cluster; the hero trap tracks
--           it hungrily (stem sway + lean, mouth breathing, drool swinging).
--           1.75 near miss: the hero lunges and nips at the fly, which dodges.
--           0.97 trap B snaps at nothing as the fly zips past.
--  3.6-4.25 the fly swoops in and lands on the hero trap's pink pad.
--  4.3-4.72 ANTICIPATION: the trap tenses, leans back, dips and gapes wide.
--  4.72-4.84 SNAP shut with overshoot: lunge, body jolt + squash, burst VFX.
--  5.3-6.8  satisfied CHEW: three exaggerated chomps with stem squash/wobble.
--  7.0-7.8  gulp -> green BURP puff (throws its head back).
--  7.8-8.7  reopens with a bouncy backOut; 8.4 a new fly buzzes in from far
--           away, the trap turns to watch it, and the loop restarts.
-- Small traps: B snaps at nothing (0.97, 6.0), C idle-chomps (2.6/2.95) and
-- yawns + snaps (8.05), D is shut and digesting (gentle pulse + glow).
-- Leaves sway always and flap from the shock of the big snap.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, env, track, E = L.ang, L.pa, L.wave, L.env, L.track, L.ease
local sin, cos, rad, deg, atan2, clamp = math.sin, math.cos, math.rad, math.deg, math.atan2, math.clamp
local TAU = math.pi * 2

local M = {}
M.Cycle = 10

------------------------------------------------------------------------
-- rig data (must match build.luau)
------------------------------------------------------------------------
local S1 = CFrame.new(0.2, 1.6, 0.9)
local S2 = CFrame.new(0.15, 3.9, 0.8)
local S3 = CFrame.new(0.05, 5.5, 0.45)
local HT = CFrame.new(0, 7.0, 0.1) * CFrame.Angles(rad(-14), 0, 0)
local LAND = (HT * CFrame.new(0, 0.42, -2.1)).Position
local HINGE = HT.Position
local HB = Vector3.new(3.9, 4.3, -0.6)
local BLADE_A = { -48, -95, -140, 175, 128, 88, 48 }
local OPEN, OPEN_S = 70, 40
local FLY_PARTS = { "FlyBody", "FlyTail", "FlyHead", "FlyEyeR", "FlyEyeL" }

local function rel(pv, X)
	return pv * X * pv:Inverse()
end
local function bez(a, b, c, d, u)
	local iu = 1 - u
	return a * (iu * iu * iu) + b * (3 * iu * iu * u) + c * (3 * iu * u * u) + d * (u * u * u)
end
local function smooth(x)
	x = clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end

------------------------------------------------------------------------
-- fly path (world space)
------------------------------------------------------------------------
local BUZZ = 3.6
local function buzz(c)
	local a = c / BUZZ * TAU
	local x = 4.8 * sin(a) + 0.55 * cos(5 * a) - 0.55
	local y = 9.3 + 1.3 * sin(2 * a) + 0.55 * sin(5 * a)
	local z = -4.6 - 1.6 * cos(a)
	-- near miss at ~1.75: zip upward away from the snapping trap
	y += 1.6 * env(c, 1.6, 0.15, 0.1, 0.6, "quadOut", "sineInOut")
	return Vector3.new(x, y, z)
end
local B0 = buzz(0)
local B0T = (buzz(0.03) - buzz(0)).Unit
local FAR = Vector3.new(-11, 12.5, -10)
local function entry(u) -- u 0..1 : far away -> start of the buzz loop
	local p = bez(FAR, FAR + Vector3.new(4, 1.5, -1), B0 - B0T * 3, B0, u)
	return p + Vector3.new(0, 0.6 * sin(u * TAU * 2.5), 0.4 * sin(u * TAU * 1.5)) * (1 - u)
end

-- small trap lid: anticipation (open wider) -> snap shut -> hold -> backOut reopen
local function snapLid(c, t0, open, wide)
	return track(c, {
		{ t0 - 0.3, 0 },
		{ t0 - 0.06, wide, "cubicOut" },
		{ t0 + 0.04, -open - 5, "quadIn" },
		{ t0 + 0.12, -open + 2, "quadOut" },
		{ t0 + 0.4, -open, "quadIn" },
		{ t0 + 0.95, 0, "backOut" },
	})
end
local function snapHit(c, t0)
	return env(c, t0 - 0.02, 0.06, 0.08, 0.45, "quadOut", "backOut")
end

local function heroLidHungry(c)
	return OPEN + 5 * wave(c, 0.8) + 2 * wave(c, 2.2, 0.3)
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	--------------------------------------------------------------------
	-- fly world position (before landing) + visibility
	--------------------------------------------------------------------
	local landed = false
	local flyP, flyYaw
	local uAppr = 0
	if c < BUZZ then
		flyP = buzz(c)
		local d = buzz(c + 0.03) - flyP
		flyYaw = deg(atan2(-d.X, -d.Z))
	elseif c < 4.25 then
		uAppr = (c - BUZZ) / (4.25 - BUZZ)
		flyP = nil -- resolved after the trap pose is known
	elseif c < 8.4 then
		landed = true
	else
		local u = (c - 8.4) / 1.6
		flyP = entry(u)
		local d = entry(math.min(1, u + 0.02)) - entry(math.max(0, u - 0.02))
		flyYaw = deg(atan2(-d.X, -d.Z))
	end
	local hidden = c >= 4.8 and c < 8.4
	local fade = 0
	if c >= 8.4 then
		fade = 1 - smooth((c - 8.4) / 0.5)
	end

	--------------------------------------------------------------------
	-- hero tracking: look at the fly while it buzzes
	--------------------------------------------------------------------
	local wTrack = (c < 8.5) and (1 - smooth((c - 3.7) / 0.5)) or smooth((c - 8.5) / 0.8)
	local yawT, pitchT = 0, 0
	local tgt = flyP or LAND
	if c >= BUZZ and c < 4.25 then
		tgt = buzz(BUZZ - 0.001):Lerp(LAND, uAppr)
	end
	do
		local d = tgt - HINGE
		local hz = math.sqrt(d.X * d.X + d.Z * d.Z)
		yawT = clamp(deg(atan2(-d.X, -d.Z)), -55, 55)
		pitchT = clamp(deg(atan2(d.Y - 0.9, hz)), -20, 30)
	end
	yawT *= wTrack
	pitchT *= wTrack

	--------------------------------------------------------------------
	-- hero beats
	--------------------------------------------------------------------
	local nip = env(c, 1.62, 0.1, 0.06, 0.4, "quadIn", "backOut") -- near-miss lunge
	local ant = env(c, 4.3, 0.42, 0, 0.12, "cubicOut", "quadIn") -- tense + lean back
	local lunge = env(c, 4.72, 0.12, 0.08, 0.55, "quadIn", "backOut") -- snap lunge
	local squash = env(c, 4.78, 0.08, 0.05, 0.6, "quadOut", "elasticOut")
	local tremble = ant * sin(c * TAU * 9)
	local chew, chewOpen, roll = 0, 0, 0
	for i, ts in { 5.56, 6.11, 6.7 } do
		local h = env(c, ts - 0.05, 0.05, 0.03, 0.3, "quadIn", "backOut")
		chew += h * (0.8 + 0.15 * i)
		chewOpen += env(c, ts - 0.26, 0.2, 0, 0.06, "quadOut", "quadIn")
		roll += h * ((i % 2 == 0) and -9 or 9)
	end
	local wobble = 5 * sin((c - 5.2) * TAU * 1.6) * env(c, 5.2, 0.2, 1.4, 0.4)
	local gulp = env(c, 6.9, 0.3, 0.1, 0.2, "sineInOut", "quadIn")
	local burp = env(c, 7.3, 0.1, 0.12, 0.6, "backOut", "backOut")
	local closedUp = env(c, 4.95, 0.45, 2.3, 0.7, "sineInOut", "sineInOut") -- sits up proud while chewing
	local proud = 7 * sin((c - 7.8) * TAU * 2.2) * env(c, 7.8, 0.15, 0.4, 0.4)

	-- idle hungry sway (absolute t, whole cycles per 10 s)
	local sw1 = wave(t, 0.3)
	local sw2 = wave(t, 0.4, 0.2)

	local X1 = pa(0, -0.35 * ant - 0.7 * squash - 0.35 * chew + 0.15 * gulp, 0,
		2.5 * sw2 + 3 * ant - 4 * nip - 4 * lunge,
		0.25 * yawT,
		3 * sw1 + 0.1 * yawT + 0.3 * roll)
	local X2 = pa(0, 0.25 * gulp, 0,
		2 * sw1 + 6 * ant - 10 * nip - 7 * lunge + 8 * burp + 0.3 * pitchT,
		0.35 * yawT,
		2 * sw2 + 0.4 * roll + wobble * 0.5)
	local X3 = ang(3 * wave(t, 0.4, 0.45) + 4 * ant - 8 * nip - 5 * lunge + 4 * chew + 6 * burp + 0.3 * pitchT,
		0.2 * yawT,
		0.5 * roll + wobble * 0.5)
	local XT = ang(2 * wave(t, 0.6, 0.1) + 5 * ant + tremble * 1.5 - 10 * nip - 9 * lunge - 7 * chew + 6 * gulp + 16 * burp + 12 * closedUp + 0.4 * pitchT,
		0.2 * yawT + proud * 0.6,
		0.4 * roll + wobble + proud)
	pose.Stem1, pose.Stem2, pose.Stem3, pose.Trap = X1, X2, X3, XT

	-- hero lid (absolute angle from shut; built open at OPEN)
	local lid
	if c < 4.25 or c >= 8.7 then
		lid = heroLidHungry(c) - 44 * nip
	else
		lid = track(c, {
			{ 4.25, heroLidHungry(4.25) },
			{ 4.4, 44, "sineInOut" },
			{ 4.72, 68, "cubicOut" },
			{ 4.82, -8, "quadIn" },
			{ 4.94, 3, "quadOut" },
			{ 5.04, -2, "sineInOut" },
			{ 5.14, 0, "sineInOut" },
			{ 7.24, 0 },
			{ 7.36, 32, "backOut" },
			{ 7.6, 26, "sineInOut" },
			{ 7.8, 3, "quadIn" },
			{ 7.95, 3 },
			{ 8.7, heroLidHungry(8.7), "backOut" },
		})
		-- chomps (open, then slam past shut)
		lid += 22 * chewOpen - 4 * chew
	end
	pose.TrapLid = ang(lid - OPEN, 0, 0)

	-- world transform of the trap (forward kinematics) for the fly + drool
	local D1 = rel(S1, X1)
	local D2 = D1 * rel(S2, X2)
	local D3 = D2 * rel(S3, X3)
	local DT = D3 * rel(HT, XT)

	-- drool hangs straight down and swings
	local drSwing = 8 * wave(t, 0.8) + 35 * lunge + 25 * nip - 20 * burp
	pose.Drool = DT.Rotation:Inverse() * ang(drSwing, 0, 6 * wave(t, 0.6, 0.3) + 0.5 * roll)

	--------------------------------------------------------------------
	-- the fly
	--------------------------------------------------------------------
	local landW = DT * LAND
	local rot
	if landed or (c >= 4.25 and c < 4.8) then
		flyP = landW
		rot = DT.Rotation * ang(0, 15 + 10 * wave(t, 3), 0)
	elseif c >= BUZZ and c < 4.25 then
		local u = E.sineInOut(uAppr)
		local p0 = buzz(BUZZ - 0.001)
		flyP = bez(p0, p0 + B0T * 2.0, landW + Vector3.new(0.6, 2.4, -1.2), landW, u)
		-- little hop-hover just before touching down
		flyP += Vector3.new(0, 0.35 * sin(uAppr * math.pi * 3) * (1 - uAppr), 0)
		rot = ang(0, -90 + 105 * u, 0)
	else
		rot = ang(0, flyYaw, 0) * ang(-6, 0, 18 * wave(t, 2.5))
	end
	pose.Fly = CFrame.new(flyP - LAND) * rot
	local flap = (c < 4.25 or c >= 8.4) and 55 * wave(t, 14) or (8 + 14 * math.max(0, wave(t, 2.5)))
	pose.WingR = ang(0, 0, flap)
	pose.WingL = ang(0, 0, -flap)
	local vis = hidden and 1 or fade
	for _, n in FLY_PARTS do
		ctx.transparency(n, vis)
	end
	local wv = hidden and 1 or (0.35 + 0.65 * fade)
	ctx.transparency("FlyWingR", wv)
	ctx.transparency("FlyWingL", wv)

	--------------------------------------------------------------------
	-- small trap B: tracks a little, snaps at nothing (0.97, 6.02)
	--------------------------------------------------------------------
	local yawB = 0
	if flyP and not hidden then
		local d = flyP - HB
		yawB = clamp(deg(atan2(-d.X, -d.Z)) + 42, -30, 30) * 0.4 * wTrack
	end
	local hitB = snapHit(c, 0.97) + snapHit(c, 6.02)
	pose.StemB = ang(3 * wave(t, 0.4, 0.6) - 8 * hitB, 0.5 * yawB, 3 * wave(t, 0.3, 0.1) - 4 * squash)
	pose.TrapB = ang(3 * wave(t, 0.6, 0.4) - 16 * hitB + 6 * squash, 0.5 * yawB, 4 * hitB)
	pose.TrapBLid = ang(4 * wave(t, 0.6, 0.3) + snapLid(c, 0.97, OPEN_S, 14) + snapLid(c, 6.02, OPEN_S, 12), 0, 0)

	--------------------------------------------------------------------
	-- small trap C: idle double-chomp, flinch at the big snap, yawn + snap
	--------------------------------------------------------------------
	local hitC = snapHit(c, 2.6) + snapHit(c, 2.95) + snapHit(c, 8.05)
	local yawn = env(c, 7.4, 0.5, 0.1, 0.06, "sineInOut", "quadIn")
	local flinch = env(c, 4.84, 0.08, 0.1, 0.6, "quadOut", "backOut")
	pose.StemC = ang(3 * wave(t, 0.5, 0.3) - 6 * hitC + 8 * flinch + 6 * yawn, 4 * wave(t, 0.2, 0.7), 3 * wave(t, 0.4, 0.5) + 6 * flinch)
	pose.TrapC = ang(2 * wave(t, 0.7) - 10 * hitC + 14 * yawn, 0, 0)
	local lidC = snapLid(c, 2.6, OPEN_S, 6) + snapLid(c, 2.95, OPEN_S, 6) + snapLid(c, 8.05, OPEN_S, 4)
	pose.TrapCLid = ang(3 * wave(t, 0.5, 0.1) + lidC + 22 * yawn - 12 * flinch, 0, 0)

	--------------------------------------------------------------------
	-- small trap D: shut and digesting - slow pulse, gulps at 3.0 and 7.6
	--------------------------------------------------------------------
	local pulse = wave(t, 0.8)
	local dg = env(c, 3.0, 0.15, 0.1, 0.5, "quadOut", "backOut") + env(c, 7.6, 0.15, 0.1, 0.5, "quadOut", "backOut")
	pose.StemD = ang(2.5 * wave(t, 0.3, 0.8) + 4 * dg, 0, 2.5 * wave(t, 0.4, 0.15) - 3 * squash)
	pose.TrapD = pa(0, 0.08 * pulse - 0.25 * dg, 0, 3 * pulse - 8 * dg, 0, 4 * dg * sin(c * TAU * 4))
	pose.TrapDLid = ang(3 + 3 * pulse - 3 * dg, 0, 0)
	local gl = 0.15 + 0.45 * (0.5 - 0.5 * pulse) - 0.15 * dg
	for _, n in { "DigestGlow1", "DigestGlowL", "DigestGlowR" } do
		ctx.transparency(n, clamp(gl, 0, 0.9))
	end

	--------------------------------------------------------------------
	-- leaves + leaf cubes: gentle sway, flap from the big snap's shock
	--------------------------------------------------------------------
	local shock = env(c, 4.84, 0.07, 0, 0.9, "quadOut", "elasticOut") + 0.5 * env(c, 7.36, 0.08, 0, 0.6, "quadOut", "elasticOut")
	for i, a in BLADE_A do
		local ax = Vector3.new(cos(rad(a)), 0, sin(rad(a)))
		local lift = 3 * wave(t, 0.3, i * 0.137) + 2 * wave(t, 0.5, i * 0.29) + 10 * shock - 2.5 * chew
		pose["Leaf" .. i] = CFrame.fromAxisAngle(ax, rad(lift)) * ang(0, 2 * wave(t, 0.2, i * 0.21), 0)
	end
	pose.Bush = pa(0, 0.05 * wave(t, 0.4) - 0.1 * shock, 0, 1.2 * wave(t, 0.2, 0.3) + 2 * shock, 0, 1.2 * wave(t, 0.3))

	--------------------------------------------------------------------
	-- effects
	--------------------------------------------------------------------
	if ctx.crossed(4.83) then
		ctx.emit("SnapBurst", 40)
		ctx.emit("SnapLeaves", 14)
	end
	for _, ts in { 5.57, 6.12, 6.71 } do
		if ctx.crossed(ts) then
			ctx.emit("SnapBurst", 8)
		end
	end
	if ctx.crossed(7.38) then
		ctx.emit("BurpPuff", 7)
	end
	if ctx.crossed(1.75) then
		ctx.emit("SnapBurst", 10)
	end
	for _, ts in { 0.99, 6.04 } do
		if ctx.crossed(ts) then
			ctx.emit("SmallSnap", 12)
		end
	end
	local flash = env(c, 4.8, 0.05, 0.05, 0.5) + 0.6 * env(c, 7.35, 0.08, 0.1, 0.5)
	ctx.light("MouthLight", 1.4 * flash)
end

return M
