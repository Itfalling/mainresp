--!nocheck
-- Astral Lotus (Starlight Ruins crop #5, Legendary, ANIM + VFX)
-- A tall night-lotus rising from a starry reflecting pool set into an ancient
-- star-temple platform.
-- * mound (bone "Soil", parts "Soil"): a dark indigo foundation tier with
--   chunky ruined edge stones and a gold band, a pale white-stone tile tier
--   with gold trim, a gold-capped pool basin, moss, star dust, a glowing
--   constellation inlay, a violet crystal cluster, a broken fluted pillar
--   stump and a fallen pillar drum
-- * the pool: deep navy water with nebula patches, twinkling star specks
--   (PoolStarN) and two hidden neon ripple rings (RippleA/B) for the bloom beat
-- * the lotus (bone "Crop" stalk -> "Bloom" head): teal stalk, sepal cup,
--   three rings of stepped cupped petals (PetalO1-8 deep violet, PetalM1-8
--   magenta-pink, PetalI1-6 pearl-gold) each on its own bone hinged at the
--   petal base so they breathe open and shut, a golden seed pod with glowing
--   seeds, and the crop's fruit: a hovering four-point astral star (bone
--   "Star", neon core StarCore) above the flower
-- * two raised lotus leaves (LeafA/LeafB), two closed buds (BudA/BudB), three
--   floating pads (Pad1-3), three star motes orbiting the bloom (bone "Orbit")
--   with trails
-- * VFX: star sparkles, pool twinkles, rising nebula motes, star glow, bloom
--   burst + drifting petals (fired on the beat), two lights, three trails
-- Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Astral Lotus",
	Rarity = "Legendary",
	Element = "Star",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette -------------------------------------------------------------
		local FOUND_DK, FOUND, FOUND_LT = "#2f2f5c", "#3d3e74", "#4f5190"
		local GROUT = "#6f6a8e"
		local STONE, STONE_LT, STONE_DK, STONE_HI = "#d8d4e6", "#e9e6f3", "#bdb7d3", "#f6f3fb"
		local GOLD_DK, GOLD, GOLD_LT = "#c9922a", "#e8b84a", "#ffd96b"
		local MOSS, MOSS_DK, MOSS_LT = "#5e9c74", "#457f5e", "#7dbb86"
		local WATER, WATER_LT, NEB_V, NEB_P = "#1b2258", "#2a3584", "#4b3b97", "#6a3f9e"
		local STAR_W, STAR_C, STAR_G = "#ffffff", "#7fe8ff", "#ffe27a"
		local CRYS, CRYS_LT, CRYS_C = "#8f6bf0", "#b9a2ff", "#7fd9ff"
		local STALK, STALK_DK, STALK_LT = "#3e9a82", "#2f7a68", "#5cbf9e"
		local LEAF, LEAF_DK, LEAF_LT, LEAF_RIM = "#2f8a84", "#22696a", "#43a89a", "#7fe0cf"
		-- petals: deep violet outside -> magenta-pink -> pearl inside
		local PO = { "#6a56d4", "#7d64e6", "#a48ff7", "#ddd2ff" }
		local PM = { "#8a43c8", "#c25ad2", "#e47fdc", "#ffc4ef" }
		local PI = { "#f2c6f2", "#ffe2f6", "#fff4fb" }
		local POD, POD_DK = "#e8b84a", "#c08a2a"
		local SEED = "#fff1a0"

		local seed = 5150515
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

		------------------------------------------------------------------
		-- MOUND (bone "Soil", every part named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local SN = { name = "Soil", mat = "Neon" }
		local function oct(bone, y0, y1, w, color, opts)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(bone, v(w, h, w * 0.62), cf(0, y, 0), color, opts)
			B:block(bone, v(w * 0.62, h + 0.02, w), cf(0, y, 0), color, opts)
			B:block(bone, v(w * 0.85, h - 0.03, w * 0.85), cf(0, y, 0), color, opts)
		end
		-- tier A: dark indigo foundation + gold band + ruined edge stones
		oct(soil, 0, 1.0, 19.0, FOUND, S)
		oct(soil, 0.55, 0.75, 19.2, GOLD_DK, S)
		for i = 0, 15 do
			local a = i * 22.5 + jit(4)
			local x, z = polar(9.0 + jit(0.25), a)
			local h = 0.9 + rnd() * 0.5
			B:block(soil, v(2.6 + rnd() * 0.6, h, 1.9), cf(x, h / 2, z, 0, -a + jit(8), 0),
				i % 3 == 0 and FOUND_LT or (i % 2 == 0 and FOUND_DK or FOUND), S)
		end
		-- tier B: pale tile platform (grout core + tiles)
		oct(soil, 1.0, 1.85, 15.2, GROUT, S)
		local TY = 1.95
		for ix = -3, 2 do
			for iz = -3, 2 do
				local x, z = (ix + 0.5) * 2.5, (iz + 0.5) * 2.5
				local edge = math.max(math.abs(x), math.abs(z)) > 5
				local corner = math.abs(x) > 5 and math.abs(z) > 5
				if edge and not corner then
					local cols = { STONE, STONE_LT, STONE_DK, STONE }
					B:block(soil, v(2.36, 0.34 + jit(0.04), 2.36), cf(x, TY, z, 0, jit(2), 0), cols[1 + math.floor(rnd() * 4)], S)
				end
			end
		end
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			B:block(soil, v(2.3, 0.33, 2.3), cf(c[1] * 5.45, TY, c[2] * 5.45, 0, 45, 0), STONE_DK, S)
		end
		-- gold trim strips along the tile tier sides
		for k = 0, 3 do
			local x, z = polar(7.62, k * 90)
			B:block(soil, v(8.0, 0.22, 0.2), CFrame.new(x, 1.45, z) * ang(0, -k * 90, 0), GOLD, S)
		end
		-- pool basin rim (pale stone, gold corner caps, thin gold lip)
		local RY0, RY1 = 1.9, 2.95
		for k = 0, 3 do
			local x, z = polar(4.55, k * 90)
			B:block(soil, v(10.2, RY1 - RY0, 1.1), CFrame.new(x, (RY0 + RY1) / 2, z) * ang(0, -k * 90, 0), k % 2 == 0 and STONE or STONE_LT, S)
			local lx, lz = polar(4.05, k * 90)
			B:block(soil, v(8.0, 0.14, 0.3), CFrame.new(lx, RY1 - 0.02, lz) * ang(0, -k * 90, 0), GOLD_LT, S)
		end
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			B:block(soil, v(1.6, 0.5, 1.6), cf(c[1] * 4.55, RY1 + 0.15, c[2] * 4.55), GOLD, S)
			B:block(soil, v(0.7, 0.3, 0.7), cf(c[1] * 4.55, RY1 + 0.5, c[2] * 4.55, 0, 45, 0), GOLD_LT, S)
		end
		-- water: deep navy + nebula patches
		local WY = 2.55
		B:block(soil, v(8.2, 0.6, 8.2), cf(0, WY - 0.3, 0), WATER, S)
		B:block(soil, v(3.4, 0.12, 2.2), cf(-2.0, WY + 0.03, 1.6, 0, 20, 0), WATER_LT, S)
		B:block(soil, v(2.6, 0.12, 1.8), cf(2.2, WY + 0.04, -2.0, 0, -30, 0), NEB_V, S)
		B:block(soil, v(1.8, 0.12, 1.4), cf(2.6, WY + 0.02, 2.3, 0, 40, 0), NEB_P, S)
		B:block(soil, v(2.0, 0.12, 1.2), cf(-2.4, WY + 0.05, -2.4, 0, -10, 0), WATER_LT, S)
		-- star specks in the pool (twinkle in motion)
		local SPECKS = { { -1.6, -3.2 }, { 1.2, -3.4 }, { 3.2, -0.6 }, { 2.8, 3.1 }, { -0.4, 3.3 }, { -3.3, 1.0 }, { -3.0, -1.4 }, { 0.6, 1.8 } }
		for i, s in SPECKS do
			B:block(soil, v(0.32, 0.1, 0.32), cf(s[1], WY + 0.1, s[2], 0, 45, 0), (i % 3 == 0) and STAR_G or (i % 2 == 0 and STAR_C or STAR_W),
				{ name = "PoolStar" .. i, mat = "Neon" })
		end
		-- hidden ripple rings (revealed on the bloom beat)
		local function ripple(nm, r)
			for k = 0, 3 do
				local x, z = polar(r, k * 90 + 45)
				B:block(soil, v(r * 1.35, 0.08, 0.2), CFrame.new(x, WY + 0.14, z) * ang(0, -(k * 90 + 45), 0), STAR_C,
					{ name = nm .. (k + 1), mat = "Neon", tr = 1 })
			end
		end
		ripple("RippleA", 1.8)
		ripple("RippleB", 3.0)

		-- constellation inlay on the front tiles
		local CON = { { -3.6, -6.5 }, { -1.7, -5.8 }, { 0.3, -6.7 }, { 2.1, -5.9 }, { 3.7, -6.6 } }
		for i, p in CON do
			B:block(soil, v(0.36, 0.12, 0.36), cf(p[1], TY + 0.2, p[2], 0, 45, 0), STAR_C, SN)
			if i > 1 then
				local q = CON[i - 1]
				B:bar(soil, v(q[1], TY + 0.19, q[2]), v(p[1], TY + 0.19, p[2]), 0.12, 0.08, STAR_C, SN)
			end
		end

		-- moss patches and drapes
		for _, m in { { 6.4, TY + 0.2, 2.6, 2.2, 1.6, 20 }, { -6.3, TY + 0.2, -2.4, 1.8, 2.4, -10 }, { 2.2, TY + 0.2, 6.3, 2.4, 1.4, 5 },
			{ -4.6, RY1 + 0.05, -4.0, 1.3, 1.0, 30 }, { 4.0, RY1 + 0.05, 4.5, 1.6, 0.9, -15 } } do
			B:block(soil, v(m[4], 0.25, m[5]), cf(m[1], m[2], m[3], 0, m[6], 0), MOSS, S)
			B:block(soil, v(m[4] * 0.55, 0.3, m[5] * 0.5), cf(m[1] + 0.2, m[2] + 0.08, m[3] - 0.1, 0, m[6] + 25, 0), MOSS_LT, S)
		end
		for _, a in { 30, 150, 215, 330 } do
			local x, z = polar(9.35, a)
			B:block(soil, v(1.6, 0.9, 0.5), cf(x, 0.75, z, 0, -a, 0), MOSS_DK, S)
		end

		-- star dust specks on the tiers
		for _, d in { { 7.9, 1.05, -3.6, STAR_G }, { -8.2, 1.05, 3.0, STAR_C }, { 5.4, TY + 0.2, -6.4, STAR_G }, { -6.6, TY + 0.2, 4.0, STAR_W },
			{ 8.6, 1.05, 2.2, STAR_W }, { -2.8, 1.05, 8.4, STAR_G } } do
			B:block(soil, v(0.28, 0.28, 0.28), cf(d[1], d[2] + 0.12, d[3], 45, 45, 0), d[4], SN)
		end

		-- violet crystal cluster (front-left on the foundation)
		do
			local base = v(-7.6, 1.0, -5.0)
			B:block(soil, v(1.4, 0.4, 1.4), CFrame.new(base + v(0, 0.2, 0)) * ang(0, 20, 0), FOUND_DK, S)
			local function crystal(off, h, w, tilt, yaw, col)
				local c = CFrame.new(base + off) * ang(0, yaw, 0) * ang(0, 0, tilt)
				B:block(soil, v(w, h, w), c * CFrame.new(0, h / 2, 0) * ang(0, 45, 0), col, S)
				B:block(soil, v(w * 0.6, 0.5, w * 0.6), c * CFrame.new(0, h + 0.2, 0) * ang(0, 45, 0), CRYS_LT, S)
			end
			crystal(v(0, 0.3, 0), 2.6, 0.9, 0, 0, CRYS)
			crystal(v(0.5, 0.3, 0.3), 1.6, 0.7, -25, 30, CRYS_C)
			crystal(v(-0.5, 0.3, -0.2), 1.9, 0.7, 22, -20, CRYS)
			B:block(soil, v(0.3, 0.3, 0.3), CFrame.new(base + v(0, 3.25, 0)) * ang(45, 45, 0), STAR_W, SN)
		end

		-- broken fluted pillar stump (back-left, on the foundation)
		do
			local p = at(9.75, 315, 1.0)
			local yaw = 15
			local F = CFrame.new(p) * ang(0, yaw, 0)
			B:block(soil, v(2.6, 0.5, 2.6), F * CFrame.new(0, 0.25, 0), STONE_DK, S)
			B:block(soil, v(2.2, 0.35, 2.2), F * CFrame.new(0, 0.65, 0), GOLD, S)
			B:block(soil, v(1.8, 3.8, 1.8), F * CFrame.new(0, 2.7, 0), STONE, S)
			B:block(soil, v(1.55, 3.6, 1.55), F * CFrame.new(0, 2.6, 0) * ang(0, 45, 0), STONE_LT, S)
			B:block(soil, v(1.95, 0.3, 1.95), F * CFrame.new(0, 2.2, 0), GOLD, S)
			-- broken stepped top
			B:block(soil, v(1.2, 0.9, 1.0), F * CFrame.new(-0.3, 5.0, 0.2) * ang(0, 0, 8), STONE_LT, S)
			B:block(soil, v(0.7, 0.6, 0.8), F * CFrame.new(0.4, 4.85, -0.3) * ang(0, 20, -6), STONE, S)
			-- gold star rune on the front face
			local face = F * CFrame.new(0, 3.4, -0.92)
			B:block(soil, v(0.7, 0.7, 0.1), face * ang(0, 0, 45), GOLD, S)
			B:block(soil, v(0.3, 0.3, 0.12), face * CFrame.new(0, 0, -0.02), STAR_G, SN)
			-- ivy on the pillar
			B:block(soil, v(0.6, 1.6, 0.3), F * CFrame.new(0.5, 2.0, -0.95), MOSS, S)
			B:block(soil, v(0.5, 0.8, 0.3), F * CFrame.new(-0.4, 3.5, -0.95), MOSS_LT, S)
		end
		-- fallen pillar drum (front-right, on the foundation)
		do
			local p = at(9.6, 125, 1.0)
			local F = CFrame.new(p) * ang(0, -125 + 70, 0)
			B:block(soil, v(2.6, 1.6, 1.6), F * CFrame.new(0, 0.8, 0), STONE, S)
			B:block(soil, v(2.5, 1.35, 1.35), F * CFrame.new(0, 0.8, 0) * ang(45, 0, 0), STONE_LT, S)
			B:block(soil, v(0.3, 1.75, 1.75), F * CFrame.new(0.6, 0.8, 0), GOLD, S)
			B:block(soil, v(0.7, 0.35, 0.9), F * CFrame.new(-1.6, 0.18, 0.4) * ang(0, 30, 0), STONE_DK, S)
		end

		------------------------------------------------------------------
		-- FLOATING PADS (bones PadN, bob on the water)
		------------------------------------------------------------------
		local PADS = { { -2.9, -1.2, 2.4, 20 }, { 2.8, 1.4, 2.2, -35 }, { 0.6, -3.1, 1.8, 60 } }
		for i, p in PADS do
			local pad = B:bone("Pad" .. i, "Soil", v(p[1], WY, p[2]))
			local F = CFrame.new(p[1], WY + 0.12, p[2]) * ang(0, p[4], 0)
			B:block(pad, v(p[3], 0.22, p[3] * 0.62), F, LEAF)
			B:block(pad, v(p[3] * 0.62, 0.24, p[3]), F, LEAF_DK)
			B:block(pad, v(p[3] * 0.5, 0.28, p[3] * 0.5), F * ang(0, 45, 0), LEAF_LT)
			if i == 2 then
				-- tiny pink bloom on this pad
				B:block(pad, v(0.8, 0.5, 0.8), F * CFrame.new(0.2, 0.35, 0.1) * ang(0, 45, 0), PM[3])
				B:block(pad, v(0.4, 0.3, 0.4), F * CFrame.new(0.2, 0.7, 0.1), PM[4])
			end
		end

		------------------------------------------------------------------
		-- THE LOTUS (bone "Crop" = stalk, "Bloom" = flower head)
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, WY, 0))
		local FY = 12.2
		local SP = { v(0, WY - 0.2, 0), v(0.45, 5.4, 0.25), v(-0.15, 8.5, -0.15), v(0.1, FY - 2.2, 0.05) }
		for i = 1, #SP - 1 do
			B:bar(crop, SP[i], SP[i + 1] + (SP[i + 1] - SP[i]).Unit * 0.3, 1.2, 1.2, (i % 2 == 1) and STALK or STALK_DK)
		end
		-- little stalk nodes
		for i = 2, #SP - 1 do
			B:block(crop, v(1.35, 0.35, 1.35), CFrame.new(SP[i]) * ang(0, 45, 0), STALK_LT)
		end
		-- base collar in the water
		B:block(crop, v(1.8, 0.35, 1.8), cf(0, WY + 0.05, 0, 0, 20, 0), STALK_DK)

		local bloom = B:bone("Bloom", "Crop", v(0.1, FY - 2.4, 0.05))
		B:bar(bloom, v(0.1, FY - 2.6, 0.05), v(0, FY - 0.6, 0), 1.0, 1.0, STALK)
		-- sepal cup
		B:block(bloom, v(2.3, 0.9, 2.3), cf(0, FY - 0.7, 0, 0, 0, 0), STALK_DK)
		B:block(bloom, v(2.7, 0.6, 2.7), cf(0, FY - 0.35, 0, 0, 45, 0), STALK)
		for k = 0, 3 do
			local c = CFrame.new(0, FY - 0.6, 0) * CFrame.Angles(0, -rad(k * 90 + 45), 0) * CFrame.new(0, 0, -1.4) * ang(-30, 0, 0)
			B:block(bloom, v(1.1, 0.35, 1.5), c, STALK_LT)
		end

		-- petals: each on its own bone, hinged at the petal base (local -Z = outward, +X rot = close)
		local function petal(name, deg, r0, y, tilt, segs, glow)
			local p = at(r0, deg, y)
			local piv = CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
			local bone = B:bone(name, "Bloom", piv)
			local cur = piv * ang(tilt, 0, 0)
			for _, s in segs do
				cur = cur * ang(s.bend, 0, 0)
				B:block(bone, v(s.w, s.th or 0.5, s.len + 0.15), cur * CFrame.new(0, 0, -s.len / 2), s.col)
				if s.vein then
					B:block(bone, v(0.5, (s.th or 0.5) + 0.1, s.len * 0.8), cur * CFrame.new(0, 0.02, -s.len / 2), s.vein)
				end
				cur = cur * CFrame.new(0, 0, -s.len)
			end
			if glow then
				B:block(bone, v(0.5, 0.56, 0.5), cur * CFrame.new(0, 0.02, 0.15), STAR_C, { mat = "Neon", name = glow })
			end
			return bone
		end
		local OUT_TILT, MID_TILT, IN_TILT = 30, 52, 70
		for k = 1, 8 do
			petal("PetalO" .. k, (k - 1) * 45, 1.3, FY - 0.25, OUT_TILT, {
				{ w = 1.6, len = 1.4, bend = 0, col = PO[1] },
				{ w = 2.6, len = 1.7, bend = 6, col = PO[2], vein = PO[3] },
				{ w = 2.2, len = 1.3, bend = 10, col = PO[3] },
				{ w = 1.3, len = 0.9, bend = 14, col = PO[4] },
			}, "PetalGlow" .. k)
		end
		for k = 1, 8 do
			petal("PetalM" .. k, (k - 1) * 45 + 22.5, 1.0, FY + 0.05, MID_TILT, {
				{ w = 1.5, len = 1.2, bend = 0, col = PM[1] },
				{ w = 2.3, len = 1.5, bend = 6, col = PM[2], vein = PM[3] },
				{ w = 1.8, len = 1.1, bend = 10, col = PM[3] },
				{ w = 1.0, len = 0.7, bend = 12, col = PM[4] },
			})
		end
		for k = 1, 6 do
			petal("PetalI" .. k, (k - 1) * 60 + 10, 0.75, FY + 0.35, IN_TILT, {
				{ w = 1.3, len = 1.0, bend = 0, col = PI[1] },
				{ w = 1.6, len = 1.1, bend = 6, col = PI[2] },
				{ w = 0.9, len = 0.7, bend = 10, col = GOLD_LT },
			})
		end
		-- golden seed pod in the centre
		B:block(bloom, v(1.9, 1.1, 1.9), cf(0, FY + 0.6, 0, 0, 0, 0), POD_DK)
		B:block(bloom, v(1.75, 1.2, 1.75), cf(0, FY + 0.7, 0, 0, 45, 0), POD)
		local SEEDS = { { 0, 0 }, { 0.5, 0.3 }, { -0.5, 0.3 }, { 0.0, -0.55 }, { 0.45, -0.35 }, { -0.45, -0.35 } }
		for i, s in SEEDS do
			B:block(bloom, v(0.3, 0.12, 0.3), cf(s[1], FY + 1.32, s[2]), SEED, { mat = "Neon", name = i == 1 and "PodSeed" or "Seed" })
		end

		------------------------------------------------------------------
		-- THE ASTRAL STAR (fruit) hovering over the bloom (bone "Star")
		------------------------------------------------------------------
		local SY = FY + 4.6
		local star = B:bone("Star", "Bloom", v(0, SY, 0))
		local SF = CFrame.new(0, SY, 0)
		B:block(star, v(1.5, 1.5, 1.5), SF, STAR_G, { mat = "Neon", name = "StarCore" })
		B:block(star, v(2.0, 2.0, 1.2), SF * ang(0, 0, 45), GOLD_LT)
		B:block(star, v(1.2, 2.0, 2.0), SF * ang(45, 0, 0), GOLD)
		-- four stepped points (up, down, left, right) + small front/back nubs
		for k = 0, 3 do
			local d = CFrame.Angles(0, 0, rad(k * 90))
			B:block(star, v(1.1, 1.0, 1.0), SF * d * CFrame.new(0, 1.45, 0), k % 2 == 0 and STONE_HI or GOLD_LT)
			B:block(star, v(0.7, 0.8, 0.7), SF * d * CFrame.new(0, 2.3, 0), k % 2 == 0 and GOLD_LT or STONE_HI)
			B:block(star, v(0.36, 0.4, 0.36), SF * d * CFrame.new(0, 2.85, 0), STAR_W, { mat = "Neon", name = "StarTip" .. (k + 1) })
		end
		-- short diagonal points
		for k = 0, 3 do
			local d = CFrame.Angles(0, 0, rad(k * 90 + 45))
			B:block(star, v(0.6, 0.9, 0.6), SF * d * CFrame.new(0, 1.35, 0), GOLD)
		end
		-- front/back points so the star reads from every side while it turns
		for _, sd in { -1, 1 } do
			B:block(star, v(0.9, 0.9, 0.9), SF * CFrame.new(0, 0, sd * 1.3) * ang(0, 0, 45), GOLD_LT)
			B:block(star, v(0.5, 0.5, 0.7), SF * CFrame.new(0, 0, sd * 2.0), STONE_HI)
		end

		------------------------------------------------------------------
		-- RAISED LEAVES + BUDS (rise from the pool on their own stalks)
		------------------------------------------------------------------
		local function liftLeaf(name, base, top, r, tilt, yaw)
			local bone = B:bone(name, "Soil", base)
			B:bar(bone, base, top, 0.5, 0.5, STALK_DK)
			local F = CFrame.new(top) * ang(0, yaw, 0) * ang(tilt, 0, 0)
			B:block(bone, v(r * 2, 0.3, r * 1.25), F, LEAF)
			B:block(bone, v(r * 1.25, 0.32, r * 2), F, LEAF_DK)
			B:block(bone, v(r * 1.7, 0.28, r * 1.7), F * ang(0, 45, 0), LEAF)
			B:block(bone, v(r * 0.9, 0.36, r * 0.9), F * CFrame.new(0, 0.03, 0) * ang(0, 20, 0), LEAF_LT)
			-- cyan rim accents on two edges
			B:block(bone, v(r * 1.2, 0.34, 0.25), F * CFrame.new(0, 0.02, -r * 0.95), LEAF_RIM)
			B:block(bone, v(0.25, 0.34, r * 1.2), F * CFrame.new(r * 0.95, 0.02, 0), LEAF_RIM)
			return bone
		end
		liftLeaf("LeafA", v(2.4, WY, 1.2), v(3.0, 6.8, 1.6), 1.8, -12, 30)
		liftLeaf("LeafB", v(-2.2, WY, 1.6), v(-2.9, 8.6, 2.2), 1.6, 10, -20)
		liftLeaf("LeafC", v(0.6, WY, 2.6), v(1.0, 4.6, 3.1), 1.5, -8, 70)

		local function bud(name, base, top, s, cols)
			local bone = B:bone(name, "Soil", base)
			B:bar(bone, base, top, 0.45, 0.45, STALK)
			local F = CFrame.new(top)
			B:block(bone, v(0.9 * s, 0.5 * s, 0.9 * s), F * CFrame.new(0, 0.1 * s, 0) * ang(0, 45, 0), STALK_DK)
			B:block(bone, v(1.3 * s, 1.0 * s, 1.3 * s), F * CFrame.new(0, 0.75 * s, 0), cols[1])
			B:block(bone, v(1.15 * s, 1.0 * s, 1.15 * s), F * CFrame.new(0, 1.0 * s, 0) * ang(0, 45, 0), cols[2])
			B:block(bone, v(0.8 * s, 0.8 * s, 0.8 * s), F * CFrame.new(0, 1.7 * s, 0) * ang(0, 20, 0), cols[3])
			B:block(bone, v(0.4 * s, 0.5 * s, 0.4 * s), F * CFrame.new(0, 2.25 * s, 0) * ang(0, 45, 0), cols[4])
			return bone
		end
		bud("BudA", v(-1.8, WY, -2.0), v(-2.6, 6.2, -2.6), 1.15, { PM[1], PM[2], PM[3], PM[4] })
		bud("BudB", v(2.2, WY, -1.4), v(3.0, 4.6, -1.9), 0.95, { PO[2], PO[3], PM[3], PI[3] })

		------------------------------------------------------------------
		-- ORBITING STAR MOTES (bone "Orbit" around the bloom) + trails
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Bloom", v(0, FY + 1.5, 0))
		local MOTES = { { 0, 6.4, 0.6 }, { 120, 6.0, -0.4 }, { 240, 6.6, 1.2 } }
		for i, m in MOTES do
			local p = at(m[2], m[1], FY + 1.5 + m[3])
			B:block(orbit, v(0.5, 0.5, 0.5), CFrame.new(p) * ang(45, 45, 0), i == 2 and STAR_C or STAR_G, { mat = "Neon", name = "Mote" .. i })
			B:block(orbit, v(0.75, 0.2, 0.2), CFrame.new(p) * ang(0, -m[1], 0), STAR_W)
			-- trail along the tangent of the orbit (a short vertical segment sweeps a ribbon)
			B:trail(orbit, p + v(0, 0.3, 0), p - v(0, 0.3, 0), { name = "MoteTrail" .. i, color = { STAR_W, i == 2 and STAR_C or STAR_G }, life = 0.6, width = { 1, 0 }, trans = { 0.25, 1 } })
		end

		------------------------------------------------------------------
		-- VFX: 6 emitters, 2 lights, 3 trails
		------------------------------------------------------------------
		local flowerFx = B:block(bloom, v(7, 3, 7), cf(0, FY + 2.0, 0), PM[3], { tr = 1, name = "FlowerFx" })
		B:emitter(flowerFx, "sparkle", { name = "StarSparkles", color = { STAR_W, STAR_G, "#ffb8f0" }, rate = 9, size = { 0.15, 0.6, 0 }, life = { 1.0, 1.8 }, speed = { 0.2, 0.8 }, light = 1 })
		local moteFx = B:block(bloom, v(2, 0.5, 2), cf(0, FY + 1.6, 0), PM[3], { tr = 1, name = "MoteFx" })
		B:emitter(moteFx, "ember", { name = "NebulaMotes", color = { "#ffc4ef", "#b48cff", STAR_C }, rate = 5, size = { 0.35, 0.28, 0 }, life = { 2.2, 3.4 }, speed = { 1.0, 2.0 }, spread = 35, accel = { 0, 0.6, 0 }, light = 1 })
		B:emitter(moteFx, "burst", { name = "BloomBurst", color = { STAR_W, "#ffd6f6", STAR_G, STAR_C }, size = { 0.7, 0.5, 0 }, speed = { 7, 13 }, life = { 0.6, 1.1 }, drag = 2.5, light = 1 })
		B:emitter(moteFx, "leaf", { name = "BloomPetals", color = { PM[3], PM[4], PO[3] }, rate = 0, size = { 0.45, 0.45, 0.3 }, life = { 2.2, 3.4 }, speed = { 3, 6 }, spread = 70, accel = { 0, -1.6, 0 }, light = 0.3, dir = "Top" })
		local starFx = B:block(star, v(1, 1, 1), SF, STAR_G, { tr = 1, name = "StarFx" })
		B:emitter(starFx, "glow", { name = "StarGlow", color = { "#fff2b0", "#ffd6f6", "#b48cff" }, rate = 2.5, size = { 2.2, 3.4, 1.2 }, trans = { 0.7, 0.6, 1 }, light = 1 })
		local poolFx = B:block(soil, v(7.6, 0.3, 7.6), cf(0, WY + 0.25, 0), WATER, { tr = 1, name = "PoolFx" })
		B:emitter(poolFx, "sparkle", { name = "PoolTwinkles", color = { STAR_W, STAR_C }, rate = 6, size = { 0.1, 0.4, 0 }, life = { 0.8, 1.6 }, speed = { 0.1, 0.5 }, light = 1 })
		local lightA = B:block(bloom, v(0.4, 0.4, 0.4), cf(0, FY + 2.0, 0), PM[3], { tr = 1, name = "FlowerLightCore" })
		B:light(lightA, { name = "FlowerLight", color = "#ff9bf0", brightness = 1.1, range = 16 })
		local lightB = B:block(soil, v(0.4, 0.4, 0.4), cf(0, WY + 1.5, 0), STAR_C, { tr = 1, name = "PoolLightCore" })
		B:light(lightB, { name = "PoolLight", color = "#7fdcff", brightness = 0.9, range = 12 })
	end,
}
