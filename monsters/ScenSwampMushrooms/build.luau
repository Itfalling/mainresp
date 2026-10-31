--!nocheck
-- Giant Swamp Mushrooms (Misty Swamp scenery, big copy-paste filler).
-- A cluster of three huge glowcap toadstools in the SwampGlowcap style: pale
-- lavender octagonal stalks on stepped bulb feet with dark flecks and a frilly
-- skirt, pale gills with radial lines, and stepped dome caps (dark-to-light
-- tiers) dotted with pale spots. Tallest violet, a teal middle one leaning
-- out, a small violet one. Only glow: one tiny neon dot on each crown.
-- Low flat moss/mud footing with stones, reeds and button sprouts.
-- Filler: anchored, weld-free, no scripts.
return {
	DisplayName = "Giant Swamp Mushrooms",
	Rarity = "Scenery",
	Filler = true,
	Element = "Misty Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Misty Swamp, SwampGlowcap hexes)
		local MUD_DK, MUD = "#4c3626", "#5e4430"
		local MOSS_DK, MOSS, MOSS_LT = "#3e6b2e", "#558a3a", "#76ab4a"
		local STONE_DK, STONE, STONE_LT = "#56605e", "#6f7a77", "#8c9893"
		local REED, REED_DK, CATTAIL = "#7a8a3e", "#5d6e30", "#4a2f1e"
		local STALK_DK, STALK, STALK_LT, STALK_BASE = "#c4b3e3", "#e0d3f5", "#f2ebfd", "#a08cc8"
		local GILL, GILL_DK = "#ddd0ef", "#b7a3d6"
		local GLOW_CY = "#7ff7ff"
		local VIO = { "#4a2789", "#6a3cbd", "#8a5bdb", "#a982ee", "#d2f8ff" }
		local TEAL = { "#135c5b", "#1d8781", "#2aaca2", "#56cfc2", "#f3dcff" }

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
		round(cf(0, 0.06, 0, 0, 15, 0), 6.0, 0.12, MUD_DK)
		round(cf(-0.4, 0.12, 0.2, 0, 40, 0), 4.4, 0.12, MOSS_DK)
		for _, m in { { -3.8, 2.6, 2.4, 1.6, 20, MOSS_LT }, { 3.0, 3.4, 2.2, 1.4, -30, MOSS_LT }, { 4.6, -2.8, 2.0, 1.5, 10, MUD }, { -1.2, -4.4, 2.6, 1.3, -15, MUD_DK } } do
			B:block(R, v(m[3], 0.16, m[4]), cf(m[1], 0.16, m[2], 0, m[5], 0), m[6])
		end
		local function stone(x, z, s, ry)
			local c = cf(x, 0.25 * s, z, 0, ry, 0)
			B:block(R, v(1.4 * s, 0.5 * s, 1.1 * s), c, STONE)
			B:block(R, v(0.9 * s, 0.3 * s, 0.7 * s), c * CFrame.new(0.15 * s, 0.32 * s, 0) * ang(0, 20, 0), STONE_LT)
			B:block(R, v(1.46 * s, 0.16 * s, 1.16 * s), c * CFrame.new(0, -0.18 * s, 0), STONE_DK)
		end
		stone(4.4, 2.0, 1.1, 25)
		stone(-5.0, -0.8, 0.8, -30)
		local function reed(x, z, h, tz, tx, cat)
			local base = v(x, 0.15, z)
			local tip = base + v(-math.sin(rad(tz)) * h, h, math.sin(rad(tx)) * h)
			B:bar(R, base, tip, 0.26, 0.26, (h > 2.6) and REED or REED_DK)
			if cat then
				local d = (tip - base).Unit
				B:bar(R, tip - d * 0.2, tip + d * 0.9, 0.46, 0.46, CATTAIL)
			end
		end
		reed(-4.6, 2.2, 3.2, 10, 8, true)
		reed(-5.0, 1.6, 2.2, 18, -4, false)
		reed(1.6, 4.6, 2.6, -6, 14, true)
		reed(2.1, 4.9, 1.8, -14, 8, false)

		------------------------------------------------------------ giant toadstool
		-- base: ground point, H: stalk height, lean: horizontal offset of the cap,
		-- Rc: cap radius, pal: cap colours, spin: yaw
		local function toadstool(base, H, lean, Rc, pal, spin, sw)
			sw = sw or 1
			-- stepped bulb foot
			oct(CFrame.new(base + v(0, 0.45, 0)) * ang(0, spin, 0), 2.6 * sw, 0.9, STALK_BASE)
			oct(CFrame.new(base + v(0, 1.2, 0)) * ang(0, spin + 20, 0), 2.1 * sw, 0.8, STALK_DK)
			-- curved octagonal stalk (2 segments)
			local p0 = base + v(0, 1.3, 0)
			local p1 = base + lean * 0.35 + v(0, H * 0.5, 0)
			local p2 = base + lean + v(0, H, 0)
			local w1, w2 = 1.6 * sw, 1.4 * sw
			B:bar(R, p0 - v(0, 0.2, 0), p1 + v(0, 0.2, 0), w1, w1, STALK)
			B:bar(R, p0 - v(0, 0.15, 0), p1 + v(0, 0.15, 0), w1 * 0.86, w1 * 0.86, STALK, { up = v(1, 0, 1).Unit })
			B:bar(R, p1 - v(0, 0.2, 0), p2 + v(0, 0.2, 0), w2, w2, STALK_LT)
			B:bar(R, p1 - v(0, 0.15, 0), p2 + v(0, 0.15, 0), w2 * 0.86, w2 * 0.86, STALK_LT, { up = v(1, 0, 1).Unit })
			-- dark flecks
			for k, f in { { 0.3, 30 }, { 0.55, 200 }, { 0.75, 320 } } do
				local p = (k == 1) and p0:Lerp(p1, f[1] * 2) or p1:Lerp(p2, (f[1] - 0.5) * 2)
				local q = CFrame.new(p) * ang(0, -f[2] - spin, 0) * CFrame.new(0, 0, -w1 * 0.5)
				B:block(R, v(0.5 * sw, 0.7 * sw, 0.2), q, STALK_DK)
			end
			-- frilly skirt ring under the cap
			local sk = CFrame.new(p1:Lerp(p2, 0.78)) * ang(0, spin, 0)
			oct(sk, 2.4 * sw, 0.3, STALK_LT, STALK)
			for k = 0, 3 do
				local q = sk * ang(0, k * 90 + 45, 0) * CFrame.new(0, -0.4, -1.1 * sw) * ang(-18, 0, 0)
				B:block(R, v(1.0 * sw, 0.8 * sw, 0.24), q, (k % 2 == 0) and STALK or STALK_DK)
			end
			-- cap
			local tilt = Vector3.new(lean.X, 0, lean.Z)
			local tx = tilt.Magnitude > 0.01 and math.deg(math.atan2(tilt.Z, tilt.X)) or 0
			local c = CFrame.new(p2) * ang(0, spin, 0) * ang(lean.Z * 2.5, 0, -lean.X * 2.5)
			round(c * CFrame.new(0, 0.25, 0), Rc * 0.82, 0.5, GILL)
			for k = 0, 3 do
				local q = c * ang(0, k * 90 + 22.5, 0) * CFrame.new(0, 0.0, -Rc * 0.5)
				B:block(R, v(0.3, 0.12, Rc * 0.62), q, GILL_DK)
			end
			local tiers = { { 1.0, 0.085, 1, 0 }, { 0.84, 0.09, 2, 22.5 }, { 0.62, 0.08, 3, 0 }, { 0.36, 0.06, 4, 22.5 } }
			local y = 0.5
			local tierY = {}
			for j, t in tiers do
				local h = t[2] * Rc * 3
				local tc = c * CFrame.new(0, y + h / 2, 0) * ang(0, t[4], 0)
				round(tc, Rc * t[1], h, pal[t[3]])
				tierY[j] = { tc, Rc * t[1], h }
				y += h
			end
			-- pale spots on the tier walls
			for _, sp in { { 1, 0, 0.16, 0.25 }, { 1, 90, 0.14, -0.15 }, { 1, 180, 0.16, -0.2 }, { 1, 270, 0.13, 0.1 }, { 2, 0, 0.12, -0.2 }, { 2, 120 - 30, 0.11, 0.15 }, { 2, 270, 0.12, 0 } } do
				local t = tierY[sp[1]]
				local s = sp[3] * Rc
				local q = t[1] * ang(0, sp[2], 0) * CFrame.new(sp[4] * t[2], 0, -t[2] - 0.06)
				B:block(R, v(s * 2.0, math.min(t[3] - 0.25, s * 1.3), 0.24), q, pal[5])
			end
			-- ledge spots seen from above
			for _, sp in { { 1, 75, 0.14 }, { 1, 240, 0.12 }, { 2, 140, 0.11 }, { 2, 330, 0.1 }, { 3, 40, 0.09 } } do
				local t = tierY[sp[1]]
				local s = sp[3] * Rc * 1.5
				local q = t[1] * ang(0, sp[2], 0) * CFrame.new(0, t[3] / 2 + 0.04, -t[2] * 0.86)
				B:block(R, v(s, 0.14, s), q * ang(0, 30, 0), pal[5])
			end
			-- crown spot + the one tiny neon dot
			local top = c * CFrame.new(0, y, 0)
			B:block(R, v(0.12 * Rc + 0.4, 0.14, 0.12 * Rc + 0.4), top * CFrame.new(0, 0.05, 0) * ang(0, 20, 0), pal[5])
			B:block(R, v(0.3, 0.14, 0.3), top * CFrame.new(0, 0.14, 0) * ang(0, 65, 0), GLOW_CY, { mat = "Neon" })
		end

		toadstool(v(-1.3, 0.12, 1.1), 13.0, v(-0.6, 0, 0.4), 5.0, VIO, 10, 1.15)
		toadstool(v(3.0, 0.12, -1.4), 8.6, v(1.6, 0, -0.6), 3.7, TEAL, 35, 0.95)
		toadstool(v(-3.2, 0.12, -2.6), 5.0, v(-0.9, 0, -0.5), 2.7, VIO, 60, 0.8)

		------------------------------------------------------------ button sprouts
		local function button(x, z, s, pal, tz)
			local bb = CFrame.new(x, 0.12, z) * ang(0, 15, tz)
			B:block(R, v(0.4 * s, 0.9 * s, 0.4 * s), bb * CFrame.new(0, 0.45 * s, 0), STALK)
			oct(bb * CFrame.new(0, 0.95 * s, 0), 1.0 * s, 0.35 * s, pal[2])
			B:block(R, v(0.55 * s, 0.22 * s, 0.55 * s), bb * CFrame.new(0, 1.2 * s, 0) * ang(0, 22, 0), pal[4])
		end
		button(1.0, 2.8, 1.2, TEAL, -10)
		button(1.8, 2.3, 0.8, VIO, 8)
		button(-5.0, -3.0, 1.0, TEAL, 12)
		button(4.6, -4.2, 0.9, VIO, -8)
	end,
}
