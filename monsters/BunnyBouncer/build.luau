--!nocheck
-- Bunny Bouncer (Guardian #2): a buff upright stud-built rabbit nightclub
-- bouncer guarding his carrot patch. Grey/white voxel fur, HUGE chunky arms
-- with white block fists, big rabbit feet, tall bone-chained ears, a black
-- "SECURITY" tank top, a gold chain with a carrot pendant, an earpiece and
-- black shades. The shades are on their own bone: they cover the eyes at rest
-- and flip UP onto the forehead when he gets angry, revealing ONE pair of
-- angry eyes (the eye parts are props, hidden while the shades are down).
-- Detail comes from colour blocking; neon is only the angry pupils, the
-- earpiece LED, the anger mark and a few tiny garden tips.
return {
	DisplayName = "Bunny Bouncer",
	Rarity = "Uncommon",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		-- palette
		local FUR, FURD, FURL = "#b4b8c6", "#7f8496", "#d2d5df" -- grey fur, shade, highlight
		local WHITE, WHITE2 = "#f6f6fa", "#dcdce6" -- belly / muzzle / fists, shade
		local PINK, PINKD = "#ff9cbc", "#e0688e"
		local TANK, TANK2 = "#1c1c24", "#34343f" -- black tank top + trim
		local GOLD, GOLDD = "#f6bd34", "#c4841a"
		local CARROT, CARROTD = "#ff8a1c", "#d6600c"
		local LEAF, LEAFD = "#4cc23a", "#2f8a2a"
		local SHADE, GLINT = "#0b0b10", "#6f80b8"
		local MOUTH, TONGUE, BROW = "#15121f", "#d8487a", "#4e5264"
		local DIRT, DIRTD = "#7a5636", "#5a3e26"
		local RED, MINT = "#ff2a3a", "#5dff8a" -- the two neon accents
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- Hips (fur shorts + belt) and cotton tail
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 2.3, 0.15))
		B:block(hips, v(2.3, 0.9, 1.8), cf(0, 2.3, 0.2), FUR)
		B:block(hips, v(1.6, 0.5, 0.2), cf(0, 2.15, -0.75), WHITE2) -- belly fur peeking under the tank
		B:block(hips, v(2.5, 0.32, 2.0), cf(0, 2.78, 0.2), TANK2) -- belt
		B:block(hips, v(0.55, 0.42, 0.12), cf(0, 2.78, -0.83), GOLD) -- buckle
		B:block(hips, v(0.25, 0.2, 0.06), cf(0, 2.78, -0.9), GOLDD)
		-- walkie-talkie clipped to the belt
		B:block(hips, v(0.4, 0.6, 0.3), cf(-1.15, 2.55, 0.65), TANK)
		B:block(hips, v(0.08, 0.35, 0.08), cf(-1.05, 3.0, 0.75), TANK2)
		B:block(hips, v(0.12, 0.12, 0.06), cf(-1.15, 2.7, 0.49), MINT, NEON)

		local tail = B:bone("Tail", "Hips", v(0, 2.35, 1.05))
		B:block(tail, v(0.9, 0.85, 0.6), cf(0, 2.4, 1.3), WHITE)
		B:block(tail, v(0.6, 0.6, 0.45), cf(0, 2.45, 1.7), WHITE)
		B:block(tail, v(0.45, 0.35, 0.35), cf(0, 2.85, 1.45), WHITE2)

		------------------------------------------------------------------
		-- Legs: chunky thighs, short shins, BIG rabbit feet
		------------------------------------------------------------------
		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Hips", v(0.95, 2.2, 0.15))
			B:block(thigh, v(1.35, 1.3, 1.55), cf(1.0, 1.85, 0.05), FUR)
			B:block(thigh, v(0.12, 0.9, 1.0), cf(1.72, 1.85, 0.05), FURD)
			B:block(thigh, v(1.0, 0.5, 0.15), cf(1.0, 1.55, -0.75), FURL) -- knee highlight
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(1.0, 1.25, -0.25))
			B:block(shin, v(1.05, 1.05, 1.1), cf(1.0, 0.95, 0.05), FUR)
			B:block(shin, v(0.12, 0.6, 0.7), cf(1.57, 0.95, 0.1), FURD)
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(1.0, 0.6, 0.3))
			B:block(foot, v(1.25, 0.5, 2.6), cf(1.0, 0.4, -0.4), FUR)
			B:block(foot, v(1.3, 0.16, 2.7), cf(1.0, 0.08, -0.4), WHITE) -- white sole rim
			B:block(foot, v(0.9, 0.3, 1.2), cf(1.0, 0.75, 0.2), FUR) -- ankle hump
			for k = -1, 1 do
				B:block(foot, v(0.36, 0.36, 0.32), cf(1.0 + k * 0.42, 0.26, -1.82), WHITE) -- toes
			end
			B:block(foot, v(0.9, 0.12, 0.08), cf(1.0, 0.5, -1.72), FURD)
			B:block(foot, v(0.7, 0.35, 0.3), cf(1.0, 0.3, 0.98), WHITE2) -- heel
		end)

		------------------------------------------------------------------
		-- Chest: V-shaped torso in a black SECURITY tank top
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Hips", v(0, 2.8, 0.2))
		B:block(chest, v(2.3, 0.8, 1.75), cf(0, 3.15, 0.2), TANK) -- waist
		B:block(chest, v(3.1, 1.35, 2.0), cf(0, 4.05, 0.15), TANK) -- chest
		B:block(chest, v(3.3, 0.5, 1.75), cf(0, 4.95, 0.25), FUR) -- traps / no-neck
		B:block(chest, v(2.4, 0.3, 1.4), cf(0, 5.3, 0.35), FURD)
		B:block(chest, v(1.0, 0.45, 0.12), cf(0, 4.55, -0.87), WHITE) -- V-neck chest fluff
		B:block(chest, v(0.6, 0.3, 0.1), cf(0, 4.3, -0.87), WHITE2)
		B:sym(function()
			B:block(chest, v(0.55, 0.58, 1.85), cf(0.95, 4.96, 0.25), TANK) -- straps
			B:block(chest, v(0.12, 1.0, 1.4), cf(1.56, 4.0, 0.15), TANK2) -- side seam
		end)
		B:block(chest, v(0.08, 0.8, 0.08), cf(0, 3.95, -0.88), TANK2) -- pec seam
		B:block(chest, v(2.2, 0.08, 0.08), cf(0, 3.48, -0.88), TANK2)
		-- small SECURITY badge on the chest
		B:block(chest, v(0.6, 0.3, 0.08), cf(-0.9, 4.3, -0.88), WHITE)
		B:block(chest, v(0.4, 0.08, 0.04), cf(-0.9, 4.3, -0.93), TANK)
		-- big SECURITY band across the back (blocky "lettering")
		B:block(chest, v(2.6, 0.55, 0.1), cf(0, 4.2, 1.18), WHITE)
		for k = 0, 7 do
			local h = k % 3 == 1 and 0.3 or 0.36
			B:block(chest, v(0.2, h, 0.06), cf(-1.05 + k * 0.3, 4.2, 1.24), TANK)
		end

		-- gold chain + carrot pendant
		B:sym(function()
			B:beam(chest, v(0.8, 4.78, -0.8), v(0.02, 4.38, -0.98), 0.14, 0.14, GOLD)
		end)
		local pend = B:bone("Pendant", "Chest", v(0, 4.4, -1.0))
		B:block(pend, v(0.26, 0.16, 0.16), cf(0, 4.36, -1.02), GOLDD)
		B:block(pend, v(0.44, 0.32, 0.22), cf(0, 4.16, -1.03), CARROT)
		B:block(pend, v(0.3, 0.3, 0.2), cf(0, 3.88, -1.03), CARROT)
		B:block(pend, v(0.16, 0.26, 0.18), cf(0, 3.62, -1.03), CARROTD)
		B:block(pend, v(0.3, 0.05, 0.04), cf(0, 4.04, -1.15), CARROTD)
		B:block(pend, v(0.12, 0.28, 0.1), cf(0.1, 4.48, -1.05), LEAF)
		B:block(pend, v(0.1, 0.22, 0.1), cf(-0.1, 4.46, -1.06), LEAFD)

		-- FX volumes on the chest: flex sparkles + fist clash sparks
		local flexAt = B:block(chest, v(4.5, 2.5, 1.5), cf(0, 4.4, 0.0), TANK, { tr = 1, name = "FlexFX" })
		B:emitter(flexAt, "burst", { name = "FlexSparkle", color = { "#ffffff", "#ffe27a" }, speed = { 3, 7 }, size = { 0.5, 0.35, 0 }, life = { 0.4, 0.8 } })
		local clashAt = B:block(chest, v(0.6, 0.6, 0.6), cf(0, 3.9, -2.3), TANK, { tr = 1, name = "ClashFX" })
		B:emitter(clashAt, "burst", { name = "FistClash", color = { "#fff6b0", "#ff9a2a" }, speed = { 6, 12 }, size = { 0.45, 0.25, 0 }, life = { 0.15, 0.35 } })

		------------------------------------------------------------------
		-- Head: big wide rabbit head sitting low between the traps
		------------------------------------------------------------------
		local head = B:bone("Head", "Chest", v(0, 4.85, -0.05))
		B:block(head, v(2.5, 1.6, 2.1), cf(0, 5.45, -0.35), FUR) -- cranium
		B:block(head, v(2.1, 0.25, 1.7), cf(0, 6.3, -0.3), FURD) -- flat top step
		B:block(head, v(2.6, 1.1, 1.6), cf(0, 5.2, -0.15), FUR) -- cheeks / jowls
		B:block(head, v(1.9, 0.6, 0.3), cf(0, 6.0, 0.8), FURD) -- back of head
		-- muzzle: white cheeks + snout, pink nose, buck teeth
		B:block(head, v(1.0, 0.6, 0.45), cf(0, 4.98, -1.6), WHITE)
		B:sym(function()
			B:block(head, v(0.8, 0.55, 0.4), cf(0.6, 4.9, -1.55), WHITE)
			B:block(head, v(0.4, 0.05, 0.05), cf(0.85, 5.0, -1.78), FURD) -- whisker dot rows
			B:block(head, v(0.4, 0.05, 0.05), cf(0.85, 4.85, -1.78), FURD)
			B:block(head, v(0.45, 0.4, 0.3), cf(1.2, 5.0, -1.25), WHITE2) -- cheek fluff
		end)
		B:block(head, v(0.44, 0.26, 0.18), cf(0, 5.22, -1.86), PINK)
		B:block(head, v(0.2, 0.08, 0.06), cf(0, 5.12, -1.93), PINKD)
		B:block(head, v(0.06, 0.2, 0.05), cf(0, 4.9, -1.83), FURD) -- philtrum
		B:sym(function()
			B:block(head, v(0.24, 0.36, 0.1), cf(0.13, 4.56, -1.78), WHITE) -- buck tooth
		end)
		B:block(head, v(0.9, 0.12, 0.55), cf(0, 4.64, -1.5), MOUTH) -- mouth roof

		-- EYES (props): hidden while the shades cover them, shown when angry.
		-- One pair, front face only.
		B:sym(function(side)
			B:block(head, v(0.66, 0.48, 0.08), cf(0.58, 5.68, -1.43), WHITE, { tr = 1, name = "EyeWhite" .. side })
			B:block(head, v(0.26, 0.3, 0.06), cf(0.47, 5.64, -1.48), RED, { mat = "Neon", tr = 1, name = "Pupil" .. side })
		end)
		-- heavy brows (sit just above the shades; tilt down when angry)
		B:sym(function(side)
			local brow = B:bone("Brow" .. side, "Head", v(0.58, 6.1, -1.5))
			B:block(brow, v(0.9, 0.24, 0.32), cf(0.58, 6.12, -1.52), BROW)
		end)
		-- anger vein mark (props) floating at the top-right of the head
		local vein = B:bone("Vein", "Head", v(1.2, 6.45, -1.2))
		local vb = { { 1.08, 6.45, 0.08, 0.36 }, { 1.32, 6.45, 0.08, 0.36 }, { 1.2, 6.57, 0.36, 0.08 }, { 1.2, 6.33, 0.36, 0.08 } }
		for i, b in vb do
			B:block(vein, v(b[3], b[4], 0.08), cf(b[1], b[2], -1.25, 0, 0, 45), RED, { mat = "Neon", tr = 1, name = "AngryMark" .. i })
		end

		-- SHADES on their own bone (flip up onto the forehead)
		local shades = B:bone("Shades", "Head", v(0, 5.7, -1.62))
		B:block(shades, v(2.62, 0.6, 0.22), cf(0, 5.72, -1.62), SHADE)
		B:sym(function()
			B:block(shades, v(0.95, 0.24, 0.2), cf(0.62, 5.33, -1.6), SHADE) -- lens bottoms
			B:block(shades, v(0.32, 0.09, 0.04), cf(0.88, 5.88, -1.75), GLINT)
			B:block(shades, v(0.1, 0.09, 0.04), cf(0.6, 5.88, -1.75), GLINT)
			B:block(shades, v(0.1, 0.12, 1.45), cf(1.3, 5.86, -0.9), SHADE) -- temple arm
		end)
		B:block(shades, v(0.26, 0.2, 0.06), cf(0, 5.42, -1.69), "#20202a") -- nose bridge

		-- earpiece + curly cord on the right side (tucked back, no glow so it
		-- never reads as an eye)
		B:block(head, v(0.2, 0.36, 0.32), cf(1.32, 5.0, 0.25), TANK)
		B:block(head, v(0.06, 0.1, 0.1), cf(1.43, 5.1, 0.25), TANK2)
		for i, p in { { 1.3, 4.74, 0.38 }, { 1.24, 4.56, 0.48 }, { 1.3, 4.4, 0.56 } } do
			B:block(head, v(0.1, 0.16, 0.1), cf(p[1], p[2], p[3]), i == 2 and TANK2 or TANK)
		end
		local headFx = B:block(head, v(2.5, 1.5, 1.0), cf(0, 5.5, -1.4), FUR, { tr = 1, name = "HeadFX" })
		B:emitter(headFx, "burst", { name = "RageBurst", color = { "#ffffff", RED }, speed = { 7, 13 }, size = { 0.7, 0.45, 0 } })

		-- lower jaw
		local jaw = B:bone("Jaw", "Head", v(0, 4.72, -1.05))
		B:block(jaw, v(1.1, 0.36, 0.7), cf(0, 4.46, -1.45), WHITE)
		B:block(jaw, v(0.8, 0.2, 0.5), cf(0, 4.24, -1.35), WHITE2)
		B:block(jaw, v(0.9, 0.08, 0.55), cf(0, 4.66, -1.45), MOUTH)
		B:block(jaw, v(0.5, 0.06, 0.35), cf(0, 4.71, -1.42), TONGUE)

		-- tall ears: two-bone chains (floppy follow-through)
		B:sym(function(side)
			local e1 = B:bone("Ear" .. side .. "1", "Head", v(0.62, 6.2, 0.0))
			B:block(e1, v(0.85, 0.24, 0.6), cf(0.62, 6.3, 0.0), FURD) -- ear root
			B:block(e1, v(0.7, 0.95, 0.45), cf(0.64, 6.75, 0.0), FUR)
			B:block(e1, v(0.38, 0.75, 0.08), cf(0.64, 6.75, -0.24), PINK)
			local e2 = B:bone("Ear" .. side .. "2", "Ear" .. side .. "1", v(0.66, 7.15, 0.0))
			B:block(e2, v(0.64, 0.75, 0.42), cf(0.66, 7.48, 0.0), FUR)
			B:block(e2, v(0.32, 0.55, 0.08), cf(0.66, 7.45, -0.22), PINK)
			B:block(e2, v(0.44, 0.14, 0.32), cf(0.66, 7.9, 0.0), FURL) -- ear tip
			B:trail(e2, v(0.66, 7.85, 0.15), v(0.66, 7.3, 0.15), { name = "EarTrail" .. side, color = { "#ffffff", PINK }, life = 0.14, trans = { 0.6, 1 } })
		end)

		------------------------------------------------------------------
		-- HUGE arms: fat deltoids, Popeye forearms, white block fists
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Chest", v(1.65, 4.55, 0.2))
			B:block(arm, v(1.45, 0.85, 1.55), cf(1.95, 4.68, 0.2), FUR) -- deltoid
			B:block(arm, v(1.1, 0.2, 1.2), cf(1.95, 5.15, 0.2), FURL)
			B:block(arm, v(1.25, 1.3, 1.3), cf(2.05, 3.85, 0.2), FUR) -- upper arm
			B:block(arm, v(0.12, 0.9, 0.9), cf(2.72, 3.9, 0.2), FURD)
			B:block(arm, v(0.9, 0.7, 0.12), cf(2.05, 3.95, -0.5), FURL) -- bicep highlight

			local fore = B:bone("Forearm" .. side, "Arm" .. side, v(2.1, 3.25, 0.2))
			B:block(fore, v(1.5, 1.25, 1.5), cf(2.15, 2.65, 0.15), FUR)
			B:block(fore, v(0.12, 0.85, 1.0), cf(2.94, 2.7, 0.15), FURD)
			B:block(fore, v(1.1, 0.2, 1.1), cf(2.15, 3.35, 0.15), FURD) -- elbow
			B:block(fore, v(1.6, 0.32, 1.6), cf(2.15, 2.05, 0.15), TANK) -- wrist band
			-- tiny carrot tattoo on the outer forearm
			B:block(fore, v(0.06, 0.4, 0.16), cf(2.92, 2.62, -0.1), CARROT)
			B:block(fore, v(0.06, 0.14, 0.1), cf(2.92, 2.9, -0.1), LEAF)

			local fist = B:bone("Fist" .. side, "Forearm" .. side, v(2.15, 1.95, 0.15))
			B:block(fist, v(1.45, 1.15, 1.45), cf(2.15, 1.36, 0.1), WHITE)
			for k = 0, 3 do
				B:block(fist, v(0.3, 0.34, 0.12), cf(1.7 + k * 0.3, 1.55, -0.66), k % 2 == 0 and WHITE2 or WHITE)
			end
			B:block(fist, v(1.2, 0.06, 0.06), cf(2.15, 1.3, -0.65), FURD) -- finger line
			B:block(fist, v(0.3, 0.45, 0.6), cf(1.4, 1.4, -0.3), WHITE2) -- thumb
			B:trail(fist, v(2.15, 1.7, -0.7), v(2.15, 0.9, -0.7), { name = "FistTrail" .. side, color = { "#ffffff", CARROT }, life = 0.2, trans = { 0.45, 1 } })
		end)

		------------------------------------------------------------------
		-- Ground FX (fixed to Root): slam in front + footstep dust
		------------------------------------------------------------------
		local slamAt = B:block("Root", v(3, 0.3, 2), cf(0, 0.2, -2.6), TANK, { tr = 1, name = "SlamFX" })
		B:emitter(slamAt, "burst", { name = "SlamBurst", color = { "#ffffff", CARROT, LEAF }, speed = { 9, 16 }, size = { 0.8, 0.5, 0 } })
		B:emitter(slamAt, "dust", { name = "SlamDust", color = { "#e8dcc4", "#c9b896" }, size = { 1.6, 3, 3.6 } })
		B:light(slamAt, { name = "SlamLight", color = "#ffb24a", brightness = 0.01, range = 10 })
		local stepAt = B:block("Root", v(2.6, 0.2, 2.6), cf(0, 0.1, 0.0), TANK, { tr = 1, name = "StepFX" })
		B:emitter(stepAt, "dust", { name = "StepDust", color = { "#efe6d2", "#cfc3a8" }, size = { 0.9, 1.8, 2.4 }, speed = { 4, 8 } })
		-- dirt / carrot chunks blasted out by the slam (props, hidden)
		local rocks = { { 1.4, 0.4, -3.2, 0.6, DIRT }, { -1.3, 0.4, -3.0, 0.5, CARROT }, { 0.5, 0.4, -3.8, 0.45, LEAF }, { -0.6, 0.4, -2.2, 0.55, DIRTD } }
		for i, r in rocks do
			local rb = B:bone("Rock" .. i, "Root", v(r[1], r[2], r[3]))
			B:block(rb, v(r[4], r[4], r[4]), cf(r[1], r[2], r[3]), r[5], { tr = 1, name = "Rock" .. i })
		end

		------------------------------------------------------------------
		-- Floating garden voxel cubes (carrot, leaf, soil) + falling leaves
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 4, 0.3))
		local spots = { { 4.8, 5.6, -1.6 }, { -4.7, 3.8, 1.4 }, { 2.0, 7.0, 4.3 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			if i == 1 then
				B:block(ob, v(0.6, 0.7, 0.6), cf(p[1], p[2], p[3]), CARROT)
				B:block(ob, v(0.4, 0.4, 0.4), cf(p[1], p[2] - 0.5, p[3]), CARROTD)
				B:block(ob, v(0.16, 0.4, 0.16), cf(p[1], p[2] + 0.5, p[3]), LEAF)
				B:block(ob, v(0.12, 0.12, 0.12), cf(p[1], p[2] + 0.74, p[3]), MINT, NEON)
			elseif i == 2 then
				B:block(ob, v(0.75, 0.75, 0.75), cf(p[1], p[2], p[3]), LEAF)
				B:block(ob, v(0.8, 0.14, 0.8), cf(p[1], p[2], p[3]), MINT, NEON)
			else
				B:block(ob, v(0.7, 0.55, 0.7), cf(p[1], p[2], p[3]), DIRT)
				B:block(ob, v(0.75, 0.2, 0.75), cf(p[1], p[2] + 0.36, p[3]), LEAF)
			end
		end
		local leafAt = B:block("Orbit", v(6, 1, 5), cf(0, 7.5, 0.3), TANK, { tr = 1, name = "LeafFX" })
		B:emitter(leafAt, "leaf", { name = "Leaves", color = { LEAF, "#8be06a" }, rate = 1.2 })
	end,
}
