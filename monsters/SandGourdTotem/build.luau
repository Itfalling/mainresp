--!nocheck
-- Gourd Totem Vine (Sandy Savanna crop #4, Epic).
-- A tall carved sandstone totem pillar rises from a stepped golden sand mound:
-- a stepped plinth, three carved drums with painted teal / terracotta bands
-- and diamond inlays, a pair of stepped "wings", a sun emblem (tiny neon
-- core) and a horned crown capital. A thick calabash vine spirals up the
-- pillar with big leaf cubes and white gourd flowers. Painted bottle gourds
-- (orange, teal and cream with contrasting bands and diamonds) hang from the
-- wing tips and vine shoots; one sits on the crown and two rest on the sand.
-- Base: stepped sand tiers, sandstone rocks, dry grass tufts, pebbles, cactus
-- sprouts and shells. Static prop: no motion.luau. Blocks only.
return {
	DisplayName = "Gourd Totem Vine",
	Rarity = "Epic",
	Element = "Nature",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Sandy Savanna)
		local SAND_LT, SAND, SAND_DK, SAND_DK2 = "#e8c27a", "#d9a95c", "#c48a45", "#b77d3c"
		local ROCK, ROCK_LT, ROCK_DK = "#c97b4a", "#dba26a", "#a5603a"
		local PEB, PEB_DK = "#a39486", "#7f7366"
		local DRY, DRY_LT, DRY_DK = "#d4bd55", "#e8d77c", "#b09a3a"
		local CACT, CACT_DK, PINK = "#64a446", "#4a8436", "#ff7fb0"
		local SHELL, SHELL_PK = "#fff1df", "#f6b9a8"
		local STONE, STONE_LT, STONE_DK, CARVE = "#dd9f62", "#ecbd84", "#bf7a44", "#8e5530"
		local TERRA, TERRA_DK = "#c9482c", "#9c3420"
		local TEAL, TEAL_DK, TEAL_LT = "#21a89d", "#147a73", "#5fd6c8"
		local CREAM = "#f7e6c4"
		local SUN, SUN_GOLD, SUN_CORE = "#f28a1d", "#ffc93a", "#fff2a0"
		local VINE, VINE_DK = "#5a9a30", "#407a24"
		local LEAF = { "#4f8f2a", "#66a834", "#80c044", "#3f7a22" }
		local FLOWER, FLOWER_C = "#fffaf0", "#ffd23a"
		local STEM = "#6b5a2c"
		-- gourd paint schemes: body, body dark, body light, band, diamond, diamond core
		local G_ORANGE = { "#f08a2a", "#d06a1c", "#ffaa4e", TEAL, TEAL_DK, CREAM }
		local G_TEAL = { "#26aa9e", "#17807a", "#52c9bb", SUN, TERRA, CREAM }
		local G_CREAM = { "#f2d49a", "#d9b273", "#fbe6bb", TERRA, TEAL, SUN_GOLD }

		local seed = 4404
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

		---------------------------------------------------------------- sand mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.6, 2.4), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.85, 6.6, SAND_DK, 15, { SAND_DK, SAND_DK2, SAND_DK }, 0.35)
		tier(0.85, 0.7, 4.7, SAND, 11, { SAND, SAND_LT, SAND }, 0.3)
		tier(1.55, 0.55, 3.0, SAND_LT, 0, {}, 0)
		local TOP = 2.1

		-- wind ripples
		for _, r in { { 40, 5.7, 0.87, 2.2 }, { 160, 5.8, 0.87, 1.9 }, { 290, 3.8, 1.57, 1.6 } } do
			local a = rad(r[1])
			local c = CFrame.new(math.sin(a) * r[2], r[3], -math.cos(a) * r[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(r[4], 0.12, 0.35), c, SAND_LT, S)
		end
		-- sandstone rocks (one little stacked cairn)
		for _, s in { { 5.4, 0.85, -1.0, 1.1, 25, ROCK }, { 5.2, 0.62, 0.4, 0.7, 10, ROCK_LT }, { -5.0, 0.8, -2.8, 0.95, -20, ROCK_DK }, { -3.9, 1.6, 2.0, 0.75, 40, ROCK }, { 1.6, 0.75, 5.8, 0.85, 60, ROCK_LT } } do
			B:block(soil, v(s[4] * 1.3, s[4], s[4]), cf(s[1], s[2], s[3], rnd(-8, 8), s[5], rnd(-8, 8)), s[6], S)
		end
		B:block(soil, v(0.8, 0.45, 0.7), cf(5.4, 1.6, -1.0, 0, 50, 4), ROCK_LT, S)
		B:block(soil, v(0.5, 0.35, 0.45), cf(5.35, 2.0, -1.0, 0, 15, 0), ROCK_DK, S)
		-- pebbles
		for _, p in { { -2.4, 1.55, -3.6 }, { 6.0, 0.85, 2.0 }, { 3.4, 1.55, 3.0 }, { -1.0, 0.85, -6.0 } } do
			B:block(soil, v(0.45, 0.3, 0.4), cf(p[1], p[2] + 0.12, p[3], 0, rnd(0, 90), 0), pick({ PEB, PEB_DK }), S)
		end
		-- dry grass tufts
		local function tuft(x, y, z, s)
			for _, b in { { 0, 1.35, DRY }, { 0.4, 1.05, DRY_LT }, { -0.4, 1.0, DRY_DK } } do
				local base = v(x + b[1] * 0.3, y, z)
				B:bar(soil, base, base + v(b[1] * s, b[2] * s, rnd(-0.2, 0.2)), 0.3, 0.3, b[3], S)
			end
		end
		tuft(6.0, 0.85, -2.9, 1.1)
		tuft(-2.6, 0.85, -5.8, 1.0)
		tuft(-6.1, 0.85, 0.6, 1.1)
		tuft(3.0, 0.85, 5.6, 1.0)
		tuft(3.6, 1.55, -2.6, 0.8)
		-- cactus sprouts with a pink bud
		local function sprout(x, y, z, s)
			B:block(soil, v(0.5 * s, 1.2 * s, 0.5 * s), cf(x, y + 0.6 * s, z), CACT, S)
			B:block(soil, v(0.55 * s, 0.25 * s, 0.25 * s), cf(x + 0.4 * s, y + 0.55 * s, z), CACT_DK, S)
			B:block(soil, v(0.25 * s, 0.5 * s, 0.25 * s), cf(x + 0.58 * s, y + 0.8 * s, z), CACT, S)
			B:block(soil, v(0.3 * s, 0.22 * s, 0.3 * s), cf(x, y + 1.3 * s, z, 0, 45, 0), PINK, S)
		end
		sprout(4.5, 0.85, 3.9, 1.0)
		sprout(-5.3, 0.85, 2.6, 0.8)
		sprout(-3.0, 1.55, -2.4, 0.7)
		-- shells
		for _, sh in { { 1.9, 2.1, 2.2, 30 }, { -4.1, 1.55, -1.0, -20 }, { 4.7, 0.85, -4.0, 70 } } do
			B:block(soil, v(0.55, 0.22, 0.45), cf(sh[1], sh[2] + 0.1, sh[3], 0, sh[4], 0), SHELL, S)
			B:block(soil, v(0.12, 0.24, 0.42), cf(sh[1], sh[2] + 0.11, sh[3], 0, sh[4], 0), SHELL_PK, S)
		end

		---------------------------------------------------------------- gourd helper
		-- Painted calabash bottle gourd. `c` = centre of the big lower bulb.
		-- Returns the point at the top of the neck.
		local function gourd(bn, c, s, yaw, pal, opt)
			opt = opt or {}
			local o = opt.name and { name = opt.name } or nil
			local F = CFrame.new(c) * CFrame.Angles(0, rad(yaw or 0), 0) * (opt.tilt or CFrame.new())
			local function at(x, y, z, ry, rz)
				return F * CFrame.new(x * s, y * s, z * s) * CFrame.Angles(0, rad(ry or 0), rad(rz or 0))
			end
			local BODY, BDK, BLT, BAND, DIA, DCORE = pal[1], pal[2], pal[3], pal[4], pal[5], pal[6]
			-- lower bulb (stepped octagon) + caps
			B:block(bn, v(2.5 * s, 1.4 * s, 1.6 * s), at(0, 0, 0), BODY, o)
			B:block(bn, v(1.6 * s, 1.38 * s, 2.5 * s), at(0, 0, 0), BODY, o)
			B:block(bn, v(2.2 * s, 1.36 * s, 2.2 * s), at(0, 0, 0), BDK, o)
			B:block(bn, v(1.7 * s, 0.45 * s, 1.7 * s), at(0, -0.85, 0), BDK, o)
			B:block(bn, v(1.8 * s, 0.45 * s, 1.8 * s), at(0, 0.85, 0), BLT, o)
			-- painted equator band
			B:block(bn, v(2.56 * s, 0.36 * s, 1.66 * s), at(0, 0, 0), BAND, o)
			B:block(bn, v(1.66 * s, 0.35 * s, 2.56 * s), at(0, 0, 0), BAND, o)
			-- painted diamonds on the 4 faces, above the band
			for i = 0, 3 do
				local f = at(0, 0.45, 0, i * 90) * CFrame.new(0, 0, -1.25 * s - 0.04) * CFrame.Angles(0, 0, rad(45))
				B:block(bn, v(0.5 * s, 0.5 * s, 0.1), f, DIA, o)
			end
			if opt.rich then
				for i = 0, 3 do
					local f = at(0, -0.45, 0, i * 90 + 45) * CFrame.new(0, 0, -1.1 * s - 0.1)
					B:block(bn, v(0.3 * s, 0.3 * s, 0.12), f, DCORE, o)
				end
			end
			-- waist, upper bulb (octagon), top band, neck
			B:block(bn, v(0.9 * s, 0.5 * s, 0.9 * s), at(0, 1.25, 0), BODY, o)
			B:block(bn, v(1.4 * s, 0.9 * s, 1.4 * s), at(0, 1.85, 0), BODY, o)
			B:block(bn, v(1.3 * s, 0.88 * s, 1.3 * s), at(0, 1.85, 0, 45), BLT, o)
			B:block(bn, v(1.46 * s, 0.22 * s, 1.46 * s), at(0, 2.05, 0), BAND, o)
			B:block(bn, v(0.55 * s, 0.6 * s, 0.55 * s), at(0, 2.55, 0), BDK, o)
			local top = at(0, 2.85, 0).Position
			if opt.glint then
				B:block(bn, v(0.2 * s, 0.45 * s, 0.1), at(-0.75, -0.35, 0) * CFrame.new(0, 0, -1.25 * s - 0.05), SUN_CORE, { mat = "Neon", name = opt.name })
			end
			return top
		end

		---------------------------------------------------------------- totem pillar
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		local PZ = 0.3
		local function P3(x, y, z)
			return v(x, y, PZ + z)
		end
		local function C(x, y, z, rx, ry, rz)
			return cf(x, y, PZ + z, rx or 0, ry or 0, rz or 0)
		end
		-- plinth
		B:block(crop, v(4.4, 1.0, 4.4), C(0, TOP + 0.3, 0), STONE_DK)
		B:block(crop, v(3.7, 0.6, 3.7), C(0, TOP + 1.1, 0, 0, 4, 0), STONE)
		for i = 0, 3 do
			local a = rad(45 + i * 90)
			B:block(crop, v(0.6, 0.6, 0.6), C(math.sin(a) * 2.75, TOP + 0.95, -math.cos(a) * 2.75, 0, 45, 0), TEAL)
		end
		-- drum 1: teal + terracotta bands, carved diamond inlays
		local D1a, D1b = TOP + 1.4, 7.0
		B:block(crop, v(3.0, D1b - D1a, 3.0), C(0, (D1a + D1b) / 2, 0), STONE)
		B:block(crop, v(3.1, 0.4, 3.1), C(0, D1a + 0.5, 0), TEAL)
		B:block(crop, v(3.1, 0.25, 3.1), C(0, D1b - 0.45, 0), TERRA)
		for i = 0, 3 do
			local F = CFrame.new(P3(0, (D1a + D1b) / 2 + 0.2, 0)) * CFrame.Angles(0, rad(i * 90), 0) * CFrame.new(0, 0, -1.52)
			B:block(crop, v(1.4, 1.4, 0.12), F * CFrame.Angles(0, 0, rad(45)), CARVE)
			B:block(crop, v(0.85, 0.85, 0.16), F * CFrame.new(0, 0, -0.03) * CFrame.Angles(0, 0, rad(45)), TERRA)
			B:block(crop, v(0.38, 0.38, 0.2), F * CFrame.new(0, 0, -0.05) * CFrame.Angles(0, 0, rad(45)), TEAL_LT)
		end
		B:block(crop, v(3.5, 0.45, 3.5), C(0, D1b + 0.2, 0, 0, -3, 0), STONE_LT)
		-- drum 2: carved notch rows + the stepped wings
		local D2a, D2b = D1b + 0.4, 10.6
		B:block(crop, v(2.7, D2b - D2a, 2.7), C(0, (D2a + D2b) / 2, 0), STONE_LT)
		for _, y in { D2a + 0.55, D2a + 1.15 } do
			B:block(crop, v(2.76, 0.22, 1.5), C(0, y, 0), CARVE)
			B:block(crop, v(1.5, 0.22, 2.76), C(0, y, 0), CARVE)
		end
		B:block(crop, v(2.78, 0.3, 2.78), C(0, D2b - 0.4, 0), TEAL)
		local wingTips = {}
		for _, sx in { -1, 1 } do
			local y = D2a + 2.0
			B:block(crop, v(1.9, 1.0, 1.4), C(sx * 2.1, y, 0, 0, 0, sx * 8), STONE)
			B:block(crop, v(1.5, 0.8, 1.2), C(sx * 3.4, y + 0.45, 0, 0, 0, sx * 16), STONE_LT)
			B:block(crop, v(0.7, 1.5, 1.1), C(sx * 4.25, y + 1.05, 0, 0, 0, sx * 10), TERRA)
			B:block(crop, v(0.72, 0.4, 1.14), C(sx * 4.3, y + 1.65, 0, 0, 0, sx * 10), TEAL)
			B:block(crop, v(1.7, 0.14, 0.5), C(sx * 2.15, y + 0.62, 0, 0, 0, sx * 8), TERRA)
			B:block(crop, v(1.3, 0.14, 0.45), C(sx * 3.35, y + 0.95, 0, 0, 0, sx * 16), TEAL)
			B:block(crop, v(0.35, 0.35, 0.12), C(sx * 3.4, y + 0.45, -0.66, 0, 0, 45), TEAL_LT, { mat = "Neon", name = "WingGem" })
			wingTips[sx] = P3(sx * 3.65, y + 0.1, 0)
		end
		B:block(crop, v(3.1, 0.45, 3.1), C(0, D2b + 0.2, 0, 0, 5, 0), STONE)
		-- drum 3: sun emblem front (neon core) and back
		local D3a, D3b = D2b + 0.4, 13.6
		B:block(crop, v(2.5, D3b - D3a, 2.5), C(0, (D3a + D3b) / 2, 0), STONE)
		local SUNY = (D3a + D3b) / 2
		for _, side in { -1, 1 } do
			local F = CFrame.new(P3(0, SUNY, side * 1.27)) * CFrame.Angles(0, side < 0 and 0 or math.pi, 0)
			B:block(crop, v(2.1, 0.32, 0.12), F, SUN)
			B:block(crop, v(0.32, 2.1, 0.12), F, SUN)
			B:block(crop, v(1.3, 1.3, 0.16), F * CFrame.new(0, 0, -0.03) * CFrame.Angles(0, 0, rad(45)), SUN_GOLD)
			B:block(crop, v(0.82, 0.82, 0.2), F * CFrame.new(0, 0, -0.06), SUN)
			B:block(crop, v(0.42, 0.42, 0.18), F * CFrame.new(0, 0, -0.14) * CFrame.Angles(0, 0, rad(45)), side < 0 and SUN_CORE or TEAL, side < 0 and { mat = "Neon", name = "SunCore" } or nil)
		end
		for _, sx in { -1, 1 } do
			B:block(crop, v(0.12, 0.75, 0.75), C(sx * 1.27, SUNY, 0, 45, 0, 0), TEAL)
		end
		-- horned crown capital
		B:block(crop, v(3.3, 0.6, 3.3), C(0, D3b + 0.3, 0), STONE_LT)
		B:block(crop, v(3.4, 0.2, 3.4), C(0, D3b + 0.1, 0), TERRA)
		for i = 0, 3 do
			local a = rad(45 + i * 90)
			local x, z = math.sin(a) * 1.85, -math.cos(a) * 1.85
			B:block(crop, v(0.6, 1.0, 0.6), C(x, D3b + 1.05, z, 0, 45, 0), STONE)
			B:block(crop, v(0.45, 0.4, 0.45), C(x, D3b + 1.7, z, 0, 45, 0), TEAL)
		end
		B:block(crop, v(2.1, 0.5, 2.1), C(0, D3b + 0.85, 0, 0, 45, 0), STONE_DK)
		local CROWN = D3b + 1.1

		---------------------------------------------------------------- vine
		local vinePts = {}
		local N = 13
		for k = 0, N do
			local t = k / N
			local a = 205 + t * 520
			local r = 2.05 - 0.25 * t
			vinePts[k] = P3(0, 0, 0) + dirOf(a) * r + v(0, TOP + 1.5 + t * (CROWN - TOP - 1.3), 0)
		end
		B:block(crop, v(1.4, 0.6, 1.4), CFrame.new(vinePts[0] + v(0, -0.2, 0)) * ang(0, 25, 0), VINE_DK)
		for k = 0, N - 1 do
			local a, b = vinePts[k], vinePts[k + 1]
			local dd = (b - a).Unit
			B:bar(crop, a - dd * 0.15, b + dd * 0.15, 0.6, 0.6, (k % 2 == 0) and VINE or VINE_DK)
		end
		local function leaf(p, s, col)
			B:block(crop, v(s, s * 0.8, s), CFrame.new(p) * ang(rnd(-25, 25), rnd(0, 90), rnd(-25, 25)), col)
		end
		local function outOf(p)
			local o = v(p.X, 0, p.Z - PZ)
			return o.Magnitude > 0.01 and o.Unit or v(0, 0, -1)
		end
		for j, k in { 1, 3, 6, 8, 11, 13 } do
			local p = vinePts[k]
			local s = 1.95 - 0.03 * k
			leaf(p + outOf(p) * (0.3 + s * 0.35), s, LEAF[(j % 4) + 1])
		end
		-- small leaf collar round the crown gourd
		for _, l in { { -1.0, 0.45, -0.5, 1.4, 2 }, { 1.1, 0.4, 0.6, 1.4, 1 }, { 0.2, 0.35, 1.2, 1.2, 3 } } do
			leaf(P3(l[1], CROWN + l[2], l[3]), l[4], LEAF[l[5]])
		end
		-- white calabash flowers
		local function flower(p, s, yaw)
			B:block(crop, v(1.15 * s, 0.2, 0.42 * s), CFrame.new(p) * ang(0, yaw, 0), FLOWER)
			B:block(crop, v(0.42 * s, 0.2, 1.15 * s), CFrame.new(p) * ang(0, yaw, 0), FLOWER)
			B:block(crop, v(0.8 * s, 0.18, 0.8 * s), CFrame.new(p) * ang(0, yaw + 45, 0), FLOWER)
			B:block(crop, v(0.36 * s, 0.32, 0.36 * s), CFrame.new(p + v(0, 0.08, 0)) * ang(0, yaw, 0), FLOWER_C)
		end
		for _, f in { { 2, 1.0, 10 }, { 7, 0.95, 40 }, { 12, 0.9, 20 } } do
			local p = vinePts[f[1]]
			flower(p + outOf(p) * 1.45 + v(0, 0.95, 0), f[2], f[3])
		end

		---------------------------------------------------------------- gourds
		-- hanging from the wing tips
		for _, sx in { -1, 1 } do
			local tip = wingTips[sx]
			local from = vinePts[sx > 0 and 9 or 7]
			local mid = P3(sx * 2.2, tip.Y + 1.05, -0.8)
			B:bar(crop, from, mid, 0.4, 0.4, VINE)
			B:bar(crop, mid, tip + v(0, 0.25, -0.8), 0.36, 0.36, VINE_DK)
			leaf(mid + v(0, 0.7, -0.1), 1.35, LEAF[sx > 0 and 2 or 3])
			local drop = tip + v(sx * 0.1, -0.6, -0.8)
			B:bar(crop, tip + v(0, 0.3, -0.8), drop, 0.32, 0.32, VINE)
			local s = 1.2
			gourd(crop, drop - v(0, 2.85 * s - 0.1, 0), s, sx * 20, sx > 0 and G_ORANGE or G_TEAL, { rich = true, glint = true })
		end
		-- vine shoots carrying gourds (back high, front-left low)
		for _, sh in { { 10, v(0.4, 0.5, 1.9), 0.9, G_CREAM, 25 }, { 3, v(-1.9, 0.5, -1.0), 0.85, G_ORANGE, -30 } } do
			local a = vinePts[sh[1]]
			local b = a + sh[2]
			B:bar(crop, a, b, 0.42, 0.42, VINE)
			leaf(b + v(0, 0.6, 0), 1.2, LEAF[3])
			local drop = b + v(0, -0.5, 0)
			B:bar(crop, b + v(0, 0.2, 0), drop, 0.3, 0.3, VINE_DK)
			gourd(crop, drop - v(0, 2.85 * sh[3] - 0.1, 0), sh[3], sh[5], sh[4])
		end
		-- crown gourd sitting upright in the leaf collar
		do
			local s = 0.95
			local top = gourd(crop, P3(0, CROWN + 0.5 + 0.95 * s, 0), s, 15, G_TEAL, { rich = true })
			local c2 = top + v(0.5, 0.6, -0.2)
			B:bar(crop, top - v(0, 0.05, 0), c2, 0.24, 0.24, STEM)
			B:bar(crop, c2, c2 + v(0.35, -0.35, -0.3), 0.2, 0.2, LEAF[3])
		end
		-- gourds resting on the sand
		gourd(soil, v(1.7, TOP - 0.15 + 0.95 * 1.0, -3.5), 1.0, -25, G_TEAL, { name = "Soil", glint = true })
		gourd(soil, v(-3.4, 1.55 + 0.75, 2.4), 0.85, 0, G_CREAM, { name = "Soil", tilt = ang(0, 0, 80) })
		B:bar(crop, vinePts[0] + v(0.2, -0.2, -0.3), v(1.0, TOP + 0.3, -2.4), 0.36, 0.36, VINE_DK)
		leaf(v(0.0, TOP + 0.55, -2.4), 1.2, LEAF[1])

		---------------------------------------------------------------- fx
		local zone = B:block(crop, v(10, 12, 7), cf(0, 11, PZ), SUN_GOLD, { tr = 1, name = "SparkleZone" })
		B:emitter(zone, "sparkle", { name = "SunSparkle", color = { "#fff4b0", "#ffc94a", TEAL_LT }, rate = 4.5, size = { 0.15, 0.42, 0 }, life = { 1.2, 2.2 }, speed = { 0.2, 0.5 } })
		local glow = B:block(crop, v(1, 1, 1), C(0, SUNY, -1.6), SUN_GOLD, { tr = 1, name = "SunGlow" })
		B:emitter(glow, "glow", { name = "SunGlowFx", color = { SUN_CORE, SUN }, rate = 1.0, size = { 1.2, 2.0, 0.4 } })
		B:light(glow, { name = "SunLight", color = "#ffc670", brightness = 1.1, range = 12 })
		local leafZone = B:block(crop, v(6, 1, 5), cf(0, CROWN + 1.0, PZ), LEAF[2], { tr = 1, name = "LeafZone" })
		B:emitter(leafZone, "leaf", { name = "DryLeaves", color = { LEAF[3], DRY, "#e0a23a" }, rate = 0.6, size = { 0.4, 0.4, 0.25 }, life = { 3, 5 }, speed = { 0.3, 0.8 }, accel = { 0.3, -1.3, 0 } })
	end,
}
