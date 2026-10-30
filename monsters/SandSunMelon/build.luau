--!nocheck
-- Sun Melon Vine (Sandy Savanna crop #3, Rare).
-- A sun-bleached wooden T-post stands in a stepped golden sand mound. A leafy
-- melon vine spirals up the post, runs out along the crossbar and hangs whole
-- golden "sun melons" from the bar ends and a side peg; a crown melon sits in
-- a leaf nest on top of the post and two more melons rest on the sand.
-- Every melon is a stepped round golden fruit with orange sunburst stripes
-- running from the stem down the sides.
-- Base: stepped sand tiers, sandstone rocks, dry grass tufts, pebbles, tiny
-- cactus sprouts and shells. Static prop: no motion.luau. Blocks only.
return {
	DisplayName = "Sun Melon Vine",
	Rarity = "Rare",
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
		local WOOD, WOOD_LT, WOOD_DK, WOOD_GR = "#d6c6a2", "#e8dcbd", "#b3a07c", "#8f7d5e"
		local TWINE = "#c9944e"
		local VINE, VINE_DK = "#5a9a30", "#407a24"
		local LEAF = { "#4f8f2a", "#66a834", "#80c044", "#3f7a22" }
		local MEL, MEL_LT, MEL_DK = "#f7c63c", "#ffdc63", "#e3a52b"
		local STRIPE, STRIPE_DK = "#f27a1d", "#d85e14"
		local STEM = "#6b5a2c"
		local FLOWER, FLOWER_C = "#ffd83a", "#f28a1d"
		local SHINE = "#fff6c0"

		local seed = 3303
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
		tier(0, 0.85, 6.3, SAND_DK, 14, { SAND_DK, SAND_DK2, SAND_DK }, 0.35)
		tier(0.85, 0.7, 4.4, SAND, 10, { SAND, SAND_LT, SAND }, 0.3)
		tier(1.55, 0.55, 2.8, SAND_LT, 0, {}, 0)
		local TOP = 2.1

		-- wind ripples (thin lighter strips on the tiers)
		for _, r in { { 30, 5.4, 0.87, 2.2 }, { 150, 5.5, 0.87, 1.8 }, { 255, 5.3, 0.87, 2.0 }, { 95, 3.6, 1.57, 1.6 }, { 300, 3.5, 1.57, 1.5 } } do
			local a = rad(r[1])
			local c = CFrame.new(math.sin(a) * r[2], r[3], -math.cos(a) * r[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(r[4], 0.12, 0.35), c, SAND_LT, S)
		end
		-- sandstone rocks
		for _, s in { { -5.2, 0.85, -1.4, 1.1, 25, ROCK }, { -5.5, 0.6, -0.1, 0.7, 10, ROCK_LT }, { 4.9, 0.8, 2.6, 0.95, -20, ROCK_DK }, { 3.7, 1.6, 1.9, 0.7, 40, ROCK }, { -1.2, 0.75, 5.6, 0.8, 60, ROCK_LT } } do
			B:block(soil, v(s[4] * 1.3, s[4], s[4]), cf(s[1], s[2], s[3], rnd(-8, 8), s[5], rnd(-8, 8)), s[6], S)
		end
		B:block(soil, v(0.7, 0.35, 0.6), cf(-5.2, 1.5, -1.3, 0, 40, 6), ROCK_LT, S)
		-- pebbles
		for _, p in { { 2.0, 2.1, 1.9 }, { -2.3, 1.55, -3.4 }, { 5.6, 0.85, -1.6 }, { -4.0, 0.85, 4.3 }, { 1.0, 1.55, -3.9 } } do
			B:block(soil, v(0.45, 0.3, 0.4), cf(p[1], p[2] + 0.12, p[3], 0, rnd(0, 90), 0), pick({ PEB, PEB_DK }), S)
		end
		-- dry grass tufts (fanned blades)
		local function tuft(x, y, z, s)
			for k, b in { { 0, 1.35, DRY }, { 0.4, 1.05, DRY_LT }, { -0.4, 1.0, DRY_DK } } do
				local base = v(x + b[1] * 0.3, y, z)
				B:bar(soil, base, base + v(b[1] * s, b[2] * s, rnd(-0.2, 0.2)), 0.3, 0.3, b[3], S)
			end
		end
		tuft(5.7, 0.85, -2.6, 1.1)
		tuft(-3.0, 0.85, -5.3, 1.0)
		tuft(-5.8, 0.85, 1.9, 1.1)
		tuft(2.4, 0.85, 5.4, 1.0)
		tuft(-3.2, 1.55, 2.2, 0.8)
		-- tiny cactus sprouts with a pink bud
		local function sprout(x, y, z, s)
			B:block(soil, v(0.5 * s, 1.2 * s, 0.5 * s), cf(x, y + 0.6 * s, z), CACT, S)
			B:block(soil, v(0.55 * s, 0.25 * s, 0.25 * s), cf(x + 0.4 * s, y + 0.55 * s, z), CACT_DK, S)
			B:block(soil, v(0.25 * s, 0.5 * s, 0.25 * s), cf(x + 0.58 * s, y + 0.8 * s, z), CACT, S)
			B:block(soil, v(0.3 * s, 0.22 * s, 0.3 * s), cf(x, y + 1.3 * s, z, 0, 45, 0), PINK, S)
		end
		sprout(-4.3, 0.85, -3.6, 1.0)
		sprout(4.2, 0.85, 4.0, 0.8)
		-- little shells
		for _, sh in { { -1.9, 2.1, 1.6, 30 }, { 4.0, 1.55, -2.6, -20 }, { -4.6, 0.85, 3.2, 70 } } do
			B:block(soil, v(0.55, 0.22, 0.45), cf(sh[1], sh[2] + 0.1, sh[3], 0, sh[4], 0), SHELL, S)
			B:block(soil, v(0.12, 0.24, 0.42), cf(sh[1], sh[2] + 0.11, sh[3], 0, sh[4], 0), SHELL_PK, S)
		end

		---------------------------------------------------------------- melon helper
		-- `c` = centre of the body, s = scale, yaw in degrees, parent bone `bn`.
		-- Returns the top point (where the stem leaves the melon).
		local function melon(bn, c, s, yaw, opt)
			opt = opt or {}
			local o = opt.name and { name = opt.name } or nil
			local F = CFrame.new(c) * CFrame.Angles(0, rad(yaw or 0), 0) * (opt.tilt or CFrame.new())
			local function at(x, y, z, ry)
				return F * CFrame.new(x * s, y * s, z * s) * CFrame.Angles(0, rad(ry or 0), 0)
			end
			-- stepped round body, 3 bands (crossed gold slabs; the orange filler
			-- shows at the octagon corners as sunburst stripes)
			B:block(bn, v(3.0 * s, 1.5 * s, 2.0 * s), at(0, 0, 0), MEL, o)
			B:block(bn, v(2.0 * s, 1.48 * s, 3.0 * s), at(0, 0, 0), MEL, o)
			B:block(bn, v(2.65 * s, 1.46 * s, 2.65 * s), at(0, 0, 0), STRIPE, o)
			for _, b in { { 1.0, MEL_LT }, { -1.0, MEL_DK } } do
				B:block(bn, v(2.4 * s, 0.62 * s, 1.5 * s), at(0, b[1], 0), b[2], o)
				B:block(bn, v(1.5 * s, 0.6 * s, 2.4 * s), at(0, b[1], 0), b[2], o)
				B:block(bn, v(2.1 * s, 0.58 * s, 2.1 * s), at(0, b[1], 0), STRIPE_DK, o)
			end
			B:block(bn, v(1.5 * s, 0.4 * s, 1.5 * s), at(0, 1.45, 0), MEL_LT, o)
			B:block(bn, v(1.3 * s, 0.34 * s, 1.3 * s), at(0, -1.42, 0), MEL_DK, o)
			-- sunburst stripes down the 4 main faces + rays across the top
			for i = 0, 3 do
				local f = at(0, 0, 0, i * 90) * CFrame.new(0, 0, -1.5 * s - 0.03)
				B:block(bn, v(0.42 * s, 1.3 * s, 0.12), f, STRIPE, o)
			end
			B:block(bn, v(1.56 * s, 0.14, 0.34 * s), at(0, 1.65, 0) * CFrame.new(0, 0.07, 0), STRIPE, o)
			B:block(bn, v(0.34 * s, 0.14, 1.56 * s), at(0, 1.65, 0) * CFrame.new(0, 0.07, 0), STRIPE, o)
			-- sun "eye" round the stem
			B:block(bn, v(0.7 * s, 0.14, 0.7 * s), at(0, 1.65, 0, 45) * CFrame.new(0, 0.16, 0), STRIPE_DK, o)
			-- glossy shine
			if opt.shine then
				B:block(bn, v(0.3 * s, 0.55 * s, 0.1), at(-0.75, 0.25, -1.5) * CFrame.new(0, 0, -0.05), SHINE, { mat = "Neon", name = opt.name })
			end
			local top = (at(0, 1.65, 0)).Position
			if not opt.noStem then
				B:bar(bn, top - v(0, 0.2, 0), top + v(0.15, 0.55, 0.1) * s, 0.3 * s, 0.3 * s, STEM, o)
			end
			return top
		end

		---------------------------------------------------------------- the post
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		local PX, PZ = 0, 0.6
		local POST_TOP = 10.9
		local BAR_Y = 9.4
		local BAR_X = 4.1
		-- the crossbar is turned so its ends reach back-right and front-left
		local BARF = CFrame.new(PX, 0, PZ) * CFrame.Angles(0, rad(-32), 0) * CFrame.new(-PX, 0, -PZ)
		-- foot stones wedged round the post
		B:block(crop, v(1.0, 0.6, 0.9), cf(PX - 1.0, TOP + 0.2, PZ - 0.4, 0, 20, 8), ROCK)
		B:block(crop, v(0.9, 0.55, 0.8), cf(PX + 0.95, TOP + 0.18, PZ + 0.5, 0, -30, -6), ROCK_LT)
		-- post: two stacked weathered lengths, slightly crooked
		B:block(crop, v(1.5, 6.0, 1.5), cf(PX, TOP + 2.8, PZ, 0, 3, 0), WOOD)
		B:block(crop, v(1.4, POST_TOP - (TOP + 5.6), 1.4), cf(PX, (TOP + 5.6 + POST_TOP) / 2, PZ, 0, -2, 0.8), WOOD_LT)
		-- grain strips / cracks on the faces
		B:block(crop, v(0.18, 3.4, 0.1), cf(PX - 0.35, TOP + 2.4, PZ - 0.8), WOOD_GR)
		B:block(crop, v(0.14, 2.2, 0.1), cf(PX + 0.3, TOP + 6.9, PZ - 0.75), WOOD_DK)
		B:block(crop, v(0.1, 2.6, 0.18), cf(PX + 0.8, TOP + 3.9, PZ + 0.2), WOOD_GR)
		B:block(crop, v(0.1, 1.8, 0.16), cf(PX - 0.75, TOP + 8.4, PZ - 0.1), WOOD_DK)
		-- weathered knot
		B:block(crop, v(0.45, 0.45, 0.12), cf(PX + 0.25, TOP + 4.6, PZ - 0.8), WOOD_GR)
		-- crossbar + end caps
		B:block(crop, v(2 * BAR_X + 1.0, 0.9, 0.95), BARF * cf(PX, BAR_Y, PZ - 0.05, 0, 0, -1.2), WOOD)
		B:block(crop, v(2 * BAR_X - 1.5, 0.12, 0.2), BARF * cf(PX, BAR_Y - 0.1, PZ - 0.55, 0, 0, -1.2), WOOD_GR)
		-- braces
		for _, sx in { -1, 1 } do
			B:bar(crop, BARF * v(PX + sx * 0.5, BAR_Y - 2.4, PZ), BARF * v(PX + sx * 2.5, BAR_Y - 0.35, PZ), 0.55, 0.55, WOOD_DK)
		end
		-- twine lashing at the cross
		B:block(crop, v(1.65, 0.45, 1.65), cf(PX, BAR_Y + 0.15, PZ, 0, 12, 0), TWINE)
		B:block(crop, v(1.6, 0.35, 1.6), cf(PX, BAR_Y - 0.55, PZ, 0, -10, 0), TWINE)
		-- post cap board
		B:block(crop, v(1.9, 0.3, 1.9), cf(PX, POST_TOP + 0.15, PZ, 0, 8, 0), WOOD_DK)
		-- side peg (carries a melon)
		local pegA, pegB = v(PX + 0.6, TOP + 5.0, PZ - 0.2), v(PX + 2.7, TOP + 5.6, PZ - 0.5)
		B:bar(crop, pegA, pegB, 0.45, 0.45, WOOD_DK)

		---------------------------------------------------------------- vine
		local vinePts = {}
		local N = 12
		for k = 0, N do
			local t = k / N
			local a = 200 + t * 520
			local r = 1.3 - 0.2 * t
			vinePts[k] = v(PX, 0, PZ) + dirOf(a) * r + v(0, TOP + 0.1 + t * (POST_TOP - TOP - 0.2), 0)
		end
		B:block(crop, v(1.3, 0.55, 1.3), CFrame.new(vinePts[0] + v(0, 0.05, 0)) * ang(0, 25, 0), VINE_DK)
		for k = 0, N - 1 do
			local a, b = vinePts[k], vinePts[k + 1]
			local dd = (b - a).Unit
			B:bar(crop, a - dd * 0.15, b + dd * 0.15, 0.55, 0.55, (k % 2 == 0) and VINE or VINE_DK)
		end
		local function leaf(p, s, col, bn)
			B:block(bn or crop, v(s, s * 0.8, s), CFrame.new(p) * ang(rnd(-25, 25), rnd(0, 90), rnd(-25, 25)), col)
		end
		local leafAt = { 1, 2, 5, 7, 8, 11, 12 }
		for j, k in leafAt do
			local p = vinePts[k]
			local out = v(p.X - PX, 0, p.Z - PZ)
			out = out.Magnitude > 0.01 and out.Unit or v(0, 0, -1)
			local s = 2.15 - 0.04 * k
			leaf(p + out * (0.35 + s * 0.35), s, LEAF[(j % 4) + 1])
		end
		-- vines out along the crossbar, drooping to the hanging melons
		local hang = {}
		for _, sx in { -1, 1 } do
			local a = BARF * v(PX + sx * 0.6, BAR_Y + 0.55, PZ - 0.2)
			local m = BARF * v(PX + sx * 2.2, BAR_Y + 0.65, PZ - 0.35)
			local b = BARF * v(PX + sx * (BAR_X - 0.4), BAR_Y + 0.5, PZ - 0.3)
			B:bar(crop, a, m, 0.4, 0.4, VINE)
			B:bar(crop, m, b, 0.38, 0.38, VINE_DK)
			leaf(m + v(0, 0.75, 0.2), 1.7, LEAF[sx > 0 and 2 or 3])
			leaf(b + v(sx * 0.6, 0.55, 0.3), 1.5, LEAF[sx > 0 and 3 or 1])
			-- drop stem round the bar end
			local d0 = BARF * v(PX + sx * BAR_X, BAR_Y + 0.5, PZ - 0.5)
			local d1 = BARF * v(PX + sx * (BAR_X + 0.15), BAR_Y - 1.4, PZ - 0.6)
			B:bar(crop, b, d0, 0.36, 0.36, VINE)
			B:bar(crop, d0, d1, 0.32, 0.32, VINE_DK)
			hang[sx] = d1
			-- curly tendril off the bar
			local c1 = m + v(-sx * 0.3, 0.2, -0.45)
			local c2 = c1 + v(0, -0.9, -0.3)
			local c3 = c2 + v(sx * 0.5, -0.2, 0)
			B:bar(crop, c1, c2, 0.16, 0.16, VINE)
			B:bar(crop, c2, c3, 0.16, 0.16, LEAF[3])
		end
		-- vine along the peg
		B:bar(crop, vinePts[4] + v(0.2, 0.2, 0), pegB + v(0, 0.35, 0), 0.32, 0.32, VINE)
		leaf(pegB + v(0.2, 0.9, 0.2), 1.3, LEAF[3])
		local pegDrop = pegB + v(0.2, -0.9, -0.1)
		B:bar(crop, pegB + v(0, 0.2, 0), pegDrop, 0.3, 0.3, VINE_DK)

		-- melon flowers
		local function flower(p, s, yaw)
			B:block(crop, v(1.15 * s, 0.2, 0.42 * s), CFrame.new(p) * ang(0, yaw, 0), FLOWER)
			B:block(crop, v(0.42 * s, 0.2, 1.15 * s), CFrame.new(p) * ang(0, yaw, 0), FLOWER)
			B:block(crop, v(0.8 * s, 0.18, 0.8 * s), CFrame.new(p) * ang(0, yaw + 45, 0), FLOWER)
			B:block(crop, v(0.38 * s, 0.32, 0.38 * s), CFrame.new(p + v(0, 0.08, 0)) * ang(0, yaw, 0), FLOWER_C)
		end
		do
			local function outAt(k)
				local p = vinePts[k]
				local o = v(p.X - PX, 0, p.Z - PZ)
				return p + (o.Magnitude > 0.01 and o.Unit or v(0, 0, -1)) * 1.6
			end
			flower(outAt(3) + v(0, 1.2, 0), 1.0, 10)
			flower(outAt(6) + v(0, 1.1, 0), 0.95, 35)
			flower(outAt(9) + v(0, 1.0, 0), 0.9, 60)
			flower(BARF * v(PX + 2.4, BAR_Y + 1.5, PZ - 0.9), 0.8, 20)
			flower(v(-3.0, TOP + 0.75, -1.8), 0.85, 15)
		end

		---------------------------------------------------------------- melons
		-- hanging from the crossbar ends
		melon(crop, hang[1] - v(0, 1.65 * 1.15 + 0.1, 0), 1.15, 10, { shine = true, rich = true, noStem = true, name = "Melon" })
		melon(crop, hang[-1] - v(0, 1.65 * 1.0 + 0.1, 0), 1.0, -15, { noStem = true, rich = true })
		-- hanging from the side peg
		melon(crop, pegDrop - v(0, 1.65 * 0.85 + 0.05, 0), 0.85, 30, { noStem = true })
		-- crown melon in a leaf nest on top of the post
		do
			local base = v(PX, POST_TOP + 0.3, PZ)
			leaf(base + v(-1.0, 0.35, -0.3), 1.7, LEAF[2])
			leaf(base + v(1.0, 0.3, 0.4), 1.7, LEAF[1])
			leaf(base + v(0.2, 0.25, 1.1), 1.5, LEAF[3])
			leaf(base + v(-0.2, 0.3, -1.1), 1.5, LEAF[4])
			local s = 1.2
			local top = melon(crop, base + v(0, 1.6 * s + 0.1, 0), s, 20, { shine = true, rich = true, name = "Melon" })
			-- stem curl + leaf on the crown melon
			local c1 = top + v(0.2, 0.55, 0.1)
			local c2 = c1 + v(0.6, 0.45, -0.2)
			local c3 = c2 + v(0.25, -0.45, -0.25)
			B:bar(crop, c1 - v(0, 0.1, 0), c2, 0.22, 0.22, VINE)
			B:bar(crop, c2, c3, 0.2, 0.2, LEAF[3])
			B:block(crop, v(1.1, 0.25, 0.8), CFrame.new(top + v(-0.55, 0.55, 0.05)) * ang(0, 30, 18), LEAF[2])
		end
		-- melons resting on the sand
		do
			local s = 1.25
			local top = melon(soil, v(1.3, TOP - 0.2 + 1.6 * s, -3.6), s, 25, { rich = true, shine = true, name = "Soil" })
			B:block(soil, v(1.0, 0.25, 0.7), CFrame.new(top + v(0.55, 0.45, 0)) * ang(0, -20, -18), LEAF[2], S)
			melon(soil, v(-3.4, 0.85 - 0.05 + 1.6 * 0.8, 2.6), 0.8, -20, { name = "Soil" })
			-- ground runner connecting the front melon to the vine root
			B:bar(crop, vinePts[0] + v(0.3, 0, -0.3), v(0.9, TOP + 0.25, -2.0), 0.36, 0.36, VINE_DK)
			leaf(v(-0.8, TOP + 0.55, -1.0), 1.3, LEAF[1])
			B:bar(crop, vinePts[0] + v(-0.3, 0, 0.3), v(-2.6, 1.85, 2.0), 0.34, 0.34, VINE_DK)
		end

		---------------------------------------------------------------- fx
		local zone = B:block(crop, v(9, 9, 6), cf(0, 10, 0), MEL, { tr = 1, name = "SunZone" })
		B:emitter(zone, "sparkle", { name = "SunSparkle", color = { "#fff4b0", "#ffc94a", "#ff9a3a" }, rate = 3.5, size = { 0.15, 0.4, 0 }, life = { 1.2, 2.2 }, speed = { 0.2, 0.5 } })
	end,
}
