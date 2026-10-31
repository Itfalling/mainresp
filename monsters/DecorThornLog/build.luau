--!nocheck
-- Mossy Mushroom Log (Thorny Woods decoration, medium accent).
-- A fallen, hollow old log lying on the forest floor: an octagonal tube of
-- chunky dark-bark slabs with a clean cut end (pale end-grain rings around a
-- dark hollow, two tiny mint-glow mushrooms peeking out) and a broken,
-- splintered far end. A thick moss blanket drapes over its back, a cluster of
-- red-and-cream toadstools sprouts from the top, orange shelf fungi step up
-- its front, and a thorny briar cane with a crimson rose arches over it.
-- Fern clumps, grass tufts, flat stones, fallen leaves and rose petals make a
-- small integrated footing. Static prop: no motion.luau.
return {
	DisplayName = "Mossy Mushroom Log",
	Rarity = "Decor",
	Element = "Thorny Woods",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Thorny Woods)
		local BARK_BK, BARK_DK, BARK, BARK_LT = "#1e120a", "#3a2415", "#4e311c", "#65412a"
		local GRAIN, GRAIN_LT, GRAIN_DK = "#c9995e", "#e2bb80", "#a0723f"
		local MOSS, MOSS_DK, MOSS_LT = "#5fae3a", "#3f8a2c", "#86c94a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8a80", "#a9a397", "#686660"
		local DIRT, DIRT_DK = "#5a3a22", "#3e2716"
		local RED_DK, RED, RED_LT = "#9a1a20", "#c8262a", "#e2433a"
		local SPOT, STALK = "#fbf6ea", "#f6e6c2"
		local SHELF, SHELF_DK, SHELF_LT = "#d77a2c", "#a85620", "#eda04a"
		local FERN, FERN_DK, FERN_LT = "#2f9a52", "#1f6e3c", "#6fd06a"
		local CANE, CANE_DK = "#3f7a2e", "#2c5a22"
		local THORN, THORN_TIP = "#ecdfb8", "#a01838"
		local ROSE, ROSE_DK, ROSE_LT = "#d8203e", "#9a1430", "#ff5a77"
		local LEAF_O, LEAF_Y, PETAL = "#c8612a", "#d99a2e", "#ff8fa6"
		local GLOW = "#9dffc4"

		local seed = 2101
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local R = "Root"
		-- frame at p whose -Z points along dir (P.aim is exact; CFrame.lookAt mis-aims in Lune)
		local function look(p, dir)
			local d = dir.Unit
			return (P.aim(p - d, p + d))
		end

		---------------------------------------------------------------- log
		local LEN = 10
		local RO = 2.0 -- outer apothem
		local TH = 0.8
		local LC = CFrame.new(0, RO + 0.2, 0.2) * ang(0, 196, 0)
		local function at(x, y, z)
			return (LC * CFrame.new(x, y, z)).Position
		end
		-- 8 bark slabs; the +X end is broken (ragged lengths)
		local ragged = { 0.0, 0.9, 0.3, -0.6, 0.5, 1.2, -0.2, 0.7 }
		for i = 0, 7 do
			local a = i * 45
			local ext = ragged[i + 1]
			local len = LEN + ext
			local q = LC * CFrame.Angles(rad(a), 0, 0) * CFrame.new(ext / 2, RO - TH / 2, 0)
			B:block(R, v(len, TH, 1.72), q, (i % 2 == 0) and BARK or BARK_DK)
			-- splinter on the broken end
			if ext > 0.2 then
				B:block(R, v(0.9, TH * 0.6, 0.6), LC * CFrame.Angles(rad(a), 0, 0) * CFrame.new(LEN / 2 + ext + 0.35, RO - TH / 2, rnd(-0.4, 0.4)), BARK_LT)
			end
		end
		-- bark ridges (raised strips) on the visible sides
		for _, r in { { 90, -1.5, 4.0 }, { 135, 1.8, 3.2 }, { -90, 0.6, 4.4 }, { -135, -2.2, 2.6 }, { 180, 0.2, 5.0 } } do
			local q = LC * CFrame.Angles(rad(r[1]), 0, 0) * CFrame.new(r[2], RO + 0.08, 0)
			B:block(R, v(r[3], 0.25, 0.5), q, BARK_LT)
		end
		-- dark hollow
		B:block(R, v(LEN - 1.0, 2.3, 2.3), LC * CFrame.new(0.4, 0, 0), BARK_BK)
		-- clean cut end: end-grain rim (-X)
		local xe = -LEN / 2 - 0.12
		for i = 0, 7 do
			local q = LC * CFrame.Angles(rad(i * 45 + 22.5 * 0), 0, 0) * CFrame.new(xe, RO - TH / 2, 0)
			B:block(R, v(0.3, TH + 0.06, 1.74), q, (i % 2 == 0) and GRAIN or GRAIN_LT)
		end
		-- growth ring line on the rim
		for i = 0, 7 do
			local q = LC * CFrame.Angles(rad(i * 45), 0, 0) * CFrame.new(xe - 0.1, RO - TH / 2 - 0.05, 0)
			B:block(R, v(0.12, 0.14, 1.2), q, GRAIN_DK)
		end
		-- inner bark lip just inside the opening
		B:block(R, v(0.3, 2.42, 2.42), LC * CFrame.new(-LEN / 2 + 0.55, 0, 0), BARK_DK)

		-- tiny glowing mushrooms peeking out of the hollow
		local floorY = -(RO - TH) + 0.02
		for _, m in { { -LEN / 2 + 0.7, -0.35, 0.95 }, { -LEN / 2 + 1.2, 0.4, 0.7 } } do
			local k = m[3]
			local base = LC * CFrame.new(m[1], floorY, m[2])
			B:block(R, v(0.3 * k, 0.8 * k, 0.3 * k), base * CFrame.new(0, 0.4 * k, 0), STALK)
			B:block(R, v(0.8 * k, 0.32 * k, 0.8 * k), base * CFrame.new(0, 0.86 * k, 0), GLOW, { mat = "Neon", name = "HollowGlow" })
		end

		---------------------------------------------------------------- moss blanket
		-- slabs on top (a=0) and the two upper shoulders, with lighter patches
		local mossRuns = {
			{ 0, -2.6, 4.2, MOSS }, { 0, 1.8, 3.4, MOSS_DK },
			{ 45, -1.6, 3.6, MOSS_DK }, { 45, 2.6, 2.2, MOSS },
			{ -45, -0.6, 4.6, MOSS }, { -45, 3.1, 1.6, MOSS_DK },
			{ 90, -2.0, 1.6, MOSS }, { -90, 0.4, 2.2, MOSS_DK },
		}
		for _, m in mossRuns do
			local q = LC * CFrame.Angles(rad(m[1]), 0, 0) * CFrame.new(m[2], RO + 0.12, 0)
			B:block(R, v(m[3], 0.3, 1.82), q, m[4])
		end
		for _, m in { { 0, -3.2, 1.4 }, { 0, 2.4, 1.1 }, { -45, 0.2, 1.6 }, { 45, -2.2, 1.2 } } do
			local q = LC * CFrame.Angles(rad(m[1]), 0, 0) * CFrame.new(m[2], RO + 0.3, rnd(-0.2, 0.2))
			B:block(R, v(m[3], 0.22, 1.0), q, MOSS_LT)
		end
		-- moss drips hanging down the sides
		for _, d in { { 90, -3.0 }, { 90, -1.2 }, { -90, 0.9 }, { -90, -0.1 }, { 135, -2.5 } } do
			local q = LC * CFrame.Angles(rad(d[1]), 0, 0) * CFrame.new(d[2], RO + 0.1, 0.4)
			B:block(R, v(0.6, 0.24, 1.0), q, MOSS_DK)
		end

		---------------------------------------------------------------- toadstools on top
		local topY = RO + 0.25
		local function toad(x, z, k, ry, tilt)
			local base = LC * CFrame.new(x, topY, z) * ang(tilt or 0, ry, 0)
			B:block(R, v(0.55 * k, 1.3 * k, 0.55 * k), base * CFrame.new(0, 0.6 * k, 0), STALK)
			B:block(R, v(0.9 * k, 0.18 * k, 0.9 * k), base * CFrame.new(0, 0.8 * k, 0), SPOT)
			B:block(R, v(1.9 * k, 0.45 * k, 1.9 * k), base * CFrame.new(0, 1.35 * k, 0), RED_DK)
			B:block(R, v(1.6 * k, 0.45 * k, 1.6 * k), base * CFrame.new(0, 1.75 * k, 0) * ang(0, 45, 0), RED)
			B:block(R, v(1.0 * k, 0.32 * k, 1.0 * k), base * CFrame.new(0, 2.1 * k, 0), RED_LT)
			-- spots
			B:block(R, v(0.4 * k, 0.12 * k, 0.4 * k), base * CFrame.new(0.1 * k, 2.3 * k, -0.1 * k) * ang(0, 20, 0), SPOT)
			B:block(R, v(0.42 * k, 0.32 * k, 0.12 * k), base * CFrame.new(0.3 * k, 1.38 * k, -0.98 * k), SPOT)
			B:block(R, v(0.12 * k, 0.32 * k, 0.4 * k), base * CFrame.new(-0.98 * k, 1.38 * k, 0.2 * k), SPOT)
			B:block(R, v(0.35 * k, 0.28 * k, 0.12 * k), base * CFrame.new(-0.25 * k, 1.78 * k, -0.9 * k) * ang(0, 45, 0), SPOT)
		end
		toad(-1.6, 0.0, 1.15, 10, 0)
		toad(-0.3, -0.5, 0.8, 35, -8)
		toad(-2.7, 0.5, 0.6, 60, 6)
		toad(2.6, 0.2, 0.55, 20, 0)

		---------------------------------------------------------------- shelf fungi (front face)
		for _, s in { { 1.4, 90, 0.0, 1.1 }, { 2.3, 90, 0.9, 0.8 }, { 0.6, 112, -0.6, 0.7 }, { -3.6, 100, 0.4, 0.75 } } do
			local k = s[4]
			local q = LC * CFrame.new(s[1], 0, 0) * CFrame.Angles(rad(s[2]), 0, 0) * CFrame.new(0, RO, 0)
			-- q: local +Y points out of the log; shelves stick out horizontally
			local pos = q.Position + v(0, s[3], 0)
			local out = q.UpVector
			out = v(out.X, 0, out.Z).Unit
			local f = look(pos, out)
			B:block(R, v(1.9 * k, 0.38, 1.2 * k), f * CFrame.new(0, 0, -0.45 * k), SHELF_DK)
			B:block(R, v(1.5 * k, 0.3, 0.95 * k), f * CFrame.new(0, 0.28, -0.35 * k), SHELF)
			B:block(R, v(0.9 * k, 0.2, 0.5 * k), f * CFrame.new(0, 0.46, -0.35 * k), SHELF_LT)
		end

		---------------------------------------------------------------- briar arching over
		local cane = {
			at(3.6, -RO - 0.1, -2.6),
			at(3.5, 0.2, -2.7),
			at(3.3, 1.9, -1.7),
			at(3.15, 2.75, 0.0),
			at(3.0, 2.2, 1.7),
			at(2.9, 0.4, 2.6),
			at(2.8, -RO - 0.1, 2.7),
		}
		for i = 1, #cane - 1 do
			B:bar(R, cane[i], cane[i + 1], 0.42, 0.42, (i % 2 == 0) and CANE or CANE_DK)
			local mid = (cane[i] + cane[i + 1]) / 2
			local d = (cane[i + 1] - cane[i]).Unit
			local side = d:Cross(v(0, 1, 0))
			if side.Magnitude < 0.1 then side = v(1, 0, 0) end
			side = side.Unit * ((i % 2 == 0) and 1 or -1)
			local tp = mid + side * 0.45 + v(0, 0.2, 0)
			B:bar(R, mid, tp, 0.22, 0.22, THORN)
			B:block(R, v(0.14, 0.14, 0.14), CFrame.new(tp), THORN_TIP)
		end
		-- leaves on the cane
		for _, l in { { 2, 0.7 }, { 4, 0.4 }, { 5, 0.6 } } do
			local p = cane[l[1]]:Lerp(cane[l[1] + 1], l[2])
			B:block(R, v(0.9, 0.16, 0.6), CFrame.new(p + v(0.45, 0.15, 0)) * ang(0, 30 * l[1], 15), (l[1] % 2 == 0) and FERN or FERN_DK)
		end
		-- the rose on top of the arch
		local rp = cane[4] + v(0.05, 0.35, 0)
		B:block(R, v(0.9, 0.3, 0.9), CFrame.new(rp) * ang(0, 20, 0), CANE)
		B:block(R, v(1.3, 0.7, 1.3), CFrame.new(rp + v(0, 0.4, 0)) * ang(0, 20, 0), ROSE_DK)
		B:block(R, v(1.1, 0.6, 1.1), CFrame.new(rp + v(0, 0.65, 0)) * ang(0, 65, 0), ROSE)
		B:block(R, v(0.6, 0.4, 0.6), CFrame.new(rp + v(0, 0.98, 0)) * ang(0, 20, 0), ROSE_LT)
		for k = 0, 3 do
			B:block(R, v(0.7, 0.18, 0.5), CFrame.new(rp) * ang(0, k * 90 + 40, 0) * CFrame.new(0, 0.08, -0.75), FERN)
		end
		-- a rose bud near the front foot
		local bp = cane[2]:Lerp(cane[3], 0.5) + v(0.3, 0.1, -0.35)
		B:block(R, v(0.5, 0.65, 0.5), CFrame.new(bp) * ang(0, 30, 10), ROSE)
		B:block(R, v(0.55, 0.22, 0.55), CFrame.new(bp - v(0, 0.35, 0)) * ang(0, 30, 10), CANE)

		---------------------------------------------------------------- ferns
		local function frond(base, yaw, len, lift, col)
			local dir = v(math.sin(rad(yaw)), 0, -math.cos(rad(yaw)))
			local p1 = base + dir * (len * 0.25) + v(0, len * 0.8, 0)
			local p2 = p1 + dir * (len * 0.6) + v(0, len * lift, 0)
			B:bar(R, base, p1, 0.2, 0.2, FERN_DK)
			B:bar(R, p1, p2, 0.18, 0.18, FERN_DK)
			local leafs = { { base, p1, 0.55, 1.4 }, { p1, p2, 0.15, 1.3 }, { p1, p2, 0.5, 1.0 }, { p1, p2, 0.82, 0.6 } }
			for j, lf in leafs do
				local a, b = lf[1], lf[2]
				local frame = P.aim(a, b)
				local p = a:Lerp(b, lf[3])
				B:block(R, v(lf[4] * len / 3.2, 0.12, 0.42), CFrame.new(p) * (frame - frame.Position), (j % 2 == 0) and col or FERN)
			end
			-- tip
			B:block(R, v(0.3, 0.12, 0.3), CFrame.new(p2) * ang(0, yaw, 0), FERN_LT)
		end
		local function fern(x, z, sz, rot)
			local base = v(x, 0.15, z)
			for j = 0, 4 do
				local yaw = rot + j * 72 + rnd(-12, 12)
				frond(base, yaw, sz * rnd(0.85, 1.1), rnd(-0.05, 0.12), (j % 2 == 0) and FERN_LT or FERN)
			end
			B:block(R, v(0.6, 0.4, 0.6), CFrame.new(base + v(0, 0.1, 0)), FERN_DK)
		end
		fern(-4.6, 2.6, 3.0, 10)
		fern(5.4, 1.9, 2.6, 40)
		fern(-1.4, -3.2, 2.2, 25)
		fern(1.6, 3.3, 2.4, 60)

		---------------------------------------------------------------- footing
		-- low earth/moss pad under the log so it rests on the ground
		B:block(R, v(8.0, 0.22, 2.2), LC * CFrame.new(0, -RO - 0.09, 0), DIRT_DK)
		B:block(R, v(6.0, 0.26, 3.4), LC * CFrame.new(-0.8, -RO - 0.07, 0.1), MOSS_DK)
		B:block(R, v(2.6, 0.3, 3.2), LC * CFrame.new(2.4, -RO - 0.05, 0.3), DIRT)
		-- flat stones
		for _, s in { { -5.9, -1.2, 1.3, 25, STONE }, { -5.0, -2.2, 0.8, 60, STONE_LT }, { 6.4, -2.4, 1.1, 10, STONE_DK }, { 7.0, -1.2, 0.7, 40, STONE }, { -2.6, 3.0, 0.8, 70, STONE_LT } } do
			local k = s[3]
			B:block(R, v(1.3 * k, 0.45 * k, k), cf(s[1], 0.22 * k, s[2], rnd(-5, 5), s[4], rnd(-5, 5)), s[5])
		end
		-- grass tufts
		for _, g in { { -3.6, -2.0 }, { 4.6, -2.6 }, { 0.2, 3.0 }, { -6.0, 0.8 }, { 6.0, 2.0 }, { 3.4, -3.0 } } do
			B:block(R, v(0.4, 0.9, 0.4), cf(g[1], 0.45, g[2], rnd(-8, 8), rnd(0, 40), rnd(-8, 8)), GRASS)
			B:block(R, v(0.3, 0.65, 0.3), cf(g[1] + 0.3, 0.32, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK)
		end
		-- fallen leaves + petals
		for _, l in { { -4.2, -2.9, LEAF_O }, { 2.2, -3.2, LEAF_Y }, { 5.2, 2.8, LEAF_O }, { -1.0, 3.4, PETAL }, { 4.0, -1.9, PETAL }, { -6.4, 2.0, LEAF_Y } } do
			B:block(R, v(0.8, 0.1, 0.55), cf(l[1], 0.05, l[2], 0, rnd(0, 180), 0), l[3])
		end

		-- little toadstools on the ground by the opening
		for _, m in { { 4.4, -3.6, 0.55, 20 }, { 5.2, -3.9, 0.4, 50 }, { -3.2, -2.6, 0.45, 10 } } do
			local k = m[3]
			local base = cf(m[1], 0, m[2], 0, m[4], 0)
			B:block(R, v(0.5 * k, 1.2 * k, 0.5 * k), base * CFrame.new(0, 0.6 * k, 0), STALK)
			B:block(R, v(1.6 * k, 0.5 * k, 1.6 * k), base * CFrame.new(0, 1.35 * k, 0), RED)
			B:block(R, v(0.9 * k, 0.35 * k, 0.9 * k), base * CFrame.new(0, 1.75 * k, 0) * ang(0, 45, 0), RED_LT)
			B:block(R, v(0.35 * k, 0.12 * k, 0.35 * k), base * CFrame.new(0, 1.95 * k, 0), SPOT)
		end

		---------------------------------------------------------------- vfx
		local hollow = B:block(R, v(1.6, 1.4, 1.6), LC * CFrame.new(-LEN / 2 - 0.6, -0.4, 0), GLOW, { tr = 1, name = "SporeSpot" })
		B:emitter(hollow, "sparkle", { name = "Spores", color = { GLOW, "#ffffff" }, rate = 2.5, size = { 0.12, 0.28, 0 }, speed = { 0.2, 0.5 }, life = { 1.5, 2.5 }, accel = { 0, 0.4, 0 } })
	end,
}
