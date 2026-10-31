--!nocheck
-- Mini Smoking Volcano (Bramble Badlands decoration, medium).
-- A chunky little stepped volcano for dressing the badlands:
-- * footing: charcoal flagstones, a cooled lava puddle with a glowing heart,
--   loose rocks, a bone and dry grass tufts (bone "Soil", removable)
-- * a stepped octagonal cone in charcoal / rust / ash bands with jagged edge
--   chunks, a couple of thin glowing cracks and a dino bone stuck in its side
-- * a chunky notched crater rim around a glowing lava pool; a lava drip
--   tumbles out of the notch and steps down the slope into the puddle
-- * crater smoke, rising embers and one warm light
-- ANIM (motion.luau, 8 s loop): the lava glow pulses hot/cool, the glow runs
-- down the drip, and a lava bubble swells and plops in the crater.
return {
	DisplayName = "Mini Smoking Volcano",
	Rarity = "Decor",
	Element = "Bramble Badlands",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Bramble Badlands) --------------------------------------
		local RK_XD, RK_DK, RK, RK_LT = "#1f1b1b", "#2c2626", "#3d3533", "#554a46"
		local ASH_DK, ASH, ASH_LT = "#6e6964", "#8c8781", "#aaa49c"
		local RUST_XD, RUST_DK, RUST, RUST_LT = "#4f2216", "#6e2f1d", "#9a4428", "#c2623a"
		local BONE, BONE_LT, BONE_DK = "#efe0bc", "#fbf1d8", "#d2c29a"
		local LAVA_DK, LAVA, LAVA_LT, LAVA_HOT = "#c8361a", "#ff6a1c", "#ff9c34", "#ffd45a"
		local GRASS, GRASS_DK = "#9a8a4a", "#76693a"
		local NEON = { mat = "Neon" }

		local seed = 41177
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
		local function facing(p, deg) -- local -Z points outward at angle deg
			return CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
		end
		local function disc(bone, y0, h, r, col, o)
			B:block(bone, v(2 * r, h, 1.15 * r), cf(0, y0 + h / 2, 0), col, o)
			B:block(bone, v(1.15 * r, h - 0.02, 2 * r), cf(0, y0 + h / 2, 0), col, o)
			B:block(bone, v(1.72 * r, h - 0.04, 1.72 * r), cf(0, y0 + h / 2, 0), col, o)
		end

		local DRIP = 35 -- angle of the rim notch / lava drip (front-right)
		local CRACKS = { { 180, 0, 4 }, { 270, 2, 5 }, { 90, 0, 2 } } -- glowing slope cracks: angle, tiers

		------------------------------------------------------------------
		-- FOOTING (bone "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local SN = { name = "Soil", mat = "Neon" }
		disc(soil, 0, 0.3, 5.9, RK_DK, S)
		for i = 0, 13 do
			local a = i / 14 * 360 + jit(8)
			if math.abs(((a - DRIP + 180) % 360) - 180) > 22 then
				local w, d = 1.6 + rnd() * 0.9, 1.2 + rnd() * 0.6
				B:block(soil, v(w, 0.35 + rnd() * 0.2, d), facing(pv(6.0 + jit(0.25), a, 0.2), a) * ang(jit(3), jit(12), jit(3)), pick({ RK_DK, RK, ASH_DK, RK_XD, RUST_DK }), S)
			end
		end
		-- cooled lava puddle at the foot of the drip, glowing heart
		local px, pz = polar(6.3, DRIP)
		B:block(soil, v(3.2, 0.3, 2.4), cf(px, 0.22, pz, 0, -DRIP + 10, 0), RK_XD, S)
		B:block(soil, v(2.4, 0.3, 3.0), cf(px, 0.24, pz, 0, -DRIP - 20, 0), RK_XD, S)
		B:block(soil, v(2.0, 0.12, 1.5), cf(px, 0.4, pz, 0, -DRIP + 10, 0), LAVA, SN)
		B:block(soil, v(1.3, 0.12, 1.8), cf(px + 0.1, 0.42, pz, 0, -DRIP - 25, 0), LAVA_LT, SN)
		B:block(soil, v(0.6, 0.1, 0.6), cf(px - 0.2, 0.48, pz + 0.1, 0, 30, 0), LAVA_HOT, { name = "PuddleGlow", mat = "Neon" })
		-- crust lumps around the puddle
		for _, o in { { 1.4, 0.5 }, { -1.3, -0.4 }, { 0.3, -1.3 }, { -0.4, 1.3 } } do
			B:block(soil, v(0.7, 0.4, 0.6), cf(px + o[1], 0.45, pz + o[2], jit(6), jit(40), jit(6)), RK, S)
		end
		-- rocks + a bone + grass tufts
		for _, r in { { -5.6, -2.4, 1.1, RK }, { -4.4, 3.9, 0.9, RUST_DK }, { 2.1, 5.6, 1.0, RK_LT }, { 5.8, 2.3, 0.7, ASH_DK } } do
			B:block(soil, v(r[3] * 1.3, r[3], r[3] * 1.1), cf(r[1], 0.3 + r[3] / 2, r[2], jit(8), jit(40), jit(8)), r[4], S)
		end
		local bf = cf(-3.3, 0.55, -5.3, 0, 25, 0)
		B:block(soil, v(1.6, 0.38, 0.38), bf, BONE, S)
		for sx = -1, 1, 2 do
			B:block(soil, v(0.45, 0.55, 0.45), bf * CFrame.new(sx * 0.85, 0, 0.18), BONE_LT, S)
			B:block(soil, v(0.45, 0.55, 0.45), bf * CFrame.new(sx * 0.85, 0, -0.18), BONE_DK, S)
		end
		local function tuft(x, z, s)
			for k = 0, 2 do
				local a = k * 120 + jit(20)
				local h = (0.9 + rnd() * 0.5) * s
				B:block(soil, v(0.18, h, 0.18), CFrame.new(x, 0.3 + h / 2, z) * CFrame.Angles(0, rad(a), 0) * CFrame.Angles(rad(18), 0, 0) * CFrame.new(0, 0, -0.12), (k == 1) and GRASS_DK or GRASS, S)
			end
		end
		tuft(-5.9, 1.0, 1.0)
		tuft(4.6, -4.4, 0.9)
		tuft(-1.5, 5.9, 1.0)

		------------------------------------------------------------------
		-- STEPPED CONE (bone "Root")
		------------------------------------------------------------------
		local R = "Root"
		local NT, TH, Y0 = 8, 1.05, 0.3
		local function tierR(k)
			return 1.85 + 3.35 * (1 - k / (NT - 1)) ^ 1.1
		end
		local bands = {
			{ RK_DK, { RK_DK, RK, RK_XD } },
			{ RUST_XD, { RUST_XD, RK, RUST_DK } },
			{ RUST_DK, { RUST_DK, RUST_XD, RUST } },
			{ RUST, { RUST, RUST_DK, RUST_LT } },
			{ RUST_LT, { RUST_LT, RUST, ASH_DK } },
			{ RUST, { RUST, RUST_DK, RUST_LT } },
			{ RUST_DK, { RUST_DK, RUST, RK_LT } },
			{ RK, { RK, RK_LT, RK_DK } },
		}
		for k = 0, NT - 1 do
			local r = tierR(k)
			local y0 = Y0 + k * TH
			disc(R, y0, TH, r, bands[k + 1][1])
			-- jagged edge chunks breaking up the silhouette
			local n = math.max(6, math.floor(r * 2.4))
			for i = 0, n - 1 do
				local a = (i + 0.5 + jit(0.25)) / n * 360 + k * 17
				local clear = math.abs(((a - DRIP + 180) % 360) - 180) > 16
				for _, ca in CRACKS do
					if math.abs(((a - ca[1] + 180) % 360) - 180) < 11 and k >= ca[2] and k <= ca[3] then
						clear = false
					end
				end
				if clear then
					local hh = TH + rnd() * 0.35 - 0.05
					local w = 1.0 + rnd() * 0.8
					B:block(R, v(w, hh, 0.9 + rnd() * 0.4), facing(pv(r - 0.15 + jit(0.12), a, y0 + hh / 2), a) * ang(jit(4), jit(10), jit(4)), pick(bands[k + 1][2]))
				end
			end
		end
		local TOP = Y0 + NT * TH -- top of the cone

		-- crater rim: chunky ring of blocks with a notch toward the drip
		local RIM_R = tierR(NT - 1)
		for i = 0, 9 do
			local a = DRIP + 18 + i * 32.4
			local hh = 0.55 + rnd() * 0.4
			B:block(R, v(1.4, hh, 0.9), facing(pv(RIM_R + 0.25, a, TOP + hh / 2 - 0.05), a) * ang(jit(5), jit(8), jit(5)), pick({ RK_DK, RK, RK_XD, RK_LT }))
		end
		-- lava pool (base layer) + hot overlays that pulse (motion)
		disc(R, TOP - 0.05, 0.3, 1.55, LAVA_DK)
		B:block(R, v(2.3, 0.14, 2.3), cf(0, TOP + 0.3, 0, 0, 0, 0), LAVA, NEON)
		B:block(R, v(2.25, 0.14, 2.25), cf(0, TOP + 0.31, 0, 0, 45, 0), LAVA_LT, NEON)
		B:block(R, v(1.7, 0.1, 1.7), cf(0, TOP + 0.4, 0, 0, 45, 0), LAVA_HOT, { mat = "Neon", name = "LavaGlow" })
		B:block(R, v(1.25, 0.1, 1.25), cf(0.15, TOP + 0.43, -0.1, 0, 15, 0), LAVA_HOT, { mat = "Neon", name = "LavaGlowB" })
		-- crust islands floating on the lava
		B:block(R, v(0.5, 0.2, 0.4), cf(-0.75, TOP + 0.42, 0.5, 0, 30, 0), RK_DK)
		B:block(R, v(0.35, 0.18, 0.35), cf(0.7, TOP + 0.42, 0.6, 0, 10, 0), RK)

		-- lava bubble that swells and plops (bone "Bubble")
		local bub = B:bone("Bubble", "Root", v(-0.3, TOP + 0.2, -0.2))
		B:block(bub, v(0.65, 0.5, 0.65), cf(-0.3, TOP + 0.35, -0.2, 0, 20, 0), LAVA_HOT, NEON)
		B:block(bub, v(0.45, 0.3, 0.45), cf(-0.3, TOP + 0.62, -0.2, 0, 65, 0), LAVA_LT, NEON)

		------------------------------------------------------------------
		-- LAVA DRIP stepping down the slope out of the notch
		------------------------------------------------------------------
		local dripN = 0
		for k = NT - 1, 0, -1 do
			local r = tierR(k)
			local y0 = Y0 + k * TH
			local wob = (k % 2 == 0) and 3 or -3
			local a = DRIP + wob
			local w = 0.8 + (NT - 1 - k) * 0.05
			-- vertical run down the tier face
			local face = facing(pv(r + 0.08, a, y0 + TH / 2 + 0.05), a)
			B:block(R, v(w, TH + 0.12, 0.42), face, LAVA, NEON)
			-- flat run across the ledge below to the next face
			local rn = (k > 0) and tierR(k - 1) or 5.6
			local ledge = (rn - r)
			if ledge > 0.05 then
				local mid = pv(r + ledge / 2 + 0.1, a + ((k % 2 == 0) and -1.5 or 1.5), y0 + 0.07)
				B:block(R, v(w - 0.05, 0.16, ledge + 0.45), facing(mid, a), LAVA, NEON)
			end
			-- hot core that the motion runs down the drip
			if k % 2 == 1 or k == 0 then
				dripN += 1
				local nm = "DripGlow" .. dripN
				B:block(R, v(w * 0.6, TH * 0.85, 0.12), face * CFrame.new(0, 0, -0.24), LAVA_HOT, { mat = "Neon", name = nm })
			end
		end
		-- a final tongue of lava flowing out to the puddle
		local t0, t1 = pv(5.0, DRIP, 0.42), pv(6.0, DRIP + 2, 0.42)
		B:bar(R, t0, t1, 0.9, 0.18, LAVA, NEON)

		-- thin glowing cracks on the slope
		local function crack(deg, k0, k1)
			for k = k0, k1 do
				local r = tierR(k)
				local a = deg + ((k % 2 == 0) and 4 or -4)
				B:block(R, v(0.34, TH * 0.9, 0.2), facing(pv(r + 0.02, a, Y0 + k * TH + TH / 2), a), (k % 2 == 0) and LAVA or LAVA_LT, NEON)
			end
		end
		for _, c in CRACKS do
			crack(c[1], c[2], c[3])
		end

		-- a dino bone stuck in the side of the volcano
		local ba = 210
		local bb = pv(tierR(2) - 0.6, ba, Y0 + 2.6)
		local bt = pv(tierR(2) + 2.0, ba - 8, Y0 + 3.9)
		B:bar(R, bb, bt, 0.62, 0.62, BONE)
		local bo = CFrame.lookAt(bt, bt + (bt - bb).Unit)
		B:block(R, v(0.8, 0.8, 0.8), bo * CFrame.new(0.32, 0, 0), BONE_LT)
		B:block(R, v(0.8, 0.8, 0.8), bo * CFrame.new(-0.32, 0, 0.05), BONE)
		B:block(R, v(1.0, 0.45, 0.5), bo * CFrame.new(0, -0.25, 0.2), BONE_DK)
		-- a few loose boulders sitting on the ledges
		for _, b in { { 2, 120, 0.7, RK_LT }, { 4, 300, 0.6, ASH }, { 1, 260, 0.8, RUST_LT } } do
			local k = b[1]
			B:block(R, v(b[3] * 1.2, b[3], b[3]), facing(pv(tierR(k + 1) + 0.35, b[2], Y0 + (k + 1) * TH + b[3] / 2 - 0.05), b[2]) * ang(jit(8), jit(30), jit(8)), b[4])
		end

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local cz = B:block(R, v(2.2, 0.6, 2.2), cf(0, TOP + 0.8, 0), LAVA, { tr = 1, name = "CraterZone" })
		B:emitter(cz, "smoke", { name = "CraterSmoke", color = { "#6a6462", "#9a9490", "#bdb8b4" }, rate = 2.8, size = { 1.0, 2.4, 3.6 }, speed = { 1.4, 2.2 }, life = { 2.6, 3.8 }, spread = 14, accel = { 0.25, 0.4, 0 } })
		B:emitter(cz, "ember", { name = "CraterEmbers", color = { "#ffe27a", "#ff8a24", "#e8401f" }, rate = 5, size = { 0.22, 0.14, 0 }, speed = { 1.6, 3.0 }, life = { 1.2, 2.2 }, spread = 28, accel = { 0, 0.6, 0 } })
		B:emitter(cz, "glow", { name = "CraterGlow", color = { "#ffa040", "#ff6a2a" }, rate = 1.2, size = { 2.4, 3.2, 0.6 }, life = { 0.8, 1.4 }, speed = { 0.2, 0.5 } })
		B:light(cz, { name = "CraterLight", color = "#ff8a3a", brightness = 1.1, range = 16 })
	end,
}
