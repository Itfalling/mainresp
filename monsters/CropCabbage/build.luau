--!nocheck
-- Cabbage (Crop #2, Uncommon) -- Grow a Garden style, kept simple:
-- a plain dirt plot, a round pale-green head (stepped octagon slabs) loosely
-- cupped by five big darker-green outer leaves whose tops curl outward.
-- GREEN only. Static prop: no motion.luau.
return {
	DisplayName = "Cabbage",
	Rarity = "Uncommon",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local DIRT, DIRT_DK = "#7b4a28", "#5e381d"
		local HEAD, HEAD_DK, HEAD_LT = "#ade36b", "#8fcc52", "#cdf393"
		local LEAF, LEAF_DK = "#46ad3e", "#2f8a33"

		-- plain dirt plot
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(5, 0.4, 5), cf(0, 0.2, 0), DIRT_DK, S)
		B:block(soil, v(4.5, 0.15, 4.5), cf(0, 0.475, 0), DIRT, S)

		local crop = B:bone("Crop", "Root", v(0, 0.55, 0))
		-- round slab: three crossed blocks give a stepped octagon
		local function round(w, y0, y1, col)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(crop, v(w, h, w * 0.6), cf(0, y, 0), col)
			B:block(crop, v(w * 0.6, h, w), cf(0, y, 0), col)
			B:block(crop, v(w * 0.85, h, w * 0.85), cf(0, y, 0), col)
		end
		-- the head
		round(2.0, 0.5, 0.95, HEAD_DK)
		round(2.6, 0.95, 1.5, HEAD)
		round(2.9, 1.5, 2.2, HEAD)
		round(2.6, 2.2, 2.75, HEAD)
		round(2.0, 2.75, 3.15, HEAD)
		round(1.1, 3.15, 3.35, HEAD_LT)

		-- five big outer leaves standing round the head, tops curling out
		local H = 1.5
		for i = 0, 4 do
			local a = math.rad(i * 72 + 18)
			local base = CFrame.new(0, 0.5, 0) * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -1.1)
				* CFrame.Angles(math.rad(-40), 0, 0)
			B:block(crop, v(1.8, H, 0.3), base * CFrame.new(0, H / 2, 0), LEAF_DK)
			B:block(crop, v(2.2, 0.8, 0.3), base * CFrame.new(0, H - 0.1, 0) * CFrame.Angles(math.rad(-30), 0, 0)
				* CFrame.new(0, 0.3, 0), LEAF)
		end
	end,
}
