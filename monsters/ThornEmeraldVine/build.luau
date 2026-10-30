--!nocheck
-- Emerald Thornvine (Thorny Woods crop #9, Divine): a huge thorny vine that
-- has swallowed a ruined stone arch deep in the enchanted wood.
-- * a stepped mossy dirt mound (bone "Soil") with chunky edge blocks, moss
--   pads, stones, little red toadstools, thorny twigs, two emerald shards
--   poking out of the ground and the fallen arch stone that broke loose
-- * two weathered stone pillars (stacked drums, a little crooked, cracked,
--   moss patches) carrying a stepped round arch with an emerald keystone; one
--   voussoir is missing and the vine bridges the gap
-- * two thick thorny vines spiral up the pillars and twist over the arch,
--   with cream thorns, big studded leaf cubes and crimson briar roses; a
--   leafy crown with a big rose bloom sits on top of the arch
-- * faceted emerald crystal fruits hang like a chandelier under the arch and
--   from side shoots, each with a tiny neon glint
-- * soft green sparkles, a gentle glow under the arch, one soft green light
-- Static crop: no motion.luau. Blocks only (no wedges / round parts).
return {
	DisplayName = "Emerald Thornvine",
	Rarity = "Divine",
	Element = "Nature",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ----------------------------------------------------------
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3b2416", "#4a2c1a", "#65402a", "#7f5535"
		local MOSS, MOSS_DK, MOSS_LT = "#5fa83a", "#3f7f2c", "#86c94a"
		local GRASS, GRASS_DK = "#57c23d", "#3a9a30"
		local STONE, STONE_LT, STONE_DK, STONE_DKR = "#9a968c", "#b4afa2", "#7a766d", "#5f5c56"
		local VINE, VINE_DK = "#567a2c", "#3a5a22"
		local THORN = "#ecdfb8"
		local LF_DK, LF, LF_MID, LF_LT = "#1d7438", "#289043", "#37a64d", "#5cc45a"
		local EM, EM_DK, EM_LT, EM_GLOW = "#16c06a", "#0a8448", "#62f0a6", "#a4ffd0"
		local ROSE, ROSE_DK, ROSE_LT = "#d8203e", "#9a1430", "#ff5a77"
		local MUSH, MUSH_SPOT, MUSH_STEM = "#d0343c", "#fff1dc", "#efe2c6"
		local TWIG = "#4a3020"
		local GOLD, GOLD_LT = "#f2b844", "#ffe08a"

		local seed = 919
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

		------------------------------------------------------------------
		-- STEPPED MOSSY MOUND (bone "Soil", every part named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(y0, y1, w, d, color)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(soil, v(w, h, d * 0.62), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.62, h + 0.02, d), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.85, h - 0.03, d * 0.85), cf(0, y, 0), color, S)
		end
		oct(0, 1.0, 17.0, 15.0, DIRT_DK)
		oct(1.0, 1.9, 13.4, 11.0, DIRT)
		oct(1.9, 2.5, 9.0, 7.0, DIRT_LT)
		-- chunky irregular edge blocks
		for i = 0, 15 do
			local a = i * 22.5 + jit(5)
			local ar = rad(a)
			local rx, rz = 8.2, 7.2
			local x, z = math.sin(ar) * rx, -math.cos(ar) * rz
			local h = 0.9 + rnd() * 0.7
			B:block(soil, v(2.6 + rnd() * 0.8, h, 1.9 + rnd() * 0.5), cf(x, h / 2, z, 0, -a + jit(10), 0),
				i % 3 == 0 and DIRT or (i % 2 == 0 and DIRT_DK2 or DIRT_DK), S)
		end
		for i = 0, 7 do
			local a = i * 45 + 22 + jit(8)
			local ar = rad(a)
			local x, z = math.sin(ar) * 6.4, -math.cos(ar) * 5.2
			local h = 0.7 + rnd() * 0.4
			B:block(soil, v(2.0 + rnd() * 0.5, h, 1.5), cf(x, 1.0 + h / 2, z, 0, -a + jit(12), 0), i % 2 == 0 and DIRT or DIRT_DK2, S)
		end
		-- moss pads draped over the tier edges
		for _, m in { { 20, 8.2, 7.1, 1.05, 2.6, MOSS }, { 95, 8.2, 7.1, 1.05, 2.2, MOSS_DK }, { 150, 8.2, 7.1, 1.05, 2.4, MOSS }, { 215, 8.2, 7.1, 1.05, 2.6, MOSS_DK },
			{ 275, 8.2, 7.1, 1.05, 2.0, MOSS }, { 330, 8.2, 7.1, 1.05, 2.3, MOSS_LT }, { 190, 6.4, 5.3, 1.95, 2.0, MOSS_LT },
			{ 0, 4.3, 3.4, 2.55, 2.4, MOSS_DK } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], m[4], -math.cos(a) * m[3]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[5], 0.32, 1.4), c * ang(-14, 0, 0), m[6], S)
		end
		-- stones
		for _, s in { { 7.0, 1.2, -2.8, 1.0, 25, STONE }, { -7.0, 1.15, 3.2, 0.9, -20, STONE_DK }, { 2.9, 1.0, 6.6, 0.8, 40, STONE }, { -2.4, 2.3, 3.0, 0.6, 15, STONE_LT } } do
			B:block(soil, v(s[4] * 1.25, s[4], s[4]), cf(s[1], s[2], s[3], 0, s[5], jit(6)), s[6], S)
		end
		-- grass tufts
		for _, g in { { 8.6, 1.6 }, { 4.6, -6.9 }, { -8.5, -1.4 }, { -3.6, 7.0 } } do
			B:block(soil, v(0.5, 1.0, 0.5), cf(g[1], 0.5, g[2], 0, jit(30), 0), GRASS, S)
			B:block(soil, v(0.4, 0.7, 0.4), cf(g[1] + 0.35, 0.35, g[2] + 0.25, 0, jit(30), 0), GRASS_DK, S)
		end
		-- little red toadstools
		for _, m in { { -5.9, 1.0, -4.5, 1.0 }, { -6.7, 1.0, -3.6, 0.7 }, { 5.7, 1.9, 3.3, 0.8 } } do
			local s = m[4]
			B:block(soil, v(0.45 * s, 1.0 * s, 0.45 * s), cf(m[1], m[2] + 0.5 * s, m[3]), MUSH_STEM, S)
			B:block(soil, v(1.3 * s, 0.5 * s, 1.3 * s), cf(m[1], m[2] + 1.1 * s, m[3], 0, 20, 0), MUSH, S)
			B:block(soil, v(0.8 * s, 0.3 * s, 0.8 * s), cf(m[1], m[2] + 1.45 * s, m[3], 0, 20, 0), MUSH, S)
			B:block(soil, v(0.3, 0.12, 0.3), cf(m[1] + 0.3 * s, m[2] + 1.36 * s, m[3] - 0.45 * s, 0, 20, 0), MUSH_SPOT, S)
		end
		-- thorny twigs lying on the mound
		for _, t in { { v(3.8, 2.6, -2.6), v(6.6, 1.95, -4.1) }, { v(-3.4, 2.6, 2.4), v(-6.2, 1.95, 4.3) } } do
			B:bar(soil, t[1], t[2], 0.3, 0.3, TWIG, S)
			local mid = t[1]:Lerp(t[2], 0.5)
			B:bar(soil, mid, mid + v(0, 0.55, 0.15), 0.16, 0.16, THORN, S)
		end
		-- emerald shards poking out of the ground
		for _, e in { { -2.8, 2.5, -2.6, 1.0, 15, 12 }, { 3.0, 1.9, 4.5, 0.8, -20, -10 } } do
			local s = e[4]
			B:block(soil, v(0.9 * s, 1.6 * s, 0.9 * s), cf(e[1], e[2] + 0.6 * s, e[3], 0, 45, e[6]), EM_DK, S)
			B:block(soil, v(0.6 * s, 1.0 * s, 0.6 * s), cf(e[1] + 0.35 * s, e[2] + 0.45 * s, e[3] - 0.3 * s, e[5], 45, e[6] - 25), EM, S)
			B:block(soil, v(0.2, 0.5 * s, 0.12), cf(e[1], e[2] + 0.9 * s, e[3] - 0.46 * s, 0, 0, e[6]), EM_GLOW, { name = "Soil", mat = "Neon" })
		end
		-- the fallen arch stone (the missing voussoir), half sunk in the moss
		B:block(soil, v(2.2, 1.8, 2.4), cf(4.3, 2.75, -4.4, 0, 28, 14), STONE, S)
		B:block(soil, v(1.6, 0.3, 1.4), cf(4.1, 3.7, -4.3, 0, 28, 14), MOSS, S)
		B:block(soil, v(0.9, 0.7, 0.8), cf(5.6, 1.35, -5.6, 0, 50, 0), STONE_DK, S)

		------------------------------------------------------------------
		-- RUINED STONE ARCH (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, 2.5, 0))
		local PX = 4.6 -- pillar centres at x = +-PX
		local DRUM_W, DRUM_H = 2.6, 1.85
		local TOPY = 13.2 -- top of the pillar drums
		local AC = 14.1 -- arch centre height (top of the capitals)
		local AR = 4.6 -- arch block radius
		for _, sx in { -1, 1 } do
			local x = sx * PX
			-- plinths
			B:block(crop, v(3.6, 1.2, 3.6), cf(x, 2.5, 0, 0, 0, 0), STONE_DK)
			B:block(crop, v(3.2, 0.6, 3.2), cf(x, 3.4, 0, 0, sx * 3, 0), STONE)
			-- stacked drums
			local y, k = 3.7, 0
			while y < TOPY - 0.05 do
				local h = math.min(DRUM_H, TOPY - y)
				local col = (k % 3 == 0) and STONE_LT or ((k % 3 == 1) and STONE or STONE_DK)
				B:block(crop, v(DRUM_W, h, DRUM_W), cf(x + jit(0.12), y + h / 2, jit(0.12), 0, jit(5), 0), col)
				y += h
				k += 1
			end
			-- capitals
			B:block(crop, v(3.0, 0.5, 3.0), cf(x, TOPY + 0.25, 0), STONE)
			B:block(crop, v(3.5, 0.45, 3.4), cf(x, TOPY + 0.7, 0, 0, sx * 2, 0), STONE_LT)
		end
		-- chips, cracks and moss patches on the pillars (faces: outer side, front, back)
		for _, c in {
			-- x side, y, face ("f" front -Z, "b" back +Z, "o" outer), size w, h, colour
			{ -1, 5.2, "f", 1.4, 0.8, MOSS }, { -1, 9.4, "o", 1.0, 1.4, STONE_DKR }, { -1, 12.1, "f", 0.8, 0.6, STONE_DKR },
			{ 1, 6.6, "o", 1.6, 0.9, MOSS_DK }, { 1, 10.6, "f", 0.7, 1.3, STONE_DKR }, { 1, 4.4, "b", 1.5, 0.7, MOSS },
			{ -1, 7.8, "b", 1.2, 0.9, MOSS_DK }, { 1, 12.8, "b", 0.9, 0.6, STONE_DKR },
		} do
			local x = c[1] * PX
			local p
			if c[3] == "f" then
				p = cf(x + jit(0.4), c[2], -DRUM_W / 2 - 0.08)
				B:block(crop, v(c[4], c[5], 0.3), p, c[6])
			elseif c[3] == "b" then
				p = cf(x + jit(0.4), c[2], DRUM_W / 2 + 0.08)
				B:block(crop, v(c[4], c[5], 0.3), p, c[6])
			else
				p = cf(x + c[1] * (DRUM_W / 2 + 0.08), c[2], jit(0.4))
				B:block(crop, v(0.3, c[5], c[4]), p, c[6])
			end
		end
		-- chipped corner chunks (a stone corner knocked off: darker block poking out)
		B:block(crop, v(0.9, 0.8, 0.9), cf(-PX - 1.15, 11.0, -1.15, 0, 20, 0), STONE_DK)
		B:block(crop, v(0.8, 0.7, 0.8), cf(PX + 1.15, 8.6, 1.1, 0, -15, 0), STONE_DK)

		-- the arch: stepped voussoirs around (0, AC), local +Y radial
		local N = 7
		local keyCF
		for i = 0, N - 1 do
			local th = 180 - (i + 0.5) * 180 / N
			local tr = rad(th)
			local pos = v(math.cos(tr) * AR, AC + math.sin(tr) * AR, 0)
			local c = CFrame.new(pos) * CFrame.Angles(0, 0, rad(th - 90))
			if i == 3 then
				-- keystone: taller, with a carved emerald inset
				keyCF = c
				B:block(crop, v(2.4, 2.6, 2.9), c * CFrame.new(0, 0.2, 0), STONE_LT)
				B:block(crop, v(1.0, 1.2, 0.3), c * CFrame.new(0, 0.3, -1.5), STONE_DKR)
				B:block(crop, v(0.6, 0.8, 0.2), c * CFrame.new(0, 0.3, -1.62), EM, { mat = "Neon", name = "KeyGem" })
				B:block(crop, v(1.0, 1.2, 0.3), c * CFrame.new(0, 0.3, 1.5), STONE_DKR)
				B:block(crop, v(0.6, 0.8, 0.2), c * CFrame.new(0, 0.3, 1.62), EM, { mat = "Neon", name = "KeyGem" })
			elseif i == 4 then
				-- missing stone: only a broken stub on the keystone side
				B:block(crop, v(0.9, 1.6, 2.4), c * CFrame.new(-0.75, -0.1, 0) * ang(0, 0, 6), STONE_DK)
			elseif i == 5 then
				-- loose stone, slipped and tilted
				B:block(crop, v(2.2, 2.0, 2.6), c * CFrame.new(0.15, -0.15, 0.1) * ang(4, 0, -7), STONE)
			else
				B:block(crop, v(2.25, 2.0, 2.6), c, (i % 2 == 0) and STONE or STONE_LT)
			end
		end
		-- moss on top of the arch shoulders
		for _, th in { 160, 128, 18 } do
			local tr = rad(th)
			local pos = v(math.cos(tr) * (AR + 1.05), AC + math.sin(tr) * (AR + 1.05), jit(0.3))
			B:block(crop, v(1.6, 0.3, 2.0), CFrame.new(pos) * CFrame.Angles(0, 0, rad(th - 90)), MOSS)
		end

		------------------------------------------------------------------
		-- THORNY VINES
		------------------------------------------------------------------
		local thornFlip = 1
		local function thorn(p, dir)
			dir = dir.Unit
			B:bar(crop, p + dir * 0.2, p + dir * 1.15, 0.28, 0.28, THORN)
		end
		local function leaf(p, s, col)
			B:block(crop, v(s, s, s), CFrame.new(p) * ang(jit(25), rnd() * 90, jit(25)), col)
		end
		local LEAFCOLS = { LF_DK, LF, LF_MID, LF_LT }
		-- run a vine through points; thorns stick out sideways, leaves every few nodes
		local function vine(pts, w, opts)
			opts = opts or {}
			for i = 1, #pts - 1 do
				local a, b = pts[i], pts[i + 1]
				B:bar(crop, a, b, w, w, (i % 2 == 0) and VINE or VINE_DK)
				local d = (b - a).Unit
				local side = d:Cross(v(0, 1, 0))
				if side.Magnitude < 0.2 then
					side = d:Cross(v(1, 0, 0))
				end
				side = side.Unit
				if opts.out then
					side = opts.out(a:Lerp(b, 0.5))
				end
				if i % (opts.thornEvery or 1) == 0 then
					thorn(a:Lerp(b, 0.5), side * thornFlip + v(0, 0.25, 0))
					thornFlip = -thornFlip
				end
				if opts.leafEvery and i % opts.leafEvery == (opts.leafOff or 0) then
					local o = opts.out and opts.out(b) or side
					leaf(b + o * (w * 0.5 + 0.3), opts.leafSize or 1.8, LEAFCOLS[1 + (i % 4)])
				end
			end
		end

		-- spiral up each pillar
		local function spiral(sx, y0, y1, turns, deg0, n)
			local pts = {}
			for i = 0, n do
				local t = i / n
				local deg = deg0 + sx * t * turns * 360
				local x, z = polar(1.95, deg)
				table.insert(pts, v(sx * PX + x, y0 + (y1 - y0) * t, z))
			end
			return pts
		end
		local leftPts = spiral(-1, 2.6, 13.6, 2.25, 200, 20)
		local rightPts = spiral(1, 2.6, 13.4, 1.75, 150, 16)
		local function outFrom(cx)
			return function(p)
				local o = v(p.X - cx, 0, p.Z)
				return o.Magnitude > 0.01 and o.Unit or v(0, 0, -1)
			end
		end
		vine(leftPts, 0.85, { out = outFrom(-PX), leafEvery = 4, leafOff = 1, leafSize = 1.7 })
		vine(rightPts, 0.8, { out = outFrom(PX), leafEvery = 4, leafOff = 2, leafSize = 1.6 })
		-- root flare where the vines leave the ground
		B:bar(crop, leftPts[1] + v(0, 0.3, 0), leftPts[1] + v(-1.4, -0.35, -0.9), 0.75, 0.6, VINE_DK)
		B:bar(crop, rightPts[1] + v(0, 0.3, 0), rightPts[1] + v(1.3, -0.35, -1.0), 0.7, 0.6, VINE_DK)

		-- over the arch: from the top of the left spiral, twisting front/back
		local archPts = { leftPts[#leftPts] }
		local VR = AR + 1.25
		for i = 0, 12 do
			local th = 178 - i * 14.5
			local tr = rad(th)
			table.insert(archPts, v(math.cos(tr) * VR, AC + math.sin(tr) * VR, 0.85 * math.sin(i * 0.9)))
		end
		table.insert(archPts, rightPts[#rightPts])
		vine(archPts, 0.9, {
			out = function(p)
				return v(p.X, p.Y - AC, 0).Unit
			end,
			leafEvery = 3,
			leafOff = 1,
			leafSize = 2.0,
		})

		------------------------------------------------------------------
		-- LEAFY CROWN on top of the arch + crimson rose bloom
		------------------------------------------------------------------
		local TOP = AC + AR + 1.0
		for _, l in {
			-- x, y, z, size, colour
			{ 0, TOP + 0.9, 0.5, 3.4, LF_DK },
			{ -2.1, TOP + 0.3, -0.6, 2.8, LF },
			{ 2.0, TOP + 0.2, 0.7, 2.8, LF_MID },
			{ -0.8, TOP + 1.9, 0.9, 2.6, LF_LT },
			{ 1.0, TOP + 1.8, -0.6, 2.6, LF },
			{ -3.6, TOP - 0.9, 0.5, 2.3, LF_MID },
			{ 3.5, TOP - 1.0, -0.4, 2.3, LF_DK },
			{ -0.3, TOP + 0.3, 2.1, 2.4, LF_LT },
			{ 1.6, TOP - 0.2, -2.0, 2.2, LF_MID },
			{ -1.7, TOP - 0.4, 2.4, 2.0, LF },
		} do
			leaf(v(l[1], l[2], l[3]), l[4], l[5])
		end
		-- shoulder leaf clumps at the pillar tops (outside)
		for _, l in { { -6.2, 14.2, -0.6, 2.2, LF }, { 6.2, 14.0, 0.6, 2.2, LF_MID } } do
			leaf(v(l[1], l[2], l[3]), l[4], l[5])
		end

		local function rose(p, s, yaw)
			local c = CFrame.new(p) * ang(0, yaw or 0, 0)
			B:block(crop, v(1.3 * s, 0.35 * s, 1.3 * s), c * CFrame.new(0, -0.45 * s, 0) * ang(0, 45, 0), LF_DK) -- sepals
			B:block(crop, v(1.15 * s, 0.8 * s, 1.15 * s), c, ROSE_DK)
			B:block(crop, v(0.95 * s, 0.75 * s, 0.95 * s), c * CFrame.new(0, 0.3 * s, 0) * ang(0, 45, 0), ROSE)
			B:block(crop, v(0.45 * s, 0.4 * s, 0.45 * s), c * CFrame.new(0, 0.62 * s, 0), ROSE_LT)
		end
		-- the big bloom on top
		do
			local p = v(0.1, TOP + 2.7, -0.2)
			B:block(crop, v(2.6, 0.4, 2.6), CFrame.new(p + v(0, -0.85, 0)) * ang(0, 45, 0), LF_LT)
			B:block(crop, v(2.3, 1.2, 2.3), CFrame.new(p + v(0, -0.2, 0)) * ang(0, 0, 0), ROSE_DK)
			B:block(crop, v(2.0, 1.1, 2.0), CFrame.new(p + v(0, 0.35, 0)) * ang(0, 45, 0), ROSE)
			B:block(crop, v(1.3, 0.9, 1.3), CFrame.new(p + v(0, 0.75, 0)) * ang(0, 20, 0), ROSE)
			B:block(crop, v(0.7, 0.6, 0.7), CFrame.new(p + v(0, 1.1, 0)) * ang(0, 65, 0), ROSE_LT)
			-- outer petals splayed at the base
			for i = 0, 3 do
				local a = i * 90 + 20
				local c = CFrame.new(p + v(0, -0.15, 0)) * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0, -1.25) * ang(-28, 0, 0)
				B:block(crop, v(1.3, 0.35, 0.9), c, (i % 2 == 0) and ROSE or ROSE_DK)
			end
		end
		-- small briar roses along the vines
		rose(leftPts[6] + v(-0.6, 0.2, -0.9), 0.9, 15)
		rose(rightPts[5] + v(0.7, 0.2, -0.8), 0.9, -10)
		rose(archPts[4] + v(0, 0.6, -0.8), 0.95, 10)
		rose(archPts[11] + v(0.2, 0.6, 0.9), 0.9, -30)
		rose(v(-2.6, TOP + 1.7, -1.5), 0.8, 30)
		rose(v(2.6, TOP + 1.2, 1.4), 0.8, -20)
		-- rose bushes at the pillar feet
		for _, b in { { -6.4, 2.6, -2.4 }, { 6.5, 2.2, -2.0 } } do
			leaf(v(b[1], b[2], b[3]), 1.8, LF)
			leaf(v(b[1] + 0.6, b[2] + 0.6, b[3] + 0.6), 1.5, LF_MID)
			rose(v(b[1] - 0.2, b[2] + 1.15, b[3] - 0.2), 0.8, 20)
		end

		------------------------------------------------------------------
		-- EMERALD CRYSTAL FRUITS (faceted, hanging on thin vine stems)
		------------------------------------------------------------------
		local function crystal(top, drop, s, yaw)
			local c = top - v(0, drop + 1.05 * s, 0)
			local R = CFrame.new(c) * ang(0, yaw, 0)
			B:bar(crop, top + v(0, 0.3, 0), c + v(0, 0.9 * s, 0), 0.28, 0.28, VINE_DK)
			B:block(crop, v(1.0 * s, 0.3 * s, 1.0 * s), R * CFrame.new(0, 1.18 * s, 0) * ang(0, 45, 0), GOLD) -- gold calyx
			B:block(crop, v(0.4 * s, 0.3 * s, 0.4 * s), R * CFrame.new(0, 1.42 * s, 0), GOLD_LT)
			B:block(crop, v(0.7 * s, 0.5 * s, 0.7 * s), R * CFrame.new(0, 0.95 * s, 0), EM_DK)
			B:block(crop, v(1.25 * s, 0.6 * s, 1.25 * s), R * CFrame.new(0, 0.5 * s, 0) * ang(0, 45, 0), EM)
			B:block(crop, v(1.6 * s, 0.75 * s, 1.6 * s), R, EM)
			B:block(crop, v(1.25 * s, 0.77 * s, 1.25 * s), R * ang(0, 45, 0), EM_LT)
			B:block(crop, v(1.15 * s, 0.6 * s, 1.15 * s), R * CFrame.new(0, -0.6 * s, 0), EM_DK)
			B:block(crop, v(0.6 * s, 0.6 * s, 0.6 * s), R * CFrame.new(0, -1.05 * s, 0) * ang(0, 45, 0), EM)
			-- tiny neon glint on the front facet
			B:block(crop, v(0.3 * s, 0.55 * s, 0.1), R * CFrame.new(-0.3 * s, 0.1 * s, -0.83 * s), EM_GLOW, { mat = "Neon", name = "Glint" })
			return c
		end
		local fruitPts = {}
		-- chandelier under the arch (stems start in the intrados)
		for _, f in { { 125, 1.9, 1.0, 10 }, { 90, 3.4, 1.15, 0 }, { 57, 2.3, 1.0, -12 } } do
			local tr = rad(f[1])
			local top = v(math.cos(tr) * (AR - 0.9), AC + math.sin(tr) * (AR - 0.9), -0.2)
			table.insert(fruitPts, crystal(top, f[2], f[3], f[4]))
		end
		-- side shoots off the spirals, each carrying a crystal
		for _, f in {
			-- base point, shoot end offset, drop, scale, yaw
			{ v(-PX - 1.6, 10.2, -1.0), v(-1.7, 0.9, -1.6), 1.1, 0.95, 20 },
			{ v(-PX - 1.4, 6.6, 1.3), v(-1.6, 0.8, 1.6), 1.0, 0.85, -15 },
			{ v(PX + 1.6, 8.4, -1.1), v(1.7, 0.9, -1.7), 1.2, 0.95, -20 },
			{ v(PX + 1.4, 11.8, 1.2), v(1.6, 0.8, 1.6), 1.0, 0.85, 15 },
		} do
			local a, b = f[1], f[1] + f[2]
			B:bar(crop, a, b, 0.5, 0.5, VINE)
			thorn(a:Lerp(b, 0.5), v(0, 1, 0))
			leaf(b + v(0, 0.55, 0), 1.2, LF_LT)
			table.insert(fruitPts, crystal(b, f[3], f[4], f[5]))
		end
		-- dangling vine curtain strands under the arch
		for _, d in { { 145, 3.0, 0.6 }, { 35, 2.6, -0.5 } } do
			local tr = rad(d[1])
			local top = v(math.cos(tr) * (AR - 0.9), AC + math.sin(tr) * (AR - 0.9), d[3])
			local bot = top - v(0, d[2], 0)
			B:bar(crop, top, bot, 0.3, 0.3, VINE)
			B:block(crop, v(0.9, 0.2, 0.6), CFrame.new(bot + v(0, 0.9, 0)) * ang(0, 30, 25), LF_LT)
			B:block(crop, v(0.7, 0.2, 0.5), CFrame.new(bot + v(0, 0.1, 0)) * ang(0, -40, -25), LF_MID)
		end

		------------------------------------------------------------------
		-- VFX: emerald sparkles, a soft glow under the arch, one green light
		------------------------------------------------------------------
		local zone = B:block(crop, v(10, 10, 5), cf(0, 12.5, 0), EM, { tr = 1, name = "SparkleZone" })
		B:emitter(zone, "sparkle", { name = "EmeraldSparkle", color = { "#c8ffe0", EM_LT, "#fff2b0" }, rate = 5, size = { 0.12, 0.45, 0 }, life = { 1.2, 2.2 }, speed = { 0.2, 0.6 } })
		local glow = B:block(crop, v(2, 2, 1), cf(0, 15.0, 0), EM, { tr = 1, name = "ArchGlow" })
		B:emitter(glow, "glow", { name = "EmeraldGlow", color = { EM_LT, EM }, rate = 1.2, size = { 1.8, 2.8, 0.5 } })
		local leafZone = B:block(crop, v(8, 1, 4), cf(0, TOP + 1.0, 0), LF, { tr = 1, name = "LeafZone" })
		B:emitter(leafZone, "leaf", { name = "FallingLeaves", color = { LF_LT, LF_MID, ROSE }, rate = 0.8, size = { 0.4, 0.4, 0.25 }, life = { 3, 5 }, speed = { 0.3, 0.8 }, accel = { 0.3, -1.3, 0 }, dir = "Bottom" })
		B:light(glow, { name = "EmeraldLight", color = "#5dffa0", brightness = 1.2, range = 16 })
	end,
}
