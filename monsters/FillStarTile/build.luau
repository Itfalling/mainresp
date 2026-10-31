--!nocheck
-- Rune Floor Tile (Starlight Ruins filler).
-- A flat 4x4 temple floor tile that tiles seamlessly on a 4-stud grid:
-- indigo slab, white-violet stone border, a lighter indigo diamond panel
-- with a gold rune (diamond outline, four star rays, bright centre) and gold
-- corner squares that join into a gold square where four tiles meet.
-- Everything stays inside X/Z -2..2. Top surface around Y=0.55.
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Rune Floor Tile",
	Rarity = "Filler",
	Filler = true,
	Element = "Starlight Ruins",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"

		local TILE_DK, TILE = "#2a2550", "#4d4684"
		local STONE_LT, STONE2 = "#f4f0fb", "#d0c7e2"
		local GOLD, GOLD_DK, GOLD_LT = "#f2c24f", "#c9952e", "#ffe08a"

		local S, H = 4, 0.4 -- tile size, slab height
		local BW = 0.5 -- border width

		-- indigo slab
		B:block(R, v(S, H, S), cf(0, H / 2, 0), TILE_DK)
		-- white stone border (N/S full length, E/W between them)
		local by = H + 0.075
		B:block(R, v(S, 0.15, BW), cf(0, by, -(S - BW) / 2), STONE_LT)
		B:block(R, v(S, 0.15, BW), cf(0, by, (S - BW) / 2), STONE2)
		B:block(R, v(BW, 0.15, S - 2 * BW), cf(-(S - BW) / 2, by, 0), STONE_LT)
		B:block(R, v(BW, 0.15, S - 2 * BW), cf((S - BW) / 2, by, 0), STONE2)
		-- gold corner squares (sit on the border)
		for _, sx in { -1, 1 } do
			for _, sz in { -1, 1 } do
				B:block(R, v(BW, 0.06, BW), cf(sx * (S - BW) / 2, H + 0.18, sz * (S - BW) / 2), GOLD)
			end
		end

		-- lighter diamond panel
		B:block(R, v(2.1, 0.06, 2.1), cf(0, H + 0.03, 0, 0, 45, 0), TILE)

		-- gold rune: diamond outline
		local ry = H + 0.08
		local r = 1.25
		local pts = { v(0, ry, -r), v(r, ry, 0), v(0, ry, r), v(-r, ry, 0) }
		for i = 1, 4 do
			local a, b = pts[i], pts[i % 4 + 1]
			local d = (b - a).Unit
			B:bar(R, a - d * 0.1, b + d * 0.1, 0.22, 0.1, GOLD)
		end
		-- four star rays + bright centre
		for _, d in { v(0, 0, -1), v(1, 0, 0), v(0, 0, 1), v(-1, 0, 0) } do
			B:bar(R, v(0, ry, 0) + d * 0.3, v(0, ry, 0) + d * 0.78, 0.2, 0.1, GOLD_DK)
		end
		B:block(R, v(0.5, 0.12, 0.5), cf(0, H + 0.09, 0, 0, 45, 0), GOLD_LT)
	end,
}
