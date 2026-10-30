--!nocheck
-- Skull Pumpkin Patch (Bramble Badlands crop #6, Mythic).
-- A pumpkin patch planted in a cute cartoon dino skull:
-- * stepped badlands mound (bone "Soil"): charcoal rock base, cracked rust-red
--   earth tier and an ash-grey top, glowing lava cracks, bone bits, obsidian
-- * a big friendly T-rex skull (bone "Skull") lying on the mound as a planter:
--   rounded stepped cranium with an open top full of ash soil, big eye sockets
--   lit by teal glow-crystals, brow ridges, nostrils, rows of block teeth and a
--   gaping lower jaw with a little pumpkin peeking out
-- * a tall dino femur stuck in the skull as a stake; a dusky pumpkin vine coils
--   up it with big stepped leaves, curly tendrils and pumpkin blossoms
-- * lava pumpkins with glowing seams: a giant one sitting in the skull, more
--   hanging up the vine, a crown pumpkin near the top, one spilled on the mound
-- Rising embers, teal wisps drifting from the sockets, nostril smoke puffs,
-- drifting ash, warm pumpkin glow; two soft lights. Static prop: no motion.luau.
return {
	DisplayName = "Skull Pumpkin Patch",
	Rarity = "Mythic",
	Element = "Fire",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Bramble Badlands) --------------------------------------
		local RK_XD, RK_DK, RK, RK_LT = "#241e22", "#3a3236", "#4a4044", "#625758"
		local RUST_DK, RUST, RUST_LT = "#7a3524", "#94452c", "#b05a36"
		local ASH_DK, ASH, ASH_LT = "#6c6662", "#88827c", "#a7a19a"
		local SOIL_DK = "#3a2f2c"
		local BONE_LT, BONE, BONE_DK, BONE_SH = "#fbf1d8", "#efe0bc", "#d8c398", "#b89f74"
		local STAIN = "#c08a5a"
		local SOCK, MOUTH = "#2a1f24", "#3a2228"
		local TEAL, TEAL_LT = "#2fe0c8", "#9affee"
		local OBS, OBS_PU = "#2a2134", "#8a5cc0"
		local LAVA, LAVA_Y = "#ff7a1a", "#ffb43a"
		local PUMP_LT, PUMP, PUMP_DK, RIB = "#ff9a3a", "#f07a1e", "#cf5c14", "#8f3510"
		local STEM, STEM_DK = "#6a5a2a", "#4a3e1e"
		local VINE, VINE_DK = "#6f7d33", "#4f5a26"
		local LEAF_DK, LEAF, LEAF_LT, LEAF_RUST = "#4c5e2a", "#62763a", "#7d9248", "#a8602c"
		local FLOW, FLOW_DK = "#ffc93a", "#f09a1e"

		local seed = 66127
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
		disc(0, 0.9, 6.8, RK_DK)
		edge(0, 0.9, 6.8, 17, { RK_DK, RK, RK_XD, RK }, 0.5, { 1.6, 2.5 }, { 1.3, 1.8 })
		disc(0.9, 0.7, 5.2, RUST)
		edge(0.9, 0.7, 5.25, 13, { RUST, RUST_DK, RUST_LT }, 0.35, { 1.5, 2.2 }, { 1.2, 1.6 })
		disc(1.6, 0.55, 3.6, ASH_DK)
		edge(1.6, 0.55, 3.65, 9, { ASH_DK, ASH, ASH_DK }, 0.25, { 1.3, 1.9 }, { 1.0, 1.4 })
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
		local function arc(d0, d1, r, n, y)
			local pts = {}
			for i = 0, n do
				local x, z = polar(r + ((i % 2 == 0) and -0.2 or 0.2), d0 + (d1 - d0) * i / n)
				table.insert(pts, { x, z })
			end
			crack(pts, y)
		end
		crack(crackPts(120, 3.8, 5.0, 2, 7), 1.62)
		crack(crackPts(235, 3.8, 5.0, 2, 8), 1.62)
		crack(crackPts(40, 3.8, 5.0, 2, 7), 1.62)
		arc(150, 195, 6.0, 3, 0.92)
		arc(-25, 15, 6.0, 3, 0.92)
		arc(255, 290, 6.0, 2, 0.92)
		for _, d in { { 120, 5.25, 1.25, 0.7 }, { 170, 6.85, 0.45, 0.8 }, { 235, 5.25, 1.25, 0.65 } } do
			local x, z = polar(d[2], d[1])
			B:block(soil, v(0.24, d[4], 0.24), facing(v(x, d[3], z), d[1]) * CFrame.new(0, 0, -0.05), LAVA, SN)
		end
		-- rocks
		for _, s in { { 5.5, 1.2, 2.6, 1.1, 25, RK }, { -5.6, 1.1, 2.2, 1.0, -20, RK_DK }, { -3.4, 1.0, 5.6, 0.8, 30, RK_LT }, { 4.0, 1.0, 5.1, 0.75, 5, RK } } do
			B:block(soil, v(s[4] * 1.35, s[4], s[4] * 1.05), cf(s[1], s[2], s[3], jit(6), s[5], jit(6)), s[6], S)
		end
		-- obsidian shards with purple glints
		for _, o in { { -6.0, 0.9, -1.2, 1.5, 10 }, { 4.6, 1.6, 0.9, 1.2, -15 } } do
			local base = cf(o[1], o[2], o[3], jit(10), o[5], jit(12))
			B:block(soil, v(0.7, o[4], 0.6), base * CFrame.new(0, o[4] / 2, 0), OBS, S)
			B:block(soil, v(0.42, 0.5, 0.36), base * CFrame.new(0, o[4] + 0.2, 0), OBS_PU, S)
			B:block(soil, v(0.5, o[4] * 0.6, 0.45), base * CFrame.new(0.5, o[4] * 0.3, 0.15) * ang(0, 0, -14), OBS, S)
		end
		-- loose bones: a little rib + vertebrae
		B:bar(soil, v(4.4, 1.7, 3.6), v(5.6, 1.75, 1.6), 0.4, 0.35, BONE, S)
		B:block(soil, v(0.55, 0.5, 0.55), cf(4.35, 1.75, 3.65, 0, 30, 0), BONE_DK, S)
		B:block(soil, v(0.7, 0.5, 0.7), cf(2.6, 2.35, 2.9, 0, 20, 0), BONE, S)
		B:block(soil, v(0.3, 0.55, 0.3), cf(2.6, 2.7, 2.9, 0, 20, 0), BONE_DK, S)
		-- ash piles + pebbles
		for _, a in { { 2.9, -1.8 }, { -2.9, 1.9 }, { -5.0, -3.8 }, { 4.6, -3.6 } } do
			local y = (math.sqrt(a[1] * a[1] + a[2] * a[2]) < 3.5) and TOP or 1.6
			B:block(soil, v(1.0, 0.18, 0.8), cf(a[1], y + 0.05, a[2], 0, jit(40), 0), ASH_LT, S)
			B:block(soil, v(0.5, 0.18, 0.45), cf(a[1] + 0.1, y + 0.18, a[2], 0, jit(40), 0), ASH_LT, S)
		end
		for _, p in { { 1.4, -6.1, RK_LT }, { -6.0, 0.4, ASH }, { 6.2, 0.8, RK_LT } } do
			B:block(soil, v(0.5, 0.32, 0.42), cf(p[1], 0.98, p[2], 0, jit(40), 0), p[3], S)
		end

		------------------------------------------------------------------
		-- CUTE DINO SKULL PLANTER (bone "Skull")
		------------------------------------------------------------------
		local sk = B:bone("Skull", "Root", v(0, TOP, 0))
		-- cranium: stepped rounded box  (y 2.7 .. 7.7, z -1.2 .. 4.0)
		local CY, CZ = 5.2, 1.4
		B:block(sk, v(6.0, 4.6, 5.0), cf(0, CY, CZ), BONE)
		B:block(sk, v(5.2, 5.0, 4.6), cf(0, CY, CZ + 0.05), BONE_LT)
		B:block(sk, v(6.5, 3.4, 4.2), cf(0, CY - 0.3, CZ + 0.2), BONE)
		B:block(sk, v(5.0, 3.6, 5.6), cf(0, CY - 0.2, CZ + 0.15), BONE_DK)
		B:block(sk, v(5.4, 0.8, 4.6), cf(0, 2.5, CZ + 0.2), BONE_SH)
		-- back of the skull (occipital bump) + jaw hinge knobs + cheek horns
		B:block(sk, v(3.6, 2.6, 1.0), cf(0, CY - 0.3, CZ + 3.0), BONE_DK)
		B:block(sk, v(2.2, 1.4, 0.6), cf(0, CY - 0.5, CZ + 3.6), BONE_SH)
		for sg = -1, 1, 2 do
			B:block(sk, v(0.9, 1.5, 1.8), cf(sg * 3.3, 3.5, -0.2), BONE_DK)
			B:block(sk, v(0.8, 0.8, 0.8), cf(sg * 3.4, 5.6, 2.2, 0, 0, sg * 20), BONE_LT)
			B:block(sk, v(0.5, 0.6, 0.5), cf(sg * 3.75, 6.1, 2.2, 0, 0, sg * 35), BONE)
		end
		-- open top full of ash soil, with a broken bone rim
		local RIMY = CY + 2.55
		B:block(sk, v(4.2, 0.3, 3.8), cf(0, RIMY + 0.05, CZ + 0.3), SOIL_DK)
		B:block(sk, v(3.4, 0.3, 3.0), cf(0, RIMY + 0.2, CZ + 0.3, 0, 20, 0), "#4a3c36")
		for _, r in { { -2.45, 0.2, 0.6, 3.8, 0.9 }, { 2.45, 0.3, 0.6, 3.4, 0.7 }, { 0.2, 2.25, 3.8, 0.55, 0.65 } } do
			B:block(sk, v(r[3], r[5], r[4]), cf(r[1], RIMY + r[5] / 2 - 0.15, CZ + r[2], 0, jit(4), 0), BONE_LT)
		end
		B:block(sk, v(0.8, 0.5, 0.7), cf(2.4, RIMY + 0.8, CZ + 1.5, 0, 20, -10), BONE)
		-- side skull openings (dino fenestrae) so it reads as a skull from every side
		for sg = -1, 1, 2 do
			B:block(sk, v(0.3, 1.5, 1.9), cf(sg * 3.2, 5.5, 1.9), SOCK)
			B:block(sk, v(0.45, 0.45, 2.5), cf(sg * 3.3, 6.45, 1.9), BONE_LT)
			B:block(sk, v(0.45, 1.6, 0.45), cf(sg * 3.3, 5.5, 3.1), BONE_LT)
			B:block(sk, v(0.45, 0.45, 2.3), cf(sg * 3.3, 4.55, 1.85), BONE)
		end
		-- crack lines + fossil stains
		B:bar(sk, v(3.3, 4.2, -0.2), v(3.32, 3.3, 0.6), 0.14, 0.16, BONE_SH)
		B:block(sk, v(0.1, 0.9, 1.0), cf(-3.27, 3.6, 2.9), STAIN)
		B:block(sk, v(1.6, 0.1, 1.0), cf(0.8, RIMY - 0.6, CZ + 3.05), STAIN)

		-- big round eye sockets on the face, lit by teal glow crystals
		local sockets = {}
		local FZ = CZ - 2.5 -- cranium front face
		for sg = -1, 1, 2 do
			local x, y = sg * 1.55, 6.55
			B:block(sk, v(2.0, 2.0, 0.3), cf(x, y, FZ - 0.1), SOCK)
			-- stepped bone frame (4 bars + corner fillers = rounded socket)
			B:block(sk, v(2.0, 0.5, 0.6), cf(x, y + 1.2, FZ - 0.3), BONE_LT)
			B:block(sk, v(2.0, 0.5, 0.6), cf(x, y - 1.2, FZ - 0.3), BONE_LT)
			B:block(sk, v(0.5, 2.0, 0.6), cf(x + 1.2, y, FZ - 0.3), BONE_LT)
			B:block(sk, v(0.5, 2.0, 0.6), cf(x - 1.2, y, FZ - 0.3), BONE_LT)
			for cx = -1, 1, 2 do
				for cy = -1, 1, 2 do
					B:block(sk, v(0.5, 0.5, 0.6), cf(x + cx * 0.82, y + cy * 0.82, FZ - 0.32), BONE)
				end
			end
			local g = B:block(sk, v(0.75, 0.75, 0.3), cf(x - sg * 0.1, y - 0.1, FZ - 0.25, 0, 0, 45), TEAL, { mat = "Neon", name = "SocketGlow" })
			B:block(sk, v(0.3, 0.3, 0.3), cf(x + sg * 0.45, y + 0.45, FZ - 0.3), TEAL_LT, { mat = "Neon", name = "SocketGlow" })
			B:block(sk, v(0.45, 0.3, 0.3), cf(x - sg * 0.5, y - 0.6, FZ - 0.2, 0, 0, 30), "#1f8f86")
			-- heavy brow ridge (front of the planter rim)
			B:block(sk, v(2.9, 0.7, 1.3), cf(x + sg * 0.1, y + 1.65, FZ - 0.05, 0, 0, sg * 6), BONE)
			table.insert(sockets, g)
		end
		-- bridge between the sockets
		B:block(sk, v(0.7, 2.6, 0.5), cf(0, 6.4, FZ - 0.2), BONE)

		-- upper jaw / snout (y 3.4 .. 5.2, z -4.8 .. -1.2)
		B:block(sk, v(4.6, 1.8, 3.6), cf(0, 4.3, -3.0), BONE)
		B:block(sk, v(4.0, 0.5, 3.4), cf(0, 5.3, -2.9), BONE_LT)
		B:block(sk, v(3.8, 1.5, 0.5), cf(0, 4.35, -4.95), BONE_LT)
		B:block(sk, v(2.8, 0.4, 0.4), cf(0, 5.2, -4.95), BONE_LT)
		B:block(sk, v(4.8, 0.4, 3.4), cf(0, 3.55, -2.9), BONE_DK)
		-- nostrils on the snout tip
		for sg = -1, 1, 2 do
			B:block(sk, v(0.4, 0.12, 0.4), cf(sg * 0.55, 5.56, -4.4), SOCK)
		end
		local noseFx = B:block(sk, v(1.8, 0.3, 0.5), cf(0, 5.8, -4.35), BONE, { tr = 1, name = "NoseFx" })
		-- mouth interior + gaping lower jaw resting on the mound
		B:block(sk, v(3.8, 1.0, 3.4), cf(0, 3.0, -2.8), MOUTH)
		B:block(sk, v(4.4, 0.9, 3.9), cf(0, 2.3, -3.0, -5, 0, 0), BONE)
		B:block(sk, v(3.8, 0.5, 3.7), cf(0, 1.95, -3.05, -5, 0, 0), BONE_DK)
		B:block(sk, v(3.4, 0.12, 3.1), cf(0, 2.76, -2.85, -5, 0, 0), "#7a3a3e")
		-- teeth: upper row hanging down, lower row pointing up
		for _, t in { { -1.4, -4.55 }, { -0.47, -4.55 }, { 0.47, -4.55 }, { 1.4, -4.55 }, { -2.05, -3.6 }, { 2.05, -3.6 }, { -2.05, -2.5 }, { 2.05, -2.5 } } do
			B:block(sk, v(0.42, 0.6, 0.42), cf(t[1], 3.15, t[2], 0, 45, 0), "#ffffff")
		end
		for _, t in { { -0.95, -4.5 }, { 1.85, -3.1 }, { -1.85, -3.1 } } do
			B:block(sk, v(0.38, 0.5, 0.38), cf(t[1], 2.85, t[2], 0, 45, 0), "#ffffff")
		end

		------------------------------------------------------------------
		-- PUMPKIN VINE (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		-- stepped lava pumpkin: crossed slabs over a dark rib core, glowing seams
		local function pumpkin(c, s, yaw, glow, tilt)
			local F = CFrame.new(c) * CFrame.Angles(rad(tilt or 0), rad(yaw or 0), 0)
			local function at(x, y, z, ry)
				return F * CFrame.new(x * s, y * s, z * s) * CFrame.Angles(0, rad(ry or 0), 0)
			end
			B:block(crop, v(3.4 * s, 1.6 * s, 2.3 * s), at(0, 0, 0), PUMP)
			B:block(crop, v(2.3 * s, 1.58 * s, 3.4 * s), at(0, 0, 0), PUMP)
			B:block(crop, v(3.0 * s, 1.56 * s, 3.0 * s), at(0, 0, 0), RIB)
			for _, b in { { 1.0, PUMP_LT }, { -0.95, PUMP_DK } } do
				B:block(crop, v(2.7 * s, 0.7 * s, 1.7 * s), at(0, b[1], 0), b[2])
				B:block(crop, v(1.7 * s, 0.68 * s, 2.7 * s), at(0, b[1], 0), b[2])
				B:block(crop, v(2.35 * s, 0.66 * s, 2.35 * s), at(0, b[1], 0), RIB)
			end
			B:block(crop, v(1.6 * s, 0.4 * s, 1.6 * s), at(0, 1.45, 0), PUMP_LT)
			B:block(crop, v(1.4 * s, 0.34 * s, 1.4 * s), at(0, -1.4, 0), PUMP_DK)
			-- dark rib grooves down the 4 faces
			for i = 0, 3 do
				B:block(crop, v(0.32 * s, 2.3 * s, 0.14), at(0, 0, 0, -i * 90) * CFrame.new(0, -0.05 * s, -1.7 * s - 0.06), RIB)
			end
			if glow then
				-- glowing lava seams in the 4 diagonal grooves
				for i = 0, 3 do
					B:block(crop, v(0.36 * s, 1.45 * s, 0.36 * s), at(0, 0, 0, 45 + i * 90) * CFrame.new(0, 0, -2.0 * s), (i % 2 == 0) and LAVA or LAVA_Y, { mat = "Neon", name = "PumpkinSeam" })
				end
			end
			-- curly stem
			local top = at(0, 1.6, 0).Position
			local s1 = top + v(0, 0.8 * s, 0)
			B:bar(crop, top - v(0, 0.2, 0), s1, 0.45 * s, 0.45 * s, STEM)
			B:bar(crop, s1 - v(0, 0.1, 0), s1 + (F.RightVector * 0.6 + v(0, 0.25, 0)) * s, 0.35 * s, 0.35 * s, STEM_DK)
			return top
		end

		-- stepped pumpkin leaf on a short stalk
		local function leaf(base, dir, s, col)
			dir = v(dir.X, 0, dir.Z).Unit
			local c = base + dir * (1.0 * s) + v(0, 0.15, 0)
			local o = CFrame.lookAt(c, c + dir) * CFrame.Angles(rad(10), 0, rad(jit(12)))
			B:bar(crop, base, c, 0.26, 0.26, VINE_DK)
			B:block(crop, v(1.9 * s, 0.32, 1.7 * s), o, col)
			B:block(crop, v(1.2 * s, 0.3, 2.4 * s), o * CFrame.new(0, 0.02, -0.15 * s), col)
			B:block(crop, v(2.5 * s, 0.28, 0.95 * s), o * CFrame.new(0, -0.02, 0.1 * s), col)
			B:block(crop, v(1.1 * s, 0.3, 1.0 * s), o * CFrame.new(0, 0.2, -0.1 * s) * CFrame.Angles(0, rad(45), 0), LEAF_DK)
			B:block(crop, v(0.18, 0.34, 2.0 * s), o * CFrame.new(0, 0.06, -0.15 * s), LEAF_DK)
		end

		-- pumpkin blossom: 5 stepped petals round a golden heart
		local function blossom(c, s, up)
			up = up.Unit
			local o = CFrame.lookAt(c, c + up) * CFrame.Angles(rad(-90), 0, 0)
			B:block(crop, v(0.6 * s, 0.6 * s, 0.6 * s), o, FLOW_DK)
			for k = 0, 4 do
				local po = o * CFrame.Angles(0, rad(k * 72), 0) * CFrame.new(0, 0.25 * s, -0.55 * s) * CFrame.Angles(rad(35), 0, 0)
				B:block(crop, v(0.75 * s, 0.18, 0.9 * s), po, (k % 2 == 0) and FLOW or FLOW_DK)
			end
			B:block(crop, v(0.3 * s, 0.4 * s, 0.3 * s), o * CFrame.new(0, 0.35 * s, 0), LAVA_Y, { mat = "Neon", name = "BlossomHeart" })
		end

		-- the femur stake standing in the back of the skull
		local SX, SZ = 0.5, CZ + 1.3
		local STAKE_B, STAKE_T = RIMY - 0.6, 15.9
		B:block(crop, v(1.3, STAKE_T - STAKE_B, 1.3), cf(SX, (STAKE_B + STAKE_T) / 2, SZ, 0, 8, 0), BONE)
		B:block(crop, v(1.15, STAKE_T - STAKE_B - 1.6, 1.45), cf(SX, (STAKE_B + STAKE_T) / 2, SZ, 0, 53, 0), BONE_DK)
		B:block(crop, v(1.7, 0.7, 1.7), cf(SX, (STAKE_B + STAKE_T) / 2 + 1.2, SZ, 0, 30, 0), BONE_LT)
		-- femur head: two knobbly condyles
		B:block(crop, v(2.8, 1.1, 1.6), cf(SX, STAKE_T + 0.1, SZ, 0, 8, 0), BONE)
		for sg = -1, 1, 2 do
			B:block(crop, v(1.3, 1.5, 1.7), cf(SX, STAKE_T + 0.6, SZ, 0, 8, 0) * CFrame.new(sg * 0.85, 0, 0), BONE_LT)
		end
		B:block(crop, v(1.9, 0.9, 1.9), cf(SX, STAKE_T - 0.7, SZ, 0, 30, 0), BONE_DK)

		-- main vine: coils up the femur
		local vine = {}
		local N = 15
		for i = 0, N do
			local f = i / N
			local a = 160 + f * 2.4 * 360
			local r = 1.1 + 0.12 * math.sin(i)
			local x, z = polar(r, a)
			table.insert(vine, v(SX + x, RIMY + 0.3 + f * (STAKE_T - RIMY + 0.2), SZ + z))
		end
		for i = 1, N do
			local w = 0.62 - 0.22 * (i / N)
			B:bar(crop, vine[i] - (vine[i + 1] - vine[i]).Unit * 0.12, vine[i + 1] + (vine[i + 1] - vine[i]).Unit * 0.12, w, w, (i % 2 == 0) and VINE or VINE_DK)
		end
		-- the vine tip arches up over the femur into a blossom
		local tipA = vine[N + 1]
		local tipB = v(SX - 0.4, STAKE_T + 2.0, SZ - 0.6)
		local tipC = v(SX - 1.5, STAKE_T + 3.1, SZ - 1.0)
		B:bar(crop, tipA, tipB, 0.42, 0.42, VINE)
		B:bar(crop, tipB, tipC, 0.36, 0.36, VINE_DK)
		blossom(tipC + v(0, 0.3, 0), 1.4, v(-0.5, 1, -0.5))
		-- curly tendrils
		local function tendril(p, dir, s)
			local d = v(dir.X, 0, dir.Z).Unit
			local side = d:Cross(v(0, 1, 0))
			local a = p + d * 0.7 * s + v(0, 0.3, 0)
			local b = a + d * 0.5 * s + v(0, 0.55, 0) * s
			local c = b - side * 0.45 * s + v(0, 0.2, 0)
			local e = c - d * 0.35 * s - v(0, 0.3, 0) * s
			B:bar(crop, p, a, 0.16, 0.16, VINE)
			B:bar(crop, a, b, 0.16, 0.16, VINE)
			B:bar(crop, b, c, 0.15, 0.15, VINE_DK)
			B:bar(crop, c, e, 0.14, 0.14, VINE_DK)
		end

		-- big leaves along the coil (pointing outward from the femur)
		for _, l in { { 3, LEAF, 1.9 }, { 5, LEAF_LT, 2.0 }, { 7, LEAF, 1.8 }, { 11, LEAF_LT, 1.8 }, { 13, LEAF, 1.7 }, { 16, LEAF_LT, 1.5 } } do
			local p = vine[l[1]]
			leaf(p, p - v(SX, p.Y, SZ), l[3], l[2])
		end
		tendril(vine[6], v(-1, 0, 0.3), 1.3)
		tendril(vine[12], v(0.8, 0, -0.6), 1.2)
		tendril(tipB, v(1, 0, 0.6), 1.1)

		-- hanging pumpkins on short drop stalks off the coil
		local function hang(p, dir, drop, s, yaw, glow)
			local d = v(dir.X, 0, dir.Z).Unit
			local e = p + d * 3.4 * s + v(0, 0.5, 0)
			local c = e + v(0, -drop - 1.5 * s, 0)
			B:bar(crop, p, e, 0.34, 0.34, VINE_DK)
			B:bar(crop, e, c + v(0, 1.4 * s, 0), 0.3, 0.3, STEM)
			pumpkin(c, s, yaw, glow)
		end
		hang(vine[9], v(1, 0, -0.1), 0.2, 0.8, 20, true)
		hang(vine[12], v(-1, 0, 0.6), 0.2, 0.72, -30, false)
		hang(vine[15], v(-0.6, 0, -1), 0.1, 0.72, 50, true)

		-- the giant pumpkin sitting in the skull
		local GS = 1.12
		pumpkin(v(-0.4, RIMY + 0.35 + 1.6 * GS, CZ - 0.6), GS, 15, true)
		leaf(v(-1.2, RIMY + 0.4, CZ + 1.4), v(-1, 0, 0.6), 1.3, LEAF_LT)
		leaf(v(1.6, RIMY + 0.4, CZ - 0.6), v(1, 0, -0.3), 1.2, LEAF)
		-- a little pumpkin peeking out of the mouth
		pumpkin(v(0.95, 2.9, -4.8), 0.4, -25, false, -8)
		-- a vine spilling out of the left socket down to a pumpkin on the mound
		local sv = { v(-2.0, 6.2, -1.4), v(-3.0, 6.0, -1.9), v(-3.7, 5.0, -2.3), v(-4.1, 4.1, -2.8) }
		for i = 1, #sv - 1 do
			B:bar(crop, sv[i], sv[i + 1] + (sv[i + 1] - sv[i]).Unit * 0.1, 0.36, 0.36, (i % 2 == 0) and VINE or VINE_DK)
		end
		leaf(sv[2], v(-1, 0, 0.5), 1.1, LEAF_LT)
		tendril(sv[3], v(-0.3, 0, -1), 0.9)
		pumpkin(v(-4.0, 1.6 + 0.72 * 1.55, -3.3), 0.72, 35, true)
		-- a second ground pumpkin + a blossom by the jaw
		pumpkin(v(4.3, 1.6 + 0.56 * 1.55, -2.1), 0.56, -20, false)
		B:bar(crop, v(4.3, 3.0, -2.1), v(3.4, 2.4, -0.9), 0.24, 0.24, VINE_DK)
		blossom(v(2.9, 2.35, -4.1), 0.95, v(0.3, 1, -0.6))
		B:bar(crop, v(2.9, 2.05, -4.1), v(4.0, 1.75, -3.2), 0.2, 0.2, VINE_DK)
		-- dry leaf litter
		for _, l in { { 1.6, 1.65, -5.3, 30 }, { -3.0, 1.65, 4.3, -20 } } do
			B:block(soil, v(1.0, 0.16, 0.8), cf(l[1], l[2], l[3], 0, l[4], 6), LEAF_RUST, S)
		end

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local pz = B:block(crop, v(2.6, 2.6, 2.6), cf(-0.4, RIMY + 2.1, CZ - 0.6), PUMP, { tr = 1, name = "PumpkinZone" })
		B:emitter(pz, "glow", { name = "PumpkinGlow", color = { "#ffa040", "#ff6a2a" }, rate = 1.4, size = { 3.0, 4.4, 0.8 } })
		B:emitter(pz, "ember", { name = "PumpkinEmbers", color = { "#ffe27a", "#ff8a24", "#e8401f" }, rate = 5, size = { 0.24, 0.16, 0 }, speed = { 0.5, 1.2 }, life = { 1.6, 2.8 }, spread = 35, accel = { 0, 1.0, 0 } })
		B:light(pz, { name = "PumpkinLight", color = "#ff8a3a", brightness = 1.3, range = 18 })
		local vz = B:block(crop, v(5, 8, 5), cf(SX, 13.5, SZ), PUMP, { tr = 1, name = "VineZone" })
		B:emitter(vz, "ember", { name = "VineEmbers", color = { "#ffd26a", "#ff7a1a" }, rate = 3, size = { 0.18, 0.12, 0 }, speed = { 0.3, 0.8 }, life = { 1.6, 2.6 }, spread = 45, accel = { 0, 0.8, 0 } })
		B:emitter(vz, "leaf", { name = "AshFlakes", color = { "#c9c3bd", "#8f8984", "#e6e0da" }, rate = 1.8, size = { 0.22, 0.22, 0.12 }, life = { 3.5, 5.5 }, speed = { 0.2, 0.5 }, accel = { 0.25, -0.7, 0.1 }, dir = "Bottom" })
		for i, g in sockets do
			B:emitter(g, "sparkle", { name = "SocketWisps" .. i, color = { TEAL_LT, TEAL, "#5fd8ff" }, rate = 3, size = { 0.16, 0.38, 0 }, life = { 1.4, 2.4 }, speed = { 0.3, 0.7 }, spread = 25, accel = { 0, 1.0, 0 } })
		end
		B:light(sockets[1], { name = "SocketLight", color = "#4fe8d4", brightness = 0.9, range = 8 })
		B:emitter(noseFx, "smoke", { name = "NostrilSmoke", color = { "#5a5254", "#8a8280" }, rate = 1.2, size = { 0.4, 1.0, 1.5 }, speed = { 0.6, 1.1 }, life = { 1.4, 2.2 }, spread = 12, accel = { 0, 0.6, 0 } })
	end,
}
