--!nocheck
-- Lily Pad Puddle (Misty Swamp filler prop).
-- A flat murky teal puddle lying straight on the ground: a stepped octagon of
-- water with a deeper dark centre and a pale ripple line, ringed by a few low
-- mud lumps and one grey stone, with three chunky lily pads (notched, two
-- shades) and a little pink water-lily on the biggest pad. A reed tuft pokes up
-- at the back edge. Anchored, weld-free, no scripts: scatter it everywhere.
return {
	DisplayName = "Lily Pad Puddle",
	Rarity = "Filler",
	Filler = true,
	Element = "Misty Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Misty Swamp)
		local MUD_DK, MUD, MUD_LT = "#3b2a1e", "#4c3626", "#5e4430"
		local WATER, WATER_DK, WATER_LT = "#2d6f6a", "#24524f", "#62a9a0"
		local PAD, PAD_DK, PAD_LT = "#3f9a4c", "#2f7a3e", "#62b85a"
		local STONE = "#6f7a72"
		local MOSS, MOSS_LT = "#4f8f3e", "#6fae4c"
		local REED, REED_DK = "#4c9a52", "#367a42"
		local LILY, LILY_LT, LILY_CEN = "#f4a6cf", "#ffe0ef", "#ffd84a"

		-- water: stepped octagon, slightly oval
		B:block(R, v(5.4, 0.16, 3.4), cf(0, 0.08, 0), WATER)
		B:block(R, v(3.6, 0.15, 4.4), cf(0, 0.075, 0), WATER)
		B:block(R, v(4.6, 0.14, 4.0), cf(0, 0.07, 0), WATER)
		B:block(R, v(2.2, 0.18, 1.6), cf(-0.5, 0.09, 0.4, 0, 20, 0), WATER_DK) -- deeper middle
		B:block(R, v(1.8, 0.19, 0.2), cf(0.9, 0.095, -0.9, 0, -15, 0), WATER_LT) -- ripple

		-- low mud lumps around the rim (not a full ring: it stays light)
		-- (half tucked under the water edge, chunky rather than long)
		local lumps = {
			{ 2.55, 0.8, 1.1, 0.34, 0.9, 70, MUD },
			{ 1.2, 1.95, 1.2, 0.28, 0.85, 20, MUD_LT },
			{ -2.5, 0.7, 1.1, 0.3, 0.9, 105, MUD_DK },
			{ -1.5, -1.65, 1.2, 0.32, 0.85, 35, MUD },
		}
		for _, m in lumps do
			B:block(R, v(m[3], m[4], m[5]), cf(m[1], m[4] / 2, m[2], 0, m[6], 0), m[7])
		end
		B:block(R, v(0.8, 0.4, 0.65), cf(2.4, 0.2, -1.0, 0, 25, 0), STONE)
		-- moss clumps on the bank
		B:block(R, v(0.9, 0.3, 0.7), cf(-2.3, 0.15, -0.6, 0, 20, 0), MOSS)
		B:block(R, v(0.8, 0.26, 0.6), cf(2.0, 0.13, 1.7, 0, -30, 0), MOSS_LT)

		-- lily pads: two crossed slabs + a water-coloured notch
		local function lily(x, z, s, yaw, col)
			local c = CFrame.new(x, 0.2, z) * ang(0, yaw, 0)
			B:block(R, v(1.5 * s, 0.12, 1.05 * s), c, col)
			B:block(R, v(1.05 * s, 0.11, 1.5 * s), c, col)
			B:block(R, v(0.32 * s, 0.13, 0.62 * s), c * CFrame.new(0, 0.01, -0.5 * s), WATER)
			return c
		end
		local big = lily(-0.7, 0.3, 1.25, 30, PAD)
		lily(1.1, -0.2, 0.95, -55, PAD_LT)
		lily(0.2, 1.4, 0.75, 120, PAD_DK)

		-- little pink water-lily on the big pad
		local f = big * CFrame.new(0.2, 0.2, 0.25)
		B:block(R, v(0.8, 0.22, 0.5), f, LILY)
		B:block(R, v(0.5, 0.24, 0.8), f, LILY)
		B:block(R, v(0.4, 0.3, 0.4), f * CFrame.new(0, 0.08, 0) * ang(0, 45, 0), LILY_LT)
		B:block(R, v(0.18, 0.12, 0.18), f * CFrame.new(0, 0.26, 0), LILY_CEN)

		-- reed tuft at the back edge
		B:bar(R, v(-0.9, 0.2, 2.2), v(-1.2, 1.7, 2.5), 0.4, 0.1, REED, { up = v(0, 0, 1) })
		B:bar(R, v(-0.6, 0.2, 2.2), v(-0.2, 1.3, 2.6), 0.36, 0.1, REED_DK, { up = v(0.4, 0, 1).Unit })
	end,
}
