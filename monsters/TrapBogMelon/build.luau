--!nocheck
-- Mossy Bog Melon (Flytrap Stage crop #4, Epic).
-- A melon patch on a stepped bog mound. A gnarled, moss-capped bog-root
-- arch rises over the back of the patch with a melon vine winding up it
-- and a crown of big studded leaf cubes on top; two melons dangle from the
-- arch. On the ground: a big hero melon in front plus three more, all
-- WHOLE, with mossy green skin, dark stripes, lime spots (a few softly
-- glowing) and a moss tuft + curly stem on top. A bog puddle with lily
-- pads and cattails sits at the front; fireflies drift around the arch.
-- Static prop: no motion.luau.
return {
	DisplayName = "Mossy Bog Melon",
	Rarity = "Epic",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ---------------------------------------------------------
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local MUD = "#2e1d12"
		local MOSS, MOSS_DK, MOSS_LT = "#6cb337", "#4f8f2a", "#8fd14a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local BOG, BOG_LT = "#2f6a50", "#6fb58a"
		local REED, CATTAIL = "#7f8f3a", "#5a3a1e"
		local WOOD_DK, WOOD, WOOD_LT = "#4a2f1c", "#64422a", "#7d5636"
		local VINE_DK, VINE = "#2c6e2a", "#3f8f34"
		local LEAF_DK, LEAF, LEAF_LT, LEAF_TOP = "#1f6e2a", "#3caa3c", "#6cc94a", "#58c447"
		local MEL_DK, MEL, MEL_LT = "#2f6a24", "#4c9534", "#5fae3c"
		local STRIPE = "#24541d"
		local SPOT, SPOT_N = "#b6e65a", "#a6ff4a"
		local LILY, LILY_DK = "#5cb83a", "#3f8f2a"
		local FLOWER = "#ff8cb4"

		local seed = 4404
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function polar(deg, r, y)
			local a = rad(deg)
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
				local w, d = rnd(1.6, 2.4), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 6.3, DIRT_DK, 14, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.6, 4.5, DIRT, 9, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.4, 0.4, 2.8, DIRT_LT, 0, {}, 0)

		-- moss pads draped over the tier edges
		for _, m in { { 120, 6.2, 1.12, 2.2, MOSS }, { 200, 6.1, 1.1, 2.0, MOSS_DK }, { 300, 6.2, 1.12, 2.1, MOSS }, { 250, 4.4, 1.7, 1.6, MOSS_LT } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], m[3], -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[4], 0.3, 1.3), c * ang(-12, 0, 0), m[5], S)
		end
		-- stones
		for _, s in { { -5.4, 0.95, -1.8, 0.9, 25, STONE }, { -5.0, 0.85, -0.6, 0.6, 10, STONE_LT }, { 4.6, 0.95, 3.4, 0.8, -20, STONE_DK } } do
			B:block(soil, v(s[4] * 1.2, s[4], s[4]), cf(s[1], s[2], s[3], rnd(-10, 10), s[5], rnd(-10, 10)), s[6], S)
		end
		-- tiny grass tufts
		for _, g in { { -6.2, 1.8 }, { 1.0, 6.3 }, { 6.0, -0.4 } } do
			B:block(soil, v(0.45, 0.9, 0.45), cf(g[1], 0.95, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.35, 0.6, 0.35), cf(g[1] + 0.35, 0.9, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end

		-- bog puddle sunk into the front-right of the mound
		local BC = v(3.4, 1.42, -3.4)
		B:block(soil, v(3.2, 0.3, 2.0), CFrame.new(BC) * ang(0, 30, 0), BOG, S)
		B:block(soil, v(2.0, 0.28, 3.0), CFrame.new(BC + v(0.05, -0.02, 0)) * ang(0, 30, 0), BOG, S)
		B:block(soil, v(1.2, 0.1, 0.35), CFrame.new(BC + v(0.5, 0.15, -0.3)) * ang(0, 30, 0), BOG_LT, S)
		B:block(soil, v(0.9, 0.5, 0.7), CFrame.new(BC + v(1.6, 0.05, 0.4)) * ang(0, 15, 0), MUD, S)
		-- lily pads (one with a little pink flower)
		B:block(soil, v(1.1, 0.12, 1.1), CFrame.new(BC + v(-0.5, 0.18, 0.2)) * ang(0, 25, 0), LILY, S)
		B:block(soil, v(0.8, 0.12, 0.8), CFrame.new(BC + v(0.7, 0.18, -0.6)) * ang(0, -10, 0), LILY_DK, S)
		B:block(soil, v(0.4, 0.35, 0.4), CFrame.new(BC + v(-0.5, 0.38, 0.2)) * ang(0, 45, 0), FLOWER, S)
		-- cattails
		B:block(soil, v(0.22, 2.2, 0.22), CFrame.new(BC + v(1.3, 1.1, 0.9)) * ang(0, 0, -6), REED, S)
		B:block(soil, v(0.4, 0.75, 0.4), CFrame.new(BC + v(1.42, 2.1, 0.9)) * ang(0, 0, -6), CATTAIL, S)
		B:block(soil, v(0.22, 1.6, 0.22), CFrame.new(BC + v(1.75, 0.8, 0.2)) * ang(5, 0, 10), REED, S)
		B:block(soil, v(0.36, 0.6, 0.36), CFrame.new(BC + v(1.62, 1.55, 0.15)) * ang(5, 0, 10), CATTAIL, S)
		local bub = B:block(soil, v(1.8, 0.1, 1.4), CFrame.new(BC + v(0, 0.08, 0)), BOG, { tr = 1, name = "Soil" })
		B:emitter(bub, "bubble", { name = "BogBubbles", color = { "#bfffb0", "#86ff3c" }, rate = 1.4, size = { 0.15, 0.3, 0.4 }, speed = { 0.3, 0.8 } })

		------------------------------------------------------------- crop
		local Y0 = 1.8
		local crop = B:bone("Crop", "Root", v(0, Y0, 0))

		local leaves = {}
		local function leafAt(p, s, col, tilt)
			tilt = tilt or 22
			local c = CFrame.new(p) * ang(rnd(-tilt, tilt), rnd(0, 90), rnd(-tilt, tilt))
			B:block(crop, v(s, s, s), c, col)
			table.insert(leaves, c)
			return c
		end

		----------------------------------------------------- mossy melons
		-- c: centre; local Z = long axis, local X = flank.
		local glowSpots = {}
		local function melon(c, s, glow)
			local H, L = s * 0.86, s * 1.25
			B:block(crop, v(s, H * 0.68, L * 0.88), c, MEL)
			B:block(crop, v(s * 0.74, H, L * 0.88), c, MEL_LT)
			B:block(crop, v(s * 0.88, H * 0.86, L * 0.96), c, MEL)
			B:block(crop, v(s * 0.6, H * 0.6, L), c, MEL_DK)
			-- dark stripes running the length over the top
			for _, x in { -0.24, 0.24 } do
				B:block(crop, v(0.13 * s, H + 0.06, L * 0.82), c * CFrame.new(x * s, 0, 0), STRIPE)
			end
			-- lime spots on the flanks + one on top
			for _, e in { -1, 1 } do
				local fx = e * (s * 0.44 + 0.03)
				B:block(crop, v(0.14 * s, 0.2 * s, 0.22 * s), c * CFrame.new(fx, 0.12 * H, 0.22 * L * e), SPOT)
				local n = B:block(crop, v(0.13 * s, 0.14 * s, 0.14 * s), c * CFrame.new(fx, -0.18 * H, -0.18 * L * e),
					glow and SPOT_N or SPOT, glow and { mat = "Neon", name = "MelonSpot" } or nil)
				if glow then table.insert(glowSpots, n) end
			end
			B:block(crop, v(0.2 * s, 0.1 * s, 0.24 * s), c * CFrame.new(0, H / 2 + 0.03, 0.18 * L), SPOT)
			-- moss tuft + curly stem on top
			B:block(crop, v(0.42 * s, 0.14 * s + 0.1, 0.42 * s), c * CFrame.new(0, H / 2 + 0.05, -L * 0.24) * ang(0, 30, 0), MOSS)
			B:block(crop, v(0.3, 0.6, 0.3), c * CFrame.new(0, H / 2 + 0.3, -L * 0.28), WOOD_DK)
			B:block(crop, v(0.6, 0.24, 0.24), c * CFrame.new(0.22, H / 2 + 0.6, -L * 0.28), VINE)
			return (c * CFrame.new(0, H / 2 + 0.3, -L * 0.28)).Position
		end
		local function groundMelon(deg, r, yGround, s, yaw, glow)
			local base = polar(deg, r, yGround)
			return melon(CFrame.new(base + v(0, s * 0.43 + 0.02, 0)) * ang(0, -deg + yaw, rnd(-3, 3)), s, glow)
		end

		---------------------------------------------------- bog-root arch
		local ARCH = {
			v(-4.4, Y0 - 0.2, 2.2), v(-4.5, 4.4, 2.4), v(-3.8, 7.0, 2.6), v(-2.3, 9.0, 2.7),
			v(0.0, 9.8, 2.8), v(2.3, 9.0, 2.6), v(3.7, 7.0, 2.3), v(4.4, 4.4, 2.0), v(4.3, Y0 - 0.2, 1.8),
		}
		for i = 1, #ARCH - 1 do
			local mid = math.abs(i - #ARCH / 2) / (#ARCH / 2)
			local w = 1.15 + 0.45 * mid
			B:bar(crop, ARCH[i], ARCH[i + 1], w, w, (i % 2 == 0) and WOOD or WOOD_DK)
			if i > 1 then
				B:block(crop, v(w + 0.15, w + 0.15, w + 0.15), CFrame.new(ARCH[i]) * ang(0, rnd(0, 90), 0), WOOD_LT)
			end
			-- moss caps on the upper segments
			if i >= 2 and i <= #ARCH - 2 then
				local a, b = ARCH[i], ARCH[i + 1]
				local up = v(0, w * 0.5, 0)
				B:bar(crop, a + up, b + up, w + 0.2, 0.34, (i % 2 == 0) and MOSS or MOSS_DK)
			end
		end
		-- gnarled root feet
		for _, f in { { -4.4, 2.2, -1 }, { 4.3, 1.8, 1 } } do
			B:block(crop, v(2.6, 0.8, 2.2), cf(f[1], Y0 + 0.1, f[2], 0, 20 * f[3], 0), WOOD_DK)
			B:block(crop, v(1.4, 0.6, 1.8), cf(f[1] + 1.1 * f[3], Y0 - 0.05, f[2] - 0.6, 0, 35 * f[3], -8 * f[3]), WOOD)
		end

		-- the melon vine winding up the arch
		do
			local prev
			for i = 1, #ARCH do
				local side = (i % 2 == 0) and 1 or -1
				local p = ARCH[i] + v(0, 0.2, side * 0.75)
				if prev then
					B:bar(crop, prev, p, 0.5, 0.5, (i % 2 == 0) and VINE or VINE_DK)
				end
				prev = p
			end
		end

		-- leafy crown on the arch
		leafAt(v(0.0, 10.8, 2.8), 3.4, LEAF)
		leafAt(v(-2.4, 10.0, 2.6), 3.0, LEAF_DK)
		leafAt(v(2.5, 10.1, 2.4), 3.0, LEAF_LT)
		leafAt(v(-1.0, 10.5, 4.3), 2.6, LEAF_DK)
		leafAt(v(1.4, 10.4, 1.1), 2.5, LEAF_TOP)
		leafAt(v(-4.0, 7.8, 2.4), 2.4, LEAF)
		leafAt(v(4.0, 7.6, 2.1), 2.3, LEAF_DK)
		leafAt(v(0.8, 11.8, 3.1), 2.0, LEAF_LT)

		-- two melons dangling from the arch on vine stalks
		local function dangle(top, s, yaw)
			local bot = top + v(0, -1.4, 0)
			B:bar(crop, top, bot, 0.36, 0.36, VINE)
			B:block(crop, v(0.6, 0.4, 0.6), CFrame.new(bot), VINE_DK)
			melon(CFrame.new(bot + v(0, -s * 0.43, 0)) * ang(0, yaw, rnd(-5, 5)), s, false)
		end
		dangle(v(-3.2, 7.6, 1.6), 2.1, 70)
		dangle(v(3.0, 7.9, 1.4), 1.9, 110)

		----------------------------------------------------- ground patch
		-- hero melon in front, others around
		local m1 = groundMelon(0, 1.6, Y0, 3.8, 90, true)
		local m2 = groundMelon(-62, 4.2, 1.4, 2.9, 80, true)
		groundMelon(118, 3.4, 1.4, 2.5, 100, false)
		groundMelon(205, 3.4, 1.4, 1.5, 60, false) -- a little young one

		-- big leaf cubes sprawling over the patch
		leafAt(polar(150, 4.6, 1.0 + 0.6), 2.4, LEAF_DK, 14)
		leafAt(polar(-118, 4.8, 1.0 + 0.6), 2.3, LEAF, 14)
		leafAt(polar(55, 4.6, 1.0 + 0.55), 2.2, LEAF_TOP, 14)
		leafAt(polar(0, 0, Y0 + 0.8), 2.4, LEAF_DK, 10)
		-- runners from the arch feet to the melons
		local function run(a, b, w, col)
			B:bar(crop, a, b, w, w, col)
		end
		run(v(-4.0, Y0 + 0.2, 1.4), v(-2.4, Y0 + 0.3, -0.6), 0.45, VINE)
		run(v(-2.4, Y0 + 0.3, -0.6), m1 + v(-0.3, -0.2, 0.2), 0.42, VINE_DK)
		run(v(3.9, Y0 + 0.2, 1.0), v(3.0, Y0 + 0.2, -0.6), 0.45, VINE_DK)
		run(v(-4.0, Y0 + 0.2, 1.4), m2 + v(0.3, -0.2, 0.3), 0.4, VINE)

		---------------------------------------------------------------- bling
		local fly = B:block(crop, v(9, 6, 5), cf(0, 7.5, 1.0), LEAF, { tr = 1, name = "FireflyZone" })
		B:emitter(fly, "sparkle", { name = "Fireflies", color = { "#e9ff6a", "#a6ff4a" }, rate = 4, size = { 0.1, 0.35, 0 }, speed = { 0.2, 0.6 } })
		B:emitter(glowSpots[1], "glow", { name = "MelonGlow", color = "#b6ff6a", rate = 1, size = 1.4 })
		B:light(glowSpots[1], { name = "MelonLight", color = "#b6ff6a", brightness = 0.9, range = 12 })
	end,
}
