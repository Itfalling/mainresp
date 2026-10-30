--!nocheck
-- Nebula Pear Tree: a calm but clearly visible, seamless 10 s idle.
-- * the trunk sways softly; the canopy sways +-2.5 deg and breathes (bob),
--   the upper crown follows with a lag
-- * seven nebula pears swing on their stems in phase-offset ellipses
--   (+-10..12 deg) and slowly twist, their neon swirl stripes pulse in a
--   ripple running around the tree
-- * three comet stars orbit the crown (one lap per loop) on a gently tilting
--   orbit, leaving trails; leaf star specks twinkle
-- * NEBULA SURGE once per loop (peak 6.0 s): the crown draws in and the glow
--   dims (5.0-5.9 s), then a flash ripples around the pears one by one - each
--   pear kicks outward and spins a full swirl, the canopy puffs up (backOut),
--   the comets whip around an extra lap, both lights flare, and a burst of
--   nebula sparkles + falling sparks pops from the crown; all settles by ~9 s
-- Every wave uses whole cycles per loop and every envelope is 0 (or a whole
-- extra lap) at both loop ends, so t=0 == t=10.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, exp, clamp, rad = math.sin, math.exp, math.clamp, math.rad

local M = {}
M.Cycle = 10

local TAU = math.pi * 2
local SURGE = 6.0

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

-- per pear: deg (must match build.luau), swing cycles, phase
local PEARS = {
	{ 10, 2, 0.00 },
	{ 62, 3, 0.31 },
	{ 115, 2, 0.58 },
	{ 165, 3, 0.12 },
	{ 215, 2, 0.83 },
	{ 265, 3, 0.47 },
	{ 315, 2, 0.21 },
}

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	local gather = L.track(c, { { 5.0, 0 }, { 5.85, 1, "sineInOut" }, { 6.05, 0, "cubicIn" } })
	local flash = L.track(c, { { 5.95, 0 }, { 6.1, 1, "quadOut" }, { 6.8, 0.8 }, { 8.8, 0, "sineInOut" } })
	local puff = L.track(c, { { 5.95, 0 }, { 6.4, 1, "backOut" }, { 7.1, 0.7, "sineInOut" }, { 9.0, 0, "sineInOut" } })
	local lap = L.track(c, { { 5.9, 0 }, { 7.6, 1, "cubicInOut" } }) -- stays 1 to the loop end (one whole extra lap)

	-- trunk + canopy
	pose.Crop = ang(0.7 * w(t, 1, 0.6), 0, 0.8 * w(t, 1, 0.85))
	pose.Canopy = pa(0, 0.2 * w(t, 2, 0.1) - 0.3 * gather + 0.45 * puff, 0,
		2.4 * w(t, 1, 0.0), 1.2 * w(t, 1, 0.35), 2.6 * w(t, 1, 0.25))
	pose.CanopyTop = pa(0, 0.12 * w(t, 2, 0.3) - 0.15 * gather + 0.35 * puff, 0,
		1.6 * w(t, 1, 0.15), 1.5 * w(t, 1, 0.6), 1.7 * w(t, 1, 0.4))

	-- pears: elliptical swings, a twist, outward kick + full spin on the surge
	for i, f in PEARS do
		local a = rad(f[1])
		local ox, oz = sin(a), -math.cos(a)
		local delay = (i - 1) * 0.09
		local dt = c - (SURGE + delay)
		local kick = 0
		if dt > 0 then
			kick = exp(-1.5 * dt) * sin(6 * dt)
		end
		local spin = L.track(c, { { SURGE + delay - 0.05, 0 }, { SURGE + delay + 1.1, 360, "cubicOut" }, { M.Cycle, 360 } })
		local K = 14 * kick - 6 * gather
		local sw, sw2 = w(t, f[2], f[3]), w(t, f[2], f[3] + 0.25)
		pose["Pear" .. i] = ang(11 * sw - K * oz, 18 * w(t, 1, f[3] + 0.4) + spin, 10 * sw2 + K * ox)
		-- swirl stripes glow: ripple around + flash in sequence
		local pf = L.track(c, { { SURGE + delay - 0.05, 0 }, { SURGE + delay + 0.08, 1, "quadOut" }, { SURGE + delay + 0.9, 0.7 }, { 9.2, 0, "sineInOut" } })
		local idle = 0.3 + 0.2 * w(t, 2, (i - 1) / 7)
		local tr = clamp((idle + 0.35 * gather) * (1 - pf), 0, 0.75)
		ctx.transparency("PearCore" .. i, tr)
		ctx.transparency("PearCore" .. i .. "B", clamp(tr + 0.1, 0, 0.8))
	end

	-- comet orbit: one lap per loop + an extra whip lap on the surge
	pose.Orbit = pa(0, 0.4 * w(t, 2, 0.2) + 0.6 * puff, 0, 9 * w(t, 1, 0.0), -360 * (c / M.Cycle + lap), 7 * w(t, 1, 0.25))

	-- twinkles
	for i = 1, 10 do
		ctx.transparency("LeafStar" .. i, clamp(0.35 + 0.4 * w(t, 3, i * 0.29) - 0.6 * flash, 0, 0.85))
	end
	for i = 1, 3 do
		ctx.transparency("Comet" .. i, clamp(0.15 + 0.15 * w(t, 4, i / 3) - 0.3 * flash, 0, 0.4))
	end
	ctx.transparency("CrownStar", clamp(0.2 + 0.15 * w(t, 2, 0.5) - 0.3 * flash, 0, 0.5))

	ctx.light("CrownLight", clamp(1.2 + 0.2 * w(t, 2, 0.1) - 0.4 * gather + 0.8 * flash, 0, 2))
	ctx.light("PearLight", clamp(1.0 + 0.2 * w(t, 3, 0.4) - 0.4 * gather + 1.0 * flash, 0, 2))

	if ctx.crossed(SURGE) then
		ctx.emit("SurgeBurst", 70)
		ctx.emit("SurgeSparks", 40)
	end
end

return M
