--!nocheck
-- Atlantean Tide Orca motion. Personality: MISCHIEVOUS ROYAL PRANKSTER.
-- Never still: a rolling swim-bob with vertical fluke strokes, paddling fins,
-- a swinging medallion, darting pupils, cocked brows and a smirking jaw.
--
-- IDLE PRANK GAGS
--   0.00  SLY GLANCE   half-lidded side-eye left / right, cocked brow, smirk
--   1.30  FAKE-OUT     winds back... LUNGES at the viewer with a huge open
--                      jaw (1.65) ... freezes ... "just kidding!" - happy
--                      closed eyes + tongue flick (2.2)
--   2.70  SQUIRT       inhales, then squirts a jet of water drops from the
--                      blowhole right at the viewer (3.05), cackles
--   4.10  TONGUE TEASE head tilt, winks, raspberry tongue wiggle + spray
--   5.30  GIGGLE       shimmy-wiggle, jaw chatter, laughing tears pop
--   6.10  CROWN TIP    tips the crown like a hat with a wink and a star
-- SIGNATURE "TIDAL CROWN"
--   6.75  wind-up hop (nose up, tail cocked)      7.15 DIVE nose-first,
--         swirling water rings wrap round it
--   7.60  BREACH: rockets up through the rings in a double barrel roll
--   8.55  APEX CROWN FLASH: crown pops + spins, crystal beam, burst
--   9.00  flips forward, splays its fins: the belly-flop fall
--   9.55  SPLAT! squash, splash crown erupts, wave ring rolls out
--  10.30  DOUBLE TAIL SLAP (10.72, 11.20) with splashes + a second wave
--  11.60  CHEEKY BOW: dips its head, tips the crown off, fin across the
--         chest, wink + star + tongue peek ... crown back on (13.0)
--  13.5   settles back into the swim
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 15

local sin, cos, pi, max, min, abs = math.sin, math.cos, math.pi, math.max, math.min, math.abs
local TAU = 2 * pi
local F = 1 / 15 -- whole cycles per loop

-- signature beats
local WIND, DIVE, BREACH, APEX, FALL, SPLAT = 6.75, 7.15, 7.6, 8.55, 9.0, 9.55
local LIFT1, SLAP1, LIFT2, SLAP2 = 10.3, 10.72, 10.95, 11.2
local BOW, BOWEND = 11.6, 13.0

local function track(c, k) return L.track(c, k) end

local function setEye(ctx, side, state)
	-- state: "open" / "half" / "closed"
	local closed = state == "closed"
	local half = state == "half"
	ctx.transparency("Lid" .. side, closed and 0 or 1)
	ctx.transparency("LidA" .. side, closed and 0 or 1)
	ctx.transparency("LidB" .. side, closed and 0 or 1)
	ctx.transparency("HalfLid" .. side, half and 0 or 1)
	ctx.transparency("HalfLash" .. side, half and 0 or 1)
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes
	------------------------------------------------------------------
	local busy = L.env(c, WIND, 0.25, 13.6 - WIND - 0.25, 0.9)
	local idleW = 1 - busy

	-- idle gags
	local sly = L.env(c, 0.1, 0.2, 0.95, 0.25)
	local windL = L.env(c, 1.3, 0.35, 0.0, 0.2, "cubicOut", "quadIn")
	local lunge = L.env(c, 1.62, 0.12, 0.42, 0.45, "backOut", "backInOut")
	local kid = L.env(c, 2.15, 0.12, 0.35, 0.25, "backOut", "quadIn")
	local inhale = L.env(c, 2.7, 0.35, 0.0, 0.12, "cubicOut", "quadIn")
	local squirt = L.env(c, 3.05, 0.06, 0.25, 0.3, "quadOut", "quadInOut")
	local cackle = L.env(c, 3.3, 0.12, 0.55, 0.25)
	local tease = L.env(c, 4.1, 0.25, 0.75, 0.25, "backOut", "quadInOut")
	local giggle = L.env(c, 5.3, 0.12, 0.5, 0.2)
	local tip = L.env(c, 6.1, 0.18, 0.2, 0.22, "backOut", "quadInOut")

	-- signature
	local wind = L.env(c, WIND, 0.4, 0.0, 0.0, "cubicOut")
	local tuck = L.env(c, DIVE, 0.2, FALL - DIVE - 0.1, 0.25)
	local flash = L.env(c, APEX, 0.06, 0.3, 0.3, "backOut", "quadIn")
	local splay = L.env(c, FALL, 0.25, 0.45, 0.6, "backOut", "quadInOut")
	local squash = L.env(c, SPLAT, 0.05, 0.12, 0.6, "quadOut", "quadInOut")
	local slapLift = max(L.env(c, LIFT1, 0.4, 0.0, 0.0, "cubicOut"), L.env(c, LIFT2, 0.22, 0, 0, "cubicOut"))
	local slapHit = max(L.env(c, SLAP1, 0.03, 0.06, 0.2, "quadIn", "quadOut"), L.env(c, SLAP2, 0.03, 0.08, 0.3, "quadIn", "quadOut"))
	local bow = L.env(c, BOW, 0.4, BOWEND - BOW - 0.4, 0.45, "backOut", "backInOut")
	local wink2 = L.env(c, 12.05, 0.08, 0.6, 0.12)

	------------------------------------------------------------------
	-- BODY
	------------------------------------------------------------------
	local swimY = 0.7 * wave(t, 8 * F) + 0.2 * wave(t, 21 * F, 0.3)
	local bx = 0.4 * wave(t, 3 * F, 0.2) * idleW
	local by = swimY * idleW
	local bz = 0
	local pitch = 3.5 * wave(t, 8 * F, 0.25) * idleW
	local yaw = (6 * wave(t, 4 * F) + 4 * L.noise(t, 1.3, 0.3)) * idleW
	local roll = 4 * wave(t, 5 * F, 0.1) * idleW

	-- sly glance: lean into the side-eye
	yaw += 5 * sly * (c < 0.7 and 1 or -1)
	roll += 4 * sly * (c < 0.7 and -1 or 1)
	-- fake-out lunge
	bz += 2.6 * windL - 5.0 * lunge
	pitch += 10 * windL - 9 * lunge + 6 * kid
	by += 0.4 * windL + 0.6 * lunge + 0.6 * kid
	roll += 3 * lunge * sin(TAU * 14 * c)
	-- squirt: inhale rise, recoil, cackle bounce
	by += 1.0 * inhale - 0.3 * squirt + 0.5 * cackle * abs(sin(TAU * 4 * c))
	pitch += 7 * inhale - 6 * squirt
	bz += 0.8 * squirt
	roll += 6 * cackle * sin(TAU * 4 * c)
	-- tongue tease: side to side sass
	yaw += 8 * tease * sin(TAU * 2.4 * (c - 4.1))
	roll += 10 * tease
	-- giggle wiggle
	roll += 12 * giggle * sin(TAU * 7 * c)
	by += 0.6 * giggle * abs(sin(TAU * 7 * c))
	yaw += 6 * giggle * sin(TAU * 3.5 * c)
	-- crown tip: polite little nod
	pitch -= 6 * tip

	-- signature translation + rotation tracks
	local sy = track(c, {
		{ WIND, 0 }, { WIND + 0.35, 4.5, "cubicOut" }, { DIVE, 4.5 }, { DIVE + 0.4, 3.6, "quadIn" },
		{ BREACH, 3.6 }, { BREACH + 0.4, 10.5, "cubicOut" }, { APEX, 11.5, "quadOut" }, { FALL, 11.5, "sineInOut" },
		{ SPLAT, -1.1, "quadIn" }, { SPLAT + 0.15, -0.8, "quadOut" }, { SPLAT + 0.45, 1.2, "quadOut" }, { SPLAT + 0.75, 0.2, "quadInOut" },
		{ LIFT1, 0.2 }, { LIFT1 + 0.3, 0.8, "quadOut" }, { SLAP1, -0.4, "quadIn" }, { SLAP1 + 0.2, 0.4, "quadOut" },
		{ SLAP2, -0.6, "quadIn" }, { SLAP2 + 0.25, 0.4, "quadOut" }, { BOW, 0, "quadInOut" }, { BOW + 0.4, 1.4, "backOut" },
		{ BOWEND, 1.4 }, { BOWEND + 0.4, 1.2, "backOut" }, { 13.6, 0, "quadInOut" },
	})
	local sp = track(c, {
		{ WIND, 0 }, { WIND + 0.35, 18, "cubicOut" }, { DIVE, 18 }, { DIVE + 0.35, -26, "backIn" }, { BREACH, -26 },
		{ BREACH + 0.45, 58, "cubicOut" }, { APEX, 62, "quadOut" }, { FALL, 66, "sineInOut" }, { SPLAT - 0.1, -8, "quadIn" },
		{ SPLAT + 0.12, -3, "quadOut" }, { SPLAT + 0.5, 4, "quadInOut" }, { LIFT1, 0, "quadInOut" },
		{ LIFT1 + 0.3, -5, "quadOut" }, { SLAP1, 4, "quadIn" }, { SLAP1 + 0.2, -4, "quadOut" }, { SLAP2, 6, "quadIn" },
		{ SLAP2 + 0.3, 0, "quadOut" }, { BOW, 0 }, { BOW + 0.4, -8, "backOut" }, { BOWEND, -8 }, { BOWEND + 0.45, 3, "backOut" },
		{ 13.7, 0, "quadInOut" },
	})
	local spin = track(c, { { BREACH, 0 }, { APEX - 0.05, 720, "cubicOut" } })
	local sz = track(c, { { DIVE, 0 }, { DIVE + 0.4, -1.5, "quadIn" }, { BREACH + 0.5, -3, "quadOut" }, { SPLAT, 0, "quadIn" } })
	local wob = L.env(c, SPLAT + 0.1, 0.1, 0.4, 0.9, "quadOut", "quadIn")
	pose.Body = pa(bx, by + sy, bz + sz, pitch + sp, yaw, roll + spin + 10 * wob * sin(TAU * 2.5 * (c - SPLAT))
		+ 3 * wind * sin(TAU * 9 * c) * (1 - tuck))

	------------------------------------------------------------------
	-- JAW (one hinged jaw): base grin, smirk roll, talk/laugh/roar
	------------------------------------------------------------------
	local chat = abs(sin(TAU * 8 * c))
	local jOpen = 8 + 3 * L.wave01(t, 8 * F) * idleW
		+ 4 * sly
		- 4 * windL + 48 * lunge + 18 * kid
		- 4 * inhale + 14 * squirt + (12 + 13 * chat) * cackle
		+ 24 * tease
		+ (8 + 22 * chat) * giggle
		+ 8 * tip
		+ 22 * wind * (1 - tuck) - 4 * tuck + 30 * flash + 36 * splay * (1 - squash) + 4 * squash
		+ 18 * slapHit + 10 * slapLift + 10 * bow
	local smirk = 6 * sly + 5 * tip + 5 * bow + 3 * idleW * L.wave01(t, 2 * F) + 4 * tease
	------------------------------------------------------------------
	-- HEAD
	------------------------------------------------------------------
	local hP = 2.5 * wave(t, 8 * F, 0.45) * idleW - 8 * windL + 10 * lunge - 5 * kid + 6 * inhale - 6 * squirt
		- 6 * cackle * abs(sin(TAU * 4 * c)) - 4 * tease - 10 * tip
		+ 10 * wind * (1 - tuck) - 6 * tuck + 14 * squash - 10 * splay * (1 - squash) - 14 * bow
		- 6 * slapLift + 5 * slapHit + 4 * giggle * sin(TAU * 7 * c + 1)
	local hY = (5 * wave(t, 4 * F, 0.3)) * idleW + 7 * sly * (c < 0.7 and 1 or -1) - 10 * tease * sin(TAU * 1.2 * (c - 4.1))
		+ 6 * bow * sin(TAU * 0.8 * (c - BOW))
	local hR = 4 * wave(t, 5 * F, 0.35) * idleW + 12 * tease + 8 * tip + 10 * bow + 6 * giggle * sin(TAU * 7 * c + 0.6)
	hP += 0.3 * jOpen - 32 * flash
	pose.Head = ang(hP, hY, hR)

	pose.Jaw = ang(-jOpen, 0, (c < 0.7 and -smirk or smirk))

	-- tongue: tease (raspberry), "nyeh" flick, cheeky peek on the bow
	local tOut = max(tease, 0.75 * kid, 0.55 * wink2, 0.6 * splay)
	local wig = sin(TAU * 6 * c)
	pose.Tongue = pa(0, 0.55 * tOut, -3.6 * tOut, 6 * tOut, 0, 0)
	pose.TongueTip = ang(-28 * tOut + 10 * tOut * wig, 30 * tOut * sin(TAU * 4 * c), 14 * tOut * wig)

	------------------------------------------------------------------
	-- EYES: pupils, lids, brows
	------------------------------------------------------------------
	local dart = math.clamp(3 * sin(TAU * 5 * F * t), -1, 1) * 0.3
	local px = (dart + 0.1 * L.noise(t, 5.1, 3)) * idleW
	local py = -0.05 * idleW
	-- sly glance: hard side-eye
	px += track(c, { { 0.1, 0 }, { 0.3, 0.6, "backOut" }, { 0.62, 0.6 }, { 0.75, -0.6, "quadInOut" }, { 1.1, -0.6 }, { 1.3, 0, "quadInOut" } })
	py += -0.15 * sly
	-- the lunge: glare straight ahead; squirt: look up at the jet then at you
	py += -0.25 * windL + 0.35 * inhale + 0.35 * flash - 0.3 * bow
	px += 0.35 * tease * sin(TAU * 1.2 * (c - 4.1))
	-- breach: roll the eyes round with the spin
	local sw = L.env(c, BREACH - 0.05, 0.15, APEX - BREACH - 0.15, 0.2)
	px += 0.45 * sw * cos(TAU * 2.2 * (c - BREACH))
	py += 0.4 * sw * sin(TAU * 2.2 * (c - BREACH))
	pose.PupilR = CFrame.new(px, py, 0)
	pose.PupilL = CFrame.new(px, py, 0)
	local tiny = (c > 1.62 and c < 2.1) or (c > APEX and c < APEX + 0.45) or (c > SPLAT - 0.02 and c < SPLAT + 0.12)
	for _, side in { "R", "L" } do
		ctx.transparency("PupilBig" .. side, tiny and 1 or 0)
		ctx.transparency("Glint" .. side, tiny and 1 or 0)
		ctx.transparency("PupilSmall" .. side, tiny and 0 or 1)
	end
	-- eye pop on the lunge / flash
	local pop = max(lunge, flash, 0.6 * squash)
	L.both(pose, "Eye", pa(0, 0.2 * pop, -0.5 * pop, 0, 0, 0))

	-- lid states
	local blink = false
	for _, b in { 0.95, 2.95, 4.0, 7.05, 14.4 } do
		if c > b and c < b + 0.12 then blink = true end
	end
	local laugh = (kid > 0.4) or (cackle > 0.3) or (giggle > 0.3) or (c > FALL + 0.15 and c < SPLAT + 0.35)
	local stateR, stateL = "open", "open"
	if sly > 0.3 or windL > 0.4 or (tip > 0.3 and false) or (inhale > 0.5) then
		stateR, stateL = "half", "half"
	end
	if blink or laugh then
		stateR, stateL = "closed", "closed"
	end
	if tease > 0.3 or tip > 0.3 or wink2 > 0.3 then
		stateL = "closed"
		if stateR == "closed" then stateR = "open" end
	end
	if (c > 11.0 and c < 11.6) then stateR, stateL = "half", "half" end -- smug after the slaps
	setEye(ctx, "R", stateR)
	pose.LidR = CFrame.new(0, stateR == "closed" and -0.1 or 0, 0)
	pose.LidL = CFrame.new(0, stateL == "closed" and -0.1 or 0, 0)
	setEye(ctx, "L", stateL)

	-- brows: R is the cocked one; L lowers into the smirk
	local bIdle = 0.12 * wave(t, 9 * F) * idleW
	local upR = bIdle + 0.55 * sly - 0.35 * windL - 0.45 * lunge + 0.5 * kid + 0.4 * inhale + 0.3 * cackle
		+ 0.55 * tease + 0.4 * giggle + 0.6 * tip + 0.7 * flash - 0.3 * tuck + 0.5 * splay + 0.6 * bow + 0.3 * slapLift
	local upL = bIdle - 0.1 * sly - 0.35 * windL - 0.45 * lunge + 0.5 * kid + 0.4 * inhale + 0.3 * cackle
		- 0.15 * tease + 0.4 * giggle - 0.1 * tip + 0.7 * flash - 0.3 * tuck + 0.5 * splay - 0.1 * bow + 0.3 * slapLift
	local tR = 4 * wave(t, 9 * F, 0.2) * idleW + 10 * sly + 22 * windL + 25 * lunge - 8 * kid - 12 * cackle
		+ 14 * tease - 10 * giggle + 10 * tip - 15 * flash + 16 * tuck - 10 * splay + 12 * bow
	local tL = 4 * wave(t, 9 * F, 0.2) * idleW + 20 * sly + 22 * windL + 25 * lunge - 8 * kid - 12 * cackle
		+ 18 * tease - 10 * giggle + 18 * tip - 15 * flash + 16 * tuck - 10 * splay + 18 * bow
	-- the cocked brow swaps sides with the glance
	if c < 0.7 and sly > 0 then upR, upL, tR, tL = upL, upR, tL, tR end
	pose.BrowR = pa(0, upR, 0, 0, 0, tR)
	pose.BrowL = L.mirror(pa(0, upL, 0, 0, 0, tL))

	-- laughing tears
	local tearOn = (cackle > 0.3) or (giggle > 0.3)
	local tu = ((c * 1.6) % 1)
	L.both(pose, "Tear", CFrame.new(0.6 * tu, -1.4 * tu, 0))
	for _, side in { "R", "L" } do
		ctx.transparency("TearA" .. side, tearOn and (tu > 0.8 and 0.6 or 0.15) or 1)
		ctx.transparency("TearB" .. side, tearOn and (tu > 0.8 and 0.6 or 0.15) or 1)
	end

	-- wink star (crown tip, tongue tease, bow)
	local starA = max(L.env(c, 6.18, 0.1, 0.25, 0.12, "backOut"), L.env(c, 4.25, 0.1, 0.3, 0.12, "backOut"), L.env(c, 12.08, 0.1, 0.5, 0.12, "backOut"))
	pose.Star = pa(-0.8 * starA, 0.6 * starA, 0, 0, 0, 200 * c)
	ctx.transparency("StarA", starA > 0.1 and 0 or 1)
	ctx.transparency("StarB", starA > 0.1 and 0 or 1)

	------------------------------------------------------------------
	-- CROWN: jaunty wobble, hat tips, apex flash pop + spin
	------------------------------------------------------------------
	local crownSpin = track(c, { { APEX, 0 }, { APEX + 0.7, 360, "cubicOut" } })
	local cPop = L.env(c, APEX - 0.02, 0.1, 0.25, 0.35, "backOut", "bounceOut")
	local cLand = L.env(c, SPLAT, 0.05, 0.05, 0.4, "quadOut", "bounceOut")
	local bowTip = L.env(c, BOW + 0.15, 0.3, BOWEND - BOW - 0.6, 0.4, "backOut", "bounceOut")
	pose.Crown = pa(0, 0.9 * tip + 2.4 * cPop + 1.6 * bowTip + 0.8 * cLand + 0.6 * lunge, -0.8 * tip - 1.4 * bowTip,
		3 * wave(t, 8 * F, 0.5) * idleW - 26 * tip - 34 * bowTip + 10 * windL + 8 * giggle * sin(TAU * 7 * c) - 12 * cLand,
		crownSpin, 3 * wave(t, 5 * F, 0.1) * idleW + 10 * tip + 8 * bowTip + 6 * cackle * sin(TAU * 4 * c))
	local beamOn = c > APEX and c < APEX + 0.35
	ctx.transparency("CrownBeam", beamOn and (c < APEX + 0.25 and 0.15 or 0.6) or 1)
	ctx.light("CrownLight", 0.4 + 1.1 * flash + 0.3 * tip)

	------------------------------------------------------------------
	-- FINS: paddle, flare on the lunge, tuck on the dive, splay on the
	-- belly-flop, sweep across the chest on the bow
	------------------------------------------------------------------
	local paddle = wave(t, 8 * F, 0.1)
	-- the BOW flourish: right fin shoots up and twirls (courtly hand-roll),
	-- then sweeps grandly across the chest; left fin flings up and back;
	-- on the way up both fins flare out in a "ta-da!"
	local bRz = track(c, { { BOW, 0 }, { BOW + 0.35, 105, "backOut" }, { BOWEND, 92, "sineInOut" }, { BOWEND + 0.35, 45, "backOut" }, { 13.75, 0, "quadInOut" } })
	local bRy = track(c, { { BOW, 0 }, { BOW + 0.35, 45, "backOut" }, { BOWEND, 30, "sineInOut" }, { BOWEND + 0.35, -15, "backOut" }, { 13.75, 0, "quadInOut" } })
	local twirl = L.env(c, BOW + 0.25, 0.15, BOWEND - BOW - 0.5, 0.2)
	local bRx = 60 * twirl * sin(TAU * 2.2 * (c - BOW - 0.25))
	local bLz = track(c, { { BOW, 0 }, { BOW + 0.45, 75, "backOut" }, { BOWEND, 62 }, { BOWEND + 0.35, 55, "backOut" }, { 13.75, 0, "quadInOut" } })
	local bLy = track(c, { { BOW, 0 }, { BOW + 0.45, -50, "backOut" }, { BOWEND, -40 }, { BOWEND + 0.35, -10, "backOut" }, { 13.75, 0, "quadInOut" } })
	local function fin(side, ph, bowArm)
		local z = 14 * paddle * idleW + 25 * lunge + 15 * windL + 20 * cackle * sin(TAU * 4 * c + ph)
			+ 30 * giggle * sin(TAU * 7 * c + ph) + 20 * tease * sin(TAU * 2 * c + ph)
			+ 20 * wind * (1 - tuck) - 30 * tuck + 45 * splay - 25 * squash + 25 * slapHit
			+ (bowArm and bRz or bLz) + 6 * bow * sin(TAU * 2 * c + ph)
		local x = 10 * paddle * idleW + 20 * lunge - 25 * tuck + 20 * splay + (bowArm and bRx or 0)
		local y = -15 * tuck - 10 * lunge + (bowArm and bRy or bLy)
		local tipZ = 12 * wave(t, 8 * F, 0.3) * idleW + 15 * squash + 18 * splay * sin(TAU * 5 * c)
			+ 10 * giggle * sin(TAU * 7 * c + 1) - 15 * tuck + (bowArm and 25 * twirl * sin(TAU * 2.2 * (c - BOW) - 0.8) or 15 * bow)
		return ang(x, y, z), ang(0, 0, tipZ)
	end
	local fR, tR2 = fin("R", 0, true)
	local fL, tL2 = fin("L", 0.25, false)
	pose.FinR, pose.FinTipR = fR, tR2
	pose.FinL, pose.FinTipL = L.mirror(fL), L.mirror(tL2)

	------------------------------------------------------------------
	-- DORSAL (follow-through) + MEDALLION swing
	------------------------------------------------------------------
	local dsw = 6 * wave(t, 5 * F, 0.2) * idleW + 14 * giggle * sin(TAU * 7 * c - 0.8) + 8 * wob * sin(TAU * 2.5 * (c - SPLAT) - 1)
	pose.Dorsal = ang(-12 * lunge + 18 * squash - 16 * sw + 8 * slapHit, 0, 1.4 * dsw)
	pose.DorsalTip = ang(-10 * lunge + 18 * squash - 18 * sw + 6 * slapHit, 0, 1.6 * dsw + 6 * wave(t, 5 * F, -0.1) * idleW)
	local mSw = 14 * wave(t, 8 * F, 0.6) * idleW + 30 * lunge - 25 * windL + 20 * giggle * sin(TAU * 7 * c - 1)
		+ 70 * squash + 40 * splay + 25 * tuck + 30 * cackle * sin(TAU * 4 * c - 1) - 20 * bow
	pose.Medal = ang(mSw, 0, 10 * wave(t, 5 * F, 0.3) * idleW + 15 * giggle * sin(TAU * 7 * c))
	ctx.light("MedalLight", 0.3 + 0.25 * L.wave01(t, 10 * F) + 0.6 * flash)

	------------------------------------------------------------------
	-- TAIL: vertical fluke strokes (orca!), cocked on the wind-up, streams
	-- on the breach, V-squash on the flop, the double slap
	------------------------------------------------------------------
	local ch = L.chain(t, 8 * F, 0.09, 1)
	local strokeA = idleW
	local tailLift = -14 * wind * (1 - tuck) + 10 * tuck * (1 - sw) - 30 * sw - 22 * squash + 12 * splay
		- 30 * slapLift + 22 * slapHit - 8 * bow + 10 * windL - 8 * lunge
	local tWag = 10 * giggle * sin(TAU * 7 * c) + 6 * tease * sin(TAU * 2.4 * (c - 4.1))
	pose.Tail1 = ang(6 * ch(0) * strokeA + 0.6 * tailLift, tWag, 0)
	pose.Tail2 = ang(9 * ch(1) * strokeA + 0.8 * tailLift + 6 * sw * sin(TAU * 3 * c), 1.3 * tWag, 0)
	pose.Tail3 = ang(12 * ch(2) * strokeA + 0.8 * tailLift + 8 * sw * sin(TAU * 3 * c - 0.6), 1.5 * tWag, 0)
	pose.Fluke = ang(16 * ch(3) * strokeA + 0.9 * tailLift + 10 * sw * sin(TAU * 3 * c - 1.2) + 12 * wob * sin(TAU * 3 * (c - SPLAT)), 1.6 * tWag, 0)
	local lobe = 6 * wave(t, 8 * F, -0.3) * idleW + 14 * slapHit + 10 * splay
	pose.FlukeR = ang(0, 0, lobe)
	pose.FlukeL = L.mirror(ang(0, 0, lobe))

	------------------------------------------------------------------
	-- floating marble cubes / crystal shards: bob + tumble, flung on splat
	------------------------------------------------------------------
	local fling = L.env(c, SPLAT, 0.15, 0.3, 1.2, "quadOut", "elasticOut")
	local DIRS = { { 1, 0.5, -0.4 }, { -1, 0.4, -0.2 }, { 0.8, 0.2, 0.6 }, { -0.8, 0.6, 0.5 }, { 0.1, 0.8, 0.8 } }
	for i = 1, 5 do
		local d = DIRS[i]
		local out = 4 * fling + 1.5 * flash
		local s = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(0.8 * wave(t, 2 * F, i * 0.21) + out * d[1], 1.0 * wave(t, 4 * F, i * 0.27) + out * d[2] + 0.3 * sy,
			0.8 * wave(t, 2 * F, i * 0.21 + 0.25) + out * d[3], 360 * 2 * F * t * s + 30 * i, 360 * 3 * F * t, 25 * i + 140 * fling * s)
	end

	------------------------------------------------------------------
	-- blowhole squirt drops (arc forward at the viewer)
	------------------------------------------------------------------
	for k = 1, 7 do
		local u = (c - 3.05 - (k - 1) * 0.05) / 0.85
		local tr = 1
		local cfk = CFrame.new()
		if u > 0 and u < 1 then
			local e = L.ease.quadOut(u)
			cfk = pa(0.8 * sin(k * 1.7) * u, 16 * u - 21 * u * u, -34 * u, 45 * k * u, 90 * u, 0)
			tr = u > 0.85 and 0.6 or 0.15
		end
		pose["Squirt" .. k] = cfk
		ctx.transparency("SquirtP" .. k, tr)
	end

	------------------------------------------------------------------
	-- swirling water rings (dive + breach)
	------------------------------------------------------------------
	local bp = L.clamp01((sp - 15) / 45) -- how upright the body is
	local cotp = cos(math.rad(sp)) / max(0.4, sin(math.rad(sp)))
	local bodyY = 12.5 + sy
	local spreadK = track(c, { { BREACH, 0 }, { APEX, 1, "cubicOut" } })
	local BUNCH, SPREAD = { 1, -4, -9 }, { -1, 1.5, 4 }
	for k = 1, 3 do
		local on0, on1 = DIVE + 0.05 + (k - 1) * 0.06, FALL + 0.2 + (k - 1) * 0.08
		local vis = c > on0 and c < on1
		local a = L.env(c, on0, 0.25, on1 - on0 - 0.55, 0.3, "backOut", "quadIn")
		local ry = L.lerp(BUNCH[k], SPREAD[k], spreadK) + 2 * (1 - a) + 0.5 * wave(t, 3, k * 0.3)
		local ringY = 6 * k + 6 + ry
		local rz = (-3 * spreadK - (ringY - bodyY) * cotp) * bp
		local spinR = 540 * (c - on0) * (k % 2 == 0 and -1 or 1)
		pose["Swirl" .. k] = pa(0, ry, rz, -0.6 * (90 - sp) * bp + 8 * sin(TAU * (c + k * 0.3)), spinR, 8 * cos(TAU * (c + k * 0.3)))
		local trv = vis and (a > 0.6 and 0.25 or 0.6) or 1
		for i = 0, 11 do
			ctx.transparency("Sw" .. k .. "_" .. i, trv)
		end
	end

	------------------------------------------------------------------
	-- belly-flop splash crown + wave rings
	------------------------------------------------------------------
	for i = 1, 12 do
		local a = (i - 0.5) / 12 * TAU
		local delay = (i % 3) * 0.04
		local lean = track(c, { { SPLAT + delay, 80 }, { SPLAT + delay + 0.28, 10, "backOut" }, { SPLAT + 0.75, 22, "quadInOut" }, { SPLAT + 1.35, 82, "quadIn" } })
		local up = L.env(c, SPLAT + delay, 0.25, 0.2, 0.8, "backOut", "quadIn")
		local R = CFrame.Angles(0, a, 0)
		pose["Splash" .. i] = CFrame.new(0, 0.6 * up, 0) * R * CFrame.Angles(math.rad(lean), 0, 0) * R:Inverse()
		local vis = c > SPLAT + delay and c < SPLAT + 1.35
		local tr = vis and (c < SPLAT + 0.85 and 0.2 or 0.55) or 1
		ctx.transparency("SplCol" .. i, tr)
		ctx.transparency("SplCap" .. i, tr)
	end
	-- wave ring 1 (the splat) then a second smaller ring from the last slap
	local w1 = (c - SPLAT) / 1.4
	local w2 = (c - SLAP2) / 1.1
	local wv, ws, wl = false, 0, 0
	if w1 > 0 and w1 < 1 then
		wv, ws, wl = true, 1.4 * L.ease.cubicOut(w1), w1
	elseif w2 > 0 and w2 < 1 then
		wv, ws, wl = true, 0.2 + 0.9 * L.ease.cubicOut(w2), w2
	end
	for i = 1, 16 do
		local a = (i - 1) / 16 * TAU
		pose["Wave" .. i] = pa(9 * sin(a) * ws, 0.25 * sin(TAU * (2 * wl + i / 8)), 15 * cos(a) * ws, 0, 0, 0)
		ctx.transparency("WaveP" .. i, wv and (wl < 0.6 and 0.2 or 0.6) or 1)
	end
	pose.SplashFX = CFrame.new(0, 0.5 * squash, 0)
	ctx.light("SplashLight", 0.01 + 1.3 * L.env(c, SPLAT, 0.05, 0.1, 0.6))

	------------------------------------------------------------------
	-- effects on the beats
	------------------------------------------------------------------
	if ctx.crossed(1.66) then ctx.emit("Raspberry", 14) end
	if ctx.crossed(2.25) then ctx.emit("Raspberry", 6) end
	if ctx.crossed(3.05) then ctx.emit("SpoutBurst", 40) end
	if ctx.crossed(4.4) then ctx.emit("Raspberry", 14) end
	if ctx.crossed(4.75) then ctx.emit("Raspberry", 12) end
	if ctx.crossed(5.45) then ctx.emit("CrystalSparkle", 8) end
	if ctx.crossed(6.2) then ctx.emit("CrownBurst", 10) end
	if ctx.crossed(DIVE + 0.3) then
		ctx.emit("SplashBurst", 25)
		ctx.emit("SplashMist", 10)
	end
	if ctx.crossed(BREACH + 0.05) then
		ctx.emit("SplashBurst", 40)
		ctx.emit("SpoutBurst", 25)
	end
	if ctx.crossed(APEX) then
		ctx.emit("CrownBurst", 70)
		ctx.emit("CrystalSparkle", 20)
	end
	if ctx.crossed(SPLAT) then
		ctx.emit("SplashBurst", 90)
		ctx.emit("SplashMist", 35)
		ctx.emit("TailSplash", 20)
	end
	if ctx.crossed(SLAP1 + 0.02) then
		ctx.emit("TailSplash", 40)
		ctx.emit("SplashMist", 10)
	end
	if ctx.crossed(SLAP2 + 0.02) then
		ctx.emit("TailSplash", 55)
		ctx.emit("SplashMist", 16)
		ctx.emit("SplashBurst", 20)
	end
	if ctx.crossed(12.1) then ctx.emit("CrownBurst", 14) end
end

return M
