--!nocheck
-- Striped Gourd Vine (Scarecrow Stage plant #1, Common).
-- A clean, low gourd vine: a stepped straw-strewn dirt mound, four big flat
-- studded leaves lying around it, one short vine curling into a tendril, and
-- three chunky striped gourds (orange, yellow with a bent neck, cream), each
-- with bold green bands, a stem and a tiny neon shine.
-- Static prop: no motion.luau.
return {
	DisplayName = "Striped Gourd Vine",
	Rarity = "Common",
	Element = "Harvest",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette
		local DIRT_DK, DIRT, DIRT_LT = "#4a2a16", "#744526", "#93603a"
		local GRASS = "#6fbf3a"
		local HAY, HAY_DK = "#e8c45a", "#c99a35"
		local VINE_DK, VINE = "#3d6e22", "#4f8a2a"
		local LEAF_DK, LEAF, LEAF_LT = "#2f7d30", "#43993a", "#8cc23f"
		local AUTUMN = "#d99a2b"
		local ORANGE, CREAM = "#ff8a1f", "#fff0c4"
		local YELLOW, GREEN, GREEN_DK = "#ffd23a", "#3f9a3a", "#2a6b2a"
		local STEM = "#6b4a24"
		local SHINE = "#fff6c8"

		local seed = 101
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		------------------------------------------------------------ soil mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(6.4, 0.7, 4.6), cf(0, 0.35, 0), DIRT_DK, S)
		B:block(soil, v(4.6, 0.7, 6.4), cf(0, 0.35, 0), DIRT_DK, S)
		local edge = 9
		for i = 0, edge - 1 do
			local a = (i + 0.5) / edge * math.pi * 2
			local r = 3.05 + rnd(-0.15, 0.2)
			local h = 0.6 + rnd(0, 0.35)
			local col = (i % 3 == 0) and DIRT or DIRT_DK
			B:block(soil, v(rnd(1.3, 1.8), h, rnd(1.0, 1.4)), cf(math.cos(a) * r, h / 2, math.sin(a) * r, 0, -math.deg(a) + rnd(-12, 12), 0), col, S)
		end
		B:block(soil, v(4.4, 0.6, 3.2), cf(0, 0.95, 0), DIRT, S)
		B:block(soil, v(3.2, 0.6, 4.4), cf(0, 0.95, 0), DIRT, S)
		B:block(soil, v(2.4, 0.4, 2.4), cf(0, 1.4, 0, 0, 20, 0), DIRT_LT, S)
		-- grass tufts
		B:block(soil, v(0.35, 0.7, 0.35), cf(-3.4, 0.35, 1.4), GRASS, S)
		B:block(soil, v(0.3, 0.5, 0.3), cf(-3.1, 0.25, 1.85), GRASS, S)
		B:block(soil, v(0.35, 0.6, 0.35), cf(3.0, 0.3, 2.3), GRASS, S)
		-- straw bits lying on the mound
		for _, h in { { -3.0, 0.72, 1.3, 30 }, { 2.9, 0.72, 1.3, -55 }, { 0.4, 0.72, -3.1, 10 } } do
			B:block(soil, v(1.4, 0.14, 0.18), cf(h[1], h[2] + 0.07, h[3], 0, h[4], 0), HAY, S)
			B:block(soil, v(1.0, 0.12, 0.16), cf(h[1] + 0.1, h[2] + 0.09, h[3] + 0.15, 0, h[4] + 25, 0), HAY_DK, S)
		end

		------------------------------------------------------------ vine + leaves
		local crop = B:bone("Crop", "Root", v(0, 1.6, 0))
		local leafParts = {}

		-- 4 big flat studded leaves lying on the mound, each with a lighter centre patch
		local function bigLeaf(yaw, r, s, col, colC)
			local c = cf(0, 1.55, 0, 0, yaw, 0) * CFrame.new(0, -0.15, -r) * ang(-14, 0, 0) * ang(0, 45, 0)
			local p = B:block(crop, v(s, 0.4, s), c, col)
			B:block(crop, v(s * 0.45, 0.4, s * 0.45), c * CFrame.new(0, 0.08, 0), colC)
			table.insert(leafParts, p)
		end
		bigLeaf(55, 2.6, 2.5, LEAF, LEAF_LT)
		bigLeaf(145, 2.6, 2.4, LEAF_DK, LEAF)
		bigLeaf(235, 2.6, 2.5, LEAF, LEAF_LT)
		bigLeaf(325, 2.5, 2.4, LEAF_DK, LEAF)

		-- one short vine rising from the centre and curling into a tendril
		B:block(crop, v(1.3, 0.6, 1.3), cf(0, 1.85, 0.2, 0, 30, 0), VINE_DK)
		B:block(crop, v(0.8, 1.2, 0.8), cf(0.1, 2.7, 0.2, 0, 10, -8), VINE)
		B:block(crop, v(0.65, 1.0, 0.65), cf(0.35, 3.65, 0.25, 0, 25, -18), VINE)
		local tx, ty, tz = 0.5, 4.25, 0.25
		for i = 0, 5 do
			local a = math.rad(i * 65)
			local r = 0.5 - i * 0.04
			B:block(crop, v(0.4, 0.4, 0.4), cf(tx + math.cos(a) * r, ty + i * 0.24, tz + math.sin(a) * r, 0, -i * 65, 0), VINE)
		end

		------------------------------------------------------------ gourds
		local shines = 0
		-- chunky gourd: body + stepped round cap + neck + stem, 2 bold bands each way
		local function gourd(c, s, body, stripe, neckH, lean)
			local w, h = 1.5 * s, 1.15 * s
			B:block(crop, v(w, h, w), c, body)
			B:block(crop, v(w * 0.72, h + 0.3 * s, w * 0.72), c, body)
			for _, k in { -0.26, 0.26 } do
				B:block(crop, v(0.24 * s, h + 0.08, w + 0.08), c * CFrame.new(k * w, 0, 0), stripe)
				B:block(crop, v(w + 0.08, h + 0.08, 0.24 * s), c * CFrame.new(0, 0, k * w), stripe)
			end
			local n = c * CFrame.new(0, h / 2 + 0.15 * s + neckH / 2, 0) * ang(0, 0, lean)
			B:block(crop, v(0.6 * s, neckH, 0.6 * s), n, body)
			B:block(crop, v(0.28 * s, 0.5 * s, 0.28 * s), n * CFrame.new(0, neckH / 2 + 0.2 * s, 0) * ang(0, 0, lean), STEM)
			shines += 1
			B:block(crop, v(0.26, 0.26, 0.26), c * CFrame.new(-0.36 * w, 0.4 * h, -0.5 * w - 0.03), SHINE, { mat = "Neon", name = "Shine" .. shines })
		end

		-- front-left: big orange gourd with dark green bands
		gourd(cf(-1.5, 1.3 + 0.8, -1.6, 0, 20, 0), 1.35, ORANGE, GREEN_DK, 0.45, 10)
		-- front-right: yellow gourd with green bands and a taller bent neck
		gourd(cf(1.75, 1.3 + 0.68, -1.3, 0, -25, 0), 1.15, YELLOW, GREEN, 0.8, -18)
		-- back: cream gourd with green bands
		gourd(cf(0.6, 1.3 + 0.62, 2.0, 0, 40, 0), 1.05, CREAM, GREEN, 0.4, 12)
		-- runners from the vine base to each gourd
		B:beam(crop, v(-0.4, 1.9, -0.1), v(-1.2, 2.2, -1.2), 0.45, 0.45, VINE_DK)
		B:beam(crop, v(0.4, 1.9, -0.1), v(1.5, 2.0, -1.0), 0.45, 0.45, VINE_DK)

		------------------------------------------------------------ fx
		B:emitter(leafParts[1], "sparkle", { name = "GourdSparkle", color = { "#fff2a8", "#ffb347" }, rate = 2, size = 0.3 })
		B:light(leafParts[1], { color = "#ffc46b", brightness = 0.7, range = 8, name = "GourdLight" })
	end,
}
