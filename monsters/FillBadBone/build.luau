--!nocheck
-- Scattered Bones (Bramble Badlands filler).
-- Two chunky cartoon "dog-bone" femurs lying crossed on the ground with a
-- smaller third bone resting across them and one charcoal pebble. Same cream
-- bone palette as the Bone Pile decoration. Sits straight on Y=0.
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Scattered Bones",
	Rarity = "Filler",
	Filler = true,
	Element = "Bramble Badlands",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"

		local BONE_LT, BONE, BONE_DK = "#fbf1d8", "#efe0bc", "#d8c398"
		local RK_DK, RK_LT = "#3a3236", "#625758"

		-- cartoon femur along local Z of frame F: shaft, top highlight, two
		-- knobs at each end (one lit, one shaded)
		local function femur(F, len, t)
			local k = t * 1.2
			B:block(R, v(t, t, len), F, BONE)
			B:block(R, v(t * 1.04, t * 0.36, len * 0.62), F * CFrame.new(0, t * 0.34, 0), BONE_LT)
			for sz = -1, 1, 2 do
				for sx = -1, 1, 2 do
					B:block(R, v(k, k, k), F * CFrame.new(sx * k * 0.4, 0, sz * (len / 2 + k * 0.12)), (sx > 0) and BONE_LT or BONE_DK)
				end
			end
		end

		-- two big femurs lying on the ground (knobs touch Y=0)
		femur(cf(-0.35, 0.36, 0.3, 0, 62, 0), 3.8, 0.6)
		femur(cf(0.75, 0.3, -0.4, 0, -28, 0), 3.0, 0.5)
		-- a smaller bone resting across both
		local F = P.aim(v(-1.3, 0.45, -1.15), v(0.95, 1.15, 0.85))
		femur(F, 2.2, 0.42)

		-- one charcoal pebble
		B:block(R, v(0.7, 0.45, 0.6), cf(1.75, 0.22, 0.95, 0, 25, 0), RK_DK)
		B:block(R, v(0.4, 0.2, 0.35), cf(1.7, 0.52, 0.95, 0, 40, 0), RK_LT)
	end,
}
