-- Treadmill motion: belt runs toward the back, rollers spin, display ramps.
local L = require(script.Parent.AnimLib)
local M = {}
M.Cycle = 4

local SPEED = 3 -- studs per second of belt travel
local GAP = 0.5 -- slat spacing

function M.Update(t, pose, ctx)
	pose.Belt = CFrame.new(0, 0, (t * SPEED) % GAP)
	local spin = L.ang((t * 360) % 360, 0, 0)
	pose.HubFR, pose.HubFL, pose.HubRR, pose.HubRL = spin, spin, spin, spin

	local lit = 1 + math.floor((t * 3) % 6)
	for i = 1, 6 do
		ctx.transparency("Bar" .. i, i <= lit and 0 or 0.85)
	end
	ctx.transparency("Led", (t * 2) % 1 < 0.5 and 0 or 0.7)
end

return M
