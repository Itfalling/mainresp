--!nocheck
-- Cinder Plum Deadtree (Bramble Badlands crop #5, Legendary).
-- A gnarled, twisted dead tree in the stud-plant style:
-- * stepped badlands mound (bone "Soil"): charcoal rock base, cracked rust-red
--   earth tier and an ash-grey top, glowing lava cracks, dino bone fragments,
--   a little fossil shell, obsidian shards with purple glints, ash piles
-- * a twisted charcoal trunk with spiral bark ridges and glowing lava fissures,
--   flared roots, and crooked leafless branches forking up and out
-- * cinder plums hang from the branches: chunky deep-plum fruits dusted with
--   ash on top, split by glowing ember seams
-- Rising embers, drifting ash flakes, warm plum glow, a smoking lava crack and
-- two soft lights. Static prop: no motion.luau.
return {
	DisplayName = "Cinder Plum Deadtree",
	Rarity = "Legendary",
	Element = "Fire",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Bramble Badlands) --------------------------------------
		local RK_XD, RK_DK, RK, RK_LT = "#241e22", "#3a3236", "#4a4044", "#625758"
		local RUST_DK, RUST, RUST_LT = "#7a3524", "#94452c", "#b05a36"
		local ASH_DK, ASH, ASH_LT = "#6c6662", "#88827c", "#a7a19a"
		local BONE, BONE_DK, BONE_SH = "#f1e4c4", "#d9c79e", "#bfa97f"
		local OBS, OBS_PU = "#2a2134", "#8a5cc0"
		local LAVA, LAVA_Y = "#ff7a1a", "#ffb43a"
		local BARK_XD, BARK_DK, BARK, BARK_LT = "#2e2526", "#45383a", "#5e4d4a", "#87756a"
		local PL_DK, PL, PL_LT, PL_HI = "#4a1a55", "#66287a", "#7e3592", "#b46ad0"
		local PL_ASH = "#9a948f"
		local LEAF_DRY, LEAF_RUST = "#8a5a32", "#a8562c"

		local seed = 51723
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function pick(t)
			return t[math.floor(rnd() * #t) + 1]
		end
		local function polar(r, deg)
			local a = rad(deg)
			return math.sin(a) * r, -math.cos(a) * r
		end
		local function pv(r, deg, y)
			local x, z = polar(r, deg)
			return v(x, y, z)
		end
		local function facing(p, deg)
			return CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
		end

		------------------------------------------------------------------
		-- STEPPED BADLANDS MOUND (bone "Soil", parts named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local SN = { name = "Soil", mat = "Neon" }
		local function disc(y0, h, r, col)
			B:block(soil, v(2 * r, h, 1.15 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.15 * r, h - 0.02, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.04, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
		end
		local function edge(y0, h, r, n, cols, eh, wr, dr)
			for i = 0, n - 1 do
				local a = (i + jit(0.2)) / n * 360
				local w, d = wr[1] + rnd() * (wr[2] - wr[1]), dr[1] + rnd() * (dr[2] - dr[1])
				local hh = h + rnd() * eh - 0.05
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + hh / 2, -(r + jit(0.2)))
				B:block(soil, v(w, hh, d), p * ang(jit(4), jit(10), jit(4)), pick(cols), S)
			end
		end
		disc(0, 0.9, 6.6, RK_DK)
		edge(0, 0.9, 6.6, 17, { RK_DK, RK, RK_XD, RK }, 0.5, { 1.6, 2.5 }, { 1.3, 1.8 })
		disc(0.9, 0.7, 5.0, RUST)
		edge(0.9, 0.7, 5.05, 13, { RUST, RUST_DK, RUST_LT }, 0.35, { 1.5, 2.2 }, { 1.2, 1.6 })
		disc(1.6, 0.55, 3.4, ASH_DK)
		edge(1.6, 0.55, 3.45, 9, { ASH_DK, ASH, ASH_DK }, 0.25, { 1.3, 1.9 }, { 1.0, 1.4 })
		local TOP = 2.15

		-- glowing lava cracks: dark groove + thin neon vein, zig-zag
		local function crack(pts, y)
			for i = 1, #pts - 1 do
				local a, b = pts[i], pts[i + 1]
				B:bar(soil, v(a[1], y, a[2]), v(b[1], y, b[2]), 0.75, 0.12, RK_XD, S)
				B:bar(soil, v(a[1], y + 0.05, a[2]), v(b[1], y + 0.05, b[2]), 0.32, 0.12, (i % 2 == 0) and LAVA_Y or LAVA, SN)
			end
		end
		local function crackPts(deg, r0, r1, n, wob)
			local pts = {}
			for i = 0, n do
				local r = r0 + (r1 - r0) * i / n
				local x, z = polar(r, deg + ((i % 2 == 0) and -wob or wob))
				table.insert(pts, { x, z })
			end
			return pts
		end
		crack(crackPts(150, 3.6, 4.8, 2, 7), 1.62)
		crack(crackPts(150, 5.15, 6.4, 2, 5), 0.92)
		crack(crackPts(255, 3.6, 4.8, 2, 8), 1.62)
		crack(crackPts(40, 5.15, 6.4, 2, 6), 0.92)
		crack(crackPts(330, 3.6, 4.8, 2, 7), 1.62)
		-- cracks across the ash top and arcs around the dark rock rim
		crack(crackPts(60, 1.9, 3.2, 2, 10), TOP + 0.02)
		crack(crackPts(290, 1.9, 3.2, 2, 9), TOP + 0.02)
		local function arc(d0, d1, r, n, y)
			local pts = {}
			for i = 0, n do
				local x, z = polar(r + ((i % 2 == 0) and -0.2 or 0.2), d0 + (d1 - d0) * i / n)
				table.insert(pts, { x, z })
			end
			crack(pts, y)
		end
		arc(-30, 15, 5.8, 3, 0.92)
		arc(95, 140, 5.85, 3, 0.92)
		arc(200, 240, 5.8, 3, 0.92)
		-- vertical drips of lava down the tier walls
		for _, d in { { 150, 5.05, 1.25, 0.7 }, { 40, 6.65, 0.45, 0.8 }, { 255, 5.05, 1.25, 0.65 } } do
			local x, z = polar(d[2], d[1])
			B:block(soil, v(0.24, d[4], 0.24), facing(v(x, d[3], z), d[1]) * CFrame.new(0, 0, -0.05), LAVA, SN)
		end
		-- smoking lava vent (the crack's source) on the ash tier
		local vent = pv(2.6, 205, TOP)
		B:block(soil, v(1.4, 0.3, 1.2), facing(vent + v(0, 0.05, 0), 205), RK_XD, S)
		local ventGlow = B:block(soil, v(0.7, 0.2, 0.55), facing(vent + v(0, 0.17, 0), 205), LAVA_Y, { name = "VentGlow", mat = "Neon" })
		B:block(soil, v(0.6, 0.45, 0.6), facing(vent + v(0.75, 0.2, 0.1), 225), RK, S)
		B:block(soil, v(0.5, 0.35, 0.5), facing(vent + v(-0.6, 0.15, 0.45), 190), RK_LT, S)

		-- rocks
		for _, s in { { 5.3, 1.2, 2.9, 1.15, 25, RK }, { 6.1, 1.0, 1.4, 0.7, 10, RK_LT }, { -5.5, 1.1, -2.6, 1.05, -20, RK_DK }, { -4.6, 1.75, 2.4, 0.75, 30, RK_LT }, { 1.6, 1.0, 6.1, 0.8, 5, RK } } do
			B:block(soil, v(s[4] * 1.35, s[4], s[4] * 1.05), cf(s[1], s[2], s[3], jit(6), s[5], jit(6)), s[6], S)
		end
		-- obsidian shards with purple glints
		for _, o in { { -5.9, 0.9, 0.9, 1.6, 10 }, { 3.0, 1.6, -4.1, 1.3, -15 }, { 4.3, 0.9, 4.9, 1.1, 20 } } do
			local base = cf(o[1], o[2], o[3], jit(10), o[5], jit(12))
			B:block(soil, v(0.7, o[4], 0.6), base * CFrame.new(0, o[4] / 2, 0), OBS, S)
			B:block(soil, v(0.42, 0.5, 0.36), base * CFrame.new(0, o[4] + 0.2, 0), OBS_PU, S)
			B:block(soil, v(0.5, o[4] * 0.6, 0.45), base * CFrame.new(0.5, o[4] * 0.3, 0.15) * ang(0, 0, -14), OBS, S)
		end
		-- dino bone fragment (shaft + knobbly ends)
		local function bone(c, len, s)
			B:block(soil, v(len, 0.38 * s, 0.38 * s), c, BONE, S)
			for sg = -1, 1, 2 do
				B:block(soil, v(0.45 * s, 0.55 * s, 0.75 * s), c * CFrame.new(sg * len / 2, 0.02, 0.17 * s), BONE, S)
				B:block(soil, v(0.45 * s, 0.55 * s, 0.6 * s), c * CFrame.new(sg * len / 2, 0.0, -0.22 * s), BONE_DK, S)
			end
		end
		bone(cf(-2.2, 1.78, -4.4, 0, 28, 0), 1.9, 1)
		bone(cf(5.6, 1.1, -1.9, 0, -70, 6), 1.4, 0.85)
		-- loose vertebra + tooth
		B:block(soil, v(0.7, 0.5, 0.7), cf(-3.6, 1.82, 3.0, 0, 20, 0), BONE, S)
		B:block(soil, v(0.3, 0.6, 0.3), cf(-3.6, 2.2, 3.0, 0, 20, 0), BONE_DK, S)
		B:block(soil, v(0.35, 0.55, 0.3), cf(2.3, 2.42, 2.2, 8, 30, 12), BONE, S)
		-- fossil shell (stepped spiral) leaning on the mound
		local fos = cf(-6.1, 1.4, -1.6, 0, 70, -6)
		B:block(soil, v(0.35, 1.4, 1.4), fos, BONE_DK, S)
		B:block(soil, v(0.4, 1.0, 1.0), fos * CFrame.new(-0.04, 0.05, 0.05), BONE, S)
		B:block(soil, v(0.45, 0.5, 0.5), fos * CFrame.new(-0.06, 0.15, 0.15), BONE_SH, S)
		-- ash piles + pebbles
		for _, a in { { 1.8, -2.5 }, { -2.4, -1.2 }, { 0.6, 2.8 }, { -4.3, -3.9 }, { 4.1, 3.0 } } do
			local y = (math.sqrt(a[1] * a[1] + a[2] * a[2]) < 3.3) and TOP or 1.6
			B:block(soil, v(1.0, 0.18, 0.8), cf(a[1], y + 0.05, a[2], 0, jit(40), 0), ASH_LT, S)
			B:block(soil, v(0.5, 0.18, 0.45), cf(a[1] + 0.1, y + 0.18, a[2], 0, jit(40), 0), ASH_LT, S)
		end
		for _, p in { { 4.9, -3.8, RK_LT }, { -1.4, -6.0, ASH }, { -5.2, 4.0, RK_LT }, { 6.0, -0.2, ASH } } do
			B:block(soil, v(0.5, 0.32, 0.42), cf(p[1], 0.98, p[2], 0, jit(40), 0), p[3], S)
		end

		------------------------------------------------------------------
		-- TWISTED DEAD TREE (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		-- a twisted limb segment: two bars rolled 45 deg against each other
		local function limb(a, b, w, c1, c2, roll)
			local d = (b - a).Unit
			local side = d:Cross(v(0, 1, 0))
			if side.Magnitude < 0.1 then
				side = v(1, 0, 0)
			end
			side = side.Unit
			local up0 = d:Cross(side).Unit
			local r = rad(roll or 0)
			local up1 = up0 * math.cos(r) + side * math.sin(r)
			local up2 = up0 * math.cos(r + rad(45)) + side * math.sin(r + rad(45))
			B:bar(crop, a, b, w, w, c1, { up = up1 })
			if c2 then
				B:bar(crop, a + d * 0.08, b - d * 0.08, w * 0.9, w * 0.9, c2, { up = up2 })
			end
		end

		-- roots flaring over the mound
		for i, r in { { 20, 3.6, 1.35 }, { 95, 3.3, 1.5 }, { 165, 3.8, 1.35 }, { 240, 3.4, 1.4 }, { 310, 3.7, 1.45 } } do
			local a0 = pv(0.6, r[1], TOP + 0.9)
			local a1 = pv(2.2, r[1] + 12, TOP + 0.15)
			local a2 = pv(r[2], r[1] + 22, 1.75)
			local a3 = pv(r[2] + 1.2, r[1] + 28, 1.1)
			limb(a0, a1, 1.05, BARK_DK, BARK, i * 30)
			B:bar(crop, a1, a2, 0.8, 0.7, (i % 2 == 0) and BARK or BARK_DK)
			B:bar(crop, a2 - (a2 - a1).Unit * 0.2, a3, 0.55, 0.5, BARK_XD)
		end

		-- trunk: twisting polyline
		local T = {
			v(0, TOP - 0.3, 0),
			v(0.6, 5.2, 0.3),
			v(-0.55, 8.2, -0.2),
			v(0.45, 10.8, 0.35),
			v(-0.05, 13.0, 0.0),
		}
		local TW = { 2.9, 2.4, 1.95, 1.55 }
		for i = 1, #T - 1 do
			limb(T[i], T[i + 1] + (T[i + 1] - T[i]).Unit * 0.25, TW[i], (i % 2 == 1) and BARK_DK or BARK, (i % 2 == 1) and BARK or BARK_DK, i * 25)
			-- knot / burl at each joint
			if i > 1 then
				B:block(crop, v(TW[i] + 0.3, 0.7, TW[i] + 0.3), CFrame.new(T[i]) * ang(0, i * 37, 0), BARK_LT)
			end
		end
		-- spiral bark ridges (light) winding up the trunk
		for k = 0, 7 do
			local y0 = 2.6 + k * 1.2
			local a0 = k * 52
			local i = (y0 < 5.2) and 1 or ((y0 < 8.2) and 2 or 3)
			local tw = TW[i]
			local f = (y0 - T[i].Y) / (T[i + 1].Y - T[i].Y)
			local ctr = T[i]:Lerp(T[i + 1], f)
			local p0 = ctr + pv(tw * 0.62, a0, 0)
			local p1 = ctr + pv(tw * 0.58, a0 + 40, 1.3)
			B:bar(crop, p0, p1, 0.4, 0.35, (k % 3 == 0) and BARK_LT or BARK_XD)
		end
		-- glowing lava fissures in the bark
		local fis = {}
		for _, f in { { 3.2, 200, 1.6 }, { 6.2, 20, 1.5 }, { 9.3, 130, 1.3 }, { 4.6, 95, 1.4 }, { 7.6, 270, 1.3 } } do
			local y = f[1]
			local i = (y < 5.2) and 1 or ((y < 8.2) and 2 or 3)
			local ctr = T[i]:Lerp(T[i + 1], (y - T[i].Y) / (T[i + 1].Y - T[i].Y))
			local r = TW[i] * 0.58
			local a = ctr + pv(r, f[2], 0)
			local b = ctr + pv(r, f[2] + 18, f[3])
			B:bar(crop, a, b, 0.62, 0.3, BARK_XD)
			table.insert(fis, B:bar(crop, a + (a - ctr).Unit * 0.08, b + (b - ctr).Unit * 0.08, 0.3, 0.2, LAVA, { mat = "Neon", name = "BarkFissure" }))
		end
		-- hollow knot hole with an ember glow
		local hole = T[2]:Lerp(T[3], 0.45)
		local holeOut = pv(1.0, 340, 0)
		B:block(crop, v(1.0, 1.3, 0.4), facing(hole + holeOut * 1.05, 340), BARK_XD)
		B:block(crop, v(0.5, 0.6, 0.2), facing(hole + holeOut * 1.22, 340), LAVA, { mat = "Neon", name = "KnotGlow" })
		B:block(crop, v(1.4, 0.35, 0.45), facing(hole + holeOut * 1.0 + v(0, 0.8, 0), 340), BARK_LT)

		-- branches: polylines {start, points..., widths}
		local hangs = {}
		local function branch(pts, w0, w1, hangAt, twigs)
			local n = #pts - 1
			for i = 1, n do
				local w = w0 + (w1 - w0) * (i - 1) / math.max(n - 1, 1)
				local a, b = pts[i], pts[i + 1]
				local ext = (b - a).Unit * math.min(w * 0.35, 0.35)
				limb(a, b + ext, w, (i % 2 == 1) and BARK or BARK_LT, (w > 0.7) and BARK_DK or nil, i * 40)
			end
			-- dead twig tip
			local tip, prev = pts[#pts], pts[#pts - 1]
			local d = (tip - prev).Unit
			local te = tip + d * 0.9 + v(0, 0.35, 0)
			B:bar(crop, tip - d * 0.15, te, 0.36, 0.36, BARK_LT)
			B:block(crop, v(0.42, 0.42, 0.42), CFrame.new(te) * ang(30, 45, 0), LAVA, { mat = "Neon", name = "EmberTip" })
			for _, tw in twigs or {} do
				local base = pts[tw[1]]:Lerp(pts[tw[1] + 1], tw[2])
				B:bar(crop, base, base + tw[3], 0.35, 0.35, BARK_DK)
				local te = base + tw[3] * 1.35 + v(0, 0.3, 0)
				B:bar(crop, base + tw[3] * 0.92, te, 0.26, 0.26, BARK_LT)
				B:block(crop, v(0.32, 0.32, 0.32), CFrame.new(te) * ang(30, 45, 0), LAVA_Y, { mat = "Neon", name = "EmberTip" })
			end
			for _, h in hangAt or {} do
				table.insert(hangs, { pts[h[1]]:Lerp(pts[h[1] + 1], h[2]), h[3] or 1.0, h[4] or 1.1 })
			end
		end

		-- low right
		branch({ T[3] + v(0.5, 0.1, 0), v(2.6, 9.4, -0.6), v(4.6, 10.1, -1.0), v(6.0, 11.9, -1.3), v(6.5, 13.6, -1.1) }, 1.3, 0.5,
			{ { 2, 0.4, 1.0, 1.3 }, { 3, 0.7, 0.9, 0.8 } }, { { 2, 0.7, v(1.0, -0.2, 1.6) } })
		-- low left
		branch({ T[3] + v(-0.5, 0.4, 0.1), v(-2.6, 10.1, 0.7), v(-4.6, 11.1, 1.2), v(-5.8, 13.2, 1.0), v(-6.1, 14.9, 0.6) }, 1.3, 0.5,
			{ { 2, 0.5, 1.0, 1.4 }, { 3, 0.75, 0.85, 0.8 } }, { { 2, 0.4, v(-0.6, 0.2, -1.8) } })
		-- mid front
		branch({ T[4] + v(0, 0, -0.4), v(0.8, 12.2, -2.4), v(1.5, 13.6, -4.2), v(1.0, 15.6, -5.0) }, 1.15, 0.5,
			{ { 2, 0.55, 1.05, 1.2 } }, { { 2, 0.5, v(-1.6, 0.6, -0.6) } })
		-- mid back
		branch({ T[4] + v(0, 0, 0.4), v(-0.7, 12.6, 2.6), v(-1.4, 14.2, 4.3), v(-0.8, 16.2, 5.0) }, 1.15, 0.5,
			{ { 2, 0.6, 0.95, 1.0 }, { 3, 0.5, 0.8, 0.8 } }, { { 2, 0.4, v(1.7, 0.4, 0.5) } })
		-- high right back
		branch({ T[5] + v(0.3, -0.4, 0.2), v(2.4, 14.1, 1.2), v(4.1, 15.9, 2.0), v(4.7, 17.9, 1.6) }, 1.0, 0.45,
			{ { 2, 0.45, 0.9, 1.0 } }, { { 2, 0.5, v(1.4, 0.8, -0.8) } })
		-- high left front
		branch({ T[5] + v(-0.3, -0.3, -0.2), v(-2.3, 14.4, -1.6), v(-3.9, 16.2, -2.9), v(-4.3, 18.0, -3.2) }, 1.0, 0.45,
			{ { 2, 0.4, 0.9, 1.0 } }, { { 2, 0.55, v(-1.3, 0.9, 0.9) } })
		-- leader: crown with a fork
		branch({ T[5], v(0.5, 14.9, -0.3), v(-0.2, 16.7, 0.3), v(0.4, 18.4, 0.0) }, 1.2, 0.6,
			{ { 2, 0.5, 1.1, 1.1 } }, { { 3, 0.3, v(1.6, 1.0, 0.6) }, { 3, 0.6, v(-1.4, 0.9, -0.7) } })

		-- a few curled dry leaves clinging on
		for _, l in { { v(6.0, 12.4, -1.2), 30 }, { v(-5.7, 13.0, 1.0), -40 }, { v(-1.3, 14.6, 4.3), 60 } } do
			B:block(crop, v(0.7, 0.18, 0.5), CFrame.new(l[1] + v(0.3, -0.1, 0)) * ang(20, l[2], 35), LEAF_RUST)
			B:block(crop, v(0.45, 0.16, 0.35), CFrame.new(l[1] + v(-0.2, 0.05, 0.25)) * ang(-15, l[2] + 50, -25), LEAF_DRY)
		end

		------------------------------------------------------------------
		-- CINDER PLUMS
		------------------------------------------------------------------
		local glowPlums = {}
		local function plum(top, s, stemLen, yaw)
			local c = top - v(0, stemLen + 0.85 * s, 0)
			local o = CFrame.new(c) * ang(jit(6), yaw, jit(6))
			B:bar(crop, top + v(0, 0.2, 0), c + v(0, 0.7 * s, 0), 0.22, 0.22, BARK_DK)
			B:block(crop, v(1.5, 1.6, 1.5) * s, o, PL)
			B:block(crop, v(1.85, 1.15, 1.15) * s, o, PL_DK)
			B:block(crop, v(1.15, 1.15, 1.85) * s, o, PL_LT)
			B:block(crop, v(1.05, 0.3, 1.05) * s, o * CFrame.new(0, 0.86 * s, 0), PL_ASH)
			B:block(crop, v(0.85, 0.3, 0.85) * s, o * CFrame.new(0, -0.88 * s, 0), PL_DK)
			-- shine on the shoulder
			B:block(crop, v(0.35, 0.45, 0.12) * s, o * CFrame.new(-0.4 * s, 0.35 * s, -0.94 * s), PL_HI)
			-- ember seams (front + right side), glowing core at the bottom
			local SEAM = { mat = "Neon", name = "PlumSeam" }
			B:block(crop, v(0.24, 1.2, 0.1) * s, o * CFrame.new(0.18 * s, -0.05 * s, -0.94 * s), LAVA, SEAM)
			B:block(crop, v(0.1, 0.2, 0.8) * s, o * CFrame.new(0.94 * s, 0.12 * s, 0.05 * s), LAVA, SEAM)
			B:block(crop, v(0.1, 0.9, 0.22) * s, o * CFrame.new(0.94 * s, -0.15 * s, 0.38 * s), LAVA_Y, SEAM)
			B:block(crop, v(0.1, 1.0, 0.22) * s, o * CFrame.new(-0.94 * s, -0.1 * s, -0.25 * s), LAVA, SEAM)
			B:block(crop, v(0.22, 0.9, 0.1) * s, o * CFrame.new(-0.3 * s, -0.12 * s, 0.94 * s), LAVA, SEAM)
			local core = B:block(crop, v(0.5, 0.18, 0.5) * s, o * CFrame.new(0, -1.08 * s, 0), LAVA_Y, { mat = "Neon", name = "PlumCore" })
			-- a dry leaf on the stem
			if #glowPlums % 2 == 0 then
				B:block(crop, v(0.6, 0.14, 0.34) * s, CFrame.new(top - v(0, stemLen * 0.45, 0)) * ang(0, yaw + 40, 30) * CFrame.new(0.3, 0, 0), LEAF_RUST)
			end
			table.insert(glowPlums, core)
		end
		for i, h in hangs do
			plum(h[1] - v(0, 0.25, 0), h[2] * 1.15, h[3], i * 47 + jit(15))
		end

		-- a fallen cinder plum split open on the mound, its ember core showing
		local fp = cf(3.2, 1.6 + 0.55, -3.3, 0, 35, 0)
		B:block(crop, v(1.3, 1.1, 1.3), fp * CFrame.new(0, 0, 0) * ang(0, 0, 8), PL)
		B:block(crop, v(1.0, 0.2, 1.0), fp * CFrame.new(0.05, 0.58, 0) * ang(0, 0, 8), PL_DK)
		B:block(crop, v(0.7, 0.24, 0.7), fp * CFrame.new(0.05, 0.62, 0) * ang(0, 0, 8), LAVA_Y, { mat = "Neon", name = "FallenCore" })
		B:block(crop, v(0.9, 0.7, 0.8), fp * CFrame.new(-1.1, -0.2, 0.3) * ang(0, 25, -40), PL_LT)
		B:block(crop, v(0.5, 0.22, 0.5), fp * CFrame.new(-0.95, 0.12, 0.3) * ang(0, 25, -40), LAVA, { mat = "Neon", name = "FallenCore" })

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local emberZone = B:block(crop, v(10, 6, 10), cf(0, 13.5, 0), LAVA, { tr = 1, name = "EmberZone" })
		B:emitter(emberZone, "ember", { name = "CinderEmbers", color = { "#ffe27a", "#ff8a24", "#e8401f" }, rate = 6, size = { 0.24, 0.16, 0 }, speed = { 0.4, 1.1 }, life = { 1.8, 3.2 }, spread = 45, accel = { 0, 0.9, 0 } })
		B:emitter(emberZone, "leaf", { name = "AshFlakes", color = { "#c9c3bd", "#8f8984", "#e6e0da" }, rate = 2.2, size = { 0.22, 0.22, 0.12 }, life = { 3.5, 5.5 }, speed = { 0.2, 0.5 }, accel = { 0.25, -0.7, 0.1 }, dir = "Bottom" })
		local glowZone = B:block(crop, v(2, 2, 2), cf(0, 11.5, 0), LAVA, { tr = 1, name = "GlowZone" })
		B:emitter(glowZone, "glow", { name = "CinderGlow", color = { "#ff9a40", "#ff6a2a" }, rate = 1.4, size = { 3.0, 4.2, 0.8 } })
		B:light(glowZone, { name = "CinderLight", color = "#ff8a3a", brightness = 1.3, range = 18 })
		for i = 1, 3 do
			local p = glowPlums[i * 3 - 1] or glowPlums[i]
			B:emitter(p, "ember", { name = "PlumEmbers" .. i, color = { "#ffd26a", "#ff7a1a" }, rate = 1.6, size = { 0.16, 0.1, 0 }, speed = { 0.3, 0.7 }, life = { 1.0, 1.8 }, spread = 30, accel = { 0, 1.2, 0 } })
		end
		B:emitter(ventGlow, "smoke", { name = "VentSmoke", color = { "#4a4244", "#7a7270" }, rate = 1.6, size = { 0.6, 1.4, 2.0 }, speed = { 0.6, 1.2 }, life = { 1.8, 2.8 }, accel = { 0.1, 0.6, 0 }, spread = 15 })
		B:light(ventGlow, { name = "VentLight", color = "#ff7a2a", brightness = 0.9, range = 8 })
	end,
}
