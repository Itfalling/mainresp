--!nocheck
-- Royal Jelly Tulip (Honey Hills crop #7, Secret): a bouquet of GIANT tulips
-- rising from a sunny meadow mound, each cup cradling a glowing orb of
-- creamy royal jelly. Static crop (no motion.luau) with VFX.
-- * stepped Honey-Hills mound (bone "Soil", parts "Soil"): dark soil tiers
--   with golden-green turf caps, chunky edge sods, tiny pastel wildflowers,
--   clover, a glossy honey puddle with a little honeycomb chunk, pebbles
-- * four giant tulips (rose / lavender / blush / gold) on tall leaning stems
--   from one clump: each cup = 3 big outer + 3 inner stepped petals with a
--   darker vein stripe, a royal-jelly orb (neon core JellyCoreN peeking out
--   between cream slabs) and jelly drips running down the petals
-- * the tallest rose tulip wears a little gold crown on its jelly orb
-- * broad stepped tulip leaves arching out of the clump, two closed buds
-- * two cute block bees (yellow/black stripes, tiny white wings): one
--   sipping jelly on the blush tulip, one resting on a leaf
-- * VFX: jelly sparkles, soft jelly glows, jelly drips, rising pollen motes,
--   drifting petals; two warm lights
-- Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Royal Jelly Tulip",
	Rarity = "Secret",
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
		local STEM, STEM_DK = "#4c9a3c", "#3a7d2e"
		local LEAF, LEAF_DK, LEAF_LT = "#6cbf55", "#52a043", "#94d46a"
		local JELLY, JELLY_DK, JELLY_HI, JELLY_CORE = "#ffeaa6", "#f4c95e", "#fffbea", "#ffd84a"
		local GOLD_DK, GOLD, GOLD_LT = "#d99a1c", "#ffc93a", "#ffe066"
		local GEM_PINK = "#ff6fb1"
		local BEE_Y, BEE_YD, BEE_K, WING = "#ffc21a", "#e59a0e", "#2a2230", "#ffffff"
		local FLOWERS = { { "#ff9ec7", "#ffe066" }, { "#c7a6ff", "#fff3a0" }, { "#fff4fa", "#ffcf3a" }, { "#ffd04a", "#ff9a3c" } }
		-- tulip palettes: petal, dark (vein / base), light (tips), tip accent
		local ROSE = { "#ff7aae", "#e0508a", "#ffb0d0", GOLD }
		local LAV = { "#b48cf2", "#8f63d6", "#dcc4ff", "#f3e3ff" }
		local BLUSH = { "#ffc0da", "#f293bc", "#ffe4f0", "#fff6fa" }
		local GOLDEN = { "#ffcf4d", "#e9a21f", "#ffe58f", "#fff2c2" }

		local seed = 7070707
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
		local function face(p, deg) -- frame at p whose -Z points outward along deg
			return CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
		end

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
		-- chunky sods around the rim (soil block + turf cap)
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
			local x, z = polar(6.2 + jit(0.3), a)
			local h = 0.7 + rnd() * 0.35
			local yaw = -a + jit(12)
			B:block(soil, v(2.2, h, 1.6), cf(x, 1.35 + h / 2, z, 0, yaw, 0), SOIL, S)
			B:block(soil, v(2.35, 0.3, 1.75), cf(x, 1.35 + h + 0.08, z, 0, yaw, 0), (i % 2 == 0) and TURF_LT or TURF, S)
		end

		-- honey puddle (front left) + a honeycomb chunk beside it
		do
			local c = v(-4.3, 2.6, -4.1)
			B:block(soil, v(3.4, 0.16, 2.4), CFrame.new(c + v(0, 0.06, 0)) * ang(0, 20, 0), HONEY_DK, S)
			B:block(soil, v(2.6, 0.18, 3.0), CFrame.new(c + v(0.2, 0.08, -0.1)) * ang(0, -15, 0), HONEY, S)
			B:block(soil, v(2.0, 0.2, 1.6), CFrame.new(c + v(-0.2, 0.1, 0.1)) * ang(0, 40, 0), HONEY_LT, S)
			B:block(soil, v(0.8, 0.22, 0.4), CFrame.new(c + v(-0.4, 0.12, -0.5)) * ang(0, 30, 0), HONEY_HI, S)
		end
		local function hex(p, d, h, col, colTop)
			for k = 0, 2 do
				B:block(soil, v(d, h, d * 0.577), CFrame.new(p + v(0, h / 2, 0)) * ang(0, k * 60, 0), col, S)
			end
			B:block(soil, v(d * 0.62, 0.12, d * 0.62 * 0.577 * 1.6), CFrame.new(p + v(0, h + 0.03, 0)) * ang(0, 90, 0), colTop, S)
		end
		hex(v(-6.3, 1.35, -1.8), 1.5, 1.0, COMB, COMB_DK)
		hex(v(-6.65, 1.35, -0.55), 1.5, 0.7, COMB, COMB_DK)
		hex(v(-5.25, 1.35, -1.0), 1.5, 1.35, HONEY_LT, COMB_DK)

		-- two meadow stones
		local function stone(x, y, z, sc, yaw)
			B:block(soil, v(1.6 * sc, 0.8 * sc, 1.3 * sc), cf(x, y + 0.4 * sc, z, 0, yaw, 0), PEB, S)
			B:block(soil, v(1.1 * sc, 0.6 * sc, 1.0 * sc), cf(x - 0.15 * sc, y + 1.0 * sc, z + 0.1 * sc, 0, yaw + 18, 0), PEB_LT, S)
			B:block(soil, v(0.9 * sc, 0.2 * sc, 0.7 * sc), cf(x + 0.3 * sc, y + 0.85 * sc, z - 0.2 * sc, 0, yaw - 10, 0), TURF_DK, S)
		end
		stone(6.0, 1.35, 1.8, 1.1, 25)
		stone(-1.4, 2.6, 5.2, 0.9, -15)
		stone(2.0, 1.35, -7.0, 0.75, 40)
		-- pebbles
		for _, p in { { 5.0, 1.35, -5.5 }, { 7.0, 1.35, 2.5 }, { -2.0, 2.6, 5.4 }, { 3.2, 3.55, 2.8 }, { -6.5, 1.35, 3.6 }, { 1.3, 1.35, -7.3 } } do
			B:block(soil, v(0.6, 0.36, 0.5), cf(p[1], p[2] + 0.16, p[3], 0, rnd() * 90, 0), rnd() > 0.5 and PEB or PEB_LT, S)
		end
		-- clover clumps (three round-ish leaves on a short stem)
		for _, c in { { 6.4, 1.35, -3.2 }, { -1.3, 1.35, -7.3 }, { 4.6, 2.6, 4.2 }, { -6.0, 2.6, 3.4 }, { 2.4, 3.55, -3.4 } } do
			local yaw = rnd() * 120
			B:block(soil, v(0.2, 0.7, 0.2), cf(c[1], c[2] + 0.35, c[3]), CLOVER_DK, S)
			for k = 0, 2 do
				local q = CFrame.new(c[1], c[2] + 0.72, c[3]) * ang(0, yaw + k * 120, 0) * CFrame.new(0, 0, -0.35) * ang(-12, 0, 0)
				B:block(soil, v(0.6, 0.16, 0.6), q * ang(0, 45, 0), (k == 0) and CLOVER or CLOVER_DK, S)
			end
		end
		-- tiny wildflowers (cross of petals + centre on a stem)
		local fl = 0
		for _, f in { { 7.3, 1.35, -0.9 }, { 3.1, 1.35, -6.7 }, { -3.2, 1.35, -6.7 }, { -7.3, 1.35, 1.2 }, { 5.2, 2.6, -4.0 }, { -2.6, 2.6, -5.6 }, { 0.8, 2.6, 5.8 }, { 5.4, 1.35, 5.0 }, { -3.9, 1.35, 6.3 }, { 3.0, 3.55, -1.4 } } do
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
		-- grass tufts
		for _, g in { { 6.5, 1.35, 3.6 }, { -7.0, 1.35, -2.4 }, { 0.2, 1.35, 7.4 }, { 4.0, 2.6, -5.4 }, { -5.0, 2.6, 4.6 } } do
			local yaw = rnd() * 90
			for k = -1, 1 do
				local h = (k == 0) and 1.2 or 0.85
				local c = CFrame.new(g[1], g[2], g[3]) * ang(0, yaw, 0) * ang(0, 0, k * 22) * CFrame.new(0, h / 2, 0)
				B:block(soil, v(0.2, h, 0.3), c, (k == 0) and TURF_HI or TURF_DK, S)
			end
		end

		------------------------------------------------------------------
		-- PLANT (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		-- the clump the stems rise from
		B:block(crop, v(2.6, 0.8, 2.6), cf(0, TOP + 0.3, 0.2, 0, 20, 0), STEM_DK)
		B:block(crop, v(1.9, 0.7, 1.9), cf(0, TOP + 0.9, 0.2, 0, -15, 0), STEM)

		-- royal-jelly orb: neon core peeking out between cream slabs
		local function orb(c, s, yaw, coreName, bone, o)
			bone = bone or crop
			local F = CFrame.new(c) * ang(0, yaw, 0)
			B:block(bone, v(1.85 * s, 1.85 * s, 1.85 * s), F, JELLY_CORE, { mat = "Neon", name = coreName })
			B:block(bone, v(2.35 * s, 1.5 * s, 1.5 * s), F, JELLY, o)
			B:block(bone, v(1.5 * s, 2.35 * s, 1.5 * s), F, JELLY_DK, o)
			B:block(bone, v(1.5 * s, 1.5 * s, 2.35 * s), F, JELLY, o)
			B:block(bone, v(2.15 * s, 1.3 * s, 2.15 * s), F * ang(0, 45, 0), JELLY_DK, o)
			B:block(bone, v(0.55 * s, 0.55 * s, 0.14), F * CFrame.new(-0.35 * s, 0.4 * s, -1.2 * s), JELLY_HI, o)
		end
		-- a fallen jelly orb resting on the mound
		orb(v(3.6, 2.6 + 0.85 * 0.75, -4.6), 0.75, 25, "Soil", soil, S)

		-- one giant tulip: cup base centre `b`, width W, petal height H
		local function tulip(b, W, H, pal, yaw, coreName, opts)
			opts = opts or {}
			-- receptacle + sepals
			B:block(crop, v(W * 0.5, 0.9, W * 0.5), CFrame.new(b + v(0, 0.25, 0)) * ang(0, yaw + 45, 0), STEM_DK)
			B:block(crop, v(W * 0.62, 1.1, W * 0.62), CFrame.new(b + v(0, 1.0, 0)) * ang(0, yaw, 0), pal[2])
			local pw, th = W * 0.7, 0.55
			local h1, h2, h3 = H * 0.55, H * 0.32, H * 0.2
			local tips = {}
			local function petal(deg, r, tilt, scale, col, colTip, stripe)
				local F = face(b + v(0, 0.35, 0), deg) * CFrame.new(0, 0, -r) * ang(-tilt, 0, 0)
				local w = pw * scale
				B:block(crop, v(w, h1 * scale, th), F * CFrame.new(0, h1 * scale / 2, 0), col)
				B:block(crop, v(w * 0.74, h2 * scale, th * 0.96), F * CFrame.new(0, h1 * scale + h2 * scale / 2 - 0.05, 0), col)
				B:block(crop, v(w * 0.4, h3 * scale, th * 0.92), F * CFrame.new(0, (h1 + h2) * scale + h3 * scale / 2 - 0.1, 0), colTip)
				if stripe then
					B:block(crop, v(w * 0.22, (h1 + h2 * 0.6) * scale, 0.12), F * CFrame.new(0, (h1 + h2 * 0.6) * scale / 2 + 0.2, -th / 2 - 0.04), pal[2])
				end
				return F
			end
			for k = 0, 2 do
				local deg = yaw + k * 120
				tips[k + 1] = petal(deg, W * 0.3, opts.tilt or 17, 1.0, pal[1], pal[4], true)
			end
			for k = 0, 2 do
				petal(yaw + 60 + k * 120, W * 0.22, (opts.tilt or 17) * 0.6, 0.86, pal[3], pal[3], false)
			end
			-- the jelly orb, sitting high in the open cup
			local s = opts.orbScale or 1.0
			local oc = b + v(0, 0.35 + H * 0.86, 0)
			-- a pool of jelly filling the cup under the orb
			B:block(crop, v(W * 0.78, 0.9, W * 0.78), CFrame.new(b + v(0, 0.35 + H * 0.45, 0)) * ang(0, yaw + 45, 0), JELLY_DK)
			orb(oc, s, yaw + 15, coreName)
			-- jelly spilling over the rim between the outer petals
			for k = 1, opts.drips or 1 do
				local deg = yaw + 60 + (k - 1) * 120
				local F = face(b + v(0, 0.35, 0), deg) * CFrame.new(0, 0, -W * 0.22) * ang(-(opts.tilt or 17) * 0.6, 0, 0)
				local top = (h1 + h2 + h3) * 0.86 - 0.15
				local len = 0.7 + 0.25 * k
				B:block(crop, v(0.85, 0.4, 0.7), F * CFrame.new(0, top, -0.1), JELLY)
				B:block(crop, v(0.45, len, 0.4), F * CFrame.new(0.05, top - len / 2, -0.45), JELLY)
				B:block(crop, v(0.55, 0.5, 0.48), F * CFrame.new(0.05, top - len - 0.1, -0.47), JELLY_DK)
			end
			return oc
		end

		-- stem from a to b (two bars with a slight kink) + a node collar
		local function stem(a, m, b, w)
			B:bar(crop, a, m, w, w, STEM)
			B:bar(crop, m, b, w * 0.9, w * 0.9, STEM_DK)
			B:block(crop, v(w * 1.3, 0.4, w * 1.3), CFrame.new(m) * ang(0, 45, 0), STEM_DK)
		end

		-- the four tulips -----------------------------------------------
		-- centre: tall royal rose tulip (with crown)
		local cB = v(0.3, 14.0, 0.9)
		stem(v(0.1, TOP + 0.6, 0.3), v(-0.2, 8.8, 0.5), cB, 1.15)
		local cO = tulip(cB, 4.6, 5.2, ROSE, 0, "JellyCore1", { orbScale = 1.4, drips = 3 })
		-- front right: lavender
		local rB = v(4.6, 10.9, -2.0)
		stem(v(0.6, TOP + 0.6, -0.2), v(2.8, 7.4, -1.3), rB, 1.0)
		local rO = tulip(rB, 4.0, 4.6, LAV, 25, "JellyCore2", { orbScale = 1.2, drips = 2 })
		-- front left: blush
		local lB = v(-4.3, 8.2, -2.4)
		stem(v(-0.5, TOP + 0.6, -0.1), v(-2.6, 5.9, -1.4), lB, 0.95)
		local lO = tulip(lB, 3.7, 4.2, BLUSH, -20, "JellyCore3", { orbScale = 1.1, drips = 1 })
		-- back left: golden
		local gB = v(-3.6, 11.9, 3.5)
		stem(v(-0.4, TOP + 0.6, 0.7), v(-2.0, 8.0, 1.9), gB, 1.0)
		local gO = tulip(gB, 3.9, 4.4, GOLDEN, 40, "JellyCore4", { orbScale = 1.15, drips = 2 })

		-- little gold crown on the royal orb
		do
			local cy = cO.Y + 1.175 * 1.4 + 0.05
			B:block(crop, v(2.0, 0.45, 2.0), CFrame.new(cO.X, cy, cO.Z) * ang(0, 15, 0), GOLD_DK)
			for k = 0, 7 do
				local p = CFrame.new(cO.X, cy, cO.Z) * CFrame.Angles(0, rad(k * 45 + 15), 0) * CFrame.new(0, 0, -0.95)
				local tall = (k % 2 == 0)
				local h = tall and 1.1 or 0.6
				B:block(crop, v(0.45, h, 0.4), p * CFrame.new(0, h / 2, 0), tall and GOLD or GOLD_LT)
				if tall then
					B:block(crop, v(0.3, 0.3, 0.3), p * CFrame.new(0, h + 0.15, 0) * ang(0, 45, 0), GEM_PINK, { mat = "Neon", name = "CrownGem" })
				end
			end
		end

		-- broad tulip leaves arching out of the clump --------------------
		local function leaf(deg, len, w, lift, col)
			local o = at(1, deg, 0)
			local p0 = at(0.8, deg, TOP + 0.4)
			local p1 = p0 + v(0, len * 0.46 * lift, 0) + o * (len * 0.2)
			local p2 = p1 + v(0, len * 0.2 * lift, 0) + o * (len * 0.26)
			local p3 = p2 - v(0, len * 0.06, 0) + o * (len * 0.16)
			local alt = (col == LEAF_DK) and LEAF or LEAF_DK
			B:bar(crop, p0, p1, w, 0.5, col, { up = o })
			B:bar(crop, p1 - (p1 - p0).Unit * 0.45, p2, w * 0.82, 0.48, alt, { up = o })
			B:bar(crop, p2 - (p2 - p1).Unit * 0.35, p3, w * 0.48, 0.46, col, { up = o })
			-- pale midrib on the outer face
			B:bar(crop, p0 + o * 0.28 + v(0, 0.6, 0), p1 + o * 0.27, 0.3, 0.12, LEAF_LT, { up = o })
			B:bar(crop, p1 + o * 0.27 - (p1 - p0).Unit * 0.2, p2 + o * 0.26, 0.26, 0.12, LEAF_LT, { up = o })
			return p2
		end
		leaf(150, 9.0, 2.5, 1.0, LEAF)
		leaf(212, 8.6, 2.4, 0.95, LEAF_DK)
		local leafR = leaf(95, 8.0, 2.4, 0.85, LEAF)
		leaf(268, 8.2, 2.4, 0.9, LEAF)
		leaf(30, 7.0, 2.2, 0.8, LEAF_DK)
		leaf(325, 7.2, 2.2, 0.85, LEAF)

		-- two closed buds on short stems
		local function bud(a, b, col, colDk)
			B:bar(crop, a, b, 0.6, 0.6, STEM)
			B:block(crop, v(1.0, 0.5, 1.0), CFrame.new(b + v(0, 0.2, 0)) * ang(0, 45, 0), STEM_DK)
			B:block(crop, v(1.3, 1.4, 1.3), CFrame.new(b + v(0, 1.05, 0)) * ang(0, 10, 0), col)
			B:block(crop, v(1.5, 0.9, 0.9), CFrame.new(b + v(0, 0.95, 0)) * ang(0, 10, 0), colDk)
			B:block(crop, v(0.85, 0.8, 0.85), CFrame.new(b + v(0, 2.05, 0)) * ang(0, 55, 0), col)
			B:block(crop, v(0.4, 0.4, 0.4), CFrame.new(b + v(0, 2.6, 0)) * ang(0, 10, 0), colDk)
		end
		bud(v(0.6, TOP + 0.6, 0.9), v(2.9, 8.2, 2.6), ROSE[3], ROSE[1])
		bud(v(-0.3, TOP + 0.6, -0.4), v(-0.6, 6.2, -3.4), LAV[3], LAV[1])

		-- block bees ------------------------------------------------------
		local function bee(c, yaw, s)
			local F = CFrame.new(c) * ang(0, yaw, 0)
			B:block(crop, v(1.1 * s, 1.0 * s, 1.5 * s), F, BEE_Y)
			B:block(crop, v(1.16 * s, 1.06 * s, 0.32 * s), F * CFrame.new(0, 0, 0.05 * s), BEE_K)
			B:block(crop, v(1.16 * s, 1.06 * s, 0.3 * s), F * CFrame.new(0, 0, 0.55 * s), BEE_K)
			B:block(crop, v(0.8 * s, 0.75 * s, 0.4 * s), F * CFrame.new(0, -0.05 * s, 0.9 * s), BEE_YD)
			B:block(crop, v(0.85 * s, 0.85 * s, 0.7 * s), F * CFrame.new(0, 0.05 * s, -1.0 * s), BEE_K)
			B:block(crop, v(0.12 * s, 0.6 * s, 0.12 * s), F * CFrame.new(0.25 * s, 0.7 * s, -1.2 * s) * ang(-25, 0, -15), BEE_K)
			B:block(crop, v(0.12 * s, 0.6 * s, 0.12 * s), F * CFrame.new(-0.25 * s, 0.7 * s, -1.2 * s) * ang(-25, 0, 15), BEE_K)
			B:block(crop, v(0.9 * s, 0.12, 0.65 * s), F * CFrame.new(0.65 * s, 0.6 * s, 0.1 * s) * ang(0, 0, 25), WING, { tr = 0.15 })
			B:block(crop, v(0.9 * s, 0.12, 0.65 * s), F * CFrame.new(-0.65 * s, 0.6 * s, 0.1 * s) * ang(0, 0, -25), WING, { tr = 0.15 })
		end
		-- sipping jelly on top of the blush tulip's orb
		bee(lO + v(0.15, 1.175 * 1.1 + 0.5, 0.1), 160, 0.95)
		-- resting on the right leaf
		bee(leafR + v(0.0, 0.75, 0.0), -70, 0.85)

		------------------------------------------------------------------
		-- VFX: 7 emitters, 2 lights
		------------------------------------------------------------------
		local sparkZone = B:block(crop, v(10, 8, 10), cf(0, 14.5, 0), JELLY, { tr = 1, name = "SparkZone" })
		B:emitter(sparkZone, "sparkle", { name = "JellySparkles", color = { "#ffffff", JELLY_CORE, "#ffb3d6" }, rate = 16, size = { 0.2, 0.7, 0 }, life = { 0.9, 1.8 }, speed = { 0.2, 0.7 }, light = 1 })
		local cFx = B:block(crop, v(2, 2, 2), CFrame.new(cO), JELLY, { tr = 1, name = "RoyalFx" })
		B:emitter(cFx, "glow", { name = "RoyalGlow", color = { "#fff6c8", JELLY_CORE }, rate = 2.5, size = { 2.6, 4.2, 1.5 }, trans = { 0.78, 0.68, 1 }, light = 1 })
		local sideFx = B:block(crop, v(2, 2, 2), CFrame.new(rO), JELLY, { tr = 1, name = "SideFx" })
		B:emitter(sideFx, "glow", { name = "SideGlow", color = { "#fff6c8", "#e9d6ff" }, rate = 1.6, size = { 1.8, 3.0, 1.0 }, trans = { 0.8, 0.72, 1 }, light = 1 })
		local dripZone = B:block(crop, v(4.2, 0.6, 4.2), CFrame.new(cB + v(0, 2.2, 0)), JELLY, { tr = 1, name = "DripZone" })
		B:emitter(dripZone, "drip", { name = "JellyDrip", color = { JELLY_HI, JELLY_DK }, rate = 2.5, size = { 0.38, 0.32, 0.15 }, life = { 1.0, 1.6 }, accel = { 0, -18, 0 } })
		local pollenZone = B:block(soil, v(14, 1, 14), cf(0, 3.6, 0), JELLY, { tr = 1, name = "PollenZone" })
		B:emitter(pollenZone, "ember", { name = "PollenMotes", color = { "#fff3a0", GOLD, "#ffd36a" }, rate = 7, size = { 0.3, 0.24, 0 }, life = { 3, 5 }, speed = { 0.3, 0.9 }, spread = 30, accel = { 0.15, 0.9, 0 }, light = 1 })
		local petalZone = B:block(crop, v(12, 1, 12), cf(0, 16.5, 0), JELLY, { tr = 1, name = "PetalZone" })
		B:emitter(petalZone, "leaf", { name = "PetalDrift", color = { ROSE[3], LAV[3], BLUSH[1] }, rate = 2.2, size = { 0.5, 0.5, 0.3 }, life = { 3.5, 5.5 }, speed = { 0.3, 0.7 }, accel = { 0.4, -1.2, 0.2 }, dir = "Bottom" })
		local lowFx = B:block(crop, v(5, 4, 5), cf(-2.0, 10.5, 0.4), JELLY, { tr = 1, name = "LowFx" })
		B:emitter(lowFx, "sparkle", { name = "LowSparkles", color = { "#ffffff", "#ffe27a" }, rate = 6, size = { 0.15, 0.5, 0 }, life = { 0.8, 1.5 }, speed = { 0.2, 0.5 }, light = 1 })
		B:light(cFx, { name = "RoyalLight", color = "#ffe6a0", brightness = 1.3, range = 16 })
		local lightLow = B:block(crop, v(0.4, 0.4, 0.4), CFrame.new((lO + gO) / 2), JELLY, { tr = 1, name = "LowLightCore" })
		B:light(lightLow, { name = "LowLight", color = "#ffc4e0", brightness = 0.9, range = 14 })
	end,
}
