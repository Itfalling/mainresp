--!nocheck
-- Pollen Pumpkin (Honey Hills crop #3, Rare).
-- A crooked wooden garden stake topped with a big grooved honey dipper that
-- drips golden honey stands in a stepped grassy meadow mound. A leafy pumpkin
-- vine spirals up the stake, sends two lashed side pegs out and hangs golden
-- pumpkins from them; three more pumpkins sit on the grass.
-- Every pumpkin is a stepped round golden-orange fruit whose ribs are amber
-- honeycomb strips (light hex cells), with a fluffy pale pollen dusting
-- round the stem.
-- Base: grassy soil tiers with a grass lip, tiny pastel wildflowers, clover,
-- a honey puddle and pebbles. Static prop: no motion.luau. Blocks only.
return {
	DisplayName = "Pollen Pumpkin",
	Rarity = "Rare",
	Element = "Nature",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Honey Hills)
		local SOIL, SOIL_DK, SOIL_LT = "#8a5a34", "#6e4426", "#a06c3e"
		local GRASS, GRASS_LT, GRASS_DK = "#a6d455", "#c0e26c", "#86bd42"
		local PEB, PEB_DK = "#d8cfc0", "#a89d8c"
		local PINK, LAV, WHITE, BUTTER = "#ffb3d1", "#c7a6ff", "#fff8ec", "#ffe066"
		local CLOVER, CLOVER_DK = "#4fae3a", "#3d9230"
		local HONEY, HONEY_LT, HONEY_DK = "#f5a417", "#ffc845", "#d4800c"
		local WOOD, WOOD_LT, WOOD_DK = "#c99a5e", "#ddb57a", "#a87a44"
		local TWINE = "#e8cf8a"
		local VINE, VINE_DK = "#5aa332", "#438a26"
		local LEAF = { "#5fae38", "#78c447", "#4a9430", "#8fd156" }
		local PUMP, PUMP_LT, PUMP_DK = "#f7b52c", "#ffcd52", "#e0921c"
		local RIB, RIB_DK = "#c96c0e", "#a85a0a"
		local CELL = "#ffe28a"
		local STEM = "#6b8a2a"
		local FLOWER, FLOWER_C = "#ffd23f", "#f28a1d"
		local POLLEN, POLLEN_LT = "#fff08a", "#fffbd0"

		local seed = 1633
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function dirOf(deg)
			local a = rad(deg)
			return v(math.sin(a), 0, -math.cos(a))
		end

		---------------------------------------------------------------- grassy mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(bn, r, h, y, col, o)
			B:block(bn, v(2 * r, h, 1.1 * r), cf(0, y, 0), col, o)
			B:block(bn, v(1.1 * r, h - 0.04, 2 * r), cf(0, y, 0), col, o)
			B:block(bn, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y, 0), col, o)
		end
		local function tier(y0, h, r, nEdge)
			oct(soil, r, h - 0.3, y0 + (h - 0.3) / 2, SOIL, S)
			oct(soil, r + 0.15, 0.4, y0 + h - 0.2, GRASS, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.6, 2.3), rnd(1.1, 1.5)
				local eh = h + rnd(-0.15, 0.25)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0, -(r + rnd(0.05, 0.3)))
				B:block(soil, v(w, eh - 0.32, d), p * cf(0, (eh - 0.32) / 2, 0, 0, rnd(-6, 6), 0), pick({ SOIL, SOIL_DK, SOIL_LT }), S)
				B:block(soil, v(w + 0.15, 0.4, d + 0.15), p * cf(0, eh - 0.18, 0, 0, rnd(-6, 6), 0), pick({ GRASS, GRASS_LT, GRASS_DK }), S)
			end
		end
		tier(0, 1.15, 6.2, 11)
		tier(1.15, 0.8, 4.3, 7)
		tier(1.95, 0.45, 2.7, 0)
		local TOP = 2.4

		-- honey puddle on the middle tier (front-left)
		do
			local c = v(-2.9, 1.97, -2.4)
			B:block(soil, v(2.4, 0.14, 1.5), CFrame.new(c) * ang(0, 25, 0), HONEY, S)
			B:block(soil, v(1.5, 0.15, 2.1), CFrame.new(c + v(0.2, 0, 0.1)) * ang(0, 25, 0), HONEY, S)
			B:block(soil, v(1.0, 0.17, 0.5), CFrame.new(c + v(-0.3, 0.02, -0.2)) * ang(0, 25, 0), HONEY_LT, S)
			-- spill running over the tier lip
			B:block(soil, v(0.6, 0.6, 0.25), CFrame.new(v(-3.3, 1.7, -3.85)) * ang(0, 25, 0), HONEY_DK, S)
			B:block(soil, v(0.4, 0.25, 0.4), CFrame.new(v(-3.45, 1.3, -3.95)) * ang(0, 25, 0), HONEY_DK, S)
		end
		-- pebbles
		for _, p in { { 5.2, 1.15, -2.6 }, { -5.5, 1.15, 1.2 }, { 0.9, 1.15, 5.6 } } do
			B:block(soil, v(0.6, 0.35, 0.5), cf(p[1], p[2] + 0.15, p[3], 0, rnd(0, 90), 0), pick({ PEB, PEB_DK }), S)
		end
		-- tiny pastel wildflowers
		local function wild(x, y, z, col, s)
			s = (s or 1) * 1.4
			B:block(soil, v(0.18, 0.7 * s, 0.18), cf(x, y + 0.35 * s, z), GRASS_DK, S)
			B:block(soil, v(0.6 * s, 0.18, 0.25 * s), cf(x, y + 0.75 * s, z, 0, 30, 0), col, S)
			B:block(soil, v(0.25 * s, 0.2, 0.6 * s), cf(x, y + 0.75 * s, z, 0, 30, 0), col, S)
			B:block(soil, v(0.22, 0.24, 0.22), cf(x, y + 0.8 * s, z, 0, 30, 0), BUTTER, S)
		end
		wild(5.6, 1.15, -0.6, PINK)
		wild(-4.6, 1.15, -3.6, LAV)
		wild(-5.2, 1.15, 3.0, WHITE)
		wild(2.7, 1.15, -5.3, LAV, 0.9)
		wild(3.6, 1.95, -2.0, PINK, 0.9)
		-- clover patches (three leaves + a pink puff)
		local function clover(x, y, z, yaw)
			for k = 0, 2 do
				local d = dirOf(yaw + k * 120)
				B:block(soil, v(0.55, 0.16, 0.55), CFrame.new(v(x, y + 0.1, z) + d * 0.3) * ang(0, yaw + k * 120 + 45, 0), k == 1 and CLOVER_DK or CLOVER, S)
			end
			B:block(soil, v(0.3, 0.3, 0.3), cf(x, y + 0.35, z, 0, yaw, 0), PINK, S)
		end
		clover(4.6, 1.15, 3.4, 10)
		clover(-5.4, 1.15, -1.4, 50)

		---------------------------------------------------------------- pumpkin helper
		-- c = centre of the body, s = scale, yaw degrees. cells = number of faces
		-- (starting from the front, going right) whose honeycomb rib gets hex cells.
		local function hex(bn, F, r, col, o)
			for k = 0, 2 do
				B:block(bn, v(r, r * 1.732, 0.12), F * CFrame.Angles(0, 0, rad(k * 60)), col, o)
			end
		end
		local function pumpkin(bn, c, s, yaw, opt)
			opt = opt or {}
			local o = opt.o
			local F = CFrame.new(c) * CFrame.Angles(0, rad(yaw or 0), 0)
			local function at(x, y, z, ry)
				return F * CFrame.new(x * s, y * s, z * s) * CFrame.Angles(0, rad(ry or 0), 0)
			end
			-- stepped round body: crossed golden slabs, amber filler shows at the
			-- octagon corners as the diagonal ribs
			B:block(bn, v(3.4 * s, 1.6 * s, 2.3 * s), at(0, 0, 0), PUMP, o)
			B:block(bn, v(2.3 * s, 1.58 * s, 3.4 * s), at(0, 0, 0), PUMP, o)
			B:block(bn, v(3.0 * s, 1.56 * s, 3.0 * s), at(0, 0, 0), RIB, o)
			for _, b in { { 1.0, PUMP_LT }, { -0.95, PUMP_DK } } do
				B:block(bn, v(2.7 * s, 0.7 * s, 1.7 * s), at(0, b[1], 0), b[2], o)
				B:block(bn, v(1.7 * s, 0.68 * s, 2.7 * s), at(0, b[1], 0), b[2], o)
				B:block(bn, v(2.35 * s, 0.66 * s, 2.35 * s), at(0, b[1], 0), RIB_DK, o)
			end
			B:block(bn, v(1.6 * s, 0.4 * s, 1.6 * s), at(0, 1.45, 0), PUMP_LT, o)
			B:block(bn, v(1.4 * s, 0.34 * s, 1.4 * s), at(0, -1.4, 0), PUMP_DK, o)
			-- honeycomb ribs down the 4 faces
			for i = 0, 3 do
				local f = at(0, 0, 0, -i * 90) * CFrame.new(0, -0.05 * s, -1.7 * s - 0.06)
				B:block(bn, v(0.85 * s, 2.3 * s, 0.14), f, RIB, o)
				if i < (opt.cells or 0) then
					for _, y in { 0.48, -0.48 } do
						hex(bn, f * CFrame.new(0, y * s, -0.06), 0.36 * s, CELL, o)
					end
				end
			end
			-- fluffy pollen dusting round the stem + a few pollen grains
			local top = at(0, 1.65, 0).Position
			B:block(bn, v(1.25 * s, 0.22, 1.25 * s), at(0, 1.67, 0, 45), POLLEN, o)
			B:block(bn, v(0.9 * s, 0.3, 0.9 * s), at(0, 1.7, 0, 0), POLLEN_LT, o)
			if opt.pollen then
				B:block(bn, v(0.3 * s, 0.14, 0.3 * s), at(-1.0, 1.45, -0.55, 20) * CFrame.new(0, 0.12, 0), POLLEN, o)
				B:block(bn, v(0.26 * s, 0.14, 0.26 * s), at(0.95, 1.45, 0.45, 50) * CFrame.new(0, 0.12, 0), POLLEN_LT, o)
			end
			-- stem
			if not opt.noStem then
				local s1 = top + v(0, 0.75 * s, 0)
				B:bar(bn, top - v(0, 0.1, 0), s1, 0.38 * s, 0.38 * s, STEM, o)
				B:bar(bn, s1 - v(0, 0.1, 0), s1 + (F.RightVector * 0.5 + v(0, 0.25, 0)) * s, 0.3 * s, 0.3 * s, STEM, o)
			end
			return top
		end

		---------------------------------------------------------------- the stake + honey dipper
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		local PX, PZ = 0.2, 0.7
		local STAKE_TOP = 12.9
		B:block(crop, v(1.0, 0.55, 0.9), cf(PX - 0.9, TOP + 0.2, PZ - 0.4, 0, 20, 6), PEB_DK)
		B:block(crop, v(0.9, 0.5, 0.8), cf(PX + 0.85, TOP + 0.18, PZ + 0.5, 0, -30, -5), PEB)
		B:block(crop, v(1.1, 6.2, 1.1), cf(PX, TOP + 2.9, PZ, 0, 6, 0), WOOD)
		B:block(crop, v(0.95, STAKE_TOP - TOP - 5.8, 0.95), cf(PX, (TOP + 5.8 + STAKE_TOP) / 2, PZ, 0, -4, 1.2), WOOD_LT)
		B:block(crop, v(0.14, 3.0, 0.1), cf(PX - 0.25, TOP + 2.4, PZ - 0.58, 0, 6, 0), WOOD_DK)
		B:block(crop, v(0.12, 2.0, 0.1), cf(PX + 0.2, TOP + 7.6, PZ - 0.5, 0, -4, 1.2), WOOD_DK)
		-- twine ties
		B:block(crop, v(1.35, 0.35, 1.35), cf(PX, TOP + 5.6, PZ, 0, 20, 0), TWINE)
		B:block(crop, v(1.2, 0.3, 1.2), cf(PX, TOP + 8.1, PZ, 0, -15, 0), TWINE)
		-- dipper head: grooved stack of octagon discs
		local DY = STAKE_TOP
		local discs = { { 0.75, 0.45, WOOD_DK }, { 1.25, 0.5, WOOD }, { 0.95, 0.35, WOOD_DK }, { 1.35, 0.55, WOOD_LT }, { 1.0, 0.35, WOOD_DK }, { 1.15, 0.5, WOOD }, { 0.6, 0.4, WOOD_DK } }
		local y = DY
		for i, d in discs do
			local yc = y + d[2] / 2
			B:block(crop, v(2 * d[1], d[2], 2 * d[1]), cf(PX, yc, PZ, 0, 10, 0), d[3])
			if d[1] > 0.9 then
				B:block(crop, v(2 * d[1], d[2] - 0.04, 2 * d[1]), cf(PX, yc, PZ, 0, 55, 0), d[3])
			end
			y += d[2]
		end
		local DTOP = y
		-- handle nub on top
		B:block(crop, v(0.5, 0.6, 0.5), cf(PX, DTOP + 0.3, PZ, 0, 10, 0), WOOD_LT)
		-- honey coating the lower half of the dipper + long drips
		B:block(crop, v(2.8, 0.55, 2.8), cf(PX, DY + 0.95, PZ, 0, 30, 0), HONEY)
		B:block(crop, v(2.6, 0.5, 2.6), cf(PX, DY + 0.95, PZ, 0, 75, 0), HONEY_LT)
		B:block(crop, v(2.0, 0.5, 2.0), cf(PX, DY + 0.35, PZ, 0, 52, 0), HONEY_DK)
		for _, d in { { 200, 1.2, 2.0 }, { 320, 1.15, 1.3 }, { 80, 1.15, 0.9 }, { 140, 1.25, 0.6 } } do
			local p = v(PX, DY + 0.9, PZ) + dirOf(d[1]) * d[2]
			B:block(crop, v(0.5, d[3], 0.5), CFrame.new(p - v(0, d[3] / 2, 0)) * ang(0, d[1], 0), HONEY)
			B:block(crop, v(0.62, 0.5, 0.62), CFrame.new(p - v(0, d[3] + 0.05, 0)) * ang(0, d[1] + 45, 0), HONEY_LT)
		end
		-- side pegs (lashed to the stake) that carry the hanging pumpkins
		local pegR0, pegR1 = v(PX + 0.4, TOP + 6.2, PZ - 0.2), v(PX + 4.3, TOP + 7.0, PZ - 1.0)
		local pegL0, pegL1 = v(PX - 0.4, TOP + 8.4, PZ + 0.1), v(PX - 4.0, TOP + 9.2, PZ + 1.0)
		B:bar(crop, pegR0, pegR1, 0.45, 0.45, WOOD_DK)
		B:bar(crop, pegL0, pegL1, 0.42, 0.42, WOOD_DK)

		---------------------------------------------------------------- vine
		local vinePts = {}
		local N = 11
		for k = 0, N do
			local t = k / N
			local a = 160 + t * 560
			local r = 1.05 - 0.2 * t
			vinePts[k] = v(PX, 0, PZ) + dirOf(a) * r + v(0, TOP + 0.1 + t * (STAKE_TOP - TOP - 0.6), 0)
		end
		B:block(crop, v(1.2, 0.5, 1.2), CFrame.new(vinePts[0] + v(0, 0.05, 0)) * ang(0, 25, 0), VINE_DK)
		for k = 0, N - 1 do
			local a, b = vinePts[k], vinePts[k + 1]
			local dd = (b - a).Unit
			B:bar(crop, a - dd * 0.15, b + dd * 0.15, 0.5, 0.5, (k % 2 == 0) and VINE or VINE_DK)
		end
		local function leaf(p, s, col, bn)
			B:block(bn or crop, v(s, s * 0.55, s), CFrame.new(p) * ang(rnd(-25, 25), rnd(0, 90), rnd(-25, 25)), col)
		end
		for j, k in { 1, 3, 4, 6, 8, 10, 11 } do
			local p = vinePts[k]
			local out = v(p.X - PX, 0, p.Z - PZ)
			out = out.Magnitude > 0.01 and out.Unit or v(0, 0, -1)
			local s = 2.1 - 0.05 * k
			leaf(p + out * (0.4 + s * 0.35), s, LEAF[(j % 4) + 1])
		end
		-- vine along each peg, dropping to a hanging pumpkin
		local hang = {}
		for side, pg in { R = { pegR0, pegR1, 1 }, L = { pegL0, pegL1, -1 } } do
			local a, b, sx = pg[1], pg[2], pg[3]
			B:bar(crop, a + v(0, 0.35, 0), b + v(0, 0.35, 0), 0.34, 0.34, VINE)
			leaf((a + b) / 2 + v(0, 0.75, 0.1), 1.5, LEAF[sx > 0 and 2 or 4])
			local d1 = b + v(sx * 0.15, -1.0, 0)
			B:bar(crop, b + v(0, 0.4, 0), d1, 0.3, 0.3, VINE_DK)
			hang[side] = d1
			-- curly tendril
			local c1 = (a + b) / 2 + v(0, -0.2, -0.3)
			local c2 = c1 + v(0, -0.85, -0.35)
			local c3 = c2 + v(sx * 0.45, -0.15, 0)
			B:bar(crop, c1, c2, 0.15, 0.15, VINE)
			B:bar(crop, c2, c3, 0.15, 0.15, LEAF[3])
		end

		-- pumpkin flowers (golden stars with an orange throat)
		local function flower(p, s, yaw)
			B:block(crop, v(1.2 * s, 0.22, 0.45 * s), CFrame.new(p) * ang(0, yaw, 0), FLOWER)
			B:block(crop, v(0.45 * s, 0.22, 1.2 * s), CFrame.new(p) * ang(0, yaw, 0), FLOWER)
			B:block(crop, v(0.85 * s, 0.2, 0.85 * s), CFrame.new(p) * ang(0, yaw + 45, 0), FLOWER)
			B:block(crop, v(0.4 * s, 0.4, 0.4 * s), CFrame.new(p + v(0, 0.12, 0)) * ang(0, yaw, 0), FLOWER_C)
		end
		do
			local function outAt(k, d)
				local p = vinePts[k]
				local o = v(p.X - PX, 0, p.Z - PZ)
				return p + (o.Magnitude > 0.01 and o.Unit or v(0, 0, -1)) * (d or 1.5)
			end
			flower(outAt(2) + v(0, 0.9, 0), 1.0, 15)
			flower(outAt(5) + v(0, 0.8, 0), 0.95, 40)
			flower(outAt(9) + v(0, 0.7, 0), 0.9, 70)
			flower(v(3.4, 1.15 + 0.85, 4.4), 0.8, 20)
		end

		---------------------------------------------------------------- pumpkins
		-- hanging from the pegs
		pumpkin(crop, hang.R - v(0, 1.65 * 1.05 + 0.05, 0), 1.05, -20, { cells = 2, noStem = true, pollen = true })
		pumpkin(crop, hang.L - v(0, 1.65 * 0.95 + 0.05, 0), 0.95, 25, { cells = 1, noStem = true })
		-- big pumpkin resting on the grass at the front
		do
			local s = 1.3
			pumpkin(crop, v(1.9, TOP - 0.15 + 1.55 * s, -2.9), s, 20, { cells = 2, pollen = true })
			pumpkin(crop, v(-2.7, TOP - 0.15 + 1.55 * 1.0, 1.9), 1.0, -35, { cells = 2, pollen = true })
			pumpkin(crop, v(4.5, 1.15 - 0.1 + 1.55 * 0.7, 1.4), 0.7, 50, { cells = 1 })
			-- ground runners joining the resting pumpkins to the vine root
			B:bar(crop, vinePts[0] + v(0.3, 0, -0.3), v(1.2, TOP + 0.25, -1.6), 0.36, 0.36, VINE_DK)
			leaf(v(-0.6, TOP + 0.5, -1.2), 1.4, LEAF[1])
			B:bar(crop, vinePts[0] + v(-0.3, 0, 0.3), v(-1.9, TOP + 0.25, 1.2), 0.34, 0.34, VINE_DK)
			B:bar(crop, vinePts[0] + v(0.3, 0, 0.3), v(3.6, 2.1, 1.3), 0.32, 0.32, VINE_DK)
			leaf(v(2.6, TOP + 0.4, 1.9), 1.3, LEAF[2])
		end
	end,
}
