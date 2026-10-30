--!nocheck
-- Ruin Crystal Bloom (Starlight Ruins crop #7, Secret).
-- A crystal flower bursting out of the keystone of a ruined star-temple arch.
-- * stepped ruin platform (bone "Soil", parts "Soil"): indigo night-soil
--   base with rough clods, a ring of pale white-violet temple tiles with gold
--   trim and glowing cyan constellation runes, an inner dais with a gold
--   star inlay, teal moss draping over the edges, star-dust specks, little
--   crystal sprouts, a fallen pillar drum and a broken fluted pillar stump
-- * the arch (bone "Crop"): two fluted white pillars with gold bands carrying
--   a stepped round arch of voussoirs with gold trim and rune dots; the right
--   pillar is cracked and one voussoir has shattered, and violet/cyan crystal
--   clusters erupt from both breaks (their neon cores pulse)
-- * the crystal flower grows out of the cracked keystone: a faceted violet
--   stem with two cyan crystal leaves, six big violet crystal petals (own
--   bones, they breathe open/shut), a slowly turning inner crown of cyan
--   crystals and a floating, spinning cyan/violet HEART crystal with a
--   glowing equator, circled by three orbiting crystal shards (with trails)
-- * a small lumen crystal floats and spins inside the arch opening
-- * VFX: bloom sparkles, heart glow, resonance burst + falling glints on the
--   signature beat, rising star dust, arch twinkles; two soft lights
-- Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Ruin Crystal Bloom",
	Rarity = "Secret",
	Element = "Star",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Starlight Ruins) ---------------------------------------
		local EARTH, EARTH_DK, EARTH_LT = "#3b3566", "#2a2550", "#4d4684"
		local STONE, STONE2, STONE_DK, STONE_LT, STONE_HI = "#e3dcef", "#d0c7e2", "#a99fc2", "#f4f0fb", "#fbf9ff"
		local GOLD, GOLD_DK, GOLD_LT = "#f2c24f", "#c9952e", "#ffe08a"
		local MOSS, MOSS_DK, MOSS_LT = "#4f9e7c", "#367a62", "#78c79a"
		local RUNE = "#7fe8ff"
		local DUST_G, DUST_C = "#ffe27a", "#b8f4ff"
		local VIO_DK, VIO, VIO_LT = "#5b3fc4", "#8160f0", "#b49cff"
		local CY_DK, CY, CY_LT = "#2aa9cf", "#4fd8f2", "#a8f3ff"
		local PINK, PINK_LT = "#ff8fd8", "#ffc4ee"
		local CORE_C, CORE_P, CORE_W = "#c4fbff", "#ffd2f4", "#f4f0ff"
		local GRASS, GRASS_DK = "#8ea9dc", "#6f87c2"

		local seed = 18707
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		-- frame at angle a (deg, 0 = front/-Z, clockwise toward +X), radius r, height y; local -Z = outward
		local function polar(a, r, y)
			return CFrame.new(math.sin(rad(a)) * r, y, -math.cos(rad(a)) * r) * CFrame.Angles(0, -rad(a), 0)
		end
		-- up vector that turns a bar 45 deg about its own axis (diamond cross-section)
		local function diamondUp(d)
			local u = d.Unit
			local ref = (math.abs(u.Y) > 0.9) and v(1, 0, 0) or v(0, 1, 0)
			local side = u:Cross(ref).Unit
			return side:Cross(u).Unit + side
		end
		-- faceted crystal prism stepping to a point; optional neon core strip
		local function crystal(bone, base, tip, w, cA, cB, cT, core)
			local d = tip - base
			local o = { up = diamondUp(d) }
			B:bar(bone, base, base + d * 0.62, w, w, cA, o)
			B:bar(bone, base + d * 0.55, base + d * 0.85, w * 0.66, w * 0.66, cB, o)
			B:bar(bone, base + d * 0.8, tip, w * 0.34, w * 0.34, cT, o)
			if core then
				-- glowing seam along one facet edge (pulses from motion)
				local up = diamondUp(d).Unit
				local off = up * (w * 0.62)
				B:bar(bone, base + d * 0.12 + off, base + d * 0.58 + off, w * 0.26, w * 0.26, core[2], { up = o.up, mat = "Neon", name = core[1] })
			end
		end
		local function oct(bone, y0, h, r, col, opts, yaw)
			B:block(bone, v(2 * r, h, 0.83 * r), cf(0, y0 + h / 2, 0, 0, yaw or 0, 0), col, opts)
			B:block(bone, v(0.83 * r, h - 0.03, 2 * r), cf(0, y0 + h / 2, 0, 0, yaw or 0, 0), col, opts)
			B:block(bone, v(1.42 * r, h - 0.06, 1.42 * r), cf(0, y0 + h / 2, 0, 0, 45 + (yaw or 0), 0), col, opts)
		end

		------------------------------------------------------------------
		-- RUIN PLATFORM (bone "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		-- indigo night-soil base + rough clods
		oct(soil, 0, 0.9, 8.3, EARTH_DK, S)
		for i = 0, 15 do
			local a = i * 22.5 + rnd(-6, 6)
			local w, d, h = rnd(2.2, 3.0), rnd(1.4, 1.9), rnd(0.8, 1.25)
			B:block(soil, v(w, h, d), polar(a, 8.1 + rnd(-0.1, 0.25), h / 2) * ang(0, rnd(-8, 8), 0), pick({ EARTH, EARTH_DK, EARTH_LT }), S)
		end
		-- tier 1: ring of worn temple tiles on a grout plate
		local T1 = 0.9
		oct(soil, T1 - 0.05, 0.7, 6.9, STONE_DK, S)
		for i = 0, 11 do
			local a = i * 30 + 15
			local hh = 0.78 + rnd(-0.04, 0.06)
			local col = (i % 2 == 0) and STONE or STONE2
			if i == 4 then -- one tile knocked askew
				B:block(soil, v(3.3, hh, 2.3), polar(a, 6.0, T1 + hh / 2 + 0.05) * ang(5, 8, -4), col, S)
			else
				B:block(soil, v(3.45, hh, 2.4), polar(a, 5.75, T1 + hh / 2), col, S)
			end
		end
		local T1T = T1 + 0.8
		-- gold trim along the tile ring rim (front half)
		for _, a in { 345, 15, 315, 45, 285, 75 } do
			B:block(soil, v(3.1, 0.14, 0.26), polar(a, 6.95, T1T - 0.04), GOLD, S)
		end
		-- constellation runes on the tile faces (neon dots + thin gold lines)
		local runeN = 0
		local function rune(a, r, y0, pts)
			local base = polar(a, r, y0)
			local prev
			for _, q in pts do
				local p = base * CFrame.new(q[1], q[2], -0.05)
				runeN += 1
				B:block(soil, v(0.26, 0.26, 0.1), p, RUNE, { name = "Soil", mat = "Neon" })
				if prev then
					local c, len = P.aim(prev.Position, p.Position, base.LookVector)
					B:block(soil, v(0.08, 0.08, len), c, GOLD, S)
				end
				prev = p
			end
		end
		rune(345, 6.97, T1, { { -1.0, 0.25 }, { -0.35, 0.5 }, { 0.3, 0.3 }, { 0.95, 0.55 } })
		rune(45, 6.97, T1, { { -0.9, 0.5 }, { -0.2, 0.25 }, { 0.6, 0.45 } })
		rune(255, 6.97, T1, { { -0.8, 0.3 }, { 0.0, 0.55 }, { 0.8, 0.3 } })
		rune(135, 6.97, T1, { { -0.7, 0.45 }, { 0.2, 0.25 }, { 0.9, 0.5 } })
		-- tier 2: inner dais between the pillars, with a gold star inlay
		local T2 = T1T
		oct(soil, T2 - 0.05, 0.55, 3.5, STONE_DK, S)
		for i = 0, 7 do
			B:block(soil, v(2.5, 0.6, 1.65), polar(i * 45, 3.15, T2 + 0.3), (i % 2 == 0) and STONE_LT or STONE, S)
		end
		B:block(soil, v(4.2, 0.6, 4.2), cf(0, T2 + 0.3, 0, 0, 22.5, 0), STONE_LT, S)
		local T2T = T2 + 0.6
		for k = 0, 3 do -- eight-point star: four arms (two long, two short pairs)
			local len = (k % 2 == 0) and 3.4 or 2.3
			B:block(soil, v(0.5, 0.1, len), cf(0, T2T + 0.02, 0, 0, k * 45, 0), GOLD, S)
		end
		B:block(soil, v(1.0, 0.14, 1.0), cf(0, T2T + 0.05, 0, 0, 45, 0), GOLD_LT, S)
		B:block(soil, v(0.45, 0.18, 0.45), cf(0, T2T + 0.08, 0, 0, 45, 0), RUNE, { name = "Soil", mat = "Neon" })
		-- moss draping over the tile edges
		for _, m in { { 100, 6.95, 2.2, MOSS }, { 200, 6.9, 1.8, MOSS_LT }, { 320, 6.95, 1.6, MOSS_DK }, { 160, 3.95, 1.4, MOSS }, { 20, 3.95, 1.2, MOSS_LT } } do
			local y = (m[2] > 5) and T1T or T2T
			B:block(soil, v(m[3], 0.22, 1.2), polar(m[1], m[2] - 0.45, y + 0.04) * ang(-8, 0, 0), m[4], S)
			B:block(soil, v(m[3] * 0.6, 0.22, 0.75), polar(m[1] + 5, m[2] + 0.12, y - 0.35) * ang(-60, 0, 0), m[4], S)
		end
		-- silver-blue grass tufts
		for _, g in { { 120, 7.6, 0.9 }, { 215, 7.7, 0.9 }, { 300, 7.6, 0.9 }, { 60, 6.3, T1T }, { 235, 6.2, T1T } } do
			local base = polar(g[1], g[2], g[3])
			for k = -1, 1 do
				local h = (k == 0) and 1.3 or 0.95
				B:block(soil, v(0.24, h, 0.3), base * ang(0, 0, k * 24) * CFrame.new(0, h / 2, 0), (k == 0) and GRASS or GRASS_DK, S)
			end
		end
		-- star-dust specks
		for _, d in { { 2.2, T2T, -1.9, DUST_G }, { -1.8, T2T, 1.6, DUST_C }, { -5.2, T1T, -2.2, DUST_G }, { 5.0, T1T, 2.8, DUST_C }, { 1.4, T1T, -5.4, DUST_G }, { -2.6, T1T, -5.0, DUST_C }, { -6.0, T1T, 2.4, DUST_G }, { 3.4, T1T, 5.0, DUST_G } } do
			B:block(soil, v(0.28, 0.18, 0.28), cf(d[1], d[2] + 0.08, d[3], 0, rnd(0, 90), 0), d[4], S)
		end
		-- little crystal sprouts poking out of the tiles
		local function sprout(p, s, yaw)
			local c = CFrame.new(p) * ang(0, yaw, 0)
			B:block(soil, v(0.55 * s, 1.4 * s, 0.55 * s), c * CFrame.new(0, 0.6 * s, 0) * ang(0, 45, 8), VIO, S)
			B:block(soil, v(0.32 * s, 0.4 * s, 0.32 * s), c * CFrame.new(0.1 * s, 1.35 * s, 0) * ang(0, 45, 8), VIO_LT, S)
			B:block(soil, v(0.4 * s, 0.95 * s, 0.4 * s), c * CFrame.new(0.45 * s, 0.4 * s, 0.1 * s) * ang(0, 20, -26), CY, S)
			B:block(soil, v(0.36 * s, 0.75 * s, 0.36 * s), c * CFrame.new(-0.4 * s, 0.3 * s, 0.15 * s) * ang(12, 55, 28), CY_DK, S)
		end
		sprout(v(-3.0, T1T, -5.3), 1.0, 20)
		sprout(v(5.6, T1T, -1.6), 0.8, -40)
		sprout(v(-1.6, 0.85, 7.3), 0.9, 70)
		-- fallen pillar drum (front-right) + a chip of it
		do
			local c = CFrame.new(3.9, T1T + 0.85, -4.3) * ang(0, 28, 90)
			B:block(soil, v(1.95, 1.75, 1.95), c, STONE_LT, S)
			B:block(soil, v(1.7, 1.8, 1.7), c * ang(0, 45, 0), STONE2, S)
			B:block(soil, v(2.05, 0.25, 2.05), c * CFrame.new(0, 0.55, 0), GOLD, S)
			B:block(soil, v(0.9, 0.55, 0.7), CFrame.new(5.5, T1T + 0.25, -3.2) * ang(0, 40, 10), STONE, S)
		end
		-- broken fluted pillar stump (back-left)
		do
			local PL = v(-4.3, T1T, 4.6)
			B:block(soil, v(2.1, 0.45, 2.1), CFrame.new(PL + v(0, 0.22, 0)) * ang(0, -15, 0), STONE_DK, S)
			B:block(soil, v(1.6, 2.6, 1.6), CFrame.new(PL + v(0, 1.7, 0)) * ang(0, -15, 0), STONE_LT, S)
			B:block(soil, v(1.38, 2.62, 1.38), CFrame.new(PL + v(0, 1.7, 0)) * ang(0, 30, 0), STONE2, S)
			B:block(soil, v(1.72, 0.26, 1.72), CFrame.new(PL + v(0, 1.0, 0)) * ang(0, -15, 0), GOLD, S)
			B:block(soil, v(1.1, 0.7, 1.3), CFrame.new(PL + v(0.15, 3.3, 0.05)) * ang(0, -15, 7), STONE_LT, S)
			B:block(soil, v(0.6, 0.5, 0.65), CFrame.new(PL + v(0.35, 3.8, -0.1)) * ang(0, 10, 12), STONE, S)
			B:block(soil, v(1.3, 0.25, 0.9), CFrame.new(PL + v(-0.1, 3.05, -0.4)) * ang(-20, -15, 0), MOSS, S)
		end

		------------------------------------------------------------------
		-- RUINED ARCH (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, T1T, 0))
		local ZA = 0.6 -- arch plane (z)
		local PX = 4.75 -- pillar centres at x = +-PX
		local SHAFT0, SHAFT1 = T1T + 1.15, 8.9
		local AC = 9.75 -- arch springline / centre height
		local AR = 4.75 -- voussoir mid radius
		for _, sx in { -1, 1 } do
			local x = sx * PX
			B:block(crop, v(3.0, 0.8, 3.0), cf(x, T1T + 0.4, ZA), STONE_DK)
			B:block(crop, v(2.7, 0.4, 2.7), cf(x, T1T + 0.95, ZA, 0, sx * 2, 0), STONE)
			-- drums
			local y, k = SHAFT0, 0
			while y < SHAFT1 - 0.05 do
				local h = math.min(1.85, SHAFT1 - y)
				local col = (k % 2 == 0) and STONE_LT or STONE
				if sx > 0 and k == 1 then
					-- cracked drum: split in two offset halves (crystal bursts out)
					B:block(crop, v(2.25, h * 0.5, 2.25), cf(x - 0.08, y + h * 0.25, ZA, 0, 3, 0), col)
					B:block(crop, v(2.2, h * 0.5, 2.2), cf(x + 0.1, y + h * 0.75, ZA + 0.05, 0, -6, -3), STONE2)
					B:block(crop, v(0.5, h * 0.7, 0.4), cf(x + 1.12, y + h * 0.5, ZA - 0.6, 0, 0, 12), EARTH)
				else
					B:block(crop, v(2.3, h, 2.3), cf(x + rnd(-0.06, 0.06), y + h / 2, ZA + rnd(-0.06, 0.06), 0, rnd(-3, 3), 0), col)
				end
				y += h
				k += 1
			end
			-- fluting (one raised strip per face)
			for f = 0, 3 do
				local q = CFrame.new(x, (SHAFT0 + SHAFT1) / 2, ZA) * CFrame.Angles(0, rad(f * 90), 0)
				B:block(crop, v(0.42, SHAFT1 - SHAFT0 - 0.4, 0.2), q * CFrame.new(0, 0, -1.2), STONE_HI)
			end
			-- gold band + capital
			B:block(crop, v(2.45, 0.3, 2.45), cf(x, SHAFT0 + 2.0, ZA), GOLD)
			B:block(crop, v(2.9, 0.45, 2.9), cf(x, SHAFT1 + 0.22, ZA), STONE_LT)
			B:block(crop, v(3.2, 0.42, 3.2), cf(x, SHAFT1 + 0.62, ZA), STONE)
			B:block(crop, v(3.26, 0.14, 3.26), cf(x, SHAFT1 + 0.47, ZA), GOLD)
			-- rune dots running down the pillar front
			for r = 1, 3 do
				B:block(crop, v(0.3, 0.3, 0.12), cf(x, SHAFT1 - 0.9 - (r - 1) * 1.4, ZA - 1.32), RUNE, { mat = "Neon", name = (sx < 0 and "PillarRuneL" or "PillarRuneR") .. r })
			end
		end
		-- moss on the left capital + a little hanging strand
		B:block(crop, v(2.0, 0.24, 1.6), cf(-PX - 0.3, SHAFT1 + 0.9, ZA - 0.6, -6, 10, 0), MOSS)
		B:block(crop, v(0.5, 1.4, 0.3), cf(-PX - 1.35, SHAFT1 + 0.2, ZA - 1.0, 0, 10, 0), MOSS_DK)

		-- voussoirs (9 x 20 deg); #7 is shattered
		local NV = 9
		local function vpos(th, r)
			return v(math.cos(rad(th)) * r, AC + math.sin(rad(th)) * r, ZA)
		end
		local keyTop
		for k = 0, NV - 1 do
			local th = 180 - (k + 0.5) * (180 / NV)
			local c = CFrame.new(vpos(th, AR)) * CFrame.Angles(0, 0, rad(th - 90))
			local col = (k % 2 == 0) and STONE_LT or STONE
			if k == 4 then
				-- keystone: bigger, gold face plate, rune, cracked open on top
				B:block(crop, v(2.2, 2.3, 2.8), c * CFrame.new(0, 0.15, 0), STONE_HI)
				for _, sz in { -1, 1 } do
					B:block(crop, v(1.5, 1.6, 0.14), c * CFrame.new(0, 0.1, sz * 1.42), GOLD)
					B:block(crop, v(0.5, 0.5, 0.16), c * CFrame.new(0, 0.1, sz * 1.46) * ang(0, 0, 45), RUNE, { mat = "Neon", name = (sz < 0) and "KeyRune" or "KeyRuneB" })
				end
				keyTop = c * CFrame.new(0, 1.3, 0)
			elseif k == 6 then
				-- shattered: an inner stub, the outer half blown away
				B:block(crop, v(1.8, 0.95, 2.3), c * CFrame.new(0.05, -0.45, 0) * ang(0, 0, 4), col)
				B:block(crop, v(0.9, 0.5, 1.6), c * CFrame.new(-0.4, 0.25, 0.2) * ang(0, 10, -8), STONE2)
			else
				B:block(crop, v(1.95, 1.8, 2.4), c * ang(rnd(-2, 2), 0, rnd(-1.5, 1.5)), col)
				-- gold trim along the outer edge, front + back
				for _, sz in { -1, 1 } do
					B:block(crop, v(1.75, 0.3, 0.14), c * CFrame.new(0, 0.62, sz * 1.22), GOLD)
				end
			end
		end
		-- rune dots on two voussoirs (front)
		for i, th in { 150, 30 } do
			B:block(crop, v(0.3, 0.3, 0.12), CFrame.new(vpos(th, AR - 0.3) + v(0, 0, -1.26)), RUNE, { mat = "Neon", name = "ArchRune" .. i })
		end

		-- crystal clusters erupting from the breaks (cores pulse)
		local function cluster(c, k, n, colA, colB, coreName, coreCol)
			-- c: frame at the cluster base, local +Y = growth direction
			crystal(crop, c.Position, (c * CFrame.new(0, 2.5 * k, 0)).Position, 1.1 * k, colA, colB, CORE_W, { coreName, coreCol })
			for j = 1, n do
				local a = j / n * 360 + rnd(-20, 20)
				local tipL = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, (1.3 + rnd(0, 0.4)) * k, -(1.0 + rnd(0, 0.25)) * k)
				local bl = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0, -0.3 * k)
				crystal(crop, (c * bl).Position, (c * tipL).Position, 0.66 * k, (j % 2 == 0) and colB or colA, (j % 2 == 0) and CY_LT or VIO_LT, CORE_W)
			end
		end
		-- shattered voussoir: crystals burst outward
		do
			local th = 180 - 6.5 * (180 / NV)
			local c = CFrame.new(vpos(th, AR + 0.2)) * CFrame.Angles(0, 0, rad(th - 90))
			cluster(c, 0.95, 3, VIO, CY, "BreakCore1", CORE_P)
		end
		-- cracked right pillar: crystals burst out sideways (front-right)
		cluster(CFrame.new(PX + 0.9, SHAFT0 + 2.75, ZA - 0.5) * ang(-35, 25, -62), 0.85, 3, CY, VIO, "BreakCore2", CORE_C)
		-- left plinth: a small cluster growing at its foot (front)
		cluster(CFrame.new(-PX + 0.4, T1T + 0.5, ZA - 1.7) * ang(-30, 0, 12), 0.6, 2, VIO, CY, "BreakCore3", CORE_P)

		------------------------------------------------------------------
		-- CRYSTAL FLOWER (out of the keystone)
		------------------------------------------------------------------
		local K = keyTop.Position -- top of the keystone
		-- crack crystals around the stem base
		for j = 0, 3 do
			local a = j * 90 + 45
			local dir = v(math.sin(rad(a)), 0, -math.cos(rad(a)))
			crystal(crop, K + dir * 0.6 - v(0, 0.3, 0), K + dir * 1.5 + v(0, 0.9, 0), 0.55, (j % 2 == 0) and CY or VIO, CY_LT, CORE_W)
		end
		local stem = B:bone("Stem", "Crop", K)
		local s0, s1, s2 = K - v(0, 0.4, 0), K + v(0.25, 1.3, -0.1), K + v(0, 2.3, -0.2)
		do
			local d = s1 - s0
			B:bar(stem, s0, s1 + d.Unit * 0.15, 1.15, 1.15, VIO_DK, { up = diamondUp(d) })
			B:bar(stem, s1, s2 + (s2 - s1).Unit * 0.15, 0.95, 0.95, VIO, { up = diamondUp(s2 - s1) })
			B:block(stem, v(1.5, 0.35, 1.5), CFrame.new(s1) * ang(0, 45, 0), GOLD)
		end
		-- two cyan crystal leaves
		for i, L in { { s0 + v(0, 0.6, 0), 270, 34 }, { s0 + v(0.2, 1.1, 0), 90, 30 } } do
			local dir = v(math.sin(rad(L[2])), 0, -math.cos(rad(L[2])))
			local p0 = L[1]
			local p1 = p0 + dir * 1.6 + v(0, 0.6, 0)
			local p2 = p1 + dir * 1.4 + v(0, 1.0, 0)
			B:bar(stem, p0, p1, 0.75, 0.38, CY_DK)
			B:bar(stem, p1 - (p1 - p0).Unit * 0.15, p2, 0.95, 0.36, CY)
			B:bar(stem, p2 - (p2 - p1).Unit * 0.2, p2 + (p2 - p1).Unit * 0.7, 0.5, 0.32, CY_LT)
		end

		local BC = s2 + v(0, 0.1, 0) -- bloom centre
		local bloom = B:bone("Bloom", "Stem", BC)
		B:block(bloom, v(2.4, 0.8, 2.4), CFrame.new(BC) * ang(0, 45, 0), VIO_DK)
		B:block(bloom, v(1.7, 0.6, 1.7), CFrame.new(BC - v(0, 0.55, 0)) * ang(0, 0, 0), VIO)
		B:block(bloom, v(2.0, 0.25, 2.0), CFrame.new(BC + v(0, 0.45, 0)), GOLD)
		-- outer petals: six big violet crystals on their own bones
		for k = 1, 6 do
			local a = (k - 1) * 60 + 30
			local dir = v(math.sin(rad(a)), 0, -math.cos(rad(a)))
			local p0 = BC + dir * 0.75 + v(0, 0.25, 0)
			local pet = B:bone("Petal" .. k, "Bloom", p0)
			local tip = p0 + dir * 2.7 + v(0, 2.5, 0)
			crystal(pet, p0 - dir * 0.2, tip, 1.35, (k % 2 == 0) and VIO or VIO_DK, VIO_LT, PINK_LT, { "PetalCore" .. k, CORE_P })
			-- a pink side-spur on every petal
			local side = dir:Cross(v(0, 1, 0)).Unit
			local sp0 = p0 + dir * 0.9 + v(0, 0.7, 0)
			crystal(pet, sp0, sp0 + dir * 0.8 + v(0, 1.0, 0) + side * ((k % 2 == 0) and 0.6 or -0.6), 0.6, PINK, PINK_LT, CORE_W)
		end
		-- inner crown: six cyan crystals that slowly turn
		local crown = B:bone("Crown", "Bloom", BC)
		for k = 0, 5 do
			local a = k * 60
			local dir = v(math.sin(rad(a)), 0, -math.cos(rad(a)))
			local p0 = BC + dir * 0.45 + v(0, 0.3, 0)
			crystal(crown, p0, p0 + dir * 0.9 + v(0, 2.0, 0), 0.8, (k % 2 == 0) and CY or CY_DK, CY_LT, CORE_W)
		end

		-- floating HEART crystal (spins), glowing equator
		local HC = BC + v(0, 3.55, 0)
		local heart = B:bone("Heart", "Bloom", HC)
		local H = CFrame.new(HC) * ang(0, 45, 0)
		B:block(heart, v(2.15, 0.5, 2.15), H, CORE_C, { mat = "Neon", name = "HeartCore" })
		B:block(heart, v(1.9, 0.6, 1.9), H * CFrame.new(0, 0.55, 0), CY)
		B:block(heart, v(1.4, 0.6, 1.4), H * CFrame.new(0, 1.1, 0), CY_LT)
		B:block(heart, v(0.85, 0.5, 0.85), H * CFrame.new(0, 1.6, 0), CORE_W)
		B:block(heart, v(0.4, 0.4, 0.4), H * CFrame.new(0, 2.0, 0), CY_LT)
		B:block(heart, v(1.9, 0.6, 1.9), H * CFrame.new(0, -0.55, 0), VIO)
		B:block(heart, v(1.35, 0.6, 1.35), H * CFrame.new(0, -1.1, 0), VIO_LT)
		B:block(heart, v(0.8, 0.6, 0.8), H * CFrame.new(0, -1.65, 0), PINK)
		B:block(heart, v(0.36, 0.5, 0.36), H * CFrame.new(0, -2.1, 0), PINK_LT)
		-- facet highlights (thin plates on two faces)
		B:block(heart, v(0.9, 0.42, 0.12), H * CFrame.new(0, 0.6, -0.97), CY_LT)
		B:block(heart, v(0.9, 0.42, 0.12), H * CFrame.new(0, -0.6, 0.97), VIO_LT)

		-- three crystal shards orbiting the heart (with trails)
		local orbit = B:bone("Orbit", "Bloom", HC)
		local SH = {
			{ 0, 3.05, 0.55, PINK, PINK_LT },
			{ 120, 3.05, -0.15, CY, CY_LT },
			{ 240, 3.05, 0.25, GOLD, GOLD_LT },
		}
		for i, s in SH do
			local pc = HC + v(math.sin(rad(s[1])) * s[2], s[3], -math.cos(rad(s[1])) * s[2])
			local sb = B:bone("Shard" .. i, "Orbit", pc)
			local F = CFrame.new(pc) * ang(0, 45, 0)
			B:block(sb, v(0.75, 0.6, 0.75), F, s[4])
			B:block(sb, v(0.45, 0.45, 0.45), F * CFrame.new(0, 0.5, 0), s[5])
			B:block(sb, v(0.4, 0.5, 0.4), F * CFrame.new(0, -0.5, 0), s[5])
			B:block(sb, v(0.82, 0.2, 0.82), F, CORE_W, { mat = "Neon", name = "ShardCore" .. i })
			B:trail(sb, pc + v(0, 0.3, 0), pc - v(0, 0.3, 0), { name = "ShardTrail" .. i, color = { s[5], s[4] }, life = 0.45, width = { 1, 0 }, trans = { 0.25, 1 } })
		end

		-- lumen crystal floating inside the arch opening
		local LC = v(0, 7.9, ZA)
		local lumen = B:bone("Lumen", "Crop", LC)
		do
			local F = CFrame.new(LC) * ang(0, 45, 0)
			B:block(lumen, v(1.25, 0.32, 1.25), F, CORE_C, { mat = "Neon", name = "LumenCore" })
			B:block(lumen, v(1.1, 0.5, 1.1), F * CFrame.new(0, 0.4, 0), VIO_LT)
			B:block(lumen, v(0.65, 0.5, 0.65), F * CFrame.new(0, 0.85, 0), CORE_W)
			B:block(lumen, v(1.1, 0.5, 1.1), F * CFrame.new(0, -0.4, 0), VIO)
			B:block(lumen, v(0.65, 0.55, 0.65), F * CFrame.new(0, -0.9, 0), VIO_LT)
			B:block(lumen, v(0.3, 0.4, 0.3), F * CFrame.new(0, -1.3, 0), PINK_LT)
		end

		------------------------------------------------------------------
		-- VFX: 7 emitters, 2 lights, 3 trails
		------------------------------------------------------------------
		local bloomZone = B:block(bloom, v(8, 6, 8), CFrame.new(BC + v(0, 2.5, 0)), CY, { tr = 1, name = "BloomZone" })
		B:emitter(bloomZone, "sparkle", { name = "BloomSparkle", color = { "#ffffff", CY_LT, PINK_LT }, rate = 12, size = { 0.2, 0.6, 0 }, life = { 0.9, 1.7 }, speed = { 0.3, 0.9 }, light = 1 })
		local heartFx = B:block(heart, v(1.6, 1.6, 1.6), CFrame.new(HC), CY, { tr = 1, name = "HeartFx" })
		B:emitter(heartFx, "glow", { name = "HeartGlow", color = { CORE_C, VIO_LT, PINK_LT }, rate = 2.5, size = { 2.6, 4.0, 1.5 }, trans = { 0.78, 0.7, 1 }, light = 1 })
		B:emitter(heartFx, "burst", { name = "ResonanceBurst", color = { "#ffffff", CY_LT, PINK_LT, VIO_LT }, size = { 0.75, 0.5, 0 }, speed = { 9, 16 }, life = { 0.6, 1.1 }, drag = 3, light = 1 })
		B:emitter(bloomZone, "sparkle", { name = "GlintRain", rate = 0, color = { CY_LT, "#ffffff", PINK_LT }, size = { 0.45, 0.35, 0 }, life = { 1.4, 2.2 }, speed = { 3, 7 }, spread = 70, accel = { 0, -7, 0 }, drag = 0.6, light = 1 })
		local dustZone = B:block(soil, v(13, 0.5, 13), cf(0, T1T + 0.3, 0), GOLD, { tr = 1, name = "DustZone" })
		B:emitter(dustZone, "sparkle", { name = "StarDust", color = { DUST_G, "#ffffff", DUST_C }, rate = 7, size = { 0.12, 0.32, 0 }, life = { 2.5, 4 }, speed = { 0.2, 0.6 }, spread = 25, accel = { 0, 0.7, 0 }, light = 1 })
		local archZone = B:block(crop, v(11, 6, 3), cf(0, AC + 2.6, ZA), CY, { tr = 1, name = "ArchZone" })
		B:emitter(archZone, "sparkle", { name = "ArchTwinkle", color = { RUNE, "#ffffff", GOLD_LT }, rate = 5, size = { 0.12, 0.42, 0 }, life = { 0.8, 1.5 }, speed = { 0.1, 0.4 }, light = 1 })
		local lumenFx = B:block(lumen, v(1, 1.5, 1), CFrame.new(LC), CY, { tr = 1, name = "LumenFx" })
		B:emitter(lumenFx, "glow", { name = "LumenGlow", color = { CORE_C, VIO_LT }, rate = 1.8, size = { 1.8, 2.8, 1 }, trans = { 0.8, 0.72, 1 }, light = 1 })
		B:light(heartFx, { name = "HeartLight", color = "#8ff0ff", brightness = 1.3, range = 16 })
		B:light(lumenFx, { name = "LumenLight", color = "#b99cff", brightness = 1.0, range = 12 })
	end,
}
