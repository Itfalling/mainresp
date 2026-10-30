--!nocheck
-- Marsh Moon Pod Tree (Misty Swamp crop #9, Divine): a dark, gnarled swamp
-- tree that grows glowing MOON PODS.
-- * a stepped dark-mud mound (bone "Soil", parts "Soil") with moss pads, a
--   murky teal puddle with lily pads + a pink water lily, cattail reeds,
--   mossy stones, glowing teal toadstools and a fallen, half-open moon pod
-- * a twisted violet-black trunk (bone "Crop") with gnarled roots, bark
--   ridges, moss patches, teal shelf fungi and a glowing knot hollow
-- * crooked limbs carry a broad canopy of dark teal leaf cubes with violet
--   tips (bone "Canopy"); grey-green swamp moss hangs from the limbs on its
--   own bones (MossN)
-- * six violet MOON PODS hang on stems (bones PodN, pivot at the stem top,
--   facing outward). Each pod is two husk halves on hinge bones (PodNL /
--   PodNR) around a glowing moon core (neon MoonCoreN) that shines through
--   the seam; the halves breathe open and burst wide on the moonrise beat
-- * two pale moon moths orbit the tree (bones MothOrbitN -> MothN -> wings
--   MothNWingR/L) leaving soft trails and moon-dust
-- * VFX: moon sparkles, pod glow, drifting fireflies, puddle mist, moth dust
--   x2, a moon burst + rising motes on the beat; two lights; two trails.
-- Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Marsh Moon Pod Tree",
	Rarity = "Divine",
	Element = "Moon",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ------------------------------------------------------------
		local MUD_DK2, MUD_DK, MUD, MUD_LT = "#33291f", "#3e3226", "#4d3f30", "#5d4d3a"
		local MOSS_DK, MOSS, MOSS_LT = "#3c6638", "#55864a", "#7aab5a"
		local WATER, WATER_DK, WATER_HI = "#2d6b66", "#22524f", "#58a598"
		local LILY, LILY_DK, LILY_PINK, LILY_PINK_LT = "#4f9150", "#3b7542", "#f08cc8", "#ffc4e6"
		local REED, REED_DK, CATTAIL = "#6f9146", "#557236", "#5a3a26"
		local STONE_DK, STONE, STONE_LT = "#454e4d", "#5d6968", "#7b8986"
		local BARK_DK, BARK, BARK_LT, BARK_HI = "#2f2638", "#3f3349", "#54465f", "#6d5b7d"
		local LEAF = { "#23675d", "#2b7868", "#1d5a52" }
		local LEAF_TOP = { "#3a917a", "#47a585", "#358a74" }
		local LEAF_UNDER = "#16443f"
		local LEAF_VIO = { "#6a52a3", "#8064bd" }
		local HMOSS, HMOSS_LT = "#7d9b6c", "#9db786"
		local HUSK_DK, HUSK, HUSK_LT, HUSK_RIM = "#4a3478", "#6446a3", "#7d5fc0", "#b9a2f0"
		local VEIN = "#4fd6c4"
		local MOON, MOON_CORE, MOON_CYAN = "#e6f6ff", "#f2fcff", "#9ff0ff"
		local MOON_CR, MOON_CR2, MOON_RIM = "#fff1b8", "#ffe79a", "#fffbe0"
		local SHROOM, SHROOM_DK, SHROOM_STEM, SHROOM_DOT = "#2a8f8a", "#1f706c", "#d7e6d4", "#8ff8ef"
		local MOTH_W, MOTH_W2, MOTH_B, MOTH_DOT = "#cbd6ff", "#b2a3ee", "#efeaff", "#8ff4ff"
		local STEM = "#2a2433"

		local seed = 909091
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function polar(r, deg)
			local a = rad(deg)
			return math.sin(a) * r, -math.cos(a) * r
		end
		local function at(r, deg, y)
			local x, z = polar(r, deg)
			return v(x, y, z)
		end

		------------------------------------------------------------------
		-- STEPPED DARK-MUD MOUND (bone "Soil", parts "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(y0, y1, w, color, ox, oz)
			ox, oz = ox or 0, oz or 0
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(soil, v(w, h, w * 0.62), cf(ox, y, oz), color, S)
			B:block(soil, v(w * 0.62, h + 0.02, w), cf(ox, y, oz), color, S)
			B:block(soil, v(w * 0.85, h - 0.03, w * 0.85), cf(ox, y, oz), color, S)
		end
		oct(0, 1.1, 18.4, MUD_DK)
		oct(1.1, 2.1, 14.0, MUD)
		oct(2.1, 2.9, 9.2, MUD_LT, 0, 1.0)
		-- chunky edge blocks around the base
		for i = 0, 15 do
			local a = i * 22.5 + jit(5)
			local x, z = polar(8.7 + jit(0.3), a)
			local h = 0.9 + rnd() * 0.6
			B:block(soil, v(2.6 + rnd() * 0.7, h, 1.9 + rnd() * 0.4), cf(x, h / 2, z, 0, -a + jit(10), 0),
				i % 3 == 0 and MUD or (i % 2 == 0 and MUD_DK2 or MUD_DK), S)
		end
		for i = 0, 8 do
			local a = i * 40 + 70 + jit(8)
			if a % 360 > 120 or a % 360 < 60 then
				local x, z = polar(6.4 + jit(0.3), a)
				local h = 0.7 + rnd() * 0.4
				B:block(soil, v(2.2 + rnd() * 0.5, h, 1.6), cf(x, 1.1 + h / 2, z, 0, -a + jit(12), 0), i % 2 == 0 and MUD_LT or MUD, S)
			end
		end
		-- moss pads draped over the tier edges
		for _, m in { { 30, 8.0, 1.1, 2.6 }, { 100, 8.2, 1.1, 2.2 }, { 200, 8.1, 1.1, 2.8 }, { 255, 8.0, 1.1, 2.0 }, { 320, 8.2, 1.1, 2.4 },
			{ 160, 5.6, 2.1, 2.4 }, { 290, 5.7, 2.1, 2.6 }, { 220, 6.2, 2.1, 1.8 }, { 340, 3.8, 2.9, 2.0 }, { 150, 3.6, 2.9, 2.2 } } do
			local x, z = polar(m[2], m[1])
			B:block(soil, v(m[4], 0.3, m[4] * 0.75), cf(x, m[3] + 0.1, z, 0, -m[1] + jit(20), 0), (m[4] > 2.3) and MOSS or MOSS_LT, S)
			B:block(soil, v(m[4] * 0.6, 0.32, m[4] * 0.45), cf(x, m[3] + 0.18, z, 0, -m[1] + 30, 0), MOSS_DK, S)
		end

		-- murky puddle (front right, on tier 2) with lily pads
		do
			local px, pz = 3.0, -5.0
			B:block(soil, v(4.6, 0.3, 3.4), cf(px, 2.1 + 0.05, pz, 0, -8, 0), WATER_DK, S)
			B:block(soil, v(4.1, 0.3, 2.9), cf(px, 2.1 + 0.12, pz, 0, -8, 0), WATER, S)
			B:block(soil, v(1.4, 0.08, 0.25), cf(px - 0.8, 2.29, pz + 0.6, 0, -8, 0), WATER_HI, S)
			B:block(soil, v(0.9, 0.08, 0.25), cf(px + 1.0, 2.29, pz - 0.7, 0, -8, 0), WATER_HI, S)
			-- mud rim
			for _, r in { { -2.6, 0, 0.8, 3.2, 0 }, { 2.6, 0.2, 0.8, 3.0, 0 }, { 0, -1.95, 4.2, 0.8, 0 }, { 0.2, 1.95, 3.6, 0.8, 0 } } do
				B:block(soil, v(r[3], 0.5, r[4]), CFrame.new(px, 2.1 + 0.22, pz) * ang(0, -8, 0) * CFrame.new(r[1], 0, r[2]), MUD_DK, S)
			end
			B:block(soil, v(1.0, 0.55, 1.0), cf(px + 2.5, 2.4, pz - 1.6, 0, 30, 0), STONE, S)
			B:block(soil, v(0.7, 0.35, 0.7), cf(px + 2.6, 2.75, pz - 1.5, 0, 50, 0), STONE_LT, S)
			-- lily pads (two-block pads with a notch)
			for _, l in { { -1.0, -0.4, 20, 1.0 }, { 1.0, 0.5, -40, 0.85 }, { 0.6, -0.8, 70, 0.6 } } do
				local c = CFrame.new(px + l[1], 2.33, pz + l[2]) * ang(0, l[3], 0)
				B:block(soil, v(1.3 * l[4], 0.1, 1.3 * l[4]), c, LILY, S)
				B:block(soil, v(0.9 * l[4], 0.12, 0.9 * l[4]), c * CFrame.new(0.15, 0, 0.15) * ang(0, 45, 0), LILY_DK, S)
			end
			-- pink water lily
			local fc = CFrame.new(px - 1.0, 2.45, pz - 0.4)
			B:block(soil, v(0.75, 0.3, 0.75), fc * ang(0, 45, 0), LILY_PINK, S)
			B:block(soil, v(0.5, 0.42, 0.5), fc * CFrame.new(0, 0.12, 0), LILY_PINK_LT, S)
			B:block(soil, v(0.22, 0.2, 0.22), fc * CFrame.new(0, 0.38, 0), "#ffe27a", S)
		end

		-- mossy stones
		local function stone(x, y, z, s, yaw)
			B:block(soil, v(1.5 * s, 0.8 * s, 1.2 * s), cf(x, y + 0.4 * s, z, 0, yaw, 0), STONE, S)
			B:block(soil, v(1.0 * s, 0.5 * s, 0.9 * s), cf(x + 0.15 * s, y + 0.95 * s, z, 0, yaw + 15, 0), STONE_LT, S)
			B:block(soil, v(1.2 * s, 0.2 * s, 0.9 * s), cf(x - 0.1 * s, y + 1.25 * s, z, 0, yaw + 5, 0), MOSS, S)
		end
		stone(-7.6, 1.1, -3.2, 1.0, 20)
		stone(7.4, 1.1, 3.8, 0.9, -35)
		stone(-3.2, 2.1, 5.6, 0.8, 50)

		-- cattail reeds (thin stalks with brown heads)
		local function reed(x, y, z, h, lean, yaw)
			local c = CFrame.new(x, y, z) * ang(0, yaw, lean)
			B:block(soil, v(0.24, h, 0.24), c * CFrame.new(0, h / 2, 0), REED, S)
			B:block(soil, v(0.45, 1.0, 0.45), c * CFrame.new(0, h - 0.2, 0), CATTAIL, S)
			B:block(soil, v(0.12, 0.5, 0.12), c * CFrame.new(0, h + 0.5, 0), REED_DK, S)
		end
		reed(5.8, 2.1, -3.0, 3.4, -6, 10)
		reed(6.4, 2.1, -3.8, 2.6, -12, 40)
		reed(5.4, 2.1, -3.9, 2.9, 4, -20)
		reed(-6.6, 1.1, 2.4, 3.0, 8, 0)
		reed(-7.2, 1.1, 1.6, 2.2, 14, 30)
		-- grass blades
		for _, g in { { -5.6, 2.1, -2.6 }, { 1.0, 2.1, -6.4 }, { -8.0, 1.1, -0.2 }, { 4.2, 2.1, 4.8 }, { -1.2, 1.1, 8.2 }, { 8.4, 1.1, -1.2 } } do
			local yaw = rnd() * 90
			for k = -1, 1 do
				local h = (k == 0) and 1.2 or 0.85
				local c = CFrame.new(g[1], g[2], g[3]) * ang(0, yaw, 0) * ang(0, 0, k * 22) * CFrame.new(0, h / 2, 0)
				B:block(soil, v(0.2, h, 0.3), c, (k == 0) and MOSS_LT or MOSS, S)
			end
		end
		-- glowing teal toadstools
		local function toad(x, y, z, s)
			B:block(soil, v(0.45 * s, 1.0 * s, 0.45 * s), cf(x, y + 0.5 * s, z), SHROOM_STEM, S)
			B:block(soil, v(1.5 * s, 0.4 * s, 1.5 * s), cf(x, y + 1.1 * s, z, 0, 20, 0), SHROOM_DK, S)
			B:block(soil, v(1.1 * s, 0.4 * s, 1.1 * s), cf(x, y + 1.4 * s, z, 0, 65, 0), SHROOM, S)
			B:block(soil, v(0.28, 0.12, 0.28), cf(x + 0.3 * s, y + 1.62 * s, z - 0.15 * s, 0, 65, 0), SHROOM_DOT, { name = "Soil", mat = "Neon" })
		end
		toad(-5.4, 2.1, -4.2, 1.1)
		toad(-4.5, 2.1, -5.0, 0.75)
		toad(6.0, 1.1, 5.8, 0.9)
		toad(-2.6, 2.9, 3.6, 0.7)

		-- fallen half-open moon pod on the mound
		do
			local c = CFrame.new(-3.4, 2.9 + 0.55, -2.2) * ang(0, 35, 80)
			B:block(soil, v(0.9, 1.6, 0.9), c, MOON_CYAN, { name = "Soil", mat = "Neon" })
			B:block(soil, v(0.6, 2.2, 1.3), c * CFrame.new(-0.55, 0, 0) * ang(0, 0, 0), HUSK, S)
			B:block(soil, v(0.6, 2.0, 1.2), c * CFrame.new(0.75, 0, 0.1) * ang(0, 25, 0), HUSK_DK, S)
			B:block(soil, v(0.62, 0.3, 1.32), c * CFrame.new(-0.55, 0.4, 0), HUSK_RIM, S)
		end

		------------------------------------------------------------------
		-- TWISTED DARK TRUNK (bone "Crop")
		------------------------------------------------------------------
		local BASE = 2.9
		local TZ = 0.6
		local crop = B:bone("Crop", "Root", v(0, BASE, TZ))
		B:block(crop, v(5.4, 1.0, 5.4), cf(0, BASE + 0.35, TZ, 0, 12, 0), BARK_DK)
		B:block(crop, v(4.8, 1.0, 4.8), cf(0, BASE + 1.1, TZ, 0, -18, 0), BARK)
		-- gnarled roots arching into the mud
		for k = 0, 5 do
			local a = k * 60 + 25 + jit(10)
			local p1 = at(2.2, a, BASE + 1.0) + v(0, 0, TZ)
			local p2 = at(3.9, a + 8, BASE + 0.9) + v(0, 0, TZ)
			local p3 = at(5.4, a + 16, (k % 2 == 0) and 1.9 or 2.4) + v(0, 0, TZ)
			B:bar(crop, p1, p2, 1.4, 1.1, (k % 2 == 0) and BARK or BARK_DK)
			B:bar(crop, p2, p3, 0.9, 0.8, BARK_DK)
		end
		-- stacked twisting segments (gentle S-curve)
		local SEG = {
			-- width, y0, x off, yaw, colour
			{ 3.9, 1.5, 0.0, 0, BARK },
			{ 3.6, 3.1, 0.25, 22, BARK_DK },
			{ 3.3, 4.7, 0.45, 44, BARK },
			{ 3.1, 6.2, 0.3, 66, BARK_DK },
			{ 2.9, 7.6, -0.1, 88, BARK },
		}
		for _, s in SEG do
			B:block(crop, v(s[1], 1.75, s[1]), cf(s[3], BASE + s[2] + 0.85, TZ, 0, s[4], 0), s[5])
		end
		-- bark ridges spiralling up
		for _, a0 in { 10, 130, 250 } do
			local prev
			for i = 0, 4 do
				local t = i / 4
				local y = BASE + 1.4 + t * 7.6
				local r = 2.05 - t * 0.5
				local p = at(r, a0 + t * 120, y) + v(0.25 * math.sin(t * 3), 0, TZ)
				if prev then
					B:bar(crop, prev, p, 0.7, 0.65, (i % 2 == 0) and BARK_LT or BARK_HI)
				end
				prev = p
			end
		end
		-- glowing knot hollow (front)
		B:block(crop, v(1.6, 2.0, 0.5), cf(0.35, BASE + 4.6, TZ - 1.62), BARK_LT)
		B:block(crop, v(1.05, 1.4, 0.5), cf(0.35, BASE + 4.6, TZ - 1.72), "#120e18")
		B:block(crop, v(0.55, 0.55, 0.3), cf(0.35, BASE + 4.45, TZ - 1.8, 0, 0, 45), "#c59bff", { mat = "Neon", name = "HollowGlow" })
		-- moss patches on the trunk
		for _, m in { { 200, 2.6, 2.0 }, { 60, 5.2, 1.8 }, { 300, 7.4, 1.6 } } do
			local p = at(m[3], m[1], BASE + m[2]) + v(0, 0, TZ)
			B:block(crop, v(1.4, 0.9, 1.4), CFrame.new(p) * ang(0, -m[1], 0), MOSS, {})
			B:block(crop, v(0.9, 0.5, 1.5), CFrame.new(p + v(0, -0.5, 0)) * ang(0, -m[1] + 20, 0), MOSS_DK, {})
		end
		-- teal shelf fungi with glowing undersides
		for _, f in { { 110, 3.4, 1.9 }, { 240, 6.0, 1.7 } } do
			local o = at(1, f[1], 0)
			local p = at(f[3] + 0.6, f[1], BASE + f[2]) + v(0, 0, TZ)
			local c = CFrame.new(p) * ang(0, -f[1], 0)
			B:block(crop, v(1.8, 0.35, 1.2), c, SHROOM)
			B:block(crop, v(1.2, 0.3, 0.9), c * CFrame.new(0, 0.3, -0.1), SHROOM_DK)
			B:block(crop, v(1.3, 0.1, 0.8), c * CFrame.new(0, -0.22, 0), SHROOM_DOT, { mat = "Neon", name = "FungusGlow" })
			local _ = o
		end

		------------------------------------------------------------------
		-- CROOKED LIMBS + CANOPY (bone "Canopy")
		------------------------------------------------------------------
		local FORK = BASE + 8.0 -- 10.9
		B:block(crop, v(2.8, 1.6, 2.8), cf(-0.1, FORK - 0.2, TZ, 0, 70, 0), BARK_DK)
		local canopy = B:bone("Canopy", "Crop", v(0, FORK, TZ))
		local LIMBS = {}
		for k = 0, 4 do
			local a = 36 + k * 72 + jit(6)
			local p0 = at(0.6, a, FORK - 0.3) + v(0, 0, TZ)
			local p1 = at(3.2, a - 14, FORK + 2.6) + v(0, 0, TZ)
			local p2 = at(5.6, a + 8, FORK + 4.4) + v(0, 0, TZ)
			B:bar(crop, p0, p1, 1.5, 1.35, (k % 2 == 0) and BARK or BARK_DK)
			B:bar(canopy, p1 - (p1 - p0).Unit * 0.35, p2, 1.1, 1.0, (k % 2 == 0) and BARK_DK or BARK)
			-- crooked twig
			B:bar(canopy, p2, p2 + at(1.6, a + 60, 1.4) - v(0, 0, 0), 0.6, 0.6, BARK_LT)
			LIMBS[k + 1] = { a = a, p1 = p1, p2 = p2 }
		end
		B:bar(canopy, v(0, FORK + 0.5, TZ), v(0.4, FORK + 6.6, TZ + 0.2), 1.5, 1.5, BARK)

		-- leaf clumps
		local function clump(c, r, n, s, tilt)
			B:block(canopy, v(r * 1.7, 0.7, r * 1.7), CFrame.new(c - v(0, s * 0.45, 0)) * ang(0, rnd() * 90, 0), LEAF_UNDER)
			for i = 0, n - 1 do
				local a = i * 360 / n + rnd() * 30
				local p = c + at(r * (0.55 + rnd() * 0.3), a, jit(0.35))
				B:block(canopy, v(s + jit(0.3), s * 0.72, s + jit(0.3)), CFrame.new(p) * ang(jit(tilt), rnd() * 90, jit(tilt)), LEAF[1 + (i % #LEAF)])
			end
			B:block(canopy, v(s * 0.9, s * 0.62, s * 0.9), CFrame.new(c + v(jit(0.3), s * 0.4, jit(0.3))) * ang(jit(8), rnd() * 90, jit(8)), LEAF_TOP[1 + math.floor(rnd() * 3)])
		end
		local CLUMPS = {}
		for i, l in LIMBS do
			local c = l.p2 + v(0, 1.4, 0)
			clump(c, 2.6, 5, 2.4, 12)
			CLUMPS[i] = c
		end
		-- inner ring between limbs + crown
		for k = 0, 4 do
			local a = 72 + k * 72
			local c = at(3.2, a, FORK + 7.0) + v(0, 0, TZ)
			clump(c, 2.2, 4, 2.3, 10)
		end
		clump(v(0.3, FORK + 8.4, TZ + 0.2), 2.0, 4, 2.2, 8)
		-- crooked bare twigs poking out of the canopy (spooky swamp silhouette)
		for k = 0, 4 do
			local a = 72 * k + 72 + 20
			local p0 = at(5.6, a, FORK + 6.6) + v(0, 0, TZ)
			local p1 = at(7.0, a + 6, FORK + 8.0) + v(0, 0, TZ)
			local p2 = p1 + at(1.0, a + 70, 0.9)
			B:bar(canopy, p0, p1, 0.5, 0.5, BARK_LT)
			B:bar(canopy, p1, p2, 0.35, 0.35, BARK_HI)
		end
		-- violet leaf tips + small top caps scattered over the canopy
		for k = 0, 9 do
			local a = k * 36 + 10
			local r = (k % 2 == 0) and 6.6 or 4.4
			local y = (k % 2 == 0) and (FORK + 6.0) or (FORK + 8.6)
			B:block(canopy, v(1.2, 0.6, 1.2), CFrame.new(at(r, a, y) + v(0, 0, TZ)) * ang(jit(15), rnd() * 90, jit(15)), LEAF_VIO[1 + (k % 2)])
		end

		-- pixel-art crescent moon crowning the canopy (bone "CrownMoon"),
		-- cream body with a glowing inner rim
		local PX = 0.6
		local MC = v(0.3, FORK + 9.0 + 3 * PX, TZ + 0.2)
		local crown = B:bone("CrownMoon", "Canopy", MC - v(0, 3 * PX, 0))
		local ROWS = { "..XXX", ".XXX.", "XXX..", "XXX..", "XXX..", ".XXX.", "..XXX" }
		for r, row in ROWS do
			local c0, c1 = string.find(row, "X+")
			local n = c1 - c0 + 1
			local cx = ((c0 - 1) + n / 2 - 2.5) * PX - 0.1
			local cy = (4 - r) * PX
			B:block(crown, v(n * PX, PX, 1.3), CFrame.new(MC + v(cx, cy, 0)), (r % 2 == 0) and MOON_CR or MOON_CR2)
			B:block(crown, v(0.24, PX + 0.02, 1.35), CFrame.new(MC + v(cx + n * PX / 2 - 0.1, cy, 0)), MOON_RIM,
				{ mat = "Neon", name = "CrownGlow" })
		end
		-- leafy cradle under the moon
		B:block(crown, v(2.2, 0.6, 1.6), CFrame.new(MC + v(-0.4, -3.3 * PX - 0.3, 0)) * ang(0, 20, 0), LEAF_TOP[2])
		B:block(crown, v(1.4, 0.5, 1.4), CFrame.new(MC + v(-0.4, -3.3 * PX - 0.75, 0)) * ang(0, 60, 0), LEAF_VIO[1])

		------------------------------------------------------------------
		-- HANGING SWAMP MOSS (bones MossN on the canopy)
		------------------------------------------------------------------
		for i, l in LIMBS do
			local top = (l.p1 + l.p2) / 2 - v(0, 0.3, 0)
			local bone = B:bone("Moss" .. i, "Canopy", top)
			local len = 2.6 + (i % 2) * 1.0
			B:block(bone, v(0.7, len, 0.25), CFrame.new(top - v(0, len / 2, 0)) * ang(0, -l.a, 0), HMOSS)
			B:block(bone, v(0.45, len * 0.7, 0.3), CFrame.new(top - v(-0.3, len * 0.4, 0.05)) * ang(0, -l.a + 30, 0), HMOSS_LT)
			B:block(bone, v(0.3, len * 0.45, 0.3), CFrame.new(top - v(0.35, len * 0.85, -0.05)) * ang(0, -l.a, 0), HMOSS)
		end

		------------------------------------------------------------------
		-- MOON PODS (bones PodN facing outward, husk halves PodNL / PodNR)
		------------------------------------------------------------------
		local PODS = {
			-- deg, radius, top y, stem length, scale
			{ 0, 5.3, FORK + 4.4, 2.2, 1.2 },
			{ 60, 4.9, FORK + 5.0, 3.4, 1.0 },
			{ 120, 5.3, FORK + 4.4, 2.3, 1.2 },
			{ 180, 4.9, FORK + 5.0, 3.3, 1.0 },
			{ 240, 5.3, FORK + 4.4, 2.2, 1.2 },
			{ 300, 4.9, FORK + 5.0, 3.5, 1.0 },
		}
		for i, pd in PODS do
			local topP = at(pd[2], pd[1], pd[3]) + v(0, 0, TZ)
			local F = CFrame.new(topP) * CFrame.Angles(0, -rad(pd[1]), 0) -- local -Z = outward
			local pod = B:bone("Pod" .. i, "Canopy", F)
			local s = pd[5]
			local L = pd[4]
			local hTop = -L -- local y of the pod top
			local H = 3.3 * s
			local cy = hTop - H / 2
			-- stem + leaf calyx
			B:bar(pod, (F * CFrame.new(0, 0.6, 0)).Position, (F * CFrame.new(0, hTop + 0.1, 0)).Position, 0.35, 0.35, STEM)
			B:block(pod, v(1.7 * s, 0.3, 0.75 * s), F * CFrame.new(0, hTop + 0.1, 0) * ang(0, 30, 18), LEAF[2])
			B:block(pod, v(1.5 * s, 0.3, 0.75 * s), F * CFrame.new(0, hTop + 0.15, 0) * ang(0, -50, -18), LEAF_TOP[1])
			B:block(pod, v(0.9 * s, 0.5, 0.9 * s), F * CFrame.new(0, hTop - 0.1, 0) * ang(0, 45, 0), HUSK_DK)
			-- glowing moon core
			B:block(pod, v(1.1 * s, H * 0.72, 1.1 * s), F * CFrame.new(0, cy, 0), MOON_CORE, { mat = "Neon", name = "MoonCore" .. i })
			B:block(pod, v(0.45 * s, 0.6 * s, 0.45 * s), F * CFrame.new(0, cy - H * 0.5 - 0.1, 0) * ang(0, 45, 0), MOON_CYAN, { mat = "Neon", name = "MoonTip" .. i })
			-- husk halves (hinge at the top of the pod, opening sideways)
			for _, sd in { 1, -1 } do
				local nm = "Pod" .. i .. ((sd > 0) and "R" or "L")
				local hinge = F * CFrame.new(sd * 0.3 * s, hTop - 0.2, 0)
				local half = B:bone(nm, "Pod" .. i, hinge)
				local function hb(sx, sy, sz, x, y, z, col)
					B:block(half, v(sx * s, sy, sz * s), F * CFrame.new(sd * x * s, y, z * s), col)
				end
				hb(0.9, H * 0.6, 1.8, 0.75, cy, 0, HUSK)
				hb(0.75, H * 0.2, 1.45, 0.62, cy + H * 0.38, 0, HUSK_DK)
				hb(0.65, H * 0.2, 1.25, 0.56, cy - H * 0.38, 0, HUSK_DK)
				hb(0.45, H * 0.12, 0.85, 0.42, cy - H * 0.52, 0, HUSK)
				hb(0.35, H * 0.38, 1.45, 1.3, cy + 0.05, 0, HUSK_LT)
				hb(0.18, H * 0.66, 1.86, 0.33, cy, 0, HUSK_RIM)
				hb(0.22, H * 0.36, 0.1, 0.95, cy + 0.1, -0.95, VEIN)
			end
		end

		------------------------------------------------------------------
		-- MOON MOTHS (orbit bones -> body -> wings)
		------------------------------------------------------------------
		local MOTHS = {
			-- orbit y, radius, scale
			{ 10.4, 9.6, 1.25 },
			{ 6.8, 8.2, 1.05 },
		}
		for i, m in MOTHS do
			local orbit = B:bone("MothOrbit" .. i, "Root", v(0, m[1], TZ))
			local c = v(m[2], m[1], TZ) -- starts on +X, travelling toward -Z
			local body = B:bone("Moth" .. i, "MothOrbit" .. i, c)
			local s = m[3]
			B:block(body, v(0.6 * s, 0.6 * s, 1.7 * s), CFrame.new(c), MOTH_B)
			B:block(body, v(0.7 * s, 0.7 * s, 0.6 * s), CFrame.new(c + v(0, 0.05, -1.0 * s)), MOTH_W2)
			B:block(body, v(0.12, 0.12, 0.9 * s), CFrame.new(c + v(0.22 * s, 0.45 * s, -1.55 * s)) * ang(30, 20, 0), MOTH_W2)
			B:block(body, v(0.12, 0.12, 0.9 * s), CFrame.new(c + v(-0.22 * s, 0.45 * s, -1.55 * s)) * ang(30, -20, 0), MOTH_W2)
			for _, sd in { 1, -1 } do
				local side = (sd > 0) and "R" or "L"
				local wing = B:bone("Moth" .. i .. "Wing" .. side, "Moth" .. i, c + v(sd * 0.3 * s, 0, 0))
				B:block(wing, v(1.9 * s, 0.14, 1.4 * s), CFrame.new(c + v(sd * 1.2 * s, 0.05, -0.3 * s)) * ang(0, sd * 10, 0), MOTH_W)
				B:block(wing, v(1.3 * s, 0.14, 1.0 * s), CFrame.new(c + v(sd * 1.0 * s, 0.0, 0.7 * s)) * ang(0, -sd * 20, 0), MOTH_W2)
				B:block(wing, v(0.45 * s, 0.16, 0.45 * s), CFrame.new(c + v(sd * 1.45 * s, 0.07, -0.35 * s)), MOTH_DOT, { mat = "Neon", name = "MothDot" })
			end
			B:trail("Moth" .. i, c + v(0, 0.35 * s, 0.6), c + v(0, -0.35 * s, 0.6),
				{ name = "MothTrail" .. i, color = { "#c8f6ff", "#b7a2ff" }, life = 0.9, width = { 1, 0 }, trans = { 0.35, 1 } })
			local dust = B:block(body, v(0.5, 0.5, 0.5), CFrame.new(c), MOTH_B, { tr = 1, name = "MothDustCore" .. i })
			B:emitter(dust, "sparkle", { name = "MothDust" .. i, color = { "#ffffff", MOON_CYAN, "#c7b4ff" }, rate = 7, size = { 0.15, 0.35, 0 }, life = { 0.8, 1.4 }, speed = { 0.1, 0.4 }, accel = { 0, -1.2, 0 }, light = 0.8 })
		end

		------------------------------------------------------------------
		-- VFX: 8 emitters, 2 lights, 2 trails (moths)
		------------------------------------------------------------------
		local podY = FORK + 2.6
		local sparkZone = B:block(canopy, v(15, 9, 15), cf(0, FORK + 5.0, TZ), MOON, { tr = 1, name = "SparkZone" })
		B:emitter(sparkZone, "sparkle", { name = "MoonSparkles", color = { "#ffffff", MOON_CYAN, "#d2c2ff" }, rate = 14, size = { 0.15, 0.6, 0 }, life = { 1.0, 1.8 }, speed = { 0.2, 0.6 }, light = 1 })
		local podZone = B:block(canopy, v(12, 3.5, 12), cf(0, podY, TZ), MOON, { tr = 1, name = "PodZone" })
		B:emitter(podZone, "burst", { name = "MoonBurst", color = { "#ffffff", MOON_CYAN, "#b89cff" }, size = { 0.7, 0.45, 0 }, speed = { 5, 11 }, life = { 0.6, 1.3 }, drag = 2.5, light = 1 })
		B:emitter(podZone, "ember", { name = "MoonMotes", color = { MOON_CYAN, "#d9ccff", "#ffffff" }, rate = 0, size = { 0.35, 0.3, 0 }, life = { 2.0, 3.2 }, speed = { 1.5, 3.5 }, spread = 50, accel = { 0, 1.2, 0 }, light = 1 })
		local flyZone = B:block(soil, v(16, 7, 16), cf(0, 6.5, TZ), MOSS, { tr = 1, name = "FlyZone" })
		B:emitter(flyZone, "sparkle", { name = "Fireflies", color = { "#e9ff7a", "#b8ff5c" }, rate = 5, size = { 0.25, 0.3, 0 }, trans = { 0.1, 0, 1 }, life = { 2.5, 4 }, speed = { 0.2, 0.6 }, accel = { 0, 0.3, 0 }, light = 1 })
		local mistZone = B:block(soil, v(4, 0.4, 3), cf(3.0, 2.5, -5.0), WATER, { tr = 1, name = "MistZone" })
		B:emitter(mistZone, "smoke", { name = "PuddleMist", color = { "#cfeee9", "#a9d9e0" }, rate = 2.5, size = { 0.8, 2.0, 2.8 }, trans = { 0.6, 0.72, 1 }, life = { 2.5, 4 }, speed = { 0.2, 0.5 }, spread = 60, accel = { -0.2, 0.25, 0 } })
		local glowZone = B:block(canopy, v(11, 2, 11), cf(0, podY - 0.6, TZ), MOON, { tr = 1, name = "GlowZone" })
		B:emitter(glowZone, "glow", { name = "PodGlow", color = { "#e6fbff", MOON_CYAN }, rate = 2, size = { 1.4, 2.4, 0.6 }, trans = { 0.8, 0.72, 1 }, light = 1 })
		local moonLightPart = B:block(canopy, v(0.4, 0.4, 0.4), cf(0, podY, TZ), MOON, { tr = 1, name = "MoonLightCore" })
		B:light(moonLightPart, { name = "MoonLight", color = "#a8ecff", brightness = 1.2, range = 18 })
		local hollowLightPart = B:block(crop, v(0.3, 0.3, 0.3), cf(0.35, BASE + 4.5, TZ - 2.3), MOON, { tr = 1, name = "HollowLightCore" })
		B:light(hollowLightPart, { name = "HollowLight", color = "#b98cff", brightness = 0.9, range = 9 })
	end,
}
