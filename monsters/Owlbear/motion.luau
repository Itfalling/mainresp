--!nocheck
-- Owlbear motion.
-- Idle: bouncy breathing, butt sway, owl head swivels with snappy holds (incl. a
-- near-180 look-behind with a curious double tilt), blinks, darting pupils,
-- ear-tuft flicks, beak clacks, paw taps, stubby tail wag.
-- Signature "HOOT RAMPAGE": crouch + butt wiggle -> rears up on the hind legs
-- (backOut overshoot), arms flung wide, beak opens for a double "HOO-HOOT!"
-- with voxel sound waves -> right + left claw slashes with trails -> slams
-- back onto all fours with an elastic squash, feather burst and dust.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, env = L.ang, L.pa, L.wave, L.env
local deg, rad, atan2, acos, sqrt = math.deg, math.rad, math.atan2, math.acos, math.sqrt
local clamp, max, abs = math.clamp, math.max, math.abs

local M = {}
M.Cycle = 10

-- rest pivots (must match build.luau)
local H0 = Vector3.new(0, 5.6, 5.2) -- Hips
local C0 = Vector3.new(0, 7.2, 1.6) -- Chest
local SH = Vector3.new(3.7, 8.4, -2.6) -- shoulder (Arm)
local EL = Vector3.new(3.95, 4.8, -2.8) -- elbow (Forearm)
local WR = Vector3.new(3.95, 1.5, -2.8) -- wrist (Paw)
local HP = Vector3.new(3.3, 5.6, 5.2) -- hip (Thigh)
local KN = Vector3.new(3.65, 3.4, 5.4) -- knee (Shin)
local AN = Vector3.new(3.65, 1.2, 5.4) -- ankle (Foot)

-- angle of a hanging limb segment (0 = straight down, + = swung forward / -Z)
local function segAng(dy, dz)
	return deg(atan2(-dz, -dy))
end
local function len2(dy, dz)
	return sqrt(dy * dy + dz * dz)
end
local A_UP, A_LO = segAng(EL.Y - SH.Y, EL.Z - SH.Z), segAng(WR.Y - EL.Y, WR.Z - EL.Z)
local A_L1, A_L2 = len2(EL.Y - SH.Y, EL.Z - SH.Z), len2(WR.Y - EL.Y, WR.Z - EL.Z)
local T_UP, T_LO = segAng(KN.Y - HP.Y, KN.Z - HP.Z), segAng(AN.Y - KN.Y, AN.Z - KN.Z)
local T_L1, T_L2 = len2(KN.Y - HP.Y, KN.Z - HP.Z), len2(AN.Y - KN.Y, AN.Z - KN.Z)

-- 2-bone IK in the side plane: world angles of the upper and lower segment.
-- bend = -1 elbow points back, +1 knee points forward.
local function ik2(sy, sz, ty, tz, l1, l2, bend)
	local dy, dz = ty - sy, tz - sz
	local d = clamp(len2(dy, dz), abs(l1 - l2) + 0.01, l1 + l2 - 0.001)
	local a = deg(acos(clamp((l1 * l1 + d * d - l2 * l2) / (2 * l1 * d), -1, 1)))
	local up = segAng(dy, dz) + bend * a
	local ur = rad(up)
	local ey, ez = sy - l1 * math.cos(ur), sz - l1 * math.sin(ur)
	return up, segAng(ty - ey, tz - ez)
end

local function snap(c, keys)
	return L.track(c, keys)
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- signature envelopes
	------------------------------------------------------------------
	local crouch = env(c, 4.4, 0.6, 0.15, 0.3, "cubicOut", "quadIn") -- wind-up crouch
	local rise = env(c, 5.05, 0.42, 1.6, 0.38, "backOut", "cubicIn") -- rear up / slam down at 7.45
	local impact = env(c, 7.43, 0.05, 0.05, 0.95, "quadOut", "elasticOut") -- squash + jiggle
	local hoot1 = env(c, 5.35, 0.12, 0.2, 0.15, "backOut", "quadIn") -- "HOO-"
	local hoot2 = env(c, 5.85, 0.14, 0.3, 0.22, "backOut", "cubicIn") -- "-HOOT!"
	local hoot = max(0.75 * hoot1, hoot2)
	local squint = env(c, 6.2, 0.1, 0.6, 0.3) -- angry focus during the slashes
	local sig = clamp(max(crouch, rise, abs(impact)), 0, 1)
	local idleW = 1 - clamp(sig * 1.6, 0, 1)

	local br = wave(t, 0.45)
	local bob = L.wave01(t, 1.0) * idleW

	------------------------------------------------------------------
	-- body
	------------------------------------------------------------------
	local wiggle = crouch * wave(t, 4.5) * 8
	local hipsYaw = wiggle + 2.5 * wave(t, 0.5, 0.25) * idleW
	local hipsRoll = 3 * wave(t, 0.5) * idleW
	local hipsP = 58 * rise - 6 * crouch + 1.2 * br - 4 * impact
	local hipsY = -0.9 * crouch - 0.45 * bob - 0.8 * impact + 0.12 * br
	local hipsRot = ang(hipsP, hipsYaw, hipsRoll)
	local hipsCF = CFrame.new(0, hipsY, 0.6 * rise) * hipsRot
	pose.Hips = hipsCF

	local chestP = 12 * rise - 5 * crouch + 2 * br - 8 * impact
	local chestRot = ang(chestP, -0.5 * hipsYaw, -0.4 * hipsRoll)
	local chestCF = CFrame.new(0, -0.3 * impact, 0) * chestRot
	pose.Chest = chestCF

	local hipsW = CFrame.new(H0) * hipsCF
	local chestW = hipsW * CFrame.new(C0 - H0) * chestCF
	local bodyRot = hipsRot * chestRot
	local Pc = hipsP + chestP

	------------------------------------------------------------------
	-- hind legs: feet stay planted (IK), knees bend on crouch/impact
	------------------------------------------------------------------
	for _, s in { 1, -1 } do
		local hp = hipsW * (Vector3.new(HP.X * s, HP.Y, HP.Z) - H0)
		local up, lo = ik2(hp.Y, hp.Z, AN.Y, AN.Z, T_L1, T_L2, 1)
		local side = s == 1 and "R" or "L"
		pose["Thigh" .. side] = hipsRot:Inverse() * ang(up - T_UP, 0, 0)
		pose["Shin" .. side] = ang((lo - T_LO) - (up - T_UP), 0, 0)
		pose["Foot" .. side] = ang(-(lo - T_LO), 0, 0)
	end

	------------------------------------------------------------------
	-- front legs: planted (IK) on the ground, keyframed in the air
	------------------------------------------------------------------
	local w = L.smoothstep(clamp(rise / 0.4, 0, 1))
	local tapR = env(c, 3.2, 0.14, 0.06, 0.25, "quadOut", "bounceOut") + env(c, 8.9, 0.14, 0.06, 0.25, "quadOut", "bounceOut")
	local tapL = env(c, 3.62, 0.14, 0.06, 0.25, "quadOut", "bounceOut") + env(c, 9.32, 0.14, 0.06, 0.25, "quadOut", "bounceOut")
	local airR = {
		{ 5.05, { -20, 0, 0 } },
		{ 5.5, { 70, 0, 60 }, "backOut" }, -- arms flung wide, claws up
		{ 6.22, { 74, 0, 56 } },
		{ 6.34, { 95, -10, 100 }, "quadOut" }, -- R wind-up: high and out
		{ 6.46, { -8, 25, -38 }, "expoOut" }, -- R SLASH: diagonal down across the belly
		{ 6.8, { 0, 20, -28 } },
		{ 7.1, { 12, 0, 38 }, "quadInOut" },
		{ 7.42, { 10, 0, 6 } },
	}
	local airL = {
		{ 5.05, { -20, 0, 0 } },
		{ 5.5, { 70, 0, 60 }, "backOut" },
		{ 6.46, { 74, 0, 56 } },
		{ 6.58, { 95, -10, 100 }, "quadOut" }, -- L wind-up
		{ 6.7, { -8, 25, -38 }, "expoOut" }, -- L SLASH
		{ 6.95, { 0, 20, -28 } },
		{ 7.15, { 12, 0, 38 }, "quadInOut" },
		{ 7.42, { 10, 0, 6 } },
	}
	local foreAir = L.track(c, { { 5.05, 30 }, { 5.5, 55, "backOut" }, { 6.22, 50 }, { 6.34, 35 }, { 6.46, 8, "expoOut" }, { 6.8, 10 }, { 7.0, 30 }, { 7.42, 0 } })
	local pawAir = L.track(c, { { 5.05, 0 }, { 5.5, -45, "backOut" }, { 6.2, -40 }, { 6.5, -10 }, { 7.0, -20 }, { 7.42, 0 } })
	for _, s in { 1, -1 } do
		local side = s == 1 and "R" or "L"
		local tap = s == 1 and tapR or tapL
		local sh = chestW * (Vector3.new(SH.X * s, SH.Y, SH.Z) - C0)
		local up, lo = ik2(sh.Y, sh.Z, WR.Y + 1.2 * tap, WR.Z - 0.6 * tap, A_L1, A_L2, -1)
		local armIK = bodyRot:Inverse() * ang(up - A_UP, 0, 0)
		local ax, ay, az = L.track3(c, s == 1 and airR or airL)
		local armAir = ang(ax, ay * s, az * s)
		pose["Arm" .. side] = armIK:Lerp(armAir, w)
		local foreIK = (lo - A_LO) - (up - A_UP)
		local pawIK = -(lo - A_LO) - 20 * tap
		pose["Forearm" .. side] = ang(L.lerp(foreIK, foreAir, w), 0, 0)
		pose["Paw" .. side] = ang(L.lerp(pawIK, pawAir, w), 0, 0)
	end

	------------------------------------------------------------------
	-- neck + owl head
	------------------------------------------------------------------
	local yaw = snap(c, {
		{ 0, 0 }, { 0.12, 0 }, { 0.3, 30, "backOut" }, { 0.75, 30 }, { 0.9, -38, "backOut" }, { 1.5, -38 },
		{ 1.78, 166, "backOut" }, { 2.95, 166 }, { 3.18, 0, "backOut" },
		{ 3.45, 0 }, { 3.6, -26, "backOut" }, { 3.95, -26 }, { 4.1, 0, "backOut" },
		{ 8.4, 0 }, { 8.55, 30, "backOut" }, { 9.05, 30 }, { 9.2, -24, "backOut" }, { 9.7, -24 }, { 9.85, 0, "backOut" },
	})
	local roll = snap(c, {
		{ 0, 0 }, { 0.75, 0 }, { 0.9, -18, "backOut" }, { 1.5, -18 }, { 1.7, 0 },
		{ 1.95, 0 }, { 2.08, 28, "backOut" }, { 2.4, 28 }, { 2.52, -24, "backOut" }, { 2.85, -24 }, { 3.05, 0, "quadOut" },
		{ 3.45, 0 }, { 3.6, -12, "backOut" }, { 3.95, -12 }, { 4.1, 0 },
		{ 9.05, 0 }, { 9.2, -16, "backOut" }, { 9.7, -16 }, { 9.85, 0 },
	})
	local lookP = snap(c, {
		{ 4.3, 0 }, { 4.75, -7, "cubicOut" }, { 5.1, -7 }, { 5.45, 16, "backOut" }, { 5.75, 8 }, { 5.95, 22, "backOut" },
		{ 6.2, 18 }, { 6.34, -10, "quadOut" }, { 7.05, -8 }, { 7.36, 12, "quadIn" }, { 7.5, -12, "quadOut" },
		{ 7.9, 4, "quadInOut" }, { 8.3, 0 },
	})
	local lift = env(c, 1.5, 0.22, 1.43, 0.25, "backOut", "quadInOut")
	local neckP = -0.4 * Pc - 5 * lift
	pose.Neck = pa(0, 2.7 * lift - 0.7 * crouch, -0.8 * lift - 0.5 * crouch, neckP, 0, 0)
	local shake = 7 * hoot2 * wave(t, 7)
	local headP = lookP - Pc - neckP - 2 * bob + 2 * br - 10 * lift
	pose.Head = pa(0, 0, 0, headP, yaw + shake, roll + 3 * hoot2 * wave(t, 5))

	-- beak: little clacks in idle, flung WIDE open for the double hoot
	local clack = env(c, 1.1, 0.05, 0.03, 0.07) + env(c, 1.27, 0.05, 0.03, 0.07)
		+ env(c, 3.0, 0.05, 0.03, 0.07) + env(c, 8.6, 0.05, 0.03, 0.07)
	pose.Beak = ang(-74 * hoot - 22 * clack - 10 * squint, 0, 0)
	pose.BeakTop = ang(30 * hoot + 6 * clack, 0, 0)

	-- eyelids: blinks (incl. a double blink after the head whip) + angry squint
	local blink = max(env(t % 3.4, 3.0, 0.06, 0.05, 0.09), env(c, 1.85, 0.05, 0.04, 0.08), env(c, 2.01, 0.05, 0.04, 0.08))
	local lid = max(blink * (1 - hoot), 0.36 * squint)
	L.both(pose, "Lid", ang(92 * lid, 0, 0))

	-- pupils dart ahead of the head and go cross-eyed when focusing
	local lookX = clamp(-yaw / 40, -1, 1) * 0.3 * (1 - lift)
	local conv = 0.28 * crouch + 0.2 * squint
	local py = 0.25 * hoot - 0.2 * crouch
	pose.PupilR = CFrame.new(lookX - conv, py, 0)
	pose.PupilL = CFrame.new(lookX + conv, py, 0)

	-- ear tufts: flicks, flare back on the hoot, flop + wobble on impact
	local flickR = env(t % 2.9, 2.5, 0.07, 0.05, 0.3, "quadOut", "elasticOut")
	local flickL = env((t + 1.3) % 3.3, 2.9, 0.07, 0.05, 0.3, "quadOut", "elasticOut")
	local earBase = 5 * wave(t, 0.45, 0.2)
	local function ear(f)
		return ang(earBase - 15 * f + 35 * hoot - 25 * impact, 0, -28 * f + 18 * hoot - 30 * impact + 8 * crouch * wave(t, 4.5))
	end
	local whip = env(c, 1.55, 0.08, 0.05, 0.45, "quadOut", "elasticOut") + env(c, 3.0, 0.08, 0.05, 0.45, "quadOut", "elasticOut")
	pose.EarR = ear(max(flickR, whip))
	pose.EarL = L.mirror(ear(max(flickL, whip)))

	-- stubby tail: happy wag, curls up while reared
	pose.Tail = ang(-25 * rise + 25 * impact + 4 * br, 22 * wave(t, 1.6) + 18 * crouch * wave(t, 4.5), 0)

	------------------------------------------------------------------
	-- VFX
	------------------------------------------------------------------
	-- hoot sound-wave voxel squares fly out of the beak
	local function waveFx(id, boneName, starts)
		local active = false
		for _, st in starts do
			local p = (c - st) / 0.5
			if p >= 0 and p < 1 then
				pose[boneName] = CFrame.new(0, 0.4 * p, -1.5 - 8 * L.ease.quadOut(p))
				for i = 1, 4 do
					ctx.transparency(id .. i, 0.2 + 0.8 * p)
				end
				active = true
			end
		end
		if not active then
			pose[boneName] = CFrame.new()
			for i = 1, 4 do
				ctx.transparency(id .. i, 1)
			end
		end
	end
	waveFx("HootA", "HootWaveA", { 5.4, 5.9 })
	waveFx("HootB", "HootWaveB", { 5.52, 6.02 })

	-- claw-scratch marks flash in the air right after each slash
	for _, sd in { { "R", 6.42 }, { "L", 6.66 } } do
		local p = (c - sd[2]) / 0.38
		local on = p >= 0 and p < 1
		pose["Slash" .. sd[1]] = on and CFrame.new(0, -0.8 * p, -1.2 * p) or CFrame.new()
		for k = 1, 3 do
			ctx.transparency("Slash" .. sd[1] .. k, on and (0.1 + 0.9 * p * p) or 1)
		end
	end

	-- ground debris bursts out of the floor on the slam and tumbles away
	local dp = (c - 7.42) / 0.75
	local dOn = dp >= 0 and dp < 1
	for i = 1, 6 do
		local a = rad(-95 + (i - 1) * 38)
		if dOn then
			local u = L.ease.quadOut(dp)
			local r = 3.4 * u * (0.8 + 0.12 * (i % 3))
			local h = (3.6 + 0.6 * (i % 3)) * 4 * u * (1 - u)
			pose["Debris" .. i] = pa(r * math.sin(a), h, -r * math.cos(a), 420 * dp, 300 * dp * (i % 2 == 0 and 1 or -1), 0)
			ctx.transparency("Debris" .. i, dp < 0.8 and 0 or (dp - 0.8) * 5)
		else
			pose["Debris" .. i] = CFrame.new()
			ctx.transparency("Debris" .. i, 1)
		end
	end

	-- floating forest voxel cubes: orbit, bob, tumble; flung out by the slam
	pose.Orbit = ang(0, 30 * t, 0)
	for i = 1, 5 do
		local dir = i % 2 == 0 and -1 or 1
		local out = 2.5 * impact + 1.2 * hoot
		pose["Orb" .. i] = pa(out * dir * 0.5, 0.8 * wave(t, 0.55, i * 0.21) + out * 0.5, 0, 80 * t * dir, 110 * t, 30 + 20 * i)
	end

	if ctx.crossed(5.1) then ctx.emit("ImpactDust", 12) end
	if ctx.crossed(5.42) then ctx.emit("HootBurst", 22) end
	if ctx.crossed(5.92) then ctx.emit("HootBurst", 40) end
	if ctx.crossed(6.42) then ctx.emit("SwipeR", 18) end
	if ctx.crossed(6.66) then ctx.emit("SwipeL", 18) end
	if ctx.crossed(7.46) then
		ctx.emit("FeatherBurst", 45)
		ctx.emit("ImpactDust", 35)
	end
end

return M
