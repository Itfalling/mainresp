--!nocheck
-- Wooden Fence (Sunny Farm filler). A straight 6-stud ranch-fence section that
-- tiles end to end along X: two posts at x = +-1.5 (so tiled copies keep an even
-- 3-stud post rhythm) and two chunky plank rails running the full 6 studs, each
-- with a lighter top edge. Stepped post caps and a dark foot ring. Rails end
-- exactly at x = +-3 so neighbours butt cleanly.
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Wooden Fence",
	Rarity = "Filler",
	Filler = true,
	Element = "Sunny Farm",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		local WOOD_LT, WOOD, WOOD_DK = "#c98a4b", "#a8692f", "#6b4220"
		local GRASS, GRASS_DK = "#5fd23f", "#3fb43a"

		-- posts
		for i, x in { -1.5, 1.5 } do
			B:block(R, v(1.1, 0.5, 1.1), cf(x, 0.25, 0), WOOD_DK) -- foot
			B:block(R, v(0.9, 3.6, 0.9), cf(x, 2.1, 0), WOOD) -- post
			B:block(R, v(1.1, 0.35, 1.1), cf(x, 4.05, 0), WOOD_DK) -- cap
			B:block(R, v(0.6, 0.35, 0.6), cf(x, 4.4, 0, 0, 45, 0), WOOD_LT) -- cap top
			-- a short grass tuft hugging the foot (mirrored side per post)
			local s = (i == 1) and -1 or 1
			B:block(R, v(0.45, 0.85, 0.45), cf(x + s * 0.55, 0.42, -0.6, 0, 20, s * -14), GRASS)
			B:block(R, v(0.35, 0.6, 0.35), cf(x - s * 0.3, 0.3, 0.65, 0, -15, s * 12), GRASS_DK)
		end

		-- rails (front of the posts), full 6-stud length so sections tile
		for _, y in { 1.5, 3.1 } do
			B:block(R, v(6, 0.7, 0.4), cf(0, y, -0.65), WOOD)
			B:block(R, v(6, 0.18, 0.46), cf(0, y + 0.3, -0.65), WOOD_LT)
			B:block(R, v(6, 0.14, 0.44), cf(0, y - 0.3, -0.65), WOOD_DK)
		end
		-- nail plates where rails cross the posts
		for _, x in { -1.5, 1.5 } do
			for _, y in { 1.5, 3.1 } do
				B:block(R, v(0.4, 0.3, 0.1), cf(x, y, -0.9), "#7c858f")
			end
		end
	end,
}
