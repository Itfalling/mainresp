--!nocheck
-- Willowberry Tree (Misty Swamp crop #5, Legendary).
-- A small weeping willow in the stud-plant style:
-- * stepped dark swamp-MUD mound (bone "Soil") with moss pads, a murky teal
--   puddle with lily pads + a tiny violet water-flower, reeds and cattails,
--   grey-teal stones and a fallen berry
-- * gnarled dark trunk with root flares, moss patches and a knot hole,
--   forking into arching branches
-- * a soft domed crown of big studded willow-green leaf cubes, from whose rim
--   long CURTAINS of stepped leaf strands weep down almost to the mud
-- * clusters of plump glossy TEAL berries hanging on stems between the
--   curtains (and peeking from the crown top)
-- Soft teal/cyan sparkle twinkles around the berries, a few drifting willow
-- leaves and one soft teal light. Static prop: no motion.luau.
return {
	DisplayName = "Willowberry Tree",
	Rarity = "Legendary",
	Element = "Nature",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Misty Swamp) -------------------------------------------
		local MUD_XD, MUD_DK, MUD, MUD_LT = "#3b2a1e", "#4c3626", "#5e4430", "#74563c"
		local MOSS_DK, MOSS, MOSS_LT = "#3e6b2e", "#558a3a", "#76ab4a"
		local WATER_DK, WATER, WATER_LT = "#276b63", "#35958a", "#86dccb"
		local PAD_DK, PAD, PAD_LT = "#3b7a3a", "#4f9a46", "#77bf5c"
		local STONE_DK, STONE, STONE_LT = "#56605e", "#6f7a77", "#8c9893"
		local REED, REED_DK, CATTAIL = "#7a8a3e", "#5d6e30", "#4a2f1e"
		local VIOLET, VIOLET_LT = "#9a6ad8", "#c9a6f2"
		local BARK_XD, BARK_DK, BARK, BARK_LT = "#2c221c", "#3d3028", "#504034", "#66523f"
		local LF_XD, LF_DK, LF, LF_MID, LF_LT, LF_TIP = "#2f5a34", "#3d7040", "#4f8a48", "#64a052", "#82b85e", "#a6cf72"
		local B_DK, B_MD, B_LT, B_HI = "#0e938c", "#22d6c6", "#7cf3e4", "#d2fff9"
		local STEM = "#3a4a26"

		local seed = 51551
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function pick(t)
			return t[math.floor(rnd() * #t) + 1]
		end
		local function pv(r, deg, y)
			local a = rad(deg)
			return v(math.sin(a) * r, y, -math.cos(a) * r)
		end

		------------------------------------------------------------------
		-- STEPPED SWAMP MUD MOUND (bone "Soil", parts named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function disc(y0, h, r, col)
			B:block(soil, v(2 * r, h, 1.15 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.15 * r, h - 0.02, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.04, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
		end
		local function edge(y0, h, r, n, cols, eh, wr, dr)
			for i = 0, n - 1 do
				local a = (i + jit(0.2)) / n * 360
				local w, d = wr[1] + rnd() * (wr[2] - wr[1]), dr[1] + rnd() * (dr[2] - dr[1])
				local hh = h + rnd() * eh - 0.05
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + hh / 2, -(r + jit(0.2)))
				B:block(soil, v(w, hh, d), p * ang(0, jit(9), 0), pick(cols), S)
			end
		end
		disc(0, 0.8, 6.3, MUD_XD)
		edge(0, 0.8, 6.35, 16, { MUD_XD, MUD_DK, MUD_XD }, 0.45, { 1.7, 2.5 }, { 1.3, 1.8 })
		disc(0.8, 0.7, 4.7, MUD_DK)
		edge(0.8, 0.7, 4.75, 12, { MUD_DK, MUD, MUD_DK }, 0.12, { 1.5, 2.2 }, { 1.2, 1.6 })
		disc(1.5, 0.5, 3.1, MUD)
		local TOP = 2.0

		-- moss pads draped over the tier edges (flat, slightly overhanging)
		for _, m in { { 30, 6.0, 0.8, 2.4, MOSS }, { 110, 5.9, 0.8, 2.0, MOSS_DK }, { 245, 6.1, 0.8, 2.6, MOSS }, { 300, 5.8, 0.8, 1.8, MOSS_LT }, { 75, 4.4, 1.5, 2.0, MOSS_LT }, { 190, 4.5, 1.5, 2.2, MOSS }, { 330, 2.8, 2.0, 1.6, MOSS_DK } } do
			local c = CFrame.new(pv(m[2], m[1], m[3] + 0.08)) * ang(0, -m[1] + jit(15), 0)
			B:block(soil, v(m[4], 0.25, m[4] * 0.75), c * ang(-5, 0, 0), m[5], S)
			B:block(soil, v(m[4] * 0.55, 0.22, 0.5), c * CFrame.new(0.1, -0.15, -m[4] * 0.38) * ang(-30, 0, 0), m[5], S)
		end

		-- murky puddle on the front-left (sunk into the middle tier)
		local PX, PZ = -2.7, -2.9
		do
			local c = cf(PX, 1.58, PZ, 0, 40, 0)
			B:block(soil, v(4.4, 0.14, 2.8), c, WATER, S)
			B:block(soil, v(3.0, 0.13, 3.8), c, WATER, S)
			B:block(soil, v(1.6, 0.16, 1.2), c * CFrame.new(0.4, 0.01, 0.3), WATER_DK, S)
			B:block(soil, v(1.8, 0.16, 0.25), c * CFrame.new(-0.3, 0.02, -0.9), WATER_LT, S)
			B:block(soil, v(0.9, 0.16, 0.22), c * CFrame.new(0.8, 0.02, 1.2), WATER_LT, S)
			-- mud lip
			for k = 0, 3 do
				local a = k * 90 + 15
				local q = c * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.05, -2.0)
				B:block(soil, v(1.6, 0.35, 0.6), q * ang(0, jit(12), 0), (k % 2 == 0) and MUD or MUD_LT, S)
			end
			-- lily pads
			local function lily(x, z, s, a, col)
				local l = cf(x, 1.68, z, 0, a, 0)
				B:block(soil, v(1.5 * s, 0.12, 1.05 * s), l, col, S)
				B:block(soil, v(1.05 * s, 0.11, 1.5 * s), l, col, S)
				B:block(soil, v(0.4 * s, 0.14, 0.6 * s), l * CFrame.new(0, 0.01, -0.55 * s), WATER, S)
				return l
			end
			local l1 = lily(PX - 0.6, PZ - 0.3, 1.0, 30, PAD)
			lily(PX + 0.8, PZ + 0.6, 0.75, -40, PAD_DK)
			lily(PX + 0.5, PZ - 1.1, 0.6, 70, PAD_LT)
			-- tiny violet water-flower
			B:block(soil, v(0.6, 0.22, 0.6), l1 * CFrame.new(0.15, 0.14, 0.2) * ang(0, 45, 0), VIOLET, S)
			B:block(soil, v(0.36, 0.25, 0.36), l1 * CFrame.new(0.15, 0.3, 0.2), VIOLET_LT, S)
		end

		-- reeds + cattails at the back-left and right
		for _, r in { { -4.6, 2.8, 4.2, 6, 0.8 }, { -3.9, 3.6, 3.3, -8, 0.8 }, { -5.2, 1.6, 2.8, 10, 0.8 }, { 4.9, -2.6, 3.6, -7, 0.8 }, { 5.4, -1.6, 2.6, 9, 0.8 } } do
			local base = r[5]
			local tip = v(r[1] - math.sin(rad(r[4])) * r[3], base + r[3], r[2])
			B:bar(soil, v(r[1], base - 0.1, r[2]), tip, 0.24, 0.24, REED, S)
			B:block(soil, v(0.42, 0.85, 0.42), CFrame.new(tip + v(0, 0.2, 0)) * ang(0, 0, r[4]), CATTAIL, S)
			B:block(soil, v(0.12, 0.45, 0.12), CFrame.new(tip + v(0, 0.8, 0)) * ang(0, 0, r[4]), REED_DK, S)
		end
		-- flat reed blades
		for _, g in { { -4.3, 3.4, 15 }, { 5.2, -2.1, -20 }, { 2.6, 5.5, 5 }, { -5.8, -0.5, -10 } } do
			B:block(soil, v(0.3, 1.6, 0.18), cf(g[1], 1.4, g[2], 0, g[3], 12), REED, S)
			B:block(soil, v(0.28, 1.2, 0.16), cf(g[1] + 0.3, 1.2, g[2] + 0.1, 0, g[3] + 30, -14), REED_DK, S)
		end
		-- grey-teal stones
		for _, s in { { 4.6, 1.0, 2.7, 1.1, 25, STONE }, { 5.4, 0.95, 1.5, 0.7, 10, STONE_LT }, { 2.6, 1.8, -2.5, 0.75, -20, STONE_DK }, { -1.2, 0.95, 5.4, 0.8, 40, STONE }, { -5.1, 0.9, -3.8, 0.6, 15, STONE_LT } } do
			B:block(soil, v(s[4] * 1.35, s[4], s[4] * 1.05), cf(s[1], s[2], s[3], jit(6), s[5], jit(6)), s[6], S)
		end
		B:block(soil, v(1.0, 0.25, 0.8), cf(4.6, 1.55, 2.7, 0, 40, 0), MOSS_LT, S)
		-- a fallen teal berry by the puddle, half sunk in the mud
		B:block(soil, v(0.85, 0.7, 0.85), cf(-0.6, 1.85, -3.7, 0, 30, 0), B_MD, S)
		B:block(soil, v(1.0, 0.35, 1.0), cf(-0.6, 1.62, -3.7, 0, 75, 0), B_DK, S)
		B:block(soil, v(0.45, 0.2, 0.45), cf(-0.6, 2.25, -3.7, 0, 30, 0), B_LT, S)

		------------------------------------------------------------------
		-- TRUNK + BRANCHES (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		local trunk = {
			v(0, TOP - 0.3, 0),
			v(0.45, 4.3, 0.2),
			v(-0.15, 6.6, -0.1),
			v(0.3, 8.8, 0.15),
			v(0, 10.6, 0),
		}
		for i = 1, #trunk - 1 do
			local w = 2.5 - (i - 1) * 0.3
			B:bar(crop, trunk[i], trunk[i + 1], w, w, (i % 2 == 1) and BARK or BARK_DK)
			B:block(crop, v(w + 0.25, 0.5, w + 0.25), CFrame.new(trunk[i + 1]) * ang(0, i * 25, 0), BARK_LT)
		end
		-- moss patches + knots + a dark knot hole
		B:block(crop, v(1.2, 1.6, 0.4), cf(-0.5, 5.0, -1.25, 0, 0, 6), MOSS)
		B:block(crop, v(0.8, 0.9, 0.42), cf(-0.6, 4.1, -1.3, 0, 0, -4), MOSS_LT)
		B:block(crop, v(0.45, 1.3, 1.2), cf(1.35, 7.4, 0.3, 0, 0, 0), MOSS_DK)
		B:block(crop, v(0.6, 1.0, 0.4), cf(0.7, 7.9, -1.0, 0, 0, 5), BARK_LT)
		B:block(crop, v(0.8, 1.0, 0.3), cf(0.35, 3.3, -1.4, 0, 0, 0), BARK_XD)
		B:block(crop, v(1.1, 0.25, 0.4), cf(0.35, 2.75, -1.35, 0, 0, 0), BARK_LT)
		B:block(crop, v(0.5, 0.9, 0.45), cf(-1.3, 9.2, 0.0, 0, 90, -4), BARK_LT)
		-- root flares onto the mud
		B:block(crop, v(3.2, 0.8, 3.2), cf(0, TOP + 0.2, 0, 0, 20, 0), BARK_DK)
		for k = 0, 4 do
			local a = k * 72 + 35
			B:bar(crop, pv(0.9, a, TOP + 1.0), pv(2.5, a + 8, TOP - 0.1), 0.95, 0.75, BARK)
			B:bar(crop, pv(2.3, a + 8, TOP + 0.05), pv(3.2, a + 15, TOP - 0.35), 0.65, 0.5, BARK_DK)
		end
		B:block(crop, v(1.0, 0.3, 0.8), CFrame.new(pv(2.4, 107, TOP + 0.3)) * ang(0, -107, 0), MOSS_LT)

		-- arching branches out to the crown rim
		local FORK = trunk[#trunk]
		local CY = 15.0 -- crown base
		local arms = {}
		for k = 0, 5 do
			local a = k * 60 + 15
			local m = pv(2.6, a, 13.2 + jit(0.3))
			local t = pv(4.9, a + 10, CY + 0.2)
			B:bar(crop, FORK + v(0, -0.5, 0), m, 1.05, 1.05, (k % 2 == 0) and BARK or BARK_DK)
			B:block(crop, v(1.25, 1.25, 1.25), CFrame.new(m) * ang(0, -a, 0), BARK_DK)
			B:bar(crop, m, t, 0.8, 0.8, BARK_LT)
			table.insert(arms, { m = m, t = t, a = a })
		end
		B:bar(crop, FORK, v(0.2, CY + 2.0, -0.1), 1.3, 1.3, BARK_DK)

		------------------------------------------------------------------
		-- DOMED CROWN
		------------------------------------------------------------------
		local function leaf(p, s, sy, yaw, tilt, col)
			return B:block(crop, v(s, sy, s), CFrame.new(p) * ang(0, yaw, 0) * ang(tilt, 0, jit(8)), col)
		end
		-- rim ring: drooping outward (the shoulder the curtains fall from)
		local RIMN = 13
		local RIM_R = 6.1
		for i = 0, RIMN - 1 do
			local a = i * 360 / RIMN + jit(4)
			leaf(pv(RIM_R + jit(0.25), a, CY + 0.3 + jit(0.2)), 3.0 + rnd() * 0.4, 1.9, -a + jit(10), -20 + jit(5), pick({ LF_DK, LF, LF }))
		end
		-- underside shade so the bottom view looks dense
		for i = 0, 6 do
			local a = i * 360 / 7 + 10
			leaf(pv(3.9, a, CY - 0.4), 3.4, 0.8, -a, 0, LF_XD)
		end
		-- middle ring
		for i = 0, 8 do
			local a = i * 40 + 20 + jit(5)
			leaf(pv(4.2 + jit(0.3), a, CY + 1.7 + jit(0.2)), 3.4 + rnd() * 0.4, 2.4, -a + jit(15), -12 + jit(4), pick({ LF, LF_MID, LF }))
		end
		-- upper ring
		for i = 0, 5 do
			local a = i * 60 + 5 + jit(6)
			leaf(pv(2.3 + jit(0.2), a, CY + 3.1 + jit(0.15)), 3.2 + rnd() * 0.3, 2.3, -a + jit(20), -8 + jit(3), pick({ LF_MID, LF_LT, LF_MID }))
		end
		-- crown top
		leaf(v(0.1, CY + 4.2, 0.0), 3.2, 2.2, 30, 0, LF_LT)
		B:block(crop, v(1.8, 1.0, 1.8), cf(-0.2, CY + 5.5, 0.2, jit(10), 15, jit(10)), LF_TIP)
		-- lighter leaf cubes tumbling on the dome (chunky highlights)
		for i = 0, 5 do
			local a = i * 60 + 35
			local s = 1.7 + rnd() * 0.4
			B:block(crop, v(s, s * 0.7, s), CFrame.new(pv(3.6 + jit(0.4), a, CY + 3.0 + jit(0.2))) * ang(jit(15), -a + jit(30), jit(15)), pick({ LF_LT, LF_TIP }))
		end

		------------------------------------------------------------------
		-- WEEPING CURTAINS: stepped leaf strands falling from the rim
		------------------------------------------------------------------
		local function strand(a, r, y0, nseg, outStep, w, cols)
			local p = pv(r, a, y0)
			local out = pv(1, a, 0) -- unit outward (y = 0)
			local tan = pv(1, a + 90, 0)
			for j = 1, nseg do
				local h = 1.9 - (j - 1) * 0.1
				local col = cols[math.min(j, #cols)]
				local zz = ((j % 2) * 2 - 1) * 0.12
				local c = CFrame.new(p + v(0, -h / 2, 0) + tan * zz) * ang(0, -a + jit(8), 0) * ang(jit(4), 0, jit(6))
				B:block(crop, v(w - (j - 1) * 0.08, h, 0.75), c, col)
				p = p + v(0, -h + 0.25, 0) + out * outStep
			end
			-- leaf tip
			B:block(crop, v(0.6, 0.6, 0.6), CFrame.new(p + v(0, 0.0, 0)) * ang(45, -a, 45), LF_TIP)
		end
		-- outer curtain (14 strands, every other gap holds a berry bunch)
		local OUTN = 14
		local CUR_R = RIM_R + 1.1
		for i = 0, OUTN - 1 do
			local a = i * 360 / OUTN + jit(2)
			local n = 5 + math.floor(rnd() * 2.4) -- 5..7 segments
			strand(a, CUR_R, CY + 0.6, n, 0.13, 1.45, { LF_DK, LF, LF_MID, LF, LF_MID, LF_LT, LF_TIP })
		end
		-- inner curtain behind the empty gaps (darker, shorter, gives depth)
		for i = 0, OUTN / 2 - 1 do
			local a = (2 * i + 1.5) * 360 / OUTN + jit(3)
			strand(a, 5.0, CY - 0.2, 3, 0.08, 1.3, { LF_XD, LF_DK, LF })
		end

		------------------------------------------------------------------
		-- TEAL WILLOWBERRIES
		------------------------------------------------------------------
		local glints = {}
		local function berry(c, s, glint)
			B:block(crop, v(1.0 * s, 1.0 * s, 1.0 * s), c, B_MD)
			B:block(crop, v(1.22 * s, 0.6 * s, 1.22 * s), c * CFrame.new(0, -0.08 * s, 0) * ang(0, 45, 0), B_DK)
			B:block(crop, v(0.6 * s, 0.3 * s, 0.6 * s), c * CFrame.new(0, 0.55 * s, 0), B_LT)
			if glint then
				table.insert(glints, B:block(crop, v(0.26 * s, 0.26 * s, 0.1 * s), c * CFrame.new(-0.25 * s, 0.25 * s, -0.66 * s), B_HI, { mat = "Neon", name = "BerryGlint" }))
			end
		end
		local function cluster(a, r, ytop, len, s)
			local top = pv(r, a, ytop)
			local knot = top + v(jit(0.2), -len, jit(0.2))
			B:bar(crop, top, knot, 0.24, 0.24, STEM)
			-- two little willow leaves at the knot
			B:block(crop, v(1.2, 0.16, 0.45), CFrame.new(knot + v(0, 0.35, 0)) * ang(0, -a + 40, -30) * CFrame.new(0.5, 0, 0), LF_MID)
			B:block(crop, v(1.0, 0.16, 0.4), CFrame.new(knot + v(0, 0.2, 0)) * ang(0, -a + 220, -30) * CFrame.new(0.45, 0, 0), LF)
			local F = CFrame.new(knot) * ang(0, -a + jit(20), 0)
			-- three berries: front-low, left, right (triangle cluster)
			berry(F * CFrame.new(0, -1.05 * s, -0.35 * s) * ang(jit(10), 20, jit(10)), s, true)
			berry(F * CFrame.new(-0.62 * s, -0.55 * s, 0.35 * s) * ang(jit(10), 50, jit(10)), s * 0.85, false)
			berry(F * CFrame.new(0.62 * s, -0.5 * s, 0.3 * s) * ang(jit(10), 10, jit(10)), s * 0.9, false)
		end
		-- in every other curtain gap, hanging out of the crown rim
		for i = 0, OUTN / 2 - 1 do
			local a = (2 * i + 0.5) * 360 / OUTN
			cluster(a, CUR_R - 0.2, CY + 0.2, 3.8 + (i % 3) * 0.8, 1.42)
		end
		-- berries peeking from the crown (readable from above)
		for _, m in { { 70, 4.6, CY + 2.9 }, { 200, 4.5, CY + 2.9 }, { 320, 4.7, CY + 2.8 }, { 140, 2.2, CY + 4.3 }, { 260, 6.3, CY + 1.6 }, { 15, 6.4, CY + 1.6 } } do
			local F = CFrame.new(pv(m[2], m[1], m[3])) * ang(0, -m[1], 0) * ang(-10, 25, 8)
			berry(F, 1.0, false)
		end

		-- little violet willow blossoms dotting the crown (swamp-magic accent)
		for _, m in { { 105, 5.6, CY + 2.0 }, { 235, 5.5, CY + 2.0 }, { 345, 3.3, CY + 3.6 }, { 170, 3.4, CY + 3.6 }, { 40, 6.9, CY + 0.9 } } do
			local F = CFrame.new(pv(m[2], m[1], m[3])) * ang(0, -m[1] + 20, 0) * ang(-15, 0, 0)
			B:block(crop, v(0.9, 0.35, 0.9), F, VIOLET)
			B:block(crop, v(0.45, 0.3, 0.45), F * CFrame.new(0, 0.2, 0) * ang(0, 45, 0), VIOLET_LT)
		end

		------------------------------------------------------------------
		-- VFX: soft teal sparkle twinkles, drifting willow leaves, soft light
		------------------------------------------------------------------
		local sparkZone = B:block(crop, v(13, 7, 13), cf(0, CY - 3.5, 0), B_MD, { tr = 1, name = "SparkZone" })
		B:emitter(sparkZone, "sparkle", { name = "BerrySparkles", color = { "#d8fff8", B_HI, "#7ff0ff" }, rate = 7, size = { 0.12, 0.45, 0 }, life = { 1.2, 2.2 }, speed = { 0.1, 0.4 }, accel = { 0, 0.3, 0 }, light = 0.9 })
		B:emitter(glints[1], "sparkle", { name = "BerryTwinkle", color = { "#ffffff", B_HI }, rate = 2.5, size = { 0.2, 0.55, 0 }, life = { 0.6, 1.0 }, speed = { 0, 0.15 }, light = 1 })
		local leafZone = B:block(crop, v(14, 1, 14), cf(0, CY - 1.0, 0), LF, { tr = 1, name = "LeafZone" })
		B:emitter(leafZone, "leaf", { name = "WillowLeaves", color = { LF_LT, LF_TIP, LF_MID }, rate = 0.9, size = { 0.35, 0.35, 0.25 }, life = { 3.5, 5.0 }, speed = { 0.2, 0.6 }, accel = { 0.3, -1.0, 0 }, dir = "Bottom" })
		B:light(sparkZone, { name = "BerryLight", color = "#6ff2dc", brightness = 0.9, range = 14 })
	end,
}
