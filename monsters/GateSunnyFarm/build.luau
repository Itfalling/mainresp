--!nocheck
-- Sunny Farm Gate (Map landmark, stage 1 gate). A grand barn-timber arch that
-- spans the whole 64-stud run lane.
-- * Two red barn towers (x = +-32..44) on stone footings: vertical barn boards in
--   three reds, white corner trim, white X-braced barn doors, a hay-loft door with
--   a bale peeking out, a little window, and a stepped red gable roof with a
--   white bargeboard and a ridge cap.
-- * A chunky red-board lintel with white trim bands and brown timber caps spans
--   between them. On its front sits the plain cream "Sign" in a chunky wood frame
--   (the map tool adds the stage name on its -Z face); the back carries a white
--   X-braced barn-door panel.
-- * Crown: a hay-bale pyramid bursting with sunflowers, topped by a copper rooster
--   weathervane with N/E/S/W arms; a white picket fence runs along the lintel top.
-- Opening: completely clear for |x| < 32, y < 19 (lintel bottom at 19.4).
-- Static Filler landmark: no scripts, no effects.
return {
	DisplayName = "Sunny Farm Gate",
	Rarity = "Landmark",
	Filler = true,
	Element = "Sunny Farm",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		local RED, RED_DK, RED_LT = "#d8392c", "#a92a21", "#ee5a48"
		local WHITE, WHITE_DK = "#fbf7ee", "#e2dccd"
		local ROOF, ROOF_DK, ROOF_LT = "#8f2a24", "#6e1d1a", "#b23a30"
		local WOOD, WOOD_DK, WOOD_LT = "#a8692f", "#6b4220", "#c98a4b"
		local STONE, STONE_DK, STONE_LT = "#9aa3ad", "#7c858f", "#c3c9cf"
		local HAY, HAY_DK, HAY_LT = "#f2cc55", "#d9ad3a", "#fbe38e"
		local PETAL, PETAL_DK = "#ffd21f", "#ffae00"
		local SEED, SEED_DK = "#7a4520", "#4e2a12"
		local STEM, LEAF, LEAF_DK = "#3f9a32", "#55c23d", "#2f8a2a"
		local COPPER, COPPER_DK, COPPER_LT = "#e0a03a", "#b8772a", "#ffd27a"
		local COMB = "#e23a2a"
		local GRASS, GRASS_DK = "#6fd44a", "#4fb43a"
		local SIGN = "#fff4d6"
		local GLASS = "#8fd3ff"

		local seed = 901
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		local PX = 38 -- tower centre |x|
		local TW, TD = 10, 8 -- tower body width / depth (x 33..43, z -4..4)
		local TOP = 26 -- tower body top
		local BY0, BY1 = 19.3, 25.2 -- lintel y range
		local BD = 5 -- lintel depth (z -2.5..2.5)

		---------------------------------------------------------------- towers
		B:sym(function(side, s)
			-- stone footing (stepped)
			B:block(R, v(12, 1.2, 10), cf(PX, 0.6, 0), STONE_DK)
			B:block(R, v(11.4, 1.0, 9.4), cf(PX, 1.7, 0), STONE)
			for i, z in { -4.75, 4.75 } do
				B:block(R, v(2.2, 0.6, 0.6), cf(PX - 3 + i * 2, 1.5, z), STONE_LT)
			end
			-- body
			B:block(R, v(TW, TOP - 2.2, TD), cf(PX, 2.2 + (TOP - 2.2) / 2, 0), RED)
			-- vertical barn boards on front/back faces (alternating tones)
			local bcols = { RED_DK, RED_LT, RED_DK, RED_LT }
			for i = 0, 3 do
				local x = PX - 3.75 + i * 2.5
				for _, z in { -TD / 2 - 0.1, TD / 2 + 0.1 } do
					B:block(R, v(0.5, TOP - 2.6, 0.3), cf(x + 1.25 - 1.25, 2.4 + (TOP - 2.6) / 2, z), bcols[i + 1])
				end
			end
			-- white corner trim posts
			for _, cx in { -1, 1 } do
				for _, cz in { -1, 1 } do
					B:block(R, v(1.1, TOP - 2.2, 1.1), cf(PX + cx * (TW / 2 - 0.25), 2.2 + (TOP - 2.2) / 2, cz * (TD / 2 - 0.25)), WHITE)
				end
			end
			-- white belt bands (floor lines)
			for _, y in { 13.5, TOP - 0.4 } do
				B:block(R, v(TW + 0.5, 0.8, TD + 0.5), cf(PX, y, 0), WHITE)
			end
			B:block(R, v(TW + 0.6, 0.3, TD + 0.6), cf(PX, 13.0, 0), WHITE_DK)

			for _, f in { -1, 1 } do -- front (-Z) and back (+Z) faces
				local fz = f * (TD / 2 + 0.35)
				-- barn door (lower): white frame + X brace
				B:block(R, v(6.4, 0.7, 0.4), cf(PX, 9.6, fz), WHITE)
				B:block(R, v(6.4, 0.7, 0.4), cf(PX, 2.9, fz), WHITE)
				B:block(R, v(0.7, 7.4, 0.4), cf(PX - 2.85, 6.25, fz), WHITE)
				B:block(R, v(0.7, 7.4, 0.4), cf(PX + 2.85, 6.25, fz), WHITE)
				B:block(R, v(0.5, 6.4, 0.42), cf(PX, 6.25, fz), WHITE_DK)
				B:bar(R, v(PX - 2.6, 3.2, fz + f * 0.05), v(PX + 2.6, 9.3, fz + f * 0.05), 0.6, 0.38, WHITE)
				B:bar(R, v(PX + 2.6, 3.2, fz + f * 0.06), v(PX - 2.6, 9.3, fz + f * 0.06), 0.6, 0.36, WHITE)
				-- hay-loft door (upper) with a bale peeking out
				B:block(R, v(5.4, 5.4, 0.3), cf(PX, 19.4, fz - f * 0.1), SEED_DK)
				B:block(R, v(6.2, 0.6, 0.45), cf(PX, 22.3, fz), WHITE)
				B:block(R, v(6.2, 0.6, 0.45), cf(PX, 16.5, fz), WHITE)
				B:block(R, v(0.6, 6.4, 0.45), cf(PX - 2.8, 19.4, fz), WHITE)
				B:block(R, v(0.6, 6.4, 0.45), cf(PX + 2.8, 19.4, fz), WHITE)
				-- bale in the loft
				B:block(R, v(4.2, 2.6, 1.6), cf(PX, 18.2, fz + f * 0.3), HAY)
				B:block(R, v(4.25, 0.35, 1.65), cf(PX, 18.6, fz + f * 0.3), HAY_DK)
				B:block(R, v(0.35, 2.65, 1.65), cf(PX - 1.0, 18.2, fz + f * 0.3), WOOD)
				B:block(R, v(0.35, 2.65, 1.65), cf(PX + 1.0, 18.2, fz + f * 0.3), WOOD)
				for k = -1, 1, 2 do
					B:block(R, v(0.3, 0.9, 0.3), cf(PX + k * 1.7, 20.0, fz + f * 0.6, 0, 0, k * -25), HAY_LT)
				end
				-- pulley beam over the loft
				B:block(R, v(0.9, 0.9, 1.4), cf(PX, 24.0, fz + f * 0.6), WOOD_DK)
				B:block(R, v(0.3, 1.2, 0.3), cf(PX, 23.2, fz + f * 1.0), STONE_DK)
			end
			-- round-ish window on the lane-facing side (inner face, high up)
			local ix = PX - TW / 2 - 0.3
			B:block(R, v(0.4, 3.2, 3.2), cf(ix, 19.5, 0), WHITE)
			B:block(R, v(0.45, 2.2, 2.2), cf(ix - 0.05, 19.5, 0), GLASS)
			B:block(R, v(0.5, 2.3, 0.35), cf(ix - 0.1, 19.5, 0), WHITE)
			B:block(R, v(0.5, 0.35, 2.3), cf(ix - 0.1, 19.5, 0), WHITE)
			-- flower box under the window
			B:block(R, v(0.8, 0.8, 3.6), cf(ix - 0.1, 17.4, 0), WOOD)
			for k = -1, 1 do
				B:block(R, v(0.6, 0.6, 0.6), cf(ix - 0.1, 18.05, k * 1.1, 0, 30 * k, 0), k == 0 and PETAL or COMB)
			end
			-- same on the outer face
			local ox = PX + TW / 2 + 0.3
			B:block(R, v(0.4, 3.2, 3.2), cf(ox, 19.5, 0), WHITE)
			B:block(R, v(0.45, 2.2, 2.2), cf(ox + 0.05, 19.5, 0), GLASS)
			B:block(R, v(0.5, 2.3, 0.35), cf(ox + 0.1, 19.5, 0), WHITE)
			B:block(R, v(0.5, 0.35, 2.3), cf(ox + 0.1, 19.5, 0), WHITE)

			-- stepped gable roof: ridge runs along Z, gable ends face -Z/+Z
			local steps = 6
			for i = 0, steps - 1 do
				local w = 13 - i * 2.1
				local y = TOP + 0.5 + i * 1.0
				local col = (i % 2 == 0) and ROOF or ROOF_DK
				B:block(R, v(w, 1.05, TD + 2.2), cf(PX, y, 0), col)
				-- lighter shingle edge along each step
				B:block(R, v(0.6, 1.08, TD + 2.3), cf(PX - w / 2 + 0.3, y, 0), ROOF_LT)
				B:block(R, v(0.6, 1.08, TD + 2.3), cf(PX + w / 2 - 0.3, y, 0), ROOF_LT)
			end
			-- gable infill (white) on both ends, behind the eaves
			for _, f in { -1, 1 } do
				local gz = f * (TD / 2 + 0.6)
				for i = 0, 4 do
					local w = 10 - i * 2.1
					B:block(R, v(w, 1.0, 0.3), cf(PX, TOP + 0.5 + i, gz), WHITE)
				end
				-- little round vent
				B:block(R, v(1.8, 1.8, 0.35), cf(PX, TOP + 2.0, gz + f * 0.1), WOOD_DK)
				B:block(R, v(1.2, 1.2, 0.4), cf(PX, TOP + 2.0, gz + f * 0.15), HAY_LT)
			end
			-- ridge cap
			B:block(R, v(1.6, 0.8, TD + 2.6), cf(PX, TOP + 6.2, 0), WHITE)
			B:block(R, v(1.0, 0.8, 1.0), cf(PX, TOP + 6.9, -TD / 2 - 0.8), WHITE_DK)
			B:block(R, v(1.0, 0.8, 1.0), cf(PX, TOP + 6.9, TD / 2 + 0.8), WHITE_DK)

		end)

		---------------------------------------------------------------- lintel
		local LY = (BY0 + BY1) / 2
		local LH = BY1 - BY0
		B:block(R, v(66.5, LH, BD), cf(0, LY, 0), RED)
		-- vertical board rhythm along the lintel back face
		for i = -13, 13 do
			local x = i * 2.4
			if math.abs(x) > 13.5 then
				B:block(R, v(0.5, LH - 1.6, 0.3), cf(x, LY, BD / 2 + 0.1), (i % 2 == 0) and RED_DK or RED_LT)
			end
		end
		-- front: white X-braced barn panels either side of the sign
		B:sym(function()
			local fz = -BD / 2 - 0.2
			local x0, x1 = 17.2, 30.6
			local y0, y1 = BY0 + 1.0, BY1 - 1.0
			B:block(R, v(x1 - x0, 0.7, 0.4), cf((x0 + x1) / 2, y0, fz), WHITE)
			B:block(R, v(x1 - x0, 0.7, 0.4), cf((x0 + x1) / 2, y1, fz), WHITE)
			B:block(R, v(0.7, y1 - y0, 0.4), cf(x0, (y0 + y1) / 2, fz), WHITE)
			B:block(R, v(0.7, y1 - y0, 0.4), cf(x1, (y0 + y1) / 2, fz), WHITE)
			B:block(R, v(0.7, y1 - y0, 0.4), cf((x0 + x1) / 2, (y0 + y1) / 2, fz), WHITE)
			for _, k in { 0, 1 } do
				local a0 = x0 + k * (x1 - x0) / 2
				local a1 = a0 + (x1 - x0) / 2
				B:bar(R, v(a0 + 0.3, y0 + 0.3, fz - 0.03), v(a1 - 0.3, y1 - 0.3, fz - 0.03), 0.6, 0.36, WHITE_DK)
				B:bar(R, v(a1 - 0.3, y0 + 0.3, fz - 0.05), v(a0 + 0.3, y1 - 0.3, fz - 0.05), 0.6, 0.34, WHITE)
			end
		end)
		-- white trim bands top + bottom, brown timber caps
		for _, f in { -1, 1 } do
			B:block(R, v(66.6, 0.8, 0.45), cf(0, BY0 + 0.4, f * (BD / 2 + 0.15)), WHITE)
			B:block(R, v(66.6, 0.8, 0.45), cf(0, BY1 - 0.4, f * (BD / 2 + 0.15)), WHITE)
		end
		B:block(R, v(67.5, 0.9, BD + 1.2), cf(0, BY1 + 0.45, 0), WOOD)
		B:block(R, v(67.6, 0.3, BD + 1.3), cf(0, BY1 + 0.95, 0), WOOD_LT)
		B:block(R, v(66.5, 0.6, BD + 0.6), cf(0, BY0 + 0.3, 0), WOOD_DK)
		-- big timber pegs where the lintel meets the towers
		B:sym(function(_, s)
			for _, f in { -1, 1 } do
				for _, y in { 21.2, 24.2 } do
					B:block(R, v(0.8, 0.8, 0.4), cf(31.4, y, f * (BD / 2 + 0.35)), WOOD_DK)
				end
			end
			-- wooden bracket where lintel enters tower (above y 19)
			B:block(R, v(1.6, 1.2, BD + 0.8), cf(32.3, BY0 + 0.6, 0), WOOD_DK)
		end)

		-- back panel: X-braced barn door look
		local bz = BD / 2 + 0.35
		B:block(R, v(26, 0.8, 0.45), cf(0, BY1 - 1.1, bz), WHITE)
		B:block(R, v(26, 0.8, 0.45), cf(0, BY0 + 1.1, bz), WHITE)
		B:block(R, v(0.8, 4.6, 0.45), cf(-12.6, LY, bz), WHITE)
		B:block(R, v(0.8, 4.6, 0.45), cf(12.6, LY, bz), WHITE)
		B:block(R, v(0.8, 4.6, 0.45), cf(0, LY, bz), WHITE)
		for _, k in { -1, 1 } do
			local x0 = k * 6.3
			B:bar(R, v(x0 - 5.8, BY0 + 1.4, bz + 0.05), v(x0 + 5.8, BY1 - 1.4, bz + 0.05), 0.7, 0.4, WHITE)
			B:bar(R, v(x0 + 5.8, BY0 + 1.4, bz + 0.06), v(x0 - 5.8, BY1 - 1.4, bz + 0.06), 0.7, 0.38, WHITE)
		end

		---------------------------------------------------------------- sign
		local SY = 23.3
		local SZ = -BD / 2 - 1.1 -- sign centre z (front face at -4.1)
		B:block(R, v(28, 5.5, 1), cf(0, SY, SZ), SIGN, { name = "Sign" })
		-- backing board between sign and lintel
		B:block(R, v(27, 5, 0.8), cf(0, SY, -BD / 2 - 0.35), WOOD_DK)
		-- chunky wooden frame
		local FZ = SZ - 0.25
		B:block(R, v(31, 1.3, 1.6), cf(0, SY + 2.75 + 0.65, FZ), WOOD)
		B:block(R, v(31, 1.3, 1.6), cf(0, SY - 2.75 - 0.65, FZ), WOOD)
		B:block(R, v(1.5, 5.5, 1.6), cf(-14.75, SY, FZ), WOOD)
		B:block(R, v(1.5, 5.5, 1.6), cf(14.75, SY, FZ), WOOD)
		B:block(R, v(31.1, 0.35, 1.65), cf(0, SY + 3.95, FZ), WOOD_LT)
		B:block(R, v(31.1, 0.35, 1.65), cf(0, SY - 3.95, FZ), WOOD_DK)
		for _, x in { -14.75, 14.75 } do
			for _, y in { SY + 3.4, SY - 3.4 } do
				B:block(R, v(1.8, 1.6, 1.8), cf(x, y, FZ), WOOD_DK)
				B:block(R, v(0.6, 0.6, 0.3), cf(x, y, FZ - 0.95), STONE_LT)
			end
		end

		---------------------------------------------------------------- hay crown
		local function bale(x, y, z, w, h, d, ry)
			local base = CFrame.new(x, y, z) * ang(0, ry or 0, 0)
			B:block(R, v(w, h, d), base, HAY)
			B:block(R, v(w + 0.05, h * 0.3, d + 0.05), base * CFrame.new(0, h * 0.32, 0), HAY_LT)
			B:block(R, v(w + 0.05, h * 0.2, d + 0.05), base * CFrame.new(0, -h * 0.38, 0), HAY_DK)
			for _, bx in { -w * 0.27, w * 0.27 } do
				B:block(R, v(0.35, h + 0.08, d + 0.08), base * CFrame.new(bx, 0, 0), WOOD)
			end
			-- straw tufts
			B:block(R, v(0.3, 0.8, 0.3), base * CFrame.new(w * 0.45, h * 0.5, -d * 0.4) * ang(0, 0, -30), HAY_LT)
			B:block(R, v(0.3, 0.7, 0.3), base * CFrame.new(-w * 0.4, h * 0.5, d * 0.38) * ang(20, 0, 25), HAY_LT)
		end
		local CY = BY1 + 0.9
		local BH = 2.2
		-- bottom row (5 bales)
		bale(-12.4, CY + BH / 2, 0.1, 6.2, BH, 4.4, 3)
		bale(-6.2, CY + BH / 2, -0.1, 6.2, BH, 4.6, -2)
		bale(0, CY + BH / 2, 0.15, 6.2, BH, 4.7, 0)
		bale(6.2, CY + BH / 2, -0.1, 6.2, BH, 4.6, 2)
		bale(12.4, CY + BH / 2, 0.1, 6.2, BH, 4.4, -3)
		-- top row (3 bales)
		bale(-6.2, CY + BH * 1.5, 0, 6, BH, 4.2, -4)
		bale(0, CY + BH * 1.5, 0, 6, BH, 4.2, 0)
		bale(6.2, CY + BH * 1.5, 0, 6, BH, 4.2, 4)
		-- small side bales flanking
		bale(-18.4, CY + 0.9, 0.3, 4, 1.8, 3.6, 12)
		bale(18.4, CY + 0.9, 0.3, 4, 1.8, 3.6, -12)

		-- sunflowers
		local function sunflower(pos, dirY, tilt, size)
			-- stem
			local face = CFrame.new(pos) * ang(0, dirY, 0) * ang(tilt, 0, 0)
			B:block(R, v(0.5, 3, 0.5), CFrame.new(pos) * ang(0, dirY, 0) * CFrame.new(0, -1.8, 0.4) * ang(-12, 0, 0), STEM)
			B:block(R, v(1.4, 0.3, 0.9), CFrame.new(pos) * ang(0, dirY, 0) * CFrame.new(0.8, -2.2, 0.3) * ang(0, 20, -25), LEAF)
			B:block(R, v(1.2, 0.3, 0.8), CFrame.new(pos) * ang(0, dirY, 0) * CFrame.new(-0.7, -2.8, 0.3) * ang(0, -20, 25), LEAF_DK)
			-- petals: 8 rotated blocks around the head
			for i = 0, 7 do
				local a = i * 45 + 22.5
				local col = (i % 2 == 0) and PETAL or PETAL_DK
				B:block(R, v(size * 0.55, size * 0.9, 0.35), face * ang(0, 0, a) * CFrame.new(0, size * 0.72, 0.05), col)
			end
			B:block(R, v(size * 1.05, size * 1.05, 0.6), face * CFrame.new(0, 0, -0.05), SEED)
			B:block(R, v(size * 0.55, size * 0.55, 0.65), face * CFrame.new(0, 0, -0.1), SEED_DK)
		end
		-- front faces
		sunflower(v(-10.8, CY + 4.6, -1.9), 0, -10, 2.3)
		sunflower(v(10.8, CY + 4.6, -1.9), 0, -10, 2.3)
		sunflower(v(-15.6, CY + 3.0, -1.4), 0, -10, 1.5)
		sunflower(v(15.6, CY + 3.0, -1.4), 0, -10, 1.5)
		sunflower(v(-3.4, CY + 5.0, -1.6), 12, -6, 1.6)
		sunflower(v(3.4, CY + 5.0, -1.6), -12, -6, 1.6)
		-- back faces
		sunflower(v(-10.8, CY + 4.6, 1.9), 180, -10, 2.2)
		sunflower(v(10.8, CY + 4.6, 1.9), 180, -10, 2.2)
		sunflower(v(-3.3, CY + 5.0, 1.6), 168, -6, 1.4)
		sunflower(v(3.3, CY + 5.0, 1.6), 192, -6, 1.4)
		-- outward on the side bales
		sunflower(v(-20.6, CY + 2.6, 0), 90 + 180, -5, 1.3)
		sunflower(v(20.6, CY + 2.6, 0), 90, -5, 1.3)

		---------------------------------------------------------------- weathervane
		local WY = CY + 2 * BH -- top of the upper bales
		B:block(R, v(0.5, 1.4, 0.5), cf(0, WY + 0.6, 0), STONE_DK)
		B:block(R, v(1.0, 0.4, 1.0), cf(0, WY + 0.2, 0), COPPER_DK)
		-- compass arms
		B:block(R, v(3.4, 0.25, 0.25), cf(0, WY + 0.6, 0), COPPER_DK)
		B:block(R, v(0.25, 0.25, 3.4), cf(0, WY + 0.6, 0), COPPER_DK)
		for _, d in { { 1.8, 0 }, { -1.8, 0 }, { 0, 1.8 }, { 0, -1.8 } } do
			B:block(R, v(0.45, 0.45, 0.45), cf(d[1], WY + 0.6, d[2], 0, 45, 0), COPPER_LT)
		end
		-- rooster (side profile along X, facing -X)
		local RY = WY + 1.75
		B:block(R, v(2.0, 1.2, 0.5), cf(0, RY, 0), COPPER) -- body
		B:block(R, v(1.2, 0.6, 0.5), cf(0.1, RY - 0.8, 0), COPPER_DK) -- belly
		B:block(R, v(0.8, 1.2, 0.5), cf(-1.1, RY + 0.8, 0), COPPER) -- neck/head
		B:block(R, v(0.5, 0.25, 0.4), cf(-1.65, RY + 0.95, 0), COPPER_LT) -- beak
		B:block(R, v(0.7, 0.4, 0.55), cf(-1.05, RY + 1.45, 0), COMB) -- comb
		B:block(R, v(0.3, 0.45, 0.55), cf(-1.4, RY + 0.4, 0), COMB) -- wattle
		B:block(R, v(0.18, 0.18, 0.6), cf(-1.3, RY + 1.05, 0), SEED_DK) -- eye
		-- tail feathers fan
		B:block(R, v(0.5, 1.8, 0.45), cf(1.1, RY + 0.8, 0, 0, 0, -25), COPPER_DK)
		B:block(R, v(0.5, 1.6, 0.45), cf(1.5, RY + 0.5, 0, 0, 0, -50), COPPER)
		B:block(R, v(0.5, 1.4, 0.45), cf(0.8, RY + 1.0, 0, 0, 0, -8), COPPER_LT)
		-- legs
		B:block(R, v(0.2, 0.5, 0.2), cf(-0.2, RY - 1.05, 0), COPPER_DK)
		B:block(R, v(0.2, 0.5, 0.2), cf(0.3, RY - 1.05, 0), COPPER_DK)

		---------------------------------------------------------------- picket fence on the lintel
		local FY = BY1 + 1.1
		B:sym(function(_, s)
			local x0, x1 = 21.0, 31.5
			for _, ry in { FY + 0.7, FY + 1.7 } do
				B:block(R, v(x1 - x0, 0.35, 0.35), cf((x0 + x1) / 2, ry, 0.45), WHITE_DK)
			end
			local n = 0
			for x = x0 + 0.6, x1 - 0.4, 1.4 do
				n += 1
				local h = 2.2 + ((n % 2 == 0) and 0.3 or 0)
				B:block(R, v(0.8, h, 0.3), cf(x, FY + h / 2, 0.2), WHITE)
				B:block(R, v(0.5, 0.5, 0.3), cf(x, FY + h + 0.15, 0.2, 0, 0, 45), WHITE)
			end
		end)
	end,
}
