-- Savanna Signpost: the hanging arrow boards swing gently in the savanna wind.
-- A soft base sway (0.5 Hz) is swelled by one slow gust per 8 s loop; each
-- board has its own phase so they never move in lockstep. Bead strings
-- follow with a little lag. Everything uses absolute t with frequencies that
-- are multiples of 1/8 Hz, so the loop is seamless.
local L = require(script.Parent.AnimLib)
local ang, wave = L.ang, L.wave
local M = {}
M.Cycle = 8

local function gust(t)
	-- 0..1, peaks once per loop
	return 0.5 - 0.5 * math.cos(2 * math.pi * (t / 8))
end

function M.Update(t, pose, ctx)
	local g = gust(t)
	local amp = 5 + 7 * g
	pose.BoardA = ang(amp * wave(t, 0.5, 0.0) + 3 * g, 0, 1.2 * wave(t, 0.25, 0.3))
	pose.BoardB = ang(amp * 0.95 * wave(t, 0.5, 0.33) + 3 * g, 0, 1.0 * wave(t, 0.25, 0.7))
	pose.BoardC = ang(amp * 0.85 * wave(t, 0.5, 0.62) + 2.5 * g, 0, 1.0 * wave(t, 0.25, 0.1))
	local b = 6 + 8 * g
	pose.BeadR = ang(b * wave(t, 0.5, 0.15) + 4 * g, 0, 4 * wave(t, 0.375, 0.2))
	pose.BeadL = ang(b * wave(t, 0.5, 0.45) + 4 * g, 0, 4 * wave(t, 0.375, 0.6))
end
return M
