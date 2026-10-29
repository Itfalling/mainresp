--!nocheck
-- Briar Rex motion: a prideful tyrant king who is secretly insecure about his
-- tiny arms. Every state drives one shared rig (legs by 2-bone IK so planted
-- feet never slide or sink, tail with a ground clamp).
--   Idle   (12 s) menacing breathing, sniffing, a heavy pacing stomp with a
--          tail sweep, the TINY-ARMS GAG (tries to scratch its head, can't,
--          sweats, looks around, puffs up proudly) and the show-off ROYAL
--          ROAR: knee hiked -> SLAM (shock ring) -> giant roar + petal storm.
--   Alert  shock jolt -> two furious stomps -> rear back -> HUGE ROAR, petals
--          explode, shock ring -> leans forward ready to run.
--   Chase  thundering run: body levelled, head forward, tail counter-swing,
--          squash + dust on every footfall, tiny arms pumping.
--   Attack rear back, jaw wide -> lunging CHOMP (impact lines) -> head shake.
--   Catch  smug look down -> triumphant roar to the sky, tiny arms raised.
--   GiveUp 4 tantrum stomps with flailing tiny arms -> big deflating sigh.
--   Return heavy grumpy stomp walk home.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E, env = L.ang, L.pa, L.wave, L.ease, L.env

local sqrt, max, min, abs, clamp = math.sqrt, math.max, math.min, math.abs, math.clamp
local atan2, acos, sin, cos, rad, pi = math.atan2, math.acos, math.sin, math.cos, math.rad, math.pi

------------------------------------------------------------------------
-- Leg IK (rest pivots in model space, right side; left is mirrored)
------------------------------------------------------------------------
local HIP = Vector3.new(0, 10.5, 2.5)
local THIGH = Vector3.new(3.6, 10.5, 3.0)
local SHIN = Vector3.new(4.3, 6.0, 1.5)
local FOOT = Vector3.new(4.3, 2.0, 4.0)
local SEG1, SEG2 = SHIN - THIGH, FOOT - SHIN
local L1 = sqrt(SEG1.Y ^ 2 + SEG1.Z ^ 2)
local L2 = sqrt(SEG2.Y ^ 2 + SEG2.Z ^ 2)
local A1 = atan2(SEG1.Z, SEG1.Y)
local A2 = atan2(SEG2.Z, SEG2.Y)
local REST_X = FOOT.X - THIGH.X
local REST_DOWN = THIGH.Y - FOOT.Y
local REACH = (L1 + L2) * 0.985

local function sideV(p, s)
	return Vector3.new(p.X * s, p.Y, p.Z)
end

local function wrap(a)
	return (a + pi) % (2 * pi) - pi
end

local function reachDrop(hipsW, s, target)
	local th = (hipsW * CFrame.new(sideV(THIGH, s) - HIP)).Position
	local d = target - th
	local h2 = d.X ^ 2 + d.Z ^ 2
	local maxDown = sqrt(max(0, REACH * REACH + REST_X * REST_X - h2))
	return max(0, -d.Y - maxDown)
end

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
-- Tail FK (ground clamp for slams)
------------------------------------------------------------------------
local TAIL_BONES = { "Tail1", "Tail2", "Tail3", "Tail4", "Tail5", "TailTip" }
local TAIL_PIV = {
	Vector3.new(0, 10.2, 6.0), Vector3.new(0, 8.9, 8.6), Vector3.new(0, 7.6, 11.0),
	Vector3.new(0, 6.5, 13.2), Vector3.new(0, 5.6, 15.2), Vector3.new(0, 5.0, 17.0),
}
local TAIL_LOW = {
	[3] = { Vector3.new(0, 5.1, 12.3) },
	[4] = { Vector3.new(0, 4.5, 14.4) },
	[5] = { Vector3.new(0, 4.1, 16.3) },
	[6] = { Vector3.new(0, 3.5, 18.4), Vector3.new(0, 4.2, 20.9), Vector3.new(0, 3.7, 20.6) },
}
local TAIL_FLOOR = 0.3

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
-- shared rig: every state fills a parameter table (unset fields read 0)
------------------------------------------------------------------------
local ZERO = { __index = function() return 0 end }
local function S()
	return setmetatable({}, ZERO)
end

local ORB_DIR = { 1, -1, 1, -1 }

local function rig(pose, ctx, s)
	-- HIPS + legs
	local hx, hy, hz, hp, hyw, hr = s.hx, s.hy, s.hz, s.hp, s.hyaw, s.hroll
	local hipsW = CFrame.new(HIP) * pa(hx, hy, hz, hp, hyw, hr)
	local fR = FOOT + Vector3.new(s.fRx, s.fRy, s.fRz)
	local fL = sideV(FOOT, -1) + Vector3.new(s.fLx, s.fLy, s.fLz)
	local drop = max(reachDrop(hipsW, 1, fR), reachDrop(hipsW, -1, fL))
	if drop > 0 then
		hy -= drop
		hipsW = CFrame.new(HIP) * pa(hx, hy, hz, hp, hyw, hr)
	end
	pose.Hips = pa(hx, hy, hz, hp, hyw, hr)
	local tR, sR, ftR = legIK(hipsW, 1, fR, ang(s.toeR, s.footYawR, 0))
	local tL, sL, ftL = legIK(hipsW, -1, fL, ang(s.toeL, -s.footYawL, 0))
	pose.ThighR, pose.ShinR, pose.FootR = tR, sR, ftR
	pose.ThighL, pose.ShinL, pose.FootL = tL, sL, ftL

	-- spine + head
	pose.Chest = ang(s.cx, s.cy, s.cz)
	pose.Neck = ang(s.nx, s.ny, s.nz)
	pose.Head = ang(s.hdx, s.hdy, s.hdz)
	local jaw = 7 + s.jaw
	pose.Jaw = ang(-jaw, s.jawY, 0)
	pose.Beard = ang(-0.25 * jaw + s.beard, 0, s.beardZ)

	-- brows: + = angry (inner end down), browUp raises them (shock)
	local brow = 3 + 0.5 * s.brow
	L.both(pose, "Brow", pa(0, s.browUp, -0.15 * s.browUp, 0, 0, brow))
	-- lids: 0 open .. 1 closed (lid blocks are props, shown only while closing)
	local lid = clamp(s.lid, 0, 1)
	L.both(pose, "Lid", CFrame.new(0, 1.3 * (1 - lid), 0))
	if lid > 0.12 then
		ctx.transparency("EyelidR", 0)
		ctx.transparency("EyelidL", 0)
	end

	-- tiny arms (hang forward-down; +X swings them forward/up, +Z flares out)
	L.both(pose, "Arm", ang(15 + s.aRx, s.aRy, 8 + s.aRz), ang(15 + s.aLx, s.aLy, 8 + s.aLz))
	L.both(pose, "Forearm", ang(-25 + s.foRx, 0, s.foRz), ang(-25 + s.foLx, 0, s.foLz))

	-- tail (−X lifts it, +Y swings toward the left)
	local pitch, yaw = {}, {}
	for i = 1, 5 do
		pitch[i] = (i == 1 and s.tp1 or s.tpn) + (i >= 4 and s.tpTip or 0)
		local lag = sin(2 * pi * (s.tw - 0.09 * i))
		yaw[i] = s.tyo * (0.5 + 0.1 * i) + s.ty * lag * (0.55 + 0.13 * i)
	end
	pitch[6] = s.tpTip
	yaw[6] = s.ty * 1.6 * sin(2 * pi * (s.tw - 0.6)) + s.tyo * 0.8
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

	-- springy rose on the head + the big front back-spike (follow-through)
	local ot = s.ot
	pose.HeadRose = ang(6 * sin(2 * pi * ot * 1.5) - 0.2 * s.hdx, 0, 10 * sin(2 * pi * ot * 1.5 + 0.7) - 0.4 * s.hdy)
	pose.BackSpike = ang(-0.4 * s.cx + 4 * sin(2 * pi * ot), 0, 5 * sin(2 * pi * ot + 0.5) - 0.3 * s.cy)

	-- floating hedge cubes
	pose.Orbit = ang(0, 18 * sin(2 * pi * ot / 24), 0)
	for i = 1, 4 do
		local d = ORB_DIR[i]
		local bob = 1.1 * sin(2 * pi * (ot / 2 + i * 0.27))
		pose["Orb" .. i] = pa(1.8 * s.oPush * d, bob + 1.2 * s.oUp - 1.6 * s.oJolt, 0, (60 + 10 * i) * ot * d, 90 * ot, 0)
	end
end

-- expanding bark shock ring (props) for a slam that happened at t0
local SHOCK_N = 12
local function shock(pose, ctx, c, t0, R)
	local sw = L.remap(c, t0, t0 + 0.5)
	local on = c > t0 and c < t0 + 0.5
	local r = R * E.quadOut(sw)
	for k = 1, SHOCK_N do
		local a = (k - 1) / SHOCK_N * 2 * pi
		pose["Shock" .. k] = CFrame.new(-sin(a) * r, 0.3 * (1 - sw), -cos(a) * r)
		if on then
			local tr = 0.05 + 0.9 * sw * sw
			ctx.transparency("Wave" .. k, tr)
			ctx.transparency("WaveTop" .. k, tr)
		end
	end
end

local function showAngry(ctx)
	for k = 1, 4 do
		ctx.transparency("AngryMark" .. k, 0)
	end
end

local function snapLines(ctx, on)
	if on then
		for k = 1, 6 do
			ctx.transparency("SnapLine" .. k, 0.15)
		end
	end
end

-- foot lift pulse ending in a stomp at `at` (0 -> 1 -> 0)
local function lift(c, at, up, down)
	return env(c, at - up - 0.05, up, 0.05, down or 0.06, "cubicOut", "cubicIn")
end

-- run/walk gait: phase 0..1 -> foot z offset, lift, toe pitch (stance first half)
local function gait(ph, S_, H, zc)
	if ph < 0.5 then
		local u = ph / 0.5
		return zc - S_ / 2 + S_ * u, 0, 0
	end
	local u = (ph - 0.5) / 0.5
	local z = zc + S_ / 2 - S_ * E.sineInOut(u)
	local y = H * sin(pi * u)
	-- toes hang down after lift-off (never deeper than the lift: the toe tip is
	-- ~7 studs ahead of the ankle pivot), then level / tip up for the heel strike
	local down = math.deg(math.asin(clamp(0.8 * y / 7.2, 0, 0.45)))
	return z, y, -down * clamp((1 - u) / 0.5, 0, 1) + 8 * max(0, u - 0.6) / 0.4 * (1 - u) / 0.4
end

------------------------------------------------------------------------
-- IDLE (12 s loop)
------------------------------------------------------------------------
local IDLE = 12
local PACE_R, PACE_L = 3.45, 4.25
local SLAM = 8.85

local function idle(t, pose, ctx)
	local c = t % IDLE
	local s = S()
	local breathe = wave(t, 0.5)
	local look = 12 * wave(t, 1 / 12) + 6 * wave(t, 3 / 12, 0.3)

	-- beats
	local sniff = env(c, 0.9, 0.3, 0.9, 0.35)
	local twitch = max(0, wave(t, 4)) ^ 2 * sniff
	local pace = env(c, 2.9, 0.3, 1.5, 0.5)
	local liftR = lift(c, PACE_R, 0.28, 0.07)
	local liftL = lift(c, PACE_L, 0.28, 0.07)
	local sweep = env(c, 2.7, 0.5, 1.6, 0.7)
	local gag = env(c, 5.0, 0.45, 1.6, 0.35, "backOut", "cubicInOut") -- arms reaching
	local strain = env(c, 5.5, 0.3, 1.0, 0.3)
	local sweat = c > 5.9 and c < 7.5
	local busted = env(c, 6.85, 0.12, 0.35, 0.15)
	local lookL = env(c, 6.85, 0.1, 0.1, 0.1, "backOut", "quadInOut")
	local lookR = env(c, 7.1, 0.1, 0.1, 0.12, "backOut", "quadInOut")
	local proud = env(c, 7.3, 0.35, 0.5, 0.4, "backOut", "cubicInOut")
	local stompUp = env(c, 8.2, 0.55, 0.05, 0.05, "backOut", "cubicIn")
	local wind = env(c, 8.2, 0.6, 0.1, 0.25, "cubicOut", "quadOut")
	local squash = env(c, SLAM, 0.04, 0.08, 0.5, "quadOut", "backOut")
	local roar = env(c, 9.05, 0.18, 1.35, 0.55, "backOut", "cubicInOut")
	local shake = env(c, 9.2, 0.15, 1.1, 0.3)
	local busy = env(c, 4.9, 0.3, 6.2, 0.5)
	local calm = 1 - busy

	-- hips
	s.hx = 0.5 * liftL - 0.5 * liftR - 1.0 * stompUp + 0.3 * wave(t, 0.25) * calm
	s.hy = 0.25 * breathe - 0.5 * (liftR + liftL) * 0.5 - 0.9 * wind - 1.7 * squash - 0.6 * roar + 0.4 * proud - 0.5 * gag
	s.hz = 0.8 * wind - 1.4 * roar
	s.hp = 7 * wind - 4 * roar - 3 * squash + 4 * proud + 2 * strain
	s.hyaw = 5 * liftR - 5 * liftL - 6 * stompUp
	s.hroll = -4 * liftR + 4 * liftL + 10 * stompUp + 2 * wave(t, 0.25) * calm
	-- feet
	s.fRy = 1.6 * liftR + 6.0 * stompUp
	s.fRz = -0.6 * liftR - 1.2 * stompUp
	s.fRx = 1.5 * stompUp
	s.toeR = -10 * liftR - 20 * stompUp
	s.fLy = 1.6 * liftL
	s.fLz = -0.6 * liftL
	s.toeL = -10 * liftL

	-- chest / neck / head
	s.cx = 3 * breathe + 8 * wind - 2 * roar + 10 * proud - 6 * squash + 4 * strain
	s.cy = -3 * liftR + 3 * liftL + 0.3 * look * calm
	s.cz = -4 * stompUp
	s.nx = -2 * breathe + 6 * sniff + 12 * wind + 2 * roar + 12 * gag - 6 * squash + 6 * proud
	s.ny = 0.4 * look * calm - 4 * gag
	local headShake = 9 * shake * wave(t, 6)
	s.hdx = 2 * breathe + 8 * sniff + 5 * twitch + 18 * wind + 30 * roar + 16 * gag - 5 * strain - 8 * squash + 12 * proud
	s.hdy = 0.6 * look * calm + headShake + 32 * lookL - 32 * lookR - 8 * gag
	s.hdz = -5 * gag + 4 * shake * wave(t, 3) - 6 * proud
	s.jaw = 3 * twitch + 18 * wind + 60 * roar + 6 * shake * wave(t, 11) - 7 * squash + 4 * max(0, breathe) * calm
	s.beardZ = 10 * wave(t, 0.5, 0.2) + 14 * shake * wave(t, 6, 0.2)

	-- face
	s.brow = 6 * sniff + 8 * wind + 10 * roar - 18 * gag * (sweat and 1 or 0.5) + 4 * proud
	s.browUp = 0.4 * busted + 0.2 * gag
	local blink = max(env(c, 3.0, 0.05, 0.04, 0.07), env(c, 11.6, 0.05, 0.04, 0.07), env(c, 7.6, 0.05, 0.04, 0.07))
	s.lid = max(blink, 0.45 * wind * (1 - roar), 0.35 * proud)
	if sweat then
		ctx.transparency("SweatDrop1", 0)
		ctx.transparency("SweatDrop2", 0)
	end

	-- tiny arms: idle fidget, the scratch attempt (reach + frantic flail, never
	-- getting there), hide behind back when busted, flung up on the roar
	local flail = 22 * strain * wave(t, 6)
	s.aRx = 6 * breathe + 95 * gag + flail - 40 * busted + 30 * roar - 25 * wind
	s.aLx = 6 * breathe + 95 * gag - flail - 40 * busted + 30 * roar - 25 * wind
	s.aRz = 30 * gag + 0.6 * flail + 35 * roar + 20 * wind
	s.aLz = 30 * gag - 0.6 * flail + 35 * roar + 20 * wind
	s.foRx = 30 * gag + 25 * strain * wave(t, 6, 0.25) + 40 * roar - 20 * busted
	s.foLx = 30 * gag - 25 * strain * wave(t, 6, 0.25) + 40 * roar - 20 * busted
	s.foRz = 10 * roar * wave(t, 8)
	s.foLz = -10 * roar * wave(t, 8)

	-- tail
	local wagAmp = 7 + 16 * sweep + 14 * shake
	s.tw = t * 0.5 + shake * 0
	s.ty = wagAmp
	s.tyo = 6 * stompUp
	s.tp1 = -2 + 1.5 * breathe - 6 * wind + 9 * squash - 4 * roar - 4 * proud
	s.tpn = -0.5 + 2 * squash
	s.tpTip = -6 * roar

	-- cubes
	s.ot = t
	s.oUp = 0.8 * wind
	s.oPush = roar
	s.oJolt = env(c, SLAM, 0.05, 0, 0.9, "quadOut", "elasticOut")

	rig(pose, ctx, s)

	-- effects
	if ctx.crossed(PACE_R) then
		ctx.emit("DustR", 8)
	end
	if ctx.crossed(PACE_L) then
		ctx.emit("DustL", 8)
	end
	if ctx.crossed(1.2) or ctx.crossed(1.7) then
		ctx.emit("AuraSparkle", 3)
	end
	if ctx.crossed(SLAM) then
		ctx.emit("DustR", 24)
		ctx.emit("StompCubes", 18)
	end
	shock(pose, ctx, c, SLAM, 9)
	if ctx.crossed(9.1) then
		ctx.emit("RoarBurst", 40)
		ctx.emit("PetalBurst", 70)
	end
	for k = 0, 9 do
		if ctx.crossed(9.15 + k * 0.12) then
			ctx.emit("MouthPetals", 6)
		end
	end
	ctx.light("MouthLight", 1.4 * roar)
end

------------------------------------------------------------------------
-- ALERT (2.2 s): MY ROSE GOT STOLEN!
------------------------------------------------------------------------
local AL_R, AL_L, AL_ROAR = 0.62, 0.95, 1.28

local function alert(t, pose, ctx)
	local s = S()
	local jolt = env(t, 0, 0.1, 0.12, 0.25, "backOut", "quadInOut")
	local liftR = lift(t, AL_R, 0.2, 0.05)
	local liftL = lift(t, AL_L, 0.2, 0.05)
	local sqR = env(t, AL_R, 0.03, 0.04, 0.2, "quadOut", "backOut")
	local sqL = env(t, AL_L, 0.03, 0.04, 0.2, "quadOut", "backOut")
	local rear = env(t, 1.0, 0.26, 0.02, 0.12, "cubicOut", "quadIn")
	local roar = env(t, AL_ROAR - 0.05, 0.14, 0.45, 0.35, "backOut", "cubicInOut")
	local shake = env(t, AL_ROAR, 0.1, 0.45, 0.25)
	local angry = env(t, 0.3, 0.1, 1.6, 0.2)
	local ready = env(t, 1.7, 0.3, 0.2, 0.0) -- ends leaning into the run

	s.hy = 0.6 * jolt - 0.9 * (sqR + sqL) - 0.8 * rear - 0.7 * roar - 0.3 * ready
	s.hz = 0.8 * rear - 1.2 * roar
	s.hp = 4 * jolt + 9 * rear - 5 * roar - 3 * (sqR + sqL) - 4 * ready
	s.hyaw = 6 * liftR - 6 * liftL
	s.hroll = -5 * liftR + 5 * liftL + 3 * sqR - 3 * sqL
	s.hx = -0.6 * liftR + 0.6 * liftL
	s.fRy, s.fRz, s.toeR = 2.6 * liftR, -0.6 * liftR, -15 * liftR
	s.fLy, s.fLz, s.toeL = 2.6 * liftL, -0.6 * liftL, -15 * liftL

	s.cx = 10 * jolt + 14 * rear - 2 * roar - 5 * (sqR + sqL)
	s.cz = -4 * liftR + 4 * liftL
	s.nx = 12 * jolt + 10 * rear - 8 * (sqR + sqL) * angry - 4 * ready
	local headShake = 12 * shake * wave(t, 7)
	s.hdx = 22 * jolt + 22 * rear + 30 * roar - 10 * (sqR + sqL) + 4 * ready
	s.hdy = headShake + 10 * wave(t, 3) * angry * (1 - roar)
	s.hdz = 5 * shake * wave(t, 3.5)
	s.jaw = 22 * jolt + 25 * rear + 64 * roar + 8 * shake * wave(t, 12) + 10 * (sqR + sqL) * angry
	s.beardZ = 16 * shake * wave(t, 7, 0.2) + 8 * wave(t, 3)

	s.brow = -14 * jolt + 22 * angry
	s.browUp = 0.7 * jolt
	s.lid = 0.4 * rear * (1 - roar)

	-- tiny arms: thrown up in shock, shaking with fury, flung out on the roar
	s.aRx = 70 * jolt + 30 * angry * (1 - roar) + 40 * roar + 15 * angry * wave(t, 9)
	s.aLx = 70 * jolt + 30 * angry * (1 - roar) + 40 * roar - 15 * angry * wave(t, 9)
	s.aRz = 30 * jolt + 40 * roar
	s.aLz = 30 * jolt + 40 * roar
	s.foRx = 50 * jolt + 30 * roar
	s.foLx = 50 * jolt + 30 * roar

	s.tw = t * 1.5
	s.ty = 10 + 14 * shake
	s.tp1 = -6 * jolt + 6 * (sqR + sqL) - 8 * rear + 4 * roar
	s.tpn = 2 * (sqR + sqL) - 2 * jolt
	s.tpTip = -8 * jolt - 6 * roar

	s.ot = t
	s.oUp = jolt
	s.oPush = roar
	s.oJolt = max(env(t, AL_R, 0.05, 0, 0.5, "quadOut", "elasticOut"), env(t, AL_L, 0.05, 0, 0.5, "quadOut", "elasticOut"))
	rig(pose, ctx, s)

	if t > 0.3 then
		showAngry(ctx)
	end
	if ctx.crossed(0.05) then
		ctx.emit("AuraSparkle", 12)
	end
	if ctx.crossed(AL_R) then
		ctx.emit("DustR", 18)
	end
	if ctx.crossed(AL_L) then
		ctx.emit("DustL", 18)
		ctx.emit("StompCubes", 10)
	end
	if ctx.crossed(AL_ROAR) then
		ctx.emit("RoarBurst", 50)
		ctx.emit("PetalBurst", 110)
		ctx.emit("StompCubes", 16)
	end
	for k = 0, 5 do
		if ctx.crossed(AL_ROAR + 0.04 + k * 0.1) then
			ctx.emit("MouthPetals", 8)
		end
	end
	shock(pose, ctx, t, AL_ROAR, 11)
	ctx.light("MouthLight", 1.5 * roar)
end

------------------------------------------------------------------------
-- CHASE (0.8 s loop): thundering run
------------------------------------------------------------------------
local CH_T, CH_S, CH_H, CH_ZC = 0.8, 8.5, 3.2, -1.4

local function chase(t, pose, ctx)
	local s = S()
	local ph = (t % CH_T) / CH_T
	local w = 2 * pi * ph
	local zR, yR, toeR = gait(ph, CH_S, CH_H, CH_ZC)
	local zL, yL, toeL = gait((ph + 0.5) % 1, CH_S, CH_H, CH_ZC)
	s.fRz, s.fRy, s.toeR = zR, yR, toeR
	s.fLz, s.fLy, s.toeL = zL, yL, toeL
	-- squash right after each footfall (ph 0 and 0.5), up at mid-stance
	local imp = max(0, cos(2 * w)) ^ 3
	local bob = cos(2 * w - 0.6)
	s.hy = -0.9 - 0.9 * bob
	s.hz = -0.6
	s.hp = -15 + 2 * imp
	s.hx = 0.5 * sin(w)
	s.hyaw = 7 * sin(w)
	s.hroll = 5 * sin(w - 0.3)
	s.cx = -5 + 4 * imp
	s.cy = -6 * sin(w)
	s.cz = -2 * sin(w)
	s.nx = -2 + 3 * bob
	s.ny = 2 * sin(w)
	s.hdx = 16 - 4 * bob
	s.hdy = -3 * sin(w)
	s.hdz = 3 * sin(w)
	s.jaw = 16 + 12 * max(0, sin(2 * w + 1.0))
	s.beard = -6 * bob
	s.beardZ = 10 * sin(w - 0.8)
	s.brow = 22
	s.lid = 0.2
	-- tiny arms pumping like mad
	s.aRx = 25 + 40 * sin(2 * w)
	s.aLx = 25 - 40 * sin(2 * w)
	s.aRz = 8
	s.aLz = 8
	s.foRx = 10 + 30 * sin(2 * w + 0.6)
	s.foLx = 10 - 30 * sin(2 * w + 0.6)
	-- tail levelled as a counter-balance, swinging against the hips
	s.tp1 = 10 + 2 * bob
	s.tpn = 1 - 1.5 * bob
	s.tw = ph + 0.5
	s.ty = 9
	s.tyo = 0
	s.ot = t
	s.oJolt = 0.4 * imp
	rig(pose, ctx, s)
	showAngry(ctx)
	if ctx.crossed(0.03 * CH_T) then
		ctx.emit("DustR", 12)
		ctx.emit("StompCubes", 3)
	end
	if ctx.crossed(0.53 * CH_T) then
		ctx.emit("DustL", 12)
		ctx.emit("StompCubes", 3)
	end
end

------------------------------------------------------------------------
-- ATTACK (1.2 s): rear back -> lunging CHOMP -> head shake
------------------------------------------------------------------------
local CHOMP = 0.56

local function attack(t, pose, ctx)
	local s = S()
	local wind = env(t, 0.0, 0.38, 0.04, 0.16, "cubicOut", "quadIn")
	local lunge = env(t, 0.4, 0.16, 0.36, 0.28, "backOut", "cubicInOut")
	local open = env(t, 0.1, 0.3, 0.12, 0.05, "cubicOut", "expoIn")
	local bite = env(t, CHOMP, 0.03, 0.3, 0.25, "linear", "quadOut")
	local shake = env(t, 0.62, 0.06, 0.28, 0.12)
	local stepZ = L.track(t, { { 0, 0 }, { 0.3, 0, "linear" }, { 0.52, -3.2, "cubicOut" }, { 0.95, -3.2, "linear" }, { 1.15, 0, "cubicInOut" } })
	local stepY = env(t, 0.3, 0.11, 0, 0.11, "quadOut", "quadIn") + env(t, 0.95, 0.1, 0, 0.1, "quadOut", "quadIn")
	local imp = env(t, 0.52, 0.03, 0.05, 0.25, "quadOut", "backOut")

	s.hy = -0.6 * wind - 0.7 * lunge - 0.5 * imp
	s.hz = 1.0 * wind - 2.4 * lunge
	s.hp = 9 * wind - 11 * lunge
	s.hyaw = -4 * lunge
	s.fRz, s.fRy, s.toeR = stepZ, 2.2 * stepY, -12 * stepY
	s.cx = 12 * wind - 10 * lunge - 4 * imp
	s.nx = 10 * wind - 10 * lunge
	local sh = sin(2 * pi * 7 * (t - 0.62)) * shake
	s.ny = 8 * sh
	s.hdx = 22 * wind + 12 * lunge - 4 * imp
	s.hdy = 22 * sh
	s.hdz = 12 * sh
	s.jaw = 65 * open - 9 * bite + 30 * wind * (1 - open)
	s.beardZ = 25 * sh
	s.brow = 24
	s.lid = 0.5 * wind * (1 - open) + 0.6 * bite
	s.aRx = -20 * wind + 60 * lunge
	s.aLx = -20 * wind + 60 * lunge
	s.aRz = 20 * wind + 10 * sh
	s.aLz = 20 * wind - 10 * sh
	s.foRx = 40 * lunge
	s.foLx = 40 * lunge
	s.tw = t * 1.0
	s.ty = 6 + 14 * shake
	s.tyo = 12 * sh
	s.tp1 = -8 * wind + 14 * lunge
	s.tpn = -2 * wind + 2 * lunge
	s.tpTip = -10 * wind
	s.ot = t
	s.oPush = lunge
	s.oJolt = bite
	rig(pose, ctx, s)
	showAngry(ctx)
	snapLines(ctx, t > CHOMP and t < CHOMP + 0.16)
	if ctx.crossed(0.53) then
		ctx.emit("DustR", 16)
	end
	if ctx.crossed(CHOMP) then
		ctx.emit("RoarBurst", 35)
		ctx.emit("MouthPetals", 14)
		ctx.emit("StompCubes", 8)
	end
	if ctx.crossed(1.08) then
		ctx.emit("DustR", 6)
	end
	ctx.light("MouthLight", 1.3 * bite)
end

------------------------------------------------------------------------
-- CATCH (2.0 s): triumphant roar to the sky
------------------------------------------------------------------------
local function catch(t, pose, ctx)
	local s = S()
	local smug = env(t, 0.0, 0.25, 0.1, 0.2, "cubicOut", "quadInOut")
	local crouch = env(t, 0.25, 0.25, 0.05, 0.15, "cubicOut", "quadIn")
	local sky = env(t, 0.5, 0.2, 0.95, 0.35, "backOut", "cubicInOut")
	local shake = env(t, 0.65, 0.1, 0.8, 0.2)
	local nod = env(t, 1.65, 0.12, 0.05, 0.18, "quadOut", "backOut")
	local stomp = lift(t, 0.55, 0.2, 0.05)
	local sq = env(t, 0.55, 0.03, 0.05, 0.3, "quadOut", "backOut")

	s.hy = -0.7 * crouch - 1.2 * sq + 0.3 * sky
	s.hz = 0.6 * sky
	s.hp = -4 * crouch + 4 * sky - 2 * sq
	s.hroll = 4 * stomp
	s.fLy, s.fLz, s.toeL = 2.4 * stomp, -0.5 * stomp, -14 * stomp
	s.cx = -6 * crouch + 6 * sky - 4 * sq + 3 * smug
	s.nx = -10 * smug - 8 * crouch + 12 * sky - 8 * nod
	s.hdx = -12 * smug - 10 * crouch + 26 * sky - 14 * nod
	s.hdy = 8 * shake * wave(t, 5) - 10 * smug
	s.hdz = 8 * smug + 4 * shake * wave(t, 2.5)
	s.jaw = -4 * smug + 62 * sky + 6 * shake * wave(t, 12)
	s.beardZ = 14 * shake * wave(t, 5, 0.2)
	s.brow = 10 * smug + 6 * sky
	s.browUp = 0.3 * sky
	s.lid = 0.45 * smug + 0.3 * crouch
	-- tiny arms raised in victory, pumping
	local pump = 15 * sky * wave(t, 4)
	s.aRx = 100 * sky + pump - 10 * crouch
	s.aLx = 100 * sky - pump - 10 * crouch
	s.aRz = 35 * sky
	s.aLz = 35 * sky
	s.foRx = 60 * sky
	s.foLx = 60 * sky
	s.tw = t * 1.5
	s.ty = 8 + 12 * sky
	s.tp1 = 4 * crouch - 10 * sky + 6 * sq
	s.tpn = -2 * sky
	s.tpTip = -12 * sky
	s.ot = t
	s.oUp = 1.5 * sky
	s.oPush = sky
	s.oJolt = env(t, 0.55, 0.05, 0, 0.6, "quadOut", "elasticOut")
	rig(pose, ctx, s)
	if ctx.crossed(0.55) then
		ctx.emit("DustL", 20)
		ctx.emit("StompCubes", 14)
	end
	shock(pose, ctx, t, 0.55, 10)
	if ctx.crossed(0.68) then
		ctx.emit("RoarBurst", 45)
		ctx.emit("PetalBurst", 120)
		ctx.emit("AuraSparkle", 20)
	end
	for k = 0, 7 do
		if ctx.crossed(0.72 + k * 0.11) then
			ctx.emit("MouthPetals", 7)
		end
	end
	ctx.light("MouthLight", 1.5 * sky)
end

------------------------------------------------------------------------
-- GIVEUP (2.6 s): tantrum stomps, then a big deflating sigh
------------------------------------------------------------------------
local TANTRUM = { { 0.32, "R" }, { 0.64, "L" }, { 0.96, "R" }, { 1.28, "L" } }

local function giveup(t, pose, ctx)
	local s = S()
	local fit = env(t, 0.05, 0.15, 1.3, 0.25)
	local liftR, liftL, sq = 0, 0, 0
	for _, st in TANTRUM do
		local k = lift(t, st[1], 0.17, 0.05)
		if st[2] == "R" then
			liftR = max(liftR, k)
		else
			liftL = max(liftL, k)
		end
		sq = max(sq, env(t, st[1], 0.03, 0.04, 0.18, "quadOut", "backOut"))
	end
	local sigh = env(t, 1.55, 0.3, 0.25, 0.45, "cubicOut", "cubicInOut")
	local huff = env(t, 1.7, 0.15, 0.2, 0.3)
	local thrash = sin(2 * pi * 3.1 * t) * fit

	s.hy = -1.1 * sq - 0.9 * sigh
	s.hp = -4 * fit - 3 * sq - 4 * sigh
	s.hx = -0.6 * liftR + 0.6 * liftL
	s.hroll = -6 * liftR + 6 * liftL
	s.hyaw = 6 * thrash
	s.fRy, s.fRz, s.toeR = 2.8 * liftR, -0.4 * liftR, -16 * liftR
	s.fLy, s.fLz, s.toeL = 2.8 * liftL, -0.4 * liftL, -16 * liftL
	s.cx = -6 * sq - 8 * sigh + 6 * huff
	s.cy = -8 * thrash
	s.cz = -5 * liftR + 5 * liftL
	s.nx = -6 * fit - 6 * sq - 12 * sigh + 6 * huff
	s.ny = 10 * thrash
	s.hdx = 6 * fit - 6 * sq - 14 * sigh + 10 * huff
	s.hdy = 22 * thrash
	s.hdz = 10 * thrash
	s.jaw = 30 * fit * max(0, sin(2 * pi * 4 * t)) + 22 * huff
	s.beardZ = 22 * thrash
	s.brow = 26 * fit - 16 * sigh
	s.browUp = 0.2 * sigh
	s.lid = 0.55 * sigh + 0.15 * fit
	-- tiny arms flailing like crazy
	local fl = sin(2 * pi * 6 * t) * fit
	s.aRx = 40 * fit + 45 * fl - 10 * sigh
	s.aLx = 40 * fit - 45 * fl - 10 * sigh
	s.aRz = 30 * fit + 20 * fl
	s.aLz = 30 * fit - 20 * fl
	s.foRx = 30 * fit + 30 * sin(2 * pi * 6 * t + 1) * fit
	s.foLx = 30 * fit - 30 * sin(2 * pi * 6 * t + 1) * fit
	s.tw = t * 2.0
	s.ty = 5 + 10 * fit
	s.tp1 = 10 * sq + 4 * sigh
	s.tpn = 3 * sq + 2 * sigh
	s.ot = t
	s.oJolt = sq - 0.5 * sigh
	rig(pose, ctx, s)
	if t < 1.6 then
		showAngry(ctx)
	end
	for _, st in TANTRUM do
		if ctx.crossed(st[1]) then
			ctx.emit(st[2] == "R" and "DustR" or "DustL", 14)
			ctx.emit("StompCubes", 5)
		end
	end
	shock(pose, ctx, t, TANTRUM[4][1], 8)
	if ctx.crossed(1.8) then
		ctx.emit("MouthPetals", 10)
	end
end

------------------------------------------------------------------------
-- RETURN (1.2 s loop): heavy grumpy stomp walk
------------------------------------------------------------------------
local RT_T, RT_S, RT_H, RT_ZC = 1.2, 4.2, 1.4, -0.6

local function returnHome(t, pose, ctx)
	local s = S()
	local ph = (t % RT_T) / RT_T
	local w = 2 * pi * ph
	local zR, yR, toeR = gait(ph, RT_S, RT_H, RT_ZC)
	local zL, yL, toeL = gait((ph + 0.5) % 1, RT_S, RT_H, RT_ZC)
	s.fRz, s.fRy, s.toeR = zR, yR, toeR * 0.7
	s.fLz, s.fLy, s.toeL = zL, yL, toeL * 0.7
	local imp = max(0, cos(2 * w)) ^ 4
	local bob = cos(2 * w - 0.5)
	s.hy = -0.4 - 0.5 * bob
	s.hp = -6 + 1.5 * imp
	s.hx = 0.7 * sin(w)
	s.hyaw = 6 * sin(w)
	s.hroll = 6 * sin(w - 0.4)
	s.cx = 2 * imp
	s.cy = -5 * sin(w)
	s.cz = -3 * sin(w - 0.4)
	s.nx = -6 + 2 * bob
	s.hdx = 2 - 3 * bob
	s.hdy = 6 * sin(w - 0.6)
	s.hdz = 4 * sin(w - 0.8)
	s.jaw = 2 + 4 * imp
	s.beardZ = 10 * sin(w - 1.0)
	s.brow = 16
	s.lid = 0.35
	s.aRx = 12 * sin(w)
	s.aLx = -12 * sin(w)
	s.foRx = 8 * sin(w + 0.5)
	s.foLx = -8 * sin(w + 0.5)
	s.tw = ph + 0.5
	s.ty = 9
	s.tp1 = 2 + 2 * bob
	s.tpn = 0.5 * bob
	s.ot = t
	s.oJolt = 0.3 * imp
	rig(pose, ctx, s)
	if ctx.crossed(0.03 * RT_T) then
		ctx.emit("DustR", 6)
	end
	if ctx.crossed(0.53 * RT_T) then
		ctx.emit("DustL", 6)
	end
end

------------------------------------------------------------------------
local M = {}
M.Props = {
	AngryMark1 = 1, AngryMark2 = 1, AngryMark3 = 1, AngryMark4 = 1,
	SweatDrop1 = 1, SweatDrop2 = 1, EyelidR = 1, EyelidL = 1,
}
for k = 1, 6 do
	M.Props["SnapLine" .. k] = 1
end
for k = 1, SHOCK_N do
	M.Props["Wave" .. k] = 1
	M.Props["WaveTop" .. k] = 1
end
M.States = {
	Idle = { Loop = true, Length = IDLE, Update = idle },
	Alert = { Length = 2.2, Update = alert },
	Chase = { Loop = true, Length = CH_T, Speed = CH_S / (0.5 * CH_T), Update = chase },
	Attack = { Length = 1.2, Update = attack },
	Catch = { Length = 2.0, Update = catch },
	GiveUp = { Length = 2.6, Update = giveup },
	Return = { Loop = true, Length = RT_T, Speed = RT_S / (0.5 * RT_T), Update = returnHome },
}
M.Base = "Idle"
M.Reel = { { "Idle" }, { "Alert" }, { "Chase", 3.6 }, { "Attack" }, { "Catch" }, { "Chase", 1.8 }, { "GiveUp" }, { "Return", 3.6 } }
return L.states(M)
