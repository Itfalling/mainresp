--!nocheck
-- Mossy Jungle Ruin (Snap-Jaw Jungle scenery, big copy-paste filler).
-- A broken chunk of jungle-stone wall (same stone as the Overgrown Jungle
-- Arch / Vine Totem): a dark plinth course, staggered courses of big
-- three-tone bricks with a stepped broken top that falls from a squat corner
-- pilaster down to a rubble stump, a carved cream teeth frieze under the
-- pilaster cap, dark recessed panels, moss caps with drips on every step,
-- leafy clumps on top, and green vines with leaves climbing both faces.
-- Fallen bricks, stones, tufts and ferns on a low bog-dirt footing.
-- Anchored, weld-free, no scripts or effects.
return {
	DisplayName = "Mossy Jungle Ruin",
	Rarity = "Scenery",
	Filler = true,
	Element = "Snap-Jaw Jungle",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		local DIRT_DK, DIRT = "#3f2516", "#4d2d1a"
		local MOSS, MOSS_DK, MOSS_LT = "#6cb337", "#4f8f2a", "#8fd04a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK, STONE_XDK = "#9a9180", "#b8ae98", "#757062", "#4e4a40"
		local GREEN, GREEN_DK, GREEN_LT, GREEN_TOP = "#3caa3c", "#1f6e2a", "#9fd84a", "#58c447"
		local CREAM = "#fff4d2"

		local seed = 7713
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		local D = 3.0 -- wall depth
		------------------------------------------------------------ footing
		B:block(R, v(18.0, 0.3, 6.6), cf(0, 0.15, 0), DIRT_DK)
		B:block(R, v(15.0, 0.29, 8.0), cf(0.4, 0.145, 0), DIRT_DK)
		B:block(R, v(12.0, 0.2, 4.2), cf(-1.0, 0.34, 1.2, 0, 4, 0), DIRT)
		for _, e in { { -9.2, -2.0, DIRT }, { 9.4, 1.8, DIRT }, { -6.0, 3.9, DIRT_DK }, { 6.4, -3.9, DIRT_DK } } do
			B:block(R, v(2.0, 0.32, 1.4), cf(e[1], 0.16, e[2], 0, rnd(-20, 20), 0), e[3])
		end
		B:block(R, v(3.4, 0.2, 1.6), cf(-3.4, 0.38, -2.6, 0, 8, 0), MOSS)
		B:block(R, v(2.6, 0.2, 1.4), cf(3.6, 0.37, 2.7, 0, -10, 0), MOSS_DK)
		B:block(R, v(2.0, 0.2, 1.2), cf(7.4, 0.38, -2.4, 0, 20, 0), MOSS)

		------------------------------------------------------------ wall
		-- plinth course
		B:block(R, v(15.4, 1.1, D + 0.8), cf(0, 0.75, 0), STONE_DK)
		B:block(R, v(15.0, 0.3, D + 0.5), cf(0, 1.4, 0), STONE)
		local function brick(x0, x1, y0, y1, col)
			local w, h = x1 - x0, y1 - y0
			local c = CFrame.new((x0 + x1) / 2, (y0 + y1) / 2, rnd(-0.15, 0.15)) * ang(0, rnd(-2, 2), 0)
			B:block(R, v(w + 0.04, h, D + rnd(-0.1, 0.2)), c, col)
			return c, w, h
		end
		local rows = {
			{ 1.5, 3.7, { { -7.3, -4.0, STONE }, { -4.0, -0.4, STONE_LT }, { -0.4, 3.2, STONE }, { 3.2, 5.9, STONE_DK }, { 5.9, 7.4, STONE } } },
			{ 3.7, 5.9, { { -7.4, -5.1, STONE_LT }, { -5.1, -1.8, STONE }, { -1.8, 1.6, STONE_DK }, { 1.6, 4.5, STONE_LT } } },
			{ 5.9, 8.1, { { -7.3, -4.3, STONE }, { -4.3, -1.0, STONE_LT }, { -1.0, 1.4, STONE } } },
			{ 8.1, 10.1, { { -7.4, -5.0, STONE_DK }, { -5.0, -2.6, STONE } } },
		}
		for _, r in rows do
			for _, b in r[3] do
				brick(b[1], b[2], r[1], r[2], b[3])
			end
		end
		-- broken stumps stepping down on the right
		brick(4.5, 6.3, 5.9, 7.0, STONE)
		brick(1.4, 2.9, 8.1, 9.0, STONE_DK)
		brick(-2.6, -0.9, 10.1, 10.9, STONE_LT)
		-- mortar shadow lines between courses (front + back)
		for _, z in { -1, 1 } do
			B:block(R, v(14.6, 0.16, 0.1), cf(0, 3.7, z * (D / 2 + 0.22)), STONE_XDK)
			B:block(R, v(11.4, 0.16, 0.1), cf(-1.6, 5.9, z * (D / 2 + 0.22)), STONE_XDK)
			B:block(R, v(8.4, 0.16, 0.1), cf(-3.1, 8.1, z * (D / 2 + 0.22)), STONE_XDK)
		end

		-- corner pilaster (squat stacked drums) + capital with teeth frieze
		local PX = -7.0
		for i, d in { { 1.4, 3.0, 4.2, STONE }, { 4.4, 2.8, 3.9, STONE_LT }, { 7.2, 2.8, 4.1, STONE } } do
			local F = CFrame.new(PX, d[1] + d[2] / 2, 0) * ang(0, (i % 2 == 0) and 4 or -3, 0)
			B:block(R, v(d[3], d[2], d[3]), F, d[4])
			B:block(R, v(d[3] + 0.16, 0.3, d[3] + 0.16), F * CFrame.new(0, -d[2] / 2 + 0.15, 0), STONE_DK)
		end
		B:block(R, v(4.0, 0.6, 4.0), cf(PX, 10.3, 0), STONE_DK)
		B:block(R, v(4.6, 0.7, 4.4), cf(PX, 10.95, 0), STONE)
		B:block(R, v(3.2, 0.8, 3.0), cf(PX + 0.2, 11.7, 0.1, 0, 8, 0), STONE_LT)
		for _, z in { -1, 1 } do
			B:block(R, v(3.4, 0.55, 0.1), cf(PX, 9.75, z * 2.07), STONE_XDK)
			for k, x in { -1.1, -0.37, 0.37, 1.1 } do
				B:block(R, v(0.32, 0.44, 0.12), cf(PX + x, 9.75 + ((k % 2 == 0) and -0.08 or 0.08), z * 2.13), CREAM)
			end
		end
		-- dark recessed panels (front + back)
		B:block(R, v(2.0, 2.8, 0.12), cf(-3.0, 6.6, -D / 2 - 0.2), STONE_XDK)
		B:block(R, v(1.4, 2.2, 0.1), cf(-3.0, 6.5, -D / 2 - 0.26), STONE_DK)
		B:block(R, v(2.2, 1.6, 0.12), cf(0.6, 2.6, D / 2 + 0.2), STONE_XDK)
		-- a few lighter / darker brick faces
		B:block(R, v(1.4, 1.0, 0.1), cf(2.2, 2.2, -D / 2 - 0.2), STONE_LT)
		B:block(R, v(1.2, 0.9, 0.1), cf(-5.6, 4.6, D / 2 + 0.2), STONE_DK)
		B:block(R, v(1.0, 0.8, 0.1), cf(4.0, 4.6, -D / 2 - 0.2), STONE_DK)

		------------------------------------------------------------ moss
		local function cap(x, y, w, d, drips)
			B:block(R, v(w, 0.4, d), cf(x, y + 0.2, rnd(-0.1, 0.1)), MOSS)
			B:block(R, v(w * 0.6, 0.3, d * 0.7), cf(x + rnd(-0.4, 0.4), y + 0.5, rnd(-0.2, 0.2)), MOSS_LT)
			for _, dr in drips do
				B:block(R, v(dr[2], dr[3], 0.3), cf(x + dr[1], y - dr[3] / 2 + 0.3, dr[4] * (d / 2 + 0.05)), MOSS_DK)
			end
		end
		cap(-3.8, 10.1, 2.6, 3.2, { { 0.4, 0.8, 1.6, -1 } })
		cap(-1.75, 10.9, 1.8, 3.0, {})
		cap(-0.6, 8.1, 3.6, 3.2, { { -0.6, 1.0, 2.0, -1 }, { 0.8, 0.7, 1.1, 1 } })
		cap(2.15, 9.0, 1.6, 3.0, {})
		cap(3.0, 5.9, 3.2, 3.2, { { -0.3, 0.9, 1.5, -1 } })
		cap(5.4, 7.0, 1.8, 3.0, { { 0.2, 0.7, 1.2, 1 } })
		cap(6.6, 3.7, 1.8, 3.2, { { 0.0, 0.8, 1.4, -1 } })
		cap(PX + 0.2, 12.1, 3.0, 2.8, { { -0.8, 0.9, 1.4, -1 }, { 0.6, 0.8, 1.0, 1 } })
		-- leafy clumps on top
		for _, c in { { -4.2, 10.9, 0.3, 2.0, GREEN }, { -0.2, 9.2, -0.4, 1.8, GREEN_DK }, { 0.8, 9.0, 0.6, 1.4, GREEN_TOP },
			{ 3.6, 6.8, 0.2, 1.7, GREEN }, { PX + 0.9, 12.9, -0.2, 1.6, GREEN_TOP }, { 6.2, 4.5, -0.3, 1.3, GREEN_DK } } do
			B:block(R, v(c[4], c[4] * 0.8, c[4]), cf(c[1], c[2], c[3], rnd(-10, 10), rnd(0, 90), rnd(-10, 10)), c[5])
		end

		-- moss creeping over the faces
		B:block(R, v(2.6, 1.2, 0.2), cf(-5.4, 2.0, -D / 2 - 0.28), MOSS_DK)
		B:block(R, v(1.6, 0.8, 0.2), cf(3.6, 2.0, D / 2 + 0.28), MOSS)
		B:block(R, v(1.8, 1.0, 0.2), cf(PX - 0.6, 2.2, 2.2), MOSS_DK)
		B:block(R, v(0.2, 1.4, 1.8), cf(PX - 2.2, 2.4, -0.6), MOSS)
		-- leafy bushes hugging the foot of the wall
		for _, c in { { -2.6, -2.5, 2.2 }, { 4.8, -2.4, 1.9 }, { -4.6, 2.5, 2.0 }, { 1.6, 2.5, 1.7 } } do
			B:block(R, v(c[3], c[3] * 0.8, c[3]), cf(c[1], 0.3 + c[3] * 0.4, c[2], rnd(-6, 6), rnd(0, 90), rnd(-6, 6)), GREEN_DK)
			B:block(R, v(c[3] * 0.7, c[3] * 0.6, c[3] * 0.7), cf(c[1] + 0.3, 0.6 + c[3] * 0.8, c[2] + rnd(-0.2, 0.2), rnd(-8, 8), rnd(0, 90), 0), GREEN_TOP)
		end

		------------------------------------------------------------ vines
		local function vine(z, pts, leafEvery)
			local side = z < 0 and -1 or 1
			for i = 1, #pts - 1 do
				local a = v(pts[i][1], pts[i][2], z)
				local b = v(pts[i + 1][1], pts[i + 1][2], z)
				B:bar(R, a, b, 0.4, 0.4, GREEN_DK)
				if i % leafEvery == 0 or i == 1 then
					local m = (a + b) / 2
					B:block(R, v(0.9, 0.7, 0.25), CFrame.new(m + v(0.35, 0.1, side * 0.15)) * ang(0, 0, -30), (i % 2 == 0) and GREEN or GREEN_LT)
					B:block(R, v(0.8, 0.6, 0.25), CFrame.new(m + v(-0.35, -0.2, side * 0.15)) * ang(0, 0, 30), GREEN_TOP)
				end
			end
		end
		local zf, zb = -D / 2 - 0.35, D / 2 + 0.35
		vine(zf, { { -4.6, 1.4 }, { -5.2, 3.6 }, { -4.2, 5.6 }, { -4.9, 7.8 }, { -4.0, 10.2 } }, 1)
		vine(zf, { { 1.0, 1.4 }, { 1.8, 3.4 }, { 0.6, 5.2 }, { 1.1, 7.0 }, { 0.2, 8.3 } }, 2)
		vine(zf, { { 5.4, 1.4 }, { 4.6, 3.2 }, { 5.0, 5.9 } }, 1)
		vine(zb, { { -2.0, 1.4 }, { -1.2, 3.8 }, { -2.2, 6.2 }, { -1.4, 8.3 } }, 1)
		vine(zb, { { 3.8, 1.4 }, { 3.0, 3.6 }, { 4.0, 5.9 } }, 2)
		-- little pink snapper buds on the vines
		for _, b in { { -5.2, 3.6, zf }, { -4.0, 9.9, zf }, { 1.8, 3.4, zf }, { -1.2, 3.8, zb }, { 4.0, 5.7, zb } } do
			B:block(R, v(0.6, 0.55, 0.5), cf(b[1] + 0.25, b[2] + 0.25, b[3] + (b[3] < 0 and -0.2 or 0.2), 0, 0, 15), "#c92a48")
			B:block(R, v(0.4, 0.2, 0.42), cf(b[1] + 0.25, b[2] + 0.6, b[3] + (b[3] < 0 and -0.2 or 0.2), 0, 0, 15), "#ff5c7c")
		end
		-- hanging strands from the top edges
		B:bar(R, v(-1.4, 8.3, zf), v(-1.6, 5.4, zf - 0.1), 0.3, 0.3, GREEN_DK)
		B:block(R, v(0.7, 0.6, 0.22), cf(-1.6, 5.3, zf - 0.2, 0, 0, 20), GREEN_LT)
		B:bar(R, v(2.6, 9.0, zb), v(2.4, 6.6, zb + 0.1), 0.3, 0.3, GREEN_DK)

		------------------------------------------------------------ rubble + plants
		B:block(R, v(2.4, 1.6, 2.0), cf(8.6, 0.95, -1.0, 4, 24, -8), STONE)
		B:block(R, v(1.6, 1.1, 1.4), cf(8.0, 2.2, -0.7, 10, 50, 6), STONE_LT)
		B:block(R, v(1.8, 1.2, 1.6), cf(7.4, 0.75, 2.6, -6, -18, 4), STONE_DK)
		B:block(R, v(1.0, 0.7, 0.9), cf(-9.0, 0.5, 1.6, 0, 30, 0), STONE)
		B:block(R, v(0.8, 0.5, 0.7), cf(3.6, 0.55, -3.2, 0, 60, 0), STONE_LT)
		B:block(R, v(1.2, 0.8, 1.1), cf(-2.0, 0.6, 3.4, 0, -35, 5), STONE_DK)
		B:block(R, v(1.6, 0.25, 1.3), cf(8.7, 1.85, -1.1, 4, 24, -8), MOSS)
		for _, g in { { -8.8, -2.4 }, { 9.6, 0.8 }, { -0.4, -3.4 }, { 4.6, 3.6 }, { -5.4, 3.4 } } do
			B:block(R, v(0.42, 1.2, 0.42), cf(g[1], 0.7, g[2], 0, 20, 8), GRASS)
			B:block(R, v(0.34, 0.8, 0.34), cf(g[1] + 0.36, 0.55, g[2] + 0.16, 0, 40, -12), GRASS_DK)
		end
		local function fern(x, z, yaw, len)
			local fr = CFrame.new(x, 0.5, z) * CFrame.Angles(0, rad(yaw), 0) * CFrame.Angles(rad(28), 0, 0)
			B:block(R, v(0.3, 0.3, len), fr * CFrame.new(0, 0, -len / 2), GREEN_DK)
			for i = 1, 3 do
				B:block(R, v(2.1 - 0.4 * i, 0.2, 0.55), fr * CFrame.new(0, 0.05, -len * 0.22 * i - 0.2), i % 2 == 1 and GREEN or GREEN_LT)
			end
		end
		fern(-6.0, -2.6, 20, 2.8)
		fern(2.8, -2.6, -30, 2.6)
		fern(-6.4, 2.8, 170, 2.6)
		fern(5.6, 2.8, -160, 2.4)
	end,
}
