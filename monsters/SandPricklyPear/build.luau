--!nocheck
-- Prickly Pear Stack (Sandy Savanna plant #2, Uncommon).
-- A tall stacked paddle cactus (opuntia) on a stepped golden sand mound with
-- sandstone rocks, dry grass tufts, pebbles, a fallen baby pad and a dropped
-- fruit. Jade-green oval pads (stepped "plus" ovals with a lighter inner panel
-- and cream areole dots) branch up and outward from one another, fanning in
-- different directions so the stack reads from every side. Plump magenta
-- prickly-pear fruits (stepped octagon blocks with a dark dimple cap) line the
-- top rims, and bright yellow cactus flowers with glowing orange hearts open
-- on the highest pads. Static prop: no motion.luau.
return {
	DisplayName = "Prickly Pear Stack",
	Rarity = "Uncommon",
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
		local PAD_DK, PAD, PAD_LT, PAD_RIM = "#409352", "#5cb262", "#84cc6e", "#a4da7c"
		local AREOLE = "#fbefc0"
		local FRUIT_DK, FRUIT, FRUIT_LT, FRUIT_CAP = "#a8124f", "#d81f6e", "#ff4f9c", "#7c0f3a"
		local PET_DK, PET, PET_LT, HEART = "#f2a81e", "#ffd23a", "#fff09a", "#ff9a2a"

		local seed = 1421
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
		tier(0, 0.75, 4.5, SAND_DK, 12, { SAND_DK, SAND_DK2, SAND_DK }, 0.35)
		tier(0.75, 0.55, 3.2, SAND, 7, { SAND, SAND_LT, SAND }, 0.25)
		tier(1.3, 0.35, 2.0, SAND_LT, 0, {}, 0)
		B:block(soil, v(1.5, 0.14, 1.1), cf(1.0, 1.7, -1.1, 0, -25, 0), SAND_TOP, S)

		local function rock(x, z, y, s, yaw)
			local c = CFrame.new(x, y, z) * ang(0, yaw, 0)
			B:block(soil, v(1.4 * s, 0.8 * s, 1.1 * s), c * CFrame.new(0, 0.4 * s, 0), ROCK, S)
			B:block(soil, v(1.0 * s, 0.5 * s, 0.8 * s), c * CFrame.new(0.15 * s, 1.0 * s, -0.05 * s) * ang(0, 12, 0), ROCK_LT, S)
			B:block(soil, v(1.55 * s, 0.25 * s, 1.2 * s), c * CFrame.new(0, 0.12 * s, 0), ROCK_DK, S)
		end
		rock(3.4, 1.8, 0.75, 1.0, -20)
		rock(-3.7, -0.6, 0.75, 0.7, 35)
		B:block(soil, v(0.55, 0.4, 0.5), cf(3.9, 0.95, -0.6, 0, 40, 0), PEBBLE, S)
		B:block(soil, v(0.45, 0.35, 0.45), cf(-1.9, 1.47, -1.7, 0, 15, 0), PEBBLE_DK, S)
		B:block(soil, v(0.5, 0.35, 0.4), cf(-1.0, 0.92, 3.7, 0, 60, 0), PEBBLE, S)
		-- shell
		B:block(soil, v(0.7, 0.25, 0.6), cf(2.6, 1.0, -3.1, 0, -30, 0), SHELL, S)
		B:block(soil, v(0.45, 0.3, 0.4), cf(2.6, 1.08, -3.1, 0, -30, 0), SHELL_PK, S)
		local function tuft(x, z, y)
			local base = CFrame.new(x, y, z) * ang(0, rnd(0, 90), 0)
			B:block(soil, v(0.3, 1.2, 0.3), base * CFrame.new(0, 0.5, 0), GRASS, S)
			B:block(soil, v(0.28, 1.0, 0.28), base * CFrame.new(0.25, 0.4, 0) * ang(0, 0, -25), GRASS_LT, S)
			B:block(soil, v(0.28, 0.9, 0.28), base * CFrame.new(-0.25, 0.35, 0.05) * ang(0, 0, 25), GRASS_DK, S)
		end
		tuft(-4.3, 1.4, 0.6)
		tuft(1.6, 4.2, 0.6)
		tuft(-2.9, -3.3, 0.6)
		tuft(4.4, -2.0, 0.6)
		-- a fallen baby pad lying on the sand (front-left) + a dropped fruit
		B:block(soil, v(1.5, 0.4, 1.0), cf(-2.4, 1.45, -2.3, 0, 30, 6), PAD, S)
		B:block(soil, v(1.0, 0.42, 1.4), cf(-2.4, 1.45, -2.3, 0, 30, 6), PAD, S)
		B:block(soil, v(0.6, 0.6, 0.6), cf(-0.2, 1.95, -1.8, 0, 20, 0), FRUIT, S)
		B:block(soil, v(0.45, 0.75, 0.45), cf(-0.2, 1.95, -1.8, 0, 65, 0), FRUIT_LT, S)

		------------------------------------------------------------ pads
		local crop = B:bone("Crop", "Root", v(0, 1.65, 0))
		-- pad frame: origin at the pad's bottom joint, +Y up the pad, Z = pad normal
		local function pad(F, w, h)
			local t = 0.8
			local c = F * CFrame.new(0, h / 2, 0)
			B:block(crop, v(w, h * 0.66, t), c, PAD)
			B:block(crop, v(w * 0.66, h, t + 0.02), c, PAD)
			B:block(crop, v(w * 0.86, h * 0.86, t - 0.04), c, PAD_DK)
			B:block(crop, v(w * 0.5, h * 0.55, t + 0.14), c * CFrame.new(0, h * 0.04, 0), PAD_LT)
			-- rim highlight on top
			B:block(crop, v(w * 0.42, 0.3, t + 0.06), F * CFrame.new(0, h - 0.12, 0), PAD_RIM)
			-- areoles (front + back faces)
			local spots = { { -0.3, 0.32, -1 }, { 0.32, 0.6, -1 }, { -0.05, 0.78, 1 }, { 0.3, 0.25, 1 } }
			for _, sp in spots do
				B:block(crop, v(0.24, 0.24, 0.2), F * CFrame.new(sp[1] * w, sp[2] * h, sp[3] * (t / 2 + 0.08)), AREOLE)
			end
			return F
		end
		-- point on the pad rim (theta 90 = top centre), returned as a frame
		-- whose +Y points outward from the rim
		local function rim(F, w, h, theta, inset)
			inset = inset or 0.88
			local x = math.cos(rad(theta)) * w / 2 * inset
			local y = h / 2 + math.sin(rad(theta)) * h / 2 * inset
			local out = (F - F.Position) * v(math.cos(rad(theta)) * h, math.sin(rad(theta)) * w, 0).Unit
			local p = F * v(x, y, 0)
			return p, out
		end
		local function child(F, w, h, theta, yaw, tilt)
			local p = rim(F, w, h, theta, 0.78)
			return CFrame.new(p) * ang(0, yaw, 0) * ang(0, 0, tilt)
		end

		local function addPad(F, w, h)
			pad(F, w, h)
			return { F = F, w = w, h = h }
		end
		local function grow(par, theta, yaw, tilt, w, h)
			return addPad(child(par.F, par.w, par.h, theta, yaw, tilt), w, h)
		end
		-- front fan (broad faces toward -Z) + a side fan (faces toward +-X)
		local P1 = addPad(cf(0, 1.3, -0.2), 3.8, 4.1)
		local P8 = addPad(cf(0.1, 1.3, 0.55) * ang(0, 90, 0) * ang(0, 0, -10), 3.4, 3.8)
		local P2 = grow(P1, 132, 12, 30, 3.4, 3.8)
		local P3 = grow(P1, 50, -12, -24, 3.4, 3.7)
		local P4 = grow(P2, 92, -8, 10, 3.0, 3.4)
		local P5 = grow(P3, 96, 14, -4, 3.1, 3.5)
		local P10 = grow(P5, 100, 65, 4, 2.6, 2.9)
		local P6 = grow(P2, 165, 0, 66, 2.4, 2.8)
		local P7 = grow(P3, 14, 0, -64, 2.4, 2.9)
		local P9 = grow(P8, 58, 100, -34, 3.0, 3.4)
		local P11 = grow(P8, 138, 80, 38, 2.7, 3.1)

		------------------------------------------------------------ fruit
		local function fruit(F, w, h, theta, s)
			local p, out = rim(F, w, h, theta, 0.9)
			local up = (out + v(0, 1.2, 0)).Unit
			local c = P.aim(p, p + up) * CFrame.new(0, 0, -0.35 * s)
			-- aim frame: -Z along `up`; turn so +Y of the fruit points along `up`
			local C = c * ang(-90, 0, 0) * ang(0, rnd(0, 45), 0)
			B:block(crop, v(0.85 * s, 1.0 * s, 0.85 * s), C, FRUIT)
			B:block(crop, v(0.62 * s, 1.22 * s, 0.62 * s), C * ang(0, 45, 0), FRUIT_LT)
			B:block(crop, v(0.5 * s, 0.2 * s, 0.5 * s), C * CFrame.new(0, 0.6 * s, 0), FRUIT_CAP)
		end
		local function fruits(pd, list)
			for _, th in list do
				fruit(pd.F, pd.w, pd.h, th, rnd(0.95, 1.1))
			end
		end
		fruits(P1, { 12, 168 })
		fruits(P2, { 105 })
		fruits(P3, { 75 })
		fruits(P4, { 35, 150 })
		fruits(P5, { 40, 150 })
		fruits(P6, { 45, 125 })
		fruits(P7, { 60, 140 })
		fruits(P8, { 25, 160 })
		fruits(P9, { 35, 140 })
		fruits(P10, { 30, 150 })
		fruits(P11, { 50, 130 })

		------------------------------------------------------------ flowers
		local hearts = {}
		local function flower(pd, theta, s, idx)
			local p, out = rim(pd.F, pd.w, pd.h, theta, 0.92)
			local n = (out + v(0, 1.4, 0)).Unit
			local F = P.aim(p, p + n) * ang(0, 0, rnd(0, 45))
			B:block(crop, v(0.9 * s, 0.9 * s, 0.6), F * CFrame.new(0, 0, 0.15), PAD_RIM)
			B:block(crop, v(1.7 * s, 1.7 * s, 0.34), F * CFrame.new(0, 0, -0.2) * ang(0, 0, 45), PET_DK)
			-- four cupped petals tipping up and out (frame -Z = flower normal)
			for k = 0, 3 do
				local G = F * ang(0, 0, k * 90)
				B:block(crop, v(1.15 * s, 1.25 * s, 0.26), G * CFrame.new(0, 0.62 * s, -0.42) * ang(-38, 0, 0), k % 2 == 0 and PET or PET_LT)
			end
			table.insert(hearts, B:block(crop, v(0.55 * s, 0.55 * s, 0.4), F * CFrame.new(0, 0, -0.45), HEART, { mat = "Neon", name = "PearBloom" .. idx }))
		end
		flower(P10, 90, 1.1, 1)
		flower(P4, 95, 1.0, 2)
		flower(P9, 85, 0.95, 3)
		flower(P7, 100, 0.85, 4)
		flower(P11, 95, 0.85, 5)

		------------------------------------------------------------ fx
		B:emitter(hearts[1], "sparkle", { name = "PearSparkle", color = { "#fff6c0", "#ff8fc4" }, rate = 2.5, size = 0.3 })
		B:light(hearts[2], { color = "#ffd07a", brightness = 0.7, range = 10, name = "PearLight" })
	end,
}
