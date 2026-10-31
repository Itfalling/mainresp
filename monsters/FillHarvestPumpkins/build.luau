--!nocheck
-- Pumpkin Pair (Harvest Fields filler prop).
-- Two uncarved ribbed pumpkins, one big and one small, nudged together.
-- Each is built like the Harvest crops: rounded octagon tiers (a square + the
-- same square turned 45 degrees) that step in at the bottom and the shoulder,
-- in three oranges (shadow base, main body, sunlit shoulder), with dark rib
-- grooves down every face, a sunken dimple and a crooked, stepped green stem.
-- A vine runs along the ground between them with two broad lobed pumpkin
-- leaves (pale veins), a curly tendril and a small yellow blossom. A low
-- litter of straw, fallen leaves, a pebble and grass tufts grounds it.
return {
	DisplayName = "Pumpkin Pair",
	Rarity = "Filler",
	Filler = true,
	Element = "Harvest Fields",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		-- palette (Harvest Fields pumpkins / wagon)
		local PUMP_SH, PUMP_DK, PUMP, PUMP_LT, PUMP_HI = "#c4560f", "#e06c18", "#ff9424", "#ffb042", "#ffc66a"
		local STEM_DK, STEM, STEM_LT = "#4f5e1e", "#6b7d2a", "#8c9c3e"
		local VINE, VINE_DK = "#3f7a2a", "#2f5f20"
		local LEAF_DK, LEAF, LEAF_LT = "#3d7f2a", "#5aa83a", "#9fd36a"
		local BLOSSOM, BLOSSOM_DK = "#ffd23a", "#f0a81c"
		local HAY, HAY_LT = "#e6bd55", "#f4d98a"
		local LF_OR, LF_RED, LF_GOLD = "#f27a1c", "#d8352a", "#f7b52c"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local STONE, STONE_LT = "#8d8174", "#a39787"

		local Y45 = CFrame.Angles(0, rad(45), 0)
		-- octagon tier: square + 45-degree square
		local function oct(C, w, h, c1, c2)
			B:block(R, v(w, h, w), C, c1)
			B:block(R, v(w - 0.04, h - 0.02, w - 0.04), C * Y45, c2 or c1)
		end

		-- ribbed pumpkin; returns the CFrame at the top of the dimple
		local function pumpkin(x, z, w, yaw, stemLean)
			local h = 0.74 * w
			local C = cf(x, 0, z, 0, yaw, 0)
			-- shadowed base tier, main body, sunlit shoulder
			oct(C * CFrame.new(0, 0.13 * h, 0), 0.8 * w, 0.26 * h, PUMP_SH, PUMP_DK)
			oct(C * CFrame.new(0, 0.45 * h, 0), w, 0.56 * h, PUMP, PUMP)
			oct(C * CFrame.new(0, 0.8 * h, 0), 0.76 * w, 0.24 * h, PUMP_LT, PUMP)
			-- rib grooves down the middle of every octagon face
			for i = 0, 7 do
				local f = C * CFrame.Angles(0, rad(i * 45), 0)
				B:block(R, v(0.13 * w, 0.5 * h, 0.06), f * CFrame.new(0, 0.46 * h, -(w / 2 + 0.01)), PUMP_DK)
			end
			-- top highlight + sunken dimple
			B:block(R, v(0.46 * w, 0.08, 0.46 * w), C * CFrame.new(0, 0.92 * h + 0.04, 0) * CFrame.Angles(0, rad(22.5), 0), PUMP_HI)
			B:block(R, v(0.26 * w, 0.1, 0.26 * w), C * CFrame.new(0, 0.92 * h + 0.07, 0), PUMP_DK)
			-- crooked stepped stem
			local s = w / 2.6
			local top = C * CFrame.new(0, 0.92 * h + 0.1, 0)
			local s1 = top * CFrame.new(0, 0.3 * s, 0) * CFrame.Angles(0, 0, rad(stemLean))
			B:block(R, v(0.44 * s, 0.62 * s, 0.44 * s), s1, STEM)
			B:block(R, v(0.56 * s, 0.16, 0.56 * s), top * CFrame.new(0, 0.04, 0) * CFrame.Angles(0, rad(30), 0), STEM_DK)
			local s2 = s1 * CFrame.new(0.08 * s, 0.42 * s, 0) * CFrame.Angles(0, 0, rad(stemLean * 1.6))
			B:block(R, v(0.34 * s, 0.4 * s, 0.34 * s), s2, STEM)
			B:block(R, v(0.38 * s, 0.1, 0.38 * s), s2 * CFrame.new(0, 0.22 * s, 0), STEM_LT)
			return top
		end

		local topA = pumpkin(-0.9, 0.3, 2.8, 12, -14)
		local topB = pumpkin(1.6, -0.5, 1.9, -20, 18)

		---------------------------------------------------------------- vine + leaves
		local vine = { v(-0.2, 0.12, -1.35), v(0.7, 0.12, -1.6), v(1.8, 0.14, -1.75), v(2.9, 0.12, -1.3) }
		for i = 1, #vine - 1 do
			B:bar(R, vine[i], vine[i + 1], 0.2, 0.2, (i % 2 == 0) and VINE or VINE_DK)
		end
		-- vine tucks under the big pumpkin
		B:bar(R, v(-0.2, 0.12, -1.35), v(-0.75, 0.14, -0.95), 0.2, 0.2, VINE_DK)
		-- curly tendril at the vine end
		local t = { v(2.9, 0.12, -1.3), v(3.35, 0.35, -1.1), v(3.3, 0.65, -0.8), v(3.05, 0.6, -0.95) }
		for i = 1, #t - 1 do
			B:bar(R, t[i], t[i + 1], 0.12, 0.12, VINE)
		end
		-- broad lobed pumpkin leaf lying on the ground
		local function leaf(p, yaw, k, tilt)
			local C = CFrame.new(p) * CFrame.Angles(0, rad(yaw), 0) * CFrame.Angles(rad(tilt), 0, 0)
			B:block(R, v(1.3 * k, 0.14, 1.2 * k), C * CFrame.new(0, 0, -0.5 * k), LEAF)
			B:block(R, v(0.95 * k, 0.12, 0.85 * k), C * CFrame.Angles(0, rad(50), 0) * CFrame.new(0, -0.01, -0.55 * k), LEAF_DK)
			B:block(R, v(0.95 * k, 0.12, 0.85 * k), C * CFrame.Angles(0, rad(-50), 0) * CFrame.new(0, -0.01, -0.55 * k), LEAF_DK)
			B:block(R, v(0.12, 0.06, 1.1 * k), C * CFrame.new(0, 0.09, -0.55 * k), LEAF_LT)
			B:block(R, v(0.7 * k, 0.06, 0.1), C * CFrame.new(0, 0.09, -0.6 * k) * CFrame.Angles(0, rad(35), 0), LEAF_LT)
		end
		leaf(v(0.6, 0.2, -1.5), -20, 1.1, -8)
		leaf(v(2.3, 0.2, -1.6), 50, 0.85, 6)

		-- small yellow blossom on the vine
		local bp = v(1.35, 0.3, -1.95)
		B:block(R, v(0.7, 0.16, 0.36), CFrame.new(bp) * CFrame.Angles(0, rad(20), 0), BLOSSOM)
		B:block(R, v(0.36, 0.16, 0.7), CFrame.new(bp + v(0, 0.02, 0)) * CFrame.Angles(0, rad(20), 0), BLOSSOM)
		B:block(R, v(0.26, 0.2, 0.26), CFrame.new(bp + v(0, 0.08, 0)) * CFrame.Angles(0, rad(65), 0), BLOSSOM_DK)

		---------------------------------------------------------------- footing
		local straws = { { -2.6, -0.8, 1.2, 30, HAY_LT }, { -2.3, -1.2, 0.9, -40, HAY }, { 0.2, 1.9, 1.1, 75, HAY_LT }, { 3.0, 1.2, 1.0, 15, HAY } }
		for _, s in straws do
			B:block(R, v(s[3], 0.12, 0.18), cf(s[1], 0.06, s[2], 0, s[4], 0), s[5])
		end
		for _, l in { { -2.5, 1.2, 25, LF_RED }, { 0.6, 2.0, -30, LF_GOLD }, { 3.1, -1.1, 60, LF_OR } } do
			B:block(R, v(0.75, 0.1, 0.55), cf(l[1], 0.05, l[2], 0, l[3], 0), l[4])
		end
		B:block(R, v(0.7, 0.36, 0.55), cf(-2.5, 0.18, -0.2, 0, 25, 0), STONE)
		B:block(R, v(0.4, 0.2, 0.34), cf(-2.65, 0.34, -0.15, 0, 50, 0), STONE_LT)
		for _, g in { { -2.4, 0.6, 15 }, { 0.4, 1.8, 50 }, { 3.0, -0.3, 80 } } do
			B:block(R, v(0.35, 0.75, 0.35), cf(g[1], 0.37, g[2], 6, g[3], 8), GRASS)
			B:block(R, v(0.3, 0.55, 0.3), cf(g[1] + 0.28, 0.27, g[2] + 0.12, -6, g[3] + 25, -12), GRASS_DK)
		end
	end,
}
