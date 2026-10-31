-- Neon Runner motion: belt runs to the back with energy pulses racing over the
-- glowing seams, side strips chase toward the back, hubs/fans spin, woofers pump
-- at 120 bpm, equalizers dance, the runner dot laps the track map.
local L = require(script.Parent.AnimLib)
local M = {}
M.Cycle = 4

local SPEED = 4.5 -- studs/s (18 per cycle, period 0.5)
local GAP = 0.5
local N = 14

local function eqLevel(t, a, b, p)
	local s = 0.55 * L.wave01(t, a, p) + 0.45 * L.wave01(t, b, p * 1.7)
	return 1 + math.floor(s * 5.99)
end

function M.Update(t, pose, ctx)
	local off = (t * SPEED) % GAP
	pose.Belt = CFrame.new(0, 0, off)
	-- energy pulses travel along the seams at 9 studs/s, wavelength 4 (seamless: 9 per cycle)
	for i = 1, 16 do
		local z = -3.75 + (i - 1) * 0.5 + 0.25 + off
		local ph = ((z - 9 * t) / 4) % 1
		ctx.transparency("Seam" .. i, 0.75 - 0.75 * math.max(0, 1 - math.abs(ph - 0.5) * 4))
	end

	local spin = L.ang((t * 720) % 360, 0, 0)
	pose.HubFR, pose.HubFL, pose.HubRR, pose.HubRL = spin, spin, spin, spin
	pose.FanR = L.ang(0, 0, -(t * 540) % 360)
	pose.FanL = L.ang(0, 0, (t * 540) % 360)
	pose.BeaconR = L.ang(0, (t * 360) % 360, 0)
	pose.BeaconL = L.ang(0, -(t * 360) % 360, 0)

	-- side chase: two pulses per side running toward +Z, 2 laps per cycle
	local head = (t * N * 0.5) % N
	for i = 1, N do
		local d = (head - i) % 7
		local tr = d < 3 and d / 3 * 0.6 or 0.93
		ctx.transparency("ChaseR" .. i, tr)
		ctx.transparency("ChaseL" .. i, tr)
	end

	-- 120 bpm beat
	local bt = t % 0.5
	local kick = bt < 0.08 and 1 or math.max(0, 1 - (bt - 0.08) / 0.2)
	for _, s in { "R", "L" } do
		pose["Woofer" .. s .. "1"] = CFrame.new(0, 0, -0.12 * kick)
		pose["Woofer" .. s .. "2"] = CFrame.new(0, 0, -0.12 * kick)
		ctx.transparency("Cap" .. s, 0.5 - 0.5 * kick)
		ctx.transparency("Rail" .. s, 0.35 - 0.35 * kick)
	end
	ctx.transparency("ChevL", 0.5 - 0.5 * kick)
	ctx.transparency("ChevR", 0.5 - 0.5 * kick)
	ctx.transparency("TailBar", 0.4 - 0.4 * kick)
	ctx.light("ScreenGlow", 0.4 + 0.4 * kick)
	ctx.light("TailGlow", 0.5 + 0.6 * kick)

	-- equalizers (8 steps/s)
	local q = math.floor(t * 8) / 8
	for si, s in { "R", "L" } do
		for col = 1, 2 do
			local h = eqLevel(q, 0.75 + col * 0.5, 1.25 + si * 0.25, col * 0.31 + si * 0.17)
			for row = 1, 6 do
				ctx.transparency(("Eq%s%d_%d"):format(s, col, row), row <= h and 0 or 0.94)
			end
		end
	end

	-- runner dot laps the track once every 2 s (trail of 3)
	local pos = (t * N / 2) % N
	for i = 1, N do
		local d = (pos - (i - 1)) % N
		ctx.transparency("Trk" .. i, d < 1 and 0 or (d < 3 and 0.4 or 0.9))
	end
	local dist = math.floor(t * 1.5) % 6 + 1
	for k = 1, 6 do
		ctx.transparency("Dist" .. k, k <= dist and 0.1 or 0.94)
	end
	local lit = 1 + math.floor(t * 3) % 6
	for i = 1, 6 do
		ctx.transparency("Spd" .. i, i <= lit and 0 or 0.94)
	end
	ctx.transparency("LogoA", 0.3 * L.wave01(t, 0.5))
	ctx.transparency("LogoB", 0.3 * L.wave01(t, 0.5, 0.5))
end

return M
