--!nocheck
-- Lava Lily: calm, subtle-but-visible, seamless 9 s idle.
-- * the three stems sway softly (+-2 deg) with different phases, each lily
--   head nods a little on top of that
-- * every petal sits on its own bone: the blooms BREATHE open and closed
--   (outer petals +-11 deg, inner +-7 deg) once per loop, with a small
--   ripple running around the petal ring (3 cycles)
-- * the obsidian lily pads bob and rock on the lava (2 cycles)
-- * the molten hearts + pad bulbs pulse with the breathing; the pool light
--   flickers like lava
-- * LAVA BLOOM once per loop (peak 5.6 s): the big lily slowly gathers shut
--   (4.6-5.5 s), then bursts wide open (backOut) - the heart flashes, the
--   bloom light ramps up, a ring of embers sprays out of the flower and a
--   lava bubble pops in the pool (pads hop). A smaller lava pop at 2.0 s.
-- Every wave uses whole cycles per loop; every envelope is 0 at both loop
-- ends, so t=0 == t=9.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, exp, clamp = math.sin, math.exp, math.clamp

local M = {}
M.Cycle = 9

local TAU = math.pi * 2
local BEAT = 5.6
local POP = 2.0

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

-- per bloom: name, outer count, inner count, breath phase, sway phase, beat weight
local BLOOMS = {
	{ "Bloom", 6, 5, 0.00, 0.00, 1.0 },
	{ "Bloom2", 5, 4, 0.35, 0.40, 0.45 },
	{ "Bloom3", 5, 4, 0.68, 0.72, 0.45 },
}
local PADS = { { "Pad1", 0.1 }, { "Pad2", 0.45 }, { "Pad3", 0.75 } }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- lava bloom envelopes (0 outside ~4.5..8.7 s)
	local gather = L.track(c, { { 4.5, 0 }, { 5.45, 1, "sineInOut" }, { 5.62, 0, "cubicIn" } })
	local burst = L.track(c, { { 5.5, 0 }, { 6.0, 1, "backOut" }, { 6.8, 0.7, "sineInOut" }, { 8.6, 0, "sineInOut" } })
	local flash = L.track(c, { { 5.5, 0 }, { 5.65, 1, "quadOut" }, { 6.3, 0.8 }, { 8.2, 0, "sineInOut" } })
	-- pool pops: pad hop impulses
	local hop = 0
	for _, p in { { POP, 0.5 }, { BEAT + 0.05, 1.0 } } do
		local dt = c - p[1]
		if dt > 0 and dt < 2.5 then
			hop += p[2] * exp(-2.5 * dt) * sin(9 * dt)
		end
	end

	pose.Crop = ang(0.3 * w(t, 1, 0.6), 0, 0.3 * w(t, 1, 0.85))

	for bi, b in BLOOMS do
		local name, nO, nI, bph, sph, bw = b[1], b[2], b[3], b[4], b[5], b[6]
		local stem = (bi == 1) and "Stem" or ("Stem" .. bi)
		local g, bu = gather * bw, burst * bw
		pose[stem] = ang(1.8 * w(t, 1, sph) - 1.2 * g + 1.5 * bu * w(t, 2, 0.1), 0.8 * w(t, 1, sph + 0.3), 2.0 * w(t, 1, sph + 0.25))
		pose[name] = pa(0, -0.2 * g + 0.25 * bu, 0, 2.5 * w(t, 2, sph + 0.1) + 3 * g, 3 * w(t, 1, sph + 0.5), 2 * w(t, 2, sph + 0.35))
		local breath = w(t, 1, bph) -- +1 = open
		for i = 1, nO do
			local rip = w(t, 3, bph + i / nO)
			pose[name .. "O" .. i] = ang(-11 * breath - 3 * rip + 22 * g - 26 * bu, 0, 0)
		end
		for i = 1, nI do
			local rip = w(t, 3, bph + 0.5 + i / nI)
			pose[name .. "I" .. i] = ang(-7 * breath - 2.5 * rip + 16 * g - 18 * bu, 0, 0)
		end
		-- heart glow: brighter when open, flashes on the bloom burst
		local o = 0.5 + 0.5 * breath
		ctx.transparency(name .. "Core", clamp((0.45 - 0.35 * o + 0.3 * g) * (1 - flash * bw), 0, 0.7))
	end

	for i, p in PADS do
		local ph = p[2]
		pose[p[1]] = pa(0, 0.1 * w(t, 2, ph) + 0.18 * hop * (i == 1 and 1 or 0.7), 0,
			2.2 * w(t, 1, ph) + 3 * hop, 4 * w(t, 1, ph + 0.4), 2.4 * w(t, 1, ph + 0.25) - 2 * hop)
	end
	ctx.transparency("Pad1Core", clamp(0.35 + 0.2 * w(t, 2, 0.2) - 0.3 * flash, 0, 0.6))
	ctx.transparency("Pad3Core", clamp(0.35 + 0.2 * w(t, 2, 0.7) - 0.3 * flash, 0, 0.6))

	-- lights: lava flicker in the pool, the bloom glows up on the burst
	ctx.light("PoolLight", clamp(1.15 + 0.2 * w(t, 3, 0.1) + 0.1 * w(t, 5, 0.3) + 0.6 * flash, 0, 2))
	ctx.light("BloomLight", clamp(0.8 + 0.25 * w(t, 1, 0.0) - 0.4 * gather + 1.1 * flash, 0, 2))

	if ctx.crossed(POP) then
		ctx.emit("PopSplash", 14)
	end
	if ctx.crossed(BEAT) then
		ctx.emit("BloomBurst", 40)
		ctx.emit("PopSplash", 28)
	end
end

return M
