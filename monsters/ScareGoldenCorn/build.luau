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
		-- leaf blades fade green -> gold-green -> straw gold toward the tips
		local LEAF_A = { "#5f9e34", "#7fb23a", "#c9c24a", "#f3d469" }
		local LEAF_B = { "#4f8c2c", "#6aa232", "#b5b440", "#e8c252" }
		local GOLD, GOLD_DK, AMBER, AMBER_DK = "#ffd024", "#e39a14", "#f59a16", "#d9730c"
		local GOLD_LT = "#ffe45c"
		local HUSK, HUSK_DK = "#a9cc4e", "#7fae38"
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
		-- STALKS (corn shock: three chunky stalks pinched together by the bow)
		------------------------------------------------------------------
		local BASEY = 2.2
		local RIBY = 6.3
		local stalks = {
			-- x, z, height, width, splay x, splay z
			{ 0.0, 0.5, 19.2, 2.0, 0.0, 0.3 },
			{ -2.0, -0.5, 15.6, 1.7, -1.3, -0.2 },
			{ 2.0, -0.3, 13.6, 1.6, 1.3, -0.1 },
		}
		local stalkPt = {}
		for si, s in stalks do
			local x0, z0, H, W = s[1], s[2], s[3], s[4]
			local function at(y)
				local t = math.clamp((y - BASEY) / (H - BASEY), 0, 1)
				-- pinched together at the ribbon, splaying out above it
				local pinch = math.clamp(1 - math.abs(y - RIBY) / 4.5, 0, 1)
				local up = math.clamp((y - RIBY) / (H - RIBY), 0, 1)
				local k = 1 - 0.45 * pinch
				return v(x0 * k + s[5] * up * up * 1.8, y, z0 * k + s[6] * up * up * 1.8)
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
				local w = W * (1 - 0.35 * (y0 - BASEY) / (H - BASEY))
				B:beam(crop, at(y0), at(y1 + 0.1), w, w, (n % 2 == 0) and STALK_LT or STALK)
				if n < #cuts - 1 then
					local p = at(y1)
					B:block(crop, v(w + 0.3, 0.35, w + 0.3), cf(p.X, p.Y, p.Z, 0, 10 * si, 0), STALK_DK)
				end
			end
			local p0 = at(BASEY)
			B:block(crop, v(W + 0.6, 0.5, W + 0.6), cf(p0.X, BASEY + 0.1, p0.Z, 0, 20 * si, 0), STALK_DK)
		end

		------------------------------------------------------------------
		-- LEAVES: broad arching straw-gold blades (up, out, then drooping)
		------------------------------------------------------------------
		local function leafBlade(p, deg, len, w, pal, rise)
			local pitches = { 42 + rise, 8 + rise * 0.5, -34 }
			local seg = len / #pitches
			local a = rad(deg)
			local dir = v(math.sin(a), 0, -math.cos(a))
			local cur = p
			for i, pt in pitches do
				local pr = rad(pt)
				local nxt = cur + dir * (math.cos(pr) * seg) + v(0, math.sin(pr) * seg, 0)
				local d = (nxt - cur).Unit
				local ww = w * (1 - 0.2 * (i - 1))
				B:beam(crop, cur - d * 0.3, nxt + d * 0.3, ww, 0.5, pal[i + 1])
				cur = nxt
			end
			return cur
		end
		local leaves = {
			-- stalk, height, deg, len, width, palette, rise
			{ 1, 4.4, 165, 7.4, 1.7, LEAF_A, 0 },
			{ 1, 4.2, 20, 7.0, 1.7, LEAF_B, 0 },
			{ 1, 8.6, 120, 7.0, 1.6, LEAF_B, 6 },
			{ 1, 11.8, 245, 6.6, 1.5, LEAF_A, 8 },
			{ 1, 15.0, 330, 5.6, 1.3, LEAF_B, 12 },
			{ 1, 17.0, 150, 4.6, 1.15, LEAF_A, 16 },
			{ 2, 4.8, 275, 7.0, 1.6, LEAF_A, 0 },
			{ 2, 11.0, 300, 5.8, 1.4, LEAF_B, 8 },
			{ 3, 4.6, 90, 6.8, 1.6, LEAF_B, 0 },
			{ 3, 10.4, 50, 5.4, 1.4, LEAF_A, 8 },
			{ 1, 6.8, 220, 6.2, 1.5, LEAF_A, 2 },
		}
		for _, l in leaves do
			leafBlade(stalkPt[l[1]](l[2]), l[3] + jit(5), l[4], l[5], l[6], l[7])
		end

		------------------------------------------------------------------
		-- GOLDEN COBS: stepped amber/gold kernel rows, gem glints, husks, silk
		------------------------------------------------------------------
		local glints = {}
		local function cob(p, deg, tilt, L, W)
			local C = orient(p, deg, tilt) * CFrame.new(0, -0.2, -(W * 0.5 + 0.55))
			B:block(crop, v(W, L, W), C * CFrame.new(0, L * 0.5, 0), GOLD)
			local rows = 6
			for r = 0, rows - 1 do
				local t = r / (rows - 1)
				local ww = (W + 0.32) * (1 - 0.28 * t)
				B:block(crop, v(ww, 0.52, ww), C * CFrame.new(0, L * (0.14 + 0.76 * t), 0), (r % 2 == 0) and GOLD_LT or GOLD)
			end
			B:block(crop, v(W * 0.62, 0.55, W * 0.62), C * CFrame.new(0, L + 0.2, 0), GOLD_LT)
			-- gem kernels glinting on the outward face
			local fz = -(W * 0.5 + 0.05)
			table.insert(glints, B:block(crop, v(0.36, 0.36, 0.14), C * CFrame.new(-W * 0.22, L * 0.5, fz), GLINT, { mat = "Neon", name = "KernelGlint" }))
			B:block(crop, v(0.3, 0.3, 0.14), C * CFrame.new(W * 0.24, L * 0.72, fz + 0.02), "#ffa81f", { mat = "Neon", name = "KernelGem" })
			-- husks peeling open around the base (sides + back)
			for _, hd in { { -1, 0, HUSK, 1 }, { 1, 0, HUSK_DK, 1 }, { 0, 1, HUSK, 0.9 } } do
				local sx = hd[2] == 0 and 0.34 or W * 1.0
				local sz = hd[2] == 0 and W * 1.0 or 0.34
				local hc = C * CFrame.new(hd[1] * (W * 0.5 + 0.12), L * 0.28, hd[2] * (W * 0.5 + 0.12))
					* CFrame.Angles(rad(hd[2] * 16), 0, rad(-hd[1] * 18))
				B:block(crop, v(sx, L * 0.62 * hd[4], sz), hc, hd[3])
			end
			-- silk tuft at the tip
			for k, sd in { { 0.15, -28, -18, SILK }, { -0.15, -18, 26, SILK_DK }, { 0, 10, 0, SILK } } do
				B:block(crop, v(0.26, 1.0, 0.26), C * CFrame.new(sd[1], L + 0.85, 0) * CFrame.Angles(rad(sd[2]), 0, rad(sd[3])), sd[4])
			end
		end
		local cobs = {
			-- stalk, height, deg, tilt, length, width
			{ 1, 9.4, 0, 18, 4.8, 2.0 },
			{ 1, 13.0, 195, 18, 4.2, 1.8 },
			{ 2, 8.0, 295, 22, 4.2, 1.8 },
			{ 3, 7.4, 65, 22, 4.0, 1.75 },
			{ 1, 12.2, 95, 18, 3.6, 1.6 },
		}
		for _, c in cobs do
			cob(stalkPt[c[1]](c[2]), c[3], c[4], c[5], c[6])
		end

		------------------------------------------------------------------
		-- TASSELS: golden fans on top of each stalk
		------------------------------------------------------------------
		local tips = {}
		for si, s in stalks do
			local top = stalkPt[si](s[3] - 0.3)
			B:beam(crop, top - v(0, 0.3, 0), top + v(0, 2.6, 0), 0.5, 0.5, GOLD)
			local n = 4
			for k = 0, n - 1 do
				local a = rad(k * (360 / n) + si * 30)
				local d = v(math.sin(a), 0, -math.cos(a))
				local mid = top + v(0, 1.5, 0) + d * 1.1
				local tip = mid + d * 0.9 - v(0, 0.9, 0)
				B:beam(crop, top + v(0, 0.7, 0), mid + d * 0.1, 0.4, 0.4, (k % 2 == 0) and GOLD or GOLD_LT)
				B:beam(crop, mid - d * 0.1, tip, 0.34, 0.34, (k % 2 == 0) and GOLD_LT or GOLD)
			end
			table.insert(tips, B:block(crop, v(0.36, 0.36, 0.36), CFrame.new(top + v(0, 2.9, 0)) * CFrame.Angles(rad(45), rad(45), 0), GLINT, { mat = "Neon", name = "TasselGlint" .. si }))
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
		B:emitter(glints[4], "sparkle", { name = "KernelSparkle2", color = { "#ffe27a", "#ffab1f" }, rate = 4, size = { 0.12, 0.45, 0 } })
		local core = B:block(crop, v(0.4, 0.4, 0.4), cf(0, 11.5, 0.2), STALK, { name = "GlowCore" })
		B:emitter(core, "glow", { name = "HarvestGlow", color = "#ffcf4a", rate = 1.5, size = { 3, 0 } })
		B:light(core, { color = "#ffcf6b", brightness = 1.3, range = 16, name = "HarvestLight" })
	end,
}
