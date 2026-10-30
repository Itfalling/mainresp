--!nocheck
-- Marsh Moon Pod Tree: a calm but clearly visible, seamless 9 s idle.
-- * the dark trunk barely moves; the canopy sways +-1.6 deg and breathes;
--   the hanging swamp moss strands ripple on their own bones
-- * six moon pods swing on their stems (+-8 deg, phase-offset ellipses) and
--   their husk halves breathe open and shut (4..14 deg) so the glowing moon
--   core peeks through the seam; the cores pulse softly with the opening
-- * the crescent moon on the crown bobs and turns slowly (+-30 deg yaw)
-- * two moon moths orbit the tree in opposite directions, flapping, bobbing
--   and banking, leaving soft trails and moon dust
-- * MOONRISE once per loop (peak 6.0 s): the pods clench shut and the glow
--   dims (gather), then every pod bursts wide open (38 deg, backOut), the
--   cores flash full bright, the moon light ramps up, the crescent rises and
--   spins a full turn, the moths swoop up, and a burst of moon sparkles +
--   rising motes pours out of the pod ring; everything settles by ~8.6 s
-- All waves use whole cycles per loop and every envelope is 0 at both loop
-- ends (the crescent spin ends on a full 360), so t=0 == t=9.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, exp, clamp = math.sin, math.exp, math.clamp

local M = {}
M.Cycle = 9

local TAU = math.pi * 2
local BEAT = 6.0

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end
local function w01(t, n, ph)
	return 0.5 + 0.5 * w(t, n, ph)
end

-- per pod: swing cycles, phase, pitch amp, roll amp, breath phase
local PODS = {
	{ 2, 0.00, 8, 6, 0.00 },
	{ 3, 0.37, 7, 7, 0.55 },
	{ 2, 0.62, 8, 6, 0.30 },
	{ 3, 0.15, 7, 7, 0.80 },
	{ 2, 0.81, 8, 6, 0.12 },
	{ 3, 0.49, 7, 7, 0.67 },
}

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- moonrise envelopes (all 0 outside ~5.1..8.7 s)
	local gather = L.track(c, { { 5.1, 0 }, { 5.85, 1, "sineInOut" }, { 6.02, 0, "cubicIn" } })
	local burst = L.track(c, { { 5.95, 0 }, { 6.3, 1, "backOut" }, { 7.2, 0.85, "sineInOut" }, { 8.6, 0, "sineInOut" } })
	local flash = L.track(c, { { 5.95, 0 }, { 6.08, 1, "quadOut" }, { 6.8, 0.8 }, { 8.4, 0, "sineInOut" } })
	local rise = L.track(c, { { 5.9, 0 }, { 6.5, 1, "backOut" }, { 7.4, 0.8 }, { 8.7, 0, "sineInOut" } })
	local spin = L.track(c, { { 5.95, 0 }, { 7.3, 1, "cubicOut" } }) -- stays 1 (=360 deg) to the loop end
	local dt = c - BEAT
	local kick = 0
	if dt > 0 then
		kick = exp(-1.8 * dt) * sin(7 * dt)
	end

	-- trunk + canopy
	pose.Crop = ang(0.6 * w(t, 1, 0.6), 0, 0.6 * w(t, 1, 0.85))
	pose.Canopy = pa(0, 0.12 * w(t, 2, 0.1) - 0.15 * gather + 0.25 * burst, 0,
		1.6 * w(t, 1, 0.0) + 1.2 * kick, 0.6 * w(t, 1, 0.35), 1.7 * w(t, 1, 0.25) - 0.8 * kick)

	-- hanging moss ripples
	for i = 1, 5 do
		local ph = i * 0.19
		pose["Moss" .. i] = ang(6 * w(t, 2, ph) + 6 * kick, 0, 5 * w(t, 2, ph + 0.25))
	end

	-- moon pods
	for i, p in PODS do
		local sw = w(t, p[1], p[2])
		local sw2 = w(t, p[1], p[2] + 0.25)
		local K = 9 * kick - 3 * gather
		pose["Pod" .. i] = ang(p[3] * sw - K, 3 * w(t, 1, p[2] + 0.4), p[4] * sw2)
		local open = 4 + 10 * w01(t, 2, p[5])
		open = open * (1 - gather) + 30 * burst
		pose["Pod" .. i .. "R"] = ang(0, 0, open)
		pose["Pod" .. i .. "L"] = ang(0, 0, -open)
		local o = clamp(open / 14, 0, 1)
		ctx.transparency("MoonCore" .. i, clamp((0.45 - 0.3 * o + 0.3 * gather) * (1 - flash), 0, 0.8))
		ctx.transparency("MoonTip" .. i, clamp((0.3 + 0.25 * w(t, 3, p[5]) + 0.3 * gather) * (1 - flash), 0, 0.8))
	end

	-- crescent moon crown
	pose.CrownMoon = pa(0, 0.2 * w(t, 2, 0.3) + 0.9 * rise - 0.2 * gather, 0,
		0, 30 * w(t, 1, 0.1) + 360 * spin, 3 * w(t, 2, 0.6))
	ctx.transparency("CrownGlow", clamp((0.3 + 0.2 * w(t, 2, 0.05) + 0.3 * gather) * (1 - flash), 0, 0.8))

	-- moths: opposite orbits, flapping, bobbing, banking; swoop up on the beat
	local flap1 = 22 + 32 * w(t, 27, 0)
	local flap2 = 22 + 32 * w(t, 30, 0.3)
	pose.MothOrbit1 = pa(0, 0.7 * w(t, 2, 0.0) + 1.6 * rise, 0, 0, 360 * c / M.Cycle, 0)
	pose.Moth1 = pa(0, 0.25 * w(t, 9, 0), 0, 6 * w(t, 3, 0.2), 0, 14 + 4 * w(t, 2, 0.4))
	pose.MothOrbit2 = pa(0, 0.6 * w(t, 2, 0.5) + 1.2 * rise, 0, 0, -360 * c / M.Cycle + 120, 0)
	pose.Moth2 = pa(0, 0.25 * w(t, 9, 0.5), 0, 6 * w(t, 3, 0.7), 180, 14 + 4 * w(t, 2, 0.9))
	L.both(pose, "Moth1Wing", ang(0, 0, flap1))
	L.both(pose, "Moth2Wing", ang(0, 0, flap2))

	-- lights
	ctx.light("MoonLight", clamp(1.0 + 0.2 * w(t, 2, 0.05) - 0.4 * gather + 0.95 * flash, 0, 2))
	ctx.light("HollowLight", clamp(0.7 + 0.25 * w(t, 3, 0.4) + 0.4 * flash, 0, 2))

	-- the moonrise burst
	if ctx.crossed(BEAT + 0.02) then
		ctx.emit("MoonBurst", 80)
		ctx.emit("MoonMotes", 40)
	end
end

return M
