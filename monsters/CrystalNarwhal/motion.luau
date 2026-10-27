--!nocheck
-- Crystal Narwhal motion. Personality: HYPER & CHEERFUL (a happy puppy of the sea).
-- Idle: bouncy dolphin-kick swim (vertical S-wave head -> flukes), excited fluke
-- WAGS (side to side like a puppy tail), flipper paddles, giggling smile, sparkly
-- spinning eye stars, cartoon blinks, the spiral tusk slowly twisting + twinkling,
-- blowhole bubble puffs, orbiting crystal / marble cubes.
-- Signature "CRYSTAL BREACH" (11 s loop):
--   3.0  anticipation: dives nose-down, tail curls up, flippers tuck, cubes sucked in
--   3.85 LAUNCH: breaches up in an arc, nose high, tail streaming
--   4.2  SPIN on the tusk axis (720) - tusk glows, neon beam + star rays revealed,
--        exaggerated happy "^ ^" squint and a big open laugh at the top
--   4.75 crystal shard burst at the apex
--   5.3  arcs over and falls nose-first
--   5.9  SPLASHDOWN: squash, water cubes + splash + bubble burst, eyes squeeze
--   6.0  wiggly follow-through (fluke flaps, dizzy happy head shake)
--   7.1  puppy joy: double hop + super-fast fluke wag + flipper claps, "^ ^" giggle
--   9.2  little excited barrel-roll spin, then back to the idle swim
--   (plus a mini spin-hop with a "^ ^" squint at 1.9 during the idle wag burst)
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 11

local sin, pi, max, min, abs = math.sin, math.pi, math.max, math.min, math.abs
local TAU = 2 * pi
local F = 1 / 11 -- every always-on wave runs a whole number of cycles per loop

local CHAIN = { "Head", "Body1", "Body2", "Tail1", "Tail2", "Tail3", "Fluke" }
local CENTER = 2
local PAMP = { 5, 3, 6, 10, 15, 21, 30 } -- dolphin-kick pitch (absolute), head -> flukes
local YAMP = { 4, 2, 4, 7, 10, 13, 16 } -- lazy side sway
local WAG = { 8, 3, 8, 16, 26, 36, 48 } -- happy puppy wag (yaw)
local COIL = { -8, 0, -4, -8, -10, -12, -14 } -- dive anticipation: tail curls up
local STREAM = { -6, 0, 6, 9, 12, 14, 16 } -- launch: tail drags behind / below
local CURL = { 10, 0, -6, -10, -13, -15, -18 } -- top of the breach: C-arc, tail up
local FALL = { -6, 0, -5, -8, -10, -10, -10 } -- nose-first fall: tail whips up
local WIG = { 6, 2, 8, 14, 20, 26, 34 } -- splashdown follow-through flaps
local BLINKS = { 1.35, 2.72, 10.35, 10.55 }

local APEX = 4.75
local SPLASH = 5.9

local DROP_A = { 0, 15, 60, 75, 120, 135, 180, 195, 240, 255, 300, 315 }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes
	------------------------------------------------------------------
	local dive = L.env(c, 3.0, 0.75, 0.1, 0.12, "cubicOut", "expoIn")
	local launch = L.env(c, 3.85, 0.2, 0.35, 0.45, "backOut", "cubicInOut")
	local curl = L.env(c, 4.15, 0.3, 0.6, 0.45, "cubicOut", "cubicInOut")
	local glow = L.env(c, 4.2, 0.12, 0.85, 0.3, "quadOut", "quadIn")
	local burst = L.env(c, APEX, 0.06, 0.15, 0.5, "quadOut", "quadIn")
	local fall = L.env(c, 5.3, 0.3, 0.25, 0.15, "quadOut", "quadIn")
	local slam = L.env(c, SPLASH, 0.05, 0.08, 0.8, "quadOut", "elasticOut")
	local wig = L.env(c, SPLASH + 0.05, 0.1, 0.45, 0.9, "quadOut", "quadIn")
	local joy = L.env(c, 7.1, 0.25, 1.5, 0.4) -- puppy joy section
	local wagIdle = L.env(c, 0.6, 0.3, 1.3, 0.4) -- idle excited wag burst
	local busyBreach = L.env(c, 2.9, 0.25, 3.8, 0.45)
	local busyJoy = max(joy, L.env(c, 9.15, 0.1, 0.7, 0.3), 0.7 * L.env(c, 1.85, 0.1, 0.6, 0.25))
	local idleW = 1 - max(busyBreach, busyJoy)
	local swimW = 1 - 0.85 * busyBreach - 0.45 * busyJoy

	-- root tracks
	local jumpY = L.track(c, {
		-- little excited spin hop in the idle
		{ 1.85, 0 }, { 2.15, 1.6, "quadOut" }, { 2.5, -0.3, "quadIn" }, { 2.75, 0, "quadOut" },
		{ 3.0, 0 }, { 3.75, -0.8, "cubicOut" }, { 3.85, -0.9 }, { 4.5, 9.0, "cubicOut" },
		{ 4.9, 10.0, "quadOut" }, { 5.3, 9.0, "quadIn" }, { SPLASH, -1.6, "quadIn" },
		{ SPLASH + 0.12, -1.9, "quadOut" }, { 6.9, 0, "elasticOut" },
		-- puppy hops
		{ 7.15, 0 }, { 7.35, -0.7, "quadOut" }, { 7.62, 2.6, "backOut" }, { 7.9, -0.5, "quadIn" },
		{ 8.15, 2.0, "backOut" }, { 8.45, -0.4, "quadIn" }, { 8.9, 0, "elasticOut" },
		-- excited spin hop
		{ 9.15, 0 }, { 9.3, -0.6, "quadOut" }, { 9.6, 2.4, "backOut" }, { 10.0, -0.5, "quadIn" },
		{ 10.6, 0, "elasticOut" },
	})
	local bodyPitch = L.track(c, {
		{ 3.0, 0 }, { 3.75, -24, "cubicOut" }, { 3.85, -24 }, { 4.2, 50, "backOut" }, { 4.65, 36, "quadOut" }, { 4.95, 26 },
		{ 5.35, 8, "quadInOut" }, { 5.75, -32, "quadIn" }, { SPLASH + 0.05, 6, "quadOut" },
		{ 6.8, 0, "elasticOut" },
		{ 7.35, 0 }, { 7.6, 14, "backOut" }, { 7.9, -6, "quadIn" }, { 8.15, 12, "backOut" },
		{ 8.45, -4, "quadIn" }, { 8.9, 0, "quadOut" },
	})
	local bz = L.track(c, {
		{ 3.0, 0 }, { 3.75, 1.2, "cubicOut" }, { 4.6, -3.0, "quadOut" }, { SPLASH, -0.8, "quadIn" },
		{ 6.9, 0, "cubicInOut" },
	})
	local spin = L.track(c, { { 4.2, 0 }, { 5.1, 745, "cubicOut" }, { 5.4, 720, "quadInOut" } })
		+ L.track(c, { { 9.2, 0 }, { 9.95, 360, "backOut" } })
		- L.track(c, { { 1.9, 0 }, { 2.5, 360, "backOut" } })

	------------------------------------------------------------------
	-- swim chain: dolphin kick (pitch) + sway / puppy wag (yaw)
	------------------------------------------------------------------
	local SW = 6 * F
	local wigPhase = 3.0 * (c - SPLASH)
	local wagAmt = max(wagIdle, joy)
	local yaw, pitch = {}, {}
	for i = 1, #CHAIN do
		local kick = PAMP[i] * sin(TAU * (SW * t - 0.1 * (i - 1)))
		local sway = YAMP[i] * sin(TAU * (3 * F * t - 0.08 * (i - 1)))
		local wag = WAG[i] * wagAmt * sin(TAU * (33 * F * t - 0.1 * (i - 1)))
		yaw[i] = swimW * sway + wag
		pitch[i] = swimW * kick + COIL[i] * dive + STREAM[i] * launch * (1 - curl) + CURL[i] * curl
			+ FALL[i] * fall + WIG[i] * wig * sin(TAU * (wigPhase - 0.1 * (i - 1)))
	end
	-- idle look-around + happy head bops
	yaw[1] += (8 * L.noise(t, 2.1, 0.35) + 4 * wave(t, 2 * F, 0.3)) * idleW
	pitch[1] += 7 * wave(t, 12 * F, 0.1) * idleW + 16 * burst + 12 * joy * wave(t, 22 * F) - 10 * dive + 12 * launch * (1 - curl)

	------------------------------------------------------------------
	-- root: bouncy hover + breach / splash / hops / spins
	------------------------------------------------------------------
	local hop = abs(sin(TAU * 3 * F * t)) -- bouncy idle hops
	local bob = (1.0 * wave(t, SW) + 0.7 * hop) * (1 - 0.8 * max(busyBreach, busyJoy))
	local by = bob + jumpY
	local roll = 7 * wave(t, SW, 0.15) * swimW + 12 * wagAmt * sin(TAU * (33 * F * t + 0.25))
		+ 12 * wig * sin(TAU * (wigPhase + 0.3))
	pose.Body1 = pa(0, by, bz, pitch[CENTER] + bodyPitch, yaw[CENTER], roll + spin)
	for i = CENTER - 1, 1, -1 do
		local r = 0
		if CHAIN[i] == "Head" then
			r = 14 * wig * sin(TAU * (wigPhase * 1.2 + 0.1)) + 6 * L.noise(t, 7.7, 0.4) * idleW
				+ 10 * joy * sin(TAU * (2 * (c - 7.1)))
		end
		pose[CHAIN[i]] = ang(pitch[i] - pitch[i + 1], yaw[i] - yaw[i + 1], r)
	end
	for i = CENTER + 1, #CHAIN do
		pose[CHAIN[i]] = ang(pitch[i] - pitch[i - 1], yaw[i] - yaw[i - 1], 0)
	end

	-- fluke lobes flex behind the beat
	local flex = 14 * wave(t, SW, -0.25) * swimW + 22 * wig * sin(TAU * (wigPhase - 0.85))
		+ 18 * launch - 14 * dive + 16 * slam
	L.both(pose, "FlukeLobe", ang(0, 6 * wagAmt * sin(TAU * (33 * F * t - 0.8)), flex))

	------------------------------------------------------------------
	-- flippers: paddle, tuck on the dive / launch, wave "yay" at the top,
	-- flare on the splash, happy claps during the joy section
	------------------------------------------------------------------
	local paddle = wave(t, 8 * F)
	local clap = sin(TAU * 4 * (c - 7.1))
	local finZ = 24 * paddle * swimW + 45 * slam - 25 * dive + 40 * curl * (0.6 + 0.4 * sin(TAU * 4 * (c - 4.2)))
		+ 30 * joy * clap + 12 * wagIdle * wave(t, 33 * F, 0.3)
	local finY = 18 * wave(t, 8 * F, 0.25) * swimW - 55 * max(launch, dive) * (1 - curl) + 20 * fall
	L.both(pose, "Flipper", ang(0, finY, finZ))
	L.both(pose, "FlipperTip", ang(0, 0, 22 * wave(t, 8 * F, -0.15) * swimW + 28 * slam - 18 * dive + 20 * joy * clap))

	------------------------------------------------------------------
	-- smile: giggles in idle, wide laugh on the breach and joy
	------------------------------------------------------------------
	local gp = (t / 2.75) % 1
	local giggle = (sin(pi * L.remap(gp, 0, 0.3)) ^ 2) * idleW
	local laugh = max(0.6 * giggle, launch, glow, 0.8 * wig, joy * (0.6 + 0.4 * L.wave01(t, 33 * F)), 0.3 * dive)
	pose.Jaw = ang(-(6 + 26 * laugh), 0, 0)

	------------------------------------------------------------------
	-- eyes: blinks, "^ ^" happy squint at the top + during joy, squeeze on the splash
	------------------------------------------------------------------
	local blink = L.env(c, SPLASH - 0.02, 0.05, 0.3, 0.1)
	for _, b in BLINKS do
		blink = max(blink, L.env(c, b, 0.05, 0.06, 0.05))
	end
	local happyEyes = max(L.env(c, 4.3, 0.05, 0.95, 0.1), L.env(c, 7.4, 0.05, 1.1, 0.1), L.env(c, 9.55, 0.05, 0.4, 0.1), L.env(c, 2.05, 0.05, 0.4, 0.1))
	local isHappy = happyEyes > 0.5
	local isBlink = (not isHappy) and blink > 0.5
	local lidTr = (isHappy or isBlink) and 0 or 1
	for _, s in { "R", "L" } do
		ctx.transparency("Lid" .. s, lidTr)
		ctx.transparency("BlinkLine" .. s, isBlink and 0 or 1)
		ctx.transparency("HappyA" .. s, isHappy and 0 or 1)
		ctx.transparency("HappyB" .. s, isHappy and 0 or 1)
		-- twinkling star sparkle (hidden while the eyes are closed)
		local tw = 0.5 + 0.5 * wave(t, 11 * F, s == "R" and 0 or 0.4)
		local starTr = (isHappy or isBlink) and 1 or (0.55 * (1 - tw))
		ctx.transparency("StarA" .. s, starTr)
		ctx.transparency("StarB" .. s, starTr)
	end
	local starSpin = 360 * 4 * F * t
	pose.EyeStarR = ang(0, 0, starSpin)
	pose.EyeStarL = ang(0, 0, -starSpin)

	------------------------------------------------------------------
	-- tusk: slow twist, drill-spins during the breach, glow beam + rays
	------------------------------------------------------------------
	local twist = 360 * 2 * F * t + L.track(c, { { 4.0, 0 }, { 5.4, 1080, "cubicInOut" } })
	pose.Tusk = ang(0, 0, twist)
	ctx.transparency("TuskTip", glow > 0.05 and 0 or (0.25 + 0.25 * wave(t, 11 * F)))
	ctx.transparency("TuskBeam", glow > 0.05 and (1 - 0.75 * glow) or 1)
	local ru = L.remap(c, 4.25, 5.35)
	for k = 1, 6 do
		local on = glow > 0.05
		local flick = 0.15 * (0.5 + 0.5 * sin(TAU * (6 * c + k * 0.37)))
		ctx.transparency("Ray" .. k, on and min(1, 1 - 0.8 * glow + flick + 0.2 * ru) or 1)
	end
	ctx.light("TuskLight", min(1.5, 0.35 + 0.15 * wave(t, 11 * F) + 1.1 * glow))
	ctx.light("GlowLight", min(1.5, 1.4 * burst + 0.8 * slam + 0.3 * glow))

	------------------------------------------------------------------
	-- floating cubes: bob + tumble, sucked in on the dive, flung by the burst
	------------------------------------------------------------------
	local jolt = L.env(c, SPLASH, 0.06, 0.05, 1.0, "quadOut", "elasticOut")
	local OD = { { 1, 1 }, { -1, 1 }, { 1, -1 }, { -1, -1 }, { 0.3, -0.5 } }
	for i = 1, 5 do
		local d = OD[i]
		local out = 2.4 * jolt + 2.0 * burst - 1.8 * dive
		local dx = 0.8 * wave(t, 2 * F, i * 0.21) + out * d[1]
		local dy = 1.1 * wave(t, 4 * F, i * 0.27) + 1.5 * burst - 1.0 * jolt + 0.6 * joy * abs(sin(TAU * 2 * (c - 7.1) + i))
		local dz = 0.8 * wave(t, 2 * F, i * 0.21 + 0.25) - out * 0.4 * d[2]
		local s = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(dx, dy, dz, 360 * 2 * F * t * s + 30 * i, 360 * 3 * F * t, 25 * i)
	end

	------------------------------------------------------------------
	-- CRYSTAL SHARDS: burst out of the apex, arc, tumble, fade
	------------------------------------------------------------------
	local su = L.remap(c, APEX, APEX + 1.2)
	local shOn = c > APEX and c < APEX + 1.2
	local se = L.ease.cubicOut(su)
	for k = 1, 10 do
		local a = math.rad(k * 36 + 10)
		local e = math.rad(k % 2 == 0 and 40 or -5)
		local r = 2.5 + (k % 3 == 0 and 9 or 12) * se
		local x = math.cos(a) * math.cos(e) * r
		local z = math.sin(a) * math.cos(e) * r - 3.0
		local y = 10.5 + math.sin(e) * r - 7 * su * su
		local tum = 540 * su * (k % 2 == 0 and 1 or -1)
		pose["Shard" .. k] = shOn and pa(x, y, z, tum, tum * 0.7, 20 * k) or CFrame.new()
		ctx.transparency("ShardPart" .. k, shOn and (su > 0.6 and (su - 0.6) / 0.4 or 0) or 1)
	end

	------------------------------------------------------------------
	-- SPLASH: water cubes burst out in a crown, ripple slabs skim outward
	------------------------------------------------------------------
	local pu = L.remap(c, SPLASH, SPLASH + 1.0)
	local pOn = c > SPLASH and c < SPLASH + 1.0
	local pe = L.ease.cubicOut(pu)
	for k = 1, 12 do
		local deg = DROP_A[k]
		local a = math.rad(deg)
		local cfr
		if k % 2 == 1 then
			local r = 3 + (k % 4 == 1 and 7 or 10) * pe
			local y = (k % 4 == 1 and 11 or 8) * 4 * pu * (1 - pu) + 1.0 * pu
			local sp = 400 * pu * (k % 4 == 1 and -1 or 1)
			cfr = pa(math.sin(a) * r, y, math.cos(a) * r, sp, sp * 0.6, 30 * k)
		else
			local r = 3.5 + 10 * pe
			cfr = pa(math.sin(a) * r, -3.3 + 0.4 * pu, math.cos(a) * r, 0, deg, 0)
		end
		pose["Drop" .. k] = pOn and cfr or CFrame.new()
		ctx.transparency("DropPart" .. k, pOn and (pu > 0.65 and (pu - 0.65) / 0.35 or 0) or 1)
	end

	------------------------------------------------------------------
	-- blowhole bubble puffs (idle)
	------------------------------------------------------------------
	for k = 1, 3 do
		local u = (gp - 0.15 - (k - 1) * 0.09) / 0.6
		local on = u > 0 and u < 1 and idleW > 0.95
		pose["Bubble" .. k] = on and pa(0.7 * sin(TAU * (1.5 * u + k * 0.3)) + 0.5 * (k - 2), 5.0 * u + by, 1.2 * u, 0, 90 * u, 45) or CFrame.new()
		ctx.transparency("BubblePart" .. k, on and (u > 0.85 and 1 or 0.4) or 1)
	end

	------------------------------------------------------------------
	-- effects on the beats
	------------------------------------------------------------------
	for j = 0, 3 do
		local tm = 2.75 * j + 0.42
		if ctx.crossed(tm) and (tm < 2.85 or tm > 10.0) then
			ctx.emit("BlowBubbles", 6)
		end
	end
	if ctx.crossed(3.85) then
		ctx.emit("BlowBubbles", 12)
		ctx.emit("AmbientSparkle", 10)
	end
	if ctx.crossed(4.25) then
		ctx.emit("TuskSparkle", 20)
	end
	if ctx.crossed(APEX) then
		ctx.emit("ShardBurst", 60)
		ctx.emit("TuskSparkle", 25)
	end
	if ctx.crossed(SPLASH) then
		ctx.emit("SplashBurst", 50)
		ctx.emit("SplashMist", 24)
		ctx.emit("BubbleBurst", 40)
	end
	if ctx.crossed(7.62) or ctx.crossed(8.15) then
		ctx.emit("AmbientSparkle", 10)
		ctx.emit("BlowBubbles", 8)
	end
	if ctx.crossed(9.6) then
		ctx.emit("ShardBurst", 18)
		ctx.emit("TuskSparkle", 12)
	end
end

return M
