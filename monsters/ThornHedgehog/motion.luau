--!nocheck
-- Thornback Hedgehog motion (Guardian #4): a chubby round short-tempered grump.
--   Idle   - sniffs around (nose wiggle, foot patter), flicks a berry up with
--            its snout and munches it with both paws, quill ripple, big yawn,
--            ah-ah-CHOO sneeze that bristles every quill, show-off: curls into
--            a ball and revs a spin-dash in place, pops out with a flip and a
--            proud "hmph"
--   Alert  - double-take, crouch, EVERY quill bristles out with a jump + burst,
--            roar, stomp-stomp, leans in ready
--   Chase  - curled into a spiky ball and ROLLING (the ball centre height
--            follows a measured table so the lowest point stays on the floor)
--   Attack - curl, wind back, leaping roll, SLAM with quill burst + shockwave
--   Catch  - hop-curl spin, POPS open in a victory pose, smug closed-eye gloat
--   GiveUp - stomping tantrum, curls up and spins in a tantrum, plops out and
--            sulks with crossed paws
--   Return - grumpy two-footed waddle, muttering
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease

local M = {}
M.Props = {
	AngerMark1 = 1, AngerMark2 = 1, AngerMark3 = 1, AngerMark4 = 1,
	Berry = 1, BerryLeaf = 1, EyelidR = 1, EyelidL = 1, LashR = 1, LashL = 1,
}
local NCOVER = 41
for i = 1, NCOVER do
	M.Props["BallCover" .. i] = 1
end
local function covers(ctx, k)
	if k > 0.6 then
		for i = 1, NCOVER do
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
local BP = Vector3.new(0, 1.3, 0.4) -- Body pivot
local BC = Vector3.new(0, 4.6, 0.4) -- ball centre
local Q = BC - BP -- ball centre in Body-local space
local HIP = Vector3.new(1.75, 1.3, 0.0)

-- curled-ball "radius" (centre height that keeps the lowest point on the
-- floor) for every 5 degrees of forward roll, measured with CAL = true
local DBALL = {
	6.39, 6.54, 6.65, 6.70, 6.70, 6.80, 6.97, 7.08, 7.14, 7.18, 7.40, 7.56, 7.66, 7.70, 7.69, 7.62, 7.48, 7.30,
	7.11, 7.33, 7.51, 7.63, 7.69, 7.69, 7.64, 7.52, 7.35, 7.12, 6.84, 6.51, 6.12, 5.90, 5.73, 5.52, 5.66, 5.82,
	6.02, 6.19, 6.32, 6.39, 6.42, 6.56, 6.71, 6.81, 6.87, 6.86, 6.91, 7.03, 7.10, 7.12, 7.08, 7.07, 7.12, 7.12,
	7.07, 6.99, 6.86, 6.90, 7.02, 7.08, 7.09, 7.05, 6.95, 6.99, 7.07, 7.09, 7.06, 6.97, 6.83, 6.64, 6.40, 6.25,
}
local BALL_R = 6.91 -- mean rolling radius
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
-- quill groups pop outward along their mean normal
local QDIR = {
	QuillF = Vector3.new(0, 0.6, 0.2), QuillFR = Vector3.new(0.55, 0.35, 0.1),
	QuillB = Vector3.new(0, 0.3, 0.6), QuillBR = Vector3.new(0.5, 0.15, 0.4),
}
local TUCK = {
	QuillF = Vector3.new(0, -0.3, -1.6), QuillFR = Vector3.new(-0.5, 0, -1.6),
	QuillB = Vector3.new(0, -0.3, -2.0), QuillBR = Vector3.new(-0.6, 0, -2.0),
}
local function bristle(pose, g, b)
	local d = QDIR["Quill" .. g]
	local ds = QDIR["Quill" .. g .. "R"]
	pose["Quill" .. g] = CFrame.new(d * b)
	L.both(pose, "Quill" .. g, CFrame.new(ds * b))
end
local function bristleAll(pose, bf, bb)
	bristle(pose, "F", bf)
	bristle(pose, "B", bb or bf)
end

-- planted feet: feet[side] = {x, y, z, pitch} foot offsets (model space, x
-- mirrored for the left)
local function legs(pose, bodyW, feet)
	for s = 1, -1, -2 do
		local side = s > 0 and "R" or "L"
		local f = feet and feet[side]
		local ox, oy, oz, pitch = 0, 0, 0, 0
		if f then
			ox, oy, oz, pitch = f[1] or 0, f[2] or 0, f[3] or 0, f[4] or 0
		end
		local piv = Vector3.new(HIP.X * s, HIP.Y, HIP.Z)
		local foot = Vector3.new(piv.X, 0, piv.Z - 0.9)
		local want = CFrame.new(foot + Vector3.new(ox * s, oy, oz)) * CFrame.Angles(rad(pitch), 0, 0) * CFrame.new(piv - foot)
		pose["Leg" .. side] = (bodyW * CFrame.new(piv - BP)):Inverse() * want
		pose["Foot" .. side] = CFrame.new()
	end
end

local function bodyAt(cfPose)
	return CFrame.new(BP) * cfPose
end

-- curl blend k (0 standing .. 1 ball): face slides inside the ball, paws and
-- feet tuck in, quills half bristled. (The DBALL table was measured with
-- exactly this pose, extraBristle 0.)
local function curl(pose, k, extraBristle)
	if k <= 0 then
		return
	end
	local function mix(name, target)
		pose[name] = (pose[name] or CFrame.new()):Lerp(target, k)
	end
	mix("Head", pa(0, 0, 2.7, 0, 0, 0))
	-- the back-swept quills slide forward/in so the ball stays round
	local qb = 0.3 + (extraBristle or 0)
	for g, d in { F = QDIR.QuillF, B = QDIR.QuillB } do
		local ds = QDIR["Quill" .. g .. "R"]
		local tuck = TUCK["Quill" .. g]
		local tuckS = TUCK["Quill" .. g .. "R"]
		mix("Quill" .. g, CFrame.new(d * qb + tuck))
		mix("Quill" .. g .. "R", CFrame.new(ds * qb + tuckS))
		mix("Quill" .. g .. "L", L.mirror(CFrame.new(ds * qb + tuckS)))
	end
	local arm = pa(-0.4, 0.5, 1.5, 0, 0, 0)
	local leg = pa(-0.45, 1.1, 0.9, 0, 0, 0)
	mix("ArmR", arm)
	mix("ArmL", L.mirror(arm))
	mix("LegR", leg)
	mix("LegL", L.mirror(leg))
	mix("FootR", CFrame.new())
	mix("FootL", CFrame.new())
	mix("Jaw", CFrame.new())
	mix("Nose", CFrame.new())
	mix("Tail", pa(0, 0.3, -0.6, 0, 0, 0))
end

-- Body transform for the ball: centre at (x, dBall(roll)+lift, z) model
-- space, rolled forward by roll degrees, optionally spun by yaw degrees
local function ballT(roll, x, z, lift, yaw)
	local w = CFrame.new(x, dBall(roll) + lift, BC.Z + z) * CFrame.Angles(0, rad(yaw or 0), 0)
		* CFrame.Angles(rad(-roll), 0, 0) * CFrame.new(-Q)
	return CFrame.new(-BP) * w
end

local function lids(ctx, closed)
	local tr = closed and 0 or 1
	ctx.transparency("EyelidR", tr)
	ctx.transparency("EyelidL", tr)
	ctx.transparency("LashR", tr)
	ctx.transparency("LashL", tr)
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
	L.both(pose, "Brow", pa(0, 0.4 * raise - 0.18 * scrunch, -0.05 * raise, 0, 0, -14 * raise + 10 * scrunch))
end

local function eyes(pose, x, y)
	pose.PupilR = CFrame.new(x, y, 0)
	pose.PupilL = CFrame.new(x, y, 0)
end

local function orbs(pose, t, hz, spinRate, lift, out)
	pose.Orbit = ang(0, 14 * wave(t, hz), 0)
	for i = 1, 4 do
		local dir = i % 2 == 0 and -1 or 1
		local bob = 0.8 * wave(t, hz, i * 0.25) + (lift or 0)
		local o = (out or 0) * dir
		pose["Orb" .. i] = pa(o, bob, 0, spinRate * t * dir, spinRate * 2 * t, 0)
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
		pose.Body = CFrame.new(-BP) * CFrame.new(0, 10, BC.Z) * CFrame.Angles(rad(-33 * (c - 0.5)), 0, 0) * CFrame.new(-Q)
		return
	end

	local sniff = env(c, 0.0, 0.3, 1.6, 0.4)
	local dip = env(c, 2.3, 0.3, 0.15, 0.12, "cubicOut", "backIn")
	local flick = env(c, 2.85, 0.1, 0.45, 0.35, "backOut", "sineInOut")
	local catchOpen = env(c, 3.05, 0.15, 0.15, 0.08, "quadOut", "quadIn")
	local munch = env(c, 3.4, 0.1, 0.9, 0.2)
	local hold = env(c, 3.25, 0.15, 1.05, 0.25)
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
	local by = 0.12 * breathe - 0.25 * dip + 0.25 * flick - 0.2 * gulp + 0.3 * yawn + 0.2 * ah2 - 0.4 * choo
		- 0.5 * crouch - 0.5 * land + 0.2 * proud + 0.12 * math.abs(patter)
	local bz = -0.3 * dip + 0.3 * yawn - 0.4 * choo + 0.3 * ah2
	local bp = -7 * dip + 6 * flick - 3 * gulp + 8 * yawn + 5 * ah1 + 8 * ah2 - 9 * choo - 5 * crouch + 5 * land
		+ 6 * proud + 1.2 * breathe
	local byaw = 10 * L.noise(t, 2.3, 0.4) * sniff + 4 * shakeHd * wave(t, 7)
	local broll = 4 * patter + 2 * wave(t, 0.25) * calm
	local stand = pa(0, by, bz, bp, byaw, broll)
	pose.Body = stand

	local lR = 0.5 * max(0, patter)
	local lL = 0.5 * max(0, -patter)
	legs(pose, bodyAt(stand), { R = { 0, lR, 0, -10 * lR }, L = { 0, lL, 0, -10 * lL } })

	-- face (slides around the ball)
	local edge = r01(c, 0, 0.6) * (1 - r01(c, IDLE_LEN - 0.6, IDLE_LEN))
	local look = (18 * L.noise(c, 7.7, 0.35) * calm + 20 * L.noise(c, 1.9, 0.6) * sniff) * edge
	local hp = -6 * sniff - 6 * dip + 10 * flick - 4 * gulp + 8 * yawn + 5 * ah1 + 8 * ah2 - 7 * choo
		+ 6 * proud + 2 * wave(t, 0.5, 0.2)
	local hroll = 4 * L.noise(c, 4.4, 0.4) * calm * edge + 6 * shakeHd * wave(t, 9)
	pose.Head = ang(hp, look + 20 * shakeHd * wave(t, 6), hroll - 4 * proud)
	pose.Nose = ang(7 * wave(t, 8) * (sniff + 0.4 * dip) + 10 * ah2 - 10 * choo, 7 * wave(t, 4) * sniff, 0)
	local chomp = munch * max(0, wave(t, 5))
	local mutter = 0.5 * calm * max(0, wave(t, 1.5, 0.1)) ^ 6
	pose.Jaw = ang(-4 - 10 * mutter - 40 * catchOpen - 22 * chomp - 55 * yawn - 22 * ah2 - 30 * choo + 4 * gulp, 0, 0)
	brows(pose, 0.6 * flick + 0.8 * yawn + 0.6 * ah2 - 0.2 * proud, 0.4 * sniff + 0.5 * munch + 0.6 * shakeHd + 0.3 * crouch)
	L.both(pose, "Ear", ang(0, 0, -16 * max(0, wave(t, 0.5, 0.3)) ^ 12 - 20 * choo + 10 * yawn))
	eyes(pose, 0.22 * L.noise(c, 3.3, 0.5) * calm, -0.2 * dip + 0.2 * flick)
	local bl = env(c, 1.55, 0.05, 0.05, 0.05) + env(c, 1.75, 0.05, 0.05, 0.05) + env(c, 4.95, 0.05, 0.05, 0.05)
	lids(ctx, bl > 0.4 or yawn > 0.5 or (c > 7.9 and c < 8.15) or proud > 0.5 or munch > 0.5)

	-- paws: patter, hold the berry to the mouth, stretch, hips
	local armX = 70 * hold + 18 * chomp - 20 * yawn + 15 * patter - 30 * proud
	local armZ = -12 * hold + 45 * yawn + 30 * choo + 35 * proud
	L.both(pose, "Arm", pa(0, 0.25 * hold, -0.2 * hold, armX, 0, armZ))
	pose.Tail = ang(0, 25 * wave(t, 1), 0)

	-- quills: ripple wave, sneeze bristle
	local function q(lag)
		return ripple * wave(t, 2, -lag) * 0.6 + 1.2 * choo - 0.3 * crouch + 0.5 * proud + 0.06 * breathe
	end
	bristleAll(pose, q(0), q(0.2))

	-- spin-dash show-off (ball), then a flip out of the ball
	if c >= SPIN_B and c < SPIN_LAND then
		local roll = dashRoll(c)
		pose.Body = CFrame.new(-BP) * CFrame.new(0, BC.Y + 5.0 * hop, BC.Z) * CFrame.Angles(rad(-roll), 0, 0) * CFrame.new(-Q)
		L.both(pose, "Arm", pa(0, 0, 0, -30, 0, 70))
		L.both(pose, "Leg", pa(0.3, -0.2, 0, 0, 0, 25))
		pose.Jaw = ang(-35, 0, 0)
		bristleAll(pose, 1.0)
	end
	if k > 0 then
		local roll = dashRoll(c)
		local jitter = 0.12 * rev * wave(t, 13)
		local bt = ballT(roll, jitter, 0.35 * rev, 5.0 * hop + 0.3 * rev)
		pose.Body = pose.Body:Lerp(bt, k)
		curl(pose, k, 0.25 * rev)
		covers(ctx, k)
	end

	-- berry snack prop: appears in front, flicked up, caught, munched
	local showBerry = c > 2.25 and c < 3.32
	ctx.transparency("Berry", showBerry and 0 or 1)
	ctx.transparency("BerryLeaf", showBerry and 0 or 1)
	if showBerry then
		local u = r01(c, 2.9, 3.3)
		local y = 2.0 * u + 4.5 * sin(pi * u)
		local z = 1.2 + 1.8 * u
		pose.Snack = pa(0, y, z, -260 * u, 120 * u, 0)
	else
		pose.Snack = CFrame.new(0, 0, 1.2)
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

	local by = 0.3 * take - 0.35 * crouch + 1.8 * jump - 0.35 * (hitR + hitL) - 0.3 * ready
	local bp = 6 * take - 6 * crouch + 8 * boom * settle + 5 * stompR + 5 * stompL - 6 * ready
	local broll = 1.5 * rumble - 8 * stompR + 8 * stompL
	local stand = pa(0.1 * rumble, by, 0.3 * crouch, bp, 12 * take, broll)
	pose.Body = stand
	legs(pose, bodyAt(stand), {
		R = { 0, 1.3 * stompR + 0.5 * jump, -0.3 * stompR, -15 * stompR },
		L = { 0, 1.3 * stompL + 0.5 * jump, -0.3 * stompL, -15 * stompL },
	})

	local headShake = rage * 10 * wave(t, 7)
	pose.Head = ang(10 * take - 10 * crouch + 12 * boom * settle - 6 * (hitR + hitL) - 6 * ready, 14 * take + headShake, -6 * take)
	pose.Nose = ang(-8 * crouch + 12 * boom, 0, 0)
	pose.Jaw = ang(-14 * take - 60 * boom * settle - 18 * (stompR + stompL) * settle, 0, 0)
	brows(pose, 1.2 * take - 0.4 * crouch, 1.2 * crouch + 1.0 * rage)
	L.both(pose, "Ear", ang(0, 0, -30 * crouch + 25 * boom))
	eyes(pose, -0.2 * take, 0.15 * take)
	lids(ctx, crouch > 0.6)
	anger(ctx, pose, t, c > BOOM)
	-- paws: shock up, fists pump on the stomps
	local armX = 40 * take + 15 * crouch + 60 * boom * settle + 30 * (stompR + stompL) * wave(t, 6)
	local armZ = 20 * take + 50 * boom * settle
	L.both(pose, "Arm", pa(0, 0.2 * boom, 0, armX, 0, armZ))
	pose.Tail = ang(-30 * boom, 30 * wave(t, 8) * rage, 0)

	local b = -0.6 * crouch + 1.25 * boom * settle
	local qv = 0.12 * rage * wave(t, 9)
	bristleAll(pose, b + qv, b + 0.1 * boom * settle - qv)
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
	shock(pose, ctx, c, BOOM + 0.4, 2.9)
	ctx.light("BristleLight", 1.5 * boom * settle)
end

------------------------------------------------------------------------
-- CHASE (0.9 s loop): spiky rolling ball, one revolution per loop
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
	local roll = track(c, { { 0, 0 }, { 0.18, -50, "quadOut" }, { HIT, 720, "quadIn" }, { 0.95, 1080, "quadOut" } })
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

	local stand = pa(0, -0.4 * land - 0.3 * crouchS, 0, 4 * land, 0, 0)
	pose.Body = stand
	legs(pose, bodyAt(stand), nil)
	brows(pose, 0, 1.2)
	pose.Jaw = ang(-20 * land, 0, 0)
	L.both(pose, "Arm", ang(20 * land, 0, 20 * land))
	bristleAll(pose, 0.3 * land)
	if k > 0 then
		pose.Body = stand:Lerp(ballT(roll, 0, z, up + 0.6 * impact), k)
		curl(pose, k, 0.7 * impact)
		covers(ctx, k)
	end
	anger(ctx, pose, t, k < 0.3)
	orbs(pose, t, 1, 120, -1.5 * impact, 0)
	shock(pose, ctx, c, HIT, -0.3)
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
-- CATCH (2.2 s): hop-curl spin, POP open victory, smug gloat
------------------------------------------------------------------------
local POP = 0.6
local function catchS(t, pose, ctx)
	local c = t
	local k = E.cubicOut(r01(c, 0.0, 0.15)) * (1 - E.backOut(r01(c, POP - 0.05, POP + 0.12)))
	local hopB = (c > 0.1 and c < POP) and sin(pi * (c - 0.1) / (POP - 0.1)) or 0
	local roll = 360 * E.quadInOut(r01(c, 0.1, POP))
	local pop = env(c, POP, 0.08, 0.35, 0.35, "backOut", "sineInOut")
	local landP = env(c, POP + 0.08, 0.04, 0.04, 0.25, "quadOut", "backOut")
	local smug = env(c, 0.9, 0.2, 0.75, 0.3, "backOut", "cubicInOut")
	local chuckle = env(c, 1.0, 0.1, 0.6, 0.15) * max(0, wave(t, 5))
	local stomp = env(c, 1.75, 0.05, 0.05, 0.3, "quadOut", "backOut")
	local nod = env(c, 1.8, 0.1, 0.05, 0.25)
	local fan = env(c, POP, 0.15, 1.0, 0.45, "backOut", "sineInOut")

	local stand = pa(0, 0.3 * pop + 0.2 * chuckle - 0.45 * landP - 0.4 * stomp, 0, 5 * pop + 4 * smug - 3 * chuckle, 0, 0)
	pose.Body = stand
	legs(pose, bodyAt(stand), nil)
	-- victory: paws thrown up, then on the hips
	local armX = 20 * pop - 25 * smug
	local armZ = 95 * pop * (1 - smug) + 40 * smug
	L.both(pose, "Arm", pa(0, 0.3 * pop, 0, armX, 0, armZ))
	pose.Head = ang(6 * pop + 4 * smug + 3 * chuckle - 8 * nod, 10 * smug * wave(t, 0.5, 0.1), -4 * smug)
	pose.Jaw = ang(-30 * pop * (1 - smug) - 6 - 14 * chuckle - 10 * nod, 0, 0)
	pose.Nose = ang(10 * smug, 0, 0)
	brows(pose, 0.5 * pop - 0.3 * smug, 0.4 * smug)
	lids(ctx, smug > 0.5)
	L.both(pose, "Ear", ang(0, 0, 15 * pop))
	pose.Tail = ang(0, 35 * wave(t, 3) * fan, 0)
	local function fw(lag)
		return 1.1 * fan + 0.15 * fan * wave(t, 2.5, -lag)
	end
	bristleAll(pose, fw(0), fw(0.2))
	if k > 0 then
		pose.Body = stand:Lerp(ballT(roll, 0, 0, 2.6 * hopB), k)
		curl(pose, k, 0)
		covers(ctx, k)
	end
	orbs(pose, t, 1, 180, 2.0 * fan, 1.0 * fan)
	shock(pose, ctx, c, -9, 0)
	if ctx.crossed(0.12) then ctx.emit("RollDust", 6) end
	if ctx.crossed(POP) then ctx.emit("Sparkle", 18); ctx.emit("QuillBurst", 24); ctx.emit("StompDust", 10) end
	for _, at in { 1.05, 1.25, 1.45 } do
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
	local shockA = env(c, 0.0, 0.1, 0.08, 0.1, "backOut", "quadIn")
	local s1 = env(c, 0.22, 0.1, 0.0, 0.07, "quadOut", "quadIn")
	local s2 = env(c, 0.45, 0.1, 0.0, 0.07, "quadOut", "quadIn")
	local s3 = env(c, 0.68, 0.1, 0.0, 0.07, "quadOut", "quadIn")
	-- tantrum spin as a ball
	local k = E.cubicInOut(r01(c, 0.82, 0.95) * (1 - r01(c, 1.6, 1.72)))
	local spinYaw = 900 * E.quadInOut(r01(c, 0.85, 1.7))
	local hops = (c > 0.95 and c < 1.65) and math.abs(sin(pi * 3 * (c - 0.95) / 0.7)) or 0
	local plop = env(c, 1.72, 0.08, 0.5, 0.4, "quadIn", "sineInOut")
	local sulk = env(c, 1.75, 0.2, 0.45, 0.4)
	local rise = 1 - r01(c, 2.2, 2.6)
	local rage = c < 1.75 and 1 or 0

	local by = 0.25 * shockA - 0.3 * (s1 + s2 + s3) - 0.5 * plop
	local stand = pa(0, by, 0, 4 * (s1 + s3) + 3 * s2 - 3 * plop, 0, -7 * s1 + 7 * s2 - 7 * s3 + 2 * sulk * rise)
	pose.Body = stand
	legs(pose, bodyAt(stand), {
		R = { 0, 1.2 * s1 + 1.2 * s3, 0, -15 * (s1 + s3) },
		L = { 0, 1.2 * s2, 0, -15 * s2 },
	})
	pose.Head = ang(8 * shockA - 5 * (s1 + s2 + s3) - 5 * sulk * rise, 12 * rage * wave(t, 6) - 8 * sulk * rise, 3 * sulk * rise)
	pose.Jaw = ang(-35 * shockA - 35 * (s1 + s2 + s3) + 4 * sulk, 0, 0)
	brows(pose, 1.0 * shockA - 0.3 * sulk, 1.3 * rage + 0.6 * sulk)
	L.both(pose, "Ear", ang(0, 0, -25 * plop * rise))
	eyes(pose, 0.2 * sulk * rise, -0.2 * sulk * rise)
	lids(ctx, (plop > 0.3 and c < 1.95) or (c > 2.15 and c < 2.25))
	anger(ctx, pose, t, c > 0.15 and c < 1.8)
	-- paws: fists pound with the stomps, then crossed in a sulk
	local pound = (s1 + s2 + s3)
	local armX = 50 * shockA + 70 * pound * (wave(t, 4.3) * 0.5 + 0.5) + 40 * sulk * rise
	local armZ = 25 * shockA - 35 * sulk * rise
	L.both(pose, "Arm", pa(-0.3 * sulk * rise, 0.3 * sulk * rise, -0.2 * sulk * rise, armX, 0, armZ))
	pose.Tail = ang(0, 40 * wave(t, 6) * rage, 0)
	local b = 1.1 * (c > 0.2 and 1 or 0) * (1 - plop) * r01(c, 0.15, 0.3) - 0.5 * plop * rise
	bristleAll(pose, b + 0.1 * wave(t, 8), b - 0.1 * wave(t, 8))
	if k > 0 then
		pose.Body = stand:Lerp(ballT(0, 0, 0, 1.2 * hops, spinYaw), k)
		curl(pose, k, 0.3)
		covers(ctx, k)
	end
	orbs(pose, t, 1, 150, -1.0 * plop, 0)
	shock(pose, ctx, c, -9, 0)
	for _, at in { 0.32, 0.55, 0.78 } do
		if ctx.crossed(at) then ctx.emit("StompDust", 10); ctx.emit("Huff", 5) end
	end
	for i = 0, 3 do
		if ctx.crossed(0.95 + 0.233 * i) then ctx.emit("StompDust", 6); ctx.emit("RollLeaves", 3) end
	end
	if ctx.crossed(1.74) then ctx.emit("StompDust", 18) end
	if ctx.crossed(2.0) then ctx.emit("Huff", 10) end
	ctx.light("BristleLight", 0.6 * k)
end

------------------------------------------------------------------------
-- RETURN (1.0 s loop): grumpy two-footed waddle home
------------------------------------------------------------------------
local RET_LEN = 1.0
local STRIDE = 2.0 -- foot slide per stance (studs)
local DUTY = 0.6
local function stepFoot(ph)
	-- ph in [0,1): stance first (foot slides back), then swing (lifted)
	if ph < DUTY then
		local u = ph / DUTY
		return 0, STRIDE * (u - 0.5), 0
	end
	local u = (ph - DUTY) / (1 - DUTY)
	return 0.7 * sin(pi * u), STRIDE * (0.5 - E.sineInOut(u)), -20 * sin(pi * u)
end
local function retWalk(t, pose, ctx)
	local c = t % RET_LEN
	local ph = c / RET_LEN
	local hz = 1 / RET_LEN
	local by = 0.05 + 0.2 * math.abs(wave(t, hz, 0.25))
	local stand = pa(0, by, 0, -3 + 2 * wave(t, 2 * hz, 0.1), 5 * wave(t, hz), 8 * wave(t, hz, 0.05))
	pose.Body = stand
	local function f(p)
		local y, z, pitch = stepFoot(p % 1)
		return { 0, y, z, pitch }
	end
	legs(pose, bodyAt(stand), { R = f(ph), L = f(ph + 0.5) })
	pose.Head = ang(-5 + 3 * wave(t, 2 * hz, 0.15), -8 * wave(t, hz, -0.1), -4 * wave(t, hz, 0.1))
	pose.Jaw = ang(-4 - 10 * max(0, wave(t, 4 * hz)) ^ 2, 0, 0)
	pose.Nose = ang(5 * wave(t, 4 * hz), 0, 0)
	brows(pose, 0, 0.9)
	L.both(pose, "Ear", ang(0, 0, -6 * wave(t, 2 * hz)))
	eyes(pose, 0.15 * wave(t, hz), 0)
	local sw = 25 * wave(t, hz)
	pose.ArmR = ang(-sw, 0, 8)
	pose.ArmL = L.mirror(ang(sw, 0, 8))
	pose.Tail = ang(0, 20 * wave(t, hz), 0)
	local w = 0.1 * wave(t, 2 * hz)
	bristleAll(pose, 0.15 + w, 0.15 - w)
	orbs(pose, t, hz, 360, 0, 0)
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
