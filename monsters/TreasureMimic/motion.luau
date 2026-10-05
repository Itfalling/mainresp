--!nocheck
-- Treasure Mimic motion.
-- Idle: bouncy waddle-hops, lid breathing + flapping on each landing, lolling
-- tongue, blinks, darting pupils, swinging padlock, orbiting gold coins.
-- Signature "GREEDY CHOMP":
--   2.45-3.20  anticipation: crouch-squash, lid clamps shut, brows furious
--   3.20-3.55  launch: hops ~4.5 studs, lid flies wide open (overshoot), coin burst,
--              loot coins + crown pop out of the mouth
--   3.55-4.50  hang time (lid wobbling, tongue flailing), then slam landing (squash + dust)
--   4.50-5.65  CHOMP x3 (4.8 / 5.2 / 5.6), catching the falling coins
--   5.65-7.05  follow-through: tongue whips around like a lasso, smug brow
--   7.05-8.00  settle back into the idle hops
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave
local track, env, clamp01 = L.track, L.env, L.clamp01

local M = {}
M.Cycle = 8

-- rig constants (must match build.luau)
local BP = Vector3.new(0, 2.0, 0) -- Body pivot
local HINGE = Vector3.new(0, 5.5, 3.5) -- Lid pivot
local CROWN = Vector3.new(0.9, 10.0, 0.1) -- Crown pivot
local LEG_L = 1.2 -- hip pivot -> foot pivot
local FOOT_Y = 1.0 -- foot pivot height when standing flat
local DOWN = Vector3.new(0, -1, 0)
local LEGS = {
	{ leg = "LegFR", foot = "FootFR", hip = Vector3.new(3.0, 2.2, -2.0), dx = 0.85, dz = -0.5, ph = 0.0 },
	{ leg = "LegFL", foot = "FootFL", hip = Vector3.new(-3.0, 2.2, -2.0), dx = -0.85, dz = -0.5, ph = 0.5 },
	{ leg = "LegBR", foot = "FootBR", hip = Vector3.new(3.0, 2.2, 2.0), dx = 0.85, dz = 0.5, ph = 0.25 },
	{ leg = "LegBL", foot = "FootBL", hip = Vector3.new(-3.0, 2.2, 2.0), dx = -0.85, dz = 0.5, ph = 0.75 },
}
-- orbiting coins (same layout as build.luau)
local ORB = {}
for i = 1, 5 do
	local a = math.rad((i - 1) * 72 + 20)
	ORB[i] = { math.cos(a), math.sin(a) }
end
-- loot coins: launch time, catch time (= a chomp), sideways drift, flips
local LOOT = {
	{ tc = 4.8, dx = -2.4, dz = -1.6, h = 6.5, flips = 2 },
	{ tc = 5.2, dx = 2.6, dz = -0.6, h = 7.5, flips = 3 },
	{ tc = 5.6, dx = -1.2, dz = 2.0, h = 8.0, flips = 3 },
	{ tc = 4.8, dx = 1.8, dz = -2.8, h = 6.0, flips = 2 },
}
local LAUNCH = 3.28

-- signature keyframes ---------------------------------------------------
local SIG_Y = {
	{ 2.45, 0 },
	{ 3.05, -0.8, "cubicOut" }, -- crouch-squash
	{ 3.2, -0.85, "linear" },
	{ 3.3, -0.2, "quadIn" }, -- push-off
	{ 3.6, 3.7, "quadOut" }, -- LAUNCH
	{ 3.95, 4.05, "sineInOut" }, -- hang time
	{ 4.2, 3.5, "quadIn" },
	{ 4.43, 0.3, "quadIn" },
	{ 4.58, -0.9, "quadOut" }, -- slam landing (squash)
	{ 4.66, -0.15, "quadOut" },
	{ 4.8, -0.7, "quadIn" }, -- chomp 1 impact
	{ 5.0, 0.15, "quadOut" },
	{ 5.2, -0.7, "quadIn" }, -- chomp 2
	{ 5.4, 0.2, "quadOut" },
	{ 5.6, -0.8, "quadIn" }, -- chomp 3
	{ 5.9, 0.35, "backOut" },
	{ 6.35, 0.1, "sineInOut" },
	{ 6.95, 0, "sineInOut" },
}
local SIG_PITCH = { -- + = lean back (mouth to the sky)
	{ 2.45, 0 },
	{ 3.05, -6, "cubicOut" },
	{ 3.2, -7 },
	{ 3.5, 12, "backOut" },
	{ 4.2, 6, "sineInOut" },
	{ 4.5, -5, "quadIn" },
	{ 4.8, -14, "quadOut" },
	{ 5.0, 2, "quadOut" },
	{ 5.2, -14, "quadIn" },
	{ 5.4, 2, "quadOut" },
	{ 5.6, -16, "quadIn" },
	{ 5.9, 7, "backOut" },
	{ 6.4, 3, "sineInOut" },
	{ 6.95, 0, "sineInOut" },
}
local SIG_Z = {
	{ 4.5, 0 },
	{ 4.8, -0.7, "quadIn" },
	{ 5.0, 0 },
	{ 5.2, -0.7, "quadIn" },
	{ 5.4, 0 },
	{ 5.6, -0.9, "quadIn" },
	{ 5.9, 0.1, "backOut" },
	{ 6.3, 0 },
}
local SIG_YAW = {
	{ 3.3, 0 },
	{ 3.7, -12, "sineInOut" },
	{ 4.1, 12, "sineInOut" },
	{ 4.45, 0, "sineInOut" },
	{ 5.65, 0 },
	{ 5.95, 16, "cubicOut" },
	{ 6.3, -16, "sineInOut" },
	{ 6.65, 8, "sineInOut" },
	{ 7.0, 0, "sineInOut" },
}
local SIG_LID = {
	{ 2.45, 17 },
	{ 2.9, -1, "cubicIn" }, -- clamps shut
	{ 3.2, -0.5 },
	{ 3.38, 85, "quadOut" }, -- flies WIDE open
	{ 3.5, 106, "quadOut" },
	{ 3.75, 94, "sineInOut" },
	{ 3.95, 90, "sineInOut" },
	{ 4.25, 98, "sineInOut" },
	{ 4.5, 45, "quadIn" },
	{ 4.64, 62, "quadOut" },
	{ 4.8, -1, "expoIn" }, -- CHOMP 1
	{ 5.0, 64, "backOut" },
	{ 5.2, -1, "expoIn" }, -- CHOMP 2
	{ 5.4, 70, "backOut" },
	{ 5.6, -1, "expoIn" }, -- CHOMP 3
	{ 5.85, 44, "backOut" },
	{ 6.6, 36, "sineInOut" },
	{ 7.1, 17, "cubicInOut" },
}
local WHIP = { -- tongue lasso sweep (yaw, degrees)
	{ 5.65, 0 },
	{ 5.95, 50, "cubicOut" },
	{ 6.3, -55, "sineInOut" },
	{ 6.65, 40, "sineInOut" },
	{ 7.0, 0, "sineInOut" },
}

-- damped spring "boing" that starts at t0 (0 before it)
local function kick(c, t0, freq, decay)
	if c < t0 then
		return 0
	end
	local x = c - t0
	return math.exp(-decay * x) * math.sin(2 * math.pi * freq * x)
end

local function rotBetween(a, b)
	local axis = a:Cross(b)
	local s = axis.Magnitude
	if s < 1e-5 then
		return CFrame.new()
	end
	return CFrame.fromAxisAngle(axis / s, math.atan2(s, a:Dot(b)))
end

local function rotOnly(cf)
	return cf - cf.Position
end

local HOPF = 1.5 -- idle hops per second

-- one cartoon hop: 72% of the time in the air (up 0..1), 28% squashed on the
-- ground (sq 0..1..0) so every landing gets a readable squash
local function hopPhase(t)
	local p = (t * HOPF) % 1
	if p < 0.72 then
		return math.sin(math.pi * p / 0.72), 0
	end
	return 0, math.sin(math.pi * (p - 0.72) / 0.28)
end

-- body transform at any time (also sampled in the past for the leg IK lag)
local function bodyAt(t)
	local c = t % M.Cycle
	local sigW = env(c, 2.45, 0.35, 4.15, 0.5)
	local idleW = 1 - sigW
	local chomping = env(c, 4.55, 0.1, 1.05, 0.2)
	local up, squash = hopPhase(t)
	local hopAmp = 0.8 + 0.6 * L.wave01(t, HOPF / 4) -- every 4th hop is a big one
	local by = L.lerp(hopAmp * up - 0.5 * squash, track(c, SIG_Y), sigW)
	local pitch = L.lerp(4 * up - 6 * squash, track(c, SIG_PITCH), sigW)
	local roll = 7 * wave(t, HOPF / 2) * idleW + 6 * chomping * wave(c, 1.25, 0.1) + 8 * kick(c, 4.5, 2.2, 4)
	local yaw = 10 * L.noise(t, 2.3, 0.25) * idleW + track(c, SIG_YAW) * sigW
	local bz = track(c, SIG_Z) * sigW
	return pa(0, by, bz, pitch, yaw, roll), by, pitch, roll
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- weights -------------------------------------------------------------
	local sigW = env(c, 2.45, 0.35, 4.15, 0.5) -- 1 during the signature move
	local idleW = 1 - sigW
	local crouch = env(c, 2.5, 0.5, 0.2, 0.12, "cubicOut", "expoIn")
	local air = env(c, 3.22, 0.2, 0.95, 0.3, "cubicOut", "quadIn")
	local chomping = env(c, 4.55, 0.1, 1.05, 0.2)
	local whip = env(c, 5.65, 0.35, 0.75, 0.4, "cubicOut", "sineInOut")
	local smug = env(c, 5.8, 0.3, 1.0, 0.5)

	-- idle hop ------------------------------------------------------------
	local hop, land = hopPhase(t)
	local hopLag, landLag = hopPhase(t - 0.08)
	local breathe = wave(t, 0.45)

	-- body ------------------------------------------------------------------
	local bodyPose, by, pitch, roll = bodyAt(t)
	pose.Body = bodyPose
	local bodyCF = CFrame.new(BP) * bodyPose
	local bodyRot = rotOnly(bodyCF)

	-- springs fired by impacts (follow-through for lock / crown / hoard)
	local jolt = kick(c, 3.3, 1.6, 2.8) + kick(c, 4.5, 2.0, 3.0) + 0.7 * kick(c, 4.8, 2.4, 4) + 0.7 * kick(c, 5.2, 2.4, 4)
		+ 0.8 * kick(c, 5.6, 2.4, 3.5)

	-- lid ---------------------------------------------------------------------
	local idleSnap = env(c, 0.95, 0.07, 0.03, 0.14, "quadIn", "backOut") + env(c, 1.3, 0.07, 0.03, 0.18, "quadIn", "backOut")
	local idleLid = 17 + 4 * breathe + 11 * landLag - 4 * hop - 19 * idleSnap
	local lidAng = L.lerp(idleLid, track(c, SIG_LID), sigW)
	lidAng += 5 * air * wave(t, 4.5) -- greedy wobble in the air
	local lidPose = ang(lidAng, 3 * wave(t, 0.9) * idleW, 2 * wave(t, HOPF / 2, 0.2) * idleW)
	pose.Lid = lidPose

	-- eyes -----------------------------------------------------------------------
	local blink = env(t % 3.1, 2.7, 0.06, 0.07, 0.09) * (1 - chomping)
	blink = math.min(1, blink)
	L.both(pose, "Eyelid", CFrame.new(0, 0, -0.95 * blink))
	local lookX = 0.32 * L.noise(t, 3.1, 0.5) * idleW - 0.3 * whip
	local lookY = 0.15 * L.noise(t, 7.7, 0.4) * idleW + 0.3 * air - 0.1 * crouch
	local cross = 0.28 * chomping
	pose.PupilR = CFrame.new(math.clamp(lookX - cross, -0.42, 0.42), lookY, 0)
	pose.PupilL = CFrame.new(math.clamp(lookX + cross, -0.42, 0.42), lookY, 0)
	-- brows: + angle = angrier (inner end down)
	local browUp = (0.15 * hopLag - 0.15 * landLag) * idleW - 0.3 * crouch + 0.55 * air - 0.35 * chomping
	local browAng = 4 * L.noise(t, 5.5, 0.3) * idleW + 14 * crouch - 20 * air + 10 * chomping + 12 * idleSnap
	pose.BrowR = pa(0, browUp + 0.4 * smug, 0, 0, 0, browAng - 16 * smug)
	pose.BrowL = L.mirror(pa(0, browUp - 0.15 * smug, 0, 0, 0, browAng + 8 * smug))

	-- crown: rides the lid, pops off and spins over the open mouth during the hop
	local crownFloat = env(c, 3.15, 0.08, 1.45, 0.3, "cubicOut", "quadIn")
	local ride = pa(0, 0.25 * math.abs(jolt), 0, 6 * jolt, 0, 9 * jolt)
	if crownFloat > 0.001 then
		local lidRest = CFrame.new(HINGE)
		local crownRest = CFrame.new(CROWN)
		local rel = lidRest:Inverse() * crownRest
		local fx = math.clamp((c - 3.2) / 1.5, 0, 1)
		local float = pa(0.6 * math.sin(fx * math.pi), 1.5 * math.sin(fx * math.pi) + 0.5, -0.6 * math.sin(fx * math.pi), 14 * math.sin(fx * 6.28), 360 * fx, 0)
		local floatPose = rel:Inverse() * lidPose:Inverse() * lidRest:Inverse() * crownRest * float
		pose.Crown = ride:Lerp(floatPose, crownFloat)
	else
		pose.Crown = ride
	end

	-- padlock: hangs, knocks against the box on every impact
	local lockX = -math.min(pitch, 0) + 4 + 38 * math.abs(jolt) + 10 * hopLag * idleW
	local lockZ = -roll + 14 * wave(t, HOPF / 2, -0.15) * idleW + 18 * whip * wave(c, 1.4)
	pose.Lock = ang(lockX, 0, lockZ)

	-- chest handles swing outward on impacts and sway with the waddle
	local hs = 10 + 40 * math.abs(jolt) + 12 * (1 - hop) * idleW
	pose.HandleR = ang(8 * wave(t, HOPF / 2, -0.2) * idleW, 0, hs + 6 * roll / 7)
	pose.HandleL = L.mirror(ang(8 * wave(t, HOPF / 2, -0.2) * idleW, 0, hs - 6 * roll / 7))

	-- gold hoard jiggles
	pose.CoinPile = CFrame.new(0, 0.08 * hopLag * idleW + 0.2 * math.abs(jolt), 0)

	-- tongue -------------------------------------------------------------------------
	local tuck = env(c, 2.5, 0.4, 0.3, 0.25)
	local fling = env(c, 3.25, 0.3, 0.9, 0.35, "cubicOut")
	local whipYaw = track(c, WHIP)
	local whipLag = track(c - 0.1, WHIP)
	local whipLag2 = track(c - 0.2, WHIP)
	local flail = wave(t, 3.2)
	local sway = wave(t, HOPF / 2, -0.15)
	pose.Tongue1 = pa(0, 0.1 * fling, 1.0 * tuck, 4 * breathe * idleW + 22 * fling + 26 * whip, 5 * wave(t, 0.6) * idleW + 0.55 * whipYaw * whip, 0)
	pose.Tongue2 = ang(3 * idleW + 25 * fling + 14 * whip + 10 * chomping * wave(t, 5), 0.45 * whipLag * whip + 12 * fling * flail, 0)
	-- hanging segments: +X swings forward
	pose.Tongue3 = ang(
		6 + 8 * hopLag * idleW + 30 * crouch + 62 * fling + 72 * whip + 12 * chomping * math.abs(jolt),
		0,
		(10 * sway) * idleW + 22 * fling * wave(t, 3.2, -0.1) - 0.6 * whipLag * whip
	)
	pose.Tongue4 = ang(
		4 + 6 * hopLag * idleW + 25 * crouch + 26 * fling + 16 * whip + 20 * fling * wave(t, 3.2, -0.2),
		0,
		(13 * wave(t, HOPF / 2, -0.25)) * idleW + 26 * fling * wave(t, 3.2, -0.2) - 0.5 * whipLag2 * whip
	)
	pose.Tongue5 = ang(
		6 + 5 * hopLag * idleW + 20 * crouch + 22 * fling + 14 * whip + 26 * fling * wave(t, 3.2, -0.3),
		0,
		(16 * wave(t, HOPF / 2, -0.35)) * idleW + 30 * fling * wave(t, 3.2, -0.3) - 0.6 * track(c - 0.3, WHIP) * whip
	)

	-- legs: tiny IK keeps feet planted and splays them on squash; dangle in the air.
	-- The splay angle is "peak-held" over the last few frames so legs spring back
	-- straight smoothly (push-off) instead of snapping when a foot leaves the ground.
	local past = { bodyCF }
	for k = 1, 4 do
		past[k + 1] = CFrame.new(BP) * (bodyAt(t - k / 30))
	end
	for _, lg in LEGS do
		local hipL = lg.hip - BP
		local h = (bodyCF * hipL).Y - FOOT_Y
		local th = 0
		for k = 1, 5 do
			local hk = (past[k] * hipL).Y - FOOT_Y
			if hk < LEG_L then
				th = math.max(th, (1.2 - 0.2 * k) * math.acos(math.clamp(hk / LEG_L, -1, 1)))
			end
		end
		local airK = clamp01((h - LEG_L) / 1.2)
		local kickF = 0.45 * airK * wave(t, 2.6, lg.ph)
		local sx, cx = math.sin(th), math.cos(th)
		local dirW = Vector3.new(sx * lg.dx + 0.35 * airK * lg.dx, -cx, sx * lg.dz + 0.3 * airK * lg.dz - kickF).Unit
		local legRot = rotBetween(DOWN, bodyRot:Inverse() * dirW)
		pose[lg.leg] = legRot
		local footWorld = ang(-45 * airK, 0, 0)
		pose[lg.foot] = rotOnly(bodyRot * legRot):Inverse() * footWorld
	end

	-- loot coins: ballistic arcs out of the mouth, caught by the chomps
	for i, lc in LOOT do
		local name = "Loot" .. i
		if c >= LAUNCH and c < lc.tc then
			local T = lc.tc - LAUNCH
			local x = (c - LAUNCH) / T
			local y0 = track(LAUNCH, SIG_Y)
			local y1 = track(lc.tc, SIG_Y)
			local arcY = L.lerp(y0, y1, x) + 4 * lc.h * x * (1 - x)
			local s = math.sin(math.pi * x)
			pose[name] = pa(lc.dx * s, arcY - by, lc.dz * s, 360 * lc.flips * x, 140 * s, 0)
		else
			pose[name] = CFrame.new()
		end
	end

	-- orbiting coins: slow spin, flung outward by the burst
	local spinBoost = 360 * L.ease.sineInOut(clamp01((c - 2.45) / 5.0))
	pose.Orbit = ang(0, 45 * t + spinBoost, 0)
	local out = 2.4 * env(c, 3.3, 0.3, 1.0, 1.0, "backOut", "sineInOut")
	for i = 1, 5 do
		local d = ORB[i]
		local bob = 0.7 * wave(t, 0.55, i * 0.21)
		pose["Coin" .. i] = pa(d[1] * out, bob + out * 0.5, d[2] * out, 25 * wave(t, 0.375, i * 0.3), 180 * t + i * 50, 0)
	end

	-- cartoon "ting!" glints on the gold
	local g1 = env(c, 0.55, 0.08, 0.04, 0.2) + env(c, 2.15, 0.08, 0.04, 0.2) + env(c, 7.55, 0.08, 0.04, 0.2)
	local g2 = env(c, 1.5, 0.08, 0.04, 0.2) + env(c, 4.62, 0.08, 0.04, 0.2) + env(c, 6.85, 0.08, 0.04, 0.2)
	pose.Glint1 = ang(0, 0, 90 * g1)
	pose.Glint2 = ang(0, 0, -90 * g2)
	for _, sfx in { "a", "b", "c" } do
		ctx.transparency("Glint1" .. sfx, 1 - g1)
		ctx.transparency("Glint2" .. sfx, 1 - g2)
	end

	-- effects ---------------------------------------------------------------------------
	ctx.enable("MouthSparkle", lidAng > 40)
	ctx.light("MouthLight", 0.35 + 1.1 * clamp01((lidAng - 10) / 90))
	if ctx.crossed(3.3) then
		ctx.emit("CoinBurst", 50)
	end
	if ctx.crossed(4.5) then
		ctx.emit("LandDust", 30)
	end
	for _, tc in { 4.8, 5.2, 5.6 } do
		if ctx.crossed(tc) then
			ctx.emit("ChompSparks", 16)
			ctx.emit("CoinBurst", 12)
		end
	end
end

return M
