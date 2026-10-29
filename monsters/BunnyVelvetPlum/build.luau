--!nocheck
-- Velvet Rope Plum Tree (Bunny Stage plant #5, Legendary).
-- The VIP corner of the Bunny Bouncer's garden: a chunky stepped dirt mound
-- ringed by shiny gold stanchion posts with a sagging red velvet rope (the
-- bouncer's VIP rope!), a stout brown trunk with stepped collars and four
-- angled branches, and a big rich-purple crown of overlapping, rotated
-- studded leaf cubes. Deep plum cubes sit half-sunk all over the crown, some
-- with a tiny pink neon shine. Gold + violet sparkles, one soft pink light.
-- Static prop: no motion.luau.
return {
	DisplayName = "Velvet Rope Plum Tree",
	Rarity = "Legendary",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local BARK_DK, BARK, BARK_LT = "#4f2c1e", "#653a26", "#7c4a30"
		local LEAF_DK, LEAF, LEAF_LT, LEAF_HI = "#5a2196", "#7433bd", "#9150dc", "#a96cec"
		local PLUM, PLUM_DK, PLUM_BLOOM, STEM = "#9a1c6c", "#6e1250", "#e0609f", "#4f8a2c"
		local SHINE = "#ff7ad9"
		local GOLD, GOLD_DK, GOLD_LT = "#ffc62e", "#d9961a", "#ffe27a"
		local VELVET, VELVET_DK = "#c0162f", "#860c20"

		-- tiny deterministic random
		local seed = 5150
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end

		---------------------------------------------------------------- mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		-- rounded stepped tier: octagon (two squares) + chunky irregular edge blocks
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			-- stepped "pixel circle": cross + inner square
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.4, 2.2), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, math.rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.7, 5.6, DIRT_DK, 16, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.7, 0.6, 3.7, DIRT, 11, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.3, 0.4, 2.3, DIRT_LT, 0, {}, 0)
		-- a few loose clods + grass tufts
		for _, c in { { 5.9, 0.35, 1.2, 20 }, { -5.8, 0.3, -2.0, -15 }, { 1.0, 0.3, 6.0, 35 } } do
			B:block(soil, v(1.0, 0.6, 0.9), cf(c[1], c[2], c[3], 0, c[4], 0), DIRT_DK2, S)
		end
		for _, g in { { 5.4, -2.4 }, { -4.6, 3.3 }, { 3.2, 4.6 }, { -2.6, -5.2 }, { -5.6, 0.6 } } do
			B:block(soil, v(0.45, 0.9, 0.45), cf(g[1], 0.9, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.35, 0.6, 0.35), cf(g[1] + 0.35, 0.85, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end

		---------------------------------------------- velvet rope stanchions
		local NP, PR = 8, 5.0
		local postTop = {}
		for i = 0, NP - 1 do
			local a = math.rad(i / NP * 360 + 22.5)
			local x, z = math.sin(a) * PR, -math.cos(a) * PR
			local yb = 0.7
			B:block(soil, v(1.1, 0.3, 1.1), cf(x, yb + 0.15, z, 0, math.deg(a), 0), GOLD_DK, S)
			B:block(soil, v(0.7, 0.25, 0.7), cf(x, yb + 0.42, z, 0, math.deg(a), 0), GOLD, S)
			B:block(soil, v(0.4, 2.3, 0.4), cf(x, yb + 1.7, z, 0, math.deg(a), 0), GOLD, S)
			B:block(soil, v(0.75, 0.75, 0.75), cf(x, yb + 3.1, z, 0, math.deg(a) + 45, 0), GOLD, S)
			B:block(soil, v(0.4, 0.4, 0.4), cf(x, yb + 3.6, z, 0, math.deg(a) + 45, 0), GOLD_LT, S)
			postTop[i] = v(x, yb + 2.75, z)
		end
		for i = 0, NP - 1 do
			local a, b = postTop[i], postTop[(i + 1) % NP]
			local q1 = a:Lerp(b, 0.3) + v(0, -0.5, 0)
			local q2 = a:Lerp(b, 0.7) + v(0, -0.5, 0)
			local mid = (a + b) / 2 + v(0, -0.55, 0)
			B:beam(soil, a, q1, 0.45, 0.45, VELVET, S)
			B:beam(soil, q1, q2, 0.45, 0.45, VELVET, S)
			B:beam(soil, q2, b, 0.45, 0.45, VELVET, S)
			-- gold clip where the rope hooks onto the post
			B:block(soil, v(0.55, 0.4, 0.55), CFrame.new(a) * ang(0, i * 45 + 22.5, 0), GOLD_DK, S)
			-- little dark tassel knot at the low point
			B:block(soil, v(0.5, 0.45, 0.5), CFrame.new(mid) * ang(0, i * 45 + 22.5, 0), VELVET_DK, S)
		end

		---------------------------------------------------------------- trunk
		local Y0 = 1.7
		local crop = B:bone("Crop", "Root", v(0, Y0, 0))
		-- stepped flare collars + chunky roots
		B:block(crop, v(3.3, 0.8, 3.3), cf(0, Y0 + 0.3, 0), BARK_DK)
		for i = 0, 3 do
			local a = i * 90 + 45
			B:block(crop, v(1.1, 0.7, 1.6), cf(0, Y0 + 0.2, 0, 0, a, 0) * CFrame.new(0, 0, -1.9) * ang(-10, 0, 0), BARK_DK)
		end
		B:block(crop, v(2.7, 0.8, 2.7), cf(0, Y0 + 1.1, 0), BARK)
		B:block(crop, v(2.2, 2.6, 2.2), cf(0, Y0 + 2.8, 0), BARK_LT)
		B:block(crop, v(1.9, 2.4, 1.9), cf(0.05, Y0 + 5.2, 0.05, 0, 6, 0), BARK)
		B:block(crop, v(1.6, 1.8, 1.6), cf(0.1, Y0 + 7.0, 0.1, 0, 12, 0), BARK_LT)
		-- bark notches
		for _, n in { { 1.12, 2.4, 0.3 }, { -1.12, 3.4, -0.4 }, { 0.3, 4.6, -0.98 }, { -0.4, 5.6, 0.98 }, { 0.98, 6.1, 0.2 } } do
			local sx = math.abs(n[1]) > 0.9 and 0.3 or 0.7
			local sz = math.abs(n[3]) > 0.9 and 0.3 or 0.7
			B:block(crop, v(sx, 0.7, sz), cf(n[1], Y0 + n[2], n[3]), BARK_DK)
		end
		-- angled branches reaching into the crown
		local function branch(from, to, w)
			B:beam(crop, from, to, w, w, BARK)
			B:block(crop, v(w + 0.2, w + 0.2, w + 0.2), CFrame.new(from), BARK)
		end
		branch(v(0.4, Y0 + 5.4, 0), v(3.0, Y0 + 7.9, -0.5), 1.0)
		branch(v(-0.4, Y0 + 5.8, 0), v(-3.0, Y0 + 8.1, 0.7), 1.0)
		branch(v(0, Y0 + 6.3, 0.4), v(0.5, Y0 + 8.3, 2.8), 0.9)
		branch(v(0, Y0 + 6.6, -0.4), v(-0.6, Y0 + 8.5, -2.7), 0.9)

		---------------------------------------------------------------- crown
		local cubes = {}
		local function leaf(x, y, z, s, rx, ry, rz, col)
			local c = cf(x, Y0 + y, z, rx, ry, rz)
			B:block(crop, v(s, s, s), c, col)
			table.insert(cubes, { cf = c, s = s })
		end
		leaf(0.0, 9.6, 0.0, 5.0, 8, 20, 6, LEAF)
		leaf(-3.4, 8.8, 0.7, 4.2, -12, 35, 14, LEAF_DK)
		leaf(3.6, 9.0, -0.5, 4.2, 14, -25, -10, LEAF)
		leaf(0.5, 8.6, 3.3, 4.0, 18, 10, -12, LEAF_DK)
		leaf(-0.5, 8.7, -3.3, 4.0, -16, -15, 10, LEAF)
		leaf(-2.0, 11.1, -1.0, 3.9, 18, 35, -12, LEAF_LT)
		leaf(2.1, 11.0, 1.4, 3.9, -12, 15, 15, LEAF_LT)
		leaf(0.2, 11.4, 0.1, 3.0, 15, 25, 12, LEAF_HI)
		leaf(-4.0, 10.2, 2.6, 3.1, 20, -20, 25, LEAF)
		leaf(4.1, 10.4, 2.1, 3.2, -25, 30, -18, LEAF)
		leaf(3.0, 7.7, 2.6, 3.0, 12, 50, 8, LEAF_DK)
		leaf(-3.1, 7.8, -2.4, 3.0, -10, 20, -15, LEAF_DK)
		leaf(2.8, 10.6, -2.6, 3.2, 30, -35, 12, LEAF_LT)
		leaf(-4.7, 9.3, -1.3, 3.0, -20, 15, 30, LEAF)

		-- plums: placed on the crown's faces, half-sunk, skipped if buried in another cube
		local function buried(p, self)
			for _, c in cubes do
				if c ~= self then
					local l = c.cf:PointToObjectSpace(p)
					local h = c.s / 2 - 0.25
					if math.abs(l.X) < h and math.abs(l.Y) < h and math.abs(l.Z) < h then
						return true
					end
				end
			end
			return false
		end
		local FACES = { v(1, 0, 0), v(-1, 0, 0), v(0, 1, 0), v(0, 0, 1), v(0, 0, -1), v(0, -1, 0) }
		local placed, shines = {}, {}
		local function farEnough(p)
			for _, q in placed do
				if (p - q).Magnitude < 1.7 then return false end
			end
			return true
		end
		local function plum(p, big)
			local s = big and 1.4 or 1.15
			local f = CFrame.new(p) * ang(rnd(-25, 25), rnd(0, 90), rnd(-25, 25))
			B:block(crop, v(s, s * 1.1, s), f, (#placed % 3 == 2) and PLUM_DK or PLUM)
			B:block(crop, v(s * 0.45, s * 0.45, s * 0.45), f * CFrame.new(s * 0.32, s * 0.36, -s * 0.32), PLUM_BLOOM)
			B:block(crop, v(0.2, 0.5, 0.2), f * CFrame.new(0, s * 0.55 + 0.15, 0), STEM)
			if #placed % 4 == 1 then
				local g = B:block(crop, v(0.24, 0.24, 0.1), f * CFrame.new(-s * 0.22, s * 0.2, -s / 2 - 0.03), SHINE, { mat = "Neon", name = "PlumShine" .. (#shines + 1) })
				table.insert(shines, g)
			end
			table.insert(placed, p)
		end
		local tries, want = 0, 28
		while #placed < want and tries < 2000 do
			tries += 1
			local c = cubes[math.floor(rnd(1, #cubes + 0.999))]
			local fdir = FACES[math.floor(rnd(1, 5.999))] -- rarely the bottom face
			local h = c.s / 2
			local t1, t2 = rnd(-0.38, 0.38) * c.s, rnd(-0.38, 0.38) * c.s
			local loc
			if fdir.X ~= 0 then
				loc = v(fdir.X * h, t1, t2)
			elseif fdir.Y ~= 0 then
				loc = v(t1, fdir.Y * h, t2)
			else
				loc = v(t1, t2, fdir.Z * h)
			end
			local p = c.cf:PointToWorldSpace(loc)
			if p.Y > Y0 + 6.0 and p.Y < Y0 + 12.4 and not buried(p, c) and farEnough(p) then
				plum(p, rnd(0, 1) > 0.6)
			end
		end

		---------------------------------------------------------------- bling
		B:emitter(shines[1], "sparkle", { name = "PlumSparkle", color = { "#ffd0f4", "#c48bff" }, rate = 4, size = 0.35 })
		B:emitter(shines[3] or shines[1], "glow", { name = "PlumGlow", color = "#e080ff", rate = 2, size = 0.6 })
		B:light(shines[2] or shines[1], { color = "#ff8ae0", brightness = 0.8, range = 10, name = "PlumLight" })
		local topKnob = B:gem(soil, v(0.3, 0.3, 0.3), CFrame.new(postTop[0] + v(0, 1.05, 0)), GOLD_LT, { name = "Soil" })
		B:emitter(topKnob, "sparkle", { name = "GoldSparkle", color = "#ffe27a", rate = 2, size = 0.3 })
	end,
}
