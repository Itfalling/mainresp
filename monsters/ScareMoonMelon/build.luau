--!nocheck
-- Harvest Moon Melon (Scarecrow Stage crop #7, Secret).
-- A melon patch under its own little moon. A stepped dirt mound strewn
-- with hay, low indigo / purple leaf cubes sprawling over it and three
-- pale-cream moon melons (silver-blue stripes, a softly glowing crescent on
-- each flank) resting on hay pads. From the back a thick twisted teal vine
-- rises and curls forward like a shepherd's crook under a hood of big
-- rotated studded leaf cubes speckled with tiny star dots; a chunky pale
-- gold crescent moon with a sleepy smile hangs from its tip like a lamp,
-- two more melons dangle from the hood and star crosses twinkle around.
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
		local VINE_DK, VINE, VINE_LT = "#22524a", "#2f6c5f", "#468a70"
		local LEAF_NT, LEAF_DK, LEAF, LEAF_LT, LEAF_HI = "#2c2368", "#3f2c8c", "#5a3cb0", "#7656cf", "#9c80e6"
		local MEL, MEL_SH = "#f3ebd3", "#e0d5b9"
		local STRIPE, STRIPE_DK = "#aebbd8", "#8f9cc0"
		local MOON_N = "#fff0a0"
		local MOON, MOON_DK = "#ffe28c", "#efc65e"
		local FACE, BLUSH = "#7a5426", "#ffb08a"
		local STAR_N, STAR_BLUE = "#fff7cc", "#bfe0ff"

		-- exact span box (B:bar; B:beam mis-aims non-level spans in Lune)
		local function bar(bone, a, b, w, h, col, opts)
			return B:bar(bone, a, b, w, h, col, opts)
		end

		local seed = 7707
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function polar(deg, r, y)
			local a = math.rad(deg)
			return v(math.sin(a) * r, y, -math.cos(a) * r)
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
		tier(0, 0.8, 7.0, DIRT_DK, 15, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.6, 5.0, DIRT, 10, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.4, 0.4, 3.0, DIRT_LT, 6, { DIRT_LT, DIRT }, 0.2)
		for _, g in { { 6.6, -3.0 }, { -6.2, 3.7 }, { 4.1, 5.8 }, { -7.0, -1.2 } } do
			B:block(soil, v(0.45, 0.9, 0.45), cf(g[1], 1.0, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.35, 0.6, 0.35), cf(g[1] + 0.35, 0.95, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end
		-- loose straw bits scattered over the tiers
		for _, h in { { 5.6, 0.8, 1.4, 30 }, { -5.4, 0.8, -2.4, -40 }, { 1.8, 0.8, -6.3, 70 }, { -2.0, 0.8, 5.8, 10 },
			{ 3.6, 1.4, 2.6, 55 }, { -2.4, 1.8, 0.8, 80 } } do
			B:block(soil, v(1.6, 0.22, 0.32), cf(h[1], h[2] + 0.12, h[3], 0, h[4], 0), HAY, S)
			B:block(soil, v(1.1, 0.2, 0.28), cf(h[1] + 0.2, h[2] + 0.13, h[3] + 0.25, 0, h[4] + 35, 0), (h[4] % 20 == 0) and HAY_DK or HAY_LT, S)
		end
		-- hay pads the big melons rest on
		local function pad(p, yaw, w)
			B:block(soil, v(w, 0.3, w * 0.75), CFrame.new(p + v(0, 0.15, 0)) * ang(0, yaw, 0), HAY, S)
			B:block(soil, v(w * 0.78, 0.34, w * 0.95), CFrame.new(p + v(0, 0.17, 0)) * ang(0, yaw + 8, 0), HAY_DK, S)
		end

		local Y0 = 1.8
		local crop = B:bone("Crop", "Root", v(0, Y0, 0))
		local function seg(a, b, w, col)
			bar(crop, a, b, w, w, col)
			B:block(crop, v(w + 0.12, w + 0.12, w + 0.12), CFrame.new(b) * ang(0, rnd(0, 90), 0), col)
		end
		local leaves = {}
		local function leafAt(p, s, col, tilt)
			tilt = tilt or 22
			local c = CFrame.new(p) * ang(rnd(-tilt, tilt), rnd(0, 90), rnd(-tilt, tilt))
			B:block(crop, v(s, s, s), c, col)
			table.insert(leaves, { cf = c, s = s })
		end

		----------------------------------------------------- moon melons
		local function melon(c, s)
			local H, L = s * 0.84, s * 1.24
			B:block(crop, v(s, H * 0.68, L * 0.88), c, MEL)
			B:block(crop, v(s * 0.74, H, L * 0.88), c, MEL)
			B:block(crop, v(s * 0.88, H * 0.86, L * 0.96), c, MEL_SH)
			B:block(crop, v(s * 0.6, H * 0.6, L), c, MEL)
			-- silver-blue stripes running the length over the top
			for _, x in { -0.21, 0.21 } do
				B:block(crop, v(0.2 * s, H + 0.06, L * 0.8), c * CFrame.new(x * s, 0, 0), x < 0 and STRIPE or STRIPE_DK)
			end
			B:block(crop, v(0.16 * s, H * 0.6 + 0.08, L * 0.92), c, STRIPE)
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
			return (c * CFrame.new(0, H / 2 + 0.3, -L * 0.3)).Position
		end
		-- resting on the ground; the flank (local X) turned toward the viewer
		local function groundMelon(deg, r, yGround, s, yaw, withPad)
			local base = polar(deg, r, yGround)
			if withPad then
				pad(base, -deg + yaw + 90, s * 1.0)
				base = base + v(0, 0.3, 0)
			end
			return melon(CFrame.new(base + v(0, s * 0.42 + 0.05, 0)) * ang(0, -deg + yaw, rnd(-3, 3)), s)
		end

		------------------------------------------------- the shepherd's-crook vine
		local path = {
			v(0.0, Y0 + 0.2, 2.2), v(0.35, 4.6, 2.3), v(-0.25, 7.2, 2.1), v(0.25, 9.8, 1.8),
			v(0.0, 12.4, 1.0), v(0.0, 14.1, -0.4), v(0.0, 14.5, -2.0), v(0.0, 13.9, -3.4),
		}
		for i = 1, #path - 1 do
			local t = (i - 1) / (#path - 2)
			seg(path[i], path[i + 1], 1.35 - 0.6 * t, (i % 2 == 0) and VINE or VINE_DK)
		end
		-- a second, thinner strand twisting around the main one
		do
			local prev
			for i = 1, #path do
				local side = (i % 2 == 0) and 1 or -1
				local p = path[i] + v(side * 0.55, 0.2, (i % 3 == 0) and 0.4 or -0.3)
				if prev then seg(prev, p, 0.55, VINE_LT) end
				prev = p
			end
		end
		-- root collar where the vine leaves the soil
		B:block(crop, v(2.8, 0.7, 2.6), CFrame.new(path[1] + v(0, 0.1, 0)) * ang(0, 15, 0), VINE_DK)
		B:block(crop, v(1.2, 0.6, 1.8), CFrame.new(path[1] + v(1.4, -0.05, 0.3)) * ang(0, 40, -8), VINE_DK)
		B:block(crop, v(1.2, 0.6, 1.8), CFrame.new(path[1] + v(-1.3, -0.05, 0.5)) * ang(0, -30, 8), VINE_DK)

		-- leaves along the rising stem
		leafAt(v(1.6, 5.6, 2.6), 2.4, LEAF)
		leafAt(v(-1.6, 8.0, 2.2), 2.3, LEAF_LT)
		leafAt(v(1.4, 10.6, 2.0), 2.2, LEAF_DK)

		-- the leafy hood over the crook
		leafAt(v(0.0, 15.6, -0.8), 3.8, LEAF)
		leafAt(v(2.3, 14.6, -0.5), 3.3, LEAF_DK)
		leafAt(v(-2.3, 14.7, -0.2), 3.3, LEAF_LT)
		leafAt(v(0.2, 14.3, 1.7), 3.2, LEAF_NT)
		leafAt(v(2.4, 13.4, 1.6), 2.6, LEAF)
		leafAt(v(-2.3, 13.3, 1.8), 2.6, LEAF_DK)
		leafAt(v(3.8, 13.6, -1.4), 2.4, LEAF_LT)
		leafAt(v(-3.8, 13.8, -1.0), 2.4, LEAF)
		leafAt(v(0.3, 15.4, -3.0), 2.4, LEAF_DK)
		leafAt(v(1.5, 16.3, 0.4), 2.2, LEAF_HI)
		leafAt(v(-1.4, 16.1, -1.3), 2.0, LEAF_LT)

		-- low patch leaves sprawling over the mound
		for k, q in { { 40, 5.0 }, { 150, 4.6 }, { 200, 5.2 }, { 255, 4.8 }, { 315, 4.7 }, { 95, 3.8 } } do
			local yb = (q[2] > 4.9) and 1.0 or 1.5
			local s = rnd(2.2, 2.8)
			leafAt(polar(q[1], q[2], yb + s * 0.25), s, ({ LEAF_DK, LEAF, LEAF_NT, LEAF_LT, LEAF, LEAF_DK })[k], 14)
		end

		-- ground melons: the big one in front, two more around the patch
		local m1 = groundMelon(-15, 4.5, 1.4, 3.9, 90, true)
		groundMelon(120, 4.9, 0.8, 3.0, 100, true)
		groundMelon(235, 4.7, 0.8, 2.6, 80, false)
		groundMelon(60, 3.2, 1.8, 1.5, 70, false) -- a little young one
		-- runners from the root collar
		seg(path[1] + v(0.6, 0, -0.6), v(1.2, 2.5, -1.4), 0.5, VINE)
		seg(v(1.2, 2.5, -1.4), m1 + v(0.4, -0.2, 0.3), 0.42, VINE_DK)
		seg(path[1] + v(1.0, 0, 0), v(3.3, 2.0, 1.6), 0.45, VINE_DK)
		seg(path[1] + v(-1.0, 0, 0), v(-3.0, 2.0, 1.4), 0.45, VINE)

		-- two melons dangling from the hood on curly stalks
		local function dangle(top, s, yaw)
			local mid = top + v(0.3, -0.9, -0.2)
			local bot = top + v(0, -1.8, 0)
			seg(top, mid, 0.34, VINE)
			seg(mid, bot, 0.32, VINE_DK)
			melon(CFrame.new(bot + v(0, -s * 0.42 - 0.05, 0)) * ang(0, yaw, rnd(-5, 5)), s)
		end
		dangle(v(4.1, 12.5, -0.6), 2.4, 70)
		dangle(v(-4.0, 12.6, 0.6), 2.2, 110)

		-- tiny star speckles half-sunk into the bigger leaf cubes
		local specks = {}
		local faces = { v(0, 0, -1), v(1, 0, 0), v(-1, 0, 0), v(0, 1, 0) }
		for i, c in leaves do
			if c.s >= 2.3 then
				local f = pick(faces)
				local u = v(rnd(-0.3, 0.3), rnd(-0.3, 0.3), rnd(-0.3, 0.3)) * c.s
				local lp = f * (c.s / 2) + v(f.X == 0 and u.X or 0, f.Y == 0 and u.Y or 0, f.Z == 0 and u.Z or 0)
				local p = B:block(crop, v(0.45, 0.45, 0.45), c.cf * CFrame.new(lp) * ang(0, 0, 45), (i % 3 == 0) and STAR_BLUE or STAR_N,
					{ mat = "Neon", name = "Speck" })
				table.insert(specks, p)
			end
		end

		------------------------------------------- the crescent moon "lamp"
		-- voxel crescent: inside the outer disc, outside the offset inner disc;
		-- rows merged into runs, the cell touching the inner disc glows.
		local tip = path[#path]
		local moonC = CFrame.new(tip + v(0.6, -4.3, -0.1)) * ang(0, 0, -8)
		local cell = 0.5
		local RO, RI, IX, IY = 3.3, 4.2, 3.0, 0.0
		local moonParts = {}
		local function inOuter(x, y)
			return x * x + y * y <= RO * RO
		end
		local function inInner(x, y)
			return (x - IX) ^ 2 + (y - IY) ^ 2 <= RI * RI
		end
		local function solidAt(i, j)
			local x, y = i * cell, j * cell
			return inOuter(x, y) and not inInner(x, y)
		end
		for j = -6, 6 do
			local y = j * cell
			local runStart
			for i = -7, 7 do
				local solid = solidAt(i, j)
				if solid and not runStart then runStart = i end
				if solid and not (i < 7 and solidAt(i + 1, j)) then
					local i0, i1 = runStart, i
					local touchesInner = inInner((i + 1) * cell, y) and (i - i0) >= 1
					if touchesInner then i1 = i - 1 end
					local n = i1 - i0 + 1
					local cx = (i0 + i1) / 2 * cell
					local p = B:block(crop, v(n * cell + 0.02, cell + 0.02, 1.4), moonC * CFrame.new(cx, y, 0), (j % 2 == 0) and MOON or MOON_DK)
					table.insert(moonParts, p)
					if touchesInner then
						B:block(crop, v(cell, cell, 1.1), moonC * CFrame.new(i * cell, y, 0), MOON_N, { mat = "Neon", name = "MoonRim" })
					end
					runStart = nil
				end
			end
		end
		-- sleepy face on the thick part, front and back (closed eye, smile, blush)
		for _, fz in { -0.72, 0.72 } do
			B:block(crop, v(0.8, 0.22, 0.1), moonC * CFrame.new(-2.25, 0.55, fz), FACE)
			B:block(crop, v(0.22, 0.22, 0.1), moonC * CFrame.new(-1.95, -0.35, fz), FACE)
			B:block(crop, v(0.22, 0.22, 0.1), moonC * CFrame.new(-2.55, -0.35, fz), FACE)
			B:block(crop, v(0.5, 0.22, 0.1), moonC * CFrame.new(-2.25, -0.55, fz), FACE)
			B:block(crop, v(0.4, 0.26, 0.1), moonC * CFrame.new(-2.55, 0.05, fz), BLUSH)
		end
		-- the vine thread the moon hangs from (to the top of the crescent's back)
		local hook = (moonC * CFrame.new(-0.3, RO - 0.4, 0)).Position
		seg(tip, tip + v(0.2, -0.4, 0), 0.4, VINE)
		seg(tip + v(0.2, -0.4, 0), hook, 0.3, VINE_LT)

		------------------------------------------------------- star crosses
		local stars = {}
		local function star(p, s, glowCol, roll)
			local c = CFrame.new(p) * ang(0, 0, roll)
			local core = B:block(crop, v(0.6 * s, 0.6 * s, 0.5 * s), c, glowCol, { mat = "Neon", name = "Star" })
			B:block(crop, v(1.8 * s, 0.32 * s, 0.34 * s), c, MOON)
			B:block(crop, v(0.32 * s, 1.8 * s, 0.34 * s), c, MOON)
			table.insert(stars, core)
		end
		star(v(-3.4, 10.6, -3.6), 1.1, STAR_N, 10)
		star(v(4.6, 9.0, -3.0), 0.9, STAR_BLUE, -12)
		star(v(-5.6, 16.0, 0.6), 1.0, STAR_N, 20)
		star(v(5.2, 16.8, 1.2), 0.8, STAR_BLUE, -5)

		---------------------------------------------------------------- bling
		local glowPart = moonParts[math.ceil(#moonParts / 2)]
		B:emitter(glowPart, "glow", { name = "MoonGlow", color = "#fff0a8", rate = 2, size = 1.8 })
		B:emitter(stars[1], "sparkle", { name = "StarSparkle", color = { "#fff7cc", "#bfe0ff" }, rate = 3, size = 0.4 })
		B:emitter(stars[3], "sparkle", { name = "StarSparkle2", color = { "#bfe0ff", "#fff7cc" }, rate = 3, size = 0.4 })
		B:emitter(specks[1], "sparkle", { name = "LeafTwinkle", color = { "#fff7cc", "#c9b8ff" }, rate = 3, size = 0.35 })
		B:light(glowPart, { color = "#ffeaa8", brightness = 1.0, range = 14, name = "MoonLight" })
	end,
}
