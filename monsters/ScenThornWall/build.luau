--!nocheck
-- Bramble Hedge Wall (Thorny Woods scenery, big copy-paste filler, 14 wide).
-- A long, tall briar hedge, 14 studs per tile: a dark-green core and a dirt
-- strip that tile end to end without gaps, dressed with big lumpy leaf cubes
-- on both faces and along the top, every lump on the same 2.8-stud rhythm
-- so the pattern carries on across the seam (the rounded end lumps hide
-- inside the neighbour when tiled). Dark cubes sit low, mid-green cubes
-- higher up and bright stepped caps crown the top. Thorny briar canes arch
-- and loop out of the hedge bristling with cream thorns tipped crimson, and
-- crimson / pink briar roses and buds bloom on both faces. Footing: a flat
-- dirt strip with moss, pebbles, grass tufts and fallen petals.
-- Anchored, weld-free, no scripts.
return {
	DisplayName = "Bramble Hedge Wall",
	Rarity = "Scenery",
	Filler = true,
	Element = "Thorny Woods",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Thorny Woods: Bramble Archway / Bramble Clump)
		local LEAF_DK, LEAF, LEAF_MID, LEAF_LT, LEAF_TOP = "#1d6a35", "#26803e", "#33984a", "#52b457", "#6fba45"
		local CANE, CANE_DK, CANE_LT = "#3f7a2e", "#2c5a22", "#4f8f34"
		local THORN, THORN_TIP = "#ecdfb8", "#a01838"
		local ROSE, ROSE_DK, ROSE_LT, ROSE_HI = "#d8203e", "#9a1430", "#ff5a77", "#ff9aae"
		local PINK, PINK_DK, PINK_LT = "#ff86b3", "#e8588f", "#ffc4da"
		local MOSS, MOSS_DK = "#5fae3a", "#3f8a2c"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT = "#8d8a80", "#a9a397"
		local DIRT, DIRT_DK = "#5a3a22", "#3e2716"
		local PETAL = "#ff8fa6"

		local seed = 4111
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function look(p, dir)
			local d = dir.Unit
			return (P.aim(p - d, p + d))
		end

		local W = 14 -- tile length along X
		local XS = { -5.6, -2.8, 0, 2.8, 5.6 } -- lump rhythm (2.8 across the seam too)

		---------------------------------------------------------------- footing
		B:block(R, v(W, 0.14, 5.6), cf(0, 0.07, 0), DIRT_DK)
		B:block(R, v(W, 0.2, 4.4), cf(0, 0.1, 0), DIRT)
		for _, m in { { -4.6, -2.6, 2.4 }, { 1.6, 2.7, 2.8 }, { 4.8, -2.7, 1.8 }, { -2.0, 2.8, 1.6 } } do
			B:block(R, v(m[3], 0.26, 1.0), cf(m[1], 0.13, m[2], 0, rnd(-15, 15), 0), MOSS_DK)
		end
		for _, st in { { -6.0, -3.0 }, { 3.4, 3.1 } } do
			B:block(R, v(0.9, 0.45, 0.7), cf(st[1], 0.22, st[2], 0, rnd(0, 90), 0), STONE)
			B:block(R, v(0.5, 0.25, 0.4), cf(st[1] - 0.1, 0.55, st[2], 0, rnd(0, 90), 0), STONE_LT)
		end
		for _, g in { { -3.4, -3.1, 15 }, { 2.0, -3.2, 50 }, { 5.6, 3.0, 80 }, { -5.4, 3.0, 30 }, { 0.2, 3.2, 65 } } do
			B:block(R, v(0.45, 1.0, 0.45), cf(g[1], 0.5, g[2], 6, g[3], 8), GRASS)
			B:block(R, v(0.35, 0.7, 0.35), cf(g[1] + 0.35, 0.35, g[2] + 0.2, -6, g[3] + 25, -10), GRASS_DK)
		end
		for _, p in { { -1.2, -3.4, PETAL }, { 4.2, -3.2, ROSE }, { -4.4, 3.4, PETAL }, { 2.8, 3.4, ROSE } } do
			B:block(R, v(0.6, 0.08, 0.45), cf(p[1], 0.04, p[2], 0, rnd(0, 90), 0), p[3])
		end

		---------------------------------------------------------------- hedge core
		B:block(R, v(W - 0.6, 4.8, 3.4), cf(0, 2.6, 0), LEAF_DK)
		B:block(R, v(W - 0.6, 1.6, 2.6), cf(0, 5.6, 0), LEAF)

		---------------------------------------------------------------- lumps
		local function cube(x, y, z, s, col, capCol)
			local C = cf(x, y, z, rnd(-12, 12), rnd(-20, 20), rnd(-12, 12))
			B:block(R, v(s, s, s), C, col)
			if capCol then
				B:block(R, v(0.7 * s, 0.3 * s, 0.7 * s), C * CFrame.new(0.05 * s, 0.56 * s, -0.04 * s) * ang(0, 35, 0), capCol)
			end
		end
		for i, x in XS do
			for _, side in { -1, 1 } do
				local o = (side > 0) and 1.4 or 0 -- back face rhythm shifted half a step
				local xx = x + o
				if xx > 6.9 then
					xx = xx - W
				end
				local alt = (i + (side > 0 and 1 or 0)) % 2 == 0
				cube(xx, 1.9, side * 1.65, rnd(2.8, 3.1), alt and LEAF or LEAF_DK, nil)
				cube(xx + rnd(-0.3, 0.3), 4.4 + rnd(-0.2, 0.3), side * 1.45, rnd(2.6, 3.0), alt and LEAF_MID or LEAF, alt and LEAF_TOP or nil)
			end
			-- top lumps: a front and a back row at different heights, bright caps
			local hi = (i % 2 == 0)
			cube(x, hi and 7.6 or 6.5, -0.6, hi and rnd(3.2, 3.4) or rnd(2.6, 2.8), hi and LEAF_LT or LEAF_MID, hi and LEAF_TOP or LEAF_LT)
			local xb = x + 1.4
			if xb > 6.9 then
				xb = xb - W
			end
			cube(xb, hi and 6.3 or 7.1, 0.7, rnd(2.5, 2.8), hi and LEAF or LEAF_MID, LEAF_LT)
		end

		-- rounded ends (hidden inside the neighbour when walls are tiled)
		for _, sx in { -1, 1 } do
			cube(sx * 6.3, 2.4, sx * 0.2, 3.3, LEAF_DK, nil)
			cube(sx * 6.1, 5.0, -sx * 0.2, 2.8, LEAF, LEAF_LT)
		end

		-- ragged flat leaves along the outline (blade + pale vein)
		local edge = {
			{ -4.2, 1.0, -3.3, 10, 20, LEAF }, { 1.4, 1.1, -3.3, -15, -24, LEAF_MID }, { 5.0, 3.4, -3.0, 20, 26, LEAF_LT },
			{ -1.8, 3.6, -3.0, -10, -22, LEAF_LT }, { -2.6, 1.0, 3.3, 190, 22, LEAF }, { 3.4, 1.2, 3.3, 165, -20, LEAF_MID },
			{ 0.2, 3.8, 3.0, 175, 24, LEAF_LT }, { -5.4, 3.6, 3.0, 190, -26, LEAF_MID },
		}
		for _, e in edge do
			local C = cf(e[1], e[2], e[3], 0, e[4], 0) * ang(e[5], 0, 0)
			B:block(R, v(1.6, 0.26, 1.2), C, e[6])
			B:block(R, v(1.2, 0.08, 0.14), C * CFrame.new(0, 0.16, 0), LEAF_TOP)
		end

		---------------------------------------------------------------- briar canes
		local function thorn(a, b, sgn)
			local d = (b - a).Unit
			local side = d:Cross(v(0, 1, 0))
			if side.Magnitude < 0.1 then
				side = v(1, 0, 0)
			end
			local mid = a:Lerp(b, 0.5)
			local f = look(mid, (side.Unit * sgn + v(0, 0.4, 0)).Unit)
			B:block(R, v(0.3, 0.3, 0.42), f * CFrame.new(0, 0, -0.42), THORN)
			B:block(R, v(0.16, 0.16, 0.24), f * CFrame.new(0, 0, -0.72), THORN_TIP)
		end
		local function cane(pts)
			for i = 1, #pts - 1 do
				local w = 0.6 - i * 0.05
				B:bar(R, pts[i], pts[i + 1], w, w, ({ CANE_DK, CANE, CANE_LT })[(i - 1) % 3 + 1])
				if i >= 2 then
					thorn(pts[i], pts[i + 1], (i % 2 == 0) and 1 or -1)
				end
			end
		end
		-- arching up out of the top and curling over a face
		cane({ v(-4.4, 6.6, 0.2), v(-3.8, 8.4, -0.4), v(-2.6, 9.2, -1.2), v(-1.6, 8.6, -2.0), v(-1.2, 7.4, -2.4) })
		cane({ v(2.0, 6.8, -0.2), v(2.6, 8.6, 0.4), v(3.8, 9.4, 1.2), v(4.8, 8.8, 1.9), v(5.2, 7.6, 2.3) })
		-- lunging out sideways from the faces
		cane({ v(0.8, 3.2, -1.8), v(1.4, 3.8, -3.0), v(2.4, 3.6, -3.6), v(3.0, 2.9, -3.8) })
		cane({ v(-2.0, 3.0, 1.8), v(-2.6, 3.6, 3.0), v(-3.6, 3.4, 3.6), v(-4.2, 2.7, 3.8) })
		-- a long cane looping across the front face
		cane({ v(-6.4, 5.2, -1.6), v(-5.4, 6.4, -2.6), v(-3.8, 6.6, -3.0), v(-2.4, 5.8, -3.1), v(-1.6, 4.6, -3.2) })
		cane({ v(6.4, 5.0, 1.6), v(5.6, 6.2, 2.6), v(4.2, 6.4, 3.0), v(2.8, 5.6, 3.1), v(1.8, 4.6, 3.2) })

		---------------------------------------------------------------- roses
		local function rose(p, dir, k, pink)
			local c1, c2, c3, c4 = ROSE_DK, ROSE, ROSE_LT, ROSE_HI
			if pink then
				c1, c2, c3, c4 = PINK_DK, PINK, PINK_LT, "#fff0f5"
			end
			local f = look(p, dir)
			B:block(R, v(1.8 * k, 0.6 * k, 0.25), f * CFrame.new(0, 0, 0.1) * ang(0, 0, 30), LEAF_LT)
			B:block(R, v(1.5 * k, 1.5 * k, 0.6 * k), f * CFrame.new(0, 0, -0.2 * k), c1)
			B:block(R, v(1.3 * k, 1.3 * k, 0.55 * k), f * CFrame.new(0, 0, -0.5 * k) * ang(0, 0, 45), c2)
			B:block(R, v(0.85 * k, 0.85 * k, 0.45 * k), f * CFrame.new(0, 0, -0.8 * k) * ang(0, 0, 20), c3)
			B:block(R, v(0.4 * k, 0.4 * k, 0.3 * k), f * CFrame.new(0, 0, -1.02 * k) * ang(0, 0, 65), c4)
		end
		local function bud(p, dir)
			local f = look(p, dir)
			B:block(R, v(0.6, 0.6, 0.4), f, CANE)
			B:block(R, v(0.55, 0.55, 0.6), f * CFrame.new(0, 0, -0.4), ROSE_DK)
			B:block(R, v(0.34, 0.34, 0.4), f * CFrame.new(0, 0, -0.75) * ang(0, 0, 45), ROSE)
		end
		-- front face (-Z)
		rose(v(-5.0, 3.4, -3.25), v(-0.2, 0.25, -1), 1.3, false)
		rose(v(1.6, 5.4, -2.95), v(0.2, 0.35, -1), 1.15, true)
		rose(v(-1.2, 7.3, -2.6), v(0, -0.2, -1), 1.1, false) -- on the arching cane tip
		rose(v(4.2, 2.2, -3.3), v(0.3, 0.1, -1), 1.05, false)
		-- back face (+Z)
		rose(v(4.6, 4.0, 3.2), v(0.2, 0.25, 1), 1.3, false)
		rose(v(-2.4, 5.6, 2.95), v(-0.2, 0.35, 1), 1.15, true)
		rose(v(5.2, 7.5, 2.5), v(0, -0.2, 1), 1.1, false)
		-- buds
		bud(v(3.0, 2.9, -3.9), v(0.4, -0.2, -1))
		bud(v(-4.2, 2.7, 3.9), v(-0.4, -0.2, 1))
		bud(v(-3.6, 9.3, -0.8), v(0, 1, -0.3))
	end,
}
