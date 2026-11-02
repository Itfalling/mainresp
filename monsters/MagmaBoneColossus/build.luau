--!nocheck
-- Magma Bone Colossus (Magma crop #5, Apex): the showpiece of the Magma pack.
-- A giant skeletal crop made of ancient bones with magma FLOWING through it.
-- * a cracked black-obsidian / basalt mound (bone "Soil", parts "Soil") with
--   glowing lava cracks, ember rocks, bone fragments and a LAVA POOL on top;
--   the pool spills over the front in a glowing cascade (Spill_K chase)
-- * six giant bone ROOT-FINGERS grip the mound (knuckles + claw tips) with
--   glowing marrow channels that suck lava up out of the pool (RootGlow)
-- * a twisted SPINE-TRUNK of eleven hollow vertebrae (Spine1..4) rises out of
--   the pool; a LAVA COLUMN runs up through the hollow spine and is visible in
--   every gap and front window. Its hot bands sit on sliding bones (Flow1..4)
--   that climb exactly whole band spacings per loop = lava visibly flows up
-- * a RIBCAGE (Rib1..3 R/L) with glowing marrow channels around a beating
--   MOLTEN HEART (Heart + lobes HeartL/HeartR/HeartB)
-- * two FLOATING RIBS (Rib0R/L) reach out and pour LAVAFALLS (FallR/FallL:
--   sliding bands) down into the pool
-- * two great ARM-BRANCHES (ArmR/L, ForeR/L) with marrow channels end in bone
--   claws holding swinging MAGMA SKULL-FRUITS (SkullR/L, chattering JawR/L)
-- * a five-claw BONE CROWN (Finger1..5) on top cradles the KING SKULL-FRUIT
--   (King, KingJaw) with lava eyes
-- * four obsidian EMBER SHARDS orbit the ribcage on trails
-- Blocks only. Palette: obsidian/basalt, bone cream, lava orange-gold.
return {
	DisplayName = "Magma Bone Colossus",
	Rarity = "Apex",
	Element = "Fire",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ------------------------------------------------------------
		local OBS_BK, BAS1, BAS2, BAS3, BAS_LT = "#1e1719", "#2b2326", "#3a2f31", "#4a3c3c", "#5e4c4a"
		local CRUST, CRUST_DK, CRUST_LT = "#5a2a1f", "#3a1f1a", "#7a3a24"
		local LAVA_DP, LAVA, LAVA_LT, LAVA_YL = "#d9441a", "#ff7a1a", "#ffa62a", "#ffd34a"
		local N_OR, N_YL, N_HOT = "#ff7d1f", "#ffb12a", "#ffd34a"
		local BONE_LT, BONE, BONE_DK, BONE_XD = "#f3ead2", "#e2d6b5", "#c9b98f", "#a8946a"
		local NEON = { mat = "Neon" }

		local seed = 5005005
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
		local function nm(n)
			return { mat = "Neon", name = n }
		end

		------------------------------------------------------------------
		-- MOUND (bone "Soil", parts "Soil")
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
		local function edgeR(w, d)
			local a = rad(d)
			local dx, dz = math.abs(math.sin(a)), math.abs(math.cos(a))
			local function box(hx, hz)
				local tx = dx > 1e-6 and hx / dx or math.huge
				local tz = dz > 1e-6 and hz / dz or math.huge
				return math.min(tx, tz)
			end
			return math.max(box(w / 2, 0.31 * w), box(0.31 * w, w / 2), box(0.425 * w, 0.425 * w))
		end
		local TIERS = {
			{ 0.0, 1.2, 27.0, OBS_BK },
			{ 1.2, 2.6, 23.0, BAS1 },
			{ 2.6, 3.9, 19.0, BAS2 },
			{ 3.9, 5.1, 15.4, BAS3 },
		}
		for _, t in TIERS do
			oct(t[1], t[2], t[3], t[4])
		end
		local function nearFront(d, tol)
			local e = math.abs(((d - 0) + 540) % 360 - 180)
			return e < tol or e > 180 - tol
		end
		-- chunky basalt blocks around the tier edges (front kept clear for the spill)
		for ti, n in { 12 } do
			local t = TIERS[ti]
			for i = 0, n - 1 do
				local a = i * 360 / n + 14 + jit(5)
				if not nearFront(a, 14) then
					local r = edgeR(t[3], a) - 0.7 + jit(0.2)
					local x, z = polar(r, a)
					local h = (t[2] - t[1]) + 0.15 + rnd() * 0.35
					local col = ({ BAS3, BAS2, BAS_LT, BAS1 })[1 + (i + ti) % 4]
					B:block(soil, v(2.7 + rnd() * 0.8, h, 1.8 + rnd() * 0.4), cf(x, t[1] + h / 2, z, 0, -a + jit(8), 0), col, S)
				end
			end
		end
		-- glowing lava cracks on the tier tops
		local function crack(r0, r1, d, y, zig)
			local pts = {}
			for k = 0, 3 do
				local r = r0 + (r1 - r0) * k / 3
				table.insert(pts, at(r, d + ((k % 2 == 0) and -zig or zig), y))
			end
			for k = 1, 3 do
				B:bar(soil, pts[k], pts[k + 1], 0.6, 0.14, CRUST_DK, S)
				B:bar(soil, pts[k] + v(0, 0.05, 0), pts[k + 1] + v(0, 0.05, 0), 0.24, 0.14, (k == 2) and N_YL or N_OR, SN)
			end
		end
		crack(9.8, 12.6, 62, 1.22, 5)
		crack(9.8, 12.6, 232, 1.22, 5)
		crack(8.6, 10.6, 140, 2.62, 6)
		crack(8.6, 10.6, 310, 2.62, 6)
		crack(7.0, 8.6, 250, 3.92, 7)
		crack(7.0, 8.6, 45, 3.92, 7)
		-- glowing magma seams down the tier risers
		for _, sm in { { 2, 50 }, { 2, 230 }, { 3, 125 }, { 3, 295 }, { 4, 70 }, { 4, 250 }, { 1, 150 }, { 1, 330 } } do
			local t = TIERS[sm[1]]
			local e = edgeR(t[3], sm[2]) + 0.04
			local h = t[2] - t[1]
			B:block(soil, v(0.6, h - 0.15, 0.2), facing(at(e, sm[2], t[1] + h / 2), sm[2]) * ang(0, 0, 8), CRUST_DK, S)
			B:block(soil, v(0.24, h - 0.3, 0.24), facing(at(e + 0.04, sm[2], t[1] + h / 2), sm[2]) * ang(0, 0, 8), N_OR, SN)
		end
		-- ember rocks (dark rock with a glowing hot top)
		for _, e in { { 11.6, 95, 1.2, 1.0 }, { 11.2, 205, 1.2, 0.9 }, { 12.2, 330, 1.2, 0.8 }, { 9.8, 165, 2.6, 0.8 }, { 8.4, 260, 3.9, 0.7 } } do
			local p = at(e[1], e[2], e[3])
			local s = e[4]
			B:block(soil, v(1.3 * s, 0.9 * s, 1.3 * s), CFrame.new(p + v(0, 0.4 * s, 0)) * ang(0, rnd() * 90, 8), BAS3, S)
			B:block(soil, v(0.8 * s, 0.25, 0.8 * s), CFrame.new(p + v(0, 0.9 * s, 0)) * ang(0, rnd() * 90, 8), N_OR, SN)
		end
		-- old bone fragments + a little skull on the base tier
		for _, b in { { at(11.8, 120, 1.35), at(12.0, 135, 1.35) }, { at(11.4, 250, 1.35), at(12.4, 262, 1.35) } } do
			B:bar(soil, b[1], b[2], 0.45, 0.45, BONE, S)
			B:block(soil, v(0.75, 0.6, 0.75), CFrame.new(b[1]) * ang(0, 30, 0), BONE_LT, S)
			B:block(soil, v(0.75, 0.6, 0.75), CFrame.new(b[2]) * ang(0, 10, 0), BONE_LT, S)
		end
		do
			local p = at(11.9, 300, 1.2)
			local F = facing(p, 300) * ang(0, 160, 0)
			B:block(soil, v(1.4, 1.0, 1.3), F * CFrame.new(0, 0.6, 0), BONE, S)
			B:block(soil, v(1.0, 0.4, 0.9), F * CFrame.new(0, 0.2, -0.3), BONE_DK, S)
			for _, sx in { -1, 1 } do
				B:block(soil, v(0.36, 0.3, 0.1), F * CFrame.new(sx * 0.32, 0.65, -0.66), CRUST_DK, S)
			end
		end

		-- POOL basin on the top tier ----------------------------------
		local PY = 5.25 -- lava pool surface
		B:block(soil, v(11.8, 0.5, 7.3), cf(0, PY - 0.2, 0), LAVA_DP, S)
		B:block(soil, v(7.3, 0.52, 11.8), cf(0, PY - 0.2, 0), LAVA_DP, S)
		B:block(soil, v(10.0, 0.54, 10.0), cf(0, PY - 0.19, 0), LAVA, S)
		B:block(soil, v(7.6, 0.56, 7.6), cf(0, PY - 0.18, 0, 0, 45, 0), LAVA, S)
		-- floating crust plates
		for i, c in { { 4.0, 15, 1.6, 1.1 }, { 4.6, 120, 1.4, 1.0 }, { 4.2, 200, 1.7, 1.0 }, { 4.5, 255, 1.3, 0.9 }, { 3.3, 320, 1.1, 0.9 } } do
			local p = at(c[1], c[2], PY + 0.06)
			B:block(soil, v(c[3], 0.24, c[4]), CFrame.new(p) * ang(0, rnd() * 90, 0), (i % 2 == 0) and CRUST or CRUST_DK, S)
		end
		-- hot spots (pulse)
		for i = 1, 6 do
			local a = i * 60 - 10
			local p = at(2.9 + (i % 2) * 1.3, a, PY + 0.02)
			B:block(soil, v(1.1, 0.14, 0.8), CFrame.new(p) * ang(0, a, 0), N_YL, nm("PoolGlow" .. i))
		end
		-- obsidian rim rocks
		for i = 0, 10 do
			local a = i * (360 / 11) + 16
			if not nearFront(a, 12) then
				local r = 6.5 + jit(0.2)
				local h = 0.6 + rnd() * 0.5
				B:block(soil, v(2.2 + rnd() * 0.4, h, 1.4), facing(at(r, a, 5.1 + h / 2), a) * ang(jit(6), jit(8), jit(6)),
					({ BAS3, OBS_BK, BAS2, BAS_LT })[1 + i % 4], S)
			end
		end

		-- SPILL: the pool overflows down the front of the mound (Spill_K) --
		for _, SP in { { 0, "Spill_" }, { 180, "SpillB_" } } do
			local d, pre = SP[1], SP[2]
			local k = 0
			local function seg(c, size, coreSize)
				k += 1
				B:block(soil, size, c, CRUST_DK, S)
				B:block(soil, size + v(-0.5, 0.06, -0.06), c, LAVA, S)
				B:block(soil, coreSize, c * CFrame.new(0, 0.04, 0), N_YL, nm(pre .. k))
			end
			-- across each tier top, then down each riser
			local r0 = 5.6
			for ti = 4, 2, -1 do
				local t = TIERS[ti]
				local e = edgeR(t[3], d)
				local wd = 2.3 + (4 - ti) * 0.3
				seg(facing(at((r0 + e) / 2, d, t[2] + 0.06), d), v(wd, 0.3, e - r0), v(0.85, 0.34, e - r0 - 0.3))
				local yb = TIERS[ti - 1][2]
				seg(facing(at(e + 0.2, d, (t[2] + yb) / 2 + 0.05), d), v(wd, t[2] - yb + 0.25, 0.4), v(0.85, t[2] - yb + 0.05, 0.46))
				r0 = e + 0.05
			end
			local e2 = edgeR(23.0, d)
			-- little pool on the base tier
			local pc = facing(at(e2 + 1.4, d, 1.24), d)
			B:block(soil, v(4.0, 0.3, 2.4), pc, CRUST_DK, S)
			B:block(soil, v(3.4, 0.34, 1.9), pc, LAVA, S)
			B:block(soil, v(1.6, 0.38, 1.0), pc, N_YL, nm(pre .. (k + 1)))
			for _, o in { -2.2, 2.2 } do
				B:block(soil, v(1.0, 0.8, 1.0), pc * CFrame.new(o, 0.3, 0.4) * ang(0, 30, 10), BAS3, S)
			end
		end

		------------------------------------------------------------------
		-- CROP base (static) + BONE ROOT-FINGERS gripping the mound
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, PY, 0))
		for i, a in { 30, 90, 150, 210, 270, 330 } do
			local p0 = at(1.4, a, PY + 0.5)
			local p1 = at(3.9, a + 3, PY + 2.1)
			local p2 = at(6.4, a + 6, PY + 0.9)
			local p3 = at(8.7, a + 9, 3.8)
			B:bar(crop, p0, p1, 1.4, 1.3, BONE)
			B:bar(crop, p1, p2, 1.2, 1.1, BONE_DK)
			B:bar(crop, p2, p3, 0.95, 0.85, BONE)
			B:block(crop, v(1.8, 1.7, 1.8), CFrame.new(p1) * ang(0, -a, 0), BONE_LT)
			B:block(crop, v(1.5, 1.4, 1.5), CFrame.new(p2) * ang(0, -a - 6, 0), BONE_LT)
			B:block(crop, v(0.8, 0.8, 0.8), CFrame.new(p3 + v(0, -0.2, 0)) * ang(0, -a, 0), BONE_XD)
			-- marrow channels on top of the root bones
			B:bar(crop, p0 + v(0, 0.66, 0), p1 + v(0, 0.86, 0), 0.34, 0.2, N_YL, nm(("RootGlow%d_1"):format(i)))
			B:bar(crop, p1 + v(0, 0.56, 0), p2 + v(0, 0.56, 0), 0.32, 0.2, N_YL, nm(("RootGlow%d_2"):format(i)))
		end

		------------------------------------------------------------------
		-- SPINE: eleven hollow vertebrae + the flowing lava column
		------------------------------------------------------------------
		local NV = 9
		local VY0, VP, VH = PY + 1.5, 3.0, 1.5
		local function vy(k)
			return VY0 + (k - 1) * VP
		end
		local function vw(k)
			return 4.8 - 0.15 * (k - 1)
		end
		local SPB = { -- section pivots (mid-gap between vertebrae)
			PY + 0.2,
			vy(2) + VP / 2,
			vy(5) + VP / 2,
			vy(7) + VP / 2,
		}
		local spine = {}
		for s = 1, 4 do
			spine[s] = B:bone("Spine" .. s, s == 1 and "Crop" or ("Spine" .. (s - 1)), v(0, SPB[s], 0))
		end
		local function secOf(k)
			if k <= 2 then
				return 1
			elseif k <= 5 then
				return 2
			elseif k <= 7 then
				return 3
			end
			return 4
		end
		local HOLE = 1.0
		local VERT = {}
		for k = 1, NV do
			local bone = spine[secOf(k)]
			local w = vw(k)
			local y = vy(k)
			local tw = w / 2 - HOLE
			local yaw = 12 * math.sin(k * 0.62)
			local F = CFrame.new(0, y, 0) * ang(0, yaw, 0)
			VERT[k] = { F = F, w = w, y = y, yaw = yaw }
			-- hollow ring: back, two sides, two front lips (1.3 wide window)
			B:block(bone, v(w, VH, tw), F * CFrame.new(0, 0, HOLE + tw / 2), BONE_DK)
			B:block(bone, v(tw, VH - 0.04, 2 * HOLE + 0.02), F * CFrame.new(HOLE + tw / 2, 0, 0), BONE)
			B:block(bone, v(tw, VH - 0.04, 2 * HOLE + 0.02), F * CFrame.new(-(HOLE + tw / 2), 0, 0), BONE)
			local lw = (w - 1.6) / 2
			for _, sx in { -1, 1 } do
				B:block(bone, v(lw, VH + 0.06, tw), F * CFrame.new(sx * (w / 2 - lw / 2), 0, -(HOLE + tw / 2)), BONE_LT)
				-- glowing marrow edge of the window
				B:block(bone, v(0.2, VH - 0.3, 0.2), F * CFrame.new(sx * 0.87, 0, -(HOLE + tw) - 0.02), N_YL, nm(("VGlow%d%s"):format(k, sx > 0 and "R" or "L")))
			end
			if k % 2 == 1 then
				-- side processes (angled up) on every other vertebra
				for _, sx in { -1, 1 } do
					local a0 = F * v(sx * (w / 2 - 0.2), 0.1, 0.3)
					local a1 = F * v(sx * (w / 2 + 1.2 - 0.05 * k), 0.8, 0.6)
					B:bar(bone, a0, a1, 0.75, 0.8, BONE)
					B:block(bone, v(0.9, 0.9, 0.9), CFrame.new(a1) * ang(0, yaw + 45, 0), BONE_LT)
				end
			else
				-- spinous process (back, angled down) on the others
				local b0 = F * v(0, 0.2, w / 2 - 0.3)
				local b1 = F * v(0, -0.8, w / 2 + 1.7 - 0.06 * k)
				B:bar(bone, b0, b1, 0.85, 1.0, BONE_DK)
				B:block(bone, v(0.75, 0.75, 0.75), CFrame.new(b1) * ang(45, yaw, 0), BONE_XD)
			end
		end
		-- lava column: a static molten body + sliding hot bands (Flow1..4)
		local BS = 2.0 -- band spacing (the flow bones climb whole spacings)
		local TOPCOL = vy(NV) + 0.4
		local secLo = { 1.0, SPB[2], SPB[3], SPB[4] }
		local secHi = { SPB[2], SPB[3], SPB[4], TOPCOL }
		for s = 1, 4 do
			local lo, hi = secLo[s], secHi[s]
			local cw = (s % 2 == 0) and 1.74 or 1.7
			local y0 = (s == 1) and PY - 1.5 or lo - 0.2
			local y1 = (s == 4) and hi or hi + 0.2
			B:block(spine[s], v(cw, y1 - y0, cw), cf(0, (y0 + y1) / 2, 0), LAVA)
			local flow = B:bone("Flow" .. s, "Spine" .. s, v(0, SPB[s], 0))
			local j = 0
			local y = 3.0
			while y < hi and y < TOPCOL - 0.9 do
				if y >= lo then
					j = math.floor((y - 3.0) / BS + 0.5) + 1
					B:block(flow, v(1.82, 0.9, 1.82), cf(0, y, 0), "#b8321a")
					B:block(flow, v(1.88, 0.94, 1.88), cf(0, y, 0), N_HOT, nm("ColBand" .. j))
				end
				y += BS
			end
		end

		------------------------------------------------------------------
		-- MOLTEN HEART inside the ribcage
		------------------------------------------------------------------
		local HS = 2.9
		local HC = v(0, vy(6) - 0.2, -3.3)
		local heart = B:bone("Heart", "Spine3", HC)
		local HF = CFrame.new(HC)
		local hd = 1.0 * HS
		B:block(heart, v(0.95 * HS, 0.95 * HS, hd * 0.8), HF * CFrame.new(0, -0.05 * HS, 0) * ang(0, 0, 45), N_HOT, nm("HeartInner"))
		local hL = B:bone("HeartL", "Heart", HC + v(-0.4 * HS, 0.22 * HS, 0))
		local hR = B:bone("HeartR", "Heart", HC + v(0.4 * HS, 0.22 * HS, 0))
		local hB = B:bone("HeartB", "Heart", HC + v(0, -0.35 * HS, 0))
		for _, Lb in { { hL, -1 }, { hR, 1 } } do
			local bone, sx = Lb[1], Lb[2]
			local LC = HF * CFrame.new(sx * 0.4 * HS, 0.22 * HS, 0) * ang(0, 0, 45)
			B:block(bone, v(0.8 * HS, 0.8 * HS, hd * 0.94), LC, LAVA)
			B:block(bone, v(0.42 * HS, 0.42 * HS, hd * 0.94 + 0.2), LC * CFrame.new(-0.12 * HS * sx, 0.12 * HS, 0), LAVA_LT)
			B:block(bone, v(0.36 * HS, 0.3 * HS, hd * 0.94 + 0.14), LC * CFrame.new(0.18 * HS * sx, -0.18 * HS, 0), CRUST)
		end
		do
			local BC = HF * CFrame.new(0, -0.35 * HS, 0) * ang(0, 0, 45)
			B:block(hB, v(1.1 * HS, 1.1 * HS, hd), BC, LAVA_DP)
			B:block(hB, v(0.3 * HS, 0.3 * HS, hd + 0.14), BC * CFrame.new(-0.36 * HS, -0.36 * HS, 0), CRUST)
			B:block(hB, v(0.5 * HS, 0.5 * HS, 0.16), BC * CFrame.new(0.08 * HS, 0.08 * HS, -(hd * 0.5 + 0.08)), N_HOT, nm("HeartCore"))
			-- crust cap + vessel joining the spine lava
			B:block(heart, v(0.65 * HS, 0.32 * HS, 0.6 * HS), HF * CFrame.new(0, 0.5 * HS, 0) * ang(0, 45, 0), CRUST_DK)
			B:bar(heart, HC + v(0, 0.55 * HS, 0.2), v(0, HC.Y + 0.9 * HS, -0.6), 0.8, 0.8, CRUST)
			B:bar(heart, HC + v(0, 0.58 * HS, 0.2), v(0, HC.Y + 0.92 * HS, -0.6), 0.3, 0.9, N_YL, nm("Vessel"))
		end

		------------------------------------------------------------------
		-- RIBCAGE (Rib1..3 R/L on Spine3) with marrow channels
		------------------------------------------------------------------
		local function ribPts(sx, y, f)
			return {
				v(sx * 1.3, y, 0.9),
				v(sx * 3.9 * f, y + 0.5, 0.5),
				v(sx * 5.0 * f, y - 0.2, -1.9 * f),
				v(sx * 4.1 * f, y - 1.0, -4.3 * f),
				v(sx * 2.0 * f, y - 1.5, -5.3 * f),
			}
		end
		for lv, R in { { 5, 1.0 }, { 6, 1.05 }, { 7, 0.88 } } do
			local y = vy(R[1]) + 0.2
			for _, sx in { 1, -1 } do
				local sd = sx > 0 and "R" or "L"
				local pts = ribPts(sx, y, R[2])
				local rib = B:bone(("Rib%d%s"):format(lv, sd), lv == 1 and "Spine2" or "Spine3", pts[1])
				for k = 1, 4 do
					local a, b = pts[k], pts[k + 1]
					local ext = (b - a).Unit * 0.25
					B:bar(rib, a - ext, b + ext, 0.95 - 0.08 * k, 0.85 - 0.06 * k, (k % 2 == 1) and BONE or BONE_LT)
					B:bar(rib, a, b, 0.3, 0.92 - 0.06 * k, N_YL, nm(("RibGlow%d%s_%d"):format(lv, sd, k)))
				end
				B:block(rib, v(0.8, 0.8, 0.8), CFrame.new(pts[5]) * ang(0, 45, 0), BONE_DK)
			end
		end
		-- floating ribs reach out and pour the lavafalls (Rib0 R/L on Spine2)
		local FALL_TOP, FALL_BOT = 0, PY - 0.6
		local FS = 1.5 -- lavafall band spacing
		for _, sx in { 1, -1 } do
			local sd = sx > 0 and "R" or "L"
			local y = vy(4) + 0.2
			local pts = {
				v(sx * 1.3, y, 0.7),
				v(sx * 3.8, y + 0.6, 0.3),
				v(sx * 4.8, y - 0.3, -0.5),
				v(sx * 5.0, y - 1.7, -0.9),
			}
			local rib = B:bone("Rib0" .. sd, "Spine2", pts[1])
			for k = 1, 3 do
				local a, b = pts[k], pts[k + 1]
				local ext = (b - a).Unit * 0.25
				B:bar(rib, a - ext, b + ext, 1.0 - 0.06 * k, 0.9 - 0.05 * k, (k % 2 == 1) and BONE or BONE_LT)
				B:bar(rib, a, b, 0.32, 0.96 - 0.05 * k, N_YL, nm(("RibGlow0%s_%d"):format(sd, k)))
			end
			-- broken rib end = the spout
			local sp = pts[4]
			B:block(rib, v(1.7, 2.0, 1.7), CFrame.new(sp + v(0, -0.6, 0)) * ang(0, 20 * sx, 0), BONE_LT)
			B:block(rib, v(1.9, 0.4, 1.9), CFrame.new(sp + v(0, -1.6, 0)) * ang(0, 20 * sx, 0), BONE_DK)
			B:block(rib, v(1.3, 0.3, 1.3), CFrame.new(sp + v(0, 0.48, 0)) * ang(0, 20 * sx, 0), N_HOT, nm("Spout" .. sd))
			FALL_TOP = sp.Y - 1.2
			-- the lavafall: molten body + sliding hot bands
			local fx, fz = sp.X, sp.Z
			local len = FALL_TOP - FALL_BOT
			B:block(rib, v(0.95, len, 0.75), cf(fx, (FALL_TOP + FALL_BOT) / 2, fz), LAVA_DP)
			local fall = B:bone("Fall" .. sd, "Rib0" .. sd, v(fx, FALL_TOP, fz))
			local yy = FALL_TOP + 0.4
			local fj = 0
			while yy > FALL_BOT + 0.3 do
				fj += 1
				B:block(fall, v(1.08, 0.75, 0.88), cf(fx, yy, fz), LAVA)
				B:block(fall, v(1.12, 0.79, 0.92), cf(fx, yy, fz), N_HOT, nm(("FallBand%s%d"):format(sd, fj)))
				yy -= FS
			end
			-- splash where it lands
			B:block(soil, v(2.2, 0.2, 2.2), cf(fx, PY + 0.05, fz, 0, 45, 0), LAVA_LT, S)
			B:block(soil, v(1.4, 0.24, 1.4), cf(fx, PY + 0.08, fz), N_HOT, nm("Splash" .. sd))
		end

		------------------------------------------------------------------
		-- MAGMA SKULL-FRUIT helper (faces local -Z)
		------------------------------------------------------------------
		local function skull(bone, jawName, jawParent, F, s, tag)
			-- cranium dome (wide) + stepped crown + cooled crust plates
			B:block(bone, v(1.0 * s, 0.6 * s, 0.96 * s), F * CFrame.new(0, 0.22 * s, 0.02 * s), LAVA)
			B:block(bone, v(0.8 * s, 0.18 * s, 0.8 * s), F * CFrame.new(0, 0.58 * s, 0.05 * s), LAVA_LT)
			B:block(bone, v(0.46 * s, 0.12 * s, 0.44 * s), F * CFrame.new(-0.16 * s, 0.7 * s, 0.14 * s), CRUST)
			B:block(bone, v(0.26 * s, 0.1 * s, 0.26 * s), F * CFrame.new(0.2 * s, 0.68 * s, -0.12 * s), CRUST_DK)
			B:block(bone, v(0.12 * s, 0.34 * s, 0.46 * s), F * CFrame.new(0.52 * s, 0.24 * s, 0.12 * s), CRUST)
			-- narrower face / cheekbones
			B:block(bone, v(0.82 * s, 0.34 * s, 0.86 * s), F * CFrame.new(0, -0.24 * s, -0.04 * s), LAVA_DP)
			for _, sx in { -1, 1 } do
				B:block(bone, v(0.2 * s, 0.14 * s, 0.16 * s), F * CFrame.new(sx * 0.37 * s, -0.17 * s, -0.43 * s), LAVA_LT)
			end
			-- heavy brow, deep black sockets, lava eyes
			B:block(bone, v(0.98 * s, 0.13 * s, 0.14 * s), F * CFrame.new(0, 0.27 * s, -0.48 * s), CRUST_DK)
			for _, sx in { -1, 1 } do
				B:block(bone, v(0.36 * s, 0.34 * s, 0.1 * s), F * CFrame.new(sx * 0.22 * s, 0.04 * s, -0.47 * s), OBS_BK)
				B:block(bone, v(0.17 * s, 0.17 * s, 0.1 * s), F * CFrame.new(sx * 0.21 * s, 0.02 * s, -0.5 * s), N_HOT, nm(("Eye%s%s"):format(tag, sx > 0 and "R" or "L")))
			end
			-- nose hole
			B:block(bone, v(0.15 * s, 0.17 * s, 0.08 * s), F * CFrame.new(0, -0.2 * s, -0.48 * s), OBS_BK)
			-- upper teeth (bone)
			for i, tx in { -0.24, -0.08, 0.08, 0.24 } do
				B:block(bone, v(0.13 * s, 0.17 * s, 0.12 * s), F * CFrame.new(tx * s, -0.44 * s, -0.42 * s), (i % 2 == 0) and BONE or BONE_LT)
			end
			-- dark mouth + throat glow (seen when the jaw opens)
			B:block(bone, v(0.62 * s, 0.1 * s, 0.6 * s), F * CFrame.new(0, -0.47 * s, -0.08 * s), OBS_BK)
			B:block(bone, v(0.38 * s, 0.08 * s, 0.36 * s), F * CFrame.new(0, -0.51 * s, -0.1 * s), N_YL, nm("Throat" .. tag))
			-- jaw (hinge at the back of the mouth)
			local hinge = F * v(0, -0.45 * s, 0.25 * s)
			local jaw = B:bone(jawName, jawParent, hinge)
			B:block(jaw, v(0.74 * s, 0.2 * s, 0.72 * s), F * CFrame.new(0, -0.62 * s, -0.1 * s), LAVA_DP)
			B:block(jaw, v(0.48 * s, 0.13 * s, 0.3 * s), F * CFrame.new(0, -0.74 * s, -0.34 * s), LAVA)
			B:block(jaw, v(0.16 * s, 0.1 * s, 0.4 * s), F * CFrame.new(-0.2 * s, -0.55 * s, 0.08 * s), CRUST)
			for i, tx in { -0.18, 0, 0.18 } do
				B:block(jaw, v(0.13 * s, 0.15 * s, 0.12 * s), F * CFrame.new(tx * s, -0.5 * s, -0.4 * s), (i % 2 == 0) and BONE_LT or BONE)
			end
			return jaw
		end

		------------------------------------------------------------------
		-- ARM-BRANCHES with claws holding magma skull-fruits
		------------------------------------------------------------------
		local SK = {}
		for _, sx in { 1, -1 } do
			local sd = sx > 0 and "R" or "L"
			local yb = vy(8)
			local sh = v(sx * 1.6, yb + 0.2, 0.2)
			local el = v(sx * 5.0, yb + 3.8, 0.7)
			local wr = v(sx * 8.6, yb + 2.2, -0.5)
			-- shoulder blade plate on the spine
			B:block(spine[4], v(1.0, 2.6, 2.2), CFrame.new(sx * 2.0, yb + 0.2, 0.5) * ang(0, 0, -12 * sx), BONE_DK)
			local arm = B:bone("Arm" .. sd, "Spine4", sh)
			B:bar(arm, sh, el + (el - sh).Unit * 0.3, 1.25, 1.15, BONE)
			B:bar(arm, sh + v(0, 0.02, 0), sh:Lerp(el, 0.5), 0.32, 1.22, N_YL, nm("ArmGlow" .. sd .. "1"))
			B:bar(arm, sh:Lerp(el, 0.5), el, 0.32, 1.22, N_YL, nm("ArmGlow" .. sd .. "2"))
			B:block(arm, v(1.7, 1.7, 1.7), CFrame.new(el) * ang(0, 30, 0), BONE_LT)
			local fore = B:bone("Fore" .. sd, "Arm" .. sd, el)
			B:bar(fore, el, wr + (wr - el).Unit * 0.2, 1.05, 0.95, BONE_DK)
			B:bar(fore, el, el:Lerp(wr, 0.5), 0.3, 1.02, N_YL, nm("ArmGlow" .. sd .. "3"))
			B:bar(fore, el:Lerp(wr, 0.5), wr, 0.3, 1.02, N_YL, nm("ArmGlow" .. sd .. "4"))
			B:block(fore, v(1.35, 1.35, 1.35), CFrame.new(wr) * ang(0, 45, 0), BONE_LT)
			-- the skull hangs from the wrist; claws grip its crown
			local s = 3.0
			local skb = B:bone("Skull" .. sd, "Fore" .. sd, wr)
			local C = wr + v(0.1 * sx, -2.75, -0.1)
			local F = CFrame.new(C) * ang(0, -24 * sx, 0)
			for i, ca in { -55, 55, 180 } do
				local d = CFrame.new(wr) * ang(0, -24 * sx + ca, 0)
				local q1 = d * v(0, -0.15, -1.05)
				local q2 = d * v(0, -0.85, -1.7)
				local q3 = d * v(0, -1.65, -1.62)
				B:bar(skb, wr, q1, 0.6, 0.55, BONE)
				B:bar(skb, q1, q2, 0.5, 0.5, BONE_LT)
				B:bar(skb, q2, q3, 0.38, 0.38, BONE_XD)
			end
			skull(skb, "Jaw" .. sd, "Skull" .. sd, F, s, sd)
			SK[sd] = { F = F, s = s, bone = skb }
		end

		------------------------------------------------------------------
		-- THE CROWN: five bone claws cradling the KING SKULL-FRUIT
		------------------------------------------------------------------
		local PAL = vy(NV) + 1.3
		B:block(spine[4], v(3.4, 1.3, 3.4), cf(0, PAL, 0, 0, 45, 0), BONE_DK)
		B:block(spine[4], v(3.9, 0.6, 3.9), cf(0, PAL + 0.25, 0), BONE)
		for i = 1, 5 do
			local a = i * 60
			local q0 = at(1.4, a, PAL + 0.2)
			local fb = B:bone("Finger" .. i, "Spine4", q0)
			local q1 = at(2.9, a, PAL + 1.0)
			local q2 = at(3.2, a + 5, PAL + 3.0)
			local q3 = at(2.75, a + 10, PAL + 4.6)
			local q4 = at(2.0, a + 13, PAL + 5.2)
			B:bar(fb, q0, q1 + (q1 - q0).Unit * 0.2, 1.0, 0.95, BONE)
			B:block(fb, v(1.15, 1.15, 1.15), CFrame.new(q1) * ang(0, -a, 0), BONE_LT)
			B:bar(fb, q1, q2 + (q2 - q1).Unit * 0.2, 0.85, 0.8, BONE_DK)
			B:block(fb, v(0.95, 0.95, 0.95), CFrame.new(q2) * ang(0, -a, 0), BONE_LT)
			B:bar(fb, q2, q3 + (q3 - q2).Unit * 0.15, 0.7, 0.65, BONE)
			B:bar(fb, q3, q4, 0.5, 0.45, BONE_XD)
			B:bar(fb, q0 + v(0, 0.5, 0), q1 + v(0, 0.5, 0), 0.28, 0.2, N_YL, nm("FingerGlow" .. i))
		end
		local KS = 4.2
		local KC = v(0, PAL + 3.25, -0.1)
		local king = B:bone("King", "Spine4", v(0, PAL + 0.8, 0))
		local KF = CFrame.new(KC)
		skull(king, "KingJaw", "King", KF, KS, "K")
		-- great curved bone horns on the King skull
		for _, sx in { 1, -1 } do
			local h0 = KF * v(sx * 0.46 * KS, 0.36 * KS, 0.05 * KS)
			local h1 = KF * v(sx * 0.8 * KS, 0.55 * KS, 0.15 * KS)
			local h2 = KF * v(sx * 0.98 * KS, 0.86 * KS, 0.1 * KS)
			local h3 = KF * v(sx * 0.86 * KS, 1.0 * KS, -0.05 * KS)
			B:bar(king, h0, h1 + (h1 - h0).Unit * 0.2, 1.25, 1.15, BONE)
			B:bar(king, h1, h2 + (h2 - h1).Unit * 0.2, 0.95, 0.9, BONE_LT)
			B:bar(king, h2, h3, 0.6, 0.55, BONE_DK)
			B:block(king, v(0.5, 0.5, 0.5), CFrame.new(h3) * ang(45, 0, 45), N_HOT, nm("Horn" .. (sx > 0 and "R" or "L")))
			B:bar(king, h0 + v(0, 0.5, 0), h1 + v(0, 0.45, 0), 0.26, 0.2, N_YL, nm("HornGlow" .. (sx > 0 and "R" or "L")))
		end

		------------------------------------------------------------------
		-- EMBER SHARDS orbiting the ribcage (trails)
		------------------------------------------------------------------
		local SHARDS = { { 20, 9.2, 0 }, { 110, 9.6, 2.2 }, { 200, 9.0, -0.8 }, { 290, 9.4, 1.4 } }
		local SY = vy(6) + 1.0
		for i, sh in SHARDS do
			local bone = B:bone("Shard" .. i, "Crop", v(0, SY, 0))
			local p = at(sh[2], sh[1], SY + sh[3])
			local Fp = CFrame.new(p) * ang(30, sh[1], 20)
			B:block(bone, v(1.0, 1.0, 1.0), Fp, N_HOT, nm("ShardGlow" .. i))
			B:block(bone, v(1.5, 1.3, 0.6), Fp * CFrame.new(0, 0.1, -0.5) * ang(0, 0, 12), CRUST_DK)
			B:block(bone, v(0.6, 1.5, 1.4), Fp * CFrame.new(0.5, -0.1, 0.1) * ang(10, 0, 0), OBS_BK)
			B:block(bone, v(1.3, 0.6, 1.2), Fp * CFrame.new(-0.1, -0.55, 0.3) * ang(0, 20, 0), CRUST)
			B:block(bone, v(0.7, 0.9, 0.7), Fp * CFrame.new(-0.3, 0.75, 0.2) * ang(20, 30, 0), LAVA)
			B:trail(bone, p + v(0, 0.55, 0), p - v(0, 0.55, 0), { name = "ShardTrail" .. i, color = { N_HOT, N_OR, "#7a2a1a" }, life = 0.5, width = { 1, 0 }, trans = { 0.15, 1 } })
		end

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local hz = B:block(heart, v(2.4, 2.4, 2.4), HF, N_HOT, { tr = 1, name = "HeartZone" })
		B:emitter(hz, "ember", { name = "MarrowEmbers", color = { N_HOT, N_OR, "#c2331a" }, rate = 7, size = { 0.34, 0.22, 0 }, life = { 1.6, 2.6 }, speed = { 1.2, 2.6 }, spread = 70, accel = { 0, 2.2, 0 } })
		B:emitter(hz, "burst", { name = "HeartBurst", color = { "#fff2b0", N_HOT, N_OR }, size = { 0.9, 0.6, 0 }, speed = { 9, 18 }, life = { 0.6, 1.2 }, accel = { 0, -6, 0 } })
		local kz = B:block("KingJaw", v(1.8, 0.6, 1.4), KF * CFrame.new(0, -0.55 * KS, -0.45 * KS), N_HOT, { tr = 1, name = "KingMouth" })
		B:emitter(kz, "fire", { name = "KingFire", color = { "#fff0a0", N_HOT, N_OR, "#a02a10" }, rate = 45, size = { 1.6, 2.4, 0 }, life = { 0.5, 0.9 }, speed = { 7, 11 }, spread = 18, accel = { 0, 4, 0 }, dir = "Front", enabled = false })
		for _, sd in { "R", "L" } do
			local sk = SK[sd]
			local mz = B:block("Jaw" .. sd, v(1.2, 0.4, 1.0), sk.F * CFrame.new(0, -0.55 * sk.s, -0.45 * sk.s), N_HOT, { tr = 1, name = "Mouth" .. sd })
			B:emitter(mz, "fire", { name = "Fire" .. sd, color = { "#fff0a0", N_HOT, N_OR, "#a02a10" }, rate = 35, size = { 1.1, 1.7, 0 }, life = { 0.45, 0.8 }, speed = { 6, 9 }, spread = 20, accel = { 0, 4, 0 }, dir = "Front", enabled = false })
			B:emitter(mz, "drip", { name = "Drip" .. sd, color = { N_HOT, LAVA, "#c2331a" }, rate = 3, size = { 0.4, 0.34, 0.15 }, life = { 1.2, 1.6 } })
		end
		local pz = B:block(soil, v(10, 0.4, 10), cf(0, PY + 0.2, 0), LAVA, { tr = 1, name = "PoolZone" })
		B:emitter(pz, "smoke", { name = "PoolSmoke", color = { "#4a403d", "#2b2526" }, rate = 1.6, size = { 1.6, 3.2, 4.4 }, life = { 2.2, 3.4 }, speed = { 1.0, 2.0 }, spread = 25, accel = { 0.2, 0.6, 0 } })
		B:light(hz, { name = "HeartLight", color = "#ff6a2a", brightness = 1.4, range = 20 })
		local kl = B:block(king, v(1, 1, 1), KF, N_HOT, { tr = 1, name = "KingZone" })
		B:light(kl, { name = "KingLight", color = "#ff8a2a", brightness = 1.2, range = 18 })
		B:light(pz, { name = "PoolLight", color = "#ff6414", brightness = 1.2, range = 20 })
		local sl = B:block(spine[2], v(1, 1, 1), cf(0, vy(4), 0), N_HOT, { tr = 1, name = "SpineZone" })
		B:light(sl, { name = "SpineLight", color = "#ff7a1a", brightness = 0.9, range = 14 })
	end,
}
