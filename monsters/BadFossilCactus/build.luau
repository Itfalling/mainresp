--!nocheck
-- Fossil Cactus (Bramble Badlands crop #3, Rare).
-- A tall stepped saguaro in the stud-plant style:
-- * stepped BADLANDS mound (bone "Soil"): charcoal basalt base, cracked
--   rust-red earth tier, ash-grey top, glowing lava cracks, bone fragments,
--   rib bones poking out of the ground, ash piles and basalt pebbles
-- * the cactus trunk is PETRIFIED at the bottom (stratified rust / sandstone
--   / bone bands with a little fossil fish imprint) and turns into a living
--   dusty teal-green ribbed column above
-- * three stepped arms, rows of tiny cartoon BONE spines along the ribs
-- * fossil-shell fruits: opalised ammonites (cream coiled shell, rust ribs,
--   teal/purple opal core) crowning the trunk and the arms
-- Static prop: no motion.luau, no VFX.
return {
	DisplayName = "Fossil Cactus",
	Rarity = "Rare",
	Element = "Earth",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Bramble Badlands) -------------------------------------
		local BAS_DK, BAS, BAS_LT = "#26211f", "#37302d", "#4a413c"
		local RUST_DK, RUST, RUST_LT = "#6e2e1c", "#924027", "#b45a35"
		local ASH_DK, ASH, ASH_LT = "#615b58", "#857e7a", "#aaa39d"
		local BONE, BONE_DK, BONE_SH = "#f1e6cb", "#d8c59e", "#b9a27a"
		local LAVA, LAVA_Y = "#ff5a14", "#ffa82a"
		local SST, SST_LT = "#c98a55", "#e0ad78"
		local CAC_DK, CAC, CAC_MID, CAC_LT = "#2a6b58", "#358a6f", "#44a082", "#8ad8b2"
		local OPAL_T, OPAL_P = "#3fd6c8", "#9a5cff"
		local SH_TAN = "#a8663c"

		local seed = 17303
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
		disc(0, 0.9, 6.5, BAS_DK)
		edge(0, 0.9, 6.55, 15, { BAS_DK, BAS, BAS_DK }, 0.5, { 1.7, 2.6 }, { 1.3, 1.8 })
		disc(0.9, 0.7, 4.8, RUST_DK)
		edge(0.9, 0.7, 4.85, 11, { RUST_DK, RUST, RUST_DK }, 0.35, { 1.5, 2.2 }, { 1.2, 1.6 })
		disc(1.6, 0.55, 3.1, ASH)
		local TOP = 2.15

		-- glowing lava cracks: dark groove + thin neon vein, zig-zagging out
		local function crack(deg, r0, y, segs)
			local p = pv(r0, deg, y)
			local a = deg
			for k = 1, segs do
				a = a + ((k % 2 == 0) and 14 or -14)
				local q = p + pv(1.05, a, 0)
				B:bar(soil, p, q, 0.8, 0.1, BAS_DK, S)
				B:bar(soil, p, q, 0.4, 0.18, (k == 1) and LAVA_Y or LAVA, SN)
				p = q
			end
		end
		crack(25, 4.95, 0.93, 2)
		crack(150, 4.95, 0.93, 1)
		crack(230, 5.0, 0.93, 2)
		crack(318, 4.95, 0.93, 1)
		crack(95, 3.25, 1.63, 1)
		crack(275, 3.25, 1.63, 1)

		-- ash piles (stepped little heaps)
		for _, a in { { 4.4, -4.0, 1.0 }, { -5.6, 1.6, 1.1 }, { 2.0, 5.3, 0.9 } } do
			B:block(soil, v(1.3 * a[3], 0.35, 1.1 * a[3]), cf(a[1], 1.07, a[2], 0, jit(30), 0), ASH, S)
			B:block(soil, v(0.75 * a[3], 0.3, 0.65 * a[3]), cf(a[1], 1.35, a[2], 0, jit(30), 0), ASH_LT, S)
		end
		-- basalt rocks + pebbles
		for _, s in { { 5.6, 1.15, 1.8, 1.1, 20, BAS }, { -4.9, 1.1, -3.5, 1.0, -25, BAS_LT }, { -1.4, 1.05, 5.9, 0.8, 10, BAS } } do
			B:block(soil, v(s[4] * 1.35, s[4], s[4] * 1.05), cf(s[1], s[2], s[3], jit(6), s[5], jit(6)), s[6], S)
		end
		B:block(soil, v(0.8, 0.5, 0.7), cf(5.6, 1.85, 1.8, 0, 50, 0), RUST, S)
		for _, p in { { 3.6, -5.4, ASH_DK }, { -3.1, -5.2, BAS_LT }, { 6.0, -1.6, RUST_LT }, { -6.0, -1.0, ASH_DK } } do
			B:block(soil, v(0.5, 0.32, 0.42), cf(p[1], 1.04, p[2], 0, jit(40), 0), p[3], S)
		end

		-- cartoon bone fragments (bar + knobbly ends)
		local function bone(c, len, s)
			B:block(soil, v(len, 0.3 * s, 0.32 * s), c, BONE, S)
			for e = -1, 1, 2 do
				B:block(soil, v(0.36 * s, 0.38 * s, 0.62 * s), c * CFrame.new(e * len / 2, 0.02, 0), BONE_DK, S)
			end
		end
		bone(cf(-3.6, 1.78, -2.3, 0, 35, 0), 1.3, 1)
		bone(cf(5.3, 1.08, -2.9, 0, -60, 0), 1.5, 1.1)
		bone(cf(-2.6, 1.08, 5.4, 0, 15, 4), 1.2, 1)

		-- loose fossil shells half-sunk in the rust earth (simple 4-block coils)
		for _, f in { { -4.1, 1.75, 1.2, 205, 0.55 }, { 1.6, 1.15, -5.6, 345, 0.5 } } do
			local c = cf(f[1], f[2], f[3]) * CFrame.Angles(0, -rad(f[4]), 0) * ang(-25, 0, 0)
			local sc = f[5]
			B:block(soil, v(2.3 * sc, 1.5 * sc, 0.9 * sc), c, BONE, S)
			B:block(soil, v(1.5 * sc, 2.3 * sc, 0.88 * sc), c, BONE, S)
			B:block(soil, v(1.3 * sc, 1.3 * sc, 0.9 * sc), c * CFrame.new(0.1 * sc, 0.1 * sc, -0.15 * sc) * ang(0, 0, 45), SH_TAN, S)
			B:block(soil, v(0.55 * sc, 0.55 * sc, 0.9 * sc), c * CFrame.new(0.2 * sc, 0.18 * sc, -0.3 * sc), OPAL_T, S)
		end

		-- curved rib bones poking out of the ground
		local function rib(deg, r, h, lean)
			local p0 = pv(r, deg, 0.6)
			local out = pv(1, deg, 0)
			local p1 = p0 + out * (0.25 * lean) + v(0, h * 0.55, 0)
			local p2 = p1 - out * (0.55 * lean) + v(0, h * 0.45, 0)
			B:bar(soil, p0, p1 + (p1 - p0).Unit * 0.15, 0.42, 0.42, BONE_DK, S)
			B:bar(soil, p1, p2, 0.36, 0.36, BONE, S)
		end
		rib(200, 6.0, 2.4, 1.0)
		rib(214, 5.9, 2.0, 1.0)
		rib(186, 6.1, 1.8, 1.0)

		------------------------------------------------------------------
		-- CACTUS (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		-- one stepped octagonal slab of cactus
		local function slab(x, z, y0, h, w, col)
			B:block(crop, v(w, h, w * 0.62), cf(x, y0 + h / 2, z), col)
			B:block(crop, v(w * 0.62, h - 0.02, w), cf(x, y0 + h / 2, z), col)
		end
		-- light ribs down each flat face of a column piece
		local function ribs(x, z, y0, y1, w, col)
			local h = y1 - y0
			for k = 0, 3 do
				local dx, dz = polar(w / 2 + 0.04, k * 90)
				local sz = (k % 2 == 0) and v(0.5, h, 0.3) or v(0.3, h, 0.5)
				B:block(crop, sz, cf(x + dx, y0 + h / 2, z + dz), col)
			end
		end
		-- bone spines: tiny cartoon bones poking diagonally out of the edges
		local spineN = 0
		local function spines(x, z, y0, y1, w, step, off)
			local y = y0 + (off or 0.6)
			local k = 0
			while y < y1 - 0.3 do
				local deg = 45 + 90 * ((k + spineN) % 4)
				local dir = pv(1, deg, 0)
				local base = v(x, y, z) + dir * (w * 0.42)
				local tip = base + dir * 0.75 + v(0, 0.45, 0)
				B:bar(crop, base, tip, 0.22, 0.22, BONE_DK)
				B:block(crop, v(0.42, 0.38, 0.42), CFrame.new(tip) * ang(0, -deg, 0), BONE)
				y = y + step
				k = k + 1
			end
			spineN = spineN + 1
		end
		-- column piece: banded slabs + ribs + spines
		local function column(x, z, y0, y1, w0, w1, segH)
			local n = math.max(1, math.floor((y1 - y0) / segH + 0.5))
			local h = (y1 - y0) / n
			for i = 0, n - 1 do
				local f = (n == 1) and 0 or i / (n - 1)
				local w = w0 + (w1 - w0) * f
				slab(x, z, y0 + i * h, h + 0.02, w, (i % 2 == 0) and CAC or CAC_MID)
			end
			ribs(x, z, y0 + 0.05, y1 - 0.05, (w0 + w1) / 2 - 0.05, CAC_LT)
		end
		-- stepped dome cap
		local function dome(x, z, y, w)
			slab(x, z, y, 0.6, w * 0.8, CAC_MID)
			slab(x, z, y + 0.55, 0.45, w * 0.5, CAC_LT)
		end

		-- PETRIFIED base: stratified stone bands
		local bands = { { 0.75, 3.3, SST }, { 0.6, 3.2, RUST_LT }, { 0.7, 3.15, BONE_DK }, { 0.6, 3.05, SST_LT }, { 0.55, 3.0, RUST } }
		local y = TOP - 0.2
		for i, b in bands do
			slab(0, 0, y, b[1] + 0.02, b[2] + ((i % 2 == 0) and 0.12 or 0), b[3])
			y = y + b[1]
		end
		local PET = y
		-- cracks in the stone + little fossil fish imprint on the front
		B:block(crop, v(0.18, 1.6, 0.12), cf(0.9, TOP + 1.1, -1.66, 0, 0, 14), BAS)
		B:block(crop, v(0.18, 0.9, 0.12), cf(1.15, TOP + 2.2, -1.66, 0, 0, -20), BAS)
		local fish = cf(-0.55, TOP + 1.55, -1.7)
		B:block(crop, v(1.25, 0.16, 0.12), fish, BONE)
		for k = -1, 1 do
			B:block(crop, v(0.12, 0.55, 0.12), fish * CFrame.new(k * 0.3, 0, 0), BONE)
		end
		B:block(crop, v(0.32, 0.32, 0.12), fish * CFrame.new(-0.72, 0, 0), BONE)
		B:block(crop, v(0.22, 0.5, 0.12), fish * CFrame.new(0.72, 0, 0), BONE)
		-- the living cactus starts with a slightly wider collar
		slab(0, 0, PET - 0.1, 0.5, 3.1, CAC_DK)

		-- stone patches: the petrification creeping up the living trunk
		for _, q in { { 330, 0.15, 1.2, 0.9, SST }, { 20, 0.8, 0.9, 0.7, BONE_DK }, { 120, 0.3, 1.0, 0.8, SST_LT }, { 215, 0.5, 1.3, 0.8, SST }, { 285, 1.4, 0.7, 0.6, RUST_LT } } do
			local d = q[1]
			B:block(crop, v(q[3], q[4], 0.3), facing(pv(1.43, d, PET + 0.35 + q[2] + q[4] / 2), d), q[5])
		end

		-- MAIN TRUNK
		local MAIN_TOP = 14.0
		column(0, 0, PET + 0.35, MAIN_TOP, 2.85, 2.45, 1.7)
		spines(0, 0, PET + 0.4, MAIN_TOP, 2.85, 1.25, 0.5)
		spines(0, 0, PET + 0.4, MAIN_TOP, 2.85, 1.25, 1.1)
		dome(0, 0, MAIN_TOP, 2.45)

		-- ARMS: horizontal elbow out of the trunk, then up
		local function arm(deg, y0, reach, y1, w)
			local base = v(0, y0, 0)
			local elbow = pv(reach, deg, y0)
			local ex, ez = elbow.X, elbow.Z
			B:bar(crop, base, elbow, w, w, CAC)
			B:bar(crop, base + pv(0.3, deg, 0), elbow, w * 0.62, w + 0.12, CAC_MID)
			B:bar(crop, base + v(0, -w / 2 - 0.02, 0) + pv(1.2, deg, 0), elbow + v(0, -w / 2 - 0.02, 0), 0.4, 0.2, CAC_LT)
			-- elbow knuckle
			slab(ex, ez, y0 - w / 2 - 0.05, w + 0.1, w + 0.1, CAC)
			column(ex, ez, y0 + w / 2 + 0.05, y1, w, w * 0.85, 1.5)
			spines(ex, ez, y0 + w / 2, y1, w, 1.2, 0.5)
			dome(ex, ez, y1, w * 0.85)
			return v(ex, y1 + 1.0, ez)
		end
		local armR = arm(84, 6.6, 3.9, 11.0, 1.85)
		local armL = arm(272, 8.8, 3.7, 12.6, 1.7)
		local armB = arm(176, 5.4, 3.4, 8.8, 1.6)

		------------------------------------------------------------------
		-- FOSSIL-SHELL FRUITS: opalised ammonites
		------------------------------------------------------------------
		-- shell stands like a coin; its flat face looks toward `deg`
		local function ammonite(p, deg, s, tilt)
			local c = facing(p, deg) * ang(0, 0, tilt or 0)
			local function at(x, y, z)
				return c * CFrame.new(x * s, y * s, z * s)
			end
			-- outer whorl (octagon)
			B:block(crop, v(2.3 * s, 1.5 * s, 1.0 * s), at(0, 0, 0), BONE)
			B:block(crop, v(1.5 * s, 2.3 * s, 0.98 * s), at(0, 0, 0), BONE)
			-- rust growth ribs around the rim
			for k = 0, 5 do
				local a = rad(k * 60 + 15)
				B:block(crop, v(0.3 * s, 0.6 * s, 1.08 * s), at(math.cos(a) * 0.82, math.sin(a) * 0.82, 0) * CFrame.Angles(0, 0, a + math.pi / 2), SH_TAN)
			end
			-- inner whorls stepping forward and off-centre (reads as a coil)
			B:block(crop, v(1.45 * s, 1.45 * s, 1.0 * s), at(0.12, 0.1, -0.16) * ang(0, 0, 45), BONE_DK)
			B:block(crop, v(0.95 * s, 0.95 * s, 1.0 * s), at(0.22, 0.18, -0.3), BONE)
			-- opal core
			B:block(crop, v(0.55 * s, 0.55 * s, 1.0 * s), at(0.3, 0.24, -0.42) * ang(0, 0, 45), OPAL_T)
			B:block(crop, v(0.26 * s, 0.26 * s, 1.0 * s), at(0.3, 0.24, -0.52), OPAL_P)
			-- aperture lip at the bottom
			B:block(crop, v(0.9 * s, 0.4 * s, 1.15 * s), at(-0.55, -0.98, 0), BONE_SH)
		end

		ammonite(v(0, MAIN_TOP + 2.3, 0), -10, 1.12, 0)
		ammonite(armR + v(0, 0.6, 0), 28, 0.95, 6)
		ammonite(armL + v(0, 0.6, 0), -30, 0.95, -6)
		ammonite(armB + v(0, 0.5, 0), 200, 0.8, 0)
		-- two shells clinging to the trunk sides
		ammonite(pv(1.7, 30, 9.9), 30, 0.75, 20)
		ammonite(pv(1.6, 300, 6.4), 300, 0.65, -15)

		-- a baby fossil cactus pup on the mound
		local px, pz = 3.2, -2.5
		slab(px, pz, TOP - 0.55 + 0, 0.6, 1.2, SST)
		slab(px, pz, TOP + 0.0, 1.3, 1.05, CAC)
		slab(px, pz, TOP + 1.25, 0.4, 0.7, CAC_LT)
		B:bar(crop, v(px - 0.45, TOP + 0.8, pz - 0.2), v(px - 0.85, TOP + 1.1, pz - 0.45), 0.14, 0.14, BONE)
		B:bar(crop, v(px + 0.45, TOP + 0.6, pz - 0.2), v(px + 0.85, TOP + 0.9, pz - 0.45), 0.14, 0.14, BONE)
	end,
}
