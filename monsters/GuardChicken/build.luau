--!nocheck
-- Coop Guard Chicken (Guardian #1): a chunky white stud-built hen-rooster who
-- takes guard duty WAY too seriously. White plastic body with light-grey
-- shading, stepped cream belly plates, a gold sheriff-star guard badge, a
-- red stepped comb + wattle, an orange beak (upper beak on Head, lower beak on
-- Jaw - the beak IS the mouth) with two silly buck teeth, big cartoon eyes
-- under heavy dark brows, a too-small tin-bucket guard helmet cocked on the
-- back of its head with a carrot-sprout "plume", stubby wings, dark-tipped
-- tail feathers and chunky orange chicken feet. Neon = one warm yellow accent.
-- Props (hidden, shown by the states): "!" (Alert), anger mark, sweat drop,
-- tiny shocked pupils, eyelids.
return {
	DisplayName = "Coop Guard Chicken",
	Rarity = "Common",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette ---------------------------------------------------------
		local WHITE, SHADE, GREY = "#f8f6f0", "#dedad2", "#c4bfb6" -- feathers / shading
		local CREAM, CREAM2 = "#f6e2b0", "#ecd08f" -- belly plates
		local RED, DRED = "#ec3432", "#b51e26" -- comb / wattle
		local ORANGE, DORANGE = "#ffa222", "#e2731a" -- beak / feet
		local INK, BLACK = "#2a2532", "#17131c" -- brows + tail tips / pupils + mouth
		local SLATE = "#3d5566" -- dark rooster sickle feathers
		local TIN, TIND = "#b4bfcc", "#7d8998" -- bucket helmet
		local GOLD, GOLDD = "#ffc633", "#d18c17" -- badge / helmet band
		local GREEN, DGREEN = "#63cc3a", "#3c9a2a" -- carrot sprout
		local DIRT = "#8a5a33"
		local TONGUE, SWEAT, BLUE = "#ff6f88", "#86d8ff", "#2f5fd0"
		local NEON = "#ffd23d" -- the one neon accent
		local NEONOPT = { mat = "Neon" }

		------------------------------------------------------------------
		-- BODY (pivot at the hips: the whole chicken pitches + bounces)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 2.2, 0.3))
		B:block(body, v(3.0, 1.9, 3.0), cf(0, 2.8, 0.3), WHITE) -- main mass
		B:block(body, v(2.4, 0.45, 2.3), cf(0, 3.9, 0.55), WHITE) -- top step
		B:block(body, v(2.5, 0.4, 2.5), cf(0, 1.7, 0.4), SHADE) -- under step
		B:block(body, v(2.4, 1.6, 0.6), cf(0, 3.0, 2.05), WHITE) -- rump
		B:block(body, v(1.8, 0.8, 0.5), cf(0, 3.95, 2.0), WHITE) -- rump steps up into the tail
		B:block(body, v(1.8, 0.4, 0.5), cf(0, 2.35, 2.1), SHADE)
		B:block(body, v(2.6, 1.7, 0.5), cf(0, 2.75, -1.4), WHITE) -- breast bulge
		B:block(body, v(2.2, 0.5, 0.55), cf(0, 3.55, -1.45), WHITE) -- puffed chest top
		B:sym(function()
			B:block(body, v(0.3, 0.9, 2.5), cf(1.55, 2.3, 0.5), SHADE) -- low flank shading
			B:block(body, v(0.25, 0.3, 1.6), cf(1.56, 1.75, 0.6), GREY)
		end)
		-- stepped cream belly plates (alternating cream / deeper cream)
		local rows = { { 2.08, 1.6 }, { 2.52, 2.2 }, { 2.96, 2.5 }, { 3.4, 2.1 } }
		for i, r in rows do
			B:block(body, v(r[2], 0.46, 0.4), cf(0, r[1], -1.72 - (i % 2) * 0.12), i % 2 == 0 and CREAM2 or CREAM)
		end
		-- gold sheriff-star guard badge (two crossed squares = 8-point star)
		B:block(body, v(0.85, 0.85, 0.12), cf(-0.7, 3.0, -1.98, 0, 0, 45), GOLDD)
		B:block(body, v(0.7, 0.7, 0.12), cf(-0.7, 3.0, -2.04), GOLD)
		B:block(body, v(0.7, 0.7, 0.12), cf(-0.7, 3.0, -2.06, 0, 0, 45), GOLD)
		B:block(body, v(0.36, 0.36, 0.1), cf(-0.7, 3.0, -2.1), GOLDD) -- badge centre boss
		local badge = B:gem(body, v(0.1, 0.1, 0.04), cf(-0.7, 3.0, -2.16), NEON, { name = "BadgeGem" })
		B:light(badge, { name = "BadgeLight", color = NEON, brightness = 0, range = 5 })
		-- stepped feather scales on the rump (alternating white / shade)
		for i, r in { { 2.45, 1.4 }, { 2.95, 2.0 }, { 3.45, 1.6 } } do
			B:block(body, v(r[2], 0.45, 0.3), cf(0, r[1], 2.43 + (i % 2) * 0.1), i % 2 == 0 and SHADE or GREY)
		end
		-- tiny back feather tufts (stepped)
		B:block(body, v(1.2, 0.35, 0.8), cf(0, 4.25, 1.1), SHADE)
		B:block(body, v(0.7, 0.3, 0.6), cf(0, 4.5, 1.25), WHITE)

		local aura = B:block(body, v(2.6, 2.2, 2.6), cf(0, 2.8, 0.4), WHITE, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "AuraSparkle", color = { "#ffffff", NEON }, rate = 2, size = { 0.08, 0.3, 0 } })
		B:emitter(aura, "leaf", {
			name = "FeatherBurst", rate = 0, color = { "#ffffff", SHADE }, size = { 0.45, 0.4, 0.25 },
			speed = { 6, 12 }, spread = 180, life = { 1.0, 2.0 }, accel = { 0, -6, 0 }, drag = 3,
		})

		------------------------------------------------------------------
		-- WINGS (stubby, two bones each for flap follow-through)
		------------------------------------------------------------------
		B:sym(function(side)
			-- three stepped feather layers (coverts -> secondaries -> primaries),
			-- each one lower, longer and a step further out, with dark tip feathers
			local wing = B:bone("Wing" .. side, "Body", v(1.45, 3.35, -0.3))
			B:block(wing, v(0.5, 0.5, 0.7), cf(1.62, 3.32, -0.85), WHITE) -- shoulder knob
			B:block(wing, v(0.5, 0.5, 1.9), cf(1.64, 3.3, 0.05), WHITE) -- coverts
			B:block(wing, v(0.5, 0.5, 2.1), cf(1.7, 2.85, 0.35), SHADE) -- secondaries
			B:block(wing, v(0.5, 0.45, 0.4), cf(1.7, 2.85, 1.6), GREY)
			local tip = B:bone("WingTip" .. side, "Wing" .. side, v(1.72, 2.7, 0.2))
			B:block(tip, v(0.46, 0.5, 1.8), cf(1.77, 2.4, 0.7), GREY) -- primaries
			B:block(tip, v(0.46, 0.5, 0.55), cf(1.77, 2.4, 1.85), INK) -- dark primary tip
			-- serrated stepped feather fringe along the bottom edge
			B:block(tip, v(0.42, 0.42, 0.55), cf(1.8, 1.98, 0.2), SHADE)
			B:block(tip, v(0.42, 0.42, 0.55), cf(1.8, 1.98, 0.8), GREY)
			B:block(tip, v(0.42, 0.42, 0.55), cf(1.8, 1.98, 1.4), INK)
			B:trail(tip, v(1.8, 2.65, 2.1), v(1.8, 1.8, 1.65), { name = "WingTrail" .. side, color = { "#ffffff", NEON }, life = 0.16, trans = { 0.5, 1 } })
		end)

		------------------------------------------------------------------
		-- TAIL (stepped feather fan with dark tips + a follow-through bone)
		------------------------------------------------------------------
		local tail = B:bone("Tail", "Body", v(0, 3.3, 2.2))
		B:block(tail, v(2.0, 1.0, 0.8), cf(0, 3.6, 2.6), WHITE) -- tail base
		B:block(tail, v(1.5, 0.5, 0.6), cf(0, 4.2, 2.75), SHADE)
		-- fan of five stepped sickle feathers, leaning back; the three middle
		-- ones are tall with dark tips
		local tt = B:bone("TailTip", "Tail", v(0, 4.15, 2.95))
		-- {angle, length, mid colour, tip colour}
		local FAN = {
			{ -62, 1.6, SHADE, GREY }, { -31, 2.0, SLATE, INK }, { 0, 2.25, SLATE, INK },
			{ 31, 2.0, SLATE, INK }, { 62, 1.6, SHADE, GREY },
		}
		for i, f in FAN do
			local F = CFrame.new(0, 4.15, 2.95 + (i % 2) * 0.14) * ang(0, 0, f[1]) * ang(36, 0, 0)
			local L = f[2]
			B:block(tt, v(0.8, L * 0.5, 0.5), F * CFrame.new(0, L * 0.25, 0), i % 2 == 0 and SHADE or WHITE)
			B:block(tt, v(0.68, L * 0.35, 0.46), F * CFrame.new(0, L * 0.65, 0), f[3])
			B:block(tt, v(0.56, L * 0.25, 0.44), F * CFrame.new(0, L * 0.92, 0), f[4])
		end

		------------------------------------------------------------------
		-- NECK + HEAD (big cartoon head)
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Body", v(0, 3.35, -0.7))
		B:block(neck, v(2.1, 1.0, 1.9), cf(0, 3.6, -0.85), WHITE)
		B:block(neck, v(2.5, 0.4, 2.2), cf(0, 3.42, -0.8), BLUE) -- guard collar
		B:block(neck, v(2.56, 0.12, 2.26), cf(0, 3.24, -0.8), GOLD) -- collar trim
		B:sym(function()
			B:block(neck, v(0.3, 0.3, 0.12), cf(1.0, 3.45, -1.95), GOLD) -- collar pins
		end)

		local head = B:bone("Head", "Neck", v(0, 3.75, -0.95))
		B:block(head, v(2.6, 1.8, 2.4), cf(0, 4.4, -1.15), WHITE) -- skull
		B:block(head, v(2.2, 0.3, 2.0), cf(0, 5.4, -1.0), WHITE) -- crown step
		B:block(head, v(1.8, 0.7, 0.4), cf(0, 4.85, 0.2), SHADE) -- back-of-head tuft
		B:block(head, v(1.2, 0.4, 0.35), cf(0, 5.25, 0.25), WHITE)
		B:sym(function()
			B:block(head, v(0.25, 0.8, 1.5), cf(1.38, 4.0, -1.0), SHADE) -- cheek feathers
			B:block(head, v(0.2, 0.35, 0.8), cf(1.42, 3.7, -0.5), GREY)
		end)

		-- upper beak: one chunky stepped orange beak
		B:block(head, v(1.2, 0.55, 0.8), cf(0, 4.0, -2.72), ORANGE)
		B:block(head, v(0.8, 0.45, 0.5), cf(0, 3.97, -3.35), ORANGE) -- stepped tip
		B:block(head, v(0.9, 0.08, 0.7), cf(0, 3.7, -2.7), BLACK) -- mouth roof (seen when open)
		local beakFX = B:block(head, v(0.8, 0.6, 0.6), cf(0, 3.7, -3.6), WHITE, { tr = 1, name = "BeakFX" })
		B:emitter(beakFX, "burst", { name = "CrowBurst", color = { "#ffffff", NEON }, size = { 0.5, 0.35, 0 }, speed = { 5, 10 } })
		B:emitter(beakFX, "spark", {
			name = "PeckSpark", rate = 0, color = { "#ffffff", NEON }, size = { 0.4, 0.2, 0 }, speed = { 4, 9 },
		})
		B:trail(head, v(0, 4.05, -3.55), v(0, 3.7, -3.55), { name = "BeakTrail", color = { "#ffffff", NEON }, life = 0.12, trans = { 0.55, 1 } })

		-- EYES: big white cartoon eyes on the front corners (own bones so they
		-- can pop out), ONE black pupil each on the front face only (own bones
		-- so they can dart around), heavy angry brows, hidden lids
		B:sym(function(side)
			local EY = 4.62
			local eye = B:bone("Eye" .. side, "Head", v(0.82, EY, -2.3))
			B:block(eye, v(1.15, 1.1, 0.9), cf(0.87, EY, -2.12), WHITE)
			B:block(eye, v(1.12, 1.24, 0.3), cf(0.78, EY, -2.35), GREY) -- eye rim (front)
			B:block(eye, v(0.15, 1.24, 1.04), cf(1.35, EY, -2.1), GREY) -- eye rim (side)
			local pupil = B:bone("Pupil" .. side, "Eye" .. side, v(0.7, EY - 0.05, -2.6))
			B:block(pupil, v(0.48, 0.7, 0.1), cf(0.7, EY - 0.05, -2.6), BLACK, { name = "PupilDisc" .. side })
			B:block(pupil, v(0.17, 0.17, 0.06), cf(0.82, EY + 0.17, -2.66), WHITE, { name = "Glint" .. side })
			B:block(pupil, v(0.22, 0.22, 0.1), cf(0.72, EY - 0.05, -2.6), BLACK, { tr = 1, name = "Dot" .. side })
			-- eyelid (+ dark lash) shown only while blinking / squeezing
			B:block(eye, v(1.2, 1.16, 1.16), cf(0.87, EY, -2.13), SHADE, { tr = 1, name = "Eyelid" .. side })
			B:block(eye, v(1.22, 0.14, 1.18), cf(0.87, EY - 0.5, -2.13), INK, { tr = 1, name = "Lash" .. side })
			-- heavy brow (inner end low = angry), its own bone for expressions
			local brow = B:bone("Brow" .. side, "Head", v(0.82, 5.24, -2.45))
			B:block(brow, v(1.2, 0.38, 0.55), cf(0.8, 5.27, -2.42, 0, 0, 18), INK)
		end)

		-- lower beak = the jaw, with the wattle hanging underneath
		local jaw = B:bone("Jaw", "Head", v(0, 3.72, -2.3))
		B:block(jaw, v(1.05, 0.38, 0.75), cf(0, 3.5, -2.72), DORANGE)
		B:block(jaw, v(0.65, 0.32, 0.4), cf(0, 3.53, -3.25), DORANGE) -- stepped tip
		B:block(jaw, v(0.8, 0.06, 0.6), cf(0, 3.71, -2.68), BLACK) -- mouth floor (seen when open)
		B:block(jaw, v(0.45, 0.06, 0.4), cf(0, 3.74, -2.62), TONGUE)
		B:block(jaw, v(0.85, 0.45, 0.12), cf(0, 3.75, -2.36), BLACK) -- throat wall
		-- neat red wattle hanging centred under the beak
		B:block(jaw, v(0.6, 0.5, 0.4), cf(0, 3.08, -2.68), RED)
		B:block(jaw, v(0.38, 0.3, 0.34), cf(0, 2.7, -2.68), DRED)

		-- comb: stepped red blocks rising from the forehead (own bone: jiggles)
		local comb = B:bone("Comb", "Head", v(0, 5.4, -1.6))
		B:block(comb, v(0.5, 0.3, 1.5), cf(0, 5.55, -1.55), DRED)
		B:block(comb, v(0.45, 0.45, 0.5), cf(0, 5.75, -2.05), RED)
		B:block(comb, v(0.45, 0.6, 0.5), cf(0, 5.88, -1.55), RED)
		B:block(comb, v(0.45, 0.4, 0.45), cf(0, 5.75, -1.1), RED)

		-- tin-bucket guard helmet, a size too small, cocked back on the crown,
		-- with a gold band, chin strap and a carrot-sprout "plume"
		local HC = CFrame.new(0, 5.36, -0.35) * ang(12, 0, -7)
		local helmet = B:bone("Helmet", "Head", HC)
		B:block(helmet, v(1.9, 0.2, 1.7), HC * CFrame.new(0, 0.05, 0), TIND) -- rim
		B:block(helmet, v(1.55, 0.45, 1.35), HC * CFrame.new(0, 0.37, 0), TIN) -- bucket
		B:block(helmet, v(1.6, 0.15, 1.4), HC * CFrame.new(0, 0.3, 0), GOLD) -- band
		B:block(helmet, v(1.15, 0.14, 0.95), HC * CFrame.new(0, 0.66, 0), TIND) -- top step
		B:block(helmet, v(0.5, 0.12, 0.4), HC * CFrame.new(0, 0.78, 0), TIN) -- handle knob
		B:block(helmet, v(0.3, 0.3, 0.1), HC * CFrame.new(0.35, 0.37, -0.69), TIND) -- dent
		-- carrot-sprout cockade tucked in the band (garden guard!)
		local CK = HC * CFrame.new(-0.82, 0.32, 0.1)
		B:block(helmet, v(0.3, 0.4, 0.3), CK, ORANGE)
		B:beam(helmet, (CK * CFrame.new(0, 0.15, 0)).Position, (CK * CFrame.new(-0.2, 0.45, 0)).Position, 0.18, 0.18, GREEN)
		B:beam(helmet, (CK * CFrame.new(0, 0.15, 0)).Position, (CK * CFrame.new(-0.45, 0.4, 0.05)).Position, 0.16, 0.16, DGREEN)
		B:beam(helmet, (CK * CFrame.new(0, 0.15, 0)).Position, (CK * CFrame.new(0.1, 0.42, 0.2)).Position, 0.16, 0.16, GREEN)
		local steam = B:block(helmet, v(1.0, 0.4, 1.0), HC * CFrame.new(0, 0.8, 0), WHITE, { tr = 1, name = "SteamFX" })
		B:emitter(steam, "smoke", {
			name = "SteamPuff", rate = 0, color = { "#ffffff", "#e8e8e8" }, size = { 0.4, 1.0, 1.4 },
			speed = { 2, 4 }, life = { 0.6, 1.1 }, spread = 25, trans = { 0.3, 0.5, 1 },
		})

		-- expression props (all hidden at rest, shown by the states)
		-- "!" above the head (Alert)
		B:block(head, v(0.35, 0.8, 0.35), cf(1.55, 6.5, -1.6, 0, 0, -12), RED, { tr = 1, name = "Exclaim1" })
		B:block(head, v(0.35, 0.32, 0.35), cf(1.43, 5.85, -1.6, 0, 0, -12), RED, { tr = 1, name = "Exclaim2" })
		-- anger mark (4 bent brackets) on the front-left of the head
		local AM = CFrame.new(-1.5, 5.75, -2.2)
		for k = 0, 3 do
			local r = CFrame.new(AM.Position) * ang(0, 0, 45 + k * 90)
			B:block(head, v(0.32, 0.11, 0.1), r * CFrame.new(0.18, 0.1, 0), RED, { tr = 1, name = "Anger" .. (2 * k + 1) })
			B:block(head, v(0.11, 0.32, 0.1), r * CFrame.new(0.1, 0.18, 0), RED, { tr = 1, name = "Anger" .. (2 * k + 2) })
		end
		-- sweat drop on the right temple (GiveUp)
		B:block(head, v(0.3, 0.42, 0.25), cf(1.52, 4.95, -1.75), SWEAT, { tr = 1, name = "Sweat1" })
		B:block(head, v(0.2, 0.2, 0.2), cf(1.52, 5.24, -1.75, 0, 0, 45), SWEAT, { tr = 1, name = "Sweat2" })

		------------------------------------------------------------------
		-- LEGS: white feathered "pants", orange shins, chunky 4-toed feet
		------------------------------------------------------------------
		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Body", v(0.75, 1.9, 0.2))
			B:block(thigh, v(1.1, 0.8, 1.2), cf(0.8, 1.75, 0.3), WHITE)
			B:block(thigh, v(1.0, 0.2, 1.1), cf(0.8, 1.35, 0.32), SHADE)
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(0.75, 1.15, 0.5))
			B:beam(shin, v(0.75, 1.3, 0.52), v(0.75, 0.3, 0.2), 0.45, 0.45, ORANGE)
			B:block(shin, v(0.52, 0.14, 0.52), cf(0.75, 0.8, 0.38), DORANGE) -- scale band
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(0.75, 0.3, 0.2))
			B:block(foot, v(0.62, 0.36, 0.62), cf(0.75, 0.24, 0.2), DORANGE)
			local from = v(0.75, 0.15, 0.15)
			local toes = { v(0.75, 0.15, -0.8), v(1.28, 0.15, -0.5), v(0.24, 0.15, -0.5), v(0.75, 0.15, 0.78) }
			for _, tp in toes do
				B:beam(foot, from, tp, 0.38, 0.3, ORANGE)
				local dir = (tp - from).Unit
				B:block(foot, v(0.22, 0.2, 0.22), CFrame.lookAt(tp + dir * 0.08, tp + dir) * CFrame.new(0, -0.04, 0), WHITE)
			end
			B:trail(foot, v(0.75, 0.3, -0.75), v(0.75, 0.05, -0.75), { name = "FootTrail" .. side, color = { "#ffffff", NEON }, life = 0.12, trans = { 0.55, 1 } })
		end)
		local dustAt = B:block("Root", v(3, 0.2, 2.6), cf(0, 0.1, 0.2), WHITE, { tr = 1, name = "DustFX" })
		B:emitter(dustAt, "dust", {
			name = "StepDust", color = { "#efe3c8", "#c9b48e" }, size = { 0.6, 1.2, 1.6 }, speed = { 3, 6 },
			life = { 0.4, 0.8 }, trans = { 0.3, 0.5, 1 }, spread = 80,
		})
		B:emitter(dustAt, "leaf", {
			name = "LeafKick", rate = 0, color = { GREEN, DGREEN, DIRT }, size = { 0.3, 0.3, 0.2 },
			speed = { 4, 8 }, spread = 50, life = { 0.8, 1.4 }, accel = { 0, -12, 0 }, drag = 1,
		})

		------------------------------------------------------------------
		-- Floating garden voxel cubes (tiny grass blocks + a golden seed)
		------------------------------------------------------------------
		local spots = { { 2.9, 5.0, 1.2 }, { -3.1, 3.6, 1.6 }, { 2.8, 1.4, 2.8 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Root", v(p[1], p[2], p[3]))
			if i == 3 then
				B:block(ob, v(0.55, 0.55, 0.55), cf(p[1], p[2], p[3]), GOLD)
				B:block(ob, v(0.6, 0.15, 0.6), cf(p[1], p[2], p[3]), GOLDD)
				B:gem(ob, v(0.22, 0.22, 0.22), cf(p[1], p[2] + 0.35, p[3]), NEON, { name = "OrbGem" })
			else
				local s = i == 1 and 0.75 or 0.65
				B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), DIRT)
				B:block(ob, v(s + 0.06, s * 0.3, s + 0.06), cf(p[1], p[2] + s * 0.36, p[3]), GREEN)
				B:block(ob, v(0.12, 0.3, 0.12), cf(p[1] + 0.12, p[2] + s * 0.5 + 0.15, p[3]), DGREEN) -- sprout
			end
		end
	end,
}
