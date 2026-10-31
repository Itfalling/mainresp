--!nocheck
-- Mossy Rock (Thorny Woods filler prop).
-- A chunky grey forest boulder built from a few overlapping, slightly turned
-- stone blocks in three greys (light on top, dark low down), with a thick
-- green moss cap over its top that drips down the back side, two light moss
-- tufts, a loose pebble and a little grass tuft at its foot.
-- No motion, no effects.
return {
	DisplayName = "Mossy Rock",
	Rarity = "Filler",
	Filler = true,
	Element = "Thorny Woods",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"

		-- palette (Thorny Woods stone + moss)
		local STONE, STONE_LT, STONE_DK = "#8d8a80", "#a9a397", "#686660"
		local MOSS, MOSS_DK, MOSS_LT = "#5fae3a", "#3f8a2c", "#86c94a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"

		-- boulder: overlapping turned blocks
		local body = cf(0, 0.9, 0, 3, 10, -3)
		B:block(R, v(3.4, 1.8, 2.8), body, STONE)
		B:block(R, v(2.2, 1.4, 2.4), cf(-1.45, 0.7, 0.35, 0, -22, 4), STONE_DK)
		local low = cf(1.55, 0.5, -1.0, -4, 38, 6)
		B:block(R, v(1.7, 1.1, 1.5), low, STONE_DK)
		local top = cf(0.25, 2.05, 0.0, 7, 28, -6)
		B:block(R, v(2.4, 0.9, 2.0), top, STONE_LT)
		B:block(R, v(1.6, 0.9, 1.4), cf(-1.2, 1.65, 0.35, -4, -14, 6), STONE)

		-- moss cap over the top, dripping down the back
		B:block(R, v(2.0, 0.28, 1.7), top * CFrame.new(-0.1, 0.55, 0.1), MOSS)
		B:block(R, v(1.4, 0.26, 1.2), cf(-1.25, 2.15, 0.45, -4, -14, 6), MOSS_DK)
		B:block(R, v(2.2, 0.26, 1.2), body * CFrame.new(0.3, 0.95, 0.9), MOSS_DK)
		B:block(R, v(1.6, 1.0, 0.26), body * CFrame.new(0.1, 0.5, 1.48), MOSS)
		B:block(R, v(0.8, 0.6, 0.26), body * CFrame.new(-0.75, 0.1, 1.5), MOSS_DK)
		-- moss creeping over the front edge and onto the low ledge
		B:block(R, v(1.3, 0.26, 0.9), body * CFrame.new(-0.85, 0.95, -1.0), MOSS)
		B:block(R, v(1.2, 0.8, 0.26), body * CFrame.new(-0.85, 0.6, -1.48), MOSS)
		B:block(R, v(1.3, 0.22, 1.1), low * CFrame.new(0.05, 0.62, 0.05), MOSS_DK)
		-- light moss tufts
		B:block(R, v(0.7, 0.4, 0.7), top * CFrame.new(0.45, 0.8, -0.2) * CFrame.Angles(0, 0.6, 0), MOSS_LT)
		B:block(R, v(0.55, 0.35, 0.55), cf(-1.5, 2.4, 0.2, 0, 20, 0), MOSS_LT)

		-- loose pebble and a grass tuft at the foot
		B:block(R, v(0.8, 0.5, 0.7), cf(2.35, 0.25, 0.75, 0, 25, 0), STONE)
		B:block(R, v(0.4, 0.9, 0.4), cf(-2.45, 0.45, -0.75, 0, 15, 14), GRASS)
		B:block(R, v(0.35, 0.65, 0.35), cf(-2.15, 0.32, -1.05, 0, 40, -16), GRASS_DK)
	end,
}
