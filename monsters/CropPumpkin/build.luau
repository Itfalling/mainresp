--!nocheck
-- Pumpkin (Crop #5, Legendary) -- Grow a Garden style, kept simple:
-- a plain dirt plot with one real-looking pumpkin: wide and squat (about
-- 1.6x wider than tall), deep orange, eight bulging ribs with darker grooves,
-- a dip at the top where a thick short stem sits, and a short vine with two
-- big simple leaves. Static prop: no motion.luau.
return {
	DisplayName = "Pumpkin",
	Rarity = "Legendary",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local DIRT, DIRT_DK = "#7b4a28", "#5e381d"
		local OR, OR_DK, OR_LT = "#ff8216", "#d85a0a", "#ff9d3c"
		local STEM = "#6f7d2a"
		local VINE = "#3e9a34"
		local LEAF, LEAF_DK = "#46b83e", "#2f8f33"

		-- plain dirt plot
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(6.5, 0.4, 6.5), cf(0, 0.2, 0), DIRT_DK, S)
		B:block(soil, v(6, 0.15, 6), cf(0, 0.475, 0), DIRT, S)

		local crop = B:bone("Crop", "Root", v(0, 0.55, 0))

		-- pumpkin core (shows as the darker grooves between the ribs)
		local CY = 1.85
		B:block(crop, v(3.6, 2.1, 2.2), cf(0, CY + 0.05, 0), OR_DK)
		B:block(crop, v(2.2, 2.1, 3.6), cf(0, CY + 0.05, 0), OR_DK)
		B:block(crop, v(3.0, 2.1, 3.0), cf(0, CY + 0.05, 0), OR_DK)

		-- eight bulging ribs, each rounded off at top and bottom
		for i = 0, 7 do
			local f = CFrame.new(0, CY, 0) * CFrame.Angles(0, rad(i * 45), 0)
			B:block(crop, v(1.3, 1.2, 1.0), f * CFrame.new(0, 0.05, -1.65), OR)
			B:block(crop, v(1.15, 0.5, 1.0), f * CFrame.new(0, 0.85, -1.4), OR)
			B:block(crop, v(0.95, 0.3, 1.0), f * CFrame.new(0, 1.2, -1.05), OR_LT)
			B:block(crop, v(1.15, 0.6, 1.0), f * CFrame.new(0, -0.75, -1.4), OR)
		end

		-- thick short stem sitting in the top dip, tip bent over
		B:block(crop, v(0.65, 0.8, 0.65), cf(0, 3.35, 0), STEM)
		B:block(crop, v(0.5, 0.4, 0.75), cf(0, 3.65, -0.3) * CFrame.Angles(rad(-20), 0, 0), STEM)

		-- short vine from the base out to two big simple leaves
		B:beam(crop, v(-1.6, 0.72, -0.5), v(-2.5, 0.72, -1.5), 0.3, 0.3, VINE)
		B:beam(crop, v(1.6, 0.72, 0.6), v(2.3, 0.72, 1.5), 0.3, 0.3, VINE)
		local function leaf(x, y, z, yaw, tilt)
			local f = CFrame.new(x, y, z) * CFrame.Angles(0, rad(yaw), 0) * CFrame.Angles(rad(tilt), 0, 0)
			B:block(crop, v(2.2, 0.2, 1.5), f, LEAF)
			B:block(crop, v(1.5, 0.2, 2.2), f * CFrame.new(0, -0.05, 0), LEAF_DK)
		end
		leaf(-2.6, 0.95, -1.7, 40, -14)
		leaf(2.2, 1.2, 1.6, -30, -30)
	end,
}
