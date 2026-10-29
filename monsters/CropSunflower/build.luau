--!nocheck
-- Sunflower (Crop #8, Cosmic) -- Grow a Garden style, kept simple:
-- a plain dirt plot, one thin tall green stem with three simple leaves and a
-- single big flower head facing forward: a round brown seed disc ringed by
-- sixteen yellow petal blocks (two shades, front/back ring). Two tiny glowing
-- seed dots and a gentle sparkle are the only bling.
-- Static prop: no motion.luau.
return {
	DisplayName = "Sunflower",
	Rarity = "Cosmic",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local DIRT, DIRT_DK = "#7b4a28", "#5e381d"
		local STEM, LEAF = "#2a9433", "#3fbf3a"
		local PETAL, PETAL_DK = "#ffd21f", "#f5a20f"
		local DISC, DISC_DK = "#7a4419", "#4e2a0e"
		local GLOW = "#ffe066"
		local TOP = 0.55

		-- plain dirt plot
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(5, 0.4, 5), cf(0, 0.2, 0), DIRT_DK, S)
		B:block(soil, v(4.5, 0.15, 4.5), cf(0, 0.475, 0), DIRT, S)

		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		-- thin stem, leaning a touch forward at the top into the back of the head
		local HY = TOP + 5.5
		B:block(crop, v(0.6, 4.6, 0.6), cf(0, TOP + 2.3, 0), STEM)
		B:beam(crop, v(0, TOP + 4.5, 0), v(0, HY, 0.1), 0.6, 0.6, STEM)

		-- simple leaves: short stalk + broad blade + tip, drooping outward
		local function leaf(y, yaw, len)
			local F = cf(0, y, 0) * ang(0, yaw, 0) * ang(-14, 0, 0)
			B:block(crop, v(0.3, 0.25, 0.7), F * CFrame.new(0, 0, -0.5), STEM)
			B:block(crop, v(1.4, 0.24, len), F * CFrame.new(0, 0, -0.75 - len / 2), LEAF)
			B:block(crop, v(0.7, 0.24, 0.6), F * CFrame.new(0, 0, -0.75 - len - 0.25), LEAF)
		end
		leaf(TOP + 1.5, -90, 1.8)
		leaf(TOP + 2.6, 90, 1.9)
		leaf(TOP + 3.6, -150, 1.5)

		-- flower head, facing -Z and tipped up a little
		local H = cf(0, HY, -0.25) * ang(12, 0, 0)
		local function hp(x, y, z, sx, sy, sz, col, opts)
			return B:block(crop, v(sx, sy, sz), H * CFrame.new(x, y, z), col, opts)
		end
		hp(0, 0, 0.45, 2.2, 1.4, 0.4, STEM) -- green back
		hp(0, 0, 0.45, 1.4, 2.2, 0.4, STEM)
		hp(0, 0, 0, 3.0, 2.0, 0.55, DISC) -- round seed disc
		hp(0, 0, 0, 2.0, 3.0, 0.55, DISC)
		hp(0, 0, -0.1, 1.5, 1.5, 0.5, DISC_DK) -- darker centre
		local c = hp(-0.35, 0.35, -0.38, 0.3, 0.3, 0.1, GLOW, { mat = "Neon", name = "SeedGlow" })
		hp(0.45, -0.3, -0.38, 0.25, 0.25, 0.1, GLOW, { mat = "Neon" })
		B:emitter(c, "sparkle", { name = "Sparkle", color = "#fff3a8", rate = 2, size = 0.3 })
		-- 16 petals: 8 bright in front, 8 deeper gold just behind, offset
		for i = 0, 15 do
			local front = i % 2 == 0
			local F = H * ang(0, 0, i * 22.5) * CFrame.new(0, 2.0, front and 0.02 or 0.2)
			B:block(crop, v(front and 0.95 or 0.85, 1.5, 0.3), F, front and PETAL or PETAL_DK)
		end
	end,
}
