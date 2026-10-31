--!nocheck
-- Lily Pad Puddle (Misty Swamp filler prop, v2).
-- A flat murky swamp puddle lying straight on the ground:
-- * stepped oval of water (dark rim under a main layer), a deep dark middle,
--   pale ripple lines and floating duckweed specks
-- * a broken bank of low mud lumps (three browns), some with moss caps, and
--   two grey stones with lit tops
-- * three lily pads of different sizes, each a rounded pad with a dark
--   underside rim, a lit patch, two veins and the classic notch
-- * a pink water-lily (two rings of petals, golden heart) on the big pad and
--   a closed bud on the middle one; two reed tufts and a baby cattail
-- Filler: anchored, weld-free, no scripts. Scatter it across the swamp.
return {
	DisplayName = "Lily Pad Puddle",
	Rarity = "Filler",
	Filler = true,
	Element = "Misty Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Misty Swamp: SwampReedBerry / SwampGlowcap)
		local MUD_XD, MUD_DK, MUD, MUD_LT = "#3b2a1e", "#4c3626", "#5e4430", "#74563c"
		local MOSS_DK, MOSS, MOSS_LT = "#3b7034", "#4f8f3e", "#6fae4c"
		local WATER_XD, WATER_DK, WATER, WATER_LT = "#1d4542", "#24524f", "#2d6f6a", "#62a9a0"
		local PAD_DK, PAD, PAD_LT = "#2f7a3e", "#3f9a4c", "#62b85a"
		local STONE_DK, STONE, STONE_LT = "#565f59", "#6f7a72", "#8c9893"
		local REED_DK, REED, REED_LT = "#367a42", "#4c9a52", "#7dbb5e"
		local CAT, CAT_DK, CAT_TIP = "#6a3f24", "#4f2d1a", "#d9c99a"
		local LILY, LILY_LT, LILY_DK = "#f4a6cf", "#ffe0ef", "#e47fb3"
		local GOLD, GOLD_DK = "#ffd84a", "#f2a92a"

		local function oct3(c, rx, rz, h, col)
			B:block(R, v(2 * rx, h, 1.15 * rz), c, col)
			B:block(R, v(1.15 * rx, h - 0.01, 2 * rz), c, col)
			B:block(R, v(1.72 * rx, h - 0.02, 1.72 * rz), c, col)
		end

		------------------------------------------------------------ water
		oct3(cf(0, 0.05, 0), 2.75, 2.15, 0.1, WATER_DK) -- dark rim
		oct3(cf(0, 0.08, 0), 2.45, 1.9, 0.14, WATER) -- main surface
		oct3(cf(-0.35, 0.09, 0.3, 0, 20, 0), 1.05, 0.8, 0.16, WATER_XD) -- deep middle
		for _, rp in { { 1.1, -0.95, 1.5, -15 }, { -1.5, 0.95, 1.1, 25 }, { 0.3, 1.45, 0.8, 5 } } do
			B:block(R, v(rp[3], 0.17, 0.14), cf(rp[1], 0.085, rp[2], 0, rp[4], 0), WATER_LT)
		end
		for _, dw in { { 1.75, 0.45 }, { 1.95, 0.05 }, { -0.9, -1.35 }, { -1.15, -1.1 } } do
			B:block(R, v(0.24, 0.18, 0.24), cf(dw[1], 0.09, dw[2], 0, 30, 0), PAD_LT)
		end

		------------------------------------------------------------ bank
		-- {angle deg, radius, width, height, depth, col, moss cap col}
		local lumps = {
			{ 70, 2.75, 1.3, 0.36, 0.85, MUD, MOSS },
			{ 112, 2.4, 1.0, 0.26, 0.7, MUD_DK, nil },
			{ 160, 2.25, 1.3, 0.32, 0.8, MUD, MOSS_LT },
			{ 205, 2.35, 1.0, 0.24, 0.7, MUD_XD, nil },
			{ 250, 2.8, 1.4, 0.34, 0.9, MUD_DK, MOSS },
			{ 300, 2.5, 1.0, 0.24, 0.7, MUD, nil },
			{ 345, 2.25, 1.2, 0.3, 0.8, MUD_XD, MOSS_DK },
			{ 25, 2.3, 1.0, 0.22, 0.7, MUD_DK, nil },
		}
		local LOW = { [MUD] = MUD_DK, [MUD_DK] = MUD_XD, [MUD_LT] = MUD, [MUD_XD] = MUD_DK }
		for _, m in lumps do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2] * 1.15, 0, -math.cos(a) * m[2]) * ang(0, -m[1], 0)
			-- wide low shadow step + the lump itself (stepped, not a box)
			B:block(R, v(m[3] * 1.25, m[4] * 0.5, m[5] * 1.2), c * CFrame.new(0.05, m[4] * 0.25, 0.12) * ang(0, -14, 0), LOW[m[6]])
			B:block(R, v(m[3], m[4], m[5]), c * CFrame.new(0, m[4] / 2, 0), m[6])
			if m[7] then
				B:block(R, v(m[3] * 0.65, 0.14, m[5] * 0.6), c * CFrame.new(0.1, m[4] + 0.05, 0.05) * ang(0, 12, 0), m[7])
			end
		end
		B:block(R, v(0.75, 0.42, 0.6), cf(2.45, 0.21, -1.25, 0, 25, 0), STONE)
		B:block(R, v(0.52, 0.12, 0.42), cf(2.42, 0.46, -1.27, 0, 25, 0), STONE_LT)
		B:block(R, v(0.5, 0.3, 0.45), cf(-2.75, 0.15, -0.55, 0, -20, 0), STONE_DK)
		B:block(R, v(0.34, 0.1, 0.3), cf(-2.75, 0.33, -0.55, 0, -20, 0), STONE)

		------------------------------------------------------------ lily pads
		local function pad(x, z, s, yaw, main, lit)
			local c = CFrame.new(x, 0.2, z) * ang(0, yaw, 0)
			B:block(R, v(1.5 * s, 0.1, 1.5 * s), c * CFrame.new(0, -0.03, 0), PAD_DK)
			B:block(R, v(1.2 * s, 0.09, 1.2 * s), c * CFrame.new(0, -0.035, 0) * ang(0, 45, 0), PAD_DK)
			B:block(R, v(1.36 * s, 0.12, 1.36 * s), c * CFrame.new(0, 0.02, 0), main)
			B:block(R, v(1.1 * s, 0.11, 1.1 * s), c * CFrame.new(0, 0.02, 0) * ang(0, 45, 0), main)
			B:block(R, v(0.55 * s, 0.13, 0.55 * s), c * CFrame.new(0.2 * s, 0.03, 0.25 * s) * ang(0, 45, 0), lit)
			for _, va in { 140, 220 } do
				B:block(R, v(0.09, 0.135, 0.55 * s), c * ang(0, va, 0) * CFrame.new(0, 0.03, -0.32 * s), PAD_DK)
			end
			B:block(R, v(0.3 * s, 0.16, 0.7 * s), c * CFrame.new(0, 0.03, -0.42 * s), WATER) -- notch
			return c
		end
		local big = pad(-0.65, 0.25, 1.35, 30, PAD, PAD_LT)
		local mid = pad(1.15, -0.25, 1.0, -55, PAD_LT, "#86cc6e")
		pad(0.15, 1.35, 0.75, 120, PAD_DK, PAD)

		------------------------------------------------------------ water-lily
		local f = big * CFrame.new(0.15, 0.22, 0.3)
		for k = 0, 4 do
			local q = f * ang(0, k * 72, 0) * CFrame.new(0, 0, -0.32) * ang(22, 0, 0)
			B:block(R, v(0.34, 0.12, 0.6), q, (k % 2 == 0) and LILY or LILY_DK)
		end
		for k = 0, 4 do
			local q = f * ang(0, k * 72 + 36, 0) * CFrame.new(0, 0.12, -0.17) * ang(50, 0, 0)
			B:block(R, v(0.26, 0.11, 0.42), q, LILY_LT)
		end
		B:block(R, v(0.28, 0.22, 0.28), f * CFrame.new(0, 0.14, 0), GOLD_DK)
		B:block(R, v(0.18, 0.12, 0.18), f * CFrame.new(0, 0.28, 0) * ang(0, 45, 0), GOLD)
		-- closed bud on the middle pad
		local bd = mid * CFrame.new(-0.15, 0.2, 0.2)
		B:block(R, v(0.34, 0.2, 0.34), bd * CFrame.new(0, 0.05, 0), PAD_DK)
		B:block(R, v(0.28, 0.42, 0.28), bd * CFrame.new(0, 0.3, 0) * ang(0, 45, 0), LILY)
		B:block(R, v(0.16, 0.18, 0.16), bd * CFrame.new(0, 0.58, 0), LILY_LT)

		------------------------------------------------------------ reeds
		local function tuft(x, z, yaw, hs)
			for k, b in { { -30, 1.5, REED_DK, REED }, { 15, 1.15, REED, REED_LT }, { 60, 0.9, REED_DK, REED } } do
				local a = rad(yaw + b[1])
				local d = v(math.sin(a), 0, -math.cos(a))
				local p0 = v(x, 0.25, z)
				local p1 = p0 + d * 0.12 + v(0, b[2] * hs * 0.6, 0)
				local p2 = p0 + d * 0.45 + v(0, b[2] * hs, 0)
				B:bar(R, p0, p1, 0.32, 0.1, b[3], { up = d })
				B:bar(R, p1 - v(0, 0.06, 0), p2, 0.24, 0.09, b[4], { up = d })
			end
		end
		tuft(-1.45, 2.05, 0, 1.15)
		tuft(2.3, 1.15, 100, 0.95)
		-- baby cattail in the back tuft
		local cb, ct = v(-1.25, 0.25, 2.2), v(-1.15, 2.1, 2.35)
		B:bar(R, cb, ct, 0.18, 0.18, REED_DK)
		B:block(R, v(0.4, 0.75, 0.4), CFrame.new(ct + v(0, 0.3, 0)) * ang(0, 20, 0), CAT)
		B:block(R, v(0.32, 0.7, 0.32), CFrame.new(ct + v(0, 0.3, 0)) * ang(0, 65, 0), CAT_DK)
		B:block(R, v(0.1, 0.35, 0.1), CFrame.new(ct + v(0, 0.82, 0)), CAT_TIP)
	end,
}
