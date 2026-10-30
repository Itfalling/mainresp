--!nocheck
-- Bramble Berry Cane (Thorny Woods plant #1, Common).
-- A tall bramble tied to an old wooden stake on a stepped forest-dirt mound
-- (moss pads, a little tan mushroom pair, stones, fallen leaves, a thorny twig
-- and a dropped berry). Four purple-red bramble canes climb the stake and arch
-- out like a fountain, studded with small cream thorns and clumps of big
-- rotated leaf cubes. Clusters of glossy blackberries (stepped octagon cubes
-- with a tiny lavender shine) and red unripe berries hang from the cane tips.
-- Static prop: no motion.luau.
return {
	DisplayName = "Bramble Berry Cane",
	Rarity = "Common",
	Element = "Thorn",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Thorny Woods)
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3a2214", "#4a2b19", "#634027", "#7e5433"
		local MOSS, MOSS_DK = "#5fae3a", "#3f8a2c"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_DK = "#8d8a80", "#686660"
		local LEAF_FALL = "#c98a2e"
		local MUSH_STEM, MUSH_CAP, MUSH_CAP_DK = "#efe3c8", "#b8743c", "#8f5428"
		local WOOD, WOOD_DK, WOOD_LT, TWINE = "#94703f", "#6b4e2b", "#b08a55", "#e0c98e"
		local CANE, CANE_DK = "#7e3550", "#5c2238"
		local THORN = "#f2dcb4"
		local LEAF_DK, LEAF, LEAF_LT, LEAF_TOP = "#2a6e30", "#378a38", "#55a83e", "#79c248"
		local STEM = "#4f6b2a"
		local BB, BB_LT = "#33194f", "#55317e"
		local RB, RB_LT = "#d3263a", "#ff5a4c"
		local SHINE = "#efe2ff"

		local seed = 1311
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
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.4, 2.0), rnd(1.1, 1.5)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.3)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.75, 4.0, DIRT_DK, 10, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.75, 0.55, 2.8, DIRT, 6, { DIRT, DIRT_LT, DIRT }, 0.25)
		tier(1.3, 0.35, 1.8, DIRT_LT, 0, {}, 0)

		-- moss pads draped over the lower tier edge
		for _, m in { { 40, 3.95, 1.8, MOSS }, { 140, 4.0, 1.6, MOSS_DK }, { 250, 3.95, 1.9, MOSS } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], 0.87, -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[3], 0.3, 1.2), c * ang(-14, 0, 0), m[4], S)
		end
		-- a pair of little tan forest mushrooms (front-left)
		B:block(soil, v(0.45, 0.8, 0.45), cf(-2.55, 1.15, -2.3, 0, 20, 0), MUSH_STEM, S)
		B:block(soil, v(1.15, 0.4, 1.15), cf(-2.55, 1.65, -2.3, 0, 20, 0), MUSH_CAP, S)
		B:block(soil, v(0.3, 0.5, 0.3), cf(-1.85, 1.0, -2.85, 0, 50, 0), MUSH_STEM, S)
		B:block(soil, v(0.7, 0.28, 0.7), cf(-1.85, 1.32, -2.85, 0, 50, 0), MUSH_CAP_DK, S)
		-- stones
		B:block(soil, v(1.0, 0.75, 0.85), cf(3.3, 1.0, 1.8, 6, 25, -8), STONE, S)
		B:block(soil, v(0.6, 0.5, 0.55), cf(3.7, 0.85, 1.0, -5, 50, 6), STONE_DK, S)
		-- fallen leaves
		B:block(soil, v(1.0, 0.12, 0.7), cf(1.9, 1.36, -2.1, 0, 35, 4), LEAF_FALL, S)
		-- a thorny twig lying on the mound (back-left)
		B:bar(soil, v(-3.4, 0.85, 0.2), v(-1.6, 1.45, 2.4), 0.3, 0.3, WOOD_DK, S)
		B:bar(soil, v(-2.6, 1.1, 1.25), v(-2.95, 1.55, 1.45), 0.16, 0.16, THORN, S)
		B:bar(soil, v(-2.1, 1.3, 1.85), v(-1.75, 1.55, 1.6), 0.16, 0.16, THORN, S)
		-- a dropped blackberry on the soil
		B:block(soil, v(0.75, 0.75, 0.75), cf(1.0, 1.95, -1.55, 0, 20, 0), BB, S)
		B:block(soil, v(0.6, 0.85, 0.6), cf(1.0, 1.98, -1.55, 0, 65, 0), BB_LT, S)
		-- tiny grass tufts
		for _, g in { { 4.1, -1.0 }, { -1.2, 4.0 } } do
			B:block(soil, v(0.38, 0.85, 0.38), cf(g[1], 0.65, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.3, 0.55, 0.3), cf(g[1] + 0.28, 0.5, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end

		------------------------------------------------------------ stake
		local crop = B:bone("Crop", "Root", v(0, 1.65, 0))
		local SX, SZ = 0, 0.45
		B:block(crop, v(1.0, 10.9, 1.0), cf(SX, 1.4 + 5.45, SZ), WOOD)
		B:block(crop, v(0.65, 0.5, 0.65), cf(SX, 12.55, SZ), WOOD_LT)
		B:block(crop, v(1.04, 1.8, 0.35), cf(SX + 0.05, 6.0, SZ - 0.36), WOOD_DK) -- grain/knot strip
		B:block(crop, v(0.35, 0.35, 0.5), cf(SX - 0.3, 9.4, SZ - 0.6), WOOD_DK) -- knot
		-- twine ties
		for _, y in { 4.4, 7.9, 10.9 } do
			B:block(crop, v(1.3, 0.32, 1.3), cf(SX + 0.1, y, SZ, 0, rnd(-8, 8), rnd(-6, 6)), TWINE)
		end

		------------------------------------------------------------ canes
		B:block(crop, v(1.7, 0.6, 1.7), cf(0, 1.85, 0.3, 0, 45, 0), CANE_DK) -- crown
		local function cane(pts, w)
			for i = 1, #pts - 1 do
				local p, q = pts[i], pts[i + 1]
				local d = (q - p).Unit
				B:bar(crop, p - d * 0.2, q + d * 0.2, w, w, i == 1 and CANE_DK or CANE)
				-- small cream thorns poking out sideways on every other segment
				if i % 2 == 0 or i == #pts - 1 then
					local side = d:Cross(v(rnd(-1, 1), rnd(-0.3, 0.3), rnd(-1, 1))).Unit
					local m = p:Lerp(q, rnd(0.35, 0.65))
					B:bar(crop, m, m + side * 0.9, 0.28, 0.28, THORN)
				end
			end
		end
		local caneA = { v(0.7, 1.7, 0.45), v(0.75, 4.8, 0.45), v(0.75, 8.2, 0.4), v(0.8, 10.8, 0.3), v(1.4, 12.3, 0.0), v(2.5, 12.7, -0.45), v(3.5, 12.1, -0.9), v(4.0, 10.8, -1.2) }
		local caneB = { v(-0.5, 1.7, 0.2), v(-1.2, 4.5, 0.1), v(-2.1, 7.3, 0.0), v(-3.0, 9.3, -0.2), v(-3.9, 10.1, -0.5), v(-4.7, 9.5, -0.8), v(-5.0, 8.2, -0.9) }
		local caneC = { v(0.5, 1.7, 0.7), v(1.4, 3.8, 0.9), v(2.5, 5.7, 1.1), v(3.5, 7.2, 1.0), v(4.4, 7.5, 0.7), v(5.0, 6.7, 0.4), v(5.2, 5.4, 0.2) }
		local caneD = { v(-0.3, 1.7, 0.9), v(-0.6, 4.8, 1.4), v(-0.8, 7.9, 1.9), v(-1.0, 9.9, 2.4), v(-1.3, 10.9, 3.1), v(-1.6, 10.4, 3.8), v(-1.8, 9.1, 4.1) }
		cane(caneA, 0.65)
		cane(caneB, 0.6)
		cane(caneC, 0.6)
		cane(caneD, 0.55)

		------------------------------------------------------------ leaves
		local leafParts = {}
		local function leaves(c, list)
			for _, l in list do
				local s = l[4]
				table.insert(leafParts, B:block(crop, v(s, s, s), cf(c.X + l[1], c.Y + l[2], c.Z + l[3], rnd(-20, 20), rnd(0, 90), rnd(-20, 20)), l[5]))
			end
		end
		-- crown over the top of the stake
		leaves(v(0.3, 12.0, 0.6), { { -0.5, 0.0, 0.4, 2.5, LEAF }, { 0.9, -0.2, 0.3, 2.0, LEAF_DK }, { -0.1, 0.9, 0.2, 1.6, LEAF_TOP } })
		-- a leaf mass at the top of each arch
		leaves(v(2.6, 12.6, -0.4), { { 0, 0, 0.2, 2.1, LEAF_LT }, { 0.8, -0.6, -0.4, 1.6, LEAF_DK } })
		leaves(v(-3.6, 10.3, -0.3), { { 0, 0, 0, 2.1, LEAF }, { -0.8, 0.5, 0.5, 1.6, LEAF_TOP } })
		leaves(v(4.0, 7.8, 0.8), { { 0, 0, 0, 2.0, LEAF_DK }, { 0.4, 0.8, -0.7, 1.5, LEAF_LT } })
		leaves(v(-1.2, 10.9, 3.0), { { 0, 0.2, 0, 2.0, LEAF }, { 0.8, -0.5, -0.5, 1.5, LEAF_DK } })
		-- mid mass tucked behind the stake
		leaves(v(0, 7.6, 1.5), { { -0.6, 0, 0.2, 2.1, LEAF_DK }, { 0.8, 0.9, 0.0, 1.7, LEAF } })
		-- a few single leaves along the canes so the arches read leafy
		leaves(v(-2.2, 7.0, -0.1), { { 0, 0, -0.3, 1.6, LEAF_LT } })
		leaves(v(2.6, 5.6, 1.0), { { 0.2, 0, -0.4, 1.6, LEAF } })
		leaves(v(1.6, 9.4, 0.9), { { 0, 0, 0, 1.7, LEAF_DK } })
		leaves(v(-4.3, 9.0, -0.6), { { 0, 0, 0, 1.3, LEAF } })
		-- low bushy skirt
		leaves(v(0, 2.8, 0.2), { { 1.4, 0, -0.7, 1.8, LEAF_DK }, { -1.4, 0.3, -0.4, 1.7, LEAF }, { 0.2, 0.2, 1.6, 1.8, LEAF_DK } })

		------------------------------------------------------------ berries
		local shines = {}
		-- a blackberry: a cube + a taller cube turned 45 deg -> stepped octagon drupe
		local function berry(p, ripe, sz)
			local yaw = rnd(0, 40)
			B:block(crop, v(sz, sz, sz), CFrame.new(p) * ang(0, yaw, 0), ripe and BB or RB)
			B:block(crop, v(sz * 0.8, sz * 1.18, sz * 0.8), CFrame.new(p) * ang(0, yaw + 45, 0), ripe and BB_LT or RB_LT)
		end
		-- hanging cluster under a point on a cane: short green stem, 3 berries
		local function cluster(tip, ripeMask, idx)
			local c = tip + v(0, -1.5, 0)
			B:bar(crop, tip, c + v(0, 0.5, 0), 0.22, 0.22, STEM)
			B:block(crop, v(0.95, 0.25, 0.95), CFrame.new(c + v(0, 0.62, 0)) * ang(0, 45, 0), STEM) -- calyx
			local offs = { v(-0.58, 0, -0.15), v(0.58, -0.1, 0.1), v(0.0, -1.05, -0.05) }
			for k, o in offs do
				berry(c + o, ripeMask[k], k == 3 and 1.1 or 1.2)
			end
			-- glossy shine on the front of the cluster
			table.insert(shines, B:block(crop, v(0.26, 0.26, 0.1), CFrame.new(c + v(-0.72, 0.22, -0.84)), SHINE, { mat = "Neon", name = "BerryShine" .. idx }))
		end
		cluster(caneA[#caneA] + v(0, -0.1, 0), { true, true, false }, 1)
		cluster(caneB[#caneB] + v(0, -0.1, 0), { true, false, true }, 2)
		cluster(caneC[#caneC] + v(0, -0.1, 0), { true, true, true }, 3)
		cluster(caneD[#caneD] + v(0, -0.1, 0), { false, true, true }, 4)
		cluster(v(-0.9, 12.0, -0.55), { false, true, true }, 5)

		------------------------------------------------------------ fx
		B:emitter(leafParts[3], "sparkle", { name = "BerrySparkle", color = { "#efe2ff", "#b98cff" }, rate = 2, size = 0.3 })
		B:light(leafParts[1], { color = "#d8c2ff", brightness = 0.6, range = 9, name = "BerryLight" })
	end,
}
