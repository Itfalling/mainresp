--!nocheck
-- Orbit Planet Vine: a lively but calm, seamless 10 s idle with a big
-- "planetary alignment" signature beat.
-- * four planets circle the moon gate on two tilted orbits that turn in
--   opposite directions (one turn per loop each); every planet spins on its
--   own axis (two turns per loop) and leaves a trail
-- * the three hanging planet fruits swing on their stems in phase-offset
--   ellipses (+-9 deg) and their cores glow softly
-- * the star-lily on top sways and breathes its six petals open/shut; the
--   gold star spins (one turn per loop) and bobs
-- * portal stars twinkle at different rates, the runes breathe
-- * ALIGNMENT once per loop: from 4.9 s the planets glide to a halt lined up
--   in front of and behind the portal (6.0-7.2 s, held), then at 6.3 s the
--   portal FLARES - hidden neon star-flare beams cross the portal, every star
--   and core flashes, the lights ramp to 2, the star-lily springs open, the
--   gold star whirls an extra full turn, the fruits jolt, and 70 burst
--   sparkles + 50 ring sparks + 35 falling stars fire; then the planets sling
--   back into their orbits and everything settles by ~8.6 s
-- All waves use whole cycles per loop; envelopes are 0 at both loop ends
-- (the whirl ends at exactly one full turn), so t=0 == t=10.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, rad, clamp, exp, floor = math.sin, math.rad, math.clamp, math.exp, math.floor

local M = {}
M.Cycle = 10

local TAU = math.pi * 2
local FLASH = 6.3
local ALIGN_AT = 6.0

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end
local function lerp(a, b, x)
	return a + (b - a) * x
end

-- orbit base angles (deg): Orbit1 turns +1, Orbit2 turns -1 per loop
local function base1(c)
	return 360 * c / M.Cycle
end
local function base2(c)
	return -360 * c / M.Cycle
end
-- alignment target: nearest multiple of 180 to where the orbit is at ALIGN_AT
-- (planets sit at local 0 / 180, so this puts them front + back)
local T1 = floor(base1(ALIGN_AT) / 180 + 0.5) * 180
local T2 = floor(base2(ALIGN_AT) / 180 + 0.5) * 180

local FRUITS = { { 2, 0.0, 9 }, { 1, 0.37, 7 }, { 2, 0.66, 9 } }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	local align = L.track(c, { { 4.9, 0 }, { ALIGN_AT, 1, "sineInOut" }, { 7.2, 1 }, { 8.6, 0, "sineInOut" } })
	local flash = L.track(c, { { 6.2, 0 }, { 6.36, 1, "quadOut" }, { 6.9, 0.8 }, { 8.6, 0, "sineInOut" } })
	local beam = L.track(c, { { 6.22, 0 }, { 6.32, 1, "quadOut" }, { 6.8, 0.55 }, { 7.9, 0, "sineInOut" } })
	local diag = L.track(c, { { 6.3, 0 }, { 6.42, 1, "quadOut" }, { 6.9, 0.4 }, { 7.6, 0, "sineInOut" } })
	local bloomOpen = L.track(c, { { 6.25, 0 }, { 6.7, 1, "backOut" }, { 7.4, 0.6, "sineInOut" }, { 8.8, 0, "sineInOut" } })
	local gather = L.track(c, { { 5.0, 0 }, { 6.15, 1, "sineInOut" }, { 6.35, 0, "cubicIn" } })
	local whirl = L.track(c, { { 6.25, 0 }, { 7.6, 1, "cubicOut" } }) -- holds 1 to the loop end (= +360)
	local dt = c - FLASH
	local kick = 0
	if dt > 0 then
		kick = exp(-1.7 * dt) * sin(7 * dt)
	end

	-- orbits: glide into alignment, hold, sling back out
	pose.Orbit1 = ang(0, lerp(base1(c), T1, align), 0)
	pose.Orbit2 = ang(0, lerp(base2(c), T2, align), 0)
	for i = 1, 4 do
		local dir = (i % 2 == 0) and -1 or 1
		pose["Planet" .. i] = ang(0, dir * 720 * c / M.Cycle, 0)
	end
	for _, i in { 1, 3, 4 } do
		ctx.transparency("PlanetCore" .. i, clamp((0.35 + 0.15 * w(t, 2, i * 0.21)) * (1 - flash), 0, 0.7))
	end

	-- star-lily + star
	pose.Bloom = pa(0, 0.1 * w(t, 2, 0.15) - 0.2 * gather + 0.25 * bloomOpen, 0,
		1.6 * w(t, 1, 0.1) - 2 * kick, 0.8 * w(t, 1, 0.4), 1.8 * w(t, 1, 0.3))
	for k = 1, 6 do
		local a = rad((k - 1) * 60)
		local axis = Vector3.new(-math.cos(a), 0, -math.sin(a)) -- + = open outward
		local open = 5 * w(t, 2, (k - 1) / 6) - 10 * gather + 13 * bloomOpen
		pose["Petal" .. k] = CFrame.fromAxisAngle(axis, rad(open))
	end
	pose.TopStar = CFrame.new(0, 0.3 * w(t, 2, 0.3) + 0.35 * bloomOpen, 0)
		* ang(4 * w(t, 1, 0.2), 360 * c / M.Cycle + 360 * whirl, 0)
	ctx.transparency("StarCore", clamp((0.25 + 0.15 * w(t, 3, 0.1) + 0.2 * gather) * (1 - flash), 0, 0.6))

	-- hanging planet fruits
	for i, f in FRUITS do
		local sw = w(t, f[1], f[2])
		local sw2 = w(t, f[1], f[2] + 0.25)
		pose["Fruit" .. i] = ang(f[3] * sw - 8 * kick, 3 * w(t, 1, f[2] + 0.4), f[3] * 0.8 * sw2 + 4 * kick * (i - 2))
		ctx.transparency("FruitCore" .. i, clamp((0.38 + 0.15 * w(t, 3, f[2] + i * 0.13) + 0.2 * gather) * (1 - flash), 0, 0.75))
	end

	-- portal: twinkling stars, flare beams
	for i = 1, 8 do
		local tw = 0.5 + 0.5 * w(t, 2 + (i % 3), i * 0.137)
		ctx.transparency("PortalStar" .. i, clamp((0.05 + 0.55 * tw) * (1 - flash), 0, 0.7))
	end
	for i = 1, 3 do
		local tw = 0.5 + 0.5 * w(t, 3, i * 0.29 + 0.5)
		ctx.transparency("PortalStarB" .. i, clamp((0.05 + 0.55 * tw) * (1 - flash), 0, 0.7))
	end
	ctx.transparency("FlareV", 1 - 0.85 * beam)
	ctx.transparency("FlareH", 1 - 0.85 * beam)
	ctx.transparency("FlareC", 1 - 0.9 * beam)
	ctx.transparency("FlareD1", 1 - 0.8 * diag)
	ctx.transparency("FlareD2", 1 - 0.8 * diag)

	-- runes: breathe; ripple from the keystone down to the pedestal on the flash
	local function rip(d0)
		return L.track(c, { { d0 - 0.05, 0 }, { d0 + 0.08, 1, "quadOut" }, { d0 + 0.5, 0.5 }, { 8.4, 0, "sineInOut" } })
	end
	local key = rip(FLASH)
	ctx.transparency("KeyRune", clamp((0.3 + 0.15 * w(t, 2, 0.1)) * (1 - key), 0, 0.6))
	ctx.transparency("KeyRuneB", clamp((0.3 + 0.15 * w(t, 2, 0.1)) * (1 - key), 0, 0.6))
	local ped = rip(FLASH + 0.3)
	ctx.transparency("PedRune", clamp((0.35 + 0.15 * w(t, 2, 0.6)) * (1 - ped), 0, 0.6))
	ctx.transparency("PedRuneB", clamp((0.35 + 0.15 * w(t, 2, 0.6)) * (1 - ped), 0, 0.6))
	local dots = rip(FLASH + 0.42)
	for _, n in { "PedDotF1", "PedDotF2", "PedDotB1", "PedDotB2" } do
		ctx.transparency(n, clamp((0.45 + 0.2 * w(t, 3, #n * 0.1)) * (1 - dots), 0, 0.75))
	end

	-- lights
	ctx.light("PortalLight", clamp(1.0 + 0.2 * w(t, 2, 0.3) + 0.3 * align + 0.7 * flash, 0, 2))
	ctx.light("StarLight", clamp(1.0 + 0.2 * w(t, 3, 0.1) + 0.9 * flash, 0, 2))

	-- the beat
	if ctx.crossed(FLASH) then
		ctx.emit("AlignBurst", 70)
		ctx.emit("RingBurst", 50)
	end
	if ctx.crossed(FLASH + 0.15) then
		ctx.emit("Starfall", 35)
	end
end

return M
