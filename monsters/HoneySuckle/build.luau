--!nocheck
-- Honeysuckle Trellis (Honey Hills crop #4, Epic).
-- A wooden garden arbor stands on a stepped grassy meadow mound: two lattice
-- side panels joined by a stepped round arch with rafters, crowned by a
-- carved hexagon plaque with a honeycomb heart. Two honeysuckle vines spiral
-- up the panels and meet over the arch, dressed in paired leaves, whorls of
-- long two-tone trumpet flowers (rose-pink and gold, cream lips, golden
-- stamens) and clusters of glossy golden "honey berries" that hang from the
-- arch. Two cute block bees visit the flowers. Stepping stones run under the
-- arch. FX: golden/pink pollen sparkle round the canopy.
-- Base: grassy soil tiers with a grass lip, tiny pastel wildflowers, clover,
-- a honey puddle and pebbles. Static prop: no motion.luau. Blocks only.
return {
	DisplayName = "Honeysuckle Trellis",
	Rarity = "Epic",
	Element = "Nature",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Honey Hills)
		local SOIL, SOIL_DK, SOIL_LT = "#8a5a34", "#6e4426", "#a06c3e"
		local GRASS, GRASS_LT, GRASS_DK = "#a6d455", "#c0e26c", "#86bd42"
		local PEB, PEB_DK, STONE = "#d8cfc0", "#a89d8c", "#c4b8a6"
		local PINK, LAV, WHITE, BUTTER = "#ffb3d1", "#c7a6ff", "#fff8ec", "#ffe066"
		local CLOVER, CLOVER_DK = "#4fae3a", "#3d9230"
		local HONEY, HONEY_LT, HONEY_DK = "#f5a417", "#ffc845", "#d4800c"
		local WOOD, WOOD_LT, WOOD_DK = "#b98552", "#d2a36c", "#93643a"
		local VINE, VINE_DK = "#5a8f2e", "#456f22"
		local LEAF = { "#4f9e34", "#66b440", "#3f8a2c", "#7cc64c" }
		local TUBE_PK, TUBE_PK2, TUBE_GD, TUBE_GD2 = "#ff8fb8", "#f06a9c", "#ffc93d", "#f5a92a"
		local LIP_PK, LIP_GD = "#ffe0ec", "#fff4c4"
		local STAMEN = "#ffe45c"
		local BERRY, BERRY_LT, BERRY_DK = "#ffb21e", "#ffd25a", "#e58a0c"
		local SHINE = "#fff4c2"
		local BEE_Y, BEE_K, WING = "#ffcf2e", "#2a2420", "#f4fbff"
		local NEON = { mat = "Neon" }

		local seed = 1644
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
		local Y1, Y2, TOP = 1.15, 1.95, 2.4
		tier(0, Y1, 6.4, 10)
		tier(Y1, Y2 - Y1, 4.9, 7)
		tier(Y2, TOP - Y2, 2.5, 0)

		-- stepping stones running under the arch
		for i, s in { { 0.2, -2.0, 15, 1.3 }, { -0.3, -0.2, -10, 1.2 }, { 0.25, 1.6, 30, 1.1 } } do
			B:block(soil, v(s[4] * 1.2, 0.18, s[4]), cf(s[1], TOP + 0.05, s[2], 0, s[3], 0), i == 2 and PEB or STONE, S)
		end
		B:block(soil, v(1.4, 0.2, 1.1), cf(0.6, Y2 + 0.06, -3.6, 0, -20, 0), STONE, S)
		-- honey puddle (front-right)
		do
			local c = v(3.1, Y2 + 0.03, -3.0)
			B:block(soil, v(2.2, 0.14, 1.4), CFrame.new(c) * ang(0, -30, 0), HONEY, S)
			B:block(soil, v(1.4, 0.15, 2.0), CFrame.new(c + v(0.2, 0, 0.1)) * ang(0, -30, 0), HONEY, S)
			B:block(soil, v(0.9, 0.17, 0.45), CFrame.new(c + v(-0.2, 0.02, -0.2)) * ang(0, -30, 0), HONEY_LT, S)
			B:block(soil, v(0.55, 0.6, 0.25), CFrame.new(v(3.6, Y2 - 0.25, -4.2)) * ang(0, -30, 0), HONEY_DK, S)
		end
		-- pebbles
		for _, p in { { 5.6, Y1, -2.4 }, { -5.8, Y1, 1.4 }, { 1.4, Y1, 6.0 }, { -2.2, Y2, -3.8 } } do
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
		wild(5.9, Y1, 0.4, LAV)
		wild(-4.9, Y1, -3.8, PINK)
		wild(-5.6, Y1, 3.4, WHITE)
		wild(-1.8, Y1, 5.8, PINK)
		-- clover patches
		local function clover(x, y, z, yaw)
			for k = 0, 2 do
				local d = dirOf(yaw + k * 120)
				B:block(soil, v(0.55, 0.16, 0.55), CFrame.new(v(x, y + 0.1, z) + d * 0.3) * ang(0, yaw + k * 120 + 45, 0), k == 1 and CLOVER_DK or CLOVER, S)
			end
			B:block(soil, v(0.3, 0.3, 0.3), cf(x, y + 0.35, z, 0, yaw, 0), WHITE, S)
		end
		clover(4.8, Y1, 3.6, 10)
		clover(-5.2, Y1, -1.2, 50)

		---------------------------------------------------------------- the arbor
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		local CX, CZ = 3.9, 1.15      -- column x, post z offset
		local COL_TOP = 12.6
		local AR = CX                 -- arch radius (centre at x=0, y=COL_TOP)
		local AY = COL_TOP
		for _, sx in { -1, 1 } do
			local x = sx * CX
			-- stone footing
			B:block(crop, v(1.8, 0.5, 3.4), cf(x, Y2 + 0.25, 0, 0, sx * 4, 0), STONE)
			-- posts
			for _, sz in { -1, 1 } do
				B:block(crop, v(0.75, COL_TOP - Y2 + 0.2, 0.75), cf(x, (Y2 + COL_TOP) / 2 + 0.1, sz * CZ), WOOD)
				B:block(crop, v(0.12, 3.0, 0.1), cf(x + sx * 0.1, Y2 + 3.2 + (sz + 1) * 2, sz * CZ - 0.4), WOOD_DK)
			end
			-- rungs
			for _, y in { Y2 + 1.0, 7.4, COL_TOP - 0.6 } do
				B:block(crop, v(0.5, 0.5, 2 * CZ + 0.9), cf(x, y, 0), WOOD_DK)
			end
			-- diamond lattice between the posts
			local y0, y1 = Y2 + 1.0, COL_TOP - 0.6
			local step = 2 * CZ
			local y = y0
			while y + step <= y1 + 0.01 do
				B:bar(crop, v(x, y, -CZ), v(x, y + step, CZ), 0.3, 0.3, WOOD_LT)
				B:bar(crop, v(x + sx * 0.05, y, CZ), v(x + sx * 0.05, y + step, -CZ), 0.3, 0.3, WOOD_LT)
				y += step
			end
		end
		-- stepped round arch (front + back beams) and rafters
		local function arcPt(deg, r, z)
			local a = rad(deg)
			return v(math.cos(a) * r, AY + math.sin(a) * r, z)
		end
		local ARC = { 0, 28, 56, 90, 124, 152, 180 }
		for _, z in { -CZ, CZ } do
			for k = 1, #ARC - 1 do
				local a, b = arcPt(ARC[k], AR, z), arcPt(ARC[k + 1], AR, z)
				local dd = (b - a).Unit
				B:bar(crop, a - dd * 0.3, b + dd * 0.3, 0.75, 0.75, (k % 2 == 0) and WOOD_LT or WOOD)
			end
		end
		for _, deg in { 14, 50, 90, 130, 166 } do
			local p = arcPt(deg, AR + 0.5, 0)
			B:block(crop, v(0.5, 0.4, 2 * CZ + 1.8), CFrame.new(p) * CFrame.Angles(0, 0, rad(deg - 90)), WOOD_DK)
		end
		-- hexagon plaque with a honeycomb heart on the apex
		local HY = AY + AR + 1.75
		local function hex(F, r, th, col)
			for k = 0, 2 do
				B:block(crop, v(r, r * 1.732, th), F * CFrame.Angles(0, 0, rad(k * 60)), col)
			end
		end
		B:block(crop, v(0.6, 1.3, 0.6), cf(0, AY + AR + 0.55, 0), WOOD_DK)
		hex(CFrame.new(0, HY, 0), 1.5, 0.5, WOOD_DK)
		hex(CFrame.new(0, HY, -0.22), 1.12, 0.2, HONEY)
		hex(CFrame.new(0, HY, -0.3), 0.5, 0.12, HONEY_LT)

		---------------------------------------------------------------- vines + leaves
		local function leaf(p, s, col, yaw)
			B:block(crop, v(s, s * 0.6, s * 0.85), CFrame.new(p) * ang(rnd(-25, 25), yaw or rnd(0, 180), rnd(-25, 25)), col)
		end
		local function vineThrough(pts, w, leafEvery, leafS)
			local flip = 1
			for k = 1, #pts - 1 do
				local a, b = pts[k], pts[k + 1]
				local dd = (b - a).Unit
				B:bar(crop, a - dd * 0.12, b + dd * 0.12, w, w, (k % 2 == 0) and VINE or VINE_DK)
				if leafEvery and k % leafEvery == 0 then
					local side = dd:Cross(v(0, 1, 0))
					side = side.Magnitude > 0.05 and side.Unit or v(1, 0, 0)
					leaf(b + side * flip * 0.75 + v(0, 0.2, 0), leafS, LEAF[(k % 4) + 1])
					flip = -flip
				end
			end
		end
		-- each column vine winds round its panel then runs over the arch
		for _, sx in { -1, 1 } do
			local pts = {}
			local x = sx * CX
			local corners = { { -1, -1 }, { 1, -1 }, { 1, 1 }, { -1, 1 } }
			local y = Y2 + 0.2
			local ci = sx > 0 and 1 or 3
			while y < COL_TOP - 0.3 do
				local c = corners[(ci - 1) % 4 + 1]
				table.insert(pts, v(x + c[1] * 0.7, y, c[2] * (CZ + 0.45)))
				y += 1.35
				ci += 1
			end
			for _, deg in (sx > 0 and { 10, 40, 70 } or { 170, 140, 110 }) do
				table.insert(pts, arcPt(deg, AR + 0.65, -CZ - 0.2))
			end
			vineThrough(pts, 0.42, 2, 1.7)
		end
		-- back vine over the arch
		do
			local pts = {}
			for _, deg in { 0, 36, 72, 108, 144, 180 } do
				table.insert(pts, arcPt(deg, AR + 0.65, CZ + 0.2))
			end
			vineThrough(pts, 0.36, 2, 1.6)
		end
		-- lush leaf masses draped over the arch shoulders and crown
		local function mass(c, n, s, spread)
			for i = 1, n do
				local o = v(rnd(-1, 1) * spread, rnd(-0.4, 0.6) * spread * 0.7, rnd(-1, 1) * spread * 0.9)
				leaf(c + o, s * rnd(0.85, 1.15), LEAF[(i % 4) + 1])
			end
		end
		for _, deg in { 25, 155 } do
			mass(arcPt(deg, AR + 0.7, 0), 4, 1.9, 1.1)
		end
		for _, deg in { 62, 118 } do
			mass(arcPt(deg, AR + 0.9, 0), 3, 2.0, 1.0)
		end
		-- leaf collar round the plaque post
		leaf(v(-0.9, AY + AR + 0.7, 0.3), 1.6, LEAF[2], 20)
		leaf(v(0.9, AY + AR + 0.65, -0.2), 1.6, LEAF[4], 70)
		-- curly tendrils escaping the arch
		for _, t in { { 20, 1 }, { 160, -1 } } do
			local c1 = arcPt(t[1], AR + 1.3, -0.3)
			local c2 = c1 + v(t[2] * 0.8, 0.7, -0.2)
			local c3 = c2 + v(t[2] * 0.1, 0.5, 0.4)
			B:bar(crop, c1, c2, 0.16, 0.16, VINE)
			B:bar(crop, c2, c3, 0.16, 0.16, LEAF[4])
		end

		---------------------------------------------------------------- flowers
		-- a fan of long trumpets fanning out from `c` towards `dir`
		local function cluster(c, dir, n, tube, s)
			s = s or 1
			dir = dir.Unit
			local up = math.abs(dir.Y) > 0.9 and v(1, 0, 0) or v(0, 1, 0)
			local r1 = dir:Cross(up).Unit
			local r2 = r1:Cross(dir).Unit
			local tube2 = (tube == TUBE_GD) and TUBE_GD2 or TUBE_PK2
			local lip = (tube == TUBE_GD) and LIP_GD or LIP_PK
			B:block(crop, v(0.6 * s, 0.6 * s, 0.6 * s), CFrame.new(c) * ang(0, 45, 0), VINE_DK)
			for k = 0, n - 1 do
				local a = rad(k / n * 360 + 30)
				local spread = r1 * math.cos(a) + r2 * math.sin(a)
				local d = (dir + spread * 0.7).Unit
				local tip = c + d * 1.9 * s
				B:bar(crop, c + d * 0.15, tip, 0.5 * s, 0.5 * s, (k % 2 == 0) and tube or tube2)
				-- flared pale lip at the mouth
				local F = P.aim(tip - d * 0.06, tip + d * 0.2)
				B:block(crop, v(0.85 * s, 0.5 * s, 0.24), F * CFrame.Angles(0, 0, rad(k * 40)), lip)
			end
			-- golden stamens poking out of the middle
			B:bar(crop, c + dir * 0.3, c + dir * 2.1 * s, 0.14, 0.14, STAMEN)
		end
		-- crown clusters on the arch shoulders (the plaque stays clear)
		cluster(arcPt(65, AR + 1.2, -CZ - 0.5), v(0.5, 0.9, -0.7), 4, TUBE_PK, 1.1)
		cluster(arcPt(115, AR + 1.2, -CZ - 0.5), v(-0.5, 0.9, -0.7), 4, TUBE_GD, 1.1)
		cluster(arcPt(30, AR + 1.1, -CZ - 0.4), v(0.9, 0.5, -0.6), 4, TUBE_GD, 1.0)
		cluster(arcPt(150, AR + 1.1, -CZ - 0.4), v(-0.9, 0.5, -0.6), 4, TUBE_PK, 1.0)
		cluster(arcPt(90, AR + 1.0, CZ + 0.8), v(0, 0.7, 0.8), 4, TUBE_PK, 1.0)
		-- side clusters on the panels
		cluster(v(CX + 1.0, 9.4, -1.5), v(1, 0.5, -0.6), 4, TUBE_PK, 0.95)
		cluster(v(-CX - 1.0, 7.4, -1.3), v(-1, 0.5, -0.6), 4, TUBE_GD, 0.95)
		cluster(v(CX + 0.9, 5.2, 1.6), v(1, 0.4, 0.6), 3, TUBE_GD, 0.9)
		cluster(v(-CX - 0.9, 10.6, 1.5), v(-1, 0.4, 0.6), 3, TUBE_PK, 0.9)

		---------------------------------------------------------------- honey berries
		local function berry(p, s, shine)
			B:block(crop, v(0.8 * s, 0.8 * s, 0.8 * s), CFrame.new(p) * ang(0, 20, 0), BERRY)
			B:block(crop, v(0.6 * s, 0.92 * s, 0.6 * s), CFrame.new(p) * ang(0, 65, 0), shine and BERRY_LT or BERRY_DK)
			if shine then
				B:block(crop, v(0.18, 0.22, 0.12), CFrame.new(p) * ang(0, 20, 0) * CFrame.new(-0.18 * s, 0.18 * s, -0.42 * s), SHINE, NEON)
			end
		end
		local function bunch(top, s, n)
			local a = top - v(0, 0.8 * s, 0)
			B:bar(crop, top, a, 0.14, 0.14, VINE_DK)
			local offs = { v(0, -0.45, 0), v(0.55, -0.2, 0.15), v(-0.5, -0.25, -0.2), v(0.1, -1.1, -0.1), v(-0.05, 0.25, 0.5) }
			for i = 1, n do
				berry(a + offs[i] * s, s, i <= 2)
			end
		end
		-- hanging under the arch
		bunch(arcPt(40, AR - 0.45, -CZ), 1.0, 4)
		bunch(arcPt(140, AR - 0.45, -CZ), 0.95, 4)
		bunch(arcPt(90, AR - 0.45, 0), 1.1, 5)
		-- on the panels
		bunch(v(CX + 1.0, 8.0, -0.2), 0.9, 3)
		bunch(v(-CX - 1.0, 6.0, 0.4), 0.9, 3)

		---------------------------------------------------------------- bees
		local function bee(c, yaw, s)
			local F = CFrame.new(c) * CFrame.Angles(0, rad(yaw), 0) * CFrame.Angles(rad(-8), 0, 0)
			B:block(crop, v(0.95 * s, 0.85 * s, 1.25 * s), F, BEE_Y)
			B:block(crop, v(1.0 * s, 0.9 * s, 0.28 * s), F * CFrame.new(0, 0, 0.15 * s), BEE_K)
			B:block(crop, v(0.8 * s, 0.75 * s, 0.25 * s), F * CFrame.new(0, 0, 0.62 * s), BEE_K)
			B:block(crop, v(0.7 * s, 0.7 * s, 0.5 * s), F * CFrame.new(0, 0.02, -0.8 * s), BEE_K)
			B:block(crop, v(0.2 * s, 0.2 * s, 0.3 * s), F * CFrame.new(0, -0.05, 0.85 * s), BEE_K)
			for _, sx in { -1, 1 } do
				B:block(crop, v(0.75 * s, 0.1, 0.55 * s), F * CFrame.new(sx * 0.5 * s, 0.55 * s, 0.05) * CFrame.Angles(0, 0, rad(sx * 25)), WING, { tr = 0.25 })
			end
		end
		bee(v(2.6, 15.0, -3.0), 35, 1.1)
		bee(v(-CX - 2.1, 9.2, -1.6), -60, 1.0)

		---------------------------------------------------------------- fx
		local zone = B:block(crop, v(10, 6, 5), cf(0, AY + 2.2, 0), HONEY, { tr = 1, name = "PollenZone" })
		B:emitter(zone, "sparkle", { name = "PollenSparkle", color = { "#fff6b0", "#ffc94a", "#ff9fc8" }, rate = 5, size = { 0.18, 0.45, 0 }, life = { 1.4, 2.4 }, speed = { 0.2, 0.6 }, accel = { 0, 0.3, 0 } })
		local zone2 = B:block(crop, v(10, 7, 4), cf(0, 7.5, 0), HONEY, { tr = 1, name = "PollenZone2" })
		B:emitter(zone2, "sparkle", { name = "PollenSparkle2", color = { "#fff6b0", "#ffd25a" }, rate = 2.5, size = { 0.12, 0.35, 0 }, life = { 1.2, 2.0 }, speed = { 0.1, 0.4 } })
	end,
}
