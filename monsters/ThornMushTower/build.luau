--!nocheck
-- Toadstool Tower (Thorny Woods crop #7, Secret).
-- Three giant red toadstool caps with chunky white spots stacked up one thick,
-- slightly crooked cream stalk like a mushroom pagoda. Every cap has softly
-- glowing mint gills underneath and a frilly cream skirt-ring on the stalk.
-- A thorny briar vine spirals up the stalk; little rose-pink mushroom "fruits"
-- sprout in clusters from the cap tops, the stalk and the mound, each with a
-- tiny glowing tip. Orange shelf fungi stud the stalk. Base: a stepped dark
-- forest-dirt mound with moss pads, stones, fallen leaves, thorny twigs and
-- tiny red mushrooms. Mint/pink spore sparkles + one soft mint light.
-- Static prop: no motion.luau.
return {
	DisplayName = "Toadstool Tower",
	Rarity = "Secret",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3a2416", "#472b1a", "#5e3b24", "#7a4f30"
		local MOSS, MOSS_DK, MOSS_LT = "#5aa236", "#3f7f2a", "#86c94a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8a8378", "#a59d90", "#66605a"
		local LEAF_O, LEAF_R, LEAF_Y = "#c8612a", "#9c3324", "#d99a2e"
		local TWIG, TWIG_DK = "#4a3020", "#36231a"
		local THORN, THORN_TIP = "#e6d6ae", "#8a2232"
		local RED_DK, RED, RED_LT, RED_HI = "#9a1a20", "#c8262a", "#de3a34", "#ee5a48"
		local SPOT, SPOT2 = "#fbf6ea", "#efe3cc"
		local STALK, STALK_DK, STALK_LT, STALK_BASE = "#fdeecb", "#e4cb9a", "#fff8e4", "#cfae7c"
		local GILL, GILL_DK = "#f0dcb4", "#cdb187"
		local GLOW = "#9dffc4"
		local SHELF, SHELF_DK, SHELF_LT = "#d77a2c", "#a85620", "#eda04a"
		local VINE, VINE_DK, VLEAF, VLEAF_DK = "#3e6a2a", "#2c4f1f", "#4f9a34", "#367a2a"
		local ROSE, ROSE_DK = "#d8264a", "#a01838"
		local FR, FR_DK, FR_LT = "#f4b62c", "#d68a1c", "#ffd65a"
		local FR_GLOW = "#fff2a8"
		local NEON = { mat = "Neon" }

		local seed = 7137
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function lookAt(pos, target)
			local d = target - pos
			return (P.aim(pos - d, pos + d))
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function polar(c, a, y, r)
			-- frame inside c at angle a (deg), height y, radius r; local -Z points outward
			return c * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y, -r)
		end
		-- stepped octagon disc (2 parts)
		local function oct(bone, c, r, h, col, opts)
			B:block(bone, v(2 * r, h, 2 * r), c, col, opts)
			B:block(bone, v(2 * r - 0.04, h - 0.04, 2 * r - 0.04), c * ang(0, 45, 0), col, opts)
		end

		---------------------------------------------------------------- mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.4, 2.3), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 6.2, DIRT_DK, 17, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.6, 4.3, DIRT, 12, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.4, 0.45, 2.7, DIRT_LT, 0, {}, 0)
		local TOP = 1.85

		-- moss pads draped over the tier edges
		for _, m in { { -35, 6.1, 1.12, 2.3, MOSS }, { 50, 6.0, 1.1, 2.0, MOSS_DK }, { 135, 6.15, 1.1, 2.0, MOSS }, { 215, 6.0, 1.12, 2.2, MOSS_DK }, { 290, 6.1, 1.1, 1.8, MOSS }, { 15, 4.2, 1.72, 1.6, MOSS_LT }, { 175, 4.25, 1.72, 1.5, MOSS } } do
			local c = polar(CFrame.new(), m[1], m[3], m[2])
			B:block(soil, v(m[4], 0.3, 1.3), c * ang(-12, 0, 0), m[5], S)
		end
		-- stones
		for _, s in { { 4.9, 1.0, -3.4, 0.9, 25, STONE }, { 5.6, 0.9, -2.2, 0.6, 10, STONE_LT }, { -5.3, 0.95, 2.8, 0.85, -20, STONE_DK }, { 2.6, 0.95, 5.5, 0.7, 40, STONE }, { -3.0, 1.75, 2.9, 0.6, 15, STONE_LT } } do
			B:block(soil, v(s[4] * 1.2, s[4], s[4]), cf(s[1], s[2], s[3], rnd(-10, 10), s[5], rnd(-10, 10)), s[6], S)
		end
		-- grass tufts
		for _, g in { { 5.9, 0.8 }, { -5.8, -1.4 }, { -1.8, 5.9 }, { 4.3, 4.5 }, { -4.4, -4.5 } } do
			B:block(soil, v(0.4, 0.9, 0.4), cf(g[1], 0.95, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.3, 0.6, 0.3), cf(g[1] + 0.3, 0.9, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end
		-- fallen leaves (flat, rotated)
		for _, l in { { 3.6, 1.43, -2.6, LEAF_O }, { -3.9, 1.43, -2.4, LEAF_Y }, { 1.2, 1.88, -2.2, LEAF_R }, { -2.0, 1.43, 3.7, LEAF_O }, { 5.4, 0.83, 2.2, LEAF_R }, { -5.0, 0.83, -3.6, LEAF_O } } do
			B:block(soil, v(1.0, 0.12, 0.6), cf(l[1], l[2], l[3], rnd(-6, 6), rnd(0, 180), rnd(-6, 6)), l[4], S)
		end
		-- thorny twigs lying on the mound
		local function twig(a, b)
			B:bar(soil, a, b, 0.32, 0.32, TWIG, S)
			local d = (b - a)
			for k = 1, 3 do
				local p = a + d * (k / 4)
				B:block(soil, v(0.22, 0.22, 0.22), CFrame.new(p + v(0, 0.22, 0)) * ang(45, k * 40, 45), k % 2 == 0 and THORN_TIP or THORN, S)
			end
		end
		twig(v(-5.6, 1.0, -0.6), v(-3.6, 1.55, -2.0))
		twig(v(4.4, 1.0, 3.4), v(2.6, 1.6, 3.8))
		-- tiny red mushrooms on the mound
		for _, m in { { 3.6, 1.4, 1.2, 0.8 }, { -3.7, 1.4, -0.4, 0.7 }, { 5.2, 0.8, -0.6, 0.6 }, { -1.6, 0.8, -5.6, 0.65 } } do
			local k = m[4]
			local f = cf(m[1], m[2], m[3], rnd(-8, 8), rnd(0, 90), rnd(-8, 8))
			B:block(soil, v(0.35 * k, 0.9 * k, 0.35 * k), f * CFrame.new(0, 0.45 * k, 0), STALK, S)
			B:block(soil, v(1.0 * k, 0.4 * k, 1.0 * k), f * CFrame.new(0, 1.0 * k, 0), RED, S)
			B:block(soil, v(0.25 * k, 0.12 * k, 0.25 * k), f * CFrame.new(0.2 * k, 1.24 * k, -0.15 * k), SPOT, S)
		end

		---------------------------------------------------------------- stalk
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		-- bulbous base (volva) with roots
		oct(crop, cf(0, TOP + 0.35, 0), 2.0, 0.9, STALK_BASE)
		oct(crop, cf(0, TOP + 1.1, 0, 0, 22, 0), 1.8, 0.8, STALK_DK)
		for _, r in { 20, 110, 200, 290 } do
			local c = polar(CFrame.new(0, TOP, 0), r, 0.2, 2.3)
			B:block(crop, v(0.9, 0.6, 1.6), c * ang(-12, 0, 0), STALK_BASE)
		end
		-- stalk path (slight S-curve)
		local path = {
			{ y = TOP + 1.4, x = 0.0, z = 0.0, r = 1.5 },
			{ y = TOP + 3.4, x = 0.15, z = 0.05, r = 1.4 },
			{ y = 7.6, x = 0.3, z = 0.1, r = 1.3 },
			{ y = 10.2, x = 0.35, z = 0.0, r = 1.15 },
			{ y = 12.6, x = 0.1, z = -0.15, r = 1.05 },
			{ y = 15.4, x = -0.25, z = -0.1, r = 0.9 },
			{ y = 17.8, x = -0.35, z = 0.05, r = 0.8 },
			{ y = 19.6, x = -0.3, z = 0.1, r = 0.7 },
		}
		local function stalkAt(y)
			for i = 1, #path - 1 do
				local a, b = path[i], path[i + 1]
				if y <= b.y then
					local t = math.clamp((y - a.y) / (b.y - a.y), 0, 1)
					return v(a.x + (b.x - a.x) * t, y, a.z + (b.z - a.z) * t), a.r + (b.r - a.r) * t
				end
			end
			local l = path[#path]
			return v(l.x, y, l.z), l.r
		end
		for i = 1, #path - 1 do
			local a, b = path[i], path[i + 1]
			local pa, pb = v(a.x, a.y, a.z), v(b.x, b.y, b.z)
			local w = a.r * 2
			local col = (i % 2 == 0) and STALK or STALK_LT
			B:bar(crop, pa - v(0, 0.2, 0), pb + v(0, 0.2, 0), w, w, col)
			B:bar(crop, pa - v(0, 0.15, 0), pb + v(0, 0.15, 0), w * 0.86, w * 0.86, col, { up = v(1, 0, 1).Unit })
			-- a few stalk texture flecks
			local mid = (pa + pb) / 2
			B:block(crop, v(0.5, 0.8, 0.2), CFrame.new(mid + v(0, 0, -a.r - 0.0)), STALK_DK)
		end

		---------------------------------------------------------------- caps
		local gillParts = {}
		local function skirt(y, r)
			local p, sr = stalkAt(y)
			local c = CFrame.new(p)
			oct(crop, c, sr + 0.45, 0.35, SPOT2)
			local n = 8
			for i = 0, n - 1 do
				local q = polar(c, i * 45 + 22.5, -0.35, sr + 0.45)
				B:block(crop, v(0.9, 0.7, 0.3), q * ang(-14, 0, 0), (i % 2 == 0) and SPOT or SPOT2)
			end
		end
		local function round(bone, c, r, h, col)
			B:block(bone, v(2 * r, h, 1.1 * r), c, col)
			B:block(bone, v(1.1 * r, h - 0.04, 2 * r), c, col)
			B:block(bone, v(1.72 * r, h - 0.08, 1.72 * r), c, col)
		end
		local function cap(y, R, tiltX, tiltZ, rot, spotMask)
			local p = stalkAt(y)
			local c = CFrame.new(p) * ang(tiltX, rot, tiltZ)
			local H = 0.7 * R
			-- gills (cream disc underneath with glowing mint lines)
			round(crop, c * CFrame.new(0, 0.32, 0), R * 0.8, 0.42, GILL)
			for i = 0, 7 do
				local a = i * 45 + 22.5
				local r0, r1 = 1.0, R * 0.92
				local q = polar(c, a, 0.06, (r0 + r1) / 2)
				if i % 2 == 0 then
					table.insert(gillParts, B:block(crop, v(0.24, 0.12, r1 - r0), q, GLOW, { mat = "Neon", name = "Gill" }))
				else
					B:block(crop, v(0.32, 0.14, r1 - r0), q, GILL_DK)
				end
			end
			-- stepped dome: {radius factor, height, color, layer rotation}
			local L = {
				{ 0.92, 0.7, RED_DK, 0 },
				{ 0.84, 0.28 * H, RED, 45 },
				{ 0.68, 0.26 * H, RED, 0 },
				{ 0.46, 0.2 * H, RED_LT, 45 },
				{ 0.24, 0.12 * H, RED_HI, 0 },
			}
			local y0 = 0.5
			local s = math.clamp(0.36 * R, 1.05, 1.75)
			for j, l in L do
				local rr, h = R * l[1], l[2]
				local lc = c * CFrame.new(0, y0 + h / 2, 0) * ang(0, l[4], 0)
				round(crop, lc, rr, h, l[3])
				-- spots on the flat arm faces of this layer
				if j >= 2 and j <= 4 then
					local m = spotMask[j - 1]
					for k = 0, 3 do
						if string.sub(m, k + 1, k + 1) == "1" then
							local q = lc * CFrame.Angles(0, rad(k * 90), 0) * CFrame.new(rnd(-0.28, 0.28) * rr, rnd(-0.1, 0.1) * h, -rr - 0.07)
							local sz = s * rnd(0.85, 1.15)
							B:block(crop, v(sz, math.min(h - 0.12, sz * 0.85), 0.35), q, (k + j) % 4 == 0 and SPOT2 or SPOT)
						end
					end
				end
				y0 += h
			end
			-- big crown spot + two on the top ledge
			B:block(crop, v(R * 0.3, 0.3, R * 0.3), c * CFrame.new(0, y0, 0) * ang(0, 20, 0), SPOT)
			-- flat spots on the upper ledges (read from above)
			local yL3 = 0.5 + 0.7 + 0.28 * H + 0.26 * H
			for k = 0, 2 do
				local q = polar(c, 65 + k * 120 + rnd(-15, 15), yL3, R * 0.6)
				B:block(crop, v(s * 0.8, 0.3, s * 0.8), q * ang(0, rnd(0, 45), 0), SPOT)
			end
			return c, y0
		end

		local c1, top1 = cap(6.7, 5.4, 0, -3, 8, { "1011", "0110", "1101" })
		skirt(5.9, 0)
		local c2, top2 = cap(13.2, 4.0, 4, 3, 31, { "1101", "1010", "0111" })
		skirt(12.4, 0)
		local c3, top3 = cap(18.6, 3.1, -4, 4, 14, { "1010", "0101", "1000" })
		skirt(17.8, 0)

		---------------------------------------------------------------- shelf fungi on the stalk
		for _, s in { { 4.9, 140, 1.0 }, { 3.3, 300, 0.8 }, { 11.5, 60, 0.75 }, { 17.0, 220, 0.6 } } do
			local p, sr = stalkAt(s[1])
			local q = polar(CFrame.new(p), s[2], 0, sr - 0.1)
			local k = s[3]
			B:block(crop, v(1.9 * k, 0.4, 1.3 * k), q * CFrame.new(0, 0, -0.45 * k), SHELF_DK)
			B:block(crop, v(1.5 * k, 0.32, 1.0 * k), q * CFrame.new(0, 0.3, -0.35 * k), SHELF)
			B:block(crop, v(0.9 * k, 0.2, 0.5 * k), q * CFrame.new(0, 0.5, -0.4 * k), SHELF_LT)
		end

		---------------------------------------------------------------- briar vine spiralling up
		local prev = nil
		local vy0, vy1 = TOP + 0.6, 18.0
		local turns = 2.35
		local nSeg = 18
		for i = 0, nSeg do
			local t = i / nSeg
			local y = vy0 + (vy1 - vy0) * t
			local p, sr = stalkAt(y)
			local a = rad(200 + t * turns * 360)
			local pt = p + v(math.sin(a) * (sr + 0.2), 0, -math.cos(a) * (sr + 0.2))
			local function hid(yy)
				return (yy > 7.3 and yy < 10.6) or (yy > 13.8 and yy < 16.6)
			end
			local inCap = hid(y)
			if prev and not (hid(y) and hid(prev.Y)) then
				B:bar(crop, prev, pt, 0.46, 0.46, (i % 2 == 0) and VINE or VINE_DK)
				-- thorns
				if i % 2 == 1 then
					local out = v(math.sin(a), 0, -math.cos(a))
					local tp = pt + out * 0.32 + v(0, 0.05, 0)
					B:block(crop, v(0.26, 0.26, 0.55), lookAt(pt, tp + v(0, 0.25, 0)) * CFrame.new(0, 0, -0.25), THORN)
					B:block(crop, v(0.16, 0.16, 0.22), lookAt(pt, tp + v(0, 0.25, 0)) * CFrame.new(0, 0, -0.62), THORN_TIP)
				end
				-- leaves every few
				if i % 4 == 2 and not inCap then
					local out = v(math.sin(a), 0, -math.cos(a))
					local lp = pt + out * 0.55
					B:block(crop, v(0.8, 0.14, 0.55), lookAt(pt, lp) * CFrame.new(0, 0.1, -0.5) * ang(15, 90, 0), (i % 8 == 2) and VLEAF or VLEAF_DK)
				end
			end
			prev = pt
		end
		-- a few briar roses on the vine
		for _, rr in { { 4.4, 1 }, { 11.8, 2 }, { 17.2, 3 } } do
			local y = rr[1]
			local t = (y - vy0) / (vy1 - vy0)
			local p, sr = stalkAt(y)
			local a = rad(200 + t * turns * 360)
			local out = v(math.sin(a), 0, -math.cos(a))
			local pt = p + out * (sr + 0.55)
			local f = lookAt(pt, pt + out)
			B:block(crop, v(0.8, 0.8, 0.5), f, ROSE_DK)
			B:block(crop, v(0.62, 0.62, 0.3), f * CFrame.new(0, 0, -0.3) * ang(0, 0, 45), ROSE)
			B:block(crop, v(0.3, 0.3, 0.2), f * CFrame.new(0, 0, -0.45), "#ff7a92")
		end

		---------------------------------------------------------------- mushroom fruits
		local tips = {}
		local function fruit(base, k, tilt, ry)
			local f = CFrame.new(base) * ang(tilt[1], ry, tilt[2])
			B:block(crop, v(0.45 * k, 1.1 * k, 0.45 * k), f * CFrame.new(0, 0.5 * k, 0), STALK_LT)
			B:block(crop, v(1.25 * k, 0.45 * k, 1.25 * k), f * CFrame.new(0, 1.15 * k, 0), FR_DK)
			B:block(crop, v(1.0 * k, 0.4 * k, 1.0 * k), f * CFrame.new(0, 1.5 * k, 0) * ang(0, 45, 0), FR)
			B:block(crop, v(0.55 * k, 0.3 * k, 0.55 * k), f * CFrame.new(0, 1.8 * k, 0), FR_LT)
			local g = B:block(crop, v(0.24 * k, 0.12 * k, 0.24 * k), f * CFrame.new(0, 1.97 * k, 0) * ang(0, 45, 0), FR_GLOW, { mat = "Neon", name = "FruitGlow" })
			table.insert(tips, g)
		end
		local function capTopPoint(c, r, a, rr, yy)
			return (polar(c, a, yy, rr)).Position
		end
		-- on the lower caps' shoulders (sit on step 2 top)
		local function clusterOnCap(c, R, a, ks)
			local yLedge = 0.5 + 0.7 + 0.28 * 0.7 * R
			for j, k in ks do
				local q = polar(c, a + (j - 1) * 16, yLedge - 0.05, R * (0.79 - (j - 1) * 0.04))
				fruit(q.Position, k, { rnd(-10, 10), rnd(-10, 10) }, rnd(0, 90))
			end
		end
		clusterOnCap(c1, 5.4, 55, { 1.0, 0.7 })
		clusterOnCap(c1, 5.4, 200, { 0.85 })
		clusterOnCap(c1, 5.4, 300, { 0.95, 0.65 })
		clusterOnCap(c2, 4.0, 130, { 0.85, 0.6 })
		clusterOnCap(c2, 4.0, 330, { 0.75 })
		-- crown cluster on the very top
		local ctop = c3 * CFrame.new(0, top3 - 0.05, 0)
		fruit(ctop.Position, 1.05, { 0, 0 }, 20)
		fruit((ctop * CFrame.new(0.75, -0.2, 0.3)).Position, 0.6, { 0, -18 }, 50)
		fruit((ctop * CFrame.new(-0.6, -0.2, -0.5)).Position, 0.5, { 14, 16 }, 10)
		-- fruits sprouting from the mound around the stalk
		for _, m in { { 2.6, -1.9, 0.95 }, { 2.9, -1.3, 0.6 }, { -2.5, 1.6, 0.85 }, { -2.0, 2.3, 0.55 }, { -0.4, -3.1, 0.7 } } do
			local y = TOP - 0.05
			if math.sqrt(m[1] * m[1] + m[2] * m[2]) > 2.7 then y = 1.35 end
			fruit(v(m[1], y, m[2]), m[3], { rnd(-10, 10), rnd(-10, 10) }, rnd(0, 90))
		end

		---------------------------------------------------------------- vfx
		local cloud = B:block(crop, v(10, 14, 10), cf(0, 12, 0), RED, { tr = 1, name = "SporeCloud" })
		B:emitter(cloud, "sparkle", { name = "Spores", color = { GLOW, FR_LT }, rate = 6, size = { 0.15, 0.35, 0 }, speed = { 0.2, 0.6 }, life = { 1.6, 2.8 }, accel = { 0, 0.3, 0 } })
		B:emitter(gillParts[2], "glow", { name = "GillGlow", color = GLOW, rate = 2, size = 0.8 })
		B:emitter(tips[#tips - 5] or tips[1], "sparkle", { name = "FruitTwinkle", color = { "#ffffff", FR_GLOW }, rate = 3, size = 0.3 })
		local low = B:block(crop, v(9, 1, 9), cf(0, TOP + 0.5, 0), RED, { tr = 1, name = "SporeMotes" })
		B:emitter(low, "glow", { name = "SporeMotes", color = { "#b6ffd6", "#ffc4e0" }, rate = 1.5, size = { 0.3, 0.6, 0.2 }, speed = { 0.2, 0.6 }, accel = { 0, 0.5, 0 } })
		B:light(gillParts[4], { color = "#aaffd0", brightness = 1.2, range = 12, name = "GillLight" })
	end,
}
