--!nocheck
-- Autumn Leaf Pile (Harvest Fields filler prop).
-- A low, lumpy heap of fallen autumn leaves raked together: three stepped
-- layers of rotated slabs in orange, red, gold and brown, topped with a few
-- loose flat leaves tilted at odd angles and a small twig, with a couple of
-- strays blown out onto the grass. No motion, no effects.
return {
	DisplayName = "Autumn Leaf Pile",
	Rarity = "Filler",
	Filler = true,
	Element = "Harvest Fields",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"

		-- palette (Harvest Fields autumn leaves)
		local OR, OR_DK = "#f27a1c", "#d0601a"
		local RED, RED_DK = "#d8352a", "#a8281f"
		local GOLD, GOLD_LT = "#f7b52c", "#ffd25a"
		local BROWN = "#a0622e"
		local TWIG = "#5a3720"

		-- heap: stepped layers of rotated slabs {sx, sy, sz, x, y, z, yaw, color}
		local heap = {
			-- bottom layer, wide and flat (darker, shaded leaves)
			{ 4.6, 0.7, 2.6, 0, 0.35, 0.1, 8, OR_DK },
			{ 2.6, 0.72, 3.2, -0.5, 0.36, -0.1, -24, RED_DK },
			{ 2.4, 0.68, 2.4, 1.3, 0.34, -0.5, 40, BROWN },
			-- middle layer
			{ 3.2, 0.7, 2.0, -0.1, 0.95, 0.15, -10, OR },
			{ 2.0, 0.72, 2.6, 0.4, 0.96, -0.2, 28, RED },
			-- top lump + crest
			{ 2.0, 0.65, 1.6, 0.0, 1.5, 0.05, 15, OR },
			{ 1.5, 0.66, 1.5, -0.6, 1.49, -0.15, 50, GOLD },
			{ 1.2, 0.45, 1.0, -0.1, 1.95, 0.05, -20, GOLD_LT },
		}
		for _, h in heap do
			B:block(R, v(h[1], h[2], h[3]), cf(h[4], h[5], h[6], 0, h[7], 0), h[8])
		end

		-- loose flat leaves resting on the ledges {x, y, z, rx, yaw, rz, color}
		local loose = {
			{ 0.5, 2.15, 0.2, 10, 30, -10, RED },
			{ -1.4, 1.38, 0.6, -10, -20, 12, GOLD },
			{ 1.6, 1.4, 0.5, 6, 70, 14, GOLD_LT },
			{ 1.2, 1.38, -1.0, 14, -50, 6, OR },
			{ -2.0, 0.8, -0.7, -8, 15, -10, RED },
			{ 2.1, 0.8, -1.2, 10, 120, 8, GOLD },
			{ -0.4, 0.8, 1.6, -12, 85, -4, BROWN },
		}
		for _, l in loose do
			B:block(R, v(1.1, 0.16, 0.8), cf(l[1], l[2], l[3], l[4], l[5], l[6]), l[7])
		end

		-- a small twig poking out of the heap
		B:bar(R, v(-0.5, 1.3, 0.2), v(-1.8, 2.3, -0.3), 0.2, 0.2, TWIG)
		B:bar(R, v(-1.3, 1.9, -0.1), v(-1.4, 2.5, 0.3), 0.16, 0.16, TWIG)

		-- strays blown onto the grass
		B:block(R, v(1.0, 0.14, 0.75), cf(2.9, 0.07, 1.2, 0, 25, 0), GOLD)
		B:block(R, v(1.0, 0.14, 0.75), cf(-2.8, 0.07, -1.3, 0, -40, 0), RED)
		B:block(R, v(0.9, 0.14, 0.7), cf(0.8, 0.07, -2.3, 0, 65, 0), OR)
	end,
}
