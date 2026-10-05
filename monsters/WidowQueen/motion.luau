--!nocheck
-- Widow Queen motion: bouncy idle (legs ripple around the body in a wave,
-- abdomen pulses and wiggles, fangs chitter, ripple blinks, crown wobble)
-- then the QUEEN'S AMBUSH: crouch -> rear up with the front 4 legs raised and
-- spread, fangs + jaw wide open, trembling -> fast lunge and strike down ->
-- legs splay on impact (red burst, dust, shock rings) -> elastic recover.
--
-- Planted feet: each femur's raise angle is solved (a tiny 1-DOF IK) so the
-- leg tips stay on the ground while the body bounces, rears and squashes.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, env = L.ang, L.pa, L.wave, L.env

local M = {}
M.Cycle = 9

local IMPACT = 5.0
-- strike debris: x / z offset from the strike point, pop height (build.luau)
local DEBRIS = {
	{ 1.6, -1.2, 3.2 }, { -1.8, -0.6, 2.6 }, { 0.6, 1.9, 3.6 },
	{ -0.9, 1.6, 2.4 }, { 2.3, 0.9, 3.0 }, { -2.4, -1.9, 3.4 },
}
local FLOOR = 0.1

------------------------------------------------------------------
-- Leg rest geometry (same numbers as build.luau, right side)
------------------------------------------------------------------
local BODY_REST = CFrame.new(0, 5, 0.3)
local LEGS = {
	{ z = -1.9, yaw = -44, knee = { 4.2, 10.2 }, ankle = { 8.9, 4.4 }, tip = { 11.0, 0.1 } },
	{ z = -0.5, yaw = -15, knee = { 4.0, 9.7 }, ankle = { 8.4, 4.1 }, tip = { 10.4, 0.1 } },
	{ z = 0.9, yaw = 16, knee = { 4.0, 9.5 }, ankle = { 8.4, 4.0 }, tip = { 10.4, 0.1 } },
	{ z = 2.3, yaw = 46, knee = { 4.2, 9.9 }, ankle = { 8.9, 4.2 }, tip = { 11.0, 0.1 } },
}
local LEGDATA = {}
for i, g in LEGS do
	local hip = Vector3.new(3.3, 5.3, g.z)
	local a = math.rad(g.yaw)
	local dir = Vector3.new(math.cos(a), 0, math.sin(a))
	local function lp(p)
		return Vector3.new(hip.X + dir.X * p[1], p[2], hip.Z + dir.Z * p[1])
	end
	local rot = CFrame.Angles(0, math.rad(-g.yaw), 0)
	local A = CFrame.new(hip) * rot
	local K = CFrame.new(lp(g.knee)) * rot
	local C = CFrame.new(lp(g.ankle)) * rot
	LEGDATA[i] = {
		cA = BODY_REST:Inverse() * A,
		cB = A:Inverse() * K,
		cC = K:Inverse() * C,
		tip = C:Inverse() * lp(g.tip),
		-- underside of the tip spike's base (lowest corner when the leg flattens)
		low = C:Inverse() * (lp(g.ankle):Lerp(lp(g.tip), 0.5) - Vector3.new(0, 0.6, 0)),
	}
end

-- head / jaw / fang rest frames (for keeping the face off the ground)
local HEAD_REST = CFrame.new(0, 6.6, -3.6)
local HEAD_C = BODY_REST:Inverse() * HEAD_REST
local FANG_REST = CFrame.new(3.3, 5.3, -8.6)
local FANG_C = HEAD_REST:Inverse() * FANG_REST
local FANG_TIP = FANG_REST:Inverse() * Vector3.new(1.7, 0.8, -10.1)
local JAW_REST = CFrame.new(0, 5.9, -5.0)
local JAW_C = HEAD_REST:Inverse() * JAW_REST
local JAW_PTS = {}
for _, sx in { -1, 1 } do
	table.insert(JAW_PTS, JAW_REST:Inverse() * Vector3.new(2.6 * sx, 4.15, -9.6))
	table.insert(JAW_PTS, JAW_REST:Inverse() * Vector3.new(2.2 * sx, 3.75, -9.0))
end

-- raise x until f(x) >= target (f increasing in x); Newton with numeric slope
local function liftTo(f, x, target, hi)
	for _ = 1, 5 do
		local y0 = f(x) - target
		if y0 >= -0.01 then
			break
		end
		local slope = (f(x + 2) - target - y0) / 2
		if slope < 0.01 then
			break
		end
		x = math.min(hi, x - y0 / slope)
	end
	return x
end

local function tipY(bodyW, d, ay, az, bz, cz)
	return (bodyW * d.cA * ang(0, ay, az) * d.cB * ang(0, 0, bz) * d.cC * ang(0, 0, cz) * d.tip).Y
end
local function lowY(bodyW, d, ay, az, bz, cz)
	local cfC = bodyW * d.cA * ang(0, ay, az) * d.cB * ang(0, 0, bz) * d.cC * ang(0, 0, cz)
	return math.min((cfC * d.tip).Y, (cfC * d.low).Y + 0.1)
end

-- femur raise (degrees) that puts the leg tip at height `target`
local function solveRaise(bodyW, d, ay, az, bz, cz, target)
	local z = az
	for _ = 1, 4 do
		local y0 = tipY(bodyW, d, ay, z, bz, cz) - target
		if math.abs(y0) < 0.02 then
			break
		end
		local slope = (tipY(bodyW, d, ay, z + 2, bz, cz) - target - y0) / 2
		if math.abs(slope) < 0.01 then
			break
		end
		z = math.clamp(z - y0 / slope, az - 70, az + 70)
	end
	return z
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- Signature move envelopes
	------------------------------------------------------------------
	local crouch = env(c, 3.0, 0.45, 0.05, 0.3, "cubicOut", "cubicIn")
	local rear = env(c, 3.5, 0.5, 0.6, 0.4, "backOut", "cubicIn")
	local coil = env(c, 4.5, 0.12, 0.05, 0.13, "quadOut", "quadIn") -- anticipation before the lunge
	local lunge = env(c, 4.75, 0.25, 0.95, 0.9, "cubicIn", "backOut")
	local impact = env(c, IMPACT, 0.06, 0.65, 0.9, "quadOut", "elasticOut")
	local shiver = env(c, 3.9, 0.15, 0.7, 0.1)
	local move = math.max(crouch, rear, lunge, impact)
	-- idle gag 2: "tap-tap" - front right foot taps the ground twice
	local tap = env(c, 6.95, 0.2, 0.85, 0.3, "backOut", "quadIn")
	local tapH = tap
	if c >= 7.15 and c <= 7.85 then
		tapH = tap * (0.5 + 0.5 * math.cos(2 * math.pi * (c - 7.15) / 0.35))
	end
	local idleW = 1 - move

	------------------------------------------------------------------
	-- Body (cephalothorax)
	------------------------------------------------------------------
	-- idle gags: a happy hop (squash -> air -> squash) and a butt wiggle
	local hopSquash = env(c, 0.7, 0.15, 0, 0.1, "quadOut", "quadIn")
	local hx = L.remap(c, 0.85, 1.4)
	local air = (c > 0.85 and c < 1.4) and math.sin(math.pi * hx) or 0
	local land = env(c, 1.4, 0.05, 0.05, 0.4, "quadOut", "elasticOut")
	local gag = math.max(hopSquash, air, land)
	local wig = env(c, 1.9, 0.15, 0.55, 0.2)
	local rippleW = idleW * (1 - gag)
	local bounce = L.bounce(t, 0.8) -- one bounce per leg-ripple half cycle
	local bob = (0.55 * bounce - 0.2) * rippleW - 0.7 * hopSquash + 2.8 * air - 0.9 * land
	local roll = 2 * wave(t, 0.8) * rippleW + 4 * wig * wave(t, 3.2, 0.25) - 4 * tap
	local yaw = 6 * L.noise(t, 2.3, 0.3) * idleW
	local tremble = shiver * wave(t, 13)
	local bodyY = bob - 1.0 * crouch + 3.5 * rear - 0.8 * coil - 1.4 * impact
	local bodyZ = -3.8 * lunge + 0.8 * crouch + 0.7 * coil
	local bodyP = -3 * crouch + 42 * rear + 8 * coil - 10 * lunge + 1.5 * tremble + 2 * wave(t, 1.6, 0.1) * rippleW + 8 * air * (1 - hx) - 6 * air * hx + 3 * land
	local bodyCF = pa(0.15 * tremble, bodyY, bodyZ, bodyP, yaw, roll + 1.5 * tremble)
	pose.Body = bodyCF

	------------------------------------------------------------------
	-- Head, jaw, brows, crown
	------------------------------------------------------------------
	-- cartoon head tilts on the blink beats (alternating sides)
	local cock = 0
	for i, k in { 0.3, 2.35, 8.1 } do
		cock += (i % 2 == 0 and -1 or 1) * env(c, k - 0.1, 0.15, 0.35, 0.3, "backOut", "sineInOut")
	end
	local look = 14 * L.noise(t, 4.1, 0.35) * idleW - 18 * tap
	local tilt = 9 * L.noise(t, 7.7, 0.3) * idleW + 14 * wig * wave(t, 1.6) + 12 * cock - 15 * tap
	pose.Head = ang(6 * wave(t, 1.6, 0.35) * rippleW + 10 * air - 8 * land - 12 * rear - 6 * coil + 9 * crouch + 12 * lunge + 8 * impact - 10 * tap, look + 5 * tremble, tilt)

	local chomp = math.max(0, wave(t, 0.37, 0.1)) ^ 10 * rippleW + 0.9 * air
	local jawOpen = L.track(c, {
		{ 3.55, 0 },
		{ 4.0, 1, "backOut" },
		{ 4.9, 0.85 },
		{ 4.97, 1.1, "quadOut" },
		{ IMPACT + 0.04, 0, "expoIn" },
		{ IMPACT + 0.2, 0.25, "quadOut" },
		{ IMPACT + 0.45, 0, "quadIn" },
	})
	local headCF = pose.Head
	local headW = BODY_REST * pose.Body * HEAD_C * headCF
	local jawA = liftTo(function(x)
		local jw = headW * JAW_C * ang(x, 0, 0)
		local m = math.huge
		for _, p in JAW_PTS do
			m = math.min(m, (jw * p).Y)
		end
		return m
	end, -22 * chomp - 55 * jawOpen + 4 * shiver * wave(t, 11), 0.2, 0)
	pose.Jaw = ang(jawA, 0, 0)

	local angry = math.max(rear, lunge)
	local smug = math.max(0, wave(t, 0.31, 0.6)) ^ 6 * idleW
	local browR = pa(0, -0.2 * angry + 0.3 * smug, 0, 0, 0, 16 * angry + 6 * crouch - 8 * smug)
	L.both(pose, "Brow", browR, pa(0, -0.2 * angry, 0, 0, 0, 16 * angry + 6 * crouch + 4 * smug))

	local crownWob = impact * wave(c - IMPACT, 3.2) + land * wave(c - 1.4, 3.5)
	pose.Crown = ang(-6 * wave(t, 1.6, 0.5) * idleW + 6 * tremble - 16 * crownWob + 12 * lunge * (1 - impact) - 8 * rear, 0, 6 * wave(t, 0.8, 0.3) * idleW + 10 * crownWob)

	------------------------------------------------------------------
	-- Fangs (chelicerae): chitter in idle, spread wide, then strike
	------------------------------------------------------------------
	local chitter = env(c, 6.9, 0.08, 0.6, 0.15) + env(c, 2.0, 0.08, 0.4, 0.15)
	local twitch = 10 * chitter * wave(t, 12)
	local fx = 45 * rear + 34 * lunge + 8 * impact + 34 * crouch * (1 - rear) + 4 * wave(t, 0.8) * idleW
	local fz = 38 * rear + 22 * air - 10 * impact + 6 * crouch + 4 * shiver * wave(t, 9)
	-- keep the fang tips above the ground (swing them forward if needed)
	local headWM = BODY_REST * L.mirror(pose.Body) * HEAD_C * L.mirror(headCF)
	local function fangFix(hw, z)
		return liftTo(function(x)
			return (hw * FANG_C * ang(x, 0, z) * FANG_TIP).Y
		end, fx, 0.2, fx + 80)
	end
	pose.FangR = ang(fangFix(headW, fz + twitch), 0, fz + twitch)
	pose.FangL = L.mirror(ang(fangFix(headWM, fz - twitch), 0, fz - twitch))

	------------------------------------------------------------------
	-- Abdomen: heartbeat pulse + butt wiggle, counters the body pitch
	------------------------------------------------------------------
	local pulse = math.max(0, wave(t, 1.0)) ^ 6
	local abWob = impact * wave(c - IMPACT, 2.4) + land * wave(c - 1.4, 2.6) - 0.8 * air
	pose.Abdomen = pa(0, 0.35 * pulse * idleW + 0.4 * rear, 0,
		-6 * pulse * idleW + 3 * wave(t, 0.8, 0.6) * idleW - 45 * rear + 6 * coil + 9 * lunge - 14 * abWob + 3 * crouch,
		10 * wave(t, 0.45) * rippleW + 24 * wig * wave(t, 3.2),
		4 * wave(t, 0.8, 0.25) * rippleW + 6 * abWob + 8 * wig * wave(t, 3.2, 0.2))

	------------------------------------------------------------------
	-- Legs: idle ripple wave travelling R1->R4->L4->L1, ambush poses,
	-- femurs solved so planted tips stay on the ground
	------------------------------------------------------------------
	local bodyW = BODY_REST * bodyCF
	local bodyWM = BODY_REST * L.mirror(bodyCF)
	for i = 1, 4 do
		local d = LEGDATA[i]
		local front = i <= 2
		local function legPose(k, bw)
			local ph = k / 8
			local lift = math.max(0, wave(t, 0.8, -ph)) ^ 2 * rippleW
			local ay = 12 * wave(t, 0.8, -ph + 0.25) * rippleW
			local az, bz, cz = 0, -18 * lift - 22 * air, -14 * lift - 18 * air
			local target = FLOOR + 3.2 * lift + 1.4 * air
			local free = 0
			local tapK = (k == 0) and tapH or 0
			if k == 0 then
				ay += 10 * tap
				bz += 18 * tapH
				cz -= 12 * tapH
			end
			if front then
				-- strike: legs stab down in front of the face as the body lunges
				local strike = lunge * (1 - rear)
				free = math.max(rear, strike * (1 - impact))
				local menace = 12 * shiver * wave(t, 2.6, k * 0.3)
				if i == 1 then
					az = 54 * rear + menace - 8 * strike
					ay += -6 * rear + 20 * strike
					bz += 66 * rear - 12 * strike
					cz += 30 * rear - 16 * strike
				else
					az = 42 * rear + menace - 6 * strike
					ay += -16 * rear + 10 * strike
					bz += 50 * rear - 8 * strike
					cz += 22 * rear - 12 * strike
				end
			else
				bz += 10 * rear + 6 * lunge
				ay += (i == 3 and -4 or -12) * lunge
			end
			-- splay on impact: tibias flatten, femurs drop (solved), body squashes
			bz += 24 * impact
			cz += 10 * impact - 6 * crouch
			bz += 6 * crouch
			local solved = solveRaise(bw, d, ay, az, bz, cz, target) + 30 * tapK
			az = L.lerp(solved, az, free)
			az = liftTo(function(x)
				return lowY(bw, d, ay, x, bz, cz)
			end, az, FLOOR, az + 70)
			return ang(0, ay, az), ang(0, 0, bz), ang(0, 0, cz)
		end
		local aR, bR, cR = legPose(i - 1, bodyW)
		local aL, bL, cL = legPose(8 - i, bodyWM)
		L.both(pose, "Leg" .. i .. "A", aR, aL)
		L.both(pose, "Leg" .. i .. "B", bR, bL)
		L.both(pose, "Leg" .. i .. "C", cR, cL)
	end

	------------------------------------------------------------------
	-- Orbiting voxel cubes
	------------------------------------------------------------------
	pose.Orbit = ang(0, 28 * t, 0)
	local spots = { { 10.5, 1 }, { -9.5, 6 }, { 6.5, 11 }, { -8.0, -6 }, { 4.0, -9 }, { -6.0, 13 }, { 11.0, 7 } }
	for i, p in spots do
		local dx, dz = p[1], p[2] - 3
		local m = math.sqrt(dx * dx + dz * dz)
		local push = 2.6 * impact + 0.8 * rear
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(dx / m * push, 1.0 * wave(t, 0.42 + 0.06 * i, i * 0.21) + 1.2 * rear + 1.5 * impact, dz / m * push, 70 * t * dir, 95 * t, 35)
	end

	------------------------------------------------------------------
	-- Eyes: ripple blink (lateral -> main -> medium -> small)
	------------------------------------------------------------------
	local BLINKS = { 0.35, 2.4, 6.95, 8.15 }
	local wide = math.max(rear, lunge) > 0.05
	local function shut(a, b)
		if wide then
			return false
		end
		for _, k in BLINKS do
			if c > k + a and c < k + b then
				return true
			end
		end
		return false
	end
	local mainShut = shut(0, 0.14)
	for _, s in { "R", "L" } do
		ctx.transparency("Eye" .. s, mainShut and 1 or 0)
		ctx.transparency("Pupil" .. s, mainShut and 1 or 0)
		ctx.transparency("Shut" .. s, mainShut and 0 or 1)
		ctx.transparency("EyeL" .. s, shut(-0.07, 0.05) and 0.85 or 0)
		ctx.transparency("EyeM" .. s, shut(0.07, 0.19) and 0.85 or 0)
		ctx.transparency("EyeS" .. s, shut(0.12, 0.24) and 0.85 or 0)
	end

	------------------------------------------------------------------
	-- Effects
	------------------------------------------------------------------
	-- voxel shock rings: each segment bone slides outward from the strike point
	local rx = L.remap(c, IMPACT, IMPACT + 0.5)
	local dist = 4.8 * L.ease.quadOut(rx)
	local ringOn = c >= IMPACT and c < IMPACT + 0.5
	local ringBOn = c >= IMPACT + 0.04 and c < IMPACT + 0.55
	local trA = ringOn and (0.05 + 0.9 * rx * rx) or 1
	local trB = ringBOn and (0.1 + 0.9 * L.remap(c, IMPACT + 0.04, IMPACT + 0.55) ^ 2) or 1
	for k = 1, 10 do
		local a = math.rad((k - 1) * 36)
		pose["Wave" .. k] = CFrame.new(-math.sin(a) * dist, 0.5 * math.sin(math.pi * rx), -math.cos(a) * dist)
		ctx.transparency("RingA_" .. k, trA)
		ctx.transparency("RingN_" .. k, trA)
		ctx.transparency("RingB_" .. k, trB)
	end
	-- ground flash
	local fl = L.remap(c, IMPACT, IMPACT + 0.25)
	ctx.transparency("FlashCore", (c >= IMPACT and c < IMPACT + 0.25) and (0.15 + 0.85 * fl) or 1)
	local fl2 = L.remap(c, IMPACT, IMPACT + 0.4)
	ctx.transparency("Flash", (c >= IMPACT and c < IMPACT + 0.4) and (0.3 + 0.7 * fl2) or 1)
	-- debris blocks pop up, fly outward and tumble, then land and vanish
	for i, d in DEBRIS do
		local t0 = IMPACT + 0.015 * i
		local x = L.remap(c, t0, t0 + 0.8)
		local on = c >= t0 and c < t0 + 0.8
		local m = math.sqrt(d[1] * d[1] + d[2] * d[2])
		local out = 3.2 * L.ease.quadOut(x)
		local up = d[3] * 4 * x * (1 - x)
		local sg = i % 2 == 0 and -1 or 1
		pose["Debris" .. i] = CFrame.new(d[1] / m * out, up, d[2] / m * out) * ang(420 * x * sg, 300 * x, 240 * x * sg)
		ctx.transparency("Debris" .. i, on and 0 or 1)
	end
	local flash = env(c, IMPACT - 0.02, 0.04, 0.08, 0.45)
	ctx.light("StrikeLight", 1.5 * flash)
	ctx.light("FaceLight", 1.0 * rear)
	ctx.enable("RageEmbers", rear > 0.5)
	if ctx.crossed(IMPACT) then
		ctx.emit("AmbushBurst", 65)
		ctx.emit("AmbushDust", 30)
	end
	if ctx.crossed(1.4) then
		ctx.emit("SplayDust", 14)
	end
	if ctx.crossed(IMPACT + 0.03) then
		ctx.emit("SplayDust", 28)
	end
end

return M
