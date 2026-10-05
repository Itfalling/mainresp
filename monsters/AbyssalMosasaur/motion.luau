--!nocheck
-- Abyssal Mosasaurus motion.
-- Idle: a constant swimming S-wave travels head -> tail, flippers paddle,
-- the whole body bobs in the air, eyes blink, little "chomp chomp" bites.
-- Signature DEATH LUNGE (every 10 s):
--   3.0  anticipation: coils back into an S, head rears up, jaw creaks open
--   4.3  LUNGE: explodes forward ~10 studs, jaw gapes ~75 deg
--   5.08 SNAP shut (chomp lines + bubble burst + squash)
--   5.2  violent head thrash x3 (tail lashes in counter-phase)
--   6.2  settle back with overshoot -> idle
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 10

local CHAIN = { "Head", "Neck", "Body1", "Body2", "Body3", "Tail1", "Tail2", "Tail3", "Tail4", "Fluke" }
local CENTER = 4
-- swim amplitude (absolute heading, degrees) per segment, head -> tail
local AMP = { 6, 8, 7, 6, 10, 16, 23, 30, 37, 44 }
-- coiled "S" (absolute yaw) and rear-up (absolute pitch) for the anticipation
local COIL_YAW = { -26, -34, -18, 0, 18, 30, 30, 18, 0, -18 }
local COIL_PITCH = { 40, 30, 16, 8, -4, -12, -18, -18, -10, 6 }
-- thrash amplitude per segment (head whips, tail lashes back)
local THRASH = { 30, 22, 10, -4, -6, -8, 10, 18, 24, 28 }
-- tail power-stroke that drives the lunge
local KICK = { 0, 0, 0, 2, 6, 10, 16, 22, 28, 32 }
-- cartoon blinks (cycle seconds)
local BLINKS = { 0.8, 2.6, 7.9, 9.3 }

-- every always-on wave completes whole cycles per 10 s loop, so the baked
-- preview loops seamlessly too (in game t just keeps growing)
local SWIM_HZ = 0.5

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes for the Death Lunge
	------------------------------------------------------------------
	local coil = L.env(c, 3.0, 1.0, 0.25, 0.22, "cubicOut", "expoIn")
	local lunge = L.env(c, 4.3, 0.3, 1.6, 1.3, "backOut", "backOut")
	local gape = L.env(c, 4.25, 0.35, 0.43, 0.07, "backOut", "expoIn")
	local tight = L.env(c, 5.05, 0.05, 1.2, 0.4, "expoOut", "cubicInOut")
	local squash = L.env(c, 5.08, 0.05, 0.03, 0.9, "linear", "elasticOut")
	local thrash = L.env(c, 5.15, 0.12, 0.95, 0.35, "cubicOut", "cubicInOut")
	local special = math.max(coil, lunge, gape, tight)
	local idleW = 1 - special
	local swimW = 1 - 0.75 * math.max(coil, math.min(1, lunge))

	local thrPhase = 2.6 * (c - 5.15)
	local kick = L.env(c, 4.2, 0.1, 0.45, 0.5)
	local kickPhase = 2.2 * (c - 4.2)

	------------------------------------------------------------------
	-- absolute heading/pitch of every segment along the body
	------------------------------------------------------------------
	local yaw, pitch = {}, {}
	for i = 1, #CHAIN do
		local swim = AMP[i] * math.sin(2 * math.pi * (SWIM_HZ * t - 0.12 * (i - 1)))
		local thr = THRASH[i] * thrash * math.sin(2 * math.pi * (thrPhase - 0.07 * math.abs(i - 2)))
		local kk = KICK[i] * kick * math.sin(2 * math.pi * (kickPhase - 0.15 * (i - 1)))
		yaw[i] = swimW * swim + coil * COIL_YAW[i] + thr + kk
		local bobPitch = 3.5 * math.sin(2 * math.pi * (0.5 * t - 0.1 * (i - 1)))
		pitch[i] = bobPitch * swimW + coil * COIL_PITCH[i]
	end
	-- idle: curious look-around + head bob
	yaw[1] += (8 * wave(t, 0.2, 0.1) + 5 * wave(t, 0.3, 0.6)) * idleW
	pitch[1] += (4 * wave(t, 1.0, 0.2) + 4 * wave(t, 0.4, 0.35)) * idleW
	-- the lunge: nose dives a touch, tail kicks up behind
	pitch[1] += -8 * lunge + 18 * gape - 12 * squash
	pitch[2] += -6 * lunge
	pitch[CENTER] += -5 * lunge

	------------------------------------------------------------------
	-- root: hover bob + coil back + explosive lunge forward + squash
	------------------------------------------------------------------
	local bob = 0.6 * wave(t, 0.5) * (1 - 0.5 * special)
	local by = bob + 1.0 * coil - 1.3 * squash + 0.3 * lunge
	local bz = 4.0 * coil - 7.5 * lunge
	local bx = 0.35 * wave(t, SWIM_HZ, 0.3) * swimW
	local roll = 5 * wave(t, SWIM_HZ, 0.15) * swimW + 8 * thrash * math.sin(2 * math.pi * (thrPhase + 0.5))
	pose.Body2 = pa(bx, by, bz, pitch[CENTER], yaw[CENTER], roll)

	-- forward chain (child is closer to the head)
	for i = CENTER - 1, 1, -1 do
		local name = CHAIN[i]
		local r = 0
		if name == "Head" then
			r = 18 * thrash * math.sin(2 * math.pi * (thrPhase + 0.2))
		end
		pose[name] = ang(pitch[i] - pitch[i + 1], yaw[i] - yaw[i + 1], r)
	end
	-- backward chain (tail)
	for i = CENTER + 1, #CHAIN do
		pose[CHAIN[i]] = ang(pitch[i] - pitch[i - 1], yaw[i] - yaw[i - 1], 0)
	end

	------------------------------------------------------------------
	-- jaw: grin + "chomp chomp" in idle, creak open, GAPE, SNAP, hold tight
	------------------------------------------------------------------
	local chompWin = math.max(L.env(c, 1.2, 0.15, 1.0, 0.15), L.env(c, 8.3, 0.15, 1.0, 0.15))
	local chomp = chompWin * L.wave01(t, 1.8)
	local jaw = (-11 - 16 * chomp) * idleW
	jaw += -12 * coil * (1 - gape) - 76 * gape + 1.5 * tight
	jaw += -7 * thrash * math.max(0, math.sin(2 * math.pi * thrPhase * 2))
	pose.Jaw = ang(jaw, 0, 0)

	-- blinks + squeeze the eyes shut on the bite
	local blink = L.env(c, 5.08, 0.04, 0.3, 0.15)
	for _, b in BLINKS do
		blink = math.max(blink, L.env(c, b, 0.06, 0.06, 0.1))
	end
	L.both(pose, "Lid", CFrame.new(0, -1.25 * blink, 0))

	------------------------------------------------------------------
	-- flippers: paddle strokes (front/back alternate), flare in the coil,
	-- slicked back in the lunge, flail during the thrash
	------------------------------------------------------------------
	local finThr = L.env(c, 5.05, 0.35, 0.8, 0.45)
	local function fin(prefix, phase, wFlap)
		local s = wave(t, 0.6, phase)
		local sw = wave(t, 0.6, phase + 0.25)
		local flail = finThr * math.sin(2 * math.pi * (thrPhase + phase))
		local slick = lunge * (1 - finThr)
		local flap = (26 * s) * swimW * wFlap + 38 * coil - 30 * slick + 32 * flail
		local sweep = 22 * sw * swimW + 28 * coil - 40 * slick + 12 * flail
		local tipFlap = 22 * wave(t, 0.6, phase - 0.15) * swimW + 15 * coil - 10 * slick
			+ 26 * finThr * math.sin(2 * math.pi * (thrPhase + phase - 0.2))
		local fR = ang(0, sweep, flap)
		local fL = ang(0, sweep, flap)
		L.both(pose, prefix .. "Fin", fR, fL)
		L.both(pose, prefix .. "Tip", ang(0, 0, tipFlap))
	end
	fin("Front", 0, 1)
	fin("Rear", 0.5, 0.8)

	------------------------------------------------------------------
	-- floating voxel cubes: bob, drift in little loops, tumble; flung out
	-- by the bite shockwave
	------------------------------------------------------------------
	for i = 1, 5 do
		local ph = i * 0.21
		local out = 2.2 * squash
		local dir = i % 2 == 0 and -1 or 1
		local dx = 0.8 * wave(t, 0.2, ph) + out * dir
		local dy = 0.9 * wave(t, 0.4, ph + 0.3) + out * 0.5
		local dz = 0.8 * wave(t, 0.2, ph + 0.25)
		pose["Orb" .. i] = pa(dx, dy, dz, 72 * t * dir + 30 * i, 108 * t, 35 + 20 * i)
	end

	------------------------------------------------------------------
	-- effects on the beats
	------------------------------------------------------------------
	if ctx.crossed(4.32) then
		ctx.emit("WakeBurst", 30)
	end
	if ctx.crossed(5.09) then
		ctx.emit("SnapBurst", 45)
		ctx.emit("BubbleBurst", 40)
	end
	ctx.enable("ThrashBubbles", c > 5.12 and c < 6.3)
	local flash = L.env(c, 5.07, 0.03, 0.12, 0.15)
	ctx.light("MouthLight", math.min(1.5, 0.8 * gape + 1.5 * flash))
	local linesOn = c > 5.08 and c < 5.34
	for i = 1, 8 do
		ctx.transparency("SnapLine" .. i, linesOn and 0.1 or 1)
	end
end

return M
