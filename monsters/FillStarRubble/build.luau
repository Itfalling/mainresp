--!nocheck
-- Ruin Rubble (Starlight Ruins filler).
-- A few broken white-violet temple stone blocks: a big fallen block with a
-- gold band and a snapped, stepped top, a standing fluted drum fragment
-- with a gold band, a tipped little block with a gold inlay, two stone chips
-- and a tuft of teal moss. Same palette as the Broken Star Pillar.
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Ruin Rubble",
	Rarity = "Filler",
	Filler = true,
	Element = "Starlight Ruins",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"

		local STONE, STONE2, STONE_DK, STONE_LT = "#e3dcef", "#d0c7e2", "#a99fc2", "#f4f0fb"
		local GOLD, GOLD_DK = "#f2c24f", "#c9952e"
		local MOSS, MOSS_DK = "#4f9e7c", "#367a62"

		-- big fallen block (lying on its side, slightly tilted)
		local A = cf(-0.7, 0.7, 0.25, 0, 18, 4)
		B:block(R, v(2.6, 1.4, 1.8), A, STONE)
		B:block(R, v(0.3, 1.46, 1.86), A * CFrame.new(0.55, 0, 0), GOLD) -- gold band
		B:block(R, v(1.2, 0.5, 1.4), A * CFrame.new(-0.6, 0.85, 0.1), STONE_LT) -- snapped step
		B:block(R, v(0.7, 0.35, 0.9), A * CFrame.new(-0.85, 1.25, -0.05), STONE2)
		B:block(R, v(0.9, 0.16, 0.8), A * CFrame.new(0.75, 0.75, 0.3), MOSS)
		B:block(R, v(0.5, 0.5, 0.12), A * CFrame.new(-0.1, 0.05, -0.92), GOLD_DK) -- gold rune square

		-- standing fluted drum fragment (cross-section like the pillar drums)
		-- with a gold band and a snapped, stepped top
		local U = cf(1.4, -0.05, -0.5, 0, -22, -5)
		B:block(R, v(1.6, 1.2, 0.75), U * CFrame.new(0, 0.6, 0), STONE2)
		B:block(R, v(0.75, 1.2, 1.6), U * CFrame.new(0, 0.6, 0), STONE2)
		B:block(R, v(1.3, 1.18, 1.3), U * CFrame.new(0, 0.6, 0), STONE_DK)
		B:block(R, v(1.66, 0.2, 0.8), U * CFrame.new(0, 0.3, 0), GOLD)
		B:block(R, v(0.8, 0.2, 1.66), U * CFrame.new(0, 0.3, 0), GOLD)
		B:block(R, v(0.75, 0.55, 1.6), U * CFrame.new(-0.1, 1.45, 0), STONE) -- jagged top
		B:block(R, v(0.5, 0.3, 0.75), U * CFrame.new(-0.45, 1.85, 0.2), STONE_LT)

		-- small tipped block
		local T = cf(0.85, 0.42, 1.35, 12, 40, -8)
		B:block(R, v(0.95, 0.85, 0.95), T, STONE_LT)
		B:block(R, v(1.0, 0.14, 1.0), T * CFrame.new(0, 0.2, 0), GOLD_DK)

		-- chips + a moss tuft on the ground
		B:block(R, v(0.5, 0.35, 0.45), cf(-2.15, 0.17, -0.85, 0, 30, 0), STONE_DK)
		B:block(R, v(0.4, 0.3, 0.4), cf(0.15, 0.15, -1.35, 0, 15, 0), STONE)
		B:block(R, v(0.8, 0.2, 0.6), cf(0.5, 0.1, 0.1, 0, -10, 0), MOSS_DK)
	end,
}
