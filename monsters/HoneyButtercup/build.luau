--!nocheck
-- Buttercup Sunbloom (Honey Hills crop #2, Uncommon).
-- A tall cluster of glossy buttercups: long green stems fan up from a rosette
-- of deep-cut palmate leaves and end in big lemon-yellow cup flowers (five
-- cupped petals with a pale gloss streak, an orange stamen ring and a green
-- knob heart). Between the flowers stand the crop: plump golden seed fruits
-- (stepped amber-gold seed heads dotted with bronze seeds, a green star calyx
-- and a curled green tip). A little block bee sits in one cup.
-- Stepped grassy meadow mound: brown soil tiers with grass lips, tiny pink /
-- lavender / white wildflowers, a honey puddle dribbling over the tier edge,
-- a dropped honeycomb chip and pebbles. Static prop: no motion.luau.
return {
	DisplayName = "Buttercup Sunbloom",
	Rarity = "Uncommon",
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
		local LEAF_DK, LEAF, LEAF_LT = "#2f8a42", "#47ad57", "#64c468"
		local HONEY, HONEY_TOP, DROP, COMB_DK = "#ffc532", "#fff2b8", "#ff9d0a", "#c97a10"
		local PET_DK, PET, PET_LT, PET_HL = "#f7c51a", "#ffe23a", "#fff07a", "#fffbe0"
		local STAMEN, KNOB = "#ff9a1e", "#7cc44a"
		local GOLD_DK, GOLD, GOLD_LT, SEED = "#f2a51c", "#ffbf2e", "#ffd95a", "#a8601a"
		local BEE_Y, BEE_K, BEE_W = "#ffcf2e", "#2a2320", "#f4fbff"

		local seed = 1621
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
		tier(0, 0.85, 4.5, SOIL_DK, GRASS_DK, 9)
		tier(0.85, 0.55, 3.2, SOIL, GRASS, 6)
		oct(2.0, 1.72, 0.32, GRASS_LT)

		-- tiny wildflowers
		local function tinyFlower(x, z, y, col)
			local yaw = rnd(0, 90)
			B:block(soil, v(0.18, 0.55, 0.18), cf(x, y + 0.27, z), STEM, S)
			B:block(soil, v(0.72, 0.18, 0.3), cf(x, y + 0.6, z, 0, yaw, 0), col, S)
			B:block(soil, v(0.3, 0.2, 0.72), cf(x, y + 0.6, z, 0, yaw, 0), col, S)
			B:block(soil, v(0.24, 0.24, 0.24), cf(x, y + 0.7, z, 0, yaw, 0), FL_CEN, S)
		end
		tinyFlower(3.8, -1.2, 0.85, FL_PINK)
		tinyFlower(-3.7, 1.6, 0.85, FL_LAV)
		tinyFlower(1.6, 3.9, 0.85, FL_WHITE)
		tinyFlower(-2.3, -2.2, 1.4, FL_PINK)
		tinyFlower(2.5, 1.9, 1.4, FL_LAV)

		-- honey puddle on the middle tier (front-left) dribbling over the edge
		local hp = CFrame.new(-1.8, 1.4, -2.1) * ang(0, 35, 0)
		B:block(soil, v(1.9, 0.12, 1.1), hp * CFrame.new(0, 0.06, 0), HONEY, S)
		B:block(soil, v(1.2, 0.14, 1.6), hp * CFrame.new(-0.1, 0.07, 0.05), HONEY, S)
		B:block(soil, v(0.7, 0.16, 0.5), hp * CFrame.new(0.25, 0.08, 0.1), HONEY_TOP, S)
		local dd = v(-0.65, 0, -0.76).Unit
		local dp = dd * 3.4
		B:block(soil, v(0.5, 0.75, 0.32), CFrame.new(dp.X, 1.1, dp.Z) * ang(0, 40, 0), HONEY, S)
		B:block(soil, v(0.36, 0.3, 0.3), CFrame.new(dp.X + dd.X * 0.05, 0.72, dp.Z + dd.Z * 0.05) * ang(0, 40, 0), DROP, S)
		B:block(soil, v(0.75, 0.1, 0.6), CFrame.new(dd.X * 3.85, 0.88, dd.Z * 3.85) * ang(0, 40, 0), HONEY, S)

		-- a dropped honeycomb chip (front-right, bottom tier)
		local hc = CFrame.new(2.9, 0.85, -2.6) * ang(0, -30, 6)
		B:block(soil, v(1.4, 0.36, 0.8), hc * CFrame.new(0, 0.18, 0), HONEY, S)
		B:block(soil, v(0.8, 0.38, 1.3), hc * CFrame.new(0, 0.19, 0), HONEY, S)
		B:block(soil, v(0.34, 0.4, 0.34), hc * CFrame.new(-0.3, 0.2, -0.15), COMB_DK, S)
		B:block(soil, v(0.34, 0.4, 0.34), hc * CFrame.new(0.3, 0.2, 0.2), COMB_DK, S)

		-- pebbles
		B:block(soil, v(0.6, 0.4, 0.5), cf(4.0, 1.0, 1.0, 0, 35, 0), PEBBLE, S)
		B:block(soil, v(0.45, 0.32, 0.45), cf(-2.6, 1.5, 1.1, 0, 15, 0), PEBBLE_DK, S)
		B:block(soil, v(0.5, 0.35, 0.42), cf(-1.0, 1.0, 4.0, 0, 60, 0), PEBBLE, S)

		------------------------------------------------------------ buttercup plant
		local crop = B:bone("Crop", "Root", v(0, 1.7, 0))

		-- deep-cut palmate leaf: three toothed lobes fanning out along the frame's -Z
		local function palm(F, s)
			for k = -1, 1 do
				local G = F * ang(0, k * 52, 0) * ang(14 + math.abs(k) * 4, 0, 0)
				local col = k == 0 and LEAF_LT or LEAF
				B:block(crop, v(0.95 * s, 0.38, 1.6 * s), G * CFrame.new(0, 0, -1.0 * s), col)
				B:block(crop, v(0.42 * s, 0.4, 0.75 * s), G * CFrame.new(0.38 * s, 0, -1.95 * s) * ang(0, -18, 0), col)
				B:block(crop, v(0.42 * s, 0.4, 0.95 * s), G * CFrame.new(0, 0.01, -2.1 * s), col)
				B:block(crop, v(0.42 * s, 0.4, 0.75 * s), G * CFrame.new(-0.38 * s, 0, -1.95 * s) * ang(0, 18, 0), col)
			end
			B:block(crop, v(0.5, 0.44, 0.5), F * ang(0, 45, 0), LEAF_DK)
		end
		local function leaf(base, tip, s)
			B:bar(crop, base, tip, 0.3, 0.3, STEM_DK)
			local d = tip - base
			local yaw = math.deg(math.atan2(-d.X, -d.Z))
			palm(CFrame.new(tip) * ang(0, yaw, 0), s)
		end
		leaf(v(0.2, 1.6, -0.3), v(1.4, 3.0, -2.3), 1.05)
		leaf(v(-0.3, 1.6, -0.1), v(-2.5, 3.3, -0.9), 1.0)
		leaf(v(0.3, 1.6, 0.3), v(2.4, 3.1, 1.3), 1.0)
		leaf(v(-0.2, 1.6, 0.3), v(-1.0, 3.6, 2.5), 1.0)

		-- glossy cup flower facing along n
		local cups = {}
		local function flower(p, n, s)
			local F = P.aim(p, p + n.Unit) * ang(0, 0, rnd(0, 72))
			B:block(crop, v(1.3 * s, 1.3 * s, 0.4), F * CFrame.new(0, 0, 0.3) * ang(0, 0, 36), STEM)
			for k = 0, 4 do
				local G = F * ang(0, 0, k * 72) * CFrame.new(0, 0.45 * s, -0.1) * ang(-36, 0, 0)
				B:block(crop, v(1.6 * s, 1.6 * s, 0.32), G * CFrame.new(0, 0.6 * s, 0), k % 2 == 0 and PET or PET_LT)
				if k % 2 == 0 then -- glossy streak
					B:block(crop, v(0.36 * s, 0.8 * s, 0.1), G * CFrame.new(0.2 * s, 0.7 * s, -0.2), PET_HL)
				end
			end
			B:block(crop, v(1.25 * s, 1.25 * s, 0.4), F * CFrame.new(0, 0, -0.15), PET_DK)
			B:block(crop, v(1.0 * s, 1.0 * s, 0.4), F * CFrame.new(0, 0, -0.35) * ang(0, 0, 45), STAMEN)
			B:block(crop, v(0.55 * s, 0.55 * s, 0.4), F * CFrame.new(0, 0, -0.62), KNOB)
			table.insert(cups, F)
			return F
		end
		local function stem(base, mid, top)
			B:bar(crop, base, mid, 0.4, 0.4, STEM)
			B:bar(crop, mid, top, 0.36, 0.36, STEM)
		end
		local function bloom(base, mid, top, n, s)
			stem(base, mid, top)
			return flower(top + n.Unit * 0.3, n, s)
		end
		bloom(v(0, 1.6, 0), v(0.2, 7.5, 0.1), v(0.0, 11.7, -0.3), v(0, 1, -0.4), 1.3)
		local fBee = bloom(v(0.5, 1.6, -0.3), v(1.4, 6.5, -0.5), v(2.7, 9.6, -0.9), v(0.6, 1, -0.4), 1.05)
		bloom(v(-0.5, 1.6, -0.2), v(-1.3, 6.2, -0.2), v(-2.6, 9.0, -0.4), v(-0.6, 1, -0.3), 1.05)
		bloom(v(0.4, 1.6, 0.5), v(1.0, 5.6, 1.4), v(1.7, 7.9, 2.4), v(0.3, 1, 0.6), 0.95)
		bloom(v(-0.3, 1.6, 0.4), v(-0.6, 6.8, 1.0), v(-0.9, 10.6, 1.8), v(-0.3, 1, 0.4), 1.05)
		bloom(v(0.3, 1.6, -0.5), v(0.6, 4.2, -1.6), v(0.9, 6.0, -2.6), v(0.2, 1, -0.9), 0.85)

		-- golden seed fruit standing on its stalk
		local function seedFruit(base, mid, top, s, yaw)
			stem(base, mid, top)
			local F = CFrame.new(top) * ang(0, yaw, 0)
			B:block(crop, v(2.0 * s, 0.26, 0.55 * s), F * CFrame.new(0, 0.15, 0), STEM)
			B:block(crop, v(0.55 * s, 0.28, 2.0 * s), F * CFrame.new(0, 0.16, 0), STEM)
			local c = F * CFrame.new(0, 0.95 * s, 0)
			B:block(crop, v(1.55 * s, 1.3 * s, 1.55 * s), c, GOLD)
			B:block(crop, v(1.25 * s, 1.7 * s, 1.25 * s), c * CFrame.new(0, 0.05 * s, 0) * ang(0, 45, 0), GOLD_DK)
			B:block(crop, v(1.1 * s, 0.5 * s, 1.1 * s), c * CFrame.new(0, 0.82 * s, 0), GOLD_LT)
			B:block(crop, v(0.22, 0.6 * s, 0.22), c * CFrame.new(0, 1.25 * s, 0) * ang(0, 0, -20), STEM_DK)
			for k = 0, 5 do -- bronze seeds dotted around the faces
				local g = c * ang(0, k * 60 + 15, 0)
				B:block(crop, v(0.3 * s, 0.3 * s, 0.14), g * CFrame.new(0, k % 2 == 0 and 0.28 * s or -0.3 * s, -0.8 * s), SEED)
			end
		end
		seedFruit(v(-0.3, 1.6, -0.4), v(-1.0, 5.2, -1.2), v(-1.7, 7.3, -2.0), 1.0, 15)
		seedFruit(v(0.5, 1.6, 0.1), v(1.6, 5.4, 0.4), v(3.0, 7.0, 0.7), 0.95, -20)
		seedFruit(v(-0.5, 1.6, 0.3), v(-1.5, 5.0, 0.9), v(-2.7, 6.6, 1.3), 0.95, 40)
		seedFruit(v(0.2, 1.6, 0.3), v(0.6, 7.0, 0.6), v(1.2, 10.4, 0.9), 1.0, 30)

		------------------------------------------------------------ bee in a cup
		local beeF = fBee * CFrame.new(0, 0, -0.95) * ang(-90, 0, 0) * ang(0, 30, 0)
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
