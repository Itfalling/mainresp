--!nocheck
-- Snapjaw Durian Vine (Flytrap Stage plant #8, Divine).
-- A thick twin jungle liana braids up out of a stepped bog mound (moss pads,
-- stones, lily-pad puddle) and bursts into an umbrella crown of big drooping
-- jungle leaves. Big spiky yellow-green durians hang from the vine on stout
-- stalks (and one sits fat on the mound). Every durian is a little flytrap:
-- its two spiky halves are hinged at the back and gape open at the front,
-- with a pink-red lip, rows of cream teeth and juicy golden flesh peeking
-- out of the toothy seam (tiny gold neon shine). Gold sparkles, lime drool
-- dripping from one durian, soft golden light. No faces. Static prop.
return {
	DisplayName = "Snapjaw Durian Vine",
	Rarity = "Divine",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (bog / greenhouse family)
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local MUD = "#2e1d12"
		local MOSS, MOSS_DK, MOSS_LT = "#6cb337", "#4f8f2a", "#8fd04a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local BOG, BOG_LT = "#2f6a50", "#6fb58a"
		local PAD, PAD_DK = "#3caa3c", "#2a8a33"
		local REED, CATTAIL = "#7f8f3a", "#5a3a1e"
		local VINE_DK, VINE, VINE_LT = "#4a3820", "#644c2b", "#7d6236"
		local LEAF_DK, LEAF, LEAF_LT, RIB = "#1f6e2a", "#2f8f37", "#45ad44", "#8fd04a"
		local DUR_DK, DUR, DUR_LT = "#6c8f22", "#8fb52e", "#b3d04a"
		local SPIKE, SPIKE_DK = "#c9de62", "#5e7d1c"
		local RIM, INSIDE = "#c92a48", "#ff5c7c"
		local FLESH, FLESH_DK, FLESH_HI = "#ffc533", "#f0a21c", "#fff09a"
		local CREAM = "#fff4d2"
		local LIME = "#86ff3c"

		local seed = 8808
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
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
				local w, d = rnd(1.4, 2.2), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 6.0, DIRT_DK, 15, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.6, 4.1, DIRT, 10, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.4, 0.4, 2.5, DIRT_LT, 0, {}, 0)

		for _, m in { { 70, 5.9, 1.12, 2.2, MOSS }, { 140, 5.8, 1.1, 2.0, MOSS_DK }, { 215, 5.95, 1.1, 1.9, MOSS }, { 290, 5.8, 1.12, 2.1, MOSS_DK }, { 110, 4.0, 1.72, 1.6, MOSS_LT }, { 250, 4.05, 1.72, 1.5, MOSS } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], m[3], -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[4], 0.3, 1.3), c * ang(-12, 0, 0), m[5], S)
		end
		for _, s in { { 5.0, 1.0, 2.8, 0.9, 25, STONE }, { 5.6, 0.9, 1.7, 0.6, 10, STONE_LT }, { -5.2, 0.95, 2.4, 0.85, -20, STONE_DK }, { -1.8, 0.95, 5.6, 0.7, 40, STONE }, { 3.0, 1.75, 2.9, 0.6, 15, STONE_LT } } do
			B:block(soil, v(s[4] * 1.2, s[4], s[4]), cf(s[1], s[2], s[3], rnd(-10, 10), s[5], rnd(-10, 10)), s[6], S)
		end
		for _, g in { { 5.8, -0.6 }, { -4.2, 4.3 }, { 4.4, -4.2 } } do
			B:block(soil, v(0.4, 0.9, 0.4), cf(g[1], 0.95, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.3, 0.6, 0.3), cf(g[1] + 0.3, 0.9, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end
		-- bog puddle front-right
		local BC = v(2.2, 1.42, -3.3)
		B:block(soil, v(3.0, 0.3, 1.7), CFrame.new(BC + v(0, -0.12, 0)) * ang(0, 12, 0), BOG, S)
		B:block(soil, v(1.8, 0.28, 2.4), CFrame.new(BC + v(0.1, -0.16, -0.05)) * ang(0, 12, 0), BOG, S)
		B:block(soil, v(1.0, 0.1, 0.35), CFrame.new(BC + v(-0.4, 0.04, -0.3)) * ang(0, 12, 0), BOG_LT, S)
		B:block(soil, v(0.8, 0.45, 0.6), CFrame.new(BC + v(1.6, 0, -0.5)) * ang(0, 20, 0), MUD, S)
		B:block(soil, v(0.9, 0.1, 0.9), CFrame.new(BC + v(0.6, 0.06, -0.2)) * ang(0, 30, 0), PAD, S)
		B:block(soil, v(0.6, 0.1, 0.6), CFrame.new(BC + v(-0.8, 0.06, 0.35)) * ang(0, -20, 0), PAD_DK, S)
		B:block(soil, v(0.2, 1.9, 0.2), CFrame.new(BC + v(1.4, 0.95, 0.6)) * ang(0, 0, -8), REED, S)
		B:block(soil, v(0.35, 0.6, 0.35), CFrame.new(BC + v(1.53, 1.75, 0.6)) * ang(0, 0, -8), CATTAIL, S)

		---------------------------------------------------------------- vine
		local Y0 = 1.8
		local crop = B:bone("Crop", "Root", v(0, Y0, 0))
		-- root flare
		B:block(crop, v(3.4, 0.8, 3.4), cf(0, Y0 + 0.3, 0, 0, 15, 0), VINE_DK)
		B:block(crop, v(2.6, 0.8, 2.6), cf(0, Y0 + 1.0, 0, 0, 40, 0), VINE)
		-- twin liana braiding upward (bars overlap past their ends so joints stay solid)
		local function seg(a, b, w, col)
			local d = (b - a).Unit
			B:bar(crop, a - d * (w * 0.45), b + d * (w * 0.45), w, w, col)
		end
		local TOP = Y0 + 14.6
		local N = 9
		local strandPts = {}
		for s = 0, 1 do
			local pts = {}
			for j = 0, N do
				local t = j / N
				local th = rad(j * 62 + s * 180)
				local r = 0.95 - 0.25 * t
				table.insert(pts, v(math.sin(th) * r, Y0 + 0.9 + t * (TOP - Y0 - 0.9), -math.cos(th) * r))
			end
			for j = 1, N do
				local w = 1.5 - 0.55 * (j / N)
				seg(pts[j], pts[j + 1], w, (j + s) % 2 == 0 and VINE or VINE_LT)
			end
			strandPts[s] = pts
		end
		-- a few small vine leaves along the braid
		local function smallLeaf(p, a, up, len, col)
			local f = CFrame.new(p) * CFrame.Angles(0, -rad(a), 0) * CFrame.Angles(rad(up), 0, 0)
			B:block(crop, v(1.0, 0.25, len), f * CFrame.new(0, 0, -len / 2 - 0.3), col)
			B:block(crop, v(0.25, 0.3, len * 0.8), f * CFrame.new(0, 0.05, -len / 2 - 0.2), RIB)
		end
		smallLeaf(v(0.4, Y0 + 4.2, -0.6), -30, 18, 2.0, LEAF)
		smallLeaf(v(-0.6, Y0 + 6.4, 0.3), -120, 22, 1.8, LEAF_LT)
		smallLeaf(v(0.6, Y0 + 7.8, 0.4), 140, 20, 1.9, LEAF)
		smallLeaf(v(-0.4, Y0 + 3.0, 0.6), 200, 15, 1.7, LEAF_LT)
		-- curly tendrils
		local function tendril(p, a, col)
			local f = CFrame.new(p) * CFrame.Angles(0, -rad(a), 0)
			local q1 = (f * CFrame.new(0, 0.5, -1.1)).Position
			local q2 = (f * CFrame.new(0, 1.3, -1.3)).Position
			local q3 = (f * CFrame.new(0, 1.5, -0.7)).Position
			B:bar(crop, p, q1, 0.3, 0.3, col)
			B:bar(crop, q1, q2, 0.3, 0.3, col)
			B:bar(crop, q2, q3, 0.28, 0.28, col)
		end
		tendril(v(0.5, Y0 + 5.4, 0.2), 70, LEAF_LT)
		tendril(v(-0.4, Y0 + 9.6, -0.3), -110, LEAF_LT)

		---------------------------------------------------------------- crown
		local CY = TOP + 0.6
		B:block(crop, v(4.2, 4.2, 4.2), cf(0, CY + 1.4, 0, 10, 25, 8), LEAF)
		B:block(crop, v(3.3, 3.3, 3.3), cf(-1.7, CY + 0.6, 1.2, -14, 40, 12), LEAF_DK)
		B:block(crop, v(3.2, 3.2, 3.2), cf(1.8, CY + 0.7, -1.0, 16, -20, -12), LEAF_DK)
		B:block(crop, v(2.8, 2.8, 2.8), cf(0.3, CY + 3.0, 0.2, 20, 50, -14), LEAF_LT)
		-- big drooping jungle leaves radiating out (umbrella)
		local LEAVES = { { 0, LEAF }, { 52, LEAF_DK }, { 103, LEAF }, { 154, LEAF_LT }, { 206, LEAF }, { 257, LEAF_DK }, { 308, LEAF_LT } }
		for i, L in LEAVES do
			local a = rad(L[1] + 10)
			local dx, dz = math.sin(a), -math.cos(a)
			local len = (i % 2 == 0) and 1.0 or 0.92
			local p0 = v(dx * 1.4, CY + 1.0, dz * 1.4)
			local p1 = v(dx * 4.4 * len, CY + 1.9, dz * 4.4 * len)
			local p2 = v(dx * 7.0 * len, CY - 0.8, dz * 7.0 * len)
			B:bar(crop, p0, p1, 2.5, 0.45, L[2])
			B:bar(crop, p1 - (p1 - p0).Unit * 0.3, p2, 2.0, 0.45, L[2])
			B:bar(crop, p0 + v(0, 0.26, 0), p1 + v(0, 0.26, 0), 0.35, 0.2, RIB)
		end

		---------------------------------------------------------------- durians
		local mouths, shines = {}, {}
		-- c = center, k = scale, ry = facing (mouth toward local -Z), open = gape degrees
		local function durian(c, k, bias, open, stalkTo)
			-- mouth faces outward from the vine, nudged toward the front by `bias`
			local ry = math.deg(math.atan2(-c.X, -c.Z)) + bias
			local F = CFrame.new(c) * ang(0, ry, 0)
			local hz = 1.3 * k
			local Hb = F * CFrame.new(0, 0, hz)
			local U = Hb * ang(open * 0.7, 0, 0) * CFrame.new(0, 0, -hz)
			local Lo = Hb * ang(-open * 0.3, 0, 0) * CFrame.new(0, 0, -hz)
			local function bk(Fr, sx, sy, sz, x, y, z, col, rx, ry2, rz, opts)
				return B:block(crop, v(sx * k, sy * k, sz * k), Fr * CFrame.new(x * k, y * k, z * k) * ang(rx or 0, ry2 or 0, rz or 0), col, opts)
			end
			for _, sgn in { 1, -1 } do
				local Fr = sgn > 0 and U or Lo
				local col = sgn > 0 and DUR or DUR_DK
				-- stepped round half (octagon from a cross + square)
				bk(Fr, 3.0, 1.35, 2.0, 0, 0.82 * sgn, 0, col)
				bk(Fr, 2.0, 1.35 - 0.04, 3.0, 0, 0.82 * sgn, 0, col)
				bk(Fr, 2.65, 1.3, 2.65, 0, 0.84 * sgn, 0, sgn > 0 and DUR_LT or DUR)
				bk(Fr, 2.0, 0.5, 2.0, 0, 1.64 * sgn, 0, col)
				-- trap mouth: red rim plate + pink inner pad
				bk(Fr, 3.1, 0.24, 3.1, 0, 0.14 * sgn, 0, RIM)
				bk(Fr, 2.6, 0.12, 2.6, 0, 0.02 * sgn, -0.1, INSIDE)
				-- spikes: diamond nubs on the four faces
				for _, sp in { { 1.55, 0 }, { -1.55, 0 }, { 0, 1.55 }, { 0, -1.55 } } do
					bk(Fr, 0.62, 0.62, 0.62, sp[1], 0.88 * sgn, sp[2], sgn > 0 and SPIKE or DUR_LT, 45, 0, 45)
				end
				-- cream teeth along the front + front corners (rows offset so they interlock)
				local xs = sgn > 0 and { -1.05, -0.35, 0.35, 1.05 } or { -0.7, 0, 0.7 }
				for _, x in xs do
					bk(Fr, 0.3, 0.8, 0.3, x, -0.3 * sgn, -1.38, CREAM, 14 * sgn, 0, 0)
				end
				for _, sd in { -1, 1 } do
					bk(Fr, 0.3, 0.7, 0.3, sd * 1.38, -0.25 * sgn, sgn > 0 and -0.8 or -0.45, CREAM, 0, 0, -14 * sgn * sd)
				end
			end
			-- top: spike crown + cap; bottom nub
			for _, d in { { 0.75, 0.75 }, { -0.75, -0.75 } } do
				bk(U, 0.55, 0.55, 0.55, d[1], 1.9, d[2], SPIKE, 45, 0, 45)
			end
			bk(U, 0.9, 0.35, 0.9, 0, 1.99, 0, SPIKE_DK)
			bk(Lo, 0.62, 0.62, 0.62, 0, -1.9, 0, DUR_LT, 45, 0, 45)
			-- juicy golden flesh peeking out of the gaping seam
			local M = Hb * ang(open * 0.2, 0, 0) * CFrame.new(0, 0, -hz)
			bk(M, 2.4, 0.9, 2.3, 0, 0.05, 0.25, FLESH)
			bk(M, 1.0, 0.95, 0.95, -0.68, 0.12, -0.95, FLESH, 20, 30, 10)
			bk(M, 1.05, 1.0, 0.95, 0.05, 0.18, -1.05, FLESH_DK, -10, 20, 5)
			bk(M, 0.95, 0.9, 0.95, 0.72, 0.1, -0.92, FLESH, -15, 15, -10)
			local shine = bk(M, 0.45, 0.32, 0.45, -0.2, 0.62, -1.15, FLESH_HI, 10, 35, 0, { mat = "Neon", name = "DurianShine" .. (#shines + 1) })
			table.insert(shines, shine)
			table.insert(mouths, (M * CFrame.new(0, -0.2 * k, -1.4 * k)).Position)
			if stalkTo then
				local top = (U * CFrame.new(0, 2.05 * k, 0)).Position
				B:bar(crop, top - v(0, 0.3, 0), stalkTo, 0.55, 0.55, VINE)
				B:block(crop, v(0.8, 0.8, 0.8), CFrame.new(stalkTo), VINE_DK)
			end
		end
		local function vineAt(s, j)
			return strandPts[s][j]
		end
		durian(v(3.6, Y0 + 9.6, -1.4), 1.15, 25, 30, vineAt(0, 8) + v(0, 0.4, 0))
		durian(v(-3.4, Y0 + 11.0, 1.8), 1.0, -20, 26, vineAt(1, 9) + v(0, 0.2, 0))
		durian(v(-2.6, Y0 + 7.2, -2.6), 1.05, -10, 28, vineAt(1, 6))
		durian(v(2.2, Y0 + 6.4, 3.0), 0.9, 25, 26, vineAt(0, 5))
		-- the fat one resting on the mound, front-left
		durian(v(-2.9, Y0 + 1.25, -3.0), 1.3, -15, 30, nil)

		---------------------------------------------------------------- vfx
		local spark = B:block(crop, v(10, 8, 10), cf(0, Y0 + 9.5, 0), LEAF, { tr = 1, name = "GoldDust" })
		B:emitter(spark, "sparkle", { name = "GoldSparkle", color = { "#fff3a8", "#ffc533" }, rate = 6, size = { 0.15, 0.45, 0 } })
		local drool = B:block(crop, v(0.4, 0.2, 0.4), CFrame.new(mouths[1] + v(0, -0.6, 0)), LIME, { tr = 1, name = "DroolSpot" })
		B:emitter(drool, "drip", { name = "Drool", color = { LIME, "#c8ff7a" }, rate = 1.2, size = { 0.3, 0.25, 0.1 } })
		B:emitter(shines[5] or shines[1], "glow", { name = "FleshGlow", color = "#ffd65a", rate = 2, size = 0.8 })
		B:emitter(shines[1], "sparkle", { name = "FleshTwinkle", color = { "#ffffff", "#ffe27a" }, rate = 3, size = 0.35 })
		B:light(shines[5] or shines[1], { color = "#ffd36a", brightness = 1.2, range = 12, name = "DurianLight" })
	end,
}
