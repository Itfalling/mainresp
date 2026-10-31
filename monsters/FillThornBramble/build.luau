--!nocheck
-- Bramble Clump (Thorny Woods filler prop).
-- A round, scruffy briar bush of big rotated studded leaf cubes in four
-- greens, with a few dark thorny canes arching out of it (cream thorns along
-- them) and two crimson roses: one nestled in the foliage, one on a cane tip.
-- Sits straight on the ground. No motion, no effects.
return {
	DisplayName = "Bramble Clump",
	Rarity = "Filler",
	Filler = true,
	Element = "Thorny Woods",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"

		-- palette (Thorny Woods briar)
		local LEAF_DK, LEAF, LEAF_MID, LEAF_LT = "#1d6a35", "#26803e", "#33984a", "#52b457"
		local CANE, CANE_DK = "#3f7a2e", "#2c5a22"
		local THORN = "#ecdfb8"
		local ROSE, ROSE_DK, ROSE_LT = "#d8203e", "#9a1430", "#ff5a77"

		-- foliage: a dome of tilted leaf cubes, darker low, lighter on top
		-- {size, x, y, z, rx, ry, rz, color}
		local cubes = {
			{ 2.4, 0, 1.2, 0, 0, 20, 0, LEAF_DK }, -- core
			{ 1.7, -1.35, 1.0, 0.2, 14, 38, -18, LEAF },
			{ 1.7, 1.3, 1.0, -0.3, -12, 10, 20, LEAF },
			{ 1.6, 0.45, 0.95, 1.25, 20, 55, 6, LEAF_DK },
			{ 1.6, -0.45, 0.95, -1.25, -18, 30, -8, LEAF_DK },
			{ 1.5, -0.75, 2.0, 0.55, 18, 15, -22, LEAF_MID },
			{ 1.5, 0.85, 2.0, 0.35, -16, 60, 18, LEAF_MID },
			{ 1.4, 0.1, 2.05, -0.75, -24, 40, 6, LEAF },
			{ 1.3, 0.1, 2.85, 0.05, 12, 70, 14, LEAF_LT },
		}
		for _, c in cubes do
			B:block(R, v(c[1], c[1] * 0.85, c[1]), cf(c[2], c[3], c[4], c[5], c[6], c[7]), c[8])
		end
		-- a few flat leaves sticking out of the edges for a scruffy outline
		B:block(R, v(1.4, 0.3, 1.0), cf(-2.05, 1.5, -0.5, 0, 25, 28), LEAF_MID)
		B:block(R, v(1.3, 0.3, 1.0), cf(2.05, 1.6, 0.6, 0, -30, -30), LEAF_LT)
		B:block(R, v(1.0, 0.3, 1.3), cf(-0.2, 1.4, 2.0, -30, 15, 0), LEAF_MID)

		-- arching thorny canes: each is two bars, with thorns along them
		local function thorn(p, ry, rz)
			B:block(R, v(0.26, 0.26, 0.26), cf(p.X, p.Y, p.Z, 45, ry, rz), THORN)
		end
		local function cane(a, b, c, col)
			B:bar(R, a, b, 0.24, 0.24, col)
			B:bar(R, b, c, 0.2, 0.2, col)
			thorn(a:Lerp(b, 0.55) + v(0, 0.14, 0), 20, 45)
			thorn(b:Lerp(c, 0.5) + v(0, -0.1, 0), -30, 30)
		end
		cane(v(1.0, 2.0, -0.4), v(2.0, 3.0, -0.8), v(2.7, 2.6, -1.1), CANE)
		cane(v(-1.0, 1.8, -0.3), v(-1.9, 2.9, -0.6), v(-2.5, 2.7, -0.2), CANE_DK)
		cane(v(0.5, 2.7, 0.5), v(1.1, 3.5, 0.9), v(1.7, 3.6, 1.0), CANE)

		-- crimson rose: dark outer petals, bright middle, light curled centre
		local function rose(x, y, z, yaw, tilt, s)
			local C = cf(x, y, z, tilt, yaw, 0)
			B:block(R, v(1.1 * s, 0.5 * s, 1.1 * s), C, ROSE_DK)
			B:block(R, v(0.85 * s, 0.5 * s, 0.85 * s), C * CFrame.new(0, 0.25 * s, 0) * CFrame.Angles(0, math.rad(45), 0), ROSE)
			B:block(R, v(0.42 * s, 0.3 * s, 0.42 * s), C * CFrame.new(0, 0.55 * s, 0), ROSE_LT)
		end
		rose(-0.7, 2.75, -0.9, 20, -22, 1.0) -- nestled in the foliage
		rose(1.8, 3.65, 1.0, 60, 12, 0.8) -- on the tip of the tall cane
	end,
}
