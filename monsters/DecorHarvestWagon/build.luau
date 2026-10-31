--!nocheck
-- Pumpkin Wagon (Harvest Fields decoration, medium accent).
-- A chunky little wooden farm cart heaped with pumpkins: plank sides with
-- stakes, four stepped octagon wheels with spokes and iron hubs, a pull
-- tongue resting on a stone, a straw bed, a pile of ribbed orange pumpkins
-- (plus a cream one and a little green gourd) crowned by a grinning
-- jack-o'-lantern that glows warm from inside. One more pumpkin sits on the
-- ground at the back, autumn leaves and hay bits are scattered around.
-- Static prop: no motion.luau.
return {
	DisplayName = "Pumpkin Wagon",
	Rarity = "Decor",
	Element = "Harvest Fields",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad

		-- palette (Harvest Fields crops)
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local HAY, HAY_DK, HAY_LT = "#e6bd55", "#c4922e", "#f4d98a"
		local WOOD_DK, WOOD, WOOD_LT, WOOD_HI = "#5a3720", "#8a5a32", "#a8723f", "#c08a52"
		local IRON, IRON_DK = "#4b4a52", "#34333a"
		local LF_OR, LF_RED, LF_GOLD = "#f27a1c", "#d8352a", "#f7b52c"
		local PUMP, PUMP_DK, PUMP_LT = "#ff9424", "#e06c18", "#ffb042"
		local CREAM, CREAM_DK, CREAM_LT = "#f1e6c8", "#d9c9a0", "#fff6dc"
		local GOURD, GOURD_DK, GOURD_LT = "#5aa83a", "#3d7f2a", "#9fd36a"
		local STEM, VINE = "#6b7d2a", "#3f7a2a"
		local GLOW, GLOW_HOT = "#ffb12e", "#ffe066"
		local CORN, CORN_DK = "#ffd23a", "#f0a81c"

		local seed = 207
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end

		local root = "Root"

		------------------------------------------------------------ pumpkins
		-- stepped round pumpkin: wide-shallow + narrow-deep + 45deg core block
		local function pumpkin(C, w, cols)
			local main, dk, lt = cols[1], cols[2], cols[3]
			local h = w * 0.78
			B:block(root, v(w, h, w * 0.7), C, dk)
			B:block(root, v(w * 0.7, h + 0.04, w), C, main)
			B:block(root, v(w * 0.66, h - 0.12, w * 0.66), C * CFrame.Angles(0, rad(45), 0), dk)
			B:block(root, v(w * 0.46, 0.2, w * 0.46), C * CFrame.new(0, h * 0.5 + 0.06, 0), lt)
			return C * CFrame.new(0, h * 0.5, 0), h
		end
		local function stemTop(top, s, yaw, leaf)
			B:block(root, v(0.42 * s, 0.7 * s, 0.42 * s), top * CFrame.new(0, 0.3 * s, 0) * CFrame.Angles(0, rad(yaw), rad(10)), STEM)
			if leaf then
				B:block(root, v(0.9 * s, 0.14, 0.6 * s), top * CFrame.new(0.45 * s, 0.14, 0.1) * CFrame.Angles(0, rad(yaw + 30), rad(-12)), VINE)
			end
		end
		-- carved jack-o'-lantern face on the -Z side of a pumpkin at C
		local function face(C, w)
			local s = w / 2.8
			local fz = -(w * 0.5) - 0.02
			local function fp(x, y, sx, sy, col, name)
				return B:block(root, v(sx * s, sy * s, 0.12), C * CFrame.new(x * s, y * s, fz), col, { mat = "Neon", name = name or "JackFace" })
			end
			-- dark carved rim behind the eyes and the grin
			for side = -1, 1, 2 do
				B:block(root, v(0.9 * s, 0.62 * s, 0.1), C * CFrame.new(side * 0.62 * s, 0.38 * s, fz + 0.03), "#6e2c08")
				fp(side * 0.62, 0.22, 0.74, 0.26, GLOW)
				fp(side * 0.62, 0.44, 0.44, 0.22, GLOW_HOT)
				fp(side * 0.62, 0.6, 0.16, 0.14, GLOW_HOT)
			end
			fp(0, -0.02, 0.3, 0.16, GLOW)
			B:block(root, v(2.0 * s, 0.5 * s, 0.1), C * CFrame.new(0, -0.4 * s, fz + 0.03), "#6e2c08")
			local core = fp(0, -0.42, 1.7, 0.32, GLOW_HOT, "JackGrin")
			fp(-0.91, -0.26, 0.26, 0.3, GLOW)
			fp(0.91, -0.26, 0.26, 0.3, GLOW)
			local tz = fz - 0.04
			B:block(root, v(0.26 * s, 0.17 * s, 0.14), C * CFrame.new(-0.3 * s, -0.33 * s, tz), PUMP)
			B:block(root, v(0.26 * s, 0.17 * s, 0.14), C * CFrame.new(0.3 * s, -0.33 * s, tz), PUMP)
			B:block(root, v(0.26 * s, 0.15 * s, 0.14), C * CFrame.new(0, -0.52 * s, tz), PUMP)
			return core
		end

		------------------------------------------------------------ footing
		for _, st in { { -6.8, -1.4, 2.0, 1.5, 15 }, { -8.7, 0.6, 1.5, 1.2, -20 }, { 6.6, 1.6, 1.8, 1.4, 30 }, { 0.6, 3.6, 1.6, 1.1, -10 }, { -2.4, -3.7, 1.4, 1.0, 40 } } do
			B:block(root, v(st[3], 0.35, st[4]), cf(st[1], 0.175, st[2], 0, st[5], 0), STONE)
			B:block(root, v(st[3] * 0.62, 0.2, st[4] * 0.6), cf(st[1] + 0.1, 0.42, st[2] - 0.05, 0, st[5] + 12, 0), STONE_LT)
		end
		for _, g in { { -5.6, 2.6 }, { 5.3, -3.4 }, { -0.8, -3.6 }, { 3.6, 3.7 }, { -7.6, 2.2 }, { 7.2, -0.6 } } do
			local yaw = rnd() * 60
			B:block(root, v(0.45, 1.0, 0.45), cf(g[1], 0.5, g[2], 0, yaw, 6), GRASS)
			B:block(root, v(0.35, 0.7, 0.35), cf(g[1] + 0.35, 0.35, g[2] + 0.2, 0, yaw + 25, -10), GRASS_DK)
		end
		-- hay bits and fallen leaves on the ground
		for _, h in { { -4.6, -3.2 }, { 2.4, -3.6 }, { 4.8, 3.2 }, { -3.0, 3.4 } } do
			local yaw = rnd() * 180
			B:block(root, v(1.5, 0.16, 0.22), cf(h[1], 0.08, h[2], 0, yaw, 0), HAY)
			B:block(root, v(1.2, 0.16, 0.22), cf(h[1] + 0.1, 0.22, h[2] + 0.1, 0, yaw + 50, 0), HAY_LT)
		end
		for i, l in { { -1.4, -4.2, LF_OR }, { 3.8, -2.6, LF_RED }, { -6.0, -2.9, LF_GOLD }, { 6.8, 3.0, LF_OR }, { -4.0, 4.0, LF_RED }, { 1.6, 4.2, LF_GOLD } } do
			B:block(root, v(0.8, 0.14, 0.8), cf(l[1], 0.07 + (i % 2) * 0.03, l[2], 0, rnd() * 90, 0), l[3])
		end

		------------------------------------------------------------ wheels
		local WY, WR = 2.0, 1.7 -- wheel centre height, ring radius (outer edge = 2.0)
		local function wheel(x, z)
			local C = CFrame.new(x, WY, z) * CFrame.Angles(rad(90), 0, 0)
			B:ring(root, C, WR, 8, v(1.5, 0.5, 0.6), WOOD_DK)
			for i = 0, 3 do
				B:block(root, v(0.32, 2 * WR, 0.3), CFrame.new(x, WY, z) * CFrame.Angles(0, 0, rad(i * 45)), WOOD)
			end
			local out = z > 0 and 1 or -1
			B:block(root, v(0.9, 0.9, 0.7), cf(x, WY, z), IRON)
			B:block(root, v(0.5, 0.5, 0.5), cf(x, WY, z + out * 0.45), IRON_DK)
		end
		for _, x in { -3.2, 3.2 } do
			for _, z in { -2.95, 2.95 } do
				wheel(x, z)
			end
			B:block(root, v(0.5, 0.5, 6.2), cf(x, WY, 0), IRON_DK) -- axle
			B:block(root, v(1.0, 0.7, 4.4), cf(x, WY + 0.55, 0), WOOD_DK) -- bolster
		end

		------------------------------------------------------------ cart bed
		local BY = 3.0 -- floor centre
		B:block(root, v(10.4, 0.6, 5.0), cf(0, BY, 0), WOOD)
		for _, z in { -1.6, 1.6 } do
			B:block(root, v(10.8, 0.5, 0.6), cf(0, BY - 0.5, z), WOOD_DK) -- under-rails
		end
		-- long side boards (front -Z / back +Z): two planks with a darker gap line
		for _, z in { -2.6, 2.6 } do
			local zo = z < 0 and -1 or 1
			B:block(root, v(10.6, 0.8, 0.4), cf(0, BY + 0.7, z), WOOD_LT)
			B:block(root, v(10.5, 0.16, 0.36), cf(0, BY + 1.18, z), WOOD_DK)
			B:block(root, v(10.6, 0.8, 0.4), cf(0, BY + 1.66, z), WOOD)
			-- stakes poking above, with lighter caps
			for _, x in { -5.0, -1.7, 1.7, 5.0 } do
				B:block(root, v(0.6, 2.9, 0.5), cf(x, BY + 1.05, z + zo * 0.2), WOOD_DK)
				B:block(root, v(0.7, 0.3, 0.6), cf(x, BY + 2.6, z + zo * 0.2), WOOD_HI)
			end
			-- iron strap brackets
			for _, x in { -3.35, 3.35 } do
				B:block(root, v(0.3, 1.9, 0.12), cf(x, BY + 1.15, z + zo * 0.24), IRON)
			end
		end
		-- end boards (x = +-5.2), a little lower
		for _, x in { -5.2, 5.2 } do
			B:block(root, v(0.4, 0.8, 4.9), cf(x, BY + 0.7, 0), WOOD_LT)
			B:block(root, v(0.4, 0.8, 4.9), cf(x, BY + 1.56, 0), WOOD)
		end

		------------------------------------------------------------ tongue
		local tA, tB = v(-5.4, BY - 0.4, 0), v(-8.9, 0.65, 0)
		B:bar(root, tA, tB, 0.55, 0.5, WOOD_DK)
		for _, z in { -1.4, 1.4 } do
			B:bar(root, v(-4.6, BY - 0.45, z), v(-7.0, 1.4, 0), 0.4, 0.4, WOOD)
		end
		B:block(root, v(0.5, 0.45, 2.6), cf(-9.0, 0.75, 0), WOOD) -- T handle
		B:block(root, v(0.56, 0.5, 0.5), cf(-9.0, 0.75, -1.3), WOOD_HI)
		B:block(root, v(0.56, 0.5, 0.5), cf(-9.0, 0.75, 1.3), WOOD_HI)
		B:block(root, v(1.0, 0.45, 1.3), cf(-8.8, 0.22, 0.2, 0, 14, 0), STONE_DK) -- rest stone

		------------------------------------------------------------ straw bed
		B:block(root, v(9.8, 1.5, 4.6), cf(0, BY + 0.95, 0), HAY)
		B:block(root, v(7.4, 0.5, 3.4), cf(0, BY + 1.9, 0.2), HAY_LT)
		for i = 0, 9 do
			local x = -4.5 + i + jit(0.2)
			local z = (i % 2 == 0) and -2.25 or 2.25
			B:block(root, v(0.9, 0.18, 0.2), cf(x, BY + 2.05 + jit(0.15), z + jit(0.1), 0, jit(40), (i % 2 == 0 and 30 or -30)), i % 3 == 0 and HAY_LT or HAY_DK)
		end

		------------------------------------------------------------ the heap
		local OR = { PUMP, PUMP_DK, PUMP_LT }
		local OR2 = { "#f7862a", "#d9601a", "#ffa648" }
		local TOPY = BY + 1.6 -- top of the straw
		local heap = {
			-- x, z, w, yaw, cols, lift, leaf
			{ -3.2, -0.9, 2.5, 10, OR, 0, true },
			{ 3.3, -0.8, 2.4, -15, OR2, 0, false },
			{ -1.7, 1.1, 2.7, 30, OR2, 0, true },
			{ 2.0, 1.2, 2.6, -25, OR, 0, true },
			{ -3.6, 0.9, 1.9, 40, OR, 1.9, false },
			{ 4.0, 0.9, 1.8, 5, { CREAM, CREAM_DK, CREAM_LT }, 1.9, true },
			{ -1.9, -0.2, 2.1, -20, OR, 1.5, true },
			{ 2.4, 0.2, 2.2, 35, OR2, 1.3, false },
			{ 0.4, 1.4, 2.2, 15, OR, 1.6, true },
		}
		for _, p in heap do
			local w = p[3]
			local h = w * 0.78
			local C = CFrame.new(p[1], TOPY + h / 2 - 0.15 + p[6], p[2]) * CFrame.Angles(rad(jit(6)), rad(p[4]), rad(jit(6)))
			local top = pumpkin(C, w, p[5])
			stemTop(top, w / 2.6, p[4] * 2, p[7])
		end
		-- little green gourd peeking over the front board
		local gC = CFrame.new(-4.3, TOPY + 0.5, -1.7) * CFrame.Angles(rad(-15), rad(20), rad(-14))
		B:block(root, v(1.1, 0.9, 1.1), gC, GOURD)
		B:block(root, v(0.8, 1.3, 0.8), gC * CFrame.new(0, 0.5, 0), GOURD_DK)
		B:block(root, v(0.5, 0.18, 0.5), gC * CFrame.new(0, 1.2, 0), GOURD_LT)
		B:block(root, v(0.25, 0.5, 0.25), gC * CFrame.new(0.05, 1.45, 0), STEM)
		-- two corn cobs tucked into the pile
		for _, c in { { 4.5, -1.4, -25, -35 }, { -0.6, 2.0, 20, 40 } } do
			local C = CFrame.new(c[1], TOPY + 1.0, c[2]) * CFrame.Angles(rad(c[3]), 0, rad(c[4]))
			B:block(root, v(0.6, 1.8, 0.6), C, CORN)
			B:block(root, v(0.66, 0.4, 0.66), C * CFrame.new(0, 0.5, 0), CORN_DK)
			B:block(root, v(0.3, 1.4, 0.75), C * CFrame.new(0.35, -0.6, 0) * CFrame.Angles(0, 0, rad(-15)), HAY_LT)
			B:block(root, v(0.75, 1.3, 0.3), C * CFrame.new(-0.2, -0.65, 0.3) * CFrame.Angles(rad(12), 0, rad(10)), HAY)
		end

		-- the big grinning jack-o'-lantern on top, facing front
		local JW = 3.0
		local JH = JW * 0.78
		local JC = CFrame.new(0.3, TOPY + 1.35 + JH / 2, -0.9) * CFrame.Angles(rad(-4), rad(-6), rad(2))
		local jtop = pumpkin(JC, JW, OR)
		stemTop(jtop, JW / 2.6, 15, true)
		local core = face(JC, JW)
		B:light(core, { color = "#ffa64a", brightness = 0.9, range = 12, name = "JackLight" })
		-- straw packed under the jack so it sits in the pile
		B:block(root, v(2.2, 1.2, 1.8), cf(0.3, TOPY + 0.75, -0.6), HAY_DK)

		-- a stray pumpkin on the ground at the back end, and a few leaves on the boards
		local gp = CFrame.new(6.9, 0.94, -1.9) * CFrame.Angles(0, rad(-30), rad(4))
		local gtop = pumpkin(gp, 2.2, OR2)
		stemTop(gtop, 2.2 / 2.6, 60, true)
		for _, l in { { -4.2, -2.75, LF_RED, 20 }, { 2.6, -2.75, LF_GOLD, -15 }, { 5.3, 1.0, LF_OR, 30 } } do
			B:block(root, v(0.75, 0.75, 0.14), cf(l[1], BY + 2.0, l[2], 0, 0, 45 + l[4] * 0.5), l[3])
		end
	end,
}
