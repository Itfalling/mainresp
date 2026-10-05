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
local FANG_TIP = FANG_REST:Inverse() * Vector3.new(2.3, 0.6, -9.6)
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
	local rear = env(c, 3.5, 0.5, 0.75, 0.22, "backOut", "expoIn")
	local lunge = env(c, 4.75, 0.25, 0.95, 0.9, "cubicIn", "backOut")
	local impact = env(c, IMPACT, 0.06, 0.65, 0.9, "quadOut", "elasticOut")
	local shiver = env(c, 3.9, 0.15, 0.7, 0.1)
	local move = math.max(crouch, rear, lunge, impact)
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
	local roll = 2 * wave(t, 0.8) * rippleW + 4 * wig * wave(t, 3.2, 0.25)
	local yaw = 6 * L.noise(t, 2.3, 0.3) * idleW
	local tremble = shiver * wave(t, 13)
	local bodyY = bob - 1.0 * crouch + 2.8 * rear - 1.3 * impact
	local bodyZ = -3.6 * lunge + 0.8 * crouch
	local bodyP = -3 * crouch + 32 * rear - 9 * lunge + 1.5 * tremble + 2 * wave(t, 1.6, 0.1) * rippleW + 8 * air * (1 - hx) - 6 * air * hx + 3 * land
	local bodyCF = pa(0.15 * tremble, bodyY, bodyZ, bodyP, yaw, roll + 1.5 * tremble)
	pose.Body = bodyCF

	------------------------------------------------------------------
	-- Head, jaw, brows, crown
	------------------------------------------------------------------
	local look = 14 * L.noise(t, 4.1, 0.35) * idleW
	local tilt = 9 * L.noise(t, 7.7, 0.3) * idleW + 14 * wig * wave(t, 1.6)
	pose.Head = ang(3 * wave(t, 1.6, 0.35) * rippleW + 10 * air - 8 * land - 10 * rear + 9 * crouch + 10 * lunge + 8 * impact, look + 5 * tremble, tilt)

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
		-6 * pulse * idleW + 3 * wave(t, 0.8, 0.6) * idleW - 38 * rear + 9 * lunge - 14 * abWob + 3 * crouch,
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
			local ay = 8 * wave(t, 0.8, -ph + 0.25) * rippleW
			local az, bz, cz = 0, -12 * lift - 22 * air, -10 * lift - 18 * air
			local target = FLOOR + 2.4 * lift + 1.4 * air
			local free = 0
			if front then
				free = rear
				local menace = 10 * shiver * wave(t, 2.6, k * 0.3)
				if i == 1 then
					az = 50 * rear + menace
					ay += -6 * rear + 14 * lunge
					bz += 64 * rear + 10 * lunge
					cz += 30 * rear
				else
					az = 38 * rear + menace
					ay += -16 * rear + 6 * lunge
					bz += 48 * rear + 8 * lunge
					cz += 22 * rear
				end
			else
				bz += 10 * rear + 6 * lunge
				ay += (i == 3 and -4 or -12) * lunge
			end
			-- splay on impact: tibias flatten, femurs drop (solved), body squashes
			bz += 24 * impact
			cz += 10 * impact - 6 * crouch
			bz += 6 * crouch
			local solved = solveRaise(bw, d, ay, az, bz, cz, target)
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
	local spots = { { 10.5, 1 }, { -9.5, 6 }, { 6.5, 11 }, { -8.0, -6 }, { 4.0, -9 } }
	for i, p in spots do
		local dx, dz = p[1], p[2] - 3
		local m = math.sqrt(dx * dx + dz * dz)
		local push = 2.6 * impact + 0.8 * rear
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(dx / m * push, 0.7 * wave(t, 0.5, i * 0.21) + 1.2 * rear, dz / m * push, 70 * t * dir, 95 * t, 35)
	end
	pose.Shock = ang(0, 40 * c, 0)

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
	local r1 = L.remap(c, IMPACT, IMPACT + 0.4)
	local r2 = L.remap(c, IMPACT + 0.08, IMPACT + 0.6)
	local on1 = c >= IMPACT and c < IMPACT + 0.4
	local on2 = c >= IMPACT + 0.08 and c < IMPACT + 0.6
	for k = 1, 8 do
		ctx.transparency("Shock1_" .. k, on1 and (0.15 + 0.85 * r1) or 1)
	end
	for k = 1, 10 do
		ctx.transparency("Shock2_" .. k, on2 and (0.2 + 0.8 * r2) or 1)
	end
	local flash = env(c, IMPACT - 0.02, 0.04, 0.08, 0.45)
	ctx.light("StrikeLight", 1.5 * flash)
	ctx.light("FaceLight", 1.0 * rear)
	ctx.enable("RageEmbers", rear > 0.5)
	if ctx.crossed(IMPACT) then
		ctx.emit("AmbushBurst", 45)
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
