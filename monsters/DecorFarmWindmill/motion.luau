--!nocheck
-- Farm Windmill motion: the sails turn slowly and steadily, one full turn per
-- 10 s loop (seamless). Everything else stays still.
local L = require(script.Parent.AnimLib)
local ang = L.ang

local M = {}
M.Cycle = 10

function M.Update(t, pose, ctx)
	local c = t % M.Cycle
	pose.Sails = ang(0, 0, -360 * c / M.Cycle)
end

return M
