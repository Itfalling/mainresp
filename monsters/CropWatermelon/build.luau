--!nocheck
-- Watermelon (Crop #6, Mythic) -- Grow a Garden style, kept simple:
-- a plain dirt plot with one big WHOLE watermelon (an elongated stepped oval,
-- dark green with light-green stripes running end to end), a small whole
-- melon beside it, joined by a thin vine with three big simple leaves.
-- Static prop: no motion.luau.
return {
	DisplayName = "Watermelon",
	Rarity = "Mythic",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local DIRT, DIRT_DK = "#7b4a28", "#5e381d"
		local MEL, MEL_DK, STRIPE = "#1f8a34", "#17692a", "#8fdc4e"
		local STEM = "#7a6a2a"
		local LEAF, LEAF_DK = "#3fbf3a", "#25912e"
		local TOP = 0.55

		-- plain dirt plot
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(8.5, 0.4, 6.5), cf(0, 0.2, 0), DIRT_DK, S)
		B:block(soil, v(8, 0.15, 6), cf(0, 0.475, 0), DIRT, S)

		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		-- a whole watermelon lying on its side, long axis = local X.
		-- F sits on the soil top; s scales it.
		local function melon(F, s)
			local function p(x, y, z, sx, sy, sz, col)
				return B:block(crop, v(sx * s, sy * s, sz * s), F * CFrame.new(x * s, y * s, z * s), col)
			end
			-- body: horizontal slabs stepped in width (round cross-section), each one a
			-- flush colour so the stripes are wide bands following the curve end to end.
			-- {y0, y1, width (Z), length (X), colour}
			local LAYERS = {
				{ 0.0, 0.5, 2.4, 5.0, MEL_DK },
				{ 0.5, 0.9, 3.2, 6.0, MEL },
				{ 0.9, 1.4, 3.5, 6.0, STRIPE }, -- lower side stripe
				{ 1.4, 2.0, 3.7, 6.0, MEL }, -- widest belt
				{ 2.0, 2.5, 3.5, 6.0, STRIPE }, -- upper side stripe
				{ 2.5, 2.9, 3.0, 6.0, MEL },
			}
			for _, l in LAYERS do
				p(0, (l[1] + l[2]) / 2, 0, l[4], l[2] - l[1], l[3], l[5])
			end
			-- top cap: dark sides with a light stripe down the middle
			p(0, 3.15, -0.75, 5.0, 0.5, 0.7, MEL)
			p(0, 3.15, 0, 5.0, 0.5, 0.8, STRIPE)
			p(0, 3.15, 0.75, 5.0, 0.5, 0.7, MEL)
			-- rounded ends: two smaller dark slabs poking out of both ends
			p(0, 1.7, 0, 6.8, 2.0, 2.6, MEL_DK)
			p(0, 1.7, 0, 7.4, 1.0, 1.4, MEL_DK)
			-- stem nub on the +X end
			p(3.85, 1.7, 0, 0.5, 0.45, 0.45, STEM)
			return (F * CFrame.new(4.05 * s, 1.7 * s, 0)).Position
		end
		local stemA = melon(cf(-0.9, TOP, 0.6, 0, -8, 0), 0.85)
		local stemB = melon(cf(1.6, TOP, -2.1, 0, 10, 0), 0.45)

		-- thin vine along the dirt joining the two stems
		local VY = TOP + 0.18
		local function vine(a, b)
			B:beam(crop, a, b, 0.3, 0.3, LEAF_DK)
		end
		local k1, k2, k3 = v(2.7, VY, 1.9), v(3.5, VY, -0.6), v(-0.5, VY, -2.3)
		local kA = v(stemA.X + 0.45, VY, stemA.Z)
		vine(stemA, kA)
		vine(kA, k1)
		vine(kA, k2)
		vine(k2, stemB)
		vine(v(1.2, VY, -2.2), k3)

		-- big simple leaves (a wide blade + a smaller lobe), lying almost flat
		local function leaf(at, yaw)
			local F = CFrame.new(at + v(0, 0.1, 0)) * ang(0, yaw, 0) * ang(8, 0, 0)
			B:block(crop, v(2.0, 0.25, 1.7), F * CFrame.new(0, 0, -0.85), LEAF)
			B:block(crop, v(1.1, 0.25, 0.8), F * CFrame.new(0, 0.03, -2.0), LEAF)
		end
		leaf(k1, -165)
		leaf(k2, -95)
		leaf(k3, 80)
	end,
}
