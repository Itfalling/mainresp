--!nocheck
-- Sunfire Savanna Tree (Sandy Savanna crop #10, Apex): the showpiece of the
-- savanna. A colossal sun-gold acacia in the stud-tree style:
-- * a big stepped golden SAND mound (bone "Soil", parts "Soil") with chunky
--   edge blocks, layered sandstone rocks, a little sandstone sun pillar, dry
--   grass tufts, cactus sprouts, pebbles, shells, wind ripples and two fallen
--   glowing sunfruits
-- * a twisted terracotta trunk (bone "Crop") with spiral ridges, gnarled
--   roots and four acacia limbs fanning out to the canopy
-- * three LAYERED FLAT CANOPY TIERS of big studded leaf slabs, olive-green ->
--   lime-gold -> sun-gold toward the top (bones Tier1 -> Tier2 -> Tier3, so
--   they sway with lag and breathe)
-- * eight glowing SUNFRUIT orbs hang under the bottom tier on stems (bones
--   FruitN, pivot at the stem top; neon cores FruitCoreN flash on the flare)
-- * a radiant SUN DISC crown on a golden stalk (bone "Sun", spins about its
--   face axis) with eight long rays on their own bones (RayN, pulse in/out)
--   carrying hidden neon flare beams (FlareBeamN) for the solar-flare beat
-- * VFX: heat sparkles, rising warm motes, falling golden leaves, swirling
--   sand dust, a sun glow, the flare burst + flare embers; two warm lights
-- Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Sunfire Savanna Tree",
	Rarity = "Apex",
	Element = "Sun",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ------------------------------------------------------------
		local SAND_DK, SAND, SAND_LT, SAND_HI, SAND_DK2 = "#c48a45", "#d9a95c", "#e8c27a", "#f3d79a", "#b77c3b"
		local ROCK_DK, ROCK, ROCK_LT = "#a9573a", "#c9774a", "#e0a06a"
		local GRASS_DRY, GRASS_DRY2 = "#d9c25c", "#b49a3c"
		local PEB, PEB_LT = "#9a8a72", "#efe4cf"
		local CACT, CACT_DK = "#5da047", "#3f7d35"
		local SHELL, SHELL_PK = "#fff1df", "#f6b9ad"
		local PINK = "#ff86b4"
		local TERRA_DK, TERRA, TERRA_LT, TERRA_HI = "#7e3420", "#a5482a", "#c8653a", "#dd8450"
		-- canopy: olive -> lime-gold -> sun-gold
		local T1 = { "#5f8a2e", "#6f9a35", "#7fa93a" }
		local T1_UNDER, T1_TOP = "#4a7027", { "#8fb53f", "#a3c247", "#7fa93a" }
		local T2 = { "#93b23a", "#a8bd3f", "#b9c844" }
		local T2_UNDER, T2_TOP = "#7c9a33", { "#c8cf4a", "#d6c84a", "#b9c844" }
		local T3 = { "#e0b13a", "#eebf45", "#d49e2e" }
		local T3_UNDER, T3_TOP = "#c08a2a", { "#f6cf55", "#ffd968", "#f0a83a" }
		local ACCENT = "#f39a2e"
		local GOLD_DK, GOLD, GOLD_LT, YELLOW = "#d98a1c", "#f2b632", "#ffd04a", "#ffe066"
		local ORANGE_DK, ORANGE = "#d4621f", "#ef7f22"
		local SUN_CORE = "#fff3b0"
		local FRUIT, FRUIT_DK, FRUIT_LT, FRUIT_CORE = "#f08a24", "#d9601c", "#ffb04a", "#ffd65a"
		local LEAFCAP, LEAFCAP2 = "#8fb53f", "#c8cf4a"

		local seed = 1010110
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function polar(r, deg)
			local a = rad(deg)
			return math.sin(a) * r, -math.cos(a) * r
		end
		local function outward(deg)
			local x, z = polar(1, deg)
			return v(x, 0, z)
		end
		local function at(r, deg, y)
			local x, z = polar(r, deg)
			return v(x, y, z)
		end

		------------------------------------------------------------------
		-- STEPPED SAND MOUND (bone "Soil", every part named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(y0, y1, w, color)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(soil, v(w, h, w * 0.62), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.62, h + 0.02, w), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.85, h - 0.03, w * 0.85), cf(0, y, 0), color, S)
		end
		oct(0, 1.2, 19.6, SAND_DK)
		oct(1.2, 2.3, 15.0, SAND)
		oct(2.3, 3.2, 10.0, SAND_LT)
		for i = 0, 17 do
			local a = i * 20 + jit(5)
			local x, z = polar(9.4 + jit(0.3), a)
			local h = 1.0 + rnd() * 0.7
			B:block(soil, v(2.8 + rnd() * 0.8, h, 2.0 + rnd() * 0.5), cf(x, h / 2, z, 0, -a + jit(10), 0),
				i % 3 == 0 and SAND or (i % 2 == 0 and SAND_DK2 or SAND_DK), S)
		end
		for i = 0, 9 do
			local a = i * 36 + 12 + jit(8)
			local x, z = polar(7.2 + jit(0.3), a)
			local h = 0.8 + rnd() * 0.4
			B:block(soil, v(2.3 + rnd() * 0.5, h, 1.7), cf(x, 1.2 + h / 2, z, 0, -a + jit(12), 0), i % 2 == 0 and SAND or SAND_LT, S)
		end
		-- wind ripples
		for _, r in { { 20, 8.4, 1.2 }, { 120, 8.5, 1.2 }, { 200, 8.4, 1.2 }, { 290, 8.5, 1.2 }, { 70, 6.0, 2.3 }, { 160, 6.1, 2.3 }, { 250, 6.0, 2.3 }, { 330, 6.2, 2.3 }, { 110, 4.1, 3.2 }, { 300, 4.2, 3.2 } } do
			local x, z = polar(r[2], r[1])
			B:block(soil, v(2.1, 0.12, 0.35), cf(x, r[3] + 0.05, z, 0, -r[1] + 90 + jit(15), 0), SAND_HI, S)
		end
		-- layered sandstone rocks
		local function rock(x, y, z, s, yaw)
			B:block(soil, v(1.5 * s, 0.7 * s, 1.2 * s), cf(x, y + 0.35 * s, z, 0, yaw, 0), ROCK, S)
			B:block(soil, v(1.15 * s, 0.5 * s, 0.95 * s), cf(x + 0.1 * s, y + 0.92 * s, z, 0, yaw + 12, 0), ROCK_LT, S)
			B:block(soil, v(1.55 * s, 0.18 * s, 1.25 * s), cf(x, y + 0.6 * s, z, 0, yaw, 0), ROCK_DK, S)
		end
		rock(8.0, 1.2, -3.2, 1.2, 20)
		rock(-8.2, 1.2, 2.8, 1.05, -30)
		rock(3.4, 2.3, 5.6, 0.85, 40)
		rock(-1.8, 1.2, 8.6, 1.0, 10)
		rock(-5.6, 2.3, -4.0, 0.8, 65)
		-- a little sandstone sun pillar at the back right (gold sun glyph)
		do
			local p = at(6.4, 128, 2.3)
			local yaw = -128
			B:block(soil, v(1.8, 0.6, 1.8), CFrame.new(p + v(0, 0.3, 0)) * ang(0, yaw, 0), ROCK_DK, S)
			B:block(soil, v(1.4, 2.4, 1.4), CFrame.new(p + v(0, 1.8, 0)) * ang(0, yaw, 0), ROCK, S)
			B:block(soil, v(1.45, 0.25, 1.45), CFrame.new(p + v(0, 1.6, 0)) * ang(0, yaw, 0), ROCK_DK, S)
			B:block(soil, v(1.8, 0.5, 1.8), CFrame.new(p + v(0, 3.25, 0)) * ang(0, yaw, 0), ROCK_LT, S)
			local face = CFrame.new(p + v(0, 2.3, 0)) * CFrame.Angles(0, -rad(128), 0) * CFrame.new(0, 0, -0.72)
			B:block(soil, v(0.7, 0.7, 0.12), face * ang(0, 0, 45), GOLD, S)
			B:block(soil, v(0.32, 0.32, 0.14), face * CFrame.new(0, 0, -0.03), YELLOW, { name = "Soil", mat = "Neon" })
		end
		-- dry grass tufts (thin blades fanning out)
		for _, g in { { 9.6, 1.2, -1.2 }, { 5.2, 1.2, -8.0 }, { -9.4, 1.2, -1.4 }, { 6.2, 2.3, 3.0 }, { -4.6, 2.3, 4.8 }, { 8.0, 1.2, 5.4 }, { -4.2, 1.2, 8.8 }, { -2.6, 3.2, -3.8 }, { -7.6, 1.2, -5.6 } } do
			local yaw = rnd() * 90
			for k = -1, 1 do
				local h = (k == 0) and 1.4 or 1.0
				local c = CFrame.new(g[1], g[2], g[3]) * ang(0, yaw, 0) * ang(0, 0, k * 24) * CFrame.new(0, h / 2, 0)
				B:block(soil, v(0.22, h, 0.32), c, (k == 0) and GRASS_DRY or GRASS_DRY2, S)
			end
		end
		-- pebbles + shells
		for _, p in { { 4.0, 3.2, -3.0 }, { -3.2, 3.2, 2.6 }, { 8.6, 1.2, -5.4 }, { -8.6, 1.2, -3.6 }, { 0.8, 1.2, -9.0 }, { -6.4, 2.3, 1.4 }, { 5.6, 2.3, -3.8 } } do
			B:block(soil, v(0.55, 0.34, 0.5), cf(p[1], p[2] + 0.15, p[3], 0, rnd() * 90, 0), rnd() > 0.5 and PEB or PEB_LT, S)
		end
		for _, s in { { 5.2, 1.2, -7.2, 30 }, { -6.8, 2.3, -1.2, -20 }, { 2.4, 3.2, 3.8, 60 }, { -2.0, 1.2, -8.8, 10 } } do
			local c = CFrame.new(s[1], s[2] + 0.12, s[3]) * ang(0, s[4], 0)
			B:block(soil, v(0.8, 0.22, 0.65), c, SHELL, S)
			B:block(soil, v(0.14, 0.26, 0.67), c * CFrame.new(-0.2, 0.01, 0), SHELL_PK, S)
			B:block(soil, v(0.14, 0.26, 0.67), c * CFrame.new(0.2, 0.01, 0), SHELL_PK, S)
		end
		-- little cactus sprouts
		local function sprout(x, y, z, s, flower)
			B:block(soil, v(0.6 * s, 1.5 * s, 0.6 * s), cf(x, y + 0.75 * s, z), CACT, S)
			B:block(soil, v(0.8 * s, 0.3 * s, 0.35 * s), cf(x + 0.45 * s, y + 0.75 * s, z), CACT_DK, S)
			B:block(soil, v(0.35 * s, 0.6 * s, 0.35 * s), cf(x + 0.72 * s, y + 1.1 * s, z), CACT, S)
			B:block(soil, v(0.8 * s, 0.3 * s, 0.35 * s), cf(x - 0.4 * s, y + 0.5 * s, z), CACT_DK, S)
			B:block(soil, v(0.35 * s, 0.5 * s, 0.35 * s), cf(x - 0.68 * s, y + 0.8 * s, z), CACT, S)
			if flower then
				B:block(soil, v(0.42 * s, 0.25 * s, 0.42 * s), cf(x, y + 1.6 * s, z, 0, 45, 0), PINK, S)
			end
		end
		sprout(-7.0, 2.3, -3.0, 1.1, true)
		sprout(8.6, 1.2, 1.8, 0.9, false)
		sprout(-3.0, 2.3, 6.4, 0.9, true)
		-- barrel cactus at the front right
		B:block(soil, v(1.2, 1.1, 1.2), cf(5.8, 2.85, -5.4), CACT, S)
		B:block(soil, v(0.9, 1.25, 0.9), cf(5.8, 2.9, -5.4, 0, 45, 0), CACT_DK, S)
		B:block(soil, v(0.5, 0.3, 0.5), cf(5.8, 3.55, -5.4, 0, 20, 0), PINK, S)

		-- fallen sunfruits on the mound (small orbs with a neon core)
		local function orb(bone, c, s, yaw, coreName, opts)
			local F = CFrame.new(c) * ang(0, yaw, 0)
			local o = opts or {}
			B:block(bone, v(1.85 * s, 1.85 * s, 1.85 * s), F, FRUIT_CORE, { mat = "Neon", name = coreName, tr = o.coreTr })
			B:block(bone, v(2.35 * s, 1.5 * s, 1.5 * s), F, FRUIT, o.slabOpts)
			B:block(bone, v(1.5 * s, 2.35 * s, 1.5 * s), F, FRUIT_DK, o.slabOpts)
			B:block(bone, v(1.5 * s, 1.5 * s, 2.35 * s), F, FRUIT, o.slabOpts)
			B:block(bone, v(0.55 * s, 0.55 * s, 0.14), F * CFrame.new(-0.35 * s, 0.35 * s, -1.2 * s), FRUIT_LT, o.slabOpts)
			return F
		end
		orb(soil, v(-3.6, 3.2 + 0.85, -3.6), 0.75, 20, "Soil", { slabOpts = S })
		orb(soil, v(7.0, 2.3 + 0.8, -1.2), 0.7, -35, "Soil", { slabOpts = S })

		------------------------------------------------------------------
		-- TWISTED TERRACOTTA TRUNK (bone "Crop")
		------------------------------------------------------------------
		local BASE = 3.2
		local crop = B:bone("Crop", "Root", v(0, BASE, 0))
		B:block(crop, v(6.4, 1.0, 6.4), cf(0, BASE + 0.35, 0, 0, 12, 0), TERRA_DK)
		B:block(crop, v(5.8, 1.0, 5.8), cf(0, BASE + 1.15, 0, 0, -14, 0), TERRA)
		for k = 0, 5 do
			local a = k * 60 + 15 + jit(8)
			local x1, z1 = polar(2.7, a)
			local x2, z2 = polar(4.7, a + 10)
			local x3, z3 = polar(6.4, a + 18)
			B:bar(crop, v(x1, BASE + 1.0, z1), v(x2, BASE - 0.15, z2), 1.6, 1.15, (k % 2 == 0) and TERRA or TERRA_DK)
			B:bar(crop, v(x2, BASE - 0.05, z2), v(x3, 2.0, z3), 1.0, 0.85, TERRA_DK)
		end
		local SEG = {
			-- width, y0, yaw, colour
			{ 5.0, 1.4, 0, TERRA },
			{ 4.6, 3.2, 16, TERRA_DK },
			{ 4.25, 5.0, 32, TERRA },
			{ 3.95, 6.8, 48, TERRA_DK },
			{ 3.7, 8.4, 64, TERRA },
		}
		for i, s in SEG do
			local ox, oz = polar(0.25, i * 70)
			B:block(crop, v(s[1], 2.1, s[1]), cf(ox, BASE + s[2] + 1.0, oz, 0, s[3], 0), s[4])
		end
		-- twisting ridges (three helices)
		for _, a0 in { 20, 140, 260 } do
			local prev
			for i = 0, 4 do
				local t = i / 4
				local y = BASE + 1.6 + t * 8.2
				local r = 2.55 - t * 0.6
				local p = at(r, a0 + t * 110, y)
				if prev then
					B:bar(crop, prev, p, 0.85, 0.75, (i % 2 == 0) and TERRA_LT or TERRA_HI)
				end
				prev = p
			end
		end
		-- acacia limbs fanning out (first segment on the trunk)
		local FORK = BASE + 9.4
		local limbs = {}
		for k = 0, 3 do
			local a = 45 + k * 90 + jit(6)
			local p0 = at(0.7, a, FORK - 0.6)
			local p1 = at(3.6, a + 8, FORK + 1.6)
			B:bar(crop, p0, p1, 1.8, 1.6, (k % 2 == 0) and TERRA or TERRA_DK)
			limbs[k + 1] = { a = a, p1 = p1 }
		end
		B:block(crop, v(3.3, 1.6, 3.3), cf(0, FORK + 0.2, 0, 0, 80, 0), TERRA)

		------------------------------------------------------------------
		-- CANOPY TIERS
		------------------------------------------------------------------
		local function slab(bone, p, s, h, col, tilt)
			return B:block(bone, v(s, h, s), CFrame.new(p) * ang(jit(tilt or 6), rnd() * 90, jit(tilt or 6)), col)
		end
		local function cube(bone, p, s, col)
			return B:block(bone, v(s, s, s), CFrame.new(p) * ang(jit(18), rnd() * 90, jit(18)), col)
		end
		local cubes = {}
		local function tier(bone, d)
			-- underside plate (darker shade)
			local uw = d.R * 1.75
			B:block(bone, v(uw, 0.7, uw * 0.62), cf(0, d.cy - d.h * 0.5 + 0.2, 0), d.under)
			B:block(bone, v(uw * 0.62, 0.72, uw), cf(0, d.cy - d.h * 0.5 + 0.2, 0), d.under)
			B:block(bone, v(uw * 0.85, 0.68, uw * 0.85), cf(0, d.cy - d.h * 0.5 + 0.2, 0, 0, 22, 0), d.under)
			for i = 0, d.n - 1 do
				local a = i * 360 / d.n + d.phase + jit(5)
				local p = at(d.r + jit(0.3), a, d.cy + jit(0.3))
				slab(bone, p, d.s + jit(0.25), d.h, d.cols[1 + (i % #d.cols)])
				table.insert(cubes, { bone = bone, p = p, s = d.s, h = d.h, a = a })
			end
			for i = 0, d.ni - 1 do
				local a = i * 360 / d.ni + d.phase + 30
				slab(bone, at(d.ri, a, d.cy + 0.25), d.si, d.h + 0.2, d.cols[1 + ((i + 1) % #d.cols)])
			end
			for i = 0, d.nb - 1 do
				local a = (i + 0.5) * 360 / d.nb + d.phase + jit(6)
				cube(bone, at(d.rb + jit(0.2), a, d.cy + d.h * 0.5 + d.bs * 0.25 + jit(0.15)), d.bs + jit(0.2), d.top[1 + (i % #d.top)])
			end
		end

		-- TIER 1 (widest, olive-green)
		local tier1 = B:bone("Tier1", "Crop", v(0, FORK + 0.6, 0))
		for _, l in limbs do
			local p2 = at(6.0, l.a - 6, FORK + 3.0)
			B:bar(tier1, l.p1 - (l.p1 - at(0.7, l.a, FORK - 0.6)).Unit * 0.4, p2, 1.3, 1.2, TERRA_LT)
		end
		B:block(tier1, v(2.6, 6.2, 2.6), cf(0, FORK + 3.4, 0, 0, 20, 0), TERRA_DK) -- leader inside the crown
		local C1 = FORK + 4.2
		tier(tier1, { cy = C1, R = 8.4, n = 10, r = 6.7, s = 5.0, h = 2.6, cols = T1, phase = 0,
			ni = 5, ri = 3.0, si = 5.2, nb = 9, rb = 5.6, bs = 2.8, top = T1_TOP, under = T1_UNDER })
		-- branches up to tier 2 (on tier 1)
		local T2Y = C1 + 4.9
		for k = 0, 2 do
			local a = 20 + k * 120
			B:bar(tier1, at(0.6, a, C1 + 0.6), at(2.6, a + 10, T2Y - 1.0), 1.2, 1.1, TERRA)
		end

		-- TIER 2 (lime-gold)
		local tier2 = B:bone("Tier2", "Tier1", v(0, C1 + 2.2, 0))
		B:block(tier2, v(2.0, 3.6, 2.0), cf(0, T2Y - 0.6, 0, 0, 40, 0), TERRA_DK)
		tier(tier2, { cy = T2Y, R = 6.2, n = 8, r = 4.9, s = 4.3, h = 2.4, cols = T2, phase = 22,
			ni = 4, ri = 1.9, si = 4.4, nb = 7, rb = 3.9, bs = 2.5, top = T2_TOP, under = T2_UNDER })
		local T3Y = T2Y + 4.3
		for k = 0, 2 do
			local a = 80 + k * 120
			B:bar(tier2, at(0.5, a, T2Y + 0.5), at(1.9, a + 10, T3Y - 0.9), 1.0, 0.95, TERRA_LT)
		end

		-- TIER 3 (sun-gold)
		local tier3 = B:bone("Tier3", "Tier2", v(0, T2Y + 1.9, 0))
		tier(tier3, { cy = T3Y, R = 4.4, n = 6, r = 3.1, s = 3.6, h = 2.2, cols = T3, phase = 10,
			ni = 1, ri = 0.0, si = 3.8, nb = 6, rb = 2.6, bs = 2.0, top = T3_TOP, under = T3_UNDER })

		-- little orange "sun-kissed" leaf caps + half-sunk sunfruits on the tier rims
		local sunkN = 0
		for i, c in cubes do
			if i % 3 == 1 then
				local o = outward(c.a)
				local p = c.p + o * (c.s * 0.5 - 0.1) + v(0, c.h * 0.5 + 0.1, 0)
				B:block(c.bone, v(1.3, 0.5, 1.3), CFrame.new(p) * ang(0, rnd() * 90, 0), ACCENT)
			elseif i % 3 == 0 and sunkN < 6 then
				sunkN += 1
				local o = outward(c.a)
				local p = c.p + o * (c.s * 0.5 + 0.15) + v(0, -0.1, 0)
				orb(c.bone, p, 0.55, -c.a, "SunkCore" .. sunkN)
			end
		end

		------------------------------------------------------------------
		-- SUN DISC CROWN (bone "Sun" on a golden stalk; rays on RayN bones)
		------------------------------------------------------------------
		local SC = v(0, T3Y + 7.4, 0)
		-- stalk + leaf collar on tier 3
		B:bar(tier3, v(0, T3Y + 0.6, 0), SC + v(0, -2.2, 0), 1.3, 1.3, GOLD_DK)
		B:block(tier3, v(1.7, 0.6, 1.7), CFrame.new(v(0, T3Y + 3.4, 0)) * ang(0, 45, 0), GOLD)
		for i = 0, 4 do
			local c = CFrame.new(0, T3Y + 1.9, 0) * CFrame.Angles(0, rad(i * 72 + 10), 0) * CFrame.new(0, 0, -1.3) * ang(-30, 0, 0)
			B:block(tier3, v(1.4, 0.32, 1.9), c, (i % 2 == 0) and T3_TOP[1] or ACCENT)
		end
		local sun = B:bone("Sun", "Tier3", SC)
		local F = CFrame.new(SC)
		local function oct2(bone, w, d, z, col, opts)
			B:block(bone, v(w, w * 0.6, d), F * CFrame.new(0, 0, z), col, opts)
			B:block(bone, v(w * 0.6, w, d + 0.02), F * CFrame.new(0, 0, z), col, opts)
			B:block(bone, v(w * 0.73, w * 0.73, d - 0.02), F * CFrame.new(0, 0, z) * ang(0, 0, 45), col, opts)
		end
		oct2(sun, 6.0, 1.6, 0, ORANGE_DK)
		for _, sd in { -1, 1 } do
			oct2(sun, 4.9, 0.3, sd * 0.86, GOLD)
			B:block(sun, v(2.9, 2.9, 0.22), F * CFrame.new(0, 0, sd * 1.06) * ang(0, 0, 45), YELLOW)
			B:block(sun, v(1.8, 1.8, 0.2), F * CFrame.new(0, 0, sd * 1.22), SUN_CORE,
				{ mat = "Neon", name = (sd < 0) and "SunCore" or "SunCoreB" })
		end
		-- short rays between the long ones (on the disc)
		for k = 0, 7 do
			local th = rad(k * 45 + 22.5)
			local d = v(math.cos(th), math.sin(th), 0)
			B:bar(sun, SC + d * 2.5, SC + d * 4.0, 0.9, 0.9, (k % 2 == 0) and ORANGE or GOLD_DK, { up = v(0, 0, 1) })
		end
		-- long rays, each on its own bone so they pulse in/out
		for k = 1, 8 do
			local th = rad((k - 1) * 45)
			local d = v(math.cos(th), math.sin(th), 0)
			local ray = B:bone("Ray" .. k, "Sun", SC)
			B:bar(ray, SC + d * 2.4, SC + d * 4.4, 1.2, 1.1, (k % 2 == 0) and GOLD or GOLD_LT, { up = v(0, 0, 1) })
			B:bar(ray, SC + d * 3.1, SC + d * 3.6, 1.35, 1.25, ORANGE, { up = v(0, 0, 1) })
			B:block(ray, v(0.75, 0.75, 0.75), CFrame.new(SC + d * 4.75) * ang(0, 0, (k - 1) * 45 + 45), YELLOW,
				{ mat = "Neon", name = "RayTip" .. k })
			B:bar(ray, SC + d * 5.2, SC + d * 8.6, 0.4, 0.4, SUN_CORE, { up = v(0, 0, 1), mat = "Neon", tr = 1, name = "FlareBeam" .. k })
		end

		------------------------------------------------------------------
		-- HANGING SUNFRUIT ORBS (bones FruitN on tier 1, pivot at the stem top)
		------------------------------------------------------------------
		local UNDER1 = C1 - 1.3
		local FRUITS = {
			-- deg, radius, stem length, scale
			{ 22, 5.6, 1.3, 1.0 },
			{ 67, 6.6, 2.4, 0.95 },
			{ 112, 5.6, 1.4, 1.0 },
			{ 157, 6.6, 2.3, 0.95 },
			{ 202, 5.6, 1.3, 1.0 },
			{ 247, 6.6, 2.5, 0.95 },
			{ 292, 5.6, 1.4, 1.0 },
			{ 337, 6.6, 2.3, 0.95 },
		}
		for i, f in FRUITS do
			local top = at(f[2], f[1], UNDER1 + 0.2)
			local bone = B:bone("Fruit" .. i, "Tier1", top)
			local s = f[4]
			local c = top - v(0, f[3] + 1.2 * s, 0)
			B:bar(bone, top + v(0, 0.5, 0), c + v(0, 0.9 * s, 0), 0.38, 0.38, TERRA_DK)
			B:block(bone, v(1.3 * s, 0.25, 0.65 * s), CFrame.new(c + v(0, 1.2 * s, 0)) * ang(0, -f[1] + 30, 18), LEAFCAP)
			B:block(bone, v(1.1 * s, 0.25, 0.6 * s), CFrame.new(c + v(0, 1.25 * s, 0)) * ang(0, -f[1] - 60, -18), LEAFCAP2)
			B:block(bone, v(0.5, 0.4, 0.5), CFrame.new(c + v(0, 1.15 * s, 0)) * ang(0, 45, 0), GOLD_DK)
			orb(bone, c, s, -f[1], "FruitCore" .. i)
		end

		------------------------------------------------------------------
		-- VFX: 8 emitters, 2 lights
		------------------------------------------------------------------
		local heatZone = B:block(tier1, v(22, 14, 22), cf(0, C1 + 4.5, 0), GOLD, { tr = 1, name = "HeatZone" })
		B:emitter(heatZone, "sparkle", { name = "HeatSparkles", color = { YELLOW, "#ffffff", GOLD_LT }, rate = 22, size = { 0.2, 0.75, 0 }, life = { 1.0, 2.0 }, speed = { 0.2, 0.7 }, light = 1 })
		local moteZone = B:block(tier1, v(16, 1, 16), cf(0, C1 + 1.0, 0), GOLD, { tr = 1, name = "MoteZone" })
		B:emitter(moteZone, "ember", { name = "RisingMotes", color = { "#ffe27a", ORANGE, "#ffb347" }, rate = 9, size = { 0.35, 0.28, 0 }, life = { 3, 5 }, speed = { 0.4, 1.0 }, spread = 25, accel = { 0.2, 1.0, 0 }, light = 1 })
		local leafZone = B:block(tier1, v(16, 1, 16), cf(0, C1 - 1.6, 0), GOLD, { tr = 1, name = "LeafZone" })
		B:emitter(leafZone, "leaf", { name = "FallingLeaves", color = { GOLD_LT, ACCENT, T1_TOP[2] }, rate = 3.5, size = { 0.55, 0.55, 0.35 }, life = { 3.5, 5.5 }, speed = { 0.3, 0.8 }, accel = { 0.5, -1.3, 0.2 }, dir = "Bottom" })
		local dustZone = B:block(soil, v(18, 0.6, 18), cf(0, 1.0, 0), SAND, { tr = 1, name = "DustZone" })
		B:emitter(dustZone, "smoke", { name = "SandDust", color = { SAND_HI, SAND_LT }, rate = 5, size = { 0.8, 2.0, 3.0 }, trans = { 0.55, 0.7, 1 }, life = { 2, 3.5 }, speed = { 0.6, 1.6 }, spread = 80, accel = { 1.4, 0.35, -0.9 } })
		local sunFx = B:block(sun, v(5, 5, 1.5), F, GOLD, { tr = 1, name = "SunFx" })
		B:emitter(sunFx, "glow", { name = "SunGlow", color = { "#fff2a0", GOLD_LT, ORANGE }, rate = 3, size = { 3.5, 5.5, 2 }, trans = { 0.75, 0.65, 1 }, light = 1 })
		B:emitter(sunFx, "burst", { name = "FlareBurst", color = { "#fff6c0", GOLD_LT, ORANGE }, size = { 0.9, 0.6, 0 }, speed = { 10, 20 }, life = { 0.6, 1.2 }, drag = 2.5, light = 1 })
		B:emitter(sunFx, "sparkle", { name = "SunSparkles", color = { "#ffffff", YELLOW }, rate = 10, size = { 0.25, 0.8, 0 }, life = { 0.6, 1.2 }, speed = { 1.5, 3.5 }, light = 1 })
		local emberZone = B:block(tier3, v(10, 1, 10), cf(0, T3Y + 1.5, 0), GOLD, { tr = 1, name = "EmberZone" })
		B:emitter(emberZone, "ember", { name = "FlareEmbers", color = { "#fff3a0", "#ffb347", ORANGE }, rate = 0, size = { 0.5, 0.35, 0 }, life = { 1.6, 2.8 }, speed = { 5, 11 }, spread = 60, accel = { 0, -2, 0 }, light = 1 })
		local sunLightPart = B:block(sun, v(0.4, 0.4, 0.4), F, GOLD, { tr = 1, name = "SunLightCore" })
		B:light(sunLightPart, { name = "SunLight", color = "#ffcf6a", brightness = 1.4, range = 22 })
		local fruitLightPart = B:block(tier1, v(0.4, 0.4, 0.4), cf(0, C1 - 3.5, 0), GOLD, { tr = 1, name = "FruitLightCore" })
		B:light(fruitLightPart, { name = "FruitLight", color = "#ffa64a", brightness = 1.1, range = 20 })
	end,
}
