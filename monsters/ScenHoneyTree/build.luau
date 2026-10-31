--!nocheck
-- Honey Blossom Tree (Honey Hills scenery, big copy-paste filler).
-- A round, puffy blossom tree: a stout warm-brown trunk with flared roots and
-- a forked crown of branches holding a ball-shaped canopy of big stepped
-- blossom clusters, golden and pink in alternation (shade / main / highlight
-- tiers each), with green leaf cubes peeking out underneath and little white
-- and pink flowers dotted over it. A small honeycomb hangs from one branch,
-- with a honey drip. Low flat meadow footing with daisies, clover and
-- pebbles. Filler: anchored, weld-free, no scripts.
return {
	DisplayName = "Honey Blossom Tree",
	Rarity = "Scenery",
	Filler = true,
	Element = "Honey Hills",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Honey Hills: HoneyCombPear / DecorHoneyHives / DecorHoneySign)
		local SOIL_DK, SOIL = "#6b4226", "#875533"
		local GR_DK, GR, GR_LT, GR_XL = "#7cae32", "#97c83e", "#b2d84c", "#d2e872"
		local CLOVER, CLOVER_DK = "#3f9a3c", "#2f7f30"
		local PEB, PEB_LT = "#a49a8c", "#c4bcae"
		local DAISY, DAISY_EYE = "#fffaf2", "#ffc93a"
		local FL_PINK, FL_WHITE = "#ff9cc4", "#fff6fa"
		local BARK_DK, BARK, BARK_LT = "#5a3720", "#74472a", "#8f5c36"
		local LF_DK, LF, LF_MID = "#46a83a", "#5dbd40", "#76cc48"
		local GOLD = { "#f5b81f", "#ffd23a", "#ffe46b" }
		local PINK = { "#ef8fb6", "#ffa9c9", "#ffc7dd" }
		local WAX_LT, WAX, WAX_DK = "#ffe27a", "#ffc93c", "#e8a020"
		local CELL, CELL_DK = "#c87410", "#a65a0c"
		local HONEY, HONEY_LT = "#ffa318", "#ffc54a"

		local seed = 4227
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function dirOf(a)
			return v(math.sin(rad(a)), 0, -math.cos(rad(a)))
		end
		local function round(c, r, h, col)
			B:block(R, v(2 * r, h, 1.1 * r), c, col)
			B:block(R, v(1.1 * r, h - 0.02, 2 * r), c, col)
			B:block(R, v(1.72 * r, h - 0.04, 1.72 * r), c, col)
		end
		local function oct(c, s, h, col, col2)
			B:block(R, v(s, h, s), c, col)
			B:block(R, v(s * 0.82, h - 0.04, s * 0.82), c * ang(0, 45, 0), col2 or col)
		end

		------------------------------------------------------------ footing (low + flat)
		round(cf(0, 0.06, 0, 0, 10, 0), 5.8, 0.12, GR_DK)
		round(cf(0.2, 0.12, 0.1, 0, 35, 0), 4.4, 0.12, GR)
		for _, m in { { -3.6, -2.6, 2.4, 1.6, 20, GR_LT }, { 3.2, 2.8, 2.6, 1.6, -25, GR_LT }, { 3.4, -3.0, 1.8, 1.4, 40, GR_XL }, { -3.0, 3.4, 2.0, 1.4, -10, GR_XL } } do
			B:block(R, v(m[3], 0.16, m[4]), cf(m[1], 0.17, m[2], 0, m[5], 0), m[6])
		end
		B:block(R, v(1.6, 0.14, 1.0), cf(-4.4, 0.13, 1.4, 0, 30, 0), SOIL)
		local function pebble(x, z, s, ry)
			B:block(R, v(1.2 * s, 0.5 * s, 0.9 * s), cf(x, 0.25 * s, z, 0, ry, 0), PEB)
			B:block(R, v(0.7 * s, 0.25 * s, 0.5 * s), cf(x + 0.1, 0.55 * s, z, 0, ry + 20, 0), PEB_LT)
		end
		pebble(4.6, 0.6, 1.0, 20)
		pebble(-1.4, -5.0, 0.8, -30)
		local function daisy(x, z, h, col)
			B:bar(R, v(x, 0.15, z), v(x + 0.1, h, z), 0.2, 0.2, CLOVER)
			B:block(R, v(0.9, 0.2, 0.36), cf(x + 0.1, h, z, 0, 20, 0), col)
			B:block(R, v(0.36, 0.22, 0.9), cf(x + 0.1, h, z, 0, 20, 0), col)
			B:block(R, v(0.32, 0.26, 0.32), cf(x + 0.1, h + 0.06, z, 0, 20, 0), DAISY_EYE)
		end
		daisy(-4.2, -1.2, 0.9, DAISY)
		daisy(-3.6, -1.9, 0.6, DAISY)
		daisy(2.4, -4.4, 0.8, DAISY)
		daisy(4.2, 2.2, 0.7, FL_PINK)
		daisy(-1.8, 4.4, 0.9, DAISY)
		local function clover(x, z)
			for k = 0, 2 do
				B:block(R, v(0.6, 0.18, 0.6), cf(x + math.sin(rad(k * 120)) * 0.35, 0.3, z - math.cos(rad(k * 120)) * 0.35, 0, k * 120 + 45, 0), (k == 0) and CLOVER_DK or CLOVER)
			end
		end
		-- fallen blossom petals on the grass
		for i, pt in { { -2.6, -2.2 }, { 1.4, -2.8 }, { 3.0, -0.6 }, { -1.0, 3.0 }, { 2.4, 2.6 }, { -3.4, 0.8 }, { 0.4, -4.4 } } do
			B:block(R, v(0.6, 0.12, 0.6), cf(pt[1], 0.3, pt[2], 0, i * 37, 0), (i % 2 == 0) and "#ffa9c9" or "#ffd23a")
		end
		clover(1.6, -3.6)
		clover(-4.6, 2.6)
		clover(3.0, 4.2)

		------------------------------------------------------------ trunk
		oct(cf(0, 0.55, 0, 0, 15, 0), 3.4, 1.1, BARK_DK, BARK)
		for i, a in { 30, 110, 190, 270, 340 } do
			local d = dirOf(a)
			B:bar(R, d * 0.8 + v(0, 2.2, 0), d * (2.7 + rnd(0, 0.5)) + v(0, 0.3, 0), 0.9, 1.0, (i % 2 == 0) and BARK or BARK_DK)
		end
		local path = { v(0, 0.8, 0), v(0.2, 4.0, 0.1), v(-0.1, 7.2, 0) }
		local widths = { 2.4, 2.0 }
		for i = 1, 2 do
			local a, b = path[i], path[i + 1]
			local w = widths[i]
			B:bar(R, a - v(0, 0.2, 0), b + v(0, 0.2, 0), w, w, (i == 1) and BARK or BARK_DK)
			B:bar(R, a - v(0, 0.15, 0), b + v(0, 0.15, 0), w * 0.86, w * 0.86, (i == 1) and BARK_DK or BARK, { up = v(1, 0, 1).Unit })
		end
		for _, r in { { 2.0, 25 }, { 3.2, 200 }, { 5.2, 120 }, { 6.0, 300 } } do
			local p = v(0, r[1], 0) + dirOf(r[2]) * 1.05
			B:bar(R, p - v(0, 0.8, 0), p + v(0, 0.8, 0), 0.4, 0.3, BARK_LT, { up = dirOf(r[2]) })
		end
		-- forked branches into the canopy
		local fork = path[3]
		local branchTips = {}
		for i, b in { { 40, 3.4, 3.0 }, { 160, 3.0, 3.4 }, { 280, 3.2, 2.8 }, { 100, 1.6, 4.4 } } do
			local tip = fork + dirOf(b[1]) * b[2] + v(0, b[3], 0)
			B:bar(R, fork - v(0, 0.3, 0), tip, 1.0, 1.0, (i % 2 == 0) and BARK or BARK_DK)
			branchTips[i] = tip
		end

		------------------------------------------------------------ canopy
		local Cc = v(0.2, 11.0, 0)
		local function jit(k) return rnd(-k, k) end
		local function pv(r, deg, y) return Cc + dirOf(deg) * r + v(0, y, 0) end
		-- leafy core (fills the gaps; green leaves peek out underneath)
		B:block(R, v(7.2, 4.6, 7.2), CFrame.new(Cc + v(0, -0.2, 0)) * ang(6, 20, -5), LF_DK)
		B:block(R, v(6.4, 4.4, 6.4), CFrame.new(Cc + v(0, 2.0, 0)) * ang(-5, 55, 8), GOLD[2])
		for k = 0, 3 do
			local deg = k * 90 + 45
			B:block(R, v(2.6, 2.6, 2.6), CFrame.new(pv(3.0, deg, -2.6)) * ang(jit(15), rnd(0, 90), jit(15)), (k % 2 == 0) and LF or LF_MID)
		end
		local rings = {
			-- y, r, n, size, yaw, palettes, tone index
			{ -0.9, 3.9, 7, 3.9, 10, 1 },
			{ 1.6, 3.5, 7, 3.8, 35, 2 },
			{ 3.7, 2.2, 5, 3.3, 5, 3 },
		}
		local cubes = {}
		for ri, r in rings do
			for i = 0, r[3] - 1 do
				local deg = i * 360 / r[3] + r[5] + jit(6)
				local p = pv(r[2] + jit(0.25), deg, r[1] + jit(0.3))
				local pal = ((i + ri) % 2 == 0) and GOLD or PINK
				local tone = r[6]
				if ri == 1 and i % 3 == 0 then tone = 2 end
				B:block(R, v(r[4], r[4], r[4]), CFrame.new(p) * ang(jit(16), rnd(0, 90), jit(16)), pal[tone])
				table.insert(cubes, { p = p, s = r[4], deg = deg, ring = ri, pal = pal })
			end
		end
		-- crown
		B:block(R, v(3.0, 2.6, 3.0), CFrame.new(Cc + v(0.2, 5.4, 0.1)) * ang(8, 30, -6), PINK[3])
		B:block(R, v(2.0, 2.0, 2.0), CFrame.new(Cc + v(-0.8, 6.2, -0.4)) * ang(-10, 10, 12), GOLD[3])
		-- little flowers dotted over the clusters (pink on gold, white on pink)
		for i, c in cubes do
			if i % 2 == 0 or c.ring == 3 then
				local a = rad(c.deg + 12)
				local bp = c.p + v(math.sin(a), 0, -math.cos(a)) * (c.s * 0.56) + v(0, c.s * 0.3, 0)
				local F = CFrame.new(bp) * CFrame.Angles(0, -a, 0) * ang(-55, 0, 0)
				local petal = (c.pal == GOLD) and FL_PINK or FL_WHITE
				B:block(R, v(1.8, 0.35, 0.7), F, petal)
				B:block(R, v(0.7, 0.36, 1.8), F, petal)
				B:block(R, v(0.6, 0.45, 0.6), F * CFrame.new(0, 0.08, 0), DAISY_EYE)
			end
		end

		------------------------------------------------------------ hanging honeycomb
		local hb = fork + dirOf(-35) * 4.6 + v(0, 1.4, 0)
		B:bar(R, fork + v(0, 0.6, 0), hb + v(0, 0.3, 0), 0.6, 0.6, BARK)
		local hc = hb + v(0, -1.6, 0)
		B:block(R, v(0.3, 1.2, 0.3), CFrame.new(hb + v(0, -0.5, 0)), BARK_DK)
		local Hc = CFrame.new(hc) * ang(0, 15, 0)
		oct(Hc * CFrame.new(0, 0.1, 0), 1.6, 0.6, WAX_DK, WAX)
		oct(Hc * CFrame.new(0, -0.6, 0), 2.1, 0.9, WAX, WAX_LT)
		oct(Hc * CFrame.new(0, -1.4, 0), 1.7, 0.7, WAX_DK, WAX)
		B:block(R, v(0.9, 0.4, 0.9), Hc * CFrame.new(0, -1.9, 0) * ang(0, 45, 0), WAX_DK)
		for k, a in { 0, 90, 180, 270 } do
			local q = Hc * ang(0, a, 0) * CFrame.new((k % 2 == 0) and 0.3 or -0.3, -0.6, -1.08)
			B:block(R, v(0.45, 0.45, 0.12), q, (k % 2 == 0) and CELL or CELL_DK)
		end
		B:block(R, v(0.32, 0.9, 0.32), Hc * CFrame.new(0.3, -2.4, -0.2), HONEY)
		B:block(R, v(0.42, 0.4, 0.42), Hc * CFrame.new(0.3, -3.0, -0.2), HONEY_LT)
	end,
}
