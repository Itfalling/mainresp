--!nocheck
-- Beehive Blossom Tree (Honey Hills crop #8, Cosmic, ANIMATED): a pink
-- blossom tree with a big striped beehive hanging from its bough while cute
-- block bees orbit around it.
-- * stepped Honey-Hills mound (bone "Soil", parts "Soil"): dark soil tiers
--   with golden-green turf caps, chunky sods, pastel wildflowers, clover,
--   pebbles, a honeycomb chunk and a glossy honey puddle under the hive
-- * a gently curving warm-brown trunk (bone "Crop") with roots and limbs
-- * a fluffy cherry-blossom canopy of big rotated studded cubes in pinks,
--   lavender and white (bones Canopy -> CanopyTop) dotted with little
--   five-petal blossoms
-- * the HIVE (bone "Hive", pivot at its stem): stepped striped gold dome
--   with a glowing entrance (neon HiveGlow), a second hole and honey drips
-- * four hanging honey-drop fruits (bones FruitN, pivot at the stem top,
--   neon cores FruitCoreN)
-- * seven block bees on orbit bones (BeeN, pivot = orbit centre, tilted
--   orbit planes): five circle the hive, two circle the whole canopy; each
--   has flapping wings (BeeNWR / BeeNWL) and a golden trail
-- * VFX: honey drips, honey burst, pollen sparkles, hive glow, falling
--   petals + petal burst, rising pollen motes; hive + canopy lights
-- Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Beehive Blossom Tree",
	Rarity = "Cosmic",
	Element = "Honey",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ------------------------------------------------------------
		local SOIL_DK, SOIL, SOIL_LT = "#5e3b22", "#7a4e2c", "#946239"
		local TURF_DK, TURF, TURF_LT, TURF_HI = "#86b83f", "#9cc94a", "#b3d65a", "#c9e06b"
		local HONEY_DK, HONEY, HONEY_LT, HONEY_HI = "#d9841a", "#f5a623", "#ffc94a", "#ffe28c"
		local COMB, COMB_DK = "#f2b632", "#b97a14"
		local PEB, PEB_LT = "#b3a894", "#ddd4c3"
		local CLOVER, CLOVER_DK = "#4fa040", "#3c8533"
		local FLOWERS = { { "#ff9ec7", "#ffe066" }, { "#c7a6ff", "#fff3a0" }, { "#fff4fa", "#ffcf3a" }, { "#ffd04a", "#ff9a3c" } }
		local BARK_DK, BARK, BARK_LT = "#5e3a26", "#7a4c30", "#9a6440"
		local PINK_DK, PINK, PINK_LT, PINK_HI = "#e47aa8", "#ff9cc4", "#ffbcd7", "#ffd9e8"
		local LAV, LAV_DK, WHITE = "#d6b4ff", "#b993ee", "#fff1f7"
		local HIVE_DK, HIVE, HIVE_LT = "#c97a14", "#ffbd33", "#ffd86b"
		local HOLE, GLOW = "#3a2412", "#ffb21f"
		local FRUIT_CORE = "#ffc93a"
		local BEE_Y, BEE_YD, BEE_K, WING = "#ffc21a", "#e59a0e", "#2a2230", "#ffffff"

		local seed = 8080808
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function polar(r, deg)
			local a = rad(deg)
			return math.sin(a) * r, -math.cos(a) * r
		end
		local function at(r, deg, y)
			local x, z = polar(r, deg)
			return v(x, y, z)
		end
		local function outward(deg)
			return at(1, deg, 0)
		end
		local function face(p, deg) -- frame at p whose -Z points outward along deg
			return CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
		end

		local HIVE_DEG, HIVE_R = 60, 6.4

		------------------------------------------------------------------
		-- MEADOW MOUND (bone "Soil", every part named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(y0, y1, w, color)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(soil, v(w, h, w * 0.62), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.62, h + 0.02, w), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.85, h - 0.03, w * 0.85), cf(0, y, 0, 0, 22.5, 0), color, S)
		end
		oct(0, 1.0, 17.0, SOIL_DK)
		oct(1.0, 1.35, 16.5, TURF_DK)
		oct(1.35, 2.25, 13.0, SOIL)
		oct(2.25, 2.6, 12.6, TURF)
		oct(2.6, 3.25, 8.8, SOIL_LT)
		oct(3.25, 3.55, 8.4, TURF_LT)
		local TOP = 3.55
		for i = 0, 15 do
			local a = i * 22.5 + jit(5)
			local x, z = polar(8.1 + jit(0.3), a)
			local h = 1.05 + rnd() * 0.5
			local yaw = -a + jit(10)
			local w, d = 2.6 + rnd() * 0.7, 1.9 + rnd() * 0.4
			B:block(soil, v(w, h, d), cf(x, h / 2, z, 0, yaw, 0), (i % 2 == 0) and SOIL_DK or SOIL, S)
			B:block(soil, v(w + 0.15, 0.32, d + 0.15), cf(x, h + 0.1, z, 0, yaw, 0), (i % 3 == 0) and TURF or TURF_DK, S)
		end
		for i = 0, 7 do
			local a = i * 45 + 20 + jit(8)
			if math.abs(a - HIVE_DEG) > 18 then
				local x, z = polar(6.2 + jit(0.3), a)
				local h = 0.7 + rnd() * 0.35
				local yaw = -a + jit(12)
				B:block(soil, v(2.2, h, 1.6), cf(x, 1.35 + h / 2, z, 0, yaw, 0), SOIL, S)
				B:block(soil, v(2.35, 0.3, 1.75), cf(x, 1.35 + h + 0.08, z, 0, yaw, 0), (i % 2 == 0) and TURF_LT or TURF, S)
			end
		end
		-- honey puddle right under the hive (the drips land here)
		do
			local c = at(6.3, HIVE_DEG, 2.6)
			B:block(soil, v(3.2, 0.16, 2.4), CFrame.new(c + v(0, 0.06, 0)) * ang(0, 20, 0), HONEY_DK, S)
			B:block(soil, v(2.5, 0.18, 2.9), CFrame.new(c + v(0.2, 0.08, -0.1)) * ang(0, -15, 0), HONEY, S)
			B:block(soil, v(1.9, 0.2, 1.5), CFrame.new(c + v(-0.2, 0.1, 0.1)) * ang(0, 40, 0), HONEY_LT, S)
			B:block(soil, v(0.8, 0.22, 0.4), CFrame.new(c + v(-0.4, 0.12, -0.5)) * ang(0, 30, 0), HONEY_HI, S)
		end
		local function hex(p, d, h, col, colTop)
			for k = 0, 2 do
				B:block(soil, v(d, h, d * 0.577), CFrame.new(p + v(0, h / 2, 0)) * ang(0, k * 60, 0), col, S)
			end
			B:block(soil, v(d * 0.62, 0.12, d * 0.62 * 0.577 * 1.6), CFrame.new(p + v(0, h + 0.03, 0)) * ang(0, 90, 0), colTop, S)
		end
		hex(v(-6.2, 1.35, 2.4), 1.5, 1.0, COMB, COMB_DK)
		hex(v(-6.6, 1.35, 1.15), 1.5, 0.7, HONEY_LT, COMB_DK)
		hex(v(-5.2, 1.35, 1.7), 1.5, 1.35, COMB, COMB_DK)
		local function stone(x, y, z, sc, yaw)
			B:block(soil, v(1.6 * sc, 0.8 * sc, 1.3 * sc), cf(x, y + 0.4 * sc, z, 0, yaw, 0), PEB, S)
			B:block(soil, v(1.1 * sc, 0.6 * sc, 1.0 * sc), cf(x - 0.15 * sc, y + 1.0 * sc, z + 0.1 * sc, 0, yaw + 18, 0), PEB_LT, S)
			B:block(soil, v(0.9 * sc, 0.2 * sc, 0.7 * sc), cf(x + 0.3 * sc, y + 0.85 * sc, z - 0.2 * sc, 0, yaw - 10, 0), TURF_DK, S)
		end
		stone(-6.2, 1.35, -3.0, 1.1, 25)
		stone(2.6, 2.6, 5.0, 0.9, -15)
		for _, p in { { -4.6, 1.35, -5.6 }, { 7.0, 1.35, 2.5 }, { -2.0, 2.6, 5.4 }, { 1.6, 3.55, -3.2 }, { -7.2, 1.35, -0.2 } } do
			B:block(soil, v(0.6, 0.36, 0.5), cf(p[1], p[2] + 0.16, p[3], 0, rnd() * 90, 0), rnd() > 0.5 and PEB or PEB_LT, S)
		end
		for _, c in { { -1.3, 1.35, -7.3 }, { 4.6, 2.6, 4.2 }, { -4.0, 2.6, -3.4 }, { 7.2, 1.35, 0.4 } } do
			local yaw = rnd() * 120
			B:block(soil, v(0.2, 0.7, 0.2), cf(c[1], c[2] + 0.35, c[3]), CLOVER_DK, S)
			for k = 0, 2 do
				local q = CFrame.new(c[1], c[2] + 0.72, c[3]) * ang(0, yaw + k * 120, 0) * CFrame.new(0, 0, -0.35) * ang(-12, 0, 0)
				B:block(soil, v(0.6, 0.16, 0.6), q * ang(0, 45, 0), (k == 0) and CLOVER or CLOVER_DK, S)
			end
		end
		local fl = 0
		for _, f in { { 2.4, 1.35, -7.0 }, { -3.2, 1.35, -6.7 }, { -7.3, 1.35, 1.2 }, { -2.6, 2.6, -5.0 }, { 0.8, 2.6, 5.8 }, { 5.4, 1.35, 5.0 }, { -3.9, 1.35, 6.3 }, { -2.4, 3.55, 1.6 }, { 0.4, 2.6, -5.6 } } do
			fl += 1
			local col = FLOWERS[1 + (fl % #FLOWERS)]
			local h = 0.6 + rnd() * 0.5
			local y = f[2] + h
			local yaw = rnd() * 90
			B:block(soil, v(0.16, h, 0.16), cf(f[1], f[2] + h / 2, f[3]), CLOVER_DK, S)
			B:block(soil, v(0.75, 0.18, 0.3), cf(f[1], y, f[3], 0, yaw, 0), col[1], S)
			B:block(soil, v(0.3, 0.19, 0.75), cf(f[1], y, f[3], 0, yaw, 0), col[1], S)
			B:block(soil, v(0.28, 0.24, 0.28), cf(f[1], y + 0.04, f[3], 0, yaw, 0), col[2], S)
		end
		for _, g in { { 6.5, 1.35, 3.6 }, { -7.0, 1.35, -2.4 }, { 0.2, 1.35, 7.4 }, { -5.0, 2.6, 4.6 } } do
			local yaw = rnd() * 90
			for k = -1, 1 do
				local h = (k == 0) and 1.2 or 0.85
				local c = CFrame.new(g[1], g[2], g[3]) * ang(0, yaw, 0) * ang(0, 0, k * 22) * CFrame.new(0, h / 2, 0)
				B:block(soil, v(0.2, h, 0.3), c, (k == 0) and TURF_HI or TURF_DK, S)
			end
		end

		------------------------------------------------------------------
		-- TRUNK (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		B:block(crop, v(4.4, 1.0, 4.4), cf(0, TOP + 0.4, 0, 0, 15, 0), BARK_DK)
		for k = 0, 4 do
			local a = k * 72 + 20 + jit(8)
			local p1 = at(1.5, a, TOP + 1.0)
			local p2 = at(3.3, a + 6, TOP - 0.05)
			local p3 = at(4.6, a + 12, 2.5)
			B:bar(crop, p1, p2, 1.4, 1.1, (k % 2 == 0) and BARK or BARK_DK)
			B:bar(crop, p2 - (p2 - p1).Unit * 0.3, p3, 0.95, 0.8, BARK_DK)
		end
		local SEG = { -- width, y0, y1, x, z, yaw, colour
			{ 3.5, 0.6, 2.8, 0.0, 0.0, 0, BARK },
			{ 3.2, 2.6, 4.7, -0.25, 0.1, 20, BARK_DK },
			{ 2.9, 4.5, 6.4, -0.3, 0.25, 40, BARK },
			{ 2.65, 6.2, 8.0, -0.1, 0.3, 60, BARK_DK },
		}
		for _, s in SEG do
			B:block(crop, v(s[1], s[3] - s[2], s[1]), cf(s[4], TOP + (s[2] + s[3]) / 2, s[5], 0, s[6], 0), s[7])
		end
		-- pale bark ridges
		for _, r in { { 200, 0.8, 4.4, 1.85 }, { 320, 2.2, 6.6, 1.65 }, { 100, 3.8, 7.6, 1.5 } } do
			local p0 = at(r[4], r[1], TOP + r[2])
			local p1 = at(r[4] - 0.25, r[1] + 25, TOP + r[3])
			B:bar(crop, p0, p1, 0.55, 0.5, BARK_LT)
		end
		local FY = TOP + 7.3
		-- limbs into the canopy (first segment on the trunk)
		local limbs = {}
		for _, a in { 150, 235, 310, 10 } do
			local p0 = at(0.6, a, FY - 0.6)
			local p1 = at(3.4, a + 6, FY + 2.2)
			B:bar(crop, p0, p1, 1.5, 1.35, BARK)
			table.insert(limbs, { a = a, p0 = p0, p1 = p1 })
		end
		B:block(crop, v(2.9, 1.4, 2.9), cf(-0.1, FY - 0.2, 0.3, 0, 75, 0), BARK_DK)

		------------------------------------------------------------------
		-- BLOSSOM CANOPY (bones Canopy -> CanopyTop)
		------------------------------------------------------------------
		local canopy = B:bone("Canopy", "Crop", v(0, FY, 0))
		for _, l in limbs do
			local tip = at(5.0, l.a - 6, FY + 3.8)
			B:bar(canopy, l.p1 - (l.p1 - l.p0).Unit * 0.4, tip, 1.1, 1.0, BARK_LT)
		end
		B:block(canopy, v(2.3, 6.0, 2.3), cf(-0.1, FY + 3.0, 0.3, 0, 30, 0), BARK_DK)
		-- the hive bough
		local hb0 = at(0.8, HIVE_DEG, FY - 0.3)
		local hb1 = at(3.8, HIVE_DEG - 4, FY + 1.1)
		local hb2 = at(HIVE_R + 0.6, HIVE_DEG, FY + 1.7)
		B:bar(canopy, hb0, hb1, 1.45, 1.3, BARK)
		B:bar(canopy, hb1 - (hb1 - hb0).Unit * 0.3, hb2, 1.1, 1.0, BARK_LT)

		local function cube(bone, p, s, col)
			B:block(bone, v(s, s, s), CFrame.new(p) * ang(jit(18), rnd() * 90, jit(18)), col)
		end
		local cubes = {}
		local function tier(bone, ringN, ringR, ringY, ringS, cols, inner, capR, capY, capS, capCols, phase, skip)
			for i = 0, ringN - 1 do
				local a = i * 360 / ringN + phase + jit(6)
				local p = at(ringR + jit(0.3), a, ringY + jit(0.4))
				local s = ringS + jit(0.3)
				cube(bone, p, s, cols[1 + (i % #cols)])
				table.insert(cubes, { bone = bone, p = p, s = s, a = a })
			end
			for _, d in inner do
				cube(bone, at(d[1], d[2], d[3]), d[4], d[5])
			end
			for i = 0, ringN - 1 do
				local a = (i + 0.5) * 360 / ringN + phase
				cube(bone, at(capR, a, capY + jit(0.3)), capS, capCols[1 + (i % #capCols)])
			end
		end
		local AY = FY + 3.5
		-- under-shade plate so the canopy has a darker belly
		B:block(canopy, v(9.5, 0.8, 9.5), cf(0, AY - 1.9, 0, 0, 22, 0), PINK_DK)
		tier(canopy, 11, 5.5, AY, 3.8, { PINK, PINK_DK, PINK_LT, PINK, LAV_DK }, {
			{ 2.4, 30, AY + 0.8, 4.4, PINK }, { 2.4, 120, AY + 0.9, 4.4, LAV }, { 2.4, 210, AY + 0.8, 4.2, PINK_DK }, { 2.4, 300, AY + 0.9, 4.4, PINK_LT },
		}, 4.3, AY + 2.0, 3.0, { PINK_LT, LAV, PINK_HI, PINK, WHITE }, 5)
		local canopyTop = B:bone("CanopyTop", "Canopy", v(0, AY + 2.2, 0))
		local BY = AY + 4.4
		tier(canopyTop, 8, 3.7, BY, 3.5, { PINK_LT, PINK, LAV_DK, PINK_DK }, {
			{ 1.3, 60, BY + 0.7, 4.0, PINK }, { 1.3, 240, BY + 0.7, 4.0, PINK_LT },
		}, 2.5, BY + 1.9, 2.6, { PINK_HI, WHITE, LAV, PINK_LT }, 25)
		cube(canopyTop, v(0, BY + 2.9, 0), 2.4, PINK_HI)

		-- little five-petal blossoms dotted over the canopy cubes
		for i, c in cubes do
			if i % 2 == 1 then
				local o = outward(c.a)
				local p = c.p + o * (c.s * 0.5 + 0.15) + v(0, c.s * 0.15, 0)
				local F = face(p, c.a) * ang(-rnd() * 30, 0, rnd() * 45)
				local col = (i % 4 == 1) and WHITE or PINK_HI
				B:block(c.bone, v(1.5, 1.5, 0.25), F * ang(0, 0, 45), col)
				B:block(c.bone, v(1.7, 0.7, 0.3), F, col)
				B:block(c.bone, v(0.6, 0.6, 0.4), F * CFrame.new(0, 0, -0.05), HONEY_LT)
			end
		end

		------------------------------------------------------------------
		-- THE HIVE (bone "Hive", pivot at the stem where it hangs)
		------------------------------------------------------------------
		local HP = at(HIVE_R, HIVE_DEG, FY + 1.5)
		local hive = B:bone("Hive", "Canopy", HP)
		B:block(canopy, v(1.9, 0.6, 1.9), CFrame.new(hb2 + v(-0.2, -0.4, 0.1)) * ang(0, 30, 0), HIVE_DK)
		B:block(hive, v(0.8, 1.4, 0.8), CFrame.new(HP + v(0, -0.4, 0)) * ang(0, 15, 0), BARK_DK)
		local LAYERS = { -- width, height, colour
			{ 2.6, 0.65, HIVE_DK },
			{ 3.8, 0.8, HIVE },
			{ 4.6, 0.8, HIVE_DK },
			{ 5.0, 0.9, HIVE },
			{ 4.9, 0.85, HIVE_DK },
			{ 4.4, 0.8, HIVE },
			{ 3.5, 0.7, HIVE_DK },
			{ 2.2, 0.6, HIVE_LT },
		}
		local y = HP.Y - 0.9
		local layerY = {}
		for i, L in LAYERS do
			local cy = y - L[2] / 2
			layerY[i] = cy
			local c = v(HP.X, cy, HP.Z)
			B:block(hive, v(L[1], L[2], L[1]), CFrame.new(c) * ang(0, 15, 0), L[3])
			B:block(hive, v(L[1] * 0.98, L[2] + 0.04, L[1] * 0.98), CFrame.new(c) * ang(0, 60, 0), L[3])
			y = y - L[2] + 0.02
		end
		local HC = v(HP.X, layerY[4], HP.Z) -- hive centre
		local HBOT = y
		-- entrance (facing the front-right, glowing honey inside)
		local EDEG = 25
		do
			local F = face(v(HP.X, layerY[5] + 0.1, HP.Z), EDEG)
			B:block(hive, v(1.7, 1.2, 0.5), F * CFrame.new(0, 0, -2.3), HOLE)
			B:block(hive, v(1.15, 0.8, 0.3), F * CFrame.new(0, 0, -2.45), GLOW, { mat = "Neon", name = "HiveGlow" })
			B:block(hive, v(2.1, 0.3, 0.9), F * CFrame.new(0, -0.72, -2.4), HIVE_LT)
			-- a small second hole higher on the side
			local G = face(v(HP.X, layerY[2], HP.Z), EDEG + 120)
			B:block(hive, v(0.8, 0.6, 0.4), G * CFrame.new(0, 0, -1.8), HOLE)
		end
		-- honey drips running down the hive
		for k, d in { { 100, 3, 1.4 }, { 220, 4, 1.1 }, { 330, 2, 1.0 } } do
			local L = LAYERS[d[2]]
			local F = face(v(HP.X, layerY[d[2]], HP.Z), d[1])
			local r = L[1] * 0.5 + 0.05
			B:block(hive, v(0.7, 0.4, 0.5), F * CFrame.new(0, 0.15, -r), HONEY)
			B:block(hive, v(0.42, d[3], 0.4), F * CFrame.new(0, -d[3] / 2, -r - 0.05), HONEY)
			B:block(hive, v(0.5, 0.45, 0.48), F * CFrame.new(0, -d[3] - 0.1, -r - 0.05), HONEY_LT)
		end
		-- the drip hanging from the bottom tip
		B:block(hive, v(0.6, 0.8, 0.6), CFrame.new(HP.X, HBOT - 0.3, HP.Z), HONEY)
		B:block(hive, v(0.7, 0.55, 0.7), CFrame.new(HP.X, HBOT - 0.9, HP.Z) * ang(0, 45, 0), HONEY_LT)

		------------------------------------------------------------------
		-- HANGING HONEY-DROP FRUITS (bones FruitN, pivot at the stem top)
		------------------------------------------------------------------
		local FRUITS = { { 150, 5.4, 1.8 }, { 215, 6.0, 2.6 }, { 285, 5.5, 1.9 }, { 345, 6.0, 2.4 } }
		for i, f in FRUITS do
			local top = at(f[2], f[1], AY - 2.0)
			local bone = B:bone("Fruit" .. i, "Canopy", top)
			local c = top - v(0, f[3] + 0.9, 0)
			B:bar(bone, top + v(0, 0.4, 0), c + v(0, 0.8, 0), 0.3, 0.3, BARK_DK)
			local F = CFrame.new(c) * ang(0, -f[1], 0)
			B:block(bone, v(1.25, 0.25, 0.5), F * CFrame.new(0, 0.95, 0) * ang(0, 30, 0), PINK)
			B:block(bone, v(0.5, 0.26, 1.25), F * CFrame.new(0, 0.95, 0) * ang(0, 30, 0), PINK)
			B:block(bone, v(1.2, 1.2, 1.2), F, FRUIT_CORE, { mat = "Neon", name = "FruitCore" .. i })
			B:block(bone, v(1.5, 1.0, 1.0), F, HONEY)
			B:block(bone, v(1.0, 1.0, 1.5), F, HONEY)
			B:block(bone, v(1.05, 1.45, 1.05), F * CFrame.new(0, -0.1, 0), HONEY_DK)
			B:block(bone, v(0.55, 0.6, 0.55), F * CFrame.new(0, -0.95, 0), HONEY_LT)
		end

		------------------------------------------------------------------
		-- BEES (bones BeeN: pivot = orbit centre, tilted orbit plane)
		------------------------------------------------------------------
		local trailCols = { "#fff2a8", "#ffc93a" }
		local function bee(name, parent, pivot, r, a0, s)
			local bone = B:bone(name, parent, pivot)
			local px, pz = polar(r, a0)
			-- body frame: forward (-Z) along the travel direction (decreasing angle)
			local F = pivot * CFrame.new(px, 0, pz) * CFrame.Angles(0, -rad(a0 - 90), 0) * ang(0, 0, -10)
			B:block(bone, v(1.1 * s, 1.0 * s, 1.5 * s), F, BEE_Y)
			B:block(bone, v(1.16 * s, 1.06 * s, 0.32 * s), F * CFrame.new(0, 0, 0.05 * s), BEE_K)
			B:block(bone, v(1.16 * s, 1.06 * s, 0.3 * s), F * CFrame.new(0, 0, 0.55 * s), BEE_K)
			B:block(bone, v(0.8 * s, 0.75 * s, 0.4 * s), F * CFrame.new(0, -0.05 * s, 0.9 * s), BEE_YD)
			B:block(bone, v(0.3 * s, 0.3 * s, 0.3 * s), F * CFrame.new(0, -0.1 * s, 1.15 * s), BEE_K)
			B:block(bone, v(0.85 * s, 0.85 * s, 0.7 * s), F * CFrame.new(0, 0.05 * s, -1.0 * s), BEE_K)
			B:block(bone, v(0.12 * s, 0.6 * s, 0.12 * s), F * CFrame.new(0.25 * s, 0.7 * s, -1.2 * s) * ang(-25, 0, -15), BEE_K)
			B:block(bone, v(0.12 * s, 0.6 * s, 0.12 * s), F * CFrame.new(-0.25 * s, 0.7 * s, -1.2 * s) * ang(-25, 0, 15), BEE_K)
			for _, side in { 1, -1 } do
				local wp = F * CFrame.new(side * 0.35 * s, 0.5 * s, 0.05 * s)
				local wb = B:bone(name .. (side > 0 and "WR" or "WL"), name, wp)
				B:block(wb, v(0.95 * s, 0.12, 0.7 * s), wp * ang(0, 0, side * 22) * CFrame.new(side * 0.5 * s, 0, 0.05 * s), WING, { tr = 0.15 })
			end
			B:trail(bone, (F * CFrame.new(0, 0.25 * s, 0.8 * s)).Position, (F * CFrame.new(0, -0.25 * s, 0.8 * s)).Position,
				{ name = name .. "Trail", color = trailCols, life = 0.45, width = { 1, 0 }, trans = { 0.25, 1 } })
			return bone
		end
		-- tilt about the tangent so the trunk side of the hive orbits sits lower
		local function tilted(c, deg, tilt)
			return CFrame.new(c) * CFrame.Angles(0, -rad(deg), 0) * ang(tilt, 0, 0) * CFrame.Angles(0, rad(deg), 0)
		end
		-- the hive swarm: name, centre y offset, radius, start angle, tilt
		local HIVE_BEES = {
			{ 0.3, 3.8, 0, 14 },
			{ -0.6, 4.0, 72, 10 },
			{ 0.9, 3.7, 144, 16 },
			{ -0.2, 4.2, 216, 8 },
			{ 0.5, 3.9, 288, 12 },
		}
		for i, b in HIVE_BEES do
			bee("Bee" .. i, "Canopy", tilted(HC + v(0, b[1], 0), HIVE_DEG, b[4]), b[2], b[3], 0.9)
		end
		-- two scouts circling the whole canopy
		bee("Bee6", "Root", tilted(v(0, AY + 1.4, 0), 200, 7), 10.2, 140, 1.0)
		bee("Bee7", "Root", tilted(v(0, AY + 3.4, 0), 20, 9), 10.0, 320, 1.0)

		------------------------------------------------------------------
		-- VFX: 7 emitters, 2 lights, 7 trails (on the bees)
		------------------------------------------------------------------
		local dripPart = B:block(hive, v(0.5, 0.3, 0.5), CFrame.new(HP.X, HBOT - 1.2, HP.Z), HONEY, { tr = 1, name = "DripPoint" })
		B:emitter(dripPart, "drip", { name = "HoneyDrip", color = { HONEY_LT, HONEY }, rate = 2.5, size = { 0.45, 0.4, 0.2 }, life = { 0.5, 0.7 }, accel = { 0, -20, 0 } })
		local mouth = B:block(hive, v(1.0, 0.7, 0.3), face(v(HP.X, layerY[5] + 0.1, HP.Z), EDEG) * CFrame.new(0, 0, -2.7), GLOW, { tr = 1, name = "HiveMouth" })
		B:emitter(mouth, "burst", { name = "HoneyBurst", color = { "#fff3a8", HONEY_LT, HONEY }, size = { 0.7, 0.5, 0 }, speed = { 6, 13 }, life = { 0.6, 1.2 }, drag = 2.5, accel = { 0, -6, 0 }, light = 1 })
		local hiveFx = B:block(hive, v(4, 5, 4), CFrame.new(HC), HIVE, { tr = 1, name = "HiveFx" })
		B:emitter(hiveFx, "glow", { name = "HiveAura", color = { "#ffe08a", HIVE }, rate = 2, size = { 3.0, 4.6, 1.5 }, trans = { 0.8, 0.72, 1 }, light = 1 })
		local canopyFx = B:block(canopy, v(15, 9, 15), cf(0, AY + 2.5, 0), PINK, { tr = 1, name = "CanopyFx" })
		B:emitter(canopyFx, "sparkle", { name = "PollenSparkles", color = { "#ffffff", "#ffe066", PINK_LT }, rate = 16, size = { 0.2, 0.7, 0 }, life = { 1.0, 1.8 }, speed = { 0.2, 0.7 }, light = 1 })
		local petalZone = B:block(canopy, v(13, 1, 13), cf(0, AY - 1.8, 0), PINK, { tr = 1, name = "PetalZone" })
		B:emitter(petalZone, "leaf", { name = "PetalFall", color = { PINK_LT, WHITE, PINK }, rate = 3, size = { 0.5, 0.5, 0.3 }, life = { 3, 4.5 }, speed = { 0.3, 0.8 }, accel = { 0.5, -1.4, 0.2 }, dir = "Bottom" })
		local topFx = B:block(canopyTop, v(6, 1, 6), cf(0, BY + 2.5, 0), PINK, { tr = 1, name = "TopFx" })
		B:emitter(topFx, "leaf", { name = "PetalBurst", rate = 0, color = { PINK_LT, WHITE, PINK_HI }, size = { 0.6, 0.6, 0.35 }, life = { 2.0, 3.2 }, speed = { 5, 9 }, spread = 70, drag = 1.5, accel = { 0.4, -2.5, 0 } })
		local moteZone = B:block(soil, v(14, 1, 14), cf(0, 3.8, 0), HONEY, { tr = 1, name = "MoteZone" })
		B:emitter(moteZone, "ember", { name = "PollenMotes", color = { "#fff3a0", HONEY_LT, "#ffd36a" }, rate = 6, size = { 0.3, 0.24, 0 }, life = { 3, 5 }, speed = { 0.3, 0.9 }, spread = 30, accel = { 0.15, 0.9, 0 }, light = 1 })
		B:light(hiveFx, { name = "HiveLight", color = "#ffc04a", brightness = 1.2, range = 14 })
		local canopyLightPart = B:block(canopy, v(0.4, 0.4, 0.4), cf(0, AY, 0), PINK, { tr = 1, name = "CanopyLightCore" })
		B:light(canopyLightPart, { name = "CanopyLight", color = "#ffb3d4", brightness = 0.9, range = 18 })
	end,
}
