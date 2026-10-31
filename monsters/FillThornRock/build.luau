--!nocheck
-- Mossy Rock (Thorny Woods filler prop).
-- A rounded forest boulder built from chamfered stone tiers (two crossed
-- slabs each) that step in as they rise, slightly turned against each other:
-- dark stone at the foot, mid grey body, pale weathered top with highlight
-- edges and zig-zag cracks. A thick moss blanket (dark under-layer, main
-- moss, bright patches) covers the top and drips down the back and one side
-- in stepped runs. A small mossy stone leans on its flank, a little fern
-- sprouts at its foot, and a low footing of moss, pebbles, grass tufts and
-- fallen leaves grounds it. No motion, no effects.
return {
	DisplayName = "Mossy Rock",
	Rarity = "Filler",
	Filler = true,
	Element = "Thorny Woods",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		-- palette (Thorny Woods: Mushroom Log / Thorn Arch)
		local STONE_DK2, STONE_DK, STONE, STONE_LT = "#55534d", "#686660", "#8d8a80", "#a9a397"
		local MOSS_DK, MOSS, MOSS_LT = "#3f8a2c", "#5fae3a", "#86c94a"
		local FERN_DK, FERN, FERN_LT = "#1f6e3c", "#2f9a52", "#6fd06a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local LEAF_O, LEAF_Y = "#c8612a", "#d99a2e"

		-- chamfered tier: two crossed slabs
		local function tier(C, w, d, h, c1, c2)
			B:block(R, v(w, h, d * 0.72), C, c1)
			B:block(R, v(w * 0.78, h - 0.02, d), C, c2 or c1)
		end

		---------------------------------------------------------------- boulder
		local T1 = cf(0, 0.5, 0, 0, 8, 0)
		local T2 = cf(-0.15, 1.28, 0.05, 3, -6, -4)
		local T3 = cf(-0.35, 1.95, 0.15, -4, 12, 5)
		tier(T1, 4.0, 3.2, 1.0, STONE_DK, STONE_DK)
		tier(T2, 3.5, 2.9, 0.9, STONE, STONE)
		tier(T3, 2.5, 2.1, 0.7, STONE_LT, STONE)
		-- a lump on the left flank breaks up the stepped outline
		local LUMP = cf(-1.75, 0.95, 0.55, 8, 35, 12)
		tier(LUMP, 1.6, 1.5, 1.3, STONE, STONE_DK)
		B:block(R, v(1.0, 0.3, 0.9), LUMP * CFrame.new(0.1, 0.72, 0) * CFrame.Angles(0, rad(20), 0), STONE_LT)
		-- highlight edges on the upper front ledges
		B:block(R, v(2.0, 0.1, 0.22), T2 * CFrame.new(0.3, 0.47, -1.0), STONE_LT)
		B:block(R, v(0.22, 0.1, 1.6), T2 * CFrame.new(1.35, 0.47, -0.2), STONE_LT)
		B:block(R, v(0.22, 0.1, 1.2), T1 * CFrame.new(1.6, 0.52, -0.3), STONE)
		-- zig-zag cracks on the front and the right side
		local function crack(C, pts)
			for i = 1, #pts - 1 do
				local a = (C * CFrame.new(pts[i][1], pts[i][2], 0)).Position
				local b = (C * CFrame.new(pts[i + 1][1], pts[i + 1][2], 0)).Position
				B:bar(R, a, b, 0.1, 0.08, STONE_DK2)
			end
		end
		crack(T2 * CFrame.new(0, 0, -1.47), { { 0.8, 0.35 }, { 0.55, 0.0 }, { 0.85, -0.35 } })
		crack(T1 * CFrame.new(0, 0, -1.17), { { -0.5, 0.35 }, { -0.75, 0.0 }, { -0.55, -0.35 } })
		crack(T2 * CFrame.Angles(0, rad(-90), 0) * CFrame.new(0, 0, -1.43), { { -0.4, 0.3 }, { 0.0, -0.05 }, { -0.2, -0.35 } })

		-- small mossy stone leaning on the right flank
		local S1 = cf(2.0, 0.32, -0.9, 0, 30, -6)
		tier(S1, 1.6, 1.4, 0.64, STONE_DK, STONE)
		tier(S1 * CFrame.new(0, 0.45, 0) * CFrame.Angles(0, rad(15), 0), 1.1, 0.95, 0.3, STONE_LT, STONE)

		---------------------------------------------------------------- moss
		-- blanket over the whole top tier: dark under-layer, main moss, bright patches
		tier(T3 * CFrame.new(0, 0.44, 0), 2.6, 2.2, 0.24, MOSS, MOSS)
		B:block(R, v(1.6, 0.2, 1.3), T3 * CFrame.new(-0.1, 0.62, 0.1) * CFrame.Angles(0, rad(20), 0), MOSS)
		B:block(R, v(0.9, 0.16, 0.8), T3 * CFrame.new(0.25, 0.76, -0.1) * CFrame.Angles(0, rad(40), 0), MOSS_LT)
		B:block(R, v(0.7, 0.14, 0.6), T3 * CFrame.new(-0.85, 0.6, 0.55) * CFrame.Angles(0, rad(10), 0), MOSS_LT)
		-- moss spilling down the top tier's sides
		B:block(R, v(2.2, 0.55, 0.22), T3 * CFrame.new(-0.1, 0.12, 1.0), MOSS_DK)
		B:block(R, v(0.22, 0.5, 1.4), T3 * CFrame.new(-1.2, 0.15, 0.1), MOSS_DK)
		B:block(R, v(1.0, 0.4, 0.22), T3 * CFrame.new(-0.6, 0.18, -1.0), MOSS)
		-- ledge moss on the middle tier (back and left), dripping down
		B:block(R, v(3.0, 0.22, 0.8), T2 * CFrame.new(-0.2, 0.5, 1.05), MOSS_DK)
		B:block(R, v(2.0, 0.6, 0.2), T2 * CFrame.new(-0.4, 0.15, 1.5), MOSS)
		B:block(R, v(1.1, 0.5, 0.2), T1 * CFrame.new(-0.6, 0.2, 1.65), MOSS_DK)
		B:block(R, v(0.8, 0.22, 1.8), T2 * CFrame.new(-1.4, 0.5, 0.2), MOSS)
		B:block(R, v(0.2, 0.6, 1.0), T2 * CFrame.new(-1.78, 0.1, 0.35), MOSS_DK)
		-- a little moss creeping over the front edge
		B:block(R, v(1.0, 0.22, 0.6), T2 * CFrame.new(-0.95, 0.5, -1.15), MOSS)
		B:block(R, v(0.7, 0.45, 0.2), T2 * CFrame.new(-1.0, 0.2, -1.5), MOSS_DK)
		-- moss cap on the small stone
		B:block(R, v(0.9, 0.16, 0.8), S1 * CFrame.new(-0.05, 0.66, 0.05), MOSS)
		B:block(R, v(0.5, 0.12, 0.45), S1 * CFrame.new(0.15, 0.78, -0.1), MOSS_LT)

		---------------------------------------------------------------- fern sprout
		local fb = v(-2.1, 0.15, -1.3)
		for i, f in { { -150, 1.1 }, { -60, 1.0 }, { 20, 0.9 } } do
			local a = rad(f[1])
			local dir = v(math.cos(a), 0, math.sin(a))
			local p1 = fb + dir * 0.35 * f[2] + v(0, 0.75 * f[2], 0)
			local p2 = p1 + dir * 0.6 * f[2] + v(0, 0.05, 0)
			B:bar(R, fb, p1, 0.16, 0.16, FERN_DK)
			B:bar(R, p1, p2, 0.14, 0.14, FERN_DK)
			local fr = P.aim(p1, p2)
			B:block(R, v(0.9 * f[2], 0.1, 0.45), CFrame.new(p1:Lerp(p2, 0.45)) * (fr - fr.Position) * CFrame.Angles(0, rad(90), 0), (i % 2 == 0) and FERN or FERN_LT)
			B:block(R, v(0.7 * f[2], 0.1, 0.35), CFrame.new(fb:Lerp(p1, 0.6)) * (fr - fr.Position) * CFrame.Angles(0, rad(90), 0), FERN)
			B:block(R, v(0.28, 0.1, 0.28), CFrame.new(p2) * CFrame.Angles(0, a, 0), FERN_LT)
		end
		B:block(R, v(0.45, 0.3, 0.45), CFrame.new(fb + v(0, 0.05, 0)), FERN_DK)

		---------------------------------------------------------------- footing
		B:block(R, v(2.2, 0.12, 1.4), cf(-1.3, 0.06, 0.9, 0, 20, 0), MOSS_DK)
		B:block(R, v(1.4, 0.16, 0.9), cf(-1.9, 0.08, 0.2, 0, -25, 0), MOSS)
		B:block(R, v(1.2, 0.12, 0.8), cf(1.4, 0.06, 1.3, 0, 35, 0), MOSS_DK)
		for _, s in { { 2.9, 0.6, 0.55, 20, STONE }, { 0.5, -2.0, 0.45, 60, STONE_LT }, { -2.7, -0.4, 0.4, 10, STONE_DK } } do
			local k = s[3]
			B:block(R, v(1.3 * k, 0.6 * k, k), cf(s[1], 0.3 * k, s[2], 0, s[4], 0), s[5])
		end
		for _, g in { { -2.6, 1.3, 15 }, { 2.6, 1.6, 50 }, { 1.2, -1.95, 80 } } do
			B:block(R, v(0.35, 0.8, 0.35), cf(g[1], 0.4, g[2], 6, g[3], 8), GRASS)
			B:block(R, v(0.3, 0.6, 0.3), cf(g[1] + 0.28, 0.3, g[2] + 0.12, -6, g[3] + 25, -12), GRASS_DK)
		end
		B:block(R, v(0.75, 0.08, 0.5), cf(-0.6, 0.04, -2.0, 0, 30, 0), LEAF_O)
		B:block(R, v(0.7, 0.08, 0.48), cf(3.0, 0.04, -0.4, 0, -50, 0), LEAF_Y)
	end,
}
