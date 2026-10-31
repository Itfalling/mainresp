-- Turbo Treadmill motion: fast belt, racing wheels + turbo spin, pistons pump,
-- tach needle revs up and drops at each of 4 gear shifts per loop; on every shift
-- the exhausts backfire (flame + smoke burst) and the shift lights flash.
local L = require(script.Parent.AnimLib)
local E = L.ease
local M = {}
M.Cycle = 4

local SPEED = 6 -- studs/s (24 per cycle, period 1.0)
local PERIOD = 1.0

function M.Update(t, pose, ctx)
	local c = t % M.Cycle
	pose.Belt = CFrame.new(0, 0, (t * SPEED) % PERIOD)

	local w = L.ang((t * 900) % 360, 0, 0) -- 10 turns per cycle
	pose.WheelFR, pose.WheelFL, pose.WheelRR, pose.WheelRL = w, w, w, w
	pose.Turbo = L.ang(0, 0, -(t * 1440) % 360)

	-- pistons pump alternately, 3 Hz
	local p = 0.32 * L.wave(t, 3)
	pose.Piston1 = CFrame.new(0, p, 0)
	pose.Piston2 = CFrame.new(0, -p, 0)

	-- rev: each 1 s gear climbs 0 -> 1, then drops at the shift
	local g = c % 1
	local rev
	if g < 0.82 then
		rev = E.quadOut(g / 0.82)
	else
		local k = (g - 0.82) / 0.18
		rev = 1 - E.backOut(k) * 0.75
	end
	local gear = math.floor(c) + 1
	-- needle sweeps clockwise from 225 deg (0) to -45 deg (redline)
	pose.Needle = L.ang(0, 0, 135 - rev * 270)
	pose.Boost = L.ang(0, 0, 60 - rev * 120 + 6 * L.wave(t, 6))

	local lit = math.floor(rev * 5.5)
	local flash = rev > 0.92 and ((t * 12) % 1 < 0.5)
	for i = 1, 5 do
		local on = i <= lit
		if rev > 0.92 then on = flash end
		ctx.transparency("Shift" .. i, on and 0 or 0.85)
	end
	for k = 1, 4 do
		ctx.transparency("Gear" .. k, k <= gear and 0 or 0.85)
	end

	-- backfire right after each shift
	local bf = g >= 0.82 and g < 0.95
	ctx.transparency("FlameR", bf and 0 or 1)
	ctx.transparency("FlameL", bf and 0 or 1)
	ctx.transparency("AmberR", bf and 0 or 0.7)
	ctx.transparency("AmberL", bf and 0 or 0.7)
	for s = 0, 3 do
		if ctx.crossed(s + 0.83) then
			ctx.emit("BackfireR", 14)
			ctx.emit("BackfireL", 14)
			ctx.emit("SmokeR", 5)
			ctx.emit("SmokeL", 5)
		end
	end
	ctx.light("DashGlow", 0.3 + 0.8 * rev)
	ctx.transparency("TailR", 0.2 + 0.5 * (1 - rev))
	ctx.transparency("TailL", 0.2 + 0.5 * (1 - rev))
end

return M
