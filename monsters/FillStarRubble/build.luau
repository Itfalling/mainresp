--!nocheck
-- Ruin Rubble (Starlight Ruins filler).
-- A small heap of broken star-temple masonry in the Broken Star Pillar style:
-- * a fallen fluted pillar drum lying on its side (crossed slabs + a 45° core
--   make the flutes), a gold band with a dark under-trim near one end, a
--   jagged snapped end, a pale highlight along the top flute and a tiny
--   glowing cyan rune tick
-- * a tipped cornice block with a gold trim edge and a gold star inlay
-- * a short standing fluted stub with a snapped top and a thin rune glow
-- * a small chipped cube with a stepped broken top, loose stone chips
-- * teal moss draped over the stones (three tones)
-- * footing: low indigo night-soil patch, a cracked paving slab with a gold
--   inlay line, silver-blue grass tufts and gold/cyan star-dust specks
-- Every stone has shadow / main / highlight tones. Filler: anchored,
-- weld-free, no scripts, no effects.
return {
	DisplayName = "Ruin Rubble",
	Rarity = "Filler",
	Filler = true,
	Element = "Starlight Ruins",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		-- palette (Starlight Ruins: Stardust Sprout / Broken Star Pillar)
		local EARTH_DK, EARTH, EARTH_LT = "#2a2550", "#3b3566", "#4d4684"
		local STONE, STONE2, STONE_DK, STONE_LT, STONE_HI = "#e3dcef", "#d0c7e2", "#a99fc2", "#f4f0fb", "#fbf9ff"
		local GOLD, GOLD_DK, GOLD_LT = "#f2c24f", "#c9952e", "#ffe08a"
		local MOSS, MOSS_DK, MOSS_LT = "#4f9e7c", "#367a62", "#78c79a"
		local RUNE = "#7fe8ff"
		local DUST_G, DUST_C = "#ffe27a", "#b8f4ff"
		local GRASS, GRASS_DK = "#8ea9dc", "#6f87c2"
		local NEON = { mat = "Neon" }

		------------------------------------------------------------ footing
		local function patch(x, z, s, h, yaw, col, col2)
			B:block(R, v(s, h, s * 0.56), cf(x, h / 2, z, 0, yaw, 0), col)
			B:block(R, v(s * 0.56, h - 0.01, s), cf(x, h / 2, z, 0, yaw, 0), col)
			B:block(R, v(s * 0.68, h + 0.02, s * 0.68), cf(x, (h + 0.02) / 2, z, 0, yaw + 45, 0), col2 or col)
		end
		patch(0.1, 0.1, 4.6, 0.12, 10, EARTH_DK, EARTH)
		-- cracked paving slab with a gold inlay line
		B:block(R, v(1.7, 0.22, 1.5), cf(1.4, 0.11, 1.15, 0, -12, 0), STONE2)
		B:block(R, v(0.9, 0.24, 1.5), cf(0.35, 0.12, 1.35, 0, -4, 0), STONE_DK)
		B:block(R, v(1.4, 0.06, 0.16), cf(1.4, 0.25, 1.15, 0, -12, 0), GOLD)
		-- moss patch on the soil
		B:block(R, v(1.1, 0.16, 0.8), cf(-2.1, 0.08, 0.1, 0, 20, 0), MOSS_DK)
		B:block(R, v(0.6, 0.18, 0.5), cf(-2.2, 0.09, 0.2, 0, 50, 0), MOSS)

		local function tuft(x, z, s, yaw)
			for k = 0, 2 do
				local h = (0.55 + 0.18 * k) * s
				B:block(R, v(0.16, h, 0.16), CFrame.new(x, 0.1 + h / 2, z) * ang(0, yaw + k * 120, 0) * ang(30, 0, 0) * CFrame.new(0, 0, -0.12), (k == 1) and GRASS_DK or GRASS)
			end
		end
		tuft(-2.5, -0.6, 1.0, 10)
		tuft(2.4, -0.3, 0.85, 60)
		tuft(0.4, 2.3, 0.75, 100)

		for _, d in { { -0.9, -1.9, DUST_G }, { 2.0, 0.6, DUST_C }, { -2.3, 1.0, DUST_G }, { 1.0, -1.7, DUST_C } } do
			B:block(R, v(0.2, 0.14, 0.2), cf(d[1], 0.14, d[2], 0, 45, 0), d[3])
		end

		------------------------------------------------------------ fallen drum
		-- lies along local X; L = length, r = half thickness
		local D = cf(-0.55, 0.82, -0.2, 0, 22, 0)
		local L = 2.5
		B:block(R, v(L, 1.6, 0.72), D, STONE)
		B:block(R, v(L, 0.72, 1.6), D, STONE)
		B:block(R, v(L - 0.04, 1.25, 1.25), D * ang(45, 0, 0), STONE2) -- flutes
		B:block(R, v(L * 0.85, 0.12, 0.5), D * CFrame.new(-0.1, 0.8, 0), STONE_HI) -- top flute highlight
		B:block(R, v(L * 0.9, 0.14, 1.0), D * CFrame.new(0, -0.74, 0), STONE_DK) -- underside shadow
		-- gold band + dark under-trim near the +X end
		local gb = D * CFrame.new(0.75, 0, 0)
		B:block(R, v(0.26, 1.68, 0.78), gb, GOLD)
		B:block(R, v(0.26, 0.78, 1.68), gb, GOLD)
		B:block(R, v(0.24, 1.32, 1.32), gb * ang(45, 0, 0), GOLD_DK)
		B:block(R, v(0.3, 0.14, 0.6), gb * CFrame.new(0, 0.86, 0), GOLD_LT)
		-- jagged snapped end (-X)
		B:block(R, v(0.4, 1.1, 1.2), D * CFrame.new(-L / 2 - 0.15, 0.1, -0.1), STONE_LT)
		B:block(R, v(0.3, 0.6, 0.7), D * CFrame.new(-L / 2 - 0.4, 0.35, 0.15), STONE)
		B:block(R, v(0.25, 0.4, 0.5), D * CFrame.new(-L / 2 - 0.3, -0.45, -0.3), STONE_DK)
		-- tiny glowing rune tick on the side flute + gold glyph line
		B:block(R, v(0.7, 0.12, 0.06), D * CFrame.new(-0.25, 0.1, -0.82), GOLD_DK)
		B:block(R, v(0.18, 0.18, 0.08), D * CFrame.new(0.2, 0.1, -0.84) * ang(0, 0, 45), RUNE, NEON)
		-- moss draped over the top
		B:block(R, v(0.9, 0.16, 1.1), D * CFrame.new(-0.35, 0.82, 0.05), MOSS)
		B:block(R, v(0.5, 0.18, 0.7), D * CFrame.new(-0.25, 0.88, 0.1), MOSS_LT)
		B:block(R, v(0.4, 0.6, 0.14), D * CFrame.new(-0.4, 0.45, 0.82), MOSS_DK) -- drip down the back

		------------------------------------------------------------ cornice block
		local C = cf(1.45, 0.62, -0.75, 0, -28, 9)
		B:block(R, v(1.5, 1.05, 1.3), C, STONE)
		B:block(R, v(1.4, 0.14, 1.2), C * CFrame.new(0, 0.56, 0), STONE_LT)
		B:block(R, v(1.56, 0.2, 1.36), C * CFrame.new(0, -0.45, 0), STONE_DK)
		B:block(R, v(1.6, 0.16, 0.24), C * CFrame.new(0, 0.38, -0.6), GOLD) -- gold trim edge
		B:block(R, v(1.6, 0.08, 0.26), C * CFrame.new(0, 0.26, -0.61), GOLD_DK)
		-- gold star inlay on the front face
		local S = C * CFrame.new(0, -0.05, -0.68)
		B:block(R, v(0.62, 0.14, 0.06), S, GOLD)
		B:block(R, v(0.14, 0.62, 0.06), S, GOLD)
		B:block(R, v(0.3, 0.3, 0.08), S * ang(0, 0, 45), GOLD_LT)
		-- moss tuft on its top corner
		B:block(R, v(0.55, 0.14, 0.5), C * CFrame.new(0.4, 0.66, 0.3), MOSS)

		------------------------------------------------------------ chipped cube
		local K = cf(0.75, 0.4, 1.15, 6, 35, -4)
		B:block(R, v(0.85, 0.75, 0.85), K, STONE2)
		B:block(R, v(0.9, 0.14, 0.9), K * CFrame.new(0, -0.32, 0), STONE_DK)
		B:block(R, v(0.5, 0.25, 0.85), K * CFrame.new(-0.18, 0.48, 0), STONE_LT) -- stepped broken top
		B:block(R, v(0.3, 0.15, 0.45), K * CFrame.new(0.2, 0.43, 0.15), STONE_HI)

		------------------------------------------------------------ stump
		-- a short standing fluted drum stub at the back-left for height
		local T = cf(-1.05, 0, 1.7, 0, 12, 0)
		B:block(R, v(1.5, 0.3, 1.5), T * CFrame.new(0, 0.22, 0), STONE_DK)
		B:block(R, v(1.56, 0.12, 1.56), T * CFrame.new(0, 0.42, 0), GOLD_DK)
		B:block(R, v(1.25, 1.5, 0.56), T * CFrame.new(0, 1.2, 0), STONE)
		B:block(R, v(0.56, 1.5, 1.25), T * CFrame.new(0, 1.2, 0), STONE)
		B:block(R, v(0.98, 1.48, 0.98), T * CFrame.new(0, 1.2, 0) * ang(0, 45, 0), STONE2)
		B:block(R, v(0.6, 0.5, 1.2), T * CFrame.new(-0.3, 2.15, 0), STONE_LT) -- snapped top
		B:block(R, v(0.45, 0.3, 0.6), T * CFrame.new(0.25, 2.0, -0.25), STONE_HI)
		B:block(R, v(0.5, 0.6, 0.14), T * CFrame.new(0.25, 1.4, 0.64), MOSS_DK)
		B:block(R, v(0.12, 0.8, 0.12), T * CFrame.new(0, 1.2, -0.66), RUNE, NEON)

		------------------------------------------------------------ chips
		local function chip(x, z, s, yaw, col, top)
			B:block(R, v(0.55 * s, 0.35 * s, 0.5 * s), cf(x, 0.12 + 0.17 * s, z, 0, yaw, 0), col)
			B:block(R, v(0.35 * s, 0.18 * s, 0.3 * s), cf(x, 0.12 + 0.42 * s, z, 0, yaw + 30, 0), top)
		end
		chip(-2.1, -1.2, 1.0, 20, STONE_DK, STONE)
		chip(0.2, -1.75, 0.8, 50, STONE, STONE_HI)
		chip(2.35, 0.9, 0.7, -15, STONE2, STONE_LT)
	end,
}
