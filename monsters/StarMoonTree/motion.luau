--!nocheck
-- Celestial Moon Tree: seamless 9 s loop, calm but clearly alive.
-- Idle:
-- * the silver trunk sways softly; both canopy tiers sway with lag and
--   breathe (bob)
-- * the crescent moon floats: slow bob, gentle rocking roll and a +-24 deg
--   yaw drift so it shows its face to every side; its inner rim glows
-- * six star fruits swing on their stems in phase-offset ellipses and SPIN
--   one full turn per loop (alternate directions), cores twinkling
-- * three comet stars circle the moon once per loop, bobbing
-- * constellation runes on the platform light up one after another
-- Signature STARFALL (peak 5.45 s):
-- * 4.4-5.4 s gather: the moon rises and tips back, dims; canopy settles;
--   fruit cores dim; comets pull in tight
-- * 5.45 s POUR: the moon swings forward (backOut) and flashes, a shower of
--   80 falling stars + a 50-spark moon burst pours over the tree; the three
--   comet stars dive in a full spiral lap round the canopy down to the
--   fruits (golden trails) and swoop back up to their perches; the canopy
--   shivers, fruits kick outward and flash
-- * ~6.8 s the stars land: landing sparks + every rune flashes
-- * settles by ~8.6 s. Whole wave cycles; envelopes 0 at both ends.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, cos, exp, clamp, rad = math.sin, math.cos, math.exp, math.clamp, math.rad

local M = {}
M.Cycle = 9

local TAU = math.pi * 2
local POUR = 5.45
local LAND = 6.8

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

local function spring(dt, k, f)
	if dt <= 0 then
		return 0
	end
	return exp(-k * dt) * sin(f * dt)
end

-- fruit: deg (match build), swing cycles, phase, spin direction
local FRUITS = { { 30, 2, 0.00, 1 }, { 90, 3, 0.31, -1 }, { 150, 2, 0.58, 1 }, { 210, 3, 0.12, -1 }, { 270, 2, 0.83, 1 }, { 330, 3, 0.47, -1 } }
local COMETS = { 0.0, 0.33, 0.67 }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	local gather = L.track(c, { { 4.4, 0 }, { 5.3, 1, "sineInOut" }, { 5.5, 0, "cubicIn" } })
	local pour = L.track(c, { { 5.4, 0 }, { 5.75, 1, "backOut" }, { 6.6, 0.6, "sineInOut" }, { 8.4, 0, "sineInOut" } })
	local flash = L.track(c, { { 5.4, 0 }, { 5.52, 1, "quadOut" }, { 6.3, 0.7 }, { 8.2, 0, "sineInOut" } })
	local landF = L.track(c, { { 6.7, 0 }, { 6.85, 1, "quadOut" }, { 7.6, 0.4 }, { 8.6, 0, "sineInOut" } })
	-- comet dive: out + down then back (0 at both ends), plus one extra lap
	local dive = L.track(c, { { 5.35, 0 }, { 6.45, 1, "sineInOut" }, { 7.1, 0.85 }, { 8.3, 0, "cubicInOut" } })
	local wide = L.track(c, { { 5.35, 0 }, { 5.95, 1, "quadOut" }, { 7.4, 0.8 }, { 8.3, 0, "cubicInOut" } })
	local lap = L.track(c, { { 5.35, 0 }, { 8.3, 1, "cubicInOut" } })
	local kick = spring(c - POUR, 1.7, 7)

	-- trunk + canopy
	pose.Crop = ang(0.7 * w(t, 1, 0.6), 0, 0.8 * w(t, 1, 0.85))
	pose.Canopy1 = pa(0, 0.2 * w(t, 2, 0.1) - 0.25 * gather + 0.3 * pour, 0,
		2.4 * w(t, 1, 0.0) - 1.6 * kick, 0.8 * w(t, 1, 0.35), 2.6 * w(t, 1, 0.25) + 1.0 * kick)
	pose.Canopy2 = pa(0, 0.12 * w(t, 2, 0.3) - 0.12 * gather + 0.2 * pour, 0,
		1.8 * w(t, 1, 0.15) + 1.4 * kick, 0.8 * w(t, 1, 0.55), 1.9 * w(t, 1, 0.4) - 1.2 * kick)

	-- moon: float, rock, yaw drift; tip back on gather, pour forward
	pose.Moon = pa(0, 0.3 * w(t, 2, 0.2) + 0.5 * gather - 0.2 * pour, 0,
		14 * gather - 22 * pour, 24 * w(t, 1, 0.1), 5 * w(t, 1, 0.35) - 4 * kick)

	-- star fruits: swing + spin, kick outward on the pour
	for i, f in FRUITS do
		local a = rad(f[1])
		local ox, oz = sin(a), -cos(a)
		local K = 14 * kick - 5 * gather
		local spin = f[4] * 360 * c / M.Cycle
		pose["Fruit" .. i] = ang(10 * w(t, f[2], f[3]) - K * oz, spin, 9 * w(t, f[2], f[3] + 0.25) + K * ox)
		ctx.transparency("FruitCore" .. i, clamp((0.3 + 0.18 * w(t, 3, f[3] + i * 0.11) + 0.35 * gather) * (1 - flash), 0, 0.8))
	end

	-- silver tassels sway with lag, flick out on the pour
	for i = 1, 6 do
		local a = rad((i - 1) * 60)
		local ox, oz = sin(a), -cos(a)
		local K = 16 * spring(c - POUR - 0.12, 1.8, 7)
		local sw = w(t, 2, i * 0.17 + 0.1)
		pose["Tassel" .. i] = ang(7 * sw - K * oz, 0, 6 * w(t, 2, i * 0.17 + 0.35) + K * ox)
		ctx.transparency("TasselTip" .. i, clamp((0.25 + 0.2 * w(t, 3, i * 0.21)) * (1 - flash), 0, 0.6))
	end

	-- comet stars: one lap round the moon per loop + the dive spiral
	for n, ph in COMETS do
		pose["CometOrbit" .. n] = ang(0, 360 * (c / M.Cycle + lap), 0)
		pose["Comet" .. n] = pa(0, 0.35 * w(t, 3, ph) - 11.5 * dive + 0.6 * gather, -(4.2 * wide - 0.8 * gather), 0, 360 * c / M.Cycle * 2, 0)
		ctx.transparency("CometCore" .. n, clamp(0.3 + 0.2 * w(t, 4, ph) - 0.3 * flash, 0, 0.6))
	end

	-- moon glow
	local rimT = clamp((0.15 + 0.12 * w(t, 2, 0.3) + 0.35 * gather) * (1 - flash), 0, 0.7)
	for k = 1, 8 do
		ctx.transparency("MoonRim" .. k, rimT)
	end

	-- runes: a chase of light round the platform, all flash when stars land
	for i = 1, 6 do
		local chase = 0.5 + 0.5 * w(t, 2, -(i - 1) / 6)
		local tr = clamp((0.65 - 0.55 * chase * chase) * (1 - landF), 0, 0.8)
		ctx.transparency("Rune" .. i, tr)
		ctx.transparency("RuneB" .. i, tr)
	end

	-- lights
	ctx.light("MoonLight", clamp(1.15 + 0.15 * w(t, 2, 0.2) - 0.5 * gather + 0.85 * flash, 0, 2))
	ctx.light("FruitLight", clamp(0.85 + 0.15 * w(t, 3, 0.4) - 0.3 * gather + 0.9 * flash, 0, 2))
	ctx.light("RuneLight", clamp(0.55 + 0.25 * w(t, 2, 0.1) + 1.2 * landF, 0, 2))

	if ctx.crossed(POUR) then
		ctx.emit("Starfall", 80)
		ctx.emit("MoonBurst", 50)
		ctx.emit("StarDrips", 12)
	end
	if ctx.crossed(LAND) then
		ctx.emit("LandSparks", 40)
		ctx.emit("RuneMotes", 14)
	end
end

return M
