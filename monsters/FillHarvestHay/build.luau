--!nocheck
-- Hay Bale (Harvest Fields filler prop).
-- One chunky golden straw bale lying on the ground: a solid bale body with a
-- darker shaded bottom course, a sun-bleached top, rough pale straw end caps,
-- two red twine bands wrapped all the way round, a few straw tufts poking out
-- of the top and two loose straws on the grass. Lightweight and anchored, made
-- to be copy-pasted all over the fields. No motion, no effects.
return {
	DisplayName = "Hay Bale",
	Rarity = "Filler",
	Filler = true,
	Element = "Harvest Fields",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"

		-- palette (Harvest Fields hay)
		local HAY, HAY_DK, HAY_LT, HAY_HI = "#e6bd55", "#c4922e", "#f4d98a", "#fbe8ae"
		local TWINE, TWINE_DK = "#c8402a", "#9a2c1c"

		local L, H, D = 4.0, 2.4, 2.5 -- bale length (X), height, depth (Z)

		-- bale body: shaded bottom course, main body, stepped-in bleached top course
		B:block(R, v(L, 0.5, D), cf(0, 0.25, 0), HAY_DK)
		B:block(R, v(L - 0.04, H - 0.9, D - 0.04), cf(0, 0.5 + (H - 0.9) / 2, 0), HAY)
		B:block(R, v(L - 0.3, 0.45, D - 0.3), cf(0, H - 0.4 + 0.225, 0), HAY_LT)
		B:block(R, v(L - 0.1, 0.2, D - 0.1), cf(0, H - 0.45, 0), HAY)
		-- pressed flake line along the long sides
		B:block(R, v(L + 0.04, 0.18, D + 0.04), cf(0, 1.2, 0), HAY_LT)
		-- rough straw end caps: two stepped layers, pale in the middle
		for s = -1, 1, 2 do
			B:block(R, v(0.2, H - 0.5, D - 0.4), cf(s * (L / 2 + 0.06), H / 2 - 0.05, 0), HAY_LT)
			B:block(R, v(0.14, H - 1.2, D - 1.1), cf(s * (L / 2 + 0.16), H / 2 - 0.05 + s * 0.1, -s * 0.1), HAY_HI)
		end
		-- twine bands wrapped all the way round (one block each, slightly bigger than the bale)
		for _, x in { -1.0, 1.0 } do
			B:block(R, v(0.28, H + 0.26, D + 0.1), cf(x, H / 2 + 0.1, 0), TWINE)
		end
		-- knot on the top of one band
		B:block(R, v(0.4, 0.16, 0.4), cf(1.0, H + 0.2, -0.3, 0, 35, 0), TWINE_DK)
		-- straw tufts poking out of the top
		B:block(R, v(0.22, 0.7, 0.22), cf(-0.4, H + 0.3, 0.4, 0, 20, 14), HAY_HI)
		B:block(R, v(0.2, 0.55, 0.2), cf(-0.15, H + 0.22, 0.55, 0, 40, -18), HAY_LT)
		B:block(R, v(0.2, 0.6, 0.2), cf(1.6, H + 0.24, -0.6, 12, 0, -10), HAY_LT)
		-- loose straws on the grass
		B:block(R, v(1.3, 0.14, 0.24), cf(-1.4, 0.07, -1.75, 0, 18, 0), HAY_LT)
		B:block(R, v(1.0, 0.14, 0.24), cf(2.2, 0.07, 1.6, 0, -55, 0), HAY)
	end,
}
