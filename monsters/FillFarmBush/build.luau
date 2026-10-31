--!nocheck
-- Round Bush (Sunny Farm filler). A chunky round shrub in the farm greens:
-- stepped crossed slabs read round from every side (dark bottom, mid, light
-- top), a few big rotated leaf cubes break the outline, and a handful of
-- small red berries tucked into the leaves.
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Round Bush",
	Rarity = "Filler",
	Filler = true,
	Element = "Sunny Farm",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		local LEAF_LT, LEAF, LEAF_DK = "#5fd23f", "#3fb43a", "#2a8f33"
		local LEAF_DK2 = "#237a2b"
		local RED, RED_DK = "#e8242c", "#b8141c"

		-- dome of round tiers: each tier is two squares, one turned 45 degrees,
		-- which reads as a round 8-point outline from every angle
		local function tier(w, y0, y1, col, rot)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(R, v(w, h, w), cf(0, y, 0, 0, rot, 0), col)
			B:block(R, v(w, h, w), cf(0, y, 0, 0, rot + 45, 0), col)
		end
		tier(3.0, 0, 0.9, LEAF_DK2, 0)
		tier(3.9, 0.7, 2.6, LEAF_DK, 10)
		tier(3.3, 2.4, 3.5, LEAF, 22)
		tier(2.1, 3.3, 4.1, LEAF_LT, 5)

		-- a few offset leaf lumps at different heights break up the tiers
		local lumps = {
			-- x, y, z, size, height, rotY, colour
			{ 1.45, 1.95, -0.9, 1.5, 1.3, 25, LEAF },
			{ -1.55, 1.45, -0.5, 1.4, 1.2, -15, LEAF },
			{ 0.2, 1.25, 1.65, 1.5, 1.2, 40, LEAF },
			{ -0.9, 3.0, -0.95, 1.3, 1.0, 30, LEAF_LT },
			{ 0.95, 3.1, 0.85, 1.2, 0.9, 5, LEAF_LT },
		}
		for _, l in lumps do
			B:block(R, v(l[4], l[5], l[4]), cf(l[1], l[2], l[3], 0, l[6], 0), l[7])
		end

		-- small red berries sitting proud of the leaves
		local berries = {
			{ 1.95, 1.25, 0.75 }, { -0.75, 1.95, -1.95 }, { -2.0, 2.05, 0.75 }, { 1.2, 2.75, -1.35 }, { -0.4, 3.7, 1.05 },
		}
		for i, b in berries do
			B:block(R, v(0.5, 0.5, 0.5), cf(b[1], b[2], b[3], 0, 45, 0), (i % 2 == 0) and RED_DK or RED)
		end
	end,
}
