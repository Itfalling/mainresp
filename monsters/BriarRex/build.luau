--!nocheck
-- Briar Rex: a towering thorn-armoured tyrant guarding the rose garden.
-- Deep forest-green stepped T-rex body with dark bark armour plates, thorny
-- vines wrapped round the legs and tail, rows of pale thorn spikes along the
-- back (some crowned with red rose blossoms), a big blocky head with a heavy
-- bark brow ridge, fierce amber slit eyes, a huge jaw with a neat row of white
-- block teeth and a mossy chin. Powerful drumstick legs with big clawed feet,
-- a 6-bone tail - and comically tiny arms (it is very touchy about them).
-- Neon is kept to the eyes, a few pink rose hearts and thin bands.
return {
	DisplayName = "Briar Rex",
	Rarity = "Divine",
	Element = "Thorn",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local MAIN, DARK = "#21804b", "#145233"
		local MOSS, BELLY = "#7fae3c", "#c9d68c"
		local BARK, BARK2 = "#5e3b22", "#8a5f36"
		local THORN, THORND = "#ecdfb8", "#c9b98c"
		local VINE, LEAF = "#3f8f2c", "#63c23a"
		local ROSE, ROSE2, ROSED = "#d8263f", "#f2475e", "#8f1028"
		local WHITE, MOUTH, TONGUE = "#f7f4e8", "#1b0f12", "#c4405e"
		local EYE, PUPIL, PINK = "#ffc93a", "#140a06", "#ff4fb0"
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- helpers
		------------------------------------------------------------------
		-- rose blossom: green sepal, 4 red petals round a dark heart (optional
		-- tiny neon-pink core). `at` = center of the blossom's base.
		local function rose(bone, at, s, glow)
			B:block(bone, v(1.5, 0.4, 1.5) * s, CFrame.new(at + v(0, 0.2 * s, 0)), LEAF)
			for k = 0, 3 do
				local a = math.rad(k * 90 + 45)
				local o = v(math.sin(a) * 0.42, 0, math.cos(a) * 0.42) * s
				B:block(bone, v(0.85, 0.9, 0.85) * s, CFrame.new(at + o + v(0, 0.75 * s, 0)) * ang(0, k * 90 + 45, 0), k % 2 == 0 and ROSE or ROSE2)
			end
			B:block(bone, v(0.8, 0.8, 0.8) * s, CFrame.new(at + v(0, 1.05 * s, 0)), ROSED)
			if glow then
				B:block(bone, v(0.4, 0.3, 0.4) * s, CFrame.new(at + v(0, 1.5 * s, 0)), PINK, NEON)
			end
		end

		-- stepped thorn spike (AtomicKaiju plate idiom): dark bark base step,
		-- pale thorn steps shrinking + leaning back, capped by a rose, a pink
		-- glowing tip or a dark-red thorn point.
		local function plate(bone, x, y, z, steps, w, tip, glow)
			local d, zo = w, 0
			for i = 0, steps - 1 do
				local wide = i == 0 and 1.5 or (1.3 - 0.12 * i)
				B:block(bone, v(wide, 1, d), cf(x, y + i + 0.5, z + zo), i == 0 and BARK or (i % 2 == 1 and THORN or THORND))
				if i < steps - 1 then
					d = math.max(1.0, d * 0.7)
					zo += 0.45
				end
			end
			local top = v(x, y + steps, z + zo + 0.1)
			if tip == "rose" then
				rose(bone, top - v(0, 0.15, 0), 1.0, glow)
			elseif tip == "pink" then
				B:block(bone, v(0.55, 0.6, 0.8), CFrame.new(top + v(0, 0.25, 0.15)), PINK, NEON)
			else
				B:wedge(bone, v(0.7, 0.9, math.max(0.9, d * 0.8)), CFrame.new(top + v(0, 0.4, 0.1)), ROSED)
			end
		end

		-- little leaf block sticking out of a vine
		local function leaf(bone, at, ry, rz)
			B:block(bone, v(0.9, 0.25, 0.6), CFrame.new(at) * ang(0, ry or 0, rz or 0), LEAF)
		end

		------------------------------------------------------------------
		-- HIPS (root of the body) + pelvis armour
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 10.5, 2.5))
		B:block(hips, v(7, 5.6, 7.4), cf(0, 10.6, 3.2), MAIN)
		B:block(hips, v(6.4, 0.8, 7.0), cf(0, 7.6, 3.2), DARK)
		B:block(hips, v(5.6, 0.8, 2.8), cf(0, 13.75, 1.6), BARK)
		B:block(hips, v(5.0, 0.8, 2.6), cf(0, 13.75, 4.6), BARK)
		B:block(hips, v(3.6, 0.3, 0.6), cf(0, 14.2, 2.7), BARK2)
		B:block(hips, v(3.2, 0.3, 0.6), cf(0, 14.2, 5.6), BARK2)
		plate(hips, 0, 14.1, 1.4, 3, 2.4, "thorn")
		plate(hips, 0, 14.1, 4.4, 2, 2.0, "rose", true)
		B:sym(function()
			plate(hips, 2.3, 13.9, 3.2, 1, 1.6, "thorn")
		end)

		------------------------------------------------------------------
		-- CHEST: barrel torso, stepped belly plates, bark flank shields
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Hips", v(0, 12, 0.5))
		B:block(chest, v(8, 7, 7), cf(0, 14.2, -1.8), MAIN)
		B:block(chest, v(6.6, 1.0, 5.4), cf(0, 10.4, -2.0), MOSS)
		local rows = { { 11.3, 4.4 }, { 12.4, 5.4 }, { 13.5, 5.8 }, { 14.6, 5.6 }, { 15.7, 4.8 }, { 16.8, 3.8 } }
		for i, r in rows do
			B:block(chest, v(r[2], 1, 0.8), cf(0, r[1], -5.5 - (i % 2) * 0.22), i % 2 == 0 and BELLY or MOSS)
		end
		B:sym(function()
			B:block(chest, v(0.5, 4.6, 5.2), cf(4.15, 14.2, -1.6), DARK)
			-- overlapping bark shields on the flank
			B:block(chest, v(0.6, 2.6, 3.2), cf(4.5, 15.4, -0.4), BARK)
			B:block(chest, v(0.3, 0.5, 2.6), cf(4.85, 16.5, -0.4), BARK2)
			B:block(chest, v(0.6, 2.0, 2.4), cf(4.5, 12.8, -2.6), BARK)
			B:block(chest, v(0.3, 0.4, 2.0), cf(4.85, 13.6, -2.6), BARK2)
			B:spike(chest, v(4.7, 15.6, 0.4), v(6.0, 16.2, 1.8), 0.7, 0.7, THORN)
			-- top bark ridges carrying the side thorn row
			B:block(chest, v(1.8, 0.6, 5.6), cf(2.7, 17.95, -1.8), BARK)
			plate(chest, 2.7, 18.2, -3.4, 2, 1.6, "thorn")
			plate(chest, 2.7, 18.2, -0.6, 1, 1.4, "thorn")
			-- a thorny vine draped over the shoulder
			B:block(chest, v(0.4, 0.5, 6.4), cf(4.45, 17.3, -1.6, 0, 0, 0), VINE)
			leaf(chest, v(4.8, 17.5, -3.6), 30, -20)
			leaf(chest, v(4.8, 17.2, 0.8), -25, -20)
		end)
		-- big centre thorn spikes, the front one crowned with a glowing rose
		plate(B:bone("BackSpike", "Chest", v(0, 17.6, -3.6)), 0, 17.65, -3.6, 3, 2.8, "rose", true)
		plate(chest, 0, 17.65, -0.4, 3, 2.6, "thorn")
		local backFX = B:block(chest, v(7, 3, 9), cf(0, 19.5, 0), MAIN, { tr = 1, name = "BackFX" })
		B:emitter(backFX, "leaf", {
			name = "AmbientPetals", color = { ROSE, ROSE2, PINK }, rate = 2, size = { 0.45, 0.4, 0.25 }, life = { 2.5, 4 },
		})
		B:emitter(backFX, "leaf", {
			name = "PetalBurst", color = { ROSE, ROSE2, PINK, "#ffffff" }, rate = 0, speed = { 9, 18 }, size = { 0.7, 0.6, 0.3 },
			life = { 1.2, 2.2 }, spread = 160, accel = { 0, -6, 0 }, drag = 2,
		})
		local aura = B:block(chest, v(9, 8, 14), cf(0, 13, 1), MAIN, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "AuraSparkle", color = { "#ffffff", PINK }, rate = 3 })

		------------------------------------------------------------------
		-- NECK
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Chest", v(0, 16.0, -4.6))
		B:block(neck, v(6, 5, 4.4), cf(0, 17.6, -6.2), MAIN)
		B:block(neck, v(4, 2.4, 0.6), cf(0, 16.0, -8.5), BELLY)
		B:block(neck, v(6.4, 0.8, 3.8), cf(0, 20.1, -6.0), BARK)
		B:block(neck, v(6.3, 3.6, 0.6), cf(0, 17.6, -4.3), DARK) -- collar band
		plate(neck, 0, 20.4, -6.4, 2, 2.2, "thorn")

		------------------------------------------------------------------
		-- HEAD: big blocky skull, heavy bark brow, amber slit eyes
		------------------------------------------------------------------
		local head = B:bone("Head", "Neck", v(0, 18.2, -8.0))
		B:block(head, v(7.4, 4.6, 6.0), cf(0, 20.0, -10.6), MAIN) -- cranium
		B:block(head, v(6.6, 3.6, 0.6), cf(0, 19.8, -7.5), DARK)
		B:block(head, v(5.2, 0.5, 4.4), cf(0, 22.5, -10.0), BARK) -- skull plate
		B:block(head, v(3.4, 0.3, 3.0), cf(0, 22.85, -9.8), BARK2)
		B:block(head, v(6.0, 2.2, 6.2), cf(0, 18.8, -16.5), MAIN) -- snout
		B:block(head, v(3.6, 0.5, 5.2), cf(0, 20.15, -16.0), MAIN) -- snout top step
		B:block(head, v(1.8, 0.4, 4.4), cf(0, 20.5, -15.6), DARK) -- snout ridge
		B:block(head, v(5.2, 1.6, 0.8), cf(0, 18.9, -19.7), MAIN) -- nose plate
		B:block(head, v(6.1, 0.5, 6.3), cf(0, 17.95, -16.5), DARK) -- lip band
		B:block(head, v(7.5, 0.5, 5.0), cf(0, 17.95, -11.0), DARK)
		B:block(head, v(5.4, 0.4, 11.4), cf(0, 17.55, -13.9), MOUTH) -- mouth roof
		B:block(head, v(4.8, 2.0, 0.6), cf(0, 16.8, -8.4), MOUTH) -- throat wall
		-- little thorn crown on the skull (prideful king)
		for k = -1, 1 do
			B:spike(head, v(k * 1.5, 22.9, -10.6 + math.abs(k) * 0.6), v(k * 1.9, 23.1 - math.abs(k) * 0.3, -8.8 + math.abs(k) * 0.6), 0.7, 0.7, THORN)
		end
		B:sym(function(side)
			-- nostril
			B:block(head, v(0.7, 0.4, 0.2), cf(1.3, 19.3, -20.15), MOUTH)
			-- upper teeth: neat rows of white blocks, alternating long/short
			for i = 0, 6 do
				local h = i % 2 == 0 and 1.2 or 0.85
				B:block(head, v(0.6, h, 0.6), cf(2.85, 17.75 - h / 2, -9.9 - i * 1.3), WHITE)
			end
			B:block(head, v(0.6, 1.1, 0.6), cf(1.7, 17.25, -19.2), WHITE)
			B:block(head, v(0.6, 0.8, 0.6), cf(0.6, 17.35, -19.4), WHITE)
			-- snout side colour blocking: dark stripe + pale scale spots
			B:block(head, v(0.15, 0.5, 4.6), cf(3.04, 19.35, -16.2), DARK)
			B:block(head, v(0.15, 0.6, 0.9), cf(3.04, 18.6, -14.4), MOSS)
			B:block(head, v(0.15, 0.6, 0.9), cf(3.04, 18.6, -17.6), MOSS)
			B:block(head, v(0.15, 1.0, 1.2), cf(3.74, 18.7, -8.6), DARK)
			-- dark cheek wall so the open mouth reads black
			B:block(head, v(0.3, 1.4, 7.0), cf(2.7, 16.9, -12.6), MOUTH)
			-- bark cheek armour + thorn frill pointing back
			B:block(head, v(0.6, 2.4, 3.8), cf(3.9, 19.6, -10.2), BARK)
			B:block(head, v(0.3, 0.5, 3.0), cf(4.25, 20.6, -10.2), BARK2)
			B:spike(head, v(4.0, 19.0, -9.0), v(5.3, 18.4, -6.8), 1.0, 1.0, THORN)
			B:spike(head, v(3.9, 20.4, -8.6), v(5.0, 21.0, -6.6), 0.8, 0.8, THORN)
			-- EYE: dark socket + glowing amber block wrapping the cranium's front
			-- corner; the slit pupil sits on the front face only
			B:block(head, v(2.3, 1.7, 1.0), cf(2.6, 20.95, -13.5), DARK)
			B:block(head, v(1.8, 1.25, 1.0), cf(2.85, 20.9, -13.75), EYE, { mat = "Neon", name = "Eye" .. side })
			B:block(head, v(0.65, 1.1, 0.2), cf(2.55, 20.9, -14.32), PUPIL)
			-- thorn horns behind the brow
			B:spike(head, v(3.2, 22.0, -11.6), v(4.4, 23.0, -9.4), 1.0, 1.0, THORN)
		end)
		-- a rose tucked on the right side of the head (vain!)
		rose(B:bone("HeadRose", "Head", v(4.2, 21.4, -8.4)), v(4.2, 21.4, -8.4), 0.8, false)
		local mouthFX = B:block(head, v(3, 1.6, 1.6), cf(0, 17.4, -20.4), MAIN, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFX, "burst", { name = "RoarBurst", color = { "#ffffff", PINK, ROSE2 } })
		B:emitter(mouthFX, "leaf", {
			name = "MouthPetals", color = { ROSE, ROSE2, PINK }, rate = 0, speed = { 10, 20 }, size = { 0.7, 0.6, 0.3 },
			life = { 0.9, 1.8 }, spread = 40, accel = { 0, -5, 0 }, drag = 2, dir = "Front",
		})
		B:light(mouthFX, { name = "MouthLight", color = PINK, brightness = 0.01, range = 16 })
		B:trail(head, v(0, 20.1, -20.0), v(0, 18.3, -20.0), { name = "SnoutTrail", color = { "#ffffff", PINK }, life = 0.2, trans = { 0.55, 1 } })
		-- CHOMP impact lines (props, flashed on the bite)
		for i = 1, 6 do
			local a = (i - 1) / 6 * 360 + 30
			B:block(head, v(0.35, 0.35, 1.6), CFrame.new(0, 17.6, -21.6) * ang(0, 0, a) * CFrame.new(0, 3.4, 0) * ang(90, 0, 0), "#fff2f8", { mat = "Neon", tr = 1, name = "SnapLine" .. i })
		end
		-- ANGER MARK (prop): cartoon vein cross floating by the skull
		local AM = CFrame.new(4.7, 22.2, -11.8) * ang(0, -30, 45)
		for k = 0, 3 do
			local o = CFrame.Angles(0, 0, math.rad(k * 90)) * CFrame.new(0.55, 0.55, 0)
			B:block(head, v(0.35, 1.0, 0.35), AM * o * CFrame.Angles(0, 0, math.rad(45)), "#ff2e2e", { tr = 1, name = "AngryMark" .. (k + 1) })
		end
		-- SWEAT DROP (prop): the insecure tiny-arms moment
		B:block(head, v(0.7, 0.9, 0.5), cf(4.35, 21.5, -12.7), "#8fdcff", { tr = 1, name = "SweatDrop1" })
		B:block(head, v(0.4, 0.45, 0.35), cf(4.35, 22.15, -12.7), "#8fdcff", { tr = 1, name = "SweatDrop2" })

		-- heavy brows on their own bones (angry tilt / shocked raise)
		B:sym(function(side)
			local brow = B:bone("Brow" .. side, "Head", v(1.6, 21.9, -13.6))
			B:block(brow, v(2.8, 1.0, 2.2), cf(2.75, 21.95, -13.6, 0, 0, 14), BARK)
			B:block(brow, v(1.4, 0.6, 1.6), cf(3.4, 22.55, -13.2, 0, 0, 14), BARK2)
			local lid = B:bone("Lid" .. side, "Head", v(2.85, 20.9, -13.8))
			B:block(lid, v(2.0, 1.4, 1.1), cf(2.85, 20.9, -13.8), DARK, { tr = 1, name = "Eyelid" .. side })
		end)

		------------------------------------------------------------------
		-- JAW: huge lower jaw, neat teeth, tongue, mossy chin
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", v(0, 17.6, -8.6))
		B:block(jaw, v(5.4, 1.4, 10.6), cf(0, 16.8, -14.0), DARK)
		B:block(jaw, v(4.6, 0.6, 9.4), cf(0, 15.85, -13.8), BELLY)
		B:block(jaw, v(5.5, 0.45, 9.0), cf(0, 16.45, -13.2), MOSS) -- jaw stripe
		B:block(jaw, v(4.8, 0.3, 10.0), cf(0, 17.55, -13.8), MOUTH)
		B:block(jaw, v(2.6, 0.35, 5.0), cf(0, 17.7, -12.6), TONGUE)
		B:block(jaw, v(4.4, 1.6, 1.2), cf(0, 17.6, -9.2), MOUTH) -- back of the mouth
		B:sym(function()
			for i = 0, 5 do
				local h = i % 2 == 0 and 0.9 or 0.7
				B:block(jaw, v(0.55, h, 0.55), cf(2.2, 17.5 + h / 2, -10.6 - i * 1.3), WHITE)
			end
			B:block(jaw, v(0.55, 0.8, 0.55), cf(1.3, 17.9, -18.6), WHITE)
			-- moss tufts along the jaw line
			B:block(jaw, v(0.3, 0.5, 2.2), cf(2.75, 16.1, -15.6), LEAF)
			B:block(jaw, v(0.3, 0.4, 1.4), cf(2.75, 16.0, -11.4), MOSS)
		end)
		B:trail(jaw, v(0, 17.6, -19.0), v(0, 16.0, -19.0), { name = "ChompTrail", color = { "#ffffff", ROSE2 }, life = 0.18, trans = { 0.5, 1 } })
		-- mossy chin beard (own bone: it swings)
		local beard = B:bone("Beard", "Jaw", v(0, 15.7, -16.6))
		B:block(beard, v(3.6, 0.8, 2.6), cf(0, 15.3, -17.2), MOSS)
		B:block(beard, v(2.6, 0.8, 1.8), cf(0, 14.6, -17.5), LEAF)
		B:block(beard, v(1.4, 0.6, 1.2), cf(0, 14.0, -17.7), MOSS)

		------------------------------------------------------------------
		-- TINY ARMS (comically small for the 8-stud torso)
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Chest", v(3.7, 13.6, -4.4))
			B:block(arm, v(1.6, 1.4, 2.2), cf(4.3, 13.3, -5.0), MAIN)
			B:block(arm, v(1.8, 0.5, 1.7), cf(4.35, 14.1, -4.8), BARK)
			B:spike(arm, v(4.9, 14.2, -4.6), v(5.5, 15.0, -3.8), 0.5, 0.5, THORN)
			local fore = B:bone("Forearm" .. side, "Arm" .. side, v(4.35, 12.8, -5.9))
			B:block(fore, v(1.3, 1.2, 1.6), cf(4.35, 12.5, -6.4), MAIN)
			B:block(fore, v(1.45, 0.9, 1.0), cf(4.35, 12.1, -7.2), BELLY)
			B:spike(fore, v(4.05, 11.9, -7.5), v(3.95, 11.1, -8.3), 0.45, 0.45, WHITE)
			B:spike(fore, v(4.65, 11.9, -7.5), v(4.75, 11.1, -8.3), 0.45, 0.45, WHITE)
			B:trail(fore, v(4.35, 11.6, -7.6), v(4.35, 12.4, -7.6), { name = "ClawTrail" .. side, color = { "#ffffff", PINK }, life = 0.15, trans = { 0.5, 1 } })
		end)

		------------------------------------------------------------------
		-- LEGS: huge drumstick thighs with bark plates, vine-wrapped shins,
		-- big three-toed feet with white claws
		------------------------------------------------------------------
		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Hips", v(3.6, 10.5, 3.0))
			B:block(thigh, v(4.2, 6.0, 5.6), cf(4.3, 8.6, 2.6), MAIN)
			B:block(thigh, v(3.6, 1.4, 4.0), cf(4.3, 5.9, 1.6), DARK)
			B:block(thigh, v(0.6, 3.2, 3.6), cf(6.6, 9.0, 2.6), BARK)
			B:block(thigh, v(0.3, 0.6, 3.0), cf(6.95, 10.3, 2.6), BARK2)
			B:block(thigh, v(0.3, 0.5, 2.4), cf(6.95, 7.8, 2.6), BARK2)
			B:block(thigh, v(3.0, 1.2, 0.5), cf(4.3, 8.0, -0.3), MOSS) -- front thigh plate
			B:spike(thigh, v(6.8, 9.3, 3.2), v(8.0, 9.9, 4.6), 0.9, 0.9, THORN)
			-- a vine coiling round the thigh
			B:block(thigh, v(4.5, 0.5, 5.9), cf(4.3, 6.9, 2.6, 0, 0, 10), VINE)
			leaf(thigh, v(6.7, 7.4, 0.6), 20, -30)

			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(4.3, 6.0, 1.5))
			local sa, sb = v(4.3, 6.4, 1.3), v(4.3, 1.9, 4.0)
			B:beam(shin, sa, sb, 3.0, 3.0, MAIN)
			B:beam(shin, sa + v(0, -0.2, -1.6), sb + v(0, 0.6, -1.35), 2.0, 0.4, DARK)
			-- vine rings + leaves + thorns on the shin
			local scf, slen = P.span(sa, sb)
			for k, f in { 0.28, 0.68 } do
				local at = scf * CFrame.new(0, 0, -slen * (f - 0.5))
				B:block(shin, v(3.3, 3.3, 0.45), at * ang(k == 1 and 14 or -14, 0, 0), VINE)
				B:spike(shin, (at * CFrame.new(1.6, 0.4, 0)).Position, (at * CFrame.new(2.4, 0.8, 0.3)).Position, 0.4, 0.4, ROSED)
			end
			leaf(shin, (scf * CFrame.new(1.7, -0.5, 0.4)).Position, -20, -30)

			local foot = B:bone("Foot" .. side, "Shin" .. side, v(4.3, 2.0, 4.0))
			B:block(foot, v(2.6, 2.4, 2.4), cf(4.3, 2.0, 4.0), DARK)
			B:block(foot, v(3.8, 1.2, 5.6), cf(4.3, 0.6, 1.8), MAIN)
			B:block(foot, v(3.0, 0.6, 4.0), cf(4.3, 1.45, 1.8), DARK)
			for k = -1, 1 do
				B:block(foot, v(1.1, 1.0, 1.6), cf(4.3 + k * 1.3, 0.5, -1.6), MAIN)
				B:block(foot, v(1.12, 0.3, 1.0), cf(4.3 + k * 1.3, 1.05, -1.8), BARK)
				B:wedge(foot, v(0.85, 0.9, 1.4), cf(4.3 + k * 1.3, 0.45, -3.1), WHITE)
			end
			B:wedge(foot, v(0.8, 0.8, 1.2), cf(4.3, 0.4, 5.2, 0, 180, 0), THORN) -- heel spur
			local dfx = B:block(foot, v(3.6, 0.2, 5), cf(4.3, 0.1, 1.6), MAIN, { tr = 1, name = "StompFX" .. side })
			B:emitter(dfx, "dust", {
				name = "Dust" .. side, color = { "#e9dcc0", "#b9a27c" }, size = { 2.4, 4.4, 5.4 }, speed = { 8, 14 },
				life = { 0.6, 1.2 }, trans = { 0.25, 0.5, 1 }, spread = 85,
			})
			B:trail(foot, v(4.3, 1.0, -3.4), v(4.3, 0.1, -3.4), { name = "FootTrail" .. side, color = { "#ffffff", LEAF }, life = 0.14, trans = { 0.55, 1 } })
		end)

		------------------------------------------------------------------
		-- TAIL: 5 segments + thorny club tip, bark plates, spikes, vines
		------------------------------------------------------------------
		local seg = {
			{ v(0, 10.8, 6.6), v(5.8, 5.0, 4.4), 3, "thorn" },
			{ v(0, 10.3, 10.4), v(4.8, 4.2, 4.2), 2, "rose" },
			{ v(0, 9.6, 14.0), v(3.9, 3.5, 4.0), 2, "thorn" },
			{ v(0, 8.8, 17.4), v(3.1, 2.8, 3.8), 1, "pink" },
			{ v(0, 8.0, 20.6), v(2.4, 2.2, 3.6), 1, "thorn" },
		}
		local parent = "Hips"
		for i, s in seg do
			local name = "Tail" .. i
			local b = B:bone(name, parent, s[1])
			local sz = s[2]
			local c = s[1] + v(0, -0.2, sz.Z / 2 - 0.3)
			B:block(b, sz, CFrame.new(c), MAIN)
			B:block(b, v(sz.X - 0.8, 0.5, sz.Z - 0.6), CFrame.new(c + v(0, -sz.Y / 2 - 0.15, 0)), MOSS)
			B:block(b, v(sz.X - 1.0, 0.5, sz.Z - 0.8), CFrame.new(c + v(0, sz.Y / 2 + 0.2, 0)), BARK)
			if i > 1 then
				B:block(b, v(sz.X + 0.3, sz.Y + 0.3, 0.6), CFrame.new(s[1] + v(0, -0.2, 0.1)), DARK)
			end
			plate(b, 0, c.Y + sz.Y / 2 + 0.4, c.Z - 0.3, s[3], sz.Z * 0.55, s[4], i == 2)
			if i % 2 == 0 then
				-- diagonal vine wrap with a leaf and a thorn
				B:block(b, v(sz.X + 0.25, sz.Y + 0.25, 0.45), CFrame.new(c + v(0, 0, 0.6)) * ang(28, 0, 0), VINE)
				leaf(b, c + v(sz.X / 2 + 0.3, 0.5, 0.2), 20, -30)
				leaf(b, c + v(-sz.X / 2 - 0.3, -0.3, 1.2), -20, 30)
			else
				B:sym(function()
					B:spike(b, c + v(sz.X / 2, 0.3, 0), c + v(sz.X / 2 + 1.0, 0.6, 0.9), 0.6, 0.6, THORN)
				end)
			end
			parent = name
		end
		-- thorny club tip with a rose and a pink glowing tip
		local tip = B:bone("TailTip", "Tail5", v(0, 7.5, 23.6))
		B:block(tip, v(2.2, 2.2, 0.6), cf(0, 7.5, 23.7), DARK)
		B:block(tip, v(2.0, 1.8, 2.4), cf(0, 7.5, 25.0), MAIN)
		B:block(tip, v(1.2, 1.2, 1.4), cf(0, 7.5, 26.8), MAIN)
		B:block(tip, v(1.6, 0.4, 2.0), cf(0, 6.45, 25.0), MOSS)
		B:block(tip, v(0.6, 0.6, 0.8), cf(0, 7.5, 27.8), PINK, NEON)
		B:sym(function()
			B:spike(tip, v(0.9, 7.6, 24.6), v(2.4, 8.2, 25.8), 0.7, 0.7, THORN)
			B:spike(tip, v(0.6, 7.2, 26.2), v(1.7, 6.6, 27.6), 0.6, 0.6, THORN)
		end)
		B:spike(tip, v(0, 8.3, 25.6), v(0, 9.7, 27.0), 0.7, 0.7, THORN)
		rose(tip, v(0, 8.35, 24.3), 0.8, false)
		B:trail(tip, v(0, 8.4, 27.4), v(0, 6.6, 27.4), { name = "TailTrail", color = { "#ffffff", PINK }, life = 0.25, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- Floating hedge cubes with roses, on a tilted ring round the rex
		-- (motion uses the same ring formula)
		------------------------------------------------------------------
		B:bone("Orbit", "Root", v(0, 11, 2))
		for i = 1, 4 do
			local th = math.rad((i - 1) * 90 + 20)
			local y = 11 - 5.0 * math.cos(th) + (i % 2 == 0 and 1.0 or 0)
			local p = v(13.5 * math.sin(th), y, 2 - 15 * math.cos(th))
			local ob = B:bone("Orb" .. i, "Orbit", p)
			local s = i % 2 == 0 and 2.0 or 2.4
			-- a little hedge block (bark base, leafy top) with a rose on it
			B:block(ob, v(s, s * 0.7, s), CFrame.new(p), i % 2 == 0 and VINE or MAIN)
			B:block(ob, v(s + 0.1, s * 0.3, s + 0.1), CFrame.new(p + v(0, -s * 0.42, 0)), BARK)
			B:block(ob, v(s + 0.14, s * 0.18, s + 0.14), CFrame.new(p + v(0, s * 0.3, 0)), LEAF)
			rose(ob, p + v(0, s * 0.38, 0), s * 0.55, i % 2 == 1)
		end

		------------------------------------------------------------------
		-- Stomp shockwave: ring of bark slabs with leafy tops (props)
		------------------------------------------------------------------
		local SC = v(0, 0.4, 2.0)
		local g = B:bone("GroundFX", "Root", SC)
		local gfx = B:block(g, v(8, 0.4, 8), CFrame.new(SC), MAIN, { tr = 1, name = "GroundFXPart" })
		B:emitter(gfx, "burst", { name = "StompCubes", color = { LEAF, ROSE, THORN }, speed = { 10, 20 }, size = { 1.0, 0.7, 0 } })
		for k = 1, 12 do
			local a = (k - 1) / 12 * 360
			local sb = B:bone("Shock" .. k, "Root", SC)
			local at = CFrame.new(SC) * ang(0, a, 0) * CFrame.new(0, 0, -4.0)
			B:block(sb, v(2.6, 0.8, 1.4), at, BARK, { tr = 1, name = "Wave" .. k })
			B:block(sb, v(2.2, 0.25, 1.0), at * CFrame.new(0, 0.5, 0), k % 3 == 0 and ROSE or LEAF, { tr = 1, name = "WaveTop" .. k })
		end
	end,
}
