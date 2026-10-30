--!nocheck
-- Bog Berry Bush (Flytrap Stage plant #1, Common).
-- A small, clean mossy bush in the reference style: a stepped bog-dirt mound
-- with moss pads, a murky little puddle with a lily pad, a stone and grass
-- tufts; a stubby dark trunk and a round crown of big rotated studded leaf
-- cubes in three mossy greens with a few hanging moss strands. Clusters of
-- three glossy swamp-blue berries sit half-sunk all over the crown, each
-- cluster with a tiny pale-blue neon shine.
-- Static prop: no motion.luau.
return {
	DisplayName = "Bog Berry Bush",
	Rarity = "Common",
	Element = "Bog",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (shared with the Flytrap section)
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_DK = "#8d8174", "#6c6359"
		local BOG, BOG_LT, PAD = "#2f6a50", "#6fb58a", "#3caa3c"
		local BARK_DK, BARK = "#3d2a18", "#57391f"
		local LEAF_DK, LEAF, LEAF_LT, LEAF_TOP = "#2b7a33", "#389a3c", "#5bb63e", "#86cc48"
		local BERRY, BERRY_DK, BERRY_LT = "#3a63d8", "#27419e", "#6f9cf0"
		local CALYX = "#2a5a24"
		local SHINE = "#d6f0ff"

		local seed = 1211
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end

		------------------------------------------------------------ soil mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH, skip)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				if skip and a > skip[1] and a < skip[2] then continue end
				local w, d = rnd(1.3, 1.9), rnd(1.1, 1.5)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.25)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.7, 3.5, DIRT_DK, 9, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35, { 290, 350 })
		tier(0.7, 0.55, 2.4, DIRT, 5, { DIRT, DIRT_LT, DIRT }, 0.25)
		tier(1.25, 0.35, 1.5, DIRT_LT, 0, {}, 0)

		-- moss pads draped over the lower tier edge
		for _, m in { { -40, 3.45, 1.5, MOSS }, { 95, 3.5, 1.7, MOSS_DK }, { 200, 3.45, 1.6, MOSS } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], 0.82, -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[3], 0.3, 1.2), c * ang(-14, 0, 0), m[4], S)
		end
		-- murky bog puddle with a lily pad, front-right on the lower tier
		local BC = v(1.95, 0.74, -2.15)
		B:block(soil, v(1.7, 0.16, 1.0), CFrame.new(BC) * ang(0, -40, 0), BOG, S)
		B:block(soil, v(0.7, 0.08, 0.25), CFrame.new(BC + v(0.25, 0.06, -0.1)) * ang(0, -40, 0), BOG_LT, S)
		B:block(soil, v(0.7, 0.1, 0.7), CFrame.new(BC + v(-0.35, 0.08, 0.1)) * ang(0, 20, 0), PAD, S)
		-- stones
		B:block(soil, v(0.9, 0.7, 0.75), cf(-2.6, 0.95, -1.9, 6, 25, -8), STONE, S)
		B:block(soil, v(0.55, 0.45, 0.5), cf(-2.0, 0.85, -2.5, -5, 50, 6), STONE_DK, S)
		-- tiny grass tufts
		for _, g in { { 3.6, 0.9 }, { -3.3, 2.0 } } do
			B:block(soil, v(0.35, 0.8, 0.35), cf(g[1], 0.6, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.3, 0.55, 0.3), cf(g[1] + 0.28, 0.5, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end

		------------------------------------------------------------ trunk
		local crop = B:bone("Crop", "Root", v(0, 1.6, 0))
		B:block(crop, v(1.7, 0.5, 1.7), cf(0, 1.8, 0, 0, 45, 0), BARK_DK)
		B:block(crop, v(1.1, 1.6, 1.1), cf(0, 2.5, 0, 0, 10, 0), BARK)
		B:block(crop, v(0.55, 0.55, 1.4), cf(0.35, 3.1, -0.6, -35, 20, 0), BARK)
		B:block(crop, v(1.4, 0.55, 0.55), cf(-0.6, 3.25, 0.3, 0, 15, 35), BARK)

		------------------------------------------------------------ crown
		local CY = 4.1
		local leaves = {
			-- x, y, z, size, rx, ry, rz, colour
			{ 0.0, 0.05, 0.0, 3.5, 12, 25, 8, LEAF },
			{ -1.65, -0.45, -0.4, 2.7, -8, 40, 12, LEAF_DK },
			{ 1.7, -0.4, 0.4, 2.7, 12, -20, -10, LEAF_DK },
			{ 0.3, -0.5, 1.7, 2.6, 15, 10, -12, LEAF_DK },
			{ -0.35, -0.45, -1.7, 2.6, -12, 62, 8, LEAF },
			{ 0.75, 0.8, -0.55, 2.4, 25, 45, 18, LEAF_LT },
			{ -0.9, 0.75, 0.8, 2.3, -20, 15, 25, LEAF_LT },
			{ 1.4, 0.5, 1.3, 2.1, 10, 70, -20, LEAF },
			{ 0.05, 1.35, 0.1, 1.6, 15, 35, -10, LEAF_TOP },
		}
		local leafParts = {}
		for _, l in leaves do
			table.insert(leafParts, B:block(crop, v(l[4], l[4], l[4]), cf(l[1], CY + l[2], l[3], l[5], l[6], l[7]), l[8]))
		end

		------------------------------------------------------------ berries
		-- clusters of three glossy berries, half-sunk into the crown surface
		local clusters = {
			-- phi (around Y, 0 = front), theta (up from horizontal)
			{ -35, 4 }, { 25, -6 }, { 95, 6 }, { 160, -4 }, { 230, 6 }, { 295, -6 }, { -10, 40 }, { 120, 42 }, { 235, 45 },
		}
		-- push a point outward along dir until it leaves every leaf cube, then sink it a little
		local function surface(o, dir)
			local p = o
			for _ = 1, 60 do
				local inside = false
				for i, l in leaves do
					local lp = leafParts[i].CFrame:PointToObjectSpace(p)
					local h = l[4] / 2
					if math.abs(lp.X) < h and math.abs(lp.Y) < h and math.abs(lp.Z) < h then
						inside = true
						break
					end
				end
				if not inside then break end
				p += dir * 0.1
			end
			return p - dir * 0.3
		end
		local shines = {}
		for i, d in clusters do
			local phi, th = rad(d[1]), rad(d[2])
			local dir = v(math.sin(phi) * math.cos(th), math.sin(th), -math.cos(phi) * math.cos(th))
			local pos = surface(v(0, CY + 0.1, 0), dir)
			local f = P.aim(pos, pos + dir) * ang(0, 0, rnd(-20, 20)) -- local -Z points outward
			local offs = { v(-0.46, -0.28, 0), v(0.46, -0.28, 0.05), v(0, 0.45, 0.1) }
			for k, o in offs do
				local s = (k == 3) and 1.0 or 0.9
				local c = f * CFrame.new(o) * ang(rnd(-10, 10), rnd(-10, 10), rnd(-12, 12))
				B:block(crop, v(s, s, s), c, (k == 2) and BERRY_DK or ((k == 3 and i % 3 == 0) and BERRY_LT or BERRY))
			end
			-- glossy shine on the front of the cluster
			table.insert(shines, B:block(crop, v(0.22, 0.22, 0.1), f * CFrame.new(-0.62, -0.12, -0.5), SHINE, { mat = "Neon", name = "BerryShine" .. i }))
		end

		------------------------------------------------------------ fx
		B:emitter(leafParts[9], "sparkle", { name = "BerrySparkle", color = { "#d6f0ff", "#7fb0ff" }, rate = 2.5, size = 0.3 })
		B:light(leafParts[1], { color = "#8fb8ff", brightness = 0.7, range = 8, name = "BerryLight" })
	end,
}
