--!nocheck
-- Moonberry Bush (Starlight Ruins plant #2, Uncommon).
-- A tall, rounded silver-leaved bush growing out of the seal of an ancient
-- star-temple tile platform (pale stone slabs with gold trim and glowing
-- cyan constellation runes, indigo night soil, teal moss, star dust, a
-- violet crystal cluster and a broken fluted pillar). Twisting dusky-violet
-- branches carry three stacked masses of big rotated studded leaf cubes in
-- silver, pearl and lavender-grey. Chunky stepped crescent-moon berries in
-- pale lunar gold hang all over it on short stems, and a big glowing
-- crescent moon crowns the top. VFX: soft moon glow + twinkles on the crown,
-- silver moon-dust drifting down off the leaves, a cool pale light.
-- Static prop: no motion.luau.
return {
	DisplayName = "Moonberry Bush",
	Rarity = "Uncommon",
	Element = "Star",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Starlight Ruins)
		local EARTH, EARTH_DK, EARTH_LT = "#3b3566", "#2a2550", "#4d4684"
		local STONE, STONE2, STONE_DK, STONE_LT = "#e3dcef", "#d0c7e2", "#a99fc2", "#f4f0fb"
		local GOLD, GOLD_DK = "#f2c24f", "#c9952e"
		local MOSS, MOSS_DK, MOSS_LT = "#4f9e7c", "#367a62", "#78c79a"
		local RUNE = "#7fe8ff"
		local CRYS, CRYS_LT, CRYS_DK = "#9b7bff", "#c9b5ff", "#6f52d6"
		local DUST_G, DUST_C = "#ffe27a", "#b8f4ff"
		-- plant
		local BARK, BARK_DK, BARK_LT = "#5a4a8c", "#433770", "#7564a8"
		local LEAF_SH, LEAF_DK, LEAF, LEAF_MID, LEAF_HI = "#222c63", "#2c3a7a", "#3b4fa0", "#4a5fb4", "#b8c4f0"
		local STEM, STEM_DK = "#9a8ad0", "#7564a8"
		local MOON, MOON_DK, MOON_LT, MOON_GLOW = "#ffe680", "#f6c24a", "#fff5c6", "#fff8dc"

		local seed = 1823
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function polar(a, r, y)
			return CFrame.new(math.sin(rad(a)) * r, y, -math.cos(rad(a)) * r) * CFrame.Angles(0, -rad(a), 0)
		end

		------------------------------------------------------------ ruin platform
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(y0, h, r, col)
			B:block(soil, v(2 * r, h, 0.83 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(0.83 * r, h - 0.03, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.42 * r, h - 0.06, 1.42 * r), cf(0, y0 + h / 2, 0, 0, 45, 0), col, S)
		end
		-- indigo night soil base with rough clods
		oct(0, 0.6, 4.7, EARTH_DK)
		for i = 0, 9 do
			local a = i * 36 + rnd(-8, 8)
			local w, d, h = rnd(1.4, 2.0), rnd(1.0, 1.4), rnd(0.5, 0.8)
			B:block(soil, v(w, h, d), polar(a, 4.6 + rnd(-0.1, 0.2), h / 2) * ang(0, rnd(-8, 8), 0), pick({ EARTH, EARTH_DK, EARTH_LT }), S)
		end
		-- tier 1: ring of eight worn stone slabs (gaps read as tile joints)
		oct(0.55, 0.5, 3.4, STONE_DK)
		for i = 0, 7 do
			local a = i * 45 + 22.5
			local hh = 0.62 + rnd(-0.04, 0.06)
			local col = (i % 2 == 0) and STONE or STONE2
			if i == 2 then -- one slab knocked askew
				B:block(soil, v(2.6, hh, 1.5), polar(a, 3.75, 0.55 + hh / 2) * ang(4, 9, -3), col, S)
			else
				B:block(soil, v(2.75, hh, 1.55), polar(a, 3.62, 0.55 + hh / 2), col, S)
			end
		end
		-- gold trim along the front slabs' top edge + glowing constellation runes
		for _, a in { 157.5, 202.5 } do
			B:block(soil, v(2.5, 0.12, 0.22), polar(a + 180, 4.3, 1.2), GOLD, S)
		end
		B:block(soil, v(2.5, 0.12, 0.22), polar(22.5, 4.3, 1.2), GOLD, S)
		-- runes: neon dots on the slab faces linked by thin gold lines
		local function rune(a, r, pts)
			local base = polar(a, r, 0)
			local prev
			for _, q in pts do
				local p = base * CFrame.new(q[1], q[2], -0.05)
				B:block(soil, v(0.22, 0.22, 0.1), p, RUNE, { name = "Soil", mat = "Neon" })
				if prev then
					local a0, a1 = prev.Position, p.Position
					local c, len = P.aim(a0, a1, base.LookVector)
					B:block(soil, v(0.07, 0.07, len), c, GOLD, S)
				end
				prev = p
			end
		end
		rune(-22.5, 4.42, { { -0.9, 0.75 }, { -0.35, 0.95 }, { 0.2, 0.7 }, { 0.8, 0.9 } })
		rune(22.5, 4.42, { { -0.8, 0.95 }, { -0.2, 0.7 }, { 0.5, 0.85 } })
		rune(247.5, 4.42, { { -0.6, 0.7 }, { 0.1, 0.92 }, { 0.7, 0.72 } })
		-- tier 2: inner tiles + seal plate
		oct(1.05, 0.45, 2.4, STONE_DK)
		for i = 0, 7 do
			local a = i * 45
			B:block(soil, v(1.62, 0.5, 1.15), polar(a, 2.25, 1.05 + 0.25), (i % 2 == 0) and STONE_LT or STONE, S)
		end
		B:block(soil, v(2.9, 0.5, 2.9), cf(0, 1.3, 0, 0, 22.5, 0), STONE_LT, S)
		B:block(soil, v(3.0, 0.12, 0.2), cf(0, 1.57, -1.48, 0, 0, 0), GOLD, S)
		B:block(soil, v(3.0, 0.12, 0.2), cf(0, 1.57, 1.48, 0, 0, 0), GOLD, S)
		-- the seal's soil bed the bush grows out of
		B:block(soil, v(2.5, 0.2, 2.5), cf(0, 1.6, 0, 0, 22.5, 0), EARTH, S)
		B:block(soil, v(1.3, 0.24, 1.3), cf(0.1, 1.62, 0.05, 0, 67, 0), EARTH_LT, S)
		-- moss draping over tile edges
		for _, m in { { 60, 4.35, 1.8, MOSS, 1.15 }, { 250, 4.3, 1.6, MOSS_LT, 1.15 }, { 115, 4.4, 1.3, MOSS_DK, 1.15 }, { 300, 2.85, 1.3, MOSS, 1.58 }, { 140, 2.85, 1.1, MOSS_LT, 1.58 } } do
			B:block(soil, v(m[3], 0.22, 1.0), polar(m[1], m[2], m[5]) * ang(-12, 0, 0), m[4], S)
			B:block(soil, v(m[3] * 0.55, 0.22, 0.6), polar(m[1] + 6, m[2] + 0.1, m[5] - 0.35) * ang(-55, 0, 0), m[4], S)
		end
		-- broken fluted pillar stump (back-left)
		local PL = v(-3.05, 1.17, 2.55)
		B:block(soil, v(1.9, 0.4, 1.9), CFrame.new(PL + v(0, 0.2, 0)) * ang(0, 20, 0), STONE_DK, S)
		B:block(soil, v(1.45, 2.1, 1.45), CFrame.new(PL + v(0, 1.45, 0)) * ang(0, 20, 0), STONE_LT, S)
		B:block(soil, v(1.25, 2.12, 1.25), CFrame.new(PL + v(0, 1.45, 0)) * ang(0, 65, 0), STONE2, S)
		B:block(soil, v(1.55, 0.25, 1.55), CFrame.new(PL + v(0, 0.95, 0)) * ang(0, 20, 0), GOLD, S)
		B:block(soil, v(1.0, 0.6, 1.2), CFrame.new(PL + v(-0.15, 2.75, 0.05)) * ang(0, 20, 6), STONE_LT, S)
		B:block(soil, v(0.6, 0.45, 0.6), CFrame.new(PL + v(-0.3, 3.2, -0.1)) * ang(0, 35, 10), STONE, S)
		-- a fallen chunk of it
		B:block(soil, v(1.0, 0.8, 0.8), CFrame.new(3.5, 1.55, 1.9) * ang(0, -30, -12), STONE_LT, S)
		B:block(soil, v(1.05, 0.2, 0.85), CFrame.new(3.5, 1.55, 1.9) * ang(0, -30, -12) * CFrame.new(0.2, 0, 0), GOLD_DK, S)
		-- little violet crystal cluster (front-left)
		local CC = v(-2.65, 1.4, -2.75)
		B:block(soil, v(0.55, 1.3, 0.55), CFrame.new(CC + v(0, 0.55, 0)) * ang(0, 30, 10), CRYS, S)
		B:block(soil, v(0.4, 0.85, 0.4), CFrame.new(CC + v(0.45, 0.35, 0.15)) * ang(0, 10, -24), CRYS_LT, S)
		B:block(soil, v(0.35, 0.7, 0.35), CFrame.new(CC + v(-0.35, 0.3, 0.2)) * ang(10, 50, 26), CRYS_DK, S)
		B:block(soil, v(0.32, 0.45, 0.32), CFrame.new(CC + v(0, 0.55, 0)) * ang(0, 30, 10) * CFrame.new(0, 0.8, 0), CRYS_LT, S)
		B:block(soil, v(0.22, 0.3, 0.22), CFrame.new(CC + v(0.45, 0.35, 0.15)) * ang(0, 10, -24) * CFrame.new(0, 0.55, 0), "#ece4ff", S)
		-- star dust specks
		for _, d in { { -1.6, 1.57, -1.4, DUST_G }, { 1.7, 1.57, 1.1, DUST_C }, { -3.6, 1.2, -1.2, DUST_G }, { 3.9, 1.22, -0.6, DUST_C }, { 0.8, 1.2, -3.8, DUST_G }, { -1.9, 1.57, 1.6, DUST_G }, { -2.4, 1.2, -3.2, DUST_C } } do
			B:block(soil, v(0.24, 0.16, 0.24), cf(d[1], d[2], d[3], 0, rnd(0, 90), 0), d[4], S)
		end

		------------------------------------------------------------ bush
		local crop = B:bone("Crop", "Root", v(0, 1.6, 0))
		local glows = {}

		-- branches (chunky bars through control points)
		local function branch(pts, w)
			for i = 1, #pts - 1 do
				local ww = w * (1 - 0.15 * (i - 1))
				B:bar(crop, pts[i], pts[i + 1] + (pts[i + 1] - pts[i]).Unit * 0.15, ww, ww, (i % 2 == 1) and BARK or BARK_DK)
			end
		end
		B:block(crop, v(1.7, 0.7, 1.7), cf(0, 1.85, 0, 0, 20, 0), BARK_DK)
		B:block(crop, v(1.3, 0.9, 1.3), cf(0, 2.0, 0, 0, 65, 0), BARK)
		branch({ v(0, 1.6, 0), v(0.15, 4.5, 0.05), v(0, 8.0, 0), v(0.05, 11.2, 0) }, 1.05)
		branch({ v(0.1, 2.3, 0), v(1.0, 3.4, -0.4) }, 0.6)
		branch({ v(-0.1, 2.4, 0.1), v(-1.0, 3.5, 0.4) }, 0.6)

		-- orderly leaf dome: big core cube, a ring of big studded leaf cubes turned to
		-- face outward, a cap and a slightly darker underside ring
		local function dome(c, core, nRing, rRing, sRing, ringY, nCap, rCap, sCap, capY, off, hiMask)
			B:block(crop, v(core, core * 0.9, core), CFrame.new(c) * ang(0, off, 0), LEAF_DK)
			for i = 0, nRing - 1 do
				local a = off + i * 360 / nRing
				local p = c + v(math.sin(rad(a)) * rRing, ringY, -math.cos(rad(a)) * rRing)
				B:block(crop, v(sRing, sRing * 0.9, sRing), CFrame.new(p) * CFrame.Angles(0, -rad(a), 0) * ang(rnd(-5, 5), rnd(-8, 8), rnd(-5, 5)), (i % 2 == 0) and LEAF or LEAF_MID)
				-- underside: tucked darker cube beneath every other ring cube
				if i % 2 == 0 then
					local q = c + v(math.sin(rad(a + 30)) * rRing * 0.7, ringY - sRing * 0.55, -math.cos(rad(a + 30)) * rRing * 0.7)
					B:block(crop, v(sRing * 0.85, sRing * 0.7, sRing * 0.85), CFrame.new(q) * CFrame.Angles(0, -rad(a + 30), 0), LEAF_SH)
				end
			end
			for i = 0, nCap - 1 do
				local a = off + 360 / nRing / 2 + i * 360 / nCap
				local p = c + v(math.sin(rad(a)) * rCap, capY, -math.cos(rad(a)) * rCap)
				local col = hiMask[i + 1] and LEAF_HI or LEAF_MID
				B:block(crop, v(sCap, sCap * 0.9, sCap), CFrame.new(p) * CFrame.Angles(0, -rad(a), 0) * ang(rnd(-5, 5), rnd(-8, 8), rnd(-5, 5)), col)
			end
		end
		-- lower dome (wide) and upper dome (smaller), two tiers only
		dome(v(0, 5.6, 0), 4.2, 7, 2.35, 2.9, -0.2, 4, 1.15, 2.6, 1.45, 10, { true, false, true, false })
		B:block(crop, v(2.3, 2.0, 2.3), cf(0.1, 7.6, 0.05, 0, 30, 0), LEAF_HI)
		dome(v(0.05, 9.6, 0.05), 3.2, 5, 1.6, 2.4, -0.15, 3, 0.75, 2.1, 1.2, 46, { true, false, false })
		B:block(crop, v(1.8, 1.6, 1.8), cf(0.1, 11.4, 0.05, 0, 15, 0), LEAF_HI)

		-- stepped crescent moon in frame F (local +Z faces out, arc opens toward local +X)
		local function crescent(F, s, glow, idx, thick)
			local r = 0.72 * s
			local th = (thick or 1) * 0.55 * s
			local arc = { { 180, 0.62, 0.8, MOON }, { 135, 0.52, 0.68, MOON_LT }, { 225, 0.52, 0.68, MOON_DK },
				{ 95, 0.4, 0.56, MOON_LT }, { 265, 0.4, 0.56, MOON_DK }, { 62, 0.27, 0.36, MOON_LT }, { 298, 0.27, 0.36, MOON } }
			for _, q in arc do
				local A = F * CFrame.Angles(0, 0, rad(q[1]))
				B:block(crop, v(q[2] * s, q[3] * s, th * (q[2] / 0.62 * 0.4 + 0.6)), A * CFrame.new(r, 0, 0), q[4])
			end
			if glow then
				local g = B:block(crop, v(0.16 * s, 0.62 * s, th * 0.75), F * CFrame.new(-r + 0.36 * s, 0, 0), MOON_GLOW, { mat = "Neon", name = "MoonGlow" .. idx })
				table.insert(glows, g)
			end
		end
		-- hang a crescent clearly outside the leaves: short stem out of the dome edge,
		-- berry dangling below it facing outward
		local function berry(a, y, rOut, s, roll, glow, idx, rIn, yIn)
			local out = v(math.sin(rad(a)), 0, -math.cos(rad(a)))
			local C = out * rOut + v(0, y, 0)
			local F = CFrame.lookAt(C, C + out) * CFrame.Angles(0, 0, rad(roll))
			local top = C + v(0, 0.75 * s, 0)
			B:bar(crop, out * rIn + v(0, yIn, 0), top + v(0, 0.1, 0), 0.26, 0.26, STEM)
			B:block(crop, v(0.45, 0.34, 0.45), CFrame.new(top) * ang(0, -a, 0), STEM_DK)
			crescent(F * CFrame.Angles(0, math.pi, 0), s, glow, idx)
		end
		-- off the lower dome's rim
		berry(-18, 3.35, 4.55, 1.7, -18, true, 1, 3.4, 4.6)
		berry(54, 3.4, 4.55, 1.65, 20, false, 2, 3.4, 4.6)
		berry(126, 3.3, 4.55, 1.7, -24, true, 3, 3.4, 4.6)
		berry(198, 3.4, 4.55, 1.65, 14, false, 4, 3.4, 4.6)
		berry(270, 3.35, 4.55, 1.7, -20, false, 5, 3.4, 4.6)
		-- off the upper dome's sides, above the lower dome
		berry(18, 8.45, 3.75, 1.45, 22, true, 6, 2.6, 9.4)
		berry(108, 8.5, 3.75, 1.45, -18, false, 7, 2.6, 9.4)
		berry(198 - 8, 8.4, 3.75, 1.45, 25, false, 8, 2.6, 9.4)
		berry(288, 8.5, 3.75, 1.45, -22, false, 9, 2.6, 9.4)

		-- the crown: a big glowing crescent moon on a stem rising from the top tuft
		branch({ v(0.1, 11.8, 0.05), v(0.15, 12.6, 0.0) }, 0.42)
		local CR = CFrame.new(0.2, 13.55, -0.05) * CFrame.Angles(0, rad(25), 0) * CFrame.Angles(0, 0, rad(-25))
		crescent(CR, 1.8, true, 12, 1.5)

		------------------------------------------------------------ fx
		local crown = glows[#glows]
		B:emitter(crown, "glow", { name = "MoonAura", color = "#fff2c0", rate = 1.2, size = { 1.2, 2.2, 0.6 }, life = { 1.2, 2.0 } })
		B:emitter(crown, "sparkle", { name = "MoonTwinkle", color = { "#ffffff", "#ffe28a" }, rate = 5, size = { 0.12, 0.5, 0 }, speed = { 0.5, 1.6 } })
		local dustPart = B:block(crop, v(8.2, 0.3, 8.2), cf(0, 9.2, 0), LEAF_DK, { tr = 1, name = "MoonDustZone" })
		B:emitter(dustPart, "leaf", { name = "MoonDust", color = { "#e6f2ff", "#a9c8ff" }, rate = 4, size = { 0.22, 0.28, 0 }, life = { 2.5, 3.5 }, speed = { 0.2, 0.6 }, accel = { 0, -1.2, 0 }, light = 0.5 })
		B:emitter(glows[1], "sparkle", { name = "BerryTwinkle", color = { "#ffffff", "#bfe9ff" }, rate = 2, size = { 0.1, 0.35, 0 } })
		B:light(crown, { name = "MoonLight", color = "#cfe0ff", brightness = 0.9, range = 12 })
	end,
}
