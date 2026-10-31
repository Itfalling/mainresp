--!nocheck
-- Big Hay Stack (Harvest Fields scenery, big copy-paste filler ~11 studs).
-- A tall stepped stack of golden straw bales: nine on the ground, four on the
-- second course, two turned crosswise on the third and one crowning bale with
-- a shaggy loose-hay heap on top. Every bale is built like the Hay Bale
-- filler (wide body + tall core = rounded edges, shaded bottom seam,
-- bleached top, shaggy pale end caps where they show, two brown twine
-- bands) in fresh and sun-aged
-- tones. A wooden ladder leans against the front. Footing: flat straw drifts and loose straws, two little pumpkins,
-- grass tufts and a pebble. Anchored, weld-free, no scripts.
return {
	DisplayName = "Big Hay Stack",
	Rarity = "Scenery",
	Filler = true,
	Element = "Harvest Fields",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		-- palette (Harvest Fields hay / wagon / corn gate)
		local HAY_SH, HAY_DK, HAY, HAY_LT, HAY_HI = "#a87a24", "#c4922e", "#e6bd55", "#f4d98a", "#fbe8ae"
		local AGED, AGED_DK, AGED_LT = "#d4a443", "#b0822a", "#e8c773"
		local TWINE, TWINE_DK = "#8a5a2a", "#6a4220"
		local WOOD_DK, WOOD, WOOD_LT = "#6b4224", "#8a5a32", "#a8723f"
				local PUMP, PUMP_DK, PUMP_LT, STEM = "#ff9424", "#e06c18", "#ffb042", "#6b7d2a"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local STONE, STONE_LT = "#8d8174", "#a39787"

		local BL, BH, BD = 4.8, 2.4, 2.8 -- bale length / height / depth

		---------------------------------------------------------------- bale
		local function bale(x, y0, z, yaw, aged, ends)
			local main = aged and AGED or HAY
			local lt = aged and AGED_LT or HAY_LT
			local dk = aged and AGED_DK or HAY_DK
			local C = cf(x, y0, z, 0, yaw, 0)
			local function at(px, py, pz)
				return C * CFrame.new(px, py, pz)
			end
			B:block(R, v(BL, BH - 0.6, BD), at(0, BH / 2, 0), main) -- body
			B:block(R, v(BL - 0.02, BH, BD - 0.5), at(0, BH / 2, 0), main) -- core
			B:block(R, v(BL + 0.02, 0.22, BD + 0.02), at(0, 0.38, 0), dk) -- shaded seam
			B:block(R, v(BL - 0.3, 0.12, BD - 0.8), at(0, BH + 0.02, 0), lt) -- bleached top
			-- shaggy pale end caps on the ends that show
			for _, e in ends or {} do
				B:block(R, v(0.16, BH - 0.8, BD - 0.7), at(e * (BL / 2 + 0.05), BH / 2 + 0.05, 0), lt)
				B:block(R, v(0.12, 0.6, 1.1), at(e * (BL / 2 + 0.13), BH / 2 + 0.3, -e * 0.25), HAY_HI)
			end
			for _, bx in { -1.1, 1.15 } do
				B:block(R, v(0.24, BH - 0.54, BD + 0.08), at(bx, BH / 2, 0), TWINE)
				B:block(R, v(0.24, BH + 0.06, BD - 0.44), at(bx, BH / 2, 0), TWINE)
			end
		end

		---------------------------------------------------------------- the stack
		-- course 1: 3 x 3
		local c1 = {
			{ -5.0, -2.8, 0, false }, { 0.0, -2.8, 0, true }, { 5.0, -2.8, 0, false },
			{ -5.0, 0.0, 0, true }, { 0.0, 0.0, 0, false }, { 5.0, 0.0, 0, true },
			{ -5.0, 2.8, 0, false }, { 0.0, 2.8, 0, false }, { 5.0, 2.8, 0, true },
		}
		for _, b in c1 do
			bale(b[1], 0, b[2], b[3], b[4], b[1] < 0 and { -1 } or (b[1] > 0 and { 1 } or nil))
		end
		-- course 2: 2 x 2, stepped in on every side
		for _, b in { { -2.5, -1.4, 2, false }, { 2.5, -1.45, -2, true }, { -2.4, 1.45, -1, true }, { 2.6, 1.4, 1, false } } do
			bale(b[1], BH, b[2], b[3], b[4], { b[1] < 0 and -1 or 1 })
		end
		-- course 3: two bales turned crosswise
		bale(-1.45, BH * 2, 0.1, 90, false, { -1, 1 })
		bale(1.45, BH * 2, 0.1, 92, true, { -1, 1 })
		-- course 4: the crowning bale
		bale(0.2, BH * 3, 0.1, 8, false, { -1, 1 })

		-- loose hay heap on top (stepped, shaggy)
		local TOP = BH * 4
		B:block(R, v(3.6, 0.5, 2.2), cf(0.1, TOP + 0.25, 0.3, 0, 12, 0), HAY_DK)
		B:block(R, v(2.6, 0.5, 1.7), cf(0.2, TOP + 0.7, 0.2, 0, -10, 0), HAY)
		B:block(R, v(1.5, 0.45, 1.1), cf(0.0, TOP + 1.1, 0.35, 0, 25, 0), HAY_LT)
		local tufts = {
			{ v(-1.4, TOP + 0.4, 0.2), v(-2.3, TOP + 0.9, -0.2), HAY_HI }, { v(1.5, TOP + 0.4, 0.6), v(2.4, TOP + 0.8, 1.0), HAY_LT },
			{ v(0.2, TOP + 1.2, 0.3), v(0.4, TOP + 2.0, -0.1), HAY_HI }, { v(-0.3, TOP + 1.1, 0.6), v(-0.9, TOP + 1.8, 0.9), HAY_LT },
			{ v(0.6, TOP + 0.9, -0.4), v(1.2, TOP + 1.5, -0.9), HAY_HI },
		}
		for _, t in tufts do
			B:bar(R, t[1], t[2], 0.16, 0.16, t[3])
		end
		-- loose hay spilling down the ledges
		local spill = {
			{ -6.2, BH + 0.08, -3.5, 2.0, 1.4, 15, HAY_LT }, { 6.0, BH + 0.08, 3.4, 2.0, 1.4, -25, HAY },
			{ -6.4, BH + 0.08, 2.0, 1.6, 1.2, 50, HAY }, { 3.6, BH + 0.08, -3.6, 1.8, 1.2, -10, HAY_LT },
			{ -3.9, BH * 2 + 0.08, -1.0, 1.6, 1.4, 30, HAY_LT }, { 3.9, BH * 2 + 0.08, 1.2, 1.6, 1.4, -35, HAY },
			{ -1.4, BH * 3 + 0.08, -1.9, 1.6, 1.0, 10, HAY }, { 1.6, BH * 3 + 0.08, 2.0, 1.6, 1.0, -20, HAY_LT },
		}
		for _, s in spill do
			B:block(R, v(s[4], 0.16, s[5]), cf(s[1], s[2], s[3], 0, s[6], 0), s[7])
			B:bar(R, v(s[1], s[2] + 0.1, s[3]), v(s[1] + 0.9, s[2] + 0.35, s[3] - 0.6), 0.14, 0.14, HAY_HI)
		end

		---------------------------------------------------------------- ladder
		-- leaning on the front of course 3, feet on the ground in front
		local LX = 1.6
		local foot, top = v(0, 0, -7.7), v(0, BH * 3 + 0.7, -2.6)
		for s = -1, 1, 2 do
			B:bar(R, foot + v(LX + s * 0.65, 0, 0), top + v(LX + s * 0.65, 0.5, 0), 0.32, 0.32, s < 0 and WOOD or WOOD_DK)
		end
		for k = 1, 6 do
			local t = (k - 0.4) / 6.3
			local p = foot:Lerp(top, t)
			B:block(R, v(1.6, 0.24, 0.3), CFrame.new(p + v(LX, 0.2, -0.05)), k % 2 == 0 and WOOD_LT or WOOD)
		end

		---------------------------------------------------------------- footing
		-- flat straw drifts that blend the stack into the ground
		local drifts = {
			{ -8.0, 2.6, 1.6, 2.6, 20, HAY_DK }, { 8.0, -2.2, 1.6, 2.4, -30, HAY }, { -4.0, -4.9, 2.8, 1.4, 8, HAY },
			{ 4.4, 4.9, 2.6, 1.4, -12, HAY_DK }, { 0.4, 4.8, 1.8, 1.2, 35, HAY_LT }, { 7.6, 3.8, 1.4, 1.0, 60, HAY_LT },
			{ 4.6, -4.8, 2.0, 1.2, -20, HAY_DK }, { -7.6, -3.6, 1.4, 1.2, 40, HAY_LT },
		}
		for _, d in drifts do
			B:block(R, v(d[3], 0.14, d[4]), cf(d[1], 0.07, d[2], 0, d[5], 0), d[6])
		end
		local straws = {
			{ -8.6, -1.4, 1.3, 30, HAY_LT }, { -2.2, -5.8, 1.2, -50, HAY }, { 3.0, -6.0, 1.2, 10, HAY_LT },
			{ 8.8, 0.6, 1.1, 65, HAY_LT }, { -1.0, 5.6, 1.3, -20, HAY_LT }, { 6.4, -5.4, 0.9, 80, HAY },
			{ -5.6, 5.2, 1.1, 40, HAY }, { 0.2, -6.6, 1.0, -70, HAY_LT },
		}
		for _, s in straws do
			B:block(R, v(s[3], 0.12, 0.2), cf(s[1], 0.12, s[2], 0, s[4], 0), s[5])
		end
		-- two little pumpkins at the foot
		local function pumpkin(x, z, w, yaw)
			local h = w * 0.78
			local C = cf(x, h / 2, z, 0, yaw, 0)
			B:block(R, v(w, h, w * 0.7), C, PUMP_DK)
			B:block(R, v(w * 0.7, h + 0.04, w), C, PUMP)
			B:block(R, v(w * 0.46, 0.2, w * 0.46), C * CFrame.new(0, h / 2 + 0.06, 0), PUMP_LT)
			B:block(R, v(0.3, 0.55, 0.3), C * CFrame.new(0, h / 2 + 0.3, 0) * CFrame.Angles(0, 0, rad(12)), STEM)
		end
		pumpkin(-3.6, -5.4, 1.8, 20)
		pumpkin(6.6, -5.0, 1.3, -30)
		pumpkin(-2.1, -6.0, 1.0, 45)
		for _, g in { { -8.4, 1.0, 10 }, { 8.6, -1.6, 40 }, { -0.4, -5.2, 70 }, { 2.6, 5.2, 25 }, { -4.6, 4.8, 55 } } do
			B:block(R, v(0.45, 1.0, 0.45), cf(g[1], 0.5, g[2], 6, g[3], 8), GRASS)
			B:block(R, v(0.35, 0.7, 0.35), cf(g[1] + 0.35, 0.35, g[2] + 0.2, -6, g[3] + 25, -10), GRASS_DK)
		end
		B:block(R, v(0.9, 0.42, 0.7), cf(8.3, 0.21, 2.0, 0, 25, 0), STONE)
		B:block(R, v(0.5, 0.24, 0.4), cf(8.1, 0.5, 2.05, 0, 50, 0), STONE_LT)
	end,
}
