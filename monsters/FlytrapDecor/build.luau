--!nocheck
-- Snappy Flytrap (Flytrap Stage decoration). A lush carnivorous-plant cluster
-- for the Snapjaw Flytrap guardian's section of the map, in the same stud
-- style as the guardian and the stage plants:
-- * a rich stepped bog-dirt mound with moss pads, stones, grass tufts and a
--   murky little bog puddle with a lily pad and cattails (bone "Soil")
-- * one BIG hero trap on a thick stepped, curving 3-bone stem: chunky stepped
--   green lobes with dark edges, saturated pink-red insides with a dark throat
--   and trigger hairs, interlocking rows of cream cilia teeth, lime neon drool
-- * three smaller traps on their own stems (one closed and digesting, with a
--   faint lime glow leaking from the seam)
-- * a rosette of chunky stepped leaf blades, a leafy collar and a few big
--   rotated leaf cubes for mass
-- * the fly (black body, red neon eyes, translucent flapping wings); its rest
--   spot is the landing pad inside the hero trap
-- No face, no eyes: it is a plant. The traps face -Z (front). Each trap is
-- built in its own frame T (hinge at the origin, mouth toward local -Z); the
-- lid is built OPEN at `open` degrees about the hinge and the motion
-- animates relative to that.
return {
	DisplayName = "Snappy Flytrap",
	Rarity = "Common",
	Element = "Decor",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (matches the Snapjaw Flytrap guardian + stage plants)
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local MUD = "#2e1d12"
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local BOG, BOG_LT = "#2f6a50", "#6fb58a"
		local REED, CATTAIL = "#7f8f3a", "#5a3a1e"
		local GREEN, GREEN_DK, GREEN_LT, GREEN_TOP = "#3caa3c", "#1f6e2a", "#a6e04c", "#58c447"
		local INSIDE, INSIDE_DK, RIM, THROAT = "#ff5c7c", "#b02448", "#c92a48", "#5c0f25"
		local HAIR = "#ffb3c4"
		local CREAM = "#fff4d2"
		local LIME = "#86ff3c"
		local NEON = { mat = "Neon" }

		local seed = 7321
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end

		------------------------------------------------------------------
		-- MOUND: stepped bog-dirt tiers (rounded "pixel circle" + chunky edge)
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.4, 2.2), rnd(1.2, 1.6)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.3)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 4.4, DIRT_DK, 11, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.6, 3.1, DIRT, 7, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.4, 0.4, 1.9, DIRT_LT, 0, {}, 0)

		-- moss pads draped over the tier edges
		for _, m in { { -25, 4.35, 1.12, 2.0, MOSS }, { 40, 4.3, 1.1, 1.8, MOSS_DK }, { 150, 4.4, 1.1, 1.7, MOSS }, { 250, 4.3, 1.12, 1.9, MOSS_DK } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], m[3], -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[4], 0.3, 1.3), c * ang(-12, 0, 0), m[5], S)
		end
		-- stones
		for _, s in { { 3.6, 0.95, -2.6, 0.9, 25, STONE }, { 4.1, 0.85, -1.6, 0.6, 10, STONE_LT }, { -3.9, 0.9, 1.9, 0.8, -20, STONE_DK }, { 1.6, 0.9, 4.0, 0.7, 40, STONE } } do
			B:block(soil, v(s[4] * 1.2, s[4], s[4]), cf(s[1], s[2], s[3], rnd(-10, 10), s[5], rnd(-10, 10)), s[6], S)
		end
		-- tiny grass tufts
		for _, g in { { 4.6, -0.4 }, { 2.4, -4.0 }, { -4.6, -0.6 } } do
			B:block(soil, v(0.4, 0.9, 0.4), cf(g[1], 0.95, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.3, 0.6, 0.3), cf(g[1] + 0.3, 0.9, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end

		-- bog patch: murky puddle sunk into the front of the middle tier
		local BC = v(0.5, 1.62, -2.5)
		B:block(soil, v(2.4, 0.3, 1.5), CFrame.new(BC + v(0, -0.15, 0)) * ang(0, 8, 0), BOG, S)
		B:block(soil, v(1.4, 0.28, 2.1), CFrame.new(BC + v(0.1, -0.19, -0.05)) * ang(0, 8, 0), BOG, S)
		B:block(soil, v(0.9, 0.1, 0.35), CFrame.new(BC + v(0.4, 0.01, -0.3)) * ang(0, 8, 0), BOG_LT, S)
		B:block(soil, v(0.8, 0.45, 0.6), CFrame.new(BC + v(-1.35, -0.05, -0.4)) * ang(0, 20, 0), MUD, S)
		B:block(soil, v(0.7, 0.4, 0.6), CFrame.new(BC + v(1.3, -0.05, -0.55)) * ang(0, -15, 0), MUD, S)
		-- lily pad + cattails
		B:block(soil, v(0.8, 0.1, 0.8), CFrame.new(BC + v(-0.5, 0.03, -0.2)) * ang(0, 30, 0), GREEN, S)
		B:block(soil, v(0.2, 1.8, 0.2), CFrame.new(BC + v(-1.2, 0.9, 0.55)) * ang(0, 0, 8), REED, S)
		B:block(soil, v(0.35, 0.6, 0.35), CFrame.new(BC + v(-1.32, 1.65, 0.55)) * ang(0, 0, 8), CATTAIL, S)
		B:block(soil, v(0.2, 1.3, 0.2), CFrame.new(BC + v(-0.85, 0.65, 0.75)) * ang(-6, 0, -10), REED, S)
		local bub = B:block(soil, v(1.6, 0.1, 1.2), CFrame.new(BC + v(0, 0.06, 0)), BOG, { tr = 1, name = "Soil" })
		B:emitter(bub, "bubble", { name = "BogBubbles", color = { "#bfffb0", LIME }, rate = 1.6, size = { 0.15, 0.3, 0.4 }, speed = { 0.3, 0.8 } })

		------------------------------------------------------------------
		-- LEAF CUBES at the back (mass, like the stage plants)
		------------------------------------------------------------------
		local bush = B:bone("Bush", "Root", v(0, 1.8, 2.2))
		B:block(bush, v(2.6, 2.6, 2.6), cf(-1.3, 2.6, 2.3, 12, 28, 8), GREEN_DK)
		B:block(bush, v(2.4, 2.4, 2.4), cf(1.4, 2.5, 2.5, -10, -20, -12), GREEN)
		B:block(bush, v(2.0, 2.0, 2.0), cf(0.1, 3.5, 2.9, 18, 40, -10), GREEN_TOP)
		B:block(bush, v(1.1, 0.4, 1.1), cf(0.1, 4.55, 2.9, 18, 40, -10), GREEN_LT)

		------------------------------------------------------------------
		-- ROSETTE: chunky stepped leaf blades on their own bones (sway)
		------------------------------------------------------------------
		local function blade(bone, base, a, len, w, up, col)
			local f = CFrame.new(base) * CFrame.Angles(0, -rad(a), 0) * CFrame.Angles(rad(up), 0, 0)
			B:block(bone, v(w, 0.4, len * 0.55), f * CFrame.new(0, 0, -len * 0.27), col)
			B:block(bone, v(0.35, 0.5, len * 0.6), f * CFrame.new(0, 0.03, -len * 0.33), GREEN_LT)
			local f2 = f * CFrame.new(0, 0, -len * 0.52) * CFrame.Angles(rad(-24), 0, 0)
			B:block(bone, v(w * 0.68, 0.4, len * 0.34), f2 * CFrame.new(0, 0, -len * 0.15), col)
		end
		local BLADES = {
			{ -48, 3.3, 1.5, 34, GREEN },
			{ -95, 3.6, 1.6, 30, GREEN_DK },
			{ -140, 3.4, 1.5, 32, GREEN },
			{ 175, 3.2, 1.4, 36, GREEN_DK },
			{ 128, 3.6, 1.6, 28, GREEN },
			{ 88, 3.4, 1.5, 32, GREEN_DK },
			{ 48, 3.0, 1.4, 30, GREEN_TOP },
		}
		for i, b in BLADES do
			local a = rad(b[1])
			local base = v(0.9 * math.sin(a), 1.75, 0.4 - 0.9 * math.cos(a))
			local lb = B:bone("Leaf" .. i, "Root", base)
			blade(lb, base, b[1], b[2], b[3], b[4], b[5])
		end

		------------------------------------------------------------------
		-- HERO STEM: thick stepped, gently curving 3-bone chain
		------------------------------------------------------------------
		local st1 = B:bone("Stem1", "Root", v(0.2, 1.6, 0.9))
		B:block(st1, v(2.2, 0.6, 2.2), cf(0.2, 1.95, 0.9), GREEN_DK)
		B:block(st1, v(1.6, 2.0, 1.6), cf(0.2, 3.0, 0.85), GREEN_DK)
		B:block(st1, v(1.9, 0.4, 1.9), cf(0.18, 3.95, 0.8), GREEN_LT)
		-- leafy collar hugging the stem base
		for i = 0, 5 do
			local a = i * 60 + 15
			local c = CFrame.new(0.2, 2.0, 0.9) * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.55, -1.15) * ang(-32, 0, 0)
			B:block(st1, v(1.1, 1.5, 0.4), c, (i % 2 == 0) and GREEN or GREEN_TOP)
		end
		local st2 = B:bone("Stem2", "Stem1", v(0.15, 3.9, 0.8))
		B:block(st2, v(1.35, 1.7, 1.35), cf(0.1, 4.75, 0.62, -8, 0, 0), GREEN)
		B:block(st2, v(0.3, 1.0, 0.7), cf(0.8, 4.7, 0.62, -8, 0, 0), GREEN_LT)
		B:block(st2, v(1.6, 0.35, 1.6), cf(0.05, 5.55, 0.45, -8, 0, 0), GREEN_DK)
		local st3 = B:bone("Stem3", "Stem2", v(0.05, 5.5, 0.45))
		B:block(st3, v(1.15, 1.3, 1.15), cf(0.0, 6.1, 0.3, -14, 0, 0), GREEN)
		B:block(st3, v(0.25, 0.8, 0.6), cf(-0.6, 6.1, 0.3, -14, 0, 0), GREEN_LT)

		------------------------------------------------------------------
		-- TRAP builder (frame T: hinge at origin, mouth toward local -Z)
		------------------------------------------------------------------
		local function trap(o)
			local s, T = o.s, o.T
			local full = o.full
			local lower = B:bone(o.name, o.parent, T)
			local lid = B:bone(o.name .. "Lid", o.name, T)
			local TL = T * CFrame.Angles(rad(o.open), 0, 0)
			local function at(F, x, y, z, rx, ry, rz)
				return F * CFrame.new(x * s, y * s, z * s) * ang(rx or 0, ry or 0, rz or 0)
			end
			local function bk(bone, F, sx, sy, sz, x, y, z, col, rx, ry, rz, opts)
				return B:block(bone, v(sx * s, sy * s, sz * s), at(F, x, y, z, rx, ry, rz), col, opts)
			end
			local tw = math.max(0.2, 0.28 * s)
			local function tooth(bone, F, x, y, z, rx, rz, len)
				B:block(bone, v(tw, len * s, tw), at(F, x, y, z, rx, 0, rz), CREAM)
			end
			for _, k in { -1, 1 } do
				local bone, F = lower, T
				if k > 0 then
					bone, F = lid, TL
				end
				-- inside: pink pad, darker centre, red rim (wider = red lip line)
				bk(bone, F, 3.8, 0.2, 3.2, 0, 0.12 * k, -1.9, INSIDE)
				if full then
					bk(bone, F, 1.4, 0.1, 2.6, 0, 0.02 * k, -1.8, INSIDE_DK)
				end
				bk(bone, F, 4.4, 0.3, 3.6, 0, 0.3 * k, -1.8, RIM)
				bk(bone, F, 5.0, 0.3, 2.2, 0, 0.3 * k, -1.8, RIM)
				-- stepped green outer lobe (oval outline: bulge in the middle)
				bk(bone, F, 4.2, 0.7, 3.6, 0, 0.75 * k, -1.8, GREEN)
				bk(bone, F, 4.8, 0.6, 2.2, 0, 0.75 * k, -1.8, GREEN)
				bk(bone, F, 3.4, 0.5, 2.8, 0, 1.3 * k, -1.7, k > 0 and GREEN_TOP or GREEN)
				if full then
					bk(bone, F, 2.0, 0.4, 1.6, 0, 1.68 * k, -1.5, GREEN_DK)
				end
				-- darker stepped edges: side panels + front lip
				if full then
					bk(bone, F, 3.0, 0.6, 0.4, 0, 0.72 * k, -3.75, GREEN_DK)
					bk(bone, F, 3.2, 0.3, 0.6, 0, 0.3 * k, -3.75, RIM)
					for _, sd in { -1, 1 } do
						bk(bone, F, 0.3, 0.5, 2.0, sd * 2.5, 0.75 * k, -1.8, GREEN_DK)
						if k > 0 then
							bk(bone, F, 0.25, 0.35, 1.7, sd * 1.55, 1.3 * k, -1.75, GREEN_LT) -- vein
						end
					end
					-- trigger hairs (lower pad)
					if k < 0 then
						for _, h in { { -0.95, -1.3 }, { 0.85, -2.4 }, { 0.2, -0.9 } } do
							bk(bone, F, 0.14, 0.5, 0.14, h[1], 0.22, h[2], HAIR)
						end
					end
				end
				-- cilia teeth: lower lobe points up, lid points down; rows offset
				-- by half a step so they interlock when the trap is shut
				local ty = -0.3 * k
				local front = full and (k < 0 and { -1.5, -0.9, -0.3, 0.3, 0.9, 1.5 } or { -1.2, -0.6, 0, 0.6, 1.2 })
					or (k < 0 and { -1.2, -0.4, 0.4, 1.2 } or { -0.8, 0, 0.8 })
				local fz = full and -4.0 or -3.68
				for _, x in front do
					tooth(bone, F, x, ty, fz, 24 * k, 0, 1.05)
				end
				local sideZ = full and (k < 0 and { -3.2, -2.4, -1.6, -0.8 } or { -2.8, -2.0, -1.2, -0.4 })
					or (k < 0 and { -2.9, -1.4 } or { -2.1 })
				for _, sd in { -1, 1 } do
					for _, z in sideZ do
						local x = (math.abs(z + 1.8) < 1.1) and 2.55 or 2.25
						tooth(bone, F, sd * x, ty, z, 0, 24 * k * sd, 1.0)
					end
					if full then
						tooth(bone, F, sd * 2.05, ty, -3.6, 17 * k, 17 * k * sd, 1.0)
					end
				end
			end
			-- hinge block (lower) carrying the stem joint; deep throat wall
			bk(lower, T, 2.6, 1.1, 1.0, 0, -0.65, 0.4, GREEN_DK)
			if o.throat then
				bk(lower, T, 3.4, 1.0, 0.3, 0, 0.35, 0.0, THROAT)
				bk(lid, TL, 2.4, 0.8, 0.8, 0, 0.6, 0.35, GREEN_DK)
			end
			return lower, lid, at
		end

		------------------------------------------------------------------
		-- HERO TRAP (big, open, drooling) on Stem3
		------------------------------------------------------------------
		local HT = CFrame.new(0, 7.0, 0.1) * CFrame.Angles(rad(-14), 0, 0)
		local hero, heroLid, hat = trap({ name = "Trap", parent = "Stem3", T = HT, s = 1, open = 70, full = true, throat = true })
		-- extra stepped speckles on the top lobe
		local HTL = HT * CFrame.Angles(rad(70), 0, 0)
		B:block(heroLid, v(0.6, 0.25, 0.6), hat(HTL, 1.0, 1.6, -0.9), GREEN_DK)
		B:block(heroLid, v(0.5, 0.25, 0.8), hat(HTL, -1.2, 1.6, -2.3), GREEN_DK)
		B:block(heroLid, v(0.7, 0.25, 0.7), hat(HTL, 1.85, 1.15, -2.6), GREEN_LT)
		B:block(heroLid, v(0.6, 0.25, 0.9), hat(HTL, -1.85, 1.15, -1.0), GREEN_LT)
		B:block(heroLid, v(1.6, 0.3, 0.5), hat(HTL, 0.3, 1.62, -3.2), GREEN_DK)
		-- drool strand + drop off the lower lip (own bone: hangs straight down)
		local lipP = hat(HT, 1.3, -0.5, -3.95).Position
		local drool = B:bone("Drool", "Trap", lipP)
		B:block(drool, v(0.24, 1.0, 0.24), CFrame.new(lipP + v(0, -0.45, 0)), LIME, NEON)
		local drop = B:block(drool, v(0.45, 0.5, 0.45), CFrame.new(lipP + v(0, -1.1, 0)), LIME, { mat = "Neon", name = "DroolDrop" })
		B:emitter(drop, "drip", { name = "DroolDrip", color = LIME, rate = 1.0, size = { 0.3, 0.25, 0.12 } })
		-- mouth FX (snap burst, burp puff, flash)
		local mfx = B:block(hero, v(3, 0.6, 2.4), hat(HT, 0, 0.5, -2.0), GREEN, { tr = 1, name = "MouthFX" })
		B:emitter(mfx, "burst", { name = "SnapBurst", color = { "#ffffff", LIME }, size = { 0.8, 0.5, 0 }, speed = { 7, 12 } })
		B:emitter(mfx, "smoke", { name = "BurpPuff", rate = 0, color = { "#d6ff9a", "#86e04a" }, size = { 0.8, 2.0, 2.8 }, trans = { 0.35, 0.55, 1 }, speed = { 2, 4 }, life = { 0.8, 1.4 }, spread = 25, accel = { 0, 2, 0 }, light = 0.3 })
		B:light(mfx, { name = "MouthLight", color = LIME, brightness = 0, range = 9 })
		local lfx = B:block("Root", v(6, 0.4, 6), cf(0, 2.2, 0.4), GREEN, { tr = 1, name = "LeafFX" })
		B:emitter(lfx, "leaf", { name = "SnapLeaves", rate = 0, color = { GREEN_LT, GREEN, "#e8f58a" }, speed = { 3, 7 }, size = { 0.5, 0.45, 0.25 }, life = { 1.0, 1.8 }, spread = 60, accel = { 0, -5, 0 } })

		------------------------------------------------------------------
		-- SMALL TRAPS on their own stems
		------------------------------------------------------------------
		local function smallStem(name, base, top, w, col)
			local sb = B:bone(name, "Root", base)
			local knee = base:Lerp(top, 0.5) + v(0, 0.25, 0)
			B:bar(sb, base, knee, w, w, col)
			B:bar(sb, knee, top, w * 0.85, w * 0.85, col)
			B:block(sb, v(w + 0.15, w + 0.15, w + 0.15), CFrame.new(knee), GREEN_LT)
			return sb
		end
		-- B: front-right, mid height, snaps at nothing
		local TB = CFrame.new(3.9, 4.3, -0.6) * CFrame.Angles(0, rad(-42), 0) * CFrame.Angles(rad(14), 0, 0)
		local sB = 0.55
		smallStem("StemB", v(2.3, 1.5, 0.3), (TB * CFrame.new(0, -0.95 * sB, 0.45 * sB)).Position, 0.75, GREEN_DK)
		local tB, _, batB = trap({ name = "TrapB", parent = "StemB", T = TB, s = sB, open = 40 })
		local bfx = B:block(tB, v(1.4, 0.4, 1.2), batB(TB, 0, 0.6, -2.0), GREEN, { tr = 1, name = "TrapBFX" })
		B:emitter(bfx, "burst", { name = "SmallSnap", color = { "#ffffff", LIME }, size = { 0.5, 0.3, 0 }, speed = { 5, 9 } })
		-- C: front-left, low, idle chomper
		local TC = CFrame.new(-3.4, 3.0, -1.7) * CFrame.Angles(0, rad(38), 0) * CFrame.Angles(rad(10), 0, 0)
		local sC = 0.47
		smallStem("StemC", v(-2.2, 1.5, -0.5), (TC * CFrame.new(0, -0.95 * sC, 0.45 * sC)).Position, 0.65, GREEN)
		trap({ name = "TrapC", parent = "StemC", T = TC, s = sC, open = 40 })
		-- D: back-left, high, CLOSED and digesting (lime glow leaks from the seam)
		local TD = CFrame.new(-2.7, 5.2, 1.6) * CFrame.Angles(0, rad(105), 0) * CFrame.Angles(rad(8), 0, 0)
		local sD = 0.55
		smallStem("StemD", v(-1.3, 1.7, 1.5), (TD * CFrame.new(0, -0.95 * sD, 0.45 * sD)).Position, 0.75, GREEN_DK)
		local tD, _, datD = trap({ name = "TrapD", parent = "StemD", T = TD, s = sD, open = 0 })
		B:block(tD, v(2.6 * sD, 0.14, 0.2), datD(TD, 0, 0, -4.12), LIME, { mat = "Neon", name = "DigestGlow1" })
		for _, sd in { -1, 1 } do
			B:block(tD, v(0.2, 0.14, 1.6 * sD), datD(TD, sd * 2.62, 0, -1.8), LIME, { mat = "Neon", name = "DigestGlow" .. (sd < 0 and "L" or "R") })
		end

		------------------------------------------------------------------
		-- THE FLY: rest spot = the landing pad inside the hero trap
		------------------------------------------------------------------
		local LAND = hat(HT, 0, 0.42, -2.1).Position
		local fly = B:bone("Fly", "Root", LAND)
		local function fp(x, y, z)
			return CFrame.new(LAND + v(x, y, z))
		end
		B:block(fly, v(0.5, 0.44, 0.6), fp(0, 0, 0), "#1b1d24", { name = "FlyBody" })
		B:block(fly, v(0.42, 0.38, 0.45), fp(0, -0.02, 0.48), "#2c2f3a", { name = "FlyTail" })
		B:block(fly, v(0.4, 0.36, 0.32), fp(0, 0.04, -0.42), "#2b2f3a", { name = "FlyHead" })
		B:block(fly, v(0.17, 0.2, 0.1), fp(0.13, 0.08, -0.6), "#ff3838", { mat = "Neon", name = "FlyEyeR" })
		B:block(fly, v(0.17, 0.2, 0.1), fp(-0.13, 0.08, -0.6), "#ff3838", { mat = "Neon", name = "FlyEyeL" })
		local wr = B:bone("WingR", "Fly", LAND + v(0.18, 0.22, 0))
		B:block(wr, v(0.75, 0.05, 0.42), fp(0.52, 0.25, 0.08), "#e8f4ff", { tr = 0.35, name = "FlyWingR" })
		local wl = B:bone("WingL", "Fly", LAND + v(-0.18, 0.22, 0))
		B:block(wl, v(0.75, 0.05, 0.42), fp(-0.52, 0.25, 0.08), "#e8f4ff", { tr = 0.35, name = "FlyWingL" })
	end,
}
