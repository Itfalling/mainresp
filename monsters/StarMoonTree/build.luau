--!nocheck
-- Celestial Moon Tree (Starlight Ruins crop #9, Divine).
-- A silver tree on an ancient star-temple platform, crowned by a floating
-- crescent moon:
-- * mound (bone "Soil", parts "Soil"): three stepped white/lavender stone
--   tile tiers with a gold trim band, an indigo star-tile platform in the
--   middle with neon constellation runes (Rune1..6), blue-green moss, star
--   dust, two cyan crystal clusters, a broken fluted pillar and a fallen
--   pillar drum
-- * a twisting silver trunk (bone "Crop") with root flares and bright bark
--   ridges, limbs fanning into a two-tier silver / periwinkle / lilac
--   canopy (Canopy1 -> Canopy2) speckled with tiny star glints
-- * the crescent MOON (bone "Moon") floats above the crown: a stepped
--   pixel crescent with a darker back plate and a glowing inner rim
-- * six hanging STAR FRUITS (Fruit1..6): chunky 8-point gold stars with
--   neon cores, each on its own stem bone (they swing and spin)
-- * three little COMET STARS (CometOrbitN -> CometN) perch around the moon;
--   on the starfall beat they dive around the tree with golden trails
-- * VFX: moon glow sparkles, canopy star dust, a STARFALL shower + moon
--   burst + landing sparks (beat), fruit star drips, rune motes;
--   moon / fruit / rune lights
-- Blocks only. No faces.
return {
	DisplayName = "Celestial Moon Tree",
	Rarity = "Divine",
	Element = "Celestial",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ------------------------------------------------------------
		local ST_DK, ST, ST_LT, ST_HI = "#8f8aad", "#bdb8d6", "#dcd9ec", "#f1effa"
		local TILE_DK, TILE = "#2c2468", "#3d3388"
		local GOLD_DK, GOLD, GOLD_LT = "#d39a26", "#efc04a", "#ffe08a"
		local MOSS_DK, MOSS = "#3f8a72", "#5fb08e"
		local CRY_DK, CRY, CRY_LT = "#3a8fd8", "#5fc8f5", "#b8f0ff"
		local BARK_DK, BARK, BARK_LT, BARK_HI = "#767c98", "#9ea4c0", "#c3c8de", "#e6e9f6"
		local LF_DK, LF, LF_MID, LF_LT, LF_SILV, LF_LIL = "#5d6cc0", "#7f8fdc", "#a2b0ec", "#c6d0f6", "#e4e9fc", "#b39ff0"
		local MOON_DK, MOON, MOON_LT, MOON_GLOW = "#e2c25e", "#fbe49a", "#fff4cc", "#fff7d6"
		local STAR_DK, STAR, STAR_LT, STAR_GLOW = "#f0a01e", "#ffcf3a", "#ffe98a", "#fff6b0"
		local RUNE = "#8fe8ff"

		local seed = 1890189
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
		-- CFrame at p whose local -Z faces outward along polar deg
		local function facing(p, deg)
			return CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
		end
		local function oct(bone, y0, y1, w, color, opts)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(bone, v(w, h, w * 0.62), cf(0, y, 0), color, opts)
			B:block(bone, v(w * 0.62, h + 0.02, w), cf(0, y, 0), color, opts)
			B:block(bone, v(w * 0.85, h - 0.03, w * 0.85), cf(0, y, 0, 0, 45, 0), color, opts)
		end
		-- chunky 8-point star in frame F (plane = local XY), scale s
		local function star(bone, F, s, cols, coreName)
			B:block(bone, v(1.05, 1.05, 0.8) * s, F, cols[1])
			B:block(bone, v(2.3, 0.6, 0.62) * s, F, cols[1])
			B:block(bone, v(0.6, 2.3, 0.62) * s, F, cols[1])
			B:block(bone, v(1.7, 0.5, 0.5) * s, F * ang(0, 0, 45), cols[2])
			B:block(bone, v(0.5, 1.7, 0.5) * s, F * ang(0, 0, 45), cols[2])
			B:block(bone, v(0.55, 0.55, 0.95) * s, F, cols[3], { mat = "Neon", name = coreName })
		end

		------------------------------------------------------------------
		-- STAR-TEMPLE PLATFORM (bone "Soil", parts "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		oct(soil, 0, 0.9, 18.0, ST_DK, S)
		oct(soil, 0.9, 1.1, 17.4, ST, S)
		oct(soil, 1.1, 1.85, 13.4, ST, S)
		oct(soil, 1.55, 1.75, 13.7, GOLD, S)
		oct(soil, 1.85, 2.05, 12.9, ST_LT, S)
		oct(soil, 2.05, 2.55, 9.4, ST_LT, S)
		oct(soil, 2.55, 2.75, 9.0, TILE, S)
		local Y1, Y2, Y3 = 1.1, 2.05, 2.75
		-- checkered tiles round tier 1
		for i = 0, 13 do
			local a = i * (360 / 14) + 6
			local x, z = polar(7.75, a)
			B:block(soil, v(1.9, 0.18, 1.6), cf(x, Y1 + 0.06, z, 0, -a, 0), (i % 2 == 0) and ST_HI or ST_LT, S)
		end
		-- chunky edge stones
		for i = 0, 11 do
			local a = i * 30 + 15 + jit(5)
			local x, z = polar(8.6, a)
			local h = 0.7 + rnd() * 0.5
			B:block(soil, v(2.2 + rnd() * 0.5, h, 1.3), cf(x, h / 2, z, 0, -a + jit(8), 0), (i % 3 == 0) and ST or ST_DK, S)
		end
		-- gold edging on the indigo platform + rune tiles
		for i = 0, 7 do
			local a = i * 45 + 22.5
			local x, z = polar(4.25, a)
			B:block(soil, v(1.6, 0.14, 0.35), cf(x, Y3 + 0.04, z, 0, -a, 0), GOLD_LT, S)
		end
		for i = 1, 6 do
			local a = (i - 1) * 60 + 30
			local x, z = polar(5.55, a)
			local F = CFrame.new(x, Y2 + 0.08, z) * ang(0, -a, 0)
			B:block(soil, v(1.5, 0.16, 1.4), F, TILE_DK, S)
			B:block(soil, v(0.9, 0.1, 0.18), F * CFrame.new(0, 0.1, 0), RUNE, { name = "Rune" .. i, mat = "Neon" })
			B:block(soil, v(0.18, 0.1, 0.9), F * CFrame.new(0, 0.1, 0) * ang(0, (i % 2 == 0) and 0 or 45, 0), RUNE, { name = "RuneB" .. i, mat = "Neon" })
		end
		-- moss
		for _, m in { { 20, 8.9 }, { 140, 8.9 }, { 250, 8.8 }, { 75, 6.7 }, { 300, 6.7 }, { 190, 4.6 } } do
			local x, z = polar(m[2], m[1])
			local y = (m[2] > 8) and Y1 or ((m[2] > 6) and Y2 or Y3)
			B:block(soil, v(2.3, 0.3, 1.4), cf(x, y + 0.08, z, 0, -m[1] + 10, 0), MOSS, S)
			B:block(soil, v(1.2, 0.34, 1.0), cf(x * 1.04, y + 0.1, z * 1.04, 0, -m[1] - 20, 0), MOSS_DK, S)
			if m[2] > 8 then
				local ox, oz = polar(m[2] + 0.55, m[1])
				B:block(soil, v(1.4, 0.9, 0.3), cf(ox, y - 0.4, oz, 0, -m[1], 0), MOSS_DK, S)
			end
		end
		-- star dust glints
		for _, d in { { 40, 7.2, Y1, STAR_GLOW }, { 160, 6.3, Y2, RUNE }, { 280, 7.6, Y1, STAR_GLOW }, { 95, 3.5, Y3, RUNE }, { 330, 3.8, Y3, STAR_GLOW }, { 210, 7.9, Y1, RUNE } } do
			local x, z = polar(d[2], d[1])
			B:block(soil, v(0.3, 0.3, 0.3), cf(x, d[3] + 0.12, z, 0, 45, 0), d[4], { name = "Soil", mat = "Neon" })
		end
		-- crystal clusters
		local function crystal(deg, r, y, sc)
			local base = at(r, deg, y)
			for k, c in { { 0, 0, 0, 2.0, CRY }, { 0.45, 0.1, 22, 1.3, CRY_LT }, { -0.45, -0.1, -25, 1.5, CRY_DK } } do
				local h = c[4] * sc
				local F = facing(base, deg) * CFrame.new(c[1] * sc, 0, c[2]) * ang(0, 0, c[3]) * CFrame.new(0, h / 2, 0)
				B:block(soil, v(0.6 * sc, h, 0.6 * sc), F * ang(0, 45, 0), c[5], S)
			end
			B:block(soil, v(0.32, 0.32, 0.32) * sc, facing(base, deg) * CFrame.new(0, 2.0 * sc + 0.1, 0) * ang(0, 45, 0), CRY_LT, { name = "Soil", mat = "Neon" })
		end
		crystal(62, 6.2, Y2, 1.0)
		crystal(300, 8.0, Y1, 0.85)
		-- broken fluted pillar (back left)
		do
			local p = at(7.2, 222, Y1)
			local F = facing(p, 222)
			B:block(soil, v(2.7, 0.6, 2.7), F * CFrame.new(0, 0.3, 0), ST_DK, S)
			B:block(soil, v(2.3, 0.4, 2.3), F * CFrame.new(0, 0.8, 0), GOLD, S)
			B:block(soil, v(1.9, 3.6, 1.9), F * CFrame.new(0, 2.8, 0), ST_HI, S)
			for k = 0, 3 do
				local q = F * ang(0, k * 90, 0) * CFrame.new(0, 2.8, -0.92)
				B:block(soil, v(0.35, 3.4, 0.22), q * CFrame.new(-0.45, 0, 0), ST, S)
				B:block(soil, v(0.35, 3.4, 0.22), q * CFrame.new(0.45, 0, 0), ST, S)
			end
			B:block(soil, v(2.1, 0.35, 2.1), F * CFrame.new(0, 3.6, 0), GOLD, S)
			B:block(soil, v(1.7, 0.9, 1.7), F * CFrame.new(0.1, 4.95, 0) * ang(0, 20, 6), ST_LT, S)
			B:block(soil, v(1.0, 0.7, 1.1), F * CFrame.new(-0.4, 5.7, 0.2) * ang(0, 35, -8), ST_HI, S)
			B:block(soil, v(0.6, 0.5, 0.6), F * CFrame.new(0.45, 5.6, -0.4) * ang(0, 10, 0), ST, S)
			B:block(soil, v(1.0, 0.25, 0.9), F * CFrame.new(-0.3, 4.6, -0.75), MOSS, S)
		end
		-- fallen pillar drum (front right)
		do
			local p = at(7.4, 112, Y1)
			local F = facing(p, 112) * ang(0, 70, 0)
			B:block(soil, v(1.8, 1.8, 2.8), F * CFrame.new(0, 0.9, 0), ST_HI, S)
			B:block(soil, v(1.95, 1.95, 0.35), F * CFrame.new(0, 0.9, 0.7), GOLD, S)
			B:block(soil, v(0.3, 0.6, 2.82), F * CFrame.new(0.95, 0.9, 0), ST, S)
			B:block(soil, v(1.3, 0.25, 1.2), F * CFrame.new(0.2, 1.9, -0.5), MOSS, S)
		end

		------------------------------------------------------------------
		-- SILVER TRUNK (bone "Crop")
		------------------------------------------------------------------
		local BASE = Y3
		local crop = B:bone("Crop", "Root", v(0, BASE, 0))
		for k = 0, 4 do
			local a = k * 72 + 20 + jit(6)
			local p1 = at(1.7, a, BASE + 1.3)
			local p2 = at(3.4, a + 10, BASE + 0.05)
			local p3 = at(4.9, a + 18, Y2 + 0.15)
			B:bar(crop, p1, p2, 1.25, 1.0, (k % 2 == 0) and BARK or BARK_DK)
			B:bar(crop, p2 - (p2 - p1).Unit * 0.3, p3, 0.85, 0.7, BARK_DK)
		end
		B:block(crop, v(4.2, 1.0, 4.2), cf(0, BASE + 0.4, 0, 0, 15, 0), BARK_DK)
		local SEG = { { 3.4, 1.0, 0, BARK }, { 3.1, 2.6, 20, BARK_LT }, { 2.8, 4.2, 40, BARK }, { 2.6, 5.8, 60, BARK_LT }, { 2.4, 6.6, 80, BARK } }
		for i, s in SEG do
			local ox, oz = polar(0.15, i * 75)
			B:block(crop, v(s[1], 1.8, s[1]), cf(ox, BASE + s[2] + 0.6, oz, 0, s[3], 0), s[4])
		end
		for _, a0 in { 30, 150, 270 } do
			local prev
			for i = 0, 3 do
				local t = i / 3
				local p = at(1.65 - t * 0.35, a0 + t * 80, BASE + 1.4 + t * 5.8)
				if prev then
					B:bar(crop, prev, p, 0.5, 0.45, (i % 2 == 0) and BARK_HI or BARK_LT)
				end
				prev = p
			end
		end
		local FORK = BASE + 7.6
		local limbs = {}
		for k = 0, 4 do
			local a = 10 + k * 72 + jit(6)
			local p0 = at(0.5, a, FORK - 0.6)
			local p1 = at(3.4, a + 8, FORK + 1.5)
			B:bar(crop, p0, p1, 1.2, 1.1, (k % 2 == 0) and BARK_LT or BARK)
			limbs[k + 1] = { a = a, p0 = p0, p1 = p1 }
		end
		B:block(crop, v(2.6, 1.6, 2.6), cf(0, FORK + 0.2, 0, 0, 30, 0), BARK_LT)

		------------------------------------------------------------------
		-- CANOPY (Canopy1 -> Canopy2)
		------------------------------------------------------------------
		local function leafCube(bone, p, s, h, col)
			return B:block(bone, v(s, h, s), CFrame.new(p) * ang(jit(8), rnd() * 90, jit(8)), col)
		end
		local function glint(bone, p)
			B:block(bone, v(0.32, 0.32, 0.32), CFrame.new(p) * ang(0, 45, 45), STAR_GLOW, { mat = "Neon", name = "Glint" })
		end
		local C1 = FORK + 2.2
		local can1 = B:bone("Canopy1", "Crop", v(0, FORK + 1.4, 0))
		for _, l in limbs do
			B:bar(can1, l.p1 - (l.p1 - l.p0).Unit * 0.4, at(5.0, l.a - 6, C1 - 0.4), 0.9, 0.8, BARK_LT)
		end
		oct(can1, C1 - 1.4, C1 + 1.2, 9.0, LF_DK)
		local ring1 = { LF, LF_MID, LF_LIL, LF_DK, LF_MID, LF_LT }
		for i = 0, 12 do
			local a = i * (360 / 13) + jit(4)
			local p = at(5.6 + jit(0.25), a, C1 + jit(0.3))
			leafCube(can1, p, 3.3 + jit(0.2), 2.4, ring1[1 + (i % #ring1)])
			if i % 3 == 1 then
				glint(can1, at(7.35, a, C1 + 0.4))
			end
		end
		for i = 0, 7 do
			local a = i * 45 + 20 + jit(5)
			local p = at(4.3 + jit(0.2), a, C1 + 1.6)
			leafCube(can1, p, 2.8 + jit(0.2), 1.2, (i % 2 == 0) and LF_LT or LF_SILV)
		end
		-- leaf tufts hanging under the rim
		for i = 0, 5 do
			local a = i * 60 + 45
			leafCube(can1, at(5.6, a, C1 - 1.9), 1.9, 1.2, (i % 2 == 0) and LF_DK or LF)
		end
		local C2 = C1 + 2.7
		local can2 = B:bone("Canopy2", "Canopy1", v(0, C1 + 1.5, 0))
		oct(can2, C2 - 1.2, C2 + 1.1, 5.8, LF)
		local ring2 = { LF_MID, LF_LT, LF_LIL, LF_SILV }
		for i = 0, 7 do
			local a = i * 45 + 22 + jit(5)
			local p = at(3.6 + jit(0.2), a, C2 + jit(0.25))
			leafCube(can2, p, 2.9 + jit(0.2), 2.0, ring2[1 + (i % #ring2)])
			if i % 3 == 0 then
				glint(can2, at(5.1, a, C2 + 0.3))
			end
		end
		for i = 0, 3 do
			local a = i * 90 + 45
			leafCube(can2, at(1.8, a, C2 + 1.45), 2.2, 1.0, (i % 2 == 0) and LF_SILV or LF_LT)
		end
		leafCube(can2, v(0, C2 + 1.8, 0), 2.4, 1.2, LF_SILV)
		glint(can2, v(1.0, C2 + 2.35, 0.6))

		------------------------------------------------------------------
		-- CRESCENT MOON (bone "Moon"), floating over the crown
		------------------------------------------------------------------
		local MC = C2 + 5.35
		local moon = B:bone("Moon", "Root", v(0, MC, 0))
		local R, cell = 2.9, 0.58
		local icx, icy, Ri = -1.3, 0.45, 2.45
		local MF = CFrame.new(0, MC, 0)
		local function q(x)
			return math.floor(x / cell + 0.5) * cell
		end
		local nrow, nrim = 0, 0
		local y = -R + cell * 0.5
		while y < R do
			local xo = math.sqrt(math.max(R * R - y * y, 0))
			local a0, a1 = q(-xo), q(xo)
			local runs = {}
			local dy = y - icy
			if dy * dy < Ri * Ri then
				local xi = math.sqrt(Ri * Ri - dy * dy)
				local b0, b1 = q(icx - xi), q(icx + xi)
				if b0 > a0 then
					table.insert(runs, { a0, math.min(b0, a1), "L" })
				end
				if b1 < a1 then
					table.insert(runs, { math.max(b1, a0), a1, "R" })
				end
			else
				table.insert(runs, { a0, a1, "" })
			end
			nrow += 1
			for _, r in runs do
				local len = r[2] - r[1]
				if len > 0.01 then
					local cx = (r[1] + r[2]) / 2
					local col = (nrow % 2 == 0) and MOON or MOON_LT
					B:block(moon, v(len, cell + 0.02, 1.3), MF * CFrame.new(cx, y, 0), col)
					B:block(moon, v(len + 0.3, cell + 0.1, 0.5), MF * CFrame.new(cx, y, 0.75), MOON_DK)
					-- inner rim glow on the side facing the hollow
					if r[3] == "R" then
						nrim += 1
						B:block(moon, v(0.35, cell, 1.4), MF * CFrame.new(r[1] + 0.17, y, -0.02), MOON_GLOW, { mat = "Neon", name = "MoonRim" .. nrim })
					end
				end
			end
			y += cell
		end
		-- crater dimples on the face
		for _, c in { { 1.8, 0.7, 0.6 }, { 1.0, -1.8, 0.5 }, { 2.1, -0.8, 0.4 } } do
			B:block(moon, v(c[3], c[3], 0.2), MF * CFrame.new(c[1], c[2], -0.7), MOON_DK)
		end
		-- tiny star sparks hung off the moon horns
		B:block(moon, v(0.4, 0.4, 0.4), MF * CFrame.new(-1.5, R - 0.1, 0) * ang(0, 0, 45), STAR_GLOW, { mat = "Neon", name = "MoonSpark" })
		B:block(moon, v(0.4, 0.4, 0.4), MF * CFrame.new(-1.2, -R + 0.05, 0) * ang(0, 0, 45), STAR_GLOW, { mat = "Neon", name = "MoonSpark" })

		------------------------------------------------------------------
		-- SILVER LEAF TASSELS (Tassel1..6) hanging from the rim
		------------------------------------------------------------------
		for i = 1, 6 do
			local a = (i - 1) * 60
			local top = at(6.4, a, C1 - 1.0)
			local tb = B:bone("Tassel" .. i, "Canopy1", top)
			local F = facing(top, a)
			local len = (i % 2 == 0) and 3 or 2
			for k = 1, len do
				local sz = 1.5 - k * 0.22
				B:block(tb, v(sz, 1.25, sz), F * CFrame.new(0, -0.55 - (k - 1) * 1.1, 0) * ang(0, 45 * (k % 2), 0),
					(k % 2 == 1) and LF_SILV or LF_LT)
			end
			B:block(tb, v(0.36, 0.36, 0.36), F * CFrame.new(0, -0.55 - len * 1.1 + 0.25, 0) * ang(0, 45, 45), STAR_GLOW, { mat = "Neon", name = "TasselTip" .. i })
		end

		------------------------------------------------------------------
		-- HANGING STAR FRUITS (Fruit1..6 on Canopy1)
		------------------------------------------------------------------
		local UNDER = C1 - 1.5
		local FRUITS = { { 30, 4.8, 0.9, 1.3 }, { 90, 5.5, 1.7, 1.15 }, { 150, 4.8, 1.0, 1.3 }, { 210, 5.5, 1.6, 1.15 }, { 270, 4.8, 0.9, 1.3 }, { 330, 5.5, 1.8, 1.15 } }
		for i, f in FRUITS do
			local top = at(f[2], f[1], UNDER)
			local bone = B:bone("Fruit" .. i, "Canopy1", top)
			local s = f[4]
			local c = top - v(0, f[3] + 1.2 * s, 0)
			B:bar(bone, top + v(0, 0.3, 0), c + v(0, 1.0 * s, 0), 0.25, 0.25, BARK_DK)
			B:block(bone, v(0.6, 0.35, 0.6), CFrame.new(top - v(0, f[3] - 0.1, 0)) * ang(0, 45, 0), LF_DK)
			star(bone, facing(c, f[1]), s, { STAR, STAR_LT, STAR_GLOW }, "FruitCore" .. i)
		end

		------------------------------------------------------------------
		-- COMET STARS perched round the moon (CometOrbitN -> CometN)
		------------------------------------------------------------------
		local COMETS = { { 40, 3.7, 1.2 }, { 160, 3.9, -0.9 }, { 280, 3.6, 0.4 } }
		for n, cm in COMETS do
			local OP = CFrame.new(0, MC, 0) * ang(0, -cm[1], 0)
			B:bone("CometOrbit" .. n, "Root", OP)
			local CP = OP * CFrame.new(0, cm[3], -cm[2])
			local cb = B:bone("Comet" .. n, "CometOrbit" .. n, CP)
			star(cb, CP, 0.62, { STAR_LT, STAR, STAR_GLOW }, "CometCore" .. n)
			B:trail(cb, CP * v(0, 0.45, 0), CP * v(0, -0.45, 0),
				{ name = "CometTrail" .. n, color = { "#ffffff", STAR_LT, STAR }, life = 0.6, width = { 1, 0.1 }, trans = { 0.1, 1 } })
		end

		------------------------------------------------------------------
		-- VFX: 7 emitters, 3 lights, 3 trails
		------------------------------------------------------------------
		local moonFx = B:block(moon, v(5.5, 5.5, 2), cf(0, MC, 0), MOON, { tr = 1, name = "MoonFx" })
		B:emitter(moonFx, "sparkle", { name = "MoonSparkle", color = { "#ffffff", MOON_LT, MOON }, rate = 8, size = { 0.2, 0.6, 0 }, life = { 0.8, 1.5 }, speed = { 0.3, 0.9 }, light = 1 })
		B:emitter(moonFx, "burst", { name = "MoonBurst", color = { "#ffffff", MOON_LT, STAR_LT }, size = { 0.9, 0.6, 0 }, speed = { 8, 15 }, life = { 0.5, 1.0 }, drag = 2.6, light = 1 })
		local fallZone = B:block(moon, v(15, 0.5, 15), cf(0, MC + 0.5, 0), MOON, { tr = 1, name = "StarfallZone" })
		B:emitter(fallZone, "drip", { name = "Starfall", rate = 0, color = { "#ffffff", STAR_LT, STAR }, size = { 0.6, 0.5, 0.15 }, life = { 1.3, 1.9 }, speed = { 5, 9 }, spread = 12, accel = { 0, -9, 0 }, light = 1, trans = { 0, 0, 0.5 }, rot = { 0, 90 } })
		local dust = B:block(can1, v(18, 10, 18), cf(0, C1 + 3, 0), LF, { tr = 1, name = "DustZone" })
		B:emitter(dust, "sparkle", { name = "StarDust", color = { "#ffffff", "#cfe0ff", "#b9a6ff" }, rate = 12, size = { 0.15, 0.5, 0 }, life = { 1.0, 2.0 }, speed = { 0.2, 0.6 }, light = 0.9 })
		local dripZone = B:block(can1, v(12, 0.5, 12), cf(0, UNDER - 2.6, 0), STAR, { tr = 1, name = "FruitDripZone" })
		B:emitter(dripZone, "drip", { name = "StarDrips", color = { STAR_GLOW, STAR }, rate = 3, size = { 0.3, 0.3, 0.1 }, life = { 1.0, 1.4 }, accel = { 0, -10, 0 }, light = 0.8 })
		local runeZone = B:block(soil, v(12, 0.6, 12), cf(0, Y2 + 0.4, 0), TILE, { tr = 1, name = "RuneZone" })
		B:emitter(runeZone, "ember", { name = "RuneMotes", tex = "sparkle", color = { "#ffffff", RUNE, "#a58cff" }, rate = 4, size = { 0.3, 0.25, 0 }, life = { 1.4, 2.2 }, speed = { 0.6, 1.4 }, accel = { 0, 1.2, 0 }, light = 1 })
		B:emitter(runeZone, "burst", { name = "LandSparks", color = { "#ffffff", STAR_LT, RUNE }, size = { 0.6, 0.45, 0 }, speed = { 5, 10 }, life = { 0.4, 0.8 }, spread = 70, drag = 3, accel = { 0, -6, 0 }, light = 1 })
		local ml = B:block(moon, v(0.4, 0.4, 0.4), cf(0, MC, -1.4), MOON, { tr = 1, name = "MoonLightCore" })
		B:light(ml, { name = "MoonLight", color = "#fff1c0", brightness = 1.2, range = 18 })
		local fl = B:block(can1, v(0.4, 0.4, 0.4), cf(0, UNDER - 2.0, 0), STAR, { tr = 1, name = "FruitLightCore" })
		B:light(fl, { name = "FruitLight", color = "#ffd76a", brightness = 0.9, range = 14 })
		local rl = B:block(soil, v(0.4, 0.4, 0.4), cf(0, Y3 + 0.8, -3), TILE, { tr = 1, name = "RuneLightCore" })
		B:light(rl, { name = "RuneLight", color = "#8fe8ff", brightness = 0.6, range = 12 })
	end,
}
