--!nocheck
-- Rune Floor Tile (Starlight Ruins filler).
-- A flat star-temple floor tile, exactly 4x4 studs, that tiles seamlessly on
-- a 4-stud grid (nothing leaves X/Z -2..2):
-- * indigo slab with a darker under-band
-- * a laid white-violet stone border: each side is three stones of
--   different lengths in alternating tones with a pale top highlight, and a
--   gold corner cap (gold + dark-gold trim) at each corner, so four tiles
--   meet in a 1x1 gold square
-- * a lighter indigo diamond panel with a thin silver inner frame, small
--   gold star dots in the four corner fields
-- * the gold rune: a diamond outline, four long and four short star rays and
--   a stepped 8-point star in the centre (square + square turned 45°) with
--   one tiny glowing cyan core
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Rune Floor Tile",
	Rarity = "Filler",
	Filler = true,
	Element = "Starlight Ruins",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"

		-- palette (Starlight Ruins)
		local EARTH_XD, EARTH_DK, EARTH, EARTH_LT = "#211d42", "#2a2550", "#3b3566", "#4d4684"
		local STONE, STONE2, STONE_DK, STONE_HI = "#e3dcef", "#d0c7e2", "#a99fc2", "#fbf9ff"
		local GOLD, GOLD_DK, GOLD_LT = "#f2c24f", "#c9952e", "#ffe08a"
		local SILVER = "#b8c4f0"
		local RUNE = "#7fe8ff"

		local S, H, BW = 4, 0.4, 0.5 -- tile size, slab height, border width
		local hs = S / 2

		------------------------------------------------------------ slab
		B:block(R, v(S, 0.12, S), cf(0, 0.06, 0), EARTH_XD) -- under-band
		B:block(R, v(S, H - 0.12, S), cf(0, 0.12 + (H - 0.12) / 2, 0), EARTH_DK)

		------------------------------------------------------------ border
		-- each side between the corner caps (length S - 2*BW = 3): three stones
		local runs = { { 1.25, STONE }, { 0.8, STONE2 }, { 0.95, STONE } }
		local BH = 0.18
		local by = H + BH / 2
		local function side(axisX, sgn, flip)
			local t = -1.5 + 0.0
			local order = flip and { runs[3], runs[2], runs[1] } or runs
			for i, r in order do
				local len = r[1]
				local c = t + len / 2
				local col = (sgn > 0) and ((i % 2 == 0) and STONE or STONE2) or r[2]
				local gap = 0.03
				if axisX then
					B:block(R, v(len - gap, BH, BW), cf(c, by, sgn * (hs - BW / 2)), col)
					B:block(R, v(len - gap - 0.12, 0.04, BW * 0.45), cf(c, H + BH + 0.02, sgn * (hs - BW / 2) - sgn * 0.08), STONE_HI)
				else
					B:block(R, v(BW, BH, len - gap), cf(sgn * (hs - BW / 2), by, c), col)
					B:block(R, v(BW * 0.45, 0.04, len - gap - 0.12), cf(sgn * (hs - BW / 2) - sgn * 0.08, H + BH + 0.02, c), STONE_HI)
				end
				t += len
			end
		end
		side(true, -1, false)
		side(true, 1, true)
		side(false, -1, true)
		side(false, 1, false)
		-- thin dark grout line inside the border
		for _, sg in { -1, 1 } do
			B:block(R, v(S - 2 * BW, 0.08, 0.1), cf(0, H + 0.04, sg * (hs - BW - 0.05)), STONE_DK)
			B:block(R, v(0.1, 0.08, S - 2 * BW - 0.2), cf(sg * (hs - BW - 0.05), H + 0.04, 0), STONE_DK)
		end
		-- gold corner caps (they meet as a 1x1 gold square between four tiles)
		for _, sx in { -1, 1 } do
			for _, sz in { -1, 1 } do
				local x, z = sx * (hs - BW / 2), sz * (hs - BW / 2)
				B:block(R, v(BW, BH, BW), cf(x, by, z), GOLD_DK)
				B:block(R, v(BW - 0.1, 0.06, BW - 0.1), cf(x, H + BH + 0.03, z), GOLD)
			end
		end

		------------------------------------------------------------ panel
		B:block(R, v(2.15, 0.06, 2.15), cf(0, H + 0.03, 0, 0, 45, 0), EARTH)
		B:block(R, v(1.6, 0.08, 1.6), cf(0, H + 0.04, 0, 0, 45, 0), EARTH_LT)

		-- little gold star dots in the four corner fields
		for _, sx in { -1, 1 } do
			for _, sz in { -1, 1 } do
				B:block(R, v(0.2, 0.06, 0.2), cf(sx * 1.05, H + 0.03, sz * 1.05, 0, 45, 0), GOLD_LT)
			end
		end

		------------------------------------------------------------ rune
		local ry = H + 0.1
		-- silver inner frame + gold diamond outline
		local function diamond(r, w, y, col)
			local pts = { v(0, y, -r), v(r, y, 0), v(0, y, r), v(-r, y, 0) }
			for i = 1, 4 do
				local a, b = pts[i], pts[i % 4 + 1]
				local d = (b - a).Unit
				B:bar(R, a - d * w * 0.5, b + d * w * 0.5, w, 0.08, col)
			end
		end
		diamond(1.5, 0.14, H + 0.07, SILVER)
		diamond(1.2, 0.2, ry, GOLD)
		-- long rays along the axes, short rays on the diagonals
		for _, d in { v(0, 0, -1), v(1, 0, 0), v(0, 0, 1), v(-1, 0, 0) } do
			B:bar(R, v(0, ry, 0) + d * 0.35, v(0, ry, 0) + d * 1.0, 0.16, 0.08, GOLD_DK)
		end
		local q = math.sqrt(0.5)
		for _, d in { v(q, 0, q), v(q, 0, -q), v(-q, 0, q), v(-q, 0, -q) } do
			B:bar(R, v(0, ry, 0) + d * 0.35, v(0, ry, 0) + d * 0.62, 0.12, 0.08, GOLD)
		end
		-- stepped 8-point star in the centre + tiny glowing core
		B:block(R, v(0.55, 0.1, 0.55), cf(0, H + 0.12, 0), GOLD)
		B:block(R, v(0.55, 0.11, 0.55), cf(0, H + 0.12, 0, 0, 45, 0), GOLD_LT)
		B:block(R, v(0.18, 0.08, 0.18), cf(0, H + 0.2, 0, 0, 45, 0), RUNE, { mat = "Neon" })
	end,
}
