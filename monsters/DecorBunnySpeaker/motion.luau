-- Boombox Speaker Tower: the cones thump gently to a 120 bpm beat (bass on
-- every beat, mids on the off-beat, boombox speakers on a softer double-time).
local L = require(script.Parent.AnimLib)
local pa = L.pa
local M = {}
M.Cycle = 8

local function kick(t, hz, phase)
	local k = (t * hz + (phase or 0)) % 1
	return (1 - k) ^ 3
end

function M.Update(t, pose, ctx)
	pose.ConeBig = pa(0, 0, -0.28 * kick(t, 2), 0, 0, 0)
	pose.ConeMid = pa(0, 0, -0.2 * kick(t, 2, 0.5), 0, 0, 0)
	local b = 0.1 * kick(t, 4)
	pose.BoomL = pa(0, 0, -b, 0, 0, 0)
	pose.BoomR = pa(0, 0, -b, 0, 0, 0)
end
return M
