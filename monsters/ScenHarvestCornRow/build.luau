--!nocheck
-- Cornstalk Row (Harvest Fields scenery, big copy-paste filler, 14 wide).
-- A row of seven tall late-season corn stalks (11-14 studs) standing on a
-- low dirt furrow that is exactly 14 studs long, so rows tile end to end
-- (stalks keep the same 2-stud spacing across the seam). Chunky olive stalks
-- with darker node rings lean slightly, long arching leaf blades fade from
-- green low down to straw-gold at the top, fat golden cobs peek out of pale
-- husks with amber silk, and golden tassels fan out on top. Two stalks are
-- drying out in straw tones. Footing: the furrow with a lighter ridge,
-- grass tufts and fallen leaves along the sides. Anchored, weld-free, no
-- scripts.
return {
	DisplayName = "Cornstalk Row",
	Rarity = "Scenery",
	Filler = true,
	Element = "Harvest Fields",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		-- palette (Harvest Fields + Golden Harvest Corn)
		local DIRT_DK, DIRT, DIRT_LT = "#55311b", "#6e4024", "#8a552f"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local STALK_DK, STALK, STALK_LT = "#4f8a2a", "#6fa83a", "#86bc44"
		local DRY_DK, DRY, DRY_LT = "#a8822e", "#c99a35", "#e2bd52"
		local L_GREEN = { "#4f8f2e", "#5f9e34", "#76b03c" }
		local L_MID = { "#7fa834", "#9db63c", "#b9c24a" }
		local L_STRAW = { "#cfa640", "#e2bd52", "#f0d36e" }
		local GOLD, GOLD_DK, GOLD_LT = "#ffd024", "#e39a14", "#ffe45c"
		local HUSK, HUSK_DK, HUSK_LT = "#9cc44a", "#78a836", "#c3d660"
		local SILK = "#f2a640"
		local TASSEL, TASSEL_DK = "#e8cc62", "#c99a35"
		local LF_OR, LF_RED, LF_GOLD = "#f27a1c", "#d8352a", "#f7b52c"

		local seed = 4091
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		local W = 14 -- tile length along X

		---------------------------------------------------------------- furrow
		B:block(R, v(W, 0.16, 3.6), cf(0, 0.08, 0), DIRT_DK)
		B:block(R, v(W, 0.32, 2.2), cf(0, 0.16, 0), DIRT)
		B:block(R, v(W, 0.08, 0.9), cf(0, 0.36, 0.1), DIRT_LT)
		-- dirt clods on the ridge
		for _, c in { { -5.0, -0.6 }, { -1.0, 0.7 }, { 3.0, -0.7 }, { 5.8, 0.6 } } do
			B:block(R, v(0.7, 0.3, 0.6), cf(c[1], 0.4, c[2], 0, rnd(0, 90), 0), DIRT_LT)
		end

		---------------------------------------------------------------- stalks
		local function leaf(base, a, L, cols)
			local d = v(math.sin(a), 0, math.cos(a))
			local mid = base + d * (1.3 * L) + v(0, 1.3 * L, 0)
			local tip = mid + d * (1.7 * L) + v(0, -0.9 * L, 0)
			B:bar(R, base, mid, 1.05, 0.26, cols[2])
			B:bar(R, mid, tip, 0.85, 0.24, cols[3])
		end

		local function stalk(x, z, h, lx, lz, dry, earSide, la)
			local sd, sm, sl = STALK_DK, STALK, STALK_LT
			if dry then
				sd, sm, sl = DRY_DK, DRY, DRY_LT
			end
			local function at(t)
				return v(x + lx * t, h * t, z + lz * t)
			end
			-- root flare
			B:block(R, v(1.3, 0.5, 1.3), cf(x, 0.45, z, 0, rnd(0, 90), 0), sd)
			-- three stalk segments + node rings
			local p0, p1, p2, p3 = at(0.03), at(0.36), at(0.68), at(0.93)
			B:bar(R, p0, p1, 1.3, 1.3, sd)
			B:bar(R, p1, p2, 1.15, 1.15, sm)
			B:bar(R, p2, p3, 0.95, 0.95, sl)
			B:block(R, v(1.5, 0.34, 1.5), CFrame.new(p1), sd)
			B:block(R, v(1.32, 0.3, 1.32), CFrame.new(p2), sm)
			-- leaves: green low, straw-gold high
			-- leaves arch out to the front and back of the row (alternating)
			local a0 = la + rnd(-15, 15)
			local fr = { 0.18, 0.33, 0.48, 0.62, 0.76 }
			for i, t in fr do
				local cols = dry and L_STRAW or (i <= 2 and L_GREEN or (i <= 4 and L_MID or L_STRAW))
				leaf(at(t), rad(a0 + (i % 2) * 180 + (i > 2 and 90 or 0) + rnd(-25, 25)), 1.3 - i * 0.1, cols)
			end
			-- golden cob in its husk
			local ep = at(0.42) + v(earSide * 0.45, 0, -earSide * 0.75)
			local E = CFrame.new(ep) * CFrame.Angles(rad(earSide * 18), 0, rad(-earSide * 14))
			B:block(R, v(1.0, 1.6, 1.0), E * CFrame.new(0, -0.1, 0), dry and DRY or HUSK)
			B:block(R, v(0.9, 2.0, 0.9), E * CFrame.new(0, 0.7, 0), dry and GOLD_DK or GOLD)
			B:block(R, v(0.6, 0.4, 0.6), E * CFrame.new(0, 1.85, 0), dry and GOLD or GOLD_LT)
			B:block(R, v(0.32, 0.55, 0.32), E * CFrame.new(0, 2.25, 0) * CFrame.Angles(0, 0, rad(-earSide * 20)), SILK)
			B:block(R, v(0.3, 1.4, 1.0), E * CFrame.new(earSide * 0.55, 0.2, 0) * CFrame.Angles(0, 0, rad(earSide * 14)), dry and DRY_LT or HUSK_LT)
			-- tassel
			local top = at(0.93)
			B:block(R, v(0.5, 1.0, 0.5), CFrame.new(top + v(0, 0.6, 0)), TASSEL)
			local ta = rnd(0, 90)
			for k = 0, 3 do
				local a = rad(ta + k * 90)
				local d = v(math.sin(a), 0, math.cos(a))
				B:bar(R, top + v(0, 0.9, 0), top + d * 0.9 + v(0, 1.8, 0), 0.22, 0.22, (k % 2 == 0) and TASSEL or TASSEL_DK)
			end
		end

		local stalks = {
			{ -6, -0.5, 12.0, false, 1 }, { -4, 0.5, 13.4, false, -1 }, { -2, -0.4, 12.4, true, 1 },
			{ 0, 0.5, 13.8, false, -1 }, { 2, -0.5, 12.6, false, 1 }, { 4, 0.4, 13.2, true, -1 },
			{ 6, -0.4, 12.2, false, -1 },
		}
		for i, s in stalks do
			stalk(s[1], s[2], s[3], rnd(-0.5, 0.5), rnd(-0.5, 0.5), s[4], s[5], (i % 2 == 0) and 45 or -45)
		end

		---------------------------------------------------------------- side dressing
		for _, g in { { -5.0, -2.2, 10 }, { -1.2, 2.2, 40 }, { 2.8, -2.3, 70 }, { 5.4, 2.1, 25 }, { -3.2, 2.3, 55 } } do
			B:block(R, v(0.45, 1.0, 0.45), cf(g[1], 0.5, g[2], 6, g[3], 8), GRASS)
			B:block(R, v(0.35, 0.7, 0.35), cf(g[1] + 0.35, 0.35, g[2] + 0.2, -6, g[3] + 25, -10), GRASS_DK)
		end
		for _, l in { { -3.6, -2.0, LF_OR }, { 0.8, -2.2, LF_GOLD }, { 4.2, 2.2, LF_RED }, { -5.8, 2.1, LF_GOLD }, { 1.8, 2.0, LF_OR } } do
			B:block(R, v(0.8, 0.12, 0.8), cf(l[1], 0.06, l[2], 0, rnd(0, 90), 0), l[3])
		end
	end,
}
