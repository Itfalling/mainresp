--!nocheck
-- Thornfall (Thorny Woods map landmark). A moody two-tier waterfall that fills
-- a 40 x 32 notch cut into the side cliff of the hallway. Faces -Z (into the
-- run lane). Footprint x [-20, 20], z [-16, 16], y [0, ~46].
-- * mossy grey-brown stone strata cliffs (3 tones, grooved bands) with dark
--   forest grass caps, moss patches, gnarled roots, ferns and thorny brambles
--   with roses; side walls blend with the map cliff (14 high at the front, 26
--   behind z = 4)
-- * a stream at the top (y 40.8) under a mossy fallen-log bridge pours over a
--   lip into a ledge basin (y 24.3), which spills over a second lip into the
--   main fall and a deep teal pool at floor level (surface y 0.9) with a low
--   mossy stone rim at the front edge, rocks, lily pads and a fallen log
--   covered in small glowing toadstools
-- * animated: falling streak/foam dashes on bones MainA / MainB / Upper slide
--   down (seamless, dashes fade in under the lip and out into the splash),
--   splash churn, expanding pool ripple rings, bobbing lily pads, swaying briar
--   vines with roses spilling over the lips, softly pulsing toadstool glow
return {
	DisplayName = "Thornfall",
	Rarity = "Landmark",
	Element = "Thorny Woods",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad, cos, sin, floor = math.rad, math.cos, math.sin, math.floor
		local R = "Root"
		-- palette
		local DIRT1, DIRT2, DIRT3 = "#7d6a58", "#6d5c4b", "#5e4f40"
		local DIRT_HI, DIRT_LO = "#94806b", "#4f4236"
		local WET1, WET2, WET3 = "#55493c", "#4b4034", "#41382d"
		local GRASS, GRASS2, GRASS_DK, GRASS_LT = "#3fae47", "#37a03f", "#2b8a36", "#5cc35f"
		local MOSS, MOSS_DK, MOSS_LT = "#5fae3a", "#3f8a2c", "#86c94a"
		local STONE_LT, STONE, STONE_DK = "#a9a397", "#8d8a80", "#686660"
		local ROOT, ROOT_DK, ROOT_LT = "#4e3424", "#36241a", "#6b4a32"
		local GRAIN, GRAIN_DK = "#c9995e", "#a0723f"
		local WATER, WATER_DK, WATER_LT = "#2fb0cf", "#1b8aae", "#7fdde6"
		local POOL_DEEP, POOL_SAND = "#146f8e", "#3f9c9a"
		local STREAK, STREAK2, FOAM, FOAM2 = "#a6eef0", "#cff8f4", "#f4fffd", "#d4f6f2"
		local PAD, PAD_DK = "#3f9a3a", "#2d7a2e"
		local CANE, CANE_DK, CANE_LT = "#3f7a2e", "#2c5a22", "#4f8f34"
		local THORN = "#ecdfb8"
		local ROSE, ROSE_DK, ROSE_LT, ROSE_HI = "#d8203e", "#9a1430", "#ff5a77", "#ff9aae"
		local LEAF, LEAF_DK = "#26803e", "#1d6a35"
		local FERN, FERN_DK, FERN_LT = "#2f9a52", "#1f6e3c", "#6fd06a"
		local STALK, STALK_DK, SPOT = "#fdeecb", "#e4cb9a", "#fbf6ea"
		local GLOW_T, GLOW_V = "#5ff2d8", "#c58bff"
		local PINK, WHITE, YELLOW, GOLD, RED, PURPLE = "#ff86b3", "#ffffff", "#ffe14a", "#ffcf3a", "#d8203e", "#b98cff"

		local seed = 4471
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
		-- 26 high behind).
		------------------------------------------------------------------
		for _, s in { 1, -1 } do
			local i1 = (s == 1) and 13 or 13.5 -- inner face of the bottom step
			local i2 = (s == 1) and 15 or 15.6
			local i3 = (s == 1) and 17 or 17.6
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
		-- basin side rims: chunky stacked stones with grass, both sides
		for _, s in { 1, -1 } do
			B:block(R, v(3.0, 2.0, 3.4), cf(s * 8.1, 24.0, -1.4, 0, s * 8, 0), STONE)
			B:block(R, v(2.6, 1.8, 3.0), cf(s * 8.3, 23.9, 2.6, 0, -s * 6, 0), STONE_DK)
			B:block(R, v(2.0, 1.0, 2.2), cf(s * 8.4, 25.3, -1.0, 0, s * 20, 0), STONE_LT)
			B:block(R, v(1.6, 0.25, 1.6), cf(s * 8.4, 25.9, -1.0, 0, s * 20, 0), MOSS)
			B:block(R, v(1.7, 1.5, 1.8), cf(s * 6.9, 23.9, -3.0, 0, s * 30, 0), STONE_LT)
			B:block(R, v(1.2, 0.9, 1.3), cf(s * 7.4, 23.5, 4.8, 0, s * 15, 0), STONE)
			tuft(s * 8.9, 24.8, 4.1, 1.0, nil)
		end
		-- lip curl where the basin spills over (hides the dashes entering)
		local function curl(x0, x1, yTop, zFront, zBack)
			box(R, x0, x1, yTop - 0.5, yTop, zFront + 0.4, zBack, "#c2f4f0")
			box(R, x0 - 0.1, x1 + 0.1, yTop - 1.85, yTop - 0.45, zFront, zFront + 1.5, "#93e4e6", { tr = 0.05 })
			box(R, x0 + 0.1, x1 - 0.1, yTop - 2.6, yTop - 1.8, zFront + 0.2, zFront + 1.3, "#6ccfdc", { tr = 0.1 })
			local n = math.floor((x1 - x0) / 1.6)
			for k = 0, n - 1 do
				local x = x0 + 0.8 + k * (x1 - x0 - 1.6) / math.max(1, n - 1) + rnd(-0.3, 0.3)
				B:block(R, v(rnd(0.7, 1.1), rnd(0.35, 0.55), 0.3), cf(x, yTop - rnd(0.6, 1.3), zFront - 0.05), (k % 2 == 0) and FOAM or FOAM2)
			end
		end
		curl(-6.1, 6.1, 24.4, -4.45, -2.6)
		curl(-3.6, 3.6, 40.9, 3.6, 5.6)
		-- stream water at the top
		box(R, -4.1, 4.1, 40.05, 40.8, 4.6, 16, WATER, { tr = 0.2 })
		for _, z in { 7.2, 11.6, 14.6 } do
			box(R, rnd(-2.8, -1), rnd(0.8, 2.8), 40.78, 40.86, z, z + 0.5, FOAM2)
		end

		------------------------------------------------------------------
		-- falling water sheets (static, slightly see-through)
		------------------------------------------------------------------
		-- main fall: y 0.9 .. 24, front of the basin lip
		box(R, -6, 6, 0.9, 22.0, -3.1, -3.02, "#1e93b8")
		box(R, -5, 5, 0.9, 23.2, -3.6, -3.1, WATER, { tr = 0.25 })
		box(R, -6, -5, 0.9, 23.0, -3.5, -3.15, WATER_DK, { tr = 0.18 })
		box(R, 5, 6, 0.9, 23.0, -3.5, -3.15, WATER_DK, { tr = 0.18 })
		-- top fall: y 24.3 .. 40.8, in front of the wet face
		box(R, -3.5, 3.5, BASIN_Y, 39.0, 4.85, 4.95, "#1e93b8")
		box(R, -3.5, 3.5, BASIN_Y, 39.6, 4.4, 4.85, WATER, { tr = 0.25 })

		------------------------------------------------------------------
		-- moving dashes (MUST match the generator in motion.luau)
		------------------------------------------------------------------
		local function frac(x)
			return x - math.floor(x)
		end
		local FLOWS = {
			{ bone = "MainA", pre = "MA", S = 4, yBot = 5.6, yTop = 23.4, n = 14, subs = 1, z = -3.72, th = 0.2, fT = 1.6, fB = 1.6 },
			{ bone = "MainB", pre = "MB", S = 4, yBot = 5.6, yTop = 23.4, n = 6, subs = 1, z = -4.0, th = 0.3, fT = 1.4, fB = 1.4 },
			{ bone = "Upper", pre = "UP", S = 4, yBot = 24.8, yTop = 39.8, n = 7, subs = 2, z = 4.15, th = 0.25, fT = 1.2, fB = 1.0 },
		}
		local function dashSpec(L, c, s)
			-- x, width, rest phase, length
			if L.pre == "MA" then
				return -5.55 + (c - 1) * 0.85 + 0.25 * (frac(c * 0.71) - 0.5), 0.3 + 0.25 * frac(c * 0.37), L.S * frac(c * 0.618 + 0.1), 2.2 + 1.3 * frac(c * 0.377 + 0.2)
			elseif L.pre == "MB" then
				local ph = L.S * frac(c * 0.414 + 0.3) + (s - 1) * (L.S / 2 + 1.2 * (frac(c * 0.83) - 0.5))
				return -4.6 + (c - 1) * 1.85 + 0.5 * (frac(c * 0.53) - 0.5), 0.45 + 0.3 * frac(c * 0.29), ph % L.S, 0.8 + 0.9 * frac(c * 0.61 + s * 0.27)
			else
				local ph = L.S * frac(c * 0.57 + 0.2) + (s - 1) * L.S * 0.5
				return -3.1 + (c - 1) * 1.03 + 0.2 * (frac(c * 0.47) - 0.5), (s == 1) and (0.3 + 0.2 * frac(c * 0.37)) or (0.45 + 0.25 * frac(c * 0.59)), ph % L.S, (s == 1) and (1.6 + 1.0 * frac(c * 0.33)) or (0.9 + 0.7 * frac(c * 0.71))
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
						if yc + len / 2 - L.S >= L.yTop then
							continue -- never reaches the visible window
						end
						-- rest-pose visibility (same fade as motion.luau at offset 0)
						local a = math.clamp((L.yTop - (yc + len / 2)) / L.fT, 0, 1) * math.clamp(((yc - len / 2) - L.yBot) / L.fB, 0, 1)
						local col, z, th, tr
						if L.pre == "MA" then
							col, z, th, tr = ({ STREAK, "#6cd0dc", STREAK2 })[c % 3 + 1], L.z, L.th, 0.1
						elseif L.pre == "MB" then
							col, z, th, tr = (s == 1) and FOAM or FOAM2, L.z - (c % 2) * 0.04, L.th, 0
						else
							col, z, th, tr = (s == 1) and STREAK or FOAM, L.z - (s - 1) * 0.3, L.th, (s == 1) and 0.1 or 0
						end
						tr = tr + (1 - tr) * (1 - a)
						B:block(bone, v(w, len, th), cf(x, yc, z), col, { tr = tr, name = ("%s%d_%d_%d"):format(L.pre, c, s, j) })
					end
				end
			end
		end

		------------------------------------------------------------------
		-- pool at floor level
		------------------------------------------------------------------
		local PY = 0.9
		box(R, -13.5, 13, 0, 0.25, -15, -1, POOL_SAND)
		box(R, -9, 9, 0.25, 0.32, -11, -1, POOL_DEEP)
		box(R, -13.5, 13, 0.25, PY, -15.2, -1, WATER, { tr = 0.3 })
		-- foam plume at the base of the main fall (stepped, static) - it also
		-- hides where the falling dashes fade out
		box(R, -7.2, 7.2, PY - 0.1, 2.2, -6.0, -2.4, FOAM2)
		box(R, -6.6, 6.6, 2.2, 3.8, -5.4, -2.6, FOAM)
		box(R, -6.0, 6.0, 3.8, 5.2, -5.0, -2.8, FOAM2)
		for k = 0, 5 do
			local x = -5.4 + k * 2.15 + rnd(-0.3, 0.3)
			B:block(R, v(rnd(1.4, 2.0), rnd(0.8, 1.3), 1.6), cf(x, 5.3, rnd(-4.6, -4.2), 0, rnd(-20, 20), 0), (k % 2 == 0) and FOAM or FOAM2)
		end
		for _, s in { 1, -1 } do
			B:block(R, v(1.8, 1.2, 1.8), cf(s * 7.6, 1.4, -4.6, 0, 25, 0), FOAM)
			B:block(R, v(1.4, 0.9, 1.4), cf(s * 6.4, 1.2, -6.6, 0, 10, 0), FOAM2)
			B:block(R, v(1.2, 0.8, 1.2), cf(s * 3.2, 1.1, -6.8, 0, 40, 0), FOAM)
		end
		-- churning foam chunks (bob) along the plume top and sides
		for k = 1, 3 do
			local ch = B:bone("Churn" .. k, R, v(-4.5 + (k - 1) * 4.5, 5.6, -4.4))
			for m = 1, 3 do
				local x = -6.2 + (k - 1) * 4.4 + m * 1.15 + rnd(-0.3, 0.3)
				local sz = rnd(1.0, 1.5)
				B:block(ch, v(sz, sz * 0.8, sz), cf(x, 5.6 + rnd(0, 0.7), rnd(-5.0, -4.5), 0, rnd(0, 45), 0), (m % 2 == 0) and FOAM or FOAM2)
			end
			local sz = rnd(1.0, 1.4)
			B:block(ch, v(sz, sz * 0.8, sz), cf(-5.5 + (k - 1) * 5.5, rnd(2.6, 3.6), -5.7, 0, rnd(0, 45), 0), FOAM)
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
		boulder(-2.6, -12.6, 0.65, true)
		boulder(11.6, -6.5, 0.85, false)
		boulder(9.0, -3.0, 0.8, true)

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
		lily("Pad4", 1.6, -14.0, 0.8, WHITE)

		------------------------------------------------------------------
		-- low stone rim at the front edge (z -16 .. -14.4, <= 1.2 high)
		------------------------------------------------------------------
		do
			local x = -13.5
			local k = 0
			while x < 13 do
				local w = math.min(rnd(1.6, 2.8), 13 - x)
				if w < 0.6 then
					break
				end
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
			for _, p in { { -13.2, -2.5 }, { -12.9, -6.0 }, { 12.7, -11 }, { 12.5, -8 }, { 12.8, -2.5 } } do
				local h = rnd(1.0, 1.4)
				B:block(R, v(1.6, h, 2.0), cf(p[1], h / 2, p[2], 0, rnd(-15, 15), 0), pick({ STONE, STONE_LT, STONE_DK }))
			end
			-- grass and flowers dotted on the rim
			tuft(-10.5, 0.6, -15.3, 0.8, nil)
			tuft(-3.5, 0.6, -15.4, 0.7, nil)
			tuft(2.5, 0.6, -15.3, 0.8, nil)
			tuft(9.2, 0.6, -15.4, 0.75, nil)
		end


		------------------------------------------------------------------
		-- thorny-woods helpers
		------------------------------------------------------------------
		local UPZ = v(0, 0, 1)
		local function look(p, dir)
			local d = dir.Unit
			return (P.aim(p - d, p + d))
		end
		local function rose(p, dir, k, bone)
			bone = bone or R
			local f = look(p, dir)
			B:block(bone, v(1.8 * k, 0.6 * k, 0.25), f * CFrame.new(0, 0, 0.1) * ang(0, 0, 30), LEAF)
			B:block(bone, v(1.5 * k, 1.5 * k, 0.6 * k), f * CFrame.new(0, 0, -0.2 * k), ROSE_DK)
			B:block(bone, v(1.3 * k, 1.3 * k, 0.55 * k), f * CFrame.new(0, 0, -0.5 * k) * ang(0, 0, 45), ROSE)
			B:block(bone, v(0.85 * k, 0.85 * k, 0.45 * k), f * CFrame.new(0, 0, -0.8 * k) * ang(0, 0, 20), ROSE_LT)
			B:block(bone, v(0.4 * k, 0.4 * k, 0.3 * k), f * CFrame.new(0, 0, -1.02 * k) * ang(0, 0, 65), ROSE_HI)
		end
		local TAN = math.tan(math.rad(22.5))
		-- octagonal log from a to b (4 crossed strips) with end-grain caps
		local function log(a, b, apo, c1, c2)
			local f, len = P.aim(a, b)
			for k = 0, 3 do
				B:block(R, v(2 * apo * TAN + 0.02, 2 * apo, len), f * ang(0, 0, 45 * k), (k % 2 == 0) and c1 or c2)
			end
			for _, e in { -1, 1 } do
				local ef = f * CFrame.new(0, 0, e * (len / 2 + 0.04))
				for k = 0, 1 do
					B:block(R, v(2 * apo * 0.8 * TAN + 0.02, 2 * apo * 0.8, 0.1), ef * ang(0, 0, 22.5 + 90 * k), GRAIN)
				end
				B:block(R, v(apo * 0.55, apo * 0.55, 0.14), ef * ang(0, 0, 45), GRAIN_DK)
			end
			return f, len
		end
		local glowN = 0
		local function gtoad(p, k, col, lean)
			local base = CFrame.new(p) * ang(0, rnd(0, 90), lean or 0)
			B:block(R, v(0.5 * k, 0.3 * k, 0.5 * k), base * CFrame.new(0, 0.15 * k, 0), STALK_DK)
			B:block(R, v(0.4 * k, 1.0 * k, 0.4 * k), base * CFrame.new(0, 0.5 * k, 0), STALK)
			glowN += 1
			B:block(R, v(1.3 * k, 0.4 * k, 1.3 * k), base * CFrame.new(0, 1.1 * k, 0), col, { mat = "Neon", name = (glowN <= 8) and ("Glow" .. glowN) or nil })
			B:block(R, v(0.85 * k, 0.32 * k, 0.85 * k), base * CFrame.new(0, 1.42 * k, 0) * ang(0, 45, 0), col)
			B:block(R, v(0.24 * k, 0.1, 0.24 * k), base * CFrame.new(0.32 * k, 1.34 * k, 0.22 * k), SPOT)
			B:block(R, v(0.22 * k, 0.1, 0.22 * k), base * CFrame.new(-0.2 * k, 1.62 * k, -0.1 * k), SPOT)
		end
		local function frond(base, yaw, len, lift, col)
			local dir = v(sin(rad(yaw)), 0, -cos(rad(yaw)))
			local p1 = base + dir * (len * 0.25) + v(0, len * 0.7, 0)
			local p2 = p1 + dir * (len * 0.6) + v(0, len * lift, 0)
			B:bar(R, base, p1, 0.2, 0.2, FERN_DK, { up = UPZ })
			for j, lf in { { base, p1, 0.6, 1.3 }, { p1, p2, 0.45, 1.25 } } do
				local fr = P.aim(lf[1], lf[2], UPZ)
				local p = lf[1]:Lerp(lf[2], lf[3])
				B:block(R, v(lf[4] * len / 3.2, 0.12, (lf[2] - lf[1]).Magnitude * 0.9), CFrame.new(p) * (fr - fr.Position), (j % 2 == 0) and col or FERN)
			end
		end
		local function fern(x, y, z, sz, rot)
			local base = v(x, y, z)
			for j = 0, 4 do
				frond(base, rot + j * 72 + rnd(-12, 12), sz * rnd(0.85, 1.1), rnd(-0.25, -0.05), (j % 2 == 0) and FERN_LT or FERN)
			end
			B:block(R, v(0.6, 0.4, 0.6), CFrame.new(base + v(0, 0.1, 0)), FERN_DK)
		end
		local function root(pts, w)
			for i = 1, #pts - 1 do
				local ww = w * (1 - 0.1 * (i - 1))
				B:bar(R, pts[i], pts[i + 1], ww, ww, (i % 2 == 0) and ROOT or ROOT_DK, { up = UPZ })
				if i > 1 then
					B:block(R, v(ww * 1.25, ww * 1.1, ww * 1.25), CFrame.new(pts[i]) * ang(0, 30 * i, 0), ROOT_LT)
				end
			end
		end
		local function bramble(x, y, z, s, nr)
			B:block(R, v(2.4 * s, 1.4 * s, 2.0 * s), cf(x, y + 0.7 * s, z, 0, 10, 0), LEAF_DK)
			B:block(R, v(1.8 * s, 1.4 * s, 1.6 * s), cf(x + 0.6 * s, y + 1.2 * s, z - 0.2 * s, 0, 35, 0), LEAF)
			B:block(R, v(1.5 * s, 1.2 * s, 1.4 * s), cf(x - 0.7 * s, y + 1.3 * s, z + 0.2 * s, 0, -20, 0), GRASS_DK)
			local a1, a2, a3 = v(x - 1.2 * s, y + 1.0 * s, z - 0.7 * s), v(x - 0.2 * s, y + 2.3 * s, z - 0.95 * s), v(x + 1.3 * s, y + 1.3 * s, z - 0.85 * s)
			B:bar(R, a1, a2, 0.25, 0.25, CANE)
			B:bar(R, a2, a3, 0.25, 0.25, CANE_DK)
			B:block(R, v(0.18, 0.18, 0.4), CFrame.new(a1:Lerp(a2, 0.5) + v(0, 0.15, -0.1)) * ang(30, 0, 40), THORN)
			B:block(R, v(0.18, 0.18, 0.4), CFrame.new(a2:Lerp(a3, 0.5) + v(0, 0.15, -0.1)) * ang(30, 0, -40), THORN)
			for k = 1, nr do
				local a = rad(k * 137 + 20)
				rose(v(x + cos(a) * 0.8 * s, y + (1.5 + 0.2 * k) * s, z + sin(a) * 0.5 * s - 0.5 * s), v(cos(a) * 0.4, 0.8, -0.7), 0.7 * s)
			end
		end
		local function outcrop(x, y, z, sc)
			B:block(R, v(3.0 * sc, 1.6 * sc, 1.6 * sc), cf(x, y, z - 0.6 * sc), DIRT2)
			B:block(R, v(2.2 * sc, 1.2 * sc, 1.4 * sc), cf(x + 0.4 * sc, y - 1.1 * sc, z - 0.4 * sc), DIRT3)
			B:block(R, v(1.6 * sc, 0.9 * sc, 1.0 * sc), cf(x - 0.6 * sc, y + 0.9 * sc, z - 0.3 * sc), DIRT_HI)
			B:block(R, v(3.2 * sc, 0.4, 1.9 * sc), cf(x, y + 0.85 * sc, z - 0.7 * sc), MOSS)
			B:block(R, v(1.0, 0.8, 0.3), cf(x - 0.9 * sc, y + 0.35 * sc, z - 1.62 * sc), MOSS_DK)
		end
		local function moss(x, y, z, w, h)
			B:block(R, v(w, h, 0.3), cf(x, y, z - 0.12), MOSS_DK)
			B:block(R, v(w * 0.6, h * 0.6, 0.3), cf(x + w * 0.15, y + h * 0.1, z - 0.22), pick({ MOSS, MOSS_LT }))
		end
		local function strand(x, y, z, n)
			for k = 0, n - 1 do
				local yy = y - 0.6 - k * 0.95
				B:block(R, v(0.35, 1.0, 0.35), cf(x + ((k % 2 == 0) and 0 or 0.15), yy, z - 0.2), (k % 2 == 0) and MOSS_DK or LEAF_DK)
				B:block(R, v(0.65, 0.5, 0.3), cf(x + ((k % 2 == 0) and 0.32 or -0.28), yy + 0.1, z - 0.35, 0, 0, (k % 2 == 0) and 25 or -25), (k % 2 == 0) and MOSS or LEAF)
			end
		end

		------------------------------------------------------------------
		-- fallen mossy log in the pool (left), covered in glowing toadstools
		------------------------------------------------------------------
		local LA, LB = v(-12.9, 1.25, -5.0), v(-7.4, 1.32, -12.4)
		local lf, ll = log(LA, LB, 1.2, ROOT, ROOT_LT)
		B:block(R, v(1.5, 0.3, ll * 0.7), lf * CFrame.new(0.1, 1.2, -0.4), MOSS)
		B:block(R, v(0.9, 0.3, ll * 0.35), lf * CFrame.new(-0.3, 1.32, 1.6), MOSS_LT)
		B:block(R, v(0.4, 0.9, 1.6), lf * CFrame.new(1.25, 0.4, 0.8), MOSS_DK)
		-- a broken branch stub
		B:bar(R, (lf * CFrame.new(0.6, 0.8, 2.2)).Position, (lf * CFrame.new(1.8, 2.4, 2.8)).Position, 0.45, 0.45, ROOT_DK, { up = UPZ })
		local logTop = function(xl, zl)
			return (lf * CFrame.new(xl, 1.32, zl)).Position
		end
		gtoad(logTop(0.2, -2.8), 1.0, GLOW_T, 4)
		gtoad(logTop(-0.3, -1.6), 0.7, GLOW_V, -8)
		gtoad(logTop(0.1, 2.6), 0.85, GLOW_T, 6)
		-- shelf fungus on the side
		B:block(R, v(0.5, 0.25, 1.2), lf * CFrame.new(1.35, 0.0, -1.0), "#d77a2c")
		B:block(R, v(0.4, 0.22, 0.9), lf * CFrame.new(1.3, -0.45, -0.2), "#eda04a")
		local logFx = B:block(R, v(1.0, 0.4, 3.0), lf * CFrame.new(0, 1.8, 0), WHITE, { tr = 1 })

		------------------------------------------------------------------
		-- mossy fallen-log bridge across the stream at the top
		------------------------------------------------------------------
		local bf, bl = log(v(-6.7, 43.95, 11.3), v(6.7, 43.8, 10.9), 0.85, ROOT, ROOT_LT)
		B:block(R, v(1.1, 0.25, bl * 0.6), bf * CFrame.new(0, 0.85, 0.8), MOSS)
		B:block(R, v(0.8, 0.25, 2.2), bf * CFrame.new(0.1, 0.92, -3.6), MOSS_LT)
		gtoad((bf * CFrame.new(0.1, 0.9, -2.2)).Position, 0.6, GLOW_V, 0)
		rose((bf * CFrame.new(0, 1.0, 3.6)).Position + v(0, 0.3, 0), v(0, 0.6, -1), 0.7)

		------------------------------------------------------------------
		-- gnarled roots over the lips and down the faces
		------------------------------------------------------------------
		for _, s in { 1, -1 } do
			root({ v(s * 6.7, 24.6, -3.2), v(s * 7.05, 22.6, -3.75), v(s * 6.55, 20.6, -3.65), v(s * 6.95, 18.6, -3.9), v(s * 6.5, 16.8, -3.8) }, 0.55)
			root({ v(s * 10.2, 18.5, -4.0), v(s * 10.6, 16.5, -4.4), v(s * 10.1, 14.6, -4.35), v(s * 10.5, 12.9, -4.45) }, 0.5)
			root({ v(s * 4.7, 43.2, 6.8), v(s * 5.05, 41.0, 6.55), v(s * 4.65, 38.8, 6.6), v(s * 5.0, 36.6, 6.6), v(s * 4.7, 35.0, 6.6) }, 0.5)
			root({ v(s * 9.4, 34.4, 4.8), v(s * 9.0, 32.4, 4.5), v(s * 9.5, 30.3, 4.55), v(s * 9.1, 28.6, 4.55) }, 0.45)
		end
		-- roots reaching from the walls into the pool
		root({ v(12.9, 4.6, -9.0), v(12.0, 3.0, -9.6), v(11.4, 1.4, -10.4), v(10.4, 0.6, -10.9) }, 0.55)
		root({ v(-13.4, 4.6, -1.8), v(-12.4, 2.8, -2.4), v(-11.6, 1.2, -2.6), v(-10.6, 0.6, -3.4) }, 0.5)

		------------------------------------------------------------------
		-- briar vines with roses spilling over the lips (animated sway)
		------------------------------------------------------------------
		local function vine(name, top, s1, s2)
			B:bone(name .. "a", R, top)
			local mid = top + s1
			B:bone(name .. "b", name .. "a", mid)
			local tip = mid + s2
			local function cane(bone, a, b)
				B:bar(bone, a, b, 0.3, 0.3, CANE, { up = UPZ })
				local p = a:Lerp(b, 0.5)
				B:block(bone, v(0.18, 0.18, 0.4), CFrame.new(p + v(0.18, 0.05, -0.15)) * ang(30, 0, 40), THORN)
				B:block(bone, v(0.18, 0.18, 0.4), CFrame.new(a:Lerp(b, 0.85) + v(-0.18, 0.05, -0.15)) * ang(30, 0, -40), THORN)
			end
			local q1 = top + s1 * 0.5 + v(0.35, 0, -0.1)
			cane(name .. "a", top, q1)
			cane(name .. "a", q1, mid)
			local q2 = mid + s2 * 0.5 + v(-0.35, 0, -0.1)
			cane(name .. "b", mid, q2)
			cane(name .. "b", q2, tip)
			B:block(name .. "a", v(0.9, 0.12, 0.55), CFrame.new(q1 + v(0.45, 0, -0.15)) * ang(0, 0, 25), LEAF)
			B:block(name .. "b", v(0.9, 0.12, 0.55), CFrame.new(q2 + v(-0.45, 0, -0.15)) * ang(0, 0, -25), LEAF_DK)
			rose(mid + v(0.35, 0.1, -0.55), v(0.3, -0.1, -1), 0.75, name .. "b")
			rose(tip + v(0, -0.3, -0.45), v(0, -0.45, -1), 0.95, name .. "b")
		end
		vine("Vine1", v(7.6, 24.6, -4.7), v(0.3, -3.2, -0.15), v(-0.2, -3.0, -0.1))
		vine("Vine2", v(-7.5, 24.6, -4.7), v(-0.3, -3.6, -0.15), v(0.25, -2.8, -0.1))
		vine("Vine3", v(6.2, 43.3, 6.3), v(0.25, -2.8, -0.1), v(-0.2, -2.6, -0.05))
		vine("Vine4", v(-6.4, 44.3, 6.3), v(-0.25, -3.2, -0.1), v(0.2, -2.9, -0.05))

		------------------------------------------------------------------
		-- dressing: brambles, ferns, toadstools, outcrops, moss
		------------------------------------------------------------------
		bramble(17.0, 26.45, 11.0, 1.0, 3)
		bramble(-17.4, 26.45, 9.0, 0.95, 2)
		bramble(12.0, 34.45, 12.0, 0.8, 2)
		bramble(-8.0, 44.45, 13.5, 0.85, 2)
		bramble(7.6, 43.45, 13.6, 0.8, 2)
		bramble(18.6, 14.45, -4.0, 0.75, 2)
		bramble(-18.8, 14.45, -11.0, 0.75, 2)
		fern(14.0, 5.4, -5.0, 2.0, 10)
		fern(-14.6, 5.4, -12.0, 2.0, 40)
		fern(-15.5, 26.4, 13.0, 2.4, 20)
		fern(11.3, 18.4, 1.0, 1.8, 60)
		fern(-11.5, 34.4, 9.0, 2.0, 30)
		fern(16.0, 10.4, -12.5, 1.8, 50)
		gtoad(v(14.0, 5.45, -11.0), 0.8, GLOW_V, 0)
		gtoad(v(-16.6, 10.45, -8.0), 0.8, GLOW_T, 0)
		gtoad(v(11.6, 18.45, -2.4), 0.75, GLOW_V, 0)
		gtoad(v(-8.6, 24.8, 3.0), 0.7, GLOW_T, 0)
		gtoad(v(12.4, 34.45, 7.0), 0.8, GLOW_T, 0)
		gtoad(v(-16.4, 26.45, 6.0), 0.85, GLOW_V, 0)
		gtoad(v(18.6, 14.45, -13.0), 0.7, GLOW_T, 0)
		outcrop(-7.6, 29.5, 5, 1.0)
		outcrop(7.4, 31.0, 5, 0.9)
		outcrop(12.0, 25.5, 3, 0.9)
		outcrop(-12.0, 28.5, 3, 0.9)
		outcrop(17.2, 19.5, 4, 0.9)
		outcrop(-17.4, 21.0, 4, 0.9)
		outcrop(-10.4, 13.0, -4, 0.8)
		gtoad(v(-10.6, 13.7, -4.95), 0.55, GLOW_V, 0)
		for _, m in {
			{ 9.0, 6.0, -5 }, { -9.6, 3.2, -5 }, { 11.5, 15.0, -4 }, { -8.4, 10.6, -4 }, { 6.5, 27.0, 5 }, { -6.0, 32.5, 5 },
			{ 12.5, 30.5, 3 }, { -12.6, 22.5, 3 }, { 18.2, 22.5, 4 }, { -16.5, 17.0, 4 }, { 8.0, 40.0, 7 }, { -7.5, 41.0, 7 },
			{ 18.5, 8.0, -16 }, { -19.0, 4.0, -16 }, { 16.0, 3.0, -16 }, { -17.0, 11.5, -16 },
		} do
			moss(m[1], m[2], m[3], rnd(1.4, 2.4), rnd(1.0, 1.8))
		end
		strand(-5.3, 34, 4.75, 4)
		strand(9.3, 34, 4.75, 3)
		strand(11.2, 18, -4.25, 4)
		strand(-12.2, 18, -4.25, 4)
		strand(15.8, 26, 3.75, 3)
		strand(-15.0, 26, 3.75, 4)
		-- grass tufts on ledges
		tuft(14.2, 5.4, -8, 0.8, nil)
		tuft(-14.6, 5.4, -4, 0.9, nil)
		tuft(16.1, 10.4, -6, 0.8, nil)
		tuft(-16.7, 10.4, -13, 0.8, nil)
		tuft(18.2, 14.4, -8, 0.9, nil)
		tuft(-18.8, 14.4, -2, 0.9, nil)

		------------------------------------------------------------------
		-- effects
		------------------------------------------------------------------
		local function fx(x0, x1, y0, y1, z0, z1)
			return box(R, x0, x1, y0, y1, z0, z1, WHITE, { tr = 1 })
		end
		local base = fx(-5.5, 5.5, 3.5, 5.0, -5.4, -4.2)
		B:emitter(base, "smoke", { name = "MistMain", color = { "#f4fffd", "#cdeee9" }, rate = 7, size = { 2, 4, 6 }, life = { 1.6, 2.8 }, speed = { 1, 2.5 }, spread = 70 })
		B:emitter(base, "sparkle", { name = "SprayMain", color = { "#ffffff", "#aef0ea" }, rate = 16, size = { 0.35, 0.5, 0 }, life = { 0.6, 1.1 }, speed = { 4, 7 }, spread = 55, accel = { 0, -14, 0 } })
		local bfx = fx(-3, 3, 24.6, 25, 2.8, 4.2)
		B:emitter(bfx, "smoke", { name = "MistBasin", color = "#f4fffd", rate = 4, size = { 1.2, 2.5, 3.5 }, life = { 1.2, 2 }, speed = { 0.8, 1.6 }, spread = 60 })
		B:emitter(bfx, "sparkle", { name = "SprayBasin", color = { "#ffffff", "#aef0ea" }, rate = 8, size = { 0.3, 0.4, 0 }, life = { 0.5, 0.9 }, speed = { 3, 5 }, spread = 50, accel = { 0, -12, 0 } })
		local sheetFx = fx(-5.5, 5.5, 6, 22, -4.4, -4.2)
		B:emitter(sheetFx, "sparkle", { name = "FallSparkle", color = { "#ffffff", "#8fe8e0" }, rate = 6, size = { 0.2, 0.5, 0 }, life = { 0.8, 1.4 }, speed = { 0.2, 0.8 }, spread = 180 })
		local flies = fx(-12, 12, 2, 9, -14, -6)
		B:emitter(flies, "sparkle", { name = "Fireflies", color = { "#e8ff7a", "#9dffc4" }, rate = 4, size = { 0.2, 0.4, 0 }, life = { 2, 3.5 }, speed = { 0.2, 0.7 }, spread = 180, light = 1 })
		local petals = fx(-12, 12, 38, 42, 6, 14)
		B:emitter(petals, "leaf", { name = "Petals", color = { "#ff5a77", "#ff9aae" }, rate = 1.5, life = { 4, 6 }, speed = { 0.5, 1.2 }, accel = { 0, -1.2, -0.6 } })
		B:emitter(logFx, "glow", { name = "Spores", color = { "#5ff2d8", "#c58bff" }, rate = 2, size = { 0.4, 0.8, 0.2 }, life = { 1.5, 2.5 }, speed = { 0.3, 0.8 }, accel = { 0, 0.6, 0 } })
		B:light(base, { name = "PoolGlow", color = "#7fe8e0", brightness = 0.7, range = 16 })
		B:light(logFx, { name = "ToadLight", color = "#b88cff", brightness = 0.6, range = 10 })
	end,
}
