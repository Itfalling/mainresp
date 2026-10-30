--!nocheck
-- Emberseed Pine (Thorny Woods crop #8, Cosmic).
-- A tall, stepped, dark forest pine: a thick dark-bark trunk with flared roots
-- and pale thorns, five tiers of big rotated deep-green needle cubes that step
-- in toward the tip like a pagoda, lighter needle tips drooping at every edge.
-- Chunky stepped pinecones hang under each tier; their scales are split by
-- glowing ember-orange seams and each ends in a hot ember tip. Tiny ember
-- seeds glint between the needles and a big upright golden ember cone crowns
-- the top. Base: stepped dark forest mound with pine-needle litter, moss,
-- stones, thorny twigs, small mushrooms and a fallen glowing cone.
-- Faint rising ember motes + one soft warm light. Static prop: no motion.luau.
return {
	DisplayName = "Emberseed Pine",
	Rarity = "Cosmic",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#35221a", "#43291c", "#5a3a26", "#744c31"
		local MOSS, MOSS_DK, MOSS_LT = "#5aa236", "#3f7f2a", "#86c94a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#857f78", "#a19a90", "#625d58"
		local NEEDLE_LIT, NEEDLE_LIT2 = "#a0522a", "#7e3f22"
		local TWIG = "#4a3020"
		local THORN, THORN_TIP = "#e6d6ae", "#8a2232"
		local BARK_DK, BARK, BARK_LT = "#2e1f17", "#432d20", "#5a3d2b"
		local PINE_DK, PINE, PINE_LT, PINE_HI = "#1f5233", "#29683d", "#357d48", "#489457"
		local TIP, TIP_LT = "#56a660", "#78c070"
		local CONE_DK, CONE, CONE_LT = "#5a2e18", "#7c4220", "#9c5a2c"
		local EMBER, EMBER_HOT = "#ff7a1a", "#ffb43a"
		local GOLD, GOLD_DK, GOLD_LT = "#e0a030", "#b8781e", "#ffd060"
		local SHROOM, SHROOM_CAP = "#efe2c4", "#c8262a"
		local NEON = { mat = "Neon" }

		local seed = 8138
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

		---------------------------------------------------------------- mound
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
		tier(0, 0.8, 6.6, DIRT_DK, 18, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.6, 4.6, DIRT, 12, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.4, 0.45, 2.8, DIRT_LT, 0, {}, 0)
		local TOP = 1.85

		for _, m in { { -40, 6.55, 1.12, 2.3, MOSS }, { 60, 6.45, 1.1, 2.0, MOSS_DK }, { 150, 6.6, 1.1, 2.0, MOSS }, { 240, 6.45, 1.12, 2.1, MOSS_DK }, { 20, 4.5, 1.72, 1.6, MOSS_LT }, { 200, 4.55, 1.72, 1.5, MOSS } } do
			local c = polar(CFrame.new(), m[1], m[3], m[2])
			B:block(soil, v(m[4], 0.3, 1.3), c * ang(-12, 0, 0), m[5], S)
		end
		for _, s in { { 5.0, 1.0, -3.4, 0.9, 25, STONE }, { 5.7, 0.9, -2.2, 0.6, 10, STONE_LT }, { -5.4, 0.95, 2.8, 0.85, -20, STONE_DK }, { -3.1, 1.75, 2.9, 0.6, 15, STONE_LT } } do
			B:block(soil, v(s[4] * 1.2, s[4], s[4]), cf(s[1], s[2], s[3], rnd(-10, 10), s[5], rnd(-10, 10)), s[6], S)
		end
		for _, g in { { 6.0, 0.8 }, { -5.9, -1.4 }, { -1.8, 6.0 }, { 4.4, 4.6 } } do
			B:block(soil, v(0.4, 0.9, 0.4), cf(g[1], 0.95, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.3, 0.6, 0.3), cf(g[1] + 0.3, 0.9, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end
		-- fallen pine-needle litter (thin rust strips in little crossed piles)
		for _, l in { { 3.4, 1.42, -2.9 }, { -3.8, 1.42, -2.5 }, { -2.4, 1.42, 3.6 }, { 5.3, 0.82, 2.4 }, { -5.2, 0.82, -3.4 }, { 1.4, 1.87, 2.3 } } do
			local yaw = rnd(0, 180)
			B:block(soil, v(1.3, 0.1, 0.18), cf(l[1], l[2], l[3], 0, yaw, 0), NEEDLE_LIT, S)
			B:block(soil, v(1.1, 0.1, 0.18), cf(l[1] + 0.1, l[2] + 0.04, l[3] + 0.1, 0, yaw + 55, 0), NEEDLE_LIT2, S)
			B:block(soil, v(0.9, 0.1, 0.16), cf(l[1] - 0.1, l[2] + 0.06, l[3], 0, yaw - 40, 0), NEEDLE_LIT, S)
		end
		-- thorny twigs
		local function twig(a, b)
			B:bar(soil, a, b, 0.32, 0.32, TWIG, S)
			local d = b - a
			for k = 1, 3 do
				B:block(soil, v(0.22, 0.22, 0.22), CFrame.new(a + d * (k / 4) + v(0, 0.22, 0)) * ang(45, k * 40, 45), k % 2 == 0 and THORN_TIP or THORN, S)
			end
		end
		twig(v(-5.7, 1.0, -0.4), v(-3.7, 1.55, -1.9))
		twig(v(4.5, 1.0, 3.5), v(2.7, 1.6, 3.9))
		-- small red mushrooms
		for _, m in { { 3.8, 1.4, 1.0, 0.8 }, { -3.8, 1.4, -0.2, 0.7 }, { 1.6, 0.8, -5.8, 0.6 } } do
			local k = m[4]
			local f = cf(m[1], m[2], m[3], rnd(-8, 8), rnd(0, 90), rnd(-8, 8))
			B:block(soil, v(0.35 * k, 0.9 * k, 0.35 * k), f * CFrame.new(0, 0.45 * k, 0), SHROOM, S)
			B:block(soil, v(1.0 * k, 0.4 * k, 1.0 * k), f * CFrame.new(0, 1.0 * k, 0), SHROOM_CAP, S)
			B:block(soil, v(0.25 * k, 0.12 * k, 0.25 * k), f * CFrame.new(0.2 * k, 1.24 * k, -0.15 * k), SHROOM, S)
		end

		---------------------------------------------------------------- trunk
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		round(crop, cf(0, TOP + 0.3, 0, 0, 15, 0), 1.9, 0.8, BARK_DK)
		B:block(crop, v(2.8, 2.6, 2.8), cf(0, TOP + 1.9, 0, 0, 0, 0), BARK)
		B:block(crop, v(2.4, 3.6, 2.4), cf(0.05, TOP + 4.6, 0, 0, 10, 0), BARK_LT)
		B:block(crop, v(2.0, 4.0, 2.0), cf(0.1, TOP + 8.2, 0, 0, 4, 0), BARK)
		B:block(crop, v(1.6, 4.0, 1.6), cf(0.05, TOP + 12.0, 0, 0, 12, 0), BARK_LT)
		B:block(crop, v(1.2, 3.6, 1.2), cf(0, TOP + 15.6, 0, 0, 6, 0), BARK)
		-- bark grooves
		for _, n in { { 1.42, 1.5, 0.3 }, { -1.42, 2.4, -0.4 }, { 0.3, 3.0, -1.42 }, { -0.4, 2.2, 1.42 }, { 1.22, 4.4, -0.3 }, { -1.22, 4.9, 0.4 } } do
			local sx = math.abs(n[1]) > 1 and 0.3 or 0.7
			local sz = math.abs(n[3]) > 1 and 0.3 or 0.7
			B:block(crop, v(sx, 1.1, sz), cf(n[1], TOP + n[2], n[3]), BARK_DK)
		end
		-- flared roots
		for _, r in { 30, 120, 210, 300 } do
			local a = rad(r)
			local dx, dz = math.sin(a), -math.cos(a)
			B:bar(crop, v(dx * 0.9, TOP + 1.6, dz * 0.9), v(dx * 2.8, TOP - 0.3, dz * 2.8), 0.9, 0.8, BARK)
			B:block(crop, v(1.0, 0.5, 1.0), CFrame.new(v(dx * 2.9, TOP - 0.25, dz * 2.9)) * ang(0, r, 0), BARK_DK)
		end
		-- pale thorns on the visible trunk
		for _, t in { { 0, 2.6 }, { 95, 3.4 }, { 185, 2.2 }, { 270, 3.9 }, { 140, 1.5 } } do
			local q = polar(CFrame.new(0, TOP, 0), t[1], t[2], 1.35)
			B:block(crop, v(0.3, 0.3, 0.6), q * CFrame.new(0, 0, -0.2) * ang(20, 0, 45), THORN)
			B:block(crop, v(0.17, 0.17, 0.3), q * CFrame.new(0, 0.12, -0.55) * ang(20, 0, 45), THORN_TIP)
		end

		---------------------------------------------------------------- needle tiers
		local cubes = {} -- rim blocks (cones hang under them)
		local tops = {} -- upper-surface spots (ember seeds sit there)
		local tiers = {
			-- y, radius, rim block count, angle offset
			{ 5.7, 5.9, 13, 0 },
			{ 8.6, 4.85, 11, 18 },
			{ 11.4, 3.9, 9, 7 },
			{ 14.1, 3.0, 7, 25 },
			{ 16.7, 2.15, 6, 10 },
			{ 19.1, 1.45, 5, 36 },
		}
		for ti, t in tiers do
			local yb, R, n, off = t[1], t[2], t[3], t[4]
			local base = CFrame.new(0, yb, 0) * ang(0, off, 0)
			local sc = math.clamp(R / 5.9, 0.45, 1)
			-- stepped skirt: dark underside, mid step, light cap
			round(crop, base, R * 0.86, 0.95, PINE_DK)
			round(crop, base * CFrame.new(0, 0.85, 0) * ang(0, 45, 0), R * 0.66, 0.8, PINE)
			round(crop, base * CFrame.new(0, 1.5, 0), R * 0.42, 0.6, PINE_LT)
			-- chunky drooping rim blocks with needle tips
			for i = 0, n - 1 do
				local a = (i + rnd(-0.15, 0.15)) / n * 360
				local w = 2 * math.pi * R / n * rnd(0.9, 1.1)
				local c = polar(base, a, -0.1 + rnd(-0.12, 0.12), R - 0.35) * ang(-20 + rnd(-5, 5), rnd(-6, 6), 0)
				local col = (i % 2 == 0) and PINE or PINE_DK
				local hh = 1.25 * (0.75 + 0.25 * sc)
				B:block(crop, v(w, hh, 1.5 * (0.7 + 0.3 * sc)), c, col)
				table.insert(cubes, { cf = c, w = w, h = hh, d = 1.5, ti = ti, a = a })
				if i % 2 == 0 then
					B:block(crop, v(w * 0.55, hh * 0.6, 0.7), c * CFrame.new(rnd(-0.15, 0.15) * w, -hh * 0.3, -0.75) * ang(-22, 0, 0), (i % 4 == 0) and TIP or PINE_HI)
				end
			end
			-- fresh light-green growth on the step tops
			for i = 0, (ti <= 3) and 2 or 1 do
				local a = off + 40 + i * (360 / ((ti <= 3) and 3 or 2)) + rnd(-15, 15)
				local q = polar(CFrame.new(0, yb, 0), a, 1.3, R * 0.62)
				local z = 1.0 * (0.6 + 0.4 * sc)
				B:block(crop, v(z * 1.3, 0.6, z), q * ang(0, rnd(0, 60), 0), (i % 2 == 0) and TIP_LT or PINE_HI)
				table.insert(tops, q)
			end
		end
		-- tip
		B:block(crop, v(1.4, 1.2, 1.4), cf(0, 20.7, 0, 0, 20, 0), PINE)
		B:block(crop, v(0.95, 0.9, 0.95), cf(0, 21.6, 0, 0, 40, 0), PINE_LT)

		---------------------------------------------------------------- pinecones
		local glows = {}
		local function pinecone(top, k, ry, gold, goldHang)
			-- top = attachment point; cone hangs below (gold = upright crown cone)
			local up = gold and 1 or -1
			local f = CFrame.new(top) * ang(rnd(-6, 6), ry, rnd(-6, 6))
			local cD, cM, cL = CONE_DK, CONE, CONE_LT
			if gold or goldHang then cD, cM, cL = GOLD_DK, GOLD, GOLD_LT end
			B:block(crop, v(0.3 * k, 0.5 * k, 0.3 * k), f * CFrame.new(0, up * 0.15 * k, 0), BARK_DK)
			-- glowing core visible between the scale rows
			local core = B:block(crop, v(0.92 * k, 2.0 * k, 0.92 * k), f * CFrame.new(0, up * 1.4 * k, 0) * ang(0, 22, 0), gold and EMBER_HOT or EMBER, { mat = "Neon", name = "ConeCore" })
			table.insert(glows, core)
			local rows = { { 0.9, 0.5, cL }, { 1.25, 0.92, cM }, { 1.4, 1.38, cD }, { 1.25, 1.84, cM }, { 0.95, 2.26, cD } }
			for j, rr in rows do
				local w = rr[1] * k
				B:block(crop, v(w, 0.28 * k, w), f * CFrame.new(0, up * rr[2] * k, 0) * ang(0, (j % 2) * 45, 0), rr[3])
			end
			B:block(crop, v(0.35 * k, 0.3 * k, 0.35 * k), f * CFrame.new(0, up * 2.55 * k, 0) * ang(0, 45, 0), gold and "#fff2b0" or EMBER_HOT, NEON)
		end
		-- hang cones under the rims (tiers 1-4), spaced around; every 4th is a rare golden one
		local nCone = 0
		for ci, c in cubes do
			local ok = (c.ti == 1 and ci % 3 == 0) or (c.ti == 2 and ci % 2 == 0) or (c.ti == 3 and ci % 2 == 1) or (c.ti == 4 and ci % 3 == 1)
			if ok then
				local p = c.cf * CFrame.new(rnd(-0.15, 0.15) * c.w, -c.h * 0.45, 0.1)
				local k = ({ 0.95, 0.85, 0.74, 0.62 })[c.ti]
				nCone += 1
				pinecone(p.Position, k * rnd(0.95, 1.04), rnd(0, 90), false, nCone % 4 == 2)
			end
		end
		-- golden ember cone crowning the spire
		pinecone(v(0, 21.9, 0), 0.66, 0, true)
		-- fallen glowing cone on the mound
		do
			local f = cf(2.9, 1.65, -2.4, 0, 30, 80)
			B:block(soil, v(0.75, 1.7, 0.75), f * ang(0, 22, 0), EMBER, { mat = "Neon", name = "Soil" })
			for j, rr in { { 1.0, -0.6, CONE }, { 1.15, 0.0, CONE_DK }, { 0.95, 0.6, CONE } } do
				B:block(soil, v(rr[1], 0.3, rr[1]), f * CFrame.new(0, rr[2], 0) * ang(0, (j % 2) * 45, 0), rr[3], S)
			end
		end

		---------------------------------------------------------------- ember seeds in the needles
		local seeds = 0
		for ti, t in tiers do
			if ti <= 5 then
				for i = 0, 2 do
					local a = t[4] + 100 + i * 120 + rnd(-20, 20)
					local q = polar(CFrame.new(0, t[1], 0), a, 0.62, t[2] * 0.78)
					B:block(crop, v(0.42, 0.42, 0.42), q * ang(45, rnd(0, 90), 45), (seeds % 2 == 0) and EMBER_HOT or EMBER, { mat = "Neon", name = "EmberSeed" })
					seeds += 1
				end
			end
		end

		---------------------------------------------------------------- vfx
		local cloud = B:block(crop, v(10, 14, 10), cf(0, 13, 0), PINE, { tr = 1, name = "EmberCloud" })
		B:emitter(cloud, "ember", { name = "EmberMotes", color = { EMBER_HOT, EMBER }, rate = 4, size = { 0.18, 0.12, 0 }, speed = { 0.3, 0.9 }, life = { 1.8, 3.0 }, accel = { 0, 0.6, 0 } })
		B:emitter(glows[#glows], "sparkle", { name = "CrownTwinkle", color = { "#ffffff", GOLD_LT }, rate = 3, size = 0.35 })
		B:emitter(glows[2], "glow", { name = "ConeGlow", color = EMBER, rate = 2, size = 0.8 })
		B:light(glows[3] or glows[1], { color = "#ff9a40", brightness = 1.3, range = 13, name = "EmberLight" })
	end,
}
