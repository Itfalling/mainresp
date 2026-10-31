--!nocheck
-- Mossy Roots (Snap-Jaw Jungle filler, v2).
-- A gnarled clump of chunky jungle roots on a low mossy dirt patch:
-- * a stepped, pixel-round bark knot (dark foot, main tier, light knob) with
--   dark grain strips, a two-tone moss cap and a moss patch on the shoulder
-- * six roots in three sizes, each three tapering segments that hump up out
--   of the knot and dive back into the soil, with a light top highlight
--   strip, a dark knuckle at the bend and moss pads on some knees
-- * three little stepped pink toadstools (one with a tiny glowing lime
--   spot), a fern
--   sprout, flat stones and tufts
-- Lightweight scenery meant to be copy-pasted many times: anchored,
-- weld-free, no scripts or effects.
return {
	DisplayName = "Mossy Roots",
	Rarity = "Filler",
	Filler = true,
	Element = "Snap-Jaw Jungle",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Snap-Jaw Jungle: SnapjawFlytrap roots, DecorJungleShrooms)
		local DIRT_DK, DIRT_DK2, DIRT = "#3f2516", "#4d2d1a", "#6a4126"
		local ROOT, ROOT_DK, ROOT_LT, ROOT_TIP = "#8b5a31", "#5a361d", "#a87244", "#d9b07a"
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local GREEN, GREEN_LT = "#3caa3c", "#9fd84a"
		local PINK, PINK_DK, CREAM, CREAM_DK = "#ff6d8a", "#e8456a", "#fff4d2", "#e8d7a8"
		local LIME = "#a6ff3c"

		local function bar(a, b, w, h, col, ext, up)
			local c, len = P.aim(a, b, up)
			ext = ext or 0.2
			B:block(R, v(w, h, len + 2 * ext), c, col)
			return c, len
		end

		------------------------------------------------------------ footing
		B:block(R, v(5.6, 0.22, 3.5), cf(0, 0.11, 0), DIRT_DK)
		B:block(R, v(3.5, 0.21, 5.6), cf(0, 0.105, 0), DIRT_DK)
		B:block(R, v(4.7, 0.2, 4.7), cf(0, 0.1, 0, 0, 45, 0), DIRT_DK2)
		B:block(R, v(2.4, 0.15, 1.6), cf(0.9, 0.27, -1.0, 0, 20, 0), MOSS)
		B:block(R, v(1.6, 0.15, 1.4), cf(-1.2, 0.27, 1.0, 0, -15, 0), MOSS_DK)
		B:block(R, v(1.2, 0.14, 0.9), cf(-1.3, 0.26, -1.2, 0, 35, 0), DIRT)
		B:block(R, v(0.8, 0.3, 0.7), cf(2.2, 0.22, 1.1, 0, 25, 0), STONE)
		B:block(R, v(0.45, 0.2, 0.4), cf(2.25, 0.45, 1.05, 0, 50, 0), STONE_LT)
		B:block(R, v(0.7, 0.28, 0.6), cf(-2.2, 0.2, -0.2, 0, -30, 0), STONE_DK)
		for _, g in { { 1.6, -2.1 }, { -0.4, 2.3 } } do
			B:block(R, v(0.26, 0.7, 0.26), cf(g[1], 0.42, g[2], 0, 20, 9), GRASS)
			B:block(R, v(0.22, 0.48, 0.22), cf(g[1] + 0.2, 0.34, g[2] + 0.1, 0, 40, -12), GRASS_DK)
		end

		------------------------------------------------------------ knot
		-- stepped pixel-round tiers: square + 45-degree square
		local function tier(y, h, w, col, colB, yaw)
			B:block(R, v(w, h, w * 0.9), cf(0, y + h / 2, 0, 0, yaw, 0), col)
			B:block(R, v(w * 0.9, h + 0.02, w * 0.8), cf(0, y + h / 2, 0, 0, yaw + 45, 0), colB)
		end
		tier(0.15, 0.75, 2.0, ROOT_DK, ROOT_DK, 10)
		tier(0.85, 0.95, 1.55, ROOT, ROOT_DK, 20)
		tier(1.75, 0.45, 1.1, ROOT_LT, ROOT, 5)
		-- bark grain strips
		for _, g in { { 0, 1.3 }, { 120, 1.2 }, { 240, 1.35 } } do
			local a = rad(g[1] + 20)
			B:block(R, v(0.22, 0.8, 0.18), cf(math.sin(a) * 0.8, g[2], -math.cos(a) * 0.83, 0, -g[1] - 20, 0), ROOT_DK)
		end
		-- moss cap with a drip down the front-right
		B:block(R, v(1.25, 0.22, 1.05), cf(0.1, 2.28, 0, 0, 30, 0), MOSS)
		B:block(R, v(0.75, 0.2, 0.65), cf(-0.1, 2.44, 0.1, 0, 60, 0), GREEN_LT)
		B:block(R, v(1.0, 0.25, 0.6), cf(-0.55, 1.88, 0.45, 0, -30, 0), MOSS_DK)

		------------------------------------------------------------ roots
		-- yaw, knee distance, knee height, reach, size, roll, moss?
		local roots = {
			{ 10, 1.6, 1.4, 3.0, 1.0, 0.3, true },
			{ 82, 1.4, 1.05, 2.4, 0.8, -0.3, false },
			{ 148, 1.65, 1.45, 3.1, 1.0, 0.25, true },
			{ 218, 1.4, 1.1, 2.5, 0.85, -0.35, false },
			{ 288, 1.55, 1.3, 2.9, 0.95, 0.3, true },
		}
		for _, r in roots do
			local a = rad(r[1])
			local dir = v(math.sin(a), 0, -math.cos(a))
			local side = v(math.cos(a), 0, math.sin(a))
			local up = v(0, 1, 0) + side * r[6]
			local sz = r[5]
			local p0 = dir * 0.6 + v(0, 0.75, 0)
			local p1 = dir * r[2] + v(0, r[3], 0)
			local pm = dir * ((r[2] + r[4]) / 2 + 0.2) + v(0, r[3] * 0.55, 0) + side * 0.18
			local p2 = dir * r[4] + v(0, 0.3, 0)
			local c1, l1 = bar(p0, p1, 0.85 * sz, 0.75 * sz, ROOT, 0.25, up)
			local c2, l2 = bar(p1, pm, 0.7 * sz, 0.64 * sz, ROOT, 0.22, up)
			bar(pm, p2, 0.56 * sz, 0.5 * sz, ROOT_DK, 0.2, up)
			-- light highlight strip along the top of the arch
			B:block(R, v(0.3 * sz, 0.1, l1 * 0.7), c1 * CFrame.new(0, 0.38 * sz, -l1 * 0.1), ROOT_LT)
			B:block(R, v(0.24 * sz, 0.1, l2 * 0.6), c2 * CFrame.new(0, 0.33 * sz, 0), ROOT_LT)
			if r[7] then
				B:block(R, v(0.8 * sz, 0.2, 1.0), CFrame.new(p1) * (c2 - c2.Position) * CFrame.new(0, 0.4 * sz, 0.05), MOSS_DK)
				B:block(R, v(0.5 * sz, 0.18, 0.55), CFrame.new(p1) * (c2 - c2.Position) * CFrame.new(0.04, 0.55 * sz, 0.05), MOSS)
			end
		end

		------------------------------------------------------------ toadstools
		local function toad(p, h, w, yaw, spotNeon)
			local c = CFrame.new(p) * ang(0, yaw, 0)
			B:block(R, v(0.45, 0.22, 0.45), c * CFrame.new(0, 0.11, 0), CREAM_DK)
			B:block(R, v(0.3, h, 0.3), c * CFrame.new(0, h / 2, 0), CREAM)
			-- stepped cap: dark rim, main, lighter crown, spot
			B:block(R, v(w, 0.22, w), c * CFrame.new(0, h, 0), PINK_DK)
			B:block(R, v(w * 0.86, 0.24, w * 0.86), c * CFrame.new(0, h + 0.18, 0) * ang(0, 45, 0), PINK)
			B:block(R, v(w * 0.55, 0.2, w * 0.55), c * CFrame.new(0, h + 0.36, 0), PINK)
			B:block(R, v(0.18, 0.1, 0.18), c * CFrame.new(w * 0.3, h + 0.27, 0), CREAM)
			if spotNeon then
				B:block(R, v(0.16, 0.1, 0.16), c * CFrame.new(0.05, h + 0.5, -0.05), LIME, { mat = "Neon" })
			end
		end
		toad(v(-0.9, 0.25, -1.65), 0.95, 0.95, 20, true)
		toad(v(-1.55, 0.25, -1.05), 0.55, 0.6, 50, false)
		toad(v(1.75, 0.25, 1.35), 0.4, 0.45, 10, false)

		------------------------------------------------------------ sprout
		B:bar(R, v(0.15, 2.4, 0.1), v(0.35, 3.05, 0.05), 0.16, 0.16, GREEN)
		B:block(R, v(0.5, 0.12, 0.28), cf(0.55, 3.0, 0.05, 0, 0, -20), GREEN_LT)
		B:block(R, v(0.45, 0.12, 0.26), cf(0.15, 2.9, 0.05, 0, 0, 25), GREEN)
		-- light root tip poking out of the soil
		B:block(R, v(0.3, 0.3, 0.5), cf(1.9, 0.3, -1.6, 20, 40, 0), ROOT_TIP)
	end,
}
