--!nocheck
-- Honey Clover (Honey Hills crop #1, Common).
-- Tall clover stalks topped with chunky golden "honey-drop" clover blossoms
-- (stepped pom-pom flower heads of honey-gold floret layers, each with a
-- plump amber honey drop about to fall) over a bed of big three-leaf clover
-- leaves with pale chevron marks. A little block bee rests on one blossom.
-- Stepped grassy meadow mound: brown soil tiers with grass lips, tiny pink /
-- lavender / white wildflowers, mini clovers, a honey puddle dribbling over
-- the tier edge and pebbles. Static prop: no motion.luau.
return {
	DisplayName = "Honey Clover",
	Rarity = "Common",
	Element = "Honey",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Honey Hills)
		local SOIL_DK, SOIL, SOIL_LT = "#7a4628", "#94583a", "#a86a42"
		local GRASS_DK, GRASS, GRASS_LT = "#8fb83a", "#a8cf46", "#c4e35e"
		local PEBBLE, PEBBLE_DK = "#d8ccb4", "#ab9e86"
		local FL_PINK, FL_LAV, FL_WHITE, FL_CEN = "#ff9ec8", "#c3a2ff", "#fff7ea", "#ffd23a"
		local STEM, STEM_DK = "#3f9440", "#2f7a34"
		local LEAF_DK, LEAF, LEAF_LT, LEAF_V = "#2f8a42", "#47ad57", "#64c468", "#dcf7c4"
		local HONEY_DK, HONEY, HONEY_MID, HONEY_LT, HONEY_TOP = "#f5a114", "#ffc532", "#ffd448", "#ffe272", "#fff2b8"
		local DROP, DROP_HL = "#ff9d0a", "#fff6d0"
		local BEE_Y, BEE_K, BEE_W = "#ffcf2e", "#2a2320", "#f4fbff"

		local seed = 1611
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		------------------------------------------------------------ meadow mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(r, y, h, col, grow)
			grow = grow or 0
			B:block(soil, v(2 * r + grow, h, 1.1 * r + grow), cf(0, y - h / 2, 0), col, S)
			B:block(soil, v(1.1 * r + grow, h - 0.04, 2 * r + grow), cf(0, y - h / 2 - 0.02, 0), col, S)
			B:block(soil, v(1.72 * r + grow, h - 0.08, 1.72 * r + grow), cf(0, y - h / 2 - 0.04, 0), col, S)
		end
		local function tier(y0, h, r, soilCol, grassCol, nEdge)
			local top = y0 + h
			oct(r, top - 0.25, h - 0.25, soilCol)
			oct(r, top, 0.34, grassCol, 0.08) -- grass lip on top of the soil
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.3, 1.9), rnd(1.0, 1.4)
				local eh = h - 0.3 + rnd(-0.1, 0.15)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0, -(r + rnd(0.05, 0.3))) * ang(0, rnd(-8, 8), 0)
				B:block(soil, v(w, eh, d), CFrame.new(0, y0 + eh / 2, 0) * p, i % 3 == 0 and SOIL_LT or soilCol, S)
				if i % 2 == 0 then
					B:block(soil, v(w + 0.14, 0.32, d + 0.14), CFrame.new(0, y0 + eh + 0.1, 0) * p, grassCol, S)
				end
			end
		end
		tier(0, 0.85, 4.4, SOIL_DK, GRASS_DK, 9)
		tier(0.85, 0.55, 3.1, SOIL, GRASS, 6)
		oct(2.0, 1.72, 0.32, GRASS_LT)

		-- tiny wildflowers
		local function tinyFlower(x, z, y, col)
			local yaw = rnd(0, 90)
			B:block(soil, v(0.18, 0.55, 0.18), cf(x, y + 0.27, z), STEM, S)
			B:block(soil, v(0.72, 0.18, 0.3), cf(x, y + 0.6, z, 0, yaw, 0), col, S)
			B:block(soil, v(0.3, 0.2, 0.72), cf(x, y + 0.6, z, 0, yaw, 0), col, S)
			B:block(soil, v(0.24, 0.24, 0.24), cf(x, y + 0.7, z, 0, yaw, 0), FL_CEN, S)
		end
		tinyFlower(-3.6, -1.6, 0.85, FL_PINK)
		tinyFlower(3.7, 1.4, 0.85, FL_LAV)
		tinyFlower(-1.4, 3.85, 0.85, FL_WHITE)
		tinyFlower(2.2, 2.3, 1.4, FL_PINK)
		-- mini clovers on the grass
		local function miniClover(x, z, y)
			local yaw = rnd(0, 120)
			B:block(soil, v(0.16, 0.4, 0.16), cf(x, y + 0.2, z), STEM, S)
			for k = 0, 2 do
				local c = CFrame.new(x, y + 0.42, z) * ang(0, yaw + k * 120, 0) * CFrame.new(0, 0, -0.28)
				B:block(soil, v(0.5, 0.14, 0.5), c * ang(0, 45, 0), k == 0 and LEAF_LT or LEAF, S)
			end
		end
		miniClover(3.9, -1.3, 0.85)
		miniClover(-1.6, -2.4, 1.4)

		-- honey puddle on the middle tier dribbling over the edge
		local hp = CFrame.new(1.75, 1.4, -2.05) * ang(0, -40, 0)
		B:block(soil, v(1.9, 0.12, 1.1), hp * CFrame.new(0, 0.06, 0), HONEY, S)
		B:block(soil, v(1.2, 0.14, 1.6), hp * CFrame.new(0.1, 0.07, 0.05), HONEY, S)
		B:block(soil, v(0.7, 0.16, 0.5), hp * CFrame.new(-0.25, 0.08, 0.1), HONEY_TOP, S)
		local dd = v(0.68, 0, -0.73).Unit
		local dp = dd * 3.3
		B:block(soil, v(0.5, 0.75, 0.32), CFrame.new(dp.X, 1.1, dp.Z) * ang(0, -43, 0), HONEY, S)
		B:block(soil, v(0.36, 0.3, 0.3), CFrame.new(dp.X + dd.X * 0.05, 0.72, dp.Z + dd.Z * 0.05) * ang(0, -43, 0), DROP, S)
		B:block(soil, v(0.75, 0.1, 0.6), CFrame.new(dd.X * 3.75, 0.88, dd.Z * 3.75) * ang(0, -43, 0), HONEY, S)

		-- pebbles
		B:block(soil, v(0.6, 0.4, 0.5), cf(-3.95, 1.0, 0.6, 0, 35, 0), PEBBLE, S)
		B:block(soil, v(0.45, 0.32, 0.45), cf(2.6, 1.5, 0.9, 0, 15, 0), PEBBLE_DK, S)
		B:block(soil, v(0.5, 0.35, 0.42), cf(0.9, 1.0, 3.95, 0, 60, 0), PEBBLE, S)

		------------------------------------------------------------ clover plant
		local crop = B:bone("Crop", "Root", v(0, 1.7, 0))

		-- big three-leaf clover: leaflets fan out in the frame's XZ plane
		local function trefoil(F, s, tilt)
			for k = 0, 2 do
				local G = F * ang(0, k * 120, 0) * ang(tilt, 0, 0)
				local col = k == 1 and LEAF_LT or LEAF
				B:block(crop, v(1.45 * s, 0.4, 1.3 * s), G * CFrame.new(0, 0, -1.05 * s), col)
				B:block(crop, v(0.82 * s, 0.42, 0.9 * s), G * CFrame.new(0.45 * s, 0, -1.95 * s) * ang(0, -10, 0), col)
				B:block(crop, v(0.82 * s, 0.42, 0.9 * s), G * CFrame.new(-0.45 * s, 0, -1.95 * s) * ang(0, 10, 0), col)
				B:block(crop, v(0.95 * s, 0.46, 0.26 * s), G * CFrame.new(0, 0, -1.3 * s), LEAF_V)
			end
			B:block(crop, v(0.5, 0.42, 0.5), F * ang(0, 45, 0), LEAF_DK)
		end
		local function leaf(base, tip, s, yaw, tilt)
			B:bar(crop, base, tip, 0.3, 0.3, STEM_DK)
			trefoil(CFrame.new(tip) * ang(0, yaw, 0), s, tilt)
		end
		leaf(v(0.3, 1.6, -0.3), v(1.9, 3.6, -1.9), 1.2, 20, 16)
		leaf(v(-0.3, 1.6, -0.2), v(-2.3, 3.0, -0.6), 1.15, 75, 14)
		leaf(v(0.4, 1.6, 0.3), v(2.3, 3.3, 1.3), 1.15, -20, 14)
		leaf(v(-0.3, 1.6, 0.4), v(-1.2, 4.6, 2.0), 1.1, 40, 18)
		-- two smaller leaves branching off the flower stalks higher up
		leaf(v(-1.35, 5.0, -0.75), v(-2.5, 5.9, -1.9), 0.72, 50, 22)
		leaf(v(1.15, 5.7, 1.15), v(2.6, 6.5, 1.6), 0.72, -40, 22)

		-- golden honey-drop blossom: stepped pom-pom of floret layers + a drip
		local function blossom(p, s, yaw, drip)
			local F = CFrame.new(p) * ang(0, yaw, 0)
			B:block(crop, v(1.1 * s, 0.35, 1.1 * s), F * CFrame.new(0, -0.95 * s, 0) * ang(0, 45, 0), STEM)
			B:block(crop, v(1.5 * s, 0.6 * s, 1.5 * s), F * CFrame.new(0, -0.62 * s, 0) * ang(0, 45, 0), HONEY_DK)
			B:block(crop, v(2.1 * s, 1.0 * s, 1.35 * s), F, HONEY)
			B:block(crop, v(1.35 * s, 1.02 * s, 2.1 * s), F * CFrame.new(0, 0.01, 0), HONEY)
			B:block(crop, v(1.8 * s, 0.96 * s, 1.8 * s), F * CFrame.new(0, -0.02, 0) * ang(0, 45, 0), HONEY_MID)
			B:block(crop, v(1.55 * s, 0.6 * s, 1.55 * s), F * CFrame.new(0, 0.72 * s, 0) * ang(0, 22.5, 0), HONEY_LT)
			B:block(crop, v(0.9 * s, 0.42 * s, 0.9 * s), F * CFrame.new(0, 1.12 * s, 0) * ang(0, 67.5, 0), HONEY_TOP)
			for k = 0, 3 do -- plump florets bulging out of the head
				local c = F * ang(0, 45 + k * 90, 0) * CFrame.new(0, 0.25 * s, -1.05 * s) * ang(-20, 0, 0)
				B:block(crop, v(0.6 * s, 0.6 * s, 0.5 * s), c, k % 2 == 0 and HONEY_LT or HONEY_MID)
			end
			if drip then
				-- plump drop hanging from the underside on a thin neck
				local d = F * CFrame.new(0.55 * s, -0.75 * s, -0.4 * s)
				B:block(crop, v(0.3 * s, 0.55 * s, 0.3 * s), d * CFrame.new(0, -0.2 * s, 0), DROP)
				B:block(crop, v(0.78 * s, 0.62 * s, 0.78 * s), d * CFrame.new(0, -0.82 * s, 0), DROP)
				B:block(crop, v(0.56 * s, 0.9 * s, 0.56 * s), d * CFrame.new(0, -0.8 * s, 0) * ang(0, 45, 0), HONEY)
				B:block(crop, v(0.2 * s, 0.24 * s, 0.12), d * CFrame.new(-0.18 * s, -0.7 * s, -0.4 * s), DROP_HL)
			end
			return F
		end
		local function stalk(base, mid, top, s, yaw, drip)
			B:bar(crop, base, mid, 0.42, 0.42, STEM)
			B:bar(crop, mid, top, 0.38, 0.38, STEM)
			return blossom(top + v(0, 0.9 * s, 0), s, yaw, drip)
		end
		stalk(v(0.1, 1.6, 0.1), v(0.05, 6.5, 0.25), v(-0.15, 9.9, 0.0), 1.15, 10, true)
		local bB = stalk(v(0.5, 1.6, -0.4), v(1.4, 5.6, -0.9), v(2.5, 8.1, -1.3), 1.0, 30, true)
		stalk(v(-0.5, 1.6, -0.3), v(-1.4, 5.0, -0.8), v(-2.6, 7.3, -1.1), 0.95, -15, true)
		stalk(v(0.5, 1.6, 0.5), v(1.2, 5.8, 1.2), v(2.0, 8.9, 2.0), 1.0, 55, false)
		stalk(v(-0.5, 1.6, 0.5), v(-1.1, 5.4, 1.2), v(-1.9, 7.9, 2.2), 0.95, 20, true)
		stalk(v(0.2, 1.6, -0.6), v(0.4, 4.0, -1.6), v(0.5, 5.4, -2.5), 0.8, 40, false)

		------------------------------------------------------------ resting bee
		local beeF = bB * CFrame.new(0.1, 1.55, 0) * ang(0, 25, 0)
		B:block(crop, v(0.85, 0.8, 1.2), beeF, BEE_Y)
		B:block(crop, v(0.9, 0.85, 0.24), beeF * CFrame.new(0, 0, 0.1), BEE_K)
		B:block(crop, v(0.9, 0.85, 0.22), beeF * CFrame.new(0, 0, 0.48), BEE_K)
		B:block(crop, v(0.65, 0.65, 0.5), beeF * CFrame.new(0, 0.05, -0.75), BEE_K)
		B:block(crop, v(0.18, 0.18, 0.3), beeF * CFrame.new(0, -0.05, 0.72), BEE_K)
		B:block(crop, v(0.7, 0.1, 0.5), beeF * CFrame.new(0.4, 0.5, 0.1) * ang(0, -15, -25), BEE_W)
		B:block(crop, v(0.7, 0.1, 0.5), beeF * CFrame.new(-0.4, 0.5, 0.1) * ang(0, 15, 25), BEE_W)
		B:block(crop, v(0.1, 0.4, 0.1), beeF * CFrame.new(0.15, 0.5, -0.9) * ang(-25, 0, -15), BEE_K)
		B:block(crop, v(0.1, 0.4, 0.1), beeF * CFrame.new(-0.15, 0.5, -0.9) * ang(-25, 0, 15), BEE_K)
	end,
}
