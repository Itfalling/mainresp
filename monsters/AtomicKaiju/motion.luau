--!nocheck
-- Atomic Kaiju motion: stompy cartoon idle (waddling march in place, tail
-- wagging, head bobbing, double blinks) then the ATOMIC ROAR:
--   charge   - lean way back, dorsal plates light up tail -> head, squint
--   lunge    - body thrown forward, jaw flung open, beam shoots out of the mouth
--   shake    - head thrashes while the beam fires, tail lashes
--   stomp    - right knee hiked to the chest, then SLAM: squash, shockwave ring,
--              dust + cube burst, floating cubes jolt, tail slams, jaw chomps
-- Legs use a small 2-bone IK so planted feet never slide or sink into the ground.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease

local M = {}
M.Cycle = 8

local sqrt, max, min, abs, clamp = math.sqrt, math.max, math.min, math.abs, math.clamp
local atan2, acos, sin, cos, rad, pi = math.atan2, math.acos, math.sin, math.cos, math.rad, math.pi

------------------------------------------------------------------------
-- Leg IK (rest pivots in model space, right side; left is mirrored)
------------------------------------------------------------------------
local HIP = Vector3.new(0, 7, 2)
local THIGH = Vector3.new(2.8, 7.5, 2.5)
local SHIN = Vector3.new(3.3, 3.9, 2.8)
local FOOT = Vector3.new(3.3, 1.0, 2.6)
local SEG1, SEG2 = SHIN - THIGH, FOOT - SHIN
local L1 = sqrt(SEG1.Y ^ 2 + SEG1.Z ^ 2)
local L2 = sqrt(SEG2.Y ^ 2 + SEG2.Z ^ 2)
local A1 = atan2(SEG1.Z, SEG1.Y)
local A2 = atan2(SEG2.Z, SEG2.Y)
local REST_X = FOOT.X - THIGH.X
local REST_DOWN = THIGH.Y - FOOT.Y
local REACH = (L1 + L2) * 0.985 -- keep a hint of knee bend (no snapping)

local function sideV(p, s)
	return Vector3.new(p.X * s, p.Y, p.Z)
end

local function wrap(a)
	return (a + pi) % (2 * pi) - pi
end

-- how far the hips must drop so a foot at `target` stays reachable
local function reachDrop(hipsW, s, target)
	local th = (hipsW * CFrame.new(sideV(THIGH, s) - HIP)).Position
	local d = target - th
	local h2 = d.X ^ 2 + d.Z ^ 2
	local maxDown = sqrt(max(0, REACH * REACH + REST_X * REST_X - h2))
	return max(0, -d.Y - maxDown)
end

-- returns Thigh, Shin, Foot transforms putting the foot pivot at `target`
-- (model space) with world rotation `footRot`
local function legIK(hipsW, s, target, footRot)
	local frame = hipsW * CFrame.new(sideV(THIGH, s) - HIP)
	local q = frame:PointToObjectSpace(target)
	local gamma = atan2(q.X, -q.Y) - atan2(REST_X * s, REST_DOWN)
	local rz = CFrame.Angles(0, 0, gamma)
	local q2 = rz:PointToObjectSpace(q)
	local D = clamp(sqrt(q2.Y ^ 2 + q2.Z ^ 2), abs(L1 - L2) + 0.05, L1 + L2 - 1e-4)
	local delta = -acos(clamp((D * D - L1 * L1 - L2 * L2) / (2 * L1 * L2), -1, 1))
	local phi = atan2(q2.Z, q2.Y)
	local s1 = phi - atan2(L2 * sin(delta), L1 + L2 * cos(delta))
	local th1 = wrap(s1 - A1)
	local th2 = wrap(delta - (A2 - A1))
	local thighT = rz * CFrame.Angles(th1, 0, 0)
	local shinT = CFrame.Angles(th2, 0, 0)
	local footT = (hipsW.Rotation * thighT * shinT):Inverse() * footRot
	return thighT, shinT, footT
end

------------------------------------------------------------------------
-- Tail forward kinematics (to keep the tail slam above the floor)
------------------------------------------------------------------------
local TAIL_BONES = { "Tail1", "Tail2", "Tail3", "Tail4", "Tail5", "TailTip" }
local TAIL_PIV = {
	Vector3.new(0, 7.0, 4.6), Vector3.new(0, 6.4, 8.2), Vector3.new(0, 5.4, 11.8),
	Vector3.new(0, 4.4, 15.4), Vector3.new(0, 3.5, 18.8), Vector3.new(0, 3.2, 22),
}
-- lowest underside points carried by each tail bone (model rest space)
local TAIL_LOW = {
	[3] = { Vector3.new(0, 3.3, 15.8) },
	[4] = { Vector3.new(0, 2.6, 19.2) },
	[5] = { Vector3.new(0, 2.0, 22.4) },
	[6] = { Vector3.new(0, 1.9, 23.5), Vector3.new(0, 2.7, 25.5) },
}
local TAIL_FLOOR = 0.15

local function tailLowest(hipsW, pitch, yaw)
	local w, prevP = hipsW, HIP
	local low, dist = math.huge, 1
	local base
	for i = 1, 6 do
		w = w * CFrame.new(TAIL_PIV[i] - prevP) * CFrame.Angles(rad(pitch[i]), rad(yaw[i]), 0)
		prevP = TAIL_PIV[i]
		if i == 1 then
			base = w.Position
		end
		for _, p in TAIL_LOW[i] or {} do
			local q = w * (p - prevP)
			if q.Y < low then
				low = q.Y
				dist = Vector3.new(q.X - base.X, 0, q.Z - base.Z).Magnitude
			end
		end
	end
	return low, dist
end

------------------------------------------------------------------------
-- timings (seconds inside the 8 s loop)
------------------------------------------------------------------------
local BEAM_ON = { 3.76, 3.80, 3.84 }
local BEAM_OFF = { 5.10, 5.15, 5.20 }
local IMPACT = 6.25
local ORB_DIR = { 1, -1, 1, -1 }
local SHOCK_N = 12

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	--------------------------------------------------------------------
	-- envelopes
	--------------------------------------------------------------------
	local windup = L.env(c, 2.7, 0.7, 0.12, 0.2, "cubicOut", "quadOut") -- lean back + charge
	local roar = L.env(c, 3.5, 0.22, 1.45, 0.45, "backOut", "cubicInOut") -- lunge, jaw open, beam
	local shake = L.env(c, 3.75, 0.15, 1.25, 0.3)
	local stompUp = L.env(c, 5.5, 0.45, 0.12, 0.18, "backOut", "cubicIn") -- knee to the chest
	local squash = L.env(c, IMPACT, 0.04, 0.08, 0.55, "quadOut", "backOut") -- body squash, springs back
	local impact = L.env(c, IMPACT, 0.03, 0.05, 0.95, "linear", "elasticOut") -- jiggly secondary
	local busy = L.env(c, 2.55, 0.3, 3.75, 0.9) -- fades the idle out/in
	local idleW = 1 - busy
	local charge = L.env(c, 2.85, 0.9, 1.45, 0.35) -- light/glow ramp

	--------------------------------------------------------------------
	-- idle march rhythm
	--------------------------------------------------------------------
	local step = wave(t, 0.75)
	local liftR = max(0, step) ^ 1.5 * idleW
	local liftL = max(0, -step) ^ 1.5 * idleW
	local bounce = L.bounce(t, 1.5)
	local breathe = wave(t, 0.5)
	local waddle = wave(t, 0.75, -0.06) -- lags the steps a touch

	--------------------------------------------------------------------
	-- HIPS: bounce, penguin waddle, crouch for the charge, lunge, stomp squash
	--------------------------------------------------------------------
	local hipX = -0.45 * step * idleW - 1.0 * stompUp
	local hipY = (0.9 * bounce - 0.45) * idleW - 1.1 * windup - 1.0 * roar - 1.8 * squash + 0.3 * stompUp
	local hipZ = 1.0 * windup - 1.8 * roar
	local hipP = 6 * windup - 6 * roar - 3 * squash
	local hipYaw = 6 * step * idleW - 8 * stompUp
	local hipRoll = 8 * waddle * idleW + 16 * stompUp - 3 * impact
	local hipsW = CFrame.new(HIP) * pa(hipX, hipY, hipZ, hipP, hipYaw, hipRoll)

	-- foot targets (model space): planted at rest, lifted for steps; the stomp
	-- is a sumo-style lift out to the side so it reads from every angle
	local footR = FOOT + Vector3.new(2.4 * stompUp, 2.0 * liftR + 6.6 * stompUp, -0.7 * liftR - 1.5 * stompUp)
	local footL = sideV(FOOT, -1) + Vector3.new(0, 2.0 * liftL, -0.7 * liftL)
	-- lower the hips if a foot could not reach its target (no floating feet)
	local drop = max(reachDrop(hipsW, 1, footR), reachDrop(hipsW, -1, footL))
	if drop > 0 then
		hipY -= drop
		hipsW = CFrame.new(HIP) * pa(hipX, hipY, hipZ, hipP, hipYaw, hipRoll)
	end
	pose.Hips = pa(hipX, hipY, hipZ, hipP, hipYaw, hipRoll)

	--------------------------------------------------------------------
	-- LEGS (IK): toes point down while a foot is in the air
	--------------------------------------------------------------------
	local tR, sR, fR = legIK(hipsW, 1, footR, ang(-14 * liftR - 22 * stompUp, 0, -10 * stompUp))
	local tL, sL, fL = legIK(hipsW, -1, footL, ang(-14 * liftL, 0, 0))
	pose.ThighR, pose.ShinR, pose.FootR = tR, sR, fR
	pose.ThighL, pose.ShinL, pose.FootL = tL, sL, fL

	--------------------------------------------------------------------
	-- CHEST: breathing, big lean back then lunge, rumble, stomp balance
	--------------------------------------------------------------------
	local rumble = 2.5 * shake * wave(t, 9)
	pose.Chest = ang(
		3 * breathe + 24 * windup - 20 * roar + 12 * stompUp - 8 * impact + rumble,
		-4 * step * idleW + 6 * stompUp,
		-5 * waddle * idleW - 8 * stompUp
	)

	--------------------------------------------------------------------
	-- NECK / HEAD: bobbing + looking around, thrown back on the wind-up,
	-- level and thrusting on the roar, thrashing, nodding at the foot
	--------------------------------------------------------------------
	local look = L.noise(t, 4.2, 0.35) * 25 * idleW
	local shakeYaw = 14 * shake * wave(t, 5.5)
	pose.Neck = ang(-7 * bounce * idleW + 10 * windup - 8 * roar - 8 * stompUp - 4 * impact, look * 0.4, 0)
	local headRoll = -6 * wave(t, 0.75, -0.16) * idleW + 6 * L.noise(t, 9.1, 0.4) * idleW + 5 * shake * wave(t, 3)
	pose.Head = ang(
		4 * breathe + 12 * windup + 34 * roar - 16 * stompUp - 10 * impact,
		look * 0.6 + shakeYaw,
		headRoll
	)

	-- JAW: always a little open (teeth + tongue read), parted on the charge so
	-- the glowing throat shows, flung WIDE on the roar, chomp on the stomp
	local chomp = max(0, wave(t, 0.4, 0.3)) ^ 8 * idleW
	pose.Jaw = ang(-10 - 16 * chomp - 8 * windup - 64 * roar + 6 * shake * wave(t, 11) - 25 * impact, 0, 0)

	-- EYELIDS: double blink + angry squint while charging
	local bl = max(L.env(t % 4.1, 3.5, 0.06, 0.05, 0.08), L.env(t % 4.1, 3.75, 0.06, 0.05, 0.08))
	local close = max(bl * (1 - roar), 0.5 * windup)
	L.both(pose, "Lid", CFrame.new(0, 1.35 * (1 - close), 0))
	local lidTr = close > 0.2 and 0 or 1
	ctx.transparency("EyelidR", lidTr)
	ctx.transparency("EyelidL", lidTr)

	--------------------------------------------------------------------
	-- ARMS: dangly swing, thrown back on the charge, spread on the roar,
	-- flung up for balance on the stomp, flop on impact
	--------------------------------------------------------------------
	local swing = 16 * step * idleW
	local armX = -35 * windup + 10 * roar - 30 * stompUp + 25 * impact
	local armZ = 10 + 45 * windup + 40 * roar + 50 * stompUp - 10 * impact
	local armR = ang(swing + armX, 0, armZ + 10 * shake * wave(t, 6))
	local armL = ang(-swing + armX, 0, armZ + 10 * shake * wave(t, 6, 0.5))
	L.both(pose, "Arm", armR, armL)
	local foreBase = -25 - 40 * windup + 25 * roar - 30 * stompUp + 20 * impact
	L.both(pose, "Forearm",
		ang(foreBase + 12 * wave(t, 0.75, 0.2) * idleW, 0, 0),
		ang(foreBase - 12 * wave(t, 0.75, 0.2) * idleW, 0, 0))

	--------------------------------------------------------------------
	-- TAIL: happy wag with lag, curls up on the charge, lashes on the roar,
	-- lifts for the stomp and slams down with a ripple
	--------------------------------------------------------------------
	local wagAmp = 11 + 10 * shake
	local wagHz = 0.75 + 1.6 * shake
	local pitch, yaw = {}, {}
	for i = 1, 5 do
		local lag = wave(t, wagHz, -0.09 * i)
		local hit = L.env(c, IMPACT + 0.06 * (i - 1), 0.04, 0.03, 0.6, "quadOut", "elasticOut")
		pitch[i] = -1.5 - (i == 1 and 7 or 2.5) * windup - 3 * roar - (i == 1 and 12 or 1) * stompUp
			+ (i == 1 and 9 or 3) * hit + 1.5 * breathe
		yaw[i] = wagAmp * lag * (0.6 + i * 0.12)
	end
	pitch[6], yaw[6] = 0, 22 * wave(t, wagHz, -0.55)
	-- ground clamp: the slam lands flat ON the floor, never through it
	for _ = 1, 2 do
		local low, dist = tailLowest(hipsW, pitch, yaw)
		if low >= TAIL_FLOOR then
			break
		end
		pitch[1] -= math.deg(math.asin(clamp((TAIL_FLOOR - low) / max(dist, 1), 0, 1))) + 0.2
	end
	for i = 1, 6 do
		pose[TAIL_BONES[i]] = ang(pitch[i], yaw[i], 0)
	end

	--------------------------------------------------------------------
	-- FLOATING CUBES: drift on the flanks (never cross the body), bob +
	-- tumble, rise with the charge, pushed out by the roar, jolt on the stomp
	--------------------------------------------------------------------
	pose.Orbit = ang(0, 20 * wave(t, 0.07), 0)
	local jolt = L.env(c, IMPACT, 0.05, 0, 0.9, "quadOut", "elasticOut")
	for i = 1, 4 do
		local dir = ORB_DIR[i]
		local bob = 1.2 * wave(t, 0.45, i * 0.27)
		local y = bob + 1.0 * windup - 1.5 * jolt
		pose["Orb" .. i] = pa(1.6 * roar * dir, y, 0, (90 + 10 * i) * t * dir, 120 * t, 0)
	end

	--------------------------------------------------------------------
	-- EFFECTS
	--------------------------------------------------------------------
	-- charge: dorsal plates light up one by one from tail tip to head
	for k = 1, 10 do
		local on = c > 2.9 + 0.065 * k and c < 5.35
		ctx.transparency("Charge" .. k, on and (0.15 + 0.1 * wave(t, 6, k * 0.1)) or 1)
	end
	-- rising motes while charging (timed bursts so every client matches)
	for k = 0, 8 do
		if ctx.crossed(2.9 + k * 0.1) then
			ctx.emit("ChargeMotes", 3)
		end
	end
	ctx.transparency("ThroatGlow", (c > 3.2 and c < 5.3) and 0.2 or 1)
	ctx.light("MouthLight", 1.2 * charge)

	-- beam: shoots out segment by segment, flickers, leaves the mouth at the end
	local flick = 0.5 + 0.5 * wave(t, 14)
	for i = 1, 3 do
		local on = c > BEAM_ON[i] and c < BEAM_OFF[i]
		ctx.transparency("Beam" .. i, on and (0.1 + 0.15 * flick) or 1)
		ctx.transparency("BeamGlow" .. i, on and (0.62 + 0.1 * wave(t, 9, i * 0.2)) or 1)
	end
	for k = 0, 13 do
		if ctx.crossed(BEAM_ON[1] + 0.02 + k * 0.1) then
			ctx.emit("RoarSparks", 4)
			ctx.emit("BeamSpray", 5)
		end
	end
	if ctx.crossed(3.6) then
		ctx.emit("AuraSparkle", 14)
	end
	if ctx.crossed(BEAM_ON[1]) then
		ctx.emit("RoarBurst", 45)
	end

	-- stomp: dust + cube burst + expanding shockwave ring
	if ctx.crossed(IMPACT) then
		ctx.emit("StompDust", 30)
		ctx.emit("StompCubes", 18)
	end
	local sw = L.remap(c, IMPACT, IMPACT + 0.45)
	local swOn = c > IMPACT and c < IMPACT + 0.45
	local r = 5.0 * E.quadOut(sw)
	for k = 1, SHOCK_N do
		local a = (k - 1) / SHOCK_N * 2 * pi
		pose["Shock" .. k] = CFrame.new(-sin(a) * r, 0.25 * (1 - sw), -cos(a) * r)
		ctx.transparency("Wave" .. k, swOn and (0.1 + 0.85 * sw * sw) or 1)
	end
end

return M
