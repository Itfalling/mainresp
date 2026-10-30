--!nocheck
-- Ruin Crystal Bloom: a calm but clearly visible, seamless 9 s idle.
-- * the crystal stem sways softly out of the keystone; the bloom breathes
-- * the six violet crystal petals (PetalN, pivot at the petal base) breathe
--   open and shut +-6 deg in a ripple running around the flower
-- * the inner cyan crown turns slowly one way (-1 turn per loop), the
--   floating heart crystal spins the other way (+1 turn) and bobs; three
--   crystal shards orbit it (2 turns per loop) tumbling, with trails
-- * the lumen crystal inside the arch bobs and spins; every crystal core
--   (petal seams, heart equator, the clusters in the arch breaks, the rune
--   dots) pulses softly with its own phase
-- * RESONANCE once per loop (peak 5.6 s): the petals draw in and the heart
--   rises and charges up (gets brighter while everything else dims), then a
--   FLASH - the heart whirls an extra full turn, the petals spring wide open
--   (backOut), the shards fling outward, every crystal goes full bright, a
--   ripple of light runs down the arch runes, the lights ramp to 2 and
--   60 crystal sparks + 35 falling glints burst from the bloom; settles by 8.4 s
-- Every wave uses whole cycles per loop; every envelope is 0 at both loop ends
-- (the extra whirl ends at exactly one full turn), so t=0 == t=9.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, cos, rad, clamp, exp = math.sin, math.cos, math.rad, math.clamp, math.exp

local M = {}
M.Cycle = 9

local TAU = math.pi * 2
local BEAT = 5.6

-- n whole cycles per loop, phase in turns
local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

-- petal yaw (deg) must match build.luau: (k-1)*60 + 30
local PETAL_AXIS = {}
for k = 1, 6 do
	local a = rad((k - 1) * 60 + 30)
	-- axis = up x outward: positive angle tips the petal outward (opens)
	PETAL_AXIS[k] = Vector3.new(-cos(a), 0, -sin(a))
end
-- shard directions (deg) must match build.luau
local SHARD_DEG = { 0, 120, 240 }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- resonance envelopes (all 0 outside ~4.6..8.6 s)
	local gather = L.track(c, { { 4.6, 0 }, { 5.45, 1, "sineInOut" }, { 5.65, 0, "cubicIn" } })
	local flash = L.track(c, { { 5.5, 0 }, { 5.66, 1, "quadOut" }, { 6.2, 0.85 }, { 8.2, 0, "sineInOut" } })
	local flare = L.track(c, { { 5.5, 0 }, { 6.0, 1, "backOut" }, { 6.7, 0.6, "sineInOut" }, { 8.4, 0, "sineInOut" } })
	local whirl = L.track(c, { { 4.8, 0 }, { 6.5, 1, "cubicInOut" } }) -- holds 1 until the loop ends (= +360 deg)
	local dt = c - BEAT
	local kick = 0
	if dt > 0 then
		kick = exp(-1.8 * dt) * sin(7 * dt)
	end

	-- stem + bloom: soft sway, breathing, dip on the gather, pop on the flash
	pose.Stem = ang(1.4 * w(t, 1, 0.1) - 1.5 * kick, 0, 1.6 * w(t, 1, 0.35))
	pose.Bloom = pa(0, 0.1 * w(t, 2, 0.2) - 0.25 * gather + 0.3 * flare, 0, 1.0 * w(t, 1, 0.6), 0, 1.0 * w(t, 1, 0.85))

	-- petals: breathing ripple, draw in on the gather, spring open on the flash
	for k = 1, 6 do
		local open = 6 * w(t, 2, (k - 1) / 6) - 13 * gather + 15 * flare + 4 * kick
		pose["Petal" .. k] = CFrame.fromAxisAngle(PETAL_AXIS[k], rad(open))
		ctx.transparency("PetalCore" .. k, clamp((0.42 + 0.2 * w(t, 2, (k - 1) / 6 + 0.25) + 0.3 * gather) * (1 - flash), 0, 0.85))
	end

	-- inner crown turns slowly the other way
	pose.Crown = ang(0, -360 * c / M.Cycle, 0)

	-- heart: spins, bobs, rises while charging, whirls on the flash
	local spin = 360 * c / M.Cycle + 360 * whirl
	local lift = 0.3 * w(t, 2, 0.2) + 0.8 * gather + 0.45 * flare
	pose.Heart = CFrame.new(0, lift, 0) * ang(5 * w(t, 1, 0.3), 0, 5 * w(t, 1, 0.55)) * ang(0, spin, 0)
	local heartIdle = 0.3 + 0.15 * w(t, 3, 0)
	ctx.transparency("HeartCore", clamp(heartIdle * (1 - 0.9 * gather) * (1 - flash), 0, 0.6))

	-- orbiting shards: two turns per loop (+ one on the whirl), fling outward on the flash
	pose.Orbit = CFrame.new(0, 0.2 * w(t, 1, 0.4) + 0.5 * gather, 0) * ang(4 * w(t, 1, 0.1), 720 * c / M.Cycle + 360 * whirl, 4 * w(t, 1, 0.35))
	for i, deg in SHARD_DEG do
		local a = rad(deg)
		local out = 0.9 * flare - 0.5 * gather
		pose["Shard" .. i] = CFrame.new(sin(a) * out, 0.25 * w(t, 3, i / 3), -cos(a) * out)
			* ang(25 * w(t, 1, i * 0.3), 360 * 2 * c / M.Cycle * ((i % 2 == 0) and -1 or 1), 25 * w(t, 1, i * 0.3 + 0.25))
		ctx.transparency("ShardCore" .. i, clamp((0.35 + 0.15 * w(t, 3, i * 0.2)) * (1 - flash), 0, 0.7))
	end

	-- lumen crystal in the arch: bob + spin (one turn the other way), flashes
	pose.Lumen = CFrame.new(0, 0.35 * w(t, 2, 0.6) + 0.25 * flare, 0) * ang(0, -360 * c / M.Cycle, 0)
	local lumFlash = L.track(c, { { 5.75, 0 }, { 5.9, 1, "quadOut" }, { 6.4, 0.8 }, { 8.3, 0, "sineInOut" } })
	ctx.transparency("LumenCore", clamp((0.3 + 0.2 * w(t, 2, 0.5)) * (1 - lumFlash), 0, 0.6))

	-- crystal clusters in the arch breaks: idle pulse, flash in a ripple
	for i = 1, 4 do
		local d0 = BEAT + 0.12 + 0.12 * i
		local f = L.track(c, { { d0 - 0.05, 0 }, { d0 + 0.1, 1, "quadOut" }, { d0 + 0.6, 0.7 }, { 8.4, 0, "sineInOut" } })
		ctx.transparency((i == 4) and "HaunchCore" or ("BreakCore" .. i), clamp((0.4 + 0.22 * w(t, 3, i * 0.29) + 0.25 * gather) * (1 - f), 0, 0.85))
	end

	-- runes: keystone first, then a ripple of light running down the pillars
	local keyF = L.track(c, { { 5.5, 0 }, { 5.65, 1, "quadOut" }, { 6.3, 0.6 }, { 8.0, 0, "sineInOut" } })
	local keyIdle = 0.3 + 0.15 * w(t, 2, 0.1)
	ctx.transparency("KeyRune", clamp(keyIdle * (1 - keyF), 0, 0.6))
	ctx.transparency("KeyRuneB", clamp(keyIdle * (1 - keyF), 0, 0.6))
	for i = 1, 2 do
		local d0 = BEAT + 0.1 + 0.1 * i
		local f = L.track(c, { { d0 - 0.05, 0 }, { d0 + 0.08, 1, "quadOut" }, { d0 + 0.5, 0.5 }, { 7.8, 0, "sineInOut" } })
		ctx.transparency("ArchRune" .. i, clamp((0.45 + 0.2 * w(t, 2, i * 0.5)) * (1 - f), 0, 0.8))
	end
	for r = 1, 3 do
		local d0 = BEAT + 0.35 + 0.15 * r
		local f = L.track(c, { { d0 - 0.05, 0 }, { d0 + 0.08, 1, "quadOut" }, { d0 + 0.45, 0.45 }, { 7.9, 0, "sineInOut" } })
		local idle = 0.45 + 0.2 * w(t, 2, r * 0.17)
		ctx.transparency("PillarRuneL" .. r, clamp(idle * (1 - f), 0, 0.8))
		ctx.transparency("PillarRuneR" .. r, clamp(idle * (1 - f), 0, 0.8))
	end

	-- lights: breathe softly, the heart light charges with the gather, both flash
	ctx.light("HeartLight", clamp(1.1 + 0.2 * w(t, 3, 0) + 0.35 * gather + 0.9 * flash, 0, 2))
	ctx.light("LumenLight", clamp(0.8 + 0.2 * w(t, 2, 0.5) - 0.3 * gather + 1.0 * lumFlash, 0, 2))

	-- the burst
	if ctx.crossed(BEAT) then
		ctx.emit("ResonanceBurst", 60)
		ctx.emit("GlintRain", 35)
	end
end

return M
