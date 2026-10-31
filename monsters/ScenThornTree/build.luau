--!nocheck
-- Thorny Oak (Thorny Woods scenery, big copy-paste filler ~18 studs).
-- A dark, gnarled oak: a twisted trunk of stacked, turning bark blocks with
-- spiral ridges, thick roots clawing out over the forest floor, and five
-- crooked elbowed limbs holding a broad, clumpy crown of deep-green leaf
-- cubes (dark underneath, brighter stepped caps on top). A thorny briar cane
-- spirals up the trunk bristling with cream thorns, more canes droop from
-- the limbs, and a few crimson / pink briar roses bloom on them. Footing: a
-- flat patch of dark dirt and moss, pebbles, grass tufts and fallen petals.
-- Anchored, weld-free, no scripts.
return {
	DisplayName = "Thorny Oak",
	Rarity = "Scenery",
	Filler = true,
	Element = "Thorny Woods",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Thorny Woods: Mushroom Log / Bramble Archway)
		local BARK_BK, BARK_DK, BARK, BARK_LT = "#1e120a", "#3a2415", "#4e311c", "#65412a"
		local LEAF_DK, LEAF, LEAF_MID, LEAF_LT = "#1d6a35", "#26803e", "#33984a", "#52b457"
		local CANE, CANE_DK, CANE_LT = "#3f7a2e", "#2c5a22", "#4f8f34"
		local THORN, THORN_TIP = "#ecdfb8", "#a01838"
		local ROSE, ROSE_DK, ROSE_LT, ROSE_HI = "#d8203e", "#9a1430", "#ff5a77", "#ff9aae"
		local PINK, PINK_DK, PINK_LT = "#ff86b3", "#e8588f", "#ffc4da"
		local MOSS, MOSS_DK, MOSS_LT = "#5fae3a", "#3f8a2c", "#86c94a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT = "#8d8a80", "#a9a397"
		local DIRT, DIRT_DK = "#5a3a22", "#3e2716"
		local PETAL = "#ff8fa6"

		local seed = 4101
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function look(p, dir)
			local d = dir.Unit
			return (P.aim(p - d, p + d))
		end

		---------------------------------------------------------------- footing
		B:block(R, v(6.4, 0.14, 5.6), cf(0, 0.07, 0, 0, 14, 0), DIRT_DK)
		B:block(R, v(4.4, 0.2, 3.6), cf(-1.2, 0.1, 1.0, 0, -22, 0), MOSS_DK)
		B:block(R, v(2.6, 0.24, 2.0), cf(1.8, 0.12, -1.6, 0, 30, 0), DIRT)
		B:block(R, v(1.6, 0.28, 1.2), cf(-2.6, 0.14, -1.8, 0, 50, 0), MOSS)
		B:block(R, v(1.1, 0.55, 0.9), cf(3.6, 0.27, 1.8, 4, 25, -4), STONE)
		B:block(R, v(0.6, 0.3, 0.5), cf(3.4, 0.62, 1.85, 0, 50, 0), STONE_LT)
		B:block(R, v(0.8, 0.36, 0.6), cf(-3.8, 0.18, 2.6, 0, 60, 0), STONE)
		for _, g in { { -4.4, -1.2, 15 }, { 4.6, -1.4, 50 }, { 0.6, 4.4, 80 }, { -1.6, -4.2, 30 }, { 2.4, 3.8, 65 } } do
			B:block(R, v(0.45, 1.0, 0.45), cf(g[1], 0.5, g[2], 6, g[3], 8), GRASS)
			B:block(R, v(0.35, 0.7, 0.35), cf(g[1] + 0.35, 0.35, g[2] + 0.2, -6, g[3] + 25, -10), GRASS_DK)
		end
		for _, p in { { 1.4, -3.6, PETAL }, { -2.8, 0.2, ROSE }, { 3.0, 0.6, PETAL }, { -0.6, 3.4, ROSE } } do
			B:block(R, v(0.6, 0.08, 0.45), cf(p[1], 0.04, p[2], 0, rnd(0, 90), 0), p[3])
		end

		---------------------------------------------------------------- roots
		local roots = {
			{ 20, 3.6, BARK_DK }, { 95, 3.0, BARK }, { 160, 3.8, BARK_DK }, { 235, 3.2, BARK }, { 300, 3.4, BARK_DK },
		}
		for _, r in roots do
			local a = rad(r[1])
			local d = v(math.sin(a), 0, math.cos(a))
			local p0 = v(0, 1.6, 0) + d * 0.9
			local p1 = d * (r[2] * 0.55) + v(0, 0.6, 0)
			local p2 = d * r[2] + v(0, 0.2, 0) + v(d.Z, 0, -d.X) * 0.6
			B:bar(R, p0, p1, 1.2, 1.0, r[3])
			B:bar(R, p1, p2, 0.8, 0.6, BARK_LT)
		end

		---------------------------------------------------------------- twisted trunk
		-- stacked, turning bark blocks that zig-zag and lean as they rise
		local function tcen(y)
			local t = y / 1.6
			return v(0.6 * math.sin(t * 1.1) + 0.06 * y, y, 0.5 * math.cos(t * 0.85) - 0.5)
		end
		local segs = 7
		for i = 0, segs - 1 do
			local y = 0.9 + i * 1.55
			local w = 3.4 - i * 0.18
			local c = tcen(y)
			B:block(R, v(w, 1.9, w), cf(c.X, y, c.Z, 0, i * 19, (i % 2 == 0) and 4 or -4), (i % 2 == 0) and BARK or BARK_DK)
		end
		-- spiral ridges winding up the bark
		for j = 0, 1 do
			local prev
			for k = 0, 7 do
				local y = 0.6 + k * 1.4
				local a = rad(j * 180 + k * 50)
				local r = 1.72 - k * 0.08
				local p = tcen(y) + v(math.sin(a) * r, 0, math.cos(a) * r)
				if prev then
					B:bar(R, prev, p, 0.6, 0.6, (j == 0) and BARK_LT or BARK_BK)
				end
				prev = p
			end
		end
		-- knot hole
		local kc = tcen(4.6)
		B:block(R, v(1.1, 1.2, 0.3), cf(kc.X + 0.3, 4.6, kc.Z - 1.62), BARK_LT)
		B:block(R, v(0.7, 0.8, 0.32), cf(kc.X + 0.3, 4.6, kc.Z - 1.67), BARK_BK)

		---------------------------------------------------------------- limbs
		-- crooked three-part limbs with knobbly elbows
		local TOP = tcen(10.4)
		local function limb(pts, w)
			for i = 1, #pts - 1 do
				local ww = w * (1 - (i - 1) * 0.25)
				B:bar(R, pts[i], pts[i + 1], ww, ww, (i == 1) and BARK or (i == 2 and BARK_LT or BARK_DK))
				if i < #pts - 1 then
					B:block(R, v(ww + 0.2, ww + 0.2, ww + 0.2), CFrame.new(pts[i + 1]) * ang(15, 30, 10), BARK_DK)
				end
			end
		end
		limb({ TOP + v(0.4, -0.6, 0), TOP + v(2.8, 0.6, -0.6), TOP + v(4.6, 2.4, -1.4), TOP + v(7.4, 3.0, -2.0) }, 1.5)
		limb({ TOP + v(-0.4, -0.4, 0), TOP + v(-2.6, 1.0, 0.8), TOP + v(-4.8, 1.8, 1.2), TOP + v(-7.0, 2.8, 2.8) }, 1.5)
		limb({ TOP + v(0, 0, 0.4), TOP + v(1.2, 1.6, 2.4), TOP + v(0.4, 2.6, 4.2), TOP + v(1.2, 3.4, 6.6) }, 1.3)
		limb({ TOP + v(0, 0, -0.4), TOP + v(-1.6, 1.4, -2.2), TOP + v(-0.8, 2.8, -4.0), TOP + v(-1.6, 3.6, -6.4) }, 1.3)
		limb({ TOP + v(0, 0, 0), TOP + v(-0.6, 2.4, 0.2), TOP + v(0.4, 4.4, 0.0), TOP + v(0.2, 6.0, 0.2) }, 1.4)
		-- bare crooked twigs poking out of the crown
		B:bar(R, TOP + v(3.0, 3.6, -1.0), TOP + v(4.4, 6.6, -1.8), 0.45, 0.45, BARK_DK)
		B:bar(R, TOP + v(-3.4, 3.2, 1.2), TOP + v(-4.4, 6.4, 1.6), 0.45, 0.45, BARK_DK)
		B:bar(R, TOP + v(0.6, 3.6, 4.8), TOP + v(-0.4, 6.0, 7.0), 0.4, 0.4, BARK_DK)

		---------------------------------------------------------------- crown
		local function leaf(x, y, z, s, col, capCol)
			local C = cf(x, y, z, rnd(-16, 16), rnd(0, 90), rnd(-16, 16))
			B:block(R, v(s, s, s), C, col)
			if capCol then
				B:block(R, v(0.7 * s, 0.3 * s, 0.7 * s), C * CFrame.new(0.05 * s, 0.56 * s, -0.04 * s) * ang(0, 35, 0), capCol)
			end
		end
		-- separate clumps at the limb tips, gaps between them show the limbs
		local function clump(c, r, n)
			leaf(c.X, c.Y, c.Z, r * 1.5, LEAF, nil)
			local off = rnd(0, 360)
			for i = 0, n - 1 do
				local a = rad(off + i * 360 / n)
				leaf(c.X + math.sin(a) * r, c.Y - r * 0.35, c.Z + math.cos(a) * r, r * rnd(1.1, 1.25), (i % 2 == 0) and LEAF_DK or LEAF, nil)
			end
			for i = 0, 1 do
				local a = rad(off + 60 + i * 180)
				leaf(c.X + math.sin(a) * r * 0.5, c.Y + r * 0.5, c.Z + math.cos(a) * r * 0.5, r * rnd(1.0, 1.1), (i == 0) and LEAF_MID or LEAF, LEAF_LT)
			end
		end
		clump(TOP + v(7.6, 3.6, -2.0), 2.4, 4)
		clump(TOP + v(-7.2, 3.4, 2.8), 2.4, 4)
		clump(TOP + v(1.2, 4.0, 6.8), 2.3, 4)
		clump(TOP + v(-1.6, 4.2, -6.6), 2.3, 4)
		clump(TOP + v(0.2, 6.2, 0.2), 2.8, 5)

		-- briar thorns bristling out of the foliage
		for _, t in { { 9.4, 4.0, -2.4, 1, 0.3, -0.2 }, { -9.0, 3.6, 3.4, -1, 0.3, 0.3 }, { 1.6, 4.4, 8.8, 0.2, 0.3, 1 }, { -2.0, 4.8, -8.6, -0.2, 0.4, -1 }, { 3.6, 8.0, 2.2, 0.6, 1, 0.3 }, { -3.4, 7.6, -1.6, -0.6, 1, -0.3 }, { 6.2, 2.4, 3.6, 0.7, -0.2, 0.7 } } do
			local p0 = TOP + v(t[1], t[2], t[3])
			local f = look(p0, v(t[4], t[5], t[6]))
			B:block(R, v(0.5, 0.5, 0.9), f, BARK_LT)
			B:block(R, v(0.26, 0.26, 0.5), f * CFrame.new(0, 0, -0.65), THORN)
		end

		---------------------------------------------------------------- briar
		local function thorn(a, b, sgn)
			local d = (b - a).Unit
			local side = d:Cross(v(0, 1, 0))
			if side.Magnitude < 0.1 then
				side = v(1, 0, 0)
			end
			local mid = a:Lerp(b, 0.5)
			local f = look(mid, (side.Unit * sgn + v(0, 0.35, 0)).Unit)
			B:block(R, v(0.3, 0.3, 0.42), f * CFrame.new(0, 0, -0.45), THORN)
			B:block(R, v(0.16, 0.16, 0.24), f * CFrame.new(0, 0, -0.75), THORN_TIP)
		end
		local function cane(pts, w)
			for i = 1, #pts - 1 do
				B:bar(R, pts[i], pts[i + 1], w, w, (i % 2 == 0) and CANE or CANE_DK)
				if i % 2 == 1 then
					thorn(pts[i], pts[i + 1], (i % 4 == 1) and 1 or -1)
				end
			end
		end
		-- spiral up the trunk
		local sp = {}
		for k = 0, 7 do
			local y = 0.5 + k * 1.35
			local a = rad(200 + k * 70)
			local r = 1.95 - k * 0.07
			sp[#sp + 1] = tcen(y) + v(math.sin(a) * r, 0, math.cos(a) * r)
		end
		cane(sp, 0.5)
		-- canes drooping from the limbs
		local d1 = { TOP + v(3.4, 1.4, -1.0), TOP + v(4.0, 0.0, -1.8), TOP + v(3.8, -1.4, -2.2), TOP + v(4.4, -2.6, -2.0), TOP + v(4.2, -3.6, -2.4) }
		local d2 = { TOP + v(-3.6, 1.5, 0.9), TOP + v(-4.2, 0.2, 1.6), TOP + v(-4.0, -1.2, 2.2), TOP + v(-4.6, -2.2, 2.4) }
		local d3 = { TOP + v(0.8, 2.2, 3.1), TOP + v(1.6, 0.8, 3.8), TOP + v(1.4, -0.6, 4.2) }
		cane(d1, 0.4)
		cane(d2, 0.4)
		cane(d3, 0.36)

		---------------------------------------------------------------- roses
		local function rose(p, dir, k, pink)
			local c1, c2, c3, c4 = ROSE_DK, ROSE, ROSE_LT, ROSE_HI
			if pink then
				c1, c2, c3, c4 = PINK_DK, PINK, PINK_LT, "#fff0f5"
			end
			local f = look(p, dir)
			B:block(R, v(1.8 * k, 0.6 * k, 0.25), f * CFrame.new(0, 0, 0.1) * ang(0, 0, 30), LEAF)
			B:block(R, v(1.5 * k, 1.5 * k, 0.6 * k), f * CFrame.new(0, 0, -0.2 * k), c1)
			B:block(R, v(1.3 * k, 1.3 * k, 0.55 * k), f * CFrame.new(0, 0, -0.5 * k) * ang(0, 0, 45), c2)
			B:block(R, v(0.85 * k, 0.85 * k, 0.45 * k), f * CFrame.new(0, 0, -0.8 * k) * ang(0, 0, 20), c3)
			B:block(R, v(0.4 * k, 0.4 * k, 0.3 * k), f * CFrame.new(0, 0, -1.02 * k) * ang(0, 0, 65), c4)
		end
		rose(sp[5] + v(0, 0.2, -0.4), v(-0.3, 0.3, -1), 1.3, false) -- on the trunk vine
		rose(d1[5] + v(0, -0.5, 0), v(0.3, -0.3, -1), 1.3, false) -- ends of the drooping canes
		rose(d2[4] + v(0, -0.5, 0), v(-0.5, -0.2, 1), 1.2, true)
		rose(d3[3] + v(0, -0.4, 0), v(0.4, -0.2, 1), 1.1, false)
		rose(TOP + v(-2.8, 3.0, -8.0), v(-0.2, 0.2, -1), 1.3, false) -- tucked into the crown
		rose(TOP + v(4.4, 7.0, 0.8), v(0.6, 0.6, 0.4), 1.2, true)
	end,
}
