--!nocheck
-- Harvest Moon Melon (Scarecrow Stage crop #7, Secret).
-- A night-sky melon vine climbing a rustic garden tepee. A stepped dirt
-- mound strewn with hay; three weathered wooden stakes lashed together with
-- straw twine; two teal-green vines spiral up the stakes, sprouting big
-- rotated studded leaf cubes in indigo / purple / violet speckled with tiny
-- glowing star dots, and a leafy cluster where the stakes cross. The melons
-- are pale cream with silver-blue stripes and a softly glowing crescent moon
-- on each flank: three big ones resting on hay at the foot, three hanging
-- off the vine. A chunky pale-gold crescent moon (with a sleepy smile) is
-- hooked on top, little star crosses twinkle around it.
-- Static prop: no motion.luau.
return {
	DisplayName = "Harvest Moon Melon",
	Rarity = "Secret",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette ---------------------------------------------------------
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local GRASS, GRASS_DK = "#7cc23a", "#5a9a2e"
		local HAY, HAY_DK, HAY_LT = "#e6bd55", "#c79634", "#f6da84"
		local WOOD, WOOD_DK, WOOD_LT = "#9a7046", "#7a5534", "#b88a5c"
		local VINE_DK, VINE, VINE_LT = "#22524a", "#2f6c5f", "#468a70"
		local LEAF_NT, LEAF_DK, LEAF, LEAF_LT, LEAF_HI = "#2c2368", "#3f2c8c", "#5a3cb0", "#7656cf", "#9c80e6"
		local MEL, MEL_SH = "#f3ebd3", "#e0d5b9"
		local STRIPE, STRIPE_DK = "#aebbd8", "#8f9cc0"
		local MOON_N = "#fff0a0"
		local MOON, MOON_DK = "#ffe28c", "#efc65e"
		local FACE = "#7a5426"
		local STAR_N, STAR_BLUE = "#fff7cc", "#bfe0ff"

		-- box spanning a -> b (own helper: CFrame.lookAt in Lune drops the
		-- vertical part of steep directions, so B:beam tilts wrongly)
		local function bar(bone, a, b, w, h, col, opts)
			local d = b - a
			local len = d.Magnitude
			local u = d.Unit
			local c = CFrame.new((a + b) / 2) * CFrame.Angles(0, math.atan2(-u.X, -u.Z), 0) * CFrame.Angles(math.asin(math.clamp(u.Y, -1, 1)), 0, 0)
			return B:block(bone, v(w, h, len), c, col, opts)
		end

		local seed = 7707
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end

		---------------------------------------------------------------- mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.5, 2.4), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, math.rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 6.6, DIRT_DK, 16, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.6, 4.6, DIRT, 10, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.4, 0.4, 2.8, DIRT_LT, 6, { DIRT_LT, DIRT }, 0.2)
		for _, g in { { 6.4, -2.9 }, { -5.8, 3.7 }, { 3.9, 5.6 }, { -6.7, -0.6 } } do
			B:block(soil, v(0.45, 0.9, 0.45), cf(g[1], 1.0, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.35, 0.6, 0.35), cf(g[1] + 0.35, 0.95, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end
		-- loose straw bits scattered over the tiers
		for _, h in { { 5.3, 0.8, 1.6, 30 }, { -5.0, 0.8, -2.6, -40 }, { 0.4, 0.8, -6.0, 70 }, { -1.9, 0.8, 5.5, 10 },
			{ -3.2, 1.4, 1.6, 55 }, { 1.0, 1.8, 2.2, 80 } } do
			B:block(soil, v(1.6, 0.22, 0.32), cf(h[1], h[2] + 0.12, h[3], 0, h[4], 0), HAY, S)
			B:block(soil, v(1.1, 0.2, 0.28), cf(h[1] + 0.2, h[2] + 0.13, h[3] + 0.25, 0, h[4] + 35, 0), (h[4] % 20 == 0) and HAY_DK or HAY_LT, S)
		end
		-- hay pads the big melons rest on
		local function pad(x, z, yaw, y)
			B:block(soil, v(3.2, 0.3, 2.4), cf(x, y + 0.15, z, 0, yaw, 0), HAY, S)
			B:block(soil, v(2.5, 0.34, 3.0), cf(x, y + 0.17, z, 0, yaw + 8, 0), HAY_DK, S)
		end
		do
			local a = math.rad(-20)
			pad(math.sin(a) * 4.3, -math.cos(a) * 4.3, 20, 1.25)
		end

		------------------------------------------------------- tepee stakes
		local Y0 = 1.8
		local crop = B:bone("Crop", "Root", v(0, Y0, 0))
		local APEX = v(0, 13.0, 0.2)
		local BASE_R = 3.6
		local stakeAngles = { 60, 180, 300 } -- degrees around Y (0 = front, -Z)
		local function polar(deg, r, y)
			local a = math.rad(deg)
			return v(math.sin(a) * r, y, -math.cos(a) * r)
		end
		for i, deg in stakeAngles do
			local foot = polar(deg, BASE_R, 1.0)
			local dir = (APEX - foot).Unit
			local top = APEX + dir * 1.5
			bar(crop, foot, top, 0.9, 0.9, (i == 2) and WOOD_DK or WOOD)
			-- a lighter tip where it pokes out above the lashing
			bar(crop, APEX + dir * 0.9, top + dir * 0.15, 0.98, 0.98, WOOD_LT)
		end
		-- straw twine lashing at the crossing
		B:block(crop, v(1.5, 0.45, 1.5), CFrame.new(APEX + v(0, -0.15, 0)) * ang(0, 20, 0), HAY)
		B:block(crop, v(1.3, 0.4, 1.3), CFrame.new(APEX + v(0, 0.35, 0)) * ang(0, 65, 0), HAY_DK)
		B:block(crop, v(0.3, 0.9, 0.3), CFrame.new(APEX + v(0.5, -0.75, -0.6)) * ang(0, 0, 12), HAY_LT)

		------------------------------------------------- spiral vines + leaves
		local function seg(a, b, w, col)
			bar(crop, a, b, w, w, col)
			B:block(crop, v(w + 0.12, w + 0.12, w + 0.12), CFrame.new(b) * ang(0, rnd(0, 90), 0), col)
		end
		local leaves = {}
		local function leafAt(p, s, col)
			local c = CFrame.new(p) * ang(rnd(-25, 25), rnd(0, 90), rnd(-25, 25))
			B:block(crop, v(s, s, s), c, col)
			table.insert(leaves, { cf = c, s = s })
		end
		-- cone radius at height y (vine hugs the stakes, slightly outside)
		local function coneR(y)
			return BASE_R * (1 - (y - 1.0) / (APEX.Y - 1.0)) + 0.55
		end
		local vinePts = {}
		local function vine(phase, colA, colB, leafCols)
			local prev
			local N = 11
			for i = 0, N do
				local t = i / N
				local y = Y0 + 0.3 + t * (APEX.Y - Y0 - 1.2)
				local deg = phase + t * 400
				local p = polar(deg, coneR(y), y)
				if prev then seg(prev, p, 0.85 - 0.3 * t, (i % 2 == 0) and colA or colB) end
				if i >= 2 and i <= 9 and i % 3 == 2 then
					-- a leaf cube sticking out of the vine, alternating sides
					local out = polar(deg + ((i % 2 == 0) and 18 or -18), coneR(y) + 0.9, y + 0.3)
					leafAt(out, 2.3 + rnd(-0.2, 0.2), leafCols[(i // 3) % #leafCols + 1])
				end
				table.insert(vinePts, { p = p, deg = deg, t = t })
				prev = p
			end
		end
		vine(10, VINE, VINE_DK, { LEAF, LEAF_DK, LEAF_LT })
		vine(190, VINE_LT, VINE, { LEAF_DK, LEAF_LT, LEAF_NT })
		-- root collar where the vines leave the soil
		B:block(crop, v(2.2, 0.6, 1.4), CFrame.new(polar(10, coneR(Y0), Y0 + 0.1)) * ang(0, -10, 0), VINE_DK)
		B:block(crop, v(2.2, 0.6, 1.4), CFrame.new(polar(190, coneR(Y0), Y0 + 0.1)) * ang(0, -190, 0), VINE_DK)

		-- the leafy cluster around the crossing
		leafAt(APEX + v(0, -1.2, 0.3), 3.8, LEAF)
		for i = 0, 4 do
			local p = polar(i * 72 + 20, 2.3, APEX.Y - 1.9 + rnd(-0.3, 0.3))
			leafAt(p, 2.7 + rnd(-0.2, 0.3), ({ LEAF_DK, LEAF_LT, LEAF_NT, LEAF, LEAF_DK })[i + 1])
		end
		leafAt(APEX + v(1.1, 0.4, 0.9), 2.0, LEAF_HI)

		-- tiny star speckles half-sunk into the leaf cubes (night-sky leaves)
		local specks = {}
		local faces = { v(0, 0, -1), v(1, 0, 0), v(-1, 0, 0), v(0, 1, 0), v(0, 0, 1) }
		for i, c in leaves do
			if i % 2 == 1 or c.s > 3.5 then
				local f = pick(faces)
				local u = v(rnd(-0.3, 0.3), rnd(-0.3, 0.3), rnd(-0.3, 0.3)) * c.s
				local lp = f * (c.s / 2) + v(f.X == 0 and u.X or 0, f.Y == 0 and u.Y or 0, f.Z == 0 and u.Z or 0)
				local p = B:block(crop, v(0.42, 0.42, 0.42), c.cf * CFrame.new(lp) * ang(0, 0, 45), (i % 3 == 0) and STAR_BLUE or STAR_N,
					{ mat = "Neon", name = "Speck" })
				table.insert(specks, p)
			end
		end

		----------------------------------------------------- moon melons
		local function melon(c, s)
			local H, L = s * 0.84, s * 1.24
			-- stepped oval body
			B:block(crop, v(s, H * 0.68, L * 0.88), c, MEL)
			B:block(crop, v(s * 0.74, H, L * 0.88), c, MEL)
			B:block(crop, v(s * 0.88, H * 0.86, L * 0.96), c, MEL_SH)
			B:block(crop, v(s * 0.6, H * 0.6, L), c, MEL)
			-- silver-blue stripes running the length over the top
			for _, x in { -0.21, 0.21 } do
				B:block(crop, v(0.2 * s, H + 0.06, L * 0.8), c * CFrame.new(x * s, 0, 0), x < 0 and STRIPE or STRIPE_DK)
			end
			B:block(crop, v(0.16 * s, H * 0.6 + 0.08, L * 0.92), c * CFrame.new(0, 0, 0), STRIPE)
			-- a softly glowing crescent moon on each flank: "(" in three steps
			for _, e in { -1, 1 } do
				local fx = e * (s / 2 + 0.02)
				for _, q in { { 0.15, 0.27, 0.3, 0.18 }, { -0.06, 0, 0.2, 0.48 }, { 0.15, -0.27, 0.3, 0.18 } } do
					B:block(crop, v(0.14, q[4] * s, q[3] * s), c * CFrame.new(fx, q[2] * H, q[1] * L * e), MOON_N, { mat = "Neon", name = "Crescent" })
				end
			end
			-- stem + little curl on top
			B:block(crop, v(0.32, 0.6, 0.32), c * CFrame.new(0, H / 2 + 0.25, -L * 0.3), VINE_DK)
			B:block(crop, v(0.64, 0.26, 0.26), c * CFrame.new(0.25, H / 2 + 0.55, -L * 0.3), VINE)
		end
		-- three big ones at the foot
		local function footMelon(deg, r, y, s, yaw)
			local p = polar(deg, r, y + s * 0.42 + 0.1)
			melon(CFrame.new(p) * ang(0, -deg + yaw, rnd(-4, 4)), s)
		end
		footMelon(-20, 4.3, 1.4, 3.7, 70)
		footMelon(115, 4.5, 1.0, 3.1, 100)
		footMelon(235, 4.4, 1.2, 2.7, 80)
		-- runners from the vine roots to the foot melons
		seg(polar(10, coneR(Y0), Y0 + 0.2), polar(-12, 3.2, 2.5), 0.5, VINE)
		seg(polar(190, coneR(Y0), Y0 + 0.2), polar(225, 3.2, 2.4), 0.5, VINE_DK)
		seg(polar(10, coneR(Y0), Y0 + 0.2), polar(105, 3.4, 2.1), 0.5, VINE_DK)

		-- three hanging off the vines, out on short stalks
		local function hang(deg, y, s)
			local base = polar(deg, coneR(y), y)
			local out = polar(deg, coneR(y) + 1.4, y - 0.4)
			seg(base, out, 0.38, VINE)
			seg(out, out + v(0, -0.7, 0), 0.34, VINE_DK)
			melon(CFrame.new(out + v(0, -0.7 - s * 0.42 - 0.1, 0)) * ang(0, -deg + 90 + rnd(-15, 15), rnd(-5, 5)), s)
		end
		hang(30, 8.6, 2.6)
		hang(160, 9.6, 2.4)
		hang(275, 7.8, 2.5)

		------------------------------------------------- crescent moon topper
		-- voxel crescent: inside the outer disc, outside the offset inner disc;
		-- rows merged into runs, the cell touching the inner disc glows.
		local moonC = CFrame.new(APEX + v(-0.3, 3.0, -0.2)) * ang(0, -15, -14)
		local cell = 0.55
		local RO, RI, IX, IY = 2.8, 2.15, 1.45, 0.25
		local moonParts = {}
		local function inOuter(x, y)
			return x * x + y * y <= RO * RO
		end
		local function inInner(x, y)
			return (x - IX) ^ 2 + (y - IY) ^ 2 <= RI * RI
		end
		for j = -5, 5 do
			local y = j * cell
			local runStart
			for i = -6, 6 do
				local x = i * cell
				local solid = inOuter(x, y) and not inInner(x, y)
				if solid and not runStart then runStart = i end
				local nextSolid = (i < 6) and inOuter((i + 1) * cell, y) and not inInner((i + 1) * cell, y)
				if solid and not nextSolid then
					local i0, i1 = runStart, i
					local touchesInner = inInner((i + 1) * cell, y) and (i - i0) >= 1
					if touchesInner then i1 = i - 1 end
					local n = i1 - i0 + 1
					local cx = (i0 + i1) / 2 * cell
					local p = B:block(crop, v(n * cell + 0.02, cell + 0.02, 1.3), moonC * CFrame.new(cx, y, 0), (j % 2 == 0) and MOON or MOON_DK)
					table.insert(moonParts, p)
					if touchesInner then
						B:block(crop, v(cell, cell, 1.0), moonC * CFrame.new(i * cell, y, 0), MOON_N, { mat = "Neon", name = "MoonRim" })
					end
					runStart = nil
				end
			end
		end
		-- sleepy face on the front of the thick part (closed eye + small smile)
		local fz = -0.67
		B:block(crop, v(0.7, 0.18, 0.1), moonC * CFrame.new(-1.75, 0.55, fz), FACE)
		B:block(crop, v(0.18, 0.18, 0.1), moonC * CFrame.new(-1.45, -0.45, fz), FACE)
		B:block(crop, v(0.55, 0.18, 0.1), moonC * CFrame.new(-1.75, -0.62, fz), FACE)
		B:block(crop, v(0.45, 0.28, 0.1), moonC * CFrame.new(-2.1, 0.05, fz), "#ffb08a")
		-- a curly vine tendril hooking the moon onto the stakes
		seg(APEX + v(0, 0.4, 0), APEX + v(-0.9, 1.2, -0.1), 0.38, VINE_LT)
		seg(APEX + v(-0.9, 1.2, -0.1), APEX + v(-1.9, 1.1, -0.2), 0.34, VINE)

		------------------------------------------------------- star crosses
		local stars = {}
		local function star(deg, r, y, s, glowCol)
			local a = math.rad(deg)
			local c = cf(math.sin(a) * r, y, -math.cos(a) * r, 0, -deg, rnd(-15, 15))
			local core = B:block(crop, v(0.6 * s, 0.6 * s, 0.5 * s), c, glowCol, { mat = "Neon", name = "Star" })
			B:block(crop, v(1.8 * s, 0.32 * s, 0.34 * s), c, MOON)
			B:block(crop, v(0.32 * s, 1.8 * s, 0.34 * s), c, MOON)
			table.insert(stars, core)
		end
		star(-60, 5.6, 14.6, 1.0, STAR_N)
		star(55, 5.2, 15.6, 0.85, STAR_BLUE)
		star(150, 5.8, 13.6, 0.9, STAR_N)
		star(240, 5.4, 15.2, 0.8, STAR_BLUE)

		---------------------------------------------------------------- bling
		B:emitter(moonParts[6], "glow", { name = "MoonGlow", color = "#fff0a8", rate = 2, size = 1.6 })
		B:emitter(stars[1], "sparkle", { name = "StarSparkle", color = { "#fff7cc", "#bfe0ff" }, rate = 3, size = 0.4 })
		B:emitter(stars[3], "sparkle", { name = "StarSparkle2", color = { "#bfe0ff", "#fff7cc" }, rate = 3, size = 0.4 })
		B:emitter(specks[1], "sparkle", { name = "LeafTwinkle", color = { "#fff7cc", "#c9b8ff" }, rate = 3, size = 0.35 })
		B:light(moonParts[6], { color = "#ffeaa8", brightness = 1.0, range = 14, name = "MoonLight" })
	end,
}
