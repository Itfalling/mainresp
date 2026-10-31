--!nocheck
-- Overgrown Jungle Arch motion (8 s seamless loop, calm).
-- The three hanging pitcher plants sway gently on their tendrils, each on
-- its own phase (a slow fore/aft swing plus a slower side drift), and the
-- three vine strands drift a little with them. All waves use frequencies
-- that are multiples of 1/8 Hz, so the loop is seamless.
local L = require(script.Parent.AnimLib)
local ang, wave = L.ang, L.wave

local M = {}
M.Cycle = 8

-- { fore/aft amp, side amp, phase }
local PITCHERS = { { 5, 3.5, 0.0 }, { 4, 3, 0.33 }, { 5.5, 4, 0.62 } }
local STRANDS = { { 7, 4, 0.15 }, { 8, 5, 0.5 }, { 6, 4, 0.8 } }

function M.Update(t, pose, ctx)
	for i, p in PITCHERS do
		local fx = p[1] * wave(t, 0.25, p[3]) + 1.0 * wave(t, 0.5, p[3] + 0.2)
		local fz = p[2] * wave(t, 0.125, p[3] + 0.25)
		pose["Pitcher" .. i] = ang(fx, 0.8 * wave(t, 0.125, p[3]), fz)
	end
	for i, s in STRANDS do
		local fx = s[1] * wave(t, 0.25, s[3])
		local fz = s[2] * wave(t, 0.375, s[3] + 0.4)
		pose["Strand" .. i] = ang(fx, 0, fz)
	end
end

return M
