--!nocheck
-- Volcano Melon (Magma crop #3, Mythic).
-- A charred melon vine climbing out of a lava-pool mound, bearing three
-- melon-sized MINI VOLCANOES.
-- * mound (bone "Soil", parts "Soil"): obsidian / basalt steps, lava cracks,
--   ember rocks, obsidian shards; a rocky rim holds a bubbling LAVA POOL
--   (bone "Pool") with neon ripple rings (Rip<ring>_<i>)
-- * the vine: VineA (base) -> VineB (top) + VineC (side branch) and a ground
--   runner (bone "Runner"), dark crust with a glowing lava seam running up it
--   (VineGlow1..N), broad charred melon leaves (LeafN bones) with orange veins
-- * three mini volcano melons (MelonN bones): stepped crust gourds with melon
--   ribs, glowing seams (SeamN_k), a jagged crater rim, a neon crater core
--   (CraterN) and lava overflow streams (FlowN_k)
-- * six lava blobs (BlobN_k bones) hide in the craters and are flung out on
--   each eruption (with trails)
-- VFX: three crater smoke emitters, three lava-spatter eruption bursts, pool
-- embers, lava drips; pool + three melon lights; six blob trails.
return {
	DisplayName = "Volcano Melon",
	Rarity = "Mythic",
	Element = "Fire",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ------------------------------------------------------------
		local OBS_XD, OBS, BAS, BAS_LT = "#1f191b", "#2b2326", "#3a2f31", "#4a3c3c"
		local CRUST, CRUST_DK, CRUST_LT = "#5a2a1f", "#3a1f1a", "#7a3a24"
		local LAVA, LAVA_LT, LAVA_HOT = "#ff7a1a", "#ffa62a", "#ffd34a"
		local GLOW, GLOW_HOT = "#ff6a1f", "#ffb12a"
		local SHEEN = "#66557a"
		local MEL, RIB = "#ff8c22", "#3a1f1a"
		local LEAF_DK, LEAF, LEAF_LT = "#6a1d16", "#9c281c", "#c23c22"

		local seed = 1003
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
		local function dir(deg)
			local a = rad(deg)
			return v(math.sin(a), 0, -math.cos(a))
		end
		local function pv(r, deg, y)
			return dir(deg) * r + v(0, y, 0)
		end
		local function facing(p, deg)
			return CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
		end
		local function oct(bone, C, w, h, col, o)
			B:block(bone, v(w, h, 0.58 * w), C, col, o)
			B:block(bone, v(0.58 * w, h - 0.02, w), C, col, o)
			B:block(bone, v(0.86 * w, h - 0.04, 0.86 * w), C, col, o)
		end

		------------------------------------------------------------------
		-- BASALT MOUND (bone "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local SN = { name = "Soil", mat = "Neon" }
		local function edge(y0, h, r, n, cols, eh)
			for i = 0, n - 1 do
				local a = (i + jit(0.2)) / n * 360
				local hh = h + rnd() * eh - 0.05
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + hh / 2, -(r + jit(0.15)))
				B:block(soil, v(1.6 + rnd() * 0.9, hh, 1.2 + rnd() * 0.5), p * ang(jit(4), jit(10), jit(4)), pick(cols), S)
			end
		end
		oct(soil, cf(0, 0.4, 0), 14.2, 0.8, OBS_XD, S)
		edge(0, 0.8, 7.15, 16, { OBS, BAS, OBS_XD, OBS }, 0.45)
		oct(soil, cf(0, 1.15, 0), 11.8, 0.7, OBS, S)
		edge(0.8, 0.7, 5.95, 13, { BAS, BAS_LT, OBS, BAS }, 0.35)
		local GY = 1.5

		local function crack(deg, r0, r1, y, wig)
			local a0 = pv(r0, deg, y)
			local mid = pv((r0 + r1) / 2, deg + wig, y)
			local a1 = pv(r1, deg - wig * 0.4, y)
			B:bar(soil, a0, mid, 0.44, 0.1, CRUST_DK, S)
			B:bar(soil, mid, a1, 0.44, 0.1, CRUST_DK, S)
			B:bar(soil, a0 + v(0, 0.02, 0), mid + v(0, 0.02, 0), 0.22, 0.14, GLOW_HOT, SN)
			B:bar(soil, mid + v(0, 0.02, 0), a1 + v(0, 0.02, 0), 0.22, 0.14, GLOW, SN)
		end
		crack(-40, 6.0, 7.3, 0.81, 8)
		crack(40, 6.0, 7.3, 0.81, -9)
		crack(130, 6.0, 7.3, 0.81, 7)
		crack(215, 6.0, 7.3, 0.81, -8)
		crack(290, 6.0, 7.3, 0.81, 6)
		crack(100, 3.0, 5.6, GY + 0.01, 10)
		crack(160, 3.2, 5.5, GY + 0.01, -8)

		local function emberRock(p, s, deg)
			local C = CFrame.new(p) * CFrame.Angles(rad(jit(10)), rad(deg), rad(jit(10)))
			B:block(soil, v(1.1 * s, 0.8 * s, 1.0 * s), C, CRUST, S)
			B:block(soil, v(0.8 * s, 0.35 * s, 0.75 * s), C * CFrame.new(0, 0.4 * s, 0), LAVA, S)
			B:block(soil, v(0.4 * s, 0.16, 0.4 * s), C * CFrame.new(0.05, 0.6 * s, 0), GLOW_HOT, SN)
		end
		emberRock(v(-6.0, 1.0, 1.6), 1.0, 20)
		emberRock(v(5.6, 0.95, 3.4), 0.95, -30)
		emberRock(v(-4.4, GY + 0.3, 3.2), 0.8, 45)
		local function shard(p, h, tilt, deg)
			local C = CFrame.new(p) * CFrame.Angles(0, rad(deg), 0) * CFrame.Angles(rad(tilt), 0, 0)
			B:block(soil, v(0.9, h, 0.9), C * CFrame.new(0, h / 2 - 0.2, 0) * ang(0, 45, 0), "#1d171f", S)
			B:block(soil, v(0.55, h * 0.45, 0.55), C * CFrame.new(0, h + 0.05 - 0.2, 0) * ang(0, 45, 0), "#2e2430", S)
			B:block(soil, v(0.18, h * 0.7, 0.3), C * CFrame.new(0.3, h * 0.5 - 0.2, -0.3) * ang(0, 45, 0), SHEEN, S)
		end
		shard(v(-6.3, 0.8, -2.0), 2.2, 18, -70)
		shard(v(-5.6, 0.8, -3.3), 1.4, 26, -40)
		shard(v(4.6, GY - 0.1, 4.0), 1.8, 20, 150)
		for _, s in { { 6.2, 1.0, -0.6, 1.2, 25, BAS_LT }, { 1.0, 1.0, 6.4, 1.1, -20, BAS }, { -2.4, GY + 0.3, 4.6, 0.9, 10, OBS } } do
			B:block(soil, v(s[4] * 1.3, s[4] * 1.1, s[4]), cf(s[1], s[2], s[3], jit(8), s[5], jit(8)), s[6], S)
		end

		------------------------------------------------------------------
		-- LAVA POOL (bone "Pool") with a rocky rim
		------------------------------------------------------------------
		local PC = v(-1.6, GY, -1.8)
		for i = 0, 11 do
			local a = i * 30 + jit(6)
			local h = 0.55 + rnd() * 0.35
			local p = PC + dir(a) * (2.95 + jit(0.12)) + v(0, h / 2 - 0.05, 0)
			B:block(soil, v(1.5, h, 1.0), facing(p, a) * ang(-12 + jit(6), jit(10), 0), pick({ BAS, BAS_LT, OBS, CRUST_DK }), S)
		end
		local pool = B:bone("Pool", "Soil", PC)
		oct(pool, CFrame.new(PC + v(0, 0.12, 0)), 5.6, 0.24, LAVA)
		oct(pool, CFrame.new(PC + v(0, 0.18, 0)) * ang(0, 22, 0), 3.6, 0.24, LAVA_LT)
		B:block(pool, v(1.2, 0.26, 1.2), CFrame.new(PC + v(0, 0.22, 0)) * ang(0, 45, 0), GLOW_HOT, { mat = "Neon", name = "PoolCore" })
		local RINGS = { { 0.95, 4, 0.6 }, { 1.7, 6, 0.75 }, { 2.4, 8, 0.85 } }
		for ri, rg in RINGS do
			for i = 0, rg[2] - 1 do
				local a = (i + 0.5 * (ri % 2)) * 360 / rg[2]
				local p = PC + dir(a) * rg[1] + v(0, 0.33, 0)
				local len = 2 * math.pi * rg[1] / rg[2] * rg[3]
				B:block(pool, v(len, 0.08, 0.2), facing(p, a), GLOW_HOT, { mat = "Neon", name = "Rip" .. ri .. "_" .. (i + 1) })
			end
		end
		-- crusty floating bits
		for ci, b in { { 1.3, 40, 0.8 }, { 2.0, 200, 0.6 }, { 1.0, 290, 0.5 } } do
			local cb = B:bone("Crust" .. ci, "Pool", PC)
			B:block(cb, v(b[3] * 1.4, 0.25, b[3]), facing(PC + dir(b[2]) * b[1] + v(0, 0.32, 0), b[2] + 30), CRUST_DK)
		end
		-- lava bubbles that swell up out of the pool and sink back
		for bi, b in { { 0.6, 120, 0.7 }, { 1.6, 330, 0.55 }, { 1.9, 250, 0.6 } } do
			local p = PC + dir(b[2]) * b[1] + v(0, 0.05, 0)
			local bb = B:bone("Bubble" .. bi, "Pool", p)
			B:block(bb, v(b[3], b[3], b[3]), CFrame.new(p) * ang(0, 30 * bi, 0), LAVA_LT)
			B:block(bb, v(b[3] * 0.55, b[3] * 0.4, b[3] * 0.55), CFrame.new(p + v(0, b[3] * 0.4, 0)) * ang(0, 30 * bi, 0), LAVA_HOT)
		end

		------------------------------------------------------------------
		-- VINE
		------------------------------------------------------------------
		local VB = v(2.4, GY, 2.0)
		local MAIN = { VB - v(0, 0.1, 0), v(2.9, 4.4, 1.7), v(2.1, 7.4, 2.1), v(0.9, 9.9, 1.9), v(0.2, 12.0, 1.2), v(0.0, 12.9, 0.8) }
		local SPLIT = 3
		B:bone("VineA", "Root", VB)
		B:bone("VineB", "VineA", MAIN[SPLIT])
		B:bone("VineC", "VineA", MAIN[SPLIT])
		local BRANCH = { MAIN[SPLIT], v(0.4, 8.6, 1.5), v(-1.8, 8.9, 0.4), v(-3.3, 8.7, -0.4) }
		B:bone("Runner", "Root", VB)
		local RUN = { VB + v(0, 0.2, 0), v(3.7, GY + 0.35, 1.2), v(4.3, GY + 0.35, 0.0), v(4.1, GY + 0.4, -0.9) }
		local glowN = 0
		local function vinePath(bone, pts, w0, w1, glow)
			for i = 1, #pts - 1 do
				local w = w0 + (w1 - w0) * (i - 1) / math.max(1, #pts - 2)
				local a, b = pts[i], pts[i + 1]
				B:bar(bone, a, b + (b - a).Unit * 0.3, w, w, (i % 2 == 1) and CRUST or CRUST_DK)
				if glow then
					glowN += 1
					local side = (b - a):Cross(v(0, 1, 0))
					side = (side.Magnitude > 0.01) and side.Unit or v(1, 0, 0)
					local off = v(0, 0, -1) * (w * 0.48) + side * 0.12
					B:bar(bone, a + off + (b - a).Unit * 0.2, b + off - (b - a).Unit * 0.1, 0.32, 0.24, (glowN % 2 == 0) and GLOW_HOT or GLOW, { mat = "Neon", name = "VineGlow" .. glowN })
				end
			end
		end
		local function bone4(i)
			return (i >= SPLIT) and "VineB" or "VineA"
		end
		-- main vine parts on VineA / VineB
		for i = 1, #MAIN - 1 do
			vinePath(bone4(i), { MAIN[i], MAIN[i + 1] }, 2.0 - i * 0.18, 2.0 - i * 0.18, true)
		end
		vinePath("VineC", BRANCH, 1.25, 1.0, true)
		vinePath("Runner", RUN, 0.9, 0.75, false)
		-- root flares
		for i = 0, 3 do
			local a = i * 90 + 20
			B:bar("VineA", VB + v(0, 1.0, 0) + dir(a) * 0.5, VB + dir(a + 8) * 1.8 - v(0, 0.05, 0), 0.7, 0.55, (i % 2 == 0) and CRUST_DK or CRUST, { up = v(0, 1, 0) })
		end
		-- curly tendrils
		local function tendril(bone, p, deg)
			local d = dir(deg)
			local p1 = p + d * 0.9 + v(0, 0.6, 0)
			local p2 = p1 + d * 0.5 + v(0, 0.6, 0)
			local p3 = p2 - d * 0.5 + v(0, 0.3, 0)
			B:bar(bone, p, p1, 0.25, 0.25, CRUST_LT)
			B:bar(bone, p1, p2, 0.22, 0.22, CRUST_LT)
			B:bar(bone, p2, p3, 0.2, 0.2, LAVA)
		end
		tendril("VineA", v(2.8, 3.6, 1.7), 80)
		tendril("VineB", v(1.4, 9.3, 2.0), 160)
		tendril("VineC", v(-1.0, 8.8, 0.9), 200)

		------------------------------------------------------------------
		-- BROAD CHARRED MELON LEAVES (own bones)
		------------------------------------------------------------------
		local leafN = 0
		local function leaf(parent, base, deg, pitch, s)
			leafN += 1
			local lb = B:bone("Leaf" .. leafN, parent, base)
			local F = facing(base, deg) * CFrame.Angles(rad(pitch), 0, 0)
			local function at(x, y, z)
				return F * CFrame.new(x * s, y * s, z * s)
			end
			B:bar(lb, base, at(0, 0, -1.2).Position, 0.45, 0.45, CRUST_DK)
			B:block(lb, v(2.4 * s, 0.45, 2.0 * s), at(0, 0, -2.3), (leafN % 2 == 0) and LEAF or LEAF_DK)
			B:block(lb, v(1.6 * s, 0.42, 1.3 * s), at(1.0, -0.1, -2.0) * ang(0, -25, -12), LEAF_LT)
			B:block(lb, v(1.6 * s, 0.42, 1.3 * s), at(-1.0, -0.1, -2.0) * ang(0, 25, 12), LEAF_LT)
			B:block(lb, v(1.3 * s, 0.45, 0.9 * s), at(0, -0.05, -3.4) * ang(-10, 0, 0), LEAF)
			B:block(lb, v(0.3 * s, 0.5, 2.6 * s), at(0, 0.03, -2.4), LAVA)
			B:block(lb, v(0.5 * s, 0.5, 0.5 * s), at(0, -0.1, -3.85), LAVA_LT)
		end
		leaf("VineA", v(2.6, 3.0, 1.6), 250, -8, 1.5)
		leaf("VineA", v(2.9, 5.4, 1.8), 110, -30, 1.45)
		leaf("VineA", v(2.6, 6.4, 2.2), 20, -26, 1.3)
		leaf("VineB", v(1.6, 9.0, 2.1), 40, -28, 1.35)
		leaf("VineB", v(1.2, 10.6, 2.0), 150, -30, 1.25)
		leaf("VineB", v(0.4, 12.0, 1.2), 250, -26, 1.2)
		leaf("VineC", v(-1.6, 8.8, 0.5), 330, -28, 1.2)
		leaf("Runner", v(4.1, GY + 0.4, 0.6), 60, -4, 1.0)
		leaf("Runner", v(3.2, GY + 0.4, 1.6), 170, -4, 0.95)

		------------------------------------------------------------------
		-- MINI VOLCANO MELONS
		------------------------------------------------------------------
		local melonTops = {}
		local function melon(idx, parent, base, s, yaw)
			local mb = B:bone("Melon" .. idx, parent, base)
			local F = CFrame.new(base) * CFrame.Angles(0, rad(yaw), 0)
			local function at(x, y, z)
				return F * CFrame.new(x * s, y * s, z * s)
			end
			-- leaf collar holding it (rides the vine, not the melon)
			for k = 0, 3 do
				local C = at(0, 0.15, 0) * ang(0, k * 90 + 45, 0)
				B:block(parent, v(1.2 * s, 0.3, 2.2 * s), C * CFrame.new(0, 0, -1.3 * s) * ang(-14, 0, 0), (k % 2 == 0) and LEAF or LEAF_DK)
				B:block(parent, v(0.5 * s, 0.32, 0.6 * s), C * CFrame.new(0, 0.05, -2.3 * s) * ang(-14, 0, 0), LAVA)
			end
			local T = {
				-- y centre, width, height, colour
				{ 0.55, 3.4, 1.1, CRUST },
				{ 1.55, 3.95, 1.0, LAVA },
				{ 2.45, 3.3, 0.9, MEL },
				{ 3.3, 2.45, 0.9, BAS },
				{ 4.05, 1.85, 0.7, OBS },
			}
			for _, tr in T do
				oct(mb, at(0, tr[1], 0), tr[2] * s, tr[3] * s, tr[4])
			end
			-- melon ribs + glowing seams between them
			local seamK = 0
			for k = 0, 7 do
				local a = k * 45 + 22.5
				local function sp(r, y)
					return (at(0, y, 0) * CFrame.Angles(0, -rad(a), 0) * CFrame.new(0, 0, -r * s)).Position
				end
				if k % 2 == 0 then
					B:bar(mb, sp(1.78, 0.6), sp(1.98, 1.6), 0.8 * s, 0.3, RIB)
					B:bar(mb, sp(1.98, 1.6), sp(1.66, 2.85), 0.7 * s, 0.3, RIB)
				else
					seamK += 1
					B:bar(mb, sp(1.76, 0.7), sp(1.98, 1.6), 0.95 * s, 0.26, CRUST)
					B:bar(mb, sp(1.98, 1.6), sp(1.64, 2.8), 0.85 * s, 0.26, CRUST)
					B:bar(mb, sp(2.03, 1.1), sp(1.82, 2.5), 0.28 * s, 0.2, GLOW_HOT, { mat = "Neon", name = "Seam" .. idx .. "_" .. seamK })
				end
			end
			-- jagged crater rim
			for k = 0, 7 do
				local a = k * 45 + jit(6)
				local h = (0.55 + rnd() * 0.3)
				local C = at(0, 4.5, 0) * CFrame.Angles(0, -rad(a), 0) * CFrame.new(0, 0, -1.1 * s) * ang(38 + jit(6), 0, 0)
				B:block(mb, v(0.95 * s, h * s, 0.55 * s), C, pick({ BAS, OBS, CRUST_DK, BAS_LT, CRUST }))
			end
			-- bubbling lava dome welling over the crater
			B:block(mb, v(1.75 * s, 0.5 * s, 1.75 * s), at(0, 4.6, 0), LAVA)
			B:block(mb, v(1.3 * s, 0.5 * s, 1.3 * s), at(0, 4.85, 0) * ang(0, 45, 0), LAVA_LT)
			B:block(mb, v(0.85 * s, 0.4 * s, 0.85 * s), at(0, 5.05, 0), GLOW_HOT, { mat = "Neon", name = "Crater" .. idx })
			-- lava overflow streams
			for k, a in { 70, 250 } do
				local function sp(r, y)
					return (at(0, y, 0) * CFrame.Angles(0, -rad(a), 0) * CFrame.new(0, 0, -r * s)).Position
				end
				B:bar(mb, sp(0.95, 4.8), sp(1.3, 3.85), 0.8 * s, 0.4, LAVA_LT)
				B:bar(mb, sp(1.3, 3.85), sp(1.72, 2.6), 0.7 * s, 0.4, LAVA)
				B:bar(mb, sp(1.1, 4.7), sp(1.8, 2.7), 0.26 * s, 0.3, GLOW_HOT, { mat = "Neon", name = "Flow" .. idx .. "_" .. k })
			end
			-- lava blobs hidden in the crater
			for k = 1, 2 do
				local p = at((k == 1) and 0.25 or -0.25, 4.05, (k == 1) and -0.15 or 0.2).Position
				local bb = B:bone("Blob" .. idx .. "_" .. k, "Melon" .. idx, p)
				B:block(bb, v(0.85 * s, 0.85 * s, 0.85 * s), CFrame.new(p) * ang(15, 30 * k, 10), LAVA_LT)
				B:block(bb, v(0.5 * s, 0.5 * s, 0.5 * s), CFrame.new(p + v(0, 0.22 * s, 0)) * ang(15, 30 * k, 10), GLOW_HOT, { mat = "Neon", name = "BlobGlow" .. idx .. "_" .. k })
				B:trail(bb, p + v(-0.3 * s, 0, 0), p + v(0.3 * s, 0, 0), { name = "BlobTrail" .. idx .. "_" .. k, color = { LAVA_HOT, GLOW, "#c8361a" }, life = 0.35, width = { 1, 0 }, trans = { 0.15, 1 } })
			end
			melonTops[idx] = at(0, 5.1, 0).Position
			return mb
		end
		melon(1, "Runner", v(3.9, GY + 0.15, -1.5), 1.05, 15)
		melon(2, "VineC", BRANCH[#BRANCH] + v(-0.2, 0.25, -0.1), 1.2, -20)
		melon(3, "VineB", MAIN[#MAIN] + v(0, 0.1, 0), 1.45, 10)

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		for i = 1, 3 do
			local top = melonTops[i]
			local fx = B:block("Melon" .. i, v(1.0, 0.5, 1.0), CFrame.new(top + v(0, 0.3, 0)), LAVA, { tr = 1, name = "CraterFx" .. i })
			B:emitter(fx, "smoke", { name = "Smoke" .. i, color = { "#857c77", "#5c5451", "#a0978f" }, rate = (i == 3) and 1.6 or 1.0, size = { 0.8, 2.0, 3.2 }, trans = { 0.5, 0.68, 1 }, life = { 2.0, 3.0 }, speed = { 1.0, 2.0 }, spread = 14, accel = { 0.3, 0.5, 0 } })
			B:emitter(fx, "burst", { name = "Erupt" .. i, tex = "fire", color = { "#fff2b0", LAVA_HOT, GLOW, "#c8361a" }, size = { 0.9, 0.7, 0 }, speed = { 8, 15 }, life = { 0.7, 1.3 }, spread = 28, accel = { 0, -14, 0 }, drag = 0.6, light = 1 })
			B:light(fx, { name = "MelonLight" .. i, color = "#ff8a2a", brightness = 0.6, range = (i == 3) and 13 or 10 })
		end
		local poolFx = B:block(pool, v(4.4, 0.3, 4.4), CFrame.new(PC + v(0, 0.4, 0)), LAVA, { tr = 1, name = "PoolFx" })
		B:emitter(poolFx, "ember", { name = "PoolEmbers", color = { LAVA_HOT, GLOW, "#c8361a" }, rate = 9, size = { 0.36, 0.26, 0 }, life = { 1.6, 2.6 }, speed = { 1.0, 2.4 }, spread = 25, accel = { 0, 2.0, 0 }, light = 1 })
		B:light(poolFx, { name = "PoolLight", color = "#ff6a1f", brightness = 1.0, range = 12 })
		-- lava drips from Melon3's overflow streams
		-- Melon2 pours a lava stream down its side and drips it into the pool
		local m2 = BRANCH[#BRANCH] + v(-0.2, 0.25, -0.1)
		local pd = ((PC - m2) * v(1, 0, 1)).Unit
		local q0, q1, q2 = m2 + pd * 1.2 + v(0, 5.7, 0), m2 + pd * 2.45 + v(0, 2.0, 0), m2 + pd * 2.05 + v(0, 0.2, 0)
		B:bar("Melon2", q0, q1, 0.8, 0.45, LAVA_LT)
		B:bar("Melon2", q1, q2, 0.7, 0.45, LAVA)
		B:bar("Melon2", q0 + pd * 0.15, q1 + pd * 0.15, 0.3, 0.3, GLOW_HOT, { mat = "Neon", name = "Pour1" })
		B:bar("Melon2", q1 + pd * 0.12, q2 + pd * 0.12, 0.28, 0.3, GLOW_HOT, { mat = "Neon", name = "Pour2" })
		local dfx = B:block("Melon2", v(0.4, 0.3, 0.4), CFrame.new(q2 - v(0, 0.2, 0)), LAVA, { tr = 1, name = "DripFx" })
		B:emitter(dfx, "drip", { name = "LavaDrip", color = { LAVA_HOT, LAVA, "#c8361a" }, rate = 3.0, size = { 0.42, 0.34, 0.16 }, life = { 0.55, 0.7 }, light = 0.8 })
	end,
}
