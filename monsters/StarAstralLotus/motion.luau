--!nocheck
-- Astral Lotus: a calm, clearly visible, seamless 9 s idle.
-- * the stalk sways softly, the flower head sways a little more and bobs
-- * all 22 petals BREATHE: one slow open/close per loop with a ripple running
--   around each ring (outer +-4..6, middle +-6..9, inner +-8..11 deg)
-- * the astral star hovers above the bloom, bobbing and turning one full
--   revolution per loop; three star motes orbit the other way with trails
-- * pads bob on the water, raised leaves + buds sway, pool stars twinkle
-- * BLOOM beat (peak 5.05 s): the petals gather shut (3.6-4.8 s, the star
--   sinks, glow dims), then burst wide open (backOut) - the star leaps up +1.3
--   and flashes, the light flares, two neon ripple rings flash across the
--   pool one after the other, 45 sparkles + 14 petals pop out of the flower;
--   everything settles back by ~8.4 s
-- Every wave uses whole cycles per loop and every envelope is 0 at both loop
-- ends, so t=0 == t=9.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, clamp = math.sin, math.clamp

local M = {}
M.Cycle = 9

local TAU = math.pi * 2
local BEAT = 5.05

-- n whole cycles per loop, phase in turns
local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	local gather = L.track(c, { { 3.6, 0 }, { 4.75, 1, "sineInOut" }, { 5.0, 0, "cubicIn" } })
	local open = L.track(c, { { 4.8, 0 }, { 5.3, 1, "backOut" }, { 6.2, 0.8, "sineInOut" }, { 8.3, 0, "sineInOut" } })
	local flash = L.track(c, { { 4.92, 0 }, { 5.08, 1, "quadOut" }, { 5.7, 0.75 }, { 7.6, 0, "sineInOut" } })
	local rise = L.track(c, { { 4.85, 0 }, { 5.45, 1, "backOut" }, { 6.6, 0.7, "sineInOut" }, { 8.5, 0, "sineInOut" } })
	local ripA = L.track(c, { { 5.0, 0 }, { 5.15, 1, "quadOut" }, { 6.0, 0, "quadIn" } })
	local ripB = L.track(c, { { 5.3, 0 }, { 5.45, 1, "quadOut" }, { 6.5, 0, "quadIn" } })

	local breathe = w(t, 1, 0.1)

	-- stalk + flower head
	pose.Crop = ang(1.2 * w(t, 1, 0.0), 0, 1.3 * w(t, 1, 0.25))
	pose.Bloom = pa(0, 0.12 * w(t, 2, 0.3) - 0.2 * gather + 0.3 * open, 0,
		2.0 * w(t, 1, 0.2) - 1.5 * gather, 3 * w(t, 1, 0.6), 1.8 * w(t, 1, 0.45))

	-- petals (+X = tip up = close)
	for k = 1, 8 do
		local r = w(t, 2, (k - 1) / 8)
		pose["PetalO" .. k] = ang(4 * breathe + 2.5 * r + 10 * gather - 14 * open, 0, 0)
		local r2 = w(t, 2, (k - 1) / 8 + 0.06)
		pose["PetalM" .. k] = ang(6 * breathe + 3 * r2 + 14 * gather - 18 * open, 0, 0)
	end
	for k = 1, 6 do
		local r = w(t, 2, (k - 1) / 6 + 0.12)
		pose["PetalI" .. k] = ang(8 * breathe + 3 * r + 13 * gather - 22 * open, 0, 0)
	end

	-- astral star: bob + one revolution per loop, leaps on the bloom
	pose.Star = pa(0, 0.35 * w(t, 2, 0.0) - 0.4 * gather + 1.3 * rise, 0,
		6 * w(t, 1, 0.3), 360 * c / M.Cycle, 8 * w(t, 1, 0.55))
	-- orbiting motes (counter-rotating, gently tilting orbit)
	pose.Orbit = pa(0, 0.3 * w(t, 2, 0.5) + 0.4 * open, 0, 7 * w(t, 1, 0.0), -360 * c / M.Cycle, 5 * w(t, 1, 0.25))

	-- pads, leaves, buds
	for i = 1, 3 do
		local ph = i * 0.29
		pose["Pad" .. i] = pa(0, 0.08 * w(t, 2, ph) + 0.12 * (i == 2 and ripB or ripA), 0, 0, 7 * w(t, 1, ph), 0)
	end
	pose.LeafA = ang(3 * w(t, 1, 0.15), 2 * w(t, 1, 0.5), 3 * w(t, 1, 0.4) - 2 * open)
	pose.LeafB = ang(3 * w(t, 1, 0.55), 2 * w(t, 1, 0.9), 3 * w(t, 1, 0.8) + 2 * open)
	pose.LeafC = ang(3 * w(t, 1, 0.75), 2 * w(t, 1, 0.2), 3 * w(t, 1, 0.05))
	pose.BudA = ang(4 * w(t, 2, 0.1), 0, 4 * w(t, 1, 0.35))
	pose.BudB = ang(4.5 * w(t, 2, 0.6), 0, 4 * w(t, 1, 0.85))

	-- glow
	ctx.transparency("StarCore", clamp((0.15 + 0.12 * w(t, 3, 0.2) + 0.3 * gather) * (1 - flash), 0, 0.6))
	for k = 1, 4 do
		ctx.transparency("StarTip" .. k, clamp((0.25 + 0.25 * w(t, 3, k * 0.25)) * (1 - flash), 0, 0.6))
	end
	for k = 1, 8 do
		ctx.transparency("PetalGlow" .. k, clamp(0.3 + 0.3 * w(t, 2, (k - 1) / 8 + 0.3) - 0.4 * flash, 0, 0.7))
	end
	ctx.transparency("PodSeed", clamp(0.2 + 0.2 * w(t, 2, 0.4) - 0.2 * flash, 0, 0.5))
	for i = 1, 8 do
		ctx.transparency("PoolStar" .. i, clamp(0.35 + 0.35 * w(t, 3, i * 0.37) - 0.5 * ripA, 0, 0.8))
	end
	for k = 1, 4 do
		ctx.transparency("RippleA" .. k, 1 - 0.8 * ripA)
		ctx.transparency("RippleB" .. k, 1 - 0.75 * ripB)
	end
	ctx.light("FlowerLight", clamp(1.1 + 0.2 * w(t, 2, 0.1) - 0.35 * gather + 0.9 * flash, 0, 2))
	ctx.light("PoolLight", clamp(0.9 + 0.15 * w(t, 2, 0.6) + 0.8 * ripA, 0, 2))

	if ctx.crossed(BEAT) then
		ctx.emit("BloomBurst", 45)
		ctx.emit("BloomPetals", 14)
	end
end

return M
