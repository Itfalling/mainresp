--!nocheck
-- Atlantean Tide Orca motion. Personality: MISCHIEVOUS ROYAL PRANKSTER.
-- Always-on: vertical orca swim-wave down the chain (fluke strokes), hover
-- bob, paddling flippers, swaying trident dorsal, swinging medallion, a
-- permanently cocked right brow, darting pupils, blinks.
-- IDLE GAGS
--   0.20  SLY SIDE-GLANCE: pupils slide left ... right, sly squint, head tilt
--   1.60  FAKE-OUT LUNGE: winds back, LUNGES at the viewer jaw open, freezes,
--   2.45  "JUST KIDDING!": pops back, head tilt, happy squint + giggle
--   3.20  BLOWHOLE SQUIRT: inhales, a water jet arcs AT the viewer, cackle
--   4.60  CROWN TIP: right flipper tips the crown like a hat + quick wink
-- SIGNATURE "TIDAL CROWN"
--   5.90  DIVE anticipation: rises, noses down, tail cocked high, squint
--   6.65  BREACH: rockets up nose-first in a double spin through three
--         swirling water rings (bubbles, wake)
--   7.30  APEX CROWN FLASH: crown pops + spins, crystal beam, star, burst
--   7.50  tips over, fins splay ... 8.05 BELLY-FLOP: squash, splash crown
--         erupts, wave ring rolls out, "OOF" face, crown bounces
--   8.72 / 9.20  DOUBLE TAIL SLAP with splashes and a second wave
--   9.70  CHEEKY BOW: dips low, flipper sweeps across the chest, crown tips,
--  10.50  ... WINK + star + smirk
-- MORE GAGS
--  11.60  RASPBERRY: tongue out + wiggle, head waggle, spray
--  12.80  GIGGLE WIGGLE: shaking roll + bounce, eyes squeezed, jaw chatter
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 15

local sin, cos, pi, max, min, abs = math.sin, math.cos, math.pi, math.max, math.min, math.abs
local TAU = 2 * pi

local CHAIN = { "Head", "Body1", "Body2", "Tail1", "Tail2", "Tail3", "Fluke" }
local CENTER = 2
local SWIM = 0.4 -- 6 whole strokes per 15 s loop
local AMP = { 2, 2, 4, 8, 12, 17, 24 } -- vertical swim pitch, head -> fluke
local YAMP = { 3, 1, 2, 3, 4, 5, 6 }
local DIVE = { -6, 0, -6, -14, -20, -24, -26 } -- tail cocked high for the dive
local CURL = { 8, 0, -10, -24, -38, -48, -52 } -- tail curls up behind in the breach
local FLOPW = { 6, 0, 6, 14, 22, 28, 34 } -- follow-through whip after the belly flop
local SLAP = { 4, 0, 4, 12, 18, 24, 30 } -- double tail slap

local SPLAT = 8.05
local BLINKS = { 5.75, 9.6, 14.3 }

local PITCH = {
	{ 0, 0 },
	{ 1.6, 0 }, { 1.95, 6, "cubicOut" }, { 2.12, -10, "expoOut" }, { 2.4, -9 }, { 2.7, 3, "backOut" }, { 3.0, 0, "sineInOut" },
	{ 3.2, 0 }, { 3.55, 8, "cubicOut" }, { 3.75, -4, "expoOut" }, { 4.3, 0, "sineInOut" },
	{ 5.9, 0 }, { 6.55, -28, "cubicOut" }, { 6.7, -24 }, { 7.1, 60, "backOut" }, { 7.45, 62 },
	{ 7.95, -6, "quadInOut" }, { SPLAT + 0.03, 2 }, { 8.3, -3 }, { 8.6, 0, "sineInOut" },
	{ 9.7, 0 }, { 10.15, -24, "backOut" }, { 10.4, -22 }, { 10.75, 4, "backOut" }, { 11.3, 0, "sineInOut" },
}
local BY = {
	{ 0, 0 },
	{ 3.2, 0 }, { 3.55, 0.7, "cubicOut" }, { 3.75, 0.2, "expoOut" }, { 4.3, 0, "sineInOut" },
	{ 5.9, 0 }, { 6.55, 1.4, "cubicOut" }, { 6.7, 1.2 }, { 7.2, 10.0, "cubicOut" }, { 7.5, 10.4, "quadOut" },
	{ SPLAT, -1.3, "quadIn" }, { 8.2, -1.4 }, { 8.55, 0.4, "backOut" }, { 8.9, 0, "quadInOut" },
	{ 9.7, 0 }, { 10.15, 0.9, "cubicOut" }, { 10.75, 0.4, "backOut" }, { 11.3, 0, "cubicInOut" },
}
local BZ = {
	{ 0, 0 },
	{ 1.6, 0 }, { 1.95, 1.6, "cubicOut" }, { 2.12, -3.2, "expoOut" }, { 2.4, -3.0 }, { 2.75, 0.4, "backOut" }, { 3.0, 0, "sineInOut" },
	{ 5.9, 0 }, { 6.55, 1.5, "cubicOut" }, { 7.3, 0, "cubicInOut" },
}
local ROLL = { { 6.65, 0 }, { 7.45, 720, "cubicInOut" } }
local SLAPT = {
	{ 8.3, 0 }, { 8.58, -1, "cubicOut" }, { 8.72, 1, "quadIn" }, { 8.86, 0.6, "quadOut" },
	{ 9.05, -1, "cubicOut" }, { 9.2, 1, "quadIn" }, { 9.36, 0.6, "quadOut" }, { 9.75, 0, "sineInOut" },
}
local GLANCE = {
	{ 0.2, 0 }, { 0.4, -0.45, "backOut" }, { 0.85, -0.45 }, { 1.0, 0.45, "backOut" }, { 1.35, 0.45 }, { 1.55, 0, "sineInOut" },
}
local RINGT = { 6.62, 6.78, 6.94 }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes
	------------------------------------------------------------------
	local glance = L.env(c, 0.2, 0.2, 1.0, 0.3)
	local wind = L.env(c, 1.6, 0.35, 0.05, 0.12, "cubicOut", "expoIn")
	local lunge = L.env(c, 1.95, 0.15, 0.3, 0.35, "expoOut", "cubicInOut")
	local kidding = L.env(c, 2.45, 0.15, 0.4, 0.3, "backOut", "cubicInOut")
	local inhale = L.env(c, 3.2, 0.35, 0.05, 0.15, "cubicOut", "quadIn")
	local squirt = L.env(c, 3.55, 0.12, 0.5, 0.3, "expoOut", "cubicInOut")
	local cackle = L.env(c, 3.95, 0.1, 0.4, 0.25)
	local tipE = L.env(c, 4.6, 0.3, 0.5, 0.35, "backOut", "cubicInOut")
	local dive = L.env(c, 5.9, 0.65, 0.12, 0.3, "cubicOut", "cubicIn")
	local air = L.env(c, 6.65, 0.2, 0.7, 0.3)
	local pop = L.env(c, 7.25, 0.12, 0.2, 0.4, "backOut", "cubicInOut")
	local splay = L.env(c, 7.5, 0.3, 0.2, 0.5, "backOut", "cubicInOut")
	local squash = L.env(c, SPLAT, 0.04, 0.05, 0.5, "linear", "elasticOut")
	local oof = L.env(c, SPLAT, 0.05, 0.3, 0.35, "expoOut", "cubicInOut")
	local flopW = L.env(c, SPLAT, 0.05, 0.25, 0.4)
	local slapS = L.track(c, SLAPT)
	local slapOn = L.env(c, 8.3, 0.2, 1.1, 0.35)
	local bow = L.env(c, 9.7, 0.45, 0.25, 0.4, "backOut", "cubicInOut")
	local winkB = L.env(c, 10.62, 0.08, 0.5, 0.15)
	local smirk = L.env(c, 10.5, 0.2, 0.7, 0.3, "backOut", "cubicInOut")
	local rasp = L.env(c, 11.6, 0.2, 0.75, 0.25, "backOut", "cubicInOut")
	local giggle = L.env(c, 12.8, 0.15, 0.8, 0.3)
	local special = L.env(c, 5.85, 0.2, 5.3, 0.4)
	local swimW = 1 - 0.85 * max(dive, air, splay) - 0.5 * slapOn
	local idleW = 1 - special
	local gig = sin(TAU * 7 * c)

	------------------------------------------------------------------
	-- absolute pitch / yaw along the chain (orca = vertical strokes)
	------------------------------------------------------------------
	local flopPh = 2.4 * (c - SPLAT)
	local pitch, yaw = {}, {}
	for i = 1, #CHAIN do
		local k = i - 1
		pitch[i] = swimW * AMP[i] * sin(TAU * (SWIM * t - 0.12 * k))
			+ dive * DIVE[i] + air * CURL[i]
			+ flopW * FLOPW[i] * sin(TAU * (flopPh - 0.12 * k))
			+ slapS * SLAP[i]
		yaw[i] = swimW * YAMP[i] * sin(TAU * (0.5 * SWIM * t - 0.1 * k + 0.2))
			+ giggle * 4 * k * sin(TAU * (7 * c - 0.1 * k))
	end
	-- head: sizes you up, nods into the lunge, tips with the crown, waggles
	yaw[1] += (6 * L.noise(t, 7.7, 0.35)) * idleW - 10 * glance * L.track(c, GLANCE) / 0.45 * 0.5
		+ 12 * rasp * sin(TAU * 3 * c)
	pitch[1] += 3 * wave(t, 0.8, 0.1) * idleW - 12 * lunge + 8 * wind + 10 * inhale - 6 * squirt
		- 10 * tipE + 10 * kidding - 8 * bow + 6 * smirk + 4 * rasp

	------------------------------------------------------------------
	-- root (Body1)
	------------------------------------------------------------------
	local bob = 0.7 * wave(t, SWIM, 0.3) * (1 - 0.7 * special)
	local by = bob + L.track(c, BY) - 1.2 * squash + 0.45 * L.bounce(c, 7) * giggle
	local bz = L.track(c, BZ)
	local bx = 0.4 * wave(t, 0.2) * idleW
	local spin = L.track(c, ROLL)
	local roll = 4 * wave(t, SWIM, 0.4) * swimW + spin + 12 * gig * giggle + 8 * kidding * sin(TAU * 4 * (c - 2.45))
		+ 6 * glance * L.track(c, GLANCE) / 0.45
	local bp = pitch[CENTER] + L.track(c, PITCH)
	pose.Body1 = pa(bx, by, bz, bp, yaw[CENTER], roll)

	pose.Head = ang(pitch[1] - pitch[2], yaw[1] - yaw[2], 10 * kidding - 8 * tipE + 8 * smirk + 6 * rasp * sin(TAU * 3 * c + 1))
	for i = CENTER + 1, #CHAIN do
		pose[CHAIN[i]] = ang(pitch[i] - pitch[i - 1], yaw[i] - yaw[i - 1], 0)
	end

	------------------------------------------------------------------
	-- face
	------------------------------------------------------------------
	-- jaw: lunge "RAH!", cackle, "WHEE!", OOF, smirk, raspberry, giggle chatter
	local jawX = -(40 * lunge + 30 * air + 34 * oof + 8 * smirk + 18 * rasp + 6 * kidding)
	jawX -= 14 * cackle * L.wave01(c, 9.0) + 16 * giggle * L.wave01(c, 8.0)
	jawX -= 3 * L.wave01(t, 0.3) * idleW
	pose.Jaw = ang(jawX, 0, 0)
	pose.Tongue = pa(0, -0.05 * rasp, -1.7 * rasp - 0.5 * kidding, -18 * rasp, 20 * rasp * sin(TAU * 5 * c), 0)

	-- pupils: glances move BOTH pupils the same world direction
	local gx = L.track(c, GLANCE) + 0.12 * L.noise(t, 2.2, 0.8) * idleW + 0.3 * smirk
	local gy = 0.15 * L.noise(t, 5.1, 0.6) + 0.25 * inhale + 0.3 * air - 0.15 * bow
	pose.PupilR = CFrame.new(gx, gy, 0)
	pose.PupilL = CFrame.new(gx, gy, 0)

	-- brows: right brow permanently cocked; fierce on the lunge
	local cock = 0.5 + 0.5 * glance + 0.6 * tipE + 0.7 * smirk + 0.4 * rasp
	local fierce = max(lunge, 0.8 * wind, dive)
	local surprised = max(inhale, 0.8 * pop, oof)
	pose.BrowR = pa(0, 0.25 * cock + 0.35 * surprised - 0.15 * fierce + 0.1 * wave(t, 1.3) * idleW, 0, 0, 0, -10 * cock + 16 * fierce - 6 * surprised)
	pose.BrowL = L.mirror(pa(0, -0.08 + 0.35 * surprised - 0.15 * fierce - 0.12 * smirk, 0, 0, 0, 6 + 16 * fierce - 6 * surprised + 6 * smirk))

	-- lids: blinks, sly squint, happy squint, squeezed shut, winks
	local closeBoth = max(0.35 * glance, 0.55 * kidding, 0.4 * dive, 0.9 * L.env(c, SPLAT, 0.03, 0.12, 0.2), 0.85 * giggle, 0.45 * rasp, 0.4 * cackle)
	for _, b in BLINKS do
		closeBoth = max(closeBoth, L.env(c, b, 0.06, 0.06, 0.1))
	end
	local winkTip = L.env(c, 5.0, 0.06, 0.2, 0.1)
	local closeL = max(closeBoth, winkB, winkTip)
	local closeR = closeBoth
	pose.LidR = CFrame.new(0, -1.5 * closeR, 0)
	pose.LidL = CFrame.new(0, -1.5 * closeL, 0)
	ctx.transparency("EyelidR", closeR > 0.06 and 0 or 1)
	ctx.transparency("EyelidL", closeL > 0.06 and 0 or 1)

	-- wink star
	local wsOn = (c > 10.65 and c < 11.15) or (c > 5.02 and c < 5.3)
	local wsP = c > 10 and L.remap(c, 10.65, 11.15) or L.remap(c, 5.02, 5.3)
	pose.WinkStar = pa(-0.4 * wsP, 0.5 * wsP, 0, 0, 0, 45 + 220 * wsP)
	local wtr = wsOn and (0.05 + 0.95 * max(0, (wsP - 0.55) / 0.45)) or 1
	ctx.transparency("WinkA", wtr)
	ctx.transparency("WinkB", wtr)

	------------------------------------------------------------------
	-- blowhole squirt: column grows, then arcs forward AT the viewer
	------------------------------------------------------------------
	local sq = L.remap(c, 3.55, 3.85)
	local sqOn = c > 3.55 and c < 4.35
	local sqFade = L.remap(c, 4.05, 4.35)
	local arc = L.ease.cubicOut(L.remap(c, 3.62, 3.95))
	pose.Squirt = ang(-58 * arc, 0, 22 * arc + 5 * sin(TAU * 6 * c))
	for k = 1, 6 do
		local on = sqOn and sq * 6.5 > k
		ctx.transparency("Jet" .. k, on and (0.05 + 0.95 * sqFade) or 1)
	end

	------------------------------------------------------------------
	-- crown: idle wobble, hat tip, apex pop + spin, bounce, bow
	------------------------------------------------------------------
	local cspin = L.track(c, { { 7.22, 0 }, { 7.7, 360, "cubicOut" } })
	local cbounce = L.env(c, SPLAT + 0.02, 0.08, 0.02, 0.4, "quadOut", "bounceOut")
	pose.Crown = pa(0, 1.0 * tipE + 1.6 * pop + 1.0 * cbounce + 0.5 * bow, -0.5 * tipE - 0.3 * bow,
		-28 * tipE - 18 * bow + 8 * cbounce, cspin, -10 * tipE + 3 * wave(t, 0.4, 0.3) + 6 * gig * giggle)
	local beamOn = c > 7.26 and c < 7.62
	ctx.transparency("CrownBeam", beamOn and (0.15 + 0.85 * L.remap(c, 7.4, 7.62)) or 1)
	local starOn = c > 7.26 and c < 7.7
	local stP = L.remap(c, 7.26, 7.7)
	ctx.transparency("CrownStarA", starOn and (0.05 + 0.95 * max(0, (stP - 0.5) / 0.5)) or 1)
	ctx.transparency("CrownStarB", starOn and (0.05 + 0.95 * max(0, (stP - 0.5) / 0.5)) or 1)

	------------------------------------------------------------------
	-- flippers (model axes, right side): +Z raise, +Y sweep forward
	------------------------------------------------------------------
	local pad = wave(t, SWIM)
	local baseZ = 14 * pad * swimW + 35 * lunge - 10 * wind + 20 * inhale - 30 * air * (1 - splay) + 60 * splay
		+ 20 * oof + 28 * gig * giggle + 15 * kidding
	local baseY = 8 * wave(t, SWIM, 0.25) * swimW - 30 * wind + 20 * lunge - 50 * air * (1 - splay) + 10 * splay
	local rZ = baseZ + 85 * tipE - 15 * bow + 10 * rasp + 45 * smirk + 15 * smirk * sin(TAU * 3 * c)
	local rY = baseY + 45 * tipE + 70 * bow
	local lZ = baseZ + 45 * bow + 10 * rasp
	local lY = baseY - 40 * bow
	pose.PecR = ang(0, rY, rZ)
	pose.PecL = L.mirror(ang(0, lY, lZ))
	local tipZ = 18 * wave(t, SWIM, -0.15) * swimW + 25 * splay * sin(TAU * 3 * (c - 7.5)) + 20 * tipE
	L.both(pose, "PecTip", ang(0, 0, tipZ + 15 * bow), ang(0, 0, tipZ - 10 * bow))

	------------------------------------------------------------------
	-- trident dorsal: lag sway, leans back in the breach, whips on the flop
	------------------------------------------------------------------
	for i = 1, 3 do
		local x = 4 * sin(TAU * (SWIM * t - 0.15 * i)) * swimW + 10 * lunge + 14 * air - 12 * flopW * sin(TAU * (flopPh - 0.15 * i))
			- 6 * wind
		local z = 5 * sin(TAU * (0.5 * SWIM * t - 0.12 * i)) + 10 * gig * giggle
		pose["Dorsal" .. i] = ang(x, 0, z)
	end

	-- royal medallion swing
	pose.Medal = ang(12 * wave(t, 0.8) + 30 * lunge - 15 * wind - 30 * air + 35 * flopW * sin(TAU * 3 * (c - SPLAT)) + 20 * bow,
		0, 10 * wave(t, 0.55) + 20 * gig * giggle)

	------------------------------------------------------------------
	-- floating cubes
	------------------------------------------------------------------
	for i = 1, 6 do
		local ph = i * 0.17
		local dir = i % 2 == 0 and -1 or 1
		local out = 2.5 * air + 1.5 * squash
		local dx = 0.8 * wave(t, 0.2, ph) + out * dir
		local dy = 1.0 * wave(t, 0.4, ph + 0.3) + 1.5 * air - 1.0 * squash
		local dz = 0.8 * wave(t, 0.2, ph + 0.25)
		pose["Orb" .. i] = pa(dx, dy, dz, 72 * t * dir + 30 * i, 108 * t, 35 + 20 * i)
	end

	------------------------------------------------------------------
	-- swirling water rings: segments swirl in one after another as the
	-- orca passes, rise and fade
	------------------------------------------------------------------
	for r = 1, 3 do
		local t0 = RINGT[r]
		local dir = r % 2 == 0 and -1 or 1
		local prog = L.remap(c, t0, t0 + 0.25)
		local fade = L.remap(c, t0 + 0.75, t0 + 1.15)
		local on = c > t0 and c < t0 + 1.15
		pose["Ring" .. r] = pa(0, 1.5 * L.remap(c, t0, t0 + 1.15), 0, 6 * sin(TAU * (c + r * 0.3)), dir * 260 * (c - t0), 0)
		for i = 0, 9 do
			local tr = 1
			if on and prog * 10 >= i then
				tr = 0.25 + 0.75 * fade
			end
			ctx.transparency("R" .. r .. "_" .. i, tr)
		end
	end

	------------------------------------------------------------------
	-- splash crown + wave ring (and a smaller 2nd wave on the last slap)
	------------------------------------------------------------------
	local spP = L.remap(c, SPLAT, SPLAT + 0.85)
	local spOn = c > SPLAT and c < SPLAT + 0.85
	local spRise = L.ease.backOut(L.remap(c, SPLAT, SPLAT + 0.25))
	local wP, wOn, wScale = 0, false, 1
	if c > SPLAT and c < SPLAT + 0.9 then
		wP, wOn = L.remap(c, SPLAT, SPLAT + 0.9), true
	elseif c > 9.2 and c < 10.0 then
		wP, wOn, wScale = L.remap(c, 9.2, 10.0), true, 0.7
	end
	for k = 1, 8 do
		local a = math.rad((k - 1) * 45 + 22.5)
		local dx, dz = sin(a), cos(a)
		local out = 1.8 * L.ease.cubicOut(spP)
		pose["Splash" .. k] = pa(dx * out, -2.5 + 2.5 * spRise - 1.5 * spP * spP, dz * out, 0, 0, 0)
		local sTr = spOn and (0.2 + 0.8 * max(0, (spP - 0.45) / 0.55)) or 1
		ctx.transparency("SplashA" .. k, sTr)
		ctx.transparency("SplashB" .. k, sTr)
		local wo = (-2.5 + 7 * L.ease.cubicOut(wP)) * wScale
		pose["Wave" .. k] = CFrame.new(dx * wo, 0, dz * wo)
		local wTr = wOn and (0.25 + 0.75 * max(0, (wP - 0.4) / 0.6)) or 1
		ctx.transparency("WaveA" .. k, wTr)
		ctx.transparency("WaveB" .. k, wTr)
	end

	------------------------------------------------------------------
	-- lights + bursts on the beats
	------------------------------------------------------------------
	local flash = max(L.env(c, 7.26, 0.05, 0.2, 0.4), 0.6 * L.env(c, 4.9, 0.05, 0.1, 0.3), 0.5 * L.env(c, 10.62, 0.05, 0.1, 0.3))
	ctx.light("CrownLight", min(1.5, 0.4 + 0.3 * dive + 1.1 * flash))

	if ctx.crossed(2.13) then
		ctx.emit("BubbleBurst", 12)
	end
	if ctx.crossed(3.6) then
		ctx.emit("SquirtSpray", 12)
	end
	if ctx.crossed(3.8) then
		ctx.emit("SquirtSpray", 18)
	end
	if ctx.crossed(4.0) then
		ctx.emit("SquirtSpray", 12)
	end
	if ctx.crossed(4.95) then
		ctx.emit("CrownFlash", 10)
	end
	if ctx.crossed(6.0) then
		ctx.emit("BubbleBurst", 10)
	end
	if ctx.crossed(6.66) then
		ctx.emit("BubbleBurst", 40)
		ctx.emit("WakeBurst", 30)
	end
	if ctx.crossed(7.27) then
		ctx.emit("CrownFlash", 45)
		ctx.emit("AmbientSparkle", 14)
	end
	if ctx.crossed(SPLAT + 0.01) then
		ctx.emit("SplashBurst", 70)
		ctx.emit("BubbleBurst", 30)
	end
	if ctx.crossed(8.73) then
		ctx.emit("WakeBurst", 25)
		ctx.emit("SplashBurst", 20)
	end
	if ctx.crossed(9.21) then
		ctx.emit("WakeBurst", 25)
		ctx.emit("SplashBurst", 25)
	end
	if ctx.crossed(10.66) then
		ctx.emit("CrownFlash", 15)
		ctx.emit("AmbientSparkle", 10)
	end
	for _, s in { 11.85, 12.05, 12.25 } do
		if ctx.crossed(s) then
			ctx.emit("Spray", 10)
		end
	end
	if ctx.crossed(12.9) then
		ctx.emit("BubbleBurst", 12)
	end
end

return M
