--!nocheck
-- Gold Rope Post (Bunny Meadow filler). One shiny gold VIP stanchion (stepped
-- base, slim shaft, hook collar, cube finial with a tiny pink neon cap) with a
-- short red velvet rope stub swagging out to each side. Each stub ends at
-- x = +-2.0 at the low point of the swag, with a gold end cap, so copies placed
-- 4 studs apart along X join into one continuous sagging rope line (the two end
-- caps meet as a gold clasp).
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Gold Rope Post",
	Rarity = "Filler",
	Filler = true,
	Element = "Bunny Meadow",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		local GOLD_LT, GOLD, GOLD_DK = "#ffe27a", "#ffc62e", "#d9961a"
		local VELVET, VELVET_DK = "#c0162f", "#860c20"
		local N_PINK = "#ff5cc8"

		------------------------------------------------------------ post
		B:block(R, v(1.6, 0.35, 1.6), cf(0, 0.175, 0), GOLD_DK)
		B:block(R, v(1.2, 0.3, 1.2), cf(0, 0.5, 0, 0, 45, 0), GOLD)
		B:block(R, v(0.8, 0.25, 0.8), cf(0, 0.75, 0), GOLD_LT)
		local TOP = 3.6
		B:block(R, v(0.55, TOP - 0.8, 0.55), cf(0, (0.8 + TOP) / 2, 0), GOLD)
		local HOOK = 3.15
		B:block(R, v(0.85, 0.3, 0.85), cf(0, HOOK, 0, 0, 45, 0), GOLD_DK)
		B:block(R, v(1.0, 1.0, 1.0), cf(0, TOP + 0.35, 0, 0, 45, 0), GOLD)
		B:block(R, v(0.6, 0.45, 0.6), cf(0, TOP + 1.05, 0), GOLD_LT)
		B:gem(R, v(0.3, 0.3, 0.3), cf(0, TOP + 1.4, 0, 0, 45, 0), N_PINK, { name = "Cap" })

		------------------------------------------------------------ rope stubs
		-- half a swag each side: from the hook (u = 0) down to the low point at
		-- x = +-2 (u = 1), where the slope is flat so neighbours join smoothly.
		local HALF, SAG = 2.0, 1.0
		for _, s in { -1, 1 } do
			local function pt(u)
				local x = 0.45 + (HALF - 0.45) * u
				return v(s * x, HOOK - SAG * (1 - (1 - u) ^ 2), -0.05)
			end
			local a, b = pt(0), pt(1)
			local tip = b - v(s * 0.2, 0, 0)
			local p1, p2 = pt(1 / 3), pt(2 / 3)
			B:bar(R, a, p1, 0.55, 0.55, VELVET)
			B:bar(R, p1, p2, 0.55, 0.55, VELVET)
			B:bar(R, p2, tip, 0.55, 0.55, VELVET)
			for _, k in { p1, p2 } do
				B:block(R, v(0.62, 0.62, 0.62), CFrame.new(k) * P.ang(45, 0, 0), VELVET_DK)
			end
			-- gold clip at the hook, gold end cap at the stub tip
			B:block(R, v(0.55, 0.5, 0.7), CFrame.new(a), GOLD_DK)
			B:block(R, v(0.4, 0.66, 0.66), CFrame.new(tip), GOLD)
		end
	end,
}
