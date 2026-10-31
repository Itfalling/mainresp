--!nocheck
-- Starlight Sanctum: seamless 8 s loop.
-- * 0.3-3.3 s DIALLING: the eight chevron stars on the gate frame light up
--   one by one; the column runes chase upward toward the crystals
-- * 3.2-4.0 s CHARGE: the step runes chase up the stairs into the gate, the
--   swirl core sinks back, the rings start to whirl
-- * 4.0 s BEAT: core rays flash, the core punches forward, a burst of star
--   sparks blasts out of the portal, the stairs spark, crystals and floating
--   rubble hop, the shards are flung outward, the portal light flares
-- * 6.6-7.5 s the chevrons go dark again
-- Always: RingA and RingB counter-rotate (1 turn + 1 whirl turn per loop
-- each), the galaxy swirl spins (2 + 1 turns), the core spins, the moon bobs
-- and rocks while its gold star turns, four crystals bob and spin, six star
-- shards orbit the gate (1 turn) spinning on their own axes, the four
-- constellations light up in sequence star by star.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, max, clamp01 = math.sin, math.max, L.clamp01

local M = {}
M.Cycle = 8
local C = M.Cycle
local TAU = math.pi * 2

local function w(c, n, ph)
	return sin(TAU * (n * c / C + (ph or 0)))
end
-- 0 -> 1 -> 0 bump starting at t0 lasting dur (wraps around the loop)
local function bump(c, t0, dur)
	local d = (c - t0) % C
	if d > dur then
		return 0
	end
	return sin(math.pi * d / dur)
end

local CON_N = 6
local CON_T = { 0.2, 2.2, 4.2, 6.2 }
local COLRUNES = { L = 7, R = 6 }
local CRYSTALS = { { "CrystalL", 0.0, 1 }, { "CrystalR", 0.35, -1 }, { "CrystalL2", 0.6, -1 }, { "CrystalR2", 0.15, 1 } }
local FLOATS = { { "FloatA", 0.1 }, { "FloatB", 0.45 }, { "FloatC", 0.75 } }

function M.Update(t, pose, ctx)
	local c = t % C

	local charge = L.track(c, { { 3.2, 0 }, { 3.95, 1, "sineInOut" }, { 4.05, 0, "quadIn" } })
	local flash = L.track(c, { { 3.95, 0 }, { 4.05, 1, "quadOut" }, { 4.6, 0.7 }, { 6.4, 0, "sineInOut" } })
	local punch = L.track(c, { { 3.95, 0 }, { 4.1, 1, "quadOut" }, { 4.9, 0, "backOut" } })
	local hop = L.track(c, { { 4.0, 0 }, { 4.35, 1, "backOut" }, { 5.8, 0, "sineInOut" } })
	local whirl = L.track(c, { { 3.4, 0 }, { 6.4, 1, "cubicInOut" } }) -- stays 1: one extra turn per loop

	-- gate rings + swirl + core
	pose.RingA = ang(0, 0, -(360 * c / C + 360 * whirl))
	pose.RingB = ang(0, 0, 360 * c / C + 360 * whirl)
	pose.Swirl = ang(0, 0, -(720 * c / C + 360 * whirl))
	pose.Core = pa(0, 0, 1.4 * charge - 2.4 * punch, 0, 0, 360 * c / C)
	for i = 1, 4 do
		ctx.transparency("CoreRay" .. i, 1 - 0.95 * flash)
	end
	ctx.transparency("CoreGem", 0.35 * (0.5 + 0.5 * w(c, 4)) * (1 - flash))

	-- chevrons dial in, flash on the beat, go dark
	local off = clamp01((c - 6.6) / 0.9)
	for i = 1, 8 do
		local on = clamp01((c - (0.3 + 0.42 * (i - 1))) / 0.15)
		local lit = on * (1 - off)
		ctx.transparency("Chevron" .. i, 0.72 * (1 - max(0.8 * lit, flash)))
	end

	-- step runes chase up into the gate (big before the beat, soft echo later)
	for k = 1, 4 do
		local p = max(bump(c, 3.1 + 0.2 * k, 0.7), 0.5 * bump(c, 7.0 + 0.2 * k, 0.7), 0.7 * flash)
		ctx.transparency("StepRune" .. k, 0.6 * (1 - p))
	end
	if ctx.crossed(3.9) then
		ctx.emit("StairBurst", 45)
	end

	-- column runes chase upward
	for side, n in COLRUNES do
		for k = 1, n do
			local p = max(bump(c, 0.6 + 0.3 * k, 0.9), 0.8 * flash)
			ctx.transparency("ColRune" .. side .. k, 0.65 * (1 - p))
		end
	end

	-- constellations light up in sequence, star by star
	for j = 1, 4 do
		for k = 1, CON_N do
			local p = bump(c, CON_T[j] + 0.16 * k, 1.5)
			ctx.transparency("Con" .. j .. "S" .. k, 0.55 * (1 - max(p, 0.6 * flash)))
			if k < CON_N then
				local q = bump(c, CON_T[j] + 0.16 * k + 0.1, 1.5)
				ctx.transparency("Con" .. j .. "L" .. k, 0.8 * (1 - max(q, 0.5 * flash)))
			end
		end
	end
	ctx.transparency("TowerStarL", 0.5 * (1 - max(bump(c, CON_T[3] + 0.3, 1.6), flash)))
	ctx.transparency("TowerStarR", 0.5 * (1 - max(bump(c, CON_T[4] + 0.3, 1.6), flash)))

	ctx.transparency("MedalL", 0.6 * (1 - max(bump(c, 1.0, 1.4), flash)))
	ctx.transparency("MedalR", 0.6 * (1 - max(bump(c, 5.0, 1.4), flash)))

	-- moon + star
	pose.Moon = pa(0, 1.1 * w(c, 1) + 0.6 * hop, 0, 0, 0, 3.5 * w(c, 1, 0.25))
	pose.StarTop = ang(0, 0, -360 * c / C)
	pose.MoonRing = ang(0, 360 * c / C, 0)
	ctx.transparency("StarCore", 0.45 * (0.5 + 0.5 * w(c, 2)) * (1 - flash))
	ctx.transparency("MoonTip1", 0.7 * (0.5 + 0.5 * w(c, 4, 0.0)))
	ctx.transparency("MoonTip2", 0.7 * (0.5 + 0.5 * w(c, 4, 0.5)))

	-- crystals bob + spin, hop on the beat
	for _, cr in CRYSTALS do
		local ph, dir = cr[2], cr[3]
		pose[cr[1]] = pa(0, 1.3 * w(c, 1, ph) + 1.2 * hop, 0, 0, dir * 360 * c / C, 5 * w(c, 1, ph + 0.25))
		ctx.transparency(cr[1] .. "Band", 0.4 * (0.5 + 0.5 * w(c, 2, ph)) * (1 - flash))
	end

	-- floating rubble
	for _, f in FLOATS do
		local ph = f[2]
		pose[f[1]] = pa(0, 0.8 * w(c, 1, ph) + 0.7 * hop, 0, 6 * w(c, 1, ph + 0.3), 0, 7 * w(c, 1, ph + 0.6))
	end

	-- orbiting shards
	pose.Orbit = ang(0, 0, 360 * c / C)
	for i = 1, 6 do
		local out = 2.6 * hop + 0.6 * w(c, 2, i / 6)
		pose["Shard" .. i] = pa(0, out, 0, 0, ((i % 2 == 0) and 1 or -1) * 720 * c / C, 0) * ang(18 * w(c, 1, i / 6), 0, 0)
	end

	-- lights + beat burst
	ctx.light("PortalLight", 0.9 + 0.5 * flash + 0.1 * w(c, 2))
	ctx.light("MoonLight", 0.7 + 0.15 * w(c, 1))
	if ctx.crossed(4.0) then
		ctx.emit("PortalBurst", 90)
	end
end

return M
