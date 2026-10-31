--!nocheck
-- Fallen Mossy Log (Misty Swamp scenery, big copy-paste filler).
-- A huge fallen swamp tree lying across a murky puddle: a chunky rounded trunk
-- (three crossed bars per section) with bark ridges, a thick stepped moss
-- blanket along the top with moss hanging down the sides, a broken hollow end
-- with a pale cut rim and splinters, and an upturned root plate of mud and
-- roots at the other end. Teal/violet shelf fungi and little toadstools grow
-- on it; lily pads, reeds and stones around the puddle. Two tiny neon gill
-- strips are the only glow. Filler: anchored, weld-free, no scripts.
return {
	DisplayName = "Fallen Mossy Log",
	Rarity = "Scenery",
	Filler = true,
	Element = "Misty Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Misty Swamp crops / decorations)
		local MUD_XD, MUD_DK, MUD, MUD_LT = "#3b2a1e", "#4c3626", "#5e4430", "#74563c"
		local MOSS_DK, MOSS, MOSS_LT = "#3e6b2e", "#558a3a", "#76ab4a"
		local WATER_DK, WATER, WATER_LT = "#276b63", "#35958a", "#86dccb"
		local PAD_DK, PAD, PAD_LT = "#3b7a3a", "#4f9a46", "#77bf5c"
		local STONE_DK, STONE, STONE_LT = "#56605e", "#6f7a77", "#8c9893"
		local REED, REED_DK, CATTAIL = "#7a8a3e", "#5d6e30", "#4a2f1e"
		local BARK_XD, BARK_DK, BARK, BARK_LT = "#2c221c", "#3d3028", "#504034", "#66523f"
		local CUT, CUT_DK = "#b8915f", "#8f6c45"
		local HOLLOW = "#1c1612"
		local STEM = "#e0d3f5"
		local TEAL_DK, TEAL, TEAL_LT = "#135c5b", "#1d8781", "#56cfc2"
		local VIO_DK, VIO, VIO_LT = "#4a2789", "#6a3cbd", "#a982ee"
		local GLOW = "#7ff7ff"
		local NEON = { mat = "Neon" }

		local seed = 4213
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function round(c, r, h, col, c2, c3)
			B:block(R, v(2 * r, h, 1.1 * r), c, col)
			B:block(R, v(1.1 * r, h - 0.02, 2 * r), c, c2 or col)
			B:block(R, v(1.72 * r, h - 0.04, 1.72 * r), c, c3 or col)
		end
		local function oct(c, s, h, col, col2)
			B:block(R, v(s, h, s), c, col)
			B:block(R, v(s * 0.82, h - 0.04, s * 0.82), c * ang(0, 45, 0), col2 or col)
		end

		------------------------------------------------------------ footing (low + flat) + puddle
		round(cf(0, 0.06, 0, 0, 0, 0), 6.6, 0.12, MUD_DK)
		B:block(R, v(17, 0.12, 6.4), cf(0, 0.07, 0, 0, 4, 0), MUD_DK)
		round(cf(-0.5, 0.12, 0.3, 0, 20, 0), 4.6, 0.12, MUD)
		-- puddle under the middle of the log
		round(cf(-0.6, 0.15, -0.4, 0, 10, 0), 4.0, 0.14, WATER_DK)
		round(cf(-0.6, 0.19, -0.4, 0, 30, 0), 3.3, 0.14, WATER)
		B:block(R, v(1.6, 0.1, 0.35), cf(-2.2, 0.28, -2.6, 0, 15, 0), WATER_LT)
		B:block(R, v(1.0, 0.1, 0.3), cf(1.4, 0.28, 2.2, 0, -10, 0), WATER_LT)
		-- lily pads
		local function lily(x, z, s, ry)
			B:block(R, v(1.6 * s, 0.14, 1.6 * s), cf(x, 0.3, z, 0, ry, 0), PAD)
			B:block(R, v(1.2 * s, 0.16, 1.2 * s), cf(x, 0.31, z, 0, ry + 45, 0), PAD_DK)
			B:block(R, v(0.7 * s, 0.18, 0.7 * s), cf(x + 0.15, 0.33, z - 0.1, 0, ry + 20, 0), PAD_LT)
		end
		lily(-3.0, -3.0, 1.0, 20)
		lily(1.8, -3.2, 0.75, -30)
		-- moss mats on the banks
		for _, m in { { -6.5, -2.6, 2.6, 1.6, 15 }, { 5.2, 2.8, 2.4, 1.8, -20 }, { -5.6, 2.8, 2.0, 1.4, 35 }, { 3.8, -3.4, 2.2, 1.4, -5 } } do
			B:block(R, v(m[3], 0.16, m[4]), cf(m[1], 0.16, m[2], 0, m[5], 0), MOSS)
			B:block(R, v(m[3] * 0.55, 0.18, m[4] * 0.55), cf(m[1] + 0.25, 0.19, m[2] - 0.1, 0, m[5] + 15, 0), MOSS_LT)
		end
		local function stone(x, z, s, ry)
			local c = cf(x, 0.25 * s, z, 0, ry, 0)
			B:block(R, v(1.4 * s, 0.5 * s, 1.1 * s), c, STONE)
			B:block(R, v(0.9 * s, 0.3 * s, 0.7 * s), c * CFrame.new(0.15 * s, 0.32 * s, 0) * ang(0, 20, 0), STONE_LT)
			B:block(R, v(1.46 * s, 0.16 * s, 1.16 * s), c * CFrame.new(0, -0.18 * s, 0), STONE_DK)
		end
		stone(-7.6, -1.6, 1.0, 25)
		stone(3.2, 3.6, 0.8, -30)
		local function reed(x, z, h, tz, tx, cat)
			local base = v(x, 0.15, z)
			local tip = base + v(-math.sin(rad(tz)) * h, h, math.sin(rad(tx)) * h)
			B:bar(R, base, tip, 0.26, 0.26, (h > 2.6) and REED or REED_DK)
			if cat then
				local d = (tip - base).Unit
				B:bar(R, tip - d * 0.2, tip + d * 0.9, 0.46, 0.46, CATTAIL)
			end
		end
		reed(2.9, -3.8, 3.4, -8, -10, true)
		reed(3.4, -3.5, 2.4, -18, -4, false)
		reed(-4.2, 3.4, 3.0, 8, 10, true)
		reed(-3.7, 3.7, 2.0, -6, 16, false)

		------------------------------------------------------------ the trunk
		local A = v(-8.6, 1.9, 0.7)
		local M = v(-1.2, 2.3, 0.2)
		local C = v(6.2, 2.7, -0.5)
		local RAD = 1.95
		local segs = { { A, M }, { M, C } }
		local frames = {}
		for i, s in segs do
			local a, b = s[1], s[2]
			local F, len = P.aim(a, b)
			frames[i] = { F, len }
			local ext = 0.15
			local L = len + ext * 2
			local col1, col2, col3 = BARK, BARK_DK, BARK
			if i == 2 then col1, col2, col3 = BARK_DK, BARK, BARK_DK end
			B:block(R, v(2 * RAD, 1.1 * RAD, L), F, col1)
			B:block(R, v(1.1 * RAD, 2 * RAD - 0.04, L - 0.04), F, col2)
			B:block(R, v(1.72 * RAD, 1.72 * RAD - 0.06, L - 0.08), F, col3)
		end
		-- point on the log surface: seg i, distance along (0..len), angle from top (deg, + toward local +X), radial offset
		local function onLog(i, d, th, out)
			local F, len = frames[i][1], frames[i][2]
			local t = rad(th)
			return F * CFrame.new(math.sin(t) * (RAD + out), math.cos(t) * (RAD + out), len / 2 - d) * CFrame.Angles(0, 0, -t)
		end
		-- bark ridges along the sides
		for _, r in { { 1, 1.0, 4.2, 62 }, { 1, 4.0, 3.0, -58 }, { 2, 0.8, 3.6, -62 }, { 2, 3.8, 2.6, 58 }, { 1, 2.5, 3.4, 118 }, { 2, 2.2, 3.0, -120 } } do
			local c = onLog(r[1], r[2] + r[3] / 2, r[4], -0.25)
			B:block(R, v(0.5, 0.5, r[3]), c, BARK_LT)
		end
		-- lighter bark plates on the sides
		for _, r in { { 1, 2.0, 1.8, -90, 1.4 }, { 1, 5.6, 1.4, 90, 1.2 }, { 2, 2.4, 1.6, 90, 1.5 }, { 2, 5.0, 1.8, -90, 1.2 } } do
			local c = onLog(r[1], r[2], r[4], -0.05)
			B:block(R, v(r[5], 0.3, r[3]), c, BARK_DK)
			B:block(R, v(r[5] * 0.6, 0.32, r[3] * 0.6), c * CFrame.new(0.1, 0.02, 0.1), BARK_LT)
		end
		-- peeled bark: pale wood showing through on the front side
		for _, r in { { 1, 6.0, 2.2, -75, 1.5 }, { 2, 1.4, 1.8, -80, 1.3 }, { 2, 5.4, 2.4, -70, 1.4 } } do
			local c = onLog(r[1], r[2], r[4], 0.0)
			B:block(R, v(r[5], 0.16, r[3]), c, CUT_DK)
			B:block(R, v(r[5] * 0.7, 0.2, r[3] * 0.75), c * CFrame.new(0.05, 0.02, -0.1), CUT)
		end
		-- knot
		local kn = onLog(2, 2.0, 90, -0.05)
		B:block(R, v(1.2, 0.3, 1.2), kn, BARK_LT)
		B:block(R, v(0.7, 0.32, 0.7), kn, HOLLOW)

		-- moss blanket along the top (stepped: dark base, main, light tufts)
		for _, m in { { 1, 1.2, 3.6, 0 }, { 1, 4.6, 3.2, 8 }, { 2, 0.4, 3.0, -6 }, { 2, 3.8, 3.4, 4 } } do
			local c = onLog(m[1], m[2] + m[3] / 2, m[4], 0.05)
			B:block(R, v(2.9, 0.4, m[3]), c, MOSS_DK)
			B:block(R, v(2.1, 0.45, m[3] * 0.7), c * CFrame.new(0.15, 0.2, 0.2), MOSS)
			B:block(R, v(1.1, 0.4, m[3] * 0.35), c * CFrame.new(-0.2, 0.42, -0.3), MOSS_LT)
		end
		-- moss hanging down the sides
		for _, h in { { 1, 2.0, 1 }, { 1, 5.2, -1 }, { 2, 1.2, 1 }, { 2, 4.6, -1 }, { 1, 6.6, 1 }, { 2, 6.4, 1 } } do
			local side = h[3]
			local c = onLog(h[1], h[2], 90 * side, 0.12)
			local L = rnd(1.4, 2.2)
			-- c's local Y points outward; local X points down (side>0) / up (side<0)
			B:block(R, v(L, 0.3, 0.9), c * CFrame.new(side * (L / 2 - 0.9), 0, 0), MOSS)
			B:block(R, v(L * 0.7, 0.32, 0.6), c * CFrame.new(side * (L * 0.35 - 0.9), 0, 0.75), MOSS_DK)
			B:block(R, v(L * 0.5, 0.34, 0.5), c * CFrame.new(side * (L + L * 0.25 - 1.1), 0, -0.1), MOSS_LT)
		end

		------------------------------------------------------------ broken hollow end (at A)
		local Fe = frames[1][1] * CFrame.new(0, 0, frames[1][2] / 2 + 0.15)
		-- pale cut rim (four rim bars) + dark hollow core
		round(Fe * CFrame.Angles(rad(90), 0, 0), RAD * 0.98, 0.3, CUT, CUT_DK, CUT)
		round(Fe * CFrame.new(0, 0, 0.05) * CFrame.Angles(rad(90), 0, 0), RAD * 0.62, 0.32, HOLLOW)
		-- ragged splinters around the rim
		for _, s in { { 20, 1.1, -10 }, { 75, 0.8, 8 }, { 150, 1.0, -6 }, { 230, 0.7, 10 }, { 300, 1.2, -8 } } do
			local t = rad(s[1])
			local p = Fe * CFrame.new(math.sin(t) * RAD * 0.8, math.cos(t) * RAD * 0.8, s[2] / 2)
			B:block(R, v(0.55, 0.55, s[2]), p * CFrame.Angles(rad(s[3]), rad(s[3]), 0), (s[1] % 2 == 0) and CUT or BARK_LT)
		end

		------------------------------------------------------------ upturned root plate (at C)
		local dirX = (C - M).Unit
		local plateC = C + dirX * 1.0 + v(0, 0.75, 0)
		local Fp = CFrame.lookAt(plateC, plateC + dirX) -- -Z along log axis
		round(Fp * CFrame.Angles(rad(90), 0, 0), 3.4, 1.1, MUD_DK, MUD_XD, MUD_DK)
		round(Fp * CFrame.new(0, 0.1, -0.3) * CFrame.Angles(rad(90), 0, 0), 2.6, 1.0, MUD, MUD_DK, MUD)
		round(Fp * CFrame.new(-0.3, 0.6, -0.65) * CFrame.Angles(rad(90), rad(20), 0), 1.4, 0.6, MUD_LT)
		-- moss tufts + grass on the plate top
		B:block(R, v(2.4, 0.5, 1.3), Fp * CFrame.new(0.3, 3.15, 0), MOSS)
		B:block(R, v(1.2, 0.5, 0.9), Fp * CFrame.new(-0.6, 3.4, 0.1), MOSS_LT)
		-- stones caught in the root plate
		B:block(R, v(0.9, 0.7, 0.5), Fp * CFrame.new(1.2, -0.6, -0.95) * ang(0, 0, 20), STONE)
		B:block(R, v(0.6, 0.5, 0.5), Fp * CFrame.new(-1.4, 1.3, -0.9) * ang(0, 0, -15), STONE_LT)
		-- roots on the outer face, radiating out past the rim (lower ones reach the ground)
		for k, a in { 20, 70, 115, 160, 200, 245, 290, 335 } do
			local t = rad(a)
			local inner = (Fp * CFrame.new(math.sin(t) * 0.9, math.cos(t) * 0.9, -0.85)).Position
			local mid = (Fp * CFrame.new(math.sin(t) * 3.1, math.cos(t) * 3.1, -0.95)).Position
			local outer = (Fp * CFrame.new(math.sin(t) * 4.3, math.cos(t) * 4.3, -1.5)).Position
			if a > 100 and a < 260 then
				outer = Vector3.new(outer.X, 0.3, outer.Z) -- droop to the ground
			end
			if outer.Y < 0.3 then outer = Vector3.new(outer.X, 0.3, outer.Z) end
			B:bar(R, inner, mid, 0.75, 0.6, (k % 2 == 0) and BARK_DK or BARK)
			B:bar(R, mid - (mid - inner).Unit * 0.25, outer, 0.5, 0.45, (k % 2 == 0) and BARK or BARK_LT)
		end
		------------------------------------------------------------ broken branch sticking up
		local bb = onLog(2, 1.6, -25, -0.3).Position
		local bt = bb + v(-1.0, 4.2, -1.4)
		B:bar(R, bb, bt, 1.0, 1.0, BARK)
		B:bar(R, bb:Lerp(bt, 0.6), bb:Lerp(bt, 0.6) + v(1.6, 1.2, -0.2), 0.5, 0.5, BARK_DK)
		B:block(R, v(1.04, 0.3, 1.04), CFrame.new(bt) * CFrame.Angles(rad(-15), 0, rad(14)), CUT)
		B:block(R, v(1.2, 0.35, 1.0), CFrame.new(bb:Lerp(bt, 0.3) + v(0.1, 0, -0.1)) * ang(0, 30, 0), MOSS)

		------------------------------------------------------------ fungi
		local function shelf(i, d, th, k, col, colLt, glow)
			local c = onLog(i, d, th, 0.0)
			-- local Y = outward; local X runs down the side for th>0, up for th<0
			local dn = (th < 0) and -1 or 1
			B:block(R, v(0.4 * k, 1.3 * k, 1.8 * k), c * CFrame.new(0, 0.55 * k, 0), col)
			B:block(R, v(0.36 * k, 0.9 * k, 1.2 * k), c * CFrame.new(-dn * 0.36 * k, 0.45 * k, 0.1 * k), colLt)
			if glow then
				B:block(R, v(0.1, 0.9 * k, 1.3 * k), c * CFrame.new(dn * 0.22 * k, 0.55 * k, 0), GLOW, NEON)
			else
				B:block(R, v(0.1, 1.0 * k, 1.4 * k), c * CFrame.new(dn * 0.22 * k, 0.5 * k, 0), colLt)
			end
		end
		-- shelves on the -X (log front) side: th = -90 ; the front of the log faces -Z
		shelf(1, 3.0, -100, 1.2, TEAL, TEAL_LT, true)
		shelf(1, 3.9, -120, 0.8, TEAL_DK, TEAL, false)
		shelf(2, 3.2, -95, 1.0, VIO, VIO_LT, true)
		shelf(2, 5.6, 100, 1.1, TEAL, TEAL_LT, false)
		shelf(1, 6.2, 110, 0.9, VIO, VIO_LT, false)
		local function toad(p, k, capCol, capLt)
			B:block(R, v(0.35 * k, 0.9 * k, 0.35 * k), CFrame.new(p + v(0, 0.45 * k, 0)), STEM)
			oct(CFrame.new(p + v(0, 0.95 * k, 0)) * ang(0, 20, 0), 1.1 * k, 0.35 * k, capCol)
			B:block(R, v(0.6 * k, 0.25 * k, 0.6 * k), CFrame.new(p + v(0, 1.2 * k, 0)) * ang(0, 40, 0), capLt)
		end
		toad(onLog(1, 3.0, 10, 0.4).Position, 1.0, VIO, VIO_LT)
		toad(onLog(1, 3.6, -15, 0.3).Position, 0.7, TEAL, TEAL_LT)
		toad(onLog(2, 5.6, 5, 0.35).Position, 0.9, TEAL, TEAL_LT)
		toad(v(-6.8, 0.15, -2.4), 0.8, VIO, VIO_LT)
	end,
}
