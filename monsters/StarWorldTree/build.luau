--!nocheck
-- Starforge World Tree (Starlight Ruins crop #10, Apex) - the showpiece of
-- the whole game. A colossal cosmic tree growing out of a ruined star temple:
-- * TEMPLE (bone "Soil", parts "Soil"): three stepped white-stone tiers with
--   gold trim bands, an indigo star-tile floor, front stairs, a ring of rune
--   tiles (Rune1..8) and two neon constellations, crystal clusters, moss,
--   a broken ARCH (two tall fluted pillars with snapped lintels) at the back
--   and two broken pillar stumps at the front
-- * three FLOATING RUIN STONES (Float1..3) hover around the temple
-- * a huge twisting deep-violet TRUNK (bone "Crop") with giant roots
--   gripping the steps and three spiralling neon STARFORGE VEINS (VeinK_J)
--   that pulse energy up into the crown
-- * the GALAXY CANOPY (Canopy -> Galaxy -> Canopy2): a nebula leaf dome with
--   three long SPIRAL ARMS (violet -> pink -> cyan, star glints) that turn
--   like a galaxy; six star fruits (Fruit1..6: gold / cyan / pink) hang from
--   the arms and are carried round
-- * the FORGE SPIRE rises through the dome and holds the STARFORGE HEART
--   (bone "Core"): a 3D 14-point star with a neon core and six ray bones
--   (Ray1..6), circled by two tilted ARMILLARY RINGS (RingA, RingB) with
--   glowing beads; hidden nova shards (Shard1..8) and a hidden SKY BEAM
--   (BeamCore, BeamGlow) appear on the supernova
-- * four PLANETS on tilted orbits (OrbitN -> PlanetN): a ringed amber giant,
--   a teal ocean world, a rose world and a little violet moon-world
-- * VFX: supernova burst + nebula dust, galaxy star dust, star rain, core
--   sparkles, vein motes, rune motes + forge sparks; core / galaxy / rune /
--   vein lights; trails on planets + ring beads
-- Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Starforge World Tree",
	Rarity = "Apex",
	Element = "Cosmic",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ------------------------------------------------------------
		local ST_DK, ST, ST_LT, ST_HI = "#8d88ad", "#bab5d4", "#dad7eb", "#f2f0fa"
		local TILE_DK, TILE = "#241c5c", "#33297e"
		local GOLD_DK, GOLD, GOLD_LT = "#cf9424", "#efbe45", "#ffe08a"
		local MOSS_DK, MOSS = "#3c8670", "#5aae8c"
		local BARK_DK, BARK, BARK_LT, BARK_HI = "#2b2154", "#3e3176", "#544396", "#6c58b6"
		local NEB_DK, NEB_IN, NEB_VI, NEB_PU = "#2c2170", "#3f33a6", "#5e3fc4", "#8150d6"
		local NEB_MG, NEB_PK, NEB_PK2 = "#b157d8", "#e070cf", "#ff9ad8"
		local NEB_BL, NEB_CY, NEB_CY2 = "#4766da", "#3fb6e6", "#7fe0f4"
		local STAR_DK, STAR, STAR_LT, STAR_GLOW = "#f29a1c", "#ffc83a", "#ffe58a", "#fff4c2"
		local CYAN_GLOW, PINK_GLOW, RUNE = "#8ff4ff", "#ffb3ec", "#8fe8ff"
		local CRY_V, CRY_V2, CRY_C, CRY_C2 = "#8a5cf0", "#c3a6ff", "#47c4f2", "#b8f0ff"

		local seed = 1900190
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
		-- STAR TEMPLE (bone "Soil", parts "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local SN = function(n)
			return { name = n or "Soil", mat = "Neon" }
		end
		oct(soil, 0, 1.2, 26.0, ST_DK, S)
		oct(soil, 1.2, 1.4, 25.4, ST, S)
		oct(soil, 1.4, 2.6, 20.0, ST, S)
		oct(soil, 2.15, 2.4, 20.3, GOLD, S)
		oct(soil, 2.6, 2.8, 19.4, ST_LT, S)
		oct(soil, 2.8, 3.9, 14.0, ST_LT, S)
		oct(soil, 3.45, 3.68, 14.3, GOLD, S)
		oct(soil, 3.9, 4.1, 13.4, TILE, S)
		local Y1, Y2, Y3 = 1.4, 2.8, 4.1
		-- checkered tiles on tier 1 and tier 2
		for i = 0, 17 do
			local a = i * 20 + 10
			if math.abs(((a + 180) % 360) - 180) > 14 then
				local x, z = polar(11.4, a)
				B:block(soil, v(2.4, 0.18, 1.9), cf(x, Y1 + 0.06, z, 0, -a, 0), (i % 2 == 0) and ST_HI or ST_LT, S)
			end
		end
		-- chunky edge blocks round the base
		for i = 0, 15 do
			local a = i * 22.5 + 11 + jit(4)
			local x, z = polar(12.6, a)
			local h = 0.8 + rnd() * 0.6
			B:block(soil, v(2.6 + rnd() * 0.6, h, 1.4), cf(x, h / 2, z, 0, -a + jit(8), 0), (i % 3 == 0) and ST or ST_DK, S)
		end
		-- front stairs (deg 0 = -Z)
		for _, st in { { 10.0, Y1, Y2 }, { 7.0, Y2, Y3 } } do
			local E, yl, yu = st[1], st[2], st[3]
			local hh = (yu - yl) / 2
			B:block(soil, v(5.0, hh, 0.9), cf(0, yl + hh / 2, -(E + 1.25)), ST_HI, S)
			B:block(soil, v(5.0, hh * 2, 0.9), cf(0, yl + hh, -(E + 0.4)), ST_LT, S)
			B:block(soil, v(0.6, hh * 2 + 0.3, 1.9), cf(2.8, yl + hh + 0.1, -(E + 0.85)), GOLD, S)
			B:block(soil, v(0.6, hh * 2 + 0.3, 1.9), cf(-2.8, yl + hh + 0.1, -(E + 0.85)), GOLD, S)
		end
		-- gold edging on the indigo floor
		for i = 0, 7 do
			local a = i * 45 + 22.5
			local x, z = polar(6.4, a)
			B:block(soil, v(2.3, 0.14, 0.4), cf(x, Y3 + 0.04, z, 0, -a, 0), GOLD_LT, S)
		end
		-- rune tiles on tier 2 (Rune1..8 + RuneBn)
		for i = 1, 8 do
			local a = (i - 1) * 45 + 22.5
			local x, z = polar(8.45, a)
			local F = CFrame.new(x, Y2 + 0.08, z) * ang(0, -a, 0)
			B:block(soil, v(1.7, 0.16, 1.5), F, TILE_DK, S)
			B:block(soil, v(1.0, 0.1, 0.2), F * CFrame.new(0, 0.1, 0), RUNE, SN("Rune" .. i))
			B:block(soil, v(0.2, 0.1, 1.0), F * CFrame.new(0, 0.1, 0) * ang(0, (i % 2 == 0) and 0 or 45, 0), RUNE, SN("RuneB" .. i))
		end
		-- constellations on the indigo floor (neon stars linked by gold lines)
		local function constellation(pts)
			for k, p in pts do
				local wp = v(p[1], Y3 + 0.14, p[2])
				B:block(soil, v(0.36, 0.14, 0.36), CFrame.new(wp) * ang(0, 45, 0), STAR_GLOW, SN())
				if k > 1 then
					local q = v(pts[k - 1][1], Y3 + 0.1, pts[k - 1][2])
					B:bar(soil, q, v(p[1], Y3 + 0.1, p[2]), 0.12, 0.08, GOLD_LT, S)
				end
			end
		end
		constellation({ { -5.6, -1.6 }, { -4.7, -3.3 }, { -3.2, -4.6 }, { -4.6, -5.2 } })
		constellation({ { 4.4, 2.6 }, { 5.6, 1.2 }, { 4.9, -0.6 }, { 3.6, 4.6 } })
		-- moss
		for _, m in { { 30, 12.9, Y1 }, { 160, 12.9, Y1 }, { 260, 12.8, Y1 }, { 100, 9.6, Y2 }, { 300, 9.6, Y2 }, { 200, 6.6, Y3 } } do
			local x, z = polar(m[2] - 0.4, m[1])
			B:block(soil, v(2.6, 0.3, 1.5), cf(x, m[3] + 0.08, z, 0, -m[1] + 10, 0), MOSS, S)
			B:block(soil, v(1.3, 0.34, 1.1), cf(x * 1.03, m[3] + 0.1, z * 1.03, 0, -m[1] - 20, 0), MOSS_DK, S)
			local ox, oz = polar(m[2] + 0.25, m[1])
			B:block(soil, v(1.5, 0.9, 0.3), cf(ox, m[3] - 0.4, oz, 0, -m[1], 0), MOSS_DK, S)
		end
		-- crystal clusters
		local function crystal(deg, r, y, sc, c1, c2, tip)
			local base = at(r, deg, y)
			for _, c in { { 0, 0, 0, 2.4, c1 }, { 0.55, 0.15, 24, 1.5, c2 }, { -0.55, -0.1, -26, 1.8, c1 }, { 0.1, 0.5, -8, 1.2, c2 } } do
				local h = c[4] * sc
				local F = facing(base, deg) * CFrame.new(c[1] * sc, 0, c[2] * sc) * ang(c[2] * 20, 0, c[3]) * CFrame.new(0, h / 2, 0)
				B:block(soil, v(0.7 * sc, h, 0.7 * sc), F * ang(0, 45, 0), c[5], S)
			end
			B:block(soil, v(0.36, 0.36, 0.36) * sc, facing(base, deg) * CFrame.new(0, 2.4 * sc + 0.1, 0) * ang(0, 45, 0), tip, SN())
		end
		crystal(112, 8.6, Y2, 1.0, CRY_V, CRY_V2, PINK_GLOW)
		crystal(250, 11.9, Y1, 0.9, CRY_C, CRY_C2, CYAN_GLOW)
		crystal(338, 5.6, Y3, 0.7, CRY_V, CRY_C2, CYAN_GLOW)
		-- pillars
		local function pillar(deg, r, h, top)
			local p = at(r, deg, Y1)
			local F = facing(p, deg)
			B:block(soil, v(3.0, 0.7, 3.0), F * CFrame.new(0, 0.35, 0), ST_DK, S)
			B:block(soil, v(2.6, 0.35, 2.6), F * CFrame.new(0, 0.85, 0), GOLD, S)
			local sh = h - 1.0
			B:block(soil, v(2.1, sh, 2.1), F * CFrame.new(0, 1.0 + sh / 2, 0), ST_HI, S)
			for k = 0, 3 do
				local q = F * ang(0, k * 90, 0) * CFrame.new(0, 1.0 + sh / 2, -1.02)
				B:block(soil, v(0.36, sh - 0.2, 0.22), q * CFrame.new(-0.5, 0, 0), ST, S)
				B:block(soil, v(0.36, sh - 0.2, 0.22), q * CFrame.new(0.5, 0, 0), ST, S)
			end
			B:block(soil, v(2.35, 0.35, 2.35), F * CFrame.new(0, 1.0 + sh * 0.62, 0), GOLD, S)
			if top == "cap" then
				B:block(soil, v(2.8, 0.6, 2.8), F * CFrame.new(0, h + 0.3, 0), ST_LT, S)
				B:block(soil, v(3.2, 0.5, 3.2), F * CFrame.new(0, h + 0.85, 0), ST_HI, S)
				B:block(soil, v(2.9, 0.22, 2.9), F * CFrame.new(0, h + 0.62, 0), GOLD_LT, S)
				return p + v(0, h + 1.1, 0)
			else
				B:block(soil, v(1.8, 0.9, 1.6), F * CFrame.new(0.15, h + 0.3, 0.1) * ang(0, 18, 7), ST_LT, S)
				B:block(soil, v(1.0, 0.7, 1.0), F * CFrame.new(-0.45, h + 1.0, 0.25) * ang(0, 34, -9), ST_HI, S)
				B:block(soil, v(1.1, 0.25, 0.9), F * CFrame.new(0.3, h - 0.4, -0.85), MOSS, S)
				return p + v(0, h, 0)
			end
		end
		local topR = pillar(135, 10.0, 9.4, "cap")
		local topL = pillar(225, 10.0, 8.6, "cap")
		pillar(45, 10.2, 4.2, "broken")
		pillar(315, 10.2, 2.6, "broken")
		-- snapped lintels reaching toward each other (a broken arch)
		for _, tp in { { topR, -1 }, { topL, 1 } } do
			local p0 = tp[1] + v(1.0 * -tp[2], 0.75, 0)
			local p1 = p0 + v(tp[2] * 5.2, 0, 0)
			B:block(soil, v(6.4, 1.5, 2.0), CFrame.new((p0 + p1) / 2 + v(-tp[2] * 0.6, 0, 0)), ST_LT, S)
			B:block(soil, v(6.5, 0.3, 2.1), CFrame.new((p0 + p1) / 2 + v(-tp[2] * 0.6, -0.55, 0)), GOLD, S)
			B:block(soil, v(1.2, 1.1, 1.7), CFrame.new(p1 + v(tp[2] * 0.2, 0.2, 0)) * ang(0, 0, tp[2] * -14), ST_HI, S)
			B:block(soil, v(0.7, 0.3, 0.7), CFrame.new(p0 + v(tp[2] * 2.2, 0.62, -0.2)) * ang(0, 45, 0), STAR_GLOW, SN())
		end
		-- fallen drum near the front stump
		do
			local p = at(11.2, 292, Y1)
			local F = facing(p, 292) * ang(0, 65, 0)
			B:block(soil, v(1.9, 1.9, 2.6), F * CFrame.new(0, 0.95, 0), ST_HI, S)
			B:block(soil, v(2.05, 2.05, 0.35), F * CFrame.new(0, 0.95, 0.65), GOLD, S)
			B:block(soil, v(1.2, 0.25, 1.2), F * CFrame.new(0.2, 2.0, -0.4), MOSS, S)
		end

		------------------------------------------------------------------
		-- FLOATING RUIN STONES (Float1..3)
		------------------------------------------------------------------
		for i, f in { { 90, 11.6, 5.6 }, { 180, 11.4, 6.6 }, { 270, 11.6, 5.0 } } do
			local p = at(f[2], f[1], f[3])
			local fb = B:bone("Float" .. i, "Root", p)
			local F = facing(p, f[1]) * ang(jit(8), jit(20), jit(8))
			B:block(fb, v(2.0, 1.3, 1.7), F, ST_LT)
			B:block(fb, v(1.6, 0.45, 1.3), F * CFrame.new(0.15, 0.85, 0.1) * ang(0, 20, 0), ST_HI)
			B:block(fb, v(1.1, 0.7, 1.0), F * CFrame.new(-0.3, -0.85, 0) * ang(0, 35, 0), ST)
			B:block(fb, v(0.9, 0.16, 0.12), F * CFrame.new(0, 0.1, -0.88), RUNE, { mat = "Neon", name = "FloatRune" .. i })
			B:block(fb, v(0.16, 0.7, 0.12), F * CFrame.new(0, 0.1, -0.88), RUNE, { mat = "Neon", name = "FloatRuneB" .. i })
		end

		------------------------------------------------------------------
		-- TRUNK (bone "Crop") with starforge veins
		------------------------------------------------------------------
		local function leafCube(bone, p, s, h, col, tilt)
			tilt = tilt or 8
			return B:block(bone, v(s, h, s), CFrame.new(p) * ang(jit(tilt), rnd() * 90, jit(tilt)), col)
		end
		local nGlint = 0
		local function glint(bone, p, col)
			nGlint += 1
			B:block(bone, v(0.4, 0.4, 0.4), CFrame.new(p) * ang(0, 45, 45), col or STAR_GLOW, { mat = "Neon", name = "Glint" .. nGlint })
		end
		local BASE = Y3
		local crop = B:bone("Crop", "Root", v(0, BASE, 0))
		for k = 0, 5 do
			local a = k * 60 + 10 + jit(5)
			local p1 = at(3.4, a, BASE + 2.0)
			local p2 = at(6.0, a + 8, BASE + 0.15)
			local p3 = at(8.5, a + 18, Y2 + 0.25)
			B:bar(crop, p1, p2, 2.3, 1.8, (k % 2 == 0) and BARK or BARK_DK)
			B:bar(crop, p2 - (p2 - p1).Unit * 0.4, p3, 1.5, 1.2, BARK_DK)
			B:block(crop, v(1.2, 0.9, 1.2), CFrame.new(p3 + v(0, -0.1, 0)) * ang(0, -a, 0), BARK)
		end
		B:block(crop, v(8.0, 1.4, 8.0), cf(0, BASE + 0.5, 0, 0, 15, 0), BARK_DK)
		local SEG = { { 6.4, 0, BARK }, { 5.9, 15, BARK_LT }, { 5.4, 30, BARK }, { 5.0, 45, BARK_DK }, { 4.6, 60, BARK }, { 4.3, 75, BARK_LT }, { 4.0, 90, BARK } }
		for i, s in SEG do
			local ox, oz = polar(0.3, i * 70)
			B:block(crop, v(s[1], 2.4, s[1]), cf(ox, BASE + 1.3 + (i - 1) * 2.05, oz, 0, s[2], 0), s[3])
		end
		-- bark ridges
		for _, a0 in { 60, 180, 300 } do
			local prev
			for i = 0, 4 do
				local t = i / 4
				local p = at(3.2 - t * 1.1, a0 - t * 100, BASE + 1.8 + t * 11.5)
				if prev then
					B:bar(crop, prev, p, 0.8, 0.7, (i % 2 == 0) and BARK_HI or BARK_LT)
				end
				prev = p
			end
		end
		-- starforge veins: 3 spirals x 5 neon segments
		local VCOL = { CYAN_GLOW, STAR_GLOW, PINK_GLOW }
		for k, a0 in { 0, 120, 240 } do
			local prev
			for j = 0, 5 do
				local t = j / 5
				local p = at(3.35 - t * 1.25, a0 + t * 110, BASE + 1.0 + t * 12.5)
				if prev then
					B:bar(crop, prev, p, 0.45, 0.45, VCOL[k], { mat = "Neon", name = "Vein" .. k .. "_" .. j })
				end
				prev = p
			end
		end
		-- two short side branches with nebula leaf tufts break up the trunk
		for _, sb in { { 105, BASE + 8.2 }, { 255, BASE + 10.0 } } do
			local p0 = at(1.6, sb[1], sb[2])
			local p1 = at(5.2, sb[1] + 6, sb[2] + 2.0)
			B:bar(crop, p0, p1, 1.2, 1.1, BARK_LT)
			leafCube(crop, p1 + v(0, 0.6, 0), 2.6, 1.8, NEB_PU)
			leafCube(crop, at(6.3, sb[1] + 12, sb[2] + 2.1), 2.0, 1.5, NEB_MG)
			leafCube(crop, at(5.0, sb[1] - 4, sb[2] + 3.0), 1.8, 1.2, NEB_PK)
			glint(crop, at(6.0, sb[1] + 2, sb[2] + 3.3), PINK_GLOW)
		end
		local FORK = BASE + 13.6
		local limbs = {}
		for k = 0, 5 do
			local a = 30 + k * 60 + jit(5)
			local p0 = at(0.8, a, FORK - 1.2)
			local p1 = at(4.6, a + 8, FORK + 1.6)
			B:bar(crop, p0, p1, 2.0, 1.8, (k % 2 == 0) and BARK_LT or BARK)
			limbs[k + 1] = { a = a, p0 = p0, p1 = p1 }
		end
		B:block(crop, v(4.2, 2.0, 4.2), cf(0, FORK, 0, 0, 30, 0), BARK_LT)

		------------------------------------------------------------------
		-- GALAXY CANOPY (Canopy sway -> Galaxy spin -> Canopy2)
		------------------------------------------------------------------
		local CY = FORK + 3.4
		local can = B:bone("Canopy", "Crop", v(0, FORK + 1.5, 0))
		for _, l in limbs do
			B:bar(can, l.p1 - (l.p1 - l.p0).Unit * 0.5, at(5.6, l.a - 6, CY - 1.0), 1.3, 1.2, BARK_LT)
		end
		local gal = B:bone("Galaxy", "Canopy", v(0, CY, 0))
		-- nebula dome core
		oct(gal, CY - 1.8, CY + 1.4, 12.4, NEB_DK)
		local domeCols = { NEB_IN, NEB_VI, NEB_PU, NEB_IN, NEB_MG, NEB_VI }
		for i = 0, 10 do
			local a = i * (360 / 11) + jit(4)
			leafCube(gal, at(5.2 + jit(0.2), a, CY + 0.2 + jit(0.3)), 4.0 + jit(0.2), 2.8, domeCols[1 + (i % #domeCols)])
		end
		for i = 0, 5 do
			local a = i * 60 + 30
			leafCube(gal, at(4.6, a, CY - 2.0), 2.4, 1.4, NEB_DK)
		end
		-- three spiral arms: main cubes on the spiral, lighter cubes on top at
		-- the half steps so each arm reads as one continuous swirl
		local NA, SWEEP = 12, 165
		local ARMCOL = { NEB_VI, NEB_VI, NEB_PU, NEB_PU, NEB_MG, NEB_MG, NEB_PK, NEB_PK, NEB_BL, NEB_BL, NEB_CY, NEB_CY }
		local TOPCOL = { NEB_PU, NEB_MG, NEB_MG, NEB_PK, NEB_PK, NEB_PK2, NEB_PK2, NEB_BL, NEB_CY, NEB_CY2, NEB_CY2, "#cdf6ff" }
		local function armAt(k, u)
			local r = 5.8 + 8.2 * u
			local a = k * 120 + SWEEP * u
			local y = CY - 0.1 - 1.5 * u * u
			return r, a, y, 4.1 - 1.6 * u, 2.4 - 1.0 * u
		end
		local armPts = {}
		for k = 0, 2 do
			armPts[k + 1] = {}
			for j = 0, NA - 1 do
				local u = j / (NA - 1)
				local r, a, y, sz, h = armAt(k, u)
				local p = at(r, a, y)
				leafCube(gal, p, sz, h, ARMCOL[j + 1], 5)
				if j < NA - 1 then
					local r2, a2, y2, sz2, h2 = armAt(k, (j + 0.5) / (NA - 1))
					B:block(gal, v(sz2 * 0.7, h2 * 0.6, sz2 * 0.7), CFrame.new(at(r2, a2, y2 + h2 * 0.45)) * ang(0, rnd() * 90, 0), TOPCOL[j + 1])
				end
				if j == 3 or j == 7 or j == 11 then
					glint(gal, at(r + 0.3, a + 4, y + h * 0.5 + 0.35), (j == 11) and CYAN_GLOW or STAR_GLOW)
				end
				armPts[k + 1][j + 1] = { p = p, a = a, r = r, h = h }
			end
		end
		-- upper dome
		local CY2 = CY + 3.0
		local can2 = B:bone("Canopy2", "Galaxy", v(0, CY + 1.4, 0))
		oct(can2, CY2 - 1.2, CY2 + 1.0, 7.0, NEB_IN)
		local upCols = { NEB_PU, NEB_MG, NEB_VI, NEB_PK, NEB_BL, NEB_PU, NEB_MG }
		for i = 0, 6 do
			local a = i * (360 / 7) + 20 + jit(5)
			leafCube(can2, at(3.4 + jit(0.2), a, CY2 + jit(0.25)), 3.0 + jit(0.2), 2.2, upCols[i + 1])
			if i % 2 == 0 then
				glint(can2, at(4.9, a, CY2 + 0.5), (i % 4 == 0) and STAR_GLOW or PINK_GLOW)
			end
		end
		-- third tier + glowing galactic bulge round the spire
		local CY3 = CY2 + 2.3
		oct(can2, CY3 - 1.0, CY3 + 0.7, 4.6, NEB_VI)
		for i = 0, 4 do
			local a = i * 72 + 10 + jit(5)
			leafCube(can2, at(2.1, a, CY3 + jit(0.2)), 2.4, 1.7, (i % 2 == 0) and NEB_PK or NEB_MG)
		end
		oct(can2, CY3 + 0.7, CY3 + 1.1, 3.0, STAR_LT)
		oct(can2, CY3 + 1.1, CY3 + 1.35, 2.3, GOLD)
		for i = 1, 4 do
			local a = (i - 1) * 90 + 45
			B:block(can2, v(0.5, 0.5, 0.5), CFrame.new(at(1.55, a, CY3 + 1.0)) * ang(0, 45, 0), STAR_GLOW, { mat = "Neon", name = "Bulge" .. i })
		end

		------------------------------------------------------------------
		-- STAR FRUITS hanging from the arms (Fruit1..6 on Galaxy)
		------------------------------------------------------------------
		local FCOLS = {
			{ STAR, STAR_LT, STAR_GLOW },
			{ NEB_CY, NEB_CY2, CYAN_GLOW },
			{ NEB_PK, NEB_PK2, PINK_GLOW },
		}
		local FR = {}
		local nf = 0
		for k = 1, 3 do
			for _, j in { 5, 9 } do
				nf += 1
				local ap = armPts[k][j]
				local top = ap.p - v(0, ap.h * 0.5 - 0.1, 0)
				local bone = B:bone("Fruit" .. nf, "Galaxy", top)
				local s = (j == 5) and 1.5 or 1.3
				local stem = (j == 5) and 1.3 or 0.9
				local c = top - v(0, stem + 1.15 * s, 0)
				B:bar(bone, top + v(0, 0.3, 0), c + v(0, 1.0 * s, 0), 0.3, 0.3, BARK_HI)
				B:block(bone, v(0.7, 0.4, 0.7), CFrame.new(top - v(0, 0.3, 0)) * ang(0, 45, 0), NEB_DK)
				star(bone, facing(c, ap.a), s, FCOLS[k], "FruitCore" .. nf)
				FR[nf] = ap.a
			end
		end

		------------------------------------------------------------------
		-- FORGE SPIRE + STARFORGE HEART (bone "Core") + armillary rings
		------------------------------------------------------------------
		local SC = CY2 + 9.0
		local spBase = CY2 + 1.0
		local spire = { { 2.2, 1.6, BARK }, { 1.8, 1.6, BARK_LT }, { 1.4, 1.4, BARK }, { 1.0, 1.2, BARK_LT } }
		local y = spBase
		for i, sp in spire do
			B:block(can, v(sp[1], sp[2], sp[1]), cf(0, y + sp[2] / 2, 0, 0, i * 25, 0), sp[3])
			y += sp[2] - 0.05
			if i == 2 then
				B:block(can, v(sp[1] + 0.3, 0.3, sp[1] + 0.3), cf(0, y, 0, 0, 45, 0), GOLD)
			end
		end
		-- gold cradle prongs holding the star
		local cradleY = y
		B:block(can, v(1.6, 0.4, 1.6), cf(0, cradleY, 0, 0, 45, 0), GOLD)
		for k = 0, 3 do
			local a = k * 90 + 45
			B:bar(can, at(0.6, a, cradleY), at(1.7, a, cradleY + 1.6), 0.4, 0.4, GOLD_LT)
		end
		local core = B:bone("Core", "Canopy", v(0, SC, 0))
		local CC = CFrame.new(0, SC, 0)
		B:block(core, v(2.3, 2.3, 2.3), CC, STAR_GLOW, { mat = "Neon", name = "StarCore" })
		B:block(core, v(2.0, 2.0, 2.0), CC * ang(45, 45, 0), STAR, {})
		-- 8 diagonal rays (static)
		for _, d in { { 1, 1, 1 }, { 1, 1, -1 }, { 1, -1, 1 }, { 1, -1, -1 }, { -1, 1, 1 }, { -1, 1, -1 }, { -1, -1, 1 }, { -1, -1, -1 } } do
			local dir = v(d[1], d[2], d[3]).Unit
			B:bar(core, CC.Position + dir * 0.9, CC.Position + dir * 2.7, 0.95, 0.95, STAR_DK)
			B:bar(core, CC.Position + dir * 2.6, CC.Position + dir * 3.3, 0.55, 0.55, STAR)
		end
		-- 6 axial rays on their own bones
		local RAYS = { v(1, 0, 0), v(-1, 0, 0), v(0, 1, 0), v(0, -1, 0), v(0, 0, 1), v(0, 0, -1) }
		for i, dir in RAYS do
			local rb = B:bone("Ray" .. i, "Core", v(0, SC, 0))
			local c0 = CC.Position
			B:bar(rb, c0 + dir * 0.9, c0 + dir * 2.7, 1.5, 1.5, STAR)
			B:bar(rb, c0 + dir * 2.6, c0 + dir * 3.9, 1.0, 1.0, STAR_LT)
			B:bar(rb, c0 + dir * 3.8, c0 + dir * 4.6, 0.55, 0.55, STAR_GLOW, { mat = "Neon", name = "RayTip" .. i })
		end
		-- armillary rings
		local RA = CFrame.new(0, SC, 0) * ang(24, 0, 10)
		local ringA = B:bone("RingA", "Core", RA)
		B:ring(ringA, RA, 5.4, 20, v(1.55, 0.5, 0.55), GOLD)
		B:ring(ringA, RA * ang(0, 9, 0), 5.4, 20, v(0.4, 0.62, 0.62), GOLD_LT)
		B:block(ringA, v(0.9, 0.9, 0.9), RA * CFrame.new(0, 0, -5.4) * ang(45, 45, 0), STAR_GLOW, { mat = "Neon", name = "BeadA" })
		B:trail(ringA, RA * v(0, 0.45, -5.4), RA * v(0, -0.45, -5.4), { name = "BeadTrailA", color = { "#ffffff", STAR_LT, STAR }, life = 0.5, width = { 1, 0.1 }, trans = { 0.1, 1 } })
		local RBc = CFrame.new(0, SC, 0) * ang(-14, 0, -30)
		local ringB = B:bone("RingB", "Core", RBc)
		B:ring(ringB, RBc, 6.3, 12, v(1.6, 0.45, 0.5), NEB_CY)
		B:ring(ringB, RBc * ang(0, 15, 0), 6.3, 12, v(1.6, 0.45, 0.5), NEB_PU)
		B:block(ringB, v(0.8, 0.8, 0.8), RBc * CFrame.new(0, 0, 6.3) * ang(45, 45, 0), CYAN_GLOW, { mat = "Neon", name = "BeadB" })
		B:trail(ringB, RBc * v(0, 0.4, 6.3), RBc * v(0, -0.4, 6.3), { name = "BeadTrailB", color = { "#ffffff", CYAN_GLOW, NEB_CY }, life = 0.5, width = { 1, 0.1 }, trans = { 0.1, 1 } })
		-- hidden supernova shards (Shard1..8) + sky beam
		for i = 1, 8 do
			local a = (i - 1) * 45
			local sb = B:bone("Shard" .. i, "Core", CFrame.new(0, SC, 0) * ang(0, -a, 0))
			local F = CFrame.new(0, SC, 0) * ang(0, -a, 0) * CFrame.new(0, 0, -2.0)
			B:block(sb, v(2.0, 0.55, 3.0), F, (i % 2 == 0) and CYAN_GLOW or STAR_GLOW, { mat = "Neon", tr = 1, name = "Shard" .. i })
		end
		B:block(core, v(1.1, 14, 1.1), cf(0, SC + 4.6 + 7, 0), STAR_GLOW, { mat = "Neon", tr = 1, name = "BeamCore" })
		B:block(core, v(2.4, 13, 2.4), cf(0, SC + 4.6 + 6.5, 0, 0, 45, 0), "#bfe9ff", { mat = "Neon", tr = 1, name = "BeamGlow" })

		------------------------------------------------------------------
		-- PLANETS on tilted orbits (OrbitN -> PlanetN)
		------------------------------------------------------------------
		local function orbit(n, center, tilt, r, deg)
			local O = CFrame.new(center) * tilt * ang(0, -deg, 0)
			B:bone("Orbit" .. n, "Root", O)
			local PC = O * CFrame.new(0, 0, -r)
			local pb = B:bone("Planet" .. n, "Orbit" .. n, PC)
			return pb, PC
		end
		-- 1: ringed amber giant
		do
			local pb, PC = orbit(1, v(0, CY2 + 1.6, 0), ang(6, 0, -5), 11.0, 40)
			B:block(pb, v(2.4, 2.4, 2.4), PC, "#f0a64a")
			B:block(pb, v(2.6, 1.2, 2.0), PC, "#ffcf7a")
			B:block(pb, v(2.0, 2.0, 2.6), PC * ang(0, 0, 0), "#d9822f")
			B:block(pb, v(1.6, 2.7, 1.6), PC, "#f0a64a")
			B:ring(pb, PC * ang(18, 0, 12), 2.35, 12, v(1.35, 0.22, 0.55), "#fff0c8")
			B:ring(pb, PC * ang(18, 15, 12), 2.75, 12, v(1.3, 0.2, 0.38), "#e8c48e")
			B:trail(pb, PC * v(0, 1.0, 0), PC * v(0, -1.0, 0), { name = "PlanetTrail1", color = { "#ffe3a8", "#f0a64a" }, life = 0.7, width = { 1, 0.1 }, trans = { 0.3, 1 } })
		end
		-- 2: teal ocean world (low orbit under the canopy)
		do
			local pb, PC = orbit(2, v(0, 9.6, 0), ang(0, 0, 0), 7.5, 200)
			B:block(pb, v(1.9, 1.9, 1.9), PC, "#2fa6c8")
			B:block(pb, v(2.05, 0.8, 1.2), PC * CFrame.new(0.1, 0.3, -0.2), "#5fd08a")
			B:block(pb, v(1.0, 0.7, 2.05), PC * CFrame.new(-0.3, -0.45, 0.1), "#5fd08a")
			B:block(pb, v(1.3, 0.3, 1.3), PC * CFrame.new(0, 0.98, 0), "#ffffff")
			B:block(pb, v(1.1, 0.3, 1.1), PC * CFrame.new(0, -0.98, 0), "#e8faff")
			B:trail(pb, PC * v(0, 0.8, 0), PC * v(0, -0.8, 0), { name = "PlanetTrail2", color = { CYAN_GLOW, NEB_CY }, life = 0.6, width = { 1, 0.1 }, trans = { 0.3, 1 } })
		end
		-- 3: rose world beside the galaxy rim
		do
			local pb, PC = orbit(3, v(0, CY + 4.2, 0), ang(-7, 0, 9), 14.0, 290)
			B:block(pb, v(1.7, 1.7, 1.7), PC, "#e86fae")
			B:block(pb, v(1.85, 0.5, 1.85), PC * CFrame.new(0, 0.35, 0), "#ffa8d4")
			B:block(pb, v(1.85, 0.4, 1.85), PC * CFrame.new(0, -0.4, 0), "#c24f8f")
			B:block(pb, v(0.6, 0.6, 0.6), PC * CFrame.new(1.6, 0.8, 0) * ang(45, 45, 0), "#fff0f8")
			B:trail(pb, PC * v(0, 0.8, 0), PC * v(0, -0.8, 0), { name = "PlanetTrail3", color = { PINK_GLOW, NEB_PK }, life = 0.6, width = { 1, 0.1 }, trans = { 0.3, 1 } })
		end
		-- 4: little violet world circling the heart
		do
			local pb, PC = orbit(4, v(0, SC, 0), ang(0, 0, 32), 8.6, 120)
			B:block(pb, v(1.4, 1.4, 1.4), PC, "#8a63e8")
			B:block(pb, v(1.5, 0.5, 1.5), PC * CFrame.new(0, 0.2, 0) * ang(0, 45, 0), "#b79bff")
			B:block(pb, v(0.4, 0.2, 0.4), PC * CFrame.new(0.3, 0.75, -0.2), "#5a3db0")
			B:trail(pb, PC * v(0, 0.6, 0), PC * v(0, -0.6, 0), { name = "PlanetTrail4", color = { "#d9c8ff", "#8a63e8" }, life = 0.6, width = { 1, 0.1 }, trans = { 0.3, 1 } })
		end

		------------------------------------------------------------------
		-- VFX: 8 emitters, 4 lights, 6 trails
		------------------------------------------------------------------
		local coreFx = B:block(core, v(3, 3, 3), CC, STAR, { tr = 1, name = "CoreFx" })
		B:emitter(coreFx, "burst", { name = "NovaBurst", color = { "#ffffff", STAR_LT, CYAN_GLOW }, size = { 1.4, 0.9, 0 }, speed = { 18, 34 }, life = { 0.7, 1.3 }, drag = 2.2, light = 1 })
		B:emitter(coreFx, "burst", { name = "NovaDust", color = { PINK_GLOW, NEB_MG, NEB_CY2 }, size = { 1.0, 1.5, 0 }, speed = { 6, 13 }, life = { 1.6, 2.6 }, drag = 1.4, light = 1, trans = { 0.1, 0.2, 1 } })
		B:emitter(coreFx, "sparkle", { name = "CoreSparkle", color = { "#ffffff", STAR_LT, STAR }, rate = 14, size = { 0.3, 0.9, 0 }, life = { 0.6, 1.2 }, speed = { 1.0, 2.5 }, light = 1 })
		local galFx = B:block(can, v(28, 4, 28), cf(0, CY + 1.0, 0), NEB_VI, { tr = 1, name = "GalaxyFx" })
		B:emitter(galFx, "sparkle", { name = "GalaxyDust", color = { "#ffffff", CYAN_GLOW, PINK_GLOW }, rate = 28, size = { 0.2, 0.65, 0 }, life = { 1.0, 2.2 }, speed = { 0.2, 0.7 }, light = 1 })
		local rainFx = B:block(can, v(22, 0.6, 22), cf(0, CY - 2.4, 0), NEB_VI, { tr = 1, name = "StarRainZone" })
		B:emitter(rainFx, "drip", { name = "StarRain", color = { STAR_GLOW, STAR_LT, NEB_CY2 }, rate = 5, size = { 0.45, 0.4, 0.1 }, life = { 1.2, 1.8 }, speed = { 0.5, 2 }, accel = { 0, -9, 0 }, light = 1, rot = { 0, 90 } })
		local veinFx = B:block(crop, v(7, 12, 7), cf(0, BASE + 7, 0), BARK, { tr = 1, name = "VeinFx" })
		B:emitter(veinFx, "ember", { name = "VeinMotes", tex = "sparkle", color = { "#ffffff", CYAN_GLOW, PINK_GLOW }, rate = 7, size = { 0.35, 0.25, 0 }, life = { 1.2, 2.0 }, speed = { 1.5, 3 }, accel = { 0, 3, 0 }, light = 1 })
		local runeFx = B:block(soil, v(20, 0.6, 20), cf(0, Y2 + 0.5, 0), TILE, { tr = 1, name = "RuneFx" })
		B:emitter(runeFx, "ember", { name = "RuneMotes", tex = "sparkle", color = { "#ffffff", RUNE, "#a58cff" }, rate = 6, size = { 0.35, 0.3, 0 }, life = { 1.4, 2.4 }, speed = { 0.6, 1.6 }, accel = { 0, 1.4, 0 }, light = 1 })
		B:emitter(runeFx, "burst", { name = "ForgeSparks", color = { "#ffffff", STAR_LT, RUNE }, size = { 0.7, 0.5, 0 }, speed = { 8, 15 }, life = { 0.5, 1.0 }, spread = 80, drag = 2.5, accel = { 0, -5, 0 }, light = 1 })
		local cl = B:block(core, v(0.4, 0.4, 0.4), cf(0, SC, -1.5), STAR, { tr = 1, name = "CoreLightCore" })
		B:light(cl, { name = "CoreLight", color = "#fff0c4", brightness = 1.4, range = 24 })
		local gl = B:block(can, v(0.4, 0.4, 0.4), cf(0, CY - 3.0, 0), NEB_PU, { tr = 1, name = "GalaxyLightCore" })
		B:light(gl, { name = "GalaxyLight", color = "#c58cff", brightness = 1.0, range = 22 })
		local rl = B:block(soil, v(0.4, 0.4, 0.4), cf(0, Y3 + 1.0, -5), TILE, { tr = 1, name = "RuneLightCore" })
		B:light(rl, { name = "RuneLight", color = "#8fe8ff", brightness = 0.8, range = 16 })
		local vl = B:block(crop, v(0.4, 0.4, 0.4), cf(0, BASE + 8, -3.2), BARK, { tr = 1, name = "VeinLightCore" })
		B:light(vl, { name = "VeinLight", color = "#9ff0ff", brightness = 0.7, range = 12 })
	end,
}
