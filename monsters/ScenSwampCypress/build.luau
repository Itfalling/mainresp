--!nocheck
-- Swamp Cypress (Misty Swamp scenery, big copy-paste filler).
-- A tall bald cypress: a flared, buttressed trunk with bark ridges, knobby
-- cypress knees poking out of the mud around it, crooked branches holding
-- flat layered foliage pads (dark/main/light tiers) and a stepped crown, with
-- grey-green Spanish moss hanging off every pad. Low flat footing of mud,
-- moss mats, a little puddle, stones and reeds. Two tiny neon glowcap dots.
-- Filler: anchored, weld-free, no scripts.
return {
	DisplayName = "Swamp Cypress",
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
		local STONE_DK, STONE, STONE_LT = "#56605e", "#6f7a77", "#8c9893"
		local REED, REED_DK, CATTAIL = "#7a8a3e", "#5d6e30", "#4a2f1e"
		local BARK_XD, BARK_DK, BARK, BARK_LT = "#2c221c", "#3d3028", "#504034", "#66523f"
		local LF_XD, LF_DK, LF, LF_MID, LF_LT, LF_TIP = "#2f5a34", "#3d7040", "#4f8a48", "#64a052", "#82b85e", "#a6cf72"
		local HANG_DK, HANG, HANG_LT = "#6f8468", "#8ea283", "#b0c2a0"
		local STEM = "#e0d3f5"
		local VIO, VIO_LT = "#6a3cbd", "#a982ee"
		local TEAL, TEAL_LT = "#1d8781", "#56cfc2"
		local GLOW = "#7ff7ff"

		local seed = 4191
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function dirOf(a)
			return v(math.sin(rad(a)), 0, -math.cos(rad(a)))
		end
		local function round(c, r, h, col)
			B:block(R, v(2 * r, h, 1.1 * r), c, col)
			B:block(R, v(1.1 * r, h - 0.02, 2 * r), c, col)
			B:block(R, v(1.72 * r, h - 0.04, 1.72 * r), c, col)
		end
		local function oct(c, s, h, col, col2)
			B:block(R, v(s, h, s), c, col)
			B:block(R, v(s * 0.82, h - 0.04, s * 0.82), c * ang(0, 45, 0), col2 or col)
		end

		------------------------------------------------------------ footing (low + flat)
		round(cf(0, 0.06, 0, 0, 10, 0), 5.6, 0.12, MUD_DK)
		round(cf(0.3, 0.12, 0.2, 0, 35, 0), 4.2, 0.12, MUD)
		for _, m in { { -3.6, -2.4, 2.6, 1.6, 20 }, { 3.4, 2.6, 2.4, 1.8, -25 }, { 2.8, -3.4, 1.8, 1.4, 40 }, { -2.8, 3.6, 2.0, 1.5, -10 } } do
			B:block(R, v(m[3], 0.16, m[4]), cf(m[1], 0.17, m[2], 0, m[5], 0), MOSS)
			B:block(R, v(m[3] * 0.55, 0.18, m[4] * 0.55), cf(m[1] + 0.25, 0.2, m[2] - 0.1, 0, m[5] + 15, 0), MOSS_LT)
		end
		-- little puddle at the front-right
		round(cf(3.6, 0.1, -1.0, 0, 20, 0), 1.7, 0.14, WATER_DK)
		round(cf(3.6, 0.13, -1.0, 0, 5, 0), 1.35, 0.14, WATER)
		B:block(R, v(0.9, 0.1, 0.3), cf(3.2, 0.21, -1.4, 0, 20, 0), WATER_LT)
		local function stone(x, z, s, ry)
			local c = cf(x, 0.25 * s, z, 0, ry, 0)
			B:block(R, v(1.4 * s, 0.5 * s, 1.1 * s), c, STONE)
			B:block(R, v(0.9 * s, 0.3 * s, 0.7 * s), c * CFrame.new(0.15 * s, 0.32 * s, 0) * ang(0, 20, 0), STONE_LT)
			B:block(R, v(1.46 * s, 0.16 * s, 1.16 * s), c * CFrame.new(0, -0.18 * s, 0), STONE_DK)
		end
		stone(-4.6, 0.4, 1.0, 30)
		stone(1.2, 4.8, 0.8, -20)
		local function reed(x, z, h, tz, tx, cat)
			local base = v(x, 0.15, z)
			local tip = base + v(-math.sin(rad(tz)) * h, h, math.sin(rad(tx)) * h)
			B:bar(R, base, tip, 0.24, 0.24, (h > 2.6) and REED or REED_DK)
			if cat then
				local d = (tip - base).Unit
				B:bar(R, tip - d * 0.2, tip + d * 0.9, 0.44, 0.44, CATTAIL)
			end
		end
		reed(4.9, -0.2, 3.4, -8, 6, true)
		reed(5.2, -0.8, 2.4, -16, -6, false)
		reed(4.6, -1.9, 2.8, -4, -12, true)
		reed(-3.4, -4.0, 2.2, 10, -10, false)
		reed(-3.0, -4.3, 3.0, 4, -4, true)

		------------------------------------------------------------ trunk
		-- flared base (stepped octagons)
		oct(cf(0, 0.6, 0, 0, 10, 0), 4.4, 1.2, BARK_DK, BARK)
		oct(cf(0.05, 1.9, 0, 0, 30, 0), 3.5, 1.5, BARK, BARK_DK)
		-- buttress flanges radiating out to the ground
		for i, a in { 15, 75, 140, 200, 260, 320 } do
			local d = dirOf(a)
			local top = d * 1.3 + v(0, 3.6, 0)
			local foot = d * (3.2 + rnd(-0.2, 0.4)) + v(0, 0.35, 0)
			B:bar(R, top, foot, 1.0, 1.3, (i % 2 == 0) and BARK or BARK_DK, { up = v(0, 1, 0) })
			B:bar(R, top + v(0, 0.35, 0) + d * 0.15, foot + v(0, 0.45, 0) - d * 0.6, 0.5, 0.5, BARK_LT)
			B:block(R, v(1.3, 0.6, 1.2), CFrame.new(foot + v(0, -0.05, 0)) * ang(0, -a, 0), BARK_XD)
			if i % 2 == 1 then
				local m = top:Lerp(foot, 0.55)
				B:block(R, v(1.2, 0.35, 1.3), CFrame.new(m + v(0, 0.75, 0)) * ang(0, -a, 0) * ang(-35, 0, 0), MOSS)
			end
		end
		-- leaning trunk column (two crossed bars per segment)
		local path = { v(0, 2.4, 0), v(0.25, 6.5, 0.15), v(0.75, 10.5, -0.1), v(0.55, 14.0, 0.25), v(0.15, 17.0, 0.1) }
		local widths = { 2.7, 2.3, 1.9, 1.5 }
		for i = 1, #path - 1 do
			local a, b = path[i], path[i + 1]
			local w = widths[i]
			B:bar(R, a - v(0, 0.2, 0), b + v(0, 0.2, 0), w, w, (i % 2 == 1) and BARK or BARK_DK)
			B:bar(R, a - v(0, 0.15, 0), b + v(0, 0.15, 0), w * 0.86, w * 0.86, (i % 2 == 1) and BARK_DK or BARK, { up = v(1, 0, 1).Unit })
		end
		-- bark ridges / knots
		for _, r in { { 1, 0.3, 30, BARK_LT }, { 1, 0.6, 200, BARK_LT }, { 2, 0.4, 120, BARK_LT }, { 2, 0.5, 300, BARK_XD }, { 3, 0.5, 60, BARK_LT } } do
			local a, b = path[r[1]], path[r[1] + 1]
			local p = a:Lerp(b, r[2])
			local d = dirOf(r[3])
			local w = widths[r[1]]
			B:bar(R, p + d * (w * 0.5) - v(0, 1.0, 0), p + d * (w * 0.5) + v(0, 1.0, 0), 0.45, 0.3, r[4], { up = d })
		end
		-- moss creeping up the trunk
		B:block(R, v(2.0, 0.9, 0.4), CFrame.new(path[2] + dirOf(160) * 1.25 + v(0, -0.6, 0)) * ang(0, -160, 0), MOSS_DK)
		B:block(R, v(1.2, 0.6, 0.42), CFrame.new(path[2] + dirOf(160) * 1.25 + v(0.2, 0.1, 0)) * ang(0, -160, 0), MOSS)
		-- knot hole
		local kh = path[2]:Lerp(path[3], 0.35) + dirOf(-20) * 1.1
		B:block(R, v(0.9, 1.1, 0.3), CFrame.new(kh) * ang(0, 20, 0), BARK_LT)
		B:block(R, v(0.55, 0.7, 0.3), CFrame.new(kh + dirOf(-20) * 0.08) * ang(0, 20, 0), MUD_XD)

		------------------------------------------------------------ knees
		local function knee(a, r, h)
			local d = dirOf(a)
			local p = d * r
			B:block(R, v(1.4, 0.5, 1.4), CFrame.new(p + v(0, 0.25, 0)) * ang(0, a + 20, 0), BARK_XD)
			B:block(R, v(1.05, h, 1.05), CFrame.new(p + v(0, h / 2, 0)) * ang(0, a, 0), BARK)
			B:block(R, v(0.75, h * 0.5, 0.75), CFrame.new(p + v(0.05, h + h * 0.22, 0)) * ang(0, a + 30, 0), BARK_LT)
			B:block(R, v(0.5, 0.3, 0.5), CFrame.new(p + v(0.05, h * 1.5 + 0.12, 0)) * ang(0, a + 10, 0), MOSS_LT)
		end
		knee(35, 4.1, 1.5)
		knee(100, 4.6, 1.0)
		knee(170, 3.9, 1.8)
		knee(230, 4.5, 1.2)
		knee(290, 4.0, 1.6)

		------------------------------------------------------------ branches + foliage pads
		local hangs = {}
		local function pad(c, s, tilt)
			c = c * ang(tilt or 0, rnd(0, 40), 0)
			oct(c, s, 1.1, LF_DK, LF_XD)
			oct(c * CFrame.new(0.1, 0.85, -0.05) * ang(0, 20, 0), s * 0.8, 1.0, LF, LF_MID)
			B:block(R, v(s * 0.55, 0.8, s * 0.5), c * CFrame.new(-0.2, 1.6, 0.1) * ang(0, 10, 0), LF_LT)
			B:block(R, v(s * 0.3, 0.4, s * 0.28), c * CFrame.new(0.35, 2.1, -0.1) * ang(0, 35, 0), LF_TIP)
			-- side tufts break up the round outline
			B:block(R, v(s * 0.35, 0.9, s * 0.3), c * CFrame.new(s * 0.45, 0.35, s * 0.1) * ang(0, 25, 0), LF_MID)
			B:block(R, v(s * 0.3, 0.8, s * 0.35), c * CFrame.new(-s * 0.2, 0.5, -s * 0.45) * ang(0, -15, 0), LF_LT)
			table.insert(hangs, { c, s })
		end
		-- branch: start on trunk, end where the pad sits
		local function branch(t, a, len, rise, s)
			local pi = math.clamp(math.floor(t), 1, #path - 1)
			local start = path[pi]:Lerp(path[pi + 1], t - pi)
			local d = dirOf(a)
			local mid = start + d * (len * 0.55) + v(0, rise * 0.4, 0)
			local tip = start + d * len + v(0, rise, 0)
			B:bar(R, start, mid, 0.8, 0.8, BARK_DK)
			B:bar(R, mid - d * 0.2, tip, 0.6, 0.6, BARK)
			pad(CFrame.new(tip + v(0, 0.2, 0)), s)
		end
		branch(2.75, 70, 4.8, 1.6, 5.0)
		branch(3.1, 200, 4.6, 1.2, 4.8)
		branch(3.5, 310, 4.0, 1.8, 4.4)
		branch(3.85, 130, 3.8, 2.0, 4.2)
		branch(4.3, 20, 3.0, 1.4, 3.8)
		branch(4.5, 245, 2.8, 1.6, 3.6)
		-- stepped crown on top of the trunk
		local top = path[#path]
		oct(CFrame.new(top + v(0, 0.3, 0)) * ang(0, 15, 0), 4.2, 1.2, LF_DK, LF_XD)
		oct(CFrame.new(top + v(0.1, 1.4, 0)) * ang(0, 35, 0), 3.2, 1.1, LF, LF_MID)
		oct(CFrame.new(top + v(0.1, 2.4, -0.1)) * ang(0, 5, 0), 2.1, 0.9, LF_MID, LF_LT)
		B:block(R, v(1.0, 0.6, 1.0), CFrame.new(top + v(0.2, 3.1, 0)) * ang(0, 30, 0), LF_TIP)
		table.insert(hangs, { CFrame.new(top + v(0, 0.3, 0)), 4.2 })

		------------------------------------------------------------ Spanish moss
		for i, h in hangs do
			local c, s = h[1], h[2]
			local n = (s > 4) and 3 or 2
			for k = 1, n do
				local a = (k / n) * 360 + rnd(-30, 30) + i * 40
				local p = (c * CFrame.new(math.sin(rad(a)) * s * 0.4, -0.45, -math.cos(rad(a)) * s * 0.4)).Position
				local L = rnd(1.6, 2.8)
				local col = (k % 2 == 0) and HANG_DK or HANG
				local q = CFrame.new(p) * ang(0, -a, 0)
				B:block(R, v(1.0, L, 0.4), q * CFrame.new(0, -L / 2, 0), col)
				B:block(R, v(0.7, L * 0.7, 0.42), q * CFrame.new(0.1, -L - L * 0.3, 0), HANG)
				B:block(R, v(0.4, L * 0.5, 0.44), q * CFrame.new(-0.05, -L * 1.85, 0), HANG_LT)
			end
		end

		------------------------------------------------------------ little glowcaps at the knees
		local function cap(p, k, capCol, capLt, glow)
			B:block(R, v(0.3 * k, 0.8 * k, 0.3 * k), CFrame.new(p + v(0, 0.4 * k, 0)), STEM)
			oct(CFrame.new(p + v(0, 0.85 * k, 0)) * ang(0, 20, 0), 1.0 * k, 0.3 * k, capCol)
			B:block(R, v(0.55 * k, 0.22 * k, 0.55 * k), CFrame.new(p + v(0, 1.08 * k, 0)) * ang(0, 40, 0), capLt)
			if glow then
				B:block(R, v(0.18, 0.08, 0.18), CFrame.new(p + v(0.05, 1.22 * k, 0)) * ang(0, 10, 0), GLOW, { mat = "Neon" })
			end
		end
		cap(dirOf(150) * 4.6 + v(0, 0.15, 0), 1.0, VIO, VIO_LT, true)
		cap(dirOf(160) * 5.2 + v(0, 0.15, 0), 0.7, TEAL, TEAL_LT, false)
		cap(dirOf(305) * 4.8 + v(0, 0.15, 0), 0.85, TEAL, TEAL_LT, true)
	end,
}
