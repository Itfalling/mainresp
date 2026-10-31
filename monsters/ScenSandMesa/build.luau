--!nocheck
-- Red Rock Mesa (Sandy Savanna scenery, big copy-paste filler).
-- A big flat-topped butte of layered red sandstone in the Sandstone Arch
-- strata palette: every layer is two offset blocks (stepped, slightly
-- irregular outline) that narrows as it rises, with thin cream / peach
-- bands sticking out between layers and an overhanging pale caprock.
-- Dark erosion grooves and light streaks run down the faces, little rock
-- ledges jut out, a low stepped shelf hugs one side and a pinched hoodoo
-- spire stands on the other. Talus boulders, a dry grass tuft crown and a
-- tiny barrel cactus on top; sand footing with drifts, pebbles and tufts.
-- Anchored, weld-free, no scripts or effects.
return {
	DisplayName = "Red Rock Mesa",
	Rarity = "Scenery",
	Filler = true,
	Element = "Sandy Savanna",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		local SAND_DK, SAND_DK2, SAND, SAND_LT, SAND_TOP = "#c48a45", "#b77d3c", "#d9a95c", "#e8c27a", "#f0d08e"
		local RED_DK, RED, TERRA, ROCK, PEACH, CREAM = "#963f24", "#c4532c", "#d6683a", "#de8a52", "#efae72", "#f7d6a0"
		local GRASS, GRASS_DK, GRASS_LT = "#d9b84a", "#b8963a", "#f0d872"
		local PEBBLE, PEBBLE_DK = "#bfae94", "#968670"
		local CAC_DK, CAC, CAC_TOP = "#3f7d35", "#5aa848", "#9ad66c"
		local PINK = "#ff7fb4"

		local seed = 2207
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		------------------------------------------------------------ footing
		B:block(R, v(19.0, 0.3, 11.0), cf(0, 0.15, 0), SAND_DK)
		B:block(R, v(15.0, 0.29, 13.6), cf(0, 0.145, 0), SAND_DK)
		B:block(R, v(12.0, 0.28, 12.0), cf(0, 0.14, 0, 0, 45, 0), SAND_DK2)
		for _, e in { { -9.8, -3.2, SAND }, { 9.9, 3.0, SAND_DK2 }, { -4.0, 6.6, SAND }, { 4.6, -6.6, SAND_DK2 } } do
			B:block(R, v(2.4, 0.32, 1.4), cf(e[1], 0.16, e[2], 0, rnd(-20, 20), 0), e[3])
		end
		B:block(R, v(4.6, 0.2, 2.0), cf(-3.0, 0.36, -5.6, 0, 6, 0), SAND_LT)
		B:block(R, v(3.6, 0.2, 1.8), cf(4.4, 0.36, 5.4, 0, -8, 0), SAND)
		B:block(R, v(2.0, 0.2, 1.2), cf(8.4, 0.37, -4.0, 0, 20, 0), SAND_TOP)
		for _, p in { { -7.4, -5.0, PEBBLE }, { 1.2, -6.4, PEBBLE_DK }, { 8.8, -1.6, PEBBLE }, { -1.6, 6.2, PEBBLE_DK }, { 6.4, 5.8, PEBBLE } } do
			B:block(R, v(0.7, 0.45, 0.6), cf(p[1], 0.45, p[2], 0, rnd(0, 90), 0), p[3])
		end
		for _, g in { { -8.6, 1.8 }, { 3.0, -6.2 }, { 9.4, 0.4 }, { -5.6, 5.6 } } do
			B:block(R, v(0.4, 1.2, 0.4), cf(g[1], 0.7, g[2], 0, 20, 10), GRASS)
			B:block(R, v(0.34, 0.9, 0.34), cf(g[1] + 0.36, 0.6, g[2] + 0.16, 0, 40, -14), GRASS_DK)
			B:block(R, v(0.3, 0.7, 0.3), cf(g[1] - 0.3, 0.5, g[2] - 0.2, 0, 10, 16), GRASS_LT)
		end

		------------------------------------------------------------ main butte
		local function layer(y0, h, cx, cz, W, L, col, yaw)
			local y = y0 + h / 2
			local F = CFrame.new(cx, y, cz) * CFrame.Angles(0, rad(yaw or 0), 0)
			B:block(R, v(W, h, L * 0.72), F * CFrame.new(rnd(-0.3, 0.3), 0, 0), col)
			B:block(R, v(W * 0.78, h + 0.02, L), F * CFrame.new(rnd(-0.5, 0.5), 0, 0), col)
			return F
		end
		-- lower tier is wide; the upper tier is narrower and shifted to -X,
		-- leaving a terrace on the +X side
		local stack = {
			{ 1.6, 14.0, 9.4, RED_DK, 0.0 }, { 0.35, 14.3, 9.6, CREAM, 0.0 }, { 1.8, 13.2, 8.8, TERRA, 0.0 },
			{ 1.5, 12.6, 8.4, ROCK, -0.2 }, { 0.4, 13.2, 8.8, PEACH, -0.2 },
			{ 1.8, 9.0, 7.4, RED, -1.8 }, { 1.6, 8.6, 7.0, TERRA, -2.0 }, { 0.3, 9.0, 7.2, CREAM, -2.0 },
			{ 1.7, 8.0, 6.6, ROCK, -2.2 }, { 1.4, 7.6, 6.2, RED, -2.3 }, { 0.9, 8.8, 7.0, PEACH, -2.3 }, { 0.5, 7.6, 5.8, CREAM, -2.4 },
		}
		-- erosion grooves: {x offset from layer centre, side} per layer index
		local grooves = {
			[1] = { { -3.4, -1 }, { 2.2, -1 }, { 0.8, 1 } }, [3] = { { -3.4, -1 }, { 2.2, -1 }, { 0.8, 1 } }, [4] = { { -3.4, -1 }, { 0.8, 1 } },
			[6] = { { -2.0, -1 }, { 1.6, -1 }, { 0.2, 1 } }, [7] = { { -2.0, -1 }, { 1.6, -1 } }, [9] = { { 1.6, -1 }, { 0.2, 1 } }, [10] = { { 1.6, -1 } },
		}
		local streaks = { [3] = { { 0.6, -1 } }, [4] = { { 0.6, -1 } }, [7] = { { -0.4, 1 } }, [9] = { { -0.4, -1 } } }
		local y = 0.3
		local tops, cxs = {}, {}
		for i, st in stack do
			local h, W, L, col, cx = st[1], st[2], st[3], st[4], st[5]
			local cz = 0.1 * math.sin(i)
			layer(y, h, cx, cz, W, L, col, 0)
			for _, g in grooves[i] or {} do
				B:block(R, v(0.55, h + 0.04, 0.3), cf(cx + g[1], y + h / 2, cz + g[2] * (L / 2 + 0.1)), RED_DK)
			end
			for _, g in streaks[i] or {} do
				B:block(R, v(0.8, h + 0.04, 0.26), cf(cx + g[1], y + h / 2, cz + g[2] * (L / 2 + 0.08)), PEACH)
			end
			y += h
			tops[i], cxs[i] = y, cx
		end
		local TOPY = y
		local TERR = tops[5] -- terrace height
		-- thin contrasting strata stripes through the thick layers
		for _, bnd in { { 3, 0.55, PEACH }, { 6, 0.6, CREAM }, { 9, 0.5, TERRA }, { 1, 0.5, ROCK } } do
			local i = bnd[1]
			local st = stack[i]
			local yb = tops[i] - st[1] * bnd[2]
			B:block(R, v(st[2] + 0.3, 0.28, st[3] * 0.72 + 0.3), cf(cxs[i], yb, 0.1 * math.sin(i)), bnd[3])
			B:block(R, v(st[2] * 0.78 + 0.3, 0.29, st[3] + 0.3), cf(cxs[i], yb, 0.1 * math.sin(i)), bnd[3])
		end
		-- side grooves on the ends
		B:block(R, v(0.3, tops[4] - 0.4, 0.6), cf(-7.05, (tops[4] + 0.4) / 2, 0.8), RED_DK)
		B:block(R, v(0.3, TOPY - TERR - 1.0, 0.7), cf(-6.25, (TOPY + TERR) / 2 - 0.5, -0.9), RED_DK)
		B:block(R, v(0.3, tops[4] - 1.0, 0.7), cf(6.85, (tops[4] + 1.0) / 2, -1.2), RED_DK)
		-- jutting ledges (cream lip over a terracotta underside)
		for _, l in { { -4.2, 3, -1, 2.6 }, { 3.6, 1, 1, 2.2 }, { -1.0, 7, -1, 2.4 }, { -4.6, 9, 1, 2.0 } } do
			local L = stack[l[2]][3]
			local z = l[3] * (L / 2 + 0.5)
			B:block(R, v(l[4], 0.45, 1.4), cf(l[1], tops[l[2]] + 0.0, z, 0, rnd(-6, 6), 0), CREAM)
			B:block(R, v(l[4] - 0.5, 0.45, 1.0), cf(l[1], tops[l[2]] - 0.42, z - l[3] * 0.15, 0, rnd(-6, 6), 0), TERRA)
		end
		-- terrace (+X): boulders, grass, a tiny barrel cactus
		B:block(R, v(2.2, 1.2, 2.0), cf(4.4, TERR + 0.55, 1.6, 0, 20, 0), ROCK)
		B:block(R, v(1.4, 0.7, 1.2), cf(4.5, TERR + 1.4, 1.6, 0, 45, 0), PEACH)
		B:block(R, v(1.2, 0.7, 1.0), cf(5.4, TERR + 0.35, -2.2, 0, 10, 0), RED)
		for _, g in { { 3.2, -1.4 }, { 5.6, 0.2 }, { 2.4, 2.6 } } do
			B:block(R, v(0.4, 1.2, 0.4), cf(g[1], TERR + 0.6, g[2], 0, 20, 10), GRASS)
			B:block(R, v(0.34, 0.9, 0.34), cf(g[1] + 0.36, TERR + 0.45, g[2] + 0.16, 0, 40, -14), GRASS_DK)
		end
		B:block(R, v(1.3, 1.2, 1.3), cf(3.6, TERR + 0.6, -0.2), CAC)
		B:block(R, v(1.5, 0.8, 1.0), cf(3.6, TERR + 0.5, -0.2), CAC_DK)
		B:block(R, v(0.8, 0.3, 0.8), cf(3.6, TERR + 1.3, -0.2), CAC_TOP)
		B:block(R, v(0.5, 0.3, 0.5), cf(3.6, TERR + 1.5, -0.2, 0, 45, 0), PINK)
		-- mesa top: a boulder and dry grass
		B:block(R, v(2.2, 1.2, 1.8), cf(-3.8, TOPY + 0.5, 0.8, 0, 20, 0), ROCK)
		B:block(R, v(1.3, 0.7, 1.1), cf(-3.7, TOPY + 1.4, 0.8, 0, 45, 0), PEACH)
		for _, g in { { -1.2, -1.2 }, { 0.6, 1.4 }, { -5.0, -1.4 } } do
			B:block(R, v(0.4, 1.2, 0.4), cf(g[1], TOPY + 0.55, g[2], 0, 20, 10), GRASS)
			B:block(R, v(0.34, 0.9, 0.34), cf(g[1] + 0.36, TOPY + 0.4, g[2] + 0.16, 0, 40, -14), GRASS_LT)
		end

		------------------------------------------------------------ side shelf (+X)
		local sy = 0.3
		for i, s in { { 1.5, 5.4, 5.6, TERRA }, { 0.3, 5.6, 5.8, CREAM }, { 1.4, 4.8, 5.0, RED }, { 1.3, 4.2, 4.6, ROCK }, { 0.6, 4.8, 5.0, PEACH } } do
			layer(sy, s[1], 7.4 + 0.1 * i, 1.2, s[2], s[3], s[4], 8)
			sy += s[1]
		end
		B:block(R, v(0.4, 0.8, 0.3), cf(8.4, sy + 0.3, 1.6, 0, 20, 8), GRASS)
		B:block(R, v(0.35, 0.6, 0.3), cf(8.7, sy + 0.25, 1.7, 0, 40, -12), GRASS_DK)

		------------------------------------------------------------ hoodoo spire (-X)
		local hy = 0.3
		local HX, HZ = -9.0, -1.6
		for i, s in { { 1.4, 3.6, RED_DK }, { 1.6, 2.8, TERRA }, { 0.3, 3.0, CREAM }, { 1.8, 2.2, ROCK }, { 1.6, 2.7, RED }, { 0.3, 3.0, PEACH }, { 1.2, 2.4, TERRA } } do
			B:block(R, v(s[2], s[1], s[2]), cf(HX + 0.08 * i, hy + s[1] / 2, HZ, 0, (i % 2) * 12, 0), s[3])
			hy += s[1]
		end
		B:block(R, v(3.4, 0.8, 3.0), cf(HX + 0.6, hy + 0.4, HZ, 0, 10, 0), CREAM)
		B:block(R, v(2.2, 0.8, 2.0), cf(HX + 0.5, hy + 1.2, HZ - 0.1, 0, 30, 0), PEACH)

		------------------------------------------------------------ talus
		for _, t in { { -6.2, -4.6, 1.8, ROCK }, { -5.0, -5.4, 1.0, PEACH }, { 5.8, -4.4, 1.5, RED }, { 6.8, -3.4, 0.9, TERRA },
			{ 2.4, 4.8, 1.4, ROCK }, { -3.4, 4.8, 1.1, RED }, { -9.4, 2.4, 1.2, TERRA }, { 10.0, 1.6, 1.0, PEACH } } do
			B:block(R, v(t[3] * 1.2, t[3], t[3]), cf(t[1], 0.25 + t[3] * 0.45, t[2], rnd(-10, 10), rnd(0, 90), rnd(-10, 10)), t[4])
		end
	end,
}
