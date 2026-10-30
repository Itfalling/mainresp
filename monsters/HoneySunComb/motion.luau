--!nocheck
-- Golden Comb Sunflower: calm but clearly visible, seamless 8 s idle.
-- * the tall stalk sways softly; the four big leaves flutter with lag; the
--   side sunflower nods and the closed bud bobs
-- * the big head slowly TURNS to follow the sun (+-26 deg yaw, one sweep per
--   loop) with a gentle nod; the petal corona spins 60 deg per loop (the
--   petals alternate in pairs, so the loop is seamless) and every petal
--   (resting in a shallow cup) breathes in a soft ripple
-- * the glowing honey cells pulse; honey drips; three bees circle the flower
--   (two around the stalk, one looping in front of the face), wings buzzing
-- * SUN BLOOM once per loop (peak 4.9 s): the petals cup shut and the head
--   dips (anticipation), then the head lifts to the sky, all 12 petals FLARE
--   from their cup to wide open (backOut), the honey cells flash, the gold light swells, a
--   burst of golden pollen + a shower of petals pops out and the bees race
--   an extra lap; everything settles by ~7.4 s
-- Whole wave cycles per loop, envelopes 0 at both ends: t=0 == t=8.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, clamp = math.sin, math.clamp

local M = {}
M.Cycle = 8

local TAU = math.pi * 2
local BLOOM = 4.9

-- n whole cycles per loop, phase in turns
local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

-- bees: base laps per loop, bob phase, wing phase
local BEES = { { 1, 0.0, 0.0 }, { 1, 0.4, 0.3 }, { 2, 0.7, 0.6 } }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- bloom envelopes (all 0 outside ~3.9..7.6 s)
	local cup = L.track(c, { { 3.9, 0 }, { 4.75, 1, "sineInOut" }, { 4.95, 0, "cubicIn" } })
	local flare = L.track(c, { { 4.8, 0 }, { 5.15, 1, "backOut" }, { 5.9, 0.85, "sineInOut" }, { 7.5, 0, "sineInOut" } })
	local flash = L.track(c, { { 4.85, 0 }, { 4.98, 1, "quadOut" }, { 5.6, 0.7 }, { 7.2, 0, "sineInOut" } })
	-- extra bee lap: 0 -> 1 across the bloom (one full turn = seamless)
	local lap = L.track(c, { { 4.7, 0 }, { 6.6, 1, "cubicInOut" } })

	-- stalk + leaves
	pose.Crop = ang(1.1 * w(t, 1, 0.6) - 1.2 * flare, 0, 1.4 * w(t, 1, 0.85))
	pose.Leaf1 = ang(5 * w(t, 2, 0.0), 0, 4 * w(t, 1, 0.2))
	pose.Leaf2 = ang(5 * w(t, 2, 0.2), 0, -4 * w(t, 1, 0.45))
	pose.Leaf3 = ang(4 * w(t, 2, 0.4), 0, 3.5 * w(t, 1, 0.7))
	pose.Leaf4 = ang(4 * w(t, 2, 0.6), 0, -3.5 * w(t, 1, 0.95))
	pose.BudR = ang(6 * w(t, 2, 0.15) + 4 * flare, 6 * w(t, 1, 0.3), 3 * w(t, 1, 0.55))
	pose.BudL = ang(4 * w(t, 2, 0.65), 0, 7 * w(t, 1, 0.1))

	-- head: slow sun-tracking turn + nod; dips before the bloom, looks up on it
	pose.Head = pa(0, 0.15 * w(t, 2, 0.1) + 0.25 * flare, 0,
		2.5 * w(t, 2, 0.35) - 6 * cup + 12 * flare, 26 * w(t, 1, 0.0), 3 * w(t, 1, 0.25))

	-- corona spins 60 deg per loop (petals alternate in pairs -> seamless)
	pose.Corona = ang(0, 0, -60 * c / M.Cycle)

	-- petals: soft breathing ripple, cup in, flare open
	for i = 1, 12 do
		local ph = (i % 2) * 0.5
		local breathe = 4 * w(t, 2, ph)
		pose["Petal" .. i] = ang(0, 12 + breathe + 20 * cup - 26 * flare, 0)
	end

	-- bees: orbit + bob + buzzing wings
	for n, b in BEES do
		local th = 360 * (b[1] * c / M.Cycle + lap)
		if n == 3 then
			pose.BeeOrbit3 = ang(0, 0, th)
		else
			pose["BeeOrbit" .. n] = ang(0, th, 0)
		end
		pose["Bee" .. n] = pa(0, 0.35 * w(t, 4, b[2]), 0, 6 * w(t, 2, b[2]), 0, 8 * w(t, 3, b[2] + 0.2))
		local flap = 32 * w(t, 64, b[3])
		pose["Bee" .. n .. "WingR"] = ang(0, 0, 10 + flap)
		pose["Bee" .. n .. "WingL"] = ang(0, 0, -10 - flap)
	end

	-- glowing honey cells pulse (0 = full glow), flash on the bloom
	for i = 1, 8 do
		local idle = 0.3 + 0.2 * w(t, 2, i * 0.13)
		ctx.transparency("CombGlow" .. i, clamp((idle + 0.25 * cup) * (1 - flash), 0, 0.7))
	end
	ctx.light("HeadLight", clamp(1.0 + 0.2 * w(t, 2, 0.1) - 0.35 * cup + 0.95 * flash, 0, 2))
	ctx.light("HoneyLight", clamp(0.6 + 0.15 * w(t, 1, 0.3) + 0.4 * flash, 0, 2))

	if ctx.crossed(BLOOM + 0.05) then
		ctx.emit("BloomBurst", 60)
		ctx.emit("PetalShower", 18)
		ctx.emit("HoneyDrip", 5)
	end
end

return M
