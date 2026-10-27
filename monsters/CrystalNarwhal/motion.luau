local L = require(script.Parent.AnimLib)
local M = {}
M.Cycle = 13
function M.Update(t, pose, ctx)
	pose.Jaw = L.ang(-14, 0, 0)
end
return M
