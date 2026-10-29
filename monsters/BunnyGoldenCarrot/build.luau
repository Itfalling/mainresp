--!nocheck
-- Golden Carrot Tree (Bunny Stage plant #7, Secret): the bunny bouncer's dream.
-- A chunky brown tree on a stepped dirt mound, its crown a cluster of big
-- rotated studded leaf cubes in three greens with gold leaf cubes mixed in,
-- hung with shiny GOLD CARROTS (stepped, tapering, green leafy tops). A gold
-- bling band wraps the trunk, gold carrot shoulders peek out of the soil.
-- Neon only on small carrot glints. Static prop: no motion.luau.
return {
	DisplayName = "Golden Carrot Tree",
	Rarity = "Secret",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad

		-- palette ---------------------------------------------------------
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#55311b", "#472815", "#6e4024", "#8a552f"
		local GRASS, GRASS_DK = "#4fc23a", "#33962c"
		local BARK, BARK_DK, BARK_LT = "#7a4a26", "#5c351a", "#93603a"
		local LEAF_DK, LEAF, LEAF_LT = "#2f9a38", "#4cc447", "#86e255"
		local GLEAF, GLEAF_DK = "#ffd23f", "#e8a91f"
		local GOLD, GOLD_DK, GOLD_LT, GOLD_N = "#ffd633", "#e9a619", "#fff07a", "#fffbd6"
		local STEM, STEM_LT = "#3faa3a", "#6fd64a"

		-- deterministic jitter
		local seed = 7
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end

		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local crop = B:bone("Crop", "Root", v(0, 0, 0))
		local S = { name = "Soil" }

		------------------------------------------------------------------
		-- STEPPED DIRT MOUND (3 tiers + chunky irregular edge blocks)
		------------------------------------------------------------------
		local function oct(y0, y1, w, color)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(soil, v(w, h, w * 0.62), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.62, h + 0.02, w), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.84, h - 0.03, w * 0.84), cf(0, y, 0), color, S)
		end
		oct(0, 0.9, 12.4, DIRT_DK)
		oct(0.9, 1.7, 8.8, DIRT)
		oct(1.7, 2.3, 5.6, DIRT_LT)
		-- chunky edge blocks around the bottom ring
		for i = 0, 10 do
			local a = i * (360 / 11) + jit(5)
			local r = 5.9 + jit(0.3)
			local x, z = math.cos(rad(a)) * r, math.sin(rad(a)) * r
			local h = 0.9 + rnd() * 0.6
			B:block(soil, v(2.6 + rnd() * 0.6, h, 1.9 + rnd() * 0.4), cf(x, h / 2, z, 0, -a + jit(10), 0), i % 3 == 0 and DIRT or (i % 2 == 0 and DIRT_DK2 or DIRT_DK), S)
		end
		-- second-tier lumps
		for i = 0, 5 do
			local a = i * 60 + 15 + jit(8)
			local r = 4.2 + jit(0.3)
			local x, z = math.cos(rad(a)) * r, math.sin(rad(a)) * r
			local h = 0.7 + rnd() * 0.4
			B:block(soil, v(2.0 + rnd() * 0.5, h, 1.6), cf(x, 0.9 + h / 2, z, 0, -a + jit(12), 0), i % 2 == 0 and DIRT or DIRT_DK, S)
		end
		-- tiny grass blocks around the foot
		for _, g in { { -6.9, 2.4, 1.1 }, { -6.3, 3.1, 0.7 }, { 5.6, -4.6, 0.9 }, { 6.1, -3.8, 0.6 }, { 1.8, 6.8, 0.8 }, { -3.6, -6.0, 0.7 } } do
			B:block(soil, v(0.6, g[3], 0.6), cf(g[1], g[3] / 2, g[2], 0, jit(20), 0), (g[3] > 0.8) and GRASS or GRASS_DK, S)
		end
		-- gold carrot shoulders + tops peeking out of the soil
		for _, c in { { 3.3, -2.1, 25 }, { -3.0, -2.6, -15 }, { -1.2, 3.6, 40 } } do
			local x, z, yaw = c[1], c[2], c[3]
			B:block(soil, v(1.0, 0.6, 1.0), cf(x, 1.95, z, 0, yaw, 0), GOLD, S)
			B:block(soil, v(0.7, 0.2, 0.7), cf(x, 2.35, z, 0, yaw, 0), GOLD_DK, S)
			B:block(soil, v(0.25, 1.0, 0.25), cf(x - 0.15, 2.9, z, 0, yaw, 14), STEM, S)
			B:block(soil, v(0.25, 0.8, 0.25), cf(x + 0.2, 2.8, z + 0.1, 12, yaw, -18), STEM_LT, S)
		end
		-- a couple of gold nuggets on the mound
		for _, n in { { 4.8, 1.8 }, { -4.4, 1.6 }, { 0.9, -4.7 } } do
			B:block(soil, v(0.7, 0.45, 0.6), cf(n[1], 1.85, n[2], 0, jit(40), 0), GOLD_DK, S)
			B:block(soil, v(0.4, 0.25, 0.35), cf(n[1] + 0.05, 2.15, n[2], 0, jit(40), 0), GOLD_LT, S)
		end

		------------------------------------------------------------------
		-- CHUNKY TRUNK: stepped flare collars, tapering, gold bling band
		------------------------------------------------------------------
		B:block(crop, v(4.6, 0.9, 4.6), cf(0, 2.7, 0, 0, 8, 0), BARK_DK)
		B:block(crop, v(3.8, 0.9, 3.8), cf(0, 3.5, 0, 0, -6, 0), BARK)
		B:block(crop, v(3.2, 1.0, 3.2), cf(0, 4.4, 0, 0, 4, 0), BARK_DK)
		-- root feet running down the mound
		for k = 0, 3 do
			local a = k * 90 + 45
			local c, s = math.cos(rad(a)), math.sin(rad(a))
			B:block(crop, v(2.0, 0.9, 1.2), cf(c * 2.5, 2.55, s * 2.5, 0, -a, 0), BARK)
			B:block(crop, v(1.2, 0.6, 1.0), cf(c * 3.6, 2.2, s * 3.6, 0, -a, 0), BARK_DK)
		end
		B:block(crop, v(3.0, 3.0, 3.0), cf(0, 6.3, 0), BARK)
		-- gold bling band (chain of links) wrapping the trunk
		B:block(crop, v(3.2, 0.5, 3.2), cf(0, 6.0, 0), GOLD_DK)
		for k = 0, 3 do
			local a = k * 90
			local c, s = math.cos(rad(a)), math.sin(rad(a))
			B:block(crop, v(0.7, 0.7, 0.4), cf(c * 1.7, 6.0, s * 1.7, 0, -a + 90, 0), GOLD)
		end
		B:block(crop, v(2.6, 2.8, 2.6), cf(0.1, 8.9, 0, 0, 10, 4), BARK)
		B:block(crop, v(1.6, 0.6, 0.5), cf(-0.4, 7.9, -1.4, 0, 10, 0), BARK_LT) -- bark patches
		B:block(crop, v(0.5, 1.2, 1.3), cf(1.5, 5.4, 0.4), BARK_DK)
		B:block(crop, v(1.0, 1.4, 0.5), cf(0.6, 9.4, 1.32, 0, 10, 4), BARK_DK)

		-- branches of angled blocks reaching into the canopy
		local function branch(a, len, tilt, y)
			local c, s = math.cos(rad(a)), math.sin(rad(a))
			local r = len / 2 * math.sin(rad(tilt))
			local h = len / 2 * math.cos(rad(tilt))
			-- block whose long axis is Y, tilted outward
			local base = CFrame.new(c * (0.6 + r), y + h, s * (0.6 + r)) * CFrame.Angles(0, rad(-a), 0) * CFrame.Angles(0, 0, rad(-tilt))
			B:block(crop, v(1.3, len, 1.3), base, BARK)
			return v(c * (0.6 + 2 * r), y + 2 * h, s * (0.6 + 2 * r))
		end
		branch(10, 4.8, 55, 9.4)
		branch(140, 4.6, 52, 9.0)
		branch(250, 4.4, 50, 9.8)
		branch(320, 3.8, 34, 10.4)
		B:block(crop, v(1.8, 3.0, 1.8), cf(0, 11.8, 0, 0, 25, 0), BARK)

		------------------------------------------------------------------
		-- CANOPY: big rotated studded leaf cubes, three greens + gold
		------------------------------------------------------------------
		local CY = 12.3
		local cubes = {}
		local function leaf(x, y, z, s, col)
			B:block(crop, v(s, s, s), cf(x, y, z, jit(24), rnd() * 90, jit(24)), col)
			table.insert(cubes, { x = x, y = y, z = z, s = s })
		end
		-- inner core (dark)
		leaf(0, CY - 0.2, 0, 6.0, LEAF_DK)
		leaf(0.4, CY + 1.2, 0.3, 5.4, LEAF)
		-- lower ring: wide, mostly green, two gold cubes
		local ringCol = { LEAF, LEAF_DK, LEAF_LT, GLEAF, LEAF, LEAF_DK, LEAF_LT, LEAF, LEAF_DK }
		for i = 0, 8 do
			local a = i * 40 + 10 + jit(6)
			local r = 4.9 + jit(0.4)
			local s = ringCol[i + 1] == GLEAF and 3.4 or 4.0 + rnd() * 0.8
			leaf(math.cos(rad(a)) * r, CY - 0.2 + jit(0.4), math.sin(rad(a)) * r, s, ringCol[i + 1])
		end
		-- upper ring
		local upCol = { LEAF_LT, LEAF, GLEAF_DK, LEAF_LT, GLEAF, LEAF_DK }
		for i = 0, 5 do
			local a = i * 60 + 35 + jit(8)
			local r = 3.2 + jit(0.3)
			local s = (upCol[i + 1] == GLEAF_DK or upCol[i + 1] == GLEAF) and 3.0 or 3.8 + rnd() * 0.6
			leaf(math.cos(rad(a)) * r, CY + 2.2 + jit(0.3), math.sin(rad(a)) * r, s, upCol[i + 1])
		end
		-- crown
		leaf(0.3, CY + 3.3, -0.2, 3.6, LEAF_LT)
		leaf(-1.4, CY + 2.8, 1.4, 2.6, GLEAF)

		------------------------------------------------------------------
		-- GOLD CARROTS: stepped tapering carrots hanging under the crown
		------------------------------------------------------------------
		local nGlint = 0
		local glints = {}
		local function carrot(x, yTop, z, len, tilt)
			local yaw = math.atan2(-x, -z) -- local -Z faces outward
			local base = CFrame.new(x, yTop, z) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(rad(tilt), 0, 0)
			-- leafy top going up into the canopy
			B:block(crop, v(0.35, 1.6, 0.35), base * CFrame.new(-0.2, 0.7, 0) * CFrame.Angles(0, 0, rad(22)), STEM)
			B:block(crop, v(0.35, 1.7, 0.35), base * CFrame.new(0, 0.8, -0.1) * CFrame.Angles(rad(-12), 0, 0), STEM_LT)
			B:block(crop, v(0.35, 1.5, 0.35), base * CFrame.new(0.2, 0.7, 0) * CFrame.Angles(0, 0, rad(-22)), STEM)
			-- stepped tapering body (pointing down)
			local k = len / 3.05
			local segs = { { 1.4, 0.62, GOLD }, { 1.12, 0.66, GOLD_LT }, { 0.85, 0.62, GOLD }, { 0.58, 0.58, GOLD_DK }, { 0.32, 0.55, GOLD_LT } }
			local y = 0
			for i, sg in segs do
				local w, h = sg[1] * k, sg[2] * k
				y -= h / 2
				B:block(crop, v(w, h + 0.02, w), base * CFrame.new(0, y, 0) * CFrame.Angles(0, rad(i * 9), 0), sg[3])
				y -= h / 2
			end
			-- carrot ridges
			B:block(crop, v(1.48 * k, 0.14, 0.5 * k), base * CFrame.new(0, -0.55 * k, -0.35 * k), GOLD_DK)
			-- shiny glint on the outward face
			nGlint += 1
			local g = B:block(crop, v(0.22, 0.42 * k, 0.1), base * CFrame.new(-0.3 * k, -0.45 * k, -0.64 * k), GOLD_N, { mat = "Neon", name = "Glint" .. nGlint })
			table.insert(glints, g)
		end
		-- hanging below the lower ring, tips leaning out into the light
		local hang = {
			{ 15, 6.3, 9.8, 3.4 }, { 62, 5.9, 10.1, 3.0 }, { 105, 6.4, 9.7, 3.5 }, { 150, 6.0, 10.0, 3.1 },
			{ 200, 6.4, 9.7, 3.4 }, { 245, 5.9, 10.2, 3.0 }, { 290, 6.4, 9.7, 3.3 }, { 335, 6.0, 10.1, 3.1 },
		}
		for _, h in hang do
			local a = rad(h[1])
			carrot(math.cos(a) * h[2], h[3], math.sin(a) * h[2], h[4], 22 + jit(6))
		end
		-- carrots poking out of the crown (half sunk, pointing out + down)
		local poke = {
			{ 40, 6.6, CY + 0.9, 2.5, 62 }, { 125, 6.7, CY + 0.6, 2.6, 58 }, { 218, 6.6, CY + 1.0, 2.5, 64 },
			{ 312, 6.7, CY + 0.7, 2.6, 60 }, { 0, 4.8, CY + 3.2, 2.2, 52 }, { 165, 4.8, CY + 3.4, 2.2, 50 },
			{ 265, 4.7, CY + 3.1, 2.2, 54 }, { 85, 4.9, CY + 3.3, 2.1, 48 },
		}
		for _, q in poke do
			local a = rad(q[1] + jit(6))
			carrot(math.cos(a) * q[2], q[3], math.sin(a) * q[2], q[4], q[5])
		end

		------------------------------------------------------------------
		-- VFX: golden sparkles + soft glow
		------------------------------------------------------------------
		local core = cubes[1]
		B:emitter(glints[1], "sparkle", { name = "GoldSparkle", color = { "#fff6c0", "#ffd23a" }, rate = 4, size = 0.4 })
		B:emitter(glints[5], "sparkle", { name = "GoldSparkle2", color = { "#ffffff", "#ffe27a" }, rate = 3, size = 0.35 })
		local glowPart = B:block(crop, v(0.4, 0.4, 0.4), cf(core.x, core.y - 1.0, core.z), LEAF_DK, { name = "GlowCore" })
		B:emitter(glowPart, "glow", { name = "GoldGlow", color = "#ffd84a", rate = 2, size = { 2.5, 0 } })
		B:light(glowPart, { color = "#ffd36b", brightness = 1.2, range = 14, name = "GoldLight" })
	end,
}
