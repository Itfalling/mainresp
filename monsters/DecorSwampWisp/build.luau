--!nocheck
-- Wisp Lantern Post (Misty Swamp decoration #3, the hero piece).
-- A tall, crooked bog-wood lantern post on a stepped base of mossy stones.
-- The post zig-zags upward (iron and rope bands at its knees, twig stubs,
-- a wrapping vine and hanging moss) and curls over at the top into a crook
-- like the Wisp Lantern crop's stalks; from it hangs a violet-framed glass
-- lantern with a small cyan flame. A wooden arrow sign points the way and a
-- little bud lantern hangs from a peg. A glowing will-o'-wisp (neon core in a
-- glassy shell with a wispy tail) circles the lantern, bobbing gently, with
-- two tiny motes; the lantern sways a little. Footing: mud and moss mats, a
-- murky puddle with a lily pad, reeds and glowcap mushrooms. Animated
-- (motion.luau, 8 s loop).
return {
	DisplayName = "Wisp Lantern Post",
	Rarity = "Decor",
	Element = "Misty Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Misty Swamp)
		local MUD_DK, MUD, MUD_LT = "#2a231d", "#43372a", "#56473a"
		local MOSS_DK, MOSS, MOSS_LT = "#3d6a32", "#55893c", "#7fae4c"
		local STONE_DK, STONE, STONE_LT = "#4f5a57", "#6c7773", "#8a9590"
		local WATER_DK, WATER, WATER_LT = "#1d4a4a", "#2a6a66", "#5fa59c"
		local PAD, PAD_LT = "#3f8f4a", "#6fbf5c"
		local REED, REED_DK, CATTAIL = "#6f8a3c", "#56702f", "#4a2e1c"
		local WOOD_DK, WOOD, WOOD_LT = "#4a3828", "#5e4632", "#7a5d42"
		local SIGN, SIGN_DK = "#9c8669", "#7a6650"
		local ROPE = "#c9b48a"
		local IRON, IRON_LT = "#3a3f45", "#5a626b"
		local VINE, VINE_LT = "#2f6e3c", "#5aa856"
		local STEM = "#cfe3d6"
		local TEAL, TEAL_LT = "#2fa39a", "#57cfc0"
		local VIO_DK, VIO, VIO_LT, VIO_HI = "#3f2466", "#5b3590", "#7d52b8", "#a982e0"
		local GLASS = "#7fefff"
		local WISP, WISP_LT = "#5ff2ff", "#c8fff8"
		local NEON = { mat = "Neon" }

		local seed = 7741
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function round(c, r, h, col)
			B:block(R, v(2 * r, h, 1.1 * r), c, col)
			B:block(R, v(1.1 * r, h - 0.04, 2 * r), c, col)
			B:block(R, v(1.72 * r, h - 0.08, 1.72 * r), c, col)
		end

		local OX = -1.9 -- post sits left of centre so the lantern + wisp orbit balance the footprint

		---------------------------------------------------------------- footing
		round(CFrame.new(0.2, 0.12, 0), 4.4, 0.24, MUD)
		round(CFrame.new(0, 0.3, 0.2) * ang(0, 25, 0), 3.6, 0.2, MUD_LT)
		for _, m in { { -3.0, 2.4, 2.0, 1.4, 25 }, { 3.6, 1.8, 1.8, 1.3, -20 }, { 0.6, 3.6, 2.2, 1.2, 40 }, { -3.4, -2.2, 1.6, 1.4, -35 } } do
			B:block(R, v(m[3], 0.2, m[4]), cf(m[1], 0.42, m[2], 0, m[5], 0), MOSS)
			B:block(R, v(m[3] * 0.5, 0.24, m[4] * 0.55), cf(m[1] + 0.2, 0.46, m[2] - 0.1, 0, m[5] + 15, 0), MOSS_LT)
		end
		-- murky puddle under the lantern
		local PC = v(2.4, 0, -1.2)
		B:block(R, v(3.4, 0.14, 2.4), cf(PC.X, 0.44, PC.Z, 0, -20, 0), WATER)
		B:block(R, v(2.4, 0.13, 3.0), cf(PC.X, 0.44, PC.Z, 0, -20, 0), WATER)
		B:block(R, v(1.8, 0.15, 1.3), cf(PC.X + 0.2, 0.45, PC.Z + 0.2, 0, 5, 0), WATER_DK)
		B:block(R, v(1.4, 0.16, 0.22), cf(PC.X - 0.3, 0.46, PC.Z - 0.7, 0, -25, 0), WATER_LT)
		local lc = cf(PC.X + 0.7, 0.54, PC.Z - 0.2, 0, 30, 0)
		B:block(R, v(1.2, 0.08, 0.8), lc, PAD)
		B:block(R, v(0.8, 0.07, 1.2), lc, PAD)
		B:block(R, v(0.3, 0.1, 0.3), lc * CFrame.new(0.1, 0.02, 0.1), PAD_LT)

		-- reeds + cattails
		local function reed(x, z, h, tz, tx, cat)
			local base = v(x, 0.35, z)
			local tip = base + v(-math.sin(rad(tz)) * h, h, math.sin(rad(tx)) * h)
			B:bar(R, base, tip, 0.22, 0.22, pick({ REED, REED_DK }))
			if cat then
				local d = (tip - base).Unit
				B:bar(R, tip - d * 0.2, tip + d * 0.9, 0.42, 0.42, CATTAIL)
				B:bar(R, tip + d * 0.85, tip + d * 1.3, 0.12, 0.12, REED_DK)
			end
		end
		reed(3.8, 0.8, 3.4, -8, 6, true)
		reed(4.2, 0.2, 2.4, -16, -2, false)
		reed(3.4, 1.4, 2.8, 2, 12, true)
		reed(-3.6, -1.0, 2.6, 12, -8, true)
		reed(-3.9, -0.4, 1.9, 18, 2, false)
		reed(-1.0, 3.8, 2.2, 4, 14, false)

		-- glowcap mushrooms
		local function shroom(base, k, capA, capB, glow)
			local c = CFrame.new(base) * ang(0, rnd(0, 45), 0)
			B:block(R, v(0.35 * k, 1.0 * k, 0.35 * k), c * CFrame.new(0, 0.5 * k, 0), STEM)
			B:block(R, v(1.3 * k, 0.35 * k, 1.3 * k), c * CFrame.new(0, 1.1 * k, 0) * ang(0, 45, 0), capA)
			B:block(R, v(0.95 * k, 0.3 * k, 0.95 * k), c * CFrame.new(0, 1.38 * k, 0), capB)
			B:block(R, v(0.95 * k, 0.1, 0.95 * k), c * CFrame.new(0, 0.9 * k, 0) * ang(0, 45, 0), glow, NEON)
			B:block(R, v(0.3 * k, 0.12 * k, 0.3 * k), c * CFrame.new(0.15 * k, 1.55 * k, -0.1 * k), glow, NEON)
		end
		shroom(v(-2.6, 0.35, -2.6), 0.9, TEAL, TEAL_LT, WISP)
		shroom(v(-1.9, 0.35, -3.2), 0.6, VIO, VIO_LT, "#d9a8ff")
		shroom(v(1.2, 0.35, 2.9), 0.75, VIO, VIO_LT, "#d9a8ff")
		shroom(v(3.9, 0.35, -2.6), 0.6, TEAL, TEAL_LT, WISP)

		---------------------------------------------------------------- stone base
		local function stone(c, s, col, top)
			B:block(R, v(1.6 * s, 0.9 * s, 1.3 * s), c, col)
			B:block(R, v(1.64 * s, 0.25 * s, 1.34 * s), c * CFrame.new(0, -0.3 * s, 0), STONE_DK)
			if top then
				B:block(R, v(1.0 * s, 0.18, 0.9 * s), c * CFrame.new(-0.1 * s, 0.48 * s, 0.05 * s), top)
			end
		end
		local BX = OX
		for i = 0, 5 do
			local a = i * 60 + 15
			local c = CFrame.new(BX, 0, 0) * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.75, -1.25) * ang(0, rnd(-8, 8), 0)
			stone(c, 1.0, pick({ STONE, STONE_LT, STONE }), (i % 2 == 0) and MOSS or nil)
		end
		for i = 0, 3 do
			local a = i * 90 + 40
			local c = CFrame.new(BX, 0, 0) * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 1.55, -0.7) * ang(0, rnd(-8, 8), 0)
			stone(c, 0.8, pick({ STONE_LT, STONE }), (i % 2 == 1) and MOSS_LT or nil)
		end
		B:block(R, v(2.2, 1.6, 2.2), cf(BX, 1.0, 0, 0, 20, 0), STONE_DK)
		-- strap-leaf clump hugging the base (same leaf language as the crops)
		local LF_DK, LF, LF_LT = "#2f6e3c", "#3f8a48", "#5aa856"
		local function blade(a, s, w, colA, colB)
			local dir = v(-math.sin(rad(a)), 0, -math.cos(rad(a)))
			local p0 = v(BX, 1.6, 0) + dir * 1.3
			local p1 = p0 + dir * 0.6 * s + v(0, 1.6 * s, 0)
			local p2 = p1 + dir * 0.9 * s + v(0, 0.9 * s, 0)
			local p3 = p2 + dir * 0.9 * s + v(0, -0.1 * s, 0)
			B:bar(R, p0, p1, w, 0.35, colA, { up = dir })
			B:bar(R, p1 - (p1 - p0).Unit * 0.2, p2, w * 0.8, 0.33, colB, { up = dir })
			B:bar(R, p2 - (p2 - p1).Unit * 0.2, p3, w * 0.5, 0.3, colA, { up = dir })
		end
		for i = 0, 6 do
			blade(i * 51 + 10 + rnd(-8, 8), 1.0 + rnd(-0.15, 0.2), 1.1, (i % 2 == 0) and LF or LF_DK, (i % 2 == 0) and LF_LT or LF)
		end

		---------------------------------------------------------------- crooked post
		local pts = {
			v(BX + 0.0, 1.4, 0.0),
			v(BX + 0.45, 5.4, -0.1),
			v(BX - 0.25, 9.4, 0.25),
			v(BX + 0.35, 13.2, -0.1),
			v(BX - 0.05, 16.6, 0.1),
			v(BX + 0.35, 18.6, 0.0),
		}
		local widths = { 1.7, 1.55, 1.4, 1.25, 1.1 }
		for i = 1, #pts - 1 do
			local a, b = pts[i], pts[i + 1]
			local d = (b - a).Unit
			B:bar(R, a - d * 0.3, b + d * 0.3, widths[i], widths[i], (i % 2 == 0) and WOOD or WOOD_DK)
			-- lighter grain strip on the front face
			B:bar(R, a + v(0, 0, -widths[i] / 2 - 0.02) + d * 0.4, b + v(0, 0, -widths[i] / 2 - 0.02) - d * 0.6, 0.3, 0.1, WOOD_LT)
		end
		-- crook over the top (curls toward +X)
		local crook = {
			pts[6],
			v(BX + 1.3, 19.6, 0),
			v(BX + 2.9, 19.9, 0),
			v(BX + 4.4, 19.4, 0),
			v(BX + 4.9, 18.4, 0),
		}
		local cw = { 1.05, 0.95, 0.85, 0.75 }
		for i = 1, #crook - 1 do
			local a, b = crook[i], crook[i + 1]
			local d = (b - a).Unit
			B:bar(R, a - d * 0.25, b + d * 0.25, cw[i], cw[i], (i % 2 == 0) and WOOD or WOOD_DK)
		end
		B:bar(R, crook[5], crook[5] + v(-0.35, -0.5, 0), 0.6, 0.6, WOOD_LT)
		-- bands at the knees
		for i = 2, 5 do
			local w = widths[math.min(i, 5)] + 0.2
			B:block(R, v(w, 0.35, w), CFrame.new(pts[i]) * ang(0, 10 * i, 0), (i % 2 == 0) and IRON or ROPE)
			if i % 2 == 0 then
				B:block(R, v(0.22, 0.22, 0.22), CFrame.new(pts[i] + v(0, 0, -w / 2)), IRON_LT)
			end
		end
		-- twig stubs
		for _, t in { { 2, 0.5, v(-1.0, 0.8, -0.3) }, { 3, 0.4, v(1.0, 0.9, 0.4) }, { 4, 0.6, v(-0.9, 0.7, 0.5) } } do
			local a = pts[t[1]]:Lerp(pts[t[1] + 1], t[2])
			B:bar(R, a, a + t[3], 0.4, 0.4, WOOD_LT)
			B:bar(R, a + t[3] * 0.9, a + t[3] * 1.4 + v(0, 0.3, 0), 0.25, 0.25, WOOD)
		end
		-- vine spiralling up the post
		local prev
		for k = 0, 16 do
			local y = 2.2 + k * 0.85
			local seg = math.clamp(math.floor((y - 1.4) / 4) + 1, 1, 4)
			local a0, b0 = pts[seg], pts[seg + 1]
			local f = math.clamp((y - a0.Y) / (b0.Y - a0.Y), 0, 1)
			local c = a0:Lerp(b0, f)
			local th = k * 70
			local r = widths[seg] / 2 + 0.12
			local p = c + v(math.cos(rad(th)) * r, 0, math.sin(rad(th)) * r)
			if prev then
				B:bar(R, prev, p, 0.24, 0.24, (k % 2 == 0) and VINE or VINE_LT)
			end
			if k % 4 == 2 then
				B:block(R, v(0.6, 0.12, 0.45), CFrame.new(p) * ang(0, -th, 20), VINE_LT)
			end
			prev = p
		end
		-- hanging moss from the crook
		for _, m in { { 1.5, 1.4 }, { 2.5, 2.0 }, { 3.4, 1.1 }, { 4.1, 0.8 } } do
			local x = BX + m[1]
			local y = 19.5
			B:block(R, v(0.55, m[2], 0.3), CFrame.new(x, y - m[2] / 2, 0.12), MOSS_DK)
			B:block(R, v(0.35, m[2] * 0.6, 0.3), CFrame.new(x + 0.15, y - m[2] * 0.3, -0.12), MOSS)
		end
		B:block(R, v(1.2, 0.25, 1.0), CFrame.new(crook[3] + v(0, 0.42, 0)) * ang(0, 15, 0), MOSS)

		-- arrow sign (points left, -X) nailed to the post
		local sp = pts[2]:Lerp(pts[3], 0.45) + v(0, 0, -0.75)
		local S = CFrame.new(sp) * ang(0, 0, -6)
		B:block(R, v(2.6, 0.9, 0.25), S * CFrame.new(-0.9, 0, 0), SIGN)
		B:block(R, v(0.75, 0.75, 0.24), S * CFrame.new(-2.2, 0, 0) * ang(0, 0, 45), SIGN)
		B:block(R, v(2.2, 0.18, 0.27), S * CFrame.new(-1.0, -0.2, 0), SIGN_DK)
		B:block(R, v(1.6, 0.16, 0.28), S * CFrame.new(-1.1, 0.12, 0), TEAL)
		B:block(R, v(0.2, 0.2, 0.3), S * CFrame.new(-0.1, 0.25, 0), IRON)
		-- peg + little bud lantern on the other side
		local pg = pts[3]:Lerp(pts[4], 0.25)
		local pegEnd = pg + v(1.5, 0.5, 0.4)
		B:bar(R, pg, pegEnd, 0.3, 0.3, WOOD_LT)
		B:bar(R, pegEnd - v(0.1, 0, 0), pegEnd - v(0.1, 0.5, 0), 0.08, 0.08, IRON)
		local bl = CFrame.new(pegEnd - v(0.1, 0.6, 0))
		B:block(R, v(0.7, 0.25, 0.7), bl * CFrame.new(0, -0.1, 0) * ang(0, 45, 0), VIO_DK)
		B:block(R, v(0.8, 0.85, 0.8), bl * CFrame.new(0, -0.65, 0), VIO)
		B:block(R, v(0.85, 0.2, 0.3), bl * CFrame.new(0, -0.65, 0), VIO_HI)
		B:block(R, v(0.4, 0.3, 0.4), bl * CFrame.new(0, -1.2, 0) * ang(0, 45, 0), VIO_LT)

		---------------------------------------------------------------- swinging lantern
		local hook = crook[5] + v(-0.3, -0.5, 0)
		local lant = B:bone("Lantern", "Root", hook)
		B:bar(lant, hook + v(0, 0.1, 0), hook - v(0, 0.9, 0), 0.14, 0.14, IRON)
		B:block(lant, v(0.4, 0.4, 0.4), CFrame.new(hook - v(0, 0.95, 0)) * ang(0, 0, 45), IRON_LT)
		local L = CFrame.new(hook - v(0, 1.15, 0))
		local function at(x, y, z)
			return L * CFrame.new(x, y, z)
		end
		local k = 1.6
		B:block(lant, v(0.6 * k, 0.3 * k, 0.6 * k), at(0, -0.1 * k, 0), IRON)
		B:block(lant, v(1.3 * k, 0.32 * k, 1.3 * k), at(0, -0.4 * k, 0) * ang(0, 45, 0), VIO_DK)
		B:block(lant, v(1.0 * k, 0.25 * k, 1.0 * k), at(0, -0.3 * k, 0), VIO)
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			B:block(lant, v(0.2 * k, 1.5 * k, 0.2 * k), at(c[1] * 0.47 * k, -1.3 * k, c[2] * 0.47 * k), VIO_LT)
		end
		B:block(lant, v(0.9 * k, 1.4 * k, 0.9 * k), at(0, -1.3 * k, 0), GLASS, { tr = 0.55 })
		B:block(lant, v(1.06 * k, 0.18 * k, 1.06 * k), at(0, -1.3 * k, 0), VIO)
		local flame = B:block(lant, v(0.5 * k, 0.5 * k, 0.5 * k), at(0, -1.35 * k, 0) * ang(45, 0, 45), WISP, { mat = "Neon", name = "LanternFlame" })
		B:block(lant, v(0.22 * k, 0.4 * k, 0.22 * k), at(0, -0.85 * k, 0) * ang(0, 45, 0), WISP_LT, NEON)
		B:block(lant, v(0.4 * k, 0.15 * k, 0.4 * k), at(0, -1.8 * k, 0), IRON)
		B:block(lant, v(1.15 * k, 0.28 * k, 1.15 * k), at(0, -2.15 * k, 0) * ang(0, 45, 0), VIO_DK)
		B:block(lant, v(0.3 * k, 0.35 * k, 0.3 * k), at(0, -2.45 * k, 0), VIO)
		local lanternCentre = at(0, -1.3 * k, 0).Position

		---------------------------------------------------------------- the will-o'-wisp
		-- built at its rest spot on the orbit (+X of the lantern); motion.luau
		-- carries it around the lantern (orbit radius ORB) with a gentle bob.
		local ORB = 2.4
		local WS = 1.2 -- wisp scale
		local WP = lanternCentre + v(ORB, 0.2, 0)
		local wisp = B:bone("Wisp", "Root", WP)
		local core = B:block(wisp, v(0.9 * WS, 0.9 * WS, 0.9 * WS), CFrame.new(WP) * ang(45, 0, 45), WISP_LT, { mat = "Neon", name = "WispCore" })
		B:block(wisp, v(1.35 * WS, 1.35 * WS, 1.35 * WS), CFrame.new(WP) * ang(0, 45, 0), WISP, { tr = 0.55 })
		B:block(wisp, v(1.6 * WS, 1.6 * WS, 1.6 * WS), CFrame.new(WP) * ang(20, 20, 0), GLASS, { tr = 0.82 })
		B:block(wisp, v(0.35 * WS, 0.55 * WS, 0.35 * WS), CFrame.new(WP + v(0, 0.95 * WS, 0)) * ang(0, 45, 0), WISP_LT, NEON)
		-- wispy tail trailing behind (+Z = behind the direction of travel at rest)
		B:block(wisp, v(0.8 * WS, 0.8 * WS, 0.8 * WS), CFrame.new(WP + v(0, -0.15 * WS, 0.95 * WS)) * ang(0, 45, 0), WISP, { tr = 0.45 })
		B:block(wisp, v(0.55 * WS, 0.55 * WS, 0.55 * WS), CFrame.new(WP + v(0, -0.3 * WS, 1.65 * WS)) * ang(0, 30, 0), WISP, { tr = 0.6 })
		B:block(wisp, v(0.35 * WS, 0.35 * WS, 0.35 * WS), CFrame.new(WP + v(0, -0.4 * WS, 2.2 * WS)), WISP_LT, { tr = 0.7 })
		B:trail(wisp, WP + v(0, 0.35, 0), WP - v(0, 0.35, 0), { name = "WispTrail", color = { WISP_LT, WISP }, life = 0.6, width = { 1, 0 }, trans = { 0.4, 1 } })
		-- two tiny motes that circle closer in
		local m1p = lanternCentre + v(-1.5, -0.9, 0)
		local m1 = B:bone("Mote1", "Root", m1p)
		B:block(m1, v(0.35, 0.35, 0.35), CFrame.new(m1p) * ang(45, 0, 45), WISP_LT, NEON)
		B:block(m1, v(0.6, 0.6, 0.6), CFrame.new(m1p), WISP, { tr = 0.7 })
		local m2p = lanternCentre + v(0, 1.0, 1.4)
		local m2 = B:bone("Mote2", "Root", m2p)
		B:block(m2, v(0.3, 0.3, 0.3), CFrame.new(m2p) * ang(45, 0, 45), VIO_HI, NEON)
		B:block(m2, v(0.55, 0.55, 0.55), CFrame.new(m2p), VIO_HI, { tr = 0.7 })

		---------------------------------------------------------------- VFX
		B:emitter(core, "sparkle", { name = "WispDust", color = { "#ffffff", WISP }, rate = 6, size = { 0.15, 0.35, 0 }, speed = { 0.1, 0.4 }, life = { 1.0, 1.8 }, accel = { 0, 0.5, 0 }, light = 1 })
		B:emitter(core, "glow", { name = "WispAura", color = { WISP_LT, WISP }, rate = 1.5, size = { 1.6, 2.4, 0.6 }, trans = { 0.8, 0.7, 1 }, light = 1 })
		B:light(core, { name = "WispLight", color = "#7ff4ff", brightness = 1.3, range = 16 })
		B:light(flame, { name = "LanternLight", color = "#b48cff", brightness = 0.7, range = 10 })
		local mist = B:block(R, v(8, 0.4, 8), cf(0, 0.7, 0), WATER, { tr = 1, name = "MistZone" })
		B:emitter(mist, "smoke", { name = "GroundMist", color = { "#cfe9ff", "#b9a8ff" }, rate = 1.2, size = { 1.4, 2.8, 3.6 }, trans = { 0.84, 0.88, 1 }, speed = { 0.1, 0.3 }, life = { 3, 5 }, spread = 90, accel = { 0, 0.06, 0 } })
		local ff = B:block(R, v(9, 8, 9), cf(0.5, 9, 0), WISP, { tr = 1, name = "FireflyZone" })
		B:emitter(ff, "sparkle", { name = "Fireflies", color = { "#e6ff7a", "#9dff6a" }, rate = 3, size = { 0.12, 0.28, 0 }, speed = { 0.1, 0.4 }, life = { 2, 3.5 } })
	end,
}
