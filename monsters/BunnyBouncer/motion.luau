--!nocheck
-- Bunny Bouncer motion (guardian states).
-- Idle   : arms crossed, cool head-nod, ear twitches, touches his earpiece
--          ("copy that"), cracks his knuckles, then the SHOW-OFF: a little hop
--          into a double-bicep flex with pumping sparkles; scans the crowd.
-- Alert  : freeze -> crouch -> SHADES FLIP UP (angry eyes + anger vein), ears
--          shoot straight up, rage roar + burst, pounds his fists together x3.
-- Chase  : huge two-footed bunny hops, feet plant and push, ears streaming.
-- Attack : crouch, fists over the head, jump -> DOUBLE-FIST GROUND SLAM.
-- Catch  : pops into a flex, nods the shades back down, smug pumps.
-- GiveUp : rabbit foot THUMP tantrum, throws his arms up, sighs, shades down.
-- Return : cool shoulder-rolling swagger walk back to the patch.
-- Legs use a small 2-bone IK so planted feet never slide or sink.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, track, env = L.ang, L.pa, L.wave, L.track, L.env

local sqrt, max, min, abs, clamp = math.sqrt, math.max, math.min, math.abs, math.clamp
local atan2, acos, sin, cos, pi = math.atan2, math.acos, math.sin, math.cos, math.pi

------------------------------------------------------------------------
-- Leg IK (rest pivots in model space, right side; left is mirrored)
------------------------------------------------------------------------
local HIP = Vector3.new(0, 2.3, 0.15)
local THIGH = Vector3.new(0.95, 2.2, 0.15)
local SHIN = Vector3.new(1.0, 1.25, -0.25)
local FOOT = Vector3.new(1.0, 0.6, 0.3)
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
-- Arm key poses (right side; left mirrors):
-- { armX, armY, armZ, foreX, foreY, foreZ, fistX, fistZ }
------------------------------------------------------------------------
local REST = { 0, 0, 8, 12, 0, -6, 0, 0 }
-- (optional 9-11: shoulder shift x, y, z in studs)
local CROSS_R = { 28, 0, -14, 34, 6, -64, 0, 0, -0.3, 0, -0.45 } -- right forearm on top
local CROSS_L = { 20, 0, -14, 42, 18, -64, 0, 0, -0.3, 0, -0.3 }
local FLEX = { 6, 0, 86, 20, 26, 128, -10, 0 } -- double-bicep
local EARPC = { 64, 0, 34, 6, -54, -140, 0, 0 } -- finger to the earpiece
local KNUCK = { 52, 0, -6, 18, -14, -44, 0, 0 } -- fists together in front
local APART = { 48, 0, 6, -10, -54, -72, 0, 0 } -- fists pulled apart (wind-up)
local OVER = { 164, 0, -10, 30, 34, -40, 0, 0 } -- fists over the head
local SLAM = { 68, 0, -10, -6, 34, -16, -10, 0 } -- fists smashed into the ground
local THROW = { 150, 0, 40, 30, 0, 10, 0, 0 } -- arms flung up in a V
local READY = { 28, 0, 12, 92, 0, -22, -10, 0 } -- boxer guard
local PUMP = { -8, 0, 22, 70, 0, 0, 0, 0 } -- fists at the hips (tantrum)

local function mix(a, b, k)
	local o = {}
	for i = 1, 11 do
		local x = a[i] or 0
		o[i] = x + ((b[i] or 0) - x) * k
	end
	return o
end

local function copy(a)
	return mix(a, a, 0)
end

------------------------------------------------------------------------
-- Pose state shared by every gameplay state, then applied by rig()
------------------------------------------------------------------------
local function newS()
	return {
		hx = 0, hy = 0, hz = 0, hrx = 0, hry = 0, hrz = 0, -- hips
		cy = 0, crx = 0, cry = 0, crz = 0, -- chest
		hdy = 0, hdx = 0, hdyaw = 0, hdz = 0, -- head
		jaw = -3,
		shades = 0, -- 0 on the eyes .. 1 flipped up on the forehead
		anger = 0, browUp = 0,
		earX = { 0, 0, 0, 0 }, -- R1, R2, L1, L2 pitch (+ = tips back)
		earOut = { 8, 4, 8, 4 }, -- splay outward (deg)
		armR = copy(REST), armL = copy(REST),
		footR = Vector3.zero, footL = Vector3.zero, -- ankle target offsets
		pitchR = 0, pitchL = 0, -- foot pitch (- = toes down)
		tailX = 0, tailY = 0, pend = 0, pendZ = 0,
		vein = 0, orbit = 0, orbY = 0, orbOut = 0,
	}
end

local function armCF(p, s)
	local a = pa(p[9] or 0, p[10] or 0, p[11] or 0, p[1], p[2], p[3])
	local f, w = ang(p[4], p[5], p[6]), ang(p[7], 0, p[8])
	if s < 0 then
		return L.mirror(a), L.mirror(f), L.mirror(w)
	end
	return a, f, w
end

local CHEST = Vector3.new(0, 2.8, 0.2)
local ARM = Vector3.new(1.65, 4.55, 0.2)
local FORE = Vector3.new(2.1, 3.25, 0.2)
local FIST = Vector3.new(2.15, 1.95, 0.15)
local FIST_CORNERS = {}
for _, x in { -0.73, 0.73 } do
	for _, y in { -0.02, -1.17 } do
		for _, z in { -0.78, 0.68 } do
			table.insert(FIST_CORNERS, Vector3.new(x, y, z))
		end
	end
end

local EYES = { "EyeWhiteR", "EyeWhiteL", "PupilR", "PupilL" }

-- limit the foot pitch so neither the long toes nor the heel dig into the floor
local function footPitch(ankleY, p)
	for _ = 1, 12 do
		local r = math.rad(p)
		local toe = ankleY - 0.6 * cos(r) + 2.3 * sin(r)
		local heel = ankleY - 0.6 * cos(r) - 0.85 * sin(r)
		if min(toe, heel) >= 0.03 then
			return p
		end
		p *= 0.8
	end
	return 0
end

local function rig(pose, ctx, S, t)
	-- HIPS + LEGS (IK keeps planted feet planted)
	local function hipsCF(dy)
		return pa(S.hx, S.hy - dy, S.hz, S.hrx, S.hry, S.hrz)
	end
	local hipsT = hipsCF(0)
	local hipsW = CFrame.new(HIP) * hipsT
	local tR = FOOT + S.footR
	local tL = sideV(FOOT, -1) + S.footL
	local drop = max(reachDrop(hipsW, 1, tR), reachDrop(hipsW, -1, tL))
	if drop > 0 then
		hipsT = hipsCF(drop)
		hipsW = CFrame.new(HIP) * hipsT
	end
	pose.Hips = hipsT
	pose.ThighR, pose.ShinR, pose.FootR = legIK(hipsW, 1, tR, ang(footPitch(tR.Y, S.pitchR), 0, 0))
	pose.ThighL, pose.ShinL, pose.FootL = legIK(hipsW, -1, tL, ang(footPitch(tL.Y, S.pitchL), 0, 0))

	pose.Chest = pa(0, S.cy, 0, S.crx, S.cry, S.crz)
	pose.Head = pa(0, S.hdy, 0, S.hdx, S.hdyaw, S.hdz)
	pose.Jaw = ang(S.jaw, 0, 0)

	-- SHADES: slide up + tip back onto the forehead (swinging out on the way)
	local k = S.shades
	local arc = sin(pi * clamp(k, 0, 1))
	pose.Shades = pa(0, 0.86 * k + 0.1 * arc, 0.6 * k - 0.45 * arc, 82 * k, 0, 0)
	local eyesOn = k > 0.35
	for _, n in EYES do
		ctx.transparency(n, eyesOn and 0 or 1)
	end

	-- BROWS: flat + cool at rest, tilted down hard when angry
	L.both(pose, "Brow", pa(0, -0.07 * S.anger + 0.14 * S.browUp, 0, 0, 0, 24 * S.anger - 6 * S.browUp))

	-- ANGER VEIN (props) pulses while shown
	if S.anger > 0.5 and S.vein > 0 then
		for i = 1, 4 do
			ctx.transparency("AngryMark" .. i, 0)
		end
	end
	local throb = 0.06 * max(0, wave(t, 4))
	pose.Vein = pa(0, throb, 0, 0, 0, 10 * wave(t, 4))

	-- EARS (right-handed values, mirrored for the left)
	pose.EarR1 = ang(S.earX[1], 0, -S.earOut[1])
	pose.EarR2 = ang(S.earX[2], 0, -S.earOut[2])
	pose.EarL1 = L.mirror(ang(S.earX[3], 0, -S.earOut[3]))
	pose.EarL2 = L.mirror(ang(S.earX[4], 0, -S.earOut[4]))

	-- ARMS (fists are lifted by a shoulder shrug if they would go into the ground)
	local chestW = hipsW * CFrame.new(CHEST - HIP) * pose.Chest
	for _, sd in { { "R", 1, S.armR }, { "L", -1, S.armL } } do
		local s = sd[2]
		local aT, fT, wT = armCF(sd[3], s)
		local fistW = chestW * CFrame.new(sideV(ARM, s) - CHEST) * aT * CFrame.new(sideV(FORE, s) - sideV(ARM, s)) * fT
			* CFrame.new(sideV(FIST, s) - sideV(FORE, s)) * wT
		local low = math.huge
		for _, c in FIST_CORNERS do
			low = min(low, (fistW * Vector3.new(c.X * s, c.Y, c.Z)).Y)
		end
		if low < 0.08 then
			aT = CFrame.new(chestW.Rotation:Inverse() * Vector3.new(0, 0.08 - low, 0)) * aT
		end
		pose["Arm" .. sd[1]], pose["Forearm" .. sd[1]], pose["Fist" .. sd[1]] = aT, fT, wT
	end

	pose.Tail = ang(S.tailX, S.tailY, 0)
	pose.Pendant = ang(S.pend, 0, S.pendZ)

	-- FLOATING GARDEN CUBES
	pose.Orbit = ang(0, S.orbit, 0)
	for i = 1, 3 do
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(0, 0.45 * wave(t, 0.5, i * 0.3) + S.orbY, 0, 90 * t * dir, 120 * t, 0)
	end
end

-- angry face preset (shades up, brows down, vein shown)
local function angry(S, k)
	S.shades, S.anger, S.vein = k, k, k
end

------------------------------------------------------------------------
-- IDLE (12 s): cool guard on duty
------------------------------------------------------------------------
local IDLE_LEN = 12
local function idle(t, pose, ctx)
	local c = t % IDLE_LEN
	local S = newS()
	local breathe = wave(t, 0.5)
	local sway = wave(t, 0.25)

	-- gag envelopes
	local earpc = env(c, 2.8, 0.35, 1.3, 0.4, "backOut", "cubicInOut")
	local crack = env(c, 5.0, 0.3, 0.9, 0.35, "backOut", "cubicInOut")
	local pre = env(c, 6.55, 0.35, 0.05, 0.12, "quadOut", "quadIn") -- flex anticipation
	local flex = track(c, { { 6.95, 0 }, { 7.2, 1, "backOut" }, { 9.0, 1 }, { 9.55, 0, "cubicInOut" } })
	local hop = env(c, 6.95, 0.15, 0, 0.17, "quadOut", "quadIn")
	local land = env(c, 7.27, 0.04, 0.02, 0.4, "quadOut", "elasticOut")
	local scan = env(c, 10.0, 0.3, 1.1, 0.35)
	local busy = max(earpc, crack, pre, flex, scan)
	local nodW = 1 - busy

	-- pumps during the flex hold
	local pumpK = 0
	for _, h in { 7.55, 8.05, 8.55 } do
		pumpK = max(pumpK, env(c, h, 0.08, 0.06, 0.25, "quadOut", "quadIn"))
	end
	-- knuckle cracks
	local crackK = 0
	for _, h in { 5.45, 5.85 } do
		crackK = max(crackK, env(c, h, 0.06, 0.05, 0.18, "quadOut", "quadIn"))
	end
	-- "copy that" nods while touching the earpiece
	local talk = env(c, 3.2, 0.1, 0.7, 0.1) * max(0, wave(t, 2.5)) ^ 2

	-- cool beat-nod (to the club music)
	local nod = max(0, wave(t, 1, 0.1)) ^ 3 * nodW

	-- HIPS: weight shift, crouch into the hop, bounce of the flex pumps
	S.hx = 0.08 * sway
	S.hy = -0.03 + 0.04 * breathe - 0.35 * pre + 0.75 * hop - 0.3 * land - 0.12 * pumpK - 0.06 * nod
	S.hry = 4 * sway * nodW
	S.hrz = -2 * sway
	S.footR = Vector3.new(0, 0.75 * hop, 0)
	S.footL = Vector3.new(0, 0.75 * hop, 0)
	S.pitchR, S.pitchL = -12 * hop, -12 * hop

	-- CHEST: breathing, puffed for the flex, shrug on cracks
	S.cy = 0.04 * breathe + 0.08 * flex
	S.crx = 2 * breathe + 4 * flex + 5 * pre - 3 * crackK - 2 * talk
	S.cry = -6 * scan * wave(t, 0.5, 0.0) + 8 * pumpK * wave(t, 1, 0.25) * flex
	S.crz = 1.5 * sway - 3 * earpc

	-- HEAD: nods to the beat, tilts into the earpiece, scans left/right
	local scanYaw = track(c, { { 10.0, 0 }, { 10.35, 32, "backOut" }, { 10.75, 32 }, { 11.0, -32, "cubicInOut" }, { 11.3, -32 }, { 11.45, 0, "quadInOut" } })
	S.hdx = -7 * nod - 9 * talk - 4 * pre + 6 * flex - 4 * crackK
	S.hdyaw = scanYaw + 6 * L.noise(t, 2.3, 0.2) * nodW
	S.hdz = -10 * earpc + 4 * sway * nodW
	S.jaw = -3 - 4 * talk - 6 * pumpK
	S.browUp = 0.8 * pumpK + 0.5 * talk + 0.6 * scan * max(0, wave(t, 3))

	-- EARS: relaxed splay, quick twitches (right at 1.6 s, left at 10.9 s)
	local twR = env(c, 1.55, 0.06, 0.4, 0.15) * wave(t, 8)
	local twL = env(c, 10.85, 0.06, 0.35, 0.15) * wave(t, 8, 0.25)
	local flop = 6 * wave(t, 0.5, -0.15) + 10 * land - 14 * hop
	S.earX = { 4 + flop + 18 * twR, 6 + 1.6 * flop + 22 * twR, 4 + flop + 18 * twL, 6 + 1.6 * flop + 22 * twL }
	S.earOut = { 9 - 8 * flex, 5 - 6 * flex - 16 * earpc, 9 - 8 * flex, 5 - 6 * flex }

	-- ARMS: crossed -> earpiece / knuckle crack / flex
	local aR, aL = copy(CROSS_R), copy(CROSS_L)
	aR[1] += 3 * breathe
	aL[1] += 3 * breathe
	aR = mix(aR, EARPC, earpc)
	aR[6] += 8 * talk
	local kn = mix(KNUCK, APART, 0)
	kn[1] += 8 * crackK
	kn[6] -= 12 * crackK
	aR = mix(aR, kn, crack)
	aL = mix(aL, kn, crack)
	local pr = mix(REST, { 20, 0, -10, 40, 0, -40, 0, 0 }, 1)
	aR = mix(aR, pr, pre * (1 - flex))
	aL = mix(aL, pr, pre * (1 - flex))
	local fl = copy(FLEX)
	fl[6] += 18 * pumpK
	fl[3] -= 6 * pumpK
	aR = mix(aR, fl, flex)
	aL = mix(aL, fl, flex)
	S.armR, S.armL = aR, aL

	S.tailY = 14 * wave(t, 1)
	S.tailX = 4 * breathe
	S.pend = -6 * hop + 8 * land + 3 * breathe
	S.pendZ = 6 * pumpK * wave(t, 2)
	S.orbit = 30 * t
	S.orbY = 0.5 * flex

	rig(pose, ctx, S, t)

	if ctx.crossed(5.47) or ctx.crossed(5.87) then
		ctx.emit("FistClash", 6)
	end
	if ctx.crossed(7.27) then
		ctx.emit("StepDust", 10)
		ctx.emit("FlexSparkle", 22)
	end
	for _, h in { 7.6, 8.1, 8.6 } do
		if ctx.crossed(h) then
			ctx.emit("FlexSparkle", 12)
		end
	end
end

------------------------------------------------------------------------
-- ALERT (2.0 s): MY CARROTS GOT STOLEN!
------------------------------------------------------------------------
local function alert(t, pose, ctx)
	local S = newS()
	local perk = env(t, 0.0, 0.12, 0.25, 0.2, "backOut", "quadInOut")
	local crouch = env(t, 0.2, 0.3, 0.02, 0.18, "cubicOut", "quadIn")
	local flip = track(t, { { 0.48, 0 }, { 0.68, 1, "backOut" } })
	local boom = env(t, 0.5, 0.12, 0.25, 0.3, "backOut", "cubicInOut") -- rage roar
	local jump = env(t, 0.5, 0.14, 0, 0.14, "quadOut", "quadIn")
	local land = env(t, 0.78, 0.04, 0.02, 0.35, "quadOut", "elasticOut")
	local pound = track(t, { { 0.8, 0 }, { 0.95, 1, "cubicOut" }, { 1.55, 1 }, { 1.75, 0, "quadInOut" } })
	local ready = track(t, { { 1.55, 0 }, { 1.85, 1, "backOut" } })
	local hit = 0
	for _, h in { 1.0, 1.22, 1.44 } do
		hit = max(hit, env(t, h - 0.08, 0.08, 0.02, 0.1, "quadIn", "quadOut"))
	end
	local fizz = env(t, 0.55, 0.05, 1.0, 0.3) * wave(t, 18) -- rage tremble

	S.hy = 0.15 * perk - 0.55 * crouch + 0.9 * jump - 0.35 * land - 0.1 * hit - 0.15 * ready
	S.hrx = -6 * crouch - 4 * ready
	S.footR = Vector3.new(0, 0.9 * jump, 0)
	S.footL = Vector3.new(0, 0.9 * jump, 0)
	S.pitchR, S.pitchL = -15 * jump, -15 * jump
	S.crx = -10 * crouch + 18 * boom - 6 * hit - 6 * ready + 2 * fizz
	S.crz = 1.5 * fizz
	S.cy = 0.1 * boom
	S.hdx = 10 * perk - 12 * crouch + 16 * boom - 10 * hit - 2 * ready
	S.hdyaw = 24 * env(t, 0.02, 0.06, 0.08, 0.1, "quadOut", "quadIn") -- double take
	S.hdz = 3 * fizz
	S.jaw = -3 - 52 * boom + 8 * crouch - 18 * hit
	angry(S, flip)
	S.anger = max(flip, crouch * 0.6)
	S.browUp = 1.2 * perk * (1 - crouch)
	-- ears perk, then SHOOT straight up (overshoot) and quiver
	local shoot = track(t, { { 0.5, 0 }, { 0.62, 1, "backOut" } })
	local quiver = 10 * shoot * wave(t, 9) * max(0, 1 - (t - 0.6) / 1.2)
	S.earX = { -6 * perk - 14 * shoot + quiver + 10 * crouch, -4 * perk - 10 * shoot + 1.4 * quiver + 14 * crouch, -6 * perk - 14 * shoot - quiver + 10 * crouch, -4 * perk - 10 * shoot - 1.4 * quiver + 14 * crouch }
	local outK = 1 - max(perk, shoot)
	S.earOut = { 9 * outK + 22 * crouch * (1 - shoot), 5 * outK + 10 * crouch * (1 - shoot), 9 * outK + 22 * crouch * (1 - shoot), 5 * outK + 10 * crouch * (1 - shoot) }

	-- arms: tense -> flung out on the roar -> pound fists -> boxer guard
	local tense = { 10, 0, 20, 40, 0, -10, 0, 0 }
	local aR = mix(REST, tense, crouch)
	aR = mix(aR, THROW, boom * (1 - pound))
	local pr = mix(APART, KNUCK, hit)
	aR = mix(aR, pr, pound)
	aR = mix(aR, READY, ready)
	S.armR = aR
	S.armL = copy(aR)
	S.armR[3] += 3 * fizz
	S.tailY = 25 * wave(t, 6) * boom
	S.tailX = -20 * boom
	S.pend = -12 * jump + 14 * land - 8 * hit
	S.orbit = 40 * t
	S.orbY = 1.2 * boom
	rig(pose, ctx, S, t)

	if ctx.crossed(0.55) then
		ctx.emit("RageBurst", 40)
	end
	if ctx.crossed(0.78) then
		ctx.emit("StepDust", 14)
	end
	for _, h in { 1.0, 1.22, 1.44 } do
		if ctx.crossed(h) then
			ctx.emit("FistClash", 16)
		end
	end
end

------------------------------------------------------------------------
-- CHASE (0.5 s loop): one huge two-footed bunny hop per cycle
------------------------------------------------------------------------
local CH_LEN, CH_CONTACT, CH_SWEEP = 0.5, 0.3, 1.5
local CH_SPEED = CH_SWEEP / (CH_LEN * CH_CONTACT) -- 10 studs/s
local function chase(t, pose, ctx)
	local ph = (t % CH_LEN) / CH_LEN
	local S = newS()
	local fz, fy, pitch, hy, squash, air
	if ph < CH_CONTACT then
		local q = ph / CH_CONTACT
		fz = -CH_SWEEP / 2 + CH_SWEEP * q
		fy = 0
		pitch = 0
		squash = sin(pi * q)
		hy = -0.5 * squash
		air = 0
	else
		local q = (ph - CH_CONTACT) / (1 - CH_CONTACT)
		fz = CH_SWEEP / 2 - CH_SWEEP * L.smoothstep(q)
		air = sin(pi * q)
		hy = 1.9 * air
		fy = 1.45 * air
		pitch = track(q, { { 0, 0 }, { 0.22, -38, "quadOut" }, { 0.8, 12, "sineInOut" }, { 1, 0, "quadIn" } })
		squash = 0
	end
	S.hy = hy
	S.hrx = -26 - 10 * squash + 6 * air
	S.footR = Vector3.new(0, fy, fz)
	S.footL = Vector3.new(0, fy, fz)
	S.pitchR, S.pitchL = pitch, pitch
	-- chest: lean in, crunch on landing, stretch in the air
	S.crx = -14 - 8 * squash + 6 * air
	S.cy = -0.08 * squash
	S.cry = 4 * wave(t, 2)
	-- head: level gaze at the thief, jolts on landing
	S.hdx = 28 + 8 * squash - 6 * air
	S.hdyaw = 3 * wave(t, 2, 0.25)
	S.jaw = -14 - 10 * squash + 6 * air
	angry(S, 1)
	-- ears stream back, whip on landing (lagging the hop)
	local lag = wave(t, 2, -0.15)
	S.earX = { 48 + 12 * lag, 30 + 22 * wave(t, 2, -0.3), 48 + 12 * lag, 30 + 22 * wave(t, 2, -0.32) }
	S.earOut = { 12, 6, 12, 6 }
	-- arms: both fists pump together (back in the air, punch forward on landing)
	local sw = track(ph, { { 0, 30 }, { 0.3, 10, "quadOut" }, { 0.55, -42, "quadInOut" }, { 1, 30, "quadIn" } })
	local a = { sw, 0, 18, 72 - 0.4 * sw, 0, -12, -12, 0 }
	S.armR, S.armL = a, copy(a)
	S.tailX = -16 * air + 10 * squash
	S.pend = -14 * air + 10 * squash
	S.orbY = 0.4 * air
	rig(pose, ctx, S, t)
	if ctx.crossed(0.01) then
		ctx.emit("StepDust", 8)
	end
end

------------------------------------------------------------------------
-- ATTACK (1.2 s): jumping double-fist slam
------------------------------------------------------------------------
local IMPACT = 0.64
local function attack(t, pose, ctx)
	local S = newS()
	local wind = track(t, { { 0, 0 }, { 0.28, 1, "cubicOut" }, { 0.52, 1 }, { IMPACT, 0, "quadIn" } })
	local over = track(t, { { 0.05, 0 }, { 0.3, 1, "backOut" }, { 0.52, 1 }, { IMPACT, 0, "quadIn" } })
	local slam = track(t, { { 0.5, 0 }, { IMPACT, 1, "quadIn" }, { 0.86, 1 }, { 1.18, 0, "cubicInOut" } })
	local jump = track(t, { { 0.22, 0 }, { 0.46, 1, "quadOut" }, { IMPACT - 0.02, 0, "quadIn" } })
	local crouch = track(t, { { 0, 0 }, { 0.22, 1, "cubicOut" }, { 0.32, 0 }, { IMPACT - 0.02, 0 }, { IMPACT + 0.04, 1.2, "quadOut" }, { 0.86, 0.9 }, { 1.18, 0, "cubicInOut" } })
	local impact = env(t, IMPACT, 0.03, 0.05, 0.45, "linear", "elasticOut")

	S.hy = -0.55 * crouch + 1.5 * jump
	S.hz = 0.25 * wind - 0.35 * slam
	S.hrx = 8 * wind - 22 * slam
	S.footR = Vector3.new(0, 1.3 * jump, 0)
	S.footL = Vector3.new(0, 1.3 * jump, 0)
	S.pitchR, S.pitchL = -25 * jump, -25 * jump
	S.crx = 14 * wind - 26 * slam - 6 * impact
	S.hdx = 12 * wind + 28 * slam + 8 * impact
	S.jaw = -10 - 40 * wind - 30 * impact
	angry(S, 1)
	S.earX = { -20 * wind + 30 * jump - 26 * impact + 20 * slam, -18 * wind + 34 * jump - 40 * impact + 24 * slam, -20 * wind + 30 * jump - 26 * impact + 20 * slam, -18 * wind + 34 * jump - 40 * impact + 24 * slam }
	S.earOut = { 4 + 18 * impact, 2 + 20 * impact, 4 + 18 * impact, 2 + 20 * impact }
	local a = mix(REST, OVER, over)
	a = mix(a, SLAM, slam)
	a[1] -= 8 * impact
	S.armR, S.armL = a, copy(a)
	S.tailX = -18 * jump + 12 * impact
	S.pend = -18 * jump + 20 * impact
	S.orbY = -0.8 * impact + 0.6 * jump
	S.orbit = 25 * t
	rig(pose, ctx, S, t)

	-- turf + carrot chunks blasted out of the ground
	local u = t - IMPACT
	local on = u > 0 and u < 0.5
	local vel = { { 3, 9, -2 }, { -3.2, 8, -1.5 }, { 1, 10, -3.5 }, { -1.5, 7.5, -3 } }
	for i, vv in vel do
		local tt = clamp(u, 0, 0.5)
		local y = max(vv[2] * tt - 20 * tt * tt, 0)
		pose["Rock" .. i] = pa(vv[1] * tt, y, vv[3] * tt, 600 * tt, 380 * tt * (i % 2 == 0 and -1 or 1), 300 * tt)
		ctx.transparency("Rock" .. i, on and (u > 0.38 and (u - 0.38) / 0.12 or 0) or 1)
	end
	if ctx.crossed(IMPACT) then
		ctx.emit("SlamBurst", 36)
		ctx.emit("SlamDust", 22)
		ctx.emit("StepDust", 10)
	end
	if ctx.crossed(0.3) then
		ctx.emit("RageBurst", 10)
	end
	ctx.light("SlamLight", 1.4 * env(t, IMPACT, 0.03, 0.05, 0.4))
end

------------------------------------------------------------------------
-- CATCH (2.2 s): flex on the thief, shades back down, smug pumps
------------------------------------------------------------------------
local function catch(t, pose, ctx)
	local S = newS()
	local pre = env(t, 0.0, 0.3, 0.02, 0.12, "quadOut", "quadIn")
	local flex = track(t, { { 0.3, 0 }, { 0.5, 1, "backOut" }, { 1.65, 1 }, { 2.1, 0, "cubicInOut" } })
	local hop = env(t, 0.28, 0.12, 0, 0.12, "quadOut", "quadIn")
	local land = env(t, 0.52, 0.04, 0.02, 0.35, "quadOut", "elasticOut")
	local nodDown = env(t, 0.78, 0.1, 0.03, 0.25, "quadOut", "backOut")
	local shadesK = track(t, { { 0.8, 1 }, { 0.92, 0, "backOut" } })
	local pumpK = 0
	for _, h in { 1.1, 1.45 } do
		pumpK = max(pumpK, env(t, h, 0.08, 0.06, 0.2, "quadOut", "quadIn"))
	end
	S.hy = -0.3 * pre + 0.6 * hop - 0.3 * land - 0.1 * pumpK
	S.footR = Vector3.new(0, 0.6 * hop, 0)
	S.footL = Vector3.new(0, 0.6 * hop, 0)
	S.pitchR, S.pitchL = -10 * hop, -10 * hop
	S.crx = 6 * pre + 6 * flex - 3 * pumpK
	S.cy = 0.08 * flex
	S.cry = 10 * pumpK * wave(t, 1.4)
	S.hdx = -6 * pre + 8 * flex - 22 * nodDown
	S.hdz = 6 * flex * wave(t, 0.9, 0.25)
	S.jaw = -3 - 10 * flex * (0.5 + 0.5 * wave(t, 3)) * (t > 1.0 and 1 or 0) - 8 * pumpK
	S.shades = shadesK
	S.anger = shadesK
	S.vein = t < 0.8 and 1 or 0
	S.browUp = (t > 0.95 and 1 or 0) * (0.6 * pumpK + 0.5 * max(0, wave(t, 2.5))) * flex
	local wig = flex * wave(t, 3, -0.1)
	S.earX = { -6 * flex + 8 * wig + 12 * land, -4 * flex + 14 * wig + 18 * land, -6 * flex - 8 * wig + 12 * land, -4 * flex - 14 * wig + 18 * land }
	S.earOut = { 9 - 9 * flex, 5 - 5 * flex, 9 - 9 * flex, 5 - 5 * flex }
	local fl = copy(FLEX)
	fl[6] += 18 * pumpK
	local a = mix(REST, { 20, 0, -10, 40, 0, -40, 0, 0 }, pre * (1 - flex))
	a = mix(a, fl, flex)
	S.armR, S.armL = a, copy(a)
	S.tailY = 20 * wave(t, 2.5) * flex
	S.pend = -8 * hop + 10 * land
	S.orbY = 0.6 * flex
	S.orbit = 30 * t
	rig(pose, ctx, S, t)
	if ctx.crossed(0.52) then
		ctx.emit("FlexSparkle", 26)
		ctx.emit("StepDust", 8)
	end
	if ctx.crossed(0.86) then
		ctx.emit("FlexSparkle", 8)
	end
	for _, h in { 1.15, 1.5 } do
		if ctx.crossed(h) then
			ctx.emit("FlexSparkle", 14)
		end
	end
end

------------------------------------------------------------------------
-- GIVEUP (2.6 s): rabbit THUMP tantrum, arms up, sigh, shades down
------------------------------------------------------------------------
local THUMPS = { 0.5, 0.8, 1.1, 1.4 }
local function giveup(t, pose, ctx)
	local S = newS()
	local tant = track(t, { { 0.15, 0 }, { 0.3, 1, "quadOut" }, { 1.45, 1 }, { 1.55, 0 } })
	local throw = track(t, { { 1.45, 0 }, { 1.62, 1, "backOut" }, { 1.9, 1 }, { 2.15, 0, "cubicInOut" } })
	local sigh = env(t, 2.0, 0.2, 0.15, 0.25, "quadOut", "quadInOut")
	local shadesK = track(t, { { 2.05, 1 }, { 2.25, 0, "backOut" } })
	-- thump: right foot lifts and SLAMS down on each beat
	local lift, slamK = 0, 0
	for _, h in THUMPS do
		lift = max(lift, env(t, h - 0.2, 0.12, 0.02, 0.06, "quadOut", "quadIn"))
		slamK = max(slamK, env(t, h, 0.03, 0.02, 0.14, "quadOut", "quadIn"))
	end
	lift *= tant
	slamK *= tant
	S.hy = 0.25 * lift - 0.3 * slamK + 0.2 * throw - 0.25 * sigh
	S.hrz = 5 * lift
	S.footR = Vector3.new(0.15 * lift, 1.5 * lift, -0.45 * lift)
	S.pitchR = 22 * lift
	S.crx = -6 * tant - 5 * slamK + 12 * throw - 10 * sigh
	S.crz = -4 * lift
	S.hdx = -8 * tant + 6 * slamK + 26 * throw - 12 * sigh
	S.hdyaw = 22 * tant * wave(t, 3.3)
	S.jaw = -3 - (24 + 10 * wave(t, 6.6)) * tant - 50 * throw + 6 * sigh
	S.shades = shadesK
	S.anger = shadesK
	S.vein = shadesK
	-- ears flail, then droop on the sigh
	local fl = tant * wave(t, 3.3, -0.1)
	S.earX = { 10 * fl + 24 * throw + 8 * slamK, 18 * fl + 34 * throw + 16 * slamK, -10 * fl + 24 * throw + 8 * slamK, -18 * fl + 34 * throw + 16 * slamK }
	S.earOut = { 9 + 30 * sigh, 5 + 26 * sigh, 9 + 30 * sigh, 5 + 26 * sigh }
	-- arms: fists pumping down with each thump -> flung up -> drop
	local pump = copy(PUMP)
	pump[1] += -14 * lift + 10 * slamK
	pump[4] += 20 * slamK
	local a = mix(REST, pump, tant)
	a = mix(a, THROW, throw)
	a[3] += 6 * sigh
	S.armR = a
	local b = copy(a)
	b[1] += 10 * tant * wave(t, 3.3, 0.5)
	S.armL = b
	S.tailY = 30 * tant * wave(t, 6.6)
	S.pend = 10 * slamK - 6 * lift + 8 * throw
	S.orbY = -0.4 * sigh
	S.orbit = 20 * t
	rig(pose, ctx, S, t)
	for _, h in THUMPS do
		if ctx.crossed(h) then
			ctx.emit("StepDust", 9)
		end
	end
	if ctx.crossed(1.6) then
		ctx.emit("RageBurst", 14)
	end
end

------------------------------------------------------------------------
-- RETURN (1.2 s loop): cool shoulder-rolling swagger
------------------------------------------------------------------------
local RT_LEN, RT_SWEEP = 1.2, 1.8
local RT_SPEED = RT_SWEEP / (RT_LEN * 0.5) -- 3 studs/s
local function footCycle(ph)
	-- stance in [0, 0.5): planted, sliding back; swing in [0.5, 1)
	if ph < 0.5 then
		local q = ph / 0.5
		return -RT_SWEEP / 2 + RT_SWEEP * q, 0, 0
	end
	local q = (ph - 0.5) / 0.5
	local z = RT_SWEEP / 2 - RT_SWEEP * L.smoothstep(q)
	return z, 0.42 * sin(pi * q), track(q, { { 0, 0 }, { 0.3, -22, "quadOut" }, { 0.85, 8 }, { 1, 0 } })
end
local function ret(t, pose, ctx)
	local S = newS()
	local ph = (t % RT_LEN) / RT_LEN
	local zR, yR, pR = footCycle(ph)
	local zL, yL, pL = footCycle((ph + 0.5) % 1)
	S.footR = Vector3.new(0, yR, zR)
	S.footL = Vector3.new(0, yL, zL)
	S.pitchR, S.pitchL = pR, pL
	local step = wave(t, 1 / RT_LEN) -- + when the right foot is forward
	local bob = wave(t, 2 / RT_LEN, 0.25)
	S.hy = -0.12 + 0.1 * bob
	S.hry = -6 * step
	S.hrz = 4 * step
	S.hrx = 2
	-- chest counter-twist + big shoulder roll, leaning back (cool)
	S.crx = 5 + 2 * bob
	S.cry = 12 * step
	S.crz = -6 * step
	S.hdx = -5 * max(0, wave(t, 2 / RT_LEN, 0.1)) - 4
	S.hdyaw = -9 * step
	S.hdz = 4 * step
	S.jaw = -3
	S.browUp = 0.3
	local fl = wave(t, 2 / RT_LEN, -0.2)
	S.earX = { 4 + 8 * fl, 6 + 14 * fl, 4 + 8 * fl, 6 + 14 * fl }
	S.earOut = { 10 + 4 * step, 6 + 6 * step, 10 - 4 * step, 6 - 6 * step }
	-- arms: heavy swagger swing, opposite to the legs, swinging out wide
	local swingR = -26 * step
	S.armR = { swingR, 0, 16 + 4 * max(0, step), 18 + 10 * max(0, -step), 0, -6, 0, 0 }
	S.armL = { -swingR, 0, 16 + 4 * max(0, -step), 18 + 10 * max(0, step), 0, -6, 0, 0 }
	S.tailY = 18 * step
	S.pend = 4 * bob
	S.pendZ = -6 * step
	S.orbit = 0
	rig(pose, ctx, S, t)
	if ctx.crossed(0.02) or ctx.crossed(0.62) then
		ctx.emit("StepDust", 3)
	end
end

local M = {}
M.Props = {
	EyeWhiteR = 1, EyeWhiteL = 1, PupilR = 1, PupilL = 1,
	AngryMark1 = 1, AngryMark2 = 1, AngryMark3 = 1, AngryMark4 = 1,
	Rock1 = 1, Rock2 = 1, Rock3 = 1, Rock4 = 1,
}
M.States = {
	Idle = { Loop = true, Length = IDLE_LEN, Update = idle },
	Alert = { Length = 2.0, Update = alert },
	Chase = { Loop = true, Length = CH_LEN, Speed = CH_SPEED, Update = chase },
	Attack = { Length = 1.2, Update = attack },
	Catch = { Length = 2.2, Update = catch },
	GiveUp = { Length = 2.6, Update = giveup },
	Return = { Loop = true, Length = RT_LEN, Speed = RT_SPEED, Update = ret },
}
M.Base = "Idle"
M.Reel = { { "Idle" }, { "Alert" }, { "Chase", 3.6 }, { "Attack" }, { "Catch" }, { "Chase", 1.8 }, { "GiveUp" }, { "Return", 3.6 } }
return L.states(M)
