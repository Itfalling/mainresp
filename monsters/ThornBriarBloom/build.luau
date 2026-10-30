--!nocheck
-- Giant Briar Bloom (Thorny Woods crop #6, Mythic).
-- A towering enchanted rose in the stud-plant style:
-- * stepped forest-dirt mound (bone "Soil") with chunky edge blocks, moss
--   pads, fallen crimson petals, thorny briar runners, stones, a little
--   mushroom and a fallen rose-bud
-- * one tall, gently S-curved thorny green stalk (cream thorns with dark red
--   bases spiral all the way up), rose leaves with stepped leaflets
-- * plump crimson ROSE-BUD fruits on short stems all along the stalk
-- * two side stems carrying half-open pink roses
-- * a HUGE crimson bloom on top: four rings of curled studded petals, green
--   sepals, a tight swirled heart with a tiny glowing golden seed
-- Drifting petals, golden pollen sparkles, a soft rose glow + one light.
-- Static prop: no motion.luau.
return {
	DisplayName = "Giant Briar Bloom",
	Rarity = "Mythic",
	Element = "Forest",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Thorny Woods) ---------------------------------------
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local MOSS, MOSS_DK = "#5fae3a", "#3f8a2c"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8a80", "#a5a197", "#686660"
		local MUSH_STEM, MUSH_CAP, MUSH_CAP_DK = "#efe3c8", "#b8743c", "#8f5428"
		local BRIAR, BRIAR_DK = "#5a3b26", "#3e281a"
		local STALK_DK, STALK, STALK_LT = "#2b5e24", "#3c7a2e", "#57993c"
		local THORN_B, THORN = "#8a2a2a", "#f2dcb4"
		local LF_DK, LF, LF_LT, LF_TOP = "#226e36", "#2e8a42", "#49a74e", "#7cc650"
		local CRIM_DK, CRIM, CRIM_LT = "#8a0f27", "#c2193b", "#e3304f"
		local ROSE, ROSE_PALE, ROSE_MID = "#ff5876", "#ff9db2", "#f03c5e"
		local PINK_DK, PINK, PINK_LT = "#d6417c", "#ff6fa8", "#ffb0cf"
		local GOLD, GOLD_LT = "#ffc62e", "#ffe27a"

		local seed = 7741
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function pick(t)
			return t[math.floor(rnd() * #t) + 1]
		end
		local function polar(r, deg)
			local a = rad(deg)
			return math.sin(a) * r, -math.cos(a) * r
		end
		local function pv(r, deg, y)
			local x, z = polar(r, deg)
			return v(x, y, z)
		end
		local function hdir(deg)
			local x, z = polar(1, deg)
			return v(x, 0, z)
		end
		local function facing(p, deg)
			return CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
		end

		------------------------------------------------------------------
		-- STEPPED FOREST MOUND (bone "Soil", parts named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function disc(y0, h, r, col)
			B:block(soil, v(2 * r, h, 1.15 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.15 * r, h - 0.02, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.04, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
		end
		local function edge(y0, h, r, n, cols, eh, wr, dr)
			for i = 0, n - 1 do
				local a = (i + jit(0.2)) / n * 360
				local w, d = wr[1] + rnd() * (wr[2] - wr[1]), dr[1] + rnd() * (dr[2] - dr[1])
				local hh = h + rnd() * eh - 0.05
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + hh / 2, -(r + jit(0.2)))
				B:block(soil, v(w, hh, d), p * ang(0, jit(9), 0), pick(cols), S)
			end
		end
		disc(0, 0.8, 5.3, DIRT_DK)
		edge(0, 0.8, 5.35, 14, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.45, { 1.7, 2.4 }, { 1.3, 1.8 })
		disc(0.8, 0.7, 3.9, DIRT)
		edge(0.8, 0.7, 3.95, 10, { DIRT, DIRT_DK2, DIRT }, 0.35, { 1.5, 2.1 }, { 1.2, 1.6 })
		disc(1.5, 0.6, 2.5, DIRT_LT)
		local TOP = 2.1

		-- moss pads
		for _, m in { { 30, 5.45, 0.85, 2.3, MOSS }, { 150, 5.45, 0.85, 2.1, MOSS_DK }, { 260, 5.45, 0.85, 2.4, MOSS }, { 95, 4.0, 1.55, 1.8, MOSS }, { 215, 4.0, 1.55, 1.7, MOSS_DK }, { 335, 2.6, 2.15, 1.5, MOSS } } do
			local c = facing(pv(m[2], m[1], m[3]), m[1])
			B:block(soil, v(m[4], 0.3, 1.3), c * ang(-14, 0, 0), m[5], S)
		end
		-- fallen petals (crimson + pink flakes)
		for _, f in { { 20, 4.6, 0.82 }, { 75, 4.4, 0.82 }, { 190, 4.7, 0.82 }, { 300, 4.5, 0.82 }, { 345, 3.2, 1.52 }, { 130, 3.1, 1.52 }, { 240, 3.2, 1.52 }, { 60, 1.9, 2.12 }, { 280, 2.0, 2.12 } } do
			B:block(soil, v(0.85, 0.12, 0.6), facing(pv(f[2], f[1], f[3]), f[1] + jit(40)) * ang(jit(8), 0, jit(8)), pick({ CRIM, CRIM_LT, ROSE, PINK }), S)
		end
		-- stones
		for _, s in { { 4.7, 1.05, 2.4, 0.9, 25, STONE }, { 5.2, 0.95, 1.1, 0.6, 10, STONE_LT }, { -4.9, 1.0, -2.2, 0.85, -20, STONE_DK }, { 2.6, 1.85, 2.7, 0.6, 15, STONE } } do
			B:block(soil, v(s[4] * 1.3, s[4], s[4]), cf(s[1], s[2], s[3], jit(8), s[5], jit(8)), s[6], S)
		end
		-- grass tufts
		for _, g in { { 6.0, -1.8 }, { -2.6, 5.9 }, { -6.1, 1.0 }, { 2.9, -5.7 } } do
			B:block(soil, v(0.45, 0.95, 0.45), cf(g[1], 0.48, g[2], 0, jit(30), 0), GRASS, S)
			B:block(soil, v(0.35, 0.65, 0.35), cf(g[1] + 0.32, 0.33, g[2] + 0.22, 0, jit(30), 0), GRASS_DK, S)
		end
		-- a little mushroom pair
		for _, m in { { -3.1, 1.5, 2.2, 1.1 }, { -2.5, 1.5, 2.8, 0.7 } } do
			local x, y, z, s = m[1], m[2], m[3], m[4]
			B:block(soil, v(0.32 * s, 0.7 * s, 0.32 * s), cf(x, y + 0.35 * s, z), MUSH_STEM, S)
			B:block(soil, v(0.9 * s, 0.3 * s, 0.9 * s), cf(x, y + 0.75 * s, z, 0, 20, 0), MUSH_CAP, S)
			B:block(soil, v(0.55 * s, 0.22 * s, 0.55 * s), cf(x, y + 0.98 * s, z, 0, 35, 0), MUSH_CAP_DK, S)
		end
		-- thorny briar runners creeping over the mound
		for _, r in { { 40, 2.2, 5.3, 1 }, { 165, 2.0, 5.1, -1 }, { 285, 2.1, 5.4, 1 } } do
			local a = pv(r[2] - 0.6, r[1], TOP + 0.05)
			local m = pv((r[2] + r[3]) / 2, r[1] + 10 * r[4], 1.55)
			local b = pv(r[3], r[1] + 18 * r[4], 0.82)
			B:bar(soil, a, m, 0.4, 0.35, BRIAR, S)
			B:bar(soil, m, b, 0.35, 0.3, BRIAR_DK, S)
			B:block(soil, v(0.16, 0.45, 0.16), CFrame.new(m + v(0, 0.25, 0)) * ang(15, 0, -15), THORN, S)
			B:block(soil, v(0.16, 0.4, 0.16), CFrame.new(m:Lerp(b, 0.6) + v(0, 0.22, 0)) * ang(-15, 0, 20), THORN, S)
		end
		-- a fallen rose-bud
		do
			local c = cf(3.4, 1.5 + 0.45, -2.6, 0, -30, 75)
			B:block(soil, v(0.9, 1.0, 0.9), c, CRIM, S)
			B:block(soil, v(0.6, 0.6, 0.6), c * CFrame.new(0, 0.7, 0) * ang(0, 45, 0), CRIM_LT, S)
			B:block(soil, v(0.7, 0.35, 0.7), c * CFrame.new(0, -0.6, 0) * ang(0, 45, 0), LF, S)
		end

		------------------------------------------------------------------
		-- THE STALK (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		local function thorn(p, dir, len, w)
			dir = dir.Unit
			local m = p + dir * (len * 0.5)
			B:bar(crop, p - dir * 0.2, m, w, w, THORN_B)
			B:bar(crop, m - dir * 0.05, p + dir * len, w * 0.55, w * 0.55, THORN)
		end

		local BLOOM_Y = 17.4
		local spine = {
			v(0, TOP - 0.2, 0),
			v(0.3, 4.6, 0.15),
			v(0.45, 7.2, 0.2),
			v(0.1, 9.8, 0.1),
			v(-0.3, 12.4, 0.0),
			v(-0.2, 14.6, -0.1),
			v(0.05, 16.3, 0.05),
			v(0.1, BLOOM_Y + 0.2, 0.3),
		}
		local function spineAt(y)
			for i = 1, #spine - 1 do
				local a, b = spine[i], spine[i + 1]
				if y <= b.Y then
					return a:Lerp(b, math.clamp((y - a.Y) / (b.Y - a.Y), 0, 1))
				end
			end
			return spine[#spine]
		end
		for i = 1, #spine - 1 do
			local w = 1.6 - (i - 1) * 0.09
			B:bar(crop, spine[i], spine[i + 1], w, w, (i % 2 == 0) and STALK or STALK_DK)
			if i > 1 then
				B:block(crop, v(w + 0.3, 0.6, w + 0.3), CFrame.new(spine[i]) * ang(0, i * 25, 0), STALK_LT)
			end
		end
		-- root collar where the stalk meets the soil
		B:block(crop, v(2.4, 0.7, 2.4), cf(0, TOP + 0.2, 0, 0, 15, 0), STALK_DK)
		for k = 0, 3 do
			local a = k * 90 + 45
			B:bar(crop, pv(0.8, a, TOP + 0.5), pv(2.0, a + 10, TOP - 0.2), 0.7, 0.55, BRIAR)
		end
		-- thorns spiralling up the whole stalk
		for i = 0, 14 do
			local y = TOP + 1.3 + i * 1.02
			local deg = i * 137 + 15
			local c = spineAt(y)
			local w = 1.6 - (y - TOP) / (BLOOM_Y - TOP) * 0.6
			thorn(c + hdir(deg) * (w * 0.5), hdir(deg) + v(0, 0.45, 0), 1.45, 0.52)
		end

		-- a brown thorny briar vine spiralling up the stalk
		do
			local prev
			local N = 12
			for i = 0, N do
				local t = i / N
				local y = TOP + 0.6 + t * 13.4
				local deg = 200 + t * 720
				local w = 1.6 - (y - TOP) / (BLOOM_Y - TOP) * 0.6
				local p = spineAt(y) + hdir(deg) * (w * 0.5 + 0.12)
				if prev then
					B:bar(crop, prev, p, 0.36, 0.36, (i % 2 == 0) and BRIAR or BRIAR_DK)
					if i % 2 == 1 then
						B:bar(crop, p, p + (hdir(deg) + v(0, 0.6, 0)).Unit * 0.55, 0.16, 0.16, THORN)
					end
				end
				prev = p
			end
		end

		------------------------------------------------------------------
		-- ROSE LEAVES: petiole + stepped leaflets
		------------------------------------------------------------------
		local function leafSet(y, deg, len, s, five)
			local base = spineAt(y)
			local d = (hdir(deg) + v(0, 0.3, 0)).Unit
			local tip = base + d * len
			B:bar(crop, base, tip, 0.28, 0.28, STALK)
			local side = d:Cross(v(0, 1, 0)).Unit
			local function leaflet(p, yawOff, sz, col)
				local roll = (yawOff > 0) and 16 or ((yawOff < 0) and -16 or 0)
				local F = facing(p, deg + yawOff) * ang(24, 0, roll)
				B:block(crop, v(1.15 * sz, 0.34, 1.6 * sz), F * CFrame.new(0, 0, -0.62 * sz), col)
				B:block(crop, v(0.7 * sz, 0.36, 0.55 * sz), F * CFrame.new(0, 0.01, -1.5 * sz), LF_TOP)
			end
			leaflet(tip, 0, s, LF)
			leaflet(base:Lerp(tip, 0.75) + side * 0.15, 55, s * 0.85, LF_DK)
			leaflet(base:Lerp(tip, 0.75) - side * 0.15, -55, s * 0.85, LF_LT)
			if five then
				leaflet(base:Lerp(tip, 0.4) + side * 0.15, 70, s * 0.7, LF_LT)
				leaflet(base:Lerp(tip, 0.4) - side * 0.15, -70, s * 0.7, LF_DK)
			end
		end
		leafSet(TOP + 2.6, 210, 2.6, 1.6, true)
		leafSet(TOP + 4.2, 40, 2.6, 1.55, true)
		leafSet(TOP + 7.0, 300, 2.4, 1.45, true)
		leafSet(TOP + 9.4, 150, 2.2, 1.35, true)
		leafSet(TOP + 11.6, 20, 2.0, 1.25, false)
		leafSet(TOP + 13.2, 240, 1.9, 1.15, false)
		leafSet(TOP + 14.5, 130, 1.8, 1.1, false)
		leafSet(TOP + 0.9, 330, 1.6, 1.2, false)
		leafSet(TOP + 1.0, 150, 1.6, 1.15, false)

		------------------------------------------------------------------
		-- ROSE-BUD FRUITS on short stems
		------------------------------------------------------------------
		local buds = {}
		local function bud(y, deg, out, up, s, glow)
			local base = spineAt(y)
			local tip = base + hdir(deg) * out + v(0, up, 0)
			local mid = base:Lerp(tip, 0.5) + v(0, -0.25, 0)
			B:bar(crop, base, mid, 0.34, 0.34, STALK)
			B:bar(crop, mid, tip, 0.3, 0.3, STALK_LT)
			local F = facing(tip, deg) * ang(-12, 0, 0)
			local function at(x, yy, z)
				return F * CFrame.new(x * s, yy * s, z * s)
			end
			B:block(crop, v(0.85 * s, 0.4 * s, 0.85 * s), at(0, 0.1, 0) * ang(0, 45, 0), LF_DK)
			B:block(crop, v(1.05 * s, 1.1 * s, 1.05 * s), at(0, 0.75, 0), CRIM)
			B:block(crop, v(0.8 * s, 0.75 * s, 0.8 * s), at(0, 1.55, 0) * ang(0, 45, 0), CRIM_LT)
			B:block(crop, v(0.42 * s, 0.5 * s, 0.42 * s), at(0, 2.1, 0), ROSE)
			-- sepals hugging the bud
			for k = 0, 3 do
				local a = k * 90 + 45
				B:block(crop, v(0.38 * s, 0.95 * s, 0.16 * s), F * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.55 * s, -0.56 * s) * ang(-14, 0, 0), (k % 2 == 0) and LF or LF_LT)
			end
			B:block(crop, v(0.3 * s, 0.42 * s, 0.12 * s), at(-0.3, 0.9, -0.55), ROSE_PALE)
			if glow then
				B:block(crop, v(0.24 * s, 0.24 * s, 0.24 * s), at(0, 2.42, 0), GOLD_LT, { mat = "Neon", name = "BudGlow" })
			end
			table.insert(buds, tip)
		end
		bud(TOP + 3.2, 120, 2.2, 1.0, 1.25, false)
		bud(TOP + 5.6, 255, 2.3, 1.1, 1.3, true)
		bud(TOP + 8.2, 70, 2.3, 1.0, 1.3, false)
		bud(TOP + 10.4, 335, 2.1, 1.0, 1.2, true)
		bud(TOP + 12.4, 185, 2.0, 0.9, 1.15, false)
		bud(TOP + 14.0, 95, 1.8, 0.8, 1.05, true)

		------------------------------------------------------------------
		-- ROSE builder. Frame F: base at origin, opens toward local +Y.
		-- rings: n, radius, base y, outward tilt, width, height, colour, lip colour
		------------------------------------------------------------------
		local function rose(F, s, rings, heartGlow, dew)
			-- sepals drooping under the flower
			for k = 0, 4 do
				local a = k * 72 + 10
				B:block(crop, v(0.75 * s, 0.2 * s, 1.7 * s), F * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.1 * s, -0.4 * s) * ang(-38, 0, 0) * CFrame.new(0, 0, -0.75 * s), (k % 2 == 0) and LF or LF_DK)
			end
			B:block(crop, v(1.4 * s, 0.8 * s, 1.4 * s), F * CFrame.new(0, 0.15 * s, 0) * ang(0, 45, 0), STALK)
			for ri, r in rings do
				for i = 0, r[1] - 1 do
					local a = i * 360 / r[1] + (r[9] or 0)
					local P0 = F * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, r[3] * s, -r[2] * s) * CFrame.Angles(rad(r[4]), 0, 0)
					local w, h = r[5] * s, r[6] * s
					B:block(crop, v(w, h, 0.42 * s), P0 * CFrame.new(0, h / 2, 0), r[7])
					if r[8] then
						-- curled-back lip
						B:block(crop, v(w * 0.82, 0.55 * s, 0.46 * s), P0 * CFrame.new(0, h - 0.05 * s, 0) * ang(-34, 0, 0) * CFrame.new(0, 0.22 * s, 0), r[8])
					end
					if ri == 1 and dew and (i % 3 == 0) then
						B:block(crop, v(0.3 * s, 0.3 * s, 0.2 * s), P0 * CFrame.new(0.28 * w, h * 0.55, 0.26 * s), "#ffd6e0", { mat = "Neon", name = "Dew" })
					end
					if ri == 1 and r[10] then
						-- darker base inside the outer petals
						B:block(crop, v(w * 0.7, h * 0.45, 0.46 * s), P0 * CFrame.new(0, h * 0.25, 0.02 * s), r[10])
					end
				end
			end
			-- tight swirled heart
			B:block(crop, v(0.9 * s, 1.5 * s, 0.9 * s), F * CFrame.new(0, 1.3 * s, 0) * ang(0, 20, 0), CRIM_DK)
			B:block(crop, v(0.75 * s, 1.55 * s, 0.32 * s), F * CFrame.new(0.15 * s, 1.45 * s, 0.1 * s) * ang(0, 65, 0), CRIM)
			if heartGlow then
				return B:block(crop, v(0.42 * s, 0.3 * s, 0.42 * s), F * CFrame.new(0, 2.1 * s, 0) * ang(0, 45, 0), GOLD_LT, { mat = "Neon", name = "BloomHeart" })
			end
		end

		------------------------------------------------------------------
		-- SIDE STEMS with half-open pink roses
		------------------------------------------------------------------
		local function sideRose(y0, deg, r1, y1, r2, y2, s, tilt)
			local a = spineAt(y0)
			local m = pv(r1, deg, y1)
			local b = pv(r2, deg + 6, y2)
			B:bar(crop, a, m, 0.55, 0.55, STALK)
			B:bar(crop, m, b, 0.48, 0.48, STALK_LT)
			B:block(crop, v(0.7, 0.7, 0.7), CFrame.new(m) * ang(0, deg, 0), STALK_DK)
			thorn(a:Lerp(m, 0.5), hdir(deg + 90) + v(0, 0.4, 0), 0.9, 0.34)
			thorn(m:Lerp(b, 0.5), hdir(deg - 90) + v(0, 0.4, 0), 0.8, 0.32)
			local F = facing(b, deg + 6) * ang(tilt, 0, 0)
			rose(F, s, {
				{ 6, 0.75, 0.35, -48, 1.9, 2.1, PINK, PINK_LT, 0, PINK_DK },
				{ 5, 0.5, 0.5, -24, 1.6, 2.0, ROSE, ROSE_PALE, 36 },
				{ 4, 0.25, 0.6, -8, 1.1, 1.7, PINK_LT, nil, 15 },
			}, false)
		end
		sideRose(TOP + 4.6, 95, 2.5, TOP + 7.4, 3.8, TOP + 9.6, 0.78, -30)
		sideRose(TOP + 7.4, 235, 2.3, TOP + 10.0, 3.6, TOP + 12.2, 0.72, -32)

		------------------------------------------------------------------
		-- THE GIANT CRIMSON BLOOM on top
		------------------------------------------------------------------
		local BF = CFrame.new(spine[#spine] - v(0, 0.2, 0)) * CFrame.Angles(rad(-20), 0, 0)
		local heart = rose(BF, 1.45, {
			{ 7, 1.05, 0.3, -64, 2.3, 2.6, CRIM, CRIM_LT, 0, CRIM_DK },
			{ 6, 0.85, 0.45, -42, 2.2, 2.6, CRIM_LT, ROSE, 30 },
			{ 5, 0.6, 0.6, -22, 1.8, 2.4, ROSE_MID, ROSE_PALE, 12 },
			{ 4, 0.35, 0.7, -8, 1.3, 2.1, ROSE, nil, 50 },
		}, true, true)
		-- golden stamen tips peeking out of the heart
		for k = 0, 4 do
			local a = k * 72 + 30
			B:block(crop, v(0.22, 0.6, 0.22), BF * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 2.95, -0.55) * ang(-20, 0, 0), GOLD)
		end

		------------------------------------------------------------------
		-- VFX: rose glow, drifting petals, golden pollen motes, one light
		------------------------------------------------------------------
		B:emitter(heart, "glow", { name = "BloomGlow", color = { "#ff7d96", "#ffc2d0" }, rate = 1.4, size = { 2.2, 3.2, 0 }, trans = { 0.75, 0.65, 1 } })
		B:light(heart, { name = "BloomLight", color = "#ff6f8c", brightness = 1.3, range = 16 })
		local pz = B:block(crop, v(9, 1, 9), BF * CFrame.new(0, 2.4, 0), CRIM, { tr = 1, name = "PetalZone" })
		B:emitter(pz, "leaf", { name = "PetalDrift", color = { CRIM_LT, ROSE, PINK_LT }, rate = 1.4, size = 0.42 })
		local mz = B:block(crop, v(10, 12, 10), cf(0, TOP + 11.0, 0), CRIM, { tr = 1, name = "PollenZone" })
		B:emitter(mz, "sparkle", { name = "Pollen", color = { "#ffe27a", "#fff3c0", "#ffb3c6" }, rate = 5, size = { 0.15, 0.42, 0.05 }, life = { 1.4, 2.6 }, speed = { 0.2, 0.6 } })
	end,
}
