--!nocheck
-- Obsidian Corn (Magma crop #2, Legendary).
-- Three glossy obsidian corn stalks on a stepped basalt mound.
-- * mound (bone "Soil", parts "Soil"): obsidian / charcoal basalt steps,
--   glowing lava cracks, ember rocks, obsidian shards and a lava puddle
-- * stalks: StalkN (base) -> StalkNTop (upper half) bones, stacked obsidian
--   segments with a glossy sheen strip, basalt node rings and a glowing vein
-- * charred husk leaves (LeafN bones) arch out from the nodes: dark crust
--   blades with a lava-orange midrib and ember tips
-- * four big COBS (CobN bones) of glowing lava kernels: each kernel row has
--   one neon kernel (K<cob>_<row>) spiralling around the cob, so glow waves
--   can run up the cob; charred husk peels open at the base
-- * six hidden POPCORN kernels (PopN bones) sit inside the cob tips and fly
--   out on the pop beat (with trails)
-- * glowing ember tassels crown each stalk
-- VFX: smoke wisps, rising embers, heat sparkles, three pop-spark bursts,
-- kernel glow, three lights, six kernel trails.
return {
	DisplayName = "Obsidian Corn",
	Rarity = "Legendary",
	Element = "Fire",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ------------------------------------------------------------
		local OBS_XD, OBS, BAS, BAS_LT = "#1f191b", "#2b2326", "#3a2f31", "#4a3c3c"
		local STALK, STALK_DK, SHEEN = "#2e2430", "#1d171f", "#66557a"
		local CRUST, CRUST_DK = "#5a2a1f", "#3a1f1a"
		local LAVA, LAVA_LT, LAVA_HOT = "#ff7a1a", "#ffa62a", "#ffd34a"
		local GLOW, GLOW_HOT = "#ff6a1f", "#ffb12a"

		local seed = 1002
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
		disc(0, 0.8, 6.2, OBS_XD)
		edge(0, 0.8, 6.25, 14, { OBS, BAS, OBS_XD, OBS }, 0.45)
		disc(0.8, 0.7, 5.0, OBS)
		edge(0.8, 0.7, 5.05, 11, { BAS, BAS_LT, OBS, BAS }, 0.35)
		disc(1.5, 0.55, 3.7, BAS)
		edge(1.5, 0.55, 3.75, 8, { BAS, BAS_LT, BAS }, 0.3)
		local GY = 2.05

		local function crack(deg, r0, r1, y, wig)
			local a0 = pv(r0, deg, y)
			local mid = pv((r0 + r1) / 2, deg + wig, y)
			local a1 = pv(r1, deg - wig * 0.4, y)
			B:bar(soil, a0, mid, 0.44, 0.1, CRUST_DK, S)
			B:bar(soil, mid, a1, 0.44, 0.1, CRUST_DK, S)
			B:bar(soil, a0 + v(0, 0.02, 0), mid + v(0, 0.02, 0), 0.22, 0.14, GLOW_HOT, SN)
			B:bar(soil, mid + v(0, 0.02, 0), a1 + v(0, 0.02, 0), 0.22, 0.14, GLOW, SN)
		end
		crack(-30, 5.1, 6.4, 0.81, 8)
		crack(60, 5.1, 6.4, 0.81, -9)
		crack(150, 5.0, 6.3, 0.81, 7)
		crack(235, 5.1, 6.4, 0.81, -8)
		crack(15, 3.8, 4.9, 1.51, 9)
		crack(120, 3.8, 4.9, 1.51, -9)
		crack(255, 3.8, 4.9, 1.51, 8)

		local function emberRock(p, s, deg)
			local C = CFrame.new(p) * CFrame.Angles(rad(jit(10)), rad(deg), rad(jit(10)))
			B:block(soil, v(1.1 * s, 0.8 * s, 1.0 * s), C, CRUST, S)
			B:block(soil, v(0.8 * s, 0.35 * s, 0.75 * s), C * CFrame.new(0, 0.4 * s, 0), LAVA, S)
			B:block(soil, v(0.4 * s, 0.16, 0.4 * s), C * CFrame.new(0.05, 0.6 * s, 0), GLOW_HOT, SN)
		end
		emberRock(v(-5.3, 1.0, -2.6), 1.0, 20)
		emberRock(v(5.0, 0.95, 3.0), 0.95, -30)
		emberRock(v(-3.4, 1.8, 2.8), 0.75, 45)
		-- obsidian shards (glossy dark crystals)
		local function shard(p, h, tilt, deg)
			local C = CFrame.new(p) * CFrame.Angles(0, rad(deg), 0) * CFrame.Angles(rad(tilt), 0, 0)
			B:block(soil, v(0.9, h, 0.9), C * CFrame.new(0, h / 2 - 0.2, 0) * ang(0, 45, 0), STALK_DK, S)
			B:block(soil, v(0.55, h * 0.45, 0.55), C * CFrame.new(0, h + 0.05 - 0.2, 0) * ang(0, 45, 0), STALK, S)
			B:block(soil, v(0.18, h * 0.7, 0.3), C * CFrame.new(0.3, h * 0.5 - 0.2, -0.3) * ang(0, 45, 0), SHEEN, S)
		end
		shard(v(5.2, 0.8, -1.6), 2.0, 18, 70)
		shard(v(5.7, 0.8, -0.6), 1.3, 28, 100)
		shard(v(-5.0, 0.8, 2.4), 1.8, 20, -100)
		-- basalt boulders
		for _, s in { { 3.9, 1.0, -4.2, 1.1, 25, BAS_LT }, { -5.3, 1.0, 0.2, 1.1, -20, BAS }, { 2.6, 1.8, 3.1, 0.9, 10, OBS } } do
			B:block(soil, v(s[4] * 1.3, s[4] * 1.1, s[4]), cf(s[1], s[2], s[3], jit(8), s[5], jit(8)), s[6], S)
		end
		-- lava puddle (front)
		B:block(soil, v(2.6, 0.16, 1.7), cf(-0.4, GY + 0.04, -3.0, 0, 15, 0), CRUST_DK, S)
		B:block(soil, v(2.0, 0.18, 1.25), cf(-0.4, GY + 0.06, -3.0, 0, 15, 0), LAVA, S)
		B:block(soil, v(1.1, 0.2, 0.55), cf(-0.4, GY + 0.08, -3.0, 0, 15, 0), GLOW_HOT, { name = "Puddle", mat = "Neon" })

		------------------------------------------------------------------
		-- STALKS
		------------------------------------------------------------------
		local STALKS = {
			-- base, nodes (heights above GY), base width, split node
			{ v(0.3, GY, 1.0), { 0, 2.4, 4.8, 7.2, 9.4, 11.4, 13.1 }, 1.75, 4 },
			{ v(-2.6, GY, -1.0), { 0, 2.2, 4.4, 6.5, 8.4, 10.0 }, 1.5, 3 },
			{ v(2.7, GY, -1.1), { 0, 2.1, 4.1, 6.0, 7.7, 9.0 }, 1.45, 3 },
		}
		local tops = {}
		local function nodePos(si, k)
			local st = STALKS[si]
			local h = st[2][k]
			-- gentle lean outwards with height
			local lean = st[1] * v(1, 0, 1)
			lean = (lean.Magnitude > 0.1) and lean.Unit or v(0, 0, 0)
			return st[1] + v(0, h, 0) + lean * (h / 13) ^ 2 * 1.2
		end
		local function stalkBone(si, k)
			local st = STALKS[si]
			return (k >= st[4]) and ("Stalk" .. si .. "Top") or ("Stalk" .. si)
		end
		for si, st in STALKS do
			B:bone("Stalk" .. si, "Root", st[1])
			B:bone("Stalk" .. si .. "Top", "Stalk" .. si, nodePos(si, st[4]))
			local n = #st[2]
			for k = 1, n - 1 do
				local a, b = nodePos(si, k), nodePos(si, k + 1)
				local w = st[3] * (1 - 0.35 * (k - 1) / (n - 1))
				local bone = stalkBone(si, k)
				B:bar(bone, a, b + v(0, 0.1, 0), w, w, (k % 2 == 0) and STALK or STALK_DK)
				-- glossy sheen strip
				B:bar(bone, a + v(w * 0.42, 0.25, -w * 0.42), b + v(w * 0.42, -0.25, -w * 0.42), 0.22, 0.22, SHEEN)
				-- node ring
				B:block(bone, v(w + 0.4, 0.4, w + 0.4), CFrame.new(b) * ang(0, 45 * (k % 2), 0), BAS_LT)
			end
			B:block("Stalk" .. si, v(st[3] + 0.6, 0.5, st[3] + 0.6), CFrame.new(st[1] + v(0, 0.2, 0)), BAS_LT)
			-- glowing vein up the lower stalk
			local a, b = nodePos(si, 1), nodePos(si, 3)
			local off = v(-st[3] * 0.52, 0, -st[3] * 0.3)
			B:bar("Stalk" .. si, a + off + v(0, 0.5, 0), b + off * 0.85 - v(0, 0.4, 0), 0.18, 0.16, GLOW, { mat = "Neon", name = "Vein" .. si })
			tops[si] = nodePos(si, n)
		end

		------------------------------------------------------------------
		-- CHARRED HUSK LEAVES (own bones)
		------------------------------------------------------------------
		local LEAVES = {
			-- stalk, node, deg, length scale
			{ 1, 2, 250, 1.1 }, { 1, 3, 70, 1.05 }, { 1, 4, 160, 1.0 }, { 1, 5, 290, 0.9 }, { 1, 6, 20, 0.8 },
			{ 2, 2, 300, 1.0 }, { 2, 3, 190, 0.9 }, { 2, 4, 120, 0.8 },
			{ 3, 2, 60, 1.0 }, { 3, 3, 150, 0.9 }, { 3, 4, 220, 0.8 },
		}
		for li, lf in LEAVES do
			local base = nodePos(lf[1], lf[2]) + v(0, 0.1, 0)
			local lb = B:bone("Leaf" .. li, stalkBone(lf[1], lf[2]), base)
			local d = dir(lf[3])
			local s = lf[4]
			local pts = {
				base + d * 0.5,
				base + d * 1.7 * s + v(0, 1.6 * s, 0),
				base + d * 3.2 * s + v(0, 2.4 * s, 0),
				base + d * 4.5 * s + v(0, 2.2 * s, 0),
				base + d * 5.4 * s + v(0, 1.1 * s, 0),
			}
			local ws = { 1.5, 1.9, 1.6, 1.0 }
			local LC = { CRUST_DK, CRUST, "#8e3a1e", LAVA }
			local side = v(-d.Z, 0, d.X) * ((li % 2 == 0) and 1 or -1)
			local UP = { up = (v(0, 1, 0) + side * 0.9).Unit }
			for i = 1, #pts - 1 do
				B:bar(lb, pts[i], pts[i + 1] + (pts[i + 1] - pts[i]).Unit * 0.15, ws[i] * s + 0.1, 0.4, LC[i], UP)
				if i < #pts - 1 then
					B:bar(lb, pts[i] + v(0, 0.14, 0), pts[i + 1] + v(0, 0.14, 0), 0.26, 0.4, (i == 1) and LAVA or LAVA_LT, UP)
				end
			end
			B:bar(lb, pts[#pts - 1] + (pts[#pts] - pts[#pts - 1]) * 0.45, pts[#pts] + (pts[#pts] - pts[#pts - 1]).Unit * 0.3, 0.5, 0.44, LAVA_HOT, UP)
		end

		------------------------------------------------------------------
		-- LAVA COBS
		------------------------------------------------------------------
		local COBS = {
			-- stalk, node, deg (outward), tilt, scale
			{ 1, 4, 330, 24, 1.45 },
			{ 2, 3, 280, 26, 1.3 },
			{ 3, 3, 80, 26, 1.25 },
			{ 1, 6, 140, 22, 1.1 },
		}
		local cobTips = {}
		local cobFrames = {}
		local ROWS = 6
		for ci, cb in COBS do
			local s = cb[5]
			local anchor = nodePos(cb[1], cb[2]) + dir(cb[3]) * (STALKS[cb[1]][3] * 0.4) + v(0, 0.15, 0)
			local cob = B:bone("Cob" .. ci, stalkBone(cb[1], cb[2]), anchor)
			local F = facing(anchor, cb[3]) * CFrame.Angles(rad(-cb[4]), 0, 0)
			local function at(x, y, z)
				return F * CFrame.new(x * s, y * s, z * s)
			end
			-- stem stub + core
			B:block(cob, v(0.7 * s, 1.0 * s, 0.7 * s), at(0, 0.3, -0.45), CRUST_DK)
			local L = 3.8
			B:block(cob, v(1.15 * s, L * s, 1.15 * s), at(0, 0.8 + L / 2, -0.75), CRUST_DK)
			for r = 1, ROWS do
				local y = 0.8 + 0.3 + (r - 1) * (L - 0.6) / (ROWS - 1)
				local taper = (r >= ROWS - 1) and 0.78 or 1
				for f = 0, 3 do
					local K = at(0, y, -0.75) * ang(0, f * 90, 0) * CFrame.new(0, 0, -0.62 * s * taper)
					local hot = (f == (r % 4))
					local col = hot and GLOW_HOT or pick({ LAVA, LAVA_LT, LAVA, "#ff8f22" })
					B:block(cob, v(1.18 * s * taper, 0.5 * s, 0.42 * s), K, col, hot and { mat = "Neon", name = "K" .. ci .. "_" .. r } or nil)
				end
			end
			-- glowing tip
			B:block(cob, v(0.75 * s, 0.5 * s, 0.75 * s), at(0, 0.8 + L + 0.1, -0.75), LAVA_HOT)
			B:block(cob, v(0.4 * s, 0.35 * s, 0.4 * s), at(0, 0.8 + L + 0.45, -0.75), GLOW_HOT, { mat = "Neon", name = "CobTip" .. ci })
			-- charred husk peels open around the base
			for k = 0, 3 do
				local H = at(0, 0.75, -0.75) * ang(0, k * 90 + 45, 0)
				local p0 = (H * CFrame.new(0, 0, -0.55 * s)).Position
				local p1 = (H * CFrame.new(0, 1.9 * s, -1.25 * s)).Position
				local p2 = (H * CFrame.new(0, 2.7 * s, -1.35 * s)).Position
				B:bar(cob, p0, p1, 0.85 * s, 0.22, (k % 2 == 0) and CRUST or CRUST_DK)
			end
			cobTips[ci] = at(0, 0.8 + L + 0.5, -0.75).Position
			cobFrames[ci] = at(0, 0.8 + L * 0.7, -0.75)
		end

		-- hidden popcorn kernels inside the three big cobs (fly out on the beat)
		local POPS = { { 1, 1 }, { 1, 2 }, { 2, 1 }, { 2, 2 }, { 3, 1 }, { 3, 2 } }
		for pi, pp in POPS do
			local C = cobFrames[pp[1]] * CFrame.new((pp[2] == 1) and 0.18 or -0.18, (pp[2] == 1) and 0.3 or -0.3, 0)
			local pb = B:bone("Pop" .. pi, "Cob" .. pp[1], C.Position)
			B:block(pb, v(0.8, 0.8, 0.8), CFrame.new(C.Position) * ang(20, 30, 10), LAVA_LT)
			B:block(pb, v(0.5, 0.5, 0.5), CFrame.new(C.Position + v(0, 0.2, 0)) * ang(20, 30, 10), GLOW_HOT, { mat = "Neon", name = "PopGlow" .. pi })
			B:trail(pb, C.Position + v(-0.25, 0, 0), C.Position + v(0.25, 0, 0), { name = "PopTrail" .. pi, color = { LAVA_HOT, GLOW, "#c8361a" }, life = 0.3, width = { 1, 0 }, trans = { 0.15, 1 } })
		end

		------------------------------------------------------------------
		-- EMBER TASSELS on the stalk tops
		------------------------------------------------------------------
		for si, top in tops do
			local bone = "Stalk" .. si .. "Top"
			local n = (si == 1) and 7 or 5
			B:block(bone, v(0.7, 0.8, 0.7), CFrame.new(top + v(0, 0.3, 0)), CRUST)
			for k = 0, n - 1 do
				local deg = k * 360 / n + si * 20
				local up = (k % 2 == 0) and 2.0 or 1.5
				local p1 = top + dir(deg) * 0.9 + v(0, up, 0)
				local p2 = top + dir(deg) * 1.7 + v(0, up - 0.5, 0)
				B:bar(bone, top + v(0, 0.4, 0), p1, 0.28, 0.28, (k % 2 == 0) and CRUST or LAVA)
				B:bar(bone, p1, p2, 0.24, 0.24, LAVA_LT)
				if k % 2 == 0 then
					B:block(bone, v(0.32, 0.32, 0.32), CFrame.new(p2), GLOW_HOT, { mat = "Neon", name = "Tassel" .. si .. "_" .. k })
				end
			end
			B:bar(bone, top, top + v(0, 2.6, 0), 0.3, 0.3, LAVA)
			B:block(bone, v(0.38, 0.38, 0.38), CFrame.new(top + v(0, 2.7, 0)), GLOW_HOT, { mat = "Neon", name = "Tassel" .. si .. "_top" })
		end

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local smokeFx = B:block("Stalk1Top", v(1.2, 0.6, 1.2), CFrame.new(tops[1] + v(0, 2.2, 0)), LAVA, { tr = 1, name = "SmokeFx" })
		B:emitter(smokeFx, "smoke", { name = "SmokeWisps", color = { "#8a817c", "#5f5653", "#a39a92" }, rate = 1.6, size = { 0.6, 1.6, 2.6 }, trans = { 0.55, 0.7, 1 }, life = { 2.2, 3.2 }, speed = { 0.8, 1.5 }, spread = 18, accel = { 0.3, 0.4, 0 } })
		local heat = B:block("Root", v(8, 8, 7), cf(0, GY + 7, 0), LAVA, { tr = 1, name = "HeatZone" })
		B:emitter(heat, "ember", { name = "Embers", color = { LAVA_HOT, GLOW, "#c8361a" }, rate = 9, size = { 0.34, 0.24, 0 }, life = { 1.8, 2.8 }, speed = { 0.6, 1.6 }, spread = 40, accel = { 0, 2.0, 0 }, light = 1 })
		B:emitter(heat, "sparkle", { name = "HeatSparkles", color = { LAVA_HOT, "#fff2c0", GLOW_HOT }, rate = 6, size = { 0.15, 0.45, 0 }, life = { 0.8, 1.4 }, light = 1 })
		for ci = 1, 3 do
			local fx = B:block("Cob" .. ci, v(0.8, 0.8, 0.8), cobFrames[ci], LAVA, { tr = 1, name = "PopFx" .. ci })
			B:emitter(fx, "burst", { name = "PopSparks" .. ci, color = { "#fff2b0", LAVA_HOT, GLOW }, size = { 0.5, 0.32, 0 }, speed = { 5, 11 }, life = { 0.5, 1.0 }, spread = 180, accel = { 0, -7, 0 }, drag = 2, light = 1 })
			if ci == 1 then
				B:emitter(fx, "glow", { name = "KernelGlow", color = { LAVA_HOT, GLOW }, rate = 1.5, size = { 1.6, 2.6, 0.8 }, light = 1 })
				B:light(fx, { name = "CobLight1", color = "#ff8a2a", brightness = 0.9, range = 11 })
			elseif ci == 2 then
				B:light(fx, { name = "CobLight2", color = "#ff8a2a", brightness = 0.7, range = 9 })
			end
		end
		local gl = B:block(soil, v(0.4, 0.4, 0.4), cf(0, GY + 1.0, -2.8), LAVA, { tr = 1, name = "GroundLightCore" })
		B:light(gl, { name = "GroundLight", color = "#ff6a1f", brightness = 0.9, range = 12 })
	end,
}
