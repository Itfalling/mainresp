--!nocheck
-- Giant Dino Ribs (Bramble Badlands scenery, big copy-paste filler).
-- A huge cartoon ribcage half-buried in the badlands, ribs arching out of the
-- ground in two rows and curling in toward each other like a bone tunnel:
-- * five rib pairs, tallest near the chest end and tapering toward the tail,
--   each rib a chunky stepped arc with a lighter outer ridge, darker inner
--   face at the base, a knobbly tip and a rubble collar where it meets the
--   ground; one rib snapped off, its broken end lying on the ground
-- * a row of big vertebrae poking up along the middle of the tunnel
-- * a thorny maroon bramble climbing one rib, olive leaves
-- * footing: flat rust-earth strips, charcoal plates, ash drifts, pebbles,
--   dry grass tufts and one tiny lava glint in a crack (no mound)
-- Scenery filler: anchored, weld-free, no scripts, no effects, no motion.
return {
	DisplayName = "Giant Dino Ribs",
	Rarity = "Scenery",
	Filler = true,
	Element = "Bramble Badlands",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Bramble Badlands: Bone Pile / Skull Gate) ----------------
		local RK_XD, RK_DK, RK, RK_LT = "#241e22", "#3a3236", "#4a4044", "#625758"
		local RUST_DK, RUST, RUST_LT = "#7a3524", "#94452c", "#b05a36"
		local ASH_DK, ASH, ASH_LT = "#6c6662", "#88827c", "#a7a19a"
		local BONE_LT, BONE, BONE_DK, BONE_SH = "#fbf1d8", "#efe0bc", "#d8c398", "#b89f74"
		local STAIN = "#c08a5a"
		local STEM_DK, STEM = "#4a2030", "#6a2e3c"
		local THORN = "#e8d6ae"
		local LEAF_DK, LEAF, LEAF_LT = "#4c5e2a", "#62763a", "#7d9248"
		local GRASS, GRASS_DK, GRASS_LT = "#9a8a4a", "#76693a", "#b3a35c"
		local LAVA = "#ff7a1a"
		local NEON = { mat = "Neon" }

		local seed = 73319
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end

		------------------------------------------------------------------
		-- FOOTING (flat, under Y = 0.45)
		------------------------------------------------------------------
		-- rust earth strips under each rib row + a lighter centre patch
		for _, s in { -1, 1 } do
			B:block(R, v(16.5, 0.12, 3.4), cf(0, 0.06, s * 4.6, 0, s * 2, 0), RUST_DK)
			B:block(R, v(13.0, 0.13, 4.4), cf(0.4, 0.065, s * 4.5, 0, -s * 3, 0), RUST)
		end
		B:block(R, v(14.0, 0.1, 6.0), cf(0, 0.05, 0, 0, 3, 0), RUST)
		B:block(R, v(10.0, 0.11, 7.6), cf(-0.3, 0.055, 0, 0, -4, 0), RUST_DK)
		-- charcoal plates
		local plates = {
			{ -5.6, -2.4, 2.6, 2.0, 12, RK }, { 1.2, 2.2, 3.0, 2.2, -8, RK_DK }, { 5.4, -1.8, 2.4, 2.6, 20, RK_LT },
			{ -2.2, 1.6, 2.2, 1.8, 30, ASH_DK }, { 7.9, 2.8, 2.0, 1.6, -15, RK }, { -8.0, 2.0, 1.8, 2.2, 10, RK_DK },
			{ 2.8, -3.0, 2.0, 1.6, 40, RK }, { -1.4, -6.2, 2.4, 1.6, -10, RK_LT }, { 3.6, 6.4, 2.2, 1.4, 15, RK },
		}
		for _, p in plates do
			local h = 0.28 + jit(0.04)
			B:block(R, v(p[3], h, p[4]), cf(p[1], 0.12 + h / 2, p[2], 0, p[5], 0), p[6])
		end
		-- dark crack line with one tiny lava glint
		local ca, cb, cc = v(4.4, 0.43, -1.0), v(5.4, 0.43, -1.9), v(6.2, 0.43, -1.4)
		B:bar(R, ca, cb, 0.4, 0.08, RK_XD)
		B:bar(R, cb, cc, 0.4, 0.08, RK_XD)
		B:bar(R, ca + v(0, 0.04, 0), cb + v(0, 0.04, 0), 0.14, 0.06, LAVA, NEON)
		-- ash drifts
		for _, a in { { -3.6, -0.6, 1.6, 20 }, { 3.0, 0.8, 1.4, -30 }, { -7.0, -5.6, 1.2, 50 }, { 8.4, -4.8, 1.3, 10 } } do
			B:block(R, v(a[3], 0.14, a[3] * 0.6), cf(a[1], 0.42, a[2], 0, a[4], 0), (a[4] > 0) and ASH_LT or ASH)
		end
		-- pebbles
		for _, p in { { -9.2, -2.6, 0.8, RK }, { 9.4, 0.4, 0.9, RK_DK }, { 0.6, -7.0, 0.7, RUST_LT }, { -4.0, 7.0, 0.7, ASH }, { 6.0, -6.6, 0.6, RK_LT } } do
			B:block(R, v(p[3] * 1.3, p[3] * 0.7, p[3]), cf(p[1], p[3] * 0.35, p[2], 0, jit(40), 0), p[4])
		end
		-- dry grass tufts
		local function tuft(x, z, s, yaw)
			for k = 0, 2 do
				local h = (0.9 + 0.25 * k) * s
				B:block(R, v(0.24, h, 0.24), CFrame.new(x, 0.25 + h / 2, z) * ang(0, yaw + k * 120, 0) * ang(28, 0, 0) * CFrame.new(0, 0, -0.15), ({ GRASS, GRASS_DK, GRASS_LT })[k + 1])
			end
		end
		tuft(-6.4, -6.0, 1.2, 10)
		tuft(7.0, 6.0, 1.1, 70)
		tuft(-1.0, 6.4, 1.0, 30)
		tuft(4.4, -6.4, 1.1, 50)
		tuft(-8.8, 5.0, 1.0, 20)

		------------------------------------------------------------------
		-- RIBS
		------------------------------------------------------------------
		-- rib arc in the plane x = const (plus a slight lean): an ellipse
		-- quarter from the ground (z = s*Rz) curling up and in.
		local THETA = { -3, 14, 31, 46, 59, 71 }
		local function ribPts(x, s, Rz, Hy, lean)
			local pts = {}
			for i, th in THETA do
				local t = rad(th)
				local y = 0.85 + Hy * math.sin(t)
				table.insert(pts, v(x + lean * (y / Hy), y, s * Rz * math.cos(t)))
			end
			return pts
		end
		local XUP = v(1, 0, 0)
		local function rib(x, s, Rz, Hy, w, lean, breakAt)
			local pts = ribPts(x, s, Rz, Hy, lean)
			local last = breakAt or (#pts - 1)
			for i = 1, last do
				local a, b = pts[i], pts[i + 1]
				local d = (b - a).Unit
				local ww = w * (1 - 0.09 * (i - 1))
				-- outward (away from the tunnel centre) normal in the rib plane
				local out = d:Cross(XUP).Unit
				if out:Dot(v(0, 0, s)) + out.Y * 0.3 < 0 then
					out = -out
				end
				local a0, b0 = a - d * ((i == 1) and 0 or 0.35), b + d * 0.35
				B:bar(R, a0, b0, ww, ww * 0.85, (i % 2 == 1) and BONE or BONE_DK, { up = XUP })
				-- light outer ridge
				B:bar(R, a0 + out * ww * 0.3 + d * 0.15, b0 + out * ww * 0.3 - d * 0.15, ww * 0.5, ww * 0.68, BONE_LT, { up = XUP })
				-- darker inner face at the base
				if i == 1 then
					B:bar(R, a0 - out * ww * 0.3 + d * 0.2, b0 - out * ww * 0.3 - d * 0.2, ww * 0.45, ww * 0.7, BONE_SH, { up = XUP })
				end
			end
			if breakAt then
				-- jagged snapped end
				local a, b = pts[breakAt], pts[breakAt + 1]
				local ww = w * (1 - 0.09 * (breakAt - 1))
				B:block(R, v(ww * 0.8, ww * 0.6, ww * 0.6), CFrame.new(b) * ang(25, 0, 30), BONE_DK)
				B:block(R, v(ww * 0.45, ww * 0.7, ww * 0.45), CFrame.new(b + (b - a).Unit * 0.3 + v(0.15, 0.1, 0)) * ang(-20, 40, 15), BONE_SH)
			else
				-- knobbly tip curling in
				local tip, prev = pts[#pts], pts[#pts - 1]
				local d = (tip - prev).Unit
				local ww = w * 0.55
				B:block(R, v(ww * 1.3, ww * 1.15, ww * 1.3), CFrame.new(tip + d * 0.15) * ang(0, 45, 0), BONE_LT)
				B:block(R, v(ww * 1.0, ww * 0.6, ww * 1.0), CFrame.new(tip + d * 0.1 - v(0, ww * 0.45, 0)), BONE_DK)
			end
			-- rubble collar where it leaves the ground
			local base = pts[1]
			local bz = v(base.X, 0, s * (Rz + 0.1))
			B:block(R, v(w * 1.9, 0.55, w * 1.5), CFrame.new(bz + v(0, 0.35, 0)) * ang(0, jit(20), 0), RK)
			B:block(R, v(w * 1.2, 0.5, w * 1.1), CFrame.new(bz + v(jit(0.3), 0.6, s * 0.4)) * ang(0, 45 + jit(15), 0), (rnd() > 0.5) and RK_LT or RUST)
			-- brown age stain on some ribs
			if rnd() > 0.45 then B:block(R, v(w * 0.9, 0.5, w * 0.92), CFrame.new(pts[2]:Lerp(pts[1], 0.5)), STAIN) end
			return pts
		end

		-- five pairs: tallest at the chest (-X), tapering to the tail (+X)
		local pairs_ = {
			{ -6.2, 4.6, 9.4, 1.55, 0.5 },
			{ -3.1, 4.9, 11.0, 1.7, 0.2 },
			{ 0.0, 4.9, 11.4, 1.7, -0.1 },
			{ 3.1, 4.6, 10.0, 1.55, -0.4 },
			{ 6.1, 4.1, 8.0, 1.35, -0.7 },
		}
		local climb
		for k, p in pairs_ do
			for _, s in { -1, 1 } do
				local brk = (k == 5 and s == 1) and 3 or nil
				local pts = rib(p[1], s, p[2] + jit(0.1), p[3] + jit(0.3), p[4], p[5] + jit(0.15), brk)
				if k == 2 and s == -1 then
					climb = pts
				end
			end
		end
		-- the snapped-off piece lying on the ground beside the broken rib
		local BF = cf(8.2, 0.85, 6.2, 0, -35, 6)
		B:block(R, v(4.2, 1.0, 1.15), BF, BONE)
		B:block(R, v(3.8, 0.4, 0.8), BF * CFrame.new(0, 0.48, 0), BONE_LT)
		B:block(R, v(1.15, 1.1, 1.3), BF * CFrame.new(2.2, 0.05, 0) * ang(0, 45, 0), BONE_LT)
		B:block(R, v(0.8, 0.7, 0.9), BF * CFrame.new(-2.1, 0.0, 0) * ang(20, 0, 25), BONE_DK)

		------------------------------------------------------------------
		-- VERTEBRAE along the middle of the tunnel
		------------------------------------------------------------------
		for k, x in { -6.2, -3.1, 0.0, 3.1, 6.1 } do
			local s = 1.0 - 0.06 * math.max(k - 3, 0)
			local F = cf(x, 0, jit(0.25), 0, jit(8), 0)
			B:block(R, v(2.0 * s, 0.9 * s, 2.4 * s), F * CFrame.new(0, 0.45 * s, 0), BONE_DK)
			B:block(R, v(1.6 * s, 0.6 * s, 3.4 * s), F * CFrame.new(0, 0.6 * s, 0), BONE)
			B:block(R, v(0.8 * s, 1.5 * s, 1.0 * s), F * CFrame.new(0, 1.3 * s, 0.1), BONE_LT)
		end
		-- disc between vertebrae (dark gaps make the row read as a spine)
		for _, x in { -4.65, -1.55, 1.55, 4.6 } do
			B:block(R, v(1.2, 0.55, 1.4), cf(x, 0.4, 0), BONE_SH)
		end

		------------------------------------------------------------------
		-- BRAMBLE climbing one rib
		------------------------------------------------------------------
		local vp = {}
		for i = 1, 4 do
			local p = climb[i]:Lerp(climb[i + 1], 0.5)
			table.insert(vp, p + v(((i % 2 == 0) and 0.95 or -0.95), 0, 0))
		end
		table.insert(vp, 1, climb[1] + v(0.9, -0.3, 0))
		for i = 1, #vp - 1 do
			local d = (vp[i + 1] - vp[i]).Unit
			B:bar(R, vp[i] - d * 0.15, vp[i + 1] + d * 0.15, 0.38, 0.38, (i % 2 == 0) and STEM or STEM_DK)
			B:bar(R, vp[i + 1], vp[i + 1] + v(0, 0.17, -0.55), 0.24, 0.24, THORN)
		end
		for i, lp in { vp[2], vp[4] } do
			B:block(R, v(0.9, 0.22, 0.6), CFrame.new(lp + v(0, 0.2, 0.35)) * ang(15, 30 * i, 20), (i == 1) and LEAF or LEAF_LT)
			B:block(R, v(0.6, 0.2, 0.45), CFrame.new(lp + v(0.2, -0.1, -0.35)) * ang(-20, 60 * i, -15), LEAF_DK)
		end
	end,
}
