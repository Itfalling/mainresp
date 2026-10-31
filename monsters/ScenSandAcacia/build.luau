--!nocheck
-- Acacia Tree (Sandy Savanna scenery, big copy-paste filler).
-- A classic flat-topped savanna acacia in the Mango Acacia palette: a
-- flared, kinked bark trunk that forks into four crooked limbs (each with a
-- side branch), carrying a wide, flat umbrella canopy built as a stepped
-- pixel-oval dome (dark underside, mid layer, light crown) broken up by
-- leafy clumps around the rim, dangling leaf cubes and a few golden sun
-- patches on top; a smaller second leaf pad sits lower on one limb for an
-- asymmetric silhouette. Sand footing with drifts, pebbles, a rock and dry
-- grass tufts.
-- Anchored, weld-free, no scripts or effects.
return {
	DisplayName = "Acacia Tree",
	Rarity = "Scenery",
	Filler = true,
	Element = "Sandy Savanna",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		local SAND_DK, SAND_DK2, SAND, SAND_LT, SAND_TOP = "#c48a45", "#b77d3c", "#d9a95c", "#e8c27a", "#f0d08e"
		local ROCK, ROCK_DK, ROCK_LT = "#c9774a", "#a9573a", "#e0a06a"
		local GRASS, GRASS_DK, GRASS_LT = "#d9b84a", "#b8963a", "#f0d872"
		local PEBBLE, PEBBLE_DK = "#bfae94", "#968670"
		local BARK_DK, BARK, BARK_LT = "#5e3a22", "#7f4f2e", "#9e6a40"
		local LF_DK, LF, LF_MID, LF_LT, LF_TOP = "#4c7a28", "#649a30", "#7db23a", "#9cc84a", "#b8d95e"
		local LF_GOLD = "#cdbf48"

		local seed = 5531
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		------------------------------------------------------------ footing
		B:block(R, v(10.0, 0.3, 6.6), cf(0, 0.15, 0), SAND_DK)
		B:block(R, v(6.6, 0.29, 10.0), cf(0, 0.145, 0), SAND_DK)
		B:block(R, v(8.4, 0.28, 8.4), cf(0, 0.14, 0, 0, 45, 0), SAND_DK2)
		for _, e in { { 25, 5.0, SAND }, { 115, 5.2, SAND_DK2 }, { 200, 4.9, SAND }, { 295, 5.1, SAND_DK } } do
			local a = rad(e[1])
			B:block(R, v(2.0, 0.34, 1.1), CFrame.new(math.sin(a) * e[2], 0.17, -math.cos(a) * e[2]) * CFrame.Angles(0, -a + rad(10), 0), e[3])
		end
		B:block(R, v(4.4, 0.2, 2.6), cf(-1.2, 0.36, 1.4, 0, 18, 0), SAND)
		B:block(R, v(2.6, 0.2, 1.6), cf(2.2, 0.37, -2.2, 0, -20, 0), SAND_LT)
		B:block(R, v(1.6, 0.2, 1.0), cf(-2.8, 0.38, -2.4, 0, 30, 0), SAND_TOP)
		-- rock + pebbles
		B:block(R, v(1.8, 1.0, 1.4), cf(3.4, 0.55, 1.8, 0, 25, 0), ROCK)
		B:block(R, v(1.2, 0.6, 1.0), cf(3.3, 1.25, 1.8, 0, 50, 0), ROCK_LT)
		B:block(R, v(0.9, 0.5, 0.8), cf(4.4, 0.4, 0.8, 0, 10, 0), ROCK_DK)
		for _, p in { { -3.6, 1.2, PEBBLE }, { 1.2, 3.6, PEBBLE_DK }, { -1.0, -3.6, PEBBLE }, { 3.8, -1.4, PEBBLE_DK } } do
			B:block(R, v(0.6, 0.4, 0.5), cf(p[1], 0.45, p[2], 0, rnd(0, 90), 0), p[3])
		end
		-- a fallen dry branch
		B:bar(R, v(-4.4, 0.45, -0.4), v(-1.8, 0.45, -3.4), 0.5, 0.5, BARK_LT)
		B:bar(R, v(-3.2, 0.45, -1.8), v(-4.2, 0.45, -3.2), 0.35, 0.35, BARK)
		-- dry grass tufts
		for _, g in { { -3.8, -1.2 }, { 1.0, -3.8 }, { 4.2, -0.2 }, { -1.8, 3.6 }, { 2.4, 3.0 } } do
			B:block(R, v(0.4, 1.2, 0.4), cf(g[1], 0.7, g[2], 0, 20, 10), GRASS)
			B:block(R, v(0.34, 0.9, 0.34), cf(g[1] + 0.36, 0.6, g[2] + 0.16, 0, 40, -14), GRASS_DK)
			B:block(R, v(0.3, 0.7, 0.3), cf(g[1] - 0.3, 0.5, g[2] - 0.2, 0, 10, 16), GRASS_LT)
		end

		------------------------------------------------------------ trunk
		B:block(R, v(3.0, 0.8, 3.0), cf(0, 0.6, 0, 0, 15, 0), BARK_DK)
		B:block(R, v(2.6, 1.2, 2.6), cf(0, 0.9, 0, 0, 60, 0), BARK)
		for k = 0, 3 do
			local a = rad(k * 90 + 35)
			B:bar(R, v(0, 1.4, 0), v(math.sin(a) * 2.4, 0.25, math.cos(a) * 2.4), 0.8, 0.6, (k % 2 == 0) and BARK_DK or BARK)
		end
		local K1, K2 = v(0, 0.5, 0), v(0.5, 3.6, 0.2)
		local K3 = v(0.1, 6.2, 0.4)
		B:bar(R, K1, K2 + v(0, 0.3, 0), 1.9, 1.9, BARK)
		B:bar(R, K2 - v(0, 0.2, 0), K3 + v(0, 0.3, 0), 1.7, 1.7, BARK)
		B:bar(R, v(0.55, 0.8, -0.98), v(0.9, 3.6, -0.78), 0.5, 0.3, BARK_LT)
		B:bar(R, v(1.0, 3.8, -0.6), v(0.6, 6.0, -0.45), 0.45, 0.3, BARK_LT)
		B:bar(R, v(-0.98, 1.2, 0.3), v(-0.5, 4.8, 0.5), 0.4, 0.3, BARK_DK)
		B:block(R, v(2.1, 0.9, 2.1), CFrame.new(K3) * ang(0, 20, 0), BARK_DK)
		-- limbs fork out and up to the canopy
		local limbs = {
			{ v(-4.6, 10.4, -1.6), v(-6.6, 11.0, -3.6), v(-4.8, 8.4, 2.4) },
			{ v(4.4, 10.6, -0.8), v(6.6, 11.0, 0.6), v(3.4, 11.0, -3.8) },
			{ v(1.2, 10.8, 4.0), v(3.6, 11.0, 5.4), v(-1.6, 11.0, 5.2) },
			{ v(-0.8, 11.0, -3.6), v(-2.4, 11.0, -5.6), v(1.2, 11.0, -5.2) },
		}
		local LIFT = v(0, 1.0, 0)
		for i, l in limbs do
			local tip = l[1] + LIFT
			local mid = K3:Lerp(tip, 0.5) + v(0, -0.4, 0)
			B:bar(R, K3, mid, 1.2, 1.2, (i % 2 == 0) and BARK or BARK_DK)
			B:bar(R, mid, tip, 0.95, 0.95, BARK)
			B:bar(R, mid:Lerp(tip, 0.4), l[2] + LIFT, 0.6, 0.6, BARK_DK)
			if i ~= 1 then
				B:bar(R, mid:Lerp(tip, 0.6), l[3] + LIFT, 0.55, 0.55, BARK_LT)
			end
		end

		------------------------------------------------------------ canopy
		local function pad(x, y, z, W, L, h, col, yaw)
			local F = CFrame.new(x, y, z) * CFrame.Angles(0, rad(yaw or 0), 0)
			B:block(R, v(W, h, L * 0.62), F, col)
			B:block(R, v(W * 0.66, h + 0.02, L), F, col)
		end
		local CY = 12.6
		pad(0.2, CY, 0.2, 17.0, 14.0, 1.0, LF_DK, 6)
		pad(0.2, CY + 0.9, 0.2, 15.6, 12.8, 1.0, LF, 6)
		pad(0.4, CY + 1.7, 0.0, 12.0, 9.6, 0.8, LF_MID, -4)
		pad(0.6, CY + 2.3, -0.2, 7.6, 6.0, 0.6, LF_LT, 10)
		pad(0.8, CY + 2.7, -0.4, 3.6, 3.0, 0.4, LF_TOP, 30)
		-- leafy clumps around the rim
		for i = 0, 6 do
			local a = rad(i * 360 / 7 + 15)
			local r = 6.4 + rnd(-0.4, 0.6)
			local x, z = math.sin(a) * r * 1.1, -math.cos(a) * r * 0.92
			local yaw = rnd(0, 90)
			pad(x, CY + 0.6 + rnd(-0.2, 0.3), z, 5.0, 4.2, 1.5, (i % 2 == 0) and LF or LF_MID, yaw)
			B:block(R, v(3.0, 0.5, 2.4), cf(x * 0.95, CY + 1.55, z * 0.95, 0, yaw + 20, 0), (i % 3 == 0) and LF_TOP or LF_LT)
			B:block(R, v(1.6, 1.2, 1.6), cf(x * 1.08, CY - 0.6, z * 1.08, 0, yaw, 0), LF_DK)
		end
		-- upper bumps between the rim clumps (breaks the oval outline)
		for i = 0, 5 do
			local a = rad(i * 60 + 45)
			local x, z = math.sin(a) * 4.6, -math.cos(a) * 3.8
			local yaw = rnd(0, 90)
			B:block(R, v(3.4, 0.9, 2.8), cf(x, CY + 2.0, z, 0, yaw, 0), (i % 2 == 0) and LF_MID or LF)
			B:block(R, v(2.0, 0.4, 1.6), cf(x + 0.2, CY + 2.55, z - 0.1, 0, yaw + 15, 0), LF_TOP)
		end
		-- dangling seed pods under the canopy
		for _, d in { { -3.0, 2.4 }, { 2.6, -3.0 }, { 4.6, 2.0 }, { -5.2, -1.4 }, { 0.4, 4.6 }, { -1.8, -4.6 } } do
			B:block(R, v(0.35, 1.3, 0.5), cf(d[1], CY - 1.05, d[2], 0, rnd(0, 90), rnd(-12, 12)), (d[1] > 0) and GRASS_DK or BARK_LT)
		end
		-- golden sun patches on top
		for _, g in { { -3.6, -1.6 }, { 3.2, 2.4 }, { -1.2, 3.4 }, { 4.0, -2.6 } } do
			B:block(R, v(1.8, 0.3, 1.4), cf(g[1], CY + 2.15, g[2], 0, rnd(0, 90), 0), LF_GOLD)
		end
		-- smaller lower pad on the left limb
		local L2 = v(-5.0, 9.5, 2.6)
		pad(L2.X, L2.Y, L2.Z, 6.0, 5.0, 1.0, LF_DK, 20)
		pad(L2.X, L2.Y + 0.8, L2.Z, 5.0, 4.0, 0.8, LF, 20)
		pad(L2.X + 0.2, L2.Y + 1.4, L2.Z - 0.1, 3.0, 2.4, 0.5, LF_LT, 40)
		B:block(R, v(1.4, 1.0, 1.4), cf(L2.X - 2.4, L2.Y - 0.6, L2.Z + 1.0, 0, 20, 0), LF_DK)
		B:block(R, v(1.2, 0.9, 1.2), cf(L2.X + 2.0, L2.Y - 0.5, L2.Z + 1.6, 0, 45, 0), LF_DK)
	end,
}
