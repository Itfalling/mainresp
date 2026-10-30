--!nocheck
-- Lava Lily (Bramble Badlands crop #7, Secret).
-- A cracked charcoal-rock + ash mound (bone "Soil") with glowing lava cracks,
-- bone fragments and jagged rocks holds a bubbling LAVA POOL: orange molten
-- channels between dark floating crust plates. Out of the lava rise dark teal
-- strap leaves and a tall curved stem carrying a huge recurved LAVA LILY
-- (six outer + five inner petals grading deep red -> lava orange -> gold,
-- cream stamens with hot tips, a molten lava-orb fruit in its heart). Two
-- smaller lilies on shorter stems, three obsidian lily pads floating on the
-- lava (one carrying a lava bulb).
-- ANIM: every petal sits on its own bone (pivot at the petal base) so the
-- blooms breathe open/closed; pads bob; stems sway. VFX: lava bubbles,
-- rising embers, bloom sparkles, a pop-splash burst, bloom ember burst,
-- warm lights.
return {
	DisplayName = "Lava Lily",
	Rarity = "Secret",
	Element = "Fire",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Bramble Badlands) --------------------------------------
		local ROCK_XD, ROCK_DK, ROCK, ROCK_LT = "#1f1b1b", "#2c2626", "#3d3533", "#554a46"
		local ASH_DK, ASH, ASH_LT = "#6e6964", "#8c8781", "#aaa49c"
		local RUST_DK, RUST, RUST_LT = "#6e2f1d", "#9a4428", "#c2623a"
		local BONE, BONE_DK = "#f0e4c6", "#d2c29a"
		local LAVA_XD, LAVA_DK, LAVA, LAVA_LT, LAVA_HOT = "#8e1f12", "#c8361a", "#ff6a1c", "#ff9c34", "#ffd45a"
		local CRUST, CRUST_LT = "#2a2222", "#3b302d"
		local TEAL_XD, TEAL_DK, TEAL, TEAL_LT = "#1e3a37", "#2b5550", "#3c7469", "#5aa595"
		local PET_DK, PET, PET_MID, PET_LT, PET_TIP = "#b0261c", "#e2401f", "#ff6e22", "#ff9f35", "#ffd35c"
		local NEON = { mat = "Neon" }

		local seed = 7177
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
		disc(0, 0.85, 6.9, ROCK_DK)
		edge(0, 0.85, 6.95, 18, { ROCK_DK, ROCK, ROCK_XD, ROCK_DK, RUST_DK }, 0.5, { 1.6, 2.5 }, { 1.3, 1.8 })
		disc(0.85, 0.7, 5.6, ASH_DK)
		edge(0.85, 0.7, 5.65, 15, { ASH_DK, ASH, ROCK, ASH_DK }, 0.35, { 1.5, 2.2 }, { 1.2, 1.6 })
		-- ash drifts on the second tier
		for _, a in { { 20, 5.4, 2.2 }, { 140, 5.5, 1.8 }, { 230, 5.3, 2.4 }, { 310, 5.5, 1.6 } } do
			B:block(soil, v(a[3], 0.2, 0.9), facing(pv(a[2] - 0.6, a[1], 1.6), a[1]) * ang(-5, 0, 0), ASH_LT, S)
		end

		-- glowing lava cracks across the rock (zigzag thin neon strips)
		local function crack(deg, r0, r1, y, wig)
			local a0 = pv(r0, deg, y)
			local mid = pv((r0 + r1) / 2, deg + wig, y)
			local a1 = pv(r1, deg - wig * 0.4, y)
			B:bar(soil, a0, mid, 0.42, 0.1, RUST_DK, S)
			B:bar(soil, mid, a1, 0.42, 0.1, RUST_DK, S)
			B:bar(soil, a0, mid, 0.2, 0.16, LAVA_LT, SN)
			B:bar(soil, mid, a1, 0.2, 0.16, LAVA_LT, SN)
		end
		crack(-35, 5.8, 7.2, 0.86, 7)
		crack(75, 5.9, 7.3, 0.86, -8)
		crack(165, 5.8, 7.2, 0.86, 9)
		crack(250, 5.9, 7.2, 0.86, -6)
		crack(20, 4.9, 5.8, 1.56, -10)
		crack(200, 4.9, 5.8, 1.56, 12)

		-- jagged rocks on the mound
		for _, s in {
			{ 5.4, 1.15, 2.9, 1.3, 25, ROCK }, { 6.0, 1.05, 1.4, 0.8, 10, ROCK_LT },
			{ -5.7, 1.2, -2.2, 1.2, -20, ROCK_DK }, { -5.0, 1.0, -3.8, 0.7, 30, RUST },
			{ -2.0, 1.05, 6.0, 1.0, 5, ROCK }, { 3.6, 1.0, -5.4, 0.8, 40, RUST_DK },
		} do
			B:block(soil, v(s[4] * 1.3, s[4] * 1.15, s[4] * 1.05), cf(s[1], s[2], s[3], jit(10), s[5], jit(10)), s[6], S)
		end
		B:block(soil, v(0.8, 0.9, 0.7), cf(5.6, 2.05, 2.7, 8, 30, -12), ROCK_LT, S)
		B:block(soil, v(0.6, 0.7, 0.6), cf(-5.6, 2.0, -2.0, -10, 15, 8), ROCK_LT, S)

		-- bone fragments (cartoony femur bits + a little vertebra)
		local function boneBit(p, deg, len, s)
			local d = CFrame.new(p) * CFrame.Angles(0, rad(deg), 0)
			B:block(soil, v(len, 0.38 * s, 0.38 * s), d, BONE, S)
			for _, sx in { -1, 1 } do
				B:block(soil, v(0.45 * s, 0.6 * s, 0.75 * s), d * CFrame.new(sx * len / 2, 0.05, 0), BONE, S)
				B:block(soil, v(0.4 * s, 0.55 * s, 0.35 * s), d * CFrame.new(sx * len / 2, 0.06, 0.4 * s), BONE_DK, S)
			end
		end
		boneBit(v(3.0, 1.06, -5.6), 70, 1.8, 1)
		boneBit(v(-6.2, 1.0, 1.6), 15, 1.5, 0.9)
		boneBit(v(5.0, 1.75, 2.5), -40, 1.1, 0.7)
		-- a big cartoony dino rib arching out of the back-left of the mound
		B:bar(soil, v(-4.4, 0.9, 4.4), v(-5.3, 3.4, 4.9), 1.15, 1.0, BONE, S)
		B:bar(soil, v(-5.3, 3.3, 4.9), v(-5.0, 5.2, 4.2), 0.95, 0.85, BONE, S)
		B:bar(soil, v(-5.0, 5.1, 4.2), v(-4.1, 5.8, 3.4), 0.75, 0.7, BONE_DK, S)
		B:block(soil, v(1.3, 0.8, 1.2), cf(-4.6, 1.2, 4.3, 0, 40, 0), BONE_DK, S)
		B:block(soil, v(1.0, 0.25, 1.0), cf(-4.6, 0.95, 4.3, 0, 10, 0), ASH_LT, S)
		-- vertebra on the back tier
		B:block(soil, v(1.0, 0.6, 0.8), cf(-3.8, 1.85, 4.2, 0, 30, 0), BONE, S)
		B:block(soil, v(0.35, 0.9, 0.35), cf(-3.8, 2.4, 4.2, 0, 30, 0), BONE_DK, S)
		B:block(soil, v(1.6, 0.3, 0.3), cf(-3.8, 1.95, 4.2, 0, 30, 0), BONE_DK, S)

		------------------------------------------------------------------
		-- LAVA POOL (Soil): crust rim, molten channels, dark crust plates
		------------------------------------------------------------------
		local PY = 1.95 -- pool surface
		disc(1.5, 0.3, 4.75, LAVA_DK)
		disc(1.62, 0.3, 4.45, LAVA)
		-- dark rim rocks around the pool
		edge(1.45, 0.55, 4.9, 16, { ROCK_DK, ROCK, CRUST, ROCK_XD, RUST_DK }, 0.25, { 1.1, 1.7 }, { 0.8, 1.1 })
		-- floating crust plates (molten orange shows in the gaps)
		local plates = {
			{ -1.6, 2.4, 1.3, 1.1, -25 }, { 0.4, 3.4, 1.2, 0.8, 10 }, { -3.5, 0.6, 0.8, 1.2, 5 }, { 0.3, -3.5, 1.1, 0.7, -30 },
		}
		for i, p in plates do
			B:block(soil, v(p[3], 0.14, p[4]), cf(p[1], PY + 0.0, p[2], 0, p[5], 0), (i % 2 == 0) and CRUST or CRUST_LT, S)
		end
		-- hot molten streaks + bright spots between plates
		B:block(soil, v(3.2, 0.1, 0.32), cf(-0.2, PY + 0.02, -0.15, 0, 18, 0), LAVA_HOT, SN)
		B:block(soil, v(2.0, 0.1, 0.28), cf(0.9, PY + 0.02, 1.7, 0, -50, 0), LAVA_HOT, SN)
		B:block(soil, v(1.6, 0.1, 0.26), cf(-2.3, PY + 0.02, 0.9, 0, 70, 0), LAVA_LT, SN)
		B:block(soil, v(0.7, 0.12, 0.7), cf(1.0, PY + 0.02, -0.9, 0, 30, 0), LAVA_LT, S)
		-- lava bubble domes
		for _, b in { { -0.9, -2.3, 0.6 }, { 2.9, 2.2, 0.45 }, { -2.6, -0.6, 0.4 } } do
			B:block(soil, v(b[3] * 1.6, b[3], b[3] * 1.6), cf(b[1], PY + b[3] * 0.3, b[2]), LAVA_LT, S)
			B:block(soil, v(b[3], b[3] * 1.2, b[3]), cf(b[1], PY + b[3] * 0.45, b[2]), LAVA_HOT, S)
		end
		-- a lava rivulet spilling over the front rim down the tiers
		B:bar(soil, v(-0.4, 1.95, -4.4), v(-0.6, 1.56, -5.4), 0.9, 0.25, LAVA, S)
		B:bar(soil, v(-0.6, 1.56, -5.4), v(-0.9, 0.86, -6.8), 0.85, 0.25, LAVA_DK, S)
		B:bar(soil, v(-0.4, 2.0, -4.4), v(-0.6, 1.62, -5.4), 0.35, 0.22, LAVA_HOT, SN)
		B:bar(soil, v(-0.6, 1.62, -5.4), v(-0.9, 0.92, -6.8), 0.3, 0.22, LAVA_LT, SN)
		B:block(soil, v(1.4, 0.2, 0.9), cf(-0.95, 0.88, -7.1), LAVA_DK, S)

		------------------------------------------------------------------
		-- PETAL + BLOOM HELPERS
		------------------------------------------------------------------
		-- one recurved petal: base at Pb (local: +Y = up the petal, -Z = outward)
		local function petal(bone, Pb, s, w, segs, cols, rib)
			local F = Pb
			for k, sg in segs do
				F = F * CFrame.Angles(rad(sg[2]), 0, 0)
				local len = sg[1] * s
				local ww = w * sg[3] * s
				B:block(bone, v(ww, len + 0.12 * s, 0.4 * s), F * CFrame.new(0, len / 2, 0), cols[k])
				if rib and k <= 2 then
					B:block(bone, v(ww * 0.34, len * 0.85, 0.12 * s), F * CFrame.new(0, len / 2, 0.2 * s), rib)
				end
				F = F * CFrame.new(0, len, 0)
			end
		end

		-- molten lava-orb fruit (stepped)
		local function orb(bone, C, s, coreName)
			B:block(bone, v(1.5 * s, 1.5 * s, 1.5 * s), C, LAVA_DK)
			B:block(bone, v(1.9 * s, 1.05 * s, 1.05 * s), C, LAVA)
			B:block(bone, v(1.05 * s, 1.9 * s, 1.05 * s), C, LAVA_LT)
			B:block(bone, v(1.05 * s, 1.05 * s, 1.9 * s), C, LAVA)
			B:block(bone, v(0.7 * s, 0.4 * s, 0.7 * s), C * CFrame.new(0, 0.95 * s, 0), LAVA_HOT, { mat = "Neon", name = coreName })
			B:block(bone, v(0.5 * s, 0.5 * s, 0.4 * s), C * CFrame.new(-0.35 * s, 0.25 * s, -0.8 * s), LAVA_HOT, { mat = "Neon", name = coreName })
			-- dark cooled crust flecks
			B:block(bone, v(0.6 * s, 0.6 * s, 0.3 * s), C * CFrame.new(0.5 * s, -0.35 * s, -0.85 * s), RUST_DK)
			B:block(bone, v(0.3 * s, 0.55 * s, 0.6 * s), C * CFrame.new(0.88 * s, 0.3 * s, 0.3 * s), RUST_DK)
		end

		-- a full lily: petals on their own bones (prefix .. "O"/"I" .. n)
		local OUTER = { { 1.4, -34, 0.95 }, { 1.6, -16, 1.15 }, { 1.4, -20, 1.0 }, { 0.9, -26, 0.6 } }
		local INNER = { { 1.3, -16, 0.95 }, { 1.4, -12, 1.1 }, { 1.1, -20, 0.85 }, { 0.7, -26, 0.5 } }
		local function lily(prefix, parent, Fr, s, nOut, nIn, coreName, withStamens)
			local head = B:bone(prefix, parent, Fr)
			-- green-teal receptacle cup
			B:block(head, v(1.5 * s, 0.8 * s, 1.5 * s), Fr * CFrame.new(0, 0.1 * s, 0), TEAL_DK)
			B:block(head, v(1.1 * s, 0.6 * s, 1.1 * s), Fr * CFrame.new(0, -0.4 * s, 0) * ang(0, 45, 0), TEAL)
			for i = 0, nOut - 1 do
				local a = i * 360 / nOut
				local Pb = Fr * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.35 * s, -0.55 * s)
				local pb = B:bone(prefix .. "O" .. (i + 1), prefix, Pb)
				petal(pb, Pb, s, 1.6, OUTER, { PET_DK, PET, PET_MID, PET_TIP }, PET_LT)
			end
			for i = 0, nIn - 1 do
				local a = i * 360 / nIn + 180 / nIn
				local Pb = Fr * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.45 * s, -0.3 * s)
				local pb = B:bone(prefix .. "I" .. (i + 1), prefix, Pb)
				petal(pb, Pb, s * 0.85, 1.4, INNER, { PET, PET_MID, PET_LT, PET_TIP }, nil)
			end
			-- stamens: cream filaments with hot tips
			if withStamens then
				for i = 0, 5 do
					local a = i * 60 + 15
					local base = Fr * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.6 * s, -0.35 * s) * CFrame.Angles(rad(-22), 0, 0)
					B:block(head, v(0.16 * s, 2.0 * s, 0.16 * s), base * CFrame.new(0, 1.0 * s, 0), BONE)
					B:block(head, v(0.42 * s, 0.24 * s, 0.24 * s), base * CFrame.new(0, 2.05 * s, 0), (i % 2 == 0) and LAVA_HOT or LAVA_LT, NEON)
				end
			end
			-- molten orb fruit in the heart
			orb(head, Fr * CFrame.new(0, 1.55 * s, 0), 1.15 * s, coreName)
			return head
		end

		------------------------------------------------------------------
		-- PLANT
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, PY, 0))

		-- strap leaves rising out of the lava (two segments each, tips rust)
		local function strap(deg, r0, h1, h2, lean, w)
			local p0 = pv(r0, deg, PY - 0.1)
			local p1 = pv(r0 + lean * 0.45, deg, PY + h1)
			local p2 = pv(r0 + lean, deg + 6, PY + h1 + h2)
			B:bar(crop, p0, p1, w, 0.6, TEAL_DK, { up = v(0, 1, 0) })
			B:bar(crop, p1 - (p1 - p0).Unit * 0.2, p2, w * 0.78, 0.5, TEAL, { up = v(0, 1, 0) })
			B:bar(crop, p0 + v(0, 0.3, 0), p1, w * 0.32, 0.8, TEAL_LT, { up = v(0, 1, 0) })
			local tip = p2 + (p2 - p1).Unit * 0.5
			B:bar(crop, p2 - (p2 - p1).Unit * 0.2, tip, w * 0.5, 0.42, RUST_LT, { up = v(0, 1, 0) })
		end
		strap(115, 1.0, 1.8, 1.6, 3.6, 1.6)
		strap(175, 1.0, 2.4, 2.0, 3.3, 1.65)
		strap(240, 1.0, 1.7, 1.5, 3.7, 1.55)
		strap(300, 1.0, 2.2, 1.8, 3.4, 1.6)
		strap(45, 1.0, 1.6, 1.4, 3.5, 1.5)

		-- stem helper (stepped bars + node collars)
		local function stem(bone, pts, w)
			for i = 1, #pts - 1 do
				B:bar(bone, pts[i], pts[i + 1], w, w, TEAL_DK)
				B:bar(bone, pts[i] + v(0.0, 0.0, 0.0), pts[i + 1], w * 0.45, w + 0.08, TEAL, { up = v(0, 0, 1) })
				if i > 1 then
					B:block(bone, v(w + 0.25, 0.35, w + 0.25), CFrame.new(pts[i]), TEAL_XD)
				end
			end
			B:block(bone, v(w + 0.6, 0.35, w + 0.6), CFrame.new(pts[1] + v(0, 0.1, 0)), TEAL_XD)
		end

		-- MAIN lily
		local mainStem = B:bone("Stem", "Crop", v(0.2, PY, 0.4))
		local MB = v(0.0, 14.0, -0.6)
		stem(mainStem, { v(0.2, PY - 0.1, 0.4), v(0.7, 6.0, 0.6), v(0.4, 10.5, 0.1), MB - v(0, 0.3, 0) }, 0.75)
		-- a leaf collar on the main stem
		for _, lf in { { 30, 7.2 }, { 210, 9.0 } } do
			local base = pv(0.3, lf[1], lf[2]) + v(0.55, 0, 0.35)
			local tip = base + (pv(1, lf[1], 0) * 2.6) + v(0, 1.4, 0)
			B:bar(mainStem, base, tip, 0.7, 0.26, TEAL, { up = v(0, 1, 0) })
			B:bar(mainStem, tip, tip + (tip - base).Unit * 0.7 + v(0, -0.25, 0), 0.4, 0.24, RUST_LT, { up = v(0, 1, 0) })
		end
		local mainFr = CFrame.new(MB) * CFrame.Angles(rad(-14), 0, rad(3))
		local bloom = lily("Bloom", "Stem", mainFr, 1.5, 6, 5, "BloomCore", true)

		-- side lily (front-left, shorter)
		local sideStem = B:bone("Stem2", "Crop", v(-1.2, PY, -0.6))
		local SB = v(-3.3, 8.3, -1.9)
		stem(sideStem, { v(-1.2, PY - 0.1, -0.6), v(-2.2, 4.6, -1.0), SB - v(0, 0.25, 0) }, 0.55)
		lily("Bloom2", "Stem2", CFrame.new(SB) * CFrame.Angles(rad(-18), rad(20), rad(22)), 1.0, 5, 4, "Bloom2Core", true)

		-- side lily (back-right, medium)
		local sideStem3 = B:bone("Stem3", "Crop", v(1.3, PY, 0.9))
		local TB = v(3.4, 10.6, 1.9)
		stem(sideStem3, { v(1.3, PY - 0.1, 0.9), v(2.5, 5.8, 1.4), TB - v(0, 0.25, 0) }, 0.6)
		lily("Bloom3", "Stem3", CFrame.new(TB) * CFrame.Angles(rad(-6), rad(-30), rad(-20)), 1.1, 5, 4, "Bloom3Core", false)

		------------------------------------------------------------------
		-- OBSIDIAN LILY PADS floating on the lava (own bones -> bob)
		------------------------------------------------------------------
		local function pad(name, x, z, s, a, bulb)
			local c = cf(x, PY + 0.12, z, 0, a, 0)
			local pb = B:bone(name, "Crop", c)
			B:block(pb, v(2.0 * s, 0.22, 1.4 * s), c, RUST_DK)
			B:block(pb, v(1.4 * s, 0.21, 2.0 * s), c, RUST_DK)
			B:block(pb, v(1.6 * s, 0.24, 1.6 * s), c * CFrame.new(0, 0.02, 0) * ang(0, 45, 0), RUST)
			B:block(pb, v(1.0 * s, 0.26, 1.0 * s), c * CFrame.new(0, 0.03, 0.1 * s), ROCK_DK)
			B:block(pb, v(0.55 * s, 0.24, 0.8 * s), c * CFrame.new(0, 0.03, -0.75 * s), LAVA, {}) -- notch glow
			B:block(pb, v(0.18, 0.24, 1.2 * s), c * CFrame.new(0.35 * s, 0.05, 0.2 * s) * ang(0, 25, 0), RUST)
			B:block(pb, v(0.18, 0.24, 1.0 * s), c * CFrame.new(-0.35 * s, 0.05, 0.25 * s) * ang(0, -25, 0), RUST)
			if bulb then
				local bc = c * CFrame.new(0.2 * s, 0.75 * s, 0.35 * s)
				orb(pb, bc, 0.75 * s, name .. "Core")
				-- teal leaf cap
				for k = 0, 3 do
					B:block(pb, v(0.3 * s, 0.18 * s, 0.75 * s), bc * CFrame.new(0, 0.85 * s, 0) * ang(0, k * 90 + 20, 0) * CFrame.new(0, 0, -0.3 * s) * ang(-25, 0, 0), TEAL_LT)
				end
			end
			return pb
		end
		pad("Pad1", 2.7, -2.4, 1.4, -20, true)
		pad("Pad2", -2.9, -1.8, 1.3, 40, false)
		pad("Pad3", 2.8, 2.6, 1.1, 70, true)

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local poolZone = B:block(soil, v(6.5, 0.4, 6.5), cf(0, PY + 0.2, 0), LAVA, { tr = 1, name = "PoolZone" })
		B:emitter(poolZone, "bubble", { name = "LavaBubbles", color = { LAVA_HOT, LAVA_LT, LAVA }, rate = 5, size = { 0.3, 0.55, 0.2 }, life = { 0.6, 1.1 }, speed = { 0.3, 0.8 }, accel = { 0, 1.0, 0 }, trans = { 0.05, 0.1, 1 }, light = 1 })
		B:emitter(poolZone, "ember", { name = "LavaEmbers", color = { LAVA_HOT, LAVA_LT, LAVA_DK }, rate = 7, size = { 0.3, 0.22, 0 }, life = { 1.6, 2.8 }, speed = { 1.0, 2.2 }, spread = 25, accel = { 0.2, 1.6, 0 }, light = 1 })
		B:emitter(poolZone, "burst", { name = "PopSplash", color = { LAVA_HOT, LAVA_LT, LAVA }, size = { 0.6, 0.4, 0 }, speed = { 4, 8 }, life = { 0.5, 0.9 }, spread = 40, accel = { 0, -14, 0 }, drag = 1, light = 1 })
		local bloomFx = B:block(bloom, v(4, 1.2, 4), mainFr * CFrame.new(0, 1.6, 0), LAVA, { tr = 1, name = "BloomFx" })
		B:emitter(bloomFx, "sparkle", { name = "BloomSparkles", color = { "#ffffff", LAVA_HOT, PET_LT }, rate = 7, size = { 0.2, 0.6, 0 }, life = { 0.8, 1.5 }, speed = { 0.4, 1.4 }, light = 1 })
		B:emitter(bloomFx, "ember", { name = "BloomBurst", color = { LAVA_HOT, LAVA_LT, PET }, rate = 0, size = { 0.45, 0.3, 0 }, life = { 1.2, 2.0 }, speed = { 3, 7 }, spread = 55, accel = { 0, 1.5, 0 }, light = 1 })
		B:emitter(bloomFx, "glow", { name = "BloomGlow", color = { LAVA_HOT, LAVA_LT }, rate = 1.5, size = { 2.2, 3.4, 1.5 }, trans = { 0.8, 0.7, 1 }, light = 1 })
		local poolLight = B:block(soil, v(0.4, 0.4, 0.4), cf(0, PY + 0.8, 0), LAVA, { tr = 1, name = "PoolLightCore" })
		B:light(poolLight, { name = "PoolLight", color = "#ff7a2a", brightness = 1.3, range = 14 })
		local bloomLight = B:block(bloom, v(0.4, 0.4, 0.4), mainFr * CFrame.new(0, 1.6, 0), LAVA, { tr = 1, name = "BloomLightCore" })
		B:light(bloomLight, { name = "BloomLight", color = "#ffb24a", brightness = 1.0, range = 12 })
	end,
}
