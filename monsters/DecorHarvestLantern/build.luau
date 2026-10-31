--!nocheck
-- Harvest Lantern Post (Harvest Fields decoration, small accent).
-- A crooked old wooden post on a little stepped stone footing, wrapped with
-- twine at its kinks, with a bent arm and a diagonal brace. From the arm's
-- hook a chunky iron lantern hangs on a short chain: stepped roof, corner
-- posts, amber glass and a glowing candle flame inside. Under it lies a heap
-- of autumn leaves (orange / red / gold) with a tiny pumpkin tucked in, and
-- a leaf rake leans against the post.
-- Animated (motion.luau): the lantern swings gently and its flame flickers.
return {
	DisplayName = "Harvest Lantern Post",
	Rarity = "Decor",
	Element = "Harvest Fields",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad

		-- palette (Harvest Fields crops)
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local HAY, HAY_LT = "#e6bd55", "#f4d98a"
		local BARK_DK, BARK, BARK_LT = "#2e1a10", "#45281a", "#6a4128"
		local WOOD, WOOD_LT = "#8a5a32", "#a8723f"
		local TWINE = "#d9b56a"
		local IRON, IRON_DK, IRON_LT = "#3f3e46", "#2a2930", "#5c5b66"
		local GLASS = "#ffb347"
		local LF_OR, LF_OR_DK, LF_RED, LF_RED_DK = "#f27a1c", "#d9581a", "#d8352a", "#a8231f"
		local LF_GOLD, LF_GOLD_LT, LF_PLUM = "#f7b52c", "#ffd34f", "#7b2e6e"
		local PUMP, PUMP_DK, PUMP_LT = "#ff9424", "#e06c18", "#ffb042"
		local STEM, VINE = "#6b7d2a", "#3f7a2a"
		local CANDLE = "#fff2d6"
		local GLOW, GLOW_HOT = "#ffb12e", "#ffe066"

		local seed = 208
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local root = "Root"

		------------------------------------------------------------ footing
		B:block(root, v(2.6, 0.5, 2.2), cf(0, 0.25, 0, 0, 8, 0), STONE_DK)
		B:block(root, v(2.0, 0.4, 2.6), cf(0.05, 0.3, 0.05, 0, 8, 0), STONE)
		B:block(root, v(1.7, 0.35, 1.7), cf(0, 0.65, 0, 0, -6, 0), STONE_LT)
		for _, st in { { -1.9, -1.2, 1.2, 0.9, 25 }, { -1.5, 1.6, 1.0, 0.8, -15 }, { 1.4, -1.9, 0.9, 0.7, 40 } } do
			B:block(root, v(st[3], 0.3, st[4]), cf(st[1], 0.15, st[2], 0, st[5], 0), STONE)
			B:block(root, v(st[3] * 0.6, 0.16, st[4] * 0.6), cf(st[1] + 0.08, 0.35, st[2], 0, st[5] + 15, 0), STONE_LT)
		end
		for _, g in { { -2.2, 0.3 }, { 0.6, 1.9 }, { -0.9, -2.0 }, { 4.6, 1.6 }, { -2.6, -2.1 } } do
			local yaw = rnd() * 60
			B:block(root, v(0.4, 0.9, 0.4), cf(g[1], 0.45, g[2], 0, yaw, 5), GRASS)
			B:block(root, v(0.32, 0.6, 0.32), cf(g[1] + 0.3, 0.3, g[2] + 0.2, 0, yaw + 25, -8), GRASS_DK)
		end

		------------------------------------------------------------ crooked post
		local p0, p1, p2, p3 = v(0, 0.7, 0), v(0.25, 3.0, 0.1), v(-0.15, 5.0, -0.05), v(0.1, 6.9, 0.05)
		B:bar(root, p0, p1 + v(0, 0.25, 0), 0.95, 0.95, BARK)
		B:bar(root, p1 - v(0, 0.2, 0), p2 + v(0, 0.2, 0), 0.85, 0.85, BARK_LT)
		B:bar(root, p2 - v(0, 0.2, 0), p3, 0.78, 0.78, BARK)
		-- bark streaks
		B:block(root, v(0.2, 1.6, 0.98), cf(0.3, 1.6, 0.0, 0, 0, -6), BARK_DK)
		B:block(root, v(0.9, 1.1, 0.18), cf(0.0, 4.2, -0.42, 0, 0, 11), BARK_DK)
		-- twine wraps at the kinks
		for _, p in { { p1, 1.08, 6 }, { p2, 0.98, -11 } } do
			B:block(root, v(p[2], 0.22, p[2]), CFrame.new(p[1]) * CFrame.Angles(0, rad(10), rad(p[3])), TWINE)
			B:block(root, v(p[2] - 0.04, 0.16, p[2] - 0.04), CFrame.new(p[1] + v(0, 0.3, 0)) * CFrame.Angles(0, rad(-12), rad(p[3])), HAY)
		end
		-- crooked cap on top
		B:block(root, v(0.95, 0.28, 0.95), cf(0.12, 6.98, 0.05, 0, 12, -7), BARK_DK)
		B:block(root, v(0.4, 0.3, 0.4), cf(0.2, 7.2, 0.0, 0, 30, -15), BARK_LT)

		-- bent arm + brace
		local a0, a1, a2 = v(-0.3, 6.3, 0.05), v(1.6, 6.55, 0.05), v(2.95, 6.35, 0.05)
		B:bar(root, a0, a1 + v(0.15, 0, 0), 0.6, 0.55, BARK_LT)
		B:bar(root, a1 - v(0.15, 0, 0), a2, 0.55, 0.5, BARK)
		B:bar(root, v(0.1, 4.7, 0.05), v(1.55, 6.35, 0.05), 0.4, 0.4, BARK)
		B:block(root, v(0.66, 0.22, 0.66), CFrame.new(a1) * CFrame.Angles(0, 0, rad(-4)), TWINE)
		-- iron hook under the arm end
		local HOOK = v(2.6, 6.0, 0.05)
		B:block(root, v(0.18, 0.5, 0.18), cf(2.6, 6.15, 0.05), IRON)
		B:block(root, v(0.4, 0.14, 0.18), cf(2.5, 5.93, 0.05), IRON)

		------------------------------------------------------------ lantern (swings)
		local lan = B:bone("Lantern", "Root", HOOK)
		local LX, LZ = HOOK.X, HOOK.Z
		-- chain: alternating links
		for i = 0, 2 do
			local y = 5.75 - i * 0.32
			if i % 2 == 0 then
				B:block(lan, v(0.26, 0.36, 0.1), cf(LX, y, LZ), IRON_LT)
			else
				B:block(lan, v(0.1, 0.36, 0.26), cf(LX, y, LZ), IRON)
			end
		end
		local CY = 4.25 -- lantern body centre
		-- handle ring + stepped roof
		B:block(lan, v(0.6, 0.12, 0.12), cf(LX, 5.0, LZ), IRON)
		B:block(lan, v(0.5, 0.3, 0.5), cf(LX, 5.05 - 0.2, LZ), IRON_DK)
		B:block(lan, v(1.0, 0.25, 1.0), cf(LX, 4.72 + 0.05, LZ), IRON)
		B:block(lan, v(1.55, 0.25, 1.55), cf(LX, 4.98 - 0.48, LZ), IRON_DK)
		-- cage: corner posts, bottom plate, little feet
		for _, sx in { -1, 1 } do
			for _, sz in { -1, 1 } do
				B:block(lan, v(0.22, 1.2, 0.22), cf(LX + sx * 0.6, CY - 0.25, LZ + sz * 0.6), IRON)
				B:block(lan, v(0.2, 0.2, 0.2), cf(LX + sx * 0.5, CY - 1.0, LZ + sz * 0.5), IRON_DK)
			end
		end
		-- mid bands on each face
		B:block(lan, v(1.3, 0.12, 1.32), cf(LX, CY - 0.25, LZ), IRON_LT, { tr = 0 })
		B:block(lan, v(1.4, 0.22, 1.4), cf(LX, CY - 0.9, LZ), IRON_DK)
		-- amber glass box and the candle inside
		B:block(lan, v(1.12, 1.05, 1.12), cf(LX, CY - 0.28, LZ), GLASS, { mat = "Neon", tr = 0.3, name = "Glass" })
		B:block(lan, v(0.42, 0.45, 0.42), cf(LX, CY - 0.58, LZ), CANDLE)
		local flame = B:block(lan, v(0.3, 0.42, 0.3), cf(LX, CY - 0.14, LZ), GLOW_HOT, { mat = "Neon", name = "Flame" })
		B:block(lan, v(0.18, 0.2, 0.18), cf(LX, CY + 0.12, LZ), GLOW, { mat = "Neon", name = "FlameTip" })
		-- bottom finial
		B:block(lan, v(0.4, 0.25, 0.4), cf(LX, CY - 1.12, LZ), IRON)
		B:light(flame, { color = "#ffa64a", brightness = 1.1, range = 12, name = "LanternLight" })
		B:emitter(flame, "glow", { name = "LanternGlow", color = "#ffb347", rate = 1, size = { 1.6, 0 }, life = { 1.2, 1.6 } })

		------------------------------------------------------------ leaf pile
		local LEAF = { LF_OR, LF_OR_DK, LF_RED, LF_GOLD, LF_GOLD_LT, LF_RED_DK, LF_OR, LF_GOLD }
		local PX, PZ = 2.4, 0.4
		-- core mound: stepped blocks
		B:block(root, v(3.4, 0.5, 2.8), cf(PX, 0.25, PZ, 0, 10, 0), LF_OR_DK)
		B:block(root, v(2.6, 0.5, 2.2), cf(PX + 0.1, 0.7, PZ + 0.05, 0, -14, 0), LF_RED)
		B:block(root, v(1.6, 0.45, 1.5), cf(PX - 0.1, 1.1, PZ, 0, 20, 0), LF_GOLD)
		-- chunky rotated leaf cubes on the mound
		local cubes = {
			{ -1.3, 0.55, -0.9, 0.9 }, { 1.4, 0.55, -0.8, 0.85 }, { 1.5, 0.5, 1.0, 0.8 }, { -1.2, 0.5, 1.1, 0.9 },
			{ 0.2, 0.6, -1.3, 0.8 }, { -0.5, 1.0, -0.4, 0.75 }, { 0.7, 1.0, 0.5, 0.75 }, { 0.1, 1.4, 0.0, 0.65 },
			{ -1.8, 0.35, 0.1, 0.65 }, { 1.9, 0.35, 0.0, 0.6 },
		}
		for i, c in cubes do
			B:block(root, v(c[4], c[4] * 0.7, c[4]), cf(PX + c[1], c[2], PZ + c[3], jit(25), rnd() * 90, jit(25)), LEAF[(i - 1) % #LEAF + 1])
		end
		-- flat loose leaves scattered round the pile and the post
		for i, l in { { 4.6, -0.8 }, { 4.2, 1.9 }, { 0.6, -1.4 }, { 3.4, -1.9 }, { 1.2, 2.2 }, { -1.0, 1.0 }, { 5.0, 0.5 }, { -0.4, -1.6 } } do
			B:block(root, v(0.7, 0.12, 0.7), cf(l[1], 0.06 + (i % 3) * 0.03, l[2], 0, rnd() * 90, 0), LEAF[i])
			if i % 2 == 0 then
				B:block(root, v(0.18, 0.1, 0.4), cf(l[1] + 0.35, 0.1, l[2] + 0.3, 0, rnd() * 90, 0), BARK_LT)
			end
		end
		-- a plum leaf for a dash of Halloween purple
		B:block(root, v(0.75, 0.5, 0.75), cf(PX + 0.9, 1.05, PZ - 0.6, 18, 35, -12), LF_PLUM)
		-- tiny pumpkin tucked into the pile
		local pc = CFrame.new(PX + 0.9, 0.95, PZ - 1.35) * CFrame.Angles(rad(-6), rad(-20), rad(4))
		B:block(root, v(1.1, 0.85, 0.8), pc, PUMP_DK)
		B:block(root, v(0.8, 0.89, 1.1), pc, PUMP)
		B:block(root, v(0.55, 0.12, 0.55), pc * CFrame.new(0, 0.46, 0), PUMP_LT)
		B:block(root, v(0.2, 0.4, 0.2), pc * CFrame.new(0.03, 0.62, 0) * CFrame.Angles(0, 0, rad(12)), STEM)
		B:block(root, v(0.5, 0.1, 0.35), pc * CFrame.new(0.25, 0.52, 0.05) * CFrame.Angles(0, rad(30), rad(-10)), VINE)

		------------------------------------------------------------ leaf rake leaning on the post
		-- handle foot on the ground, fan head up against the post
		local r0, r1 = v(-3.0, 0.1, -1.1), v(-1.3, 3.65, -0.6)
		B:bar(root, r0, r1, 0.24, 0.24, WOOD_LT)
		B:block(root, v(0.32, 0.25, 0.32), CFrame.new(r0 + v(0, 0.12, 0)), WOOD)
		local dir = (r1 - r0).Unit
		local hc = CFrame.lookAt(r1, r1 + dir) -- -Z along the handle
		local hb = hc * CFrame.Angles(rad(-90), 0, 0) -- +Y along the handle
		B:block(root, v(0.5, 0.28, 0.3), hb, WOOD)
		B:block(root, v(1.7, 0.22, 0.24), hb * CFrame.new(0, 0.25, 0), WOOD)
		for i = -3, 3 do
			local a = i * 13
			B:block(root, v(0.12, 1.1, 0.12), hb * CFrame.new(i * 0.24, 0.3, 0) * CFrame.Angles(0, 0, rad(-a)) * CFrame.new(0, 0.55, 0), i % 2 == 0 and WOOD_LT or WOOD)
		end
		B:block(root, v(2.3, 0.14, 0.16), hb * CFrame.new(0, 1.0, 0), WOOD_LT)
		-- a leaf caught in the tines
		B:block(root, v(0.5, 0.5, 0.12), hb * CFrame.new(0.35, 0.8, -0.1) * CFrame.Angles(0, 0, rad(30)), LF_RED)
	end,
}
