--!nocheck
-- Bunny Topiary (Bunny Meadow scenery, ~15 studs). A big party hedge clipped
-- into a sitting bunny, in a purple VIP planter with gold trim. Faces -Z.
-- * planter: dark purple foot, purple body with lighter corner pillars and
--   dark panel insets, a gold diamond badge front and back, gold rim with a
--   dark lip, light top edge and corner studs; the only glow is two thin pink
--   neon trim lines under the rim and the bunny's little neon nose
-- * bunny: stepped rounded body (shadow / main / light greens), hind thighs
--   and long hind feet, front paws, a lighter clipped chest, a big round head
--   with a light muzzle, glossy dark eyes, tall ears with pink blossom
--   insides, a fluffy pale tail and a pink party bow at the neck
-- * proud clipped leaf patches (squares + diamonds) on the body and head
-- * grounding: grass tufts and a pebble beside the planter
-- Scenery filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Bunny Topiary",
	Rarity = "Scenery",
	Filler = true,
	Element = "Bunny Meadow",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		-- Bunny Meadow palette (FillBunnyNeonBush / DecorBunnySpeaker / DecorBunnyRope)
		local LEAF_SH, LEAF_DK, LEAF, LEAF_LT, LEAF_HI = "#1d7232", "#2a8f3a", "#3aab46", "#5ccc50", "#7fe060"
		local PURP_DK, PURP, PURP_LT = "#4a1aa8", "#7e3cf0", "#a874ff"
		local GOLD_LT, GOLD, GOLD_DK = "#ffe27a", "#ffc62e", "#d9961a"
		local PINK_DK, PINK, PINK_LT = "#c41f86", "#ff3fb4", "#ff86d4"
		local DIRT = "#3f2516"
		local EYE, WHITE = "#142a1a", "#ffffff"
		local N_PINK = "#ff5cc8"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local STONE = "#8d8a9c"

		local function plus(x, y0, y1, z, w, d, col, rot)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(R, v(w, h, d * 0.72), cf(x, y, z, 0, rot or 0, 0), col)
			B:block(R, v(w * 0.72, h, d), cf(x, y, z, 0, rot or 0, 0), col)
		end

		------------------------------------------------------------ planter
		local PW = 7.6
		local PH = 2.0 -- planter body top
		B:block(R, v(PW + 0.3, 0.35, PW + 0.3), cf(0, 0.175, 0), PURP_DK)
		B:block(R, v(PW, PH - 0.3, PW), cf(0, (PH + 0.3) / 2, 0), PURP)
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			B:block(R, v(0.8, PH - 0.25, 0.8), cf(c[1] * (PW / 2 - 0.22), (PH + 0.3) / 2, c[2] * (PW / 2 - 0.22)), PURP_LT)
		end
		B:block(R, v(5.0, PH - 1.0, PW + 0.06), cf(0, PH / 2 + 0.05, 0), PURP_DK)
		B:block(R, v(PW + 0.06, PH - 1.0, 5.0), cf(0, PH / 2 + 0.05, 0), PURP_DK)
		-- gold badge front + back, small gold studs on the side panels
		for i, s in { -1, 1 } do
			B:block(R, v(0.8, 0.8, 0.14), cf(0, PH / 2 + 0.05, s * (PW / 2 + 0.06), 0, 0, 45), GOLD)
			B:block(R, v(0.36, 0.36, 0.14), cf(0, PH / 2 + 0.05, s * (PW / 2 + 0.12), 0, 0, 45), GOLD_LT)
			B:block(R, v(0.14, 0.5, 0.5), cf(s * (PW / 2 + 0.06), PH / 2 + 0.05, 0, 45, 0, 0), GOLD)
			B:block(R, v(5.8, 0.14, 0.1), cf(0, PH - 0.3, s * (PW / 2 + 0.04)), N_PINK, { mat = "Neon", name = "Trim" .. i })
		end
		B:block(R, v(PW + 0.44, 0.12, PW + 0.44), cf(0, PH + 0.02, 0), GOLD_DK)
		B:block(R, v(PW + 0.4, 0.38, PW + 0.4), cf(0, PH + 0.25, 0), GOLD)
		B:block(R, v(PW - 0.1, 0.06, PW - 0.1), cf(0, PH + 0.46, 0), GOLD_LT)
		B:block(R, v(PW - 0.7, 0.08, PW - 0.7), cf(0, PH + 0.5, 0), DIRT)
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			B:block(R, v(0.65, 0.34, 0.65), cf(c[1] * (PW / 2 - 0.05), PH + 0.6, c[2] * (PW / 2 - 0.05)), GOLD_LT)
		end
		local Y0 = PH + 0.5
		-- little flowers in the planter soil
		for i, f in { { -3.0, -2.9 }, { 2.9, -3.0 }, { 3.1, 2.4 }, { -2.9, 2.9 }, { 0.2, 3.25 } } do
			local col = (i % 2 == 0) and PINK_LT or GOLD_LT
			B:block(R, v(0.7, 0.35, 0.7), cf(f[1], Y0 + 0.2, f[2], 0, 45, 0), col)
			B:block(R, v(0.3, 0.38, 0.3), cf(f[1], Y0 + 0.24, f[2]), (i % 2 == 0) and GOLD or PINK)
		end

		------------------------------------------------------------ body
		local BZ = 0.5
		plus(0, Y0, Y0 + 0.8, BZ, 4.8, 4.8, LEAF_SH)
		plus(0, Y0 + 0.7, Y0 + 2.1, BZ, 5.7, 5.7, LEAF_DK, 0)
		plus(0, Y0 + 2.0, Y0 + 3.9, BZ, 6.1, 6.1, LEAF)
		plus(0, Y0 + 3.8, Y0 + 4.9, BZ, 5.3, 5.3, LEAF)
		plus(0, Y0 + 4.8, Y0 + 5.5, BZ - 0.3, 4.0, 3.8, LEAF_LT)
		-- lighter clipped chest
		B:block(R, v(3.2, 2.8, 0.4), cf(0, Y0 + 3.0, BZ - 3.1), LEAF_LT)
		B:block(R, v(2.2, 3.5, 0.4), cf(0, Y0 + 3.1, BZ - 3.05), LEAF_LT)
		B:block(R, v(1.2, 1.2, 0.14), cf(0, Y0 + 2.6, BZ - 3.32, 0, 0, 45), LEAF_HI)
		-- hind thighs + long hind feet
		for _, s in { -1, 1 } do
			local tx, tz = s * 2.55, BZ + 0.9
			plus(tx, Y0 + 0.4, Y0 + 1.9, tz, 2.4, 2.8, LEAF_DK)
			plus(tx, Y0 + 1.8, Y0 + 3.0, tz, 2.1, 2.5, LEAF)
			B:block(R, v(1.3, 0.2, 1.5), cf(tx, Y0 + 3.07, tz), LEAF_LT)
			B:block(R, v(1.4, 0.8, 2.8), cf(s * 2.45, Y0 + 0.4, BZ - 1.5), LEAF_DK)
			B:block(R, v(1.2, 0.3, 2.5), cf(s * 2.45, Y0 + 0.9, BZ - 1.55), LEAF)
			-- front paws
			B:block(R, v(1.1, 1.7, 1.1), cf(s * 0.95, Y0 + 0.85, BZ - 3.0), LEAF)
			B:block(R, v(1.25, 0.55, 1.3), cf(s * 0.95, Y0 + 0.27, BZ - 3.1), LEAF_LT)
		end

		------------------------------------------------------------ head
		local HZ = -1.3
		local HY = Y0 + 5.0
		plus(0, HY, HY + 0.8, HZ, 3.8, 3.6, LEAF_DK)
		plus(0, HY + 0.7, HY + 2.9, HZ, 5.4, 4.9, LEAF)
		plus(0, HY + 2.8, HY + 3.8, HZ, 4.6, 4.2, LEAF)
		plus(0, HY + 3.7, HY + 4.3, HZ, 3.3, 3.0, LEAF_LT)
		B:block(R, v(1.5, 0.2, 1.5), cf(0, HY + 4.38, HZ, 0, 45, 0), LEAF_HI)
		local FZ = HZ - 2.45 -- face plane
		-- muzzle + cheeks
		B:block(R, v(2.6, 1.3, 0.7), cf(0, HY + 1.3, FZ - 0.2), LEAF_LT)
		B:block(R, v(1.8, 1.7, 0.6), cf(0, HY + 1.35, FZ - 0.15), LEAF_LT)
		B:block(R, v(0.7, 0.45, 0.3), cf(0, HY + 1.85, FZ - 0.6), N_PINK, { mat = "Neon", name = "Nose" })
		B:block(R, v(0.14, 0.6, 0.2), cf(0, HY + 1.35, FZ - 0.56), LEAF_DK)
		-- glossy eyes
		for _, s in { -1, 1 } do
			B:block(R, v(0.7, 1.0, 0.2), cf(s * 1.3, HY + 2.35, FZ - 0.05), EYE)
			B:block(R, v(0.24, 0.28, 0.1), cf(s * 1.3 - 0.13, HY + 2.62, FZ - 0.17), WHITE)
			B:block(R, v(0.7, 0.4, 0.14), cf(s * 1.85, HY + 1.45, FZ - 0.03), PINK_LT)
		end

		------------------------------------------------------------ ears
		for _, s in { -1, 1 } do
			local base = CFrame.new(s * 1.25, HY + 3.6, HZ + 0.2) * CFrame.Angles(math.rad(-8), 0, math.rad(-s * 9))
			B:block(R, v(1.7, 1.1, 1.3), base * CFrame.new(0, 0.4, 0), LEAF_DK)
			B:block(R, v(1.5, 4.0, 1.1), base * CFrame.new(0, 2.4, 0), LEAF)
			B:block(R, v(1.15, 0.6, 0.9), base * CFrame.new(0, 4.65, 0), LEAF_LT)
			B:block(R, v(0.75, 3.0, 0.14), base * CFrame.new(0, 2.4, -0.57), PINK_LT)
			B:block(R, v(0.36, 2.1, 0.14), base * CFrame.new(0, 2.3, -0.63), PINK)
			B:block(R, v(0.14, 3.6, 1.0), base * CFrame.new(s * 0.76, 2.4, 0.05), LEAF_LT)
		end

		------------------------------------------------------------ tail + bow
		plus(0, Y0 + 1.6, Y0 + 2.6, BZ + 3.25, 2.0, 1.2, LEAF_LT)
		plus(0, Y0 + 1.9, Y0 + 3.0, BZ + 3.55, 1.4, 0.9, LEAF_HI)
		-- pink party bow at the neck
		local BY, BBZ = HY + 0.25, HZ - 1.95
		B:block(R, v(0.8, 0.8, 0.6), cf(0, BY, BBZ), PINK)
		for _, s in { -1, 1 } do
			B:block(R, v(1.4, 1.1, 0.5), cf(s * 1.0, BY + 0.1, BBZ + 0.05, 0, 0, s * 10), PINK_LT)
			B:block(R, v(0.55, 0.55, 0.52), cf(s * 1.2, BY + 0.14, BBZ + 0.03, 0, 0, s * 10), PINK_DK)
			B:bar(R, v(s * 0.2, BY - 0.3, BBZ - 0.1), v(s * 0.55, BY - 1.0, BBZ - 0.2), 0.4, 0.18, PINK)
		end
		B:block(R, v(0.4, 0.4, 0.14), cf(0, BY, BBZ - 0.32), PINK_LT)

		------------------------------------------------------------ leaf patches
		-- (face, u, y, size, colour, diamond?)  faces: R = +x, L = -x, Bk = +z
		local bodyPatches = {
			{ "R", -1.2, 4.6, 1.0, LEAF_LT, true },
			{ "R", 0.6, 5.3, 0.9, LEAF_DK, false },
			{ "R", 1.6, 4.3, 0.8, LEAF_LT, false },
			{ "L", -0.8, 5.2, 0.9, LEAF_LT, false },
			{ "L", 1.0, 4.5, 1.0, LEAF_DK, true },
			{ "L", 1.9, 5.5, 0.7, LEAF_LT, true },
			{ "Bk", -1.6, 5.0, 1.0, LEAF_DK, true },
			{ "Bk", 1.4, 5.4, 0.9, LEAF_LT, false },
			{ "Bk", 0.3, 6.2, 0.8, LEAF_LT, true },
			{ "Bk", -0.6, 3.3, 0.8, LEAF_DK, false },
		}
		local function patch(face, cx, cz, half, u, y, sz, col, dia)
			local rot = dia and 45 or 0
			sz *= 1.35
			local s2 = dia and sz * 0.75 or sz
			if face == "R" or face == "L" then
				local sx = (face == "R") and 1 or -1
				B:block(R, v(0.14, s2, s2), cf(cx + sx * (half + 0.05), y, cz + u, rot, 0, 0), col)
			else
				B:block(R, v(s2, s2, 0.14), cf(cx + u, y, cz + half + 0.05, 0, 0, rot), col)
			end
		end
		for _, p in bodyPatches do
			patch(p[1], 0, BZ, 3.05, p[2], Y0 + p[3] - 1.6, p[4], p[5], p[6])
		end
		local headPatches = {
			{ "R", -0.6, 2.0, 0.8, LEAF_LT, true },
			{ "R", 0.9, 1.4, 0.7, LEAF_DK, false },
			{ "L", 0.5, 2.2, 0.8, LEAF_LT, false },
			{ "L", -0.9, 1.3, 0.7, LEAF_DK, true },
			{ "Bk", -0.8, 1.8, 0.8, LEAF_LT, true },
			{ "Bk", 0.9, 2.3, 0.7, LEAF_DK, false },
		}
		for _, p in headPatches do
			patch(p[1], 0, HZ, (p[1] == "Bk") and 2.45 or 2.7, p[2], HY + p[3], p[4], p[5], p[6])
		end

		------------------------------------------------------------ grounding
		local function tuft(x, z, h, ry)
			local b = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(ry), 0)
			B:block(R, v(0.4, h, 0.4), b * CFrame.new(0, h / 2, 0), GRASS)
			B:block(R, v(0.35, h * 0.75, 0.35), b * CFrame.new(0.32, h * 0.36, 0.05) * CFrame.Angles(0, 0, math.rad(-20)), GRASS_DK)
			B:block(R, v(0.35, h * 0.65, 0.35), b * CFrame.new(-0.3, h * 0.32, -0.05) * CFrame.Angles(0, 0, math.rad(22)), GRASS)
		end
		tuft(4.55, -2.6, 0.9, 20)
		tuft(-4.5, 2.4, 0.8, -40)
		tuft(-2.0, -4.5, 0.7, 60)
		B:block(R, v(0.6, 0.26, 0.5), cf(-4.45, 0.13, -1.6, 0, 25, 0), STONE)
	end,
}
