--!nocheck
-- Orbit Planet Vine (Starlight Ruins crop #8, Cosmic).
-- A round "moon gate" arch of the star temple, its opening a window onto the
-- night sky, with a starlight vine spiralling up the ring and tiny planets
-- orbiting the whole gate.
-- * stepped ruin platform (bone "Soil", parts "Soil"): indigo night-soil
--   base, a ring of pale temple tiles with gold trim and cyan constellation
--   runes, front temple steps, teal moss, star dust, crystal sprouts and a
--   broken pillar piece
-- * the gate (bone "Crop"): a two-step gold-trimmed pedestal carrying a big
--   stepped stone ring with a gold keystone; inside it a deep-indigo starry
--   PORTAL with nebula patches, twinkling neon stars and a gold constellation
--   (hidden neon flare beams light up on the signature beat)
-- * two mint vines spiral around the ring tube from the pedestal to the top,
--   with leaf cubes, gold leaves and little star blossoms; they meet at the
--   top in a pink/violet star-lily (petals on own bones) holding a spinning
--   golden STAR
-- * three planet fruits hang from the vine in front of the portal (swing on
--   their stems, glowing cores)
-- * four planets orbit the gate on two tilted, counter-rotating orbits
--   (bones Orbit1/Orbit2 -> PlanetN): a ringed gold planet, a silver moon,
--   a blue ocean world and a red planet, each with a trail
-- * VFX: portal shimmer + nebula glow, alignment burst + starfall on the
--   beat, top-star sparkles, rising star dust, vine glints; two lights
-- Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Orbit Planet Vine",
	Rarity = "Cosmic",
	Element = "Star",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Starlight Ruins) ---------------------------------------
		local EARTH, EARTH_DK, EARTH_LT = "#3b3566", "#2a2550", "#4d4684"
		local STONE, STONE2, STONE_DK, STONE_LT, STONE_HI = "#e3dcef", "#d0c7e2", "#a99fc2", "#f4f0fb", "#fbf9ff"
		local GOLD, GOLD_DK, GOLD_LT = "#f2c24f", "#c9952e", "#ffe08a"
		local MOSS, MOSS_DK, MOSS_LT = "#4f9e7c", "#367a62", "#78c79a"
		local RUNE = "#7fe8ff"
		local DUST_G, DUST_C = "#ffe27a", "#b8f4ff"
		local CRYS, CRYS_LT, CRYS_DK = "#9b7bff", "#c9b5ff", "#6f52d6"
		local NIGHT, NEB_V, NEB_P, NEB_T = "#231d4d", "#5a3fb0", "#a8509e", "#2d6aa0"
		local STARW = "#fff8dc"
		-- vine + bloom
		local VINE, VINE_DK, VINE_LT = "#3fae8f", "#2c8673", "#6dd2ad"
		local LEAF, LEAF_DK, LEAF_LT = "#3aa88a", "#28806e", "#86e0bb"
		local PET, PET_DK, PET_LT, PET_HI = "#ff8fd0", "#c46ae0", "#ffc0ea", "#fff0fa"
		local SEPAL, SEPAL_DK = "#7b5ccc", "#5a40a6"
		local STAR, STAR_DK, STAR_LT, STAR_CORE = "#ffd447", "#eaa526", "#fff0a6", "#fff7d0"
		local BLOSSOM = "#fff3c4"

		local seed = 18808
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function polar(a, r, y)
			return CFrame.new(math.sin(rad(a)) * r, y, -math.cos(rad(a)) * r) * CFrame.Angles(0, -rad(a), 0)
		end
		local function oct(bone, y0, h, r, col, opts)
			B:block(bone, v(2 * r, h, 0.83 * r), cf(0, y0 + h / 2, 0), col, opts)
			B:block(bone, v(0.83 * r, h - 0.03, 2 * r), cf(0, y0 + h / 2, 0), col, opts)
			B:block(bone, v(1.42 * r, h - 0.06, 1.42 * r), cf(0, y0 + h / 2, 0, 0, 45, 0), col, opts)
		end
		-- stepped orb (planet): neon core peeking out at the corners of 3 crossed slabs
		local function orb(bone, F, s, cA, cB, coreCol, coreName)
			if coreCol then
				B:block(bone, v(1.8 * s, 1.8 * s, 1.8 * s), F, coreCol, { mat = "Neon", name = coreName })
			end
			B:block(bone, v(2.3 * s, 1.5 * s, 1.5 * s), F, cA)
			B:block(bone, v(1.5 * s, 2.3 * s, 1.5 * s), F, cB)
			B:block(bone, v(1.5 * s, 1.5 * s, 2.3 * s), F, cA)
			if not coreCol then
				B:block(bone, v(1.95 * s, 1.95 * s, 1.95 * s), F, cB)
			end
		end

		------------------------------------------------------------------
		-- RUIN PLATFORM (bone "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		oct(soil, 0, 0.9, 8.8, EARTH_DK, S)
		for i = 0, 17 do
			local a = i * 20 + rnd(-6, 6)
			local w, d, h = rnd(2.2, 3.0), rnd(1.4, 1.9), rnd(0.8, 1.25)
			B:block(soil, v(w, h, d), polar(a, 8.6 + rnd(-0.1, 0.25), h / 2) * ang(0, rnd(-8, 8), 0), pick({ EARTH, EARTH_DK, EARTH_LT }), S)
		end
		local T1 = 0.9
		oct(soil, T1 - 0.05, 0.7, 7.4, STONE_DK, S)
		for i = 0, 11 do
			local a = i * 30 + 15
			local hh = 0.78 + rnd(-0.04, 0.06)
			local col = (i % 2 == 0) and STONE or STONE2
			if i == 7 then
				B:block(soil, v(3.5, hh, 2.4), polar(a, 6.45, T1 + hh / 2 + 0.05) * ang(5, -8, 4), col, S)
			else
				B:block(soil, v(3.7, hh, 2.5), polar(a, 6.2, T1 + hh / 2), col, S)
			end
		end
		local T1T = T1 + 0.8
		for _, a in { 345, 15, 315, 45, 285, 75, 135, 225 } do
			B:block(soil, v(3.3, 0.14, 0.26), polar(a, 7.45, T1T - 0.04), GOLD, S)
		end
		-- runes on the tile faces
		local function rune(a, r, y0, pts)
			local base = polar(a, r, y0)
			local prev
			for _, q in pts do
				local p = base * CFrame.new(q[1], q[2], -0.05)
				B:block(soil, v(0.26, 0.26, 0.1), p, RUNE, { name = "Soil", mat = "Neon" })
				if prev then
					local c, len = P.aim(prev.Position, p.Position, base.LookVector)
					B:block(soil, v(0.08, 0.08, len), c, GOLD, S)
				end
				prev = p
			end
		end
		rune(315, 7.47, T1, { { -1.0, 0.25 }, { -0.35, 0.55 }, { 0.3, 0.3 }, { 0.95, 0.5 } })
		rune(75, 7.47, T1, { { -0.9, 0.5 }, { -0.2, 0.25 }, { 0.6, 0.45 } })
		rune(195, 7.47, T1, { { -0.8, 0.3 }, { 0.0, 0.55 }, { 0.8, 0.3 } })
		-- front temple steps up to the gate
		for i, st in { { -5.6, 0.45, 4.6 }, { -4.6, 0.9, 4.0 } } do
			B:block(soil, v(st[3], st[2], 1.3), cf(0, T1T + st[2] / 2 - 0.02, st[1]), (i == 1) and STONE or STONE_LT, S)
			B:block(soil, v(st[3] + 0.04, 0.12, 0.2), cf(0, T1T + st[2] - 0.04, st[1] - 0.58), GOLD, S)
		end
		-- moss
		for _, m in { { 100, 7.45, 2.2, MOSS }, { 200, 7.4, 1.8, MOSS_LT }, { 260, 7.45, 1.6, MOSS_DK }, { 40, 7.4, 1.4, MOSS } } do
			B:block(soil, v(m[3], 0.22, 1.2), polar(m[1], m[2] - 0.45, T1T + 0.04) * ang(-8, 0, 0), m[4], S)
			B:block(soil, v(m[3] * 0.6, 0.22, 0.75), polar(m[1] + 5, m[2] + 0.12, T1T - 0.35) * ang(-60, 0, 0), m[4], S)
		end
		-- star dust
		for _, d in { { 2.6, -4.2, DUST_G }, { -2.8, -3.8, DUST_C }, { -5.4, -1.6, DUST_G }, { 5.6, 2.2, DUST_C }, { 1.0, 5.2, DUST_G }, { -3.4, 4.6, DUST_C }, { 4.4, -2.0, DUST_G } } do
			B:block(soil, v(0.28, 0.18, 0.28), cf(d[1], T1T + 0.08, d[2], 0, rnd(0, 90), 0), d[3], S)
		end
		-- crystal sprouts
		local function sprout(p, s, yaw)
			local c = CFrame.new(p) * ang(0, yaw, 0)
			B:block(soil, v(0.55 * s, 1.4 * s, 0.55 * s), c * CFrame.new(0, 0.6 * s, 0) * ang(0, 45, 8), CRYS, S)
			B:block(soil, v(0.32 * s, 0.4 * s, 0.32 * s), c * CFrame.new(0.1 * s, 1.35 * s, 0) * ang(0, 45, 8), CRYS_LT, S)
			B:block(soil, v(0.4 * s, 0.95 * s, 0.4 * s), c * CFrame.new(0.45 * s, 0.4 * s, 0.1 * s) * ang(0, 20, -26), CRYS_DK, S)
		end
		sprout(v(-4.6, T1T, -3.6), 1.0, 20)
		sprout(v(5.2, T1T, 3.8), 0.85, -40)
		-- broken pillar piece (back-right) + a fallen drum (left)
		do
			local PL = v(4.6, T1T, 4.4)
			B:block(soil, v(2.0, 0.45, 2.0), CFrame.new(PL + v(0, 0.22, 0)) * ang(0, 20, 0), STONE_DK, S)
			B:block(soil, v(1.55, 2.2, 1.55), CFrame.new(PL + v(0, 1.5, 0)) * ang(0, 20, 0), STONE_LT, S)
			B:block(soil, v(1.33, 2.22, 1.33), CFrame.new(PL + v(0, 1.5, 0)) * ang(0, 65, 0), STONE2, S)
			B:block(soil, v(1.66, 0.26, 1.66), CFrame.new(PL + v(0, 0.95, 0)) * ang(0, 20, 0), GOLD, S)
			B:block(soil, v(1.0, 0.6, 1.2), CFrame.new(PL + v(-0.15, 2.85, 0.05)) * ang(0, 20, 6), STONE_LT, S)
			local c = CFrame.new(-5.6, T1T + 0.8, 1.8) * ang(0, -25, 90)
			B:block(soil, v(1.8, 1.6, 1.8), c, STONE_LT, S)
			B:block(soil, v(1.55, 1.65, 1.55), c * ang(0, 45, 0), STONE2, S)
			B:block(soil, v(1.9, 0.24, 1.9), c * CFrame.new(0, 0.5, 0), GOLD, S)
			B:block(soil, v(1.2, 0.24, 1.0), c * CFrame.new(-0.95, 0, 0) * ang(0, 0, 90), MOSS, S)
		end

		------------------------------------------------------------------
		-- MOON GATE (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, T1T, 0))
		local ZG = 0.5
		-- pedestal (two steps)
		local PA, PB = T1T + 1.45, T1T + 2.9
		B:block(crop, v(9.0, PA - T1T, 4.2), cf(0, (T1T + PA) / 2, ZG), STONE_DK)
		B:block(crop, v(9.1, 0.16, 4.3), cf(0, PA - 0.25, ZG), GOLD)
		B:block(crop, v(7.0, PB - PA, 3.4), cf(0, (PA + PB) / 2, ZG), STONE)
		B:block(crop, v(7.4, 0.35, 3.7), cf(0, PB + 0.1, ZG), STONE_LT)
		for _, sz in { -1, 1 } do
			B:block(crop, v(5.4, 0.16, 0.12), cf(0, PA + 0.55, ZG + sz * 1.72), GOLD)
			B:block(crop, v(0.4, 0.4, 0.12), cf(0, PA + 0.95, ZG + sz * 1.74, 0, 0, 45), RUNE, { mat = "Neon", name = (sz < 0) and "PedRune" or "PedRuneB" })
			for _, x in { -2.2, 2.2 } do
				B:block(crop, v(0.26, 0.26, 0.12), cf(x, PA + 0.95, ZG + sz * 1.74), RUNE, { mat = "Neon", name = ("PedDot%s%d"):format(sz < 0 and "F" or "B", x < 0 and 1 or 2) })
			end
		end
		-- the ring
		local R, TUBE_R, TUBE_D = 5.4, 1.5, 2.2 -- mid radius, radial thickness, depth
		local CY = PB + R + TUBE_R / 2 - 0.55
		local C = v(0, CY, ZG)
		local function rp(th, r)
			return C + v(math.cos(rad(th)) * r, math.sin(rad(th)) * r, 0)
		end
		local NS = 16
		local seg = 2 * R * math.sin(rad(180 / NS)) + 0.42
		for k = 0, NS - 1 do
			local th = k * (360 / NS) + (180 / NS)
			local F = CFrame.new(rp(th, R)) * CFrame.Angles(0, 0, rad(th - 90))
			B:block(crop, v(seg, TUBE_R, TUBE_D), F, (k % 2 == 0) and STONE_LT or STONE)
			if k % 2 == 1 then
				for _, sz in { -1, 1 } do
					B:block(crop, v(seg - 0.3, 0.32, 0.14), F * CFrame.new(0, 0.48, sz * (TUBE_D / 2 + 0.05)), GOLD)
				end
			end
		end
		-- keystone + side bosses
		do
			local F = CFrame.new(rp(90, R + 0.1))
			B:block(crop, v(2.0, 2.0, TUBE_D + 0.4), F, STONE_HI)
			for _, sz in { -1, 1 } do
				B:block(crop, v(1.4, 1.4, 0.14), F * CFrame.new(0, 0, sz * (TUBE_D / 2 + 0.25)) * ang(0, 0, 45), GOLD)
				B:block(crop, v(0.55, 0.55, 0.16), F * CFrame.new(0, 0, sz * (TUBE_D / 2 + 0.3)) * ang(0, 0, 45), RUNE, { mat = "Neon", name = (sz < 0) and "KeyRune" or "KeyRuneB" })
			end
			for _, th in { 0, 180 } do
				local G = CFrame.new(rp(th, R)) * CFrame.Angles(0, 0, rad(th - 90))
				B:block(crop, v(1.7, 1.8, TUBE_D + 0.3), G, STONE_HI)
				B:block(crop, v(0.9, 0.9, TUBE_D + 0.5), G * ang(0, 0, 45), GOLD)
			end
		end

		-- starry portal inside the ring
		local RI = R - TUBE_R / 2 + 0.2
		for i = -4, 4 do
			local y = i * 1.0
			local wdt = 2 * math.sqrt(math.max(RI * RI - y * y, 0.3)) + 0.1
			B:block(crop, v(wdt, 1.02, 0.3), CFrame.new(C + v(0, y, 0)), NIGHT, { name = "Portal", tr = 0.08 })
		end
		-- nebula patches (thin plates on both faces)
		for _, n in { { -1.4, 1.2, 3.4, 1.6, NEB_V }, { 1.3, -0.9, 3.0, 1.4, NEB_P }, { 0.8, 2.3, 2.0, 0.9, NEB_T }, { -1.8, -2.0, 2.2, 1.0, NEB_T } } do
			for _, sz in { -1, 1 } do
				B:block(crop, v(n[3], n[4], 0.1), CFrame.new(C + v(n[1] * sz, n[2], sz * 0.2)) * ang(0, 0, 18 * sz), n[5], { name = "Nebula", tr = 0.25 })
			end
		end
		-- portal stars (front) + a gold constellation joining four of them
		local PST = { { -2.6, 1.8 }, { -1.2, 2.9 }, { 0.6, 2.2 }, { 2.3, 3.0 }, { 2.9, -0.6 }, { -3.1, -1.4 }, { -0.6, -2.9 }, { 1.7, -2.4 } }
		for i, s in PST do
			local sz = (i % 3 == 0) and 0.42 or 0.3
			B:block(crop, v(sz, sz, 0.12), CFrame.new(C + v(s[1], s[2], -0.3)) * ang(0, 0, 45), STARW, { mat = "Neon", name = "PortalStar" .. i })
		end
		for _, pr in { { 1, 2 }, { 2, 3 }, { 3, 4 }, { 4, 5 } } do
			local a, b = PST[pr[1]], PST[pr[2]]
			B:bar(crop, C + v(a[1], a[2], -0.25), C + v(b[1], b[2], -0.25), 0.09, 0.09, GOLD, { up = v(0, 0, 1) })
		end
		for i, s in { { 2.2, 1.0 }, { -2.0, 0.4 }, { 0.3, -1.8 } } do
			B:block(crop, v(0.3, 0.3, 0.12), CFrame.new(C + v(s[1], s[2], 0.3)) * ang(0, 0, 45), STARW, { mat = "Neon", name = "PortalStarB" .. i })
		end
		-- hidden flare beams (revealed on the beat)
		B:block(crop, v(0.32, 8.4, 0.1), CFrame.new(C + v(0, 0, -0.42)), STAR_CORE, { mat = "Neon", tr = 1, name = "FlareV" })
		B:block(crop, v(8.4, 0.32, 0.1), CFrame.new(C + v(0, 0, -0.44)), STAR_CORE, { mat = "Neon", tr = 1, name = "FlareH" })
		B:block(crop, v(1.5, 1.5, 0.1), CFrame.new(C + v(0, 0, -0.46)) * ang(0, 0, 45), STAR_CORE, { mat = "Neon", tr = 1, name = "FlareC" })
		B:block(crop, v(0.25, 5.0, 0.1), CFrame.new(C + v(0, 0, -0.43)) * ang(0, 0, 45), STAR_CORE, { mat = "Neon", tr = 1, name = "FlareD1" })
		B:block(crop, v(0.25, 5.0, 0.1), CFrame.new(C + v(0, 0, -0.43)) * ang(0, 0, -45), STAR_CORE, { mat = "Neon", tr = 1, name = "FlareD2" })

		------------------------------------------------------------------
		-- STARLIGHT VINES spiralling around the ring tube
		------------------------------------------------------------------
		local VA, VB = 1.0, 1.3 -- half-extents the vine hugs (radial, depth)
		local function vinePoint(th, ph)
			local u, w = math.cos(rad(ph)), math.sin(rad(ph))
			local k = (math.abs(u / VA) ^ 4 + math.abs(w / VB) ^ 4) ^ -0.25
			local n = v(math.cos(rad(th)), math.sin(rad(th)), 0)
			return rp(th, R) + n * (u * k) + v(0, 0, w * k), n * u + v(0, 0, w)
		end
		local TOPV = vinePoint(90, 0)
		local leafN = 0
		for _, sgn in { 1, -1 } do
			local N = 22
			local prev
			for i = 0, N do
				local s = i / N
				local th = 90 + sgn * 128 * (1 - s)
				local ph = sgn * 720 * (1 - s)
				local p, o = vinePoint(th, ph)
				if prev then
					local wv = 0.62 - 0.12 * s
					B:bar(crop, prev - (p - prev).Unit * 0.1, p + (p - prev).Unit * 0.1, wv, wv, (i % 2 == 0) and VINE or VINE_DK)
				end
				if i % 3 == 1 and i < N - 1 then
					leafN += 1
					local oo = o.Unit
					local lc = p + oo * 0.55
					local gold = (leafN % 4 == 0)
					B:block(crop, v(1.15, 0.45, 1.15), P.aim(lc - oo * 0.01, lc + oo * 0.01) * ang(rnd(-20, 20), 0, rnd(0, 90)), gold and GOLD or pick({ LEAF, LEAF_DK, LEAF }))
					B:block(crop, v(0.75, 0.42, 0.75), CFrame.new(lc + oo * 0.35 + v(rnd(-0.3, 0.3), 0.25, 0)) * ang(rnd(-25, 25), rnd(0, 90), rnd(-25, 25)), gold and GOLD_LT or LEAF_LT)
					if leafN % 3 == 2 then
						B:block(crop, v(0.5, 0.5, 0.5), CFrame.new(lc + oo * 0.75) * ang(0, 45, 45), BLOSSOM)
					end
				end
				prev = p
			end
			-- root down onto the pedestal
			local p0 = vinePoint(90 + sgn * 128, 0)
			local foot = v(sgn * -3.2, PB + 0.2, ZG - 1.2)
			B:bar(crop, foot, p0, 0.7, 0.7, VINE_DK)
			B:block(crop, v(1.1, 0.4, 1.1), CFrame.new(foot) * ang(0, 30, 0), VINE)
			B:block(crop, v(1.0, 0.42, 1.0), CFrame.new(foot + v(sgn * 0.5, 0.25, -0.4)) * ang(10, 20, 15), LEAF)
		end

		------------------------------------------------------------------
		-- STAR-LILY BLOOM on top with a spinning gold star
		------------------------------------------------------------------
		local BB = TOPV + v(0, 1.0, 0)
		B:bar(crop, TOPV - v(0, 0.2, 0), BB + v(0, 0.2, 0), 0.75, 0.75, VINE)
		local bloom = B:bone("Bloom", "Crop", BB)
		B:block(bloom, v(1.5, 0.6, 1.5), CFrame.new(BB) * ang(0, 45, 0), SEPAL_DK)
		for k = 0, 3 do
			local A = CFrame.new(BB) * CFrame.Angles(0, rad(k * 90), 0)
			B:block(bloom, v(0.7, 1.1, 0.3), A * CFrame.new(0, 0.35, -0.65) * ang(-35, 0, 0), (k % 2 == 0) and SEPAL or SEPAL_DK)
		end
		for k = 1, 6 do
			local a = (k - 1) * 60
			local dir = v(math.sin(rad(a)), 0, -math.cos(rad(a)))
			local p0 = BB + dir * 0.45 + v(0, 0.3, 0)
			local pet = B:bone("Petal" .. k, "Bloom", p0)
			local p1 = p0 + dir * 1.3 + v(0, 1.3, 0)
			local p2 = p1 + dir * 1.25 + v(0, 0.75, 0)
			local col = (k % 2 == 0) and PET or PET_DK
			B:bar(pet, p0, p1, 1.25, 0.34, col)
			B:bar(pet, p1 - (p1 - p0).Unit * 0.15, p2, 1.0, 0.32, (k % 2 == 0) and PET_LT or PET)
			B:bar(pet, p2 - (p2 - p1).Unit * 0.1, p2 + (p2 - p1).Unit * 0.5, 0.5, 0.3, PET_HI)
		end
		B:block(bloom, v(1.1, 0.5, 1.1), CFrame.new(BB + v(0, 0.6, 0)), GOLD_DK)
		for k = 0, 4 do
			local a = rad(k * 72)
			B:bar(bloom, BB + v(0, 0.6, 0), BB + v(math.sin(a) * 0.7, 1.7, -math.cos(a) * 0.7), 0.16, 0.16, GOLD_LT)
		end

		-- the star (five stepped arms facing front, spins about Y)
		local SC = BB + v(0, 3.15, 0)
		local star = B:bone("TopStar", "Bloom", SC)
		do
			local F = CFrame.new(SC)
			local Rs, th = 1.75, 0.95
			for k = 0, 4 do
				local A = F * CFrame.Angles(0, 0, rad(90 + 72 * k))
				B:block(star, v(Rs * 0.5, Rs * 0.5, th), A * CFrame.new(Rs * 0.42, 0, 0), STAR)
				B:block(star, v(Rs * 0.34, Rs * 0.32, th * 0.82), A * CFrame.new(Rs * 0.76, 0, 0), STAR)
				B:block(star, v(Rs * 0.26, Rs * 0.17, th * 0.62), A * CFrame.new(Rs * 1.0, 0, 0), STAR_LT)
			end
			B:block(star, v(Rs * 0.78, Rs * 0.78, th * 0.9), F * CFrame.Angles(0, 0, rad(18)), STAR_DK)
			B:block(star, v(Rs * 0.62, Rs * 0.62, th * 1.2), F * CFrame.Angles(0, 0, rad(63)), STAR)
			B:block(star, v(Rs * 0.32, Rs * 0.32, th * 1.45), F * CFrame.Angles(0, 0, rad(18)), STAR_CORE, { mat = "Neon", name = "StarCore" })
		end

		------------------------------------------------------------------
		-- HANGING PLANET FRUITS (in front of the portal)
		------------------------------------------------------------------
		local FRUITS = {
			-- theta on the ring, stem length, size, colours, core
			{ 122, 1.3, 0.62, "#ff7ac0", "#d9549f", "#ffd2ec" },
			{ 90, 2.3, 0.7, "#8f6cf5", "#6a4bd6", "#d8ccff" },
			{ 58, 1.5, 0.58, "#ffbf4a", "#e8912e", "#fff0b8" },
		}
		for i, f in FRUITS do
			local top = rp(f[1], R - TUBE_R / 2 - 0.1) + v(0, 0, -1.25)
			local fb = B:bone("Fruit" .. i, "Crop", top)
			local c = top - v(0, f[2] + 1.15 * f[3], 0)
			B:bar(fb, top + v(0, 0.35, 0), c + v(0, 0.9 * f[3], 0), 0.24, 0.24, VINE_DK)
			B:block(fb, v(0.9, 0.22, 0.6), CFrame.new(c + v(0, 1.15 * f[3], 0)) * ang(0, 30, 15), LEAF)
			B:block(fb, v(0.8, 0.22, 0.55), CFrame.new(c + v(0, 1.18 * f[3], 0)) * ang(0, -60, -15), LEAF_LT)
			orb(fb, CFrame.new(c) * ang(0, 45 * i, 0), f[3], f[4], f[5], f[6], "FruitCore" .. i)
			-- a stripe band so they read as little planets
			B:block(fb, v(2.36 * f[3], 0.3 * f[3], 1.56 * f[3]), CFrame.new(c + v(0, 0.35 * f[3], 0)) * ang(0, 45 * i, 0), f[6])
		end

		------------------------------------------------------------------
		-- ORBITING PLANETS (two tilted, counter-rotating orbits)
		------------------------------------------------------------------
		local ORB = {
			{ name = "Orbit1", tilt = 18, r = 9.0 },
			{ name = "Orbit2", tilt = -18, r = 7.9 },
		}
		local PL = {
			-- orbit, local angle (0 = front), size, kind
			{ 1, 0, 0.78, "ringed" },
			{ 1, 180, 0.45, "moon" },
			{ 2, 0, 0.62, "ocean" },
			{ 2, 180, 0.52, "red" },
		}
		local orbitBones = {}
		for i, o in ORB do
			orbitBones[i] = B:bone(o.name, "Crop", CFrame.new(C) * ang(o.tilt, 0, 0))
		end
		for i, p in PL do
			local o = ORB[p[1]]
			local OF = CFrame.new(C) * ang(o.tilt, 0, 0)
			local pc = (OF * CFrame.Angles(0, -rad(p[2]), 0) * CFrame.new(0, 0, -o.r)).Position
			local up = OF.UpVector
			local pb = B:bone("Planet" .. i, o.name, CFrame.new(pc) * (OF - OF.Position))
			local F = CFrame.new(pc) * (OF - OF.Position) * ang(0, 45, 0)
			local s = p[3]
			if p[4] == "ringed" then
				orb(pb, F, s, "#f2b84a", "#e0953a", "#fff1c0", "PlanetCore1")
				B:block(pb, v(2.36 * s, 0.35 * s, 1.56 * s), F * CFrame.new(0, 0.4 * s, 0), "#ffe2a0")
				local RF = F * ang(0, 0, 14)
				B:block(pb, v(4.6 * s, 0.16, 1.1 * s), RF, "#ffb6e4")
				B:block(pb, v(1.1 * s, 0.17, 4.6 * s), RF, "#ffb6e4")
				B:block(pb, v(3.6 * s, 0.15, 3.6 * s), RF * ang(0, 45, 0), "#f7d6ff")
			elseif p[4] == "moon" then
				orb(pb, F, s, "#d9d6ea", "#b9b4d2", nil)
				B:block(pb, v(0.55 * s, 0.55 * s, 0.12), F * CFrame.new(0.35 * s, 0.3 * s, -1.0 * s), "#9d97bd")
				B:block(pb, v(0.4 * s, 0.4 * s, 0.12), F * CFrame.new(-0.4 * s, -0.35 * s, -1.0 * s), "#9d97bd")
			elseif p[4] == "ocean" then
				orb(pb, F, s, "#3fa8f0", "#2f7fd6", "#c8f4ff", "PlanetCore3")
				B:block(pb, v(1.0 * s, 0.9 * s, 0.14), F * CFrame.new(0.2 * s, 0.25 * s, -1.2 * s), "#5fd38a")
				B:block(pb, v(0.14, 0.8 * s, 0.9 * s), F * CFrame.new(-1.2 * s, -0.2 * s, 0.1 * s), "#5fd38a")
			else
				orb(pb, F, s, "#ff6a4a", "#d9472e", "#ffd2a8", "PlanetCore4")
				B:block(pb, v(2.36 * s, 0.3 * s, 1.56 * s), F * CFrame.new(0, -0.3 * s, 0), "#ffb07a")
			end
			B:trail(pb, pc + up * 0.45, pc - up * 0.45, { name = "PlanetTrail" .. i, color = ({ { "#fff1c0", "#ffb6e4" }, { "#ffffff", "#c9c4ff" }, { "#c8f4ff", "#3fa8f0" }, { "#ffd2a8", "#ff6a4a" } })[i], life = 0.6, width = { 1, 0 }, trans = { 0.3, 1 } })
		end

		------------------------------------------------------------------
		-- VFX: 8 emitters, 2 lights, 4 trails
		------------------------------------------------------------------
		local portalFx = B:block(crop, v(7.4, 7.4, 0.6), CFrame.new(C), NIGHT, { tr = 1, name = "PortalFx" })
		B:emitter(portalFx, "sparkle", { name = "PortalShimmer", color = { "#ffffff", RUNE, "#ffc0ea" }, rate = 12, size = { 0.15, 0.45, 0 }, life = { 0.8, 1.6 }, speed = { 0.1, 0.4 }, light = 1 })
		B:emitter(portalFx, "glow", { name = "NebulaGlow", color = { "#8a6cff", "#ff8fd0", "#5fc8ff" }, rate = 1.6, size = { 2.4, 3.6, 1.5 }, trans = { 0.84, 0.78, 1 }, light = 1 })
		B:emitter(portalFx, "burst", { name = "AlignBurst", color = { "#ffffff", STAR_LT, RUNE, "#ffc0ea" }, size = { 0.8, 0.55, 0 }, speed = { 10, 18 }, life = { 0.6, 1.2 }, drag = 2.5, light = 1 })
		local starFx = B:block(star, v(2.4, 2.4, 1.2), CFrame.new(SC), STAR, { tr = 1, name = "StarFx" })
		B:emitter(starFx, "sparkle", { name = "StarSparkle", color = { "#ffffff", STAR_LT, STAR }, rate = 9, size = { 0.2, 0.6, 0 }, life = { 0.7, 1.4 }, speed = { 0.8, 2.0 }, light = 1 })
		B:emitter(starFx, "sparkle", { name = "Starfall", rate = 0, color = { STAR_LT, "#ffffff", "#ffc0ea" }, size = { 0.5, 0.4, 0 }, life = { 1.6, 2.6 }, speed = { 5, 10 }, spread = 75, accel = { 0, -6, 0 }, drag = 0.5, light = 1 })
		local dustZone = B:block(soil, v(14, 0.5, 14), cf(0, T1T + 0.3, 0), GOLD, { tr = 1, name = "DustZone" })
		B:emitter(dustZone, "sparkle", { name = "StarDust", color = { DUST_G, "#ffffff", DUST_C }, rate = 7, size = { 0.12, 0.32, 0 }, life = { 2.5, 4 }, speed = { 0.2, 0.6 }, spread = 25, accel = { 0, 0.7, 0 }, light = 1 })
		local ringFx = B:block(crop, v(13, 13, 3), CFrame.new(C), VINE, { tr = 1, name = "RingFx" })
		B:emitter(ringFx, "sparkle", { name = "VineGlints", color = { LEAF_LT, GOLD_LT, "#ffffff" }, rate = 5, size = { 0.12, 0.38, 0 }, life = { 0.8, 1.5 }, speed = { 0.1, 0.4 }, light = 1 })
		B:emitter(ringFx, "sparkle", { name = "RingBurst", rate = 0, color = { RUNE, "#ffffff", GOLD_LT }, size = { 0.4, 0.3, 0 }, life = { 0.8, 1.4 }, speed = { 3, 6 }, spread = 180, drag = 1.5, light = 1 })
		B:light(portalFx, { name = "PortalLight", color = "#a98cff", brightness = 1.2, range = 16 })
		B:light(starFx, { name = "StarLight", color = "#ffd77a", brightness = 1.2, range = 14 })
	end,
}
