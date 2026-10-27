--!nocheck
local L = require(script.Parent.AnimLib)
local M = {}
M.Cycle = 15
function M.Update(t, pose, ctx)
	pose.Body = L.pa(0, 0.3 * L.wave(t, 0.4), 0, 0, 0, 0)
end
return M
