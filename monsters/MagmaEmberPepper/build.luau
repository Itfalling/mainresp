--!nocheck
-- Ember Pepper (Magma crop #1, Epic).
-- A chunky chili-pepper bush on a black basalt mound.
-- * mound (bone "Soil", parts "Soil"): obsidian / charcoal basalt steps with
--   glowing lava cracks, ember rocks and a little lava puddle
-- * a twisted charred trunk with a glowing seam, four branch bones each
--   carrying a cluster of chunky charred-ember leaf cubes (crimson / rust
--   with orange highlights)
-- * five big glowing MAGMA PEPPERS hang on their own stem bones (PepperN):
--   stepped lava-orange bodies that curl at the tip, crust seams and a neon
--   hot stripe + neon dripping tip. Pepper3 (front) is the big "flare" pepper
-- VFX: rising embers, heat sparkles, lava drips from three pepper tips,
-- flare sparks + flare fire bursts, trails on three pepper tips, a soft bush
-- light and the flare light.
return {
	DisplayName = "Ember Pepper",
	Rarity = "Epic",
	Element = "Fire",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ------------------------------------------------------------
		local OBS, BAS, BAS_LT = "#2b2326", "#3a2f31", "#4a3c3c"
		local OBS_XD = "#1f191b"
		local CRUST, CRUST_DK = "#5a2a1f", "#3a1f1a"
		local LAVA, LAVA_LT, LAVA_HOT = "#ff7a1a", "#ffa62a", "#ffd34a"
		local GLOW, GLOW_HOT = "#ff6a1f", "#ffb12a"
		local LEAF_DK, LEAF, LEAF_MID, LEAF_LT = "#5e1a14", "#9c261b", "#c43a22", "#ef6a2c"
		local NEON = { mat = "Neon" }

		local seed = 1001
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
		local function pv(r, deg, y)
			local a = rad(deg)
			return v(math.sin(a) * r, y, -math.cos(a) * r)
		end
		local function facing(p, deg)
			return CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
		end

		------------------------------------------------------------------
		-- BASALT MOUND (bone "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local SN = { name = "Soil", mat = "Neon" }
		local function disc(y0, h, r, col)
			B:block(soil, v(2 * r, h, 1.15 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.15 * r, h - 0.02, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.04, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
		end
		local function edge(y0, h, r, n, cols, eh)
			for i = 0, n - 1 do
				local a = (i + jit(0.2)) / n * 360
				local hh = h + rnd() * eh - 0.05
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + hh / 2, -(r + jit(0.15)))
				B:block(soil, v(1.5 + rnd() * 0.9, hh, 1.2 + rnd() * 0.5), p * ang(jit(4), jit(10), jit(4)), pick(cols), S)
			end
		end
		disc(0, 0.8, 5.4, OBS)
		edge(0, 0.8, 5.45, 15, { OBS, BAS, OBS_XD, OBS }, 0.45)
		disc(0.8, 0.7, 4.2, BAS)
		edge(0.8, 0.7, 4.25, 12, { BAS, BAS_LT, OBS, BAS }, 0.35)
		local GY = 1.5

		-- lava cracks: zig-zag neon seams on the step faces
		local function crack(deg, r0, r1, y, wig)
			local a0 = pv(r0, deg, y)
			local mid = pv((r0 + r1) / 2, deg + wig, y)
			local a1 = pv(r1, deg - wig * 0.4, y)
			B:bar(soil, a0, mid, 0.42, 0.1, CRUST_DK, S)
			B:bar(soil, mid, a1, 0.42, 0.1, CRUST_DK, S)
			B:bar(soil, a0 + v(0, 0.02, 0), mid + v(0, 0.02, 0), 0.2, 0.14, GLOW_HOT, SN)
			B:bar(soil, mid + v(0, 0.02, 0), a1 + v(0, 0.02, 0), 0.2, 0.14, GLOW, SN)
		end
		crack(-25, 4.3, 5.6, 0.81, 8)
		crack(80, 4.3, 5.6, 0.81, -9)
		crack(165, 4.3, 5.5, 0.81, 7)
		crack(250, 4.3, 5.6, 0.81, -7)
		crack(20, 1.9, 3.9, GY + 0.01, 10)
		crack(200, 1.9, 3.8, GY + 0.01, -10)

		-- ember rocks (orange plastic body, neon hot top)
		local function emberRock(p, s, deg)
			local C = CFrame.new(p) * CFrame.Angles(rad(jit(10)), rad(deg), rad(jit(10)))
			B:block(soil, v(1.1 * s, 0.8 * s, 1.0 * s), C, CRUST, S)
			B:block(soil, v(0.8 * s, 0.35 * s, 0.75 * s), C * CFrame.new(0, 0.4 * s, 0), LAVA, S)
			B:block(soil, v(0.4 * s, 0.16, 0.4 * s), C * CFrame.new(0.05, 0.6 * s, 0), GLOW_HOT, SN)
		end
		emberRock(v(-4.6, 1.0, -2.4), 1.0, 20)
		emberRock(v(4.3, 0.95, 2.9), 0.9, -30)
		emberRock(v(2.6, GY + 0.3, -3.0), 0.75, 45)
		-- basalt boulders
		for _, s in { { 4.9, 1.0, -1.4, 1.2, 25, BAS_LT }, { -4.0, 1.0, 3.3, 1.1, -20, BAS }, { -1.5, GY + 0.35, 3.3, 0.8, 10, OBS } } do
			B:block(soil, v(s[4] * 1.3, s[4] * 1.1, s[4]), cf(s[1], s[2], s[3], jit(8), s[5], jit(8)), s[6], S)
		end
		-- little lava puddle (front-left)
		B:block(soil, v(2.2, 0.16, 1.5), cf(-2.2, GY + 0.04, -2.6, 0, 25, 0), CRUST_DK, S)
		B:block(soil, v(1.7, 0.18, 1.1), cf(-2.2, GY + 0.06, -2.6, 0, 25, 0), LAVA, S)
		B:block(soil, v(0.9, 0.2, 0.5), cf(-2.2, GY + 0.08, -2.6, 0, 25, 0), GLOW_HOT, { name = "Puddle", mat = "Neon" })

		------------------------------------------------------------------
		-- TRUNK (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, GY, 0))
		for i = 0, 3 do
			local a = i * 90 + 30
			B:bar(crop, pv(0.6, a, GY + 1.1), pv(1.9, a + 8, GY - 0.05), 0.75, 0.6, (i % 2 == 0) and CRUST_DK or CRUST, { up = v(0, 1, 0) })
		end
		local trunkPts = { v(0, GY - 0.1, 0), v(0.25, GY + 1.6, -0.1), v(-0.15, GY + 3.2, 0.15), v(0.1, GY + 4.6, -0.05) }
		for i = 1, #trunkPts - 1 do
			B:bar(crop, trunkPts[i], trunkPts[i + 1] + v(0, 0.3, 0), 1.25 - i * 0.08, 1.15 - i * 0.08, (i % 2 == 1) and CRUST or CRUST_DK)
		end
		-- glowing seam up the front of the trunk
		B:bar(crop, v(0.2, GY + 0.4, -0.62), v(-0.05, GY + 2.4, -0.58), 0.22, 0.16, GLOW, { mat = "Neon", name = "TrunkGlow" })
		B:bar(crop, v(-0.05, GY + 2.4, -0.55), v(0.1, GY + 3.9, -0.5), 0.2, 0.16, GLOW_HOT, { mat = "Neon", name = "TrunkGlow2" })
		local FORK = v(0.1, GY + 4.6, -0.05)

		------------------------------------------------------------------
		-- LEAF CLUSTERS on branch bones
		------------------------------------------------------------------
		-- leaf cluster: a dark core + two rings of tilted leaf slabs pointing
		-- outward + a little top crown (reads as a leafy clump, not rocks)
		local function cluster(bone, c, rx, ry, rz, n, emberName)
			B:block(bone, v(rx * 1.3, ry * 1.1, rz * 1.3), CFrame.new(c) * ang(0, 20, 0), LEAF_DK)
			local ring = { { -0.35, n, 0.95, -18, { LEAF, LEAF_DK, LEAF } }, { 0.35, n - 2, 0.7, 22, { LEAF_MID, LEAF, LEAF_MID } } }
			for ri, rg in ring do
				for i = 0, rg[2] - 1 do
					local a = (i + (ri - 1) * 0.5 + jit(0.15)) / rg[2] * 360
					local r = rg[3]
					local p = c + v(math.sin(rad(a)) * rx * r, rg[1] * ry + jit(0.2), -math.cos(rad(a)) * rz * r)
					local L = 1.7 + rnd() * 0.5
					local C = facing(p, a) * CFrame.Angles(rad(rg[4] + jit(8)), 0, rad(jit(12)))
					B:block(bone, v(1.25 + rnd() * 0.3, 0.45, L), C * CFrame.new(0, 0, -L * 0.3), pick(rg[5]))
					if i % 2 == 0 then
						-- glowing ember edge on every other leaf tip
						B:block(bone, v(0.55, 0.5, 0.4), C * CFrame.new(0, 0.02, -L * 0.3 - L / 2 + 0.1), LEAF_LT)
					end
				end
			end
			for k = 0, 2 do
				B:block(bone, v(1.2, 0.5, 1.6), CFrame.new(c + v(0, ry * 0.85, 0)) * ang(0, k * 120 + 10, 0) * CFrame.new(0, 0, -0.5) * ang(35, 0, 0), (k == 0) and LEAF_LT or LEAF_MID)
			end
			-- glowing ember speck on top
			B:block(bone, v(0.45, 0.3, 0.45), CFrame.new(c + v(0, ry * 0.85 + 0.45, 0)) * ang(0, 30, 0), GLOW_HOT, { mat = "Neon", name = emberName })
		end

		local BR = {
			-- name, cluster centre, radii, leaf count
			{ "BranchA", v(-3.2, 9.4, -0.2), 2.0, 1.3, 1.9, 8 },
			{ "BranchB", v(3.1, 9.9, 0.7), 2.0, 1.3, 1.9, 8 },
			{ "BranchC", v(0.0, 12.2, 0.4), 1.9, 1.3, 1.8, 8 },
			{ "BranchD", v(0.3, 8.0, -2.6), 1.5, 1.0, 1.3, 6 },
		}
		local bones = {}
		for bi, b in BR do
			local bone = B:bone(b[1], "Crop", FORK)
			bones[b[1]] = bone
			local c = b[2]
			local mid = FORK:Lerp(c, 0.55) + v(0, 0.5, 0)
			B:bar(bone, FORK, mid, 0.8, 0.75, CRUST)
			B:bar(bone, mid, c - v(0, 0.4, 0), 0.65, 0.6, CRUST_DK)
			cluster(bone, c, b[3], b[4], b[5], b[6], "LeafEmber" .. bi)
		end

		------------------------------------------------------------------
		-- MAGMA PEPPERS (own bones, pivot at the stem top)
		------------------------------------------------------------------
		local PEP = {
			-- parent, stem top, yaw, scale
			{ "BranchA", v(-4.6, 8.2, -1.3), 35, 0.8 },
			{ "BranchB", v(4.6, 8.6, -0.6), -40, 0.85 },
			{ "BranchD", v(0.4, 7.0, -3.9), 0, 1.0 },
			{ "BranchA", v(-3.0, 8.1, 1.9), 150, 0.72 },
			{ "BranchB", v(2.9, 8.6, 2.6), 210, 0.75 },
		}
		local tips = {}
		for i, pp in PEP do
			local top, s = pp[2], pp[4]
			local pb = B:bone("Pepper" .. i, pp[1], top)
			-- twig from the leaf cluster down to the stem top
			local parentC = nil
			for _, b in BR do
				if b[1] == pp[1] then
					parentC = b[2]
				end
			end
			B:bar(bones[pp[1]], parentC:Lerp(top, 0.45) + v(0, 0.2, 0), top + v(0, 0.3, 0), 0.4, 0.4, CRUST_DK)
			local F = CFrame.new(top) * CFrame.Angles(0, rad(pp[3]), 0)
			local function at(x, y, z)
				return F * CFrame.new(x * s, y * s, z * s)
			end
			-- stem + calyx
			B:block(pb, v(0.4 * s, 1.0 * s, 0.4 * s), at(0, -0.25, 0) * ang(8, 0, 0), CRUST_DK)
			B:block(pb, v(1.35 * s, 0.45 * s, 1.35 * s), at(0, -0.85, 0), CRUST)
			for k = 0, 3 do
				B:block(pb, v(0.6 * s, 0.25 * s, 1.0 * s), at(0, -1.0, 0) * ang(0, k * 90 + 45, 0) * CFrame.new(0, 0, -0.85 * s) * ang(25, 0, 0), (k % 2 == 0) and CRUST or CRUST_DK)
			end
			-- body: stepped, tapering, curling forward (-Z) at the tip
			local SEG = {
				-- y, width, height, z, tilt, colour
				{ -1.45, 1.75, 1.1, 0.0, 0, LAVA },
				{ -2.4, 1.55, 1.05, -0.12, -8, LAVA },
				{ -3.25, 1.3, 0.95, -0.42, -18, LAVA_LT },
				{ -3.9, 1.05, 0.85, -0.88, -32, LAVA_LT },
				{ -4.3, 0.82, 0.8, -1.42, -50, LAVA_HOT },
			}
			for si, sg in SEG do
				local w, h = sg[2] * s, sg[3] * s
				local C = at(0, sg[1], sg[4]) * ang(sg[5], 0, 0)
				B:block(pb, v(w, h, w), C, sg[6])
				if si <= 3 then
					B:block(pb, v(w + 0.26 * s, h * 0.8, w - 0.4 * s), C, sg[6])
					B:block(pb, v(w - 0.4 * s, h * 0.8, w + 0.26 * s), C, sg[6])
				end
			end
			-- shoulder bulge + cooled crust patches on the back
			B:block(pb, v(2.0 * s, 0.55 * s, 1.5 * s), at(0, -1.2, 0), LAVA)
			B:block(pb, v(0.9 * s, 0.75 * s, 0.25 * s), at(0.25, -2.0, 0.9), CRUST)
			B:block(pb, v(0.6 * s, 0.5 * s, 0.25 * s), at(-0.3, -2.9, 0.62) * ang(-18, 0, 0), CRUST_DK)
			-- hot stripe down the front + a highlight block
			B:bar(pb, (at(0.25, -1.35, -1.02)).Position, (at(0.15, -3.15, -1.1)).Position, 0.26 * s, 0.18 * s, GLOW_HOT, { mat = "Neon", name = "PepGlow" .. i })
			B:block(pb, v(0.45 * s, 0.7 * s, 0.2 * s), at(-0.4, -1.75, -0.95), LAVA_HOT)
			-- dripping neon tip, hooked forward
			local tipC = at(0, -4.45, -2.0) * ang(-70, 0, 0)
			B:block(pb, v(0.5 * s, 0.7 * s, 0.5 * s), tipC, GLOW_HOT, { mat = "Neon", name = "PepTip" .. i })
			tips[i] = tipC.Position
		end

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local heat = B:block(crop, v(7.5, 6, 6.5), cf(0, 9.5, 0), LAVA, { tr = 1, name = "HeatZone" })
		B:emitter(heat, "ember", { name = "Embers", color = { LAVA_HOT, GLOW, "#c8361a" }, rate = 7, size = { 0.34, 0.24, 0 }, life = { 1.6, 2.6 }, speed = { 0.6, 1.6 }, spread = 40, accel = { 0, 2.2, 0 }, light = 1 })
		B:emitter(heat, "sparkle", { name = "HeatSparkles", color = { LAVA_HOT, "#fff2c0", GLOW_HOT }, rate = 5, size = { 0.15, 0.45, 0 }, life = { 0.8, 1.4 }, light = 1 })
		-- lava drips from three pepper tips (emit from small hidden blocks at the tips)
		for _, i in { 1, 3, 5 } do
			local dp = B:block("Pepper" .. i, v(0.3, 0.2, 0.3), CFrame.new(tips[i] - v(0, 0.25, 0)), LAVA, { tr = 1, name = "DripFx" .. i })
			B:emitter(dp, "drip", { name = "Drip" .. i, color = { LAVA_HOT, LAVA, "#c8361a" }, rate = (i == 3) and 2.2 or 1.4, size = { 0.32, 0.28, 0.12 }, life = { 0.5, 0.75 }, light = 0.8 })
		end
		-- the flare pepper's burst emitters
		local flare = B:block("Pepper3", v(0.6, 0.6, 0.6), CFrame.new(tips[3]), LAVA, { tr = 1, name = "FlareFx" })
		B:emitter(flare, "burst", { name = "FlareSparks", color = { "#fff2b0", LAVA_HOT, GLOW }, size = { 0.55, 0.35, 0 }, speed = { 6, 12 }, life = { 0.5, 1.0 }, spread = 70, accel = { 0, -6, 0 }, drag = 2, light = 1 })
		B:emitter(flare, "fire", { name = "FlareFire", rate = 0, color = { LAVA_HOT, GLOW, "#c8361a" }, size = { 1.2, 0.9, 0 }, life = { 0.35, 0.65 }, speed = { 3, 6 }, spread = 35, light = 1 })
		B:light(flare, { name = "FlareLight", color = "#ff8a2a", brightness = 0.6, range = 10 })
		local glowCore = B:block(crop, v(0.4, 0.4, 0.4), cf(0, 7.8, -0.8), LAVA, { tr = 1, name = "BushLightCore" })
		B:light(glowCore, { name = "BushLight", color = "#ff7a2a", brightness = 0.9, range = 12 })
		-- trails on swinging pepper tips
		for _, i in { 2, 3, 4 } do
			local tp = tips[i]
			B:trail("Pepper" .. i, tp + v(-0.3, 0, 0), tp + v(0.3, 0, 0), { name = "PepTrail" .. i, color = { LAVA_HOT, GLOW, "#c8361a" }, life = 0.3, width = { 1, 0 }, trans = { 0.25, 1 } })
		end
	end,
}
