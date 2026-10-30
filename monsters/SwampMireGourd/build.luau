--!nocheck
-- Mire Gourd Vine (Misty Swamp crop #4, Epic).
-- A thick, mossy, broken dead stump stands in the swamp mud: grey-brown dead
-- bark with deep grooves, a jagged splintered crown with a dark hollow, a
-- broken spire and crooked dead branches, violet bracket fungus and heavy moss
-- pads. A dark swamp vine spirals up the stump in teal-green leaf cubes with
-- pale lavender gourd flowers, runs out along every branch and climbs the
-- spire into a leafy crown that arcs over into a hook. Mossy green bottle
-- gourds (striped, moss-capped, dripping with moss) hang from the branch tips
-- and the hook; one ripe gourd lies on the mound.
-- Base: stepped dark swamp-mud mound with moss pads, a murky teal puddle with
-- lily pads, reeds + cattails and mossy stones.
-- Static prop: no motion.luau, no VFX (Epic tier).
return {
	DisplayName = "Mire Gourd Vine",
	Rarity = "Epic",
	Element = "Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Misty Swamp)
		local MUD_DK, MUD_DK2, MUD, MUD_LT = "#2f2721", "#3a3028", "#4a3d30", "#5e4e3c"
		local MOSS, MOSS_DK, MOSS_LT = "#4f8a3c", "#356a2e", "#74ad4a"
		local WATER, WATER_LT, WATER_DK = "#2f7d73", "#57a89a", "#225a54"
		local PAD, PAD_DK, PAD_FL, PAD_FL_C = "#4f9e45", "#3a7d36", "#d9a8f0", "#fff0a8"
		local REED, REED_DK, CATTAIL = "#7a9a44", "#5b7a34", "#5a3a26"
		local STONE, STONE_LT, STONE_DK = "#66726c", "#84908a", "#4c5652"
		local BARK, BARK_DK, BARK_LT = "#6b6157", "#4f473f", "#837868"
		local WOOD, HOLLOW = "#a8946e", "#2a231d"
		local FUNGUS, FUNGUS_LT = "#8a6ab8", "#b49ad8"
		local VINE, VINE_DK = "#2f6a33", "#234f29"
		local LEAF = { "#3f8f5a", "#4fa368", "#2f7a4c" }
		local FLOWER, FLOWER_C = "#efe6ff", "#ffd95a"
		local GOURD, GOURD_DK, GOURD_LT, STRIPE = "#6fae4a", "#4f8a38", "#8cc45e", "#b9e08a"
		local GCAP, DRIP = "#3c6b2e", "#567f34"

		local seed = 1547
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function polar(c, a, y, r)
			-- frame inside c at angle a (deg), height y, radius r; local -Z points outward
			return c * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y, -r)
		end
		local function dirOf(deg)
			local a = rad(deg)
			return v(math.sin(a), 0, -math.cos(a))
		end
		-- stepped "pixel circle" disc (3 parts)
		local function disc(bone, c, r, h, col, opts)
			B:block(bone, v(2 * r, h, 1.0 * r), c, col, opts)
			B:block(bone, v(1.0 * r, h - 0.04, 2 * r), c, col, opts)
			B:block(bone, v(1.6 * r, h - 0.08, 1.6 * r), c, col, opts)
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
				local w, d = rnd(1.4, 2.3), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 6.0, MUD_DK, 13, { MUD_DK, MUD_DK2, MUD_DK }, 0.35)
		tier(0.8, 0.65, 4.2, MUD, 9, { MUD, MUD_LT, MUD_DK2 }, 0.3)
		tier(1.45, 0.45, 2.9, MUD_LT, 0, {}, 0)
		local TOP = 1.9

		-- moss pads draped over the tier edges
		for _, m in { { 10, 6.05, 1.12, 2.3, MOSS }, { 100, 6.0, 1.1, 2.0, MOSS_DK }, { 190, 6.1, 1.1, 2.2, MOSS }, { 280, 6.0, 1.12, 1.8, MOSS_DK }, { 150, 4.25, 1.77, 1.7, MOSS_LT }, { 240, 4.2, 1.77, 1.5, MOSS } } do
			local c = polar(CFrame.new(), m[1], m[3], m[2])
			B:block(soil, v(m[4], 0.3, 1.3), c * ang(-12, 0, 0), m[5], S)
		end

		-- murky puddle on the front-right
		local pc = CFrame.new(3.3, 1.86, -2.6) * ang(0, -30, 0)
		disc(soil, pc * CFrame.new(0, -0.22, 0), 1.95, 0.55, MUD_DK2, S)
		disc(soil, pc * CFrame.new(0, 0.05, 0), 1.65, 0.14, WATER, S)
		B:block(soil, v(1.1, 0.1, 0.35), pc * CFrame.new(-0.4, 0.1, 0.55), WATER_LT, S)
		B:block(soil, v(0.8, 0.1, 0.8), pc * CFrame.new(0.5, 0.09, -0.6) * ang(0, 30, 0), WATER_DK, S)
		local function lily(c, r, flower)
			B:block(soil, v(1.9 * r, 0.12, 1.5 * r), c, PAD, S)
			B:block(soil, v(1.5 * r, 0.1, 1.9 * r), c, PAD_DK, S)
			B:block(soil, v(0.35 * r, 0.14, 0.8 * r), c * CFrame.new(0, 0.01, -0.6 * r), WATER, S)
			if flower then
				B:block(soil, v(0.7, 0.3, 0.7), c * CFrame.new(0.2, 0.18, 0.2) * ang(0, 45, 0), PAD_FL, S)
				B:block(soil, v(0.5, 0.3, 0.5), c * CFrame.new(0.2, 0.32, 0.2), PAD_FL, S)
				B:block(soil, v(0.22, 0.2, 0.22), c * CFrame.new(0.2, 0.48, 0.2), PAD_FL_C, S)
			end
		end
		lily(pc * CFrame.new(-0.5, 0.16, -0.3) * ang(0, -30, 0), 0.7, true)
		lily(pc * CFrame.new(0.7, 0.15, 0.4) * ang(0, 110, 0), 0.5, false)
		lily(cf(-4.9, 0.86, -2.6, 0, 40, 0), 0.55, false)

		-- reeds + cattails
		local function reed(x, z, y0, h, lean, cat)
			local a = v(x, y0, z)
			local b = a + v(lean[1], h, lean[2])
			B:bar(soil, a, b, 0.24, 0.24, (h > 2.6) and REED or REED_DK, S)
			if cat then
				local d = (b - a).Unit
				B:bar(soil, b - d * 0.2, b + d * 0.9, 0.42, 0.42, CATTAIL, S)
				B:bar(soil, b + d * 0.85, b + d * 1.3, 0.12, 0.12, REED_DK, S)
			end
		end
		reed(-4.5, 2.9, 0.8, 3.4, { -0.3, 0.2 }, true)
		reed(-5.0, 2.2, 0.8, 2.4, { -0.5, -0.1 }, false)
		reed(-3.9, 3.6, 0.8, 2.0, { 0.1, 0.4 }, false)
		reed(4.9, 1.6, 0.8, 2.9, { 0.4, 0.2 }, true)
		reed(5.1, 0.8, 0.8, 1.9, { 0.4, -0.2 }, false)

		-- mossy stones
		for _, s in { { -5.1, 1.0, -0.6, 0.95, 25, STONE }, { -5.5, 0.85, 0.6, 0.6, 10, STONE_LT }, { 1.4, 1.0, 5.4, 0.85, -20, STONE_DK }, { 5.0, 0.95, 3.0, 0.7, 40, STONE }, { -2.4, 1.75, 3.4, 0.55, 15, STONE_LT } } do
			local st = B:block(soil, v(s[4] * 1.2, s[4], s[4]), cf(s[1], s[2], s[3], rnd(-10, 10), s[5], rnd(-10, 10)), s[6], S)
			if s[4] > 0.75 then
				B:block(soil, v(s[4] * 0.9, 0.2, s[4] * 0.7), st.CFrame * CFrame.new(0, s[4] / 2, 0), MOSS_LT, S)
			end
		end

		---------------------------------------------------------------- dead stump
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		local STUMP_TOP = 12.0
		local function rAt(y)
			return 2.0 - (y - TOP) / (STUMP_TOP - TOP) * 0.6
		end
		-- stacked tapering sections
		local secs = { TOP - 0.2, 4.6, 7.2, 9.7, STUMP_TOP }
		for i = 1, #secs - 1 do
			local y0, y1 = secs[i], secs[i + 1]
			local r = rAt((y0 + y1) / 2) + 0.05
			disc(crop, cf(0, (y0 + y1) / 2, 0, 0, (i % 2 == 0) and 45 or 0, 0), r, y1 - y0 + 0.12, (i % 2 == 0) and BARK or BARK_LT)
		end
		-- deep grooves on the arm faces
		for i = 0, 5 do
			local a = i * 90 + ((i >= 4) and 45 or 0)
			local y0 = TOP + rnd(0.2, 1.5)
			local y1 = STUMP_TOP - rnd(0.8, 3.5)
			local p0 = dirOf(a) * (rAt(y0) - 0.12) + v(0, y0, 0)
			local p1 = dirOf(a) * (rAt(y1) - 0.12) + v(0, y1, 0)
			B:bar(crop, p0, p1, 0.35, 0.35, BARK_DK)
		end
		-- root flares running down into the mud
		for _, a in { 20, 95, 165, 240, 310 } do
			local d = dirOf(a)
			local p0 = d * 1.4 + v(0, TOP + 1.6, 0)
			local p1 = d * 2.7 + v(0, TOP + 0.1, 0)
			local p2 = d * 3.9 + v(0, 1.3, 0)
			B:bar(crop, p0, p1 + d * 0.2, 1.1, 1.1, BARK)
			B:bar(crop, p1 - d * 0.2, p2, 0.75, 0.75, BARK_DK)
		end
		-- splintered crown with a dark hollow
		disc(crop, cf(0, STUMP_TOP - 0.05, 0, 0, 22, 0), 1.0, 0.2, HOLLOW)
		for i = 0, 6 do
			local a = i * (360 / 7) + rnd(-8, 8)
			local h = ({ 0.7, 1.6, 0.9, 2.2, 0.6, 1.3, 1.0 })[i + 1]
			local q = polar(CFrame.new(0, STUMP_TOP, 0), a, h / 2 - 0.1, 1.05)
			B:block(crop, v(0.85, h, 0.55), q * ang(rnd(-8, 8), 0, rnd(-6, 6)), (i % 2 == 0) and BARK_LT or BARK)
			if h > 1.2 then
				B:block(crop, v(0.45, 0.5, 0.35), q * CFrame.new(0, h / 2 + 0.15, 0.05), WOOD)
			end
		end
		B:block(crop, v(2.2, 0.18, 0.5), polar(CFrame.new(0, STUMP_TOP + 0.02, 0), 110, 0, 0.6), WOOD)
		-- broken spire rising from the back-left of the crown
		local sp0 = dirOf(215) * 0.75 + v(0, STUMP_TOP - 1.0, 0)
		local sp1 = dirOf(215) * 0.55 + v(0, 15.0, 0) + v(0.1, 0, 0)
		B:bar(crop, sp0, sp1, 1.1, 1.0, BARK)
		B:bar(crop, sp0 + v(0, 0.6, 0), sp1 + v(0, -0.6, 0), 0.7, 1.25, BARK_DK)
		B:block(crop, v(0.6, 0.8, 0.6), CFrame.new(sp1 + v(0, 0.3, 0)) * ang(0, 30, 10), WOOD)
		-- the dead branch arching over the top into a hook (carries the crown gourd)
		local h0 = sp1 - v(0, 0.6, 0)
		local h1 = v(-0.3, 17.4, 0.0)
		local h2 = v(0.3, 18.2, -1.5)
		local h3 = v(0.6, 17.4, -2.9)
		B:bar(crop, h0, h1, 0.6, 0.6, BARK)
		B:bar(crop, h1, h2, 0.5, 0.5, BARK_LT)
		B:bar(crop, h2, h3, 0.45, 0.45, BARK)

		-- crooked dead branches: {deg, y, reach, rise}
		local tips = {}
		for bi, b in { { 65, 9.2, 3.5, 1.1 }, { 200, 10.6, 3.2, 0.9 }, { 305, 6.8, 3.2, 0.6 }, { 135, 7.6, 2.8, 0.8 } } do
			local d = dirOf(b[1])
			local side = d:Cross(v(0, 1, 0))
			local base = d * (rAt(b[2]) - 0.3) + v(0, b[2], 0)
			local m = base + d * (b[3] * 0.55) + v(0, b[4], 0) + side * 0.35
			local tip = base + d * b[3] + v(0, b[4] + 0.15, 0) - side * 0.2
			B:bar(crop, base, m, 0.75, 0.75, BARK)
			B:bar(crop, m - (m - base).Unit * 0.15, tip + (tip - m).Unit * 0.2, 0.55, 0.55, BARK_LT)
			-- broken twig stub
			B:bar(crop, m, m + v(0, 0.9, 0) + d * 0.4 - side * 0.3, 0.3, 0.3, BARK_DK)
			tips[bi] = tip
		end

		-- heavy moss pads on the stump
		for _, m in { { 30, 4.2, 1.8 }, { 170, 6.0, 1.6 }, { 280, 8.6, 1.5 }, { 100, 10.4, 1.3 }, { 330, 11.2, 1.2 }, { 230, 3.2, 1.6 } } do
			local r = rAt(m[2])
			local q = polar(CFrame.new(0, m[2], 0), m[1], 0, r - 0.1)
			B:block(crop, v(m[3], m[3] * 0.8, 0.5), q, MOSS)
			B:block(crop, v(m[3] * 0.7, 0.45, 0.4), q * CFrame.new(0.1, -m[3] * 0.55, -0.05), MOSS_DK)
		end
		-- violet bracket fungus
		for _, f in { { 250, 5.0, 1.0 }, { 250, 5.9, 0.75 }, { 20, 9.8, 0.8 } } do
			local q = polar(CFrame.new(0, f[2], 0), f[1], 0, rAt(f[2]) - 0.1)
			local k = f[3]
			B:block(crop, v(1.8 * k, 0.35, 1.2 * k), q * CFrame.new(0, 0, -0.5 * k), FUNGUS)
			B:block(crop, v(1.2 * k, 0.25, 0.8 * k), q * CFrame.new(0, 0.25, -0.35 * k), FUNGUS_LT)
		end

		---------------------------------------------------------------- vine + leaves
		local vinePts = {}
		local N = 15
		for k = 0, N do
			local t = k / N
			local y = TOP + 0.2 + t * (STUMP_TOP + 0.4 - TOP)
			local a = 160 + t * 560
			vinePts[k] = dirOf(a) * (rAt(math.min(y, STUMP_TOP)) + 0.3) + v(0, y, 0)
		end
		B:block(crop, v(1.3, 0.6, 1.3), CFrame.new(vinePts[0] + v(0, 0.05, 0)) * ang(0, 25, 0), VINE_DK)
		for k = 0, N - 1 do
			local a, b = vinePts[k], vinePts[k + 1]
			local dd = (b - a).Unit
			B:bar(crop, a - dd * 0.2, b + dd * 0.2, 0.55, 0.55, (k % 2 == 0) and VINE or VINE_DK)
		end
		-- up the spire
		local sv = { vinePts[N], dirOf(230) * 1.4 + v(0, 13.4, 0), dirOf(190) * 1.1 + v(0, 15.6, 0), h1 + v(0.3, -0.3, 0.3) }
		for k = 1, #sv - 1 do
			local dd = (sv[k + 1] - sv[k]).Unit
			B:bar(crop, sv[k] - dd * 0.2, sv[k + 1] + dd * 0.2, 0.45, 0.45, (k % 2 == 0) and VINE_DK or VINE)
		end
		local leafAt = { 1, 3, 4, 6, 7, 9, 10, 12, 14 }
		for j, k in leafAt do
			local p = vinePts[k]
			local out = v(p.X, 0, p.Z)
			out = out.Magnitude > 0.01 and out.Unit or v(0, 0, -1)
			local s = 1.9 - 0.04 * k
			B:block(crop, v(s, s * 0.8, s), CFrame.new(p + out * (0.3 + s * 0.35)) * ang(rnd(-25, 25), rnd(0, 90), rnd(-25, 25)), LEAF[(j % 3) + 1])
		end
		-- leafy crown around the spire top + along the hook
		for j, l in { { -1.4, 13.6, 1.0, 2.0 }, { 0.6, 14.2, 1.9, 1.8 }, { -1.6, 15.4, -0.6, 1.7 }, { 0.3, 16.0, 1.2, 1.6 }, { -0.9, 16.9, 0.3, 1.5 }, { 0.9, 17.6, -0.6, 1.3 }, { -0.6, 17.9, -1.5, 1.2 }, { 1.3, 15.2, 0.0, 1.4 } } do
			B:block(crop, v(l[4], l[4] * 0.8, l[4]), cf(l[1], l[2], l[3], rnd(-25, 25), rnd(0, 90), rnd(-25, 25)), LEAF[(j % 3) + 1])
		end
		-- vines out along the branches, a leaf + tendril on each
		for bi, tip in tips do
			local inner = v(tip.X * 0.4, tip.Y - 0.6, tip.Z * 0.4)
			B:bar(crop, inner, tip + v(0, 0.2, 0), 0.32, 0.32, VINE)
			local out = v(tip.X, 0, tip.Z).Unit
			local side = out:Cross(v(0, 1, 0))
			local c1 = tip + v(0, 0.25, 0)
			local c2 = c1 + v(0, 0.9, 0) + out * 0.3
			local c3 = c2 + side * 0.45 + v(0, 0.2, 0)
			B:bar(crop, c1, c2, 0.2, 0.2, VINE)
			B:bar(crop, c2, c3, 0.2, 0.2, MOSS_LT)
			local lp = inner:Lerp(tip, 0.5) + v(0, 0.5, 0)
			B:block(crop, v(1.3, 1.0, 1.3), CFrame.new(lp) * ang(rnd(-20, 20), bi * 41, rnd(-20, 20)), LEAF[(bi % 3) + 1])
		end
		-- pale lavender gourd flowers
		local function flower(p, s)
			B:block(crop, v(1.1 * s, 0.2, 0.42 * s), CFrame.new(p) * ang(0, 20, 0), FLOWER)
			B:block(crop, v(0.42 * s, 0.2, 1.1 * s), CFrame.new(p) * ang(0, 20, 0), FLOWER)
			B:block(crop, v(0.35 * s, 0.32, 0.35 * s), CFrame.new(p + v(0, 0.08, 0)) * ang(0, 20, 0), FLOWER_C)
		end
		flower(vinePts[4] + v(vinePts[4].X, 0, vinePts[4].Z).Unit * 1.4 + v(0, 0.9, 0), 1.0)
		flower(vinePts[10] + v(vinePts[10].X, 0, vinePts[10].Z).Unit * 1.3 + v(0, 0.8, 0), 0.9)
		flower(v(0.6, 16.85, 1.3), 0.85)

		---------------------------------------------------------------- mossy bottle gourds
		-- hangs from p (stem top); s = scale
		local function gourd(p, s, deg, stemLen)
			local sl = stemLen or 0.7
			local F = CFrame.new(p) * CFrame.Angles(0, rad(deg), 0)
			B:block(crop, v(0.28, sl + 0.25, 0.28), F * CFrame.new(0, -sl / 2, 0) * ang(0, 0, 10), VINE_DK)
			local y = -sl
			local function at(yy)
				return F * CFrame.new(0, y - yy * s, 0)
			end
			-- moss cap + drips
			B:block(crop, v(1.0 * s, 0.4 * s, 1.0 * s), at(0.15) * ang(0, 45, 0), GCAP)
			B:block(crop, v(0.3 * s, 0.8 * s, 0.3 * s), at(0.55) * CFrame.new(0.45 * s, 0, -0.25 * s), DRIP)
			-- neck bulb + waist
			B:block(crop, v(1.05 * s, 0.95 * s, 1.05 * s), at(0.7), GOURD_LT)
			B:block(crop, v(0.85 * s, 0.95 * s, 0.85 * s), at(0.7) * ang(0, 45, 0), GOURD_LT)
			B:block(crop, v(0.8 * s, 0.4 * s, 0.8 * s), at(1.25), GOURD_DK)
			-- big lower bulb (stepped round)
			disc(crop, at(2.4), 1.2 * s, 1.9 * s, GOURD)
			B:block(crop, v(1.7 * s, 2.5 * s, 1.7 * s), at(2.4) * ang(0, 45, 0), GOURD_DK)
			B:block(crop, v(1.1 * s, 0.4 * s, 1.1 * s), at(3.65), GOURD_DK)
			-- pale stripes on the arm faces + a moss patch
			for i = 0, 3 do
				B:block(crop, v(0.36 * s, 1.6 * s, 0.12), at(2.4) * CFrame.Angles(0, rad(i * 90), 0) * CFrame.new(0, 0, -1.2 * s - 0.03), STRIPE)
			end
			B:block(crop, v(1.0 * s, 0.35 * s, 0.9 * s), at(1.55) * CFrame.new(0.3 * s, 0, 0.2 * s) * ang(0, 20, 0), MOSS)
		end
		gourd(h3 - v(0, 0.1, 0), 0.95, 10, 0.6)
		gourd(tips[1], 1.15, 65, 0.8)
		gourd(tips[2], 1.0, 200, 0.7)
		gourd(tips[3], 0.9, 305, 0.6)
		gourd(tips[4], 0.85, 135, 0.6)
		-- a ripe gourd lying on the mound (on its side)
		do
			local C = cf(-2.5, 2.95, -3.4, 0, -35, 80)
			disc(soil, C, 1.15, 1.9, GOURD, S)
			B:block(soil, v(1.6, 2.4, 1.6), C * ang(0, 45, 0), GOURD_DK, S)
			B:block(soil, v(1.0, 0.9, 1.0), C * CFrame.new(0, 1.45, 0), GOURD_LT, S)
			B:block(soil, v(0.8, 0.35, 0.8), C * CFrame.new(0, 2.0, 0) * ang(0, 45, 0), GCAP, S)
			B:block(soil, v(0.35, 1.6, 0.12), C * CFrame.new(0, 0, -1.18), STRIPE, S)
		end
	end,
}
