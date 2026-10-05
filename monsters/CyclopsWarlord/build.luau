--!nocheck
-- Cyclops Warlord: a hunched one-eyed stud brute. Olive voxel skin with a
-- lighter stepped gut, ONE huge cartoon eye (white sclera, orange iris with a
-- small glowing core, black pupil) under an angry V unibrow, tusked
-- underbite, single ivory horn + topknot, leather loincloth, spiked grey
-- pauldron with gold trims, gold arm bands and a huge spiked voxel club.
-- Earth VFX: floating rock cubes, and on the slam a crater rim, glowing
-- ground cracks, flying debris, dust and sparks.
return {
	DisplayName = "Cyclops Warlord",
	Rarity = "Legendary",
	Element = "Earth",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local SKIN, SKIN_D = "#8fae6b", "#6e8a50"
		local BELLY_A, BELLY_B = "#cfdfa6", "#b4ca88"
		local IVORY, WHITE, MOUTH, TONGUE = "#f2e8cc", "#fbfaf4", "#1b1612", "#d9566b"
		local LEATHER, LEATHER_D, HAIR = "#7a4a2a", "#553218", "#3a2a20"
		local METAL, METAL_D, METAL_L = "#7a7f8c", "#5b606c", "#cfd3dc"
		local GOLD = "#ebb43a"
		local WOOD, WOOD_D = "#8f5d33", "#64401f"
		local IRIS, NEON, PUPIL = "#ec7418", "#ff9a1a", "#141414"
		local STONE, STONE_D, DIRT = "#a89c8a", "#857a6a", "#8f7a5e"

		-- stepped voxel spike: n blocks shrinking from base toward tip
		local function stepSpike(bone, base, tip, n, w0, color, tipColor)
			local scf, len = P.span(base, tip)
			local seg = len / n
			for i = 0, n - 1 do
				local w = w0 * (1 - i / (n + 0.5))
				local col = (i == n - 1 and tipColor) or color
				B:block(bone, v(w, w, seg + 0.12), scf * CFrame.new(0, 0, len / 2 - (i + 0.5) * seg), col, col == NEON and { mat = "Neon" } or nil)
			end
		end

		------------------------------------------------------------------
		-- Hips: leather shorts, belt + gold buckle, loincloth flaps
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 6.4, 0.4))
		B:block(hips, v(7.6, 2.6, 5.4), cf(0, 5.5, 0.4), LEATHER_D)
		B:block(hips, v(9.6, 1.4, 7.4), cf(0, 7.1, 0.4), LEATHER)
		B:block(hips, v(2.6, 1.9, 0.5), cf(0, 7.1, -3.5), GOLD)
		B:gem(hips, v(0.8, 0.8, 0.3), cf(0, 7.1, -3.85), NEON)
		B:sym(function()
			B:block(hips, v(0.4, 0.8, 0.8), cf(4.85, 7.1, -1.4), GOLD)
			B:block(hips, v(0.4, 0.8, 0.8), cf(4.85, 7.1, 2.2), GOLD)
		end)

		local loinF = B:bone("LoinF", "Hips", v(0, 6.6, -2.7))
		B:block(loinF, v(3.8, 1.8, 0.5), cf(0, 5.7, -2.65), LEATHER)
		B:block(loinF, v(3.2, 1.5, 0.5), cf(0, 4.1, -2.65), LEATHER)
		B:block(loinF, v(1.1, 0.8, 0.5), cf(-0.95, 3.0, -2.65), LEATHER_D)
		B:block(loinF, v(1.1, 0.8, 0.5), cf(0.95, 3.0, -2.65), LEATHER_D)
		B:block(loinF, v(3.9, 0.4, 0.55), cf(0, 4.95, -2.65), GOLD)

		local loinB = B:bone("LoinB", "Hips", v(0, 6.6, 3.5))
		B:block(loinB, v(4.4, 1.8, 0.5), cf(0, 5.7, 3.45), LEATHER)
		B:block(loinB, v(3.6, 1.5, 0.5), cf(0, 4.1, 3.45), LEATHER)
		B:block(loinB, v(1.2, 0.8, 0.5), cf(-1.0, 3.0, 3.45), LEATHER_D)
		B:block(loinB, v(1.2, 0.8, 0.5), cf(1.0, 3.0, 3.45), LEATHER_D)

		------------------------------------------------------------------
		-- Legs: short stubby voxel legs, leather wraps, ivory toenails
		------------------------------------------------------------------
		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Hips", v(2.75, 5.4, 0.4))
			B:block(thigh, v(3.4, 2.8, 3.6), cf(2.75, 4.4, 0.4), SKIN_D)
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(2.75, 3.1, 0.4))
			B:block(shin, v(3.0, 2.4, 3.0), cf(2.75, 2.15, 0.45), SKIN)
			B:block(shin, v(3.2, 0.7, 3.2), cf(2.75, 2.75, 0.45), LEATHER_D)
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(2.75, 1.1, 0.5))
			B:block(foot, v(3.6, 1.2, 4.4), cf(2.75, 0.6, 0.1), SKIN_D)
			for k = -1, 1 do
				B:block(foot, v(1.05, 1.0, 1.1), cf(2.75 + k * 1.2, 0.5, -2.45), SKIN)
				B:wedge(foot, v(0.8, 0.65, 0.8), cf(2.75 + k * 1.2, 0.33, -3.3), IVORY)
			end
		end)

		------------------------------------------------------------------
		-- Torso: barrel chest + stepped light gut
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Hips", v(0, 7.6, 0.4))
		B:block(chest, v(9.0, 3.6, 6.8), cf(0, 9.3, 0.4), SKIN)
		B:block(chest, v(10.4, 3.6, 6.4), cf(0, 12.7, 0.8), SKIN)
		B:block(chest, v(8.4, 1.4, 5.0), cf(0, 15.0, 1.6), SKIN_D)
		B:sym(function()
			B:block(chest, v(0.4, 2.8, 5.6), cf(4.6, 9.3, 0.6), SKIN_D)
			B:block(chest, v(0.4, 3.0, 5.4), cf(5.3, 12.6, 1.0), SKIN_D)
			-- pecs
			B:block(chest, v(3.6, 1.8, 0.6), cf(2.6, 12.9, -2.6), SKIN)
		end)
		-- dark back panel + stepped ivory back spikes
		B:block(chest, v(6.4, 5.6, 0.6), cf(0, 11.5, 4.0), SKIN_D)
		for i, y in { 14.0, 12.0, 10.0 } do
			stepSpike(chest, v(0, y, 3.9), v(0, y + 1.2, 6.4 - i * 0.25), 2, 1.6 - i * 0.12, IVORY)
		end
		-- the gut: its own bone so it can breathe in and out
		local gut = B:bone("Gut", "Chest", v(0, 9.6, -3.0))
		local rows = { { 8.3, 5.2, -3.3 }, { 9.3, 6.6, -3.55 }, { 10.3, 7.0, -3.55 }, { 11.3, 6.2, -3.3 } }
		for i, r in rows do
			B:block(gut, v(r[2], 1.0, 1.3), cf(0, r[1], r[3] + 0.05), i % 2 == 1 and BELLY_A or BELLY_B)
		end
		B:block(gut, v(0.7, 0.5, 0.2), cf(0, 9.3, -4.25), SKIN_D)
		local aura = B:block(chest, v(9, 7, 6), cf(0, 11, 0.5), SKIN, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { color = { "#fff6dc", NEON }, rate = 3 })

		------------------------------------------------------------------
		-- Head: big cartoon head sunk into the shoulders
		------------------------------------------------------------------
		local head = B:bone("Head", "Chest", v(0, 14.0, -1.0))
		B:block(head, v(7.6, 4.2, 6.0), cf(0, 16.4, -2.3), SKIN)
		B:block(head, v(6.6, 0.9, 5.0), cf(0, 18.9, -2.0), SKIN)
		B:block(head, v(6.4, 3.2, 1.2), cf(0, 16.2, 1.0), SKIN_D)
		B:block(head, v(6.2, 4.4, 0.3), cf(0, 16.8, -5.4), SKIN_D)
		B:block(head, v(7.0, 1.2, 1.3), cf(0, 14.6, -5.5), SKIN)
		B:block(head, v(6.4, 1.4, 4.0), cf(0, 13.5, -3.4), MOUTH)
		B:sym(function(side)
			B:block(head, v(0.4, 2.8, 4.4), cf(3.85, 16.0, -2.6), SKIN_D)
			B:block(head, v(0.5, 0.35, 0.2), cf(0.75, 14.9, -6.2), MOUTH)
			-- upper teeth
			B:block(head, v(0.7, 0.7, 0.6), cf(0.8, 13.7, -5.75), WHITE)
			B:block(head, v(0.7, 0.7, 0.6), cf(2.15, 13.7, -5.75), WHITE)
			-- stepped ogre ears (pointing out and up)
			B:block(head, v(1.0, 2.0, 1.6), cf(4.1, 16.4, -2.4), SKIN)
			B:block(head, v(1.2, 1.5, 1.2), cf(5.1, 16.9, -2.2), SKIN)
			B:block(head, v(1.0, 1.0, 0.9), cf(6.05, 17.5, -2.0), SKIN)
			B:block(head, v(1.8, 0.9, 0.2), cf(5.0, 16.8, -2.85), SKIN_D)
			if side == "R" then
				-- gold earring hoop
				B:block(head, v(0.3, 0.3, 1.1), cf(5.1, 15.45, -2.2), GOLD)
				B:block(head, v(0.3, 0.8, 0.3), cf(5.1, 15.8, -2.6), GOLD)
				B:block(head, v(0.3, 0.8, 0.3), cf(5.1, 15.8, -1.8), GOLD)
			end
		end)
		-- single forward-curving horn with a small glowing tip
		B:block(head, v(2.0, 0.8, 2.0), cf(0, 19.6, -3.0), IVORY)
		B:block(head, v(1.5, 0.8, 1.5), cf(0, 20.25, -3.3, -10, 0, 0), IVORY)
		B:block(head, v(1.0, 0.7, 1.0), cf(0, 20.8, -3.7, -20, 0, 0), IVORY)
		B:gem(head, v(0.55, 0.55, 0.55), cf(0, 21.2, -4.05, -28, 0, 0), NEON)
		local snort = B:block(head, v(1.6, 0.4, 0.4), cf(0, 14.8, -6.4), SKIN, { tr = 1, name = "SnortFX" })
		B:emitter(snort, "dust", { name = "Snort", color = "#f4f1e8", speed = { 3, 6 }, size = { 0.5, 1.2, 1.8 }, life = { 0.4, 0.8 }, spread = 20, dir = "Front" })
		local hornTip = B:block(head, v(0.6, 0.6, 0.6), cf(0, 21.3, -4.1), SKIN, { tr = 1, name = "HornFX" })
		B:emitter(hornTip, "burst", { name = "Bling", color = { "#ffffff", "#ffe2a8" }, speed = { 3, 6 }, size = { 0.7, 0.5, 0 } })

		-- topknot (secondary motion)
		local knot = B:bone("Topknot", "Head", v(0, 19.3, 0.2))
		B:block(knot, v(1.5, 0.6, 1.5), cf(0, 19.6, 0.2), GOLD)
		B:block(knot, v(1.9, 1.1, 1.9), cf(0, 20.4, 0.3), HAIR)
		B:block(knot, v(1.4, 1.0, 1.6), cf(0, 20.55, 1.6, 25, 0, 0), HAIR)
		B:block(knot, v(1.0, 0.9, 1.3), cf(0, 20.1, 2.6, 55, 0, 0), HAIR)

		-- the ONE big eye (pops out on its own bone) + darting iris
		local eye = B:bone("Eye", "Head", v(0, 16.8, -5.7))
		B:block(eye, v(5.2, 3.6, 1.4), cf(0, 16.8, -5.4), WHITE)
		local iris = B:bone("Iris", "Eye", v(0, 16.7, -6.15))
		B:block(iris, v(2.8, 2.8, 0.2), cf(0, 16.7, -6.15), IRIS)
		B:gem(iris, v(1.7, 1.7, 0.15), cf(0, 16.7, -6.3), NEON, { name = "EyeCore" })
		B:block(iris, v(1.0, 1.0, 0.15), cf(0, 16.7, -6.42), PUPIL)
		B:block(iris, v(0.45, 0.45, 0.08), cf(0.62, 17.3, -6.52), WHITE)

		-- eyelid: flat plate tucked under the brow, hinges down for blinks
		local lid = B:bone("Lid", "Head", v(0, 18.75, -6.85))
		B:block(lid, v(5.6, 0.5, 3.8), cf(0, 18.75, -4.95), SKIN)

		-- angry V unibrow (two halves so it can flip to surprised)
		B:sym(function(side)
			local brow = B:bone("Brow" .. side, "Head", v(0.2, 19.0, -5.9))
			B:block(brow, v(3.8, 1.3, 1.7), cf(1.8, 19.15, -5.95, 0, 0, 12), SKIN_D)
		end)

		-- underbite jaw with ivory tusks
		local jaw = B:bone("Jaw", "Head", v(0, 14.0, -1.6))
		B:block(jaw, v(7.2, 1.6, 5.4), cf(0, 12.2, -3.9), SKIN)
		B:block(jaw, v(6.0, 0.5, 4.4), cf(0, 11.25, -3.6), SKIN_D)
		B:block(jaw, v(5.0, 1.0, 0.6), cf(0, 12.0, -6.85), SKIN_D)
		B:block(jaw, v(6.4, 0.4, 4.6), cf(0, 13.1, -3.8), MOUTH)
		B:block(jaw, v(3.0, 0.3, 2.6), cf(0, 13.35, -3.6), TONGUE)
		B:sym(function()
			B:block(jaw, v(0.7, 0.8, 0.6), cf(1.0, 13.5, -6.15), WHITE)
			B:block(jaw, v(1.2, 1.2, 1.2), cf(2.7, 13.5, -6.1), IVORY)
			B:block(jaw, v(0.95, 1.0, 0.95), cf(2.95, 14.55, -6.15), IVORY)
			B:block(jaw, v(0.7, 0.8, 0.7), cf(3.2, 15.4, -6.2), IVORY)
		end)

		------------------------------------------------------------------
		-- Arms: gorilla arms, gold bracers. Right fist holds the club, the
		-- left hand cups the club head (idle "tap tap").
		------------------------------------------------------------------
		local SH = v(5.4, 13.6, 0.8)
		local EL = v(6.8, 10.2, -1.8)
		local FIST_R = v(4.8, 7.4, -6.2)
		local PALM_L = v(3.6, 7.2, -6.8) -- authored on the right, mirrored to -X
		B:sym(function(side)
			local isR = side == "R"
			local arm = B:bone("Arm" .. side, "Chest", SH)
			B:block(arm, v(3.2, 3.2, 3.4), cf(6.3, 13.4, 0.8), SKIN)
			B:beam(arm, v(6.4, 12.6, 0.4), EL + v(0, -0.3, -0.1), 2.6, 2.6, SKIN_D)
			if not isR then
				B:beam(arm, v(6.55, 11.7, -0.6), v(6.65, 11.0, -1.1), 2.9, 2.9, GOLD)
			end
			local fore = B:bone("Forearm" .. side, "Arm" .. side, EL)
			local hand = isR and FIST_R or PALM_L
			local d = (hand - EL).Unit
			B:beam(fore, EL - d * 0.6, hand - d * 0.9, 2.8, 2.8, SKIN)
			B:beam(fore, hand - d * 2.5, hand - d * 1.6, 3.1, 3.1, GOLD)
			if isR then
				B:block(fore, v(3.0, 2.8, 3.0), CFrame.new(hand), SKIN)
				B:block(fore, v(2.6, 2.2, 0.5), CFrame.new(hand + v(0.1, 0, -1.45)), SKIN_D)
			else
				B:block(fore, v(2.8, 1.0, 3.0), CFrame.new(hand), SKIN)
				for k = -1, 1 do
					B:block(fore, v(0.75, 1.3, 0.8), CFrame.new(hand + v(k * 0.85, 0.65, -1.3)), SKIN)
				end
				B:block(fore, v(0.8, 1.1, 0.8), CFrame.new(hand + v(0.4, 0.55, 1.35)), SKIN_D)
			end
		end)

		-- spiked metal pauldron on the right shoulder (follows the arm partly)
		local paul = B:bone("Pauldron", "Chest", SH)
		B:block(paul, v(4.4, 1.0, 4.4), cf(6.4, 15.3, 0.8), METAL)
		B:block(paul, v(1.0, 2.4, 4.4), cf(8.3, 14.0, 0.8), METAL)
		B:block(paul, v(1.0, 1.4, 3.8), cf(8.75, 12.5, 0.8), METAL_D)
		B:block(paul, v(4.6, 0.45, 0.45), cf(6.4, 15.0, -1.45), GOLD)
		B:block(paul, v(4.6, 0.45, 0.45), cf(6.4, 15.0, 3.05), GOLD)
		B:block(paul, v(0.5, 0.45, 4.0), cf(9.0, 11.85, 0.8), GOLD)
		B:block(paul, v(0.4, 0.8, 0.8), cf(8.85, 14.1, 0.8), GOLD)
		stepSpike(paul, v(6.2, 15.6, 0.8), v(6.6, 18.4, 0.8), 3, 1.3, METAL_L)
		stepSpike(paul, v(7.6, 15.5, -0.5), v(9.3, 17.3, -1.1), 2, 1.1, METAL_L)
		stepSpike(paul, v(7.6, 15.5, 2.1), v(9.3, 17.3, 2.7), 2, 1.1, METAL_L)

		------------------------------------------------------------------
		-- The club: wood + grey bands + light metal spikes
		------------------------------------------------------------------
		local CLUB_T = v(-3.6, 9.4, -6.8) -- club axis rests on the left palm here
		local ccf = CFrame.lookAt(FIST_R, CLUB_T)
		local club = B:bone("Club", "ForearmR", FIST_R)
		local function cb(size, along, color, opts)
			return B:block(club, size, ccf * CFrame.new(0, 0, -along), color, opts)
		end
		cb(v(1.2, 1.2, 4.6), 0.9, WOOD)
		cb(v(1.4, 1.4, 0.9), 2.2, LEATHER_D)
		cb(v(1.6, 1.6, 0.8), -1.8, WOOD_D)
		cb(v(1.1, 1.1, 0.4), -2.35, GOLD)
		cb(v(2.1, 2.1, 0.6), 3.2, METAL)
		cb(v(2.8, 2.8, 1.0), 3.9, WOOD)
		cb(v(3.6, 3.6, 3.2), 5.9, WOOD, { name = "ClubHead" })
		cb(v(3.9, 3.9, 0.7), 5.9, METAL)
		cb(v(3.0, 3.0, 1.0), 7.95, WOOD_D)
		cb(v(2.3, 2.3, 0.5), 8.65, METAL)
		B:block(club, v(0.55, 0.55, 0.2), ccf * CFrame.new(1.96, 0, -5.9) * P.ang(0, 90, 0), NEON, { mat = "Neon" })
		B:block(club, v(0.55, 0.55, 0.2), ccf * CFrame.new(-1.96, 0, -5.9) * P.ang(0, 90, 0), NEON, { mat = "Neon" })
		local function cpt(x, y, along)
			return (ccf * CFrame.new(x, y, -along)).Position
		end
		stepSpike(club, cpt(0, 1.6, 4.8), cpt(0, 3.3, 4.8), 2, 1.1, METAL_L)
		stepSpike(club, cpt(0, 1.6, 7.0), cpt(0, 3.3, 7.0), 2, 1.1, METAL_L)
		stepSpike(club, cpt(0, -1.6, 5.9), cpt(0, -3.3, 5.9), 2, 1.1, METAL_L)
		stepSpike(club, cpt(1.6, 0, 4.8), cpt(3.3, 0, 4.8), 2, 1.1, METAL_L)
		stepSpike(club, cpt(1.6, 0, 7.0), cpt(3.3, 0, 7.0), 2, 1.1, METAL_L)
		stepSpike(club, cpt(-1.6, 0, 5.9), cpt(-3.3, 0, 5.9), 2, 1.1, METAL_L)
		stepSpike(club, cpt(0, 0, 8.8), cpt(0, 0, 10.2), 2, 1.1, METAL_L)
		B:trail(club, cpt(0, 1.8, 7.6), cpt(0, -1.8, 7.6), { name = "ClubTrail", color = { "#fff3d6", NEON }, life = 0.28, trans = { 0.35, 1 } })

		------------------------------------------------------------------
		-- Floating rock voxel cubes orbiting the warlord
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 10, 0))
		local spots = { { 10.6, 12.0, 0.5 }, { -10.2, 8.0, 2.5 }, { 7.0, 3.2, 6.0 }, { -6.0, 19.8, -5.2 } }
		for i, p in spots do
			local ob = B:bone("Rock" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = (i % 2 == 0) and 1.4 or 1.8
			B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), i % 2 == 0 and STONE_D or STONE)
			B:block(ob, v(s * 0.55, s * 0.55, s * 0.55), cf(p[1] + s * 0.42, p[2] + s * 0.42, p[3] - s * 0.2), i % 2 == 0 and STONE or DIRT)
			B:block(ob, v(s + 0.08, 0.22, 0.22), cf(p[1], p[2] - s * 0.15, p[3] - s / 2 - 0.02), NEON, { mat = "Neon" })
		end

		------------------------------------------------------------------
		-- Earthshaker impact FX (hidden until the club hits the ground)
		------------------------------------------------------------------
		local IMPACT = v(-0.2, 0, -13.3)
		local imp = B:bone("Impact", "Root", IMPACT)
		local ground = B:block(imp, v(4, 0.3, 4), CFrame.new(IMPACT + v(0, 0.15, 0)), STONE, { tr = 1, name = "ImpactFX" })
		B:emitter(ground, "dust", { name = "ImpactDust", color = { "#e3d5ba", "#b39e80" } })
		B:emitter(ground, "burst", { name = "ImpactSpark", color = { "#ffffff", NEON }, speed = { 10, 18 } })
		B:light(ground, { name = "ImpactLight", color = NEON, brightness = 0.01, range = 16 })
		-- crater rim: ring of chunky rocks that pops up out of the ground
		local crater = B:bone("Crater", "Impact", IMPACT)
		for i = 0, 7 do
			local a = i / 8 * 360
			local c = CFrame.new(IMPACT) * P.ang(0, a, 0) * CFrame.new(0, 0.35, -2.7) * P.ang(-22, 0, 0)
			B:block(crater, v(1.5, 1.1, 1.0), c, i % 2 == 0 and STONE or STONE_D, { tr = 1, name = "Crat" .. (i + 1) })
		end
		-- glowing ground cracks
		for i = 0, 3 do
			local a = (i / 4 + 0.12) * 360
			local c = CFrame.new(IMPACT + v(0, 0.06, 0)) * P.ang(0, a, 0) * CFrame.new(0, 0, -2.6)
			B:block(imp, v(0.3, 0.12, 3.2), c, NEON, { mat = "Neon", tr = 1, name = "Crack" .. (i + 1) })
		end
		-- flying debris chunks
		for i = 1, 6 do
			local db = B:bone("Deb" .. i, "Impact", IMPACT)
			local s = 0.8 + (i % 3) * 0.3
			B:block(db, v(s, s, s), CFrame.new(IMPACT + v(0, 0.6, 0)), ({ STONE, STONE_D, DIRT })[i % 3 + 1], { tr = 1, name = "Deb" .. i })
		end
	end,
}
