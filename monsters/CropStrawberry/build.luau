--!nocheck
-- Strawberry (Crop #7, Secret) -- Grow a Garden style, kept simple:
-- a plain dirt plot with a low leafy plant (four 3-lobed leaf clumps on thin
-- stalks), five red strawberries hanging round the edge (stepped tapered
-- berries, yellow seed dots, green caps) and one tiny white flower on top
-- with a small glowing centre and a gentle sparkle.
-- Static prop: no motion.luau.
return {
	DisplayName = "Strawberry",
	Rarity = "Secret",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local DIRT, DIRT_DK = "#7b4a28", "#5e381d"
		local LEAF, LEAF_DK = "#35b03c", "#21852d"
		local RED, RED_DK, SEED = "#f0242f", "#c4141f", "#ffe14d"
		local WHITE, GOLD = "#ffffff", "#ffd84a"
		local TOP = 0.55

		-- plain dirt plot
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(6.5, 0.4, 6.5), cf(0, 0.2, 0), DIRT_DK, S)
		B:block(soil, v(6, 0.15, 6), cf(0, 0.475, 0), DIRT, S)

		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		local function out(a, r, y) -- point at angle a (deg), radius r, height y
			local ra = math.rad(a)
			return v(-math.sin(ra) * r, y, -math.cos(ra) * r)
		end

		-- 3-lobed leaf clumps on thin stalks
		local function clump(a, r, y)
			local hub = out(a, r, y)
			B:beam(crop, v(0, TOP, 0), hub, 0.25, 0.25, LEAF_DK)
			for _, d in { -55, 0, 55 } do
				local F = CFrame.new(hub) * ang(0, a + d, 0) * ang(24, 0, 0)
				local len = d == 0 and 2.0 or 1.7
				B:block(crop, v(1.45, 0.22, len), F * CFrame.new(0, 0, -len / 2 + 0.1), LEAF)
			end
		end
		clump(45, 0.8, TOP + 1.9)
		clump(135, 0.8, TOP + 1.7)
		clump(225, 0.8, TOP + 2.0)
		clump(315, 0.8, TOP + 1.8)
		B:block(crop, v(1.6, 1.0, 1.6), cf(0, TOP + 1.5, 0), LEAF_DK) -- leafy heart

		-- strawberries: wide top, tapered tip, green cap, seed dots facing out
		local function berry(a, r, yt)
			local p = out(a, r, yt)
			B:beam(crop, out(a, 0.8, TOP + 1.4), p + v(0, 0.2, 0), 0.2, 0.2, LEAF_DK)
			local F = CFrame.new(p) * ang(0, a, 0)
			B:block(crop, v(1.25, 0.65, 1.25), F * CFrame.new(0, -0.33, 0), RED)
			B:block(crop, v(0.9, 0.5, 0.9), F * CFrame.new(0, -0.9, 0), RED)
			B:block(crop, v(0.5, 0.35, 0.5), F * CFrame.new(0, -1.3, 0), RED_DK)
			B:block(crop, v(1.5, 0.16, 0.45), F * CFrame.new(0, 0.06, 0), LEAF) -- cap
			B:block(crop, v(0.45, 0.16, 1.5), F * CFrame.new(0, 0.07, 0), LEAF)
			B:block(crop, v(0.2, 0.2, 0.1), F * CFrame.new(-0.25, -0.4, -0.66), SEED)
			B:block(crop, v(0.2, 0.2, 0.1), F * CFrame.new(0.18, -0.95, -0.48), SEED)
		end
		berry(5, 2.4, TOP + 1.5)
		berry(75, 2.45, TOP + 1.5)
		berry(160, 2.4, TOP + 1.55)
		berry(230, 2.45, TOP + 1.5)
		berry(300, 2.4, TOP + 1.55)

		-- tiny white flower on top
		B:beam(crop, v(0, TOP + 1.9, 0), v(0.2, TOP + 2.95, -0.2), 0.18, 0.18, LEAF_DK)
		local FL = cf(0.2, TOP + 3.0, -0.2, 0, 45, 0)
		B:block(crop, v(1.1, 0.18, 0.4), FL, WHITE)
		B:block(crop, v(0.4, 0.18, 1.1), FL, WHITE)
		local c = B:block(crop, v(0.32, 0.12, 0.32), FL * CFrame.new(0, 0.12, 0), GOLD, { mat = "Neon", name = "FlowerGlow" })
		B:emitter(c, "sparkle", { name = "Sparkle", color = "#fff3a8", rate = 2, size = 0.25 })
	end,
}
