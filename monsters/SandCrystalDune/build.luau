--!nocheck
-- Dune Crystal Bloom (Sandy Savanna crop #7, Secret).
-- A chunky layered sandstone outcrop (banded tan / terracotta / cream rock
-- strata) rises from a stepped golden sand mound. Amber crystals poke out of
-- its cracks, and from its crown a sage-green agave rosette sends up a tall
-- desert flower stalk. Candelabra side arms carry golden bloom cups, each
-- holding a cluster of faceted amber crystal fruit; the top of the stalk
-- opens into a big sun-gold flower cradling the largest amber crystal.
-- Base: golden sand tiers with wind ripples, sandstone rocks, dry grass
-- tufts, pebbles, shells and little cactus sprouts. Golden sand sparkles +
-- one soft amber light. Static prop: no motion.luau.
return {
	DisplayName = "Dune Crystal Bloom",
	Rarity = "Secret",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette
		local SAND_DK, SAND_DK2, SAND, SAND_MD, SAND_LT, SAND_HI = "#c48a45", "#b67c3b", "#d9a95c", "#e0b468", "#e8c27a", "#f2d696"
		local SST_DK, SST, SST_LT, SST_BAND, SST_CREAM = "#9c4f2c", "#b8643a", "#cf8050", "#7e3a22", "#f0cf98"
		local PEB, PEB_LT, PEB_DK = "#a39486", "#c2b4a2", "#7d7166"
		local GRASS_D, GRASS_M, GRASS_L = "#c49a34", "#d8b84a", "#ead27a"
		local CACT, CACT_DK, CACT_FL = "#5c9a3c", "#467c2e", "#ff7aa8"
		local SHELL, SHELL_PK = "#fbefdc", "#f6b8b0"
		local AG_DK, AG, AG_LT, AG_TIP = "#5d7d48", "#76995a", "#9cbd78", "#7a3a22"
		local STK_DK, STK, STK_LT = "#6f7a38", "#8a964a", "#a4ad5e"
		local PET_DK, PET, PET_LT, PET_HI = "#d93a5e", "#f45a78", "#ff8a98", "#ffe08a"
		local AMB_DK, AMB, AMB_LT, AMB_HI = "#d8650e", "#ff8f1a", "#ffb43a", "#ffdc8a"
		local GLOW = "#ffe9a8"
		local NEON = { mat = "Neon" }

		local seed = 7147
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
		tier(0, 0.8, 6.6, SAND_DK, 18, { SAND_DK, SAND_DK2, SAND_DK }, 0.35)
		tier(0.8, 0.6, 4.7, SAND, 12, { SAND, SAND_MD, SAND }, 0.3)
		tier(1.4, 0.45, 2.9, SAND_LT, 0, {}, 0)
		local TOP = 1.85

		-- wind ripples on the tiers
		for _, r in { { 20, 5.6, 0.82 }, { 75, 5.4, 0.82 }, { 140, 5.7, 0.82 }, { 250, 5.5, 0.82 }, { 310, 5.6, 0.82 }, { 110, 3.8, 1.42 }, { 200, 3.7, 1.42 }, { 340, 3.9, 1.42 } } do
			local c = polar(CFrame.new(), r[1], r[3], r[2])
			B:block(soil, v(2.2, 0.1, 0.3), c * ang(0, rnd(-8, 8), 0), SAND_HI, S)
		end
		-- sandstone rocks (with a darker stratum band)
		local function rock(x, y, z, s, ry)
			local c = cf(x, y, z, rnd(-6, 6), ry, rnd(-6, 6))
			B:block(soil, v(1.3 * s, 0.9 * s, 1.0 * s), c, SST, S)
			B:block(soil, v(1.34 * s, 0.22 * s, 1.04 * s), c * CFrame.new(0, -0.12 * s, 0), SST_BAND, S)
			B:block(soil, v(0.8 * s, 0.4 * s, 0.7 * s), c * CFrame.new(0.15 * s, 0.6 * s, 0.05 * s) * ang(0, 20, 0), SST_LT, S)
		end
		rock(5.2, 1.15, -3.0, 1.1, 25)
		rock(-5.5, 1.1, 2.5, 1.0, -20)
		rock(2.8, 1.15, 5.4, 0.8, 40)
		rock(-4.4, 1.05, -4.4, 0.7, 10)
		-- pebbles
		for _, p in { { 5.9, 0.85, -1.5, 0.45 }, { 4.3, 1.45, 1.4, 0.4 }, { -3.4, 1.45, -2.4, 0.38 }, { -1.2, 0.85, 6.1, 0.42 }, { -6.0, 0.85, -0.6, 0.35 }, { 1.4, 0.85, -6.1, 0.4 } } do
			B:block(soil, v(p[4] * 1.3, p[4], p[4]), cf(p[1], p[2] + p[4] / 2 - 0.1, p[3], 0, rnd(0, 90), 0), pick({ PEB, PEB_LT, PEB_DK }), S)
		end
		-- dry grass tufts (3 blades fanning out)
		local function tuft(x, y, z, k)
			local base = v(x, y, z)
			for j = 0, 2 do
				local a = rad(j * 120 + rnd(-20, 20))
				local tip = base + v(math.sin(a) * 0.5 * k, (1.3 + rnd(-0.2, 0.3)) * k, math.cos(a) * 0.5 * k)
				B:bar(soil, base, tip, 0.22 * k, 0.22 * k, pick({ GRASS_D, GRASS_M, GRASS_L }), S)
			end
			B:bar(soil, base, base + v(0, 1.6 * k, 0), 0.24 * k, 0.24 * k, GRASS_L, S)
		end
		tuft(6.1, 0.75, 1.4, 1.0)
		tuft(-6.0, 0.75, -2.0, 0.9)
		tuft(-1.6, 0.75, 6.2, 1.0)
		tuft(4.6, 0.75, 4.4, 0.85)
		tuft(-4.6, 0.75, -4.0, 0.8)
		tuft(3.9, 1.35, -2.4, 0.75)
		tuft(-3.8, 1.35, 1.2, 0.7)
		-- little cactus sprouts
		local function cactus(x, y, z, k, ry)
			local c = cf(x, y, z, 0, ry, 0)
			B:block(soil, v(0.7 * k, 1.5 * k, 0.7 * k), c * CFrame.new(0, 0.75 * k, 0), CACT, S)
			B:block(soil, v(0.5 * k, 0.4 * k, 0.4 * k), c * CFrame.new(0.55 * k, 0.7 * k, 0), CACT_DK, S)
			B:block(soil, v(0.4 * k, 0.6 * k, 0.4 * k), c * CFrame.new(0.7 * k, 1.1 * k, 0), CACT, S)
			B:block(soil, v(0.4 * k, 0.25 * k, 0.4 * k), c * CFrame.new(0, 1.6 * k, 0) * ang(0, 45, 0), CACT_FL, S)
		end
		cactus(-2.4, 1.38, -3.6, 0.9, 30)
		cactus(5.4, 0.78, 2.8, 0.8, -60)
		cactus(-5.3, 0.78, 0.9, 0.7, 150)
		-- shells
		for _, s in { { 3.2, 1.42, 3.0, SHELL }, { -4.0, 0.82, 4.6, SHELL_PK }, { 6.0, 0.82, -2.6, SHELL } } do
			local c = cf(s[1], s[2], s[3], 0, rnd(0, 180), 0)
			B:block(soil, v(0.7, 0.18, 0.55), c, s[4], S)
			B:block(soil, v(0.12, 0.22, 0.5), c * CFrame.new(0, 0.03, 0), SHELL_PK, S)
		end

		---------------------------------------------------------------- red-rock butte
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		local crystalTips = {}
		local function crystal(base, tip, w, colA, colB, glowTip)
			-- faceted prism (diamond cross-section) stepping to a point
			local d = tip - base
			local up = v(0.7, 0, 0.7)
			if math.abs(d.Unit.Y) < 0.6 then up = v(0, 1, 0) end
			B:bar(crop, base, base + d * 0.7, w, w, colA, { up = up })
			B:bar(crop, base + d * 0.6, base + d * 0.9, w * 0.68, w * 0.68, colB, { up = up })
			if glowTip then
				local g = B:block(crop, v(w * 0.4, w * 0.4, w * 0.4), CFrame.new(base + d * 0.94) * ang(45, 0, 45), GLOW, { mat = "Neon", name = "CrystalGlow" })
				table.insert(crystalTips, g)
			else
				B:bar(crop, base + d * 0.84, base + d, w * 0.38, w * 0.38, AMB_HI, { up = up })
			end
		end
		local function cluster(c, k, n, glowMain)
			-- c: CFrame at the cluster base, local +Y = growth direction
			crystal(c.Position, (c * CFrame.new(0, 2.3 * k, 0)).Position, 1.05 * k, AMB, AMB_LT, glowMain)
			B:block(crop, v(0.18 * k, 1.1 * k, 0.12 * k), c * CFrame.new(0, 0.85 * k, 0) * ang(0, 45, 0) * CFrame.new(0, 0, -0.52 * k), GLOW, { mat = "Neon", name = "CrystalFacet" })
			for j = 1, n do
				local a = j / n * 360 + rnd(-15, 15)
				local tipLocal = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, (1.1 + rnd(0, 0.3)) * k, -(0.95 + rnd(0, 0.2)) * k)
				local bl = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0, -0.25 * k)
				crystal((c * bl).Position, (c * tipLocal).Position, 0.62 * k, (j % 2 == 0) and AMB_DK or AMB, AMB_LT, false)
			end
		end

		-- stepped strata (like a little mesa)
		local function stratum(y0, h, sx, sz, ry, col, band, ox, oz)
			local c = cf(ox, y0 + h / 2, oz, 0, ry, 0)
			B:block(crop, v(sx, h, sz), c, col)
			for k = 0, 3 do
				local q = c * CFrame.Angles(0, rad(k * 90), 0)
				local along = (k % 2 == 0) and sx or sz
				local depth = (k % 2 == 0) and sz or sx
				B:block(crop, v(along * rnd(0.35, 0.55), h - rnd(0.05, 0.25), 0.7), q * CFrame.new(rnd(-0.22, 0.22) * along, rnd(-0.1, 0.05), -depth / 2 - 0.2), (k == 1) and SST_LT or col)
			end
			if band then
				B:block(crop, v(sx + 0.12, 0.32, sz + 0.12), c * CFrame.new(0, h / 2 - 0.28, 0), band)
			end
			return c
		end
		stratum(TOP - 0.1, 1.6, 6.4, 5.4, 8, SST_DK, SST_BAND, 0.1, 0.3)
		stratum(TOP + 1.5, 1.5, 5.4, 4.6, -7, SST, SST_CREAM, -0.15, 0.25)
		stratum(TOP + 3.0, 1.3, 4.4, 3.8, 13, SST_LT, SST_BAND, 0.2, 0.15)
		stratum(TOP + 4.3, 1.0, 3.4, 3.0, -4, SST, SST_CREAM, 0, 0.1)
		local ROCKTOP = TOP + 5.3
		-- side boulders leaning on the butte
		local function boulder(x, z, h, w, ry, tz)
			local c = cf(x, TOP + h / 2 - 0.1, z, 0, ry, tz)
			B:block(crop, v(w, h, w * 0.9), c, SST_DK)
			B:block(crop, v(w + 0.08, 0.3, w * 0.9 + 0.08), c * CFrame.new(0, h * 0.15, 0), SST_CREAM)
			B:block(crop, v(w * 0.7, 0.5, w * 0.6), c * CFrame.new(0.1, h / 2 + 0.2, 0) * ang(0, 25, 0), SST_LT)
		end
		boulder(-3.4, -1.7, 2.8, 2.1, 18, 6)
		boulder(3.3, 2.0, 2.0, 1.8, -25, -5)
		-- amber geode clusters bursting out of the rock
		cluster(cf(-2.9, TOP + 2.0, -2.6) * ang(-40, 30, 25), 0.95, 3, true)
		cluster(cf(3.1, TOP + 1.4, -1.4) * ang(-20, 0, -50), 0.85, 3, false)
		cluster(cf(-2.4, TOP + 3.8, 1.7) * ang(35, 0, 35), 0.7, 2, false)
		cluster(cf(1.7, TOP + 4.0, -1.6) * ang(-45, 0, -25), 0.7, 2, true)
		cluster(cf(0.6, TOP + 1.3, 3.0) * ang(50, 0, -10), 0.8, 3, false)
		-- dark crack lines on the rock faces
		for _, k in { { -0.8, TOP + 1.0, -2.95, 0.3, 1.5 }, { 1.4, TOP + 2.6, -2.45, 0.28, 1.2 }, { 3.05, TOP + 0.9, 0.9, 0.28, 1.3 } } do
			B:block(crop, v(k[4], k[5], 0.2), cf(k[1], k[2], k[3], 0, 0, 15), SST_BAND)
		end

		---------------------------------------------------------------- agave rosette
		local RC = v(0, ROCKTOP, 0.1)
		round(crop, CFrame.new(RC + v(0, 0.1, 0)), 1.3, 0.3, SAND_LT)
		local function leaf(a, len, lift, w, col, colTip)
			local dir = v(math.sin(rad(a)), 0, -math.cos(rad(a)))
			local p0 = RC + v(0, 0.25, 0)
			local p1 = p0 + dir * (len * 0.55) + v(0, lift * 0.4, 0)
			local p2 = p0 + dir * len + v(0, lift, 0)
			B:bar(crop, p0, p1, w, w * 0.45, col)
			B:bar(crop, p1 - (p1 - p0).Unit * 0.2, p2, w * 0.66, w * 0.4, colTip)
			B:bar(crop, p2 - (p2 - p1).Unit * 0.2, p2 + (p2 - p1).Unit * 0.45, w * 0.28, w * 0.28, AG_TIP)
		end
		for i = 0, 6 do
			leaf(i * (360 / 7) + 10, 3.7 + rnd(-0.2, 0.3), 1.1 + rnd(0, 0.5), 1.45, (i % 2 == 0) and AG_DK or AG, (i % 2 == 0) and AG or AG_LT)
		end
		for i = 0, 3 do
			leaf(i * 90 + 50, 2.2, 2.4 + rnd(0, 0.3), 1.1, AG, AG_LT)
		end

		---------------------------------------------------------------- flower stalk
		local path = {
			v(0, ROCKTOP, 0.1),
			v(0.2, ROCKTOP + 3.2, 0.05),
			v(0.35, ROCKTOP + 6.2, -0.1),
			v(0.1, ROCKTOP + 8.8, -0.2),
			v(-0.2, ROCKTOP + 11.0, -0.1),
		}
		local widths = { 1.6, 1.4, 1.2, 1.0 }
		for i = 1, #path - 1 do
			local a, b = path[i], path[i + 1]
			local w = widths[i]
			B:bar(crop, a - v(0, 0.15, 0), b + v(0, 0.15, 0), w, w, (i % 2 == 1) and STK or STK_LT)
			B:bar(crop, a, b, w * 0.4, w + 0.1, STK_DK, { up = v(1, 0, 0) })
			B:block(crop, v(w + 0.35, 0.35, w + 0.35), CFrame.new(b) * ang(0, 45, 0), STK_DK)
		end
		local function stalkAt(y)
			for i = 1, #path - 1 do
				local a, b = path[i], path[i + 1]
				if y <= b.Y then
					return a:Lerp(b, math.clamp((y - a.Y) / (b.Y - a.Y), 0, 1))
				end
			end
			return path[#path]
		end

		-- bloom cup holding a crystal fruit cluster
		local function bloom(c, k, nPet, fruitN, glow)
			B:block(crop, v(1.0 * k, 0.55 * k, 1.0 * k), c * CFrame.new(0, -0.15 * k, 0) * ang(0, 45, 0), STK_DK)
			for j = 0, nPet - 1 do
				local q = c * CFrame.Angles(0, rad(j / nPet * 360), 0)
				local p0 = (q * CFrame.new(0, 0, -0.3 * k)).Position
				local p1 = (q * CFrame.new(0, 0.6 * k, -1.45 * k)).Position
				local p2 = (q * CFrame.new(0, 1.2 * k, -2.0 * k)).Position
				B:bar(crop, p0, p1, 1.25 * k, 0.28 * k, (j % 2 == 0) and PET or PET_DK)
				B:bar(crop, p1 - (p1 - p0).Unit * 0.1, p2, 0.9 * k, 0.26 * k, (j % 2 == 0) and PET_LT or PET)
				B:block(crop, v(0.45 * k, 0.28 * k, 0.45 * k), CFrame.new(p2) * ang(0, j * 72, 0), PET_HI)
			end
			B:block(crop, v(1.2 * k, 0.3 * k, 1.2 * k), c * CFrame.new(0, 0.12 * k, 0), PET_HI)
			cluster(c * CFrame.new(0, 0.15 * k, 0), 1.05 * k, fruitN, glow)
		end
		local arms = {
			{ y = ROCKTOP + 2.6, a = 40, len = 3.4, rise = 1.5, k = 1.1, n = 3, g = true },
			{ y = ROCKTOP + 4.6, a = 220, len = 3.5, rise = 1.6, k = 1.05, n = 3, g = false },
			{ y = ROCKTOP + 6.6, a = 130, len = 3.1, rise = 1.5, k = 0.95, n = 2, g = true },
			{ y = ROCKTOP + 8.3, a = 310, len = 2.7, rise = 1.3, k = 0.85, n = 2, g = false },
		}
		for _, A in arms do
			local p0 = stalkAt(A.y)
			local dir = v(math.sin(rad(A.a)), 0, -math.cos(rad(A.a)))
			local p1 = p0 + dir * (A.len * 0.7) + v(0, A.rise * 0.3, 0)
			local p2 = p0 + dir * A.len + v(0, A.rise, 0)
			B:bar(crop, p0, p1, 0.75, 0.75, STK)
			B:bar(crop, p1 - (p1 - p0).Unit * 0.2, p2, 0.6, 0.6, STK_LT)
			bloom(CFrame.new(p2 + v(0, 0.2, 0)) * ang(0, A.a, 0) * ang(-14, 0, 0), A.k, 5, A.n, A.g)
		end
		-- little yellow buds on the stalk
		for _, bdef in { { ROCKTOP + 1.4, 160 }, { ROCKTOP + 5.6, 20 }, { ROCKTOP + 9.6, 200 } } do
			local p = stalkAt(bdef[1])
			local dir = v(math.sin(rad(bdef[2])), 0, -math.cos(rad(bdef[2])))
			local q = p + dir * 0.9
			B:bar(crop, p, q + v(0, 0.4, 0), 0.3, 0.3, STK)
			B:block(crop, v(0.55, 0.7, 0.55), CFrame.new(q + v(0, 0.7, 0)) * ang(0, 45, 0), PET_LT)
			B:block(crop, v(0.3, 0.3, 0.3), CFrame.new(q + v(0, 1.15, 0)) * ang(0, 45, 0), PET_HI)
		end

		---------------------------------------------------------------- crown flower
		local CT = path[#path] + v(0, 0.2, 0)
		local crown = CFrame.new(CT)
		round(crop, crown * CFrame.new(0, -0.3, 0), 0.9, 0.6, STK_DK)
		for j = 0, 7 do
			local q = crown * CFrame.Angles(0, rad(j * 45 + 22.5), 0)
			local p0 = (q * CFrame.new(0, 0, -0.4)).Position
			local p1 = (q * CFrame.new(0, 0.7, -2.1)).Position
			local p2 = (q * CFrame.new(0, 1.7, -3.0)).Position
			B:bar(crop, p0, p1, 1.4, 0.32, (j % 2 == 0) and PET_DK or PET)
			B:bar(crop, p1 - (p1 - p0).Unit * 0.1, p2, 1.0, 0.3, (j % 2 == 0) and PET or PET_LT)
			B:bar(crop, p2 - (p2 - p1).Unit * 0.1, p2 + (p2 - p1).Unit * 0.55, 0.55, 0.26, (j % 2 == 0) and PET_HI or PET_LT)
		end
		for j = 0, 5 do
			local q = crown * CFrame.Angles(0, rad(j * 60), 0)
			B:bar(crop, (q * CFrame.new(0, 0.2, -0.35)).Position, (q * CFrame.new(0, 1.7, -1.5)).Position, 1.0, 0.28, (j % 2 == 0) and PET_LT or PET)
		end
		round(crop, crown * CFrame.new(0, 0.25, 0), 0.9, 0.4, AMB_DK)
		-- the big amber crystal heart
		local hb = CT + v(0, 0.35, 0)
		crystal(hb, hb + v(0, 3.5, 0), 1.6, AMB, AMB_LT, true)
		local heart = crystalTips[#crystalTips]
		B:block(crop, v(0.3, 1.8, 0.16), CFrame.new(hb + v(0, 1.3, 0)) * ang(0, 45, 0) * CFrame.new(0, 0, -0.78), GLOW, { mat = "Neon", name = "CrystalFacet" })
		for j = 0, 4 do
			local a = rad(j * 72 + 15)
			local dir = v(math.sin(a), 0, -math.cos(a))
			local tall = (j % 2 == 0) and 2.5 or 1.9
			crystal(hb + dir * 0.55, hb + dir * 1.6 + v(0, tall, 0), 0.9, (j % 2 == 0) and AMB_DK or AMB, AMB_LT, j == 2)
		end

		---------------------------------------------------------------- vfx
		local air = B:block(crop, v(11, 16, 11), cf(0, 12, 0), AMB, { tr = 1, name = "SparkleCloud" })
		B:emitter(air, "sparkle", { name = "SandSparkle", color = { "#fff4c8", AMB_HI }, rate = 7, size = { 0.15, 0.35, 0 }, speed = { 0.2, 0.6 }, life = { 1.6, 2.8 }, accel = { 0, 0.25, 0 } })
		local low = B:block(crop, v(11, 1, 11), cf(0, 1.6, 0), AMB, { tr = 1, name = "SandDrift" })
		B:emitter(low, "glow", { name = "SandMotes", color = { SAND_HI, "#ffd27a" }, rate = 1.5, size = { 0.3, 0.55, 0.2 }, speed = { 0.2, 0.6 }, accel = { 0, 0.4, 0 } })
		local top = heart
		B:emitter(top, "sparkle", { name = "CrystalTwinkle", color = { "#ffffff", GLOW }, rate = 3, size = 0.35 })
		B:light(top, { color = "#ffc46a", brightness = 1.2, range = 14, name = "AmberLight" })
	end,
}
