--!nocheck
-- Mossy Lantern Gourd (Thorny Woods crop #4, Epic).
-- A tall gourd vine climbing a crooked twig tower: three bent bark poles
-- lashed together at the top with twine, crossed by twig rungs, with crooked
-- arms poking out. A thick vine spirals up the tower dressed in big mossy
-- leaf cubes and pale gourd flowers. Pale-green lantern gourds hang from
-- the arms and the top hook; each is ribbed, capped with moss, and glows
-- softly through thin carved slits (small neon). One fallen lantern gourd
-- sits on the mound. Fireflies + one soft light.
-- Base: stepped forest-dirt mound with moss pads, stones, fallen leaves,
-- tiny toadstools and roots. Static prop: no motion.luau.
return {
	DisplayName = "Mossy Lantern Gourd",
	Rarity = "Epic",
	Element = "Forest",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Thorny Woods)
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3b2416", "#47291a", "#5e3a22", "#78492b"
		local MOSS, MOSS_DK, MOSS_LT = "#5e9e38", "#3f7a2c", "#86c24a"
		local GRASS = "#5fc23c"
		local STONE, STONE_LT, STONE_DK = "#7f7a72", "#9d978b", "#5f5b55"
		local FALL = { "#c8662a", "#a84a22", "#d99a3a" }
		local CAP, DOT, STEM = "#d8343a", "#fff4e6", "#efe3c9"
		local BARK, BARK_DK, BARK_LT = "#4a2e1c", "#33200f", "#634029"
		local TWINE = "#b98a4a"
		local FUNGUS, FUNGUS_LT = "#c9893a", "#e8b866"
		local VINE, VINE_DK = "#3f7f2e", "#2c5f24"
		local LEAF = { "#3f8a2e", "#4f9a34", "#62ad3c" }
		local GOURD, GOURD_LT, GOURD_DK, GOURD_RIB = "#b3da74", "#d2ec98", "#7fae4e", "#94c45e"
		local GCAP = "#3f6e2c"
		local GLOW = "#fff38a"
		local FLOWER, FLOWER_C = "#fff6cf", "#ffc83a"
		local THORN = "#f1e4c0"
		local NEON = { mat = "Neon" }

		local seed = 4134
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

		---------------------------------------------------------------- mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.5, 2.3), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 5.8, DIRT_DK, 13, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.7, 4.0, DIRT, 9, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.5, 0.5, 2.6, DIRT_LT, 0, {}, 0)
		local TOP = 2.0

		for _, m in { { 20, 4.0, 1.18, 2.1, MOSS }, { 140, 4.05, 1.17, 1.9, MOSS_DK }, { 250, 4.0, 1.18, 2.0, MOSS_LT }, { 320, 5.85, 0.6, 2.3, MOSS_DK }, { 85, 5.9, 0.58, 2.0, MOSS }, { 190, 5.8, 0.6, 1.8, MOSS } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], m[3], -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[4], 0.3, 1.3), c * ang(-12, 0, 0), m[5], S)
		end
		for _, s in { { -5.0, 0.85, -1.0, 0.9, 25, STONE }, { -5.3, 0.7, 0.2, 0.6, 10, STONE_LT }, { 4.6, 0.85, 2.8, 0.8, -20, STONE_DK }, { 3.4, 1.65, 1.6, 0.7, 40, STONE } } do
			B:block(soil, v(s[4] * 1.2, s[4], s[4]), cf(s[1], s[2], s[3], rnd(-10, 10), s[5], rnd(-10, 10)), s[6], S)
		end
		for i, f in { { -2.6, 1.52, -2.8, 30 }, { 1.2, 2.02, -1.6, -40 }, { -4.6, 0.82, -3.0, 70 }, { 5.3, 0.82, -0.6, 10 }, { -1.0, 0.82, 5.4, 45 } } do
			B:block(soil, v(0.9, 0.12, 0.6), cf(f[1], f[2], f[3], rnd(-6, 6), f[4], rnd(-6, 6)), FALL[(i - 1) % 3 + 1], S)
		end
		for _, g in { { 5.5, -2.2 }, { -3.0, -5.2 }, { -5.6, 1.6 }, { 2.6, 5.1 } } do
			B:block(soil, v(0.45, 0.9, 0.45), cf(g[1], 0.9, g[2], 0, rnd(0, 40), 0), GRASS, S)
		end
		local function toad(x, y, z, s)
			B:block(soil, v(0.35 * s, 0.8 * s, 0.35 * s), cf(x, y + 0.4 * s, z), STEM, S)
			B:block(soil, v(1.0 * s, 0.4 * s, 1.0 * s), cf(x, y + 0.9 * s, z, 0, 20, 0), CAP, S)
			B:block(soil, v(0.25 * s, 0.1, 0.25 * s), cf(x + 0.2 * s, y + 1.12 * s, z - 0.15 * s, 0, 20, 0), DOT, S)
		end
		toad(3.6, 1.5, -2.4, 1.0)
		toad(4.2, 1.5, -1.7, 0.7)
		toad(-3.8, 0.8, 3.6, 0.8)

		---------------------------------------------------------------- twig tower
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		local APEX = 17.2
		local poles = {}
		for i, deg in { 60, 180, 300 } do
			local d = dirOf(deg)
			local side = d:Cross(v(0, 1, 0)).Unit
			local pts = {}
			local ts = { 0, 0.3, 0.62, 1.0 }
			local kinks = { 0, 0.45, -0.4, 0 }
			for k, t in ts do
				local r = 2.5 * (1 - t) + 0.35 * t
				local y = TOP - 0.3 + (APEX - TOP + 0.3) * t
				pts[k] = d * r + side * (kinks[k] * ((i % 2 == 0) and -1 or 1)) + v(0, y, 0)
			end
			pts[4] = d * 0.35 + v(0, APEX, 0)
			for k = 1, 3 do
				local a, b = pts[k], pts[k + 1]
				local dd = (b - a).Unit
				B:bar(crop, a - dd * 0.15, b + dd * 0.25, 0.75 - 0.08 * k, 0.75 - 0.08 * k, (k == 2) and BARK_LT or BARK)
			end
			poles[i] = pts
		end
		local function poleAt(i, y)
			local pts = poles[i]
			for k = 1, 3 do
				local a, b = pts[k], pts[k + 1]
				if y <= b.Y or k == 3 then
					local t = math.clamp((y - a.Y) / (b.Y - a.Y), 0, 1)
					return a:Lerp(b, t)
				end
			end
		end
		-- twine lashing at the apex + crooked finial
		B:block(crop, v(1.5, 0.7, 1.5), cf(0, APEX - 0.2, 0, 0, 15, 0), TWINE)
		B:block(crop, v(1.25, 0.25, 1.25), cf(0, APEX + 0.25, 0, 0, 50, 0), BARK_DK)
		for i = 1, 3 do
			local p = poles[i][4]
			B:bar(crop, p, p + (p - v(0, APEX, 0)).Unit * 0.9 + v(0, 1.0, 0), 0.4, 0.4, BARK)
		end
		-- the hook at the top that carries the crown lantern (bends to the front)
		local h0 = v(0, APEX + 0.2, 0)
		local h1 = v(0.2, APEX + 1.9, -0.6)
		local h2 = v(0.1, APEX + 2.2, -1.9)
		local h3 = v(0.0, APEX + 1.6, -2.6)
		B:bar(crop, h0, h1, 0.5, 0.5, BARK)
		B:bar(crop, h1, h2, 0.45, 0.45, BARK)
		B:bar(crop, h2, h3, 0.4, 0.4, BARK_LT)
		-- twig rungs (two rings) with twine ties
		for _, y in { 7.6, 12.6 } do
			for i = 1, 3 do
				local a, b = poleAt(i, y), poleAt(i % 3 + 1, y + 0.3)
				local dd = (b - a).Unit
				B:bar(crop, a - dd * 0.5, b + dd * 0.5, 0.38, 0.38, BARK_LT)
				B:block(crop, v(0.85, 0.4, 0.85), CFrame.new(a) * ang(0, 30 * i, 0), TWINE)
			end
		end
		-- crooked arms poking out of the tower: {pole, y, deg}
		local arms = {}
		for ai, a in { { 1, 12.4, 70 }, { 3, 9.6, 285 }, { 2, 14.2, 165 }, { 3, 6.6, 330 }, { 1, 8.2, 118 } } do
			local base = poleAt(a[1], a[2])
			local d = dirOf(a[3])
			local m = base + d * 1.6 + v(0, 0.7, 0)
			local tip = m + d * 1.5 + v(0, 0.2, 0) + d:Cross(v(0, 1, 0)) * 0.3
			B:bar(crop, base - d * 0.2, m, 0.5, 0.5, BARK)
			B:bar(crop, m - d * 0.1, tip + d * 0.2, 0.42, 0.42, BARK_LT)
			-- one little thorn on each arm
			B:bar(crop, m, m + v(0, 0.6, 0) - d * 0.2, 0.22, 0.22, THORN)
			arms[ai] = tip
		end
		-- bracket fungus + moss on the poles
		local fp = poleAt(2, 5.0)
		B:block(crop, v(1.4, 0.3, 1.0), CFrame.new(fp + dirOf(180) * 0.55) * ang(0, 180, 0), FUNGUS)
		B:block(crop, v(1.0, 0.3, 0.8), CFrame.new(fp + dirOf(180) * 0.45 + v(0, 0.6, 0)) * ang(0, 200, 0), FUNGUS_LT)
		for _, m in { { 1, 4.0 }, { 3, 11.0 }, { 2, 9.0 } } do
			local p = poleAt(m[1], m[2])
			B:block(crop, v(1.0, 1.4, 1.0), CFrame.new(p) * ang(0, rnd(0, 90), rnd(-8, 8)), MOSS_DK)
		end

		---------------------------------------------------------------- vine + leaves
		local vinePts = {}
		local N = 14
		for k = 0, N do
			local t = k / N
			local a = 20 + t * 600
			local r = 2.25 * (1 - t) + 0.95 * t
			vinePts[k] = dirOf(a) * r + v(0, TOP + 0.1 + t * (APEX - 1.2 - TOP), 0)
		end
		-- vine root mass
		B:block(crop, v(1.3, 0.6, 1.3), CFrame.new(vinePts[0] + v(0, 0.1, 0)) * ang(0, 25, 0), VINE_DK)
		for k = 0, N - 1 do
			local a, b = vinePts[k], vinePts[k + 1]
			local dd = (b - a).Unit
			B:bar(crop, a - dd * 0.2, b + dd * 0.2, 0.55, 0.55, (k % 2 == 0) and VINE or VINE_DK)
		end
		local leafAt = { 1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14 }
		for j, k in leafAt do
			local p = vinePts[k]
			local out = v(p.X, 0, p.Z)
			out = out.Magnitude > 0.01 and out.Unit or v(0, 0, -1)
			local s = 2.4 - 0.06 * k
			B:block(crop, v(s, s * 0.8, s), CFrame.new(p + out * (0.4 + s * 0.35)) * ang(rnd(-25, 25), rnd(0, 90), rnd(-25, 25)), LEAF[(j % 3) + 1])
		end
		-- vines running out along the arms
		for ai, tip in arms do
			local inner = v(tip.X * 0.45, tip.Y - 0.2, tip.Z * 0.45)
			B:bar(crop, inner, tip + v(0, 0.15, 0), 0.32, 0.32, VINE)
			-- curly tendril + a small leaf on each arm
			local out = v(tip.X, 0, tip.Z).Unit
			local side = out:Cross(v(0, 1, 0))
			local c1 = tip + v(0, 0.2, 0) + out * 0.2
			local c2 = c1 + v(0, 0.9, 0) + out * 0.4
			local c3 = c2 + side * 0.5 - out * 0.1 + v(0, 0.2, 0)
			B:bar(crop, c1, c2, 0.2, 0.2, VINE)
			B:bar(crop, c2, c3, 0.2, 0.2, MOSS_LT)
			local lp = inner:Lerp(tip, 0.45) + v(0, 0.55, 0)
			B:block(crop, v(1.4, 1.0, 1.4), CFrame.new(lp) * ang(rnd(-20, 20), ai * 37, rnd(-20, 20)), LEAF[(ai % 3) + 1])
		end
		-- pale gourd flowers on a few leaves
		local function flower(p, s)
			B:block(crop, v(1.1 * s, 0.2, 0.42 * s), CFrame.new(p) * ang(0, 20, 0), FLOWER)
			B:block(crop, v(0.42 * s, 0.2, 1.1 * s), CFrame.new(p) * ang(0, 20, 0), FLOWER)
			B:block(crop, v(0.35 * s, 0.32, 0.35 * s), CFrame.new(p + v(0, 0.08, 0)) * ang(0, 20, 0), FLOWER_C)
		end
		flower(vinePts[3] + dirOf(20 + 3 / N * 600) * 1.8 + v(0, 1.2, 0), 1.0)
		flower(vinePts[9] + dirOf(20 + 9 / N * 600) * 1.6 + v(0, 1.0, 0), 0.9)
		flower(vinePts[13] + dirOf(20 + 13 / N * 600) * 1.4 + v(0, 0.9, 0), 0.85)

		---------------------------------------------------------------- lantern gourds
		-- hangs from `p` (top of the stem); `deg` turns the gourd so one slit
		-- faces outward.
		local function lantern(p, s, deg, stemLen, withLight)
			local F = CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
			local function at(x, y, z, ry)
				return F * CFrame.new(x * s, y * s, z * s) * CFrame.Angles(0, rad(ry or 0), 0)
			end
			local sl = stemLen or 0.8
			-- stem + cap
			B:block(crop, v(0.3, sl + 0.2, 0.3), F * CFrame.new(0, -sl / 2, 0) * CFrame.Angles(0, 0, rad(8)), VINE_DK)
			local y0 = -sl
			local function Y(y)
				return y0 / s - y
			end
			B:block(crop, v(0.9 * s, 0.45 * s, 0.9 * s), at(0, Y(0.2), 0, 45), GCAP)
			-- neck + shoulders + body (stepped octagon) + bottom
			B:block(crop, v(1.0 * s, 0.8 * s, 1.0 * s), at(0, Y(0.75), 0), GOURD_LT)
			B:block(crop, v(1.9 * s, 0.6 * s, 1.9 * s), at(0, Y(1.4), 0, 45), GOURD)
			-- stepped round body: two crossed slabs (ribbed) + a filler
			B:block(crop, v(2.6 * s, 1.7 * s, 1.7 * s), at(0, Y(2.4), 0), GOURD)
			B:block(crop, v(1.7 * s, 1.68 * s, 2.6 * s), at(0, Y(2.4), 0), GOURD_RIB)
			B:block(crop, v(2.25 * s, 1.5 * s, 2.25 * s), at(0, Y(2.4), 0), GOURD_DK)
			B:block(crop, v(2.0 * s, 0.4 * s, 2.0 * s), at(0, Y(1.55), 0), GOURD)
			B:block(crop, v(1.8 * s, 0.5 * s, 1.8 * s), at(0, Y(3.35), 0), GOURD_DK)
			B:block(crop, v(0.5 * s, 0.35 * s, 0.5 * s), at(0, Y(3.7), 0), GCAP)
			-- moss cap draped on the shoulders
			B:block(crop, v(1.4 * s, 0.35 * s, 1.0 * s), at(0.35, Y(1.12), 0.2, 20), MOSS)
			-- glowing slits on the 4 faces of the square body block
			local slit
			for i = 0, 3 do
				local f = at(0, Y(2.4), 0, i * 90) * CFrame.new(0, 0, -1.3 * s - 0.02)
				local part = B:block(crop, v(0.42 * s, 1.2 * s, 0.14), f, GLOW, NEON)
				if i == 0 then
					slit = part
				end
			end
			if withLight then
				B:light(slit, { color = "#e8ff9a", brightness = 1.2, range = 12, name = "LanternGlow" })
			end
			return at(0, Y(2.4), 0)
		end
		lantern(h3 - v(0, 0.1, 0), 0.95, 0, 0.6)
		local big = lantern(arms[2], 1.4, 285, 0.9, true)
		lantern(arms[1], 1.15, 70, 0.8)
		lantern(arms[3], 1.05, 165, 0.7)
		lantern(arms[4], 1.0, 330, 0.7)
		lantern(arms[5], 1.1, 118, 0.8)
		-- a fallen lantern gourd resting on the mound (lies on its side)
		do
			local C = cf(2.6, 2.75, -3.1, 0, 30, 82)
			B:block(soil, v(2.2, 1.4, 2.2), C, GOURD, S)
			B:block(soil, v(2.0, 1.3, 2.0), C * ang(0, 45, 0), GOURD_RIB, S)
			B:block(soil, v(1.2, 0.8, 1.2), C * CFrame.new(0, 1.0, 0), GOURD_LT, S)
			B:block(soil, v(0.7, 0.4, 0.7), C * CFrame.new(0, 1.55, 0) * ang(0, 45, 0), GCAP, S)
			B:block(soil, v(0.28, 0.85, 0.12), C * CFrame.new(0, 0, -1.13), GLOW, { mat = "Neon", name = "Soil" })
		end

		---------------------------------------------------------------- fx
		local zone = B:block(crop, v(7, 12, 7), cf(0, 10, 0), GLOW, { tr = 1, name = "FireflyZone" })
		B:emitter(zone, "sparkle", { color = { "#f6ffb0", "#c8ff6a" }, rate = 4, size = { 0.2, 0.32, 0 }, speed = { 0.2, 0.6 }, name = "Fireflies" })
		local gz = B:block(crop, v(2, 2, 2), big, GLOW, { tr = 1, name = "GlowZone" })
		B:emitter(gz, "glow", { color = "#eaff9a", rate = 2, name = "LanternMotes" })
	end,
}
