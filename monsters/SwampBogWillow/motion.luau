--!nocheck
-- Ancient Bog Willow: the Misty Swamp showpiece, a seamless 10 s loop.
-- * the huge trunk barely moves; the canopy sways +-1.8 deg and breathes,
--   its upper dome trails behind with a little lag
-- * a BREEZE runs around the tree: every leaf curtain (CurtNa -> CurtNb)
--   sways with a phase set by its angle, so a wave travels around the
--   willow twice per loop, the lower segment following with lag (+-5 / +-9
--   deg); the inner strands ripple too
-- * seven wisp fruits swing on their stems in phase-offset ellipses and their
--   neon cores + wisp tips pulse; the grand wisp over the pond bobs, swings
--   and glows like a slow heartbeat
-- * fireflies circle on three orbits (two clockwise, one counter) and bob,
--   drawing glowing trails
-- * SPIRIT GUST once per loop (peak 6.2 s): anticipation - the curtains draw
--   in, the canopy sinks and the wisps dim; then the gust - every curtain
--   flares outward (backOut, the lower segments whip after with lag), the
--   canopy heaves, the wisps swing out and flash full bright, the grand wisp
--   leaps, the fireflies whirl an extra lap, all lights ramp up, and a spirit
--   burst + rising wisp motes + pond bubbles pour out; it settles by ~9 s
-- Waves use whole cycles per loop; envelopes are 0 at both ends; the extra
-- firefly lap ends on a full 360, so t=0 == t=10.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, exp, clamp = math.sin, math.exp, math.clamp

local M = {}
M.Cycle = 10

local TAU = math.pi * 2
local BEAT = 6.2
local NC = 14

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

-- damped spring after a beat (0 before it)
local function spring(dt, k, f)
	if dt <= 0 then
		return 0
	end
	return exp(-k * dt) * sin(f * dt)
end

local WISPS = {
	-- swing cycles, phase
	{ 2, 0.00 }, { 3, 0.31 }, { 2, 0.58 }, { 3, 0.12 }, { 2, 0.83 }, { 3, 0.47 }, { 2, 0.21 },
}

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- gust envelopes
	local gather = L.track(c, { { 5.2, 0 }, { 6.05, 1, "sineInOut" }, { 6.25, 0, "cubicIn" } })
	local gust = L.track(c, { { 6.15, 0 }, { 6.55, 1, "backOut" }, { 7.3, 0.6, "sineInOut" }, { 9.0, 0, "sineInOut" } })
	local gustB = L.track(c, { { 6.3, 0 }, { 6.8, 1, "backOut" }, { 7.6, 0.55, "sineInOut" }, { 9.3, 0, "sineInOut" } })
	local flash = L.track(c, { { 6.15, 0 }, { 6.3, 1, "quadOut" }, { 7.0, 0.8 }, { 8.8, 0, "sineInOut" } })
	local leap = L.track(c, { { 6.15, 0 }, { 6.6, 1, "backOut" }, { 7.4, 0.7, "sineInOut" }, { 9.2, 0, "sineInOut" } })
	local lap = L.track(c, { { 6.2, 0 }, { 8.4, 1, "cubicOut" } }) -- stays 1 (= one extra 360) to the loop end
	local kick = spring(c - BEAT, 1.6, 6.5)

	-- trunk + canopy
	pose.Crop = ang(0.5 * w(t, 1, 0.6) - 0.4 * kick, 0, 0.5 * w(t, 1, 0.85))
	pose.Canopy = pa(0, 0.18 * w(t, 2, 0.1) - 0.35 * gather + 0.55 * gust, 0,
		1.8 * w(t, 1, 0.0) + 1.5 * kick, 0.7 * w(t, 1, 0.35), 2.0 * w(t, 1, 0.25) - 0.8 * kick)
	pose.CanopyTop = pa(0, 0.1 * w(t, 2, 0.35) - 0.15 * gather + 0.35 * gust, 0,
		1.1 * w(t, 1, 0.9) - 0.8 * kick, 0, 1.2 * w(t, 1, 0.15) + 0.5 * kick)

	-- leaf curtains: a breeze wave travelling around the tree (2 laps per loop)
	for i = 2, NC - 1 do
		local ph = (i - 1) / NC
		local inA = -7 * gather + 18 * gust
		local inB = -6 * gather + 22 * gustB
		pose["Curt" .. i .. "a"] = ang(5 * w(t, 2, ph) + 2 * w(t, 3, ph * 2 + 0.3) + inA, 0, 3.5 * w(t, 2, ph + 0.25))
		pose["Curt" .. i .. "b"] = ang(8 * w(t, 2, ph - 0.12) + 3 * w(t, 3, ph * 2 + 0.1) + inB, 0, 5 * w(t, 2, ph + 0.12))
	end
	for i = 1, 6 do
		local ph = (i - 1) / 6 + 0.05
		pose["Inner" .. i] = ang(6 * w(t, 2, ph) - 4 * gather + 14 * gust, 0, 4 * w(t, 2, ph + 0.25))
	end

	-- wisp fruits
	for i, wd in WISPS do
		local sw = w(t, wd[1], wd[2])
		local sw2 = w(t, wd[1], wd[2] + 0.25)
		pose["Wisp" .. i] = ang(9 * sw - 4 * gather + 16 * gust + 6 * kick, 4 * w(t, 1, wd[2] + 0.4), 7 * sw2)
		local idle = 0.32 + 0.16 * w(t, 2, wd[2] + i * 0.13)
		ctx.transparency("Wisp" .. i .. "Core", clamp((idle + 0.35 * gather) * (1 - flash), 0, 0.8))
		ctx.transparency("Wisp" .. i .. "Tip", clamp((0.25 + 0.25 * w(t, 4, wd[2]) + 0.4 * gather) * (1 - flash), 0, 0.8))
	end
	-- grand wisp: slow heartbeat glow, bob + swing, leaps on the gust
	pose.GrandWisp = pa(0, 0.25 * w(t, 2, 0.2) + 1.4 * leap - 0.3 * gather, 0,
		6 * w(t, 1, 0.1) + 10 * kick, 8 * w(t, 1, 0.6), 5 * w(t, 2, 0.35))
	local hb = 0.5 + 0.5 * w(t, 5, 0.0)
	ctx.transparency("GrandWispCore", clamp((0.3 - 0.2 * hb + 0.4 * gather) * (1 - flash), 0, 0.8))
	ctx.transparency("GrandWispTip", clamp((0.3 + 0.2 * w(t, 4, 0.3) + 0.4 * gather) * (1 - flash), 0, 0.8))

	-- fireflies: three orbits, bobbing; one extra lap after the gust
	pose.FlyOrbit1 = pa(0, 0.9 * w(t, 3, 0.0), 0, 3 * w(t, 2, 0.2), 360 * c / M.Cycle + 360 * lap, 0)
	pose.FlyOrbit2 = pa(0, 0.7 * w(t, 4, 0.3), 0, 0, -720 * c / M.Cycle - 360 * lap, 4 * w(t, 2, 0.7))
	pose.FlyOrbit3 = pa(0, 1.1 * w(t, 2, 0.6) + 1.2 * leap, 0, -3 * w(t, 1, 0.4), 360 * c / M.Cycle + 360 * lap + 30, 0)
	for o = 1, 3 do
		for f = 1, 2 do
			ctx.transparency("Fly" .. o .. f, clamp(0.15 + 0.35 * (0.5 + 0.5 * w(t, 7 + o + f, o * 0.21 + f * 0.37)), 0, 0.6))
		end
	end

	-- lights
	ctx.light("WispLight", clamp(1.1 + 0.2 * w(t, 2, 0.05) - 0.45 * gather + 0.9 * flash, 0, 2))
	ctx.light("GrandLight", clamp(0.8 + 0.4 * hb - 0.4 * gather + 1.0 * flash, 0, 2))
	ctx.light("PondLight", clamp(0.7 + 0.15 * w(t, 3, 0.4) + 0.6 * flash, 0, 2))

	-- the spirit gust burst
	if ctx.crossed(BEAT + 0.05) then
		ctx.emit("SpiritBurst", 110)
		ctx.emit("WispMotes", 45)
		ctx.emit("PondBubbles", 30)
	end
end

return M
