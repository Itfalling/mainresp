--!nocheck
-- Dino Spine Tree (Bramble Badlands crop #9, Divine): a hardy badlands tree
-- that grew up the fossil spine of a giant dinosaur.
-- * a stepped cracked-rock mound (bone "Soil", parts "Soil"): charcoal basalt
--   base, rust-red cracked earth, ash-grey top, glowing lava cracks, a little
--   lava pool, bone fragments, a cute dog-bone, pebbles and a teal crystal
-- * the GIANT DINO SPINE: ten stacked cream vertebrae curving up out of the
--   ground (bones "Crop" + "Upper"), each with side processes and a teal
--   fossil glint (GlintN) and a tall dorsal plate on its own bone (PlateN) so
--   the crest can ripple; three pairs of half-buried ribs at the foot
-- * two twisted charcoal bark strands wind up around the vertebrae and burst
--   into a sage/olive canopy with rust + ochre leaves ("Canopy",
--   "CanopyTop" bones)
-- * six glowing AMMONITE FOSSIL FRUITS hang under the canopy on stems (bones
--   FruitN, pivot at the stem top) with neon teal cores (FossilCoreN)
-- * VFX: teal fossil motes, falling sage/rust leaves, lava embers from the
--   cracks, a teal "awaken" burst + spine sparks for the signature beat,
--   teal fruit light + warm lava light
-- Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Dino Spine Tree",
	Rarity = "Divine",
	Element = "Earth",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad, deg = math.rad, math.deg

		-- palette ------------------------------------------------------------
		local BASALT_DK, BASALT, BASALT_LT = "#241f20", "#332c2c", "#4a403d"
		local RUST_DK, RUST, RUST_LT = "#5e2a1d", "#7c3a26", "#9a4c30"
		local ASH, ASH_LT, ASH_DK = "#8d8680", "#b0aaa2", "#6c6560"
		local CRACK = "#1a1213"
		local LAVA, LAVA_HOT, LAVA_DK = "#ff7a1a", "#ffb43a", "#d4421a"
		local BONE, BONE_LT, BONE_DK, BONE_TAN = "#e8dcbc", "#f6eedb", "#c9b58c", "#a88e64"
		local BARK_DK, BARK, BARK_LT = "#231a17", "#33261f", "#4c3a2c"
		local LF_DK, LF, LF_MID, LF_LT, LF_OLIVE = "#3d6638", "#527f3f", "#6c9747", "#92b553", "#adb34a"
		local LF_RUST, LF_OCHRE = "#a5482a", "#c98c34"
		local TEAL, TEAL_LT, TEAL_DK = "#2fd6c0", "#9ff5e6", "#1f8f86"
		local CRYS, CRYS_LT = "#2fb3a3", "#86e8da"

		local seed = 909017
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function polar(r, d)
			local a = rad(d)
			return math.sin(a) * r, -math.cos(a) * r
		end
		local function outward(d)
			local x, z = polar(1, d)
			return v(x, 0, z)
		end
		local function at(r, d, y)
			local x, z = polar(r, d)
			return v(x, y, z)
		end
		local function facing(p, d)
			return CFrame.new(p) * CFrame.Angles(0, -rad(d), 0)
		end

		------------------------------------------------------------------
		-- CRACKED BADLANDS MOUND (bone "Soil", parts "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local SN = { name = "Soil", mat = "Neon" }
		local function oct(y0, y1, w, color)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(soil, v(w, h, w * 0.62), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.62, h + 0.02, w), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.85, h - 0.03, w * 0.85), cf(0, y, 0), color, S)
		end
		oct(0, 1.1, 17.2, BASALT_DK)
		oct(1.1, 2.2, 13.0, RUST_DK)
		oct(2.2, 3.0, 8.8, RUST)
		-- chunky edge rocks around the base + mid tier
		for i = 0, 15 do
			local a = i * 22.5 + jit(5)
			local x, z = polar(8.3 + jit(0.3), a)
			local h = 0.9 + rnd() * 0.7
			B:block(soil, v(2.6 + rnd() * 0.8, h, 2.0 + rnd() * 0.5), cf(x, h / 2, z, 0, -a + jit(10), 0),
				i % 3 == 0 and BASALT_LT or (i % 2 == 0 and BASALT or BASALT_DK), S)
		end
		for i = 0, 8 do
			local a = i * 40 + 12 + jit(8)
			local x, z = polar(6.2 + jit(0.3), a)
			local h = 0.8 + rnd() * 0.4
			B:block(soil, v(2.1 + rnd() * 0.5, h, 1.6), cf(x, 1.1 + h / 2, z, 0, -a + jit(12), 0), i % 2 == 0 and RUST or RUST_DK, S)
		end
		-- ash drifts on the tiers
		for _, m in { { 40, 7.6, 1.1, 2.4, ASH }, { 125, 7.7, 1.1, 2.0, ASH_LT }, { 200, 7.6, 1.1, 2.6, ASH }, { 300, 7.7, 1.1, 2.2, ASH_DK },
			{ 80, 5.6, 2.2, 1.8, ASH_LT }, { 250, 5.5, 2.2, 2.0, ASH }, { 0, 3.6, 3.0, 1.6, ASH_LT }, { 160, 3.4, 3.0, 1.4, ASH } } do
			local c = facing(at(m[2], m[1], m[3]), m[1])
			B:block(soil, v(m[4], 0.24, 1.3), c * ang(-8, 0, 0), m[5], S)
		end
		-- glowing lava cracks (dark groove + thin neon core), zig-zagging outward
		local function crack(r0, r1, d, y, zig)
			local pts = {}
			local n = 3
			for k = 0, n do
				local t = k / n
				local r = r0 + (r1 - r0) * t
				local dd = d + ((k % 2 == 0) and -zig or zig)
				table.insert(pts, at(r, dd, y))
			end
			for k = 1, n do
				B:bar(soil, pts[k], pts[k + 1], 0.5, 0.14, CRACK, S)
				B:bar(soil, pts[k] + v(0, 0.05, 0), pts[k + 1] + v(0, 0.05, 0), 0.22, 0.14, LAVA, SN)
			end
		end
		crack(4.6, 6.4, 60, 2.22, 6)
		crack(4.6, 6.4, 215, 2.22, 7)
		crack(6.8, 8.4, 140, 1.12, 5)
		crack(6.8, 8.4, 330, 1.12, 6)
		crack(2.4, 4.2, 120, 3.02, 9)
		-- little lava pool on the front-right of the mid tier
		do
			local p = at(5.3, 28, 2.2)
			B:block(soil, v(3.0, 0.5, 2.2), facing(p + v(0, 0.06, 0), 28), CRACK, S)
			B:block(soil, v(2.4, 0.4, 1.6), facing(p + v(0, 0.16, 0), 28), LAVA_DK, S)
			B:block(soil, v(1.6, 0.4, 1.0), facing(p + v(0, 0.2, 0), 28), LAVA, SN)
			B:block(soil, v(0.6, 0.4, 0.5), facing(p + v(0.3, 0.24, -0.1), 28), LAVA_HOT, SN)
			for _, r in { { -1.6, 0.0, 0.8 }, { 1.6, 0.2, 0.7 }, { 0.2, 1.2, 0.6 }, { -0.6, -1.1, 0.55 } } do
				local q = facing(p, 28) * CFrame.new(r[1], 0.3, r[2])
				B:block(soil, v(r[3] * 1.2, r[3], r[3]), q * ang(0, jit(30), jit(8)), BASALT_LT, S)
			end
		end
		-- pebbles / small rocks
		for _, s in { { -7.4, 1.25, -2.4, 0.9, 20, BASALT_LT }, { 7.6, 1.2, 2.6, 0.8, -15, BASALT }, { -3.2, 2.5, 5.2, 0.7, 35, RUST_LT },
			{ 2.4, 1.15, 7.6, 0.75, 10, BASALT_LT }, { -5.6, 2.45, -1.8, 0.6, 50, ASH_DK } } do
			B:block(soil, v(s[4] * 1.3, s[4], s[4]), cf(s[1], s[2], s[3], 0, s[5], jit(6)), s[6], S)
		end
		-- bone fragments + a cute dog-bone on the mound
		for _, b in { { v(-6.4, 1.2, 3.4), v(-4.9, 1.3, 4.6) }, { v(5.9, 2.3, -2.2), v(6.7, 2.35, -0.8) }, { v(-1.6, 1.2, -7.4), v(-0.2, 1.25, -7.9) } } do
			B:bar(soil, b[1], b[2], 0.38, 0.38, BONE, S)
			B:block(soil, v(0.55, 0.5, 0.55), CFrame.new(b[1]) * ang(0, 30, 0), BONE_LT, S)
		end
		do
			local c = cf(-3.6, 3.22, -2.6, 0, 35, 0)
			B:block(soil, v(1.9, 0.42, 0.42), c, BONE_LT, S)
			for _, sx in { -1, 1 } do
				B:block(soil, v(0.42, 0.44, 0.5), c * CFrame.new(sx * 1.0, 0, -0.26), BONE, S)
				B:block(soil, v(0.42, 0.44, 0.5), c * CFrame.new(sx * 1.0, 0, 0.26), BONE, S)
			end
		end
		-- teal crystal cluster (back-left) + a little purple one
		do
			local base = v(-5.4, 2.2, 3.6)
			B:block(soil, v(0.9, 2.4, 0.9), CFrame.new(base + v(0, 1.0, 0)) * ang(8, 20, -10), CRYS, S)
			B:block(soil, v(0.5, 0.6, 0.5), CFrame.new(base + v(-0.2, 2.25, 0.2)) * ang(8, 20, -10), CRYS_LT, S)
			B:block(soil, v(0.7, 1.5, 0.7), CFrame.new(base + v(0.8, 0.6, -0.3)) * ang(-6, 40, 22), CRYS, S)
			B:block(soil, v(0.6, 1.1, 0.6), CFrame.new(base + v(-0.7, 0.5, -0.5)) * ang(10, -10, -28), CRYS_LT, S)
			B:block(soil, v(1.6, 0.4, 1.4), CFrame.new(base + v(0, 0.1, 0)) * ang(0, 15, 0), BASALT, S)
		end
		do
			local base = v(6.2, 1.1, 4.2)
			B:block(soil, v(0.7, 1.6, 0.7), CFrame.new(base + v(0, 0.7, 0)) * ang(-10, 10, 14), "#8a5cd6", S)
			B:block(soil, v(0.55, 1.0, 0.55), CFrame.new(base + v(0.6, 0.4, 0.2)) * ang(6, 30, -20), "#b893f0", S)
		end
		-- dry thorny bramble twigs
		for _, t in { { v(3.4, 3.05, 2.8), v(5.4, 2.25, 4.4) }, { v(-6.8, 1.15, -4.6), v(-8.6, 1.4, -2.6) } } do
			B:bar(soil, t[1], t[2], 0.3, 0.3, BARK_LT, S)
			local mid = t[1]:Lerp(t[2], 0.5)
			B:bar(soil, mid, mid + v(0, 0.55, 0.2), 0.16, 0.16, BONE_LT, S)
		end

		------------------------------------------------------------------
		-- THE DINO SPINE (bones "Crop" lower half, "Upper" upper half)
		------------------------------------------------------------------
		local BASE = 3.0
		local N = 9
		local function spineAt(t)
			local y = BASE + 0.6 + 10.0 * t
			local z = 0.8 * math.sin(math.pi * t) - 0.4 * t
			local x = 0.3 * math.sin(2 * math.pi * t)
			return v(x, y, z)
		end
		local function spineW(t)
			return 3.4 - 1.0 * t
		end
		local crop = B:bone("Crop", "Root", v(0, BASE, 0))
		local SPLIT = 5 -- vertebrae 1..5 on Crop, 6..9 on Upper
		local upperPivot = spineAt((SPLIT - 0.5) / (N - 1))
		local upper = B:bone("Upper", "Crop", upperPivot)

		-- base socket: the spine bursts out of a cracked rock collar
		B:block(crop, v(4.4, 0.8, 4.0), cf(0, BASE + 0.2, 0.1, 0, 10, 0), BASALT)
		B:block(crop, v(3.4, 0.5, 3.4), cf(0, BASE + 0.55, 0.1, 0, -14, 0), BASALT_LT)

		local verts = {}
		for i = 1, N do
			local t = (i - 1) / (N - 1)
			local p = spineAt(t)
			local p2 = spineAt(math.min(1, t + 0.05))
			local p1 = spineAt(math.max(0, t - 0.05))
			local tan = (p2 - p1).Unit
			local rx = deg(math.atan2(tan.Z, tan.Y))
			local rz = -deg(math.atan2(tan.X, tan.Y))
			local F = CFrame.new(p) * ang(rx, 0, rz)
			local bone = i <= SPLIT and crop or upper
			local w = spineW(t)
			verts[i] = { F = F, w = w, t = t, bone = bone, bname = i <= SPLIT and "Crop" or "Upper" }
			-- centrum (stepped: core + lighter cap ring) and the tan disc below it
			B:block(bone, v(w, 1.0, w * 0.86), F, BONE)
			B:block(bone, v(w * 0.8, 0.3, w * 0.7), F * CFrame.new(0, 0.6, 0), BONE_LT)
			B:block(bone, v(w * 0.72, 0.4, w * 0.62), F * CFrame.new(0, -0.65, 0), BONE_DK)
			-- teal fossil glint on the front face
			B:block(bone, v(w * 0.5, 0.26, 0.14), F * CFrame.new(0, 0.02, -w * 0.43 - 0.06), TEAL, { mat = "Neon", name = "Glint" .. i })
			-- side processes (stepped bars ending in knobs)
			for _, sx in { -1, 1 } do
				local a = (F * CFrame.new(sx * w * 0.42, 0.05, 0.2)).Position
				local b = (F * CFrame.new(sx * (w * 0.5 + 2.3 - 1.3 * t), 0.55, 0.5)).Position
				B:bar(bone, a, b, 0.6, 0.6, BONE)
				B:block(bone, v(0.75, 0.75, 0.75), CFrame.new(b) * F.Rotation * ang(0, 0, 45), BONE_TAN)
			end
		end
		-- dorsal plates: one bone each (pivot at the back of the centrum)
		for i = 1, N do
			local vt = verts[i]
			local F, w, t = vt.F, vt.w, vt.t
			local piv = F * CFrame.new(0, 0.1, w * 0.36)
			local plate = B:bone("Plate" .. i, vt.bname, piv)
			local L = 3.8 - 1.4 * t + ((i % 2 == 0) and 0.4 or 0)
			local tipL = (piv * CFrame.Angles(rad(-38), 0, 0) * CFrame.new(0, 0, L)).Position
			local midL = (piv * CFrame.Angles(rad(-38), 0, 0) * CFrame.new(0, 0, L * 0.55)).Position
			B:bar(plate, piv.Position, tipL, 0.55, 0.9, BONE_DK)
			B:bar(plate, piv.Position, midL, 0.75, 1.3, BONE_TAN)
			B:block(plate, v(0.75, 0.75, 0.75), CFrame.new(tipL) * F.Rotation * ang(45, 0, 0), BONE_LT)
		end
		-- half-buried ribs at the foot: two pairs arching out to the sides and
		-- curving down into the mound (front pair forward, back pair backward)
		for k, dz in { { 1, -1 }, { 3, 1 } } do
			local vt = verts[dz[1]]
			local fz = dz[2]
			for _, sx in { -1, 1 } do
				local y = vt.F.Position.Y
				local zc = vt.F.Position.Z
				local w = vt.w * 0.5
				local pts = {
					v(sx * w * 0.9, y + 0.1, zc + 0.15),
					v(sx * (w + 1.5), y + 0.9, zc + 0.3 * fz),
					v(sx * (w + 2.8), y + 0.6, zc + 1.0 * fz),
					v(sx * (w + 3.5), y - 0.6, zc + 1.9 * fz),
					v(sx * (w + 3.4), 1.9, zc + 2.7 * fz),
				}
				for j = 1, 4 do
					B:bar(crop, pts[j], pts[j + 1] + (pts[j + 1] - pts[j]).Unit * 0.2, 0.62 - 0.04 * j, 0.62 - 0.04 * j, (j % 2 == 0) and BONE_LT or BONE)
				end
			end
		end

		------------------------------------------------------------------
		-- TWISTED BARK STRANDS winding up the spine
		------------------------------------------------------------------
		local function strand(d0, turns, n, col1, col2, thick)
			local pts = {}
			for k = 0, n do
				local t = k / n
				local tt = 0.02 + 0.98 * t
				local c = spineAt(tt)
				local r = spineW(tt) * 0.62 + 0.55
				local dd = d0 + turns * 360 * t
				local x, z = polar(r, dd)
				table.insert(pts, { p = c + v(x, 0, z), d = dd, t = tt })
			end
			for k = 1, n do
				local a, b = pts[k], pts[k + 1]
				local bone = (a.t < (SPLIT - 0.5) / (N - 1)) and crop or upper
				B:bar(bone, a.p, b.p + (b.p - a.p).Unit * 0.3, thick, thick * 0.85, (k % 2 == 0) and col1 or col2)
				if k % 3 == 1 and k > 1 then
					B:block(bone, v(1.0, 1.0, 1.0), CFrame.new(b.p + outward(b.d) * 0.6) * ang(jit(25), rnd() * 90, jit(25)), (k % 2 == 0) and LF_MID or LF_OLIVE)
				end
			end
			return pts
		end
		strand(200, 1.0, 9, BARK, BARK_DK, 0.85)
		strand(20, 1.0, 9, BARK_DK, BARK_LT, 0.75)
		-- roots splaying from the strand feet onto the mound
		for k, a in { 200, 270, 20, 100, 150, 330 } do
			local p0 = at(2.2, a, BASE + 0.4)
			local p1 = at(3.8, a + 8, BASE - 0.1)
			local p2 = at(5.0, a + 14, 2.0)
			B:bar(crop, p0, p1, 1.1, 0.9, (k % 2 == 0) and BARK or BARK_DK)
			B:bar(crop, p1, p2, 0.8, 0.7, BARK_DK)
		end

		-- trunk crown: the strands merge above the top vertebra
		local topP = spineAt(1)
		local CROWNY = topP.Y + 1.0
		B:block(upper, v(3.2, 1.8, 3.2), cf(topP.X, CROWNY, topP.Z, 0, 20, 0), BARK)
		B:block(upper, v(2.6, 1.6, 2.6), cf(topP.X, CROWNY + 1.3, topP.Z, 0, -15, 0), BARK_DK)

		------------------------------------------------------------------
		-- CANOPY
		------------------------------------------------------------------
		local CX, CZ = topP.X, topP.Z
		local CPY = CROWNY + 0.8
		local canopy = B:bone("Canopy", "Upper", v(CX, CPY, CZ))
		-- branches
		for k = 0, 5 do
			local a = k * 60 + 15
			local x0, z0 = polar(0.5, a)
			local x1, z1 = polar(4.0, a + 8)
			B:bar(canopy, v(CX + x0, CPY - 0.4, CZ + z0), v(CX + x1, CPY + 1.8, CZ + z1), 1.1, 1.0, (k % 2 == 0) and BARK_LT or BARK)
		end
		local function leaf(bone, p, s, col)
			B:block(bone, v(s, s, s), CFrame.new(p) * ang(jit(18), rnd() * 90, jit(18)), col)
		end
		local AY = CPY + 2.6
		local cubes = {}
		-- lower ring: varied sizes / heights so the crown is a soft dome, not a drum
		local ringCols = { LF_DK, LF, LF_MID, LF_DK, LF_RUST, LF, LF_MID, LF_DK, LF, LF_OCHRE, LF_MID }
		for i = 0, 10 do
			local a = i * (360 / 11) + jit(5)
			local up = (i % 2 == 0) and 0.45 or -0.35
			local x, z = polar(4.9 + jit(0.4), a)
			local p = v(CX + x, AY + up + jit(0.25), CZ + z)
			local s = 3.3 + rnd() * 0.8
			if ringCols[i + 1] == LF_RUST or ringCols[i + 1] == LF_OCHRE then
				s = 3.0
			end
			leaf(canopy, p, s, ringCols[i + 1])
			table.insert(cubes, { p = p, s = s, a = a, bone = canopy })
		end
		-- drooping tips under a few ring cubes (softer silhouette)
		for _, k in { 1, 4, 7, 10 } do
			local c = cubes[k]
			leaf(canopy, c.p + outward(c.a) * 0.6 + v(0, -c.s * 0.55 - 0.6, 0), 1.8, (k % 2 == 0) and LF_MID or LF)
		end
		for _, d in { { 2.2, 30, 0.9, 4.4, LF_DK }, { 2.2, 150, 1.0, 4.4, LF }, { 2.2, 270, 0.9, 4.4, LF_DK } } do
			local x, z = polar(d[1], d[2])
			leaf(canopy, v(CX + x, AY + d[3], CZ + z), d[4], d[5])
		end
		for i = 0, 8 do
			local a = i * 40 + 20
			local x, z = polar(3.6 + jit(0.3), a)
			leaf(canopy, v(CX + x, AY + 2.0 + jit(0.3), CZ + z), 2.5 + rnd() * 0.5, ({ LF_LT, LF_MID, LF_OLIVE, LF_MID, LF_LT, LF_OLIVE, LF_MID, LF_LT, LF_OLIVE })[i + 1])
		end
		local canopyTop = B:bone("CanopyTop", "Canopy", v(CX, AY + 1.8, CZ))
		local BY = AY + 3.1
		for i = 0, 5 do
			local a = i * 60 + 10 + jit(5)
			local x, z = polar(2.3, a)
			leaf(canopyTop, v(CX + x, BY + jit(0.25), CZ + z), 2.9, ({ LF, LF_MID, LF_LT, LF_MID, LF, LF_OLIVE })[i + 1])
		end
		leaf(canopyTop, v(CX, BY + 1.0, CZ), 2.6, LF_LT)
		for i = 0, 4 do
			local a = i * 72 + 40
			local x, z = polar(1.5, a)
			leaf(canopyTop, v(CX + x, BY + 1.3, CZ + z), 1.6, ({ LF_OLIVE, LF_LT, LF_OCHRE, LF_LT, LF_RUST })[i + 1])
		end
		-- small fossil "buds" half-sunk into the canopy (teal glints)
		for n, idx in { 2, 6, 9 } do
			local c = cubes[idx]
			local p = c.p + outward(c.a) * (c.s * 0.5 + 0.05) + v(0, c.s * 0.15, 0)
			local F = facing(p, c.a)
			B:block(canopy, v(0.9, 0.9, 0.5), F * ang(0, 0, 45), BONE)
			B:block(canopy, v(0.45, 0.45, 0.14), F * CFrame.new(0, 0, -0.28) * ang(0, 0, 45), TEAL, { mat = "Neon", name = "Bud" .. n })
		end

		------------------------------------------------------------------
		-- AMMONITE FOSSIL FRUITS (bones FruitN, pivot at the stem top)
		------------------------------------------------------------------
		local function ammonite(bone, F, s, coreName)
			-- ribbed shell: a ring of alternating chambers around a cream disc
			B:block(bone, v(1.35 * s, 1.35 * s, 0.82 * s), F * ang(0, 0, 45), BONE_LT)
			local R = F * ang(90, 0, 0)
			B:ring(bone, R, 0.98 * s, 4, v(0.86 * s, 0.7 * s, 0.6 * s), BONE)
			B:ring(bone, R * ang(0, 45, 0), 0.98 * s, 4, v(0.86 * s, 0.66 * s, 0.6 * s), BONE_DK)
			-- spiral hint: a tan inner whorl + glowing teal core on both faces
			B:block(bone, v(0.55 * s, 0.55 * s, 0.12), F * CFrame.new(0.22 * s, 0.22 * s, -0.41 * s - 0.05) * ang(0, 0, 45), BONE_TAN)
			B:block(bone, v(0.55 * s, 0.55 * s, 0.14), F * CFrame.new(-0.05 * s, -0.08 * s, -0.41 * s - 0.08), TEAL, { mat = "Neon", name = coreName })
			B:block(bone, v(0.55 * s, 0.55 * s, 0.14), F * CFrame.new(0.05 * s, -0.08 * s, 0.41 * s + 0.08), TEAL, { mat = "Neon", name = coreName .. "B" })
			-- aperture lip at the bottom
			B:block(bone, v(0.8 * s, 0.4 * s, 0.95 * s), F * CFrame.new(0, -1.25 * s, 0), BONE_TAN)
		end
		local FRUITS = {
			-- deg, stem length, scale
			{ 25, 1.3, 1.15 },
			{ 85, 2.1, 1.1 },
			{ 145, 1.4, 1.15 },
			{ 205, 2.0, 1.1 },
			{ 265, 1.3, 1.15 },
			{ 325, 2.1, 1.1 },
		}
		for i, f in FRUITS do
			local x, z = polar(4.9, f[1])
			local top = v(CX + x, AY - 1.4, CZ + z)
			local bone = B:bone("Fruit" .. i, "Canopy", top)
			local s = f[3]
			local c = top + v(0, -f[2] - 1.15 * s, 0) + outward(f[1]) * 0.3
			B:bar(bone, top + v(0, 0.6, 0), c + v(0, 0.9 * s, 0), 0.3, 0.3, BARK_LT)
			B:block(bone, v(0.9, 0.18, 0.5), CFrame.new(top:Lerp(c, 0.4)) * ang(0, -f[1] + 50, 25), LF_LT)
			ammonite(bone, facing(c, f[1]), s, "FossilCore" .. i)
		end

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local moteZone = B:block(canopy, v(12, 6, 12), cf(CX, AY - 2.0, CZ), TEAL, { tr = 1, name = "MoteZone" })
		B:emitter(moteZone, "sparkle", { name = "FossilMotes", color = { TEAL_LT, TEAL, "#e8fff9" }, rate = 5, size = { 0.12, 0.4, 0 }, life = { 1.4, 2.4 }, speed = { 0.15, 0.5 } })
		local leafZone = B:block(canopy, v(11, 1, 11), cf(CX, AY - 0.8, CZ), LF, { tr = 1, name = "LeafZone" })
		B:emitter(leafZone, "leaf", { name = "FallingLeaves", color = { LF_LT, LF_OCHRE, LF_RUST }, rate = 1.2, size = { 0.45, 0.45, 0.3 }, life = { 3.5, 5 }, speed = { 0.3, 0.8 }, accel = { 0.3, -1.3, 0 }, dir = "Bottom" })
		local crackZone = B:block(soil, v(13, 0.4, 13), cf(0, 2.0, 0), LAVA, { tr = 1, name = "CrackZone" })
		B:emitter(crackZone, "ember", { name = "LavaEmbers", color = { LAVA_HOT, LAVA, LAVA_DK }, rate = 4, size = { 0.22, 0.14, 0 }, life = { 1.2, 2.2 }, speed = { 0.6, 1.6 }, spread = 25, accel = { 0, 1.4, 0 } })
		local spineZone = B:block(upper, v(3, 10, 3), CFrame.new(spineAt(0.55)), TEAL, { tr = 1, name = "SpineZone" })
		B:emitter(spineZone, "spark", { name = "SpineSparks", color = { TEAL_LT, TEAL }, rate = 0, size = { 0.3, 0.12, 0 }, speed = { 3, 6 } })
		local burstZone = B:block(canopy, v(9, 3, 9), cf(CX, AY - 1.6, CZ), TEAL, { tr = 1, name = "BurstZone" })
		B:emitter(burstZone, "burst", { name = "AwakenBurst", color = { TEAL_LT, TEAL, BONE_LT }, size = { 0.7, 0.45, 0 }, speed = { 6, 12 } })
		B:emitter(burstZone, "sparkle", { name = "AwakenGlitter", color = { "#e8fff9", TEAL_LT }, rate = 0, size = { 0.2, 0.5, 0 }, life = { 1.2, 2.2 }, speed = { 1, 3 } })
		B:light(moteZone, { name = "FossilLight", color = "#5ff0dc", brightness = 1.1, range = 16 })
		B:light(crackZone, { name = "LavaLight", color = "#ff7a2a", brightness = 0.9, range = 12 })
	end,
}
