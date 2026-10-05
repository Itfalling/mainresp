--!nocheck
-- Amethyst Golem motion: heavy gorilla waddle idle (weight shifts, stompy feet,
-- alternating knuckle thumps with fist clenches, head bobs, blinks) then
-- CRYSTAL QUAKE: hop + lean back with both fists raised overhead (charging
-- sparks) -> double fist SLAM into the ground (body squashes 2 studs, fists stay
-- planted via IK) -> dust, purple sparkle burst, glowing ground cracks, crystal
-- spikes erupt, rocks fly, orbiting cubes fling outward -> ROAR with head shake
-- -> spring back up and settle.
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave
local rad, deg = math.rad, math.deg

local M = {}
M.Cycle = 8

local IMPACT = 4.62
local LEG = 4.2 -- hip -> ankle length (thigh 2.1 + shin 2.1)

-- rest pivots (model space, right side) used by the arm IK
local H0 = Vector3.new(0, 6.4, 1.2)
local C0 = Vector3.new(0, 7.8, 1.2)
local S0 = Vector3.new(5.6, 13.8, 0.8)
local E0 = Vector3.new(7.7, 9.3, 1.2)
local W0 = Vector3.new(8.5, 4.7, -1.4)
local T_IDLE = Vector3.new(8.7, 4.45, -1.7) -- wrist target: knuckles planted at idle
local T_SLAM = Vector3.new(9.2, 4.55, -6.3) -- wrist target: fists smashed into the floor

-- orbiting cube rest offsets relative to the Orbit pivot (0, 10, 1)
local ORBS = { { 12.5, -2.0 }, { -12.0, 1.5 }, { 7.0, 9.0 }, { -8.0, -8.0 } }

-- debris cube launch velocities (right side; left is mirrored)
local DEBRIS = { { 6, 15, -4 }, { 3, 12, 5 } }
-- idle knuckle-thump landing times inside the loop (left / right fist)
local THUMPS_L = { 0.42, 2.42, 6.42 }
local THUMPS_R = { 1.42, 7.42 }

local SPIKE_NAMES = {}
for _, side in { "R", "L" } do
	for n = 1, 3 do
		for k = 1, 4 do
			table.insert(SPIKE_NAMES, "Spike" .. side .. n .. "_" .. k)
		end
	end
end
local CRACK_NAMES = {}
for _, side in { "R", "L" } do
	for i = 1, 3 do
		for j = 1, 2 do
			table.insert(CRACK_NAMES, "Crack" .. side .. i .. j)
		end
	end
end

local function wrap(x)
	while x > math.pi do x -= 2 * math.pi end
	while x < -math.pi do x += 2 * math.pi end
	return x
end

-- knee angle (deg) that shortens a straight leg by `drop` studs
local function bend(drop)
	return deg(math.acos(math.clamp(1 - math.max(0, drop) / LEG, -1, 1)))
end

-- 2-bone arm IK. Arm pose = Rz(roll) * Rx(a), forearm pose = Rx(b) (right-side
-- frame; the left side is mirrored). Returns a, b, roll (degrees) so the wrist
-- pivot lands on `target` (world, given for the right side).
local function armIK(chestW, s, target)
	local S = Vector3.new(S0.X * s, S0.Y, S0.Z)
	local e, f = E0 - S0, W0 - E0
	local tl = (chestW * CFrame.new(S - C0)):PointToObjectSpace(Vector3.new(target.X * s, target.Y, target.Z))
	local tx, ty, tz = tl.X * s, tl.Y, tl.Z
	local ox = e.X + f.X -- sideways offset of the wrist (constant under pitch)
	local le = math.sqrt(e.Y * e.Y + e.Z * e.Z)
	local lf = math.sqrt(f.Y * f.Y + f.Z * f.Z)
	local D = math.sqrt(math.max(0, tx * tx + ty * ty + tz * tz - ox * ox))
	D = math.clamp(D, math.abs(le - lf) + 0.01, le + lf - 0.01)
	local k = math.clamp((D * D - le * le - lf * lf) / (2 * le * lf), -1, 1)
	local ae, af = math.atan2(e.Z, e.Y), math.atan2(f.Z, f.Y)
	local b = wrap(math.acos(k) - wrap(af - ae))
	local cb, sb = math.cos(b), math.sin(b)
	local wy0 = e.Y + f.Y * cb - f.Z * sb
	local wz0 = e.Z + f.Y * sb + f.Z * cb
	local wz = math.clamp(tz, -D, D)
	local wy = -math.sqrt(math.max(0, D * D - wz * wz))
	local a = wrap(math.atan2(wz, wy) - math.atan2(wz0, wy0))
	local r = wrap(math.atan2(ty, tx) - math.atan2(wy, ox))
	return deg(a), deg(b), deg(r)
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- signature move tracks
	------------------------------------------------------------------
	local raise = L.track(c, { { 3.0, 0 }, { 3.9, 1, "backOut" }, { 4.42, 1.06, "sineInOut" }, { IMPACT, 0, "quadIn" } })
	local slam = L.track(c, { { 4.42, 0 }, { IMPACT, 1, "quadIn" }, { 5.5, 1 }, { 6.4, 0, "cubicInOut" } })
	local squash = L.env(c, IMPACT, 0.05, 0.12, 1.0, "quadOut", "elasticOut")
	local roar = L.env(c, 4.78, 0.22, 0.55, 0.45, "backOut", "cubicInOut")
	local shake = L.env(c, 4.85, 0.1, 0.55, 0.3)
	local fling = L.track(c, { { IMPACT, 0 }, { IMPACT + 0.3, 1, "expoOut" }, { 5.7, 1 }, { 6.6, -0.12, "cubicInOut" }, { 7.0, 0, "sineInOut" } })
	local crouch = L.env(c, 2.7, 0.3, 0.05, 0.22, "quadOut", "quadIn") -- anticipation dip before the leap
	local busy = L.clamp01(math.max(raise, slam, crouch))
	local idleW = 1 - busy
	local dt = c - IMPACT

	------------------------------------------------------------------
	-- idle rhythm: heavy waddle with alternating fist + foot thumps
	------------------------------------------------------------------
	local ti = t + 0.5 -- idle rhythm phase (puts a lifted fist on every whole second)
	local sway = wave(ti, 0.5) * idleW -- + = weight on the right leg (left side lifts)
	local ph = ti % 2
	local liftL = L.env(ph, 0.1, 0.42, 0.12, 0.28, "cubicOut", "quadIn") * idleW
	local liftR = L.env((ti + 1) % 2, 0.1, 0.42, 0.12, 0.28, "cubicOut", "quadIn") * idleW
	local thump = (L.env(ph, 0.92, 0.04, 0.02, 0.4, "linear", "cubicOut") + L.env((ti + 1) % 2, 0.92, 0.04, 0.02, 0.4, "linear", "cubicOut")) * idleW
	local breathe = wave(t, 0.4)
	local rumble = L.noise(t, 3.3, 7) * (0.8 + 2.5 * shake + 1.6 * L.clamp01(raise))

	------------------------------------------------------------------
	-- HIPS + LEGS (simple IK keeps planted feet flat on the floor)
	------------------------------------------------------------------
	local hipY = -0.5 + 0.3 * math.abs(sway) - 0.45 * thump + 1.1 * raise - 1.55 * slam - 0.65 * squash - 0.9 * crouch
	local hipX = -8 * slam - 4 * squash + 4 * raise
	local hipYaw = 4 * sway
	local hipZ = -7 * sway
	pose.Hips = pa(0, hipY, 0, hipX, hipYaw, hipZ)

	local hipsInv = ang(hipX, hipYaw, hipZ):Inverse()
	local function legPose(side, lift)
		local s = side == "R" and 1 or -1
		local off = hipY + s * 2.8 * math.sin(rad(hipZ))
		local th = bend(-off + 2.1 * lift)
		-- feet dangle toes-down only as far as the hop clearance allows
		local toeDown = math.min(18, deg(math.max(0, off) / 3.9)) * L.clamp01(raise)
		pose["Thigh" .. side] = hipsInv * ang(th, 0, 0)
		pose["Shin" .. side] = ang(-2 * th, 0, 0)
		pose["Foot" .. side] = ang(th - toeDown + 10 * lift, 0, 0)
	end
	legPose("R", liftR)
	legPose("L", liftL)

	------------------------------------------------------------------
	-- CHEST: breathing + rumble, lean back on the raise, slam forward
	------------------------------------------------------------------
	local chestX = 2.5 * breathe + rumble + 3 * thump + 22 * raise - 16 * slam - 7 * squash + 8 * roar - 8 * crouch
	local chestPose = ang(chestX, -12 * sway + 1.2 * rumble * shake, 4 * sway)
	pose.Chest = chestPose

	-- crystal mane wobbles (follow-through after every impact)
	local wob = 0
	if dt > 0 and dt < 2 then
		wob = 12 * math.exp(-3 * dt) * math.sin(dt * 2 * math.pi * 3.2)
	end
	pose.BackCrystals = ang(wob + 1.5 * wave(t, 0.5, 0.3) - 7 * raise + 3 * thump, 0, 0.8 * wob)

	------------------------------------------------------------------
	-- HEAD + JAW + LIDS
	------------------------------------------------------------------
	local look = L.noise(t, 7.7, 0.35) * 22 * idleW
	local shakeYaw = 14 * shake * wave(t, 6)
	local headX = 3 * breathe - 12 * thump + 18 * raise + 18 * slam - 10 * squash + 18 * roar - 6 * crouch
	pose.Head = ang(headX, look + shakeYaw + 6 * sway, 5 * L.noise(t, 2.1, 0.4) * idleW + 6 * shake * wave(t, 3) - 4 * sway)

	local chomp = math.max(0, wave(t, 0.37, 0.2)) ^ 6 * idleW
	pose.Jaw = ang(-10 - 14 * chomp + 6 * thump - 26 * raise - 10 * slam - 50 * roar + 6 * shake * wave(t, 11), 0, 0)

	local blink = L.env(t % 3.1, 2.75, 0.06, 0.06, 0.1)
	local squint = 0.5 * L.clamp01(raise)
	L.both(pose, "Lid", CFrame.new(0, -1.35 * math.max(blink, squint) * (1 - roar), 0))

	------------------------------------------------------------------
	-- ARMS: knuckle thumps -> fists overhead -> SLAM (IK keeps fists planted)
	------------------------------------------------------------------
	local hipsW = CFrame.new(H0) * pose.Hips
	local chestW = hipsW * CFrame.new(C0 - H0) * chestPose
	local rw = L.clamp01(raise)
	local rec = c > 5.5 and math.sin(math.pi * slam) or 0
	local function arm(side, s, lift, open)
		-- IK target: planted knuckles (lifted for the thumps) -> slam point (arc on recovery)
		local target = T_IDLE:Lerp(T_SLAM, slam) + Vector3.new(0.4 * lift, 3.4 * lift + 3.2 * rec, -1.0 * lift)
		local aI, bI, rI = armIK(chestW, s, target)
		-- raise = forward kinematics, fists high overhead (trembling while charging)
		local shiver = 3 * rw * wave(t, 13, s * 0.25)
		local a = L.lerp(aI, 152, rw) + 40 * (raise - rw) + shiver
		local b = L.lerp(bI, 8, rw)
		local roll = L.lerp(rI, 10, rw)
		local fistIK = -(hipX + chestX + aI + bI) - 4 + 10 * lift
		local fistX = L.lerp(fistIK, 30, rw)
		pose["Arm" .. side] = CFrame.Angles(0, 0, rad(roll * s)) * CFrame.Angles(rad(a), 0, 0)
		pose["Forearm" .. side] = ang(b, 0, 0)
		pose["Fist" .. side] = ang(fistX, 0, s * 2 * raise * wave(t, 18))
		pose["Fingers" .. side] = ang(55 * open, 0, 0)
	end
	arm("R", 1, liftR, liftR)
	arm("L", -1, liftL, liftL)

	------------------------------------------------------------------
	-- ORBITING CUBES: slow orbit, bob + tumble; flung outward by the quake
	------------------------------------------------------------------
	pose.Orbit = ang(0, 26 * t, 0)
	for i, o in ORBS do
		local len = math.sqrt(o[1] * o[1] + o[2] * o[2])
		local out = 5 * fling
		local bobY = 0.7 * wave(t, 0.55, i * 0.21) + 2.2 * fling
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(o[1] / len * out, bobY, o[2] / len * out, 70 * t * dir + 360 * fling, 90 * t, 25 * dir)
	end

	------------------------------------------------------------------
	-- QUAKE FX: spikes erupt, cracks glow then fade, debris flies
	------------------------------------------------------------------
	local rise = L.track(c, { { IMPACT, 0 }, { IMPACT + 0.22, 1, "backOut" }, { 5.7, 1 }, { 6.25, 0, "quadIn" } })
	pose.Spikes = CFrame.new(0, -5 * (1 - rise), 0)
	local spikeTr = rise > 0.03 and 0 or 1
	for _, n in SPIKE_NAMES do
		ctx.transparency(n, spikeTr)
	end
	local crackTr = 1
	if dt >= 0 and dt < 1.8 then
		crackTr = 0.15 + 0.85 * L.remap(dt, 0.5, 1.8)
	end
	for _, n in CRACK_NAMES do
		ctx.transparency(n, crackTr)
	end

	for i, d in DEBRIS do
		local cfR = CFrame.new()
		local tr = 1
		if dt >= 0 and dt < 0.72 then
			cfR = pa(d[1] * dt, d[2] * dt - 20 * dt * dt, d[3] * dt, 720 * dt, 400 * dt, 300 * dt)
			tr = 0
		end
		pose["DebrisR" .. i] = cfR
		pose["DebrisL" .. i] = L.mirror(cfR)
		ctx.transparency("DebrisCubeR" .. i, tr)
		ctx.transparency("DebrisCubeL" .. i, tr)
	end

	local flash = L.env(c, IMPACT, 0.04, 0.12, 0.7)
	ctx.light("QuakeLight", 1.5 * flash)
	ctx.light("CoreLight", 0.45 + 0.15 * wave(t, 0.8) + 0.8 * L.clamp01(raise))
	ctx.enable("CoreCharge", c > 3.4 and c < IMPACT)
	if ctx.crossed(IMPACT) then
		ctx.emit("QuakeDust", 40)
		ctx.emit("QuakeBurst", 55)
		ctx.emit("QuakeRocks", 24)
		ctx.emit("ThumpDustR", 14)
		ctx.emit("ThumpDustL", 14)
	end
	-- little dust puffs on the idle knuckle thumps
	for _, at in THUMPS_L do
		if ctx.crossed(at) then ctx.emit("ThumpDustL", 6) end
	end
	for _, at in THUMPS_R do
		if ctx.crossed(at) then ctx.emit("ThumpDustR", 6) end
	end
end

return M
