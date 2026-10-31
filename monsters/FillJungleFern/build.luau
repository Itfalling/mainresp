--!nocheck
-- Jungle Fern (Snap-Jaw Jungle filler, v2).
-- A lush clump of chunky jungle fern on a low mossy footing:
-- * six arching fronds in three sizes; each frond is a dark midrib in three
--   segments (rise, crest, droop) with paired leaflets swept toward the tip
--   and drooping slightly, shading from green at the base through bright
--   green to lime at the tip
-- * a stepped dark root crown and two curled fiddleheads unrolling in the
--   middle, each hiding one tiny glowing lime bud in its curl
-- * a low pixel-round dirt patch with two moss tones, flat stones and tufts
-- Lightweight scenery meant to be copy-pasted many times: anchored,
-- weld-free, no scripts or effects.
return {
	DisplayName = "Jungle Fern",
	Rarity = "Filler",
	Filler = true,
	Element = "Snap-Jaw Jungle",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Snap-Jaw Jungle crops / DecorJungleShrooms)
		local DIRT_DK, DIRT_DK2, DIRT = "#3f2516", "#4d2d1a", "#6a4126"
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local GREEN, GREEN_DK, GREEN_LT, GREEN_TOP = "#3caa3c", "#1f6e2a", "#9fd84a", "#58c447"
		local LIME = "#a6ff3c"

		local function bar(a, b, w, h, col, ext)
			local c, len = P.aim(a, b)
			ext = ext or 0.12
			B:block(R, v(w, h, len + 2 * ext), c, col)
			return c, len
		end

		------------------------------------------------------------ footing
		B:block(R, v(4.2, 0.22, 2.6), cf(0, 0.11, 0), DIRT_DK)
		B:block(R, v(2.6, 0.21, 4.2), cf(0, 0.105, 0), DIRT_DK)
		B:block(R, v(3.5, 0.2, 3.5), cf(0, 0.1, 0, 0, 45, 0), DIRT_DK2)
		B:block(R, v(2.8, 0.16, 1.9), cf(0.3, 0.28, -0.2, 0, 12, 0), MOSS)
		B:block(R, v(1.6, 0.15, 1.5), cf(-0.8, 0.27, 0.9, 0, -25, 0), MOSS_DK)
		B:block(R, v(1.0, 0.14, 0.8), cf(1.2, 0.26, 1.1, 0, 30, 0), DIRT)
		-- chunky edge clods so the rim isn't a perfect outline
		for _, e in { { 50, 2.05, DIRT_DK2 }, { 165, 2.1, DIRT_DK }, { 245, 2.0, DIRT }, { 320, 2.1, DIRT_DK2 } } do
			local a = rad(e[1])
			B:block(R, v(1.0, 0.3, 0.65), CFrame.new(math.sin(a) * e[2], 0.15, -math.cos(a) * e[2]) * CFrame.Angles(0, -a + rad(8), 0), e[3])
		end
		-- flat stones
		B:block(R, v(0.9, 0.35, 0.75), cf(1.9, 0.25, 0.5, 0, 25, 0), STONE)
		B:block(R, v(0.5, 0.2, 0.45), cf(1.95, 0.5, 0.45, 0, 50, 0), STONE_LT)
		B:block(R, v(0.8, 0.3, 0.65), cf(-1.7, 0.2, -1.0, 0, -20, 0), STONE_DK)
		-- grass tufts
		for _, g in { { -1.9, 0.6 }, { 0.9, -1.9 } } do
			B:block(R, v(0.28, 0.75, 0.28), cf(g[1], 0.45, g[2], 0, 20, 8), GRASS)
			B:block(R, v(0.24, 0.5, 0.24), cf(g[1] + 0.22, 0.35, g[2] + 0.1, 0, 40, -12), GRASS_DK)
		end

		------------------------------------------------------------ crown
		B:block(R, v(1.2, 0.45, 1.2), cf(0, 0.4, 0), DIRT_DK2)
		B:block(R, v(1.1, 0.46, 1.1), cf(0, 0.4, 0, 0, 45, 0), DIRT)
		B:block(R, v(0.9, 0.45, 0.9), cf(0, 0.75, 0, 0, 20, 0), GREEN_DK)

		------------------------------------------------------------ fronds
		-- leaflet pair at fraction t along a rib segment (frame c, length len)
		local function pair(c, len, t, ll, col)
			local base = c * CFrame.new(0, 0.06, len * (0.5 - t))
			for _, sd in { -1, 1 } do
				local f = base * ang(0, sd * 28, 0) * ang(0, 0, -sd * 12) * CFrame.new(sd * (ll / 2 + 0.1), 0, 0)
				B:block(R, v(ll, 0.2, 0.5), f, col)
			end
		end
		-- yaw, length, rise, leaflet scale, base leaflet tone (back fronds darker)
		local fronds = {
			{ 15, 3.3, 2.6, 1.0, GREEN },
			{ 75, 2.5, 1.9, 0.8, GREEN_DK },
			{ 135, 3.1, 2.4, 0.95, GREEN },
			{ 195, 2.6, 2.9, 0.85, GREEN_TOP },
			{ 255, 3.4, 2.3, 1.0, GREEN },
			{ 315, 2.4, 2.1, 0.75, GREEN_DK },
		}
		for _, f in fronds do
			local a = rad(f[1])
			local dir = v(math.sin(a), 0, -math.cos(a))
			local L, H, S = f[2], f[3], f[4]
			local p0 = v(0, 0.8, 0) + dir * 0.25
			local p1 = dir * (L * 0.25) + v(0, H, 0)
			local p2 = dir * (L * 0.68) + v(0, H * 1.08, 0)
			local p3 = dir * L + v(0, H * 0.45, 0)
			local c1, l1 = bar(p0, p1, 0.26, 0.26, GREEN_DK)
			local c2, l2 = bar(p1, p2, 0.24, 0.24, GREEN_DK)
			local c3, l3 = bar(p2, p3, 0.22, 0.22, GREEN_DK)
			pair(c1, l1, 0.8, 0.75 * S, f[5])
			pair(c2, l2, 0.3, 1.0 * S, f[5] == GREEN_DK and GREEN or f[5])
			pair(c2, l2, 0.8, 0.9 * S, GREEN_TOP)
			pair(c3, l3, 0.3, 0.7 * S, GREEN_TOP)
			pair(c3, l3, 0.75, 0.45 * S, GREEN_LT)
			-- lime tip
			B:block(R, v(0.3, 0.22, 0.5), c3 * CFrame.new(0, 0.02, -l3 / 2), GREEN_LT)
		end

		------------------------------------------------------------ fiddleheads
		for _, fh in { { v(0.2, 0.9, 0.15), 2.2, 0, GREEN }, { v(-0.25, 0.9, -0.15), 1.7, 140, GREEN_TOP } } do
			local top = fh[1] + v(0, fh[2], 0)
			local yaw = fh[3]
			bar(fh[1], top, 0.26, 0.26, fh[4], 0.1)
			local c = CFrame.new(top) * ang(0, yaw, 0)
			B:block(R, v(0.32, 0.32, 0.5), c * CFrame.new(0, 0.05, -0.15), GREEN_LT)
			B:block(R, v(0.3, 0.42, 0.3), c * CFrame.new(0, -0.15, -0.42), GREEN_TOP)
			-- tiny glowing lime bud in the curl (jungle glow accent)
			B:block(R, v(0.16, 0.16, 0.16), c * CFrame.new(0, -0.3, -0.24), LIME, { mat = "Neon" })
		end
	end,
}
