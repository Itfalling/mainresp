--!nocheck
-- Scarecrow Sentry (Guardian #3): a lanky living scarecrow that guards its
-- cornfield plant and PRETENDS to be an ordinary scarecrow. Stud-built:
-- a big burlap-sack head (tan blocks, dark stitch seams) cinched with rope,
-- ONE pair of glowing orange cut-out eyes under heavy stitched brows, ONE
-- jagged stitched grin on a jaw that drops open, a floppy wide straw hat with
-- a blue patch and a sunflower in the band, a red plaid shirt (colour-blocked
-- squares + cream lines), patched denim overalls, rope belt, straw tufts
-- poking out at the neck / wrists / ankles / waist / under the hat, wooden
-- pole wrists, twig fingers and stake feet, and a pitchfork in the right hand.
-- Garden VFX: floating pumpkin / corn / hay-bale cubes, straw + leaf bursts,
-- dust puffs. Neon is only the eyes, the fork tine tips and a hidden mouth glow.
return {
	DisplayName = "Scarecrow Sentry",
	Rarity = "Rare",
	Element = "Harvest",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		-- palette
		local BURLAP, BURLAP_D, BURLAP_L = "#d6b47e", "#ad8752", "#ead2a6"
		local STITCH, SOCKET, MOUTH = "#4a2e18", "#2b1a0e", "#170f0a"
		local EYE, PUPIL = "#ff8a1a", "#2a0c00"
		local HAT, HAT_D, BAND = "#ecc85e", "#c4973a", "#9a3a22"
		local PLAID, PLAID_D, PLAID_L = "#c8402f", "#862420", "#f2ddb0"
		local DENIM, DENIM_D, DENIM_L = "#4a6fb5", "#2f4b87", "#7193d2"
		local PATCH_Y, PATCH_G, PATCH_B, PATCH_S = "#e2a93c", "#78b44a", "#5a8fd6", "#9fb36a"
		local ROPE, ROPE_D, BRASS = "#d0a96b", "#9c7944", "#d9b046"
		local STRAW, STRAW_D, STRAW_L = "#f3d466", "#d4a63a", "#fbe8a2"
		local WOOD, WOOD_D = "#8b5a2b", "#5c3819"
		local METAL, METAL_D = "#bcc1cc", "#7f858f"
		local PUMPKIN, PUMPKIN_D, LEAF, LEAF_D = "#f08a24", "#c4621a", "#5fae3c", "#3e8a2a"
		local CORN, CORN_D, SUN = "#f8d03c", "#dca522", "#ffcf2e"
		local RED = "#e8262a"
		local NEON = { mat = "Neon" }
		local STRAWS = { STRAW, STRAW_D, STRAW_L }

		-- straw tuft: thin stepped strands fanning out from `base` toward each tip
		local function tuft(bone, base, tips, w)
			for i, tip in tips do
				B:beam(bone, base, tip, w or 0.2, w or 0.2, STRAWS[(i - 1) % 3 + 1])
			end
		end
		-- little stitch ticks (dark thread) along a line on a face
		local function ticks(bone, a, b, n, size, color)
			for i = 0, n - 1 do
				local p = a:Lerp(b, n == 1 and 0.5 or i / (n - 1))
				B:block(bone, size, CFrame.new(p), color or STITCH)
			end
		end

		------------------------------------------------------------------
		-- Hips: patched overall shorts, rope belt with a knot, waist straw
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 3.7, 0))
		B:block(hips, v(2.5, 1.1, 1.6), cf(0, 3.85, 0), DENIM)
		B:block(hips, v(1.3, 0.45, 1.4), cf(0, 3.2, 0), DENIM_D)
		B:sym(function()
			B:block(hips, v(0.1, 0.9, 1.2), cf(1.27, 3.85, 0), DENIM_D)
		end)
		-- back pocket patch with stitches
		B:block(hips, v(0.75, 0.6, 0.1), cf(0.55, 3.85, 0.83), PATCH_Y)
		ticks(hips, v(0.3, 4.17, 0.89), v(0.8, 4.17, 0.89), 2, v(0.08, 0.16, 0.06))
		-- rope belt (twisted: darker ticks) + knot
		B:block(hips, v(2.7, 0.32, 1.8), cf(0, 4.45, 0), ROPE)
		for i = -1, 1 do
			B:block(hips, v(0.14, 0.34, 0.06), cf(i * 0.6 - 0.35, 4.45, -0.92, 0, 0, 30), ROPE_D)
		end
		B:block(hips, v(0.55, 0.48, 0.35), cf(0.6, 4.45, -0.95), ROPE_D)
		local rope = B:bone("RopeEnd", "Hips", v(0.6, 4.3, -1.0))
		B:block(rope, v(0.22, 0.75, 0.22), cf(0.48, 3.95, -1.02), ROPE)
		B:block(rope, v(0.22, 0.6, 0.22), cf(0.74, 4.0, -1.05), ROPE)
		B:block(rope, v(0.3, 0.2, 0.3), cf(0.48, 3.55, -1.02), STRAW_D)
		B:block(rope, v(0.3, 0.2, 0.3), cf(0.74, 3.68, -1.05), STRAW_D)
		-- straw poking out under the belt (sides + back)
		B:sym(function()
			tuft(hips, v(1.15, 4.3, 0.25), { v(1.85, 3.8, 0.45), v(1.75, 4.05, 0.85), v(1.8, 3.6, 0.0) })
		end)
		tuft(hips, v(0, 4.3, 0.75), { v(0.35, 3.85, 1.35), v(-0.3, 3.8, 1.35) })

		------------------------------------------------------------------
		-- Legs: patched overall legs, rolled cuffs, ankle straw, stake feet
		------------------------------------------------------------------
		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Hips", v(0.65, 3.55, 0))
			B:block(thigh, v(1.05, 1.65, 1.05), cf(0.65, 2.75, 0), DENIM)
			B:block(thigh, v(0.08, 1.4, 0.6), cf(1.2, 2.8, 0), DENIM_D)
			B:block(thigh, v(0.62, 0.55, 0.08), cf(0.65, 2.3, -0.56), side == "R" and PATCH_G or PATCH_Y)
			ticks(thigh, v(0.45, 2.6, -0.61), v(0.85, 2.6, -0.61), 2, v(0.07, 0.15, 0.05))
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(0.65, 2.0, 0))
			B:block(shin, v(1.0, 1.35, 1.0), cf(0.65, 1.33, 0), DENIM)
			B:block(shin, v(1.16, 0.32, 1.16), cf(0.65, 0.8, 0), DENIM_L)
			B:block(shin, v(0.08, 1.0, 0.5), cf(1.17, 1.45, 0), DENIM_D)
			tuft(shin, v(0.65, 0.72, 0), { v(1.3, 0.5, 0.25), v(0.95, 0.45, -0.65) })
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(0.65, 0.6, 0))
			B:block(foot, v(0.4, 0.45, 0.4), cf(0.65, 0.58, 0), WOOD)
			B:block(foot, v(0.82, 0.4, 1.3), cf(0.65, 0.2, -0.15), WOOD)
			B:block(foot, v(0.84, 0.08, 1.0), cf(0.65, 0.32, -0.2), WOOD_D)
			B:block(foot, v(0.7, 0.3, 0.45), cf(0.65, 0.15, -1.0), WOOD_D)
			local fx = B:block(foot, v(0.8, 0.1, 1.2), cf(0.65, 0.05, -0.2), WOOD, { tr = 1, name = "FootFX" .. side })
			B:emitter(fx, "dust", {
				name = "Dust" .. side, color = { "#efe2c4", "#c9b38a" }, size = { 0.8, 1.6, 2.0 }, speed = { 3, 6 },
				life = { 0.4, 0.8 }, spread = 80,
			})
		end)

		------------------------------------------------------------------
		-- Chest: plaid shirt, overall bib + straps, collar straw
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Hips", v(0, 4.4, 0))
		B:block(chest, v(2.4, 2.1, 1.5), cf(0, 5.45, 0), PLAID)
		B:block(chest, v(2.8, 0.45, 1.6), cf(0, 6.45, 0), PLAID_D)
		B:sym(function()
			-- side plaid: checker squares + cream lines
			B:block(chest, v(0.1, 0.7, 0.6), cf(1.22, 5.0, -0.35), PLAID_D)
			B:block(chest, v(0.1, 0.7, 0.6), cf(1.22, 5.75, 0.38), PLAID_D)
			B:block(chest, v(0.08, 2.0, 0.12), cf(1.24, 5.4, 0.0), PLAID_L)
			B:block(chest, v(0.08, 0.12, 1.52), cf(1.24, 5.38, 0), PLAID_L)
			-- bib straps over the shoulders
			B:block(chest, v(0.36, 0.7, 0.14), cf(0.62, 6.25, -0.86), DENIM)
			B:block(chest, v(0.36, 0.12, 1.66), cf(0.62, 6.72, 0), DENIM)
			B:block(chest, v(0.32, 0.22, 0.08), cf(0.62, 5.9, -0.95), BRASS)
			-- collar points
			B:block(chest, v(0.6, 0.14, 0.55), cf(0.42, 6.74, -0.55, 0, 0, -18), PLAID_D)
			-- collar straw
			tuft(chest, v(0.8, 6.7, -0.2), { v(1.65, 6.95, -0.55), v(1.55, 7.15, -0.1) })
			tuft(chest, v(0.7, 6.7, 0.45), { v(1.4, 7.0, 0.95), v(0.9, 7.1, 1.15) })
		end)
		tuft(chest, v(0, 6.7, 0.55), { v(0.15, 7.1, 1.35), v(-0.25, 6.95, 1.3) })
		-- back plaid + crossed straps
		B:block(chest, v(0.7, 0.7, 0.1), cf(-0.6, 5.0, 0.77), PLAID_D)
		B:block(chest, v(0.7, 0.7, 0.1), cf(0.6, 5.85, 0.77), PLAID_D)
		B:block(chest, v(2.42, 0.12, 0.08), cf(0, 5.38, 0.79), PLAID_L)
		B:beam(chest, v(0.65, 6.65, 0.84), v(-0.5, 4.45, 0.84), 0.34, 0.1, DENIM)
		B:beam(chest, v(-0.65, 6.65, 0.86), v(0.5, 4.45, 0.86), 0.34, 0.1, DENIM_D)
		-- front bib with a pocket and a patch
		B:block(chest, v(1.7, 1.5, 0.15), cf(0, 5.15, -0.8), DENIM)
		B:block(chest, v(1.72, 0.16, 0.18), cf(0, 5.9, -0.8), DENIM_D)
		B:block(chest, v(0.8, 0.55, 0.08), cf(0.2, 5.3, -0.9), DENIM_D)
		B:block(chest, v(0.55, 0.5, 0.06), cf(-0.45, 4.75, -0.9), PATCH_Y)
		ticks(chest, v(-0.65, 5.0, -0.94), v(-0.25, 5.0, -0.94), 2, v(0.07, 0.15, 0.05))
		-- hidden FX volumes
		local cfx = B:block(chest, v(2, 2, 1.4), cf(0, 5.6, 0), PLAID, { tr = 1, name = "ChestFX" })
		B:emitter(cfx, "burst", {
			name = "StrawBurst", color = { STRAW_L, STRAW, STRAW_D }, size = { 0.5, 0.4, 0 }, speed = { 6, 12 },
			life = { 0.5, 1.0 }, spread = 180, accel = { 0, -14, 0 }, drag = 1,
		})
		B:emitter(cfx, "leaf", {
			name = "StrawFly", color = { STRAW, STRAW_D, LEAF }, rate = 14, enabled = false, size = { 0.35, 0.3, 0.2 },
			speed = { 2, 5 }, life = { 0.5, 0.9 },
		})
		local aura = B:block(chest, v(6, 7, 4), cf(0, 5.5, 0), PLAID, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "Sparkle", color = { "#ffffff", "#ffd27a" }, rate = 2 })

		-- "!" that pops above the hat when the plant is stolen (prop)
		local pop = B:bone("Pop", "Chest", v(-2.2, 10.6, -0.6))
		B:block(pop, v(0.6, 1.3, 0.6), cf(-2.2, 11.35, -0.6), "#ffd12e", { tr = 1, name = "Exclaim" })
		B:block(pop, v(0.6, 0.55, 0.6), cf(-2.2, 10.3, -0.6), "#ffd12e", { tr = 1, name = "ExclaimDot" })

		------------------------------------------------------------------
		-- Neck (wooden pole) + Head (burlap sack)
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Chest", v(0, 6.65, 0.05))
		B:block(neck, v(0.55, 0.7, 0.55), cf(0, 6.85, 0.1), WOOD)

		local head = B:bone("Head", "Neck", v(0, 6.95, 0.1))
		B:block(head, v(3.0, 1.65, 2.6), cf(0, 8.275, -0.1), BURLAP) -- upper sack
		B:block(head, v(3.0, 0.7, 1.3), cf(0, 7.1, 0.55), BURLAP) -- back of the lower sack
		B:block(head, v(2.6, 0.3, 2.3), cf(0, 9.15, 0.0), BURLAP_D) -- bunched top (under the hat)
		B:block(head, v(2.0, 0.35, 1.8), cf(0, 6.62, 0.2), BURLAP_D) -- cinch
		B:block(head, v(2.15, 0.22, 1.95), cf(0, 6.74, 0.2), ROPE) -- rope tie
		B:block(head, v(0.45, 0.38, 0.35), cf(0.35, 6.72, 1.25), ROPE_D)
		B:sym(function()
			B:block(head, v(0.1, 1.2, 1.5), cf(1.53, 8.15, 0.3), BURLAP_D)
		end)
		-- side patch (right) with stitches
		B:block(head, v(0.08, 0.75, 0.75), cf(1.6, 8.45, 0.45), PATCH_S)
		ticks(head, v(1.65, 8.85, 0.45), v(1.65, 8.05, 0.45), 3, v(0.06, 0.1, 0.3))
		-- back seam + burlap texture squares
		B:block(head, v(0.12, 1.55, 0.06), cf(0, 8.2, 1.22), STITCH)
		ticks(head, v(0, 8.75, 1.24), v(0, 7.65, 1.24), 3, v(0.38, 0.08, 0.05))
		B:block(head, v(0.8, 0.6, 0.06), cf(-0.8, 8.6, 1.22), BURLAP_D)
		B:block(head, v(0.6, 0.5, 0.06), cf(0.85, 7.75, 1.22), BURLAP_L)
		-- mouth: dark interior seen through the jagged gap, grin corners curling up
		B:block(head, v(2.5, 0.55, 1.2), cf(0, 7.22, -0.75), MOUTH)
		B:block(head, v(2.3, 0.4, 0.04), cf(0, 7.28, -1.355), EYE, { mat = "Neon", tr = 1, name = "MouthGlow" })
		B:sym(function()
			B:block(head, v(0.32, 0.32, 0.1), cf(1.2, 7.56, -1.42), MOUTH)
			B:block(head, v(0.3, 0.2, 0.15), cf(0.3, 7.36, -1.33), BURLAP)
			B:block(head, v(0.3, 0.2, 0.15), cf(0.9, 7.36, -1.33), BURLAP)
		end)
		for i, x in { -0.6, 0, 0.6 } do
			B:block(head, v(0.1, 0.34, 0.08), cf(x, 7.52, -1.44, 0, 0, (i % 2 == 0) and 14 or -14), STITCH)
		end
		-- jack-o'-lantern nose: stepped dark triangle
		B:block(head, v(0.5, 0.16, 0.1), cf(0, 7.78, -1.44), SOCKET)
		B:block(head, v(0.24, 0.16, 0.1), cf(0, 7.92, -1.44), SOCKET)
		local mfx = B:block(head, v(1.2, 0.5, 0.4), cf(0, 7.3, -1.7), BURLAP, { tr = 1, name = "MouthFX" })
		B:emitter(mfx, "burst", {
			name = "Sneeze", color = { STRAW_L, STRAW, "#f4ead2" }, size = { 0.45, 0.35, 0 }, speed = { 7, 13 },
			life = { 0.4, 0.8 }, spread = 25, accel = { 0, -10, 0 }, dir = "Front", drag = 2,
		})
		local efx = B:block(head, v(2.0, 0.6, 0.3), cf(0, 8.3, -1.8), BURLAP, { tr = 1, name = "EyeFX" })
		B:emitter(efx, "burst", { name = "EyeEmbers", color = { "#fff2c0", EYE }, size = { 0.3, 0.2, 0 }, speed = { 2, 5 }, life = { 0.4, 0.8 }, accel = { 0, 4, 0 } })
		B:light(efx, { name = "EyeLight", color = EYE, brightness = 0.5, range = 8 })
		-- anger mark (prop): a red pinwheel cross beside the hat crown
		local AM = v(1.25, 9.55, -1.25)
		local marks = {
			{ v(0.45, 0.14, 0.12), v(0.08, 0.22, 0) },
			{ v(0.45, 0.14, 0.12), v(-0.08, -0.22, 0) },
			{ v(0.14, 0.45, 0.12), v(0.22, -0.08, 0) },
			{ v(0.14, 0.45, 0.12), v(-0.22, 0.08, 0) },
		}
		for i, m in marks do
			B:block(head, m[1], CFrame.new(AM + m[2]), RED, { tr = 1, name = "AngryMark" .. i })
		end

		-- EYES (own bones so they can pop): dark cut-out socket + glowing
		-- orange hole + a pupil on the FRONT face only
		B:sym(function(side)
			local EX = 0.86
			local eb = B:bone("Eye" .. side, "Head", v(EX, 8.3, -1.4))
			-- stepped triangle (point up), dark cut rim behind each step; the
			-- bottom steps wrap round the head's front corner so the glow
			-- still reads from the side
			local rows = { { 8.08, 0.92 }, { 8.32, 0.66 }, { 8.54, 0.38 } }
			for i, r in rows do
				B:block(eb, v(r[2] + 0.2, 0.34, 0.1), cf(EX, r[1], -1.44), SOCKET)
				B:block(eb, v(r[2], 0.24, 0.24), cf(EX, r[1], -1.49), EYE, { mat = "Neon", name = i == 1 and ("EyeGlow" .. side) or nil })
			end
			B:block(eb, v(0.12, 0.5, 0.42), cf(1.5, 8.2, -1.24), SOCKET)
			B:block(eb, v(0.1, 0.36, 0.3), cf(1.53, 8.2, -1.25), EYE, NEON)
			B:block(eb, v(0.26, 0.34, 0.06), cf(EX - 0.1, 8.2, -1.62), PUPIL)
			-- heavy stitched brow on its own bone (angry tilt baked in)
			local brow = B:bone("Brow" .. side, "Head", v(0.86, 8.93, -1.75))
			B:block(brow, v(1.2, 0.26, 0.14), cf(0.86, 8.93, -1.75, 0, 0, 12), STITCH)
			B:block(brow, v(0.3, 0.26, 0.5), cf(1.38, 9.04, -1.55, 0, 0, 12), STITCH)
			for k = -1, 1 do
				B:block(brow, v(0.08, 0.46, 0.06), cf(0.86 + k * 0.36, 8.93 + k * 0.075, -1.83, 0, 0, 12), SOCKET)
			end
			-- eyelid (prop: hidden until it blinks down over the eye)
			local lid = B:bone("Lid" .. side, "Head", v(0.86, 9.0, -1.66))
			B:block(lid, v(1.12, 0.72, 0.06), cf(0.86, 9.0, -1.655), BURLAP_D, { tr = 1, name = "Lid" .. side })
		end)

		-- JAW: lower sack lip with jagged teeth + stitches
		local jaw = B:bone("Jaw", "Head", v(0, 7.35, 0.1))
		B:block(jaw, v(2.8, 0.45, 1.5), cf(0, 6.975, -0.65), BURLAP)
		B:block(jaw, v(2.4, 0.05, 1.2), cf(0, 7.22, -0.75), MOUTH)
		B:block(jaw, v(2.4, 0.14, 0.08), cf(0, 6.83, -1.42), BURLAP_D)
		for _, x in { -1.1, -0.55, 0, 0.55, 1.1 } do
			B:block(jaw, v(0.28, 0.2, 0.15), cf(x, 7.27, -1.33), BURLAP)
		end
		for i, x in { -0.6, 0, 0.6 } do
			B:block(jaw, v(0.1, 0.3, 0.08), cf(x, 7.1, -1.44, 0, 0, (i % 2 == 0) and -14 or 14), STITCH)
		end

		-- straw "hair" poking out under the hat brim
		local hair = B:bone("Hair", "Head", v(0, 8.9, 0.3))
		B:sym(function()
			tuft(hair, v(1.35, 8.85, 0.2), { v(2.0, 8.35, 0.4), v(1.95, 8.6, -0.25), v(1.85, 8.15, 0.85) })
			tuft(hair, v(1.0, 8.85, 1.0), { v(1.4, 8.25, 1.6) })
		end)
		tuft(hair, v(0, 8.85, 1.1), { v(0.25, 8.1, 1.75), v(-0.3, 8.2, 1.7) })

		------------------------------------------------------------------
		-- Hat: crown + patch + sunflower band, four floppy brim flaps
		------------------------------------------------------------------
		local hat = B:bone("Hat", "Head", v(0, 9.05, -0.05))
		B:block(hat, v(3.4, 0.25, 3.2), cf(0, 9.15, -0.05), HAT)
		B:block(hat, v(2.5, 0.5, 2.3), cf(0, 9.52, 0.05), HAT)
		B:block(hat, v(2.6, 0.26, 2.4), cf(0, 9.42, 0.05), BAND)
		B:block(hat, v(1.9, 0.2, 1.7), cf(0, 9.86, 0.1), HAT_D)
		B:block(hat, v(0.72, 0.42, 0.08), cf(-0.55, 9.6, -1.12), PATCH_B)
		ticks(hat, v(-0.8, 9.6, -1.17), v(-0.3, 9.6, -1.17), 2, v(0.07, 0.5, 0.04))
		-- sunflower + leaves tucked in the band (right side)
		B:block(hat, v(0.14, 0.9, 0.45), cf(1.32, 9.75, 0.45, -20, 0, -10), LEAF)
		B:block(hat, v(0.14, 0.7, 0.4), cf(1.32, 9.65, 0.85, 30, 0, -10), LEAF_D)
		B:block(hat, v(0.16, 0.62, 0.62), cf(1.36, 9.95, 0.05), SUN)
		B:block(hat, v(0.1, 0.28, 0.28), cf(1.45, 9.95, 0.05), WOOD_D)
		local function flap(name, pivot, size, at, fray, frayAt)
			local b = B:bone(name, "Hat", pivot)
			B:block(b, size, CFrame.new(at), HAT)
			B:block(b, fray, CFrame.new(frayAt), HAT_D)
			return b
		end
		local bf = flap("BrimF", v(0, 9.15, -1.55), v(4.0, 0.22, 0.7), v(0, 9.13, -1.9), v(3.8, 0.12, 0.2), v(0, 9.08, -2.2))
		flap("BrimB", v(0, 9.15, 1.45), v(4.4, 0.22, 1.0), v(0, 9.13, 1.95), v(4.2, 0.12, 0.22), v(0, 9.08, 2.4))
		B:sym(function(side)
			flap("Brim" .. side, v(1.6, 9.15, -0.05), v(1.0, 0.22, 3.1), v(2.1, 9.13, -0.05), v(0.22, 0.12, 2.9), v(2.55, 9.08, -0.05))
		end)
		B:trail(bf, v(1.9, 9.13, -2.2), v(1.9, 9.13, -1.7), { name = "HatTrail", color = { STRAW_L, HAT }, life = 0.2, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- Arms: plaid sleeves, cuff straw, wooden wrists, twig fingers.
		-- The right hand holds the pitchfork.
		------------------------------------------------------------------
		B:sym(function(side)
			local isR = side == "R"
			local S, E, W, H = v(1.35, 6.35, 0), v(1.95, 4.85, 0), v(2.3, 3.62, 0), v(2.32, 3.5, 0)
			local arm = B:bone("Arm" .. side, "Chest", S)
			B:block(arm, v(0.95, 0.75, 1.0), cf(1.5, 6.35, 0), PLAID_D)
			B:beam(arm, v(1.5, 6.3, 0), E, 0.82, 0.82, PLAID)
			B:beam(arm, v(1.7, 5.7, 0), v(1.76, 5.5, 0), 0.88, 0.88, PLAID_L)
			B:beam(arm, v(1.86, 5.18, 0), v(1.92, 4.98, 0), 0.86, 0.86, PLAID_D)
			B:block(arm, v(0.08, 0.5, 0.5), cf(2.3, 5.05, 0, 0, 0, 22), isR and PATCH_Y or PATCH_G)
			local fore = B:bone("Forearm" .. side, "Arm" .. side, E)
			B:beam(fore, E + v(0, 0.15, 0), v(2.27, 3.8, 0), 0.76, 0.76, PLAID)
			B:beam(fore, v(2.08, 4.35, 0), v(2.13, 4.15, 0), 0.8, 0.8, PLAID_D)
			B:beam(fore, v(2.24, 3.88, 0), v(2.29, 3.66, 0), 0.92, 0.92, PLAID_D)
			tuft(fore, v(2.28, 3.68, 0), { v(2.85, 3.45, 0.2), v(1.85, 3.4, 0.3), v(2.45, 3.35, 0.55) })
			B:block(fore, v(0.32, 0.4, 0.32), cf(2.3, 3.5, 0), WOOD)
			local hand = B:bone("Hand" .. side, "Forearm" .. side, H)
			B:block(hand, v(0.55, 0.45, 0.55), cf(2.32, 3.2, 0.05), WOOD_D)
			if isR then
				-- twig fingers wrapped round the fork shaft
				B:block(hand, v(0.5, 0.16, 0.18), cf(2.35, 3.32, -0.66), WOOD)
				B:block(hand, v(0.5, 0.16, 0.18), cf(2.35, 3.1, -0.66), WOOD)
				B:block(hand, v(0.16, 0.42, 0.2), cf(2.02, 3.25, -0.42), WOOD)
			else
				B:beam(hand, v(2.25, 3.0, -0.15), v(2.3, 2.55, -0.38), 0.17, 0.17, WOOD)
				B:beam(hand, v(2.35, 3.0, 0.05), v(2.45, 2.5, 0.12), 0.17, 0.17, WOOD)
				B:beam(hand, v(2.42, 3.0, 0.2), v(2.65, 2.6, 0.38), 0.17, 0.17, WOOD)
				B:beam(hand, v(2.1, 3.15, -0.1), v(1.85, 2.85, -0.32), 0.17, 0.17, WOOD)
				B:trail(hand, v(2.35, 2.6, -0.1), v(2.32, 3.2, 0), { name = "HandTrail", color = { STRAW_L, STRAW }, life = 0.18, trans = { 0.55, 1 } })
			end
			if isR then
				----------------------------------------------------------
				-- Pitchfork (grip at G; shaft along +Y, tines in the X plane)
				----------------------------------------------------------
				local G = v(2.35, 3.2, -0.4)
				local fork = B:bone("Fork", "HandR", G)
				B:beam(fork, v(2.35, 0.7, -0.4), v(2.35, 6.45, -0.4), 0.32, 0.32, WOOD)
				B:block(fork, v(0.4, 0.22, 0.4), cf(2.35, 1.5, -0.4), WOOD_D)
				B:block(fork, v(0.4, 0.22, 0.4), cf(2.35, 5.6, -0.4), WOOD_D)
				B:block(fork, v(0.42, 0.28, 0.42), cf(2.35, 0.7, -0.4), METAL_D)
				B:block(fork, v(0.5, 0.5, 0.5), cf(2.35, 6.5, -0.4), METAL)
				B:block(fork, v(1.5, 0.28, 0.32), cf(2.35, 6.8, -0.4), METAL_D)
				for _, dx in { -0.62, 0, 0.62 } do
					B:block(fork, v(0.22, 1.1, 0.22), cf(2.35 + dx, 7.38, -0.4), METAL)
					B:block(fork, v(0.24, 0.26, 0.24), cf(2.35 + dx, 8.04, -0.4), EYE, NEON)
				end
				B:trail(fork, v(2.35, 8.1, -0.4), v(2.35, 6.9, -0.4), { name = "ForkTrail", color = { "#ffffff", EYE }, life = 0.24, trans = { 0.4, 1 } })
				local ffx = B:block(fork, v(1.4, 1.2, 0.4), cf(2.35, 7.6, -0.4), METAL, { tr = 1, name = "ForkFX" })
				B:emitter(ffx, "burst", { name = "ForkSpark", color = { "#ffffff", EYE }, speed = { 8, 15 }, size = { 0.4, 0.25, 0 }, life = { 0.2, 0.45 }, drag = 3 })
				B:light(ffx, { name = "ForkLight", color = EYE, brightness = 0.01, range = 10 })
			end
		end)

		------------------------------------------------------------------
		-- Floating harvest cubes: pumpkins, a corn cob, a hay bale
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 5, 0))
		local spots = {
			{ 6.2, 6.6, 1.2, "pumpkin" },
			{ -6.0, 4.6, 2.2, "corn" },
			{ 3.6, 2.4, 5.0, "bale" },
			{ -4.0, 8.8, -3.8, "pumpkin" },
		}
		for i, s in spots do
			local p = v(s[1], s[2], s[3])
			local ob = B:bone("Orb" .. i, "Orbit", p)
			local function at(x, y, z, rx, ry, rz)
				return CFrame.new(p + v(x, y, z)) * P.ang(rx or 0, ry or 0, rz or 0)
			end
			if s[4] == "pumpkin" then
				local k = i == 1 and 1 or 0.8
				B:block(ob, v(1.3, 1.0, 1.3) * k, at(0, 0, 0), PUMPKIN)
				B:block(ob, v(0.22, 1.02, 1.32) * k, at(0, 0, 0), PUMPKIN_D)
				B:block(ob, v(1.32, 1.02, 0.22) * k, at(0, 0, 0), PUMPKIN_D)
				B:block(ob, v(0.25, 0.4, 0.25) * k, at(0, 0.65 * k, 0), WOOD_D)
				B:block(ob, v(0.5, 0.1, 0.32) * k, at(0.3 * k, 0.55 * k, 0.1), LEAF)
				B:block(ob, v(1.34, 0.12, 0.12) * k, at(0, -0.1 * k, -0.62 * k), EYE, NEON)
			elseif s[4] == "corn" then
				B:block(ob, v(0.62, 1.3, 0.62), at(0, 0, 0), CORN)
				B:block(ob, v(0.66, 0.14, 0.66), at(0, 0.25, 0), CORN_D)
				B:block(ob, v(0.66, 0.14, 0.66), at(0, -0.25, 0), CORN_D)
				B:block(ob, v(0.12, 1.1, 0.5), at(0.36, -0.2, 0, 0, 0, -12), LEAF)
				B:block(ob, v(0.12, 1.0, 0.5), at(-0.36, -0.25, 0, 0, 0, 12), LEAF_D)
			else
				B:block(ob, v(1.3, 0.85, 0.9), at(0, 0, 0), STRAW)
				B:block(ob, v(0.14, 0.88, 0.94), at(-0.35, 0, 0), ROPE_D)
				B:block(ob, v(0.14, 0.88, 0.94), at(0.35, 0, 0), ROPE_D)
				B:block(ob, v(1.32, 0.12, 0.6), at(0, 0.45, 0), STRAW_L)
				B:block(ob, v(0.1, 0.4, 0.1), at(0.5, 0.6, 0.2, 0, 0, -25), STRAW_D)
			end
		end
	end,
}
