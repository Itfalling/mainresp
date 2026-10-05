--!nocheck
-- Abyssal Mosasaurus motion.
-- Idle: a big bouncy swimming S-wave travels head -> tail, flippers paddle,
-- the whole body bobs and wiggles in the air, eyes blink, little "chomp chomp".
-- Signature DEATH LUNGE (every 10 s):
--   3.0  anticipation: coils back into an S, head rears up, jaw creaks open
--   4.3  LUNGE: explodes forward ~7.5 studs, upper head thrown up, jaw gapes
--        into a big forward V
--   4.72 SNAP shut (chomp lines + voxel chunks + bubble burst + squash)
--   4.8  violent head thrash x3 (tail lashes in counter-phase, bubbles pop
--        on every whip), happy angry squint
--   6.2  settle back with overshoot + a proud fluke kick -> idle
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 10

local sin, cos, pi, max, min, abs = math.sin, math.cos, math.pi, math.max, math.min, math.abs

local CHAIN = { "Head", "Neck", "Body1", "Body2", "Body3", "Tail1", "Tail2", "Tail3", "Tail4", "Fluke" }
local CENTER = 4
-- swim amplitude (absolute heading, degrees) per segment, head -> tail
local AMP = { 10, 12, 10, 8, 14, 20, 26, 32, 38, 44 }
-- coiled "S" (absolute yaw) and rear-up (absolute pitch) for the anticipation
local COIL_YAW = { -28, -36, -20, 0, 20, 32, 32, 20, 0, -20 }
local COIL_PITCH = { 42, 30, 16, 8, -4, -12, -18, -18, -10, 6 }
-- thrash amplitude per segment (head whips, tail lashes back)
local THRASH = { 48, 30, 12, -6, -8, -10, 12, 22, 30, 36 }
-- tail power-stroke that drives the lunge (and the proud settle kick)
local KICK = { 0, 0, 0, 2, 6, 10, 16, 22, 28, 32 }
-- cartoon blinks (cycle seconds)
local BLINKS = { 0.8, 2.6, 7.9, 9.3 }

local SNAP = 4.72
local THR0 = 4.8
local THR_HZ = 2.6

-- every always-on wave completes whole cycles per 10 s loop, so the baked
-- preview loops seamlessly too (in game t just keeps growing)
local SWIM_HZ = 0.5

-- voxel chunks that pop out of the mouth on the snap: direction (x, y, z)
local CHUNK_DIR = {
	{ 1.0, 0.9, -0.6 }, { -1.0, 0.8, -0.5 }, { 0.6, 1.3, -0.9 }, { -0.5, 1.4, -0.8 },
	{ 1.3, 0.2, -0.4 }, { -1.3, 0.3, -0.3 }, { 0.3, -0.4, -1.3 }, { -0.2, 0.6, -1.4 },
}

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes for the Death Lunge
	------------------------------------------------------------------
	local coil = L.env(c, 3.0, 1.0, 0.25, 0.22, "cubicOut", "expoIn")
	local lunge = L.env(c, 4.3, 0.3, 1.5, 1.2, "backOut", "backOut")
	local gape = L.env(c, 4.25, 0.3, 0.12, 0.06, "backOut", "expoIn")
	local tight = L.env(c, SNAP - 0.03, 0.05, 1.3, 0.4, "expoOut", "cubicInOut")
	local squash = L.env(c, SNAP, 0.05, 0.03, 0.9, "linear", "elasticOut")
	local thrash = L.env(c, THR0, 0.12, 0.95, 0.35, "cubicOut", "cubicInOut")
	local settle = L.env(c, 6.2, 0.25, 0.2, 0.9, "backOut", "cubicInOut") -- proud "ta-da" kick
	local special = max(coil, lunge, gape, tight)
	local idleW = 1 - special
	local swimW = 1 - 0.75 * max(coil, min(1, lunge))

	local thrPhase = THR_HZ * (c - THR0)
	local kick = max(L.env(c, 4.2, 0.1, 0.45, 0.5), 0.8 * settle)
	local kickPhase = 2.2 * (c - 4.2)

	------------------------------------------------------------------
	-- absolute heading/pitch of every segment along the body
	------------------------------------------------------------------
	local yaw, pitch = {}, {}
	for i = 1, #CHAIN do
		local swim = AMP[i] * sin(2 * pi * (SWIM_HZ * t - 0.12 * (i - 1)))
		local thr = THRASH[i] * thrash * sin(2 * pi * (thrPhase - 0.07 * abs(i - 2)))
		local kk = KICK[i] * kick * sin(2 * pi * (kickPhase - 0.15 * (i - 1)))
		yaw[i] = swimW * swim + coil * COIL_YAW[i] + thr + kk
		local bobPitch = 5 * sin(2 * pi * (0.5 * t - 0.1 * (i - 1)))
		pitch[i] = bobPitch * swimW + coil * COIL_PITCH[i]
	end
	-- idle: curious look-around + head bob
	yaw[1] += (8 * wave(t, 0.2, 0.1) + 5 * wave(t, 0.3, 0.6)) * idleW
	pitch[1] += (5 * wave(t, 1.0, 0.2) + 4 * wave(t, 0.4, 0.35)) * idleW
	-- the lunge: upper head THROWN UP while the jaw drops (forward V-bite),
	-- nods down on the snap, jolts with every thrash whip
	pitch[1] += -8 * lunge + 32 * gape - 14 * squash + 12 * thrash + 8 * thrash * sin(2 * pi * thrPhase * 2)
	pitch[2] += -6 * lunge
	pitch[CENTER] += -5 * lunge
	-- the fluke flicks up on the proud settle
	pitch[#CHAIN] += -14 * settle

	------------------------------------------------------------------
	-- root: hover bob + happy wiggle + coil back + explosive lunge + squash
	------------------------------------------------------------------
	local bob = 1.0 * wave(t, 0.5) * (1 - 0.5 * special)
	local hop = 0.4 * L.bounce(t, 1.0) * idleW
	local by = bob + hop + 1.0 * coil - 1.3 * squash + 0.3 * lunge + 0.6 * settle
	local bz = 4.0 * coil - 7.5 * lunge
	local bx = 0.5 * wave(t, SWIM_HZ, 0.3) * swimW
	local roll = 8 * wave(t, SWIM_HZ, 0.15) * swimW + 10 * thrash * sin(2 * pi * (thrPhase + 0.5))
	pose.Body2 = pa(bx, by, bz, pitch[CENTER], yaw[CENTER], roll)

	-- forward chain (child is closer to the head)
	for i = CENTER - 1, 1, -1 do
		local name = CHAIN[i]
		local r = 0
		if name == "Head" then
			r = 28 * thrash * sin(2 * pi * (thrPhase + 0.2))
		end
		pose[name] = ang(pitch[i] - pitch[i + 1], yaw[i] - yaw[i + 1], r)
	end
	-- backward chain (tail)
	for i = CENTER + 1, #CHAIN do
		pose[CHAIN[i]] = ang(pitch[i] - pitch[i - 1], yaw[i] - yaw[i - 1], 0)
	end

	------------------------------------------------------------------
	-- jaw: grin + "chomp chomp" in idle, creak open, GAPE, SNAP, hold tight,
	-- chomps on every thrash whip
	------------------------------------------------------------------
	local chompWin = max(L.env(c, 1.2, 0.15, 1.0, 0.15), L.env(c, 8.3, 0.15, 1.0, 0.15))
	local chomp = chompWin * L.wave01(t, 1.8)
	local jaw = (-11 - 16 * chomp) * idleW
	jaw += -14 * coil * (1 - gape) - 58 * gape + 1.5 * tight
	jaw += -12 * thrash * max(0, sin(2 * pi * thrPhase * 2))
	jaw += -18 * settle * L.wave01(c, 3.0, 0.25) -- proud little chomps
	pose.Jaw = ang(jaw, 0, 0)

	------------------------------------------------------------------
	-- eyelids: blinks, squeezed shut on the snap, angry squint in the thrash
	------------------------------------------------------------------
	local blink = L.env(c, SNAP - 0.02, 0.04, 0.12, 0.12)
	blink = max(blink, 0.5 * L.env(c, THR0, 0.1, 1.0, 0.3))
	blink = max(blink, 0.45 * coil)
	for _, b in BLINKS do
		blink = max(blink, L.env(c, b, 0.06, 0.06, 0.1))
	end
	L.both(pose, "Lid", CFrame.new(0, -1.7 * blink, 0))
	local lidTr = blink > 0.08 and 0 or 1
	ctx.transparency("EyelidR", lidTr)
	ctx.transparency("EyelidL", lidTr)

	------------------------------------------------------------------
	-- flippers: paddle strokes (front/back alternate), flare in the coil,
	-- slicked FLAT back along the body in the lunge, flail during the thrash
	------------------------------------------------------------------
	local finThr = L.env(c, THR0 - 0.05, 0.3, 0.85, 0.45)
	local function fin(prefix, phase, wFlap)
		local s = wave(t, 0.6, phase)
		local sw = wave(t, 0.6, phase + 0.25)
		local flail = finThr * sin(2 * pi * (thrPhase + phase))
		local slick = lunge * (1 - finThr)
		local flap = (30 * s) * swimW * wFlap + 40 * coil + 10 * slick + 18 * flail + 12 * settle
		local sweep = 24 * sw * swimW + 30 * coil - 60 * slick + 30 * flail - 20 * settle
		local tipFlap = 24 * wave(t, 0.6, phase - 0.15) * swimW + 18 * coil - 4 * slick
			+ 28 * finThr * sin(2 * pi * (thrPhase + phase - 0.2)) + 20 * settle * wave(c, 3.0)
		local f = ang(0, sweep, flap)
		L.both(pose, prefix .. "Fin", f, f)
		L.both(pose, prefix .. "Tip", ang(0, 0, tipFlap))
	end
	fin("Front", 0, 1)
	fin("Rear", 0.5, 0.8)

	------------------------------------------------------------------
	-- floating voxel cubes: bob, drift in little loops, tumble; dragged along
	-- in the lunge wake, flung out by the bite shockwave
	------------------------------------------------------------------
	for i = 1, 5 do
		local ph = i * 0.21
		local out = 2.4 * squash
		local dir = i % 2 == 0 and -1 or 1
		local dx = 0.8 * wave(t, 0.2, ph) + out * dir
		local dy = 1.0 * wave(t, 0.4, ph + 0.3) + out * 0.5 + 0.8 * coil
		local dz = 0.8 * wave(t, 0.2, ph + 0.25) - 3 * lunge + 1.2 * coil
		pose["Orb" .. i] = pa(dx, dy, dz, 72 * t * dir + 30 * i, 108 * t, 35 + 20 * i)
	end

	------------------------------------------------------------------
	-- CHOMP chunks: pop out of the mouth on the snap, tumble, fall, vanish
	------------------------------------------------------------------
	local cp = L.remap(c, SNAP, SNAP + 0.7)
	local chunkOn = c > SNAP and c < SNAP + 0.7
	local ce = L.ease.cubicOut(cp)
	for k = 1, 8 do
		local d = CHUNK_DIR[k]
		local r = 7 * ce
		local spin = 540 * cp * (k % 2 == 0 and -1 or 1)
		pose["Chunk" .. k] = chunkOn
				and pa(d[1] * r, d[2] * r - 5 * cp * cp, d[3] * r - 2.0, spin, spin * 0.7, 45 * k)
			or CFrame.new()
		ctx.transparency("ChunkPart" .. k, chunkOn and (cp > 0.7 and (cp - 0.7) / 0.3 or 0) or 1)
	end

	------------------------------------------------------------------
	-- effects on the beats
	------------------------------------------------------------------
	if ctx.crossed(4.32) then
		ctx.emit("WakeBurst", 34)
	end
	if ctx.crossed(SNAP + 0.01) then
		ctx.emit("SnapBurst", 45)
		ctx.emit("BubbleBurst", 40)
	end
	-- every thrash whip pops a little bubble burst
	for k = 0, 2 do
		if ctx.crossed(THR0 + (k + 0.25) / THR_HZ) then
			ctx.emit("BubbleBurst", 8)
			ctx.emit("SnapBurst", 6)
		end
	end
	if ctx.crossed(6.3) then
		ctx.emit("WakeBurst", 16)
		ctx.emit("AmbientSparkle", 10)
	end
	ctx.enable("ThrashBubbles", c > SNAP + 0.04 and c < 6.0)
	local flash = L.env(c, SNAP - 0.01, 0.03, 0.12, 0.15)
	ctx.light("MouthLight", min(1.5, 0.8 * gape + 1.5 * flash))
	local linesOn = c > SNAP and c < SNAP + 0.26
	for i = 1, 8 do
		ctx.transparency("SnapLine" .. i, linesOn and 0.1 or 1)
	end
end

return M
