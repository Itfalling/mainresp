--!nocheck
-- Glow Lotus Pond (Flytrap Stage plant #6, Mythic).
-- A round stepped bog mound holding a little lily-pad pond, ringed by mossy
-- stones and reeds. Out of the teal water rise slender green stems carrying
-- big stepped pink lotus flowers (three rings of petals, pale tips, golden
-- stamens) and chunky lotus seed pods - the "fruits" - whose flat tops are
-- dotted with glowing lime-gold seeds. Two cupped lotus leaves stand above
-- the water, lily pads float on it, a closed bud peeks up at the front.
-- Fireflies, seed glow, pond bubbles, drifting petals, one soft light.
-- Static prop: no motion.luau.
return {
	DisplayName = "Glow Lotus Pond",
	Rarity = "Mythic",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Flytrap stage)
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local WATER, WATER_LT, WATER_DK = "#2f8a74", "#6fc9a8", "#256a5a"
		local REED, CATTAIL = "#7f8f3a", "#5a3a1e"
		local STEM, STEM_DK = "#4f9a3a", "#3a7a2c"
		local LEAF, LEAF_DK, LEAF_LT = "#3caa3c", "#1f6e2a", "#7fd04a"
		local PINK_DK, PINK, PINK_LT, PINK_PALE = "#d6417c", "#ff6fa8", "#ff9cc6", "#ffb6d6"
		local GOLD, GOLD_LT = "#ffc62e", "#ffe27a"
		local POD_DK, POD, POD_LT = "#5c8f34", "#86b84c", "#b5d86a"
		local SEED = "#d9ff5a"
		local NEON = { mat = "Neon" }

		local seed = 6623
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end

		---------------------------------------------------------------- mound + pond
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function disc(y0, h, r, col)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.02, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.04, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
		end
		local function edge(y0, h, r, n, cols, edgeH, wr, dr)
			for i = 0, n - 1 do
				local a = (i + rnd(-0.2, 0.2)) / n * 360
				local w, d = rnd(wr[1], wr[2]), rnd(dr[1], dr[2])
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.3)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-8, 8), 0), pick(cols), S)
			end
		end
		disc(0, 0.7, 6.2, DIRT_DK)
		edge(0, 0.7, 6.2, 15, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35, { 1.4, 2.2 }, { 1.2, 1.7 })
		disc(0.7, 0.8, 4.8, DIRT)
		-- stone + moss rim of the pond
		edge(0.7, 1.0, 4.75, 13, { STONE, STONE_LT, STONE_DK, MOSS_DK, STONE, STONE_DK }, 0.35, { 1.3, 2.0 }, { 1.1, 1.5 })
		-- water
		disc(1.45, 0.2, 4.3, WATER)
		B:block(soil, v(4.6, 0.1, 0.35), cf(-0.6, 1.66, -2.1, 0, 12, 0), WATER_LT, S)
		B:block(soil, v(2.8, 0.1, 0.35), cf(1.4, 1.66, 2.6, 0, -8, 0), WATER_LT, S)
		B:block(soil, v(1.8, 0.1, 0.3), cf(-2.4, 1.66, 1.6, 0, 30, 0), WATER_LT, S)
		B:block(soil, v(2.4, 0.08, 2.0), cf(0.4, 1.63, 0.3, 0, 20, 0), WATER_DK, S)
		-- grass tufts on the outer tier
		for _, g in { { 5.7, -1.8 }, { -3.0, -5.3 }, { 3.2, 5.1 } } do
			B:block(soil, v(0.45, 0.9, 0.45), cf(g[1], 0.9, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.35, 0.6, 0.35), cf(g[1] + 0.35, 0.85, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end
		-- reeds + cattails at the back-left
		for _, r in { { -4.0, 2.6, 3.4, 6 }, { -3.4, 3.2, 2.6, -8 }, { -4.6, 1.8, 2.2, 10 } } do
			B:block(soil, v(0.22, r[3], 0.22), cf(r[1], 1.5 + r[3] / 2, r[2], 0, 0, r[4]), REED, S)
			B:block(soil, v(0.38, 0.75, 0.38), cf(r[1] - math.sin(rad(r[4])) * r[3] / 2, 1.5 + r[3] + 0.2, r[2], 0, 0, r[4]), CATTAIL, S)
		end

		-- floating lily pads
		local function lily(x, z, s, a, col)
			local c = cf(x, 1.66, z, 0, a, 0)
			B:block(soil, v(1.9 * s, 0.14, 1.3 * s), c, col, S)
			B:block(soil, v(1.3 * s, 0.13, 1.9 * s), c, col, S)
			B:block(soil, v(0.5 * s, 0.17, 0.75 * s), c * CFrame.new(0, 0.01, -0.7 * s), WATER, S) -- notch
			B:block(soil, v(0.45 * s, 0.18, 0.45 * s), c * CFrame.new(0.1 * s, 0.02, 0.15 * s), LEAF_LT, S)
			return c
		end
		lily(-3.0, -1.4, 1.1, 30, LEAF)
		local frontPad = lily(1.9, -3.0, 1.0, -20, LEAF_DK)
		lily(3.2, 1.6, 0.9, 70, LEAF)
		-- tiny pink water-flower on the front pad
		for i = 0, 1 do
			B:block(soil, v(0.75, 0.25, 0.3), frontPad * CFrame.new(-0.2, 0.18, 0.2) * ang(0, i * 90 + 20, 0), PINK_LT, S)
		end
		B:block(soil, v(0.3, 0.3, 0.3), frontPad * CFrame.new(-0.2, 0.28, 0.2) * ang(0, 20, 0), GOLD, S)

		---------------------------------------------------------------- plant
		local WY = 1.65
		local crop = B:bone("Crop", "Root", v(0, WY, 0))

		-- slender stem: water -> slight bend -> head
		local function stem(a, b, w, bend)
			local mid = a:Lerp(b, 0.5) + bend
			B:bar(crop, a, mid, w, w, STEM)
			B:bar(crop, mid, b, w, w, STEM)
			B:block(crop, v(w + 0.12, w + 0.12, w + 0.12), CFrame.new(mid), STEM)
			B:block(crop, v(w + 0.35, 0.3, w + 0.35), CFrame.new(a + v(0, 0.05, 0)), STEM_DK)
		end

		-- LOTUS FLOWER (frame: base at origin, opens toward local +Y)
		local function flower(base, s, rx, rz, yaw)
			local Fr = CFrame.new(base) * CFrame.Angles(rad(rx), rad(yaw or 0), rad(rz))
			B:block(crop, v(1.1 * s, 0.6 * s, 1.1 * s), Fr * CFrame.new(0, 0.1 * s, 0), LEAF_DK)
			local rings = {
				-- n, radius, outward tilt, w, h, color, tip color, offset
				{ 8, 0.55, -58, 1.25, 2.1, PINK, PINK_LT, 22.5 },
				{ 6, 0.4, -32, 1.1, 1.95, PINK_LT, PINK_PALE, 0 },
				{ 5, 0.25, -12, 0.85, 1.5, PINK_PALE, nil, 36 },
			}
			for ri, r in rings do
				for i = 0, r[1] - 1 do
					local a = i * 360 / r[1] + r[8]
					local P0 = Fr * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.25 * s, -r[2] * s) * CFrame.Angles(rad(r[3]), 0, 0)
					B:block(crop, v(r[4] * s, r[5] * s, 0.32 * s), P0 * CFrame.new(0, r[5] * s / 2, 0), r[6])
					if r[7] then
						B:block(crop, v(r[4] * 0.62 * s, 0.55 * s, 0.36 * s), P0 * CFrame.new(0, r[5] * s - 0.2 * s, 0), r[7])
					end
					if ri == 1 then
						B:block(crop, v(r[4] * 0.7 * s, 0.5 * s, 0.36 * s), P0 * CFrame.new(0, 0.3 * s, 0), PINK_DK)
					end
				end
			end
			-- golden stamens + little glowing heart
			for i = 0, 3 do
				local a = i * 90 + 45
				B:block(crop, v(0.24 * s, 0.75 * s, 0.24 * s), Fr * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 1.05 * s, -0.5 * s) * ang(-18, 0, 0), GOLD)
			end
			B:block(crop, v(0.8 * s, 0.6 * s, 0.8 * s), Fr * CFrame.new(0, 1.0 * s, 0), POD_LT)
			return B:block(crop, v(0.4 * s, 0.2 * s, 0.4 * s), Fr * CFrame.new(0, 1.35 * s, 0), SEED, NEON)
		end

		-- LOTUS SEED POD (frame: base at origin, flat seed face toward local +Y)
		local seeds = {}
		local function pod(base, s, rx, rz)
			local Fr = CFrame.new(base) * CFrame.Angles(rad(rx), 0, rad(rz))
			local function at(x, y, z, ry)
				return Fr * CFrame.new(x * s, y * s, z * s) * ang(0, ry or 0, 0)
			end
			B:block(crop, v(0.7 * s, 0.6 * s, 0.7 * s), at(0, 0.3, 0), POD_DK)
			B:block(crop, v(1.4 * s, 0.6 * s, 1.4 * s), at(0, 0.85, 0, 45), POD_DK)
			B:block(crop, v(2.0 * s, 0.6 * s, 2.0 * s), at(0, 1.4, 0), POD)
			B:block(crop, v(2.6 * s, 0.5 * s, 1.7 * s), at(0, 1.9, 0), POD)
			B:block(crop, v(1.7 * s, 0.48 * s, 2.6 * s), at(0, 1.9, 0), POD)
			B:block(crop, v(2.3 * s, 0.46 * s, 2.3 * s), at(0, 1.9, 0, 0), POD)
			B:block(crop, v(2.2 * s, 0.2 * s, 2.2 * s), at(0, 2.2, 0, 45), POD_LT)
			-- glowing seeds sunk in dark holes
			local SP = { { 0, 0 }, { 0.75, 0 }, { -0.75, 0 }, { 0.38, 0.68 }, { -0.38, 0.68 }, { 0.38, -0.68 }, { -0.38, -0.68 } }
			for i, p in SP do
				B:block(crop, v(0.5 * s, 0.12 * s, 0.5 * s), at(p[1], 2.3, p[2]), POD_DK)
				local sd = B:block(crop, v(0.32 * s, 0.22 * s, 0.32 * s), at(p[1], 2.37, p[2]), SEED, { mat = "Neon", name = "Seed" })
				table.insert(seeds, sd)
			end
			-- little upturned crown tufts round the rim
			for i = 0, 3 do
				local a = i * 90 + 45
				B:block(crop, v(0.5 * s, 0.35 * s, 0.4 * s), Fr * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 2.2 * s, -1.45 * s) * ang(30, 0, 0), POD_LT)
			end
			return Fr:PointToWorldSpace(v(0, 2.5 * s, 0))
		end

		-- STANDING LOTUS LEAF: cupped round pad on a stem
		local function bigLeaf(c, s, rx, rz, col)
			local Fr = CFrame.new(c) * CFrame.Angles(rad(rx), 0, rad(rz))
			B:block(crop, v(3.6 * s, 0.25, 2.0 * s), Fr, col)
			B:block(crop, v(2.0 * s, 0.24, 3.6 * s), Fr, col)
			B:block(crop, v(3.1 * s, 0.23, 3.1 * s), Fr, col)
			B:block(crop, v(0.8 * s, 0.32, 0.8 * s), Fr * ang(0, 45, 0), LEAF_LT)
			for i = 0, 3 do
				B:block(crop, v(0.3 * s, 0.3, 1.5 * s), Fr * CFrame.Angles(0, rad(i * 90 + 45), 0) * CFrame.new(0, 0.02, -0.95 * s), LEAF_LT)
			end
			for i = 0, 4 do
				local a = i * 72 + 15
				B:block(crop, v(1.5 * s, 0.25, 0.7 * s), Fr * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.25, -1.75 * s) * ang(35, 0, 0), LEAF_DK)
			end
		end

		-- closed bud
		local function bud(base, s, rz)
			local Fr = CFrame.new(base) * CFrame.Angles(0, rad(20), rad(rz))
			B:block(crop, v(0.9 * s, 0.35 * s, 0.9 * s), Fr * CFrame.new(0, 0.15 * s, 0), LEAF_DK)
			B:block(crop, v(1.0 * s, 1.0 * s, 1.0 * s), Fr * CFrame.new(0, 0.75 * s, 0), PINK)
			B:block(crop, v(0.75 * s, 0.7 * s, 0.75 * s), Fr * CFrame.new(0, 1.5 * s, 0) * ang(0, 45, 0), PINK_LT)
			B:block(crop, v(0.4 * s, 0.45 * s, 0.4 * s), Fr * CFrame.new(0, 2.0 * s, 0), PINK_PALE)
		end

		-- standing leaves (a lush mid-level bed)
		stem(v(1.6, WY, 1.2), v(3.6, 5.4, 2.4), 0.42, v(0.3, 0, -0.2))
		bigLeaf(v(3.6, 5.5, 2.4), 1.35, 10, -14, LEAF)
		stem(v(-1.4, WY, -0.6), v(-3.4, 4.3, -1.6), 0.42, v(0.2, 0, 0.2))
		bigLeaf(v(-3.4, 4.4, -1.6), 1.15, -10, 12, LEAF)
		stem(v(-0.6, WY, 1.6), v(-1.6, 6.0, 3.4), 0.42, v(-0.3, 0, 0.1))
		bigLeaf(v(-1.6, 6.1, 3.4), 1.2, 14, 6, LEAF_DK)

		-- hero seed pod (tallest)
		local P1b = v(0.6, 11.0, 1.0)
		stem(v(0.2, WY, 0.5), P1b, 0.55, v(-0.4, 0, 0.3))
		pod(P1b, 1.35, -12, -6)
		-- side seed pod (left, mid)
		local P2b = v(-3.6, 7.4, 1.0)
		stem(v(-0.9, WY, 0.9), P2b, 0.45, v(-0.6, 0, 0.1))
		pod(P2b, 1.0, 6, 22)
		-- small pod low at the front-right, tipped toward the viewer
		local P3b = v(3.5, 3.9, -2.2)
		stem(v(1.8, WY, -1.4), P3b, 0.4, v(0.3, 0, 0))
		pod(P3b, 0.85, -26, -14)

		-- hero flower + second flower
		local F1b = v(-1.5, 8.0, -1.2)
		stem(v(-0.5, WY, -0.4), F1b, 0.5, v(0.4, 0, -0.2))
		local heart1 = flower(F1b, 1.55, -16, 10, 0)
		local F2b = v(3.7, 6.6, 0.1)
		stem(v(1.0, WY, -0.1), F2b, 0.45, v(0.2, 0, 0.3))
		flower(F2b, 1.2, -10, -22, 15)

		-- bud at the front
		local Bb = v(-0.6, 3.6, -3.3)
		stem(v(-0.3, WY, -2.3), Bb, 0.32, v(0.15, 0, 0.1))
		bud(Bb, 0.95, 8)

		---------------------------------------------------------------- bling
		B:emitter(seeds[1], "glow", { name = "SeedGlow", color = { SEED, GOLD_LT }, rate = 2, size = 0.7 })
		B:light(seeds[1], { color = "#e8ff8a", brightness = 1.0, range = 12, name = "PodLight" })
		local ff = B:block(crop, v(9, 4, 9), cf(0, 8.5, 0), LEAF, { tr = 1, name = "FireflyZone" })
		B:emitter(ff, "sparkle", { name = "Fireflies", color = { "#e8ff6a", "#86ff3c" }, rate = 4, size = 0.32 })
		B:emitter(heart1, "leaf", { name = "PetalDrift", color = { PINK_LT, PINK_PALE }, rate = 0.8, size = 0.35 })
		local pond = B:block(soil, v(6, 0.1, 6), cf(0, 1.7, 0), WATER, { tr = 1, name = "Soil" })
		B:emitter(pond, "bubble", { name = "PondBubbles", color = { "#bfffe0", "#86ff3c" }, rate = 1.5, size = { 0.15, 0.3, 0.4 }, speed = { 0.3, 0.8 } })
	end,
}
