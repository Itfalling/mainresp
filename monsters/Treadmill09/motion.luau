-- Cyber Treadmill motion: fast belt, rollers + tower fans spin, chase lights flow
-- to the back, laser scanner sweeps the deck, holo panels float and glitch-flicker,
-- holo cube tumbles, screen bars scroll with a scanner line, pods pulse.
local L = require(script.Parent.AnimLib)
local M = {}
M.Cycle = 4

local SPEED = 5 -- studs per second (gold is 4)
local GAP = 0.5

-- deterministic "glitch" pattern that repeats every cycle (seamless)
local function glitch(t, seed, rate, chance)
	local idx = math.floor((t % M.Cycle) * rate)
	local h = (idx * 73 + seed * 151) % 97
	return h < chance
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle
	pose.Belt = CFrame.new(0, 0, (t * SPEED) % GAP)

	local roll = L.ang((t * 720) % 360, 0, 0)
	pose.RollFR, pose.RollFL, pose.RollRR, pose.RollRL = roll, roll, roll, roll
	pose.FanR = L.ang((t * 900) % 360, 0, 0)
	pose.FanL = L.ang((-t * 900) % 360, 0, 0)

	-- laser scanner: 2 sweeps front->back->front per cycle, eased at the ends
	local sweep = 0.5 - 0.5 * math.cos(c / 2 * math.pi * 2)
	pose.Scan = CFrame.new(0, 0, -2.9 + 6.4 * sweep)
	ctx.transparency("ScanSheet", 0.72 + 0.12 * L.wave(t, 4))
	ctx.light("ScanLight", 0.5 + 0.4 * L.wave01(t, 2))

	-- screen scanner line slides across, bars scroll like a spectrum
	pose.ScreenScan = CFrame.new(-1.6 + 3.2 * (0.5 - 0.5 * math.cos(c * math.pi)), 0, 0)
	for i = 1, 10 do
		local lvl = 0.5 + 0.5 * math.sin((t * 3 - i * 0.3) * math.pi)
		ctx.transparency("Bar" .. i, 0.85 - 0.85 * lvl)
	end

	-- holo panels: float (whole waves per cycle) + glitch flicker
	pose.HoloC = L.pa(0, 0.12 * L.wave(t, 0.5), 0, 0, 0, 0)
	pose.HoloR = L.pa(0, 0.12 * L.wave(t, 0.5, 0.33), 0, 0, 6 * L.wave(t, 0.25), 0)
	pose.HoloL = L.pa(0, 0.12 * L.wave(t, 0.5, 0.66), 0, 0, -6 * L.wave(t, 0.25), 0)
	local gC, gR, gL = glitch(t, 1, 12, 10), glitch(t, 2, 12, 12), glitch(t, 3, 12, 12)
	-- scanlines roll upward through each panel
	for k = 1, 3 do
		local lit = math.floor((t * 3) % 3) + 1 == k
		ctx.transparency("HoloCS" .. k, gC and 0.95 or (lit and 0.15 or 0.6))
		ctx.transparency("HoloRS" .. k, gR and 0.95 or (lit and 0.15 or 0.6))
		ctx.transparency("HoloLS" .. k, gL and 0.95 or (lit and 0.15 or 0.6))
	end
	for i = 1, 5 do
		local lvl = 0.5 + 0.5 * math.sin((t * 1 + i * 0.4) * math.pi)
		ctx.transparency("HoloBar" .. i, gC and 0.9 or (0.6 - 0.5 * lvl))
	end
	ctx.transparency("HoloLine", ((t * 2) % 1 < 0.5) and 0.2 or 0.6)
	for _, nm in { "HoloR", "HoloL" } do
		local g = nm == "HoloR" and gR or gL
		ctx.transparency(nm .. "A", g and 0.9 or 0.3)
		ctx.transparency(nm .. "B", g and 0.9 or (((t * 1.5) % 1 < 0.5) and 0.3 or 0.7))
		ctx.transparency(nm .. "C", g and 0.9 or 0.25 * (1 + L.wave(t, 1)))
	end
	if ctx.crossed(1.0) or ctx.crossed(3.0) then ctx.emit("Glitch", 14) end

	-- holo cube tumbles
	pose.HoloCube = L.pa(0, 0.15 * L.wave(t, 0.5), 0, (t * 90) % 360, (t * 180) % 360, 0)
	ctx.light("HoloLight", 0.6 + 0.35 * L.wave01(t, 1))

	-- chase lights run toward the back (+Z), 2 lit, 8 steps/s
	local head = math.floor((t * 8) % 8) + 1
	for k = 1, 8 do
		local d = (head - k) % 8
		local tr = d == 0 and 0 or (d == 1 and 0.4 or 0.85)
		ctx.transparency("ChaseR" .. k, tr)
		ctx.transparency("ChaseL" .. k, tr)
	end
	-- thruster pods + emblem pulse, antenna tips blink
	for p = 1, 4 do
		local pt = 0.3 + 0.3 * L.wave(t, 1, p / 4)
		ctx.transparency("Pod" .. p .. "X", pt)
		ctx.transparency("Pod" .. p .. "Z", pt)
	end
	ctx.transparency("Emblem", 0.2 + 0.2 * L.wave(t, 2))
	ctx.transparency("TipR", ((t * 2) % 1) < 0.3 and 0 or 0.7)
	ctx.transparency("TipL", ((t * 2 + 0.5) % 1) < 0.3 and 0 or 0.7)
	-- gate progress bar fills up twice per cycle
	local fill = math.floor((c % 2) / 2 * 10)
	for k = 1, 8 do
		ctx.transparency("Prog" .. k, k <= fill and 0 or 0.85)
	end
	ctx.transparency("GateBack", 0.3 + 0.3 * L.wave(t, 2))
	ctx.transparency("KeyR", ((t * 3) % 1) < 0.5 and 0 or 0.6)
	ctx.transparency("KeyL", ((t * 3 + 0.5) % 1) < 0.5 and 0 or 0.6)
end

return M
