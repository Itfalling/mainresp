--!nocheck
-- Heartwood Thorn Oak (Thorny Woods crop #10, Apex): the showpiece of the
-- enchanted thorn forest. A colossal ancient oak in the stud-tree style:
-- * a big stepped mossy mound (bone "Soil") with chunky edge blocks, moss
--   pads, stones, toadstools, fallen leaves, rose petals, thorny twigs, a
--   little briar rose bush and a fallen heart-fruit
-- * a massive twisted dark-bark trunk (bone "Crop") with gnarled roots, bark
--   ridges and two thorny briar vines (cream thorns, crimson roses) wound
--   around it; a hollow in the front holds the glowing rose-gold HEARTWOOD
-- * a huge three-tier layered canopy of big rotated studded leaf cubes
--   ("Canopy" + "CanopyTop" bones, so the crown can sway with a little lag),
--   dotted with briar roses and half-sunk heart-fruits, crowned by a big
--   rose-gold heart-fruit in a golden leaf collar
-- * six rose-gold heart-fruits hang under the canopy on stems (HeartN bones,
--   pivot at the stem top) and four briar tendrils dangle from the branch
--   tips (VineNa -> VineNb chains)
-- * falling leaves, drifting rose petals, golden motes, heart glows and one
--   warm light (motion.luau: subtle sway / swing / ripple / glow pulse)
-- Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Heartwood Thorn Oak",
	Rarity = "Apex",
	Element = "Nature",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ----------------------------------------------------------
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3b2416", "#4a2c1a", "#65402a", "#7f5535"
		local MOSS, MOSS_DK, MOSS_LT = "#5fa83a", "#3f7f2c", "#86c94a"
		local GRASS, GRASS_DK = "#57c23d", "#3a9a30"
		local STONE, STONE_LT, STONE_DK = "#8f8a80", "#aaa497", "#6e6a62"
		local BARK_BK, BARK_DK, BARK, BARK_LT = "#160d08", "#2b1a10", "#3d2516", "#56361f"
		local VINE, VINE_DK = "#4f7a2a", "#365a20"
		local THORN = "#ecdfb8"
		local LF_DK, LF, LF_MID, LF_LT, LF_LIME = "#1d6a35", "#26803e", "#33984a", "#52b457", "#8bd45e"
		local ROSE, ROSE_DK, ROSE_LT = "#d8203e", "#9a1430", "#ff5a77"
		local RG, RG_DK, RG_LT = "#f47a8a", "#c94a60", "#ffc6bc" -- rose-gold heart-fruit
		local GOLD, GOLD_LT = "#f2b844", "#ffe08a"
		local GLOW = "#ffd79a"
		local MUSH, MUSH_SPOT, MUSH_STEM = "#d0343c", "#fff1dc", "#efe2c6"
		local TWIG = "#4a3020"
		local PETAL = "#ff8fa6"
		local BLOSSOM, BLOSSOM_LT = "#f590ad", "#ffc2d4"

		local seed = 1010
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
		-- CFrame whose local -Z faces outward along polar `deg`
		local function facing(p, deg)
			return CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
		end

		------------------------------------------------------------------
		-- HEART-FRUIT: rotated-cube voxel heart in frame F (front = local -Z)
		-- total ~1.9s tall x 1.9s wide; returns the neon core part
		------------------------------------------------------------------
		local function heart(bone, F, s, coreName, opts)
			opts = opts or {}
			local d = (opts.depth or 0.8) * s
			B:block(bone, v(0.8 * s, 0.8 * s, d * 0.94), F * CFrame.new(-0.4 * s, 0.22 * s, 0) * ang(0, 0, 45), RG)
			B:block(bone, v(0.8 * s, 0.8 * s, d * 0.94), F * CFrame.new(0.4 * s, 0.22 * s, 0) * ang(0, 0, 45), RG)
			B:block(bone, v(1.1 * s, 1.1 * s, d), F * CFrame.new(0, -0.35 * s, 0) * ang(0, 0, 45), RG_DK)
			-- lighter facet + glowing core on the front
			B:block(bone, v(0.42 * s, 0.42 * s, 0.12), F * CFrame.new(-0.45 * s, 0.3 * s, -d * 0.47 - 0.04) * ang(0, 0, 45), RG_LT)
			local core = B:block(bone, v(0.5 * s, 0.5 * s, 0.14), F * CFrame.new(0.05 * s, -0.3 * s, -d * 0.5 - 0.06) * ang(0, 0, 45), GLOW,
				{ mat = "Neon", name = coreName })
			if not opts.noBack then
				B:block(bone, v(0.5 * s, 0.5 * s, 0.14), F * CFrame.new(0.05 * s, -0.3 * s, d * 0.5 + 0.06) * ang(0, 0, 45), GLOW,
					{ mat = "Neon", name = coreName .. "B" })
			end
			-- golden cap in the notch
			B:block(bone, v(0.5 * s, 0.3 * s, 0.5 * s), F * CFrame.new(0, 0.55 * s, 0) * ang(0, 45, 0), GOLD)
			return core
		end

		------------------------------------------------------------------
		-- STEPPED MOSSY MOUND (bone "Soil", every part named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(y0, y1, w, color)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(soil, v(w, h, w * 0.62), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.62, h + 0.02, w), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.85, h - 0.03, w * 0.85), cf(0, y, 0), color, S)
		end
		oct(0, 1.1, 17.6, DIRT_DK)
		oct(1.1, 2.1, 13.4, DIRT)
		oct(2.1, 2.8, 8.8, DIRT_LT)
		for i = 0, 15 do
			local a = i * 22.5 + jit(5)
			local x, z = polar(8.5 + jit(0.3), a)
			local h = 1.0 + rnd() * 0.7
			B:block(soil, v(2.7 + rnd() * 0.8, h, 2.0 + rnd() * 0.5), cf(x, h / 2, z, 0, -a + jit(10), 0),
				i % 3 == 0 and DIRT or (i % 2 == 0 and DIRT_DK2 or DIRT_DK), S)
		end
		for i = 0, 8 do
			local a = i * 40 + 15 + jit(8)
			local x, z = polar(6.4 + jit(0.3), a)
			local h = 0.8 + rnd() * 0.4
			B:block(soil, v(2.2 + rnd() * 0.5, h, 1.6), cf(x, 1.1 + h / 2, z, 0, -a + jit(12), 0), i % 2 == 0 and DIRT or DIRT_DK2, S)
		end
		-- moss pads over the tier edges
		for _, m in { { 15, 8.6, 1.15, 2.6, MOSS }, { 80, 8.5, 1.15, 2.2, MOSS_DK }, { 140, 8.6, 1.15, 2.4, MOSS }, { 205, 8.5, 1.15, 2.6, MOSS_DK },
			{ 265, 8.6, 1.15, 2.0, MOSS_LT }, { 320, 8.5, 1.15, 2.4, MOSS }, { 55, 6.4, 2.15, 1.8, MOSS }, { 180, 6.4, 2.15, 2.0, MOSS_LT },
			{ 290, 6.4, 2.15, 1.8, MOSS_DK } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], m[3], -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[4], 0.32, 1.4), c * ang(-14, 0, 0), m[5], S)
		end
		-- stones
		for _, s in { { 7.4, 1.25, -2.6, 1.0, 25, STONE }, { 7.9, 1.1, -1.2, 0.65, 10, STONE_LT }, { -7.2, 1.2, 3.4, 0.9, -20, STONE_DK }, { 3.0, 1.1, 7.2, 0.8, 40, STONE }, { -2.6, 2.4, 3.5, 0.6, 15, STONE_LT } } do
			B:block(soil, v(s[4] * 1.25, s[4], s[4]), cf(s[1], s[2], s[3], 0, s[5], jit(6)), s[6], S)
		end
		-- grass tufts
		for _, g in { { 9.0, 1.6 }, { 4.8, -7.4 }, { -8.9, -1.4 }, { -3.8, 7.6 }, { 6.9, 5.2 } } do
			B:block(soil, v(0.5, 1.0, 0.5), cf(g[1], 0.5, g[2], 0, jit(30), 0), GRASS, S)
			B:block(soil, v(0.4, 0.7, 0.4), cf(g[1] + 0.35, 0.35, g[2] + 0.25, 0, jit(30), 0), GRASS_DK, S)
		end
		-- toadstools
		for _, m in { { -6.2, 1.1, -4.6, 1.0 }, { -7.0, 1.1, -3.7, 0.7 }, { 6.0, 2.1, 3.4, 0.85 }, { -4.6, 2.1, 4.8, 0.6 } } do
			local s = m[4]
			B:block(soil, v(0.45 * s, 1.0 * s, 0.45 * s), cf(m[1], m[2] + 0.5 * s, m[3]), MUSH_STEM, S)
			B:block(soil, v(1.3 * s, 0.5 * s, 1.3 * s), cf(m[1], m[2] + 1.1 * s, m[3], 0, 20, 0), MUSH, S)
			B:block(soil, v(0.8 * s, 0.3 * s, 0.8 * s), cf(m[1], m[2] + 1.45 * s, m[3], 0, 20, 0), MUSH, S)
			B:block(soil, v(0.3, 0.12, 0.3), cf(m[1] + 0.3 * s, m[2] + 1.36 * s, m[3] - 0.45 * s, 0, 20, 0), MUSH_SPOT, S)
		end
		-- fallen leaves + rose petals scattered on the tiers
		for _, l in { { 3.6, 2.8, -3.0, LF_LT }, { -5.2, 2.1, -2.6, LF_MID }, { 5.6, 2.1, -0.2, LF }, { -1.0, 2.8, 3.9, LF_LIME }, { -7.6, 1.1, 1.2, LF_LT } } do
			B:block(soil, v(1.0, 0.16, 0.7), cf(l[1], l[2] + 0.08, l[3], 0, rnd() * 180, 0), l[4], S)
		end
		for _, l in { { -2.2, 2.8, -3.6 }, { 1.5, 2.8, -3.8 }, { 4.6, 2.1, 2.5 }, { -6.0, 2.1, 0.6 }, { 0.6, 1.1, -8.0 } } do
			B:block(soil, v(0.5, 0.12, 0.45), cf(l[1], l[2] + 0.06, l[3], 0, rnd() * 180, 0), PETAL, S)
		end
		-- thorny twigs
		for _, t in { { v(4.2, 2.85, 3.4), v(6.8, 2.15, 5.2) }, { v(-4.6, 2.15, -4.0), v(-7.2, 1.15, -5.0) } } do
			B:bar(soil, t[1], t[2], 0.3, 0.3, TWIG, S)
			local mid = t[1]:Lerp(t[2], 0.5)
			B:bar(soil, mid, mid + v(0, 0.55, 0.15), 0.16, 0.16, THORN, S)
		end
		-- a fallen heart-fruit at the front
		heart(soil, CFrame.new(-3.3, 3.55, -3.4) * ang(-10, 25, -18), 0.7, "FallenGlow", { noBack = true })
		-- little briar rose bush at the front right
		B:block(soil, v(1.7, 1.5, 1.7), cf(4.8, 2.8, -4.4, 0, 30, 0), LF, S)
		B:block(soil, v(1.3, 1.2, 1.3), cf(5.6, 3.1, -3.7, 10, 10, 0), LF_MID, S)
		B:block(soil, v(0.8, 0.6, 0.8), cf(4.6, 3.85, -4.6, 0, 45, 0), ROSE, S)
		B:block(soil, v(0.4, 0.35, 0.4), cf(4.6, 4.2, -4.6), ROSE_LT, S)
		B:block(soil, v(0.7, 0.55, 0.7), cf(5.8, 3.95, -3.6, 0, 20, 0), ROSE_DK, S)

		------------------------------------------------------------------
		-- TWISTED TRUNK (bone "Crop")
		------------------------------------------------------------------
		local BASE = 2.8
		local crop = B:bone("Crop", "Root", v(0, BASE, 0))
		-- root flare
		B:block(crop, v(7.0, 1.0, 7.0), cf(0, BASE + 0.35, 0, 0, 12, 0), BARK_DK)
		B:block(crop, v(6.4, 1.0, 6.4), cf(0, BASE + 1.2, 0, 0, -10, 0), BARK)
		-- gnarled roots running down the mound
		for k = 0, 5 do
			local a = k * 60 + 30 + jit(8)
			local x1, z1 = polar(3.0, a)
			local x2, z2 = polar(5.1, a + 10)
			local x3, z3 = polar(6.6, a + 18)
			B:bar(crop, v(x1, BASE + 1.0, z1), v(x2, BASE - 0.15, z2), 1.7, 1.2, (k % 2 == 0) and BARK or BARK_DK)
			B:bar(crop, v(x2, BASE - 0.05, z2), v(x3, 1.5, z3), 1.05, 0.85, BARK_DK)
		end
		-- trunk segments: thick and slightly S-curved; the hollow segments stay square to the front
		local SEG = {
			-- width, y0, x offset, yaw, colour
			{ 5.8, 1.6, 0.0, 6, BARK },
			{ 5.4, 3.6, 0.1, 0, BARK_DK },
			{ 5.1, 5.6, 0.1, 0, BARK },
			{ 4.9, 7.6, 0.05, 0, BARK_DK },
			{ 4.5, 9.4, -0.15, 14, BARK },
			{ 4.1, 11.2, -0.35, 28, BARK_DK },
			{ 3.7, 12.8, -0.3, 42, BARK },
		}
		local function halfW(y)
			local w = 5.0
			for _, s in SEG do
				if y >= BASE + s[2] - 0.01 then
					w = s[1]
				end
			end
			return w / 2
		end
		for _, s in SEG do
			local h = 2.2
			B:block(crop, v(s[1], h, s[1]), cf(s[3], BASE + s[2] + h / 2, 0, 0, s[4], 0), s[5])
		end
		-- bark ridges twisting up the sides (kept off the front so the hollow stays clear)
		for _, a0 in { 52, 130, 210, 300 } do
			local prev
			for i = 0, 3 do
				local t = i / 3
				local y = BASE + 1.8 + t * 11.4
				local a = a0 + t * 40
				local x, z = polar(halfW(y) * 1.05 + 0.05, a)
				local p = v(x, y, z)
				if prev then
					B:bar(crop, prev, p, 0.9, 0.7, BARK_LT)
				end
				prev = p
			end
		end
		-- THE HEARTWOOD HOLLOW (front face, z = -2.2)
		local HY = BASE + 6.4
		local FZ = -2.55
		B:block(crop, v(2.4, 3.0, 0.4), cf(0, HY, FZ - 0.05), BARK_BK) -- dark hollow
		B:block(crop, v(0.7, 3.8, 0.8), cf(-1.5, HY, FZ - 0.2, 0, 0, -4), BARK_LT) -- lips
		B:block(crop, v(0.7, 3.6, 0.8), cf(1.5, HY + 0.1, FZ - 0.2, 0, 0, 5), BARK_LT)
		B:block(crop, v(3.4, 0.7, 0.9), cf(0, HY + 1.85, FZ - 0.2, 0, 0, 3), BARK_LT)
		B:block(crop, v(3.2, 0.6, 1.1), cf(0, HY - 1.75, FZ - 0.25), BARK_LT)
		B:block(crop, v(2.2, 0.3, 1.0), cf(0.2, HY - 1.4, FZ - 0.35), MOSS) -- mossy sill
		local hwCore = heart(crop, CFrame.new(0, HY - 0.05, FZ - 0.55), 1.15, "HeartwoodCore", { noBack = true, depth = 0.7 })
		-- moss patches on the bark
		for _, m in { { 200, 4.0, 1.7 }, { 110, 9.0, 1.4 }, { 250, 11.6, 1.3 } } do
			local x, z = polar(halfW(BASE + m[2]) + 0.15, m[1])
			B:block(crop, v(m[3], 0.9, 0.5), facing(v(x, BASE + m[2], z), m[1]), MOSS)
			B:block(crop, v(m[3] * 0.6, 0.4, 0.55), facing(v(x, BASE + m[2] + 0.6, z), m[1]), MOSS_LT)
		end

		-- briar vines wound around the trunk
		local thornFlip = 1
		local function thorn(bone, p, dir)
			dir = dir.Unit
			B:bar(bone, p + dir * 0.2, p + dir * 1.15, 0.28, 0.28, THORN)
		end
		local function rose(bone, p, s, yaw)
			local c = CFrame.new(p) * ang(0, yaw or 0, 0)
			B:block(bone, v(1.3 * s, 0.35 * s, 1.3 * s), c * CFrame.new(0, -0.45 * s, 0) * ang(0, 45, 0), LF_DK)
			B:block(bone, v(1.15 * s, 0.8 * s, 1.15 * s), c, ROSE_DK)
			B:block(bone, v(0.95 * s, 0.75 * s, 0.95 * s), c * CFrame.new(0, 0.3 * s, 0) * ang(0, 45, 0), ROSE)
			B:block(bone, v(0.45 * s, 0.4 * s, 0.45 * s), c * CFrame.new(0, 0.62 * s, 0), ROSE_LT)
		end
		local function helix(deg0, turns, y0, y1, n)
			local pts = {}
			for i = 0, n do
				local t = i / n
				local y = y0 + (y1 - y0) * t
				local deg = deg0 + turns * 360 * t
				local x, z = polar(halfW(y) * 1.12 + 0.35, deg)
				table.insert(pts, { p = v(x, y, z), deg = deg })
			end
			return pts
		end
		local function briar(pts, roseAt)
			for i = 1, #pts - 1 do
				local a, b = pts[i].p, pts[i + 1].p
				B:bar(crop, a, b, 0.75, 0.75, (i % 2 == 0) and VINE or VINE_DK)
				local o = outward((pts[i].deg + pts[i + 1].deg) / 2)
				thorn(crop, a:Lerp(b, 0.5), o + v(0, 0.35 * thornFlip, 0))
				thornFlip = -thornFlip
				if roseAt[i] then
					rose(crop, b + outward(pts[i + 1].deg) * 0.6 + v(0, 0.3, 0), 0.85, pts[i + 1].deg)
				elseif i % 3 == 0 then
					B:block(crop, v(1.2, 1.2, 1.2), CFrame.new(b + outward(pts[i + 1].deg) * 0.55) * ang(jit(25), rnd() * 90, jit(25)), (i % 2 == 0) and LF_MID or LF_LT)
				end
			end
		end
		briar(helix(300, 1.4, BASE + 0.9, BASE + 13.6, 14), { [4] = true, [10] = true })
		briar(helix(40, -1.3, BASE + 0.9, BASE + 13.4, 13), { [6] = true, [12] = true })

		-- crooked branches (first segment on the trunk, second on the canopy)
		local TOPY = BASE + 13.2
		local branchTips = {}
		for k = 0, 5 do
			local a = k * 60
			local x0, z0 = polar(0.6, a)
			local x1, z1 = polar(3.2, a + 10)
			branchTips[k + 1] = { a = a, p0 = v(x0, TOPY - 0.6, z0), p1 = v(x1, TOPY + 1.8 + (k % 2) * 0.4, z1) }
			B:bar(crop, branchTips[k + 1].p0, branchTips[k + 1].p1, 2.0, 1.8, (k % 2 == 0) and BARK or BARK_DK)
		end

		------------------------------------------------------------------
		-- CANOPY (bone "Canopy": lower tier, branches, hanging bits)
		------------------------------------------------------------------
		local CPY = TOPY + 0.6
		local canopy = B:bone("Canopy", "Crop", v(0, CPY, 0))
		for k, b in branchTips do
			local x2, z2 = polar(5.6, b.a - 6)
			local tip = v(x2, CPY + 2.6, z2)
			B:bar(canopy, b.p1 - (b.p1 - b.p0).Unit * 0.4, tip, 1.4, 1.3, BARK_LT)
			b.tip = tip
		end
		-- upper trunk hidden inside the canopy
		B:block(canopy, v(2.8, 8.0, 2.8), cf(0, CPY + 4.0, 0, 0, 30, 0), BARK_DK)

		local function leaf(bone, p, s, col)
			B:block(bone, v(s, s, s), CFrame.new(p) * ang(jit(20), rnd() * 90, jit(20)), col)
		end
		local cubes = {}
		local function tier(bone, ringN, ringR, ringY, ringS, cols, innerDefs, capR, capY, capS, capCols, phase)
			for i = 0, ringN - 1 do
				local a = i * 360 / ringN + phase + jit(6)
				local x, z = polar(ringR + jit(0.3), a)
				local s = ringS + jit(0.3)
				local p = v(x, ringY + jit(0.4), z)
				leaf(bone, p, s, cols[1 + (i % #cols)])
				table.insert(cubes, { bone = bone, p = p, s = s, a = a })
			end
			for _, d in innerDefs do
				local x, z = polar(d[1], d[2])
				leaf(bone, v(x, d[3], z), d[4], d[5])
			end
			for i = 0, ringN - 1 do
				local a = (i + 0.5) * 360 / ringN + phase
				local x, z = polar(capR, a)
				leaf(bone, v(x, capY + jit(0.3), z), capS, capCols[1 + (i % #capCols)])
			end
		end
		local AY = CPY + 3.4
		tier(canopy, 9, 6.0, AY, 5.2, { LF_DK, LF, LF_MID }, {
			{ 2.8, 20, AY + 0.9, 5.6, LF_DK }, { 2.8, 110, AY + 1.0, 5.6, LF }, { 2.8, 200, AY + 0.9, 5.4, LF_DK }, { 2.8, 290, AY + 1.0, 5.6, LF },
		}, 5.2, AY + 2.4, 3.4, { LF_LT, LF_MID, BLOSSOM, LF_LT, LF_MID }, 0)

		-- CanopyTop: the two upper tiers + the crown (sways with a little lag)
		local canopyTop = B:bone("CanopyTop", "Canopy", v(0, AY + 2.0, 0))
		local BY = AY + 4.9
		tier(canopyTop, 7, 4.7, BY, 4.9, { LF, LF_MID, LF_DK }, {
			{ 1.5, 60, BY + 0.8, 5.0, LF }, { 1.5, 240, BY + 0.8, 5.0, LF_MID },
		}, 3.8, BY + 2.1, 3.0, { LF_LIME, LF_LT, BLOSSOM_LT, LF_MID }, 20)
		local CY = BY + 4.1
		tier(canopyTop, 5, 2.5, CY, 3.8, { LF_MID, LF_LT, LF }, {
			{ 0, 0, CY + 1.3, 4.2, LF_MID },
		}, 1.8, CY + 2.3, 2.2, { LF_LIME, LF_LT }, 36)

		-- briar roses + half-sunk heart-fruits dotted over the canopy
		local function onCube(idx, upFrac, side)
			local c = cubes[idx]
			local a = c.a + (side or 0)
			return c.p + outward(a) * (c.s * 0.5 + 0.1) + v(0, c.s * upFrac, 0), a
		end
		for _, r in { { 2, 0.15, 10 }, { 5, 0.2, -15 }, { 8, 0.1, 20 }, { 11, 0.2, -10 }, { 14, 0.15, 15 }, { 17, 0.2, 0 } } do
			if cubes[r[1]] then
				local p, a = onCube(r[1], r[2], r[3])
				rose(cubes[r[1]].bone, p, 1.0, -a)
			end
		end
		local sunkN = 0
		for _, r in { { 1, -0.1 }, { 4, 0.0 }, { 7, -0.05 }, { 10, 0.05 }, { 13, 0.1 } } do
			if cubes[r[1]] then
				sunkN += 1
				local p, a = onCube(r[1], r[2], 0)
				heart(cubes[r[1]].bone, facing(p, a), 0.85, "SunkGlow" .. sunkN, { noBack = true })
			end
		end

		-- the crown heart-fruit on top in a golden leaf collar
		local TOPC = CY + 2.3
		B:block(canopyTop, v(0.7, 1.6, 0.7), cf(0, TOPC, 0), VINE_DK)
		for i = 0, 4 do
			local c = CFrame.new(0, TOPC + 0.3, 0) * CFrame.Angles(0, rad(i * 72 + 10), 0) * CFrame.new(0, 0, -1.2) * ang(-28, 0, 0)
			B:block(canopyTop, v(1.3, 0.3, 1.7), c, (i % 2 == 0) and GOLD or GOLD_LT)
		end
		local crownS = 1.9
		local crownC = v(0, TOPC + 0.75 + 1.1 * crownS, 0)
		local crownCore = heart(canopyTop, CFrame.new(crownC), crownS, "CrownCore", { depth = 1.05 })

		------------------------------------------------------------------
		-- HANGING HEART-FRUITS (bones HeartN on the canopy, pivot at stem top)
		------------------------------------------------------------------
		local HEARTS = {
			-- deg, stem length, scale
			{ 30, 1.6, 1.6 },
			{ 90, 2.5, 1.5 },
			{ 150, 1.8, 1.55 },
			{ 210, 2.4, 1.5 },
			{ 270, 1.7, 1.55 },
			{ 330, 2.5, 1.6 },
		}
		for i, h in HEARTS do
			local x, z = polar(4.8, h[1])
			local top = v(x, AY - 1.7, z)
			local bone = B:bone("Heart" .. i, "Canopy", top)
			local hx, hz = polar(5.2, h[1])
			local s = h[3]
			local c = v(hx, top.Y - h[2] - 0.85 * s, hz)
			B:bar(bone, top + v(0, 0.6, 0), c + v(0, 0.6 * s, 0), 0.32, 0.32, VINE_DK)
			B:block(bone, v(0.9, 0.18, 0.5), CFrame.new(top:Lerp(c, 0.45)) * ang(0, -h[1] + 60, 25), LF_LT) -- leaf flag
			heart(bone, facing(c, h[1]), s, "HeartCore" .. i)
		end

		------------------------------------------------------------------
		-- BRIAR TENDRILS dangling from the branch tips (VineNa -> VineNb)
		------------------------------------------------------------------
		for i, k in { 2, 3, 5, 6 } do
			local b = branchTips[k]
			local o = outward(b.a - 6)
			local top = b.tip + o * 0.8 + v(0, -1.6, 0)
			local mid = top + v(0, -3.0, 0) + o * 0.3
			local bot = mid + v(0, -2.6, 0) + o * 0.2
			local va = B:bone("Vine" .. i .. "a", "Canopy", top)
			local vb = B:bone("Vine" .. i .. "b", "Vine" .. i .. "a", mid)
			B:bar(va, top + v(0, 0.8, 0), mid, 0.45, 0.45, VINE)
			thorn(va, top:Lerp(mid, 0.4), o + v(0, 0.3, 0))
			thorn(va, top:Lerp(mid, 0.8), -o + v(0, 0.3, 0))
			B:block(va, v(1.0, 0.18, 0.6), CFrame.new(top:Lerp(mid, 0.6)) * ang(0, -b.a + 40, -25), LF_MID)
			B:bar(vb, mid + v(0, 0.2, 0), bot, 0.4, 0.4, VINE_DK)
			thorn(vb, mid:Lerp(bot, 0.5), o:Cross(v(0, 1, 0)) + v(0, 0.3, 0))
			rose(vb, bot + v(0, -0.2, 0), 0.75, -b.a)
		end

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local leafZone = B:block(canopy, v(13, 1, 13), cf(0, AY - 1.0, 0), LF, { tr = 1, name = "LeafZone" })
		B:emitter(leafZone, "leaf", { name = "FallingLeaves", color = { LF_LT, LF_MID, LF_LIME }, rate = 1.0, size = { 0.5, 0.5, 0.3 }, life = { 3.5, 5.5 }, speed = { 0.3, 0.8 }, accel = { 0.35, -1.2, 0 }, dir = "Bottom" })
		B:emitter(leafZone, "leaf", { name = "RosePetals", color = { PETAL, ROSE, "#ffc0cc" }, rate = 1.1, size = { 0.32, 0.32, 0.2 }, life = { 4, 6 }, speed = { 0.2, 0.6 }, accel = { -0.3, -0.9, 0.2 }, dir = "Bottom" })
		local moteZone = B:block(canopy, v(16, 14, 16), cf(0, AY, 0), GOLD, { tr = 1, name = "MoteZone" })
		B:emitter(moteZone, "sparkle", { name = "GoldMotes", color = { GOLD_LT, "#ffd6c4", GOLD }, rate = 5, size = { 0.12, 0.42, 0 }, life = { 1.4, 2.6 }, speed = { 0.15, 0.5 } })
		B:emitter(hwCore, "glow", { name = "HeartwoodGlow", color = { GLOW, RG }, rate = 1.3, size = { 1.6, 2.6, 0.6 } })
		B:emitter(hwCore, "ember", { name = "HeartMotes", color = { GOLD_LT, RG_LT }, rate = 1.6, size = { 0.18, 0.12, 0 }, speed = { 0.3, 0.8 }, life = { 2, 3.2 }, spread = 50, accel = { 0, 0.5, 0 } })
		B:emitter(crownCore, "glow", { name = "CrownGlow", color = { GLOW, RG_LT }, rate = 1.2, size = { 2.2, 3.2, 0.6 } })
		B:light(hwCore, { name = "HeartLight", color = "#ffb894", brightness = 1.4, range = 20 })
	end,
}
