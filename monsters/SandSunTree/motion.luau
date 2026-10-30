--!nocheck
-- Sunfire Savanna Tree: a calm but CLEARLY visible, seamless 9 s showpiece idle.
-- * the trunk sways very softly; the three flat canopy tiers sway +-3.5 deg
--   each (adding up to ~5 deg at the top) with a lag between tiers, and
--   breathe with a visible bob (0.3 / 0.15 / 0.1 studs)
-- * eight sunfruit orbs swing on their stems +-12 deg in phase-offset ellipses
--   and their neon cores pulse softly
-- * the sun-disc crown ROTATES a full 360 deg per loop in its own plane (with
--   a +-22 deg yaw wobble so it faces every side), the eight long rays pulse
--   in and out in a ripple running around the disc (rays passing the bottom
--   tuck in so they never touch the canopy)
-- * SOLAR FLARE once per loop (peak 5.55 s): a short gather (canopy settles,
--   rays + fruit draw in, glow dims), then a FLASH - fruit + sun cores go full
--   bright, both lights ramp to 2, the rays shoot out with neon flare beams,
--   the sun whirls an extra 45 deg, the canopy tiers puff up (backOut), the
--   fruit swing outward, and 70 golden sparks + 45 embers burst from the crown;
--   then everything settles back by ~8.4 s
-- Every wave uses whole cycles per loop and every envelope is 0 at both loop
-- ends, so t=0 == t=9.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, cos, exp, clamp, rad = math.sin, math.cos, math.exp, math.clamp, math.rad

local M = {}
M.Cycle = 9

local TAU = math.pi * 2
local FLARE = 5.55

-- n whole cycles per loop, phase in turns
local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

-- fruit: deg (must match build.luau), swing cycles, phase
local FRUITS = {
	{ 22, 2, 0.00 },
	{ 67, 3, 0.31 },
	{ 112, 2, 0.58 },
	{ 157, 3, 0.12 },
	{ 202, 2, 0.83 },
	{ 247, 3, 0.47 },
	{ 292, 2, 0.21 },
	{ 337, 3, 0.69 },
}

local function smooth(x)
	x = clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- flare envelopes (all exactly 0 outside ~4.6..8.6 s)
	local gather = L.track(c, { { 4.6, 0 }, { 5.4, 1, "sineInOut" }, { 5.56, 0, "cubicIn" } })
	local flash = L.track(c, { { 5.48, 0 }, { 5.62, 1, "quadOut" }, { 6.2, 0.9 }, { 8.2, 0, "sineInOut" } })
	local puff = L.track(c, { { 5.5, 0 }, { 5.95, 1, "backOut" }, { 6.6, 0.75, "sineInOut" }, { 8.5, 0, "sineInOut" } })
	local rayOut = L.track(c, { { 5.45, 0 }, { 5.7, 1, "backOut" }, { 6.5, 0.55, "sineInOut" }, { 7.8, 0, "sineInOut" } })
	local beam = L.track(c, { { 5.5, 0 }, { 5.6, 1, "quadOut" }, { 6.0, 0.75 }, { 7.0, 0, "sineInOut" } })
	local whirl = L.track(c, { { 5.45, 0 }, { 6.1, 1, "cubicOut" }, { 9.0, 0, "sineInOut" } })
	-- fruit kick: springy outward swing after the flash
	local dt = c - FLARE
	local kick = 0
	if dt > 0 then
		kick = exp(-1.6 * dt) * sin(6.5 * dt)
	end

	-- trunk: very soft sway
	pose.Crop = ang(0.8 * w(t, 1, 0.6), 0, 0.9 * w(t, 1, 0.85))

	-- canopy tiers: sway with lag + breathing bob + gather/puff
	pose.Tier1 = pa(0, 0.3 * w(t, 2, 0.1) - 0.3 * gather + 0.6 * puff, 0,
		3.3 * w(t, 1, 0.0) - 1.2 * kick, 1.0 * w(t, 1, 0.35), 3.6 * w(t, 1, 0.25))
	pose.Tier2 = pa(0, 0.15 * w(t, 2, 0.25) - 0.15 * gather + 0.4 * puff, 0,
		1.7 * w(t, 1, 0.12) + 0.8 * kick, 0.8 * w(t, 1, 0.5), 1.9 * w(t, 1, 0.37))
	pose.Tier3 = pa(0, 0.1 * w(t, 2, 0.4) - 0.1 * gather + 0.3 * puff, 0,
		1.5 * w(t, 1, 0.24) - 0.6 * kick, 0.8 * w(t, 1, 0.65), 1.7 * w(t, 1, 0.49))

	-- sun disc: full turn per loop (+45 deg whirl at the flare), yaw wobble
	local roll = -(360 * c / M.Cycle + 45 * whirl)
	pose.Sun = pa(0, 0.25 * w(t, 2, 0.3) + 0.5 * puff - 0.2 * gather, 0,
		4 * w(t, 2, 0.15), 22 * w(t, 2, 0.6), roll)

	-- rays: ripple pulse around the disc, shoot out on the flare
	for k = 1, 8 do
		local th0 = (k - 1) * 45
		local ext = 0.32 + 0.32 * w(t, 3, (k - 1) / 8) + 1.2 * rayOut - 0.3 * gather
		-- angular distance of this ray from straight down (270 deg) right now
		local cur = (th0 + roll) % 360
		local dd = math.abs(((cur - 270) + 540) % 360 - 180)
		local tuck = smooth((dd - 20) / 50)
		ext = math.max(ext, -0.25) * (0.2 + 0.8 * tuck) - 0.25 * (1 - tuck)
		local a = rad(th0)
		pose["Ray" .. k] = CFrame.new(cos(a) * ext, sin(a) * ext, 0)
		ctx.transparency("RayTip" .. k, clamp(0.4 - 0.5 * (ext - 0.1) - 0.4 * flash, 0, 0.6))
		local show = smooth((dd - 70) / 30)
		ctx.transparency("FlareBeam" .. k, 1 - 0.85 * beam * show)
	end

	-- hanging sunfruit: elliptical swings, outward kick on the flare
	for i, f in FRUITS do
		local a = rad(f[1])
		local ox, oz = sin(a), -cos(a)
		local sw = w(t, f[2], f[3])
		local sw2 = w(t, f[2], f[3] + 0.25)
		local K = 10 * kick - 5 * gather
		pose["Fruit" .. i] = ang(12 * sw - K * oz, 4 * w(t, 1, f[3] + 0.4), 11 * sw2 + K * ox)
		local idle = 0.4 + 0.12 * w(t, 3, f[3] + i * 0.13)
		ctx.transparency("FruitCore" .. i, clamp((idle + 0.25 * gather) * (1 - flash), 0, 0.7))
	end
	for i = 1, 6 do
		local idle = 0.42 + 0.12 * w(t, 2, i * 0.17)
		ctx.transparency("SunkCore" .. i, clamp((idle + 0.25 * gather) * (1 - flash), 0, 0.7))
	end
	local sunIdle = 0.22 + 0.1 * w(t, 2, 0.05)
	ctx.transparency("SunCore", clamp((sunIdle + 0.3 * gather) * (1 - flash), 0, 0.6))
	ctx.transparency("SunCoreB", clamp((sunIdle + 0.3 * gather) * (1 - flash), 0, 0.6))

	-- lights: breathe softly, ramp to 2 on the flare
	ctx.light("SunLight", clamp(1.15 + 0.2 * w(t, 2, 0.05) - 0.4 * gather + 0.9 * flash, 0, 2))
	ctx.light("FruitLight", clamp(0.9 + 0.15 * w(t, 3, 0.2) - 0.3 * gather + 1.1 * flash, 0, 2))

	-- the burst
	if ctx.crossed(FLARE) then
		ctx.emit("FlareBurst", 70)
		ctx.emit("FlareEmbers", 45)
	end
end

return M
