--!nocheck
-- Mossy Boulder Pile (Thorny Woods scenery, big copy-paste filler ~15 wide).
-- A big rock formation: a tall central boulder flanked by two medium ones and
-- two low stones, plus a flat slab that has toppled against the top. Every
-- boulder is built like the Mossy Rock filler: stacked chamfered tiers
-- (crossed slabs) that step in as they rise, dark at the foot, mid-grey in
-- the middle and pale on top, with lit and shaded flank lumps and zig-zag
-- cracks. Thick moss blankets the tops (dark under-layer, main moss, bright
-- patches) and drips down the sides. Fern clumps sprout between the rocks,
-- red fly-agaric toadstools cluster at the foot and on a ledge, and orange
-- shelf fungus clings to a flank. Footing: a flat patch of dirt and moss,
-- pebbles, grass tufts and fallen leaves. Anchored, weld-free, no scripts.
return {
	DisplayName = "Mossy Boulder Pile",
	Rarity = "Scenery",
	Filler = true,
	Element = "Thorny Woods",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Thorny Woods: Mossy Rock / Mushroom Log / Red Toadstools)
		local STONE_DK2, STONE_DK, STONE, STONE_LT = "#55534d", "#686660", "#8d8a80", "#a9a397"
		local MOSS_DK, MOSS, MOSS_LT = "#3f8a2c", "#5fae3a", "#86c94a"
		local FERN_DK, FERN, FERN_LT = "#1f6e3c", "#2f9a52", "#6fd06a"
		local RED_DK, RED, RED_LT = "#9a1a20", "#c8262a", "#de3a34"
		local SPOT, STALK, STALK_DK = "#fbf6ea", "#fdeecb", "#e4cb9a"
		local SHELF, SHELF_DK, SHELF_LT = "#d77a2c", "#a85620", "#eda04a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local DIRT, DIRT_DK = "#5a3a22", "#3e2716"
		local LEAF_O, LEAF_Y = "#c8612a", "#d99a2e"

		local seed = 4121
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		-- chamfered tier: two crossed slabs
		local function tier(C, w, d, h, c1, c2)
			B:block(R, v(w, h, d * 0.72), C, c1)
			B:block(R, v(w * 0.78, h - 0.02, d), C, c2 or c1)
		end
		local function crack(C, pts)
			for i = 1, #pts - 1 do
				local a = (C * CFrame.new(pts[i][1], pts[i][2], 0)).Position
				local b = (C * CFrame.new(pts[i + 1][1], pts[i + 1][2], 0)).Position
				B:bar(R, a, b, 0.2, 0.14, STONE_DK2)
			end
		end

		---------------------------------------------------------------- boulder
		-- three stepped tiers + a flank lump, moss blanket on top
		-- returns the CFrame of the top surface
		local function boulder(x, z, w, h, d, yaw, lumpSide, mossy)
			local h1, h2, h3 = h * 0.42, h * 0.34, h * 0.24
			local T1 = cf(x, h1 / 2, z, 0, yaw, 0)
			local T2 = cf(x, 0, z, 0, yaw, 0) * CFrame.new(-0.05 * w, h1 + h2 / 2 - 0.02, 0.03 * d) * ang(2, -6, -3)
			local T3 = cf(x, 0, z, 0, yaw, 0) * CFrame.new(-0.1 * w, h1 + h2 + h3 / 2 - 0.04, 0.06 * d) * ang(-3, 10, 4)
			tier(T1, w, d, h1, STONE_DK, STONE_DK)
			tier(T2, w * 0.86, d * 0.88, h2, STONE, STONE)
			tier(T3, w * 0.62, d * 0.64, h3, STONE_LT, STONE)
			-- flank lump breaks up the outline (lit or shaded side)
			local L = T1 * CFrame.new(lumpSide * w * 0.48, h1 * 0.1, -0.1 * d) * ang(6, 30, lumpSide * 8)
			tier(L, w * 0.42, d * 0.62, h1 * 0.9, lumpSide > 0 and STONE or STONE_DK, STONE_DK)
			B:block(R, v(w * 0.28, 0.3, d * 0.36), L * CFrame.new(0, h1 * 0.45 + 0.1, 0) * ang(0, 20, 0), STONE_LT)
			-- highlight ledge on the middle tier
			B:block(R, v(0.3, 0.14, d * 0.5), T2 * CFrame.new(lumpSide * 0.4 * w, h2 / 2 + 0.06, -0.1 * d), STONE_LT)
			-- crack on the front
			crack(T1 * CFrame.new(0, 0, -d * 0.36 - 0.02), { { 0.15 * w, 0.35 * h1 }, { -0.05 * w, 0.0 }, { 0.12 * w, -0.32 * h1 } })
			if mossy then
				local top = T3 * CFrame.new(0, h3 / 2, 0)
				tier(top * CFrame.new(0, 0.12, 0), w * 0.64, d * 0.66, 0.26, MOSS, MOSS)
				B:block(R, v(w * 0.36, 0.2, d * 0.36), top * CFrame.new(-0.05 * w, 0.32, 0.05 * d) * ang(0, 25, 0), MOSS_LT)
				-- moss spilling down the front, back and one side, and over the ledges
				B:block(R, v(w * 0.5, h3 * 0.8, 0.24), T3 * CFrame.new(0.05 * w, 0.1, -d * 0.33), MOSS_DK)
				B:block(R, v(w * 0.56, h3 * 0.8, 0.24), T3 * CFrame.new(0, 0.1, d * 0.33), MOSS_DK)
				B:block(R, v(0.24, h3 * 0.7, d * 0.5), T3 * CFrame.new(-lumpSide * w * 0.31, 0.12, 0), MOSS)
				B:block(R, v(w * 0.6, 0.22, d * 0.24), T2 * CFrame.new(-0.1 * w, h2 / 2 + 0.1, -0.38 * d), MOSS)
				B:block(R, v(w * 0.34, h2 * 0.65, 0.22), T2 * CFrame.new(-0.2 * w, h2 * 0.12, -0.45 * d), MOSS_DK)
				B:block(R, v(w * 0.7, 0.22, d * 0.3), T2 * CFrame.new(-0.05 * w, h2 / 2 + 0.1, 0.36 * d), MOSS_DK)
				B:block(R, v(w * 0.5, 0.22, d * 0.28), T1 * CFrame.new(0.15 * w, h1 / 2 + 0.1, -0.38 * d), MOSS_LT)
			end
			return T3 * CFrame.new(0, h3 / 2, 0), T2 * CFrame.new(0, h2 / 2, 0)
		end

		---------------------------------------------------------------- footing
		B:block(R, v(11.0, 0.14, 7.0), cf(0, 0.07, 0.8, 0, 6, 0), DIRT_DK)
		B:block(R, v(8.0, 0.2, 4.0), cf(-2.6, 0.1, -1.6, 0, -14, 0), MOSS_DK)
		B:block(R, v(3.0, 0.24, 1.8), cf(3.0, 0.12, -2.6, 0, 20, 0), DIRT)
		B:block(R, v(2.4, 0.22, 1.6), cf(5.2, 0.11, -2.2, 0, -25, 0), MOSS_DK)
		B:block(R, v(4.0, 0.22, 2.6), cf(4.0, 0.11, 3.6, 0, -10, 0), MOSS)

		---------------------------------------------------------------- rocks
		local top1, mid1 = boulder(0.4, 0.8, 6.6, 8.8, 5.6, 12, 1, true) -- tall centre
		local top2, mid2 = boulder(-5.2, 0.2, 5.0, 5.6, 4.6, -22, -1, true) -- left
		local top3 = boulder(5.3, 1.2, 4.8, 6.4, 4.6, 28, 1, true) -- right
		local top4 = boulder(-2.2, -3.6, 3.6, 2.8, 3.0, 35, -1, true) -- front low
		boulder(2.6, 4.6, 3.8, 3.6, 3.2, -15, 1, false) -- back low

		-- toppled slab leaning from the left boulder against the tall one
		local SL = top2 * CFrame.new(1.4, 0.7, 0.2) * ang(0, 30, 24)
		tier(SL, 4.6, 3.0, 1.1, STONE, STONE_DK)
		B:block(R, v(3.2, 0.24, 2.0), SL * CFrame.new(-0.2, 0.62, 0), MOSS)
		B:block(R, v(1.6, 0.2, 1.1), SL * CFrame.new(-0.6, 0.78, 0.2) * ang(0, 20, 0), MOSS_LT)

		-- scattered stones in front
		for _, s in { { 3.4, -3.6, 1.4, 0.8, 20 }, { -6.4, -2.8, 1.2, 0.7, -30 }, { 6.8, -1.8, 1.0, 0.6, 45 }, { -0.2, -5.0, 0.9, 0.5, 60 } } do
			tier(cf(s[1], s[4] / 2, s[2], 0, s[5], 0), s[3], s[3] * 0.85, s[4], STONE_DK, STONE)
			B:block(R, v(s[3] * 0.55, 0.16, s[3] * 0.5), cf(s[1] - 0.05, s[4] + 0.07, s[2], 0, s[5] + 20, 0), STONE_LT)
		end

		---------------------------------------------------------------- shelf fungus
		local SF = mid1 * CFrame.new(2.2, -1.4, -2.3)
		for i, sh in { { 0, 0, 1.6 }, { 0.5, -0.8, 1.2 }, { -0.3, 0.75, 1.0 } } do
			local C = SF * CFrame.new(sh[1], sh[2], 0)
			B:block(R, v(sh[3], 0.32, sh[3] * 0.7), C * CFrame.new(0, 0, -0.2), i == 1 and SHELF or SHELF_DK)
			B:block(R, v(sh[3] * 0.7, 0.14, sh[3] * 0.45), C * CFrame.new(0, 0.2, -0.25), SHELF_LT)
		end

		---------------------------------------------------------------- ferns
		local function fern(x, z, sz, rot, n)
			local base = v(x, 0.2, z)
			B:block(R, v(0.7 * sz, 0.5 * sz, 0.7 * sz), cf(x, 0.25 * sz, z, 0, rot, 0), FERN_DK)
			for k = 0, n - 1 do
				local a = rad(rot + k * 360 / n + rnd(-12, 12))
				local d = v(math.sin(a), 0, math.cos(a))
				local p1 = base + d * (1.1 * sz) + v(0, 1.5 * sz, 0)
				local p2 = p1 + d * (1.2 * sz) + v(0, -0.5 * sz, 0)
				B:bar(R, base, p1, 0.6 * sz, 0.18, (k % 2 == 0) and FERN or FERN_DK)
				B:bar(R, p1, p2, 0.48 * sz, 0.14, (k % 2 == 0) and FERN_LT or FERN)
			end
		end
		fern(-4.0, -2.4, 1.45, 10, 6) -- between the left and front rocks
		fern(3.4, -2.6, 1.3, 40, 5) -- foot of the tall rock
		fern(-7.4, 1.8, 1.2, 70, 5)
		fern(7.6, 2.6, 1.2, 20, 5)

		---------------------------------------------------------------- toadstools
		local function toadstool(C, k, h)
			B:block(R, v(0.6 * k, h, 0.6 * k), C * CFrame.new(0, h / 2, 0), STALK)
			B:block(R, v(0.66 * k, 0.4 * h, 0.66 * k), C * CFrame.new(0, 0.2 * h, 0), STALK_DK)
			local top = C * CFrame.new(0, h, 0)
			B:block(R, v(2.0 * k, 0.4 * k, 2.0 * k), top * CFrame.new(0, 0.2 * k, 0), RED_DK)
			B:block(R, v(1.55 * k, 0.45 * k, 1.55 * k), top * CFrame.new(0, 0.6 * k, 0) * ang(0, 45, 0), RED)
			B:block(R, v(0.95 * k, 0.3 * k, 0.95 * k), top * CFrame.new(0, 0.95 * k, 0), RED_LT)
			B:block(R, v(0.4 * k, 0.1, 0.4 * k), top * CFrame.new(-0.2 * k, 1.12 * k, 0.15 * k) * ang(0, 30, 0), SPOT)
			B:block(R, v(0.36 * k, 0.36 * k, 0.1), top * CFrame.new(0.3 * k, 0.6 * k, -0.78 * k), SPOT)
		end
		toadstool(cf(1.0, 0, -3.6, 0, 20, -8), 1.25, 1.6)
		toadstool(cf(2.0, 0, -4.4, 0, -15, 10), 0.85, 1.0)
		toadstool(cf(-5.8, 0, -2.4, 0, 40, 6), 0.95, 1.2)
		toadstool(top4 * CFrame.new(0.2, 0.2, 0) * ang(0, 30, -6), 0.8, 1.0) -- on the low stone
		toadstool(top2 * CFrame.new(-0.6, 0.25, 0.3) * ang(0, -20, 8), 0.7, 0.8) -- on the left boulder

		---------------------------------------------------------------- details
		for _, g in { { -7.6, -0.8, 15 }, { 7.8, -0.4, 50 }, { -1.6, -5.2, 80 }, { 4.8, -3.8, 30 }, { -4.6, 3.8, 65 } } do
			B:block(R, v(0.45, 1.0, 0.45), cf(g[1], 0.5, g[2], 6, g[3], 8), GRASS)
			B:block(R, v(0.35, 0.7, 0.35), cf(g[1] + 0.35, 0.35, g[2] + 0.2, -6, g[3] + 25, -10), GRASS_DK)
		end
		for _, l in { { -4.4, -4.2, LEAF_O }, { 5.6, -3.0, LEAF_Y }, { 0.0, -5.8, LEAF_O }, { -7.8, 2.6, LEAF_Y } } do
			B:block(R, v(0.8, 0.12, 0.6), cf(l[1], 0.06, l[2], 0, rnd(0, 90), 0), l[3])
		end
	end,
}
