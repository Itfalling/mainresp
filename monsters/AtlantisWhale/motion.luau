--!nocheck
-- Atlantis Sky Whale motion. Personality: GENTLE, KIND, MOTHERLY GUARDIAN.
-- Always: slow vertical whale stroke down the body chain, hover bob, flipper
-- paddling, waterfalls flowing, seaweed swaying, spire crystal turning,
-- cubes tumbling, a little clownfish friend circling her, blinks.
-- Idle gags:
--   0.15  HUMMING: eyes half closed, head sways, "mmm" mouth, music notes
--   2.5   GLANCES BACK at her city (head + pupils), raises her right flipper
--         and PATS it three times (city hops, sparkles), proud little smile
--   4.7   BLOWHOLE FOUNTAIN: squash, whoosh! water column + droplets
--   12.4  FISH BOOP: the clownfish swims up and boops her nose (13.05): she
--         goes cross-eyed, jolts "oh!", giggles, a heart pops up
--   14.3  HAPPY WIGGLE: rolls side to side, tail wags, flippers flap
-- Signature "RISING ATLANTIS" (6.0 - 12.0):
--   6.0   DEEP BREATH: sinks, nose lifts, eyes close, flippers spread back
--   6.9   RISE / BREACH: surges ~6.5 studs up nose-first, flippers flare
--   7.4   SPIRE BEAM: beam of light + a halo of golden rays around the spire
--   7.8   the four CITY TOWERS RISE one by one with golden FIREWORKS
--   8.6   PIROUETTE: a full 360 turn in the air, flippers out like a dancer
--   9.5   TAIL SLAP: tail lifts, nose dips ... 10.05 SLAM: splash crown,
--         squash, beam snaps off
--   10.3  PROUD HAPPY SETTLE: glides down, happy squint, big smile, claps,
--         towers sink back (11.0)
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 16

local sin, cos, pi, max, min, abs, atan2 = math.sin, math.cos, math.pi, math.max, math.min, math.abs, math.atan2
local TAU = 2 * pi

local CHAIN = { "Head", "Body", "Body2", "Tail1", "Tail2", "Tail3", "Fluke" }
local CENTER = 2
local SWIM = 0.375 -- 6 strokes per loop
local AMP = { 2.5, 2, 4, 7, 11, 15, 20 } -- vertical stroke, head -> flukes
local BREACH_BEND = { -6, 0, -5, -9, -11, -11, -9 } -- tail curls up as she rises
local SLAP_BEND = { 0, 0, 7, 13, 17, 21, 25 } -- + = tail down (slam), - = lift
local SPIN_LAG = { 0, 0, 5, 10, 15, 20, 26 } -- tail trails in the pirouette
local WIG = { 6, 0, 6, 10, 14, 18, 22 } -- happy wag (yaw)

local BLINKS = { 4.45, 5.95, 12.15, 15.85 }
local SLAM = 10.05
local BOOP = 13.05

local BY = {
	{ 6.0, 0 }, { 6.85, -1.2, "sineInOut" }, { 7.5, 6.5, "backOut" }, { 8.6, 6.0, "sineInOut" },
	{ 9.5, 5.0, "sineInOut" }, { 9.9, 5.4, "quadOut" }, { SLAM, 3.2, "expoIn" }, { 10.3, 3.0 },
	{ 11.0, 0.6, "cubicInOut" }, { 11.45, -0.5, "quadIn" }, { 11.9, 0, "backOut" },
}
local PITCH = {
	{ 6.0, 0 }, { 6.8, 8, "sineInOut" }, { 6.95, 2, "quadIn" }, { 7.5, 26, "backOut" },
	{ 8.3, 20 }, { 8.7, 4, "cubicInOut" }, { 9.5, 4 }, { 9.9, -10, "cubicOut" },
	{ SLAM, 10, "expoIn" }, { 10.3, 2, "quadOut" }, { 10.8, -4, "sineInOut" }, { 11.5, 0, "sineInOut" },
}
local SLAPK = {
	{ 9.5, 0 }, { 9.9, -1, "cubicOut" }, { SLAM, 1, "expoIn" }, { 10.2, 1 },
	{ 10.5, -0.3, "quadOut" }, { 10.8, 0.15, "sineInOut" }, { 11.1, 0, "sineInOut" },
}

-- firework chunk directions (city frame)
local CHUNK_DIR = {
	{ 1.0, 1.2, -0.4 }, { -1.0, 1.3, -0.3 }, { 0.5, 1.6, 0.8 }, { -0.6, 1.5, 0.7 },
	{ 1.3, 0.8, 0.5 }, { -1.3, 0.9, 0.4 }, { 0.3, 1.8, -0.9 }, { -0.4, 1.4, -1.1 },
}
local FO = Vector3.new(0, 16.5, -12.0) -- fish rest pivot
local NOTES = { { 0.35, 1.85 }, { 0.95, 2.45 } }

local function bodyBob(t, special)
	return 0.7 * wave(t, 0.25) * (1 - 0.6 * special)
end

-- the little fish's orbit around the whale (2 laps per loop)
local function orbit(c)
	local ph = TAU * 2 * c / M.Cycle
	return Vector3.new(11 * sin(ph), 17 + 1.2 * sin(2 * ph), 3 - 13 * cos(ph))
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes
	------------------------------------------------------------------
	local hum = L.env(c, 0.15, 0.35, 1.5, 0.4)
	local glance = L.env(c, 2.5, 0.35, 1.25, 0.4, "backOut", "cubicInOut")
	local patArm = L.env(c, 2.75, 0.35, 0.95, 0.4, "backOut", "cubicInOut")
	local patBeat = 0
	for _, p in { 3.15, 3.45, 3.75 } do
		patBeat += L.env(c, p, 0.08, 0.02, 0.15, "quadIn", "quadOut")
	end
	local fAnt = L.env(c, 4.7, 0.25, 0.05, 0.12, "quadOut", "expoIn")
	local fSpout = L.env(c, 5.0, 0.12, 0.45, 0.35, "backOut", "quadIn")
	local breath = L.env(c, 6.0, 0.8, 0.1, 0.15, "sineInOut", "expoIn")
	local breach = L.env(c, 6.9, 0.5, 1.4, 0.5, "backOut", "cubicInOut")
	local beam = L.env(c, 7.4, 0.15, 2.5, 0.2)
	local spinE = L.env(c, 8.6, 0.2, 0.55, 0.25)
	local slapK = L.track(c, SLAPK)
	local lift = max(0, -slapK)
	local squash = L.env(c, SLAM, 0.04, 0.05, 0.55, "linear", "elasticOut")
	local proud = L.env(c, 10.3, 0.3, 1.5, 0.6, "backOut", "cubicInOut")
	local fishIn = L.env(c, 12.4, 0.6, 0.35, 0.7, "sineInOut", "sineInOut")
	local crossEye = L.env(c, 12.65, 0.3, 0.6, 0.3)
	local jolt = L.env(c, BOOP, 0.06, 0.12, 0.45, "expoOut", "cubicInOut")
	local giggle = L.env(c, 13.2, 0.15, 0.75, 0.3)
	local wiggle = L.env(c, 14.3, 0.25, 0.85, 0.45)
	local special = L.env(c, 5.95, 0.15, 6.0, 0.4)
	local idleW = 1 - special
	local swimW = 1 - 0.6 * max(breath, breach, spinE) - 0.5 * proud - 0.4 * hum

	local happyEyes = max(0.6 * proud, 0.55 * wiggle, 0.5 * giggle, 0.55 * spinE, 0.35 * glance * (1 - patBeat))

	------------------------------------------------------------------
	-- body chain: absolute pitch / yaw per segment
	------------------------------------------------------------------
	local wigPh = 2.5 * (c - 14.3)
	local yaw, pitch = {}, {}
	for i = 1, #CHAIN do
		local k = i - 1
		pitch[i] = AMP[i] * sin(TAU * (SWIM * t - 0.11 * k)) * swimW
			+ breach * BREACH_BEND[i] + slapK * SLAP_BEND[i]
		yaw[i] = 2 * sin(TAU * (0.125 * t - 0.08 * k)) * idleW
			- spinE * SPIN_LAG[i]
			+ wiggle * WIG[i] * sin(TAU * (wigPh - 0.12 * k))
	end
	-- head: humming sway, glance back, breach joy, boop jolt, giggle
	yaw[1] += 6 * hum * sin(TAU * 0.9 * (c - 0.15)) - 26 * glance + 7 * giggle * sin(TAU * 3 * (c - 13.2))
	pitch[1] += 3 * wave(t, 0.5, 0.1) * idleW + 7 * glance - 5 * patBeat + 10 * breach - 6 * breath
		+ 12 * jolt - 4 * fAnt + 8 * fSpout + 6 * proud - 6 * lift + 4 * hum * wave(c, 0.9, 0.25)

	------------------------------------------------------------------
	-- root (Body)
	------------------------------------------------------------------
	local bob = bodyBob(t, special)
	local by = bob + L.track(c, BY) - 1.0 * fAnt + 0.6 * fSpout - 1.5 * squash
		+ 0.35 * L.bounce(c, 2.5) * wiggle + 0.25 * patBeat
	local spin = L.track(c, { { 8.6, 0 }, { 9.5, 360, "cubicInOut" } })
	if c > 9.5 then spin = 0 end
	local bp = pitch[CENTER] + L.track(c, PITCH) - 5 * fAnt + 4 * fSpout + 3 * wave(t, 0.25, 0.2) * idleW
		- 3 * jolt
	local byaw = yaw[CENTER] + spin + 6 * wiggle * sin(TAU * 1.25 * (c - 14.3))
	local roll = 3 * wave(t, 0.25, 0.1) * idleW + 4 * hum * sin(TAU * 0.9 * (c - 0.15) + 0.6)
		- 6 * glance + 8 * wiggle * sin(TAU * wigPh) + 5 * giggle * sin(TAU * 3 * (c - 13.25))
		+ 6 * proud * sin(TAU * 1.5 * (c - 10.3))
	pose.Body = pa(0.3 * wave(t, 0.125), by, 0.5 * jolt, bp, byaw, roll)

	pose.Head = pa(0, 0, 0.35 * jolt, pitch[1] - pitch[2], yaw[1] - yaw[2], 4 * hum * sin(TAU * 0.9 * (c - 0.3)) - 7 * glance)
	for i = CENTER + 1, #CHAIN do
		pose[CHAIN[i]] = ang(pitch[i] - pitch[i - 1], yaw[i] - yaw[i - 1], 0)
	end

	------------------------------------------------------------------
	-- face
	------------------------------------------------------------------
	-- jaw: "mmm" hum, "whee!" on the breach, proud smile, "oh!", giggles
	local jawX = -(4 + 6 * L.wave01(c, 2.2)) * hum
		- 16 * breach - 18 * proud - 14 * jolt
		- (8 + 10 * L.wave01(c, 5.0)) * giggle - 10 * wiggle - 6 * glance * (1 - patArm) - 8 * fSpout
	pose.Jaw = ang(min(0, jawX), 0, 0)

	-- lids: content half-close while humming, closed for the breath,
	-- happy squints, blinks; wide open on the boop
	local close = max(0.45 * hum, breath, happyEyes)
	for _, b in BLINKS do
		close = max(close, L.env(c, b, 0.06, 0.06, 0.1))
	end
	close = max(close, L.env(c, BOOP + 0.25, 0.05, 0.05, 0.1)) -- blink after the boop
	close = close * (1 - jolt)
	pose.LidR = CFrame.new(0, -3.05 * close, 0)
	pose.LidL = CFrame.new(0, -3.05 * close, 0)
	local lidTr = close > 0.04 and 0 or 1
	for _, s in { "R", "L" } do
		ctx.transparency("Eyelid" .. s, lidTr)
		ctx.transparency("Lash" .. s, lidTr)
	end

	-- pupils: idle drift, glance back to the right, cross-eyed at the fish
	local px = 0.08 * L.noise(t, 1.7, 0.3) + 0.3 * glance
	local py = 0.06 * L.noise(t, 4.2, 0.3) + 0.25 * glance + 0.15 * breach
	pose.PupilR = CFrame.new(px - 0.32 * crossEye, py - 0.15 * crossEye, 0)
	pose.PupilL = CFrame.new(px + 0.32 * crossEye, py - 0.15 * crossEye, 0)

	local browUp = 0.45 * jolt + 0.3 * breath + 0.25 * breach + 0.2 * proud + 0.15 * hum + 0.2 * crossEye
	local browZ = -6 * breath + 8 * jolt + 4 * wave(t, 0.5) * idleW - 5 * proud + 4 * glance
	L.both(pose, "Brow", pa(0, browUp, 0, 0, 0, browZ))

	------------------------------------------------------------------
	-- flippers (right side; model axes): +Z raise / flare, +Y sweep forward
	------------------------------------------------------------------
	local pad = wave(t, SWIM)
	local idleZ = 10 * pad * swimW
	local idleY = 8 * wave(t, SWIM, 0.25) * swimW
	local clap = proud * L.wave01(c, 3.0, 0.75)
	local flap = wiggle * (18 + 18 * sin(TAU * 3 * (c - 14.3))) + giggle * (6 + 10 * sin(TAU * 4 * (c - 13.2)))
	local commonZ = idleZ + 25 * breath + 55 * breach + 40 * spinE - 25 * lift + 30 * proud + flap
	local commonY = idleY - 35 * breath + 10 * breach + 45 * proud + 30 * clap
	local tipZ = 14 * wave(t, SWIM, -0.15) * swimW + 20 * breach + 15 * spinE + 0.6 * flap
	-- right flipper also does the PAT
	local rZ = commonZ + 125 * patArm - 10 * patBeat
	local rY = commonY - 30 * patArm
	pose.FinR = ang(0, rY, rZ)
	pose.FinL = L.mirror(ang(0, commonY, commonZ))
	pose.FinTipR = ang(0, 0, tipZ - 30 * patArm - 22 * patBeat)
	pose.FinTipL = L.mirror(ang(0, 0, tipZ))

	------------------------------------------------------------------
	-- city: hops on the pats, rattles on the slam; towers rise
	------------------------------------------------------------------
	pose.City = pa(0, 0.25 * patBeat + 0.3 * squash, 0, 2.5 * squash * sin(TAU * 6 * (c - SLAM)), 0, 2 * squash * sin(TAU * 5 * (c - SLAM)))
	for i = 1, 4 do
		local t0 = 7.8 + 0.15 * (i - 1)
		local t1 = 11.0 + 0.12 * (i - 1)
		local rise = L.track(c, { { t0, 0 }, { t0 + 0.35, 1, "backOut" }, { t1, 1 }, { t1 + 0.6, 0, "cubicInOut" } })
		local wob = 0.06 * sin(TAU * (0.5 * t + 0.25 * i))
		pose["Tower" .. i] = pa(0, 2.2 * rise + wob, 0, 0, 0, 3 * squash * sin(TAU * 4 * (c - SLAM) + i))
	end
	pose.Spire = pa(0, 0.12 * wave(t, 0.5) + 0.5 * beam, 0, 0, (40 * t) % 360, 0)
	pose.Halo = ang(0, -((40 * t) % 360), 90 * c)

	-- spire beam + halo of rays
	local beamOn = beam > 0.05
	ctx.transparency("Beam", beamOn and (0.3 + 0.12 * L.wave01(c, 6.0) + 0.6 * (1 - beam)) or 1)
	for i = 1, 8 do
		local on = c > 7.45 + 0.05 * i and c < 10.1
		ctx.transparency("Ray" .. i, on and (0.15 + 0.85 * L.remap(c, 9.9, 10.1)) or 1)
	end

	-- firework chunks
	local fp = L.remap(c, 7.9, 8.8)
	local chunkOn = c > 7.9 and c < 8.8
	local fe = L.ease.cubicOut(fp)
	for k = 1, 8 do
		local d = CHUNK_DIR[k]
		local r = 7 * fe
		local s = 480 * fp * (k % 2 == 0 and -1 or 1)
		pose["Chunk" .. k] = chunkOn and pa(d[1] * r, d[2] * r - 6 * fp * fp, d[3] * r, s, s * 0.7, 40 * k) or CFrame.new()
		ctx.transparency("ChunkPart" .. k, chunkOn and (fp > 0.7 and (fp - 0.7) / 0.3 or 0) or 1)
	end

	------------------------------------------------------------------
	-- blowhole fountain
	------------------------------------------------------------------
	local spOn = fSpout > 0.03
	pose.Spout = pa(0, -3.0 * (1 - fSpout), 0, 0, 30 * c, 4 * sin(TAU * 3 * c))
	for k = 1, 6 do
		ctx.transparency("Spout" .. k, spOn and (k >= 5 and 0.15 or 0.3) or 1)
	end

	------------------------------------------------------------------
	-- splash crown on the tail slam
	------------------------------------------------------------------
	local sp = L.remap(c, SLAM, SLAM + 0.85)
	local splashOn = c > SLAM and c < SLAM + 0.85
	pose.Splash = pa(0, -1.2 + 2.4 * L.ease.cubicOut(sp), 0, 0, 25 * sp, 0)
	for i = 0, 9 do
		ctx.transparency("SplashP" .. i, splashOn and (0.2 + 0.8 * max(0, (sp - 0.45) / 0.55)) or 1)
	end

	------------------------------------------------------------------
	-- music notes while humming
	------------------------------------------------------------------
	for k, n in NOTES do
		local p = L.remap(c, n[1], n[2])
		local on = c > n[1] and c < n[2]
		local dir = k == 1 and 1 or -1
		pose["Note" .. k] = pa(dir * 0.8 * sin(TAU * 1.2 * p), -2.2 + 4.2 * p, -0.3 * p, 0, 0, dir * 18 * sin(TAU * 1.5 * p))
		local tr = on and max(0, 1 - p / 0.12, (p - 0.75) / 0.25) or 1
		for j = 1, 3 do
			ctx.transparency("Note" .. k .. "f" .. j, tr)
			ctx.transparency("Note" .. k .. "b" .. j, tr)
		end
	end

	------------------------------------------------------------------
	-- the clownfish friend: circles her, swims in to BOOP her nose
	------------------------------------------------------------------
	local o1 = orbit(c)
	local o2 = orbit(c + 0.05)
	local oyaw = math.deg(atan2(-(o2.X - o1.X), -(o2.Z - o1.Z)))
	local noseP = Vector3.new(0, 8.8 + bob, -10.4)
	local fpos = o1 + (noseP - o1) * fishIn + Vector3.new(0, 0.4 * jolt, -1.6 * jolt)
	local dYaw = ((180 - oyaw + 180) % 360) - 180
	local fyaw = oyaw + dYaw * fishIn + 18 * sin(TAU * 4 * t)
	local fo = fpos - FO
	pose.Fish = pa(fo.X, fo.Y + 0.2 * sin(TAU * 1.5 * t), fo.Z, 0, fyaw, 0)

	-- heart pops after the boop
	local hpg = L.remap(c, 13.25, 14.4)
	local heartOn = c > 13.25 and c < 14.4
	local hpop = L.ease.backOut(L.remap(c, 13.25, 13.5))
	pose.Heart = pa(0.5 * sin(TAU * hpg), -1.0 + 1.0 * hpop + 2.2 * hpg, 0, 0, 0, 12 * sin(TAU * 2 * hpg))
	local htr = heartOn and max(0, (hpg - 0.7) / 0.3) or 1
	for j = 1, 4 do
		ctx.transparency("HeartP" .. j, htr)
	end

	------------------------------------------------------------------
	-- secondary: waterfalls, seaweed, floating cubes
	------------------------------------------------------------------
	local flowY = -2.3 * L.saw(t, 0.8)
	pose.FlowR = CFrame.new(0, flowY, 0)
	pose.FlowL = CFrame.new(0, flowY, 0)
	for i = 1, 2 do
		local w = 10 * sin(TAU * (0.6 * t + 0.3 * i)) + 14 * breach + 18 * squash * sin(TAU * 3 * (c - SLAM))
		pose["Weed" .. i .. "a"] = ang(w * 0.5, 0, 8 * sin(TAU * (0.4 * t + 0.2 * i)))
		pose["Weed" .. i .. "b"] = ang(w, 0, 12 * sin(TAU * (0.4 * t + 0.2 * i - 0.15)))
	end
	for i = 1, 6 do
		local ph = i * 0.17
		local dir = i % 2 == 0 and -1 or 1
		local out = 2.0 * spinE + 1.5 * squash + 1.0 * breach
		local dx = 0.8 * wave(t, 0.2, ph) + out * dir
		local dy = 1.0 * wave(t, 0.4, ph + 0.3) + 2.5 * breach
		local dz = 0.8 * wave(t, 0.2, ph + 0.25)
		pose["Orb" .. i] = pa(dx, dy, dz, 60 * t * dir + 30 * i, 90 * t, 35 + 20 * i)
	end

	------------------------------------------------------------------
	-- lights + bursts on the beats
	------------------------------------------------------------------
	local fwFlash = 0
	for i = 0, 3 do
		fwFlash = max(fwFlash, L.env(c, 7.85 + 0.15 * i, 0.04, 0.05, 0.25))
	end
	ctx.light("SpireLight", min(1.5, 0.5 + 0.9 * beam + 0.3 * breath))
	ctx.light("FireworkLight", min(1.5, 1.3 * fwFlash + 0.8 * L.env(c, 10.4, 0.05, 0.1, 0.4)))

	for _, p in { 3.17, 3.47, 3.77 } do
		if ctx.crossed(p) then ctx.emit("AmbientSparkle", 6) end
	end
	if ctx.crossed(5.02) then ctx.emit("SpoutBurst", 30) end
	if ctx.crossed(5.3) then ctx.emit("SpoutBurst", 15) end
	if ctx.crossed(6.95) then ctx.emit("AmbientBubbles", 25) end
	if ctx.crossed(7.42) then
		ctx.emit("SpireSparkle", 25)
		ctx.emit("Fireworks", 15)
	end
	for i = 0, 3 do
		if ctx.crossed(7.86 + 0.15 * i) then ctx.emit("Fireworks", 22) end
	end
	if ctx.crossed(8.62) then ctx.emit("AmbientSparkle", 15) end
	if ctx.crossed(SLAM + 0.01) then
		ctx.emit("SplashBurst", 60)
		ctx.emit("AmbientBubbles", 20)
	end
	if ctx.crossed(10.42) then ctx.emit("Fireworks", 30) end
	if ctx.crossed(11.0) then ctx.emit("SpoutBurst", 12) end
	if ctx.crossed(BOOP + 0.01) then ctx.emit("BoopBurst", 25) end
	if ctx.crossed(13.3) then ctx.emit("BoopBurst", 10) end
	if ctx.crossed(14.5) then ctx.emit("AmbientSparkle", 10) end
end

return M
