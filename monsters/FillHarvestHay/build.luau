--!nocheck
-- Hay Bale (Harvest Fields filler prop).
-- One chunky golden straw bale with rounded edges: a stepped profile (wide
-- body + tall narrow core) in three straw tones, a sun-bleached top, a
-- shaded tucked-in bottom, pressed-straw grain lines down both long faces,
-- shaggy stepped end caps with straw tufts, and two brown twine bands that
-- follow the stepped profile (one tied in a knot with a loose end). Straw
-- tufts poke out of the top; a low litter of loose straw, a pebble and a few
-- grass tufts ground it. Anchored, weld-free, no scripts: made to be
-- copy-pasted all over the fields.
return {
	DisplayName = "Hay Bale",
	Rarity = "Filler",
	Filler = true,
	Element = "Harvest Fields",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"

		-- palette (Harvest Fields hay / wagon / golden corn)
		local HAY_SH, HAY_DK, HAY, HAY_LT, HAY_HI = "#a87a24", "#c4922e", "#e6bd55", "#f4d98a", "#fbe8ae"
		local TWINE, TWINE_DK = "#8a5a2a", "#6a4220"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local STONE, STONE_LT = "#8d8174", "#a39787"

		local L, D = 4.2, 2.6

		---------------------------------------------------------------- bale body
		-- wide body + tall narrow core = rounded (chamfered) long edges
		B:block(R, v(L, 1.7, D), cf(0, 0.35 + 0.85, 0), HAY)
		B:block(R, v(L - 0.02, 2.3, D - 0.5), cf(0, 0.05 + 1.15, 0), HAY)
		-- shaded, tucked-in bottom course
		B:block(R, v(L - 0.08, 0.34, D - 0.3), cf(0, 0.2, 0), HAY_SH)
		B:block(R, v(L + 0.02, 0.22, D + 0.02), cf(0, 0.45, 0), HAY_DK)
		-- sun-bleached top cap + highlight strips along the upper ledges
		B:block(R, v(L - 0.24, 0.18, D - 0.72), cf(0, 2.44, 0), HAY_LT)
		for s = -1, 1, 2 do
			B:block(R, v(L - 0.06, 0.1, 0.24), cf(0, 2.08, s * (D / 2 - 0.13)), HAY_LT)
		end

		---------------------------------------------------------------- grain lines
		-- pressed-straw lines on both long faces {x, y, len, color}
		local lines = {
			{ -0.9, 0.95, 2.0, HAY_DK }, { 0.8, 1.3, 2.3, HAY_LT }, { -0.3, 1.65, 2.8, HAY_DK }, { 1.2, 0.8, 1.2, HAY_LT },
		}
		for s = -1, 1, 2 do
			for i, g in lines do
				local x = g[1] * s
				B:block(R, v(g[3], 0.14, 0.06), cf(x, g[2] + (s > 0 and 0.08 or 0), s * (D / 2 + 0.01), 0, 0, 0), g[4])
			end
		end

		---------------------------------------------------------------- end caps
		for s = -1, 1, 2 do
			local x = s * (L / 2)
			B:block(R, v(0.16, 1.5, D - 0.4), cf(x + s * 0.06, 1.2, 0), HAY_LT)
			B:block(R, v(0.16, 2.0, D - 0.9), cf(x + s * 0.06, 1.2, 0), HAY_LT)
			B:block(R, v(0.12, 0.6, 1.3), cf(x + s * 0.14, 1.55, -s * 0.2), HAY_HI)
			B:block(R, v(0.12, 0.5, 0.8), cf(x + s * 0.14, 1.0, s * 0.35), HAY)
			B:block(R, v(0.1, 0.12, 1.4), cf(x + s * 0.13, 0.62, s * 0.1), HAY_DK)
			-- shaggy straw tufts sticking out of the end
			B:bar(R, v(x, 1.9, 0.5 * s), v(x + s * 0.55, 2.15, 0.7 * s), 0.12, 0.12, HAY_HI)
			B:bar(R, v(x, 0.9, -0.7 * s), v(x + s * 0.5, 0.75, -0.95 * s), 0.12, 0.12, HAY_LT)
		end

		---------------------------------------------------------------- twine bands
		-- each band follows the stepped profile: body ring, core ring, over the cap
		for i, x in { -1.15, 1.2 } do
			B:block(R, v(0.24, 1.76, D + 0.08), cf(x, 1.2, 0), TWINE)
			B:block(R, v(0.24, 2.36, D - 0.42), cf(x, 1.2, 0), TWINE)
			B:block(R, v(0.24, 0.24, D - 0.64), cf(x, 2.45, 0), TWINE)
			if i == 2 then
				-- knot on the front + loose end
				B:block(R, v(0.42, 0.36, 0.16), cf(x, 1.75, -(D / 2 + 0.08), 0, 0, 12), TWINE_DK)
				B:bar(R, v(x + 0.05, 1.65, -(D / 2 + 0.1)), v(x + 0.3, 1.05, -(D / 2 + 0.18)), 0.12, 0.12, TWINE_DK)
			end
		end

		---------------------------------------------------------------- straw on top
		local tufts = {
			{ -0.6, 0.3, -0.4, 0.4, 0.2, HAY_HI }, { -0.45, 0.25, -0.1, 0.6, -0.1, HAY_LT },
			{ 0.4, -0.35, 0.6, 0.4, -0.5, HAY_HI }, { 1.75, 0.5, 2.0, 0.35, 0.8, HAY_LT },
			{ -1.7, -0.5, -2.0, 0.3, -0.75, HAY_HI },
		}
		for _, t in tufts do
			B:bar(R, v(t[1], 2.45, t[2]), v(t[3], 2.45 + t[4], t[5]), 0.12, 0.12, t[6])
		end

		---------------------------------------------------------------- footing
		-- low litter of loose straw around the bale
		B:block(R, v(1.4, 0.06, 0.9), cf(-2.55, 0.03, 0.6, 0, 20, 0), HAY)
		B:block(R, v(1.1, 0.06, 0.7), cf(2.45, 0.03, -0.9, 0, -30, 0), HAY)
		local straws = {
			{ -2.7, 0.9, 1.3, 30, HAY_LT }, { -2.4, 0.3, 1.0, -50, HAY }, { -1.4, -1.7, 1.2, 10, HAY_LT },
			{ 2.6, -1.0, 1.1, 65, HAY_LT }, { 2.3, -0.6, 0.9, -15, HAY }, { 1.0, 1.75, 1.3, -20, HAY_LT },
			{ 0.0, -1.75, 0.8, 80, HAY },
		}
		for _, s in straws do
			B:block(R, v(s[3], 0.12, 0.18), cf(s[1], 0.11, s[2], 0, s[4], 0), s[5])
		end
		B:block(R, v(0.7, 0.36, 0.55), cf(2.75, 0.18, 1.0, 0, 25, 0), STONE)
		B:block(R, v(0.4, 0.2, 0.36), cf(2.55, 0.34, 1.05, 0, 40, 0), STONE_LT)
		for _, g in { { -2.4, -1.3, 10 }, { 2.9, 0.2, 40 }, { -0.8, 1.75, 70 } } do
			B:block(R, v(0.35, 0.75, 0.35), cf(g[1], 0.37, g[2], 6, g[3], 8), GRASS)
			B:block(R, v(0.3, 0.55, 0.3), cf(g[1] + 0.28, 0.27, g[2] + 0.12, -6, g[3] + 25, -12), GRASS_DK)
		end
	end,
}
