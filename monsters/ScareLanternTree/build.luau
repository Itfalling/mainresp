--!nocheck
-- Great Lantern Tree (Scarecrow Stage crop #10, Apex): the showpiece of the
-- cornfield. A majestic autumn tree in the stud-tree reference style: a big
-- stepped dirt mound strewn with fallen leaves, hay tufts and two little
-- jack-o'-lanterns; a chunky twisted dark-bark trunk with gnarled roots and
-- spiral bark ridges; four crooked branches carrying a huge crown of big
-- rotated studded leaf cubes in orange / red / gold. Glowing jack-o'-lantern
-- fruit with CUTE carved faces (stepped triangle eyes, toothy grins) hang on
-- curly vine stems under the crown (each on its own bone so they can sway),
-- more sit half-sunk in the canopy, and a lantern wearing a little purple
-- witch hat crowns the top. Falling autumn leaves, ember motes, one warm light.
-- Has a subtle motion.luau (lantern swing, canopy breathing, glow flicker).
return {
	DisplayName = "Great Lantern Tree",
	Rarity = "Apex",
	Element = "Harvest",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad

		-- palette ---------------------------------------------------------
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#4a2a17", "#3d2213", "#643a21", "#7d4c2c"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local HAY, HAY_LT = "#e6bd55", "#f4d98a"
		local BARK_DK, BARK, BARK_LT = "#2e1a10", "#45281a", "#5e3824"
		local LF_OR, LF_OR_DK, LF_RED, LF_RED_DK = "#f27a1c", "#d9581a", "#d8352a", "#a8231f"
		local LF_GOLD, LF_GOLD_LT, LF_PLUM = "#f7b52c", "#ffd34f", "#7b2e6e"
		local PUMP, PUMP_DK, PUMP_LT = "#f58a1f", "#cf6416", "#ffa53a"
		local STEM, STEM_DK, VINE = "#6b7d2a", "#4c5c1c", "#3f7a2a"
		local GLOW, GLOW_HOT = "#ffb12e", "#ffe066"
		local HAT, HAT_DK, HAT_BAND = "#5b2a86", "#3e1b5e", "#f2a52a"

		local seed = 31
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function polar(r, deg)
			local a = rad(deg)
			return math.sin(a) * r, -math.cos(a) * r
		end
		-- CFrame whose local -Z faces outward along polar `deg`
		local function facing(x, y, z, deg)
			return CFrame.new(x, y, z) * CFrame.Angles(0, -rad(deg), 0)
		end

		------------------------------------------------------------------
		-- JACK-O'-LANTERN: stepped round pumpkin + cute glowing carved face
		-- C = centre, local -Z = face. kind: "happy" | "wink" | "cheeky"
		------------------------------------------------------------------
		local faceParts = {} -- named neon parts for the flicker
		local nJack = 0
		local function jack(bone, C, w, kind, flickName)
			nJack += 1
			local h = w * 0.82
			B:block(bone, v(w, h, w * 0.7), C, PUMP_DK)
			B:block(bone, v(w * 0.7, h + 0.04, w), C, PUMP)
			B:block(bone, v(w * 0.86, h - 0.12, w * 0.86), C * CFrame.Angles(0, rad(45), 0), PUMP_DK)
			B:block(bone, v(w * 0.5, 0.2, w * 0.5), C * CFrame.new(0, h * 0.5 + 0.06, 0), PUMP_LT)
			-- face, slightly proud of the front face
			local s = w / 2.8
			local fz = -(w * 0.5) - 0.02
			local function fp(x, y, sx, sy, col, name)
				local p = B:block(bone, v(sx * s, sy * s, 0.12), C * CFrame.new(x * s, y * s, fz), col or GLOW, { mat = "Neon", name = name or "JackFace" })
				return p
			end
			local main
			-- eyes: stepped triangles (wide bottom, narrow top)
			for side = -1, 1, 2 do
				local wink = (kind == "wink" and side == 1)
				if wink then
					-- a closed, happy ^ eye
					B:block(bone, v(0.5 * s, 0.16 * s, 0.12), C * CFrame.new(side * 0.62 * s - 0.14 * s, 0.32 * s, fz) * CFrame.Angles(0, 0, rad(30)), GLOW, { mat = "Neon", name = "JackFace" })
					B:block(bone, v(0.5 * s, 0.16 * s, 0.12), C * CFrame.new(side * 0.62 * s + 0.14 * s, 0.32 * s, fz) * CFrame.Angles(0, 0, rad(-30)), GLOW, { mat = "Neon", name = "JackFace" })
				else
					local e = fp(side * 0.62, 0.22, 0.74, 0.26, GLOW, (side == -1 and flickName) or nil)
					if side == -1 then main = e end
					fp(side * 0.62, 0.44, 0.44, 0.22, GLOW_HOT)
					fp(side * 0.62, 0.6, 0.16, 0.14, GLOW_HOT)
				end
			end
			-- tiny triangle nose
			fp(0, -0.02, 0.3, 0.16, GLOW)
			-- toothy smile: wide glowing bar, corners curling up, pumpkin teeth over it
			local mw = (kind == "cheeky") and 1.5 or 1.7
			fp(0, -0.42, mw, 0.32, GLOW_HOT)
			fp(-mw * 0.5 - 0.06, -0.26, 0.26, 0.3, GLOW)
			fp(mw * 0.5 + 0.06, -0.26, 0.26, 0.3, GLOW)
			local tz = fz - 0.04
			B:block(bone, v(0.26 * s, 0.17 * s, 0.14), C * CFrame.new(-0.3 * s, -0.33 * s, tz), PUMP)
			B:block(bone, v(0.26 * s, 0.17 * s, 0.14), C * CFrame.new(0.3 * s, -0.33 * s, tz), PUMP)
			B:block(bone, v(0.26 * s, 0.15 * s, 0.14), C * CFrame.new(0, -0.52 * s, tz), PUMP)
			if kind == "cheeky" then
				-- a little tongue poking out
				B:block(bone, v(0.36 * s, 0.24 * s, 0.16), C * CFrame.new(0.4 * s, -0.58 * s, tz), "#e8455a")
			end
			table.insert(faceParts, main)
			return C * CFrame.new(0, h * 0.5, 0)
		end
		-- stem + leaf on top of a pumpkin
		local function stemTop(bone, top, s, yaw)
			B:block(bone, v(0.42 * s, 0.7 * s, 0.42 * s), top * CFrame.new(0, 0.3 * s, 0) * CFrame.Angles(0, rad(yaw), rad(10)), STEM)
			B:block(bone, v(0.9 * s, 0.14, 0.6 * s), top * CFrame.new(0.45 * s, 0.14, 0.1) * CFrame.Angles(0, rad(yaw + 30), rad(-12)), VINE)
		end

		------------------------------------------------------------------
		-- STEPPED DIRT MOUND
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(y0, y1, w, color)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(soil, v(w, h, w * 0.62), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.62, h + 0.02, w), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.84, h - 0.03, w * 0.84), cf(0, y, 0), color, S)
		end
		oct(0, 1.0, 16.0, DIRT_DK)
		oct(1.0, 1.9, 12.0, DIRT)
		oct(1.9, 2.6, 7.4, DIRT_LT)
		for i = 0, 14 do
			local a = i * 24 + jit(6)
			local x, z = polar(7.7 + jit(0.3), a)
			local h = 0.9 + rnd() * 0.7
			B:block(soil, v(2.6 + rnd() * 0.8, h, 1.9 + rnd() * 0.5), cf(x, h / 2, z, 0, -a + jit(10), 0),
				i % 3 == 0 and DIRT or (i % 2 == 0 and DIRT_DK2 or DIRT_DK), S)
		end
		for i = 0, 7 do
			local a = i * 45 + 20 + jit(8)
			local x, z = polar(5.7 + jit(0.3), a)
			local h = 0.7 + rnd() * 0.4
			B:block(soil, v(2.1 + rnd() * 0.5, h, 1.6), cf(x, 1.0 + h / 2, z, 0, -a + jit(12), 0), i % 2 == 0 and DIRT or DIRT_DK, S)
		end
		for _, g in { { -8.6, 2.6, 1.1 }, { -8.0, 3.5, 0.7 }, { 7.9, -4.6, 0.9 }, { 8.4, -3.8, 0.6 }, { 2.4, 8.6, 0.8 }, { -4.4, -7.6, 0.7 } } do
			B:block(soil, v(0.6, g[3], 0.6), cf(g[1], g[3] / 2, g[2], 0, jit(20), 0), (g[3] > 0.8) and GRASS or GRASS_DK, S)
		end
		-- hay tufts
		for _, t in { { 140, 6.6 }, { 250, 6.3 }, { 25, 6.5 } } do
			local x, z = polar(t[2], t[1])
			for k = 0, 2 do
				B:block(soil, v(0.22, 1.0, 0.22), cf(x + (k - 1) * 0.25, 2.2, z, (k - 1) * 18, 0, (k - 1) * 24), (k == 1) and HAY_LT or HAY, S)
			end
		end
		-- fallen leaves scattered on the mound
		local FALL = { LF_OR, LF_RED, LF_GOLD, LF_OR_DK }
		for i = 1, 8 do
			local a = i * 45 + jit(10)
			local r = 3.4 + rnd() * 4.2
			local x, z = polar(r, a)
			local y = (r > 6.0) and 1.96 or (r > 3.7 and 1.96 or 2.66)
			if r <= 3.7 then y = 2.66 end
			B:block(soil, v(0.8, 0.14, 0.6), cf(x, y + 0.02, z, 0, rnd() * 180, 0), FALL[i % 4 + 1], S)
		end
		-- two little jack-o'-lanterns on the mound (front)
		do
			local x, z = polar(5.0, 330)
			local top = jack(soil, facing(x, 1.9 + 0.82, z, 330 + 15), 2.0, "happy", nil)
			stemTop(soil, top, 0.7, 20)
			local x2, z2 = polar(5.4, 35)
			local top2 = jack(soil, facing(x2, 1.9 + 0.62, z2, 35 - 10), 1.5, "wink", nil)
			stemTop(soil, top2, 0.55, -30)
		end
		-- every base part is named Soil so the game can strip the base
		for _, p in B.parts do
			p.Name = "Soil"
		end
		table.clear(faceParts)

		------------------------------------------------------------------
		-- TWISTED TRUNK
		------------------------------------------------------------------
		local BASE = 2.6
		local crop = B:bone("Crop", "Root", v(0, BASE, 0))
		B:block(crop, v(4.8, 1.0, 4.8), cf(0, BASE + 0.4, 0, 0, 10, 0), BARK_DK)
		B:block(crop, v(4.2, 1.0, 4.2), cf(0, BASE + 1.3, 0, 0, -12, 0), BARK)
		-- gnarled roots running down the mound
		for k = 0, 4 do
			local a = k * 72 + 20 + jit(8)
			local x1, z1 = polar(2.2, a)
			local x2, z2 = polar(4.4, a + 12)
			local x3, z3 = polar(5.6, a + 20)
			B:bar(crop, v(x1, BASE + 0.9, z1), v(x2, BASE - 0.2, z2), 1.3, 1.0, (k % 2 == 0) and BARK or BARK_DK)
			B:bar(crop, v(x2, BASE - 0.1, z2), v(x3, 1.6, z3), 0.95, 0.8, BARK_DK)
		end
		-- twisting column: each block yawed further, wandering slightly
		local col = {
			{ 3.8, 2.2, 0.0, 0.0, 0 },
			{ 3.5, 4.2, 0.2, -0.1, 18 },
			{ 3.2, 6.2, 0.1, 0.1, 36 },
			{ 3.0, 8.2, -0.2, 0.15, 54 },
			{ 2.8, 10.0, -0.1, 0.0, 72 },
		}
		for i, c in col do
			B:block(crop, v(c[1], 2.3, c[1]), cf(c[3], BASE + c[2], c[4], 0, c[5], (i % 2 == 0) and 3 or -2), (i % 2 == 0) and BARK_LT or BARK)
		end
		-- spiral bark ridges wrapping the trunk
		for r = 0, 1 do
			local prev
			for i = 0, 6 do
				local t = i / 6
				local deg = r * 180 + t * 300
				local rr = 1.9 - t * 0.45
				local x, z = polar(rr, deg)
				local p = v(x, BASE + 1.4 + t * 8.6, z)
				if prev then
					B:bar(crop, prev, p, 0.7, 0.7, BARK_DK)
				end
				prev = p
			end
		end
		-- knot hole (a cosy dark hollow) + bark patches
		B:block(crop, v(1.2, 1.5, 0.4), cf(0.35, BASE + 4.6, -1.8, 0, 36, 0), "#1c0f08")
		B:block(crop, v(1.6, 0.4, 0.5), cf(0.35, BASE + 5.45, -1.8, 0, 36, 0), BARK_LT)
		B:block(crop, v(1.4, 0.4, 0.5), cf(0.35, BASE + 3.75, -1.8, 0, 36, 0), BARK_LT)
		-- crooked branches into the canopy (two segments with an elbow)
		local br = {
			{ 30, 10.6, 3.2, 12.6, 6.0, 14.2 },
			{ 120, 10.2, 3.4, 12.0, 6.2, 13.6 },
			{ 210, 10.8, 3.0, 12.8, 5.8, 14.6 },
			{ 300, 10.4, 3.3, 12.4, 6.1, 14.0 },
		}
		for _, b in br do
			local x0, z0 = polar(0.8, b[1])
			local x1, z1 = polar(b[3], b[1] + 12)
			local x2, z2 = polar(b[5], b[1] - 6)
			local p0, p1, p2 = v(x0, BASE + b[2], z0), v(x1, b[4], z1), v(x2, b[6], z2)
			B:bar(crop, p0, p1, 1.6, 1.6, BARK)
			B:bar(crop, p1, p2, 1.2, 1.2, BARK_LT)
		end

		------------------------------------------------------------------
		-- CANOPY (its own bone so it can breathe): big rotated leaf cubes
		------------------------------------------------------------------
		local CANY = 15.0
		local canopy = B:bone("Canopy", "Crop", v(0, BASE + 10.5, 0))
		local leafDefs = {
			-- deg, r, y, size, colour
			{ 0, 6.3, 14.4, 5.4, LF_OR },
			{ 60, 6.4, 14.6, 5.2, LF_RED },
			{ 120, 6.2, 14.3, 5.5, LF_GOLD },
			{ 180, 6.4, 14.5, 5.2, LF_OR_DK },
			{ 240, 6.2, 14.4, 5.4, LF_RED_DK },
			{ 300, 6.5, 14.6, 5.1, LF_GOLD },
			{ 30, 7.9, 16.1, 3.8, LF_GOLD_LT },
			{ 150, 7.8, 16.0, 3.7, LF_RED },
			{ 270, 7.9, 16.2, 3.8, LF_OR },
			{ 90, 7.6, 15.8, 3.5, LF_OR },
			{ 210, 7.6, 15.9, 3.5, LF_GOLD_LT },
			{ 330, 7.7, 15.8, 3.6, LF_PLUM },
			{ 36, 4.0, 17.4, 5.8, LF_RED_DK },
			{ 108, 4.1, 17.8, 5.6, LF_OR },
			{ 180, 3.9, 17.2, 5.9, LF_GOLD },
			{ 252, 4.1, 17.6, 5.6, LF_OR },
			{ 324, 4.0, 17.9, 5.5, LF_RED },
			{ 0, 0.0, 15.6, 6.4, LF_OR_DK },
			{ 70, 2.2, 19.4, 4.8, LF_GOLD_LT },
			{ 190, 2.1, 19.2, 5.0, LF_RED },
			{ 300, 2.0, 19.6, 4.6, LF_OR },
		}
		local cubes = {}
		for _, c in leafDefs do
			local x, z = polar(c[2], c[1])
			B:block(canopy, v(c[4], c[4], c[4]), cf(x, c[3], z, jit(20), rnd() * 90, jit(20)), c[5])
			table.insert(cubes, { pos = v(x, c[3], z), size = c[4], deg = c[1] })
		end

		-- half-sunk jack-o'-lanterns peeking out of the crown
		local sunk = { { 1, 0.6, "happy", 2.1 }, { 3, 0.4, "cheeky", 2.0 }, { 5, 0.3, "wink", 2.0 }, { 14, 1.2, "happy", 1.8 } }
		for k, sd in sunk do
			local c = cubes[sd[1]]
			local a = rad(c.deg)
			local out = v(math.sin(a), 0, -math.cos(a))
			local p = c.pos + out * (c.size * 0.5 - 0.1) + v(0, sd[2], 0)
			local top = jack(canopy, facing(p.X, p.Y, p.Z, c.deg + jit(10)), sd[4], sd[3], "SunkFace" .. k)
			stemTop(canopy, top, sd[4] / 2.8, k * 40)
		end

		------------------------------------------------------------------
		-- HANGING LANTERNS: each on its own bone, pivot at the vine top
		------------------------------------------------------------------
		local hang = {
			-- deg, r, top y, vine length, size, kind
			{ 10, 6.6, 12.0, 2.6, 2.9, "happy" },
			{ 70, 7.2, 12.2, 1.9, 2.5, "wink" },
			{ 130, 6.4, 11.9, 2.8, 2.8, "cheeky" },
			{ 190, 7.0, 12.1, 2.0, 2.6, "happy" },
			{ 250, 6.6, 12.0, 2.7, 2.9, "wink" },
			{ 310, 7.2, 12.2, 1.9, 2.5, "happy" },
		}
		local lanternGlow
		for k, h in hang do
			local x, z = polar(h[2], h[1])
			local top = v(x, h[3], z)
			local bone = B:bone("Lantern" .. k, "Canopy", top)
			-- curly vine stem: hook into the canopy, a little curl, then down
			B:block(bone, v(0.32, h[4] + 0.6, 0.32), cf(x, h[3] - h[4] * 0.5 + 0.3, z), VINE)
			local cx, cz = polar(0.45, h[1] + 90)
			B:block(bone, v(0.6, 0.24, 0.24), cf(x + cx * 0.6, h[3] - h[4] * 0.45, z + cz * 0.6, 0, -h[1] - 90, 0), STEM_DK)
			B:block(bone, v(0.24, 0.5, 0.24), cf(x + cx * 1.1, h[3] - h[4] * 0.45 + 0.2, z + cz * 1.1), STEM_DK)
			B:block(bone, v(0.9, 0.12, 0.55), cf(x - cx * 0.5, h[3] - h[4] * 0.25, z - cz * 0.5, 0, -h[1] + 60, 18), VINE)
			-- the pumpkin itself
			local hh = h[5] * 0.82
			local C = facing(x, h[3] - h[4] - hh * 0.5, z, h[1] + jit(8))
			local ptop = jack(bone, C, h[5], h[6], "LanternFace" .. k)
			B:block(bone, v(0.5, 0.5, 0.5), ptop * CFrame.new(0, 0.15, 0), STEM)
			if k == 1 then
				lanternGlow = B:block(bone, v(0.3, 0.3, 0.3), C, PUMP_DK, { name = "LanternCore" })
			end
		end

		------------------------------------------------------------------
		-- TOPPER: a jack-o'-lantern in a little purple witch hat
		------------------------------------------------------------------
		local TOPY = 21.3
		do
			local C = facing(0, TOPY, 0, -10)
			local top = jack(canopy, C, 2.6, "cheeky", "TopFace")
			-- hat: brim + stepped cone with a gold band + bent tip
			B:block(canopy, v(3.4, 0.25, 3.4), top * CFrame.new(0, 0.12, 0) * CFrame.Angles(0, rad(10), rad(-6)), HAT_DK)
			local hc = top * CFrame.Angles(0, 0, rad(-6))
			B:block(canopy, v(1.9, 0.9, 1.9), hc * CFrame.new(0, 0.65, 0), HAT)
			B:block(canopy, v(2.0, 0.3, 2.0), hc * CFrame.new(0, 0.38, 0), HAT_BAND)
			B:block(canopy, v(1.4, 0.8, 1.4), hc * CFrame.new(0.1, 1.45, 0), HAT_DK)
			B:block(canopy, v(0.9, 0.7, 0.9), hc * CFrame.new(0.3, 2.15, 0) * CFrame.Angles(0, 0, rad(-12)), HAT)
			B:block(canopy, v(0.5, 0.6, 0.5), hc * CFrame.new(0.75, 2.6, 0) * CFrame.Angles(0, 0, rad(-40)), HAT_DK)
			B:block(canopy, v(0.4, 0.4, 0.15), hc * CFrame.new(0.5, 0.38, -1.02), GLOW_HOT) -- buckle
		end

		------------------------------------------------------------------
		-- VFX: falling autumn leaves, ember motes, one warm light
		------------------------------------------------------------------
		local emitPart = B:block(canopy, v(6, 0.4, 6), cf(0, 13.0, 0), LF_OR_DK, { name = "LeafFall", tr = 1 })
		B:emitter(emitPart, "leaf", { name = "FallingLeaves", color = { LF_OR, LF_RED, LF_GOLD }, rate = 1.6, size = { 0.45, 0.45, 0.3 }, life = { 3, 5 }, speed = { 0.3, 0.8 }, accel = { 0.4, -1.4, 0 }, dir = "Bottom" })
		local glowPart = B:block(canopy, v(0.4, 0.4, 0.4), cf(0, 12.8, 0), BARK_DK, { name = "GlowCore" })
		B:emitter(glowPart, "ember", { name = "EmberMotes", color = { "#ffd166", "#ff8a1f" }, rate = 2.5, size = { 0.18, 0.12, 0 }, speed = { 0.4, 1.0 }, life = { 2, 3.5 }, spread = 160, accel = { 0, 0.6, 0 } })
		B:emitter(glowPart, "sparkle", { name = "LanternSparkle", color = { "#fff0b0", "#ffb12e" }, rate = 3, size = { 0.12, 0.4, 0 } })
		B:emitter(lanternGlow, "glow", { name = "LanternGlow", color = "#ffa630", rate = 1.2, size = { 2.2, 0 } })
		B:light(glowPart, { color = "#ffa64a", brightness = 1.4, range = 20, name = "LanternLight" })
	end,
}
