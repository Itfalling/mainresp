--!nocheck
-- Giant Snapper Bush (Snap-Jaw Jungle scenery, big copy-paste filler).
-- A big rounded jungle bush built from chunky rotated leaf cubes (dark base
-- ring, mid layer, light crown with lime highlight cubes), stepped leaf
-- blades fanning out at the foot, and five flytrap heads on thick stems
-- snapping out of the foliage in every direction - same trap design as the
-- Baby Snapper / Flytrap Stage plants (pink pads, red lips, stepped green
-- lobes, interlocking cream teeth, dark throat), one with a tiny glowing lime
-- drop. Low bog-dirt footing with moss, stones and tufts.
-- Anchored, weld-free, no scripts or effects.
return {
	DisplayName = "Giant Snapper Bush",
	Rarity = "Scenery",
	Filler = true,
	Element = "Snap-Jaw Jungle",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		local DIRT_DK, DIRT_DK2, DIRT = "#3f2516", "#4d2d1a", "#6a4126"
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local GREEN, GREEN_DK, GREEN_LT, GREEN_TOP = "#3caa3c", "#1f6e2a", "#a6e04c", "#58c447"
		local INSIDE, INSIDE_DK, RIM, THROAT = "#ff5c7c", "#b02448", "#c92a48", "#5c0f25"
		local CREAM, LIME = "#fff4d2", "#86ff3c"

		local seed = 4127
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		------------------------------------------------------------ footing
		B:block(R, v(14.0, 0.3, 9.4), cf(0, 0.15, 0), DIRT_DK)
		B:block(R, v(9.4, 0.29, 14.0), cf(0, 0.145, 0), DIRT_DK)
		B:block(R, v(11.6, 0.28, 11.6), cf(0, 0.14, 0, 0, 45, 0), DIRT_DK2)
		for _, e in { { 30, 7.0, DIRT_DK2 }, { 120, 7.2, DIRT }, { 205, 6.9, DIRT_DK }, { 300, 7.1, DIRT_DK2 } } do
			local a = rad(e[1])
			B:block(R, v(2.0, 0.34, 1.1), CFrame.new(math.sin(a) * e[2], 0.17, -math.cos(a) * e[2]) * CFrame.Angles(0, -a + rad(10), 0), e[3])
		end
		B:block(R, v(3.0, 0.2, 1.6), cf(-4.4, 0.36, -4.0, 0, 20, 0), MOSS)
		B:block(R, v(2.4, 0.2, 1.4), cf(4.8, 0.35, 3.8, 0, -25, 0), MOSS_DK)
		B:block(R, v(1.6, 1.0, 1.4), cf(5.9, 0.6, -2.8, 0, 30, 0), STONE)
		B:block(R, v(1.0, 0.5, 0.9), cf(5.95, 1.3, -2.8, 0, 55, 0), STONE_LT)
		B:block(R, v(1.1, 0.6, 1.0), cf(-6.0, 0.4, 2.6, 0, -20, 0), STONE_DK)
		for _, g in { { -6.2, -1.4 }, { 2.4, -6.0 }, { 6.4, 1.0 }, { -2.2, 6.0 } } do
			B:block(R, v(0.42, 1.2, 0.42), cf(g[1], 0.7, g[2], 0, 20, 8), GRASS)
			B:block(R, v(0.34, 0.8, 0.34), cf(g[1] + 0.36, 0.55, g[2] + 0.16, 0, 40, -12), GRASS_DK)
		end

		------------------------------------------------------------ bush body
		B:block(R, v(7.0, 4.6, 7.0), cf(0, 2.6, 0, 0, 20, 0), GREEN_DK)
		-- dark base ring
		for i = 0, 7 do
			local a = rad(i * 45 + rnd(-8, 8))
			local s = rnd(3.4, 4.2)
			B:block(R, v(s, s * 0.85, s), CFrame.new(math.sin(a) * 3.8, 2.0, -math.cos(a) * 3.8) * ang(rnd(-8, 8), rnd(0, 90), rnd(-8, 8)), (i % 3 == 1) and GREEN or GREEN_DK)
		end
		-- mid layer
		for i = 0, 5 do
			local a = rad(i * 60 + 25 + rnd(-8, 8))
			local s = rnd(3.8, 4.6)
			B:block(R, v(s, s * 0.9, s), CFrame.new(math.sin(a) * 2.6, 4.3, -math.cos(a) * 2.6) * ang(rnd(-10, 10), rnd(0, 90), rnd(-10, 10)), (i % 2 == 0) and GREEN or GREEN_TOP)
		end
		-- bulges that round the dome out
		for i = 0, 4 do
			local a = rad(i * 72 + 50 + rnd(-10, 10))
			local s = rnd(3.0, 3.6)
			B:block(R, v(s, s * 0.8, s), CFrame.new(math.sin(a) * 4.3, 3.4, -math.cos(a) * 4.3) * ang(rnd(-12, 12), rnd(0, 90), rnd(-12, 12)), (i % 2 == 0) and GREEN_TOP or GREEN)
		end
		-- closed snapper buds peeking out of the foliage
		for _, b in { { 20, 3.0 }, { 120, 4.6 }, { 200, 2.8 }, { 280, 4.2 } } do
			local a = rad(b[1])
			local F = CFrame.new(math.sin(a) * 6.0, b[2], -math.cos(a) * 6.0) * CFrame.Angles(0, -a, 0) * CFrame.Angles(rad(30), 0, 0)
			B:block(R, v(1.7, 0.9, 2.2), F * CFrame.new(0, 0.5, 0), GREEN_TOP)
			B:block(R, v(1.7, 0.9, 2.2), F * CFrame.new(0, -0.5, 0), GREEN)
			B:block(R, v(1.85, 0.3, 2.35), F, RIM)
		end
		-- crown
		for i = 0, 2 do
			local a = rad(i * 120 + 70)
			local s = rnd(3.4, 4.0)
			B:block(R, v(s, s * 0.85, s), CFrame.new(math.sin(a) * 1.2, 6.4, -math.cos(a) * 1.2) * ang(rnd(-8, 8), rnd(0, 90), rnd(-8, 8)), GREEN_TOP)
		end
		B:block(R, v(2.2, 1.6, 2.2), cf(-0.4, 8.2, 0.3, 0, 30, 0), GREEN_LT)
		B:block(R, v(1.6, 1.2, 1.6), cf(2.4, 6.9, -1.6, 0, 10, 0), GREEN_LT)
		B:block(R, v(1.5, 1.1, 1.5), cf(-2.6, 5.9, -2.4, 0, 50, 0), GREEN_LT)

		-- leaf blades fanning from the foot
		local function blade(a, len, w, up, col)
			local f = CFrame.new(math.sin(rad(a)) * 4.8, 0.6, -math.cos(rad(a)) * 4.8) * CFrame.Angles(0, -rad(a), 0) * CFrame.Angles(rad(up), 0, 0)
			B:block(R, v(w, 0.26, len * 0.6), f * CFrame.new(0, 0, -len * 0.28), col)
			B:block(R, v(0.26, 0.34, len * 0.62), f * CFrame.new(0, 0.04, -len * 0.33), GREEN_LT)
			local f2 = f * CFrame.new(0, 0, -len * 0.55) * CFrame.Angles(rad(-30), 0, 0)
			B:block(R, v(w * 0.64, 0.26, len * 0.4), f2 * CFrame.new(0, 0, -len * 0.18), col)
		end
		for i, a in { 15, 75, 135, 195, 255, 320 } do
			blade(a + rnd(-10, 10), rnd(2.8, 3.4), 1.3, 26, (i % 2 == 0) and GREEN or GREEN_TOP)
		end

		------------------------------------------------------------ flytrap heads
		local tw = 0.34
		local function trap(a, r, y, tilt, open, s, drop)
			local base = v(math.sin(rad(a)) * (r - 2.4), y - 3.4, -math.cos(rad(a)) * (r - 2.4))
			local hp = v(math.sin(rad(a)) * r, y, -math.cos(rad(a)) * r)
			-- stem from inside the foliage
			B:bar(R, base, hp + v(0, -0.4, 0), 1.0, 1.0, GREEN_DK)
			B:block(R, v(1.5, 0.4, 1.5), CFrame.new(hp + v(0, -0.6, 0)) * ang(0, a, 0), GREEN_LT)
			local T = CFrame.new(hp) * CFrame.Angles(0, -rad(a), 0) * CFrame.Angles(rad(tilt), 0, 0)
			local TL = T * CFrame.Angles(rad(open), 0, 0)
			local function bk(F, sx, sy, sz, x, y2, z, col, rx, rz, opts)
				return B:block(R, v(sx * s, sy * s, sz * s), F * CFrame.new(x * s, y2 * s, z * s) * ang(rx or 0, 0, rz or 0), col, opts)
			end
			for _, k in { -1, 1 } do
				local F = k > 0 and TL or T
				bk(F, 3.8, 0.2, 3.2, 0, 0.12 * k, -1.9, INSIDE)
				bk(F, 4.6, 0.3, 3.6, 0, 0.3 * k, -1.8, RIM)
				bk(F, 4.4, 0.7, 3.4, 0, 0.75 * k, -1.8, k > 0 and GREEN or GREEN_DK)
				bk(F, 5.0, 0.6, 2.0, 0, 0.75 * k, -1.8, k > 0 and GREEN_DK or GREEN)
				bk(F, 3.2, 0.6, 0.5, 0, 0.72 * k, -3.6, GREEN_DK)
				bk(F, 3.0, 0.5, 2.4, 0, 1.3 * k, -1.7, k > 0 and GREEN_TOP or GREEN_DK)
				-- cilia teeth (rows offset so they interlock)
				local xs = k < 0 and { -1.4, 0, 1.4 } or { -0.7, 0.7 }
				for _, x in xs do
					B:block(R, v(tw, 1.4 * s, tw), F * CFrame.new(x * s, -0.4 * k * s, -3.8 * s) * ang(22 * k, 0, 0), CREAM)
				end
				if k < 0 then
					for _, sd in { -1, 1 } do
						B:block(R, v(tw, 1.3 * s, tw), F * CFrame.new(sd * 2.5 * s, 0.35 * s, -2.2 * s) * ang(0, 0, -22 * sd), CREAM)
					end
				end
			end
			bk(TL, 0.4, 0.3, 2.2, 0, 1.58, -1.7, GREEN_LT)
			bk(T, 3.4, 1.0, 0.3, 0, 0.35, 0.0, THROAT)
			bk(T, 2.6, 1.2, 1.2, 0, -0.5, 0.4, GREEN_DK)
			bk(T, 1.2, 0.1, 2.0, 0, 0.24, -1.8, INSIDE_DK)
			if drop then
				local lip = (T * CFrame.new(1.0 * s, -0.4 * s, -3.6 * s)).Position
				B:block(R, v(0.22, 0.45, 0.22), CFrame.new(lip + v(0, -0.25, 0)), LIME, { mat = "Neon" })
			end
		end
		trap(-25, 5.6, 6.6, 8, 55, 0.95, true)
		trap(68, 5.4, 8.8, 16, 50, 0.9, false)
		trap(150, 5.6, 6.8, 8, 58, 0.92, false)
		trap(235, 5.2, 9.0, 16, 52, 0.9, false)
		trap(330, 2.4, 11.0, 34, 50, 0.85, false)
	end,
}
