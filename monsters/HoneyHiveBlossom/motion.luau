--!nocheck
-- Beehive Blossom Tree: a calm, clearly visible, seamless 9 s idle with a
-- once-per-loop "HONEY RUSH" beat.
-- * the trunk barely moves; the blossom canopy sways +-1.8 deg and breathes
--   (0.15 stud bob), the top tier trails with a little lag
-- * the hive swings gently on its stem like a pendulum (+-4 deg ellipse);
--   four honey-drop fruits swing on their stems, their neon cores pulse
-- * five block bees circle the hive (2 laps per loop, tilted orbits, each
--   bobbing on its own phase), two scouts circle the whole canopy (1 lap);
--   every bee's wings buzz (6 Hz flap) and leave a short golden trail
-- * HONEY RUSH (pop at 6.0 s): the hive starts to tremble and its entrance
--   glows hotter (4.9-5.95 s, the hive sinks a little), then POPS: a springy
--   hive kick, the entrance + fruit flash, both lights flare, the canopy
--   puffs up, the hive bees zoom (one extra lap, eased) and lift, and 45
--   honey sparks + 35 blossom petals burst out; everything settles by ~8.5 s
-- Every wave uses whole cycles per loop; envelopes are 0 at both loop ends.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, exp, clamp = math.sin, math.exp, math.clamp

local M = {}
M.Cycle = 9

local TAU = math.pi * 2
local POP = 6.0

-- n whole cycles per loop, phase in turns
local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

-- hive bees: laps per loop, bob phase, wing phase   (5 hive bees)
local HIVE_BEES = {
	{ 2, 0.00, 0.00 },
	{ 2, 0.37, 0.21 },
	{ 2, 0.71, 0.47 },
	{ 2, 0.15, 0.68 },
	{ 2, 0.56, 0.90 },
}
-- canopy scouts
local SCOUTS = { { 6, 1, 0.3, 0.33 }, { 7, 1, 0.8, 0.77 } }
-- fruits: swing cycles, phase, amp
local FRUITS = { { 2, 0.0, 9 }, { 3, 0.4, 8 }, { 2, 0.65, 9 }, { 3, 0.2, 8 } }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- beat envelopes (all exactly 0 outside 4.9 .. 8.6 s)
	local rumble = L.track(c, { { 4.9, 0 }, { 5.85, 1, "quadIn" }, { 6.05, 0, "quadOut" } })
	local sink = L.track(c, { { 4.9, 0 }, { 5.9, 1, "sineInOut" }, { 6.05, 0, "quadOut" } })
	local pop = L.track(c, { { 5.95, 0 }, { 6.2, 1, "backOut" }, { 6.9, 0.7, "sineInOut" }, { 8.5, 0, "sineInOut" } })
	local flash = L.track(c, { { 5.95, 0 }, { 6.05, 1, "quadOut" }, { 6.6, 0.75 }, { 8.0, 0, "sineInOut" } })
	-- the rush: hive bees gain ONE extra full lap (360 deg) between the pop
	-- and 8.55 s, so the offset is invisible again at the loop end
	local whirl = L.track(c, { { 5.95, 0 }, { 8.55, 1, "sineInOut" } })
	local dt = c - POP
	local kick = 0
	if dt > 0 then
		kick = exp(-1.8 * dt) * sin(7 * dt)
	end
	-- fast tremble (6 Hz = 54 cycles per loop)
	local tremble = w(t, 54, 0) * rumble

	-- trunk + canopy
	pose.Crop = ang(0.5 * w(t, 1, 0.6), 0, 0.5 * w(t, 1, 0.85))
	pose.Canopy = pa(0, 0.15 * w(t, 2, 0.1) + 0.35 * pop, 0,
		1.8 * w(t, 1, 0.0) + 0.8 * kick, 0.5 * w(t, 1, 0.35), 1.8 * w(t, 1, 0.25) - 0.6 * kick)
	pose.CanopyTop = pa(0, 0.08 * w(t, 2, 0.3) + 0.25 * pop, 0,
		1.2 * w(t, 1, 0.9) - 0.8 * kick, 0, 1.2 * w(t, 1, 0.15) + 0.6 * kick)

	-- the hive: pendulum swing + tremble + springy kick on the pop
	pose.Hive = pa(0, -0.25 * sink + 0.15 * pop, 0,
		4 * w(t, 2, 0.0) + 3 * tremble + 7 * kick,
		2 * w(t, 1, 0.4) + 4 * w(t, 54, 0.25) * rumble,
		3.5 * w(t, 2, 0.25) - 2.5 * tremble - 5 * kick)

	-- hive bees: laps + bob + zoom
	for i, b in HIVE_BEES do
		local theta = 360 * b[1] * c / M.Cycle + 360 * whirl
		local bob = 0.3 * w(t, 6, b[2]) + 0.9 * pop - 0.3 * sink
		pose["Bee" .. i] = ang(0, theta, 0) * CFrame.new(0, bob, 0)
	end
	for _, s in SCOUTS do
		local theta = 360 * s[2] * c / M.Cycle
		local bob = 0.5 * w(t, 4, s[3]) + 0.4 * pop
		pose["Bee" .. s[1]] = ang(0, theta, 0) * CFrame.new(0, bob, 0)
	end
	-- wings buzz (6 Hz), a bit faster-looking during the rush
	for i = 1, 7 do
		local ph = (i <= 5) and HIVE_BEES[i][3] or SCOUTS[i - 5][4]
		local f = 12 + 26 * w(t, 54, ph) + 8 * pop
		pose["Bee" .. i .. "WR"] = ang(0, 0, f)
		pose["Bee" .. i .. "WL"] = ang(0, 0, -f)
	end

	-- hanging honey-drop fruits
	for i, f in FRUITS do
		local sw = w(t, f[1], f[2])
		local sw2 = w(t, f[1], f[2] + 0.25)
		pose["Fruit" .. i] = ang(f[3] * sw + 6 * kick, 3 * w(t, 1, f[2] + 0.4), f[3] * 0.8 * sw2 - 5 * kick)
		local idle = 0.35 + 0.12 * w(t, 3, f[2] + i * 0.13)
		ctx.transparency("FruitCore" .. i, clamp(idle * (1 - flash), 0, 0.6))
	end

	-- hive entrance glow: breathes, heats up during the tremble, flashes
	local g = 0.35 + 0.12 * w(t, 2, 0.1)
	ctx.transparency("HiveGlow", clamp(g * (1 - rumble) * (1 - flash), 0, 0.6))

	-- lights
	ctx.light("HiveLight", clamp(1.1 + 0.15 * w(t, 2, 0.1) + 0.4 * rumble + 0.85 * flash, 0, 2))
	ctx.light("CanopyLight", clamp(0.85 + 0.1 * w(t, 1, 0.3) + 0.9 * flash, 0, 2))

	if ctx.crossed(POP) then
		ctx.emit("HoneyBurst", 45)
		ctx.emit("PetalBurst", 35)
	end
end

return M
