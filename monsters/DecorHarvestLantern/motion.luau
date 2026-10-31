-- Harvest Lantern Post: a calm, seamless 8 s loop.
-- * the lantern swings gently from its hook (side-to-side roll with a small
--   pitch a quarter-cycle behind, so it traces a soft ellipse)
-- * the candle flame flickers softly and the warm light breathes with it
-- Every wave uses a whole number of cycles per loop, so it loops perfectly.
local L = require(script.Parent.AnimLib)
local ang = L.ang

local M = {}
M.Cycle = 8

local TAU = math.pi * 2
local function w(t, n, ph)
	return math.sin(TAU * (n * t / M.Cycle + (ph or 0)))
end
local function flick(t)
	local f = 0.5 * w(t, 5, 0.1) + 0.3 * w(t, 11, 0.37) + 0.2 * w(t, 17, 0.71)
	return math.clamp(0.5 + 0.5 * f, 0, 1)
end

function M.Update(t, pose, ctx)
	-- two swings per loop, plus a little drift so it doesn't look mechanical
	local roll = 9 * w(t, 2, 0) + 1.5 * w(t, 1, 0.3)
	local pitch = 4 * w(t, 2, 0.25)
	pose.Lantern = ang(pitch, 0, roll)

	local f = flick(t)
	ctx.transparency("Flame", 0.25 * (1 - f) ^ 1.5)
	ctx.transparency("FlameTip", 0.45 * (1 - f))
	ctx.light("LanternLight", 0.85 + 0.35 * f)
end

return M
