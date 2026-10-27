--!nocheck
-- Orichalcum Hammerhead motion: a MEAN GRUMPY BULLY.
-- Idle: aggressive prowling S-wave swim, the hammer head sweeps side to side,
-- snapping jaw gnashes, two HEAD-BUTTS at the air (wind-up, jab, snap), grumpy
-- brow twitches, blinks.
-- Signature "HAMMER RUSH" (furious tantrum slam):
--   2.9  anticipation: rears back + up, tail curls, jaw snarls open, brows
--        furrow, the whole body trembles with rage
--   4.05 CHARGE: explodes forward ~13 studs, tail power-strokes, rush bubbles
--   4.42 SLAM: hammer head smashes down -> 3 neon shockwave rings ripple out,
--        dust + debris cubes + bubble burst, squash, eyes squeezed shut
--   4.55 tantrum head-shake thrash (jaw chomps on every whip)
--   5.75 a second angry POUND
--   5.95 swaggers back in an arc, chin up, smug lopsided sneer, one brow
--        cocked, half-lidded eyes -> idle by 7.7
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 10

local sin, pi, max, min, abs = math.sin, math.pi, math.max, math.min, math.abs

local CHAIN = { "Head", "Body1", "Body2", "Body3", "Tail1", "Tail2", "Tail3", "Fluke" }
local CENTER = 3
-- prowl swim amplitude (absolute heading, degrees) per segment, head -> tail
local AMP = { 8, 6, 5, 9, 15, 21, 27, 34 }
-- coiled rear-back (absolute yaw / extra pitch) for the anticipation
local COIL_YAW = { -14, -8, 0, 10, 16, 14, 6, -8 }
local COIL_PITCH = { 0, 0, 0, 6, 12, 16, 16, 10 }
-- tantrum thrash amplitude per segment (head whips, tail lashes back)
local THRASH = { 34, 12, 0, -8, -10, 10, 20, 28 }
-- tail power strokes that drive the charge
local KICK = { 0, 0, 2, 8, 14, 20, 26, 32 }
local BLINKS = { 0.5, 2.5, 7.9, 9.6 }
local BUTTS = { 1.2, 8.4 }

local SLAM = 4.42
local POUND = 5.75
local THR0 = 4.55
local THR_HZ = 3.0
local SWIM_HZ = 0.5

local CHUNK_DIR = {
	{ 1.0, 1.4, -0.4 }, { -1.0, 1.3, -0.3 }, { 0.6, 1.8, 0.6 }, { -0.5, 1.7, 0.7 },
	{ 1.4, 0.9, 0.2 }, { -1.4, 1.0, 0.1 }, { 0.3, 1.5, -1.2 }, { -0.2, 1.9, -1.0 },
}

local function tr(c, keys)
	return L.track(c, keys)
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes
	------------------------------------------------------------------
	local ant = L.env(c, 2.9, 0.95, 0.15, 0.2, "cubicOut", "expoIn")
	local tremble = L.env(c, 3.3, 0.3, 0.55, 0.15)
	local rush = L.env(c, 3.95, 0.15, 0.35, 0.2, "quadIn", "cubicOut")
	local kick = L.env(c, 3.95, 0.08, 0.45, 0.25)
	local squash = L.env(c, SLAM, 0.04, 0.04, 0.8, "linear", "elasticOut")
	local squash2 = L.env(c, POUND, 0.04, 0.03, 0.5, "linear", "elasticOut")
	local thrash = L.env(c, THR0, 0.1, 1.0, 0.25, "cubicOut", "cubicInOut")
	local smug = L.env(c, 6.0, 0.45, 1.0, 0.5, "backOut", "cubicInOut")
	local special = L.env(c, 2.9, 0.5, 3.2, 0.8)
	local idleW = 1 - special
	local swimW = 1 - 0.8 * special
	local thrPhase = THR_HZ * (c - THR0)
	local shake = tremble * sin(2 * pi * 13 * c)

	-- idle head-butts: wind-up (pre) then a hard jab (butt)
	local pre, butt = 0, 0
	for _, b in BUTTS do
		pre = max(pre, L.env(c, b - 0.4, 0.3, 0.05, 0.1, "cubicOut", "quadIn"))
		butt = max(butt, L.env(c, b, 0.1, 0.06, 0.5, "quadIn", "backOut"))
	end

	------------------------------------------------------------------
	-- root (Body2): hover bob, rear back, CHARGE, SLAM drop, swagger arc
	------------------------------------------------------------------
	local bz = tr(c, {
		{ 2.9, 0 }, { 3.85, 3.5, "cubicOut" }, { 4.05, 3.8 }, { SLAM, -6.5, "quadIn" },
		{ 4.6, -7.0, "cubicOut" }, { 5.9, -6.8 }, { 7.5, 0, "sineInOut" },
	})
	local by = tr(c, {
		{ 2.9, 0 }, { 3.85, 1.6, "cubicOut" }, { 4.05, 1.8 }, { 4.3, 0.4, "quadIn" }, { SLAM, 1.9, "quadIn" },
		{ 4.62, -0.3, "backOut" }, { 5.6, 0.1 }, { POUND, 1.8, "quadIn" }, { 5.95, -0.2, "backOut" },
		{ 6.6, 0.6, "sineInOut" }, { 7.5, 0, "sineInOut" },
	})
	local bp = tr(c, {
		{ 2.9, 0 }, { 3.85, 16, "cubicOut" }, { 4.05, 18 }, { 4.28, -2, "quadIn" }, { SLAM, -16, "quadIn" },
		{ 4.62, -6, "backOut" }, { 5.6, -6 }, { POUND, -12, "quadIn" }, { 5.95, -4, "backOut" },
		{ 6.6, 4, "sineInOut" }, { 7.5, 0, "sineInOut" },
	})
	local u = L.ease.sineInOut(L.clamp01(L.remap(c, 5.9, 7.5)))
	local arc = sin(pi * u)
	local bx = 5.5 * arc + 0.5 * wave(t, SWIM_HZ, 0.3) * swimW
	local byaw = -40 * arc

	local chompWin = max(L.env(c, 2.0, 0.1, 0.6, 0.1), L.env(c, 9.0, 0.1, 0.5, 0.1))
	local chomp = chompWin * L.wave01(t, 3.0)
	local bob = 0.8 * wave(t, 0.5) * (1 - 0.6 * special)
	local surge = 0.5 * L.bounce(t, 1.0) * idleW -- aggressive prowl lurch
	by += bob - 0.3 * surge + 0.5 * butt + 0.7 * chomp * idleW
	bz += 1.0 * pre - 2.4 * butt - 0.5 * surge
	bp += -6 * butt + 3 * pre

	------------------------------------------------------------------
	-- absolute heading / pitch of every segment
	------------------------------------------------------------------
	local yaw, pitch = {}, {}
	local kickPhase = 3.2 * (c - 3.95)
	for i = 1, #CHAIN do
		local swim = AMP[i] * sin(2 * pi * (SWIM_HZ * t - 0.12 * (i - 1)))
		local thr = THRASH[i] * thrash * sin(2 * pi * (thrPhase - 0.08 * abs(i - 1)))
		local kk = KICK[i] * kick * sin(2 * pi * (kickPhase - 0.14 * (i - 1)))
		yaw[i] = swimW * swim + ant * COIL_YAW[i] + thr + kk + byaw
		local bobPitch = 4 * sin(2 * pi * (0.5 * t - 0.1 * (i - 1)))
		pitch[i] = bobPitch * swimW + ant * COIL_PITCH[i] + bp
	end
	-- the hammerhead sweep: the head scans side to side (grumpy, suspicious)
	yaw[1] += (18 * wave(t, 0.3, 0.1) + 6 * wave(t, 0.7, 0.4)) * idleW + 6 * shake
	-- the gnash lifts the snout (keeps the gaping jaw off the floor)
	pitch[1] += (4 * wave(t, 1.0, 0.2) + 10 * chomp) * idleW + 14 * pre - 14 * butt
	-- signature head pitch: rear up, SLAM down, pound, chin up smug
	pitch[1] += tr(c, {
		{ 2.9, 0 }, { 3.85, 18, "cubicOut" }, { 4.05, 20 }, { 4.28, 0, "quadIn" }, { SLAM, -26, "expoIn" },
		{ 4.6, 6, "backOut" }, { 5.6, 6 }, { POUND, -24, "quadIn" }, { 5.95, 4, "backOut" },
		{ 6.5, 0, "sineInOut" }, { 7.7, 0 },
	}) + 20 * smug
	pitch[1] += 8 * thrash * sin(2 * pi * thrPhase * 2)
	-- the fluke flicks on the slam and the swagger
	pitch[#CHAIN] += -18 * squash - 10 * smug * wave(c, 2.0)

	pose.Body2 = pa(bx, by, bz, pitch[CENTER], yaw[CENTER], 6 * wave(t, SWIM_HZ, 0.15) * swimW + 5 * shake + 10 * thrash * sin(2 * pi * (thrPhase + 0.5)))

	for i = CENTER - 1, 1, -1 do
		local name = CHAIN[i]
		local r = 0
		if name == "Head" then
			r = 22 * thrash * sin(2 * pi * (thrPhase + 0.2)) - 10 * smug + 4 * wave(t, 0.3, 0.35) * idleW
		end
		pose[name] = ang(pitch[i] - pitch[i + 1], yaw[i] - yaw[i + 1], r)
	end
	for i = CENTER + 1, #CHAIN do
		pose[CHAIN[i]] = ang(pitch[i] - pitch[i - 1], yaw[i] - yaw[i - 1], 0)
	end

	------------------------------------------------------------------
	-- jaw: grumpy gnash, snaps on head-butts, snarl in the wind-up, gape on
	-- the charge, CHOMP on the slam, chomps per thrash whip, smug sneer
	------------------------------------------------------------------
	local jaw = (-5 - 28 * chomp) * idleW
	jaw += -34 * pre * idleW + 4 * butt
	jaw += -40 * ant - 30 * rush * (1 - squash)
	jaw += -26 * thrash * max(0, sin(2 * pi * thrPhase * 2))
	jaw += -3 * smug - 6 * smug * L.wave01(c, 3.0) -- smug "heh heh heh"
	local jawRoll = 9 * smug + 3 * wave(t, 0.2, 0.1) * idleW
	pose.Jaw = ang(jaw, 4 * smug, jawRoll)

	------------------------------------------------------------------
	-- brows: always a little furrowed; full scowl on butts / rage; smug:
	-- right brow furrowed, left brow cocked up
	------------------------------------------------------------------
	local twitch = max(L.env(c, 0.2, 0.08, 0.15, 0.2), L.env(c, 6.9, 0.08, 0.1, 0.2), L.env(c, 9.3, 0.08, 0.1, 0.2))
	local furrow = 0.25 + 0.5 * twitch + 0.75 * max(pre, butt, ant, rush, thrash)
	furrow = min(1.2, furrow)
	local bR = pa(0, -0.3 * furrow, 0, -4 * furrow, 0, 12 * furrow)
	local bL = pa(0, -0.3 * furrow * (1 - smug) + 0.9 * smug, 0, 0, 0, 12 * furrow * (1 - smug) - 30 * smug)
	L.both(pose, "Brow", bR, bL)

	------------------------------------------------------------------
	-- eyelids: blinks, squeezed on the impacts, squint in the thrash,
	-- smug half-lids
	------------------------------------------------------------------
	local blink = L.env(c, SLAM - 0.02, 0.04, 0.14, 0.14)
	blink = max(blink, L.env(c, POUND - 0.02, 0.04, 0.1, 0.12))
	blink = max(blink, 0.45 * thrash, 0.5 * smug, 0.35 * butt)
	for _, b in BLINKS do
		blink = max(blink, L.env(c, b, 0.06, 0.06, 0.1))
	end
	L.both(pose, "Lid", CFrame.new(0, -0.65 * blink, 0))
	local lidTr = blink > 0.08 and 0 or 1
	ctx.transparency("EyelidR", lidTr)
	ctx.transparency("EyelidL", lidTr)

	------------------------------------------------------------------
	-- pectoral fins: prowl paddles, flare in the wind-up, slicked back in
	-- the charge, flail in the tantrum, proud flare in the swagger
	------------------------------------------------------------------
	local slick = rush * (1 - thrash)
	local flail = thrash * sin(2 * pi * thrPhase)
	local s = wave(t, 0.5, 0)
	local sw = wave(t, 0.5, 0.25)
	local flap = (6 + 16 * s) * swimW + 36 * ant + 8 * slick + 20 * flail + 20 * smug - 10 * squash
	local sweep = 18 * sw * swimW + 24 * ant - 50 * slick + 20 * flail - 10 * smug
	local tipFlap = (4 + 15 * wave(t, 0.5, -0.15)) * swimW + 22 * ant - 6 * slick + 30 * thrash * sin(2 * pi * (thrPhase - 0.2)) + 16 * smug
	L.both(pose, "Pec", ang(0, sweep, flap))
	L.both(pose, "PecTip", ang(0, 0, tipFlap))

	------------------------------------------------------------------
	-- dorsal fin: follow-through (leans back in the charge, whips on slam)
	------------------------------------------------------------------
	local wob = L.env(c, SLAM, 0.02, 0, 1.3, "linear", "quadOut")
	local dp = 5 * wave(t, 0.5, -0.25) * swimW + 22 * rush * (1 - squash) - 10 * ant - 22 * wob * sin(2 * pi * 3 * (c - SLAM))
	pose.Dorsal = ang(dp, 0, -12 * thrash * sin(2 * pi * (thrPhase - 0.25)))

	------------------------------------------------------------------
	-- floating voxel cubes: bob + tumble; dragged by the rush, blown out by
	-- the slam shockwave
	------------------------------------------------------------------
	for i = 1, 6 do
		local ph = i * 0.19
		local dir = i % 2 == 0 and -1 or 1
		local out = 2.6 * max(squash, 0.6 * squash2)
		local dx = 0.8 * wave(t, 0.2, ph) + out * dir
		local dy = 1.0 * wave(t, 0.4, ph + 0.3) + out * 0.6 + 0.8 * ant
		local dz = 0.8 * wave(t, 0.2, ph + 0.25) - 4 * rush + 1.0 * ant
		pose["Orb" .. i] = pa(dx, dy, dz, 72 * t * dir + 30 * i, 108 * t, 35 + 20 * i)
	end

	------------------------------------------------------------------
	-- SLAM FX: rings ripple out one after another, debris cubes fly
	------------------------------------------------------------------
	local function ringVis(name, n, t0, dur)
		local k = (c - t0) / dur
		local on = k >= 0 and k < 1
		for i = 0, n - 1 do
			ctx.transparency(name .. i, on and (0.05 + 0.75 * k * k) or 1)
		end
		pose[name] = on and pa(0, 0.5 * k, 0, 0, 30 * k, 0) or CFrame.new()
		return on
	end
	if not ringVis("ShockA", 10, SLAM, 0.3) then
		ringVis("ShockA", 10, POUND, 0.26)
	end
	if not ringVis("ShockB", 14, SLAM + 0.08, 0.36) then
		ringVis("ShockB", 14, POUND + 0.07, 0.3)
	end
	ringVis("ShockC", 18, SLAM + 0.16, 0.42)

	-- orichalcum crystals burst up out of the ground, then sink back
	local cr = L.env(c, SLAM, 0.12, 0.6, 0.45, "backOut", "cubicIn")
	local crOn = cr > 0.02
	for k = 1, 6 do
		local lag = (k % 2) * 0.15
		local h = cr * (1 - lag)
		pose["Crystal" .. k] = pa(0, -3.4 + 3.4 * h, 0, 0, 90 * h * (k % 2 == 0 and 1 or -1), 0)
		ctx.transparency("CrystalBody" .. k, crOn and 0 or 1)
		ctx.transparency("CrystalTip" .. k, crOn and 0 or 1)
	end

	local cp = L.remap(c, SLAM, SLAM + 0.9)
	local chunkOn = c > SLAM and c < SLAM + 0.9
	local ce = L.ease.cubicOut(cp)
	for k = 1, 8 do
		local d = CHUNK_DIR[k]
		local r = 6 * ce
		local spin = 600 * cp * (k % 2 == 0 and -1 or 1)
		pose["Chunk" .. k] = chunkOn and pa(d[1] * r, d[2] * 7 * cp - 9 * cp * cp, d[3] * r, spin, spin * 0.7, 45 * k) or CFrame.new()
		ctx.transparency("ChunkPart" .. k, chunkOn and (cp > 0.75 and (cp - 0.75) / 0.25 or 0) or 1)
	end

	------------------------------------------------------------------
	-- particles / light on the beats
	------------------------------------------------------------------
	for _, b in BUTTS do
		if ctx.crossed(b + 0.1) then
			ctx.emit("ChompBurst", 12)
		end
	end
	if ctx.crossed(SLAM) then
		ctx.emit("ImpactDust", 40)
		ctx.emit("ImpactBurst", 50)
		ctx.emit("BubbleBurst", 30)
	end
	for k = 0, 2 do
		if ctx.crossed(THR0 + (k + 0.25) / THR_HZ) then
			ctx.emit("ChompBurst", 6)
		end
	end
	if ctx.crossed(POUND) then
		ctx.emit("ImpactDust", 22)
		ctx.emit("ImpactBurst", 20)
	end
	if ctx.crossed(6.3) then
		ctx.emit("AmbientSparkle", 12)
	end
	ctx.enable("RushBubbles", c > 3.95 and c < 4.6)
	local flash = max(L.env(c, SLAM - 0.01, 0.03, 0.12, 0.3), 0.6 * L.env(c, POUND - 0.01, 0.03, 0.08, 0.25))
	ctx.light("ImpactLight", 1.5 * flash)
end

return M
