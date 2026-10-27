--!nocheck
-- Atlantis Sky Whale motion. Personality: a GENTLE, motherly guardian.
-- Idle: slow majestic swim wave travelling down the body (whales swim up and
-- down), flippers glide, the city sways softly on her back, waterfalls
-- shimmer, slow affectionate blinks. She glances back over her shoulder at
-- her city with a warm smile and hums (bubbles from the blowhole).
-- Signature "RISING ATLANTIS" (every 14 s):
--   5.0  deep breath: sinks, belly swells, eyes close calmly, flippers tuck
--   6.4  rises in a grand arc (nose up, tail curls under, flippers open wide
--        like arms); the city counter-tilts to stay level (she protects it)
--   6.9  the crystal spire charges (sparkles, glow ramps, shiver)
--   7.45 BEAM of light fires straight up + a spinning halo of rays, she sings
--   7.7  the towers rise out of the walls one by one (overshoot), gold burst
--   9.0  graceful dive: the tail lifts high (wind-up) ...
--   9.84 ... HUGE FLUKE SLAP: bubble burst, squash, city jolts, towers bounce
--  10.2  content peaceful smile with happy closed eyes, little hum, settle
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 14

local sin, pi, max, min = math.sin, math.pi, math.max, math.min
local TAU = 2 * pi
local SW = 2 / 7 -- swim frequency (4 strokes per loop)

local CHAIN = { "Head", "Body", "Tail1", "Tail2", "Tail3", "Fluke" }
local AMP = { 3, 2.5, 5, 9, 13, 20 } -- swim pitch (absolute), head -> fluke
local ARC = { 34, 22, 30, 40, 50, 62 } -- rising arc: nose up, tail curls under
local LIFT = { -4, -12, -26, -44, -62, -82 } -- dive wind-up: tail lifts high
local SLAPA = { 4, 6, 16, 30, 46, 72 } -- slap: tail whips down
local BLINKS = { 0.9, 4.6, 12.6 }

local FIRE = 7.45
local SLAP = 9.84

local CHUNK_DIR = {
	{ 1.0, 1.4, -0.4 }, { -1.0, 1.3, -0.6 }, { 0.5, 1.7, 0.9 },
	{ -0.6, 1.6, 0.8 }, { 1.2, 1.0, 0.6 }, { -1.2, 1.1, 0.2 },
}

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes
	------------------------------------------------------------------
	local breath = L.env(c, 5.0, 1.2, 0.3, 0.45, "sineInOut", "cubicIn")
	local rise = L.env(c, 6.35, 1.1, 1.45, 0.7, "backOut", "sineInOut")
	local charge = L.env(c, 6.9, 0.55, 0.0, 0.12, "quadIn", "quadOut")
	local beam = L.env(c, FIRE, 0.12, 1.45, 0.5, "expoOut", "cubicIn")
	local lift = L.env(c, 9.0, 0.75, 0.05, 0.09, "sineInOut", "expoIn")
	local slap = L.env(c, 9.7, 0.14, 0.04, 1.4, "quadIn", "elasticOut")
	local squash = L.env(c, SLAP, 0.06, 0.04, 0.9, "linear", "elasticOut")
	local content = L.env(c, 10.25, 0.4, 1.9, 0.6, "sineInOut", "sineInOut")
	local look = L.env(c, 1.6, 0.9, 1.1, 0.9, "sineInOut", "sineInOut") -- glance at the city (left)
	local look2 = L.env(c, 12.0, 0.7, 0.6, 0.7, "sineInOut", "sineInOut") -- glance right
	local hum = max(L.env(c, 2.4, 0.3, 1.1, 0.4), L.env(c, 11.0, 0.3, 1.0, 0.4), 0.7 * L.env(c, 12.4, 0.3, 0.6, 0.4))
	local special = max(breath, min(1, rise), lift, min(1, slap))
	local swimW = 1 - 0.7 * special

	------------------------------------------------------------------
	-- absolute pitch of every segment (whale swim = vertical wave)
	------------------------------------------------------------------
	local pitch = {}
	for i = 1, #CHAIN do
		local swim = AMP[i] * sin(TAU * (SW * t - 0.11 * (i - 1)))
		pitch[i] = swim * swimW + ARC[i] * rise + LIFT[i] * lift + SLAPA[i] * slap
	end
	-- deep breath: nose dips, tail tucks a bit
	pitch[1] += -4 * breath
	pitch[2] += -5 * breath
	pitch[6] += 6 * breath
	-- slap follow-through on the fluke
	pitch[6] += -10 * squash
	-- content nod
	pitch[1] += -5 * content * (0.5 + 0.5 * sin(TAU * 1.0 * (c - 10.25)))
	-- song: head lifts while the beam fires
	pitch[1] += 12 * beam

	------------------------------------------------------------------
	-- body: calm bob, deep-breath sink, majestic rise, squash on the slap
	------------------------------------------------------------------
	local bob = 0.8 * sin(TAU * (SW * t + 0.15)) * (1 - 0.6 * special)
	local by = bob - 1.4 * breath + 3.4 * rise - 1.6 * squash + 0.5 * lift
	local bz = -1.5 * rise + 0.8 * lift
	local roll = 3 * wave(t, 1 / 7) * swimW - 5 * look + 4 * look2
	local yaw = 2 * wave(t, 1 / 14, 0.2) * swimW
	pose.Body = pa(0, by, bz, pitch[2], yaw, roll)
	pose.Head = ang(pitch[1] - pitch[2], 22 * look - 16 * look2, 6 * look - 4 * look2)
	for i = 3, #CHAIN do
		pose[CHAIN[i]] = ang(pitch[i] - pitch[i - 1], 0, 0)
	end
	pose.Belly = CFrame.new(0, -0.9 * breath + 0.15 * wave(t, SW), -0.2 * breath)

	------------------------------------------------------------------
	-- face: warm smile, hums, the song, blinks, content closed eyes
	------------------------------------------------------------------
	local humMouth = hum * (0.5 + 0.5 * sin(TAU * 2 * c))
	local jaw = -2 - 5 * humMouth - 24 * beam - 6 * charge + 3 * breath - 8 * squash
	pose.Jaw = ang(jaw, 0, 0)

	local blink = 0
	for _, b in BLINKS do
		blink = max(blink, L.env(c, b, 0.07, 0.12, 0.1))
	end
	local closedCalm = max(blink, breath > 0.35 and 1 or 0, squash > 0.5 and 1 or 0)
	local happy = content > 0.3 and 1 or 0
	local lidOn = (closedCalm > 0.5 or happy > 0) and 0 or 1
	local lashOn = (closedCalm > 0.5 and happy == 0) and 0 or 1
	local happyOn = happy > 0 and 0 or 1
	for _, s in { "R", "L" } do
		ctx.transparency("Lid" .. s, lidOn)
		ctx.transparency("Lash" .. s, lashOn)
		ctx.transparency("LashS" .. s, lashOn)
		for k = 1, 4 do
			ctx.transparency("Happy" .. s .. k, happyOn)
		end
	end
	-- pupils: glance back at the city, look up at the beam
	local pz = 0.45 * max(look, look2) - 0.15 * rise
	local py = 0.25 * beam + 0.1 * rise
	L.both(pose, "Pupil", CFrame.new(0, py, pz))

	------------------------------------------------------------------
	-- flippers: slow glide, tuck on the breath, open wide on the rise
	------------------------------------------------------------------
	local glide = sin(TAU * (SW * t + 0.05))
	local flap = 12 * glide * swimW - 14 * breath + 42 * rise + 6 * lift + 30 * squash
	local sweep = 8 * sin(TAU * (SW * t + 0.3)) * swimW + 18 * breath - 22 * rise + 10 * lift
	local tipFlap = 10 * sin(TAU * (SW * t - 0.05)) * swimW + 22 * rise * (1 + 0.25 * sin(TAU * 1.5 * c)) - 10 * breath + 25 * squash
	L.both(pose, "Fin", ang(0, sweep, flap))
	L.both(pose, "FinTip", ang(0, 0, tipFlap))

	------------------------------------------------------------------
	-- city: soft sway, counter-tilts to stay level (protective), jolts on slap
	------------------------------------------------------------------
	local cityPitch = -0.5 * pitch[2] - 0.35 * ARC[2] * rise + 1.2 * wave(t, SW, 0.3) + 4 * squash * sin(TAU * 3 * (c - SLAP))
	local cityRoll = 2 * wave(t, 1 / 7, 0.4) + 3 * squash * sin(TAU * 2.5 * (c - SLAP))
	pose.City = pa(0, -0.3 * squash, 0, cityPitch, 0, cityRoll)
	for i = 1, 3 do
		pose["Weed" .. i] = ang(10 * wave(t, 0.5, i * 0.23), 0, 14 * wave(t, 0.5, i * 0.31 + 0.1) + 20 * squash)
	end

	-- towers rise out of the walls one by one with overshoot
	for i = 1, 4 do
		local up = L.env(c, 7.7 + 0.13 * (i - 1), 0.5, 2.4 - 0.13 * (i - 1), 1.0, "backOut", "cubicInOut")
		local bounce = 0.35 * squash * sin(TAU * 3 * (c - SLAP) + i)
		pose["Tower" .. i] = pa(0, 2.6 * up + bounce, 0, 0, 25 * up * (1 - up) * 4 * (i % 2 == 0 and -1 or 1), 0)
	end

	-- the spire: shivers while charging, recoils on the shot; halo spins
	local shiver = charge * sin(TAU * 18 * c) * 3
	pose.Spire = pa(0, 0.3 * beam, 0, shiver, 60 * beam * (c - FIRE), -shiver * 0.6)
	pose.Halo = ang(0, 220 * (c - FIRE) * (beam > 0 and 1 or 0), 0)

	------------------------------------------------------------------
	-- VFX transparencies
	------------------------------------------------------------------
	ctx.transparency("BeamCore", beam > 0.02 and (1 - 0.92 * beam) or 1)
	ctx.transparency("BeamGlow", beam > 0.02 and (1 - 0.5 * beam) or 1)
	local splashOn = c > SLAP and c < SLAP + 0.3
	for i = 1, 6 do
		ctx.transparency("SplashLine" .. i, splashOn and 0.15 + 2.5 * max(0, c - SLAP - 0.0) or 1)
	end
	for i = 1, 10 do
		ctx.transparency("Ray" .. i, beam > 0.05 and (1 - 0.9 * beam) or 1)
	end
	for k = 1, 4 do
		local f = 0.28 + 0.1 * sin(TAU * (3 * t + k * 0.37))
		ctx.transparency("Fall" .. k, f)
		ctx.transparency("FallStreak" .. k, 0.15 + 0.35 * (0.5 + 0.5 * sin(TAU * (5 * t + k * 0.21))))
	end

	-- gold chunks pop out of the city as the towers rise
	local cp = L.remap(c, 7.75, 8.75)
	local chunkOn = c > 7.75 and c < 8.75
	local ce = L.ease.cubicOut(cp)
	for k = 1, 6 do
		local d = CHUNK_DIR[k]
		local r = 6 * ce
		local spin = 480 * cp * (k % 2 == 0 and -1 or 1)
		pose["Chunk" .. k] = chunkOn and pa(d[1] * r, d[2] * r - 6 * cp * cp, d[3] * r, spin, spin * 0.6, 30 * k) or CFrame.new()
		ctx.transparency("ChunkPart" .. k, chunkOn and (cp > 0.75 and (cp - 0.75) / 0.25 or 0) or 1)
	end

	------------------------------------------------------------------
	-- floating cubes: bob, drift, tumble; lift with her, pushed by the slap
	------------------------------------------------------------------
	for i = 1, 6 do
		local ph = i * 0.17
		local dir = i % 2 == 0 and -1 or 1
		local dx = 0.8 * wave(t, 1 / 7, ph) + 1.8 * squash * dir
		local dy = 0.9 * wave(t, SW, ph + 0.3) + 2.2 * rise + 1.0 * beam * wave(t, 1.0, ph)
		local dz = 0.8 * wave(t, 1 / 7, ph + 0.25)
		local spinRate = 360 / 7 * (1 + (i % 3))
		pose["Orb" .. i] = pa(dx, dy, dz, spinRate * t * dir * 0.5 + 20 * i, spinRate * t, 15 * i)
	end

	------------------------------------------------------------------
	-- effects on the beats
	------------------------------------------------------------------
	ctx.enable("HumBubbles", hum > 0.5 or (content > 0.5 and c > 11.0))
	ctx.enable("SpireCharge", c > 6.9 and c < FIRE + 0.2)
	ctx.light("SpireLight", min(2, 0.35 + 0.15 * L.wave01(t, 0.5) + 1.0 * charge + 1.6 * beam))
	ctx.light("TempleLight", 0.6 + 0.6 * beam)
	if ctx.crossed(FIRE + 0.02) then
		ctx.emit("BeamBurst", 50)
		ctx.emit("CitySparkle", 20)
	end
	if ctx.crossed(7.75) then
		ctx.emit("GoldBurst", 40)
	end
	if ctx.crossed(8.1) then
		ctx.emit("GoldBurst", 20)
	end
	if ctx.crossed(SLAP) then
		ctx.emit("SlapBurst", 70)
		ctx.emit("AmbientBubbles", 30)
		ctx.emit("FallDrips", 30)
	end
	if ctx.crossed(10.6) then
		ctx.emit("CitySparkle", 12)
	end
end

return M
