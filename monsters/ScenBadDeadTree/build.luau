--!nocheck
-- Dead Twisted Tree (Bramble Badlands scenery, big copy-paste filler).
-- A large leafless dead tree, built for repetition across the badlands:
-- * footing: flat cracked charcoal rock plates over a rust-earth patch, dark
--   crack lines between them, ash drifts, pebbles, dry olive grass tufts and
--   one tiny lava glint in a crack (no mound)
-- * flared root buttresses gripping the plates, a thick corkscrew trunk made
--   of paired bars rolled against each other, light bark ridges spiralling up
--   it, burl knots at the kinks and a dark hollow
-- * crooked branches forking up and out into bleached, hooked twig tips, a
--   thorny maroon bramble vine winding round the lower trunk
-- Scenery filler: anchored, weld-free, no scripts, no effects, no motion.
return {
	DisplayName = "Dead Twisted Tree",
	Rarity = "Scenery",
	Filler = true,
	Element = "Bramble Badlands",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Bramble Badlands crops + decorations) -----------------------
		local RK_XD, RK_DK, RK, RK_LT = "#241e22", "#3a3236", "#4a4044", "#625758"
		local RUST_DK, RUST, RUST_LT = "#7a3524", "#94452c", "#b05a36"
		local ASH_DK, ASH, ASH_LT = "#6c6662", "#88827c", "#a7a19a"
		local BARK_XD, BARK_DK, BARK, BARK_LT = "#2e2526", "#45383a", "#5e4d4a", "#87756a"
		local BLEACH, BLEACH_DK = "#b8aa98", "#9c8e7e"
		local STEM_DK, STEM, STEM_LT = "#4a2030", "#6a2e3c", "#86445a"
		local THORN = "#e8d6ae"
		local GRASS, GRASS_DK, GRASS_LT = "#9a8a4a", "#76693a", "#b3a35c"
		local LAVA, LAVA_Y = "#ff7a1a", "#ffb43a"
		local NEON = { mat = "Neon" }

		local seed = 42611
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function pv(r, deg, y)
			local a = rad(deg)
			return v(math.sin(a) * r, y, -math.cos(a) * r)
		end

		------------------------------------------------------------------
		-- FOOTING: flat cracked rock plates (all under Y = 0.45)
		------------------------------------------------------------------
		-- rust earth underlay (two crossed slabs + a turned square)
		B:block(R, v(12.6, 0.12, 6.8), cf(0, 0.06, 0, 0, 10, 0), RUST_DK)
		B:block(R, v(6.8, 0.13, 12.2), cf(0.2, 0.065, 0.1, 0, 10, 0), RUST_DK)
		B:block(R, v(10.0, 0.14, 7.0), cf(-0.2, 0.07, 0.3, 0, 55, 0), RUST)
		B:block(R, v(7.0, 0.145, 10.0), cf(0.3, 0.0725, -0.2, 0, 55, 0), RUST)
		-- cracked charcoal plates (a ring of slabs with gaps = cracks)
		local plates = {
			{ 0, 0, 4.6, 4.2, 8, ASH_DK },
			{ 4.0, -1.2, 2.8, 3.2, 20, RK_DK },
			{ 3.6, 2.6, 3.0, 2.4, -12, ASH_DK },
			{ -0.4, 4.0, 3.4, 2.4, 6, RK_DK },
			{ -4.0, 1.9, 2.6, 3.2, -18, RK },
			{ -3.7, -2.2, 3.0, 2.6, 25, RK_LT },
			{ 0.3, -4.1, 3.6, 2.2, -6, RK },
			{ 3.0, -4.0, 1.8, 1.6, 30, ASH_DK },
			{ -5.6, -0.2, 1.6, 2.0, 12, ASH_DK },
		}
		for _, s in plates do
			local h = 0.32 + jit(0.04)
			B:block(R, v(s[3], h, s[4]), cf(s[1], h / 2 + 0.12, s[2], 0, s[5], 0), s[6])
		end
		-- worn highlight chips on a few plates
		for _, c in { { 4.3, -1.0, 1.3, 15 }, { -3.9, -2.4, 1.2, 40 }, { -0.6, 4.2, 1.4, -20 }, { 3.8, 2.4, 1.1, 5 } } do
			B:block(R, v(c[3], 0.12, c[3] * 0.7), cf(c[1], 0.48, c[2], 0, c[4], 0), RK_LT)
		end
		-- dark crack lines running out across the plates, one hiding a lava glint
		local function crack(pts, glow)
			for i = 1, #pts - 1 do
				local a, b = v(pts[i][1], 0.47, pts[i][2]), v(pts[i + 1][1], 0.47, pts[i + 1][2])
				B:bar(R, a, b, 0.42, 0.1, RK_XD)
			end
			if glow then
				local a, b = v(pts[1][1], 0.55, pts[1][2]), v(pts[2][1], 0.55, pts[2][2])
				B:bar(R, a, b, 0.16, 0.08, LAVA, NEON)
			end
		end
		crack({ { 1.8, -2.4 }, { 2.6, -3.4 }, { 2.3, -4.6 } })
		crack({ { -2.4, 0.6 }, { -3.6, 0.2 }, { -4.6, 1.2 } })
		crack({ { 2.0, 1.8 }, { 3.2, 3.0 } })
		crack({ { -1.5, -2.6 }, { -2.3, -3.5 }, { -2.0, -4.5 } }, true)
		-- ash drifts
		for _, a in { { -2.6, -3.6, 1.6, 20 }, { 4.6, 1.0, 1.4, -30 }, { -1.8, 3.2, 1.2, 50 } } do
			B:block(R, v(a[3], 0.16, a[3] * 0.6), cf(a[1], 0.5, a[2], 0, a[4], 0), ASH)
			B:block(R, v(a[3] * 0.55, 0.14, a[3] * 0.4), cf(a[1] + 0.1, 0.62, a[2], 0, a[4] + 35, 0), ASH_LT)
		end
		-- pebbles + loose rocks at the rim
		for _, p in { { 5.7, -2.9, 0.9, RK }, { -5.6, 2.9, 1.0, RK_DK }, { 1.5, 5.3, 0.8, RUST_LT }, { -2.0, -5.3, 0.7, ASH }, { 6.0, 1.9, 0.6, RK_LT } } do
			B:block(R, v(p[3] * 1.3, p[3] * 0.7, p[3]), cf(p[1], p[3] * 0.35, p[2], 0, jit(40), 0), p[4])
			B:block(R, v(p[3] * 0.7, p[3] * 0.35, p[3] * 0.6), cf(p[1] - 0.1, p[3] * 0.8, p[2], 0, jit(40), 0), RK_LT)
		end
		-- dry grass tufts poking from the cracks
		local function tuft(x, z, s, yaw)
			for k = 0, 2 do
				local h = (0.9 + 0.25 * k) * s
				B:block(R, v(0.24, h, 0.24), CFrame.new(x, 0.3 + h / 2, z) * ang(0, yaw + k * 120, 0) * ang(28, 0, 0) * CFrame.new(0, 0, -0.15), ({ GRASS, GRASS_DK, GRASS_LT })[k + 1])
			end
		end
		tuft(5.2, -0.6, 1.2, 10)
		tuft(-4.9, -1.0, 1.1, 70)
		tuft(0.9, -5.2, 1.0, 30)
		tuft(-2.8, 4.8, 1.2, 50)

		------------------------------------------------------------------
		-- TREE
		------------------------------------------------------------------
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
			B:bar(R, a, b, w, w, c1, { up = up1 })
			if c2 then
				B:bar(R, a + d * 0.1, b - d * 0.1, w * 0.88, w * 0.88, c2, { up = up2 })
			end
		end

		-- root buttresses flaring out over the plates
		for i, r in { { 15, 4.3 }, { 85, 3.6 }, { 150, 4.6 }, { 215, 3.8 }, { 285, 4.4 }, { 345, 3.4 } } do
			local a0 = pv(0.7, r[1], 1.7)
			local a1 = pv(2.3, r[1] + 10, 0.85)
			local a2 = pv(r[2], r[1] + 20, 0.5)
			local a3 = pv(r[2] + 1.0, r[1] + 26, 0.42)
			limb(a0, a1, 1.5, BARK_DK, BARK, i * 30)
			B:bar(R, a1 - (a1 - a0).Unit * 0.3, a2, 1.05, 0.9, (i % 2 == 0) and BARK or BARK_DK)
			B:bar(R, a2 - (a2 - a1).Unit * 0.25, a3, 0.7, 0.55, BARK_LT)
		end
		-- base flare (stepped collar)
		B:block(R, v(4.6, 1.2, 3.4), cf(0, 0.9, 0, 0, 20, 0), BARK_DK)
		B:block(R, v(3.4, 1.25, 4.6), cf(0, 0.92, 0, 0, 20, 0), BARK)
		B:block(R, v(3.8, 1.0, 3.8), cf(0, 1.4, 0, 0, 65, 0), BARK_DK)

		-- trunk: corkscrew polyline
		local T = {
			v(0, 0.6, 0),
			v(0.9, 4.2, 0.4),
			v(-0.7, 7.6, -0.4),
			v(0.8, 10.6, 0.5),
			v(-0.2, 13.0, -0.1),
			v(0.3, 14.8, 0.2),
		}
		local TW = { 3.4, 2.9, 2.4, 1.9, 1.45 }
		for i = 1, #T - 1 do
			local ext = (T[i + 1] - T[i]).Unit * 0.35
			limb(T[i], T[i + 1] + ext, TW[i], (i % 2 == 1) and BARK_DK or BARK, (i % 2 == 1) and BARK or BARK_DK, i * 25)
			if i > 1 then
				-- burl knot at each kink
				B:block(R, v(TW[i] + 0.4, 0.8, TW[i] + 0.4), CFrame.new(T[i]) * ang(0, i * 37, 0), BARK_LT)
			end
		end
		-- spiral bark ridges winding up the trunk (light and dark)
		local function onTrunk(y)
			for i = 1, #T - 1 do
				if y <= T[i + 1].Y or i == #T - 1 then
					local f = (y - T[i].Y) / (T[i + 1].Y - T[i].Y)
					return T[i]:Lerp(T[i + 1], f), TW[i]
				end
			end
		end
		for k = 0, 8 do
			local y0 = 1.8 + k * 1.25
			local ctr, tw = onTrunk(y0)
			local a0 = k * 55
			local p0 = ctr + pv(tw * 0.6, a0, 0)
			local ctr2 = onTrunk(y0 + 1.5)
			local p1 = ctr2 + pv(tw * 0.55, a0 + 45, 0)
			B:bar(R, p0, p1, 0.5, 0.45, (k % 3 == 0) and BARK_LT or BARK_XD)
		end
		-- dark hollow with a lighter lip
		local hc = onTrunk(5.6)
		local hd = pv(1, 330, 0)
		B:block(R, v(1.2, 1.7, 0.5), CFrame.new(hc + hd * 1.32) * ang(0, 30, 0), BARK_XD)
		B:block(R, v(1.7, 0.4, 0.55), CFrame.new(hc + hd * 1.25 + v(0, 1.05, 0)) * ang(0, 30, 0), BARK_LT)
		B:block(R, v(1.5, 0.35, 0.5), CFrame.new(hc + hd * 1.25 + v(0, -1.0, 0)) * ang(0, 30, 0), BARK)

		-- branches: polylines with tapering widths, bleached hooked tips
		local function branch(pts, w0, w1, twigs)
			local n = #pts - 1
			for i = 1, n do
				local w = w0 + (w1 - w0) * (i - 1) / math.max(n - 1, 1)
				local a, b = pts[i], pts[i + 1]
				local ext = (b - a).Unit * math.min(w * 0.4, 0.4)
				limb(a, b + ext, w, (i % 2 == 1) and BARK or BARK_DK, (w > 0.95) and BARK_DK or nil, i * 40)
				if i > 1 and w > 0.8 then
					B:block(R, v(w + 0.2, w + 0.2, w + 0.2), CFrame.new(a) * ang(0, i * 30, 20), BARK_LT)
				end
			end
			-- bleached hooked tip
			local tip, prev = pts[#pts], pts[#pts - 1]
			local d = (tip - prev).Unit
			local t1 = tip + d * 1.2 + v(0, 0.3, 0)
			local t2 = t1 + v(d.X * 0.5, 0.7, d.Z * 0.5)
			B:bar(R, tip - d * 0.2, t1, 0.5, 0.5, BLEACH_DK)
			B:bar(R, t1 - (t1 - tip).Unit * 0.15, t2, 0.38, 0.38, BLEACH)
			for _, tw in twigs or {} do
				local base = pts[tw[1]]:Lerp(pts[tw[1] + 1], tw[2])
				local e1 = base + tw[3]
				local e2 = e1 + tw[3].Unit * 0.9 + v(0, 0.6, 0)
				B:bar(R, base, e1, 0.55, 0.5, BARK_DK)
				B:bar(R, e1 - tw[3].Unit * 0.15, e2, 0.38, 0.38, BLEACH_DK)
			end
		end

		-- low right (long, reaching sideways)
		branch({ onTrunk(7.0) + v(0.6, 0, 0), v(3.4, 8.0, -0.4), v(6.0, 8.7, -1.0), v(8.2, 10.1, -0.8), v(9.3, 11.7, -0.2) }, 1.6, 0.65,
			{ { 2, 0.6, v(0.4, 1.6, 1.4) }, { 3, 0.5, v(0.6, 1.4, -1.4) } })
		-- low left back
		branch({ onTrunk(8.2) + v(-0.6, 0, 0.2), v(-3.2, 9.0, 1.2), v(-5.6, 9.7, 2.2), v(-7.4, 11.2, 2.6), v(-8.1, 12.8, 2.0) }, 1.5, 0.6,
			{ { 2, 0.5, v(-0.4, 1.5, -1.6) }, { 3, 0.6, v(-0.8, 1.6, 1.2) } })
		-- mid front left
		branch({ onTrunk(10.4) + v(-0.2, 0, -0.5), v(-1.8, 11.4, -2.8), v(-3.6, 12.3, -4.6), v(-4.8, 13.9, -5.3) }, 1.3, 0.6,
			{ { 2, 0.5, v(1.2, 1.5, -0.8) } })
		-- mid back right
		branch({ onTrunk(11.2) + v(0.3, 0, 0.5), v(2.2, 12.2, 2.8), v(4.2, 13.2, 4.4), v(5.3, 14.8, 5.0) }, 1.3, 0.6,
			{ { 2, 0.5, v(0.8, 1.6, -1.2) } })
		-- high right front
		branch({ onTrunk(13.4) + v(0.3, 0, -0.2), v(2.6, 14.6, -1.8), v(4.4, 15.6, -3.0), v(5.1, 17.0, -3.2) }, 1.1, 0.55)
		-- crown leader with a fork
		branch({ T[6], v(-0.6, 16.2, 0.6), v(-1.7, 17.3, 0.5), v(-2.3, 18.5, 0.9) }, 1.2, 0.6,
			{ { 1, 0.6, v(1.8, 1.2, 0.6) }, { 2, 0.5, v(0.6, 1.3, -1.6) } })

		-- thorny bramble vine winding round the lower trunk
		local vp = {}
		for k = 0, 7 do
			local y = 1.4 + k * 0.85
			local ctr, tw = onTrunk(y)
			table.insert(vp, ctr + pv(tw * 0.62 + 0.15, 200 + k * 62, 0))
		end
		for i = 1, #vp - 1 do
			local d = (vp[i + 1] - vp[i]).Unit
			B:bar(R, vp[i] - d * 0.12, vp[i + 1] + d * 0.12, 0.34, 0.34, (i % 2 == 0) and STEM or STEM_DK)
			if i % 2 == 1 then
				local out = (vp[i] - onTrunk(vp[i].Y)).Unit
				B:bar(R, vp[i] + out * 0.05, vp[i] + out * 0.6, 0.22, 0.22, THORN)
			end
		end
		B:block(R, v(0.5, 0.5, 0.5), CFrame.new(vp[#vp]) * ang(20, 45, 0), STEM_LT)
	end,
}
