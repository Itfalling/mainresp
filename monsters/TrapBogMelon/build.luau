--!nocheck
-- Mossy Bog Melon (Flytrap Stage crop #4, Epic).
-- A low, clean melon patch on a stepped bog mound. One BIG hero melon and
-- two medium ones, all WHOLE and rounded (stepped tiers in height and
-- length): deep rich bog-green skin with bright moss-lime stripes curving
-- end to end over the top, a few softly glowing lime spots and a moss
-- tuft + curly stem on top. Around them a vine rosette of big flat studded
-- leaves with two curly tendrils, a little clump of glowing purple bog
-- mushrooms, cattails, and a bog puddle with lily pads and a pink flower.
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
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local BOG, BOG_LT = "#2f6a50", "#6fb58a"
		local REED, CATTAIL = "#7f8f3a", "#5a3a1e"
		local STEM = "#5a3b22"
		local VINE_DK, VINE = "#3f7f2c", "#5a9e34"
		local LEAF_DK, LEAF, LEAF_LT, VEIN = "#357a2a", "#469a34", "#5aae3c", "#2a5e22"
		local MEL_DK, MEL, MEL_LT = "#164428", "#1f5a34", "#2b7a44"
		local STRIPE = "#b6ff5a"
		local GLOW = "#c8ff4a"
		local LILY, LILY_DK = "#5cb83a", "#3f8f2a"
		local FLOWER, FLOWER_C = "#ff8cb4", "#ffe27a"
		local SHROOM_STEM, CAP, CAP_DK = "#efe2c4", "#8a5ad6", "#6a3fb0"

		local seed = 4404
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
				local w, d = rnd(1.6, 2.4), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 6.4, DIRT_DK, 14, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.6, 4.8, DIRT, 10, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.4, 0.4, 3.2, DIRT_LT, 0, {}, 0)

		-- moss pads draped over the tier edges
		for _, m in { { 140, 6.3, 1.12, 2.2, MOSS }, { 215, 6.2, 1.1, 2.0, MOSS_DK }, { 290, 6.3, 1.12, 2.1, MOSS } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], m[3], -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[4], 0.3, 1.3), c * ang(-12, 0, 0), m[5], S)
		end
		-- stones
		for _, s in { { -5.6, 0.95, -1.6, 0.9, 25, STONE }, { -5.3, 0.85, -0.4, 0.6, 10, STONE_LT }, { 5.0, 0.95, 3.4, 0.8, -20, STONE_DK } } do
			B:block(soil, v(s[4] * 1.2, s[4], s[4]), cf(s[1], s[2], s[3], rnd(-10, 10), s[5], rnd(-10, 10)), s[6], S)
		end
		-- tiny grass tufts
		for _, g in { { -6.3, 1.8 }, { 1.0, 6.5 }, { 6.2, -0.6 } } do
			B:block(soil, v(0.45, 0.9, 0.45), cf(g[1], 0.95, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.35, 0.6, 0.35), cf(g[1] + 0.35, 0.9, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end

		-- bog puddle sunk into the front-right of the middle tier
		local BC = v(3.0, 1.42, -3.5)
		B:block(soil, v(3.2, 0.3, 2.0), CFrame.new(BC) * ang(0, 30, 0), BOG, S)
		B:block(soil, v(2.0, 0.28, 3.0), CFrame.new(BC + v(0.05, -0.02, 0)) * ang(0, 30, 0), BOG, S)
		B:block(soil, v(1.2, 0.1, 0.35), CFrame.new(BC + v(0.5, 0.15, -0.3)) * ang(0, 30, 0), BOG_LT, S)
		B:block(soil, v(0.9, 0.5, 0.7), CFrame.new(BC + v(1.6, 0.05, 0.4)) * ang(0, 15, 0), MUD, S)
		-- lily pads (one with a little pink flower)
		B:block(soil, v(1.2, 0.12, 1.2), CFrame.new(BC + v(-0.5, 0.18, 0.1)) * ang(0, 25, 0), LILY, S)
		B:block(soil, v(0.85, 0.12, 0.85), CFrame.new(BC + v(0.7, 0.18, -0.6)) * ang(0, -10, 0), LILY_DK, S)
		B:block(soil, v(0.55, 0.3, 0.55), CFrame.new(BC + v(-0.5, 0.36, 0.1)) * ang(0, 45, 0), FLOWER, S)
		B:block(soil, v(0.25, 0.2, 0.25), CFrame.new(BC + v(-0.5, 0.56, 0.1)) * ang(0, 45, 0), FLOWER_C, S)
		local bub = B:block(soil, v(1.8, 0.1, 1.4), CFrame.new(BC + v(0, 0.08, 0)), BOG, { tr = 1, name = "Soil" })
		B:emitter(bub, "bubble", { name = "BogBubbles", color = { "#bfffb0", "#86ff3c" }, rate = 1.4, size = { 0.15, 0.3, 0.4 }, speed = { 0.3, 0.8 } })
		-- cattail clump behind the puddle
		for _, c in { { 1.7, 0.4, 2.6, -5, 0 }, { 2.05, 0.0, 2.0, 6, 4 }, { 1.3, -0.1, 1.6, -2, -10 } } do
			local base = BC + v(c[1], 0, c[2] + 1.0)
			local rc = CFrame.new(base + v(0, c[3] / 2, 0)) * ang(c[4], 0, c[5])
			B:block(soil, v(0.22, c[3], 0.22), rc, REED, S)
			B:block(soil, v(0.4, 0.75, 0.4), rc * CFrame.new(0, c[3] / 2 + 0.1, 0), CATTAIL, S)
		end

		------------------------------------------------------------- crop
		local Y0 = 1.8
		local crop = B:bone("Crop", "Root", v(0, Y0, 0))

		----------------------------------------------------- bog melons
		-- c sits at the melon's centre; local Z = long axis, X = flank.
		-- Rounded by stepped tiers in height AND length; lime stripes are
		-- thin slabs rotated around the long axis so they curve over the top.
		local glowSpots = {}
		local function melon(c, s)
			local H, L = s * 0.9, s * 1.22
			local T = { { 0.07, 0.5, MEL_DK }, { 0.21, 0.82, MEL }, { 0.36, 0.96, MEL }, { 0.5, 1.0, MEL_LT },
				{ 0.64, 0.96, MEL }, { 0.79, 0.82, MEL }, { 0.93, 0.5, MEL_LT } }
			for _, t in T do
				-- each tier is a stepped oval in plan: wide-short + narrow-long
				local w = t[2]
				local y = (t[1] - 0.5) * H
				B:block(crop, v(w * s, 0.15 * H, w * 0.74 * L), c * CFrame.new(0, y, 0), t[3])
				B:block(crop, v(w * 0.66 * s, 0.15 * H - 0.02, (0.42 + 0.58 * w) * L), c * CFrame.new(0, y, 0), t[3])
			end
			-- bright moss-lime stripes curving end to end over the top
			for _, th in { -96, -48, 0, 48, 96 } do
				local a = rad(th)
				local p = v(math.sin(a) * (s / 2 - 0.01), math.cos(a) * (H / 2 - 0.01), 0)
				local len = L * ((math.abs(th) > 60) and 0.62 or ((th == 0) and 0.88 or 0.74))
				B:block(crop, v(0.13 * s, 0.12, len), c * CFrame.new(p) * ang(0, 0, -th), STRIPE)
			end
			-- a few softly glowing lime spots between the stripes
			for _, q in { { 24, 0.22 }, { -72, -0.26 } } do
				local a = rad(q[1])
				local p = v(math.sin(a) * (s / 2 + 0.03), math.cos(a) * (H / 2 + 0.03), q[2] * L)
				local n = B:block(crop, v(0.12 * s, 0.1, 0.12 * s), c * CFrame.new(p) * ang(0, 0, -q[1]), GLOW,
					{ mat = "Neon", name = "MelonSpot" })
				table.insert(glowSpots, n)
			end
			-- moss tuft + curly stem on top
			B:block(crop, v(0.3 * s, 0.22, 0.34 * s), c * CFrame.new(0, H / 2 + 0.06, -L * 0.24) * ang(0, 25, 0), MOSS)
			B:block(crop, v(0.36, 0.7, 0.36), c * CFrame.new(0, H / 2 + 0.4, -L * 0.3), STEM)
			B:block(crop, v(0.7, 0.28, 0.28), c * CFrame.new(0.25, H / 2 + 0.72, -L * 0.3), VINE)
			return (c * CFrame.new(0, H / 2 + 0.3, -L * 0.3)).Position
		end
		local function groundMelon(x, z, yGround, s, yaw)
			return melon(CFrame.new(x, yGround + s * 0.45 - 0.05, z) * ang(0, yaw, rnd(-2, 2)), s)
		end
		B:block(crop, v(3.4, 0.3, 3.0), cf(-0.7, Y0 + 0.1, 0.0, 0, 20, 0), MOSS)
		B:block(crop, v(2.6, 0.32, 3.6), cf(-0.7, Y0 + 0.12, 0.0, 0, 20, 0), MOSS_DK)
		local mHero = groundMelon(-0.7, 0.0, Y0 + 0.28, 4.8, 72)
		local mA = groundMelon(3.6, 2.6, 1.4, 2.7, -30)
		local mB = groundMelon(-4.4, -2.6, 0.8, 2.5, 35)

		------------------------------------------------- vine rosette
		local function bar(a, b, w, col)
			B:bar(crop, a, b, w, w, col)
		end
		local VY = Y0 + 0.25
		local hub = v(-0.6, VY, 3.6)
		local nodes = {
			v(-3.4, 1.6, 3.2), v(2.2, 1.85, 4.0), v(3.0, 1.8, -1.4), v(-4.0, 1.4, 0.6), v(0.8, 2.0, -3.4),
		}
		for _, n in nodes do
			bar(hub, n, 0.42, VINE_DK)
		end
		bar(hub, mHero + v(0, -0.3, 0), 0.45, VINE)
		bar(nodes[2], mA + v(0, -0.2, 0), 0.38, VINE)
		bar(nodes[4], mB + v(0, -0.2, 0), 0.38, VINE)
		B:block(crop, v(1.2, 0.6, 1.2), CFrame.new(hub) * ang(0, 30, 0), VINE_DK)

		-- big flat studded leaves (blade + lobe + vein), lying almost flat
		local leaves = {}
		local function leaf(at, yaw, sc, col)
			local F = CFrame.new(at + v(0, 0.12, 0)) * ang(0, yaw, 0) * ang(10, 0, 0)
			local p = B:block(crop, v(2.8 * sc, 0.3, 2.4 * sc), F * CFrame.new(0, 0, -1.2 * sc), col)
			B:block(crop, v(1.6 * sc, 0.3, 1.2 * sc), F * CFrame.new(0, 0.02, -2.9 * sc), col)
			B:block(crop, v(0.3, 0.34, 3.0 * sc), F * CFrame.new(0, 0.04, -1.6 * sc), VEIN)
			table.insert(leaves, p)
		end
		leaf(nodes[1], 150, 0.85, LEAF)
		leaf(nodes[2], -160, 0.8, LEAF_LT)
		leaf(nodes[4], 100, 0.85, LEAF_LT)
		leaf(nodes[5], -15, 0.7, LEAF)
		leaf(hub + v(0.4, 0.3, 0.6), 200, 0.9, LEAF_DK)
		leaf(v(-2.4, 1.6, -4.2), 20, 0.7, LEAF_DK)

		-- little yellow melon flowers on the vine
		for _, f in { nodes[3] + v(-0.6, 0.5, 0.6), nodes[1] + v(0.8, 0.5, -0.4) } do
			B:block(crop, v(0.6, 0.2, 0.6), CFrame.new(f) * ang(0, 45, 0), FLOWER_C)
			B:block(crop, v(0.25, 0.25, 0.25), CFrame.new(f + v(0, 0.15, 0)), "#ff9f3a")
		end

		-- two curly tendrils rising from the vine
		local function tendril(base, yaw, h, r0)
			local f = CFrame.new(base) * ang(0, yaw, 0)
			local c = f * CFrame.new(r0, h, 0)
			local prev = base
			local first = (c * CFrame.new(-r0, 0, 0)).Position
			bar(prev, first, 0.3, VINE)
			prev = first
			for k = 1, 7 do
				local a = rad(180 - k * 55)
				local r = r0 * (1 - k * 0.09)
				local p = (c * CFrame.new(math.cos(a) * r, math.sin(a) * r, 0)).Position
				bar(prev, p, 0.28 - k * 0.015, (k % 2 == 0) and VINE_DK or VINE)
				prev = p
			end
		end
		tendril(hub + v(-0.8, 0.2, 0.0), 10, 6.0, 1.0)
		tendril(nodes[2] + v(-0.4, 0.1, -0.2), -60, 4.4, 0.8)

		-- glowing purple bog mushrooms (back-left)
		local shroomGlow
		local function shroom(p, h, s)
			B:block(crop, v(0.4 * s, h, 0.4 * s), CFrame.new(p + v(0, h / 2, 0)), SHROOM_STEM)
			local top = p + v(0, h, 0)
			B:block(crop, v(1.3 * s, 0.4 * s, 1.3 * s), CFrame.new(top) * ang(0, 45, 0), CAP)
			B:block(crop, v(0.8 * s, 0.3 * s, 0.8 * s), CFrame.new(top + v(0, 0.3 * s, 0)) * ang(0, 20, 0), CAP_DK)
			local g = B:block(crop, v(1.0 * s, 0.1, 1.0 * s), CFrame.new(top + v(0, -0.22 * s, 0)) * ang(0, 45, 0), GLOW,
				{ mat = "Neon", name = "ShroomGlow" })
			B:block(crop, v(0.22, 0.22, 0.22), CFrame.new(top + v(0.3 * s, 0.25 * s, -0.2 * s)), GLOW, { mat = "Neon", name = "ShroomDot" })
			shroomGlow = shroomGlow or g
		end
		shroom(v(4.3, 1.4, -0.1), 1.3, 1.1)
		shroom(v(5.1, 1.2, 0.9), 0.8, 0.8)
		shroom(v(3.6, 1.4, 0.8), 0.6, 0.65)

		---------------------------------------------------------------- bling
		local fly = B:block(crop, v(10, 4, 9), cf(0, 5.5, 0.5), LEAF, { tr = 1, name = "FireflyZone" })
		B:emitter(fly, "sparkle", { name = "Fireflies", color = { "#e9ff6a", "#b6ff5a" }, rate = 4, size = { 0.1, 0.35, 0 }, speed = { 0.2, 0.6 } })
		B:emitter(shroomGlow, "glow", { name = "ShroomAura", color = "#c8a8ff", rate = 1, size = 1.2 })
		B:light(glowSpots[1], { name = "MelonLight", color = "#b6ff6a", brightness = 0.9, range = 12 })
	end,
}
