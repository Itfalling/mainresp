--!nocheck
-- Constellation Corn (Starlight Ruins crop #4, Epic).
-- Three tall starlit corn stalks (teal stalks, silver nodes) growing out of
-- a star-temple floor. Long arching leaves fade from teal to night-blue to
-- violet at the tips. The cobs are deep midnight-indigo, and on each cob's
-- face the kernels glow in a constellation: gold and cyan star kernels
-- joined by thin glowing lines. Silver-lavender husks peel back to show
-- them, with pink-gold silk. Golden tassels with glowing star tips; the
-- main tassel is crowned by a big four-point star.
-- Base: stepped octagonal star-temple platform (indigo stone, white marble
-- tiles, gold trim, constellation runes, moss, star dust), a broken
-- white-and-gold pillar stump and a violet crystal cluster.
-- VFX: twinkling star sparkles over every cob, star pollen drifting off the
-- crown star, star dust over the platform, soft glow + two lights.
-- Static prop: no motion.luau.
return {
	DisplayName = "Constellation Corn",
	Rarity = "Epic",
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
		local STALK, STALK_LT, STALK_DK = "#2f8a70", "#43a184", "#236a57"
		local NODE = "#e6d08a"
		local L1 = { "#2b9a90", "#2c7fa6", "#4a5cc0" }
		local L2 = { "#38ad9c", "#3a92bc", "#6c5ad0" }
		local COB, COB_DK, COB_LT, COB_BAND = "#3b37a6", "#2b2886", "#4f4ac2", "#5c57d0"
		local STAR_G, STAR_C, LINE = "#ffe27a", "#9ff6ff", "#d8f6ff"
		local HUSK, HUSK_DK, HUSK_LT = "#d3bff2", "#ab92e0", "#efe6ff"
		local SILK, SILK_DK = "#ff9fd6", "#ffd27a"
		local TASSEL, TASSEL_DK, TASSEL_LT = "#e8b84a", "#c9952e", "#ffd970"
		local NEON = { mat = "Neon" }

		local seed = 18404
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
		rune({ { -3.4, -2.0 }, { -2.5, -3.2 }, { -1.3, -3.0 }, { -0.6, -3.6 } }, RUNE)
		rune({ { 3.4, 2.2 }, { 2.4, 3.3 }, { 1.2, 3.0 } }, RUNE_GOLD)
		-- moss pads draped over tile edges
		for _, m in { { 20, 4.1, 1.5, 2.0, MOSS }, { 160, 4.2, 1.5, 1.7, MOSS_DK }, { 250, 5.9, 0.95, 2.2, MOSS_LT }, { 290, 4.15, 1.5, 1.8, MOSS }, { 110, 5.95, 0.95, 1.9, MOSS_DK } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], m[3], -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[4], 0.3, 1.2), c * ang(-14, 0, 0), m[5], S)
		end
		-- star dust specks
		for _, d in { { -4.7, 1.0, 1.6 }, { 4.9, 1.0, -1.4 }, { -2.1, 1.58, 2.5 }, { 1.8, 1.58, -3.0 }, { 5.1, 1.0, 3.0 }, { -5.0, 1.0, -2.8 }, { 0.4, 1.0, -5.3 } } do
			B:block(soil, v(0.24, 0.24, 0.24), cf(d[1], d[2] + 0.1, d[3], 0, 45, 45), (d[2] > 1.2) and GOLD_LT or RUNE, SN)
		end
		-- violet crystal cluster (front-right)
		local function crystal(x, y, z, h, tz, tx, col)
			B:block(soil, v(0.7, h, 0.7), cf(x, y + h / 2 - 0.2, z, tx, 45, tz), col, S)
			B:block(soil, v(0.4, 0.5, 0.4), cf(x, y - 0.2, z, tx, 45, tz) * CFrame.new(0, h / 2 + 0.2, 0), CRYS_LT, S)
		end
		crystal(4.4, 0.95, -3.3, 1.9, -12, -8, CRYS)
		crystal(3.7, 0.95, -4.1, 1.2, 18, 10, CRYS_LT)
		crystal(5.0, 0.95, -2.8, 1.0, -25, 5, CRYS)
		-- broken pillar stump (back-left): plinth, fluted drum, gold band, jagged top
		do
			local X, Z = -3.0, 3.0
			B:block(soil, v(2.6, 0.45, 2.6), cf(X, 1.62, Z, 0, 10, 0), MARBLE_DK, S)
			B:block(soil, v(2.1, 2.6, 2.1), cf(X, 3.1, Z, 0, 10, 0), MARBLE, S)
			B:block(soil, v(2.3, 0.35, 2.3), cf(X, 2.25, Z, 0, 10, 0), GOLD, S)
			for f = 0, 3 do
				local c = CFrame.new(X, 3.25, Z) * CFrame.Angles(0, rad(10 + 90 * f), 0)
				B:block(soil, v(0.3, 1.9, 0.1), c * CFrame.new(0, 0, -1.06), MARBLE_DK, S)
			end
			B:block(soil, v(1.0, 0.9, 1.0), cf(X - 0.5, 4.8, Z + 0.4, 0, 14, 0), MARBLE_LT, S)
			B:block(soil, v(0.8, 0.5, 0.9), cf(X + 0.5, 4.6, Z + 0.5, 0, 4, 0), MARBLE, S)
			B:block(soil, v(0.7, 0.7, 0.6), cf(X - 0.3, 4.9, Z - 0.5, 10, 20, -8), MARBLE_DK, S)
			-- fallen chunk
			B:block(soil, v(1.2, 0.9, 1.0), cf(X + 1.9, 1.95, Z + 1.0, 8, 35, 12), MARBLE_LT, S)
			-- gold rune on the drum, facing the front
			B:block(soil, v(0.3, 0.3, 0.1), CFrame.new(X, 3.6, Z) * ang(0, 10, 0) * CFrame.new(0, 0, -1.08) * ang(0, 0, 45), RUNE_GOLD, SN)
			B:block(soil, v(0.24, 0.24, 0.1), CFrame.new(X, 2.9, Z) * ang(0, 10, 0) * CFrame.new(0.4, 0, -1.08) * ang(0, 0, 45), RUNE_GOLD, SN)
		end

		local TOP = 1.55
		---------------------------------------------------------------- stalks
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		-- x0,z0 base, x1,z1 top, top height, width
		local stalks = {
			{ 0.3, -0.3, 0.5, -0.3, 15.3, 1.75 },
			{ -1.4, 0.9, -2.9, 1.6, 12.9, 1.45 },
			{ 1.7, 1.1, 3.3, 2.1, 11.2, 1.35 },
		}
		local stalkAt = {}
		for si, s in stalks do
			local H, W = s[5], s[6]
			local function at(y)
				local t = (y - TOP) / (H - TOP)
				local k = t * t
				return v(s[1] + (s[3] - s[1]) * k, y, s[2] + (s[4] - s[2]) * k)
			end
			stalkAt[si] = at
			local p0 = at(TOP)
			B:block(crop, v(W + 0.6, 0.5, W + 0.6), cf(p0.X, TOP + 0.2, p0.Z, 0, 15 * si, 0), STALK_DK)
			for r = 0, (si == 1 and 3 or 1) do
				local d = dirOf(r * (si == 1 and 90 or 180) + si * 40)
				B:bar(crop, at(TOP + 1.3) + d * 0.3, p0 + d * (W * 0.5 + 0.8) - v(0, 0.1, 0), 0.42, 0.42, STALK_DK)
			end
			local y = TOP
			local n = 0
			while y < H - 0.05 do
				local y1 = math.min(H, y + 2.9)
				local w = W * (1 - 0.32 * (y - TOP) / (H - TOP))
				B:bar(crop, at(y), at(y1 + 0.05), w, w, (n % 2 == 1) and STALK_LT or STALK)
				if y1 < H - 0.05 then
					local p = at(y1)
					B:block(crop, v(w + 0.28, 0.3, w + 0.28), cf(p.X, p.Y, p.Z, 0, 12 * n + 20 * si, 0), NODE)
				end
				y = y1
				n += 1
			end
		end

		---------------------------------------------------------------- leaves
		-- long arching blades: up-out, level, drooping tip; colour fades
		-- teal -> night blue -> violet toward the tip.
		local function blade(p, deg, len, w, pal, rise)
			local d = dirOf(deg)
			local pitches = { 46 + rise, 6 + rise * 0.4, -40 }
			local lens = { 0.36, 0.38, 0.26 }
			local widths = { 0.9, 1.0, 0.65 }
			local cur = p
			for i, pt in pitches do
				local pr = rad(pt)
				local sl = len * lens[i]
				local nxt = cur + d * (math.cos(pr) * sl) + v(0, math.sin(pr) * sl, 0)
				local dd = (nxt - cur).Unit
				B:bar(crop, cur - dd * 0.25, nxt + dd * 0.25, w * widths[i], 0.42, pal[i])
				cur = nxt
			end
		end
		local leafs = {
			-- stalk, y, deg, len, width, palette, rise
			{ 1, 5.0, 200, 8.4, 1.8, L2, -3 },
			{ 1, 5.2, 15, 8.2, 1.8, L1, -3 },
			{ 1, 7.4, 115, 7.6, 1.7, L1, -2 },
			{ 1, 10.0, 275, 7.0, 1.6, L2, 4 },
			{ 1, 12.1, 80, 6.0, 1.5, L1, 8 },
			{ 1, 13.7, 230, 5.0, 1.35, L2, 12 },
			{ 2, 5.2, 290, 7.4, 1.6, L1, -6 },
			{ 2, 8.9, 165, 6.2, 1.5, L2, 4 },
			{ 3, 4.8, 100, 7.0, 1.6, L2, -6 },
			{ 3, 8.4, 20, 5.8, 1.45, L1, 4 },
		}
		for _, l in leafs do
			local at = stalkAt[l[1]]
			local p = at(TOP + l[2] - 2.0)
			blade(p + dirOf(l[3]) * 0.5, l[3], l[4], l[5], l[6], l[7])
		end

		---------------------------------------------------------------- cobs
		-- frame F: local +Y along the cob, tipped outward by `tilt`; local -Z
		-- (the flat face carrying the constellation) faces outward.
		-- stars: list of {x, y, gold?} on the face (x in -0.6..0.6, y 1.2..3.6)
		local cobZones = {}
		local function cob(p, deg, tilt, s, stars)
			local F = CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0) * CFrame.Angles(-rad(tilt), 0, 0)
			local function at(x, y, z)
				return F * CFrame.new(x * s, y * s, z * s)
			end
			B:block(crop, v(0.75 * s, 1.0 * s, 0.75 * s), at(0, 0.15, 0), STALK_DK)
			-- stepped cob: narrow base, wide body with kernel bands, tapered top
			B:block(crop, v(1.25 * s, 0.6 * s, 1.25 * s), at(0, 0.75, 0), COB_DK)
			B:block(crop, v(1.6 * s, 2.7 * s, 1.6 * s), at(0, 2.35, 0), COB)
			B:block(crop, v(1.68 * s, 0.32 * s, 1.68 * s), at(0, 1.55, 0), COB_BAND)
			B:block(crop, v(1.68 * s, 0.32 * s, 1.68 * s), at(0, 3.05, 0), COB_BAND)
			B:block(crop, v(1.25 * s, 0.6 * s, 1.25 * s), at(0, 3.95, 0), COB_LT)
			B:block(crop, v(0.75 * s, 0.45 * s, 0.75 * s), at(0, 4.45, 0), COB)
			-- the constellation: star kernels + thin glowing lines on the face
			local fz = -0.8 - 0.06 / s
			local first
			for k, st in stars do
				local col = st[3] and STAR_G or STAR_C
				local sz = st[3] and 0.52 or 0.38
				local part = B:block(crop, v(sz * s, sz * s, 0.12), at(st[1], st[2], fz) * ang(0, 0, 45), col, NEON)
				first = first or part
				if k > 1 then
					local q = stars[k - 1]
					local a = at(q[1], q[2], fz + 0.02).Position
					local b = at(st[1], st[2], fz + 0.02).Position
					B:bar(crop, a, b, 0.15, 0.06, LINE, { mat = "Neon", up = (F * CFrame.new(0, 0, -1)).Position - F.Position })
				end
			end
			-- two loose glowing kernels on the side faces
			B:block(crop, v(0.12, 0.3 * s, 0.3 * s), at(0.8 + 0.06 / s, 2.6, 0.2), STAR_C, NEON)
			B:block(crop, v(0.12, 0.3 * s, 0.3 * s), at(-0.8 - 0.06 / s, 1.9, -0.1), STAR_G, NEON)
			-- husks wrapping the sides and peeling back at the top
			for _, h in { { -1, HUSK }, { 1, HUSK_DK } } do
				local sx = h[1]
				local A = at(sx * 0.7, 0.5, 0.15).Position
				local M = at(sx * 1.0, 2.4, 0.25).Position
				local T = at(sx * 1.85, 3.5, 0.45).Position
				B:bar(crop, A, M, 1.1 * s, 0.3 * s, h[2])
				B:bar(crop, M, T, 0.85 * s, 0.26 * s, HUSK_LT)
			end
			-- back husk
			B:bar(crop, at(0, 0.5, 0.75).Position, at(0, 3.1, 1.15).Position, 1.2 * s, 0.3 * s, HUSK_DK)
			-- pink + gold silk on top
			B:block(crop, v(0.5 * s, 0.45 * s, 0.5 * s), at(0, 4.85, 0) * ang(0, 20, 0), SILK)
			B:block(crop, v(0.3 * s, 0.6 * s, 0.3 * s), at(0.15, 5.2, -0.1) * ang(0, 20, -25), SILK_DK)
			table.insert(cobZones, at(0, 2.4, -0.4))
			return first
		end
		-- constellations (rough shapes of real ones, squeezed onto the cob face)
		local dipper = { { -0.5, 1.2, true }, { -0.45, 1.85 }, { 0.05, 2.15 }, { 0.5, 2.6, true }, { 0.35, 3.25 }, { -0.25, 3.45, true } }
		local cassio = { { -0.55, 1.4, true }, { -0.15, 2.0 }, { 0.3, 1.75, true }, { 0.5, 2.6 }, { 0.0, 3.3, true } }
		local orion = { { -0.45, 1.3 }, { -0.05, 2.0, true }, { 0.15, 2.25 }, { 0.4, 2.5, true }, { 0.45, 3.4 } }
		local lyra = { { 0.0, 3.3, true }, { -0.4, 2.55 }, { -0.3, 1.6 }, { 0.35, 1.45, true }, { 0.4, 2.4 } }
		local swan = { { 0.0, 1.2 }, { 0.0, 2.2, true }, { -0.5, 2.6 }, { 0.0, 2.2 }, { 0.5, 2.0 }, { 0.05, 3.5, true } }
		local big = cob(stalkAt[1](6.0) + dirOf(330) * 1.2, 330, 38, 1.4, dipper)
		cob(stalkAt[1](8.9) + dirOf(65) * 1.1, 65, 36, 1.15, cassio)
		cob(stalkAt[1](11.4) + dirOf(195) * 1.0, 195, 34, 1.05, orion)
		cob(stalkAt[2](7.0) + dirOf(255) * 0.9, 255, 40, 1.05, lyra)
		cob(stalkAt[3](6.6) + dirOf(130) * 0.9, 130, 40, 1.0, swan)

		---------------------------------------------------------------- tassels
		local function tassel(top, s, n, rot)
			B:bar(crop, top - v(0, 0.3, 0), top + v(0, 2.2 * s, 0), 0.4, 0.4, TASSEL)
			for i = 0, n - 1 do
				local d = dirOf(rot + i * 360 / n)
				local a = top + v(0, 0.7 * s, 0)
				local m = a + d * (1.1 * s) + v(0, 0.8 * s, 0)
				local t = m + d * (1.0 * s) - v(0, 0.6 * s, 0)
				B:bar(crop, a, m, 0.3, 0.3, (i % 2 == 0) and TASSEL or TASSEL_DK)
				B:bar(crop, m, t, 0.26, 0.26, TASSEL_LT)
				B:block(crop, v(0.26, 0.26, 0.26), CFrame.new(t) * ang(45, 0, 45), STAR_C, NEON)
			end
		end
		local top1 = stalkAt[1](15.3)
		tassel(top1, 1.25, 5, 15)
		tassel(stalkAt[2](12.9), 0.95, 3, 40)
		tassel(stalkAt[3](11.2), 0.85, 3, 0)
		-- the crown star on the main tassel (four-point star + glowing core)
		local crownC = CFrame.new(top1 + v(0, 3.2, 0)) * ang(0, 20, 0)
		B:block(crop, v(2.2, 0.5, 0.5), crownC * ang(0, 0, 45), GOLD, {})
		B:block(crop, v(2.2, 0.5, 0.5), crownC * ang(0, 0, -45), GOLD_DK, {})
		B:block(crop, v(0.5, 2.6, 0.5), crownC, GOLD_LT, {})
		B:block(crop, v(2.6, 0.5, 0.5), crownC, GOLD_LT, {})
		local crown = B:block(crop, v(0.85, 0.85, 0.85), crownC * ang(0, 0, 45), "#fff6d0", NEON)

		---------------------------------------------------------------- fx
		for zi, zc in cobZones do
			local z = B:block(crop, v(2.0, 3.2, 2.0), zc, "#ffffff", { tr = 1, name = "CobStarZone" .. zi })
			B:emitter(z, "sparkle", {
				color = (zi % 2 == 1) and { "#fff6c0", "#ffe27a" } or { "#e8ffff", "#9ff6ff" },
				rate = 3,
				size = { 0.22, 0.38, 0 },
				life = { 0.8, 1.5 },
				speed = { 0.1, 0.35 },
				name = "CobTwinkle" .. zi,
			})
		end
		local pz = B:block(crop, v(2.4, 2.4, 2.4), crownC, "#ffffff", { tr = 1, name = "CrownZone" })
		B:emitter(pz, "sparkle", { color = { "#ffffff", "#ffe27a", "#ffb0e0" }, rate = 5, size = { 0.3, 0.45, 0 }, speed = { 0.4, 1.0 }, accel = { 0, -0.8, 0 }, life = { 1.2, 2.2 }, name = "StarPollen" })
		local dust = B:block(soil, v(11, 2.5, 11), cf(0, 2.6, 0), "#ffffff", { tr = 1, name = "StarDustZone" })
		B:emitter(dust, "sparkle", { color = { "#fff0a0", "#ffd24a", "#9ff6ff" }, rate = 4, size = { 0.18, 0.3, 0 }, speed = { 0.1, 0.4 }, name = "StarDust" })
		B:light(crown, { color = "#ffe9a0", brightness = 1.0, range = 12, name = "CrownLight" })
		B:light(big, { color = "#9ff6ff", brightness = 0.9, range = 9, name = "CobLight" })
	end,
}
