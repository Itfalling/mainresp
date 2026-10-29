--!nocheck
-- Tomato Plant (Crop #3, Rare) -- Grow a Garden style, kept simple:
-- a plain dirt plot, a thin green stem holding a small leafy bush (a few
-- rounded leaf clumps) with five round red tomatoes, each with a green top.
-- Static prop: no motion.luau.
return {
	DisplayName = "Tomato Plant",
	Rarity = "Rare",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local DIRT, DIRT_DK = "#7b4a28", "#5e381d"
		local LEAF, LEAF_DK = "#43b83d", "#2e8f33"
		local STEM = "#3a8f2e"
		local RED = "#f2302b"
		local CAP = "#2f9a2f"

		-- plain dirt plot
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(5, 0.4, 5), cf(0, 0.2, 0), DIRT_DK, S)
		B:block(soil, v(4.5, 0.15, 4.5), cf(0, 0.475, 0), DIRT, S)

		local crop = B:bone("Crop", "Root", v(0, 0.55, 0))
		-- rounded leaf clump: a wide crossed slab with a narrower one on top
		local function blob(x, y, z, w, h, col)
			local y0 = y - h / 2
			B:block(crop, v(w, h * 0.65, w * 0.7), cf(x, y0 + h * 0.325, z), col)
			B:block(crop, v(w * 0.7, h * 0.65, w), cf(x, y0 + h * 0.325, z), col)
			B:block(crop, v(w * 0.7, h * 0.4, w * 0.7), cf(x, y0 + h * 0.8, z), col)
		end

		-- thin stem
		B:block(crop, v(0.35, 1.6, 0.35), cf(0, 1.3, 0), STEM)

		-- leafy bush: a few rounded clumps
		blob(0, 3.45, 0, 2.6, 1.6, LEAF)
		blob(-1.0, 2.35, 0.1, 1.9, 1.3, LEAF_DK)
		blob(1.0, 2.45, -0.1, 1.9, 1.3, LEAF_DK)
		blob(0, 2.25, 0.8, 1.8, 1.2, LEAF)

		-- five round tomatoes on the outside of the bush, each with a green star top
		local function tomato(x, y, z)
			B:block(crop, v(1.3, 0.6, 0.75), cf(x, y, z), RED)
			B:block(crop, v(0.75, 0.6, 1.3), cf(x, y, z), RED)
			B:block(crop, v(1.1, 0.6, 1.1), cf(x, y, z), RED)
			B:block(crop, v(0.8, 1.0, 0.8), cf(x, y, z), RED)
			B:block(crop, v(0.8, 0.16, 0.25), cf(x, y + 0.56, z), CAP)
			B:block(crop, v(0.25, 0.16, 0.8), cf(x, y + 0.56, z), CAP)
		end
		tomato(0.15, 1.85, -1.1)
		tomato(-1.55, 1.85, -0.6)
		tomato(1.6, 1.95, -0.7)
		tomato(-0.7, 3.15, -1.35)
		tomato(0.8, 3.3, -1.3)
	end,
}
