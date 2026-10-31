--!nocheck
-- Wooden Fence (Sunny Farm filler, v2). A straight 6-stud farmyard rail-fence
-- section that tiles end to end along X.
-- * two chunky posts at x = +-1.5 (tiled copies keep an even 3-stud rhythm):
--   dark stone-and-wood foot, three-tone post (shadow foot band, main body,
--   light front edge strip), grain line, stepped cap (dark slab, light 45-degree
--   slab, small top block)
-- * two plank rails running the full 6 studs (ends exactly at x = +-3 so
--   neighbours butt cleanly): main plank, light top edge, dark underside, grain
--   lines and knots, grey nail heads where they cross the posts
-- * a diagonal brace in the middle bay (tiled rows alternate braced/plain bays)
-- * low grass tufts, pebbles and one small daisy as grounding
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Wooden Fence",
	Rarity = "Filler",
	Filler = true,
	Element = "Sunny Farm",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		-- exact Sunny Farm palette (DecorFarmWell)
		local WOOD_LT, WOOD, WOOD_DK = "#c98a4b", "#a8692f", "#6b4220"
		local WOOD_MID = "#8a5a2b"
		local STONE_LT, STONE, STONE_DK = "#c3c9cf", "#9aa3ad", "#7c858f"
		local METAL = "#7c858f"
		local GRASS, GRASS_DK = "#5fd23f", "#3fb43a"

		local POSTS = { -1.5, 1.5 }
		local RAILS = { 1.3, 2.75 }
		local RZ = -0.62 -- rail centre (in front of the posts)

		------------------------------------------------------------ posts
		for i, x in POSTS do
			-- footing: flat stone + dark wooden foot band
			B:block(R, v(1.4, 0.2, 1.3), cf(x, 0.1, 0.05, 0, i * 9, 0), STONE_DK)
			B:block(R, v(1.1, 0.55, 1.1), cf(x, 0.45, 0), WOOD_DK)
			-- main post + light front-left edge strip + grain line
			B:block(R, v(0.9, 3.05, 0.9), cf(x, 2.1, 0), WOOD)
			-- shaded right side + lit left edge, grain line
			B:block(R, v(0.12, 2.9, 0.92), cf(x + 0.4, 2.12, 0), WOOD_MID)
			B:block(R, v(0.12, 2.9, 0.92), cf(x - 0.4, 2.12, 0), WOOD_LT)
			B:block(R, v(0.08, 0.9, 0.94), cf(x - 0.05, 3.15 - i * 0.15, 0), WOOD_MID)
			-- stepped cap
			B:block(R, v(1.15, 0.3, 1.15), cf(x, 3.75, 0), WOOD_DK)
			B:block(R, v(0.9, 0.28, 0.9), cf(x, 4.03, 0, 0, 45, 0), WOOD_LT)
			B:block(R, v(0.45, 0.2, 0.45), cf(x, 4.25, 0), WOOD)
		end

		------------------------------------------------------------ rails
		for ri, y in RAILS do
			B:block(R, v(6, 0.66, 0.4), cf(0, y, RZ), WOOD)
			B:block(R, v(6, 0.16, 0.46), cf(0, y + 0.3, RZ), WOOD_LT)
			B:block(R, v(6, 0.14, 0.44), cf(0, y - 0.3, RZ), WOOD_DK)
			-- shaded lower board half + plank seam in the middle
			B:block(R, v(6, 0.22, 0.43), cf(0, y - 0.13, RZ), WOOD_MID)
			B:block(R, v(0.1, 0.62, 0.48), cf(ri == 1 and 0.35 or -0.45, y, RZ), WOOD_DK)
			-- a knot
			local kx = (ri == 1) and -0.6 or 0.7
			B:block(R, v(0.22, 0.22, 0.08), cf(kx, y - 0.05, RZ - 0.22), WOOD_DK)
			-- one nail head at each post
			for _, x in POSTS do
				B:block(R, v(0.2, 0.2, 0.08), cf(x, y, RZ - 0.23, 0, 0, 45), METAL)
			end
		end

		------------------------------------------------------------ brace
		local bz = RZ + 0.02
		local a, b = v(-1.1, RAILS[1] - 0.1, bz), v(1.1, RAILS[2] + 0.1, bz)
		B:bar(R, a, b, 0.4, 0.36, WOOD_MID)
		B:bar(R, a + v(0, 0.13, -0.03), b + v(0, 0.13, -0.03), 0.1, 0.4, WOOD_LT)

		------------------------------------------------------------ grounding
		local function tuft(x, z, h, ry)
			local base = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(ry), 0)
			B:block(R, v(0.32, h, 0.32), base * CFrame.new(0, h / 2, 0), GRASS)
			B:block(R, v(0.28, h * 0.75, 0.28), base * CFrame.new(0.28, h * 0.36, 0.05) * CFrame.Angles(0, 0, math.rad(-20)), GRASS_DK)
			B:block(R, v(0.28, h * 0.65, 0.28), base * CFrame.new(-0.26, h * 0.32, -0.05) * CFrame.Angles(0, 0, math.rad(22)), GRASS)
		end
		tuft(-2.2, -0.95, 0.9, 15)
		tuft(1.05, -1.0, 0.7, -30)
		tuft(2.35, 0.5, 0.65, 40)
		-- pebbles
		B:block(R, v(0.5, 0.22, 0.4), cf(-0.45, 0.11, -1.05, 0, 25, 0), STONE)
		B:block(R, v(0.35, 0.16, 0.3), cf(-0.05, 0.08, -0.85, 0, -10, 0), STONE_LT)
		B:block(R, v(0.4, 0.18, 0.35), cf(2.0, 0.09, 0.55, 0, 40, 0), STONE)
		-- a little daisy by the left tuft
		B:block(R, v(0.12, 0.7, 0.12), cf(-2.5, 0.35, -1.35), GRASS_DK)
		B:block(R, v(0.42, 0.12, 0.42), cf(-2.5, 0.72, -1.35, 0, 45, 0), "#ffffff")
		B:block(R, v(0.18, 0.16, 0.18), cf(-2.5, 0.74, -1.35), "#ffd93b")
	end,
}
