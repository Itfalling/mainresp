--!nocheck
-- Striped Gourd Vine (Scarecrow Stage plant #1, Common).
-- A low, bushy autumn gourd vine on a stepped dirt mound sprinkled with straw:
-- a stubby vine crown of big rotated studded leaf cubes, runners crawling over
-- the mound, a curly tendril on top and four small striped gourds (orange /
-- cream, yellow / green bicolour, a green crookneck and a little cream one)
-- resting on the soil and nestled in the leaves. Tiny neon shine accents.
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
		for _, h in { { -2.2, 1.27, 1.6, 30 }, { 2.4, 0.72, 1.9, -55 }, { 1.0, 1.27, -1.8, 75 }, { -2.9, 0.72, -1.2, 10 } } do
			B:block(soil, v(1.4, 0.14, 0.18), cf(h[1], h[2] + 0.07, h[3], 0, h[4], 0), HAY, S)
			B:block(soil, v(1.0, 0.12, 0.16), cf(h[1] + 0.1, h[2] + 0.09, h[3] + 0.15, 0, h[4] + 25, 0), HAY_DK, S)
		end

		------------------------------------------------------------ vine
		local crop = B:bone("Crop", "Root", v(0, 1.6, 0))
		B:block(crop, v(1.3, 0.8, 1.3), cf(0, 1.9, 0, 0, 30, 0), VINE_DK)
		B:block(crop, v(0.9, 1.4, 0.9), cf(0.1, 2.7, 0, 0, 10, 8), VINE)

		-- runners crawling out over the mound to the gourds
		local function runner(a, b)
			B:beam(crop, a, b, 0.45, 0.45, VINE_DK)
		end

		------------------------------------------------------------ leaves
		local leafParts = {}
		local function leaf(x, y, z, s, rx, ry, rz, col)
			local p = B:block(crop, v(s, s, s), cf(x, y, z, rx, ry, rz), col)
			table.insert(leafParts, p)
			return p
		end
		local CY = 3.0
		local LZ = 0.6
		leaf(0, CY, LZ, 2.7, 12, 25, 8, LEAF)
		leaf(-1.4, CY - 0.5, LZ + 0.1, 2.2, -10, 40, 15, LEAF_DK)
		leaf(1.4, CY - 0.45, LZ + 0.4, 2.2, 15, -20, -12, LEAF_DK)
		leaf(0.3, CY - 0.5, LZ + 1.5, 2.1, 20, 10, -15, LEAF)
		leaf(-0.3, CY - 0.6, LZ - 1.3, 2.0, -15, 62, 10, LEAF)
		leaf(0.6, CY + 0.85, LZ - 0.2, 1.8, 30, 45, 20, LEAF_LT)
		leaf(-0.8, CY + 0.6, LZ + 0.7, 1.7, -22, 15, 30, AUTUMN)
		-- flat leaves lying on the mound (ground cover)
		B:block(crop, v(1.9, 0.35, 1.9), cf(-2.2, 1.45, -0.2, 8, 30, -10), LEAF_DK)
		B:block(crop, v(1.7, 0.35, 1.7), cf(1.9, 1.45, -1.3, -10, 15, 8), LEAF)
		B:block(crop, v(1.6, 0.35, 1.6), cf(1.2, 1.4, 2.2, 6, 50, 10), LEAF_DK)

		-- curly tendril on top
		local tx, ty, tz = 0.4, CY + 1.5, LZ - 0.3
		for i = 0, 6 do
			local a = math.rad(i * 70)
			local r = 0.5 - i * 0.03
			B:block(crop, v(0.3, 0.3, 0.3), cf(tx + math.cos(a) * r, ty + i * 0.28, tz + math.sin(a) * r, 0, -i * 70, 0), VINE)
		end

		------------------------------------------------------------ gourds
		local shines = 0
		local function shine(c, x, y, z)
			shines += 1
			B:block(crop, v(0.28, 0.28, 0.28), c * CFrame.new(x, y, z), SHINE, { mat = "Neon", name = "Shine" .. shines })
		end
		local function stem(c, h)
			B:block(crop, v(0.3, 0.55, 0.3), c * CFrame.new(0, h / 2 + 0.2, 0) * ang(0, 0, 12), STEM)
			B:block(crop, v(0.5, 0.2, 0.2), c * CFrame.new(0.2, h / 2 + 0.45, 0), STEM)
		end
		-- round striped gourd: stepped round body + a # of thin rib stripes (like a ribbed pumpkin)
		local function roundGourd(c, s, body, stripe)
			local w, h = 1.5 * s, 1.1 * s
			B:block(crop, v(w, h, w), c, body)
			B:block(crop, v(w * 0.7, h + 0.3 * s, w * 0.7), c, body)
			for _, k in { -0.27, 0.27 } do
				B:block(crop, v(0.22 * s, h + 0.08, w + 0.08), c * CFrame.new(k * w, 0, 0), stripe)
				B:block(crop, v(w + 0.08, h + 0.08, 0.22 * s), c * CFrame.new(0, 0, k * w), stripe)
			end
			stem(c, h + 0.3 * s)
			shine(c, -0.36 * w, 0.42 * h, -0.5 * w - 0.03)
		end
		-- bottle gourd: bicolour bulb + neck
		local function bottleGourd(c, s, bulb, stripe, neck)
			local w, h = 1.4 * s, 1.0 * s
			B:block(crop, v(w, h, w), c, bulb)
			B:block(crop, v(w + 0.25 * s, h * 0.65, w * 0.7), c, bulb)
			B:block(crop, v(w * 0.7, h * 0.65, w + 0.25 * s), c, bulb)
			for _, x in { -0.4, 0.4 } do
				B:block(crop, v(0.24 * s, h + 0.08, w + 0.08), c * CFrame.new(x * w, 0, 0), stripe)
			end
			B:block(crop, v(w * 0.85, 0.5 * s, w * 0.85), c * CFrame.new(0, h / 2 + 0.2 * s, 0), neck)
			B:block(crop, v(0.75 * s, 0.75 * s, 0.75 * s), c * CFrame.new(0.08 * s, h / 2 + 0.75 * s, 0) * ang(0, 0, 8), neck)
			B:block(crop, v(0.6 * s, 0.4 * s, 0.6 * s), c * CFrame.new(0.2 * s, h / 2 + 1.25 * s, 0) * ang(0, 0, 16), stripe)
			stem(c * CFrame.new(0.28 * s, 1.3 * s, 0) * ang(0, 0, 16), h)
			shine(c, -0.32 * w, 0.4 * h, -0.5 * w)
		end
		-- crookneck: bulb + bent neck
		local function crookGourd(c, s, body, stripe)
			local w, h = 1.3 * s, 1.0 * s
			B:block(crop, v(w, h, w * 1.1), c, body)
			B:block(crop, v(w * 0.7, h * 0.65, w * 1.35), c, body)
			B:block(crop, v(w + 0.08, h + 0.08, 0.24 * s), c * CFrame.new(0, 0, 0.25 * w), stripe)
			B:block(crop, v(w + 0.08, h + 0.08, 0.24 * s), c * CFrame.new(0, 0, -0.25 * w), stripe)
			local n1 = c * CFrame.new(0, h / 2 + 0.3 * s, 0.1 * s) * ang(-25, 0, 0)
			B:block(crop, v(0.75 * s, 0.8 * s, 0.75 * s), n1, body)
			local n2 = n1 * CFrame.new(0, 0.55 * s, 0.25 * s) * ang(-40, 0, 0)
			B:block(crop, v(0.55 * s, 0.7 * s, 0.55 * s), n2, stripe)
			B:block(crop, v(0.25, 0.4, 0.25), n2 * CFrame.new(0, 0.5 * s, 0), STEM)
			shine(c, 0.3 * w, 0.4 * h, -0.55 * w)
		end

		-- front-left: big orange / cream round gourd on the mid tier
		local g1 = cf(-1.5, 1.25 + 0.7, -1.9, 0, 25, 0)
		roundGourd(g1, 1.25, ORANGE, GREEN_DK)
		runner(v(-0.3, 2.0, 0.0), v(-1.4, 2.6, -1.7))
		-- front-right: yellow bottle gourd with a green bulb
		local g2 = cf(2.1, 0.7 + 0.6, -1.7, 0, -20, -10)
		bottleGourd(g2, 1.15, GREEN, YELLOW, YELLOW)
		runner(v(0.4, 2.0, 0.0), v(2.0, 1.5, -1.5))
		-- back-left: green crookneck lying on the mound
		local g3 = cf(-2.3, 0.7 + 0.55, 1.6, 0, 200, 0)
		crookGourd(g3, 1.1, GREEN_DK, YELLOW)
		runner(v(-0.4, 2.0, 0.5), v(-2.1, 1.5, 1.5))
		-- small cream / orange gourd nestled in the leaves (front, up top)
		local g4 = cf(0.9, 3.6, -1.0, 0, 40, 8)
		roundGourd(g4, 0.85, CREAM, GREEN)
		------------------------------------------------------------ fx
		B:emitter(leafParts[6], "sparkle", { name = "GourdSparkle", color = { "#fff2a8", "#ffb347" }, rate = 2, size = 0.3 })
		B:light(leafParts[1], { color = "#ffc46b", brightness = 0.7, range = 8, name = "GourdLight" })
	end,
}
