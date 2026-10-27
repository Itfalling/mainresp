--!nocheck
-- Atlantis Sky Whale motion. Personality: GENTLE, MOTHERLY GUARDIAN.
-- Always: slow hovering swim, fluke strokes rippling down the tail, flipper
-- strokes, breathing belly, blinks + pupil darts, waterfalls, seaweed,
-- tiny city fish circling her, crystal cubes orbiting.
-- IDLE GAGS (0 - 9 s)
--   0.3  HUM SONG: half-lidded dreamy eyes, "la-la-la" mouth, head sways,
--        gold music notes float out of her mouth
--   2.8  PAT THE CITY: leans left, her right flipper slides up her flank,
--        stands beside the city and flops its hand over the wall: pat-pat-pat
--        (city jolts, towers hop, sparkles), proud ^ ^ eyes, blush, a heart
--   4.8  BLOWHOLE FOUNTAIN: puffs her cheeks, squeezes her eyes, PFOOSH a
--        tall water column with a foam crown + raining droplets shoots out of
--        the forehead blowhole (tilted forward so it reads from the front), sparkly eyes, giggles
--   6.4  FISH BOOP: a city fish swims up and boops her nose -> cross-eyed,
--        brows up, "o" mouth, then a giggle, happy wiggle, flipper clap,
--        blush lines and two hearts
-- SIGNATURE "RISING ATLANTIS" (9 - 19.6 s)
--   9.0  DEEP BREATH: sinks + crouches nose-down, belly swells, cheeks
--        puff, eyes shut, flippers fold, tail curls up
--  10.3  RISE / BREACH: launches up with a huge tail down-stroke, nose up
--        30 deg, flippers flare, mouth wide open "AAAH", sparkle-star eyes
--  11.4  SPIRE BEAM + HALO: the crystal spire charges, a beam of light shoots
--        into the sky, a halo of rays spins round the tip, she sings
--  12.4  CITY RISES: the four towers rise out of the city one by one with
--        overshoot, golden firework chunks launch and burst
--  13.3  TWIRL: a full 360 pirouette with a bank, flippers out like a dancer
--  14.9  FLUKE SLAP: tail lifts high (nose dips), WHIPS down, a giant splash
--        crown erupts under the flukes, squash, city jolts, laughing
--  16.6  PROUD HAPPY SETTLE: ^ ^ eyes, big blush, three hearts, flipper
--        claps, a proud bow, towers sink home, a last contented hum
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 20

local sin, cos, pi, max, min, abs, clamp = math.sin, math.cos, math.pi, math.max, math.min, math.abs, math.clamp
local TAU = 2 * pi
local F = 1 / 20 -- whole cycles per loop

-- signature beats
local BREATH, LAUNCH, BEAM, TOWERS, SPIN0, SPIN1, WIND, SLAP, SETTLE = 9.0, 10.3, 11.4, 12.4, 13.3, 14.9, 14.9, 15.85, 16.6

-- pat pose (right flipper standing beside the city, hand flopped over the wall)
local PAT_X, PAT_Y, PAT_Z, PAT_T, PAT_H, PAT_LIFT = 40, 215, 90, 10, -75, -70

local function env(c, s, a, h, r, ei, eo)
	return L.env(c, s, a, h, r, ei, eo)
end

-- window progress helper: u in [0,1] inside [s, s+d], nil outside
local function win(c, s, d)
	local u = (c - s) / d
	if u >= 0 and u <= 1 then
		return u
	end
	return nil
end

-- the body's vertical offset (also used by the fish so they stay with her)
local function riseAt(c)
	return L.track(c, {
		{ BREATH, 0 }, { 9.9, -0.9, "quadInOut" }, { LAUNCH, -1.15, "sineInOut" },
		{ 10.85, 6.4, "cubicOut" }, { 11.25, 5.5, "quadInOut" }, { 12.3, 5.9, "sineInOut" },
		{ 13.3, 5.6, "sineInOut" }, { 14.2, 6.5, "sineInOut" }, { WIND, 6.2, "sineInOut" },
		{ 15.5, 4.2, "quadInOut" }, { SLAP, 1.2, "quadIn" }, { 16.05, 0.5, "quadOut" },
		{ 16.6, 2.0, "quadOut" }, { 17.3, 0.6, "quadInOut" }, { 18.2, 1.0, "sineInOut" }, { 19.6, 0, "sineInOut" },
	})
end

local FISH = {
	-- rest pos (body space), orbit freq (cycles/loop), phase, height, dir
	{ Vector3.new(9.0, 17.0, -8.0), 2, 0.0, 17.0, 1 },
	{ Vector3.new(-9.5, 18.0, 4.0), 3, 0.35, 18.2, -1 },
	{ Vector3.new(8.5, 16.5, 10.0), 2, 0.55, 16.4, 1 },
}
local BOOP = Vector3.new(0, 10.7, -19.55)

local function fishPos(k, t, c)
	local f = FISH[k]
	-- extra lap during the signature (seamless: adds exactly one lap)
	local extra = L.track(c, { { BREATH, 0 }, { 19.4, 1, "sineInOut" } })
	local th = TAU * (f[2] * F * t + f[3] + extra) * f[5]
	local p = Vector3.new(10.5 * sin(th), f[4] + 1.0 * sin(th * 2 + k), -1 + 20.5 * cos(th))
	if k == 1 then
		local w = env(c, 6.3, 0.7, 0.75, 0.9, "cubicInOut", "cubicInOut")
		if w > 0 then
			-- the boop: a little bump into her nose at 7.05
			local bump = env(c, 6.95, 0.1, 0.02, 0.25, "quadIn", "backOut")
			local hover = BOOP + Vector3.new(0.3 * sin(TAU * 1.5 * c), 0.25 * sin(TAU * 1.1 * c), -0.9 + 0.9 * bump)
			p = p:Lerp(hover, w)
		end
	end
	return p
end

local ORBS = {
	{ Vector3.new(13.5, 15.0, -10), 0.0, 13.0, 16.5 },
	{ Vector3.new(-14, 12.0, -5), 0.22, 14.0, 18.5 },
	{ Vector3.new(13, 10.0, 8), 0.45, 13.5, 15.5 },
	{ Vector3.new(-12, 19.0, 8), 0.63, 12.5, 21.0 },
	{ Vector3.new(-8, 21.0, -14), 0.82, 14.5, 19.5 },
}

-- note / heart start times
local NOTES = { { 0.55, 1.2, 1.85 }, { 17.85, 18.3 } }
local HEARTS = { { 4.05, 16.85 }, { 7.45, 17.2 }, { 7.75, 17.55 } }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes
	------------------------------------------------------------------
	local busy = env(c, 8.9, 0.4, 10.0, 0.6)
	local idleW = 1 - busy
	local hum = env(c, 0.3, 0.3, 1.9, 0.35)
	local la = 0.5 - 0.5 * cos(TAU * 1.5 * (c - 0.3))
	local peek = env(c, 2.8, 0.45, 1.3, 0.5, "backOut", "cubicInOut")
	local pat = env(c, 2.85, 0.4, 1.25, 0.45, "backOut", "cubicInOut")
	-- three little taps on the city wall (contact at 3.3 / 3.65 / 4.0)
	local tapU = clamp((c - 3.3) / 1.05, 0, 1)
	local tapLift = (c > 3.3 and c < 4.35) and sin(pi * 3 * tapU) ^ 2 or 0
	local tapHit = 0
	for _, h in { 3.3, 3.65, 4.0 } do
		tapHit = max(tapHit, env(c, h, 0.03, 0.03, 0.2, "quadOut", "quadOut"))
	end
	local proud = env(c, 3.85, 0.15, 0.6, 0.25)
	local puff = env(c, 4.8, 0.4, 0.15, 0.08, "quadOut", "expoIn")
	local spout = env(c, 5.3, 0.15, 0.6, 0.45, "backOut", "quadIn")
	local giggleA = env(c, 5.45, 0.1, 0.7, 0.3)
	local boopApp = env(c, 6.4, 0.5, 0.15, 0.1)
	local boop = env(c, 7.0, 0.06, 0.35, 0.25, "backOut", "quadInOut")
	local giggleB = env(c, 7.35, 0.12, 0.75, 0.35)
	local clapI = env(c, 7.5, 0.15, 0.5, 0.25)

	local breath = env(c, BREATH, 0.9, 0.3, 0.25, "quadInOut", "quadIn")
	local launch = env(c, LAUNCH, 0.4, 2.6, 0.6, "backOut", "sineInOut")
	local sing = env(c, 10.6, 0.3, 2.6, 0.4)
	local beam = env(c, BEAM, 0.25, 2.2, 0.3, "expoOut", "quadIn")
	local haloOn = env(c, BEAM + 0.1, 0.3, 2.4, 0.3, "backOut", "quadIn")
	local spinU = L.track(c, { { SPIN0, 0 }, { SPIN1, 1, "cubicInOut" } })
	local spinning = env(c, SPIN0, 0.3, 1.0, 0.3)
	local wind = env(c, WIND, 0.6, 0.05, 0.3, "quadInOut", "quadIn")
	local impact = env(c, SLAP, 0.04, 0.2, 0.6, "quadOut", "quadInOut")
	local laugh = env(c, SLAP + 0.05, 0.1, 0.9, 0.4)
	local settle = env(c, SETTLE, 0.3, 2.3, 0.6)
	local bow = env(c, 17.6, 0.45, 0.35, 0.5, "quadInOut", "quadInOut")
	local hum2 = env(c, 17.9, 0.3, 1.2, 0.4)
	local clapS = env(c, 16.8, 0.15, 0.85, 0.3)

	------------------------------------------------------------------
	-- BODY
	------------------------------------------------------------------
	local bob = 0.6 * wave(t, 4 * F) + 0.2 * wave(t, 9 * F, 0.3)
	local rise = riseAt(c)
	local wiggle = giggleB * sin(TAU * 3 * (c - 7.35)) + 0.6 * giggleA * sin(TAU * 4 * (c - 5.45))
		+ 0.7 * laugh * sin(TAU * 3 * (c - SLAP))
	local by = bob * (1 - 0.7 * busy) + rise - 0.5 * puff + 0.6 * spout + 0.35 * abs(wiggle)
	local bz = L.track(c, { { LAUNCH, 0 }, { 10.9, -1.6, "cubicOut" }, { 13.0, 0, "sineInOut" } })
		+ 0.6 * boop
	local pitchSig = L.track(c, {
		{ BREATH, 0 }, { 9.9, -7, "quadInOut" }, { LAUNCH, -9, "sineInOut" }, { 10.75, 30, "backOut" },
		{ 11.3, 22, "quadInOut" }, { 12.4, 13, "sineInOut" }, { SPIN0, 9, "sineInOut" }, { WIND, 3, "sineInOut" },
		{ 15.5, -12, "quadInOut" }, { SLAP, 11, "quadIn" }, { 16.2, -3, "quadOut" }, { 16.7, 3, "quadInOut" },
		{ 17.4, 0, "quadInOut" }, { 19.6, 0 },
	})
	local pitch = pitchSig + 2.5 * wave(t, 4 * F, 0.25) * idleW - 4 * puff + 1 * spout - 3 * bow
	local yaw = 360 * spinU + (4 * wave(t, 2 * F, 0.25) + 3 * L.noise(t, 2.2, 0.3)) * idleW + 8 * peek
	local roll = 3 * wave(t, 2 * F) * idleW + 9 * wiggle + 6 * peek + 22 * sin(pi * spinU) * spinning
		+ 4 * sin(TAU * 0.9 * (c - LAUNCH)) * env(c, 11.0, 0.3, 1.8, 0.4)
	pose.Body = pa(0, by, bz, pitch, yaw, roll)

	-- belly breathing / deep breath swell
	pose.Belly = CFrame.new(0, -0.15 * wave(t, 4 * F, 0.5) * idleW - 0.75 * breath - 0.35 * puff, 0)

	------------------------------------------------------------------
	-- HEAD + JAW (ONE mouth)
	------------------------------------------------------------------
	local hp = 2 * wave(t, 4 * F, 0.4) * idleW + 3 * hum * sin(TAU * 0.75 * (c - 0.3)) + 9 * peek
		- 4 * puff - 2 * spout + 7 * boop - 4 * boopApp + 10 * breath + 8 * launch + 3 * sing * sin(TAU * 1.2 * c)
		- 6 * wind + 6 * impact - 14 * bow + 4 * settle
	local hy = 5 * L.noise(t, 4.4, 0.25) * idleW + 6 * peek + 3 * wave(t, 3 * F) * idleW
		+ 6 * giggleB * sin(TAU * 1.5 * (c - 7.35))
	local hr = 7 * hum * sin(TAU * 0.75 * (c - 0.3)) - 9 * peek + 4 * wiggle + 8 * sing * sin(TAU * 0.6 * (c - 10.6))
		+ 6 * hum2 * sin(TAU * 0.75 * (c - 17.9))
	pose.Head = pa(0, 0, 0, hp, hy, hr)

	local open = 9 * (1 - puff) * (1 - breath)
		+ 16 * hum * la + 8 * proud + 6 * peek
		+ 5 * giggleA * abs(sin(TAU * 5 * c))
		+ 12 * boop + 6 * giggleB + 6 * giggleB * abs(sin(TAU * 4.5 * c))
		+ 18 * env(c, BREATH, 0.2, 0.05, 0.4)
		+ 22 * launch * (1 - 0.15 * spinning) + 4 * sing * sin(TAU * 6 * c)
		+ 6 * wind
		+ 18 * laugh + 8 * laugh * abs(sin(TAU * 4 * c))
		+ 10 * settle + 10 * hum2 * L.wave01(c, 1.5, 0.5)
	pose.Jaw = ang(-min(open, 38), 0, 0)

	------------------------------------------------------------------
	-- EYES / LIDS / PUPILS / BROWS / CHEEKS
	------------------------------------------------------------------
	local blink = 0
	for _, b in { 2.6, 6.3, 8.75, 19.75 } do
		blink = max(blink, env(c, b, 0.06, 0.06, 0.1))
	end
	local happy = max(proud, env(c, 0.45, 0.1, 0.95, 0.1), env(c, 17.95, 0.1, 1.2, 0.1), env(c, 4.95, 0.1, 0.4, 0.1), env(c, 7.45, 0.1, 0.65, 0.1),
		env(c, SLAP, 0.05, 0.55, 0.1), env(c, SETTLE + 0.1, 0.1, 1.5, 0.1))
	local shut = max(blink, env(c, 9.2, 0.1, 0.9, 0.1))
	local stars = env(c, 10.6, 0.1, 4.1, 0.1) > 0.5 or env(c, 5.45, 0.1, 0.6, 0.1) > 0.5 or env(c, 3.4, 0.1, 0.4, 0.1) > 0.5
	local closed = happy > 0.5 or shut > 0.5
	for _, s in { "R", "L" } do
		ctx.transparency("Lid" .. s, closed and 0 or 1)
		ctx.transparency("Lash" .. s, (shut > 0.5 and happy <= 0.5) and 0 or 1)
		local h = (happy > 0.5) and 0 or 1
		ctx.transparency("HapA" .. s, h)
		ctx.transparency("HapC" .. s, h)
		ctx.transparency("HapD" .. s, h)
		ctx.transparency("StarA" .. s, stars and 0 or 1)
		ctx.transparency("StarB" .. s, stars and 0 or 1)
	end
	local pop = max(boop, 0.8 * launch * (1 - spinning), 0.5 * spout)
	L.both(pose, "Eye", pa(0, 0.1 * pop, -0.35 * pop, 0, 0, 3 * wiggle))
	L.both(pose, "Lid", CFrame.new(0, -0.05 * happy, 0))

	-- pupils: gentle glances, dreamy up while humming, look back at the city,
	-- cross-eyed at the boop, up at the beam
	local dart = clamp(3 * sin(TAU * 3 * F * t), -1, 1) * 0.28
	local px = (dart + 0.06 * L.noise(t, 5.1, 2)) * idleW + 0.42 * peek * (1 - proud)
	local py = (-0.05 + 0.05 * L.noise(t, 8.2, 2)) * idleW + 0.3 * hum + 0.38 * peek * (1 - proud) + 0.4 * beam
	local cross = max(boopApp, boop) * (1 - giggleB)
	px = px * (1 - cross) - 0.5 * cross
	py = py * (1 - cross) - 0.42 * cross
	px += 0.3 * sin(TAU * 1.0 * (c - SPIN0)) * spinning
	L.both(pose, "Pupil", CFrame.new(px, py, 0))

	local surprise = max(boop * (1 - giggleB), 0.8 * launch * (1 - spinning))
	local browUp = 0.15 * wave(t, 4 * F, 0.1) * idleW + 0.6 * surprise + 0.3 * hum + 0.35 * proud
		- 0.35 * breath - 0.2 * puff + 0.3 * settle + 0.25 * giggleB
	local browRoll = -6 * hum - 10 * surprise + 10 * breath + 8 * puff - 6 * settle + 3 * wave(t, 4 * F, 0.3) * idleW
	L.both(pose, "Brow", pa(0, browUp, 0, 0, 0, browRoll))

	local cheekOut = 0.7 * puff + 0.6 * breath + 0.12 * L.wave01(t, 4 * F) * idleW + 0.25 * max(giggleB, laugh, proud)
	L.both(pose, "Cheek", pa(0.45 * cheekOut, 0.25 * max(proud, giggleB, laugh, settle), -0.45 * cheekOut, 0, 0, 0))
	local blush = max(proud, giggleB, settle, laugh, puff) > 0.4
	local lines = max(giggleB, env(c, 3.9, 0.1, 0.5, 0.1), env(c, 16.9, 0.1, 1.2, 0.1)) > 0.4
	for _, s in { "R", "L" } do
		ctx.transparency("BlushBig" .. s, blush and 0 or 1)
		for k = 1, 3 do
			ctx.transparency("BlushLine" .. s .. k, lines and 0 or 1)
		end
	end

	------------------------------------------------------------------
	-- FLIPPERS: slow strokes, pat the city, claps, flare, dance, fold
	------------------------------------------------------------------
	local stroke = wave(t, 4 * F)
	local clap = max(clapI, clapS)
	local clapBeat = clap * abs(sin(TAU * 2.2 * (c - (clapI > clapS and 7.5 or 16.8))))
	local function fin(isRight)
		local z = 12 * stroke * idleW + 70 * launch * (1 - spinning) + 45 * spinning - 8 * breath + 20 * clap
			+ 10 * wiggle + 15 * spout
		local y = 4 * wave(t, 4 * F, 0.25) * idleW - 28 * breath + 38 * clapBeat + 10 * clap - 10 * launch
		local x = 10 * wave(t, 4 * F, 0.3) * idleW + 8 * launch + 20 * spinning * sin(TAU * 1.0 * (c - SPIN0))
		local tz = 15 * wave(t, 4 * F, -0.15) * idleW + 25 * launch * sin(TAU * 1.0 * (c - LAUNCH)) - 15 * breath + 25 * clapBeat
		local lift = 0
		local hz = 0.5 * tz
		if isRight then
			-- the right flipper slides up her flank, stands up beside the city and
			-- flops its hand over the wall: pat, pat, pat
			local k = 1 - pat
			x, y, z, tz = x * k + PAT_X * pat, y * k + PAT_Y * pat, z * k + PAT_Z * pat, tz * k + PAT_T * pat
			hz = hz * k + pat * (PAT_H - PAT_LIFT * tapLift)
			lift = 2.6 * pat + 0.5 * tapLift
			z += 12 * tapLift * pat
		else
			-- the other flipper lifts a little as she leans, for balance
			z += 16 * peek
		end
		return CFrame.new(0, lift, 0) * ang(x, y, z), ang(0, 6 * stroke * idleW + 15 * clapBeat, tz + 10 * impact), ang(0, 0, hz)
	end
	local fR, tR, hR = fin(true)
	local fL, tL, hL = fin(false)
	pose.FinR, pose.FinL = fR, L.mirror(fL)
	pose.FinTipR, pose.FinTipL = tR, L.mirror(tL)
	pose.FinHandR, pose.FinHandL = hR, L.mirror(hL)

	------------------------------------------------------------------
	-- TAIL: whale strokes (vertical) + signature curls / slap
	------------------------------------------------------------------
	local function curl(cc)
		return L.track(cc, {
			{ BREATH, 0 }, { 9.9, -16, "quadInOut" }, { LAUNCH, -20, "sineInOut" }, { 10.6, 13, "quadIn" },
			{ 10.95, -9, "quadOut" }, { 11.4, 4, "quadInOut" }, { 12.3, 0, "sineInOut" },
			{ WIND, 0 }, { 15.5, -32, "quadInOut" }, { SLAP, 21, "expoIn" }, { 16.0, 15, "quadOut" },
			{ 16.3, -9, "quadInOut" }, { 16.7, 5, "quadInOut" }, { 17.2, -2, "quadInOut" }, { 17.8, 0, "quadInOut" },
		})
	end
	local W = { 0.75, 0.95, 1.05, 1.2 }
	local NAMES = { "Tail1", "Tail2", "Tail3", "Fluke" }
	for i = 1, 4 do
		local swim = (6 + 3 * i) * wave(t, 4 * F, -0.12 * i) * (1 - 0.6 * busy)
		local cu = curl(c - 0.05 * (i - 1)) * W[i]
		local yawT = (3 + i) * wave(t, 2 * F, -0.1 * i) * idleW + (10 + 4 * i) * spinning * sin(TAU * 0.8 * (c - SPIN0 - 0.1 * i))
			+ 4 * i * wiggle * 0.5 + 6 * i * peek * 0.4
		pose[NAMES[i]] = ang(swim + cu, yawT, 0)
	end

	------------------------------------------------------------------
	-- CITY: jolts, tower rise, spire, halo, beam, fireworks, water
	------------------------------------------------------------------
	local cityJolt = -0.35 * impact + 0.25 * env(c, SLAP + 0.15, 0.15, 0.05, 0.5, "quadOut", "bounceOut")
	cityJolt += -0.3 * tapHit
	pose.City = pa(0, cityJolt + 0.12 * env(c, TOWERS, 0.1, 1.0, 0.4) * sin(TAU * 9 * c), 0,
		-1.5 * impact, 0, 1.5 * wiggle * 0.3 - 1.2 * tapHit)
	for i = 1, 4 do
		local s = TOWERS + 0.14 * (i - 1)
		local up = L.track(c, { { s, 0 }, { s + 0.4, 3.2, "backOut" }, { 18.5 + 0.1 * i, 3.0 }, { 19.3 + 0.1 * i, 0, "cubicInOut" } })
		local wob = env(c, s, 0.4, 2.0, 0.5) * sin(TAU * (2 * c + i * 0.25))
		local spinT = L.track(c, { { s + 0.2, 0 }, { s + 0.9, 360, "cubicOut" } })
		local hop = 0.7 * env(c, 3.36 + 0.05 * i, 0.08, 0.02, 0.25, "quadOut", "bounceOut")
			+ 0.6 * env(c, 3.71 + 0.05 * i, 0.08, 0.02, 0.25, "quadOut", "bounceOut")
			+ 0.8 * env(c, 4.06 + 0.05 * i, 0.08, 0.02, 0.3, "quadOut", "bounceOut")
		pose["Tower" .. i] = pa(0, up + hop + 0.05 * wave(t, 4 * F, i * 0.2), 0, 3 * wob, spinT, 3 * wob)
	end
	local spireUp = env(c, BEAM - 0.4, 0.4, 2.3, 0.5, "backOut", "quadInOut")
	pose.Spire = pa(0, 0.9 * spireUp + 0.1 * wave(t, 4 * F), 0, 0, 90 * spireUp + 720 * L.track(c, { { BEAM, 0 }, { 14.1, 1, "sineInOut" } }), 0)
	pose.Halo = ang(0, 220 * c, 0) * CFrame.new(0, 0, 0)
	local rayT = haloOn > 0.15 and (0.1 + 0.2 * (1 - haloOn)) or 1
	for i = 1, 8 do
		ctx.transparency("Ray" .. i, rayT)
	end
	local flick = 0.08 * sin(TAU * 13 * c)
	ctx.transparency("BeamCore", beam > 0.1 and (0.1 + 0.6 * (1 - beam) + flick) or 1)
	ctx.transparency("BeamGlow", beam > 0.1 and (0.55 + 0.35 * (1 - beam) + flick) or 1)
	ctx.enable("SpireCharge", c > 10.8 and c < 13.9)
	ctx.light("SpireLight", min(2, 0.4 + 1.6 * max(beam, 0.6 * spireUp)))
	ctx.light("TempleLight", min(1.5, 0.5 + 0.3 * wave(t, 8 * F) + 0.9 * env(c, TOWERS, 0.2, 1.4, 0.6)))

	-- firework chunks: launched one after another, burst at the top
	for k = 1, 6 do
		local s = TOWERS + 0.15 + 0.16 * (k - 1)
		local u = win(c, s, 1.0)
		local a = TAU * (k / 6) + 0.4
		if u then
			local r = 3.2 * u
			pose["Chunk" .. k] = pa(r * cos(a), 15 * u - 6 * u * u, r * sin(a), 300 * u, 200 * u, 0)
			ctx.transparency("ChunkP" .. k, u > 0.85 and 0.6 or 0)
		else
			pose["Chunk" .. k] = CFrame.new()
			ctx.transparency("ChunkP" .. k, 1)
		end
	end

	-- waterfalls + seaweed
	pose.FallFlow = CFrame.new(0, -3.2 * L.saw(t, 20 * F), 0)
	for i = 1, 3 do
		pose["Weed" .. i] = ang(10 * wave(t, 6 * F, i * 0.3) - 12 * impact, 0, 12 * wave(t, 4 * F, i * 0.21) + 8 * wiggle)
	end

	------------------------------------------------------------------
	-- blowhole fountain
	------------------------------------------------------------------
	-- the column shoots up out of the blowhole (it starts hidden inside the head)
	local h = spout
	local gush = 0.35 * sin(TAU * 5 * c) * h
	pose.Spout = pa(0.12 * sin(TAU * 4 * c) * h, -8.6 * (1 - h) + gush, 0, 0, 90 * c, 0)
	local sv = spout > 0.04
	ctx.transparency("SpoutA", sv and 0.05 or 1)
	ctx.transparency("SpoutB", (sv and h > 0.25) and 0.1 or 1)
	ctx.transparency("SpoutS", (sv and h > 0.25) and 0.25 or 1)
	ctx.transparency("SpoutC", (sv and h > 0.45) and 0 or 1)
	ctx.transparency("SpoutD", (sv and h > 0.7) and 0 or 1)
	ctx.transparency("SpoutE", (sv and h > 0.7) and 0 or 1)
	-- droplets rain down around the crown
	local du = win(c, 5.5, 1.0)
	if du then
		pose.SpoutDrops = pa(0, 1.2 * du - 7 * du * du + 8.6 * (1 - h), 0, 0, 160 * du, 0)
	else
		pose.SpoutDrops = CFrame.new()
	end
	for k = 1, 4 do
		ctx.transparency("Drop" .. k, (du and du < 0.9) and (du > 0.7 and 0.4 or 0) or 1)
	end

	------------------------------------------------------------------
	-- music notes + hearts (popping props)
	------------------------------------------------------------------
	for k = 1, 3 do
		local cfk, tr = CFrame.new(), 1
		for _, list in NOTES do
			local s = list[k]
			local u = s and win(c, s, 1.5)
			if u then
				local side = (k == 2) and -1 or 1
				cfk = pa(side * (3.2 + 5.0 * u) + 0.5 * sin(TAU * 1.5 * u), 0.2 + 5.5 * u, -0.6 - 1.0 * u, 0, 0, 18 * sin(TAU * 2 * u))
				tr = u < 0.08 and 0.5 or (u > 0.8 and 0.5 or 0)
			end
		end
		pose["Note" .. k] = cfk
		ctx.transparency("NoteS" .. k, tr)
		ctx.transparency("NoteH" .. k, tr)
		ctx.transparency("NoteF" .. k, tr)
	end
	for k = 1, 3 do
		local cfk, tr = CFrame.new(), 1
		for _, s in HEARTS[k] do
			local u = win(c, s, 1.7)
			if u then
				local pop2 = L.ease.backOut(min(1, u * 5))
				cfk = pa(0.6 * sin(TAU * 1.2 * u + k), -1.2 + 1.2 * pop2 + 4.5 * u, 0, 0, 25 * sin(TAU * u), 12 * sin(TAU * 1.5 * u))
				tr = u > 0.85 and 0.5 or 0
			end
		end
		pose["Heart" .. k] = cfk
		for _, n in { "A", "B", "C", "D" } do
			ctx.transparency("Heart" .. n .. k, tr)
		end
	end

	------------------------------------------------------------------
	-- splash crown under the flukes
	------------------------------------------------------------------
	local su = win(c, SLAP, 1.1)
	if su then
		pose.Splash = CFrame.new(0, 2.6 * L.ease.cubicOut(min(1, su * 1.6)), 0)
	else
		pose.Splash = CFrame.new()
	end
	for i = 1, 8 do
		local trs = 1
		if su then
			local d = (i % 2) * 0.06
			trs = (su > d) and (su < 0.55 and 0.15 or (su < 0.8 and 0.45 or 0.75)) or 1
		end
		ctx.transparency("SplashCol" .. i, trs)
	end

	------------------------------------------------------------------
	-- tiny city fish (body space)
	------------------------------------------------------------------
	for k = 1, 3 do
		local p = fishPos(k, t, c)
		local p2 = fishPos(k, t + 0.05, c + 0.05)
		local d = p2 - p
		local hd = Vector3.new(d.X, 0, d.Z)
		local yawF
		if k == 1 then
			local w = env(c, 6.3, 0.7, 0.75, 0.9, "cubicInOut", "cubicInOut")
			if hd.Magnitude < 1e-4 then
				hd = Vector3.new(0, 0, -1)
			end
			hd = hd.Unit:Lerp(Vector3.new(0, 0, 1), w)
		end
		if hd.Magnitude < 1e-4 then
			hd = Vector3.new(0, 0, -1)
		end
		yawF = math.deg(math.atan2(-hd.X, -hd.Z))
		local rest = FISH[k][1]
		pose["Fish" .. k] = pa(p.X - rest.X, p.Y - rest.Y, p.Z - rest.Z, 0, yawF + 15 * sin(TAU * 3 * c + k), 0)
	end

	------------------------------------------------------------------
	-- orbiting cubes (pushed out during the signature)
	------------------------------------------------------------------
	local flung = env(c, LAUNCH, 0.5, 4.5, 1.5, "backOut", "sineInOut")
	for i, o in ORBS do
		local th = TAU * (F * t + o[2])
		local r = o[3] + 4 * flung
		-- cubes swing up and over when they pass in front of her face
		local front = max(0, -sin(th)) ^ 2
		local target = Vector3.new(r * cos(th), o[4] + 1.0 * wave(t, 3 * F, i * 0.2) + 3 * flung + 4 * front, 1.7 * r * sin(th))
		local d = target - o[1]
		local s = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(d.X, d.Y, d.Z, 360 * 2 * F * t * s + 30 * i, 360 * 3 * F * t, 25 * i)
	end

	------------------------------------------------------------------
	-- effects on the beats
	------------------------------------------------------------------
	for _, h in { 3.3, 3.65, 4.0 } do
		if ctx.crossed(h) then
			ctx.emit("CitySparkle", 14)
		end
	end
	if ctx.crossed(5.35) then
		ctx.emit("SpoutSpray", 35)
	end
	if ctx.crossed(5.8) then
		ctx.emit("SpoutSpray", 20)
		ctx.emit("CitySparkle", 12)
	end
	if ctx.crossed(7.02) then
		ctx.emit("CitySparkle", 8)
	end
	if ctx.crossed(LAUNCH + 0.25) then
		ctx.emit("SplashMist", 25)
		ctx.emit("SplashBurst", 30)
		ctx.emit("AmbientBubbles", 30)
	end
	if ctx.crossed(BEAM + 0.05) then
		ctx.emit("BeamBurst", 60)
	end
	if ctx.crossed(BEAM + 1.2) then
		ctx.emit("BeamBurst", 30)
	end
	for _, tt in { 13.0, 13.25, 13.5, 13.75 } do
		if ctx.crossed(tt) then
			ctx.emit("Fireworks", 28)
		end
	end
	if ctx.crossed(SPIN1 - 0.6) then
		ctx.emit("CitySparkle", 15)
	end
	if ctx.crossed(SLAP) then
		ctx.emit("SplashBurst", 90)
		ctx.emit("SplashMist", 40)
	end
	if ctx.crossed(SLAP + 0.3) then
		ctx.emit("SplashBurst", 35)
	end
	if ctx.crossed(17.0) then
		ctx.emit("CitySparkle", 15)
	end
end

return M
