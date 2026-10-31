--!nocheck
-- Bone Pile (Bramble Badlands decoration, small accent).
-- A cute heap of cartoon dino bones on a few flat badlands stones:
-- * footing: charcoal + ash flagstones over a rust-earth patch, pebbles and
--   dry olive grass tufts (bone "Soil", removable)
-- * chunky "dog-bone" style femurs crossed in a pile, one leaning up, two
--   curved ribs poking out, loose vertebrae
-- * a small friendly dino skull peeking out of the front of the pile, with a
--   tiny teal glint in each eye socket (matches the Skull Pumpkin Patch)
-- * a thorny bramble curling up through the pile: dusky maroon stem, pale bone
--   thorns, a few olive leaves and little blackberry clusters
-- Static prop: no motion.luau.
return {
	DisplayName = "Bone Pile",
	Rarity = "Decor",
	Element = "Bramble Badlands",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Bramble Badlands) --------------------------------------
		local RK_XD, RK_DK, RK, RK_LT = "#241e22", "#3a3236", "#4a4044", "#625758"
		local RUST_DK, RUST, RUST_LT = "#7a3524", "#94452c", "#b05a36"
		local ASH_DK, ASH, ASH_LT = "#6c6662", "#88827c", "#a7a19a"
		local BONE_LT, BONE, BONE_DK, BONE_SH = "#fbf1d8", "#efe0bc", "#d8c398", "#b89f74"
		local STAIN = "#c08a5a"
		local SOCK = "#2a1f24"
		local TEAL, TEAL_LT = "#2fe0c8", "#9affee"
		local STEM, STEM_DK = "#6a2e3c", "#4a2030"
		local THORN = "#e8d6ae"
		local LEAF_DK, LEAF, LEAF_LT = "#4c5e2a", "#62763a", "#7d9248"
		local GRASS, GRASS_DK = "#9a8a4a", "#76693a"
		local BERRY, BERRY_DK, BERRY_HI = "#5a2346", "#3c1630", "#8a3c6a"

		local seed = 22517
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end

		------------------------------------------------------------------
		-- FOOTING (bone "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		-- rust earth patch
		B:block(soil, v(7.4, 0.2, 5.0), cf(0, 0.1, 0.0, 0, 8, 0), RUST_DK, S)
		B:block(soil, v(5.2, 0.22, 6.8), cf(0.2, 0.11, -0.2, 0, -14, 0), RUST, S)
		-- flat flagstones
		for _, s in {
			{ -2.3, -1.2, 2.4, 1.9, 20, RK }, { 1.9, -1.5, 2.2, 1.7, -15, ASH_DK },
			{ 2.4, 1.5, 2.0, 1.8, 35, RK_DK }, { -1.9, 1.9, 2.3, 1.6, -30, ASH },
			{ 0.2, 0.2, 2.6, 2.4, 8, RK_LT }, { -3.6, 0.5, 1.2, 1.1, 10, RK_DK },
		} do
			B:block(soil, v(s[3], 0.35, s[4]), cf(s[1], 0.25 + jit(0.03), s[2], jit(2), s[5], jit(2)), s[6], S)
		end
		-- pebbles
		for _, p in { { 3.5, -0.4, RK_LT }, { -3.2, -2.3, ASH_LT }, { 0.8, 3.1, RK }, { 3.6, -2.4, RUST_LT }, { -3.9, 1.9, ASH } } do
			B:block(soil, v(0.55, 0.4, 0.5), cf(p[1], 0.3, p[2], jit(8), jit(40), jit(8)), p[3], S)
		end
		-- dry grass tufts
		local function tuft(x, z, s)
			for k = 0, 2 do
				local a = k * 120 + jit(20)
				local h = (0.9 + rnd() * 0.5) * s
				B:block(soil, v(0.18, h, 0.18), CFrame.new(x, 0.25 + h / 2, z) * CFrame.Angles(0, rad(a), 0) * CFrame.Angles(rad(18), 0, 0) * CFrame.new(0, 0, -0.12), (k == 1) and GRASS_DK or GRASS, S)
			end
		end
		tuft(-3.4, -1.0, 1.0)
		tuft(3.3, 0.6, 0.9)
		tuft(-0.6, 3.0, 1.1)
		tuft(1.4, -3.0, 0.8)

		------------------------------------------------------------------
		-- BONE PILE (bone "Root")
		------------------------------------------------------------------
		local R = "Root"
		local G = 0.42 -- top of the flagstones

		-- cartoon femur along local Z of frame F (knobby double-lobed ends)
		local function femur(F, len, t, shade)
			local col = shade and BONE_DK or BONE
			B:block(R, v(t, t, len), F, col)
			B:block(R, v(t * 1.05, t * 0.4, len * 0.6), F * CFrame.new(0, t * 0.35, 0), BONE_LT)
			for sz = -1, 1, 2 do
				local k = t * 1.12
				for sx = -1, 1, 2 do
					B:block(R, v(k, k, k), F * CFrame.new(sx * k * 0.42, 0, sz * (len / 2 + k * 0.15)), (sx > 0) and BONE_LT or BONE)
				end
				B:block(R, v(k * 1.3, k * 0.6, k * 0.7), F * CFrame.new(0, -k * 0.25, sz * (len / 2 + k * 0.1)), BONE_DK)
			end
		end
		local function femurAB(a, b, t, shade)
			local F, len = P.aim(a, b)
			femur(F, len, t, shade)
		end

		-- bottom layer: two big femurs crossing
		femur(cf(-0.3, G + 0.4, 0.6, 0, 70, 0), 4.6, 0.8)
		femur(cf(0.4, G + 0.4, -0.4, 0, -20, 0), 4.0, 0.75, true)
		-- second layer resting on them
		femurAB(v(-2.2, G + 0.9, -0.6), v(1.9, G + 1.25, 1.3), 0.7)
		-- a femur leaning up out of the back of the pile
		femurAB(v(-1.4, G + 0.5, 1.9), v(0.2, G + 3.6, 1.3), 0.65, true)
		-- small bone on the ground at the side
		femur(cf(2.9, G + 0.3, 1.2, 0, 15, 90), 1.8, 0.5)

		-- curved ribs poking up out of the pile
		local function rib(base, dir, h, w)
			dir = v(dir.X, 0, dir.Z).Unit
			local pts = { base, base + dir * 0.6 + v(0, h * 0.45, 0), base + dir * 1.4 + v(0, h * 0.8, 0), base + dir * 2.3 + v(0, h * 0.95, 0) }
			for i = 1, #pts - 1 do
				local d = (pts[i + 1] - pts[i]).Unit
				B:bar(R, pts[i] - d * 0.12, pts[i + 1] + d * 0.12, w, w * 0.8, (i == 2) and BONE_LT or BONE)
			end
			B:block(R, v(w * 1.2, w * 1.2, w * 1.2), CFrame.new(pts[#pts]), BONE_DK)
		end
		rib(v(1.0, G + 0.8, 1.4), v(1, 0, 0.5), 2.6, 0.45)
		rib(v(0.6, G + 0.8, 1.9), v(0.8, 0, 0.9), 2.0, 0.4)

		-- vertebrae
		local function vert(c, yaw, s)
			local F = CFrame.new(c) * CFrame.Angles(0, rad(yaw), 0)
			B:block(R, v(0.9 * s, 0.75 * s, 0.9 * s), F, BONE)
			B:block(R, v(0.95 * s, 0.25 * s, 0.95 * s), F * CFrame.new(0, -0.3 * s, 0), BONE_DK)
			B:block(R, v(0.3 * s, 0.8 * s, 0.4 * s), F * CFrame.new(0, 0.6 * s, 0.1 * s), BONE_LT)
			B:block(R, v(1.8 * s, 0.25 * s, 0.3 * s), F * CFrame.new(0, 0.15 * s, 0), BONE_LT)
		end
		vert(v(-2.7, G + 0.38, -1.6), 25, 1)
		vert(v(-0.5, G + 1.4, 0.1), -10, 0.85)
		vert(v(2.9, G + 0.32, -1.9), 60, 0.8)

		------------------------------------------------------------------
		-- LITTLE DINO SKULL peeking out at the front
		------------------------------------------------------------------
		local KS = 1.3
		local K = CFrame.new(-0.8, G, -2.0) * CFrame.Angles(0, rad(16), 0) -- faces -Z
		local function at(x, y, z, rx, ry, rz)
			return K * CFrame.new(x * KS, y * KS, z * KS) * CFrame.Angles(rad(rx or 0), rad(ry or 0), rad(rz or 0))
		end
		-- cranium
		local function kv(x, y, z)
			return v(x * KS, y * KS, z * KS)
		end
		B:block(R, kv(2.4, 1.8, 2.0), at(0, 1.05, 0.5), BONE)
		B:block(R, kv(2.0, 2.0, 1.8), at(0, 1.1, 0.55), BONE_LT)
		B:block(R, kv(2.6, 1.2, 1.6), at(0, 0.95, 0.6), BONE_DK)
		B:block(R, kv(1.4, 1.0, 0.5), at(0, 1.0, 1.6), BONE_SH)
		-- brow ridges + little horn bumps
		for sg = -1, 1, 2 do
			B:block(R, kv(1.1, 0.35, 0.55), at(sg * 0.6, 2.12, -0.42, 0, 0, sg * 8), BONE)
			B:block(R, kv(0.45, 0.45, 0.45), at(sg * 1.0, 2.25, 0.4, 0, 0, sg * 25), BONE_LT)
		end
		-- big eye sockets with tiny teal glints
		for sg = -1, 1, 2 do
			B:block(R, kv(0.85, 0.85, 0.2), at(sg * 0.6, 1.5, -0.52), SOCK)
			B:block(R, kv(0.3, 0.3, 0.1), at(sg * 0.52, 1.48, -0.6, 0, 0, 45), TEAL, { mat = "Neon", name = "EyeGlint" })
			B:block(R, kv(0.12, 0.12, 0.1), at(sg * 0.72, 1.72, -0.62), TEAL_LT, { mat = "Neon", name = "EyeGlint" })
		end
		-- side fenestra
		for sg = -1, 1, 2 do
			B:block(R, kv(0.15, 0.45, 0.6), at(sg * 1.25, 1.25, 0.8), SOCK)
		end
		-- snout
		B:block(R, kv(1.8, 0.75, 1.7), at(0, 0.62, -1.2), BONE)
		B:block(R, kv(1.6, 0.25, 1.6), at(0, 1.02, -1.15), BONE_LT)
		B:block(R, kv(1.5, 0.6, 0.3), at(0, 0.65, -2.05), BONE_LT)
		for sg = -1, 1, 2 do
			B:block(R, kv(0.25, 0.1, 0.25), at(sg * 0.35, 1.16, -1.75), SOCK)
		end
		-- teeth
		for _, t in { { -0.55, -2.0 }, { 0, -2.05 }, { 0.55, -2.0 }, { -0.8, -1.4 }, { 0.8, -1.4 } } do
			B:block(R, kv(0.26, 0.38, 0.26), at(t[1], 0.2, t[2], 0, 45, 0), "#ffffff")
		end
		-- lower jaw, slightly open on the stones
		B:block(R, kv(1.7, 0.2, 1.9), at(0, 0.1, -1.0, 3, 0, 0), BONE_DK)
		B:block(R, kv(1.3, 0.1, 1.4), at(0, 0.22, -1.0, 3, 0, 0), "#7a3a3e")
		-- crack + fossil stain
		B:bar(R, at(0.6, 2.0, 0.2).Position, at(0.9, 1.6, 0.9).Position, 0.1, 0.12, BONE_SH)
		B:block(R, kv(0.6, 0.1, 0.6), at(-0.4, 2.12, 0.9), STAIN)

		------------------------------------------------------------------
		-- THORNY BRAMBLE curling up through the pile
		------------------------------------------------------------------
		local pts = {}
		local N = 9
		for i = 0, N do
			local f = i / N
			local a = rad(200 + f * 300)
			local r = 1.0 - 0.35 * f
			table.insert(pts, v(1.3 + math.sin(a) * r, G + 0.2 + f * 5.2, 0.4 - math.cos(a) * r))
		end
		for i = 1, N do
			local d = (pts[i + 1] - pts[i]).Unit
			local w = 0.52 - 0.22 * (i / N)
			B:bar(R, pts[i] - d * 0.08, pts[i + 1] + d * 0.08, w, w, (i % 2 == 0) and STEM or STEM_DK)
			-- thorns sticking out sideways
			local side = d:Cross(v(0, 1, 0))
			if side.Magnitude > 0.1 then
				side = side.Unit * ((i % 2 == 0) and 1 or -1)
				local m = (pts[i] + pts[i + 1]) / 2
				B:bar(R, m, m + side * 0.6 + v(0, 0.18, 0), 0.2, 0.2, THORN)
				B:bar(R, pts[i], pts[i] - side * 0.45 + v(0, 0.2, 0), 0.16, 0.16, THORN)
			end
		end
		-- a second, lower runner trailing over the bones to the left
		local run = { v(0.9, G + 1.2, 0.1), v(0.1, G + 2.7, -0.9), v(-1.0, G + 3.35, -1.6), v(-2.2, G + 2.6, -2.3), v(-2.9, G + 1.2, -2.4), v(-3.0, G + 0.2, -2.1) }
		for i = 1, #run - 1 do
			local d = (run[i + 1] - run[i]).Unit
			B:bar(R, run[i] - d * 0.08, run[i + 1] + d * 0.08, 0.36, 0.36, (i % 2 == 0) and STEM or STEM_DK)
			local m = (run[i] + run[i + 1]) / 2
			local sd = d:Cross(v(0, 1, 0)).Unit * ((i % 2 == 0) and 1 or -1)
			B:bar(R, m, m + v(0, 0.35, 0) + sd * 0.4, 0.18, 0.18, THORN)
		end
		-- tip curl
		local tip = pts[N + 1]
		local c1 = tip + v(-0.5, 0.35, -0.1)
		local c2 = c1 + v(-0.25, -0.35, 0)
		B:bar(R, tip, c1, 0.2, 0.2, STEM)
		B:bar(R, c1, c2, 0.17, 0.17, STEM_DK)

		-- leaves
		local function leaf(p, dir, s, col)
			dir = v(dir.X, 0, dir.Z).Unit
			local c = p + dir * 0.55 * s + v(0, 0.1, 0)
			local o = CFrame.lookAt(c, c + dir) * CFrame.Angles(rad(15), 0, 0)
			B:block(R, v(0.75 * s, 0.16, 1.0 * s), o, col)
			B:block(R, v(0.45 * s, 0.16, 1.3 * s), o * CFrame.new(0, 0.03, -0.1 * s), col)
			B:block(R, v(0.1, 0.2, 1.0 * s), o * CFrame.new(0, 0.05, 0), LEAF_DK)
		end
		leaf(pts[4], v(1, 0, -0.4), 1.4, LEAF)
		leaf(pts[6], v(-1, 0, 0.3), 1.3, LEAF_LT)
		leaf(pts[8], v(0.4, 0, 1), 1.2, LEAF)
		leaf(run[3], v(-0.3, 0, 1), 1.2, LEAF_LT)
		leaf(run[5], v(-1, 0, -0.4), 1.1, LEAF)

		-- blackberry clusters
		local function berries(c)
			B:block(R, v(0.45, 0.45, 0.45), CFrame.new(c), BERRY)
			B:block(R, v(0.32, 0.32, 0.32), CFrame.new(c + v(0.25, -0.15, 0.1)), BERRY_DK)
			B:block(R, v(0.3, 0.3, 0.3), CFrame.new(c + v(-0.2, -0.2, -0.15)), BERRY)
			B:block(R, v(0.14, 0.14, 0.14), CFrame.new(c + v(-0.08, 0.2, -0.2)), BERRY_HI)
		end
		berries(pts[5] + v(0.45, -0.35, -0.2))
		berries(pts[9] + v(-0.4, -0.3, 0.2))
		berries(run[4] + v(0.1, 0.2, -0.4))

		-- a faint teal twinkle from the skull's eyes
		local fx = B:block(R, v(1.6, 0.6, 0.4), at(0, 1.5, -0.7), BONE, { tr = 1, name = "EyeFx" })
		B:emitter(fx, "sparkle", { name = "EyeTwinkle", color = { TEAL_LT, TEAL }, rate = 1.2, size = { 0.12, 0.25, 0 }, life = { 1.2, 2.0 }, speed = { 0.2, 0.4 }, spread = 25, accel = { 0, 0.6, 0 } })
	end,
}
