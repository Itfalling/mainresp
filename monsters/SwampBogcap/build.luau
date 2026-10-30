--!nocheck
-- Bogcap Cluster (Misty Swamp crop #3, Rare).
-- A tall cluster of five teal swamp mushrooms of different heights, each
-- stalk leaning a little outward from one mossy root clump. Every cap is a
-- stepped teal dome with chunky pale spots, lavender gills underneath and a
-- violet frill ring on the stalk; tattered swamp moss hangs from the rims.
-- Base: stepped dark swamp-mud mound with moss pads, a murky teal puddle with
-- lily pads, reeds + cattails, mossy stones and a few baby bogcaps.
-- Static prop: no motion.luau, no VFX (Rare tier).
return {
	DisplayName = "Bogcap Cluster",
	Rarity = "Rare",
	Element = "Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Misty Swamp)
		local MUD_DK, MUD_DK2, MUD, MUD_LT = "#2f2721", "#3a3028", "#4a3d30", "#5e4e3c"
		local MOSS, MOSS_DK, MOSS_LT = "#4f8a3c", "#356a2e", "#74ad4a"
		local WATER, WATER_LT, WATER_DK = "#2f7d73", "#57a89a", "#225a54"
		local PAD, PAD_DK, PAD_FL, PAD_FL_C = "#4f9e45", "#3a7d36", "#d9a8f0", "#fff0a8"
		local REED, REED_DK, CATTAIL = "#7a9a44", "#5b7a34", "#5a3a26"
		local STONE, STONE_LT, STONE_DK = "#66726c", "#84908a", "#4c5652"
		local CAP_DK, CAP, CAP_LT, CAP_HI = "#16736d", "#1f9a8f", "#33bcae", "#5fd8c6"
		local SPOT, SPOT2 = "#effff8", "#dccbf2"
		local GILL, GILL_DK = "#b9a3d8", "#6f4f99"
		local FRILL, FRILL_DK = "#9a78c8", "#7656a8"
		local STALK, STALK_LT, STALK_DK = "#dfe6d2", "#eef3e4", "#c3ccb2"
		local BEARD, BEARD_DK = "#5e8f3e", "#43702f"

		local seed = 1513
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function polar(c, a, y, r)
			-- frame inside c at angle a (deg), height y, radius r; local -Z points outward
			return c * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y, -r)
		end
		-- stepped "pixel circle" disc (3 parts)
		local function disc(bone, c, r, h, col, opts)
			B:block(bone, v(2 * r, h, 1.0 * r), c, col, opts)
			B:block(bone, v(1.0 * r, h - 0.04, 2 * r), c, col, opts)
			B:block(bone, v(1.6 * r, h - 0.08, 1.6 * r), c, col, opts)
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
		tier(0, 0.8, 6.0, MUD_DK, 13, { MUD_DK, MUD_DK2, MUD_DK }, 0.35)
		tier(0.8, 0.65, 4.2, MUD, 9, { MUD, MUD_LT, MUD_DK2 }, 0.3)
		tier(1.45, 0.45, 2.7, MUD_LT, 0, {}, 0)
		local TOP = 1.9

		-- moss pads draped over the tier edges
		for _, m in { { -20, 6.05, 1.12, 2.3, MOSS }, { 70, 6.0, 1.1, 2.0, MOSS_DK }, { 160, 6.1, 1.1, 2.2, MOSS }, { 250, 6.0, 1.12, 1.8, MOSS_DK }, { 30, 4.2, 1.77, 1.7, MOSS_LT }, { 120, 4.25, 1.77, 1.5, MOSS }, { 300, 4.2, 1.77, 1.6, MOSS } } do
			local c = polar(CFrame.new(), m[1], m[3], m[2])
			B:block(soil, v(m[4], 0.3, 1.3), c * ang(-12, 0, 0), m[5], S)
		end

		-- murky puddle on the front-left, set into the middle tier
		local pc = CFrame.new(-3.1, 1.86, -2.7) * ang(0, 35, 0)
		disc(soil, pc * CFrame.new(0, -0.22, 0), 2.05, 0.55, MUD_DK2, S)
		disc(soil, pc * CFrame.new(0, 0.05, 0), 1.75, 0.14, WATER, S)
		B:block(soil, v(1.2, 0.1, 0.35), pc * CFrame.new(0.4, 0.1, 0.5), WATER_LT, S)
		B:block(soil, v(0.7, 0.1, 0.3), pc * CFrame.new(-0.6, 0.1, -0.4), WATER_LT, S)
		B:block(soil, v(0.9, 0.1, 0.9), pc * CFrame.new(-0.3, 0.09, 0.6) * ang(0, 30, 0), WATER_DK, S)
		-- lily pads (a disc with a wedge-shaped notch faked by a dark water block)
		local function lily(c, r, flower)
			B:block(soil, v(1.9 * r, 0.12, 1.5 * r), c, PAD, S)
			B:block(soil, v(1.5 * r, 0.1, 1.9 * r), c, PAD_DK, S)
			B:block(soil, v(0.35 * r, 0.14, 0.8 * r), c * CFrame.new(0, 0.01, -0.6 * r), WATER, S)
			if flower then
				B:block(soil, v(0.7, 0.3, 0.7), c * CFrame.new(0.2, 0.18, 0.2) * ang(0, 45, 0), PAD_FL, S)
				B:block(soil, v(0.5, 0.3, 0.5), c * CFrame.new(0.2, 0.32, 0.2), PAD_FL, S)
				B:block(soil, v(0.22, 0.2, 0.22), c * CFrame.new(0.2, 0.48, 0.2), PAD_FL_C, S)
			end
		end
		lily(pc * CFrame.new(0.55, 0.16, -0.35) * ang(0, 20, 0), 0.75, true)
		lily(pc * CFrame.new(-0.75, 0.15, 0.25) * ang(0, 140, 0), 0.5, false)
		lily(cf(4.9, 0.86, -3.0, 0, 60, 0), 0.55, false)

		-- reeds + cattails at the back
		local function reed(x, z, y0, h, lean, cat)
			local a = v(x, y0, z)
			local b = a + v(lean[1], h, lean[2])
			B:bar(soil, a, b, 0.24, 0.24, (h > 2.6) and REED or REED_DK, S)
			if cat then
				local d = (b - a).Unit
				B:bar(soil, b - d * 0.2, b + d * 0.9, 0.42, 0.42, CATTAIL, S)
				B:bar(soil, b + d * 0.85, b + d * 1.3, 0.12, 0.12, REED_DK, S)
			end
		end
		reed(4.3, 2.8, 0.8, 3.4, { 0.3, 0.2 }, true)
		reed(4.8, 2.2, 0.8, 2.4, { 0.5, -0.1 }, false)
		reed(3.9, 3.5, 0.8, 2.0, { -0.1, 0.4 }, false)
		reed(-4.9, 2.0, 0.8, 2.8, { -0.4, 0.2 }, true)
		reed(-4.4, 2.9, 0.8, 2.0, { -0.2, 0.5 }, false)
		reed(-1.6, -4.4, 1.45, 2.2, { -0.2, -0.3 }, false)
		reed(-1.1, -4.6, 1.45, 1.6, { 0.2, -0.4 }, false)

		-- mossy stones
		for _, s in { { 5.0, 1.0, -0.4, 0.95, 25, STONE }, { 5.5, 0.85, 0.7, 0.6, 10, STONE_LT }, { -5.3, 0.95, -1.4, 0.85, -20, STONE_DK }, { 1.6, 1.0, 5.4, 0.8, 40, STONE }, { 3.0, 1.75, -2.9, 0.55, 15, STONE_LT } } do
			local st = B:block(soil, v(s[4] * 1.2, s[4], s[4]), cf(s[1], s[2], s[3], rnd(-10, 10), s[5], rnd(-10, 10)), s[6], S)
			if s[4] > 0.75 then
				B:block(soil, v(s[4] * 0.9, 0.2, s[4] * 0.7), st.CFrame * CFrame.new(0, s[4] / 2, 0), MOSS_LT, S)
			end
		end

		-- baby bogcaps poking out of the mud (decor)
		local function baby(x, y, z, k, ry)
			local f = cf(x, y, z, rnd(-8, 8), ry, rnd(-8, 8))
			B:block(soil, v(0.4 * k, 1.0 * k, 0.4 * k), f * CFrame.new(0, 0.5 * k, 0), STALK, S)
			B:block(soil, v(1.2 * k, 0.4 * k, 1.2 * k), f * CFrame.new(0, 1.05 * k, 0), CAP, S)
			B:block(soil, v(0.75 * k, 0.3 * k, 0.75 * k), f * CFrame.new(0, 1.35 * k, 0) * ang(0, 45, 0), CAP_LT, S)
			B:block(soil, v(0.3 * k, 0.12, 0.3 * k), f * CFrame.new(0.3 * k, 1.27 * k, -0.25 * k), SPOT, S)
		end
		baby(3.6, 1.42, 0.9, 0.9, 20)
		baby(-3.9, 1.42, 1.3, 0.8, 10)
		baby(0.6, 0.8, -5.3, 0.7, 30)
		baby(-5.4, 0.8, 0.0, 0.55, 60)

		---------------------------------------------------------------- mushrooms
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		-- mossy root clump that all stalks grow out of
		disc(crop, cf(0, TOP + 0.25, 0, 0, 10, 0), 2.3, 0.5, MOSS_DK)
		disc(crop, cf(0.2, TOP + 0.65, 0.1, 0, 40, 0), 1.6, 0.4, MOSS)
		for _, r in { 30, 140, 250, 330 } do
			local c = polar(CFrame.new(0, TOP, 0), r, 0.15, 2.45)
			B:block(crop, v(0.9, 0.5, 1.4), c * ang(-15, 0, 0), STALK_DK)
		end

		-- stalk from base a to cap point b, bending through m; width w0 -> w1
		local function stalk(a, m, b, w0, w1)
			local wm = (w0 + w1) / 2
			for k, seg in { { a, m, w0, wm }, { m, b, wm, w1 } } do
				local p, q, wa, wb = seg[1], seg[2], seg[3], seg[4]
				local d = (q - p).Unit
				local w = (wa + wb) / 2
				local col = (k == 1) and STALK or STALK_LT
				B:bar(crop, p - d * 0.25, q + d * 0.25, w, w, col, { up = v(1, 0, 0) })
				B:bar(crop, p - d * 0.2, q + d * 0.2, w * 0.86, w * 0.86, col, { up = v(1, 0, 1).Unit })
			end
			-- darker fleck stripes for texture
			local d = (b - m).Unit
			B:bar(crop, m + d * 0.4 + v(0, 0, -w1 * 0.42), m + d * 1.6 + v(0, 0, -w1 * 0.42), 0.22, 0.5, STALK_DK)
			-- moss sock creeping up from the root clump
			B:bar(crop, a - v(0, 0.1, 0), a + (m - a).Unit * 1.3, w0 + 0.14, w0 + 0.14, MOSS_DK, { up = v(1, 0, 0) })
		end

		-- frilly violet ring on the stalk just under the cap
		local function frill(p, w, d)
			local c = CFrame.new(p) * ang(0, 22, 0)
			B:block(crop, v(w + 0.7, 0.3, w + 0.7), c, FRILL)
			for i = 0, 3 do
				local q = polar(c, i * 90 + 45, -0.3, (w + 0.7) * 0.5)
				B:block(crop, v(0.8, 0.55, 0.28), q * ang(-14, 0, 0), (i % 2 == 0) and FRILL_DK or FRILL)
			end
		end

		-- stepped dome cap. c = frame at the gill plane (tilted with the stalk)
		local function cap(c, R, spotMask, beards, nLayers)
			local s = R / 3
			-- gills underneath
			disc(crop, c * CFrame.new(0, 0.12, 0), R * 0.86, 0.26, GILL)
			for i = 0, 3 do
				local q = polar(c, i * 90 + 30, 0.0, R * 0.52)
				B:block(crop, v(0.2, 0.08, R * 0.6), q, GILL_DK)
			end
			local layers = {
				{ 1.0, 0.55, CAP_DK, 0 },
				{ 0.9, 0.6, CAP, 45 },
				{ 0.74, 0.55, CAP, 0 },
				{ 0.54, 0.5, CAP_LT, 45 },
				{ 0.3, 0.4, CAP_HI, 0 },
			}
			local y = 0.22
			for j = 1, nLayers do
				local l = layers[j]
				local rr, h = R * l[1], l[2] * s * (nLayers == 5 and 1 or 1.15)
				local lc = c * CFrame.new(0, y + h / 2, 0) * ang(0, l[4] + 10, 0)
				disc(crop, lc, rr, h, l[3])
				-- chunky spots on the flat arm faces of this layer
				local m = spotMask[j]
				if m then
					for k = 0, 3 do
						if string.sub(m, k + 1, k + 1) == "1" then
							local q = lc * CFrame.Angles(0, rad(k * 90), 0) * CFrame.new(rnd(-0.22, 0.22) * rr, 0, -rr - 0.08)
							local sz = math.clamp(0.42 * R, 0.6, 1.4) * rnd(0.85, 1.1)
							B:block(crop, v(sz, math.min(h - 0.1, sz * 0.8), 0.35), q, ((k + j) % 3 == 0) and SPOT2 or SPOT)
						end
					end
				end
				y += h
				if j == 3 and nLayers == 5 then
					-- flat spots on the ledge of layer 3 (read from above)
					for k = 0, 2 do
						local q = polar(c, 40 + k * 120 + rnd(-15, 15), y + 0.02, R * 0.64)
						local sz = math.clamp(0.36 * R, 0.6, 1.2)
						B:block(crop, v(sz, 0.26, sz), q * ang(0, rnd(0, 45), 0), (k == 1) and SPOT2 or SPOT)
					end
				end
			end
			-- crown spot
			B:block(crop, v(R * 0.3, 0.24, R * 0.3), c * CFrame.new(0, y, 0) * ang(0, 30, 0), SPOT)
			-- hanging swamp moss beards from the rim (vertical, world space)
			for _, bd in beards do
				local rim = polar(c, bd[1], 0.2, R * 0.82).Position
				local L = bd[2]
				B:block(crop, v(0.4, L, 0.4), CFrame.new(rim - v(0, L / 2 - 0.2, 0)) * ang(0, bd[1], 0), BEARD)
				B:block(crop, v(0.28, L * 0.55, 0.28), CFrame.new(rim - v(0, L + L * 0.2 - 0.2, 0) + v(0.06, 0, 0)) * ang(0, bd[1], 0), BEARD_DK)
			end
			return y
		end

		-- {base, bend, capPoint, w0, w1, R, tiltX, tiltZ, spots, beards, layers, frill}
		local shrooms = {
			{ v(0.2, TOP + 0.4, 0.3), v(0.5, 8.0, 0.1), v(-0.1, 13.4, -0.1), 1.75, 1.35, 3.4, -4, 5, { "1011", "0110", "1101", "0010" }, { { 30, 1.8 }, { 150, 1.2 }, { 260, 2.1 }, { 330, 1.0 } }, 5, true },
			{ v(1.1, TOP + 0.4, -0.6), v(2.3, 6.0, -1.2), v(3.6, 9.9, -1.6), 1.35, 1.05, 2.5, -12, -14, { "1101", "1010", "0100" }, { { 70, 1.4 }, { 200, 0.9 } }, 5, true },
			{ v(-1.0, TOP + 0.4, 0.8), v(-2.2, 5.3, 1.5), v(-3.4, 8.3, 1.9), 1.3, 1.0, 2.3, 5, 12, { "0111", "1001", "0010" }, { { 120, 1.3 }, { 290, 1.0 } }, 5, true },
			{ v(-0.9, TOP + 0.3, -1.1), v(-1.6, 3.6, -2.1), v(-2.3, 5.4, -3.0), 1.0, 0.85, 1.65, -16, 12, { "1010", "0101" }, { { 200, 0.8 } }, 4, false },
			{ v(1.1, TOP + 0.3, 1.2), v(1.8, 3.4, 2.1), v(2.6, 4.6, 2.9), 0.95, 0.8, 1.4, 16, -14, { "0110", "1001" }, {}, 4, false },
		}
		for i, m in shrooms do
			local a, mid, b = m[1], m[2], m[3]
			stalk(a, mid, b, m[4], m[5])
			local d = (b - mid).Unit
			local c = CFrame.new(b - d * 0.2) * ang(m[7], i * 23, m[8])
			if m[12] then
				frill(b - d * 1.35, m[5], d)
			end
			cap(c, m[6], m[9], m[10], m[11])
		end
	end,
}
