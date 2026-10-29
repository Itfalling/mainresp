--!nocheck
-- Apple Tree (Crop #9, Divine) -- Grow a Garden style, kept simple:
-- a plain dirt plot, a SLIM brown trunk with three thin branches, four big
-- simple leaf clumps (stepped plus-shaped slabs, three greens) and eight round
-- red apples hanging on the outside. Two tiny glowing shine dots and a gentle
-- sparkle are the only bling.
-- Static prop: no motion.luau.
return {
	DisplayName = "Apple Tree",
	Rarity = "Divine",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local DIRT, DIRT_DK = "#7b4a28", "#5e381d"
		local BARK, BARK_DK = "#8a5a2b", "#6b4220"
		local LEAF_LT, LEAF, LEAF_DK = "#5fd23f", "#3fb43a", "#2a8f33"
		local RED, RED_DK, STALK = "#e8242c", "#b8141c", "#5a3a1a"
		local SHINE = "#ffd6d6"
		local TOP = 0.55

		-- plain dirt plot
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(6, 0.4, 6), cf(0, 0.2, 0), DIRT_DK, S)
		B:block(soil, v(5.5, 0.15, 5.5), cf(0, 0.475, 0), DIRT, S)

		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		-- slim trunk with a small root flare, three thin branches
		B:block(crop, v(1.8, 0.5, 1.8), cf(0, TOP + 0.25, 0), BARK_DK)
		B:block(crop, v(1.2, 7.6, 1.2), cf(0, TOP + 3.8, 0), BARK)
		local function branch(y, x, by, z)
			B:beam(crop, v(0, TOP + y, 0), v(x, TOP + by, z), 0.5, 0.5, BARK)
		end
		branch(4.0, -2.4, 6.1, 0.3)
		branch(4.6, 2.4, 6.4, -0.3)
		branch(5.0, 0.3, 6.6, 2.2)

		-- big simple leaf clump: a stepped round blob (dark base, plus-shaped middle, light cap)
		local function clump(x, y, z, w, h)
			y = TOP + y
			B:block(crop, v(w - 1.4, h * 0.25, w - 1.4), cf(x, y - h * 0.375, z), LEAF_DK)
			B:block(crop, v(w, h * 0.5, w - 1.2), cf(x, y, z), LEAF)
			B:block(crop, v(w - 1.2, h * 0.5, w), cf(x, y, z), LEAF)
			B:block(crop, v(w - 1.4, h * 0.25, w - 1.4), cf(x, y + h * 0.375, z), LEAF_LT)
		end
		clump(0, 8.8, 0, 5.2, 3.6)
		clump(-2.8, 6.6, 0.3, 4.0, 2.8)
		clump(2.8, 6.9, -0.3, 4.0, 2.8)
		clump(0.3, 7.0, 2.4, 3.8, 2.4)

		-- round red apples hanging on the outside
		local n = 0
		local function apple(x, y, z, shine)
			y = TOP + y
			B:block(crop, v(1.1, 0.9, 1.1), cf(x, y, z), RED)
			B:block(crop, v(0.7, 1.2, 0.7), cf(x, y - 0.05, z), RED_DK)
			B:block(crop, v(0.16, 0.4, 0.16), cf(x, y + 0.7, z), STALK)
			if shine then
				n += 1
				return B:block(crop, v(0.22, 0.22, 0.1), cf(x - 0.25, y + 0.15, z - 0.56), SHINE, { mat = "Neon", name = "Shine" .. n })
			end
		end
		local s1 = apple(-1.0, 8.0, -2.55, true)
		apple(1.3, 9.1, -2.55)
		apple(0.6, 7.2, -1.9)
		apple(-3.0, 6.1, -1.75)
		apple(-4.85, 6.8, 0.2)
		apple(2.3, 6.3, -2.35, true)
		apple(4.85, 7.1, -0.6)
		apple(1.4, 6.0, 4.4)
		apple(-2.2, 8.4, 2.55)
		B:emitter(s1, "sparkle", { name = "Sparkle", color = "#fff3c4", rate = 2, size = 0.3 })
	end,
}
