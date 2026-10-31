-- Wooden Garden Treadmill motion: wooden belt slats run toward the back, cart
-- wheels roll, the hood gears mesh (8:6 teeth -> 3:4 speed), the pinwheel
-- whirls, flowers sway in a breeze, sprout bars grow
-- one by one and the sun LED glows.
local L = require(script.Parent.AnimLib)
local M = {}
M.Cycle = 4

local SPEED = 4
local GAP = 0.5

function M.Update(t, pose, ctx)
	pose.Belt = CFrame.new(0, 0, (t * SPEED) % GAP)
	local spin = L.ang((t * 540) % 360, 0, 0)
	pose.HubFR, pose.HubFL, pose.HubRR, pose.HubRL = spin, spin, spin, spin

	-- gears: A turns 1.5 turns per cycle, B (6 teeth) turns the other way 2 turns
	pose.GearA = L.ang(0, 0, (t * 135) % 360)
	pose.GearB = L.ang(0, 0, -(t * 180) % 360 + 15)
	pose.Pinwheel = L.ang(0, 0, -(t * 450) % 360) -- 5 turns per cycle

	-- breeze: flowers sway with staggered phase, gust peaks once per cycle
	local gust = 0.6 + 0.4 * L.wave01(t, 0.25)
	for i = 1, 6 do
		local ph = i * 0.13
		pose["Flower" .. i] = L.ang(10 * gust * L.wave(t, 0.5, ph), 0, 12 * gust * L.wave(t, 0.75, ph + 0.3))
	end

	-- sprout bars grow one by one, hold, reset (once per cycle)
	local c = t % M.Cycle
	local grown = math.min(8, math.floor(c * 2.6))
	for i = 1, 8 do
		ctx.transparency("Bar" .. i, i <= grown and 0 or 0.85)
		ctx.transparency("Bud" .. i, i <= grown and 0 or 0.9)
	end
	ctx.transparency("Sun", 0.15 + 0.35 * L.wave01(t, 0.5))
end

return M
