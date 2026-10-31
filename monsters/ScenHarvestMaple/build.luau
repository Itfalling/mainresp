--!nocheck
-- Autumn Maple (Harvest Fields scenery, big copy-paste filler ~18 studs).
-- A broad autumn maple: a chunky warm-brown trunk with a stepped root flare
-- and bark strips, four thick limbs reaching out, and a lumpy, lobed crown of
-- big rotated studded leaf cubes. Each lobe has its own autumn tone (orange,
-- red, golden top) with dark cubes underneath, main cubes around the middle
-- and bright stepped caps where the light hits, plus a few flat maple leaves
-- poking out of the outline. Footing: a flat ring of fallen leaves, a few
-- roots, grass tufts and a pebble. Anchored, weld-free, no scripts.
return {
	DisplayName = "Autumn Maple",
	Rarity = "Scenery",
	Filler = true,
	Element = "Harvest Fields",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		-- palette (Harvest Fields: Corn Shock Gate / Pumpkin Wagon)
		local BARK_DK, BARK, BARK_LT = "#55331d", "#7a4a2a", "#9a6438"
		local OR_DK, OR, OR_LT = "#d9581a", "#f27a1c", "#ff9a3a"
		local RD_DK, RD, RD_LT = "#a8231f", "#d8352a", "#ec5a34"
		local GD_DK, GD, GD_LT = "#e0921c", "#f7b52c", "#ffd34f"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local STONE, STONE_LT = "#8d8174", "#a39787"
		local DIRT, DIRT_DK = "#6a4126", "#4d2d1a"

		local seed = 4071
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		---------------------------------------------------------------- footing
		-- low dirt patch + a flat ring of fallen leaves (no mound)
		B:block(R, v(5.2, 0.14, 4.6), cf(0, 0.07, 0, 0, 12, 0), DIRT_DK)
		B:block(R, v(3.8, 0.2, 3.6), cf(0.3, 0.1, -0.2, 0, -18, 0), DIRT)
		local LITTER = { OR, RD, GD, OR_DK, GD_LT, RD_DK, OR_LT }
		for i = 1, 16 do
			local a = rad(i * 22.5 + rnd(-8, 8))
			local r = rnd(3.0, 6.2)
			local s = rnd(0.8, 1.3)
			B:block(R, v(s, 0.12, s), cf(math.sin(a) * r, 0.06 + (i % 3) * 0.02, math.cos(a) * r, 0, rnd(0, 90), 0), LITTER[i % #LITTER + 1])
		end
		for _, g in { { -4.2, -2.6, 10 }, { 4.6, 1.6, 40 }, { 1.2, 4.6, 70 }, { -3.0, 3.4, 25 } } do
			B:block(R, v(0.45, 1.0, 0.45), cf(g[1], 0.5, g[2], 6, g[3], 8), GRASS)
			B:block(R, v(0.35, 0.7, 0.35), cf(g[1] + 0.35, 0.35, g[2] + 0.2, -6, g[3] + 25, -10), GRASS_DK)
		end
		B:block(R, v(1.1, 0.5, 0.9), cf(3.4, 0.25, -2.6, 0, 25, 0), STONE)
		B:block(R, v(0.6, 0.3, 0.5), cf(3.2, 0.6, -2.5, 0, 50, 0), STONE_LT)

		---------------------------------------------------------------- trunk
		-- stepped root flare
		B:block(R, v(4.0, 0.9, 4.0), cf(0, 0.45, 0, 0, 8, 0), BARK_DK)
		for i = 0, 4 do
			local a = i * 72 + 20
			B:block(R, v(1.2, 0.8, 2.2), cf(0, 0.38, 0, 0, a, 0) * CFrame.new(0, 0.2, -2.3) * CFrame.Angles(rad(-8), 0, 0), i % 2 == 0 and BARK_DK or BARK)
		end
		B:block(R, v(3.4, 1.0, 3.4), cf(0, 1.3, 0, 0, -6, 0), BARK)
		B:block(R, v(2.9, 3.6, 2.9), cf(0, 3.5, 0), BARK)
		B:block(R, v(2.6, 3.0, 2.6), cf(0.1, 6.6, 0.05, 0, 8, 0), BARK_LT)
		B:block(R, v(2.2, 2.0, 2.2), cf(0.15, 8.9, 0.1, 0, 16, 0), BARK)
		-- bark strips
		for _, s in { { 1.47, 3.2, 0.3, 0.3, 2.6, 0.6, BARK_DK }, { -1.47, 4.4, -0.4, 0.3, 2.2, 0.6, BARK_DK }, { 0.2, 2.8, -1.47, 0.7, 1.8, 0.3, BARK_LT }, { -0.3, 5.6, 1.36, 0.6, 2.0, 0.3, BARK_DK }, { 1.35, 6.9, 0.2, 0.3, 1.6, 0.6, BARK } } do
			B:block(R, v(s[4], s[5], s[6]), cf(s[1], s[2], s[3]), s[7])
		end
		-- knot hole on the front
		B:block(R, v(0.8, 0.9, 0.2), cf(-0.3, 4.6, -1.48), BARK_DK)
		B:block(R, v(0.5, 0.55, 0.22), cf(-0.3, 4.6, -1.5), "#2e1a0e")

		-- limbs
		local function limb(a, b, w, col)
			B:bar(R, a, b, w, w, col)
			B:block(R, v(w + 0.2, w + 0.2, w + 0.2), CFrame.new(a), col)
		end
		limb(v(0.3, 7.4, 0), v(4.8, 10.4, -0.5), 1.2, BARK)
		limb(v(-0.3, 7.8, 0), v(-4.6, 10.2, 0.8), 1.2, BARK_LT)
		limb(v(0, 8.6, 0.3), v(0.6, 10.6, 4.2), 1.0, BARK)
		limb(v(0, 8.8, -0.3), v(-0.6, 10.8, -4.0), 1.0, BARK_LT)
		limb(v(0.1, 9.6, 0), v(0.3, 13.0, 0.2), 1.3, BARK)
		-- twigs that poke out under the crown
		B:bar(R, v(4.2, 10.0, -0.4), v(6.2, 10.0, -1.6), 0.45, 0.45, BARK_DK)
		B:bar(R, v(-4.0, 9.9, 0.7), v(-6.0, 9.6, 2.0), 0.45, 0.45, BARK_DK)

		---------------------------------------------------------------- crown
		-- leaf cube + a lighter stepped cap on its top
		local function leaf(x, y, z, s, cols, cap)
			local C = cf(x, y, z, rnd(-15, 15), rnd(0, 90), rnd(-15, 15))
			B:block(R, v(s, s, s), C, cols[1])
			if cap then
				B:block(R, v(0.7 * s, 0.32 * s, 0.7 * s), C * CFrame.new(0.05 * s, 0.56 * s, -0.04 * s) * CFrame.Angles(0, rad(35), 0), cols[2])
			end
		end
		-- lobe: core cube, a ring of dark cubes below, main cubes round the
		-- waist and bright cubes on top
		local function lobe(cx, cy, cz, r, pal, n)
			local dk, mn, lt = pal[1], pal[2], pal[3]
			leaf(cx, cy, cz, r * 1.6, { mn, lt }, false)
			local off = rnd(0, 360)
			for i = 0, n - 1 do
				local a = rad(off + i * 360 / n)
				local rr = r * rnd(0.85, 1.0)
				leaf(cx + math.sin(a) * rr, cy - r * 0.3, cz + math.cos(a) * rr, r * rnd(1.2, 1.35), { (i % 2 == 0) and dk or mn, mn }, false)
			end
			for i = 0, n - 2 do
				local a = rad(off + 30 + i * 360 / (n - 1))
				local rr = r * 0.55
				leaf(cx + math.sin(a) * rr, cy + r * 0.5, cz + math.cos(a) * rr, r * rnd(1.1, 1.2), { (i % 2 == 0) and mn or lt, lt }, i % 2 == 1)
			end
		end
		local ORANGE = { OR_DK, OR, OR_LT }
		local RED = { RD_DK, RD, RD_LT }
		local GOLD = { GD_DK, GD, GD_LT }
		lobe(0.2, 13.8, 0.0, 3.6, ORANGE, 4) -- centre mass
		lobe(-5.0, 11.6, 1.0, 2.9, RED, 4)
		lobe(5.2, 12.0, -0.7, 3.0, ORANGE, 4)
		lobe(0.9, 11.5, 4.8, 2.8, ORANGE, 4)
		lobe(-0.7, 11.8, -4.7, 2.8, RED, 4)
		lobe(0.5, 17.0, 0.4, 2.4, GOLD, 3) -- sunlit top

		-- shaded cubes under the crown give it depth from below
		for i = 0, 5 do
			local a = rad(i * 60 + 25)
			local r = (i % 2 == 0) and 3.4 or 4.2
			leaf(math.sin(a) * r, 9.4 + (i % 2) * 0.4, math.cos(a) * r, 2.6, { (i % 3 == 0) and RD_DK or OR_DK, OR }, false)
		end

		-- flat maple leaves poking out of the outline
		local edge = {
			{ -8.0, 10.8, 1.8, 20, OR_LT }, { 8.2, 11.4, -1.4, -25, GD_LT }, { 1.1, 10.6, 7.6, 95, RD_LT },
			{ -1.1, 11.0, -7.6, -80, OR_LT }, { 4.4, 14.6, 3.2, -40, GD }, { -4.4, 14.4, -2.6, 45, RD_LT },
		}
		for _, e in edge do
			local C = cf(e[1], e[2], e[3], 0, e[4], 0) * CFrame.Angles(0, 0, rad(-20))
			B:block(R, v(1.8, 0.3, 1.4), C, e[5])
			B:block(R, v(0.9, 0.32, 0.9), C * CFrame.new(0.5, 0.02, 0) * CFrame.Angles(0, rad(45), 0), e[5])
		end
	end,
}
