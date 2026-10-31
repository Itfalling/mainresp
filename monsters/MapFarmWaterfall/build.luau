--!nocheck
-- Sunny Falls (Sunny Farm map landmark). A two-tier waterfall that fills a
-- 40 x 32 notch cut into the side cliff of the hallway. Faces -Z (into the run
-- lane). Footprint x [-20, 20], z [-16, 16], y [0, ~46].
-- * orange-dirt strata cliffs (3 tones, grooved bands) with green grass caps,
--   grass drips, flowers and bushes; side walls blend with the map cliff
--   (14 high at the front, 26 behind z = 4)
-- * a stream at the top (y 40.8) under a little wooden bridge pours over a lip
--   into a ledge basin (y 24.3), which spills over a second lip into the main
--   fall and a clear blue pool at floor level (surface y 0.9) with a low stone
--   rim at the front edge, rocks, lily pads and a turning wooden water wheel fed
--   by a flume
-- * animated: falling streak/foam dashes on bones MainA / MainB / Upper slide
--   down (seamless, dashes fade in under the lip and out into the splash),
--   splash churn, expanding pool ripple rings, bobbing lily pads, water wheel
return {
	DisplayName = "Sunny Falls",
	Rarity = "Landmark",
	Element = "Sunny Farm",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad, cos, sin, floor = math.rad, math.cos, math.sin, math.floor
		local R = "Root"

		-- palette
		local DIRT1, DIRT2, DIRT3 = "#d98a4e", "#c97a40", "#b86a35"
		local DIRT_HI, DIRT_LO = "#e8a468", "#a35a2b"
		local WET1, WET2, WET3 = "#9a5a34", "#87502e", "#74452a"
		local GRASS, GRASS2, GRASS_DK, GRASS_LT = "#6fd44a", "#62c43f", "#4fb236", "#8fe462"
		local STONE_LT, STONE, STONE_DK = "#c9ced4", "#a5adb6", "#868e98"
		local WOOD_LT, WOOD, WOOD_DK, WOOD_XDK = "#e0a866", "#c98a4b", "#8a5a2b", "#5e3a1c"
		local WATER, WATER_DK, WATER_LT = "#46c4ff", "#2aa2ee", "#8fe0ff"
		local POOL_DEEP, POOL_SAND = "#1f86d6", "#7fd6e6"
		local STREAK, STREAK2, FOAM, FOAM2 = "#b4f0ff", "#d6f8ff", "#ffffff", "#e6fbff"
		local PAD, PAD_DK = "#4fc23a", "#3a9a2c"
		local PINK, WHITE, YELLOW, GOLD, RED, PURPLE = "#ff7eb6", "#ffffff", "#ffe14a", "#ffcf3a", "#ff4f4f", "#b98cff"

		local seed = 9127
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.min(#t, 1 + floor(rnd(0, #t)))]
		end
		local function clampX(x)
			return math.clamp(x, -20, 20)
		end
		local function clampZ(z)
			return math.clamp(z, -16, 16)
		end
		local function box(bone, x0, x1, y0, y1, z0, z1, col, opts)
			if x0 > x1 then
				x0, x1 = x1, x0
			end
			return B:block(bone, v(x1 - x0, y1 - y0, z1 - z0), cf((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), col, opts)
		end

		------------------------------------------------------------------
		-- strata rock: fixed band lines shared by every box so the layers
		-- line up across the whole cliff; every other band is inset on the
		-- exposed faces (ex: f = -z, b = +z, l = -x, r = +x)
		------------------------------------------------------------------
		local BANDS = { 0, 2.5, 5.5, 8, 11, 13.5, 16.5, 19, 22, 24.5, 27.5, 30, 33, 35.5, 38.5, 41, 44, 47 }
		local DRY = { DIRT1, DIRT2, DIRT1, DIRT3 }
		local WET = { WET1, WET2, WET1, WET3 }
		local function rock(x0, x1, y0, y1, z0, z1, ex, pal)
			pal = pal or DRY
			ex = ex or "f"
			for i = 1, #BANDS - 1 do
				local a, b = math.max(y0, BANDS[i]), math.min(y1, BANDS[i + 1])
				if b - a > 0.05 then
					local ins = (i % 2 == 0) and 0.4 or 0
					local ax0 = x0 + (ex:find("l") and ins or 0)
					local ax1 = x1 - (ex:find("r") and ins or 0)
					local az0 = z0 + (ex:find("f") and ins or 0)
					local az1 = z1 - (ex:find("b") and ins or 0)
					box(R, ax0, ax1, a, b, az0, az1, pal[(i - 1) % 4 + 1])
				end
			end
		end
		-- grass cap on top of a rock box + drips down the exposed faces
		local function cap(x0, x1, z0, z1, y, ex, nDrip)
			ex = ex or "f"
			local o = 0.3
			local cx0 = clampX(x0 - (ex:find("l") and o or 0))
			local cx1 = clampX(x1 + (ex:find("r") and o or 0))
			local cz0 = clampZ(z0 - (ex:find("f") and o or 0))
			local cz1 = clampZ(z1 + (ex:find("b") and o or 0))
			box(R, cx0, cx1, y - 0.5, y + 0.45, cz0, cz1, GRASS)
			-- lighter tufty patch on top
			if (x1 - x0) > 2.5 and (z1 - z0) > 2.5 then
				local px, pz = rnd(x0 + 0.6, x1 - 1.6), rnd(z0 + 0.6, z1 - 1.6)
				box(R, px, math.min(px + rnd(1.2, 2.4), x1 - 0.2), y + 0.4, y + 0.6, pz, math.min(pz + rnd(1.2, 2.4), z1 - 0.2), GRASS2)
			end
			nDrip = nDrip or 0
			for _ = 1, nDrip do
				if ex:find("f") then
					local w, h = rnd(0.8, 1.8), rnd(0.5, 1.5)
					local x = rnd(x0 + w / 2, x1 - w / 2)
					box(R, x - w / 2, x + w / 2, y - 0.5 - h, y - 0.3, cz0, cz0 + 0.6, pick({ GRASS, GRASS2, GRASS_DK }))
				end
			end
		end
		-- little stone / dirt nubs on a face for texture
		local function nub(x, y, z, s, col)
			B:block(R, v(s, s * 0.8, s), cf(x, y, z), col)
		end
		local function tuft(x, y, z, h, flower)
			B:block(R, v(0.5, h, 0.5), cf(x, y + h / 2, z), GRASS)
			B:block(R, v(0.4, h * 0.7, 0.4), cf(x + 0.3, y + h * 0.35, z + 0.15, 0, 0, -18), GRASS_DK)
			B:block(R, v(0.4, h * 0.75, 0.4), cf(x - 0.3, y + h * 0.37, z - 0.12, 0, 0, 18), GRASS2)
			if flower then
				B:block(R, v(0.6, 0.3, 0.6), cf(x, y + h + 0.1, z, 0, 45, 0), flower)
				B:block(R, v(0.28, 0.34, 0.28), cf(x, y + h + 0.12, z), GOLD)
			end
		end
		local function flower(x, y, z, col)
			B:block(R, v(0.18, 0.8, 0.18), cf(x, y + 0.4, z), GRASS_DK)
			B:block(R, v(0.7, 0.28, 0.7), cf(x, y + 0.85, z, 0, 45, 0), col)
			B:block(R, v(0.3, 0.32, 0.3), cf(x, y + 0.87, z), (col == YELLOW) and "#ff9a3a" or GOLD)
		end
		local function bush(x, y, z, s, berry)
			B:block(R, v(2.2 * s, 1.6 * s, 2.0 * s), cf(x, y + 0.8 * s, z), GRASS_DK)
			B:block(R, v(1.7 * s, 1.5 * s, 1.6 * s), cf(x + 0.7 * s, y + 1.3 * s, z - 0.3 * s, 0, 20, 0), GRASS)
			B:block(R, v(1.5 * s, 1.3 * s, 1.5 * s), cf(x - 0.7 * s, y + 1.4 * s, z + 0.2 * s, 0, -15, 0), GRASS2)
			B:block(R, v(1.2 * s, 1.0 * s, 1.2 * s), cf(x, y + 2.0 * s, z, 0, 40, 0), GRASS_LT)
			if berry then
				for k = 1, 3 do
					local a = rad(k * 120 + 20)
					B:block(R, v(0.4, 0.4, 0.4), cf(x + cos(a) * 1.0 * s, y + (1.2 + 0.3 * k) * s, z + sin(a) * 0.9 * s - 0.2), berry)
				end
			end
		end

		------------------------------------------------------------------
		-- side walls (blend with the map cliff: 14 high in front of z = 4,
		-- 26 high behind). Left side is a little wider-open for the wheel.
		------------------------------------------------------------------
		for _, s in { 1, -1 } do
			local i1 = (s == 1) and 13 or 14.5 -- inner face of the bottom step
			local i2 = (s == 1) and 15 or 16.2
			local i3 = (s == 1) and 17 or 17.8
			local function sx(a, b) -- x range on side s, given inner/outer |x|
				if s == 1 then
					return a, b
				end
				return -b, -a
			end
			local inner = (s == 1) and "fl" or "fr"
			local a0, a1 = sx(i1, 20)
			rock(a0, a1, 0, 5, -16, 4, inner)
			a0, a1 = sx(i2, 20)
			rock(a0, a1, 5, 10, -16, 4, inner)
			a0, a1 = sx(i3, 20)
			rock(a0, a1, 10, 14, -16, 4, inner)
			-- ledge caps
			a0, a1 = sx(i1, i2)
			cap(a0, a1, -16, 4, 5, (s == 1) and "fl" or "fr", 2)
			a0, a1 = sx(i2, i3)
			cap(a0, a1, -16, 4, 10, (s == 1) and "fl" or "fr", 2)
			a0, a1 = sx(i3, 20)
			cap(a0, a1, -16, 4, 14, (s == 1) and "fl" or "fr", 2)
			-- back block 26 high
			a0, a1 = sx(14, 20)
			rock(a0, a1, 0, 26, 4, 16, "f" .. ((s == 1) and "l" or "r"))
			cap(a0, a1, 4, 16, 26, "f", 3)
			-- shoulder 34 high
			a0, a1 = sx(10, 14)
			rock(a0, a1, 0, 34, 3, 16, "f" .. ((s == 1) and "l" or "r"))
			cap(a0, a1, 3, 16, 34, "f" .. ((s == 1) and "r" or "l"), 2)
			-- buttress framing the main fall
			a0, a1 = sx(7, 13)
			rock(a0, a1, 0, 8, -5, 3, (s == 1) and "fl" or "fr")
			a0, a1 = sx(7.5, 13)
			rock(a0, a1, 8, 18, -4, 3, (s == 1) and "fl" or "fr")
			a0, a1 = sx(9.5, 13)
			cap(a0, a1, -4, 3, 18, (s == 1) and "fl" or "fr", 2)
			-- upper cliff beside the top fall
			a0, a1 = sx(4.2, 10)
			rock(a0, a1, 22, 34, 5, 16, "f" .. ((s == 1) and "l" or "r"))
			local top = (s == 1) and 43 or 44
			a0, a1 = sx(4.2, 10)
			rock(a0, a1, 34, top, 7, 16, "f" .. ((s == 1) and "l" or "r"))
			cap(a0, a1, 5, 7, 34, "f", 1)
			cap(a0, a1, 7, 16, top, "f" .. ((s == 1) and "l" or "r"), 2)
		end

		------------------------------------------------------------------
		-- core cliff behind the falls
		------------------------------------------------------------------
		-- wet rock wall behind the main fall
		rock(-7, 7, 0, 18, -1, 3, "f", WET)
		rock(-10, 10, 0, 22, 3, 16, "f")
		-- basin ledge slab (overhangs the wet wall; the main fall pours off its lip)
		rock(-9.5, 9.5, 18, 23.4, -3, 6, "flr")
		-- upper cliff core under the stream bed (wet face behind the top fall)
		rock(-4.2, 4.2, 22, 40, 5, 16, "f", WET)
		-- stream bed + banks lining
		box(R, -4.3, 4.3, 39.6, 40.05, 5, 16, DIRT3)

		------------------------------------------------------------------
		-- basin: water, rims, spill lip
		------------------------------------------------------------------
		local BASIN_Y = 24.3
		box(R, -7, 7, 23.4, BASIN_Y, -2.9, 5.2, WATER, { tr = 0.2 })
		-- basin side rims (stones) and the shoulders of the spill lip
		for _, s in { 1, -1 } do
			box(R, s * 6.6 - 0.9 * s, s * 9.6, 23.3, 25.0, -3.3, 5.5, STONE)
			box(R, s * 7.2 - 0.6 * s, s * 9.2, 24.9, 25.6, -2.6, 2.0, STONE_LT)
			box(R, s * 6.0 - 0.0, s * 7.4, 23.2, 24.8, -3.5, -1.6, STONE_DK)
			tuft(s * 8.6, 25.0, 3.6, 1.0, (s == 1) and PINK or WHITE)
			flower(s * 8.4, 25.6, -1.6, (s == 1) and YELLOW or PINK)
		end
		-- lip roll where the basin spills over (hides the dashes entering)
		box(R, -6.1, 6.1, 22.7, 24.25, -4.35, -2.85, WATER_LT, { tr = 0.1 })
		box(R, -5.6, 5.6, 24.0, 24.45, -4.2, -2.6, FOAM2)
		-- top fall lip roll (stream spills over)
		box(R, -3.7, 3.7, 39.3, 40.9, 3.65, 5.2, WATER_LT, { tr = 0.1 })
		box(R, -3.3, 3.3, 40.7, 41.0, 3.8, 5.5, FOAM2)
		-- stream water at the top
		box(R, -4.1, 4.1, 40.05, 40.8, 4.6, 16, WATER, { tr = 0.2 })
		for _, z in { 7.2, 11.6, 14.6 } do
			box(R, rnd(-2.8, -1), rnd(0.8, 2.8), 40.78, 40.86, z, z + 0.5, FOAM2)
		end

		------------------------------------------------------------------
		-- falling water sheets (static, slightly see-through)
		------------------------------------------------------------------
		-- main fall: y 0.9 .. 24, front of the basin lip
		box(R, -5, 5, 0.9, 23.2, -3.6, -3.1, WATER, { tr = 0.18 })
		box(R, -6, -5, 0.9, 23.0, -3.5, -3.15, WATER_DK, { tr = 0.18 })
		box(R, 5, 6, 0.9, 23.0, -3.5, -3.15, WATER_DK, { tr = 0.18 })
		-- top fall: y 24.3 .. 40.8, in front of the wet face
		box(R, -3.5, 3.5, BASIN_Y, 39.6, 4.4, 4.85, WATER, { tr = 0.18 })

		------------------------------------------------------------------
		-- moving dashes (MUST match the generator in motion.luau)
		------------------------------------------------------------------
		local function frac(x)
			return x - math.floor(x)
		end
		local FLOWS = {
			{ bone = "MainA", pre = "MA", S = 8, yBot = 1.4, yTop = 23.4, n = 12, subs = 1, z = -3.72, th = 0.2 },
			{ bone = "MainB", pre = "MB", S = 8, yBot = 1.4, yTop = 23.4, n = 9, subs = 2, z = -4.0, th = 0.3 },
			{ bone = "Upper", pre = "UP", S = 6, yBot = 24.6, yTop = 40.2, n = 7, subs = 2, z = 4.15, th = 0.25 },
		}
		local function dashSpec(L, c, s)
			-- x, width, rest phase, length
			if L.pre == "MA" then
				return -5.5 + (c - 1) * 1.0, 0.55 + 0.3 * frac(c * 0.71), L.S * frac(c * 0.618 + 0.1), 2.5 + 2.5 * frac(c * 0.377 + 0.2)
			elseif L.pre == "MB" then
				local ph = L.S * frac(c * 0.414 + 0.3) + (s - 1) * (L.S / 2 + 1.2 * (frac(c * 0.83) - 0.5))
				return -5.2 + (c - 1) * 1.3 + 0.3 * (frac(c * 0.53) - 0.5), 0.8 + 0.45 * frac(c * 0.29), ph % L.S, 1.3 + 1.5 * frac(c * 0.61 + s * 0.27)
			else
				local ph = L.S * frac(c * 0.57 + 0.2) + (s - 1) * L.S * 0.5
				return -3.0 + (c - 1) * 1.0, (s == 1) and 0.55 or 0.85, ph % L.S, (s == 1) and (2 + 1.5 * frac(c * 0.33)) or (1.1 + 1.0 * frac(c * 0.71))
			end
		end
		for _, L in FLOWS do
			local bone = B:bone(L.bone, R, v(0, L.yBot, L.z))
			local rows = math.ceil((L.yTop - L.yBot) / L.S) + 1
			for c = 1, L.n do
				for s = 1, L.subs do
					local x, w, ph, len = dashSpec(L, c, s)
					for j = 0, rows do
						local yc = L.yBot + ph + j * L.S
						local col, z, th, tr
						if L.pre == "MA" then
							col, z, th, tr = (c % 2 == 0) and STREAK or STREAK2, L.z, L.th, 0.1
						elseif L.pre == "MB" then
							col, z, th, tr = (s == 1) and FOAM or FOAM2, L.z - (c % 2) * 0.04, L.th, 0
						else
							col, z, th, tr = (s == 1) and STREAK or FOAM, L.z - (s - 1) * 0.3, L.th, (s == 1) and 0.1 or 0
						end
						B:block(bone, v(w, len, th), cf(x, yc, z), col, { tr = tr, name = ("%s%d_%d_%d"):format(L.pre, c, s, j) })
					end
				end
			end
		end

		------------------------------------------------------------------
		-- pool at floor level
		------------------------------------------------------------------
		local PY = 0.9
		box(R, -14.5, 13, 0, 0.25, -15, -1, POOL_SAND)
		box(R, -9, 9, 0.25, 0.32, -11, -1, POOL_DEEP)
		box(R, -14.5, 13, 0.25, PY, -15.2, -1, WATER, { tr = 0.3 })
		-- splash foam at the base of the main fall (static mound)
		box(R, -6.4, 6.4, PY - 0.1, 1.6, -5.2, -2.6, FOAM2)
		box(R, -5.2, 5.2, 1.4, 2.1, -4.6, -2.9, FOAM)
		box(R, -7.2, -5.4, PY - 0.1, 1.3, -4.6, -2.4, FOAM)
		box(R, 5.4, 7.2, PY - 0.1, 1.3, -4.6, -2.4, FOAM)
		-- churning foam chunks (bob)
		for k = 1, 3 do
			local ch = B:bone("Churn" .. k, R, v(-4.5 + (k - 1) * 4.5, 1.6, -4))
			for m = 1, 3 do
				local x = -6 + (k - 1) * 4.5 + m * 1.1 + rnd(-0.3, 0.3)
				local sz = rnd(0.9, 1.5)
				B:block(ch, v(sz, sz * 0.8, sz), cf(x, 1.5 + rnd(0, 0.6), rnd(-5.0, -3.2), 0, rnd(0, 45), 0), (m % 2 == 0) and FOAM or FOAM2)
			end
		end
		-- basin splash at the foot of the top fall
		box(R, -4.2, 4.2, BASIN_Y - 0.1, 24.8, 2.6, 4.5, FOAM2)
		local cu = B:bone("ChurnUp", R, v(0, 24.8, 3.4))
		for m = 1, 4 do
			local sz = rnd(0.8, 1.2)
			B:block(cu, v(sz, sz * 0.7, sz), cf(-3.6 + m * 1.45, 24.9, rnd(2.4, 3.6), 0, rnd(0, 45), 0), (m % 2 == 0) and FOAM or FOAM2)
		end

		-- ripple rings: 5 direction bones, 3 segments each, slide outward
		-- (must match motion.luau: centre (0, z -3.5), R0 4.5, D 3.5)
		local RC, R0, D = v(0, PY + 0.06, -3.5), 4.5, 3.5
		local DIRS = { 180, 220, 270, 320, 360 }
		for di, th in DIRS do
			local d = v(cos(rad(th)), 0, sin(rad(th)))
			local rb = B:bone("Ripple" .. di, R, RC)
			for i = 0, 1 do
				local r = R0 + i * D
				local p = RC + d * r
				local L = 0.55 * r
				-- tangent frame: local X along tangent
				B:block(rb, v(L, 0.12, 0.35), CFrame.new(p) * ang(0, -th + 90, 0), FOAM, { name = ("Rip%d_%d"):format(di, i) })
			end
		end

		-- rocks in the pool
		local function boulder(x, z, s, mossy)
			B:block(R, v(2.4 * s, 1.5 * s, 2.0 * s), cf(x, 0.75 * s, z, 0, 12, 0), STONE)
			B:block(R, v(1.8 * s, 1.0 * s, 1.6 * s), cf(x + 0.2 * s, 1.55 * s, z - 0.1 * s, 0, -8, 0), STONE_LT)
			B:block(R, v(1.2 * s, 0.6 * s, 1.0 * s), cf(x - 0.5 * s, 0.6 * s, z - 0.7 * s, 0, 30, 0), STONE_DK)
			if mossy then
				B:block(R, v(1.3 * s, 0.25, 1.1 * s), cf(x + 0.2 * s, 2.05 * s + 0.1, z, 0, -8, 0), GRASS)
			end
		end
		boulder(7.5, -9.5, 1.0, true)
		boulder(10.8, -12.5, 0.75, false)
		boulder(-4.0, -12.4, 0.65, true)
		boulder(11.6, -6.5, 0.85, false)
		boulder(-13.0, -3.0, 0.9, true)

		-- lily pads (bob/turn)
		local function lily(name, x, z, s, flowerCol)
			local b = B:bone(name, R, v(x, PY, z))
			B:block(b, v(1.9 * s, 0.14, 1.9 * s), cf(x, PY + 0.06, z, 0, 20, 0), PAD)
			B:block(b, v(1.3 * s, 0.16, 1.3 * s), cf(x - 0.15, PY + 0.08, z + 0.1, 0, 65, 0), PAD_DK)
			B:block(b, v(0.5 * s, 0.2, 0.9 * s), cf(x + 0.6 * s, PY + 0.07, z - 0.3 * s, 0, 20, 0), WATER)
			if flowerCol then
				B:block(b, v(0.7, 0.35, 0.7), cf(x - 0.2, PY + 0.3, z + 0.1, 0, 45, 0), flowerCol)
				B:block(b, v(0.5, 0.45, 0.5), cf(x - 0.2, PY + 0.35, z + 0.1), WHITE)
				B:block(b, v(0.22, 0.5, 0.22), cf(x - 0.2, PY + 0.4, z + 0.1), GOLD)
			end
		end
		lily("Pad1", 4.2, -12.0, 1.0, PINK)
		lily("Pad2", 8.8, -13.6, 0.8, nil)
		lily("Pad3", -1.2, -9.5, 0.9, nil)
		lily("Pad4", -12.0, -13.4, 0.85, WHITE)

		------------------------------------------------------------------
		-- low stone rim at the front edge (z -16 .. -14.4, <= 1.2 high)
		------------------------------------------------------------------
		do
			local x = -14.5
			local k = 0
			while x < 13 do
				local w = math.min(rnd(1.6, 2.8), 13 - x)
				local h = rnd(0.7, 1.15)
				local d = rnd(1.2, 1.5)
				k += 1
				local col = (k % 3 == 0) and STONE_DK or ((k % 3 == 1) and STONE or STONE_LT)
				B:block(R, v(w, h, d), cf(x + w / 2, h / 2, -15.95 + d / 2), col)
				if k % 2 == 0 then
					B:block(R, v(w * 0.6, 0.15, d * 0.6), cf(x + w / 2, h + 0.05, -15.9 + d / 2), (k % 4 == 0) and GRASS or STONE_LT)
				end
				x += w - 0.05
			end
			-- stones along the base of the side walls
			for _, p in { { -14.2, -12 }, { -14.0, -8.5 }, { -14.3, -5.5 }, { 12.7, -11 }, { 12.5, -8 }, { 12.8, -2.5 } } do
				B:block(R, v(1.6, rnd(1.0, 1.4), 2.0), cf(p[1], 0.6, p[2], 0, rnd(-15, 15), 0), pick({ STONE, STONE_LT, STONE_DK }))
			end
			-- grass and flowers dotted on the rim
			tuft(-10.5, 0.6, -15.3, 0.8, PINK)
			tuft(-3.5, 0.6, -15.4, 0.7, nil)
			tuft(2.5, 0.6, -15.3, 0.8, WHITE)
			tuft(9.2, 0.6, -15.4, 0.75, YELLOW)
		end

		------------------------------------------------------------------
		-- water wheel (left, in the pool) + flume from the wall
		------------------------------------------------------------------
		local WC = v(-9.6, 4.7, -10.2)
		local WR = 3.3
		local wheel = B:bone("Wheel", R, CFrame.new(WC))
		local WF = CFrame.new(WC)
		B:block(wheel, v(1.3, 1.3, 2.6), WF, WOOD_DK)
		B:block(wheel, v(0.7, 0.7, 2.9), WF, WOOD_XDK)
		for k = 0, 3 do
			for _, zz in { -0.75, 0.75 } do
				B:block(wheel, v(2 * WR, 0.4, 0.3), WF * CFrame.new(0, 0, zz) * ang(0, 0, k * 45), WOOD)
			end
		end
		local NS = 12
		for k = 0, NS - 1 do
			local a = rad(k * 360 / NS)
			local segL = 2 * WR * math.tan(math.pi / NS) + 0.12
			for _, zz in { -0.8, 0.8 } do
				B:block(wheel, v(segL, 0.5, 0.35), WF * ang(0, 0, k * 360 / NS) * CFrame.new(0, WR, zz), (k % 2 == 0) and WOOD_LT or WOOD)
			end
			-- paddle
			B:block(wheel, v(0.25, 0.85, 2.0), WF * ang(0, 0, k * 360 / NS + 15) * CFrame.new(0, WR + 0.35, 0), WOOD_DK)
		end
		-- axle + posts standing in the pool
		B:block(R, v(0.5, 0.5, 4.4), WF, WOOD_XDK)
		for _, zz in { -2.0, 2.0 } do
			B:block(R, v(0.7, WC.Y + 0.4, 0.6), cf(WC.X - 0.9, (WC.Y + 0.4) / 2, WC.Z + zz, 0, 0, -10), WOOD_DK)
			B:block(R, v(0.7, WC.Y + 0.4, 0.6), cf(WC.X + 0.9, (WC.Y + 0.4) / 2, WC.Z + zz, 0, 0, 10), WOOD_DK)
			B:block(R, v(1.2, 0.8, 0.8), cf(WC.X, WC.Y, WC.Z + zz), WOOD)
			B:block(R, v(2.6, 0.4, 0.5), cf(WC.X, 1.2, WC.Z + zz), WOOD)
		end
		-- flume: trough from a stone spout in the left wall to above the wheel
		local FY = WC.Y + WR + 1.2
		B:block(R, v(1.6, 1.8, 2.0), cf(-16.9, FY + 0.3, WC.Z), STONE)
		B:block(R, v(1.2, 0.5, 1.6), cf(-16.6, FY + 1.3, WC.Z), STONE_LT)
		local x0, x1 = -16.2, -10.6
		box(R, x0, x1, FY - 0.6, FY - 0.25, WC.Z - 0.7, WC.Z + 0.7, WOOD)
		box(R, x0, x1, FY - 0.6, FY + 0.35, WC.Z - 0.85, WC.Z - 0.6, WOOD_DK)
		box(R, x0, x1, FY - 0.6, FY + 0.35, WC.Z + 0.6, WC.Z + 0.85, WOOD_DK)
		box(R, x0 + 0.3, x1, FY - 0.25, FY + 0.1, WC.Z - 0.6, WC.Z + 0.6, WATER, { tr = 0.15 })
		B:block(R, v(0.4, FY - 0.6, 0.4), cf(-13.8, (FY - 0.6) / 2, WC.Z - 0.95), WOOD_DK)
		-- water pouring off the flume end onto the paddles
		box(R, x1 - 0.1, x1 + 0.7, FY - 1.6, FY + 0.05, WC.Z - 0.55, WC.Z + 0.55, WATER_LT, { tr = 0.15 })
		local flumeEnd = box(R, x1, x1 + 0.6, FY - 1.8, FY - 1.4, WC.Z - 0.5, WC.Z + 0.5, FOAM2)

		------------------------------------------------------------------
		-- wooden bridge across the stream at the top
		------------------------------------------------------------------
		do
			local BZ0, BZ1, BY = 10, 12.6, 43.15
			for k = 0, 10 do
				local x = -5.2 + k * 1.04
				box(R, x - 0.48, x + 0.48, BY, BY + 0.3, BZ0 + rnd(-0.1, 0.1), BZ1 + rnd(-0.1, 0.1), (k % 2 == 0) and WOOD_LT or WOOD)
			end
			box(R, -5.6, 5.6, BY - 0.35, BY, BZ0 + 0.2, BZ0 + 0.6, WOOD_DK)
			box(R, -5.6, 5.6, BY - 0.35, BY, BZ1 - 0.6, BZ1 - 0.2, WOOD_DK)
			for _, z in { BZ0 - 0.05, BZ1 + 0.05 } do
				for _, x in { -5.1, 0, 5.1 } do
					B:block(R, v(0.4, 1.5, 0.4), cf(x, BY + 0.9, z), WOOD_DK)
				end
				box(R, -5.4, 5.4, BY + 1.35, BY + 1.65, z - 0.22, z + 0.22, WOOD)
				box(R, -5.4, 5.4, BY + 0.7, BY + 0.9, z - 0.18, z + 0.18, WOOD_LT)
			end
		end

		------------------------------------------------------------------
		-- dressing: bushes, flowers, tufts, nubs
		------------------------------------------------------------------
		-- top
		bush(-8.0, 44.4, 13.0, 0.9, RED)
		bush(7.5, 43.4, 9.5, 0.8, nil)
		bush(16.8, 26.4, 12, 1.0, PINK)
		bush(-17.2, 26.4, 9, 0.9, nil)
		bush(12, 34.4, 10, 0.75, YELLOW)
		bush(-12, 34.4, 13, 0.8, RED)
		bush(18.4, 14.4, -2, 0.75, nil)
		bush(-19.0, 14.4, -7, 0.7, PINK)
		bush(11.4, 18.4, 0.5, 0.65, nil)
		for _, f in {
			{ -6.4, 44.4, 8.4, PINK }, { -9.0, 44.4, 9.6, WHITE }, { 6.2, 43.4, 13.6, YELLOW }, { 8.8, 43.4, 12.2, PINK },
			{ 15.6, 26.4, 6.2, WHITE }, { 18.6, 26.4, 7.5, YELLOW }, { -15.4, 26.4, 13.6, PINK }, { -18.4, 26.4, 5.4, PURPLE },
			{ 11.0, 34.4, 5.0, PINK }, { -11.2, 34.4, 5.4, WHITE }, { 13.7, 5.4, -12, YELLOW }, { 14.2, 5.4, -4, PINK },
			{ -15.4, 5.4, -14, WHITE }, { -15.2, 5.4, -1, YELLOW }, { 16.0, 10.4, -9, PURPLE }, { -17.0, 10.4, -5, PINK },
			{ 18.6, 14.4, -13, PINK }, { -18.8, 14.4, -14, YELLOW }, { 10.6, 18.4, -2.8, WHITE }, { 12.4, 18.4, 1.8, PINK },
			{ 5.4, 34.4, 5.8, YELLOW }, { -5.4, 34.4, 6.2, PINK },
		} do
			flower(f[1], f[2], f[3], f[4])
		end
		tuft(14.2, 5.4, -8, 0.8, nil)
		tuft(-15.4, 5.4, -9, 0.9, PINK)
		tuft(16.1, 10.4, -14, 0.8, WHITE)
		tuft(-17.0, 10.4, -12, 0.8, nil)
		tuft(18.2, 14.4, -8, 0.9, nil)
		tuft(-18.7, 14.4, -1, 0.9, WHITE)
		tuft(17, 26.4, 8, 1.0, nil)
		-- dirt nubs on cliff faces (texture)
		for _ = 1, 26 do
			local face = floor(rnd(0, 4))
			if face == 0 then -- right inner side wall
				nub(rnd(12.9, 13.1), rnd(1, 4.5), rnd(-14, 3), rnd(0.6, 1.0), pick({ DIRT_HI, DIRT_LO }))
			elseif face == 1 then
				nub(rnd(-14.6, -14.4), rnd(1, 4.5), rnd(-14, 3), rnd(0.6, 1.0), pick({ DIRT_HI, DIRT_LO }))
			elseif face == 2 then -- upper faces
				local s = pick({ 1, -1 })
				nub(s * rnd(5, 9.5), rnd(24, 33), 4.95, rnd(0.6, 1.0), pick({ DIRT_HI, DIRT_LO }))
			else -- front faces of side walls / buttresses
				local s = pick({ 1, -1 })
				nub(s * rnd(8, 12.5), rnd(1, 7.5), -5.05, rnd(0.6, 1.0), pick({ DIRT_HI, DIRT_LO }))
			end
		end

		------------------------------------------------------------------
		-- effects
		------------------------------------------------------------------
		local function fx(x0, x1, y0, y1, z0, z1)
			return box(R, x0, x1, y0, y1, z0, z1, WHITE, { tr = 1 })
		end
		local base = fx(-5.5, 5.5, 1.2, 1.8, -4.8, -3)
		B:emitter(base, "smoke", { name = "MistMain", color = { "#ffffff", "#dff6ff" }, rate = 7, size = { 2, 4, 6 }, life = { 1.6, 2.8 }, speed = { 1, 2.5 }, spread = 70 })
		B:emitter(base, "sparkle", { name = "SprayMain", color = { "#ffffff", "#bff0ff" }, rate = 16, size = { 0.35, 0.5, 0 }, life = { 0.6, 1.1 }, speed = { 4, 7 }, spread = 55, accel = { 0, -14, 0 } })
		local bfx = fx(-3, 3, 24.6, 25, 2.8, 4.2)
		B:emitter(bfx, "smoke", { name = "MistBasin", color = "#ffffff", rate = 4, size = { 1.2, 2.5, 3.5 }, life = { 1.2, 2 }, speed = { 0.8, 1.6 }, spread = 60 })
		B:emitter(bfx, "sparkle", { name = "SprayBasin", color = { "#ffffff", "#bff0ff" }, rate = 8, size = { 0.3, 0.4, 0 }, life = { 0.5, 0.9 }, speed = { 3, 5 }, spread = 50, accel = { 0, -12, 0 } })
		local sheetFx = fx(-5.5, 5.5, 3, 22, -4.4, -4.2)
		B:emitter(sheetFx, "sparkle", { name = "FallSparkle", color = { "#ffffff", "#9fe8ff" }, rate = 6, size = { 0.2, 0.5, 0 }, life = { 0.8, 1.4 }, speed = { 0.2, 0.8 }, spread = 180 })
		B:emitter(flumeEnd, "drip", { name = "FlumeDrip", color = { "#ffffff", "#9fe8ff" }, rate = 12, size = { 0.3, 0.25, 0.1 } })
		local petals = fx(-12, 12, 38, 42, 6, 14)
		B:emitter(petals, "leaf", { name = "Petals", color = { "#ff9ccd", "#ffffff" }, rate = 1.5, life = { 4, 6 }, speed = { 0.5, 1.2 }, accel = { 0, -1.2, -0.6 } })
		B:light(base, { name = "PoolGlow", color = "#9fe8ff", brightness = 0.8, range = 16 })
	end,
}
