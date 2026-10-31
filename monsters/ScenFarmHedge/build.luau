--!nocheck
-- Farm Hedge Wall (Sunny Farm scenery, 14 studs long). A neatly trimmed
-- farmyard hedge section in the apple-tree greens, dotted with pink, white
-- and yellow farm flowers. It runs along X from -7 to +7 with flat ends, and
-- every repeating detail stays inside that span with a 7-stud rhythm, so
-- copies placed 14 studs apart join into one long seamless hedge.
-- * body: dark core with stepped, rounded long edges (shadow foot band, main
--   green faces, a bevel band, a light top and a pale highlight strip)
-- * four clipped round bumps along the top (every 3.5 studs)
-- * proud leaf clusters (squares + diamonds, shadow / light greens) on both
--   long faces, with small flowers tucked between them
-- * grounding: grass tufts along the foot and a couple of pebbles
-- Scenery filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Farm Hedge Wall",
	Rarity = "Scenery",
	Filler = true,
	Element = "Sunny Farm",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		-- Sunny Farm palette (FillFarmBush / DecorFarmWell)
		local LEAF_HI, LEAF_LT, LEAF, LEAF_DK, LEAF_SH = "#7be35a", "#5fd23f", "#3fb43a", "#2a8f33", "#22762b"
		local PINK, PINK_DK, WHITE, CREAM, YELLOW, YELLOW_DK = "#ff7eb6", "#e85a98", "#ffffff", "#fff4dc", "#ffd93b", "#f2b01e"
		local GRASS, GRASS_DK = "#5fd23f", "#3fb43a"
		local STONE_LT, STONE = "#c3c9cf", "#9aa3ad"

		local L = 14 -- section length (tiles along X)
		local LI = L - 0.04 -- inner layers stop just short of the ends (no z-fight)
		local D = 3.2 -- core depth
		local TOP = 5.0

		------------------------------------------------------------ body
		B:block(R, v(L, TOP - 0.2, D), cf(0, (TOP + 0.2) / 2, 0), LEAF_DK)
		B:block(R, v(LI, 0.95, D + 0.3), cf(0, 0.475, 0), LEAF_SH)
		B:block(R, v(LI, 3.6, D + 0.55), cf(0, 2.7, 0), LEAF)
		B:block(R, v(LI, 0.55, D + 0.2), cf(0, TOP - 0.45, 0), LEAF)
		B:block(R, v(LI, 0.45, D - 0.2), cf(0, TOP - 0.05, 0), LEAF_LT)
		B:block(R, v(L - 0.3, 0.15, D - 1.1), cf(0, TOP + 0.22, 0), LEAF_HI)
		-- darker shadow seam under the bevel
		for _, s in { -1, 1 } do
			B:block(R, v(LI - 0.02, 0.2, 0.1), cf(0, TOP - 0.6, s * ((D + 0.55) / 2 + 0.02)), LEAF_DK)
		end

		------------------------------------------------------------ top bumps
		for _, x in { -5.25, -1.75, 1.75, 5.25 } do
			B:block(R, v(3.2, 1.0, 2.2), cf(x, TOP + 0.6, 0), LEAF)
			B:block(R, v(2.4, 1.0, 3.0), cf(x, TOP + 0.6, 0), LEAF)
			B:block(R, v(2.4, 0.6, 1.7), cf(x, TOP + 1.35, 0), LEAF_LT)
			B:block(R, v(1.8, 0.6, 2.4), cf(x, TOP + 1.35, 0), LEAF_LT)
			B:block(R, v(1.2, 0.22, 1.2), cf(x, TOP + 1.72, 0, 0, 45, 0), LEAF_HI)
		end

		------------------------------------------------------------ face clusters
		-- (x within a 7-stud period, y, size, colour, diamond?)
		local FACE = (D + 0.55) / 2
		local clusters = {
			{ -2.6, 1.6, 1.3, LEAF_DK, false },
			{ -1.2, 3.3, 1.2, LEAF_LT, true },
			{ 0.4, 1.9, 1.1, LEAF_LT, false },
			{ 1.9, 3.1, 1.3, LEAF_DK, true },
			{ 2.9, 1.5, 1.0, LEAF_DK, true },
			{ -3.0, 3.8, 0.9, LEAF_LT, false },
			{ 0.9, 4.0, 0.8, LEAF_DK, false },
			{ -0.6, 1.2, 0.8, LEAF_DK, true },
		}
		local flowers = {
			{ -2.0, 2.6, PINK },
			{ -0.3, 4.0, WHITE },
			{ 1.2, 2.8, PINK },
			{ 2.7, 3.9, WHITE },
			{ -2.95, 1.4, WHITE },
			{ 0.2, 1.5, PINK },
			{ -1.6, 4.1, PINK },
		}
		for _, s in { -1, 1 } do
			for _, half in { -3.5, 3.5 } do
				-- same pattern in both 7-stud halves (so tiled copies keep the rhythm), mirrored on the back face
				local flip = 1
				for _, c in clusters do
					local x = half + c[1] * flip * s
					local rot = c[5] and 45 or 0
					local sz = c[5] and c[3] * 0.75 or c[3]
					B:block(R, v(sz, sz, 0.14), cf(x, c[2], s * (FACE + 0.06), 0, 0, rot), c[4])
				end
				for _, f in flowers do
					local x = half + f[1] * flip * s
					local z = s * (FACE + 0.14)
					B:block(R, v(0.85, 0.34, 0.14), cf(x, f[2], z), f[3])
					B:block(R, v(0.34, 0.85, 0.14), cf(x, f[2], z), f[3])
					B:block(R, v(0.3, 0.3, 0.14), cf(x, f[2], z + s * 0.08), YELLOW)
				end
			end
		end
		-- a few flowers on top, between the bumps
		for i, x in { -3.5, 0, 3.5, -6.45, 6.45 } do
			local z = ((i % 2 == 0) and 0.7 or -0.6)
			local col = (i % 2 == 0) and WHITE or PINK
			B:block(R, v(0.8, 0.14, 0.32), cf(x, TOP + 0.33, z, 0, 20, 0), col)
			B:block(R, v(0.32, 0.14, 0.8), cf(x, TOP + 0.33, z, 0, 20, 0), col)
			B:block(R, v(0.28, 0.14, 0.28), cf(x, TOP + 0.4, z), YELLOW_DK)
		end

		------------------------------------------------------------ grounding
		local function tuft(x, z, h, ry)
			local b = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(ry), 0)
			B:block(R, v(0.4, h, 0.4), b * CFrame.new(0, h / 2, 0), GRASS)
			B:block(R, v(0.35, h * 0.75, 0.35), b * CFrame.new(0.32, h * 0.36, 0.05) * CFrame.Angles(0, 0, math.rad(-20)), GRASS_DK)
			B:block(R, v(0.35, h * 0.65, 0.35), b * CFrame.new(-0.3, h * 0.32, -0.05) * CFrame.Angles(0, 0, math.rad(22)), GRASS)
		end
		tuft(-5.4, -2.3, 0.9, 20)
		tuft(-1.1, -2.35, 0.8, -30)
		tuft(3.2, -2.3, 1.0, 50)
		tuft(6.0, -2.25, 0.7, 10)
		tuft(-3.6, 2.3, 0.8, -15)
		tuft(1.4, 2.35, 0.9, 35)
		tuft(5.0, 2.3, 0.7, -50)
		B:block(R, v(0.7, 0.28, 0.55), cf(-3.0, 0.14, -2.4, 0, 20, 0), STONE)
		B:block(R, v(0.5, 0.2, 0.4), cf(4.4, 0.1, -2.5, 0, -25, 0), STONE_LT)
		B:block(R, v(0.6, 0.24, 0.5), cf(-0.4, 0.12, 2.45, 0, 35, 0), STONE)
		-- fallen petals
		B:block(R, v(0.35, 0.08, 0.35), cf(0.9, 0.04, -2.55, 0, 45, 0), PINK)
		B:block(R, v(0.35, 0.08, 0.35), cf(-4.7, 0.04, 2.55, 0, 20, 0), CREAM)
	end,
}
