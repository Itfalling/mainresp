--!nocheck
-- Pitcher Pod Plant (Flytrap Stage plant #2, Uncommon).
-- Three chunky stepped pitcher-plant pods rising from a low leaf rosette on a
-- stepped bog-dirt mound (moss pads, a murky puddle with a lily pad, cattails,
-- stones, grass tufts). Each pod is a stepped cup: green foot and belly, a
-- lime-green upper body with bold red vertical stripes, a red neck, a pink-red
-- rim and a hooded lid (green on top, red veined underneath) propped open at
-- the back. The cups brim with glowing lime nectar, one drop spilling over
-- each rim. Static prop: no motion.luau.
return {
	DisplayName = "Pitcher Pod Plant",
	Rarity = "Uncommon",
	Element = "Bog",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (shared with the Flytrap section)
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local MUD = "#2e1d12"
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local BOG, BOG_LT, PAD = "#2f6a50", "#6fb58a", "#3caa3c"
		local REED, CATTAIL = "#7f8f3a", "#5a3a1e"
		local GREEN_DK, GREEN, GREEN_LT, GREEN_TOP = "#1f6e2a", "#3caa3c", "#9fd84a", "#58c447"
		local RED, RED_DK, RIM, HOOD = "#c92a48", "#8e1a33", "#ff5c7c", "#ff6d8a"
		local NECTAR = "#a6ff3c"

		local seed = 1222
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end

		------------------------------------------------------------ soil mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH, skip)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				if skip and a > skip[1] and a < skip[2] then continue end
				local w, d = rnd(1.4, 2.1), rnd(1.1, 1.5)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.3)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.75, 4.0, DIRT_DK, 10, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35, { -25, 25 })
		tier(0.75, 0.55, 2.8, DIRT, 6, { DIRT, DIRT_LT, DIRT }, 0.25)
		tier(1.3, 0.35, 1.8, DIRT_LT, 0, {}, 0)

		-- moss pads draped over the lower tier edge
		for _, m in { { 60, 3.95, 1.8, MOSS }, { 150, 4.0, 1.6, MOSS_DK }, { 230, 3.95, 1.9, MOSS }, { 300, 4.0, 1.5, MOSS_DK } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], 0.87, -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[3], 0.3, 1.2), c * ang(-14, 0, 0), m[4], S)
		end
		-- bog puddle at the front with a lily pad, mud lumps and two cattails
		local BC = v(0.1, 0.8, -3.4)
		B:block(soil, v(2.6, 0.16, 1.3), CFrame.new(BC), BOG, S)
		B:block(soil, v(1.5, 0.14, 1.9), CFrame.new(BC + v(0.2, -0.02, 0.05)), BOG, S)
		B:block(soil, v(0.9, 0.08, 0.25), CFrame.new(BC + v(0.5, 0.07, -0.2)), BOG_LT, S)
		B:block(soil, v(0.8, 0.1, 0.8), CFrame.new(BC + v(-0.55, 0.09, 0.05)) * ang(0, 25, 0), PAD, S)
		B:block(soil, v(0.8, 0.45, 0.6), CFrame.new(BC + v(-1.55, 0.05, 0.1)) * ang(0, 20, 0), MUD, S)
		B:block(soil, v(0.7, 0.4, 0.6), CFrame.new(BC + v(1.6, 0.05, 0.05)) * ang(0, -15, 0), MUD, S)
		local CT = v(-3.0, 0.75, 1.9)
		B:block(soil, v(0.2, 2.2, 0.2), CFrame.new(CT + v(0, 1.1, 0)) * ang(0, 0, 6), REED, S)
		B:block(soil, v(0.38, 0.7, 0.38), CFrame.new(CT + v(-0.13, 2.05, 0)) * ang(0, 0, 6), CATTAIL, S)
		B:block(soil, v(0.2, 1.6, 0.2), CFrame.new(CT + v(0.4, 0.8, 0.25)) * ang(-6, 0, -8), REED, S)
		-- stones
		B:block(soil, v(1.0, 0.75, 0.85), cf(3.3, 1.0, 1.9, 6, 25, -8), STONE, S)
		B:block(soil, v(0.6, 0.5, 0.55), cf(3.75, 0.85, 1.1, -5, 50, 6), STONE_LT, S)
		B:block(soil, v(0.8, 0.6, 0.7), cf(-3.4, 0.9, -1.6, 4, -20, 6), STONE_DK, S)
		-- tiny grass tufts
		for _, g in { { 4.1, -1.0 }, { -1.4, 4.0 }, { 2.0, 3.7 } } do
			B:block(soil, v(0.38, 0.85, 0.38), cf(g[1], 0.65, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.3, 0.55, 0.3), cf(g[1] + 0.28, 0.5, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end
		local bub = B:block(soil, v(1.6, 0.1, 1.0), CFrame.new(BC + v(0, 0.06, 0)), BOG, { tr = 1, name = "Soil" })
		B:emitter(bub, "bubble", { name = "BogBubbles", color = { "#bfffb0", NECTAR }, rate = 1.2, size = { 0.15, 0.3, 0.35 }, speed = { 0.3, 0.7 } })

		------------------------------------------------------------ rosette
		local crop = B:bone("Crop", "Root", v(0, 1.65, 0))
		B:block(crop, v(1.6, 0.6, 1.6), cf(0, 1.9, 0, 0, 45, 0), GREEN_DK)
		local function blade(a, len, w, up, col)
			local f = CFrame.new(0.5 * math.sin(rad(a)), 1.85, -0.5 * math.cos(rad(a))) * CFrame.Angles(0, -rad(a), 0) * CFrame.Angles(rad(up), 0, 0)
			B:block(crop, v(w, 0.35, len * 0.6), f * CFrame.new(0, 0, -len * 0.3), col)
			local f2 = f * CFrame.new(0, 0, -len * 0.58) * CFrame.Angles(rad(-22), 0, 0)
			B:block(crop, v(w * 0.65, 0.35, len * 0.36), f2 * CFrame.new(0, 0, -len * 0.16), col)
		end
		blade(0, 2.6, 1.3, 18, GREEN)
		blade(72, 2.8, 1.4, 22, GREEN_DK)
		blade(144, 2.6, 1.3, 26, GREEN)
		blade(216, 2.8, 1.4, 22, GREEN_DK)
		blade(288, 2.6, 1.3, 18, GREEN_TOP)
		-- a few chunky leaf cubes tucked between the pod feet for mass
		local heart = B:block(crop, v(1.45, 1.45, 1.45), cf(0.1, 2.2, -1.35, 18, 35, 14), GREEN)
		B:block(crop, v(1.6, 1.6, 1.6), cf(-1.75, 2.1, 1.35, -10, 20, 14), GREEN)
		B:block(crop, v(1.6, 1.6, 1.6), cf(1.85, 2.1, 1.3, 14, -25, -10), GREEN_DK)

		------------------------------------------------------------ pitcher pods
		local nectars, lids = {}, {}
		-- base: foot position on the mound; yaw: direction the mouth faces (0 = -Z);
		-- tilt: lean outward (deg); s: scale
		local function pod(base, yaw, tilt, s, idx)
			local F = CFrame.new(base) * CFrame.Angles(0, -rad(yaw), 0) * CFrame.Angles(-rad(tilt), 0, 0)
			local function at(x, y, z) return F * CFrame.new(x * s, y * s, z * s) end
			-- stepped tube body: narrow green foot widening up to a lime, red-veined top
			B:block(crop, v(0.9 * s, 0.4 * s, 0.9 * s), at(0, 0.2, 0), GREEN_DK)
			B:block(crop, v(1.1 * s, 1.1 * s, 1.1 * s), at(0, 0.95, 0), GREEN)
			B:block(crop, v(1.4 * s, 1.1 * s, 1.4 * s), at(0, 2.05, 0), GREEN)
			B:block(crop, v(1.75 * s, 1.3 * s, 1.75 * s), at(0, 3.25, 0), GREEN_LT)
			-- bold red vertical veins (each block shows on two opposite faces)
			for _, k in { -0.38, 0.38 } do
				B:block(crop, v(0.24 * s, 1.3 * s + 0.06, 1.75 * s + 0.08), at(k, 3.25, 0), RED)
				B:block(crop, v(1.75 * s + 0.08, 1.3 * s + 0.06, 0.24 * s), at(0, 3.25, k), RED)
			end
			-- red neck + flared pink-red rim (hollow square ring)
			B:block(crop, v(1.6 * s, 0.35 * s, 1.6 * s), at(0, 4.075, 0), RED)
			local rt, rw, rh, ry = 0.38, 2.1, 0.4, 4.45
			B:block(crop, v(rw * s, rh * s, rt * s), at(0, ry, -(rw - rt) / 2), RIM)
			B:block(crop, v(rw * s, rh * s, rt * s), at(0, ry, (rw - rt) / 2), RIM)
			B:block(crop, v(rt * s, rh * s - 0.04, (rw - 2 * rt) * s + 0.02), at(-(rw - rt) / 2, ry, 0), RIM)
			B:block(crop, v(rt * s, rh * s - 0.04, (rw - 2 * rt) * s + 0.02), at((rw - rt) / 2, ry, 0), RIM)
			-- brimming glowing nectar + one drop spilling over the front rim
			table.insert(nectars, B:block(crop, v(1.36 * s, 0.3 * s, 1.36 * s), at(0, 4.4, 0), NECTAR, { mat = "Neon", name = "Nectar" .. idx }))
			B:block(crop, v(0.28 * s, 0.6 * s, 0.14), at(0.35, 4.2, -rw / 2 - 0.07 / s), NECTAR, { mat = "Neon", name = "NectarDrip" .. idx })
			-- hooded lid hinged at the back of the rim, leaning over the mouth
			local H = at(0, 4.62, 0.9) * CFrame.Angles(rad(58), 0, 0)
			local L = 1.7 * s
			table.insert(lids, B:block(crop, v(1.7 * s, 0.32, L), H * CFrame.new(0, 0.16, -L / 2), GREEN_LT))
			B:block(crop, v(1.1 * s, 0.32, 0.6 * s), H * CFrame.new(0, 0.16, -L - 0.25 * s), GREEN_LT)
			B:block(crop, v(1.3 * s, 0.3, L * 0.85), H * CFrame.new(0, -0.05, -L / 2 - 0.1), HOOD)
			B:block(crop, v(0.26 * s, 0.32, L * 0.7), H * CFrame.new(0, 0.2, -L / 2), RED_DK)
			-- stalk from the rosette heart down into the foot
			B:bar(crop, v(0, 1.95, 0), (at(0, 0.3, 0)).Position, 0.55, 0.55, GREEN_DK)
		end
		pod(v(0, 1.65, 1.1), 0, 6, 1.2, 1)
		pod(v(-2.0, 1.3, -0.8), -40, 12, 0.92, 2)
		pod(v(2.1, 1.3, -0.6), 45, 10, 1.0, 3)

		------------------------------------------------------------ fx
		B:emitter(nectars[1], "glow", { name = "NectarGlow", color = { "#d8ff8a", NECTAR }, rate = 1.5, size = 0.6, speed = { 0.2, 0.5 } })
		B:emitter(nectars[3], "sparkle", { name = "NectarSparkle", color = { "#eaffb0", "#a6ff3c" }, rate = 2.5, size = 0.3 })
		B:light(heart, { color = "#c8ff7a", brightness = 0.7, range = 9, name = "NectarLight" })
	end,
}
