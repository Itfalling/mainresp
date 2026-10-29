--!nocheck
-- Thornback Hedgehog motion (Guardian #4): a short-tempered grump.
--   Idle   - sniffs around, flicks a berry up and munches it, quill ripple,
--            yawn, ah-ah-CHOO sneeze, show-off: curls into a ball and revs a
--            spin-dash in place, pops out with a flip and a proud "hmph"
--   Alert  - double-take, crouch, EVERY quill bristles out with a burst, roar,
--            stomp-stomp, huffs
--   Chase  - curled into a spiky ball and ROLLING (contact point stays on the
--            floor: the ball centre height follows a measured radius table)
--   Attack - wind-up, leaping roll, SLAM with quill burst + shockwave, bounce back
--   Catch  - rears up, smug closed-eye gloat, quills fanned, chuckles, stomps
--   GiveUp - stomping tantrum, spinning hop tantrum, plops down sulking
--   Return - grumpy waddle with muttering jaw
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease

local M = {}
M.Props = {
	AngerMark1 = 1, AngerMark2 = 1, AngerMark3 = 1, AngerMark4 = 1,
	Berry = 1, BerryLeaf = 1, EyelidR = 1, EyelidL = 1,
	BallCover1 = 1, BallCover2 = 1, BallCover3 = 1, BallCover4 = 1, BallCover5 = 1, BallCover6 = 1,
}
local function covers(ctx, k)
	if k > 0.6 then
		for i = 1, 6 do
			ctx.transparency("BallCover" .. i, 0)
		end
	end
end

local max, sin, rad, pi, clamp = math.max, math.sin, math.rad, math.pi, math.clamp
local env, track, remap = L.env, L.track, L.remap
local function r01(c, a, b)
	return clamp(remap(c, a, b), 0, 1)
end

------------------------------------------------------------------------
-- rig constants (model space, must match build.luau)
------------------------------------------------------------------------
local BP = Vector3.new(0, 4.0, 0.6) -- Body pivot
local Q = Vector3.new(0, 1.0, 0.2) -- ball centre in Body-local space
local LEGS = {
	{ "Arm", "Paw", Vector3.new(2.7, 2.6, -2.3) },
	{ "Leg", "Foot", Vector3.new(2.9, 2.6, 2.6) },
}
-- curled-ball "radius" (centre height that keeps the lowest point on the
-- floor) for every 5 degrees of forward roll, measured from the curled pose
local DBALL = {
	6.03, 6.01, 6.03, 6.03, 6.02, 5.96, 5.89, 5.78, 5.65, 5.48, 5.27, 5.03, 4.82, 4.53, 4.32, 4.32, 4.29, 4.23,
	4.13, 4.24, 4.35, 4.42, 4.46, 4.48, 4.48, 4.46, 4.41, 4.32, 4.21, 4.19, 4.47, 4.70, 4.90, 5.06, 5.20, 5.31,
	5.40, 5.43, 5.43, 5.42, 5.38, 5.30, 5.19, 4.99, 4.80, 4.64, 4.79, 4.89, 4.98, 5.01, 5.02, 5.01, 4.98, 4.92,
	4.82, 4.64, 4.61, 4.67, 4.70, 4.88, 5.15, 5.33, 5.49, 5.71, 5.90, 6.05, 6.18, 6.23, 6.24, 6.24, 6.21, 6.14,
}
local BALL_R = 5.05 -- mean rolling radius
local function dBall(roll)
	local r = (roll % 360) / 5
	local i = math.floor(r)
	local f = r - i
	local a, b = DBALL[i % 72 + 1], DBALL[(i + 1) % 72 + 1]
	return a + (b - a) * f + 0.03
end

------------------------------------------------------------------------
-- helpers
------------------------------------------------------------------------
local function quillCF(b)
	return pa(0, 0.35 * b, 0, -22 * b, 0, 0), pa(0.3 * b, 0.2 * b, 0, -12 * b, 0, -24 * b)
end
local function bristle(pose, g, b)
	local c, s = quillCF(b)
	pose["Quill" .. g] = c
	L.both(pose, "Quill" .. g, s)
end
local function bristleAll(pose, bf, bm, br)
	bristle(pose, "F", bf)
	bristle(pose, "M", bm or bf)
	bristle(pose, "R", br or bf)
end

-- planted legs: feet[key] = {x, y, z, pitch, toe} foot offsets (model space,
-- x mirrored for the left), keys "AR","AL","LR","LL"
local function legs(pose, bodyW, feet)
	for _, lg in LEGS do
		for s = 1, -1, -2 do
			local side = s > 0 and "R" or "L"
			local key = lg[1]:sub(1, 1) .. side
			local f = feet and feet[key]
			local ox, oy, oz, pitch, toe = 0, 0, 0, 0, 0
			if f then
				ox, oy, oz, pitch, toe = f[1] or 0, f[2] or 0, f[3] or 0, f[4] or 0, f[5] or 0
			end
			local piv = Vector3.new(lg[3].X * s, lg[3].Y, lg[3].Z)
			local foot = Vector3.new(piv.X, 0, piv.Z)
			local want = CFrame.new(foot + Vector3.new(ox * s, oy, oz)) * CFrame.Angles(rad(pitch), 0, 0) * CFrame.new(piv - foot)
			pose[lg[1] .. side] = (bodyW * CFrame.new(piv - BP)):Inverse() * want
			pose[lg[2] .. side] = ang(toe, 0, 0)
		end
	end
end

-- keep the snout + open jaw above the floor: close the jaw first, then lift the head
local HEADP, JAWP = Vector3.new(0, 4.3, -3.4), Vector3.new(0, 2.95, -4.4)
local HPTS = { Vector3.new(0, 3.9, -10.3), Vector3.new(0, 2.7, -8.4) }
local JPTS = { Vector3.new(0, 1.5, -9.2), Vector3.new(0, 1.5, -5.0), Vector3.new(1.8, 1.8, -9.2) }
local function fixHead(pose)
	local bodyW = CFrame.new(BP) * (pose.Body or CFrame.new())
	local head = pose.Head or CFrame.new()
	local jaw = pose.Jaw or CFrame.new()
	local jx = jaw:ToEulerAnglesXYZ()
	for _ = 1, 14 do
		local hW = bodyW * CFrame.new(HEADP - BP) * head
		local jW = hW * CFrame.new(JAWP - HEADP) * jaw
		local low = math.huge
		for _, p in HPTS do
			low = math.min(low, (hW * (p - HEADP)).Y)
		end
		for _, p in JPTS do
			low = math.min(low, (jW * (p - JAWP)).Y)
		end
		if low >= 0.2 then
			break
		end
		if jx < rad(-4) then
			jaw = jaw * ang(6, 0, 0)
			jx += rad(6)
		else
			head = head * ang(3, 0, 0)
		end
	end
	pose.Head, pose.Jaw = head, jaw
end

local function bodyAt(cfPose)
	return CFrame.new(BP) * cfPose
end

-- curl blend k (0 standing .. 1 ball): Front/Rump fold under, head slides
-- inside, legs tuck, quills half bristled (the DBALL table was measured with
-- exactly this pose, extraBristle 0)
local function curl(pose, k, extraBristle)
	if k <= 0 then
		return
	end
	local function mix(name, target)
		pose[name] = (pose[name] or CFrame.new()):Lerp(target, k)
	end
	mix("Front", ang(-45, 0, 0))
	mix("Rump", ang(45, 0, 0))
	mix("Head", pa(0, 1.8, 6.6, -10, 0, 0))
	local c, s = quillCF(0.5 + (extraBristle or 0))
	for _, g in { "F", "M", "R" } do
		mix("Quill" .. g, c)
		mix("Quill" .. g .. "R", s)
		mix("Quill" .. g .. "L", L.mirror(s))
	end
	local arm = pa(0, 2.4, 1.8, 30, 0, 0)
	local leg = pa(0, 2.2, -1.0, -30, 0, 0)
	mix("ArmR", arm)
	mix("ArmL", L.mirror(arm))
	mix("LegR", leg)
	mix("LegL", L.mirror(leg))
	mix("PawR", CFrame.new())
	mix("PawL", CFrame.new())
	mix("FootR", CFrame.new())
	mix("FootL", CFrame.new())
	mix("Jaw", CFrame.new())
end

-- Body transform for the ball: centre at (x, dBall(roll)+lift, z) model space
local function ballT(roll, x, z, lift)
	local w = CFrame.new(x, dBall(roll) + lift, BP.Z + Q.Z + z) * CFrame.Angles(rad(-roll), 0, 0) * CFrame.new(-Q)
	return CFrame.new(-BP) * w
end

local function lids(ctx, closed)
	local tr = closed and 0 or 1
	ctx.transparency("EyelidR", tr)
	ctx.transparency("EyelidL", tr)
end

local function anger(ctx, pose, t, on)
	if on then
		for i = 1, 4 do
			ctx.transparency("AngerMark" .. i, 0)
		end
		local th = max(0, wave(t, 5)) ^ 3
		pose.Vein = pa(0.1 * th, 0.15 * th, -0.1 * th, 0, 0, 12 * th)
	end
end

local function brows(pose, raise, scrunch)
	-- raise > 0: surprised (up, flatter); scrunch > 0: angrier (down, steeper)
	L.both(pose, "Brow", pa(0, 0.4 * raise - 0.15 * scrunch, -0.05 * raise, 0, 0, -14 * raise + 10 * scrunch))
end

local function orbs(pose, t, hz, spinRate, lift, out)
	pose.Orbit = ang(0, 14 * wave(t, hz * 0.5), 0)
	for i = 1, 4 do
		local dir = i % 2 == 0 and -1 or 1
		local bob = 0.8 * wave(t, hz, i * 0.25) + (lift or 0)
		local o = (out or 0) * dir
		pose["Orb" .. i] = pa(o, bob, 0, spinRate * t * dir, spinRate * 1.3 * t, 0)
	end
end

local function shock(pose, ctx, c, at, cz)
	local u = r01(c, at, at + 0.5)
	local on = c > at and c < at + 0.5
	local r = 5.5 * E.quadOut(u)
	for k = 1, 8 do
		local a = (k - 1) / 8 * 2 * pi
		pose["Shock" .. k] = CFrame.new(-sin(a) * r, 0.3 * (1 - u), (cz or 0) - math.cos(a) * r)
		ctx.transparency("Wave" .. k, on and (0.1 + 0.85 * u * u) or 1)
		ctx.transparency("WaveTop" .. k, on and (0.1 + 0.85 * u * u) or 1)
	end
end

------------------------------------------------------------------------
-- IDLE (12 s): guarding the berry bush
------------------------------------------------------------------------
local IDLE_LEN = 12
local SPIN_A, SPIN_B, SPIN_LAND = 8.9, 10.6, 11.0
local W1 = 5.31 -- rev/s at the pop (total spin = 6 revs)

local function dashRoll(c)
	local d1 = SPIN_B - SPIN_A
	if c < SPIN_A then
		return 0
	elseif c < SPIN_B then
		local u = c - SPIN_A
		return 360 * (0.5 * u + 0.5 * (W1 - 0.5) * u * u / d1)
	elseif c < SPIN_LAND then
		local u = c - SPIN_B
		local d2 = SPIN_LAND - SPIN_B
		local base = 0.5 * d1 + 0.5 * (W1 - 0.5) * d1
		return 360 * (base + W1 * u - 0.5 * W1 * u * u / d2)
	end
	return 360 * 6
end

local CAL = false -- calibration: slow ball spin at a fixed height (measures DBALL)
local function idle(t, pose, ctx)
	local c = t % IDLE_LEN
	if CAL then
		shock(pose, ctx, c, -9, 0)
		covers(ctx, 1)
		curl(pose, 1, 0)
		pose.Body = CFrame.new(-BP) * CFrame.new(0, 8, BP.Z + Q.Z) * CFrame.Angles(rad(-36 * c), 0, 0) * CFrame.new(-Q)
		return
	end

	local sniff = env(c, 0.0, 0.3, 1.6, 0.4)
	local dip = env(c, 2.3, 0.3, 0.15, 0.12, "cubicOut", "backIn")
	local flick = env(c, 2.85, 0.1, 0.45, 0.35, "backOut", "sineInOut")
	local catchOpen = env(c, 3.05, 0.15, 0.15, 0.08, "quadOut", "quadIn")
	local munch = env(c, 3.4, 0.1, 0.9, 0.2)
	local gulp = env(c, 4.35, 0.1, 0.05, 0.3, "quadOut", "backOut")
	local ripple = env(c, 4.7, 0.1, 0.9, 0.2)
	local yawn = env(c, 5.9, 0.45, 0.55, 0.35, "cubicOut", "cubicInOut")
	local ah1 = env(c, 7.2, 0.25, 0.1, 0.12, "sineInOut", "quadIn")
	local ah2 = env(c, 7.55, 0.3, 0.12, 0.08, "sineInOut", "quadIn")
	local choo = env(c, 7.95, 0.06, 0.12, 0.45, "quadOut", "backOut")
	local shakeHd = env(c, 8.1, 0.05, 0.25, 0.15)
	local crouch = env(c, 8.35, 0.3, 0.0, 0.25, "cubicOut", "quadIn")
	local k = E.cubicInOut(r01(c, 8.5, 8.85) * (1 - r01(c, SPIN_B + 0.02, SPIN_B + 0.3)))
	local rev = env(c, SPIN_A, 0.3, 1.4, 0.0)
	local hop = (c > SPIN_B and c < SPIN_LAND) and sin(pi * (c - SPIN_B) / (SPIN_LAND - SPIN_B)) or 0
	local land = env(c, SPIN_LAND, 0.04, 0.06, 0.45, "quadOut", "backOut")
	local proud = env(c, 11.05, 0.2, 0.45, 0.3, "backOut", "sineInOut")
	local busy = max(env(c, 2.25, 0.2, 2.2, 0.3), env(c, 5.85, 0.2, 5.6, 0.3))
	local calm = 1 - busy

	local breathe = wave(t, 0.5)
	local patter = wave(t, 2) * sniff

	-- body (standing)
	local by = 0.12 * breathe - 0.35 * dip + 0.25 * flick - 0.3 * gulp + 0.3 * yawn + 0.2 * ah2 - 0.6 * choo
		- 0.9 * crouch - 0.75 * land + 0.2 * proud
	local bz = -0.3 * dip + 0.35 * yawn - 0.5 * choo + 0.4 * ah2
	local bp = -4 * dip + 8 * flick - 3 * gulp + 10 * yawn + 6 * ah1 + 9 * ah2 - 12 * choo - 6 * crouch + 6 * land
		+ 6 * proud + 1.5 * breathe
	local byaw = 10 * L.noise(t, 2.3, 0.4) * sniff + 4 * shakeHd * wave(t, 7)
	local broll = 3 * patter + 2 * wave(t, 0.25) * calm
	local stand = pa(0, by, bz, bp, byaw, broll)
	pose.Body = stand

	local lR = 0.45 * max(0, patter)
	local lL = 0.45 * max(0, -patter)
	legs(pose, bodyAt(stand), {
		AR = { 0, lR, -0.1 * lR, 0, -15 * lR },
		AL = { 0, lL, -0.1 * lL, 0, -15 * lL },
		LR = { 0, 0.6 * lL, 0, 0, 0 },
		LL = { 0, 0.6 * lR, 0, 0, 0 },
	})

	-- head / face
	local look = 22 * L.noise(t, 7.7, 0.35) * calm + 26 * L.noise(t, 1.9, 0.6) * sniff
	local hp = -14 * sniff - 26 * dip + 34 * flick - 10 * gulp + 30 * yawn + 12 * ah1 + 18 * ah2 - 16 * choo
		+ 22 * proud + 4 * wave(t, 0.5, 0.2)
	local hroll = 6 * L.noise(t, 4.4, 0.4) * calm + 14 * shakeHd * wave(t, 9)
	pose.Head = ang(hp, look + 30 * shakeHd * wave(t, 6), hroll - 8 * proud)
	pose.Nose = ang(7 * wave(t, 8) * (sniff + 0.4 * dip) + 10 * ah2 - 10 * choo, 6 * wave(t, 4) * sniff, 0)
	local chomp = munch * max(0, wave(t, 5))
	local mutter = 0.5 * calm * max(0, wave(t, 1.5, 0.1)) ^ 6
	pose.Jaw = ang(-4 - 8 * mutter - 40 * catchOpen - 18 * chomp - 62 * yawn - 22 * ah2 - 30 * choo + 4 * gulp, 0, 0)
	fixHead(pose)
	brows(pose, 0.6 * flick + 0.8 * yawn + 0.6 * ah2 - 0.2 * proud, 0.4 * sniff + 0.5 * munch + 0.6 * shakeHd + 0.3 * crouch)
	L.both(pose, "Ear", ang(0, 0, -16 * max(0, wave(t, 0.5, 0.3)) ^ 12 - 20 * choo + 10 * yawn))
	local bl = env(c, 1.55, 0.05, 0.05, 0.05) + env(c, 1.75, 0.05, 0.05, 0.05) + env(c, 4.95, 0.05, 0.05, 0.05)
	lids(ctx, bl > 0.4 or yawn > 0.5 or (c > 7.9 and c < 8.15) or proud > 0.5 or munch > 0.5)

	-- quills: ripple wave, sneeze bristle
	local function q(lag)
		return ripple * wave(t, 2, -lag) * 0.7 + 1.3 * choo - 0.3 * crouch + 0.5 * proud + 0.06 * breathe
	end
	bristleAll(pose, q(0), q(0.12), q(0.24))

	-- spin-dash show-off (ball), then a flip out of the ball
	pose.Body = stand
	if k > 0 then
		local roll = dashRoll(c)
		local jitter = 0.12 * rev * wave(t, 13)
		local bt = ballT(roll, jitter, 0.35 * rev, 3.2 * hop)
		pose.Body = stand:Lerp(bt, k)
		curl(pose, k, 0.25 * rev)
		covers(ctx, k)
	elseif c >= SPIN_B and c < SPIN_LAND then
		local roll = dashRoll(c)
		pose.Body = CFrame.new(-BP) * CFrame.new(0, BP.Y + Q.Y + 3.2 * hop, BP.Z + Q.Z) * CFrame.Angles(rad(-roll), 0, 0) * CFrame.new(-Q)
		L.both(pose, "Arm", pa(0, 0.4, 0, -40, 0, 50))
		L.both(pose, "Leg", pa(0, 0.4, 0, 30, 0, 20))
		pose.Jaw = ang(-35, 0, 0)
		bristleAll(pose, 1.0)
	end

	-- berry snack prop: appears in front, flicked up, caught, munched
	local showBerry = c > 2.25 and c < 3.32
	ctx.transparency("Berry", showBerry and 0 or 1)
	ctx.transparency("BerryLeaf", showBerry and 0 or 1)
	if showBerry then
		local u = r01(c, 2.9, 3.3)
		local y = 4.5 * u + 6.0 * sin(pi * u) * (1 - 0.15 * u)
		local z = 2.2 * u
		pose.Snack = pa(0, y, z, -260 * u, 120 * u, 0)
	end

	orbs(pose, t, 1 / 3, 60, 1.0 * proud - 1.2 * land, 0.8 * rev)
	shock(pose, ctx, c, -9, 0)

	-- effects
	if ctx.crossed(1.9) then ctx.emit("Huff", 6) end
	if ctx.crossed(2.3) then ctx.emit("Sparkle", 6) end
	for _, at in { 3.45, 3.65, 3.85, 4.05, 4.25 } do
		if ctx.crossed(at) then ctx.emit("Crumbs", 5) end
	end
	if ctx.crossed(4.75) then ctx.emit("QuillBurst", 8) end
	if ctx.crossed(7.98) then
		ctx.emit("Huff", 22)
		ctx.emit("QuillBurst", 18)
		ctx.emit("Leaves", 10)
	end
	for i = 0, 16 do
		if ctx.crossed(SPIN_A + 0.1 * i) then
			ctx.emit("RollDust", 2 + math.floor(i / 4))
			ctx.emit("RollLeaves", 1 + math.floor(i / 5))
		end
	end
	if ctx.crossed(SPIN_B) then
		ctx.emit("QuillBurst", 30)
		ctx.emit("StompDust", 12)
	end
	if ctx.crossed(SPIN_LAND) then
		ctx.emit("StompDust", 22)
		ctx.emit("Sparkle", 10)
	end
	ctx.light("BristleLight", 1.2 * choo + 0.8 * rev)
end

------------------------------------------------------------------------
-- ALERT (2.0 s): MY BERRIES!
------------------------------------------------------------------------
local BOOM = 0.55
local function alert(t, pose, ctx)
	local c = t
	local take = env(c, 0.0, 0.08, 0.1, 0.12, "backOut", "quadIn")
	local crouch = env(c, 0.2, 0.3, 0.05, 0.12, "cubicOut", "quadIn")
	local boom = env(c, BOOM, 0.08, 0.35, 0.5, "backOut", "cubicInOut")
	local jump = (c > BOOM and c < BOOM + 0.4) and sin(pi * (c - BOOM) / 0.4) or 0
	local stompR = env(c, 0.95, 0.12, 0.0, 0.08, "quadOut", "quadIn")
	local stompL = env(c, 1.25, 0.12, 0.0, 0.08, "quadOut", "quadIn")
	local hitR = env(c, 1.15, 0.03, 0.03, 0.2)
	local hitL = env(c, 1.45, 0.03, 0.03, 0.2)
	local ready = env(c, 1.55, 0.2, 0.1, 0.15)
	local settle = 1 - r01(c, 1.6, 2.0)
	local rage = (c > BOOM and 1 or 0) * settle
	local rumble = crouch * wave(t, 18)

	local by = 0.3 * take - 0.7 * crouch + 1.6 * jump - 0.5 * (hitR + hitL) - 0.5 * ready
	local bp = 6 * take - 8 * crouch + 10 * boom * settle + 6 * stompR + 6 * stompL - 4 * ready
	local broll = 1.5 * rumble - 7 * stompR + 7 * stompL
	local stand = pa(0.1 * rumble, by, 0.4 * crouch, bp, 0, broll)
	pose.Body = stand
	legs(pose, bodyAt(stand), {
		AR = { 0, 1.6 * stompR + 0.6 * jump, -0.4 * stompR, 0, -20 * stompR },
		AL = { 0, 1.6 * stompL + 0.6 * jump, -0.4 * stompL, 0, -20 * stompL },
		LR = { 0, 0.5 * jump, 0, 0, 10 * jump },
		LL = { 0, 0.5 * jump, 0, 0, 10 * jump },
	})

	local headShake = rage * 10 * wave(t, 7)
	pose.Head = ang(14 * take - 18 * crouch + 26 * boom * settle - 10 * (hitR + hitL) - 6 * ready, 18 * take + headShake, -6 * take)
	pose.Nose = ang(-8 * crouch + 10 * boom, 0, 0)
	pose.Jaw = ang(-12 * take - 64 * boom * settle - 20 * (stompR + stompL) * settle, 0, 0)
	fixHead(pose)
	brows(pose, 1.2 * take - 0.4 * crouch, 1.2 * crouch + 1.0 * rage)
	L.both(pose, "Ear", ang(0, 0, -30 * crouch + 25 * boom))
	lids(ctx, crouch > 0.6)
	anger(ctx, pose, t, c > BOOM)

	local b = -0.7 * crouch + 1.5 * boom * settle
	local qv = 0.15 * rage * wave(t, 9)
	bristleAll(pose, b + qv, b + 0.2 * boom * settle - qv, b + qv)
	orbs(pose, t, 1, 90, 1.5 * boom, 1.5 * boom)

	if ctx.crossed(BOOM) then
		ctx.emit("QuillBurst", 55)
		ctx.emit("Leaves", 14)
		ctx.emit("Huff", 18)
		ctx.emit("StompDust", 10)
	end
	if ctx.crossed(BOOM + 0.4) then ctx.emit("StompDust", 14) end
	if ctx.crossed(1.15) then ctx.emit("StompDust", 12); ctx.emit("Huff", 8) end
	if ctx.crossed(1.45) then ctx.emit("StompDust", 12); ctx.emit("Huff", 8) end
	shock(pose, ctx, c, BOOM + 0.4, 2.5)
	ctx.light("BristleLight", 1.5 * boom * settle)
end

------------------------------------------------------------------------
-- CHASE (0.8 s loop): spiky rolling ball, one revolution per loop
------------------------------------------------------------------------
local CHASE_LEN = 0.9
local function chase(t, pose, ctx)
	local c = t % CHASE_LEN
	local roll = 360 * c / CHASE_LEN
	pose.Body = ballT(roll, 0, 0, 0)
	curl(pose, 1, 0)
	covers(ctx, 1)
	orbs(pose, t, 1 / CHASE_LEN, 400, 0.5, 1.0)
	shock(pose, ctx, c, -9, 0)
	for _, at in { 0.0, 0.225, 0.45, 0.675 } do
		if ctx.crossed(at) then
			ctx.emit("RollDust", 3)
			ctx.emit("RollLeaves", 2)
		end
	end
	if ctx.crossed(0.1) then ctx.emit("QuillBurst", 2) end
end

------------------------------------------------------------------------
-- ATTACK (1.2 s): leaping roll slam
------------------------------------------------------------------------
local HIT = 0.6
local function attack(t, pose, ctx)
	local c = t
	local k = E.cubicOut(r01(c, 0, 0.16)) * (1 - E.cubicInOut(r01(c, 0.85, 1.05)))
	local roll = track(c, { { 0, 0 }, { 0.18, -50, "quadOut" }, { HIT, 720, "quadIn" }, { 0.95, 360, "quadOut" } })
	local z = track(c, { { 0.18, 0.5 }, { HIT, -3.2, "sineInOut" }, { 0.95, 0, "sineInOut" } })
	local up = 0
	if c > 0.18 and c < HIT then
		up = 4.2 * sin(pi * (c - 0.18) / (HIT - 0.18))
	elseif c > HIT + 0.04 and c < 0.95 then
		up = 2.0 * sin(pi * (c - HIT - 0.04) / (0.95 - HIT - 0.04))
	end
	local impact = env(c, HIT, 0.03, 0.06, 0.35, "quadOut", "backOut")
	local land = env(c, 1.0, 0.04, 0.04, 0.16, "quadOut", "sineInOut")
	local crouchS = env(c, 0.0, 0.16, 0.02, 0.05)

	local stand = pa(0, -0.6 * land - 0.5 * crouchS, 0, 4 * land, 0, 0)
	pose.Body = stand
	legs(pose, bodyAt(stand), nil)
	brows(pose, 0, 1.2)
	pose.Jaw = ang(-20 * land, 0, 0)
	bristleAll(pose, 0.3 * land)
	if k > 0 then
		pose.Body = stand:Lerp(ballT(roll, 0, z, up + 0.9 * impact), k)
		curl(pose, k, 0.9 * impact)
		covers(ctx, k)
	end
	anger(ctx, pose, t, true)
	orbs(pose, t, 1, 120, -1.5 * impact, 0)
	shock(pose, ctx, c, HIT, -0.6)
	if ctx.crossed(0.18) then ctx.emit("RollDust", 6) end
	if ctx.crossed(HIT) then
		ctx.emit("QuillBurst", 60)
		ctx.emit("StompDust", 30)
		ctx.emit("RollLeaves", 12)
	end
	if ctx.crossed(1.0) then ctx.emit("StompDust", 10) end
	ctx.light("BristleLight", 1.5 * impact)
end

------------------------------------------------------------------------
-- CATCH (2.2 s): smug victory gloat
------------------------------------------------------------------------
local function catchS(t, pose, ctx)
	local c = t
	local rear = env(c, 0.1, 0.35, 1.05, 0.35, "backOut", "cubicInOut")
	local chuckle = env(c, 0.6, 0.1, 0.75, 0.15) * max(0, wave(t, 5))
	local stomp = env(c, 1.75, 0.05, 0.05, 0.3, "quadOut", "backOut")
	local nod = env(c, 1.8, 0.1, 0.05, 0.25)
	local fan = env(c, 0.25, 0.3, 1.0, 0.4, "backOut", "sineInOut")

	local stand = pa(0, 1.1 * rear + 0.25 * chuckle - 0.6 * stomp, 1.2 * rear, 30 * rear - 2 * chuckle, 0, 0)
	pose.Body = stand
	legs(pose, bodyAt(stand), nil)
	-- front arms come off the ground: folded smugly across the chest
	local armR = pa(-0.2 * rear, 0.6 * rear, -0.3 * rear, 75 * rear, 25 * rear, -40 * rear)
	pose.ArmR = pose.ArmR:Lerp(armR, rear)
	pose.ArmL = pose.ArmL:Lerp(L.mirror(armR), rear)
	pose.PawR = ang(-30 * rear, 0, 0)
	pose.PawL = ang(-30 * rear, 0, 0)
	pose.Head = ang(-16 * rear + 4 * chuckle - 12 * nod, 18 * rear * wave(t, 0.5, 0.1), -8 * rear)
	pose.Jaw = ang(-6 - 14 * chuckle - 10 * nod, 0, 0)
	fixHead(pose)
	pose.Nose = ang(12 * rear, 0, 0)
	brows(pose, -0.2 * rear, 0.3)
	lids(ctx, rear > 0.5)
	L.both(pose, "Ear", ang(0, 0, 10 * rear))
	local function fw(lag)
		return 1.1 * fan + 0.15 * fan * wave(t, 2.5, -lag)
	end
	bristleAll(pose, fw(0), fw(0.15), fw(0.3))
	orbs(pose, t, 1, 180, 2.0 * fan, 1.0 * fan)
	shock(pose, ctx, c, -9, 0)
	if ctx.crossed(0.4) then ctx.emit("Sparkle", 16); ctx.emit("QuillBurst", 14) end
	for _, at in { 0.7, 0.9, 1.1, 1.3 } do
		if ctx.crossed(at) then ctx.emit("Huff", 3) end
	end
	if ctx.crossed(1.78) then ctx.emit("StompDust", 16) end
	ctx.light("BristleLight", 0.8 * fan)
end

------------------------------------------------------------------------
-- GIVE UP (2.6 s): tantrum then sulk
------------------------------------------------------------------------
local function giveUp(t, pose, ctx)
	local c = t
	local shockA = env(c, 0.12, 0.08, 0.08, 0.1, "backOut", "quadIn")
	local s1 = env(c, 0.22, 0.1, 0.0, 0.07, "quadOut", "quadIn")
	local s2 = env(c, 0.45, 0.1, 0.0, 0.07, "quadOut", "quadIn")
	local s3 = env(c, 0.68, 0.1, 0.0, 0.07, "quadOut", "quadIn")
	local spinW = r01(c, 0.9, 1.7)
	local spinning = c > 0.9 and c < 1.7
	local hops = spinning and math.abs(sin(pi * 4 * (c - 0.9) / 0.8)) or 0
	local plop = env(c, 1.72, 0.08, 0.5, 0.4, "quadIn", "sineInOut")
	local sulkHead = env(c, 1.75, 0.2, 0.4, 0.45)
	local rise = 1 - r01(c, 2.2, 2.6)
	local rage = c < 1.75 and 1 or 0

	local yaw = 720 * E.cubicInOut(spinW)
	local pop = env(c, 0.0, 0.1, 0.06, 0.16, "quadOut", "quadIn")
	local by = 1.0 * pop + 0.2 * shockA - 0.4 * (s1 + s2 + s3) + 1.5 * hops - 0.85 * plop
	local stand = pa(0, by, 0, 4 * (s1 + s3) + 3 * s2 - 5 * plop, yaw, -6 * s1 + 6 * s2 - 6 * s3)
	pose.Body = stand
	-- planted feet are in world space; while spinning they ride along the yaw
	local legW = bodyAt(stand)
	if spinning then
		legW = CFrame.new(BP) * CFrame.Angles(0, rad(yaw), 0):Inverse() * CFrame.new(-BP) * legW
	end
	legs(pose, legW, {
		AR = { 0, 1.4 * s1 + 1.4 * s3 + 0.7 * hops, 0, 0, -15 * (s1 + s3) },
		AL = { 0, 1.4 * s2 + 0.7 * hops, 0, 0, -15 * s2 },
		LR = { 0, 0.6 * hops, 0, 0, 0 },
		LL = { 0, 0.6 * hops, 0, 0, 0 },
	})
	pose.Head = ang(12 * shockA - 8 * (s1 + s2 + s3) + 14 * hops - 18 * sulkHead * rise, 14 * rage * wave(t, 6), 10 * sulkHead * rise)
	pose.Jaw = ang(-30 * shockA - 40 * (s1 + s2 + s3) - 30 * hops + 6 * sulkHead, 0, 0)
	fixHead(pose)
	brows(pose, 1.0 * shockA - 0.4 * sulkHead, 1.3 * rage + 0.5 * sulkHead)
	L.both(pose, "Ear", ang(0, 0, -25 * plop * rise))
	lids(ctx, plop > 0.6 and c < 2.15)
	anger(ctx, pose, t, c > 0.15 and c < 1.8)
	local b = 1.2 * (c > 0.2 and 1 or 0) * (1 - plop) * r01(c, 0.15, 0.3) - 0.6 * plop * rise
	bristleAll(pose, b + 0.1 * wave(t, 8), b, b - 0.1 * wave(t, 8))
	orbs(pose, t, 1, 150, -1.0 * plop, 0)
	shock(pose, ctx, c, -9, 0)
	for _, at in { 0.32, 0.55, 0.78 } do
		if ctx.crossed(at) then ctx.emit("StompDust", 10); ctx.emit("Huff", 5) end
	end
	for i = 1, 4 do
		if ctx.crossed(0.9 + 0.2 * i) then ctx.emit("StompDust", 6); ctx.emit("RollLeaves", 3) end
	end
	if ctx.crossed(1.8) then ctx.emit("StompDust", 18) end
	if ctx.crossed(2.0) then ctx.emit("Huff", 10) end
	ctx.light("BristleLight", 0.6 * hops)
end

------------------------------------------------------------------------
-- RETURN (1.0 s loop): grumpy waddle home
------------------------------------------------------------------------
local RET_LEN = 1.0
local STRIDE = 2.4 -- foot slide per stance (studs)
local DUTY = 0.6
local function stepFoot(ph)
	-- ph in [0,1): stance first (foot slides back), then swing (lifted)
	if ph < DUTY then
		local u = ph / DUTY
		return 0, STRIDE * (u - 0.5), 0
	end
	local u = (ph - DUTY) / (1 - DUTY)
	return 0.9 * sin(pi * u), STRIDE * (0.5 - E.sineInOut(u)), -25 * sin(pi * u)
end
local function retWalk(t, pose, ctx)
	local c = t % RET_LEN
	local ph = c / RET_LEN
	local hz = 1 / RET_LEN
	local by = -0.15 - 0.2 * math.abs(wave(t, 2 * hz))
	local stand = pa(0, by, 0, -3 + 2 * wave(t, 2 * hz, 0.1), 5 * wave(t, hz), 6 * wave(t, hz, 0.05))
	pose.Body = stand
	local function f(p)
		local y, z, toe = stepFoot(p % 1)
		return { 0, y, z, 0, toe }
	end
	legs(pose, bodyAt(stand), { AR = f(ph), LL = f(ph), AL = f(ph + 0.5), LR = f(ph + 0.5) })
	pose.Head = ang(-10 + 4 * wave(t, 2 * hz, 0.15), -6 * wave(t, hz, -0.1), -4 * wave(t, hz, 0.1))
	pose.Jaw = ang(-4 - 8 * max(0, wave(t, 4 * hz)) ^ 2, 0, 0)
	fixHead(pose)
	pose.Nose = ang(5 * wave(t, 4 * hz), 0, 0)
	brows(pose, 0, 0.8)
	L.both(pose, "Ear", ang(0, 0, -6 * wave(t, 2 * hz)))
	local w = 0.12 * wave(t, 2 * hz)
	bristleAll(pose, 0.15 + w, 0.15 - w, 0.15 + w)
	orbs(pose, t, hz, 90, 0, 0)
	shock(pose, ctx, c, -9, 0)
	if ctx.crossed(0.0) then ctx.emit("StompDust", 2) end
	if ctx.crossed(0.5) then ctx.emit("StompDust", 2); ctx.emit("Huff", 2) end
end

M.States = {
	Idle = { Loop = true, Length = IDLE_LEN, Update = idle },
	Alert = { Length = 2.0, Update = alert },
	Chase = { Loop = true, Length = CHASE_LEN, Speed = 2 * pi * BALL_R / CHASE_LEN, Update = chase },
	Attack = { Length = 1.2, Update = attack },
	Catch = { Length = 2.2, Update = catchS },
	GiveUp = { Length = 2.6, Update = giveUp },
	Return = { Loop = true, Length = RET_LEN, Speed = STRIDE / (DUTY * RET_LEN), Update = retWalk },
}
M.Base = "Idle"
M.Reel = { { "Idle" }, { "Alert" }, { "Chase", 3.6 }, { "Attack" }, { "Catch" }, { "Chase", 1.8 }, { "GiveUp" }, { "Return", 3.6 } }
return L.states(M)
