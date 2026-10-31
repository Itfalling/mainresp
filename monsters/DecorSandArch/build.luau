--!nocheck
-- Sandstone Arch (Sandy Savanna decoration, the biome's hero piece).
-- A tall natural rock arch built from stacked strata of red sandstone: every
-- layer is a slightly different size and offset, so the sides read as
-- weathered ledges, and thin contrasting bands stick out between layers
-- (red / terracotta / peach / cream stripes). The pillars pinch in at the
-- waist like hoodoos and flare out where they meet the lintel; the opening
-- steps inward to a rounded pixel arch. Carved sun tablets sit on both
-- pillars and a big sun keystone crowns the arch (front and back, tiny gold
-- neon centre). Crown boulders, dry grass tufts and a small barrel cactus on
-- top; flat stones, rubble, sand drifts and grass around the feet.
-- Static prop: no motion.luau.
return {
	DisplayName = "Sandstone Arch",
	Rarity = "Decor",
	Element = "Sandy Savanna",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		local SAND_DK, SAND_DK2, SAND, SAND_LT, SAND_TOP = "#c48a45", "#b77d3c", "#d9a95c", "#e8c27a", "#f0d08e"
		-- red sandstone strata
		local RED_DK, RED, TERRA, ROCK, PEACH, CREAM = "#963f24", "#c4532c", "#d6683a", "#de8a52", "#efae72", "#f7d6a0"
		local STRATA = { RED, PEACH, TERRA, CREAM, RED, ROCK, PEACH, RED, TERRA, CREAM, ROCK, RED, PEACH, TERRA, RED, CREAM, ROCK, PEACH, RED, TERRA }
		local BANDS = { CREAM, RED_DK, PEACH, CREAM, RED_DK, PEACH }
		local GRASS, GRASS_DK, GRASS_LT = "#d9b84a", "#b8963a", "#f0d872"
		local PEBBLE, PEBBLE_DK = "#bfae94", "#968670"
		local CAC_DK, CAC, CAC_LT, CAC_TOP = "#3f7d35", "#5aa848", "#7cc35a", "#9ad66c"
		local PINK, PINK_DK, SPINE = "#ff7fb4", "#e4528f", "#fbefcc"
		local SUN, SUN_LT, SUN_DK, SUN_GLOW = "#f2b048", "#ffe0a0", "#d9822e", "#ffd25a"

		local seed = 2181
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function interp(keys, y)
			if y <= keys[1][1] then
				return keys[1][2]
			end
			for i = 1, #keys - 1 do
				local a, b = keys[i], keys[i + 1]
				if y <= b[1] then
					local t = (y - a[1]) / (b[1] - a[1])
					return a[2] + (b[2] - a[2]) * t
				end
			end
			return keys[#keys][2]
		end

		------------------------------------------------------------ profile
		local TOP = 17.6
		local SPRING, CROWN, HALF = 7.4, 13.4, 3.8 -- arch springs at 7.4, closes at 13.4
		local function opening(y)
			if y <= SPRING then
				return HALF
			elseif y >= CROWN then
				return 0
			end
			local u = (y - SPRING) / (CROWN - SPRING)
			return HALF * math.sqrt(math.max(0, 1 - u * u))
		end
		local OUTER = { { 0, 9.3 }, { 1.8, 8.6 }, { 4.5, 7.5 }, { 7.0, 7.6 }, { 10.5, 8.6 }, { 13.2, 9.1 }, { 15.6, 8.9 }, { 17.6, 8.0 } }
		local DEPTH = { { 0, 5.6 }, { 2.5, 4.9 }, { 7, 4.4 }, { 11, 4.8 }, { 15, 5.1 }, { 17.6, 4.4 } }

		-- layer heights (smaller through the arch curve so the steps read round)
		local heights = { 1.3, 1.0, 1.4, 0.9, 1.2, 1.1, 0.7, 0.8, 0.7, 0.8, 0.7, 0.8, 0.7, 0.8, 0.7, 1.2, 0.9, 1.0, 0.8, 0.9 }
		local layers = {}
		local y = 0
		for i, h in heights do
			if y >= TOP - 0.1 then
				break
			end
			h = math.min(h, TOP - y)
			layers[#layers + 1] = { y0 = y, y1 = y + h, col = STRATA[(i - 1) % #STRATA + 1], i = i }
			y += h
		end

		-- front-face record for placing carvings flush: {y0,y1,side,zFront,zBack,xIn,xOut}
		local faces = {}
		for _, Lr in layers do
			local ym = (Lr.y0 + Lr.y1) / 2
			local ho = opening(Lr.y1 - 0.05)
			local wo = interp(OUTER, ym) + rnd(-0.25, 0.25)
			local d = interp(DEPTH, ym) + rnd(-0.2, 0.2)
			if Lr.i % 3 == 0 then -- eroded groove layer
				wo -= 0.45
				d -= 0.5
			end
			local dz = rnd(-0.18, 0.18)
			local h = Lr.y1 - Lr.y0
			local band = (Lr.i % 2 == 0) and BANDS[(Lr.i / 2 - 1) % #BANDS + 1] or nil
			if ho > 0.05 then
				for _, sx in { 1, -1 } do
					local xin = ho + rnd(-0.12, 0.12)
					local xout = wo + rnd(-0.2, 0.2)
					local w = xout - xin
					local cx = sx * (xin + xout) / 2
					B:block(R, v(w, h, d), cf(cx, Lr.y0 + h / 2, dz), Lr.col)
					faces[#faces + 1] = { Lr.y0, Lr.y1, sx, dz - d / 2, dz + d / 2, xin, xout }
					if band then
						-- thin protruding strata band at the bottom of this layer
						B:block(R, v(w + 0.3, 0.26, d + 0.3), cf(cx + sx * 0.08, Lr.y0 + 0.13, dz), band)
					end
				end
			else
				local w = 2 * wo
				B:block(R, v(w, h, d), cf(rnd(-0.2, 0.2), Lr.y0 + h / 2, dz), Lr.col)
				faces[#faces + 1] = { Lr.y0, Lr.y1, 0, dz - d / 2, dz + d / 2, -wo, wo }
				if band then
					B:block(R, v(w + 0.3, 0.26, d + 0.3), cf(0, Lr.y0 + 0.13, dz), band)
				end
			end
		end
		-- soffit: a darker underside strip along the inner arch curve
		for _, Lr in layers do
			local ho = opening(Lr.y1 - 0.05)
			if Lr.y0 >= SPRING - 0.5 and ho > 0.05 then
				for _, sx in { 1, -1 } do
					B:block(R, v(0.3, Lr.y1 - Lr.y0 + 0.02, 3.4), cf(sx * (ho + 0.05), (Lr.y0 + Lr.y1) / 2, 0), RED_DK)
				end
			end
		end

		-- the frontmost (or backmost) face over a y-range for a given side
		local function faceZ(y0, y1, side, back)
			local z = back and -1e9 or 1e9
			for _, f in faces do
				if f[2] > y0 and f[1] < y1 and (f[3] == side or f[3] == 0) then
					if back then
						z = math.max(z, f[5])
					else
						z = math.min(z, f[4])
					end
				end
			end
			return z
		end

		------------------------------------------------------------ erosion chunks
		-- weathered blocks poking out of the faces (other strata colours)
		for k = 1, 22 do
			local Lr = layers[math.floor(rnd(1, #layers + 0.999))]
			local ym = (Lr.y0 + Lr.y1) / 2
			local ho = opening(Lr.y1 - 0.05)
			local sx = (k % 2 == 0) and 1 or -1
			local x
			if ho > 0.05 then
				x = sx * rnd(ho + 0.8, interp(OUTER, ym) - 0.6)
			else
				x = rnd(-7, 7)
			end
			local back = rnd(0, 1) > 0.5
			local side = ho > 0.05 and sx or 0
			local z = faceZ(Lr.y0, Lr.y1, side, back)
			local s = rnd(0.7, 1.3)
			local zc = back and (z - s * 0.3) or (z + s * 0.3)
			B:block(R, v(s * rnd(1.0, 1.6), s * 0.7, s), cf(x, ym + rnd(-0.2, 0.2), zc, 0, rnd(-8, 8), 0), pick({ PEACH, CREAM, RED, TERRA }))
		end
		-- outer side chunks (ledges on the X faces)
		for k = 1, 10 do
			local Lr = layers[math.floor(rnd(1, #layers + 0.999))]
			local ym = (Lr.y0 + Lr.y1) / 2
			local sx = (k % 2 == 0) and 1 or -1
			local wo = interp(OUTER, ym)
			local s = rnd(0.8, 1.3)
			B:block(R, v(s, s * 0.7, s * rnd(1.2, 2.0)), cf(sx * (wo + 0.05), ym, rnd(-1.2, 1.2), 0, rnd(-10, 10), 0), pick({ PEACH, CREAM, RED, ROCK }))
		end

		------------------------------------------------------------ sun carvings
		-- a recessed tablet (dark panel set into the rock) with a stepped sun
		local function sun(x, yc, side, s, back, glow)
			local zf = faceZ(yc - 1.7 * s, yc + 1.7 * s, side, back)
			local dir = back and 1 or -1 -- outward
			local base = CFrame.new(x, yc, zf) * (back and ang(0, 180, 0) or CFrame.new())
			-- local -Z is outward now
			local function at(px, py, pz)
				return base * CFrame.new(px, py, -pz)
			end
			B:block(R, v(3.4 * s, 3.4 * s, 1.0), at(0, 0, -0.42), RED_DK)
			B:block(R, v(3.0 * s, 3.0 * s, 0.2), at(0, 0, 0.12), RED)
			-- rays
			for k = 0, 7 do
				local a = k * 45
				local long = (k % 2 == 0)
				local c = at(0, 0, 0.24) * ang(0, 0, a) * CFrame.new(0, (long and 1.12 or 1.0) * s, 0)
				B:block(R, v((long and 0.5 or 0.4) * s, (long and 0.75 or 0.55) * s, 0.14), c, long and SUN_LT or SUN)
			end
			-- disc: octagon of a square + 45deg square, stepped toward the viewer
			B:block(R, v(1.35 * s, 1.35 * s, 0.24), at(0, 0, 0.3), SUN)
			B:block(R, v(1.35 * s, 1.35 * s, 0.22), at(0, 0, 0.3) * ang(0, 0, 45), SUN_DK)
			B:block(R, v(0.95 * s, 0.95 * s, 0.2), at(0, 0, 0.42), SUN_LT)
			if glow then
				B:gem(R, v(0.42 * s, 0.42 * s, 0.14), at(0, 0, 0.54) * ang(0, 0, 45), SUN_GLOW)
			else
				B:block(R, v(0.42 * s, 0.42 * s, 0.14), at(0, 0, 0.54) * ang(0, 0, 45), SUN)
			end
		end
		local PX = (HALF + 7.8) / 2 -- pillar centre
		sun(PX, 5.2, 1, 0.85, false, false)
		sun(-PX, 5.2, -1, 0.85, false, false)
		sun(PX, 5.2, 1, 0.85, true, false)
		sun(-PX, 5.2, -1, 0.85, true, false)
		sun(0, 15.4, 0, 1.1, false, true)
		sun(0, 15.4, 0, 1.1, true, true)

		------------------------------------------------------------ crown
		local topY = layers[#layers].y1
		-- the top edge humps up in the middle (arched cap strata)
		B:block(R, v(12.4, 0.8, 4.0), cf(0.3, topY + 0.4, 0.1), ROCK)
		B:block(R, v(12.9, 0.24, 4.3), cf(0.3, topY + 0.12, 0.1), CREAM)
		B:block(R, v(8.2, 0.7, 3.6), cf(-0.2, topY + 1.15, 0.0), RED)
		B:block(R, v(4.2, 0.6, 3.0), cf(0.1, topY + 1.8, 0.1), PEACH)
		topY += 0.0
		B:block(R, v(2.6, 0.9, 2.4), cf(-7.0, topY + 0.45, 0.4, 0, 12, 0), PEACH)
		B:block(R, v(1.4, 0.6, 1.3), cf(-7.2, topY + 1.15, 0.3, 0, -8, 0), CREAM)
		B:block(R, v(2.2, 0.7, 2.0), cf(7.2, topY + 0.35, -0.5, 0, -14, 0), RED)
		B:block(R, v(1.5, 0.9, 1.3), cf(-1.6, topY + 2.5, 0.2, 0, 18, 0), TERRA)

		-- dry grass tufts
		local function tuft(x, z, yb, s)
			s = s or 1
			local base = CFrame.new(x, yb, z) * ang(0, rnd(0, 90), 0)
			B:block(R, v(0.3, 1.4 * s, 0.3), base * CFrame.new(0, 0.6 * s, 0), GRASS)
			B:block(R, v(0.28, 1.15 * s, 0.28), base * CFrame.new(0.3, 0.45 * s, 0) * ang(0, 0, -25), GRASS_LT)
			B:block(R, v(0.28, 1.0 * s, 0.28), base * CFrame.new(-0.28, 0.4 * s, 0.05) * ang(0, 0, 25), GRASS_DK)
			B:block(R, v(0.26, 0.9 * s, 0.26), base * CFrame.new(0, 0.36 * s, 0.28) * ang(25, 0, 0), GRASS)
		end
		tuft(2.6, -0.9, topY + 1.4, 1.0)
		tuft(-5.4, 0.8, topY + 0.7, 1.0)
		tuft(6.6, 0.9, topY - 0.1, 0.9)
		tuft(-0.4, 1.0, topY + 2.0, 0.8)

		-- small barrel cactus on the crown, with a pink flower (scale k)
		local function miniBarrel(cx, cz, cy, k)
			local y0 = cy
			for _, t in { { 0.25, 1.0, CAC_DK }, { 0.6, 1.25, CAC }, { 0.45, 1.15, CAC }, { 0.25, 0.85, CAC_LT } } do
				local th, w = t[1] * k, t[2] * k
				B:block(R, v(w, th + 0.02, w), cf(cx, cy + th / 2, cz), t[3])
				B:block(R, v(w * 0.86, th + 0.04, w * 0.86), cf(cx, cy + th / 2, cz, 0, 45, 0), CAC_DK)
				cy += th
			end
			for j = 0, 7 do
				local a = rad(j * 45)
				local r = (j % 2 == 0) and 0.58 * k or 0.66 * k
				B:block(R, v(0.2, 0.2, 0.2), cf(cx + math.sin(a) * r, y0 + (0.6 + (j % 2) * 0.35) * k, cz - math.cos(a) * r, 0, j * 45, 0), SPINE)
			end
			for j = 0, 4 do
				B:block(R, v(0.4 * k, 0.16 * k, 0.55 * k), CFrame.new(cx, cy - 0.05, cz) * ang(0, j * 72, 0) * CFrame.new(0, 0.12 * k, -0.3 * k) * ang(30, 0, 0), PINK)
			end
			B:block(R, v(0.3 * k, 0.3 * k, 0.3 * k), cf(cx, cy + 0.12 * k, cz, 0, 45, 0), PINK_DK)
		end
		miniBarrel(0.9, 0.4, topY + 2.05, 1.35)
		miniBarrel(-4.4, -0.9, topY + 0.78, 0.9)

		-- grass sprouting from a couple of ledges
		tuft(-8.3, -1.6, 3.4, 0.7)
		tuft(8.0, 1.8, 7.6, 0.7)

		------------------------------------------------------------ footing
		-- sand drifts at the pillar feet + flat stones + rubble + tufts
		for _, sx in { 1, -1 } do
			B:block(R, v(9.0, 0.4, 7.4), cf(sx * 6.0, 0.2, 0), SAND_DK)
			B:block(R, v(7.0, 0.36, 8.4), cf(sx * 6.2, 0.18, 0.1, 0, sx * 8, 0), SAND_DK2)
			B:block(R, v(10.4, 0.3, 6.4), cf(sx * 5.6, 0.15, -0.2, 0, -sx * 6, 0), SAND)
		end
		B:block(R, v(6.0, 0.32, 5.4), cf(0, 0.16, 0), SAND_DK)
		-- stepping stones through the arch
		for _, s in { { -0.8, -2.4, 1.6, 15, PEACH }, { 0.7, -0.4, 1.4, -10, CREAM }, { -0.4, 1.6, 1.5, 30, PEACH }, { 0.5, 3.5, 1.2, 5, CREAM } } do
			B:block(R, v(s[3], 0.22, s[3] * 0.85), cf(s[1], 0.4, s[2], 0, s[4], 0), s[5])
		end
		-- rubble boulders at the feet
		local function rock(x, z, yb, s, yaw)
			local c = CFrame.new(x, yb, z) * ang(0, yaw, 0)
			B:block(R, v(1.6 * s, 0.3 * s, 1.3 * s), c * CFrame.new(0, 0.15 * s, 0), RED_DK)
			B:block(R, v(1.4 * s, 0.8 * s, 1.15 * s), c * CFrame.new(0, 0.65 * s, 0), ROCK)
			B:block(R, v(1.0 * s, 0.5 * s, 0.85 * s), c * CFrame.new(0.12 * s, 1.25 * s, -0.04 * s) * ang(0, 14, 0), PEACH)
		end
		rock(-9.6, -2.4, 0.3, 1.2, 20)
		rock(9.8, 2.2, 0.3, 1.0, -25)
		rock(4.4, -3.6, 0.3, 0.8, 35)
		rock(-5.0, 3.5, 0.3, 0.75, -10)
		rock(10.2, -1.8, 0.25, 0.6, 5)
		-- fallen strata slab leaning on the left pillar
		B:block(R, v(2.6, 0.6, 1.8), cf(-9.4, 1.0, 1.2, 0, 15, 24), CREAM)
		-- pebbles
		for _, p in { { -2.6, -3.0 }, { 2.3, 2.8 }, { 7.6, -3.5 }, { -7.4, 3.6 }, { 11.0, 0.4 }, { -11.0, 0.2 } } do
			B:block(R, v(0.5, 0.36, 0.45), cf(p[1], 0.48, p[2], 0, rnd(0, 90), 0), pick({ PEBBLE, PEBBLE_DK }))
		end
		tuft(-2.6, -2.2, 0.3, 1.0)
		tuft(3.0, 2.2, 0.3, 0.9)
		tuft(-8.6, 3.2, 0.3, 1.1)
		tuft(8.8, -3.0, 0.3, 1.0)
		tuft(11.2, 1.6, 0.25, 0.8)
		tuft(-11.0, -1.4, 0.25, 0.9)
		tuft(6.0, 3.6, 0.3, 0.8)
	end,
}
