-- Great Lantern Tree: a SUBTLE, seamless 8 s idle for a static crop.
-- * the hanging jack-o'-lanterns sway gently on their vines (each its own bone,
--   pivot at the vine top, +-6..8 deg, small elliptical paths, phase-offset)
-- * the crown breathes / sways very slightly (+-1..1.5 deg)
-- * the carved faces flicker softly like candles (transparency 0..0.3) and the
--   warm light flickers with them
-- Every wave uses a whole number of cycles per loop, so it loops perfectly.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa

local M = {}
M.Cycle = 8

local TAU = math.pi * 2
-- n whole cycles per loop, phase in turns
local function w(t, n, ph)
	return math.sin(TAU * (n * t / M.Cycle + (ph or 0)))
end
-- soft candle flicker in [0,1] (mostly bright, occasional gentle dips)
local function flick(t, ph)
	local f = 0.5 * w(t, 5, ph) + 0.3 * w(t, 11, ph * 1.7 + 0.2) + 0.2 * w(t, 17, ph * 2.3 + 0.5)
	return math.clamp(0.5 + 0.5 * f, 0, 1)
end

local SWING = {
	-- cycles per loop, phase, pitch amp, roll amp
	{ 2, 0.00, 7, 5 },
	{ 3, 0.31, 6, 6 },
	{ 2, 0.58, 6, 7 },
	{ 3, 0.12, 7, 5 },
	{ 2, 0.83, 7, 6 },
	{ 3, 0.47, 6, 6 },
}

function M.Update(t, pose, ctx)
	-- crown: slow breathing sway, one cycle per loop
	pose.Canopy = pa(0, 0.06 * w(t, 2, 0.1), 0, 1.0 * w(t, 1, 0), 0.5 * w(t, 1, 0.4), 1.3 * w(t, 1, 0.25))

	-- lanterns: gentle elliptical swing on the vine
	for i, s in SWING do
		pose["Lantern" .. i] = ang(s[3] * w(t, s[1], s[2]), 0, s[4] * w(t, s[1], s[2] + 0.25))
	end

	-- candle flicker on the carved faces (eyes + grin), different per lantern
	local total = 0
	for i = 1, 6 do
		local f = flick(t, i * 0.137)
		total += f
		local tr = 0.3 * (1 - f) ^ 1.5
		ctx.transparency("LanternFace" .. i .. "L", tr)
		ctx.transparency("LanternFace" .. i .. "R", tr)
		ctx.transparency("LanternFace" .. i .. "M", tr * 0.8)
	end
	for i = 1, 4 do
		local tr = 0.3 * (1 - flick(t, 0.41 + i * 0.211)) ^ 1.5
		ctx.transparency("SunkFace" .. i .. "L", tr)
		ctx.transparency("SunkFace" .. i .. "R", tr)
		ctx.transparency("SunkFace" .. i .. "M", tr * 0.8)
	end
	local tt = 0.3 * (1 - flick(t, 0.77)) ^ 1.5
	ctx.transparency("TopFaceL", tt)
	ctx.transparency("TopFaceR", tt)
	ctx.transparency("TopFaceM", tt * 0.8)

	-- warm light breathes with the average flicker (1.15 .. 1.65)
	ctx.light("LanternLight", 1.15 + 0.5 * (total / 6))
end

return M
