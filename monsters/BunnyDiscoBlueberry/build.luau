--!nocheck
-- Disco Blueberry Bush (Bunny Stage plant #3, Rare).
-- A chunky VIP-garden bush in the stud-tree style: stepped dirt mound, short
-- flared trunk with four stubby branches, a wide crown of big rotated emerald
-- leaf cubes, and clusters of blueberries that are tiny DISCO BALLS (each berry
-- is a blue cube with four silver corner cubes = a 2x2 mirror-tile checker on
-- every face, a few with a neon glint). Static prop: no motion.luau.
return {
	DisplayName = "Disco Blueberry Bush",
	Rarity = "Rare",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		local DIRT_DK, DIRT, DIRT_LT = "#3f2516", "#5a3520", "#734626"
		local BARK_DK, BARK, BARK_LT = "#5c3720", "#7a4a2a", "#93603a"
		local GRASS, GRASS_DK = "#5fd23c", "#3fa82a"
		local LEAF_LT, LEAF, LEAF_DK = "#5fd46e", "#37b456", "#228a41"
		local BLUE, INDIGO, SILVER, SILVER_LT = "#4a6fe0", "#3b4bc8", "#d9e2f0", "#f4f7fc"
		local GLINT = "#bfe9ff"

		----------------------------------------------------------------- mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(size, h, y, col)
			B:block(soil, v(size, h, size), cf(0, y, 0), col, S)
			B:block(soil, v(size - 0.1, h - 0.04, size - 0.1), cf(0, y - 0.02, 0, 0, 45, 0), col, S)
		end
		local function ring(r, n, w, h, d, cols, phase, jit)
			for i = 0, n - 1 do
				local deg = phase + i * 360 / n
				local a = math.rad(deg)
				local hh = h + ((i % 3 == 1) and 0.2 or ((i % 3 == 2) and -0.1 or 0))
				B:block(soil, v(w, hh, d), cf(math.sin(a) * r, hh / 2 + (jit or 0), math.cos(a) * r, 0, deg, 0), cols[i % #cols + 1], S)
			end
		end
		-- wide dark bottom ring with a chunky irregular edge
		oct(8.0, 0.6, 0.3, DIRT_DK)
		ring(4.0, 12, 2.1, 0.75, 1.3, { DIRT_DK, "#4b2c19", DIRT_DK, "#352013" }, 7)
		-- lighter middle tier + its own chunky edge
		oct(5.8, 0.55, 0.85, DIRT)
		ring(2.8, 9, 1.8, 0.6, 1.1, { DIRT, "#64391f" }, 20, 0.65)
		-- top tier
		oct(3.6, 0.4, 1.35, DIRT_LT)
		-- tiny grass tufts
		B:block(soil, v(0.45, 0.9, 0.45), cf(3.9, 0.45, -3.2, 0, 20, 0), GRASS, S)
		B:block(soil, v(0.4, 0.6, 0.4), cf(4.4, 0.3, -2.7, 0, 5, 0), GRASS_DK, S)
		B:block(soil, v(0.45, 0.8, 0.45), cf(-4.3, 0.4, 2.6, 0, -10, 0), GRASS, S)
		B:block(soil, v(0.4, 0.55, 0.4), cf(-3.7, 0.28, 3.3, 0, 30, 0), GRASS_DK, S)

		----------------------------------------------------------------- trunk
		local crop = B:bone("Crop", "Root", v(0, 1.6, 0))
		B:block(crop, v(2.8, 0.6, 2.8), cf(0, 1.8, 0, 0, 15, 0), BARK_DK)
		B:block(crop, v(2.2, 0.6, 2.2), cf(0, 2.35, 0, 0, 40, 0), BARK)
		B:block(crop, v(1.7, 0.5, 1.7), cf(0, 2.85, 0, 0, 5, 0), BARK_LT)
		B:block(crop, v(1.4, 3.2, 1.4), cf(0, 4.4, 0, 0, 20, 0), BARK)
		local function branch(x, y, z)
			B:beam(crop, v(0, 5.0, 0), v(x, y, z), 0.8, 0.8, BARK)
		end
		branch(-2.2, 6.4, 0.7)
		branch(2.2, 6.5, -0.5)
		branch(0.4, 6.4, 2.2)
		branch(-0.5, 6.3, -2.1)

		----------------------------------------------------------------- canopy
		local function leaf(x, y, z, s, rx, ry, rz, col)
			B:block(crop, v(s, s, s), cf(x, y, z, rx, ry, rz), col)
		end
		local Y = 7.6
		leaf(0, Y + 0.3, 0, 4.0, 8, 15, -6, LEAF)
		leaf(-2.5, Y - 0.6, 0.7, 3.3, -12, 30, 10, LEAF_DK)
		leaf(2.6, Y - 0.5, -0.4, 3.4, 10, -20, -12, LEAF)
		leaf(0.3, Y - 0.7, 2.5, 3.2, 15, 40, 5, LEAF_DK)
		leaf(-0.5, Y - 0.7, -2.5, 3.2, -10, 10, 14, LEAF)
		leaf(-1.5, Y + 1.3, -0.8, 2.9, 20, 25, -8, LEAF_LT)
		leaf(1.7, Y + 1.2, 1.1, 3.0, -15, -30, 12, LEAF_LT)
		leaf(3.2, Y - 1.4, 2.0, 2.5, 25, 10, 30, LEAF_DK)
		leaf(-3.3, Y - 1.4, -1.7, 2.5, -20, 50, -25, LEAF)
		leaf(0.2, Y + 1.9, 0.2, 2.2, 30, 45, 20, LEAF_LT)
		leaf(-2.8, Y + 0.6, 2.2, 2.4, 10, -15, 35, LEAF)
		leaf(2.8, Y + 0.7, -2.2, 2.5, -25, 20, -10, LEAF_LT)
		leaf(-2.2, Y - 1.5, -2.6, 2.2, 15, -25, 20, LEAF_DK)
		leaf(2.0, Y - 1.6, -2.6, 2.2, -15, 35, -20, LEAF)

		----------------------------------------------------------------- disco berries
		-- blue core + 4 silver corner cubes on alternating corners = checker on all 6 faces
		local CORN = { { 1, 1, 1 }, { 1, -1, -1 }, { -1, 1, -1 }, { -1, -1, 1 } }
		local glints = {}
		local function berry(x, y, z, s, rx, ry, rz, core, glint)
			local F = cf(x, y, z, rx, ry, rz)
			B:block(crop, v(s, s, s), F, core)
			if y < Y - 1.4 then
				-- low berries hang from a little stem up into the leaves
				B:block(crop, v(0.22, 1.3, 0.22), cf(x, y + s * 0.5 + 0.45, z, 0, ry, 8), "#2c6b2a")
			end
			local c = s * 0.53
			local o = s * 0.25
			for i, k in CORN do
				B:block(crop, v(c, c, c), F * CFrame.new(k[1] * o, k[2] * o, k[3] * o), i == 1 and SILVER_LT or SILVER)
			end
			if glint then
				local g = B:block(crop, v(0.3, 0.3, 0.12), F * CFrame.new(-o, o, -(s * 0.5 + 0.04)), GLINT, { mat = "Neon", name = "Glint" .. (#glints + 1) })
				table.insert(glints, g)
				if glint == "star" then
					-- a little "+" twinkle popping off the mirror ball
					local T = F * CFrame.new(-o - 0.35, o + 0.35, -(s * 0.5 + 0.1))
					B:block(crop, v(0.9, 0.14, 0.1), T * CFrame.Angles(0, 0, math.rad(45)), "#ffffff", { mat = "Neon" })
					B:block(crop, v(0.14, 0.9, 0.1), T * CFrame.Angles(0, 0, math.rad(45)), "#ffffff", { mat = "Neon" })
				end
			end
		end
		-- clusters of 2-3 around the crown
		berry(-1.3, Y - 2.3, -3.5, 1.3, 10, 20, 15, BLUE, "star")
		berry(0.9, Y - 2.4, -3.3, 1.1, -15, 40, 5, INDIGO)
		berry(2.4, Y - 0.9, -3.0, 1.3, 20, -15, 10, BLUE, true)
		berry(3.3, Y - 1.6, -2.4, 1.1, 5, 30, -20, INDIGO)
		berry(4.2, Y - 0.2, 0.4, 1.3, -10, 60, 20, BLUE, "star")
		berry(4.2, Y - 1.3, 1.3, 1.1, 25, 10, 0, INDIGO, true)
		berry(-4.1, Y - 0.1, 0.8, 1.3, 15, -30, -10, BLUE, true)
		berry(-2.6, Y + 1.6, 2.6, 1.1, -20, 25, 15, INDIGO)
		berry(3.6, Y + 1.2, -1.6, 1.2, 15, -50, -10, BLUE, true)
		berry(-3.4, Y + 1.3, -1.9, 1.2, 25, 10, 20, BLUE)
		berry(-4.0, Y - 1.2, 0.0, 1.1, -20, 5, 25, INDIGO)
		berry(-1.1, Y + 2.1, -2.2, 1.2, 30, 20, 10, BLUE)
		berry(1.3, Y + 2.5, -0.8, 1.2, -10, 35, -15, INDIGO, "star")
		berry(-0.2, Y + 0.4, 3.7, 1.3, 10, 15, 20, BLUE, true)
		berry(1.0, Y - 0.3, 3.9, 1.1, -25, -20, 5, INDIGO)
		berry(-3.0, Y - 1.9, 2.5, 1.2, 20, 45, -10, BLUE)
		berry(2.6, Y + 1.9, 2.4, 1.2, 0, -40, 25, BLUE)

		----------------------------------------------------------------- vfx
		B:emitter(glints[1], "sparkle", { name = "DiscoSparkle", color = { "#ffffff", "#8fd0ff" }, rate = 3, size = 0.35 })
		B:emitter(glints[3], "sparkle", { name = "DiscoSparkle2", color = { "#c9b8ff", "#ffffff" }, rate = 2, size = 0.3 })
		B:light(glints[2], { color = "#7fb4ff", brightness = 0.8, range = 9, name = "DiscoGlow" })
	end,
}
