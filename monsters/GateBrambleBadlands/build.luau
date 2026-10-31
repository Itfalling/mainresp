--!nocheck
-- Bramble Badlands Gate (map stage gate, static landmark).
-- A fossil gateway dug out of the badlands:
-- * carved rust-stone plinths (|x| 32.6..45) with bone glyphs and glowing
--   lava cracks, a lava fissure running off into the ground
-- * two giant femur bones stand on them as the pillars: double knuckle
--   condyles at the bottom, a chunky octagonal shaft, a big knobbly head on
--   top; dark thorny brambles spiral up each femur
-- * a curved bone tusk rises from each pillar top and hooks inward
-- * an ancient carved stone lintel (dino footprint glyph panels, lava cracks,
--   dark cornice) carries the stage "Sign" in a heavy dark-stone frame with
--   bone knuckle corners; crossed bones are carved on the back
-- * a big friendly triceratops skull crowns the middle: scalloped bone frill
--   with spiky rim and rust spots, glowing teal eye sockets, a beak, a nose
--   horn and two long brow horns
-- * bramble bushes with dark berries, rubble and loose bones at the feet
-- Opening x -32..32 is clear up to y 19.4. Static landmark (Filler).
return {
	DisplayName = "Bramble Badlands Gate",
	Rarity = "Landmark",
	Filler = true,
	Element = "Bramble Badlands",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		local RK_XD, RK_DK, RK, RK_LT = "#241e22", "#3a3236", "#4a4044", "#625758"
		local ST_DK, ST, ST_LT, ST_HI = "#7d4636", "#9a5a44", "#b5704f", "#c98a62"
		local BONE_LT, BONE, BONE_DK, BONE_SH = "#fbf1d8", "#efe0bc", "#d8c398", "#b89f74"
		local SOCK = "#2a1f24"
		local TEAL, TEAL_LT = "#2fe0c8", "#9affee"
		local LAVA, LAVA_Y = "#ff7a1a", "#ffb43a"
		local STEM, STEM_DK, THORN = "#6a2e3c", "#4a2030", "#e8d6ae"
		local BERRY, BERRY_DK = "#5a2346", "#3c1630"
		local LEAF_DK, LEAF = "#4c5e2a", "#62763a"
		local SPOT = "#c07a52"
		local ASH = "#88827c"
		local SIGN = "#f3e8cc"
		local NEON = { mat = "Neon" }
		local UP = v(0, 0, 1)

		local seed = 9091
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		local PX = 38.8
		------------------------------------------------------------ plinths
		local function crack(pts, z, w)
			for i = 1, #pts - 1 do
				local a, b = pts[i], pts[i + 1]
				B:bar(R, v(a[1], a[2], z), v(b[1], b[2], z), w or 0.35, 0.3, (i % 2 == 0) and LAVA_Y or LAVA, { mat = "Neon", up = UP })
			end
		end
		for _, sx in { 1, -1 } do
			local x = sx * PX
			B:block(R, v(12.6, 1.4, 10.6), cf(x + sx * 0.4, 0.7, 0), RK_DK)
			B:block(R, v(11.8, 2.2, 9.8), cf(x + sx * 0.2, 2.5, 0), ST)
			B:block(R, v(12.2, 0.5, 10.2), cf(x + sx * 0.2, 3.8, 0), ST_DK)
			B:block(R, v(10.6, 0.8, 8.8), cf(x, 4.4, 0), ST_LT)
			for _, side in { -1, 1 } do
				local z = side * 4.95
				-- bone glyph: an eye-spiral in a recess + lava crack
				B:block(R, v(1.8, 1.8, 0.2), cf(x - sx * 2.6, 2.5, z, 0, 0, 45), BONE)
				B:block(R, v(1.0, 1.0, 0.25), cf(x - sx * 2.6, 2.5, z + side * 0.05, 0, 0, 45), ST_DK)
				B:block(R, v(0.5, 0.5, 0.3), cf(x - sx * 2.6, 2.5, z + side * 0.08, 0, 0, 45), TEAL, NEON)
				crack({ { x + sx * 1.0, 1.6 }, { x + sx * 2.0, 2.7 }, { x + sx * 3.2, 2.2 }, { x + sx * 4.4, 3.3 } }, z + side * 0.05)
			end
			-- lava fissure in the ground running out from the plinth
			local gp = { { x + sx * 6.2, -2.6 }, { x + sx * 7.6, -4.2 }, { x + sx * 7.0, -5.4 } }
			for i = 1, #gp - 1 do
				B:bar(R, v(gp[i][1], 0.1, gp[i][2]), v(gp[i + 1][1], 0.1, gp[i + 1][2]), 1.2, 0.2, RK_XD)
				B:bar(R, v(gp[i][1], 0.18, gp[i][2]), v(gp[i + 1][1], 0.18, gp[i + 1][2]), 0.5, 0.2, LAVA, NEON)
			end
		end

		------------------------------------------------------------ femur pillars
		local HEADY = 22.0
		for _, sx in { 1, -1 } do
			local x = sx * PX
			-- condyles (two big knuckles)
			for _, dx in { -3.0, 3.0 } do
				B:block(R, v(6.0, 4.6, 7.6), cf(x + dx, 7.0, 0), BONE)
				B:block(R, v(5.2, 4.0, 8.2), cf(x + dx, 7.0, 0), BONE_DK)
				B:block(R, v(4.8, 5.4, 6.6), cf(x + dx, 7.2, 0), BONE_LT)
			end
			B:block(R, v(8.6, 2.6, 6.8), cf(x, 10.2, 0), BONE)
			B:block(R, v(1.0, 2.6, 7.0), cf(x, 6.6, 0), BONE_SH) -- notch between the knuckles
			-- shaft (octagonal, slight waist)
			local sy0, sy1 = 10.8, 19.4
			B:block(R, v(7.0, sy1 - sy0, 6.0), cf(x, (sy0 + sy1) / 2, 0), BONE)
			B:block(R, v(5.8, sy1 - sy0 + 0.1, 5.8), cf(x, (sy0 + sy1) / 2, 0, 0, 45, 0), BONE_DK)
			B:block(R, v(7.8, 2.0, 6.6), cf(x, sy0 + 0.8, 0), BONE_LT)
			-- cracks + stains on the shaft (front + back)
			for _, side in { -1, 1 } do
				B:block(R, v(0.35, 3.4, 0.2), cf(x + sx * 1.2, 15.0, side * 3.05, 0, 0, 18), BONE_SH)
				B:block(R, v(0.35, 1.6, 0.2), cf(x + sx * 1.9, 13.0, side * 3.05, 0, 0, -20), BONE_SH)
				B:block(R, v(1.8, 1.4, 0.2), cf(x - sx * 1.6, 17.4, side * 3.05), SPOT)
			end
			-- head: big knob + femoral ball offset outward
			B:block(R, v(11.0, 4.4, 8.0), cf(x, HEADY, 0), BONE)
			B:block(R, v(9.4, 4.0, 9.0), cf(x, HEADY, 0), BONE_DK)
			B:block(R, v(9.4, 5.4, 7.0), cf(x, HEADY + 0.4, 0), BONE_LT)
			B:block(R, v(5.6, 5.0, 5.6), cf(x + sx * 4.6, HEADY + 3.2, 0), BONE)
			B:block(R, v(4.4, 5.8, 4.4), cf(x + sx * 4.6, HEADY + 3.4, 0, 0, 45, 0), BONE_LT)

			-- brambles spiralling up the femur
			local prev
			for i = 0, 12 do
				local a = rad(i * 62 + (sx == 1 and 0 or 30))
				local y = 5.0 + i * 1.25
				local rr = (y < 10) and 4.5 or 3.8
				local p = v(x + math.cos(a) * (rr + 1.4), y, math.sin(a) * rr)
				if prev then
					B:bar(R, prev, p, 0.7, 0.7, (i % 2 == 0) and STEM or STEM_DK)
					if i % 2 == 0 then
						local o = v(math.cos(a), 0, math.sin(a))
						B:bar(R, p, p + o * 0.8 + v(0, 0.4, 0), 0.35, 0.35, THORN)
					end
					if i % 4 == 1 then
						B:block(R, v(1.1, 0.35, 0.8), CFrame.new(p) * ang(0, -i * 62, 20), LEAF)
					end
				end
				prev = p
			end
			B:block(R, v(0.8, 0.8, 0.8), cf(x + sx * 4.6, 12.2, -4.0, 0, 30, 0), BERRY)
			B:block(R, v(0.7, 0.7, 0.7), cf(x - sx * 4.6, 16.0, 4.2, 0, 10, 0), BERRY_DK)

			---------------------------------------------------- curved tusk (hooks inward over the pillar)
			local tp = {
				{ v(x + sx * 3.6, HEADY + 3.0, 0.0), 3.6 },
				{ v(x + sx * 5.0, HEADY + 6.4, -0.2), 3.1 },
				{ v(x + sx * 4.4, HEADY + 8.9, -0.4), 2.5 },
				{ v(x + sx * 1.8, HEADY + 10.5, -0.6), 1.8 },
				{ v(x - sx * 1.4, HEADY + 10.9, -0.7), 1.0 },
			}
			for i = 1, #tp - 1 do
				local w = tp[i][2]
				local col = (i == #tp - 1) and BONE_SH or ((i % 2 == 0) and BONE or BONE_LT)
				B:bar(R, tp[i][1], tp[i + 1][1], w, w, col, { up = UP })
				if i > 1 then
					B:block(R, v(w * 1.02, w * 1.02, w * 1.02), CFrame.new(tp[i][1]), col)
				end
			end
			B:bar(R, v(x + sx * 3.9, HEADY + 4.4, 0), v(x + sx * 4.3, HEADY + 5.6, 0), 4.0, 4.0, ST_DK, { up = UP }) -- carved stone ring
			B:bar(R, v(x + sx * 4.0, HEADY + 4.6, 0), v(x + sx * 4.2, HEADY + 5.4, 0), 4.2, 0.5, LAVA, { up = UP, mat = "Neon" })
		end

		------------------------------------------------------------ the spine beam
		-- a dino backbone spans the pillars: vertebrae, discs, dorsal spines and
		-- short ribs curling down on both faces (they stop above y 19.5)
		local VY = 24.0
		local SPAN = 33.4
		local vx = {}
		local nV = 19
		for i = 0, nV - 1 do
			vx[#vx + 1] = -SPAN + i * (2 * SPAN / (nV - 1))
		end
		B:block(R, v(2 * SPAN + 2, 2.4, 3.0), cf(0, VY, 0), BONE_SH) -- spinal cord core
		for i, x in vx do
			local mid = 1 - math.abs(x) / SPAN
			B:block(R, v(2.6, 4.0, 4.4), cf(x, VY, 0), (i % 2 == 0) and BONE or BONE_LT)
			B:block(R, v(2.2, 3.4, 5.0), cf(x, VY, 0), BONE_DK)
			-- dorsal spine
			local sh = 2.4 + 2.0 * mid
			B:block(R, v(1.6, sh, 1.6), cf(x, VY + 2.0 + sh / 2, 0), BONE)
			B:block(R, v(1.0, 0.9, 1.0), cf(x, VY + 2.0 + sh + 0.3, 0, 0, 45, 0), BONE_SH)
			-- transverse knobs
			B:block(R, v(1.4, 1.2, 6.4), cf(x, VY + 1.2, 0), BONE_DK)
			-- ribs (only outside the sign tablet, both faces)
			for _, side in { -1, 1 } do
				if math.abs(x) > 19.5 then
					local a = v(x, VY + 1.0, side * 3.0)
					local b = v(x + 0.2, VY - 2.2, side * 4.0)
					local c = v(x + 0.4, 19.7, side * 3.4)
					B:bar(R, a, b, 0.9, 0.9, BONE_LT)
					B:bar(R, b, c, 0.8, 0.8, BONE)
				end
			end
		end
		-- discs between vertebrae
		for i = 1, #vx - 1 do
			B:block(R, v(1.0, 3.0, 3.6), cf((vx[i] + vx[i + 1]) / 2, VY, 0), RK_DK)
		end
		-- a bramble draped over the spine
		local bp = { v(-31, 27.2, -1.6), v(-26, 26.4, -2.8), v(-22.6, 27.6, -0.4), v(-20.2, 26.8, 1.6) }
		for i = 1, #bp - 1 do
			B:bar(R, bp[i], bp[i + 1], 0.6, 0.6, (i % 2 == 0) and STEM or STEM_DK)
			B:bar(R, bp[i], bp[i] + v(0.2, 1.0, -0.4), 0.3, 0.3, THORN)
		end
		local bq = { v(31, 26.8, 1.4), v(27.0, 27.6, -1.8), v(23.4, 26.6, -2.6), v(20.6, 27.2, -0.6) }
		for i = 1, #bq - 1 do
			B:bar(R, bq[i], bq[i + 1], 0.6, 0.6, (i % 2 == 0) and STEM or STEM_DK)
			B:bar(R, bq[i], bq[i] + v(-0.2, 1.0, -0.4), 0.3, 0.3, THORN)
		end
		B:block(R, v(0.8, 0.8, 0.8), cf(-26, 27.0, -3.2, 0, 30, 0), BERRY)
		B:block(R, v(0.7, 0.7, 0.7), cf(24.0, 27.2, -3.0, 0, 10, 0), BERRY_DK)

		------------------------------------------------------------ carved stone tablet (holds the sign)
		local TY0, TY1, TZ = 19.6, 28.0, 3.0
		B:block(R, v(37.0, TY1 - TY0, TZ * 2), cf(0, (TY0 + TY1) / 2, 0), ST)
		B:block(R, v(38.0, 0.9, TZ * 2 + 0.6), cf(0, TY1 + 0.15, 0), RK_DK) -- cornice
		B:block(R, v(37.6, 0.7, TZ * 2 + 0.4), cf(0, TY0 + 0.35, 0), ST_DK)
		for _, sx in { 1, -1 } do
			-- carved end blocks with spiral glyphs, both faces
			B:block(R, v(2.6, TY1 - TY0 - 1.4, TZ * 2 + 0.3), cf(sx * 17.4, (TY0 + TY1) / 2, 0), ST_LT)
			for _, side in { -1, 1 } do
				local z = side * (TZ + 0.2)
				B:block(R, v(1.4, 1.4, 0.2), cf(sx * 17.4, 25.4, z, 0, 0, 45), BONE)
				B:block(R, v(0.6, 0.6, 0.25), cf(sx * 17.4, 25.4, z + side * 0.05), RK_DK)
				B:block(R, v(1.6, 0.4, 0.2), cf(sx * 17.4, 22.6, z), BONE_DK)
				B:block(R, v(0.4, 1.6, 0.2), cf(sx * 17.4, 22.6, z), BONE_DK)
			end
			-- lava cracks down the tablet ends (back face + outer sides)
			crack({ { sx * 15.0, 27.4 }, { sx * 13.4, 26.0 }, { sx * 14.6, 24.4 }, { sx * 12.6, 22.4 }, { sx * 13.6, 20.6 } }, TZ + 0.08, 0.4)
		end
		-- back: carved crossed bones under a lava crack
		do
			local z = TZ + 0.15
			for _, a in { 22, -22 } do
				local c = CFrame.new(0, 23.8, z) * ang(0, 0, a)
				B:block(R, v(11, 1.3, 0.4), c, BONE)
				for _, e in { -1, 1 } do
					B:block(R, v(1.4, 1.2, 0.5), c * CFrame.new(e * 5.6, 0.55, 0.05), BONE_LT)
					B:block(R, v(1.4, 1.2, 0.5), c * CFrame.new(e * 5.6, -0.55, 0.05), BONE_DK)
				end
			end
		end

		------------------------------------------------------------ the Sign
		local SY, SW, SH = 23.6, 28.0, 5.4
		local SZ = -TZ - 0.5
		B:block(R, v(SW, SH, 1.0), cf(0, SY, SZ), SIGN, { name = "Sign" })
		local FZ, FD = SZ - 0.15, 1.8
		B:block(R, v(SW + 3.2, 1.3, FD), cf(0, SY + SH / 2 + 0.65, FZ), RK_DK)
		B:block(R, v(SW + 3.2, 1.2, FD), cf(0, SY - SH / 2 - 0.6, FZ), RK_DK)
		B:block(R, v(1.6, SH, FD), cf(SW / 2 + 0.8, SY, FZ), RK)
		B:block(R, v(1.6, SH, FD), cf(-SW / 2 - 0.8, SY, FZ), RK)
		for _, sx in { 1, -1 } do
			for _, sy in { 1, -1 } do
				local y = SY + sy * (SH / 2 + 0.6)
				B:block(R, v(2.2, 1.6, FD + 0.4), cf(sx * (SW / 2 + 0.9), y, FZ), BONE)
				B:block(R, v(1.6, 1.0, FD + 0.6), cf(sx * (SW / 2 + 0.9), y, FZ), BONE_LT)
			end
		end
		for _, dx in { -9, 0, 9 } do
			B:block(R, v(1.2, 0.25, 0.2), cf(dx, SY - SH / 2 - 0.6, FZ - FD / 2 - 0.05), LAVA, NEON)
		end

		------------------------------------------------------------ triceratops skull crown
		local KY = TY1 + 0.6 -- base of the skull (28.6)
		local KZ = 1.4
		-- frill: wide stepped half-disc in the XY plane
		local frill = { { 0.0, 23.0 }, { 1.0, 22.0 }, { 2.0, 20.0 }, { 3.0, 17.0 }, { 3.9, 13.0 }, { 4.6, 8.0 } }
		for i, f in frill do
			local h = (frill[i + 1] and frill[i + 1][1] or 5.2) - f[1]
			local col = (i % 2 == 0) and BONE_DK or BONE
			B:block(R, v(f[2], h + 0.05, 1.8), cf(0, KY + f[1] + h / 2, KZ + 1.6), col)
		end
		B:block(R, v(23.4, 0.7, 2.2), cf(0, KY + 0.2, KZ + 1.6), BONE_DK)
		-- spiky rim (epoccipitals)
		for k = 0, 10 do
			local a = rad(-82 + k * 16.4)
			local px, py = math.sin(a) * 11.4, math.cos(a) * 4.2
			B:block(R, v(1.5, 1.5, 1.4), CFrame.new(px, KY + py + 0.1, KZ + 1.6) * ang(0, 0, -math.deg(a) + 45), (k % 2 == 0) and BONE_SH or BONE_DK)
		end
		-- rust spots, front + back
		for _, sp in { { -7.0, 2.0, 1.6 }, { 7.2, 1.8, 1.4 }, { -3.6, 3.4, 1.1 }, { 4.0, 3.6, 1.2 }, { -9.6, 0.9, 0.9 }, { 9.8, 0.9, 0.9 } } do
			for _, side in { -1, 1 } do
				B:block(R, v(sp[3] * 1.4, sp[3], 0.2), cf(sp[1], KY + sp[2], KZ + 1.6 + side * 0.95), SPOT)
			end
		end
		-- cranium + snout
		B:block(R, v(8.0, 4.6, 5.0), cf(0, KY + 2.3, KZ - 1.6), BONE)
		B:block(R, v(6.6, 4.0, 6.0), cf(0, KY + 2.3, KZ - 1.8), BONE_DK)
		B:block(R, v(5.0, 3.2, 3.4), cf(0, KY + 1.6, KZ - 5.0), BONE_LT)
		B:block(R, v(3.6, 2.4, 1.2), cf(0, KY + 1.2, KZ - 6.6), BONE)
		B:block(R, v(2.4, 1.8, 0.6), cf(0, KY + 0.7, KZ - 7.1), BONE_SH) -- beak
		B:block(R, v(4.6, 1.0, 3.6), cf(0, KY + 0.2, KZ - 4.4), BONE_DK) -- jaw
		for k = -1, 1 do
			B:block(R, v(0.55, 0.55, 0.5), cf(k * 1.2, KY - 0.15, KZ - 5.9), BONE_LT)
		end
		B:block(R, v(0.7, 0.6, 0.2), cf(-1.0, KY + 2.0, KZ - 6.75), SOCK)
		B:block(R, v(0.7, 0.6, 0.2), cf(1.0, KY + 2.0, KZ - 6.75), SOCK)
		B:bar(R, v(0, KY + 2.8, KZ - 5.4), v(0, KY + 4.3, KZ - 6.0), 1.4, 1.4, BONE_LT)
		B:bar(R, v(0, KY + 4.3, KZ - 6.0), v(0, KY + 5.0, KZ - 6.2), 0.7, 0.7, BONE_SH)
		for _, sx in { 1, -1 } do
			B:block(R, v(2.2, 1.8, 0.3), cf(sx * 2.1, KY + 2.9, KZ - 4.2), SOCK)
			B:block(R, v(1.0, 1.0, 0.2), cf(sx * 2.1, KY + 2.9, KZ - 4.4), TEAL, NEON)
			B:block(R, v(3.0, 0.9, 1.2), cf(sx * 2.0, KY + 4.1, KZ - 3.9, 0, 0, sx * 10), BONE_DK)
			local hb = v(sx * 2.2, KY + 4.2, KZ - 3.0)
			local hm = v(sx * 3.0, KY + 4.5, KZ - 4.8)
			local ht = v(sx * 3.3, KY + 4.6, KZ - 6.6)
			B:bar(R, hb, hm, 1.5, 1.5, BONE_LT)
			B:bar(R, hm, ht, 0.9, 0.9, BONE_SH)
			B:bar(R, v(sx * 4.0, KY + 1.2, KZ - 2.0), v(sx * 5.6, KY + 0.6, KZ - 3.0), 1.0, 1.0, BONE_DK)
		end

		------------------------------------------------------------ feet dressing
		local function bush(x, z, s)
			for k = 0, 4 do
				local a = rad(k * 72 + rnd(-15, 15))
				local top = v(x + math.cos(a) * 1.6 * s, (2.2 + rnd(0, 1.2)) * s, z + math.sin(a) * 1.1 * s)
				B:bar(R, v(x, 0.2, z), top, 0.45 * s, 0.45 * s, (k % 2 == 0) and STEM or STEM_DK)
				B:bar(R, top, top + v(math.cos(a) * 0.5, 0.6, math.sin(a) * 0.3), 0.25, 0.25, THORN)
			end
			B:block(R, v(1.6 * s, 0.9 * s, 1.4 * s), cf(x, 0.9 * s, z, 0, 20, 0), LEAF_DK)
			B:block(R, v(0.6, 0.6, 0.6), cf(x + 0.6 * s, 1.7 * s, z - 0.5, 0, 25, 0), BERRY)
			B:block(R, v(0.5, 0.5, 0.5), cf(x - 0.7 * s, 1.4 * s, z + 0.3, 0, 10, 0), BERRY_DK)
		end
		local function rock(x, z, s, yaw)
			local c = CFrame.new(x, 0, z) * ang(0, yaw, 0)
			B:block(R, v(2.4 * s, 1.4 * s, 2.0 * s), c * CFrame.new(0, 0.7 * s, 0), RK)
			B:block(R, v(1.6 * s, 0.9 * s, 1.4 * s), c * CFrame.new(0.2 * s, 1.7 * s, 0) * ang(0, 20, 0), RK_LT)
		end
		local function smallBone(x, z, yaw)
			local c = CFrame.new(x, 0.35, z) * ang(0, yaw, 0)
			B:block(R, v(2.4, 0.5, 0.5), c, BONE)
			B:block(R, v(0.7, 0.7, 1.0), c * CFrame.new(1.2, 0, 0), BONE_LT)
			B:block(R, v(0.7, 0.7, 1.0), c * CFrame.new(-1.2, 0, 0), BONE_DK)
		end
		for _, sx in { 1, -1 } do
			bush(sx * 46.8, -2.8, 1.2)
			bush(sx * 35.0, 4.6, 0.8)
			rock(sx * 46.6, 3.0, 1.0, 25 * sx)
			rock(sx * 33.6, -5.0, 0.7, -10 * sx)
			smallBone(sx * 44.0, -4.4, 30 * sx)
			B:block(R, v(2.0, 0.25, 1.4), cf(sx * 36.4, 0.12, -4.8, 0, 15, 0), ASH)
		end
	end,
}
