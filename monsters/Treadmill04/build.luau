--!nocheck
-- Wooden Garden Treadmill (tier 3 of the treadmill ladder). A cosy garden
-- machine: plank-built wooden frame with dark corner posts and brass bolts, a
-- belt of honey-wood slats, wooden cart-wheel rollers, two side flower boxes
-- (pink / yellow / white / purple blooms), a leafy trellis arch with blooms, ivy on the uprights, meshing wooden gears on the hood front, sprout-shaped
-- green speed bars and a colourful pinwheel stuck in the flower box.
-- Faces -Z (console at the front).
-- Animated: belt slats (Belt), 4 cart wheels, 2 meshing gears, Pinwheel,
-- 6 flowers swaying, sprout bars / sun LED.
return {
	DisplayName = "Wooden Garden Treadmill",
	Rarity = "Uncommon",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local WOOD_L, WOOD, WOOD_D, BARK = "#e0aa6c", "#b97c43", "#83532a", "#5a381c"
		local SLAT, BED = "#e9bb7a", "#3b2614"
		local LEAF, LEAF_D, LEAF_L = "#4fc23c", "#2e8f2c", "#93e35c"
		local SOIL, STONE, STONE_D = "#5a3b22", "#a3abb4", "#7c858f"
		local BRASS, IRON = "#e0b040", "#3a3c42"
		local PINK, YELLOW, WHITE, PURPLE, SKY = "#ff7eb6", "#ffd23a", "#fff8ec", "#b67bff", "#5cc8ff"

		-- stone feet
		B:sym(function()
			for _, z in { -4.4, 4.3 } do
				B:block("Root", v(1.0, 0.3, 1.0), cf(2.0, 0.15, z), STONE_D)
				B:block("Root", v(0.8, 0.1, 0.8), cf(2.0, 0.34, z), STONE)
			end
		end)

		-- deck: dark core, stacked side planks in two tones, corner posts + brass bolts
		B:block("Root", v(4.7, 1.0, 9.5), cf(0, 0.8, -0.05), WOOD_D)
		B:sym(function()
			B:block("Root", v(0.14, 0.34, 9.3), cf(2.39, 1.1, -0.05), WOOD_L)
			B:block("Root", v(0.14, 0.32, 9.3), cf(2.38, 0.77, -0.05), WOOD)
			B:block("Root", v(0.14, 0.3, 9.3), cf(2.39, 0.46, -0.05), WOOD_L)
			for _, z in { -4.62, 4.52 } do
				B:block("Root", v(0.5, 1.15, 0.5), cf(2.3, 0.85, z), BARK)
				B:block("Root", v(0.56, 0.12, 0.56), cf(2.3, 1.45, z), WOOD_D)
			end
			B:block("Root", v(0.08, 0.16, 0.16), cf(2.47, 0.77, 0), BRASS)
			-- leaf sprigs on the deck corners
			B:block("Root", v(0.5, 0.5, 0.5), cf(2.35, 1.55, 4.0, 0, 30, 20), LEAF)
			B:block("Root", v(0.36, 0.36, 0.36), cf(2.55, 1.35, 3.6, 0, -20, 10), LEAF_D)
		end)
		-- belt bed
		B:block("Root", v(3.5, 0.1, 7.6), cf(0, 1.28, 0.2), BED)

		-- moving belt of honey-wood slats (slide +Z one gap, then repeat)
		local belt = B:bone("Belt", "Root", v(0, 1.33, 0))
		for i = 0, 15 do
			B:block(belt, v(3.4, 0.07, 0.3), cf(0, 1.365, -3.75 + i * 0.5), SLAT)
		end

		-- side foot rails: planks with seams
		B:sym(function()
			B:block("Root", v(0.85, 0.3, 7.15), cf(2.17, 1.33, 0.17), WOOD)
			for i = 0, 2 do
				B:block("Root", v(0.87, 0.06, 0.12), cf(2.17, 1.46, -1.9 + i * 2.1), WOOD_D)
			end
		end)

		-- motor hood: plank box with a leafy lid
		B:block("Root", v(4.7, 1.0, 1.5), cf(0, 1.5, -4.1), WOOD)
		B:block("Root", v(4.75, 0.1, 1.52), cf(0, 1.35, -4.1), WOOD_D)
		B:block("Root", v(4.75, 0.1, 1.52), cf(0, 1.7, -4.1), WOOD_D)
		B:block("Root", v(4.5, 0.22, 1.35), cf(0, 2.1, -4.15), WOOD_L)
		B:block("Root", v(3.6, 0.14, 1.0), cf(0, 2.27, -4.2), LEAF_D)
		for i = -4, 4, 2 do
			B:block("Root", v(0.5, 0.22, 0.5), cf(i * 0.4, 2.36, -4.2 + (i % 2) * 0.2, 0, 45, 0), i % 2 == 0 and LEAF or LEAF_L)
		end
		-- meshing gears on the hood front (backing plate + 2 gears on bones)
		B:block("Root", v(2.3, 0.9, 0.08), cf(-0.38, 1.5, -4.88), "#3f2612")
		local function gear(name, x, y, rBody, teeth, col, col2)
			local c = cf(x, y, -5.0)
			local g = B:bone(name, "Root", c)
			B:block(g, v(rBody * 1.6, rBody * 1.6, 0.14), c, col)
			B:block(g, v(rBody * 1.6, rBody * 1.6, 0.14), c * ang(0, 0, 45), col)
			B:ring(g, c * ang(90, 0, 0), rBody + 0.08, teeth, v(0.16, 0.12, 0.22), col2)
			B:block(g, v(0.22, 0.22, 0.12), c * CFrame.new(0, 0, -0.08), col == BRASS and BARK or BRASS)
		end
		gear("GearA", -0.85, 1.48, 0.42, 8, WOOD_L, BARK)
		gear("GearB", 0.08, 1.56, 0.31, 6, BRASS, "#a87a22")
		B:sym(function()
			B:block("Root", v(0.45, 0.45, 0.45), cf(1.75, 1.3, -4.9, 0, 0, 30), LEAF)
			B:block("Root", v(0.3, 0.3, 0.3), cf(1.45, 1.1, -4.92, 0, 0, 15), LEAF_D)
		end)

		-- rear end cap: plank with brass lantern lights
		B:block("Root", v(4.7, 0.6, 0.85), cf(0, 1.2, 4.32), WOOD)
		B:block("Root", v(4.4, 0.14, 0.75), cf(0, 1.56, 4.32), WOOD_L)
		B:block("Root", v(4.72, 0.08, 0.87), cf(0, 1.05, 4.32), WOOD_D)
		B:sym(function()
			B:block("Root", v(0.4, 0.3, 0.1), cf(1.4, 1.2, 4.78), BRASS)
			B:block("Root", v(0.26, 0.18, 0.06), cf(1.4, 1.2, 4.84), "#ffd27a")
		end)

		-- wooden cart-wheel rollers (spin): bark rim, plank spokes, brass hub
		for _, h in { { "HubFR", 2.5, 1.1, -4.1 }, { "HubFL", -2.5, 1.1, -4.1 }, { "HubRR", 2.5, 1.0, 4.32 }, { "HubRL", -2.5, 1.0, 4.32 } } do
			local b = B:bone(h[1], "Root", v(h[2], h[3], h[4]))
			local sx = h[2] > 0 and 1 or -1
			local c = cf(h[2], h[3], h[4])
			B:ring(b, c * ang(0, 0, 90), 0.44, 8, v(0.2, 0.2, 0.24), BARK)
			B:block(b, v(0.14, 0.8, 0.12), c, WOOD_L)
			B:block(b, v(0.14, 0.12, 0.8), c, WOOD_L)
			B:block(b, v(0.24, 0.26, 0.26), c * CFrame.new(sx * 0.04, 0, 0), BRASS)
		end

		-- log uprights with ivy
		B:sym(function()
			B:block("Root", v(0.95, 0.45, 0.95), cf(2.1, 2.3, -4.45), BARK)
			B:bar("Root", v(2.1, 2.0, -4.5), v(2.1, 5.6, -4.0), 0.68, 0.68, WOOD)
			B:bar("Root", v(2.1, 3.0, -4.37), v(2.1, 3.25, -4.33), 0.76, 0.76, BARK)
			B:bar("Root", v(2.1, 4.4, -4.17), v(2.1, 4.65, -4.13), 0.76, 0.76, BARK)
			for i, o in { { 0.38, 2.8, 0 }, { 0.3, 3.5, 0.25 }, { 0.4, 4.2, -0.1 }, { 0.28, 4.95, 0.2 } } do
				B:block("Root", v(0.36, 0.36, 0.36), cf(2.1 + o[1], o[2], -4.42 + (o[2] - 2) * 0.14 + o[3], 0, 45, 0), i % 2 == 0 and LEAF or LEAF_D)
			end
		end)

		-- console: wooden box, chalkboard screen, sprout speed bars
		local con = cf(0, 5.95, -3.9) * ang(-30, 0, 0)
		local function cp(x, y, z) return con * CFrame.new(x, y, z) end
		B:block("Root", v(5.3, 1.15, 1.4), con, WOOD)
		B:block("Root", v(5.4, 0.12, 1.5), cp(0, 0.2, 0), WOOD_D)
		B:block("Root", v(5.4, 0.22, 1.5), cp(0, 0.62, 0), WOOD_L)
		B:block("Root", v(5.2, 0.12, 1.42), cp(0, -0.6, 0), WOOD_D)
		B:block("Root", v(3.6, 0.9, 0.06), cp(-0.55, 0.02, 0.71), "#24402c")
		B:block("Root", v(3.75, 0.08, 0.1), cp(-0.55, 0.5, 0.72), WOOD_D)
		B:block("Root", v(3.75, 0.08, 0.1), cp(-0.55, -0.46, 0.72), WOOD_D)
		for i = 1, 8 do
			local hgt = 0.14 + (i - 1) * 0.07
			local x = -2.05 + (i - 1) * 0.38
			B:block("Root", v(0.12, hgt, 0.06), cp(x, -0.34 + hgt / 2, 0.75), "#6dff5a", { mat = "Neon", name = "Bar" .. i })
			B:block("Root", v(0.24, 0.1, 0.06), cp(x + 0.1, -0.34 + hgt - 0.02, 0.76), "#b4ff6a", { mat = "Neon", name = "Bud" .. i })
		end
		-- sun LED + wooden buttons
		B:block("Root", v(0.34, 0.34, 0.08), cp(1.75, 0.18, 0.72), YELLOW, { mat = "Neon", name = "Sun" })
		B:block("Root", v(0.5, 0.5, 0.06), cp(1.75, 0.18, 0.7, 0, 0, 0) * ang(0, 0, 45), "#ffb02e")
		B:block("Root", v(0.36, 0.26, 0.12), cp(1.45, -0.27, 0.72), LEAF)
		B:block("Root", v(0.36, 0.26, 0.12), cp(2.05, -0.27, 0.72), "#ff5a5a")

		-- console window box with flowers along the top
		B:block("Root", v(4.0, 0.4, 0.6), cp(0, 0.9, -0.2), WOOD_D)
		B:block("Root", v(3.8, 0.08, 0.5), cp(0, 1.12, -0.2), SOIL)
		for i = -4, 4, 2 do
			B:block("Root", v(0.48, 0.38, 0.48), cp(i * 0.42, 1.25, -0.2 + (i % 2) * 0.1) * ang(0, 45, 0), i % 2 == 0 and LEAF or LEAF_D)
		end

		-- handrails: wood bars with leaf-green grips
		B:sym(function()
			local x = 2.45
			B:bar("Root", v(2.15, 5.35, -3.95), v(x, 5.2, -3.4), 0.46, 0.46, WOOD)
			B:bar("Root", v(x, 5.2, -3.4), v(x, 4.5, -0.5), 0.42, 0.42, WOOD)
			B:bar("Root", v(x, 5.07, -2.85), v(x, 4.62, -1.0), 0.54, 0.54, LEAF_D)
			B:bar("Root", v(x, 4.96, -2.4), v(x, 4.88, -2.1), 0.6, 0.6, LEAF)
			B:bar("Root", v(x, 4.58, -0.85), v(x, 4.46, -0.4), 0.5, 0.5, BARK)
			B:block("Root", v(0.36, 0.36, 0.36), cf(x, 5.45, -3.3, 0, 45, 0), LEAF_L)
		end)

		-- leafy trellis arch over the console with blooms
		B:sym(function()
			B:bar("Root", v(2.55, 5.8, -4.45), v(2.55, 7.6, -4.45), 0.4, 0.4, WOOD_D)
			B:block("Root", v(0.5, 0.2, 0.5), cf(2.55, 7.55, -4.45), BARK)
			B:block("Root", v(0.42, 0.42, 0.42), cf(2.75, 6.4, -4.45, 0, 45, 0), LEAF)
			B:block("Root", v(0.34, 0.34, 0.34), cf(2.35, 7.0, -4.3, 0, 45, 0), LEAF_D)
		end)
		B:block("Root", v(5.8, 0.4, 0.5), cf(0, 7.8, -4.45), WOOD)
		B:block("Root", v(6.0, 0.14, 0.6), cf(0, 8.05, -4.45), WOOD_D)
		for i = -5, 5, 2 do
			local s = 0.4 + (i % 3) * 0.08
			B:block("Root", v(s, s, s), cf(i * 0.55, 8.2 + (i % 2) * 0.08, -4.45 + ((i % 3) - 1) * 0.15, 0, 45, 0), i % 2 == 0 and LEAF or (i % 3 == 0 and LEAF_L or LEAF_D))
		end
		for _, x in { -2.2, -0.9, 1.3 } do
			B:block("Root", v(0.3, 0.3, 0.3), cf(x, 8.42, -4.45), x < 0 and PINK or YELLOW)
		end

		-- side flower boxes with swaying blooms
		local fi = 0
		local function flower(x, z, h, petal)
			fi += 1
			local f = B:bone("Flower" .. fi, "Root", v(x, 1.15, z))
			B:block(f, v(0.1, h, 0.1), cf(x, 1.15 + h / 2, z), LEAF_D)
			B:block(f, v(0.62, 0.2, 0.62), cf(x, 1.2 + h, z), petal)
			B:block(f, v(0.46, 0.22, 0.46), cf(x, 1.2 + h, z, 0, 45, 0), petal)
			B:block(f, v(0.24, 0.26, 0.24), cf(x, 1.25 + h, z), YELLOW == petal and "#ff8a2e" or YELLOW)
		end
		B:sym(function(side)
			B:block("Root", v(1.25, 0.95, 2.6), cf(3.18, 0.6, 2.1), WOOD)
			B:block("Root", v(1.3, 0.12, 2.65), cf(3.18, 0.85, 2.1), WOOD_D)
			B:block("Root", v(1.35, 0.14, 2.7), cf(3.18, 1.1, 2.1), WOOD_L)
			B:block("Root", v(1.05, 0.1, 2.4), cf(3.18, 1.13, 2.1), SOIL)
			for i = 0, 2, 2 do
				B:block("Root", v(0.4, 0.3, 0.4), cf(3.0 + (i % 2) * 0.35, 1.25, 1.2 + i * 0.9, 0, 45, 0), i % 2 == 0 and LEAF or LEAF_D)
			end
		end)
		flower(3.0, 1.3, 0.9, PINK)
		flower(3.35, 2.05, 1.2, YELLOW)
		flower(3.05, 3.0, 0.75, WHITE)
		flower(-3.0, 1.25, 1.1, PURPLE)
		flower(-3.35, 2.05, 0.8, PINK)
		flower(-3.0, 2.95, 1.2, WHITE)

		-- watering can by the left box
		B:block("Root", v(0.55, 0.5, 0.7), cf(-3.95, 0.25, 0.4), SKY)
		B:block("Root", v(0.6, 0.08, 0.75), cf(-3.95, 0.52, 0.4), "#3a9de0")
		B:bar("Root", v(-3.95, 0.3, 0.0), v(-3.95, 0.75, -0.45), 0.12, 0.12, SKY)
		B:block("Root", v(0.1, 0.35, 0.45), cf(-3.95, 0.75, 0.6), "#3a9de0")

		-- garden pinwheel stuck in the right flower box (spins)
		B:block("Root", v(0.14, 2.2, 0.14), cf(3.6, 2.15, 2.5), WOOD_L)
		local pp = cf(3.6, 3.2, 2.5) * ang(0, -35, 0) * CFrame.new(0, 0, -0.1)
		local pw = B:bone("Pinwheel", "Root", pp)
		for k, col in { PINK, YELLOW, SKY, LEAF_L } do
			local r = pp * ang(0, 0, 90 * (k - 1))
			B:block(pw, v(0.44, 0.88, 0.06), r * CFrame.new(0.24, 0.48, 0), col)
			B:block(pw, v(0.36, 0.36, 0.06), r * CFrame.new(0.6, 0.76, 0.02), col)
		end
		B:block(pw, v(0.24, 0.24, 0.14), pp * CFrame.new(0, 0, -0.07), WHITE)
	end,
}
