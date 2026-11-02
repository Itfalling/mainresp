--!nocheck
-- Inferno Lotus (Magma crop #4, Divine).
-- * a stepped black-obsidian / basalt mound (bone "Soil", parts "Soil") with
--   glowing lava cracks and ember rocks, crowned by a LAVA POOL whose hot
--   ripple rings pulse outward (RipK_I) and crust lily pads float
-- * two big cooled-crust lotus LEAVES on stalks (Leaf1/Leaf2) with glowing veins
-- * a thick crust STEM (bone "Stem") with three open lava CHANNELS; the hot
--   bands inside sit on bone "StemFlow" that slides down whole band spacings
--   per loop, so lava visibly pours down the stem into the pool
-- * a huge FLAME-PETAL LOTUS (bone "Bloom"): 8 outer + 8 middle + 6 inner
--   stepped crust petals with neon edges, each on its own bone so the bloom
--   opens and closes; a ring of bone-cream stamens with hot tips
-- * a MOLTEN LOTUS SEED-POD core (bone "Core") with glowing seeds that rises
--   out of the bloom on the beat
-- * a hidden RING OF FIRE (bone "FireRing") that flares up on full bloom
-- * four ember ORBS orbit the bloom on fiery trails (Orb1..4)
-- Blocks only.
return {
	DisplayName = "Inferno Lotus",
	Rarity = "Divine",
	Element = "Fire",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		local OBS_BK, BAS1, BAS2, BAS3, BAS_LT = "#1e1719", "#2b2326", "#3a2f31", "#4a3c3c", "#5e4c4a"
		local CRUST, CRUST_DK, CRUST_LT = "#5a2a1f", "#3a1f1a", "#7a3a24"
		local LAVA_DP, LAVA, LAVA_LT, LAVA_YL, LAVA_PALE = "#d9441a", "#ff7a1a", "#ffa62a", "#ffc23a", "#ffe58a"
		local N_OR, N_YL, N_HOT = "#ff7d1f", "#ffb12a", "#ffd34a"
		local BONE_LT, BONE = "#f3ead2", "#e2d6b5"

		local seed = 1004004
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
		-- MOUND
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
			{ 0.0, 1.1, 21.0, OBS_BK },
			{ 1.1, 2.3, 17.0, BAS1 },
			{ 2.3, 3.4, 13.4, BAS2 },
		}
		for _, t in TIERS do
			oct(t[1], t[2], t[3], t[4])
		end
		for i = 0, 9 do
			local t = TIERS[1]
			local a = i * 36 + 10 + jit(5)
			local r = edgeR(t[3], a) - 0.6 + jit(0.2)
			local x, z = polar(r, a)
			local h = (t[2] - t[1]) + 0.15 + rnd() * 0.3
			B:block(soil, v(2.4 + rnd() * 0.6, h, 1.6 + rnd() * 0.4), cf(x, t[1] + h / 2, z, 0, -a + jit(8), 0), ({ BAS3, BAS2, BAS_LT, BAS1 })[1 + i % 4], S)
		end
		local function crack(r0, r1, d, y, zig)
			local pts = {}
			for k = 0, 3 do
				local r = r0 + (r1 - r0) * k / 3
				table.insert(pts, at(r, d + ((k % 2 == 0) and -zig or zig), y))
			end
			for k = 1, 3 do
				B:bar(soil, pts[k], pts[k + 1], 0.55, 0.14, CRUST_DK, S)
				B:bar(soil, pts[k] + v(0, 0.05, 0), pts[k + 1] + v(0, 0.05, 0), 0.22, 0.14, (k == 2) and N_YL or N_OR, SN)
			end
		end
		crack(7.6, 9.8, 40, 1.12, 6)
		crack(7.6, 9.8, 200, 1.12, 6)
		crack(6.6, 8.2, 120, 2.32, 7)
		crack(6.6, 8.2, 300, 2.32, 7)
		for _, e in { { 9.2, 80, 1.1, 0.9 }, { 9.0, 250, 1.1, 0.8 }, { 7.6, 160, 2.3, 0.7 } } do
			local p = at(e[1], e[2], e[3])
			local s = e[4]
			B:block(soil, v(1.3 * s, 0.9 * s, 1.3 * s), CFrame.new(p + v(0, 0.4 * s, 0)) * ang(0, rnd() * 90, 8), BAS3, S)
			B:block(soil, v(0.8 * s, 0.25, 0.8 * s), CFrame.new(p + v(0, 0.9 * s, 0)) * ang(0, rnd() * 90, 8), N_OR, SN)
		end

		-- LAVA POOL ---------------------------------------------------------
		local PY = 3.55
		B:block(soil, v(10.6, 0.5, 6.6), cf(0, PY - 0.2, 0), LAVA_DP, S)
		B:block(soil, v(6.6, 0.52, 10.6), cf(0, PY - 0.2, 0), LAVA_DP, S)
		B:block(soil, v(9.0, 0.54, 9.0), cf(0, PY - 0.19, 0), LAVA, S)
		for i = 0, 9 do
			local a = i * 36 + 18
			local r = 5.7 + jit(0.15)
			local h = 0.5 + rnd() * 0.45
			B:block(soil, v(2.0 + rnd() * 0.4, h, 1.3), facing(at(r, a, 3.4 + h / 2), a) * ang(jit(6), jit(8), jit(6)), ({ BAS3, OBS_BK, BAS2, BAS_LT })[1 + i % 4], S)
		end
		-- ripple rings (pulse outward)
		local RIP = { { 1.9, 4 }, { 3.0, 6 }, { 4.1, 8 } }
		for ri, rr in RIP do
			for i = 1, rr[2] do
				local a = (i - 0.5) * 360 / rr[2] + ri * 13
				local len = 2 * math.pi * rr[1] / rr[2] * 0.55
				B:block(soil, v(len, 0.12, 0.32), facing(at(rr[1], a, PY + 0.03), a), N_YL, nm(("Rip%d_%d"):format(ri, i)))
			end
		end
		-- crust lily pads floating on the lava
		for _, pd in { { 3.6, 70, 1.0 }, { 3.9, 215, 0.85 }, { 3.4, 300, 0.75 } } do
			local p = at(pd[2] and pd[1] or 0, pd[2], PY + 0.08)
			local s = pd[3]
			B:block(soil, v(2.2 * s, 0.2, 1.5 * s), CFrame.new(p) * ang(0, pd[2], 0), CRUST, S)
			B:block(soil, v(1.5 * s, 0.22, 2.2 * s), CFrame.new(p) * ang(0, pd[2], 0), CRUST_DK, S)
			B:block(soil, v(0.18, 0.24, 1.6 * s), CFrame.new(p) * ang(0, pd[2] + 40, 0), N_OR, SN)
		end

		------------------------------------------------------------------
		-- LOTUS LEAVES on stalks
		------------------------------------------------------------------
		for li, L in { { 125, 6.0, 5.6, 1.45 }, { 250, 5.4, 7.4, 1.25 } } do
			local d, r, y, s = L[1], L[2], L[3], L[4]
			local base = at(1.6, d, PY - 0.2)
			local leafBone = B:bone("Leaf" .. li, "Root", base)
			local top = at(r, d, y)
			B:bar(leafBone, base, at(r * 0.55, d, y * 0.7), 0.6, 0.6, CRUST)
			B:bar(leafBone, at(r * 0.55, d, y * 0.7), top, 0.5, 0.5, CRUST_LT)
			local F = facing(top + v(0, 0.2, 0), d) * ang(-10, 0, 0)
			B:block(leafBone, v(4.4 * s, 0.3, 2.8 * s), F, CRUST, {})
			B:block(leafBone, v(2.8 * s, 0.32, 4.4 * s), F, CRUST, {})
			B:block(leafBone, v(3.6 * s, 0.34, 3.6 * s), F * ang(0, 45, 0), CRUST_DK, {})
			B:block(leafBone, v(2.4 * s, 0.38, 2.4 * s), F * CFrame.new(0, 0.04, 0), CRUST_LT, {})
			for k = 1, 3 do
				local va = (k - 2) * 55
				B:block(leafBone, v(0.24, 0.2, 2.0 * s), F * ang(0, va, 0) * CFrame.new(0, 0.26, -1.0 * s), N_YL, nm(("LeafVein%d_%d"):format(li, k)))
			end
			-- curled hot rim
			B:block(leafBone, v(2.4 * s, 0.5, 0.4), F * CFrame.new(0, 0.2, -2.1 * s), LAVA_DP, {})
		end

		------------------------------------------------------------------
		-- two closed LOTUS BUDS on their own stalks (BudA / BudB)
		------------------------------------------------------------------
		for bi, Bd in { { 40, 5.2, 9.4, 1.45 }, { 300, 5.4, 7.6, 1.25 } } do
			local d, r, h, s = Bd[1], Bd[2], Bd[3], Bd[4]
			local base = at(1.3, d, PY - 0.2)
			local bud = B:bone("Bud" .. bi, "Root", base)
			local mid = at(r * 0.6, d, PY + (h - PY) * 0.55)
			local top = at(r, d, h)
			B:bar(bud, base, mid, 0.5, 0.5, CRUST)
			B:bar(bud, mid, top + v(0, 0.3, 0), 0.42, 0.42, CRUST_LT)
			local C = CFrame.new(top) * ang(0, -d, 0)
			B:block(bud, v(1.5 * s, 0.6 * s, 1.5 * s), C * CFrame.new(0, 0.2 * s, 0) * ang(0, 45, 0), CRUST)
			for k = 0, 3 do
				local Fk = C * ang(0, k * 90, 0) * CFrame.new(0, 0.3 * s, -0.42 * s) * ang(14, 0, 0)
				B:block(bud, v(1.0 * s, 2.3 * s, 0.45 * s), Fk * CFrame.new(0, 1.1 * s, 0), (k % 2 == 0) and LAVA_DP or LAVA)
				B:block(bud, v(0.7 * s, 0.9 * s, 0.14), Fk * CFrame.new(0, 0.55 * s, -0.27 * s), CRUST)
			end
			for k = 0, 3 do
				local Fk = C * ang(0, k * 90 + 45, 0) * CFrame.new(0, 0.3 * s, -0.25 * s) * ang(8, 0, 0)
				B:block(bud, v(0.8 * s, 2.7 * s, 0.4 * s), Fk * CFrame.new(0, 1.3 * s, 0), LAVA_LT)
			end
			B:block(bud, v(0.55 * s, 0.6 * s, 0.55 * s), C * CFrame.new(0, 2.85 * s, 0) * ang(0, 45, 0), N_HOT, nm("BudTip" .. bi))
		end

		------------------------------------------------------------------
		-- STEM with three flowing lava channels
		------------------------------------------------------------------
		local RY = 14.2 -- receptacle top
		local stem = B:bone("Stem", "Root", v(0, PY, 0))
		local SY0, SY1 = PY - 0.6, RY - 1.2
		B:block(stem, v(1.9, SY1 - SY0, 1.9), cf(0, (SY0 + SY1) / 2, 0), CRUST_DK)
		-- crust bark knots
		for i = 0, 4 do
			local y = PY + 1.5 + i * 2.3
			B:block(stem, v(2.2, 0.6, 2.2), cf(0, y, 0, 0, 60 + i * 20, 0), (i % 2 == 0) and CRUST or CRUST_LT)
		end
		local CH = { 0, 120, 240 }
		local FBS = 1.6 -- band spacing
		local flow = B:bone("StemFlow", "Stem", v(0, PY, 0))
		for ci, d in ipairs(CH) do
			local Fc = CFrame.Angles(0, -rad(d), 0)
			local len = SY1 - SY0
			local mid = (SY0 + SY1) / 2
			-- molten channel bed + crust rims
			B:block(stem, v(0.8, len, 0.3), Fc * CFrame.new(0, mid, -1.0), LAVA_DP)
			for _, sx in { -1, 1 } do
				B:block(stem, v(0.28, len - 0.2, 0.5), Fc * CFrame.new(sx * 0.55, mid, -1.05), CRUST)
			end
			-- sliding hot bands (enter from under the receptacle, sink into the pool)
			local j = 0
			local y = SY1 + 0.4
			while y > PY - 1.4 do
				j += 1
				B:block(flow, v(0.78, 0.7, 0.34), Fc * CFrame.new(0, y, -1.08), LAVA)
				B:block(flow, v(0.8, 0.62, 0.38), Fc * CFrame.new(0, y, -1.1), N_HOT, nm(("SBand%d_%d"):format(ci, j)))
				y -= FBS
			end
		end

		------------------------------------------------------------------
		-- THE BLOOM
		------------------------------------------------------------------
		local Fr = CFrame.new(0, RY, 0)
		local bloom = B:bone("Bloom", "Stem", Fr)
		-- receptacle (stepped crust cup, hides the channel tops)
		B:block(bloom, v(3.4, 1.3, 3.4), Fr * CFrame.new(0, -1.2, 0), CRUST_DK)
		B:block(bloom, v(4.6, 1.0, 4.6), Fr * CFrame.new(0, -0.4, 0) * ang(0, 45, 0), CRUST)
		B:block(bloom, v(5.2, 0.55, 5.2), Fr * CFrame.new(0, 0.05, 0), CRUST_LT)
		B:block(bloom, v(2.6, 0.6, 2.6), Fr * CFrame.new(0, -1.95, 0) * ang(0, 45, 0), CRUST_DK)

		local function petal(bone, Pb, s, w, segs, cols, back, edge)
			local F = Pb
			for k, sg in segs do
				F = F * CFrame.Angles(rad(sg[2]), 0, 0)
				local len = sg[1] * s
				local ww = w * sg[3] * s
				B:block(bone, v(ww, len + 0.12 * s, 0.42 * s), F * CFrame.new(0, len / 2, 0), cols[k])
				if back and k <= 2 then
					B:block(bone, v(ww * 0.78, len * 0.9, 0.14), F * CFrame.new(0, len / 2, -0.26 * s), back)
				end
				if edge and k == 2 then
					for i, sx in { -1, 1 } do
						B:block(bone, v(0.18, len * 1.05, 0.46 * s), F * CFrame.new(sx * (ww / 2 + 0.03), len / 2, 0), N_YL, nm(edge .. (i == 1 and "a" or "b")))
					end
				end
				F = F * CFrame.new(0, len, 0)
			end
		end
		local OUTER = { { 1.4, 0, 0.95 }, { 1.9, 6, 1.35 }, { 1.7, 8, 1.25 }, { 1.1, 14, 0.85 }, { 0.6, 18, 0.4 } }
		local MID = { { 1.3, 0, 0.9 }, { 1.7, 6, 1.3 }, { 1.5, 8, 1.2 }, { 1.0, 14, 0.8 }, { 0.5, 18, 0.38 } }
		local INNER = { { 1.2, 0, 0.9 }, { 1.4, 5, 1.1 }, { 1.2, 9, 0.85 }, { 0.6, 16, 0.4 } }
		for i = 1, 8 do
			local a = (i - 1) * 45 + 22.5
			local Pb = Fr * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.2, -2.2) * CFrame.Angles(rad(-62), 0, 0)
			local pb = B:bone("PetalO" .. i, "Bloom", Pb)
			petal(pb, Pb, 1.45, 1.75, OUTER, { CRUST_LT, LAVA_DP, LAVA, LAVA_LT, LAVA_YL }, CRUST, "EdgeO" .. i)
		end
		for i = 1, 8 do
			local a = (i - 1) * 45
			local Pb = Fr * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.5, -1.7) * CFrame.Angles(rad(-38), 0, 0)
			local pb = B:bone("PetalM" .. i, "Bloom", Pb)
			petal(pb, Pb, 1.35, 1.6, MID, { CRUST_LT, LAVA_DP, LAVA, LAVA_LT, LAVA_YL }, CRUST, "EdgeM" .. i)
		end
		for i = 1, 6 do
			local a = (i - 1) * 60 + 30
			local Pb = Fr * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.6, -1.2) * CFrame.Angles(rad(-16), 0, 0)
			local pb = B:bone("PetalI" .. i, "Bloom", Pb)
			petal(pb, Pb, 0.95, 1.6, INNER, { LAVA_DP, LAVA, LAVA_LT, LAVA_YL }, nil, nil)
		end
		-- stamens: bone-cream filaments with hot tips
		for i = 1, 8 do
			local a = i * 45 + 10
			local base = Fr * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.4, -1.3) * CFrame.Angles(rad(-20), 0, 0)
			B:block(bloom, v(0.2, 1.8, 0.2), base * CFrame.new(0, 0.9, 0), (i % 2 == 0) and BONE or BONE_LT)
			B:block(bloom, v(0.42, 0.3, 0.42), base * CFrame.new(0, 1.85, 0), N_HOT, nm("Stamen" .. i))
		end

		-- MOLTEN SEED-POD CORE (rises on the beat)
		local core = B:bone("Core", "Bloom", Fr * CFrame.new(0, 0.4, 0))
		local CF0 = Fr * CFrame.new(0, 2.3, 0)
		B:block(core, v(1.3, 2.0, 1.3), CF0 * CFrame.new(0, -1.2, 0) * ang(0, 45, 0), CRUST)
		B:block(core, v(1.9, 1.0, 1.9), CF0, LAVA_DP)
		B:block(core, v(2.3, 0.45, 2.3), CF0 * CFrame.new(0, 0.62, 0), LAVA)
		B:block(core, v(1.7, 0.3, 1.7), CF0 * CFrame.new(0, 0.9, 0) * ang(0, 45, 0), LAVA_LT)
		local SEEDS = { { 0, 0 }, { 0.62, 0 }, { -0.62, 0 }, { 0.31, 0.55 }, { -0.31, 0.55 }, { 0.31, -0.55 }, { -0.31, -0.55 } }
		for i, sd in SEEDS do
			B:block(core, v(0.34, 0.16, 0.34), CF0 * CFrame.new(sd[1], 1.08, sd[2]), N_HOT, nm("Seed" .. i))
		end

		-- RING OF FIRE (hidden flames that flare up on full bloom)
		local ring = B:bone("FireRing", "Bloom", Fr)
		for i = 1, 8 do
			local a = (i - 1) * 45
			local p = at(4.4, a, RY + 1.6)
			B:block(ring, v(0.95, 1.3, 0.95), CFrame.new(p) * ang(0, 45 - a, 0), LAVA_LT, { name = "FlameA" .. i, tr = 1 })
			B:block(ring, v(0.55, 1.1, 0.55), CFrame.new(p + v(0, 0.95, 0)) * ang(0, -a, 0), N_HOT, { mat = "Neon", name = "FlameB" .. i, tr = 1 })
		end

		-- EMBER ORBS orbiting the bloom
		for i = 1, 4 do
			local a = (i - 1) * 90 + 45
			local yo = (i % 2 == 0) and 6.4 or 5.2
			local ob = B:bone("Orb" .. i, "Root", v(0, RY + yo, 0))
			local p = at(5.6, a, RY + yo)
			B:block(ob, v(1.0, 1.0, 1.0), CFrame.new(p) * ang(45, 0, 45), LAVA)
			B:block(ob, v(0.75, 0.75, 0.75), CFrame.new(p) * ang(0, 45, 0), N_HOT, nm("OrbCore" .. i))
			B:block(ob, v(0.5, 0.5, 0.5), CFrame.new(p + v(0, 0.55, 0)) * ang(0, 20, 0), CRUST)
			B:trail(ob, p + v(0, 0.45, 0), p - v(0, 0.45, 0), { name = "OrbTrail" .. i, color = { N_HOT, N_OR, "#7a2a1a" }, life = 0.55, width = { 1, 0 }, trans = { 0.15, 1 } })
		end

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local cz = B:block(core, v(1.6, 1.0, 1.6), CF0 * CFrame.new(0, 0.6, 0), N_HOT, { tr = 1, name = "CoreZone" })
		B:emitter(cz, "ember", { name = "CoreEmbers", color = { N_HOT, N_OR, "#c2331a" }, rate = 6, size = { 0.3, 0.2, 0 }, life = { 1.4, 2.4 }, speed = { 1.2, 2.6 }, spread = 50, accel = { 0, 2, 0 } })
		B:emitter(cz, "burst", { name = "BloomBurst", color = { "#fff4c0", N_HOT, N_OR }, size = { 0.8, 0.5, 0 }, speed = { 10, 18 }, life = { 0.6, 1.1 } })
		B:emitter(cz, "sparkle", { name = "CoreSparkle", color = { "#fff4c0", N_HOT }, rate = 5, size = { 0.2, 0.5, 0 } })
		local rz = B:block(ring, v(9.0, 0.4, 9.0), Fr * CFrame.new(0, 1.6, 0), N_HOT, { tr = 1, name = "RingZone" })
		B:emitter(rz, "fire", { name = "RingFire", color = { "#fff0a0", N_HOT, N_OR, "#a02a10" }, rate = 60, size = { 1.4, 1.0, 0 }, life = { 0.5, 0.9 }, speed = { 3, 6 }, spread = 12, enabled = false })
		local dz = B:block(bloom, v(2.4, 0.3, 2.4), Fr * CFrame.new(0, -2.2, 0), N_HOT, { tr = 1, name = "DripZone" })
		B:emitter(dz, "drip", { name = "LavaDrip", color = { N_HOT, LAVA, "#c2331a" }, rate = 3, size = { 0.38, 0.32, 0.15 }, life = { 1.0, 1.4 } })
		local pz = B:block(soil, v(8, 0.4, 8), cf(0, PY + 0.2, 0), LAVA, { tr = 1, name = "PoolZone" })
		B:emitter(pz, "ember", { name = "PoolEmbers", color = { N_HOT, N_OR, "#c2331a" }, rate = 5, size = { 0.26, 0.16, 0 }, life = { 1.2, 2.2 }, speed = { 0.8, 2 }, spread = 25, accel = { 0, 1.6, 0 } })
		B:emitter(pz, "smoke", { name = "PoolSmoke", color = { "#4a403d", "#2b2526" }, rate = 1.2, size = { 1.2, 2.6, 3.6 }, life = { 2, 3 }, speed = { 0.8, 1.6 }, spread = 25, accel = { 0.2, 0.5, 0 } })
		B:light(cz, { name = "CoreLight", color = "#ff8a2a", brightness = 1.3, range = 18 })
		B:light(pz, { name = "PoolLight", color = "#ff6414", brightness = 1.1, range = 16 })
		local sl = B:block(stem, v(0.6, 0.6, 0.6), cf(0, PY + 6, 0), N_HOT, { tr = 1, name = "StemZone" })
		B:light(sl, { name = "StemLight", color = "#ff7a1a", brightness = 0.8, range = 12 })
	end,
}
