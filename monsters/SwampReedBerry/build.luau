--!nocheck
-- Reedberry Cattail (Misty Swamp plant #1, Common).
-- A tall clump of swamp cattails on a stepped dark-mud mound (moss pads, a
-- murky teal puddle with lily pads, mossy stones, little reed tufts). Six
-- slender green stalks splay gently out of the mud, each topped with a
-- chunky stepped brown cattail head and a pale spike tip; long flat reed
-- blades fan out from the base and bend over at the knees. Arching side
-- shoots carry grape-like clusters of plump violet berries.
-- Static prop: no motion.luau, no VFX.
return {
	DisplayName = "Reedberry Cattail",
	Rarity = "Common",
	Element = "Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Misty Swamp)
		local MUD_DK, MUD_DK2, MUD, MUD_LT = "#3e3428", "#4a3e2e", "#5c4c36", "#6e5d42"
		local MOSS, MOSS_DK, MOSS_LT = "#4f8f3e", "#3b7034", "#6fae4c"
		local WATER, WATER_DK, WATER_LT = "#2d6f6a", "#24524f", "#62a9a0"
		local PAD, PAD_DK, PAD_LT = "#3f9a4c", "#2f7a3e", "#62b85a"
		local STONE, STONE_DK = "#6f7a72", "#565f59"
		local STALK, STALK_DK = "#4f8f46", "#3d7238"
		local REED, REED_DK, REED_LT = "#4c9a52", "#367a42", "#7dbb5e"
		local CAT, CAT_DK, CAT_LT, CAT_TIP = "#6a3f24", "#4f2d1a", "#875330", "#d9c99a"
		local BERRY, BERRY_DK, BERRY_LT, BERRY_HI = "#8a4ad8", "#6634ac", "#ad78f0", "#e2c8ff"
		local CALYX = "#2f5f2c"
		local LILY, LILY_LT = "#f4a6cf", "#ffe0ef"

		local seed = 1511
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		-- frame at p whose local +Y points along dir
		local function up(p, dir)
			return P.aim(p, p + dir) * ang(-90, 0, 0)
		end

		------------------------------------------------------------ mud mound
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
		tier(0, 0.75, 4.3, MUD_DK, 11, { MUD_DK, MUD_DK2, MUD_DK }, 0.35)
		tier(0.75, 0.55, 3.0, MUD, 6, { MUD, MUD_LT, MUD }, 0.25, { 300, 355 })
		tier(1.3, 0.35, 1.9, MUD_LT, 0, {}, 0)

		-- moss pads draped over the tier edges
		for _, m in { { 35, 4.3, 1.9, MOSS }, { 120, 4.35, 1.6, MOSS_DK }, { 200, 4.3, 2.0, MOSS }, { 255, 4.3, 1.5, MOSS_LT } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], 0.87, -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[3], 0.3, 1.2), c * ang(-14, 0, 0), m[4], S)
		end
		for _, m in { { 70, 3.0, 1.4, MOSS_LT }, { 165, 3.0, 1.5, MOSS } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], 1.42, -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[3], 0.26, 1.0), c * ang(-12, 0, 0), m[4], S)
		end

		-- murky puddle on the lower tier, front-left, with lily pads
		local PC = v(-1.95, 1.33, -1.95)
		B:block(soil, v(1.7, 0.14, 2.7), CFrame.new(PC) * ang(0, 45, 0), WATER, S)
		B:block(soil, v(2.5, 0.14, 1.5), CFrame.new(PC + v(0, 0.005, 0)) * ang(0, 45, 0), WATER, S)
		B:block(soil, v(1.2, 0.15, 1.2), CFrame.new(PC + v(0.2, 0.01, 0.2)) * ang(0, 20, 0), WATER_DK, S)
		B:block(soil, v(0.9, 0.06, 0.22), CFrame.new(PC + v(0.3, 0.09, -0.4)) * ang(0, 45, 0), WATER_LT, S)
		B:block(soil, v(0.6, 0.06, 0.2), CFrame.new(PC + v(-0.6, 0.09, 0.15)) * ang(0, 45, 0), WATER_LT, S)
		-- mud rim around the puddle
		B:block(soil, v(1.2, 0.35, 0.7), CFrame.new(PC + v(-1.0, 0.05, -0.95)) * ang(0, 45, 0), MUD_LT, S)
		B:block(soil, v(0.8, 0.3, 0.6), CFrame.new(PC + v(-1.45, 0.02, 0.15)) * ang(0, 70, 0), MUD, S)
		local function lily(p, s, yaw, flower)
			B:block(soil, v(1.0 * s, 0.1, 1.0 * s), CFrame.new(p) * ang(0, yaw, 0), PAD, S)
			B:block(soil, v(0.8 * s, 0.12, 0.8 * s), CFrame.new(p + v(0, 0.01, 0)) * ang(0, yaw + 45, 0), PAD_DK, S)
			B:block(soil, v(0.45 * s, 0.14, 0.45 * s), CFrame.new(p + v(0, 0.02, 0)) * ang(0, yaw + 20, 0), PAD_LT, S)
			if flower then
				B:block(soil, v(0.45, 0.3, 0.45), CFrame.new(p + v(0, 0.2, 0)) * ang(0, yaw, 0), LILY, S)
				B:block(soil, v(0.25, 0.3, 0.25), CFrame.new(p + v(0, 0.35, 0)) * ang(0, yaw + 45, 0), LILY_LT, S)
			end
		end
		lily(PC + v(-0.45, 0.06, -0.45), 1.0, 15, true)
		lily(PC + v(0.55, 0.06, 0.3), 0.75, 50, false)

		-- tiny teal swamp mushrooms (back-right)
		local function mush(p, s)
			B:block(soil, v(0.32 * s, 0.7 * s, 0.32 * s), CFrame.new(p + v(0, 0.35 * s, 0)), "#d8e6d0", S)
			B:block(soil, v(0.95 * s, 0.32 * s, 0.95 * s), CFrame.new(p + v(0, 0.78 * s, 0)) * ang(0, 30, 0), "#2f9f9a", S)
			B:block(soil, v(0.6 * s, 0.2 * s, 0.6 * s), CFrame.new(p + v(0, 0.98 * s, 0)) * ang(0, 75, 0), "#45c2b5", S)
			B:block(soil, v(0.18 * s, 0.1, 0.18 * s), CFrame.new(p + v(0.22 * s, 0.98 * s, -0.2 * s)) * ang(0, 30, 0), "#e8fff8", S)
		end
		mush(v(1.9, 1.3, 2.0), 1.0)
		mush(v(2.5, 1.3, 1.45), 0.7)
		mush(v(-3.2, 0.75, -1.2), 0.75)

		-- mossy stones
		local function stone(p, s, yaw)
			local c = CFrame.new(p) * ang(0, yaw, 0)
			B:block(soil, v(1.1 * s, 0.75 * s, 0.9 * s), c * CFrame.new(0, 0.37 * s, 0), STONE, S)
			B:block(soil, v(0.7 * s, 0.45 * s, 0.6 * s), c * CFrame.new(0.15 * s, 0.85 * s, 0) * ang(0, 20, 0), STONE_DK, S)
			B:block(soil, v(0.8 * s, 0.2 * s, 0.7 * s), c * CFrame.new(-0.1 * s, 0.82 * s, 0.05 * s) * ang(0, -10, 0), MOSS, S)
		end
		stone(v(3.3, 0.72, 1.6), 1.0, 25)
		stone(v(0.3, 0.72, -3.7), 0.7, -20)
		stone(v(-3.4, 0.72, 1.8), 0.8, 60)

		-- little reed tufts on the mound
		local function tuft(x, z, y)
			local base = CFrame.new(x, y, z) * ang(0, rnd(0, 90), 0)
			B:block(soil, v(0.24, 1.5, 0.24), base * CFrame.new(0, 0.7, 0), REED, S)
			B:block(soil, v(0.22, 1.2, 0.22), base * CFrame.new(0.2, 0.55, 0) * ang(0, 0, -18), REED_LT, S)
			B:block(soil, v(0.22, 1.0, 0.22), base * CFrame.new(-0.2, 0.45, 0.05) * ang(0, 0, 20), REED_DK, S)
		end
		tuft(3.7, -1.3, 0.7)
		tuft(-3.9, -0.2, 0.7)
		tuft(1.3, 3.8, 0.7)

		------------------------------------------------------------ cattails
		local crop = B:bone("Crop", "Root", v(0, 1.65, 0))
		-- base clump of mud + young shoots
		B:block(crop, v(2.1, 0.4, 2.1), cf(0, 1.8, 0.1, 0, 20, 0), MOSS_DK)
		B:block(crop, v(1.5, 0.5, 1.5), cf(0, 1.92, 0.1, 0, 65, 0), MOSS)

		local stalks = {
			-- base, knee, tip
			{ v(0.0, 1.8, 0.1), v(0.1, 7.0, 0.0), v(0.35, 13.0, -0.25) },
			{ v(-0.5, 1.8, 0.35), v(-1.2, 6.5, 0.4), v(-2.3, 11.6, 0.45) },
			{ v(0.55, 1.8, 0.25), v(1.3, 6.2, 0.3), v(2.4, 10.9, 0.25) },
			{ v(-0.2, 1.8, -0.4), v(-0.5, 5.8, -1.1), v(-1.0, 10.1, -2.0) },
			{ v(0.25, 1.8, 0.6), v(0.6, 6.0, 1.3), v(1.0, 10.3, 2.3) },
			{ v(0.4, 1.8, -0.3), v(1.0, 5.2, -1.0), v(1.9, 8.9, -1.9) },
		}
		local function cattail(s, size)
			local a, k, t = s[1], s[2], s[3]
			B:bar(crop, a, k + (k - a).Unit * 0.15, 0.42, 0.42, STALK_DK)
			local d = (t - k).Unit
			local headTop = t - d * 0.9
			local headBot = headTop - d * (2.5 * size)
			B:bar(crop, k - d * 0.15, headBot + d * 0.3, 0.38, 0.38, STALK)
			-- stepped cattail head: body + 45deg core + pale bands at the ends
			local mid = (headTop + headBot) / 2
			local F = up(mid, d) * ang(0, rnd(0, 45), 0)
			local L = 2.5 * size
			B:block(crop, v(0.95 * size, L, 0.95 * size), F, CAT)
			B:block(crop, v(0.82 * size, L + 0.3, 0.82 * size), F * ang(0, 45, 0), CAT_DK)
			B:block(crop, v(1.05 * size, L * 0.4, 1.05 * size), F * CFrame.new(0, L * 0.12, 0), CAT_LT)
			B:block(crop, v(0.6, 0.35, 0.6), F * CFrame.new(0, -L / 2 - 0.15, 0) * ang(0, 45, 0), STALK)
			-- pale spike tip
			B:bar(crop, headTop, t, 0.24, 0.24, CAT_TIP)
			B:block(crop, v(0.45, 0.3, 0.45), up(headTop + d * 0.1, d) * ang(0, 45, 0), CAT_DK)
		end
		cattail(stalks[1], 1.15)
		cattail(stalks[2], 1.05)
		cattail(stalks[3], 1.0)
		cattail(stalks[4], 0.95)
		cattail(stalks[5], 0.95)
		cattail(stalks[6], 1.0)

		------------------------------------------------------------ reed blades
		-- long flat blades from the base, bending over at a knee
		local function blade(a, len1, len2, lean, yaw, col, col2, w)
			local dir = v(math.sin(rad(yaw)), 0, -math.cos(rad(yaw)))
			local p0 = v(0, 1.85, 0.1) + dir * 0.4
			local p1 = p0 + dir * (len1 * math.sin(rad(lean))) + v(0, len1 * math.cos(rad(lean)), 0)
			local lean2 = lean + a
			local p2 = p1 + dir * (len2 * math.sin(rad(lean2))) + v(0, len2 * math.cos(rad(lean2)), 0)
			local side = v(dir.Z, 0, -dir.X)
			B:bar(crop, p0, p1 + (p1 - p0).Unit * 0.2, w, 0.25, col, { up = side:Cross(p1 - p0) })
			B:bar(crop, p1 - (p2 - p1).Unit * 0.1, p2, w * 0.85, 0.22, col2, { up = side:Cross(p2 - p1) })
		end
		blade(45, 4.2, 3.0, 14, 30, REED, REED_LT, 1.0)
		blade(55, 3.8, 2.6, 18, 100, REED_DK, REED, 1.0)
		blade(40, 4.6, 3.0, 12, 165, REED, REED_LT, 1.0)
		blade(60, 3.6, 2.4, 20, 215, REED_DK, REED, 0.9)
		blade(45, 4.4, 3.0, 14, 280, REED, REED_LT, 1.0)
		blade(50, 3.4, 2.4, 22, 330, REED_LT, REED, 0.9)
		blade(35, 5.4, 2.6, 6, 250, REED_DK, REED_LT, 0.9)
		blade(35, 5.2, 2.4, 7, 70, REED, REED_LT, 0.9)

		------------------------------------------------------------ berries
		-- plump stepped berry: cube + taller 45deg core + small calyx on top
		local function berry(p, s, col, yaw)
			local F = CFrame.new(p) * ang(rnd(-8, 8), yaw, rnd(-8, 8))
			B:block(crop, v(0.85 * s, 0.85 * s, 0.85 * s), F, col)
			B:block(crop, v(0.66 * s, 1.08 * s, 0.66 * s), F * ang(0, 45, 0), col == BERRY_DK and BERRY or BERRY_LT)
		end
		-- arching shoot from a point on a stalk, cluster hangs below the tip
		local function cluster(from, yaw, reach, big)
			local dir = v(math.sin(rad(yaw)), 0, -math.cos(rad(yaw)))
			local p1 = from + dir * (reach * 0.6) + v(0, 0.6, 0)
			local p2 = from + dir * reach + v(0, 0.2, 0)
			B:bar(crop, from, p1, 0.22, 0.22, STALK)
			B:bar(crop, p1, p2, 0.2, 0.2, STALK_DK)
			B:block(crop, v(0.6, 0.25, 0.6), CFrame.new(p2 + v(0, -0.1, 0)) * ang(0, yaw + 45, 0), CALYX)
			local side = v(dir.Z, 0, -dir.X)
			local c = p2 + v(0, -0.75, 0)
			berry(c + side * 0.48, 1.0, BERRY, yaw)
			berry(c - side * 0.48, 1.0, BERRY_LT, yaw + 10)
			berry(c + dir * 0.45 + v(0, 0.05, 0), 0.95, BERRY_DK, yaw - 10)
			berry(c - dir * 0.45 + v(0, 0.05, 0), 0.95, BERRY, yaw + 20)
			berry(c + v(0, -0.85, 0), big and 1.05 or 0.95, BERRY_LT, yaw + 5)
			if big then
				berry(c + side * 0.35 + v(0, -1.65, 0), 0.85, BERRY, yaw)
			end
			-- glossy highlight on the front berry
			B:block(crop, v(0.2, 0.28, 0.12), CFrame.new(c + side * 0.48 + dir * 0.0 + v(-0.1, 0.12, 0)) * ang(0, yaw, 0) * CFrame.new(0, 0, -0.44), BERRY_HI)
		end
		local function along(s, f)
			local a, k = s[1], s[2]
			return a:Lerp(k, f)
		end
		local function alongTop(s, f)
			local k, t = s[2], s[3]
			return k:Lerp(t, f)
		end
		cluster(alongTop(stalks[1], 0.25), -20, 1.6, true)
		cluster(alongTop(stalks[2], 0.35), -95, 1.5, true)
		cluster(alongTop(stalks[3], 0.3), 85, 1.5, true)
		cluster(along(stalks[4], 0.85), -40, 1.5, false)
		cluster(along(stalks[5], 0.9), 150, 1.5, true)
		cluster(alongTop(stalks[6], 0.15), 40, 1.4, false)
		cluster(along(stalks[1], 0.7), 200, 1.5, false)

		-- fallen berries on the mud
		berry(v(1.6, 2.1, -1.2), 0.85, BERRY, 20)
		berry(v(2.25, 1.75, -1.75), 0.75, BERRY_LT, 60)
		berry(v(-1.1, 2.1, 1.7), 0.8, BERRY_DK, 10)

		-- a little teal dragonfly resting on the right cattail
		local dt = stalks[3][3]
		local D = CFrame.new(dt + v(0.1, -2.0, -0.55)) * ang(0, -30, 0)
		local DF, DF_DK, WING = "#2fb8c8", "#1f7f8f", "#d8f4f8"
		B:block(crop, v(0.32, 0.32, 1.7), D, DF)
		B:block(crop, v(0.5, 0.45, 0.5), D * CFrame.new(0, 0.02, -0.95), DF_DK)
		B:block(crop, v(0.22, 0.22, 0.8), D * CFrame.new(0, 0, 1.1), DF_DK)
		B:block(crop, v(2.4, 0.08, 0.42), D * CFrame.new(0, 0.2, -0.35) * ang(0, 8, 0), WING, { tr = 0.25 })
		B:block(crop, v(2.0, 0.08, 0.38), D * CFrame.new(0, 0.2, 0.15) * ang(0, -8, 0), WING, { tr = 0.25 })
	end,
}
