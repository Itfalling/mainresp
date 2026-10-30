--!nocheck
-- Thornback Pear Tree (Thorny Woods crop #5, Legendary).
-- A tall, slender enchanted pear tree in the stud-tree style:
-- * stepped forest-dirt mound (bone "Soil") with chunky edge blocks, moss
--   pads, fallen autumn leaves, stones, little tan mushrooms, a thorny twig
--   and a fallen golden pear
-- * a tall slender dark-bark trunk with gnarled roots, studded with cream
--   thorns, and thorny branches reaching out under the canopy
-- * a tall upright oval canopy of big rotated emerald leaf cubes with
--   thorny branch tips poking out of it
-- * plump stepped golden pears with a rosy blush hanging from the branches
--   and peeking out of the leaves
-- * a golden thorn CROWN on the very top cradling the biggest pear
-- Gold sparkle motes, a few drifting leaves, one soft golden light.
-- Static prop: no motion.luau.
return {
	DisplayName = "Thornback Pear Tree",
	Rarity = "Legendary",
	Element = "Forest",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Thorny Woods) ---------------------------------------
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local MOSS, MOSS_DK = "#5fae3a", "#3f8a2c"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8a80", "#a5a197", "#686660"
		local FALL, FALL_DK, FALL_LT = "#c98a2e", "#a8582a", "#dcae3e"
		local MUSH_STEM, MUSH_CAP, MUSH_CAP_DK = "#efe3c8", "#b8743c", "#8f5428"
		local BARK_DK, BARK, BARK_LT = "#33211a", "#4a3022", "#634230"
		local THORN_B, THORN = "#7a3b2e", "#f2dcb4"
		local LF_DK, LF, LF_MID, LF_LT, LF_TOP = "#1f8446", "#29a052", "#38b860", "#5ccb6c", "#a2e06a"
		local GOLD_DK, GOLD, GOLD_LT = "#d29a1c", "#f2c230", "#ffe06a"
		local BLUSH, BLUSH_LT = "#e2583c", "#f2875a"
		local STALK = "#5a3a20"
		local CROWN, CROWN_DK = "#f0a81c", "#b8760e"
		local SHINE = "#fff6c8"
		local BLOSSOM, BLOSSOM_C = "#fff0f4", "#ff8fb0"

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
		-- polar: deg 0 = front (-Z), clockwise seen from above toward +X
		local function polar(r, deg)
			local a = rad(deg)
			return math.sin(a) * r, -math.cos(a) * r
		end
		local function pv(r, deg, y)
			local x, z = polar(r, deg)
			return v(x, y, z)
		end
		-- CFrame whose local -Z faces outward along polar `deg`
		local function facing(p, deg)
			return CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
		end

		------------------------------------------------------------------
		-- STEPPED FOREST MOUND (bone "Soil", parts named "Soil")
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
		disc(0, 0.8, 5.2, DIRT_DK)
		edge(0, 0.8, 5.25, 14, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.45, { 1.7, 2.4 }, { 1.3, 1.8 })
		disc(0.8, 0.7, 3.8, DIRT)
		edge(0.8, 0.7, 3.85, 10, { DIRT, DIRT_DK2, DIRT }, 0.35, { 1.6, 2.2 }, { 1.2, 1.6 })
		disc(1.5, 0.6, 2.5, DIRT_LT)
		local TOP = 2.1

		-- moss pads draped over tier edges
		for _, m in { { 20, 5.35, 0.85, 2.4, MOSS }, { 140, 5.35, 0.85, 2.0, MOSS_DK }, { 250, 5.35, 0.85, 2.3, MOSS }, { 85, 3.9, 1.55, 1.8, MOSS_DK }, { 200, 3.9, 1.55, 1.9, MOSS }, { 320, 2.6, 2.15, 1.5, MOSS } } do
			local c = facing(pv(m[2], m[1], m[3]), m[1])
			B:block(soil, v(m[4], 0.3, 1.3), c * ang(-14, 0, 0), m[5], S)
		end
		-- fallen autumn leaves (flat little squares)
		for _, f in { { 45, 4.5, 0.82 }, { 105, 4.6, 0.82 }, { 170, 4.3, 0.82 }, { 300, 4.6, 0.82 }, { 15, 3.1, 1.52 }, { 120, 3.0, 1.52 }, { 260, 3.2, 1.52 }, { 340, 2.0, 2.12 }, { 190, 1.8, 2.12 } } do
			B:block(soil, v(0.8, 0.12, 0.6), cf(0, 0, 0) * facing(pv(f[2], f[1], f[3]), f[1] + jit(40)), pick({ FALL, FALL_DK, FALL_LT }), S)
		end
		-- stones
		for _, s in { { 4.8, 1.05, -2.4, 0.9, 25, STONE }, { 5.4, 0.95, -1.1, 0.6, 10, STONE_LT }, { -4.8, 1.0, 2.6, 0.85, -20, STONE_DK }, { -2.5, 1.85, -2.9, 0.6, 15, STONE } } do
			B:block(soil, v(s[4] * 1.3, s[4], s[4]), cf(s[1], s[2], s[3], jit(8), s[5], jit(8)), s[6], S)
		end
		-- grass tufts
		for _, g in { { 6.1, 1.6 }, { -2.8, -5.8 }, { -6.0, -1.3 }, { 2.3, 6.0 } } do
			B:block(soil, v(0.45, 0.95, 0.45), cf(g[1], 0.48, g[2], 0, jit(30), 0), GRASS, S)
			B:block(soil, v(0.35, 0.65, 0.35), cf(g[1] + 0.32, 0.33, g[2] + 0.22, 0, jit(30), 0), GRASS_DK, S)
		end
		-- little tan mushrooms
		local function mush(x, y, z, s)
			B:block(soil, v(0.32 * s, 0.7 * s, 0.32 * s), cf(x, y + 0.35 * s, z), MUSH_STEM, S)
			B:block(soil, v(0.9 * s, 0.3 * s, 0.9 * s), cf(x, y + 0.75 * s, z, 0, 20, 0), MUSH_CAP, S)
			B:block(soil, v(0.55 * s, 0.22 * s, 0.55 * s), cf(x, y + 0.98 * s, z, 0, 35, 0), MUSH_CAP_DK, S)
		end
		mush(-3.0, 1.5, -2.0, 1.1)
		mush(-2.4, 1.5, -2.6, 0.75)
		mush(3.6, 0.8, 3.6, 1.0)
		-- a thorny twig lying on the mound
		do
			local a, b = v(2.2, 1.62, -3.2), v(4.3, 0.95, -2.1)
			B:bar(soil, a, b, 0.28, 0.28, BARK_LT, S)
			B:block(soil, v(0.14, 0.4, 0.14), CFrame.new(a:Lerp(b, 0.3) + v(0, 0.22, 0)) * ang(0, 0, -25), THORN, S)
			B:block(soil, v(0.14, 0.4, 0.14), CFrame.new(a:Lerp(b, 0.7) + v(0, 0.22, 0)) * ang(20, 0, 15), THORN, S)
		end
		-- a fallen golden pear
		do
			local c = cf(-3.1, 1.5 + 0.55, 1.8, 0, 30, 80)
			B:block(soil, v(1.25, 1.0, 1.0), c * CFrame.new(0, -0.35, 0), GOLD, S)
			B:block(soil, v(1.0, 1.02, 1.25), c * CFrame.new(0, -0.35, 0), GOLD, S)
			B:block(soil, v(0.7, 0.7, 0.7), c * CFrame.new(0, 0.45, 0), GOLD_LT, S)
			B:block(soil, v(0.6, 0.55, 0.15), c * CFrame.new(0.15, -0.3, -0.65), BLUSH, S)
			B:block(soil, v(0.16, 0.5, 0.16), c * CFrame.new(0, 0.95, 0), STALK, S)
		end

		------------------------------------------------------------------
		-- TRUNK (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		-- thorn: dark reddish base + cream point, sticking out along dir
		local function thorn(p, dir, len, w)
			dir = dir.Unit
			local m = p + dir * (len * 0.5)
			B:bar(crop, p - dir * 0.2, m, w, w, THORN_B)
			B:bar(crop, m - dir * 0.05, p + dir * len, w * 0.55, w * 0.55, THORN)
		end

		-- trunk column: slender stepped blocks with a slight zig-zag
		local col = {
			-- w, y0, h, x, z, yaw, colour
			{ 2.9, TOP - 0.1, 1.1, 0, 0, 8, BARK_DK },
			{ 2.3, TOP + 0.9, 2.3, 0.1, 0.0, -10, BARK },
			{ 2.0, TOP + 3.1, 2.3, 0.25, 0.1, 14, BARK_LT },
			{ 1.8, TOP + 5.3, 2.3, 0.05, 0.15, -6, BARK },
			{ 1.6, TOP + 7.5, 2.4, -0.15, 0.0, 18, BARK_LT },
			{ 1.4, TOP + 9.8, 2.6, 0.0, -0.1, -4, BARK },
			{ 1.2, TOP + 12.2, 2.6, 0.05, 0.0, 22, BARK_DK },
		}
		for _, c in col do
			B:block(crop, v(c[1], c[3], c[1]), cf(c[4], c[2] + c[3] / 2, c[5], 0, c[6], 0), c[7])
		end
		-- bark ridges for texture on the visible lower trunk
		for _, r in { { 30, 1.05, TOP + 2.2, 1.6 }, { 160, 1.0, TOP + 4.2, 1.8 }, { 270, 0.95, TOP + 6.2, 1.5 } } do
			B:block(crop, v(0.6, r[4], 0.4), facing(pv(r[2], r[1], r[3]), r[1]), BARK_DK)
		end
		-- moss collar at the foot
		B:block(crop, v(1.6, 0.5, 0.5), facing(pv(1.35, 200, TOP + 0.9), 200), MOSS)
		B:block(crop, v(1.2, 0.4, 0.5), facing(pv(1.3, 60, TOP + 0.7), 60), MOSS_DK)
		-- gnarled roots flaring down the mound
		for k = 0, 4 do
			local a = k * 72 + 30 + jit(8)
			B:bar(crop, pv(1.0, a, TOP + 0.9), pv(2.4, a + 8, TOP - 0.15), 1.0, 0.8, (k % 2 == 0) and BARK or BARK_DK)
			B:bar(crop, pv(2.3, a + 8, TOP - 0.1), pv(3.5, a + 14, TOP - 0.75), 0.7, 0.6, BARK_DK)
		end
		-- thorns spiralling up the visible trunk
		for i = 0, 7 do
			local deg = i * 137 + 20
			local y = TOP + 1.6 + i * 0.85
			local rr = (y < TOP + 3.1) and 1.15 or ((y < TOP + 5.3) and 1.0 or 0.9)
			local x, z = polar(1, deg)
			thorn(pv(rr, deg, y), v(x, 0.45, z), 1.45, 0.48)
		end

		------------------------------------------------------------------
		-- THORNY BRANCHES under the canopy (pears hang from their tips)
		------------------------------------------------------------------
		local pearSpots = {}
		local LOWB = {
			-- deg, start y, elbow r/y, tip r/y
			{ 35, TOP + 5.6, 2.6, TOP + 7.0, 5.2, TOP + 7.7 },
			{ 140, TOP + 6.3, 2.7, TOP + 7.6, 5.3, TOP + 8.2 },
			{ 235, TOP + 5.9, 2.6, TOP + 7.2, 5.1, TOP + 7.9 },
			{ 320, TOP + 6.6, 2.6, TOP + 7.9, 5.0, TOP + 8.6 },
		}
		for i, b in LOWB do
			local p0 = pv(0.5, b[1], b[2])
			local p1 = pv(b[3], b[1] + 8, b[4])
			local p2 = pv(b[5], b[1] - 4, b[6])
			B:bar(crop, p0, p1, 0.85, 0.85, BARK)
			B:bar(crop, p1, p2, 0.65, 0.65, BARK_LT)
			B:block(crop, v(0.85, 0.85, 0.85), CFrame.new(p1) * ang(0, b[1], 0), BARK)
			-- a thorn up and one down-out on each branch
			local d = (p2 - p0).Unit
			local side = d:Cross(v(0, 1, 0)).Unit
			thorn(p0:Lerp(p1, 0.55), v(0, 1, 0) + side * 0.4, 1.1, 0.4)
			thorn(p1:Lerp(p2, 0.45), side * -1 + v(0, 0.3, 0), 1.0, 0.38)
			-- little leaf tuft at the tip
			B:block(crop, v(1.0, 1.0, 1.0), CFrame.new(p2 + d * 0.2 + v(0, 0.2, 0)) * ang(jit(20), rnd() * 90, jit(20)), (i % 2 == 0) and LF_LT or LF_MID)
			table.insert(pearSpots, { p = p1:Lerp(p2, 0.78) + v(0, -0.15, 0), deg = b[1] - 2, s = 1.05 + (i % 2) * 0.08, shine = (i % 2 == 1) })
		end

		------------------------------------------------------------------
		-- TALL OVAL CANOPY: rings of big rotated emerald leaf cubes
		------------------------------------------------------------------
		local rings = {
			-- y, r, n, size, yaw offset, colours
			{ TOP + 9.5, 2.5, 6, 3.4, 0, { LF_DK, LF, LF_DK } },
			{ TOP + 11.2, 2.95, 7, 3.7, 26, { LF, LF_MID, LF_DK } },
			{ TOP + 13.0, 2.5, 6, 3.4, 8, { LF_MID, LF, LF_LT } },
			{ TOP + 13.9, 1.8, 4, 2.6, 45, { LF_LT, LF_MID, LF_TOP } },
		}
		local cubes = {}
		for ri, r in rings do
			for i = 0, r[3] - 1 do
				local deg = i * 360 / r[3] + r[5] + jit(6)
				local p = pv(r[2] + jit(0.25), deg, r[1] + jit(0.3))
				B:block(crop, v(r[4], r[4], r[4]), CFrame.new(p) * ang(jit(18), rnd() * 90, jit(18)), r[6][(i % #r[6]) + 1])
				table.insert(cubes, { p = p, s = r[4], deg = deg, ring = ri })
			end
		end
		B:block(crop, v(4.0, 4.0, 4.0), cf(0, TOP + 10.3, 0, 8, 20, -6), LF_DK)
		B:block(crop, v(3.8, 3.8, 3.8), cf(0, TOP + 12.2, 0, -6, 50, 10), LF)
		B:block(crop, v(3.0, 3.0, 3.0), cf(0.1, TOP + 13.5, 0.1, 10, 15, 5), LF_MID)
		-- lime "sun-lit" caps on the upper shoulders
		for _, c in { { 60, 2.4, TOP + 13.8, 1.7 }, { 190, 2.5, TOP + 13.6, 1.8 }, { 300, 2.3, TOP + 13.9, 1.6 } } do
			B:block(crop, v(c[4], c[4], c[4]), CFrame.new(pv(c[2], c[1], c[3])) * ang(jit(15), rnd() * 90, jit(15)), LF_TOP)
		end

		-- little pink-white pear blossoms dotted over the leaves
		for i, c in cubes do
			if c.ring >= 2 and (i % 2 == 0) then
				local a = rad(c.deg + 14)
				local out = v(math.sin(a), 0, -math.cos(a))
				local bp = c.p + out * (c.s * 0.52) + v(0, c.s * 0.22, 0)
				local F = CFrame.new(bp) * CFrame.Angles(0, -a, 0) * ang(-60, 0, 0)
				B:block(crop, v(1.4, 0.3, 0.6), F, BLOSSOM)
				B:block(crop, v(0.6, 0.31, 1.4), F, BLOSSOM)
				B:block(crop, v(0.48, 0.4, 0.48), F * CFrame.new(0, 0.08, 0), BLOSSOM_C)
			end
		end

		-- thorny branch tips poking out through the leaves
		for _, t in { { 10, TOP + 11.6 }, { 100, TOP + 10.0 }, { 175, TOP + 12.2 }, { 255, TOP + 10.4 }, { 330, TOP + 13.2 } } do
			local a = pv(2.0, t[1], t[2] - 0.9)
			local b = pv(5.7, t[1] + 6, t[2] + 0.6)
			B:bar(crop, a, b, 0.6, 0.6, BARK_LT)
			local d = (b - a).Unit
			thorn(b - d * 0.1, d + v(0, 0.5, 0), 1.2, 0.4)
			local side = d:Cross(v(0, 1, 0)).Unit
			thorn(a:Lerp(b, 0.8), side + v(0, 0.4, 0), 1.0, 0.36)
		end

		------------------------------------------------------------------
		-- GOLDEN PEARS: stepped bulb, rosy blush, brown stalk, leaf
		-- top = stalk attachment, the pear hangs below it.
		------------------------------------------------------------------
		local pearN = 0
		local function pear(top, deg, s, shine)
			pearN += 1
			local F = facing(top, deg)
			local function at(x, y, z)
				return F * CFrame.new(x * s, y * s, z * s)
			end
			B:block(crop, v(0.22 * s, 0.9 * s, 0.22 * s), at(0.05, -0.3, 0) * ang(0, 0, 12), STALK)
			B:block(crop, v(0.95 * s, 0.14, 0.55 * s), at(0.45, -0.35, 0) * ang(0, 20, -28), LF_LT)
			B:block(crop, v(0.72 * s, 0.75 * s, 0.72 * s), at(0, -1.0, 0) * ang(0, 45, 0), GOLD_LT)
			B:block(crop, v(1.1 * s, 0.8 * s, 1.1 * s), at(0, -1.6, 0), GOLD)
			B:block(crop, v(1.6 * s, 1.3 * s, 1.25 * s), at(0, -2.55, 0), GOLD)
			B:block(crop, v(1.25 * s, 1.32 * s, 1.6 * s), at(0, -2.55, 0), GOLD)
			B:block(crop, v(1.05 * s, 0.32 * s, 1.05 * s), at(0, -3.27, 0) * ang(0, 45, 0), GOLD_DK)
			B:block(crop, v(0.85 * s, 0.75 * s, 0.2 * s), at(0.18, -2.4, -0.82), BLUSH)
			B:block(crop, v(0.4 * s, 0.35 * s, 0.22 * s), at(0.3, -2.25, -0.84), BLUSH_LT)
			if shine then
				B:block(crop, v(0.22 * s, 0.42 * s, 0.12 * s), at(-0.48, -2.3, -0.86), SHINE, { mat = "Neon", name = "PearShine" })
			end
		end
		for _, ps in pearSpots do
			pear(ps.p, ps.deg, ps.s, ps.shine)
		end
		-- pears peeking out of the canopy (hung between the leaf cubes)
		for i, c in { { 75, 4.6, TOP + 10.3, 0.95 }, { 190, 4.7, TOP + 10.5, 0.92 }, { 285, 4.6, TOP + 10.4, 0.95 }, { 125, 4.2, TOP + 12.3, 0.8 }, { 10, 4.2, TOP + 12.1, 0.82 }, { 240, 3.8, TOP + 13.5, 0.74 } } do
			pear(pv(c[2], c[1], c[3]), c[1], c[4], i == 2 or i == 5)
		end

		------------------------------------------------------------------
		-- GOLDEN THORN CROWN on the top, cradling the biggest pear
		------------------------------------------------------------------
		local CY = TOP + 15.3
		B:ring(crop, CFrame.new(0, CY, 0), 1.45, 8, v(1.3, 0.6, 0.5), CROWN)
		B:ring(crop, CFrame.new(0, CY - 0.45, 0) * CFrame.Angles(0, rad(22.5), 0), 1.35, 8, v(1.2, 0.35, 0.45), CROWN_DK)
		for i = 0, 7 do
			local a = i * 45 + 22.5
			local tall = (i % 2 == 0)
			local h = tall and 0.85 or 0.5
			local F = facing(pv(1.55, a, CY + 0.25), a) * ang(-25, 0, 0)
			B:block(crop, v(0.75, h, 0.45), F * CFrame.new(0, h / 2, 0), CROWN)
			B:block(crop, v(0.42, 0.5, 0.36), F * CFrame.new(0, h + 0.2, 0), CROWN_DK)
			if tall then
				B:block(crop, v(0.2, 0.42, 0.2), F * CFrame.new(0, h + 0.6, 0), THORN)
			end
			if i % 2 == 0 then
				B:block(crop, v(0.4, 0.4, 0.3), CFrame.new(pv(1.78, a, CY)) * ang(0, -a, 0) * CFrame.new(0, 0, -0.12), "#ff3d5e", { mat = "Neon" })
			end
		end
		-- the crown pear (big, upright, with a leaf pair)
		local CP = v(0, CY + 4.1, 0)
		pear(CP, 0, 1.2, true)
		B:block(crop, v(1.3, 0.16, 0.7), CFrame.new(CP + v(-0.55, -0.2, 0)) * ang(0, -20, 28), LF_TOP)
		local core = B:block(crop, v(0.4, 0.4, 0.4), CFrame.new(CP + v(0, -2.6, 0)), GOLD, { tr = 1, name = "CrownCore" })
		B:emitter(core, "glow", { name = "CrownGlow", color = { GOLD_LT, "#fff1a8" }, rate = 1.2, size = { 1.8, 2.6, 0 }, trans = { 0.75, 0.65, 1 } })
		B:light(core, { name = "CrownLight", color = "#ffd76a", brightness = 1.2, range = 14 })

		------------------------------------------------------------------
		-- VFX: golden sparkle motes + a few drifting leaves
		------------------------------------------------------------------
		local motes = B:block(crop, v(11, 8, 11), cf(0, TOP + 11.5, 0), LF, { tr = 1, name = "MoteZone" })
		B:emitter(motes, "sparkle", { name = "GoldMotes", color = { "#ffe57a", "#fff6c8", "#ffd23a" }, rate = 5, size = { 0.15, 0.45, 0.05 }, life = { 1.4, 2.6 }, speed = { 0.2, 0.6 } })
		local lz = B:block(crop, v(8, 1, 8), cf(0, TOP + 8.0, 0), LF, { tr = 1, name = "LeafZone" })
		B:emitter(lz, "leaf", { name = "FallingLeaves", color = { LF_LT, LF_TOP, FALL_LT }, rate = 0.8, size = 0.35 })
	end,
}
