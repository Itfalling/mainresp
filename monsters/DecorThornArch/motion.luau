--!nocheck
-- Bramble Archway: calm, seamless 8 s loop. The arch itself is still; the
-- five hanging briar tendrils sway gently like in a soft breeze, with the
-- lower segment trailing the upper one (ripple down the chain). Every wave
-- uses a whole number of cycles per loop, so t=0 == t=8.
local L = require(script.Parent.AnimLib)
local ang = L.ang
local sin = math.sin

local M = {}
M.Cycle = 8

local TAU = math.pi * 2
local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

-- {phase, cycles per loop, amplitude scale}
local VINES = {
	{ 0.00, 1, 1.0 },
	{ 0.22, 2, 0.8 },
	{ 0.47, 1, 1.1 },
	{ 0.68, 2, 0.85 },
	{ 0.85, 1, 0.95 },
}

function M.Update(t, pose, ctx)
	for i, vn in VINES do
		local ph, n, k = vn[1], vn[2], vn[3]
		-- sway mostly front/back (X) with a little side roll (Z)
		pose["Vine" .. i .. "a"] = ang(8 * k * w(t, n, ph), 0, 4.5 * k * w(t, n, ph + 0.27))
		pose["Vine" .. i .. "b"] = ang(12 * k * w(t, n, ph - 0.12), 0, 7 * k * w(t, n, ph + 0.15))
	end
end

return M
