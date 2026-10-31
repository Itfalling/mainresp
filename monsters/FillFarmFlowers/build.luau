--!nocheck
-- Flower Patch (Sunny Farm filler, v2). A small loose patch of tulips (red,
-- yellow, white) in three heights, the way the farm crops are built:
-- * each tulip head is a rounded cup (a square + the same square turned 45
--   degrees) in the main colour, a darker base, four lighter petal tips
--   standing up round the rim and a dark inner centre
-- * two-tone stems; long blade leaves (angled bars, light + dark green)
-- * grounding: a low irregular soil patch, low grass tufts and two pebbles
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Flower Patch",
	Rarity = "Filler",
	Filler = true,
	Element = "Sunny Farm",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		-- Sunny Farm palette (CropCarrot / DecorFarmWell)
		local DIRT, DIRT_DK = "#7b4a28", "#5e381d"
		local STEM, STEM_DK = "#4fd23f", "#2f9f34"
		local LEAF_LT, LEAF, LEAF_DK = "#5fd23f", "#3fb43a", "#2a8f33"
		local GRASS, GRASS_DK = "#5fd23f", "#3fb43a"
		local STONE_LT, STONE = "#c3c9cf", "#9aa3ad"
		local COLS = {
			-- shadow, main, highlight tips, centre
			red = { "#b8141c", "#e8242c", "#ff6a5c", "#7a0e14" },
			yellow = { "#e6a817", "#ffcc1f", "#fff07a", "#c27a0e" },
			white = { "#d9dde3", "#f4f4f4", "#ffffff", "#ffd93b" },
		}

		------------------------------------------------------------ soil patch
		B:block(R, v(2.6, 0.12, 1.8), cf(0.1, 0.06, 0, 0, 10, 0), DIRT_DK)
		B:block(R, v(1.8, 0.16, 2.5), cf(-0.1, 0.08, 0.05, 0, 10, 0), DIRT)
		B:block(R, v(0.6, 0.2, 0.45), cf(0.9, 0.1, 0.75, 0, 35, 0), DIRT_DK)

		------------------------------------------------------------ tulips
		local function tulip(x, z, h, col, ry, lean)
			local c = COLS[col]
			local top = CFrame.new(x, 0, z) * CFrame.Angles(math.rad(lean or 0), math.rad(ry), 0)
			B:block(R, v(0.2, h, 0.2), top * CFrame.new(0, h / 2, 0), STEM)
			B:block(R, v(0.24, h * 0.35, 0.24), top * CFrame.new(0, h * 0.175, 0), STEM_DK)
			local head = top * CFrame.new(0, h, 0)
			B:block(R, v(0.42, 0.22, 0.42), head * CFrame.new(0, 0.08, 0), c[1])
			B:block(R, v(0.62, 0.5, 0.62), head * CFrame.new(0, 0.42, 0), c[2])
			B:block(R, v(0.62, 0.5, 0.62), head * CFrame.new(0, 0.42, 0) * CFrame.Angles(0, math.rad(45), 0), c[2])
			for k = 0, 3 do
				local a = math.rad(k * 90)
				B:block(R, v(0.24, 0.3, 0.24), head * CFrame.new(math.cos(a) * 0.3, 0.75, math.sin(a) * 0.3) * CFrame.Angles(0, -a, 0), c[3])
			end
			B:block(R, v(0.34, 0.08, 0.34), head * CFrame.new(0, 0.68, 0), c[4])
		end
		tulip(-0.15, 0.2, 1.85, "red", 10)
		tulip(-0.85, -0.45, 1.45, "yellow", 30, -8)
		tulip(0.6, -0.55, 1.6, "white", 5, 8)
		tulip(0.95, 0.45, 1.25, "red", 20)
		tulip(-0.95, 0.75, 1.15, "white", 40)
		tulip(0.15, -1.15, 1.05, "red", 15, 10)
		tulip(0.35, 1.05, 1.5, "yellow", 25, -6)

		------------------------------------------------------------ leaves
		local leaves = {
			-- base x, z, tip offset x, height, z, colour
			{ -0.4, -0.05, -0.55, 1.0, -0.35, LEAF },
			{ 0.25, -0.3, 0.6, 0.85, -0.45, LEAF_DK },
			{ 0.55, 0.35, 0.5, 0.9, 0.45, LEAF },
			{ -0.55, 0.45, -0.5, 0.75, 0.55, LEAF_DK },
			{ 0.05, 0.6, 0.1, 1.05, 0.6, LEAF_LT },
			{ -0.25, -0.75, -0.3, 0.7, -0.5, LEAF },
		}
		for _, l in leaves do
			local a = v(l[1], 0.12, l[2])
			local m = a + v(l[3] * 0.45, l[4] * 0.6, l[5] * 0.45)
			local t = a + v(l[3], l[4], l[5])
			B:bar(R, a, m, 0.42, 0.14, l[6])
			B:bar(R, m - (m - a) * 0.08, t, 0.3, 0.12, (l[6] == LEAF_DK) and LEAF or LEAF_LT)
		end

		------------------------------------------------------------ grounding
		local function tuft(x, z, hgt, ry)
			local base = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(ry), 0)
			B:block(R, v(0.28, hgt, 0.28), base * CFrame.new(0, hgt / 2, 0), GRASS)
			B:block(R, v(0.24, hgt * 0.75, 0.24), base * CFrame.new(0.24, hgt * 0.36, 0.05) * CFrame.Angles(0, 0, math.rad(-20)), GRASS_DK)
			B:block(R, v(0.24, hgt * 0.65, 0.24), base * CFrame.new(-0.22, hgt * 0.32, -0.05) * CFrame.Angles(0, 0, math.rad(22)), GRASS)
		end
		tuft(1.45, -0.3, 0.6, 20)
		tuft(-1.45, 0.1, 0.55, -30)
		B:block(R, v(0.42, 0.2, 0.34), cf(-0.75, 0.1, -1.25, 0, 25, 0), STONE)
		B:block(R, v(0.3, 0.14, 0.26), cf(1.25, 0.07, 1.1, 0, -15, 0), STONE_LT)
	end,
}
