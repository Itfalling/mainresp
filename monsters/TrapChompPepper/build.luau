--!nocheck
-- Chomp Pepper Plant (Flytrap Stage plant #5, Legendary).
-- A chunky pepper bush on a stepped bog-dirt mound (moss pads, stones, a
-- little bog puddle with a lily pad). A thick green stalk forks into a
-- compact crown of rotated studded leaf cubes dotted with tiny white pepper
-- blossoms. Hanging all around the crown are big glossy red peppers that are
-- little flytraps: each pepper is split down the front into two lobes that
-- gape open, showing a pink inside lined with interlocking cream teeth; a
-- few drip lime neon drool. Lime fireflies + one soft lime light.
-- Static prop: no motion.luau.
return {
	DisplayName = "Chomp Pepper Plant",
	Rarity = "Legendary",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Flytrap stage)
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local MUD = "#2e1d12"
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local BOG, BOG_LT = "#2f6a50", "#6fb58a"
		local GREEN, GREEN_DK, GREEN_LT, GREEN_TOP = "#3caa3c", "#1f6e2a", "#a6e04c", "#58c447"
		local STALK, STALK_DK = "#4f8f2a", "#356b22"
		local RED, RED_DK, RED_LT = "#e0261c", "#a8141a", "#ff6a4a"
		local INSIDE, INSIDE_DK = "#ff5c7c", "#b02448"
		local CREAM = "#fff4d2"
		local LIME = "#86ff3c"
		local PETAL, POLLEN = "#fffaf0", "#ffd23a"
		local NEON = { mat = "Neon" }

		local seed = 5521
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end

		---------------------------------------------------------------- mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.4, 2.2), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.7, 5.5, DIRT_DK, 15, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.7, 0.6, 3.7, DIRT, 10, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.3, 0.4, 2.3, DIRT_LT, 0, {}, 0)

		-- moss pads draped over the tier edges
		for _, m in { { 25, 3.75, 1.06, 2.0, MOSS }, { 140, 3.8, 1.05, 1.8, MOSS_DK }, { 215, 3.75, 1.06, 1.9, MOSS }, { 300, 5.5, 0.5, 2.2, MOSS_DK }, { 80, 5.55, 0.48, 1.9, MOSS } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], m[3], -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[4], 0.3, 1.3), c * ang(-12, 0, 0), m[5], S)
		end
		-- stones
		for _, s in { { 4.7, 0.85, 1.6, 0.9, 25, STONE }, { 5.1, 0.7, 2.6, 0.6, 10, STONE_LT }, { -4.4, 0.85, 2.8, 0.8, -20, STONE_DK }, { -1.4, 0.85, 5.0, 0.7, 40, STONE } } do
			B:block(soil, v(s[4] * 1.2, s[4], s[4]), cf(s[1], s[2], s[3], rnd(-10, 10), s[5], rnd(-10, 10)), s[6], S)
		end
		-- tiny grass tufts
		for _, g in { { 5.2, -1.6 }, { -2.6, -5.1 }, { -5.3, 0.4 }, { 3.0, 4.6 } } do
			B:block(soil, v(0.45, 0.9, 0.45), cf(g[1], 0.9, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.35, 0.6, 0.35), cf(g[1] + 0.35, 0.85, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end
		-- little bog puddle sunk into the front-right of the middle tier
		local BC = v(1.9, 1.32, -3.3)
		B:block(soil, v(2.2, 0.3, 1.4), CFrame.new(BC + v(0, -0.12, 0)) * ang(0, -18, 0), BOG, S)
		B:block(soil, v(1.3, 0.28, 2.0), CFrame.new(BC + v(0.05, -0.16, 0)) * ang(0, -18, 0), BOG, S)
		B:block(soil, v(0.8, 0.1, 0.3), CFrame.new(BC + v(-0.3, 0.05, -0.2)) * ang(0, -18, 0), BOG_LT, S)
		B:block(soil, v(0.7, 0.4, 0.6), CFrame.new(BC + v(1.25, 0.0, 0.35)) * ang(0, 20, 0), MUD, S)
		B:block(soil, v(0.8, 0.1, 0.8), CFrame.new(BC + v(0.35, 0.06, 0.15)) * ang(0, 30, 0), GREEN, S)
		B:block(soil, v(0.3, 0.12, 0.3), CFrame.new(BC + v(0.35, 0.1, 0.15)) * ang(0, 30, 0), GREEN_LT, S)

		---------------------------------------------------------------- stalk
		local Y0 = 1.7
		local crop = B:bone("Crop", "Root", v(0, Y0, 0))
		B:block(crop, v(2.4, 0.7, 2.4), cf(0, Y0 + 0.3, 0), STALK_DK)
		for i = 0, 3 do
			local a = i * 90 + 45
			B:block(crop, v(0.9, 0.6, 1.4), cf(0, Y0 + 0.2, 0, 0, a, 0) * CFrame.new(0, 0, -1.4) * ang(-12, 0, 0), STALK_DK)
		end
		B:block(crop, v(1.5, 2.2, 1.5), cf(0, Y0 + 1.6, 0), STALK)
		B:block(crop, v(1.25, 2.0, 1.25), cf(0.05, Y0 + 3.4, 0.05, 0, 8, 0), STALK)
		B:block(crop, v(0.3, 1.2, 0.7), cf(0.78, Y0 + 1.7, -0.1), GREEN_LT)
		B:block(crop, v(0.7, 0.9, 0.3), cf(-0.1, Y0 + 3.2, -0.66, 0, 8, 0), STALK_DK)
		-- forking branches into the crown
		local fork = v(0, Y0 + 3.4, 0)
		for _, b in { { 2.6, 5.2, -0.8 }, { -2.5, 5.3, -0.6 }, { 0.6, 5.2, 2.5 }, { -0.4, 5.0, -2.4 } } do
			B:bar(crop, fork, v(b[1], Y0 + b[2], b[3]), 0.8, 0.8, STALK)
		end
		B:block(crop, v(1.4, 1.0, 1.4), CFrame.new(fork) * ang(0, 20, 0), STALK)

		---------------------------------------------------------------- crown
		local cubes = {}
		local function leaf(x, y, z, s, rx, ry, rz, col)
			local c = cf(x, Y0 + y, z, rx, ry, rz)
			B:block(crop, v(s, s, s), c, col)
			table.insert(cubes, { cf = c, s = s })
		end
		leaf(0.0, 6.9, 0.0, 4.8, 8, 20, 6, GREEN)
		leaf(-2.9, 6.2, 0.7, 3.5, -12, 35, 14, GREEN_DK)
		leaf(3.0, 6.3, -0.5, 3.5, 14, -25, -10, GREEN)
		leaf(0.5, 6.0, 2.9, 3.3, 18, 10, -12, GREEN_DK)
		leaf(-0.5, 6.1, -2.9, 3.3, -16, -15, 10, GREEN_DK)
		leaf(-1.5, 8.2, -0.8, 3.3, 18, 35, -12, GREEN_TOP)
		leaf(1.6, 8.1, 1.1, 3.3, -12, 15, 15, GREEN_TOP)
		leaf(0.2, 9.1, 0.1, 2.4, 15, 25, 12, GREEN_LT)
		leaf(2.6, 7.7, -2.4, 2.8, 30, -35, 12, GREEN_TOP)
		leaf(-2.8, 7.6, 2.3, 2.8, 20, -20, 25, GREEN)

		-- tiny white pepper blossoms on the crown faces
		local function blossom(cIdx, lx, lz)
			local c = cubes[cIdx]
			local f = c.cf * CFrame.new(lx, c.s / 2, lz)
			for i = 0, 1 do
				B:block(crop, v(0.85, 0.2, 0.32), f * ang(0, i * 90 + 15, 0), PETAL)
			end
			B:block(crop, v(0.32, 0.3, 0.32), f * CFrame.new(0, 0.08, 0) * ang(0, 15, 0), POLLEN)
		end
		blossom(6, 0.6, -0.5)
		blossom(7, -0.7, 0.4)
		blossom(9, 0.2, 0.3)
		blossom(1, 1.4, -1.3)

		---------------------------------------------------------------- chomp peppers
		-- frame F: origin at the top of the calyx, pepper hangs down local -Y,
		-- its split mouth faces local -Z (outward). Each half is hinged at the
		-- back (local z = +0.75) and swung open.
		local SEGS = {
			-- y, w, h, d, color (all hinged at the back z = +0.7)
			{ -0.5, 1.7, 0.95, 1.55, RED },
			{ -1.45, 1.55, 1.0, 1.45, RED },
			{ -2.4, 1.2, 0.95, 1.15, RED_DK },
		}
		local function frontZ(y)
			for _, sg in SEGS do
				if y > sg[1] - sg[3] / 2 - 0.01 then
					return 0.7 - sg[4]
				end
			end
			return 0.7 - SEGS[#SEGS][4]
		end
		local drops = {}
		local function pepper(top, attach, yaw, tilt, s, open, drool)
			local F = CFrame.new(top) * CFrame.Angles(0, rad(yaw), 0) * CFrame.Angles(rad(tilt), 0, 0)
			local HZ = 0.7 * s
			local function at(Fr, x, y, z)
				return Fr * CFrame.new(x * s, y * s, z * s)
			end
			local function bk(bone, Fr, sx, sy, sz, x, y, z, col, opts)
				return B:block(bone, v(sx * s, sy * s, sz * s), at(Fr, x, y, z), col, opts)
			end
			for _, k in { -1, 1 } do
				local H = F * CFrame.new(0, 0, HZ) * CFrame.Angles(0, rad(-k * open), 0) * CFrame.new(0, 0, -HZ)
				for _, sg in SEGS do
					bk(crop, H, sg[2] / 2, sg[3], sg[4], k * sg[2] / 4, sg[1], 0.7 - sg[4] / 2, sg[5])
				end
				-- pink inside of the lobe
				bk(crop, H, 0.1, 1.85, 1.3, -k * 0.03, -1.0, 0.0, INSIDE)
				bk(crop, H, 0.1, 0.8, 0.9, -k * 0.03, -2.35, 0.15, INSIDE_DK)
				-- glossy highlight on the outer face
				bk(crop, H, 0.3, 0.6, 0.1, k * 0.48, -1.2, 0.7 - 1.45 - 0.04, RED_LT)
				-- cream teeth along the split: point forward + inward, interlocking
				local ys = (k < 0) and { -0.35, -1.0, -1.65, -2.3 } or { -0.65, -1.3, -1.95, -2.6 }
				for _, y in ys do
					local fz = frontZ(y)
					local base = at(H, -k * 0.06, y, fz + 0.12)
					local tcf = base * CFrame.Angles(0, rad(k * 38), 0) * CFrame.new(0, 0, -0.24 * s)
					B:block(crop, v(0.2 * s, 0.2 * s, 0.6 * s), tcf, CREAM)
				end
			end
			-- closed tapering tip curling outward
			bk(crop, F, 0.8, 0.75, 0.8, 0, -3.25, 0.25, RED_DK)
			bk(crop, F, 0.55, 0.55, 0.55, 0, -3.8, 0.0, RED_DK)
			bk(crop, F, 0.35, 0.4, 0.4, 0, -4.15, -0.3, RED)
			-- calyx + sepals + pedicel
			bk(crop, F, 1.3, 0.45, 1.3, 0, -0.02, 0.05, GREEN_DK)
			for i = 0, 3 do
				local a = i * 90 + 45
				local c = F * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, -0.22 * s, -0.75 * s) * ang(-25, 0, 0)
				B:block(crop, v(0.55 * s, 0.22 * s, 0.6 * s), c, GREEN)
			end
			local stemTop = F:PointToWorldSpace(v(0, 0.55 * s, 0.1 * s))
			B:block(crop, v(0.45 * s, 0.6 * s, 0.45 * s), at(F, 0, 0.35, 0.05), STALK)
			B:bar(crop, stemTop, attach, 0.38, 0.38, STALK)
			-- lime drool off the bottom of the split
			if drool then
				local lip = F:PointToWorldSpace(v(0, -2.75 * s, -0.35 * s))
				B:block(crop, v(0.18, 0.8, 0.18), CFrame.new(lip + v(0, -0.35, 0)), LIME, NEON)
				local drop = B:block(crop, v(0.34, 0.38, 0.34), CFrame.new(lip + v(0, -0.88, 0)), LIME, { mat = "Neon", name = "DroolDrop" .. (#drops + 1) })
				table.insert(drops, drop)
			end
		end
		local PEPS = {
			-- angle, radius, topY, scale, open, tilt, drool
			{ -8, 4.9, 4.7, 1.12, 30, 10, true },
			{ 58, 5.0, 4.9, 1.0, 22, 12, false },
			{ 122, 4.9, 4.6, 1.05, 28, 10, true },
			{ 182, 4.9, 4.9, 1.0, 22, 12, false },
			{ -122, 5.0, 4.6, 1.05, 28, 10, false },
			{ -62, 4.9, 5.0, 1.0, 22, 12, false },
		}
		for _, p in PEPS do
			local a = rad(p[1])
			local dir = v(math.sin(a), 0, -math.cos(a))
			local top = dir * p[2] + v(0, Y0 + p[3], 0)
			local attach = dir * (p[2] - 1.5) + v(0, Y0 + p[3] + 1.0, 0)
			pepper(top, attach, -p[1], p[6], p[4], p[5], p[7])
		end

		---------------------------------------------------------------- bling
		B:emitter(drops[1], "drip", { name = "DroolDrip", color = LIME, rate = 0.8, size = { 0.25, 0.2, 0.1 } })
		B:emitter(drops[2] or drops[1], "drip", { name = "DroolDrip2", color = LIME, rate = 0.6, size = { 0.25, 0.2, 0.1 } })
		local ff = B:block(crop, v(6, 2, 6), cf(0, Y0 + 7.5, 0), GREEN, { tr = 1, name = "FireflyZone" })
		B:emitter(ff, "sparkle", { name = "Fireflies", color = { "#e8ff6a", LIME }, rate = 3, size = 0.3 })
		B:light(drops[1], { color = LIME, brightness = 0.8, range = 8, name = "DroolLight" })
	end,
}
