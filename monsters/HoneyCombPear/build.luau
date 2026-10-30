--!nocheck
-- Honeycomb Pear Tree (Honey Hills crop #5, Legendary).
-- A plump, sunny pear tree in the stud-tree style:
-- * stepped GRASSY meadow mound (bone "Soil"): warm soil tiers capped with
--   grass, tiny pink / lavender / white wildflowers, clover, pebbles, a
--   glossy honey puddle (fed by the pear dripping above it) and a wooden
--   honey dipper stuck in the grass
-- * a stout warm-brown trunk with flared roots and branches reaching out
--   under a round canopy of big rotated leaf cubes dotted with pink blossoms
-- * the pears ARE honeycomb: every pear is a stack of hexagonal prisms
--   (neck -> shoulder -> big bulb -> base), golden wax with amber cell
--   openings staggered around the bulb, a stalk + leaf, and a honey drip
--   with a glowing drop hanging from its bottom
-- * a honeycomb CROWN on top: a ring of stepped hex cells cradling the
--   biggest pear, honey oozing over the leaves
-- * two cute block bees visiting the tree
-- VFX: honey drips falling from the pears, golden pollen sparkles, a warm
-- glow + soft light at the crown.
-- Static prop: no motion.luau.
return {
	DisplayName = "Honeycomb Pear Tree",
	Rarity = "Legendary",
	Element = "Nature",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local SQ3 = math.sqrt(3)

		-- palette (Honey Hills) -------------------------------------------
		local SOIL_DK, SOIL, SOIL_LT = "#6b4226", "#875533", "#a06a40"
		local GR_DK, GR, GR_LT, GR_XL = "#7cae32", "#97c83e", "#b2d84c", "#d2e872"
		local CLOVER, CLOVER_DK = "#3f9a3c", "#2f7f30"
		local PEB, PEB_LT = "#a49a8c", "#c4bcae"
		local FL_PINK, FL_LAV, FL_WHITE, FL_EYE = "#ff9cc4", "#c7a2ff", "#fff6fa", "#ffc93a"
		local BARK_DK, BARK, BARK_LT = "#5a3720", "#74472a", "#8f5c36"
		local LF_DK, LF, LF_MID, LF_LT, LF_TOP = "#46a83a", "#5dbd40", "#76cc48", "#95da55", "#bce86e"
		local BLOSSOM, BLOSSOM_C = "#ffe3ef", "#ff86b4"
		local WAX_LT, WAX, WAX_DK = "#ffe27a", "#ffc93c", "#e8a020"
		local CELL, CELL_DK = "#c87410", "#a65a0c"
		local HONEY, HONEY_LT, HONEY_GLOW = "#ffa318", "#ffc54a", "#ffb52e"
		local STALK = "#5a3a20"
		local BEE_Y, BEE_K, WING = "#ffd23a", "#2a2126", "#f4fbff"
		local DIP, DIP_DK = "#c99a62", "#9f7444"

		local seed = 16511
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
		local function facing(p, deg)
			return CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
		end
		-- hexagonal prism (pointy at local +-X) = 3 blocks at 0/60/120 deg
		local function hex(bone, c, R, h, col, opts)
			for k = 0, 2 do
				B:block(bone, v(R, h, R * SQ3), c * CFrame.Angles(0, rad(k * 60), 0), col, opts)
			end
		end

		------------------------------------------------------------------
		-- STEPPED GRASSY MOUND (bone "Soil", parts named "Soil")
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
		-- tier 1: soil skirt + grass cap
		disc(0, 0.6, 6.2, SOIL_DK)
		edge(0, 0.6, 6.25, 15, { SOIL_DK, SOIL, SOIL_DK }, 0.3, { 1.7, 2.4 }, { 1.2, 1.7 })
		disc(0.55, 0.35, 5.9, GR_DK)
		-- tier 2
		disc(0.9, 0.45, 4.4, SOIL)
		edge(0.9, 0.45, 4.45, 11, { GR, GR_DK, GR }, 0.3, { 1.6, 2.2 }, { 1.1, 1.5 })
		disc(1.3, 0.3, 4.15, GR)
		-- tier 3
		disc(1.6, 0.5, 2.7, GR_LT)
		local TOP = 2.1

		-- grass tufts (3 blades)
		for _, g in { { 6.3, -1.5 }, { -2.6, -5.9 }, { -6.1, 1.6 }, { 2.9, 5.7 } } do
			B:block(soil, v(0.35, 1.1, 0.35), cf(g[1], 0.95, g[2], 0, jit(30), -8), GR_LT, S)
			B:block(soil, v(0.3, 0.8, 0.3), cf(g[1] + 0.32, 0.82, g[2] + 0.2, 0, jit(30), 14), GR, S)
			B:block(soil, v(0.28, 0.9, 0.28), cf(g[1] - 0.3, 0.86, g[2] - 0.15, 10, jit(30), 0), GR_XL, S)
		end
		-- tiny wildflowers: stem + crossed petals + golden eye
		local function flower(x, y, z, col, s)
			s = s or 1
			B:block(soil, v(0.18, 0.7 * s, 0.18), cf(x, y + 0.35 * s, z), GR_DK, S)
			local yaw = rnd() * 90
			B:block(soil, v(0.75 * s, 0.18, 0.3 * s), cf(x, y + 0.72 * s, z, 0, yaw, 0), col, S)
			B:block(soil, v(0.3 * s, 0.19, 0.75 * s), cf(x, y + 0.72 * s, z, 0, yaw, 0), col, S)
			B:block(soil, v(0.24, 0.26, 0.24), cf(x, y + 0.78 * s, z, 0, yaw, 0), FL_EYE, S)
		end
		flower(5.0, 0.9, 1.6, FL_PINK)
		flower(-4.9, 0.9, -1.8, FL_LAV)
		flower(-1.2, 0.9, -5.4, FL_WHITE)
		flower(1.9, 0.9, -5.2, FL_PINK, 1.15)
		flower(-4.2, 0.9, 3.3, FL_PINK)
		flower(0.6, 0.9, 5.6, FL_LAV)
		-- clover: three round-ish leaflets on a short stem
		local function clover(x, y, z)
			local yaw = rnd() * 120
			for k = 0, 2 do
				local c = cf(x, y + 0.32, z, 0, yaw + k * 120, 0) * CFrame.new(0, 0, -0.3)
				B:block(soil, v(0.5, 0.14, 0.5), c * ang(0, 45, 0), (k == 0) and CLOVER_DK or CLOVER, S)
			end
		end
		clover(-5.4, 0.9, 0.0)
		clover(2.5, 1.6, 3.2)
		clover(5.5, 0.9, -2.6)
		clover(-3.4, 1.6, 1.4)
		-- pebbles
		for _, p in { { 4.0, 0.95, 4.0, PEB }, { -5.3, 0.95, -3.4, PEB_LT }, { -1.4, 1.62, 3.6, PEB }, { 5.7, 0.95, 0.6, PEB_LT } } do
			B:block(soil, v(0.6, 0.38, 0.5), cf(p[1], p[2], p[3], 0, jit(40), 0), p[4], S)
		end
		-- glossy honey puddle (front-right, under the dripping pear)
		do
			local px, pz = 3.0, -4.0
			B:block(soil, v(2.4, 0.14, 1.6), cf(px, 0.94, pz, 0, 20, 0), HONEY, S)
			B:block(soil, v(1.5, 0.16, 2.2), cf(px + 0.2, 0.95, pz - 0.1, 0, 35, 0), HONEY, S)
			B:block(soil, v(0.9, 0.17, 0.6), cf(px - 0.3, 0.97, pz + 0.1, 0, 20, 0), HONEY_LT, S)
			B:block(soil, v(0.32, 0.18, 0.32), cf(px + 0.5, 0.98, pz - 0.5, 0, 40, 0), "#fff0b8", S)
		end
		-- a wooden honey dipper stuck in the grass
		do
			local base = v(-3.9, 0.9, -3.2)
			local top = base + v(0.5, 2.3, -0.35)
			B:bar(soil, base, top, 0.25, 0.25, DIP, S)
			local d = (top - base).Unit
			local o = top - d * 0.9
			local ac = P.aim(o, o + d)
			local hc = CFrame.new(o) * (ac - ac.Position) * CFrame.Angles(-math.pi / 2, 0, 0)
			for k = 0, 2 do
				B:block(soil, v(0.62, 0.2, 0.62), hc * CFrame.new(0, -0.2 + k * 0.32, 0) * ang(0, k * 30, 0), (k == 1) and DIP_DK or DIP, S)
			end
			B:block(soil, v(0.45, 0.45, 0.45), hc * CFrame.new(0, -0.55, 0.0) * ang(0, 45, 0), HONEY_LT, S)
		end

		------------------------------------------------------------------
		-- TRUNK + BRANCHES (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		local col = {
			-- w, y0, h, x, z, yaw, colour
			{ 3.0, TOP - 0.1, 1.1, 0, 0, 10, BARK_DK },
			{ 2.5, TOP + 0.9, 2.0, 0.1, 0.0, -8, BARK },
			{ 2.2, TOP + 2.8, 2.0, 0.25, 0.1, 15, BARK_LT },
			{ 2.0, TOP + 4.7, 2.0, 0.1, 0.15, -5, BARK },
			{ 1.8, TOP + 6.6, 1.6, -0.1, 0.0, 20, BARK_LT },
		}
		for _, c in col do
			B:block(crop, v(c[1], c[3], c[1]), cf(c[4], c[2] + c[3] / 2, c[5], 0, c[6], 0), c[7])
		end
		for _, r in { { 30, 1.15, TOP + 2.0, 1.4 }, { 165, 1.1, TOP + 3.8, 1.6 }, { 275, 1.05, TOP + 5.4, 1.4 } } do
			B:block(crop, v(0.55, r[4], 0.4), facing(pv(r[2], r[1], r[3]), r[1]), BARK_DK)
		end
		-- roots flaring down the mound
		for k = 0, 4 do
			local a = k * 72 + 20 + jit(8)
			B:bar(crop, pv(1.0, a, TOP + 0.8), pv(2.5, a + 8, TOP - 0.2), 1.0, 0.8, (k % 2 == 0) and BARK or BARK_DK)
			B:bar(crop, pv(2.4, a + 8, TOP - 0.15), pv(3.5, a + 14, TOP - 0.8), 0.7, 0.6, BARK_DK)
		end
		local T2 = TOP - 0.8 -- canopy level (keeps the Legendary a notch shorter than the Mythic)

		------------------------------------------------------------------
		-- HONEYCOMB PEARS: stacked hex prisms, staggered amber cells,
		-- stalk + leaf, honey drip. `top` = stalk attachment point.
		------------------------------------------------------------------
		local dropTips = {}
		local function pear(top, deg, s, drop)
			local F = facing(top, deg)
			local function at(x, y, z)
				return F * CFrame.new(x * s, y * s, z * s)
			end
			B:block(crop, v(0.24 * s, 0.85 * s, 0.24 * s), at(0.05, -0.3, 0) * ang(0, 0, 12), STALK)
			B:block(crop, v(1.0 * s, 0.14, 0.5 * s), at(0.5, -0.32, 0) * ang(0, 20, -28), LF_LT)
			hex(crop, at(0, -1.0, 0) * ang(0, 30, 0), 0.5 * s, 0.75 * s, WAX)
			hex(crop, at(0, -1.65, 0), 0.82 * s, 0.6 * s, WAX_LT)
			hex(crop, at(0, -2.7, 0) * ang(0, 30, 0), 1.25 * s, 1.55 * s, WAX)
			hex(crop, at(0, -3.58, 0), 0.85 * s, 0.32 * s, WAX_DK)
			-- amber cell openings on the bulb's six faces, staggered like comb
			local apo = 1.25 * s * SQ3 / 2
			for k = 0, 5 do
				local yy = (k % 2 == 0) and -2.4 or -3.0
				local c = F * CFrame.Angles(0, rad(k * 60 + 30), 0) * CFrame.new(0, yy * s, -apo - 0.03)
				B:block(crop, v(0.82 * s, 0.6 * s, 0.1), c, (k % 2 == 0) and CELL or CELL_DK)
			end
			if drop then
				local d0 = at(0, -3.7, 0).Position
				B:block(crop, v(0.5 * s, 0.25, 0.5 * s), CFrame.new(d0 + v(0, 0.02, 0)) * ang(0, 45, 0), HONEY)
				B:block(crop, v(0.26 * s, 0.85 * s, 0.26 * s), CFrame.new(d0 - v(0, 0.4 * s, 0)), HONEY)
				local tip = d0 - v(0, 0.95 * s, 0)
				B:block(crop, v(0.42 * s, 0.42 * s, 0.42 * s), CFrame.new(tip) * ang(0, 45, 0), HONEY_GLOW, { mat = "Neon", name = "HoneyDrop" })
				table.insert(dropTips, tip)
			end
		end

		-- five branches fanning out under the canopy, a big pear on each
		local LOWB = {
			-- deg, start y, elbow r/y, tip r/y
			{ 15, T2 + 5.9, 2.7, T2 + 7.0, 5.3, T2 + 7.7 },
			{ 87, T2 + 6.5, 2.8, T2 + 7.6, 5.4, T2 + 8.3 },
			{ 160, T2 + 6.1, 2.7, T2 + 7.2, 5.3, T2 + 7.9 },
			{ 232, T2 + 6.6, 2.8, T2 + 7.7, 5.4, T2 + 8.4 },
			{ 304, T2 + 6.2, 2.7, T2 + 7.3, 5.2, T2 + 8.0 },
		}
		for i, b in LOWB do
			local p0 = pv(0.5, b[1], b[2])
			local p1 = pv(b[3], b[1] + 8, b[4])
			local p2 = pv(b[5], b[1] - 4, b[6])
			B:bar(crop, p0, p1, 0.9, 0.9, BARK)
			B:bar(crop, p1, p2, 0.65, 0.65, BARK_LT)
			B:block(crop, v(0.9, 0.9, 0.9), CFrame.new(p1) * ang(0, b[1], 0), BARK)
			local d = (p2 - p0).Unit
			B:block(crop, v(1.2, 1.2, 1.2), CFrame.new(p2 + d * 0.3 + v(0, 0.3, 0)) * ang(jit(20), rnd() * 90, jit(20)), (i % 2 == 0) and LF_LT or LF_TOP)
			pear(p1:Lerp(p2, 0.8) + v(0, -0.1, 0), b[1] - 2, 1.22, true)
		end

		------------------------------------------------------------------
		-- ROUND CANOPY: rings of big rotated leaf cubes (kept compact so
		-- the honeycomb pears below read clearly)
		------------------------------------------------------------------
		local rings = {
			-- y, r, n, size, yaw offset, colours
			{ T2 + 8.9, 2.7, 6, 3.3, 30, { LF_DK, LF, LF_DK } },
			{ T2 + 10.6, 3.2, 7, 3.5, 0, { LF, LF_MID, LF_DK } },
			{ T2 + 12.3, 2.5, 5, 3.2, 20, { LF_MID, LF, LF_LT } },
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
		B:block(crop, v(4.2, 3.8, 4.2), cf(0, T2 + 10.0, 0, 8, 20, -6), LF_DK)
		B:block(crop, v(4.0, 3.6, 4.0), cf(0, T2 + 12.0, 0, -6, 50, 10), LF)
		for _, c in { { 60, 2.0, T2 + 13.5, 1.7 }, { 180, 2.1, T2 + 13.3, 1.8 }, { 300, 1.9, T2 + 13.6, 1.6 } } do
			B:block(crop, v(c[4], c[4], c[4]), CFrame.new(pv(c[2], c[1], c[3])) * ang(jit(15), rnd() * 90, jit(15)), LF_TOP)
		end
		-- pink pear blossoms dotted over the leaves
		for i, c in cubes do
			if i % 2 == 0 then
				local a = rad(c.deg + 14)
				local out = v(math.sin(a), 0, -math.cos(a))
				local bp = c.p + out * (c.s * 0.52) + v(0, c.s * 0.22, 0)
				local F = CFrame.new(bp) * CFrame.Angles(0, -a, 0) * ang(-60, 0, 0)
				B:block(crop, v(1.3, 0.3, 0.55), F, BLOSSOM)
				B:block(crop, v(0.55, 0.31, 1.3), F, BLOSSOM)
				B:block(crop, v(0.45, 0.4, 0.45), F * CFrame.new(0, 0.08, 0), BLOSSOM_C)
			end
		end
		-- two smaller pears peeking out of the canopy
		pear(pv(3.9, 125, T2 + 11.7), 125, 0.85, false)
		pear(pv(3.9, 270, T2 + 11.9), 270, 0.85, false)

		------------------------------------------------------------------
		-- HONEYCOMB CROWN: ring of stepped hex cells around the top pear,
		-- honey oozing over the leaves
		------------------------------------------------------------------
		local CY = T2 + 13.9
		local cellR = 1.0
		hex(crop, CFrame.new(0, CY - 0.15, 0), 2.0, 0.6, WAX_DK)
		for i = 0, 5 do
			local a = i * 60 + 30
			local h = (i % 2 == 0) and 1.45 or 0.95
			local p = pv(1.73, a, CY + h / 2)
			local c = facing(p, a) * ang(0, 30, 0)
			hex(crop, c, cellR, h, (i % 2 == 0) and WAX or WAX_LT)
			-- dark cell opening on top
			B:block(crop, v(cellR * 0.95, 0.12, cellR * 0.95), c * CFrame.new(0, h / 2 + 0.02, 0) * ang(0, 45, 0), (i % 3 == 1) and HONEY_LT or CELL_DK)
		end
		-- honey oozing down from the crown over the leaf tops
		for _, o in { { 0, 2.7, 1.5 }, { 120, 2.6, 1.2 }, { 240, 2.7, 1.4 } } do
			local p = pv(o[2], o[1], CY - 0.1)
			B:block(crop, v(1.0, 0.35, 1.3), facing(p, o[1]) * ang(-35, 0, 0), HONEY)
			B:block(crop, v(0.55, o[3], 0.55), facing(p + pv(0.5, o[1], -o[3] / 2), o[1]), HONEY)
			B:block(crop, v(0.45, 0.45, 0.45), facing(p + pv(0.5, o[1], -o[3] - 0.1), o[1]), HONEY_LT)
		end
		-- the crown pear: big, upright, cradled by the cells
		local CP = v(0, CY + 5.1, 0)
		pear(CP, 0, 1.25, false)
		local core = B:block(crop, v(0.4, 0.4, 0.4), CFrame.new(CP + v(0, -2.8, 0)), WAX, { tr = 1, name = "CrownCore" })
		B:emitter(core, "glow", { name = "CrownGlow", color = { "#ffe27a", "#fff3b8" }, rate = 1.2, size = { 2.2, 3.0, 0 }, trans = { 0.75, 0.65, 1 } })
		B:light(core, { name = "HoneyLight", color = "#ffc85a", brightness = 1.2, range = 14 })

		------------------------------------------------------------------
		-- CUTE BLOCK BEES visiting the tree
		------------------------------------------------------------------
		local function bee(p, yaw, tilt)
			local F = CFrame.new(p) * CFrame.Angles(0, rad(yaw), 0) * ang(tilt, 0, 0)
			B:block(crop, v(0.95, 0.9, 1.3), F, BEE_Y)
			B:block(crop, v(0.99, 0.94, 0.26), F * CFrame.new(0, 0, 0.05), BEE_K)
			B:block(crop, v(0.99, 0.94, 0.22), F * CFrame.new(0, 0, 0.5), BEE_K)
			B:block(crop, v(0.8, 0.78, 0.5), F * CFrame.new(0, 0.02, -0.82), BEE_K)
			B:block(crop, v(0.18, 0.18, 0.3), F * CFrame.new(0, -0.1, 0.78), BEE_K)
			for sgn = -1, 1, 2 do
				B:block(crop, v(0.7, 0.08, 0.5), F * CFrame.new(sgn * 0.48, 0.6, -0.05) * ang(0, 0, sgn * 25), WING, { tr = 0.25 })
			end
		end
		bee(pv(7.0, 50, T2 + 9.6), 75, -8)
		bee(pv(5.6, 215, T2 + 14.6), 255, 6)

		------------------------------------------------------------------
		-- VFX: honey drips from the pears, golden pollen sparkles
		------------------------------------------------------------------
		for i, tp in dropTips do
			if i <= 5 then
				local z = B:block(crop, v(0.3, 0.2, 0.3), CFrame.new(tp - v(0, 0.2, 0)), HONEY, { tr = 1, name = "DripZone" .. i })
				B:emitter(z, "drip", { name = "HoneyDrip" .. i, color = { "#ffc23a", "#ff9a14" }, rate = 0.9 + (i % 2) * 0.3, size = { 0.34, 0.3, 0.16 }, life = { 0.5, 0.75 } })
			end
		end
		local motes = B:block(crop, v(11, 8, 11), cf(0, T2 + 11.0, 0), LF, { tr = 1, name = "PollenZone" })
		B:emitter(motes, "sparkle", { name = "PollenSparkle", color = { "#ffe57a", "#fff6c8", "#ffb0d0" }, rate = 5, size = { 0.15, 0.45, 0.05 }, life = { 1.4, 2.6 }, speed = { 0.2, 0.6 } })
	end,
}
