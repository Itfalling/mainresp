--!nocheck
-- Bonfire Pepper Plant (Scarecrow Stage crop #4, Epic).
-- A bushy ornamental pepper plant in the stud-crop style: stepped dirt mound
-- ringed with chunky campfire stones, a little firewood stack and hay
-- tufts, a sturdy green stem with branches, a dome of big rotated glossy leaf
-- cubes, and upright FLAME-SHAPED peppers poking out all over: each pepper is
-- a green calyx, then a flickering stepped stack red -> red-orange -> orange ->
-- yellow with a tiny neon flame tip. Soft ember sparkles drift off the top.
-- Static prop: no motion.luau.
return {
	DisplayName = "Bonfire Pepper Plant",
	Rarity = "Epic",
	Element = "Harvest",
	Build = function(B, P)
		local v, cf = P.v, P.cf

		-- NOTE: Lune 0.10.5's CFrame.lookAt (used by P.span / B:beam) returns a wrong
		-- rotation for any span that is not level, so this file builds its own span frame.
		local function cross(a, b)
			return v(a.Y * b.Z - a.Z * b.Y, a.Z * b.X - a.X * b.Z, a.X * b.Y - a.Y * b.X)
		end
		local function span(a, b)
			local d = b - a
			local zb = -d.Unit
			local up = math.abs(zb.Y) > 0.98 and v(0, 0, 1) or v(0, 1, 0)
			local x = cross(up, zb).Unit
			local y = cross(zb, x)
			local m = (a + b) / 2
			return CFrame.new(m.X, m.Y, m.Z, x.X, y.X, zb.X, x.Y, y.Y, zb.Y, x.Z, y.Z, zb.Z), d.Magnitude
		end
		local function bar(bone, a, b, w, h, col, opts)
			local F, len = span(a, b)
			return B:block(bone, v(w, h, len), F, col, opts)
		end

		local DIRT_DK, DIRT, DIRT_LT = "#3f2516", "#5a3520", "#734626"
		local GRASS, GRASS_DK = "#5fd23c", "#3fa82a"
		local STRAW, STRAW_D, STRAW_L = "#f3d466", "#d4a63a", "#fbe8a2"
		local STONE_DK, STONE, STONE_LT = "#6b6662", "#85807b", "#a59f97"
		local LOG, LOG_DK, LOG_END = "#9a6a3c", "#6e4626", "#f0d29a"
		local STEM_DK, STEM = "#3f6b26", "#548a30"
		local LEAF_LT, LEAF, LEAF_DK = "#4cbf4e", "#2f9c3f", "#1f7a33"
		local CALYX = "#3c8a2a"
		local FLAME = { "#d8231b", "#ff4f1c", "#ff9a22", "#ffe14d" }
		local TIP = "#fff1a0"

		----------------------------------------------------------------- mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(size, h, y, col)
			B:block(soil, v(size, h, size), cf(0, y, 0), col, S)
			B:block(soil, v(size - 0.1, h - 0.04, size - 0.1), cf(0, y - 0.02, 0, 0, 45, 0), col, S)
		end
		local function ring(r, n, w, h, d, cols, phase, base)
			for i = 0, n - 1 do
				local deg = phase + i * 360 / n
				local a = math.rad(deg)
				local hh = h + ((i % 3 == 1) and 0.2 or ((i % 3 == 2) and -0.1 or 0))
				B:block(soil, v(w, hh, d), cf(math.sin(a) * r, hh / 2 + (base or 0), math.cos(a) * r, 0, deg, 0), cols[i % #cols + 1], S)
			end
		end
		oct(9.4, 0.6, 0.3, DIRT_DK)
		ring(4.7, 14, 2.1, 0.75, 1.3, { DIRT_DK, "#4b2c19", DIRT_DK, "#352013" }, 6)
		oct(6.8, 0.55, 0.85, DIRT)
		ring(3.3, 10, 1.9, 0.6, 1.1, { DIRT, "#64391f" }, 19, 0.65)
		oct(4.4, 0.4, 1.35, DIRT_LT)
		-- grass blocks
		B:block(soil, v(0.45, 0.9, 0.45), cf(4.6, 0.45, -3.5, 0, 20, 0), GRASS, S)
		B:block(soil, v(0.4, 0.6, 0.4), cf(5.1, 0.3, -3.0, 0, 5, 0), GRASS_DK, S)
		B:block(soil, v(0.45, 0.8, 0.45), cf(-5.0, 0.4, 2.9, 0, -10, 0), GRASS, S)
		-- campfire ring: chunky stones sitting round the middle tier
		local stones = 11
		for i = 0, stones - 1 do
			local deg = 8 + i * 360 / stones
			local a = math.rad(deg)
			local s = 1.05 + ((i * 7) % 3) * 0.15
			local col = ({ STONE, STONE_DK, STONE_LT, STONE })[i % 4 + 1]
			B:block(soil, v(s * 1.1, s * 0.8, s), cf(math.sin(a) * 3.65, 1.25 + s * 0.3, math.cos(a) * 3.65, (i % 2) * 8 - 4, deg + (i % 3) * 12, (i % 3) * 5 - 5), col, S)
		end
		-- firewood log: tan bark, darker bark band, pale cut end facing out
		local function log(a, b)
			bar(soil, a, b, 0.75, 0.75, LOG, S)
			local F, len = span(a, b)
			B:block(soil, v(0.6, 0.6, 0.1), F * CFrame.new(0, 0, -len / 2 - 0.03), LOG_END, S)
			B:block(soil, v(0.82, 0.82, 0.3), F * CFrame.new(0, 0, -len / 2 + 0.45), LOG_DK, S)
		end
		-- a little firewood stack in front, cut ends facing out
		log(v(-0.85, 0.95, -4.0), v(-0.75, 0.95, -5.7))
		log(v(0.05, 0.95, -4.0), v(0.15, 0.95, -5.7))
		log(v(-0.35, 1.68, -4.1), v(-0.3, 1.68, -5.55))
		-- hay tufts
		local function hay(x, y, z, deg)
			local a = math.rad(deg)
			local dx, dz = math.sin(a), math.cos(a)
			local base = v(x, y, z)
			bar(soil, base, base + v(dx * 0.9 - dz * 0.5, 1.2, dz * 0.9 + dx * 0.5), 0.3, 0.3, STRAW, S)
			bar(soil, base, base + v(dx * 1.1, 0.9, dz * 1.1), 0.3, 0.3, STRAW_L, S)
			bar(soil, base, base + v(dx * 0.9 + dz * 0.5, 1.25, dz * 0.9 - dx * 0.5), 0.3, 0.3, STRAW_D, S)
		end
		hay(4.0, 0.8, 1.9, 70)
		hay(-3.6, 0.8, -2.8, 225)

		----------------------------------------------------------------- stem
		local crop = B:bone("Crop", "Root", v(0, 1.6, 0))
		B:block(crop, v(2.0, 0.5, 2.0), cf(0, 1.7, 0, 0, 20, 0), STEM_DK)
		B:block(crop, v(1.2, 3.6, 1.2), cf(0, 3.5, 0, 0, 10, 0), STEM)
		local function branch(x, y, z)
			bar(crop, v(0, 4.4, 0), v(x, y, z), 0.6, 0.6, STEM)
		end
		branch(-2.3, 5.9, 0.8)
		branch(2.3, 6.0, -0.6)
		branch(0.6, 5.9, 2.3)
		branch(-0.7, 5.8, -2.3)

		----------------------------------------------------------------- leaves
		local function leaf(x, y, z, s, rx, ry, rz, col)
			B:block(crop, v(s, s, s), cf(x, y, z, rx, ry, rz), col)
		end
		local Y = 6.7
		-- skirt
		leaf(-3.0, Y - 0.9, 0.7, 2.9, -12, 30, 10, LEAF_DK)
		leaf(3.0, Y - 0.8, -0.5, 3.0, 10, -20, -12, LEAF_DK)
		leaf(0.5, Y - 0.9, 3.0, 2.8, 15, 40, 5, LEAF_DK)
		leaf(-0.6, Y - 0.9, -3.0, 2.8, -10, 10, 14, LEAF)
		leaf(2.4, Y - 1.1, 2.4, 2.4, 25, 10, 30, LEAF)
		leaf(-2.5, Y - 1.1, -2.3, 2.4, -20, 50, -25, LEAF)
		leaf(2.4, Y - 1.2, -2.5, 2.3, -15, 35, -20, LEAF_DK)
		leaf(-2.5, Y - 1.2, 2.5, 2.3, 15, -25, 20, LEAF_DK)
		-- body
		leaf(0, Y + 0.5, 0, 4.4, 8, 15, -6, LEAF)
		leaf(-2.0, Y + 0.8, -1.2, 3.2, 20, 25, -8, LEAF_LT)
		leaf(2.1, Y + 0.7, 1.4, 3.3, -15, -30, 12, LEAF)
		leaf(-2.1, Y + 0.6, 2.0, 3.0, 10, -15, 35, LEAF_LT)
		leaf(2.2, Y + 0.9, -2.0, 3.0, -25, 20, -10, LEAF_LT)
		-- crown
		leaf(0.2, Y + 2.2, 0.2, 2.6, 30, 45, 20, LEAF_LT)
		leaf(-1.0, Y + 1.9, 1.1, 2.0, -20, 10, 25, LEAF)
		leaf(1.1, Y + 1.9, -1.0, 2.0, 15, -35, -15, LEAF)

		----------------------------------------------------------------- flame peppers
		local tips = {}
		-- an upright pepper at `pos`, leaning `tilt` degrees outward toward heading `deg`
		local function pepper(pos, deg, tilt, s, tongue)
			local F = CFrame.new(pos) * CFrame.Angles(0, math.rad(deg), 0) * CFrame.Angles(math.rad(tilt), 0, 0)
			local function at(x, y, z) return F * CFrame.new(x * s, y, z * s) end
			B:block(crop, v(0.3, 0.8, 0.3), at(0, -0.4, 0), STEM_DK)
			B:block(crop, v(1.25 * s, 0.35, 1.25 * s), at(0, 0.05, 0) * CFrame.Angles(0, math.rad(45), 0), CALYX)
			-- flickering stepped flame body: each step narrower and nudged side to side
			local y = 0.2
			local steps = {
				{ 1.35, 1.15, 0, 0, FLAME[1] },
				{ 1.08, 0.85, 0.18, -0.08, FLAME[2] },
				{ 0.8, 0.7, -0.14, 0.1, FLAME[3] },
				{ 0.52, 0.55, 0.1, -0.06, FLAME[4] },
			}
			for _, st in steps do
				local w, h = st[1] * s, st[2] * s
				B:block(crop, v(w, h + 0.04, w), at(st[3], y + h / 2, st[4]), st[5])
				y += h
			end
			local tip = B:block(crop, v(0.28 * s, 0.42 * s, 0.28 * s), at(-0.02, y + 0.19 * s, 0), TIP, { mat = "Neon", name = "Tip" .. (#tips + 1) })
			table.insert(tips, tip)
			if tongue then
				-- a little side flame lick on the bigger peppers
				B:block(crop, v(0.38 * s, 0.75 * s, 0.38 * s), at(-0.72 * tongue, 0.2 + 0.95 * s, 0) * CFrame.Angles(0, 0, math.rad(18 * tongue)), FLAME[3])
			end
		end
		-- top crown: a fan of big upright peppers
		pepper(v(0.1, Y + 3.2, -0.2), 0, 4, 1.05, 1)
		pepper(v(-1.5, Y + 2.7, -0.9), 240, 16, 0.95, -1)
		pepper(v(1.5, Y + 2.7, 0.5), 75, 16, 0.95, 1)
		pepper(v(-0.6, Y + 2.6, 1.6), 340, 18, 0.9, 1)
		pepper(v(0.9, Y + 2.5, -1.7), 160, 18, 0.9)
		-- middle ring poking out of the leaf sides
		pepper(v(-3.3, Y + 0.9, -1.5), 245, 24, 0.95, 1)
		pepper(v(3.4, Y + 1.0, -1.3), 110, 24, 0.95, -1)
		pepper(v(-1.0, Y + 0.6, -3.5), 190, 26, 0.95, -1)
		pepper(v(1.8, Y + 0.2, -3.2), 155, 28, 0.85)
		pepper(v(3.0, Y + 0.6, 2.2), 55, 24, 0.9)
		pepper(v(-3.0, Y + 0.7, 2.0), 300, 24, 0.9)
		pepper(v(0.4, Y + 0.8, 3.6), 5, 24, 0.95, 1)
		-- low ones peeking out under the skirt
		pepper(v(-2.2, Y - 1.7, -3.4), 210, 32, 0.75)
		pepper(v(3.8, Y - 1.6, 0.6), 95, 32, 0.75)

		----------------------------------------------------------------- vfx
		B:emitter(tips[1], "ember", { name = "Embers", color = { "#ffe27a", "#ff8a24", "#ff4a1a" }, rate = 3, size = 0.22 })
		B:emitter(tips[6], "sparkle", { name = "EmberSparkle", color = { "#fff1a0", "#ffb340" }, rate = 2, size = 0.25 })
		B:light(tips[1], { color = "#ff9a3a", brightness = 1.0, range = 10, name = "BonfireGlow" })
	end,
}
