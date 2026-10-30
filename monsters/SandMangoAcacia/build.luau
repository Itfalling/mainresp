--!nocheck
-- Mango Acacia (Sandy Savanna crop #5, Legendary).
-- A flat-topped umbrella acacia in the stud-plant style:
-- * stepped golden SAND mound (bone "Soil") with chunky edge blocks,
--   sandstone rocks, dry yellow grass tufts, pebbles, shells, a tiny cactus
--   sprout and a fallen mango
-- * twisted warm-brown trunk with root flares that splits into a vase of
--   crooked branches (the classic acacia "Y")
-- * a WIDE flat umbrella canopy of big studded savanna-green leaf slabs,
--   a smaller second tier on top, a few sun-dried golden leaves
-- * juicy red-orange-gold MANGOES hanging on stems under the canopy, a few
--   more peeking from the canopy top
-- Falling leaves + warm golden motes. Static prop: no motion.luau.
return {
	DisplayName = "Mango Acacia",
	Rarity = "Legendary",
	Element = "Nature",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Sandy Savanna) ----------------------------------------
		local SAND_DK, SAND, SAND_LT, SAND_XL = "#c48a45", "#d9a95c", "#e8c27a", "#f2d495"
		local ROCK_DK, ROCK, ROCK_LT = "#a8653a", "#c97f4c", "#e0a46a"
		local GRASS_DK, GRASS, GRASS_LT = "#b39a3a", "#d4bc52", "#ead878"
		local PEB, PEB_LT = "#9c8670", "#bfae96"
		local SHELL, SHELL_PK = "#fbecd8", "#f4b6a4"
		local CAC_DK, CAC = "#4f8a42", "#68a852"
		local BARK_DK, BARK, BARK_LT = "#5e3a22", "#7f4f2e", "#9e6a40"
		local LF_DK, LF, LF_MID, LF_LT, LF_TOP = "#4c7a28", "#649a30", "#7db23a", "#9cc84a", "#b8d95e"
		local LF_GOLD = "#cdbf48"
		local M_RED, M_RED_DK, M_ORG, M_YEL, M_GRN = "#f04a2c", "#c22f1f", "#ff9424", "#ffbe38", "#b5cf42"
		local STEM = "#6b4a26"
		local HI = "#fff2b8"

		local seed = 5521
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function pick(t)
			return t[math.floor(rnd() * #t) + 1]
		end
		local function polar(r, deg)
			local a = rad(deg)
			return math.sin(a) * r, -math.cos(a) * r
		end
		local function pv(r, deg, y)
			local x, z = polar(r, deg)
			return v(x, y, z)
		end
		local function facing(p, deg)
			return CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
		end

		------------------------------------------------------------------
		-- STEPPED SAND MOUND (bone "Soil", parts named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function disc(y0, h, r, col)
			B:block(soil, v(2 * r, h, 1.15 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.15 * r, h - 0.02, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.04, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
		end
		local function edge(y0, h, r, n, cols, eh, wr, dr)
			for i = 0, n - 1 do
				local a = (i + jit(0.2)) / n * 360
				local w, d = wr[1] + rnd() * (wr[2] - wr[1]), dr[1] + rnd() * (dr[2] - dr[1])
				local hh = h + rnd() * eh - 0.05
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + hh / 2, -(r + jit(0.2)))
				B:block(soil, v(w, hh, d), p * ang(0, jit(9), 0), pick(cols), S)
			end
		end
		disc(0, 0.8, 6.3, SAND_DK)
		edge(0, 0.8, 6.35, 16, { SAND_DK, SAND, SAND_DK }, 0.45, { 1.7, 2.5 }, { 1.3, 1.8 })
		disc(0.8, 0.7, 4.6, SAND)
		edge(0.8, 0.7, 4.65, 12, { SAND, SAND_LT, SAND }, 0.35, { 1.5, 2.2 }, { 1.2, 1.6 })
		disc(1.5, 0.6, 3.0, SAND_LT)
		local TOP = 2.1

		-- wind ripples in the sand
		for _, m in { { 20, 5.1, 0.82, 2.4 }, { 140, 5.2, 0.82, 2.2 }, { 255, 5.0, 0.82, 2.5 }, { 320, 5.2, 0.82, 1.9 }, { 80, 3.7, 1.52, 1.8 }, { 200, 3.7, 1.52, 1.7 } } do
			local c = facing(pv(m[2], m[1], m[3]), m[1])
			B:block(soil, v(m[4], 0.18, 0.7), c * ang(-6, 0, 0), SAND_XL, S)
		end
		-- sandstone rocks (stacked, warm)
		for _, s in { { 4.9, 1.1, 2.6, 1.1, 25, ROCK }, { 5.6, 1.0, 1.2, 0.7, 10, ROCK_LT }, { -5.2, 1.05, -2.3, 1.0, -20, ROCK_DK }, { -4.5, 1.0, -3.4, 0.6, 30, ROCK_LT }, { 2.8, 1.9, 2.9, 0.65, 15, ROCK } } do
			B:block(soil, v(s[4] * 1.35, s[4], s[4] * 1.05), cf(s[1], s[2], s[3], jit(6), s[5], jit(6)), s[6], S)
		end
		B:block(soil, v(0.9, 0.5, 0.8), cf(4.9, 1.85, 2.6, 0, 40, 0), ROCK_LT, S)
		-- dry grass tufts (3-blade)
		for _, g in { { 6.2, -1.8 }, { -2.6, 6.1 }, { -6.3, 1.2 }, { 3.0, -5.9 }, { -3.6, -3.4, 1.5 }, { 1.0, 3.9, 1.5 } } do
			local y = g[3] or 0
			B:block(soil, v(0.35, 1.2, 0.35), cf(g[1], y + 0.6, g[2], 0, jit(30), -8), GRASS, S)
			B:block(soil, v(0.3, 0.85, 0.3), cf(g[1] + 0.35, y + 0.42, g[2] + 0.2, 0, jit(30), 14), GRASS_DK, S)
			B:block(soil, v(0.28, 0.95, 0.28), cf(g[1] - 0.3, y + 0.47, g[2] - 0.15, 10, jit(30), 0), GRASS_LT, S)
		end
		-- pebbles + shells
		for _, p in { { 4.6, -3.4, 0.82, PEB }, { -1.5, -5.4, 0.82, PEB_LT }, { -5.0, 3.6, 0.82, PEB }, { 3.4, 1.8, 1.52, PEB_LT }, { -2.9, -1.9, 1.52, PEB } } do
			B:block(soil, v(0.5, 0.32, 0.42), cf(p[1], p[3] + 0.14, p[2], 0, jit(40), 0), p[4], S)
		end
		for _, p in { { 1.8, -5.5, 0.82, SHELL }, { -4.4, -1.0, 1.52, SHELL_PK }, { 5.2, 3.8, 0.82, SHELL_PK } } do
			B:block(soil, v(0.55, 0.22, 0.45), cf(p[1], p[3] + 0.1, p[2], 0, jit(40), 0), p[4], S)
			B:block(soil, v(0.3, 0.2, 0.25), cf(p[1], p[3] + 0.22, p[2], 0, jit(40), 0), SHELL, S)
		end
		-- tiny cactus sprout with a pink bud
		do
			local x, y, z = -3.8, 1.5, 2.3
			B:block(soil, v(0.55, 1.3, 0.55), cf(x, y + 0.65, z), CAC, S)
			B:block(soil, v(0.35, 0.6, 0.35), cf(x + 0.42, y + 0.7, z), CAC_DK, S)
			B:block(soil, v(0.32, 0.45, 0.32), cf(x + 0.52, y + 1.05, z), CAC_DK, S)
			B:block(soil, v(0.3, 0.25, 0.3), cf(x, y + 1.42, z, 0, 45, 0), "#ff7fb0", S)
		end
		-- a fallen mango in the sand
		do
			local c = cf(-1.6, 1.5 + 0.55, -3.3, 0, 30, 80)
			B:block(soil, v(1.2, 1.5, 1.05), c, M_ORG, S)
			B:block(soil, v(1.28, 0.7, 1.13), c * CFrame.new(0, -0.45, 0), M_RED, S)
			B:block(soil, v(1.28, 0.45, 1.13), c * CFrame.new(0, 0.55, 0), M_YEL, S)
			B:block(soil, v(0.18, 0.4, 0.18), c * CFrame.new(0, 0.95, 0), STEM, S)
		end

		------------------------------------------------------------------
		-- TRUNK + BRANCHES (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		local trunk = {
			v(0, TOP - 0.3, 0),
			v(0.35, 4.2, 0.15),
			v(0.1, 6.0, -0.1),
			v(-0.3, 7.6, 0.05),
		}
		for i = 1, #trunk - 1 do
			local w = 2.4 - (i - 1) * 0.25
			B:bar(crop, trunk[i], trunk[i + 1], w, w, (i % 2 == 1) and BARK or BARK_DK)
			B:block(crop, v(w + 0.25, 0.5, w + 0.25), CFrame.new(trunk[i + 1]) * ang(0, i * 30, 0), BARK_LT)
		end
		-- bark plates / knots
		B:block(crop, v(0.6, 1.2, 0.4), cf(0.6, 4.5, -1.15, 0, 0, 5), BARK_LT)
		B:block(crop, v(0.5, 0.9, 0.4), cf(-1.15, 5.6, 0.3, 0, 90, -4), BARK_DK)
		B:block(crop, v(0.5, 0.5, 0.35), cf(0.2, 3.3, 1.3, 0, 0, 0), BARK_DK)
		-- root flares onto the sand
		B:block(crop, v(3.0, 0.8, 3.0), cf(0, TOP + 0.25, 0, 0, 15, 0), BARK_DK)
		for k = 0, 4 do
			local a = k * 72 + 20
			B:bar(crop, pv(0.9, a, TOP + 0.9), pv(2.4, a + 8, TOP - 0.1), 0.9, 0.7, BARK)
			B:bar(crop, pv(2.2, a + 8, TOP + 0.1), pv(3.1, a + 14, TOP - 0.3), 0.6, 0.5, BARK_DK)
		end

		-- the acacia vase: crooked branches reaching out to the canopy underside
		local FORK = trunk[#trunk]
		local CY = 14.1 -- canopy underside
		local branchTips = {}
		local function branch(deg, r1, y1, r2, y2, w)
			local m = pv(r1, deg, y1)
			local t = pv(r2, deg + 12, y2)
			B:bar(crop, FORK + v(0, -0.4, 0), m, w, w, BARK)
			B:block(crop, v(w + 0.2, w + 0.2, w + 0.2), CFrame.new(m) * ang(0, deg, 0), BARK_DK)
			B:bar(crop, m, t, w * 0.8, w * 0.8, BARK_LT)
			table.insert(branchTips, { p = t, deg = deg + 12 })
			return m, t
		end
		local m1 = branch(0, 2.4, 10.4, 4.8, CY + 0.4, 1.3)
		local m2 = branch(125, 2.6, 10.0, 5.2, CY + 0.3, 1.25)
		local m3 = branch(240, 2.5, 10.8, 4.6, CY + 0.5, 1.25)
		-- small secondary twigs splitting off mid-branch
		B:bar(crop, m1, pv(3.0, 60, CY + 0.2), 0.7, 0.7, BARK)
		B:bar(crop, m2, pv(2.6, 180, CY + 0.2), 0.7, 0.7, BARK)
		B:bar(crop, m3, pv(3.4, 300, CY + 0.2), 0.7, 0.7, BARK)
		B:bar(crop, FORK, v(-0.2, CY + 0.5, 0.2), 1.1, 1.1, BARK_DK)

		------------------------------------------------------------------
		-- FLAT UMBRELLA CANOPY
		------------------------------------------------------------------
		local function leaf(p, sx, sy, sz, yaw, tilt, col)
			return B:block(crop, v(sx, sy, sz), CFrame.new(p) * ang(0, yaw, 0) * ang(tilt, 0, jit(6)), col)
		end
		-- outermost overhang: thin slabs drooping outward (the umbrella brim)
		local brimN = 14
		for i = 0, brimN - 1 do
			local a = i * 360 / brimN + 8 + jit(5)
			local sx = 3.4 + rnd() * 0.6
			leaf(pv(8.6 + jit(0.4), a, CY + 0.55 + jit(0.15)), sx, 1.5, 3.2, -a + jit(10), 14 + jit(4), pick({ LF_DK, LF_DK, LF }))
		end
		-- main wide slab: outer ring, mid ring, centre (flat, low)
		local outerN = 11
		for i = 0, outerN - 1 do
			local a = i * 360 / outerN + jit(6)
			local s = 4.2 + rnd() * 0.8
			leaf(pv(6.4 + jit(0.4), a, CY + 1.0 + jit(0.2)), s, 2.2, s, -a + jit(15), 6 + jit(4), pick({ LF, LF_DK, LF }))
		end
		local midN = 8
		for i = 0, midN - 1 do
			local a = i * 360 / midN + 20 + jit(6)
			local s = 4.4 + rnd() * 0.7
			leaf(pv(3.7 + jit(0.4), a, CY + 1.35 + jit(0.15)), s, 2.4, s, -a + jit(20), 3 + jit(3), pick({ LF, LF_MID, LF }))
		end
		leaf(v(0, CY + 1.5, 0), 5.0, 2.5, 5.0, 15, 0, LF_MID)
		-- a few lighter leaf cubes breaking the flat top (rotated, chunky)
		for i = 0, 6 do
			local a = i * 360 / 7 + 35
			local s = 2.2 + rnd() * 0.5
			B:block(crop, v(s, s * 0.8, s), CFrame.new(pv(6.0 + jit(0.5), a, CY + 2.4)) * ang(jit(15), -a + jit(30), jit(15)), pick({ LF_MID, LF_LT }))
		end
		-- underside shadow layer (so the bottom view looks dense, darker)
		for i = 0, 5 do
			local a = i * 60 + 5
			leaf(pv(5.0, a, CY + 0.1), 3.8, 0.7, 3.8, -a + jit(15), 0, LF_DK)
		end
		-- second, smaller top tier (low, keeps the flat-top silhouette)
		local TY = CY + 3.0
		for i = 0, 4 do
			local a = i * 72 + 10 + jit(6)
			local s = 3.4 + rnd() * 0.6
			leaf(pv(2.4 + jit(0.3), a, TY + jit(0.15)), s, 1.9, s, -a + jit(20), 4 + jit(3), pick({ LF_MID, LF_LT, LF_MID }))
		end
		leaf(v(0.2, TY + 0.4, -0.1), 3.6, 2.0, 3.6, 40, 0, LF_LT)
		-- sun-bleached highlights on top
		for i = 0, 2 do
			local a = i * 120 + 50
			B:block(crop, v(1.9, 1.3, 1.9), CFrame.new(pv(1.4, a, TY + 1.3)) * ang(jit(12), -a + jit(30), jit(12)), LF_TOP)
		end
		-- a few sun-dried golden leaves for savanna flavour
		for _, g in { { 70, 8.4, CY + 1.3 }, { 210, 8.2, CY + 1.3 }, { 330, 4.4, CY + 2.6 }, { 140, 6.7, CY + 2.3 } } do
			B:block(crop, v(1.9, 1.2, 1.9), CFrame.new(pv(g[2], g[1], g[3])) * ang(jit(12), -g[1] + 20, jit(12)), LF_GOLD)
		end

		------------------------------------------------------------------
		-- MANGOES
		------------------------------------------------------------------
		local function mango(F, s, glint)
			-- F: centre frame, local +Y up (stem end). Red blush cheek on +X,
			-- sun-gold shoulder on -X, beak tip low on the blush side.
			B:block(crop, v(1.5 * s, 2.4 * s, 1.3 * s), F, M_ORG)
			B:block(crop, v(1.95 * s, 1.5 * s, 1.5 * s), F * CFrame.new(0, -0.1 * s, 0), M_ORG)
			B:block(crop, v(0.8 * s, 1.8 * s, 1.62 * s), F * CFrame.new(0.62 * s, -0.3 * s, 0), M_RED)
			B:block(crop, v(0.7 * s, 1.2 * s, 1.6 * s), F * CFrame.new(-0.66 * s, 0.4 * s, 0), M_YEL)
			B:block(crop, v(0.9 * s, 0.55 * s, 0.9 * s), F * CFrame.new(0.3 * s, -1.35 * s, 0), M_RED_DK)
			B:block(crop, v(1.0 * s, 0.35 * s, 0.9 * s), F * CFrame.new(-0.1 * s, 1.3 * s, 0), M_GRN)
			if glint then
				B:block(crop, v(0.32 * s, 0.32 * s, 0.12 * s), F * CFrame.new(-0.45 * s, 0.5 * s, -0.84 * s), HI, { mat = "Neon", name = "MangoGlint" })
			end
		end
		local function hanging(deg, r, len, s, glint)
			local top = pv(r, deg, CY + 0.3)
			local bot = top + v(jit(0.3), -len, jit(0.3))
			B:bar(crop, top, bot + v(0, 1.2 * s, 0), 0.22, 0.22, STEM)
			-- two little leaves at the stem top
			B:block(crop, v(1.2, 0.18, 0.55), CFrame.new(top + v(0, -0.5, 0)) * ang(0, -deg + 30, -25) * CFrame.new(0.5, 0, 0), LF_MID)
			B:block(crop, v(1.1, 0.18, 0.5), CFrame.new(top + v(0, -0.7, 0)) * ang(0, -deg + 210, -25) * CFrame.new(0.5, 0, 0), LF)
			local F = CFrame.new(bot) * ang(0, -deg + jit(30), 0) * ang(jit(8), 0, 10 + jit(6))
			mango(F, s, glint)
		end
		hanging(15, 8.6, 2.6, 1.12, true)
		hanging(55, 3.8, 1.8, 1.01, true)
		hanging(95, 8.9, 3.0, 1.18, true)
		hanging(140, 4.2, 2.3, 1.06, true)
		hanging(180, 8.7, 2.4, 1.12, true)
		hanging(222, 3.6, 2.9, 1.01, true)
		hanging(262, 8.8, 2.0, 1.12, true)
		hanging(305, 4.0, 2.5, 1.06, true)
		hanging(340, 8.5, 3.2, 1.12, true)
		hanging(40, 6.4, 2.2, 1.0, false)
		hanging(300, 6.7, 1.9, 1.0, false)
		hanging(200, 6.2, 1.6, 0.95, false)
		hanging(130, 6.6, 1.8, 0.95, true)
		-- mangoes peeking out of the canopy top (readable from above)
		for _, m in { { 30, 5.2, CY + 2.7 }, { 150, 5.0, CY + 2.7 }, { 270, 5.3, CY + 2.6 }, { 210, 6.6, CY + 2.4 }, { 85, 6.8, CY + 2.4 }, { 100, 2.3, TY + 1.5 }, { 300, 2.2, TY + 1.5 } } do
			local F = CFrame.new(pv(m[2], m[1], m[3])) * ang(0, -m[1], 0) * ang(-15, 0, 12)
			mango(F, 0.9, false)
		end

		-- a little weaver-bird nest hanging from the canopy rim (savanna charm)
		do
			local NEST, NEST_DK, NEST_LT = "#cfae55", "#a8863a", "#e6cc78"
			local top = pv(8.0, 205, CY + 0.2)
			local c = top + v(0, -2.6, 0)
			B:bar(crop, top, c + v(0, 1.0, 0), 0.25, 0.25, NEST_DK)
			B:block(crop, v(1.5, 1.7, 1.5), CFrame.new(c) * ang(0, 20, 0), NEST)
			B:block(crop, v(1.25, 0.6, 1.25), CFrame.new(c + v(0, 1.05, 0)) * ang(0, 35, 0), NEST_LT)
			B:block(crop, v(0.95, 0.7, 0.95), CFrame.new(c + v(0, -1.1, 0)) * ang(0, 5, 0), NEST_DK)
			B:block(crop, v(0.6, 0.6, 0.2), CFrame.new(c) * ang(0, -205 + 20, 0) * CFrame.new(0, -0.3, -0.72), "#3a2414")
			B:block(crop, v(1.62, 0.25, 1.62), CFrame.new(c + v(0, 0.3, 0)) * ang(0, 20, 0), NEST_DK)
		end

		------------------------------------------------------------------
		-- VFX: falling acacia leaves, warm golden motes, soft mango glow
		------------------------------------------------------------------
		local leafZone = B:block(crop, v(14, 1, 14), cf(0, CY - 0.6, 0), LF, { tr = 1, name = "LeafZone" })
		B:emitter(leafZone, "leaf", { name = "FallingLeaves", color = { LF_LT, LF_MID, LF_GOLD }, rate = 1.0, size = { 0.45, 0.45, 0.3 }, life = { 3.5, 5.0 }, speed = { 0.3, 0.8 }, accel = { 0.35, -1.2, 0 }, dir = "Bottom" })
		local moteZone = B:block(crop, v(16, 8, 16), cf(0, CY - 1.5, 0), M_YEL, { tr = 1, name = "MoteZone" })
		B:emitter(moteZone, "sparkle", { name = "SunMotes", color = { "#ffe27a", "#fff3c0", "#ffb35c" }, rate = 4, size = { 0.12, 0.4, 0 }, life = { 1.4, 2.6 }, speed = { 0.15, 0.5 } })
		B:light(leafZone, { name = "MangoLight", color = "#ffb066", brightness = 0.9, range = 14 })
	end,
}
