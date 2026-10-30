--!nocheck
-- Queen's Honeytree: the Honey Hills showpiece, seamless 10 s loop.
-- Idle (always visible):
-- * the trunk sways softly; the three comb-canopy tiers sway +-2..3 deg with
--   lag and breathe (bob); four wild comb sheets and six honey-drop fruits
--   swing on their stems in phase-offset ellipses, the fruit cores pulse
-- * both HONEY FALLS flow: a ripple of glossy bands runs down each fall
--   (transparency wave, 10 waves per loop) and the pools splash constantly
-- * the crown hive bobs and gently wobbles, its entrance glows like a
--   heartbeat; the queen's crown sways and its gems twinkle
-- * an 8-bee SWARM circles the hive and the canopy (1-2 laps per loop each,
--   both directions, tilted orbits), bobbing, wings buzzing, gold trails
-- Signature HONEY BURST (peak 6.0 s):
-- * 4.5-6.0 s gather: the hive squashes down and SHAKES harder and harder,
--   the canopy settles, the bees pull in tight, the falls and glow dim
-- * 6.0 s POP: the hive springs up (backOut), the crown hops 2 studs and
--   whirls a quarter turn (4-fold crown -> seamless), 90 golden sparks + 40
--   flung honey drops burst out, the bees blast outward and race an extra
--   lap, the falls SURGE (solid + neon cores lit), the pools splash, petals
--   rain, the canopy puffs up, fruits and combs kick, all lights flash
-- * settles back by ~9.4 s
-- Whole wave cycles per loop and envelopes 0 at both ends: t=0 == t=10.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, cos, exp, clamp, rad = math.sin, math.cos, math.exp, math.clamp, math.rad

local M = {}
M.Cycle = 10

local TAU = math.pi * 2
local BURST = 6.0

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

-- bees: laps per loop, direction (must match build), bob phase, wing phase
local BEES = {
	{ 2, 1, 0.00, 0.0 },
	{ 2, 1, 0.37, 0.3 },
	{ 2, -1, 0.71, 0.6 },
	{ 1, 1, 0.15, 0.1 },
	{ 1, -1, 0.52, 0.4 },
	{ 1, 1, 0.83, 0.7 },
	{ 1, -1, 0.28, 0.2 },
	{ 1, -1, 0.64, 0.5 },
}
-- fruit: deg (match build), swing cycles, phase
local FRUITS = { { 0, 2, 0.0 }, { 60, 3, 0.31 }, { 120, 2, 0.58 }, { 180, 3, 0.12 }, { 240, 2, 0.83 }, { 300, 3, 0.47 } }
local COMBS = { { 45, 0.1 }, { 135, 0.45 }, { 225, 0.7 }, { 315, 0.25 } }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- burst envelopes (0 outside ~4.5..9.5 s)
	local gather = L.track(c, { { 4.5, 0 }, { 5.85, 1, "sineInOut" }, { 6.02, 0, "cubicIn" } })
	local pop = L.track(c, { { 5.97, 0 }, { 6.3, 1, "backOut" }, { 7.0, 0.7, "sineInOut" }, { 9.2, 0, "sineInOut" } })
	local flash = L.track(c, { { 5.97, 0 }, { 6.1, 1, "quadOut" }, { 6.9, 0.75 }, { 9.0, 0, "sineInOut" } })
	local hop = L.track(c, { { 5.97, 0 }, { 6.35, 1, "quadOut" }, { 7.0, 0, "bounceOut" } })
	local spin = L.track(c, { { 5.97, 0 }, { 7.3, 1, "cubicOut" } }) -- 0 -> 1 (stays 1: 90 deg = seamless)
	local out = L.track(c, { { 5.97, 0 }, { 6.4, 1, "backOut" }, { 7.4, 0.6, "sineInOut" }, { 9.4, 0, "sineInOut" } })
	local lap = L.track(c, { { 5.9, 0 }, { 8.2, 1, "cubicInOut" } }) -- 0 -> 1 = one extra full lap
	local dt = c - BURST
	local kick = (dt > 0) and exp(-1.5 * dt) * sin(6.5 * dt) or 0
	-- the hive shakes harder as it gathers (fast jitter, 0 when gather is 0)
	local g2 = gather * gather
	local shX = 5 * g2 * w(t, 90, 0.0)
	local shZ = 5 * g2 * w(t, 110, 0.3)

	-- trunk + canopy tiers
	pose.Crop = ang(0.6 * w(t, 1, 0.6), 0, 0.7 * w(t, 1, 0.85))
	pose.Canopy1 = pa(0, 0.25 * w(t, 2, 0.1) - 0.3 * gather + 0.55 * pop, 0,
		2.2 * w(t, 1, 0.0) - 1.0 * kick, 0.8 * w(t, 1, 0.35), 2.4 * w(t, 1, 0.25))
	pose.Canopy2 = pa(0, 0.15 * w(t, 2, 0.25) - 0.15 * gather + 0.4 * pop, 0,
		1.4 * w(t, 1, 0.12) + 0.7 * kick, 0.7 * w(t, 1, 0.5), 1.6 * w(t, 1, 0.37))
	pose.Canopy3 = pa(0, 0.1 * w(t, 2, 0.4) - 0.1 * gather + 0.3 * pop, 0,
		1.2 * w(t, 1, 0.24) - 0.5 * kick, 0.6 * w(t, 1, 0.65), 1.4 * w(t, 1, 0.49))

	-- crown hive: bob + wobble; squash + shake on the gather, pop up on the burst
	pose.Hive = pa(0, 0.2 * w(t, 2, 0.3) - 0.7 * gather + 1.1 * pop, 0,
		2.0 * w(t, 1, 0.15) + shX - 3 * kick, 3 * w(t, 1, 0.6), 2.0 * w(t, 1, 0.4) + shZ)
	pose.Crown = pa(0, 1.7 * hop + 0.08 * w(t, 2, 0.5), 0,
		4 * w(t, 1, 0.7) + 10 * hop, 90 * spin + 6 * w(t, 1, 0.2), 4 * w(t, 1, 0.95) - 6 * hop)

	-- wild comb sheets + honey-drop fruits
	for i, cb in COMBS do
		local a = rad(cb[1])
		local ox, oz = sin(a), -cos(a)
		local K = 8 * kick
		pose["Comb" .. i] = ang(5 * w(t, 2, cb[2]) - K * oz, 0, 4 * w(t, 2, cb[2] + 0.25) + K * ox)
	end
	for i, f in FRUITS do
		local a = rad(f[1])
		local ox, oz = sin(a), -cos(a)
		local K = 12 * kick - 4 * gather
		pose["Fruit" .. i] = ang(11 * w(t, f[2], f[3]) - K * oz, 4 * w(t, 1, f[3] + 0.4), 10 * w(t, f[2], f[3] + 0.25) + K * ox)
		ctx.transparency("FruitCore" .. i, clamp((0.38 + 0.14 * w(t, 2, f[3] + i * 0.13) + 0.25 * gather) * (1 - flash), 0, 0.75))
	end

	-- bee swarm
	for n, b in BEES do
		local th = b[2] * 360 * (b[1] * c / M.Cycle + lap)
		pose["BeeOrbit" .. n] = ang(0, th, 0)
		local o = b[2] * (4.0 * out - 1.4 * gather)
		pose["Bee" .. n] = pa(o, 0.4 * w(t, 4, b[3]) + 0.8 * out * w(t, 1, b[3]), 0, 7 * w(t, 2, b[3]), 0, 9 * w(t, 3, b[3] + 0.2))
		local flap = 32 * w(t, 80, b[4])
		pose["Bee" .. n .. "WingR"] = ang(0, 0, 10 + flap)
		pose["Bee" .. n .. "WingL"] = ang(0, 0, -10 - flap)
	end

	-- honey falls: glossy bands flow downward; surge solid + neon core on the burst
	for k = 1, 2 do
		for j = 1, 9 do
			local band = 0.5 + 0.5 * w(t, 10, -j * 0.22 + k * 0.5)
			ctx.transparency("Fall" .. k .. "Seg" .. j, clamp((0.02 + 0.18 * band + 0.12 * gather) * (1 - flash), 0, 0.4))
		end
		ctx.transparency("FallCore" .. k, 1 - 0.85 * flash)
	end

	-- glows
	ctx.transparency("HiveCore", clamp((0.2 + 0.2 * (0.5 + 0.5 * w(t, 5, 0.1)) + 0.3 * gather) * (1 - flash), 0, 0.7))
	for i = 1, 4 do
		ctx.transparency("CrownGem" .. i, clamp((0.25 + 0.2 * w(t, 3, i * 0.25)) * (1 - flash), 0, 0.6))
	end
	ctx.transparency("CrownJewel", clamp((0.2 + 0.15 * w(t, 2, 0.6)) * (1 - flash), 0, 0.6))
	ctx.light("HiveLight", clamp(1.2 + 0.2 * w(t, 5, 0.1) - 0.5 * gather + 0.8 * flash, 0, 2))
	ctx.light("CanopyLight", clamp(0.9 + 0.15 * w(t, 2, 0.3) - 0.3 * gather + 0.9 * flash, 0, 2))
	ctx.light("PoolLight", clamp(0.7 + 0.15 * w(t, 3, 0.7) + 0.7 * flash, 0, 2))

	-- the burst
	if ctx.crossed(BURST + 0.02) then
		ctx.emit("HiveBurst", 90)
		ctx.emit("HoneyFling", 40)
		ctx.emit("HoneySplash1", 25)
		ctx.emit("HoneySplash2", 25)
		ctx.emit("CanopyDrips", 14)
		ctx.emit("BlossomPetals", 16)
	end
end

return M
