--!nocheck
-- Inferno Lotus: seamless 9 s loop.
-- Idle: lava pours DOWN the stem (StemFlow slides 3 band spacings per loop
-- and two hot crests run down every channel), the pool's ripple rings pulse
-- outward, the petals breathe open/closed with a wave running round the
-- bloom, the neon petal edges shimmer, the molten seed-pod core bobs and
-- turns, four ember orbs circle above the bloom on trails, the leaves sway.
-- Signature FULL BLOOM (5.6 s):
-- * 4.2-5.5 s: the petals fold up into a tight bud, the core sinks, the
--   glow dims, the stem trembles
-- * 5.6 s: the petals burst wide open (backOut, rippling round the flower),
--   the molten core RISES high out of the bloom, a RING OF FIRE flares up
--   and spins, a sparkle shockwave bursts out, lava surges down the stem,
--   the orbs are flung wider and race an extra lap, every light flashes
-- * settles by ~8.6 s.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, cos, exp, clamp, rad = math.sin, math.cos, math.exp, math.clamp, math.rad

local M = {}
M.Cycle = 9

local TAU = math.pi * 2
local BLOOM = 5.6
local FBS = 1.6
local STEM_TOP = 13.4 -- top band y (build.luau prints it)

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end
local function smooth(x)
	x = clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	local bud = L.track(c, { { 4.2, 0 }, { 5.45, 1, "cubicInOut" }, { 5.65, 0, "quadOut" } })
	local flare = L.track(c, { { 5.5, 0 }, { 5.7, 1, "quadOut" }, { 6.6, 0.8 }, { 8.4, 0, "sineInOut" } })
	local rise = L.track(c, { { 5.5, 0 }, { 6.0, 1, "backOut" }, { 7.2, 0.8, "sineInOut" }, { 8.6, 0, "sineInOut" } })
	local fire = L.track(c, { { 5.55, 0 }, { 5.8, 1, "backOut" }, { 6.9, 0.85 }, { 7.8, 0, "sineInOut" } })
	local shake = bud * bud
	local sh1 = shake * w(t, 41, 0.1)
	local sh2 = shake * w(t, 47, 0.3)

	-- stem + leaves ---------------------------------------------------
	pose.Stem = ang(1.0 * w(t, 1, 0.0) + 0.8 * sh1, 0, 0.9 * w(t, 1, 0.25) + 0.8 * sh2)
	pose.Bloom = pa(0, -0.3 * bud + 0.3 * rise, 0, 1.2 * w(t, 1, 0.1), 3 * w(t, 1, 0.5), 1.2 * w(t, 1, 0.35))
	pose.Leaf1 = ang(2.5 * w(t, 1, 0.2), 0, 2.5 * w(t, 2, 0.1))
	pose.Leaf2 = ang(2.5 * w(t, 1, 0.6), 0, 2.5 * w(t, 2, 0.45))
	pose.Bud1 = ang(3 * w(t, 1, 0.3) + 2 * sh1, 0, 3 * w(t, 1, 0.55) - 4 * flare)
	pose.Bud2 = ang(3 * w(t, 1, 0.8) + 2 * sh2, 0, 3 * w(t, 1, 0.05) + 4 * flare)
	ctx.transparency("BudTip1", clamp(0.3 + 0.3 * w(t, 3, 0.1) - 0.4 * flare, 0, 0.7))
	ctx.transparency("BudTip2", clamp(0.3 + 0.3 * w(t, 3, 0.6) - 0.4 * flare, 0, 0.7))

	-- lava pours down the stem -----------------------------------------
	local extra = smooth((c - BLOOM) / 1.0)
	local down = (FBS * (3 * c / M.Cycle + extra)) % FBS
	pose.StemFlow = CFrame.new(0, -down, 0)
	for ci = 1, 3 do
		for j = 1, 8 do
			local y = STEM_TOP - FBS * (j - 1) - down
			local g = 0
			for _, ph in { 0, 0.5 } do
				local u = (2 * c / M.Cycle + ph + ci * 0.11) % 1
				g += exp(-((y - (STEM_TOP + 1 - 12 * u)) / 2.0) ^ 2)
			end
			g = math.max(clamp(g, 0, 1), flare)
			ctx.transparency(("SBand%d_%d"):format(ci, j), clamp(1 - 1.1 * g, 0, 1))
		end
	end

	-- petals: breathe, fold into a bud, burst open ------------------------
	local function petals(prefix, n, idle, close, open, lagStep)
		for i = 1, n do
			local d = (i - 1) * lagStep
			local b = L.track(c, { { 4.2 + d, 0 }, { 5.45 + d, 1, "cubicInOut" }, { 5.65 + d, 0, "quadOut" } })
			local o = L.track(c, { { 5.55 + d, 0 }, { 5.95 + d, 1, "backOut" }, { 6.8 + d, 0.6, "sineInOut" }, { 8.6, 0, "sineInOut" } })
			local th = idle * w(t, 1, -i / n) + close * b - open * o + 1.2 * sh1
			pose[prefix .. i] = ang(th, 0, 0)
		end
	end
	petals("PetalO", 8, 5, 26, 16, 0.025)
	petals("PetalM", 8, 4, 22, 20, 0.025)
	petals("PetalI", 6, 3, 12, 18, 0.03)

	-- molten core + ring of fire -----------------------------------------
	pose.Core = pa(0, 0.15 * w(t, 2, 0.2) - 0.7 * bud + 3.6 * rise, 0, 0, 360 * c / M.Cycle, 0)
	pose.FireRing = pa(0, -0.6 + 1.6 * fire, 0, 0, -360 * c / M.Cycle, 0)
	for i = 1, 8 do
		local trF = clamp(1 - fire * 1.1 + 0.1 * w(t, 9, i * 0.13), 0, 1)
		ctx.transparency("FlameA" .. i, trF)
		ctx.transparency("FlameB" .. i, trF)
	end

	-- ember orbs (1 lap + 1 extra on the bloom), flung wider ---------------
	local lap = 360 * (c / M.Cycle + smooth((c - BLOOM) / 2.0))
	for i = 1, 4 do
		local R = CFrame.Angles(0, -rad(lap), 0)
		local a = rad((i - 1) * 90 + 45)
		local dir = R * Vector3.new(sin(a), 0, -cos(a))
		pose["Orb" .. i] = CFrame.new(dir * (2.4 * rise - 1.0 * bud) + Vector3.new(0, 0.5 * w(t, 2, i * 0.25) + 1.0 * rise, 0)) * R
		ctx.transparency("OrbCore" .. i, clamp(0.25 + 0.2 * w(t, 3, i * 0.25) - 0.3 * flare, 0, 0.6))
	end

	-- glow ------------------------------------------------------------------
	for i = 1, 8 do
		local s1 = 0.5 + 0.5 * sin(TAU * (2 * t / M.Cycle - i / 8))
		local tr = clamp(0.1 + 0.45 * s1 + 0.3 * bud - 0.6 * flare, 0, 0.75)
		ctx.transparency("EdgeO" .. i .. "a", tr)
		ctx.transparency("EdgeO" .. i .. "b", tr)
		local s2 = 0.5 + 0.5 * sin(TAU * (2 * t / M.Cycle - i / 8 + 0.3))
		local tr2 = clamp(0.1 + 0.45 * s2 + 0.3 * bud - 0.6 * flare, 0, 0.75)
		ctx.transparency("EdgeM" .. i .. "a", tr2)
		ctx.transparency("EdgeM" .. i .. "b", tr2)
		ctx.transparency("Stamen" .. i, clamp(0.25 + 0.25 * w(t, 3, i * 0.125) - 0.4 * flare, 0, 0.6))
	end
	for i = 1, 7 do
		ctx.transparency("Seed" .. i, clamp(0.2 + 0.3 * w(t, 4, i * 0.14) + 0.3 * bud - 0.5 * flare, 0, 0.7))
	end
	local RIPN = { 4, 6, 8 }
	for ri = 1, 3 do
		local band = 0.5 + 0.5 * sin(TAU * (4 * t / M.Cycle - ri * 0.3))
		for i = 1, RIPN[ri] do
			ctx.transparency(("Rip%d_%d"):format(ri, i), clamp(0.1 + 0.65 * band - 0.5 * flare, 0, 0.8))
		end
	end
	for li = 1, 2 do
		for k = 1, 3 do
			ctx.transparency(("LeafVein%d_%d"):format(li, k), clamp(0.3 + 0.25 * w(t, 2, li * 0.3 + k * 0.1) - 0.3 * flare, 0, 0.7))
		end
	end

	-- lights + effects -------------------------------------------------------
	ctx.light("CoreLight", clamp(1.0 + 0.2 * w(t, 3, 0.1) - 0.5 * bud + 1.0 * flare, 0, 2))
	ctx.light("PoolLight", clamp(0.9 + 0.2 * w(t, 4, 0.3) + 0.8 * flare, 0, 2))
	ctx.light("StemLight", clamp(0.7 + 0.2 * w(t, 2, 0.6) + 0.9 * flare, 0, 2))
	ctx.enable("RingFire", c > BLOOM + 0.05 and c < BLOOM + 1.6)
	if ctx.crossed(BLOOM) then
		ctx.emit("BloomBurst", 70)
	end
	if ctx.crossed(BLOOM + 0.3) then
		ctx.emit("BloomBurst", 30)
	end
end

return M
