--!nocheck
-- Diamond Pineapple (Bunny Stage #9, Divine) -- a giant diamond-cut pineapple
-- in the stud-tree reference style: a stepped, gold-trimmed dirt mound with
-- gem studs, a rosette of chunky green leaf blocks at the base, a gold ring
-- collar holding the fruit, two baby diamond pineapples, a tall body of icy
-- cyan tiers covered in rotated white/ice "diamond facet" cubes (the
-- pineapple cross-hatch) with tiny neon glints, and a big three-layer crown
-- of stepped gold leaf blocks with glowing tips. Floating diamond cubes,
-- sparkles and one soft icy light finish the bling.
-- Static prop: no motion.luau.
return {
	DisplayName = "Diamond Pineapple",
	Rarity = "Divine",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2616", "#4c2e1a", "#6b4127", "#7f5032"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local GOLD_LT, GOLD, GOLD_DK = "#ffe680", "#ffc928", "#e09a12"
		local ICE_DK, ICE, ICE_LT, WHITE = "#2fa9d6", "#5fd3f2", "#a8ecff", "#f2fdff"
		local LEAF, LEAF_DK = "#2fb36b", "#1f8a50"
		local GLINT, GLINT_GOLD, GEM_PINK = "#e8fdff", "#fff27a", "#ff6fd8"

		-- tiny deterministic jitter
		local seed = 7
		local function rnd()
			seed = (seed * 1103515245 + 12345) % 2147483648
			return seed / 2147483648
		end
		local function polar(r, deg, y)
			local a = rad(deg)
			return math.sin(a) * r, y, -math.cos(a) * r
		end

		---------------------------------------------------------------- mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		-- bottom tier: wide dark ring
		B:block(soil, v(12, 1, 8.6), cf(0, 0.5, 0), DIRT_DK, S)
		B:block(soil, v(8.6, 1, 12), cf(0, 0.5, 0), DIRT_DK, S)
		B:block(soil, v(10.4, 0.98, 10.4), cf(0, 0.49, 0, 0, 45, 0), DIRT_DK2, S)
		-- chunky irregular edge blocks
		for i = 0, 13 do
			local deg = i * (360 / 14) + rnd() * 8
			local x, _, z = polar(6.3 + rnd() * 0.5, deg, 0)
			local h = 0.7 + rnd() * 0.6
			B:block(soil, v(2 + rnd() * 0.9, h, 1.5 + rnd() * 0.6), cf(x, h / 2, z, 0, -deg + (rnd() - 0.5) * 20, 0),
				(i % 2 == 0) and DIRT_DK or DIRT_DK2, S)
		end
		-- gold trim band with gem studs (the VIP bling)
		for i = 0, 15 do
			local deg = i * 22.5
			local x, _, z = polar(5.35, deg, 0)
			B:block(soil, v(2.25, 0.5, 0.8), cf(x, 1.15, z, 0, -deg, 0), (i % 2 == 0) and GOLD or GOLD_DK, S)
			if i % 2 == 0 then
				local gx, _, gz = polar(5.8, deg, 0)
				B:gem(soil, v(0.5, 0.5, 0.5), cf(gx, 1.15, gz, 0, -deg + 45, 0), (i % 4 == 0) and GLINT or GEM_PINK, { name = "Soil" })
			end
		end
		-- middle tier: lighter brown
		B:block(soil, v(8.6, 1, 6.2), cf(0, 1.5, 0), DIRT, S)
		B:block(soil, v(6.2, 1, 8.6), cf(0, 1.5, 0), DIRT, S)
		for i = 0, 7 do
			local deg = i * 45 + 22.5 + rnd() * 10
			local x, _, z = polar(4.0, deg, 0)
			B:block(soil, v(1.8 + rnd() * 0.6, 0.9 + rnd() * 0.3, 1.4), cf(x, 1.45, z, 0, -deg, 0), (i % 2 == 0) and DIRT or DIRT_LT, S)
		end
		-- top tier
		B:block(soil, v(5.2, 0.6, 5.2), cf(0, 2.3, 0, 0, 45, 0), DIRT_LT, S)
		-- grass tufts
		local grass = { { -6.6, 3.4 }, { 6.9, 1.6 }, { 2.4, 6.8 }, { -3.2, -6.6 }, { 5.6, -4.6 } }
		for i, g in grass do
			local h = 0.9 + (i % 2) * 0.5
			B:block(soil, v(0.55, h, 0.55), cf(g[1], h / 2, g[2], 0, i * 23, 0), (i % 2 == 0) and GRASS or GRASS_DK, S)
			B:block(soil, v(0.45, h * 0.6, 0.45), cf(g[1] + 0.5, h * 0.3, g[2] + 0.2, 0, i * 31, 0), GRASS_DK, S)
		end

		---------------------------------------------------------------- crop
		local BASE = 2.6
		local crop = B:bone("Crop", "Root", v(0, BASE, 0))

		-- body profile
		local YB, TH, NT = 3.0, 1.2, 9
		local YC, HH, R = YB + TH * NT / 2, TH * NT / 2 + 0.6, 4.1
		local function radiusAt(y)
			local d = (y - YC) / HH
			return math.max(1.4, R * (math.max(0, 1 - d * d)) ^ 0.55)
		end

		-- base rosette of chunky green leaf blocks
		for j = 0, 6 do
			local deg = j * (360 / 7) + 10
			local x0, _, z0 = polar(2.2, deg, 0)
			local x1, _, z1 = polar(4.9, deg, 0)
			local x2, _, z2 = polar(6.6, deg, 0)
			B:beam(crop, v(x0, BASE + 0.7, z0), v(x1, BASE + 3.4, z1), 2.2, 0.8, (j % 2 == 0) and LEAF or LEAF_DK)
			B:beam(crop, v(x1 * 0.95, BASE + 3.1, z1 * 0.95), v(x2, BASE + 3.9, z2), 1.6, 0.7, (j % 2 == 0) and LEAF_DK or LEAF)
			B:block(crop, v(0.6, 0.6, 0.6), cf(x2, BASE + 3.95, z2, 0, -deg + 45, 0), GOLD)
		end

		-- two baby diamond pineapples sprouting on the mound
		local function baby(deg, r, k)
			local bx, _, bz = polar(r, deg, 0)
			local y0 = BASE - 0.55
			local rs = { 0.75, 1.0, 1.05, 0.8 }
			for t = 1, 4 do
				local rr = rs[t]
				local col = (t % 2 == 0) and ICE or ICE_DK
				B:block(crop, v(2 * rr, 0.6, 1.4 * rr), cf(bx, y0 + (t - 0.5) * 0.6, bz, 0, deg + (t % 2) * 45, 0), col)
				B:block(crop, v(1.4 * rr, 0.58, 2 * rr), cf(bx, y0 + (t - 0.5) * 0.6, bz, 0, deg + (t % 2) * 45, 0), (t % 2 == 0) and ICE_LT or WHITE)
			end
			local yt = y0 + 2.4
			for q = 0, 3 do
				local a = q * 90 + 45 + deg
				local ax, _, az = polar(0.9, a, 0)
				B:beam(crop, v(bx, yt, bz), v(bx + ax, yt + 1.1, bz + az), 0.6, 0.35, (q % 2 == 0) and GOLD or GOLD_LT)
			end
			B:gem(crop, v(0.35, 0.35, 0.35), cf(bx, yt + 0.9, bz, 45, 45, 0), GLINT_GOLD, { name = "BabyTip" .. k })
		end
		baby(35.7, 4.3, 1)
		baby(190, 4.4, 2)

		-- gold ring-setting collar
		for i = 0, 9 do
			local deg = i * 36
			local x, _, z = polar(2.5, deg, 0)
			B:block(crop, v(1.7, 0.9, 0.9), cf(x, YB + 0.05, z, 0, -deg, 0), (i % 2 == 0) and GOLD or GOLD_DK)
		end

		-- icy stepped body tiers + diamond facets
		local glintN = 0
		local glints = {}
		for i = 1, NT do
			local y = YB + (i - 0.5) * TH
			local r = radiusAt(y)
			local yaw = (i % 2) * 45
			B:block(crop, v(2 * r, TH, 1.3 * r), cf(0, y, 0, 0, yaw, 0), (i % 2 == 0) and ICE_DK or ICE)
			B:block(crop, v(1.3 * r, TH - 0.02, 2 * r), cf(0, y, 0, 0, yaw, 0), (i % 2 == 0) and ICE or ICE_DK)
			local nf = (r < 2.4) and 6 or 8
			local fs = (r < 2.4) and 1.05 or 1.35
			for j = 0, nf - 1 do
				local deg = (j + 0.5 * (i % 2)) * (360 / nf)
				local rr = r * 0.97
				local x, _, z = polar(rr, deg, 0)
				local F = cf(x, y, z, 0, -deg, 0) * ang(0, 0, 45)
				local col = ((i + j) % 2 == 0) and WHITE or ICE_LT
				if (i + j) % 5 == 0 then col = ICE end
				B:block(crop, v(fs, fs, fs), F, col)
				if (i * 3 + j) % 5 == 0 then
					glintN += 1
					local g = B:gem(crop, v(0.32, 0.32, 0.32), F * CFrame.new(0, 0, -fs / 2 - 0.05), GLINT, { name = "Glint" .. glintN })
					table.insert(glints, g)
				end
			end
		end

		-- crown: three layers of stepped gold leaf blocks
		local YT = YB + NT * TH
		B:block(crop, v(2.6, 0.9, 2.6), cf(0, YT + 0.2, 0, 0, 45, 0), GOLD_DK)
		B:block(crop, v(1.8, 0.8, 1.8), cf(0, YT + 0.9, 0), GOLD)
		local tipN = 0
		local function leaf(deg, r0, y0, e1, l1, e2, l2, w, col, col2, glow)
			local a = rad(deg)
			local dx, dz = math.sin(a), -math.cos(a)
			local p0 = v(dx * r0, YT + y0, dz * r0)
			local p1 = p0 + v(dx * math.cos(rad(e1)) * l1, math.sin(rad(e1)) * l1, dz * math.cos(rad(e1)) * l1)
			local p2 = p1 + v(dx * math.cos(rad(e2)) * l2, math.sin(rad(e2)) * l2, dz * math.cos(rad(e2)) * l2)
			B:beam(crop, p0, p1 + (p1 - p0).Unit * 0.3, w, 0.8, col)
			B:beam(crop, p1 - (p2 - p1).Unit * 0.4, p2, w * 0.7, 0.7, col2)
			if glow then
				tipN += 1
				return B:gem(crop, v(0.5, 0.5, 0.5), cf(p2.X, p2.Y, p2.Z, 0, -deg + 45, 0), GLINT_GOLD, { name = "CrownTip" .. tipN })
			end
		end
		for j = 0, 7 do
			leaf(j * 45 + 22.5, 0.9, 0.3, 36, 3.2, 14, 2.6, 2.1, GOLD_DK, GOLD, false)
		end
		for j = 0, 5 do
			leaf(j * 60, 0.6, 0.9, 52, 3.4, 30, 2.8, 2.0, GOLD, GOLD_LT, j % 2 == 0)
		end
		local topTip
		for j = 0, 3 do
			local t = leaf(j * 90 + 45, 0.35, 1.3, 74, 3.6, 56, 2.7, 1.9, GOLD_LT, GOLD, true)
			topTip = topTip or t
		end
		B:block(crop, v(1.6, 3.8, 1.6), cf(0, YT + 2.9, 0, 0, 45, 0), GOLD)
		-- chunky studded gold leaf cubes give the crown body (like the ref canopies)
		for k = 0, 4 do
			local x, _, z = polar(1.25, k * 72 + 10, 0)
			B:block(crop, v(2.0, 2.0, 2.0), cf(x, YT + 1.6 + (k % 2) * 0.5, z, 15 + k * 9, k * 37, -12 + k * 7), (k % 2 == 0) and GOLD or GOLD_DK)
		end
		local crownTop = B:gem(crop, v(0.6, 0.6, 0.6), cf(0, YT + 5.0, 0, 45, 45, 0), GLINT_GOLD, { name = "CrownTop" })

		-- floating diamond cubes
		local floats = { { 40, 5.8, 8.4 }, { 145, 5.9, 11.4 }, { 250, 5.8, 7.2 }, { 320, 5.0, 13.4 } }
		local firstFloat
		for k, f in floats do
			local x, _, z = polar(f[2], f[1], 0)
			local D = cf(x, f[3], z, 0, -f[1], 0) * ang(0, 0, 45)
			local d = B:block(crop, v(1.2, 1.2, 1.2), D, (k % 2 == 0) and ICE_LT or WHITE, { name = "FloatDiamond" .. k })
			B:gem(crop, v(0.3, 0.3, 0.3), D * CFrame.new(0, 0, -0.62), GLINT, { name = "FloatGlint" .. k })
			firstFloat = firstFloat or d
		end

		-- effects
		B:emitter(crownTop, "sparkle", { name = "CrownSparkle", color = { "#fff6b0", "#ffd84a" }, rate = 5, size = { 0.15, 0.5, 0 }, speed = { 0.5, 1.6 } })
		B:emitter(glints[1], "sparkle", { name = "IceSparkle", color = { "#ffffff", "#8fe8ff" }, rate = 6, size = { 0.15, 0.55, 0 }, speed = { 0.4, 1.4 } })
		B:emitter(glints[#glints], "sparkle", { name = "IceSparkle2", color = { "#ffffff", "#8fe8ff" }, rate = 5, size = { 0.15, 0.5, 0 } })
		B:emitter(firstFloat, "glow", { name = "IceGlow", color = "#9fefff", rate = 1.2 })
		B:light(glints[math.max(1, #glints // 2)], { color = "#bff4ff", brightness = 1.2, range = 14, name = "IceLight" })
	end,
}
