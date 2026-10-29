--!nocheck
-- Neon Lime Bush (Bunny Stage plant #1, Common).
-- A small round bush in the reference style: a stepped dirt mound, a stubby
-- flared trunk and a chunky crown of big rotated studded leaf cubes in three
-- greens, dotted with glowing lime-green limes half sunk into the leaves.
-- Static prop: no motion.luau.
return {
	DisplayName = "Neon Lime Bush",
	Rarity = "Common",
	Element = "Party",
	Build = function(B, P)
		local v, cf = P.v, P.cf

		local DIRT_DK, DIRT, DIRT_LT = "#4a2a16", "#744526", "#93603a"
		local BARK_DK, BARK = "#5a3519", "#7a4a26"
		local LEAF_DK, LEAF, LEAF_LT = "#23863a", "#2e9a3f", "#4fc24c"
		local GRASS = "#4fcf3a"
		local LIME, LIME_DK, LIME_GLOW = "#a8f02c", "#7ccf1e", "#d8ff4a"

		-- deterministic jitter
		local seed = 7
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		------------------------------------------------------------ soil mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		-- wide dark bottom ring (two crossed slabs -> rounded square)
		B:block(soil, v(6.2, 0.7, 4.6), cf(0, 0.35, 0), DIRT_DK, S)
		B:block(soil, v(4.6, 0.7, 6.2), cf(0, 0.35, 0), DIRT_DK, S)
		-- chunky irregular edge blocks
		local edge = 8
		for i = 0, edge - 1 do
			local a = (i + 0.5) / edge * math.pi * 2
			local r = 2.95 + rnd(-0.15, 0.2)
			local h = 0.6 + rnd(0, 0.35)
			local col = (i % 3 == 0) and DIRT or DIRT_DK
			B:block(soil, v(rnd(1.3, 1.8), h, rnd(1.0, 1.4)), cf(math.cos(a) * r, h / 2, math.sin(a) * r, 0, -math.deg(a) + rnd(-12, 12), 0), col, S)
		end
		-- lighter middle tier
		B:block(soil, v(4.2, 0.6, 3.2), cf(0, 0.95, 0), DIRT, S)
		B:block(soil, v(3.2, 0.6, 4.2), cf(0, 0.95, 0), DIRT, S)
		-- small top tier
		B:block(soil, v(2.4, 0.4, 2.4), cf(0, 1.4, 0), DIRT_LT, S)
		-- tiny grass tufts
		B:block(soil, v(0.35, 0.7, 0.35), cf(-3.3, 0.35, -1.6), GRASS, S)
		B:block(soil, v(0.3, 0.5, 0.3), cf(-3.0, 0.25, -2.0), GRASS, S)
		B:block(soil, v(0.35, 0.6, 0.35), cf(2.9, 0.3, 2.3), GRASS, S)

		------------------------------------------------------------ trunk
		local crop = B:bone("Crop", "Root", v(0, 1.6, 0))
		B:block(crop, v(1.9, 0.5, 1.9), cf(0, 1.75, 0), BARK_DK)
		B:block(crop, v(1.5, 0.5, 1.5), cf(0, 2.2, 0, 0, 45, 0), BARK_DK)
		B:block(crop, v(1.2, 2.2, 1.2), cf(0, 3.3, 0), BARK)
		B:block(crop, v(0.6, 0.6, 1.6), cf(0.4, 3.6, -0.7, -35, 20, 0), BARK)
		B:block(crop, v(1.6, 0.6, 0.6), cf(-0.7, 3.8, 0.3, 0, 15, 35), BARK)

		------------------------------------------------------------ canopy
		local CY = 4.2
		local K = 0.95 -- crown scale
		local leaves = {
			-- x, y, z, size, rx, ry, rz, colour
			{ 0.0, 0.0, 0.0, 3.6, 12, 25, 8, LEAF },
			{ -1.75, -0.55, -0.5, 3.0, -10, 40, 15, LEAF_DK },
			{ 1.8, -0.45, 0.4, 3.0, 15, -20, -12, LEAF_DK },
			{ 0.3, -0.6, 1.8, 2.9, 20, 10, -15, LEAF_DK },
			{ -0.5, -0.4, -1.8, 2.8, -15, 62, 10, LEAF },
			{ 0.7, 0.85, -0.5, 2.6, 30, 45, 20, LEAF_LT },
			{ -1.0, 0.75, 0.9, 2.4, -22, 15, 30, LEAF_LT },
			{ 1.5, 0.6, 1.4, 2.3, 10, 70, -25, LEAF },
			{ -1.6, 0.5, -1.3, 2.2, 25, -30, -20, LEAF_LT },
		}
		local leafParts = {}
		for _, l in leaves do
			local sz = l[4] * K
			local p = B:block(crop, v(sz, sz, sz), cf(l[1] * K, CY + l[2] * K, l[3] * K, l[5], l[6], l[7]), l[8])
			table.insert(leafParts, p)
		end

		------------------------------------------------------------ limes
		-- directions on the crown (phi = around Y, theta = up from horizontal)
		local limes = {
			{ -35, 10 }, { 20, 25 }, { 75, 5 }, { 130, 20 }, { 180, 0 },
			{ 230, 30 }, { 280, 8 }, { 325, 40 }, { 100, 55 }, { 250, 60 }, { 0, -15 },
			{ 45, -22 }, { 300, -20 }, { 160, -18 },
		}
		local glowN = 0
		local firstGlow
		for i, d in limes do
			local phi, th = math.rad(d[1] - 90), math.rad(d[2])
			local rx, ry = (d[2] < 0 and 3.05 or 2.75) * K, 1.95 * K
			local dir = v(math.cos(phi) * math.cos(th), math.sin(th), math.sin(phi) * math.cos(th))
			local pos = v(dir.X * rx, CY + 0.2 + dir.Y * ry, dir.Z * rx)
			local rot = cf(pos.X, pos.Y, pos.Z, rnd(-25, 25), rnd(0, 90), rnd(-25, 25))
			-- oval lime: body + slightly longer core
			B:block(crop, v(1.05, 0.95, 1.05), rot, LIME)
			B:block(crop, v(0.75, 0.75, 1.35), rot, LIME_DK)
			do
				-- glowing highlight cube facing outward
				glowN += 1
				local g = B:block(crop, v(0.55, 0.55, 0.55), cf(pos.X + dir.X * 0.42, pos.Y + 0.18 + dir.Y * 0.3, pos.Z + dir.Z * 0.42, 0, 45, 0), LIME_GLOW, { mat = "Neon", name = "LimeGlow" .. glowN })
				firstGlow = firstGlow or g
			end
		end

		------------------------------------------------------------ fx
		B:emitter(leafParts[6], "sparkle", { name = "LimeSparkle", color = { "#e6ff8a", "#9dff3c" }, rate = 3, size = 0.35 })
		B:emitter(leafParts[1], "glow", { name = "LimeGlowFx", color = "#b8ff4a", rate = 1.5, size = 0.6 })
		B:light(leafParts[1], { color = "#b8ff4a", brightness = 0.9, range = 9, name = "LimeLight" })
	end,
}
