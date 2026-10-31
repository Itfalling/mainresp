--!nocheck
-- Neon Hedge Cube (Bunny Meadow filler, v2). A neatly clipped party topiary
-- cube in a low purple VIP planter.
-- * hedge: bevelled cube (core + two crossed slabs = chamfered edges), dark
--   shadow band at the bottom, main green faces, light top with a domed
--   highlight; each face has a staggered pattern of slightly proud leaf
--   clusters in shadow / light greens, and the chamfered corners are darker
-- * planter: dark base, purple body with lighter purple corner pillars and a
--   panel inset, gold rim with light top edge and gold corner studs
-- * the only glow: two thin pink neon trim lines under the rim (front + back)
-- * grounding: two low grass tufts and a pebble
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Neon Hedge Cube",
	Rarity = "Filler",
	Filler = true,
	Element = "Bunny Meadow",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		-- Bunny Meadow palette (BunnyNeonLime / DecorBunnyRope / DecorBunnySign)
		local LEAF_SH, LEAF_DK, LEAF, LEAF_LT, LEAF_HI = "#1d7232", "#2a8f3a", "#3aab46", "#5ccc50", "#7fe060"
		local PURP_DK, PURP, PURP_LT = "#4a1aa8", "#7e3cf0", "#a874ff"
		local GOLD_LT, GOLD, GOLD_DK = "#ffe27a", "#ffc62e", "#d9961a"
		local N_PINK = "#ff5cc8"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local STONE = "#8d8a9c"

		------------------------------------------------------------ planter
		local PW = 3.6
		B:block(R, v(PW + 0.2, 0.25, PW + 0.2), cf(0, 0.125, 0), PURP_DK)
		B:block(R, v(PW, 0.75, PW), cf(0, 0.62, 0), PURP)
		-- lighter corner pillars + darker panel insets
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			B:block(R, v(0.45, 0.8, 0.45), cf(c[1] * (PW / 2 - 0.15), 0.62, c[2] * (PW / 2 - 0.15)), PURP_LT)
		end
		B:block(R, v(2.4, 0.4, PW + 0.06), cf(0, 0.6, 0), PURP_DK)
		B:block(R, v(PW + 0.06, 0.4, 2.4), cf(0, 0.6, 0), PURP_DK)
		-- neon trim lines (front + back) just under the rim
		for i, s in { -1, 1 } do
			B:block(R, v(3.0, 0.12, 0.1), cf(0, 0.86, s * (PW / 2 + 0.04)), N_PINK, { mat = "Neon", name = "Trim" .. i })
		end
		-- gold rim + light top edge + corner studs
		B:block(R, v(PW + 0.3, 0.28, PW + 0.3), cf(0, 1.14, 0), GOLD)
		B:block(R, v(PW + 0.34, 0.08, PW + 0.34), cf(0, 1.02, 0), GOLD_DK)
		B:block(R, v(PW - 0.3, 0.06, PW - 0.3), cf(0, 1.3, 0), GOLD_LT)
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			B:block(R, v(0.42, 0.24, 0.42), cf(c[1] * (PW / 2 - 0.02), 1.38, c[2] * (PW / 2 - 0.02)), GOLD_LT)
		end

		------------------------------------------------------------ hedge
		local Y0, Y1 = 1.28, 4.2
		local HW = 3.0 -- hedge width
		local H, Y = Y1 - Y0, (Y0 + Y1) / 2
		-- dark shadow band at the foot
		B:block(R, v(HW - 0.1, 0.45, HW - 0.7), cf(0, Y0 + 0.22, 0), LEAF_SH)
		B:block(R, v(HW - 0.7, 0.45, HW - 0.1), cf(0, Y0 + 0.22, 0), LEAF_SH)
		-- darker core shows at the chamfered corners
		B:block(R, v(HW - 0.35, H - 0.5, HW - 0.35), cf(0, Y + 0.05, 0), LEAF_DK)
		-- main faces (crossed slabs)
		B:block(R, v(HW, H - 0.75, HW - 0.6), cf(0, Y + 0.08, 0), LEAF)
		B:block(R, v(HW - 0.6, H - 0.75, HW), cf(0, Y + 0.08, 0), LEAF)
		-- light top, stepped dome highlight
		B:block(R, v(HW - 0.1, 0.35, HW - 0.7), cf(0, Y1 - 0.3, 0), LEAF_LT)
		B:block(R, v(HW - 0.7, 0.35, HW - 0.1), cf(0, Y1 - 0.3, 0), LEAF_LT)
		B:block(R, v(HW - 0.9, 0.18, HW - 0.9), cf(0, Y1 - 0.05, 0), LEAF_HI)
		B:block(R, v(1.1, 0.12, 1.1), cf(0.3, Y1 + 0.08, -0.2, 0, 45, 0), LEAF_HI)

		-- staggered leaf clusters, slightly proud, on all four faces
		-- (u = across the face, y = height, size, colour)
		local pattern = {
			{ -0.7, 2.0, 0.8, LEAF_DK }, { 0.55, 2.35, 0.9, LEAF_LT }, { -0.35, 3.15, 0.85, LEAF_LT },
			{ 0.75, 3.45, 0.7, LEAF_DK }, { 0.2, 1.75, 0.6, LEAF_DK },
		}
		local faces = { { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 0 } }
		for fi, f in faces do
			for k, p in pattern do
				-- shift the pattern per face so repeats don't line up
				local u = ((p[1] + fi * 0.45 + 1.1) % 2.2) - 1.1
				u = math.clamp(u, -1.0 + p[3] / 2, 1.0 - p[3] / 2)
				local d = HW / 2 + 0.04
				local x, z = f[1] * d + f[2] * u, f[2] * d - f[1] * u
				local sx = (f[1] == 0) and p[3] or 0.14
				local sz = (f[1] == 0) and 0.14 or p[3]
				-- every other cluster is a diamond (turned 45 degrees about the face normal)
				local rot = ((k + fi) % 2 == 0) and 45 or 0
				local rcf = (f[1] == 0) and CFrame.Angles(0, 0, math.rad(rot)) or CFrame.Angles(math.rad(rot), 0, 0)
				local sc = (rot == 45) and 0.75 or 1
				B:block(R, v(sx == 0.14 and 0.14 or sx * sc, p[3] * sc, sz == 0.14 and 0.14 or sz * sc), CFrame.new(x, p[2], z) * rcf, p[4])
			end
		end

		------------------------------------------------------------ grounding
		local function tuft(x, z, h, ry)
			local b = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(ry), 0)
			B:block(R, v(0.3, h, 0.3), b * CFrame.new(0, h / 2, 0), GRASS)
			B:block(R, v(0.26, h * 0.75, 0.26), b * CFrame.new(0.26, h * 0.36, 0.05) * CFrame.Angles(0, 0, math.rad(-20)), GRASS_DK)
			B:block(R, v(0.26, h * 0.65, 0.26), b * CFrame.new(-0.24, h * 0.32, -0.05) * CFrame.Angles(0, 0, math.rad(22)), GRASS)
		end
		tuft(2.2, -1.4, 0.7, 20)
		tuft(-2.15, 1.5, 0.6, -40)
		B:block(R, v(0.45, 0.2, 0.36), cf(-2.15, 0.1, -1.0, 0, 25, 0), STONE)
	end,
}
