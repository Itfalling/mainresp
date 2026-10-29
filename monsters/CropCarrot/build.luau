--!nocheck
-- Carrot (Crop #1, Common) -- Grow a Garden style, kept simple:
-- a plain dirt plot, a long bright-orange root tapering down into the dirt
-- (stepped plus-shaped slabs read round), and a tuft of thin green leaf stalks.
-- Static prop: no motion.luau.
return {
	DisplayName = "Carrot",
	Rarity = "Common",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local DIRT, DIRT_DK = "#7b4a28", "#5e381d"
		local OR, OR_DK = "#ff8c1a", "#e0660c"
		local LEAF, LEAF_DK = "#4fd23f", "#2f9f34"

		-- plain dirt plot
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(4, 0.4, 4), cf(0, 0.2, 0), DIRT_DK, S)
		B:block(soil, v(3.5, 0.15, 3.5), cf(0, 0.475, 0), DIRT, S)

		local crop = B:bone("Crop", "Root", v(0, 0.55, 0))
		-- round-ish slab: two crossed blocks
		local function slab(w, y0, y1, col)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(crop, v(w, h, w * 0.6), cf(0, y, 0), col)
			B:block(crop, v(w * 0.6, h, w), cf(0, y, 0), col)
		end
		-- root: thin tip down in the dirt, wide shoulder on top
		slab(0.4, 0.35, 0.75, OR_DK)
		slab(0.7, 0.75, 1.2, OR)
		slab(0.95, 1.2, 1.7, OR)
		slab(1.2, 1.7, 2.2, OR)
		slab(1.35, 2.2, 2.65, OR)
		slab(0.9, 2.65, 2.8, OR_DK)

		-- tuft of thin leaf stalks, each ending in a small flat leaf
		local function stalk(rx, rz, len, col)
			local base = CFrame.new(0, 2.75, 0) * CFrame.Angles(math.rad(rx), 0, math.rad(rz))
			B:block(crop, v(0.25, len, 0.25), base * CFrame.new(0, len / 2, 0), LEAF_DK)
			B:block(crop, v(0.6, 0.85, 0.2), base * CFrame.new(0, len - 0.05, 0), col)
		end
		stalk(0, 0, 0.95, LEAF)
		stalk(0, -36, 0.85, LEAF)
		stalk(0, 36, 0.85, LEAF)
		stalk(-34, 0, 0.8, LEAF)
		stalk(34, 0, 0.8, LEAF)
	end,
}
