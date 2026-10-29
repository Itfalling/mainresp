--!nocheck
-- Corn (Crop #4, Epic) -- Grow a Garden style, kept simple:
-- a plain dirt plot, one thin tall green stalk with five long arching leaves,
-- two yellow cobs in light-green husks, and a small tassel on top.
-- Static prop: no motion.luau.
return {
	DisplayName = "Corn",
	Rarity = "Epic",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local DIRT, DIRT_DK = "#7b4a28", "#5e381d"
		local STALK = "#4caa38"
		local LEAF, LEAF_DK = "#5cc43f", "#3c9a34"
		local COB, COB_DK = "#ffd43a", "#f2b51c"
		local HUSK = "#a6dc68"
		local TASSEL = "#e2c35c"

		-- plain dirt plot
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(4.5, 0.4, 4.5), cf(0, 0.2, 0), DIRT_DK, S)
		B:block(soil, v(4, 0.15, 4), cf(0, 0.475, 0), DIRT, S)

		local crop = B:bone("Crop", "Root", v(0, 0.55, 0))
		local rad = math.rad

		-- thin tall stalk
		B:block(crop, v(0.55, 5.6, 0.55), cf(0, 3.3, 0), STALK)

		-- long leaves: rise out from the stalk, then arch over and droop
		local function leaf(h, yaw, len, col)
			local f = CFrame.new(0, h, 0) * CFrame.Angles(0, rad(yaw), 0) * CFrame.new(0, 0, -0.15)
			local segs = { { 68, len * 0.45, 1.1 }, { -45, len * 0.33, 0.95 }, { -45, len * 0.3, 0.65 } }
			for _, s in segs do
				f = f * CFrame.Angles(rad(s[1]), 0, 0)
				B:block(crop, v(s[3], 0.2, s[2] + 0.1), f * CFrame.new(0, 0, -s[2] / 2), col)
				f = f * CFrame.new(0, 0, -s[2])
			end
		end
		leaf(1.3, 20, 3.0, LEAF_DK)
		leaf(2.2, 160, 3.0, LEAF)
		leaf(3.3, 270, 2.8, LEAF_DK)
		leaf(4.3, 90, 2.6, LEAF)
		leaf(5.2, 210, 2.2, LEAF)

		-- two cobs leaning out from the stalk
		local function cob(h, yaw)
			local f = CFrame.new(0, h, 0) * CFrame.Angles(0, rad(yaw), 0) * CFrame.new(0, 0, -0.4)
				* CFrame.Angles(rad(-22), 0, 0)
			B:block(crop, v(1.0, 1.9, 0.7), f * CFrame.new(0, 1.15, 0), COB)
			B:block(crop, v(0.7, 1.9, 1.0), f * CFrame.new(0, 1.15, 0), COB_DK)
			B:block(crop, v(0.55, 0.3, 0.55), f * CFrame.new(0, 2.2, 0), COB)
			-- husk: a cup at the base and two leaves up the sides
			B:block(crop, v(1.15, 0.6, 1.15), f * CFrame.new(0, 0.25, 0), HUSK)
			B:block(crop, v(0.2, 1.1, 0.8), f * CFrame.new(0.55, 0.75, 0) * CFrame.Angles(0, 0, rad(10)), HUSK)
			B:block(crop, v(0.2, 1.1, 0.8), f * CFrame.new(-0.55, 0.75, 0) * CFrame.Angles(0, 0, rad(-10)), HUSK)
		end
		cob(2.4, 330)
		cob(3.4, 140)

		-- small tassel on top
		B:block(crop, v(0.2, 1.0, 0.2), cf(0, 6.5, 0), TASSEL)
		for i = 0, 2 do
			local f = CFrame.new(0, 6.05, 0) * CFrame.Angles(0, rad(i * 120 + 30), 0) * CFrame.Angles(rad(-35), 0, 0)
			B:block(crop, v(0.18, 0.8, 0.18), f * CFrame.new(0, 0.4, 0), TASSEL)
		end
	end,
}
