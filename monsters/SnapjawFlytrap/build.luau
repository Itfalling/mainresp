--!nocheck
-- Snapjaw Flytrap: a giant walking venus flytrap that guards the greenhouse.
-- Its whole HEAD is the trap: a stepped green upper lobe (Head) and lower lobe
-- (Jaw), pink-red inside, rimmed with cream cilia "teeth" (that rim is its one
-- mouth). One pair of yellow neon eyes with heavy angry brows sits on top of
-- the upper lobe. A thick stepped stem neck (3 bones) rises out of a cracked
-- terracotta pot with gold trim and lumpy soil, a ring of collar leaves, two
-- big leaf arms with leafy fingers, and SIX chunky arched root legs (IK planted
-- by the motion). Lime neon drool, leaf/spore VFX and floating leaf cubes.
return {
	DisplayName = "Snapjaw Flytrap",
	Rarity = "Legendary",
	Element = "Nature",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local GREEN, GREEN_DK, GREEN_LT, GREEN_TOP = "#3caa3c", "#1f6e2a", "#a6e04c", "#58c447"
		local INSIDE, INSIDE_DK, RIM, TONGUE = "#e8455f", "#9c1f3a", "#c92a48", "#ff9bb8"
		local CREAM, BROW, PUPIL = "#fff4d2", "#123a18", "#0c160d"
		local EYE, LIME = "#ffee3a", "#86ff3c"
		local TERRA, TERRA_DK, TERRA_LT, GOLD, GOLD_DK = "#c9643a", "#8a3b20", "#e2895a", "#f2bd3c", "#c28a1e"
		local SOIL, SOIL_DK = "#4a2e1d", "#2c1a10"
		local ROOT, ROOT_DK, ROOT_TIP = "#8b5a31", "#5a361d", "#d9b07a"
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- POT (body): stepped cracked terracotta with gold trim + soil
		------------------------------------------------------------------
		local pot = B:bone("Pot", "Root", v(0, 2.6, 0))
		B:block(pot, v(4.4, 0.5, 4.4), cf(0, 1.15, 0), TERRA_DK) -- foot
		B:block(pot, v(5.2, 1.1, 5.2), cf(0, 1.95, 0), TERRA) -- lower body
		B:block(pot, v(5.6, 0.45, 5.6), cf(0, 2.72, 0), GOLD) -- gold trim band
		B:block(pot, v(6.0, 1.05, 6.0), cf(0, 3.47, 0), TERRA) -- upper body
		B:block(pot, v(7.0, 0.8, 7.0), cf(0, 4.4, 0), TERRA_LT) -- rim
		B:block(pot, v(7.1, 0.25, 7.1), cf(0, 4.12, 0), GOLD_DK) -- rim under-trim
		B:block(pot, v(6.3, 0.5, 6.3), cf(0, 4.75, 0), SOIL) -- soil
		-- gold zig-zag studs on the trim band (offset so the pot never shows a
		-- symmetric "face")
		for i = -2, 2 do
			local x = i * 1.05 + 0.3
			B:block(pot, v(0.5, 0.45, 0.25), cf(x, 2.72 + (i % 2 == 0 and 0.42 or -0.42), -2.65), GOLD)
			B:block(pot, v(0.5, 0.45, 0.25), cf(x - 0.6, 2.72 + (i % 2 == 0 and -0.42 or 0.42), 2.65), GOLD)
		end
		B:sym(function()
			for i = -1, 1 do
				B:block(pot, v(0.25, 0.45, 0.5), cf(2.65, 2.72 + (i % 2 == 0 and 0.42 or -0.42), i * 1.3), GOLD)
			end
			B:block(pot, v(0.3, 0.75, 4.0), cf(3.05, 3.47, 0), TERRA_DK) -- darker side panel
		end)
		-- cracks (asymmetric zig-zags)
		B:block(pot, v(0.25, 0.8, 0.2), cf(-1.5, 3.65, -3.05, 0, 0, 25), TERRA_DK)
		B:block(pot, v(0.25, 0.6, 0.2), cf(-1.2, 3.15, -3.05, 0, 0, -30), TERRA_DK)
		B:block(pot, v(0.25, 0.7, 0.2), cf(1.4, 1.9, -2.65, 0, 0, -20), TERRA_DK)
		B:block(pot, v(0.25, 0.5, 0.2), cf(1.7, 1.45, -2.65, 0, 0, 35), TERRA_DK)
		B:block(pot, v(0.2, 0.7, 0.25), cf(3.05, 3.55, 1.6, 25, 0, 0), SOIL_DK)
		B:block(pot, v(1.2, 0.4, 0.3), cf(2.6, 4.45, -3.55), TERRA_DK) -- chipped rim
		-- soil lumps + pebbles
		B:block(pot, v(1.4, 0.4, 1.1), cf(-2.0, 5.15, -1.8), SOIL_DK)
		B:block(pot, v(1.0, 0.35, 1.3), cf(2.1, 5.1, 1.6), SOIL_DK)
		B:block(pot, v(0.6, 0.3, 0.6), cf(1.9, 5.1, -2.2), "#8d8174")
		B:block(pot, v(0.5, 0.3, 0.5), cf(-2.4, 5.1, 2.2), "#a39787")
		local collarFX = B:block(pot, v(5, 0.6, 5), cf(0, 5.4, 0), SOIL, { tr = 1, name = "CollarFX" })
		B:emitter(collarFX, "leaf", { name = "LeafFall", color = { GREEN_LT, GREEN }, rate = 0.7, size = { 0.45, 0.45, 0.3 } })

		------------------------------------------------------------------
		-- Leaf collar: big pointed leaves on the soil (own bones -> flare)
		------------------------------------------------------------------
		local function leaf(bone, base, a, len, w, up, col)
			local f = CFrame.new(base) * CFrame.Angles(0, -rad(a), 0) * CFrame.Angles(rad(up), 0, 0)
			B:block(bone, v(w, 0.4, len * 0.55), f * CFrame.new(0, 0, -len * 0.27), col)
			B:block(bone, v(0.35, 0.5, len * 0.5), f * CFrame.new(0, 0.02, -len * 0.3), GREEN_LT)
			local f2 = f * CFrame.new(0, 0, -len * 0.5) * CFrame.Angles(rad(18), 0, 0)
			B:block(bone, v(w * 0.62, 0.4, len * 0.42), f2 * CFrame.new(0, 0, -len * 0.2), col)
			B:spike(bone, (f2 * CFrame.new(0, 0, -len * 0.38)).Position, (f2 * CFrame.new(0, 0.1, -len * 0.38 - 1.1)).Position, w * 0.45, 0.4, GREEN_LT)
		end
		local LEAVES = { { 35, 4.0, 2.0 }, { 95, 4.4, 2.2 }, { 150, 4.0, 2.0 } }
		B:sym(function(side)
			for i, L in LEAVES do
				local a = L[1]
				local base = v(1.3 * math.sin(rad(a)), 5.05, -1.3 * math.cos(rad(a)))
				local lb = B:bone("Leaf" .. i .. side, "Pot", base)
				leaf(lb, base, a, L[2], L[3], 14, i == 2 and GREEN or GREEN_DK)
			end
		end)
		local lbk = B:bone("LeafB", "Pot", v(0, 5.05, 1.3))
		leaf(lbk, v(0, 5.05, 1.3), 180, 4.2, 2.2, 18, GREEN)

		------------------------------------------------------------------
		-- ROOT LEGS: six arched chunky roots (upper Leg + lower Shin)
		------------------------------------------------------------------
		local LEGA = { 45, 95, 145 }
		B:sym(function(side)
			for k, a in LEGA do
				local d = v(math.sin(rad(a)), 0, -math.cos(rad(a)))
				local H = v(0, 1.5, 0) + d * 1.6
				local K = v(0, 2.8, 0) + d * 3.8
				local F = v(0, 0.45, 0) + d * 5.0
				local up = B:bone("Leg" .. k .. side, "Pot", H)
				B:beam(up, H - d * 0.4, K + d * 0.3, 1.4, 1.4, ROOT)
				B:beam(up, H + d * 0.8 + v(0, 0.75, 0), K + v(0, 0.75, 0) - d * 0.2, 0.5, 0.3, ROOT_DK) -- top bark ridge
				B:block(up, v(1.7, 1.7, 1.7), CFrame.new(K) * CFrame.Angles(0, -rad(a), 0), ROOT_DK) -- knee knot
				B:spike(up, K + v(0, 0.6, 0), K + v(0, 1.6, 0) + d * 0.5, 0.5, 0.5, ROOT_TIP) -- little root thorn
				local lo = B:bone("Shin" .. k .. side, "Leg" .. k .. side, K)
				B:beam(lo, K, F + v(0, 0.1, 0), 1.2, 1.2, ROOT)
				B:beam(lo, K + d * 0.2 + v(0, -0.6, 0), F + v(0, 0.6, 0) - d * 0.05, 1.3, 0.5, ROOT_DK) -- bark band
				-- splayed root toes on the ground
				B:block(lo, v(1.5, 0.6, 1.5), CFrame.new(F + v(0, -0.12, 0)) * CFrame.Angles(0, -rad(a), 0), ROOT_DK)
				B:spike(lo, F + v(0, -0.15, 0), F + d * 1.3 + v(0, -0.25, 0), 0.6, 0.4, ROOT_TIP)
				local sd = v(d.Z, 0, -d.X)
				B:spike(lo, F + v(0, -0.15, 0), F + d * 0.6 + sd * 0.9 + v(0, -0.25, 0), 0.45, 0.35, ROOT_TIP)
			end
		end)

		------------------------------------------------------------------
		-- STEM NECK: three thick stepped segments with node rings
		------------------------------------------------------------------
		local n1 = B:bone("Neck1", "Pot", v(0, 4.9, 0.4))
		B:block(n1, v(2.7, 1.8, 2.7), cf(0, 5.8, 0.4), GREEN_DK)
		B:block(n1, v(3.0, 0.4, 3.0), cf(0, 6.6, 0.4), GREEN_LT) -- node ring
		local n2 = B:bone("Neck2", "Neck1", v(0, 6.6, 0.3))
		B:block(n2, v(2.3, 1.5, 2.3), cf(0, 7.35, 0.3), GREEN)
		B:block(n2, v(2.6, 0.4, 2.6), cf(0, 8.05, 0.3), GREEN_DK)
		B:sym(function()
			B:block(n2, v(0.3, 0.9, 1.0), cf(1.2, 7.3, 0.3), GREEN_LT) -- side vein
		end)
		local n3 = B:bone("Neck3", "Neck2", v(0, 8.0, 0.3))
		B:block(n3, v(2.0, 1.3, 2.0), cf(0, 8.65, 0.35), GREEN)
		B:block(n3, v(2.2, 0.3, 2.2), cf(0, 9.25, 0.45), GREEN_LT)
		-- a little leaf sprouting off the back of the stem
		local sprout = B:bone("Sprout", "Neck2", v(0, 7.3, 1.4))
		leaf(sprout, v(0, 7.3, 1.4), 180, 2.6, 1.4, 40, GREEN_DK)

		------------------------------------------------------------------
		-- ARMS: winged petiole + big leaf hand with three leafy fingers
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Neck1", v(1.1, 6.0, 0.4))
			local S, E = v(1.0, 6.0, 0.4), v(3.6, 5.6, -0.4)
			B:beam(arm, S, E, 1.1, 1.1, GREEN_DK)
			B:beam(arm, S + v(0.6, 0.55, 0), E + v(-0.3, 0.55, 0), 0.4, 0.6, GREEN) -- petiole wing
			B:block(arm, v(1.4, 1.4, 1.4), cf(3.7, 5.6, -0.4), GREEN_DK) -- wrist knot
			local hand = B:bone("Hand" .. side, "Arm" .. side, E)
			-- the leaf blade lies in the local XY plane (faces forward) and runs out +X
			local f = CFrame.new(E) * CFrame.Angles(0, rad(28), 0) * CFrame.Angles(0, 0, rad(-20))
			local function at(x, y) return f * CFrame.new(x, y, 0) end
			B:block(hand, v(1.2, 1.6, 0.6), at(0.9, 0), GREEN)
			B:block(hand, v(1.3, 2.4, 0.6), at(2.1, 0.05), GREEN)
			B:block(hand, v(1.3, 2.8, 0.6), at(3.3, 0.1), GREEN)
			B:block(hand, v(1.1, 2.2, 0.6), at(4.4, 0.05), GREEN)
			B:block(hand, v(4.6, 0.35, 0.72), at(2.7, 0.05), GREEN_LT) -- midrib
			B:block(hand, v(0.3, 1.0, 0.7), at(2.4, 0.7), GREEN_LT)
			B:block(hand, v(0.3, 1.0, 0.7), at(3.6, -0.6), GREEN_LT)
			B:block(hand, v(2.4, 0.3, 0.7), at(2.8, 1.3), GREEN_DK) -- serrated edges
			B:block(hand, v(2.2, 0.3, 0.7), at(3.0, -1.2), GREEN_DK)
			-- three leafy fingers
			B:spike(hand, at(4.6, 0.8).Position, at(5.9, 1.7).Position, 0.8, 0.5, GREEN_LT)
			B:spike(hand, at(4.8, 0.05).Position, at(6.4, 0.05).Position, 0.9, 0.5, GREEN_LT)
			B:spike(hand, at(4.6, -0.7).Position, at(5.8, -1.5).Position, 0.8, 0.5, GREEN_LT)
			B:trail(hand, at(6.2, 0.05).Position, at(5.4, 0.05).Position, { name = "HandTrail" .. side, color = { LIME, GREEN_LT }, life = 0.18, trans = { 0.5, 1 } })
		end)

		------------------------------------------------------------------
		-- HEAD = upper trap lobe (+ eyes on top). Mouth line at y = 9.9.
		-- Lobes have a stepped oval outline (narrow ends, wide middle).
		------------------------------------------------------------------
		local head = B:bone("Head", "Neck3", v(0, 9.0, 0.2))
		B:block(head, v(3.6, 2.2, 1.8), cf(0, 10.0, 0.9), GREEN_DK) -- hinge / midrib
		B:block(head, v(5.6, 1.3, 0.3), cf(0, 10.0, -0.05), INSIDE_DK) -- deep red back of the trap
		B:block(head, v(6.4, 0.9, 5.8), cf(0, 10.75, -2.4), GREEN) -- U1
		B:block(head, v(7.2, 0.8, 3.4), cf(0, 10.75, -2.4), GREEN) -- U1 middle bulge
		B:block(head, v(6.6, 0.3, 6.0), cf(0, 10.36, -2.4), RIM) -- red lip rim
		B:block(head, v(7.4, 0.3, 3.6), cf(0, 10.36, -2.4), RIM)
		B:block(head, v(6.2, 0.2, 5.3), cf(0, 10.2, -2.5), INSIDE) -- pink inside
		B:block(head, v(2.2, 0.15, 4.4), cf(0, 10.08, -2.6), INSIDE_DK) -- inner centre
		B:block(head, v(5.4, 0.6, 4.6), cf(0, 11.48, -1.9), GREEN_TOP) -- U2 dome
		B:block(head, v(3.0, 0.35, 2.6), cf(0, 11.9, -1.2), GREEN) -- U3
		B:block(head, v(1.4, 0.25, 1.4), cf(0, 12.15, -0.9), GREEN_DK) -- crown
		B:block(head, v(5.0, 0.7, 0.6), cf(0, 10.7, -5.55), GREEN) -- front lip step
		B:block(head, v(5.2, 0.3, 0.8), cf(0, 10.36, -5.55), RIM)
		B:sym(function()
			B:block(head, v(0.3, 0.5, 3.0), cf(3.65, 10.85, -2.4), GREEN_DK) -- side panel
			B:block(head, v(0.2, 0.45, 0.2), cf(1.2, 9.95, -2.0), INSIDE_DK) -- trigger hair
			B:block(head, v(0.6, 0.2, 0.6), cf(1.4, 11.85, -0.4), GREEN_DK) -- speckles
			B:block(head, v(0.25, 0.4, 0.5), cf(2.75, 11.5, -0.2), GREEN_DK)
		end)
		B:block(head, v(0.2, 0.45, 0.2), cf(0, 9.95, -3.6), INSIDE_DK)
		-- upper cilia teeth: front row + side rows, pointing down/out
		for i = 0, 5 do
			local x = -2.9 + i * 1.16
			B:spike(head, v(x, 10.45, -5.75), v(x * 1.08, 9.15, -6.25), 0.55, 0.5, CREAM)
		end
		B:sym(function()
			B:spike(head, v(3.15, 10.45, -4.7), v(3.8, 9.2, -5.1), 0.55, 0.5, CREAM)
			for _, z in { -3.6, -2.4, -1.2 } do
				B:spike(head, v(3.65, 10.45, z), v(4.3, 9.25, z - 0.15), 0.55, 0.5, CREAM)
			end
		end)

		-- eyes: raised bumps on the front of the top lobe, glowing slit eyes with
		-- a pupil on the FRONT face only, heavy angry brows on own bones
		B:sym(function(side)
			B:block(head, v(2.2, 1.2, 1.6), cf(1.7, 11.75, -3.35), GREEN) -- eye bump
			B:block(head, v(1.9, 1.0, 0.2), cf(1.7, 11.75, -4.18), PUPIL) -- dark socket frame
			B:block(head, v(1.6, 0.8, 0.2), cf(1.7, 11.75, -4.24), EYE, { mat = "Neon", name = "Eye" .. side })
			B:block(head, v(0.45, 0.7, 0.12), cf(1.4, 11.72, -4.37), PUPIL)
			B:block(head, v(0.3, 0.25, 0.06), cf(1.98, 11.98, -4.36), "#ffffff") -- glint
			local brow = B:bone("Brow" .. side, "Head", v(1.7, 12.5, -4.0))
			B:block(brow, v(2.7, 0.6, 1.3), cf(1.75, 12.55, -3.95, 0, 0, 17), BROW)
			-- eyelid (hidden; slides down over the eye for blinks / squints)
			local lid = B:bone("Lid" .. side, "Head", v(1.7, 11.75, -4.3))
			B:block(lid, v(1.95, 1.05, 0.3), cf(1.7, 11.75, -4.4), GREEN_DK, { tr = 1, name = "Eyelid" .. side })
		end)

		-- expression props (shown only by the states that use them)
		local AM = v(2.7, 12.3, -1.2)
		B:block(head, v(0.25, 1.1, 0.25), CFrame.new(AM + v(-0.25, 0, 0)) * P.ang(0, 0, 20), "#ff2b2b", { tr = 1, name = "AngryMark1" })
		B:block(head, v(0.25, 1.1, 0.25), CFrame.new(AM + v(0.25, 0, 0)) * P.ang(0, 0, -20), "#ff2b2b", { tr = 1, name = "AngryMark2" })
		B:block(head, v(1.1, 0.25, 0.25), CFrame.new(AM + v(0, 0.25, 0)) * P.ang(0, 0, 10), "#ff2b2b", { tr = 1, name = "AngryMark3" })
		B:block(head, v(1.1, 0.25, 0.25), CFrame.new(AM + v(0, -0.25, 0)) * P.ang(0, 0, -10), "#ff2b2b", { tr = 1, name = "AngryMark4" })
		local sweat = B:bone("Sweat", "Head", v(-3.3, 11.9, -2.8))
		B:block(sweat, v(0.55, 0.8, 0.55), cf(-3.3, 11.8, -2.8), "#8fdcff", { tr = 1, name = "SweatDrop1" })
		B:block(sweat, v(0.35, 0.4, 0.35), cf(-3.3, 12.35, -2.8), "#c9f0ff", { tr = 1, name = "SweatDrop2" })

		-- mouth VFX
		local mouthFX = B:block(head, v(4, 0.6, 1), cf(0, 9.9, -5.9), GREEN, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFX, "burst", { name = "ChompBurst", color = { "#ffffff", LIME }, size = { 0.9, 0.6, 0 }, speed = { 7, 13 } })
		B:emitter(mouthFX, "leaf", { name = "LeafBurst", rate = 0, color = { GREEN_LT, GREEN, "#e8f58a" }, speed = { 5, 11 }, size = { 0.6, 0.55, 0.3 }, life = { 1.0, 1.8 }, spread = 55, accel = { 0, -6, 0 }, drag = 2, dir = "Front" })
		B:light(mouthFX, { name = "MouthLight", color = LIME, brightness = 0, range = 10 })
		local aura = B:block(head, v(7, 3, 6), cf(0, 11, -2.4), GREEN, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "SporeSparkle", color = { "#ffffff", LIME }, rate = 2.5 })

		------------------------------------------------------------------
		-- JAW = lower trap lobe (+ tongue, drool)
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", v(0, 9.8, 0.4))
		B:block(jaw, v(6.2, 0.2, 5.3), cf(0, 9.55, -2.5), INSIDE) -- pink inside
		B:block(jaw, v(6.6, 0.3, 6.0), cf(0, 9.42, -2.4), RIM)
		B:block(jaw, v(7.4, 0.3, 3.6), cf(0, 9.42, -2.4), RIM)
		B:block(jaw, v(6.4, 0.8, 5.8), cf(0, 8.95, -2.4), GREEN) -- D1
		B:block(jaw, v(7.2, 0.7, 3.4), cf(0, 8.95, -2.4), GREEN) -- D1 bulge
		B:block(jaw, v(5.4, 0.6, 4.6), cf(0, 8.3, -2.3), GREEN) -- D2
		B:block(jaw, v(5.0, 0.7, 0.6), cf(0, 9.05, -5.55), GREEN) -- front lip step
		B:block(jaw, v(5.2, 0.3, 0.8), cf(0, 9.42, -5.55), RIM)
		B:block(jaw, v(3.4, 1.0, 0.3), cf(0, 9.45, -0.05), INSIDE_DK) -- back wall
		B:sym(function()
			B:block(jaw, v(0.3, 0.45, 3.0), cf(3.65, 8.95, -2.4), GREEN_DK)
			B:block(jaw, v(0.2, 0.45, 0.2), cf(1.4, 9.82, -3.0), INSIDE_DK) -- trigger hair
			B:block(jaw, v(0.25, 0.35, 2.2), cf(2.75, 8.3, -2.4), GREEN_LT) -- vein
			B:spike(jaw, v(3.15, 9.35, -4.7), v(3.8, 10.6, -5.1), 0.55, 0.5, CREAM)
			for _, z in { -3.0, -1.8 } do
				B:spike(jaw, v(3.65, 9.35, z), v(4.3, 10.55, z - 0.15), 0.55, 0.5, CREAM)
			end
		end)
		for i = 0, 4 do
			local x = -2.32 + i * 1.16
			B:spike(jaw, v(x, 9.35, -5.75), v(x * 1.08, 10.65, -6.25), 0.55, 0.5, CREAM)
		end
		B:sym(function(side)
			B:trail(jaw, v(3.4, 9.3, -5.6), v(3.4, 8.3, -5.6), { name = "SnapTrail" .. side, color = { "#ffffff", LIME }, life = 0.15, trans = { 0.5, 1 } })
		end)
		-- tongue (2 bones) resting on the lower lobe
		local tg = B:bone("Tongue", "Jaw", v(0, 9.75, -0.6))
		B:block(tg, v(2.4, 0.3, 2.6), cf(0, 9.78, -1.9), TONGUE)
		B:block(tg, v(0.4, 0.1, 2.0), cf(0, 9.95, -1.9), "#e0607f") -- groove
		local tt = B:bone("TongueTip", "Tongue", v(0, 9.78, -3.1))
		B:block(tt, v(2.0, 0.3, 1.6), cf(0, 9.78, -3.8), TONGUE)
		B:block(tt, v(1.2, 0.3, 0.6), cf(0, 9.78, -4.8), TONGUE)
		-- drool strand + drop hanging off the lower lip
		local dr = B:bone("Drool", "Jaw", v(1.9, 8.75, -5.65))
		B:block(dr, v(0.3, 1.0, 0.3), cf(1.9, 8.3, -5.7), LIME, NEON)
		local dd = B:bone("DroolDrop", "Drool", v(1.9, 7.85, -5.7))
		local drop = B:block(dd, v(0.55, 0.6, 0.55), cf(1.9, 7.55, -5.7), LIME, NEON)
		B:emitter(drop, "drip", { name = "DroolDrip", color = LIME, rate = 1.2, size = { 0.35, 0.3, 0.15 } })
		local lip = B:block(jaw, v(5, 0.5, 0.8), cf(0, 9.6, -5.9), GREEN, { tr = 1, name = "LipFX" })
		B:emitter(lip, "burst", { name = "DroolBurst", color = { LIME, "#d6ff9a" }, speed = { 4, 9 }, size = { 0.5, 0.4, 0.1 }, accel = { 0, -30, 0 }, life = { 0.5, 1.0 }, spread = 60, dir = "Front" })

		------------------------------------------------------------------
		-- the imaginary fly (prop) the trap snaps at during Idle
		------------------------------------------------------------------
		local fly = B:bone("Fly", "Root", v(0, 11.5, -9))
		B:block(fly, v(0.5, 0.45, 0.7), cf(0, 11.5, -9), "#1b1b22", { tr = 1, name = "FlyBody" })
		B:sym(function(side)
			B:block(fly, v(0.6, 0.1, 0.45), cf(0.5, 11.8, -8.95, 0, 0, 25), "#e8f6ff", { tr = 1, name = "FlyWing" .. side })
		end)

		------------------------------------------------------------------
		-- ground FX + floating leaf cubes
		------------------------------------------------------------------
		local dust = B:block("Root", v(9, 0.2, 9), cf(0, 0.1, 0), SOIL, { tr = 1, name = "DustFX" })
		B:emitter(dust, "dust", { name = "StepDust", color = { "#d9c7a6", "#b59a74" }, size = { 1.6, 3.0, 3.8 } })

		local orbit = B:bone("Orbit", "Root", v(0, 8, 0))
		local spots = { { 9.5, 9.5, 2.0 }, { -9.8, 7.0, 2.5 }, { 7.0, 3.5, 6.5 }, { -6.0, 11.0, 6.0 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = i > 2 and 1.0 or 1.3
			local green = i % 2 == 1
			B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), green and GREEN or TERRA)
			B:block(ob, v(s + 0.1, s * 0.25, s + 0.1), cf(p[1], p[2], p[3]), green and LIME or GOLD, green and NEON or nil)
		end
	end,
}
