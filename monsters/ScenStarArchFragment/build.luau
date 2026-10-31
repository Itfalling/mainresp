--!nocheck
-- Broken Star Arch (Starlight Ruins scenery, big copy-paste filler).
-- Half of a ruined white-and-gold temple arch still standing:
-- * footing: flat worn white-violet paving slabs and indigo tiles with gold
--   inlay, silver-blue grass tufts, star-dust specks (no mound)
-- * the left pier stands tall: stepped plinth with a gold ring, stacked
--   courses in alternating tones, a recessed front panel carved with a gold
--   star, a gold-trimmed impost block
-- * the arch ring springs from it in big voussoir blocks (lighter outer
--   rim, gold inner trim) over the top, past a keystone with a gold star and
--   a tiny cyan rune, and breaks off in a jagged end
-- * the right pier is only a snapped stump; two fallen voussoirs lie on the
--   paving below the gap
-- * teal moss over the arch and pier tops with hanging strands, violet and
--   cyan crystal sprouts at the feet
-- Scenery filler: anchored, weld-free, no scripts, no effects, no motion.
return {
	DisplayName = "Broken Star Arch",
	Rarity = "Scenery",
	Filler = true,
	Element = "Starlight Ruins",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Starlight Ruins crops + decorations) ---------------------
		local STONE, STONE2, STONE_DK, STONE_LT, STONE_HI = "#e3dcef", "#d0c7e2", "#a99fc2", "#f4f0fb", "#fbf9ff"
		local GOLD, GOLD_DK, GOLD_LT = "#f2c24f", "#c9952e", "#ffe08a"
		local MOSS, MOSS_DK, MOSS_LT = "#4f9e7c", "#367a62", "#78c79a"
		local TILE_DK, TILE = "#2a2550", "#3b3566"
		local RUNE = "#7fe8ff"
		local DUST_G, DUST_C = "#ffe27a", "#b8f4ff"
		local VIO_DK, VIO, VIO_LT = "#7a58ea", "#9b7cff", "#c6b4ff"
		local CY, CY_LT = "#4fd8f2", "#a8f3ff"
		local GRASS, GRASS_DK = "#8ea9dc", "#6f87c2"
		local NEON = { mat = "Neon" }

		local seed = 55219
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		------------------------------------------------------------------
		-- FOOTING: paving slabs + indigo tiles (flat)
		------------------------------------------------------------------
		local slabs = {
			{ -5.4, 0.2, 4.0, 3.8, 3, STONE2 }, { -1.6, -0.2, 3.4, 3.4, -6, STONE }, { 1.9, 0.3, 3.4, 3.2, 5, STONE_LT },
			{ 5.4, -0.1, 3.8, 3.6, -3, STONE2 }, { -3.6, -3.2, 2.8, 2.0, 10, TILE }, { 0.4, -3.4, 3.0, 2.2, -8, STONE },
			{ 4.0, -3.4, 2.6, 2.0, 12, TILE_DK }, { -2.2, 3.3, 3.0, 2.0, 8, TILE }, { 2.6, 3.4, 2.8, 2.0, -10, STONE2 },
			{ -6.4, 3.0, 2.0, 1.8, -14, STONE_LT }, { 7.4, 2.6, 1.6, 1.6, 20, TILE_DK },
		}
		for _, s in slabs do
			local stone = (s[6] ~= TILE and s[6] ~= TILE_DK)
			local h = (stone and 0.4 or 0.3) + rnd(-0.03, 0.03)
			B:block(R, v(s[3], h, s[4]), cf(s[1], h / 2, s[2], 0, s[5], 0), s[6])
		end
		B:block(R, v(2.0, 0.1, 0.18), cf(-3.6, 0.33, -3.2, 0, 10, 0), GOLD)
		B:block(R, v(0.18, 0.1, 1.6), cf(-2.2, 0.33, 3.3, 0, 8, 0), GOLD)
		B:block(R, v(0.7, 0.11, 0.7), cf(4.0, 0.33, -3.4, 0, 57, 0), GOLD_DK)
		B:block(R, v(0.4, 0.13, 0.4), cf(4.0, 0.35, -3.4, 0, 12, 0), GOLD_LT)

		------------------------------------------------------------------
		-- PIERS
		------------------------------------------------------------------
		local F0 = 0.4
		local PW, PD = 2.8, 2.8 -- pier width (X) and depth (Z)
		local LX, RX = -5.6, 5.6
		local function plinth(x)
			B:block(R, v(PW + 1.0, 0.8, PD + 1.0), cf(x, F0 + 0.4, 0), STONE_DK)
			B:block(R, v(PW + 1.16, 0.16, PD + 1.16), cf(x, F0 + 0.86, 0), GOLD)
			B:block(R, v(PW + 0.5, 0.5, PD + 0.5), cf(x, F0 + 1.15, 0), STONE)
			return F0 + 1.4
		end
		-- star carving on a face (frame faces -Z)
		local function star(F, s, glow)
			B:block(R, v(1.6 * s, 0.32 * s, 0.12), F, GOLD)
			B:block(R, v(0.32 * s, 1.6 * s, 0.12), F, GOLD)
			B:block(R, v(1.0 * s, 0.26 * s, 0.13), F * ang(0, 0, 45), GOLD_LT)
			B:block(R, v(0.26 * s, 1.0 * s, 0.13), F * ang(0, 0, 45), GOLD_LT)
			if glow then
				B:block(R, v(0.4 * s, 0.4 * s, 0.16), F * ang(0, 0, 45), RUNE, NEON)
			else
				B:block(R, v(0.42 * s, 0.42 * s, 0.15), F * ang(0, 0, 45), GOLD_DK)
			end
		end

		-- left pier: stacked courses up to the spring
		local SPRING = 8.6
		do
			local y = plinth(LX)
			local courses = { { 1.8, STONE_LT }, { 1.7, STONE }, { 1.8, STONE_LT }, { 1.7, STONE } }
			for i, c in courses do
				local h = c[1]
				local dx = (i % 2 == 0) and 0.06 or -0.06
				B:block(R, v(PW, h, PD), cf(LX + dx, y + h / 2, 0), c[2])
				-- shadowed course joint
				B:block(R, v(PW + 0.1, 0.16, PD + 0.1), cf(LX + dx, y + h - 0.02, 0), STONE_DK)
				y = y + h
			end
			-- recessed front panel with a carved star
			B:block(R, v(PW - 0.8, 4.4, 0.12), cf(LX, 4.3, -PD / 2 - 0.02), STONE2)
			B:block(R, v(PW - 0.5, 0.18, 0.14), cf(LX, 6.55, -PD / 2 - 0.03), GOLD_DK)
			B:block(R, v(PW - 0.5, 0.18, 0.14), cf(LX, 2.05, -PD / 2 - 0.03), GOLD_DK)
			star(CFrame.new(LX, 4.3, -PD / 2 - 0.1), 1.0, false)
			-- side panel on the back too (reads from every angle)
			B:block(R, v(PW - 0.8, 4.4, 0.12), cf(LX, 4.3, PD / 2 + 0.02), STONE2)
			star(CFrame.new(LX, 4.3, PD / 2 + 0.1) * ang(0, 180, 0), 0.85, false)
			-- impost block at the spring (wider, gold trimmed)
			B:block(R, v(PW + 0.7, 0.6, PD + 0.7), cf(LX, SPRING - 0.85, 0), STONE_LT)
			B:block(R, v(PW + 0.86, 0.16, PD + 0.86), cf(LX, SPRING - 0.5, 0), GOLD)
			B:block(R, v(PW + 0.4, 0.4, PD + 0.4), cf(LX, SPRING - 0.25, 0), STONE)
		end

		------------------------------------------------------------------
		-- ARCH RING (voussoirs from the left spring over the top)
		------------------------------------------------------------------
		local RIN, ROUT = -LX - PW / 2, -LX + PW / 2 -- radii: inner 4.2, outer 7.0
		local RM = (RIN + ROUT) / 2
		local RT = ROUT - RIN
		local C = v(0, SPRING, 0)
		local function vous(th, col, outerCol, len)
			local t = rad(th)
			local p = C + v(-math.cos(t) * RM, math.sin(t) * RM, 0)
			-- local +Y = radial direction, +X = along the ring
			local radial = v(-math.cos(t), math.sin(t), 0)
			local Fr = CFrame.new(p) * ang(0, 0, 90 - th)
			B:block(R, v(len, RT, PD), Fr, col)
			-- lighter outer rim (extrados)
			B:block(R, v(len + 0.1, 0.5, PD + 0.2), Fr * CFrame.new(0, RT / 2 - 0.15, 0), outerCol)
			-- gold trim on the inner face (intrados)
			B:block(R, v(len - 0.2, 0.18, PD + 0.12), Fr * CFrame.new(0, -RT / 2 + 0.3, 0), GOLD)
			return Fr
		end
		local ANG = { 6, 26, 46, 66, 90, 112 }
		local frames = {}
		for i, th in ANG do
			local len = (i == 5) and 2.6 or 2.75
			local col = (i % 2 == 1) and STONE or STONE_LT
			frames[i] = vous(th, col, (i % 2 == 1) and STONE_HI or STONE2, len)
		end
		-- keystone: proud of the ring, gold star + tiny rune
		do
			local Fk = frames[5]
			B:block(R, v(2.2, RT + 0.6, PD + 0.5), Fk * CFrame.new(0, 0.2, 0), STONE_HI)
			B:block(R, v(2.4, 0.3, PD + 0.7), Fk * CFrame.new(0, RT / 2 + 0.55, 0), GOLD)
			star(Fk * CFrame.new(0, 0.2, -(PD + 0.5) / 2 - 0.08), 0.95, true)
		end
		-- jagged broken end past the keystone
		do
			local th = 128
			local t = rad(th)
			local radial = v(-math.cos(t), math.sin(t), 0)
			local p = C + radial * RM
			local Fr = CFrame.new(p) * ang(0, 0, 90 - th)
			B:block(R, v(1.4, RT * 0.7, PD - 0.2), Fr * CFrame.new(-0.2, RT * 0.12, 0) * ang(0, 0, 8), STONE)
			B:block(R, v(0.9, RT * 0.4, PD - 0.6), Fr * CFrame.new(0.45, RT * 0.3, 0.1) * ang(0, 10, -14), STONE_LT)
			B:block(R, v(0.12, RT * 0.8, PD - 0.4), Fr * CFrame.new(-0.95, 0.1, 0) * ang(0, 0, 12), STONE_DK)
		end
		-- arch spandrel infill above the left pier (solid shoulder)
		B:block(R, v(PW + 0.2, 2.4, PD - 0.1), cf(LX - 0.3, SPRING + 3.2, 0), STONE2)
		B:block(R, v(PW + 0.6, 0.5, PD + 0.4), cf(LX - 0.3, SPRING + 4.6, 0), STONE_LT)

		------------------------------------------------------------------
		-- RIGHT PIER STUMP
		------------------------------------------------------------------
		do
			local y = plinth(RX)
			B:block(R, v(PW, 1.8, PD), cf(RX, y + 0.9, 0), STONE_LT)
			B:block(R, v(PW + 0.1, 0.16, PD + 0.1), cf(RX, y + 1.78, 0), STONE_DK)
			B:block(R, v(PW, 1.0, PD), cf(RX + 0.05, y + 2.3, 0, 0, 2, 0), STONE)
			-- jagged top
			B:block(R, v(1.5, 0.9, 1.7), cf(RX - 0.55, y + 3.15, 0.35, 0, 6, -5), STONE)
			B:block(R, v(0.9, 0.6, 1.0), cf(RX - 0.6, y + 3.8, 0.4, 0, 22, 8), STONE_LT)
			B:block(R, v(1.0, 0.5, 1.2), cf(RX + 0.7, y + 2.95, -0.6, 0, -10, 4), STONE_HI)
			B:block(R, v(1.1, 0.12, 1.0), cf(RX + 0.55, y + 2.82, 0.6, 0, 15, 0), STONE_DK)
			-- moss on the snap
			B:block(R, v(1.8, 0.22, 1.5), cf(RX + 0.2, y + 2.86, 0.2, 2, 10, -2), MOSS)
			B:block(R, v(0.5, 1.8, 0.26), cf(RX - 0.8, y + 1.9, PD / 2 + 0.14), MOSS_DK)
		end

		------------------------------------------------------------------
		-- FALLEN VOUSSOIRS on the paving
		------------------------------------------------------------------
		local function fallen(F, col)
			B:block(R, v(2.6, RT * 0.95, PD - 0.2), F, col)
			B:block(R, v(2.7, 0.45, PD), F * CFrame.new(0, RT * 0.95 / 2 - 0.1, 0), STONE_HI)
			B:block(R, v(2.4, 0.18, PD + 0.1), F * CFrame.new(0, -RT * 0.95 / 2 + 0.3, 0), GOLD)
		end
		fallen(CFrame.new(1.7, 1.85, -2.7) * ang(0, 24, 0) * ang(0, 0, 160), STONE)
		fallen(CFrame.new(3.5, 1.75, 1.9) * ang(10, -30, -14), STONE_LT)
		B:block(R, v(1.6, 0.22, 1.4), cf(3.3, 3.2, 1.9, 10, -10, -14), MOSS)
		B:block(R, v(0.9, 0.2, 0.8), cf(3.0, 3.35, 2.1, 10, 20, -14), MOSS_LT)
		B:block(R, v(1.3, 1.0, 1.2), cf(-0.6, 0.9, 2.2, 8, 30, 6), STONE2)
		B:block(R, v(0.8, 0.6, 0.8), cf(-1.4, 0.7, -2.0, 0, 50, 10), STONE_LT)

		------------------------------------------------------------------
		-- MOSS over the arch + hanging strands
		------------------------------------------------------------------
		local function mossOn(i, off, w, col)
			local F = frames[i]
			B:block(R, v(w, 0.24, PD - 0.2), F * CFrame.new(off, RT / 2 + 0.18, 0.1), col)
		end
		mossOn(3, 0.2, 2.2, MOSS)
		mossOn(4, -0.3, 1.8, MOSS_LT)
		mossOn(6, 0.0, 2.0, MOSS)
		B:block(R, v(3.2, 0.26, 2.6), cf(LX - 0.3, SPRING + 5.0, 0.2, 0, 4, 0), MOSS)
		B:block(R, v(1.8, 0.24, 1.6), cf(LX - 0.1, SPRING + 5.2, 0.0, 0, 22, 0), MOSS_LT)
		-- strands hanging off the inner arch and the pier
		for _, s in { { 3, 0.4, 1.6, MOSS_DK }, { 4, -0.6, 1.0, MOSS }, { 6, 0.3, 1.3, MOSS_DK } } do
			local F = frames[s[1]]
			local p = (F * CFrame.new(s[2], -RT / 2 - 0.02, -PD / 2 + 0.4)).Position
			B:block(R, v(0.5, s[3], 0.28), CFrame.new(p - v(0, s[3] / 2, 0)), s[4])
		end
		B:block(R, v(0.6, 2.6, 0.28), cf(LX + 0.7, SPRING + 1.6, -PD / 2 - 0.22), MOSS_DK)
		B:block(R, v(0.5, 1.4, 0.28), cf(LX - 0.6, SPRING + 2.8, -PD / 2 - 0.2), MOSS)
		B:block(R, v(0.55, 2.0, 0.28), cf(LX - PW / 2 - 0.22, SPRING + 3.0, 0.5, 0, 90, 0), MOSS)

		------------------------------------------------------------------
		-- CRYSTAL SPROUTS, chips, dust, grass
		------------------------------------------------------------------
		local function sprout(p, sc, yaw)
			local base = CFrame.new(p) * ang(0, yaw, 0)
			B:block(R, v(0.6 * sc, 1.7 * sc, 0.6 * sc), base * CFrame.new(0, 0.6 * sc, 0) * ang(-10, 45, 6), VIO)
			B:block(R, v(0.34 * sc, 0.5 * sc, 0.34 * sc), base * CFrame.new(0.12 * sc, 1.55 * sc, -0.17 * sc) * ang(-10, 45, 6), VIO_LT)
			B:block(R, v(0.42 * sc, 1.1 * sc, 0.42 * sc), base * CFrame.new(0.5 * sc, 0.35 * sc, -0.1 * sc) * ang(-14, 20, -28), CY)
			B:block(R, v(0.26 * sc, 0.3 * sc, 0.26 * sc), base * CFrame.new(0.78 * sc, 0.86 * sc, -0.25 * sc) * ang(-14, 20, -28), CY_LT)
			B:block(R, v(0.38 * sc, 0.9 * sc, 0.38 * sc), base * CFrame.new(-0.42 * sc, 0.25 * sc, 0.05 * sc) * ang(8, 55, 30), VIO_DK)
		end
		sprout(v(-7.6, 0.4, -1.6), 1.2, -30)
		sprout(v(7.4, 0.4, -1.4), 1.0, 40)
		sprout(v(-3.6, 0.4, 2.0), 0.8, 160)
		for _, c in { { -2.6, -1.8, 0.7, STONE }, { 0.4, 1.0, 0.6, STONE_LT }, { 7.6, 0.8, 0.55, STONE2 }, { -7.4, 1.4, 0.6, STONE } } do
			B:block(R, v(c[3], c[3] * 0.7, c[3] * 0.9), cf(c[1], 0.4 + c[3] * 0.3, c[2], rnd(-10, 10), rnd(0, 90), rnd(-10, 10)), c[4])
		end
		for _, d in { { -1.6, -1.6, DUST_G }, { 2.2, -0.8, DUST_C }, { -3.8, 1.2, DUST_C }, { 4.6, 2.4, DUST_G }, { -0.4, 2.6, DUST_G } } do
			B:block(R, v(0.28, 0.16, 0.28), cf(d[1], 0.46, d[2], 0, rnd(0, 90), 0), d[3])
		end
		for _, g in { { -8.0, 0.2, 0.6 }, { -3.2, 0.4, -1.6 }, { 3.4, 0.4, -1.0 }, { 8.0, 0.0, -0.2 }, { 0.6, 0.4, 2.6 } } do
			local base = CFrame.new(g[1], g[2], g[3]) * ang(0, rnd(0, 90), 0)
			for k = -1, 1 do
				B:block(R, v(0.22, 0.9 - math.abs(k) * 0.25, 0.22), base * CFrame.new(k * 0.25, 0.45, 0) * ang(0, 0, -k * 22), (k == 0) and GRASS or GRASS_DK)
			end
		end
	end,
}
