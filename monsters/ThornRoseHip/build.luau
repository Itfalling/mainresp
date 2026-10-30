--!nocheck
-- Rose Hip Briar (Thorny Woods plant #2, Uncommon).
-- A tall wild-rose briar climbing an old wooden trellis (two posts, three
-- rails and a big rustic X brace) on a stepped forest-dirt mound with moss
-- pads, roots, stones, fallen petals and a little mushroom. Dark-green briar
-- canes studded with rose-red thorns weave up the trellis, crest over the top
-- rail and arch out to the sides. Clumps of glossy rose leaves, open pink
-- dog-roses (stepped 8-point petals, pale inner ring, tiny glowing gold
-- centre) and plump orange-red rose hips with dark dried tips hanging in
-- bunches from the arching cane ends. Static prop: no motion.luau.
return {
	DisplayName = "Rose Hip Briar",
	Rarity = "Uncommon",
	Element = "Thorn",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Thorny Woods)
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3a2214", "#4a2b19", "#634027", "#7e5433"
		local MOSS, MOSS_DK = "#5fae3a", "#3f8a2c"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_DK = "#8d8a80", "#686660"
		local ROOT = "#4a3320"
		local MUSH_STEM, MUSH_CAP = "#efe3c8", "#b8743c"
		local WOOD, WOOD_DK, WOOD_LT = "#a07a4a", "#765633", "#bf9a66"
		local CANE, CANE_DK = "#3f7a2e", "#2c5a22"
		local THORN = "#c8304e"
		local LEAF_DK, LEAF, LEAF_LT, LEAF_TOP = "#24632c", "#2f7f35", "#4b9e3c", "#6fba45"
		local PETAL, PETAL_DK, PETAL_LT, CENTER = "#ff86b3", "#e8588f", "#ffc4da", "#ffd84a"
		local SEPAL = "#3a7a2a"
		local HIP, HIP_LT, HIP_DK, HIP_TIP = "#e0402a", "#ff6d3a", "#b82d22", "#4a2a1a"
		local STEM = "#4f7a2a"

		local seed = 1322
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
				local w, d = rnd(1.4, 2.1), rnd(1.1, 1.5)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.3)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.75, 4.3, DIRT_DK, 11, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.75, 0.55, 3.0, DIRT, 6, { DIRT, DIRT_LT, DIRT }, 0.25)
		tier(1.3, 0.35, 1.9, DIRT_LT, 0, {}, 0)

		-- moss pads draped over the lower tier edge
		for _, m in { { 20, 4.25, 1.8, MOSS }, { 115, 4.3, 1.6, MOSS_DK }, { 205, 4.25, 1.9, MOSS }, { 290, 4.3, 1.5, MOSS_DK } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], 0.87, -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[3], 0.3, 1.2), c * ang(-14, 0, 0), m[4], S)
		end
		-- gnarly roots spilling down the mound
		B:bar(soil, v(-0.8, 1.6, -0.6), v(-2.6, 0.85, -2.3), 0.5, 0.45, ROOT, S)
		B:bar(soil, v(0.9, 1.6, -0.4), v(3.0, 0.8, -1.4), 0.45, 0.4, ROOT, S)
		-- stones
		B:block(soil, v(1.0, 0.75, 0.85), cf(-3.4, 1.0, 1.6, 6, 25, -8), STONE, S)
		B:block(soil, v(0.6, 0.5, 0.55), cf(-3.9, 0.85, 0.8, -5, 50, 6), STONE_DK, S)
		-- a little tan mushroom (front-right)
		B:block(soil, v(0.4, 0.75, 0.4), cf(2.5, 1.15, -2.6, 0, 20, 0), MUSH_STEM, S)
		B:block(soil, v(1.0, 0.36, 1.0), cf(2.5, 1.6, -2.6, 0, 20, 0), MUSH_CAP, S)
		-- fallen petals + a dropped hip
		B:block(soil, v(0.6, 0.12, 0.6), cf(-1.4, 1.71, -1.3, 0, 30, 0), PETAL, S)
		B:block(soil, v(0.5, 0.12, 0.5), cf(-2.6, 1.36, -1.6, 0, 70, 0), PETAL_LT, S)
		B:block(soil, v(0.55, 0.12, 0.55), cf(1.6, 1.36, -2.0, 0, 10, 0), PETAL_DK, S)
		B:block(soil, v(0.75, 0.75, 0.9), cf(-0.4, 1.95, -1.6, 0, 25, 80), HIP, S)
		-- tiny grass tufts
		for _, g in { { 4.3, -0.6 }, { 1.0, 4.3 }, { -2.2, -3.6 } } do
			B:block(soil, v(0.38, 0.85, 0.38), cf(g[1], 0.65, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.3, 0.55, 0.3), cf(g[1] + 0.28, 0.5, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end

		------------------------------------------------------------ trellis
		local crop = B:bone("Crop", "Root", v(0, 1.65, 0))
		local TZ, PX, TOP = 1.4, 2.5, 12.6
		for _, sx in { -1, 1 } do
			B:block(crop, v(0.8, TOP - 1.0, 0.8), cf(sx * PX, 1.0 + (TOP - 1.0) / 2, TZ), WOOD)
			B:block(crop, v(1.05, 0.45, 1.05), cf(sx * PX, TOP + 0.2, TZ), WOOD_LT)
			B:block(crop, v(1.1, 0.5, 1.1), cf(sx * PX, 1.45, TZ, 0, 15, 0), WOOD_DK) -- foot
		end
		-- rails (top one overhangs)
		B:block(crop, v(2 * PX + 0.9, 0.45, 0.45), cf(0, 5.2, TZ - 0.05), WOOD_DK)
		B:block(crop, v(2 * PX + 0.9, 0.45, 0.45), cf(0, 9.0, TZ - 0.05), WOOD_DK)
		B:block(crop, v(2 * PX + 2.2, 0.55, 0.6), cf(0, TOP - 0.45, TZ), WOOD)
		-- rustic X brace
		B:bar(crop, v(-PX + 0.2, 2.2, TZ + 0.12), v(PX - 0.2, 11.6, TZ + 0.12), 0.38, 0.32, WOOD_LT)
		B:bar(crop, v(PX - 0.2, 2.2, TZ - 0.12), v(-PX + 0.2, 11.6, TZ - 0.12), 0.38, 0.32, WOOD_LT)

		------------------------------------------------------------ canes
		B:block(crop, v(1.6, 0.6, 1.6), cf(0, 1.85, 0.3, 0, 45, 0), CANE_DK) -- crown
		local function cane(pts, w, thornEvery)
			for i = 1, #pts - 1 do
				local p, q = pts[i], pts[i + 1]
				local d = (q - p).Unit
				B:bar(crop, p - d * 0.18, q + d * 0.18, w, w, i == 1 and CANE_DK or CANE)
				if i % thornEvery == 0 then
					local side = d:Cross(v(rnd(-1, 1), rnd(-0.3, 0.3), rnd(-1, 1))).Unit
					local m = p:Lerp(q, rnd(0.35, 0.65))
					B:bar(crop, m, m + side * 0.75, 0.24, 0.24, THORN)
				end
			end
		end
		local c1 = { v(-0.4, 1.7, 0.4), v(-1.2, 4.2, 0.85), v(-1.9, 6.7, 0.95), v(-1.6, 9.2, 0.9), v(-1.0, 11.5, 0.85), v(-0.3, 13.0, 0.7) }
		local c2 = { v(0.4, 1.7, 0.4), v(1.3, 4.3, 0.85), v(1.9, 6.9, 0.95), v(1.4, 9.6, 0.9), v(1.8, 11.6, 0.8), v(2.7, 13.0, 0.55), v(3.8, 12.6, 0.3), v(4.4, 11.2, 0.1) }
		local c3 = { v(-0.3, 1.7, 0.0), v(-1.5, 4.8, -0.3), v(-2.9, 7.6, -0.45), v(-4.0, 9.0, -0.55), v(-4.8, 8.6, -0.6), v(-5.2, 7.4, -0.6) }
		local c4 = { v(0.3, 1.7, -0.2), v(1.4, 3.9, -0.8), v(2.6, 5.5, -1.25), v(3.7, 6.2, -1.55), v(4.5, 5.6, -1.65), v(4.8, 4.5, -1.6) }
		local c5 = { v(-1.0, 11.5, 0.85), v(-2.3, 12.6, 0.7), v(-3.5, 12.8, 0.45), v(-4.3, 11.8, 0.2), v(-4.5, 10.6, 0.1) }
		cane(c1, 0.55, 2)
		cane(c2, 0.55, 2)
		cane(c3, 0.5, 2)
		cane(c4, 0.5, 2)
		cane(c5, 0.45, 2)
		-- a back cane so the trellis reads leafy from behind too
		local c6 = { v(0.2, 1.7, 0.8), v(0.7, 4.6, 2.2), v(1.0, 7.6, 2.4), v(0.5, 10.4, 2.3) }
		cane(c6, 0.45, 2)

		------------------------------------------------------------ leaves
		local leafParts = {}
		local function leaves(c, list)
			for _, l in list do
				local s = l[4]
				table.insert(leafParts, B:block(crop, v(s, s, s), cf(c.X + l[1], c.Y + l[2], c.Z + l[3], rnd(-20, 20), rnd(0, 90), rnd(-20, 20)), l[5]))
			end
		end
		-- crest over the top rail
		leaves(v(0, 13.0, 0.9), { { -0.9, 0, 0.2, 2.2, LEAF }, { 0.9, 0.1, 0.3, 2.0, LEAF_DK }, { 0.0, 0.7, 0.8, 1.6, LEAF_TOP } })
		leaves(v(-3.2, 12.5, 0.5), { { 0, 0, 0, 2.0, LEAF_LT }, { -0.6, -0.8, 0.5, 1.5, LEAF_DK } })
		leaves(v(3.1, 12.7, 0.5), { { 0, 0, 0, 2.0, LEAF }, { 0.6, -0.8, 0.4, 1.5, LEAF_LT } })
		-- climbing the lattice
		leaves(v(-1.8, 7.6, 0.6), { { 0, 0, 0, 1.8, LEAF_DK }, { 0.3, 1.0, 0.4, 1.4, LEAF_LT } })
		leaves(v(1.7, 9.0, 0.6), { { 0, 0, 0, 1.8, LEAF }, { -0.3, -1.0, 0.4, 1.4, LEAF_DK } })
		leaves(v(-1.3, 10.8, 0.7), { { 0, 0, 0, 1.5, LEAF } })
		leaves(v(1.5, 5.2, 0.6), { { 0, 0, 0, 1.5, LEAF_LT } })
		-- the arches
		leaves(v(-4.0, 9.1, -0.4), { { 0, 0, 0, 1.8, LEAF }, { 0.7, -0.6, 0.6, 1.4, LEAF_DK } })
		leaves(v(3.3, 6.2, -1.3), { { 0, 0, 0, 1.8, LEAF_DK }, { -0.7, 0.5, 0.5, 1.4, LEAF_LT } })
		-- behind the trellis
		leaves(v(0.9, 6.4, 2.6), { { 0, 0, 0, 1.8, LEAF }, { -0.6, -1.1, 0.1, 1.4, LEAF_DK } })
		leaves(v(0.4, 10.6, 2.4), { { 0, 0, 0, 1.7, LEAF_LT } })
		leaves(v(-1.4, 4.0, 2.3), { { 0, 0, 0, 1.6, LEAF_DK } })
		-- low skirt
		leaves(v(0, 2.8, 0.2), { { 1.4, 0, -0.6, 1.7, LEAF_DK }, { -1.4, 0.3, -0.3, 1.6, LEAF }, { 0.0, 0.1, 1.5, 1.7, LEAF_DK } })

		------------------------------------------------------------ roses
		local centers = {}
		-- open dog-rose: green sepal star, two pink squares at 0/45 deg (8-point
		-- petal star), a pale inner ring and a small glowing gold centre.
		-- n = direction the flower faces.
		local function rose(p, n, s, idx)
			local F = P.aim(p, p + n) * ang(0, 0, rnd(0, 45))
			B:block(crop, v(1.3 * s, 1.3 * s, 0.3), F * CFrame.new(0, 0, 0.28) * ang(0, 0, 22.5), SEPAL)
			B:block(crop, v(2.0 * s, 2.0 * s, 0.4), F, PETAL)
			B:block(crop, v(2.0 * s, 2.0 * s, 0.44), F * CFrame.new(0, 0, 0.02) * ang(0, 0, 45), PETAL_DK)
			B:block(crop, v(1.25 * s, 1.25 * s, 0.4), F * CFrame.new(0, 0, -0.2) * ang(0, 0, 22.5), PETAL_LT)
			table.insert(centers, B:block(crop, v(0.6 * s, 0.6 * s, 0.4), F * CFrame.new(0, 0, -0.38), CENTER, { mat = "Neon", name = "RoseHeart" .. idx }))
		end
		rose(v(0.1, 14.0, 0.2), v(0, 1, -0.55), 1.15, 1)
		rose(v(-2.9, 13.4, -0.1), v(-0.3, 0.8, -0.6), 1.0, 2)
		rose(v(2.9, 13.6, -0.1), v(0.3, 0.8, -0.6), 1.0, 3)
		rose(v(-2.1, 9.9, -0.15), v(-0.2, 0.25, -1), 1.0, 4)
		rose(v(2.3, 7.5, -0.05), v(0.25, 0.2, -1), 1.0, 5)
		rose(v(-3.4, 8.3, -1.3), v(-0.35, 0.3, -1), 0.95, 6)
		rose(v(2.3, 4.6, -1.8), v(0.2, 0.35, -1), 0.9, 7)
		rose(v(1.2, 8.4, 3.0), v(0.3, 0.3, 1), 0.95, 8)
		rose(v(-1.9, 11.4, 2.2), v(-0.3, 0.4, 1), 0.9, 9)

		------------------------------------------------------------ rose hips
		-- plump orange-red hip: cube + taller cube turned 45 deg, dark dried tip
		local function hip(p, s, tilt)
			local yaw = rnd(0, 40)
			local F = CFrame.new(p) * ang(0, yaw, tilt)
			B:block(crop, v(0.95 * s, 1.25 * s, 0.95 * s), F, HIP)
			B:block(crop, v(0.72 * s, 1.6 * s, 0.72 * s), F * ang(0, 45, 0), HIP_LT)
			B:block(crop, v(0.4 * s, 0.35 * s, 0.4 * s), F * CFrame.new(0, -0.92 * s, 0) * ang(0, 45, 0), HIP_TIP)
		end
		-- bunch of hips hanging below a cane tip
		local function bunch(tip, n)
			local c = tip + v(0, -1.1, 0)
			B:bar(crop, tip, c, 0.2, 0.2, STEM)
			B:block(crop, v(0.7, 0.22, 0.7), CFrame.new(c) * ang(0, 45, 0), STEM)
			local offs = { v(-0.55, -0.85, -0.1), v(0.55, -0.95, 0.1), v(0.0, -1.0, -0.6) }
			local tilts = { 12, -12, 0 }
			for k = 1, n do
				hip(c + offs[k], k == 3 and 0.95 or 1.05, tilts[k])
			end
		end
		bunch(c2[#c2] + v(0, -0.05, 0), 3)
		bunch(c3[#c3] + v(0, -0.05, 0), 3)
		bunch(c4[#c4] + v(0, -0.05, 0), 2)
		bunch(c5[#c5] + v(0, -0.05, 0), 3)
		bunch(v(-1.75, 6.0, 0.2), 2)
		bunch(v(1.75, 10.8, 0.3), 2)

		------------------------------------------------------------ fx
		B:emitter(centers[1], "sparkle", { name = "RoseSparkle", color = { "#fff2c2", "#ff9cc4" }, rate = 2.5, size = 0.3 })
		B:light(leafParts[1], { color = "#ffb0cc", brightness = 0.7, range = 10, name = "RoseLight" })
	end,
}
