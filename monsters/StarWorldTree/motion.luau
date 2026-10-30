--!nocheck
-- Starforge World Tree: the most spectacular crop in the game, seamless 10 s.
-- Idle (always moving, calm):
-- * the giant trunk sways softly; the canopy sways and breathes while the
--   whole GALAXY canopy turns (half a turn per loop at idle) so the three
--   spiral arms sweep round and carry the six star fruits, which swing on
--   their stems with their cores twinkling
-- * the STARFORGE HEART bobs and slowly spins; its six rays pulse in and
--   out in a ripple; the two armillary rings spin in opposite directions
--   (1 and 2 turns per loop) with glowing beads drawing trails
-- * four PLANETS orbit on tilted paths (1-2 laps, both directions),
--   spinning and bobbing, each with a trail
-- * energy pulses climb the three neon starforge VEINS up the trunk;
--   runes on the temple light up in a chase; three ruin stones float
-- Signature SUPERNOVA (peak 6.2 s):
-- * 4.6-6.15 s CHARGE: the heart sinks and shakes harder and harder, the
--   rays pull in, the core dims, the veins flood with light from the root
--   up, the planets are drawn in, the canopy settles, the rings tilt in
-- * 6.2 s SUPERNOVA: rays blast out (backOut), the core flashes, a ring of
--   eight neon shards flies out as a shockwave, a SKY BEAM shoots up from
--   the heart, 150 sparks + 60 nebula motes burst, star rain falls, the
--   galaxy WHIRLS an extra half turn, the planets are flung outward and race
--   an extra lap, the rings whirl + flare, the fruits kick and flash, the
--   ruin stones leap, every light flashes to 2
-- * 6.5 s the energy reaches the temple: all runes flash + forge sparks
-- * everything settles by ~9.4 s.
-- Seamless: whole wave cycles per loop; envelopes 0 at both ends; spins end
-- on full symmetry turns (galaxy 180+180, heart 90+90 on a 4-fold star,
-- rings + planets whole laps); shards/beam are invisible when they reset.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, cos, exp, clamp, rad = math.sin, math.cos, math.exp, math.clamp, math.rad

local M = {}
M.Cycle = 10

local TAU = math.pi * 2
local NOVA = 6.2

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

local function spring(dt, k, f)
	if dt <= 0 then
		return 0
	end
	return exp(-k * dt) * sin(f * dt)
end

-- fruit polar angle in the galaxy frame (match build: arms at k*120 + 165*u)
local FRUIT_DEG = {}
do
	local n = 0
	for k = 0, 2 do
		for _, j in { 3, 6 } do
			n += 1
			FRUIT_DEG[n] = k * 120 + 165 * (j / 8)
		end
	end
end
local FRUIT_PH = { 0.0, 0.31, 0.58, 0.12, 0.83, 0.47 }
-- planets: laps per loop (signed), self spins, bob phase
local PLANETS = { { 1, 1, 0.0 }, { -2, 2, 0.3 }, { 1, -1, 0.6 }, { -2, 3, 0.15 } }
local RAYS = { Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, -1, 0), Vector3.new(0, 0, 1), Vector3.new(0, 0, -1) }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- supernova envelopes
	local gather = L.track(c, { { 4.6, 0 }, { 6.1, 1, "sineInOut" }, { 6.25, 0, "cubicIn" } })
	local nova = L.track(c, { { 6.15, 0 }, { 6.45, 1, "backOut" }, { 7.2, 0.6, "sineInOut" }, { 9.4, 0, "sineInOut" } })
	local flash = L.track(c, { { 6.15, 0 }, { 6.25, 1, "quadOut" }, { 7.0, 0.75 }, { 9.2, 0, "sineInOut" } })
	local beam = L.track(c, { { 6.15, 0 }, { 6.3, 1, "quadOut" }, { 7.0, 0.8 }, { 8.4, 0, "sineInOut" } })
	local shock = L.track(c, { { 6.15, 0 }, { 7.4, 1, "cubicOut" }, { 8.0, 1 }, { 9.0, 0, "sineInOut" } })
	local shardVis = L.track(c, { { 6.15, 0 }, { 6.25, 1, "quadOut" }, { 6.9, 0.65 }, { 7.45, 0, "quadIn" } })
	local whirl = L.track(c, { { 5.9, 0 }, { 8.4, 1, "cubicInOut" } }) -- stays 1
	local lap = L.track(c, { { 6.0, 0 }, { 8.8, 1, "cubicInOut" } }) -- stays 1
	local runeF = L.track(c, { { 6.4, 0 }, { 6.55, 1, "quadOut" }, { 7.4, 0.5 }, { 8.8, 0, "sineInOut" } })
	local hop = L.track(c, { { 6.25, 0 }, { 6.7, 1, "backOut" }, { 7.6, 0.4, "sineInOut" }, { 9.0, 0, "sineInOut" } })
	local kick = spring(c - NOVA, 1.5, 6.5)
	local g2 = gather * gather
	local shake = 3.2 * g2

	-- trunk + canopy
	pose.Crop = ang(0.5 * w(t, 1, 0.6) - 0.6 * kick, 0, 0.6 * w(t, 1, 0.85))
	pose.Canopy = pa(0, -0.3 * gather + 0.4 * nova, 0, 1.6 * w(t, 1, 0.0) - 1.4 * kick, 0, 1.8 * w(t, 1, 0.25) + 0.8 * kick)
	local galYaw = 180 * c / M.Cycle + 180 * whirl
	pose.Galaxy = pa(0, 0.25 * w(t, 2, 0.1) - 0.3 * gather + 0.6 * nova, 0,
		1.2 * w(t, 1, 0.4) + 2.0 * kick, galYaw, 1.0 * w(t, 1, 0.65))
	pose.Canopy2 = pa(0, 0.15 * w(t, 2, 0.35) - 0.2 * gather + 0.5 * nova, 0, 1.2 * w(t, 1, 0.2) - 1.5 * kick, 0, 1.2 * w(t, 1, 0.55))

	-- star fruits
	for i = 1, 6 do
		local a = rad(FRUIT_DEG[i])
		local ox, oz = sin(a), -cos(a)
		local K = 16 * kick - 6 * gather
		local ph = FRUIT_PH[i]
		pose["Fruit" .. i] = ang(10 * w(t, 2 + (i % 2), ph) - K * oz, 8 * w(t, 1, ph + 0.4), 9 * w(t, 2 + (i % 2), ph + 0.25) + K * ox)
		ctx.transparency("FruitCore" .. i, clamp((0.3 + 0.15 * w(t, 3, ph + i * 0.13) + 0.35 * gather) * (1 - flash), 0, 0.8))
	end

	-- starforge heart
	local spin = 90 * c / M.Cycle + 90 * whirl
	pose.Core = pa(shake * 0.12 * w(t, 70, 0.0), 0.3 * w(t, 2, 0.3) - 0.6 * gather + 0.9 * nova, shake * 0.12 * w(t, 90, 0.2),
		3 * w(t, 1, 0.2) + shake * w(t, 80, 0.1), spin, 3 * w(t, 1, 0.45) + shake * w(t, 100, 0.4))
	for i, d in RAYS do
		local ext = 0.3 + 0.3 * w(t, 3, (i - 1) / 6) - 1.0 * gather + 2.6 * nova
		pose["Ray" .. i] = CFrame.new(d * ext)
		ctx.transparency("RayTip" .. i, clamp((0.3 - 0.2 * w(t, 3, (i - 1) / 6) + 0.3 * gather) * (1 - flash), 0, 0.7))
	end
	ctx.transparency("StarCore", clamp((0.08 + 0.1 * (0.5 + 0.5 * w(t, 4, 0.1)) + 0.45 * gather) * (1 - flash), 0, 0.6))
	-- rings: 1 and -2 laps per loop + an extra whirl lap; tilt in, flare out
	pose.RingA = ang(-10 * gather + 14 * nova + 4 * w(t, 1, 0.1), 360 * (c / M.Cycle + lap), 6 * nova)
	pose.RingB = ang(8 * gather - 12 * nova + 4 * w(t, 1, 0.6), -360 * (2 * c / M.Cycle + lap), -8 * nova)
	ctx.transparency("BeadA", clamp(0.2 + 0.2 * w(t, 4, 0.0) - 0.3 * flash, 0, 0.6))
	ctx.transparency("BeadB", clamp(0.2 + 0.2 * w(t, 4, 0.5) - 0.3 * flash, 0, 0.6))
	-- shockwave shards + sky beam
	for i = 1, 8 do
		pose["Shard" .. i] = CFrame.new(0, 0.6 * (i % 2 == 0 and 1 or -1) * shock, -14 * shock)
		ctx.transparency("Shard" .. i, 1 - 0.9 * shardVis)
	end
	ctx.transparency("BeamCore", 1 - 0.85 * beam)
	ctx.transparency("BeamGlow", 1 - 0.5 * beam)

	-- planets
	for n, pl in PLANETS do
		pose["Orbit" .. n] = ang(0, 360 * (pl[1] * c / M.Cycle + (pl[1] > 0 and 1 or -1) * lap), 0)
		pose["Planet" .. n] = pa(0, 0.4 * w(t, 2, pl[3]) + 0.8 * nova * w(t, 1, pl[3]), 1.6 * gather - 3.0 * nova,
			6 * w(t, 1, pl[3]), 360 * pl[2] * c / M.Cycle, 0)
	end

	-- floating ruin stones
	for i = 1, 3 do
		local ph = i * 0.29
		pose["Float" .. i] = pa(0, 0.45 * w(t, 1, ph) + 1.6 * hop - 0.3 * gather, 0,
			5 * w(t, 1, ph + 0.25) + 10 * hop, 12 * w(t, 1, ph + 0.5) + 30 * hop, 4 * w(t, 2, ph))
		ctx.transparency("FloatRune" .. i, clamp(0.35 + 0.25 * w(t, 2, ph) - 0.6 * runeF, 0, 0.7))
		ctx.transparency("FloatRuneB" .. i, clamp(0.35 + 0.25 * w(t, 2, ph) - 0.6 * runeF, 0, 0.7))
	end

	-- starforge veins: pulses climb upward; charge floods them from the root
	for k = 1, 3 do
		for j = 1, 5 do
			local p = 0.5 + 0.5 * w(t, 5, -j * 0.16 + k / 3)
			local fill = clamp(gather * 1.6 - (j - 1) * 0.15, 0, 1)
			ctx.transparency("Vein" .. k .. "_" .. j, clamp((0.7 - 0.6 * p * p) * (1 - fill) * (1 - flash), 0, 0.8))
		end
	end

	-- runes: chase round the temple, flash when the nova lands
	for i = 1, 8 do
		local ch = 0.5 + 0.5 * w(t, 2, -(i - 1) / 8)
		local tr = clamp((0.65 - 0.55 * ch * ch - 0.2 * gather) * (1 - runeF), 0, 0.8)
		ctx.transparency("Rune" .. i, tr)
		ctx.transparency("RuneB" .. i, tr)
	end

	-- lights
	ctx.light("CoreLight", clamp(1.35 + 0.15 * w(t, 4, 0.1) - 0.6 * gather + 0.65 * flash, 0, 2))
	ctx.light("GalaxyLight", clamp(0.95 + 0.15 * w(t, 2, 0.3) - 0.3 * gather + 1.0 * flash, 0, 2))
	ctx.light("RuneLight", clamp(0.7 + 0.2 * w(t, 2, 0.1) + 1.2 * runeF, 0, 2))
	ctx.light("VeinLight", clamp(0.6 + 0.2 * w(t, 5, 0.2) + 1.0 * gather + 0.6 * flash, 0, 2))

	-- one-shots
	if ctx.crossed(5.3) then
		ctx.emit("CoreSparkle", 25)
		ctx.emit("VeinMotes", 15)
	end
	if ctx.crossed(NOVA) then
		ctx.emit("NovaBurst", 150)
		ctx.emit("NovaDust", 60)
		ctx.emit("StarRain", 45)
		ctx.emit("GalaxyDust", 40)
	end
	if ctx.crossed(6.5) then
		ctx.emit("ForgeSparks", 50)
		ctx.emit("RuneMotes", 20)
	end
end

return M
