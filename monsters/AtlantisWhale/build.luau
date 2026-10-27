--!nocheck
-- Atlantis Sky Whale: the Divine showpiece of the Atlantis pack.
-- A colossal, gentle, motherly blue whale that hovers through the air carrying
-- the lost city of Atlantis on her back. Stud-built: ocean-blue body with a
-- darker back and lighter stepped spots, a cream pleated (grooved) throat and
-- belly, long humpback flippers with orichalcum gold bands, big stepped flukes.
-- A kind cartoon face: big soft sky-glow eyes with huge pupils and glints,
-- gently raised brows, a warm upturned smile with pink blush, baleen inside.
-- On her back: a stepped marble ziggurat with concentric marble / gold ring
-- walls and water moats, a gold-domed temple with columns, a tall turquoise
-- orichalcum crystal spire (small neon tip), four little towers that rise out
-- of the walls, a gate arch, broken columns, coral & seaweed, and waterfalls
-- spilling off both sides. Hidden VFX: a beam of light + halo of rays on the
-- spire, gold voxel chunks, closed "content" eyes.
return {
	DisplayName = "Atlantis Sky Whale",
	Rarity = "Divine",
	Element = "Atlantis",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette
		local MAIN, DARK, SPOT = "#2a5fa8", "#183c75", "#6fa8dc"
		local CREAM, GROOVE = "#f3e6c4", "#d6c095"
		local MARBLE, MARBLE2 = "#f4f1ea", "#d9d4c8"
		local GOLD, DGOLD = "#f0bf3c", "#b8862a"
		local TURQ, TURQL, TEAL = "#2ec4b6", "#7fe9df", "#1f8f8a"
		local WATER, FOAM = "#4fb6f0", "#e8fbff"
		local CORAL, CORAL2, WEED = "#ff6f91", "#ff9a4a", "#3fae5a"
		local EYEW, PUPIL, MOUTH, TONGUE, BLUSH = "#fdfaf0", "#10182a", "#1a1030", "#ff8fa8", "#ff9fb4"
		local NT, NS, NG = "#3ff0e0", "#6fe3ff", "#ffe27a" -- neon turquoise / sky / gold
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- BODY (the big back that carries the city)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 8.5, -1))
		B:block(body, v(11, 6.4, 13), cf(0, 8.2, -1), MAIN)
		B:block(body, v(9, 8.6, 12.6), cf(0, 8.2, -1), MAIN)
		B:block(body, v(11.1, 1.6, 12.6), cf(0, 10.7, -1), DARK)
		B:block(body, v(9.1, 1.2, 12.2), cf(0, 11.95, -1), DARK)
		B:block(body, v(7.6, 0.8, 11.6), cf(0, 12.85, -1), DARK)
		B:block(body, v(11.1, 1.4, 12.4), cf(0, 5.6, -1), CREAM)
		B:block(body, v(11.2, 0.25, 12.0), cf(0, 5.3, -1), GROOVE)
		B:block(body, v(11.2, 0.25, 10.6), cf(0, 5.95, -1.5), GROOVE)
		B:block(body, v(9.1, 1.2, 12.2), cf(0, 4.45, -1), CREAM)
		-- stepped light spots (one block shows on both sides)
		local spots = {
			{ -4.6, 8.0, 1.8 }, { -4.2, 8.8, 0.9 },
			{ 0.6, 7.2, 1.6 }, { 1.0, 8.0, 0.8 },
			{ 3.6, 9.4, 1.8 }, { 3.2, 8.6, 0.9 },
			{ -1.6, 10.6, 1.4 }, { 2.4, 10.7, 1.0 },
		}
		for _, s in spots do
			B:block(body, v(11.16, 0.8, s[3]), cf(0, s[2], s[1]), SPOT)
		end
		-- top spots on the dark back
		B:block(body, v(9.16, 0.4, 1.2), cf(0, 12.0, 3.9), SPOT)
		-- barnacles + a little coral clinging to the flanks
		B:sym(function()
			B:block(body, v(0.5, 0.5, 0.5), cf(5.65, 7.2, 3.4), MARBLE2)
			B:block(body, v(0.4, 0.4, 0.4), cf(5.6, 6.7, 2.8), MARBLE)
			B:block(body, v(0.4, 0.8, 0.4), cf(5.65, 9.0, -6.2), CORAL)
		end)
		local bodyFx = B:block(body, v(13, 9, 30), cf(0, 10, 1), MAIN, { tr = 1, name = "BodyFX" })
		B:emitter(bodyFx, "bubble", { name = "AmbientBubbles", color = { "#ffffff", "#9fe2ff" }, rate = 4, size = { 0.25, 0.5, 0.6 } })

		-- swelling belly (deep breath): pleated cream plates
		local belly = B:bone("Belly", "Body", v(0, 4.0, -1))
		B:block(belly, v(7.4, 0.8, 11), cf(0, 3.55, -1), CREAM)
		B:block(belly, v(5, 0.5, 8.5), cf(0, 2.95, -1.2), CREAM)
		for _, x in { -3.0, 3.0 } do
			B:block(belly, v(0.35, 0.2, 10.4), cf(x, 3.1, -1), GROOVE)
		end
		for _, x in { -1.6, 0, 1.6 } do
			B:block(belly, v(0.35, 0.2, 8.0), cf(x, 2.65, -1.2), GROOVE)
		end

		------------------------------------------------------------------
		-- HEAD: big blunt cartoon whale head, face on the front corners
		------------------------------------------------------------------
		local head = B:bone("Head", "Body", v(0, 8.5, -7.5))
		B:block(head, v(10, 4.5, 8.8), cf(0, 9.75, -11.8), MAIN) -- skull
		B:block(head, v(8.4, 0.9, 8.2), cf(0, 12.4, -11.6), DARK) -- crown steps
		B:block(head, v(6.4, 0.6, 7.2), cf(0, 13.1, -11.2), DARK)
		B:block(head, v(9.2, 2.1, 2.4), cf(0, 8.55, -17.3), MAIN) -- muzzle
		B:block(head, v(8.0, 0.5, 2.0), cf(0, 9.85, -17.1), MAIN)
		B:block(head, v(3.0, 0.3, 2.2), cf(0, 13.45, -11.6), SPOT)
		B:block(head, v(1.4, 0.3, 1.2), cf(2.6, 12.9, -8.4), SPOT)
		B:block(head, v(1.6, 0.3, 1.0), cf(-2.2, 12.9, -14.2), SPOT)
		B:block(head, v(2.2, 0.3, 0.8), cf(0, 10.15, -17.0), SPOT)
		-- forehead orichalcum circlet: gold plate + turquoise gem
		B:block(head, v(4.0, 0.35, 0.3), cf(0, 12.15, -15.85), GOLD) -- tiara
		B:block(head, v(0.6, 0.75, 0.25), cf(0, 12.55, -15.95), NT, NEON)
		B:block(head, v(0.4, 0.5, 0.25), cf(0.75, 12.45, -15.9), GOLD)
		B:block(head, v(0.4, 0.5, 0.25), cf(-0.75, 12.45, -15.9), GOLD)
		-- big warm smile drawn across the muzzle front
		B:block(head, v(5.6, 0.4, 0.15), cf(0, 7.95, -18.55), MOUTH)
		-- blowholes (the hum bubbles come out here)
		B:block(head, v(0.5, 0.2, 0.9), cf(0.45, 13.45, -9.0), MOUTH)
		B:block(head, v(0.5, 0.2, 0.9), cf(-0.45, 13.45, -9.0), MOUTH)
		-- the smile line wraps around the front
		B:block(head, v(10.1, 0.4, 8.6), cf(0, 7.65, -11.9), DARK)
		B:block(head, v(9.3, 0.4, 2.5), cf(0, 7.65, -17.3), DARK)
		B:block(head, v(9, 0.3, 10.4), cf(0, 7.4, -12.9), MOUTH) -- palate
		B:block(head, v(7.6, 0.9, 0.4), cf(0, 7.0, -17.7), CREAM) -- front baleen
		local blowFx = B:block(head, v(1.2, 0.6, 1.0), cf(0, 13.7, -9.0), MAIN, { tr = 1, name = "BlowFX" })
		B:emitter(blowFx, "bubble", { name = "HumBubbles", color = { "#ffffff", NS }, rate = 10, enabled = false, speed = { 2, 4 }, size = { 0.3, 0.55, 0.7 }, spread = 25 })

		B:sym(function(side)
			-- smile corners turn UP (warm smile) + blush
			B:block(head, v(0.3, 0.45, 0.9), cf(5.05, 8.05, -8.4), DARK)
			B:block(head, v(0.3, 0.45, 0.7), cf(5.05, 8.45, -7.8), DARK)
			B:block(head, v(0.7, 0.4, 0.15), cf(3.05, 8.25, -18.55), MOUTH)
			B:block(head, v(0.5, 0.45, 0.15), cf(3.55, 8.6, -18.55), MOUTH)
			B:block(head, v(0.2, 0.7, 1.4), cf(5.05, 8.7, -13.6), BLUSH)
			B:block(head, v(0.9, 0.5, 0.15), cf(3.6, 9.25, -18.55), BLUSH)
			B:block(head, v(0.4, 0.9, 8.5), cf(4.1, 7.0, -12.6), CREAM) -- baleen
			-- big soft eye wrapping the front-side corner (reads from front AND side)
			B:block(head, v(2.3, 2.7, 2.6), cf(4.2, 10.75, -15.2), EYEW)
			B:block(head, v(1.7, 2.2, 0.2), cf(4.25, 10.7, -16.55), NS, NEON)
			B:block(head, v(0.2, 2.2, 1.9), cf(5.4, 10.7, -15.2), NS, NEON)
			local pupil = B:bone("Pupil" .. side, "Head", v(4.6, 10.55, -16.0))
			B:block(pupil, v(1.15, 1.9, 0.2), cf(4.1, 10.55, -16.7), PUPIL)
			B:block(pupil, v(0.2, 1.9, 1.15), cf(5.5, 10.55, -15.55), PUPIL)
			B:block(head, v(0.45, 0.45, 0.1), cf(4.45, 11.2, -16.85), "#ffffff", NEON)
			B:block(head, v(0.1, 0.45, 0.45), cf(5.65, 11.2, -15.85), "#ffffff", NEON)
			-- gentle raised brow (inner end lifted = kind) + soft lower lid
			B:block(head, v(2.4, 0.45, 2.8), cf(4.2, 12.45, -15.25, 0, 0, -10), DARK)
			B:block(head, v(1.9, 0.35, 0.3), cf(4.2, 9.4, -16.6), SPOT)
			B:block(head, v(0.3, 0.35, 2.0), cf(5.38, 9.4, -15.2), SPOT)
			-- hidden lids: blink (flat lash) / content closed happy eyes (arc)
			B:block(head, v(2.7, 3.0, 3.1), cf(4.4, 10.75, -15.55), MAIN, { tr = 1, name = "Lid" .. side })
			B:block(head, v(1.9, 0.3, 0.15), cf(4.3, 10.5, -17.15), PUPIL, { tr = 1, name = "Lash" .. side })
			B:block(head, v(0.15, 0.3, 2.2), cf(5.8, 10.5, -15.4), PUPIL, { tr = 1, name = "LashS" .. side })
			B:block(head, v(0.9, 0.3, 0.15), cf(4.3, 11.0, -17.15), PUPIL, { tr = 1, name = "Happy" .. side .. "1" })
			B:block(head, v(0.75, 0.3, 0.15), cf(4.95, 10.7, -17.15, 0, 0, -35), PUPIL, { tr = 1, name = "Happy" .. side .. "2" })
			B:block(head, v(0.75, 0.3, 0.15), cf(3.65, 10.7, -17.15, 0, 0, 35), PUPIL, { tr = 1, name = "Happy" .. side .. "3" })
			B:block(head, v(0.15, 0.3, 1.6), cf(5.8, 10.95, -15.4), PUPIL, { tr = 1, name = "Happy" .. side .. "4" })
		end)

		------------------------------------------------------------------
		-- JAW: cream pleated throat, tongue (opens for hums and the song)
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", v(0, 7.5, -7.8))
		B:block(jaw, v(9.6, 1.4, 10.0), cf(0, 6.8, -12.7), MAIN)
		B:block(jaw, v(8.0, 1.4, 0.8), cf(0, 6.8, -17.9), MAIN) -- stepped chin
		B:block(jaw, v(8.4, 0.2, 9.8), cf(0, 7.45, -13.2), MOUTH)
		B:block(jaw, v(4, 0.3, 5), cf(0, 7.5, -12.2), TONGUE)
		B:block(jaw, v(9.0, 1.6, 9.4), cf(0, 5.4, -12.4), CREAM)
		B:block(jaw, v(7.4, 1.4, 0.8), cf(0, 5.5, -17.4), CREAM)
		B:block(jaw, v(7, 0.7, 7.6), cf(0, 4.35, -11.9), CREAM)
		B:block(jaw, v(9.15, 0.25, 9.6), cf(0, 5.55, -12.7), GROOVE)
		B:block(jaw, v(9.1, 0.25, 9.0), cf(0, 4.95, -12.3), GROOVE)
		for _, x in { -2.4, -0.8, 0.8, 2.4 } do
			B:block(jaw, v(0.35, 0.2, 7.0), cf(x, 3.95, -11.9), GROOVE)
		end

		------------------------------------------------------------------
		-- FLIPPERS: long humpback flippers, 2 bones each, gold bands
		------------------------------------------------------------------
		B:sym(function(side)
			local F = CFrame.new(5.2, 7.0, -4.5) * ang(0, -32, -22)
			local function at(x, y, z)
				return F * CFrame.new(x, y, z)
			end
			local arm = B:bone("Fin" .. side, "Body", F)
			B:block(arm, v(3.8, 1.3, 2.6), at(1.4, 0, 0), MAIN)
			B:block(arm, v(3.4, 0.3, 2.3), at(1.6, -0.6, 0.1), CREAM)
			B:block(arm, v(0.7, 1.55, 2.85), at(3.0, 0, 0), GOLD)
			local tip = B:bone("FinTip" .. side, "Fin" .. side, at(3.3, 0, 0))
			B:block(tip, v(3.6, 1.1, 2.4), at(5.0, 0, 0.3), MAIN)
			B:block(tip, v(2.8, 0.9, 1.9), at(8.0, 0, 0.8), MAIN)
			B:block(tip, v(1.6, 0.8, 1.3), at(10.0, 0, 1.3), DARK)
			B:block(tip, v(3.4, 1.0, 0.5), at(5.0, 0, -1.1), CREAM)
			B:block(tip, v(2.6, 0.85, 0.5), at(8.0, 0, -0.35), CREAM)
			B:block(tip, v(0.6, 1.3, 2.6), at(6.7, 0, 0.5), GOLD)
			B:block(tip, v(0.25, 0.2, 1.6), at(6.7, 0.7, 0.5), NT, NEON)
			B:block(tip, v(1.2, 0.2, 0.9), at(8.2, 0.5, 0.8), SPOT)
			B:block(tip, v(0.5, 0.45, 0.6), at(10.9, 0, 1.5), NT, NEON)
			local a, b = at(10.8, 0, 1.6), at(9.4, 0, 1.9)
			B:trail(tip, a.Position, b.Position, { name = "FinTrail" .. side, color = { "#ffffff", NT }, life = 0.35, trans = { 0.5, 1 } })
		end)

		------------------------------------------------------------------
		-- TAIL chain + flukes
		------------------------------------------------------------------
		local t1 = B:bone("Tail1", "Body", v(0, 8.6, 5.0))
		B:block(t1, v(9, 6.4, 5.8), cf(0, 8.6, 7.7), MAIN)
		B:block(t1, v(9.1, 1.8, 5.6), cf(0, 10.95, 7.7), DARK)
		B:block(t1, v(6.5, 0.8, 5.2), cf(0, 12.1, 7.6), DARK)
		B:block(t1, v(9.1, 1.4, 5.6), cf(0, 6.1, 7.7), CREAM)
		B:block(t1, v(9.2, 0.25, 5.2), cf(0, 6.0, 7.7), GROOVE)
		B:block(t1, v(7.5, 0.8, 5.2), cf(0, 5.1, 7.6), CREAM)
		B:block(t1, v(9.16, 0.8, 1.4), cf(0, 9.0, 7.0), SPOT)
		B:block(t1, v(9.16, 0.8, 0.7), cf(0, 9.8, 7.35), SPOT)
		B:block(t1, v(1.2, 0.8, 2.4), cf(0, 12.8, 8.6), DARK) -- little dorsal
		B:block(t1, v(1.0, 0.7, 1.3), cf(0, 13.5, 9.2), DARK)
		B:block(t1, v(0.6, 0.6, 0.6), cf(0, 14.05, 9.6), NT, NEON)

		local t2 = B:bone("Tail2", "Tail1", v(0, 8.8, 10.2))
		B:block(t2, v(6.8, 4.8, 4.6), cf(0, 8.9, 12.2), MAIN)
		B:block(t2, v(6.9, 1.4, 4.4), cf(0, 10.6, 12.2), DARK)
		B:block(t2, v(3.5, 0.7, 4.0), cf(0, 11.6, 12.1), DARK)
		B:block(t2, v(6.9, 1.2, 4.4), cf(0, 7.1, 12.2), CREAM)
		B:block(t2, v(5, 0.6, 4.0), cf(0, 6.25, 12.1), CREAM)
		B:block(t2, v(6.96, 0.7, 1.2), cf(0, 9.3, 11.8), SPOT)
		B:block(t2, v(0.8, 0.6, 0.8), cf(0, 12.2, 11.2), DARK)
		B:block(t2, v(0.8, 0.6, 0.8), cf(0, 12.1, 13.0), DARK)

		local t3 = B:bone("Tail3", "Tail2", v(0, 9.0, 14.0))
		B:block(t3, v(4.0, 3.4, 3.6), cf(0, 9.0, 15.6), MAIN)
		B:block(t3, v(4.1, 1.0, 3.4), cf(0, 10.3, 15.6), DARK)
		B:block(t3, v(3.0, 0.6, 3.2), cf(0, 7.2, 15.6), CREAM)
		B:block(t3, v(0.7, 0.6, 0.8), cf(0, 11.0, 15.2), DARK)
		B:block(t3, v(4.3, 3.7, 0.5), cf(0, 9.0, 16.7), GOLD) -- orichalcum tail band
		B:block(t3, v(4.36, 0.25, 0.3), cf(0, 9.0, 16.7), NT, NEON)

		local FZ = 17.0
		local fluke = B:bone("Fluke", "Tail3", v(0, 9.0, FZ))
		B:block(fluke, v(3.6, 1.4, 3.0), cf(0, 9.0, 18.0), MAIN)
		B:block(fluke, v(2.0, 0.3, 2.0), cf(0, 9.8, 18.0), DARK)
		B:sym(function(side)
			local lobes = {
				{ 2.8, 18.4, 2.4, 3.2, 1.2, MAIN },
				{ 4.8, 19.0, 2.0, 3.0, 1.1, MAIN },
				{ 6.6, 19.7, 2.0, 2.6, 1.0, DARK },
				{ 8.3, 20.5, 1.6, 2.0, 0.9, DARK },
				{ 9.6, 21.3, 1.2, 1.4, 0.8, DARK },
			}
			for _, l in lobes do
				B:block(fluke, v(l[3], l[5], l[4]), cf(l[1], 9.0, l[2]), l[6])
			end
			B:block(fluke, v(4.2, 0.3, 2.6), cf(3.8, 8.35, 18.8), CREAM)
			B:block(fluke, v(1.6, 0.25, 1.4), cf(4.4, 9.62, 19.0), SPOT)
			B:block(fluke, v(0.5, 0.5, 0.6), cf(10.2, 9.0, 22.0), NT, NEON)
			B:trail(fluke, v(10.2, 9.0, 22.2), v(8.6, 9.0, 21.6), { name = "FlukeTrail" .. side, color = { "#ffffff", NS }, life = 0.4, trans = { 0.45, 1 } })
		end)
		-- splash crown flashed on the slap (hidden)
		for i = 1, 6 do
			local a = (i - 1) * 60 + 30
			B:block(fluke, v(0.4, 0.4, 2.4), CFrame.new(0, 9.0, 19.8) * ang(0, a, 0) * CFrame.new(0, 0, -6.5) * ang(-30, 0, 0), FOAM, { mat = "Neon", tr = 1, name = "SplashLine" .. i })
		end
		local flukeFx = B:block(fluke, v(14, 1.5, 4), cf(0, 9.0, 19.5), MAIN, { tr = 1, name = "FlukeFX" })
		B:emitter(flukeFx, "burst", { name = "SlapBurst", color = { "#ffffff", NS, "#9fe2ff" }, size = { 1.0, 0.7, 0 }, speed = { 8, 18 }, life = { 0.5, 1.1 } })

		------------------------------------------------------------------
		-- THE LOST CITY on her back
		------------------------------------------------------------------
		local city = B:bone("City", "Body", v(0, 13.2, -1))
		B:block(city, v(9.0, 0.6, 11.6), cf(0, 13.45, -1), MARBLE)
		B:block(city, v(9.2, 0.3, 11.8), cf(0, 13.3, -1), GOLD)
		B:block(city, v(9.06, 0.15, 9.4), cf(0, 13.55, -1), NT, NEON) -- rune strips
		B:block(city, v(7.6, 0.5, 9.6), cf(0, 14.0, -1), MARBLE2)
		B:block(city, v(7.0, 0.2, 7.0), cf(0, 14.3, -1), WATER) -- moat water
		-- concentric rings: marble outer wall with gold crenels, gold inner wall
		local C = CFrame.new(0, 14.75, -1)
		B:ring(city, C, 3.5, 12, v(1.85, 1.0, 0.7), MARBLE)
		B:ring(city, CFrame.new(0, 15.45, -1) * ang(0, 15, 0), 3.5, 6, v(0.8, 0.45, 0.8), GOLD)
		B:ring(city, CFrame.new(0, 14.7, -1) * ang(0, 22.5, 0), 2.2, 8, v(1.6, 0.8, 0.5), GOLD)
		-- central temple
		B:block(city, v(3.0, 0.5, 3.0), cf(0, 14.5, -1), MARBLE)
		B:ring(city, CFrame.new(0, 15.85, -1) * ang(0, 45, 0), 1.15, 8, v(0.5, 2.2, 0.5), MARBLE)
		local core = B:block(city, v(0.8, 1.2, 0.8), cf(0, 15.6, -1, 0, 45, 0), NT, { mat = "Neon", name = "TempleCore" })
		B:light(core, { name = "TempleLight", color = NG, brightness = 0.6, range = 9 })
		B:block(city, v(3.2, 0.45, 3.2), cf(0, 17.18, -1), GOLD)
		B:block(city, v(2.8, 0.4, 2.8), cf(0, 17.6, -1), MARBLE)
		B:block(city, v(2.4, 0.6, 2.4), cf(0, 18.1, -1), GOLD)
		B:block(city, v(1.8, 0.6, 1.8), cf(0, 18.7, -1), GOLD)
		B:block(city, v(1.1, 0.5, 1.1), cf(0, 19.25, -1), DGOLD)
		-- front gate arch
		B:block(city, v(0.7, 2.4, 0.7), cf(1.3, 14.95, -5.9), MARBLE)
		B:block(city, v(0.7, 2.4, 0.7), cf(-1.3, 14.95, -5.9), MARBLE)
		B:block(city, v(3.4, 0.6, 0.9), cf(0, 16.4, -5.9), GOLD)
		B:block(city, v(0.6, 0.3, 0.1), cf(0, 16.4, -6.4), NT, NEON)
		-- back ruins: broken columns + fallen drum
		B:block(city, v(0.6, 1.6, 0.6), cf(1.6, 14.6, 4.0), MARBLE)
		B:block(city, v(0.6, 1.0, 0.6), cf(-1.4, 14.3, 4.1, 0, 0, 8), MARBLE2)
		B:block(city, v(1.6, 0.5, 0.5), cf(0.1, 14.05, 4.4, 0, 20, 0), MARBLE2)
		-- coral tufts
		local function coral(x, z, col, col2)
			B:block(city, v(0.5, 1.2, 0.5), cf(x, 14.3, z), col)
			B:block(city, v(0.4, 0.8, 0.4), cf(x + 0.45, 14.6, z, 0, 0, -25), col)
			B:block(city, v(0.4, 0.4, 0.4), cf(x - 0.3, 14.95, z + 0.2), col2)
		end
		coral(3.4, 4.0, CORAL, CORAL2)
		coral(-3.6, -5.9, CORAL2, CORAL)
		coral(-3.7, 3.4, CORAL, NG)
		-- seaweed (sways)
		local weeds = { { 3.7, -5.9 }, { -3.2, 4.4 }, { 3.9, 1.6 } }
		for i, w in weeds do
			local wb = B:bone("Weed" .. i, "City", v(w[1], 13.8, w[2]))
			B:block(wb, v(0.5, 1.0, 0.5), cf(w[1], 14.3, w[2]), WEED)
			B:block(wb, v(0.45, 1.0, 0.45), cf(w[1] + 0.2, 15.2, w[2]), WEED)
			B:block(wb, v(0.4, 0.9, 0.4), cf(w[1], 16.05, w[2]), "#5fd17a")
		end
		-- waterfalls spilling off both sides
		local fi = 0
		B:sym(function(side)
			for _, z in { -3.4, 2.0 } do
				fi += 1
				B:block(city, v(1.4, 0.3, 1.6), cf(5.1, 13.95, z), WATER)
				B:block(city, v(0.35, 4.6, 1.4), cf(5.78, 11.6, z), WATER, { tr = 0.3, name = "Fall" .. fi })
				B:block(city, v(0.38, 3.0, 0.3), cf(5.82, 11.4, z + 0.3), FOAM, { tr = 0.3, name = "FallStreak" .. fi })
				B:block(city, v(0.6, 0.4, 1.8), cf(5.85, 9.35, z), FOAM)
			end
		end)
		local fallFx = B:block(city, v(12.4, 0.6, 7), cf(0, 9.4, -0.7), MAIN, { tr = 1, name = "FallFX" })
		B:emitter(fallFx, "drip", { name = "FallDrips", color = { FOAM, WATER }, rate = 6 })
		local cityFx = B:block(city, v(9, 5, 11), cf(0, 17, -1), MAIN, { tr = 1, name = "CityFX" })
		B:emitter(cityFx, "sparkle", { name = "CitySparkle", color = { "#ffffff", NG, NT }, rate = 4 })
		B:emitter(cityFx, "burst", { name = "GoldBurst", color = { "#ffffff", NG, GOLD }, size = { 0.8, 0.5, 0 }, speed = { 6, 14 } })

		-- four little towers that RISE out of the ring wall
		local towers = { { 2.5, -3.5 }, { -2.5, -3.5 }, { 2.5, 1.5 }, { -2.5, 1.5 } }
		for i, tp in towers do
			local x, z = tp[1], tp[2]
			local tw = B:bone("Tower" .. i, "City", v(x, 14.5, z))
			B:block(tw, v(1.2, 5.6, 1.2), cf(x, 14.3, z), MARBLE)
			B:block(tw, v(1.35, 0.35, 1.35), cf(x, 16.4, z), GOLD)
			B:block(tw, v(1.26, 0.4, 0.4), cf(x, 15.8, z), NS, NEON)
			B:block(tw, v(1.6, 0.4, 1.6), cf(x, 17.3, z), GOLD)
			B:block(tw, v(1.1, 0.6, 1.1), cf(x, 17.8, z), TEAL)
			B:block(tw, v(0.6, 0.6, 0.6), cf(x, 18.4, z), TURQ)
			B:block(tw, v(0.3, 0.4, 0.3), cf(x, 18.9, z), NG, NEON)
		end

		-- the orichalcum crystal spire on the dome
		local spire = B:bone("Spire", "City", v(0, 19.5, -1))
		B:block(spire, v(1.3, 0.4, 1.3), cf(0, 19.65, -1), GOLD)
		B:block(spire, v(1.1, 3.0, 1.1), cf(0, 21.3, -1, 0, 45, 0), TURQ)
		B:block(spire, v(0.75, 2.0, 0.75), cf(0, 23.6, -1, 0, 45, 0), TURQL)
		B:block(spire, v(0.5, 1.0, 0.5), cf(0, 25.0, -1, 0, 45, 0), NT, NEON)
		B:beam(spire, v(0.3, 20.0, -1), v(1.3, 21.4, -1), 0.45, 0.45, TURQL)
		B:beam(spire, v(-0.3, 20.2, -1), v(-1.1, 21.2, -0.6), 0.4, 0.4, TURQ)
		local tipFx = B:block(spire, v(1, 1, 1), cf(0, 25.0, -1), MAIN, { tr = 1, name = "TipFX" })
		B:emitter(tipFx, "sparkle", { name = "SpireCharge", color = { "#ffffff", NT, NS }, rate = 40, enabled = false, speed = { 2, 5 }, size = { 0.2, 0.6, 0 } })
		B:emitter(tipFx, "burst", { name = "BeamBurst", color = { "#ffffff", NS, NG }, size = { 1.0, 0.6, 0 }, speed = { 10, 20 } })
		B:light(tipFx, { name = "SpireLight", color = NT, brightness = 0.4, range = 14 })
		-- hidden beam of light shooting up from the tip
		B:block(spire, v(0.8, 16, 0.8), cf(0, 33.5, -1), "#d8fbff", { mat = "Neon", tr = 1, name = "BeamCore" })
		B:block(spire, v(1.8, 16, 1.8), cf(0, 33.5, -1), NS, { mat = "Neon", tr = 1, name = "BeamGlow" })
		-- halo of rays around the tip (spins)
		local halo = B:bone("Halo", "Spire", v(0, 24.9, -1))
		for i = 1, 10 do
			local a = i * 36
			local len = (i % 2 == 0) and 2.8 or 4.2
			B:block(halo, v(0.3, 0.3, len), CFrame.new(0, 24.9, -1) * ang(0, a, 0) * CFrame.new(0, 0, -1.0 - len / 2) * ang(25, 0, 0), (i % 2 == 0) and NT or NG, { mat = "Neon", tr = 1, name = "Ray" .. i })
		end

		-- gold voxel chunks that pop out when the towers rise (hidden)
		local chunkCol = { GOLD, MARBLE, GOLD, NT, MARBLE, GOLD }
		for k = 1, 6 do
			local cb = B:bone("Chunk" .. k, "City", v(0, 16.5, -1))
			B:block(cb, v(0.7, 0.7, 0.7), cf(0, 16.5, -1), chunkCol[k], { mat = chunkCol[k] == NT and "Neon" or nil, tr = 1, name = "ChunkPart" .. k })
		end

		------------------------------------------------------------------
		-- Floating marble / gold / crystal cubes orbiting her
		------------------------------------------------------------------
		local orbs = {
			{ 11.5, 15.5, -10, 1.8, "marble" },
			{ -12, 12.5, -5, 1.6, "gold" },
			{ 11, 10, 7, 1.4, "crystal" },
			{ -10.5, 19, 7, 1.8, "marble" },
			{ 6.5, 22, 11, 1.2, "gold" },
			{ -7, 22.5, -12, 1.4, "crystal" },
		}
		for i, o in orbs do
			local p = v(o[1], o[2], o[3])
			local ob = B:bone("Orb" .. i, "Root", p)
			local s = o[4]
			if o[5] == "marble" then
				B:block(ob, v(s, s, s), CFrame.new(p), MARBLE)
				B:block(ob, v(s + 0.12, s * 0.22, s + 0.12), CFrame.new(p) * CFrame.new(0, s * 0.2, 0), GOLD)
				B:block(ob, v(s * 0.3, s * 0.3, s + 0.16), CFrame.new(p) * CFrame.new(0, -s * 0.15, 0), NT, NEON)
			elseif o[5] == "gold" then
				B:block(ob, v(s, s, s), CFrame.new(p), GOLD)
				B:block(ob, v(s + 0.12, s * 0.2, s + 0.12), CFrame.new(p), NT, NEON)
				B:block(ob, v(s * 0.5, s * 0.3, s * 0.5), CFrame.new(p) * CFrame.new(0, s * 0.62, 0), DGOLD)
			else
				B:block(ob, v(s * 0.8, s * 1.4, s * 0.8), CFrame.new(p) * ang(0, 45, 0), TURQ)
				B:block(ob, v(s * 0.5, s * 0.6, s * 0.5), CFrame.new(p) * CFrame.new(0, s * 0.95, 0) * ang(0, 45, 0), TURQL)
				B:block(ob, v(s * 0.3, s * 0.35, s * 0.3), CFrame.new(p) * CFrame.new(0, s * 1.35, 0) * ang(0, 45, 0), NT, NEON)
			end
		end
	end,
}
