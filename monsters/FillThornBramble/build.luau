--!nocheck
-- Bramble Clump (Thorny Woods filler prop).
-- A scruffy, rounded briar bush: clumps of tilted studded leaf cubes, each
-- with a lighter cube stepped on top (dark low down, bright where the light
-- hits), ragged flat leaves with pale veins around the outline, and four dark
-- briar canes arching out of it, bristling with cream thorns tipped crimson.
-- Two layered crimson roses (dark outer petals, bright middle, pale curled
-- centre, green sepals) and a closed bud sit in the foliage, with a couple of
-- rose hips. A low forest-floor footing of dirt and moss, pebbles, grass tufts
-- and fallen petals. No motion, no effects.
return {
	DisplayName = "Bramble Clump",
	Rarity = "Filler",
	Filler = true,
	Element = "Thorny Woods",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		-- palette (Thorny Woods: Rose Hip Briar / Thorn Arch / Mushroom Log)
		local LEAF_DK, LEAF, LEAF_LT, LEAF_TOP = "#24632c", "#2f7f35", "#4b9e3c", "#6fba45"
		local CANE, CANE_DK = "#3f7a2e", "#2c5a22"
		local THORN, THORN_TIP = "#ecdfb8", "#a01838"
		local ROSE_DK, ROSE, ROSE_LT, ROSE_HI = "#9a1430", "#d8203e", "#ff5a77", "#ff9aae"
		local HIP, HIP_LT, HIP_DK = "#e0402a", "#ff6d3a", "#4a2a1a"
		local DIRT_DK, DIRT = "#3e2716", "#5a3a22"
		local MOSS, MOSS_DK = "#5fae3a", "#3f8a2c"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT = "#8d8a80", "#a9a397"
		local PETAL = "#ff86b3"

		---------------------------------------------------------------- foliage
		-- clump: tilted leaf cube + a lighter cube stepped onto its top
		local function clump(x, y, z, s, rx, ry, rz, c1, c2)
			local C = cf(x, y, z, rx, ry, rz)
			B:block(R, v(s, 0.85 * s, s), C, c1)
			B:block(R, v(0.72 * s, 0.3 * s, 0.72 * s), C * CFrame.new(0.06 * s, 0.5 * s, -0.04 * s) * CFrame.Angles(0, rad(30), 0), c2)
		end
		clump(0.0, 1.25, 0.0, 2.4, 0, 20, 0, LEAF_DK, LEAF) -- core
		clump(-1.45, 0.85, 0.25, 1.7, 12, 38, -16, LEAF_DK, LEAF)
		clump(1.4, 0.85, -0.3, 1.7, -10, 8, 16, LEAF_DK, LEAF)
		clump(0.45, 0.8, 1.3, 1.6, 16, 55, 6, LEAF_DK, LEAF)
		clump(-0.4, 0.8, -1.3, 1.6, -16, 30, -8, LEAF, LEAF_LT)
		clump(-0.85, 2.05, 0.5, 1.45, 16, 15, -20, LEAF, LEAF_LT)
		clump(0.95, 2.0, 0.35, 1.45, -14, 60, 16, LEAF, LEAF_LT)
		clump(0.15, 2.05, -0.8, 1.35, -20, 40, 6, LEAF_LT, LEAF_TOP)
		clump(0.1, 2.9, 0.05, 1.25, 10, 70, 12, LEAF_LT, LEAF_TOP)
		clump(1.75, 0.55, 0.85, 1.0, 8, 25, 10, LEAF, LEAF_LT)

		-- ragged flat leaves around the outline (blade + pale vein)
		local edge = {
			{ -2.15, 1.5, -0.4, 25, 28, LEAF_LT }, { 2.15, 1.55, 0.5, -30, -30, LEAF_TOP }, { -0.3, 1.45, 2.05, 100, -28, LEAF_LT },
			{ 0.7, 1.25, -2.0, -80, 26, LEAF }, { -1.6, 2.4, -0.9, 50, 34, LEAF_TOP }, { 1.5, 2.6, -0.6, -40, -32, LEAF_LT },
		}
		for _, e in edge do
			local C = cf(e[1], e[2], e[3], 0, e[4], 0) * CFrame.Angles(0, 0, rad(e[5]))
			B:block(R, v(1.3, 0.24, 0.9), C, e[6])
			B:block(R, v(1.0, 0.06, 0.12), C * CFrame.new(0, 0.14, 0), LEAF_TOP)
		end

		---------------------------------------------------------------- briar canes
		local function thorn(a, b, f, sideSign)
			local d = (b - a).Unit
			local side = d:Cross(v(0, 1, 0))
			if side.Magnitude < 0.1 then side = v(1, 0, 0) end
			local mid = a:Lerp(b, f)
			local tp = mid + side.Unit * 0.38 * sideSign + v(0, 0.18, 0)
			B:bar(R, mid, tp, 0.18, 0.18, THORN)
			B:block(R, v(0.13, 0.13, 0.13), CFrame.new(tp), THORN_TIP)
		end
		local function cane(pts)
			for i = 1, #pts - 1 do
				B:bar(R, pts[i], pts[i + 1], 0.3 - i * 0.04, 0.3 - i * 0.04, (i % 2 == 0) and CANE or CANE_DK)
				if i < #pts - 1 or i == 1 then
					thorn(pts[i], pts[i + 1], 0.55, (i % 2 == 0) and 1 or -1)
				end
			end
		end
		cane({ v(1.0, 2.0, -0.5), v(2.0, 3.0, -0.9), v(2.8, 3.1, -1.2), v(3.3, 2.5, -1.3) })
		cane({ v(-1.0, 1.9, -0.4), v(-2.0, 2.9, -0.7), v(-2.7, 2.8, -0.3), v(-3.0, 2.2, 0.0) })
		cane({ v(0.4, 2.8, 0.6), v(0.9, 3.7, 1.1), v(1.6, 3.85, 1.3) })
		cane({ v(-0.6, 1.4, 1.2), v(-1.4, 2.0, 2.0), v(-2.1, 1.6, 2.4) })

		---------------------------------------------------------------- roses
		local function rose(p, yaw, tilt, k)
			local C = CFrame.new(p) * CFrame.Angles(rad(tilt), rad(yaw), 0)
			B:block(R, v(0.9 * k, 0.3 * k, 0.9 * k), C, CANE)
			for i = 0, 3 do
				B:block(R, v(0.62 * k, 0.16, 0.42 * k), C * CFrame.Angles(0, rad(i * 90 + 40), 0) * CFrame.new(0, 0.06, -0.7 * k), LEAF)
			end
			B:block(R, v(1.3 * k, 0.65 * k, 1.3 * k), C * CFrame.new(0, 0.42 * k, 0) * CFrame.Angles(0, rad(20), 0), ROSE_DK)
			B:block(R, v(1.08 * k, 0.6 * k, 1.08 * k), C * CFrame.new(0, 0.66 * k, 0) * CFrame.Angles(0, rad(65), 0), ROSE)
			B:block(R, v(0.62 * k, 0.4 * k, 0.62 * k), C * CFrame.new(0, 0.98 * k, 0) * CFrame.Angles(0, rad(20), 0), ROSE_LT)
			B:block(R, v(0.28 * k, 0.16, 0.28 * k), C * CFrame.new(0, 1.2 * k, 0) * CFrame.Angles(0, rad(50), 0), ROSE_HI)
		end
		rose(v(-0.75, 2.75, -0.95), 20, -22, 0.95)
		rose(v(1.65, 3.85, 1.3), 60, 12, 0.75) -- on the tall cane's tip
		-- closed bud on the right cane
		local bp = v(3.3, 2.55, -1.3)
		local BF = CFrame.new(bp) * CFrame.Angles(0, rad(30), rad(-25))
		B:block(R, v(0.42, 0.2, 0.42), BF, CANE)
		B:block(R, v(0.36, 0.42, 0.36), BF * CFrame.new(0, 0.3, 0), ROSE_DK)
		B:block(R, v(0.24, 0.26, 0.24), BF * CFrame.new(0, 0.6, 0) * CFrame.Angles(0, rad(45), 0), ROSE)
		for sgn = -1, 1, 2 do
			B:block(R, v(0.1, 0.42, 0.08), BF * CFrame.new(sgn * 0.2, 0.28, 0) * CFrame.Angles(0, 0, rad(-sgn * 14)), LEAF_LT)
		end
		-- little rose hips hanging off the left canes (Rose Hip Briar style)
		for _, h in { { v(-3.0, 2.2, 0.0), 0.42, 10 }, { v(-2.1, 1.6, 2.4), 0.38, -12 } } do
			local tip, k = h[1], h[2]
			local c = tip + v(0, -0.35, 0)
			B:bar(R, tip, c, 0.12, 0.12, CANE)
			local F = CFrame.new(c + v(0, -0.62 * k - 0.05, 0)) * CFrame.Angles(0, rad(20), rad(h[3]))
			B:block(R, v(0.95 * k, 1.25 * k, 0.95 * k), F, HIP)
			B:block(R, v(0.72 * k, 1.6 * k, 0.72 * k), F * CFrame.Angles(0, rad(45), 0), HIP_LT)
			B:block(R, v(0.4 * k, 0.35 * k, 0.4 * k), F * CFrame.new(0, -0.9 * k, 0) * CFrame.Angles(0, rad(45), 0), HIP_DK)
		end

		---------------------------------------------------------------- footing
		B:block(R, v(3.6, 0.12, 2.8), cf(0.1, 0.06, 0.1, 0, 15, 0), DIRT_DK)
		B:block(R, v(2.6, 0.16, 2.0), cf(-0.7, 0.08, 0.6, 0, -20, 0), MOSS_DK)
		B:block(R, v(1.4, 0.18, 1.0), cf(1.3, 0.09, -1.2, 0, 35, 0), DIRT)
		B:block(R, v(0.7, 0.4, 0.55), cf(2.35, 0.2, -1.55, 4, 25, -4), STONE)
		B:block(R, v(0.42, 0.22, 0.36), cf(2.2, 0.42, -1.5, 0, 50, 0), STONE_LT)
		B:block(R, v(0.5, 0.26, 0.4), cf(-2.3, 0.13, -1.3, 0, 60, 0), STONE)
		for _, g in { { -2.3, 1.2, 15 }, { 2.4, 1.3, 50 }, { 0.3, -2.1, 80 } } do
			B:block(R, v(0.35, 0.8, 0.35), cf(g[1], 0.4, g[2], 6, g[3], 8), GRASS)
			B:block(R, v(0.3, 0.6, 0.3), cf(g[1] + 0.28, 0.3, g[2] + 0.12, -6, g[3] + 25, -12), GRASS_DK)
		end
		B:block(R, v(0.55, 0.08, 0.4), cf(1.0, 0.04, -2.2, 0, 30, 0), PETAL)
		B:block(R, v(0.5, 0.08, 0.38), cf(-1.7, 0.04, -1.9, 0, -20, 0), ROSE)
		B:block(R, v(0.45, 0.08, 0.35), cf(2.6, 0.04, 0.2, 0, 70, 0), PETAL)
		B:block(R, v(0.8, 0.14, 0.6), cf(-2.6, 0.07, 0.3, 0, 40, 0), MOSS)
	end,
}
