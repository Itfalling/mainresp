--!nocheck
-- Glowcap Mushroom (Misty Swamp filler prop, v2).
-- One small glowcap toadstool in the SwampGlowcap style:
-- * a pale lavender stalk on a stepped bulb foot, octagonal (two crossed
--   bars per segment), dark flecks and a frilly skirt ring under the cap
-- * pale gills with darker radial lines under a stepped violet dome (four
--   rounded tiers, dark to light), pale spots on the tier walls and ledges,
--   and ONE tiny neon-cyan dot on the crown (the only glow)
-- * a teal-capped little sibling and a violet button sprout for clustered
--   variety; a flat moss patch footing with mud, pebbles and a reed blade
-- Filler: anchored, weld-free, no scripts. Scatter it around the swamp.
return {
	DisplayName = "Glowcap Mushroom",
	Rarity = "Filler",
	Filler = true,
	Element = "Misty Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Misty Swamp, exact SwampGlowcap hexes)
		local MUD_DK, MUD = "#4c3626", "#5e4430"
		local MOSS_DK, MOSS, MOSS_LT = "#3e6b2e", "#558a3a", "#76ab4a"
		local STONE_DK, STONE, STONE_LT = "#56605e", "#6f7a77", "#8c9893"
		local REED, REED_DK = "#7a8a3e", "#5d6e30"
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
		local function oct(c, s, h, col)
			B:block(R, v(s, h, s), c, col)
			B:block(R, v(s * 0.8, h - 0.02, s * 0.8), c * ang(0, 45, 0), col)
		end

		------------------------------------------------------------ footing
		round(cf(0.1, 0.07, 0.1, 0, 15, 0), 1.6, 0.14, MOSS_DK)
		round(cf(-0.2, 0.1, -0.1, 0, 40, 0), 1.1, 0.2, MOSS)
		B:block(R, v(0.9, 0.24, 0.7), cf(-0.75, 0.12, -0.45, 0, 20, 0), MOSS_LT)
		B:block(R, v(1.0, 0.18, 0.7), cf(1.2, 0.09, 0.75, 0, -25, 0), MUD_DK)
		B:block(R, v(0.6, 0.22, 0.45), cf(1.25, 0.11, 0.8, 0, 5, 0), MUD)
		B:block(R, v(0.55, 0.34, 0.45), cf(-1.3, 0.17, 0.6, 0, 25, 0), STONE)
		B:block(R, v(0.38, 0.1, 0.3), cf(-1.3, 0.38, 0.58, 0, 25, 0), STONE_LT)
		B:block(R, v(0.36, 0.22, 0.3), cf(1.45, 0.11, -0.7, 0, -10, 0), STONE_DK)
		B:bar(R, v(-1.0, 0.18, 1.1), v(-1.35, 1.5, 1.4), 0.3, 0.1, REED, { up = v(-0.7, 0, 1).Unit })
		B:bar(R, v(-0.85, 0.18, 1.1), v(-0.6, 1.1, 1.55), 0.26, 0.1, REED_DK, { up = v(0.4, 0, 1).Unit })

		------------------------------------------------------------ main stalk
		local base = v(-0.15, 0.2, 0.05)
		oct(CFrame.new(base + v(0, 0.25, 0)) * ang(0, 10, 0), 1.45, 0.5, STALK_BASE)
		oct(CFrame.new(base + v(0, 0.65, 0)) * ang(0, 30, 0), 1.2, 0.4, STALK_DK)
		local path = { base + v(0, 0.7, 0), base + v(0.22, 2.2, 0.12), base + v(0.05, 3.7, -0.05) }
		for i = 1, 2 do
			local a, b = path[i], path[i + 1]
			local col = (i == 1) and STALK or STALK_LT
			local w = (i == 1) and 0.86 or 0.78
			B:bar(R, a - v(0, 0.12, 0), b + v(0, 0.12, 0), w, w, col)
			B:bar(R, a - v(0, 0.1, 0), b + v(0, 0.1, 0), w * 0.86, w * 0.86, col, { up = v(1, 0, 1).Unit })
		end
		for _, f in { { 1.4, 30 }, { 2.4, 200 }, { 3.0, 320 } } do
			local q = CFrame.new(base + v(0.1, f[1], 0)) * ang(0, -f[2], 0) * CFrame.new(0, 0, -0.44)
			B:block(R, v(0.28, 0.4, 0.12), q, STALK_DK)
		end
		-- frilly skirt ring
		local sk = CFrame.new(base + v(0.1, 3.3, 0))
		oct(sk, 1.3, 0.18, STALK_LT)
		for k = 0, 3 do
			local q = sk * ang(0, k * 90 + 45, 0) * CFrame.new(0, -0.22, -0.6) * ang(-18, 0, 0)
			B:block(R, v(0.5, 0.42, 0.14), q, (k % 2 == 0) and STALK or STALK_DK)
		end

		------------------------------------------------------------ main cap
		local c = CFrame.new(path[3]) * ang(-3, 12, 4)
		local Rc = 1.9
		round(c * CFrame.new(0, 0.15, 0), Rc * 0.8, 0.3, GILL)
		for k = 0, 3 do
			local q = c * ang(0, k * 90 + 22.5, 0) * CFrame.new(0, 0.0, -Rc * 0.5)
			B:block(R, v(0.16, 0.08, Rc * 0.6), q, GILL_DK)
		end
		local tiers = { { 1.0, 0.4, 1, 0 }, { 0.82, 0.34, 2, 22.5 }, { 0.58, 0.28, 3, 0 }, { 0.32, 0.2, 4, 22.5 } }
		local y = 0.3
		local tierY = {}
		for j, t in tiers do
			local tc = c * CFrame.new(0, y + t[2] / 2, 0) * ang(0, t[4], 0)
			round(tc, Rc * t[1], t[2], VIO[t[3]])
			tierY[j] = { tc, Rc * t[1], t[2] }
			y += t[2]
		end
		-- pale spots on tier walls (low tier: 4, second tier: 3)
		for _, sp in { { 1, 15, 0.55 }, { 1, 110, 0.5 }, { 1, 200, 0.55 }, { 1, 290, 0.45 }, { 2, 60, 0.42 }, { 2, 170, 0.4 }, { 2, 255, 0.42 } } do
			local t = tierY[sp[1]]
			local q = t[1] * ang(0, sp[2], 0) * CFrame.new(0, 0, -t[2] - 0.05)
			B:block(R, v(sp[3], math.min(t[3] - 0.08, sp[3] * 0.75), 0.14), q, VIO[5])
		end
		-- ledge spots seen from above
		for _, sp in { { 1, 75, 0.45 }, { 1, 235, 0.4 }, { 2, 140, 0.34 }, { 2, 320, 0.3 }, { 3, 40, 0.26 } } do
			local t = tierY[sp[1]]
			local q = t[1] * ang(0, sp[2], 0) * CFrame.new(0, t[3] / 2 + 0.03, -t[2] * 0.88)
			B:block(R, v(sp[3], 0.1, sp[3]), q * ang(0, 30, 0), VIO[5])
		end
		-- crown: pale spot + the single tiny neon dot
		local top = c * CFrame.new(0, y, 0)
		B:block(R, v(0.42, 0.1, 0.42), top * CFrame.new(0, 0.03, 0) * ang(0, 20, 0), VIO[5])
		B:block(R, v(0.2, 0.1, 0.2), top * CFrame.new(0, 0.1, 0) * ang(0, 65, 0), GLOW_CY, { mat = "Neon" })

		------------------------------------------------------------ teal sibling
		local tb = CFrame.new(1.4, 0.2, 0.15) * ang(0, 35, -14)
		B:block(R, v(0.6, 0.3, 0.6), tb * CFrame.new(0, 0.15, 0), STALK_BASE)
		B:block(R, v(0.42, 1.5, 0.42), tb * CFrame.new(0, 0.95, 0), STALK)
		B:block(R, v(0.34, 1.45, 0.34), tb * CFrame.new(0, 0.95, 0) * ang(0, 45, 0), STALK_LT)
		local tc = tb * CFrame.new(0, 1.75, 0)
		oct(tc * CFrame.new(0, -0.04, 0), 0.95, 0.12, GILL)
		round(tc * CFrame.new(0, 0.1, 0), 0.72, 0.2, TEAL[1])
		oct(tc * CFrame.new(0, 0.28, 0) * ang(0, 22.5, 0), 1.0, 0.18, TEAL[2])
		oct(tc * CFrame.new(0, 0.43, 0), 0.62, 0.14, TEAL[3])
		B:block(R, v(0.3, 0.1, 0.3), tc * CFrame.new(0, 0.53, 0) * ang(0, 45, 0), TEAL[4])
		for _, a in { 0, 120, 240 } do
			B:block(R, v(0.26, 0.14, 0.12), tc * ang(0, a + 20, 0) * CFrame.new(0, 0.1, -0.74), TEAL[5])
		end
		B:block(R, v(0.22, 0.08, 0.22), tc * CFrame.new(0.3, 0.38, 0.1), TEAL[5])

		------------------------------------------------------------ button sprout
		local bb = CFrame.new(0.7, 0.2, 1.05) * ang(0, 10, 10)
		B:block(R, v(0.24, 0.5, 0.24), bb * CFrame.new(0, 0.25, 0), STALK)
		oct(bb * CFrame.new(0, 0.55, 0), 0.55, 0.2, VIO[2])
		B:block(R, v(0.3, 0.12, 0.3), bb * CFrame.new(0, 0.7, 0) * ang(0, 22, 0), VIO[4])
	end,
}
