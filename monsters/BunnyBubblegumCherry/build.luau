--!nocheck
-- Bubblegum Cherry Tree (Bunny Stage plant #2, Uncommon).
-- A small tree in the reference style: a stepped dirt mound, a chunky flared
-- trunk with angled branches and a crown of big rotated studded leaf cubes in
-- three bubblegum pinks. Hot-pink cherry PAIRS dangle on little green V stems,
-- and a few of them are blowing a see-through bubblegum bubble.
-- Static prop: no motion.luau.
return {
	DisplayName = "Bubblegum Cherry Tree",
	Rarity = "Uncommon",
	Element = "Party",
	Build = function(B, P)
		local v, cf = P.v, P.cf

		local DIRT_DK, DIRT, DIRT_LT = "#4a2a16", "#744526", "#93603a"
		local BARK_DK, BARK, BARK_LT = "#5a3519", "#7a4a26", "#8f5a30"
		local LEAF_DK, LEAF, LEAF_LT = "#f48dc6", "#ff9fd2", "#ffc4e4"
		local GRASS = "#4fcf3a"
		local CHERRY, CHERRY_DK, SHINE = "#ff2a86", "#d81268", "#fff0f8"
		local STEM, BUBBLE = "#3fa83a", "#ff86c6"

		local seed = 11
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		------------------------------------------------------------ soil mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(7.0, 0.7, 5.2), cf(0, 0.35, 0), DIRT_DK, S)
		B:block(soil, v(5.2, 0.7, 7.0), cf(0, 0.35, 0), DIRT_DK, S)
		local edge = 10
		for i = 0, edge - 1 do
			local a = (i + 0.5) / edge * math.pi * 2
			local r = 3.35 + rnd(-0.15, 0.2)
			local h = 0.6 + rnd(0, 0.35)
			local col = (i % 3 == 0) and DIRT or DIRT_DK
			B:block(soil, v(rnd(1.3, 1.8), h, rnd(1.0, 1.4)), cf(math.cos(a) * r, h / 2, math.sin(a) * r, 0, -math.deg(a) + rnd(-12, 12), 0), col, S)
		end
		B:block(soil, v(4.6, 0.6, 3.4), cf(0, 0.95, 0), DIRT, S)
		B:block(soil, v(3.4, 0.6, 4.6), cf(0, 0.95, 0), DIRT, S)
		-- chunky blocks on the middle tier
		for i = 0, 5 do
			local a = (i + 0.2) / 6 * math.pi * 2
			B:block(soil, v(1.1, 0.5, 0.9), cf(math.cos(a) * 2.0, 1.3, math.sin(a) * 2.0, 0, -math.deg(a) + rnd(-15, 15), 0), DIRT_LT, S)
		end
		B:block(soil, v(2.6, 0.4, 2.6), cf(0, 1.45, 0), DIRT_LT, S)
		B:block(soil, v(0.35, 0.7, 0.35), cf(-3.6, 0.35, -1.7), GRASS, S)
		B:block(soil, v(0.3, 0.5, 0.3), cf(-3.3, 0.25, -2.1), GRASS, S)
		B:block(soil, v(0.35, 0.6, 0.35), cf(3.2, 0.3, 2.4), GRASS, S)

		------------------------------------------------------------ trunk
		local crop = B:bone("Crop", "Root", v(0, 1.6, 0))
		B:block(crop, v(2.3, 0.6, 2.3), cf(0, 1.85, 0), BARK_DK)
		B:block(crop, v(1.9, 0.6, 1.9), cf(0, 2.4, 0), BARK)
		B:block(crop, v(1.55, 1.8, 1.55), cf(0, 3.5, 0), BARK_LT)
		B:block(crop, v(1.3, 1.8, 1.3), cf(0, 5.1, 0), BARK)
		-- branches reaching into the crown
		local TOPY = 5.4
		B:beam(crop, v(0, TOPY, 0), v(-2.3, 6.6, -0.6), 0.8, 0.8, BARK)
		B:beam(crop, v(0, TOPY, 0), v(2.3, 6.7, 0.6), 0.8, 0.8, BARK)
		B:beam(crop, v(0, TOPY - 0.3, 0), v(0.5, 6.6, 2.3), 0.7, 0.7, BARK_LT)
		B:beam(crop, v(0, TOPY, 0), v(-0.4, 6.7, -2.2), 0.7, 0.7, BARK_LT)

		------------------------------------------------------------ canopy
		local CY = 6.85
		local leafParts = {}
		local function leaf(x, y, z, sz, rx, ry, rz, col)
			table.insert(leafParts, B:block(crop, v(sz, sz, sz), cf(x, CY + y, z, rx, ry, rz), col))
		end
		-- big centre cube
		leaf(0, 0.1, 0, 3.4, 18, 25, 12, LEAF_LT)
		local ringDots = {}
		-- wide lower ring (mild tilts so the crown stays round and wide)
		local ring = {
			{ 0, 3.4, LEAF_DK }, { 60, 2.9, LEAF }, { 120, 3.3, LEAF_DK },
			{ 180, 3.0, LEAF }, { 240, 3.5, LEAF_DK }, { 300, 2.8, LEAF },
		}
		for i, r in ring do
			local a = math.rad(r[1] + 15)
			local R = 2.7 + rnd(-0.2, 0.2)
			local tx, tz = rnd(16, 28), rnd(14, 26)
			if i % 2 == 0 then tx = -tx end
			if i % 3 == 0 then tz = -tz end
			local ly = ((i % 2 == 0) and -0.6 or 0.15) + rnd(-0.2, 0.2)
			leaf(math.sin(a) * R, ly, -math.cos(a) * R, r[2], tx, r[1] + rnd(-20, 20), tz, r[3])
			-- a cherry cube half sunk into this cube's outer face
			local da = a + math.rad(rnd(-14, 14))
			local dr = R + r[2] * 0.5
			table.insert(ringDots, { math.sin(da) * dr, CY + ly + rnd(-0.3, 0.6), -math.cos(da) * dr })
		end
		-- lighter cubes on top, more tumbled
		leaf(1.3, 0.5, -0.9, 2.6, 30, 45, 20, LEAF_LT)
		leaf(-1.4, 0.4, 1.2, 2.5, -22, 15, 30, LEAF_LT)
		leaf(1.5, 0.45, 1.6, 2.3, 10, 70, -25, LEAF_LT)
		leaf(-1.6, 0.5, -1.4, 2.3, 25, -30, -20, LEAF)
		-- mid-height cubes poking out between the ring cubes
		for i = 0, 2 do
			local a = math.rad(i * 120 + 50)
			leaf(math.sin(a) * 2.5, 0.7 + rnd(-0.2, 0.2), -math.cos(a) * 2.5, 2.4, rnd(-35, 35), i * 120 + rnd(0, 45), rnd(-35, 35), i == 1 and LEAF_DK or LEAF_LT)
		end

		------------------------------------------------------------ cherry pairs
		-- {phi (deg around Y, 0 = front), theta (deg up from horizontal), bubble?}
		local cherries = {
			{ -20, -25, true }, { 40, -20 }, { 95, -28 }, { 150, -22, true }, { 205, -26 },
			{ 260, -20 }, { 310, -30 }, { 10, 25 }, { 130, 30 }, { 240, 35, true }, { 330, 45 },
		}
		local shineN, firstShine = 0, nil
		local bubbleParts = {}
		for i, c in cherries do
			local phi, th = math.rad(c[1] - 90), math.rad(c[2])
			local dir = v(math.cos(phi) * math.cos(th), math.sin(th), math.sin(phi) * math.cos(th))
			local hang = c[2] < 0
			local top
			if hang then
				-- hang from the underside rim of the crown
				local hd = v(dir.X, 0, dir.Z).Unit
				local R = 3.7 + rnd(-0.2, 0.25)
				top = v(hd.X * R, CY - 1.5 + c[2] * 0.01, hd.Z * R)
			else
				top = v(dir.X * 3.5, CY + 0.3 + dir.Y * 2.1, dir.Z * 3.5)
			end
			-- side axis perpendicular to dir in the XZ plane
			local side = v(-dir.Z, 0, dir.X)
			if side.Magnitude < 0.01 then side = v(1, 0, 0) end
			side = side.Unit
			local drop = hang and 1.2 or 0.7
			for k = -1, 1, 2 do
				local berry = top + side * (0.48 * k) + v(0, -drop, 0) + dir * 0.15
				B:beam(crop, top, berry + v(0, 0.35, 0), 0.14, 0.14, STEM)
				local rot = cf(berry.X, berry.Y, berry.Z, rnd(-10, 10), c[1] + rnd(-15, 15), rnd(-10, 10))
				B:block(crop, v(0.85, 0.8, 0.85), rot, CHERRY)
				B:block(crop, v(0.6, 0.95, 0.6), rot, CHERRY_DK)
				if k == 1 then
					shineN += 1
					local sp = berry + dir * 0.42 + v(0, 0.2, 0)
					local s = B:block(crop, v(0.24, 0.24, 0.24), cf(sp.X, sp.Y, sp.Z, 0, c[1], 0), SHINE, { mat = "Neon", name = "Shine" .. shineN })
					firstShine = firstShine or s
				end
			end
			-- tiny leaf at the stem joint
			B:block(crop, v(0.5, 0.15, 0.8), cf(top.X, top.Y + 0.05, top.Z, 0, c[1] + 30, 20), STEM)
			if c[3] then
				-- blown bubblegum bubble on the left cherry
				local bp = top + side * -0.48 + v(0, -drop, 0) + dir * 0.95
				local b = B:block(crop, v(1.3, 1.3, 1.3), cf(bp.X, bp.Y, bp.Z, 0, c[1] + 20, 0), BUBBLE, { tr = 0.2, name = "Bubble" })
				table.insert(bubbleParts, b)
			end
		end

		-- single cherries dotted over the crown, half sunk (like the ref fruit cubes)
		for i, d in ringDots do
			B:block(crop, v(0.9, 0.9, 0.9), cf(d[1], d[2], d[3], rnd(-30, 30), rnd(0, 90), rnd(-30, 30)), (i % 2 == 0) and CHERRY or CHERRY_DK)
		end
		local dots = { { 120, 50 }, { 300, 55 }, { 200, 45 } }
		for _, d in dots do
			local phi, th = math.rad(d[1] - 90), math.rad(d[2])
			local dir = v(math.cos(phi) * math.cos(th), math.sin(th), math.sin(phi) * math.cos(th))
			local p = v(dir.X * 3.55, CY + 0.1 + dir.Y * 2.2, dir.Z * 3.55)
			B:block(crop, v(0.9, 0.9, 0.9), cf(p.X, p.Y, p.Z, rnd(-30, 30), rnd(0, 90), rnd(-30, 30)), (d[1] % 2 == 0) and CHERRY or CHERRY_DK)
		end

		------------------------------------------------------------ fx
		B:emitter(leafParts[6], "sparkle", { name = "PinkSparkle", color = { "#ffffff", "#ff9fd2" }, rate = 3, size = 0.35 })
		B:emitter(bubbleParts[1], "bubble", { name = "GumBubbles", color = "#ffb3dd", rate = 1.2, size = 0.4 })
		B:light(leafParts[1], { color = "#ff8fcc", brightness = 0.9, range = 10, name = "PinkLight" })
	end,
}
