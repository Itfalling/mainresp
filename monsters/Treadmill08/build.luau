-- Treadmill08 "Gold Treadmill" (Epic): gold & white luxe frame, gem buttons,
-- a jewelled crown on the console, sparkles, spinning gold rollers + side gears.
-- Faces -Z (console at the front). Belt slats on "Belt" slide +Z one gap per step.
return {
	DisplayName = "Gold Treadmill",
	Rarity = "Epic",
	Element = "Gym",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local G1, G2, G3 = "#ffe066", "#f2b22a", "#b9770f" -- gold light / main / dark
		local W1, W2, W3 = "#fffdf5", "#efe7d4", "#cdbf9f" -- white / cream / shadow
		local BELT, SLAT, SLAT2 = "#3a1a2b", "#d9a334", "#f5cf5a"
		local INK = "#1d1420"
		local VEL = "#a3123a" -- royal velvet
		local RUBY, SAPH, EMER, AMET = "#ff2d5a", "#2f86ff", "#2dff96", "#c75cff"
		local function lerp(a, b, t) return a + (b - a) * t end

		---------------------------------------------------------------- base
		-- stepped gold feet
		for _, x in { -2.2, 2.2 } do
			for _, z in { -4.5, 4.4 } do
				B:block("Root", v(1.0, 0.3, 1.0), cf(x, 0.15, z), G3)
				B:block("Root", v(0.8, 0.2, 0.8), cf(x, 0.4, z), G2)
			end
		end
		-- white plinth with gold trim bands
		B:block("Root", v(4.9, 0.7, 9.5), cf(0, 0.85, 0), W2)
		B:block("Root", v(5.05, 0.2, 9.65), cf(0, 0.6, 0), G2)
		B:block("Root", v(5.0, 0.12, 9.6), cf(0, 1.22, 0), W1)
		-- recessed side panels (colour blocking) with gold medallions
		B:sym(function(side)
			local s = 1 -- B:sym mirrors the left side
			B:block("Root", v(0.1, 0.36, 6.4), cf(s * 2.48, 0.92, 0.4), W3)
		end)

		-- belt bed + moving gold slats
		B:block("Root", v(3.5, 0.1, 7.8), cf(0, 1.25, 0.25), BELT)
		local belt = B:bone("Belt", "Root", v(0, 1.3, 0))
		for i = 0, 15 do
			B:block(belt, v(3.4, 0.06, 0.2), cf(0, 1.33, -3.6 + i * 0.5), i % 2 == 0 and SLAT or SLAT2)
		end

		-- foot rails: white with a gold cap and inset gems
		B:sym(function(side)
			local s = 1 -- B:sym mirrors the left side
			B:block("Root", v(0.75, 0.32, 7.6), cf(s * 2.12, 1.4, 0.25), W1)
			B:block("Root", v(0.4, 0.08, 7.4), cf(s * 2.12, 1.6, 0.25), G1)
			B:block("Root", v(0.08, 0.14, 7.5), cf(s * 2.52, 1.36, 0.25), G2)
		end)

		-- inset rail gems (chase toward the back) + gold diamond studs on the plinth
		for _, s in { 1, -1 } do
			for k, z in { -2.9, -1.3, 0.3, 1.9, 3.5 } do
				B:gem("Root", v(0.1, 0.16, 0.24), cf(s * 2.57, 1.36, z), k % 2 == 1 and RUBY or SAPH, { name = ("RailGem%s%d"):format(s == 1 and "R" or "L", k) })
			end
			for _, z in { -0.85, 1.65 } do
				B:block("Root", v(0.12, 0.42, 0.42), cf(s * 2.53, 0.92, z) * ang(45, 0, 0), G2)
				B:block("Root", v(0.14, 0.2, 0.2), cf(s * 2.55, 0.92, z) * ang(45, 0, 0), G1)
			end
		end

		-- front motor hood (stepped) + gold crest
		B:block("Root", v(5.0, 1.0, 1.6), cf(0, 1.55, -4.05), W2)
		B:block("Root", v(4.8, 0.3, 1.4), cf(0, 2.15, -4.05), W1)
		B:block("Root", v(5.1, 0.2, 1.65), cf(0, 1.15, -4.05), G2)
		B:block("Root", v(3.6, 0.12, 1.2), cf(0, 2.36, -4.05), G1)
		B:block("Root", v(3.2, 0.14, 0.9), cf(0, 2.45, -4.05), VEL)
		B:block("Root", v(3.3, 0.06, 0.06), cf(0, 2.5, -4.52), G1)
		-- crest on the front face: stepped gold shield + ruby
		B:block("Root", v(1.4, 0.7, 0.1), cf(0, 1.6, -4.88), G2)
		B:block("Root", v(1.0, 0.25, 0.1), cf(0, 1.15, -4.88), G2)
		B:block("Root", v(1.1, 0.5, 0.06), cf(0, 1.62, -4.95), G1)
		B:gem("Root", v(0.35, 0.3, 0.08), cf(0, 1.62, -5.0), RUBY, { name = "Crest" })
		-- rear cap
		B:block("Root", v(5.0, 0.6, 0.9), cf(0, 1.3, 4.4), W2)
		B:block("Root", v(5.05, 0.14, 0.95), cf(0, 1.66, 4.4), G2)
		B:block("Root", v(3.4, 0.2, 0.1), cf(0, 1.3, 4.88), G1)

		---------------------------------------------------------- gold rollers
		-- big 8-point gold rollers front & back, both sides (they spin with the belt)
		local rollers = { { "RollFR", 1, 1.45, -4.05 }, { "RollFL", -1, 1.45, -4.05 }, { "RollRR", 1, 1.15, 4.4 }, { "RollRL", -1, 1.15, 4.4 } }
		for _, r in rollers do
			local x = r[2] * 2.62
			local b = B:bone(r[1], "Root", v(x, r[3], r[4]))
			local c = cf(x, r[3], r[4])
			B:block(b, v(0.2, 0.95, 0.95), c, G2)
			B:block(b, v(0.2, 0.95, 0.95), c * ang(45, 0, 0), G1)
			B:block(b, v(0.28, 0.45, 0.45), c, W1)
			B:gem(b, v(0.32, 0.22, 0.22), c, r[2] == 1 and RUBY or SAPH)
		end
		-- small spinning drive gears along the plinth sides
		for i, z in { -2.1, 0.4, 2.9 } do
			for _, s in { 1, -1 } do
				local nm = ("Gear%d%s"):format(i, s == 1 and "R" or "L")
				local x = s * 2.56
				local b = B:bone(nm, "Root", v(x, 0.92, z))
				local c = cf(x, 0.92, z)
				B:block(b, v(0.12, 0.62, 0.22), c, G2)
				B:block(b, v(0.12, 0.22, 0.62), c, G2)
				B:block(b, v(0.16, 0.3, 0.3), c * ang(45, 0, 0), G1)
			end
		end
		B:trail("RollFR", v(2.75, 1.92, -4.05), v(2.75, 1.7, -4.05), { color = { G1, "#ffffff" }, life = 0.2, width = { 1, 0 }, name = "TrailR" })
		B:trail("RollFL", v(-2.75, 1.92, -4.05), v(-2.75, 1.7, -4.05), { color = { G1, "#ffffff" }, life = 0.2, width = { 1, 0 }, name = "TrailL" })

		-------------------------------------------------------------- columns
		-- classical white columns with gold bands, leaning slightly back
		B:sym(function(side)
			local s = 1 -- B:sym mirrors the left side
			local x = s * 2.05
			local a, b = v(x, 2.2, -4.35), v(x, 5.6, -3.85)
			B:block("Root", v(1.0, 0.25, 1.0), cf(x, 2.42, -4.3), G2)
			B:block("Root", v(0.85, 0.2, 0.85), cf(x, 2.62, -4.28), W2)
			B:bar("Root", a, b, 0.6, 0.6, W1)
			B:bar("Root", a:Lerp(b, 0.5), a:Lerp(b, 0.58), 0.72, 0.72, G2)
			B:bar("Root", a:Lerp(b, 0.25), a:Lerp(b, 0.28), 0.66, 0.66, W3)
			B:bar("Root", a:Lerp(b, 0.78), a:Lerp(b, 0.81), 0.66, 0.66, W3)
			B:bar("Root", a:Lerp(b, 0.9), a:Lerp(b, 1.0), 0.8, 0.8, G2)
		end)

		-------------------------------------------------------------- console
		local con = cf(0, 5.9, -3.75) * ang(-30, 0, 0)
		local function at(x, y, z) return con * CFrame.new(x, y, z) end
		B:block("Root", v(5.0, 1.0, 1.5), con, W1)
		B:block("Root", v(5.15, 0.22, 1.65), at(0, 0.52, 0), G2)
		B:block("Root", v(5.1, 0.18, 1.55), at(0, -0.55, 0), W3)
		-- screen with gold bezel
		B:block("Root", v(3.0, 0.78, 0.06), at(0, 0.0, 0.77), INK)
		B:block("Root", v(3.2, 0.1, 0.1), at(0, 0.44, 0.76), G2)
		B:block("Root", v(3.2, 0.1, 0.1), at(0, -0.44, 0.76), G2)
		B:block("Root", v(0.1, 0.9, 0.1), at(-1.6, 0, 0.76), G2)
		B:block("Root", v(0.1, 0.9, 0.1), at(1.6, 0, 0.76), G2)
		-- equaliser bars (animated)
		for i = 1, 8 do
			local hgt = 0.56
			B:block("Root", v(0.22, hgt, 0.05), at(-1.19 + (i - 1) * 0.34, -0.33 + hgt / 2, 0.81), i % 2 == 0 and "#ffd23d" or "#fff0a0", { mat = "Neon", name = "Bar" .. i })
		end
		-- gem buttons (pulse in sequence)
		local gemCols = { RUBY, SAPH, EMER, AMET }
		for i = 1, 4 do
			local x = (i <= 2) and -2.05 or 2.05
			local y = (i % 2 == 1) and 0.18 or -0.2
			B:block("Root", v(0.46, 0.34, 0.08), at(x, y, 0.76), G2)
			B:block("Root", v(0.3, 0.22, 0.08), at(x, y, 0.8), gemCols[i], { mat = "Neon", name = "Gem" .. i })
		end

		-- jewelled crown above the console (upright)
		-- marble pediment rising behind the screen
		local ped = { { 4.7, 0.6, 6.5 }, { 3.5, 0.4, 7.0 }, { 2.4, 0.4, 7.4 } }
		for j, pd in ped do
			B:block("Root", v(pd[1], pd[2], 0.62), cf(0, pd[3], -4.05), j == 2 and W2 or W1)
			B:block("Root", v(pd[1] + 0.1, 0.1, 0.7), cf(0, pd[3] + pd[2] / 2 - 0.02, -4.05), G2)
		end
		for _, sx in { -1.9, 1.9 } do
			B:block("Root", v(0.5, 0.5, 0.7), cf(sx, 7.0, -4.05), G2)
			B:block("Root", v(0.26, 0.26, 0.74), cf(sx, 7.0, -4.05), sx > 0 and RUBY or SAPH, { mat = "Neon" })
			B:block("Root", v(0.3, 0.3, 0.3), cf(sx, 7.4, -4.05) * ang(45, 0, 45), G1)
		end
		for k, sx in { -1.2, -0.4, 0.4, 1.2 } do
			B:block("Root", v(0.2, 0.3, 0.06), cf(sx, 7.0, -3.72), G1)
			B:block("Root", v(0.2, 0.3, 0.06), cf(sx, 7.0, -4.38), G1)
		end
		local cy, cz = 8.0, -4.0
		B:block("Root", v(2.6, 0.2, 1.2), cf(0, cy - 0.3, cz), W2)
		B:block("Root", v(2.3, 0.45, 1.0), cf(0, cy, cz), G2)
		B:block("Root", v(2.4, 0.1, 1.1), cf(0, cy - 0.14, cz), G3)
		local tips = { { -1.0, 0.35 }, { -0.5, 0.5 }, { 0, 0.7 }, { 0.5, 0.5 }, { 1.0, 0.35 } }
		for i, tp in tips do
			local x, h = tp[1], tp[2]
			B:block("Root", v(0.3, h, 0.3), cf(x, cy + 0.2 + h / 2, cz), G1)
			B:block("Root", v(0.18, 0.18, 0.18), cf(x, cy + 0.3 + h, cz), W1)
		end
		for i, x in { -0.75, 0, 0.75 } do
			local col = i == 2 and RUBY or EMER
			B:gem("Root", v(0.26, 0.22, 1.06), cf(x, cy, cz), col, { name = "CrownGem" .. i })
		end
		-- spinning gold diamond jewel floating above the crown
		local jewel = B:bone("Jewel", "Root", v(0, cy + 1.2, cz))
		local jcf = cf(0, cy + 1.2, cz) * ang(45, 0, 45)
		B:block(jewel, v(0.6, 0.6, 0.6), jcf, G1)
		local core = B:gem(jewel, v(0.38, 0.38, 0.38), cf(0, cy + 1.2, cz) * ang(0, 45, 0), "#fff6b8", { name = "JewelCore" })
		B:block(jewel, v(0.16, 0.9, 0.16), cf(0, cy + 1.2, cz), G2)

		-- console end ornaments (stepped gold scrolls)
		for _, sx in { 1, -1 } do
			B:block("Root", v(0.2, 1.2, 1.3), at(sx * 2.6, 0, 0), G2)
			B:block("Root", v(0.14, 0.7, 0.8), at(sx * 2.72, 0.05, 0), G1)
			B:gem("Root", v(0.1, 0.26, 0.26), at(sx * 2.8, 0.05, 0), sx == 1 and RUBY or SAPH)
		end

		-- rear trophy posts with spinning gold stars
		for _, s in { 1, -1 } do
			local x, z = s * 2.2, 4.4
			B:block("Root", v(1.0, 0.3, 0.9), cf(x, 1.88, z), W2)
			B:block("Root", v(0.8, 0.15, 0.75), cf(x, 2.08, z), G2)
			B:block("Root", v(0.55, 1.3, 0.55), cf(x, 2.75, z), W1)
			B:block("Root", v(0.65, 0.16, 0.65), cf(x, 2.75, z), G2)
			B:block("Root", v(0.85, 0.22, 0.85), cf(x, 3.45, z), G2)
			B:block("Root", v(0.6, 0.18, 0.6), cf(x, 3.63, z), G1)
			local nm = s == 1 and "StarR" or "StarL"
			local sb = B:bone(nm, "Root", v(x, 4.25, z))
			local sc = cf(x, 4.25, z)
			B:block(sb, v(0.75, 0.75, 0.14), sc, G1)
			B:block(sb, v(0.75, 0.75, 0.14), sc * ang(0, 0, 45), G2)
			B:gem(sb, v(0.3, 0.3, 0.2), sc, s == 1 and RUBY or EMER, { name = "StarGem" .. (s == 1 and "R" or "L") })
			B:block("Root", v(0.14, 0.4, 0.14), cf(x, 3.8, z), G3)
		end

		-- console front face: gold filigree + gem
		B:block("Root", v(4.2, 0.1, 0.06), at(0, 0.25, -0.77), G2)
		B:block("Root", v(4.2, 0.1, 0.06), at(0, -0.25, -0.77), G2)
		for _, sx in { -1.6, -0.8, 0.8, 1.6 } do
			B:block("Root", v(0.24, 0.24, 0.06), at(sx, 0, -0.78) * ang(0, 0, 45), G1)
		end
		B:block("Root", v(0.6, 0.6, 0.08), at(0, 0, -0.78) * ang(0, 0, 45), G2)
		B:gem("Root", v(0.3, 0.3, 0.06), at(0, 0, -0.83) * ang(0, 0, 45), EMER, { name = "FaceGem" })

		-- gold bullion stacks on the hood, either side of the velvet cushion
		for _, sx in { -1, 1 } do
			local bx = sx * 1.05
			for r, row in { { -0.37, 0, 0.37 }, { -0.18, 0.18 }, { 0 } } do
				for _, dx in row do
					B:block("Root", v(0.34, 0.22, 0.62), cf(bx + dx, 2.63 + (r - 1) * 0.22, -4.35), r == 2 and G1 or G2)
				end
			end
		end

		-- VIP velvet ropes on gold stanchion hooks from the rear posts to the columns
		for _, s in { 1, -1 } do
			local x = s * 2.32
			local a, b = v(x, 3.3, 4.1), v(x, 3.3, -3.6)
			local sag = { a, v(x, 2.75, 2.0), v(x, 2.6, 0.25), v(x, 2.75, -1.5), b }
			for k = 1, 4 do
				B:bar("Root", sag[k], sag[k + 1], 0.16, 0.16, VEL)
			end
			for k = 2, 4 do
				B:block("Root", v(0.2, 0.2, 0.2), CFrame.new(sag[k]), G1)
			end
			B:block("Root", v(0.26, 0.26, 0.26), CFrame.new(a), G2)
			B:block("Root", v(0.26, 0.26, 0.26), CFrame.new(b), G2)
		end

		------------------------------------------------------------ handrails
		for _, s in { 1, -1 } do
			local x = s * 2.35
			B:bar("Root", v(x, 5.3, -3.45), v(x, 4.55, -0.5), 0.36, 0.36, G2)
			B:bar("Root", v(x, 5.05, -2.4), v(x, 4.7, -1.0), 0.48, 0.48, W1)
			B:block("Root", v(0.5, 0.5, 0.5), cf(x, 4.52, -0.45), G1)
			B:block("Root", v(0.3, 0.3, 0.3), cf(x, 4.52, -0.45) * ang(45, 45, 0), G3)
			-- cup holder on the right, towel hook on the left
			if s == 1 then
				B:block("Root", v(0.6, 0.12, 0.6), cf(x + 0.35, 4.75, -2.95), G2)
				B:block("Root", v(0.42, 0.45, 0.42), cf(x + 0.35, 5.0, -2.95), "#7fd3ff")
				B:block("Root", v(0.5, 0.1, 0.5), cf(x + 0.35, 5.25, -2.95), W1)
			else
				B:block("Root", v(0.5, 0.7, 0.12), cf(x - 0.3, 4.6, -2.95), W1)
				B:block("Root", v(0.52, 0.1, 0.14), cf(x - 0.3, 4.4, -2.95), G2)
			end
		end

		-------------------------------------------------------------- effects
		B:emitter(core, "sparkle", { color = { "#ffffff", G1 }, rate = 8, size = { 0.15, 0.5, 0 }, name = "JewelSparkle" })
		B:emitter(core, "burst", { color = { "#fff6b8", G2 }, size = { 0.5, 0.35, 0 }, speed = { 5, 9 }, name = "Shine" })
		B:light(core, { color = "#ffd76a", brightness = 0.9, range = 10, name = "JewelLight" })
		local railR = B:block("Root", v(0.2, 0.1, 6.8), cf(2.12, 1.7, 0.25), G1, { tr = 1, name = "SparkR" })
		local railL = B:block("Root", v(0.2, 0.1, 6.8), cf(-2.12, 1.7, 0.25), G1, { tr = 1, name = "SparkL" })
		B:emitter(railR, "sparkle", { color = { "#ffffff", G1 }, rate = 3, size = { 0.1, 0.3, 0 }, name = "RailSparkR" })
		B:emitter(railL, "sparkle", { color = { "#ffffff", G1 }, rate = 3, size = { 0.1, 0.3, 0 }, name = "RailSparkL" })
	end,
}
