--!nocheck
-- Comet Gourd Vine (Starlight Ruins crop #3, Rare).
-- A starlit teal vine spirals up a broken white-and-gold temple pillar.
-- Violet bottle gourds with gold star caps hang from its arms, and every
-- gourd is a little comet: a stepped, glassy tail of cyan -> violet -> pink
-- blocks streams behind it, all tails sweeping the same way round the pillar
-- so the gourds look like comets orbiting it. One comet gourd has crashed
-- onto the tiles in a small crater, its tail streaking across the floor.
-- Base: stepped octagonal star-temple platform (indigo stone, white marble
-- tiles, gold trim, glowing constellation runes, moss, star dust, crystals).
-- VFX: sparkle streams drifting off every comet tail, star-dust twinkles,
-- a soft glow + light on the crashed comet. Static prop: no motion.luau.
return {
	DisplayName = "Comet Gourd Vine",
	Rarity = "Rare",
	Element = "Cosmic",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Starlight Ruins)
		local BASE, BASE_DK, BASE_LT = "#2c2a5c", "#211f48", "#3a3874"
		local SLATE = { "#4a4886", "#55538f", "#403e76" }
		local GROUT = "#1c1a3a"
		local TILE = { "#ece8dc", "#dcd6c8", "#e4dfd2" }
		local TILE_DK = "#bdb5a6"
		local GOLD, GOLD_DK, GOLD_LT = "#e8b84a", "#b98a2e", "#ffd970"
		local MOSS, MOSS_DK, MOSS_LT = "#3f9a7c", "#2c7a63", "#62b892"
		local RUNE, RUNE_GOLD = "#8af4ff", "#ffd970"
		local CRYS, CRYS_LT = "#8a6cff", "#b9a4ff"
		local MARBLE, MARBLE_LT, MARBLE_DK = "#efeae0", "#faf7f0", "#cfc8ba"
		local VINE, VINE_DK = "#2f8a74", "#226a5c"
		local LEAF = { "#2f8f7c", "#3aa58c", "#4cb99c" }
		local LEAF_SILVER = "#a6dccb"
		local GOURD, GOURD_RIB, GOURD_DK, GOURD_LT = "#5d48c9", "#7a63e2", "#43339f", "#9a88f0"
		local SPECK = "#9ff6ff"
		local FLOWER, FLOWER_C = "#f4f0ff", "#ffd24a"
		local TAIL = { "#c4f8ff", "#6fe3ff", "#5a9cff", "#8c68ff", "#d07cff" }
		local TAIL_TR = { 0, 0.08, 0.18, 0.32, 0.5 }
		local NEON = { mat = "Neon" }

		local seed = 18303
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function dirOf(deg)
			local a = rad(deg)
			return v(math.sin(a), 0, -math.cos(a))
		end

		---------------------------------------------------------------- platform
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local SN = { name = "Soil", mat = "Neon" }
		local function octagon(y0, h, w, col)
			B:block(soil, v(w, h, w * 0.78), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(w * 0.78, h - 0.04, w), cf(0, y0 + h / 2, 0), col, S)
		end
		-- tier 1: dark indigo temple stone with slate floor slabs
		octagon(0, 0.8, 12.2, BASE)
		for i = 0, 11 do
			local a = (i + rnd(-0.25, 0.25)) / 12 * 360 + 15
			local r = 5.75 + rnd(-0.1, 0.3)
			local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0, -r)
			local eh = rnd(0.45, 0.85)
			B:block(soil, v(rnd(1.2, 1.9), eh, rnd(0.9, 1.3)), p * CFrame.new(0, eh / 2, 0) * ang(0, rnd(-10, 10), 0), (i % 3 == 0) and BASE_DK or BASE_LT, S)
		end
		for gx = -5, 5, 2 do
			for gz = -5, 5, 2 do
				local inner = math.abs(gx) <= 3 and math.abs(gz) <= 3
				local corner = math.abs(gx) == 5 and math.abs(gz) == 5
				if not inner and not corner and rnd(0, 1) > 0.18 then
					B:block(soil, v(1.85, 0.2, 1.85), cf(gx + rnd(-0.08, 0.08), 0.85, gz + rnd(-0.08, 0.08), rnd(-3, 3), rnd(-6, 6), rnd(-3, 3)), pick(SLATE), S)
				end
			end
		end
		-- tier 2: white marble tiles on dark grout, gold trim
		octagon(0.8, 0.62, 8.3, GROUT)
		for gx = -3, 3, 2 do
			for gz = -3, 3, 2 do
				local corner = math.abs(gx) == 3 and math.abs(gz) == 3
				local h = 0.72 + rnd(-0.02, 0.08)
				if corner then
					-- cracked corner tile, sunk and tilted
					B:block(soil, v(1.6, 0.6, 1.6), cf(gx * 0.93, 1.05, gz * 0.93, rnd(-8, 8), rnd(-20, 20), rnd(-8, 8)), TILE_DK, S)
				else
					B:block(soil, v(1.9, h, 1.9), cf(gx, 0.8 + h / 2, gz), pick(TILE), S)
				end
			end
		end
		for i = 0, 3 do
			local c = CFrame.Angles(0, rad(90 * i), 0)
			B:block(soil, v(4.4, 0.22, 0.3), c * CFrame.new(0, 1.35, -4.12), GOLD, S)
		end
		-- glowing constellation runes inlaid in the floor tiles
		local function rune(pts, col)
			for k, p in pts do
				B:block(soil, v(0.32, 0.08, 0.32), cf(p[1], 1.56, p[2], 0, 45, 0), col, SN)
				if k > 1 then
					local q = pts[k - 1]
					B:bar(soil, v(q[1], 1.55, q[2]), v(p[1], 1.55, p[2]), 0.1, 0.06, col, SN)
				end
			end
		end
		rune({ { 3.5, -2.2 }, { 2.7, -3.3 }, { 1.6, -2.9 }, { 0.9, -3.6 } }, RUNE)
		rune({ { 2.4, 3.4 }, { 3.3, 2.5 }, { 3.0, 1.6 } }, RUNE_GOLD)
		-- moss pads draped over tile edges
		for _, m in { { 35, 4.1, 1.5, 2.0, MOSS }, { 150, 4.2, 1.5, 1.7, MOSS_DK }, { 230, 5.9, 0.95, 2.2, MOSS_LT }, { 300, 4.15, 1.5, 1.8, MOSS }, { 95, 5.95, 0.95, 1.9, MOSS_DK } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], m[3], -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[4], 0.3, 1.2), c * ang(-14, 0, 0), m[5], S)
		end
		-- star dust specks
		for _, d in { { -4.6, 1.0, 1.9 }, { 4.9, 1.0, -1.2 }, { -2.0, 1.58, 2.6 }, { 1.4, 1.58, -3.2 }, { 5.2, 1.0, 2.9 }, { -5.1, 1.0, -2.6 } } do
			B:block(soil, v(0.24, 0.24, 0.24), cf(d[1], d[2] + 0.1, d[3], 0, 45, 45), (d[2] > 1.2) and GOLD_LT or RUNE, SN)
		end
		-- violet crystal cluster poking out of the floor (back-left)
		local function crystal(x, y, z, h, tz, tx, col)
			B:block(soil, v(0.7, h, 0.7), cf(x, y + h / 2 - 0.2, z, tx, 45, tz), col, S)
			B:block(soil, v(0.4, 0.5, 0.4), cf(x, y - 0.2, z, tx, 45, tz) * CFrame.new(0, h / 2 + 0.2, 0), CRYS_LT, S)
		end
		crystal(-4.3, 0.95, 3.4, 1.8, 12, -8, CRYS)
		crystal(-3.7, 0.95, 4.1, 1.2, -18, 10, CRYS_LT)
		crystal(-4.9, 0.95, 3.0, 0.9, 25, 5, CRYS)
		-- broken pillar drum lying on the bottom tier (right)
		do
			local C = cf(4.9, 1.55, 0.6, 0, 12, 90)
			B:block(soil, v(1.5, 2.1, 1.5), C, MARBLE, S)
			B:block(soil, v(1.7, 0.35, 1.7), C * CFrame.new(0, 0.85, 0), GOLD_DK, S)
			for k = 0, 1 do
				B:block(soil, v(0.28, 2.0, 0.08), C * CFrame.new(-0.35 + 0.7 * k, 0, -0.76), MARBLE_DK, S)
			end
		end

		local TOP = 1.5
		---------------------------------------------------------------- pillar
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		local PX, PZ = 0, 0.5
		local function pc(x, y, z, ry)
			return cf(PX + x, y, PZ + z, 0, ry or 0, 0)
		end
		B:block(crop, v(3.9, 0.55, 3.9), pc(0, TOP + 0.27, 0), MARBLE_DK)
		B:block(crop, v(4.0, 0.18, 4.0), pc(0, TOP + 0.5, 0), GOLD)
		B:block(crop, v(3.2, 0.5, 3.2), pc(0, TOP + 0.82, 0), MARBLE)
		B:block(crop, v(2.7, 0.35, 2.7), pc(0, TOP + 1.2, 0), MARBLE_LT)
		local drums = { { TOP + 1.35, 7.4 }, { 7.75, 12.0 } }
		for di, d in drums do
			local y0, y1 = d[1], d[2]
			B:block(crop, v(2.2, y1 - y0, 2.2), pc(0, (y0 + y1) / 2, 0), (di == 1) and MARBLE or MARBLE_LT)
			for f = 0, 3 do
				local c = CFrame.new(PX, (y0 + y1) / 2, PZ) * CFrame.Angles(0, rad(90 * f), 0)
				for _, o in { -0.5, 0.5 } do
					B:block(crop, v(0.3, y1 - y0 - 0.3, 0.1), c * CFrame.new(o, 0, -1.11), MARBLE_DK)
				end
			end
		end
		-- gold band between the drums
		B:block(crop, v(2.55, 0.4, 2.55), pc(0, 7.57, 0), GOLD)
		B:block(crop, v(2.35, 0.2, 2.35), pc(0, 7.57, 0, 45), GOLD_DK)
		-- broken, jagged top
		B:block(crop, v(1.2, 1.6, 1.1), pc(-0.5, 12.75, 0.5, 4), MARBLE_LT)
		B:block(crop, v(1.0, 0.9, 1.0), pc(0.6, 12.4, 0.55, -6), MARBLE)
		B:block(crop, v(0.9, 0.6, 1.2), pc(0.55, 12.25, -0.5, 3), MARBLE_DK)
		B:block(crop, v(0.7, 1.1, 0.6), pc(-0.65, 13.6, 0.6, 10), MARBLE)
		B:block(crop, v(1.0, 0.7, 0.8), cf(PX - 0.2, 12.6, PZ - 0.55, 18, 0, -12), MARBLE_LT)
		-- crack running down the upper drum
		B:block(crop, v(0.14, 1.6, 0.06), cf(PX + 0.25, 11.0, PZ - 1.13, 0, 0, 14), MARBLE_DK)
		B:block(crop, v(0.14, 1.2, 0.06), cf(PX + 0.05, 9.7, PZ - 1.13, 0, 0, -10), MARBLE_DK)
		-- constellation rune carved on the front of the lower drum
		do
			local pts = { { -0.55, 5.6 }, { 0.1, 6.1 }, { 0.45, 5.2 }, { 0.0, 4.4 }, { -0.5, 3.9 } }
			for k, p in pts do
				B:block(crop, v(0.3, 0.3, 0.1), cf(PX + p[1], p[2], PZ - 1.16, 0, 0, 45), RUNE, NEON)
				if k > 1 then
					local q = pts[k - 1]
					B:bar(crop, v(PX + q[1], q[2], PZ - 1.14), v(PX + p[1], p[2], PZ - 1.14), 0.1, 0.06, RUNE, NEON)
				end
			end
		end

		---------------------------------------------------------------- vine
		local N = 16
		local R0 = 1.55
		local A0, TURN = 210, 560
		local vinePts = {}
		local function vineAng(k)
			return A0 + k / N * TURN
		end
		for k = 0, N do
			local t = k / N
			local r = R0 + 0.1 * math.sin(t * 9)
			vinePts[k] = dirOf(vineAng(k)) * r + v(PX, TOP + 1.1 + t * (12.4 - TOP - 1.1), PZ)
		end
		-- vine climbs over the broken top and arches forward into a hook
		local crest = {
			v(PX + 0.5, 13.9, PZ - 0.2),
			v(PX + 0.3, 15.6, PZ - 0.5),
			v(PX - 0.9, 16.7, PZ - 1.2),
			v(PX - 1.8, 16.5, PZ - 2.1),
			v(PX - 2.2, 15.8, PZ - 2.5),
		}
		B:block(crop, v(1.4, 0.7, 1.4), CFrame.new(vinePts[0] - v(0, 0.35, 0)) * ang(0, 25, 0), VINE_DK)
		local function seg(a, b, w, col)
			local dd = (b - a).Unit
			B:bar(crop, a - dd * 0.18, b + dd * 0.18, w, w, col)
		end
		for k = 0, N - 1 do
			seg(vinePts[k], vinePts[k + 1], 0.6, (k % 2 == 0) and VINE or VINE_DK)
		end
		seg(vinePts[N], crest[1], 0.58, VINE)
		for k = 1, #crest - 1 do
			seg(crest[k], crest[k + 1], 0.58 - 0.06 * k, (k % 2 == 0) and VINE_DK or VINE)
		end
		-- leaf cubes along the spiral (kept off the rune on the pillar front)
		for j, k in { 1, 2, 3, 5, 6, 7, 9, 10, 12, 13, 15, 16 } do
			local p = vinePts[k]
			local out = v(p.X - PX, 0, p.Z - PZ).Unit
			if not (out.Z < -0.75 and p.Y < 7.5) then
				local s = 2.1 - 0.04 * k
				local col = (j == 5 or j == 10) and LEAF_SILVER or LEAF[(j % 3) + 1]
				B:block(crop, v(s, s * 0.75, s), CFrame.new(p + out * (0.35 + s * 0.35) + v(0, 0.2, 0)) * ang(rnd(-25, 25), rnd(0, 90), rnd(-25, 25)), col)
			end
		end
		-- leafy crown on the crest
		B:block(crop, v(2.0, 1.5, 2.0), CFrame.new(crest[1] + v(0.9, 0.3, 0.6)) * ang(20, 30, -15), LEAF[3])
		B:block(crop, v(1.9, 1.4, 1.9), CFrame.new(crest[2] + v(-1.0, 0.0, 0.7)) * ang(-15, 60, 20), LEAF[1])
		B:block(crop, v(1.7, 1.3, 1.7), CFrame.new(crest[2] + v(1.0, 0.4, 0.4)) * ang(10, 15, 25), LEAF[2])
		B:block(crop, v(1.4, 1.1, 1.4), CFrame.new(crest[3] + v(0.2, 0.75, 0.3)) * ang(15, 40, -10), LEAF_SILVER)
		B:block(crop, v(1.1, 0.9, 1.1), CFrame.new(crest[4] + v(-0.6, 0.5, 0)) * ang(-10, 10, 20), LEAF[1])
		-- curly tendril off the hook
		seg(crest[3] + v(0, 0.2, 0), crest[3] + v(0.9, 1.0, 0.2), 0.22, MOSS_LT)
		seg(crest[3] + v(0.9, 1.0, 0.2), crest[3] + v(1.4, 0.7, -0.3), 0.2, MOSS_LT)

		-- pale star flowers (crossed petals + gold neon centre)
		local function flower(p, s, ry)
			B:block(crop, v(1.2 * s, 0.2, 0.4 * s), CFrame.new(p) * ang(0, ry, 0), FLOWER)
			B:block(crop, v(0.4 * s, 0.2, 1.2 * s), CFrame.new(p) * ang(0, ry, 0), FLOWER)
			B:block(crop, v(0.3 * s, 0.3, 0.3 * s), CFrame.new(p + v(0, 0.06, 0)) * ang(0, ry + 45, 0), FLOWER_C, NEON)
		end

		---------------------------------------------------------------- comet gourds
		-- a gourd hangs from `p`; it "orbits" the pillar, so its tail streams
		-- back along the orbit (tangent) and sweeps upward like a rising comet.
		local tailZones = {}
		local function comet(p, s, theta, stemLen)
			local F = CFrame.new(p) * CFrame.Angles(0, -rad(theta), 0)
			local function at(x, y, z, ry)
				return F * CFrame.new(x * s, y * s, z * s) * CFrame.Angles(0, rad(ry or 0), 0)
			end
			local sl = stemLen
			B:block(crop, v(0.32, sl + 0.25, 0.32), F * CFrame.new(0, -sl / 2, 0) * ang(0, 0, 6), VINE_DK)
			local y0 = -sl / s
			local function Y(y)
				return y0 - y
			end
			-- gold star calyx
			B:block(crop, v(1.5 * s, 0.22, 0.42 * s), at(0, Y(0.12), 0, 0), GOLD)
			B:block(crop, v(1.5 * s, 0.2, 0.42 * s), at(0, Y(0.12), 0, 90), GOLD_DK)
			-- neck, shoulder, ribbed bulb, bottom
			B:block(crop, v(0.85 * s, 1.0 * s, 0.85 * s), at(0, Y(0.65), 0, 45), GOURD_LT)
			B:block(crop, v(1.5 * s, 0.55 * s, 1.5 * s), at(0, Y(1.3), 0), GOURD_RIB)
			B:block(crop, v(2.5 * s, 1.8 * s, 1.65 * s), at(0, Y(2.4), 0), GOURD)
			B:block(crop, v(1.65 * s, 1.78 * s, 2.5 * s), at(0, Y(2.4), 0), GOURD_RIB)
			B:block(crop, v(2.2 * s, 1.6 * s, 2.2 * s), at(0, Y(2.4), 0, 45), GOURD_DK)
			B:block(crop, v(1.7 * s, 0.5 * s, 1.7 * s), at(0, Y(3.4), 0), GOURD)
			B:block(crop, v(0.6 * s, 0.35 * s, 0.6 * s), at(0, Y(3.75), 0, 45), GOLD_DK)
			-- glowing star speckles on the outward face
			local speck = B:block(crop, v(0.32 * s, 0.32 * s, 0.1), at(-0.45, Y(2.1), -0.86), SPECK, NEON)
			B:block(crop, v(0.24 * s, 0.24 * s, 0.1), at(0.42, Y(2.75), -0.86), SPECK, NEON)
			-- the comet tail: glassy stepped blocks, cyan -> violet -> pink
			local out = dirOf(theta)
			local back = dirOf(theta - 90)
			local head = (at(0, Y(2.45), 0)).Position + back * (0.55 * s)
			local cur = head
			local lens = { 1.4, 1.35, 1.3, 1.2, 1.1 }
			local sizes = { 1.95, 1.55, 1.15, 0.82, 0.52 }
			local first, last
			for i = 1, 5 do
				local e = rad(2 + i * 7)
				local d = (back * math.cos(e) - out * (0.13 * i) + v(0, math.sin(e), 0)).Unit
				local nxt = cur + d * (lens[i] * s)
				B:bar(crop, cur - d * 0.12, nxt + d * 0.12, sizes[i] * s, sizes[i] * s, TAIL[i], { tr = TAIL_TR[i] })
				if i == 1 then
					first = nxt
				end
				last = nxt
				cur = nxt
			end
			-- bright neon core streak + two thin side streamers
			B:bar(crop, head - back * 0.2, first, 0.36 * s, 0.36 * s, "#e8ffff", NEON)
			for _, sg in { 1, -1 } do
				local o = out * (0.6 * s * sg) - v(0, 0.25 * s, 0)
				B:bar(crop, head + back * (0.3 * s) + o, head:Lerp(last, 0.72) + o * 1.4, 0.18 * s, 0.18 * s, TAIL[3], { tr = 0.35 })
			end
			table.insert(tailZones, { head:Lerp(last, 0.55), (last - head).Unit, (last - head).Magnitude })
			return speck
		end

		-- vine arms reaching out from the spiral to carry the gourds
		local function arm(k, len, rise)
			local p = vinePts[k]
			local out = v(p.X - PX, 0, p.Z - PZ).Unit
			local m = p + out * (len * 0.55) + v(0, rise, 0)
			local tip = m + out * (len * 0.45) - v(0, 0.15, 0)
			seg(p, m, 0.42, VINE)
			seg(m, tip, 0.36, VINE_DK)
			-- curly tendril
			local c1 = m + v(0, 0.2, 0)
			local c2 = c1 + v(0, 0.9, 0) - out * 0.3
			seg(c1, c2, 0.2, MOSS_LT)
			local theta = math.deg(math.atan2(out.X, -out.Z))
			return tip, theta
		end
		local gourds = {
			-- spiral index, arm length, rise, scale, stem
			{ 6, 2.5, 0.9, 1.05, 0.5 },
			{ 9, 2.6, 0.7, 1.15, 0.55 },
			{ 12, 2.5, 0.6, 1.0, 0.5 },
			{ 15, 2.3, 0.5, 0.9, 0.45 },
		}
		local bigSpeck
		for gi, g in gourds do
			local tip, theta = arm(g[1], g[2], g[3])
			local sp = comet(tip, g[4], theta, g[5])
			if gi == 2 then
				bigSpeck = sp
			end
		end
		-- crown comet hanging from the hook at the very top
		comet(crest[5], 0.95, -45, 0.35)
		flower(vinePts[3] + dirOf(vineAng(3)) * 1.9 + v(0, 1.1, 0), 1.0, 20)
		flower(vinePts[10] + dirOf(vineAng(10)) * 1.8 + v(0, 1.0, 0), 0.9, 60)
		flower(crest[2] + v(1.2, 1.25, 0.4), 0.85, 10)

		---------------------------------------------------------------- crashed comet
		-- a comet gourd lying in a little crater of cracked tiles, its tail
		-- streaking back across the floor.
		local crash
		do
			local C = cf(-2.9, 2.25, -2.7, 0, 35, -78)
			B:block(soil, v(2.3, 1.6, 2.3), C, GOURD, S)
			B:block(soil, v(2.1, 1.55, 2.1), C * ang(0, 45, 0), GOURD_RIB, S)
			B:block(soil, v(1.2, 0.9, 1.2), C * CFrame.new(0, 1.15, 0), GOURD_LT, S)
			B:block(soil, v(1.5, 0.22, 0.42), C * CFrame.new(0, 1.65, 0), GOLD, S)
			B:block(soil, v(0.42, 0.2, 1.5), C * CFrame.new(0, 1.65, 0), GOLD_DK, S)
			crash = B:block(soil, v(0.3, 0.3, 0.1), C * CFrame.new(0.4, -0.3, -1.08), SPECK, SN)
			-- crater rim of upturned tiles
			for _, r in { { -1.6, 1.6, -4.3, 25, -20 }, { -4.5, 1.6, -3.5, -15, 25 }, { -4.3, 1.7, -1.5, 10, -30 } } do
				B:block(soil, v(1.1, 0.4, 0.9), cf(r[1], r[2], r[3], r[4], rnd(0, 60), r[5]), TILE_DK, S)
			end
			-- tail across the floor (toward the back-right)
			local head = v(-3.3, 2.2, -1.6)
			local d = v(-0.4, 0.12, 1).Unit
			local cur = head
			for i = 1, 4 do
				local nxt = cur + d * 1.25
				B:bar(soil, cur, nxt, 1.25 - 0.2 * i, 0.9 - 0.15 * i, TAIL[i + 1], { tr = TAIL_TR[i + 1], name = "Soil" })
				cur = nxt
			end
		end

		---------------------------------------------------------------- fx
		-- each comet tail sheds a stream of sparkles drifting along the tail
		for zi, z in tailZones do
			local zp = B:block(crop, v(0.8, 0.8, z[3] * 0.7), CFrame.lookAt(z[1], z[1] + z[2]), "#ffffff", { tr = 1, name = "CometZone" .. zi })
			B:emitter(zp, "sparkle", {
				color = { "#ffffff", "#8af4ff", "#c79bff" },
				rate = 5,
				size = { 0.35, 0.28, 0 },
				life = { 0.9, 1.6 },
				speed = { 0.2, 0.5 },
				accel = { z[2].X * 1.6, z[2].Y * 1.6, z[2].Z * 1.6 },
				name = "CometSparks" .. zi,
			})
		end
		-- gold + cyan star dust twinkling over the platform
		local dust = B:block(soil, v(11, 2.5, 11), cf(0, 2.6, 0), "#ffffff", { tr = 1, name = "StarDustZone" })
		B:emitter(dust, "sparkle", { color = { "#fff0a0", "#ffd24a", "#9ff6ff" }, rate = 4, size = { 0.18, 0.3, 0 }, speed = { 0.1, 0.4 }, name = "StarDust" })
		-- crashed comet: soft glow + cyan light
		local gz = B:block(soil, v(1.8, 1.8, 1.8), cf(-2.9, 2.4, -2.7), "#ffffff", { tr = 1, name = "CrashGlowZone" })
		B:emitter(gz, "glow", { color = "#9ff6ff", rate = 1.5, size = { 1.2, 2.0, 0.6 }, name = "CrashGlow" })
		B:light(crash, { color = "#8af4ff", brightness = 1.0, range = 10, name = "CrashLight" })
		B:light(bigSpeck, { color = "#b48cff", brightness = 0.8, range = 9, name = "GourdLight" })
	end,
}
