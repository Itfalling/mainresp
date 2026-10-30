--!nocheck
-- Golden Harvest Corn (Scarecrow Stage crop #9, Divine): a prize-winning
-- cluster of three giant golden corn stalks tied together like a harvest
-- corn shock with a big burgundy ribbon bow. Chunky olive-gold stalks with
-- darker node rings, long arching straw-gold leaf blades, and fat golden
-- cobs whose kernels are faceted amber/gold "gem" rows with tiny neon glints,
-- peeking out of pale husks with amber silk. Golden tassels on top.
-- Base: stepped round dirt mound ringed with twine-tied hay bales, straw
-- bits, two little pumpkins and grass tufts. Static prop: no motion.luau.
return {
	DisplayName = "Golden Harvest Corn",
	Rarity = "Divine",
	Element = "Harvest",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad

		-- palette ---------------------------------------------------------
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#55311b", "#472815", "#6e4024", "#8a552f"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local HAY, HAY_DK, HAY_LT, TWINE = "#eac25a", "#c99a35", "#f7e095", "#8a5a2a"
		local STALK, STALK_DK, STALK_LT = "#6fa83a", "#4f8a2a", "#86bc44"
		local L_GREEN = { "#4f8f2e", "#5f9e34", "#76b03c" }
		local L_MID = { "#7fa834", "#9db63c", "#b9c24a" }
		local L_STRAW = { "#cfa640", "#e2bd52", "#f0d36e" }
		local GOLD, GOLD_DK, AMBER, AMBER_DK = "#ffd024", "#e39a14", "#f59a16", "#d9730c"
		local GOLD_LT = "#ffe45c"
		local HUSK, HUSK_DK, HUSK_LT, STRAW_TIP = "#9cc44a", "#78a836", "#c3d660", "#e8cc62"
		local SILK, SILK_DK = "#f2a640", "#b8641e"
		local GLINT = "#fff2a8"
		local RIB, RIB_DK = "#b8243a", "#86182a"
		local PUMPKIN, PUMPKIN_DK, PSTEM = "#f08a24", "#c8631a", "#5f7a2a"

		local seed = 9
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		-- polar: deg 0 = front (-Z), clockwise seen from above toward +X
		local function polar(r, deg)
			local a = rad(deg)
			return math.sin(a) * r, -math.cos(a) * r
		end
		-- CFrame at pos whose local -Z faces outward along `deg` and whose +Y is tipped
		-- outward by `tilt` degrees
		local function orient(pos, deg, tilt, roll)
			return CFrame.new(pos) * CFrame.Angles(0, -rad(deg), 0) * CFrame.Angles(-rad(tilt or 0), 0, 0) * CFrame.Angles(0, 0, rad(roll or 0))
		end

		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local crop = B:bone("Crop", "Root", v(0, 0, 0))
		local S = { name = "Soil" }

		------------------------------------------------------------------
		-- STEPPED DIRT MOUND (3 tiers + chunky irregular edge blocks)
		------------------------------------------------------------------
		local function oct(y0, y1, w, color)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(soil, v(w, h, w * 0.62), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.62, h + 0.02, w), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.84, h - 0.03, w * 0.84), cf(0, y, 0), color, S)
		end
		oct(0, 0.9, 13.2, DIRT_DK)
		oct(0.9, 1.7, 9.8, DIRT)
		oct(1.7, 2.3, 6.0, DIRT_LT)
		for i = 0, 12 do
			local a = i * (360 / 13) + jit(5)
			local x, z = polar(6.3 + jit(0.3), a)
			local h = 0.9 + rnd() * 0.6
			B:block(soil, v(2.6 + rnd() * 0.7, h, 1.9 + rnd() * 0.4), cf(x, h / 2, z, 0, -a + jit(10), 0),
				i % 3 == 0 and DIRT or (i % 2 == 0 and DIRT_DK2 or DIRT_DK), S)
		end
		for i = 0, 6 do
			local a = i * (360 / 7) + 20 + jit(8)
			local x, z = polar(4.6 + jit(0.3), a)
			local h = 0.7 + rnd() * 0.4
			B:block(soil, v(2.0 + rnd() * 0.5, h, 1.6), cf(x, 0.9 + h / 2, z, 0, -a + jit(12), 0), i % 2 == 0 and DIRT or DIRT_DK, S)
		end
		for _, g in { { -7.9, 2.6, 1.1 }, { -7.3, 3.4, 0.7 }, { 6.9, -4.8, 0.9 }, { 7.4, -4.0, 0.6 }, { 2.2, 7.8, 0.8 }, { -4.2, -6.9, 0.7 } } do
			B:block(soil, v(0.6, g[3], 0.6), cf(g[1], g[3] / 2, g[2], 0, jit(20), 0), (g[3] > 0.8) and GRASS or GRASS_DK, S)
		end

		------------------------------------------------------------------
		-- HAY BALES ringing the mound (twine bands + straw bits)
		------------------------------------------------------------------
		local function bale(x, y, z, yaw, sx, sy, sz)
			local C = cf(x, y, z, 0, yaw, 0)
			B:block(soil, v(sx, sy, sz), C, HAY, S)
			B:block(soil, v(sx - 0.3, sy + 0.1, sz - 0.3), C, HAY_LT, S) -- lighter top / ends
			for _, o in { -sx * 0.27, sx * 0.27 } do
				B:block(soil, v(0.25, sy + 0.14, sz + 0.14), C * CFrame.new(o, 0, 0), TWINE, S)
			end
			-- straw poking out of an end
			B:block(soil, v(0.18, 0.18, 0.9), C * CFrame.new(sx * 0.5, sy * 0.15, 0.2) * CFrame.Angles(0, rad(70), rad(20)), HAY_DK, S)
		end
		local bales = {
			{ 200, 4.3, 2.45, 3.0, 1.5, 1.7 },
			{ 265, 4.2, 2.45, 3.0, 1.5, 1.7 },
			{ 128, 4.3, 2.45, 3.0, 1.5, 1.7 },
			{ 335, 4.4, 2.35, 2.6, 1.3, 1.5 },
		}
		for _, b in bales do
			local x, z = polar(b[2], b[1])
			bale(x, b[3], z, -b[1] + 90 + jit(8), b[4], b[5], b[6])
		end
		-- one bale stacked on the back pair
		do
			local x, z = polar(4.0, 232)
			bale(x, 3.85, z, -235 + 90 + 8, 2.6, 1.3, 1.5)
		end
		-- loose straw bits on the mound
		for i = 1, 9 do
			local a = i * 40 + jit(12)
			local x, z = polar(3.2 + rnd() * 3.4, a)
			local y = (math.sqrt(x * x + z * z) > 5.4) and 1.75 or 2.38
			B:block(soil, v(0.2, 0.18, 1.0 + rnd() * 0.5), cf(x, y, z, 0, rnd() * 180, 0), (i % 3 == 0) and HAY_LT or (i % 2 == 0 and HAY or HAY_DK), S)
		end
		-- two little pumpkins at the front
		local function pumpkin(x, y, z, s, yaw)
			local C = cf(x, y + s * 0.4, z, 0, yaw, 0)
			B:block(soil, v(s, s * 0.8, s * 0.72), C, PUMPKIN, S)
			B:block(soil, v(s * 0.72, s * 0.82, s), C, PUMPKIN_DK, S)
			B:block(soil, v(s * 0.86, s * 0.78, s * 0.86), C, PUMPKIN, S)
			B:block(soil, v(0.3, 0.45, 0.3), C * CFrame.new(0, s * 0.5, 0) * CFrame.Angles(0, 0, rad(12)), PSTEM, S)
		end
		pumpkin(2.6, 2.3, -3.9, 1.5, 20)
		pumpkin(-1.4, 2.3, -4.3, 1.1, -15)

		------------------------------------------------------------------
		-- STALKS (corn shock: chunky stalks pinched together by the bow)
		------------------------------------------------------------------
		local BASEY = 2.2
		local RIBY = 6.3
		local stalks = {
			-- x, z, height, width, splay x, splay z, tassel?
			{ 0.0, 0.3, 12.8, 2.3, 0.0, 0.0, false },
			{ -2.1, -0.5, 15.0, 1.7, -1.6, -0.3, true },
			{ 2.1, -0.4, 13.2, 1.6, 1.6, -0.2, true },
			{ 0.3, 2.2, 11.4, 1.5, 0.3, 1.4, true },
		}
		local stalkPt = {}
		for si, s in stalks do
			local x0, z0, H, W = s[1], s[2], s[3], s[4]
			local function at(y)
				local pinch = math.clamp(1 - math.abs(y - RIBY) / 4.5, 0, 1)
				local up = math.clamp((y - RIBY) / (H - RIBY), 0, 1)
				local k = 1 - 0.45 * pinch
				return v(x0 * k + s[5] * up * up * 1.6, y, z0 * k + s[6] * up * up * 1.6)
			end
			stalkPt[si] = at
			local cuts = { BASEY - 0.2 }
			local y = BASEY - 0.2
			while y < H - 0.5 do
				y = math.min(H, y + 2.4)
				table.insert(cuts, y)
			end
			for n = 1, #cuts - 1 do
				local y0, y1 = cuts[n], cuts[n + 1]
				local w = W * (1 - 0.3 * (y0 - BASEY) / (H - BASEY))
				B:bar(crop, at(y0), at(y1 + 0.1), w, w, (n % 2 == 0) and STALK_LT or STALK)
				if n < #cuts - 1 then
					local p = at(y1)
					B:block(crop, v(w + 0.3, 0.35, w + 0.3), cf(p.X, p.Y, p.Z, 0, 10 * si, 0), STALK_DK)
				end
			end
			local p0 = at(BASEY)
			B:block(crop, v(W + 0.6, 0.5, W + 0.6), cf(p0.X, BASEY + 0.1, p0.Z, 0, 20 * si, 0), STALK_DK)
		end

		------------------------------------------------------------------
		-- LEAVES: broad arching blades, green low down, straw-gold up high
		------------------------------------------------------------------
		local function leafBlade(p, deg, len, w, pal, rise)
			local pitches = { 40 + rise, 6 + rise * 0.5, -34 }
			local seg = len / #pitches
			local a = rad(deg)
			local dir = v(math.sin(a), 0, -math.cos(a))
			local cur = p
			for i, pt in pitches do
				local pr = rad(pt)
				local nxt = cur + dir * (math.cos(pr) * seg) + v(0, math.sin(pr) * seg, 0)
				local d = (nxt - cur).Unit
				B:bar(crop, cur - d * 0.3, nxt + d * 0.3, w * (1 - 0.2 * (i - 1)), 0.5, pal[i])
				cur = nxt
			end
		end
		local leaves = {
			-- stalk, height, deg, len, width, palette, rise
			{ 1, 4.2, 170, 7.4, 1.8, L_GREEN, -4 },
			{ 1, 4.0, 15, 7.0, 1.8, L_GREEN, -4 },
			{ 2, 4.6, 280, 7.2, 1.7, L_GREEN, -4 },
			{ 3, 4.4, 90, 7.0, 1.7, L_GREEN, -4 },
			{ 4, 4.8, 215, 6.6, 1.6, L_GREEN, -2 },
			{ 1, 8.8, 120, 6.6, 1.6, L_MID, 4 },
			{ 1, 9.4, 240, 6.4, 1.6, L_MID, 4 },
			{ 2, 10.4, 310, 6.0, 1.5, L_STRAW, 8 },
			{ 3, 9.6, 45, 5.8, 1.5, L_STRAW, 8 },
			{ 4, 9.0, 165, 5.4, 1.4, L_STRAW, 8 },
		}
		for _, l in leaves do
			leafBlade(stalkPt[l[1]](l[2]), l[3] + jit(5), l[4], l[5], l[6], l[7])
		end

		------------------------------------------------------------------
		-- COBS: gold kernel rows over an amber kernel grid, gem glints, husks
		------------------------------------------------------------------
		local glints = {}
		local function kernels(C, L, W, rows, gems)
			-- stepped tapering kernel rows: amber grooves between plump gold rows
			local pitch = L / rows
			local function taper(t)
				return 1 - 0.36 * math.clamp((t - 0.62) / 0.38, 0, 1) ^ 1.5
			end
			for r = 0, rows - 1 do
				local t = r / (rows - 1)
				local wc = W * taper(t)
				local y = pitch * (r + 0.5)
				B:block(crop, v(wc, pitch + 0.04, wc), C * CFrame.new(0, y, 0), AMBER)
				B:block(crop, v(wc + 0.36, pitch * 0.66, wc + 0.36), C * CFrame.new(0, y, 0), (r % 2 == 0) and GOLD_LT or GOLD)
			end
			B:block(crop, v(W * 0.5, 0.5, W * 0.5), C * CFrame.new(0, L + 0.2, 0), GOLD_LT)
			-- kernel columns: gold ribs crossing the amber grooves -> a kernel grid
			for f = 0, 1 do
				local a, b = W + 0.2, W * 0.28
				B:block(crop, v(f == 0 and a or b, L * 0.66, f == 0 and b or a), C * CFrame.new(0, L * 0.36, 0), GOLD)
			end
			-- gem kernels: tiny neon amber/gold glints in the grid
			for k, g in gems do
				local face = g[1]
				local yaw = rad(face * 90)
				local wl = W * taper(g[3])
				local pc = C * CFrame.Angles(0, yaw, 0) * CFrame.new(g[2] * wl, L * g[3], -(wl * 0.5 + 0.2))
				local part = B:block(crop, v(0.42, 0.42, 0.16), pc * CFrame.Angles(0, 0, rad(45)), (k % 2 == 1) and GLINT or "#ffb020", { mat = "Neon", name = "KernelGlint" })
				table.insert(glints, part)
			end
		end
		local function husks(C, n, r, y0, len, w, tilt, cols, phase)
			for k = 0, n - 1 do
				local a = k * (360 / n) + (phase or 0)
				local base = C * CFrame.Angles(0, -rad(a), 0) * CFrame.new(0, y0, -r)
				local h1 = base * CFrame.Angles(-rad(tilt), 0, 0)
				B:block(crop, v(w, len, 0.4), h1 * CFrame.new(0, len * 0.5, 0), cols[k % #cols + 1])
				local top = h1 * CFrame.new(0, len - 0.15, 0) * CFrame.Angles(-rad(tilt + 28), 0, 0)
				B:block(crop, v(w * 0.72, len * 0.55, 0.38), top * CFrame.new(0, len * 0.27, 0), (k % 2 == 0) and HUSK_LT or STRAW_TIP)
			end
		end
		local function silk(C, L, n, s)
			for k = 0, n - 1 do
				local a = rad(k * (360 / n) + 20)
				B:block(crop, v(0.28 * s, 1.1 * s, 0.28 * s), C * CFrame.new(0, L + 0.6 * s, 0) * CFrame.Angles(0, a, 0) * CFrame.Angles(rad(-35), 0, 0) * CFrame.new(0, 0.3 * s, 0), (k % 2 == 0) and SILK or SILK_DK)
			end
		end

		-- the GIANT golden cob crowning the main stalk
		local CROWNY = 12.4
		do
			local C = cf(0, CROWNY, 0.3, 0, 15, 0)
			local L, W = 7.0, 3.4
			B:block(crop, v(2.6, 0.8, 2.6), C * CFrame.new(0, 0.1, 0), STALK_DK)
			kernels(C * CFrame.new(0, 0.4, 0), L, W, 9, {
				{ 0, -0.2, 0.35 }, { 0, 0.22, 0.62 }, { 1, 0.1, 0.48 }, { 2, -0.15, 0.3 }, { 2, 0.2, 0.7 }, { 3, 0.0, 0.55 },
			})
			husks(C, 6, 1.5, 0.3, 2.8, 1.9, 26, { HUSK, HUSK_DK }, 15)
			silk(C * CFrame.new(0, 0.4, 0), L, 5, 1.3)
		end
		-- smaller cobs on the side stalks
		local cobs = {
			-- stalk, height, deg, tilt, length, width
			{ 2, 8.2, 300, 20, 3.8, 1.7 },
			{ 3, 7.8, 60, 20, 3.6, 1.6 },
			{ 4, 7.4, 175, 20, 3.4, 1.5 },
			{ 2, 11.4, 20, 18, 3.0, 1.4 },
		}
		for _, c in cobs do
			local C = orient(stalkPt[c[1]](c[2]), c[3], c[4]) * CFrame.new(0, -0.3, -(c[6] * 0.5 + 0.6))
			kernels(C * CFrame.new(0, 0.3, 0), c[5], c[6], 5, { { 0, -0.2, 0.5 } })
			husks(C, 3, c[6] * 0.42, 0.2, c[5] * 0.5, c[6] * 0.9, 12, { HUSK_DK, HUSK }, 180)
			silk(C * CFrame.new(0, 0.3, 0), c[5], 3, 0.8)
		end

		------------------------------------------------------------------
		-- TASSELS: golden fans on top of the side stalks
		------------------------------------------------------------------
		local tips = {}
		for si, s in stalks do
			if s[7] then
				local top = stalkPt[si](s[3] - 0.3)
				B:bar(crop, top - v(0, 0.3, 0), top + v(0, 2.4, 0), 0.5, 0.5, GOLD)
				for k = 0, 3 do
					local a = rad(k * 90 + si * 30)
					local d = v(math.sin(a), 0, -math.cos(a))
					local mid = top + v(0, 1.4, 0) + d * 1.0
					local tip = mid + d * 0.8 - v(0, 0.9, 0)
					B:bar(crop, top + v(0, 0.6, 0), mid + d * 0.1, 0.4, 0.4, (k % 2 == 0) and GOLD or GOLD_LT)
					B:bar(crop, mid - d * 0.1, tip, 0.34, 0.34, (k % 2 == 0) and GOLD_LT or GOLD)
				end
				table.insert(tips, B:block(crop, v(0.36, 0.36, 0.36), CFrame.new(top + v(0, 2.7, 0)) * CFrame.Angles(rad(45), rad(45), 0), GLINT, { mat = "Neon", name = "TasselGlint" .. si }))
			end
		end
		------------------------------------------------------------------
		-- RIBBON BOW tying the corn shock together
		------------------------------------------------------------------
		do
			local y = RIBY
			local cx, cz = 0.05, 0.05
			B:block(crop, v(3.5, 0.6, 2.7), cf(cx, y, cz, 0, 8, 0), RIB)
			B:block(crop, v(2.7, 0.62, 3.4), cf(cx, y, cz, 0, 8, 0), RIB)
			-- bow at the front
			local fz = cz - 1.75
			B:block(crop, v(0.8, 0.8, 0.6), cf(cx, y, fz, 0, 8, 0), RIB_DK)
			B:block(crop, v(1.5, 1.1, 0.4), cf(cx - 1.0, y + 0.35, fz - 0.05, 0, 8, 22), RIB)
			B:block(crop, v(1.5, 1.1, 0.4), cf(cx + 1.0, y + 0.35, fz - 0.05, 0, 8, -22), RIB)
			B:block(crop, v(0.5, 1.6, 0.3), cf(cx - 0.5, y - 1.0, fz - 0.1, 0, 8, -14), RIB_DK)
			B:block(crop, v(0.5, 1.5, 0.3), cf(cx + 0.55, y - 0.95, fz - 0.1, 0, 8, 16), RIB)
			-- gold medal centre
			B:block(crop, v(0.6, 0.6, 0.2), cf(cx, y, fz - 0.35, 0, 8, 45), GOLD)
		end

		------------------------------------------------------------------
		-- VFX: golden sparkles + one soft warm light
		------------------------------------------------------------------
		B:emitter(tips[1], "sparkle", { name = "GoldSparkle", color = { "#fff6c0", "#ffd23a" }, rate = 5, size = { 0.15, 0.55, 0 } })
		B:emitter(glints[1], "sparkle", { name = "KernelSparkle", color = { "#ffffff", "#ffc23a" }, rate = 4, size = { 0.12, 0.45, 0 } })
		B:emitter(glints[3], "sparkle", { name = "KernelSparkle2", color = { "#ffe27a", "#ffab1f" }, rate = 4, size = { 0.12, 0.45, 0 } })
		local core = B:block(crop, v(0.4, 0.4, 0.4), cf(0, 16.0, 0.3), GOLD_DK, { name = "GlowCore" })
		B:emitter(core, "glow", { name = "HarvestGlow", color = "#ffcf4a", rate = 1.5, size = { 3, 0 } })
		B:light(core, { color = "#ffcf6b", brightness = 1.3, range = 16, name = "HarvestLight" })
	end,
}
