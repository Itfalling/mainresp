--!nocheck
-- Barrel Cactus Cluster (Sandy Savanna decoration, small accent).
-- Four chunky barrel cacti of different sizes huddled on a flat stepped
-- golden-sand patch with layered sandstone rocks, pebbles and dry grass.
-- Each barrel is a stack of stepped octagonal tiers (a square block plus a
-- 45-degree block, so the corners read as ribs) that swell in the middle and
-- step in to a flat crown; cream spine cubes sit on the rib edges and a ring
-- of chunky petals (pink / yellow / orange) blooms on the crown.
-- Palette matches the savanna crops (Date Cactus, Prickly Pear).
-- Static prop: no motion.luau.
return {
	DisplayName = "Barrel Cactus Cluster",
	Rarity = "Decor",
	Element = "Sandy Savanna",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		local SAND_DK, SAND_DK2, SAND, SAND_LT, SAND_TOP = "#c48a45", "#b77d3c", "#d9a95c", "#e8c27a", "#f0d08e"
		local ROCK, ROCK_DK, ROCK_LT = "#c9774a", "#a9573a", "#e0a06a"
		local GRASS, GRASS_DK, GRASS_LT = "#d9b84a", "#b8963a", "#f0d872"
		local PEBBLE, PEBBLE_DK = "#bfae94", "#968670"
		local CAC_DK, CAC, CAC_LT, CAC_TOP = "#3f7d35", "#5aa848", "#7cc35a", "#9ad66c"
		local SPINE, SPINE_TIP = "#fbefcc", "#e8b45a"
		local FLOWERS = {
			{ "#ff7fb4", "#e4528f", "#ffe066" }, -- pink
			{ "#ffd23f", "#f0a81c", "#ff8a3c" }, -- yellow
			{ "#ff8a3c", "#e0612a", "#ffe066" }, -- orange
		}

		local seed = 2161
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end

		------------------------------------------------------------ sand footing
		-- a low, irregular stepped patch (no mound): two thin tiers + edge chunks
		B:block(R, v(8.6, 0.4, 5.2), cf(0, 0.2, 0.1), SAND_DK)
		B:block(R, v(5.6, 0.38, 7.6), cf(0.3, 0.19, 0), SAND_DK)
		B:block(R, v(7.4, 0.36, 6.6), cf(-0.2, 0.18, 0.2, 0, 12, 0), SAND_DK2)
		for i = 0, 9 do
			local a = (i + rnd(-0.25, 0.25)) / 10 * 360
			local r = 3.6 + rnd(-0.2, 0.3)
			local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0, -r)
			local h = rnd(0.32, 0.5)
			B:block(R, v(rnd(1.4, 2.0), h, rnd(1.0, 1.4)), CFrame.new(p.Position.X * 1.08, h / 2, p.Position.Z * 0.92) * ang(0, a + rnd(-8, 8), 0), pick({ SAND_DK, SAND_DK2, SAND }))
		end
		B:block(R, v(5.8, 0.3, 4.4), cf(0.2, 0.52, 0.1, 0, -8, 0), SAND)
		B:block(R, v(3.8, 0.24, 3.2), cf(-0.4, 0.74, 0.3, 0, 18, 0), SAND_LT)
		B:block(R, v(1.6, 0.12, 1.0), cf(1.9, 0.72, -1.7, 0, 25, 0), SAND_TOP)
		B:block(R, v(1.2, 0.12, 0.8), cf(-2.6, 0.45, -1.9, 0, -15, 0), SAND_TOP)

		-- layered sandstone rocks
		local function rock(x, z, y, s, yaw)
			local c = CFrame.new(x, y, z) * ang(0, yaw, 0)
			B:block(R, v(1.6 * s, 0.25 * s, 1.3 * s), c * CFrame.new(0, 0.12 * s, 0), ROCK_DK)
			B:block(R, v(1.4 * s, 0.75 * s, 1.1 * s), c * CFrame.new(0, 0.55 * s, 0), ROCK)
			B:block(R, v(1.0 * s, 0.5 * s, 0.8 * s), c * CFrame.new(0.15 * s, 1.1 * s, -0.05 * s) * ang(0, 14, 0), ROCK_LT)
		end
		rock(3.3, 1.5, 0.3, 1.05, -25)
		rock(-3.4, -1.3, 0.25, 0.75, 30)
		rock(-1.6, 2.9, 0.3, 0.6, 10)
		-- pebbles
		B:block(R, v(0.55, 0.4, 0.5), cf(2.7, 0.55, -2.4, 0, 40, 0), PEBBLE)
		B:block(R, v(0.45, 0.35, 0.45), cf(-3.6, 0.5, 1.5, 0, 15, 0), PEBBLE_DK)
		B:block(R, v(0.5, 0.35, 0.4), cf(0.9, 0.55, 2.9, 0, 60, 0), PEBBLE)
		B:block(R, v(0.4, 0.3, 0.4), cf(4.0, 0.5, -0.6, 0, 20, 0), PEBBLE_DK)

		-- dry grass tufts
		local function tuft(x, z, y, s)
			s = s or 1
			local base = CFrame.new(x, y, z) * ang(0, rnd(0, 90), 0)
			B:block(R, v(0.3, 1.3 * s, 0.3), base * CFrame.new(0, 0.55 * s, 0), GRASS)
			B:block(R, v(0.28, 1.05 * s, 0.28), base * CFrame.new(0.28, 0.42 * s, 0) * ang(0, 0, -25), GRASS_LT)
			B:block(R, v(0.28, 0.95 * s, 0.28), base * CFrame.new(-0.27, 0.38 * s, 0.05) * ang(0, 0, 25), GRASS_DK)
			B:block(R, v(0.26, 0.85 * s, 0.26), base * CFrame.new(0, 0.34 * s, 0.26) * ang(25, 0, 0), GRASS)
		end
		tuft(-3.9, 0.6, 0.35, 1.0)
		tuft(3.9, -1.6, 0.35, 0.9)
		tuft(1.2, -3.0, 0.4, 0.8)
		tuft(-0.6, 3.3, 0.4, 0.9)
		tuft(2.4, 2.9, 0.35, 0.7)

		------------------------------------------------------------ barrel cacti
		-- octagonal tier: square + 45deg block; rib corners carry spines
		local function tier(x, z, y0, h, w, col, colDk, spineRow)
			local c = CFrame.new(x, y0 + h / 2, z)
			B:block(R, v(w, h, w), c, col)
			local s = w * 0.86
			B:block(R, v(s, h + 0.04, s), c * ang(0, 45, 0), colDk)
			if spineRow then
				local y = y0 + h * 0.55
				for k = 0, 7 do
					local a = rad(k * 45)
					local d = (k % 2 == 0) and (s / math.sqrt(2) + 0.05) or (w / math.sqrt(2) + 0.05)
					-- 45deg block corners point along the axes; square block corners on diagonals
					local px, pz = math.sin(a) * d, -math.cos(a) * d
					local ss = math.min(0.24, 0.14 + 0.04 * w)
					B:block(R, v(ss, ss, ss), CFrame.new(x + px, y, z + pz) * ang(0, -math.deg(a), 0), SPINE)
				end
			end
		end

		local function flower(x, z, y, s, cols)
			local yaw = rnd(0, 45)
			local n = 6
			for k = 0, n - 1 do
				local a = yaw + k * 360 / n
				local c = CFrame.new(x, y, z) * ang(0, a, 0) * CFrame.new(0, 0.2 * s, -0.5 * s) * ang(32, 0, 0)
				B:block(R, v(0.6 * s, 0.22 * s, 0.85 * s), c, cols[1])
				local c2 = CFrame.new(x, y, z) * ang(0, a + 30, 0) * CFrame.new(0, 0.32 * s, -0.26 * s) * ang(58, 0, 0)
				B:block(R, v(0.36 * s, 0.18 * s, 0.45 * s), c2, cols[2])
			end
			B:block(R, v(0.5 * s, 0.45 * s, 0.5 * s), CFrame.new(x, y + 0.34 * s, z) * ang(0, yaw + 45, 0), cols[3])
			B:block(R, v(0.24 * s, 0.16 * s, 0.24 * s), CFrame.new(x, y + 0.6 * s, z) * ang(0, yaw, 0), cols[1])
		end

		-- a barrel: stepped "pixel round" profile, crown steps, flower(s)
		local function barrel(x, z, y0, w, h, cols, bud)
			local prof = { -- {height fraction, width fraction, colour, dark, spines}
				{ 0.10, 0.78, CAC_DK, CAC_DK, false },
				{ 0.14, 0.92, CAC, CAC_DK, true },
				{ 0.22, 1.00, CAC, CAC_DK, true },
				{ 0.18, 0.97, CAC, CAC_DK, true },
				{ 0.13, 0.86, CAC, CAC_DK, true },
				{ 0.09, 0.70, CAC_LT, CAC, false },
				{ 0.06, 0.50, CAC_TOP, CAC_LT, false },
			}
			local y = y0
			for _, b in prof do
				local th = h * b[1]
				tier(x, z, y, th + 0.02, w * b[2], b[3], b[4], b[5])
				y += th
			end
			-- golden wool tuft on the crown with spine tips
			B:block(R, v(w * 0.3, 0.16, w * 0.3), cf(x, y + 0.06, z, 0, 45, 0), SPINE)
			for k = 0, 3 do
				local a = rad(k * 90 + 22)
				B:block(R, v(0.16, 0.36, 0.16), CFrame.new(x + math.sin(a) * w * 0.27, y + 0.12, z - math.cos(a) * w * 0.27) * ang(0, -math.deg(a), -20), SPINE_TIP)
			end
			flower(x, z, y - 0.1, 0.85 + w * 0.2, cols)
			if bud then
				local a = rad(bud)
				local r = w * 0.36
				local bx, bz = x + math.sin(a) * r, z - math.cos(a) * r
				B:block(R, v(0.42, 0.5, 0.42), cf(bx, y - 0.05, bz, 0, 45, 0), cols[2])
				B:block(R, v(0.28, 0.25, 0.28), cf(bx, y + 0.3, bz, 0, 10, 0), cols[1])
			end
			return y
		end

		-- big barrel (back-left), medium (front-right), small (front-left), tiny (back-right)
		barrel(-0.8, 0.5, 0.7, 3.4, 4.3, FLOWERS[1], 140)
		barrel(1.7, -1.0, 0.65, 2.6, 2.9, FLOWERS[2], 250)
		barrel(-1.9, -1.6, 0.55, 1.9, 1.85, FLOWERS[3], nil)
		barrel(2.0, 1.5, 0.6, 1.5, 1.45, FLOWERS[1], nil)
		-- a baby pup barrel at the big one's foot
		tier(0.0, -2.6, 0.5, 0.55, 0.9, CAC, CAC_DK, false)
		B:block(R, v(0.55, 0.2, 0.55), cf(0.0, 1.12, -2.6, 0, 45, 0), CAC_LT)
		B:block(R, v(0.22, 0.2, 0.22), cf(0.0, 1.28, -2.6), SPINE)
		-- a fallen petal and a dry twig in the sand
		B:block(R, v(0.4, 0.12, 0.5), cf(-0.9, 0.82, -2.3, 0, 30, 0), FLOWERS[1][1])
		B:block(R, v(0.38, 0.12, 0.46), cf(3.1, 0.6, -1.0, 0, -20, 0), FLOWERS[2][1])
		B:bar(R, v(-2.8, 0.5, 2.2), v(-1.6, 0.62, 2.6), 0.18, 0.18, "#9a7a4c")
	end,
}
