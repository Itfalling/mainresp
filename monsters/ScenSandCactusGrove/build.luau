--!nocheck
-- Saguaro Grove (Sandy Savanna scenery, big copy-paste filler).
-- Three tall saguaro cacti of different heights (about 18 / 13 / 9 studs)
-- on one sand footing, in the Barrel Cactus Cluster palette: each trunk is
-- a square core with a dark 45-degree core behind it (octagon look) and
-- light ridge strips on every face, stepped domed tops, cream spine ticks,
-- and upturned stepped arms (elbow, upright, ridge, cap). The tallest wears
-- a little crown of cream / pink flowers. Rocks, pebbles, sand drifts and
-- dry grass tufts around the feet.
-- Anchored, weld-free, no scripts or effects.
return {
	DisplayName = "Saguaro Grove",
	Rarity = "Scenery",
	Filler = true,
	Element = "Sandy Savanna",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		local SAND_DK, SAND_DK2, SAND, SAND_LT, SAND_TOP = "#c48a45", "#b77d3c", "#d9a95c", "#e8c27a", "#f0d08e"
		local ROCK, ROCK_DK, ROCK_LT = "#c9774a", "#a9573a", "#e0a06a"
		local GRASS, GRASS_DK, GRASS_LT = "#d9b84a", "#b8963a", "#f0d872"
		local PEBBLE, PEBBLE_DK = "#bfae94", "#968670"
		local CAC_DK, CAC, CAC_LT, CAC_TOP = "#3f7d35", "#5aa848", "#7cc35a", "#9ad66c"
		local SPINE = "#fbefcc"
		local PINK, PINK_DK, CENTER = "#ff7fb4", "#e4528f", "#ffe066"

		local seed = 8819
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		------------------------------------------------------------ footing
		B:block(R, v(16.0, 0.3, 10.0), cf(0, 0.15, 0), SAND_DK)
		B:block(R, v(11.0, 0.29, 14.0), cf(0, 0.145, 0), SAND_DK)
		B:block(R, v(12.6, 0.28, 12.6), cf(0, 0.14, 0, 0, 45, 0), SAND_DK2)
		for _, e in { { 30, 7.4, SAND }, { 120, 7.8, SAND_DK2 }, { 210, 7.2, SAND }, { 300, 7.8, SAND_DK } } do
			local a = rad(e[1])
			B:block(R, v(2.2, 0.34, 1.2), CFrame.new(math.sin(a) * e[2], 0.17, -math.cos(a) * e[2]) * CFrame.Angles(0, -a + rad(10), 0), e[3])
		end
		B:block(R, v(4.6, 0.2, 2.4), cf(-1.0, 0.36, -4.2, 0, 12, 0), SAND)
		B:block(R, v(3.0, 0.2, 1.8), cf(1.0, 0.37, 4.4, 0, -18, 0), SAND_LT)
		B:block(R, v(1.8, 0.2, 1.2), cf(-5.2, 0.38, 0.6, 0, 30, 0), SAND_TOP)
		-- rocks + pebbles
		B:block(R, v(2.0, 1.1, 1.6), cf(4.4, 0.6, -3.4, 0, 25, 0), ROCK)
		B:block(R, v(1.3, 0.6, 1.1), cf(4.3, 1.35, -3.4, 0, 50, 0), ROCK_LT)
		B:block(R, v(1.0, 0.6, 0.9), cf(5.6, 0.45, -2.2, 0, 10, 0), ROCK_DK)
		B:block(R, v(1.2, 0.7, 1.0), cf(-6.4, 0.45, 1.6, 0, -25, 0), ROCK_DK)
		for _, p in { { -1.6, -5.2, PEBBLE }, { 1.4, 5.4, PEBBLE_DK }, { 6.8, 0.2, PEBBLE }, { -6.4, -1.0, PEBBLE_DK }, { 1.6, -4.6, PEBBLE } } do
			B:block(R, v(0.6, 0.4, 0.5), cf(p[1], 0.45, p[2], 0, rnd(0, 90), 0), p[3])
		end
		for _, g in { { -6.4, -3.2 }, { 1.4, -2.4 }, { 7.0, 3.0 }, { -2.4, 5.4 }, { -5.8, 3.4 }, { 2.4, 5.6 } } do
			B:block(R, v(0.4, 1.2, 0.4), cf(g[1], 0.7, g[2], 0, 20, 10), GRASS)
			B:block(R, v(0.34, 0.9, 0.34), cf(g[1] + 0.36, 0.6, g[2] + 0.16, 0, 40, -14), GRASS_DK)
			B:block(R, v(0.3, 0.7, 0.3), cf(g[1] - 0.3, 0.5, g[2] - 0.2, 0, 10, 16), GRASS_LT)
		end

		------------------------------------------------------------ saguaros
		local function spine(F, x, y, z, rx, rz)
			B:block(R, v(0.32, 0.32, 0.4), F * CFrame.new(x, y, z) * ang(rx or 0, 0, rz or 0), SPINE)
		end
		-- column (trunk or arm upright) in frame F (base at F, rising +Y)
		local function column(F, w, h, ridgeFaces)
			B:block(R, v(w, h, w), F * CFrame.new(0, h / 2, 0), CAC)
			B:block(R, v(w * 0.98, h - 0.1, w * 0.98), F * CFrame.new(0, h / 2, 0) * ang(0, 45, 0), CAC_DK)
			for _, fz in ridgeFaces do
				local a = rad(fz)
				local o = v(math.sin(a), 0, math.cos(a)) * (w / 2 + 0.08)
				B:block(R, v(w * 0.3, h - 0.5, 0.24), F * CFrame.new(o + v(0, h / 2 + 0.05, 0)) * ang(0, fz, 0), CAC_LT)
			end
			-- stepped domed top
			B:block(R, v(w * 0.76, 0.5, w * 0.76), F * CFrame.new(0, h + 0.2, 0), CAC)
			B:block(R, v(w * 0.46, 0.35, w * 0.46), F * CFrame.new(0, h + 0.55, 0), CAC_TOP)
		end
		local function saguaro(x, z, H, w, yaw, arms, flowers)
			local F = CFrame.new(x, 0.25, z) * CFrame.Angles(0, rad(yaw), 0)
			column(F, w, H, { 0, 90, 180, 270 })
			-- spine ticks on the ridges
			for i = 1, math.floor(H / 2.4) do
				local yy = 1.4 + (i - 1) * 2.2
				for _, k in { i % 4, (i + 2) % 4 } do
					local fz = rad(k * 90)
					local o = v(math.sin(fz), 0, math.cos(fz)) * (w / 2 + 0.22)
					B:block(R, v(0.34, 0.34, 0.4), F * CFrame.new(o + v(0, yy, 0)) * ang(0, k * 90, 0), SPINE)
				end
			end
			for _, a in arms do
				-- a = { height, side yaw, out, upright length, width }
				local ha, ay, out, la, aw = a[1], a[2], a[3], a[4], a[5]
				local A = F * CFrame.new(0, ha, 0) * CFrame.Angles(0, rad(ay), 0)
				local hx = w / 2 + out
				B:block(R, v(hx, aw, aw), A * CFrame.new(hx / 2, 0, 0), CAC)
				B:block(R, v(hx - 0.3, aw * 0.6, 0.2), A * CFrame.new(hx / 2 + 0.1, 0, -aw / 2 - 0.08), CAC_LT)
				local U = A * CFrame.new(hx, -aw / 2 + 0.1, 0)
				B:block(R, v(aw + 0.2, aw * 0.9, aw + 0.2), A * CFrame.new(hx - 0.05, 0.1, 0) * ang(0, 45, 0), CAC_DK)
				column(U, aw, la, { 90, 180 })
				spine(U, aw / 2 + 0.2, la * 0.6, 0, 0, 90)
				spine(U, 0, la * 0.35, -aw / 2 - 0.2, 0, 0)
			end
			if flowers then
				local top = F * CFrame.new(0, H + 0.55, 0)
				for k = 0, 2 do
					local a = rad(k * 120 + 20)
					local p = top * CFrame.new(math.sin(a) * w * 0.32, 0.15, math.cos(a) * w * 0.32)
					B:block(R, v(0.8, 0.35, 0.8), p * ang(0, 45 + k * 10, 0), (k == 1) and PINK or SPINE)
					B:block(R, v(0.4, 0.2, 0.4), p * CFrame.new(0, 0.24, 0), (k == 1) and PINK_DK or CENTER)
				end
			end
		end
		saguaro(-1.4, 1.0, 17.4, 2.2, -38, {
			{ 6.2, 180, 2.6, 5.6, 1.5 },
			{ 9.2, 0, 2.3, 4.6, 1.4 },
			{ 12.2, 100, 1.4, 2.6, 1.1 },
		}, true)
		saguaro(4.6, 2.4, 12.6, 1.9, -15, {
			{ 5.0, 0, 2.2, 4.0, 1.3 },
			{ 7.4, 250, 1.6, 2.8, 1.1 },
		}, true)
		saguaro(-4.4, -3.6, 8.6, 1.7, 30, {
			{ 3.4, 150, 1.8, 2.8, 1.1 },
		}, false)
	end,
}
