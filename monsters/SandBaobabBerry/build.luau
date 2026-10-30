--!nocheck
-- Baobab Berry Tree (Sandy Savanna crop #8, Cosmic).
-- A huge fat bottle-trunk baobab: a stepped, bulging mauve-grey trunk with
-- fluted bark ridges, chunky root flares and a little knot-hole full of
-- glowing seeds. From its narrow top a small crown of thick stubby branches
-- spreads out like roots in the sky, each tipped with a clump of big studded
-- savanna-green leaf cubes and creamy baobab blossoms. Velvety golden-ochre
-- pods dangle on stems beneath the crown; each is split open down its front,
-- showing glowing turquoise pulp and cream seeds.
-- Base: golden sand tiers with wind ripples, sandstone rocks, dry grass
-- tufts, pebbles, shells, cactus sprouts and a fallen split pod.
-- Turquoise pod glow + sparkles, a few drifting leaves, one soft turquoise
-- light. Static prop: no motion.luau.
return {
	DisplayName = "Baobab Berry Tree",
	Rarity = "Cosmic",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette
		local SAND_DK, SAND_DK2, SAND, SAND_MD, SAND_LT, SAND_HI = "#c48a45", "#b67c3b", "#d9a95c", "#e0b468", "#e8c27a", "#f2d696"
		local SST, SST_LT, SST_BAND = "#c47a3e", "#d9955a", "#93492a"
		local PEB, PEB_LT, PEB_DK = "#a39486", "#c2b4a2", "#7d7166"
		local GRASS_D, GRASS_M, GRASS_L = "#c49a34", "#d8b84a", "#ead27a"
		local CACT, CACT_DK, CACT_FL = "#5c9a3c", "#467c2e", "#ff7aa8"
		local SHELL, SHELL_PK = "#fbefdc", "#f6b8b0"
		local BARK_DK, BARK, BARK_LT, BARK_HI = "#8e6650", "#b08268", "#c39578", "#dcb898"
		local HOLE = "#3a2a26"
		local LEAF_DK, LEAF, LEAF_LT, LEAF_HI = "#4f8a2e", "#62a33a", "#7fbd48", "#9ad35a"
		local POD_DK, POD, POD_LT = "#9a5a26", "#c47a30", "#dc9a44"
		local PULP_DK, PULP, PULP_GLOW = "#178a86", "#3fd6c8", "#7ffff0"
		local SEED = "#fff2d6"
		local BLOSSOM, BLOSSOM_LT = "#f6eedc", "#ffffff"
		local NEON = { mat = "Neon" }

		local seed = 8148
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function polar(c, a, y, r)
			return c * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y, -r)
		end
		local function round(bone, c, r, h, col, opts)
			B:block(bone, v(2 * r, h, 1.1 * r), c, col, opts)
			B:block(bone, v(1.1 * r, h - 0.04, 2 * r), c, col, opts)
			B:block(bone, v(1.72 * r, h - 0.08, 1.72 * r), c, col, opts)
		end
		local function dirA(a)
			return v(math.sin(rad(a)), 0, -math.cos(rad(a)))
		end

		---------------------------------------------------------------- sand mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			round(soil, CFrame.new(0, y0 + h / 2, 0), r, h, col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.4, 2.3), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 6.9, SAND_DK, 19, { SAND_DK, SAND_DK2, SAND_DK }, 0.35)
		tier(0.8, 0.6, 5.0, SAND, 13, { SAND, SAND_MD, SAND }, 0.3)
		tier(1.4, 0.45, 3.2, SAND_LT, 0, {}, 0)
		local TOP = 1.85

		for _, r in { { 30, 5.9, 0.82 }, { 95, 5.8, 0.82 }, { 160, 6.0, 0.82 }, { 230, 5.8, 0.82 }, { 300, 5.9, 0.82 }, { 60, 4.15, 1.42 }, { 190, 4.1, 1.42 }, { 320, 4.2, 1.42 } } do
			local c = polar(CFrame.new(), r[1], r[3], r[2])
			B:block(soil, v(2.2, 0.1, 0.3), c * ang(0, rnd(-8, 8), 0), SAND_HI, S)
		end
		local function rock(x, y, z, s, ry)
			local c = cf(x, y, z, rnd(-6, 6), ry, rnd(-6, 6))
			B:block(soil, v(1.3 * s, 0.9 * s, 1.0 * s), c, SST, S)
			B:block(soil, v(1.34 * s, 0.22 * s, 1.04 * s), c * CFrame.new(0, -0.12 * s, 0), SST_BAND, S)
			B:block(soil, v(0.8 * s, 0.4 * s, 0.7 * s), c * CFrame.new(0.15 * s, 0.6 * s, 0.05 * s) * ang(0, 20, 0), SST_LT, S)
		end
		rock(5.6, 1.15, -2.6, 1.1, 25)
		rock(-5.7, 1.1, 2.9, 1.0, -20)
		rock(-2.4, 1.1, -6.0, 0.8, 50)
		for _, p in { { 6.3, 0.85, -0.9, 0.45 }, { 4.3, 1.45, 2.4, 0.4 }, { -4.1, 1.45, -1.6, 0.38 }, { -0.8, 0.85, 6.5, 0.42 }, { -6.3, 0.85, -0.4, 0.35 }, { 2.0, 0.85, -6.3, 0.4 } } do
			B:block(soil, v(p[4] * 1.3, p[4], p[4]), cf(p[1], p[2] + p[4] / 2 - 0.1, p[3], 0, rnd(0, 90), 0), pick({ PEB, PEB_LT, PEB_DK }), S)
		end
		local function tuft(x, y, z, k)
			local base = v(x, y, z)
			for j = 0, 2 do
				local a = rad(j * 120 + rnd(-20, 20))
				local tip = base + v(math.sin(a) * 0.5 * k, (1.3 + rnd(-0.2, 0.3)) * k, math.cos(a) * 0.5 * k)
				B:bar(soil, base, tip, 0.22 * k, 0.22 * k, pick({ GRASS_D, GRASS_M, GRASS_L }), S)
			end
			B:bar(soil, base, base + v(0, 1.6 * k, 0), 0.24 * k, 0.24 * k, GRASS_L, S)
		end
		tuft(6.4, 0.75, 1.6, 1.0)
		tuft(-6.3, 0.75, -2.2, 0.95)
		tuft(-2.0, 0.75, 6.4, 1.0)
		tuft(4.9, 0.75, 4.6, 0.9)
		tuft(-4.8, 0.75, -4.4, 0.85)
		tuft(4.5, 1.35, -2.2, 0.75)
		tuft(-4.3, 1.35, 1.8, 0.75)
		tuft(1.2, 0.75, -6.5, 0.8)
		local function cactus(x, y, z, k, ry)
			local c = cf(x, y, z, 0, ry, 0)
			B:block(soil, v(0.7 * k, 1.5 * k, 0.7 * k), c * CFrame.new(0, 0.75 * k, 0), CACT, S)
			B:block(soil, v(0.5 * k, 0.4 * k, 0.4 * k), c * CFrame.new(0.55 * k, 0.7 * k, 0), CACT_DK, S)
			B:block(soil, v(0.4 * k, 0.6 * k, 0.4 * k), c * CFrame.new(0.7 * k, 1.1 * k, 0), CACT, S)
			B:block(soil, v(0.4 * k, 0.25 * k, 0.4 * k), c * CFrame.new(0, 1.6 * k, 0) * ang(0, 45, 0), CACT_FL, S)
		end
		cactus(5.7, 0.78, 2.9, 0.85, -60)
		cactus(-5.6, 0.78, 0.6, 0.75, 150)
		for _, s in { { 3.6, 1.42, 3.4, SHELL }, { -4.3, 0.82, 4.9, SHELL_PK }, { 6.2, 0.82, -3.4, SHELL } } do
			local c = cf(s[1], s[2], s[3], 0, rnd(0, 180), 0)
			B:block(soil, v(0.7, 0.18, 0.55), c, s[4], S)
			B:block(soil, v(0.12, 0.22, 0.5), c * CFrame.new(0, 0.03, 0), SHELL_PK, S)
		end

		---------------------------------------------------------------- bottle trunk
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		local prof = {
			{ 1.3, 3.1 }, { 2.4, 3.45 }, { 3.8, 3.65 }, { 5.4, 3.7 }, { 7.0, 3.5 }, { 8.4, 3.1 },
			{ 9.6, 2.6 }, { 10.7, 2.1 }, { 11.8, 1.7 }, { 12.9, 1.45 }, { 14.0, 1.3 },
		}
		for _, pr in prof do
			pr[2] *= 0.92
		end
		local function rAt(y)
			for i = 1, #prof - 1 do
				local a, b = prof[i], prof[i + 1]
				if y <= b[1] then
					local t = math.clamp((y - a[1]) / (b[1] - a[1]), 0, 1)
					return a[2] + (b[2] - a[2]) * t
				end
			end
			return prof[#prof][2]
		end
		for i = 1, #prof - 1 do
			local a, b = prof[i], prof[i + 1]
			local h = b[1] - a[1] + 0.1
			local r = (a[2] + b[2]) / 2
			round(crop, CFrame.new(0, (a[1] + b[1]) / 2, 0), r, h, (i % 2 == 0) and BARK or BARK_LT)
		end
		-- fluted bark ridges (cardinal = on the flat faces, diagonal = on the corners)
		for k = 0, 7 do
			local a = k * 45
			local diag = (k % 2 == 1)
			local col = diag and BARK_DK or BARK_DK
			local ys = { 1.6, 4.6, 8.0, 11.2, 13.8 }
			for j = 1, #ys - 1 do
				local y0, y1 = ys[j], ys[j + 1]
				local r0 = diag and (1.18 * rAt(y0) + 0.02) or (rAt(y0) + 0.08)
				local r1 = diag and (1.18 * rAt(y1) + 0.02) or (rAt(y1) + 0.08)
				if not (k == 0 and j == 2) then
					B:bar(crop, dirA(a) * r0 + v(0, y0, 0), dirA(a) * r1 + v(0, y1, 0), diag and 0.55 or 0.7, 0.4, (j % 2 == 0) and col or BARK_DK)
				end
			end
		end
		-- pale bark patches
		for _, pch in { { 22, 6.4, 1.6, 1.1 }, { 160, 4.0, 1.2, 1.6 }, { 250, 8.6, 1.0, 1.3 }, { 120, 10.4, 0.9, 1.0 }, { 300, 3.2, 1.3, 0.9 } } do
			local y = pch[2]
			local c = CFrame.new(dirA(pch[1]) * (rAt(y) * 1.03 + 0.05) + v(0, y, 0)) * CFrame.Angles(0, -rad(pch[1]), 0)
			B:block(crop, v(pch[3], pch[4], 0.3), c, BARK_HI)
		end
		-- root flares
		for k = 0, 5 do
			local a = k * 60 + 30
			local d = dirA(a)
			local rc = CFrame.new(d * 3.55 + v(0, 2.0, 0)) * CFrame.Angles(0, -rad(a), 0)
			B:block(crop, v(1.5, 1.5, 1.6), rc * ang(-18, 0, 0), (k % 2 == 0) and BARK or BARK_LT)
			B:block(crop, v(1.1, 0.8, 1.2), rc * CFrame.new(0, -0.55, -1.15) * ang(-8, 0, 0), BARK_DK)
		end
		-- knot hole with glowing seeds (front)
		local kh = v(0, 6.2, 0)
		local knot = CFrame.new(dirA(0) * (rAt(6.2) + 0.05) + kh) -- faces -Z
		B:block(crop, v(1.9, 2.3, 0.4), knot * CFrame.new(0, 0, 0.0), BARK_DK)
		B:block(crop, v(1.3, 1.7, 0.4), knot * CFrame.new(0, 0, -0.08), HOLE)
		B:block(crop, v(0.35, 0.35, 0.3), knot * CFrame.new(-0.25, -0.5, -0.2) * ang(0, 0, 45), PULP_GLOW, { mat = "Neon", name = "KnotGlow" })
		B:block(crop, v(0.3, 0.3, 0.3), knot * CFrame.new(0.3, -0.45, -0.22) * ang(0, 0, 45), SEED)
		B:block(crop, v(0.28, 0.28, 0.3), knot * CFrame.new(0.05, -0.15, -0.2) * ang(0, 0, 30), PULP)

		---------------------------------------------------------------- crown branches
		local leafParts = {}
		local function clump(c, s)
			local cols = { LEAF_DK, LEAF, LEAF_LT }
			table.insert(leafParts, B:block(crop, v(s, s, s), CFrame.new(c) * ang(rnd(-25, 25), rnd(0, 90), rnd(-25, 25)), LEAF))
			for j = 0, 3 do
				local a = j * 90 + rnd(-25, 25)
				local off = dirA(a) * s * 0.55 + v(0, rnd(-0.45, 0.15) * s, 0)
				local k = rnd(0.6, 0.8)
				B:block(crop, v(s * k, s * k, s * k), CFrame.new(c + off) * ang(rnd(-30, 30), rnd(0, 90), rnd(-30, 30)), cols[(j % 3) + 1])
			end
			B:block(crop, v(s * 0.55, s * 0.55, s * 0.55), CFrame.new(c + v(rnd(-0.3, 0.3), s * 0.55, rnd(-0.3, 0.3))) * ang(rnd(-20, 20), rnd(0, 90), rnd(-20, 20)), LEAF_HI)
		end
		local berryTips = {}
		local function berries(cc, a, s)
			-- little turquoise berry bunch peeking out of a leaf clump (outer, upper side)
			local p = cc + dirA(a) * (s * 0.62) + v(0, s * 0.18, 0)
			local c = CFrame.new(p) * CFrame.Angles(0, -rad(a), 0)
			B:block(crop, v(0.75, 0.75, 0.75), c * ang(20, 0, 25), PULP)
			B:block(crop, v(0.6, 0.6, 0.6), c * CFrame.new(0.55, -0.35, 0.1) * ang(-15, 30, 10), PULP_DK)
			B:block(crop, v(0.6, 0.6, 0.6), c * CFrame.new(-0.5, -0.3, 0.05) * ang(10, 15, -20), PULP)
			B:block(crop, v(0.18, 0.4, 0.18), c * CFrame.new(0, 0.5, 0), LEAF_DK)
			table.insert(berryTips, B:block(crop, v(0.3, 0.3, 0.3), c * CFrame.new(0.05, 0.05, -0.4) * ang(45, 0, 45), PULP_GLOW, { mat = "Neon", name = "BerryGlow" }))
		end

		local podHangs = {}
		local branches = {
			{ a = 15, r = 3.7, y = 16.0, f1 = { 25, 5.9, 18.0 }, f2 = { -10, 4.0, 19.6 } },
			{ a = 85, r = 3.9, y = 15.6, f1 = { 10, 6.1, 17.4 }, f2 = { -25, 4.3, 19.2 } },
			{ a = 150, r = 3.6, y = 16.2, f1 = { 20, 5.8, 18.2 }, f2 = { -15, 3.9, 19.9 } },
			{ a = 215, r = 3.9, y = 15.7, f1 = { 15, 6.0, 17.6 }, f2 = { -20, 4.2, 19.4 } },
			{ a = 285, r = 3.7, y = 16.0, f1 = { 20, 5.9, 17.9 }, f2 = { -15, 4.0, 19.7 } },
		}
		local base0 = v(0, 13.6, 0)
		for bi, br in branches do
			local d = dirA(br.a)
			local p0 = d * 0.6 + base0
			local p1 = d * br.r + v(0, br.y, 0)
			B:bar(crop, p0, p1, 1.3, 1.3, (bi % 2 == 0) and BARK or BARK_LT)
			B:block(crop, v(1.5, 1.5, 1.5), CFrame.new(p1) * ang(0, br.a + 45, 0), BARK)
			local q1 = dirA(br.a + br.f1[1]) * br.f1[2] + v(0, br.f1[3], 0)
			local q2 = dirA(br.a + br.f2[1]) * br.f2[2] + v(0, br.f2[3], 0)
			B:bar(crop, p1, q1, 0.85, 0.85, BARK)
			B:bar(crop, p1, q2, 0.8, 0.8, BARK_LT)
			clump(q1 + v(0, 0.8, 0), 2.4 + rnd(-0.2, 0.3))
			clump(q2 + v(0, 0.9, 0), 2.2 + rnd(-0.2, 0.3))
			-- pod hang points: under the elbow and under the outer twig
			table.insert(podHangs, { p = p1 - v(0, 0.6, 0), a = br.a })
			table.insert(podHangs, { p = p1:Lerp(q1, 0.8) - v(0, 0.45, 0), a = br.a + br.f1[1] })
			berries(q1 + v(0, 0.8, 0), br.a + br.f1[1], 2.4)
			if bi % 2 == 0 then berries(q2 + v(0, 0.9, 0), br.a + br.f2[1], 2.2) end
		end
		-- top-centre stub branch + clump
		B:bar(crop, base0, v(0.2, 18.8, 0.3), 1.2, 1.2, BARK_LT)
		clump(v(0.2, 21.0, 0.3), 3.0)
		berries(v(0.2, 21.0, 0.3), 200, 2.6)
		berries(v(0.2, 21.0, 0.3), 20, 2.6)

		---------------------------------------------------------------- velvety split pods
		local podGlows = {}
		local function pod(top, len, a, k)
			-- top: hang point; the pod's split (glowing pulp) faces outward (dirA(a))
			local stemLen = 1.1 + k * 0.9
			local c0 = top - v(0, stemLen, 0)
			B:bar(crop, top + v(0, 0.2, 0), c0, 0.22, 0.22, POD_DK)
			local c = CFrame.new(c0) * CFrame.Angles(0, -rad(a), 0) * ang(rnd(-6, 6), 0, rnd(-8, 8)) -- local -Z = outward
			local L = len
			B:block(crop, v(0.95, 0.5, 0.95), c * CFrame.new(0, -0.2, 0), POD_DK)
			B:block(crop, v(1.5, L * 0.25, 1.5), c * CFrame.new(0, -0.4 - L * 0.125, 0), POD)
			B:block(crop, v(1.85, L * 0.5, 1.85), c * CFrame.new(0, -0.4 - L * 0.5, 0), POD_LT)
			B:block(crop, v(1.45, L * 0.25, 1.45), c * CFrame.new(0, -0.4 - L * 0.875, 0), POD)
			B:block(crop, v(0.65, 0.45, 0.65), c * CFrame.new(0, -0.6 - L, 0) * ang(0, 45, 0), POD_DK)
			-- split: turquoise pulp, neon seam, cream seeds
			local mid = c * CFrame.new(0, -0.4 - L * 0.5, -0.92)
			B:block(crop, v(1.15, L * 0.66, 0.2), mid, PULP_DK)
			B:block(crop, v(0.8, L * 0.54, 0.2), mid * CFrame.new(0, 0, -0.08), PULP)
			table.insert(podGlows, B:block(crop, v(0.32, L * 0.44, 0.14), mid * CFrame.new(0, 0, -0.16), PULP_GLOW, { mat = "Neon", name = "PodGlow" }))
			B:block(crop, v(0.24, 0.24, 0.16), mid * CFrame.new(0.3, L * 0.05, -0.17), SEED)
			B:block(crop, v(0.24, 0.24, 0.16), mid * CFrame.new(-0.3, -L * 0.05, -0.17), SEED)
		end
		for i, h in podHangs do
			pod(h.p, 2.2 + rnd(-0.2, 0.4), h.a, (i % 2 == 0) and rnd(0.6, 1) or rnd(0, 0.4))
		end

		---------------------------------------------------------------- fallen split pod on the sand
		do
			local c = cf(-3.3, 2.15, -3.5, 0, 35, 82)
			B:block(crop, v(1.3, 0.5, 1.3), c * CFrame.new(0, 0.9, 0), POD)
			B:block(crop, v(1.5, 1.2, 1.5), c, POD_LT)
			B:block(crop, v(1.2, 0.5, 1.2), c * CFrame.new(0, -0.85, 0), POD)
			B:block(crop, v(0.9, 1.0, 0.2), c * CFrame.new(0.68, 0, 0) * ang(0, 90, 0), PULP_DK)
			B:block(crop, v(0.5, 0.75, 0.2), c * CFrame.new(0.76, 0, 0) * ang(0, 90, 0), PULP)
			B:block(crop, v(0.3, 0.3, 0.3), cf(-2.2, 1.95, -4.0, 0, 30, 0), SEED)
			B:block(crop, v(0.3, 0.3, 0.3), cf(-2.6, 1.95, -4.4, 0, 70, 0), PULP)
		end

		---------------------------------------------------------------- vfx
		local podZone = B:block(crop, v(12, 4, 12), cf(0, 13.5, 0), PULP, { tr = 1, name = "PodZone" })
		B:emitter(podZone, "sparkle", { name = "PodSparkle", color = { "#ffffff", PULP_GLOW }, rate = 7, size = { 0.15, 0.35, 0 }, speed = { 0.1, 0.4 }, life = { 1.4, 2.4 } })
		B:emitter(podZone, "glow", { name = "PodMotes", color = { PULP_GLOW, "#bffff6" }, rate = 2, size = { 0.3, 0.6, 0.2 }, speed = { 0.2, 0.5 }, accel = { 0, 0.4, 0 } })
		local canopy = B:block(crop, v(13, 3, 13), cf(0, 18.5, 0), LEAF, { tr = 1, name = "Canopy" })
		B:emitter(canopy, "leaf", { name = "FallingLeaves", color = { LEAF_LT, GRASS_M }, rate = 1.2 })
		local low = B:block(crop, v(12, 1, 12), cf(0, 1.6, 0), SAND, { tr = 1, name = "SandDrift" })
		B:emitter(low, "sparkle", { name = "SandSparkle", color = { "#fff4c8", SAND_HI }, rate = 3, size = { 0.12, 0.3, 0 }, speed = { 0.2, 0.5 }, accel = { 0, 0.3, 0 } })
		B:light(podGlows[1], { color = "#7ffff0", brightness = 1.2, range = 14, name = "PodLight" })
	end,
}
