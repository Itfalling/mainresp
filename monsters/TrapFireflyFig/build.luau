--!nocheck
-- Firefly Fig Tree (Flytrap Stage plant #7, Cosmic).
-- A deep bog-green fig tree in the Snapjaw Flytrap's greenhouse: a stepped
-- bog mound with moss pads, stones and a little lily-pad puddle; a chunky
-- grey-brown fig trunk with mossy patches and arching aerial roots; a big
-- dark-green crown of overlapping, rotated studded leaf cubes. Plump purple
-- stepped figs hang all over the crown and each one GLOWS at its tip like a
-- firefly's tail (tiny lime-yellow neon). A few little block fireflies hover
-- around the crown; lime/yellow firefly sparkles + one soft lime light.
-- Static prop: no motion.luau.
return {
	DisplayName = "Firefly Fig Tree",
	Rarity = "Cosmic",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (bog / greenhouse family)
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local MUD = "#2e1d12"
		local MOSS, MOSS_DK, MOSS_LT = "#6cb337", "#4f8f2a", "#8fd04a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local BOG, BOG_LT = "#2f6a50", "#6fb58a"
		local PAD, PAD_DK = "#3caa3c", "#2a8a33"
		local REED, CATTAIL = "#7f8f3a", "#5a3a1e"
		local BARK_DK, BARK, BARK_LT = "#4a3a2c", "#655140", "#7f6a55"
		local LEAF_DK, LEAF, LEAF_LT, LEAF_HI = "#1b5a2c", "#24703a", "#2f8744", "#41a04f"
		local FIG_DK, FIG, FIG_LT, FIG_HI = "#4d1d78", "#6d2fa0", "#8a45c2", "#b47ee4"
		local FIG_STEM = "#4e6a24"
		local GLOW = "#d6ff3a"
		local GLOW_Y = "#ffe95a"
		local FLY = "#2a2233"
		local WING = "#e8fbff"
		local NEON = { mat = "Neon" }

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
				local w, d = rnd(1.4, 2.2), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 5.8, DIRT_DK, 16, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.6, 3.9, DIRT, 11, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.4, 0.4, 2.4, DIRT_LT, 0, {}, 0)

		-- moss pads draped over the tier edges
		for _, m in { { -30, 5.7, 1.12, 2.2, MOSS }, { 55, 5.6, 1.1, 2.0, MOSS_DK }, { 120, 5.75, 1.1, 1.9, MOSS }, { 200, 5.6, 1.12, 2.1, MOSS_DK }, { 20, 3.8, 1.72, 1.6, MOSS_LT }, { 160, 3.85, 1.72, 1.5, MOSS } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], m[3], -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[4], 0.3, 1.3), c * ang(-12, 0, 0), m[5], S)
		end
		-- stones
		for _, s in { { 4.6, 1.0, -3.2, 0.9, 25, STONE }, { 5.3, 0.9, -2.2, 0.6, 10, STONE_LT }, { -5.0, 0.95, 2.6, 0.85, -20, STONE_DK }, { 2.4, 0.95, 5.2, 0.7, 40, STONE }, { -2.8, 1.75, 2.6, 0.6, 15, STONE_LT } } do
			B:block(soil, v(s[4] * 1.2, s[4], s[4]), cf(s[1], s[2], s[3], rnd(-10, 10), s[5], rnd(-10, 10)), s[6], S)
		end
		-- grass tufts
		for _, g in { { 5.6, 0.6 }, { -5.5, -1.4 }, { -1.8, 5.6 }, { 4.0, 4.3 }, { -4.2, -4.2 } } do
			B:block(soil, v(0.4, 0.9, 0.4), cf(g[1], 0.95, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.3, 0.6, 0.3), cf(g[1] + 0.3, 0.9, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end

		-- bog puddle sunk into the front-left of the middle tier, with lily pads + cattails
		local BC = v(-1.6, 1.42, -3.4)
		B:block(soil, v(3.0, 0.3, 1.7), CFrame.new(BC + v(0, -0.12, 0)) * ang(0, -10, 0), BOG, S)
		B:block(soil, v(1.8, 0.28, 2.4), CFrame.new(BC + v(0.1, -0.16, -0.05)) * ang(0, -10, 0), BOG, S)
		B:block(soil, v(1.0, 0.1, 0.35), CFrame.new(BC + v(0.5, 0.04, -0.3)) * ang(0, -10, 0), BOG_LT, S)
		B:block(soil, v(0.8, 0.45, 0.6), CFrame.new(BC + v(-1.6, 0, -0.4)) * ang(0, 20, 0), MUD, S)
		B:block(soil, v(0.7, 0.4, 0.6), CFrame.new(BC + v(1.6, 0, -0.5)) * ang(0, -15, 0), MUD, S)
		B:block(soil, v(0.9, 0.1, 0.9), CFrame.new(BC + v(-0.6, 0.06, -0.2)) * ang(0, 30, 0), PAD, S)
		B:block(soil, v(0.3, 0.12, 0.3), CFrame.new(BC + v(-0.35, 0.07, -0.45)) * ang(0, 30, 0), PAD_DK, S)
		B:block(soil, v(0.6, 0.1, 0.6), CFrame.new(BC + v(0.8, 0.06, 0.35)) * ang(0, -20, 0), PAD_DK, S)
		B:block(soil, v(0.2, 1.9, 0.2), CFrame.new(BC + v(-1.4, 0.95, 0.6)) * ang(0, 0, 8), REED, S)
		B:block(soil, v(0.35, 0.6, 0.35), CFrame.new(BC + v(-1.53, 1.75, 0.6)) * ang(0, 0, 8), CATTAIL, S)
		B:block(soil, v(0.2, 1.4, 0.2), CFrame.new(BC + v(-1.0, 0.7, 0.8)) * ang(-6, 0, -10), REED, S)

		---------------------------------------------------------------- trunk
		local Y0 = 1.8
		local crop = B:bone("Crop", "Root", v(0, Y0, 0))
		B:block(crop, v(3.4, 0.8, 3.4), cf(0, Y0 + 0.3, 0, 0, 10, 0), BARK_DK)
		B:block(crop, v(2.9, 1.2, 2.9), cf(0, Y0 + 1.2, 0, 0, 4, 0), BARK)
		B:block(crop, v(2.4, 2.6, 2.4), cf(0.05, Y0 + 3.0, 0, 0, 0, 0), BARK_LT)
		B:block(crop, v(2.1, 2.4, 2.1), cf(0.15, Y0 + 5.3, -0.05, 0, 8, 0), BARK)
		B:block(crop, v(1.8, 2.2, 1.8), cf(0.25, Y0 + 7.4, -0.1, 0, 16, 0), BARK_LT)
		-- bark notches + moss patches
		for _, n in { { 1.22, 2.6, 0.3, BARK_DK }, { -1.22, 3.6, -0.4, BARK_DK }, { 0.3, 4.8, -1.07, BARK_DK }, { -0.4, 5.8, 1.07, BARK_DK }, { 1.1, 6.4, 0.2, BARK_DK } } do
			local sx = math.abs(n[1]) > 0.9 and 0.3 or 0.7
			local sz = math.abs(n[3]) > 0.9 and 0.3 or 0.7
			B:block(crop, v(sx, 0.7, sz), cf(n[1], Y0 + n[2], n[3]), n[4])
		end
		B:block(crop, v(1.3, 0.9, 0.35), cf(-0.4, Y0 + 2.2, -1.25), MOSS)
		B:block(crop, v(0.35, 1.1, 1.2), cf(-1.25, Y0 + 2.6, 0.5), MOSS_DK)
		B:block(crop, v(0.9, 0.6, 0.3), cf(0.4, Y0 + 4.4, 1.1), MOSS)
		-- arching aerial roots (fig buttress roots) down into the mound
		for i, r in { { 35, 1.9 }, { 125, 2.1 }, { 215, 1.8 }, { 300, 2.2 } } do
			local a = rad(r[1])
			local dx, dz = math.sin(a), -math.cos(a)
			local top = v(dx * 1.0, Y0 + 3.4 + (i % 2) * 0.6, dz * 1.0)
			local knee = v(dx * 2.3, Y0 + 2.0, dz * 2.3)
			local foot = v(dx * (2.3 + r[2]), 0.9, dz * (2.3 + r[2]))
			B:bar(crop, top, knee, 0.75, 0.75, BARK)
			B:block(crop, v(0.85, 0.85, 0.85), CFrame.new(knee) * ang(0, r[1], 0), BARK_DK)
			B:bar(crop, knee, foot, 0.7, 0.7, BARK_DK)
			B:block(crop, v(1.0, 0.5, 1.0), CFrame.new(foot + v(0, -0.15, 0)) * ang(0, r[1], 0), BARK_DK)
		end
		-- branches into the crown
		local function branch(from, to, w)
			B:bar(crop, from, to, w, w, BARK)
			B:block(crop, v(w + 0.2, w + 0.2, w + 0.2), CFrame.new(from), BARK)
		end
		branch(v(0.5, Y0 + 6.6, 0), v(3.4, Y0 + 9.4, -0.6), 1.0)
		branch(v(-0.3, Y0 + 7.0, 0), v(-3.4, Y0 + 9.6, 0.8), 1.0)
		branch(v(0.2, Y0 + 7.6, 0.4), v(0.6, Y0 + 9.8, 3.2), 0.9)
		branch(v(0.2, Y0 + 7.8, -0.4), v(-0.6, Y0 + 10.0, -3.1), 0.9)

		---------------------------------------------------------------- crown
		local cubes = {}
		local function leaf(x, y, z, s, rx, ry, rz, col)
			local c = cf(x, Y0 + y, z, rx, ry, rz)
			B:block(crop, v(s, s, s), c, col)
			table.insert(cubes, { cf = c, s = s })
		end
		leaf(0.0, 11.4, 0.0, 5.6, 8, 20, 6, LEAF)
		leaf(-3.8, 10.4, 0.8, 4.6, -12, 35, 14, LEAF_DK)
		leaf(4.0, 10.6, -0.6, 4.6, 14, -25, -10, LEAF)
		leaf(0.6, 10.2, 3.7, 4.4, 18, 10, -12, LEAF_DK)
		leaf(-0.6, 10.3, -3.7, 4.4, -16, -15, 10, LEAF)
		leaf(-2.2, 13.2, -1.1, 4.3, 18, 35, -12, LEAF_LT)
		leaf(2.3, 13.1, 1.5, 4.3, -12, 15, 15, LEAF_LT)
		leaf(0.2, 14.6, 0.1, 3.4, 15, 25, 12, LEAF_HI)
		leaf(-4.5, 12.0, 2.9, 3.4, 20, -20, 25, LEAF)
		leaf(4.6, 12.3, 2.3, 3.5, -25, 30, -18, LEAF)
		leaf(3.3, 9.1, 2.9, 3.2, 12, 50, 8, LEAF_DK)
		leaf(-3.4, 9.2, -2.7, 3.2, -10, 20, -15, LEAF_DK)
		leaf(3.1, 12.6, -2.9, 3.5, 30, -35, 12, LEAF_LT)
		leaf(-5.2, 10.9, -1.4, 3.2, -20, 15, 30, LEAF)
		leaf(-1.4, 12.6, 3.6, 3.0, 25, 5, -20, LEAF_LT)

		-- figs: hanging stepped teardrops (narrow top, plump body, round-ish bottom)
		-- with a lime-yellow neon "firefly" glow at the tip
		local function buried(p, self, pad)
			for _, c in cubes do
				if c ~= self then
					local l = c.cf:PointToObjectSpace(p)
					local h = c.s / 2 - (pad or 0.25)
					if math.abs(l.X) < h and math.abs(l.Y) < h and math.abs(l.Z) < h then
						return true
					end
				end
			end
			return false
		end
		local placed, tips = {}, {}
		local function farEnough(p, d)
			for _, q in placed do
				if (p - q).Magnitude < (d or 1.9) then return false end
			end
			return true
		end
		local function fig(p, s, ry)
			-- p = attachment point (top of the neck); fig hangs below it
			local f = CFrame.new(p) * ang(rnd(-8, 8), ry, rnd(-8, 8))
			local n = #placed
			local body = (n % 3 == 0) and FIG_DK or FIG
			B:block(crop, v(0.22 * s, 0.7 * s, 0.22 * s), f * CFrame.new(0, 0.15 * s, 0), FIG_STEM)
			B:block(crop, v(0.6 * s, 0.55 * s, 0.6 * s), f * CFrame.new(0, -0.3 * s, 0), FIG_LT)
			B:block(crop, v(1.05 * s, 0.6 * s, 1.05 * s), f * CFrame.new(0, -0.8 * s, 0), body)
			B:block(crop, v(1.3 * s, 0.75 * s, 1.3 * s), f * CFrame.new(0, -1.4 * s, 0), body)
			B:block(crop, v(1.0 * s, 0.35 * s, 1.0 * s), f * CFrame.new(0, -1.9 * s, 0), FIG_DK)
			-- soft highlight on the front-left shoulder
			B:block(crop, v(0.35 * s, 0.4 * s, 0.12 * s), f * CFrame.new(-0.3 * s, -1.25 * s, -0.66 * s), FIG_HI)
			-- the firefly glow at the tip
			local g = B:block(crop, v(0.62 * s, 0.42 * s, 0.62 * s), f * CFrame.new(0, -2.2 * s, 0), (n % 2 == 0) and GLOW or GLOW_Y, { mat = "Neon", name = "FigGlow" .. (#tips + 1) })
			table.insert(tips, g)
			table.insert(placed, p)
		end

		-- 1) figs dangling from the underside of the crown
		local FACES = { v(1, 0, 0), v(-1, 0, 0), v(0, 0, 1), v(0, 0, -1), v(0, -1, 0) }
		local tries = 0
		while #placed < 7 and tries < 3000 do
			tries += 1
			local c = cubes[math.floor(rnd(1, #cubes + 0.999))]
			local h = c.s / 2
			local loc = v(rnd(-0.35, 0.35) * c.s, -h, rnd(-0.35, 0.35) * c.s)
			local p = c.cf:PointToWorldSpace(loc)
			local r = math.sqrt(p.X * p.X + p.Z * p.Z)
			if p.Y > Y0 + 7.0 and p.Y < Y0 + 10.0 and r > 2.6 and not buried(p + v(0, -0.6, 0), c, 0) and farEnough(p, 2.0) then
				fig(p + v(0, 0.2, 0), rnd(0, 1) > 0.5 and 1.0 or 0.88, rnd(0, 90))
			end
		end
		-- 2) figs half-sunk into the sides of the crown (neck in the leaves)
		tries = 0
		while #placed < 20 and tries < 4000 do
			tries += 1
			local c = cubes[math.floor(rnd(1, #cubes + 0.999))]
			local fdir = FACES[math.floor(rnd(1, 4.999))]
			local h = c.s / 2
			local t1, t2 = rnd(-0.3, 0.3) * c.s, rnd(-0.3, 0.3) * c.s
			local loc = fdir.X ~= 0 and v(fdir.X * (h + 0.2), t1, t2) or v(t1, t2, fdir.Z * (h + 0.2))
			local p = c.cf:PointToWorldSpace(loc)
			local out = (c.cf:VectorToWorldSpace(fdir))
			local hang = p + out * 0.35 + v(0, 0.4, 0)
			if p.Y > Y0 + 9.5 and p.Y < Y0 + 15.0 and not buried(hang + v(0, -1.3, 0), nil, 0.1) and farEnough(hang, 2.1) then
				fig(hang, rnd(0, 1) > 0.6 and 0.95 or 0.82, rnd(0, 90))
			end
		end

		-- a few bright young-leaf tufts poking out of the crown top (highlights)
		for _, t in { { 0.4, 16.5, 0.3, 1.7, 20 }, { -2.6, 15.2, -1.6, 1.4, 50 }, { 2.7, 15.0, 1.8, 1.5, -15 }, { 3.6, 14.2, -2.9, 1.3, 35 }, { -4.3, 13.7, 2.8, 1.3, 10 } } do
			B:block(crop, v(t[4], t[4], t[4]), cf(t[1], Y0 + t[3] * 0 + t[2], t[3], 12, t[5], -10), MOSS_LT)
		end

		-- little glow-cap mushrooms on the mound (purple caps, lime glowing dots)
		for i, m in { { 3.3, 1.8, -1.6, 1.0 }, { -3.4, 1.4, -0.8, 0.8 }, { 1.4, 1.8, 3.4, 0.9 }, { -4.6, 0.8, -3.0, 0.75 } } do
			local base = v(m[1], m[2], m[3])
			local k = m[4]
			local f = CFrame.new(base) * ang(rnd(-8, 8), rnd(0, 90), rnd(-8, 8))
			B:block(soil, v(0.35 * k, 0.9 * k, 0.35 * k), f * CFrame.new(0, 0.45 * k, 0), "#f2e6c8", S)
			B:block(soil, v(1.0 * k, 0.4 * k, 1.0 * k), f * CFrame.new(0, 1.0 * k, 0), FIG, S)
			B:block(soil, v(0.6 * k, 0.25 * k, 0.6 * k), f * CFrame.new(0, 1.3 * k, 0), FIG_LT, S)
			B:block(soil, v(0.22 * k, 0.1 * k, 0.22 * k), f * CFrame.new(0.2 * k, 1.44 * k, -0.15 * k), GLOW, { mat = "Neon", name = "Soil" })
		end

		---------------------------------------------------------------- fireflies
		-- little hovering block fireflies around the crown
		local flies = {}
		for i, q in { { 25, 7.6, 9.6 }, { 95, 7.4, 13.8 }, { 160, 7.8, 10.6 }, { 230, 7.2, 14.4 }, { 300, 7.7, 11.2 }, { 345, 6.9, 15.6 } } do
			local a = rad(q[1])
			local p = v(math.sin(a) * q[2], Y0 + q[3], -math.cos(a) * q[2])
			local f = CFrame.new(p) * ang(rnd(-15, 15), q[1] + 90, rnd(-10, 10))
			B:block(crop, v(0.45, 0.45, 0.75), f, FLY)
			local tail = B:block(crop, v(0.55, 0.55, 0.55), f * CFrame.new(0, -0.05, 0.6), (i % 2 == 0) and GLOW_Y or GLOW, { mat = "Neon", name = "FireflyTail" .. i })
			B:block(crop, v(0.7, 0.08, 0.38), f * CFrame.new(-0.45, 0.28, 0.0) * ang(0, 0, 20), WING, { tr = 0.35 })
			B:block(crop, v(0.7, 0.08, 0.38), f * CFrame.new(0.45, 0.28, 0.0) * ang(0, 0, -20), WING, { tr = 0.35 })
			table.insert(flies, tail)
		end

		---------------------------------------------------------------- vfx
		local swarm = B:block(crop, v(12, 7, 12), cf(0, Y0 + 11.5, 0), LEAF, { tr = 1, name = "FireflySwarm" })
		B:emitter(swarm, "sparkle", { name = "Fireflies", color = { GLOW, GLOW_Y }, rate = 7, size = { 0.15, 0.4, 0 }, speed = { 0.2, 0.7 }, life = { 1.5, 2.6 } })
		B:emitter(tips[1], "glow", { name = "FigGlowPuff", color = "#c8ff5a", rate = 2, size = 0.7 })
		B:emitter(tips[5] or tips[1], "sparkle", { name = "FigTwinkle", color = { "#ffffff", GLOW_Y }, rate = 3, size = 0.3 })
		local low = B:block(crop, v(9, 1, 9), cf(0, Y0 + 1.5, 0), LEAF, { tr = 1, name = "BogMotes" })
		B:emitter(low, "glow", { name = "BogMotes", color = { "#b6ff5a", "#fff07a" }, rate = 1.5, size = { 0.3, 0.6, 0.2 }, speed = { 0.2, 0.6 }, accel = { 0, 0.4, 0 } })
		B:light(tips[2] or tips[1], { color = "#d6ff6a", brightness = 1.2, range = 12, name = "FigLight" })
	end,
}
