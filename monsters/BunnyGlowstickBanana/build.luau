--!nocheck
-- Glowstick Banana Palm (Bunny Stage plant #4, Epic).
-- A party palm in the stud-tree style: stepped dirt mound with little
-- glowsticks stuck in it like garden lights, a chunky ringed palm trunk that
-- leans gently, a crown of big studded drooping fronds around a leaf-cube
-- heart, and three banana bunches (pink / lime / yellow) whose bananas glow
-- like snapped glowsticks: bright plastic bodies with neon tips.
-- Static prop: no motion.luau.
return {
	DisplayName = "Glowstick Banana Palm",
	Rarity = "Epic",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		local DIRT_DK, DIRT, DIRT_LT = "#3f2516", "#5a3520", "#734626"
		local BARK_DK, BARK, BARK_LT = "#6b4224", "#8d5c33", "#a8743f"
		local GRASS, GRASS_DK = "#5fd23c", "#3fa82a"
		local LEAF_LT, LEAF, LEAF_DK, RIB = "#4fcf5a", "#2fae45", "#1f8636", "#8fe08a"
		local STALK = "#4f7a2a"
		-- glowstick colours: { plastic body, neon tip }
		local GLOW = {
			{ "#ff3fae", "#ff5fd2" }, -- pink
			{ "#a8f02a", "#8bff4a" }, -- lime
			{ "#ffd21f", "#ffe94a" }, -- yellow
		}

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
		oct(9.0, 0.6, 0.3, DIRT_DK)
		ring(4.5, 14, 2.1, 0.75, 1.3, { DIRT_DK, "#4b2c19", DIRT_DK, "#352013" }, 5)
		oct(6.6, 0.55, 0.85, DIRT)
		ring(3.2, 10, 1.9, 0.6, 1.1, { DIRT, "#64391f" }, 18, 0.65)
		oct(4.2, 0.4, 1.35, DIRT_LT)
		-- grass tufts
		B:block(soil, v(0.45, 0.9, 0.45), cf(4.4, 0.45, -3.4, 0, 20, 0), GRASS, S)
		B:block(soil, v(0.4, 0.6, 0.4), cf(4.9, 0.3, -2.9, 0, 5, 0), GRASS_DK, S)
		B:block(soil, v(0.45, 0.8, 0.45), cf(-4.8, 0.4, 2.8, 0, -10, 0), GRASS, S)
		B:block(soil, v(0.4, 0.55, 0.4), cf(-4.2, 0.28, 3.6, 0, 30, 0), GRASS_DK, S)
		-- glowsticks stuck in the mound like little party garden lights
		local function stick(deg, r, tilt, g)
			local a = math.rad(deg)
			local x, z = math.sin(a) * r, math.cos(a) * r
			local F = cf(x, 1.2, z, 0, deg, 0) * CFrame.Angles(math.rad(tilt), 0, 0)
			B:block(soil, v(0.45, 1.8, 0.45), F * CFrame.new(0, 0.55, 0), GLOW[g][1], S)
			B:block(soil, v(0.5, 0.45, 0.5), F * CFrame.new(0, 1.6, 0), GLOW[g][2], { name = "Soil", mat = "Neon" })
		end
		stick(30, 2.6, 18, 1)
		stick(150, 2.7, 15, 2)
		stick(265, 2.6, 20, 3)

		----------------------------------------------------------------- trunk
		local crop = B:bone("Crop", "Root", v(0, 1.6, 0))
		B:block(crop, v(3.2, 0.6, 3.2), cf(0, 1.75, 0, 0, 15, 0), BARK_DK)
		B:block(crop, v(2.6, 0.6, 2.6), cf(0, 2.3, 0, 0, 40, 0), BARK)
		B:block(crop, v(2.2, 0.5, 2.2), cf(0, 2.8, 0, 0, 5, 0), BARK_LT)
		-- ringed palm trunk: stacked chunky segments, alternating shade, gentle lean to +X
		local segs = 7
		local y0, segH = 3.0, 1.0
		local function trunkAt(k) -- centre of segment k
			return 0.05 * k * k, y0 + (k - 0.5) * segH, -0.02 * k * k
		end
		for k = 1, segs do
			local x, y, z = trunkAt(k)
			local w = 1.9 - k * 0.05
			B:block(crop, v(w, segH + 0.06, w), cf(x, y, z, 0, 0, -k * 1.2), (k % 2 == 0) and BARK_LT or BARK)
			-- slightly wider dark ring lip at the bottom of each segment (palm bark rings)
			B:block(crop, v(w + 0.3, 0.3, w + 0.3), cf(x, y - segH * 0.5 + 0.12, z, 0, 0, -k * 1.2), BARK_DK)
		end
		-- glowstick bracelets snapped around the trunk
		for i, b in { { 3, 1 }, { 5, 2 } } do
			local x, y, z = trunkAt(b[1])
			B:ring(crop, cf(x, y + 0.1, z, 0, 0, -b[1] * 1.2), 1.02, 8, v(0.9, 0.3, 0.22), GLOW[b[2]][2], { mat = "Neon" })
		end
		local tx, ty, tz = trunkAt(segs)
		ty += segH * 0.5

		----------------------------------------------------------------- crown
		-- leaf-cube heart where the fronds sprout
		B:block(crop, v(3.0, 3.0, 3.0), cf(tx, ty + 0.6, tz, 15, 30, 10), LEAF_DK)
		B:block(crop, v(2.4, 2.4, 2.4), cf(tx + 0.3, ty + 1.6, tz - 0.2, -10, 10, 20), LEAF)
		B:block(crop, v(1.8, 1.8, 1.8), cf(tx - 0.2, ty + 2.4, tz + 0.2, 20, 45, -15), LEAF_LT)
		-- big chunky drooping fronds: 3 stepped slabs each (wide -> narrow), droop increasing
		local function frond(deg, len, lift, y, col, colTip, w)
			w = w or 1
			local a = math.rad(deg)
			local dx, dz = math.sin(a), math.cos(a)
			local p0 = v(tx + dx * 0.6, ty + y, tz + dz * 0.6)
			local p1 = p0 + v(dx * len * 0.42, lift, dz * len * 0.42)
			local p2 = p1 + v(dx * len * 0.33, -0.8, dz * len * 0.33)
			local p3 = p2 + v(dx * len * 0.25, -1.5, dz * len * 0.25)
			B:beam(crop, p0, p1 + v(dx * 0.4, 0, dz * 0.4), 3.0 * w, 0.9, col)
			B:beam(crop, p1 - v(dx * 0.2, 0, dz * 0.2), p2 + v(dx * 0.3, 0, dz * 0.3), 2.5 * w, 0.8, col)
			B:beam(crop, p2 - v(dx * 0.2, 0, dz * 0.2), p3, 1.7 * w, 0.7, colTip)
			-- pale midrib strip along the top of the first two slabs
			B:beam(crop, p0 + v(0, 0.47, 0), p1 + v(dx * 0.3, 0.47, dz * 0.3), 0.4, 0.1, RIB)
			B:beam(crop, p1 + v(0, 0.42, 0), p2 + v(dx * 0.2, 0.42, dz * 0.2), 0.35, 0.1, RIB)
		end
		-- upper ring
		frond(0, 5.6, 0.9, 1.6, LEAF, LEAF_LT)
		frond(72, 5.4, 1.1, 1.7, LEAF_DK, LEAF)
		frond(144, 5.8, 0.9, 1.6, LEAF, LEAF_LT)
		frond(216, 5.5, 1.0, 1.7, LEAF_DK, LEAF)
		frond(288, 5.7, 0.9, 1.6, LEAF, LEAF_LT)
		-- lower ring, between the banana bunches, droops more
		frond(60, 5.0, 0.3, 0.9, LEAF_DK, LEAF_DK, 0.9)
		frond(180, 5.2, 0.3, 0.9, LEAF_DK, LEAF, 0.9)
		frond(300, 5.0, 0.3, 0.9, LEAF_DK, LEAF_DK, 0.9)
		-- short upright young fronds poking out of the top
		local function shoot(deg, col)
			local a = math.rad(deg)
			B:beam(crop, v(tx, ty + 2.0, tz), v(tx + math.sin(a) * 1.5, ty + 3.5, tz + math.cos(a) * 1.5), 1.4, 0.6, col)
		end
		shoot(20, LEAF_LT)
		shoot(140, LEAF)
		shoot(260, LEAF_LT)

		----------------------------------------------------------------- glowstick banana bunches
		local tips = {}
		local function bunch(deg, g, y)
			local a = math.rad(deg)
			local bx, bz = tx + math.sin(a) * 2.0, tz + math.cos(a) * 2.0
			local body, tip = GLOW[g][1], GLOW[g][2]
			-- stalk hanging from the crown
			B:beam(crop, v(tx + math.sin(a) * 0.6, ty + 0.4, tz + math.cos(a) * 0.6), v(bx, y - 0.4, bz), 0.6, 0.6, STALK)
			for tier = 0, 1 do
				local ty2 = y + 0.8 - tier * 1.2
				for k = 0, 4 do
					local phi = a + math.rad((k - 2) * 38 + tier * 19)
					local ox, oz = math.sin(phi), math.cos(phi)
					-- banana: points outward then curls up, neon glowstick tip
					local p0 = v(bx + ox * 0.2, ty2, bz + oz * 0.2)
					local p1 = p0 + v(ox * 1.3, 0.8, oz * 1.3)
					local p2 = p1 + v(ox * 0.25, 0.7, oz * 0.25)
					B:beam(crop, p0, p1, 0.75, 0.75, body)
					local t = B:beam(crop, p1 - v(ox * 0.15, 0.12, oz * 0.15), p2, 0.5, 0.5, tip, { mat = "Neon" })
					table.insert(tips, t)
				end
			end
			-- dark bud at the bottom of the bunch
			B:block(crop, v(0.8, 0.9, 0.8), cf(bx, y - 1.0, bz, 0, deg + 45, 0), "#6b2a5a")
		end
		bunch(125, 1, ty - 2.5)
		bunch(235, 2, ty - 2.4)
		bunch(0, 3, ty - 2.5)

		----------------------------------------------------------------- vfx
		B:emitter(tips[2], "sparkle", { name = "PinkSparkle", color = { "#ffffff", "#ff8fd8" }, rate = 3, size = 0.35 })
		B:emitter(tips[13], "sparkle", { name = "LimeSparkle", color = { "#ffffff", "#b8ff7a" }, rate = 3, size = 0.35 })
		B:emitter(tips[23], "sparkle", { name = "GoldSparkle", color = { "#ffffff", "#ffe56a" }, rate = 3, size = 0.35 })
		B:light(tips[8], { color = "#ff9be6", brightness = 1.0, range = 10, name = "GlowstickLight" })
	end,
}
