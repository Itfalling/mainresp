--!nocheck
-- Candy Corn Stalk (Scarecrow Stage plant #2, Uncommon).
-- A little clump of chunky corn stalks on a stepped, straw-strewn dirt mound.
-- Long stepped leaf blades arch out and droop, drying to straw-gold at the
-- tips, golden tassels crown each stalk, and the cobs are giant candy corns:
-- a yellow base, an orange middle and a white tip, peeking out of peeled
-- green husks. A few loose candy-corn kernels lie on the soil.
-- Static prop: no motion.luau.
return {
	DisplayName = "Candy Corn Stalk",
	Rarity = "Uncommon",
	Element = "Harvest",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette
		local DIRT_DK, DIRT, DIRT_LT = "#4a2a16", "#744526", "#93603a"
		local GRASS = "#6fbf3a"
		local HAY, HAY_DK = "#e8c45a", "#c99a35"
		local STALK_DK, STALK, STALK_LT = "#3f7a2a", "#56963a", "#7cb848"
		local LEAF_DK, LEAF, LEAF_TIP = "#3a8530", "#5aa83e", "#b5b444"
		local HUSK, HUSK_LT = "#7fae45", "#b9cf68"
		local TASSEL, TASSEL_DK = "#f0cc5a", "#c9962e"
		local CC_Y, CC_O, CC_W = "#ffc61f", "#ff7a14", "#ffffff"
		local SHINE = "#fffbe6"

		local seed = 202
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		------------------------------------------------------------ soil mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(6.8, 0.7, 4.8), cf(0, 0.35, 0), DIRT_DK, S)
		B:block(soil, v(4.8, 0.7, 6.8), cf(0, 0.35, 0), DIRT_DK, S)
		local edge = 10
		for i = 0, edge - 1 do
			local a = (i + 0.5) / edge * math.pi * 2
			local r = 3.25 + rnd(-0.15, 0.2)
			local h = 0.6 + rnd(0, 0.35)
			local col = (i % 3 == 0) and DIRT or DIRT_DK
			B:block(soil, v(rnd(1.3, 1.8), h, rnd(1.0, 1.4)), cf(math.cos(a) * r, h / 2, math.sin(a) * r, 0, -math.deg(a) + rnd(-12, 12), 0), col, S)
		end
		B:block(soil, v(4.6, 0.6, 3.4), cf(0, 0.95, 0), DIRT, S)
		B:block(soil, v(3.4, 0.6, 4.6), cf(0, 0.95, 0), DIRT, S)
		B:block(soil, v(2.6, 0.4, 2.6), cf(0, 1.4, 0, 0, 15, 0), DIRT_LT, S)
		-- grass tufts
		B:block(soil, v(0.35, 0.7, 0.35), cf(-3.5, 0.35, -1.5), GRASS, S)
		B:block(soil, v(0.3, 0.5, 0.3), cf(-3.2, 0.25, -1.95), GRASS, S)
		B:block(soil, v(0.35, 0.6, 0.35), cf(3.2, 0.3, 2.2), GRASS, S)
		-- straw bits
		for _, h in { { -2.3, 1.27, 1.5, 30 }, { 2.6, 0.72, -1.6, -55 }, { 1.3, 1.27, 1.9, 75 }, { -2.9, 0.72, -0.4, 10 } } do
			B:block(soil, v(1.4, 0.14, 0.18), cf(h[1], h[2] + 0.07, h[3], 0, h[4], 0), HAY, S)
			B:block(soil, v(1.0, 0.12, 0.16), cf(h[1] + 0.1, h[2] + 0.09, h[3] + 0.15, 0, h[4] + 25, 0), HAY_DK, S)
		end
		-- loose candy-corn kernels on the soil
		local function kernel(x, y, z, ry)
			local c = cf(x, y, z, 0, ry, 70)
			B:block(soil, v(0.5, 0.3, 0.5), c * CFrame.new(0, -0.2, 0), CC_Y, S)
			B:block(soil, v(0.4, 0.25, 0.4), c * CFrame.new(0, 0.07, 0), CC_O, S)
			B:block(soil, v(0.26, 0.2, 0.26), c * CFrame.new(0, 0.28, 0), CC_W, S)
		end
		kernel(-1.4, 1.5, -1.9, 20)
		kernel(2.3, 0.95, -2.4, -40)

		------------------------------------------------------------ stalks
		local crop = B:bone("Crop", "Root", v(0, 1.6, 0))
		local leafParts = {}

		-- stalk: stacked segments with darker node rings
		local function stalk(x, z, h, w, lean)
			local top
			local n = math.floor(h / 1.5 + 0.5)
			local segH = h / n
			for i = 0, n - 1 do
				local y = 1.5 + i * segH
				local ox = lean * (i * segH) / h
				B:block(crop, v(w, segH + 0.05, w), cf(x + ox, y + segH / 2, z, 0, i * 9, 0), (i % 2 == 0) and STALK or STALK_LT)
				if i > 0 then
					B:block(crop, v(w + 0.2, 0.25, w + 0.2), cf(x + ox, y, z, 0, i * 9 + 45, 0), STALK_DK)
				end
			end
			top = v(x + lean, 1.5 + h, z)
			return top
		end

		-- leaf blade: chain of flat segments that arches out and droops
		local bladeN = 0
		local function blade(p, yaw, pitch, segs, len, w)
			bladeN += 1
			local roll = (bladeN % 2 == 0) and 55 or -55
			local c = CFrame.new(p) * ang(0, yaw, 0) * ang(pitch, 0, 0)
			for i = 1, segs do
				local col = (i == segs) and LEAF_TIP or ((i % 2 == 1) and LEAF or LEAF_DK)
				local ww = w * (1 - (i - 1) * 0.2)
				local part = B:block(crop, v(ww, 0.35, len + 0.1), c * CFrame.new(0, 0, -len / 2) * ang(0, 0, roll), col)
				table.insert(leafParts, part)
				c = c * CFrame.new(0, 0, -len) * ang(-22, 0, 0)
			end
		end

		-- tassel: golden stepped spikes on top
		local function tassel(p, s)
			B:block(crop, v(0.5 * s, 0.9 * s, 0.5 * s), CFrame.new(p + v(0, 0.35 * s, 0)), TASSEL)
			B:block(crop, v(0.3 * s, 0.7 * s, 0.3 * s), CFrame.new(p + v(0, 1.1 * s, 0)) * ang(0, 45, 0), TASSEL_DK)
			for i = 0, 4 do
				local yaw = i * 72 + 15
				local c = CFrame.new(p + v(0, 0.45 * s, 0)) * ang(0, yaw, 0) * ang(35, 0, 0)
				B:block(crop, v(0.32, 0.32, 1.1 * s), c * CFrame.new(0, 0, -0.55 * s), (i % 2 == 0) and TASSEL or TASSEL_DK)
			end
		end

		-- candy-corn cob, local +Y along the cob, base at c
		local shines = 0
		local function cob(p, yaw, tilt, s)
			local c = CFrame.new(p) * ang(0, yaw, 0) * ang(-tilt, 0, 0) * CFrame.new(0, 0, -0.35)
			-- husk collar + peeled husk leaves
			B:block(crop, v(1.0 * s, 0.5 * s, 1.0 * s), c * CFrame.new(0, 0.2 * s, 0), HUSK)
			B:block(crop, v(0.8 * s, 1.1 * s, 0.22), c * CFrame.new(0, 0.6 * s, 0.66 * s) * ang(-22, 0, 0), HUSK)
			B:block(crop, v(0.22, 1.0 * s, 0.75 * s), c * CFrame.new(0.7 * s, 0.55 * s, 0) * ang(0, 0, -24), HUSK_LT)
			B:block(crop, v(0.22, 0.9 * s, 0.7 * s), c * CFrame.new(-0.7 * s, 0.5 * s, 0) * ang(0, 0, 24), HUSK)
			-- candy corn: yellow base, orange middle, white tip (stepped taper)
			B:block(crop, v(1.2 * s, 1.0 * s, 1.2 * s), c * CFrame.new(0, 0.85 * s, 0), CC_Y)
			B:block(crop, v(1.0 * s, 0.9 * s, 1.0 * s), c * CFrame.new(0, 1.75 * s, 0), CC_O)
			B:block(crop, v(0.75 * s, 0.7 * s, 0.75 * s), c * CFrame.new(0, 2.5 * s, 0), CC_W)
			B:block(crop, v(0.42 * s, 0.4 * s, 0.42 * s), c * CFrame.new(0, 3.0 * s, 0), CC_W)
			shines += 1
			B:block(crop, v(0.24, 0.24, 0.24), c * CFrame.new(-0.3 * s, 2.6 * s, -0.36 * s), SHINE, { mat = "Neon", name = "Shine" .. shines })
		end

		-- main stalk
		local mainTop = stalk(0, 0.3, 6.3, 1.3, 0.15)
		tassel(mainTop, 1.3)
		blade(v(0, 3.0, 0.3), 200, 38, 3, 1.7, 1.5)
		blade(v(0, 4.2, 0.3), 80, 40, 3, 1.6, 1.45)
		blade(v(0, 5.4, 0.3), 300, 42, 3, 1.5, 1.35)
		blade(v(0.1, 6.6, 0.3), 150, 48, 3, 1.4, 1.25)
		blade(v(0.15, 7.6, 0.3), 30, 55, 2, 1.3, 1.1)
		cob(v(0.4, 3.6, -0.2), 330, 30, 1.3)
		cob(v(-0.5, 5.0, -0.1), 35, 34, 1.15)
		-- left side stalk
		local lTop = stalk(-1.8, 1.0, 4.2, 1.0, -0.3)
		tassel(lTop, 1.0)
		blade(v(-1.8, 2.7, 1.0), 110, 38, 3, 1.4, 1.2)
		blade(v(-1.9, 4.1, 1.0), 240, 45, 3, 1.3, 1.1)
		cob(v(-2.1, 3.3, 0.6), 65, 40, 1.0)
		-- right side stalk
		local rTop = stalk(1.7, 1.2, 5.0, 1.05, 0.3)
		tassel(rTop, 1.1)
		blade(v(1.7, 2.9, 1.2), 285, 38, 3, 1.4, 1.2)
		blade(v(1.8, 4.6, 1.2), 175, 45, 3, 1.3, 1.1)
		cob(v(2.0, 3.8, 0.8), 295, 38, 1.05)

		------------------------------------------------------------ fx
		B:emitter(leafParts[1], "sparkle", { name = "CandySparkle", color = { "#fff6d6", "#ffb347" }, rate = 2.5, size = 0.3 })
		B:light(leafParts[4], { color = "#ffc46b", brightness = 0.8, range = 9, name = "CandyLight" })
	end,
}
