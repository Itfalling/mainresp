--!nocheck
-- Golden Comb Sunflower (Honey Hills crop #9, Divine): a towering sunflower
-- whose giant disc is a domed golden HONEYCOMB.
-- * a stepped grassy meadow mound (bone "Soil", parts "Soil"): brown soil
--   tiers with fresh grass caps, chunky edge blocks, tiny pink / lavender /
--   white wildflowers, clover, pebbles and a little honey puddle with a fallen
--   comb chunk
-- * a thick stepped green stalk (bone "Crop") with node collars, root flares
--   and four big stepped leaves on their own bones (LeafN)
-- * a small side sunflower (bone "BudR") and a closed bud (bone "BudL")
-- * the big HEAD (bone "Head", turns slowly to follow the sun): green calyx +
--   sepals behind, a domed honeycomb disc of offset studded cells (a few
--   capped wax cells, a few glowing honey cells CombGlowN) and honey dribbling
--   over the lower petals
-- * the petal CORONA (bone "Corona", spins slowly): 12 deep-gold inner petals
--   and 12 bright outer petals, each on its own bone (PetalN, pivot at the
--   petal root) so they cup and flare for the bloom beat
-- * three cute block bees (yellow/black stripes, white wings on WingR/WingL
--   bones) circling the flower on orbit bones, each with a honey trail
-- * VFX: honey drips, pollen sparkles, comb glow, rising pollen motes, the
--   bloom burst + petal shower, a gold head light and a soft honey light
-- Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Golden Comb Sunflower",
	Rarity = "Divine",
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
		local STEM_DK, STEM, STEM_LT = "#3a7d24", "#4f9e2e", "#6dbd3a"
		local LEAF_DK, LEAF, LEAF_LT = "#3f9a2c", "#58b83a", "#86d64a"
		local PET_LT, PET, PET_DK, PET_OR = "#ffe766", "#ffd21f", "#f5ab12", "#ef8c18"
		local COMB_DK, COMB_BASE, COMB, COMB_LT, COMB_CAP = "#7c3f0c", "#a55a12", "#eea21a", "#ffc93a", "#ffe7a0"
		local HONEY_DK, HONEY, HONEY_LT, HONEY_GLOW = "#c7740c", "#f0a215", "#ffc23a", "#ffd95a"
		local BEE_Y, BEE_K, WING = "#ffd23a", "#2b2222", "#ffffff"

		local seed = 1690169
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

		------------------------------------------------------------------
		-- MEADOW MOUND (bone "Soil", every part named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(y0, y1, w, color)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(soil, v(w, h, w * 0.62), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.62, h + 0.02, w), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.85, h - 0.03, w * 0.85), cf(0, y, 0), color, S)
		end
		-- soil body + grass caps
		oct(0, 0.85, 15.0, SOIL_DK)
		oct(0.85, 1.1, 14.6, GRASS_DK)
		oct(1.1, 1.75, 11.4, SOIL)
		oct(1.75, 2.0, 11.0, GRASS)
		oct(2.0, 2.45, 8.0, SOIL_LT)
		oct(2.45, 2.65, 7.6, GRASS_LT)
		-- chunky edge blocks (soil with a grass top)
		for i = 0, 15 do
			local a = i * 22.5 + jit(5)
			local x, z = polar(7.1 + jit(0.25), a)
			local h = 0.7 + rnd() * 0.5
			local yaw = -a + jit(10)
			local w = 2.2 + rnd() * 0.6
			B:block(soil, v(w, h, 1.7), cf(x, h / 2, z, 0, yaw, 0), (i % 3 == 0) and SOIL or SOIL_DK, S)
			B:block(soil, v(w + 0.1, 0.3, 1.8), cf(x, h + 0.12, z, 0, yaw, 0), (i % 2 == 0) and GRASS or GRASS_DK, S)
		end
		for i = 0, 8 do
			local a = i * 40 + 14 + jit(8)
			local x, z = polar(5.4 + jit(0.25), a)
			B:block(soil, v(1.9 + rnd() * 0.5, 0.35, 1.5), cf(x, 2.05, z, 0, -a + jit(12), 0), (i % 2 == 0) and GRASS_LT or GRASS, S)
		end
		-- tiny wildflowers (stem + cross petals + yellow eye)
		local function flower(x, y, z, col, h)
			h = h or 0.9
			B:block(soil, v(0.18, h, 0.18), cf(x, y + h / 2, z), STEM, S)
			local yaw = rnd() * 90
			B:block(soil, v(0.75, 0.2, 0.3), cf(x, y + h + 0.05, z, 0, yaw, 0), col, S)
			B:block(soil, v(0.3, 0.21, 0.75), cf(x, y + h + 0.05, z, 0, yaw, 0), col, S)
			B:block(soil, v(0.24, 0.26, 0.24), cf(x, y + h + 0.1, z, 0, yaw, 0), FL_EYE, S)
		end
		local FLW = {
			{ 6.4, 1.1, -2.6, FL_PINK }, { -6.6, 1.1, 1.0, FL_LAV }, { 3.0, 2.0, -4.4, FL_WHITE },
			{ -2.4, 2.65, -3.1, FL_PINK, 0.7 }, { 5.0, 1.1, 4.8, FL_LAV }, { -4.8, 2.0, 3.6, FL_WHITE },
			{ 1.6, 1.1, 6.6, FL_PINK }, { -6.0, 1.1, -4.4, FL_WHITE }, { 4.4, 2.0, 1.8, FL_PINK, 0.7 },
			{ 2.9, 2.65, 2.6, FL_LAV, 0.6 },
		}
		for _, f in FLW do
			flower(f[1], f[2], f[3], f[4], f[5])
		end
		-- clover (three round-ish leaflets, one with a white puff)
		local function clover(x, y, z, puff)
			local yaw = rnd() * 120
			B:block(soil, v(0.14, 0.5, 0.14), cf(x, y + 0.25, z), CLOVER, S)
			for k = 0, 2 do
				local c = CFrame.new(x, y + 0.55, z) * ang(0, yaw + k * 120, 0) * CFrame.new(0, 0, -0.32)
				B:block(soil, v(0.5, 0.14, 0.5), c * ang(0, 45, 0), (k == 0) and CLOVER_LT or CLOVER, S)
			end
			if puff then
				B:block(soil, v(0.36, 0.36, 0.36), cf(x + 0.3, y + 0.9, z, 0, 30, 0), FL_WHITE, S)
			end
		end
		clover(-4.0, 2.0, -2.2, true)
		clover(6.8, 1.1, 1.4, false)
		clover(-1.0, 1.1, -6.8, false)
		clover(-3.2, 1.1, 6.2, true)
		clover(1.2, 2.65, -3.4, false)
		-- pebbles
		for _, p in { { 3.4, 2.0, -3.0 }, { -5.4, 1.1, -2.0 }, { 6.0, 1.1, -4.6 }, { -1.8, 2.65, 2.8 }, { 0.6, 1.1, -7.0 }, { -6.6, 1.1, 3.4 } } do
			B:block(soil, v(0.6, 0.36, 0.5), cf(p[1], p[2] + 0.15, p[3], 0, rnd() * 90, 0), rnd() > 0.5 and PEB or PEB_LT, S)
		end
		-- honey puddle (front left) with a fallen comb chunk
		do
			local px, py, pz = -3.9, 1.1, -4.9
			B:block(soil, v(3.0, 0.14, 2.2), cf(px, py + 0.05, pz, 0, 20, 0), HONEY_DK, S)
			B:block(soil, v(2.3, 0.16, 2.6), cf(px + 0.2, py + 0.07, pz, 0, 20, 0), HONEY_DK, S)
			B:block(soil, v(2.6, 0.2, 1.8), cf(px, py + 0.12, pz, 0, 20, 0), HONEY, S)
			B:block(soil, v(1.9, 0.22, 2.2), cf(px + 0.2, py + 0.13, pz, 0, 20, 0), HONEY, S)
			B:block(soil, v(0.7, 0.06, 0.35), cf(px - 0.5, py + 0.26, pz - 0.3, 0, 20, 0), HONEY_GLOW, { name = "Soil", mat = "Neon" })
			B:block(soil, v(0.3, 0.06, 0.3), cf(px + 0.6, py + 0.26, pz + 0.4, 0, 20, 0), HONEY_GLOW, { name = "Soil", mat = "Neon" })
			-- fallen comb chunk half in the honey
			local c = CFrame.new(px + 1.1, py + 0.55, pz + 0.6) * ang(0, -25, 12)
			B:block(soil, v(1.5, 0.8, 1.0), c, COMB_BASE, S)
			for k = 0, 2 do
				B:block(soil, v(0.42, 0.5, 0.2), c * CFrame.new(-0.5 + k * 0.5, (k % 2) * 0.12, -0.5), (k == 1) and COMB_CAP or COMB_LT, S)
			end
		end

		------------------------------------------------------------------
		-- STALK (bone "Crop")
		------------------------------------------------------------------
		local BASE = 2.65
		local crop = B:bone("Crop", "Root", v(0, BASE, 0))
		-- root flares
		for k = 0, 4 do
			local a = k * 72 + 20
			local x1, z1 = polar(0.6, a)
			local x2, z2 = polar(2.0, a + 12)
			B:bar(crop, v(x1, BASE + 0.9, z1 + 0.3), v(x2, BASE - 0.05, z2 + 0.3), 0.75, 0.6, (k % 2 == 0) and STEM_DK or STEM)
		end
		B:block(crop, v(2.8, 0.7, 2.8), cf(0, BASE + 0.25, 0.3, 0, 45, 0), STEM_DK)
		-- stalk segments with node collars
		local PTS = { v(0, BASE, 0.3), v(0.3, 6.0, 0.5), v(-0.15, 9.6, 0.7), v(0.1, 12.8, 0.8), v(0, 14.9, 0.75) }
		local WID = { 2.1, 1.9, 1.7, 1.5 }
		for i = 1, 4 do
			B:bar(crop, PTS[i] - v(0, 0.3, 0), PTS[i + 1] + v(0, 0.3, 0), WID[i], WID[i], (i % 2 == 1) and STEM or STEM_LT)
			-- a darker stripe for depth
			B:bar(crop, PTS[i] + v(0.6, 0, 0.6), PTS[i + 1] + v(0.5, 0, 0.5), 0.55, 0.55, STEM_DK)
			if i > 1 then
				B:block(crop, v(WID[i] + 0.35, 0.45, WID[i] + 0.35), CFrame.new(PTS[i]) * ang(0, 20 * i, 0), STEM_DK)
			end
		end

		-- big stepped leaves (bones LeafN, pivot at the stalk)
		local function leaf(name, base, yaw, len)
			local bone = B:bone(name, "Crop", base)
			local F = CFrame.new(base) * ang(0, yaw, 0) * ang(14, 0, 0)
			B:block(bone, v(0.45, 0.35, 1.1), F * CFrame.new(0, 0, -0.5), STEM)
			local F1 = F * CFrame.new(0, 0, -1.0) * ang(-12, 0, 0)
			B:block(bone, v(2.6, 0.5, len * 0.42), F1 * CFrame.new(0, 0, -len * 0.21), LEAF)
			B:block(bone, v(0.5, 0.56, len * 0.44), F1 * CFrame.new(0, 0.04, -len * 0.21), LEAF_LT)
			local F2 = F1 * CFrame.new(0, 0, -len * 0.42) * ang(-16, 0, 0)
			B:block(bone, v(3.0, 0.48, len * 0.36), F2 * CFrame.new(0, 0, -len * 0.18), LEAF_DK)
			B:block(bone, v(0.5, 0.54, len * 0.38), F2 * CFrame.new(0, 0.04, -len * 0.18), LEAF_LT)
			local F3 = F2 * CFrame.new(0, 0, -len * 0.36) * ang(-18, 0, 0)
			B:block(bone, v(2.0, 0.46, len * 0.24), F3 * CFrame.new(0, 0, -len * 0.12), LEAF)
			B:block(bone, v(0.9, 0.44, 0.6), F3 * CFrame.new(0, 0, -len * 0.24 - 0.25), LEAF_LT)
		end
		leaf("Leaf1", v(0.5, 5.0, 0.4), -100, 5.0)
		leaf("Leaf2", v(-0.5, 7.4, 0.6), 110, 4.8)
		leaf("Leaf3", v(0.4, 10.2, 0.9), -150, 4.2)
		leaf("Leaf4", v(-0.4, 12.0, 0.9), 160, 3.8)

		-- side sunflower (right) on a branch
		do
			local a, b = v(0.4, 8.0, 0.55), v(3.5, 11.2, 0.0)
			B:bar(crop, a, b, 0.75, 0.75, STEM)
			B:block(crop, v(1.0, 0.4, 1.0), CFrame.new(a + v(0.2, 0.2, 0)) * ang(0, 30, 0), STEM_DK)
			local bud = B:bone("BudR", "Crop", b)
			local H = CFrame.new(b + v(0.5, 0.8, -0.5)) * ang(10, -28, 0)
			B:bar(bud, b - v(0, 0.2, 0), H * v(0, 0, 0.5), 0.65, 0.65, STEM)
			B:block(bud, v(2.6, 1.7, 0.4), H * CFrame.new(0, 0, 0.4), STEM_DK)
			B:block(bud, v(1.7, 2.6, 0.42), H * CFrame.new(0, 0, 0.4), STEM_DK)
			for i = 0, 9 do
				local th = i * 36
				local P1 = H * ang(0, 0, th) * CFrame.new(2.0, 0, (i % 2 == 0) and 0.05 or 0.2)
				B:block(bud, v(1.5, 0.95, 0.3), P1, (i % 2 == 0) and PET or PET_DK)
				B:block(bud, v(0.6, 0.6, 0.28), P1 * CFrame.new(0.95, 0, 0), (i % 2 == 0) and PET_LT or PET)
			end
			B:block(bud, v(2.4, 1.6, 0.5), H * CFrame.new(0, 0, -0.05), COMB_BASE)
			B:block(bud, v(1.6, 2.4, 0.52), H * CFrame.new(0, 0, -0.05), COMB_BASE)
			for _, c in { { -0.5, 0.45 }, { 0.5, 0.45 }, { 0, -0.05 }, { -1.0, -0.05 }, { 1.0, -0.05 }, { -0.5, -0.55 }, { 0.5, -0.55 } } do
				B:block(bud, v(0.42, 0.4, 0.2), H * CFrame.new(c[1] * 0.85, c[2] * 0.95, -0.35), (c[1] == 0) and COMB_CAP or COMB_LT)
			end
		end
		-- closed bud (left)
		do
			local a, b = v(-0.4, 6.6, 0.6), v(-3.0, 9.0, 0.5)
			B:bar(crop, a, b, 0.7, 0.7, STEM)
			local bud = B:bone("BudL", "Crop", b)
			local c = b + v(-0.4, 1.0, 0)
			B:bar(bud, b - v(0, 0.2, 0), c, 0.6, 0.6, STEM)
			B:block(bud, v(1.6, 1.0, 1.6), CFrame.new(c + v(0, 0.3, 0)) * ang(0, 45, 0), STEM_DK)
			B:block(bud, v(1.3, 1.1, 1.3), CFrame.new(c + v(0, 1.0, 0)), STEM)
			B:block(bud, v(0.9, 0.9, 0.9), CFrame.new(c + v(0, 1.75, 0)) * ang(0, 45, 0), PET)
			B:block(bud, v(0.5, 0.5, 0.5), CFrame.new(c + v(0, 2.3, 0)), PET_LT)
			for k = 0, 3 do
				local d = CFrame.new(c + v(0, 1.0, 0)) * ang(0, k * 90 + 45, 0) * CFrame.new(0, 0.2, -0.7) * ang(-16, 0, 0)
				B:block(bud, v(0.7, 1.3, 0.25), d, STEM_LT)
			end
		end

		------------------------------------------------------------------
		-- HEAD (bone "Head", pivot at the neck)
		------------------------------------------------------------------
		local NECK = v(0, 14.9, 0.75)
		local HC = v(0, 15.9, -0.5)
		local HF = CFrame.new(HC) * ang(8, 0, 0)
		local head = B:bone("Head", "Crop", NECK)
		local function hp(x, y, z, sx, sy, sz, col, opts)
			return B:block(head, v(sx, sy, sz), HF * CFrame.new(x, y, z), col, opts)
		end
		local function hoct(r, z, t, col, opts)
			local w = r * 2
			hp(0, 0, z, w, w * 0.62, t, col, opts)
			hp(0, 0, z, w * 0.62, w, t + 0.02, col, opts)
			B:block(head, v(w * 0.86, w * 0.86, t - 0.02), HF * CFrame.new(0, 0, z) * ang(0, 0, 22.5), col, opts)
		end
		-- neck + calyx behind the disc
		B:bar(head, NECK - v(0, 0.4, 0), HF * v(0, -0.6, 1.6), 1.5, 1.5, STEM)
		hoct(3.7, 0.95, 0.6, STEM_DK)
		hoct(2.4, 1.4, 0.5, STEM)
		-- pointed sepals between the petals (visible as green tips from the front)
		for i = 0, 11 do
			local th = i * 30 + 15
			local P1 = HF * ang(0, 0, th) * CFrame.new(4.4, 0, 0.75)
			B:block(head, v(2.0, 0.9, 0.3), P1, (i % 2 == 0) and LEAF or LEAF_DK)
			B:block(head, v(0.8, 0.5, 0.28), P1 * CFrame.new(1.25, 0, 0.02), LEAF_LT)
		end
		-- disc base + rim
		hoct(4.15, 0.15, 0.9, COMB_BASE)
		B:ring(head, HF * ang(90, 0, 0) * CFrame.new(0, 0.15, 0), 4.05, 16, v(1.75, 1.05, 0.7), COMB_DK)
		-- domed honeycomb cells (offset rows -> hex grid)
		local glowN = 0
		local RMAX = 3.55
		local row = 0
		for y = -3.4, 3.41, 0.85 do
			local off = (row % 2 == 0) and 0 or 0.475
			for x = -3.8 + off, 3.81, 0.95 do
				local r = math.sqrt(x * x + y * y)
				if r <= RMAX then
					local dome = 0.55 * (1 - (r / 3.9) ^ 2)
					local z = -0.42 - dome
					local col = ((row + math.floor((x + 4) / 0.95)) % 2 == 0) and COMB or COMB_LT
					local opts = nil
					if r < 1.3 and glowN < 4 then
						glowN += 1
						col = HONEY_GLOW
						opts = { mat = "Neon", name = "CombGlow" .. glowN }
					elseif rnd() < 0.2 then
						col = COMB_CAP
					end
					hp(x, y, z, 0.8, 0.72, 0.4, col, opts)
				end
			end
			row += 1
		end
		-- a few honey-filled cells glowing further out
		for _, g in { { -2.4, 1.3 }, { 1.95, 2.05 }, { 2.4, -1.4 }, { -1.5, -2.6 } } do
			glowN += 1
			hp(g[1], g[2], -0.75 - 0.55 * (1 - (math.sqrt(g[1] ^ 2 + g[2] ^ 2) / 3.9) ^ 2), 0.42, 0.38, 0.2, HONEY_GLOW, { mat = "Neon", name = "CombGlow" .. glowN })
		end
		-- honey dribbling over the lower rim (static strands, drips emit below)
		local dripTips = {}
		for k, d in { { -1.6, 2.1 }, { 0.35, 2.9 }, { 2.0, 1.7 } } do
			local x, len = d[1], d[2]
			local y0 = -math.sqrt(math.max(0, 3.9 ^ 2 - x * x)) + 0.6
			hp(x, y0 - len / 2, -0.75, 0.5, len, 0.4, HONEY)
			hp(x, y0 - 0.3, -0.78, 0.7, 0.6, 0.42, HONEY_LT)
			hp(x, y0 - len - 0.25, -0.75, 0.7, 0.6, 0.55, HONEY_DK)
			dripTips[k] = HF * CFrame.new(x, y0 - len - 0.5, -0.75)
		end

		------------------------------------------------------------------
		-- PETAL CORONA (bone "Corona", spins slowly about the face axis)
		------------------------------------------------------------------
		local corona = B:bone("Corona", "Head", HF)
		for i = 0, 11 do
			local th = i * 30 + 15
			local P1 = HF * ang(0, 0, th) * CFrame.new(5.0, 0, 0.35)
			B:block(corona, v(2.6, 1.45, 0.38), P1, (i % 2 == 0) and PET_DK or PET_OR)
			B:block(corona, v(0.9, 0.9, 0.36), P1 * CFrame.new(1.6, 0, 0.02), PET_DK)
		end
		for i = 0, 11 do
			local th = i * 30
			local PF = HF * ang(0, 0, th) * CFrame.new(3.65, 0, 0.0)
			local pb = B:bone("Petal" .. (i + 1), "Corona", PF)
			local main = (i % 2 == 0) and PET or PET_LT
			local side = (i % 2 == 0) and PET_DK or PET
			B:block(pb, v(1.7, 1.95, 0.42), PF * CFrame.new(0.8, 0, 0), side)
			B:block(pb, v(1.5, 1.6, 0.44), PF * CFrame.new(2.2, 0, -0.05) * ang(0, 6, 0), main)
			B:block(pb, v(0.9, 1.0, 0.4), PF * CFrame.new(3.25, 0, -0.15) * ang(0, 10, 0), main)
			B:block(pb, v(2.6, 0.32, 0.1), PF * CFrame.new(1.6, 0, -0.25), PET_LT)
		end

		------------------------------------------------------------------
		-- BEES (orbit bones; body bone; wing bones)
		------------------------------------------------------------------
		local function bee(n, orbitParent, orbitPivot, local0, s)
			-- local0: CFrame of the bee relative to the orbit pivot (forward = -Z)
			local orbit = B:bone("BeeOrbit" .. n, orbitParent, orbitPivot)
			local BF = orbitPivot * local0
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
				B:bar(body, BF * v(0.2 * sd * s, 0.4 * s, -1.0 * s), BF * v(0.38 * sd * s, 0.95 * s, -1.35 * s), 0.12 * s, 0.12 * s, BEE_K)
				local side = (sd > 0) and "R" or "L"
				local wb = B:bone("Bee" .. n .. "Wing" .. side, "Bee" .. n, BF * CFrame.new(0.3 * sd * s, 0.5 * s, 0))
				B:block(wb, v(1.0 * s, 0.1 * s, 0.7 * s), BF * CFrame.new(0.78 * sd * s, 0.62 * s, 0.1 * s) * ang(0, 0, 12 * sd), WING, { tr = 0.25 })
			end
			B:trail(body, BF * v(0, 0.35 * s, 1.0 * s), BF * v(0, -0.35 * s, 1.0 * s),
				{ name = "BeeTrail" .. n, color = { HONEY_GLOW, "#fff3c0" }, life = 0.45, width = { 1, 0.2 }, trans = { 0.35, 1 } })
		end
		-- two bees circle the stalk (tilted orbits), one loops in front of the face
		bee(1, "Crop", CFrame.new(0, 13.0, 0.2) * ang(0, 0, 10), CFrame.new(0, 0, -8.6) * ang(0, 90, 0), 1.15)
		bee(2, "Crop", CFrame.new(0, 18.5, 0.2) * ang(-8, 0, 0), CFrame.new(8.0, 0, 0), 1.05)
		bee(3, "Head", HF * CFrame.new(0, 0, -2.6), CFrame.new(0, 5.2, 0, 0, 0, 1, -1, 0, 0, 0, -1, 0), 0.95)

		------------------------------------------------------------------
		-- VFX: 6 emitters, 2 lights, 3 trails (above)
		------------------------------------------------------------------
		for k, tip in dripTips do
			if k == 2 then
				local dz = B:block(head, v(1.6, 0.3, 0.6), tip, HONEY, { tr = 1, name = "DripZone" })
				B:emitter(dz, "drip", { name = "HoneyDrip", color = { HONEY_LT, HONEY }, rate = 2.2, size = { 0.38, 0.32, 0.18 }, life = { 0.7, 1.0 }, accel = { 0, -18, 0 }, light = 0.3 })
			end
		end
		local headFx = B:block(head, v(8, 8, 1.0), HF * CFrame.new(0, 0, -0.6), COMB, { tr = 1, name = "HeadFx" })
		B:emitter(headFx, "glow", { name = "CombGlow", color = { "#fff0a0", HONEY_GLOW, PET_DK }, rate = 1.2, size = { 2.5, 3.5, 1.2 }, trans = { 0.85, 0.78, 1 }, light = 0.5 })
		B:emitter(headFx, "burst", { name = "BloomBurst", color = { "#ffffff", HONEY_GLOW, PET_OR }, size = { 0.8, 0.55, 0 }, speed = { 9, 17 }, life = { 0.6, 1.1 }, drag = 2.6, light = 0.8 })
		local pollenZone = B:block(head, v(15, 15, 5), HF * CFrame.new(0, 0, -0.5), PET, { tr = 1, name = "PollenZone" })
		B:emitter(pollenZone, "sparkle", { name = "PollenSparkle", color = { "#ffffff", PET_LT, HONEY_GLOW }, rate = 12, size = { 0.15, 0.55, 0 }, life = { 0.9, 1.7 }, speed = { 0.2, 0.7 }, light = 0.8 })
		B:emitter(pollenZone, "leaf", { name = "PetalShower", color = { PET_LT, PET, PET_DK }, rate = 0.5, size = { 0.5, 0.5, 0.35 }, life = { 2.5, 4 }, speed = { 1, 3 }, accel = { 0.4, -2.2, 0 }, spread = 90 })
		local moteZone = B:block(soil, v(12, 0.6, 12), cf(0, 2.3, 0), PET, { tr = 1, name = "MoteZone" })
		B:emitter(moteZone, "ember", { name = "PollenMotes", color = { PET_LT, HONEY_GLOW, "#fff6c8" }, rate = 5, size = { 0.28, 0.22, 0 }, life = { 3, 5 }, speed = { 0.4, 1.0 }, spread = 35, accel = { 0.15, 0.9, 0 }, light = 0.7 })
		local hl = B:block(head, v(0.4, 0.4, 0.4), HF * CFrame.new(0, 0, -1.5), COMB, { tr = 1, name = "HeadLightCore" })
		B:light(hl, { name = "HeadLight", color = "#ffc84a", brightness = 1.2, range = 16 })
		local pl = B:block(soil, v(0.4, 0.4, 0.4), cf(-3.9, 1.6, -4.9), HONEY, { tr = 1, name = "HoneyLightCore" })
		B:light(pl, { name = "HoneyLight", color = "#ffb030", brightness = 0.7, range = 8 })
	end,
}
