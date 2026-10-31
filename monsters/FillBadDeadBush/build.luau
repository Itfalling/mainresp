--!nocheck
-- Dead Thorn Bush (Bramble Badlands filler).
-- A dried-out bramble: five kinked, dusky maroon branches fanning up out of
-- a dark root knot, each with a bleached grey twig and pale bone-coloured
-- thorns. A charcoal stone leans against the knot. Sits on Y=0.
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Dead Thorn Bush",
	Rarity = "Filler",
	Filler = true,
	Element = "Bramble Badlands",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		local WOOD_DK, WOOD, WOOD_LT = "#3e2228", "#5a2e36", "#74424a"
		local ASH, ASH_LT = "#88827c", "#a7a19a"
		local THORN = "#e8d6ae"
		local RK, RK_LT = "#4a4044", "#625758"

		local function dir(deg)
			return v(math.sin(rad(deg)), 0, -math.cos(rad(deg)))
		end
		local function thorn(p, d)
			B:bar(R, p, p + d * 0.55, 0.24, 0.24, THORN)
		end

		-- root knot
		B:block(R, v(1.1, 0.5, 1.1), cf(0, 0.25, 0, 0, 45, 0), WOOD_DK)
		B:block(R, v(0.7, 0.5, 0.7), cf(0.05, 0.65, 0, 0, 10, 0), WOOD)

		-- branches: { yaw, mid radius, mid height, tip radius, tip height }
		local br = {
			{ 10, 0.7, 1.7, 1.2, 3.4 },
			{ 85, 0.9, 1.3, 1.9, 2.5 },
			{ 160, 0.8, 1.5, 1.6, 2.9 },
			{ 235, 0.9, 1.2, 1.9, 2.2 },
			{ 300, 0.7, 1.6, 1.4, 3.0 },
		}
		for i, b in br do
			local d = dir(b[1])
			local side = dir(b[1] + 90)
			local base = v(0, 0.6, 0)
			local mid = d * b[2] + v(0, b[3], 0) + side * 0.35
			local tip = d * b[4] + v(0, b[5], 0) - side * 0.35
			local hook = tip + d * 0.5 + side * 0.25 + v(0, 0.25, 0)
			B:bar(R, base, mid + (mid - base).Unit * 0.15, 0.42, 0.42, (i % 2 == 0) and WOOD or WOOD_DK)
			B:bar(R, mid, tip + (tip - mid).Unit * 0.1, 0.32, 0.32, (i % 2 == 0) and WOOD_LT or WOOD)
			B:bar(R, tip, hook, 0.24, 0.24, (i % 2 == 0) and WOOD or WOOD_LT)
			-- bleached side twig off the kink
			local twig = mid + d * 0.75 + side * ((i % 2 == 0) and 0.55 or -0.55) + v(0, 0.75, 0)
			B:bar(R, mid, twig, 0.22, 0.22, (i % 2 == 0) and ASH or ASH_LT)
			-- thorns
			thorn(base:Lerp(mid, 0.55), (d * 0.3 - side + v(0, 0.2, 0)).Unit)
			thorn(mid:Lerp(tip, 0.5), (side + v(0, 0.25, 0)).Unit)
		end

		-- a charcoal stone leaning on the knot
		B:block(R, v(0.9, 0.5, 0.8), cf(0.75, 0.25, -0.7, 0, 25, 0), RK_LT)
		B:block(R, v(0.7, 0.35, 0.6), cf(-0.7, 0.17, 0.6, 0, -15, 0), RK)
	end,
}
