--!nocheck
-- Neon Hedge Cube (Bunny Meadow filler). A neatly trimmed party hedge cube in
-- a low purple planter with a gold rim. The planter has two thin neon
-- lines (front and back) just under the rim (the only glow). The hedge has bevelled edges
-- (crossed blocks), a slightly domed lighter top, and a few proud leaf
-- patches in a second green for texture.
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Neon Hedge Cube",
	Rarity = "Filler",
	Filler = true,
	Element = "Bunny Meadow",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		local LEAF_DK, LEAF, LEAF_LT, LEAF_TOP = "#23863a", "#38ad46", "#4fc24c", "#6ad85a"
		local PURP_DK, PURP = "#5b1fc4", "#7e3cf0"
		local GOLD, GOLD_DK = "#ffc62e", "#d9961a"
		local N_PINK = "#ff5cc8"

		------------------------------------------------------------ planter
		B:block(R, v(3.6, 0.3, 3.6), cf(0, 0.15, 0), PURP_DK)
		B:block(R, v(3.4, 0.6, 3.4), cf(0, 0.6, 0), PURP)
		-- the neon trim: two thin lines on the front and back, just under the rim
		for i, s in { -1, 1 } do
			B:block(R, v(3.0, 0.14, 0.12), cf(0, 0.95, s * 1.73), N_PINK, { mat = "Neon", name = "Trim" .. i })
		end
		B:block(R, v(3.7, 0.3, 3.7), cf(0, 1.19, 0), GOLD)
		B:block(R, v(3.2, 0.1, 3.2), cf(0, 1.37, 0), GOLD_DK)

		------------------------------------------------------------ hedge
		local Y0, Y1 = 1.3, 4.1
		local H, Y = Y1 - Y0, (Y0 + Y1) / 2
		-- bevelled cube: a core plus two crossed slabs (chamfered vertical edges)
		B:block(R, v(3.0, H - 0.3, 2.4), cf(0, Y - 0.15, 0), LEAF)
		B:block(R, v(2.4, H - 0.3, 3.0), cf(0, Y - 0.15, 0), LEAF)
		B:block(R, v(2.8, H - 0.5, 2.8), cf(0, Y - 0.25, 0), LEAF_DK)
		-- domed lighter top
		B:block(R, v(2.6, 0.4, 2.6), cf(0, Y1 - 0.2, 0), LEAF_TOP)
		B:block(R, v(1.8, 0.2, 1.8), cf(0, Y1 + 0.1, 0, 0, 45, 0), LEAF_LT)

		-- proud leaf patches in two greens (one or two per side, offset)
		local patches = {
			{ 0.6, 2.2, -1.52, 1.1, 0.9, 0.2, LEAF_DK },
			{ -0.55, 3.25, -1.52, 0.9, 0.8, 0.2, LEAF_LT },
			{ 1.52, 3.0, 0.4, 0.2, 0.9, 1.1, LEAF_LT },
			{ 1.52, 1.95, -0.6, 0.2, 0.7, 0.8, LEAF_DK },
			{ -0.3, 2.5, 1.52, 1.0, 1.0, 0.2, LEAF_DK },
			{ -1.52, 2.85, -0.2, 0.2, 1.0, 1.0, LEAF_DK },
			{ -1.52, 1.9, 0.75, 0.2, 0.6, 0.7, LEAF_LT },
		}
		for _, p in patches do
			B:block(R, v(p[4], p[5], p[6]), cf(p[1], p[2], p[3]), p[7])
		end
	end,
}
