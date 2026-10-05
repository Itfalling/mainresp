--!nocheck
-- Solar Griffin: stud-built sun griffin. White eagle head + gold beak, stepped
-- white -> gold -> orange chest feathers, tawny lion hindquarters, big stepped
-- feather wings and a lion tail that ends in a voxel flame tuft.
-- Glow is kept to small orange accents (eyes, tips, thin strips).
return {
	DisplayName = "Solar Griffin",
	Rarity = "Legendary",
	Element = "Sun",
	Build = function(B, P)
		local v, cf = P.v, P.cf

		-- palette ---------------------------------------------------------
		local WHITE, CREAM = "#fbf7ee", "#eadcbf" -- feathers / shade of white
		local GOLD, BEAKDK = "#f5c04a", "#e08f22" -- beak, wing bars / beak hook, scales
		local TAWNY, DARK = "#e0a83a", "#b97d24" -- lion body / shading blocks
		local ORANGE, FLAMEY = "#f27a1e", "#ffcf3a" -- feather tips, flame
		local BELLY = "#f6e0ac"
		local MOUTH, TONGUE, PUPIL = "#1d1410", "#e0566e", "#2a1406"
		local NEON = "#ff8a2a" -- the one neon accent

		------------------------------------------------------------------
		-- BODY: tawny lion hindquarters
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 8.6, 2.0))
		B:block(body, v(5.8, 4.4, 6.2), cf(0, 8.7, 4.6), TAWNY) -- rump
		B:block(body, v(5.4, 4.2, 3.8), cf(0, 8.9, 0.2), TAWNY) -- waist
		B:block(body, v(4.6, 0.8, 7.4), cf(0, 11.3, 3.4), TAWNY) -- back step
		B:block(body, v(1.8, 0.4, 6.6), cf(0, 11.85, 3.7), DARK) -- spine stripe
		B:block(body, v(4.4, 0.6, 7.6), cf(0, 6.3, 2.6), BELLY) -- belly
		B:block(body, v(4.6, 2.8, 0.4), cf(0, 8.4, 7.85), DARK) -- rump shade
		for i, z in { 1.2, 3.6, 6.0 } do -- stepped fur tufts along the spine
			B:block(body, v(1.0, 0.7, 1.4), cf(0, 12.35, z), i == 2 and GOLD or DARK)
		end

		------------------------------------------------------------------
		-- CHEST: eagle front with stepped white -> gold -> orange feathers
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Body", v(0, 9.8, -0.6))
		B:block(chest, v(6.2, 5.6, 5.0), cf(0, 10.6, -2.2), WHITE)
		B:block(chest, v(5.0, 1.0, 4.2), cf(0, 13.9, -1.6), WHITE)
		local rows = {
			{ 13.0, 4.6, WHITE }, { 12.0, 5.4, WHITE }, { 11.0, 5.0, GOLD },
			{ 10.0, 4.2, GOLD }, { 9.0, 3.2, ORANGE }, { 8.05, 2.0, ORANGE },
		}
		for i, r in rows do
			B:block(chest, v(r[2], 1.0, 1.0), cf(0, r[1], -5.0 - (i % 2) * 0.25), r[3])
		end
		B:sym(function()
			B:block(chest, v(0.3, 3.6, 4.0), cf(3.15, 10.4, -2.2), CREAM)
		end)
		local aura = B:block(chest, v(5, 4, 5), cf(0, 11, -1), WHITE, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { color = { WHITE, FLAMEY }, rate = 4 })
		local fx = B:block(chest, v(7, 1, 3), cf(0, 13.4, 1.0), WHITE, { tr = 1, name = "FeatherFX" })
		B:emitter(fx, "leaf", {
			name = "FeatherBurst", rate = 0, color = { WHITE, GOLD, ORANGE }, size = { 0.6, 0.55, 0.3 },
			speed = { 5, 10 }, spread = 180, life = { 1.2, 2.2 }, accel = { 0, -5, 0 }, drag = 2,
		})

		------------------------------------------------------------------
		-- NECK + HEAD (big cartoon eagle head)
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Chest", v(0, 12.8, -3.0))
		B:block(neck, v(4.0, 3.6, 3.6), cf(0, 13.6, -4.4), WHITE)
		B:block(neck, v(4.6, 1.0, 4.0), cf(0, 12.4, -4.0), CREAM) -- feather collar
		B:block(neck, v(3.0, 0.9, 0.6), cf(0, 13.6, -6.35), WHITE)
		-- feather mane spikes down the back of the neck
		B:spike(neck, v(0, 15.0, -3.4), v(0, 16.6, -0.6), 1.6, 1.2, WHITE)
		B:spike(neck, v(0, 13.9, -2.8), v(0, 14.5, -0.2), 1.4, 1.0, GOLD)

		local head = B:bone("Head", "Neck", v(0, 14.4, -5.4))
		B:block(head, v(5.0, 4.6, 5.0), cf(0, 15.8, -7.2), WHITE) -- cranium
		B:block(head, v(3.8, 0.8, 3.6), cf(0, 18.5, -6.6), WHITE) -- top step
		B:block(head, v(5.8, 1.8, 3.6), cf(0, 14.3, -6.6), WHITE) -- chunky jowls
		B:block(head, v(4.4, 1.2, 1.4), cf(0, 17.3, -4.3), CREAM) -- back mane
		B:block(head, v(3.6, 1.0, 1.2), cf(0, 16.2, -3.8), GOLD)
		-- little sun mark on the forehead
		B:block(head, v(1.1, 1.1, 0.2), cf(0, 17.45, -9.78, 0, 0, 45), GOLD)
		B:block(head, v(0.55, 0.55, 0.2), cf(0, 17.45, -9.84, 0, 0, 45), NEON, { mat = "Neon" })

		-- hooked beak (upper)
		B:block(head, v(2.2, 0.9, 1.2), cf(0, 15.55, -10.2), GOLD) -- cere
		B:block(head, v(2.2, 1.4, 2.4), cf(0, 14.7, -11.0), GOLD)
		B:block(head, v(0.8, 0.4, 2.6), cf(0, 15.5, -11.2), BEAKDK) -- ridge
		B:wedge(head, v(1.6, 1.6, 1.2), cf(0, 14.3, -12.8), GOLD) -- tip slopes down
		B:block(head, v(1.2, 0.6, 1.0), cf(0, 13.75, -12.95), BEAKDK)
		B:wedge(head, v(1.0, 1.3, 1.1), cf(0, 12.8, -12.85, 0, 0, 180), BEAKDK) -- hook point
		B:block(head, v(2.0, 0.3, 2.6), cf(0, 13.95, -11.0), MOUTH)
		B:block(head, v(1.0, 0.45, 0.5), cf(0, 13.8, -9.95), NEON, { mat = "Neon" }) -- throat glow

		B:sym(function()
			-- nostril
			B:block(head, v(0.35, 0.2, 0.6), cf(0.6, 15.45, -11.6), MOUTH)
			-- fangs hanging over the lower beak (toothy grin)
			B:block(head, v(0.35, 0.7, 0.4), cf(1.25, 13.6, -10.4), WHITE)
			B:block(head, v(0.35, 0.7, 0.4), cf(1.15, 13.6, -11.5), WHITE)
			-- big wrap-around eye: neon slit, dark pupils (front + side), heavy brow
			B:block(head, v(1.6, 1.6, 1.4), cf(1.8, 16.1, -9.1), NEON, { mat = "Neon", name = "Eye" })
			B:block(head, v(0.5, 1.1, 0.1), cf(1.55, 16.0, -9.84), PUPIL)
			B:block(head, v(0.15, 1.1, 0.5), cf(2.6, 16.0, -9.0), PUPIL)
			B:block(head, v(2.2, 0.7, 1.7), cf(1.75, 17.2, -9.15, 0, 0, 14), BEAKDK)
			-- cheek feather spike flaring back
			B:spike(head, v(2.5, 14.6, -6.4), v(4.6, 14.0, -3.0), 1.2, 1.2, WHITE)
			-- ear-tuft "horns": stacked stepped blocks (white -> gold), small neon tip
			local hb = CFrame.new(1.65, 17.7, -6.6) * P.ang(34, 0, -16)
			B:block(head, v(1.7, 1.4, 1.8), hb * CFrame.new(0, 0.5, 0), WHITE)
			B:block(head, v(1.4, 1.3, 1.5), hb * CFrame.new(0, 1.8, 0.15), WHITE)
			B:block(head, v(1.1, 1.2, 1.2), hb * CFrame.new(0, 3.0, 0.3), GOLD)
			B:block(head, v(0.8, 1.0, 0.9), hb * CFrame.new(0, 4.05, 0.45), GOLD)
			B:block(head, v(0.5, 0.6, 0.5), hb * CFrame.new(0, 4.85, 0.55), NEON, { mat = "Neon" })
		end)

		-- crest plume (own bone for secondary motion)
		local crest = B:bone("Crest", "Head", v(0, 18.7, -6.4))
		B:block(crest, v(1.4, 1.2, 2.4), cf(0, 19.3, -6.4), WHITE)
		B:block(crest, v(1.2, 1.1, 2.2), cf(0, 20.1, -5.2), GOLD)
		B:block(crest, v(1.0, 1.0, 1.8), cf(0, 20.8, -3.9), ORANGE)
		B:block(crest, v(0.6, 0.6, 0.6), cf(0, 21.3, -3.0), NEON, { mat = "Neon" })

		-- eyelids (tucked up under the brow; slide down for blinks)
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(1.8, 17.0, -9.1))
			B:block(lid, v(1.8, 1.7, 1.6), cf(1.8, 17.75, -9.1), WHITE)
		end)

		-- mouth FX (screech)
		local mfx = B:block(head, v(2, 1, 1), cf(0, 13.6, -13.0), WHITE, { tr = 1, name = "MouthFX" })
		B:emitter(mfx, "burst", { name = "SolarBurst", color = { WHITE, FLAMEY, NEON } })
		B:emitter(mfx, "spark", { name = "ScreechSparks", color = { FLAMEY, NEON }, enabled = false, rate = 30 })
		B:light(mfx, { name = "ScreechLight", color = "#ffb347", brightness = 0, range = 14 })

		-- lower beak
		local jaw = B:bone("Jaw", "Head", v(0, 13.9, -9.6))
		B:block(jaw, v(2.0, 0.9, 3.0), cf(0, 13.3, -11.0), GOLD)
		B:block(jaw, v(2.6, 0.9, 1.0), cf(0, 13.35, -9.3), GOLD)
		B:block(jaw, v(1.6, 0.4, 2.2), cf(0, 12.7, -10.9), BEAKDK)
		B:block(jaw, v(1.8, 0.2, 2.6), cf(0, 13.8, -11.0), MOUTH)
		B:block(jaw, v(1.0, 0.2, 1.4), cf(0, 13.95, -10.6), TONGUE)
		B:sym(function()
			B:block(jaw, v(0.35, 0.45, 0.35), cf(0.65, 14.0, -12.15), WHITE)
			B:block(jaw, v(0.35, 0.45, 0.35), cf(0.75, 14.0, -11.2), WHITE)
		end)

		------------------------------------------------------------------
		-- WINGS (authored folded flat along the body; motion tilts / spreads)
		------------------------------------------------------------------
		B:sym(function(side)
			local w1 = B:bone("Wing" .. side, "Chest", v(2.8, 13.4, -0.6))
			B:block(w1, v(1.4, 1.4, 4.8), cf(3.5, 13.4, 1.4), GOLD)
			B:block(w1, v(1.0, 1.6, 4.6), cf(3.8, 11.95, 1.5), WHITE)
			B:block(w1, v(0.8, 1.4, 4.4), cf(3.75, 10.6, 1.7), GOLD)
			for k, h in { 0.8, 1.2, 1.0 } do
				B:block(w1, v(0.8, h, 1.45), cf(3.75, 9.95 - h / 2, -0.95 + k * 1.45), ORANGE)
			end

			local w2 = B:bone("WingMid" .. side, "Wing" .. side, v(3.0, 13.4, 3.6))
			B:block(w2, v(1.3, 1.3, 4.0), cf(3.5, 13.4, 5.3), GOLD)
			B:block(w2, v(1.0, 1.5, 3.8), cf(3.8, 12.0, 5.3), WHITE)
			B:block(w2, v(0.8, 1.4, 3.6), cf(3.75, 10.7, 5.3), GOLD)
			for k, h in { 1.2, 1.8, 1.4 } do
				B:block(w2, v(0.8, h, 1.2), cf(3.75, 10.0 - h / 2, 2.7 + k * 1.2), ORANGE)
			end

			local w3 = B:bone("WingTip" .. side, "WingMid" .. side, v(3.1, 13.4, 7.2))
			B:block(w3, v(1.2, 1.2, 2.8), cf(3.5, 13.4, 8.3), GOLD)
			B:block(w3, v(1.0, 0.9, 1.8), cf(3.5, 13.4, 10.4), WHITE)
			B:block(w3, v(0.3, 0.3, 2.6), cf(3.5, 14.1, 8.2), NEON, { mat = "Neon" })
			-- primaries: stepped feathers, longest on top, orange tips
			local prim = { { 12.4, 5.3, WHITE }, { 11.4, 4.7, WHITE }, { 10.4, 4.0, GOLD }, { 9.4, 3.3, GOLD } }
			for k, p in prim do
				local x = 3.8 - (k % 2) * 0.1
				B:block(w3, v(0.8, 1.0, p[2]), cf(x, p[1], 6.8 + p[2] / 2), p[3])
				B:block(w3, v(0.8, 1.0, 1.2), cf(x, p[1], 6.8 + p[2] + 0.6), ORANGE)
			end
			B:block(w3, v(0.5, 0.5, 0.5), cf(3.75, 12.4, 13.55), NEON, { mat = "Neon" })
			B:trail(w3, v(3.6, 13.0, 13.2), v(3.7, 9.6, 11.6), {
				name = "WingTrail" .. side, color = { GOLD, ORANGE }, life = 0.3, trans = { 0.45, 1 }, light = 0.4,
			})
		end)

		------------------------------------------------------------------
		-- FRONT LEGS (eagle): feathered trousers, scaly gold legs, white talons
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Chest", v(2.5, 9.6, -2.8))
			B:block(arm, v(2.4, 3.4, 2.6), cf(2.8, 8.0, -2.8), WHITE)
			B:block(arm, v(2.6, 0.7, 2.8), cf(2.8, 6.4, -2.8), CREAM)
			local fore = B:bone("Fore" .. side, "Arm" .. side, v(2.8, 6.2, -2.6))
			B:block(fore, v(1.6, 5.2, 1.6), cf(2.8, 3.6, -2.8), GOLD)
			B:block(fore, v(1.75, 0.35, 1.75), cf(2.8, 4.6, -2.8), BEAKDK)
			B:block(fore, v(1.75, 0.35, 1.75), cf(2.8, 3.2, -2.8), BEAKDK)
			local foot = B:bone("Foot" .. side, "Fore" .. side, v(2.8, 1.5, -3.0))
			B:block(foot, v(2.2, 1.0, 2.2), cf(2.8, 0.75, -3.2), GOLD)
			B:block(foot, v(2.7, 0.7, 1.4), cf(2.8, 0.35, -4.7), GOLD)
			for k = -1, 1 do
				B:wedge(foot, v(0.6, 0.9, 1.3), cf(2.8 + k * 0.95, 0.45, -6.05), WHITE)
			end
			B:wedge(foot, v(0.6, 0.7, 1.0), cf(2.8, 0.35, -1.65, 0, 180, 0), WHITE)
		end)

		------------------------------------------------------------------
		-- HIND LEGS (lion): big haunch, shaded shin, chunky paw with claws
		------------------------------------------------------------------
		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Body", v(2.5, 9.0, 4.8))
			B:block(thigh, v(2.6, 4.4, 4.4), cf(3.0, 7.6, 4.8), TAWNY)
			B:block(thigh, v(0.3, 2.8, 3.2), cf(4.4, 7.6, 5.0), DARK)
			B:block(thigh, v(2.2, 1.0, 3.4), cf(3.0, 10.2, 4.9), TAWNY) -- stepped haunch top
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(3.0, 5.6, 5.8))
			B:block(shin, v(1.9, 4.8, 2.0), cf(3.0, 3.6, 6.0), TAWNY)
			B:block(shin, v(1.5, 2.4, 0.3), cf(3.0, 3.6, 7.1), DARK)
			local paw = B:bone("Paw" .. side, "Shin" .. side, v(3.0, 1.6, 5.8))
			B:block(paw, v(2.6, 1.4, 3.2), cf(3.0, 0.7, 5.3), TAWNY)
			B:block(paw, v(2.4, 0.7, 0.6), cf(3.0, 0.4, 3.5), BELLY)
			for k = -1, 1 do
				B:wedge(paw, v(0.5, 0.6, 0.9), cf(3.0 + k * 0.8, 0.3, 3.0), WHITE)
			end
		end)

		------------------------------------------------------------------
		-- TAIL (4 bones) ending in a stepped voxel flame
		------------------------------------------------------------------
		local pts = { v(0, 10.0, 7.4), v(0, 10.9, 9.6), v(0, 12.4, 11.3), v(0, 14.2, 12.2), v(0, 15.8, 12.5) }
		local widths = { 1.5, 1.3, 1.15, 1.0 }
		local parent = "Body"
		for i = 1, 4 do
			local b = B:bone("Tail" .. i, parent, pts[i])
			B:beam(b, pts[i], pts[i + 1] + (pts[i + 1] - pts[i]).Unit * 0.3, widths[i], widths[i], TAWNY)
			B:block(b, v(widths[i] + 0.2, widths[i] + 0.2, 0.6), CFrame.lookAt(pts[i], pts[i + 1]), DARK)
			if i == 2 or i == 3 then -- little stepped fur tufts on the tail
				local mid = (pts[i] + pts[i + 1]) / 2
				B:block(b, v(0.6, 0.8, 0.8), CFrame.lookAt(mid, pts[i + 1]) * CFrame.new(0, widths[i] / 2 + 0.25, 0), GOLD)
			end
			parent = "Tail" .. i
		end
		local flame = B:bone("Flame", "Tail4", pts[5])
		B:block(flame, v(2.4, 1.3, 2.4), cf(0, 16.4, 12.6), ORANGE)
		B:block(flame, v(2.1, 0.35, 2.1), cf(0, 17.15, 12.7), NEON, { mat = "Neon" })
		B:block(flame, v(2.0, 1.3, 2.0), cf(0, 17.6, 12.7), FLAMEY)
		B:sym(function()
			B:block(flame, v(0.8, 1.2, 0.8), cf(1.35, 17.4, 12.4), ORANGE)
		end)
		B:block(flame, v(0.8, 1.0, 0.8), cf(0, 18.0, 11.5), ORANGE)
		B:block(flame, v(1.3, 1.2, 1.3), cf(0, 18.8, 12.9), FLAMEY)
		B:block(flame, v(0.8, 1.0, 0.8), cf(0, 19.8, 13.1), ORANGE)
		B:block(flame, v(0.4, 0.6, 0.4), cf(0, 20.6, 13.25), FLAMEY)
		local ffx = B:block(flame, v(1.2, 1.2, 1.2), cf(0, 17.6, 12.7), ORANGE, { tr = 1, name = "FireFX" })
		B:emitter(ffx, "fire", { name = "TailFire", color = { FLAMEY, NEON }, rate = 10, size = { 0.9, 0.6, 0 } })
		B:emitter(ffx, "ember", { name = "TailEmbers", color = { FLAMEY, NEON }, rate = 4 })
		B:light(ffx, { name = "TailLight", color = NEON, brightness = 0.6, range = 8 })
		B:trail(flame, v(0, 18.6, 12.9), v(0, 16.4, 12.6), { name = "TailTrail", color = { FLAMEY, ORANGE }, life = 0.25, trans = { 0.5, 1 }, light = 0.4 })

		------------------------------------------------------------------
		-- Ground FX (dust on launch + landing)
		------------------------------------------------------------------
		local dust = B:block("Root", v(8, 0.3, 12), cf(0, 0.15, 1), WHITE, { tr = 1, name = "DustFX" })
		B:emitter(dust, "dust", { name = "GroundDust", color = "#eadfc6" })

		------------------------------------------------------------------
		-- Floating gold voxel cubes
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 9, 2))
		local spots = { { 9.5, 8.0, -1 }, { -9.5, 10.0, 3 }, { 8.0, 12.0, 9 }, { -7.5, 6.5, -5 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = i % 2 == 0 and 1.4 or 1.8
			B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), i % 2 == 0 and WHITE or GOLD)
			B:block(ob, v(s + 0.1, s * 0.22, s + 0.1), cf(p[1], p[2], p[3]), NEON, { mat = "Neon" })
		end
	end,
}
