--!nocheck
-- Queen's Honeytree (Honey Hills crop #10, Apex): the showpiece of the hills.
-- A colossal honey tree in the stud-tree style:
-- * a big stepped grassy meadow mound (bone "Soil", parts "Soil"): brown soil
--   tiers with fresh grass caps, chunky edge blocks, pastel wildflowers,
--   clover, pebbles, fallen comb chunks, a little straw skep and TWO honey
--   pools where the honey falls land
-- * a chunky honey-brown trunk (bone "Crop") with root flares, honey-glazed
--   streaks and limbs fanning into the canopy
-- * a three-tier COMB CANOPY (bones Canopy1 -> Canopy2 -> Canopy3): stepped
--   golden honeycomb cores ringed by big rotated leaf cubes and comb blocks
--   whose faces show stepped cells, pastel blossoms on top
-- * four wild comb sheets (CombN) and six glowing honey-drop fruits (FruitN)
--   hang under the canopy and swing on their own bones
-- * two HONEY FALLS (static bone "Falls") pour from the canopy rim into the
--   pools: stacked honey segments FallNSegK that ripple (flow animation) with
--   a hidden neon core FallCoreN that lights up on the burst
-- * the giant CROWN HIVE (bone "Hive"): a striped straw skep with a glowing
--   entrance, wearing a golden queen's CROWN (bone "Crown") with neon gems
-- * a SWARM of eight block bees on orbit bones (BeeOrbitN -> BeeN ->
--   BeeNWingR/L) circling the hive and canopy, each with a golden trail
-- * VFX: hive burst + flung honey drops (signature beat), honey splashes at
--   both pools, canopy honey drips, pollen sparkles, drifting pink blossom
--   petals; gold hive light, warm canopy light, honey pool light
-- Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Queen's Honeytree",
	Rarity = "Apex",
	Element = "Honey",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ------------------------------------------------------------
		local SOIL_DK, SOIL, SOIL_LT = "#7a4a28", "#966034", "#b07a46"
		local GRASS_DK, GRASS, GRASS_LT = "#6db53c", "#8bcb4a", "#aade5e"
		local PEB, PEB_LT = "#a39a8c", "#d6cfc2"
		local FL_PINK, FL_LAV, FL_WHITE, FL_EYE = "#ff9ccf", "#c4a0f2", "#fff6ea", "#ffd23f"
		local CLOVER, CLOVER_LT = "#4fae3e", "#6fcf4c"
		local BARK_DK, BARK, BARK_LT, BARK_HI = "#6b3f1f", "#8a5428", "#a86c34", "#c48848"
		local LF_DK, LF, LF_MID, LF_LT, LF_LIME = "#3f9a2c", "#55b23a", "#6cc444", "#8fd64e", "#b5e05a"
		local LF_GOLD, LF_GOLD2 = "#cfdc4e", "#e6d24a"
		local COMB_DK, COMB_BASE, COMB, COMB_LT, COMB_CAP = "#7c3f0c", "#a55a12", "#eea21a", "#ffc93a", "#ffe7a0"
		local HONEY_DK, HONEY, HONEY_LT, HONEY_GLOW = "#c7740c", "#f0a215", "#ffc23a", "#ffd95a"
		local HIVE_GR, HIVE_DK, HIVE, HIVE_LT = "#94561a", "#d4922e", "#f2b648", "#ffd66e"
		local GOLD_DK, GOLD, GOLD_LT = "#f0b020", "#ffd23a", "#ffea8a"
		local GEM_PINK, GEM_LAV = "#ff6fb5", "#b98cff"
		local BLOS, BLOS_LT, BLOS_LAV = "#ff9fcf", "#ffd0e6", "#cfa8ff"
		local BEE_Y, BEE_K, WING = "#ffd23a", "#2b2222", "#ffffff"

		local seed = 1700170
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
		-- CFrame at p whose local -Z faces outward along polar deg
		local function facing(p, deg)
			return CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
		end

		------------------------------------------------------------------
		-- MEADOW MOUND (bone "Soil", every part named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(bone, y0, y1, w, color, opts)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(bone, v(w, h, w * 0.62), cf(0, y, 0), color, opts)
			B:block(bone, v(w * 0.62, h + 0.02, w), cf(0, y, 0), color, opts)
			B:block(bone, v(w * 0.85, h - 0.03, w * 0.85), cf(0, y, 0), color, opts)
		end
		oct(soil, 0, 1.0, 22.0, SOIL_DK, S)
		oct(soil, 1.0, 1.3, 21.5, GRASS_DK, S)
		oct(soil, 1.3, 2.05, 16.8, SOIL, S)
		oct(soil, 2.05, 2.3, 16.3, GRASS, S)
		oct(soil, 2.3, 2.95, 11.6, SOIL_LT, S)
		oct(soil, 2.95, 3.2, 11.1, GRASS_LT, S)
		local Y1, Y2, Y3 = 1.3, 2.3, 3.2
		-- chunky edge blocks (soil with a grass top)
		local POOLS = { { deg = 35, r = 9.0 }, { deg = 215, r = 9.0 } }
		for i = 0, 15 do
			local a = i * 22.5 + jit(4)
			local x, z = polar(10.5 + jit(0.25), a)
			local h = 0.8 + rnd() * 0.6
			local yaw = -a + jit(10)
			local w = 2.4 + rnd() * 0.7
			local nearPool = math.abs(((a - 35) + 540) % 180 - 0) < 15 or math.abs(((a - 35) + 540) % 180 - 180) < 15
			if not nearPool then
				B:block(soil, v(w, h, 1.8), cf(x, h / 2, z, 0, yaw, 0), (i % 3 == 0) and SOIL or SOIL_DK, S)
				B:block(soil, v(w + 0.1, 0.3, 1.9), cf(x, h + 0.12, z, 0, yaw, 0), (i % 2 == 0) and GRASS or GRASS_DK, S)
			end
		end
		for i = 0, 8 do
			local a = i * 40 + 12 + jit(7)
			local x, z = polar(7.9 + jit(0.25), a)
			B:block(soil, v(2.2 + rnd() * 0.5, 0.4, 1.7), cf(x, Y2 + 0.05, z, 0, -a + jit(12), 0), (i % 2 == 0) and GRASS_LT or GRASS, S)
		end
		-- pastel wildflowers
		local function flower(x, y, z, col, h)
			h = h or 1.0
			B:block(soil, v(0.2, h, 0.2), cf(x, y + h / 2, z), CLOVER, S)
			local yaw = rnd() * 90
			B:block(soil, v(0.85, 0.22, 0.34), cf(x, y + h + 0.05, z, 0, yaw, 0), col, S)
			B:block(soil, v(0.34, 0.23, 0.85), cf(x, y + h + 0.05, z, 0, yaw, 0), col, S)
			B:block(soil, v(0.28, 0.3, 0.28), cf(x, y + h + 0.12, z, 0, yaw, 0), FL_EYE, S)
		end
		for _, f in {
			{ 9.2, Y1, -2.4, FL_PINK }, { -9.4, Y1, 1.2, FL_LAV }, { 4.8, Y2, -5.6, FL_WHITE }, { -3.4, Y3, -4.0, FL_PINK, 0.8 },
			{ 7.0, Y1, 6.6, FL_LAV }, { -7.0, Y2, 3.6, FL_WHITE }, { 2.4, Y1, 9.4, FL_PINK }, { -8.4, Y1, -5.6, FL_WHITE },
			{ 6.4, Y2, 2.6, FL_PINK, 0.8 }, { 3.6, Y3, 3.4, FL_LAV, 0.7 },
		} do
			flower(f[1], f[2], f[3], f[4], f[5])
		end
		local function clover(x, y, z, puff)
			local yaw = rnd() * 120
			B:block(soil, v(0.16, 0.55, 0.16), cf(x, y + 0.27, z), CLOVER, S)
			for k = 0, 2 do
				local c = CFrame.new(x, y + 0.6, z) * ang(0, yaw + k * 120, 0) * CFrame.new(0, 0, -0.36)
				B:block(soil, v(0.56, 0.16, 0.56), c * ang(0, 45, 0), (k == 0) and CLOVER_LT or CLOVER, S)
			end
			if puff then
				B:block(soil, v(0.4, 0.4, 0.4), cf(x + 0.34, y + 1.0, z, 0, 30, 0), FL_WHITE, S)
			end
		end
		clover(-5.6, Y2, -2.6, true)
		clover(-1.4, Y1, 9.8, true)
		clover(5.8, Y2, 5.6, false)
		for _, p in { { 5.0, Y2, -3.6 }, { -7.6, Y1, -2.6 }, { 8.8, Y1, -6.2 }, { -2.6, Y3, 3.8 }, { 1.0, Y1, -10.0 }, { -9.6, Y1, 4.0 }, { 7.6, Y1, 3.4 } } do
			B:block(soil, v(0.7, 0.42, 0.6), cf(p[1], p[2] + 0.18, p[3], 0, rnd() * 90, 0), rnd() > 0.5 and PEB or PEB_LT, S)
		end
		-- fallen comb chunks
		local function chunk(x, y, z, yaw, tilt)
			local c = CFrame.new(x, y + 0.45, z) * ang(0, yaw, tilt)
			B:block(soil, v(1.7, 0.9, 1.1), c, COMB_BASE, S)
			for k = 0, 2 do
				B:block(soil, v(0.46, 0.55, 0.22), c * CFrame.new(-0.55 + k * 0.55, (k % 2) * 0.14, -0.56), (k == 1) and COMB_CAP or COMB_LT, S)
			end
		end
		chunk(-6.4, Y1, -7.4, 30, 10)
		chunk(6.6, Y2, -1.0, -60, -8)
		-- a little straw skep on the back right of the mound
		do
			local p = at(8.0, 125, Y2)
			B:block(soil, v(2.4, 0.7, 2.4), CFrame.new(p + v(0, 0.35, 0)) * ang(0, 20, 0), HIVE_DK, S)
			B:block(soil, v(2.5, 0.7, 2.5), CFrame.new(p + v(0, 1.0, 0)) * ang(0, 65, 0), HIVE, S)
			B:block(soil, v(2.0, 0.6, 2.0), CFrame.new(p + v(0, 1.6, 0)) * ang(0, 20, 0), HIVE_DK, S)
			B:block(soil, v(1.3, 0.5, 1.3), CFrame.new(p + v(0, 2.1, 0)) * ang(0, 65, 0), HIVE_LT, S)
			B:block(soil, v(0.6, 0.55, 0.3), facing(p + v(0, 0.45, 0), 125) * CFrame.new(0, 0, -1.15), BEE_K, S)
		end

		-- honey pools (where the falls land)
		for k, pl in POOLS do
			local p = at(pl.r, pl.deg, Y1)
			local F = facing(p, pl.deg)
			B:block(soil, v(4.4, 0.16, 3.4), F * CFrame.new(0, 0.06, 0), HONEY_DK, S)
			B:block(soil, v(3.4, 0.18, 4.2), F * CFrame.new(0, 0.07, 0.2), HONEY_DK, S)
			B:block(soil, v(4.0, 0.22, 3.0), F * CFrame.new(0, 0.14, 0), HONEY, S)
			B:block(soil, v(3.0, 0.24, 3.8), F * CFrame.new(0, 0.15, 0.2), HONEY, S)
			B:block(soil, v(1.0, 0.07, 0.4), F * CFrame.new(-1.0, 0.3, -0.7), HONEY_GLOW, { name = "Soil", mat = "Neon" })
			B:block(soil, v(0.4, 0.07, 0.4), F * CFrame.new(1.1, 0.3, 0.6), HONEY_GLOW, { name = "Soil", mat = "Neon" })
			-- honey spilling over the mound edge
			B:block(soil, v(2.6, 1.1, 0.5), F * CFrame.new(0.2, -0.45, -1.75), HONEY, S)
			B:block(soil, v(1.0, 0.7, 0.6), F * CFrame.new(-0.4, -0.95, -1.8), HONEY_LT, S)
		end

		------------------------------------------------------------------
		-- TRUNK (bone "Crop")
		------------------------------------------------------------------
		local BASE = Y3
		local crop = B:bone("Crop", "Root", v(0, BASE, 0))
		for k = 0, 5 do
			local a = k * 60 + 10 + jit(6)
			local p1 = at(2.6, a, BASE + 1.4)
			local p2 = at(4.8, a + 8, BASE - 0.1)
			local p3 = at(6.6, a + 14, Y2 + 0.2)
			B:bar(crop, p1, p2, 1.7, 1.3, (k % 2 == 0) and BARK or BARK_DK)
			B:bar(crop, p2 - (p2 - p1).Unit * 0.3, p3, 1.1, 0.95, BARK_DK)
		end
		B:block(crop, v(6.6, 1.2, 6.6), cf(0, BASE + 0.4, 0, 0, 15, 0), BARK_DK)
		local SEG = { { 5.8, 1.0, 0, BARK }, { 5.3, 3.0, 22, BARK_DK }, { 4.9, 5.0, 44, BARK }, { 4.5, 7.0, 66, BARK_DK }, { 4.1, 8.8, 88, BARK } }
		for i, s in SEG do
			local ox, oz = polar(0.2, i * 80)
			B:block(crop, v(s[1], 2.2, s[1]), cf(ox, BASE + s[2] + 1.0, oz, 0, s[3], 0), s[4])
		end
		-- honey-glazed streaks down the bark + light ridges
		for k, a0 in { 25, 145, 265 } do
			local prev
			for i = 0, 3 do
				local t = i / 3
				local p = at(2.75 - t * 0.6, a0 + t * 70, BASE + 2.0 + t * 8.0)
				if prev then
					B:bar(crop, prev, p, 0.8, 0.7, (i % 2 == 0) and BARK_LT or BARK_HI)
				end
				prev = p
			end
			local d = at(2.95 - k * 0.12, a0 + 40, BASE + 7.5)
			B:bar(crop, d + v(0, 2.2, 0), d - v(0, 2.0, 0), 0.7, 0.5, HONEY)
			B:block(crop, v(0.85, 0.7, 0.75), CFrame.new(d - v(0, 2.2, 0)) * ang(0, -(a0 + 40), 0), HONEY_LT)
		end
		-- limbs fanning to the canopy
		local FORK = BASE + 10.2
		local limbs = {}
		for k = 0, 4 do
			local a = 36 + k * 72 + jit(6)
			local p0 = at(0.8, a, FORK - 0.8)
			local p1 = at(4.6, a + 6, FORK + 1.6)
			B:bar(crop, p0, p1, 2.0, 1.8, (k % 2 == 0) and BARK or BARK_DK)
			limbs[k + 1] = { a = a, p1 = p1, p0 = p0 }
		end
		B:block(crop, v(3.8, 1.8, 3.8), cf(0, FORK + 0.2, 0, 0, 70, 0), BARK)

		------------------------------------------------------------------
		-- COMB CANOPY
		------------------------------------------------------------------
		local cubes = {}
		local function leafCube(bone, p, s, h, col)
			return B:block(bone, v(s, h, s), CFrame.new(p) * ang(jit(7), rnd() * 90, jit(7)), col)
		end
		-- a honeycomb block whose outward face shows stepped cells
		local function combCube(bone, p, deg, s, h)
			local F = facing(p, deg) * ang(jit(5), 0, jit(5))
			-- amber wax body; raised golden cells in a 2-3-2 hex cluster leave
			-- dark seams between them = honeycomb
			local H = h + 0.8
			B:block(bone, v(s, H, s * 0.9), F, COMB_BASE)
			local cw = (s - 0.4) / 3 - 0.2
			local ch = (H - 0.3) / 3 - 0.2
			local cells = { { -0.5, 1 }, { 0.5, 1 }, { -1, 0 }, { 0, 0 }, { 1, 0 }, { -0.5, -1 }, { 0.5, -1 } }
			for k, c in cells do
				local col = (k == 4) and HONEY_GLOW or ((k == 1 or k == 7) and COMB_CAP or ((k % 2 == 0) and COMB or COMB_LT))
				B:block(bone, v(cw, ch, 0.4), F * CFrame.new(c[1] * (cw + 0.2), c[2] * (ch + 0.2), -s * 0.45 - 0.12), col)
			end
			-- a honey drip hanging off the bottom
			B:block(bone, v(0.7, 1.0, 0.6), F * CFrame.new(0.4, -H * 0.5 - 0.35, -s * 0.3), HONEY)
		end
		local function blossom(bone, p, col)
			local yaw = rnd() * 90
			B:block(bone, v(1.2, 0.35, 0.5), CFrame.new(p) * ang(0, yaw, 0), col)
			B:block(bone, v(0.5, 0.36, 1.2), CFrame.new(p) * ang(0, yaw, 0), col)
			B:block(bone, v(0.4, 0.45, 0.4), CFrame.new(p + v(0, 0.06, 0)) * ang(0, yaw, 0), FL_EYE)
		end
		local function tier(bone, d)
			-- stepped golden comb core with a dark underside
			oct(bone, d.cy - d.h * 0.5 - 0.2, d.cy - d.h * 0.5 + 0.5, d.R * 1.7, COMB_DK)
			oct(bone, d.cy - d.h * 0.5 + 0.5, d.cy + d.h * 0.5 + 0.2, d.R * 1.25, COMB)
			for i = 0, d.n - 1 do
				local isComb = (i % d.combEvery == 0)
				local a = i * 360 / d.n + d.phase + (isComb and 0 or jit(4))
				local p = at(d.r + jit(0.25), a, d.cy + jit(0.25))
				if isComb then
					combCube(bone, p, a, d.s, d.h)
				else
					leafCube(bone, p, d.s + jit(0.25), d.h, d.cols[1 + (i % #d.cols)])
				end
				table.insert(cubes, { bone = bone, p = p, s = d.s, h = d.h, a = a })
			end
			for i = 0, d.ni - 1 do
				local a = i * 360 / d.ni + d.phase + 30
				leafCube(bone, at(d.ri, a, d.cy + 0.3), d.si, d.h + 0.2, d.cols[1 + ((i + 1) % #d.cols)])
			end
			for i = 0, d.nb - 1 do
				local a = (i + 0.5) * 360 / d.nb + d.phase + jit(6)
				local p = at(d.rb + jit(0.2), a, d.cy + d.h * 0.5 + d.bh * 0.3)
				leafCube(bone, p, d.bs + jit(0.2), d.bh, d.top[1 + (i % #d.top)])
				if i % 2 == 0 then
					blossom(bone, p + v(0, d.bh * 0.5 + 0.1, 0), (i % 4 == 0) and BLOS or ((i % 3 == 0) and BLOS_LAV or BLOS_LT))
				end
			end
		end

		-- TIER 1 (widest)
		local can1 = B:bone("Canopy1", "Crop", v(0, FORK + 0.8, 0))
		for _, l in limbs do
			local p2 = at(7.4, l.a - 5, FORK + 3.0)
			B:bar(can1, l.p1 - (l.p1 - l.p0).Unit * 0.5, p2, 1.4, 1.3, BARK_LT)
		end
		B:block(can1, v(3.0, 4.0, 3.0), cf(0, FORK + 2.6, 0, 0, 20, 0), BARK_DK)
		local C1 = FORK + 3.6
		tier(can1, { cy = C1, R = 9.4, n = 12, r = 7.7, s = 4.6, h = 2.6, cols = { LF, LF_MID, LF_DK }, phase = 35, combEvery = 3,
			ni = 6, ri = 4.4, si = 5.0, nb = 10, rb = 6.8, bs = 3.0, bh = 1.3, top = { LF_LT, LF_LIME, LF_MID } })
		local T2Y = C1 + 4.6
		for k = 0, 2 do
			local a = 20 + k * 120
			B:bar(can1, at(0.6, a, C1 + 0.6), at(3.2, a + 10, T2Y - 0.6), 1.3, 1.2, BARK)
		end
		-- TIER 2
		local can2 = B:bone("Canopy2", "Canopy1", v(0, C1 + 2.4, 0))
		B:block(can2, v(2.2, 3.4, 2.2), cf(0, T2Y - 1.4, 0, 0, 40, 0), BARK_DK)
		tier(can2, { cy = T2Y, R = 7.4, n = 10, r = 6.0, s = 4.1, h = 2.4, cols = { LF_MID, LF_LT, LF_LIME }, phase = 80, combEvery = 3,
			ni = 3, ri = 2.4, si = 4.4, nb = 8, rb = 4.6, bs = 2.6, bh = 1.3, top = { LF_LIME, LF_GOLD } })
		local T3Y = T2Y + 4.0
		for k = 0, 2 do
			local a = 80 + k * 120
			B:bar(can2, at(0.5, a, T2Y + 0.5), at(2.2, a + 10, T3Y - 0.6), 1.1, 1.0, BARK_LT)
		end
		-- TIER 3
		local can3 = B:bone("Canopy3", "Canopy2", v(0, T2Y + 2.0, 0))
		tier(can3, { cy = T3Y, R = 5.0, n = 8, r = 4.1, s = 3.5, h = 2.2, cols = { LF_LIME, LF_GOLD, LF_LT }, phase = 8, combEvery = 4,
			ni = 1, ri = 0, si = 3.8, nb = 6, rb = 3.0, bs = 2.2, bh = 1.1, top = { LF_GOLD2, LF_GOLD } })

		------------------------------------------------------------------
		-- CROWN HIVE (bone "Hive" on top of tier 3) + queen's CROWN
		------------------------------------------------------------------
		local HB = T3Y + 1.1
		local hive = B:bone("Hive", "Canopy3", v(0, HB, 0))
		local BANDS = { -- y0, y1, width, colour
			{ 0.0, 1.3, 6.0, HIVE_DK },
			{ 1.3, 2.6, 6.6, HIVE },
			{ 2.6, 3.8, 6.4, HIVE_DK },
			{ 3.8, 4.9, 5.6, HIVE },
			{ 4.9, 5.8, 4.4, HIVE_DK },
			{ 5.8, 6.5, 3.0, HIVE_LT },
		}
		for i, b in BANDS do
			oct(hive, HB + b[1], HB + b[2], b[3], b[4])
			if i < #BANDS then
				-- darker groove just inside the next band edge
				local gw = math.min(b[3], BANDS[i + 1][3]) + 0.25
				oct(hive, HB + b[2] - 0.12, HB + b[2] + 0.12, gw, HIVE_GR)
			end
		end
		-- honey oozing over the hive bands
		for _, d in { { 30, 1.8 }, { 150, 2.4 }, { 250, 1.5 } } do
			local p = at(3.25, d[1], HB + 2.4)
			local F = facing(p, d[1])
			B:block(hive, v(0.9, d[2], 0.4), F * CFrame.new(0, -d[2] / 2 + 0.3, 0), HONEY)
			B:block(hive, v(1.1, 0.7, 0.5), F * CFrame.new(0, -d[2] + 0.1, 0), HONEY_LT)
		end
		-- entrance (front): dark doorway with a glowing honey core
		do
			local F = facing(v(0, HB + 1.15, 0), 0) * CFrame.new(0, 0, -3.05)
			B:block(hive, v(2.0, 1.5, 0.3), F, HIVE_GR)
			B:block(hive, v(1.4, 1.0, 0.35), F * CFrame.new(0, -0.1, -0.03), BEE_K)
			B:block(hive, v(0.8, 0.5, 0.2), F * CFrame.new(0, -0.15, -0.12), HONEY_GLOW, { mat = "Neon", name = "HiveCore" })
			B:block(hive, v(2.4, 0.35, 0.8), F * CFrame.new(0, -0.85, -0.2), HIVE_LT) -- landing step
		end
		-- crown
		local CY = HB + 6.5
		local crown = B:bone("Crown", "Hive", v(0, CY, 0))
		B:block(crown, v(3.4, 0.6, 3.4), cf(0, CY + 0.3, 0), GOLD_DK)
		B:ring(crown, CFrame.new(0, CY + 0.95, 0), 1.75, 8, v(1.45, 0.9, 0.45), GOLD)
		for i = 0, 7 do
			local a = i * 45
			local tall = (i % 2 == 0)
			local h = tall and 1.4 or 0.8
			local p = at(1.75, a, CY + 1.4 + h / 2)
			B:block(crown, v(0.6, h, 0.6), CFrame.new(p) * ang(0, -a, 0), tall and GOLD_LT or GOLD)
			if tall then
				B:block(crown, v(0.45, 0.45, 0.45), CFrame.new(p + v(0, h / 2 + 0.25, 0)) * ang(0, 45 - a, 0), GOLD_LT)
			end
		end
		for i = 0, 3 do
			local a = i * 90
			local F = facing(at(1.75, a, CY + 0.95), a) * CFrame.new(0, 0, -0.25)
			B:block(crown, v(0.5, 0.5, 0.2), F * ang(0, 0, 45), GEM_PINK, { mat = "Neon", name = "CrownGem" .. (i + 1) })
		end
		B:block(crown, v(0.8, 0.8, 0.8), cf(0, CY + 1.2, 0, 0, 45, 0), GEM_PINK, { mat = "Neon", name = "CrownJewel" })

		------------------------------------------------------------------
		-- HANGING COMB SHEETS + HONEY-DROP FRUITS (under tier 1)
		------------------------------------------------------------------
		local UNDER = C1 - 1.6
		for i, a in { 0, 90, 180, 270 } do
			local deg = a + 45
			local top = at(4.9, deg, UNDER + 0.2)
			local bone = B:bone("Comb" .. i, "Canopy1", top)
			local F = facing(top, deg)
			B:block(bone, v(0.5, 0.8, 0.5), F * CFrame.new(0, -0.1, 0), BARK_DK)
			B:block(bone, v(2.6, 2.4, 0.7), F * CFrame.new(0, -1.6, 0), COMB_BASE)
			B:block(bone, v(1.9, 1.0, 0.68), F * CFrame.new(0, -3.2, 0), COMB_BASE)
			B:block(bone, v(1.0, 0.7, 0.66), F * CFrame.new(0, -4.0, 0), HONEY)
			for _, sd in { -1, 1 } do
				for _, c in { { -0.6, -1.0 }, { 0.6, -1.0 } } do
					B:block(bone, v(0.75, 0.7, 0.14), F * CFrame.new(c[1], c[2], sd * 0.4), (c[2] < -2.5 or c[1] == 0) and COMB_CAP or COMB_LT)
				end
			end
		end
		local FRUITS = { -- deg, radius, stem length, scale
			{ 0, 7.4, 1.6, 1.15 }, { 60, 7.9, 2.6, 1.0 }, { 120, 7.4, 1.8, 1.15 },
			{ 180, 7.9, 2.4, 1.0 }, { 240, 7.4, 1.7, 1.15 }, { 300, 7.9, 2.7, 1.0 },
		}
		for i, f in FRUITS do
			local top = at(f[2], f[1], UNDER + 0.3)
			local bone = B:bone("Fruit" .. i, "Canopy1", top)
			local s = f[4]
			local c = top - v(0, f[3] + 1.3 * s, 0)
			local F = CFrame.new(c) * ang(0, -f[1] + 20, 0)
			B:bar(bone, top + v(0, 0.4, 0), c + v(0, 1.2 * s, 0), 0.35, 0.35, BARK_DK)
						B:block(bone, v(0.6, 0.6, 0.6) * s, F * CFrame.new(0, 0.95 * s, 0) * ang(0, 45, 0), HONEY_DK)
			B:block(bone, v(1.25, 0.8, 1.25) * s, F * CFrame.new(0, 0.45 * s, 0), HONEY)
			B:block(bone, v(1.6, 1.25, 1.6) * s, F * CFrame.new(0, -0.45 * s, 0) * ang(0, 45, 0), HONEY_DK)
			B:block(bone, v(1.95, 1.0, 1.4) * s, F * CFrame.new(0, -0.45 * s, 0), HONEY)
			B:block(bone, v(1.4, 1.0, 1.95) * s, F * CFrame.new(0, -0.45 * s, 0), HONEY_LT)
			B:block(bone, v(1.05, 0.6, 1.05) * s, F * CFrame.new(0, -1.25 * s, 0) * ang(0, 45, 0), HONEY)
			B:block(bone, v(0.7, 0.7, 0.7) * s, F * CFrame.new(-0.35 * s, -0.25 * s, -0.75 * s), HONEY_GLOW, { mat = "Neon", name = "FruitCore" .. i })
		end

		------------------------------------------------------------------
		-- HONEY FALLS (static bone "Falls"): flow segments + hidden neon core
		------------------------------------------------------------------
		local falls = B:bone("Falls", "Root", v(0, 0, 0))
		local NSEG = 9
		for k, pl in POOLS do
			-- pours out of the comb block below the tier-1 rim
			local topY = C1 - 2.2
			local botY = Y1 + 0.3
			local FR = 9.55
			local F = facing(at(FR, pl.deg, 0), pl.deg)
			local segH = (topY - botY) / NSEG
			for j = 1, NSEG do
				local y = topY - (j - 0.5) * segH
				local wide = ((j % 2 == 0) and 2.0 or 2.65) + 0.35 * (j / NSEG)
				local sx = ((j % 3) - 1) * 0.15
				B:block(falls, v(wide, segH + 0.1, 1.15), F * CFrame.new(sx, y, 0), (j % 2 == 0) and HONEY or HONEY_LT,
					{ name = "Fall" .. k .. "Seg" .. j })
			end
			-- glossy streak + hidden neon core revealed on the burst
			B:block(falls, v(0.5, topY - botY - 0.4, 1.2), F * CFrame.new(-0.5, (topY + botY) / 2, -0.02), HONEY_GLOW, { mat = "Neon", tr = 1, name = "FallCore" .. k })
			B:block(falls, v(0.28, topY - botY - 1.8, 1.18), F * CFrame.new(0.5, (topY + botY) / 2 + 0.5, -0.03), GOLD_LT)
			-- pour lip under the comb + splash crown at the foot
			B:block(falls, v(3.0, 0.9, 2.2), F * CFrame.new(0, topY + 0.35, 0.6), HONEY)
			B:block(falls, v(2.2, 0.6, 1.6), F * CFrame.new(0.2, topY + 0.85, 0.9), HONEY_LT)
			B:block(falls, v(3.2, 0.5, 1.6), F * CFrame.new(0, botY - 0.05, 0), HONEY_LT)
			B:block(falls, v(1.6, 0.45, 2.8), F * CFrame.new(0, botY - 0.1, 0), HONEY)
		end

		------------------------------------------------------------------
		-- BEE SWARM (orbit bone -> bee bone -> wing bones)
		------------------------------------------------------------------
		local function bee(n, pivot, r, dir, s, trail)
			local orbit = B:bone("BeeOrbit" .. n, "Root", pivot)
			-- bee at the front of its orbit, facing along the direction of travel
			local BF = pivot * CFrame.new(0, 0, -r) * ang(0, 90 * dir, 0)
			local body = B:bone("Bee" .. n, "BeeOrbit" .. n, BF)
			local function bp(x, y, z, sx, sy, sz, col, opts)
				return B:block(body, v(sx * s, sy * s, sz * s), BF * CFrame.new(x * s, y * s, z * s), col, opts)
			end
			bp(0, 0, 0.1, 1.1, 1.0, 1.5, BEE_Y)
			bp(0, 0, -0.05, 1.16, 1.06, 0.3, BEE_K)
			bp(0, 0, 0.45, 1.16, 1.06, 0.3, BEE_K)
			bp(0, -0.02, 0.95, 0.8, 0.75, 0.35, BEE_Y)
			bp(0, -0.05, 1.22, 0.24, 0.24, 0.3, BEE_K)
			bp(0, 0.05, -0.9, 0.9, 0.85, 0.55, BEE_K)
			for _, sd in { 1, -1 } do
				local side = (sd > 0) and "R" or "L"
				local wb = B:bone("Bee" .. n .. "Wing" .. side, "Bee" .. n, BF * CFrame.new(0.3 * sd * s, 0.5 * s, 0))
				B:block(wb, v(1.0 * s, 0.1 * s, 0.7 * s), BF * CFrame.new(0.78 * sd * s, 0.62 * s, 0.1 * s) * ang(0, 0, 12 * sd), WING, { tr = 0.25 })
			end
			if trail then
				B:trail(body, BF * v(0, 0.35 * s, 1.0 * s), BF * v(0, -0.35 * s, 1.0 * s),
					{ name = "BeeTrail" .. n, color = { HONEY_GLOW, "#fff3c0" }, life = 0.5, width = { 1, 0.2 }, trans = { 0.3, 1 } })
			end
		end
		-- around the crown hive
		bee(1, CFrame.new(0, HB + 2.4, 0) * ang(8, 0, 0), 5.6, 1, 1.15, true)
		bee(2, CFrame.new(0, HB + 4.2, 0) * ang(-6, 120, 6), 5.0, 1, 1.05, true)
		bee(3, CFrame.new(0, HB + 1.2, 0) * ang(0, 240, -8), 6.2, -1, 1.1, true)
		-- around the canopy
		bee(4, CFrame.new(0, C1 + 0.6, 0) * ang(6, 30, 0), 12.6, 1, 1.25, true)
		bee(5, CFrame.new(0, T2Y + 0.4, 0) * ang(-8, 200, 4), 10.2, -1, 1.2, true)
		bee(6, CFrame.new(0, UNDER - 2.0, 0) * ang(0, 100, 7), 10.8, 1, 1.2, true)
		bee(7, CFrame.new(0, T3Y + 0.2, 0) * ang(10, 300, 0), 8.0, -1, 1.1, true)
		bee(8, CFrame.new(0, C1 - 0.4, 0) * ang(-10, 160, -6), 12.8, -1, 1.2, true)

		------------------------------------------------------------------
		-- VFX: 8 emitters, 3 lights, 8 trails (bees)
		------------------------------------------------------------------
		local hiveFx = B:block(hive, v(5, 4, 5), cf(0, HB + 3.0, 0), HIVE, { tr = 1, name = "HiveFx" })
		B:emitter(hiveFx, "burst", { name = "HiveBurst", color = { "#ffffff", GOLD_LT, HONEY }, size = { 1.0, 0.7, 0 }, speed = { 12, 24 }, life = { 0.7, 1.4 }, drag = 2.4, light = 0.9 })
		B:emitter(hiveFx, "burst", { name = "HoneyFling", color = { HONEY_LT, HONEY, HONEY_DK }, size = { 0.75, 0.6, 0.3 }, speed = { 9, 16 }, life = { 1.2, 2.0 }, drag = 0.6, accel = { 0, -24, 0 }, spread = 70, light = 0.3, trans = { 0, 0, 0.3 } })
		for k, pl in POOLS do
			local p = at(pl.r - 0.1, pl.deg, Y1 + 0.6)
			local sz = B:block(soil, v(1.6, 0.4, 1.6), CFrame.new(p), HONEY, { tr = 1, name = "SplashZone" .. k })
			B:emitter(sz, "bubble", { name = "HoneySplash" .. k, color = { HONEY_GLOW, HONEY_LT, HONEY }, rate = 9, size = { 0.35, 0.45, 0.2 }, life = { 0.5, 0.9 }, speed = { 3, 5 }, spread = 55, accel = { 0, -16, 0 }, trans = { 0.05, 0.1, 1 }, light = 0.4 })
		end
		local dripZone = B:block(can1, v(14, 0.6, 14), cf(0, UNDER - 0.3, 0), HONEY, { tr = 1, name = "DripZone" })
		B:emitter(dripZone, "drip", { name = "CanopyDrips", color = { HONEY_LT, HONEY }, rate = 4, size = { 0.4, 0.35, 0.2 }, life = { 0.9, 1.4 }, accel = { 0, -18, 0 }, light = 0.3 })
		local pollen = B:block(can1, v(24, 16, 24), cf(0, C1 + 6, 0), GOLD, { tr = 1, name = "PollenZone" })
		B:emitter(pollen, "sparkle", { name = "PollenSparkle", color = { "#ffffff", GOLD_LT, HONEY_GLOW }, rate = 22, size = { 0.2, 0.7, 0 }, life = { 1.0, 2.0 }, speed = { 0.2, 0.7 }, light = 0.9 })
		local petalZone = B:block(can1, v(18, 1, 18), cf(0, C1 + 1.0, 0), BLOS, { tr = 1, name = "PetalZone" })
		B:emitter(petalZone, "leaf", { name = "BlossomPetals", color = { BLOS, BLOS_LT, BLOS_LAV }, rate = 2.5, size = { 0.5, 0.5, 0.35 }, life = { 3.5, 5.5 }, speed = { 0.3, 0.9 }, accel = { 0.6, -1.4, 0.2 }, dir = "Bottom" })
		local crownFx = B:block(crown, v(4, 2.5, 4), cf(0, CY + 1.4, 0), GOLD, { tr = 1, name = "CrownFx" })
		B:emitter(crownFx, "sparkle", { name = "CrownSparkle", color = { "#ffffff", GEM_PINK, GOLD_LT }, rate = 7, size = { 0.2, 0.7, 0 }, life = { 0.7, 1.3 }, speed = { 0.3, 1.0 }, light = 1 })
		local hl = B:block(hive, v(0.4, 0.4, 0.4), cf(0, HB + 1.2, -2.0), HONEY, { tr = 1, name = "HiveLightCore" })
		B:light(hl, { name = "HiveLight", color = "#ffc24a", brightness = 1.3, range = 18 })
		local cl = B:block(can1, v(0.4, 0.4, 0.4), cf(0, UNDER - 2.5, 0), HONEY, { tr = 1, name = "CanopyLightCore" })
		B:light(cl, { name = "CanopyLight", color = "#ffb347", brightness = 1.0, range = 20 })
		local pl = B:block(soil, v(0.4, 0.4, 0.4), at(8.6, 32, Y1 + 1.0), HONEY, { tr = 1, name = "PoolLightCore" })
		B:light(pl, { name = "PoolLight", color = "#ffb030", brightness = 0.8, range = 10 })
	end,
}
