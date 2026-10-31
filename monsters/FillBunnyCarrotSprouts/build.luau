--!nocheck
-- Carrot Sprouts (Bunny Meadow filler). Three carrots of different sizes
-- poking their bright orange shoulders out of a small patch of tilled dirt,
-- each crowned with a tuft of fresh green leaves; the biggest one has a gold
-- ring, a nod to the meadow's VIP golden carrots.
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Carrot Sprouts",
	Rarity = "Filler",
	Filler = true,
	Element = "Bunny Meadow",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		local DIRT_DK, DIRT = "#4a2a16", "#744526"
		local OR, OR_DK, OR_LT = "#ff8a1c", "#d6600c", "#ffab4a"
		local LEAF, LEAF_DK = "#5fd645", "#349a2c"
		local GOLD = "#ffc62e"

		-- flat tilled dirt footing (two crossed slabs -> rounded patch)
		B:block(R, v(3.4, 0.12, 2.4), cf(0, 0.06, 0, 0, 8, 0), DIRT_DK)
		B:block(R, v(2.4, 0.16, 3.2), cf(0.1, 0.08, 0, 0, 8, 0), DIRT)

		local function carrot(x, z, s, ry, gold)
			local base = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(ry), 0)
			local w = 1.1 * s
			-- stepped shoulders: wide body, narrower top, dark crown
			B:block(R, v(w, 0.9 * s, w), base * CFrame.new(0, 0.45 * s, 0), OR)
			B:block(R, v(w * 0.75, 0.35 * s, w * 0.75), base * CFrame.new(0, 0.9 * s + 0.12 * s, 0) * CFrame.Angles(0, math.rad(45), 0), OR_LT)
			B:block(R, v(w + 0.08, 0.16 * s, w + 0.08), base * CFrame.new(0, 0.45 * s, 0), gold and GOLD or OR_DK)
			-- leaf tuft: one tall upright leaf + three fanned out around it
			local top = 0.9 * s + 0.25 * s
			local up = 1.3 * s
			B:block(R, v(0.5 * s, up, 0.2), base * CFrame.new(0, top + up / 2 - 0.1, 0), LEAF)
			for i = 1, 3 do
				local len = 1.05 * s
				local lcf = base * CFrame.new(0, top - 0.05, 0) * CFrame.Angles(0, math.rad(i * 120 + 30), 0) * CFrame.Angles(0, 0, math.rad(32))
				B:block(R, v(0.45 * s, len, 0.18), lcf * CFrame.new(0, len / 2, 0), (i == 2) and LEAF or LEAF_DK)
			end
		end
		carrot(-0.55, 0.35, 1.0, 15, true)
		carrot(0.85, -0.35, 0.8, -20, false)
		carrot(-0.35, -0.9, 0.65, 40, false)
	end,
}
