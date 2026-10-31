-- Gold Treadmill motion: belt runs to the back, gold rollers + drive gears spin,
-- equaliser bars dance, gem buttons chase, crown jewel spins and flashes a shine burst.
local L = require(script.Parent.AnimLib)
local M = {}
M.Cycle = 4

local SPEED = 4 -- studs per second (base is 3)
local GAP = 0.5

function M.Update(t, pose, ctx)
	local c = t % M.Cycle
	pose.Belt = CFrame.new(0, 0, (t * SPEED) % GAP)

	-- rollers turn with the belt (top moves +Z = +X rotation): 1.5 rev/s
	local roll = L.ang((t * 540) % 360, 0, 0)
	pose.RollFR, pose.RollFL, pose.RollRR, pose.RollRL = roll, roll, roll, roll
	-- drive gears mesh: alternate direction, 1 rev/s
	for i = 1, 3 do
		local dir = (i % 2 == 0) and -1 or 1
		local g = L.ang((dir * t * 360) % 360, 0, 0)
		pose["Gear" .. i .. "R"], pose["Gear" .. i .. "L"] = g, g
	end

	-- crown jewel: slow spin, gentle float, quick extra twirl on the shine beat
	local twirl = L.env(c, 0.0, 0.35, 0.0, 0.6, "backOut", "cubicInOut")
	local spinY = (t * 90) % 360 + 360 * L.ease.cubicInOut(L.clamp01(c / 0.9))
	pose.Jewel = L.pa(0, 0.18 * L.wave(t, 0.5) + 0.25 * twirl, 0, 0, spinY % 360, 0)
	if ctx.crossed(0.05) then ctx.emit("Shine", 24) end
	if ctx.crossed(2.0) then ctx.emit("CoinBurst", 16) end
	ctx.light("JewelLight", 0.7 + 0.6 * twirl)

	-- rear trophy stars spin opposite ways (1 rev / 2 s)
	pose.StarR = L.ang(0, (t * 180) % 360, 0)
	pose.StarL = L.ang(0, (-t * 180) % 360, 0)

	-- equaliser bars: each bar its own wave (whole repeats per cycle)
	for i = 1, 8 do
		local lvl = 0.5 + 0.5 * math.sin((t * 2 + i * 0.37) * math.pi)
		lvl = 0.25 + 0.75 * lvl * (0.6 + 0.4 * math.abs(math.sin((t * 0.5 + i * 0.21) * math.pi)))
		ctx.transparency("Bar" .. i, 1 - lvl)
	end

	-- gem buttons chase 1-2-4-3 at 4 steps/s
	local step = math.floor((t * 4) % 4)
	local order = { 1, 2, 4, 3 }
	for k = 1, 4 do
		ctx.transparency("Gem" .. order[k], (k - 1 == step) and 0 or 0.55)
	end
	-- crown gems twinkle in turn
	for i = 1, 3 do
		ctx.transparency("CrownGem" .. i, ((t * 1.5 + i / 3) % 1) < 0.5 and 0 or 0.4)
	end
	-- rail gems: a sparkle runs toward the back along both rails
	local g = math.floor((t * 5) % 5) + 1
	for k = 1, 5 do
		local tr = (k == g) and 0 or 0.5
		ctx.transparency("RailGemR" .. k, tr)
		ctx.transparency("RailGemL" .. k, tr)
	end
	ctx.transparency("FaceGem", 0.3 + 0.3 * L.wave(t, 1, 0.5))
	ctx.transparency("Crest", 0.25 - 0.25 * L.wave(t, 1))
end

return M
