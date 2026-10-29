--!nocheck
-- Boombox Melon Vine (Bunny Stage plant #6, Mythic).
-- The party's sound system grows on a vine! A wide stepped dirt mound, a
-- thick double vine twisting up out of a chunky brown root collar, side
-- runners crawling over the mound and a huge crown of overlapping, rotated
-- studded leaf cubes in three greens. The melons are little boomboxes:
-- charcoal-black bodies striped with cyan grille bands (a thin neon cyan
-- band in the middle) and a speaker cone on each end. Two big ones rest on
-- the mound, more hang from curly tendrils under the crown, and chunky
-- music-note cubes float around it in pink, cyan and gold.
-- Static prop: no motion.luau.
return {
	DisplayName = "Boombox Melon Vine",
	Rarity = "Mythic",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local BARK_DK, BARK = "#4f2c1e", "#653a26"
		local VINE_DK, VINE, VINE_LT = "#1f6b2c", "#2d8c39", "#45a846"
		local LEAF_DK, LEAF, LEAF_LT, LEAF_HI = "#23863a", "#33a845", "#4fc94f", "#74dd5a"
		local MEL, MEL_DK = "#1c1f29", "#12141b"
		local GRILLE, CONE, CONE_RIM = "#1fb8d6", "#30343f", "#4a5060"
		local CYAN_NEON = "#62f4ff"
		local PINK, PINK_NEON, GOLD, GOLD_NEON = "#ff3fae", "#ff7ad0", "#ffc62e", "#ffe27a"

		local seed = 6606
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
			-- stepped "pixel circle": cross + inner square, then chunky edge blocks
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.4, 2.3), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, math.rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 6.2, DIRT_DK, 18, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.6, 4.2, DIRT, 12, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.4, 0.4, 2.6, DIRT_LT, 6, { DIRT_LT, DIRT }, 0.2)
		for _, c in { { 6.8, 0.35, 1.6, 20 }, { -6.6, 0.3, -2.2, -15 }, { 1.4, 0.3, 6.9, 35 }, { -2.0, 0.3, -6.9, 10 } } do
			B:block(soil, v(1.1, 0.6, 0.9), cf(c[1], c[2], c[3], 0, c[4], 0), DIRT_DK2, S)
		end
		for _, g in { { 6.0, -2.8 }, { -5.4, 3.6 }, { 3.6, 5.2 }, { -3.0, -5.8 }, { -6.2, 0.2 }, { 5.2, 3.0 } } do
			B:block(soil, v(0.45, 0.9, 0.45), cf(g[1], 1.0, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.35, 0.6, 0.35), cf(g[1] + 0.35, 0.95, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end

		----------------------------------------------------------- root collar
		local Y0 = 1.8
		local crop = B:bone("Crop", "Root", v(0, Y0, 0))
		B:block(crop, v(3.4, 0.8, 3.4), cf(0, Y0 + 0.3, 0), BARK_DK)
		for i = 0, 3 do
			B:block(crop, v(1.1, 0.7, 1.7), cf(0, Y0 + 0.2, 0, 0, i * 90 + 45, 0) * CFrame.new(0, 0, -2.0) * ang(-10, 0, 0), BARK_DK)
		end
		B:block(crop, v(2.8, 0.8, 2.8), cf(0, Y0 + 1.1, 0, 0, 12, 0), BARK)

		------------------------------------------------- twisted double vine
		local function seg(a, b, w, col)
			B:beam(crop, a, b, w, w, col)
			B:block(crop, v(w + 0.15, w + 0.15, w + 0.15), CFrame.new(b) * ang(0, rnd(0, 90), 0), col)
		end
		local function helix(phase, col, colAlt)
			local prev
			local N = 9
			for i = 0, N do
				local t = i / N
				local a = math.rad(phase + t * 300)
				local r = 0.75 - 0.15 * t
				local p = v(math.cos(a) * r, Y0 + 1.2 + t * 7.4, math.sin(a) * r)
				if prev then seg(prev, p, 1.3 - 0.35 * t, (i % 2 == 0) and col or colAlt) end
				prev = p
			end
		end
		helix(0, VINE, VINE_DK)
		helix(180, VINE_LT, VINE)

		-- a few leaf cubes sprouting from the vine
		local cubes = {}
		local function leaf(x, y, z, s, rx, ry, rz, col)
			local c = cf(x, Y0 + y, z, rx, ry, rz)
			B:block(crop, v(s, s, s), c, col)
			table.insert(cubes, { cf = c, s = s })
		end
		leaf(1.4, 4.0, -0.6, 1.8, 20, 30, -25, LEAF)
		leaf(-1.3, 5.4, 0.5, 1.7, -15, 50, 20, LEAF_LT)
		leaf(0.3, 6.6, -1.3, 1.6, 25, 10, 15, LEAF)

		------------------------------------------------------------- crown
		-- wide umbrella crown: a big centre cube, an inner ring, an outer drooping ring, a stepped top
		leaf(0, 10.2, 0, 5.4, 8, 20, 6, LEAF)
		local inner = { LEAF_DK, LEAF, LEAF_LT, LEAF_DK, LEAF, LEAF_LT }
		for i = 0, 5 do
			local a = math.rad(i * 60 + 10)
			leaf(math.sin(a) * 3.8, 9.7 + rnd(-0.3, 0.3), -math.cos(a) * 3.8, 4.3 + rnd(-0.2, 0.3), rnd(-18, 18), i * 60 + rnd(-20, 20), rnd(-18, 18), inner[i + 1])
		end
		for i = 0, 6 do
			local a = math.rad(i * 360 / 7 + 35)
			leaf(math.sin(a) * 6.0, 8.9 + rnd(-0.3, 0.3), -math.cos(a) * 6.0, 3.1 + rnd(-0.2, 0.3), rnd(-25, 25), rnd(0, 90), rnd(-25, 25), (i % 2 == 0) and LEAF_DK or LEAF)
		end
		for i = 0, 2 do
			local a = math.rad(i * 120 + 50)
			leaf(math.sin(a) * 1.9, 12.0, -math.cos(a) * 1.9, 3.6, rnd(-15, 15), rnd(0, 90), rnd(-15, 15), LEAF_LT)
		end
		leaf(0.2, 13.1, -0.1, 2.8, 12, 25, 10, LEAF_HI)

		-------------------------------------------------- boombox melons
		local melons = {}
		local glows = {}
		local function melon(c, s)
			local L, H = s * 1.2, s * 0.9
			B:block(crop, v(s, H, L), c, MEL)
			-- grille bands around the long axis: cyan / neon / cyan
			for k, z in { -0.3, 0, 0.3 } do
				local neon = k == 2
				local g = B:block(crop, v(s + 0.1, H + 0.1, neon and 0.22 or 0.34), c * CFrame.new(0, 0, z * L),
					neon and CYAN_NEON or GRILLE, neon and { mat = "Neon", name = "Grille" .. (#glows + 1) } or nil)
				if neon then table.insert(glows, g) end
			end
			-- thin dark grille slots between the bands
			for _, z in { -0.15, 0.15 } do
				B:block(crop, v(s + 0.04, H + 0.04, 0.14), c * CFrame.new(0, 0, z * L), MEL_DK)
			end
			-- a speaker cone on each end
			for _, e in { -1, 1 } do
				B:block(crop, v(s * 0.66, H * 0.66, 0.16), c * CFrame.new(0, 0, e * (L / 2 + 0.06)), CONE_RIM)
				B:block(crop, v(s * 0.4, H * 0.4, 0.16), c * CFrame.new(0, 0, e * (L / 2 + 0.14)), CONE)
				B:block(crop, v(s * 0.14, H * 0.14, 0.1), c * CFrame.new(0, 0, e * (L / 2 + 0.24)), CYAN_NEON, { mat = "Neon", name = "Cone" })
			end
			-- curly stem on top
			B:block(crop, v(0.3, 0.6, 0.3), c * CFrame.new(0, H / 2 + 0.25, 0), VINE_DK)
			B:block(crop, v(0.6, 0.25, 0.25), c * CFrame.new(0.25, H / 2 + 0.55, 0), VINE)
			table.insert(melons, c)
		end

		-- two big ones resting on the mound, fed by runners from the vine base
		local function runner(pts, w)
			for i = 1, #pts - 1 do
				seg(pts[i], pts[i + 1], w, (i % 2 == 0) and VINE_DK or VINE)
			end
		end
		melon(cf(-3.9, 0.8 + 1.4, -2.3, 0, 35, -4), 3.0)
		runner({ v(-1.2, Y0 + 0.6, -0.6), v(-2.4, 1.6, -1.6), v(-3.4, 1.7, -2.6) }, 0.6)
		melon(cf(3.6, 0.8 + 1.25, 2.6, 0, -50, 3), 2.7)
		runner({ v(1.2, Y0 + 0.6, 0.6), v(2.3, 1.5, 1.7), v(3.2, 1.6, 2.7) }, 0.6)
		-- a small one in front
		melon(cf(1.6, 1.4 + 0.95, -3.4, 0, -15, 0), 2.0)
		runner({ v(0.4, Y0 + 0.6, -1.2), v(1.0, 1.9, -2.4), v(1.5, 2.5, -3.2) }, 0.5)

		-- hanging melons on curly tendrils under the crown
		local function hang(x, z, top, len, s, yaw)
			local mid = v(x + 0.4, Y0 + top - len * 0.45, z - 0.3)
			local bot = v(x, Y0 + top - len, z)
			seg(v(x - 0.2, Y0 + top, z + 0.2), mid, 0.4, VINE)
			seg(mid, bot, 0.38, VINE_DK)
			melon(cf(x, Y0 + top - len - s * 0.45 - 0.2, z, 0, yaw, rnd(-6, 6)), s)
		end
		for i, h in { { 35, 2.4 }, { 35 + 360 / 7 * 2, 2.3 }, { 35 + 360 / 7 * 4, 2.4 }, { 35 + 360 / 7 * 6, 2.2 } } do
			local a = math.rad(h[1])
			local r = 5.7
			hang(math.sin(a) * r, -math.cos(a) * r, 7.6, 1.3, h[2], -h[1] + 15)
		end

		-- little leaf-green tendril curls poking out of the crown
		for _, t in { { 6.4, 11.0, -1.4 }, { -6.2, 11.4, 1.0 }, { 0.8, 11.6, 6.2 }, { -1.4, 12.2, -6.0 } } do
			local base = v(t[1] * 0.8, Y0 + t[2] - 0.6, t[3] * 0.8)
			local tip = v(t[1], Y0 + t[2] + 0.8, t[3])
			seg(base, tip, 0.35, VINE_LT)
			B:block(crop, v(0.35, 0.8, 0.35), CFrame.new(tip + v(0, -0.4, 0)) * CFrame.new((tip - base).Unit * 0.4), VINE_LT)
		end

		------------------------------------------------ floating music notes
		local notes = {}
		local function note(p, yaw, col, glow, double)
			local c = CFrame.new(p) * ang(0, yaw, rnd(-12, 12))
			local head = B:block(crop, v(1.15, 0.85, 0.55), c, glow, { mat = "Neon", name = "NoteHead" .. (#notes + 1) })
			B:block(crop, v(0.3, 2.2, 0.3), c * CFrame.new(0.45, 1.25, 0), col)
			if double then
				B:block(crop, v(1.15, 0.85, 0.55), c * CFrame.new(1.65, 0.3, 0), glow, { mat = "Neon", name = "NoteHead" })
				B:block(crop, v(0.3, 2.2, 0.3), c * CFrame.new(2.1, 1.55, 0), col)
				B:block(crop, v(1.95, 0.45, 0.32), c * CFrame.new(1.27, 2.5, 0) * ang(0, 0, 9), col)
			else
				B:block(crop, v(0.75, 0.38, 0.28), c * CFrame.new(0.8, 2.15, 0) * ang(0, 0, -25), col)
				B:block(crop, v(0.6, 0.34, 0.28), c * CFrame.new(0.9, 1.65, 0) * ang(0, 0, -25), col)
			end
			table.insert(notes, head)
		end
		local function noteAt(deg, r, y, yaw, col, glow, double)
			local a = math.rad(deg)
			note(v(math.sin(a) * r, Y0 + y, -math.cos(a) * r), yaw, col, glow, double)
		end
		noteAt(-60, 7.4, 11.8, 30, PINK, PINK_NEON, false)
		noteAt(20, 6.8, 12.4, -10, GRILLE, CYAN_NEON, true)
		noteAt(85, 7.6, 11.0, -70, GOLD, GOLD_NEON, false)
		noteAt(150, 7.0, 12.2, 200, PINK, PINK_NEON, true)
		noteAt(215, 7.4, 11.4, 130, GRILLE, CYAN_NEON, false)
		noteAt(270, 7.2, 12.6, 80, GOLD, GOLD_NEON, true)

		---------------------------------------------------------------- bling
		B:emitter(notes[1], "sparkle", { name = "NoteSparkle", color = { "#ff9ee0", "#7ff6ff" }, rate = 4, size = 0.4 })
		B:emitter(notes[3], "sparkle", { name = "NoteSparkle2", color = { "#7ff6ff", "#ffe27a" }, rate = 4, size = 0.4 })
		B:emitter(glows[1], "glow", { name = "BassGlow", color = "#62f4ff", rate = 2, size = 0.8 })
		B:emitter(glows[4] or glows[2], "sparkle", { name = "BeatSparkle", color = "#9ff8ff", rate = 3, size = 0.35 })
		B:light(glows[1], { color = "#62f4ff", brightness = 1.0, range = 12, name = "BassLight" })
	end,
}
