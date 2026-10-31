--!nocheck
-- Sandstone Rocks (Sandy Savanna filler, v2).
-- A cluster of three layered sandstone rocks (big, medium, small) on a low
-- pixel-round sand patch. Each rock is built from stacked pixel-round tiers
-- (a box plus the same box turned 45 degrees) that step in toward the top:
-- a dark foot, a lower body, a pale sandstone strata line, a set-back upper
-- body and a light cap with a sun-bleached highlight chip, plus a dark
-- zig-zag crack and a chipped-off side chunk. Rubble, pebbles and two dry grass tufts ground it.
-- Lightweight scenery meant to be copy-pasted many times: anchored,
-- weld-free, no scripts or effects.
return {
	DisplayName = "Sandstone Rocks",
	Rarity = "Filler",
	Filler = true,
	Element = "Sandy Savanna",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		-- palette (Sandy Savanna crops: SandDateCactus / SandPricklyPear)
		local SAND_DK, SAND_DK2, SAND, SAND_LT, SAND_TOP = "#c48a45", "#b77d3c", "#d9a95c", "#e8c27a", "#f0d08e"
		-- rocks use the redder sandstone of the savanna decorations so they
		-- stand out from the sand (DecorSandCactus)
		local ROCK, ROCK_DK, ROCK_LT = "#c9774a", "#a9573a", "#e0a06a"
		local CRACK = "#7a3f2a"
		local GRASS, GRASS_DK, GRASS_LT = "#d9b84a", "#b8963a", "#f0d872"
		local PEBBLE, PEBBLE_DK = "#bfae94", "#968670"

		------------------------------------------------------------ footing
		B:block(R, v(5.6, 0.2, 3.4), cf(0, 0.1, 0.1), SAND_DK)
		B:block(R, v(3.6, 0.19, 4.6), cf(0, 0.095, 0.1), SAND_DK)
		B:block(R, v(4.4, 0.18, 4.0), cf(0, 0.09, 0.1, 0, 45, 0), SAND_DK2)
		B:block(R, v(2.6, 0.14, 1.5), cf(0.2, 0.25, 1.2, 0, 10, 0), SAND)
		B:block(R, v(1.4, 0.12, 1.0), cf(-1.6, 0.24, -1.2, 0, -25, 0), SAND_LT)
		B:block(R, v(0.5, 0.08, 0.4), cf(-1.9, 0.3, 0.3, 0, 30, 0), SAND_TOP)

		------------------------------------------------------------ rocks
		-- c: rock frame (base on ground), s: scale, hf: height factor,
		-- strata: number of pale lines, crack side (+1/-1/0), chip?
		local function rock(c, s, hf, strata, crack, chip)
			local h1 = 0.4 * s
			local hA, hB = 0.6 * s * hf, 0.45 * s * hf
			local h3 = 0.35 * s
			local w, d = 1.6 * s, 1.25 * s
			-- dark foot
			B:block(R, v(w * 1.05, h1, d * 1.05), c * CFrame.new(0, h1 / 2, 0), ROCK_DK)
			B:block(R, v(w * 0.85, h1 + 0.02, d * 0.95), c * CFrame.new(0, h1 / 2, 0) * ang(0, 45, 0), ROCK_DK)
			-- lower body
			local yA = h1 + hA / 2
			B:block(R, v(w * 0.95, hA, d * 0.9), c * CFrame.new(0, yA, 0), ROCK)
			B:block(R, v(w * 0.78, hA - 0.02, d * 0.85), c * CFrame.new(0, yA, 0) * ang(0, 45, 0), ROCK)
			-- pale strata line(s)
			for i = 1, strata do
				local y = h1 + hA * (i == 1 and 1 or 0.45)
				B:block(R, v(w * (i == 1 and 0.9 or 0.98), 0.14, d * (i == 1 and 0.86 or 0.93)), c * CFrame.new(0, y, 0), SAND_LT)
			end
			-- upper body, set back a little and stepped in
			local yB = h1 + hA + hB / 2
			local up = c * CFrame.new(0.08 * s, yB, 0.06 * s) * ang(0, 8, 0)
			B:block(R, v(w * 0.78, hB, d * 0.72), up, ROCK)
			B:block(R, v(w * 0.62, hB - 0.02, d * 0.66), up * ang(0, 45, 0), ROCK_DK)
			-- light cap + sun-bleached chip
			local y3 = h1 + hA + hB + h3 / 2
			local cap = c * CFrame.new(0.12 * s, y3, 0.02 * s) * ang(0, 18, 0)
			B:block(R, v(w * 0.58, h3, d * 0.55), cap, ROCK_LT)
			B:block(R, v(w * 0.45, h3 - 0.02, d * 0.45), cap * ang(0, 45, 0), ROCK_LT)
			B:block(R, v(w * 0.28, 0.12, d * 0.28), cap * CFrame.new(-0.08 * s, h3 / 2 + 0.04, 0.05 * s) * ang(0, 30, 0), SAND_TOP)
			-- dark crack zig-zagging down the front face
			if crack ~= 0 then
				local x = crack * w * 0.2
				B:block(R, v(0.13, hA * 0.6, 0.1), c * CFrame.new(x, yA + hA * 0.1, -d * 0.455) * ang(0, 0, 10 * crack), CRACK)
				B:block(R, v(0.13, hA * 0.35, 0.1), c * CFrame.new(x + crack * 0.1, yA - hA * 0.3, -d * 0.455) * ang(0, 0, -16 * crack), CRACK)
			end
			-- chipped side chunk
			if chip then
				B:block(R, v(0.55 * s, 0.6 * s, 0.6 * s), c * CFrame.new(w * 0.52, h1 + 0.2 * s, d * 0.2) * ang(0, 20, 8), ROCK_DK)
				B:block(R, v(0.42 * s, 0.18 * s, 0.46 * s), c * CFrame.new(w * 0.52, h1 + 0.55 * s, d * 0.2) * ang(0, 20, 8), ROCK_LT)
			end
		end
		rock(CFrame.new(-0.6, 0.15, 0.25) * ang(0, 18, 3), 1.45, 1.3, 2, 1, true)
		rock(CFrame.new(1.45, 0.15, -0.55) * ang(0, -30, -4), 1.0, 1.0, 1, -1, false)
		rock(CFrame.new(0.85, 0.15, 1.35) * ang(0, 50, 5), 0.65, 0.9, 1, 0, false)

		------------------------------------------------------------ rubble
		B:block(R, v(0.55, 0.4, 0.5), cf(-2.3, 0.3, -0.9, 0, 35, 0), ROCK)
		B:block(R, v(0.35, 0.18, 0.3), cf(-2.3, 0.56, -0.9, 0, 60, 0), ROCK_LT)
		B:block(R, v(0.4, 0.3, 0.35), cf(2.35, 0.25, 0.6, 0, 15, 0), PEBBLE)
		B:block(R, v(0.35, 0.25, 0.3), cf(-0.4, 0.25, -1.55, 0, 50, 0), PEBBLE_DK)
		B:block(R, v(0.3, 0.2, 0.3), cf(2.0, 0.22, 1.3, 0, 20, 0), ROCK_DK)

		------------------------------------------------------------ tufts
		local function tuft(x, z, yaw, s)
			local base = CFrame.new(x, 0.2, z) * ang(0, yaw, 0)
			B:block(R, v(0.26, 1.1 * s, 0.26), base * CFrame.new(0, 0.5 * s, 0), GRASS)
			B:block(R, v(0.24, 0.9 * s, 0.24), base * CFrame.new(0.24, 0.38 * s, 0) * ang(0, 0, -25), GRASS_LT)
			B:block(R, v(0.24, 0.8 * s, 0.24), base * CFrame.new(-0.23, 0.34 * s, 0.05) * ang(0, 0, 25), GRASS_DK)
		end
		tuft(-2.0, 1.0, 20, 1.0)
		tuft(2.2, -1.3, 70, 0.8)
	end,
}
