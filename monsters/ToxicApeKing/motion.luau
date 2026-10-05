--!nocheck
-- Toxic Ape King motion.
-- Idle: heavy huffing breaths, knuckle shuffle (fists lift + plant with a
-- body sway), head looking around, bouncy crown, blinks, drooly chomps.
-- Signature "KING'S FURY": crouch -> REAR UP (body pitches back ~38 deg) ->
-- 4 fast alternating CHEST POUNDS -> ROAR with a double-bicep flex and a
-- toxic breath cloud -> fists raised over the head -> small LEAP ->
-- DOUBLE-FIST GROUND SLAM (body drops, green burst, dust, voxel shockwave)
-- -> elastic settle back into the knuckle stance.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, track = L.ang, L.pa, L.wave, L.track

local M = {}
M.Cycle = 8

-- rest pivots (right side) used for the little fist-planting IK
local HIPS_P = Vector3.new(0, 6.0, 3.4)
local CHEST_P = Vector3.new(0, 7.6, 1.6)
local ARM_P = Vector3.new(4.6, 11.4, -0.8)
local FORE_P = Vector3.new(5.8, 6.8, -1.4)
local FIST_P = Vector3.new(6.0, 2.6, -1.8)
local FIST_BOTTOM = { Vector3.new(-1.7, -2.55, -2.1), Vector3.new(1.7, -2.55, -2.1), Vector3.new(-1.7, -2.55, 1.5), Vector3.new(1.7, -2.55, 1.5) }

-- arm key poses (right side; left mirrors): {armX, armY, armZ, foreX, foreY, foreZ, fistX, fistZ}
local COCK = { 75, 0, 55, 120, 0, -70, -20, 0 } -- fist pulled up/out, elbow high
local HIT = { 50, 0, 25, 110, 0, -80, -10, 0 } -- fist on the pec
local FLEX = { -15, 0, 85, 0, 0, 100, 0, 0 } -- double-bicep flex
local OVER = { 125, -35, -15, 0, 0, -10, -40, 0 } -- fists clasped high over the head
local SLAM = { 25, 30, 25, 40, 0, -30, -40, -5 } -- fists smashed into the ground

local function mix(a, b, k)
	local o = {}
	for i = 1, 8 do
		o[i] = a[i] + (b[i] - a[i]) * k
	end
	return o
end

-- alternating pound pulse (1 = fist on the chest)
local function beat(c, hits)
	local k = 0
	for _, h in hits do
		k = math.max(k, L.env(c, h - 0.13, 0.13, 0.03, 0.14, "quadIn", "quadOut"))
	end
	return k
end

-- 2-bone leg: knees bend so the foot stays planted when the hip drops by `drop`
local function leg(drop, tuck, hipPitch, roll, yaw)
	local d = math.clamp(drop, 0, 2.4)
	local r = 0
	for _ = 1, 4 do -- solve 4.7 cos a + 0.4 sin a = 4.7 - d
		r = math.acos(math.clamp((4.7 - d - 0.4 * math.sin(r)) / 4.7, -1, 1))
	end
	local a = math.deg(r)
	return ang(a + 35 * tuck - hipPitch, -yaw, -roll), ang(-2 * a - 60 * tuck, 0, 0), ang(a + 25 * tuck, 0, 0)
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- signature phases ---------------------------------------------------
	local pound = track(c, { { 2.0, 0 }, { 2.25, 1, "cubicOut" }, { 3.45, 1 }, { 3.7, 0, "quadInOut" } })
	local flex = track(c, { { 3.45, 0 }, { 3.75, 1, "backOut" }, { 4.55, 1 }, { 4.85, 0, "quadInOut" } })
	local over = track(c, { { 4.55, 0 }, { 4.95, 1, "backOut" }, { 5.4, 1 }, { 5.6, 0, "quadIn" } })
	local slam = track(c, { { 5.4, 0 }, { 5.6, 1, "quadIn" }, { 6.05, 1 }, { 6.9, 0, "cubicInOut" } })
	local slamPlant = track(c, { { 5.5, 0 }, { 5.6, 1 }, { 6.1, 1 }, { 6.6, 0 } })

	-- chest pitch: crouch forward -> REAR back -> roar lean -> arch -> SLAM forward
	local chestX = track(c, {
		{ 1.45, 0 }, { 1.8, -10, "quadOut" }, { 2.15, 38, "backOut" }, { 3.45, 38 },
		{ 3.75, 20, "backOut" }, { 4.55, 20 }, { 4.95, 32, "quadOut" }, { 5.4, 42, "quadOut" },
		{ 5.6, -14, "quadIn" }, { 6.05, -11 }, { 6.9, 0, "backOut" },
	})
	-- hips height: crouch -> rise -> crouch -> LEAP -> squash -> spring back
	local hipY = track(c, {
		{ 1.45, 0 }, { 1.8, -0.9, "quadOut" }, { 2.15, 0.2, "backOut" }, { 4.55, 0.2 },
		{ 4.95, -1.0, "quadOut" }, { 5.3, 2.8, "quadOut" }, { 5.6, -1.4, "quadIn" }, { 6.05, -1.0 },
		{ 6.9, 0, "elasticOut" },
	})
	local hipX = track(c, { { 1.45, 0 }, { 2.15, 6, "backOut" }, { 4.55, 6 }, { 5.3, 10 }, { 5.6, -6, "quadIn" }, { 6.9, 0, "backOut" } })
	local leap = L.env(c, 4.95, 0.35, 0.0, 0.3, "quadOut", "quadIn") -- legs tuck in the air
	local impact = L.env(c, 5.6, 0.04, 0.1, 0.9, "linear", "elasticOut")
	local roar = L.env(c, 3.6, 0.2, 0.85, 0.3, "backOut", "cubicInOut")
	local shake = L.env(c, 3.75, 0.1, 0.75, 0.2)
	local sig = math.max(pound, flex, over, slam, L.env(c, 1.45, 0.35, 0, 0.2))
	local idleW = 1 - L.clamp01(math.max(sig, math.abs(chestX) / 15, math.abs(hipY) / 0.6))
	local groundW = 1 - math.max(pound, flex, over, slam)

	-- idle layers --------------------------------------------------------
	local breathe = wave(t, 0.55) -- heavy huffing
	local huff = math.max(0, wave(t, 0.55, 0.1)) ^ 3
	local step = wave(t, 0.6) -- knuckle shuffle: lift right / left fist
	local liftR = math.max(0, step) ^ 2 * idleW
	local liftL = math.max(0, -step) ^ 2 * idleW
	local bob = (1 - math.abs(step)) ^ 2 * idleW -- bounce up between fist plants

	-- HIPS: bob, sway into the shuffle, rear / leap / squash
	local hipYaw, hipRoll = 4 * step * idleW, -3 * step * idleW
	local hy = hipY + idleW * (0.4 * math.abs(step) ^ 1.5 - 0.25) -- rise as a fist lifts, drop on the plant
	local hipsT = pa(0.35 * step * idleW, hy, 0, hipX, hipYaw, hipRoll)
	pose.Hips = hipsT

	-- CHEST: heaving breath + shuffle twist + pound recoil + roar rumble
	local poundR = beat(c, { 2.4, 3.0 }) * pound
	local poundL = beat(c, { 2.7, 3.3 }) * pound
	local recoil = 4 * (poundR + poundL)
	local rumble = 2.5 * shake * wave(t, 9)
	local chestPitch = chestX + 3 * breathe * idleW + 2 * huff * idleW + recoil + rumble
	local chestT = pa(0, 0.15 * breathe * idleW, 0, chestPitch, -7 * step * idleW + 7 * (poundR - poundL), 6 * step * idleW + 4 * (poundL - poundR))
	pose.Chest = chestT

	-- HEAD: looks around in idle; held high while pounding; roars at you
	local look = L.noise(t, 3.7, 0.3) * 30 * idleW
	local nod = L.noise(t, 8.2, 0.45) * 8 * idleW
	local shakeYaw = 16 * shake * wave(t, 5)
	local headX = -chestX * 0.7 + nod - 4 * breathe * idleW + 6 * (poundR + poundL)
		- 14 * roar - 22 * over + 10 * impact + 4 * leap
	-- cartoon neck stretch: the head rises above the chest while pounding / roaring
	local headUp = 4.5 * pound + 2.2 * flex
	local headBack = 1.0 * pound + 0.3 * flex - 1.6 * over
	pose.Head = pa(0, headUp, headBack, headX, look + shakeYaw, 5 * L.noise(t, 2.2, 0.4) * idleW + 6 * shake * wave(t, 2.5) - 4 * (poundR - poundL))

	-- JAW: always a little open (angry), huffs, chomps; WIDE on the roar
	local chomp = math.max(0, wave(t, 0.37, 0.2)) ^ 10 * idleW
	pose.Jaw = ang(-20 - 10 * huff * idleW - 14 * chomp + 12 * chomp * wave(t, 6) - 48 * roar
		- 18 * pound * (0.5 + 0.5 * (poundR + poundL)) - 25 * impact + 4 * shake * wave(t, 11), 0, 0)

	-- CROWN: bounces on every beat, flies up on the slam then clanks back down
	local crownPop = 0.35 * bob + 0.5 * (poundR + poundL) + 1.4 * L.env(c, 5.6, 0.08, 0.05, 0.6, "quadOut", "bounceOut")
		+ 0.5 * L.env(c, 2.0, 0.12, 0, 0.4, "quadOut", "bounceOut")
	pose.Crown = pa(0, crownPop, 0, 0, 0, 6 * L.noise(t, 5.5, 0.6) * idleW + 10 * shake * wave(t, 5, 0.25) - 8 * (poundR - poundL))

	-- blinks (lids drop over the eyes); squeeze during the slam impact
	local blink = math.max(L.env(t % 3.1, 2.7, 0.06, 0.06, 0.1), L.env(t % 7.3, 4.0, 0.06, 0.06, 0.1))
	local lid = math.max(blink * (1 - roar), 0.6 * impact)
	L.both(pose, "Lid", CFrame.new(0, -1.0 * lid, 0))

	-- ARMS -----------------------------------------------------------------
	local function armPose(lift, hitK, ph)
		local p = { 16 * lift - 3 * breathe * idleW - 2 * huff * idleW, 0, 4 * lift, 38 * lift, 0, 0, -30 * lift, 0 }
		p = mix(p, mix(COCK, HIT, hitK), pound)
		p = mix(p, FLEX, flex)
		p = mix(p, OVER, over)
		p = mix(p, SLAM, slam)
		p[3] += 8 * shake * wave(t, 6, ph)
		return p
	end
	local hipsW = CFrame.new(HIPS_P) * hipsT
	local chestW = hipsW * CFrame.new(CHEST_P - HIPS_P) * chestT
	-- planted fists: shift the arm so the fist bottom sits on the ground
	-- (and never sinks into it)
	local function solveArm(s, p, lift)
		local aT, fT, wT = ang(p[1], p[2], p[3]), ang(p[4], p[5], p[6]), ang(p[7], 0, p[8])
		if s < 0 then
			aT, fT, wT = L.mirror(aT), L.mirror(fT), L.mirror(wT)
		end
		local function m(v)
			return Vector3.new(v.X * s, v.Y, v.Z)
		end
		local fistW = chestW * CFrame.new(m(ARM_P) - CHEST_P) * aT * CFrame.new(m(FORE_P) - m(ARM_P)) * fT
			* CFrame.new(m(FIST_P) - m(FORE_P)) * wT
		local minY = math.huge
		for _, corner in FIST_BOTTOM do
			minY = math.min(minY, (fistW * m(corner)).Y)
		end
		local plant = math.max(groundW * (1 - math.min(1, lift * 3)), slamPlant)
		local want = minY + plant * (0.06 - minY)
		want = math.max(want, 0.06)
		local push = math.clamp(want - minY, -1.2, 2.5)
		local up = chestW.Rotation:Inverse() * Vector3.new(0, push, 0) + Vector3.new(0, 1.3 * over, 0) -- shrug / stretch up
		return CFrame.new(up) * aT, fT, wT
	end
	local aR, fR, wR = solveArm(1, armPose(liftR, poundR, 0), liftR)
	local aL, fL, wL = solveArm(-1, armPose(liftL, poundL, 0.5), liftL)
	pose.ArmR, pose.ForearmR, pose.FistR = aR, fR, wR
	pose.ArmL, pose.ForearmL, pose.FistL = aL, fL, wL

	-- LEGS: knees bend to keep the feet planted; tuck up during the leap
	local drop = -hy
	local rr = math.sin(math.rad(hipRoll)) * 2.6
	pose.ThighR, pose.ShinR, pose.FootR = leg(drop - rr, leap, hipX, hipRoll, hipYaw)
	pose.ThighL, pose.ShinL, pose.FootL = leg(drop + rr, leap, hipX, hipRoll, hipYaw)

	-- SHOCKWAVE: voxel bars race outward from the slam point and fade
	local wv = L.remap(c, 5.6, 6.3)
	local push = 7.5 * L.ease.cubicOut(wv)
	local dirs = { { 0, -1 }, { 0, 1 }, { 1, 0 }, { -1, 0 } }
	for i, d in dirs do
		pose["Wave" .. i] = CFrame.new(d[1] * push, 0.1 * wv, d[2] * push)
	end
	local showWave = c > 5.6 and c < 6.3
	for i = 1, 4 do
		ctx.transparency("Shock" .. i, showWave and (0.1 + 0.9 * wv ^ 1.5) or 1)
	end

	-- TURF CHUNKS: blasted up and out by the fists, tumble, bounce, vanish
	local u = c - 5.6
	local rockOn = u > 0 and u < 0.95
	local vel = { { 4.5, 13, -3.5 }, { 1.5, 15, -5.5 }, { 6.5, 11, 1.0 } }
	for i, vv in vel do
		local tt = math.clamp(u, 0, 0.95)
		local y = math.max(vv[2] * tt - 16 * tt * tt, 0)
		for _, sd in { { "R", 1 }, { "L", -1 } } do
			local k = sd[2]
			pose["Rock" .. sd[1] .. i] = pa(k * vv[1] * tt, y, vv[3] * tt, 520 * tt * k, 300 * tt, 410 * tt * k)
			ctx.transparency("Rock" .. sd[1] .. i, rockOn and (u > 0.8 and (u - 0.8) / 0.15 or 0) or 1)
		end
	end

	-- ORBITING VOXEL CUBES: slow orbit, bob + tumble, flung out by the slam
	pose.Orbit = ang(0, 28 * t, 0)
	for i = 1, 4 do
		local out = 2.2 * impact + 1.0 * roar
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(0, 0.9 * wave(t, 0.5, i * 0.27) + out, 0, 80 * t * dir, 110 * t, 30 * dir)
	end

	-- EFFECTS --------------------------------------------------------------
	for _, h in { 2.4, 2.7, 3.0, 3.3 } do
		if ctx.crossed(h) then
			ctx.emit("PoundBurst", 14)
		end
	end
	ctx.enable("ToxicBreath", c > 3.7 and c < 4.6)
	ctx.light("MouthLight", 1.2 * roar)
	if ctx.crossed(3.7) then
		ctx.emit("RoarBurst", 30)
	end
	if ctx.crossed(5.6) then
		ctx.emit("SlamBurst", 50)
		ctx.emit("SlamDust", 30)
	end
	ctx.light("SlamLight", 1.5 * L.env(c, 5.6, 0.03, 0.05, 0.6))
end

return M
