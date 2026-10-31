--!nocheck
-- Glowcap Mushroom (Misty Swamp filler prop).
-- One small swamp toadstool: a pale lavender stalk on a stepped bulb foot,
-- pale gills under a stepped violet cap with cream spots, and a single tiny
-- neon-cyan dot on the crown (the only glow). A baby button mushroom and a
-- moss pad keep it from looking lonely. Anchored, weld-free, no scripts.
return {
	DisplayName = "Glowcap Mushroom",
	Rarity = "Filler",
	Filler = true,
	Element = "Misty Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		-- palette (Misty Swamp, from SwampGlowcap)
		local MUD = "#4c3626"
		local MOSS_DK, MOSS, MOSS_LT = "#3e6b2e", "#558a3a", "#76ab4a"
		local STALK_DK, STALK, STALK_LT, STALK_BASE = "#c4b3e3", "#e0d3f5", "#f2ebfd", "#a08cc8"
		local GILL = "#ddd0ef"
		local VIO_DK, VIO, VIO_MD, VIO_LT = "#4a2789", "#6a3cbd", "#8a5bdb", "#a982ee"
		local SPOT = "#e8dcff"
		local GLOW = "#7ff7ff"
		local REED = "#4c9a52"

		-- rough octagon from three overlapping slabs
		local function oct(c, r, h, col, opts)
			B:block(R, v(2 * r, h, 1.15 * r), c, col, opts)
			B:block(R, v(1.15 * r, h - 0.02, 2 * r), c, col, opts)
			B:block(R, v(1.72 * r, h - 0.04, 1.72 * r), c, col, opts)
		end

		-- footing: flat mud + moss pad
		B:block(R, v(2.6, 0.18, 2.0), cf(0.2, 0.09, 0.1, 0, 15, 0), MUD)
		B:block(R, v(1.9, 0.22, 1.5), cf(-0.1, 0.11, -0.1, 0, -20, 0), MOSS)

		-- stalk (main mushroom slightly off-centre, leaning a touch)
		local base = v(-0.2, 0, 0)
		B:block(R, v(1.3, 0.75, 1.3), cf(base.X, 0.5, base.Z, 0, 20, 0), STALK_BASE)
		local s0, s1 = base + v(0, 0.7, 0), base + v(0.15, 2.5, 0.05)
		B:bar(R, s0, s1, 0.85, 0.85, STALK)
		B:block(R, v(0.3, 0.3, 0.12), CFrame.new(s0:Lerp(s1, 0.45) + v(0, 0, -0.45)), STALK_DK) -- fleck

		-- cap: gills, three stepped violet tiers, crown
		local c = CFrame.new(s1) * ang(-4, 15, 5)
		oct(c * CFrame.new(0, 0.05, 0), 1.25, 0.3, GILL)
		oct(c * CFrame.new(0, 0.38, 0), 1.65, 0.42, VIO_DK)
		oct(c * CFrame.new(0, 0.78, 0) * ang(0, 22.5, 0), 1.3, 0.4, VIO)
		B:block(R, v(1.55, 0.36, 1.55), c * CFrame.new(0, 1.15, 0), VIO_MD)
		B:block(R, v(0.9, 0.26, 0.9), c * CFrame.new(0, 1.43, 0) * ang(0, 45, 0), VIO_LT)
		B:block(R, v(0.26, 0.1, 0.26), c * CFrame.new(0.05, 1.59, 0.05) * ang(0, 45, 0), GLOW, { mat = "Neon" })

		-- cream spots on the cap tiers (no glow)
		for _, s in { { 0, 1.67, 0.38, 0.6 }, { 135, 1.67, 0.38, 0.55 }, { 250, 1.67, 0.38, 0.5 }, { 70, 1.35, 0.78, 0.45 }, { 200, 1.35, 0.78, 0.45 }, { 315, 1.35, 0.78, 0.4 } } do
			local q = c * CFrame.Angles(0, math.rad(s[1]), 0) * CFrame.new(0, s[3], -s[2])
			B:block(R, v(s[4], s[4] * 0.6, 0.2), q, SPOT)
		end

		-- baby button mushroom
		local b = CFrame.new(0.95, 0, -0.55) * ang(0, 30, -8)
		B:block(R, v(0.32, 0.8, 0.32), b * CFrame.new(0, 0.5, 0), STALK)
		B:block(R, v(0.85, 0.3, 0.85), b * CFrame.new(0, 0.95, 0), VIO)
		B:block(R, v(0.5, 0.22, 0.5), b * CFrame.new(0, 1.18, 0) * ang(0, 45, 0), VIO_MD)

		-- moss tuft + reed blade
		B:block(R, v(0.7, 0.35, 0.6), cf(-1.1, 0.3, 0.6, 0, 30, 0), MOSS_LT)
		B:block(R, v(0.5, 0.3, 0.5), cf(0.8, 0.28, 0.75, 0, -10, 0), MOSS_DK)
		B:bar(R, v(-1.1, 0.2, -0.5), v(-1.5, 1.6, -0.8), 0.32, 0.1, REED, { up = v(-1, 0, -0.6).Unit })
	end,
}
