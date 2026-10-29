--!nocheck
-- Starfruit Tree (Crop #10, Apex) -- Grow a Garden style, kept simple:
-- the same simple tree language as the Apple Tree, made magical: a plain dirt
-- plot, a SLIM pale trunk with three thin branches, five big mint/teal leaf
-- clumps (stepped plus-shaped slabs) and eight golden plus-shaped star fruit
-- dangling on short stalks. Three tiny neon gold star hearts, one sparkle
-- emitter and one soft gold light are the only bling.
-- Static prop: no motion.luau.
return {
	DisplayName = "Starfruit Tree",
	Rarity = "Apex",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local DIRT, DIRT_DK = "#7b4a28", "#5e381d"
		local BARK, BARK_DK = "#efe2c6", "#cdb994"
		local LEAF_LT, LEAF, LEAF_DK = "#8ff2d6", "#3fd3b0", "#22a487"
		local GOLD, GOLD_DK, STALK = "#ffd62e", "#ffbb1c", "#5e8a3a"
		local GLOW = "#fff08a"
		local TOP = 0.55

		-- plain dirt plot
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(6.5, 0.4, 6.5), cf(0, 0.2, 0), DIRT_DK, S)
		B:block(soil, v(6, 0.15, 6), cf(0, 0.475, 0), DIRT, S)

		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		-- slim pale trunk with a small root flare, three thin branches
		B:block(crop, v(1.8, 0.5, 1.8), cf(0, TOP + 0.25, 0), BARK_DK)
		B:block(crop, v(1.2, 8.6, 1.2), cf(0, TOP + 4.3, 0), BARK)
		local function branch(y, x, by, z)
			B:beam(crop, v(0, TOP + y, 0), v(x, TOP + by, z), 0.5, 0.5, BARK)
		end
		branch(4.8, -2.6, 7.1, 0.3)
		branch(5.4, 2.6, 7.4, -0.3)
		branch(5.8, 0.3, 7.6, 2.3)

		-- big simple leaf clump: a stepped round blob (dark base, plus-shaped middle, light cap)
		local function clump(x, y, z, w, h)
			y = TOP + y
			B:block(crop, v(w - 1.4, h * 0.25, w - 1.4), cf(x, y - h * 0.375, z), LEAF_DK)
			B:block(crop, v(w, h * 0.5, w - 1.2), cf(x, y, z), LEAF)
			B:block(crop, v(w - 1.2, h * 0.5, w), cf(x, y, z), LEAF)
			B:block(crop, v(w - 1.4, h * 0.25, w - 1.4), cf(x, y + h * 0.375, z), LEAF_LT)
		end
		clump(0, 9.9, 0, 5.4, 3.6)
		clump(-3.0, 7.6, 0.3, 4.2, 2.8)
		clump(3.0, 7.9, -0.3, 4.2, 2.8)
		clump(0.3, 8.0, 2.6, 3.8, 2.6)
		clump(-0.6, 7.3, -1.9, 3.0, 2.0)

		-- golden plus-shaped star fruit dangling on short stalks
		local n = 0
		local function star(x, y, z, yaw, roll, glow)
			y = TOP + y
			B:block(crop, v(0.18, 0.6, 0.18), cf(x, y + 1.15, z), STALK)
			local F = cf(x, y, z) * ang(0, yaw, 0) * ang(0, 0, roll)
			B:block(crop, v(1.9, 0.55, 0.5), F, GOLD)
			B:block(crop, v(0.55, 1.9, 0.5), F, GOLD)
			B:block(crop, v(0.95, 0.95, 0.8), F, GOLD_DK)
			if glow then
				n += 1
				return B:block(crop, v(0.3, 0.3, 0.1), F * CFrame.new(0, 0, -0.44), GLOW, { mat = "Neon", name = "StarGlow" .. n })
			end
		end
		local g1 = star(-1.3, 7.6, -3.0, 0, 12, true)
		star(1.4, 8.6, -2.95, 0, -10)
		star(-2.9, 5.8, -1.9, 15, 8)
		star(-5.2, 6.7, 0.1, 80, -12)
		star(2.6, 6.0, -2.5, -15, -8, true)
		star(5.2, 7.0, -0.5, -80, 10)
		star(1.5, 6.1, 4.5, 180, 10)
		star(-2.3, 9.0, 2.9, 160, -8, true)
		B:emitter(g1, "sparkle", { name = "Sparkle", color = "#fff3a8", rate = 3, size = 0.3 })
		B:light(g1, { color = "#ffd76a", brightness = 0.5, range = 8, name = "StarLight" })
	end,
}
