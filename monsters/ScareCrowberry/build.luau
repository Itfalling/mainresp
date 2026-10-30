--!nocheck
-- Crowberry Bush (Scarecrow Stage crop #3, Rare).
-- A low, wide berry bush in the stud-crop style: stepped dirt mound with hay
-- tufts and a couple of fallen autumn leaves, a few short dark woody stems, a
-- dome of big rotated plum-black leaf cubes, clusters of chunky deep-violet
-- berries (each with a lighter shine corner and a tiny dark crown), and a few
-- glossy black crow feathers tucked in among the leaves like extra leaves.
-- Static prop: no motion.luau.
return {
	DisplayName = "Crowberry Bush",
	Rarity = "Rare",
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
		local STEM_DK, STEM = "#3a2430", "#4e3240"
		local LEAF_LT, LEAF, LEAF_DK = "#86649f", "#5b4076", "#45305e"
		local BERRY, BERRY_DK, BERRY_SH = "#9150ff", "#6b2fd8", "#d2b2ff"
		local CROWN = "#24122e"
		local FEATHER, FEATHER_SH, QUILL = "#16141d", "#2a3866", "#6d7088"
		local AUTUMN = { "#e8742a", "#d9452b", "#f0a83a" }

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
		oct(8.6, 0.6, 0.3, DIRT_DK)
		ring(4.3, 13, 2.1, 0.75, 1.3, { DIRT_DK, "#4b2c19", DIRT_DK, "#352013" }, 9)
		oct(6.2, 0.55, 0.85, DIRT)
		ring(3.0, 9, 1.8, 0.6, 1.1, { DIRT, "#64391f" }, 22, 0.65)
		oct(3.8, 0.4, 1.35, DIRT_LT)
		-- tiny grass blocks
		B:block(soil, v(0.45, 0.9, 0.45), cf(4.2, 0.45, -3.3, 0, 20, 0), GRASS, S)
		B:block(soil, v(0.4, 0.6, 0.4), cf(4.7, 0.3, -2.8, 0, 5, 0), GRASS_DK, S)
		B:block(soil, v(0.45, 0.8, 0.45), cf(-4.6, 0.4, 2.7, 0, -10, 0), GRASS, S)
		-- hay tufts: little fans of straw strands poking out of the mound
		local function hay(x, y, z, deg)
			local a = math.rad(deg)
			local dx, dz = math.sin(a), math.cos(a)
			local base = v(x, y, z)
			bar(soil, base, base + v(dx * 0.9 - dz * 0.5, 1.3, dz * 0.9 + dx * 0.5), 0.32, 0.32, STRAW, S)
			bar(soil, base, base + v(dx * 1.1, 1.0, dz * 1.1), 0.32, 0.32, STRAW_L, S)
			bar(soil, base, base + v(dx * 0.9 + dz * 0.5, 1.35, dz * 0.9 - dx * 0.5), 0.32, 0.32, STRAW_D, S)
		end
		hay(3.2, 0.9, 2.6, 50)
		hay(-3.4, 0.9, -2.4, 230)
		hay(-1.2, 1.25, -2.6, 190)
		-- loose straw lying on the mound
		B:block(soil, v(1.4, 0.18, 0.2), cf(1.9, 1.62, -1.2, 0, 35, 0), STRAW, S)
		B:block(soil, v(1.1, 0.18, 0.2), cf(2.1, 1.62, -0.9, 0, -20, 0), STRAW_L, S)
		B:block(soil, v(1.2, 0.18, 0.2), cf(-2.6, 1.2, 1.9, 0, 70, 0), STRAW_D, S)
		-- two fallen autumn leaves
		B:block(soil, v(0.8, 0.14, 0.6), cf(-2.2, 1.6, -0.9, 0, 25, 4), AUTUMN[1], S)
		B:block(soil, v(0.7, 0.14, 0.55), cf(3.7, 0.83, 0.6, 0, -30, -3), AUTUMN[2], S)

		----------------------------------------------------------------- stems
		local crop = B:bone("Crop", "Root", v(0, 1.6, 0))
		B:block(crop, v(2.2, 0.6, 2.2), cf(0, 1.75, 0, 0, 20, 0), STEM_DK)
		B:block(crop, v(1.6, 0.6, 1.6), cf(0, 2.3, 0, 0, 55, 0), STEM)
		local function stem(x, y, z)
			bar(crop, v(x * 0.15, 2.0, z * 0.15), v(x, y, z), 0.75, 0.75, STEM)
		end
		stem(-2.1, 4.2, 0.9)
		stem(2.2, 4.3, -0.7)
		stem(0.6, 4.2, 2.3)
		stem(-0.7, 4.1, -2.2)

		----------------------------------------------------------------- leaf dome
		local function leaf(x, y, z, s, rx, ry, rz, col)
			B:block(crop, v(s, s, s), cf(x, y, z, rx, ry, rz), col)
		end
		local Y = 5.9
		-- low wide skirt (lifted so the stems show underneath)
		leaf(-3.0, Y - 1.3, 0.7, 3.2, -12, 30, 10, LEAF_DK)
		leaf(3.0, Y - 1.2, -0.5, 3.3, 10, -20, -12, LEAF_DK)
		leaf(0.5, Y - 1.3, 3.0, 3.1, 15, 40, 5, LEAF_DK)
		leaf(-0.6, Y - 1.3, -3.0, 3.1, -10, 10, 14, LEAF)
		leaf(2.5, Y - 1.1, 2.6, 2.6, 25, 10, 30, LEAF)
		leaf(-2.6, Y - 1.1, -2.4, 2.6, -20, 50, -25, LEAF)
		leaf(2.5, Y - 1.2, -2.6, 2.5, -15, 35, -20, LEAF_DK)
		leaf(-2.6, Y - 1.2, 2.6, 2.5, 15, -25, 20, LEAF_DK)
		-- body
		leaf(0, Y + 0.4, 0, 4.4, 8, 15, -6, LEAF)
		leaf(-1.9, Y + 0.7, -1.1, 3.0, 20, 25, -8, LEAF_LT)
		leaf(2.0, Y + 0.6, 1.3, 3.1, -15, -30, 12, LEAF)
		leaf(-2.0, Y + 0.5, 1.9, 2.8, 10, -15, 35, LEAF_DK)
		leaf(2.1, Y + 0.8, -1.9, 2.8, -25, 20, -10, LEAF_LT)
		-- crown
		leaf(0.2, Y + 2.4, 0.2, 2.9, 30, 45, 20, LEAF_LT)
		leaf(-1.1, Y + 1.9, 1.3, 2.1, -20, 10, 25, LEAF)

		----------------------------------------------------------------- crow feathers
		-- glossy black feathers tucked into the bush: wide vane, narrower stepped tip,
		-- a blue-black sheen strip down the middle and a grey quill end
		local function feather(from, to, roll)
			-- local frame: -Z runs quill -> tip, X across the vane, rolled so the flat
			-- face catches the light; built as two half-vanes (black + blue-black sheen)
			-- either side of a grey shaft, then a stepped narrower tip
			local F, len = span(from, to)
			F = F * CFrame.Angles(0, 0, math.rad(roll))
			local function seg(w, h, z0, z1, x, col)
				B:block(crop, v(w, h, z1 - z0), F * CFrame.new(x, 0, len / 2 - (z0 + z1) / 2), col)
			end
			seg(0.16, 0.36, 0, len * 0.95, 0, QUILL)
			seg(0.72, 0.28, len * 0.18, len * 0.7, -0.4, FEATHER)
			seg(0.72, 0.28, len * 0.18, len * 0.7, 0.4, FEATHER_SH)
			seg(0.95, 0.26, len * 0.68, len * 0.9, 0, FEATHER)
			seg(0.45, 0.24, len * 0.88, len, 0, FEATHER)
		end
		-- left/right ones are rolled flat-on to the front so the vane reads as a feather
		feather(v(-2.2, Y + 1.0, -0.6), v(-6.0, Y + 3.6, -1.2), 90)
		feather(v(2.2, Y + 1.3, 0.2), v(5.9, Y + 3.8, 0.9), -90)
		feather(v(-0.6, Y + 2.6, 0.6), v(-1.4, Y + 6.0, 1.8), 90)
		feather(v(0.6, Y + 0.4, -2.0), v(1.7, Y + 2.2, -5.6), 0)

		----------------------------------------------------------------- berry clusters
		local glints = {}
		local function berry(x, y, z, s, ry, col, glint)
			local F = cf(x, y, z, 0, ry, 0)
			B:block(crop, v(s, s, s), F, col)
			-- stepped round: a slightly wider, thinner band around the middle
			B:block(crop, v(s * 1.2, s * 0.55, s * 1.2), F, col)
			-- shine on the upper front-left corner
			B:block(crop, v(s * 0.34, s * 0.34, s * 0.2), F * CFrame.new(-s * 0.22, s * 0.25, -s * 0.52), BERRY_SH)
			if glint then
				local g = B:block(crop, v(0.2, 0.2, 0.1), F * CFrame.new(-s * 0.22, s * 0.25, -s * 0.62 - 0.02), "#f1e4ff", { mat = "Neon", name = "Glint" .. (#glints + 1) })
				table.insert(glints, g)
			end
		end
		-- a cluster hangs from a short twig poking out of the leaves; berries are
		-- given in the cluster's local frame {right, down, out, size, spin, colour, glint}
		local function cluster(deg, r, y, list)
			local a = math.rad(deg)
			local ox, oz = math.sin(a), math.cos(a)
			local rx, rz = oz, -ox
			bar(crop, v(ox * (r - 1.0), y + 0.55, oz * (r - 1.0)), v(ox * r, y + 0.2, oz * r), 0.26, 0.26, STEM_DK)
			for _, b in list do
				berry(ox * (r + b[3]) + rx * b[1] * 1.15, y + b[2] * 1.1, oz * (r + b[3]) + rz * b[1], b[4], deg + b[5], b[6] or BERRY, b[7])
			end
		end
		-- cluster(heading, radius, twig y, berries)  heading 180 = front (-Z)
		cluster(195, 4.3, 4.3, { { -0.55, -0.45, 0, 1.15, 10, BERRY, true }, { 0.6, -0.55, 0.1, 1.0, -15, BERRY_DK }, { 0.05, -1.4, -0.05, 1.0, 25 } })
		cluster(150, 4.5, 6.6, { { -0.5, -0.4, 0, 1.05, 5 }, { 0.55, -0.5, 0, 1.1, 30, BERRY_DK, true }, { 0, -1.35, 0, 0.9, -10 } })
		cluster(240, 4.4, 5.7, { { -0.5, -0.45, 0, 1.1, 15, BERRY_DK }, { 0.55, -0.5, 0, 1.0, -20, BERRY, true }, { 0, -1.4, 0, 0.95, 5 } })
		cluster(95, 4.4, 4.6, { { -0.5, -0.45, 0, 1.1, -5 }, { 0.55, -0.5, 0, 1.0, 25, BERRY_DK }, { 0, -1.4, 0, 0.95, 10, BERRY, true } })
		cluster(285, 4.3, 4.4, { { -0.5, -0.45, 0, 1.1, 0 }, { 0.55, -0.5, 0, 1.0, 20, BERRY_DK, true }, { 0, -1.35, 0, 0.9, -15 } })
		cluster(20, 4.4, 4.7, { { -0.5, -0.45, 0, 1.1, 10, BERRY_DK }, { 0.55, -0.5, 0, 1.0, -10 }, { 0, -1.4, 0, 0.95, 20 } })
		cluster(330, 4.0, 7.4, { { -0.5, -0.4, 0, 1.0, 0 }, { 0.5, -0.5, 0, 1.05, 20, BERRY_DK } })
		cluster(215, 4.4, 7.9, { { -0.5, -0.4, 0, 1.0, 10, BERRY_DK }, { 0.5, -0.5, 0, 1.05, -15, BERRY, true } })
		-- a little bunch sitting on top of the crown
		berry(-0.9, Y + 4.1, -0.6, 1.0, 20, BERRY, true)
		berry(0.2, Y + 4.0, -1.0, 0.9, -10, BERRY_DK)

		----------------------------------------------------------------- vfx
		if glints[1] then
			B:emitter(glints[1], "sparkle", { name = "BerrySparkle", color = { "#ffffff", "#c9a0ff" }, rate = 2, size = 0.3 })
			B:emitter(glints[5], "sparkle", { name = "BerrySparkle2", color = { "#e9d6ff", "#8f5cff" }, rate = 2, size = 0.28 })
			B:light(glints[2], { color = "#a070ff", brightness = 0.7, range = 8, name = "BerryGlow" })
		end
	end,
}
