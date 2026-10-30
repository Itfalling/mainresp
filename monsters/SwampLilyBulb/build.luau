--!nocheck
-- Lilypad Bulb (Misty Swamp plant #2, Uncommon).
-- A tall, gently zig-zagging swamp stalk rising out of a little murky pool
-- on a stepped dark-mud mound (moss pads, mossy stones, reeds, small lily
-- pads floating in the pool). Four big lily pads are stacked up the stalk
-- like a pagoda, each a stepped octagon with a dark split line, light veins
-- and a wine-red underside, getting smaller toward the top. Round, plump
-- pink bulb fruits sit on short stems on the pad rims, a few dangle under
-- the pads with moss strands, and a big closed pink bulb crowns the top.
-- Static prop: no motion.luau, no VFX.
return {
	DisplayName = "Lilypad Bulb",
	Rarity = "Uncommon",
	Element = "Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Misty Swamp)
		local MUD_DK, MUD_DK2, MUD, MUD_LT = "#3e3428", "#4a3e2e", "#5c4c36", "#6e5d42"
		local MOSS, MOSS_DK, MOSS_LT = "#4f8f3e", "#3b7034", "#6fae4c"
		local WATER, WATER_DK, WATER_LT = "#2d6f6a", "#24524f", "#62a9a0"
		local STONE, STONE_DK = "#6f7a72", "#565f59"
		local REED, REED_DK, REED_LT = "#4c9a52", "#367a42", "#7dbb5e"
		local STALK, STALK_DK, STALK_LT = "#3f8a55", "#2f6c44", "#5aa86a"
		local PAD, PAD_DK, PAD_LT, PAD_VEIN = "#4bb256", "#379446", "#6ccb62", "#9ade7a"
		local PAD_UNDER = "#7a3456"
		local BULB, BULB_DK, BULB_LT, BULB_HI = "#ff7cb6", "#ef5f9f", "#ffaad3", "#ffe2f0"
		local SEPAL, SEPAL_DK = "#3f9a4c", "#2c7a3a"
		local STRAND = "#5a7a3a"

		local seed = 1522
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end

		------------------------------------------------------------ mud mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.4, 2.1), rnd(1.1, 1.5)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.3)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.75, 4.4, MUD_DK, 11, { MUD_DK, MUD_DK2, MUD_DK }, 0.35)
		tier(0.75, 0.55, 3.1, MUD, 8, { MUD, MUD_LT, MUD }, 0.3)

		-- the pool: water sunk into the second tier, ringed by a mud lip
		local WY = 1.36
		B:block(soil, v(4.0, 0.14, 2.4), cf(0, WY, 0), WATER, S)
		B:block(soil, v(2.4, 0.14, 4.0), cf(0, WY + 0.004, 0), WATER, S)
		B:block(soil, v(3.4, 0.14, 3.4), cf(0, WY + 0.008, 0, 0, 45, 0), WATER, S)
		B:block(soil, v(1.0, 0.06, 0.24), cf(1.0, WY + 0.08, -1.2, 0, 20, 0), WATER_LT, S)
		B:block(soil, v(0.7, 0.06, 0.22), cf(-1.3, WY + 0.08, 0.9, 0, -30, 0), WATER_LT, S)
		B:block(soil, v(0.7, 0.06, 0.22), cf(-0.6, WY + 0.08, -1.5, 0, 60, 0), WATER_LT, S)
		for i = 0, 9 do
			local a = rad(i * 36 + rnd(-8, 8))
			local r = 2.35 + rnd(-0.1, 0.15)
			local c = CFrame.new(math.sin(a) * r, WY + 0.1, -math.cos(a) * r) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(rnd(1.3, 1.7), rnd(0.35, 0.5), 0.8), c, pick({ MUD_LT, MUD, MUD_LT }), S)
		end

		-- small floating lily pads in the pool (pink bud on one)
		local function smallPad(p, s, yaw)
			B:block(soil, v(1.0 * s, 0.1, 1.0 * s), CFrame.new(p) * ang(0, yaw, 0), PAD, S)
			B:block(soil, v(0.8 * s, 0.12, 0.8 * s), CFrame.new(p + v(0, 0.01, 0)) * ang(0, yaw + 45, 0), PAD_DK, S)
			B:block(soil, v(0.45 * s, 0.14, 0.45 * s), CFrame.new(p + v(0, 0.02, 0)) * ang(0, yaw + 20, 0), PAD_LT, S)
		end
		smallPad(v(-1.35, WY + 0.08, -0.9), 1.1, 15)
		smallPad(v(1.45, WY + 0.08, 0.6), 0.9, 40)
		smallPad(v(0.4, WY + 0.08, 1.6), 0.8, 70)

		-- moss pads draped over the lower tier edge
		for _, m in { { 30, 4.4, 1.9, MOSS }, { 110, 4.45, 1.6, MOSS_DK }, { 195, 4.4, 2.0, MOSS }, { 260, 4.4, 1.5, MOSS_LT }, { 320, 4.4, 1.6, MOSS_DK } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], 0.87, -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[3], 0.3, 1.2), c * ang(-14, 0, 0), m[4], S)
		end
		-- moss on the pool lip
		for _, m in { { 75, 2.4, 1.3, MOSS_LT }, { 220, 2.4, 1.4, MOSS } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], WY + 0.38, -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[3], 0.2, 0.9), c, m[4], S)
		end

		-- mossy stones
		local function stone(p, s, yaw)
			local c = CFrame.new(p) * ang(0, yaw, 0)
			B:block(soil, v(1.1 * s, 0.75 * s, 0.9 * s), c * CFrame.new(0, 0.37 * s, 0), STONE, S)
			B:block(soil, v(0.7 * s, 0.45 * s, 0.6 * s), c * CFrame.new(0.15 * s, 0.85 * s, 0) * ang(0, 20, 0), STONE_DK, S)
			B:block(soil, v(0.8 * s, 0.2 * s, 0.7 * s), c * CFrame.new(-0.1 * s, 0.82 * s, 0.05 * s) * ang(0, -10, 0), MOSS, S)
		end
		stone(v(-3.5, 0.72, -1.5), 0.95, 25)
		stone(v(3.2, 0.72, 2.2), 0.8, -35)

		-- reed tufts
		local function tuft(x, z, y)
			local base = CFrame.new(x, y, z) * ang(0, rnd(0, 90), 0)
			B:block(soil, v(0.24, 1.6, 0.24), base * CFrame.new(0, 0.75, 0), REED, S)
			B:block(soil, v(0.22, 1.25, 0.22), base * CFrame.new(0.2, 0.55, 0) * ang(0, 0, -18), REED_LT, S)
			B:block(soil, v(0.22, 1.0, 0.22), base * CFrame.new(-0.2, 0.45, 0.05) * ang(0, 0, 20), REED_DK, S)
			B:block(soil, v(0.3, 0.6, 0.3), base * CFrame.new(0, 1.7, 0), "#6a3f24", S) -- tiny cattail
		end
		tuft(3.8, -1.2, 0.7)
		tuft(-2.6, 3.2, 0.7)
		tuft(-0.6, -3.9, 0.7)

		------------------------------------------------------------ plant
		local crop = B:bone("Crop", "Root", v(0, 1.4, 0))

		-- stalk nodes (zig-zags gently upward); pads sit at the nodes
		local nodes = {
			v(0.0, 1.3, 0.0),
			v(0.25, 5.2, -0.15),
			v(-0.25, 8.6, 0.15),
			v(0.2, 11.4, -0.1),
			v(-0.05, 13.6, 0.05),
		}
		local widths = { 1.0, 0.9, 0.8, 0.7 }
		for i = 1, #nodes - 1 do
			local a, b = nodes[i], nodes[i + 1]
			local d = (b - a).Unit
			B:bar(crop, a - d * 0.1, b + d * 0.1, widths[i], widths[i], i % 2 == 1 and STALK or STALK_DK)
			-- node ring under each pad
			B:block(crop, v(widths[i] + 0.25, 0.35, widths[i] + 0.25), CFrame.new(b - v(0, 0.35, 0)) * ang(0, 45, 0), STALK_LT)
		end
		-- base collar where the stalk leaves the water
		B:block(crop, v(1.6, 0.4, 1.6), cf(0, WY + 0.2, 0, 0, 45, 0), STALK_DK)
		B:block(crop, v(1.25, 0.6, 1.25), cf(0, WY + 0.35, 0, 0, 0, 0), STALK)

		-- big stacked lily pad: stepped octagon, split line, veins, red underside
		local function pad(c, r, yaw, tiltX, tiltZ)
			local F = CFrame.new(c) * ang(tiltX, yaw, tiltZ)
			B:block(crop, v(2 * r * 0.92, 0.22, 2 * r * 0.92), F * CFrame.new(0, -0.18, 0) * ang(0, 22.5, 0), PAD_UNDER)
			-- four squares at 22.5deg steps: a round, scalloped two-tone rim
			local q = 2 * r * 0.96
			B:block(crop, v(q, 0.3, q), F, PAD)
			B:block(crop, v(q, 0.32, q), F * ang(0, 22.5, 0), PAD_DK)
			B:block(crop, v(q, 0.34, q), F * ang(0, 45, 0), PAD)
			B:block(crop, v(q, 0.36, q), F * ang(0, 67.5, 0), PAD_DK)
			B:block(crop, v(1.3 * r, 0.4, 1.3 * r), F * ang(0, 11, 0), PAD_LT)
			B:block(crop, v(0.75, 0.55, 0.75), F * CFrame.new(0, 0.1, 0) * ang(0, 45, 0), STALK_DK)
			-- dark split line from centre to the rim (the classic lily-pad notch)
			B:block(crop, v(0.32, 0.44, r * 1.0), F * CFrame.new(0, 0.0, -r * 0.5), PAD_UNDER)
			-- light veins
			for k = 1, 3 do
				local va = 90 * k
				B:block(crop, v(0.18, 0.42, r * 0.8), F * ang(0, va, 0) * CFrame.new(0, 0.0, -r * 0.5), PAD_VEIN)
			end
			return F
		end

		-- plump round pink bulb: stepped cross + 45 core, darker base, sepals, tip
		local bulbTips = {}
		local function bulb(p, s, yaw, hanging)
			local F = CFrame.new(p) * ang(0, yaw, 0) * (hanging and ang(180, 0, 0) or CFrame.new())
			B:block(crop, v(1.25 * s, 1.0 * s, 1.25 * s), F, BULB)
			B:block(crop, v(1.0 * s, 1.35 * s, 1.0 * s), F * ang(0, 45, 0), BULB_DK)
			B:block(crop, v(1.45 * s, 0.6 * s, 0.85 * s), F * CFrame.new(0, -0.05 * s, 0), BULB_LT)
			B:block(crop, v(0.85 * s, 0.6 * s, 1.45 * s), F * CFrame.new(0, -0.05 * s, 0), BULB)
			B:block(crop, v(0.55 * s, 0.5 * s, 0.55 * s), F * CFrame.new(0, 0.8 * s, 0) * ang(0, 45, 0), BULB_LT)
			B:block(crop, v(0.24 * s, 0.35 * s, 0.24 * s), F * CFrame.new(0, 1.15 * s, 0), BULB_HI)
			B:block(crop, v(0.8 * s, 0.4 * s, 0.8 * s), F * CFrame.new(0, -0.62 * s, 0) * ang(0, 45, 0), BULB_DK)
			-- sepals cupping the bottom
			B:block(crop, v(0.95 * s, 0.3 * s, 0.95 * s), F * CFrame.new(0, -0.82 * s, 0) * ang(0, 22.5, 0), SEPAL)
			-- glossy highlight
			B:block(crop, v(0.22 * s, 0.32 * s, 0.1), F * CFrame.new(-0.3 * s, 0.2 * s, -0.63 * s), BULB_HI)
			table.insert(bulbTips, F)
		end
		-- bulb on a short stem rising from a pad (pad frame F, radial angle a, radius rr)
		local function padBulb(F, a, rr, s, stemH)
			local base = (F * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.15, -rr)).Position
			local top = base + v(0, stemH, 0)
			B:bar(crop, base, top + v(0, 0.1, 0), 0.28, 0.28, STALK_DK)
			bulb(top + v(0, 0.6 * s + 0.2, 0), s, rnd(0, 45), false)
		end
		-- bulb dangling under a pad on a short stem, with a moss strand beside it
		local function hangBulb(F, a, rr, s, drop)
			local top = (F * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, -0.25, -rr)).Position
			local bot = top - v(0, drop, 0)
			B:bar(crop, top, bot, 0.24, 0.24, STALK_DK)
			bulb(bot - v(0, 0.6 * s, 0), s, rnd(0, 45), true)
		end
		local function strand(F, a, rr, len)
			local top = (F * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, -0.25, -rr)).Position
			B:bar(crop, top, top - v(0, len, 0), 0.22, 0.22, STRAND)
			B:block(crop, v(0.35, 0.35, 0.35), CFrame.new(top - v(0, len, 0)) * ang(0, 45, 0), MOSS_DK)
		end

		local p1 = pad(nodes[2] + v(0, 0.05, 0), 3.0, 10, 3, -4)
		local p2 = pad(nodes[3] + v(0, 0.05, 0), 2.5, 35, -4, 3)
		local p3 = pad(nodes[4] + v(0, 0.05, 0), 2.0, 60, 4, 3)
		local p4 = pad(nodes[5] + v(0, 0.0, 0), 1.45, 80, -2, -3)

		-- bulbs on the pad rims
		padBulb(p1, 70, 2.1, 0.95, 0.7)
		padBulb(p1, 200, 2.2, 0.9, 0.5)
		padBulb(p1, 300, 2.0, 0.8, 0.4)
		padBulb(p2, 140, 1.7, 0.85, 0.6)
		padBulb(p2, 255, 1.75, 0.8, 0.4)
		padBulb(p3, 0, 1.35, 0.75, 0.4)
		padBulb(p3, 190, 1.35, 0.7, 0.35)
		-- dangling bulbs + moss strands under the pads
		hangBulb(p1, 20, 2.3, 0.8, 0.9)
		hangBulb(p1, 150, 2.4, 0.75, 0.7)
		hangBulb(p2, 300, 1.9, 0.75, 0.8)
		hangBulb(p3, 110, 1.5, 0.65, 0.6)
		strand(p1, 250, 2.6, 1.6)
		strand(p2, 60, 2.2, 1.4)
		strand(p2, 190, 2.1, 1.1)
		strand(p3, 260, 1.7, 1.2)

		-- crown: a big closed pink bulb on the top pad, with a pointed stepped tip
		local top = nodes[5] + v(0, 0.35, 0)
		B:block(crop, v(1.0, 0.5, 1.0), CFrame.new(top) * ang(0, 20, 0), SEPAL_DK)
		bulb(top + v(0, 1.1, 0), 1.35, 15, false)
		B:block(crop, v(1.4, 0.4, 0.5), CFrame.new(top + v(0, 0.55, 0)) * ang(0, 15, 25), SEPAL)
		B:block(crop, v(0.5, 0.4, 1.4), CFrame.new(top + v(0, 0.55, 0)) * ang(-25, 15, 0), SEPAL)
		-- outer petals just starting to peel open around the crown bulb
		for k = 0, 3 do
			local a = 15 + 45 + k * 90
			local R = CFrame.new(top + v(0, 1.0, 0)) * ang(0, a, 0)
			B:block(crop, v(0.95, 1.5, 0.3), R * CFrame.new(0, 0.1, -1.0) * ang(-22, 0, 0), k % 2 == 0 and BULB_LT or BULB)
		end

		-- a little swamp frog sitting on the lowest pad (front-right)
		local FR = (p1 * CFrame.Angles(0, rad(-40), 0) * CFrame.new(0, 0.2, -1.75)).Position
		local Fq = CFrame.new(FR) * ang(0, -32, 0)
		local FROG, FROG_DK, FROG_LT, EYE = "#a6dc3c", "#7cb52c", "#f2f0b0", "#1d1f1a"
		B:block(crop, v(1.1, 0.7, 1.2), Fq * CFrame.new(0, 0.35, 0), FROG)
		B:block(crop, v(0.8, 0.3, 0.9), Fq * CFrame.new(0, 0.12, -0.15), FROG_LT)
		B:block(crop, v(1.35, 0.35, 0.6), Fq * CFrame.new(0, 0.18, 0.4), FROG_DK)
		for _, sx in { -1, 1 } do
			B:block(crop, v(0.38, 0.38, 0.38), Fq * CFrame.new(sx * 0.32, 0.82, -0.32), FROG)
			B:block(crop, v(0.2, 0.22, 0.1), Fq * CFrame.new(sx * 0.32, 0.86, -0.53), EYE)
		end
	end,
}
