--!nocheck
-- Broken Star Pillar (Starlight Ruins decoration, small/medium accent).
-- A white-and-gold fluted temple pillar that snapped and toppled:
-- * footing: a few worn white-violet paving slabs and indigo star tiles on
--   Y=0, silver-blue grass tufts, star-dust specks and stone chips
-- * the broken STUMP (left): plinth, base ring, two fluted drums with a gold
--   band and a jagged snapped top, a glowing cyan rune line up its front
-- * the FALLEN SHAFT lying to the right: three fluted drums knocked slightly
--   out of line, gold bands at the joints, glowing rune lines running along
--   the flutes (with little glyph ticks), the CAPITAL resting at the far end
--   with a gold star on its face
-- * teal moss draping over the drums and the stump, a small violet/cyan
--   crystal sprout pushing out of the crack between two drums
-- * VFX: soft rune twinkles. Static (no motion).
-- Blocks only (no wedges / round parts).
return {
	DisplayName = "Broken Star Pillar",
	Rarity = "Decor",
	Element = "Starlight Ruins",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Starlight Ruins crops) -----------------------------------
		local STONE, STONE2, STONE_DK, STONE_LT, STONE_HI = "#e3dcef", "#d0c7e2", "#a99fc2", "#f4f0fb", "#fbf9ff"
		local GOLD, GOLD_DK, GOLD_LT = "#f2c24f", "#c9952e", "#ffe08a"
		local MOSS, MOSS_DK, MOSS_LT = "#4f9e7c", "#367a62", "#78c79a"
		local TILE_DK, TILE = "#2a2550", "#3b3566"
		local RUNE = "#7fe8ff"
		local DUST_G, DUST_C = "#ffe27a", "#b8f4ff"
		local VIO_DK, VIO, VIO_LT = "#7a58ea", "#9b7cff", "#c6b4ff"
		local CY, CY_LT = "#4fd8f2", "#a8f3ff"
		local GRASS, GRASS_DK = "#8ea9dc", "#6f87c2"
		local R = "Root"

		local seed = 22801
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- FOOTING: paving slabs + indigo tiles
		------------------------------------------------------------------
		local slabs = {
			{ -4.9, 0.3, 3.8, 3.6, 4, STONE2 },
			{ -1.6, -0.9, 2.9, 2.7, -8, STONE },
			{ 1.3, 0.6, 3.0, 2.9, 6, STONE2 },
			{ 4.3, -0.4, 2.8, 3.1, -4, STONE },
			{ -2.3, 2.0, 2.0, 1.6, 12, TILE },
			{ 2.4, -2.4, 2.3, 1.6, -10, TILE },
			{ 0.5, -2.6, 1.6, 1.3, 25, STONE_LT },
			{ -6.4, -2.0, 1.6, 1.4, -15, TILE_DK },
			{ -3.2, -2.6, 1.4, 1.2, 8, STONE },
		}
		for i, s in slabs do
			local h = (s[6] == STONE or s[6] == STONE2) and 0.4 or 0.3
			B:block(R, v(s[3], h + rnd(-0.03, 0.03), s[4]), cf(s[1], h / 2, s[2], 0, s[5], 0), s[6])
		end
		-- gold inlay lines on two indigo tiles
		B:block(R, v(1.4, 0.1, 0.16), cf(-2.3, 0.33, 2.0, 0, 12, 0), GOLD)
		B:block(R, v(1.5, 0.1, 0.16), cf(2.4, 0.33, -2.4, 0, -10, 0), GOLD)
		B:block(R, v(0.3, 0.12, 0.3), cf(2.4, 0.35, -2.4, 0, 35, 0), RUNE, NEON)

		------------------------------------------------------------------
		-- STUMP (left)
		------------------------------------------------------------------
		local SX, SZ = -4.9, 0.3
		local F0 = 0.4
		B:block(R, v(3.0, 0.7, 3.0), cf(SX, F0 + 0.35, SZ, 0, 4, 0), STONE_DK)
		B:block(R, v(2.7, 0.4, 2.7), cf(SX, F0 + 0.9, SZ, 0, 4, 0), STONE)
		B:block(R, v(2.86, 0.14, 2.86), cf(SX, F0 + 0.72, SZ, 0, 4, 0), GOLD)
		local s0 = F0 + 1.1
		-- drums 1 + 2 (whole)
		for k = 0, 1 do
			local y = s0 + k * 1.8
			local c = cf(SX + (k == 1 and 0.04 or 0), y + 0.9, SZ, 0, 4 - 2 * k, 0)
			B:block(R, v(2.2, 1.8, 0.92), c, (k == 0) and STONE_LT or STONE)
			B:block(R, v(0.92, 1.78, 2.2), c, (k == 0) and STONE_LT or STONE)
			B:block(R, v(1.58, 1.76, 1.58), c * ang(0, 45, 0), STONE2)
			for f = 0, 3 do
				B:block(R, v(0.26, 1.4, 0.14), c * ang(0, 45 + f * 90, 0) * CFrame.new(0, 0, -0.85), STONE_HI)
			end
		end
		B:block(R, v(2.35, 0.3, 2.35), cf(SX, s0 + 1.8, SZ, 0, 4, 0), GOLD)
		-- drum 3, snapped: jagged top made of offset chunks
		local s3 = s0 + 3.6
		B:block(R, v(2.2, 0.9, 0.92), cf(SX, s3 + 0.45, SZ, 0, 1, 0), STONE_LT)
		B:block(R, v(0.92, 0.88, 2.2), cf(SX, s3 + 0.45, SZ, 0, 1, 0), STONE_LT)
		B:block(R, v(1.58, 0.86, 1.58), cf(SX, s3 + 0.45, SZ, 0, 46, 0), STONE2)
		B:block(R, v(1.2, 0.9, 1.4), cf(SX - 0.45, s3 + 1.3, SZ + 0.25, 0, 6, -6), STONE)
		B:block(R, v(0.75, 0.6, 0.85), cf(SX - 0.55, s3 + 1.95, SZ + 0.35, 0, 20, 9), STONE_LT)
		B:block(R, v(0.9, 0.5, 1.0), cf(SX + 0.55, s3 + 1.05, SZ - 0.45, 0, -12, 5), STONE_HI)
		-- broken face (fresh darker stone) at the snap
		B:block(R, v(1.1, 0.12, 1.0), cf(SX + 0.45, s3 + 0.95, SZ + 0.45, 0, 15, 0), STONE_DK)
		-- rune line up the front of the stump (+ glyph ticks)
		local FZ = SZ - 1.13
		B:block(R, v(0.2, 3.6, 0.12), cf(SX + 0.58, s0 + 2.1, FZ, 0, 4, 0), RUNE, { mat = "Neon", name = "StumpRune" })
		for i, y in { 0.8, 1.9, 3.0 } do
			B:block(R, v(0.5, 0.18, 0.12), cf(SX + 0.58 - 0.32 * ((i % 2 == 0) and -1 or 1), s0 + y, FZ, 0, 4, 0), RUNE, NEON)
		end
		B:block(R, v(0.34, 0.34, 0.12), cf(SX - 0.5, s0 + 1.2, FZ, 0, 4, 45), RUNE, NEON)
		B:block(R, v(0.34, 0.34, 0.12), cf(SX - 0.5, s0 + 2.9, FZ, 0, 4, 45), RUNE, NEON)
		-- moss over the snapped top + hanging strands
		B:block(R, v(1.8, 0.24, 1.5), cf(SX + 0.1, s3 + 0.98, SZ + 0.15, 4, 10, -3), MOSS)
		B:block(R, v(0.55, 2.2, 0.3), cf(SX - 0.95, s3 - 0.3, SZ + 0.98, 0, 4, 0), MOSS_DK)
		B:block(R, v(0.5, 1.2, 0.3), cf(SX + 1.08, s3 + 0.1, SZ + 0.4, 0, 94, 0), MOSS)
		B:block(R, v(1.5, 0.22, 0.6), cf(SX - 0.3, s3 + 0.8, SZ + 1.15, -50, 4, 0), MOSS_LT)

		------------------------------------------------------------------
		-- FALLEN SHAFT (axis along +X, lying on the slabs)
		------------------------------------------------------------------
		local AY = 1.5 -- axis height
		local D = 2.2
		-- horizontal fluted drum: frame c (axis = local X)
		local function drum(c, len, col, col2)
			B:block(R, v(len, D, 0.42 * D), c, col)
			B:block(R, v(len - 0.02, 0.42 * D, D), c, col)
			B:block(R, v(len - 0.04, 0.72 * D, 0.72 * D), c * ang(45, 0, 0), col2)
			-- raised flute ribs on the four diagonal faces
			for k = 0, 3 do
				B:block(R, v(len - 0.5, 0.26, 0.14), c * ang(45 + k * 90, 0, 0) * CFrame.new(0, 0, -0.36 * D - 0.06), STONE_HI)
			end
		end
		local drums = {
			{ -1.35, 2.4, -0.1, 4, 2 },
			{ 1.2, 2.3, 0.2, -6, -6 },
			{ 3.55, 2.0, -0.15, 9, 9 },
		}
		local frames = {}
		for i, d in drums do
			local c = CFrame.new(d[1], AY, d[3]) * ang(d[5], d[4], 0)
			frames[i] = { c, d[2] }
			drum(c, d[2], (i % 2 == 1) and STONE_LT or STONE, STONE2)
			-- gold band at the drum's left end
			B:block(R, v(0.3, D + 0.12, D + 0.12), c * CFrame.new(-d[2] / 2 + 0.25, 0, 0), GOLD)
		end
		-- capital at the far right end, resting on the ground
		do
			local c = CFrame.new(5.05, 1.6, 0.05) * ang(0, 7, 3)
			B:block(R, v(0.5, 2.9, 2.9), c * CFrame.new(-0.25, 0, 0), STONE_LT)
			B:block(R, v(0.15, 3.05, 3.05), c * CFrame.new(0.07, 0, 0), GOLD)
			B:block(R, v(0.5, 3.2, 3.2), c * CFrame.new(0.4, 0, 0), STONE)
			-- gold star on the capital face (8 points: two crosses)
			local face = c * CFrame.new(0.7, 0, 0)
			B:block(R, v(0.12, 2.3, 0.4), face, GOLD)
			B:block(R, v(0.12, 0.4, 2.3), face, GOLD)
			B:block(R, v(0.13, 1.5, 0.32), face * ang(45, 0, 0), GOLD_LT)
			B:block(R, v(0.13, 0.32, 1.5), face * ang(45, 0, 0), GOLD_LT)
			B:block(R, v(0.16, 0.55, 0.55), face * ang(45, 0, 0), RUNE, { mat = "Neon", name = "CapitalStar" })
			-- chipped corner
			B:block(R, v(0.7, 0.6, 0.8), CFrame.new(5.7, 0.7, -1.95) * ang(0, 30, 12), STONE2)
		end
		-- rune lines running along the front flutes of the fallen drums
		for i, f in frames do
			local c, len = f[1], f[2]
			local yOff = (i % 2 == 1) and 0.12 or -0.12
			local runeF = c * CFrame.new(0.15, yOff, -D / 2 - 0.05)
			B:block(R, v(len - 0.9, 0.18, 0.12), runeF, RUNE, { mat = "Neon", name = "ShaftRune" .. i })
			-- glyph ticks
			for k = -1, 1, 2 do
				B:block(R, v(0.18, 0.4, 0.12), runeF * CFrame.new(k * (len - 1.3) * 0.3, (yOff > 0) and -0.18 or 0.18, 0), RUNE, NEON)
			end
			-- dot on the top flute
			B:block(R, v(0.3, 0.12, 0.3), c * CFrame.new(-0.4 + 0.3 * i, D / 2 + 0.04, -0.2) * ang(0, 45, 0), RUNE, NEON)
		end

		-- moss draping over the drums
		for _, m in { { 1, -0.4, 1.8, MOSS }, { 2, 0.5, 1.5, MOSS_LT }, { 3, -0.2, 1.2, MOSS } } do
			local c = frames[m[1]][1]
			B:block(R, v(m[3], 0.2, 1.0), c * CFrame.new(m[2], D / 2 + 0.08, 0.3), m[4])
			B:block(R, v(m[3] * 0.6, 0.2, 0.8), c * CFrame.new(m[2] + 0.3, D / 2 + 0.16, 0.05) * ang(0, 15, 0), MOSS_LT)
			B:block(R, v(m[3] * 0.7, 0.22, 0.9), c * CFrame.new(m[2] - 0.1, D / 2 - 0.15, 0.85) * ang(-45, 0, 0), MOSS)
			B:block(R, v(m[3] * 0.45, 1.0, 0.22), c * CFrame.new(m[2] + 0.1, 0.1, D / 2 + 0.06), MOSS_DK)
		end
		B:block(R, v(0.8, 0.6, 0.22), frames[2][1] * CFrame.new(-0.6, 0.62, -D / 2 + 0.05) * ang(-25, 0, 0), MOSS)

		-- crystal sprouts: one in the crack between drum 1 and drum 2, one at the stump foot
		local function sprout(p, sc, yaw)
			local base = CFrame.new(p) * ang(0, yaw, 0)
			B:block(R, v(0.6 * sc, 1.7 * sc, 0.6 * sc), base * CFrame.new(0, 0.6 * sc, 0) * ang(-10, 45, 6), VIO)
			B:block(R, v(0.34 * sc, 0.5 * sc, 0.34 * sc), base * CFrame.new(0.12 * sc, 1.55 * sc, -0.17 * sc) * ang(-10, 45, 6), VIO_LT)
			B:block(R, v(0.42 * sc, 1.1 * sc, 0.42 * sc), base * CFrame.new(0.5 * sc, 0.35 * sc, -0.1 * sc) * ang(-14, 20, -28), CY)
			B:block(R, v(0.26 * sc, 0.3 * sc, 0.26 * sc), base * CFrame.new(0.78 * sc, 0.86 * sc, -0.25 * sc) * ang(-14, 20, -28), CY_LT)
			B:block(R, v(0.38 * sc, 0.9 * sc, 0.38 * sc), base * CFrame.new(-0.42 * sc, 0.25 * sc, 0.05 * sc) * ang(8, 55, 30), VIO_DK)
		end
		sprout(v(-0.1, AY + 0.55, -0.45), 1.25, 0)
		sprout(v(-6.3, 0.4, -1.1), 1.0, -40)
		sprout(v(5.6, 0.2, 1.9), 0.75, 60)
		-- loose chips + star dust + grass tufts
		for _, c in { { 2.3, -2.0, 0.7, STONE }, { -6.2, 1.5, 0.55, STONE_LT }, { 0.6, 2.4, 0.5, STONE2 }, { -2.4, -2.2, 0.6, STONE } } do
			B:block(R, v(c[3], c[3] * 0.7, c[3] * 0.9), cf(c[1], 0.32 + c[3] * 0.3, c[2], rnd(-10, 10), rnd(0, 90), rnd(-10, 10)), c[4])
		end
		for _, d in { { -1.8, 0.42, -1.9, DUST_G }, { 2.9, 0.42, 1.6, DUST_C }, { -5.7, 0.42, 1.4, DUST_C }, { 4.9, 0.42, -1.9, DUST_G }, { 0.4, 0.42, 1.7, DUST_G } } do
			B:block(R, v(0.26, 0.16, 0.26), cf(d[1], d[2], d[3], 0, rnd(0, 90), 0), d[4])
		end
		for _, g in { { -6.0, 0.25, -0.6 }, { 0.2, 0.4, -1.9 }, { 5.9, 0.0, 1.6 }, { -2.8, 0.3, 2.9 }, { 2.4, 0.4, 1.9 } } do
			local base = CFrame.new(g[1], g[2], g[3]) * ang(0, rnd(0, 90), 0)
			for k = -1, 1 do
				local h = (k == 0) and 1.2 or 0.85
				B:block(R, v(0.24, h, 0.28), base * ang(0, 0, k * 24) * CFrame.new(0, h / 2, 0), (k == 0) and GRASS or GRASS_DK)
			end
		end

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local zone = B:block(R, v(10, 3.5, 2.6), cf(0, 2.2, 0), CY, { tr = 1, name = "RuneZone" })
		B:emitter(zone, "sparkle", { name = "RuneTwinkle", color = { RUNE, "#ffffff", GOLD_LT }, rate = 4, size = { 0.12, 0.38, 0 }, life = { 0.9, 1.7 }, speed = { 0.1, 0.4 }, light = 1 })
	end,
}
