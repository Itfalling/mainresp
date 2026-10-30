--!nocheck
-- Ancient Bog Willow (Misty Swamp crop #10, Apex): the showpiece of the swamp.
-- A colossal weeping willow leaning over a murky pond.
-- * a big stepped dark-mud mound (bone "Soil", parts "Soil") with moss pads,
--   a wide teal POND in front (lily pads, pink water lilies, stepping
--   stones, highlights), cattails, reeds, mossy stones and glowing toadstools
-- * a massive gnarled grey-green trunk (bone "Crop") leaning over the pond,
--   with arching roots that dip into the water, bark ridges, moss streaks and
--   glowing shelf fungi
-- * a wide domed canopy of sage / teal leaf cubes (bones Canopy -> CanopyTop)
-- * fourteen long LEAF CURTAINS around the rim, each a two-bone chain
--   (CurtNa -> CurtNb, facing outward) so they sway in a breeze that runs
--   around the tree, plus six shorter inner strands (InnerN)
-- * seven WISP FRUITS (bones WispN) hanging between the curtains: ghostly
--   translucent orbs around neon cores (cyan / violet) with curling wisp
--   tails, plus a big GRAND WISP (bone GrandWisp) hanging over the pond
-- * fireflies on three orbit bones (FlyOrbitN), each with a glowing trail
-- * VFX: pond fog, pond bubbles, wisp sparkles, wisp glow, firefly motes,
--   falling willow leaves, the spirit burst + rising wisp motes on the beat;
--   three lights; six firefly trails.
-- Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Ancient Bog Willow",
	Rarity = "Apex",
	Element = "Spirit",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ------------------------------------------------------------
		local MUD_DK2, MUD_DK, MUD, MUD_LT = "#33291f", "#3e3226", "#4d3f30", "#5d4d3a"
		local MOSS_DK, MOSS, MOSS_LT = "#3c6638", "#55864a", "#7aab5a"
		local WATER_DK, WATER, WATER_HI, WATER_HI2 = "#1f4c4a", "#2b6b66", "#5aa89a", "#86cdbd"
		local LILY, LILY_DK, LILY_PINK, LILY_PINK_LT, LILY_Y = "#4f9150", "#3b7542", "#f08cc8", "#ffc4e6", "#ffe27a"
		local REED, REED_DK, CATTAIL = "#6f9146", "#557236", "#5a3a26"
		local STONE_DK, STONE, STONE_LT = "#454e4d", "#5d6968", "#7b8986"
		local BARK_DK, BARK, BARK_LT, BARK_HI = "#3b352c", "#4d463a", "#625a4a", "#7a705c"
		local W_UNDER = "#2f5e47"
		local W1 = { "#4e8c5f", "#5d9e68", "#447f57" }
		local W2 = { "#68a96f", "#79b878", "#5d9c68" }
		local W3 = { "#8cc584", "#9fd18f", "#7fbb7c" }
		local W_TOP = { "#a9d998", "#b8e2a2", "#97cc8b" }
		local CURT = { "#5c9d68", "#73b274", "#4f8f5f", "#86c180" }
		local W_VIO = { "#7a62b8", "#9479cf" }
		local TWIG = "#5d6b45"
		local SHROOM, SHROOM_DK, SHROOM_STEM, SHROOM_DOT = "#2a8f8a", "#1f706c", "#d7e6d4", "#8ff8ef"
		local WISP_SHELL = "#c8f7ff"
		local WISP_C = { "#9ff8ff", "#d9b0ff" }
		local WISP_TAIL = { "#bdf3ff", "#e3c9ff" }
		local FLY, FLY_BODY = "#eaff6e", "#3a3a2a"

		local seed = 4242421
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
		-- STEPPED MUD MOUND (bone "Soil", parts "Soil")
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
		oct(0, 1.3, 26.5, MUD_DK)
		oct(1.3, 2.5, 21.5, MUD)
		oct(2.5, 3.5, 12.5, MUD_LT, 0, 4.0)
		for i = 0, 19 do
			local a = i * 18 + jit(4)
			local x, z = polar(12.6 + jit(0.3), a)
			local h = 1.1 + rnd() * 0.7
			B:block(soil, v(3.2 + rnd() * 0.8, h, 2.2 + rnd() * 0.4), cf(x, h / 2, z, 0, -a + jit(10), 0),
				i % 3 == 0 and MUD or (i % 2 == 0 and MUD_DK2 or MUD_DK), S)
		end
		for _, a in { 60, 95, 130, 165, 200, 235, 270, 305 } do
			local x, z = polar(9.8 + jit(0.3), a + jit(6))
			local h = 0.8 + rnd() * 0.4
			B:block(soil, v(2.6 + rnd() * 0.5, h, 1.8), cf(x, 1.3 + h / 2, z, 0, -a + jit(12), 0), (rnd() > 0.5) and MUD_LT or MUD, S)
		end
		-- moss pads
		for _, m in { { 20, 11.8, 1.3, 3.0 }, { 75, 12.0, 1.3, 2.4 }, { 140, 11.8, 1.3, 3.2 }, { 200, 12.0, 1.3, 2.6 }, { 250, 11.8, 1.3, 2.8 }, { 330, 12.0, 1.3, 2.4 },
			{ 110, 8.6, 2.5, 2.8 }, { 250, 8.8, 2.5, 2.6 }, { 160, 8.2, 2.5, 2.2 }, { 70, 7.0, 3.5, 2.4 }, { 290, 6.8, 3.5, 2.2 } } do
			local x, z = polar(m[2], m[1])
			B:block(soil, v(m[4], 0.32, m[4] * 0.75), cf(x, m[3] + 0.1, z, 0, -m[1] + jit(20), 0), (m[4] > 2.5) and MOSS or MOSS_LT, S)
			B:block(soil, v(m[4] * 0.6, 0.34, m[4] * 0.45), cf(x, m[3] + 0.18, z, 0, -m[1] + 30, 0), MOSS_DK, S)
		end

		-- THE POND (front, sunk into tier 2)
		local PX, PZ, PY = -0.4, -5.6, 2.5
		do
			local c = CFrame.new(PX, PY, PZ)
			B:block(soil, v(12.4, 0.3, 6.4), c * CFrame.new(0, 0.05, 0), WATER_DK, S)
			B:block(soil, v(9.6, 0.31, 8.0), c * CFrame.new(0, 0.05, -0.2), WATER_DK, S)
			B:block(soil, v(11.6, 0.3, 5.7), c * CFrame.new(0, 0.14, 0), WATER, S)
			B:block(soil, v(8.9, 0.31, 7.3), c * CFrame.new(0, 0.14, -0.2), WATER, S)
			for _, h in { { -3.2, -1.2, 2.2 }, { 2.4, 1.6, 1.6 }, { 0.4, -2.6, 1.2 }, { -1.0, 2.2, 1.0 } } do
				B:block(soil, v(h[3], 0.08, 0.28), c * CFrame.new(h[1], 0.32, h[2]), (h[3] > 1.5) and WATER_HI or WATER_HI2, S)
			end
			-- mud + stone rim
			for _, r in { { -6.4, 0, 0.9, 5.4 }, { 6.4, 0.2, 0.9, 5.2 }, { -3.4, -3.75, 5.0, 0.9 }, { 3.0, -3.75, 5.2, 0.9 }, { -4.6, 3.0, 2.8, 0.8 }, { 4.6, 3.0, 2.8, 0.8 } } do
				B:block(soil, v(r[3], 0.55, r[4]), c * CFrame.new(r[1], 0.25, r[2]), MUD_DK, S)
			end
			for _, st in { { -6.0, -3.0, 1.1 }, { 6.2, -2.6, 1.0 }, { -6.4, 2.4, 0.9 }, { 0.6, -4.2, 0.9 } } do
				B:block(soil, v(st[3] * 1.3, st[3] * 0.7, st[3]), c * CFrame.new(st[1], 0.45, st[2]) * ang(0, rnd() * 90, 0), STONE, S)
				B:block(soil, v(st[3] * 0.8, st[3] * 0.4, st[3] * 0.7), c * CFrame.new(st[1] + 0.1, 0.85, st[2]) * ang(0, rnd() * 90, 0), MOSS, S)
			end
			-- stepping stones
			for _, st in { { 3.6, -1.4 }, { 2.0, -0.2 } } do
				B:block(soil, v(1.2, 0.35, 1.0), c * CFrame.new(st[1], 0.33, st[2]) * ang(0, rnd() * 60, 0), STONE_LT, S)
			end
			-- lily pads + water lilies
			for i, l in { { -4.0, -1.8, 20, 1.3 }, { -2.0, 1.2, -40, 1.0 }, { 1.0, -2.2, 70, 1.2 }, { 4.6, 1.4, 10, 1.0 }, { -4.8, 1.4, 50, 0.8 } } do
				local lc = c * CFrame.new(l[1], 0.35, l[2]) * ang(0, l[3], 0)
				B:block(soil, v(1.5 * l[4], 0.1, 1.5 * l[4]), lc, LILY, S)
				B:block(soil, v(1.0 * l[4], 0.12, 1.0 * l[4]), lc * CFrame.new(0.2, 0, 0.2) * ang(0, 45, 0), LILY_DK, S)
				if i % 2 == 1 then
					B:block(soil, v(0.85, 0.32, 0.85), lc * CFrame.new(-0.1, 0.18, -0.1) * ang(0, 45, 0), LILY_PINK, S)
					B:block(soil, v(0.55, 0.45, 0.55), lc * CFrame.new(-0.1, 0.3, -0.1), LILY_PINK_LT, S)
					B:block(soil, v(0.24, 0.2, 0.24), lc * CFrame.new(-0.1, 0.58, -0.1), LILY_Y, S)
				end
			end
		end

		-- mossy stones
		local function stone(x, y, z, s, yaw)
			B:block(soil, v(1.6 * s, 0.9 * s, 1.3 * s), cf(x, y + 0.45 * s, z, 0, yaw, 0), STONE, S)
			B:block(soil, v(1.1 * s, 0.55 * s, 1.0 * s), cf(x + 0.15 * s, y + 1.05 * s, z, 0, yaw + 15, 0), STONE_LT, S)
			B:block(soil, v(1.3 * s, 0.2 * s, 1.0 * s), cf(x - 0.1 * s, y + 1.38 * s, z, 0, yaw + 5, 0), MOSS, S)
		end
		stone(-10.6, 1.3, 2.4, 1.1, 20)
		stone(10.4, 1.3, 4.2, 1.0, -35)
		stone(-4.6, 3.5, 8.0, 0.8, 50)

		-- cattails
		local function reed(x, y, z, h, lean, yaw)
			local c = CFrame.new(x, y, z) * ang(0, yaw, lean)
			B:block(soil, v(0.26, h, 0.26), c * CFrame.new(0, h / 2, 0), REED, S)
			B:block(soil, v(0.5, 1.1, 0.5), c * CFrame.new(0, h - 0.2, 0), CATTAIL, S)
			B:block(soil, v(0.12, 0.55, 0.12), c * CFrame.new(0, h + 0.55, 0), REED_DK, S)
		end
		reed(6.6, 2.5, -8.0, 3.8, -8, 10)
		reed(7.4, 2.5, -7.2, 3.0, -14, 40)
		reed(6.0, 2.5, -8.8, 3.2, 5, -20)
		reed(-7.2, 2.5, -8.0, 3.4, 8, 0)
		reed(-8.0, 2.5, -7.2, 2.6, 14, 30)
		reed(-9.6, 1.3, 6.4, 3.0, 8, 60)
		reed(9.4, 1.3, -2.0, 2.8, -10, 15)
		-- grass tufts
		for _, g in { { -9.0, 2.5, -2.8 }, { 9.4, 2.5, 0.8 }, { -11.0, 1.3, -5.2 }, { 4.2, 3.5, 6.8 }, { -1.8, 1.3, 11.8 }, { 11.4, 1.3, -6.0 } } do
			local yaw = rnd() * 90
			for k = -1, 1 do
				local h = (k == 0) and 1.3 or 0.9
				local c = CFrame.new(g[1], g[2], g[3]) * ang(0, yaw, 0) * ang(0, 0, k * 22) * CFrame.new(0, h / 2, 0)
				B:block(soil, v(0.22, h, 0.32), c, (k == 0) and MOSS_LT or MOSS, S)
			end
		end
		-- glowing toadstools
		local function toad(x, y, z, s, neon)
			B:block(soil, v(0.5 * s, 1.1 * s, 0.5 * s), cf(x, y + 0.55 * s, z), SHROOM_STEM, S)
			B:block(soil, v(1.6 * s, 0.42 * s, 1.6 * s), cf(x, y + 1.2 * s, z, 0, 20, 0), SHROOM_DK, S)
			B:block(soil, v(1.15 * s, 0.42 * s, 1.15 * s), cf(x, y + 1.52 * s, z, 0, 65, 0), SHROOM, S)
			if neon then
				B:block(soil, v(0.3, 0.12, 0.3), cf(x + 0.3 * s, y + 1.76 * s, z - 0.15 * s, 0, 65, 0), SHROOM_DOT, { name = "Soil", mat = "Neon" })
			end
		end
		toad(-8.8, 2.5, 1.0, 1.3, true)
		toad(-9.6, 2.5, 0.0, 0.8, false)
		toad(8.6, 2.5, 3.6, 1.1, true)
		toad(3.6, 3.5, 7.4, 0.9, true)
		toad(10.8, 1.3, -7.4, 0.9, false)

		------------------------------------------------------------------
		-- MASSIVE GNARLED TRUNK (bone "Crop"), leaning over the pond
		------------------------------------------------------------------
		local BASE = 3.5
		local TZ = 4.0
		local crop = B:bone("Crop", "Root", v(0, BASE, TZ))
		B:block(crop, v(7.6, 1.2, 7.6), cf(0, BASE + 0.4, TZ, 0, 12, 0), BARK_DK)
		B:block(crop, v(6.8, 1.2, 6.8), cf(0, BASE + 1.3, TZ, 0, -16, 0), BARK)
		-- roots: back roots into the mud, front roots arch into the pond
		for k = 0, 6 do
			local a = k * (360 / 7) + 10 + jit(6)
			local front = math.cos(rad(a)) > 0.55
			local p1 = at(3.0, a, BASE + 1.2) + v(0, 0, TZ)
			local p2 = at(front and 6.0 or 5.2, a + 6, front and (BASE + 2.0) or (BASE + 0.9)) + v(0, 0, TZ)
			local p3 = at(front and 8.4 or 7.2, a + 12, front and 2.4 or 2.2) + v(0, 0, TZ)
			B:bar(crop, p1, p2, 1.9, 1.5, (k % 2 == 0) and BARK or BARK_DK)
			B:bar(crop, p2, p3, 1.2, 1.1, BARK_DK)
		end
		-- stacked twisting segments, leaning forward (-Z) as they rise
		local SEG = {
			-- width, y0, z off, yaw, colour
			{ 5.8, 1.8, 0.0, 0, BARK },
			{ 5.4, 3.7, -0.3, 18, BARK_DK },
			{ 5.0, 5.6, -0.7, 36, BARK },
			{ 4.7, 7.5, -1.1, 54, BARK_DK },
			{ 4.4, 9.4, -1.6, 72, BARK },
			{ 4.1, 11.3, -2.1, 90, BARK_DK },
			{ 3.8, 13.1, -2.6, 108, BARK },
		}
		for _, s in SEG do
			B:block(crop, v(s[1], 2.0, s[1]), cf(0, BASE + s[2] + 1.0, TZ + s[3], 0, s[4], 0), s[5])
		end
		-- bark ridges spiralling up
		for _, a0 in { 30, 150, 270 } do
			local prev
			for i = 0, 5 do
				local t = i / 5
				local y = BASE + 2.0 + t * 12.0
				local r = 3.0 - t * 0.9
				local p = at(r, a0 + t * 140, y) + v(0, 0, TZ - t * 2.6)
				if prev then
					B:bar(crop, prev, p, 0.9, 0.8, (i % 2 == 0) and BARK_LT or BARK_HI)
				end
				prev = p
			end
		end
		-- moss streaks + glowing shelf fungi
		for _, m in { { 200, 3.0, 2.9 }, { 60, 6.4, 2.6 }, { 300, 9.6, 2.3 }, { 150, 12.0, 2.1 } } do
			local p = at(m[3], m[1], BASE + m[2]) + v(0, 0, TZ - m[2] * 0.2)
			B:block(crop, v(1.8, 1.1, 1.8), CFrame.new(p) * ang(0, -m[1], 0), MOSS)
			B:block(crop, v(1.1, 0.7, 1.9), CFrame.new(p + v(0, -0.7, 0)) * ang(0, -m[1] + 20, 0), MOSS_DK)
		end
		for _, f in { { 100, 4.6, 2.9 }, { 250, 8.4, 2.6 }, { 20, 11.0, 2.3 } } do
			local p = at(f[3] + 0.7, f[1], BASE + f[2]) + v(0, 0, TZ - f[2] * 0.2)
			local c = CFrame.new(p) * ang(0, -f[1], 0)
			B:block(crop, v(2.2, 0.4, 1.4), c, SHROOM)
			B:block(crop, v(1.4, 0.35, 1.0), c * CFrame.new(0, 0.35, -0.1), SHROOM_DK)
			B:block(crop, v(1.6, 0.1, 0.9), c * CFrame.new(0, -0.25, 0), SHROOM_DOT, { mat = "Neon", name = "FungusGlow" })
		end
		-- big boughs reaching out under the canopy
		local TOPY = BASE + 15.2 -- 18.7
		local TOPZ = TZ - 3.0
		local BOUGHS = {}
		for k = 0, 4 do
			local a = k * 72 + 36
			local p0 = v(0, TOPY - 1.5, TOPZ)
			local p1 = at(4.6, a, TOPY + 1.6) + v(0, 0, TOPZ)
			B:bar(crop, p0, p1, 1.8, 1.6, (k % 2 == 0) and BARK or BARK_DK)
			BOUGHS[k + 1] = p1
		end
		B:block(crop, v(3.6, 2.0, 3.6), cf(0, TOPY, TOPZ, 0, 30, 0), BARK_DK)

		------------------------------------------------------------------
		-- DOMED CANOPY (bones Canopy -> CanopyTop)
		------------------------------------------------------------------
		local CZ = 0.6 -- canopy centre z (overhangs the pond)
		local canopy = B:bone("Canopy", "Crop", v(0, TOPY + 1.0, TOPZ))
		for k, p1 in BOUGHS do
			local a = (k - 1) * 72 + 36
			B:bar(canopy, p1 - v(0, 0.3, 0), at(8.6, a + 8, TOPY + 3.4) + v(0, 0, CZ), 1.1, 1.0, BARK_LT)
		end
		local Y1 = TOPY + 4.6
		-- underside plates
		B:block(canopy, v(20, 0.8, 12.4), cf(0, Y1 - 1.5, CZ), W_UNDER)
		B:block(canopy, v(12.4, 0.82, 20), cf(0, Y1 - 1.5, CZ), W_UNDER)
		B:block(canopy, v(17, 0.78, 17), cf(0, Y1 - 1.5, CZ, 0, 22, 0), W_UNDER)
		local RIM = {}
		local function ring(bone, n, r, y, s, h, cols, phase)
			for i = 0, n - 1 do
				local a = i * 360 / n + phase + jit(4)
				local p = at(r + jit(0.3), a, y + jit(0.3)) + v(0, 0, CZ)
				B:block(bone, v(s + jit(0.3), h, s + jit(0.3)), CFrame.new(p) * ang(jit(8), rnd() * 90, jit(8)), cols[1 + (i % #cols)])
				table.insert(RIM, { p = p, a = a, r = r, bone = bone })
			end
		end
		ring(canopy, 16, 10.0, Y1, 4.4, 2.8, W1, 0)
		ring(canopy, 12, 7.2, Y1 + 2.3, 4.6, 2.8, W2, 12)
		B:block(canopy, v(9, 3.0, 9), cf(0, Y1 + 1.6, CZ, 0, 15, 0), W1[3])
		local canopyTop = B:bone("CanopyTop", "Canopy", v(0, Y1 + 3.6, CZ))
		ring(canopyTop, 8, 4.4, Y1 + 4.9, 4.2, 2.6, W3, 30)
		ring(canopyTop, 4, 1.6, Y1 + 7.0, 3.8, 2.4, W_TOP, 10)
		B:block(canopyTop, v(6, 2.4, 6), cf(0, Y1 + 5.2, CZ, 0, 40, 0), W3[2])
		-- top highlights + violet accent leaves
		for k = 0, 9 do
			local a = k * 36 + 15
			local r = (k % 2 == 0) and 8.2 or 5.6
			local y = (k % 2 == 0) and (Y1 + 1.8) or (Y1 + 4.2)
			local bone = (k % 2 == 0) and canopy or canopyTop
			local col = (k % 3 == 0) and W_VIO[1 + (k % 2)] or W_TOP[1 + (k % 3)]
			B:block(bone, v(1.8, 0.8, 1.8), CFrame.new(at(r, a, y) + v(0, 0, CZ)) * ang(jit(12), rnd() * 90, jit(12)), col)
		end

		------------------------------------------------------------------
		-- LEAF CURTAINS (CurtNa -> CurtNb, facing outward) + inner strands
		------------------------------------------------------------------
		local NC = 14
		local CTOP = Y1 - 1.4
		local function leaves(bone, F, y0, y1, n, wdt, col0)
			-- a twig + n leaf panels between local y0 (top) and y1 (bottom)
			B:bar(bone, (F * CFrame.new(0, y0 + 0.3, 0)).Position, (F * CFrame.new(0, y1, 0)).Position, 0.3, 0.3, TWIG)
			for j = 0, n - 1 do
				local y = y0 - (j + 0.5) * (y0 - y1) / n
				local wj = wdt * (1 - 0.12 * j)
				local side = (j % 2 == 0) and 1 or -1
				B:block(bone, v(wj, 1.7, 0.55), F * CFrame.new(side * 0.25, y, jit(0.15)) * ang(jit(6), jit(12), side * 8),
					CURT[1 + ((j + col0) % #CURT)])
			end
		end
		for i = 1, NC do
			local a = (i - 1) * 360 / NC + 6
			local top = at(10.6, a, CTOP) + v(0, 0, CZ)
			local F = CFrame.new(top) * CFrame.Angles(0, -rad(a), 0)
			local La = 5.6 + ((i % 3 == 0) and 0.8 or 0)
			local Lb = 5.0 + ((i % 2 == 0) and 1.0 or 0)
			local ba = B:bone("Curt" .. i .. "a", "Canopy", F)
			leaves(ba, F, 0, -La, 3, 2.3, i)
			local Fb = F * CFrame.new(0, -La + 0.2, 0)
			local bb = B:bone("Curt" .. i .. "b", "Curt" .. i .. "a", Fb)
			leaves(bb, Fb, 0, -Lb, 3, 1.9, i + 1)
			B:block(bb, v(0.9, 0.9, 0.45), Fb * CFrame.new(0, -Lb - 0.3, 0) * ang(0, 0, 45), CURT[1 + (i % #CURT)])
		end
		for i = 1, 6 do
			local a = (i - 1) * 60 + 30
			local top = at(6.6, a, CTOP - 0.2) + v(0, 0, CZ)
			local F = CFrame.new(top) * CFrame.Angles(0, -rad(a), 0)
			local bone = B:bone("Inner" .. i, "Canopy", F)
			leaves(bone, F, 0, -4.6, 3, 1.9, i + 2)
		end

		------------------------------------------------------------------
		-- WISP FRUITS (bones WispN) + GRAND WISP over the pond
		------------------------------------------------------------------
		local function wisp(name, parent, top, deg, L, s, k)
			local F = CFrame.new(top) * CFrame.Angles(0, -rad(deg), 0)
			local bone = B:bone(name, parent, F)
			local c = -L - 1.0 * s
			B:bar(bone, (F * CFrame.new(0, 0.5, 0)).Position, (F * CFrame.new(0, c + 0.6 * s, 0)).Position, 0.3, 0.3, TWIG)
			B:block(bone, v(1.3 * s, 0.25, 0.6 * s), F * CFrame.new(0, -L + 0.05, 0) * ang(0, 30, 16), CURT[2])
			B:block(bone, v(1.1 * s, 0.25, 0.55 * s), F * CFrame.new(0, -L + 0.1, 0) * ang(0, -60, -16), CURT[4])
			B:block(bone, v(0.95 * s, 0.95 * s, 0.95 * s), F * CFrame.new(0, c, 0) * ang(0, 45, 0), WISP_C[k], { mat = "Neon", name = name .. "Core" })
			B:block(bone, v(1.7 * s, 1.15 * s, 1.15 * s), F * CFrame.new(0, c, 0), WISP_SHELL, { tr = 0.45 })
			B:block(bone, v(1.15 * s, 1.7 * s, 1.15 * s), F * CFrame.new(0, c, 0), WISP_SHELL, { tr = 0.45 })
			B:block(bone, v(1.15 * s, 1.15 * s, 1.7 * s), F * CFrame.new(0, c, 0), WISP_SHELL, { tr = 0.45 })
			-- curling wisp tail
			B:block(bone, v(0.6 * s, 0.6 * s, 0.6 * s), F * CFrame.new(0.3 * s, c - 1.05 * s, 0), WISP_TAIL[k], { tr = 0.15 })
			B:block(bone, v(0.42 * s, 0.42 * s, 0.42 * s), F * CFrame.new(0.65 * s, c - 1.5 * s, 0.1), WISP_TAIL[k], { tr = 0.2 })
			B:block(bone, v(0.26 * s, 0.26 * s, 0.26 * s), F * CFrame.new(0.5 * s, c - 1.85 * s, 0.2), WISP_C[k], { mat = "Neon", name = name .. "Tip" })
			return bone
		end
		local WISPS = {
			-- deg, length, scale
			{ 20, 2.4, 1.15 }, { 72, 4.0, 1.0 }, { 124, 2.6, 1.15 }, { 176, 3.8, 1.0 },
			{ 228, 2.4, 1.15 }, { 280, 4.0, 1.0 }, { 332, 2.6, 1.15 },
		}
		for i, wd in WISPS do
			local top = at(8.4, wd[1], CTOP - 0.1) + v(0, 0, CZ)
			wisp("Wisp" .. i, "Canopy", top, wd[1], wd[2], wd[3], 1 + (i % 2))
		end
		local gw = wisp("GrandWisp", "Canopy", v(0.2, CTOP - 0.1, CZ - 4.6), 0, 3.0, 1.75, 1)
		local gF = CFrame.new(0.2, CTOP - 0.1 - 3.0 - 1.75, CZ - 4.6)
		for k = 0, 3 do
			B:block(gw, v(1.2, 0.3, 0.5), gF * CFrame.Angles(0, rad(k * 90 + 45), 0) * CFrame.new(0, 1.6, -0.9) * ang(-30, 0, 0), W_VIO[1 + (k % 2)])
		end

		------------------------------------------------------------------
		-- FIREFLIES on orbit bones (each with a trail)
		------------------------------------------------------------------
		local ORBITS = {
			-- y, { {radius, angle, dy}, ... }
			{ 9.0, { { 12.6, 0, 0 }, { 12.0, 180, 1.2 } } },
			{ 6.4, { { 8.8, 90, 0 }, { 9.4, 270, -0.6 } } },
			{ 15.0, { { 13.8, 45, 0 }, { 13.4, 225, 1.0 } } },
		}
		for o, ob in ORBITS do
			local bone = B:bone("FlyOrbit" .. o, "Root", v(0, ob[1], CZ))
			for f, fl in ob[2] do
				local p = at(fl[1], fl[2], ob[1] + fl[3]) + v(0, 0, CZ)
				B:block(bone, v(0.5, 0.5, 0.5), CFrame.new(p) * ang(0, 45, 45), FLY, { mat = "Neon", name = "Fly" .. o .. f })
				B:block(bone, v(0.32, 0.32, 0.55), CFrame.new(p + v(0, 0.3, 0)), FLY_BODY)
				B:trail(bone, p + v(0, 0.22, 0), p - v(0, 0.22, 0),
					{ name = "FlyTrail" .. o .. f, color = { "#f4ff9a", "#9dff6a" }, life = 0.7, width = { 1, 0 }, trans = { 0.25, 1 } })
			end
		end

		------------------------------------------------------------------
		-- VFX: 8 emitters, 3 lights, 6 trails
		------------------------------------------------------------------
		local pond = B:block(soil, v(10, 0.4, 5.5), cf(PX, PY + 0.6, PZ), WATER, { tr = 1, name = "PondZone" })
		B:emitter(pond, "smoke", { name = "PondFog", color = { "#d5f1ec", "#aed8dc" }, rate = 3.5, size = { 1.2, 3.0, 4.2 }, trans = { 0.68, 0.78, 1 }, life = { 3, 5 }, speed = { 0.2, 0.6 }, spread = 70, accel = { 0.25, 0.15, 0 } })
		B:emitter(pond, "bubble", { name = "PondBubbles", color = { "#bff7ee", "#8fe3d6" }, rate = 3, size = { 0.2, 0.35, 0.45 }, life = { 0.8, 1.6 }, speed = { 0.3, 0.9 }, accel = { 0, 1.5, 0 } })
		local under = B:block(canopy, v(22, 10, 22), cf(0, CTOP - 4.5, CZ), WISP_SHELL, { tr = 1, name = "WispZone" })
		B:emitter(under, "sparkle", { name = "WispSparkles", color = { "#ffffff", "#9ff8ff", "#d9b0ff" }, rate = 18, size = { 0.2, 0.7, 0 }, life = { 1.0, 2.0 }, speed = { 0.2, 0.7 }, light = 1 })
		B:emitter(under, "glow", { name = "WispGlow", color = { "#c8fbff", "#d9b0ff" }, rate = 2.5, size = { 1.6, 2.8, 0.6 }, trans = { 0.82, 0.74, 1 }, light = 1 })
		B:emitter(under, "burst", { name = "SpiritBurst", color = { "#ffffff", "#9ff8ff", "#c79bff" }, size = { 0.9, 0.6, 0 }, speed = { 8, 16 }, life = { 0.7, 1.4 }, drag = 2.5, light = 1 })
		B:emitter(under, "ember", { name = "WispMotes", color = { "#9ff8ff", "#e0c4ff", "#ffffff" }, rate = 1.5, size = { 0.4, 0.3, 0 }, life = { 2.5, 4 }, speed = { 0.6, 1.6 }, spread = 60, accel = { 0, 1.0, 0 }, light = 1 })
		local fly = B:block(soil, v(24, 9, 24), cf(0, 8, CZ), MOSS, { tr = 1, name = "FlyZone" })
		B:emitter(fly, "sparkle", { name = "Fireflies", color = { "#eaff6e", "#b8ff5c" }, rate = 7, size = { 0.25, 0.32, 0 }, trans = { 0.1, 0, 1 }, life = { 2.5, 4 }, speed = { 0.2, 0.6 }, accel = { 0, 0.3, 0 }, light = 1 })
		local leafZone = B:block(canopy, v(20, 1, 20), cf(0, CTOP - 0.8, CZ), W1[1], { tr = 1, name = "LeafZone" })
		B:emitter(leafZone, "leaf", { name = "WillowLeaves", color = { W3[1], CURT[2], W_TOP[1] }, rate = 3, size = { 0.5, 0.5, 0.3 }, life = { 3.5, 5.5 }, speed = { 0.3, 0.8 }, accel = { 0.6, -1.2, 0.2 }, dir = "Bottom" })
		local wl = B:block(canopy, v(0.4, 0.4, 0.4), cf(0, CTOP - 4.0, CZ), WISP_SHELL, { tr = 1, name = "WispLightCore" })
		B:light(wl, { name = "WispLight", color = "#9ff0ff", brightness = 1.2, range = 22 })
		local gl = B:block(gw, v(0.4, 0.4, 0.4), gF, WISP_SHELL, { tr = 1, name = "GrandLightCore" })
		B:light(gl, { name = "GrandLight", color = "#b9f6ff", brightness = 1.1, range = 14 })
		local pl = B:block(soil, v(0.4, 0.4, 0.4), cf(PX, PY + 1.2, PZ), WATER, { tr = 1, name = "PondLightCore" })
		B:light(pl, { name = "PondLight", color = "#7fe8d6", brightness = 0.8, range = 12 })
	end,
}
