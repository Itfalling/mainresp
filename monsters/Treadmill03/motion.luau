-- Sport Treadmill motion: faster belt, spinning sport rims, console cooling
-- fan, 8-bar speed ramp, double-beat heart light, lap counter, LED, key swing.
local L = require(script.Parent.AnimLib)
local M = {}
M.Cycle = 4

local SPEED = 4 -- studs per second of belt travel
local GAP = 0.5

function M.Update(t, pose, ctx)
	pose.Belt = CFrame.new(0, 0, (t * SPEED) % GAP)
	local spin = L.ang((t * 540) % 360, 0, 0) -- 6 turns per cycle
	pose.HubFR, pose.HubFL, pose.HubRR, pose.HubRL = spin, spin, spin, spin
	pose.Fan = L.ang(0, 0, -(t * 630) % 360) -- 7 turns per cycle
	pose.Key = L.ang(12 * L.wave(t, 1), 0, 7 * L.wave(t, 0.5))

	-- speed meter: ramps up then holds at full
	local c = t % M.Cycle
	local lit = math.min(8, 1 + math.floor(c * 3))
	for i = 1, 8 do
		ctx.transparency("Bar" .. i, i <= lit and 0 or 0.85)
	end
	-- heart: lub-dub every 0.8 s
	local h = t % 0.8
	ctx.transparency("Heart", (h < 0.1 or (h > 0.2 and h < 0.3)) and 0 or 0.75)
	-- lap counter: one cell runs around the square every second
	local lap = 1 + math.floor((t * 4) % 4)
	for i = 1, 4 do
		ctx.transparency("Lap" .. i, i == lap and 0 or 0.8)
	end
	ctx.transparency("Led", (t * 2) % 1 < 0.5 and 0 or 0.7)
end

return M
