--!nocheck
-- Volcano Fruit Cone (Bramble Badlands crop #8, Cosmic).
-- A cracked charcoal-rock + ash mound (bone "Soil") with glowing lava cracks,
-- lava puddles, bone fragments and two baby volcano sprouts. On it grows a
-- tall plant shaped like a MINI VOLCANO: a stepped cone of overlapping
-- pinecone-like bark scales (rust / charcoal / ash) with glowing lava
-- channels running down its sides, a chunky crater rim crowned by six
-- arching teal cycad fronds, and a bubbling lava crater holding a glowing
-- VOLCANO FRUIT. Five more volcano fruits (molten orange, dark crust,
-- glowing cracks, teal leaf caps) sprout from the slopes on short stalks.
-- ANIM: the crater rumbles, puffs smoke and POPS its fruit high into the
-- air (trail, sparks) once per loop; fronds sway, fruits jiggle.
-- VFX: crater smoke, smoke puffs, rising embers, eruption sparks, landing
-- sparks, heat sparkles, fruit trail, two warm lights.
return {
	DisplayName = "Volcano Fruit Cone",
	Rarity = "Cosmic",
	Element = "Fire",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Bramble Badlands) --------------------------------------
		local ROCK_XD, ROCK_DK, ROCK, ROCK_LT = "#1f1b1b", "#2c2626", "#3d3533", "#554a46"
		local ASH_DK, ASH, ASH_LT = "#6e6964", "#8c8781", "#aaa49c"
		local RUST_XD, RUST_DK, RUST, RUST_LT = "#4f2216", "#6e2f1d", "#9a4428", "#c2623a"
		local BONE, BONE_DK = "#f0e4c6", "#d2c29a"
		local LAVA_XD, LAVA_DK, LAVA, LAVA_LT, LAVA_HOT = "#8e1f12", "#c8361a", "#ff6a1c", "#ff9c34", "#ffd45a"
		local TEAL_XD, TEAL_DK, TEAL, TEAL_LT = "#1e3a37", "#2b5550", "#3c7469", "#5aa595"
		local NEON = { mat = "Neon" }

		local seed = 8188
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
		-- CRACKED ROCK + ASH MOUND (bone "Soil", parts named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local SN = { name = "Soil", mat = "Neon" }
		local function disc(bone, y0, h, r, col, o)
			B:block(bone, v(2 * r, h, 1.15 * r), cf(0, y0 + h / 2, 0), col, o)
			B:block(bone, v(1.15 * r, h - 0.02, 2 * r), cf(0, y0 + h / 2, 0), col, o)
			B:block(bone, v(1.72 * r, h - 0.04, 1.72 * r), cf(0, y0 + h / 2, 0), col, o)
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
		disc(soil, 0, 0.85, 7.0, ROCK_DK, S)
		edge(0, 0.85, 7.05, 18, { ROCK_DK, ROCK, ROCK_XD, ROCK_DK, RUST_DK }, 0.5, { 1.6, 2.5 }, { 1.3, 1.8 })
		disc(soil, 0.85, 0.7, 5.7, ASH_DK, S)
		edge(0.85, 0.7, 5.75, 15, { ASH_DK, ASH, ROCK, ASH_DK, RUST_DK }, 0.35, { 1.5, 2.2 }, { 1.2, 1.6 })
		local GY = 1.55 -- top of the mound
		-- ash drifts
		for _, a in { { 20, 5.6, 2.2 }, { 140, 5.7, 1.8 }, { 230, 5.5, 2.4 }, { 330, 5.6, 1.6 } } do
			B:block(soil, v(a[3], 0.2, 0.9), facing(pv(a[2] - 0.6, a[1], GY + 0.03), a[1]) * ang(-5, 0, 0), ASH_LT, S)
		end

		-- glowing lava cracks (zigzag)
		local function crack(deg, r0, r1, y, wig)
			local a0 = pv(r0, deg, y)
			local mid = pv((r0 + r1) / 2, deg + wig, y)
			local a1 = pv(r1, deg - wig * 0.4, y)
			B:bar(soil, a0, mid, 0.42, 0.1, RUST_DK, S)
			B:bar(soil, mid, a1, 0.42, 0.1, RUST_DK, S)
			B:bar(soil, a0, mid, 0.2, 0.16, LAVA_LT, SN)
			B:bar(soil, mid, a1, 0.2, 0.16, LAVA_LT, SN)
		end
		crack(-15, 5.9, 7.3, 0.86, 7)
		crack(95, 5.9, 7.3, 0.86, -8)
		crack(185, 5.8, 7.2, 0.86, 9)
		crack(275, 5.9, 7.3, 0.86, -6)

		-- jagged rocks
		for _, s in {
			{ 5.8, 1.15, 2.6, 1.3, 25, ROCK }, { 6.3, 1.05, 1.2, 0.8, 10, ROCK_LT },
			{ -6.0, 1.2, -2.0, 1.2, -20, ROCK_DK }, { -5.2, 1.0, -3.9, 0.7, 30, RUST },
			{ -1.8, 1.05, 6.3, 1.0, 5, ROCK }, { 3.6, 1.0, -5.7, 0.8, 40, RUST_DK },
		} do
			B:block(soil, v(s[4] * 1.3, s[4] * 1.15, s[4] * 1.05), cf(s[1], s[2], s[3], jit(10), s[5], jit(10)), s[6], S)
		end

		-- bone fragments
		local function boneBit(p, deg, len, s)
			local d = CFrame.new(p) * CFrame.Angles(0, rad(deg), 0)
			B:block(soil, v(len, 0.38 * s, 0.38 * s), d, BONE, S)
			for _, sx in { -1, 1 } do
				B:block(soil, v(0.45 * s, 0.6 * s, 0.75 * s), d * CFrame.new(sx * len / 2, 0.05, 0), BONE, S)
				B:block(soil, v(0.4 * s, 0.55 * s, 0.35 * s), d * CFrame.new(sx * len / 2, 0.06, 0.4 * s), BONE_DK, S)
			end
		end
		boneBit(v(2.6, 1.06, -6.1), 70, 1.8, 1)
		boneBit(v(-6.4, 1.0, 1.4), 15, 1.5, 0.9)
		boneBit(v(4.9, GY + 0.2, 1.4), -40, 1.2, 0.75)
		-- a little dino skull fossil half-buried at the back-right
		local sk = CFrame.new(4.3, GY + 0.45, 3.9) * CFrame.Angles(0, rad(-140), rad(8))
		B:block(soil, v(1.6, 0.9, 1.3), sk, BONE, S)
		B:block(soil, v(1.1, 0.6, 1.0), sk * CFrame.new(0, -0.1, -1.05), BONE, S)
		B:block(soil, v(0.4, 0.35, 0.3), sk * CFrame.new(0.35, 0.15, -0.6), ROCK_XD, S) -- eye socket
		B:block(soil, v(0.4, 0.35, 0.3), sk * CFrame.new(-0.35, 0.15, -0.6), ROCK_XD, S)
		B:block(soil, v(0.18, 0.3, 0.18), sk * CFrame.new(0.3, -0.45, -1.4), BONE_DK, S) -- teeth
		B:block(soil, v(0.18, 0.3, 0.18), sk * CFrame.new(-0.3, -0.45, -1.4), BONE_DK, S)
		B:block(soil, v(0.5, 0.5, 0.9), sk * CFrame.new(0, 0.55, 0.3) * ang(25, 0, 0), BONE_DK, S) -- crest

		-- baby volcano sprouts on the mound
		local function babyCone(p, s)
			B:block(soil, v(1.6 * s, 0.6 * s, 1.6 * s), CFrame.new(p + v(0, 0.3 * s, 0)), RUST_DK, S)
			B:block(soil, v(1.1 * s, 0.6 * s, 1.1 * s), CFrame.new(p + v(0, 0.85 * s, 0)) * ang(0, 45, 0), RUST, S)
			B:block(soil, v(0.75 * s, 0.4 * s, 0.75 * s), CFrame.new(p + v(0, 1.3 * s, 0)), ROCK_DK, S)
			B:block(soil, v(0.4 * s, 0.12, 0.4 * s), CFrame.new(p + v(0, 1.52 * s, 0)), LAVA_HOT, SN)
			B:block(soil, v(0.25 * s, 0.7 * s, 0.12), CFrame.new(p + v(0.2 * s, 0.9 * s, -0.56 * s)), LAVA, S)
		end
		babyCone(v(-5.0, GY - 0.05, -2.6), 1.0)
		babyCone(v(5.2, GY - 0.05, -2.4), 0.75)

		------------------------------------------------------------------
		-- THE VOLCANO PLANT
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, GY, 0))
		local NT = 10 -- cone tiers
		local TH = 1.6 -- tier height
		local SPLIT = 6 -- tiers >= SPLIT ride on the ConeTop bone
		local function tierR(k)
			return 2.05 + 3.0 * (1 - k / (NT - 1)) ^ 1.8
		end
		local function tierY(k)
			return GY + k * TH
		end
		local coneTop = B:bone("ConeTop", "Crop", v(0, tierY(SPLIT), 0))
		local RIM = tierY(NT) -- top of the cone (crater floor level)

		-- root flare gripping the mound
		for i = 0, 5 do
			local a = i * 60 + 10
			local p0 = pv(4.4, a, GY + 0.9)
			local p1 = pv(5.7, a + 6, GY - 0.1)
			B:bar(crop, p0, p1, 0.85, 0.7, (i % 2 == 0) and RUST_DK or ROCK_DK, { up = v(0, 1, 0) })
		end

		-- tiers: octagon core + pinecone scales
		local SCALE_COLS = {
			{ RUST_DK, RUST, RUST_LT },
			{ ROCK_DK, ROCK, ASH_DK },
			{ RUST_XD, RUST_DK, RUST },
		}
		for k = 0, NT - 1 do
			local bone = (k >= SPLIT) and coneTop or crop
			local r = tierR(k)
			local y0 = tierY(k)
			local cols = SCALE_COLS[(k % 3) + 1]
			local dr = r - 0.35
			B:block(bone, v(2 * dr, TH + 0.05, 1.15 * dr), cf(0, y0 + TH / 2, 0), (k % 2 == 0) and ROCK_DK or RUST_XD)
			B:block(bone, v(1.15 * dr, TH + 0.03, 2 * dr), cf(0, y0 + TH / 2, 0), (k % 2 == 0) and ROCK_DK or RUST_XD)
			local n = (r > 3.2) and 9 or ((r > 2.6) and 8 or 7)
			for i = 0, n - 1 do
				local a = (i + (k % 2) * 0.5) / n * 360
				local Fr = facing(pv(r - 0.3, a, y0 + TH * 0.55), a) * CFrame.Angles(rad(-18), 0, 0)
				local w = 2 * math.pi * r / n * 0.92
				B:block(bone, v(w, TH * 1.05, 0.7), Fr, cols[1 + (i % 2)])
				if (i + k) % 2 == 0 then
					B:block(bone, v(w * 0.6, 0.4, 0.75), Fr * CFrame.new(0, TH * 0.42, -0.05), cols[3])
				end
			end
		end

		-- crater rim (chunky jagged ring) + lava pool + glowing core
		local rimR = tierR(NT - 1) - 0.1
		for i = 0, 9 do
			local a = i * 36 + jit(5)
			local h = 1.0 + rnd() * 0.6
			local p = pv(rimR + 0.25, a, RIM + h / 2 - 0.15)
			B:block(coneTop, v(1.5, h, 1.1), facing(p, a) * ang(-22 + jit(6), jit(8), 0), (i % 3 == 0) and RUST or ((i % 3 == 1) and ROCK_DK or ROCK), nil)
		end
		disc(coneTop, RIM - 0.1, 0.3, rimR - 0.35, LAVA_DK, nil)
		B:block(coneTop, v(2.4, 0.3, 2.4), cf(0, RIM + 0.12, 0, 0, 45, 0), LAVA, nil)
		B:block(coneTop, v(1.6, 0.25, 1.6), cf(0, RIM + 0.2, 0), LAVA_HOT, { mat = "Neon", name = "CraterCore" })
		-- lava drips over the rim
		for _, a in { 40, 160, 285 } do
			local p0 = pv(rimR - 0.6, a, RIM + 0.15)
			local p1 = pv(rimR + 0.45, a, RIM + 0.3)
			B:bar(coneTop, p0, p1, 0.75, 0.3, LAVA, nil)
			B:bar(coneTop, p0 + v(0, 0.05, 0), p1 + v(0, 0.05, 0), 0.32, 0.3, LAVA_HOT, { mat = "Neon", name = "LavaGlow" })
		end

		-- lava channels running down the slopes (plastic bed + neon core)
		for ci, a0 in { 40, 160, 285 } do
			local pts = {}
			for _, k in { NT, NT - 2, NT - 4, NT - 6, NT - 8, NT - 10 } do
				local kk = math.min(k, NT - 1)
				local r = tierR(kk) + ((k == NT) and 0.55 or 0.45)
				local a = a0 + 5 * math.sin(k * 1.3 + ci)
				table.insert(pts, { pv(r, a, tierY(k) + ((k == NT) and 0.2 or 0.0)), k })
			end
			for i = 1, #pts - 1 do
				local p0, p1, k = pts[i][1], pts[i + 1][1], pts[i][2]
				local bone = (k > SPLIT) and coneTop or crop
				if k == SPLIT + 1 or (k > SPLIT and pts[i + 1][2] < SPLIT) then
					bone = coneTop
				end
				B:bar(bone, p0, p1, 0.85, 0.35, LAVA_DK, nil)
				B:bar(bone, p0 + (p0 - v(0, p0.Y, 0)).Unit * 0.12, p1 + (p1 - v(0, p1.Y, 0)).Unit * 0.12, 0.34, 0.3, LAVA_HOT, { mat = "Neon", name = "LavaGlow" })
			end
			-- lava puddle where it reaches the mound
			local e = pts[#pts][1]
			local d = (e - v(0, e.Y, 0)).Unit
			B:block(soil, v(1.8, 0.16, 1.3), CFrame.lookAt(v(e.X, GY + 0.05, e.Z) + d * 0.8, v(e.X, GY + 0.05, e.Z) + d * 2), LAVA_DK, S)
			B:block(soil, v(0.9, 0.18, 0.7), CFrame.lookAt(v(e.X, GY + 0.07, e.Z) + d * 0.8, v(e.X, GY + 0.07, e.Z) + d * 2), LAVA_LT, S)
		end

		------------------------------------------------------------------
		-- FRONDS: six arching teal cycad leaves from below the rim
		------------------------------------------------------------------
		local FR = {
			-- deg, base pitch, length scale
			{ 75, -46, 1.0 }, { 125, -54, 0.9 }, { 197, -44, 1.05 }, { 247, -52, 0.92 }, { 317, -46, 1.0 }, { 7, -54, 0.9 },
		}
		for fi, f in FR do
			local deg = f[1]
			local fk = NT - 3
			local base = pv(tierR(fk) - 0.1, deg, tierY(fk) + TH * 0.7)
			local Pb = facing(base, deg)
			local fb = B:bone("Frond" .. fi, "ConeTop", Pb)
			local F = Pb * CFrame.Angles(rad(f[2]), 0, 0)
			local segs = { { 2.0, 1.3, 0 }, { 2.0, 1.1, -16 }, { 1.7, 0.85, -22 }, { 1.1, 0.55, -26 } }
			for si, sg in segs do
				F = F * CFrame.Angles(rad(sg[3]), 0, 0)
				local len = sg[1] * f[3]
				local isTip = si == #segs
				B:block(fb, v(sg[2] + 0.1, len + 0.15, 0.35), F * CFrame.new(0, len / 2, 0), isTip and RUST_LT or ((si % 2 == 1) and TEAL_DK or TEAL))
				if not isTip then
					-- leaflet pair
					for _, sx in { -1, 1 } do
						local L0 = F * CFrame.new(sx * (sg[2] / 2 + 0.1), len * 0.55, 0) * CFrame.Angles(0, 0, rad(-sx * 55))
						B:block(fb, v(0.5, 1.8 * f[3] - si * 0.22, 0.3), L0 * CFrame.new(0, 0.7 - si * 0.08, 0), (si % 2 == 1) and TEAL or TEAL_LT)
					end
				end
				F = F * CFrame.new(0, len, 0)
			end
		end

		------------------------------------------------------------------
		-- VOLCANO FRUITS
		------------------------------------------------------------------
		local function vfruit(bone, C, s, coreName)
			B:block(bone, v(1.5 * s, 1.5 * s, 1.5 * s), C, RUST_DK)
			B:block(bone, v(1.85 * s, 1.1 * s, 1.1 * s), C, LAVA)
			B:block(bone, v(1.1 * s, 1.85 * s, 1.1 * s), C, LAVA_LT)
			B:block(bone, v(1.1 * s, 1.1 * s, 1.85 * s), C, LAVA)
			B:block(bone, v(1.62 * s, 0.6 * s, 0.6 * s), C * CFrame.new(0, -0.2 * s, 0), LAVA_DK)
			-- glowing cracks
			B:block(bone, v(0.25 * s, 0.9 * s, 0.25 * s), C * CFrame.new(0.3 * s, 0.1 * s, -0.84 * s) * ang(0, 0, 25), LAVA_HOT, { mat = "Neon", name = coreName })
			B:block(bone, v(0.86 * s, 0.25 * s, 0.25 * s), C * CFrame.new(-0.84 * s, 0.2 * s, 0.2 * s) * ang(0, 90, 15), LAVA_HOT, { mat = "Neon", name = coreName })
			-- dark crust flecks
			B:block(bone, v(0.55 * s, 0.55 * s, 0.3 * s), C * CFrame.new(-0.45 * s, -0.4 * s, -0.86 * s), ROCK_DK)
			B:block(bone, v(0.3 * s, 0.5 * s, 0.55 * s), C * CFrame.new(0.88 * s, 0.35 * s, 0.35 * s), ROCK_DK)
			-- teal leaf cap + stem nub
			B:block(bone, v(0.32 * s, 0.6 * s, 0.32 * s), C * CFrame.new(0, 1.15 * s, 0), RUST_XD)
			for k = 0, 2 do
				B:block(bone, v(0.38 * s, 0.2 * s, 0.95 * s), C * CFrame.new(0, 0.98 * s, 0) * ang(0, k * 120 + 15, 0) * CFrame.new(0, 0, -0.4 * s) * ang(-22, 0, 0), (k == 0) and TEAL_LT or TEAL)
			end
		end

		-- slope fruits on short stalks (own bones -> jiggle)
		local SF = {
			-- deg, tier, size
			{ 100, 3, 1.2 }, { 222, 2, 1.25 }, { 342, 3, 1.15 }, { 130, 0, 1.05 }, { 252, 5, 1.05 },
		}
		for i, f in ipairs(SF) do
			local k = f[2]
			local parent = (k >= SPLIT) and "ConeTop" or "Crop"
			local r = tierR(k)
			local base = pv(r + 0.1, f[1], tierY(k) + TH * 0.6)
			local Fb = facing(base, f[1])
			local fb = B:bone("Fruit" .. i, parent, Fb)
			local tip = (Fb * CFrame.new(0, 1.0, -1.1)).Position
			B:bar(fb, base, tip, 0.4, 0.4, TEAL_DK)
			B:block(fb, v(0.65, 0.4, 0.65), CFrame.new(base) * CFrame.Angles(0, -rad(f[1]), 0), TEAL_XD)
			local C = Fb * CFrame.new(0, 1.0 + 0.95 * f[3], -1.25) * ang(0, 20, 0)
			vfruit(fb, C, f[3], "FruitCore" .. i)
		end

		-- the crater fruit that pops (own bone, pivot at its centre)
		local POPC = v(0, RIM + 1.55, 0)
		local pop = B:bone("PopFruit", "ConeTop", POPC)
		vfruit(pop, CFrame.new(POPC) * ang(0, 30, 0), 1.35, "PopCore")

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local craterFx = B:block(coneTop, v(2.4, 0.6, 2.4), cf(0, RIM + 0.8, 0), LAVA, { tr = 1, name = "CraterFx" })
		B:emitter(craterFx, "smoke", { name = "CraterSmoke", color = { "#7d7570", "#5a5350", "#9a938c" }, rate = 2.2, size = { 1.2, 2.8, 4.0 }, trans = { 0.5, 0.65, 1 }, life = { 2.2, 3.4 }, speed = { 1.2, 2.2 }, spread = 14, accel = { 0.3, 0.6, 0.1 } })
		B:emitter(craterFx, "smoke", { name = "SmokePuff", rate = 0, color = { "#8e8680", "#5e5753", "#b4aca4" }, size = { 1.6, 3.6, 5.0 }, trans = { 0.35, 0.55, 1 }, life = { 1.6, 2.6 }, speed = { 4, 8 }, spread = 30, accel = { 0, 0.4, 0 }, drag = 1.5 })
		B:emitter(craterFx, "ember", { name = "CraterEmbers", color = { LAVA_HOT, LAVA_LT, LAVA_DK }, rate = 8, size = { 0.32, 0.24, 0 }, life = { 1.4, 2.4 }, speed = { 2.0, 4.0 }, spread = 22, accel = { 0, 1.0, 0 }, light = 1 })
		B:emitter(craterFx, "burst", { name = "EruptSparks", color = { LAVA_HOT, "#fff2b0", LAVA }, size = { 0.7, 0.45, 0 }, speed = { 9, 17 }, life = { 0.7, 1.3 }, spread = 40, accel = { 0, -12, 0 }, drag = 1.2, light = 1 })
		B:emitter(craterFx, "burst", { name = "LandSparks", color = { LAVA_HOT, LAVA_LT }, size = { 0.5, 0.3, 0 }, speed = { 4, 8 }, life = { 0.4, 0.8 }, spread = 70, accel = { 0, -8, 0 }, light = 1 })
		local heatZone = B:block(crop, v(10, 9, 10), cf(0, GY + 6.5, 0), LAVA, { tr = 1, name = "HeatZone" })
		B:emitter(heatZone, "sparkle", { name = "HeatSparkles", color = { LAVA_HOT, "#ffffff", LAVA_LT }, rate = 9, size = { 0.2, 0.6, 0 }, life = { 0.8, 1.6 }, speed = { 0.3, 0.9 }, light = 1 })
		B:trail(pop, POPC + v(-0.7, 0, 0), POPC + v(0.7, 0, 0), { name = "PopTrail", color = { LAVA_HOT, LAVA, LAVA_DK }, life = 0.35, width = { 1, 0 }, trans = { 0.1, 1 } })
		local craterLight = B:block(coneTop, v(0.4, 0.4, 0.4), cf(0, RIM + 1.4, 0), LAVA, { tr = 1, name = "CraterLightCore" })
		B:light(craterLight, { name = "CraterLight", color = "#ff8a3a", brightness = 1.2, range = 16 })
		local coneLight = B:block(crop, v(0.4, 0.4, 0.4), cf(0, GY + 4.5, -4.8), LAVA, { tr = 1, name = "ConeLightCore" })
		B:light(coneLight, { name = "ConeLight", color = "#ff7a2a", brightness = 0.9, range = 12 })
	end,
}
