--!nocheck
-- Honey Hills Gate (map stage gate, static landmark).
-- A sweet honeycomb gateway:
-- * each pillar (|x| 32.6..46) is a lumpy stack of big pointy-top hex cells
--   (rows of 2 and 2-offset, so the outline zig-zags) around a wax core; every
--   cell shows a darker honey-filled, pale wax-capped or empty amber centre on
--   both faces; a stepped wax plinth at the bottom
-- * the beam is a row of ten big hex cells side by side (zig-zag top and
--   bottom edges) under a runny honey glaze that drips down in stepped drips
-- * a straw beehive skep crowns the middle, ringed with stripes, a dark
--   entrance and a honey drip; five chunky bees hover around it and the
--   pillar tops (static)
-- * sunflowers and daisies grow at the pillar feet, clover leaves on the plinths
-- * the stage "Sign" (cream) sits in a chunky chocolate-wood frame with honey
--   hex corners on the front; the back shows the honeycomb cells
-- Opening x -32..32 is clear up to y 19.4. Static landmark (Filler).
return {
	DisplayName = "Honey Hills Gate",
	Rarity = "Landmark",
	Filler = true,
	Element = "Honey Hills",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"
		local SQ3 = math.sqrt(3)

		local HONEY, HONEY2, HONEY_LT, HONEY_DK = "#f7b733", "#f2a51d", "#ffcc4d", "#d98a14"
		local FILL, FILL2, WAX, EMPTY = "#e0860f", "#ee9a18", "#ffeaa6", "#a8601a"
		local GLAZE, GLAZE_LT = "#ffb229", "#ffd36b"
		local STRAW, STRAW_DK, STRAW_LT = "#e8b04a", "#c98f2e", "#f5cd72"
		local HOLE = "#4a2c14"
		local BEE_Y, BEE_K, WING, EYE = "#ffd23a", "#2a2018", "#f4fbff", "#ffffff"
		local PETAL, PETAL_DK, SEED, SEED_DK = "#ffd23a", "#f5a91c", "#6b3a1a", "#4a2810"
		local STEM, STEM_DK, LEAF, LEAF_LT = "#4f9e3a", "#3c7f2c", "#6fc24a", "#8ed85a"
		local DAISY, DAISY_C = "#ffffff", "#ffc93a"
		local CHOC, CHOC_DK = "#8a5428", "#6a3e1c"
		local PLINTH, PLINTH_DK, PLINTH_LT = "#f0a83a", "#d98f26", "#ffc35a"
		local SIGN = "#fff6d8"
		local NEON = { mat = "Neon" }

		local seed = 9081
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		-- pointy-top hex prism, axis along Z (flat-to-flat F horizontally)
		local function hex(cx, cy, cz, F, D, col)
			local s = F / SQ3
			for k = 0, 2 do
				B:block(R, v(F, s, D), cf(cx, cy, cz, 0, 0, k * 60), col)
			end
		end
		local INNER = { FILL, WAX, FILL2, EMPTY, FILL, WAX }

		------------------------------------------------------------ pillars
		local F, D = 5.4, 7.6
		local RR = F / SQ3
		local ROW = 1.5 * RR
		local cells = {
			{ 0, -2.7 }, { 0, 2.7 },
			{ 1, 0.0 }, { 1, 5.4 },
			{ 2, -2.7 }, { 2, 2.7 },
			{ 3, 0.0 }, { 3, 5.4 },
			{ 4, -2.7 }, { 4, 2.7 },
			{ 5, 0.0 },
		}
		local PX = 38.0
		local Y0 = 3.0 + RR
		local pillarTop = {}
		for _, sx in { 1, -1 } do
			local x0 = sx * PX
			-- plinth
			B:block(R, v(14.4, 1.2, 10.4), cf(x0 + sx * 1.2, 0.6, 0), PLINTH_DK)
			B:block(R, v(13.6, 1.0, 9.6), cf(x0 + sx * 1.2, 1.7, 0), PLINTH)
			B:block(R, v(13.0, 0.6, 9.0), cf(x0 + sx * 1.2, 2.5, 0), PLINTH_LT)
			-- wax core behind the cells
			B:block(R, v(10.8, 25.0, 5.6), cf(x0 + sx * 0.6, 15.0, 0), HONEY_DK)
			for i, c in cells do
				local cx = x0 + sx * c[2]
				local cy = Y0 + c[1] * ROW
				hex(cx, cy, 0, F - 0.1, D, (i % 2 == 0) and HONEY or HONEY2)
				local inner = INNER[(i + (sx == 1 and 0 or 2)) % #INNER + 1]
				for _, side in { -1, 1 } do
					hex(cx, cy, side * (D / 2 + 0.05), F * 0.66, 0.3, inner)
				end
			end
			pillarTop[sx] = { x = x0, y = Y0 + 5 * ROW + RR }
			-- clover leaves on the plinth front corners
			for _, side in { -1, 1 } do
				local lx = x0 + sx * 6.0
				B:block(R, v(1.6, 0.3, 1.6), cf(lx, 3.0, side * 4.0, 0, 45, 0), LEAF)
				B:block(R, v(1.6, 0.3, 1.6), cf(lx + 1.0, 3.0, side * 4.0 - 0.4, 0, 20, 0), LEAF_LT)
			end
		end

		------------------------------------------------------------ beam: row of big cells
		local BF, BD = 7.2, 6.0
		local BR = BF / SQ3
		local BY = 23.6 -- bottom points at BY - BR = 19.44
		local beamX = {}
		for k = 0, 9 do
			beamX[#beamX + 1] = -32.4 + k * BF
		end
		for i, x in beamX do
			hex(x, BY, 0, BF - 0.05, BD, (i % 2 == 0) and HONEY_LT or HONEY)
			for _, side in { -1, 1 } do
				local hidden = side == -1 and math.abs(x) < 16
				if not hidden then
					hex(x, BY, side * (BD / 2 + 0.05), BF * 0.64, 0.3, INNER[(i * 2) % #INNER + 1])
				end
			end
		end
		-- the beam's ends lock into the pillars
		for _, sx in { 1, -1 } do
			B:block(R, v(4.0, 7.0, 5.4), cf(sx * 34.6, BY, 0), HONEY_DK)
		end

		------------------------------------------------------------ honey glaze + drips
		B:block(R, v(75.0, 1.0, BD + 0.8), cf(0, BY + 2.6, 0), GLAZE)
		B:block(R, v(70.0, 0.6, BD + 0.4), cf(0, BY + 3.3, 0), GLAZE_LT)
		-- stepped drips down both faces (kept clear of the sign)
		local function drip(x, ytop, z, side, len)
			B:block(R, v(1.8, len, 0.6), cf(x, ytop - len / 2, z), GLAZE)
			B:block(R, v(1.1, 1.0, 0.6), cf(x, ytop - len - 0.5, z + side * 0.05), GLAZE)
			B:block(R, v(0.6, 0.6, 0.6), cf(x, ytop - len - 1.25, z + side * 0.1), GLAZE_LT)
		end
		for _, side in { -1, 1 } do
			local z = side * (BD / 2 + 0.6)
			for _, d in { { 18.2, 1.6 }, { 22.6, 2.8 }, { 27.4, 1.2 }, { 31.2, 2.2 }, { -18.4, 2.4 }, { -23.0, 1.4 }, { -27.8, 2.6 }, { -31.6, 1.4 } } do
				drip(d[1] * (side == 1 and -1 or 1), BY + 2.4, z, side, d[2])
			end
		end
		-- honey pooling over the pillar tops and dripping down their faces
		for _, sx in { 1, -1 } do
			local pt = pillarTop[sx]
			B:block(R, v(5.6, 1.0, D + 0.6), cf(pt.x, pt.y - 0.6, 0), GLAZE)
			B:block(R, v(3.6, 0.6, D - 1.0), cf(pt.x, pt.y, 0), GLAZE_LT)
			for _, side in { -1, 1 } do
				drip(pt.x + sx * 1.2, pt.y - 1.0, side * (D / 2 + 0.6), side, 3.4)
				drip(pt.x - sx * 1.6, pt.y - 1.0, side * (D / 2 + 0.6), side, 1.6)
			end
		end

		------------------------------------------------------------ the Sign
		local SY, SW, SH = 23.4, 28.0, 5.4
		local SZ = -BD / 2 - 1.1
		B:block(R, v(SW, SH, 1.0), cf(0, SY, SZ), SIGN, { name = "Sign" })
		B:block(R, v(SW, SH, 1.2), cf(0, SY, SZ + 0.9), CHOC_DK) -- backing against the cells
		local FZ, FD = SZ - 0.1, 1.8
		B:block(R, v(SW + 3.2, 1.3, FD), cf(0, SY + SH / 2 + 0.65, FZ), CHOC)
		B:block(R, v(SW + 3.2, 1.2, FD), cf(0, SY - SH / 2 - 0.6, FZ), CHOC)
		B:block(R, v(1.6, SH, FD), cf(SW / 2 + 0.8, SY, FZ), CHOC_DK)
		B:block(R, v(1.6, SH, FD), cf(-SW / 2 - 0.8, SY, FZ), CHOC_DK)
		for _, sx in { 1, -1 } do
			for _, sy in { 1, -1 } do
				hex(sx * (SW / 2 + 0.9), SY + sy * (SH / 2 + 0.55), FZ - 0.2, 2.6, FD + 0.2, HONEY_LT)
			end
		end
		-- little honey drip off the frame's top bar
		drip(-9.0, SY + SH / 2 + 1.3, FZ - 0.6, -1, 0.0001)
		drip(10.5, SY + SH / 2 + 1.3, FZ - 0.6, -1, 0.0001)

		------------------------------------------------------------ beehive skep crown
		local KY = BY + 3.6
		local rings = { { 10.0, 1.3 }, { 9.4, 1.3 }, { 8.4, 1.2 }, { 7.0, 1.1 }, { 5.2, 1.0 }, { 3.0, 0.7 } }
		local y = KY
		for i, r in rings do
			local w, h = r[1], r[2]
			local col = (i % 2 == 0) and STRAW_LT or STRAW
			B:block(R, v(w, h + 0.02, w * 0.7), cf(0, y + h / 2, 0), col)
			B:block(R, v(w * 0.86, h + 0.04, w * 0.86), cf(0, y + h / 2, 0, 0, 45, 0), STRAW_DK)
			y += h
		end
		B:block(R, v(1.2, 0.8, 1.2), cf(0, y + 0.3, 0, 0, 45, 0), STRAW_DK) -- knob
		-- entrance (front + back) with a honey drip
		for _, side in { -1, 1 } do
			B:block(R, v(2.6, 1.6, 0.4), cf(0, KY + 1.5, side * 3.55), HOLE)
			B:block(R, v(1.6, 0.6, 0.4), cf(0, KY + 2.5, side * 3.55), HOLE)
			B:block(R, v(3.4, 0.4, 0.8), cf(0, KY + 0.55, side * 3.6), STRAW_DK) -- landing lip
		end
		B:block(R, v(1.6, 2.0, 0.6), cf(2.6, KY + 4.4, -3.2), GLAZE)
		B:block(R, v(1.0, 1.0, 0.6), cf(2.6, KY + 2.9, -3.25), GLAZE)

		------------------------------------------------------------ bees
		local function bee(x, y, z, yaw, s)
			s = s or 1
			local c = CFrame.new(x, y, z) * ang(0, yaw, 0)
			B:block(R, v(1.8 * s, 1.6 * s, 2.4 * s), c, BEE_Y)
			B:block(R, v(1.9 * s, 1.7 * s, 0.45 * s), c * CFrame.new(0, 0, 0.1 * s), BEE_K)
			B:block(R, v(1.9 * s, 1.7 * s, 0.45 * s), c * CFrame.new(0, 0, 0.85 * s), BEE_K)
			B:block(R, v(1.4 * s, 1.3 * s, 1.0 * s), c * CFrame.new(0, 0.1 * s, -1.55 * s), BEE_K) -- head
			B:block(R, v(0.45 * s, 0.5 * s, 0.2 * s), c * CFrame.new(-0.35 * s, 0.3 * s, -2.06 * s), EYE)
			B:block(R, v(0.45 * s, 0.5 * s, 0.2 * s), c * CFrame.new(0.35 * s, 0.3 * s, -2.06 * s), EYE)
			B:block(R, v(1.6 * s, 0.15 * s, 1.0 * s), c * CFrame.new(-1.0 * s, 1.0 * s, 0.2 * s) * ang(0, 0, 25), WING, { tr = 0.25 })
			B:block(R, v(1.6 * s, 0.15 * s, 1.0 * s), c * CFrame.new(1.0 * s, 1.0 * s, 0.2 * s) * ang(0, 0, -25), WING, { tr = 0.25 })
			B:block(R, v(0.3 * s, 0.3 * s, 0.5 * s), c * CFrame.new(0, -0.1 * s, 1.4 * s), BEE_K) -- stinger
		end
		bee(-8.0, 31.0, -1.6, 30, 1.0)
		bee(7.6, 32.4, 0.8, -150, 0.9)
		bee(38.0, 32.6, -1.0, -20, 1.0)
		bee(-37.0, 33.0, 1.2, 160, 0.95)
		bee(-14.5, 29.4, 2.0, -60, 0.8)

		------------------------------------------------------------ sunflowers + daisies
		local function sunflower(x, z, h, yaw)
			B:block(R, v(0.7, h, 0.7), cf(x, h / 2, z), STEM)
			B:block(R, v(2.2, 0.4, 1.0), cf(x + 1.0, h * 0.45, z, 0, yaw, 20), LEAF)
			B:block(R, v(2.0, 0.4, 1.0), cf(x - 0.9, h * 0.65, z, 0, yaw, -20), LEAF_LT)
			local c = CFrame.new(x, h + 1.2, z) * ang(0, yaw, 0) * ang(-12, 0, 0)
			-- petals: two crossed squares + four tips, seed centre
			B:block(R, v(4.4, 4.4, 0.4), c, PETAL)
			B:block(R, v(4.4, 4.4, 0.4), c * ang(0, 0, 45), PETAL_DK)
			B:block(R, v(2.6, 2.6, 0.7), c * CFrame.new(0, 0, -0.2), SEED)
			B:block(R, v(1.8, 1.8, 0.8), c * CFrame.new(0, 0, -0.3) * ang(0, 0, 45), SEED_DK)
		end
		local function daisy(x, z, h)
			B:block(R, v(0.3, h, 0.3), cf(x, h / 2, z), STEM_DK)
			B:block(R, v(1.6, 0.25, 0.5), cf(x, h, z, 0, 30, 0), DAISY)
			B:block(R, v(0.5, 0.25, 1.6), cf(x, h, z, 0, 30, 0), DAISY)
			B:block(R, v(0.5, 0.35, 0.5), cf(x, h + 0.1, z, 0, 30, 0), DAISY_C)
		end
		for _, sx in { 1, -1 } do
			sunflower(sx * 46.8, -3.0, 11.0, sx * 10)
			sunflower(sx * 44.6, -4.2, 7.5, -sx * 15)
			sunflower(sx * 46.4, 3.4, 9.0, 180 + sx * 15)
			for _, d in { { 33.6, -5.4, 1.4 }, { 35.2, -5.6, 1.0 }, { 41.0, -5.5, 1.2 }, { 34.4, 5.4, 1.2 }, { 40.0, 5.6, 1.0 }, { 47.4, 0.4, 1.3 } } do
				daisy(sx * d[1], d[2], d[3])
			end
		end
	end,
}
