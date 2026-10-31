--!nocheck
-- Boardwalk Dock (Misty Swamp decoration #1, medium piece).
-- A short, rickety swamp boardwalk on crooked stilts over a murky puddle:
-- uneven weathered planks (one missing, one snapped), a gentle sag, two
-- stringers, cross beams, wet dark stilt feet with moss rings, a little
-- plank ramp down to the mud bank, a sagging rope railing on stubby posts and
-- a crooked end post with a small wisp lantern hanging from an arm. The
-- puddle has lily pads, reeds and cattails, a mud/stone rim and swamp bubbles.
-- Static prop: no motion.luau.
return {
	DisplayName = "Boardwalk Dock",
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
		local PAD, PAD_DK, PAD_LT = "#3f8f4a", "#2d6b3a", "#6fbf5c"
		local REED, REED_DK, CATTAIL = "#6f8a3c", "#56702f", "#4a2e1c"
		local WOOD_DK, WOOD, WOOD_LT, WOOD_HI = "#4f3d2e", "#7a6148", "#96795a", "#ab906d"
		local WET = "#2f2620"
		local ROPE, ROPE_DK = "#c9b48a", "#a08d66"
		local VIO_DK, VIO, VIO_LT = "#3f2466", "#5b3590", "#7d52b8"
		local IRON = "#3a3f45"
		local GLASS = "#7fefff"
		local WISP, WISP_LT = "#5ff2ff", "#c8fff8"

		local seed = 5119
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end

		---------------------------------------------------------------- puddle
		local OX = 1.0                    -- shifts the whole build so its footprint is centred
		local PX = 0.5 + OX
		B:block(R, v(12.4, 0.2, 6.0), cf(PX, 0.1, 0, 0, 4, 0), WATER_DK)
		B:block(R, v(10.0, 0.22, 7.6), cf(PX - 0.4, 0.11, 0.2, 0, -6, 0), WATER_DK)
		B:block(R, v(11.0, 0.12, 5.2), cf(PX, 0.22, 0, 0, 4, 0), WATER)
		B:block(R, v(8.6, 0.12, 6.6), cf(PX - 0.4, 0.23, 0.2, 0, -6, 0), WATER)
		-- light ripple glints
		for _, r in { { -2.5, -2.4, 2.2, 10 }, { 3.6, 2.6, 1.8, -12 }, { 4.6, -2.0, 1.4, 20 }, { -4.0, 2.4, 1.2, -5 } } do
			B:block(R, v(r[3], 0.14, 0.22), cf(PX + r[1], 0.25, r[2], 0, r[4], 0), WATER_LT)
		end
		-- mud rim chunks + moss around the puddle edge
		for i = 0, 15 do
			local a = i / 16 * math.pi * 2 + rnd(-0.1, 0.1)
			local x, z = PX + math.cos(a) * 6.4, math.sin(a) * 3.9
			local w, d = rnd(1.4, 2.2), rnd(0.9, 1.3)
			local h = rnd(0.3, 0.5)
			B:block(R, v(w, h, d), cf(x, h / 2, z, 0, -math.deg(a) + 90 + rnd(-10, 10), 0), pick({ MUD, MUD_DK, MUD_LT, MUD }))
			if i % 3 == 0 then
				B:block(R, v(w * 0.7, 0.16, d * 0.8), cf(x, h + 0.06, z, 0, -math.deg(a) + 90, 0), pick({ MOSS, MOSS_LT }))
			end
		end
		local function stone(x, z, s, ry, moss)
			local c = cf(x, 0.3 * s + 0.05, z, 0, ry, 0)
			B:block(R, v(1.3 * s, 0.7 * s, 1.0 * s), c, STONE)
			B:block(R, v(0.8 * s, 0.3 * s, 0.6 * s), c * CFrame.new(0.15 * s, 0.45 * s, 0) * ang(0, 20, 0), STONE_LT)
			B:block(R, v(1.34 * s, 0.2 * s, 1.04 * s), c * CFrame.new(0, -0.25 * s, 0), STONE_DK)
			if moss then
				B:block(R, v(0.8 * s, 0.14, 0.7 * s), c * CFrame.new(-0.15 * s, 0.38 * s, 0), MOSS_LT)
			end
		end
		stone(PX + 6.3, -1.6, 1.0, 25, true)
		stone(PX - 3.0, -4.0, 0.8, -20, false)
		stone(PX + 2.6, 4.1, 0.9, 40, true)
		-- lily pads
		local function lily(x, z, s, a, col, flower)
			local c = cf(x, 0.32, z, 0, a, 0)
			B:block(R, v(1.5 * s, 0.1, 1.0 * s), c, col)
			B:block(R, v(1.0 * s, 0.09, 1.5 * s), c, col)
			B:block(R, v(0.45 * s, 0.12, 0.6 * s), c * CFrame.new(0, 0.01, -0.55 * s), WATER)
			B:block(R, v(0.35 * s, 0.13, 0.35 * s), c * CFrame.new(0.1 * s, 0.02, 0.15 * s), PAD_LT)
			if flower then
				B:block(R, v(0.5, 0.35, 0.5), c * CFrame.new(0.2 * s, 0.2, 0.3 * s) * ang(0, 45, 0), "#f2b8e6")
				B:block(R, v(0.25, 0.25, 0.25), c * CFrame.new(0.2 * s, 0.38, 0.3 * s), "#fff2a8")
			end
		end
		lily(PX - 1.5, -2.6, 1.0, 20, PAD, true)
		lily(PX + 3.8, -2.7, 0.8, -35, PAD_DK, false)
		lily(PX + 1.2, 2.6, 0.9, 60, PAD, false)
		lily(PX - 4.4, 2.2, 0.7, -10, PAD_DK, true)
		-- reeds + cattails
		local function reed(x, z, h, tz, tx, cat)
			local base = v(x, 0.25, z)
			local tip = base + v(-math.sin(rad(tz)) * h, h, math.sin(rad(tx)) * h)
			B:bar(R, base, tip, 0.22, 0.22, pick({ REED, REED_DK }))
			if cat then
				local d = (tip - base).Unit
				B:bar(R, tip - d * 0.2, tip + d * 0.9, 0.42, 0.42, CATTAIL)
				B:bar(R, tip + d * 0.85, tip + d * 1.3, 0.12, 0.12, REED_DK)
			end
		end
		reed(PX + 5.8, 1.8, 3.6, -8, 4, true)
		reed(PX + 6.2, 1.2, 2.6, -14, -6, false)
		reed(PX + 5.4, 2.5, 3.0, 4, 10, true)
		reed(PX - 5.6, -2.4, 3.2, 10, -6, true)
		reed(PX - 5.0, -2.9, 2.4, 4, -12, false)
		reed(PX - 1.0, 3.6, 2.8, 2, 10, true)
		reed(PX - 0.4, 3.8, 2.0, -12, 14, false)

		---------------------------------------------------------------- boardwalk
		local X0, X1 = -5.4 + OX, 5.6 + OX         -- deck span along X
		local W = 3.4                    -- deck width (Z)
		local function deckY(x)          -- sags a little in the middle, end dips
			local t = (x - X0) / (X1 - X0)
			return 3.0 - 0.4 * math.sin(math.pi * t) - 0.2 * t
		end
		local SZ = 1.35                  -- stilt rows at z = +-SZ
		local stilts = { -5.0 + OX, -1.4 + OX, 2.2 + OX, 5.2 + OX }
		-- stilts (crooked), wet feet, moss rings, cross beams
		for i, x in stilts do
			for _, s in { -1, 1 } do
				local top = deckY(x) - 0.2
				local lean = v(rnd(-0.25, 0.25), 0, rnd(-0.2, 0.2))
				local foot = v(x, 0.1, s * SZ) + lean
				B:bar(R, foot, v(x, top, s * SZ), 0.7, 0.7, (i % 2 == 0) and WOOD_DK or WOOD)
				B:bar(R, foot, foot + (v(x, top, s * SZ) - foot).Unit * 0.9, 0.78, 0.78, WET)
				B:block(R, v(1.0, 0.22, 1.0), CFrame.new(foot + v(0, 0.45, 0)) * ang(0, 45 * i, 0), MOSS_DK)
			end
			-- cross beam under the planks
			B:block(R, v(0.55, 0.5, W + 0.6), cf(x, deckY(x) - 0.45, 0, 0, rnd(-3, 3), rnd(-4, 4)), WOOD_DK)
		end
		-- X brace on the front between two stilt pairs
		B:bar(R, v(stilts[2], 0.5, -SZ - 0.42), v(stilts[3], deckY(stilts[3]) - 0.7, -SZ - 0.42), 0.35, 0.25, WOOD)
		B:bar(R, v(stilts[1], deckY(stilts[1]) - 0.7, -SZ - 0.42), v(stilts[2], 0.6, -SZ - 0.42), 0.35, 0.25, WOOD_DK)
		-- stringers (2 segments each so they follow the sag)
		for _, s in { -1, 1 } do
			local z = s * (SZ - 0.1)
			local mid = (X0 + X1) / 2
			B:bar(R, v(X0 - 0.3, deckY(X0) - 0.32, z), v(mid + 0.2, deckY(mid) - 0.32, z), 0.45, 0.45, WOOD_DK)
			B:bar(R, v(mid - 0.2, deckY(mid) - 0.32, z), v(X1 + 0.3, deckY(X1) - 0.32, z), 0.45, 0.45, WOOD_DK)
		end
		-- planks (across Z), uneven; one missing, one snapped
		local x = X0
		local k = 0
		while x <= X1 + 0.01 do
			k += 1
			local y = deckY(x)
			local col = pick({ WOOD, WOOD_LT, WOOD, WOOD_HI, WOOD_LT })
			if k == 8 then
				-- missing plank (gap)
			elseif k == 5 then
				-- snapped plank: short piece + a tilted broken half
				B:block(R, v(0.9, 0.32, 1.7), cf(x, y, -0.85, 0, 2, 0), col)
				B:block(R, v(0.9, 0.32, 1.6), cf(x + 0.05, y - 0.32, 0.95, 0, -4, -14), WOOD_DK)
			else
				local len = W + rnd(-0.3, 0.4)
				local zo = rnd(-0.2, 0.2)
				B:block(R, v(0.9, 0.32, len), cf(x, y + rnd(-0.03, 0.05), zo, rnd(-1.5, 1.5), rnd(-4, 4), rnd(-3, 3)), col)
				-- nail heads / dark knots on some planks
				if k % 3 == 1 then
					B:block(R, v(0.22, 0.06, 0.22), cf(x, y + 0.18, zo - len / 2 + 0.4), IRON)
					B:block(R, v(0.22, 0.06, 0.22), cf(x, y + 0.18, zo + len / 2 - 0.4), IRON)
				end
				if k == 3 or k == 10 then
					B:block(R, v(1.2, 0.12, 1.1), cf(x + 0.1, y + 0.2, zo + 1.0, 0, 15, 0), MOSS)
				end
			end
			x += 1.0
		end
		-- ramp down to the mud bank at the -X end
		local rampTop = v(X0 - 0.4, deckY(X0) - 0.05, 0)
		local rampBot = v(X0 - 3.4, 0.35, 0.1)
		for _, z in { -1.0, 0.0, 1.0 } do
			B:bar(R, rampTop + v(0, 0, z), rampBot + v(0, 0, z * 0.95), 0.95, 0.3, pick({ WOOD, WOOD_LT, WOOD_HI }), { up = v(0, 1, 0) })
		end
		-- cleats across the ramp
		for _, f in { 0.35, 0.7 } do
			local p = rampTop:Lerp(rampBot, f) + v(0, 0.2, 0)
			B:block(R, v(0.3, 0.2, 3.0), CFrame.new(p), WOOD_DK)
		end
		-- mud bank under the ramp foot
		B:block(R, v(2.4, 0.4, 3.6), cf(X0 - 3.3, 0.2, 0.1, 0, 6, 0), MUD)
		B:block(R, v(1.6, 0.44, 2.6), cf(X0 - 3.6, 0.22, 0.3, 0, -10, 0), MUD_LT)
		B:block(R, v(1.4, 0.16, 1.2), cf(X0 - 3.8, 0.46, -0.9, 0, 20, 0), MOSS)

		---------------------------------------------------------------- rope railing (back side)
		local postTops = {}
		for i, px in stilts do
			if i < #stilts then
				local base = v(px, deckY(px) - 0.4, SZ + 0.05)
				local top = v(px + rnd(-0.15, 0.15), deckY(px) + 2.0 + rnd(-0.2, 0.2), SZ + 0.05)
				B:bar(R, base, top, 0.6, 0.6, (i % 2 == 0) and WOOD or WOOD_DK)
				B:block(R, v(0.75, 0.3, 0.75), CFrame.new(top - v(0, 0.35, 0)), ROPE_DK)
				table.insert(postTops, top - v(0, 0.35, 0))
			end
		end
		for i = 1, #postTops - 1 do
			local a, b = postTops[i], postTops[i + 1]
			local m = a:Lerp(b, 0.5) - v(0, 0.55, 0)
			local q1, q2 = a:Lerp(m, 0.5) - v(0, 0.12, 0), m:Lerp(b, 0.5) - v(0, 0.12, 0)
			for _, seg in { { a, q1 }, { q1, m }, { m, q2 }, { q2, b } } do
				B:bar(R, seg[1], seg[2], 0.2, 0.2, ROPE)
			end
		end
		-- loose rope end dangling past the last post toward the lantern post
		local lt = postTops[#postTops]
		B:bar(R, lt, lt + v(0.5, -0.8, 0.05), 0.2, 0.2, ROPE)
		B:bar(R, lt + v(0.5, -0.8, 0.05), lt + v(0.55, -1.4, 0.1), 0.2, 0.2, ROPE_DK)
		-- fishing pole leaning on the middle railing post, line into the puddle
		local pt = postTops[2]
		local rodBase = v(pt.X - 1.1, deckY(pt.X - 1.1) + 0.2, SZ - 0.6)
		local rodTip = pt + v(1.6, 1.9, 1.7)
		B:bar(R, rodBase, rodTip, 0.2, 0.2, "#8a6a3e")
		B:bar(R, rodBase, rodBase + (rodTip - rodBase).Unit * 0.9, 0.3, 0.3, WOOD_DK)
		local bob = v(rodTip.X + 0.6, 0.45, rodTip.Z + 0.2)
		B:bar(R, rodTip, bob + v(0, 0.2, 0), 0.06, 0.06, "#e8e8e0")
		B:block(R, v(0.3, 0.2, 0.3), CFrame.new(bob + v(0, 0.05, 0)), "#e8e8e0")
		B:block(R, v(0.3, 0.2, 0.3), CFrame.new(bob + v(0, 0.25, 0)), "#e0483c")
		-- glowing shelf fungi on a front stilt (ties it to the glowcap crops)
		for _, f in { { 0.9, 1.0 }, { 1.5, 0.7 } } do
			local c = CFrame.new(stilts[2], f[1], -SZ - 0.45)
			B:block(R, v(1.0 * f[2], 0.25, 0.7 * f[2]), c, "#2fa39a")
			B:block(R, v(0.6 * f[2], 0.22, 0.4 * f[2]), c * CFrame.new(0, 0.18, 0.05), "#57cfc0")
			B:block(R, v(0.7 * f[2], 0.07, 0.35 * f[2]), c * CFrame.new(0, -0.15, -0.1), WISP, { mat = "Neon" })
		end
		-- rope coil on the deck
		local cx, cz = 3.4 + OX, 0.6
		local cy = deckY(cx) + 0.22
		B:block(R, v(1.2, 0.2, 1.2), cf(cx, cy, cz, 0, 20, 0), ROPE)
		B:block(R, v(1.2, 0.2, 1.2), cf(cx, cy, cz, 0, 65, 0), ROPE_DK)
		B:block(R, v(0.9, 0.2, 0.9), cf(cx, cy + 0.18, cz, 0, 40, 0), ROPE)
		B:block(R, v(0.4, 0.22, 0.4), cf(cx, cy + 0.2, cz, 0, 40, 0), WOOD_DK)

		---------------------------------------------------------------- lantern post
		local LX, LZ = 5.2 + OX, -SZ - 0.05
		local lp0 = v(LX, deckY(LX) - 0.4, LZ)
		local lp1 = v(LX + 0.15, deckY(LX) + 2.4, LZ - 0.05)
		local lp2 = v(LX - 0.1, deckY(LX) + 4.6, LZ + 0.05)
		B:bar(R, lp0, lp1 + v(0, 0.1, 0), 0.7, 0.7, WOOD)
		B:bar(R, lp1 - v(0, 0.1, 0), lp2, 0.6, 0.6, WOOD)
		B:block(R, v(0.8, 0.35, 0.8), CFrame.new(lp2 + v(0, 0.05, 0)), WOOD_DK)
		B:block(R, v(0.78, 0.35, 0.78), CFrame.new(lp1 + v(0, 0.3, 0)) * ang(0, 30, 0), ROPE_DK)
		-- arm out toward +X with a brace
		local armEnd = lp2 + v(1.9, 0.0, 0)
		B:bar(R, lp2 + v(-0.3, -0.15, 0), armEnd + v(0.1, -0.15, 0), 0.4, 0.4, WOOD_DK)
		B:bar(R, lp2 + v(0.05, -1.3, 0), lp2 + v(1.0, -0.3, 0), 0.3, 0.3, WOOD)
		-- moss tuft on the post top
		B:block(R, v(0.9, 0.18, 0.9), CFrame.new(lp2 + v(0, 0.3, 0)) * ang(0, 20, 0), MOSS)
		-- hanging lantern
		local K = 1.3
		local hang = armEnd + v(-0.2, -0.35, 0)
		B:bar(R, hang, hang - v(0, 0.6, 0), 0.12, 0.12, IRON)
		local L = CFrame.new(hang - v(0, 0.6, 0))
		local function at(px, py, pz)
			return L * CFrame.new(px, py, pz)
		end
		B:block(R, v(0.5 * K, 0.25 * K, 0.5 * K), at(0, -0.1 * K, 0), IRON)
		B:block(R, v(1.15 * K, 0.28 * K, 1.15 * K), at(0, -0.35 * K, 0) * ang(0, 45, 0), VIO_DK)
		B:block(R, v(0.9 * K, 0.22 * K, 0.9 * K), at(0, -0.25 * K, 0), VIO)
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			B:block(R, v(0.18 * K, 1.3 * K, 0.18 * K), at(c[1] * 0.42 * K, -1.15 * K, c[2] * 0.42 * K), VIO_LT)
		end
		B:block(R, v(0.8 * K, 1.2 * K, 0.8 * K), at(0, -1.15 * K, 0), GLASS, { tr = 0.55 })
		local core = B:block(R, v(0.5 * K, 0.5 * K, 0.5 * K), at(0, -1.1 * K, 0) * ang(45, 0, 45), WISP, { mat = "Neon", name = "LanternCore" })
		B:block(R, v(0.2 * K, 0.35 * K, 0.2 * K), at(0, -0.7 * K, 0), WISP_LT, { mat = "Neon" })
		B:block(R, v(1.0 * K, 0.25 * K, 1.0 * K), at(0, -1.9 * K, 0) * ang(0, 45, 0), VIO_DK)
		B:block(R, v(0.25 * K, 0.3 * K, 0.25 * K), at(0, -2.15 * K, 0), VIO)

		---------------------------------------------------------------- VFX
		B:emitter(core, "sparkle", { name = "LanternMotes", color = { "#ffffff", WISP }, rate = 3, size = { 0.12, 0.3, 0 }, speed = { 0.2, 0.5 }, life = { 1.4, 2.4 }, accel = { 0, 0.6, 0 }, light = 1 })
		B:emitter(core, "glow", { name = "LanternAura", color = { WISP_LT, WISP }, rate = 1.2, size = { 1.2, 1.8, 0.5 }, trans = { 0.8, 0.7, 1 }, light = 1 })
		B:light(core, { name = "LanternLight", color = "#7ff4ff", brightness = 1.2, range = 12 })
		local pud = B:block(R, v(9, 0.1, 5), cf(PX, 0.3, 0), WATER, { tr = 1, name = "PuddleZone" })
		B:emitter(pud, "bubble", { name = "PuddleBubbles", color = { "#c8fff0", WISP }, rate = 1.5, size = { 0.12, 0.25, 0.3 }, speed = { 0.3, 0.7 } })
		B:emitter(pud, "smoke", { name = "PuddleMist", color = { "#cfe9ff", "#b9a8ff" }, rate = 1.2, size = { 1.4, 2.8, 3.6 }, trans = { 0.84, 0.88, 1 }, speed = { 0.1, 0.3 }, life = { 3, 5 }, spread = 90, accel = { 0, 0.08, 0 } })
	end,
}
