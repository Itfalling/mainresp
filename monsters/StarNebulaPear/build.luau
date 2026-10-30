--!nocheck
-- Nebula Pear Tree (Starlight Ruins crop #6, Mythic, ANIM + VFX)
-- An ancient star-temple pear tree whose fruit are swirling little nebulae.
-- * mound (bone "Soil", parts "Soil"): dark indigo foundation tier with ruined
--   edge stones and a gold band, a pale tile tier, a raised white-stone dais
--   with a gold rim and rune studs, a broken arch pillar with a snapped lintel,
--   a fallen pillar drum, crystals, moss, star dust and a constellation inlay
-- * trunk (bone "Crop"): twisted violet-grey bark with silver ridges, gilded
--   bands, roots gripping the dais, four limbs into the crown
-- * canopy (bones "Canopy" -> "CanopyTop"): clusters of big rotated studded
--   leaf cubes, deep indigo -> starlight blue with nebula-violet accents and
--   twinkling star specks (LeafStarN)
-- * seven NEBULA PEARS (bones PearN, pivot at the stem top): stepped pears
--   built of twisted colour bands (magenta / violet / cyan / pink) with neon
--   swirl stripes (PearCoreN, PearCoreNB) that pulse
-- * three comet stars orbiting the crown (bone "Orbit") with trails
-- * VFX: nebula dust, rising motes, glowing pear drips, falling star leaves,
--   crown glow, surge burst + surge sparks (fired on the beat), ground
--   twinkles; two lights; three trails
-- Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Nebula Pear Tree",
	Rarity = "Mythic",
	Element = "Star",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette -------------------------------------------------------------
		local FOUND_DK, FOUND, FOUND_LT = "#2f2f5c", "#3d3e74", "#4f5190"
		local GROUT = "#6f6a8e"
		local STONE, STONE_LT, STONE_DK, STONE_HI = "#d8d4e6", "#e9e6f3", "#bdb7d3", "#f6f3fb"
		local GOLD_DK, GOLD, GOLD_LT = "#c9922a", "#e8b84a", "#ffd96b"
		local MOSS, MOSS_DK, MOSS_LT = "#5e9c74", "#457f5e", "#7dbb86"
		local STAR_W, STAR_C, STAR_G, STAR_P = "#ffffff", "#7fe8ff", "#ffe27a", "#ffb8f0"
		local CRYS, CRYS_LT, CRYS_C = "#8f6bf0", "#b9a2ff", "#7fd9ff"
		local BARK_DK, BARK, BARK_LT, BARK_HI = "#5e5390", "#7a6db0", "#9a8ecb", "#c4bce6"
		local L1 = { "#3a52c0", "#4560d0", "#5a4cc8" }
		local L2 = { "#5076e0", "#5c6ae8", "#4a8ce0" }
		local L3 = { "#6c9cf4", "#7c8cf8", "#6ab0f4" }
		local L4 = { "#9cc8ff", "#b4aaff", "#8cd8ff" }
		local L_UNDER = "#2c3488"
		local NEB, NEB2 = "#b468e6", "#ff9ad8"
		local STEM = "#4a3a78"
		local PLEAF, PLEAF2 = "#3fa6c8", "#5fd0d8"
		local PEARS_PAL = {
			{ "#e85aa8", "#c8448c", "#9a5ae8", "#7fd8ff", "#ffd6f4" },
			{ "#8458e8", "#6a44cc", "#4fc0ec", "#ff9ad8", "#c8f8ff" },
			{ "#4aa8ee", "#3a88d4", "#d05cc8", "#e8dcff", "#ffe6fb" },
		}

		local seed = 6160616
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
		local function at(r, deg, y)
			local x, z = polar(r, deg)
			return v(x, y, z)
		end

		------------------------------------------------------------------
		-- MOUND (bone "Soil", every part named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local SN = { name = "Soil", mat = "Neon" }
		local function oct(bone, y0, y1, w, color, opts)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(bone, v(w, h, w * 0.62), cf(0, y, 0), color, opts)
			B:block(bone, v(w * 0.62, h + 0.02, w), cf(0, y, 0), color, opts)
			B:block(bone, v(w * 0.85, h - 0.03, w * 0.85), cf(0, y, 0), color, opts)
		end
		-- tier A: indigo foundation, gold band, ruined edge stones
		oct(soil, 0, 1.0, 19.4, FOUND, S)
		oct(soil, 0.55, 0.75, 19.6, GOLD_DK, S)
		for i = 0, 15 do
			local a = i * 22.5 + 11 + jit(4)
			local x, z = polar(9.2 + jit(0.25), a)
			local h = 0.9 + rnd() * 0.5
			B:block(soil, v(2.6 + rnd() * 0.6, h, 1.9), cf(x, h / 2, z, 0, -a + jit(8), 0),
				i % 3 == 0 and FOUND_LT or (i % 2 == 0 and FOUND_DK or FOUND), S)
		end
		-- tier B: tile platform
		oct(soil, 1.0, 1.85, 15.4, GROUT, S)
		local TY = 1.95
		for ix = -3, 2 do
			for iz = -3, 2 do
				local x, z = (ix + 0.5) * 2.5, (iz + 0.5) * 2.5
				local m = math.max(math.abs(x), math.abs(z))
				if m > 3 and math.abs(x) + math.abs(z) < 11 then
					local cols = { STONE, STONE_LT, STONE_DK, STONE }
					B:block(soil, v(2.36, 0.34 + jit(0.04), 2.36), cf(x, TY, z, 0, jit(2), 0), cols[1 + math.floor(rnd() * 4)], S)
				end
			end
		end
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			B:block(soil, v(2.2, 0.33, 2.2), cf(c[1] * 5.1, TY, c[2] * 5.1, 0, 45, 0), STONE_DK, S)
		end
		-- tier C: raised white dais with a gold rim + rune studs
		oct(soil, 1.9, 2.9, 7.6, STONE_LT, S)
		oct(soil, 2.45, 2.62, 7.78, GOLD, S)
		local DY = 2.9
		for k = 0, 7 do
			local x, z = polar(3.55, k * 45 + 22.5)
			B:block(soil, v(0.4, 0.4, 0.12), CFrame.new(x, 2.1 + 0.05, z) * ang(0, -(k * 45 + 22.5), 0) * CFrame.new(0, 0, -0.32) * ang(0, 0, 45),
				k % 2 == 0 and STAR_C or STAR_G, SN)
		end

		-- constellation inlay on the front tiles
		local CON = { { -4.6, -5.4 }, { -2.6, -6.4 }, { -0.6, -5.6 }, { 1.4, -6.5 }, { 3.0, -5.2 }, { 4.8, -5.9 } }
		for i, p in CON do
			B:block(soil, v(0.36, 0.12, 0.36), cf(p[1], TY + 0.2, p[2], 0, 45, 0), STAR_C, SN)
			if i > 1 then
				local q = CON[i - 1]
				B:bar(soil, v(q[1], TY + 0.19, q[2]), v(p[1], TY + 0.19, p[2]), 0.12, 0.08, STAR_C, SN)
			end
		end

		-- moss
		for _, m in { { 5.6, TY + 0.2, 3.4, 2.2, 1.5, 20 }, { -6.0, TY + 0.2, -1.6, 1.8, 2.2, -10 }, { -2.4, TY + 0.2, 6.0, 2.2, 1.4, 5 },
			{ 2.4, DY + 0.05, -2.0, 1.4, 1.0, 30 } } do
			B:block(soil, v(m[4], 0.25, m[5]), cf(m[1], m[2], m[3], 0, m[6], 0), MOSS, S)
			B:block(soil, v(m[4] * 0.55, 0.3, m[5] * 0.5), cf(m[1] + 0.2, m[2] + 0.08, m[3] - 0.1, 0, m[6] + 25, 0), MOSS_LT, S)
		end
		for _, a in { 60, 170, 250, 300 } do
			local x, z = polar(9.55, a)
			B:block(soil, v(1.6, 0.9, 0.5), cf(x, 0.75, z, 0, -a, 0), MOSS_DK, S)
		end
		-- star dust
		for _, d in { { 8.0, 1.05, -3.2, STAR_G }, { -8.4, 1.05, 2.6, STAR_C }, { 6.0, TY + 0.2, -4.4, STAR_P }, { -5.2, TY + 0.2, 4.6, STAR_W },
			{ 8.6, 1.05, 3.0, STAR_W }, { -1.6, 1.05, 8.6, STAR_G }, { 1.4, DY + 0.05, 2.6, STAR_P } } do
			B:block(soil, v(0.28, 0.28, 0.28), cf(d[1], d[2] + 0.12, d[3], 45, 45, 0), d[4], SN)
		end

		-- crystal cluster (right side, on the foundation)
		do
			local base = v(8.4, 1.0, -1.0)
			B:block(soil, v(1.5, 0.4, 1.5), CFrame.new(base + v(0, 0.2, 0)) * ang(0, 20, 0), FOUND_DK, S)
			local function crystal(off, h, w, tilt, yaw, col)
				local c = CFrame.new(base + off) * ang(0, yaw, 0) * ang(0, 0, tilt)
				B:block(soil, v(w, h, w), c * CFrame.new(0, h / 2, 0) * ang(0, 45, 0), col, S)
				B:block(soil, v(w * 0.6, 0.5, w * 0.6), c * CFrame.new(0, h + 0.2, 0) * ang(0, 45, 0), CRYS_LT, S)
			end
			crystal(v(0, 0.3, 0), 2.4, 0.9, 0, 0, CRYS)
			crystal(v(0.1, 0.3, 0.55), 1.5, 0.7, -24, 80, CRYS_C)
			crystal(v(0, 0.3, -0.55), 1.8, 0.7, 22, 90, CRYS)
			B:block(soil, v(0.3, 0.3, 0.3), CFrame.new(base + v(0, 3.05, 0)) * ang(45, 45, 0), STAR_W, SN)
		end

		-- broken arch pillar with a snapped lintel (back-left)
		do
			local p = at(9.6, 305, 1.0)
			local F = CFrame.new(p) * ang(0, 35, 0)
			B:block(soil, v(2.6, 0.5, 2.6), F * CFrame.new(0, 0.25, 0), STONE_DK, S)
			B:block(soil, v(2.2, 0.35, 2.2), F * CFrame.new(0, 0.65, 0), GOLD, S)
			B:block(soil, v(1.8, 5.6, 1.8), F * CFrame.new(0, 3.6, 0), STONE, S)
			B:block(soil, v(1.55, 5.4, 1.55), F * CFrame.new(0, 3.5, 0) * ang(0, 45, 0), STONE_LT, S)
			B:block(soil, v(1.95, 0.3, 1.95), F * CFrame.new(0, 2.6, 0), GOLD, S)
			B:block(soil, v(2.4, 0.6, 2.4), F * CFrame.new(0, 6.6, 0), STONE_DK, S)
			B:block(soil, v(2.5, 0.25, 2.5), F * CFrame.new(0, 7.0, 0), GOLD, S)
			-- snapped lintel stub reaching toward the tree
			B:block(soil, v(3.4, 1.2, 1.9), F * CFrame.new(1.2, 7.7, 0) * ang(0, 0, -4), STONE_LT, S)
			B:block(soil, v(1.0, 0.8, 1.5), F * CFrame.new(3.2, 7.55, 0.1) * ang(0, 10, -12), STONE, S)
			B:block(soil, v(3.0, 0.2, 2.0), F * CFrame.new(1.1, 8.38, 0), GOLD_LT, S)
			-- star rune
			local face = F * CFrame.new(0, 4.4, -0.92)
			B:block(soil, v(0.75, 0.75, 0.1), face * ang(0, 0, 45), GOLD, S)
			B:block(soil, v(0.32, 0.32, 0.12), face * CFrame.new(0, 0, -0.02), STAR_C, SN)
			B:block(soil, v(0.6, 1.8, 0.3), F * CFrame.new(0.5, 2.0, -0.95), MOSS, S)
			B:block(soil, v(0.5, 0.9, 0.3), F * CFrame.new(-0.45, 5.4, -0.95), MOSS_LT, S)
			B:block(soil, v(1.2, 0.3, 1.0), F * CFrame.new(1.2, 8.5, 0.2), MOSS, S)
		end
		-- fallen pillar drum (front-left)
		do
			local p = at(9.4, 228, 1.0)
			local F = CFrame.new(p) * ang(0, -228 + 75, 0)
			B:block(soil, v(2.6, 1.6, 1.6), F * CFrame.new(0, 0.8, 0), STONE, S)
			B:block(soil, v(2.5, 1.35, 1.35), F * CFrame.new(0, 0.8, 0) * ang(45, 0, 0), STONE_LT, S)
			B:block(soil, v(0.3, 1.75, 1.75), F * CFrame.new(-0.6, 0.8, 0), GOLD, S)
		end

		------------------------------------------------------------------
		-- TRUNK (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, DY, 0))
		-- roots over the dais and down onto the tiles
		for k = 0, 5 do
			local a = k * 60 + 25 + jit(6)
			B:bar(crop, at(1.2, a, DY + 1.0), at(3.0, a + 8, DY + 0.05), 1.3, 1.0, k % 2 == 0 and BARK or BARK_DK)
			B:bar(crop, at(2.9, a + 8, DY + 0.15), at(4.4, a + 14, TY + 0.25), 0.9, 0.8, BARK_DK)
		end
		B:block(crop, v(4.0, 1.0, 4.0), cf(0, DY + 0.4, 0, 0, 12, 0), BARK_DK)
		local SEG = { { 3.3, 0.9, 0, BARK }, { 3.0, 2.6, 22, BARK_DK }, { 2.75, 4.3, 44, BARK }, { 2.5, 5.9, 66, BARK_DK }, { 2.3, 7.3, 88, BARK } }
		for i, s in SEG do
			local ox, oz = polar(0.2, i * 80)
			B:block(crop, v(s[1], 1.8, s[1]), cf(ox, DY + s[2] + 0.8, oz, 0, s[3], 0), s[4])
		end
		-- gilded bands
		for _, y in { DY + 2.45, DY + 5.75 } do
			B:block(crop, v(3.25, 0.3, 3.25), cf(0, y, 0, 0, 30, 0), GOLD)
			B:block(crop, v(0.5, 0.36, 0.5), cf(0, y, -1.65, 0, 0, 45), GOLD_LT)
		end
		-- glowing star runes carved into the bark (front + back)
		for k, yaw in { 0, 180 } do
			local F = CFrame.new(0, DY + 4.0, 0) * ang(0, yaw + 44, 0) * CFrame.new(0, 0, -1.4)
			B:block(crop, v(1.2, 1.2, 0.2), F * ang(0, 0, 45), GOLD_DK)
			B:block(crop, v(0.55, 0.55, 0.24), F * CFrame.new(0, 0, -0.02) * ang(0, 0, 45), STAR_C, { mat = "Neon", name = "TrunkRune" .. k })
		end
		-- silver spiral ridges
		for _, a0 in { 30, 210 } do
			local prev
			for i = 0, 4 do
				local f = i / 4
				local p = at(1.55 - f * 0.25, a0 + f * 140, DY + 0.8 + f * 6.6)
				if prev then
					B:bar(crop, prev, p, 0.6, 0.55, i % 2 == 0 and BARK_LT or BARK_HI)
				end
				prev = p
			end
		end
		-- limbs into the crown
		local FORK = DY + 8.6
		B:block(crop, v(2.6, 1.6, 2.6), cf(0, FORK, 0, 0, 80, 0), BARK)
		for k = 0, 3 do
			local a = 45 + k * 90 + jit(8)
			B:bar(crop, at(0.6, a, FORK - 0.5), at(3.6, a + 10, FORK + 2.4), 1.3, 1.2, k % 2 == 0 and BARK or BARK_LT)
		end

		------------------------------------------------------------------
		-- CANOPY (bones Canopy -> CanopyTop)
		------------------------------------------------------------------
		local C0 = FORK + 1.6
		local canopy = B:bone("Canopy", "Crop", v(0, C0, 0))
		local starN = 0
		local function cube(bone, p, s, h, col)
			return B:block(bone, v(s, h, s), CFrame.new(p) * ang(jit(9), rnd() * 90, jit(9)), col)
		end
		local function ring(bone, y, r, n, s, cols, phase, specks, capCol)
			for i = 0, n - 1 do
				local a = i * 360 / n + phase + jit(6)
				local p = at(r + jit(0.3), a, y + jit(0.35))
				local h = s * (0.8 + rnd() * 0.2)
				local col = cols[1 + (i % #cols)]
				cube(bone, p, s + jit(0.2), h, col)
				if i % 3 == 1 then
					B:block(bone, v(1.4, 0.5, 1.4), CFrame.new(p + v(jit(0.4), h * 0.5 + 0.15, jit(0.4))) * ang(0, rnd() * 90, 0), (i % 2 == 0) and NEB or NEB2)
				elseif capCol then
					B:block(bone, v(s * 0.6, 0.45, s * 0.6), CFrame.new(p + v(jit(0.3), h * 0.5 + 0.12, jit(0.3))) * ang(0, rnd() * 90, 0), capCol)
				end
				if specks and i % 2 == 0 and starN < 10 then
					starN += 1
					local o = (p - v(0, p.Y, 0)).Unit
					local sp = p + o * (s * 0.5 + 0.05) + v(0, jit(0.6), 0)
					B:block(bone, v(0.42, 0.42, 0.12), CFrame.new(sp) * ang(0, -a, 0) * ang(0, 0, 45), (starN % 3 == 0) and STAR_P or (starN % 2 == 0 and STAR_C or STAR_W),
						{ mat = "Neon", name = "LeafStar" .. starN })
				end
			end
		end
		-- underside plates + core
		B:block(canopy, v(11, 0.8, 7), cf(0, C0 + 0.3, 0), L_UNDER)
		B:block(canopy, v(7, 0.82, 11), cf(0, C0 + 0.3, 0), L_UNDER)
		B:block(canopy, v(9.4, 0.78, 9.4), cf(0, C0 + 0.3, 0, 0, 45, 0), L_UNDER)
		B:block(canopy, v(10, 3.8, 10), cf(0, C0 + 2.4, 0, 0, 20, 0), L1[2])
		ring(canopy, C0 + 1.1, 6.3, 11, 3.4, L1, 0, true, L2[3])
		ring(canopy, C0 + 3.3, 5.7, 10, 3.4, L2, 16, true, L3[3])
		local top = B:bone("CanopyTop", "Canopy", v(0, C0 + 4.4, 0))
		B:block(top, v(6.6, 3.0, 6.6), cf(0, C0 + 5.2, 0, 0, 40, 0), L2[1])
		ring(top, C0 + 5.4, 3.8, 8, 3.0, L3, 8, true, L4[1])
		ring(top, C0 + 7.0, 1.6, 4, 2.6, L4, 30, false, "#cfe4ff")
		-- little gold star crowning the tree
		B:block(top, v(0.9, 0.9, 0.9), cf(0, C0 + 8.9, 0, 0, 45, 0), STAR_G, { mat = "Neon", name = "CrownStar" })
		B:block(top, v(1.6, 0.5, 0.5), cf(0, C0 + 8.9, 0), GOLD_LT)
		B:block(top, v(0.5, 1.6, 0.5), cf(0, C0 + 8.9, 0), GOLD_LT)
		B:block(top, v(0.5, 0.7, 0.5), cf(0, C0 + 8.2, 0), GOLD_DK)

		------------------------------------------------------------------
		-- NEBULA PEARS (bones PearN, pivot at the stem top under the canopy)
		------------------------------------------------------------------
		local function pear(bone, top, stemLen, s, pal, coreName, yaw0)
			local c0 = top - v(0, stemLen, 0)
			B:bar(bone, top + v(0, 0.5, 0), c0 + v(0, -0.1, 0), 0.32, 0.32, STEM)
			B:block(bone, v(1.3, 0.22, 0.6), CFrame.new(c0 + v(0.55, 0.15, 0)) * ang(0, yaw0 + 20, -20), PLEAF)
			B:block(bone, v(1.0, 0.22, 0.55), CFrame.new(c0 + v(-0.45, 0.25, 0.1)) * ang(0, yaw0 - 40, 18), PLEAF2)
			local function band(size, dy, yaw, col, opts, roll)
				B:block(bone, size, CFrame.new(c0 - v(0, dy * s, 0)) * ang(0, yaw0 + yaw, 0) * ang(0, 0, roll or 0), col, opts)
			end
			band(v(0.75 * s, 0.7 * s, 0.75 * s), 0.35, 45, pal[4])
			band(v(1.25 * s, 1.0 * s, 1.25 * s), 1.05, 20, pal[3])
			band(v(1.75 * s, 0.9 * s, 1.75 * s), 1.9, 0, pal[2])
			band(v(2.3 * s, 1.5 * s, 2.3 * s), 2.9, 0, pal[1])
			band(v(2.0 * s, 1.65 * s, 2.0 * s), 2.85, 45, pal[2])
			band(v(1.5 * s, 0.5 * s, 1.5 * s), 3.8, 45, pal[2])
			-- neon swirl stripes wrapping diagonally across the faces
			band(v(1.7 * s, 0.36 * s, 3.0 * s), 2.65, 0, pal[5], { mat = "Neon", name = coreName }, 26)
			B:block(bone, v(3.0 * s, 0.36 * s, 1.7 * s), CFrame.new(c0 - v(0, 3.05 * s, 0)) * ang(0, yaw0, 0) * ang(-26, 0, 0), pal[5], { mat = "Neon", name = coreName .. "B" })
			-- glossy highlight
			B:block(bone, v(0.45 * s, 0.45 * s, 0.12), CFrame.new(c0 - v(0, 3.25 * s, 0)) * ang(0, yaw0, 0) * CFrame.new(-0.55 * s, 0, -1.17 * s), STONE_HI)
		end
		local PEARS = {
			-- deg, radius, stem length, scale
			{ 10, 5.6, 1.0, 1.2 },
			{ 62, 6.6, 1.9, 1.1 },
			{ 115, 5.4, 1.3, 1.2 },
			{ 165, 6.5, 2.1, 1.1 },
			{ 215, 5.6, 1.1, 1.2 },
			{ 265, 6.5, 1.8, 1.1 },
			{ 315, 5.8, 1.5, 1.15 },
		}
		for i, f in PEARS do
			local topP = at(f[2], f[1], C0 + 0.1)
			local bone = B:bone("Pear" .. i, "Canopy", topP)
			pear(bone, topP, f[3], f[4], PEARS_PAL[1 + ((i - 1) % 3)], "PearCore" .. i, -f[1])
		end

		------------------------------------------------------------------
		-- COMET STARS orbiting the crown (bone "Orbit") + trails
		------------------------------------------------------------------
		local OY = C0 + 4.5
		local orbit = B:bone("Orbit", "Crop", v(0, OY, 0))
		local COMETS = { { 0, 8.6, 1.0, STAR_G }, { 120, 8.4, -1.2, STAR_C }, { 240, 8.8, 0.2, STAR_P } }
		for i, m in COMETS do
			local p = at(m[2], m[1], OY + m[3])
			B:block(orbit, v(0.85, 0.85, 0.85), CFrame.new(p) * ang(45, 45, 0), m[4], { mat = "Neon", name = "Comet" .. i })
			B:block(orbit, v(1.7, 0.4, 0.4), CFrame.new(p) * ang(0, -m[1], 0), STAR_W)
			B:block(orbit, v(0.4, 1.7, 0.4), CFrame.new(p) * ang(0, -m[1], 0), STAR_W)
			B:trail(orbit, p + v(0, 0.7, 0), p - v(0, 0.7, 0), { name = "CometTrail" .. i, color = { STAR_W, m[4] }, life = 0.8, width = { 1, 0 }, trans = { 0.2, 1 } })
		end

		------------------------------------------------------------------
		-- VFX: 8 emitters, 2 lights, 3 trails
		------------------------------------------------------------------
		local crownFx = B:block(canopy, v(15, 10, 15), cf(0, C0 + 5.5, 0), L2[1], { tr = 1, name = "CrownFx" })
		B:emitter(crownFx, "sparkle", { name = "NebulaDust", color = { STAR_W, STAR_P, STAR_C }, rate = 16, size = { 0.15, 0.65, 0 }, life = { 1.0, 2.0 }, speed = { 0.2, 0.7 }, light = 1 })
		B:emitter(crownFx, "glow", { name = "CrownGlow", color = { "#c48cff", "#ff9ae0", "#7fd0ff" }, rate = 1.6, size = { 3.5, 5.5, 2 }, trans = { 0.8, 0.72, 1 }, light = 1 })
		local leafZone = B:block(canopy, v(13, 1, 13), cf(0, C0 + 0.2, 0), L2[1], { tr = 1, name = "LeafZone" })
		B:emitter(leafZone, "leaf", { name = "StarLeaves", color = { L4[1], L3[2], STAR_C }, rate = 2.5, size = { 0.5, 0.5, 0.3 }, life = { 3.5, 5 }, speed = { 0.3, 0.8 }, accel = { 0.4, -1.2, 0.2 }, dir = "Bottom" })
		local pearZone = B:block(canopy, v(12, 1, 12), cf(0, C0 - 3.4, 0), STAR_P, { tr = 1, name = "PearZone" })
		B:emitter(pearZone, "ember", { name = "NebulaMotes", color = { "#ffc4ef", "#b48cff", STAR_C }, rate = 7, size = { 0.35, 0.25, 0 }, life = { 2.5, 3.8 }, speed = { 0.5, 1.2 }, spread = 40, accel = { 0, 0.7, 0 }, light = 1 })
		B:emitter(pearZone, "drip", { name = "PearDrips", color = { "#ffd0f6", STAR_C }, rate = 2, size = { 0.28, 0.24, 0.1 }, life = { 0.7, 1.0 }, light = 1 })
		local surgeFx = B:block(canopy, v(9, 6, 9), cf(0, C0 + 3.5, 0), STAR_P, { tr = 1, name = "SurgeFx" })
		B:emitter(surgeFx, "burst", { name = "SurgeBurst", color = { STAR_W, "#ff9ae0", "#b48cff", STAR_C }, size = { 0.9, 0.6, 0 }, speed = { 9, 17 }, life = { 0.7, 1.3 }, drag = 2.2, light = 1 })
		B:emitter(surgeFx, "ember", { name = "SurgeSparks", color = { "#fff3c0", STAR_P, STAR_C }, rate = 0, size = { 0.45, 0.3, 0 }, life = { 1.6, 2.6 }, speed = { 4, 9 }, spread = 70, accel = { 0, -1.5, 0 }, light = 1 })
		local groundFx = B:block(soil, v(15, 0.4, 15), cf(0, TY + 0.4, 0), STONE, { tr = 1, name = "GroundFx" })
		B:emitter(groundFx, "sparkle", { name = "GroundTwinkles", color = { STAR_W, STAR_C, STAR_G }, rate = 5, size = { 0.1, 0.4, 0 }, life = { 0.8, 1.6 }, speed = { 0.1, 0.5 }, light = 1 })
		local lc = B:block(canopy, v(0.4, 0.4, 0.4), cf(0, C0 + 4.0, 0), STAR_P, { tr = 1, name = "CrownLightCore" })
		B:light(lc, { name = "CrownLight", color = "#c890ff", brightness = 1.2, range = 20 })
		local lp = B:block(canopy, v(0.4, 0.4, 0.4), cf(0, C0 - 3.0, 0), STAR_C, { tr = 1, name = "PearLightCore" })
		B:light(lp, { name = "PearLight", color = "#ff9ae0", brightness = 1.0, range = 16 })
	end,
}
