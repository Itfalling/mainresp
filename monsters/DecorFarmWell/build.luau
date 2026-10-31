--!nocheck
-- Wooden Well (Sunny Farm decoration, medium ~11 studs). A cute farmyard well:
-- * footing: a few flat grey stepping stones and grass tufts (bone "Base")
-- * a chunky octagonal stone ring, three courses of two-tone grey stones with
--   a pale cap rim and bright blue water inside
-- * two wooden posts carrying a little red shingled gable roof (rotated
--   shingle rows, wooden gable boards, dark ridge cap)
-- * a rope drum on an axle with a crank handle on the right, and a wooden
--   bucket with metal bands hanging on the rope over the water
-- Faces -Z. Static prop: no motion.luau.
return {
	DisplayName = "Wooden Well",
	Rarity = "Decor",
	Element = "Sunny Farm",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local STONE_LT, STONE, STONE_DK = "#c3c9cf", "#9aa3ad", "#7c858f"
		local WOOD_LT, WOOD, WOOD_DK = "#c98a4b", "#a8692f", "#6b4220"
		local ROOF, ROOF_DK, ROOF_LT = "#e0392e", "#b02720", "#f25a44"
		local WATER, WATER_LT = "#3fa7e8", "#7fd0ff"
		local ROPE, METAL = "#e3c78a", "#8f98a3"
		local GRASS, GRASS_DK = "#5fd23f", "#3fb43a"
		local DARK = "#3a3f46"

		------------------------------------------------------------------
		-- footing: flat stepping stones + grass tufts
		------------------------------------------------------------------
		local base = B:bone("Base", "Root", v(0, 0, 0))
		local stones = {
			{ -3.6, -3.3, 1.8, 1.4, 20, STONE },
			{ 3.4, -3.6, 1.6, 1.4, -15, STONE_LT },
			{ 4.1, 2.6, 1.4, 1.2, 30, STONE },
			{ -4.0, 2.9, 1.5, 1.5, 10, STONE_LT },
			{ 0.6, -4.6, 2.0, 1.3, 5, STONE_LT },
		}
		for _, s in stones do
			B:block(base, v(s[3], 0.3, s[4]), cf(s[1], 0.15, s[2], 0, s[5], 0), s[6])
		end
		local function tuft(x, z, h, flower)
			B:block(base, v(0.5, h, 0.5), cf(x, h / 2, z), GRASS)
			B:block(base, v(0.4, h * 0.7, 0.4), cf(x + 0.35, h * 0.35 + 0.08, z + 0.2, 0, 0, -18), GRASS_DK)
			B:block(base, v(0.4, h * 0.75, 0.4), cf(x - 0.35, h * 0.37 + 0.08, z - 0.15, 0, 0, 18), GRASS)
			if flower then
				B:block(base, v(0.55, 0.3, 0.55), cf(x, h + 0.1, z), flower)
				B:block(base, v(0.25, 0.32, 0.25), cf(x, h + 0.12, z), "#ffd93b")
			end
		end
		tuft(-3.9, -1.0, 1.0, "#ffffff")
		tuft(3.9, -1.4, 0.9, "#ff7eb6")
		tuft(-1.9, -4.3, 0.8)
		tuft(2.6, 3.9, 1.0, "#ff7eb6")
		tuft(-2.6, 4.0, 0.85)

		------------------------------------------------------------------
		-- stone ring (octagon: 4 straight sides + 4 diagonal corners)
		------------------------------------------------------------------
		local well = "Root"
		local R = 2.75 -- centre line of the wall
		local CH = 1.0 -- course height
		local courses = { STONE, STONE_DK, STONE }
		for i, col in courses do
			local y = 0.2 + CH * (i - 0.5)
			local alt = (col == STONE) and STONE_DK or STONE
			-- straight sides
			B:block(well, v(3.0, CH, 1.2), cf(0, y, -R), col)
			B:block(well, v(3.0, CH, 1.2), cf(0, y, R), col)
			B:block(well, v(1.2, CH, 3.0), cf(-R, y, 0), col)
			B:block(well, v(1.2, CH, 3.0), cf(R, y, 0), col)
			-- diagonal corners (alternate shade -> brick look)
			for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
				local d = R * 0.71
				B:block(well, v(2.7, CH, 1.2), cf(c[1] * d, y, c[2] * d, 0, c[1] * c[2] * 45, 0), alt)
			end
		end
		local topY = 0.2 + CH * #courses
		-- pale cap rim, slightly proud
		B:block(well, v(3.2, 0.4, 1.5), cf(0, topY + 0.2, -R), STONE_LT)
		B:block(well, v(3.2, 0.4, 1.5), cf(0, topY + 0.2, R), STONE_LT)
		B:block(well, v(1.5, 0.4, 3.2), cf(-R, topY + 0.2, 0), STONE_LT)
		B:block(well, v(1.5, 0.4, 3.2), cf(R, topY + 0.2, 0), STONE_LT)
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			local d = R * 0.71
			B:block(well, v(2.8, 0.4, 1.5), cf(c[1] * d, topY + 0.2, c[2] * d, 0, c[1] * c[2] * 45, 0), STONE_LT)
		end
		-- a few accent stones poking out of the wall
		B:block(well, v(1.0, 0.6, 0.3), cf(-0.9, 1.0, -R - 0.65), STONE_LT)
		B:block(well, v(0.8, 0.5, 0.3), cf(1.0, 2.2, -R - 0.65), STONE_DK)
		B:block(well, v(0.3, 0.6, 1.0), cf(R + 0.65, 1.6, 0.6), STONE_LT)
		B:block(well, v(0.3, 0.5, 0.9), cf(-R - 0.65, 2.3, -0.5), STONE_DK)
		-- wider stepped footing course hugging the bottom of the wall
		for _, sd in { { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } } do
			local w = (sd[1] == 0) and v(3.1, 0.35, 0.5) or v(0.5, 0.35, 3.1)
			B:block(well, w, cf(sd[1] * (R + 0.75), 0.175, sd[2] * (R + 0.75)), STONE_DK)
		end
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			local d = (R + 0.75) * 0.71
			B:block(well, v(2.9, 0.35, 0.5), cf(c[1] * d, 0.175, c[2] * d, 0, c[1] * c[2] * 45, 0), STONE_DK)
		end
		-- a little moss creeping up one side
		B:block(well, v(1.2, 0.5, 0.25), cf(-1.4, 0.9, -R - 0.62, 0, 0, 0), GRASS_DK)
		B:block(well, v(0.6, 0.4, 0.25), cf(-1.2, 1.3, -R - 0.64), GRASS)
		-- dark shaft + water inside
		B:block(well, v(3.6, 0.2, 3.6), cf(0, topY - 0.9, 0), DARK)
		B:block(well, v(3.4, 0.25, 3.4), cf(0, topY - 0.55, 0), WATER)
		B:block(well, v(0.8, 0.1, 0.4), cf(-0.7, topY - 0.38, -0.6), WATER_LT)
		B:block(well, v(0.5, 0.1, 0.3), cf(0.9, topY - 0.38, 0.8), WATER_LT)

		------------------------------------------------------------------
		-- wooden posts + crossbar + rope drum + crank
		------------------------------------------------------------------
		local PX = 2.75
		local postTop = 8.6
		for _, s in { 1, -1 } do
			B:block(well, v(0.8, postTop - topY, 0.8), cf(s * PX, (topY + postTop) / 2 + 0.2, 0), WOOD)
			B:block(well, v(1.1, 0.4, 1.1), cf(s * PX, topY + 0.55, 0), WOOD_DK)
			-- little knee braces under the roof
			B:bar(well, v(s * PX, postTop - 1.4, 0), v(s * PX, postTop - 0.2, -1.2), 0.4, 0.4, WOOD_DK)
			B:bar(well, v(s * PX, postTop - 1.4, 0), v(s * PX, postTop - 0.2, 1.2), 0.4, 0.4, WOOD_DK)
		end
		-- top beam between posts
		B:block(well, v(6.6, 0.6, 0.7), cf(0, postTop - 0.1, 0), WOOD_DK)
		-- axle + rope drum
		local AY = 6.3
		B:block(well, v(6.9, 0.35, 0.35), cf(0, AY, 0), WOOD_DK)
		B:block(well, v(2.6, 1.1, 1.1), cf(0, AY, 0), WOOD_LT)
		B:block(well, v(0.3, 1.4, 1.4), cf(-1.35, AY, 0), WOOD_DK)
		B:block(well, v(0.3, 1.4, 1.4), cf(1.35, AY, 0), WOOD_DK)
		for i = -1, 1 do
			B:block(well, v(0.5, 1.2, 1.2), cf(i * 0.75, AY, 0), ROPE)
		end
		-- crank on the right
		B:block(well, v(0.35, 1.6, 0.4), cf(PX + 0.65, AY - 0.6, 0), WOOD_DK)
		B:block(well, v(1.1, 0.4, 0.4), cf(PX + 1.05, AY - 1.3, 0), WOOD_LT)
		B:block(well, v(0.5, 0.5, 0.5), cf(PX + 1.6, AY - 1.3, 0), ROOF)

		------------------------------------------------------------------
		-- rope + hanging bucket
		------------------------------------------------------------------
		local BY = 4.4
		B:block(well, v(0.2, AY - 0.5 - (BY + 1.2), 0.2), cf(0, (AY - 0.5 + BY + 1.2) / 2, -0.55), ROPE)
		B:bar(well, v(0, BY + 1.25, -0.55), v(-0.6, BY + 0.6, -0.55), 0.15, 0.15, METAL)
		B:bar(well, v(0, BY + 1.25, -0.55), v(0.6, BY + 0.6, -0.55), 0.15, 0.15, METAL)
		B:block(well, v(1.3, 1.1, 1.3), cf(0, BY, -0.55), WOOD_LT)
		B:block(well, v(1.1, 0.4, 1.1), cf(0, BY - 0.6, -0.55), WOOD)
		B:block(well, v(1.4, 0.2, 1.4), cf(0, BY + 0.3, -0.55), METAL)
		B:block(well, v(1.4, 0.2, 1.4), cf(0, BY - 0.3, -0.55), METAL)
		B:block(well, v(1.0, 0.1, 1.0), cf(0, BY + 0.53, -0.55), WATER)

		-- a spare bucket resting on a stepping stone (front-right)
		local gb = CFrame.new(3.4, 0.3, -3.6) * CFrame.Angles(0, math.rad(20), 0)
		B:block(well, v(1.0, 0.9, 1.0), gb * CFrame.new(0, 0.45, 0), WOOD_LT)
		B:block(well, v(1.1, 0.15, 1.1), gb * CFrame.new(0, 0.7, 0), METAL)
		B:block(well, v(1.1, 0.15, 1.1), gb * CFrame.new(0, 0.2, 0), METAL)
		B:block(well, v(0.75, 0.1, 0.75), gb * CFrame.new(0, 0.86, 0), WATER)
		B:block(well, v(0.12, 0.12, 1.2), gb * CFrame.new(0.5, 1.0, 0) * CFrame.Angles(0, 0, math.rad(-35)), METAL)

		------------------------------------------------------------------
		-- little red shingled gable roof (ridge along X)
		------------------------------------------------------------------
		local ridgeY = 10.6
		local ANG = 34
		local slope = 3.4 -- panel depth along the slope
		local function panel(s) -- s = -1 front (-Z), +1 back
			local th = rad(s * ANG)
			local cz = s * slope / 2 * math.cos(rad(ANG))
			local cy = ridgeY - slope / 2 * math.sin(rad(ANG))
			local pcf = CFrame.new(0, cy, cz) * CFrame.Angles(th, 0, 0)
			B:block(well, v(7.4, 0.35, slope), pcf, ROOF_DK)
			-- shingle rows, lower rows overlapping on top
			local rows = 3
			for i = 1, rows do
				local lz = s * (-slope / 2 + (i - 0.5) * slope / rows)
				local col = (i % 2 == 0) and ROOF_LT or ROOF
				B:block(well, v(7.6, 0.3, slope / rows + 0.25), pcf * CFrame.new(0, 0.25 + 0.06 * i, lz), col)
			end
		end
		panel(-1)
		panel(1)
		B:block(well, v(7.8, 0.45, 0.7), cf(0, ridgeY + 0.35, 0), WOOD_DK)
		-- stepped wooden gable boards at each end
		for _, s in { 1, -1 } do
			local x = s * (PX + 0.05)
			B:block(well, v(0.3, 0.8, 4.4), cf(x, postTop + 0.4, 0), WOOD_LT)
			B:block(well, v(0.3, 0.7, 2.6), cf(x, postTop + 1.15, 0), WOOD_LT)
			B:block(well, v(0.3, 0.5, 1.0), cf(x, postTop + 1.7, 0), WOOD_LT)
			B:block(well, v(0.35, 0.5, 0.5), cf(x, postTop + 0.9, 0), ROOF)
		end
	end,
}
