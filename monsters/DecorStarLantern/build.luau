--!nocheck
-- Constellation Lantern (Starlight Ruins decoration, medium).
-- A star-topped temple lantern post for lining paths through the ruins:
-- * footing: an indigo star tile with gold inlay, a stepped white-stone
--   plinth with gold trim, a few worn slabs, moss, grass tufts, star dust and
--   a little violet/cyan crystal sprout
-- * an octagonal fluted white post with gold bands and glowing rune dots
-- * the LANTERN: a gold-framed box whose four dark-indigo panels each carry
--   a glowing CONSTELLATION (neon star dots joined by fine gold lines), a
--   glowing cyan core peeking out under the roof
-- * a stepped white-and-gold roof crowned by a chunky 3D gold STAR with a
--   glowing heart
-- * VFX: soft star twinkles round the lantern + one soft light. Static.
-- Blocks only (no wedges / round parts).
return {
	DisplayName = "Constellation Lantern",
	Rarity = "Decor",
	Element = "Starlight Ruins",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		-- palette (Starlight Ruins crops) -----------------------------------
		local STONE, STONE2, STONE_DK, STONE_LT, STONE_HI = "#e3dcef", "#d0c7e2", "#a99fc2", "#f4f0fb", "#fbf9ff"
		local GOLD, GOLD_DK, GOLD_LT = "#f2c24f", "#c9952e", "#ffe08a"
		local MOSS, MOSS_DK, MOSS_LT = "#4f9e7c", "#367a62", "#78c79a"
		local TILE_DK, TILE, PANEL = "#2a2550", "#3b3566", "#2c2470"
		local RUNE = "#7fe8ff"
		local STAR_W = "#f4fbff"
		local DUST_G, DUST_C = "#ffe27a", "#b8f4ff"
		local VIO_DK, VIO, VIO_LT = "#7a58ea", "#9b7cff", "#c6b4ff"
		local CY, CY_LT, CORE_C = "#4fd8f2", "#a8f3ff", "#c4fbff"
		local GRASS, GRASS_DK = "#8ea9dc", "#6f87c2"
		local NEON = { mat = "Neon" }

		local seed = 22901
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		-- octagonal prism (vertical), width w, from y0 height h
		local function oct(x, z, y0, h, w, col, col2, yaw)
			local c = cf(x, y0 + h / 2, z, 0, yaw or 0, 0)
			B:block(R, v(w, h, 0.42 * w), c, col)
			B:block(R, v(0.42 * w, h - 0.02, w), c, col)
			B:block(R, v(0.72 * w, h - 0.04, 0.72 * w), c * ang(0, 45, 0), col2 or col)
			return c
		end

		------------------------------------------------------------------
		-- FOOTING
		------------------------------------------------------------------
		B:block(R, v(4.4, 0.3, 4.4), cf(0, 0.15, 0, 0, 0, 0), TILE)
		for k = 0, 3 do -- gold inlay border
			B:block(R, v(4.0, 0.08, 0.16), cf(0, 0.32, 0, 0, k * 90, 0) * CFrame.new(0, 0, -1.95), GOLD)
		end
		-- worn slabs around the tile
		for _, s in { { -2.9, -1.4, 1.8, 1.6, 10, STONE2 }, { 2.7, 1.9, 1.6, 1.4, -14, STONE }, { 1.6, -2.8, 1.5, 1.2, 25, STONE_LT }, { -2.4, 2.6, 1.4, 1.3, -30, TILE_DK } } do
			B:block(R, v(s[3], 0.32, s[4]), cf(s[1], 0.16, s[2], 0, s[5], 0), s[6])
		end
		-- stepped plinth
		B:block(R, v(3.0, 0.8, 3.0), cf(0, 0.7, 0), STONE_DK)
		B:block(R, v(3.12, 0.14, 3.12), cf(0, 1.1, 0), GOLD)
		B:block(R, v(2.5, 0.45, 2.5), cf(0, 1.3, 0), STONE)
		B:block(R, v(1.9, 0.5, 1.9), cf(0, 1.75, 0), STONE_LT)
		-- rune star on the plinth front
		B:block(R, v(0.4, 0.4, 0.1), cf(0, 0.7, -1.52, 0, 0, 45), RUNE, { mat = "Neon", name = "PlinthRune" })
		B:block(R, v(1.2, 0.1, 0.08), cf(0, 0.7, -1.51), GOLD)

		------------------------------------------------------------------
		-- POST
		------------------------------------------------------------------
		local P0, P1 = 2.0, 5.2
		oct(0, 0, P0, P1 - P0, 1.3, STONE_LT, STONE2)
		for f = 0, 3 do -- flute ribs
			B:block(R, v(0.2, P1 - P0 - 0.6, 0.12), cf(0, (P0 + P1) / 2, 0, 0, 45 + f * 90, 0) * CFrame.new(0, 0, -0.5), STONE_HI)
		end
		for _, y in { P0 + 0.45, P1 - 0.45 } do
			B:block(R, v(1.42, 0.28, 1.42), cf(0, y, 0), GOLD)
		end
		for i, y in { 3.0, 3.7, 4.4 } do
			B:block(R, v(0.24, 0.24, 0.1), cf(0, y, -0.6, 0, 0, 45), RUNE, { mat = "Neon", name = "PostRune" .. i })
		end
		-- moss creeping up the post + on the plinth
		B:block(R, v(0.5, 1.6, 0.22), cf(0.25, P0 + 0.7, 0.62, 0, 0, 0), MOSS_DK)
		B:block(R, v(1.4, 0.22, 0.9), cf(-0.6, 2.05, 0.7, 0, 15, 0), MOSS)
		B:block(R, v(1.0, 0.2, 0.7), cf(1.1, 1.58, -0.9, 0, -20, 0), MOSS_LT)
		B:block(R, v(0.9, 0.7, 0.22), cf(1.25, 1.1, -1.4, -10, -20, 0), MOSS)

		------------------------------------------------------------------
		-- LANTERN HEAD
		------------------------------------------------------------------
		local H0 = P1
		B:block(R, v(2.2, 0.35, 2.2), cf(0, H0 + 0.17, 0), STONE)
		B:block(R, v(2.8, 0.35, 2.8), cf(0, H0 + 0.5, 0), STONE_LT)
		B:block(R, v(2.92, 0.12, 2.92), cf(0, H0 + 0.7, 0), GOLD)
		local C0, C1 = H0 + 0.68, H0 + 3.3 -- cage
		local CH = C1 - C0
		local CM = (C0 + C1) / 2
		-- glowing core (visible in the gap under the roof)
		B:block(R, v(1.1, 0.6, 1.1), cf(0, C1 - 0.1, 0, 0, 45, 0), CORE_C, { mat = "Neon", name = "LanternCore" })
		-- corner posts
		for _, sx in { -1, 1 } do
			for _, sz in { -1, 1 } do
				B:block(R, v(0.42, CH, 0.42), cf(sx * 1.12, CM, sz * 1.12), GOLD)
				B:block(R, v(0.5, 0.3, 0.5), cf(sx * 1.12, C0 + 0.15, sz * 1.12), GOLD_DK)
			end
		end
		-- four constellation panels
		local consts = {
			{ { -0.6, 0.75 }, { -0.15, 0.35 }, { 0.45, 0.6 }, { 0.2, -0.25 }, { -0.45, -0.7 } }, -- front
			{ { -0.6, -0.6 }, { -0.2, 0.1 }, { 0.3, 0.7 }, { 0.6, -0.2 } }, -- right
			{ { -0.55, 0.6 }, { 0.05, 0.75 }, { 0.55, 0.3 }, { 0.0, -0.3 }, { 0.4, -0.75 } }, -- back
			{ { -0.5, -0.7 }, { -0.5, 0.0 }, { 0.1, 0.35 }, { 0.55, 0.8 } }, -- left
		}
		for k = 0, 3 do
			local F = CFrame.new(0, CM, 0) * CFrame.Angles(0, math.rad(-k * 90), 0) * CFrame.new(0, 0.1, -1.08)
			B:block(R, v(1.85, CH - 0.5, 0.2), F, PANEL)
			-- top + bottom gold rails
			B:block(R, v(1.9, 0.16, 0.26), F * CFrame.new(0, (CH - 0.5) / 2, -0.02), GOLD_LT)
			B:block(R, v(1.9, 0.16, 0.26), F * CFrame.new(0, -(CH - 0.5) / 2, -0.02), GOLD_LT)
			local pts = consts[k + 1]
			local prev
			for i, q in pts do
				local p = F * CFrame.new(q[1], q[2], -0.13)
				local big = (i == 1 or i == #pts)
				local sz = big and 0.32 or 0.24
				B:block(R, v(sz, sz, 0.08), p * ang(0, 0, 45), (i == 2) and STAR_W or RUNE, { mat = "Neon", name = ("Const%d_%d"):format(k + 1, i) })
				if prev then
					local c, len = P.aim(prev.Position, p.Position, F.LookVector)
					B:block(R, v(0.07, 0.07, len), c * CFrame.new(0, 0, 0) + F.LookVector * 0.02, GOLD)
				end
				prev = p
			end
		end

		------------------------------------------------------------------
		-- ROOF + STAR
		------------------------------------------------------------------
		local R0 = C1 + 0.25 -- small gap above the cage shows the core glow
		for _, sx in { -1, 1 } do
			for _, sz in { -1, 1 } do
				B:block(R, v(0.42, 0.3, 0.42), cf(sx * 1.12, C1 + 0.12, sz * 1.12), GOLD)
			end
		end
		B:block(R, v(3.2, 0.4, 3.2), cf(0, R0 + 0.2, 0), STONE)
		B:block(R, v(3.32, 0.12, 3.32), cf(0, R0 + 0.06, 0), GOLD)
		B:block(R, v(2.5, 0.45, 2.5), cf(0, R0 + 0.62, 0), STONE_LT)
		B:block(R, v(2.6, 0.12, 2.6), cf(0, R0 + 0.86, 0), GOLD)
		B:block(R, v(1.7, 0.45, 1.7), cf(0, R0 + 1.1, 0, 0, 45, 0), STONE)
		B:block(R, v(0.9, 0.5, 0.9), cf(0, R0 + 1.55, 0), GOLD)
		-- roof corner tips
		for _, sx in { -1, 1 } do
			for _, sz in { -1, 1 } do
				B:block(R, v(0.4, 0.35, 0.4), cf(sx * 1.45, R0 + 0.55, sz * 1.45), GOLD_LT)
			end
		end
		-- the STAR (8 points, built in the X-Y plane, thickened + a crossed copy)
		local SC = CFrame.new(0, R0 + 3.05, 0)
		-- stepped points: thick inner segment + thin tip, four long + four short
		for k = 0, 3 do
			local A = SC * ang(0, 0, k * 90)
			B:block(R, v(1.0, 0.7, 0.7), A * CFrame.new(0, 0.6, 0), GOLD)
			B:block(R, v(0.6, 0.65, 0.62), A * CFrame.new(0, 1.2, 0), GOLD)
			B:block(R, v(0.3, 0.55, 0.54), A * CFrame.new(0, 1.75, 0), GOLD_LT)
			local D = SC * ang(0, 0, 45 + k * 90)
			B:block(R, v(0.55, 0.6, 0.5), D * CFrame.new(0, 0.65, 0), GOLD_DK)
			B:block(R, v(0.26, 0.4, 0.44), D * CFrame.new(0, 1.1, 0), GOLD_DK)
		end
		B:block(R, v(1.2, 1.2, 0.8), SC * ang(0, 0, 45), GOLD_LT)
		B:block(R, v(0.62, 0.62, 0.9), SC * ang(0, 0, 45), STAR_W, { mat = "Neon", name = "StarHeart" })
		-- short stem holding the star
		B:block(R, v(0.45, 0.8, 0.45), cf(0, R0 + 1.95, 0), GOLD_DK)

		------------------------------------------------------------------
		-- small details at the base
		------------------------------------------------------------------
		do -- crystal sprout
			local base = CFrame.new(-1.9, 0.3, -1.2) * ang(0, 30, 0)
			B:block(R, v(0.55, 1.4, 0.55), base * CFrame.new(0, 0.55, 0) * ang(0, 45, 8), VIO)
			B:block(R, v(0.3, 0.4, 0.3), base * CFrame.new(0.1, 1.35, 0) * ang(0, 45, 8), VIO_LT)
			B:block(R, v(0.4, 0.9, 0.4), base * CFrame.new(0.45, 0.35, 0.1) * ang(0, 20, -26), CY)
			B:block(R, v(0.34, 0.7, 0.34), base * CFrame.new(-0.4, 0.28, 0.15) * ang(12, 55, 28), VIO_DK)
			B:block(R, v(0.24, 0.3, 0.24), base * CFrame.new(0.7, 0.8, 0.1) * ang(0, 20, -26), CY_LT)
		end
		for _, g in { { 2.1, -1.6 }, { -1.8, 1.9 }, { 2.0, 2.2 }, { -2.8, 0.4 } } do
			local base = CFrame.new(g[1], 0.3, g[2]) * ang(0, rnd(0, 90), 0)
			for k = -1, 1 do
				local h = (k == 0) and 1.1 or 0.8
				B:block(R, v(0.22, h, 0.26), base * ang(0, 0, k * 24) * CFrame.new(0, h / 2, 0), (k == 0) and GRASS or GRASS_DK)
			end
		end
		for _, d in { { 1.6, -1.9, DUST_G }, { -1.5, -2.0, DUST_C }, { 1.9, 1.3, DUST_G }, { -0.6, 2.0, DUST_C } } do
			B:block(R, v(0.26, 0.14, 0.26), cf(d[1], 0.36, d[2], 0, rnd(0, 90), 0), d[3])
		end
		B:block(R, v(0.7, 0.5, 0.8), cf(2.95, 0.5, -0.4, 6, 30, 10), STONE2)

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local fx = B:block(R, v(3.4, 3.4, 3.4), cf(0, CM + 0.4, 0), CY, { tr = 1, name = "LanternFx" })
		B:emitter(fx, "sparkle", { name = "StarTwinkle", color = { RUNE, STAR_W, GOLD_LT }, rate = 5, size = { 0.12, 0.38, 0 }, life = { 1.0, 1.8 }, speed = { 0.2, 0.6 }, light = 1 })
		B:emitter(fx, "glow", { name = "LanternGlow", color = { CORE_C, VIO_LT }, rate = 1.2, size = { 2.4, 3.4, 1.5 }, trans = { 0.84, 0.78, 1 }, light = 1 })
		B:light(fx, { name = "LanternLight", color = "#9fefff", brightness = 1.0, range = 14 })
	end,
}
