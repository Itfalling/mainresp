--!nocheck
-- Little Red Shed (Sunny Farm scenery, ~13 studs). A small storybook red barn
-- in the windmill / well palette, faces -Z:
-- * low grey stone footing course, red plank walls in three tones (shadow
--   foot band, main red, a few sunny highlight planks, dark plank grooves)
--   with cream corner boards and a cream band under the eaves
-- * a gambrel roof made of rotated slate-grey panels with proud shingle rows
--   (dark / light), a dark ridge cap, cream barge boards on both gables and
--   a stepped red gable wall behind them
-- * big double barn doors with cream frames and X braces, iron hinges
-- * the hay door: a dark loft opening with a cream frame, its leaf swung open
--   flat against the gable, hay spilling out, and a pulley beam with a rope
-- * cream-framed windows with flower boxes on both sides, a little cupola with
--   a gold weathervane on the ridge
-- * grounding: a door plank, loose straw, a hay bale, grass tufts, stones
-- Scenery filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Little Red Shed",
	Rarity = "Scenery",
	Filler = true,
	Element = "Sunny Farm",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		-- Sunny Farm palette (DecorFarmWindmill / DecorFarmWell / DecorFarmHay)
		local RED_LT, RED, RED_DK = "#f25a44", "#e0392e", "#b02720"
		local CREAM, CREAM_DK = "#fff4dc", "#ecdcb8"
		local SLATE_LT, SLATE, SLATE_DK = "#9aa3ad", "#7c858f", "#5f6770"
		local STONE_LT, STONE, STONE_DK = "#c3c9cf", "#9aa3ad", "#7c858f"
		local WOOD_LT, WOOD, WOOD_DK = "#c98a4b", "#a8692f", "#6b4220"
		local HAY_LT, HAY, HAY_DK = "#fff0a0", "#f7d462", "#e2ad38"
		local TWINE = "#d2452e"
		local GLASS, GLASS_LT = "#8fd8ff", "#c8eeff"
		local IRON, DARK = "#3a3f46", "#2a2420"
		local GOLD = "#ffcf3a"
		local ROPE = "#e3c78a"
		local GRASS, GRASS_DK = "#5fd23f", "#3fb43a"
		local FLOWER_P, FLOWER_W, FLOWER_Y = "#ff7eb6", "#ffffff", "#ffd93b"

		local HX, HZ = 4, 4.5 -- wall half extents
		local Y0, WH = 0.4, 6.0 -- wall foot, wall height
		local YT = Y0 + WH

		------------------------------------------------------------ footing
		B:block(R, v(HX * 2 + 0.6, Y0 + 0.05, HZ * 2 + 0.6), cf(0, (Y0 + 0.05) / 2, 0), STONE_DK)
		B:block(R, v(HX * 2 + 0.3, 0.12, HZ * 2 + 0.3), cf(0, Y0 + 0.02, 0), STONE)
		for _, s in { { -2.6, -1 }, { 3.1, -1 }, { -1.2, 1 }, { 2.0, 1 } } do
			B:block(R, v(1.3, 0.35, 0.2), cf(s[1], 0.22, s[2] * (HZ + 0.32)), STONE_LT)
		end

		------------------------------------------------------------ walls
		B:block(R, v(HX * 2, WH, HZ * 2), cf(0, Y0 + WH / 2, 0), RED)
		B:block(R, v(HX * 2 + 0.1, 0.55, HZ * 2 + 0.1), cf(0, Y0 + 0.28, 0), RED_DK)
		-- plank grooves (dark) + sunny highlight planks on the side walls
		for _, s in { -1, 1 } do
			for _, z in { -3.0, -1.5, 1.5, 3.0 } do
				B:block(R, v(0.1, WH - 0.7, 0.16), cf(s * (HX + 0.04), Y0 + WH / 2 + 0.2, z), RED_DK)
			end
			B:block(R, v(0.1, WH - 0.7, 0.9), cf(s * (HX + 0.04), Y0 + WH / 2 + 0.2, -2.25), RED_LT)
			B:block(R, v(0.1, WH - 0.7, 0.9), cf(s * (HX + 0.04), Y0 + WH / 2 + 0.2, 2.25), RED_LT)
		end
		for _, x in { -3.0, 3.0 } do
			B:block(R, v(0.16, WH - 0.7, 0.1), cf(x, Y0 + WH / 2 + 0.2, -HZ - 0.04), RED_DK)
		end
		for _, x in { -3.0, -1.5, 0, 1.5, 3.0 } do
			B:block(R, v(0.16, WH - 0.7, 0.1), cf(x, Y0 + WH / 2 + 0.2, HZ + 0.04), RED_DK)
		end
		B:block(R, v(0.9, WH - 0.7, 0.1), cf(-2.25, Y0 + WH / 2 + 0.2, HZ + 0.04), RED_LT)
		-- cream corner boards + band under the eaves
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			B:block(R, v(0.6, WH, 0.6), cf(c[1] * HX, Y0 + WH / 2, c[2] * HZ), CREAM)
		end
		for _, s in { -1, 1 } do
			B:block(R, v(HX * 2 + 0.2, 0.4, 0.3), cf(0, YT - 0.2, s * (HZ + 0.06)), CREAM_DK)
			B:block(R, v(0.3, 0.4, HZ * 2 + 0.2), cf(s * (HX + 0.06), YT - 0.2, 0), CREAM_DK)
		end

		------------------------------------------------------------ gambrel roof
		local RL = HZ * 2 + 1.3 -- roof length along Z
		local EX, EY = 4.75, 6.15 -- eave
		local KX, KY = 3.2, 8.95 -- knee
		local RY = 10.55 -- ridge
		local function roofX(y)
			if y <= KY then
				return EX - (y - EY) * (EX - KX) / (KY - EY)
			end
			return KX * (RY - y) / (RY - KY)
		end
		local function panel(ax, ay, bx, by, s)
			local a, b = v(s * ax, ay, 0), v(s * bx, by, 0)
			B:bar(R, a, b, RL, 0.5, SLATE)
			-- outward normal in the XY plane
			local d = (b - a).Unit
			local n = v(d.Y, -d.X, 0)
			if n.Y < 0 then n = -n end
			local len = (b - a).Magnitude
			local rows = math.max(2, math.floor(len / 1.05))
			for i = 1, rows do
				local t0 = (i - 1) / rows + 0.04
				local t1 = i / rows - 0.12
				local p0 = a + (b - a) * t0 + n * 0.3
				local p1 = a + (b - a) * t1 + n * 0.3
				B:bar(R, p0, p1, RL + 0.1, 0.18, (i % 2 == 1) and SLATE_DK or SLATE_LT)
			end
		end
		for _, s in { -1, 1 } do
			panel(EX, EY, KX, KY, s)
			panel(KX, KY, -0.1, RY, s)
		end
		B:block(R, v(1.0, 0.45, RL + 0.2), cf(0, RY + 0.2, 0), SLATE_DK)
		-- stepped red gable walls (front + back)
		for _, s in { -1, 1 } do
			local y = YT
			local i = 0
			while y < RY - 0.3 do
				local y1 = math.min(y + 0.6, RY - 0.1)
				local hw = math.max(0.4, roofX(y1) - 0.05)
				i += 1
				B:block(R, v(hw * 2, y1 - y + 0.02, 0.6), cf(0, (y + y1) / 2, s * (HZ - 0.3)), (i % 2 == 0) and RED or RED_DK)
				y = y1
			end
			-- cream barge boards along the gable edge
			local z = s * (RL / 2 + 0.08)
			for _, sx in { -1, 1 } do
				B:bar(R, v(sx * (EX + 0.05), EY - 0.25, z), v(sx * KX, KY - 0.25, z), 0.32, 0.55, CREAM)
				B:bar(R, v(sx * KX, KY - 0.25, z), v(0, RY - 0.2, z), 0.32, 0.55, CREAM)
			end
		end

		------------------------------------------------------------ barn doors
		local FZ = -HZ - 0.1
		local DW, DH = 4.0, 4.4
		B:block(R, v(DW, DH, 0.1), cf(0, Y0 + DH / 2, -HZ - 0.02), DARK)
		for _, s in { -1, 1 } do
			local cx = s * DW / 4
			B:block(R, v(DW / 2 - 0.12, DH - 0.1, 0.22), cf(cx, Y0 + DH / 2, FZ), RED_DK)
			-- X brace + mid rail
			local x0, x1 = s * 0.2, s * (DW / 2 - 0.2)
			B:bar(R, v(x0, Y0 + 0.3, FZ - 0.14), v(x1, Y0 + DH - 0.3, FZ - 0.14), 0.32, 0.18, CREAM, { up = v(0, 0, -1) })
			B:bar(R, v(x1, Y0 + 0.3, FZ - 0.14), v(x0, Y0 + DH - 0.3, FZ - 0.14), 0.32, 0.18, CREAM, { up = v(0, 0, -1) })
			B:block(R, v(DW / 2 - 0.2, 0.3, 0.16), cf(cx, Y0 + DH / 2, FZ - 0.16), CREAM_DK)
			-- iron hinges + handle
			B:block(R, v(0.7, 0.22, 0.12), cf(s * (DW / 2 - 0.4), Y0 + DH - 0.7, FZ - 0.17), IRON)
			B:block(R, v(0.7, 0.22, 0.12), cf(s * (DW / 2 - 0.4), Y0 + 0.7, FZ - 0.17), IRON)
			B:block(R, v(0.2, 0.6, 0.2), cf(s * 0.35, Y0 + DH / 2 + 0.6, FZ - 0.22), IRON)
		end
		-- cream door frame
		B:block(R, v(DW + 0.9, 0.5, 0.36), cf(0, Y0 + DH + 0.2, FZ), CREAM)
		for _, s in { -1, 1 } do
			B:block(R, v(0.45, DH, 0.36), cf(s * (DW / 2 + 0.22), Y0 + DH / 2, FZ), CREAM)
		end
		B:block(R, v(0.18, DH - 0.1, 0.3), cf(0, Y0 + DH / 2, FZ - 0.05), CREAM_DK)

		------------------------------------------------------------ hay door
		local HY0, HY1 = 7.0, 8.75
		local HW = 1.1
		local GZ = -HZ - 0.02
		B:block(R, v(HW * 2, HY1 - HY0, 0.1), cf(0, (HY0 + HY1) / 2, GZ - 0.02), DARK)
		B:block(R, v(HW * 2 + 0.7, 0.35, 0.36), cf(0, HY1 + 0.15, GZ - 0.1), CREAM)
		B:block(R, v(HW * 2 + 0.8, 0.3, 0.5), cf(0, HY0 - 0.1, GZ - 0.15), CREAM)
		for _, s in { -1, 1 } do
			B:block(R, v(0.35, HY1 - HY0, 0.36), cf(s * (HW + 0.17), (HY0 + HY1) / 2, GZ - 0.1), CREAM)
		end
		-- open leaf, swung flat against the gable on the right
		local LX = HW + 0.35 + 1.0
		B:block(R, v(1.9, HY1 - HY0 - 0.1, 0.2), cf(LX, (HY0 + HY1) / 2, GZ - 0.12), RED_DK)
		B:block(R, v(2.0, 0.22, 0.26), cf(LX, HY1 - 0.12, GZ - 0.16), CREAM_DK)
		B:block(R, v(2.0, 0.22, 0.26), cf(LX, HY0 + 0.07, GZ - 0.16), CREAM_DK)
		B:bar(R, v(LX - 0.8, HY0 + 0.2, GZ - 0.26), v(LX + 0.8, HY1 - 0.25, GZ - 0.26), 0.26, 0.14, CREAM, { up = v(0, 0, -1) })
		B:bar(R, v(LX + 0.8, HY0 + 0.2, GZ - 0.26), v(LX - 0.8, HY1 - 0.25, GZ - 0.26), 0.26, 0.14, CREAM, { up = v(0, 0, -1) })
		-- hay spilling out of the loft
		B:block(R, v(1.9, 0.7, 1.0), cf(0, HY0 + 0.4, GZ - 0.35), HAY)
		B:block(R, v(1.3, 0.45, 0.8), cf(-0.2, HY0 + 0.95, GZ - 0.25), HAY_LT)
		B:block(R, v(0.18, 0.9, 0.18), cf(0.55, HY0 - 0.25, GZ - 0.7, 0, 0, 15), HAY_LT)
		B:block(R, v(0.18, 0.7, 0.18), cf(-0.6, HY0 - 0.2, GZ - 0.6, 0, 0, -20), HAY)
		B:block(R, v(0.7, 0.18, 0.18), cf(0.85, HY0 + 0.55, GZ - 0.85, 0, 30, 15), HAY_DK)
		-- pulley beam under the ridge, rope + hook
		B:block(R, v(0.5, 0.5, 1.9), cf(0, RY - 0.75, -HZ - 0.95), WOOD_DK)
		B:block(R, v(0.3, 0.7, 0.7), cf(0, RY - 1.25, -HZ - 1.6), IRON)
		B:block(R, v(0.12, 0.9, 0.12), cf(0, RY - 2.0, -HZ - 1.6), ROPE)
		B:block(R, v(0.12, 0.3, 0.4), cf(0, RY - 2.5, -HZ - 1.5), IRON)

		-- back gable: a cream-framed diamond vent with dark slats
		B:block(R, v(1.7, 1.7, 0.3), cf(0, 8.3, HZ + 0.05, 0, 0, 45), CREAM)
		B:block(R, v(1.2, 1.2, 0.3), cf(0, 8.3, HZ + 0.1, 0, 0, 45), DARK)
		for _, dy in { -0.3, 0.05, 0.4 } do
			B:block(R, v(1.1 - math.abs(dy) * 1.2, 0.14, 0.2), cf(0, 8.3 + dy - 0.05, HZ + 0.22), RED_DK)
		end

		------------------------------------------------------------ side windows + flower boxes
		for _, s in { -1, 1 } do
			local x = s * (HX + 0.08)
			B:block(R, v(0.16, 2.0, 2.2), cf(x, 3.9, 0), CREAM)
			B:block(R, v(0.16, 1.5, 1.7), cf(x + s * 0.04, 3.9, 0), GLASS)
			B:block(R, v(0.16, 0.5, 0.5), cf(x + s * 0.06, 4.25, -0.45), GLASS_LT)
			B:block(R, v(0.16, 1.5, 0.16), cf(x + s * 0.08, 3.9, 0), CREAM)
			B:block(R, v(0.16, 0.16, 1.7), cf(x + s * 0.08, 3.9, 0), CREAM)
			-- flower box
			B:block(R, v(0.6, 0.45, 2.3), cf(x + s * 0.3, 2.65, 0), WOOD)
			B:block(R, v(0.62, 0.12, 2.32), cf(x + s * 0.3, 2.5, 0), WOOD_DK)
			B:block(R, v(0.4, 0.3, 2.0), cf(x + s * 0.3, 3.0, 0), GRASS_DK)
			for i, z in { -0.7, 0, 0.7 } do
				B:block(R, v(0.4, 0.35, 0.4), cf(x + s * 0.3, 3.25, z, 0, 45, 0), (i == 2) and FLOWER_W or FLOWER_P)
			end
		end

		------------------------------------------------------------ cupola + weathervane
		local CY = RY + 0.35
		B:block(R, v(1.7, 1.1, 1.7), cf(0, CY + 0.55, 0.6), RED)
		B:block(R, v(1.75, 0.5, 1.0), cf(0, CY + 0.7, 0.6), CREAM_DK)
		B:block(R, v(1.0, 0.5, 1.75), cf(0, CY + 0.7, 0.6), CREAM_DK)
		B:block(R, v(2.3, 0.35, 2.3), cf(0, CY + 1.25, 0.6), SLATE_DK)
		B:block(R, v(1.6, 0.35, 1.6), cf(0, CY + 1.55, 0.6, 0, 45, 0), SLATE)
		B:block(R, v(0.8, 0.3, 0.8), cf(0, CY + 1.85, 0.6), SLATE_LT)
		B:block(R, v(0.16, 1.3, 0.16), cf(0, CY + 2.6, 0.6), IRON)
		B:block(R, v(0.16, 0.16, 1.7), cf(0, CY + 2.9, 0.6), GOLD)
		B:block(R, v(0.42, 0.42, 0.14), cf(0, CY + 2.9, -0.25, 0, 90, 45), GOLD)
		B:block(R, v(0.14, 0.5, 0.5), cf(0, CY + 2.9, 1.4), GOLD)

		------------------------------------------------------------ grounding
		-- worn door plank
		B:block(R, v(DW + 0.6, 0.2, 0.9), cf(0, 0.1, -HZ - 0.65), WOOD)
		B:block(R, v(DW + 0.4, 0.06, 0.2), cf(0, 0.22, -HZ - 0.65), WOOD_LT)
		-- loose straw under the hay door
		for i, s in { { -1.0, -6.0, 25 }, { 0.8, -5.7, -40 }, { 1.9, -6.5, 70 }, { -2.3, -6.6, -10 } } do
			B:block(R, v(1.0, 0.12, 0.25), cf(s[1], 0.06, s[2], 0, s[3], 0), (i % 2 == 0) and HAY_LT or HAY)
		end
		-- a little hay bale by the door
		local hb = CFrame.new(3.6, 0, -6.0) * CFrame.Angles(0, math.rad(-12), 0)
		B:block(R, v(2.2, 1.2, 1.4), hb * CFrame.new(0, 0.6, 0), HAY)
		B:block(R, v(0.14, 0.9, 1.1), hb * CFrame.new(1.12, 0.6, 0), HAY_DK)
		B:block(R, v(0.14, 0.9, 1.1), hb * CFrame.new(-1.12, 0.6, 0), HAY_DK)
		B:block(R, v(1.8, 0.14, 1.0), hb * CFrame.new(0, 1.22, 0), HAY_LT)
		B:block(R, v(0.18, 1.3, 1.5), hb * CFrame.new(-0.5, 0.6, 0), TWINE)
		B:block(R, v(0.18, 1.3, 1.5), hb * CFrame.new(0.5, 0.6, 0), TWINE)
		local function tuft(x, z, h, flower)
			B:block(R, v(0.45, h, 0.45), cf(x, h / 2, z), GRASS)
			B:block(R, v(0.4, h * 0.7, 0.4), cf(x + 0.32, h * 0.35 + 0.05, z + 0.18, 0, 0, -18), GRASS_DK)
			B:block(R, v(0.4, h * 0.75, 0.4), cf(x - 0.32, h * 0.37 + 0.05, z - 0.14, 0, 0, 18), GRASS)
			if flower then
				B:block(R, v(0.5, 0.28, 0.5), cf(x, h + 0.1, z), flower)
				B:block(R, v(0.22, 0.3, 0.22), cf(x, h + 0.12, z), FLOWER_Y)
			end
		end
		tuft(-3.5, -5.6, 1.0, FLOWER_W)
		tuft(4.9, -2.2, 0.9, FLOWER_P)
		tuft(-5.0, 1.8, 1.0)
		tuft(4.8, 3.6, 0.8)
		tuft(-2.0, 5.5, 0.9, FLOWER_P)
		B:block(R, v(1.0, 0.3, 0.8), cf(-5.3, 0.15, -2.4, 0, 20, 0), STONE)
		B:block(R, v(0.7, 0.24, 0.6), cf(2.6, 0.12, 5.6, 0, -25, 0), STONE_LT)
	end,
}
