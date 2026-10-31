--!nocheck
-- Ruined Colonnade (Starlight Ruins scenery, big copy-paste filler).
-- Three white-and-gold temple columns still standing in a row under a broken
-- lintel, about 14 studs wide:
-- * footing: flat worn white-violet paving slabs and indigo star tiles with
--   gold inlay, silver-blue grass tufts, star-dust specks (no mound)
-- * each column: stepped plinth with a gold ring, an octagonal fluted shaft
--   (crossed slabs + a turned square, raised light flute ribs), a gold band,
--   stepped capital with gold trim; the right column is snapped off short
-- * the lintel spans the two whole columns and breaks off in a jagged end
--   past the middle one; cornice on top, gold trim line, a gold star carved
--   in its face with a tiny cyan rune; the fallen lintel chunk lies tilted
--   on the paving in front of the snapped column
-- * teal moss on the lintel and capitals with hanging strands, small violet
--   and cyan crystal sprouts at the column feet
-- Scenery filler: anchored, weld-free, no scripts, no effects, no motion.
return {
	DisplayName = "Ruined Colonnade",
	Rarity = "Scenery",
	Filler = true,
	Element = "Starlight Ruins",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		-- palette (Starlight Ruins crops + decorations) ---------------------
		local STONE, STONE2, STONE_DK, STONE_LT, STONE_HI = "#e3dcef", "#d0c7e2", "#a99fc2", "#f4f0fb", "#fbf9ff"
		local GOLD, GOLD_DK, GOLD_LT = "#f2c24f", "#c9952e", "#ffe08a"
		local MOSS, MOSS_DK, MOSS_LT = "#4f9e7c", "#367a62", "#78c79a"
		local TILE_DK, TILE = "#2a2550", "#3b3566"
		local RUNE = "#7fe8ff"
		local DUST_G, DUST_C = "#ffe27a", "#b8f4ff"
		local VIO_DK, VIO, VIO_LT = "#7a58ea", "#9b7cff", "#c6b4ff"
		local CY, CY_LT = "#4fd8f2", "#a8f3ff"
		local GRASS, GRASS_DK = "#8ea9dc", "#6f87c2"
		local NEON = { mat = "Neon" }

		local seed = 31877
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		------------------------------------------------------------------
		-- FOOTING: paving slabs + indigo tiles (flat)
		------------------------------------------------------------------
		local slabs = {
			{ -5.3, 0.0, 4.2, 3.8, 3, STONE2 }, { -1.4, 0.4, 3.6, 3.4, -5, STONE }, { 2.4, -0.2, 3.8, 3.6, 4, STONE2 },
			{ 5.9, 0.3, 3.6, 3.8, -3, STONE }, { -3.4, -3.1, 2.8, 2.0, 8, TILE }, { 1.0, -3.4, 3.2, 2.2, -6, STONE_LT },
			{ 4.6, -3.4, 2.4, 2.0, 12, TILE_DK }, { -0.6, 3.4, 3.0, 2.0, 10, TILE }, { 3.6, 3.4, 2.6, 2.0, -8, STONE2 },
			{ -4.6, 3.2, 2.4, 2.0, -12, STONE_LT }, { -7.2, -2.4, 1.8, 1.6, 15, TILE_DK }, { 7.6, -2.8, 1.6, 1.4, -10, STONE },
		}
		for _, s in slabs do
			local stone = (s[6] ~= TILE and s[6] ~= TILE_DK)
			local h = (stone and 0.4 or 0.3) + rnd(-0.03, 0.03)
			B:block(R, v(s[3], h, s[4]), cf(s[1], h / 2, s[2], 0, s[5], 0), s[6])
		end
		-- gold inlay lines + a star tile
		B:block(R, v(2.2, 0.1, 0.18), cf(-3.4, 0.33, -3.1, 0, 8, 0), GOLD)
		B:block(R, v(0.18, 0.1, 1.6), cf(-0.6, 0.33, 3.4, 0, 10, 0), GOLD)
		B:block(R, v(0.7, 0.11, 0.7), cf(4.6, 0.33, -3.4, 0, 57, 0), GOLD_DK)
		B:block(R, v(0.4, 0.13, 0.4), cf(4.6, 0.35, -3.4, 0, 12, 0), GOLD_LT)

		------------------------------------------------------------------
		-- COLUMNS
		------------------------------------------------------------------
		local F0 = 0.4
		local SH = 2.1 -- shaft thickness
		local function shaftSeg(x, z, y0, h, yaw, col)
			local c = cf(x, y0 + h / 2, z, 0, yaw, 0)
			B:block(R, v(SH, h, SH * 0.45), c, col)
			B:block(R, v(SH * 0.45, h - 0.02, SH), c, col)
			B:block(R, v(SH * 0.74, h - 0.04, SH * 0.74), c * ang(0, 45, 0), STONE2)
			for f = 0, 3 do
				B:block(R, v(0.26, h - 0.5, 0.14), c * ang(0, 45 + f * 90, 0) * CFrame.new(0, 0, -SH * 0.37 - 0.05), STONE_HI)
			end
		end
		local function plinth(x, z, yaw)
			B:block(R, v(3.2, 0.8, 3.2), cf(x, F0 + 0.4, z, 0, yaw, 0), STONE_DK)
			B:block(R, v(3.36, 0.16, 3.36), cf(x, F0 + 0.86, z, 0, yaw, 0), GOLD)
			B:block(R, v(2.8, 0.5, 2.8), cf(x, F0 + 1.15, z, 0, yaw, 0), STONE)
			return F0 + 1.4
		end
		local function capital(x, z, y0, yaw)
			B:block(R, v(2.4, 0.5, 2.4), cf(x, y0 + 0.25, z, 0, yaw, 0), STONE)
			B:block(R, v(2.55, 0.18, 2.55), cf(x, y0 + 0.55, z, 0, yaw, 0), GOLD)
			B:block(R, v(3.2, 0.7, 3.2), cf(x, y0 + 0.97, z, 0, yaw, 0), STONE_LT)
			return y0 + 1.32
		end

		local TOPY
		-- left + middle: whole columns
		for i, c in { { -5.2, 0.1, 2 }, { 0.2, 0.0, -2 } } do
			local x, z, yaw = c[1], c[2], c[3]
			local y = plinth(x, z, yaw)
			shaftSeg(x, z, y, 4.6, yaw, STONE_LT)
			B:block(R, v(2.35, 0.3, 2.35), cf(x, y + 4.6, z, 0, yaw, 0), GOLD)
			shaftSeg(x, z, y + 4.75, 4.4, yaw + 1, STONE)
			TOPY = capital(x, z, y + 9.15, yaw)
		end
		-- right: snapped column (jagged top)
		do
			local x, z, yaw = 5.6, 0.2, 4
			local y = plinth(x, z, yaw)
			shaftSeg(x, z, y, 4.6, yaw, STONE_LT)
			B:block(R, v(2.35, 0.3, 2.35), cf(x, y + 4.6, z, 0, yaw, 0), GOLD)
			shaftSeg(x, z, y + 4.75, 1.3, yaw - 2, STONE)
			local s3 = y + 6.05
			B:block(R, v(1.3, 1.0, 1.5), cf(x - 0.35, s3 + 0.45, z + 0.2, 0, 8, -6), STONE)
			B:block(R, v(0.8, 0.7, 0.9), cf(x - 0.45, s3 + 1.1, z + 0.3, 0, 25, 9), STONE_LT)
			B:block(R, v(1.0, 0.5, 1.1), cf(x + 0.5, s3 + 0.15, z - 0.4, 0, -10, 5), STONE_HI)
			B:block(R, v(1.0, 0.12, 0.9), cf(x + 0.45, s3 + 0.42, z + 0.4, 0, 15, 0), STONE_DK)
			-- moss on the snap + a strand
			B:block(R, v(1.6, 0.22, 1.3), cf(x + 0.15, s3 + 0.12, z + 0.2, 3, 10, -3), MOSS)
			B:block(R, v(0.5, 2.0, 0.28), cf(x - 0.6, s3 - 0.9, z + 0.98, 0, 4, 0), MOSS_DK)
		end

		------------------------------------------------------------------
		-- LINTEL (spans left + middle, breaks off past the middle)
		------------------------------------------------------------------
		local LY = TOPY -- bottom of the lintel
		local L0, L1 = -7.0, 2.4
		local LC = (L0 + L1) / 2
		local LL = L1 - L0
		B:block(R, v(LL, 2.0, 2.6), cf(LC, LY + 1.0, 0.05), STONE)
		-- darker underside / soffit strip and a gold trim line on the front
		B:block(R, v(LL - 0.4, 0.3, 2.3), cf(LC, LY + 0.12, 0.05), STONE_DK)
		B:block(R, v(LL - 0.2, 0.2, 0.12), cf(LC, LY + 0.55, -1.28), GOLD)
		B:block(R, v(LL - 0.2, 0.2, 0.12), cf(LC, LY + 0.55, 1.38), GOLD_DK)
		-- cornice on top (lighter, wider), stepped
		B:block(R, v(LL + 0.4, 0.5, 3.1), cf(LC - 0.1, LY + 2.25, 0.05), STONE_LT)
		B:block(R, v(LL - 0.6, 0.4, 2.4), cf(LC - 0.2, LY + 2.7, 0.05), STONE_HI)
		-- dentil blocks under the cornice front
		for k = 0, 5 do
			B:block(R, v(0.5, 0.35, 0.3), cf(L0 + 0.8 + k * 1.5, LY + 1.82, -1.32), STONE2)
		end
		-- jagged broken end (+X)
		B:block(R, v(1.2, 1.4, 2.3), cf(L1 + 0.45, LY + 0.95, 0.1, 0, 0, -8), STONE)
		B:block(R, v(0.8, 0.9, 1.8), cf(L1 + 1.05, LY + 1.5, -0.1, 0, 10, 12), STONE_LT)
		B:block(R, v(0.7, 0.6, 1.2), cf(L1 + 0.9, LY + 0.45, 0.4, 0, -15, 20), STONE2)
		B:block(R, v(0.12, 1.4, 2.0), cf(L1 + 0.02, LY + 1.4, 0.05), STONE_DK)
		-- gold star carved in the face between the columns
		local SF = CFrame.new(-2.5, LY + 1.15, -1.32)
		B:block(R, v(1.8, 0.36, 0.12), SF, GOLD)
		B:block(R, v(0.36, 1.8, 0.12), SF, GOLD)
		B:block(R, v(1.15, 0.28, 0.13), SF * ang(0, 0, 45), GOLD_LT)
		B:block(R, v(0.28, 1.15, 0.13), SF * ang(0, 0, 45), GOLD_LT)
		B:block(R, v(0.42, 0.42, 0.16), SF * ang(0, 0, 45), RUNE, NEON)
		-- moss over the lintel + hanging strands
		B:block(R, v(3.2, 0.24, 2.0), cf(-4.6, LY + 2.95, 0.3, 0, 4, 0), MOSS)
		B:block(R, v(1.8, 0.22, 1.4), cf(-4.2, LY + 3.1, 0.1, 0, 20, 0), MOSS_LT)
		B:block(R, v(2.2, 0.24, 1.8), cf(0.6, LY + 2.95, 0.4, 0, -8, 0), MOSS)
		B:block(R, v(0.6, 1.8, 0.26), cf(-5.6, LY + 1.4, -1.5), MOSS_DK)
		B:block(R, v(0.5, 1.1, 0.26), cf(-4.9, LY + 1.8, -1.5), MOSS)
		B:block(R, v(0.55, 1.5, 0.26), cf(1.3, LY + 1.6, 1.5), MOSS_DK)
		B:block(R, v(0.6, 2.4, 0.26), cf(-6.9, LY + 1.0, 0.6, 0, 90, 0), MOSS)

		------------------------------------------------------------------
		-- FALLEN LINTEL CHUNK in front of the snapped column
		------------------------------------------------------------------
		local FC = CFrame.new(5.0, 1.55, -3.0) * ang(0, -18, 8)
		B:block(R, v(3.8, 2.0, 2.4), FC, STONE)
		B:block(R, v(4.1, 0.45, 2.8), FC * CFrame.new(0, 1.15, 0.1), STONE_LT)
		B:block(R, v(3.6, 0.2, 0.12), FC * CFrame.new(0, -0.45, -1.24), GOLD)
		B:block(R, v(0.12, 1.6, 1.9), FC * CFrame.new(-1.92, 0.1, 0), STONE_DK)
		B:block(R, v(0.9, 0.8, 1.2), FC * CFrame.new(-2.1, -0.4, 0.4) * ang(10, 20, 15), STONE2)
		B:block(R, v(1.6, 0.22, 1.1), FC * CFrame.new(0.5, 1.45, 0.2) * ang(0, 15, 0), MOSS)
		-- loose drum chunk
		B:block(R, v(1.6, 1.3, 1.4), cf(7.5, 1.05, 2.5, 0, 30, 6), STONE_LT)
		B:block(R, v(1.2, 0.3, 1.1), cf(7.5, 1.8, 2.5, 0, 40, 6), STONE2)

		------------------------------------------------------------------
		-- CRYSTAL SPROUTS at the column feet, chips, dust, grass
		------------------------------------------------------------------
		local function sprout(p, sc, yaw)
			local base = CFrame.new(p) * ang(0, yaw, 0)
			B:block(R, v(0.6 * sc, 1.7 * sc, 0.6 * sc), base * CFrame.new(0, 0.6 * sc, 0) * ang(-10, 45, 6), VIO)
			B:block(R, v(0.34 * sc, 0.5 * sc, 0.34 * sc), base * CFrame.new(0.12 * sc, 1.55 * sc, -0.17 * sc) * ang(-10, 45, 6), VIO_LT)
			B:block(R, v(0.42 * sc, 1.1 * sc, 0.42 * sc), base * CFrame.new(0.5 * sc, 0.35 * sc, -0.1 * sc) * ang(-14, 20, -28), CY)
			B:block(R, v(0.26 * sc, 0.3 * sc, 0.26 * sc), base * CFrame.new(0.78 * sc, 0.86 * sc, -0.25 * sc) * ang(-14, 20, -28), CY_LT)
			B:block(R, v(0.38 * sc, 0.9 * sc, 0.38 * sc), base * CFrame.new(-0.42 * sc, 0.25 * sc, 0.05 * sc) * ang(8, 55, 30), VIO_DK)
		end
		sprout(v(-7.0, 0.4, -1.4), 1.2, -30)
		sprout(v(2.0, 0.4, -1.7), 0.9, 40)
		sprout(v(-1.7, 0.4, 2.0), 0.8, 160)
		for _, c in { { -2.4, -2.0, 0.7, STONE }, { 3.0, 2.4, 0.6, STONE_LT }, { -6.6, 2.4, 0.55, STONE2 }, { 7.6, -1.0, 0.6, STONE } } do
			B:block(R, v(c[3], c[3] * 0.7, c[3] * 0.9), cf(c[1], 0.4 + c[3] * 0.3, c[2], rnd(-10, 10), rnd(0, 90), rnd(-10, 10)), c[4])
		end
		for _, d in { { -1.8, -1.9, DUST_G }, { 3.4, 1.6, DUST_C }, { -6.2, 1.4, DUST_C }, { 2.4, -2.6, DUST_G }, { -3.6, 2.2, DUST_G } } do
			B:block(R, v(0.28, 0.16, 0.28), cf(d[1], 0.46, d[2], 0, rnd(0, 90), 0), d[3])
		end
		for _, g in { { -7.8, 0.2, 0.0 }, { -3.0, 0.4, -1.8 }, { 3.6, 0.4, -1.4 }, { 7.9, 0.0, -0.8 }, { 1.6, 0.4, 2.4 } } do
			local base = CFrame.new(g[1], g[2], g[3]) * ang(0, rnd(0, 90), 0)
			for k = -1, 1 do
				B:block(R, v(0.22, 0.9 - math.abs(k) * 0.25, 0.22), base * CFrame.new(k * 0.25, 0.45, 0) * ang(0, 0, -k * 22), (k == 0) and GRASS or GRASS_DK)
			end
		end
	end,
}
