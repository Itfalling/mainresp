--!nocheck
-- Tomato Vine (Rare crop): a leafy tomato plant tied to a wooden garden stake
-- with twine, on a stepped soil patch. Clusters of juicy stepped-round red
-- tomatoes (3-tier plus cross-section, dark-red underside, pink shine squares,
-- green star calyx tops) plus a couple of orange unripe ones, bright green
-- zig-zag vine + branches, blocky leaf clumps and two little yellow flowers.
-- Static prop: no motion.luau. Soil parts live on the "Soil" bone.
return {
	DisplayName = "Tomato Vine",
	Rarity = "Rare",
	Element = "Nature",
	Build = function(B, P)
		local v, cf = P.v, P.cf

		local RED, RED_DK, RED_LT, SHINE = "#ec1c24", "#a30f1e", "#ff5c4d", "#fff6f0"
		local ORG, ORG_DK, ORG_LT = "#ff8a12", "#d6580a", "#ffc04a"
		local STEM, STEM_DK = "#3cb83a", "#1f7a2c"
		local LEAF, LEAF_DK, LEAF_LT = "#27b04a", "#147536", "#9cf05a"
		local CALYX = "#167a2e"
		local WOOD, WOOD_DK, WOOD_LT = "#b8783e", "#7a4a22", "#dca267"
		local TWINE = "#f3dfa2"
		local SOIL, SOIL_DK, SOIL_LT, PEBBLE = "#6e4227", "#472915", "#8d5a33", "#a49a8c"
		local YEL, YEL_DK = "#ffd81a", "#ff9800"

		local root = "Root"
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }

		------------------------------------------------------------------
		-- SOIL PATCH: stepped tilled mound with clods + pebble
		------------------------------------------------------------------
		B:block(soil, v(5.4, 0.45, 4.8), cf(0, 0.225, 0), SOIL_DK, S)
		B:block(soil, v(4.6, 0.4, 4.0), cf(0, 0.62, 0), SOIL, S)
		B:block(soil, v(3.2, 0.3, 2.8), cf(0, 0.94, 0), SOIL_LT, S)
		-- furrow ridges along the front/back edges
		-- clods + pebbles
		B:block(soil, v(0.7, 0.35, 0.6), cf(-1.9, 1.0, -1.2), SOIL_DK, S)
		B:block(soil, v(0.6, 0.3, 0.7), cf(2.0, 0.95, 1.3), SOIL_DK, S)
		B:block(soil, v(0.5, 0.3, 0.5), cf(1.3, 1.15, -1.0), SOIL_DK, S)
		B:block(soil, v(0.5, 0.35, 0.45), cf(-2.2, 0.75, 1.9), PEBBLE, S)
		B:block(soil, v(0.4, 0.25, 0.4), cf(2.45, 0.55, -1.9), PEBBLE, S)

		------------------------------------------------------------------
		-- STAKE + TWINE
		------------------------------------------------------------------
		local SX, SZ = 0.35, 0.4
		B:block(root, v(0.6, 5.9, 0.6), cf(SX, 3.85, SZ), WOOD)
		B:block(root, v(0.2, 5.6, 0.1), cf(SX - 0.12, 3.8, SZ - 0.33), WOOD_DK) -- grain strip
		B:block(root, v(0.7, 0.3, 0.7), cf(SX, 6.85, SZ), WOOD_LT) -- cut top
		for _, y in { 2.6, 4.7 } do
			B:block(root, v(1.45, 0.22, 1.3), cf(0.05, y, 0.12), TWINE)
			B:block(root, v(0.3, 0.3, 0.25), cf(-0.55, y - 0.2, -0.5), TWINE) -- knot tail
		end

		------------------------------------------------------------------
		-- VINE: zig-zag stepped main stem + branches
		------------------------------------------------------------------
		B:block(root, v(0.55, 1.9, 0.55), cf(-0.2, 1.95, -0.15), STEM)
		B:block(root, v(0.5, 2.2, 0.5), cf(-0.42, 3.75, -0.15), STEM)
		B:block(root, v(0.45, 2.0, 0.45), cf(-0.2, 5.65, -0.15), STEM)
		B:block(root, v(0.6, 0.25, 0.6), cf(-0.3, 2.85, -0.15), STEM_DK) -- node
		B:block(root, v(0.55, 0.25, 0.55), cf(-0.3, 4.75, -0.15), STEM_DK) -- node
		local function branch(a, b) B:beam(root, a, b, 0.32, 0.32, STEM) end
		-- A: right low
		branch(v(-0.2, 3.1, -0.2), v(1.95, 3.1, -0.45))
		branch(v(1.9, 3.15, -0.45), v(1.9, 2.55, -0.45))
		-- B: left mid
		branch(v(-0.4, 4.3, -0.2), v(-2.1, 4.3, -0.35))
		branch(v(-2.05, 4.35, -0.35), v(-2.05, 3.85, -0.35))
		-- C: right high
		branch(v(-0.2, 5.55, -0.15), v(1.7, 5.55, -0.3))
		branch(v(1.7, 5.6, -0.3), v(1.7, 5.05, -0.3))
		-- D: back
		branch(v(-0.2, 3.8, 0), v(-0.2, 3.8, 1.6))

		------------------------------------------------------------------
		-- TOMATOES: stepped-round (3-tier plus) with shine + star calyx
		------------------------------------------------------------------
		local function tomato(x, y, z, s, ripe)
			local m, d, l = RED, RED_DK, RED_LT
			if not ripe then m, d, l = ORG, ORG_DK, ORG_LT end
			B:block(root, v(0.7 * s, 0.9 * s, 0.7 * s), cf(x, y, z), m) -- core
			B:block(root, v(s, 0.56 * s, 0.76 * s), cf(x, y + 0.02 * s, z), m) -- X band
			B:block(root, v(0.76 * s, 0.56 * s, s), cf(x, y + 0.02 * s, z), m) -- Z band
			B:block(root, v(0.86 * s, 0.2 * s, 0.86 * s), cf(x, y - 0.34 * s, z), d) -- shadow ring
			B:block(root, v(0.28 * s, 0.24 * s, 0.1), cf(x - 0.17 * s, y + 0.12 * s, z - 0.5 * s - 0.04), l) -- highlight
			if s >= 1.1 then
				B:block(root, v(0.13 * s, 0.13 * s, 0.1), cf(x - 0.24 * s, y + 0.19 * s, z - 0.5 * s - 0.1), SHINE) -- shine
			end
			-- star calyx + stem nub
			B:block(root, v(0.66 * s, 0.1, 0.2 * s), cf(x, y + 0.47 * s, z), CALYX)
			B:block(root, v(0.2 * s, 0.1, 0.66 * s), cf(x, y + 0.47 * s, z), CALYX)
		end
		-- cluster A (right, low)
		tomato(1.9, 2.0, -0.45, 1.45, true)
		tomato(1.1, 1.75, -1.15, 1.05, true)
		tomato(2.45, 1.75, 0.5, 1.0, false)
		-- cluster B (left, mid)
		tomato(-2.05, 3.25, -0.35, 1.4, true)
		tomato(-1.3, 2.75, -1.05, 1.05, true)
		tomato(-2.35, 2.55, 0.65, 1.0, true)
		-- cluster C (right, high)
		tomato(1.7, 4.45, -0.35, 1.2, true)
		tomato(2.15, 4.2, 0.55, 0.9, false)
		-- top left, hanging under the crown
		tomato(-1.35, 5.75, -0.8, 0.95, true)
		-- back
		tomato(-0.2, 3.1, 1.65, 1.15, true)

		------------------------------------------------------------------
		-- LEAVES: drooping stepped blades (base -> out along local +X),
		-- mid / tip stepping down, dark side lobes underneath, light midrib
		------------------------------------------------------------------
		local function leaf(x, y, z, a, len)
			len = len or 1
			local f = CFrame.new(x, y, z) * CFrame.Angles(0, math.rad(a), 0)
			B:block(root, v(1.2 * len, 0.45, 1.2), f * CFrame.new(0.6 * len, 0, 0), LEAF)
			B:block(root, v(0.8 * len, 0.35, 1.8), f * CFrame.new(0.85 * len, -0.25, 0), LEAF_DK) -- side lobes
			B:block(root, v(0.9 * len, 0.4, 0.9), f * CFrame.new(1.45 * len, -0.35, 0.05), LEAF)
			B:block(root, v(0.55, 0.35, 0.55), f * CFrame.new(1.95 * len, -0.7, 0.05), LEAF_DK) -- drooping tip
			B:block(root, v(0.5, 0.2, 0.5), f * CFrame.new(0.55 * len, 0.3, -0.15), LEAF_LT) -- shine
		end
		-- crown
		leaf(-0.2, 6.55, -0.15, 0, 1.0)
		leaf(-0.2, 6.6, -0.15, 135, 0.9)
		leaf(-0.2, 6.5, -0.15, 225, 0.9)
		B:block(root, v(1.0, 0.55, 1.0), cf(-0.25, 6.7, -0.2), LEAF_LT) -- crown bud
		-- over the clusters
		leaf(1.0, 3.55, -0.3, 0, 1.0)
		leaf(-1.0, 4.75, -0.3, 180, 1.0)
		leaf(0.6, 5.95, -0.2, 45, 0.9)
		-- back / low
		leaf(-0.2, 4.3, 0.4, 270, 1.0)
		leaf(-0.4, 2.3, 0.0, 225, 0.85)

		------------------------------------------------------------------
		-- FLOWERS: little yellow plus-crosses facing front
		------------------------------------------------------------------
		local function flower(x, y, z)
			B:block(root, v(0.75, 0.25, 0.18), cf(x, y, z), YEL)
			B:block(root, v(0.25, 0.75, 0.18), cf(x, y, z), YEL)
			B:block(root, v(0.25, 0.25, 0.25), cf(x, y, z - 0.08), YEL_DK)
		end
		flower(0.1, 5.2, -1.05)
		flower(0.75, 3.75, -1.05)

		-- a gentle twinkle of "freshness" around the fruit
		local fx = B:block(root, v(4.5, 4.5, 3.0), cf(0, 3.6, 0), RED, { tr = 1, name = "TwinkleFX" })
		B:emitter(fx, "sparkle", { name = "Twinkle", color = { "#ffffff", "#ffd0c4" }, rate = 1.2, size = { 0.25, 0.3, 0 } })
	end,
}
