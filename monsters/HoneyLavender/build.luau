--!nocheck
-- Lavender Nectar Bush (Honey Hills crop #6, Mythic).
-- A tall fan of lavender spikes in the stud-plant style:
-- * stepped GRASSY meadow mound (bone "Soil"): soil tiers capped with
--   golden-green grass, tiny wildflowers, clover, pebbles, fallen lavender
--   florets and a little honey puddle
-- * a round clump of silvery grey-green lavender leaf blades
-- * thirteen tall lavender spikes fanning out of the clump: slim stems, then
--   long heads of stepped florets twisting 45 deg per whorl, deep violet at
--   the base grading to pale lilac, each tipped with a tiny glowing bud;
--   the tall centre spike towers over the rest
-- * glowing NECTAR PODS hanging like lanterns from arching stems: a neon
--   gold nectar core caged by amber ribs, with a leafy calyx and a nectar
--   drop at the bottom
-- * two cute block bees come to sip the nectar
-- VFX: golden nectar glow + drips at the pods, rising lilac sparkles off
-- the spike tips, drifting lavender florets, golden pollen motes; a warm
-- gold light in the pods and a soft lilac light up in the spikes.
-- Static prop: no motion.luau.
return {
	DisplayName = "Lavender Nectar Bush",
	Rarity = "Mythic",
	Element = "Nature",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Honey Hills) -------------------------------------------
		local SOIL_DK, SOIL = "#6b4226", "#875533"
		local GR_DK, GR, GR_LT, GR_XL = "#7cae32", "#97c83e", "#b2d84c", "#d2e872"
		local CLOVER, CLOVER_DK = "#3f9a3c", "#2f7f30"
		local PEB, PEB_LT = "#a49a8c", "#c4bcae"
		local FL_PINK, FL_WHITE, FL_EYE = "#ff9cc4", "#fff6fa", "#ffc93a"
		local SAGE_DK, SAGE, SAGE_LT, SAGE_XL = "#6f9468", "#86aa7c", "#9fc292", "#bad8aa"
		local STEM, STEM_DK = "#6f8f5a", "#56744a"
		local VIO_DK, VIO, LAV, LAV_LT, LILAC = "#6c4cc0", "#8766da", "#a286ea", "#bfa6f4", "#e0d0ff"
		local BUD_GLOW = "#e2ccff"
		local NECTAR, RIB, RIB_DK, RIB_LT = "#ffd23a", "#e8961c", "#c27412", "#ffb43a"
		local HONEY, HONEY_LT = "#ffa318", "#ffc54a"
		local CALYX = "#5f9a46"
		local BEE_Y, BEE_K, WING = "#ffd23a", "#2a2126", "#f4fbff"

		local seed = 16611
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function pick(t)
			return t[math.floor(rnd() * #t) + 1]
		end
		-- polar: deg 0 = front (-Z), clockwise seen from above toward +X
		local function polar(r, deg)
			local a = rad(deg)
			return math.sin(a) * r, -math.cos(a) * r
		end
		local function pv(r, deg, y)
			local x, z = polar(r, deg)
			return v(x, y, z)
		end
		local function facing(p, deg)
			return CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
		end
		-- frame at point a whose local +Y points along dir (exact aim)
		local function axisFrame(a, dir)
			local c = P.aim(a, a + dir)
			return CFrame.new(a) * (c - c.Position) * CFrame.Angles(-math.pi / 2, 0, 0)
		end

		------------------------------------------------------------------
		-- STEPPED GRASSY MOUND (bone "Soil", parts named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function disc(y0, h, r, col)
			B:block(soil, v(2 * r, h, 1.15 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.15 * r, h - 0.02, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.04, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
		end
		local function edge(y0, h, r, n, cols, eh, wr, dr)
			for i = 0, n - 1 do
				local a = (i + jit(0.2)) / n * 360
				local w, d = wr[1] + rnd() * (wr[2] - wr[1]), dr[1] + rnd() * (dr[2] - dr[1])
				local hh = h + rnd() * eh - 0.05
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + hh / 2, -(r + jit(0.2)))
				B:block(soil, v(w, hh, d), p * ang(0, jit(9), 0), pick(cols), S)
			end
		end
		disc(0, 0.6, 6.4, SOIL_DK)
		edge(0, 0.6, 6.45, 15, { SOIL_DK, SOIL, SOIL_DK }, 0.3, { 1.7, 2.4 }, { 1.2, 1.7 })
		disc(0.55, 0.35, 6.1, GR_DK)
		disc(0.9, 0.45, 4.6, SOIL)
		edge(0.9, 0.45, 4.65, 11, { GR, GR_DK, GR }, 0.3, { 1.6, 2.2 }, { 1.1, 1.5 })
		disc(1.3, 0.3, 4.35, GR)
		disc(1.6, 0.5, 2.9, GR_LT)
		local TOP = 2.1

		-- grass tufts
		for _, g in { { 6.4, 1.2 }, { -3.0, -5.8 }, { -6.2, -1.0 }, { 2.4, 6.0 } } do
			B:block(soil, v(0.35, 1.1, 0.35), cf(g[1], 0.95, g[2], 0, jit(30), -8), GR_LT, S)
			B:block(soil, v(0.3, 0.8, 0.3), cf(g[1] + 0.32, 0.82, g[2] + 0.2, 0, jit(30), 14), GR, S)
			B:block(soil, v(0.28, 0.9, 0.28), cf(g[1] - 0.3, 0.86, g[2] - 0.15, 10, jit(30), 0), GR_XL, S)
		end
		-- tiny wildflowers
		local function flower(x, y, z, col, s)
			s = s or 1
			B:block(soil, v(0.18, 0.7 * s, 0.18), cf(x, y + 0.35 * s, z), GR_DK, S)
			local yaw = rnd() * 90
			B:block(soil, v(0.75 * s, 0.18, 0.3 * s), cf(x, y + 0.72 * s, z, 0, yaw, 0), col, S)
			B:block(soil, v(0.3 * s, 0.19, 0.75 * s), cf(x, y + 0.72 * s, z, 0, yaw, 0), col, S)
			B:block(soil, v(0.24, 0.26, 0.24), cf(x, y + 0.78 * s, z, 0, yaw, 0), FL_EYE, S)
		end
		flower(5.2, 0.9, -1.4, FL_PINK)
		flower(-5.0, 0.9, 2.2, FL_WHITE)
		flower(-1.6, 0.9, 5.6, FL_PINK, 1.1)
		flower(1.0, 0.9, -5.7, FL_WHITE)
		flower(-4.6, 0.9, -3.4, FL_PINK, 0.9)
		-- clover
		local function clover(x, y, z)
			local yaw = rnd() * 120
			for k = 0, 2 do
				local c = cf(x, y + 0.32, z, 0, yaw + k * 120, 0) * CFrame.new(0, 0, -0.3)
				B:block(soil, v(0.5, 0.14, 0.5), c * ang(0, 45, 0), (k == 0) and CLOVER_DK or CLOVER, S)
			end
		end
		clover(5.6, 0.9, 2.6)
		clover(-5.6, 0.9, 0.4)
		clover(3.0, 1.6, -3.2)
		-- pebbles
		for _, p in { { 4.1, 0.95, 4.3, PEB }, { -4.4, 0.95, 4.2, PEB_LT }, { 5.9, 0.95, -3.0, PEB } } do
			B:block(soil, v(0.6, 0.38, 0.5), cf(p[1], p[2], p[3], 0, jit(40), 0), p[4], S)
		end
		-- fallen lavender florets
		for _, f in { { 30, 5.2 }, { 75, 4.9 }, { 150, 5.3 }, { 205, 5.0 }, { 280, 5.4 }, { 330, 3.6 }, { 110, 3.5 } } do
			local y = (f[2] > 4.4) and 0.95 or 1.63
			B:block(soil, v(0.45, 0.2, 0.45), facing(pv(f[2], f[1], y), f[1] + jit(40)) * ang(0, 45, 0), pick({ VIO, LAV, LAV_LT }), S)
		end
		-- little honey puddle under a nectar pod
		do
			local px, pz = -3.75, -3.9
			B:block(soil, v(1.9, 0.14, 1.3), cf(px, 0.94, pz, 0, -15, 0), HONEY, S)
			B:block(soil, v(1.2, 0.16, 1.7), cf(px - 0.1, 0.95, pz, 0, 10, 0), HONEY, S)
			B:block(soil, v(0.6, 0.17, 0.45), cf(px + 0.2, 0.97, pz + 0.1, 0, -15, 0), HONEY_LT, S)
		end

		------------------------------------------------------------------
		-- PLANT (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		-- silvery lavender leaf clump: core + rings of narrow blades
		B:block(crop, v(2.6, 1.2, 2.6), cf(0, TOP + 0.5, 0, 0, 20, 0), SAGE_DK)
		B:block(crop, v(2.0, 1.0, 2.0), cf(0, TOP + 1.3, 0, 0, 65, 0), SAGE)
		local function blade(deg, r0, y0, elev, len, w, col)
			local e = rad(elev)
			local x, z = polar(1, deg)
			local dir = v(x * math.cos(e), math.sin(e), z * math.cos(e))
			local a = pv(r0, deg, y0)
			B:bar(crop, a, a + dir * len, w, w * 0.7, col)
		end
		-- rounded bush body of rotated sage leaf cubes
		for i = 0, 6 do
			local deg = i * 360 / 7 + jit(8)
			local sz = 2.2 + rnd() * 0.4
			B:block(crop, v(sz, sz * 0.85, sz), CFrame.new(pv(2.0 + jit(0.15), deg, TOP + 0.6 + jit(0.15))) * ang(jit(15), rnd() * 90, jit(15)), (i % 3 == 0) and SAGE_DK or ((i % 3 == 1) and SAGE or SAGE_LT))
		end
		for i = 0, 4 do
			local deg = i * 72 + 30 + jit(8)
			local sz = 1.8 + rnd() * 0.3
			B:block(crop, v(sz, sz, sz), CFrame.new(pv(1.15, deg, TOP + 1.9 + jit(0.15))) * ang(jit(15), rnd() * 90, jit(15)), (i % 2 == 0) and SAGE_LT or SAGE_XL)
		end
		-- narrow silvery blades sticking out of the clump
		for i = 0, 9 do
			blade(i * 36 + jit(6), 1.2, TOP + 0.6, 34 + jit(8), 3.3, 0.5, (i % 2 == 0) and SAGE_LT or SAGE)
		end
		for i = 0, 6 do
			blade(i * 360 / 7 + 18 + jit(6), 0.6, TOP + 1.5, 62 + jit(6), 3.0, 0.45, (i % 2 == 0) and SAGE_XL or SAGE_LT)
		end

		-- LAVENDER SPIKE: stem, then a head of twisting stepped florets
		local tips = {}
		local function spike(base, dir, stemLen, headLen, wmax, crossed)
			dir = dir.Unit
			local hb = base + dir * stemLen
			B:bar(crop, base, hb + dir * 0.3, 0.38, 0.38, STEM)
			-- inner stem through the head
			B:bar(crop, hb, hb + dir * (headLen + 0.2), 0.3, 0.3, STEM_DK)
			local H = axisFrame(hb, dir)
			local n = math.max(4, math.floor(headLen / 0.62))
			local step = headLen / n
			for k = 0, n - 1 do
				local f = k / (n - 1)
				local w = wmax * (1 - 0.48 * f)
				local col = (f < 0.25) and VIO_DK or ((f < 0.5) and VIO or ((f < 0.78) and LAV or LAV_LT))
				local c = H * CFrame.new(0, (k + 0.5) * step, 0) * CFrame.Angles(0, rad(k * 45), 0)
				B:block(crop, v(w, step * 0.8, w), c, col)
				if crossed and k % 2 == 0 and k < n - 2 then
					B:block(crop, v(w * 1.25, step * 0.4, w * 0.45), c * CFrame.Angles(0, rad(22.5), 0), LILAC)
				end
			end
			local tipP = hb + dir * (headLen + 0.25)
			B:block(crop, v(wmax * 0.38, wmax * 0.38, wmax * 0.38), axisFrame(tipP, dir) * CFrame.Angles(0, rad(45), 0), BUD_GLOW, { mat = "Neon", name = "SpikeBud" })
			table.insert(tips, tipP)
		end

		-- tall centre spike
		spike(v(0, TOP + 1.5, 0), v(0.02, 1, -0.02), 9.8, 8.2, 1.55, true)
		-- inner ring of five
		for i = 0, 4 do
			local deg = i * 72 + 36 + jit(5)
			local x, z = polar(0.2 + jit(0.04), deg)
			spike(pv(0.6, deg, TOP + 1.3), v(x, 1, z), 8.6 + jit(0.6), 6.4 + jit(0.4), 1.25, true)
		end
		-- outer ring of seven
		for i = 0, 6 do
			local deg = i * 360 / 7 + 10 + jit(6)
			local x, z = polar(0.4 + jit(0.05), deg)
			spike(pv(0.9, deg, TOP + 1.0), v(x, 1, z), 6.6 + jit(0.6), 5.0 + jit(0.4), 1.05, false)
		end

		------------------------------------------------------------------
		-- GLOWING NECTAR PODS hanging like lanterns from arching stems
		------------------------------------------------------------------
		local pods = {}
		local function pod(deg, y0, reach, rise, s)
			local p0 = pv(0.7, deg, y0)
			local p1 = pv(reach * 0.65, deg + 6, y0 + rise)
			local p2 = pv(reach, deg + 10, y0 + rise - 0.4)
			B:bar(crop, p0, p1, 0.32, 0.32, STEM)
			B:bar(crop, p1, p2, 0.28, 0.28, STEM_DK)
			-- a small leaf on the arch
			B:block(crop, v(0.9, 0.12, 0.45), facing(p1 + v(0, 0.15, 0), deg + 70) * ang(0, 0, 20), SAGE_LT)
			local F = facing(p2, deg)
			local function at(x, y, z)
				return F * CFrame.new(x * s, y * s, z * s)
			end
			-- calyx + caps + ribs around a neon nectar core
			B:block(crop, v(0.9 * s, 0.28 * s, 0.9 * s), at(0, -0.25, 0) * ang(0, 45, 0), CALYX)
			B:block(crop, v(1.0 * s, 0.32 * s, 1.0 * s), at(0, -0.55, 0), RIB_DK)
			B:block(crop, v(1.2 * s, 1.7 * s, 1.2 * s), at(0, -1.6, 0) * ang(0, 45, 0), NECTAR, { mat = "Neon", name = "NectarCore" })
			for k = 0, 3 do
				local R = F * CFrame.Angles(0, rad(k * 90), 0)
				local col = (k % 2 == 0) and RIB or RIB_LT
				-- upper rib leans out from the cap, lower rib curls back in
				B:bar(crop, (R * CFrame.new(0, -0.6 * s, -0.5 * s)).Position, (R * CFrame.new(0, -1.55 * s, -0.78 * s)).Position, 0.42 * s, 0.32 * s, col)
				B:bar(crop, (R * CFrame.new(0, -1.4 * s, -0.78 * s)).Position, (R * CFrame.new(0, -2.5 * s, -0.48 * s)).Position, 0.42 * s, 0.32 * s, col)
			end
			B:block(crop, v(0.95 * s, 0.32 * s, 0.95 * s), at(0, -2.55, 0), RIB_DK)
			B:block(crop, v(0.5 * s, 0.32 * s, 0.5 * s), at(0, -2.85, 0) * ang(0, 45, 0), RIB)
			local drop = at(0, -3.2, 0).Position
			B:block(crop, v(0.32 * s, 0.32 * s, 0.32 * s), CFrame.new(drop) * ang(0, 45, 0), HONEY_LT)
			table.insert(pods, { core = at(0, -1.6, 0).Position, drop = drop })
		end
		pod(20, TOP + 5.2, 4.4, 3.0, 1.1)
		pod(95, TOP + 7.0, 4.1, 2.8, 1.0)
		pod(165, TOP + 4.6, 4.5, 3.0, 1.1)
		pod(235, TOP + 6.6, 4.2, 2.9, 1.0)
		pod(305, TOP + 4.9, 5.0, 3.1, 1.1)
		pod(345, TOP + 8.6, 3.4, 2.4, 0.85)

		------------------------------------------------------------------
		-- CUTE BLOCK BEES sipping nectar
		------------------------------------------------------------------
		local function bee(p, yaw, tilt)
			local F = CFrame.new(p) * CFrame.Angles(0, rad(yaw), 0) * ang(tilt, 0, 0)
			B:block(crop, v(0.95, 0.9, 1.3), F, BEE_Y)
			B:block(crop, v(0.99, 0.94, 0.26), F * CFrame.new(0, 0, 0.05), BEE_K)
			B:block(crop, v(0.99, 0.94, 0.22), F * CFrame.new(0, 0, 0.5), BEE_K)
			B:block(crop, v(0.8, 0.78, 0.5), F * CFrame.new(0, 0.02, -0.82), BEE_K)
			B:block(crop, v(0.18, 0.18, 0.3), F * CFrame.new(0, -0.1, 0.78), BEE_K)
			for sgn = -1, 1, 2 do
				B:block(crop, v(0.7, 0.08, 0.5), F * CFrame.new(sgn * 0.48, 0.6, -0.05) * ang(0, 0, sgn * 25), WING, { tr = 0.25 })
			end
		end
		bee(pv(6.2, 60, TOP + 8.6), 80, -10)
		bee(pv(5.0, 200, TOP + 13.0), 160, 8)

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		-- nectar glow on three pods + drips from two
		for i, idx in { 1, 3, 5 } do
			local pd = pods[idx]
			local z = B:block(crop, v(0.4, 0.4, 0.4), CFrame.new(pd.core), NECTAR, { tr = 1, name = "PodGlowZone" .. i })
			B:emitter(z, "glow", { name = "NectarGlow" .. i, color = { "#ffe27a", "#ffc23a" }, rate = 1.2, size = { 1.6, 2.4, 0 }, trans = { 0.7, 0.6, 1 } })
		end
		for i, idx in { 5, 2 } do
			local pd = pods[idx]
			local z = B:block(crop, v(0.3, 0.2, 0.3), CFrame.new(pd.drop - v(0, 0.25, 0)), HONEY, { tr = 1, name = "NectarDripZone" .. i })
			B:emitter(z, "drip", { name = "NectarDrip" .. i, color = { "#ffd24a", "#ffa318" }, rate = 1.0, size = { 0.32, 0.28, 0.14 }, life = { 0.55, 0.8 } })
		end
		local light1 = B:block(crop, v(0.4, 0.4, 0.4), cf(0, TOP + 7.5, 0), NECTAR, { tr = 1, name = "NectarLightZone" })
		B:light(light1, { name = "NectarLight", color = "#ffc85a", brightness = 1.3, range = 14 })
		-- rising lilac sparkles off the spike tips
		local tz = B:block(crop, v(8, 5, 8), cf(0, TOP + 15.5, 0), LAV, { tr = 1, name = "SpikeSparkZone" })
		B:emitter(tz, "sparkle", { name = "LilacSparkle", color = { "#f0e4ff", "#cbb4f6", "#ffe27a" }, rate = 6, size = { 0.15, 0.5, 0.05 }, life = { 1.4, 2.6 }, speed = { 0.3, 0.8 }, accel = { 0, 0.6, 0 } })
		B:light(tz, { name = "LilacLight", color = "#c9a8ff", brightness = 1.0, range = 14 })
		-- drifting lavender florets
		local fz = B:block(crop, v(9, 2, 9), cf(0, TOP + 12.0, 0), LAV, { tr = 1, name = "FloretZone" })
		B:emitter(fz, "leaf", { name = "DriftingFlorets", color = { LAV_LT, VIO, LILAC }, rate = 1.2, size = 0.3 })
		-- golden pollen motes around the bush
		local mz = B:block(crop, v(10, 6, 10), cf(0, TOP + 7.0, 0), NECTAR, { tr = 1, name = "PollenZone" })
		B:emitter(mz, "sparkle", { name = "GoldPollen", color = { "#ffe57a", "#fff6c8", "#ffc23a" }, rate = 4, size = { 0.12, 0.38, 0.05 }, life = { 1.4, 2.6 }, speed = { 0.15, 0.5 } })
	end,
}
