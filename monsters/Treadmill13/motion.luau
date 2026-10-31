-- Galaxy Treadmill motion (seamless 6 s loop).
-- Starfield belt glides to the back, planets circle the arch (1 orbit per
-- loop) while spinning, the moon laps its planet, a comet sweeps back and
-- forth along the arch, chase lights climb the arch, the console galaxy turns,
-- and at 4.2 s the keystone star goes SUPERNOVA (flare, burst, all flash).
local L = require(script.Parent.AnimLib)
local E = L.ease
local M = {}
M.Cycle = 6

local SPEED = 6.5 -- studs/s
local PERIOD = 1.5 -- 3-slat star pattern
local NOVA = 4.2

function M.Update(t, pose, ctx)
	local c = t % M.Cycle
	local nova = L.env(c, NOVA, 0.12, 0.35, 1.0, "expoOut", "cubicInOut")
	local wind = L.env(c, NOVA - 0.7, 0.6, 0.0, 0.12, "quadIn", "quadIn")

	pose.Belt = CFrame.new(0, 0, (t * SPEED) % PERIOD)
	local f = L.ang((t * 540) % 360, 0, 0)
	local r = L.ang((t * 720) % 360, 0, 0)
	pose.HubFR, pose.HubFL, pose.HubRR, pose.HubRL = f, f, r, r

	-- planets: one orbit per loop, each spinning on its own axis
	pose.Orbit = L.ang(0, -(t * 60) % 360, 0)
	pose.Planet1 = CFrame.new(0, 0.15 * L.wave(t, 1 / 3), 0) * L.ang(0, (t * 120) % 360, 0)
	pose.Planet2 = CFrame.new(0, 0.15 * L.wave(t, 1 / 3, 0.33), 0) * L.ang(0, (t * 180) % 360, 0)
	pose.Planet3 = CFrame.new(0, 0.15 * L.wave(t, 1 / 3, 0.66), 0) * L.ang(0, -(t * 120) % 360, 0)
	pose.Moon = L.ang(0, (t * 360) % 360, 0)

	-- keystone star: steady spin, winds back, then whirls on the supernova
	local whirl = 720 * E.cubicOut(L.clamp01((c - NOVA) / 1.4))
	pose.Star = CFrame.new(0, 0.12 * L.wave(t, 0.5) + 0.1 * nova, 0) * L.ang(0, 0, (-(t * 60) - whirl + 25 * wind) % 360)

	-- comet: sweeps right -> left -> right along the arch, 2 passes per loop
	local ph = (c / 3) % 1
	local u = ph < 0.5 and E.sineInOut(ph * 2) or E.sineInOut(2 - ph * 2)
	pose.Comet = L.ang(0, 0, 4 + 172 * u)

	-- console galaxy turns (2 turns per loop)
	pose.Galaxy = L.ang(0, 0, -(t * 120) % 360)

	-- supernova flare rays
	local fl = nova > 0.05 and (math.floor(c * 16) % 4 ~= 3) and nova or 0
	ctx.transparency("Nova1", 1 - fl)
	ctx.transparency("Nova2", 1 - fl)
	ctx.transparency("Nova3", 1 - fl * 0.8)
	ctx.transparency("Nova4", 1 - fl * 0.8)
	ctx.transparency("StarCore", 0.25 * (1 - nova) * L.wave01(t, 2))
	ctx.light("StarLight", 0.7 + 1.3 * nova)

	-- arch lights climb from both springs to the keystone (3 climbs per loop)
	local climb = (c * 0.5) % 1 * 8 -- 0..8 (beyond 6 = pause)
	for i = 0, 12 do
		local step = math.min(i, 12 - i) -- 0 at springs, 6 at the top
		local d = climb - step
		local on = (d >= 0 and d < 1.6) or nova > 0.3 or wind > 0.5 and (math.floor(c * 14) % 2 == 0)
		ctx.transparency("ArchF" .. i, on and 0 or 0.7)
		ctx.transparency("ArchB" .. i, on and 0 or 0.7)
	end

	-- chase lights stream to the back, flash on the nova
	local head = (t * 8 / 3) % 8
	for i = 1, 8 do
		local d = ((i - 1) - head) % 8
		local on = d < 2.5 or nova > 0.3
		ctx.transparency("ChR" .. i, on and 0 or 0.8)
		ctx.transparency("ChL" .. i, on and 0 or 0.8)
	end

	-- stardust bars twinkle, max out on the nova
	for i = 1, 8 do
		local l = 4.5 + 3 * L.wave(t, 1, i * 0.13) + 4 * nova
		ctx.transparency("Bar" .. i, i <= l and 0 or 0.85)
	end

	-- thrusters pulse in turn, blaze on the nova
	ctx.transparency("Thrust1", math.max(0, 0.45 - 0.4 * L.wave01(t, 2) - nova))
	ctx.transparency("Thrust2", math.max(0, 0.45 - 0.4 * L.wave01(t, 2, 0.5) - nova))
	ctx.transparency("HoodGlow", 0.5 - 0.5 * L.wave01(t, 0.5) * (1 - nova) - 0.5 * nova + 0.5 * 0)
	ctx.transparency("StormSpot", (t * 1.5) % 1 < 0.5 and 0 or 0.5)
	ctx.transparency("PostR", (t * 2) % 1 < 0.5 and 0 or 0.5)
	ctx.transparency("PostL", (t * 2 + 0.5) % 1 < 0.5 and 0 or 0.5)
	ctx.transparency("Led", (t * 2) % 1 < 0.5 and 0 or 0.7)

	if ctx.crossed(NOVA) then
		ctx.emit("Supernova", 60)
	end
end

return M
