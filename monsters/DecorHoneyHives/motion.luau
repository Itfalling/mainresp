--!nocheck
-- Beehive Boxes: a calm, seamless 8 s loop. The hives and stand never move;
-- six block bees circle them on tilted orbits (hive bees 1 lap per loop,
-- the two outer scouts 1 lap the other way round... all at an easy pace),
-- each bobbing gently on its own phase, wings buzzing.
-- Every wave uses whole cycles per loop so the loop is seamless.
local L = require(script.Parent.AnimLib)
local ang = L.ang
local sin = math.sin

local M = {}
M.Cycle = 8

local TAU = math.pi * 2

-- n whole cycles per loop, phase in turns
local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

-- laps per loop, bob cycles, bob amp, bob phase, wing phase
local BEES = {
	{ 1, 2, 0.35, 0.00, 0.00 },
	{ 1, 3, 0.30, 0.37, 0.21 },
	{ 1, 2, 0.30, 0.71, 0.47 },
	{ 1, 3, 0.35, 0.15, 0.68 },
	{ 1, 2, 0.45, 0.56, 0.90 },
	{ 1, 2, 0.40, 0.83, 0.33 },
}

function M.Update(t, pose, ctx)
	local c = t % M.Cycle
	for i, b in BEES do
		local theta = 360 * b[1] * c / M.Cycle
		local bob = b[3] * w(t, b[2], b[4])
		pose["Bee" .. i] = ang(0, theta, 0) * CFrame.new(0, bob, 0)
		-- wings buzz (6 Hz = 48 cycles per loop)
		local f = 14 + 24 * w(t, 48, b[5])
		pose["Bee" .. i .. "WR"] = ang(0, 0, f)
		pose["Bee" .. i .. "WL"] = ang(0, 0, -f)
	end
end

return M
