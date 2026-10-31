--!nocheck
-- Red Toadstools (Thorny Woods filler prop).
-- A little cluster of three red-and-white fly-agaric toadstools of
-- different heights: chunky cream stalks, pale gills, stepped red caps
-- (wide dark-red brim under a bright 45-degree crown) dotted with white
-- spots, leaning slightly apart, with a small grass tuft at their feet.
-- No motion, no effects.
return {
	DisplayName = "Red Toadstools",
	Rarity = "Filler",
	Filler = true,
	Element = "Thorny Woods",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		-- palette (Thorny Woods toadstools)
		local RED_DK, RED = "#9a1a20", "#c8262a"
		local SPOT, STALK, GILL = "#fbf6ea", "#f6e6c2", "#e2cfa4"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"

		-- toadstool: stalk from the ground, gills, a three-step domed cap and
		-- white spots (on the top, on the crown ledge and on the brim sides)
		-- s = scale, h = stalk height, yaw = turn, lean = tilt (degrees about Z)
		local function toadstool(x, z, s, h, yaw, lean, ledge, side)
			local base = cf(x, 0, z, 0, yaw, 0) * CFrame.Angles(0, 0, rad(lean))
			B:block(R, v(0.7 * s, h + 0.1, 0.7 * s), base * CFrame.new(0, h / 2 - 0.05, 0), STALK)
			local top = base * CFrame.new(0, h, 0)
			B:block(R, v(1.5 * s, 0.16, 1.5 * s), top * CFrame.new(0, 0.06, 0), GILL)
			local y0 = 0.12
			local bh, ch, th = 0.45 * s, 0.42 * s, 0.32 * s
			B:block(R, v(2.0 * s, bh, 2.0 * s), top * CFrame.new(0, y0 + bh / 2, 0), RED_DK)
			B:block(R, v(1.42 * s, ch, 1.42 * s), top * CFrame.new(0, y0 + bh + ch / 2 - 0.02, 0) * CFrame.Angles(0, rad(45), 0), RED)
			B:block(R, v(1.0 * s, th, 1.0 * s), top * CFrame.new(0, y0 + bh + ch + th / 2 - 0.04, 0) * CFrame.Angles(0, rad(20), 0), RED)
			local sp = v(0.5 * s, 0.1, 0.5 * s)
			-- spot on the top
			B:block(R, sp, top * CFrame.new(0.1 * s, y0 + bh + ch + th - 0.01, -0.05 * s) * CFrame.Angles(0, rad(30), 0), SPOT)
			-- spots on the brim ledge (the corners of the brim the crown leaves free)
			for _, c in ledge do
				B:block(R, sp, top * CFrame.new(c[1] * s, y0 + bh + 0.03, c[2] * s) * CFrame.Angles(0, rad(45), 0), SPOT)
			end
			-- spots on the brim sides
			for _, a in side do
				local d = CFrame.Angles(0, rad(a), 0)
				B:block(R, v(0.5 * s, 0.26 * s, 0.1), top * d * CFrame.new(0, y0 + bh / 2, -(1.0 * s + 0.03)), SPOT)
			end
		end

		toadstool(-0.6, 0.25, 1.15, 1.7, 15, 6, { { 0.78, 0.78 }, { -0.78, -0.78 } }, { 0, 90 })
		toadstool(1.35, -0.3, 0.8, 1.05, -25, -10, { { -0.78, 0.78 } }, { 0, 180 })
		toadstool(0.1, -1.2, 0.55, 0.55, 40, 10, {}, { 0 })

		-- small grass tufts at their feet
		B:block(R, v(0.4, 0.8, 0.4), cf(-1.6, 0.4, -0.7, 0, 20, 12), GRASS)
		B:block(R, v(0.35, 0.6, 0.35), cf(-1.3, 0.3, -0.95, 0, 50, -16), GRASS_DK)
		B:block(R, v(0.35, 0.55, 0.35), cf(1.2, 0.27, 0.9, 0, 10, -14), GRASS)
	end,
}
