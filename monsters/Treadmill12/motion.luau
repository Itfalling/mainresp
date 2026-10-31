-- Storm Treadmill motion (seamless 6 s loop).
-- Belt races toward the back, turbines/fan/hubs spin, the radar sweeps and the
-- capacitors charge. Single strikes at 1.4 s and 2.9 s, then the finale at
-- 4.4 s: all four bolts flicker, the arc crackles between the coils, the cloud
-- flashes and rumbles, the turbines whip an extra turn and sparks burst.
local L = require(script.Parent.AnimLib)
local E = L.ease
local M = {}
M.Cycle = 6

local SPEED = 6 -- studs/s
local PERIOD = 1.0

-- strike windows: {start, duration, bolts...}
local STRIKES = {
	{ 0.35, 0.22, 3 },
	{ 1.4, 0.32, 1 },
	{ 2.9, 0.32, 4 },
	{ 3.25, 0.25, 2 },
	{ 4.4, 0.75, 1, 2, 3, 4 },
	{ 5.45, 0.2, 2 },
}
local BIG = 4.4

local function flick(c, start, dur)
	local d = c - start
	if d < 0 or d > dur then
		return false
	end
	-- on / off / on flicker, ~24 changes per second
	-- 75 ms on / 25 ms off flicker
	return (d * 10 + 0.3) % 1 < 0.72
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	pose.Belt = CFrame.new(0, 0, (t * SPEED) % PERIOD)
	local f = L.ang((t * 540) % 360, 0, 0) -- 1.5 rev/s
	local r = L.ang((t * 720) % 360, 0, 0)
	pose.HubFR, pose.HubFL, pose.HubRR, pose.HubRL = f, f, r, r

	-- finale envelope + anticipation (charge-up hum)
	local big = L.env(c, BIG, 0.08, 0.5, 0.9, "expoOut", "cubicInOut")
	local charge = L.clamp01(c / BIG)
	if c > BIG then
		charge = 1 - L.clamp01((c - BIG) / 1.0)
	end

	-- turbines: 2 rev/s plus an eased extra turn after the big strike
	local whip = 360 * E.cubicOut(L.clamp01((c - BIG) / 1.2))
	pose.TurbR = L.ang((t * 720 + whip) % 360, 0, 0)
	pose.TurbL = L.ang((-(t * 720) - whip) % 360, 0, 0)
	pose.Fan = L.ang(0, 0, (-(t * 540) - whip) % 360)
	pose.Radar = L.ang(0, 0, -(t * 240) % 360)

	-- cloud: slow heave, shudder on strikes
	local shake = 0
	for _, s in STRIKES do
		shake = math.max(shake, L.env(c, s[1], 0.04, s[2] * 0.5, 0.35, "quadOut", "quadIn"))
	end
	local nx = 0.12 * shake * math.sin(t * 71)
	local nz = 0.1 * shake * math.sin(t * 53 + 1)
	pose.Cloud = CFrame.new(nx, 0.15 * L.wave(t, 1 / 3) - 0.2 * big, nz) * L.ang(1.5 * L.wave(t, 1 / 6), 0, 2 * L.wave(t, 1 / 3, 0.25) + 2 * shake * math.sin(t * 40))

	pose.Wisps = CFrame.new(0, 0.2 * L.wave(t, 1 / 3, 0.5), 0) * L.ang(0, (t * 60) % 360, 0)
	ctx.transparency("WispBolt1", flick(c, 0.9, 0.2) and 0 or 1)
	ctx.transparency("WispBolt2", flick(c, 3.8, 0.2) and 0 or 1)

	-- bolts
	local boltOn = { false, false, false, false }
	for _, s in STRIKES do
		if flick(c, s[1], s[2]) then
			for i = 3, #s do
				boltOn[s[i]] = true
			end
		end
	end
	for n = 1, 4 do
		local tr = boltOn[n] and 0 or 1
		for k = 1, 4 do
			ctx.transparency(("Bolt%d_%d"):format(n, k), tr)
		end
		ctx.transparency(("Bolt%d_f"):format(n), boltOn[n] and (math.floor(c * 30) % 2 == 0 and 0 or 1) or 1)
		ctx.transparency("RodTip" .. n, boltOn[n] and 0 or 0.35 + 0.25 * L.wave01(t, 1, n / 4))
	end
	local anyBolt = boltOn[1] or boltOn[2] or boltOn[3] or boltOn[4]

	-- arc between the coils: little crackles plus the finale
	local arcOn = flick(c, BIG + 0.05, 0.8) or flick(c, 0.7, 0.14) or flick(c, 2.2, 0.14) or flick(c, 3.7, 0.18) or flick(c, 5.4, 0.12)
	for k = 1, 6 do
		ctx.transparency("Arc" .. k, arcOn and ((math.floor(c * 40) + k) % 4 == 0 and 1 or 0) or 1)
	end
	pose.Arc = CFrame.new(0, arcOn and 0.12 * math.sin(t * 90) or 0, arcOn and 0.1 * math.sin(t * 67) or 0) * L.ang(arcOn and 4 * math.sin(t * 83) or 0, 0, 0)
	ctx.transparency("CoilR", (arcOn or charge > 0.95) and 0 or 0.5 - 0.4 * charge)
	ctx.transparency("CoilL", (arcOn or charge > 0.95) and 0 or 0.5 - 0.4 * charge)

	-- cloud flashes
	for k = 1, 4 do
		local on = anyBolt and (boltOn[k] or big > 0.3) and math.floor(c * 20 + k) % 2 == 0
		ctx.transparency("Flash" .. k, on and 0.35 or 1)
	end
	ctx.light("StormLight", anyBolt and 2 or 0.3 + 0.5 * big)

	-- capacitor gauges fill as the storm charges, drain after the finale
	local lvl = charge * 6
	for k = 1, 6 do
		local on = k <= lvl + 0.01 or (charge > 0.97 and math.floor(t * 8) % 2 == 0)
		ctx.transparency("CapR" .. k, on and 0 or 0.85)
		ctx.transparency("CapL" .. k, on and 0 or 0.85)
	end
	-- storm level bars follow the charge with a ripple
	for i = 1, 8 do
		local l = charge * 8 + 0.8 * L.wave(t, 2, i * 0.1)
		ctx.transparency("Bar" .. i, (i <= l or big > 0.4) and 0 or 0.85)
	end

	-- chase lights race to the back (4 laps), strobe on the finale
	local head = (t * 16 / 3) % 8
	for i = 1, 8 do
		local d = ((i - 1) - head) % 8
		local on = big > 0.2 and (math.floor(c * 12) % 2 == 0) or d < 2
		ctx.transparency("ChR" .. i, on and 0 or 0.8)
		ctx.transparency("ChL" .. i, on and 0 or 0.8)
	end

	-- radar blips light as the sweep passes them
	local sweep = (t * 240) % 360 -- clockwise from 12 o'clock
	for k, a in { 42, 290, 168 } do
		local d = (sweep - a) % 360
		ctx.transparency("Blip" .. k, d < 90 and (d / 90) * 0.9 or 1)
	end
	ctx.transparency("Led", (t * 2) % 1 < 0.5 and 0 or 0.7)
	ctx.transparency("AntR", (t * 3) % 1 < 0.3 and 0 or 0.5)
	ctx.transparency("AntL", (t * 3 + 0.5) % 1 < 0.3 and 0 or 0.5)

	if ctx.crossed(1.4) then ctx.emit("StrikeR", 25) end
	if ctx.crossed(5.45) then ctx.emit("StrikeL", 15) end
	if ctx.crossed(3.25) then ctx.emit("StrikeL", 25) end
	if ctx.crossed(BIG) then
		ctx.emit("StrikeR", 45)
		ctx.emit("StrikeL", 45)
		ctx.emit("ArcSpark", 40)
	end
	if ctx.crossed(0.7) or ctx.crossed(2.2) or ctx.crossed(3.7) then ctx.emit("ArcSpark", 12) end
end

return M
