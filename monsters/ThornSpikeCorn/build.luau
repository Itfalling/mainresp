--!nocheck
-- Spikeleaf Corn (Thorny Woods crop #3, Rare).
-- A tall clump of forest maize: one towering emerald stalk flanked by two
-- shorter ones, all with dark node rings and red-brown brace roots. Long
-- arching blades are edged with little cream thorns. Fat deep-red / maroon
-- kernel cobs poke out of peeled-back husks with golden silk, and every
-- stalk is crowned with a golden tassel (tiny sparkle).
-- Base: stepped forest-dirt mound with moss pads, fallen autumn leaves,
-- stones, two tiny red toadstools and a thorny twig.
-- Static prop: no motion.luau.
return {
	DisplayName = "Spikeleaf Corn",
	Rarity = "Rare",
	Element = "Forest",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Thorny Woods)
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3b2416", "#47291a", "#5e3a22", "#78492b"
		local MOSS, MOSS_DK, MOSS_LT = "#5e9e38", "#3f7a2c", "#86c24a"
		local GRASS, GRASS_DK = "#5fc23c", "#3f9a2e"
		local STONE, STONE_LT, STONE_DK = "#7f7a72", "#9d978b", "#5f5b55"
		local FALL = { "#c8662a", "#a84a22", "#d99a3a" }
		local CAP, DOT, STEM = "#d8343a", "#fff4e6", "#efe3c9"
		local BARK, BARK_DK = "#4a2e1c", "#33200f"
		local STALK, STALK_LT, STALK_DK, NODE = "#3f8f3a", "#55a845", "#2b6a30", "#25502a"
		local ROOT = "#7a3a24"
		local BRAMBLE, BRAMBLE_DK = "#94403a", "#73302e"
		local ROSE, ROSE_LT = "#d8304e", "#ff6f8a"
		local L1 = { "#3a9a40", "#4bb048", "#78c856" }
		local L2 = { "#2f8a3c", "#3ea045", "#62bc4e" }
		local THORN, THORN_RED = "#f1e4c0", "#c43448"
		local K_DK, K_MID, K_RED, K_HI = "#761428", "#a31b33", "#c92a40", "#ec6078"
		local HUSK, HUSK_DK, HUSK_LT = "#7fb04a", "#5c8f38", "#b4d462"
		local SILK, SILK_DK = "#f0b440", "#b9762a"
		local GOLD, GOLD_DK, GOLD_LT = "#f2c13a", "#cf9424", "#ffe27a"
		local NEON = { mat = "Neon" }

		local seed = 3133
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		-- deg 0 = front (-Z), clockwise from above toward +X
		local function dirOf(deg)
			local a = rad(deg)
			return v(math.sin(a), 0, -math.cos(a))
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
				local w, d = rnd(1.5, 2.3), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 5.6, DIRT_DK, 12, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.7, 3.9, DIRT, 8, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.5, 0.5, 2.4, DIRT_LT, 0, {}, 0)
		local TOP = 2.0

		-- moss pads draped over tier edges
		for _, m in { { 30, 3.9, 1.18, 2.1, MOSS }, { 150, 3.95, 1.17, 1.8, MOSS_DK }, { 245, 3.9, 1.18, 2.0, MOSS }, { 320, 5.65, 0.6, 2.3, MOSS_DK }, { 95, 5.7, 0.58, 1.9, MOSS_LT }, { 200, 5.6, 0.6, 1.8, MOSS } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], m[3], -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[4], 0.3, 1.3), c * ang(-12, 0, 0), m[5], S)
		end
		-- stones
		for _, s in { { 4.9, 0.85, 1.2, 0.9, 25, STONE }, { 5.2, 0.7, 2.3, 0.6, 10, STONE_LT }, { -4.6, 0.85, -2.6, 0.8, -20, STONE_DK }, { -3.6, 1.65, 1.2, 0.7, 40, STONE } } do
			B:block(soil, v(s[4] * 1.2, s[4], s[4]), cf(s[1], s[2], s[3], rnd(-10, 10), s[5], rnd(-10, 10)), s[6], S)
		end
		-- fallen autumn leaves
		for i, f in { { 2.8, 1.52, -2.6, 30 }, { -2.2, 1.52, -3.0, -40 }, { 4.5, 0.82, -3.2, 70 }, { -5.2, 0.82, 1.4, 10 } } do
			B:block(soil, v(0.9, 0.12, 0.6), cf(f[1], f[2], f[3], rnd(-6, 6), f[4], rnd(-6, 6)), FALL[(i - 1) % 3 + 1], S)
		end
		-- tiny grass tufts
		for _, g in { { 5.4, -1.6 }, { -2.9, -5.1 }, { -5.5, 0.0 }, { 3.2, 4.7 } } do
			B:block(soil, v(0.45, 0.9, 0.45), cf(g[1], 0.9, g[2], 0, rnd(0, 40), 0), GRASS, S)
		end
		-- two tiny red toadstools
		local function toad(x, y, z, s)
			B:block(soil, v(0.35 * s, 0.8 * s, 0.35 * s), cf(x, y + 0.4 * s, z), STEM, S)
			B:block(soil, v(1.0 * s, 0.4 * s, 1.0 * s), cf(x, y + 0.9 * s, z, 0, 20, 0), CAP, S)
			B:block(soil, v(0.25 * s, 0.1, 0.25 * s), cf(x + 0.2 * s, y + 1.12 * s, z - 0.15 * s, 0, 20, 0), DOT, S)
		end
		toad(-3.3, 1.5, -2.2, 1.0)
		toad(-3.9, 1.5, -1.6, 0.7)
		-- thorny twig lying on the mound
		do
			local a, b = v(2.2, 1.65, 3.2), v(4.9, 1.0, 1.5)
			B:bar(soil, a, b, 0.35, 0.35, BARK, S)
			for _, t in { 0.3, 0.65 } do
				local p = a:Lerp(b, t)
				B:bar(soil, p, p + v(0, 0.55, 0.15), 0.18, 0.18, THORN, S)
			end
		end

		---------------------------------------------------------------- crop
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		-- stalks: x0,z0 base, x1,z1 top, top height, width, node spacing
		local stalks = {
			{ 0.0, -0.2, 0.2, -0.1, 14.4, 1.85 },
			{ -1.6, 1.1, -3.1, 2.1, 11.6, 1.35 },
			{ 1.6, 1.0, 3.2, 1.8, 10.0, 1.3 },
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
			-- base collar + brace roots
			local p0 = at(TOP)
			B:block(crop, v(W + 0.5, 0.5, W + 0.5), cf(p0.X, TOP + 0.15, p0.Z, 0, 15 * si, 0), STALK_DK)
			for r = 0, (si == 1 and 3 or 1) do
				local d = dirOf(r * (si == 1 and 90 or 180) + si * 40)
				B:bar(crop, at(TOP + 1.3) + d * 0.3, p0 + d * (W * 0.5 + 0.8) - v(0, 0.2, 0), 0.4, 0.4, ROOT)
			end
			-- segments with node rings
			local y = TOP
			local n = 0
			while y < H - 0.05 do
				local y1 = math.min(H, y + 2.75)
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

		-- a thorny bramble cane twisting up the lower main stalk (Thorny Woods)
		do
			local at = stalkAt[1]
			local prev
			for k = 0, 7 do
				local t = k / 7
				local y = TOP + 0.3 + t * 4.6
				local c = at(y) + dirOf(200 + k * 95) * 1.45
				if prev then
					local dd = (c - prev).Unit
					B:bar(crop, prev - dd * 0.12, c + dd * 0.12, 0.46, 0.46, (k % 2 == 0) and BRAMBLE or BRAMBLE_DK)
					if k % 2 == 1 then
						local o = v(c.X - at(y).X, 0, c.Z - at(y).Z).Unit
						B:bar(crop, c, c + o * 0.85 + v(0, 0.3, 0), 0.3, 0.3, THORN)
					end
				end
				prev = c
			end
			-- a little briar rose bud where the cane ends
			B:block(crop, v(0.9, 0.8, 0.9), CFrame.new(prev + v(0, 0.5, 0)) * ang(0, 30, 0), ROSE)
			B:block(crop, v(0.6, 0.4, 0.6), CFrame.new(prev + v(0, 1.0, 0)) * ang(0, 75, 0), ROSE_LT)
		end

		---------------------------------------------------------------- leaves
		-- long arching blades: up-out, level, drooping tip. Cream thorns stick
		-- out sideways from both edges at the first two joints.
		local function blade(p, deg, len, w, pal, rise)
			local d = dirOf(deg)
			local right = d:Cross(v(0, 1, 0)).Unit
			local pitches = { 58 + rise, 14 + rise * 0.4, -40 }
			local lens = { 0.36, 0.38, 0.26 }
			local widths = { 1.0, 1.1, 0.7 }
			local cur = p
			for i, pt in pitches do
				local pr = rad(pt)
				local sl = len * lens[i]
				local nxt = cur + d * (math.cos(pr) * sl) + v(0, math.sin(pr) * sl, 0)
				local dd = (nxt - cur).Unit
				B:bar(crop, cur - dd * 0.25, nxt + dd * 0.25, w * widths[i], 0.42, pal[i])
				if i >= 2 then
					local hw = w * widths[i] * 0.5
					for _, sgn in (i == 2) and { 1, -1 } or { (deg % 2 == 0) and 1 or -1 } do
						local e = cur + dd * 0.35 + right * (sgn * (hw - 0.1))
						local col = (i == 3) and THORN_RED or THORN
						B:bar(crop, e, e + right * (sgn * 1.0) + dd * 0.4 + v(0, 0.2, 0), 0.4, 0.4, col)
					end
				end
				cur = nxt
			end
		end
		local leafs = {
			-- stalk, y, deg, len, width, palette, rise
			{ 1, 4.4, 200, 6.6, 1.9, L2, -8 },
			{ 1, 4.6, 20, 6.4, 1.9, L1, -8 },
			{ 1, 7.6, 120, 6.0, 1.8, L1, -2 },
			{ 1, 10.4, 270, 5.6, 1.65, L2, 4 },
			{ 1, 12.2, 80, 4.8, 1.5, L1, 8 },
			{ 2, 5.0, 285, 5.8, 1.7, L1, -6 },
			{ 2, 8.8, 150, 5.0, 1.55, L2, 4 },
			{ 3, 4.8, 95, 5.8, 1.7, L2, -6 },
			{ 3, 7.8, 15, 4.8, 1.5, L1, 4 },
		}
		for _, l in leafs do
			local at = stalkAt[l[1]]
			local p = at(TOP + l[2] - 2.0)
			blade(p + dirOf(l[3]) * 0.5, l[3], l[4], l[5], l[6], l[7])
		end

		---------------------------------------------------------------- cobs
		-- frame F: local +Y along the cob, tipped outward by `tilt`; local -Z
		-- faces outward (toward `deg`).
		local function cob(p, deg, tilt, s)
			local F = CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0) * CFrame.Angles(-rad(tilt), 0, 0)
			local function at(x, y, z)
				return F * CFrame.new(x * s, y * s, z * s)
			end
			-- shank
			B:block(crop, v(0.7 * s, 1.0 * s, 0.7 * s), at(0, 0.2, 0), STALK_DK)
			-- kernel layers (square + 45° turned square, two-tone)
			local layers = { 1.35, 1.65, 1.7, 1.55, 1.25, 0.85 }
			for i, w in layers do
				local y = 0.8 + (i - 1) * 0.58
				local a, b2 = (i % 2 == 1) and K_MID or K_DK, (i % 2 == 1) and K_DK or K_RED
				B:block(crop, v(w * s, 0.6 * s, w * s), at(0, y, 0), a)
				B:block(crop, v(w * 0.93 * s, 0.56 * s, w * 0.93 * s), at(0, y, 0) * ang(0, 45, 0), b2)
			end
			-- kernel highlights on the outward face
			B:block(crop, v(0.4 * s, 0.4 * s, 0.2 * s), at(-0.3, 2.0, -0.84), K_HI)
			B:block(crop, v(0.22 * s, 0.22 * s, 0.12 * s), at(0.25, 1.5, -0.9), K_HI, NEON)
			-- husk leaves wrapping the lower half and peeling back at the top
			for _, h in { { -1, 0, HUSK }, { 1, 0, HUSK_DK } } do
				local sx, sz = h[1], h[2]
				local base = v(sx * 0.62, 0.5, sz * 0.62)
				local mid = v(sx * 0.95, 2.3, sz * 0.95 + (sx ~= 0 and 0.1 or 0))
				local tip = v(sx * 1.75, 3.2, sz * 1.6)
				local A = (F * CFrame.new(base * s)).Position
				local M = (F * CFrame.new(mid * s)).Position
				local T = (F * CFrame.new(tip * s)).Position
				B:bar(crop, A, M, 1.05 * s, 0.32 * s, h[3])
				B:bar(crop, M, T, 0.8 * s, 0.28 * s, HUSK_LT)
			end
			-- golden silk tuft on top
			B:block(crop, v(0.5 * s, 0.4 * s, 0.5 * s), at(0, 4.2, 0) * ang(0, 20, 0), SILK)
			B:block(crop, v(0.3 * s, 0.5 * s, 0.3 * s), at(0.1, 4.5, -0.1) * ang(0, 20, -20), SILK_DK)
		end
		cob(stalkAt[1](6.4) + dirOf(320) * 0.9, 320, 36, 1.22)
		cob(stalkAt[1](9.4) + dirOf(45) * 0.8, 45, 34, 1.05)
		cob(stalkAt[2](7.4) + dirOf(215) * 0.6, 215, 38, 0.92)

		---------------------------------------------------------------- tassels
		local function tassel(top, s, n, rot)
			B:bar(crop, top - v(0, 0.3, 0), top + v(0, 2.2 * s, 0), 0.38, 0.38, GOLD)
			B:block(crop, v(0.3, 0.3, 0.3), cf(top.X, top.Y + 2.3 * s, top.Z, 0, 30, 0), GOLD_LT, NEON)
			for i = 0, n - 1 do
				local d = dirOf(rot + i * 360 / n)
				local a = top + v(0, 0.7 * s, 0)
				local m = a + d * (1.1 * s) + v(0, 0.8 * s, 0)
				local t = m + d * (1.0 * s) - v(0, 0.6 * s, 0)
				B:bar(crop, a, m, 0.3, 0.3, (i % 2 == 0) and GOLD or GOLD_DK)
				B:bar(crop, m, t, 0.26, 0.26, GOLD_LT)
			end
		end
		local top1 = stalkAt[1](14.4)
		tassel(top1, 1.25, 5, 15)
		tassel(stalkAt[2](11.6), 0.95, 3, 40)
		tassel(stalkAt[3](10.0), 0.85, 3, 0)

		-- tiny golden pollen sparkle around the top tassel
		local spark = B:block(crop, v(2.5, 1.5, 2.5), cf(top1.X, top1.Y + 1.6, top1.Z), GOLD, { tr = 1, name = "PollenZone" })
		B:emitter(spark, "sparkle", { color = { "#fff2a0", "#ffc83a" }, rate = 3, size = { 0.25, 0.35, 0 }, name = "Pollen" })
	end,
}
