--!nocheck
-- Beehive Boxes (Honey Hills decoration, HERO piece, gently animated).
-- Two stacks of painted wooden beehive boxes on a sturdy wooden stand, with
-- honeycomb, honey jars and flowers; little block bees circle the hives.
-- * footing (bone "Soil", parts "Soil"): stepped turf pad with a soil rim,
--   flat stones, tufts, daisies, pink/lavender wildflowers, clover, a
--   lavender bunch and a small sunflower
-- * the STAND (bone "Hives"): plank deck on four legs with cross braces and
--   a lower shelf holding three little honey jars
-- * TALL STACK (left): bottom board + landing board + dark entrance slot,
--   three boxes (honey yellow / cream / pink) with seams and hand-hold
--   notches, a cream lid and a stepped gabled terracotta roof
-- * SHORT STACK (right): two boxes and a lid crowned with a chunk of hex
--   honeycomb, honey oozing down the sides
-- * honey dribbling out of both entrances onto the landing boards, a
--   honeycomb frame leaning against the stand
-- * six block bees on orbit bones (BeeN, pivot = orbit centre, tilted
--   orbit planes) with flapping wing bones (BeeNWR / BeeNWL) and faint trails
-- VFX: honey drips at the entrances, golden pollen sparkles. Blocks only.
return {
	DisplayName = "Beehive Boxes",
	Rarity = "Decor",
	Element = "Honey Hills",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local SQ3 = math.sqrt(3)

		-- palette (Honey Hills) ------------------------------------------
		local SOIL_DK, SOIL = "#6b4226", "#875533"
		local GR_DK, GR, GR_LT, GR_XL = "#7cae32", "#97c83e", "#b2d84c", "#d2e872"
		local LEAF, LEAF_DK = "#5dbd40", "#46a83a"
		local CLOVER, CLOVER_DK = "#3f9a3c", "#2f7f30"
		local STONE, STONE_LT = "#a49a8c", "#c4bcae"
		local DAISY, DAISY_EYE = "#fffaf2", "#ffc93a"
		local FL_PINK, FL_LAV = "#ff9cc4", "#c7a2ff"
		local LAV, LAV_DK = "#b993ee", "#9a74d6"
		local SUN, SUN_DK, SUN_C = "#ffd23a", "#f5a623", "#7a4a22"
		local WOOD_DK, WOOD, WOOD_LT = "#7a4c2b", "#9a6440", "#b47a4c"
		local BOX_Y, BOX_Y_DK = "#ffcf4a", "#e8a83a"
		local BOX_C, BOX_C_DK = "#fff0c8", "#e6cf9c"
		local BOX_P, BOX_P_DK = "#ffb3cf", "#e88cb0"
		local ROOF, ROOF_DK = "#e0663a", "#b84a2a"
		local SLOT = "#3a2416"
		local HONEY_DK, HONEY, HONEY_LT = "#e08a14", "#ffa318", "#ffc54a"
		local WAX_LT, WAX, WAX_DK = "#ffe27a", "#ffc93c", "#e8a020"
		local CELL, CELL_DK = "#c87410", "#a65a0c"
		local JAR_LID, CLOTH = "#fff4dc", "#ff7f9e"
		local BEE_Y, BEE_YD, BEE_K, WING = "#ffd23a", "#f5b81f", "#2a2126", "#f4fbff"

		local seed = 22401
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function pick(t)
			return t[math.floor(rnd() * #t) + 1]
		end
		local function polar(r, deg)
			local a = rad(deg)
			return math.sin(a) * r, -math.cos(a) * r
		end
		local function pad(bone, c, r, h, col, opts)
			B:block(bone, v(2 * r, h, 1.15 * r), c, col, opts)
			B:block(bone, v(1.15 * r, h - 0.02, 2 * r), c, col, opts)
			B:block(bone, v(1.72 * r, h - 0.04, 1.72 * r), c, col, opts)
		end
		local function hex(bone, c, R, h, col, opts)
			for k = 0, 2 do
				B:block(bone, v(R, h, R * SQ3), c * CFrame.Angles(0, rad(k * 60), 0), col, opts)
			end
		end

		------------------------------------------------------------------
		-- FOOTING (bone "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		for _, x in { -2.6, 2.6 } do
			pad(soil, cf(x, 0.25, 0), 5.6, 0.5, SOIL_DK, S)
			pad(soil, cf(x, 0.45, 0), 5.3, 0.3, GR_DK, S)
			pad(soil, cf(x * 0.9, 0.62, 0), 4.2, 0.2, GR, S)
		end
		for i = 0, 17 do
			local a = i / 18 * 360 + jit(6)
			local ar = rad(a)
			local x, z = math.sin(ar) * 8.0, -math.cos(ar) * 5.6
			local h = 0.55 + rnd() * 0.25
			B:block(soil, v(1.9 + rnd() * 0.6, h, 1.3), cf(x, h / 2, z, 0, -a + jit(8), 0), pick({ GR, GR_DK, GR_LT }), S)
		end
		local TOP = 0.72
		-- flat stones
		for _, s in { { -7.0, -1.8, 1.3, STONE }, { 6.9, 2.6, 1.1, STONE_LT }, { -1.4, -4.6, 1.2, STONE_LT }, { 0.2, -5.3, 0.9, STONE }, { -6.2, 3.4, 1.0, STONE } } do
			B:block(soil, v(s[3], 0.3, s[3] * 0.8), cf(s[1], TOP + 0.02, s[2], 0, jit(40), 0), s[4], S)
		end
		-- tufts
		for _, g in { { -7.6, 0.6 }, { 7.8, -0.4 }, { 3.6, -4.9 }, { -4.2, 4.6 }, { 4.4, 4.7 } } do
			B:block(soil, v(0.35, 1.1, 0.35), cf(g[1], TOP + 0.45, g[2], 0, jit(30), -8), GR_LT, S)
			B:block(soil, v(0.3, 0.8, 0.3), cf(g[1] + 0.32, TOP + 0.35, g[2] + 0.2, 0, jit(30), 14), GR, S)
			B:block(soil, v(0.28, 0.9, 0.28), cf(g[1] - 0.3, TOP + 0.4, g[2] - 0.15, 10, jit(30), 0), GR_XL, S)
		end
		-- little flowers (8-petal daisies, pink + lavender wildflowers)
		local function flower(x, z, col, s, stem)
			s = s or 1
			stem = stem or 0.8
			B:block(soil, v(0.18, stem * s, 0.18), cf(x, TOP + stem * s / 2, z), GR_DK, S)
			local yaw = rnd() * 90
			local c = cf(x, TOP + stem * s + 0.02, z, 0, yaw, 0)
			B:block(soil, v(1.0 * s, 0.16, 0.34 * s), c, col, S)
			B:block(soil, v(0.34 * s, 0.17, 1.0 * s), c, col, S)
			if col == DAISY then
				B:block(soil, v(0.9 * s, 0.15, 0.3 * s), c * ang(0, 45, 0), col, S)
				B:block(soil, v(0.3 * s, 0.155, 0.9 * s), c * ang(0, 45, 0), col, S)
			end
			B:block(soil, v(0.36 * s, 0.26, 0.36 * s), c * CFrame.new(0, 0.05, 0), DAISY_EYE, S)
		end
		flower(-6.4, -2.8, DAISY, 1.1)
		flower(-4.6, -3.9, FL_PINK, 1.0, 1.0)
		flower(-2.8, -4.4, DAISY, 0.9)
		flower(1.6, -4.6, FL_LAV, 1.0, 1.1)
		flower(3.0, -4.1, DAISY, 1.0)
		flower(5.6, -3.2, FL_PINK, 0.9)
		flower(7.4, 1.2, DAISY, 0.9)
		flower(-7.6, 1.8, FL_LAV, 0.9)
		flower(-2.0, 4.6, DAISY, 0.9)
		flower(2.2, 4.8, FL_PINK, 0.9)
		local function clover(x, z)
			local yaw = rnd() * 120
			for k = 0, 2 do
				local c = cf(x, TOP + 0.3, z, 0, yaw + k * 120, 0) * CFrame.new(0, 0, -0.3)
				B:block(soil, v(0.5, 0.14, 0.5), c * ang(0, 45, 0), (k == 0) and CLOVER_DK or CLOVER, S)
			end
		end
		clover(-5.6, -1.2)
		clover(-0.6, -3.8)
		clover(4.4, -3.6)
		clover(6.3, 0.0)
		clover(-5.0, 2.6)
		-- lavender bunch (front-left)
		for k, l in { { -7.2, -0.6, 2.4 }, { -6.7, -1.2, 2.9 }, { -6.3, -0.4, 2.2 }, { -7.6, -1.4, 2.0 } } do
			local base = v(l[1], TOP, l[2])
			local tip = base + v(jit(0.3), l[3], jit(0.3))
			B:bar(soil, base, tip, 0.16, 0.16, LEAF_DK, S)
			for j = 0, 2 do
				local p = tip + v(0, -0.25 - j * 0.42, 0)
				B:block(soil, v(0.42 - j * 0.0, 0.38, 0.42), CFrame.new(p) * ang(0, 45 * (j % 2), 0), (j % 2 == 0) and LAV or LAV_DK, S)
			end
			local _ = k
		end
		-- small sunflower (back-right)
		do
			local base = v(7.0, TOP, 2.0)
			local head = base + v(-0.3, 5.0, -0.2)
			B:bar(soil, base, head, 0.32, 0.32, LEAF_DK, S)
			B:block(soil, v(1.1, 0.16, 0.5), CFrame.new(base:Lerp(head, 0.35)) * ang(0, 30, 25), LEAF, S)
			B:block(soil, v(1.0, 0.16, 0.5), CFrame.new(base:Lerp(head, 0.6)) * ang(0, -150, 25), LEAF, S)
			local F = CFrame.new(head) * CFrame.Angles(0, rad(-30), 0) * ang(20, 0, 0)
			for k = 0, 3 do
				B:block(soil, v(2.6, 0.7, 0.2), F * ang(0, 0, k * 45), (k % 2 == 0) and SUN or SUN_DK, S)
			end
			B:block(soil, v(1.2, 1.2, 0.36), F * CFrame.new(0, 0, -0.06), SUN_C, S)
			B:block(soil, v(0.5, 0.5, 0.4), F * CFrame.new(0, 0, -0.1) * ang(0, 0, 45), "#5a3418", S)
		end

		------------------------------------------------------------------
		-- THE STAND (bone "Hives")
		------------------------------------------------------------------
		local hb = B:bone("Hives", "Root", v(0, TOP, 0))
		local DECK = 3.7 -- deck top
		for _, lx in { -5.0, 5.0 } do
			for _, lz in { -2.9, 2.9 } do
				B:block(hb, v(0.9, DECK - TOP + 0.05, 0.9), cf(lx, (DECK + TOP) / 2 - 0.25, lz), WOOD)
				B:block(hb, v(1.15, 0.35, 1.15), cf(lx, TOP + 0.15, lz), WOOD_DK)
			end
			-- side braces
			B:bar(hb, v(lx, TOP + 0.6, -2.9), v(lx, DECK - 0.6, 2.9), 0.35, 0.4, WOOD_DK)
		end
		-- deck planks
		for i = 0, 4 do
			local z = -2.8 + i * 1.4
			B:block(hb, v(11.4, 0.5, 1.38), cf(jit(0.06), DECK - 0.25, z), (i % 2 == 0) and WOOD_LT or WOOD)
		end
		B:block(hb, v(11.0, 0.4, 0.5), cf(0, DECK - 0.7, -3.2), WOOD_DK) -- front apron
		-- lower shelf with honey jars
		local SH = 1.75
		B:block(hb, v(10.2, 0.35, 5.6), cf(0, SH, 0), WOOD)
		B:block(hb, v(10.3, 0.2, 0.3), cf(0, SH + 0.05, -2.8), WOOD_DK)
		for k, jx in { -2.6, -1.3, 3.4 } do
			local base = SH + 0.18
			local c = cf(jx, base + 0.6, -1.9 + (k == 2 and 0.6 or 0), 0, k * 20, 0)
			B:block(hb, v(1.0, 1.2, 1.0), c, HONEY)
			B:block(hb, v(1.1, 0.7, 0.8), c * CFrame.new(0, -0.05, 0), HONEY_LT)
			B:block(hb, v(0.9, 0.25, 0.9), c * CFrame.new(0, 0.72, 0), JAR_LID)
			B:block(hb, v(1.15, 0.12, 1.15), c * CFrame.new(0, 0.82, 0) * ang(0, 45, 0), CLOTH)
		end

		------------------------------------------------------------------
		-- HIVE STACKS
		------------------------------------------------------------------
		local W = 4.6 -- box width
		local function box(x, z, y0, h, col, colDk, notch)
			B:block(hb, v(W, h - 0.04, W), cf(x, y0 + h / 2, z), col)
			B:block(hb, v(W + 0.08, 0.16, W + 0.08), cf(x, y0 + 0.08, z), colDk) -- seam
			if notch then
				for _, face in { 0, 90, -90, 180 } do
					local c = cf(x, y0 + h * 0.62, z, 0, face, 0) * CFrame.new(0, 0, -W / 2 - 0.02)
					B:block(hb, v(1.5, 0.36, 0.1), c, colDk)
				end
			end
		end
		local function bottomBoard(x, z)
			B:block(hb, v(W + 0.3, 0.5, W + 0.3), cf(x, DECK + 0.25, z), WOOD_DK)
			B:block(hb, v(3.6, 0.22, 1.3), cf(x, DECK + 0.39, z - W / 2 - 0.55), WOOD)
			B:block(hb, v(2.8, 0.38, 0.1), cf(x, DECK + 0.72, z - W / 2 - 0.02), SLOT)
		end
		local entrances = {}
		-- tall stack (left = -X)
		local AX, AZ = -3.0, -0.8
		bottomBoard(AX, AZ)
		local y = DECK + 0.5
		box(AX, AZ, y, 2.6, BOX_Y, BOX_Y_DK, true)
		y += 2.6
		box(AX, AZ, y, 2.6, BOX_C, BOX_C_DK, true)
		y += 2.6
		box(AX, AZ, y, 2.6, BOX_P, BOX_P_DK, true)
		y += 2.6
		box(AX, AZ, y, 1.7, BOX_Y, BOX_Y_DK, true)
		y += 1.7
		-- a hex emblem on the cream box
		do
			local Fc = cf(AX, DECK + 0.5 + 2.6 + 1.0, AZ - W / 2 - 0.02) * CFrame.Angles(rad(90), 0, 0)
			for k, o in { { 0, 0.5 }, { -0.55, -0.45 }, { 0.55, -0.45 } } do
				local c = Fc * CFrame.new(o[1], -0.04, o[2]) * CFrame.Angles(0, rad(30), 0)
				hex(hb, c, 0.55, 0.1, WAX)
				hex(hb, c * CFrame.new(0, -0.04, 0), 0.3, 0.1, (k == 1) and HONEY or CELL)
			end
		end
		-- lid + stepped gable roof (ridge along X)
		B:block(hb, v(W + 0.4, 0.45, W + 0.4), cf(AX, y + 0.22, AZ), BOX_C)
		y += 0.45
		local depths = { 5.4, 4.2, 3.0, 1.8 }
		for i, d in depths do
			B:block(hb, v(W + 0.7, 0.48, d), cf(AX, y + (i - 0.5) * 0.48, AZ), (i % 2 == 1) and ROOF or ROOF_DK)
		end
		B:block(hb, v(W + 0.9, 0.35, 0.8), cf(AX, y + 4 * 0.48 + 0.15, AZ), ROOF_DK)
		local ATOP = y + 4 * 0.48 + 0.33
		table.insert(entrances, v(AX, DECK + 0.72, AZ - W / 2 - 0.1))

		-- short stack (right = +X)
		local BX, BZ = 3.0, 0.9
		bottomBoard(BX, BZ)
		y = DECK + 0.5
		box(BX, BZ, y, 2.6, BOX_P, BOX_P_DK, true)
		y += 2.6
		box(BX, BZ, y, 1.8, BOX_Y, BOX_Y_DK, true)
		y += 1.8
		B:block(hb, v(W + 0.4, 0.45, W + 0.4), cf(BX, y + 0.22, BZ), BOX_C)
		y += 0.45
		local BTOP = y
		table.insert(entrances, v(BX, DECK + 0.72, BZ - W / 2 - 0.1))
		-- honeycomb chunk on the short stack
		do
			local cells = { { 0, 0, 1.6 }, { 1.55, 0.9, 1.1 }, { -1.55, 0.9, 1.2 }, { 0, 1.8, 0.8 }, { 1.55, -0.9, 0.9 }, { -1.55, -0.9, 1.3 }, { 0, -1.8, 0.7 } }
			for i, c in cells do
				local cc = cf(BX + c[1] * 0.85, BTOP + c[3] / 2, BZ + c[2] * 0.85)
				hex(hb, cc, 1.0, c[3], (i % 2 == 0) and WAX_LT or WAX)
				B:block(hb, v(0.95, 0.1, 0.95), cc * CFrame.new(0, c[3] / 2 + 0.02, 0) * ang(0, 45, 0), (i % 3 == 0) and HONEY_LT or CELL_DK)
			end
			-- honey oozing down the box sides
			for _, o in { { -1.2, -1, 1.5 }, { 1.0, -1, 2.2 }, { 1, 1.4, 1.2 } } do
				local fx, fz
				if o[3] == 1.2 then
					fx, fz = BX + W / 2 + 0.12, BZ + o[2]
				else
					fx, fz = BX + o[1], BZ - W / 2 - 0.12
				end
				local len = o[3]
				local sx = (fx > BX + W / 2) and 0.25 or 0.9
				local sz = (fx > BX + W / 2) and 0.9 or 0.25
				B:block(hb, v(sx, len, sz), cf(fx, BTOP - len / 2 + 0.1, fz), HONEY)
				B:block(hb, v(sx * 0.7 + 0.1, 0.5, sz * 0.7 + 0.1), cf(fx, BTOP - len - 0.05, fz, 0, 0, 0), HONEY_LT)
			end
		end
		-- honey dribbling out of the entrances onto the landing boards
		for _, e in entrances do
			B:block(hb, v(1.4, 0.12, 1.0), cf(e.X + 0.4, DECK + 0.52, e.Z - 0.4), HONEY)
			B:block(hb, v(0.4, 0.8, 0.4), cf(e.X + 0.9, DECK + 0.1, e.Z - 1.15), HONEY)
			B:block(hb, v(0.6, 0.14, 0.6), cf(e.X - 0.5, DECK + 0.53, e.Z - 0.7, 0, 30, 0), HONEY_LT)
		end
		-- glow in the tall stack's entrance (tiny neon accent)
		B:gem(hb, v(1.6, 0.2, 0.08), cf(AX, DECK + 0.72, AZ - W / 2 - 0.06), "#ffb52e", { name = "HiveGlow" })

		------------------------------------------------------------------
		-- honeycomb frame leaning against the front-right leg
		------------------------------------------------------------------
		do
			local F = cf(6.3, TOP + 1.55, -3.4, -16, -25, 0) -- local Y up the frame, -Z faces out
			local FW, FH = 2.8, 3.0
			B:block(hb, v(FW + 0.5, 0.3, 0.4), F * CFrame.new(0, FH / 2 + 0.05, 0), WOOD_LT)
			B:block(hb, v(FW + 1.1, 0.25, 0.3), F * CFrame.new(0, FH / 2 + 0.05, 0.02), WOOD)
			B:block(hb, v(FW, 0.25, 0.35), F * CFrame.new(0, -FH / 2, 0), WOOD_LT)
			for _, sx in { -1, 1 } do
				B:block(hb, v(0.25, FH, 0.35), F * CFrame.new(sx * FW / 2, 0, 0), WOOD_LT)
			end
			B:block(hb, v(FW - 0.1, FH - 0.2, 0.2), F, WAX_DK)
			for r = 0, 2 do
				for cI = 0, 2 do
					local cx = -0.85 + cI * 0.85 + ((r % 2 == 1) and 0.42 or 0)
					if cx < 1.1 then
						local c = F * CFrame.new(cx, -0.9 + r * 0.85, -0.1) * CFrame.Angles(rad(90), 0, 0)
						hex(hb, c, 0.45, 0.1, ((r + cI) % 3 == 0) and HONEY or WAX)
					end
				end
			end
		end

		------------------------------------------------------------------
		-- BEES on orbit bones (pivot = orbit centre, tilted orbit plane)
		------------------------------------------------------------------
		local trailCols = { "#fff2a8", "#ffc93a" }
		local function bee(name, pivot, r, a0, s)
			local bone = B:bone(name, "Root", pivot)
			local px, pz = polar(r, a0)
			local F = pivot * CFrame.new(px, 0, pz) * CFrame.Angles(0, -rad(a0 - 90), 0) * ang(0, 0, -10)
			B:block(bone, v(1.1 * s, 1.0 * s, 1.5 * s), F, BEE_Y)
			B:block(bone, v(1.16 * s, 1.06 * s, 0.32 * s), F * CFrame.new(0, 0, 0.05 * s), BEE_K)
			B:block(bone, v(1.16 * s, 1.06 * s, 0.3 * s), F * CFrame.new(0, 0, 0.55 * s), BEE_K)
			B:block(bone, v(0.8 * s, 0.75 * s, 0.4 * s), F * CFrame.new(0, -0.05 * s, 0.9 * s), BEE_YD)
			B:block(bone, v(0.3 * s, 0.3 * s, 0.3 * s), F * CFrame.new(0, -0.1 * s, 1.15 * s), BEE_K)
			B:block(bone, v(0.85 * s, 0.85 * s, 0.7 * s), F * CFrame.new(0, 0.05 * s, -1.0 * s), BEE_K)
			B:block(bone, v(0.12 * s, 0.6 * s, 0.12 * s), F * CFrame.new(0.25 * s, 0.7 * s, -1.2 * s) * ang(-25, 0, -15), BEE_K)
			B:block(bone, v(0.12 * s, 0.6 * s, 0.12 * s), F * CFrame.new(-0.25 * s, 0.7 * s, -1.2 * s) * ang(-25, 0, 15), BEE_K)
			for _, side in { 1, -1 } do
				local wp = F * CFrame.new(side * 0.35 * s, 0.5 * s, 0.05 * s)
				local wb = B:bone(name .. (side > 0 and "WR" or "WL"), name, wp)
				B:block(wb, v(0.95 * s, 0.12, 0.7 * s), wp * ang(0, 0, side * 22) * CFrame.new(side * 0.5 * s, 0, 0.05 * s), WING, { tr = 0.15 })
			end
			B:trail(bone, (F * CFrame.new(0, 0.25 * s, 0.8 * s)).Position, (F * CFrame.new(0, -0.25 * s, 0.8 * s)).Position,
				{ name = name .. "Trail", color = trailCols, life = 0.35, width = { 1, 0 }, trans = { 0.45, 1 } })
		end
		local function tilted(c, deg, tlt)
			return CFrame.new(c) * CFrame.Angles(0, -rad(deg), 0) * ang(tlt, 0, 0) * CFrame.Angles(0, rad(deg), 0)
		end
		-- name, centre, radius, start angle, tilt dir, tilt, scale
		bee("Bee1", tilted(v(AX, DECK + 5.8, AZ), 30, 10), 4.4, 20, 1.0)
		bee("Bee2", tilted(v(AX, DECK + 10.0, AZ), 200, 12), 4.2, 200, 0.95)
		bee("Bee3", tilted(v(BX, DECK + 4.4, BZ), 120, 9), 4.0, 110, 0.95)
		bee("Bee4", tilted(v(BX, DECK + 6.6, BZ), 300, 14), 3.6, 290, 0.9)
		bee("Bee5", tilted(v(0, DECK + 11.5, 0), 60, 8), 7.0, 150, 1.05)
		bee("Bee6", tilted(v(0, DECK + 7.6, 0), 240, 10), 7.8, 330, 1.0)

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		for i, e in entrances do
			local z = B:block(hb, v(0.3, 0.2, 0.3), cf(e.X + 0.9, DECK - 0.4, e.Z - 1.15), HONEY, { tr = 1, name = "DripZone" .. i })
			B:emitter(z, "drip", { name = "HoneyDrip" .. i, color = { "#ffc23a", "#ff9a14" }, rate = 0.7, size = { 0.3, 0.26, 0.14 }, life = { 0.4, 0.6 } })
		end
		local motes = B:block(hb, v(12, 8, 7), cf(0, DECK + 5, 0), HONEY, { tr = 1, name = "PollenZone" })
		B:emitter(motes, "sparkle", { name = "PollenSparkle", color = { "#ffe57a", "#fff6c8", "#ffb0d0" }, rate = 4, size = { 0.12, 0.4, 0.05 }, life = { 1.4, 2.6 }, speed = { 0.2, 0.5 } })
		local _ = { ATOP, SOIL, HONEY_DK }
	end,
}
