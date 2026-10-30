--!nocheck
-- Dino Spine Tree: calm but clearly visible, seamless 9 s loop.
-- Idle:
-- * the spine sways softly from the ground up (Crop -> Upper, with lag), the
--   canopy sways +-2 deg and breathes (bob), the top tier trails behind
-- * the dorsal plates ripple gently up the back like a sleeping dino breathing
-- * six ammonite fossil fruits swing on their stems in phase-offset ellipses;
--   their teal cores, the vertebra glints and the canopy buds pulse softly
-- Signature "FOSSIL AWAKENING" (wave 3.8 s -> 4.9 s, awaken 5.1 s):
-- * a bright teal pulse climbs the spine vertebra by vertebra; each dorsal
--   plate flares up as the pulse passes (with spine sparks)
-- * the canopy dips and the fruits draw in (anticipation), then at 5.1 s the
--   fruit cores + buds FLASH, the canopy puffs up (backOut), the fruits kick
--   outward on springy swings, the fossil light flares and a teal/cream burst
--   + glitter pops out of the crown; everything settles by ~8 s
-- Whole wave cycles per loop and envelopes 0 at both ends: t=0 == t=9.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, exp, clamp, rad = math.sin, math.exp, math.clamp, math.rad

local M = {}
M.Cycle = 9

local TAU = math.pi * 2
local WAVE0, STEP, AWAKEN = 3.8, 0.14, 5.1
local NV = 9

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end
-- short bump centred at c (width s), exactly 0 far away
local function bump(x, c, s)
	local d = (x - c) / s
	if math.abs(d) > 3 then
		return 0
	end
	return exp(-d * d)
end

-- fruit: deg (matches build.luau), swing cycles, phase
local FRUITS = {
	{ 25, 2, 0.00 },
	{ 85, 3, 0.31 },
	{ 145, 2, 0.58 },
	{ 205, 3, 0.12 },
	{ 265, 2, 0.83 },
	{ 325, 3, 0.47 },
}

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- awakening envelopes (0 outside ~4.5..8.6 s)
	local gather = L.track(c, { { 4.5, 0 }, { 5.0, 1, "sineInOut" }, { 5.15, 0, "cubicIn" } })
	local flash = L.track(c, { { 5.05, 0 }, { 5.18, 1, "quadOut" }, { 5.7, 0.8 }, { 7.6, 0, "sineInOut" } })
	local puff = L.track(c, { { 5.08, 0 }, { 5.5, 1, "backOut" }, { 6.2, 0.6, "sineInOut" }, { 8.0, 0, "sineInOut" } })
	local dt = c - AWAKEN
	local kick = 0
	if dt > 0 then
		kick = exp(-1.4 * dt) * sin(6.5 * dt)
	end

	-- spine sway: grows toward the top
	pose.Crop = ang(0.5 * w(t, 1, 0.6), 0, 0.6 * w(t, 1, 0.85))
	pose.Upper = ang(1.1 * w(t, 1, 0.75) - 0.6 * kick, 0, 1.3 * w(t, 1, 0.0))
	-- canopy: sway + breathing bob + dip / puff
	pose.Canopy = pa(0, 0.15 * w(t, 2, 0.1) - 0.25 * gather + 0.45 * puff, 0,
		2.0 * w(t, 1, 0.9) + 1.2 * kick, 0.8 * w(t, 1, 0.35), 2.2 * w(t, 1, 0.15))
	pose.CanopyTop = pa(0, 0.08 * w(t, 2, 0.35) - 0.1 * gather + 0.3 * puff, 0,
		1.1 * w(t, 1, 0.05) - 0.8 * kick, 0, 1.2 * w(t, 1, 0.3))

	-- dorsal plates + vertebra glints: idle ripple + the climbing pulse
	local sparkle = 0
	for i = 1, NV do
		local tc = WAVE0 + (i - 1) * STEP
		local p = bump(c, tc, 0.16)
		local idle = 3 * w(t, 2, -i * 0.08)
		-- extending backward: -X lifts the plate
		pose["Plate" .. i] = ang(-(idle + 22 * p), 0, 2 * w(t, 1, i * 0.1))
		local glow = 0.45 + 0.15 * w(t, 3, -i * 0.09)
		ctx.transparency("Glint" .. i, clamp(glow * (1 - p) - 0.2 * flash, 0, 0.8))
		sparkle += p
	end
	if ctx.crossed(WAVE0 + 0.05) then
		ctx.emit("SpineSparks", 18)
	end
	if ctx.crossed(WAVE0 + 0.6) then
		ctx.emit("SpineSparks", 22)
	end

	-- hanging ammonite fruits
	for i, f in FRUITS do
		local a = rad(f[1])
		local ox, oz = sin(a), -math.cos(a)
		local sw = w(t, f[2], f[3])
		local sw2 = w(t, f[2], f[3] + 0.25)
		local K = 12 * kick - 5 * gather
		pose["Fruit" .. i] = ang(10 * sw - K * oz, 4 * w(t, 1, f[3] + 0.4), 9 * sw2 + K * ox)
		local idle = 0.35 + 0.12 * w(t, 3, f[3] + i * 0.13)
		local tr = clamp((idle + 0.25 * gather) * (1 - flash), 0, 0.7)
		ctx.transparency("FossilCore" .. i, tr)
		ctx.transparency("FossilCore" .. i .. "B", tr)
	end
	for n = 1, 3 do
		ctx.transparency("Bud" .. n, clamp((0.35 + 0.2 * w(t, 2, n * 0.3)) * (1 - flash), 0, 0.7))
	end

	-- lights
	ctx.light("FossilLight", clamp(1.0 + 0.15 * w(t, 3, 0.2) + 0.25 * math.min(sparkle, 1) - 0.3 * gather + 0.95 * flash, 0, 2))
	ctx.light("LavaLight", 0.85 + 0.2 * w(t, 3, 0.6))

	-- the burst
	if ctx.crossed(AWAKEN) then
		ctx.emit("AwakenBurst", 60)
		ctx.emit("AwakenGlitter", 40)
	end
end

return M
