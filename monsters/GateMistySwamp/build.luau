--!nocheck
-- Misty Swamp Gate (map stage gate, static landmark).
-- Two huge gnarled cypress stumps (|x| 33..44) hold up a mossy old log:
-- * each stump flares into buttress roots and cypress knees at the bottom,
--   wiggles up in offset octagonal rings with dark bark ridges, and ends in a
--   jagged broken top under a moss cap with purple glow-mushrooms; a knot
--   hollow with two little glowing wisp eyes peeks out of each trunk
-- * shelf fungi with glowing teal spots climb the trunks, old planks are
--   nailed over the bark, rope lashings tie the log to the stumps
-- * crooked branches grow from both stump tops and knot together over the
--   middle in a pointed "witch" arch; wisp lanterns hang from it on ropes
--   (one over the sign, two to the sides) and from the outer branches
-- * moss drapes over everything with hanging strands; the stage "Sign" is a
--   pale weathered board in a chunky dark log frame with rope corners, crossed
--   planks on the back
-- Opening x -32..32 is clear up to y 19. Static landmark (Filler).
return {
	DisplayName = "Misty Swamp Gate",
	Rarity = "Landmark",
	Filler = true,
	Element = "Misty Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		local WOOD_XD, WOOD_DK, WOOD, WOOD_LT, WOOD_HI = "#2e231c", "#3e3026", "#54412f", "#6e563e", "#86694a"
		local MOSS_DK, MOSS, MOSS_LT, MOSS_HANG, MOSS_HANG2 = "#2f6e3f", "#4f9e6a", "#78c26a", "#9cc48a", "#7fae74"
		local CAP, CAP_DK, CAP_LT, STEM = "#9b5de5", "#7a3fc4", "#b98af0", "#e8e0c8"
		local GLOW, WISP, WISP_LT = "#5ff5d8", "#b8ffb0", "#eaffd8"
		local FUNGUS, FUNGUS_DK = "#d8b98a", "#b8956a"
		local ROPE, ROPE_DK = "#c9a46a", "#a58450"
		local PLANK, PLANK_DK, PLANK_LT = "#9a7a56", "#7d6244", "#b5946a"
		local LANTERN, NAIL = "#3a3240", "#5c5650"
		local MUD, MUD_DK, WATER = "#3d5a48", "#2f4a3a", "#4f8f8a"
		local SIGN = "#efe6cc"
		local NEON = { mat = "Neon" }

		local seed = 9071
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		------------------------------------------------------------ stumps
		local tops = {}
		local function stump(sx, topY, stubH)
			local cx = sx * 38.6
			local y = 0
			local i = 0
			local segs = {}
			while y < topY - 0.1 do
				i += 1
				local t = y / topY
				local h = math.min(3.0 + rnd(-0.4, 0.4), topY - y)
				local w = (i == 1 and 11.2) or (i == 2 and 9.8) or (9.2 - t * 2.6 + rnd(-0.3, 0.3))
				local d = math.min(w * 0.85, 8.8)
				local ox = cx + sx * (math.sin(i * 1.3) * 0.7 + 0.4)
				local yaw = rnd(-7, 7)
				if y < 19.5 then
					-- keep the inner face (incl. the turned octagon block) out of the run lane
					local ca, sa = math.cos(rad(yaw)), math.abs(math.sin(rad(yaw)))
					local half = math.max(w / 2 * ca + d / 2 * sa, 0.82 * (w + d) / 2 * 0.7072) + 0.15
					if math.abs(ox) - half < 32.3 then
						ox = sx * (32.3 + half)
					end
				end
				local col = (i % 2 == 0) and WOOD or WOOD_LT
				local c = cf(ox, y + h / 2, rnd(-0.2, 0.2), 0, yaw, 0)
				B:block(R, v(w, h + 0.05, d), c, col)
				B:block(R, v(w * 0.82, h + 0.1, d * 0.82), c * ang(0, 45, 0), WOOD_DK)
				-- bark ridges on the front + back faces
				if i % 2 == 1 then
					for _, side in { -1, 1 } do
						B:block(R, v(0.8, h + 0.4, 0.6), c * CFrame.new(rnd(-w * 0.3, w * 0.3), 0, side * d / 2), WOOD_XD)
					end
				end
				segs[#segs + 1] = { y = y, h = h, w = w, d = d, x = ox }
				y += h
			end
			-- broken outer stub rising beside the arch
			local last = segs[#segs]
			local sbx = last.x + sx * 2.6
			local sby = last.y + last.h
			local stubTop = sby + stubH
			B:block(R, v(5.0, stubH, 5.6), cf(sbx, sby + stubH / 2, 0.2, 0, 10, 0), WOOD)
			B:block(R, v(4.2, stubH + 0.1, 4.6), cf(sbx, sby + stubH / 2, 0.2, 0, 55, 0), WOOD_DK)
			local jag = { { -1.2, 2.2, 1.0 }, { 1.0, 1.4, -1.0 }, { 0.2, 3.0, 0.1 } }
			for k, j in jag do
				B:block(R, v(1.8, j[2], 1.8), cf(sbx + sx * j[1], stubTop + j[2] / 2 - 0.2, j[3], 0, k * 25, 0), (k % 2 == 0) and WOOD_HI or WOOD_LT)
			end
			B:block(R, v(5.6, 0.8, 6.2), cf(sbx, stubTop - 0.4, 0.2, 0, 8, 0), MOSS)
			B:block(R, v(3.6, 0.6, 3.8), cf(sbx - sx * 0.4, stubTop + 0.25, 0.4, 0, -12, 0), MOSS_LT)
			for _, side in { -1, 1 } do
				B:block(R, v(3.0, 2.6, 0.5), cf(sbx + sx * 0.6, stubTop - 1.5, side * 3.2), MOSS_DK)
			end
			tops[sx] = { x = sbx, y = stubTop, base = sby, last = last }

			-- buttress roots: front, back and outward (inner roots stay at |x| >= 32.3)
			local roots = {
				{ -1.0, -1.0 }, { -0.2, -1.0 }, { 0.5, -1.0 }, { 1.0, -0.5 }, { 1.0, 0.4 }, { 0.5, 1.0 }, { -0.2, 1.0 }, { -1.0, 1.0 },
			}
			for k, r in roots do
				local ax = cx + sx * r[1] * 3.4
				local az = r[2] * 3.2
				local bx = cx + sx * r[1] * 6.2
				local bz = math.clamp(r[2] * 5.4, -4.3, 4.3)
				if sx * bx < 33.4 then
					bx = sx * 33.4
				end
				local col = (k % 2 == 0) and WOOD_DK or WOOD
				B:bar(R, v(ax, 5.0, az), v(bx, 0.9, bz), 2.2, 2.0, col)
				B:block(R, v(2.0, 1.0, 2.0), cf(bx, 0.5, bz, 0, k * 17, 0), WOOD_XD)
			end
			-- cypress knees poking out of the mud
			for _, kn in { { 45.6, -3.6, 2.0 }, { 46.2, 2.4, 1.4 }, { 34.2, -5.0, 1.2 } } do
				B:block(R, v(1.2, kn[3], 1.2), cf(sx * kn[1], kn[3] / 2, kn[2], 0, 20, 0), WOOD_LT)
				B:block(R, v(0.8, 0.5, 0.8), cf(sx * kn[1], kn[3] + 0.2, kn[2], 0, 45, 0), WOOD_HI)
			end
			-- mud + puddle patch at the foot
			B:block(R, v(13.0, 0.3, 10.6), cf(cx + sx * 1.2, 0.15, 0), MUD)
			B:block(R, v(10.0, 0.32, 9.0), cf(cx + sx * 1.6, 0.16, 0.4, 0, -10, 0), MUD_DK)
			B:block(R, v(3.4, 0.36, 2.4), cf(cx + sx * 5.4, 0.2, -4.2, 0, 15, 0), WATER)

			-- knot hollow with glowing wisp eyes (front)
			local hy = 11.0
			local seg
			for _, sgm in segs do
				if hy >= sgm.y and hy < sgm.y + sgm.h then
					seg = sgm
				end
			end
			local fz = -seg.d / 2
			B:block(R, v(4.4, 4.0, 0.6), cf(seg.x, hy, fz - 0.1), WOOD_HI)
			B:block(R, v(3.4, 3.0, 0.6), cf(seg.x, hy, fz - 0.2), WOOD_XD)
			B:block(R, v(0.8, 1.0, 0.3), cf(seg.x - 0.8, hy + 0.3, fz - 0.45), WISP, NEON)
			B:block(R, v(0.8, 1.0, 0.3), cf(seg.x + 0.8, hy + 0.3, fz - 0.45), WISP, NEON)
			-- back: a second smaller hollow with a mushroom inside
			local bz = seg.d / 2
			B:block(R, v(3.6, 3.2, 0.6), cf(seg.x, hy - 2, bz + 0.1), WOOD_HI)
			B:block(R, v(2.6, 2.2, 0.6), cf(seg.x, hy - 2, bz + 0.2), WOOD_XD)
			B:block(R, v(1.4, 0.6, 1.0), cf(seg.x, hy - 2.2, bz + 0.3), CAP)
			B:block(R, v(0.4, 0.4, 0.3), cf(seg.x, hy - 2.1, bz + 0.85), GLOW, NEON)

			-- shelf fungi climbing the trunk (front + back + outer side)
			local shelves = { { 6.0, -1, -0.15 }, { 16.5, -1, 0.2 }, { 8.5, 1, 0.25 }, { 19.0, 1, -0.2 }, { 14.0, 0, 0 } }
			for _, sh in shelves do
				local sy = sh[1]
				local sg
				for _, sgm in segs do
					if sy >= sgm.y and sy < sgm.y + sgm.h then
						sg = sgm
					end
				end
				if sh[2] ~= 0 then
					local z = sh[2] * (sg.d / 2 + 0.9)
					local x = sg.x + sh[3] * sg.w
					B:block(R, v(3.2, 0.6, 1.8), cf(x, sy, z), FUNGUS)
					B:block(R, v(2.2, 0.5, 1.2), cf(x, sy + 0.5, z + sh[2] * 0.2), FUNGUS_DK)
					B:block(R, v(0.5, 0.2, 0.5), cf(x - 0.7, sy + 0.38, z + sh[2] * 0.4), GLOW, NEON)
				else
					local x = sg.x + sx * (sg.w / 2 + 0.9)
					B:block(R, v(1.8, 0.6, 3.2), cf(x, sy, 0), FUNGUS)
					B:block(R, v(1.2, 0.5, 2.2), cf(x + sx * 0.2, sy + 0.5, 0), FUNGUS_DK)
					B:block(R, v(0.5, 0.2, 0.5), cf(x + sx * 0.3, sy + 0.38, 0.6), GLOW, NEON)
				end
			end

			-- old planks nailed across the trunk front + back
			for _, side in { -1, 1 } do
				local sg = segs[3]
				local z = side * (sg.d / 2 + 0.25)
				B:block(R, v(6.4, 1.2, 0.4), cf(sg.x, 7.2, z, 0, 0, side * 12), PLANK)
				B:block(R, v(5.6, 1.1, 0.4), cf(sg.x - sx * 0.3, 5.6, z + side * 0.15, 0, 0, -side * 8), PLANK_LT)
				B:block(R, v(0.3, 0.3, 0.3), cf(sg.x - 2.2, 7.6 - side * 0.5, z + side * 0.3), NAIL)
				B:block(R, v(0.3, 0.3, 0.3), cf(sg.x + 2.2, 6.8 + side * 0.5, z + side * 0.3), NAIL)
			end

			-- hanging moss strands off the trunk sides (outside the lane)
			for _, m in { { 17.0, -1, 0.3, 5 }, { 15.0, 1, -0.2, 6 }, { 12.5, -1, -0.3, 4 } } do
				local sg
				for _, sgm in segs do
					if m[1] >= sgm.y and m[1] < sgm.y + sgm.h then
						sg = sgm
					end
				end
				local x = sg.x + m[3] * sg.w
				local z = m[2] * (sg.d / 2 + 0.3)
				B:block(R, v(2.2, 0.8, 1.0), cf(x, m[1], z), MOSS)
				B:block(R, v(1.4, m[4], 0.4), cf(x, m[1] - m[4] / 2, z), MOSS_HANG)
				B:block(R, v(0.8, m[4] * 0.6, 0.4), cf(x + 0.5, m[1] - m[4] * 0.8, z + m[2] * 0.05), MOSS_HANG2)
			end
			return segs
		end
		stump(1, 19.5, 9.0)
		stump(-1, 19.5, 7.0)

		------------------------------------------------------------ helpers
		local UP = v(0, 0, 1)
		local function lantern(x, ytop, len, k)
			k = k or 1
			B:block(R, v(0.25, len + 0.6, 0.25), cf(x, ytop - len / 2 + 0.3, 0), ROPE)
			local y = ytop - len
			B:block(R, v(1.7 * k, 0.5 * k, 1.7 * k), cf(x, y - 0.25 * k, 0), LANTERN)
			B:block(R, v(0.8 * k, 0.4 * k, 0.8 * k), cf(x, y + 0.1 * k, 0), LANTERN)
			B:block(R, v(1.2 * k, 1.4 * k, 1.2 * k), cf(x, y - 1.2 * k, 0), WISP, NEON)
			for _, c in { { 1, 1 }, { -1, 1 }, { 1, -1 }, { -1, -1 } } do
				B:block(R, v(0.3 * k, 1.6 * k, 0.3 * k), cf(x + c[1] * 0.75 * k, y - 1.2 * k, c[2] * 0.75 * k), LANTERN)
			end
			B:block(R, v(1.7 * k, 0.4 * k, 1.7 * k), cf(x, y - 2.1 * k, 0), LANTERN)
			B:block(R, v(0.5 * k, 0.4 * k, 0.5 * k), cf(x, y - 2.5 * k, 0), LANTERN)
		end
		local function branch(pts, w, col)
			for i = 1, #pts - 1 do
				B:bar(R, pts[i], pts[i + 1], w, w * 1.05, col, { up = UP })
				B:block(R, v(w * 1.15, w * 1.15, w * 1.15), CFrame.new(pts[i + 1]) * ang(0, 30 * i, 0), WOOD_DK) -- knuckle
			end
		end

		------------------------------------------------------------ bent trunk arch
		-- the stumps keep growing up and bend inward until they meet over the middle
		local archPts = {}
		for _, sx in { 1, -1 } do
			local last = tops[sx].last
			local pts = {
				{ last.x, 17.0, 0.0, 8.4 },
				{ sx * 36.6, 22.4, 0.3, 7.6 },
				{ sx * 32.0, 26.0, -0.3, 6.6 },
				{ sx * 25.0, 28.6, 0.3, 5.6 },
				{ sx * 16.0, 30.3, -0.2, 4.6 },
				{ sx * 7.0, 31.0, 0.2, 3.9 },
				{ sx * 0.8, 31.2, 0.0, 3.5 },
			}
			archPts[sx] = pts
			for i = 1, #pts - 1 do
				local p0, p1 = pts[i], pts[i + 1]
				local a, b = v(p0[1], p0[2], p0[3]), v(p1[1], p1[2], p1[3])
				local w = (p0[4] + p1[4]) / 2
				local c, len = P.aim(a, b, UP)
				B:block(R, v(w, w * 1.05, len + 0.4), c, (i % 2 == 0) and WOOD or WOOD_LT)
				B:block(R, v(w * 0.74, w * 0.74, len + 0.6), c * ang(0, 0, 45), WOOD_DK)
				-- bark ridges along the front + back
				for _, side in { -1, 1 } do
					B:block(R, v(w * 0.3, 0.5, len * 0.8), c * CFrame.new(w * 0.12 * side, 0, 0) * CFrame.new(0, side * (w * 0.525 + 0.15), 0), WOOD_XD)
				end
				-- knuckle at the joint (axis aligned so the low ones stay out of the lane)
				if i > 1 then
					B:block(R, v(p0[4] * 0.9, p0[4] * 0.9, p0[4] * 1.08), cf(p0[1], p0[2], p0[3]), WOOD_DK)
				end
			end
		end
		-- knot where the two trunks meet: lashed with rope, moss on top
		local AY = 31.2
		B:block(R, v(4.6, 3.8, 4.6), cf(0, AY, 0, 0, 15, 0), WOOD_DK)
		B:block(R, v(4.8, 0.8, 4.8), cf(0, AY + 0.5, 0, 0, 15, 0), ROPE)
		B:block(R, v(0.8, 4.0, 4.9), cf(0, AY, 0, 0, 15, 0), ROPE_DK)
		B:block(R, v(3.6, 0.8, 3.4), cf(0.3, AY + 2.1, 0, 0, -10, 0), MOSS)

		local function archAt(sx, x)
			local pts = archPts[sx]
			for i = 1, #pts - 1 do
				local p0, p1 = pts[i], pts[i + 1]
				if math.abs(x) <= math.abs(p0[1]) and math.abs(x) >= math.abs(p1[1]) then
					local t = (math.abs(p0[1]) - math.abs(x)) / (math.abs(p0[1]) - math.abs(p1[1]))
					return p0[2] + (p1[2] - p0[2]) * t, p0[4] + (p1[4] - p0[4]) * t
				end
			end
			return pts[#pts][2], pts[#pts][4]
		end

		for _, sx in { 1, -1 } do
			-- moss draped over the arch with hanging strands (strands end well above y 19)
			for mi, mx in { 28.5, 20.5, 11.5 } do
				local y, w = archAt(sx, sx * mx)
				local hang = ({ 3.4, 2.8, 2.0 })[mi]
				B:block(R, v(3.6, 1.0, w + 0.8), cf(sx * mx, y + w / 2 + 0.2, 0, 0, 0, sx * (8 + mi * 3)), MOSS)
				B:block(R, v(2.2, 0.6, w * 0.6), cf(sx * (mx + 0.4), y + w / 2 + 0.75, 0.2, 0, 0, sx * 10), MOSS_LT)
				for _, side in { -1, 1 } do
					B:block(R, v(2.4, w * 0.8, 0.5), cf(sx * mx, y + 0.2, side * (w / 2 + 0.35)), MOSS_DK)
					B:block(R, v(1.4, hang, 0.4), cf(sx * (mx - 0.5), y - w * 0.4 - hang / 2 + 0.4, side * (w / 2 + 0.45)), MOSS_HANG)
					B:block(R, v(0.8, hang * 0.6, 0.4), cf(sx * (mx + 0.6), y - w * 0.4 - hang * 0.3 + 0.4, side * (w / 2 + 0.5)), MOSS_HANG2)
				end
			end
			-- purple glow-mushroom clusters growing on top of the arch
			for ci, mx in { 27.0, 33.5 } do
				local y, w = archAt(sx, sx * mx)
				local yt = y + w / 2 - 0.1
				for k, m in { { 0, 0, 1.0 }, { 1.4, 0.9, 0.75 }, { -1.2, -0.8, 0.6 } } do
					local x, z, k2 = sx * (mx + m[1]), m[2], m[3]
					B:block(R, v(0.8 * k2, 1.8 * k2, 0.8 * k2), cf(x, yt + 0.9 * k2, z), STEM)
					B:block(R, v(2.6 * k2, 0.8 * k2, 2.6 * k2), cf(x, yt + 1.9 * k2, z, 0, 20 * k, 0), CAP_DK)
					B:block(R, v(1.9 * k2, 0.6 * k2, 1.9 * k2), cf(x, yt + 2.5 * k2, z, 0, 20 * k, 0), (ci == 1) and CAP or CAP_LT)
					if k == 1 then
						B:block(R, v(0.5, 0.3, 0.5), cf(x + sx * 0.7, yt + 2.85 * k2, z - 0.5), GLOW, NEON)
						B:block(R, v(0.5, 0.3, 0.5), cf(x - sx * 0.6, yt + 2.85 * k2, z + 0.6), GLOW, NEON)
					end
				end
			end
			-- shelf fungi on the arch's front + back faces
			for _, f in { { 33.4, -1 }, { 21.5, 1 }, { 8.0, -1 } } do
				local y, w = archAt(sx, sx * f[1])
				local z = f[2] * (w / 2 + 0.8)
				B:block(R, v(2.8, 0.5, 1.6), cf(sx * f[1], y - 0.6, z), FUNGUS)
				B:block(R, v(1.8, 0.45, 1.0), cf(sx * f[1], y - 0.15, z + f[2] * 0.2), FUNGUS_DK)
				B:block(R, v(0.45, 0.2, 0.45), cf(sx * f[1] + 0.5, y + 0.15, z + f[2] * 0.35), GLOW, NEON)
			end
			-- twig spurs on the arch
			local y1 = archAt(sx, sx * 24)
			B:bar(R, v(sx * 24, y1 + 1.5, 0.4), v(sx * 22.2, y1 + 4.4, 0.6), 0.9, 0.9, WOOD_LT, { up = UP })
			local y2 = archAt(sx, sx * 14)
			B:bar(R, v(sx * 14, y2 + 1.2, -0.3), v(sx * 12.6, y2 + 3.0, -0.5), 0.7, 0.7, WOOD, { up = UP })
			-- wisp lanterns hanging from the arch underside
			local ya, wa = archAt(sx, sx * 23.5)
			lantern(sx * 23.5, ya - wa / 2 + 0.2, 0.6, 1.25)
			local yb, wb = archAt(sx, sx * 29.6)
			lantern(sx * 30.0, yb - wb / 2 + 0.2, 1.2, 1.05)
			-- outer branch hooking out of the stub, with a lantern
			local tp = tops[sx]
			local ob = { v(tp.x + sx * 1.8, tp.y - 2.4, 0.2), v(sx * 45.6, tp.y - 0.4, -0.3), v(sx * 47.6, tp.y - 1.4, 0.0) }
			branch(ob, 1.5, WOOD_LT)
			lantern(sx * 47.6, tp.y - 2.0, 3.4, 1.2)
		end

		------------------------------------------------------------ the Sign
		-- a pale weathered board hanging on ropes under the arch
		local SY, SW, SH = 23.0, 28.0, 5.4
		local SZ = -0.6
		B:block(R, v(SW, SH, 1.0), cf(0, SY, SZ), SIGN, { name = "Sign" })
		B:block(R, v(SW + 0.4, SH + 0.4, 0.5), cf(0, SY, SZ + 0.7), PLANK_DK) -- back board
		local FZ, FD = SZ - 0.1, 1.8
		B:block(R, v(SW + 3.4, 1.4, FD), cf(0, SY + SH / 2 + 0.7, FZ), WOOD_DK)
		B:block(R, v(SW + 3.0, 1.2, FD), cf(0, SY - SH / 2 - 0.6, FZ), WOOD_DK)
		B:block(R, v(1.6, SH + 0.2, FD), cf(SW / 2 + 0.8, SY, FZ), WOOD)
		B:block(R, v(1.6, SH + 0.2, FD), cf(-SW / 2 - 0.8, SY, FZ), WOOD)
		B:block(R, v(SW + 3.8, 0.5, FD + 0.4), cf(0.3, SY + SH / 2 + 1.5, FZ, 0, 0, 1), WOOD_LT) -- top board lip
		for _, sx in { 1, -1 } do
			for _, sy in { 1, -1 } do
				local y = SY + sy * (SH / 2 + 0.55)
				B:block(R, v(0.6, 1.5, FD + 0.4), cf(sx * (SW / 2 + 0.5), y, FZ), ROPE)
				B:block(R, v(2.0, 0.6, FD + 0.4), cf(sx * (SW / 2 + 0.9), y, FZ), ROPE_DK)
			end
			-- hanging ropes up to the arch, wrapped round it
			local ya, wa = archAt(sx, sx * 10)
			local top = ya + wa / 2
			B:block(R, v(0.4, top - (SY + SH / 2 + 1.6), 0.4), cf(sx * 10, (top + SY + SH / 2 + 1.6) / 2, FZ), ROPE)
			B:block(R, v(0.8, wa + 0.3, wa + 0.3), cf(sx * 10, ya, 0), ROPE_DK)
			-- a moss strand dangling off the frame's outer corner
			B:block(R, v(1.2, 1.8, 0.4), cf(sx * (SW / 2 + 1.2), SY + SH / 2 - 0.3, FZ - 1.0), MOSS_HANG)
		end
		-- back: crossed planks + nails
		B:block(R, v(16, 1.8, 0.5), cf(0, SY, SZ + 1.15, 0, 0, 12), PLANK)
		B:block(R, v(16, 1.8, 0.5), cf(0, SY, SZ + 1.3, 0, 0, -12), PLANK_LT)
		B:block(R, v(0.4, 0.4, 0.3), cf(0, SY, SZ + 1.6), NAIL)

		------------------------------------------------------------ mushrooms
		local function shroom(x, y, z, s, glow)
			B:block(R, v(0.7 * s, 1.6 * s, 0.7 * s), cf(x, y + 0.8 * s, z), STEM)
			B:block(R, v(2.4 * s, 0.7 * s, 2.4 * s), cf(x, y + 1.75 * s, z, 0, 20, 0), CAP_DK)
			B:block(R, v(1.8 * s, 0.6 * s, 1.8 * s), cf(x, y + 2.25 * s, z, 0, 20, 0), CAP)
			if glow then
				B:block(R, v(0.45 * s, 0.25 * s, 0.45 * s), cf(x + 0.6 * s, y + 2.5 * s, z - 0.3 * s), GLOW, NEON)
			end
		end
		for _, sx in { 1, -1 } do
			local tp = tops[sx]
			shroom(tp.x + sx * 0.8, tp.y + 0.5, -1.4, 1.0, true)
			shroom(tp.x - sx * 1.0, tp.y + 0.4, 1.6, 0.7, false)
			shroom(sx * 34.8, 0.3, -4.4, 1.0, true)
			shroom(sx * 36.0, 0.3, -4.0, 0.6, false)
			shroom(sx * 44.6, 0.3, 4.2, 1.1, true)
			shroom(sx * 42.8, 0.3, -4.6, 0.7, false)
		end
	end,
}
