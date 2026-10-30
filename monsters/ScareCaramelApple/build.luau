--!nocheck
-- Caramel Apple Tree (Scarecrow Stage crop #6, Mythic).
-- A harvest-fair treat tree: a stepped dirt mound, a stout warm-brown trunk
-- with stepped collars and reaching branches, and a clean rounded crown of
-- rotated studded leaf cubes in deep crimson, burgundy and rust with a few
-- gold highlights. Nine CARAMEL APPLES hang round the rim - shiny red apple
-- cubes with a glossy dripping caramel cap (one chocolate + sprinkles) and a
-- short wooden stick pushed up into the leaves as the stem - and two have
-- fallen onto the mound. Tiny neon shines, sparkles, a few falling leaves and
-- one warm light. Static prop: no motion.luau.
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
		local BURGUNDY, CRIMSON, CRIMSON_LT, RUST, GOLD = "#7a1830", "#a8203a", "#c8343f", "#9a3a1c", "#f2b632"
		local APPLE, APPLE_DK = "#ee2a2a", "#b3161c"
		local CAR, CAR_DK, CAR_LT = "#e09a44", "#b3702a", "#f6c97e"
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
		-- a couple of hay bits and fallen leaves
		for _, h in { { -5.4, 0.85, -3.6 }, { 5.6, 0.85, 2.6 } } do
			local yaw = rnd(0, 180)
			B:block(soil, v(1.6, 0.18, 0.22), cf(h[1], h[2] + 0.06, h[3], 0, yaw, rnd(-4, 4)), HAY, S)
			B:block(soil, v(1.3, 0.18, 0.22), cf(h[1] + 0.1, h[2] + 0.2, h[3] + 0.1, 0, yaw + rnd(35, 70), 0), HAY_LT, S)
		end
		for _, l in { { 5.0, 0.85, -4.0, CRIMSON }, { -6.0, 0.85, 0.4, BURGUNDY }, { -1.4, 0.85, 6.0, GOLD } } do
			B:block(soil, v(1.0, 0.16, 1.0), cf(l[1], l[2] + 0.08, l[3], rnd(-5, 5), rnd(0, 90), rnd(-5, 5)), l[4], S)
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
		-- clean rounded crown (Velvet Plum layout, a touch wider): crimson,
		-- burgundy and deep rust cubes with a few gold highlights
		local cubes = {}
		local function leaf(x, y, z, sz, rx, ry, rz, col)
			local c = cf(x * 1.25, Y0 + y + 0.2, z * 1.25, rx, ry, rz)
			local s2 = sz * 1.16
			B:block(crop, v(s2, s2, s2), c, col)
			table.insert(cubes, { cf = c, s = s2 })
		end
		leaf(0.0, 9.6, 0.0, 5.0, 8, 20, 6, CRIMSON)
		leaf(-3.4, 8.8, 0.7, 4.2, -12, 35, 14, BURGUNDY)
		leaf(3.6, 9.0, -0.5, 4.2, 14, -25, -10, CRIMSON)
		leaf(0.5, 8.6, 3.3, 4.0, 18, 10, -12, RUST)
		leaf(-0.5, 8.7, -3.3, 4.0, -16, -15, 10, CRIMSON)
		leaf(-2.0, 11.1, -1.0, 3.9, 18, 35, -12, CRIMSON_LT)
		leaf(2.1, 11.0, 1.4, 3.9, -12, 15, 15, BURGUNDY)
		leaf(0.2, 11.4, 0.1, 3.0, 15, 25, 12, RUST)
		leaf(-4.0, 10.2, 2.6, 3.1, 20, -20, 25, CRIMSON_LT)
		leaf(4.1, 10.4, 2.1, 3.2, -25, 30, -18, GOLD)
		leaf(3.0, 7.7, 2.6, 3.0, 12, 50, 8, BURGUNDY)
		leaf(-3.1, 7.8, -2.4, 3.0, -10, 20, -15, RUST)
		leaf(2.8, 10.6, -2.6, 3.2, 30, -35, 12, CRIMSON_LT)
		leaf(-4.7, 9.3, -1.3, 3.0, -20, 15, 30, GOLD)
		-- lower rim ring rounds the dome off underneath
		leaf(4.6, 8.0, -2.6, 2.8, 15, 20, -20, BURGUNDY)
		leaf(-1.6, 7.9, 4.6, 2.8, -18, 40, 12, CRIMSON)
		leaf(-4.2, 8.0, 1.6, 2.6, 22, -10, 18, RUST)
		leaf(1.4, 7.8, -4.6, 2.7, -14, 60, -16, BURGUNDY)
		leaf(-1.2, 12.3, 1.6, 2.6, 20, 10, -15, GOLD)

		local function inside(p, pad)
			for _, c in cubes do
				local l = c.cf:PointToObjectSpace(p)
				local h = c.s / 2 - (pad or 0)
				if math.abs(l.X) < h and math.abs(l.Y) < h and math.abs(l.Z) < h then
					return true
				end
			end
			return false
		end
		-- lowest point of the crown above (x, z)
		local function crownBottom(x, z)
			for y = Y0 + 5, Y0 + 15, 0.1 do
				if inside(v(x, y, z), 0.15) then return y end
			end
			return nil
		end

		------------------------------------------------------- caramel apples
		-- local frame: +Y = up along the stick. s = apple size.
		local shines = {}
		local function caramelApple(c, s, choc, shine)
			B:block(crop, v(s, s * 0.95, s), c, APPLE)
			B:block(crop, v(s * 0.72, 0.3, s * 0.72), c * CFrame.new(0, -s * 0.47 - 0.1, 0), APPLE_DK)
			local capH = s * 0.46
			local cy = s * 0.475 - capH / 2 + 0.08
			local col, dk, hi = CAR, CAR_DK, CAR_LT
			if choc then col, dk, hi = CHOC, CHOC_DK, CHOC end
			B:block(crop, v(s + 0.14, capH, s + 0.14), c * CFrame.new(0, cy, 0), col)
			-- glossy highlight on the cap
			if not choc then
				B:block(crop, v(s * 0.55, capH + 0.04, s * 0.3), c * CFrame.new(-s * 0.12, cy, -s * 0.22), hi)
			end
			-- two drips running down
			local capBot = cy - capH / 2
			B:block(crop, v(0.4, 0.75, 0.26), c * CFrame.new(s * 0.18, capBot - 0.3, -(s / 2 + 0.1)), dk)
			B:block(crop, v(0.26, 0.55, 0.4), c * CFrame.new(s / 2 + 0.1, capBot - 0.2, s * 0.15), dk)
			if choc then
				for k = 1, 4 do
					B:block(crop, v(0.2, 0.12, 0.42), c * CFrame.new(((k % 2) - 0.5) * 0.6 * s, cy + capH / 2 + 0.03, (k <= 2 and -0.22 or 0.22) * s) * ang(0, k * 47, 0), SPRINKLES[k])
				end
			end
			-- short stick
			B:block(crop, v(0.28, 1.4, 0.28), c * CFrame.new(0, cy + capH / 2 + 0.6, 0), STICK)
			if shine then
				table.insert(shines, B:block(crop, v(0.28, 0.28, 0.1), c * CFrame.new(-s * 0.25, -s * 0.12, -s / 2 - 0.03), SHINE, { mat = "Neon", name = "AppleShine" }))
			end
			return cy + capH / 2 + 1.3 -- stick top above the apple centre
		end
		-- 9 apples hung round the rim, sticks pushed up into the leaves
		for i = 0, 8 do
			local a = math.rad(i * 40 + 12)
			local r = (i % 2 == 0) and 6.6 or 5.8
			local x, z = math.sin(a) * r, -math.cos(a) * r
			local yb = crownBottom(x, z)
			while not yb and r > 2 do
				r -= 0.3
				x, z = math.sin(a) * r, -math.cos(a) * r
				yb = crownBottom(x, z)
			end
			local s = (i % 2 == 0) and 1.9 or 1.75
			-- stick top (centre + offset) sits 0.45 inside the leaves
			local capH = s * 0.46
			local stickTop = s * 0.475 + 0.08 + 1.3
			local y = yb + 0.45 - stickTop
			caramelApple(CFrame.new(x, y, z) * ang(rnd(-5, 5), rnd(0, 90), rnd(-5, 5)), s, i == 5, i % 3 == 0)
		end
		-- two fallen on the mound
		caramelApple(cf(3.4, 1.4 + 0.85, -2.9, 0, 30, -16), 1.8, false, true)
		caramelApple(cf(-4.2, 0.8 + 0.8, 3.4, 0, -40, 18), 1.7, false, false)

		---------------------------------------------------------------- bling
		B:emitter(shines[1], "sparkle", { name = "CaramelSparkle", color = { "#fff0c8", "#ffc75a" }, rate = 4, size = 0.35 })
		B:emitter(shines[2] or shines[1], "sparkle", { name = "CaramelSparkle2", color = { "#ffd98a", "#ffb0b0" }, rate = 3, size = 0.3 })
		B:emitter(B:block(crop, v(9, 0.2, 9), cf(0, Y0 + 7.4, 0), CRIMSON, { tr = 1, name = "LeafFall" }), "leaf",
			{ name = "AutumnLeaves", color = { "#a81c30", "#f2b632", "#8e3218" }, rate = 1.5, size = 0.45 })
		B:light(B:block(crop, v(0.4, 0.4, 0.4), cf(0, Y0 + 6.8, 0), CRIMSON, { tr = 1, name = "Lamp" }), { color = "#ffb35a", brightness = 1.0, range = 14, name = "WarmLight" })
	end,
}
