-- Divine Treadmill motion (6 s loop; every wave / spin / chase is a whole
-- number of repeats per loop so it is seamless).
-- Always on: belt runs to the back, sunburst hubs spin, gold chase lights run
-- backward along the dais, light strips rise up the arch pillars, the glory
-- halo turns, the runner's halo spins + floats, light cubes orbit, clouds
-- bob, wings breathe-flap with the tips lagging, console bars + pulse.
-- BLESSING (signature, 2.9 - 4.9): wings fold down (anticipation), then sweep
-- up in a huge flap with overshoot, the glory halo whips an extra full turn,
-- gems flash, light burst, halo jumps; everything settles by 5.4.
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave
local M = {}
M.Cycle = 6
local C = 6
local function hz(n) return n / C end

local SPEED, GAP = 5, 0.5 -- 60 slat gaps per loop

function M.Update(t, pose, ctx)
	local c = t % C

	-- belt + hubs
	pose.Belt = CFrame.new(0, 0, (t * SPEED) % GAP)
	local spin = ang(-(t * 540) % 360, 0, 0)
	pose.HubFR, pose.HubFL, pose.HubRR, pose.HubRL = spin, spin, spin, spin

	-- signature envelopes
	local wind = L.env(c, 2.9, 0.5, 0.15, 0.35, "cubicInOut", "quadOut") -- fold down
	local flap = L.env(c, 3.45, 0.35, 0.45, 1.2, "backOut", "cubicInOut") -- big flap up
	local whip = L.track(c, { { 0, 0 }, { 3.4, 0 }, { 4.6, 1, "cubicInOut" }, { 6, 1 } })

	-- glory halo: 1 turn per loop + an extra whip turn on the beat
	pose.Glory = ang(0, 0, -(60 * c + 360 * whip))

	-- runner halo: 2 turns per loop, floating bob, hop on the beat
	local hop = L.env(c, 3.5, 0.25, 0.1, 0.9, "backOut", "bounceOut")
	pose.Halo = pa(0, 0.14 * wave(t, hz(3)) + 0.35 * hop, 0, 0, -(120 * c) % 360, 6 * hop * wave(t, hz(12)))

	-- light cubes orbit the glory halo (whole turns per loop)
	pose.Mote1 = ang(0, 0, 120 * c)
	pose.Mote2 = ang(0, 0, 120 * c)
	pose.Mote3 = ang(0, 0, -180 * c)
	pose.Mote4 = ang(0, 0, -180 * c)

	-- wings: soft breathing flap, tips lag behind; big flap on the beat
	local idle = 9 * wave(t, hz(4))
	local idleTip = 12 * wave(t, hz(4), -0.9)
	local w = idle - 16 * wind + 34 * flap
	local wt = idleTip - 14 * wind + 26 * L.env(c, 3.6, 0.4, 0.35, 1.3, "backOut", "cubicInOut") - 10 * flap * wave(t, hz(18))
	L.both(pose, "Wing", ang(0, -6 * flap + 4 * wave(t, hz(2)), w))
	L.both(pose, "WingTip", ang(0, -8 * flap, wt))

	-- clouds bob gently (never sink below the ground)
	for i = 1, 8 do
		pose["Cloud" .. i] = pa(0, 0.1 * wave(t, hz(2), i * 0.7), 0, 0, 5 * wave(t, hz(1), i), 0)
	end

	-- chase lights run toward the back with a short comet tail
	local step = math.floor(t * 10) % 8 -- 60 steps per loop
	for i = 1, 8 do
		local d = (step - (i - 1)) % 8
		local tr = d == 0 and 0 or (d == 1 and 0.45 or 0.88)
		ctx.transparency("ChaseR" .. i, tr)
		ctx.transparency("ChaseL" .. i, tr)
	end
	-- light rises up the arch pillars
	local rise = math.floor(t * 5) % 6 -- 30 steps per loop
	for i = 1, 5 do
		local d = (rise - (i - 1)) % 6
		local tr = d == 0 and 0 or (d == 1 and 0.5 or 0.9)
		ctx.transparency("RiseR" .. i, tr)
		ctx.transparency("RiseL" .. i, tr)
	end

	-- console: speed bars climb, pulse beats twice per second
	local lit = 1 + math.floor((t * 4) % 8)
	for i = 1, 8 do
		ctx.transparency("Bar" .. i, i <= lit and 0 or 0.85)
	end
	local beat = L.bounce(t, 1) -- 2 beats per second
	ctx.transparency("PulseH", 0.6 - 0.6 * beat)
	ctx.transparency("PulseV", 0.6 - 0.6 * beat)

	-- glory gems shimmer, flash on the beat
	local flash = L.env(c, 3.5, 0.08, 0.3, 0.8, "linear", "quadOut")
	for i = 1, 4 do
		ctx.transparency("GloryGem" .. i, math.max(0, 0.35 + 0.3 * wave(t, hz(6), i * 1.57) - flash))
	end
	ctx.light("GloryLight", 0.8 + 1.0 * flash)
	ctx.light("HaloLight", 0.7 + 0.2 * wave(t, hz(3)) + 0.8 * hop)
	if ctx.crossed(3.5) then
		ctx.emit("Burst", 45)
	end
end

return M
