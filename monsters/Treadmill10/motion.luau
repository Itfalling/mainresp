-- Lava Treadmill motion: fastest belt so far with pulsing lava seams, lava flowing
-- along the side channels, stone gears grinding, magma vents pulsing with piston caps
-- popping in turn, volcano erupting once per loop, two rings of lava rocks orbiting.
local L = require(script.Parent.AnimLib)
local M = {}
M.Cycle = 4

local SPEED = 6 -- studs per second (cyber is 5)
local GAP = 0.5
local FLOW = 1.5 -- lava channel flow, studs/s
local FGAP = 1.0

local function pop(c, at)
	-- quick piston lift (anticipation dip, overshoot) and settle, 0..1
	local up = L.env(c, at, 0.12, 0.15, 0.55, "backOut", "bounceOut")
	local dip = L.env(c, at - 0.2, 0.15, 0, 0.05, "quadOut", "quadIn")
	return up - 0.15 * dip
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle
	pose.Belt = CFrame.new(0, 0, (t * SPEED) % GAP)
	local f = (t * FLOW) % FGAP
	pose.FlowR = CFrame.new(0, 0, f)
	pose.FlowL = CFrame.new(0, 0, f)

	-- lavafall drops slide down 2 studs/s (one 0.5 gap repeats)
	pose.Fall = CFrame.new(0, -((t * 2) % 0.5), 0)
	ctx.transparency("FallCore", 0.35 + 0.25 * L.wave(t, 2))
	ctx.transparency("Pool", 0.2 + 0.2 * L.wave(t, 1))

	-- lava seams: a heat wave travelling toward the back along the belt
	for i = 1, 8 do
		local w = 0.5 + 0.5 * math.sin((t * 2 - i * 0.25) * math.pi)
		ctx.transparency("Seam" .. i, 0.45 - 0.45 * w)
	end

	-- stone gears: alternate directions, 1 rev / 2 s
	for i = 1, 3 do
		local dir = (i % 2 == 0) and -1 or 1
		local g = L.ang((dir * t * 180) % 360, 0, 0)
		pose["Gear" .. i .. "R"], pose["Gear" .. i .. "L"] = g, g
	end

	-- magma vents: piston caps pop in turn, cores flare on each puff
	local order = { R1 = 0.4, L1 = 1.4, R2 = 2.4, L2 = 3.4 }
	for id, at in pairs(order) do
		local p = pop(c, at)
		pose["Cap" .. id] = L.pa(0, 0.75 * p, 0, 0, 25 * p * (id:sub(1, 1) == "R" and 1 or -1), 0)
		local glow = math.max(L.env(c, at, 0.08, 0.2, 0.6), 0)
		ctx.transparency("VentCore" .. id, 0.45 - 0.45 * glow - 0.1 * L.wave(t, 1))
	end
	if ctx.crossed(2.45) then ctx.emit("VentFireR", 18) end
	if ctx.crossed(3.45) then ctx.emit("VentFireL", 18) end

	-- volcano: rumble build-up then eruption at 1.0s
	local erupt = L.env(c, 1.0, 0.15, 0.3, 1.2, "expoOut", "cubicInOut")
	if ctx.crossed(1.0) then ctx.emit("Erupt", 40) end
	ctx.transparency("Crater", 0.25 - 0.25 * erupt + 0.1 * L.wave(t, 2))
	ctx.light("CraterLight", 0.8 + 1.0 * erupt)
	for k = 1, 3 do
		local w = 0.5 + 0.5 * math.sin((t * 1 - k * 0.3) * math.pi * 2)
		ctx.transparency("StreamA" .. k, 0.5 - 0.5 * math.max(w, erupt))
		ctx.transparency("StreamB" .. k, 0.5 - 0.5 * math.max(1 - w, erupt))
	end

	-- lava rocks orbit (inner ring 1 rev / 4 s, outer ring opposite), bob + flare on eruption
	pose.Orbit = L.pa(0, 0.2 * L.wave(t, 0.5) + 0.35 * erupt, 0, 0, (t * 90) % 360, 0)
	pose.Orbit2 = L.pa(0, 0.15 * L.wave(t, 0.5, 0.5), 0, 0, (-t * 90) % 360, 0)

	-- plinth cracks + pillar veins pulse in travelling waves
	for i = 1, 2 do
		local w = 0.5 + 0.5 * math.sin((t * 1 + i * 0.5) * math.pi * 2)
		ctx.transparency("CrackR" .. i, 0.6 - 0.6 * w)
		ctx.transparency("CrackL" .. i, 0.6 - 0.6 * w)
	end
	for j = 1, 3 do
		local w = 0.5 + 0.5 * math.sin((t * 1 - j * 0.33) * math.pi * 2)
		ctx.transparency("VeinR" .. j, 0.5 - 0.5 * w)
		ctx.transparency("VeinL" .. j, 0.5 - 0.5 * w)
	end
	for r = 1, 3 do
		ctx.transparency("Grille" .. r, 0.4 - 0.4 * L.wave01(t, 2, r / 3))
	end
	for j = 1, 3 do
		local w = L.wave01(t, 1, j / 3)
		ctx.transparency("SpireTipR" .. j, 0.4 - 0.4 * w)
		ctx.transparency("SpireTipL" .. j, 0.4 - 0.4 * w)
	end
	for j = 1, 3 do
		ctx.transparency("FaceCrack" .. j, 0.5 - 0.5 * math.max(L.wave01(t, 1, j / 3), erupt))
	end
	ctx.transparency("Fissure", 0.3 - 0.3 * L.wave(t, 0.5))
	ctx.transparency("Lip", 0.2 + 0.2 * L.wave(t, 1))
	ctx.light("BeltGlow", 0.45 + 0.2 * L.wave01(t, 2))

	-- heat gauge climbs with the eruption, needles twitch toward the red
	local lvl = 4 + math.floor(6 * erupt + 0.5 + 1.2 * L.wave01(t, 4))
	for i = 1, 10 do
		ctx.transparency("Bar" .. i, i <= lvl and 0 or 0.8)
	end
	local twitch = 6 * math.sin(t * math.pi * 6)
	pose.NeedleR = L.ang(0, 0, 40 - 90 * erupt + twitch)
	pose.NeedleL = L.ang(0, 0, -30 - 70 * erupt - twitch)
end

return M
