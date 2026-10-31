--!nocheck
-- Carrot Sprouts (Bunny Meadow filler, v2). Three carrots of different sizes
-- peeking out of a little tilled-dirt patch, built like the carrot crops:
-- * rounded stepped orange shoulders (crossed slabs = rounded square), darker
--   bottom where they meet the soil, light top band, dark crown ring, a couple
--   of dark ridge lines and a pale shine
-- * leaf tufts like CropCarrot: thin dark stalks fanned out, each ending in a
--   flat leaf (light + dark greens), the middle one tallest
-- * the biggest carrot wears a gold band (the meadow's VIP golden-carrot nod)
-- * grounding: a low irregular dirt patch with furrow lines, clods, two low
--   grass tufts
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Carrot Sprouts",
	Rarity = "Filler",
	Filler = true,
	Element = "Bunny Meadow",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		-- Bunny Meadow palette (BunnyNeonLime / DecorBunnyRope / DecorBunnySign)
		local DIRT_DK, DIRT, DIRT_LT = "#4a2a16", "#744526", "#93603a"
		local CARROT, CARROT_DK, CARROT_LT = "#ff8a1c", "#d6600c", "#ffab4a"
		local LEAF, LEAF_DK, LEAF_LT = "#5fd645", "#349a2c", "#86e255"
		local GOLD, GOLD_LT = "#ffc62e", "#ffe27a"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local SHINE = "#ffc477"

		------------------------------------------------------------ dirt patch
		B:block(R, v(3.6, 0.12, 2.6), cf(0, 0.06, 0, 0, 8, 0), DIRT_DK)
		B:block(R, v(2.7, 0.18, 3.3), cf(0.05, 0.09, 0, 0, 8, 0), DIRT)
		-- furrow lines and clods
		for i, z in { -0.8, 0.85 } do
			B:block(R, v(2.4, 0.06, 0.18), cf(0.1 * i, 0.2, z, 0, 8, 0), DIRT_DK)
		end
		local clods = { { 1.35, -0.95, 0.4 }, { -1.5, 0.8, 0.35 }, { 0.9, 1.3, 0.3 }, { -1.2, -1.05, 0.3 } }
		for i, c in clods do
			B:block(R, v(c[3], c[3] * 0.6, c[3]), cf(c[1], 0.18 + c[3] * 0.3, c[2], 0, i * 25, 0), (i % 2 == 0) and DIRT_LT or DIRT)
		end

		------------------------------------------------------------ carrots
		local function carrot(x, z, s, ry, gold)
			local base = CFrame.new(x, 0.15, z) * CFrame.Angles(0, math.rad(ry), 0)
			local function slab(w, y0, y1, col)
				local h, y = (y1 - y0) * s, (y0 + y1) / 2 * s
				B:block(R, v(w * s, h, w * s * 0.62), base * CFrame.new(0, y, 0), col)
				B:block(R, v(w * s * 0.62, h, w * s), base * CFrame.new(0, y, 0), col)
			end
			slab(1.25, 0, 0.35, CARROT_DK) -- where it meets the soil
			slab(1.45, 0.35, 0.95, CARROT)
			slab(1.3, 0.95, 1.25, CARROT_LT)
			slab(0.9, 1.25, 1.4, gold and GOLD or CARROT_DK)
			-- ridge lines + shine
			B:block(R, v(0.6 * s, 0.08, 0.08), base * CFrame.new(0.1 * s, 0.55 * s, -0.73 * s), CARROT_DK)
			B:block(R, v(0.08, 0.08, 0.55 * s), base * CFrame.new(-0.73 * s, 0.75 * s, 0.1 * s), CARROT_DK)
			B:block(R, v(0.14 * s, 0.3 * s, 0.06), base * CFrame.new(-0.35 * s, 0.85 * s, -0.74 * s), SHINE)
			if gold then
				B:block(R, v(1.0 * s, 0.1, 1.0 * s), base * CFrame.new(0, 1.43 * s, 0) * CFrame.Angles(0, math.rad(45), 0), GOLD_LT)
			end
			-- leaf tuft: CropCarrot-style stalks, each ending in a flat leaf
			local top = 1.35 * s
			local stalks = { { 0, 0, 1.15, LEAF }, { 0, -34, 0.95, LEAF_DK }, { 0, 34, 0.95, LEAF }, { -32, 0, 0.9, LEAF_LT }, { 32, 0, 0.9, LEAF_DK } }
			for _, st in stalks do
				local len = st[3] * s
				local sc = base * CFrame.new(0, top, 0) * CFrame.Angles(math.rad(st[1]), 0, math.rad(st[2]))
				B:block(R, v(0.18, len, 0.18), sc * CFrame.new(0, len / 2, 0), LEAF_DK)
				B:block(R, v(0.55 * s, 0.75 * s, 0.16), sc * CFrame.new(0, len, 0), st[4])
			end
		end
		carrot(-0.6, 0.3, 1.0, 15, true)
		carrot(0.85, -0.25, 0.78, -20, false)
		carrot(-0.15, -1.0, 0.62, 40, false)

		------------------------------------------------------------ tufts
		local function tuft(x, z, h, ry)
			local b = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(ry), 0)
			B:block(R, v(0.3, h, 0.3), b * CFrame.new(0, h / 2, 0), GRASS)
			B:block(R, v(0.26, h * 0.75, 0.26), b * CFrame.new(0.26, h * 0.36, 0.05) * CFrame.Angles(0, 0, math.rad(-20)), GRASS_DK)
			B:block(R, v(0.26, h * 0.65, 0.26), b * CFrame.new(-0.24, h * 0.32, -0.05) * CFrame.Angles(0, 0, math.rad(22)), GRASS)
		end
		tuft(1.85, 0.6, 0.7, 20)
		tuft(-1.9, -0.55, 0.6, -40)
	end,
}
