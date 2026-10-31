--!nocheck
-- Autumn Leaf Pile (Harvest Fields filler prop).
-- A soft, rounded heap of raked autumn leaves: four oval tiers (two crossed
-- slabs each, stepping in and slightly off-centre) shading from deep brown
-- and dark red at the bottom through orange to sunlit gold on top. Its
-- surface is shingled with individual leaves (a blade, a turned lobe and a
-- little stem each) in red, orange, gold and brown, leaning down the slope.
-- A forked twig pokes out, two acorns sit at the foot, and a few stray
-- leaves and grass tufts make a low footing.
return {
	DisplayName = "Autumn Leaf Pile",
	Rarity = "Filler",
	Filler = true,
	Element = "Harvest Fields",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		-- palette (Harvest Fields autumn leaves / wagon wood)
		local OR_DK, OR, OR_LT = "#c85a14", "#f27a1c", "#ff9a3a"
		local RED_DK, RED, RED_LT = "#a8281f", "#d8352a", "#ec5a3a"
		local GOLD_DK, GOLD, GOLD_LT = "#d8922a", "#f7b52c", "#ffd25a"
		local BROWN_DK, BROWN = "#7a4622", "#a0622e"
		local TWIG, TWIG_LT = "#5a3720", "#8a5a32"
		local NUT, NUT_LT, CAP = "#c08a52", "#d8a86a", "#6a4426"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"

		---------------------------------------------------------------- heap
		-- oval tiers: two crossed slabs each {wx, wz, y0, h, dx, dz, yaw, c1, c2}
		local tiers = {
			{ 4.8, 3.2, 0.0, 0.6, 0.0, 0.0, 6, BROWN, OR_DK },
			{ 3.8, 2.5, 0.5, 0.58, -0.15, 0.05, -4, OR_DK, RED },
			{ 2.8, 1.9, 0.98, 0.56, 0.05, -0.05, 10, OR, GOLD_DK },
			{ 1.8, 1.3, 1.44, 0.5, -0.2, 0.05, -12, GOLD, OR_LT },
		}
		for _, t in tiers do
			local C = cf(t[5], t[3] + t[4] / 2, t[6], 0, t[7], 0)
			B:block(R, v(t[1], t[4], t[2]), C, t[8])
			B:block(R, v(t[1] * 0.78, t[4] - 0.02, t[2] * 1.28), C, t[9])
		end
		B:block(R, v(1.0, 0.3, 0.8), cf(-0.15, 2.0, 0.0, 0, 30, 0), GOLD_LT)

		---------------------------------------------------------------- leaves
		-- one leaf: blade + turned lobe toward the tip + tiny stem
		local function leaf(C, k, c1, c2)
			B:block(R, v(0.75 * k, 0.12, 1.0 * k), C, c1)
			B:block(R, v(0.55 * k, 0.13, 0.55 * k), C * CFrame.new(0, 0.005, -0.35 * k) * CFrame.Angles(0, rad(45), 0), c2)
			B:block(R, v(0.08, 0.08, 0.4 * k), C * CFrame.new(0, 0.02, 0.62 * k), BROWN_DK)
		end
		-- leaves shingled on the slope {angle, radius, y, tilt, spin, k, c1, c2}
		local shingles = {
			{ 15, 1.95, 0.6, 18, 10, 1.0, RED, RED_LT },
			{ 75, 1.45, 0.58, 22, -15, 0.95, GOLD, GOLD_LT },
			{ 140, 1.85, 0.6, 16, 20, 1.0, OR, OR_LT },
			{ 205, 1.95, 0.6, 20, -10, 1.05, GOLD_DK, GOLD },
			{ 260, 1.5, 0.6, 24, 15, 0.95, RED, RED_LT },
			{ 320, 1.9, 0.6, 18, -20, 1.0, BROWN, OR_DK },
			{ 40, 1.55, 0.98, 20, 25, 0.9, OR, GOLD },
			{ 110, 1.15, 0.98, 24, -10, 0.85, RED_LT, RED },
			{ 180, 1.55, 0.98, 18, 5, 0.9, GOLD, GOLD_LT },
			{ 235, 1.25, 0.98, 22, -25, 0.85, OR_LT, OR },
			{ 295, 1.45, 0.98, 20, 15, 0.9, RED, OR },
			{ 0, 1.05, 1.36, 20, -15, 0.85, GOLD_LT, GOLD },
			{ 150, 1.0, 1.36, 24, 20, 0.8, RED, RED_LT },
			{ 250, 0.85, 1.36, 18, 0, 0.8, OR, OR_LT },
			{ 60, 0.25, 1.88, 8, 30, 0.85, RED_LT, RED },
		}
		for _, s in shingles do
			local a = rad(s[1])
			local d = v(math.cos(a), 0, math.sin(a))
			local p = v(d.X * s[2], s[3] + 0.2 + (s[3] > 0.9 and 0.1 or 0) + (s[3] > 1.3 and 0.12 or 0) + (s[3] > 1.8 and 0.12 or 0), d.Z * s[2] * 0.7)
			local frame = (P.aim(p, p + d))
			leaf(frame * CFrame.Angles(0, rad(s[5]), 0) * CFrame.Angles(rad(-s[4]), 0, 0), s[6], s[7], s[8])
		end

		---------------------------------------------------------------- twig + acorns
		B:bar(R, v(0.5, 1.5, 0.2), v(1.6, 2.4, -0.2), 0.2, 0.2, TWIG)
		B:bar(R, v(1.6, 2.4, -0.2), v(2.0, 2.6, -0.35), 0.16, 0.16, TWIG_LT)
		B:bar(R, v(1.25, 2.1, -0.1), v(1.25, 2.7, 0.2), 0.14, 0.14, TWIG)
		local function acorn(x, z, yaw, tip)
			local C = cf(x, 0, z, 0, yaw, tip)
			B:block(R, v(0.5, 0.55, 0.5), C * CFrame.new(0, 0.3, 0), NUT)
			B:block(R, v(0.3, 0.12, 0.3), C * CFrame.new(0, 0.05, 0), NUT_LT)
			B:block(R, v(0.62, 0.24, 0.62), C * CFrame.new(0, 0.62, 0), CAP)
			B:block(R, v(0.1, 0.2, 0.1), C * CFrame.new(0, 0.82, 0), TWIG)
		end
		acorn(-2.0, -1.55, 20, 0)
		-- a second acorn lying on its side
		local lay = cf(-1.35, 0.27, -1.95, 0, 50, 0) * CFrame.Angles(0, 0, rad(80))
		B:block(R, v(0.5, 0.55, 0.5), lay, NUT)
		B:block(R, v(0.62, 0.24, 0.62), lay * CFrame.new(0, 0.33, 0), CAP)
		B:block(R, v(0.1, 0.2, 0.1), lay * CFrame.new(0, 0.53, 0), TWIG)

		---------------------------------------------------------------- footing
		local strays = {
			{ 2.9, 1.3, 25, GOLD, GOLD_LT }, { -2.9, -0.4, -40, RED, RED_LT }, { 0.9, -2.2, 65, OR, OR_LT },
			{ -1.2, 2.1, 110, BROWN, OR_DK }, { 2.6, -1.5, 160, RED_DK, RED },
		}
		for _, s in strays do
			local C = cf(s[1], 0.07, s[2], 0, s[3], 0)
			B:block(R, v(0.7, 0.1, 0.95), C, s[4])
			B:block(R, v(0.5, 0.11, 0.5), C * CFrame.new(0, 0.005, -0.33) * CFrame.Angles(0, rad(45), 0), s[5])
		end
		for _, g in { { -2.6, 0.9, 15 }, { 2.9, -0.3, 50 }, { 0.2, 2.0, 80 } } do
			B:block(R, v(0.35, 0.75, 0.35), cf(g[1], 0.37, g[2], 6, g[3], 8), GRASS)
			B:block(R, v(0.3, 0.55, 0.3), cf(g[1] + 0.28, 0.27, g[2] + 0.12, -6, g[3] + 25, -12), GRASS_DK)
		end
	end,
}
