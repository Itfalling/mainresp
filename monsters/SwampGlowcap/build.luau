--!nocheck
-- Glowcap Ring (Misty Swamp crop #6, Mythic).
-- A fairy ring of giant glowing toadstools around one tall central glowcap:
-- * stepped dark swamp-MUD mound (bone "Soil") with moss pads, a murky teal
--   puddle with lily pads at the back, reeds + cattails, grey-teal stones and
--   a ring of tiny glowing button mushrooms on the outer tier
-- * a tall pale-lavender central stalk (bulb foot, frilly skirt ring, glowing
--   freckles) carrying a huge stepped VIOLET cap with glowing cyan spots and
--   neon-cyan gills underneath
-- * six giant toadstools leaning outward around it at different heights,
--   alternating violet caps (cyan glow spots) and teal caps (pink-violet glow
--   spots), each with glowing gills
-- VFX: rising glow spores, cyan twinkles round the big cap, a soft aura puff
-- under it, a cyan + a violet PointLight. Static prop: no motion.luau.
return {
	DisplayName = "Glowcap Ring",
	Rarity = "Mythic",
	Element = "Nature",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Misty Swamp) -------------------------------------------
		local MUD_XD, MUD_DK, MUD, MUD_LT = "#3b2a1e", "#4c3626", "#5e4430", "#74563c"
		local MOSS_DK, MOSS, MOSS_LT = "#3e6b2e", "#558a3a", "#76ab4a"
		local WATER_DK, WATER, WATER_LT = "#276b63", "#35958a", "#86dccb"
		local PAD_DK, PAD, PAD_LT = "#3b7a3a", "#4f9a46", "#77bf5c"
		local STONE_DK, STONE, STONE_LT = "#56605e", "#6f7a77", "#8c9893"
		local REED, REED_DK, CATTAIL = "#7a8a3e", "#5d6e30", "#4a2f1e"
		local STALK_DK, STALK, STALK_LT, STALK_BASE = "#c9bde0", "#e6def3", "#f6f2fc", "#a596c2"
		local GILL, GILL_DK = "#ddd0ef", "#b7a3d6"
		local GLOW_CY, GLOW_PK = "#7ff7ff", "#f2b6ff"
		local VIO = { "#4a2789", "#6a3cbd", "#8a5bdb", "#a982ee", GLOW_CY, "#d2f8ff" }
		local TEAL = { "#135c5b", "#1d8781", "#2aaca2", "#56cfc2", GLOW_PK, "#f3dcff" }
		local NEON = { mat = "Neon" }

		local seed = 66161
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
		local function pv(r, deg, y)
			local a = rad(deg)
			return v(math.sin(a) * r, y, -math.cos(a) * r)
		end

		------------------------------------------------------------------
		-- STEPPED SWAMP MUD MOUND (bone "Soil", parts named "Soil")
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
		disc(0, 0.8, 6.4, MUD_XD)
		edge(0, 0.8, 6.45, 16, { MUD_XD, MUD_DK, MUD_XD }, 0.45, { 1.7, 2.5 }, { 1.3, 1.8 })
		disc(0.8, 0.7, 4.9, MUD_DK)
		edge(0.8, 0.7, 4.95, 12, { MUD_DK, MUD, MUD_DK }, 0.12, { 1.5, 2.2 }, { 1.2, 1.6 })
		disc(1.5, 0.5, 2.9, MUD)
		local TOP = 2.0

		-- moss pads draped over the tier edges
		for _, m in { { 15, 6.1, 0.8, 2.4, MOSS }, { 125, 6.0, 0.8, 2.0, MOSS_DK }, { 240, 6.2, 0.8, 2.6, MOSS }, { 305, 5.9, 0.8, 1.8, MOSS_LT }, { 65, 4.6, 1.5, 1.8, MOSS_LT }, { 250, 4.6, 1.5, 1.9, MOSS }, { 0, 2.6, 2.0, 1.5, MOSS_DK } } do
			local c = CFrame.new(pv(m[2], m[1], m[3] + 0.08)) * ang(0, -m[1] + jit(15), 0)
			B:block(soil, v(m[4], 0.25, m[4] * 0.75), c * ang(-5, 0, 0), m[5], S)
			B:block(soil, v(m[4] * 0.55, 0.22, 0.5), c * CFrame.new(0.1, -0.15, -m[4] * 0.38) * ang(-30, 0, 0), m[5], S)
		end

		-- murky puddle at the back (between two ring toadstools)
		do
			local PA = 188
			local c = CFrame.new(pv(4.1, PA, 1.58)) * ang(0, -PA, 0)
			B:block(soil, v(3.4, 0.14, 2.4), c, WATER, S)
			B:block(soil, v(2.4, 0.13, 3.0), c, WATER, S)
			B:block(soil, v(1.3, 0.16, 1.0), c * CFrame.new(0.4, 0.01, 0.2), WATER_DK, S)
			B:block(soil, v(1.5, 0.16, 0.22), c * CFrame.new(-0.2, 0.02, -0.7), WATER_LT, S)
			for k = 0, 2 do
				local q = c * CFrame.Angles(0, rad(k * 120 + 40), 0) * CFrame.new(0, 0.05, -1.6)
				B:block(soil, v(1.4, 0.35, 0.55), q * ang(0, jit(12), 0), (k % 2 == 0) and MUD or MUD_LT, S)
			end
			local function lily(q, s, col)
				B:block(soil, v(1.5 * s, 0.12, 1.05 * s), q, col, S)
				B:block(soil, v(1.05 * s, 0.11, 1.5 * s), q, col, S)
				B:block(soil, v(0.4 * s, 0.14, 0.6 * s), q * CFrame.new(0, 0.01, -0.55 * s), WATER, S)
			end
			lily(c * CFrame.new(-0.6, 0.1, 0.2) * ang(0, 30, 0), 0.9, PAD)
			lily(c * CFrame.new(0.7, 0.1, -0.5) * ang(0, -50, 0), 0.65, PAD_LT)
		end

		-- reeds + cattails
		for _, r in { { 3.9, 4.3, 4.0, -6 }, { 4.6, 3.5, 3.0, 9 }, { -4.5, 4.0, 3.4, 8 }, { -5.3, -2.9, 3.6, 6 }, { -4.6, -3.7, 2.6, -9 } } do
			local base = 0.8
			local tip = v(r[1] - math.sin(rad(r[4])) * r[3], base + r[3], r[2])
			B:bar(soil, v(r[1], base - 0.1, r[2]), tip, 0.24, 0.24, REED, S)
			B:block(soil, v(0.42, 0.85, 0.42), CFrame.new(tip + v(0, 0.2, 0)) * ang(0, 0, r[4]), CATTAIL, S)
			B:block(soil, v(0.12, 0.45, 0.12), CFrame.new(tip + v(0, 0.8, 0)) * ang(0, 0, r[4]), REED_DK, S)
		end
		for _, g in { { 4.3, 4.8, 15 }, { -5.6, -2.3, -20 }, { -4.9, 4.4, 5 } } do
			B:block(soil, v(0.3, 1.6, 0.18), cf(g[1], 1.4, g[2], 0, g[3], 12), REED, S)
			B:block(soil, v(0.28, 1.2, 0.16), cf(g[1] + 0.3, 1.2, g[2] + 0.1, 0, g[3] + 30, -14), REED_DK, S)
		end
		-- grey-teal stones
		for _, s in { { 5.6, 0.95, -0.6, 1.0, 25, STONE }, { 5.9, 0.9, 0.7, 0.6, 10, STONE_LT }, { -5.8, 0.95, 0.8, 0.9, -20, STONE_DK }, { 1.4, 0.95, 5.8, 0.7, 40, STONE }, { -1.6, 0.9, -5.8, 0.6, 15, STONE_LT } } do
			B:block(soil, v(s[4] * 1.35, s[4], s[4] * 1.05), cf(s[1], s[2], s[3], jit(6), s[5], jit(6)), s[6], S)
		end

		-- tiny glowing button mushrooms on the outer tier (the fairy ring)
		for i = 0, 9 do
			local a = i * 36 + 18 + jit(5)
			local p = pv(5.55 + jit(0.15), a, 0.8)
			local k = 0.8 + rnd() * 0.45
			local pal = (i % 2 == 0) and VIO or TEAL
			local f = CFrame.new(p) * ang(jit(8), rnd() * 90, jit(8))
			B:block(soil, v(0.36 * k, 0.8 * k, 0.36 * k), f * CFrame.new(0, 0.4 * k, 0), STALK, S)
			B:block(soil, v(1.0 * k, 0.32 * k, 1.0 * k), f * CFrame.new(0, 0.86 * k, 0), pal[2], S)
			B:block(soil, v(0.6 * k, 0.24 * k, 0.6 * k), f * CFrame.new(0, 1.1 * k, 0) * ang(0, 45, 0), pal[3], S)
			B:block(soil, v(0.24 * k, 0.12 * k, 0.24 * k), f * CFrame.new(0, 1.26 * k, 0), pal[5], { name = "Soil", mat = "Neon" })
		end

		------------------------------------------------------------------
		-- TOADSTOOL KIT (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		local function round(c, r, h, col, opts)
			B:block(crop, v(2 * r, h, 1.1 * r), c, col, opts)
			B:block(crop, v(1.1 * r, h - 0.04, 2 * r), c, col, opts)
			B:block(crop, v(1.72 * r, h - 0.08, 1.72 * r), c, col, opts)
		end
		local gills = {}
		-- c: cap frame at the gill line (local +Y up). pal = {dk, md, lt, hi, glowSpot, paleSpot}
		local function cap(c, R, pal, masks, big)
			-- gills: pale disc + glowing radial lines on the underside
			round(c * CFrame.new(0, 0.28, 0), R * 0.82, 0.42, GILL)
			local nG = big and 8 or 4
			for i = 0, nG - 1 do
				local a = i * 360 / nG + 22.5
				local r0, r1 = 0.7, R * 0.88
				local q = c * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.04, -(r0 + r1) / 2)
				table.insert(gills, B:block(crop, v(0.24, 0.12, r1 - r0), q, GLOW_CY, { mat = "Neon", name = "Gill" }))
			end
			-- stepped dome
			local layers = big and {
				{ 1.0, 0.7, 1, 0 },
				{ 0.9, 0.22 * R, 2, 45 },
				{ 0.74, 0.2 * R, 2, 0 },
				{ 0.53, 0.17 * R, 3, 45 },
				{ 0.3, 0.12 * R, 4, 0 },
			} or {
				{ 1.0, 0.55, 1, 0 },
				{ 0.82, 0.28 * R, 2, 45 },
				{ 0.56, 0.22 * R, 3, 0 },
				{ 0.3, 0.14 * R, 4, 45 },
			}
			local y0 = 0.45
			local s = math.clamp(0.34 * R, 0.75, 1.7)
			for j, l in layers do
				local rr, h = R * l[1], l[2]
				local lc = c * CFrame.new(0, y0 + h / 2, 0) * ang(0, l[4], 0)
				round(lc, rr, h, pal[l[3]])
				local m = masks[j - 1]
				if m and j < #layers then
					for k = 0, 3 do
						if string.sub(m, k + 1, k + 1) == "1" then
							local q = lc * CFrame.Angles(0, rad(k * 90), 0) * CFrame.new(jit(0.25) * rr, 0, -rr - 0.08)
							local sz = s * (0.85 + rnd() * 0.3)
							local glow = (k + j) % 2 == 0
							B:block(crop, v(sz, math.min(h - 0.1, sz * 0.85), 0.32), q, glow and pal[5] or pal[6], glow and { mat = "Neon", name = "Spot" } or nil)
						end
					end
				end
				y0 += h
			end
			-- crown spot + ledge spots (read from above)
			B:block(crop, v(R * 0.26, 0.24, R * 0.26), c * CFrame.new(0, y0 + 0.02, 0) * ang(0, 20, 0), pal[6])
			local yL = 0.45 + layers[1][2] + layers[2][2] + (big and layers[3][2] or 0)
			local rL = big and R * 0.64 or R * 0.7
			for k = 0, (big and 3 or 1) do
				local q = c * CFrame.Angles(0, rad(40 + k * (big and 90 or 180) + jit(15)), 0) * CFrame.new(0, yL + 0.05, -rL)
				B:block(crop, v(s * 0.75, 0.24, s * 0.75), q * ang(0, rnd() * 45, 0), (k % 2 == 0) and pal[6] or pal[5], (k % 2 == 1) and NEON or nil)
			end
			return y0
		end

		------------------------------------------------------------------
		-- CENTRAL GLOWCAP
		------------------------------------------------------------------
		local path = {
			{ p = v(0, TOP - 0.3, 0), w = 2.9 },
			{ p = v(0.35, 6.0, 0.25), w = 2.5 },
			{ p = v(-0.25, 10.5, -0.1), w = 2.25 },
			{ p = v(0.2, 14.5, 0.1), w = 2.1 },
			{ p = v(0, 17.4, 0), w = 2.0 },
		}
		for i = 1, #path - 1 do
			local a, b = path[i], path[i + 1]
			local w = (a.w + b.w) / 2
			local col = (i % 2 == 1) and STALK or STALK_LT
			B:bar(crop, a.p - v(0, 0.2, 0), b.p + v(0, 0.2, 0), w, w, col)
			B:bar(crop, a.p - v(0, 0.15, 0), b.p + v(0, 0.15, 0), w * 0.86, w * 0.86, col, { up = v(1, 0, 1).Unit })
		end
		-- bulb foot (stepped)
		B:block(crop, v(4.0, 1.0, 4.0), cf(0, TOP + 0.3, 0, 0, 10, 0), STALK_BASE)
		B:block(crop, v(3.5, 0.9, 3.5), cf(0, TOP + 1.1, 0, 0, 55, 0), STALK_DK)
		B:block(crop, v(3.1, 0.7, 3.1), cf(0.1, TOP + 1.8, 0.1, 0, 25, 0), STALK)
		-- frilly skirt ring
		do
			local yS = 13.6
			local c = CFrame.new(v(0.15, yS, 0.05))
			B:block(crop, v(3.2, 0.35, 3.2), c, STALK_LT)
			B:block(crop, v(3.15, 0.33, 3.15), c * ang(0, 45, 0), STALK_LT)
			for i = 0, 7 do
				local q = c * CFrame.Angles(0, rad(i * 45 + 22.5), 0) * CFrame.new(0, -0.45, -1.55)
				B:block(crop, v(1.0, 0.8, 0.3), q * ang(-16, 0, 0), (i % 2 == 0) and STALK or STALK_DK)
			end
		end
		-- glowing freckles + dark stalk flecks
		for _, f in { { 4.5, 30, 1.3 }, { 7.2, 160, 1.2 }, { 9.0, 290, 1.15 }, { 11.6, 80, 1.1 }, { 15.8, 210, 1.05 }, { 6.0, 250, 1.25 } } do
			local q = CFrame.new(v(0, f[1], 0)) * CFrame.Angles(0, rad(-f[2]), 0) * CFrame.new(0, 0, -f[3])
			B:block(crop, v(0.4, 0.4, 0.2), q, GLOW_CY, NEON)
		end
		for _, f in { { 5.3, 100, 1.28 }, { 8.4, 20, 1.18 }, { 12.3, 200, 1.1 }, { 16.4, 330, 1.05 } } do
			local q = CFrame.new(v(0, f[1], 0)) * CFrame.Angles(0, rad(-f[2]), 0) * CFrame.new(0, 0, -f[3])
			B:block(crop, v(0.6, 0.9, 0.2), q, STALK_DK)
		end
		local CAPY = 17.2
		local bigCap = CFrame.new(v(0, CAPY, 0)) * ang(2, 12, -3)
		local bigTop = cap(bigCap, 5.4, VIO, { "1111", "1011", "0110" }, true)

		------------------------------------------------------------------
		-- RING OF GIANT TOADSTOOLS
		------------------------------------------------------------------
		local RING = {
			-- angle, cap height, cap radius, palette, outward tilt, stem width
			{ 335, 6.0, 2.1, TEAL, 16, 1.0 },
			{ 30, 8.6, 2.5, VIO, 14, 1.15 },
			{ 95, 11.3, 2.9, TEAL, 12, 1.3 },
			{ 155, 9.2, 2.7, VIO, 14, 1.2 },
			{ 220, 12.0, 3.0, TEAL, 11, 1.35 },
			{ 278, 7.6, 2.4, VIO, 15, 1.1 },
		}
		local ringCaps = {}
		for i, r in RING do
			local a, H, R, pal, tilt, w = r[1], r[2], r[3], r[4], r[5], r[6]
			local base = pv(4.15, a, 1.45)
			local out = pv(1, a, 0)
			local top = base + v(0, H - 1.5, 0) + out * (math.sin(rad(tilt)) * (H - 1.5) * 0.9)
			local mid = base:Lerp(top, 0.5) + out * -0.25
			B:bar(crop, base, mid, w, w, STALK)
			B:bar(crop, mid, top, w * 0.92, w * 0.92, STALK_LT)
			B:block(crop, v(w + 0.15, w + 0.15, w + 0.15), CFrame.new(mid) * ang(0, -a, 0), STALK)
			-- stepped bulb foot
			B:block(crop, v(w + 1.0, 0.7, w + 1.0), CFrame.new(base + v(0, 0.3, 0)) * ang(0, -a + 20, 0), STALK_BASE)
			B:block(crop, v(w + 0.55, 0.6, w + 0.55), CFrame.new(base + v(0, 0.85, 0)) * ang(0, -a + 65, 0), STALK_DK)
			-- a glowing freckle facing out
			B:block(crop, v(0.3, 0.3, 0.16), CFrame.new(mid + v(0, 0.6, 0)) * ang(0, -a, 0) * CFrame.new(0, 0, -w * 0.5), pal[5], NEON)
			local c = CFrame.new(top) * ang(0, -a + jit(20), 0) * ang(-tilt, 0, jit(5))
			local masks = (i % 2 == 0) and { "1010", "0101" } or { "0101", "1010" }
			local y = cap(c, R, pal, masks, false)
			table.insert(ringCaps, c * CFrame.new(0, y, 0))
		end

		-- little baby glowcaps sprouting from the central bulb
		for _, m in { { 140, 1.7, 0.9, VIO }, { 160, 1.9, 0.6, TEAL }, { 330, 1.75, 0.75, TEAL }, { 60, 1.8, 0.55, VIO } } do
			local p = pv(m[2], m[1], TOP + 0.6)
			local k = m[3]
			local f = CFrame.new(p) * ang(0, -m[1], 0) * ang(-18, 0, 0)
			B:block(crop, v(0.45 * k, 1.2 * k, 0.45 * k), f * CFrame.new(0, 0.6 * k, 0), STALK_LT)
			B:block(crop, v(1.3 * k, 0.45 * k, 1.3 * k), f * CFrame.new(0, 1.3 * k, 0), m[4][2])
			B:block(crop, v(0.8 * k, 0.35 * k, 0.8 * k), f * CFrame.new(0, 1.65 * k, 0) * ang(0, 45, 0), m[4][3])
			B:block(crop, v(0.3 * k, 0.14 * k, 0.3 * k), f * CFrame.new(0, 1.87 * k, 0), m[4][5], NEON)
		end

		------------------------------------------------------------------
		-- VFX: rising glow spores, cyan twinkles, cap aura, two soft lights
		------------------------------------------------------------------
		local sporeZone = B:block(crop, v(13, 9, 13), cf(0, 7.5, 0), VIO[2], { tr = 1, name = "SporeZone" })
		B:emitter(sporeZone, "glow", { name = "GlowSpores", color = { GLOW_CY, "#c9a2ff", "#a8ffe8" }, rate = 7, size = { 0.22, 0.4, 0 }, trans = { 0.1, 0.2, 1 }, life = { 3, 5 }, speed = { 0.2, 0.5 }, accel = { 0, 0.55, 0 }, light = 1 })
		local capZone = B:block(crop, v(11, 2, 11), cf(0, CAPY + 2.6, 0), VIO[2], { tr = 1, name = "CapZone" })
		B:emitter(capZone, "sparkle", { name = "CapTwinkles", color = { "#ffffff", GLOW_CY, "#c9a2ff" }, rate = 8, size = { 0.15, 0.55, 0 }, life = { 0.8, 1.6 }, speed = { 0.2, 0.6 }, accel = { 0, 0.4, 0 }, light = 1 })
		local under = B:block(crop, v(6, 0.6, 6), cf(0, CAPY - 0.8, 0), VIO[2], { tr = 1, name = "UnderCap" })
		B:emitter(under, "glow", { name = "CapAura", color = { GLOW_CY, "#9fe8ff" }, rate = 1.4, size = { 2.2, 3.4, 0.5 }, trans = { 0.8, 0.7, 1 }, life = { 1.5, 2.5 }, light = 1 })
		local low = B:block(crop, v(10, 0.5, 10), cf(0, 2.2, 0), TEAL[2], { tr = 1, name = "RingFloor" })
		B:emitter(low, "sparkle", { name = "RingSpores", color = { GLOW_PK, "#e2c4ff", GLOW_CY }, rate = 4, size = { 0.12, 0.38, 0 }, life = { 2, 3.5 }, speed = { 0.4, 0.9 }, spread = 25, accel = { 0, 0.6, 0 }, light = 1 })
		B:light(under, { name = "CapLight", color = "#7ff0ff", brightness = 1.3, range = 16 })
		B:light(low, { name = "RingLight", color = "#b48aff", brightness = 1.0, range = 13 })
	end,
}
