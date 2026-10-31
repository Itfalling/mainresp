--!nocheck
-- Hollow Glow Stump (Misty Swamp decoration #2, medium accent).
-- A broken, hollow swamp stump: a ring of stepped bark staves with a ragged top
-- that scoops low at the front so you can see inside, a pale cut-wood rim,
-- draped moss caps and hanging moss, a flared base with splayed roots.
-- Inside, a dark hollow with a cluster of glowing teal/violet mushrooms; more
-- glowcaps and shelf fungi grow on the bark. A little fog curls out of the
-- hollow and creeps around the roots. Small footing of dark mud, moss mats,
-- flat stones and reed tufts. Static prop: no motion.luau.
return {
	DisplayName = "Hollow Glow Stump",
	Rarity = "Decor",
	Element = "Misty Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (matches the Misty Swamp crops)
		local MUD_DK, MUD, MUD_LT = "#2a231d", "#43372a", "#56473a"
		local MOSS_DK, MOSS, MOSS_LT = "#3d6a32", "#55893c", "#7fae4c"
		local STONE_DK, STONE, STONE_LT = "#4f5a57", "#6c7773", "#8a9590"
		local BARK_DK, BARK, BARK_LT = "#3b2b20", "#4e3a2a", "#66503a"
		local CUT, CUT_DK = "#b8915f", "#8f6c45"
		local HOLLOW = "#1c1612"
		local REED, REED_DK, CATTAIL = "#6f8a3c", "#56702f", "#4a2e1c"
		local STEM = "#cfe3d6"
		local TEAL_DK, TEAL, TEAL_LT = "#1f7a72", "#2fa39a", "#57cfc0"
		local VIO_DK, VIO, VIO_LT = "#3f2466", "#5b3590", "#7d52b8"
		local WISP, WISP_LT, PINK = "#5ff2ff", "#c8fff8", "#d9a8ff"
		local NEON = { mat = "Neon" }

		local seed = 2207
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function dirOf(a)
			return v(-math.sin(rad(a)), 0, -math.cos(rad(a)))
		end
		local function round(c, r, h, col)
			B:block(R, v(2 * r, h, 1.1 * r), c, col)
			B:block(R, v(1.1 * r, h - 0.04, 2 * r), c, col)
			B:block(R, v(1.72 * r, h - 0.08, 1.72 * r), c, col)
		end

		---------------------------------------------------------------- footing
		round(CFrame.new(0, 0.12, 0.2), 4.2, 0.24, MUD)
		round(CFrame.new(0.3, 0.3, 0.4) * ang(0, 20, 0), 3.4, 0.2, MUD_LT)
		for _, m in { { -2.6, -2.6, 2.2, 1.4, 25 }, { 3.0, -1.4, 1.8, 1.3, -20 }, { 2.4, 3.0, 2.0, 1.2, 40 }, { -3.2, 2.0, 1.6, 1.4, -35 } } do
			B:block(R, v(m[3], 0.2, m[4]), cf(m[1], 0.42, m[2], 0, m[5], 0), MOSS)
			B:block(R, v(m[3] * 0.5, 0.24, m[4] * 0.55), cf(m[1] + 0.2, 0.46, m[2] - 0.1, 0, m[5] + 15, 0), MOSS_LT)
		end
		local function stone(x, z, s, ry, moss)
			local c = cf(x, 0.3 + 0.3 * s, z, 0, ry, 0)
			B:block(R, v(1.4 * s, 0.6 * s, 1.1 * s), c, STONE)
			B:block(R, v(0.9 * s, 0.3 * s, 0.7 * s), c * CFrame.new(0.15 * s, 0.4 * s, 0) * ang(0, 20, 0), STONE_LT)
			B:block(R, v(1.44 * s, 0.2 * s, 1.14 * s), c * CFrame.new(0, -0.22 * s, 0), STONE_DK)
			if moss then
				B:block(R, v(0.8 * s, 0.14, 0.7 * s), c * CFrame.new(-0.2 * s, 0.33 * s, 0.1 * s), MOSS_LT)
			end
		end
		stone(-3.4, -1.0, 1.0, 30, true)
		stone(1.8, -3.6, 0.8, -15, false)
		stone(3.6, 1.6, 0.9, 50, true)
		local function reed(x, z, h, tz, tx, cat)
			local base = v(x, 0.3, z)
			local tip = base + v(-math.sin(rad(tz)) * h, h, math.sin(rad(tx)) * h)
			B:bar(R, base, tip, 0.22, 0.22, (h > 2.5) and REED or REED_DK)
			if cat then
				local d = (tip - base).Unit
				B:bar(R, tip - d * 0.2, tip + d * 0.9, 0.42, 0.42, CATTAIL)
				B:bar(R, tip + d * 0.85, tip + d * 1.25, 0.12, 0.12, REED_DK)
			end
		end
		reed(-3.0, 2.9, 3.4, 8, 6, true)
		reed(-3.5, 2.4, 2.4, 16, -4, false)
		reed(-2.5, 3.4, 2.0, -6, 14, false)
		reed(3.7, -0.4, 2.2, -14, 0, false)
		reed(3.3, -0.9, 2.9, -6, -8, true)
		-- grass tufts
		for _, t in { { -1.6, -3.4 }, { 3.4, 2.9 }, { -3.9, 0.6 }, { 0.6, 3.9 } } do
			for k = 0, 2 do
				local base = v(t[1] + (k - 1) * 0.25, 0.3, t[2])
				B:bar(R, base, base + v((k - 1) * 0.35, 0.9 + 0.2 * k, rnd(-0.2, 0.2)), 0.2, 0.2, (k == 1) and MOSS_LT or MOSS)
			end
		end

		---------------------------------------------------------------- stump
		local RAD = 2.5
		local N = 12
		-- heights of the staves, clockwise from the front (-Z): low scoop at the front
		local H = { 1.4, 2.0, 3.0, 3.9, 4.7, 5.4, 5.8, 5.2, 4.5, 3.7, 2.8, 1.9 }
		local Y0 = 0.35
		local tops = {}
		for i = 1, N do
			local a = (i - 1) * (360 / N)
			local h = H[i]
			local rot = CFrame.Angles(0, rad(a), 0)
			local col = (i % 2 == 0) and BARK or BARK_DK
			-- outer stave
			B:block(R, v(1.5, h, 1.1), rot * CFrame.new(0, Y0 + h / 2, -RAD), col)
			-- dark inner lining (gives the hollow its depth)
			B:block(R, v(1.4, h - 0.3, 0.3), rot * CFrame.new(0, Y0 + (h - 0.3) / 2, -RAD + 0.65), HOLLOW)
			-- pale cut-wood rim on the ragged top
			B:block(R, v(1.52, 0.3, 1.12), rot * CFrame.new(0, Y0 + h - 0.1, -RAD), (i % 3 == 0) and CUT_DK or CUT)
			-- bark ridge on the outside
			if i % 2 == 1 then
				B:block(R, v(0.4, h * 0.75, 0.25), rot * CFrame.new(rnd(-0.3, 0.3), Y0 + h * 0.42, -RAD - 0.6), BARK_LT)
			end
			-- flared base
			B:block(R, v(1.7, 1.1, 1.2), rot * CFrame.new(0, Y0 + 0.55, -RAD - 0.35) * ang(-8, 0, 0), (i % 2 == 0) and BARK_DK or BARK)
			tops[i] = { a = a, h = h, rot = rot }
		end
		-- broken splinters sticking up on the tall back staves
		for _, s in { { 6, 0.5, 1.1, -6 }, { 8, -0.3, 1.4, 8 }, { 5, 0.2, 0.7, 4 }, { 9, 0.4, 0.8, -10 } } do
			local t = tops[s[1]]
			B:block(R, v(0.5, s[3], 0.5), t.rot * CFrame.new(s[2], Y0 + t.h + s[3] / 2 - 0.1, -RAD) * ang(s[4], 0, s[4]), CUT)
		end
		-- moss caps draped over the rim + hanging moss strands
		for _, m in { { 4, 1.2, 1.6 }, { 6, 0.9, 2.0 }, { 7, 1.2, 1.2 }, { 9, 1.0, 1.8 }, { 12, 1.0, 0.8 } } do
			local t = tops[m[1]]
			B:block(R, v(1.6, 0.28, 1.35), t.rot * CFrame.new(0, Y0 + t.h + 0.12, -RAD - 0.08), MOSS)
			B:block(R, v(1.0, 0.3, 0.8), t.rot * CFrame.new(0.15, Y0 + t.h + 0.18, -RAD), MOSS_LT)
			B:block(R, v(0.7, m[3], 0.22), t.rot * CFrame.new(rnd(-0.3, 0.3), Y0 + t.h - m[3] / 2, -RAD - 0.62), MOSS_DK)
			B:block(R, v(0.4, m[3] * 0.6, 0.22), t.rot * CFrame.new(rnd(-0.4, 0.4), Y0 + t.h - m[3] * 0.3, -RAD - 0.64), MOSS)
		end
		-- knot hole on the back
		local tk = tops[7]
		B:block(R, v(1.2, 1.4, 0.2), tk.rot * CFrame.new(0, Y0 + 2.4, -RAD - 0.6), BARK_LT)
		B:block(R, v(0.8, 1.0, 0.2), tk.rot * CFrame.new(0, Y0 + 2.4, -RAD - 0.68), HOLLOW)
		-- dark hollow floor
		round(CFrame.new(0, 0.9, 0), 2.0, 0.5, HOLLOW)
		round(CFrame.new(0, 1.18, 0.1) * ang(0, 20, 0), 1.3, 0.1, MUD)

		-- roots splaying out (not at the front opening)
		for _, a in { 45, 105, 160, 205, 255, 310 } do
			local d = dirOf(a)
			local p0 = d * (RAD + 0.2) + v(0, 1.3, 0)
			local p1 = d * (RAD + 1.6) + v(0, 0.75, 0)
			local p2 = d * (RAD + 2.7) + v(0, 0.45, 0) + v(d.Z, 0, -d.X) * 0.4
			B:bar(R, p0, p1, 1.0, 0.9, BARK)
			B:bar(R, p1 - (p1 - p0).Unit * 0.2, p2, 0.7, 0.55, BARK_DK)
			B:block(R, v(0.8, 0.2, 0.6), CFrame.new(p1 + v(0, 0.48, 0)) * ang(0, -a, 0), MOSS)
		end

		---------------------------------------------------------------- glowing mushrooms
		local glowParts = {}
		local function shroom(base, k, capA, capB, glow, tilt)
			local c = CFrame.new(base) * ang(tilt or 0, rnd(0, 45), 0)
			B:block(R, v(0.35 * k, 1.0 * k, 0.35 * k), c * CFrame.new(0, 0.5 * k, 0), STEM)
			B:block(R, v(0.6 * k, 0.18 * k, 0.6 * k), c * CFrame.new(0, 0.6 * k, 0), STEM)
			B:block(R, v(1.3 * k, 0.35 * k, 1.3 * k), c * CFrame.new(0, 1.1 * k, 0) * ang(0, 45, 0), capA)
			B:block(R, v(0.95 * k, 0.3 * k, 0.95 * k), c * CFrame.new(0, 1.38 * k, 0), capB)
			-- glowing gills + spot
			B:block(R, v(0.95 * k, 0.1, 0.95 * k), c * CFrame.new(0, 0.9 * k, 0) * ang(0, 45, 0), glow, NEON)
			local spot = B:block(R, v(0.32 * k, 0.12 * k, 0.32 * k), c * CFrame.new(0.15 * k, 1.55 * k, -0.1 * k), glow, NEON)
			table.insert(glowParts, spot)
			return spot
		end
		-- inside the hollow
		local inner = shroom(v(0.1, 1.2, -0.3), 1.5, TEAL, TEAL_LT, WISP)
		shroom(v(-0.9, 1.2, 0.5), 1.15, VIO, VIO_LT, PINK, 6)
		shroom(v(0.9, 1.2, 0.6), 0.95, TEAL_DK, TEAL, WISP_LT, -6)
		shroom(v(-0.6, 1.2, -1.0), 0.65, VIO, VIO_LT, PINK)
		-- on the rim
		local t5 = tops[5]
		shroom((t5.rot * CFrame.new(0.2, Y0 + t5.h + 0.05, -RAD)).Position, 1.0, VIO, VIO_LT, PINK)
		local t11 = tops[11]
		shroom((t11.rot * CFrame.new(-0.2, Y0 + t11.h + 0.05, -RAD)).Position, 0.85, TEAL, TEAL_LT, WISP)
		-- at the roots
		shroom(v(-2.6, 0.35, -2.3), 0.8, TEAL, TEAL_LT, WISP, 8)
		shroom(v(-2.0, 0.35, -3.0), 0.55, VIO, VIO_LT, PINK)
		shroom(v(3.4, 0.35, 0.3), 0.7, VIO, VIO_LT, PINK, -8)
		shroom(v(1.4, 0.35, 3.8), 0.65, TEAL, TEAL_LT, WISP)

		-- shelf fungi on the bark
		local function shelf(i, y, k, col, colLt, glow)
			local t = tops[i]
			local c = t.rot * CFrame.new(rnd(-0.2, 0.2), Y0 + y, -RAD - 0.6)
			B:block(R, v(1.5 * k, 0.32 * k, 1.0 * k), c * CFrame.new(0, 0, -0.35 * k), col)
			B:block(R, v(1.0 * k, 0.28 * k, 0.6 * k), c * CFrame.new(0, 0.22 * k, -0.25 * k), colLt)
			B:block(R, v(1.1 * k, 0.08, 0.5 * k), c * CFrame.new(0, -0.18 * k, -0.45 * k), glow, NEON)
		end
		shelf(3, 2.0, 1.0, TEAL, TEAL_LT, WISP)
		shelf(3, 1.3, 0.75, TEAL, TEAL_LT, WISP)
		shelf(5, 3.2, 0.9, VIO, VIO_LT, PINK)
		shelf(8, 3.9, 1.0, TEAL_DK, TEAL, WISP)
		shelf(10, 2.3, 0.9, VIO, VIO_LT, PINK)
		shelf(11, 1.4, 0.7, TEAL, TEAL_LT, WISP)

		---------------------------------------------------------------- VFX
		local fogSrc = B:block(R, v(2.6, 0.6, 2.6), cf(0, 2.0, 0), WISP, { tr = 1, name = "FogSource" })
		B:emitter(fogSrc, "smoke", { name = "HollowFog", color = { "#d8f2ff", "#b9a8ff" }, rate = 1.6, size = { 1.2, 2.6, 3.6 }, trans = { 0.78, 0.84, 1 }, speed = { 0.3, 0.6 }, life = { 3, 5 }, spread = 25, accel = { 0, 0.25, 0 } })
		local mist = B:block(R, v(8, 0.4, 8), cf(0, 0.6, 0), WISP, { tr = 1, name = "MistZone" })
		B:emitter(mist, "smoke", { name = "GroundMist", color = { "#cfe9ff", "#b9a8ff" }, rate = 1.0, size = { 1.4, 2.8, 3.6 }, trans = { 0.84, 0.88, 1 }, speed = { 0.1, 0.3 }, life = { 3, 5 }, spread = 90, accel = { 0, 0.05, 0 } })
		B:emitter(inner, "sparkle", { name = "SporeMotes", color = { "#ffffff", WISP }, rate = 3, size = { 0.12, 0.3, 0 }, speed = { 0.3, 0.7 }, life = { 1.6, 2.8 }, accel = { 0, 0.7, 0 }, light = 1 })
		B:light(inner, { name = "HollowGlow", color = "#7ff4ff", brightness = 1.0, range = 10 })
	end,
}
