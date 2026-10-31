--!nocheck
-- Starlight Ruins Gate (map stage gate, static landmark).
-- A ruined celestial temple gateway:
-- * two fluted white-violet columns (|x| 33..44) on stepped gold-trimmed
--   plinths: octagonal shafts with raised flute ribs, gold bands, a glowing
--   cyan constellation strip with gold star studs up the front and back,
--   stepped capitals; the right shaft is cracked with a drum knocked askew,
--   chipped corners and teal moss
-- * an architrave spans the columns (y 19.6..27.4) with a gold trim line,
--   dentils and constellation glow strips (gold stars joined by thin cyan
--   lines) on both faces; the stage "Sign" sits in a chunky gold-and-stone
--   frame with star corners on the front, a big gold star on the back
-- * a flat arch of voussoir stones rides on top, held by a big crescent moon
--   keystone (pale gold with a gold rim and a glowing star); two voussoirs on
--   the left have broken loose and float just above their gap
-- * star crystals (violet / cyan double points) and little gold stars hover
--   around the gate (static, just placed)
-- * indigo star tiles, rubble, a fallen column drum and crystal sprouts at
--   the feet
-- Opening x -32..32 is clear up to y 19.4. Static landmark (Filler).
return {
	DisplayName = "Starlight Ruins Gate",
	Rarity = "Landmark",
	Filler = true,
	Element = "Starlight Ruins",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		local STONE, STONE2, STONE_DK, STONE_LT, STONE_HI = "#e3dcef", "#d0c7e2", "#a99fc2", "#f4f0fb", "#fbf9ff"
		local GOLD, GOLD_DK, GOLD_LT = "#f2c24f", "#c9952e", "#ffe08a"
		local MOSS, MOSS_DK = "#4f9e7c", "#367a62"
		local TILE_DK, TILE, TILE_LT = "#2a2550", "#3b3566", "#4d4684"
		local RUNE = "#7fe8ff"
		local VIO_DK, VIO, VIO_LT = "#7a58ea", "#9b7cff", "#c6b4ff"
		local CY_DK, CY, CY_LT = "#2aa9cf", "#4fd8f2", "#a8f3ff"
		local MOON, MOON_LT, MOON_DK = "#ffe9a8", "#fff6d6", "#f0cf78"
		local SIGN = "#f4f0fc"
		local NEON = { mat = "Neon" }
		local UP = v(0, 0, 1)

		local seed = 9101
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		-- a little 4-point star facing +-Z (two crossed diamonds)
		local function star(x, y, z, s, col, col2)
			B:block(R, v(0.5 * s, 1.6 * s, 0.25), cf(x, y, z), col)
			B:block(R, v(1.6 * s, 0.5 * s, 0.25), cf(x, y, z), col)
			B:block(R, v(0.7 * s, 0.7 * s, 0.3), cf(x, y, z, 0, 0, 45), col2 or col)
		end
		-- floating double-point crystal
		local function crystal(x, y, z, s, col, colLt, tilt)
			local c = CFrame.new(x, y, z) * ang(0, 45, tilt or 0)
			B:block(R, v(1.3 * s, 1.8 * s, 1.3 * s), c, col)
			B:block(R, v(0.9 * s, 0.9 * s, 0.9 * s), c * CFrame.new(0, 1.25 * s, 0), colLt)
			B:block(R, v(0.5 * s, 0.6 * s, 0.5 * s), c * CFrame.new(0, 1.9 * s, 0), colLt)
			B:block(R, v(0.8 * s, 0.8 * s, 0.8 * s), c * CFrame.new(0, -1.15 * s, 0), col)
			B:block(R, v(1.36 * s, 0.25 * s, 1.36 * s), c, CY_LT, NEON)
		end

		------------------------------------------------------------ columns
		local PX = 38.5
		local tops = {}
		for _, sx in { 1, -1 } do
			local x = sx * PX
			local broken = (sx == 1)
			-- plinth
			B:block(R, v(11.4, 1.2, 10.6), cf(x + sx * 0.2, 0.6, 0), STONE_DK)
			B:block(R, v(11.6, 0.3, 10.8), cf(x + sx * 0.2, 1.35, 0), GOLD)
			B:block(R, v(10.6, 1.6, 9.8), cf(x, 2.3, 0), STONE)
			B:block(R, v(9.6, 0.8, 8.8), cf(x, 3.5, 0), STONE_LT)
			-- shaft: three drums
			local drums = { { 3.9, 8.6 }, { 8.9, 13.6 }, { 13.9, 17.4 } }
			for di, d in drums do
				local y0, y1 = d[1], d[2]
				local h = y1 - y0
				local yaw = (broken and di == 2) and 7 or 0
				local dx = (broken and di == 2) and sx * 0.5 or 0
				local c = cf(x + dx, (y0 + y1) / 2, 0, 0, yaw, 0)
				B:block(R, v(7.0, h, 3.2), c, (di % 2 == 0) and STONE or STONE_LT)
				B:block(R, v(3.2, h - 0.02, 7.0), c, (di % 2 == 0) and STONE or STONE_LT)
				B:block(R, v(5.4, h - 0.04, 5.4), c * ang(0, 45, 0), STONE2)
				-- flute ribs on the diagonals
				for f = 0, 3 do
					B:block(R, v(0.5, h - 0.6, 0.3), c * ang(0, 45 + f * 90, 0) * CFrame.new(0, 0, -2.75), STONE_HI)
				end
				if di < 3 then
					B:block(R, v(6.2, 0.4, 6.2), cf(x, y1 + 0.15, 0, 0, 45, 0), GOLD) -- gold band between drums
				end
			end
			-- constellation glow strip up the front + back faces
			for _, side in { -1, 1 } do
				local z = side * 3.55
				B:block(R, v(1.0, 12.6, 0.2), cf(x, 10.8, z), TILE_DK)
				B:block(R, v(0.25, 12.0, 0.25), cf(x, 10.8, z + side * 0.05), RUNE, NEON)
				for k, sy in { 5.6, 9.4, 12.4, 16.0 } do
					B:block(R, v(0.9, 0.9, 0.3), cf(x, sy, z + side * 0.12, 0, 0, 45), (k % 2 == 0) and GOLD_LT or GOLD)
				end
			end
			-- capital
			B:block(R, v(8.0, 0.5, 8.0), cf(x, 17.65, 0), GOLD)
			B:block(R, v(8.6, 0.9, 8.6), cf(x, 18.35, 0), STONE)
			B:block(R, v(10.4, 1.0, 9.6), cf(x + sx * 0.3, 19.3, 0), STONE_LT)
			tops[sx] = x
			if broken then
				-- chipped corner on the capital + crack line
				B:block(R, v(1.6, 1.0, 1.6), cf(x + sx * 4.8, 18.9, -4.2, 0, 20, 0), STONE_DK)
				B:block(R, v(0.3, 3.4, 0.2), cf(x - sx * 1.2, 11.0, -3.6, 0, 0, 20), STONE_DK)
				-- moss on the knocked drum
				B:block(R, v(3.4, 0.4, 3.0), cf(x + sx * 1.6, 13.85, 1.6, 0, 7, 0), MOSS)
				B:block(R, v(0.6, 2.0, 0.3), cf(x + sx * 2.8, 12.6, 3.5), MOSS_DK)
			else
				B:block(R, v(3.0, 0.4, 2.6), cf(x - sx * 2.2, 3.95, 2.8), MOSS)
				B:block(R, v(0.6, 1.6, 0.3), cf(x - sx * 3.2, 3.0, 4.95), MOSS_DK)
			end
		end

		------------------------------------------------------------ architrave
		local AY0, AY1, AZ = 19.8, 27.0, 3.2
		B:block(R, v(88.0, AY1 - AY0, AZ * 2), cf(0, (AY0 + AY1) / 2, 0), STONE)
		B:block(R, v(88.4, 0.8, AZ * 2 + 0.4), cf(0, AY0 + 0.4, 0), STONE_DK)
		B:block(R, v(90.0, 1.0, AZ * 2 + 1.0), cf(0, AY1 + 0.5, 0), STONE_LT) -- cornice
		B:block(R, v(90.4, 0.3, AZ * 2 + 1.3), cf(0, AY1 + 0.15, 0), GOLD)
		-- broken end of the cornice on the left (ruin)
		B:block(R, v(3.0, 1.2, 2.0), cf(-44.0, AY1 + 0.4, -3.2, 0, 15, 8), STONE_DK)
		for _, side in { -1, 1 } do
			local z = side * AZ
			-- gold trim line
			B:block(R, v(88.2, 0.35, 0.2), cf(0, 21.0, z), GOLD)
			for _, sx in { 1, -1 } do
				-- dentils under the cornice (outside the sign)
				for k = 0, 8 do
					B:block(R, v(1.1, 0.8, 0.4), cf(sx * (17.6 + k * 3.1), AY1 - 0.5, z + side * 0.1), STONE_HI)
				end
				-- constellation: gold star studs joined by thin glowing lines
				local pts = { { 18.6, 23.0 }, { 22.4, 25.0 }, { 26.6, 22.8 }, { 30.2, 24.6 }, { 34.4, 23.2 }, { 38.6, 25.0 }, { 42.2, 23.4 } }
				for i = 1, #pts - 1 do
					local a, b = pts[i], pts[i + 1]
					B:bar(R, v(sx * a[1], a[2], z + side * 0.08), v(sx * b[1], b[2], z + side * 0.08), 0.22, 0.2, RUNE, { mat = "Neon", up = UP })
				end
				for i, p in pts do
					B:block(R, v(0.95, 0.95, 0.3), cf(sx * p[1], p[2], z + side * 0.15, 0, 0, 45), (i % 2 == 0) and GOLD_LT or GOLD)
				end
			end
		end
		-- back: a big gold star where the sign is on the front
		do
			local z = AZ + 0.15
			B:block(R, v(12, 4.6, 0.3), cf(0, 23.4, z), TILE)
			B:block(R, v(1.2, 4.0, 0.3), cf(0, 23.4, z + 0.15), GOLD)
			B:block(R, v(4.4, 1.2, 0.3), cf(0, 23.4, z + 0.15), GOLD)
			B:block(R, v(2.0, 2.0, 0.3), cf(0, 23.4, z + 0.25, 0, 0, 45), GOLD_LT)
			B:block(R, v(0.7, 0.7, 0.3), cf(0, 23.4, z + 0.4, 0, 0, 45), RUNE, NEON)
			for _, sx in { 1, -1 } do
				star(sx * 4.2, 24.6, z + 0.15, 0.7, GOLD_LT)
				star(sx * 3.4, 22.0, z + 0.15, 0.5, GOLD)
			end
		end

		------------------------------------------------------------ the Sign
		local SY, SW, SH = 23.4, 28.0, 5.4
		local SZ = -AZ - 0.5
		B:block(R, v(SW, SH, 1.0), cf(0, SY, SZ), SIGN, { name = "Sign" })
		local FZ, FD = SZ - 0.15, 1.8
		B:block(R, v(SW + 3.2, 1.3, FD), cf(0, SY + SH / 2 + 0.65, FZ), STONE_DK)
		B:block(R, v(SW + 3.2, 1.2, FD), cf(0, SY - SH / 2 - 0.6, FZ), STONE_DK)
		B:block(R, v(1.6, SH, FD), cf(SW / 2 + 0.8, SY, FZ), STONE_DK)
		B:block(R, v(1.6, SH, FD), cf(-SW / 2 - 0.8, SY, FZ), STONE_DK)
		B:block(R, v(SW + 3.4, 0.35, FD + 0.2), cf(0, SY + SH / 2 + 0.2, FZ), GOLD) -- gold inner lip top
		B:block(R, v(SW + 3.4, 0.35, FD + 0.2), cf(0, SY - SH / 2 - 0.15, FZ), GOLD) -- and bottom
		for _, sx in { 1, -1 } do
			for _, sy in { 1, -1 } do
				local y = SY + sy * (SH / 2 + 0.6)
				local x = sx * (SW / 2 + 0.85)
				B:block(R, v(2.2, 2.2, FD + 0.3), cf(x, y, FZ, 0, 0, 45), GOLD)
				B:block(R, v(1.2, 1.2, FD + 0.5), cf(x, y, FZ), GOLD_LT)
			end
		end

		------------------------------------------------------------ voussoir arch + moon keystone
		local RA, RB, RY = 30.0, 4.6, AY1 + 1.0 -- ellipse centre line
		local N = 15
		local function arcPt(t)
			return RA * math.cos(t), RY + RB * math.sin(t)
		end
		for i = 0, N - 1 do
			local t0 = math.pi * i / N
			local t1 = math.pi * (i + 1) / N
			local tm = (t0 + t1) / 2
			if i ~= 7 then -- the middle one is the moon keystone
				local x0, y0 = arcPt(t0)
				local x1, y1 = arcPt(t1)
				local a, b = v(x0, y0, 0), v(x1, y1, 0)
				local float = (i == 11 or i == 12)
				local off = float and v(-0.6, 1.4 + (i - 11) * 0.6, 0) or v(0, 0, 0)
				local c, len = P.aim(a + off, b + off, UP)
				if float then
					c = c * ang(0, 0, (i == 11) and 8 or -10)
				end
				-- local X is radial (in-plane), local Y is depth
				B:block(R, v(2.8, 4.6, len - 0.25), c, (i % 2 == 0) and STONE_LT or STONE)
				B:block(R, v(0.5, 4.8, len - 0.6), c * CFrame.new(1.25, 0, 0), GOLD) -- gold extrados trim
				if i % 3 == 1 and not float then
					B:block(R, v(0.8, 4.9, 0.8), c * CFrame.new(0, 0, 0), STONE_DK) -- joint stud
				end
			end
		end
		-- rubble of the fallen voussoirs' mortar on the architrave
		B:block(R, v(1.6, 0.6, 1.4), cf(-17.0, AY1 + 1.3, 1.0, 0, 20, 0), STONE_DK)

		-- crescent moon keystone (XY plane, depth 4)
		local MY = 30.0
		local MR = 3.9
		-- crescent: arc of blocks on the left of the circle, opening to the right
		for k = 0, 8 do
			local a = rad(40 + k * 35) -- 40..320 deg
			local w = 1.4 + 0.9 * math.sin(rad(k / 8 * 180))
			local px, py = math.cos(a) * (MR - w / 2), math.sin(a) * (MR - w / 2)
			B:block(R, v(w, 1.9, 4.0), CFrame.new(px, MY + py, 0) * ang(0, 0, math.deg(a) + 90), (k % 2 == 0) and MOON or MOON_LT)
		end
		-- gold rim along the outer edge
		for k = 0, 9 do
			local a = rad(30 + k * 33)
			B:block(R, v(1.2, 0.5, 4.4), CFrame.new(math.cos(a) * (MR + 0.15), MY + math.sin(a) * (MR + 0.15), 0) * ang(0, 0, math.deg(a) + 90), GOLD)
		end
		-- inner shadow + a glowing star in the crescent's mouth
		B:block(R, v(1.0, 3.4, 4.2), cf(-1.2, MY, 0), MOON_DK)
		star(1.5, MY + 0.2, -2.2, 1.1, GOLD_LT, RUNE)
		star(1.5, MY + 0.2, 2.2, 1.1, GOLD_LT, RUNE)
		B:block(R, v(0.5, 0.5, 4.6), cf(1.5, MY + 0.2, 0, 0, 0, 45), RUNE, NEON)
		-- seat block under the moon
		B:block(R, v(5.0, 1.0, 4.8), cf(0, AY1 + 1.4, 0), STONE_DK)
		B:block(R, v(5.4, 0.3, 5.0), cf(0, AY1 + 1.95, 0), GOLD)

		------------------------------------------------------------ floating crystals + stars
		crystal(-36.5, 25.8, -0.4, 1.2, VIO, VIO_LT, 10) -- (above the left capital, in the arch gap area)
		crystal(43.6, 24.6, 0.6, 1.1, CY, CY_LT, -12)
		crystal(-44.6, 30.6, -0.8, 1.0, CY, CY_LT, 8)
		crystal(39.4, 31.8, 0.2, 1.3, VIO, VIO_LT, -6)
		crystal(-21.8, 33.0, 0.4, 0.8, VIO_DK, VIO_LT, 15)
		crystal(9.6, 33.0, -0.6, 0.85, CY_DK, CY_LT, -15)
		crystal(-9.0, 32.4, 0.8, 0.7, VIO, VIO_LT, 5)
		for _, st in { { 32.6, 31.6, 1.0 }, { -30.0, 33.0, 0.8 }, { 19.4, 32.8, 0.7 }, { -47.0, 25.0, 0.8 }, { 47.2, 29.4, 0.9 } } do
			for _, side in { -1, 1 } do
				star(st[1], st[2], side * 0.15, st[3], GOLD, GOLD_LT)
			end
		end

		------------------------------------------------------------ feet dressing
		for _, sx in { 1, -1 } do
			-- indigo star tiles round the plinth
			for _, t in { { 44.6, -4.0, 2.4, 2.0, 10 }, { 45.8, 1.6, 2.0, 2.4, -8 }, { 33.4, 4.6, 2.0, 1.8, 15 } } do
				B:block(R, v(t[3], 0.3, t[4]), cf(sx * t[1], 0.15, t[2], 0, t[5], 0), TILE)
				B:block(R, v(0.7, 0.32, 0.7), cf(sx * t[1], 0.17, t[2], 0, t[5] + 45, 0), GOLD)
			end
			-- crystal sprouts
			local cx, cz = sx * 45.4, 4.2
			B:block(R, v(0.9, 2.4, 0.9), cf(cx, 1.2, cz, 0, 45, 8), VIO)
			B:block(R, v(0.6, 1.6, 0.6), cf(cx + 0.7, 0.8, cz - 0.4, 0, 30, -20), VIO_LT)
			B:block(R, v(0.5, 1.2, 0.5), cf(cx - 0.6, 0.6, cz + 0.3, 0, 10, 18), CY)
			-- rubble
			B:block(R, v(1.6, 1.0, 1.4), cf(sx * 33.6, 0.5, -4.6, 0, 25, 0), STONE2)
			B:block(R, v(1.0, 0.7, 0.9), cf(sx * 34.4, 1.2, -4.4, 0, 50, 0), STONE_LT)
		end
		-- fallen column drum lying beside the right column (outside the lane)
		B:block(R, v(3.0, 3.0, 5.0), cf(46.6, 1.5, -2.6, 0, 0, 0), STONE_LT)
		B:block(R, v(2.6, 2.6, 5.1), cf(46.6, 1.5, -2.6, 0, 0, 45), STONE2)
		B:block(R, v(3.2, 3.2, 0.3), cf(46.6, 1.5, -4.9), GOLD)
	end,
}
