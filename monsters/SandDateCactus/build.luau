--!nocheck
-- Date Cactus (Sandy Savanna plant #1, Common).
-- A tall stepped saguaro cactus on a stepped golden sand mound (sandstone
-- rocks, dry yellow grass tufts, pebbles, a tiny cactus sprout and a little
-- shell). The ribbed trunk (a square column + a 45-degree star column for
-- ribs, cream spines on the rib edges) steps narrower toward the top and
-- grows three upturned arms. Orange date stalks arc out from under the crown
-- and from the arm tops with chunky bunches of amber-brown dates hanging
-- down; a big pink cactus flower crowns the top, small pink buds on the arms.
-- Static prop: no motion.luau.
return {
	DisplayName = "Date Cactus",
	Rarity = "Common",
	Element = "Sand",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Sandy Savanna)
		local SAND_DK, SAND_DK2, SAND, SAND_LT, SAND_TOP = "#c48a45", "#b77d3c", "#d9a95c", "#e8c27a", "#f0d08e"
		local ROCK, ROCK_DK, ROCK_LT = "#cf9358", "#a8703f", "#e6b27a"
		local GRASS, GRASS_DK, GRASS_LT = "#d9b84a", "#b8963a", "#f0d872"
		local PEBBLE, PEBBLE_DK = "#bfae94", "#968670"
		local SHELL, SHELL_PK = "#fff1dc", "#ffc2b0"
		local CAC_DK, CAC, CAC_LT, CAC_TOP = "#428a3a", "#5aa848", "#7cc35a", "#9ad66c"
		local SPINE = "#fbefcc"
		local STALK, STALK_DK = "#e8a33c", "#c47e26"
		local DATE_DK, DATE, DATE_LT, DATE_GOLD = "#9a4a1c", "#c4642a", "#e08436", "#ffc35a"
		local PETAL, PETAL_DK, PETAL_LT, CENTER = "#ff7fb4", "#e4528f", "#ffc6de", "#ffe066"

		local seed = 1411
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end

		------------------------------------------------------------ sand mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.4, 2.1), rnd(1.1, 1.5)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.3)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.75, 4.3, SAND_DK, 11, { SAND_DK, SAND_DK2, SAND_DK }, 0.35)
		tier(0.75, 0.55, 3.0, SAND, 7, { SAND, SAND_LT, SAND }, 0.25)
		tier(1.3, 0.35, 1.9, SAND_LT, 0, {}, 0)
		B:block(soil, v(1.6, 0.14, 1.2), cf(-0.9, 1.7, -1.0, 0, 20, 0), SAND_TOP, S)

		-- sandstone rocks (layered)
		local function rock(x, z, y, s, yaw)
			local c = CFrame.new(x, y, z) * ang(0, yaw, 0)
			B:block(soil, v(1.4 * s, 0.8 * s, 1.1 * s), c * CFrame.new(0, 0.4 * s, 0), ROCK, S)
			B:block(soil, v(1.0 * s, 0.5 * s, 0.8 * s), c * CFrame.new(0.15 * s, 1.0 * s, -0.05 * s) * ang(0, 12, 0), ROCK_LT, S)
			B:block(soil, v(1.55 * s, 0.25 * s, 1.2 * s), c * CFrame.new(0, 0.12 * s, 0), ROCK_DK, S)
		end
		rock(-3.3, 1.7, 0.75, 1.0, 25)
		rock(3.5, 1.2, 0.75, 0.75, -30)
		-- pebbles
		B:block(soil, v(0.55, 0.4, 0.5), cf(-3.9, 0.95, 0.4, 0, 40, 0), PEBBLE, S)
		B:block(soil, v(0.45, 0.35, 0.45), cf(2.1, 1.47, -1.9, 0, 15, 0), PEBBLE_DK, S)
		B:block(soil, v(0.5, 0.35, 0.4), cf(0.6, 0.92, 3.6, 0, 60, 0), PEBBLE, S)
		-- a little shell (front-left)
		B:block(soil, v(0.7, 0.25, 0.6), cf(-2.2, 1.42, -2.2, 0, 30, 0), SHELL, S)
		B:block(soil, v(0.45, 0.3, 0.4), cf(-2.2, 1.5, -2.2, 0, 30, 0), SHELL_PK, S)
		-- dry grass tufts (splayed straw blades)
		local function tuft(x, z, y)
			local yaw = rnd(0, 90)
			local base = CFrame.new(x, y, z) * ang(0, yaw, 0)
			B:block(soil, v(0.3, 1.2, 0.3), base * CFrame.new(0, 0.5, 0) * ang(0, 0, 0), GRASS, S)
			B:block(soil, v(0.28, 1.0, 0.28), base * CFrame.new(0.25, 0.4, 0) * ang(0, 0, -25), GRASS_LT, S)
			B:block(soil, v(0.28, 0.9, 0.28), base * CFrame.new(-0.25, 0.35, 0.05) * ang(0, 0, 25), GRASS_DK, S)
		end
		tuft(4.2, -0.9, 0.6)
		tuft(-1.2, 4.1, 0.6)
		tuft(2.6, -3.2, 0.6)
		-- tiny cactus sprout (front-right)
		B:block(soil, v(0.6, 0.9, 0.6), cf(1.3, 1.95, -2.35, 0, 15, 0), CAC, S)
		B:block(soil, v(0.4, 0.5, 0.4), cf(1.68, 2.0, -2.35, 0, 15, 0), CAC_LT, S)
		B:block(soil, v(0.32, 0.22, 0.32), cf(1.3, 2.5, -2.35, 0, 60, 0), PETAL, S)

		------------------------------------------------------------ cactus
		local crop = B:bone("Crop", "Root", v(0, 1.65, 0))
		local spines = 0
		-- ribbed column: square block + a 45 deg star block (ribs) + spines on rib edges
		local function column(x, z, y0, y1, w, spineRows)
			local h = y1 - y0
			local c = CFrame.new(x, (y0 + y1) / 2, z)
			B:block(crop, v(w, h, w), c, CAC)
			local s = w * 0.86
			B:block(crop, v(s, h + 0.06, s), c * ang(0, 45, 0), CAC_DK)
			for r = 1, spineRows do
				local y = y0 + h * (r - 0.5) / spineRows
				local off = (r % 2 == 0) and 45 or 0
				for k = 0, 3 do
					local a = rad(off + k * 90)
					local d = (off == 45) and (w / math.sqrt(2) + 0.08) or (s / math.sqrt(2) + 0.08)
					B:block(crop, v(0.22, 0.22, 0.22), CFrame.new(x + math.sin(a) * d, y, z - math.cos(a) * d) * ang(0, -math.deg(a), 0), SPINE)
					spines += 1
				end
			end
		end
		-- trunk steps narrower toward the top
		column(0, 0, 1.4, 5.2, 2.8, 2)
		column(0, 0, 5.1, 8.7, 2.55, 1)
		column(0, 0, 8.6, 10.9, 2.3, 1)
		B:block(crop, v(1.85, 0.6, 1.85), cf(0, 11.15, 0), CAC_LT)
		B:block(crop, v(1.55, 0.62, 1.55), cf(0, 11.15, 0, 0, 45, 0), CAC)
		B:block(crop, v(1.2, 0.4, 1.2), cf(0, 11.6, 0), CAC_TOP)
		-- lighter growth bands where the trunk steps in
		B:block(crop, v(2.65, 0.3, 2.65), cf(0, 5.2, 0, 0, 0, 0), CAC_LT)
		B:block(crop, v(2.4, 0.3, 2.4), cf(0, 8.7, 0, 0, 0, 0), CAC_LT)

		-- arms: horizontal stub from the trunk, then an upturned column
		local function arm(dir, yOut, reach, yTop, w)
			-- dir: unit Vector3 in XZ
			local side = v(dir.Z, 0, -dir.X)
			local inner = dir * 1.0
			local elbow = dir * reach
			local hc, len = P.aim(v(inner.X, yOut, inner.Z), v(elbow.X, yOut, elbow.Z) + dir * (w / 2))
			B:block(crop, v(w, w, len), hc, CAC)
			-- rib block stops at the column's inner face so its diamond corners stay hidden
			local rc, rlen = P.aim(v(inner.X, yOut, inner.Z), v(elbow.X, yOut, elbow.Z) - dir * (w * 0.45))
			B:block(crop, v(w * 0.86, w * 0.86, rlen), rc * ang(0, 0, 45), CAC_DK)
			column(elbow.X, elbow.Z, yOut - w / 2, yTop, w, 1)
			-- fillet in the inner elbow so the arm curves up instead of a hard L
			local fc = P.aim(v(elbow.X, yOut, elbow.Z), v(elbow.X, yOut, elbow.Z) + side)
			B:block(crop, v(w * 0.75, w * 0.75, w * 0.96), CFrame.new(v(elbow.X, yOut, elbow.Z) - dir * (w * 0.5) + v(0, w * 0.5, 0)) * (fc - fc.Position) * ang(0, 0, 45), CAC)
			B:block(crop, v(w * 0.72, 0.4, w * 0.72), cf(elbow.X, yTop + 0.18, elbow.Z), CAC_LT)
			B:block(crop, v(w * 0.45, 0.3, w * 0.45), cf(elbow.X, yTop + 0.5, elbow.Z), CAC_TOP)
			return v(elbow.X, yTop + 0.65, elbow.Z)
		end
		local armR = arm(v(1, 0, 0), 4.4, 3.9, 8.7, 1.6)
		local armL = arm(v(-1, 0, 0), 6.0, 3.7, 10.1, 1.55)
		local armB = arm(v(0.3, 0, 0.95).Unit, 7.6, 3.0, 9.6, 1.3)

		------------------------------------------------------------ flowers
		local hearts = {}
		local function flower(p, n, s, idx, big)
			local F = P.aim(p, p + n) * ang(0, 0, rnd(0, 45))
			if big then -- a ring of eight cupped petals tipping up and out (frame -Z = normal)
				for k = 0, 7 do
					local G = F * ang(0, 0, k * 45)
					local outer = k % 2 == 0
					B:block(crop, v(1.05 * s, 1.3 * s, 0.26), G * CFrame.new(0, (outer and 1.05 or 0.9) * s, outer and -0.3 or -0.45) * ang(outer and -32 or -48, 0, 0), outer and PETAL or PETAL_LT)
				end
			end
			B:block(crop, v(1.4 * s, 1.4 * s, 0.3), F * CFrame.new(0, 0, 0.25) * ang(0, 0, 22.5), CAC_LT)
			B:block(crop, v(2.0 * s, 2.0 * s, 0.4), F, PETAL)
			B:block(crop, v(2.0 * s, 2.0 * s, 0.44), F * CFrame.new(0, 0, 0.02) * ang(0, 0, 45), PETAL_DK)
			B:block(crop, v(1.25 * s, 1.25 * s, 0.4), F * CFrame.new(0, 0, -0.2) * ang(0, 0, 22.5), PETAL_LT)
			table.insert(hearts, B:block(crop, v(0.55 * s, 0.55 * s, 0.4), F * CFrame.new(0, 0, big and -0.55 or -0.38), CENTER, { mat = "Neon", name = "CactusBloom" .. idx }))
		end
		flower(v(0, 12.0, 0), v(0, 1, -0.3), 1.15, 1, true)
		flower(armL + v(0, 0.05, 0), v(-0.2, 1, -0.3), 0.72, 2, true)
		-- small closed bud on the right arm
		B:block(crop, v(0.7, 0.8, 0.7), cf(armR.X, armR.Y + 0.25, armR.Z, 0, 20, 0), PETAL_DK)
		B:block(crop, v(0.5, 0.5, 0.5), cf(armR.X, armR.Y + 0.75, armR.Z, 0, 65, 0), PETAL)
		B:block(crop, v(0.6, 0.7, 0.6), cf(armB.X, armB.Y + 0.2, armB.Z, 0, 10, 0), PETAL_DK)
		B:block(crop, v(0.42, 0.42, 0.42), cf(armB.X, armB.Y + 0.65, armB.Z, 0, 55, 0), PETAL_LT)

		------------------------------------------------------------ dates
		-- stalk arcs out from the trunk then droops; a stepped bunch of plump
		-- dates (separate blocks with small gaps so each date reads) hangs below
		local function bunch(a, y, r0, rows)
			local d = v(math.sin(rad(a)), 0, -math.cos(rad(a)))
			local side = v(d.Z, 0, -d.X)
			local p0 = d * r0 + v(0, y, 0)
			local p1 = d * (r0 + 1.3) + v(0, y + 0.5, 0)
			local p2 = d * (r0 + 2.1) + v(0, y - 0.3, 0)
			B:bar(crop, p0, p1, 0.34, 0.34, STALK)
			B:bar(crop, p1, p2, 0.32, 0.32, STALK_DK)
			local top = p2 + v(0, -0.2, 0)
			local yaw = -a
			B:block(crop, v(1.5, 0.28, 0.45), CFrame.new(top) * ang(0, yaw, 0), STALK)
			B:block(crop, v(0.45, 0.28, 1.4), CFrame.new(top + v(0, 0.02, 0)) * ang(0, yaw, 0), STALK)
			local layout = {
				{ side * 0.72 + v(0, -0.75, 0), -10, DATE_LT },
				{ -side * 0.72 + v(0, -0.75, 0), 10, DATE },
				{ d * 0.62 + v(0, -0.8, 0), 0, DATE },
				{ -d * 0.6 + v(0, -0.8, 0), 0, DATE_LT },
				{ side * 0.38 + d * 0.2 + v(0, -1.85, 0), -5, DATE_DK },
				{ -side * 0.38 + d * 0.15 + v(0, -1.85, 0), 5, DATE_LT },
				{ d * 0.15 + v(0, -2.85, 0), 0, DATE },
			}
			for k = 1, rows do
				local l = layout[k]
				local sz = k == 7 and 0.9 or 1.0
				B:block(crop, v(0.64 * sz, 1.0 * sz, 0.64 * sz), CFrame.new(top + l[1]) * ang(0, yaw, 0) * ang(0, 0, l[2]), l[3])
			end
			-- a little golden shine on the front date
			B:block(crop, v(0.2, 0.3, 0.12), CFrame.new(top + d * 0.95 + side * 0.12 + v(0, -0.6, 0)) * ang(0, yaw, 0), DATE_GOLD)
		end
		bunch(38, 10.2, 1.1, 7)
		bunch(-38, 10.0, 1.1, 7)
		bunch(215, 10.3, 1.1, 5)
		bunch(145, 9.9, 1.1, 5)

		------------------------------------------------------------ fx
		B:emitter(hearts[1], "sparkle", { name = "BloomSparkle", color = { "#fff4c8", "#ffb0d0" }, rate = 2, size = 0.3 })
	end,
}
