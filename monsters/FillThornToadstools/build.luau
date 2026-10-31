--!nocheck
-- Red Toadstools (Thorny Woods filler prop).
-- A little family of fly-agaric toadstools: a big one, a medium one leaning
-- away, a small one and a tiny button. Built like the Toadstool Tower: a
-- tan bulb at the foot, a cream stalk with a shaded base and a pale
-- highlight strip, a frilly skirt ring, two-tone gills, and a domed cap that
-- steps up in rounded tiers from a dark-red brim through red to a bright
-- crown, dotted with chunky white spots on the top, the ledges and the
-- sides. A low mossy forest-floor footing with leaf litter, pebbles and
-- grass tufts. No motion, no effects.
return {
	DisplayName = "Red Toadstools",
	Rarity = "Filler",
	Filler = true,
	Element = "Thorny Woods",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		-- palette (Thorny Woods: Toadstool Tower / Mushroom Log)
		local RED_DK, RED, RED_LT, RED_HI = "#9a1a20", "#c8262a", "#de3a34", "#ee5a48"
		local SPOT, SPOT2 = "#fbf6ea", "#efe3cc"
		local STALK, STALK_DK, STALK_LT, STALK_BASE = "#fdeecb", "#e4cb9a", "#fff8e4", "#cfae7c"
		local GILL, GILL_DK = "#f0dcb4", "#cdb187"
		local MOSS, MOSS_DK, MOSS_LT = "#5aa236", "#3f7f2a", "#86c94a"
		local DIRT_DK, DIRT = "#3a2416", "#5e3b24"
		local LEAF_O, LEAF_Y = "#c8612a", "#d99a2e"
		local STONE, STONE_LT = "#8a8378", "#a59d90"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"

		local Y45 = CFrame.Angles(0, rad(45), 0)
		-- rounded tier: a square + a slightly smaller square turned 45 degrees
		local function tier(C, w, h, c1, c2)
			B:block(R, v(w, h, w), C, c1)
			B:block(R, v(0.82 * w, h - 0.02, 0.82 * w), C * Y45, c2 or c1)
		end

		-- k = scale, h = stalk height, lean = tilt (deg about local Z)
		-- opts: skirt (bool), ledge (list of {x, z}), side (list of yaw degrees)
		local function toadstool(x, z, k, h, yaw, lean, skirt, ledge, side)
			local base = cf(x, 0, z, 0, yaw, 0)
			-- bulb at the foot (stays upright on the ground)
			tier(base * CFrame.new(0, 0.15 * k, 0), 0.85 * k, 0.3 * k, STALK_BASE, STALK_DK)
			local S = base * CFrame.Angles(0, 0, rad(lean))
			-- stalk: shaded lower part, main stalk, pale highlight strip
			B:block(R, v(0.64 * k, 0.4 * h, 0.64 * k), S * CFrame.new(0, 0.2 * h + 0.05, 0), STALK_DK)
			B:block(R, v(0.58 * k, h, 0.58 * k), S * CFrame.new(0, h / 2, 0), STALK)
			B:block(R, v(0.14 * k, 0.6 * h, 0.05), S * CFrame.new(-0.12 * k, 0.6 * h, -(0.29 * k + 0.02)), STALK_LT)
			if skirt then
				tier(S * CFrame.new(0, 0.74 * h, 0), 0.95 * k, 0.14, SPOT2, STALK_LT)
			end
			local top = S * CFrame.new(0, h, 0)
			-- gills (two tones) under the cap
			B:block(R, v(1.65 * k, 0.12, 1.65 * k), top * CFrame.new(0, 0.04, 0) * Y45, GILL_DK)
			B:block(R, v(1.2 * k, 0.1, 1.2 * k), top * CFrame.new(0, -0.03, 0), GILL)
			-- domed cap: brim, middle tier, top, crown
			local bh, mh, th = 0.38 * k, 0.44 * k, 0.36 * k
			local yb = 0.1 + bh / 2
			local ym = 0.1 + bh + mh / 2 - 0.03
			local yt = 0.1 + bh + mh + th / 2 - 0.06
			tier(top * CFrame.new(0, yb, 0), 2.05 * k, bh, RED_DK, RED_DK)
			tier(top * CFrame.new(0, ym, 0) * CFrame.Angles(0, rad(22.5), 0), 1.6 * k, mh, RED, RED)
			B:block(R, v(1.05 * k, th, 1.05 * k), top * CFrame.new(0, yt, 0) * Y45, RED_LT)
			local yc = 0.1 + bh + mh + th - 0.06
			B:block(R, v(0.55 * k, 0.12, 0.55 * k), top * CFrame.new(0.05 * k, yc + 0.04, 0), RED_HI)
			-- spots: top, ledges, brim sides
			B:block(R, v(0.46 * k, 0.1, 0.46 * k), top * CFrame.new(-0.18 * k, yc + 0.08, 0.15 * k) * CFrame.Angles(0, rad(30), 0), SPOT)
			for _, c in ledge do
				local yl = c[3] and (0.1 + bh + mh - 0.03) or (0.1 + bh)
				B:block(R, v(0.46 * k, 0.1, 0.46 * k), top * CFrame.new(c[1] * k, yl + 0.03, c[2] * k) * Y45, SPOT)
			end
			for i, a in side do
				B:block(R, v(0.46 * k, 0.26 * k, 0.1), top * CFrame.Angles(0, rad(a), 0) * CFrame.new(0.1 * k, yb, -(1.025 * k + 0.03)), (i % 2 == 0) and SPOT2 or SPOT)
			end
		end

		toadstool(-0.55, 0.3, 1.2, 1.8, 15, 5, true, { { 0.8, 0.8 }, { -0.8, -0.75 }, { 0.55, -0.35, true } }, { 0, 90, 215 })
		toadstool(1.6, -0.3, 0.85, 1.15, -25, -12, true, { { -0.8, 0.8 }, { 0.75, -0.8 } }, { 0, 160 })
		toadstool(0.15, -1.3, 0.55, 0.6, 40, 9, false, { { 0.8, 0.75 } }, { 20 })
		-- tiny button toadstool
		local tb = cf(-1.75, 0, -0.75, 0, 30, -8)
		B:block(R, v(0.22, 0.4, 0.22), tb * CFrame.new(0, 0.2, 0), STALK)
		B:block(R, v(0.55, 0.22, 0.55), tb * CFrame.new(0, 0.48, 0), RED_DK)
		B:block(R, v(0.38, 0.18, 0.38), tb * CFrame.new(0, 0.64, 0) * Y45, RED)
		B:block(R, v(0.16, 0.06, 0.16), tb * CFrame.new(0.03, 0.75, 0), SPOT)

		---------------------------------------------------------------- footing
		B:block(R, v(3.0, 0.08, 2.2), cf(0.1, 0.04, -0.1, 0, 12, 0), DIRT_DK)
		B:block(R, v(2.4, 0.14, 1.8), cf(-0.4, 0.07, 0.3, 0, -18, 0), MOSS_DK)
		B:block(R, v(1.3, 0.18, 1.0), cf(-0.9, 0.09, 0.9, 0, 30, 0), MOSS)
		B:block(R, v(0.7, 0.2, 0.6), cf(1.4, 0.1, 0.8, 0, -10, 0), MOSS_LT)
		B:block(R, v(0.9, 0.08, 0.7), cf(1.5, 0.04, -1.2, 0, 40, 0), DIRT)
		for _, l in { { -1.9, 0.9, 25, LEAF_O }, { 2.3, 0.6, -40, LEAF_Y }, { 1.0, -2.0, 70, LEAF_O }, { -0.8, -1.9, 10, LEAF_Y } } do
			B:block(R, v(0.75, 0.08, 0.5), cf(l[1], 0.04, l[2], 0, l[3], 0), l[4])
		end
		B:block(R, v(0.7, 0.36, 0.55), cf(2.3, 0.18, -0.9, 4, 25, -4), STONE)
		B:block(R, v(0.4, 0.2, 0.34), cf(2.2, 0.36, -0.85, 0, 50, 0), STONE_LT)
		B:block(R, v(0.45, 0.24, 0.4), cf(-1.4, 0.12, 1.5, 0, 60, 0), STONE)
		for _, g in { { -2.1, 0.1, 15 }, { 2.4, 0.0, 50 }, { 0.4, 1.6, 80 } } do
			B:block(R, v(0.35, 0.75, 0.35), cf(g[1], 0.37, g[2], 6, g[3], 8), GRASS)
			B:block(R, v(0.3, 0.55, 0.3), cf(g[1] + 0.28, 0.27, g[2] + 0.12, -6, g[3] + 25, -12), GRASS_DK)
		end
	end,
}
