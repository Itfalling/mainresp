--!nocheck
-- Seraph Koi motion.
-- Idle: air-swimming S-wave from the head to the fan tail, bobbing hover,
-- six wings flapping in a staggered ripple (upper -> middle -> lower pair),
-- paddling pectoral fins, floppy gold barbels, gulping "O" mouth (gill covers
-- flare, voxel bubbles wobble up), cartoon blinks, spinning halo, orbiting cubes.
-- Signature "HEAVENLY LEAP" (every 11 s):
--   3.0  anticipation: sinks + coils into a U, all six wings FOLD tight, squint
--   3.85 LAUNCH: shoots up ~9.5 studs, wings flare and beat hard, mouth "O"
--   4.0  full BACKFLIP (360) while the wings keep beating
--   4.65 HOLY BURST at the apex: sun rays, sparkle burst, feathers, halo flash
--   5.3  falls nose-first, wings up like a parachute
--   5.8  SPLASHDOWN: squash, droplet cubes + splash + bubble burst, wings slam
--   5.9  wiggly follow-through (decaying S-wiggle, dizzy head wobble)
--   7.1  happy hop + tail-wag SPIN (360) with a halo flash and happy squint
--   9.0  settle back into the idle swim
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 11

local sin, cos, pi, max, min, abs = math.sin, math.cos, math.pi, math.max, math.min, math.abs
local TAU = 2 * pi
-- every always-on wave runs a whole number of cycles per 11 s loop
local F = 1 / 11

local CHAIN = { "Head", "Body1", "Body2", "Tail1", "Tail2", "Tail3", "TailFan" }
local CENTER = 2
local AMP = { 8, 5, 10, 16, 24, 30, 36 } -- swim yaw (absolute), head -> tail
local COIL = { 24, 6, -8, -16, -22, -26, -26 } -- U-shape (abs pitch): head & tail up
local CURL = { 34, 0, -10, -18, -24, -28, -30 } -- backflip curl (concave back)
local STREAM = { -6, 0, 6, 10, 12, 14, 16 } -- launch: tail streams behind
local WIGGLE = { 18, 6, 12, 20, 28, 34, 40 } -- splashdown follow-through
local BLINKS = { 1.3, 2.35, 9.6, 10.4 }

local SPLASH = 5.8
local LIFT, TAIL_LIFT, HEAD_LIFT = 1.3, 10, 4
local APEX = 4.65

-- wings: phase lag, idle flap amplitude, fold (x, y, z), flare z, parachute z
local WINGS = {
	{ "WingU", 0.0, 26, { 50, -10, 18 }, -12, 30 },
	{ "WingM", 0.12, 24, { 0, -55, -15 }, 18, 40 },
	{ "WingD", 0.24, 20, { 0, -40, -22 }, 26, 34 },
}

local DROP_A = { 0, 15, 60, 75, 120, 135, 180, 195, 240, 255, 300, 315 }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes
	------------------------------------------------------------------
	local coil = L.env(c, 3.0, 0.75, 0.1, 0.12, "cubicOut", "expoIn")
	local fold = L.env(c, 3.0, 0.6, 0.25, 0.12, "cubicOut", "quadIn")
	local launch = L.env(c, 3.85, 0.2, 0.4, 0.5, "backOut", "cubicInOut")
	local air = L.env(c, 3.9, 0.12, 1.25, 0.25) -- wings beating in the air
	local curl = L.env(c, 4.05, 0.35, 0.45, 0.4, "cubicOut", "cubicInOut")
	local burst = L.env(c, APEX, 0.06, 0.15, 0.5, "quadOut", "quadIn")
	local fall = L.env(c, 5.15, 0.3, 0.3, 0.15, "quadOut", "quadIn")
	local slam = L.env(c, SPLASH, 0.05, 0.08, 0.8, "quadOut", "elasticOut")
	local squash = L.env(c, SPLASH, 0.05, 0.1, 0.7, "linear", "backOut")
	local wig = L.env(c, SPLASH + 0.05, 0.1, 0.5, 1.0, "quadOut", "quadIn")
	local hopUp = L.env(c, 7.1, 0.3, 0.75, 0.35, "backOut", "quadIn")
	local spinW = L.env(c, 7.25, 0.2, 0.95, 0.4)
	local happy = L.env(c, 7.3, 0.15, 1.1, 0.3)
	local busyLeap = L.env(c, 2.9, 0.25, 3.7, 0.5)
	local busySpin = L.env(c, 7.0, 0.2, 1.6, 0.5)
	local idleW = 1 - max(busyLeap, busySpin)
	local swimW = 1 - 0.85 * busyLeap - 0.3 * busySpin

	-- big root tracks
	local jumpY = L.track(c, {
		{ 3.0, 0 }, { 3.75, -2.3, "cubicOut" }, { 3.85, -2.4 }, { 4.35, 7.6, "cubicOut" },
		{ 4.75, 9.0, "quadOut" }, { 5.2, 8.3, "quadIn" }, { SPLASH, -1.2, "quadIn" },
		{ SPLASH + 0.12, -1.5, "quadOut" }, { 6.9, 0, "elasticOut" },
		{ 7.1, 0 }, { 7.3, -1.1, "quadOut" }, { 7.7, 3.6, "backOut" }, { 8.15, 3.2 },
		{ 8.45, -0.7, "quadIn" }, { 9.2, 0, "elasticOut" },
	})
	local flip = L.track(c, { { 4.0, 0 }, { 5.25, 360, "cubicInOut" } })
	local spin = L.track(c, { { 7.35, 0 }, { 8.25, 360, "backInOut" } })
	local bodyPitch = L.track(c, {
		{ 3.0, 0 }, { 3.75, -8, "cubicOut" }, { 3.95, 34, "backOut" }, { 4.3, 18 },
		{ 5.25, 0 }, { 5.6, -28, "quadIn" }, { SPLASH + 0.1, 10, "quadOut" }, { 6.8, 0, "elasticOut" },
	})

	------------------------------------------------------------------
	-- absolute heading / pitch along the body
	------------------------------------------------------------------
	local SW = 6 * F
	local wigPhase = 3.0 * (c - SPLASH)
	local wagPhase = 3.0 * (c - 7.2)
	local yaw, pitch = {}, {}
	for i = 1, #CHAIN do
		local swim = AMP[i] * sin(TAU * (SW * t - 0.11 * (i - 1)))
		local w = WIGGLE[i] * wig * sin(TAU * (wigPhase - 0.12 * (i - 1)))
		local wag = (i >= 4 and 1 or 0.3) * AMP[i] * 1.3 * happy * sin(TAU * (wagPhase - 0.12 * (i - 1)))
		yaw[i] = swimW * swim + w + wag
		local bob = 5 * sin(TAU * (SW * t - 0.1 * (i - 1) + 0.25))
		pitch[i] = bob * swimW + COIL[i] * coil + CURL[i] * curl + STREAM[i] * launch * (1 - curl)
			- 10 * (i - 2) * fall * (i > 2 and 1 or 0) + (i == 1 and -14 or 0) * fall
	end
	-- idle look-around
	yaw[1] += (9 * L.noise(t, 2.1, 0.35) + 4 * wave(t, 2 * F, 0.3)) * idleW
	pitch[1] += 5 * wave(t, 12 * F, 0.1) * idleW + 10 * burst + 8 * happy

	------------------------------------------------------------------
	-- root: hover bob + coil / leap / backflip / splash / happy spin
	------------------------------------------------------------------
	local bob = 1.1 * wave(t, SW) * (1 - 0.7 * max(busyLeap, busySpin))
	-- floor clearance: hover a little higher, and lift the body while the big
	-- pitches (launch nose-up, backflip, nose-dive) would swing the long fan
	-- tail / big head down through the floor
	local bigP = math.rad(bodyPitch + flip)
	local clear = LIFT + TAIL_LIFT * max(0, sin(bigP)) + HEAD_LIFT * max(0, -sin(bigP))
	local by = bob + jumpY + clear
	local bz = 1.2 * coil - 1.0 * launch
	local roll = 6 * wave(t, SW, 0.15) * swimW + 14 * wig * sin(TAU * (wigPhase + 0.3)) + 10 * happy * sin(TAU * wagPhase * 0.5)
	pose.Body1 = pa(0, by, bz, pitch[CENTER] + bodyPitch + flip, yaw[CENTER] + spin, roll)
	for i = CENTER - 1, 1, -1 do
		local r = 0
		if CHAIN[i] == "Head" then
			r = 12 * wig * sin(TAU * (wigPhase * 1.2 + 0.1)) + 5 * L.noise(t, 7.7, 0.4) * idleW
		end
		pose[CHAIN[i]] = ang(pitch[i] - pitch[i + 1], yaw[i] - yaw[i + 1], r)
	end
	for i = CENTER + 1, #CHAIN do
		pose[CHAIN[i]] = ang(pitch[i] - pitch[i - 1], yaw[i] - yaw[i - 1], 0)
	end

	------------------------------------------------------------------
	-- fan tail lobes: ripple, spread wide on the leap / splash
	------------------------------------------------------------------
	local spread = 22 * max(launch, slam) + 12 * happy - 14 * coil
	local fl = wave(t, 11 * F, 0.1)
	pose.LobeU = ang(-6 * fl - spread, 12 * wave(t, 6 * F, -0.4), 0)
	pose.LobeD = ang(6 * fl + spread, 12 * wave(t, 6 * F, -0.45), 0)

	------------------------------------------------------------------
	-- six wings: staggered ripple in idle, fold tight, flare + hard beats,
	-- parachute on the fall, slam on the splash, happy flutter
	------------------------------------------------------------------
	local flare = max(launch, burst)
	for _, w in WINGS do
		local name, ph, amp, fd, flz, para = w[1], w[2], w[3], w[4], w[5], w[6]
		local active = 1 - max(fold, air * 0.9)
		local flap = amp * wave(t, 11 * F, -ph) * active
		local beat = 44 * air * sin(TAU * (2.6 * (c - 3.9) - ph))
		local flutter = 18 * happy * sin(TAU * (4 * (c - 7.3) - ph))
		local z = flap + beat + flutter + fd[3] * fold + flz * flare + para * fall - 34 * slam
		local x = fd[1] * fold
		local y = fd[2] * fold + 10 * flare
		L.both(pose, name, ang(x, y, z))
		local tz = 0.7 * amp * wave(t, 11 * F, -ph - 0.12) * active
			+ 30 * air * sin(TAU * (2.6 * (c - 3.9) - ph - 0.15))
			+ 14 * happy * sin(TAU * (4 * (c - 7.3) - ph - 0.15))
			- 28 * fold + 18 * fall - 26 * slam
		L.both(pose, name .. "Tip", ang(0, -12 * fold, tz))
	end

	------------------------------------------------------------------
	-- fins
	------------------------------------------------------------------
	local paddle = wave(t, 8 * F)
	local finZ = 22 * paddle * swimW + 40 * slam - 20 * fold + 25 * fall + 20 * happy * sin(TAU * 4 * (c - 7.3))
	local finY = 16 * wave(t, 8 * F, 0.25) * swimW - 50 * max(launch, coil) * (1 - fall)
	L.both(pose, "Fin", ang(0, finY, finZ))
	L.both(pose, "FinTip", ang(0, 0, 20 * wave(t, 8 * F, -0.15) * swimW + 25 * slam - 15 * fold))

	------------------------------------------------------------------
	-- mouth: gulps every 2.2 s in idle, surprised "O" on the leap, happy
	------------------------------------------------------------------
	local gp = (t / 2.2) % 1
	local g = sin(pi * L.remap(gp, 0, 0.35)) ^ 2 * idleW
	local shout = max(launch * (1 - curl * 0.3), burst, 0.8 * wig)
	pose.Mouth = pa(0, 0, -0.7 * g - 0.5 * shout, 8 * g + 6 * shout, 0, 0)
	pose.Jaw = ang(-5 - 30 * g - 38 * shout + 4 * coil - 24 * happy * L.wave01(c, 3.0), 0, 0)
	L.both(pose, "Gill", ang(0, 28 * g + 20 * shout + 10 * wave(t, 6 * F) * idleW, 0))

	-- barbels: lazy floating sway + drag on the moves + wild flops
	local wA = 14 * wave(t, 6 * F, 0.2) * swimW + 30 * launch - 26 * fall + 22 * wig * sin(TAU * (wigPhase * 1.3))
	local wB = 10 * wave(t, 4 * F, 0.5) * swimW + 20 * happy * sin(TAU * 4 * (c - 7.3))
	L.both(pose, "Whisker", ang(wA, wB, 8 * wave(t, 6 * F, 0.4)))
	L.both(pose, "WhiskerTip", ang(0.8 * wA * 0.8 + 12 * wave(t, 6 * F, 0.05), 0, 18 * wave(t, 6 * F, 0.05) + 20 * wig * sin(TAU * (wigPhase * 1.3 - 0.2))))

	------------------------------------------------------------------
	-- eyelids: blinks, squint on the coil, squeeze on the splash, happy squint
	------------------------------------------------------------------
	local blink = max(0.5 * coil, L.env(c, SPLASH - 0.02, 0.05, 0.25, 0.15), 0.55 * happy)
	for _, b in BLINKS do
		blink = max(blink, L.env(c, b, 0.06, 0.06, 0.1))
	end
	L.both(pose, "Lid", CFrame.new(0, -3.45 * blink, 0))
	local lidTr = blink > 0.06 and 0 or 1
	for _, n in { "EyelidR", "EyelidL", "LashR", "LashL" } do
		ctx.transparency(n, lidTr)
	end

	------------------------------------------------------------------
	-- halo: slow spin + bob; pops up and whirls on the burst and the spin
	------------------------------------------------------------------
	local haloPop = max(burst, 0.8 * happy)
	local haloSpin = 360 * 2 * F * t + L.track(c, { { 4.5, 0 }, { 5.3, 720, "cubicOut" } }) + L.track(c, { { 7.3, 0 }, { 8.4, 360, "cubicOut" } })
	pose.Halo = pa(0, 0.35 * wave(t, 6 * F, 0.3) + 1.6 * haloPop - 0.8 * coil + 1.2 * slam, 0,
		4 * wave(t, 3 * F) + 10 * slam * sin(TAU * 3 * (c - SPLASH)), haloSpin, 4 * wave(t, 3 * F, 0.25))

	------------------------------------------------------------------
	-- floating cubes: bob + tumble, sucked in on the coil, flung by the splash
	------------------------------------------------------------------
	local jolt = L.env(c, SPLASH, 0.06, 0.05, 1.0, "quadOut", "elasticOut")
	local OD = { { 1, 1 }, { -1, 1 }, { 1, -1 }, { -1, -1 } }
	for i = 1, 4 do
		local d = OD[i]
		local out = 2.6 * jolt + 1.5 * burst - 1.5 * coil
		local dx = 0.8 * wave(t, 2 * F, i * 0.21) + out * d[1]
		local dy = 1.1 * wave(t, 4 * F, i * 0.27) + 1.5 * burst - 1.2 * jolt
		local dz = 0.8 * wave(t, 2 * F, i * 0.21 + 0.25) - out * 0.4 * d[2]
		local s = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(dx, dy, dz, 360 * 2 * F * t * s + 30 * i, 360 * 3 * F * t, 25 * i)
	end

	------------------------------------------------------------------
	-- HOLY SUN RAYS at the apex (ride up with the leap, spin, fade)
	------------------------------------------------------------------
	local rayOn = c > APEX - 0.02 and c < APEX + 0.8
	local ru = L.remap(c, APEX, APEX + 0.8)
	pose.Rays = pa(0, by, 0, 0, 45 + 140 * ru, 0)
	for k = 1, 8 do
		ctx.transparency("Ray" .. k, rayOn and (0.9 * ru ^ 2) or 1)
	end

	------------------------------------------------------------------
	-- SPLASH droplets: holy-water cubes burst out in a crown, arc, fade
	------------------------------------------------------------------
	local su = L.remap(c, SPLASH, SPLASH + 1.0)
	local sOn = c > SPLASH and c < SPLASH + 1.0
	local se = L.ease.cubicOut(su)
	for k = 1, 12 do
		local deg = DROP_A[k]
		local a = math.rad(deg)
		local cf
		if k % 2 == 1 then
			-- crown cube: shoots up and out, tumbles, falls back
			local r = 3 + (k % 4 == 1 and 8 or 11) * se
			local y = (k % 4 == 1 and 13 or 10) * 4 * su * (1 - su) + 1.5 * su
			local sp = 420 * su * (k % 4 == 1 and -1 or 1)
			cf = pa(sin(a) * r, y, cos(a) * r, sp, sp * 0.6, 30 * k)
		else
			-- ripple slab: skims outward low over the ground, tangent to the ring
			local r = 3 + 11 * se
			cf = pa(sin(a) * r, -3.6 + 0.6 * su, cos(a) * r, 0, deg, 0)
		end
		pose["Drop" .. k] = sOn and cf or CFrame.new()
		ctx.transparency("DropPart" .. k, sOn and (su > 0.65 and (su - 0.65) / 0.35 or 0.0) or 1)
	end

	------------------------------------------------------------------
	-- voxel bubbles wobbling up after each idle gulp
	------------------------------------------------------------------
	for k = 1, 3 do
		local u = (gp - 0.2 - (k - 1) * 0.09) / 0.62
		local on = u > 0 and u < 1 and idleW > 0.95
		local yy = 5.5 * u
		pose["Bubble" .. k] = on and pa(0.8 * sin(TAU * (1.5 * u + k * 0.3)) + 0.5 * (k - 2), yy + bob, -2.6 * u, 0, 90 * u, 45) or CFrame.new()
		ctx.transparency("BubblePart" .. k, on and (u > 0.85 and 1 or 0.45) or 1)
	end

	------------------------------------------------------------------
	-- effects on the beats
	------------------------------------------------------------------
	for j = 0, 4 do
		local tm = 2.2 * j + 0.385
		if ctx.crossed(tm) and (tm < 2.85 or tm > 9.0) then
			ctx.emit("MouthBubbles", 5)
		end
	end
	if ctx.crossed(3.9) then
		ctx.emit("FeatherBurst", 10)
		ctx.emit("AmbientSparkle", 8)
	end
	if ctx.crossed(APEX) then
		ctx.emit("HolyBurst", 55)
		ctx.emit("FeatherBurst", 22)
		ctx.emit("HaloSparkle", 14)
	end
	if ctx.crossed(SPLASH) then
		ctx.emit("SplashBurst", 50)
		ctx.emit("SplashMist", 26)
		ctx.emit("MouthBubbles", 24)
	end
	if ctx.crossed(7.75) then
		ctx.emit("HolyBurst", 20)
		ctx.emit("HaloSparkle", 14)
		ctx.emit("FeatherBurst", 8)
	end
	local flash = L.env(c, APEX, 0.05, 0.2, 0.6)
	ctx.light("HolyLight", min(1.5, 1.5 * flash + 0.8 * slam))
	ctx.light("HaloLight", min(1.5, 0.35 + 1.1 * max(burst, happy)))
end

return M
