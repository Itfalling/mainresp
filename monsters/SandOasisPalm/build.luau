--!nocheck
-- Oasis Gold Palm (Sandy Savanna crop #9, Divine): a tall date palm leaning
-- over a tiny shimmering oasis pool.
-- * a stepped golden SAND mound (bone "Soil", parts "Soil") with chunky edge
--   blocks, layered sandstone rocks, dry grass tufts, pebbles, shells, little
--   cactus sprouts, sand ripples and a few fallen golden dates
-- * the OASIS: a turquoise pool sunk into the front-left of the mound with
--   shimmer strips, a lily pad + pink flower, papyrus reeds and rim stones
-- * a segmented, gently curving palm trunk (bone "Crop") with diamond ring
--   bands and a root flare; a fibrous crown knob
-- * a big crown of chunky studded fronds (gold midribs, green leaflets that
--   droop on both sides, lime tips) + two young upright spears
-- * five golden glowing date clusters hanging under the crown
-- * pool shimmer, golden motes, a soft date glow and one warm light
-- Static crop: no motion.luau. Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Oasis Gold Palm",
	Rarity = "Divine",
	Element = "Nature",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ------------------------------------------------------------
		local SAND_DK, SAND, SAND_LT, SAND_HI = "#c48a45", "#d9a95c", "#e8c27a", "#f3d79a"
		local SAND_DK2 = "#b77c3b"
		local ROCK_DK, ROCK, ROCK_LT = "#a9573a", "#c9774a", "#e0a06a"
		local GRASS_DRY, GRASS_DRY2 = "#d9c25c", "#b49a3c"
		local PEB, PEB_LT = "#9a8a72", "#efe4cf"
		local CACT, CACT_DK = "#5da047", "#3f7d35"
		local SHELL, SHELL_PK = "#fff1df", "#f6b9ad"
		local WATER_DK, WATER, WATER_LT, SHIMMER = "#1f93b8", "#33bfd6", "#7fe1ea", "#d8fdff"
		local PAD, FLOWER, FLOWER_LT = "#4caf50", "#ff86b4", "#ffd2e4"
		local REED, REED_TOP = "#6aa83a", "#94cc4e"
		local TRUNK, TRUNK_DK, TRUNK_LT, RING = "#9c6a3c", "#80542e", "#b88352", "#c99a62"
		local FIBER = "#7a5a30"
		local FR_DK, FR, FR_MID, FR_LT, FR_LIME = "#2f7d33", "#3f9a3a", "#52b043", "#72c44a", "#a8d84e"
		local MIDRIB, MIDRIB_LT = "#d8a93a", "#f0c95a"
		local STALK = "#e08a2a"
		local DATE, DATE_DK, DATE_LT, DATE_GLOW = "#f5be34", "#e0901c", "#ffdc72", "#ffe48a"

		local seed = 909190
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
		local function outward(deg)
			local x, z = polar(1, deg)
			return v(x, 0, z)
		end
		local UP = v(0, 1, 0)

		------------------------------------------------------------------
		-- STEPPED SAND MOUND (bone "Soil", every part named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(y0, y1, w, color)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(soil, v(w, h, w * 0.62), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.62, h + 0.02, w), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.85, h - 0.03, w * 0.85), cf(0, y, 0), color, S)
		end
		oct(0, 1.1, 17.0, SAND_DK)
		oct(1.1, 2.1, 12.8, SAND)
		oct(2.1, 2.8, 8.4, SAND_LT)
		local POOL_DEG = 326
		local function nearPool(a, lo, hi)
			local d = (a - POOL_DEG + 540) % 360 - 180
			return d > lo and d < hi
		end
		for i = 0, 15 do
			local a = i * 22.5 + jit(5)
			local x, z = polar(8.2 + jit(0.3), a)
			local h = 0.9 + rnd() * 0.7
			B:block(soil, v(2.6 + rnd() * 0.8, h, 1.9 + rnd() * 0.5), cf(x, h / 2, z, 0, -a + jit(10), 0),
				i % 3 == 0 and SAND or (i % 2 == 0 and SAND_DK2 or SAND_DK), S)
		end
		for i = 0, 8 do
			local a = i * 40 + 10 + jit(8)
			if not nearPool(a, -40, 40) then
				local x, z = polar(6.1 + jit(0.3), a)
				local h = 0.7 + rnd() * 0.4
				B:block(soil, v(2.1 + rnd() * 0.5, h, 1.6), cf(x, 1.1 + h / 2, z, 0, -a + jit(12), 0), i % 2 == 0 and SAND or SAND_LT, S)
			end
		end
		-- wind ripples (pale strips) on the tiers
		for _, r in { { 100, 7.2, 1.1 }, { 160, 7.4, 1.1 }, { 220, 7.2, 1.1 }, { 60, 5.2, 2.1 }, { 190, 5.0, 2.1 }, { 140, 3.0, 2.8 }, { 230, 3.2, 2.8 } } do
			local x, z = polar(r[2], r[1])
			B:block(soil, v(1.9, 0.12, 0.35), cf(x, r[3] + 0.05, z, 0, -r[1] + 90 + jit(15), 0), SAND_HI, S)
		end

		-- layered sandstone rocks
		local function rock(x, y, z, s, yaw)
			B:block(soil, v(1.5 * s, 0.7 * s, 1.2 * s), cf(x, y + 0.35 * s, z, 0, yaw, 0), ROCK, S)
			B:block(soil, v(1.15 * s, 0.5 * s, 0.95 * s), cf(x + 0.1 * s, y + 0.92 * s, z, 0, yaw + 12, 0), ROCK_LT, S)
			B:block(soil, v(1.55 * s, 0.18 * s, 1.25 * s), cf(x, y + 0.6 * s, z, 0, yaw, 0), ROCK_DK, S)
		end
		rock(6.8, 1.0, 2.6, 1.15, 20)
		rock(-6.6, 1.0, 3.8, 0.95, -30)
		rock(2.6, 2.0, -4.6, 0.75, 40)
		rock(-1.0, 1.0, 7.4, 1.0, 10)

		-- dry grass tufts (thin blades fanning out)
		for _, g in { { 8.4, 1.1, -2.6, 0 }, { 4.4, 1.1, -6.8, 0 }, { -8.2, 1.1, -0.6, 0 }, { 5.6, 2.1, 3.6, 1 }, { -4.0, 2.1, 3.8, 1 }, { 7.2, 1.1, 5.2, 0 }, { -3.6, 1.1, 7.6, 0 } } do
			local yaw = rnd() * 90
			for k = -1, 1 do
				local h = (k == 0) and 1.3 or 0.95
				local c = CFrame.new(g[1], g[2], g[3]) * ang(0, yaw, 0) * ang(0, 0, k * 24) * CFrame.new(0, h / 2, 0)
				B:block(soil, v(0.2, h, 0.3), c, (k == 0) and GRASS_DRY or GRASS_DRY2, S)
			end
		end
		-- pebbles
		for _, p in { { 3.8, 2.8, 2.6 }, { -2.8, 2.8, 2.0 }, { 7.6, 1.1, -4.8 }, { -7.4, 1.1, -3.6 }, { 0.6, 1.1, -7.8 }, { -5.6, 2.1, 1.4 } } do
			B:block(soil, v(0.5, 0.32, 0.45), cf(p[1], p[2] + 0.14, p[3], 0, rnd() * 90, 0), rnd() > 0.5 and PEB or PEB_LT, S)
		end
		-- shells (cream fan + pink stripes)
		for _, s in { { 4.8, 1.1, -5.6, 30 }, { -6.0, 2.1, -0.6, -20 }, { 2.4, 2.8, 3.2, 60 } } do
			local c = CFrame.new(s[1], s[2] + 0.12, s[3]) * ang(0, s[4], 0)
			B:block(soil, v(0.75, 0.22, 0.6), c, SHELL, S)
			B:block(soil, v(0.14, 0.26, 0.62), c * CFrame.new(-0.18, 0.01, 0), SHELL_PK, S)
			B:block(soil, v(0.14, 0.26, 0.62), c * CFrame.new(0.18, 0.01, 0), SHELL_PK, S)
		end
		-- little cactus sprouts
		local function sprout(x, y, z, s, flower)
			B:block(soil, v(0.6 * s, 1.5 * s, 0.6 * s), cf(x, y + 0.75 * s, z), CACT, S)
			B:block(soil, v(0.8 * s, 0.3 * s, 0.35 * s), cf(x + 0.45 * s, y + 0.75 * s, z), CACT_DK, S)
			B:block(soil, v(0.35 * s, 0.6 * s, 0.35 * s), cf(x + 0.72 * s, y + 1.1 * s, z), CACT, S)
			if flower then
				B:block(soil, v(0.4 * s, 0.25 * s, 0.4 * s), cf(x, y + 1.6 * s, z, 0, 45, 0), FLOWER, S)
			end
		end
		sprout(7.4, 1.1, -1.0, 1.0, true)
		sprout(-5.2, 2.1, -3.2, 0.8, false)
		-- a round barrel cactus at the back left
		B:block(soil, v(1.2, 1.1, 1.2), cf(-4.6, 2.65, 4.4), CACT, S)
		B:block(soil, v(0.9, 1.25, 0.9), cf(-4.6, 2.7, 4.4, 0, 45, 0), CACT_DK, S)
		B:block(soil, v(0.5, 0.3, 0.5), cf(-4.6, 3.35, 4.4, 0, 20, 0), FLOWER, S)
		-- fallen golden dates on the sand
		for _, d in { { 1.6, 2.8, -2.6 }, { 2.3, 2.8, -2.0 }, { -6.9, 1.1, 1.6 } } do
			B:block(soil, v(0.6, 0.5, 0.75), cf(d[1], d[2] + 0.25, d[3], 0, rnd() * 90, 0), DATE, S)
		end

		------------------------------------------------------------------
		-- THE OASIS POOL (front-left of the middle tier)
		------------------------------------------------------------------
		local px, pz = polar(5.2, POOL_DEG)
		local PC = CFrame.new(px, 2.1, pz) * CFrame.Angles(0, -rad(POOL_DEG), 0)
		local function pc(x, y, z, ry)
			return PC * CFrame.new(x, y, z) * ang(0, ry or 0, 0)
		end
		-- sand basin under the water (fills the gap over the lower tier)
		B:block(soil, v(6.8, 1.5, 4.8), pc(0, -0.75, -0.2), SAND, S)
		B:block(soil, v(5.8, 0.3, 4.0), pc(0, 0.02, 0), WATER_DK, S)
		B:block(soil, v(4.4, 0.32, 4.6), pc(0, 0.04, 0), WATER, S)
		B:block(soil, v(6.2, 0.3, 3.0), pc(0, 0.05, 0), WATER, S)
		B:block(soil, v(1.6, 0.06, 0.3), pc(0.9, 0.22, -0.8), WATER_LT, S)
		B:block(soil, v(1.1, 0.06, 0.25), pc(-1.6, 0.22, 0.9), WATER_LT, S)
		B:block(soil, v(1.0, 0.06, 0.18), pc(-0.2, 0.23, -1.3), SHIMMER, { name = "Soil", mat = "Neon" })
		B:block(soil, v(0.7, 0.06, 0.16), pc(1.5, 0.23, 0.5), SHIMMER, { name = "Soil", mat = "Neon" })
		-- rim: sand lips + sandstone stones around the outer edge
		B:block(soil, v(7.0, 0.55, 0.9), pc(0, 0.05, -2.55, 3), SAND_LT, S)
		B:block(soil, v(0.9, 0.5, 4.2), pc(-3.35, 0.05, 0.0, -4), SAND_LT, S)
		B:block(soil, v(0.9, 0.5, 4.0), pc(3.35, 0.05, -0.1, 5), SAND_LT, S)
		for _, r in { { -3.0, -2.4, 0.8, 20, ROCK }, { 3.1, -2.2, 0.65, -15, ROCK_LT }, { 3.5, 1.4, 0.75, 30, ROCK }, { -3.5, 1.6, 0.6, 10, ROCK_LT }, { 0.8, -2.9, 0.55, 40, ROCK_DK } } do
			B:block(soil, v(r[3] * 1.3, r[3], r[3] * 1.1), pc(r[1], 0.3 + r[3] * 0.3, r[2], r[4]), r[5], S)
		end
		-- lily pad + pink flower
		B:block(soil, v(1.2, 0.12, 1.2), pc(-1.0, 0.25, -0.5, 25), PAD, S)
		B:block(soil, v(0.5, 0.35, 0.5), pc(-1.0, 0.45, -0.5, 45), FLOWER, S)
		B:block(soil, v(0.25, 0.2, 0.25), pc(-1.0, 0.68, -0.5), FLOWER_LT, S)
		B:block(soil, v(0.8, 0.12, 0.8), pc(1.3, 0.25, 0.9, -15), PAD, S)
		-- papyrus reeds at the back corner of the pool
		for _, r in { { -2.8, 1.9, 2.6, 6 }, { -2.2, 2.2, 3.2, -5 }, { -3.2, 1.2, 2.0, 12 } } do
			local base = pc(r[1], 0.2, r[2])
			B:block(soil, v(0.22, r[3], 0.22), base * ang(0, 0, r[4]) * CFrame.new(0, r[3] / 2, 0), REED, S)
			local top = base * ang(0, 0, r[4]) * CFrame.new(0, r[3], 0)
			B:block(soil, v(0.9, 0.18, 0.5), top * ang(0, 30, 25), REED_TOP, S)
			B:block(soil, v(0.9, 0.18, 0.5), top * ang(0, -40, -25), REED_TOP, S)
		end
		-- a baby palm sapling at the back left
		do
			local bx, bz = polar(4.9, 215)
			local b0 = v(bx, 2.1, bz)
			B:block(soil, v(1.3, 0.5, 1.3), CFrame.new(b0 + v(0, 0.25, 0)) * ang(0, 20, 0), TRUNK_DK, S)
			local tp = b0 + v(0.3, 3.0, 0.2)
			B:bar(soil, b0 + v(0, 0.3, 0), tp, 0.8, 0.8, TRUNK, S)
			B:block(soil, v(1.1, 0.35, 1.1), CFrame.new(b0:Lerp(tp, 0.35)) * ang(0, 45, 0), RING, S)
			B:block(soil, v(1.0, 0.35, 1.0), CFrame.new(b0:Lerp(tp, 0.7)) * ang(0, 10, 0), RING, S)
			for k = 0, 4 do
				local o = outward(k * 72 + 15)
				local m = tp + o * 1.2 + v(0, 0.35, 0)
				local e = tp + o * 2.3 + v(0, -0.5, 0)
				B:bar(soil, tp, m, 0.8, 0.3, (k % 2 == 0) and FR or FR_MID, S)
				B:bar(soil, m, e, 0.65, 0.28, (k % 2 == 0) and FR_LT or FR_LIME, S)
			end
			B:block(soil, v(0.6, 0.6, 0.6), CFrame.new(tp + v(0, 0.3, 0)) * ang(0, 30, 0), FR_DK, S)
		end
		-- reeds on the right side of the pool
		for _, r in { { 2.9, 1.6, 1.8, -8 }, { 3.3, 1.0, 1.3, 10 } } do
			local base = pc(r[1], 0.2, r[2])
			B:block(soil, v(0.2, r[3], 0.2), base * ang(0, 0, r[4]) * CFrame.new(0, r[3] / 2, 0), REED, S)
			B:block(soil, v(0.32, 0.6, 0.32), base * ang(0, 0, r[4]) * CFrame.new(0, r[3] + 0.1, 0), "#6b4a2a", S)
		end
		local shimmerZone = B:block(soil, v(5.4, 0.4, 3.6), pc(0, 0.5, 0), WATER, { tr = 1, name = "PoolShimmerZone" })
		B:emitter(shimmerZone, "sparkle", { name = "PoolShimmer", color = { SHIMMER, "#9ff3ff", "#ffffff" }, rate = 6, size = { 0.12, 0.4, 0 }, life = { 0.6, 1.3 }, speed = { 0.05, 0.3 } })

		------------------------------------------------------------------
		-- CURVED PALM TRUNK (bone "Crop")
		------------------------------------------------------------------
		local BASE = 2.8
		local crop = B:bone("Crop", "Root", v(0, BASE, 0))
		local TB = v(1.3, BASE, 1.6)
		local TOP = v(-0.3, 18.5, 0.1)
		local function trunkAt(t)
			-- leans toward the pool at the bottom, then straightens up
			local bend = math.sin(t * math.pi / 2)
			return v(TB.X + (TOP.X - TB.X) * bend, TB.Y + (TOP.Y - TB.Y) * t, TB.Z + (TOP.Z - TB.Z) * bend)
		end
		-- root flare
		B:block(crop, v(3.6, 0.9, 3.6), CFrame.new(TB + v(0, 0.35, 0)) * ang(0, 15, 0), TRUNK_DK)
		B:block(crop, v(3.0, 0.8, 3.0), CFrame.new(TB + v(0, 1.0, 0)) * ang(0, -20, 0), TRUNK)
		for k = 0, 4 do
			local a = k * 72 + 20
			local o = outward(a)
			B:bar(crop, TB + o * 1.2 + v(0, 0.7, 0), TB + o * 2.4 + v(0, -0.15, 0), 0.8, 0.6, (k % 2 == 0) and TRUNK_DK or FIBER)
		end
		local NSEG = 9
		local prev = trunkAt(0)
		for i = 1, NSEG do
			local t = i / NSEG
			local p = trunkAt(t)
			local w = 2.5 - 0.45 * t
			local dir = (p - prev).Unit
			B:bar(crop, prev - dir * 0.05, p + dir * 0.05, w, w, (i % 2 == 0) and TRUNK or TRUNK_DK)
			-- diamond ring band at each joint
			local c = P.aim(prev, p)
			local jc = CFrame.new(p) * (c - c.Position) * ang(0, 0, 45 + (i % 2) * 10)
			B:block(crop, v(w + 0.35, w + 0.35, 0.55), jc, (i % 3 == 0) and TRUNK_LT or RING)
			prev = p
		end
		-- fibrous crown knob
		B:block(crop, v(2.6, 1.4, 2.6), CFrame.new(TOP + v(0, 0.4, 0)) * ang(0, 20, 0), FIBER)
		B:block(crop, v(2.2, 1.2, 2.2), CFrame.new(TOP + v(0, 1.2, 0)) * ang(0, -15, 0), FR_DK)
		B:block(crop, v(1.6, 1.0, 1.6), CFrame.new(TOP + v(0, 1.9, 0)) * ang(0, 35, 0), FR)

		------------------------------------------------------------------
		-- FRONDS: chunky plate midrib segments with drooping leaflets
		------------------------------------------------------------------
		local CR = TOP + v(0, 1.3, 0)
		local function frond(deg, rs, hs, wid, cols, gold)
			local o = outward(deg)
			local pts = {}
			for k = 1, #rs do
				pts[k] = CR + o * rs[k] + v(0, hs[k], 0)
			end
			for k = 1, #pts - 1 do
				local a, b = pts[k], pts[k + 1]
				local d = (b - a).Unit
				local L = (b - a).Magnitude
				local w = wid * (1 - 0.18 * (k - 1))
				B:bar(crop, a - d * 0.15, b + d * 0.15, w, 0.45, gold and MIDRIB or ((k % 2 == 0) and cols[1] or cols[2]))
				if k > 1 then
					local side = d:Cross(UP).Unit
					local mid = a:Lerp(b, 0.5)
					local reach = 1.9 - 0.25 * (k - 2)
					for _, sd in { -1, 1 } do
						local s0 = mid + side * sd * (w * 0.35) + v(0, -0.1, 0)
						local s1 = mid + side * sd * (w * 0.35 + reach) + v(0, -0.85 - 0.1 * k, 0) + d * 0.3
						B:bar(crop, s0, s1, 0.32, L * 0.95, (k == #pts - 1) and FR_LIME or ((sd > 0) and cols[3] or cols[4]), { up = d })
					end
				end
			end
			-- lime / gold tip
			local tip = pts[#pts]
			local d = (tip - pts[#pts - 1]).Unit
			B:bar(crop, tip - d * 0.1, tip + d * 1.0, wid * 0.4, 0.4, gold and MIDRIB_LT or FR_LIME)
			return pts
		end
		-- lower ring: long fronds arching out and drooping
		local lower = { 15, 85, 155, 225, 295 }
		for i, a in lower do
			local gold = (i % 2 == 1)
			frond(a + jit(6), { 0.6, 3.0, 5.4, 7.4, 8.7 }, { 0.3, 1.4, 1.0, -0.6, -2.6 }, 1.9,
				gold and { FR, FR_DK, FR_MID, FR_LT } or { FR_DK, FR, FR_LT, FR_MID }, gold)
		end
		-- upper ring: shorter fronds reaching up and out
		local upper = { 50, 130, 200, 270, 340 }
		for i, a in upper do
			frond(a + jit(6), { 0.3, 2.2, 4.1, 5.8, 6.9 }, { 0.8, 2.4, 3.1, 2.6, 1.4 }, 1.7,
				{ FR, FR_MID, FR_LT, FR_MID }, i % 2 == 0)
		end
		-- two young upright spears in the middle
		for _, s in { { 100, 0.6, 3.0 }, { 290, 0.7, 2.6 } } do
			local o = outward(s[1])
			local a = CR + v(0, 0.6, 0)
			local b = CR + o * s[2] + v(0, s[3], 0)
			B:bar(crop, a, b, 0.9, 0.5, FR_MID)
			B:bar(crop, b - (b - a).Unit * 0.1, b + (b - a).Unit * 0.8, 0.5, 0.35, FR_LIME)
		end

		------------------------------------------------------------------
		-- GOLDEN DATE CLUSTERS hanging under the crown
		------------------------------------------------------------------
		local glowParts = {}
		local function cluster(deg, drop, n)
			local o = outward(deg)
			local side = o:Cross(UP)
			local a = TOP + o * 0.9 + v(0, 0.4, 0)
			local b = TOP + o * 2.6 + v(0, -0.9, 0)
			local c = b + o * 0.5 + v(0, -drop, 0)
			B:bar(crop, a, b, 0.4, 0.4, STALK)
			B:bar(crop, b, c + v(0, 0.4, 0), 0.32, 0.32, STALK)
			-- rows: wide at the top, narrowing to a point
			local rows = {
				{ y = 0.0, r = 0.95, k = 6 },
				{ y = -0.9, r = 0.9, k = 5 },
				{ y = -1.75, r = 0.62, k = 4 },
				{ y = -2.5, r = 0.0, k = 1 },
			}
			local idx = 0
			for ri, row in rows do
				for j = 0, row.k - 1 do
					idx += 1
					local ang0 = j * 360 / row.k + ri * 30 + deg
					local ox, oz = polar(row.r, ang0)
					local p = c + v(ox, row.y, oz)
					local glow = (idx == 2 or idx == 9 or idx == 14) and n ~= nil
					local col = glow and DATE_GLOW or ((idx % 3 == 0) and DATE_DK or ((idx % 3 == 1) and DATE or DATE_LT))
					local part = B:block(crop, v(0.78, 0.95, 0.78), CFrame.new(p) * ang(jit(10), rnd() * 90, jit(10)), col,
						glow and { mat = "Neon", name = "DateGlow" } or nil)
					if glow then
						table.insert(glowParts, part)
					end
				end
			end
			-- little stalk cap over the bunch
			B:block(crop, v(1.5, 0.35, 1.5), CFrame.new(c + v(0, 0.6, 0)) * ang(0, 45, 0), STALK)
			return c
		end
		local cl = {}
		for i, d in { { 40, 1.2 }, { 130, 1.6 }, { 220, 1.3 }, { 310, 1.7 } } do
			cl[i] = cluster(d[1], d[2], i)
		end

		------------------------------------------------------------------
		-- VFX: golden motes around the crown, a soft date glow, one light
		------------------------------------------------------------------
		local moteZone = B:block(crop, v(15, 6, 15), CFrame.new(TOP + v(0, 0.5, 0)), DATE, { tr = 1, name = "MoteZone" })
		B:emitter(moteZone, "sparkle", { name = "GoldMotes", color = { DATE_GLOW, "#fff3b0", DATE }, rate = 6, size = { 0.12, 0.45, 0 }, life = { 1.4, 2.6 }, speed = { 0.15, 0.5 } })
		local glowZone = B:block(crop, v(6, 1.5, 6), CFrame.new(TOP + v(0, -2.2, 0)), DATE, { tr = 1, name = "DateGlowZone" })
		B:emitter(glowZone, "glow", { name = "DateGlowFx", color = { DATE_GLOW, "#ffcf5a" }, rate = 2.2, size = { 1.4, 2.4, 0.6 } })
		local leafZone = B:block(crop, v(12, 1, 12), CFrame.new(TOP + v(0, 1.0, 0)), FR, { tr = 1, name = "LeafZone" })
		B:emitter(leafZone, "leaf", { name = "GoldFlecks", color = { MIDRIB_LT, FR_LIME, DATE }, rate = 0.8, size = { 0.35, 0.35, 0.2 }, life = { 3, 5 }, speed = { 0.2, 0.6 }, accel = { 0.3, -1.1, 0 }, dir = "Bottom" })
		B:light(glowZone, { name = "DateLight", color = "#ffcc66", brightness = 1.2, range = 16 })
	end,
}
