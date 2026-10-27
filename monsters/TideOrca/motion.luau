--!nocheck
-- Atlantean Tide Orca motion. Personality: MISCHIEVOUS ROYAL PRANKSTER.
-- Idle: powerful vertical orca swim wave (flukes beat up/down), pectoral
-- paddles, hover bob, playful head tilts, blinks, bubbles, floating Atlantis
-- cubes. Prank beats in the idle:
--   0.5  sly side-glance to its right, cocked brow pops higher
--   1.55 FAKE-OUT LUNGE: pulls back, snaps forward jaws wide... stops short
--        and bounces back with a smug head tilt
--   2.6  TONGUE-OUT TEASE: tongue wags, head waggles, left eye squints and
--        the blowhole squirts voxel water at the crowd
--   9.6  second sly glance (to its left) with an eyebrow waggle, tiny blep
-- Signature "TIDAL CROWN" (every 12 s), a show-off splash meant to soak everyone:
--   3.6  anticipation: DIVES nose-down, sinks, curls, tucks fins, squints
--   4.4  BREACH: rockets up ~9.5 studs nose-first, flukes power-stroke,
--        swirling double water ring appears around it
--   4.5  spinning leap: double barrel roll (720), rings counter-spin
--   5.1  apex: crown gem FLASHES (gem burst + light), crown pops up
--   5.6  tips over into a belly-flop, fins flared wide
--   6.2  SPLASH: squash, crown knocked crooked, wave ring bursts outward,
--        droplet cubes + splash + mist, head & tail flop then spring back
--   7.6  happy double TAIL SLAP (splash on each slap)
--   8.6  cheeky grin + WINK (left eye), brow cocked, tongue blep -> idle
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 12

local sin, cos, pi, max, min, abs, rad = math.sin, math.cos, math.pi, math.max, math.min, math.abs, math.rad
local TAU = 2 * pi
local F = 1 / 12 -- every always-on wave runs whole cycles per loop

local CHAIN = { "Head", "Body1", "Body2", "Tail1", "Tail2", "Tail3", "Fluke" }
local CENTER = 3
local PAMP = { 3, 2, 3, 9, 16, 24, 34 } -- vertical swim wave (abs pitch), head -> fluke
local YAMP = { 5, 3, 2, 4, 6, 8, 9 } -- a little side wiggle on top
local DIVE = { -16, -6, 0, -6, -12, -18, -24 } -- nose-down banana curl, tail up
local STREAM = { 8, 3, 0, 6, 12, 16, 20 } -- launch: tail streams down behind
local FLOP = { -16, -6, 0, 7, 12, 16, 22 } -- belly-flop: ends keep falling
local SLAP = { 7, 3, 0, 14, 26, 38, 50 } -- happy tail slap (big, readable)
local BLINKS = { 0.2, 4.0, 11.55 }

local LAUNCH, APEX, SPLASH = 4.4, 5.1, 6.2
-- floor clearance: base hover lift + extra lift while the big pitches swing
-- the long tail / big head toward the floor
local LIFT, TAIL_LIFT, HEAD_LIFT, LUNGE_LIFT = 1.0, 8, 8, 1.2

local OD = { { 1, 1 }, { -1, 1 }, { 1, -1 }, { -1, -1 }, { -1, 1 } }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes
	------------------------------------------------------------------
	local dive = L.env(c, 3.6, 0.7, 0.1, 0.15, "cubicOut", "expoIn")
	local launch = L.env(c, LAUNCH, 0.15, 0.35, 0.5, "backOut", "cubicInOut")
	local air = L.env(c, LAUNCH, 0.1, 1.2, 0.3)
	local apex = L.env(c, APEX, 0.06, 0.15, 0.5, "quadOut", "quadIn")
	local fall = L.env(c, 5.55, 0.3, 0.3, 0.12, "quadOut", "quadIn")
	local flop = L.env(c, SPLASH, 0.06, 0.06, 1.0, "quadOut", "elasticOut")
	local jolt = L.env(c, SPLASH, 0.05, 0.05, 1.1, "quadOut", "elasticOut")
	local wob = L.env(c, SPLASH, 0.05, 0.6, 1.0)
	local slapW = L.env(c, 7.5, 0.2, 1.2, 0.4)
	local grin = L.env(c, 8.55, 0.15, 0.95, 0.35, "backOut", "cubicInOut")
	local busy = L.env(c, 3.5, 0.3, 3.9, 0.6)
	local swimW = 1 - 0.85 * busy
	local idleW = 1 - max(busy, slapW * 0.6)

	-- prank beats
	local glance1 = L.env(c, 0.5, 0.18, 0.8, 0.25, "backOut", "cubicInOut")
	local glance2 = L.env(c, 9.6, 0.18, 0.8, 0.25, "backOut", "cubicInOut")
	local fakeZ = L.track(c, {
		{ 1.5, 0 }, { 1.8, 1.7, "cubicOut" }, { 1.98, -3.8, "backOut" }, { 2.15, -3.4 },
		{ 2.55, 0.5, "cubicInOut" }, { 2.85, 0, "quadOut" },
	})
	local fakeJaw = L.env(c, 1.8, 0.1, 0.18, 0.25, "backOut", "quadIn")
	local smug = L.env(c, 2.15, 0.2, 0.45, 0.3, "backOut", "quadInOut")
	local tease = L.env(c, 2.6, 0.15, 0.55, 0.2, "backOut", "quadIn")
	local blep = L.env(c, 10.9, 0.12, 0.35, 0.15, "backOut", "quadIn")

	------------------------------------------------------------------
	-- root tracks (dive -> breach -> spin -> belly-flop -> tail slaps)
	------------------------------------------------------------------
	local jumpY = L.track(c, {
		{ 3.5, 0 }, { 4.3, -2.3, "cubicOut" }, { LAUNCH, -2.4 }, { 4.9, 7.6, "cubicOut" },
		{ 5.15, 9.4, "quadOut" }, { 5.45, 8.9, "quadIn" }, { SPLASH, -2.3, "quadIn" },
		{ SPLASH + 0.12, -2.8, "quadOut" }, { 7.3, 0, "elasticOut" },
		{ 7.6, 0 }, { 7.9, -0.7, "quadIn" }, { 8.15, 0.3, "quadOut" }, { 8.45, -0.6, "quadIn" }, { 9.0, 0, "backOut" },
	})
	local bodyPitch = L.track(c, {
		{ 3.5, 0 }, { 4.3, -30, "cubicOut" }, { LAUNCH, -32 }, { 4.62, 52, "backOut" }, { 5.0, 38 },
		{ 5.5, 0, "quadInOut" }, { 6.0, -14, "quadIn" }, { SPLASH + 0.05, 4, "quadOut" }, { 7.0, 0, "elasticOut" },
	})
	local spin = L.track(c, { { 4.5, 0 }, { 5.85, 720, "cubicInOut" } })
	local leapZ = L.track(c, { { 4.4, 0 }, { 5.2, -2.5, "quadOut" }, { SPLASH, -1.5 }, { 7.3, 0, "cubicInOut" } })
	local slapT = L.track(c, {
		{ 7.5, 0 }, { 7.75, -1, "backOut" }, { 7.9, 0.7, "quadIn" }, { 8.1, -0.8, "quadOut" },
		{ 8.45, 0.7, "quadIn" }, { 9.0, 0, "cubicInOut" },
	})

	------------------------------------------------------------------
	-- absolute pitch / yaw along the body
	------------------------------------------------------------------
	local SW = 6 * F -- 0.5 Hz swim
	local kickPh = 2.4 * (c - LAUNCH)
	local wobPh = 3.0 * (c - SPLASH)
	local pitch, yaw = {}, {}
	for i = 1, #CHAIN do
		local swim = PAMP[i] * sin(TAU * (SW * t - 0.11 * (i - 1)))
		local kick = (i >= 4 and 1 or 0) * PAMP[i] * 1.4 * air * sin(TAU * (kickPh - 0.12 * (i - 1)))
		pitch[i] = swimW * swim + DIVE[i] * dive + STREAM[i] * launch * (1 - fall) + kick
			+ FLOP[i] * flop + SLAP[i] * slapT
		pitch[i] += 7 * wob * sin(TAU * (wobPh - 0.12 * (i - 1))) * (i == 3 and 0 or 1)
		yaw[i] = swimW * YAMP[i] * sin(TAU * (SW * t - 0.13 * (i - 1) + 0.25))
	end
	-- head: playful look-arounds, glances, fake-lunge tilt, tease waggle
	local glanceYaw = -14 * glance1 + 14 * glance2
	yaw[1] += (6 * L.noise(t, 3.1, 0.3) + 4 * wave(t, 2 * F, 0.3)) * idleW + glanceYaw
	pitch[1] += 4 * wave(t, 12 * F, 0.1) * idleW - 10 * fakeJaw * 0.5 + 8 * smug + 10 * tease + 10 * apex + 8 * grin

	-- root: hover bob + prank lunge + the Tidal Crown
	local bob = 0.9 * wave(t, SW) * (1 - 0.7 * busy)
	local sp = sin(rad(bodyPitch))
	local clear = LIFT + TAIL_LIFT * max(0, sp) + HEAD_LIFT * max(0, -sp) + LUNGE_LIFT * fakeJaw
	local by = bob + jumpY + clear + 0.3 * L.bounce(t, 6 * F) * idleW
	local bz = fakeZ + leapZ
	local bx = 0.4 * wave(t, SW, 0.3) * swimW
	local roll = 5 * wave(t, SW, 0.15) * swimW + 10 * wob * sin(TAU * (wobPh + 0.3)) + spin
		+ 8 * smug - 6 * grin
	pose.Body2 = pa(bx, by, bz, pitch[CENTER] + bodyPitch, yaw[CENTER], roll)
	for i = CENTER - 1, 1, -1 do
		local r = 0
		if CHAIN[i] == "Head" then
			r = 9 * wave(t, 3 * F, 0.2) * idleW + 16 * tease * sin(TAU * 3 * (c - 2.6)) - 14 * smug
				+ 12 * grin + 8 * glance1 - 8 * glance2 + 10 * wob * sin(TAU * (wobPh * 1.2))
		end
		pose[CHAIN[i]] = ang(pitch[i] - pitch[i + 1], yaw[i] - yaw[i + 1], r)
	end
	for i = CENTER + 1, #CHAIN do
		pose[CHAIN[i]] = ang(pitch[i] - pitch[i - 1], yaw[i] - yaw[i - 1], 0)
	end

	------------------------------------------------------------------
	-- flukes flex (lag behind the beat), spread on the splash
	------------------------------------------------------------------
	local flex = 10 * wave(t, SW, -0.35) * swimW + 22 * air * sin(TAU * (kickPh - 0.9)) + 18 * flop
		- 16 * slapT
	L.both(pose, "Fluke", ang(0, 0, flex))

	------------------------------------------------------------------
	-- dorsal fin: sway + jelly wobble after the splash and slaps
	------------------------------------------------------------------
	local dW = 5 * wave(t, SW, 0.1) * swimW + 20 * wob * sin(TAU * (wobPh * 1.3)) + 10 * slapW * sin(TAU * 2.5 * (c - 7.5))
	pose.Dorsal = ang(-6 * launch + 6 * fall + 8 * flop, 0, dW)
	pose.DorsalTip = ang(-8 * launch + 10 * flop, 0, 1.4 * dW + 6 * wave(t, SW, -0.15) * swimW)

	------------------------------------------------------------------
	-- pectoral fins: paddle, sweep back in the lunge / dive, flare for the
	-- belly-flop, happy flutter
	------------------------------------------------------------------
	local paddle = wave(t, 8 * F)
	local slick = max(dive, launch * (1 - fall), L.env(c, 1.8, 0.1, 0.2, 0.3))
	local flapZ = 26 * paddle * swimW + 36 * fall + 20 * flop - 15 * slick + 22 * grin * sin(TAU * 4 * (c - 8.55))
		+ 18 * tease * sin(TAU * 3 * (c - 2.6))
	local sweep = 18 * wave(t, 8 * F, 0.25) * swimW - 55 * slick + 20 * fall
	L.both(pose, "Fin", ang(0, sweep, flapZ))
	L.both(pose, "FinTip", ang(0, 0, 20 * wave(t, 8 * F, -0.15) * swimW - 10 * slick + 20 * flop))

	------------------------------------------------------------------
	-- jaw: smirk-open at rest, gape on the fake lunge, laugh, grin
	------------------------------------------------------------------
	local laugh = smug * L.wave01(c, 6.0, 0.25)
	local jawA = -10 * idleW - 48 * fakeJaw - 14 * laugh - 22 * tease - 26 * launch * (1 - fall) - 30 * apex
		+ 4 * dive - 20 * flop * (1 - jolt * 0.5) - 20 * grin - 14 * blep - 12 * glance2 * L.wave01(c, 3, 0.25)
	-- lopsided smirk: the jaw hangs crooked (open on the right, tight on the left)
	pose.Jaw = ang(jawA, 0, -9 * idleW - 8 * smug - 6 * grin)
	-- tongue: tease wag, blep after the wink and in the late idle
	local tOut = max(tease, 0.6 * grin, 0.8 * blep)
	pose.Tongue = pa(0, 0.3 * tOut, -2.6 * tOut, -16 * tOut, 18 * tease * sin(TAU * 5 * (c - 2.6)) + 8 * grin * sin(TAU * 3 * (c - 8.55)), 0)

	------------------------------------------------------------------
	-- eyes: sly pupils, cocked / waggling brows, blinks, squints, WINK
	------------------------------------------------------------------
	-- front pupils slide in X (clamped so they stay on the eye face); the
	-- side pupils slide only along the side face (Y/Z) so they never float
	local px = max(-0.35, min(0.35, 0.33 * glance1 - 0.33 * glance2 + 0.07 * L.noise(t, 9.3, 0.4) * idleW))
	local py = max(-0.28, min(0.28, -0.25 * dive + 0.2 * apex - 0.12 * smug))
	pose.PupilR = CFrame.new(px, py, 0)
	pose.PupilL = CFrame.new(px, py, 0)
	pose.PupilSR = CFrame.new(0, py, -0.32 * glance2 + 0.3 * glance1)
	pose.PupilSL = CFrame.new(0, py, -0.32 * glance1 + 0.3 * glance2)

	local waggle = glance2 * max(0, sin(TAU * 3 * (c - 9.7)))
	local idleBrow = 0.08 * L.bounce(t, 6 * F) * idleW
	-- right brow: the cocked one (pops way up on glances / smug / wink)
	local bR = idleBrow + 0.75 * glance1 + 0.7 * waggle + 0.55 * smug + 0.65 * grin + 0.45 * apex - 0.6 * dive
		+ 0.35 * fakeJaw
	pose.BrowR = pa(0, bR, 0, 0, 0, -10 * glance1 + 8 * grin - 6 * waggle)
	-- left brow: low and scheming, squashes down on the wink
	local bL = -0.4 * grin + 0.3 * apex - 0.3 * tease + 0.2 * glance2 - 0.35 * dive
	pose.BrowL = L.mirror(pa(0, bL, 0, 0, 0, 10 * grin + 8 * tease - 6 * glance1))

	local blinkR, blinkL = 0, 0
	for _, b in BLINKS do
		local e = L.env(c, b, 0.06, 0.06, 0.1)
		blinkR, blinkL = max(blinkR, e), max(blinkL, e)
	end
	local squeeze = L.env(c, SPLASH - 0.02, 0.05, 0.2, 0.15)
	blinkR = max(blinkR, 0.4 * dive, squeeze)
	-- the left eye rests HALF-LIDDED (smug, scheming) except when it pops open
	-- for the breach / apex
	local smugLid = 0.27 * (1 - max(launch, apex, air))
	blinkL = max(blinkL, smugLid, 0.4 * dive, squeeze, 0.5 * tease, L.env(c, 8.7, 0.08, 0.55, 0.15))
	pose.LidR = CFrame.new(0, -2.15 * blinkR, 0)
	pose.LidL = CFrame.new(0, -2.15 * blinkL, 0)
	ctx.transparency("EyelidR", blinkR > 0.05 and 0 or 1)
	ctx.transparency("LashR", blinkR > 0.05 and 0 or 1)
	ctx.transparency("EyelidL", blinkL > 0.05 and 0 or 1)
	ctx.transparency("LashL", blinkL > 0.05 and 0 or 1)

	------------------------------------------------------------------
	-- crown: idle wobble, pops up at the apex, knocked crooked by the
	-- splash, wiggles back
	------------------------------------------------------------------
	local crooked = L.env(c, SPLASH, 0.05, 0.6, 1.0, "backOut", "elasticOut")
	pose.Crown = pa(0.35 * crooked, 0.15 * wave(t, 6 * F, 0.3) + 0.9 * apex - 0.3 * jolt, 0,
		3 * wave(t, 3 * F) - 6 * crooked, 0, 2 * wave(t, 3 * F, 0.25) - 14 * crooked + 4 * smug)

	------------------------------------------------------------------
	-- floating cubes: bob + tumble, drawn up by the breach, flung by splash
	------------------------------------------------------------------
	for i = 1, 5 do
		local d = OD[i]
		local out = 2.6 * jolt
		local dx = 0.7 * wave(t, 2 * F, i * 0.21) + out * d[1]
		local dy = 1.0 * wave(t, 4 * F, i * 0.27) + 2.0 * air - 1.0 * jolt
		local dz = 0.7 * wave(t, 2 * F, i * 0.21 + 0.25) + out * 0.4 * d[2]
		local s = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(dx, dy, dz, 360 * 2 * F * t * s + 30 * i, 360 * 3 * F * t, 25 * i)
	end

	------------------------------------------------------------------
	-- swirling water rings (counter-spinning, ride with the leap)
	------------------------------------------------------------------
	local ringOn = c > LAUNCH + 0.02 and c < 6.05
	local ringTr = 1
	if ringOn then
		local fin_ = L.remap(c, 5.75, 6.05)
		local fadeIn = 1 - L.remap(c, LAUNCH, LAUNCH + 0.2)
		ringTr = max(fadeIn, fin_) * 0.9 + 0.1
	end
	local rs = 360 * 1.6 * (c - LAUNCH)
	pose.SpinRing = pa(0, jumpY + clear, bz, bodyPitch, 0, spin + rs)
	pose.SpinRing2 = pa(0, jumpY + clear, bz, bodyPitch, 0, -spin - rs)
	for k = 1, 22 do
		ctx.transparency("RingPart" .. k, ringOn and ringTr or 1)
	end

	------------------------------------------------------------------
	-- wave ring bursting outward + droplet cubes after the belly-flop
	------------------------------------------------------------------
	local WD = 1.35
	local wu = L.remap(c, SPLASH - 0.02, SPLASH - 0.02 + WD)
	local wOn = c > SPLASH - 0.02 and c < SPLASH - 0.02 + WD
	local we = L.ease.cubicOut(wu)
	for k = 1, 12 do
		local deg = (k - 1) * 30 + 15
		local a = rad(deg)
		local r = 4.8 + 11 * we
		-- rears up out of the "water" fast, crests, then rolls over and sinks
		local rise = L.ease.backOut(min(1, wu * 4))
		local y = -2.4 + 4.2 * rise - 3.6 * L.ease.quadIn(L.remap(wu, 0.45, 1))
		local lean = -10 + 45 * wu
		local cf = pa(sin(a) * r, y + 0.25 * sin(TAU * (2 * wu + k * 0.17)), cos(a) * r, 0, deg, 0) * ang(lean, 0, 0)
		pose["Wave" .. k] = wOn and cf or CFrame.new()
		local tr = wOn and (wu > 0.6 and (wu - 0.6) / 0.4 or 0.1) or 1
		ctx.transparency("WavePart" .. k, tr)
		ctx.transparency("CrestPart" .. k, tr)
		ctx.transparency("FoamPart" .. k, wOn and (wu > 0.6 and (wu - 0.6) / 0.4 or 0) or 1)
	end
	local du = L.remap(c, SPLASH, SPLASH + 1.0)
	local dOn = c > SPLASH and c < SPLASH + 1.0
	local de = L.ease.cubicOut(du)
	for k = 1, 6 do
		local a = rad(k * 60 + 15)
		local r = 2.5 + (k % 2 == 0 and 9 or 6) * de
		local y = (k % 2 == 0 and 7 or 11) * 4 * du * (1 - du)
		local sp = 400 * du * (k % 2 == 0 and -1 or 1)
		pose["Drop" .. k] = dOn and pa(sin(a) * r, y, cos(a) * r, sp, sp * 0.6, 30 * k) or CFrame.new()
		ctx.transparency("DropPart" .. k, dOn and (du > 0.7 and (du - 0.7) / 0.3 or 0) or 1)
	end

	------------------------------------------------------------------
	-- blowhole squirt (the prank): cubes arc up and forward at the crowd
	------------------------------------------------------------------
	local SQ = 2.75
	for k = 1, 4 do
		local u = (c - SQ - (k - 1) * 0.07) / 0.95
		local on = u > 0 and u < 1
		local spread = (k - 2.5) * 0.9
		pose["Squirt" .. k] = on and pa(spread * 1.4 * u, 10 * 4 * u * (1 - u) - 2 * u, -8 * u, 300 * u, 200 * u, 45) or CFrame.new()
		ctx.transparency("SquirtPart" .. k, on and (u > 0.8 and (u - 0.8) / 0.2 * 0.8 + 0.2 or 0.2) or 1)
	end

	------------------------------------------------------------------
	-- effects on the beats
	------------------------------------------------------------------
	if ctx.crossed(SQ) then
		ctx.emit("SpoutBurst", 30)
	end
	if ctx.crossed(1.98) then
		ctx.emit("AmbientBubbles", 12)
	end
	if ctx.crossed(LAUNCH + 0.05) then
		ctx.emit("SplashBurst", 30)
		ctx.emit("FlukeSplash", 20)
	end
	if ctx.crossed(APEX) then
		ctx.emit("GemBurst", 50)
		ctx.emit("AmbientSparkle", 12)
	end
	if ctx.crossed(SPLASH) then
		ctx.emit("SplashBurst", 60)
		ctx.emit("SplashMist", 26)
		ctx.emit("AmbientBubbles", 20)
	end
	if ctx.crossed(7.9) then
		ctx.emit("FlukeSplash", 26)
	end
	if ctx.crossed(8.45) then
		ctx.emit("FlukeSplash", 26)
	end
	if ctx.crossed(8.7) then
		ctx.emit("GemBurst", 14)
		ctx.emit("AmbientSparkle", 8)
	end
	local flash = L.env(c, APEX, 0.05, 0.25, 0.6)
	ctx.light("GemLight", min(1.5, 0.45 + 0.15 * wave(t, 6 * F) + 1.05 * max(flash, 0.6 * grin)))
	ctx.light("RingLight", ringOn and min(1.2, 1.2 * (1 - ringTr) + 0.6 * L.env(c, SPLASH, 0.05, 0.1, 0.4)) or 0.6 * L.env(c, SPLASH, 0.05, 0.1, 0.4))
end

return M
