--!nocheck
-- Floating Crystal Shrine (Starlight Ruins decoration, hero piece).
-- A ruined star-temple platform with a big crystal floating above its altar:
-- * PLATFORM (Root): an indigo night-stone base, a ring of worn white-violet
--   temple tiles with gold trim and glowing rune constellations (one tile
--   missing, one knocked askew), front steps, an inner dais with a gold
--   eight-point star inlay, moss draping over the edges, grass tufts, star
--   dust, crystal sprouts and rubble
-- * four broken fluted PILLAR STUMPS at the corners (all different heights,
--   gold bands, rune dots, moss) - one has toppled, its drum lies beside it
-- * the ALTAR: a stepped white pedestal with gold rims, rune faces and a gold
--   four-prong cradle reaching up toward the crystal
-- * the floating CRYSTAL (bone "Crystal"): a big stepped violet/cyan/pink
--   double-point crystal with a glowing equator and facet highlights; it
--   spins slowly and bobs (motion.luau)
-- * four little gold/white STARS (Orbit -> Star1..4) circle it, each one
--   turning on its own
-- * VFX: crystal glow + sparkles, star motes rising from the altar, rune
--   twinkles on the dais; one soft crystal light
-- Blocks only (no wedges / round parts).
return {
	DisplayName = "Floating Crystal Shrine",
	Rarity = "Decor",
	Element = "Starlight Ruins",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Starlight Ruins crops) -----------------------------------
		local EARTH, EARTH_DK, EARTH_LT = "#3b3566", "#2a2550", "#4d4684"
		local STONE, STONE2, STONE_DK, STONE_LT, STONE_HI = "#e3dcef", "#d0c7e2", "#a99fc2", "#f4f0fb", "#fbf9ff"
		local GOLD, GOLD_DK, GOLD_LT = "#f2c24f", "#c9952e", "#ffe08a"
		local MOSS, MOSS_DK, MOSS_LT = "#4f9e7c", "#367a62", "#78c79a"
		local RUNE = "#7fe8ff"
		local DUST_G, DUST_C = "#ffe27a", "#b8f4ff"
		local VIO_DK, VIO, VIO_LT = "#7a58ea", "#9b7cff", "#c6b4ff"
		local CY_DK, CY, CY_LT = "#2aa9cf", "#4fd8f2", "#a8f3ff"
		local PINK, PINK_LT = "#ff8fd8", "#ffc4ee"
		local CORE_C, CORE_W = "#c4fbff", "#f4f0ff"
		local GRASS, GRASS_DK = "#8ea9dc", "#6f87c2"
		local NEON = { mat = "Neon" }

		local seed = 23011
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		-- frame at angle a (deg, 0 = front/-Z, clockwise toward +X), radius r, height y; local -Z = outward
		local function polar(a, r, y)
			return CFrame.new(math.sin(rad(a)) * r, y, -math.cos(rad(a)) * r) * CFrame.Angles(0, -rad(a), 0)
		end
		local function oct(bone, y0, h, r, col, yaw)
			B:block(bone, v(2 * r, h, 0.83 * r), cf(0, y0 + h / 2, 0, 0, yaw or 0, 0), col)
			B:block(bone, v(0.83 * r, h - 0.03, 2 * r), cf(0, y0 + h / 2, 0, 0, yaw or 0, 0), col)
			B:block(bone, v(1.42 * r, h - 0.06, 1.42 * r), cf(0, y0 + h / 2, 0, 0, 45 + (yaw or 0), 0), col)
		end
		-- octagonal pillar drum (vertical) at frame c
		local function drumV(c, h, w, col)
			B:block(R, v(w, h, 0.42 * w), c, col)
			B:block(R, v(0.42 * w, h - 0.02, w), c, col)
			B:block(R, v(0.72 * w, h - 0.04, 0.72 * w), c * ang(0, 45, 0), STONE2)
			for f = 0, 3 do
				B:block(R, v(0.24, h - 0.4, 0.12), c * ang(0, 45 + f * 90, 0) * CFrame.new(0, 0, -0.36 * w - 0.05), STONE_HI)
			end
		end

		------------------------------------------------------------------
		-- PLATFORM
		------------------------------------------------------------------
		-- indigo night-stone base with rough edge blocks
		oct(R, 0, 0.6, 7.0, EARTH_DK)
		for i = 0, 15 do
			local a = i * 22.5 + rnd(-6, 6)
			local w, d, h = rnd(2.3, 3.0), rnd(1.3, 1.8), rnd(0.65, 0.95)
			B:block(R, v(w, h, d), polar(a, 6.85 + rnd(-0.1, 0.2), h / 2) * ang(0, rnd(-8, 8), 0), pick({ EARTH, EARTH_DK, EARTH_LT }))
		end
		-- tier 1: ring of temple tiles on a grout plate
		local T1 = 0.6
		oct(R, T1 - 0.05, 0.6, 5.9, STONE_DK)
		for i = 0, 11 do
			local a = i * 30 + 15
			local hh = 0.7 + rnd(-0.04, 0.05)
			local col = (i % 2 == 0) and STONE or STONE2
			if i == 5 then
				-- missing tile: rubble in the hole
				B:block(R, v(1.2, 0.5, 0.9), polar(a + 6, 5.2, T1 + 0.4) * ang(8, 30, -6), STONE2)
				B:block(R, v(0.7, 0.4, 0.6), polar(a - 8, 5.7, T1 + 0.3) * ang(0, 12, 10), STONE)
			elseif i == 8 then
				B:block(R, v(3.2, hh, 2.2), polar(a, 5.0, T1 + hh / 2 + 0.08) * ang(6, 8, -5), col)
			else
				B:block(R, v(3.35, hh, 2.3), polar(a, 4.8, T1 + hh / 2), col)
			end
		end
		local T1T = T1 + 0.72
		-- gold trim along the tile ring rim
		for i = 0, 11 do
			if i ~= 5 then
				B:block(R, v(2.9, 0.14, 0.24), polar(i * 30 + 15, 5.9, T1T - 0.05), GOLD)
			end
		end
		-- rune constellations on the outer tile faces
		local function rune(a, r, y0, pts)
			local base = polar(a, r, y0)
			local prev
			for _, q in pts do
				local p = base * CFrame.new(q[1], q[2], -0.05)
				B:block(R, v(0.24, 0.24, 0.1), p, RUNE, NEON)
				if prev then
					local c, len = P.aim(prev.Position, p.Position, base.LookVector)
					B:block(R, v(0.08, 0.08, len), c, GOLD)
				end
				prev = p
			end
		end
		rune(345, 5.97, T1 - 0.02, { { -1.0, 0.2 }, { -0.35, 0.45 }, { 0.3, 0.25 }, { 0.95, 0.5 } })
		rune(75, 5.97, T1 - 0.02, { { -0.9, 0.45 }, { -0.2, 0.2 }, { 0.6, 0.4 } })
		rune(285, 5.97, T1 - 0.02, { { -0.8, 0.25 }, { 0.0, 0.5 }, { 0.8, 0.25 } })
		rune(135, 5.97, T1 - 0.02, { { -0.7, 0.4 }, { 0.2, 0.2 }, { 0.9, 0.45 } })
		-- front steps
		B:block(R, v(3.6, 0.55, 1.3), cf(0, 0.28, -7.2), STONE_DK)
		B:block(R, v(3.4, 0.4, 1.1), cf(0, 0.62, -6.6), STONE)
		B:block(R, v(3.0, 0.4, 1.0), cf(0, T1T + 0.18, -3.95), STONE_LT)
		-- tier 2: inner dais with a gold star inlay
		local T2 = T1T
		oct(R, T2 - 0.05, 0.5, 3.5, STONE_DK)
		for i = 0, 7 do
			B:block(R, v(2.45, 0.55, 1.6), polar(i * 45, 3.1, T2 + 0.27), (i % 2 == 0) and STONE_LT or STONE)
		end
		B:block(R, v(4.2, 0.55, 4.2), cf(0, T2 + 0.27, 0, 0, 22.5, 0), STONE_LT)
		local T2T = T2 + 0.55
		for k = 0, 3 do
			local len = (k % 2 == 0) and 6.0 or 4.2
			B:block(R, v(0.5, 0.1, len), cf(0, T2T + 0.02, 0, 0, k * 45, 0), GOLD)
		end
		-- rune dots at the long star tips
		for k = 0, 3 do
			B:block(R, v(0.34, 0.14, 0.34), polar(k * 90, 2.85, T2T + 0.05) * ang(0, 45, 0), RUNE, { mat = "Neon", name = "DaisRune" .. (k + 1) })
		end

		------------------------------------------------------------------
		-- ALTAR + CRADLE
		------------------------------------------------------------------
		local A0 = T2T
		B:block(R, v(2.9, 0.55, 2.9), cf(0, A0 + 0.27, 0), STONE)
		B:block(R, v(3.02, 0.12, 3.02), cf(0, A0 + 0.5, 0), GOLD)
		B:block(R, v(2.1, 1.6, 2.1), cf(0, A0 + 1.35, 0), STONE_LT)
		for k = 0, 3 do -- rune face on each side + gold frame lines
			local F = CFrame.new(0, A0 + 1.35, 0) * CFrame.Angles(0, rad(-k * 90), 0) * CFrame.new(0, 0, -1.06)
			B:block(R, v(0.42, 0.42, 0.1), F * ang(0, 0, 45), RUNE, { mat = "Neon", name = "AltarRune" .. (k + 1) })
			B:block(R, v(1.5, 0.1, 0.08), F * CFrame.new(0, 0.55, 0), GOLD)
			B:block(R, v(1.5, 0.1, 0.08), F * CFrame.new(0, -0.55, 0), GOLD)
		end
		B:block(R, v(2.8, 0.45, 2.8), cf(0, A0 + 2.37, 0), STONE)
		B:block(R, v(2.92, 0.12, 2.92), cf(0, A0 + 2.2, 0), GOLD)
		B:block(R, v(1.6, 0.3, 1.6), cf(0, A0 + 2.72, 0, 0, 45, 0), GOLD_DK)
		B:block(R, v(0.8, 0.2, 0.8), cf(0, A0 + 2.9, 0, 0, 45, 0), CORE_C, { mat = "Neon", name = "CradleGlow" })
		local ATOP = A0 + 2.6
		for k = 0, 3 do -- four gold prongs reaching up
			local a = k * 90 + 45
			local p0 = polar(a, 1.05, ATOP).Position
			local p1 = polar(a, 1.55, ATOP + 1.2).Position
			B:bar(R, p0, p1, 0.4, 0.4, GOLD)
			B:block(R, v(0.3, 0.45, 0.3), CFrame.new(p1 + v(0, 0.3, 0)) * ang(0, -a, 0), GOLD_LT)
		end

		------------------------------------------------------------------
		-- PILLAR STUMPS (corners)
		------------------------------------------------------------------
		local function stump(a, r, nDrums, topH, tilt, mossy, idx)
			local base = polar(a, r, T1T)
			local yaw = rnd(-10, 10)
			local bp = base.Position
			B:block(R, v(2.4, 0.5, 2.4), CFrame.new(bp + v(0, 0.25, 0)) * ang(0, yaw - a, 0), STONE_DK)
			B:block(R, v(2.1, 0.3, 2.1), CFrame.new(bp + v(0, 0.62, 0)) * ang(0, yaw - a, 0), STONE)
			local y = 0.77
			for k = 1, nDrums do
				local c = CFrame.new(bp + v(rnd(-0.05, 0.05), y + 0.85, rnd(-0.05, 0.05))) * ang(0, yaw - a + rnd(-4, 4), 0)
				drumV(c, 1.7, 1.8, (k % 2 == 1) and STONE_LT or STONE)
				y += 1.7
				if k == 1 then
					B:block(R, v(1.92, 0.26, 1.92), CFrame.new(bp + v(0, y - 0.1, 0)) * ang(0, yaw - a, 0), GOLD)
				end
			end
			-- broken top piece
			local top = CFrame.new(bp + v(0, y + topH / 2 - 0.05, 0)) * ang(tilt, yaw - a, tilt * 0.6)
			B:block(R, v(1.5, topH, 1.2), top * CFrame.new(-0.12, 0, 0.1), STONE_LT)
			B:block(R, v(0.8, topH * 0.7, 0.9), top * CFrame.new(0.35, topH * 0.55, -0.2) * ang(0, 15, 8), STONE)
			-- rune dots on the outward face
			for k = 1, nDrums do
				local p = base * CFrame.new(0, 0.77 + (k - 0.5) * 1.7, -0.78)
				B:block(R, v(0.26, 0.26, 0.1), p * ang(0, 0, 45), RUNE, { mat = "Neon", name = ("PillarRune%d_%d"):format(idx, k) })
			end
			if mossy then
				B:block(R, v(1.6, 0.22, 1.4), top * CFrame.new(0, topH / 2 + 0.05, 0), MOSS)
				B:block(R, v(0.5, 1.6, 0.25), base * CFrame.new(0.45, y - 0.6, -0.82), MOSS_DK)
			end
			return y
		end
		stump(45, 4.75, 1, 0.8, 6, true, 1)    -- front-right: low
		stump(225, 4.85, 2, 1.0, -8, false, 2) -- back-left: medium
		local hB = stump(135, 4.85, 4, 0.8, 4, true, 3) -- back-right: tall, with a capital fragment
		stump(315, 4.75, 1, 0.5, -10, true, 4) -- front-left: toppled
		-- capital fragment perched on the tall stump
		do
			local bp = polar(135, 4.85, T1T).Position
			local c = CFrame.new(bp + v(0, hB + 0.5, 0)) * ang(5, -100, -4)
			B:block(R, v(2.5, 0.4, 2.5), c * CFrame.new(0, 0.5, 0), STONE_LT)
			B:block(R, v(2.6, 0.14, 2.6), c * CFrame.new(0, 0.27, 0), GOLD)
			B:block(R, v(2.2, 0.4, 2.2), c * CFrame.new(0, 0.0, 0), STONE)
			B:block(R, v(1.6, 0.22, 1.2), c * CFrame.new(-0.3, 0.8, 0.3), MOSS_LT)
			B:block(R, v(0.4, 1.2, 0.25), c * CFrame.new(-1.15, 0.0, 0.4), MOSS_DK)
		end
		-- the toppled drum of the back-left pillar, lying on the tiles
		do
			local c = polar(282, 5.0, T1T + 0.9) * ang(0, 80, 90)
			drumV(c, 1.8, 1.8, STONE_LT)
			B:block(R, v(1.92, 0.26, 1.92), c * CFrame.new(0, 0.75, 0), GOLD)
			local c2 = polar(330, 6.1, T1T + 0.4) * ang(15, 20, 8)
			B:block(R, v(0.9, 0.6, 0.8), c2, STONE)
		end

		------------------------------------------------------------------
		-- MOSS, GRASS, SPROUTS, DUST
		------------------------------------------------------------------
		for _, m in { { 100, 5.9, 2.0, MOSS }, { 200, 5.85, 1.7, MOSS_LT }, { 20, 5.9, 1.5, MOSS_DK }, { 300, 5.9, 1.2, MOSS }, { 160, 3.55, 1.3, MOSS }, { 250, 3.55, 1.1, MOSS_LT } } do
			local y = (m[2] > 4.5) and T1T or T2T
			B:block(R, v(m[3], 0.22, 1.1), polar(m[1], m[2] - 0.4, y + 0.04) * ang(-8, 0, 0), m[4])
			B:block(R, v(m[3] * 0.6, 0.22, 0.7), polar(m[1] + 4, m[2] + 0.1, y - 0.35) * ang(-60, 0, 0), m[4])
		end
		for _, g in { { 115, 7.3, 0.6 }, { 205, 7.4, 0.6 }, { 290, 7.3, 0.6 }, { 60, 5.6, T1T }, { 172, 5.4, T1T }, { 340, 7.4, 0.6 } } do
			local base = polar(g[1], g[2], g[3])
			for k = -1, 1 do
				local h = (k == 0) and 1.3 or 0.95
				B:block(R, v(0.24, h, 0.3), base * ang(0, 0, k * 24) * CFrame.new(0, h / 2, 0), (k == 0) and GRASS or GRASS_DK)
			end
		end
		local function sprout(p, s, yaw)
			local c = CFrame.new(p) * ang(0, yaw, 0)
			B:block(R, v(0.55 * s, 1.4 * s, 0.55 * s), c * CFrame.new(0, 0.6 * s, 0) * ang(0, 45, 8), VIO)
			B:block(R, v(0.32 * s, 0.4 * s, 0.32 * s), c * CFrame.new(0.1 * s, 1.35 * s, 0) * ang(0, 45, 8), VIO_LT)
			B:block(R, v(0.4 * s, 0.95 * s, 0.4 * s), c * CFrame.new(0.45 * s, 0.4 * s, 0.1 * s) * ang(0, 20, -26), CY)
			B:block(R, v(0.36 * s, 0.75 * s, 0.36 * s), c * CFrame.new(-0.4 * s, 0.3 * s, 0.15 * s) * ang(12, 55, 28), CY_DK)
		end
		sprout(polar(355, 4.6, T1T).Position, 1.0, 20)
		sprout(polar(95, 5.0, T1T).Position, 0.85, -40)
		sprout(polar(180, 7.3, 0.55).Position, 0.9, 70)
		sprout(polar(270, 3.0, T2T).Position, 0.7, 10)
		for _, d in { { 30, 2.6, T2T }, { 200, 2.4, T2T }, { 75, 5.4, T1T }, { 330, 5.2, T1T }, { 160, 5.6, T1T }, { 260, 4.3, T1T }, { 15, 6.9, 0.85 }, { 230, 6.8, 0.85 } } do
			local p = polar(d[1], d[2], d[3] + 0.08).Position
			B:block(R, v(0.28, 0.16, 0.28), CFrame.new(p) * ang(0, rnd(0, 90), 0), pick({ DUST_G, DUST_C }))
		end

		------------------------------------------------------------------
		-- FLOATING CRYSTAL (bone "Crystal")
		------------------------------------------------------------------
		local CC = v(0, 12.4, 0)
		local crys = B:bone("Crystal", "Root", CC)
		local H = CFrame.new(CC) * ang(0, 45, 0)
		B:block(crys, v(3.7, 0.6, 3.7), H, CORE_C, { mat = "Neon", name = "CrystalCore" })
		local up = { { 3.35, VIO }, { 2.8, VIO_LT }, { 2.2, VIO }, { 1.6, CY }, { 1.0, CY_LT }, { 0.5, CORE_W } }
		for i, s in up do
			B:block(crys, v(s[1], 0.9, s[1]), H * CFrame.new(0, 0.3 + 0.9 * (i - 0.5), 0), s[2])
		end
		local dn = { { 3.25, VIO_DK }, { 2.5, VIO }, { 1.8, VIO_LT }, { 1.1, PINK }, { 0.5, PINK_LT } }
		for i, s in dn do
			B:block(crys, v(s[1], 0.9, s[1]), H * CFrame.new(0, -0.3 - 0.9 * (i - 0.5), 0), s[2])
		end
		-- facet highlights (thin plates on alternating faces)
		for k = 0, 3 do
			local F = H * CFrame.Angles(0, rad(k * 90), 0)
			if k % 2 == 0 then
				B:block(crys, v(1.6, 0.6, 0.14), F * CFrame.new(0, 0.75, -1.73), VIO_LT)
				B:block(crys, v(0.9, 0.6, 0.14), F * CFrame.new(0, 2.55, -1.16), CY_LT)
			else
				B:block(crys, v(1.5, 0.6, 0.14), F * CFrame.new(0, -0.75, -1.68), VIO_LT)
				B:block(crys, v(1.1, 0.6, 0.14), F * CFrame.new(0, 1.65, -1.46), STONE_HI)
			end
		end
		-- two small satellite shards locked to the crystal (turn with it)
		for i, s in { { 1, PINK, PINK_LT }, { -1, CY, CY_LT } } do
			local pc = CC + v(s[1] * 2.95, s[1] * 0.4, 0)
			local F = CFrame.new(pc) * ang(0, 45, s[1] * -12)
			B:block(crys, v(0.7, 0.9, 0.7), F, s[2])
			B:block(crys, v(0.4, 0.5, 0.4), F * CFrame.new(0, 0.65, 0), s[3])
			B:block(crys, v(0.38, 0.45, 0.38), F * CFrame.new(0, -0.62, 0), s[3])
		end

		------------------------------------------------------------------
		-- ORBITING STARS (Orbit -> Star1..4)
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", CC)
		local STARS = {
			{ 0, 4.8, -0.8, 1.25, GOLD, GOLD_LT },
			{ 90, 5.0, 0.9, 1.0, STONE_HI, CY_LT },
			{ 180, 4.8, -0.3, 1.25, GOLD, GOLD_LT },
			{ 270, 5.0, 1.4, 1.0, STONE_HI, PINK_LT },
		}
		for i, s in STARS do
			local pc = CC + v(math.sin(rad(s[1])) * s[2], s[3], -math.cos(rad(s[1])) * s[2])
			local F = CFrame.new(pc) * ang(0, -s[1], 0)
			local sb = B:bone("Star" .. i, "Orbit", F) -- pivot at the star centre: it twirls about Y
			local k = s[4]
			for q = 0, 3 do
				local A = F * ang(0, 0, q * 90)
				B:block(sb, v(0.6 * k, 0.5 * k, 0.45 * k), A * CFrame.new(0, 0.45 * k, 0), s[5])
				B:block(sb, v(0.3 * k, 0.45 * k, 0.4 * k), A * CFrame.new(0, 0.9 * k, 0), s[6])
			end
			B:block(sb, v(0.62 * k, 0.62 * k, 0.5 * k), F * ang(0, 0, 45), CORE_W, { mat = "Neon", name = "StarCore" .. i })
		end

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local cfx = B:block(crys, v(2.8, 3.4, 2.8), CFrame.new(CC), CY, { tr = 1, name = "CrystalFx" })
		B:emitter(cfx, "glow", { name = "CrystalGlow", color = { CORE_C, VIO_LT, PINK_LT }, rate = 2, size = { 3.0, 4.5, 2 }, trans = { 0.8, 0.72, 1 }, light = 1 })
		local zone = B:block(R, v(10, 8, 10), CFrame.new(CC), CY, { tr = 1, name = "CrystalZone" })
		B:emitter(zone, "sparkle", { name = "CrystalSparkle", color = { "#ffffff", CY_LT, PINK_LT, GOLD_LT }, rate = 8, size = { 0.15, 0.5, 0 }, life = { 1.0, 1.8 }, speed = { 0.2, 0.6 }, light = 1 })
		local altarFx = B:block(R, v(1.4, 0.4, 1.4), cf(0, ATOP + 0.5, 0), CY, { tr = 1, name = "AltarFx" })
		B:emitter(altarFx, "sparkle", { name = "RisingMotes", color = { CY_LT, "#ffffff", VIO_LT }, rate = 5, size = { 0.15, 0.32, 0 }, life = { 1.6, 2.4 }, speed = { 0.8, 1.4 }, spread = 12, accel = { 0, 0.6, 0 }, light = 1, emitDir = "Top" })
		local dais = B:block(R, v(11, 0.5, 11), cf(0, T1T + 0.3, 0), GOLD, { tr = 1, name = "DaisZone" })
		B:emitter(dais, "sparkle", { name = "RuneTwinkle", color = { RUNE, DUST_G, "#ffffff" }, rate = 5, size = { 0.12, 0.32, 0 }, life = { 1.8, 3 }, speed = { 0.2, 0.5 }, spread = 25, accel = { 0, 0.6, 0 }, light = 1 })
		B:light(cfx, { name = "CrystalLight", color = "#b5a2ff", brightness = 1.2, range = 18 })
	end,
}
