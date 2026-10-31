-- Blue Treadmill motion: belt runs toward the back, rollers spin, 8-bar speed
-- ramp, calorie cells count up, running LED blinks, safety key swings.
local L = require(script.Parent.AnimLib)
local M = {}
M.Cycle = 4

local SPEED = 3.5 -- studs per second of belt travel (base: 3)
local GAP = 0.5 -- slat spacing

function M.Update(t, pose, ctx)
	pose.Belt = CFrame.new(0, 0, (t * SPEED) % GAP)
	local spin = L.ang((t * 450) % 360, 0, 0)
	pose.HubFR, pose.HubFL, pose.HubRR, pose.HubRL = spin, spin, spin, spin

	-- safety key sways with the runner's rhythm (2 swings per cycle)
	pose.Key = L.ang(10 * L.wave(t, 1), 0, 6 * L.wave(t, 0.5))

	local lit = 1 + math.floor((t * 4) % 8)
	for i = 1, 8 do
		ctx.transparency("Bar" .. i, i <= lit and 0 or 0.85)
	end
	local cal = math.floor((t * 1) % 4)
	for i = 1, 3 do
		ctx.transparency("Cal" .. i, i <= cal and 0 or 0.8)
	end
	ctx.transparency("Led", (t * 2) % 1 < 0.5 and 0 or 0.7)
end

return M
