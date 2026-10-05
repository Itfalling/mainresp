--!nocheck
-- Spore Lord motion: squishy waddle idle (cap wobbling with lag, arms
-- swinging, back mushrooms jiggling, blinks, little chomps), then the
-- SPORE BURST: deep anticipation squat -> big jump (cap tilts back) ->
-- SPLAT landing squash -> cap pumps twice -> BLAST of voxel spores with the
-- arms thrown wide -> wobbly follow-through and settle.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease
local track, env, clamp01, remap = L.track, L.env, L.clamp01, L.remap
local exp, sin, pi, max = math.exp, math.sin, math.pi, math.max

local M = {}
M.Cycle = 8

local T_LAUNCH, T_LAND, T_BLAST = 3.62, 4.3, 4.78

-- damped spring wobble that starts at t0
local function ring(c, t0, hz, decay)
	if c < t0 then
		return 0
	end
	local x = c - t0
	return exp(-decay * x) * sin(2 * pi * hz * x)
end

-- spore puff flight: 12 directions around the cap; even = float up, odd = arc down
local PUFFS = {}
for i = 1, 12 do
	local a = math.rad((i - 1) * 30 + 15 + (i % 3) * 7)
	local high = i % 2 == 0
	PUFFS[i] = { math.sin(a), -math.cos(a), high and 1.7 or 0.5, high and 0.25 or 2.2, i % 2 == 0 and 1 or -1, 6.5 + (i % 3) * 1.2 }
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- signature move channels (keyframes in cycle time)
	------------------------------------------------------------------
	local sig = env(c, 2.4, 0.35, 3.75, 0.7)
	local idleW = 1 - sig

	local hipY = track(c, {
		{ 2.4, 0 },
		{ 3.0, -1.1, "cubicOut" },
		{ 3.3, -1.25 },
		{ T_LAUNCH, 4.0, "cubicOut" },
		{ 4.0, 4.9, "quadOut" },
		{ T_LAND, -1.15, "quadIn" },
		{ 4.38, -1.3, "linear" },
		{ 4.5, -0.55, "quadOut" },
		{ 4.6, -1.0, "quadIn" },
		{ 4.68, -0.6, "quadOut" },
		{ 4.78, -1.2, "quadIn" },
		{ 4.95, 0.6, "backOut" },
		{ 5.5, 0.4 },
		{ 5.9, -0.5, "quadInOut" },
		{ 6.25, 0.2, "quadInOut" },
		{ 6.6, -0.1 },
		{ 6.9, 0 },
	})
	local hipPitch = track(c, {
		{ 2.4, 0 }, { 3.0, -6, "cubicOut" }, { 3.3, -7 }, { T_LAUNCH, 4, "cubicOut" }, { 4.0, 0, "quadInOut" },
		{ T_LAND, -5, "quadIn" }, { 4.5, -2, "quadOut" }, { 4.78, -4, "quadIn" }, { 4.95, 4, "backOut" },
		{ 5.5, 3 }, { 6.0, -1, "quadInOut" }, { 6.5, 0 },
	})
	local chestY = track(c, {
		{ 2.4, 0 }, { 3.0, -0.5 }, { 3.3, -0.6 }, { T_LAUNCH, 0.3, "cubicOut" }, { 4.0, 0.1 },
		{ T_LAND, -0.6, "quadIn" }, { 4.45, -0.3 }, { 4.6, -0.5 }, { 4.7, -0.3 }, { 4.78, -0.6 },
		{ 4.95, 0.35, "backOut" }, { 5.5, 0.2 }, { 6.0, -0.2 }, { 6.5, 0 },
	})
	local chestPitch = track(c, {
		{ 2.4, 0 }, { 3.0, -8, "cubicOut" }, { 3.3, -9 }, { T_LAUNCH, 6, "cubicOut" }, { 4.0, 2 },
		{ T_LAND, -5, "quadIn" }, { 4.5, -2 }, { 4.78, -5 }, { 4.95, 3, "backOut" }, { 5.5, 2 },
		{ 6.0, -2, "quadInOut" }, { 6.5, 0 },
	})
	local headPitch = track(c, {
		{ 2.4, 0 }, { 3.0, 15 }, { 3.3, 17 }, { T_LAUNCH, 10, "cubicOut" }, { 4.0, 4 },
		{ T_LAND, -2, "quadIn" }, { 4.45, 2 }, { 4.6, -3 }, { 4.7, 1 }, { 4.78, -4 },
		{ 4.95, 12, "backOut" }, { 5.4, 9 }, { 5.9, -4, "quadInOut" }, { 6.3, 3 }, { 6.6, 0 },
	})
	local headY = track(c, {
		{ 2.4, 0 }, { 3.0, -0.35 }, { T_LAUNCH, 0.3 }, { 4.0, 0.1 }, { T_LAND, -0.45, "quadIn" },
		{ 4.5, -0.2 }, { 4.78, -0.45 }, { 4.95, 0.4, "backOut" }, { 5.5, 0.2 }, { 6.0, 0 },
	})
	local jaw = track(c, {
		{ 2.4, 0 }, { 3.0, -6 }, { 3.3, -4 }, { T_LAUNCH, -38, "cubicOut" }, { 4.0, -30 }, { 4.25, -8 },
		{ T_LAND, 0 }, { 4.78, 0 }, { 4.92, -55, "backOut" }, { 5.55, -50 }, { 5.9, -6, "quadInOut" },
		{ 6.1, -12 }, { 6.4, 0 },
	})
	local capY = track(c, {
		{ 2.4, 0 }, { 3.0, -0.6 }, { 3.3, -0.65 }, { 3.5, -0.8, "quadIn" }, { 3.85, 0.6, "backOut" },
		{ 4.15, 0.4 }, { 4.32, -0.8, "quadIn" }, { 4.45, -0.2 }, { 4.52, 0.7, "quadOut" }, { 4.62, -0.3, "quadIn" },
		{ 4.7, 0.8, "quadOut" }, { 4.8, -0.5, "quadIn" }, { 4.95, 1.3, "backOut" }, { 5.5, 1.0 },
		{ 5.85, -0.3, "quadInOut" }, { 6.2, 0.15 }, { 6.5, 0 },
	})
	local capPitch = track(c, {
		{ 2.4, 0 }, { 3.0, -5 }, { 3.3, -6 }, { T_LAUNCH, 28, "cubicOut" }, { 3.95, -10, "quadInOut" },
		{ 4.15, -4 }, { 4.32, -10, "quadIn" }, { 4.45, 6, "quadOut" }, { 4.55, -5 }, { 4.65, 5 }, { 4.75, -6 },
		{ 4.95, 4, "backOut" }, { 5.5, 3 }, { 5.85, -4, "quadInOut" }, { 6.15, 4 }, { 6.45, -2 }, { 6.7, 0 },
	})
	local armZ = track(c, {
		{ 2.4, 0 }, { 3.0, 15 }, { 3.3, 18 }, { T_LAUNCH, 105, "cubicOut" }, { 4.0, 115 }, { T_LAND, 25, "quadIn" },
		{ 4.5, 15 }, { 4.78, -5, "quadIn" }, { 4.92, 100, "backOut" }, { 5.5, 92 }, { 6.0, 10, "quadInOut" }, { 6.4, 0 },
	})
	local armX = track(c, {
		{ 2.4, 0 }, { 3.0, -50, "cubicOut" }, { 3.3, -55 }, { T_LAUNCH, 20, "cubicOut" }, { 4.0, 10 },
		{ T_LAND, -20, "quadIn" }, { 4.5, 10 }, { 4.78, 35, "quadIn" }, { 4.92, -5, "backOut" }, { 5.5, -5 },
		{ 6.0, 0, "quadInOut" },
	})
	local handX = track(c, {
		{ 2.4, 0 }, { 3.0, -20 }, { T_LAUNCH, 30 }, { 4.0, 20 }, { T_LAND, -10 }, { 4.78, 40 },
		{ 4.92, -15, "backOut" }, { 5.5, -10 }, { 6.0, 0 },
	})
	local handZ = track(c, { { 4.78, 0 }, { 4.92, 25, "backOut" }, { 5.5, 20 }, { 6.0, 0 } })
	-- the cap SPINS like a top while it blasts the spores out
	local capSpin = track(c, { { T_BLAST - 0.02, 0 }, { T_BLAST + 0.8, 360, "cubicOut" } })
	local squat = clamp01(-hipY / 1.2) -- leg splay amount
	local air = clamp01(hipY / 2)

	-- impact wobbles
	local wobLand = ring(c, T_LAND, 2.2, 3.5)
	local wobBlast = ring(c, 4.95, 1.8, 2.8)

	------------------------------------------------------------------
	-- idle: squishy waddle
	------------------------------------------------------------------
	local wad = wave(t, 0.6) -- +1 right foot up, -1 left foot up
	local bnc = L.bounce(t, 1.2) -- 1 while a foot is up, 0 on contact
	local squish = 1 - bnc
	local breathe = wave(t, 0.35)
	local look = L.noise(t, 3.7, 0.3) * 18

	-- HIPS
	local hy = (0.9 * bnc - 0.3) * idleW + hipY
	pose.Hips = pa(0, hy, 0, hipPitch, 6 * wad * idleW, 10 * wad * idleW)

	-- LEGS stay upright (counter the hip roll), splay on squats
	L.both(pose, "Leg", ang(-hipPitch * 0.6, 0, -10 * wad * idleW + 10 * squat), ang(-hipPitch * 0.6, 0, 10 * wad * idleW + 10 * squat))

	-- FEET (on Root): march in place, follow the body into the air
	local liftR = max(0, wad) ^ 1.3 * idleW
	local liftL = max(0, -wad) ^ 1.3 * idleW
	local footAir = max(0, hipY - 0.4)
	local tuck = -25 * air
	local kick = 0.4 * air * wave(t, 3)
	L.both(pose, "Foot",
		pa(0.3 * squat, 1.1 * liftR + footAir, -0.3 * liftR + kick, 18 * liftR + tuck, 0, 0),
		pa(0.3 * squat, 1.1 * liftL + footAir, -0.3 * liftL - kick, 18 * liftL + tuck, 0, 0))

	-- CHEST: breathing, squash on each step
	pose.Chest = pa(0, -0.35 * squish * idleW + chestY, 0, 3 * breathe * idleW + chestPitch, -4 * wad * idleW, -4 * wad * idleW)

	-- HEAD: bob + look around + counter-roll
	local blastShake = 4 * env(c, 4.95, 0.1, 0.5, 0.3) * wave(t, 7)
	pose.Head = pa(0, -0.15 * squish * idleW + headY, 0,
		(-5 * squish + 2 * breathe) * idleW + headPitch,
		look * idleW + blastShake,
		-4 * wad * idleW + 6 * wobLand)

	-- JAW: occasional chomps in idle, wide yell on the jump, huge blast roar
	local chomp = max(0, wave(t, 0.33, 0.1)) ^ 12 * idleW
	pose.Jaw = ang(-20 * chomp - 3 * squish * idleW + jaw, 0, 0)

	-- CAP: lagging wobble (idle) + pumps/tilts (move) + springy follow-through
	local capLagY = -0.5 * (1 - L.bounce(t - 0.1, 1.2))
	pose.Cap = pa(0, capLagY * idleW + capY, 0,
		(6 * wave(t, 1.2, -0.2)) * idleW + capPitch + 6 * wobBlast,
		capSpin,
		(-9 * wave(t, 0.6, -0.12)) * idleW + 10 * wobLand + 5 * wobBlast)

	-- BLINK (cartoon eyelids) + squeeze shut on the landing
	local blink = env(t % 3.1, 2.75, 0.06, 0.06, 0.1)
	local squeeze = env(c, 4.26, 0.04, 0.12, 0.15)
	L.both(pose, "Lid", CFrame.new(0, -2.45 * max(blink * idleW, squeeze), 0))

	-- ARMS: swing opposite the feet, flap on bounce
	local swing = 28 * wad * idleW
	local zIdle = (10 + 8 * bnc) * idleW
	L.both(pose, "Arm",
		ang(-swing + armX, 0, zIdle + armZ),
		ang(swing + armX, 0, zIdle + armZ))
	local elbow = (15 + 10 * wave(t, 0.6, -0.1)) * idleW
	L.both(pose, "Hand",
		ang(elbow + handX, 0, handZ),
		ang(15 * idleW - 10 * wave(t, 0.6, -0.1) * idleW + handX, 0, handZ))

	-- BACK MUSHROOMS: jiggle with lag, flop on impacts
	for i = 1, 3 do
		local lag = -0.15 - 0.08 * i
		local rx = 9 * wave(t, 1.2, lag) * idleW + 25 * ring(c, T_LAND + 0.03 * i, 3.0, 4) + 20 * ring(c, 4.95 + 0.03 * i, 2.6, 3) - 15 * air
		local rz = 8 * wave(t, 0.6, lag) * idleW + 14 * ring(c, T_LAND + 0.05 * i, 2.4, 3.5)
		pose["Shroom" .. i] = ang(rx, 0, i == 2 and -rz or rz)
	end

	-- ORBITING CUBES: spin, bob, tumble; flung outward by the blast
	local fling = env(c, 4.85, 0.25, 0.5, 0.9, "backOut", "cubicInOut")
	pose.Orbit = ang(0, 35 * t, 0)
	for i = 1, 6 do
		local dir = i % 2 == 0 and -1 or 1
		local bob = 0.8 * wave(t, 0.5, i * 0.27)
		pose["Orb" .. i] = pa(2.5 * fling * dir, bob + 1.5 * fling, 0, 80 * t * dir, 110 * t, 30)
	end

	-- SPORE CLOUD: voxel puffs blast out of the cap, float up and fade
	local pt = c - T_BLAST
	for i, p in PUFFS do
		local name = "Puff" .. i
		if pt >= 0 and pt <= 1.6 then
			local k = E.expoOut(clamp01(pt / 0.9))
			local d = 1.2 + p[6] * k
			local y = 0.4 + p[3] * 2.2 * k - p[4] * 1.4 * pt * pt
			pose[name] = pa(p[1] * d, y, p[2] * d, p[5] * 260 * pt, 320 * pt, p[5] * 45)
			ctx.transparency(name, remap(pt, 0.85, 1.55))
		else
			pose[name] = CFrame.new()
			ctx.transparency(name, 1)
		end
	end
	for i = 1, 2 do
		local name = "Cloud" .. i
		local s = i == 1 and 1 or -1
		if pt >= 0 and pt <= 1.6 then
			local k = E.expoOut(clamp01(pt / 1.0))
			pose[name] = pa(s * 3.2 * k, 0.8 + 1.8 * k + 0.4 * pt, -0.8 * s * k, 0, 60 * pt * s, 0)
			ctx.transparency(name, 0.35 + 0.65 * remap(pt, 0.25, 1.4))
		else
			pose[name] = CFrame.new()
			ctx.transparency(name, 1)
		end
	end

	------------------------------------------------------------------
	-- effects on the beats
	------------------------------------------------------------------
	ctx.enable("SporeSparks", pt > 0 and pt < 0.8)
	ctx.transparency("ThroatGlow", (pt > 0.05 and pt < 0.8) and 0.15 or 1)
	ctx.light("SporeLight", 1.2 * env(c, T_BLAST, 0.08, 0.4, 0.8))
	if ctx.crossed(T_LAUNCH - 0.3) then
		ctx.emit("LandDust", 15)
	end
	if ctx.crossed(T_LAND) then
		ctx.emit("LandDust", 35)
	end
	if ctx.crossed(T_BLAST + 0.02) then
		ctx.emit("SporeBurst", 70)
		ctx.emit("SporeCloud", 18)
	end
end

return M
