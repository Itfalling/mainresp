--!nocheck
-- Gold Rope Post (Bunny Meadow filler, v2). One shiny VIP stanchion with a short
-- velvet rope swag to each side, on a strip of red carpet. Built to chain:
-- copies placed 4 studs apart along X join into one continuous rope line on one
-- continuous carpet runner.
-- * post: rounded stepped base (square + 45-degree square tiers, dark / main /
--   light gold), slim shaft with a light edge strip and two collars, hook
--   collar, cube finial with a light cap and a tiny pink neon tip
-- * rope: each half droops from the hook (x = +-0.45) to the low point at
--   x = +-2.0 where the slope is flat, in 4 segments with a lighter top strip,
--   dark knots at the joints, a gold clip with a rivet at the hook and a gold
--   end cap at the tip (two neighbours' caps meet as a clasp)
-- * footing: a 4-stud carpet strip with gold side trims (ends at x = +-2 so
--   chained copies form one runner) and a darker pile stripe
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Gold Rope Post",
	Rarity = "Filler",
	Filler = true,
	Element = "Bunny Meadow",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		-- Bunny Meadow palette (DecorBunnyRope)
		local GOLD_LT, GOLD, GOLD_DK = "#ffe27a", "#ffc62e", "#d9961a"
		local VELVET, VELVET_DK, VELVET_LT = "#c0162f", "#860c20", "#e0384e"
		local CARPET, CARPET_DK = "#d11a3a", "#9c1028"
		local N_PINK = "#ff5cc8"

		local HALF = 2.0 -- half the chain spacing

		------------------------------------------------------------ carpet strip
		local CW = 2.2
		B:block(R, v(HALF * 2, 0.14, CW), cf(0, 0.07, 0), CARPET)
		B:block(R, v(HALF * 2, 0.16, 0.4), cf(0, 0.08, -0.45), CARPET_DK)
		for _, s in { -1, 1 } do
			B:block(R, v(HALF * 2, 0.2, 0.22), cf(0, 0.1, s * (CW / 2 + 0.05)), GOLD_DK)
			B:block(R, v(HALF * 2, 0.06, 0.12), cf(0, 0.22, s * (CW / 2 + 0.05)), GOLD)
		end
		local YB = 0.14

		------------------------------------------------------------ post
		local function tier(w, y0, y1, col)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(R, v(w, h, w), cf(0, y, 0), col)
			B:block(R, v(w, h, w), cf(0, y, 0, 0, 45, 0), col)
		end
		tier(1.45, YB, YB + 0.3, GOLD_DK)
		tier(1.15, YB + 0.3, YB + 0.55, GOLD)
		tier(0.8, YB + 0.55, YB + 0.75, GOLD_LT)
		local TOP = YB + 3.45
		B:block(R, v(0.5, TOP - YB - 0.7, 0.5), cf(0, (YB + 0.7 + TOP) / 2, 0), GOLD)
		-- light edge strip on the front-left corner of the shaft
		B:block(R, v(0.14, TOP - YB - 0.9, 0.14), cf(-0.2, (YB + 0.8 + TOP) / 2, -0.2), GOLD_LT)
		-- collars
		B:block(R, v(0.72, 0.18, 0.72), cf(0, YB + 1.2, 0), GOLD_DK)
		local HOOK = YB + 3.0
		B:block(R, v(0.82, 0.3, 0.82), cf(0, HOOK, 0, 0, 45, 0), GOLD_DK)
		B:block(R, v(0.7, 0.1, 0.7), cf(0, HOOK + 0.2, 0), GOLD_LT)
		-- finial
		B:block(R, v(0.7, 0.18, 0.7), cf(0, TOP + 0.05, 0), GOLD_DK)
		B:block(R, v(0.95, 0.95, 0.95), cf(0, TOP + 0.6, 0, 0, 45, 0), GOLD)
		B:block(R, v(0.7, 0.1, 0.7), cf(0, TOP + 1.12, 0, 0, 45, 0), GOLD_LT)
		B:block(R, v(0.5, 0.35, 0.5), cf(0, TOP + 1.3, 0), GOLD_LT)
		B:block(R, v(0.26, 0.26, 0.26), cf(0, TOP + 1.58, 0, 0, 45, 0), N_PINK, { mat = "Neon", name = "Cap" })

		------------------------------------------------------------ rope halves
		local SAG = 0.95
		local N = 3
		for _, s in { -1, 1 } do
			local function pt(u)
				local x = 0.45 + (HALF - 0.2 - 0.45) * u
				return v(s * x, HOOK - SAG * (1 - (1 - u) ^ 2), -0.02)
			end
			for k = 0, N - 1 do
				local a, b = pt(k / N), pt((k + 1) / N)
				B:bar(R, a, b, 0.5, 0.5, VELVET)
				B:bar(R, a + v(0, 0.2, -0.02), b + v(0, 0.2, -0.02), 0.42, 0.14, VELVET_LT)
			end
			for k = 1, N - 1 do
				B:block(R, v(0.54, 0.54, 0.54), CFrame.new(pt(k / N)) * P.ang(45, 0, 0), VELVET_DK)
			end
			-- gold clip with a rivet at the hook
			local a = pt(0)
			B:block(R, v(0.5, 0.48, 0.66), CFrame.new(a), GOLD_DK)
			B:block(R, v(0.22, 0.22, 0.7), CFrame.new(a + v(0, 0.04, 0)), GOLD_LT)
			-- gold end cap at the tip (flush with x = +-2)
			local tip = pt(1)
			B:block(R, v(0.4, 0.62, 0.62), CFrame.new(tip + v(s * 0.0, 0, 0)), GOLD)
			B:block(R, v(0.4, 0.12, 0.66), CFrame.new(tip + v(0, 0.25, 0)), GOLD_LT)
		end
	end,
}
