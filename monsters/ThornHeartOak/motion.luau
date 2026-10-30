--!nocheck
-- Heartwood Thorn Oak: a SUBTLE, seamless 10 s idle for the Apex crop.
-- * the trunk barely moves; the big canopy sways +-2 deg and gently breathes
--   (a small bob), the upper tiers follow with a little lag (+-1 deg more)
-- * six rose-gold heart-fruits swing on their stems (HeartN, pivot at the
--   stem top, +-6..8 deg, small elliptical paths, phase-offset)
-- * four briar tendrils ripple down their two-bone chains (VineNa -> VineNb)
-- * the heart glows pulse softly like a slow heartbeat (neon transparency)
--   and the warm heart light breathes with them
-- Every wave uses a whole number of cycles per loop, so t=0 == t=10.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, clamp = math.sin, math.clamp

local M = {}
M.Cycle = 10

local TAU = math.pi * 2
-- n whole cycles per loop, phase in turns
local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end
-- soft "lub-dub" heartbeat in [0,1]: two gentle swells per beat, 5 beats per loop
local function beat(t, ph)
	local x = (t / M.Cycle * 5 + (ph or 0)) % 1
	-- wrap-safe distance so the pulse is seamless across beats
	local function d(c)
		local e = math.abs(x - c)
		return math.min(e, 1 - e)
	end
	local a = math.exp(-(d(0.2) / 0.13) ^ 2)
	local b = 0.6 * math.exp(-(d(0.48) / 0.14) ^ 2)
	return clamp(a + b, 0, 1)
end

local HEARTS = {
	-- cycles per loop, phase, pitch amp, roll amp
	{ 3, 0.00, 7, 6 },
	{ 2, 0.31, 8, 6 },
	{ 3, 0.58, 6, 7 },
	{ 2, 0.12, 7, 6 },
	{ 3, 0.83, 7, 6 },
	{ 2, 0.47, 8, 7 },
}
local VINES = { 0.05, 0.4, 0.65, 0.9 }

function M.Update(t, pose, ctx)
	-- trunk: almost still
	pose.Crop = ang(0.25 * w(t, 1, 0.6), 0, 0.25 * w(t, 1, 0.85))
	-- canopy: slow sway + breathing bob
	pose.Canopy = pa(0, 0.12 * w(t, 2, 0.1), 0, 1.9 * w(t, 1, 0.0), 0.6 * w(t, 1, 0.35), 2.1 * w(t, 1, 0.25))
	-- upper tiers trail a little behind
	pose.CanopyTop = pa(0, 0.06 * w(t, 2, 0.35), 0, 1.0 * w(t, 1, 0.9), 0, 1.1 * w(t, 1, 0.15))

	-- hanging heart-fruits
	for i, h in HEARTS do
		pose["Heart" .. i] = ang(h[3] * w(t, h[1], h[2]), 3 * w(t, 1, h[2] + 0.4), h[4] * w(t, h[1], h[2] + 0.25))
	end

	-- briar tendrils: ripple travels down the chain
	for i, ph in VINES do
		pose["Vine" .. i .. "a"] = ang(4 * w(t, 2, ph), 0, 4 * w(t, 2, ph + 0.25))
		pose["Vine" .. i .. "b"] = ang(7 * w(t, 2, ph - 0.12), 0, 7 * w(t, 2, ph + 0.13))
	end

	-- glow pulse: a slow heartbeat (0 = brightest)
	local hb = beat(t, 0)
	ctx.transparency("HeartwoodCore", 0.35 * (1 - hb))
	ctx.transparency("CrownCore", 0.35 * (1 - beat(t, 0.08)))
	ctx.transparency("CrownCoreB", 0.35 * (1 - beat(t, 0.08)))
	for i = 1, 6 do
		local b = beat(t, i * 0.11)
		ctx.transparency("HeartCore" .. i, 0.38 * (1 - b))
		ctx.transparency("HeartCore" .. i .. "B", 0.38 * (1 - b))
	end
	ctx.light("HeartLight", 1.3 + 0.6 * hb)
end

return M
