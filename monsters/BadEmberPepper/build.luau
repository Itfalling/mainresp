--!nocheck
-- Ember Pepper Thornbush (Bramble Badlands crop #4, Epic).
-- A tall flame-shaped bramble thicket in the stud-plant style:
-- * stepped BADLANDS mound (bone "Soil"): charcoal basalt base, cracked
--   rust-red earth tier, ash-grey top, glowing lava cracks, bone fragments,
--   a half-buried cartoon dino tooth, ash piles, basalt pebbles
-- * a charred root crown sitting in a little glowing lava vent
-- * gnarled charred bramble canes with bone-cream thorns climbing up through
--   tiers of smoky-olive leaf clusters that taper like a flame to a curled tip
-- * glowing EMBER PEPPERS hanging all over it: dark-red shoulders grading to
--   orange, with a neon hot tip and a glowing crack
-- VFX: rising embers off the bush, hot embers + soft glow from the lava vent,
-- golden heat twinkles, one warm light. Static prop: no motion.luau.
return {
	DisplayName = "Ember Pepper Thornbush",
	Rarity = "Epic",
	Element = "Fire",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Bramble Badlands) -------------------------------------
		local BAS_DK, BAS, BAS_LT = "#26211f", "#37302d", "#4a413c"
		local RUST_DK, RUST, RUST_LT = "#6e2e1c", "#924027", "#b45a35"
		local ASH_DK, ASH, ASH_LT = "#615b58", "#857e7a", "#aaa39d"
		local BONE, BONE_DK = "#f1e6cb", "#d8c59e"
		local LAVA, LAVA_Y = "#ff5a14", "#ffa82a"
		local CANE_DK, CANE, CANE_LT = "#2b1715", "#45221c", "#6a3426"
		local LF_DK, LF, LF_MID, LF_LT = "#3b561d", "#577d27", "#73a030", "#9cc246"
		local STEM, CALYX = "#3e5a22", "#6f8a36"
		local PEP1, PEP2, PEP3, PEP_TIP, PEP_HOT = "#c0201a", "#e23a1c", "#ff6a1e", "#ffc23a", "#ff9a2a"

		local seed = 17404
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
				B:block(soil, v(w, hh, d), p * ang(0, jit(9), 0), pick(cols), S)
			end
		end
		disc(0, 0.9, 6.6, BAS_DK)
		edge(0, 0.9, 6.65, 15, { BAS_DK, BAS, BAS_DK }, 0.5, { 1.7, 2.6 }, { 1.3, 1.8 })
		disc(0.9, 0.7, 4.9, RUST_DK)
		edge(0.9, 0.7, 4.95, 11, { RUST_DK, RUST, RUST_DK }, 0.35, { 1.5, 2.2 }, { 1.2, 1.6 })
		disc(1.6, 0.55, 3.2, ASH)
		local TOP = 2.15

		-- glowing lava cracks: dark groove + neon vein, zig-zagging outward
		local function crack(deg, r0, y, segs)
			local p = pv(r0, deg, y)
			local a = deg
			for k = 1, segs do
				a = a + ((k % 2 == 0) and 14 or -14)
				local q = p + pv(1.05, a, 0)
				B:bar(soil, p, q, 0.7, 0.1, BAS_DK, S)
				B:bar(soil, p, q, 0.32, 0.18, (k == 1) and LAVA_Y or LAVA, SN)
				p = q
			end
		end
		crack(40, 5.05, 0.93, 2)
		crack(140, 5.0, 0.93, 1)
		crack(215, 5.05, 0.93, 2)
		crack(300, 5.0, 0.93, 1)
		crack(70, 3.35, 1.63, 1)
		crack(250, 3.35, 1.63, 1)

		-- ash piles
		for _, a in { { -4.6, -3.7, 1.0 }, { 5.6, 1.3, 1.1 }, { -1.8, 5.5, 0.9 } } do
			B:block(soil, v(1.3 * a[3], 0.35, 1.1 * a[3]), cf(a[1], 1.07, a[2], 0, jit(30), 0), ASH, S)
			B:block(soil, v(0.75 * a[3], 0.3, 0.65 * a[3]), cf(a[1], 1.35, a[2], 0, jit(30), 0), ASH_LT, S)
		end
		-- basalt rocks + pebbles
		for _, s in { { -5.6, 1.15, 1.9, 1.1, 20, BAS }, { 4.8, 1.1, -3.7, 1.0, -25, BAS_LT }, { 1.6, 1.05, 5.9, 0.8, 10, BAS } } do
			B:block(soil, v(s[4] * 1.35, s[4], s[4] * 1.05), cf(s[1], s[2], s[3], jit(6), s[5], jit(6)), s[6], S)
		end
		B:block(soil, v(0.8, 0.5, 0.7), cf(-5.6, 1.85, 1.9, 0, 50, 0), RUST, S)
		for _, p in { { -3.4, -5.4, ASH_DK }, { 3.0, -5.3, BAS_LT }, { -6.0, -1.4, RUST_LT }, { 6.0, -1.0, ASH_DK } } do
			B:block(soil, v(0.5, 0.32, 0.42), cf(p[1], 1.04, p[2], 0, jit(40), 0), p[3], S)
		end
		-- cartoon bone fragments
		local function bone(c, len, s)
			B:block(soil, v(len, 0.3 * s, 0.32 * s), c, BONE, S)
			for e = -1, 1, 2 do
				B:block(soil, v(0.36 * s, 0.38 * s, 0.62 * s), c * CFrame.new(e * len / 2, 0.02, 0), BONE_DK, S)
			end
		end
		bone(cf(3.7, 1.78, -2.2, 0, -35, 0), 1.3, 1)
		bone(cf(-5.3, 1.08, -2.6, 0, 60, 0), 1.5, 1.1)
		bone(cf(2.9, 1.08, 5.0, 0, -15, 4), 1.2, 1)
		------------------------------------------------------------------
		-- BUSH (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		-- little lava vent the roots sit in
		B:block(crop, v(2.9, 0.3, 2.9), cf(0, TOP + 0.05, 0, 0, 45, 0), BAS_DK)
		local vent = B:block(crop, v(2.1, 0.2, 2.1), cf(0, TOP + 0.14, 0, 0, 45, 0), LAVA, { mat = "Neon", name = "LavaVent" })
		-- charred root crown
		for k = 0, 4 do
			local d = k * 72 + 20
			B:bar(crop, pv(1.7, d, TOP + 0.1), pv(0.2, d, TOP + 1.6), 0.8, 0.7, (k % 2 == 0) and CANE or CANE_DK)
		end
		B:block(crop, v(1.5, 1.6, 1.5), cf(0, TOP + 1.6, 0, 0, 30, 0), CANE)

		-- thorns: bone-cream hooks poking out of canes and leaf masses
		local function thorn(p, dir, len)
			local q = p + dir.Unit * (len * 1.3) + v(0, 0.15, 0)
			B:bar(crop, p, q, 0.32, 0.32, BONE)
		end

		-- leaf clusters: big rotated studded leaf cubes
		local function cluster(p, s, cols)
			B:block(crop, v(1.95 * s, 1.3 * s, 1.95 * s), CFrame.new(p) * ang(jit(20), rnd() * 90, jit(20)), cols[1])
			B:block(crop, v(1.3 * s, 1.1 * s, 1.3 * s), CFrame.new(p + v(jit(0.4), 0.6 * s, jit(0.4))) * ang(jit(25), rnd() * 90, jit(25)), cols[2])
		end
		local colSets = { { LF_DK, LF }, { LF, LF_MID }, { LF_MID, LF_LT }, { LF, "#b8692e" } }

		-- ember pepper hanging from `top`, its glowing face toward `deg`
		local function pepper(top, deg, s, curl)
			local out = pv(1, deg, 0)
			local function at(dy, dc)
				return top + v(0, -dy * s, 0) + out * (dc * s)
			end
			B:bar(crop, top + v(0, 0.9, 0) - out * 0.3, top + v(0, 0.05, 0), 0.26, 0.26, STEM)
			B:block(crop, v(1.0 * s, 0.32 * s, 1.0 * s), facing(at(0.12, 0), deg + 45), CALYX)
			B:block(crop, v(0.9 * s, 0.85 * s, 0.9 * s), facing(at(0.68, 0.02), deg), PEP1)
			B:block(crop, v(0.72 * s, 0.8 * s, 0.72 * s), facing(at(1.42, 0.12 * curl), deg) * ang(-6 * curl, 0, 0), PEP2)
			B:block(crop, v(0.54 * s, 0.68 * s, 0.54 * s), facing(at(2.06, 0.3 * curl), deg) * ang(-12 * curl, 0, 0), PEP3)
			B:block(crop, v(0.36 * s, 0.5 * s, 0.36 * s), facing(at(2.55, 0.52 * curl), deg) * ang(-20 * curl, 0, 0), PEP_TIP, { mat = "Neon", name = "PepperTip" })
			-- glowing crack down the outer face
			B:block(crop, v(0.14 * s, 0.9 * s, 0.1), facing(at(1.05, 0.06 * curl), deg) * CFrame.new(0.1 * s, 0, -0.4 * s), PEP_HOT, { mat = "Neon", name = "PepperCrack" })
		end

		-- arching bramble canes: rise steeply, arch over, droop at the tip.
		-- {deg, riseR, riseY, tipR, tipY}
		local CANES = {
			{ 10, 1.7, 9.4, 4.5, 8.0 },
			{ 75, 1.9, 12.2, 4.3, 10.9 },
			{ 140, 1.6, 8.4, 4.6, 7.0 },
			{ 200, 1.8, 13.6, 3.9, 12.5 },
			{ 262, 1.7, 10.6, 4.6, 9.2 },
			{ 318, 1.5, 15.2, 3.4, 14.4 },
		}
		for ci, c in CANES do
			local d, rr, ry, tr, ty = c[1], c[2], c[3], c[4], c[5]
			local pts = {
				pv(0.9, d, TOP + 0.9),
				pv(rr * 0.85, d + 6, TOP + 1.4 + (ry - TOP - 1.4) * 0.45),
				pv(rr, d + 12, ry),
				pv((rr + tr) / 2 + 0.3, d + 18, ry + 0.7),
				pv(tr, d + 22, ty),
			}
			for i = 1, #pts - 1 do
				local a, b = pts[i], pts[i + 1]
				local w = 0.78 - 0.1 * (i - 1)
				B:bar(crop, a - (b - a).Unit * 0.2, b + (b - a).Unit * 0.1, w, w, (i % 2 == 1) and CANE or CANE_LT)
				-- one hooked thorn per segment, alternating sides
				local m = (a + b) / 2
				local side = v(b.X - a.X, 0, b.Z - a.Z)
				if side.Magnitude < 0.2 then
					side = pv(1, d + 90, 0)
				end
				side = side.Unit:Cross(v(0, 1, 0)) * ((i % 2 == 0) and 1 or -1)
				thorn(m, side + v(0, 0.25, 0), 0.8)
			end
			local cs = colSets[(ci % #colSets) + 1]
			cluster(pts[3] + v(0, 0.3, 0), 0.95, cs)
			cluster(pts[4] + v(0, 0.35, 0), 1.05, colSets[((ci + 1) % #colSets) + 1])
			cluster(pts[5] + v(0, 0.25, 0), 0.85, cs)
			cluster(pts[2], 0.7, colSets[((ci + 2) % #colSets) + 1])
			-- peppers hang under the arch and under the drooping tip
			pepper(pts[4] + pv(0.3, d + 18, -0.7), d + 18, 1.15, (ci % 2 == 0) and 1 or -1)
			pepper(pts[5] + pv(0.45, d + 22, -0.55), d + 22, 1.0, (ci % 2 == 0) and -1 or 1)
			-- extra thorn hooking out of the arch leaves
			thorn(pts[4] + pv(0.9, d + 18, 0.6), pv(1, d + 10, 0.5), 0.85)
		end

		-- low skirt: short arching shoots full of leaves right above the mound
		for k = 0, 5 do
			local d = k * 60 + 40 + jit(6)
			local a = pv(0.9, d, TOP + 0.6)
			local m = pv(2.0, d + 5, TOP + 2.6)
			local e = pv(3.1, d + 10, TOP + 2.2)
			B:bar(crop, a, m, 0.6, 0.6, CANE)
			B:bar(crop, m - (m - a).Unit * 0.1, e, 0.5, 0.5, CANE_LT)
			cluster(m + v(0, 0.35, 0), 0.9, colSets[(k % #colSets) + 1])
			cluster(e + v(0, 0.1, 0), 0.75, colSets[((k + 2) % #colSets) + 1])
			if k % 2 == 1 then
				pepper(e + pv(0.35, d + 10, -0.55), d + 10, 0.85, (k % 4 == 1) and 1 or -1)
			else
				thorn(e + v(0, 0.3, 0), pv(1, d + 30, 0.4), 0.7)
			end
		end

		-- central leader cane rising to a curled flame-tip crown
		local lead = { v(0, TOP + 1.8, 0), v(0.35, 8.5, 0.15), v(-0.25, 13.0, 0.1), v(0.2, 16.8, 0.0) }
		for i = 1, #lead - 1 do
			local w = 0.9 - 0.12 * (i - 1)
			B:bar(crop, lead[i] - v(0, 0.2, 0), lead[i + 1], w, w, (i % 2 == 1) and CANE or CANE_LT)
		end
		thorn(v(0.1, 10.5, 0.1), v(-1, 0.3, -0.3), 0.8)
		thorn(v(0.0, 14.8, 0.0), v(1, 0.3, 0.4), 0.8)
		cluster(v(0.1, 11.2, -0.1), 1.0, { LF_DK, LF_MID })
		cluster(v(0.2, 16.6, 0.0), 1.1, { LF, LF_LT })
		B:block(crop, v(1.0, 1.0, 1.0), cf(0.45, 18.0, 0.1, 0, 20, -14), LF_LT)
		B:block(crop, v(0.65, 0.75, 0.65), cf(0.95, 18.75, 0.15, 0, 35, -32), LF_MID)
		B:block(crop, v(0.38, 0.5, 0.38), cf(1.45, 19.2, 0.2, 0, 10, -55), LF_LT)
		-- crown pepper dangling just under the tip
		pepper(v(-0.6, 15.9, -0.9), 330, 1.05, 1)

		------------------------------------------------------------------
		-- VFX: embers rising off the bush, vent glow, heat twinkles, light
		------------------------------------------------------------------
		B:emitter(vent, "ember", { name = "VentEmbers", color = { "#ffe27a", "#ff8a24", "#e8401c" }, rate = 8, size = { 0.32, 0.2, 0 }, speed = { 1.2, 2.6 }, life = { 1.0, 1.8 }, spread = 25, accel = { 0, 2.0, 0 } })
		B:emitter(vent, "glow", { name = "VentGlow", color = { "#ffb347", "#ff6a1e" }, rate = 1.4, size = { 1.6, 2.4, 0.6 } })
		local bushZone = B:block(crop, v(8, 10, 8), cf(0, 11.0, 0), LAVA, { tr = 1, name = "EmberZone" })
		B:emitter(bushZone, "ember", { name = "RisingEmbers", color = { "#fff0a0", "#ffb02e", "#ff5a14" }, rate = 7, size = { 0.3, 0.2, 0 }, speed = { 0.4, 1.0 }, life = { 1.8, 3.0 }, spread = 40, accel = { 0, 1.0, 0 } })
		B:emitter(bushZone, "sparkle", { name = "HeatTwinkle", color = { "#ffe27a", "#fff3c0", "#ff9a2a" }, rate = 3, size = { 0.12, 0.38, 0 }, life = { 1.0, 2.0 }, speed = { 0.1, 0.4 } })
		B:light(bushZone, { name = "EmberLight", color = "#ff8a3a", brightness = 1.3, range = 16 })
	end,
}
