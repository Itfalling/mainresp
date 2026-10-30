--!nocheck
-- Magma Heart Tree (Bramble Badlands crop #10, Apex): the showpiece of the
-- badlands. A colossal obsidian tree growing out of a live volcano.
-- * a big stepped VOLCANO mound (bone "Soil", parts "Soil"): charcoal basalt
--   and rust rock tiers, ash drifts, bone fragments, obsidian shards, a
--   crater rim of chunky rocks around a lava pool
-- * four LAVA RIVERS spill from the crater and cascade down every tier into
--   little lava pools (bone "Lava" under Soil; neon cores FlowR_K ripple)
-- * a twisted glossy OBSIDIAN trunk (bone "Crop") with purple sheen and
--   glowing magma veins (VeinL_S) that light up on the heartbeat
-- * a two-tier "heat gradient" canopy: dark obsidian leaves at the bottom
--   glowing up through crimson and rust to orange + amber at the top
--   ("Canopy", "CanopyTop")
-- * the BEATING MAGMA HEART crowning the tree, held in five obsidian claws
--   (ClawN); its lobes are separate bones (HeartL / HeartR / HeartB) that
--   pump outward on every beat around a neon magma core
-- * six small magma-heart fruits hang under the canopy (FruitN)
-- * five lava bombs (BombN) hidden in the crater are flung out on the
--   eruption beat with fire trails
-- * VFX: heart glow + embers, crater smoke, lava embers, falling ash, crater
--   fire + eruption burst, heart-beat sparks; heart / crater / lava lights
-- Blocks only (no wedges / round parts). No faces.
return {
	DisplayName = "Magma Heart Tree",
	Rarity = "Apex",
	Element = "Fire",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ------------------------------------------------------------
		local BASALT_BK, BASALT_DK, BASALT, BASALT_LT = "#1c1718", "#262021", "#342c2b", "#4a3f3b"
		local RUST_DK, RUST, RUST_LT = "#5a271b", "#783624", "#97482d"
		local ASH, ASH_LT, ASH_DK = "#8a837d", "#aea79f", "#67605b"
		local CRACK = "#140d0e"
		local LAVA_DK, LAVA, LAVA_HOT, LAVA_YEL = "#c2331a", "#ff6414", "#ff9a2a", "#ffd04a"
		local OBS_BK, OBS_DK, OBS, OBS_LT, OBS_SHEEN = "#0f0c13", "#18131e", "#221b2a", "#30263b", "#54447a"
		local BONE, BONE_LT, BONE_DK = "#e6d9b8", "#f5eddb", "#c4b088"
		-- canopy heat gradient (bottom -> top)
		local LF_OBS1, LF_OBS2, LF_OBS3 = "#241e26", "#332a36", "#463848"
		local LF_CRIM, LF_CRIM2, LF_RUST = "#7c1c1f", "#952422", "#b23a1e"
		local LF_ORG, LF_ORG2, LF_AMB, LF_YEL = "#dd5a1c", "#ea7320", "#f59a2a", "#ffc54a"
		-- the heart
		local HRT_DK, HRT, HRT_LT, HRT_CORE = "#8a1420", "#c4202a", "#ff5a46", "#ffd66a"

		local seed = 1800180
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
		-- THE VOLCANO (bone "Soil", parts "Soil")
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
		-- outer radius of an oct() tier of width w along polar angle d
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
			-- y0, y1, width, colour
			{ 0.0, 1.2, 24.0, BASALT_BK },
			{ 1.2, 2.8, 20.0, RUST_DK },
			{ 2.8, 4.6, 16.4, BASALT },
			{ 4.6, 6.4, 13.2, RUST },
			{ 6.4, 8.0, 10.6, BASALT_DK },
		}
		for _, t in TIERS do
			oct(t[1], t[2], t[3], t[4])
		end
		local RIVERS = { 0, 90, 180, 270 }
		local function nearRiver(d, tol)
			for _, r in RIVERS do
				local e = math.abs(((d - r) + 540) % 360 - 180)
				if e < tol then
					return true
				end
			end
			return false
		end
		-- chunky rock blocks around the tier edges (kept clear of the rivers)
		for ti, n in { 14, 11, 9 } do
			local t = TIERS[ti]
			for i = 0, n - 1 do
				local a = i * 360 / n + jit(5) + 9
				if not nearRiver(a, 13) then
					local r = edgeR(t[3], a) - 0.6 + jit(0.2)
					local x, z = polar(r, a)
					local h = (t[2] - t[1]) + 0.1 + rnd() * 0.3
					local col = (ti % 2 == 1) and ({ BASALT_LT, BASALT, BASALT_DK })[1 + i % 3] or ({ RUST, RUST_LT, RUST_DK })[1 + i % 3]
					B:block(soil, v(2.6 + rnd() * 0.8, h, 1.7 + rnd() * 0.4), cf(x, t[1] + h / 2, z, 0, -a + jit(8), 0), col, S)
				end
			end
		end
		-- rust strata bands on the risers of the upper tiers
		for i = 0, 7 do
			local a = i * 45 + 22.5
			local r = edgeR(13.2, a) + 0.05
			B:block(soil, v(3.0, 0.35, 0.3), facing(at(r, a, 5.5), a), RUST_LT, S)
			r = edgeR(16.4, a) + 0.05
			B:block(soil, v(3.6, 0.4, 0.3), facing(at(r, a, 3.5), a), BASALT_LT, S)
		end
		-- ash drifts on the tier tops
		for _, m in { { 45, 11.0, 1.2, 2.8, ASH }, { 135, 10.6, 1.2, 2.4, ASH_LT }, { 225, 11.0, 1.2, 2.8, ASH }, { 315, 10.6, 1.2, 2.2, ASH_DK },
			{ 30, 8.6, 2.8, 2.2, ASH_LT }, { 150, 8.4, 2.8, 2.0, ASH }, { 240, 8.6, 2.8, 2.4, ASH_LT }, { 330, 8.4, 2.8, 1.8, ASH_DK },
			{ 60, 6.6, 4.6, 1.8, ASH }, { 200, 6.6, 4.6, 1.6, ASH_LT }, { 120, 4.8, 6.4, 1.4, ASH_LT }, { 300, 4.8, 6.4, 1.4, ASH } } do
			B:block(soil, v(m[4], 0.24, 1.4), facing(at(m[2], m[1], m[3] + 0.1), m[1]) * ang(-6, 0, 0), m[5], S)
		end
		-- glowing cracks on the tier tops
		local function crack(r0, r1, d, y, zig)
			local pts = {}
			for k = 0, 3 do
				local r = r0 + (r1 - r0) * k / 3
				table.insert(pts, at(r, d + ((k % 2 == 0) and -zig or zig), y))
			end
			for k = 1, 3 do
				B:bar(soil, pts[k], pts[k + 1], 0.55, 0.14, CRACK, S)
				B:bar(soil, pts[k] + v(0, 0.05, 0), pts[k + 1] + v(0, 0.05, 0), 0.22, 0.14, LAVA, SN)
			end
		end
		crack(8.2, 10.6, 50, 1.22, 5)
		crack(8.2, 10.6, 220, 1.22, 5)
		crack(6.4, 8.4, 140, 2.82, 6)
		crack(6.4, 8.4, 320, 2.82, 6)
		crack(5.0, 6.4, 30, 4.62, 7)
		crack(5.0, 6.4, 235, 4.62, 7)
		-- obsidian shard clusters on the slopes
		local function shards(p, s, yaw)
			local c = CFrame.new(p) * ang(0, yaw, 0)
			B:block(soil, v(0.9 * s, 2.8 * s, 0.9 * s), c * CFrame.new(0, 1.2 * s, 0) * ang(10, 0, -12), OBS, S)
			B:block(soil, v(0.55 * s, 0.7 * s, 0.55 * s), c * CFrame.new(-0.3 * s, 2.55 * s, 0) * ang(10, 0, -12), OBS_SHEEN, S)
			B:block(soil, v(0.7 * s, 1.9 * s, 0.7 * s), c * CFrame.new(0.8 * s, 0.75 * s, 0.2 * s) * ang(-8, 30, 24), OBS_LT, S)
			B:block(soil, v(0.6 * s, 1.4 * s, 0.6 * s), c * CFrame.new(-0.7 * s, 0.55 * s, -0.4 * s) * ang(14, -20, -30), OBS_DK, S)
		end
		shards(at(9.6, 52, 1.2), 1.1, 30)
		shards(at(7.6, 228, 2.8), 0.9, -40)
		shards(at(10.4, 300, 1.2), 0.8, 10)
		shards(at(5.6, 140, 4.6), 0.75, 70)
		-- bone fragments + a little fossil rib on the base tier
		for _, b in { { v(-10.4, 1.3, 3.2), v(-9.0, 1.4, 4.8) }, { v(6.2, 2.9, 5.4), v(7.6, 3.0, 4.4) }, { v(3.6, 1.3, -10.4), v(5.0, 1.35, -9.6) } } do
			B:bar(soil, b[1], b[2], 0.4, 0.4, BONE, S)
			B:block(soil, v(0.6, 0.55, 0.6), CFrame.new(b[1]) * ang(0, 30, 0), BONE_LT, S)
		end
		do
			local base = v(-7.0, 2.8, -6.2)
			for k = 0, 2 do
				local p0 = base + v(k * 0.9, 0, k * 0.6)
				B:bar(soil, p0, p0 + v(-0.6, 1.4, -0.3), 0.4, 0.4, BONE, S)
				B:bar(soil, p0 + v(-0.6, 1.4, -0.3), p0 + v(-1.6, 1.8, -0.8), 0.36, 0.36, BONE_LT, S)
			end
			B:bar(soil, base + v(-0.2, 0.2, -0.1), base + v(2.2, 0.2, 1.5), 0.55, 0.55, BONE_DK, S)
		end

		-- CRATER: a rim of chunky rocks (notched where the rivers spill out)
		local CRATER_Y = 8.0
		for i = 0, 11 do
			local a = i * 30 + 15
			local r = 4.6 + jit(0.15)
			local h = 1.0 + rnd() * 0.6
			B:block(soil, v(2.3 + rnd() * 0.4, h, 1.5), facing(at(r, a, CRATER_Y + h / 2 - 0.1), a) * ang(jit(6), jit(8), jit(5)),
				({ BASALT_LT, BASALT, RUST_DK, BASALT_DK })[1 + i % 4], S)
		end
		-- lava pool inside the crater (plastic body, small neon hot spots)
		B:block(soil, v(8.2, 0.3, 8.2), cf(0, CRATER_Y + 0.1, 0, 0, 45, 0), LAVA_DK, S)
		B:block(soil, v(7.6, 0.3, 7.6), cf(0, CRATER_Y + 0.16, 0), LAVA, S)
		for i = 0, 5 do
			local a = i * 60 + 30
			B:block(soil, v(1.0, 0.3, 0.7), facing(at(3.6, a, CRATER_Y + 0.22), a), LAVA_YEL, SN)
		end

		------------------------------------------------------------------
		-- LAVA RIVERS (bone "Lava": static bodies + rippling neon cores)
		------------------------------------------------------------------
		local lava = B:bone("Lava", "Soil", v(0, 0, 0))
		local flowN = {}
		for ri, d in RIVERS do
			local k = 0
			local function seg(cfr, size, bodyGrow, coreSize, coreOff)
				k += 1
				B:block(lava, size, cfr, LAVA_DK, { name = "LavaBed" })
				B:block(lava, size + bodyGrow, cfr, LAVA, { name = "LavaBody" })
				B:block(lava, coreSize, cfr * coreOff, LAVA_HOT, { mat = "Neon", name = ("Flow%d_%d"):format(ri, k) })
			end
			local prevR = 3.6
			for ti = 5, 1, -1 do
				local t = TIERS[ti]
				local e = edgeR(t[3], d)
				local r0 = prevR
				local r1 = (ti == 1) and (e - 1.4) or (e + 0.05)
				local len = r1 - r0
				local c = facing(at((r0 + r1) / 2, d, t[2] + 0.08), d)
				local wid = 1.9 + (5 - ti) * 0.25
				seg(c, v(wid, 0.3, len), v(-0.6, 0.04, -0.12), v(0.75, 0.34, len - 0.3), CFrame.new(0, 0.03, 0))
				if ti > 1 then
					-- cascade down the riser
					local yb = TIERS[ti - 1][2]
					local h = t[2] - yb + 0.25
					local cd = facing(at(e + 0.2, d, (t[2] + yb) / 2 + 0.05), d)
					seg(cd, v(wid, h, 0.4), v(-0.6, -0.12, 0.04), v(0.75, h - 0.3, 0.44), CFrame.new(0, 0, -0.03))
				end
				prevR = e + 0.05
			end
			-- the pool where it ends on the base tier
			local pe = edgeR(24.0, d) - 1.4
			local pc = facing(at(pe, d, 1.25), d)
			B:block(lava, v(3.6, 0.3, 2.4), pc, LAVA_DK, { name = "LavaBed" })
			B:block(lava, v(3.0, 0.32, 1.8), pc, LAVA, { name = "LavaBody" })
			B:block(lava, v(1.4, 0.36, 0.9), pc, LAVA_YEL, { mat = "Neon", name = "Pool" .. ri })
			for _, o in { -2.0, 2.0 } do
				B:block(lava, v(0.9, 0.7, 0.9), pc * CFrame.new(o, 0.25, 0.5) * ang(0, 30, 10), BASALT_LT, { name = "LavaBed" })
			end
			flowN[ri] = k
		end

		------------------------------------------------------------------
		-- OBSIDIAN TRUNK (bone "Crop")
		------------------------------------------------------------------
		local BASE = CRATER_Y + 0.2
		local crop = B:bone("Crop", "Root", v(0, BASE, 0))
		local SEG = {
			-- width, y0 (above BASE), x off, yaw, colour
			{ 5.6, 0.0, 0.0, 8, OBS_DK },
			{ 5.3, 1.75, 0.1, 22, OBS },
			{ 5.0, 3.5, 0.2, 38, OBS_DK },
			{ 4.8, 5.25, 0.1, 54, OBS },
			{ 4.6, 7.0, -0.1, 70, OBS_DK },
			{ 4.4, 8.75, -0.3, 86, OBS },
			{ 4.2, 10.5, -0.3, 102, OBS_DK },
		}
		for _, s in SEG do
			B:block(crop, v(s[1], 2.25, s[1]), cf(s[3], BASE + s[2] + 1.1, 0, 0, s[4], 0), s[5])
		end
		-- glossy sheen ridges: twisted purple-grey edges
		for _, a0 in { 30, 150, 270 } do
			local prev
			for i = 0, 4 do
				local f = i / 4
				local y = BASE + 0.6 + f * 12.6
				local w = 6.0 - 2.3 * f
				local x, z = polar(w * 0.52 + 0.1, a0 + f * 95)
				local p = v(x, y, z)
				if prev then
					B:bar(crop, prev, p, 0.7, 0.6, (i % 2 == 0) and OBS_SHEEN or OBS_LT)
				end
				prev = p
			end
		end
		-- glowing MAGMA VEINS (named by level so the pulse can climb): 4 strands
		local VEIN_LEVELS = 6
		for si, a0 in { 0, 90, 180, 270 } do
			local prev
			for lv = 0, VEIN_LEVELS do
				local f = lv / VEIN_LEVELS
				local y = BASE + 0.4 + f * 12.8
				local w = 6.0 - 2.3 * f
				local a = a0 + f * 95 + ((lv % 2 == 0) and -9 or 9)
				local x, z = polar(w * 0.5 + 0.12, a)
				local p = v(x, y, z)
				if prev then
					B:bar(crop, prev, p, 0.3, 0.3, LAVA_HOT, { mat = "Neon", name = ("Vein%d_%d"):format(lv, si) })
				end
				prev = p
			end
		end
		-- roots clutching the crater rim
		for k = 0, 5 do
			local a = k * 60 + 30
			local p0 = at(2.6, a, BASE + 1.0)
			local p1 = at(4.2, a + 6, CRATER_Y + 0.9)
			local p2 = at(5.4, a + 12, CRATER_Y - 0.7)
			local p3 = at(6.4, a + 16, 5.6)
			B:bar(crop, p0, p1, 1.5, 1.2, (k % 2 == 0) and OBS or OBS_DK)
			B:bar(crop, p1, p2, 1.15, 1.0, OBS_DK)
			B:bar(crop, p2, p3, 0.85, 0.75, OBS)
			B:bar(crop, p0 + v(0, 0.62, 0), p1 + v(0, 0.52, 0), 0.25, 0.2, LAVA, { mat = "Neon", name = "RootVein" .. k })
		end

		-- crooked branches
		local TOPY = BASE + 11.8
		local branchTips = {}
		for k = 0, 5 do
			local a = k * 60 + 10
			local x0, z0 = polar(0.6, a)
			local x1, z1 = polar(3.4, a + 12)
			branchTips[k + 1] = { a = a, p0 = v(x0, TOPY - 1.0, z0), p1 = v(x1, TOPY + 1.4, z1) }
			B:bar(crop, branchTips[k + 1].p0, branchTips[k + 1].p1, 1.7, 1.5, (k % 2 == 0) and OBS or OBS_DK)
		end

		------------------------------------------------------------------
		-- CANOPY: obsidian leaves heating up to amber toward the heart
		------------------------------------------------------------------
		local CPY = TOPY + 0.6
		local canopy = B:bone("Canopy", "Crop", v(0, CPY, 0))
		for _, b in branchTips do
			local x2, z2 = polar(6.6, b.a + 4)
			local tip = v(x2, CPY + 2.4, z2)
			B:bar(canopy, b.p1 - (b.p1 - b.p0).Unit * 0.4, tip, 1.2, 1.1, OBS_LT)
			b.tip = tip
		end
		B:block(canopy, v(3.0, 7.0, 3.0), cf(0, CPY + 3.4, 0, 0, 20, 0), OBS_DK)
		local function leaf(bone, p, s, col)
			B:block(bone, v(s, s, s), CFrame.new(p) * ang(jit(18), rnd() * 90, jit(18)), col)
		end
		local AY = CPY + 3.2
		local cubes = {}
		local ringA = { LF_CRIM, LF_OBS2, LF_CRIM2, LF_RUST, LF_OBS3, LF_CRIM, LF_CRIM2, LF_OBS2, LF_RUST, LF_CRIM, LF_OBS3, LF_CRIM2 }
		for i = 0, 11 do
			local a = i * 30 + jit(5)
			local up = (i % 2 == 0) and 0.4 or -0.35
			local x, z = polar(7.1 + jit(0.4), a)
			local p = v(x, AY + up + jit(0.2), z)
			local s = 4.6 + rnd() * 0.7
			leaf(canopy, p, s, ringA[i + 1])
			table.insert(cubes, { p = p, s = s, a = a })
		end
		for _, k in { 2, 5, 8, 11 } do
			local c = cubes[k]
			leaf(canopy, c.p + outward(c.a) * 0.7 + v(0, -c.s * 0.55 - 0.7, 0), 2.0, LF_OBS2)
		end
		for _, d in { { 3.4, 0, 1.0, 5.4, LF_OBS2 }, { 3.4, 120, 1.1, 5.4, LF_CRIM }, { 3.4, 240, 1.0, 5.4, LF_OBS3 } } do
			local x, z = polar(d[1], d[2])
			leaf(canopy, v(x, AY + d[3], z), d[4], d[5])
		end
		local capA = { LF_CRIM, LF_RUST, LF_CRIM2, LF_RUST, LF_CRIM, LF_ORG, LF_CRIM2, LF_RUST, LF_CRIM, LF_RUST, LF_ORG }
		for i = 0, 10 do
			local a = i * (360 / 11) + 15
			local x, z = polar(5.6 + jit(0.3), a)
			leaf(canopy, v(x, AY + 2.5 + jit(0.3), z), 3.2 + rnd() * 0.5, capA[i + 1])
		end
		-- half-sunk ember glints on the lower ring
		for n, idx in { 1, 4, 7, 10 } do
			local c = cubes[idx]
			local p = c.p + outward(c.a) * (c.s * 0.5 + 0.05) + v(0, c.s * 0.1, 0)
			B:block(canopy, v(0.9, 0.9, 0.3), facing(p, c.a) * ang(0, 0, 45), LAVA_HOT, { mat = "Neon", name = "Ember" .. n })
		end
		-- obsidian shards breaking out of the canopy
		for _, sh in { { 5.2, 40, 1.2, 25 }, { 5.4, 160, 1.0, -20 }, { 5.0, 280, 1.3, 15 } } do
			local base = at(sh[1], sh[2], AY + sh[3])
			local c = CFrame.new(base) * CFrame.Angles(0, -rad(sh[2]), 0) * ang(-sh[4], 0, 0)
			B:block(canopy, v(1.0, 3.4, 1.0), c * CFrame.new(0, 1.0, -0.6), OBS)
			B:block(canopy, v(0.6, 0.8, 0.6), c * CFrame.new(0, 2.9, -0.6), OBS_SHEEN)
		end

		local canopyTop = B:bone("CanopyTop", "Canopy", v(0, AY + 2.4, 0))
		local BY = AY + 4.6
		local ringB = { LF_RUST, LF_ORG, LF_ORG2, LF_RUST, LF_ORG, LF_ORG2, LF_AMB, LF_ORG }
		for i = 0, 7 do
			local a = i * 45 + 20 + jit(5)
			local x, z = polar(4.5 + jit(0.3), a)
			leaf(canopyTop, v(x, BY + jit(0.3), z), 4.0 + rnd() * 0.4, ringB[i + 1])
		end
		leaf(canopyTop, v(0, BY + 0.3, 0), 4.4, LF_ORG)
		for i = 0, 6 do
			local a = i * (360 / 7) + 5
			local x, z = polar(3.4, a)
			leaf(canopyTop, v(x, BY + 2.0 + jit(0.2), z), 2.5 + rnd() * 0.4, ({ LF_AMB, LF_YEL, LF_ORG2, LF_AMB, LF_YEL, LF_AMB, LF_ORG2 })[i + 1])
		end

		------------------------------------------------------------------
		-- THE MAGMA HEART + obsidian claws
		------------------------------------------------------------------
		local HS = 3.5
		local HY = BY + 6.6
		local HC = v(0, HY, 0)
		-- stalk + charred leaf collar at its base
		B:block(canopyTop, v(1.2, 3.0, 1.2), cf(0, BY + 3.4, 0, 0, 30, 0), OBS_DK)
		for i = 0, 5 do
			local c = CFrame.new(0, BY + 3.2, 0) * CFrame.Angles(0, rad(i * 60 + 15), 0) * CFrame.new(0, 0, -1.6) * ang(-24, 0, 0)
			B:block(canopyTop, v(1.5, 0.35, 2.0), c, (i % 2 == 0) and OBS_LT or OBS_SHEEN)
		end
		local heart = B:bone("Heart", "CanopyTop", HC)
		local F = CFrame.new(HC)
		local d = 1.05 * HS
		-- inner magma core (shows through the gaps when the lobes pump apart)
		B:block(heart, v(1.0 * HS, 1.0 * HS, d * 0.8), F * CFrame.new(0, -0.05 * HS, 0) * ang(0, 0, 45), LAVA_HOT, { mat = "Neon", name = "HeartInner" })
		local hL = B:bone("HeartL", "Heart", HC + v(-0.4 * HS, 0.22 * HS, 0))
		local hR = B:bone("HeartR", "Heart", HC + v(0.4 * HS, 0.22 * HS, 0))
		local hB = B:bone("HeartB", "Heart", HC + v(0, -0.35 * HS, 0))
		for _, L in { { hL, -1 }, { hR, 1 } } do
			local bone, sx = L[1], L[2]
			local LC = F * CFrame.new(sx * 0.4 * HS, 0.22 * HS, 0) * ang(0, 0, 45)
			B:block(bone, v(0.8 * HS, 0.8 * HS, d * 0.94), LC, HRT)
			-- stepped crust highlight + magma crack on both faces
			B:block(bone, v(0.4 * HS, 0.4 * HS, d * 0.94 + 0.2), LC * CFrame.new(-0.12 * HS * sx, 0.12 * HS, 0), HRT_LT)
			for _, fz in { -1, 1 } do
				B:block(bone, v(0.5 * HS, 0.14, 0.12), LC * CFrame.new(0.08 * HS * sx, -0.12 * HS, fz * (d * 0.47 + 0.07)) * ang(0, 0, 25 * sx), LAVA_YEL,
					{ mat = "Neon", name = ("LobeCrack%s%d"):format(sx > 0 and "R" or "L", fz > 0 and 2 or 1) })
			end
		end
		do
			local BC = F * CFrame.new(0, -0.35 * HS, 0) * ang(0, 0, 45)
			B:block(hB, v(1.1 * HS, 1.1 * HS, d), BC, HRT_DK)
			B:block(hB, v(0.55 * HS, 0.55 * HS, d + 0.16), BC * CFrame.new(0.22 * HS, 0.22 * HS, 0), HRT)
			-- glowing core on front + back
			B:block(hB, v(0.55 * HS, 0.55 * HS, 0.16), BC * CFrame.new(0.05 * HS, 0.05 * HS, -(d * 0.5 + 0.1)), HRT_CORE, { mat = "Neon", name = "HeartCore" })
			B:block(hB, v(0.55 * HS, 0.55 * HS, 0.16), BC * CFrame.new(0.05 * HS, 0.05 * HS, d * 0.5 + 0.1), HRT_CORE, { mat = "Neon", name = "HeartCoreB" })
			-- obsidian cap in the notch + two vessel stubs
			B:block(heart, v(0.6 * HS, 0.35 * HS, 0.6 * HS), F * CFrame.new(0, 0.5 * HS, 0) * ang(0, 45, 0), OBS)
			B:block(heart, v(0.32 * HS, 0.45 * HS, 0.32 * HS), F * CFrame.new(-0.12 * HS, 0.74 * HS, 0.1 * HS) * ang(0, 0, 14), OBS_LT)
			B:block(heart, v(0.26 * HS, 0.35 * HS, 0.26 * HS), F * CFrame.new(0.15 * HS, 0.72 * HS, -0.08 * HS) * ang(0, 0, -18), OBS_SHEEN)
		end
		-- five obsidian claws curling up around the heart
		for i = 1, 5 do
			local a = (i - 1) * 72 + 36
			local p0 = at(1.6, a, BY + 3.0)
			local claw = B:bone("Claw" .. i, "CanopyTop", p0)
			local p1 = at(4.2, a, HY - 1.8)
			local p2 = at(4.7, a + 6, HY + 1.0)
			local p3 = at(3.4, a + 12, HY + 3.4)
			B:bar(claw, p0, p1 + (p1 - p0).Unit * 0.3, 0.95, 0.9, OBS)
			B:bar(claw, p1, p2 + (p2 - p1).Unit * 0.25, 0.8, 0.75, OBS_DK)
			B:bar(claw, p2, p3, 0.6, 0.6, OBS_LT)
			B:block(claw, v(0.55, 0.55, 0.55), CFrame.new(p3) * ang(45, a, 0), OBS_SHEEN)
			B:bar(claw, p1 - outward(a) * 0.4, p2 - outward(a + 6) * 0.35, 0.22, 0.22, LAVA, { mat = "Neon", name = "ClawVein" .. i })
		end

		------------------------------------------------------------------
		-- HANGING MAGMA-HEART FRUITS (FruitN, pivot at the stem top)
		------------------------------------------------------------------
		local function smallHeart(bone, F2, s, coreName)
			local dd = 0.85 * s
			B:block(bone, v(0.8 * s, 0.8 * s, dd * 0.94), F2 * CFrame.new(-0.4 * s, 0.22 * s, 0) * ang(0, 0, 45), HRT)
			B:block(bone, v(0.8 * s, 0.8 * s, dd * 0.94), F2 * CFrame.new(0.4 * s, 0.22 * s, 0) * ang(0, 0, 45), HRT)
			B:block(bone, v(1.1 * s, 1.1 * s, dd), F2 * CFrame.new(0, -0.35 * s, 0) * ang(0, 0, 45), HRT_DK)
			B:block(bone, v(0.4 * s, 0.4 * s, 0.12), F2 * CFrame.new(-0.42 * s, 0.3 * s, -dd * 0.47 - 0.04) * ang(0, 0, 45), HRT_LT)
			B:block(bone, v(0.5 * s, 0.5 * s, 0.14), F2 * CFrame.new(0.05 * s, -0.3 * s, -dd * 0.5 - 0.06) * ang(0, 0, 45), HRT_CORE, { mat = "Neon", name = coreName })
			B:block(bone, v(0.5 * s, 0.5 * s, 0.14), F2 * CFrame.new(0.05 * s, -0.3 * s, dd * 0.5 + 0.06) * ang(0, 0, 45), HRT_CORE, { mat = "Neon", name = coreName .. "B" })
			B:block(bone, v(0.5 * s, 0.3 * s, 0.5 * s), F2 * CFrame.new(0, 0.55 * s, 0) * ang(0, 45, 0), OBS)
		end
		local FRUITS = {
			{ 30, 1.5, 1.6 },
			{ 90, 2.4, 1.5 },
			{ 150, 1.6, 1.6 },
			{ 210, 2.3, 1.5 },
			{ 270, 1.5, 1.6 },
			{ 330, 2.4, 1.5 },
		}
		for i, f in FRUITS do
			local x, z = polar(6.2, f[1])
			local top = v(x, AY - 2.1, z)
			local bone = B:bone("Fruit" .. i, "Canopy", top)
			local s = f[3]
			local c = top + v(0, -f[2] - 0.9 * s, 0) + outward(f[1]) * 0.3
			B:bar(bone, top + v(0, 0.8, 0), c + v(0, 0.6 * s, 0), 0.32, 0.32, OBS_LT)
			smallHeart(bone, facing(c, f[1]), s, "FruitCore" .. i)
		end

		------------------------------------------------------------------
		-- LAVA BOMBS (hidden in the crater; flung out on the eruption)
		------------------------------------------------------------------
		for i = 1, 5 do
			local a = (i - 1) * 72 + 18
			local p = at(3.2, a, CRATER_Y - 0.9)
			local bomb = B:bone("Bomb" .. i, "Root", p)
			B:block(bomb, v(1.1, 1.1, 1.1), CFrame.new(p) * ang(20, 35, 10), "#4a1610", { name = "Bomb" .. i })
			B:block(bomb, v(0.85, 0.85, 0.85), CFrame.new(p) * ang(45, 10, 45), LAVA_HOT, { mat = "Neon", name = "Bomb" .. i .. "N" })
			B:trail(bomb, p + v(0, 0.35, 0), p - v(0, 0.35, 0), { name = "BombTrail" .. i, color = { LAVA_YEL, LAVA, "#7a2a1a" }, life = 0.45, width = { 1, 0 }, trans = { 0.1, 1 } })
		end

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local hcore = B:block(heart, v(2.2, 2.2, 2.2), F, HRT_CORE, { tr = 1, name = "HeartZone" })
		B:emitter(hcore, "glow", { name = "HeartGlow", color = { "#ffb347", "#ff4a2a" }, rate = 1.6, size = { 3.0, 4.4, 1.0 } })
		B:emitter(hcore, "ember", { name = "HeartEmbers", color = { LAVA_YEL, LAVA_HOT, LAVA_DK }, rate = 5, size = { 0.32, 0.2, 0 }, life = { 1.4, 2.4 }, speed = { 1, 2.4 }, spread = 60, accel = { 0, 1.8, 0 } })
		B:emitter(hcore, "burst", { name = "HeartBurst", color = { LAVA_YEL, LAVA_HOT, "#ff3a1a" }, size = { 0.8, 0.5, 0 }, speed = { 7, 14 } })
		local crater = B:block(soil, v(6.0, 0.6, 6.0), cf(0, CRATER_Y + 0.6, 0), LAVA, { tr = 1, name = "CraterZone" })
		B:emitter(crater, "smoke", { name = "CraterSmoke", color = { "#5a504c", "#3a3331" }, rate = 2.2, size = { 1.6, 3.4, 4.6 }, life = { 2.2, 3.4 }, speed = { 1.2, 2.2 }, spread = 25, accel = { 0.3, 0.6, 0 } })
		B:emitter(crater, "fire", { name = "CraterFire", color = { LAVA_YEL, LAVA_HOT, LAVA_DK }, rate = 40, size = { 2.2, 1.6, 0 }, life = { 0.5, 1.0 }, speed = { 6, 11 }, spread = 22, enabled = false })
		B:emitter(crater, "burst", { name = "EruptBurst", color = { LAVA_YEL, LAVA_HOT, "#ff3a1a" }, size = { 1.1, 0.7, 0 }, speed = { 10, 20 }, life = { 0.7, 1.4 }, accel = { 0, -14, 0 }, spread = 50, dir = "Top" })
		local slope = B:block(soil, v(18, 0.5, 18), cf(0, 3.0, 0), LAVA, { tr = 1, name = "SlopeZone" })
		B:emitter(slope, "ember", { name = "LavaEmbers", color = { LAVA_YEL, LAVA_HOT, LAVA_DK }, rate = 7, size = { 0.26, 0.16, 0 }, life = { 1.2, 2.4 }, speed = { 0.8, 2 }, spread = 20, accel = { 0, 1.6, 0 } })
		local ashZone = B:block(canopy, v(14, 1, 14), cf(0, AY - 1.0, 0), ASH, { tr = 1, name = "AshZone" })
		B:emitter(ashZone, "leaf", { name = "AshFall", color = { ASH_LT, LF_ORG, ASH }, rate = 1.6, size = { 0.38, 0.38, 0.22 }, life = { 3.5, 5.5 }, speed = { 0.3, 0.8 }, accel = { 0.3, -1.1, 0 }, dir = "Bottom" })
		B:light(hcore, { name = "HeartLight", color = "#ff6a2a", brightness = 1.4, range = 22 })
		B:light(crater, { name = "CraterLight", color = "#ff7a1a", brightness = 1.2, range = 18 })
		B:light(slope, { name = "LavaLight", color = "#ff5a1a", brightness = 0.9, range = 20 })
	end,
}
