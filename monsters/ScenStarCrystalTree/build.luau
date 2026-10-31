--!nocheck
-- Crystal Tree (Starlight Ruins scenery, big copy-paste filler).
-- A tall silver-barked tree whose canopy is made of violet and cyan crystal
-- clusters instead of leaves:
-- * footing: flat indigo star-earth patch, a few worn white-violet paving
--   slabs, silver-blue grass tufts, star-dust specks and little crystal
--   sprouts (no mound)
-- * silver trunk (three tones, light bark streaks, dark knots) with flared
--   roots and a teal moss collar, splitting into crooked boughs
-- * seven crystal clusters: each a chunky faceted core with stepped prisms
--   bursting up and out, pale tips; alternating violet / cyan so the canopy
--   reads as one big rounded crown from far away; two tiny glowing glints
-- Scenery filler: anchored, weld-free, no scripts, no effects, no motion.
return {
	DisplayName = "Crystal Tree",
	Rarity = "Scenery",
	Filler = true,
	Element = "Starlight Ruins",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Starlight Ruins) ----------------------------------------
		local EARTH_DK, EARTH, EARTH_LT = "#2a2550", "#3b3566", "#4d4684"
		local STONE, STONE2, STONE_DK, STONE_LT = "#e3dcef", "#d0c7e2", "#a99fc2", "#f4f0fb"
		local SIL_XD, SIL_DK, SIL, SIL_LT, SIL_HI = "#6f7394", "#8f93b4", "#b6bad6", "#d6d9ee", "#f0f2fb"
		local GOLD, GOLD_DK = "#f2c24f", "#c9952e"
		local MOSS, MOSS_DK, MOSS_LT = "#4f9e7c", "#367a62", "#78c79a"
		local VIO_XD, VIO_DK, VIO, VIO_LT, VIO_HI = "#5a3fc0", "#7a58ea", "#9b7cff", "#c6b4ff", "#e4dbff"
		local CY_XD, CY_DK, CY, CY_LT, CY_HI = "#1f86b0", "#2aa9cf", "#4fd8f2", "#a8f3ff", "#dcfbff"
		local DUST_G, DUST_C = "#ffe27a", "#b8f4ff"
		local GRASS, GRASS_DK = "#8ea9dc", "#6f87c2"

		local seed = 61403
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pv(r, deg, y)
			local a = rad(deg)
			return v(math.sin(a) * r, y, -math.cos(a) * r)
		end

		------------------------------------------------------------------
		-- FOOTING (flat)
		------------------------------------------------------------------
		B:block(R, v(11.5, 0.14, 6.6), cf(0, 0.07, 0, 0, 12, 0), EARTH_DK)
		B:block(R, v(6.6, 0.15, 11.5), cf(0, 0.075, 0, 0, 12, 0), EARTH_DK)
		B:block(R, v(9.0, 0.17, 9.0), cf(0, 0.085, 0, 0, 57, 0), EARTH)
		B:block(R, v(4.4, 0.19, 4.4), cf(0.6, 0.095, -0.8, 0, 20, 0), EARTH_LT)
		for _, s in { { 4.0, -2.6, 2.6, 2.2, 8, STONE2 }, { -4.2, 1.8, 2.4, 2.2, -10, STONE }, { 1.2, 4.4, 2.2, 1.8, 15, STONE_LT }, { -2.6, -4.0, 2.0, 1.8, -5, STONE } } do
			local h = 0.36 + rnd(-0.03, 0.03)
			B:block(R, v(s[3], h, s[4]), cf(s[1], h / 2, s[2], 0, s[5], 0), s[6])
		end
		B:block(R, v(1.8, 0.1, 0.18), cf(4.0, 0.38, -2.6, 0, 8, 0), GOLD)
		B:block(R, v(0.18, 0.1, 1.5), cf(-4.2, 0.38, 1.8, 0, -10, 0), GOLD_DK)
		for _, d in { { -1.8, -2.4, DUST_G }, { 2.6, 1.8, DUST_C }, { -3.4, -1.0, DUST_C }, { 3.0, -0.6, DUST_G }, { -0.6, 3.0, DUST_G } } do
			B:block(R, v(0.3, 0.14, 0.3), cf(d[1], 0.25, d[2], 0, rnd(0, 90), 0), d[3])
		end
		for _, g in { { -5.0, -1.4 }, { 5.2, 0.8 }, { 0.6, -5.0 }, { -1.6, 5.0 }, { 3.4, 3.6 } } do
			local base = CFrame.new(g[1], 0.15, g[2]) * ang(0, rnd(0, 90), 0)
			for k = -1, 1 do
				B:block(R, v(0.24, 1.0 - math.abs(k) * 0.3, 0.24), base * CFrame.new(k * 0.26, 0.5, 0) * ang(0, 0, -k * 22), (k == 0) and GRASS or GRASS_DK)
			end
		end
		-- little crystal sprouts on the ground
		local function sprout(p, sc, yaw, c1, c2, c3)
			local base = CFrame.new(p) * ang(0, yaw, 0)
			B:block(R, v(0.6 * sc, 1.6 * sc, 0.6 * sc), base * CFrame.new(0, 0.6 * sc, 0) * ang(-10, 45, 6), c1)
			B:block(R, v(0.34 * sc, 0.5 * sc, 0.34 * sc), base * CFrame.new(0.12 * sc, 1.5 * sc, -0.17 * sc) * ang(-10, 45, 6), c2)
			B:block(R, v(0.42 * sc, 1.0 * sc, 0.42 * sc), base * CFrame.new(0.5 * sc, 0.3 * sc, -0.1 * sc) * ang(-14, 20, -28), c3)
		end
		sprout(v(-4.6, 0.15, -2.6), 1.1, -30, VIO, VIO_HI, CY)
		sprout(v(4.8, 0.15, 2.6), 0.9, 50, CY, CY_HI, VIO)
		sprout(v(2.4, 0.15, -4.4), 0.7, 110, VIO_DK, VIO_LT, CY_LT)

		------------------------------------------------------------------
		-- SILVER TRUNK
		------------------------------------------------------------------
		local function limb(a, b, w, c1, c2, roll)
			local d = (b - a).Unit
			local side = d:Cross(v(0, 1, 0))
			if side.Magnitude < 0.1 then
				side = v(1, 0, 0)
			end
			side = side.Unit
			local up0 = d:Cross(side).Unit
			local r = rad(roll or 0)
			B:bar(R, a, b, w, w, c1, { up = up0 * math.cos(r) + side * math.sin(r) })
			if c2 then
				local r2 = r + rad(45)
				B:bar(R, a + d * 0.1, b - d * 0.1, w * 0.86, w * 0.86, c2, { up = up0 * math.cos(r2) + side * math.sin(r2) })
			end
		end
		-- roots
		for i, r in { { 30, 3.2 }, { 110, 2.8 }, { 190, 3.4 }, { 270, 3.0 } } do
			local a0 = pv(0.5, r[1], 1.4)
			local a1 = pv(1.9, r[1] + 12, 0.6)
			local a2 = pv(r[2], r[1] + 22, 0.32)
			limb(a0, a1, 1.15, SIL_DK, SIL, i * 20)
			B:bar(R, a1 - (a1 - a0).Unit * 0.25, a2, 0.75, 0.6, (i % 2 == 0) and SIL or SIL_DK)
		end
		-- base collar + moss
		B:block(R, v(3.2, 1.0, 2.4), cf(0, 0.6, 0, 0, 15, 0), SIL_DK)
		B:block(R, v(2.4, 1.05, 3.2), cf(0, 0.62, 0, 0, 15, 0), SIL)
		B:block(R, v(2.2, 0.3, 1.6), cf(-0.5, 1.15, 0.6, 0, 30, 0), MOSS)
		B:block(R, v(1.3, 0.28, 1.0), cf(0.8, 1.12, -0.7, 0, -20, 0), MOSS_LT)

		local T = { v(0, 0.4, 0), v(0.5, 3.4, 0.2), v(-0.4, 6.2, -0.2), v(0.2, 8.6, 0.1) }
		local TW = { 2.3, 1.95, 1.65 }
		for i = 1, #T - 1 do
			local ext = (T[i + 1] - T[i]).Unit * 0.3
			limb(T[i], T[i + 1] + ext, TW[i], (i % 2 == 1) and SIL or SIL_LT, (i % 2 == 1) and SIL_LT or SIL, i * 25)
			if i > 1 then
				B:block(R, v(TW[i] + 0.25, 0.6, TW[i] + 0.25), CFrame.new(T[i]) * ang(0, i * 37, 0), SIL_DK)
			end
		end
		-- light bark streaks + dark knots
		for k = 0, 4 do
			local y = 1.6 + k * 1.3
			local i = (y < 3.4) and 1 or 2
			local ctr = T[i]:Lerp(T[i + 1], (y - T[i].Y) / (T[i + 1].Y - T[i].Y))
			local a = k * 72 + 15
			local p0 = ctr + pv(TW[i] * 0.55, a, 0)
			B:bar(R, p0, p0 + v(0, 1.2, 0) + pv(0.1, a + 90, 0), 0.32, 0.3, (k % 2 == 0) and SIL_HI or SIL_XD)
		end
		-- a little gold band of bark inlay
		B:block(R, v(2.15, 0.22, 2.15), CFrame.new(T[2] + v(0, 0.75, 0)) * ang(0, 30, 0), GOLD)

		------------------------------------------------------------------
		-- BOUGHS + CRYSTAL CLUSTERS
		------------------------------------------------------------------
		local VIOL = { VIO_XD, VIO_DK, VIO, VIO_LT, VIO_HI }
		local CYAN = { CY_XD, CY_DK, CY, CY_LT, CY_HI }
		local UP = v(0, 1, 0)
		local function cluster(c, s, pal, glint)
			local o = v(c.X, 0, c.Z)
			o = (o.Magnitude > 0.3) and o.Unit or v(0, 0, -1)
			local side = o:Cross(UP).Unit
			local yaw = math.deg(math.atan2(o.X, -o.Z))
			-- faceted core
			local core = CFrame.new(c) * ang(0, -yaw, 0)
			B:block(R, v(3.4, 2.6, 2.4) * s, core, pal[2])
			B:block(R, v(2.4, 2.8, 3.4) * s, core, pal[3])
			B:block(R, v(2.6, 2.2, 2.6) * s, core * CFrame.new(0, 0.5 * s, 0) * ang(0, 45, 0), pal[4])
			B:block(R, v(2.0, 1.0, 2.0) * s, core * CFrame.new(0, -1.25 * s, 0) * ang(0, 45, 0), pal[1])
			-- prisms bursting up and out
			local dirs = {
				{ UP * 1.0 + o * 0.15, 3.6, 1.15 },
				{ UP * 0.8 + o * 0.7 + side * 0.25, 3.2, 1.0 },
				{ UP * 0.8 + o * 0.35 - side * 0.75, 2.8, 0.95 },
				{ UP * 0.75 + o * 0.25 + side * 0.85, 2.6, 0.9 },
				{ UP * 0.35 + o * 1.0 - side * 0.2, 2.4, 0.9 },
			}
			for k, dd in dirs do
				local d = dd[1].Unit
				local base = c + d * 0.6 * s
				local top = c + d * dd[2] * s
				local w = dd[3] * s
				B:bar(R, base, top, w, w, (k % 2 == 1) and pal[3] or pal[2])
				B:bar(R, top - d * 0.15, top + d * 0.75 * s, w * 0.62, w * 0.62, (k == 1) and pal[5] or pal[4])
			end
			if glint then
				B:block(R, v(0.5, 0.5, 0.5) * s, CFrame.new(c + o * 1.75 * s + v(0, -0.2 * s, 0)) * ang(0, -yaw + 45, 0), CY_HI, { mat = "Neon" })
			end
		end

		local TOP = T[4]
		local CL = {
			{ v(0.3, 14.2, 0.2), 1.25, VIOL, true },
			{ v(3.7, 12.2, -1.1), 1.1, CYAN },
			{ v(-3.5, 12.4, 1.3), 1.1, VIOL },
			{ v(1.3, 11.6, 3.5), 1.0, CYAN },
			{ v(-1.2, 11.5, -3.4), 1.0, VIOL, true },
			{ v(4.8, 9.8, 2.4), 0.85, VIOL },
			{ v(-4.7, 9.9, -2.1), 0.85, CYAN },
		}
		for i, c in CL do
			local p = c[1]
			-- crooked bough: trunk top -> elbow -> cluster
			local elbow = TOP:Lerp(p, 0.5) + v(0, -0.6, 0) + v(-p.Z, 0, p.X).Unit * 0.5
			limb(TOP + v(0, -0.6, 0), elbow, 1.2, SIL, (i <= 3) and SIL_DK or nil, i * 30)
			B:bar(R, elbow - (elbow - TOP).Unit * 0.2, p, 0.95, 0.9, (i % 2 == 0) and SIL_LT or SIL)
		end
		-- inner canopy mass so the crown reads solid from far away
		B:block(R, v(6.4, 2.8, 4.4), cf(0.1, 11.9, 0.1, 0, 20, 0), VIO_XD)
		B:block(R, v(4.4, 3.0, 6.4), cf(0.1, 12.0, 0.1, 0, 20, 0), VIO_DK)
		B:block(R, v(5.0, 2.4, 5.0), cf(0.1, 10.9, 0.1, 0, 65, 0), CY_XD)
		for _, c in CL do
			cluster(c[1], c[2], c[3], c[4])
		end
	end,
}
