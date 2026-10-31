-- Steel Pro Treadmill motion: belt runs toward the back, hubs + motor fan spin,
-- bar graph scrolls, heart pulses (lub-dub) with an ECG sweep, safety key swings.
local L = require(script.Parent.AnimLib)
local M = {}
M.Cycle = 4

local SPEED = 3.5 -- studs/s (14 per cycle: whole number of 1.0 periods)
local PERIOD = 1.0 -- two-tone slat pattern repeats every 1.0 studs
local PROFILE = { 1, 2, 3, 3, 4, 5, 4, 3, 2, 2, 3, 4, 5, 5, 3, 2 }
local NECG = 11

function M.Update(t, pose, ctx)
	pose.Belt = CFrame.new(0, 0, (t * SPEED) % PERIOD)
	local spin = L.ang((t * 540) % 360, 0, 0) -- 6 turns per cycle
	pose.HubFR, pose.HubFL, pose.HubRR, pose.HubRL = spin, spin, spin, spin
	pose.Fan = L.ang(0, 0, -(t * 720) % 360)

	-- scrolling bar graph (16 steps per cycle)
	local step = math.floor(t * 4) % 16
	for col = 1, 10 do
		local h = PROFILE[(col + step - 1) % 16 + 1]
		for row = 1, 5 do
			ctx.transparency(("Cell%d_%d"):format(col, row), row <= h and 0 or 0.88)
		end
	end

	-- heartbeat at 1 Hz: lub (0.0) + dub (0.2)
	local b = t % 1
	local beat = (b < 0.12 or (b > 0.2 and b < 0.3)) and 0 or 0.55
	for i = 1, 5 do
		ctx.transparency("Heart" .. i, beat)
	end
	ctx.transparency("GripR", beat)
	ctx.transparency("GripL", beat)
	-- ECG sweep: head runs across once per beat, short glowing tail
	local head = b * (NECG + 4)
	for j = 1, NECG do
		local d = head - j
		ctx.transparency("Ecg" .. j, (d >= 0 and d < 4) and (d / 4) * 0.6 or 0.92)
	end

	local prog = math.floor(t * 0.75) % 3 + 1
	for k = 1, 3 do
		ctx.transparency("Prog" .. k, k == prog and 0 or 0.8)
	end
	ctx.transparency("Status", (t * 2) % 1 < 0.5 and 0 or 0.75)

	-- safety key jiggles from the running
	pose.Key = L.ang(14 * L.wave(t, 1), 0, 6 * L.wave(t, 0.5, 0.25))
end

return M
