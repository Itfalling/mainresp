-- Apex Hyper Treadmill motion (8 s loop; every spin / wave / chase is a whole
-- number of repeats per loop, so it is seamless).
-- Always on: belt races to the back (7 studs/s) with plasma pulses riding the
-- seams even faster, turbine hubs spin, the two energy rings counter-rotate
-- around the tumbling plasma core, plasma cubes orbit, tesla arcs flicker,
-- 6 pistons pump in a rolling sequence, conduits + chevrons chase, energy
-- collars rise up the gantry, the hologram floats, flickers and its gauge spins.
-- HYPER SURGE (signature):
--   4.4 - 5.3  charge: rings wind BACK, pistons sink, core dims, arcs go wild
--   5.3        SURGE: rings whip an extra turn (backOut), core flashes, every
--              arc + chevron fires, pistons slam up, steam + particle burst,
--              hologram glitches
--   5.3 - 7.2  settle back into the cruise
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave
local M = {}
M.Cycle = 8
local C = 8
local function hz(n) return n / C end

local SPEED, GAP = 7, 0.5 -- 112 slat gaps per loop
local SURGE = 5.3

function M.Update(t, pose, ctx)
	local c = t % C
	local off = (t * SPEED) % GAP

	-- belt + hubs
	pose.Belt = CFrame.new(0, 0, off)
	local spin = ang(-(t * 720) % 360, 0, 0)
	pose.HubFR, pose.HubFL, pose.HubRR, pose.HubRL = spin, spin, spin, spin

	-- surge envelopes
	local charge = L.env(c, 4.4, 0.9, 0.0, 0.25, "cubicIn", "expoOut")
	local surge = L.env(c, SURGE, 0.08, 0.35, 1.4, "linear", "cubicOut")
	local extra = L.track(c, { { 0, 0 }, { 4.4, 0 }, { SURGE, -0.12, "cubicInOut" }, { 6.6, 1, "backOut" }, { 8, 1 } })

	-- counter-rotating energy rings (+2 / -3 turns per loop, plus the whip)
	pose.RingA = ang(0, 90 * c + 360 * extra, 0)
	pose.RingB = ang(0, -(135 * c + 360 * extra), 0)
	-- plasma core tumbles + bobs; orbit cubes
	pose.Core = pa(0, 0.12 * wave(t, hz(4)) - 0.15 * charge, 0, 45 * c, 90 * c + 180 * surge, 0)
	pose.Orbit1 = ang(0, 270 * c, 0)
	pose.Orbit2 = ang(0, -360 * c, 0)
	ctx.transparency("CoreShell", math.clamp(0.55 + 0.12 * wave(t, hz(16)) + 0.35 * charge - 0.5 * surge, 0, 0.95))
	ctx.transparency("CoreHeart", 0.25 * charge)
	ctx.light("CoreLight", 0.95 + 0.15 * wave(t, hz(16)) - 0.6 * charge + 0.85 * surge)

	-- tesla arcs: flicker pattern, wild while charging, all on at the surge
	for i = 1, 4 do
		local n = math.noise(math.floor(t * 14) * 0.37, i * 3.1)
		local on = n > (0.25 - 0.6 * charge) or surge > 0.5
		ctx.transparency("ArcA" .. i, on and 0 or 1)
		ctx.transparency("ArcB" .. i, on and 0 or 1)
	end

	-- pistons: rolling pump sequence (1 stroke per second), sink + slam on surge
	local slam = L.env(c, SURGE, 0.1, 0.3, 0.9, "backOut", "bounceOut")
	for i = 1, 3 do
		for s, side in { "R", "L" } do
			local ph = (i - 1) / 3 + (s - 1) / 6
			local y = 0.45 + 0.45 * wave(t, hz(8), ph)
			y = y * (1 - charge) * (1 - slam) - 0.3 * charge + 1.0 * slam
			pose["Piston" .. side .. i] = CFrame.new(0, y, 0)
			ctx.transparency("PistonTip" .. side .. i, y > 0.75 and 0 or 0.55)
		end
	end
	if ctx.crossed(SURGE) then
		ctx.emit("Burst", 60)
		ctx.emit("Steam", 24)
	end
	if ctx.crossed(1.0) or ctx.crossed(3.0) then
		ctx.emit("Steam", 6)
	end

	-- plasma pulses race along the belt seams (faster than the belt)
	local p1 = -4.2 + (t * 12.5) % 10 -- one sweep every 0.8 s
	local p2 = p1 - 5
	for i = 1, 17 do
		local z = -3.6 + (i - 1) * 0.5 + 0.25 + off
		local d = math.min(math.abs(z - p1), math.abs(z - p2), math.abs(z - p1 - 10))
		ctx.transparency("Seam" .. i, math.clamp(d / 1.2, 0, 1) * 0.6 * (1 - surge))
	end

	-- warp arches fire front-to-back (4 steps per beat), all on at the surge
	local ws = math.floor(t * 8) % 4 -- 64 steps per loop
	for k = 1, 3 do
		local tr = (ws == k - 1 or surge > 0.3) and 0 or (ws == k % 4 and 0.55 or 0.85)
		ctx.transparency("Warp" .. k .. "R", tr)
		ctx.transparency("Warp" .. k .. "L", tr)
		ctx.transparency("Warp" .. k .. "T", tr)
	end
	pose.Shards = pa(0, 0.1 * wave(t, hz(4)), 0, 0, -(45 * c + 90 * extra), 0)

	-- conduits chase backward
	local step = math.floor(t * 12) % 8 -- 96 steps per loop
	for i = 1, 8 do
		local d = (step - (i - 1)) % 8
		local tr = d == 0 and 0 or (d == 1 and 0.35 or (d == 2 and 0.65 or 0.85))
		tr = tr * (1 - surge)
		ctx.transparency("FlowR" .. i, tr)
		ctx.transparency("FlowL" .. i, tr)
	end

	-- chevrons chase outward from the centre
	local cs = math.floor(t * 6) % 3 -- 48 steps per loop
	for i = 1, 5 do
		local d = math.abs(i - 3)
		local tr = (d == cs or surge > 0.3) and 0 or 0.8
		ctx.transparency("ChevA" .. i, tr)
		ctx.transparency("ChevB" .. i, tr)
	end
	ctx.light("GantryLight", 0.7 + 0.6 * surge)

	-- energy collars rise up the gantry pylons and fade
	for k = 1, 3 do
		local ph = (t * 3 / C + (k - 1) / 3) % 1 -- 3 rises per loop each
		local y = ph * 4.9
		local tr = 1 - math.sin(ph * math.pi) ^ 0.6
		for _, side in { "R", "L" } do
			pose["Collar" .. side .. k] = CFrame.new(0, y, 0)
			local nm = "Collar" .. side .. k
			ctx.transparency(nm .. "a", tr)
			ctx.transparency(nm .. "b", tr)
			ctx.transparency(nm .. "c", tr)
			ctx.transparency(nm .. "d", tr)
		end
	end

	-- hologram: floats, flickers, glitches on the surge; gauge spins
	local glitch = surge > 0.05 and surge < 0.9 and (math.floor(t * 20) % 2 == 0)
	pose.Holo = pa((glitch and 0.12 or 0), 0.08 * wave(t, hz(4)), 0, 0, 2 * wave(t, hz(2)), 0)
	pose.HoloRing = ang(0, 0, -(t * 180) % 360)
	local fl = (math.noise(math.floor(t * 10) * 0.53, 7.7) > 0.45) and 0.25 or 0
	ctx.transparency("HoloPanel", glitch and 0.85 or (0.6 + fl))
	ctx.transparency("HoloSideR", glitch and 0.9 or (0.6 + fl * 0.5))
	ctx.transparency("HoloSideL", glitch and 0.9 or (0.6 + fl * 0.5))
	for i = 1, 4 do
		ctx.transparency("HoloEdge" .. i, glitch and 0.7 or fl)
	end
	ctx.transparency("HoloText1", (math.floor(t * 2) % 2 == 0) and 0 or 0.7)
	ctx.transparency("HoloText2", (math.floor(t * 2 + 1) % 2 == 0) and 0 or 0.7)
	local lit = 1 + math.floor((t * 6) % 8)
	if surge > 0.3 then lit = 8 end
	for i = 1, 8 do
		ctx.transparency("Bar" .. i, i <= lit and 0 or 0.85)
	end
	for i = 1, 3 do
		ctx.transparency("HoloBeam" .. i, 0.7 + 0.15 * wave(t, hz(16), i * 0.3) + (glitch and 0.15 or 0))
	end
	ctx.transparency("NozzleR", 0.15 * wave(t, hz(32)) + 0.15)
	ctx.transparency("NozzleL", 0.15 * wave(t, hz(32), 0.5) + 0.15)
end

return M
