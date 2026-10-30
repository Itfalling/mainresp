--!nocheck
-- Caramel Apple Tree (Scarecrow Stage crop #6, Mythic).
-- A harvest-fair treat tree: a wide stepped dirt mound strewn with hay bits
-- and fallen autumn leaves, a stout warm-brown trunk with stepped collars and
-- reaching branches, and a big umbrella crown of rotated studded leaf cubes in
-- orange, amber, gold and rust - its top cubes glazed with dripping caramel.
-- The fruit are CARAMEL APPLES: glossy red apple cubes with a dripping caramel
-- (or chocolate + sprinkles) cap and a wooden stick that doubles as the stem,
-- hanging all round the crown, sitting proudly on top, and two that have
-- fallen onto the mound. Tiny neon shines, gold sparkles, a few falling leaves
-- and one warm light. Static prop: no motion.luau.
return {
	DisplayName = "Caramel Apple Tree",
	Rarity = "Mythic",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local HAY, HAY_LT = "#e2b64a", "#f2d27a"
		local BARK_DK, BARK, BARK_LT = "#4a2a1a", "#623822", "#7a4a2e"
		local RUST, ORANGE, ORANGE_LT, AMBER, GOLD = "#a8381c", "#e8621c", "#f7862a", "#f29a22", "#f7c43c"
		local APPLE, APPLE_DK = "#d4142e", "#9c0c20"
		local CAR, CAR_DK, CAR_LT = "#d39443", "#a8661f", "#ecbd6e"
		local CHOC, CHOC_DK = "#5b3220", "#432415"
		local STICK = "#ead2a0"
		local SPRINKLES = { "#ffffff", "#ff7ab8", "#ffd23a", "#7fd4ff" }
		local SHINE = "#fff4e0"

		local seed = 6106
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end

		---------------------------------------------------------------- mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.4, 2.3), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, math.rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 6.6, DIRT_DK, 17, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.6, 4.4, DIRT, 12, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.4, 0.4, 2.7, DIRT_LT, 0, {}, 0)
		for _, c in { { 7.0, 0.35, 1.6, 20 }, { -6.8, 0.3, -2.2, -15 }, { 1.4, 0.3, 7.1, 35 } } do
			B:block(soil, v(1.1, 0.6, 0.9), cf(c[1], c[2], c[3], 0, c[4], 0), DIRT_DK2, S)
		end
		for _, g in { { 6.2, -2.8 }, { -5.6, 3.6 }, { 3.6, 5.6 }, { -3.0, -6.0 } } do
			B:block(soil, v(0.45, 0.9, 0.45), cf(g[1], 1.0, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.35, 0.6, 0.35), cf(g[1] + 0.35, 0.95, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end
		-- hay bits
		for _, h in { { -5.4, 0.85, -3.6 }, { 5.6, 0.85, 2.6 }, { -1.2, 0.85, 6.0 }, { 3.6, 1.45, -2.4 }, { -6.0, 0.85, 1.0 } } do
			local yaw = rnd(0, 180)
			B:block(soil, v(1.6, 0.18, 0.22), cf(h[1], h[2] + 0.06, h[3], 0, yaw, rnd(-4, 4)), HAY, S)
			B:block(soil, v(1.3, 0.18, 0.22), cf(h[1] + 0.1, h[2] + 0.2, h[3] + 0.1, 0, yaw + rnd(35, 70), 0), HAY_LT, S)
		end
		-- fallen autumn leaves lying on the tiers
		for _, l in { { 4.8, 0.85, -4.2 }, { -4.4, 0.85, -4.6 }, { 6.0, 0.85, -0.6 }, { -6.2, 0.85, -1.4 }, { 2.2, 1.45, 3.4 }, { -3.0, 1.45, 2.6 }, { 0.4, 0.85, -6.2 }, { -4.6, 0.85, 4.4 } } do
			B:block(soil, v(1.0, 0.16, 1.0), cf(l[1], l[2] + 0.08, l[3], rnd(-5, 5), rnd(0, 90), rnd(-5, 5)), pick({ ORANGE, RUST, GOLD, AMBER }), S)
		end

		---------------------------------------------------------------- trunk
		local Y0 = 1.8
		local crop = B:bone("Crop", "Root", v(0, Y0, 0))
		local function seg(a, b, w, col)
			local c, len = P.aim(a, b)
			return B:block(crop, v(w, w, len + w * 0.7), c, col)
		end
		B:block(crop, v(3.6, 0.8, 3.6), cf(0, Y0 + 0.3, 0), BARK_DK)
		for i = 0, 3 do
			B:block(crop, v(1.2, 0.7, 1.8), cf(0, Y0 + 0.2, 0, 0, i * 90 + 45, 0) * CFrame.new(0, 0, -2.1) * ang(-10, 0, 0), BARK_DK)
		end
		B:block(crop, v(3.0, 0.8, 3.0), cf(0, Y0 + 1.1, 0, 0, 10, 0), BARK)
		B:block(crop, v(2.4, 2.8, 2.4), cf(0, Y0 + 2.9, 0), BARK_LT)
		B:block(crop, v(2.1, 2.2, 2.1), cf(0.05, Y0 + 5.2, 0.05, 0, 6, 0), BARK)
		B:block(crop, v(1.8, 1.8, 1.8), cf(0.1, Y0 + 6.9, 0.1, 0, 12, 0), BARK_LT)
		for _, n in { { 1.22, 2.4, 0.3 }, { -1.22, 3.6, -0.4 }, { 0.3, 4.8, -1.08 }, { -0.4, 5.9, 1.08 }, { 1.08, 6.6, 0.2 } } do
			local sx = math.abs(n[1]) > 0.9 and 0.3 or 0.7
			local sz = math.abs(n[3]) > 0.9 and 0.3 or 0.7
			B:block(crop, v(sx, 0.7, sz), cf(n[1], Y0 + n[2], n[3]), BARK_DK)
		end
		local function branch(from, to, w)
			seg(from, to, w, BARK)
			B:block(crop, v(w + 0.2, w + 0.2, w + 0.2), CFrame.new(from), BARK)
		end
		branch(v(0.4, Y0 + 5.0, 0), v(3.8, Y0 + 7.4, -0.6), 1.0)
		branch(v(-0.4, Y0 + 5.4, 0), v(-3.8, Y0 + 7.6, 0.8), 1.0)
		branch(v(0, Y0 + 5.9, 0.4), v(0.6, Y0 + 7.8, 3.6), 0.9)
		branch(v(0, Y0 + 6.2, -0.4), v(-0.7, Y0 + 8.0, -3.5), 0.9)

		---------------------------------------------------------------- crown
		local cubes = {}
		local function leaf(x, y, z, s, rx, ry, rz, col)
			local c = cf(x, Y0 + y - 0.5, z, rx, ry, rz)
			B:block(crop, v(s, s, s), c, col)
			local e = { cf = c, s = s }
			table.insert(cubes, e)
			return e
		end
		local center = leaf(0, 10.6, 0, 5.6, 8, 20, 6, ORANGE)
		local inner = {}
		local innerCols = { RUST, ORANGE_LT, AMBER, ORANGE, ORANGE_LT, RUST }
		for i = 0, 5 do
			local a = math.rad(i * 60 + 10)
			inner[i + 1] = leaf(math.sin(a) * 3.9, 10.1 + rnd(-0.3, 0.3), -math.cos(a) * 3.9, 4.3 + rnd(-0.2, 0.3), rnd(-18, 18), i * 60 + rnd(-20, 20), rnd(-18, 18), innerCols[i + 1])
		end
		local outer = {}
		local outerCols = { ORANGE, RUST, AMBER, ORANGE_LT, ORANGE, RUST, GOLD, ORANGE_LT }
		for i = 0, 7 do
			local a = math.rad(i * 45 + 32)
			outer[i + 1] = leaf(math.sin(a) * 6.3, 9.0 + rnd(-0.3, 0.3), -math.cos(a) * 6.3, 3.2 + rnd(-0.1, 0.3), rnd(-22, 22), rnd(0, 90), rnd(-22, 22), outerCols[i + 1])
		end
		local top = {}
		for i = 0, 2 do
			local a = math.rad(i * 120 + 50)
			top[i + 1] = leaf(math.sin(a) * 2.0, 12.6, -math.cos(a) * 2.0, 3.7, rnd(-12, 12), rnd(0, 90), rnd(-12, 12), (i == 1) and GOLD or AMBER)
		end
		local crownTop = leaf(0.2, 13.5, -0.1, 2.9, 10, 25, 8, GOLD)

		-- caramel glaze poured over the top cubes, dripping down their sides
		local function glaze(e, col, colDk)
			local s = e.s
			B:block(crop, v(s + 0.1, 0.42, s + 0.1), e.cf * CFrame.new(0, s / 2 - 0.12, 0), col)
			for _, d in { { 1, 0.15, 1.1 }, { -1, -0.25, 0.7 } } do
				B:block(crop, v(0.6, d[3], 0.24), e.cf * CFrame.new(d[2] * s, s / 2 - 0.3 - d[3] / 2 + 0.2, -d[1] * (s / 2 + 0.07)), colDk)
			end
			B:block(crop, v(0.24, 0.9, 0.6), e.cf * CFrame.new(s / 2 + 0.07, s / 2 - 0.55, 0.2 * s), colDk)
		end
		glaze(crownTop, CAR, CAR_DK)
		local glints = {}
		for _, g in { { crownTop, 0.5, -0.4 }, { top[1], -0.6, 0.5 }, { top[3], 0.4, 0.6 } } do
			table.insert(glints, B:block(crop, v(0.3, 0.12, 0.3), g[1].cf * CFrame.new(g[2], g[1].s / 2 + 0.12, g[3]) * ang(0, 45, 0), "#fff1c2", { mat = "Neon", name = "SugarGlint" }))
		end
		glaze(top[1], CAR, CAR_DK)
		glaze(top[3], CAR_LT, CAR)

		-- caramel oozing down the trunk into a little stepped pool at its foot
		B:block(crop, v(4.4, 0.24, 2.6), cf(0, Y0 + 0.08, 0, 0, 20, 0), CAR)
		B:block(crop, v(2.4, 0.22, 4.2), cf(0.2, Y0 + 0.09, -0.2, 0, 20, 0), CAR)
		B:block(crop, v(1.2, 0.2, 1.0), cf(2.3, Y0 + 0.1, -1.4, 0, 35, 0), CAR_LT)
		B:block(crop, v(0.5, 2.6, 0.3), cf(0.4, Y0 + 5.2, -1.12, 0, 6, 0), CAR_DK)
		B:block(crop, v(0.3, 1.6, 0.5), cf(-1.12, Y0 + 5.9, 0.3, 0, 6, 0), CAR_DK)
		B:block(crop, v(0.5, 1.8, 0.3), cf(-0.3, Y0 + 2.6, -1.28, 0, 0, 0), CAR)
		B:block(crop, v(0.7, 0.3, 0.5), cf(-0.3, Y0 + 1.66, -1.5, 0, 0, 0), CAR)

		------------------------------------------------------- caramel apples
		-- local frame: +Y = up along the stick. s = apple size.
		local shines, nApple = {}, 0
		local function caramelApple(c, s, kind)
			nApple += 1
			B:block(crop, v(s, s * 0.95, s), c, APPLE)
			B:block(crop, v(s * 0.72, 0.3, s * 0.72), c * CFrame.new(0, -s * 0.47 - 0.1, 0), APPLE_DK)
			local capH = s * 0.48
			local cy = s * 0.475 - capH / 2 + 0.08
			local col, dk = CAR, CAR_DK
			if kind == "choc" then col, dk = CHOC, CHOC_DK end
			B:block(crop, v(s + 0.14, capH, s + 0.14), c * CFrame.new(0, cy, 0), col)
			-- drips running down two sides
			local capBot = cy - capH / 2
			local d1, d2 = rnd(0.55, 0.9), rnd(0.4, 0.7)
			B:block(crop, v(0.36, d1, 0.24), c * CFrame.new(rnd(-0.2, 0.2) * s, capBot - d1 / 2 + 0.12, -(s / 2 + 0.1)), dk)
			B:block(crop, v(0.24, d2, 0.36), c * CFrame.new(s / 2 + 0.1, capBot - d2 / 2 + 0.12, rnd(-0.2, 0.2) * s), dk)
			if kind == "choc" then
				for k = 1, 3 do
					B:block(crop, v(0.2, 0.12, 0.42), c * CFrame.new(rnd(-0.32, 0.32) * s, cy + capH / 2 + 0.03, rnd(-0.32, 0.32) * s) * ang(0, rnd(0, 180), 0), SPRINKLES[(nApple + k) % 4 + 1])
				end
			elseif kind == "nuts" then
				for k = 1, 2 do
					B:block(crop, v(0.3, 0.3, 0.3), c * CFrame.new(rnd(-0.3, 0.3) * s, cy + rnd(-0.1, 0.1), -(s / 2 + 0.12)) * ang(0, 0, 45), CAR_LT)
				end
			end
			-- wooden stick
			B:block(crop, v(0.3, 2.0, 0.3), c * CFrame.new(0, cy + capH / 2 + 0.9, 0), STICK)
			if nApple % 3 == 1 then
				local g = B:block(crop, v(0.26, 0.26, 0.1), c * CFrame.new(-s * 0.25, -s * 0.1, -s / 2 - 0.03), SHINE, { mat = "Neon", name = "AppleShine" .. (#shines + 1) })
				table.insert(shines, g)
			end
		end
		local KINDS = { "car", "choc", "car", "nuts", "car", "choc", "car", "nuts" }
		-- hanging under the outer ring, stick going up into the leaves
		for i, e in outer do
			local p = e.cf.Position
			local dir = v(p.X, 0, p.Z).Unit
			local s = rnd(1.8, 2.05)
			local ap = p + dir * rnd(0.9, 1.3) + v(0, -1.6 - s / 2 - 0.5 - (i % 2) * 0.4, 0)
			caramelApple(CFrame.new(ap) * ang(rnd(-6, 6), rnd(0, 90), rnd(-6, 6)), s, KINDS[i])
		end
		-- hung on the sides of the crown, sticks leaning back into the leaves
		for i, k in { 1, 3, 4, 6 } do
			local e = inner[k]
			local p = e.cf.Position
			local dir = v(p.X, 0, p.Z).Unit
			local s = rnd(1.7, 1.9)
			local ap = p + dir * (e.s * 0.55 + 0.9) + v(0, -e.s * 0.15, 0)
			local th = math.rad(28)
			local yA = v(0, math.cos(th), 0) - dir * math.sin(th)
			local xA = v(-dir.Z, 0, dir.X)
			caramelApple(CFrame.fromMatrix(ap, xA, yA), s, KINDS[i + 3])
		end
		-- proudly sitting on top of the crown, sticks up
		caramelApple(inner[2].cf * CFrame.new(0, inner[2].s / 2 + 0.85, 0), 1.8, "choc")
		caramelApple(inner[5].cf * CFrame.new(0, inner[5].s / 2 + 0.85, 0), 1.8, "nuts")
		-- two fallen on the mound
		caramelApple(cf(3.3, 1.4 + 0.9, -3.0, 0, 30, -18), 1.8, "car")
		caramelApple(cf(-3.8, 0.8 + 0.85, -4.6, 0, -20, 22), 1.7, "choc")

		---------------------------------------------------------------- bling
		B:emitter(shines[1], "sparkle", { name = "CaramelSparkle", color = { "#fff0c8", "#ffc75a" }, rate = 4, size = 0.35 })
		B:emitter(glints[1], "sparkle", { name = "CaramelSparkle2", color = { "#ffd98a", "#ff9a4a" }, rate = 3, size = 0.3 })
		B:emitter(B:block(crop, v(9, 0.2, 9), cf(0, Y0 + 7.0, 0), ORANGE, { tr = 1, name = "LeafFall" }), "leaf",
			{ name = "AutumnLeaves", color = { "#f5862a", "#f9cc48", "#b8421c" }, rate = 1.5, size = 0.45 })
		B:light(center.cf and B:block(crop, v(0.4, 0.4, 0.4), cf(0, Y0 + 6.6, 0), ORANGE, { tr = 1, name = "Lamp" }), { color = "#ffb35a", brightness = 1.0, range = 14, name = "WarmLight" })
	end,
}
