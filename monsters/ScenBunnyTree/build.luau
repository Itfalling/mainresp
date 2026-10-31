--!nocheck
-- Pink Party Tree (Bunny Meadow scenery, ~18 studs). A cotton-candy party tree
-- for the Bunny Meadow: a curvy dark trunk with a gold party collar carrying
-- a stacked, cloud-like hot-pink canopy, wrapped in a string of tiny lights.
-- * trunk: stepped octagon root flare, two leaning bar segments in the
--   velvet-plum bark tones with light / dark bark strips, a gold collar band
--   with light studs, two branches into the side puffs, flat roots
-- * canopy: a wide lower puff, a middle puff, a small top puff and two side
--   puffs (plus-shaped tiers: magenta shadow underneath, hot pink, light pink,
--   a pale pink cap) with tilted pink leaf cubes breaking up the outline
-- * string lights: a dark wire swagged around the lower puff with eight tiny
--   neon bulbs (cyan / yellow / lime) under dark sockets -- the only glow
-- * grounding: fallen pink petals, grass tufts and a pebble
-- Scenery filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Pink Party Tree",
	Rarity = "Scenery",
	Filler = true,
	Element = "Bunny Meadow",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		-- Bunny Meadow palette (BunnyVelvetPlum / DecorBunnySpeaker / DecorBunnySign)
		local PK_HI, PK_LT, PK, PK_DK, PK_SH = "#ffc2ea", "#ff86d4", "#ff3fb4", "#c41f86", "#93155f"
		local BARK_DK, BARK, BARK_LT = "#4f2c1e", "#653a26", "#7c4a30"
		local GOLD_LT, GOLD, GOLD_DK = "#ffe27a", "#ffc62e", "#d9961a"
		local WIRE = "#26222e"
		local N_CYAN, N_YELLOW, N_GREEN = "#4fe6ff", "#fff36a", "#8dff5a"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local STONE = "#8d8a9c"

		local seed = 11
		local function rnd()
			seed = (seed * 1103515245 + 12345) % 2147483648
			return seed / 2147483648
		end
		local ANG = { -20, -10, 0, 10, 20 }
		local function pick() return ANG[1 + math.floor(rnd() * #ANG)] end

		------------------------------------------------------------ trunk
		B:block(R, v(3.4, 0.8, 3.4), cf(0, 0.4, 0), BARK_DK)
		B:block(R, v(2.9, 0.78, 2.9), cf(0, 0.4, 0, 0, 45, 0), BARK_DK)
		B:block(R, v(2.6, 0.8, 2.6), cf(0, 1.1, 0), BARK)
		B:block(R, v(2.2, 0.78, 2.2), cf(0, 1.1, 0, 0, 45, 0), BARK_DK)
		local A, Bm, C = v(0, 1.0, 0), v(0.7, 5.0, 0.25), v(-0.15, 9.4, -0.1)
		B:bar(R, A, Bm, 2.0, 2.0, BARK)
		B:bar(R, Bm, C, 1.8, 1.8, BARK)
		B:block(R, v(2.1, 0.9, 2.1), cf(Bm.X, Bm.Y, Bm.Z, 0, 45, 0), BARK_DK)
		-- bark strips (light on the sunny front-left, dark grooves)
		B:bar(R, A + v(-0.6, 0.6, -0.95), Bm + v(-0.55, -0.4, -0.85), 0.4, 0.2, BARK_LT, { up = v(0, 0, -1) })
		B:bar(R, Bm + v(-0.55, 0.5, -0.85), C + v(-0.5, -0.6, -0.8), 0.4, 0.2, BARK_LT, { up = v(0, 0, -1) })
		B:bar(R, A + v(0.55, 0.6, -0.97), Bm + v(0.5, -0.4, -0.88), 0.25, 0.2, BARK_DK, { up = v(0, 0, -1) })
		B:bar(R, A + v(1.0, 0.6, 0.3), Bm + v(0.95, -0.4, 0.3), 0.2, 0.3, BARK_DK)
		-- gold party collar
		B:block(R, v(2.4, 0.5, 2.4), cf(0.25, 2.6, 0.08), GOLD)
		B:block(R, v(2.5, 0.14, 2.5), cf(0.25, 2.3, 0.08), GOLD_DK)
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			B:block(R, v(0.4, 0.35, 0.4), cf(0.25 + c[1] * 1.15, 2.65, 0.08 + c[2] * 1.15), GOLD_LT)
		end
		-- flat roots
		for i, r in { { 30, 3.4 }, { 120, 3.0 }, { 200, 3.3 }, { 290, 2.9 } } do
			local a = math.rad(r[1])
			local dx, dz = math.cos(a), math.sin(a)
			B:bar(R, v(dx * 1.2, 0.5, dz * 1.2), v(dx * r[2], 0.35, dz * r[2]), 0.9, 0.7, (i % 2 == 0) and BARK or BARK_DK)
		end
		-- branches into the side puffs
		B:bar(R, v(0.2, 7.2, 0.1), v(3.7, 9.6, 1.4), 1.0, 1.0, BARK)
		B:bar(R, v(0.0, 7.8, 0.0), v(-3.5, 10.2, -1.5), 1.0, 1.0, BARK)

		------------------------------------------------------------ canopy
		local function tier(x, y0, y1, z, w, col, rot)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(R, v(w, h, w * 0.72), cf(x, y, z, 0, rot, 0), col)
			B:block(R, v(w * 0.72, h, w), cf(x, y, z, 0, rot, 0), col)
		end
		local function puff(x, yb, z, w, h, rot)
			tier(x, yb, yb + h * 0.2, z, w * 0.7, PK_SH, rot)
			tier(x, yb + h * 0.17, yb + h * 0.5, z, w * 0.95, PK_DK, rot)
			tier(x, yb + h * 0.47, yb + h * 0.82, z, w, PK, rot)
			tier(x, yb + h * 0.79, yb + h, z, w * 0.74, PK_LT, rot)
			B:block(R, v(w * 0.4, 0.3, w * 0.4), cf(x, yb + h + 0.1, z, 0, rot + 45, 0), PK_HI)
		end
		local LOW = { 0, 8.6, 0, 9.6, 4.6, 0 }
		puff(LOW[1], LOW[2], LOW[3], LOW[4], LOW[5], LOW[6])
		puff(0.4, 12.4, 0.2, 7.2, 3.8, 0)
		puff(-0.2, 15.4, -0.2, 4.6, 2.9, 0)
		puff(4.1, 9.3, 1.5, 4.0, 3.2, 20)
		puff(-3.9, 9.9, -1.7, 3.8, 3.1, -15)

		local function leaf(x, y, z, s, col, cap)
			local c = CFrame.new(x, y, z) * CFrame.Angles(math.rad(pick()), math.rad(pick() + 45), math.rad(pick()))
			B:block(R, v(s, s, s), c, col)
			B:block(R, v(s * 0.7, 0.2, s * 0.7), c * CFrame.new(0, s / 2 + 0.07, 0), cap)
		end
		local function ring(cx, cy, cz, rad, n, s, off, col, cap)
			for i = 1, n do
				local a = math.rad(off + (i - 1) * 360 / n + rnd() * 12)
				leaf(cx + math.cos(a) * rad, cy + (rnd() - 0.5) * 0.6, cz + math.sin(a) * rad, s * (0.85 + rnd() * 0.3), col, cap)
			end
		end
		ring(0.4, 14.6, 0.2, 3.5, 6, 2.0, 20, PK, PK_LT)
		ring(-0.2, 17.0, -0.2, 2.0, 3, 1.6, 60, PK_LT, PK_HI)
		ring(0, 11.9, 0, 4.4, 7, 2.1, 5, PK, PK_LT)
		leaf(5.4, 11.3, 2.2, 1.8, PK, PK_LT)
		leaf(-5.2, 11.9, -2.4, 1.7, PK, PK_LT)
		leaf(3.0, 12.0, 3.1, 1.6, PK_LT, PK_HI)

		------------------------------------------------------------ string lights
		-- dark wire swagged between the octagon corners of the lower puff's
		-- widest tier, a tiny neon bulb hanging at the low point of every swag
		local W = LOW[4]
		local WY = LOW[2] + LOW[5] * 0.78 -- wire height at the corners
		local o = 0.18
		local hw, hn = W / 2 + o, W * 0.36 + o
		local verts = {
			v(hw, 0, -hn), v(hw, 0, hn), v(hn, 0, hw), v(-hn, 0, hw),
			v(-hw, 0, hn), v(-hw, 0, -hn), v(-hn, 0, -hw), v(hn, 0, -hw),
		}
		local bulbCols = { N_CYAN, N_YELLOW, N_GREEN }
		for i = 1, #verts do
			local a = verts[i] + v(LOW[1], WY, LOW[3])
			local b = verts[i % #verts + 1] + v(LOW[1], WY, LOW[3])
			local len = (b - a).Magnitude
			local m = (a + b) / 2 - v(0, math.min(1.1, 0.25 + len * 0.18), 0)
			B:bar(R, a, m, 0.12, 0.12, WIRE)
			B:bar(R, m, b, 0.12, 0.12, WIRE)
			B:block(R, v(0.26, 0.2, 0.26), cf(m.X, m.Y - 0.12, m.Z), WIRE)
			B:block(R, v(0.34, 0.42, 0.34), cf(m.X, m.Y - 0.42, m.Z, 0, 45, 0), bulbCols[(i - 1) % 3 + 1], { mat = "Neon", name = "Bulb" .. i })
		end

		------------------------------------------------------------ grounding
		local petals = { { 2.6, -2.4, 20 }, { -2.9, -1.2, -30 }, { 0.9, 3.1, 50 }, { -1.8, 2.7, 10 }, { 3.4, 1.0, -60 }, { -0.6, -3.4, 35 } }
		for i, p in petals do
			B:block(R, v(0.5, 0.08, 0.5), cf(p[1], 0.04, p[2], 0, p[3], 0), (i % 2 == 0) and PK_LT or PK)
		end
		local function tuft(x, z, h, ry)
			local b = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(ry), 0)
			B:block(R, v(0.42, h, 0.42), b * CFrame.new(0, h / 2, 0), GRASS)
			B:block(R, v(0.36, h * 0.75, 0.36), b * CFrame.new(0.34, h * 0.36, 0.05) * CFrame.Angles(0, 0, math.rad(-20)), GRASS_DK)
			B:block(R, v(0.36, h * 0.65, 0.36), b * CFrame.new(-0.32, h * 0.32, -0.05) * CFrame.Angles(0, 0, math.rad(22)), GRASS)
		end
		tuft(2.4, -1.6, 0.9, 20)
		tuft(-2.5, 1.9, 0.8, -40)
		tuft(-1.6, -2.6, 0.7, 60)
		B:block(R, v(0.7, 0.28, 0.55), cf(2.0, 0.14, 2.4, 0, 25, 0), STONE)
	end,
}
