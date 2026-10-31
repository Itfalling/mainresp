--!nocheck
-- Bramble Archway (Thorny Woods decoration, HERO piece ~20 studs).
-- A tall pointed archway grown entirely from bramble: on each side three
-- dark-green briar canes twist around a thick core cane, rise from a stepped
-- mossy stone plinth and meet in a pointed apex. Cream thorns bristle all
-- along the canes, clusters of big rotated leaf cubes hug the shoulders and
-- feet, and crimson / pink briar roses bloom up both sides with a three-rose
-- crown at the apex. Five briar tendrils (VineNa -> VineNb bone chains) hang
-- from the underside of the arch with leaves and rosebuds and sway gently
-- (motion.luau). Rose petals drift down from the crown and a few golden motes
-- twinkle. Footing: two plinths with roots, a short stepping-stone path
-- through the opening, grass tufts, toadstools and fallen petals.
-- The walk-through opening is ~8 studs wide and ~13 studs tall.
return {
	DisplayName = "Bramble Archway",
	Rarity = "Decor",
	Element = "Thorny Woods",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Thorny Woods)
		local STONE, STONE_LT, STONE_DK = "#8d8a80", "#aaa497", "#686660"
		local MOSS, MOSS_DK, MOSS_LT = "#5fae3a", "#3f8a2c", "#86c94a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local CORE = "#24451c"
		local CANE, CANE_DK, CANE_LT = "#3f7a2e", "#2c5a22", "#4f8f34"
		local THORN, THORN_TIP = "#ecdfb8", "#fff6dc"
		local LEAF_DK, LEAF, LEAF_MID, LEAF_LT = "#1d6a35", "#26803e", "#33984a", "#52b457"
		local ROSE, ROSE_DK, ROSE_LT, ROSE_HI = "#d8203e", "#9a1430", "#ff5a77", "#ff9aae"
		local PINK, PINK_DK, PINK_LT = "#ff86b3", "#e8588f", "#ffc4da"
		local ROOT = "#3d2a1a"
		local MUSH, MUSH_STEM, SPOT = "#c8262a", "#f6e6c2", "#fbf6ea"
		local PETAL, PETAL2 = "#ff8fa6", "#e8405e"
		local GOLD_LT = "#ffe08a"

		local seed = 2121
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local R = "Root"
		-- frame at p whose -Z points along dir (P.aim is exact; CFrame.lookAt mis-aims in Lune)
		local function look(p, dir)
			local d = dir.Unit
			return (P.aim(p - d, p + d))
		end
		local Z = v(0, 0, 1)

		---------------------------------------------------------------- arch centerline
		local HX = 5.5 -- pillar centre |x|
		local Y0 = 1.0 -- canes start (on the plinth)
		local SPR = 10.5 -- spring line
		local C = 1.6 -- pointed-arch centre offset
		local RR = HX + C
		local TMAX = math.acos(C / RR)
		local LV = SPR - Y0
		local LA = RR * TMAX
		local LT = LV + LA
		-- right side (x>0): position, tangent, outward normal at arclength u
		local function center(u)
			if u <= LV then
				return v(HX, Y0 + u, 0), v(0, 1, 0), v(1, 0, 0)
			end
			local th = (u - LV) / RR
			local p = v(-C + RR * math.cos(th), SPR + RR * math.sin(th), 0)
			local t = v(-math.sin(th), math.cos(th), 0)
			local o = v(math.cos(th), math.sin(th), 0)
			return p, t, o
		end
		local function mir(p, s)
			return v(p.X * s, p.Y, p.Z)
		end

		---------------------------------------------------------------- canes
		local NS = 15
		local TW = rad(34)
		local RC = 0.78
		local cols = { CANE, CANE_DK, CANE_LT }
		for _, s in { 1, -1 } do
			-- thick core
			local prev = nil
			for i = 0, 8 do
				local p = center(LT * i / 8)
				p = mir(p, s)
				if prev then
					B:bar(R, prev, p + (p - prev).Unit * 0.45, 1.35, 1.35, CORE)
				end
				prev = p
			end
			-- three twisting canes
			for k = 0, 2 do
				local last = nil
				for i = 0, NS do
					local u = LT * i / NS
					local p, t, o = center(u)
					local phi = k * rad(120) + u * TW * s + (s < 0 and rad(60) or 0)
					local off = o * math.cos(phi) + Z * math.sin(phi)
					local q = mir(p + off * RC, s)
					local offm = mir(off, s)
					if last then
						local wdt = 0.78 + math.max(0, 1 - u / 3.5) * 0.35
						B:bar(R, last, q + (q - last).Unit * 0.25, wdt, wdt, cols[(i + k) % 3 + 1])
					end
					-- thorns
					if i > 0 and i < NS and (i + k) % 3 == 0 then
						local d = (offm + mir(t, s) * 0.45).Unit
						local f = look(q, d)
						B:block(R, v(0.34, 0.34, 0.45), f * CFrame.new(0, 0, -0.55), THORN)
						B:block(R, v(0.18, 0.18, 0.28), f * CFrame.new(0, 0, -0.88), THORN_TIP)
					end
					last = q
				end
			end
		end
		-- knot at the apex binding both sides
		local apex = center(LT)
		B:block(R, v(1.5, 1.2, 1.5), CFrame.new(apex + v(0, 0.1, 0)) * ang(0, 45, 0), CANE_DK)
		B:block(R, v(1.3, 1.0, 1.3), CFrame.new(apex + v(0, 0.3, 0)) * ang(20, 0, 25), CANE)

		---------------------------------------------------------------- leaves
		local function leafCube(p, sz, col)
			B:block(R, v(sz, sz, sz), CFrame.new(p) * ang(rnd(-35, 35), rnd(0, 90), rnd(-35, 35)), col)
		end
		local leafCols = { LEAF_DK, LEAF, LEAF_MID, LEAF_LT }
		-- {u fraction, out offset, z offset, size}
		local leafSpots = {
			{ 0.05, 0.6, -0.7, 1.4 }, { 0.06, 0.5, 0.8, 1.3 }, { 0.12, 1.0, 0.1, 1.1 },
			{ 0.36, 0.7, -0.7, 1.0 }, { 0.48, 0.9, 0.6, 1.2 }, { 0.55, 0.8, -0.8, 1.3 },
			{ 0.62, 1.1, 0.2, 1.4 }, { 0.68, 0.6, 0.9, 1.1 }, { 0.78, 1.0, -0.6, 1.2 },
			{ 0.9, 0.9, 0.5, 1.1 }, { 0.97, 0.8, 0.7, 1.0 },
		}
		for _, s in { 1, -1 } do
			for j, l in leafSpots do
				local p, _, o = center(LT * l[1])
				local q = p + o * l[2] + Z * l[3]
				leafCube(mir(q, s), l[4] * rnd(0.9, 1.1), leafCols[(j + (s > 0 and 0 or 1)) % 4 + 1])
			end
		end

		---------------------------------------------------------------- roses
		local function rose(p, dir, k, pal)
			local c1, c2, c3, c4 = ROSE_DK, ROSE, ROSE_LT, ROSE_HI
			if pal == "pink" then
				c1, c2, c3, c4 = PINK_DK, PINK, PINK_LT, "#fff0f5"
			end
			local f = look(p, dir)
			if k >= 1.3 then
				-- outer petal ring (8-point stepped bloom)
				for j = 0, 3 do
					B:block(R, v(0.95 * k, 0.95 * k, 0.4 * k), f * ang(0, 0, j * 90) * CFrame.new(0, 0.62 * k, 0.05 * k) * ang(0, 0, 45), (j % 2 == 0) and c2 or c1)
				end
			else
				B:block(R, v(1.8 * k, 0.6 * k, 0.25), f * CFrame.new(0, 0, 0.1) * ang(0, 0, 30), LEAF)
			end
			B:block(R, v(1.5 * k, 1.5 * k, 0.6 * k), f * CFrame.new(0, 0, -0.2 * k), c1)
			B:block(R, v(1.3 * k, 1.3 * k, 0.55 * k), f * CFrame.new(0, 0, -0.5 * k) * ang(0, 0, 45), c2)
			B:block(R, v(0.85 * k, 0.85 * k, 0.45 * k), f * CFrame.new(0, 0, -0.8 * k) * ang(0, 0, 20), c3)
			B:block(R, v(0.4 * k, 0.4 * k, 0.3 * k), f * CFrame.new(0, 0, -1.02 * k) * ang(0, 0, 65), c4)
		end
		-- {u fraction, side, z dir, size, palette}
		local roseSpots = {
			{ 0.2, 1, -1, 1.35, "red" }, { 0.4, 1, 1, 1.2, "pink" }, { 0.56, 1, -1, 1.5, "red" }, { 0.78, 1, -1, 1.15, "pink" }, { 0.7, 1, 1, 1.2, "red" },
			{ 0.3, -1, -1, 1.3, "pink" }, { 0.5, -1, -1, 1.45, "red" }, { 0.64, -1, 1, 1.2, "red" }, { 0.84, -1, -1, 1.15, "red" }, { 0.14, -1, 1, 1.2, "red" },
		}
		for _, r in roseSpots do
			local p, _, o = center(LT * r[1])
			local dir = (Z * r[3] + o * 0.45).Unit
			local q = p + o * 0.5 + Z * r[3] * 0.9
			rose(mir(q, r[2]), mir(dir, r[2]), r[4], r[5])
		end
		-- crown of three roses on the apex
		rose(apex + v(0, 1.5, -0.5), v(0, 0.55, -1).Unit, 1.8, "red")
		rose(apex + v(1.5, 0.5, -0.3), v(0.7, 0.35, -0.7).Unit, 1.25, "pink")
		rose(apex + v(-1.5, 0.5, -0.3), v(-0.7, 0.35, -0.7).Unit, 1.25, "pink")
		rose(apex + v(0, 1.1, 1.0), v(0, 0.5, 1).Unit, 1.25, "red")
		leafCube(apex + v(0.7, 0.9, 0.4), 1.0, LEAF_MID)
		leafCube(apex + v(-0.7, 0.9, 0.4), 1.0, LEAF)

		---------------------------------------------------------------- hanging tendrils (animated)
		-- {u fraction, side, length a, length b, z}
		local vines = {
			{ 0.62, 1, 1.6, 1.5, -0.2 },
			{ 0.86, 1, 1.9, 1.7, 0.25 },
			{ 1.0, 1, 2.2, 2.0, -0.1 },
			{ 0.82, -1, 1.8, 1.6, -0.25 },
			{ 0.58, -1, 1.5, 1.4, 0.2 },
		}
		local tips = {}
		for i, vn in vines do
			local p, _, o = center(LT * vn[1])
			local top = mir(p - o * 0.75, vn[2]) + v(0, 0, vn[5])
			if vn[1] >= 1 then top = apex - v(0, 0.8, 0) + v(0, 0, vn[5]) end
			local mid = top + v(vn[2] * 0.15, -vn[3], 0)
			local bot = mid + v(-vn[2] * 0.1, -vn[4], 0.05)
			local ba = B:bone("Vine" .. i .. "a", R, top)
			local bb = B:bone("Vine" .. i .. "b", "Vine" .. i .. "a", mid)
			B:bar(ba, top + v(0, 0.2, 0), mid - v(0, 0.12, 0), 0.42, 0.42, CANE)
			B:bar(bb, mid + v(0, 0.12, 0), bot, 0.38, 0.38, CANE_DK)
			-- leaves alternating sides
			B:block(ba, v(0.8, 0.14, 0.55), CFrame.new(top:Lerp(mid, 0.45) + v(0.45, 0, 0)) * ang(0, 0, -25), LEAF_MID)
			B:block(bb, v(0.75, 0.14, 0.5), CFrame.new(mid:Lerp(bot, 0.35) + v(-0.42, 0, 0)) * ang(0, 0, 25), LEAF_LT)
			B:block(ba, v(0.22, 0.22, 0.34), CFrame.new(top:Lerp(mid, 0.75) + v(0, 0, -0.25)), THORN)
			-- rosebud tip
			B:block(bb, v(0.5, 0.25, 0.5), CFrame.new(bot) * ang(0, 30, 0), LEAF)
			local bud = B:block(bb, v(0.46, 0.62, 0.46), CFrame.new(bot - v(0, 0.38, 0)) * ang(0, 30, 0), (i % 2 == 0) and PINK or ROSE)
			B:block(bb, v(0.26, 0.3, 0.26), CFrame.new(bot - v(0, 0.76, 0)) * ang(0, 30, 0), (i % 2 == 0) and PINK_DK or ROSE_DK)
			tips[i] = bud
		end

		---------------------------------------------------------------- footing
		for _, s in { 1, -1 } do
			local x = HX * s
			B:block(R, v(3.6, 0.6, 3.4), cf(x, 0.3, 0, 0, 10 * s, 0), STONE_DK)
			B:block(R, v(3.1, 0.56, 3.6), cf(x, 0.32, 0, 0, 52 * s, 0), STONE)
			B:block(R, v(2.6, 0.5, 2.6), cf(x, 0.8, 0, 0, 25 * s, 0), STONE_LT)
			B:block(R, v(1.4, 0.24, 1.0), cf(x - 0.9 * s, 0.68, -0.9, -10, 20, 0), MOSS)
			B:block(R, v(1.2, 0.24, 1.0), cf(x + 0.7 * s, 1.06, 0.6, 0, -15, 8 * s), MOSS_LT)
			-- roots spreading over the ground
			for _, r in { { 2.6, -1.2 }, { 2.2, 1.6 }, { -1.6, -2.0 }, { 0.6, 2.4 } } do
				B:bar(R, v(x, 1.0, 0), v(x + r[1] * s, 0.18, r[2]), 0.5, 0.42, (r[2] > 0) and ROOT or CANE_DK)
			end
			-- grass tufts
			for _, g in { { 2.4, -0.4 }, { -1.4, 1.4 }, { 1.2, -2.2 }, { 1.8, 2.2 } } do
				B:block(R, v(0.4, 0.9, 0.4), cf(x + g[1] * s, 0.45, g[2], rnd(-8, 8), rnd(0, 40), rnd(-8, 8)), GRASS)
				B:block(R, v(0.3, 0.6, 0.3), cf(x + g[1] * s + 0.3, 0.3, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK)
			end
		end
		-- stepping-stone path through the opening
		for _, s in { { 0.2, -3.2, 1.6, 15, STONE }, { -0.3, -0.6, 1.8, -10, STONE_LT }, { 0.3, 1.9, 1.6, 30, STONE }, { -0.1, 4.2, 1.3, 5, STONE_DK } } do
			local k = s[3]
			B:block(R, v(1.3 * k, 0.3, k), cf(s[1], 0.15, s[2], 0, s[4], 0), s[5])
		end
		-- little toadstools
		for _, m in { { 3.2, -1.8, 0.6, 20 }, { 3.7, -2.4, 0.42, 60 }, { -3.5, 2.0, 0.55, 10 } } do
			local k = m[3]
			local base = cf(m[1], 0, m[2], 0, m[4], 0)
			B:block(R, v(0.5 * k, 1.2 * k, 0.5 * k), base * CFrame.new(0, 0.6 * k, 0), MUSH_STEM)
			B:block(R, v(1.6 * k, 0.5 * k, 1.6 * k), base * CFrame.new(0, 1.35 * k, 0), MUSH)
			B:block(R, v(0.9 * k, 0.35 * k, 0.9 * k), base * CFrame.new(0, 1.75 * k, 0) * ang(0, 45, 0), MUSH)
			B:block(R, v(0.35 * k, 0.12 * k, 0.35 * k), base * CFrame.new(0, 1.95 * k, 0), SPOT)
		end
		-- fallen petals
		for _, l in { { 1.4, -2.0, PETAL }, { -1.2, -1.4, PETAL2 }, { 0.9, 0.8, PETAL }, { -1.6, 2.8, PETAL }, { 2.2, 3.2, PETAL2 }, { -2.4, -3.0, PETAL } } do
			B:block(R, v(0.55, 0.1, 0.5), cf(l[1], 0.05, l[2], 0, rnd(0, 90), 0), l[3])
		end

		---------------------------------------------------------------- vfx
		local crown = B:block(R, v(9, 2, 3), cf(0, 15.5, 0), PETAL, { tr = 1, name = "PetalCloud" })
		B:emitter(crown, "leaf", { name = "Petals", color = { PETAL, PETAL2 }, rate = 3, size = { 0.35, 0.35, 0.2 }, life = { 3.5, 5 }, speed = { 0.3, 0.8 }, accel = { 0.4, -1.2, 0 } })
		local motes = B:block(R, v(12, 10, 4), cf(0, 9, 0), GOLD_LT, { tr = 1, name = "MoteCloud" })
		B:emitter(motes, "sparkle", { name = "Motes", color = { GOLD_LT, "#ffffff" }, rate = 2, size = { 0.12, 0.25, 0 }, speed = { 0.1, 0.4 }, life = { 1.5, 2.5 } })
	end,
}
