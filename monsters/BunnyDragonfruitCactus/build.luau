--!nocheck
-- Neon Dragonfruit Cactus (Bunny Stage plant #8, Cosmic): a club-neon cactus
-- built like the volcano-tree reference: stacked stepped teal tiers with darker
-- ribs, pale spines and thin glowing pink/cyan seams, two stepped saguaro arms
-- and a crown of branching tips, every tip carrying a hot-pink DRAGONFRUIT
-- with green flame-scale flaps whose tips glow lime. Stepped dirt mound with a
-- few glowing club pebbles. Static prop: no motion.luau.
return {
	DisplayName = "Neon Dragonfruit Cactus",
	Rarity = "Cosmic",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad

		-- palette ---------------------------------------------------------
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#52301b", "#432614", "#6c3f24", "#87522e"
		local GRASS, GRASS_DK = "#4fc23a", "#33962c"
		local TEAL, TEAL_MID, TEAL_DK, TEAL_LT = "#14ccb4", "#10b5a4", "#09706c", "#62f2d8"
		local SPINE = "#f4f0d8"
		local PINK_N, CYAN_N = "#ff3fb4", "#4ff3ff"
		local DRAG, DRAG_DK, DRAG_LT = "#ff2e93", "#d4126f", "#ff7cc0"
		local SCALE, SCALE_DK, LIME_N = "#47d64a", "#2fa83a", "#b6ff3a"

		local seed = 8
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
		-- STEPPED DIRT MOUND
		------------------------------------------------------------------
		local function oct(y0, y1, w, color)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(soil, v(w, h, w * 0.62), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.62, h + 0.02, w), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.84, h - 0.03, w * 0.84), cf(0, y, 0), color, S)
		end
		oct(0, 0.9, 12.8, DIRT_DK)
		oct(0.9, 1.7, 9.4, DIRT)
		oct(1.7, 2.3, 7.4, DIRT_LT)
		for i = 0, 10 do
			local a = i * (360 / 11) + jit(5)
			local r = 6.1 + jit(0.3)
			local x, z = math.cos(rad(a)) * r, math.sin(rad(a)) * r
			local h = 0.9 + rnd() * 0.6
			B:block(soil, v(2.6 + rnd() * 0.6, h, 1.9 + rnd() * 0.4), cf(x, h / 2, z, 0, -a + jit(10), 0), i % 3 == 0 and DIRT or (i % 2 == 0 and DIRT_DK2 or DIRT_DK), S)
		end
		for i = 0, 5 do
			local a = i * 60 + 25 + jit(8)
			local r = 4.5 + jit(0.3)
			local x, z = math.cos(rad(a)) * r, math.sin(rad(a)) * r
			local h = 0.7 + rnd() * 0.4
			B:block(soil, v(2.0 + rnd() * 0.5, h, 1.6), cf(x, 0.9 + h / 2, z, 0, -a + jit(12), 0), i % 2 == 0 and DIRT or DIRT_DK, S)
		end
		for _, g in { { -7.0, 2.2, 1.1 }, { -6.4, 3.0, 0.7 }, { 5.7, -4.6, 0.9 }, { 6.2, -3.7, 0.6 }, { 1.6, 6.9, 0.8 }, { -3.8, -6.0, 0.7 } } do
			B:block(soil, v(0.6, g[3], 0.6), cf(g[1], g[3] / 2, g[2], 0, jit(20), 0), (g[3] > 0.8) and GRASS or GRASS_DK, S)
		end
		-- glowing club pebbles on the mound
		for i, p in { { 4.4, 2.2, PINK_N }, { -4.0, -2.4, CYAN_N }, { -1.6, 4.4, PINK_N }, { 2.2, -4.3, CYAN_N } } do
			B:block(soil, v(0.8, 0.4, 0.7), cf(p[1], 1.85, p[2], 0, jit(40), 0), DIRT_DK, S)
			B:block(soil, v(0.35, 0.3, 0.35), cf(p[1], 2.15, p[2], 0, jit(40), 0), p[3], { mat = "Neon", name = "Soil" })
		end

		------------------------------------------------------------------
		-- DRAGONFRUIT: hot-pink body, green flame scales with lime glow tips
		------------------------------------------------------------------
		local fruits = {}
		local function dragonfruit(base, s)
			B:block(crop, v(1.6, 1.9, 1.6) * s, base, DRAG)
			B:block(crop, v(1.7, 0.5, 1.7) * s, base * CFrame.new(0, -0.75 * s, 0), DRAG_DK)
			B:block(crop, v(0.6, 0.75, 0.1) * s, base * CFrame.new(-0.3 * s, 0.25 * s, -0.82 * s), DRAG_LT)
			-- four scale flaps flaring up + out, glowing lime tips
			for k = 0, 3 do
				local a = k * 90 + 45
				local h = (k % 2 == 0) and 0.1 or -0.35
				local flap = base * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, h * s, -0.8 * s) * CFrame.Angles(rad(-35), 0, 0)
				B:block(crop, v(0.5, 1.1, 0.25) * s, flap * CFrame.new(0, 0.3 * s, 0), k % 2 == 0 and SCALE or SCALE_DK)
				B:block(crop, v(0.26, 0.32, 0.26) * s, flap * CFrame.new(0, 0.95 * s, 0), LIME_N, { mat = "Neon" })
			end
			-- flame tuft on top
			B:block(crop, v(0.4, 0.9, 0.4) * s, base * CFrame.new(-0.3 * s, 1.25 * s, 0) * CFrame.Angles(0, 0, rad(25)), SCALE)
			B:block(crop, v(0.45, 1.1, 0.45) * s, base * CFrame.new(0, 1.35 * s, 0), SCALE)
			local tip = B:block(crop, v(0.3, 0.36, 0.3) * s, base * CFrame.new(0, 2.0 * s, 0), LIME_N, { mat = "Neon" })
			table.insert(fruits, tip)
		end

		------------------------------------------------------------------
		-- STACKED STEPPED TEAL TIERS (volcano-ref structure)
		------------------------------------------------------------------
		local tiers = { { 7.4, 2.1 }, { 6.4, 2.0 }, { 5.4, 1.9 }, { 4.5, 1.8 }, { 3.6, 1.7 }, { 2.8, 1.5 } }
		local y = 2.3
		local tierInfo = {}
		for i, t in tiers do
			local w, h = t[1], t[2]
			local yaw = (i % 2 == 0) and 6 or -4
			local c = CFrame.new(0, y + h / 2, 0) * CFrame.Angles(0, rad(yaw), 0)
			B:block(crop, v(w, h, w), c, i % 2 == 0 and TEAL_MID or TEAL)
			-- light ledge on top
			B:block(crop, v(w - 0.3, 0.22, w - 0.3), c * CFrame.new(0, h / 2 + 0.06, 0), TEAL_LT)
			for f = 0, 3 do
				local face = c * CFrame.Angles(0, rad(f * 90), 0)
				local d = w / 2
				-- two darker ribs per face
				-- dark rib + inset panel (like the volcano ref's dark windows)
				local rx = ((i + f) % 2 == 0) and -w * 0.26 or w * 0.26
				B:block(crop, v(0.7, h - 0.3, 0.4), face * CFrame.new(rx, 0, -d - 0.12), TEAL_DK)
				-- pale spine poking out of a rib
				local sx = rx
				local sy = ((i + f) % 2 == 0) and 0.4 or -0.3
				B:block(crop, v(0.16, 0.16, 0.6), face * CFrame.new(sx, sy, -d - 0.55) * CFrame.Angles(rad(-15), 0, 0), SPINE)
				-- glowing seam dash along the bottom edge (alternating pink / cyan)
				local col = ((i + f) % 3 == 0) and CYAN_N or PINK_N
				B:block(crop, v(w * 0.34, 0.22, 0.12), face * CFrame.new(-rx * 0.6, -h / 2 + 0.32, -d - 0.04), col, { mat = "Neon", name = "Seam" })
				-- a little vertical seam dash
				if (i + f) % 2 == 1 then
					B:block(crop, v(0.2, h * 0.45, 0.12), face * CFrame.new(-rx * 0.15, h * 0.12, -d - 0.04), col, { mat = "Neon", name = "Seam" })
				end
			end
			tierInfo[i] = { y0 = y, y1 = y + h, w = w, cf = c }
			y += h
		end
		local topY = y -- ~15

		------------------------------------------------------------------
		-- STEPPED SAGUARO ARMS
		------------------------------------------------------------------
		local function arm(a, ti, out, up, s)
			local t = tierInfo[ti]
			local yy = (t.y0 + t.y1) / 2
			local face = CFrame.new(0, yy, 0) * CFrame.Angles(0, rad(a), 0)
			local d = t.w / 2
			B:block(crop, v(1.7, 1.6, out), face * CFrame.new(0, 0, -d - out / 2 + 0.3), TEAL)
			B:block(crop, v(2.0, 2.0, 2.0), face * CFrame.new(0, 0.2, -d - out - 0.6), TEAL_MID)
			B:block(crop, v(1.7, up, 1.7), face * CFrame.new(0, 1.2 + up / 2, -d - out - 0.6), TEAL)
			B:block(crop, v(0.5, up - 0.3, 0.3), face * CFrame.new(0, 1.2 + up / 2, -d - out - 1.5), TEAL_DK)
			B:block(crop, v(0.3, up - 0.3, 0.5), face * CFrame.new(0.9, 1.2 + up / 2, -d - out - 0.6), TEAL_DK)
			B:block(crop, v(1.4, 0.8, 1.4), face * CFrame.new(0, 1.6 + up, -d - out - 0.6), TEAL_LT)
			B:block(crop, v(0.12, up * 0.5, 0.12), face * CFrame.new(-0.4, 1.0 + up / 2, -d - out - 1.48), PINK_N, { mat = "Neon", name = "Seam" })
			B:block(crop, v(0.16, 0.16, 0.6), face * CFrame.new(-0.86, 1.6 + up * 0.3, -d - out - 1.3) * CFrame.Angles(0, rad(-30), 0), SPINE)
			dragonfruit(face * CFrame.new(0, 2.0 + up + 0.95 * s, -d - out - 0.6) * CFrame.Angles(0, rad(20), 0), s)
		end
		arm(60, 2, 2.2, 3.0, 1.0)
		arm(215, 3, 2.0, 2.4, 0.95)
		arm(320, 1, 1.6, 1.4, 0.85)

		------------------------------------------------------------------
		-- CROWN: branching tips fanning up out of the top tier
		------------------------------------------------------------------
		local function branch(a, tilt, len, s)
			local c = CFrame.new(0, topY - 0.6, 0) * CFrame.Angles(0, rad(a), 0) * CFrame.Angles(rad(-tilt), 0, 0)
			B:block(crop, v(1.3, len, 1.3), c * CFrame.new(0, len / 2, 0), TEAL)
			B:block(crop, v(1.0, 1.2, 1.0), c * CFrame.new(0, len * 0.55, 0) * CFrame.Angles(0, rad(45), 0), TEAL_MID)
			B:block(crop, v(0.4, len - 0.4, 0.3), c * CFrame.new(0, len / 2, -0.7), TEAL_DK)
			B:block(crop, v(0.12, len * 0.45, 0.1), c * CFrame.new(0.3, len * 0.55, -0.68), CYAN_N, { mat = "Neon", name = "Seam" })
			local tipC = c * CFrame.new(0, len, 0)
			B:block(crop, v(1.5, 0.5, 1.5), tipC, TEAL_LT)
			dragonfruit(tipC * CFrame.Angles(rad(tilt * 0.6), 0, 0) * CFrame.new(0, 0.95 * s + 0.2, 0), s)
		end
		branch(20, 42, 4.0, 0.85)
		branch(110, 48, 3.4, 0.8)
		branch(200, 40, 4.2, 0.85)
		branch(290, 50, 3.2, 0.8)
		-- crowning dragonfruit
		B:block(crop, v(2.0, 1.6, 2.0), cf(0, topY + 0.6, 0, 0, 30, 0), TEAL)
		B:block(crop, v(1.5, 1.0, 1.5), cf(0, topY + 1.8, 0, 0, 10, 0), TEAL_MID)
		B:block(crop, v(1.6, 0.5, 1.6), cf(0, topY + 2.4, 0, 0, 10, 0), TEAL_LT)
		dragonfruit(CFrame.new(0, topY + 3.6, 0) * CFrame.Angles(0, rad(15), 0), 1.15)

		------------------------------------------------------------------
		-- small dragonfruits nestled on the tier ledges
		------------------------------------------------------------------
		local function ledgeFruit(ti, a, s)
			local t = tierInfo[ti]
			local d = t.w / 2 - 0.15
			dragonfruit(t.cf * CFrame.Angles(0, rad(a), 0) * CFrame.new(0.4, (t.y1 - t.y0) / 2 + 0.95 * s, -d) * CFrame.Angles(0, rad(30), 0), s)
		end
		ledgeFruit(1, 140, 0.75)
		ledgeFruit(2, 290, 0.7)

		------------------------------------------------------------------
		-- VFX: pink + cyan club sparkles, soft pink light
		------------------------------------------------------------------
		B:emitter(fruits[#fruits - 3], "sparkle", { name = "ClubSparkle", color = { "#ff7cd6", "#7cf6ff" }, rate = 4, size = 0.45 })
		B:emitter(fruits[1], "sparkle", { name = "ClubSparkle2", color = { "#ffffff", "#ff5ce1" }, rate = 3, size = 0.35 })
		B:emitter(fruits[3], "sparkle", { name = "ClubSparkle3", color = { "#b98cff", "#7cf6ff" }, rate = 2, size = 0.35 })
		local core = B:block(crop, v(0.4, 0.4, 0.4), cf(0, topY + 1.2, 0), TEAL, { name = "GlowCore" })
		B:emitter(core, "glow", { name = "NeonGlow", color = { "#ff3fb4", "#4ff3ff" }, rate = 2, size = { 3, 0 } })
		B:light(core, { color = "#ff6ad0", brightness = 1.3, range = 16, name = "NeonLight" })
	end,
}
