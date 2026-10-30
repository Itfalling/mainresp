--!nocheck
-- Stardust Sprout (Starlight Ruins plant #1, Common).
-- A tall cosmic seedling growing out of an ancient star-temple tile platform
-- (pale white-violet stone slabs with gold trim and glowing cyan
-- constellation runes, indigo night soil, teal moss, scattered star dust, a
-- little violet crystal cluster and a broken fluted pillar stump). Three
-- mint-teal sprout stems rise from a seal tile; each grows broad stepped
-- seedling leaves and ends in a violet sepal cup holding a chunky gold
-- five-pointed star bud with a glowing core. Two small closed buds peek
-- glowing tips out of their sepals. VFX: small gold/white sparkles twinkle
-- off the star buds, a soft warm light under the top star.
-- Static prop: no motion.luau.
return {
	DisplayName = "Stardust Sprout",
	Rarity = "Common",
	Element = "Star",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Starlight Ruins)
		local EARTH, EARTH_DK, EARTH_LT = "#3b3566", "#2a2550", "#4d4684"
		local STONE, STONE2, STONE_DK, STONE_LT = "#e3dcef", "#d0c7e2", "#a99fc2", "#f4f0fb"
		local GOLD, GOLD_DK = "#f2c24f", "#c9952e"
		local MOSS, MOSS_DK, MOSS_LT = "#4f9e7c", "#367a62", "#78c79a"
		local RUNE = "#7fe8ff"
		local CRYS, CRYS_LT, CRYS_DK = "#9b7bff", "#c9b5ff", "#6f52d6"
		local DUST_G, DUST_C = "#ffe27a", "#b8f4ff"
		-- plant
		local STEM, STEM_DK, STEM_LT = "#2f957b", "#237563", "#6dd2ad"
		local LEAF, LEAF_DK, LEAF_LT = "#4fc79b", "#309c7d", "#98efc6"
		local SEPAL, SEPAL_DK = "#7b5ccc", "#5a40a6"
		local STAR, STAR_DK, STAR_LT, STAR_CORE = "#ffd447", "#eaa526", "#fff0a6", "#fff7d0"

		local seed = 1811
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		-- frame at p whose local +Y points along dir
		local function up(p, dir)
			return P.aim(p, p + dir) * ang(-90, 0, 0)
		end
		local function polar(a, r, y)
			return CFrame.new(math.sin(rad(a)) * r, y, -math.cos(rad(a)) * r) * CFrame.Angles(0, -rad(a), 0)
		end

		------------------------------------------------------------ ruin platform
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(y0, h, r, col)
			B:block(soil, v(2 * r, h, 0.83 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(0.83 * r, h - 0.03, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.42 * r, h - 0.06, 1.42 * r), cf(0, y0 + h / 2, 0, 0, 45, 0), col, S)
		end
		-- indigo night soil base with rough clods
		oct(0, 0.6, 4.7, EARTH_DK)
		for i = 0, 9 do
			local a = i * 36 + rnd(-8, 8)
			local w, d, h = rnd(1.4, 2.0), rnd(1.0, 1.4), rnd(0.5, 0.8)
			B:block(soil, v(w, h, d), polar(a, 4.6 + rnd(-0.1, 0.2), h / 2) * ang(0, rnd(-8, 8), 0), pick({ EARTH, EARTH_DK, EARTH_LT }), S)
		end
		-- tier 1: ring of eight worn stone slabs (gaps read as tile joints)
		oct(0.55, 0.5, 3.4, STONE_DK)
		for i = 0, 7 do
			local a = i * 45 + 22.5
			local hh = 0.62 + rnd(-0.04, 0.06)
			local col = (i % 2 == 0) and STONE or STONE2
			if i == 6 then -- one slab knocked askew
				B:block(soil, v(2.6, hh, 1.5), polar(a, 3.75, 0.55 + hh / 2) * ang(4, 9, -3), col, S)
			else
				B:block(soil, v(2.75, hh, 1.55), polar(a, 3.62, 0.55 + hh / 2), col, S)
			end
		end
		-- gold trim along the front slabs' top edge + glowing constellation runes
		for _, a in { 157.5, 202.5 } do
			B:block(soil, v(2.5, 0.12, 0.22), polar(a + 180, 4.3, 1.2), GOLD, S)
		end
		B:block(soil, v(2.5, 0.12, 0.22), polar(22.5, 4.3, 1.2), GOLD, S)
		-- runes: neon dots on the slab faces linked by thin gold lines
		local function rune(a, r, pts)
			local base = polar(a, r, 0)
			local prev
			for _, q in pts do
				local p = base * CFrame.new(q[1], q[2], -0.05)
				B:block(soil, v(0.22, 0.22, 0.1), p, RUNE, { name = "Soil", mat = "Neon" })
				if prev then
					local a0, a1 = prev.Position, p.Position
					local c, len = P.aim(a0, a1, base.LookVector)
					B:block(soil, v(0.07, 0.07, len), c, GOLD, S)
				end
				prev = p
			end
		end
		rune(-22.5, 4.42, { { -0.9, 0.75 }, { -0.35, 0.95 }, { 0.2, 0.7 }, { 0.8, 0.9 } })
		rune(22.5, 4.42, { { -0.8, 0.95 }, { -0.2, 0.7 }, { 0.5, 0.85 } })
		rune(112.5, 4.42, { { -0.6, 0.7 }, { 0.1, 0.92 }, { 0.7, 0.72 } })
		-- tier 2: inner tiles + seal plate
		oct(1.05, 0.45, 2.4, STONE_DK)
		for i = 0, 7 do
			local a = i * 45
			B:block(soil, v(1.62, 0.5, 1.15), polar(a, 2.25, 1.05 + 0.25), (i % 2 == 0) and STONE_LT or STONE, S)
		end
		B:block(soil, v(2.9, 0.5, 2.9), cf(0, 1.3, 0, 0, 22.5, 0), STONE_LT, S)
		B:block(soil, v(3.0, 0.12, 0.2), cf(0, 1.57, -1.48, 0, 0, 0), GOLD, S)
		B:block(soil, v(3.0, 0.12, 0.2), cf(0, 1.57, 1.48, 0, 0, 0), GOLD, S)
		-- the seal's soil hole the sprout grows out of
		B:block(soil, v(1.9, 0.2, 1.9), cf(0, 1.6, 0, 0, 22.5, 0), EARTH, S)
		B:block(soil, v(1.3, 0.24, 1.3), cf(0.1, 1.62, 0.05, 0, 67, 0), EARTH_LT, S)
		-- moss draping over tile edges
		for _, m in { { 60, 4.35, 1.8, MOSS, 1.15 }, { 250, 4.3, 1.6, MOSS_LT, 1.15 }, { 115, 4.4, 1.3, MOSS_DK, 1.15 }, { 300, 2.85, 1.3, MOSS, 1.58 }, { 140, 2.85, 1.1, MOSS_LT, 1.58 } } do
			B:block(soil, v(m[3], 0.22, 1.0), polar(m[1], m[2], m[5]) * ang(-12, 0, 0), m[4], S)
			B:block(soil, v(m[3] * 0.55, 0.22, 0.6), polar(m[1] + 6, m[2] + 0.1, m[5] - 0.35) * ang(-55, 0, 0), m[4], S)
		end
		-- broken fluted pillar stump (back-right)
		local PL = v(3.05, 1.17, 2.55)
		B:block(soil, v(1.9, 0.4, 1.9), CFrame.new(PL + v(0, 0.2, 0)) * ang(0, 20, 0), STONE_DK, S)
		B:block(soil, v(1.45, 2.1, 1.45), CFrame.new(PL + v(0, 1.45, 0)) * ang(0, 20, 0), STONE_LT, S)
		B:block(soil, v(1.25, 2.12, 1.25), CFrame.new(PL + v(0, 1.45, 0)) * ang(0, 65, 0), STONE2, S)
		B:block(soil, v(1.55, 0.25, 1.55), CFrame.new(PL + v(0, 0.95, 0)) * ang(0, 20, 0), GOLD, S)
		B:block(soil, v(1.0, 0.6, 1.2), CFrame.new(PL + v(-0.15, 2.75, 0.05)) * ang(0, 20, 6), STONE_LT, S)
		B:block(soil, v(0.6, 0.45, 0.6), CFrame.new(PL + v(-0.3, 3.2, -0.1)) * ang(0, 35, 10), STONE, S)
		-- a fallen chunk of it
		B:block(soil, v(1.0, 0.8, 0.8), CFrame.new(-3.5, 1.55, 1.9) * ang(0, 30, 12), STONE_LT, S)
		B:block(soil, v(1.05, 0.2, 0.85), CFrame.new(-3.5, 1.55, 1.9) * ang(0, 30, 12) * CFrame.new(0.2, 0, 0), GOLD_DK, S)
		-- little violet crystal cluster (front-right)
		local CC = v(2.65, 1.4, -2.75)
		B:block(soil, v(0.55, 1.3, 0.55), CFrame.new(CC + v(0, 0.55, 0)) * ang(0, 30, 10), CRYS, S)
		B:block(soil, v(0.4, 0.85, 0.4), CFrame.new(CC + v(0.45, 0.35, 0.15)) * ang(0, 10, -24), CRYS_LT, S)
		B:block(soil, v(0.35, 0.7, 0.35), CFrame.new(CC + v(-0.35, 0.3, 0.2)) * ang(10, 50, 26), CRYS_DK, S)
		B:block(soil, v(0.32, 0.45, 0.32), CFrame.new(CC + v(0, 0.55, 0)) * ang(0, 30, 10) * CFrame.new(0, 0.8, 0), CRYS_LT, S)
		B:block(soil, v(0.22, 0.3, 0.22), CFrame.new(CC + v(0.45, 0.35, 0.15)) * ang(0, 10, -24) * CFrame.new(0, 0.55, 0), "#ece4ff", S)
		-- star dust specks
		for _, d in { { -1.6, 1.57, -1.4, DUST_G }, { 1.7, 1.57, 1.1, DUST_C }, { -3.6, 1.2, -1.2, DUST_G }, { 3.9, 1.22, -0.6, DUST_C }, { 0.8, 1.2, -3.8, DUST_G }, { -1.9, 1.57, 1.6, DUST_G }, { -2.4, 1.2, -3.2, DUST_C } } do
			B:block(soil, v(0.24, 0.16, 0.24), cf(d[1], d[2], d[3], 0, rnd(0, 90), 0), d[4], S)
		end

		------------------------------------------------------------ sprout
		local crop = B:bone("Crop", "Root", v(0, 1.6, 0))
		local cores = {}

		-- stem made of a few chunky bars through control points
		local function stem(pts, w)
			for i = 1, #pts - 1 do
				local ww = w * (1 - 0.12 * (i - 1))
				B:bar(crop, pts[i], pts[i + 1] + (pts[i + 1] - pts[i]).Unit * 0.12, ww, ww, (i % 2 == 1) and STEM or STEM_DK)
			end
		end

		-- broad stepped oval seedling leaf: short petiole from p, blade tipped up by lift
		local function leaf(p, yawDeg, lift, len, wid)
			local F = CFrame.new(p) * CFrame.Angles(0, -rad(yawDeg), 0) * ang(lift, 0, 0)
			-- F: -Z points out along the leaf
			B:block(crop, v(0.3, 0.3, len * 0.3), F * CFrame.new(0, 0, -len * 0.12), STEM_DK)
			B:block(crop, v(wid * 0.6, 0.3, len * 0.22), F * CFrame.new(0, 0, -len * 0.3), LEAF_DK)
			B:block(crop, v(wid, 0.32, len * 0.4), F * CFrame.new(0, 0.02, -len * 0.58), LEAF)
			B:block(crop, v(wid * 0.68, 0.3, len * 0.2), F * CFrame.new(0, 0.04, -len * 0.86), LEAF_LT)
			B:block(crop, v(wid * 0.3, 0.28, len * 0.1), F * CFrame.new(0, 0.05, -len * 1.0), LEAF_LT)
			B:block(crop, v(0.16, 0.36, len * 0.55), F * CFrame.new(0, 0.05, -len * 0.6), LEAF_DK)
		end

		-- chunky five-pointed star (stepped tapering arms) facing yaw (deg; 0 = front)
		local function star(c, yawDeg, tilt, R, idx)
			local F = CFrame.new(c) * CFrame.Angles(0, -rad(yawDeg), 0) * ang(tilt, 0, 0) * CFrame.Angles(0, math.pi, 0)
			-- F: local +Z faces the viewer side; arms in local XY
			local th = 0.62 * R
			for k = 0, 4 do
				local A = F * CFrame.Angles(0, 0, rad(90 + 72 * k))
				B:block(crop, v(R * 0.5, R * 0.5, th), A * CFrame.new(R * 0.42, 0, 0), STAR)
				B:block(crop, v(R * 0.34, R * 0.32, th * 0.82), A * CFrame.new(R * 0.76, 0, 0), STAR)
				B:block(crop, v(R * 0.26, R * 0.17, th * 0.62), A * CFrame.new(R * 1.0, 0, 0), STAR_LT)
			end
			-- body: dark gold back plate, raised face, glowing core
			B:block(crop, v(R * 0.78, R * 0.78, th * 0.9), F * CFrame.new(0, 0, -0.08) * CFrame.Angles(0, 0, rad(18)), STAR_DK)
			B:block(crop, v(R * 0.62, R * 0.62, th * 1.2), F * CFrame.Angles(0, 0, rad(45 + 18)), STAR)
			local core = B:block(crop, v(R * 0.32, R * 0.32, th * 1.45), F * CFrame.Angles(0, 0, rad(18)), STAR_CORE, { mat = "Neon", name = "StarCore" .. idx })
			table.insert(cores, core)
			return F
		end

		-- violet sepal cup under a star / bud at p, stem arriving along dir
		local function sepals(p, dir, s)
			local U = up(p, dir)
			for k = 0, 3 do
				local A = U * CFrame.Angles(0, rad(45 + 90 * k), 0)
				B:block(crop, v(0.5 * s, 0.9 * s, 0.22 * s), A * CFrame.new(0, 0.25 * s, -0.32 * s) * ang(-38, 0, 0), (k % 2 == 0) and SEPAL or SEPAL_DK)
			end
			B:block(crop, v(0.62 * s, 0.5 * s, 0.62 * s), U * CFrame.new(0, -0.05 * s, 0), SEPAL_DK)
		end

		-- main stem (centre), slight S-bend
		local m0, m1, m2, m3 = v(0, 1.4, 0), v(0.25, 4.6, 0.15), v(-0.15, 7.6, -0.1), v(0.05, 9.7, -0.15)
		stem({ m0, m1, m2, m3 }, 0.62)
		sepals(m3, (m3 - m2).Unit, 1.05)
		star(m3 + v(0, 1.5, -0.05), 24, -6, 1.75, 1)

		-- right stem
		local r0, r1, r2, r3 = v(0.25, 1.4, -0.1), v(1.0, 3.6, -0.3), v(1.9, 6.0, -0.55), v(2.35, 7.25, -0.65)
		stem({ r0, r1, r2, r3 }, 0.5)
		sepals(r3, (r3 - r2).Unit, 0.9)
		star(r3 + (r3 - r2).Unit * 1.25, -72, -4, 1.35, 2)

		-- left-back stem
		local l0, l1, l2, l3 = v(-0.25, 1.4, 0.1), v(-1.0, 3.2, 0.45), v(-1.85, 5.4, 0.9), v(-2.15, 6.35, 1.0)
		stem({ l0, l1, l2, l3 }, 0.48)
		sepals(l3, (l3 - l2).Unit, 0.85)
		star(l3 + (l3 - l2).Unit * 1.15, 150, -4, 1.2, 3)

		-- two closed buds on short shoots, glowing tips peeking out
		local function bud(a, b, idx)
			stem({ a, b }, 0.34)
			local d = (b - a).Unit
			sepals(b, d, 0.8)
			local U = up(b, d)
			B:block(crop, v(0.55, 0.75, 0.55), U * CFrame.new(0, 0.45, 0) * ang(0, 45, 0), STAR_DK)
			B:block(crop, v(0.36, 0.4, 0.36), U * CFrame.new(0, 0.95, 0) * ang(0, 45, 0), STAR_CORE, { mat = "Neon", name = "BudTip" .. idx })
		end
		bud(v(0.6, 5.2, 0.3), v(1.35, 6.6, 1.15), 1)
		bud(v(-0.6, 4.0, -0.2), v(-1.5, 4.85, -1.15), 2)
		bud(v(0.1, 3.4, 0.2), v(0.3, 4.6, 1.75), 3)

		-- seedling leaves: big cotyledon pair low, smaller pairs up the stems
		leaf(v(0, 2.2, 0), 75, 12, 3.6, 2.2)
		leaf(v(0, 2.4, 0), -105, 14, 3.5, 2.1)
		leaf(v(0.1, 5.9, 0.05), 20, 28, 2.3, 1.45)
		leaf(v(-0.05, 6.6, -0.05), 205, 30, 2.2, 1.35)
		leaf(v(1.45, 4.7, -0.4), 105, 30, 1.9, 1.2)
		leaf(v(-1.4, 4.1, 0.6), -60, 30, 1.9, 1.2)
		leaf(v(-0.1, 8.2, -0.12), 115, 36, 1.8, 1.1)
		leaf(v(0.0, 7.5, -0.1), -40, 34, 1.7, 1.05)
		-- gold star-dust speckles on a few leaves

		------------------------------------------------------------ fx
		B:emitter(cores[1], "sparkle", { name = "StarSparkle", color = { "#fff6c8", "#ffd447" }, rate = 5, size = { 0.15, 0.5, 0 }, speed = { 0.4, 1.4 } })
		B:emitter(cores[2], "sparkle", { name = "StarSparkleR", color = { "#ffffff", "#9fefff" }, rate = 2.5, size = { 0.1, 0.4, 0 } })
		B:emitter(cores[3], "sparkle", { name = "StarSparkleL", color = { "#ffffff", "#ffd447" }, rate = 2.5, size = { 0.1, 0.4, 0 } })
		B:light(cores[1], { name = "StarGlow", color = "#ffe08a", brightness = 0.8, range = 9 })
	end,
}
