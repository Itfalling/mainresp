--!nocheck
-- Rose Thorn Lantern (Thorny Woods decoration, medium accent).
-- An old dark-wood lantern post on a stepped flat-stone footing, with a
-- curled wrought-iron hook arm. A chunky iron-and-gold lantern hangs from the
-- hook on a short chain: amber glass panes around a cream candle with a small
-- warm glowing flame (one soft light). A thorny briar cane spirals up the
-- post and along the arm, bristling with cream thorns and glossy leaves and
-- blooming with crimson roses; a tendril with a rosebud dangles beside the
-- lantern. A little rose bush, grass tufts, stones and fallen petals dress
-- the foot. Static prop: no motion.luau.
return {
	DisplayName = "Rose Thorn Lantern",
	Rarity = "Decor",
	Element = "Thorny Woods",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Thorny Woods)
		local STONE, STONE_LT, STONE_DK = "#8d8a80", "#aaa497", "#686660"
		local MOSS, MOSS_DK, MOSS_LT = "#5fae3a", "#3f8a2c", "#86c94a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local WOOD_DK, WOOD, WOOD_LT = "#3a2415", "#4e311c", "#6a4428"
		local IRON, IRON_DK, IRON_LT = "#4b3d4f", "#30263a", "#6a5c72"
		local GOLD, GOLD_LT = "#f2b844", "#ffe08a"
		local GLASS = "#ffcf73"
		local CANDLE, CANDLE_DK = "#fff1d6", "#ead2a8"
		local FLAME, FLAME_CORE = "#ffb13b", "#fff2a8"
		local CANE, CANE_DK = "#3f7a2e", "#2c5a22"
		local THORN, THORN_TIP = "#ecdfb8", "#fff6dc"
		local LEAF, LEAF_DK, LEAF_LT = "#2f7f35", "#24632c", "#4b9e3c"
		local ROSE, ROSE_DK, ROSE_LT, ROSE_HI = "#d8203e", "#9a1430", "#ff5a77", "#ff9aae"
		local PETAL = "#ff8fa6"

		local seed = 2111
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

		local PX, PZ = -1.1, 0.0 -- post position
		local PTOP = 10.2

		---------------------------------------------------------------- footing
		B:block(R, v(3.4, 0.5, 3.0), cf(PX, 0.25, PZ, 0, 8, 0), STONE_DK)
		B:block(R, v(3.0, 0.48, 3.3), cf(PX, 0.26, PZ, 0, 50, 0), STONE)
		B:block(R, v(2.2, 0.45, 2.2), cf(PX, 0.7, PZ, 0, 22, 0), STONE_LT)
		B:block(R, v(1.6, 0.4, 1.6), cf(PX, 1.1, PZ, 0, 0, 0), STONE)
		-- scattered flat stones
		for _, s in { { 1.4, -1.6, 1.0, 30, STONE }, { 2.4, -0.6, 0.7, 70, STONE_LT }, { -3.2, 1.4, 0.9, 15, STONE_DK }, { 0.9, 1.9, 0.8, 55, STONE } } do
			local k = s[3]
			B:block(R, v(1.3 * k, 0.35 * k, k), cf(s[1], 0.17 * k, s[2], rnd(-4, 4), s[4], rnd(-4, 4)), s[5])
		end
		-- moss creeping over the footing
		B:block(R, v(1.4, 0.24, 1.0), cf(PX - 1.0, 0.55, PZ - 0.9, -10, 20, 0), MOSS)
		B:block(R, v(1.1, 0.22, 0.9), cf(PX + 0.6, 0.94, PZ + 0.6, 0, -15, 8), MOSS_LT)
		B:block(R, v(1.3, 0.24, 0.8), cf(PX + 1.3, 0.5, PZ - 0.2, 0, 70, -12), MOSS_DK)
		-- grass tufts
		for _, g in { { 1.8, 0.4 }, { -3.0, -1.0 }, { -0.4, -2.2 }, { -2.4, 2.0 }, { 2.0, 1.6 } } do
			B:block(R, v(0.4, 0.9, 0.4), cf(g[1], 0.45, g[2], rnd(-8, 8), rnd(0, 40), rnd(-8, 8)), GRASS)
			B:block(R, v(0.3, 0.6, 0.3), cf(g[1] + 0.3, 0.3, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK)
		end
		-- fallen petals
		for _, l in { { 0.6, -1.9 }, { 1.9, -1.2 }, { -2.6, -1.8 }, { 0.2, 1.2 } } do
			B:block(R, v(0.5, 0.1, 0.5), cf(l[1], 0.05, l[2], 0, rnd(0, 90), 0), PETAL)
		end

		---------------------------------------------------------------- post
		B:block(R, v(1.1, PTOP - 1.2, 1.1), cf(PX, 1.2 + (PTOP - 1.2) / 2, PZ), WOOD)
		B:block(R, v(1.5, 0.7, 1.5), cf(PX, 1.6, PZ), WOOD_DK)
		-- iron bands
		for _, y in { 3.4, 7.6 } do
			B:block(R, v(1.26, 0.3, 1.26), cf(PX, y, PZ), IRON)
		end
		-- wood grain strips
		B:block(R, v(0.2, 2.6, 0.12), cf(PX + 0.15, 5.4, PZ - 0.58), WOOD_LT)
		B:block(R, v(0.12, 1.8, 0.2), cf(PX - 0.58, 6.2, PZ + 0.1), WOOD_LT)
		-- cap
		B:block(R, v(1.5, 0.4, 1.5), cf(PX, PTOP + 0.15, PZ), IRON_DK)
		B:block(R, v(0.9, 0.35, 0.9), cf(PX, PTOP + 0.5, PZ, 0, 45, 0), IRON)
		B:block(R, v(0.4, 0.4, 0.4), cf(PX, PTOP + 0.85, PZ, 0, 45, 0), GOLD)

		---------------------------------------------------------------- hook arm
		local AY = PTOP - 0.5
		local LX = 1.5 -- lantern x
		B:block(R, v(LX - PX + 0.9, 0.4, 0.4), cf((PX + LX) / 2 + 0.25, AY, PZ), IRON)
		-- scroll curl at the tip
		B:block(R, v(0.4, 0.9, 0.4), cf(LX + 0.9, AY + 0.45, PZ), IRON)
		B:block(R, v(0.7, 0.35, 0.4), cf(LX + 0.65, AY + 0.95, PZ), IRON)
		B:block(R, v(0.32, 0.32, 0.44), cf(LX + 0.42, AY + 0.65, PZ), GOLD)
		-- diagonal brace with a small curl
		B:bar(R, v(PX + 0.4, AY - 1.8, PZ), v(LX - 0.5, AY - 0.1, PZ), 0.3, 0.3, IRON)
		B:block(R, v(0.5, 0.5, 0.36), cf(PX + 0.8, AY - 0.6, PZ, 0, 0, 45), IRON_DK)
		B:block(R, v(0.26, 0.26, 0.4), cf(PX + 0.8, AY - 0.6, PZ, 0, 0, 45), GOLD)

		---------------------------------------------------------------- chain + lantern
		B:block(R, v(0.18, 0.4, 0.32), cf(LX, AY - 0.4, PZ), IRON_LT)
		B:block(R, v(0.32, 0.4, 0.18), cf(LX, AY - 0.75, PZ), IRON_LT)
		B:block(R, v(0.18, 0.4, 0.32), cf(LX, AY - 1.1, PZ), IRON_LT)
		local LT = AY - 1.35 -- lantern top (ring)
		B:block(R, v(0.5, 0.3, 0.5), cf(LX, LT - 0.1, PZ, 0, 45, 0), GOLD)
		-- roof (stepped)
		B:block(R, v(0.8, 0.3, 0.8), cf(LX, LT - 0.4, PZ), IRON)
		B:block(R, v(1.5, 0.3, 1.5), cf(LX, LT - 0.7, PZ, 0, 45, 0), IRON)
		B:block(R, v(2.25, 0.34, 2.25), cf(LX, LT - 1.0, PZ), IRON_DK)
		-- gold trim corners on the roof brim
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			B:block(R, v(0.34, 0.36, 0.34), cf(LX + c[1] * 1.04, LT - 1.0, PZ + c[2] * 1.04), GOLD)
		end
		local BT = LT - 1.16 -- body top
		local BH = 2.4
		local BB = BT - BH -- body bottom
		-- corner posts
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			B:block(R, v(0.3, BH, 0.3), cf(LX + c[1] * 0.82, BB + BH / 2, PZ + c[2] * 0.82), IRON)
		end
		-- glass panes (amber, translucent)
		for k = 0, 3 do
			local q = CFrame.new(LX, BB + BH / 2, PZ) * ang(0, k * 90, 0) * CFrame.new(0, 0, -0.8)
			B:block(R, v(1.4, BH - 0.1, 0.1), q, GLASS, { tr = 0.4, name = "Glass" })
			-- a thin iron mullion across the middle of each pane
			B:block(R, v(1.4, 0.16, 0.14), q * CFrame.new(0, 0.25, -0.02), IRON_DK)
		end
		-- base
		B:block(R, v(2.05, 0.34, 2.05), cf(LX, BB - 0.1, PZ), IRON_DK)
		B:block(R, v(1.3, 0.3, 1.3), cf(LX, BB - 0.4, PZ, 0, 45, 0), IRON)
		B:block(R, v(0.4, 0.4, 0.4), cf(LX, BB - 0.7, PZ, 0, 45, 0), GOLD)
		-- candle + flame inside
		B:block(R, v(0.55, 0.8, 0.55), cf(LX, BB + 0.48, PZ), CANDLE)
		B:block(R, v(0.65, 0.16, 0.65), cf(LX, BB + 0.85, PZ, 0, 45, 0), CANDLE_DK)
		local flame = B:block(R, v(0.34, 0.5, 0.34), cf(LX, BB + 1.18, PZ, 0, 45, 0), FLAME, { mat = "Neon", name = "Flame" })
		B:block(R, v(0.18, 0.26, 0.18), cf(LX, BB + 1.5, PZ, 0, 45, 0), FLAME_CORE, { mat = "Neon", name = "FlameTip" })

		---------------------------------------------------------------- briar spiralling up the post
		local function thorn(p, out)
			local d = (out * 0.85 + v(0, 0.5, 0)).Unit
			local f = look(p, d)
			B:block(R, v(0.26, 0.26, 0.34), f * CFrame.new(0, 0, -0.3), THORN)
			B:block(R, v(0.14, 0.14, 0.2), f * CFrame.new(0, 0, -0.55), THORN_TIP)
		end
		local function leaf(p, out, col)
			local f = look(p, out)
			B:block(R, v(0.65, 0.14, 0.9), f * CFrame.new(0, 0.1, -0.45) * ang(-15, 0, 0), col)
		end
		local pts = {}
		local y0, y1, turns = 1.6, AY - 0.2, 2.6
		local n = 19
		for i = 0, n do
			local t = i / n
			local a = rad(150 + t * turns * 360)
			local r = 0.72
			table.insert(pts, { p = v(PX + math.sin(a) * r, y0 + (y1 - y0) * t, PZ - math.cos(a) * r), out = v(math.sin(a), 0, -math.cos(a)) })
		end
		for i = 1, #pts - 1 do
			local a, b = pts[i], pts[i + 1]
			B:bar(R, a.p, b.p, 0.36, 0.36, (i % 2 == 0) and CANE or CANE_DK)
			if i % 2 == 1 then thorn(b.p, b.out) end
			if i % 3 == 0 then leaf(a.p, a.out, (i % 2 == 0) and LEAF or LEAF_LT) end
		end
		-- continue along the arm
		local last = pts[#pts].p
		local armPts = { last, v(PX + 0.9, AY + 0.3, PZ - 0.25), v(0.4, AY - 0.15, PZ + 0.28), v(LX - 0.2, AY + 0.3, PZ - 0.2), v(LX + 0.6, AY + 0.1, PZ + 0.2) }
		for i = 1, #armPts - 1 do
			B:bar(R, armPts[i], armPts[i + 1], 0.32, 0.32, (i % 2 == 0) and CANE or CANE_DK)
		end
		thorn(armPts[2], v(0, 0.6, -0.8).Unit)
		thorn(armPts[3], v(0, 0.3, 1).Unit)
		leaf(armPts[3], v(0, 0.2, -1).Unit, LEAF)
		leaf(armPts[4], v(0.3, 0.2, 1).Unit, LEAF_DK)
		---------------------------------------------------------------- roses
		local function rose(p, out, k, pink)
			local c1, c2, c3, c4 = ROSE_DK, ROSE, ROSE_LT, ROSE_HI
			if pink then
				c1, c2, c3, c4 = "#e8588f", "#ff86b3", "#ffc4da", "#fff0f5"
			end
			local f = look(p, out) * CFrame.new(0, 0, -0.25 * k)
			-- sepals
			for j = 0, 3 do
				B:block(R, v(0.5 * k, 0.5 * k, 0.16), f * ang(0, 0, j * 90 + 45) * CFrame.new(0, 0.5 * k, 0.15), LEAF)
			end
			B:block(R, v(1.15 * k, 1.15 * k, 0.55 * k), f * CFrame.new(0, 0, -0.2 * k), c1)
			B:block(R, v(1.0 * k, 1.0 * k, 0.5 * k), f * CFrame.new(0, 0, -0.45 * k) * ang(0, 0, 45), c2)
			B:block(R, v(0.62 * k, 0.62 * k, 0.4 * k), f * CFrame.new(0, 0, -0.7 * k), c3)
			B:block(R, v(0.3 * k, 0.3 * k, 0.2 * k), f * CFrame.new(0, 0, -0.88 * k) * ang(0, 0, 45), c4)
		end
		rose(pts[4].p, (pts[4].out + v(0, 0.3, 0)).Unit, 1.0)
		rose(pts[9].p, (pts[9].out + v(0, 0.3, 0)).Unit, 1.15, true)
		rose(pts[14].p, (pts[14].out + v(0, 0.4, 0)).Unit, 0.9)
		rose(pts[18].p, (pts[18].out + v(0, 0.3, 0)).Unit, 0.95)
		rose(armPts[3] + v(0, 0.2, 0), v(0, 1, -0.6).Unit, 1.05)

		---------------------------------------------------------------- rose bush at the foot
		local bush = v(PX + 1.5, 0, PZ - 1.2)
		for _, c in { { 0, 0.85, 0, 1.3, LEAF_DK }, { 0.6, 0.75, 0.4, 1.0, LEAF }, { -0.5, 0.72, 0.3, 1.0, LEAF }, { 0.2, 1.4, -0.1, 0.9, LEAF_LT } } do
			B:block(R, v(c[4], c[4], c[4]), CFrame.new(bush + v(c[1], c[2], c[3])) * ang(rnd(-20, 20), rnd(0, 90), rnd(-20, 20)), c[5])
		end
		rose(bush + v(0.1, 1.5, -0.3), v(0, 1, -0.8).Unit, 0.85, true)
		rose(bush + v(0.8, 0.9, -0.3), v(0.6, 0.4, -0.7).Unit, 0.7)
		local bush2 = v(PX - 1.6, 0, PZ + 0.9)
		B:block(R, v(1.1, 1.1, 1.1), CFrame.new(bush2 + v(0, 0.75, 0)) * ang(10, 30, -8), LEAF_DK)
		B:block(R, v(0.8, 0.8, 0.8), CFrame.new(bush2 + v(-0.4, 0.9, -0.3)) * ang(-15, 60, 10), LEAF)
		rose(bush2 + v(-0.2, 1.2, -0.5), v(-0.4, 0.8, -0.8).Unit, 0.7, true)

		---------------------------------------------------------------- vfx
		B:emitter(flame, "glow", { name = "LanternGlow", color = GLASS, rate = 2, size = { 1.6, 2.2, 1.2 }, life = { 0.8, 1.2 } })
		B:emitter(flame, "sparkle", { name = "Motes", color = { GOLD_LT, "#ffffff" }, rate = 2, size = { 0.12, 0.22, 0 }, speed = { 0.3, 0.6 }, life = { 1.2, 2.2 }, accel = { 0, 0.4, 0 } })
		B:light(flame, { color = "#ffcf8a", brightness = 1.2, range = 14, name = "LanternLight" })
	end,
}
