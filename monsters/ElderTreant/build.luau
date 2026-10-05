--!nocheck
-- Elder Treant: a stud-built walking oak in the Void Leviathan style. Chunky
-- bark trunk with a big carved cartoon face (angry brows, big lime eyes with
-- goofy pupils, buck teeth, upturned tusks, stepped moss beard), a stepped
-- 4-tier voxel canopy (pink blossom blocks on their own sway bones, twisting
-- branch antlers out the back), splayed branch arms with chunky twig hands,
-- wide root feet and a row of stepped bark spikes down the back.
-- Palette: bark brown + dark bark, light cream contrast, ONE leaf green + a
-- light leaf highlight, pink blossoms as the secondary color, lime neon only
-- on eyes, tips and thin edge strips (calm glow).
return {
	DisplayName = "Elder Treant",
	Rarity = "Legendary",
	Element = "Nature",
	Build = function(B, P)
		local v, cf = P.v, P.cf

		-- palette
		local BARK, DARK, RIDGE = "#7a5230", "#4e341e", "#9a6d42"
		local CREAM = "#f1dfb0" -- light contrast: claws, thorns, shelves
		local FACE = "#c99560" -- heartwood face mask
		local LEAF, LEAF2 = "#2f8f2a", "#8fe36a" -- deep leaf + light highlight tops
		local PINK, PINKC = "#ff7fc0", "#fff1a8"
		local WHITE, MOUTH, TONGUE = "#fbf7ea", "#1a110a", "#e0507e"
		local PUPIL = "#16210c"
		local NEON = "#c6ff5c"

		local function box(bone, sx, sy, sz, x, y, z, col, opts)
			return B:block(bone, v(sx, sy, sz), cf(x, y, z), col, opts)
		end
		local function neon(bone, sx, sy, sz, x, y, z, name)
			return B:block(bone, v(sx, sy, sz), cf(x, y, z), NEON, { mat = "Neon", name = name })
		end

		------------------------------------------------------------------
		-- Hips (lower trunk)
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 6.2, 0.5))
		box(hips, 7.2, 3.0, 5.8, 0, 6.1, 0.5, BARK) -- y 4.6..7.6
		box(hips, 6.4, 0.6, 5.2, 0, 4.5, 0.5, DARK)
		box(hips, 4.6, 0.5, 0.3, 0, 5.0, -2.45, DARK) -- belt groove
		B:sym(function()
			box(hips, 0.4, 2.4, 4.8, 3.65, 6.0, 0.5, DARK)
			box(hips, 0.9, 2.2, 0.3, 2.1, 6.2, -2.45, RIDGE)
		end)

		------------------------------------------------------------------
		-- Root legs (thigh -> shin -> foot -> 2 root toes)
		------------------------------------------------------------------
		B:sym(function(side)
			local th = B:bone("Thigh" .. side, "Hips", v(2.4, 5.6, 0.6))
			box(th, 3.0, 3.2, 3.2, 2.6, 4.4, 0.6, BARK) -- y 2.8..6.0
			box(th, 0.4, 2.4, 2.6, 4.15, 4.4, 0.6, DARK)
			box(th, 1.0, 2.2, 0.3, 2.6, 4.3, -1.05, RIDGE)

			local sh = B:bone("Shin" .. side, "Thigh" .. side, v(2.7, 2.9, 0.6))
			box(sh, 2.6, 2.2, 2.8, 2.75, 2.0, 0.5, BARK) -- y 0.9..3.1
			box(sh, 3.2, 0.8, 3.4, 2.75, 3.0, 0.5, LEAF) -- mossy knee cuff
			box(sh, 2.2, 0.3, 2.4, 2.75, 3.5, 0.5, LEAF2)
			B:spike(sh, v(2.75, 3.0, -1.0), v(2.75, 3.6, -2.4), 0.7, 0.7, CREAM) -- knee thorn

			local ft = B:bone("Foot" .. side, "Shin" .. side, v(2.8, 1.1, 0.4))
			box(ft, 4.4, 1.2, 4.2, 2.9, 0.6, 0.1, BARK) -- x 0.7..5.1, y 0..1.2
			box(ft, 4.0, 0.4, 3.6, 2.9, 1.4, 0.3, DARK)
			box(ft, 2.2, 0.5, 1.6, 2.9, 1.8, 0.4, LEAF) -- moss tuft
			B:beam(ft, v(3.2, 0.6, 1.6), v(4.0, 0.45, 3.6), 1.2, 0.9, DARK) -- back root spur

			local toe = B:bone("Toe" .. side, "Foot" .. side, v(2.9, 0.6, -1.7))
			for k = -1, 1, 2 do
				local a = v(2.9 + k * 1.05, 0.6, -1.5)
				local b = v(2.9 + k * 1.4, 0.55, -3.4)
				B:beam(toe, a, b, 1.4, 1.1, BARK)
				box(toe, 1.2, 0.9, 0.9, b.X, 0.45, -3.95, CREAM) -- chunky claw block
			end
			if side == "R" then
				local dustAt = box(ft, 4.2, 0.3, 4, 2.9, 0.15, 0.1, BARK, { tr = 1, name = "StompFX" })
				B:emitter(dustAt, "dust", { name = "StompDust", color = "#cdb58c" })
				B:trail(ft, v(2.9, 0.2, -4.2), v(2.9, 1.3, -3.6), { name = "StompTrail", color = { LEAF2, NEON }, life = 0.25, trans = { 0.5, 1 } })
			end
		end)

		------------------------------------------------------------------
		-- Chest (upper trunk) + mossy collar
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Hips", v(0, 7.4, 0.5))
		box(chest, 7.8, 4.6, 6.2, 0, 9.6, 0.5, BARK) -- y 7.3..11.9, z -2.6..3.6
		box(chest, 9.0, 1.4, 7.6, 0, 11.8, 0.5, LEAF) -- collar (covers the neck seam)
		box(chest, 8.0, 0.4, 6.6, 0, 12.6, 0.5, LEAF2)
		B:sym(function()
			box(chest, 0.4, 3.8, 5.2, 4.05, 9.5, 0.6, DARK)
			-- glowing sap crack in a dark groove (zig-zag)
			box(chest, 1.0, 3.4, 0.3, 3.1, 9.2, -2.75, DARK)
			neon(chest, 0.3, 1.1, 0.2, 2.95, 9.3, -2.95)
			neon(chest, 0.3, 1.0, 0.2, 3.25, 8.3, -2.95)
			box(chest, 1.4, 1.2, 0.5, 2.4, 10.6, 3.95, LEAF) -- back moss
		end)
		-- back: knot hole + stepped bark spike plates down the spine
		box(chest, 1.8, 2.2, 0.3, -2.3, 9.0, 3.7, DARK)
		box(chest, 0.9, 1.2, 0.3, -2.3, 9.0, 3.85, MOUTH)
		box(chest, 2.2, 0.5, 1.6, 2.5, 8.5, 4.2, CREAM) -- mushroom shelves
		box(chest, 1.4, 0.5, 1.1, 2.9, 9.4, 4.0, CREAM)
		local function spinePlate(bone, y, z, s)
			box(bone, 1.8 * s, 1.4 * s, 0.9, 0, y, z + 0.35, DARK)
			box(bone, 1.2 * s, 1.1 * s, 0.8, 0, y + 0.2 * s, z + 1.1, RIDGE)
			box(bone, 0.7 * s, 0.8 * s, 0.7, 0, y + 0.35 * s, z + 1.8, CREAM)
			neon(bone, 0.4, 0.4, 0.4, 0, y + 0.45 * s, z + 2.3)
		end
		spinePlate(chest, 8.3, 3.6, 0.85)
		spinePlate(chest, 10.4, 3.6, 1.0)

		------------------------------------------------------------------
		-- Head: the carved face on the top of the trunk
		------------------------------------------------------------------
		local head = B:bone("Head", "Chest", v(0, 11.8, 0.8))
		box(head, 8.6, 5.4, 7.0, 0, 14.4, 0.3, BARK) -- y 11.7..17.1, z -3.2..3.8, face at z=-3.2
		-- light heartwood face mask (stepped) so the face pops against the bark
		box(head, 7.4, 3.6, 0.25, 0, 14.1, -3.32, FACE) -- y 12.3..15.9
		box(head, 5.6, 0.8, 0.25, 0, 16.2, -3.32, FACE) -- forehead step
		spinePlate(head, 13.1, 3.8, 1.05)
		spinePlate(head, 15.4, 3.8, 1.15)
		B:sym(function(side)
			box(head, 0.4, 4.6, 6.0, 4.45, 14.4, 0.5, DARK)
			-- side of the head: knot + stepped mushroom shelves + twig ear with a leaf
			box(head, 1.0, 1.0, 1.0, 4.6, 15.0, -1.2, DARK)
			box(head, 0.4, 0.5, 0.5, 5.15, 15.0, -1.2, MOUTH)
			box(head, 2.4, 0.5, 1.8, 5.1, 13.0, 1.5, CREAM)
			box(head, 1.5, 0.5, 1.2, 4.9, 12.2, 0.2, CREAM)
			B:beam(head, v(4.4, 15.6, 1.2), v(6.0, 16.6, 2.4), 0.8, 0.8, RIDGE)
			box(head, 1.4, 1.0, 1.4, 6.2, 16.8, 2.5, LEAF2)
			-- heavy angled brow with a moss tuft
			local brow = cf(2.05, 16.35, -3.8, 0, 0, 14)
			B:block(head, v(3.4, 1.0, 1.3), brow, DARK)
			B:block(head, v(1.8, 0.45, 1.0), brow * CFrame.new(0.5, 0.65, 0.1), LEAF)
			-- eye: dark socket, big lime glow, goofy pupil offset inward/up
			box(head, 2.8, 2.0, 0.2, 2.0, 14.85, -3.5, MOUTH)
			neon(head, 2.0, 1.3, 0.2, 2.0, 14.8, -3.6, "Eye" .. side)
			box(head, 0.7, 0.95, 0.2, 1.7, 14.95, -3.72, PUPIL)
			box(head, 0.3, 0.3, 0.12, 2.65, 15.2, -3.72, WHITE) -- eye shine
			-- upper teeth: big goofy buck teeth in the middle, then smaller blocks
			box(head, 1.0, 1.2, 0.5, 0.55, 12.95, -3.75, WHITE)
			box(head, 0.7, 0.6, 0.5, 1.65, 13.2, -3.75, WHITE)
			box(head, 0.7, 0.9, 0.5, 2.55, 13.05, -3.75, WHITE)
		end)
		-- knobby nose (sits between the eyes, below the brow line)
		box(head, 1.0, 1.2, 1.0, 0, 14.1, -3.7, RIDGE)
		box(head, 0.8, 0.7, 0.6, 0, 13.85, -4.35, BARK)
		-- carved dark mouth + cavity behind the jaw
		box(head, 6.8, 1.8, 0.3, 0, 12.6, -3.45, MOUTH) -- y 11.7..13.5
		box(head, 6.0, 2.4, 2.4, 0, 11.9, -2.2, MOUTH, { name = "MouthCavity" })
		box(head, 2.8, 1.4, 0.3, 0.4, 12.6, 3.9, LEAF) -- back moss patch

		-- eyelids: hidden, slide down + shown for blinks/squints
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(2.0, 15.9, -3.9))
			box(lid, 3.0, 2.1, 0.25, 2.0, 14.85, -3.9, FACE, { tr = 1, name = "Eyelid" .. side })
		end)

		-- jaw: underbite with big upturned tusks, pink tongue
		local jaw = B:bone("Jaw", "Head", v(0, 12.0, -0.8))
		box(jaw, 6.8, 1.5, 3.6, 0, 11.2, -2.5, BARK) -- y 10.45..11.95, z -4.3..-0.7
		box(jaw, 5.6, 0.3, 2.6, 0, 12.0, -2.2, MOUTH)
		box(jaw, 2.6, 0.4, 1.6, 0, 12.3, -2.8, TONGUE)
		box(jaw, 6.2, 0.4, 3.2, 0, 10.35, -2.5, DARK)
		box(jaw, 5.8, 0.5, 0.25, 0, 11.2, -4.38, FACE) -- chin highlight
		B:sym(function()
			box(jaw, 1.0, 1.6, 0.9, 3.15, 12.45, -3.95, WHITE) -- tusk
			box(jaw, 0.6, 0.5, 0.6, 3.15, 13.45, -3.95, CREAM) -- tusk tip step
			box(jaw, 0.6, 0.6, 0.5, 1.3, 12.2, -4.0, WHITE)
			box(jaw, 0.5, 0.5, 0.5, 2.2, 12.15, -4.0, WHITE)
		end)

		-- mossy beard (stepped like the reference's chest scales)
		local beard = B:bone("Beard", "Jaw", v(0, 10.4, -3.0))
		box(beard, 6.4, 1.2, 1.6, 0, 9.95, -3.3, LEAF)
		box(beard, 5.0, 1.1, 1.4, 0, 8.9, -3.45, LEAF2)
		box(beard, 3.6, 1.0, 1.2, 0, 7.95, -3.4, LEAF)
		box(beard, 2.0, 0.9, 1.0, 0, 7.05, -3.55, LEAF2)
		box(beard, 1.0, 1.0, 0.6, 1.7, 9.95, -4.15, PINK)
		box(beard, 0.45, 0.45, 0.3, 1.7, 9.95, -4.5, PINKC)

		------------------------------------------------------------------
		-- Canopy: 4 shrinking stepped voxel tiers (light highlight tops),
		-- side clumps, back clump with twisting branch antlers
		------------------------------------------------------------------
		local canopy = B:bone("Canopy", "Head", v(0, 17.8, 0.6))
		box(canopy, 11.4, 0.5, 9.4, 0, 17.25, 0.9, DARK) -- underside (y 17.0..17.5)
		-- tier 1 (y 17.5..19.1)
		box(canopy, 13, 1.2, 11, 0, 18.1, 0.9, LEAF)
		box(canopy, 13, 0.4, 11, 0, 18.9, 0.9, LEAF2)
		-- tier 2 (y 19.1..20.6), front edge stepped back
		box(canopy, 10, 1.2, 8.6, 0.3, 19.7, 1.3, LEAF)
		box(canopy, 10, 0.3, 8.6, 0.3, 20.45, 1.3, LEAF2)
		-- tier 3 (y 20.6..21.8)
		box(canopy, 6.6, 0.9, 5.6, -0.3, 21.05, 1.5, LEAF)
		box(canopy, 6.6, 0.3, 5.6, -0.3, 21.65, 1.5, LEAF2)
		-- scalloped edge lumps break up the rectangle (cloud outline)
		B:sym(function()
			box(canopy, 2.2, 1.4, 2.4, 5.7, 17.3, -3.9, LEAF) -- front corner drip
			box(canopy, 1.2, 0.8, 1.2, 5.9, 16.3, -4.1, LEAF2)
			box(canopy, 1.6, 1.4, 3.0, 6.9, 18.2, 4.2, LEAF) -- side bulge
		end)
		-- thin neon edge strips under the tier fronts (calm accents)
		B:sym(function()
			neon(canopy, 2.6, 0.3, 0.3, 3.7, 17.5, -4.65)
		end)
		neon(canopy, 4.0, 0.3, 0.3, 0.3, 19.15, -3.05)
		neon(canopy, 2.4, 0.3, 0.3, -0.3, 20.65, -1.25)

		local leafVol = box(canopy, 12, 1, 10, 0, 17.4, 0.9, LEAF, { tr = 1, name = "CanopyFX" })
		B:emitter(leafVol, "leaf", { name = "Leaves", color = { LEAF2, LEAF }, rate = 4, size = { 0.5, 0.5, 0.3 } })
		B:emitter(leafVol, "leaf", { name = "Petals", color = { PINK, "#ffc8e4" }, rate = 2, size = { 0.45, 0.4, 0.2 } })
		B:emitter(leafVol, "leaf", { name = "LeafBurst", color = { LEAF2, PINK }, rate = 0, speed = { 10, 20 }, spread = 180, size = { 0.8, 0.7, 0.3 }, life = { 1.2, 2.2 }, accel = { 0, -9, 0 } })
		B:emitter(leafVol, "burst", { name = "SparkleBurst", color = { "#ffffff", NEON } })

		-- tier 4 (crown) on its own bone
		local top = B:bone("CanopyTop", "Canopy", v(-0.3, 21.8, 1.5))
		box(top, 3.2, 0.8, 3.0, -0.3, 22.2, 1.6, LEAF2) -- y 21.8..22.6
		box(top, 1.2, 0.5, 1.2, 0.9, 22.2, 0.0, LEAF)
		B:gem(top, v(0.7, 0.7, 0.7), cf(-1.6, 22.15, 0.3), NEON)

		B:sym(function(side)
			local cl = B:bone("Canopy" .. side, "Canopy", v(5.8, 18.6, 0.6))
			box(cl, 3.0, 2.4, 4.0, 7.8, 18.6, 0.4, LEAF) -- x 6.3..9.3, y 17.4..19.8
			box(cl, 3.0, 0.4, 4.0, 7.8, 20.0, 0.4, LEAF2)
			box(cl, 2.4, 0.4, 3.4, 7.8, 17.2, 0.4, DARK)
			box(cl, 2.0, 1.4, 2.8, 7.4, 16.4, 0.9, LEAF) -- stepped lower lump
			box(cl, 1.4, 0.3, 2.2, 7.4, 17.15, 0.9, LEAF2)
		end)

		local back = B:bone("CanopyBack", "Canopy", v(0, 18.4, 5.8))
		box(back, 8.4, 1.8, 2.4, 0, 18.3, 7.2, LEAF) -- z 6.0..8.4
		box(back, 8.4, 0.35, 2.4, 0, 19.35, 7.2, LEAF2)
		box(back, 5.0, 1.2, 1.8, 0, 17.0, 7.0, LEAF)
		box(back, 7.4, 0.4, 2.0, 0, 17.25, 7.25, DARK)
		-- twisting branch antlers stepping thinner, capped by blossoms / buds
		local antlers = {
			{ v(2.6, 19.0, 7.6), v(3.6, 20.2, 9.0), v(4.9, 20.8, 9.9), v(5.6, 21.6, 10.6), "bud" },
			{ v(-2.6, 19.0, 7.6), v(-3.4, 20.0, 9.2), v(-4.8, 20.4, 10.0), v(-5.2, 21.3, 10.9), "bud" },
			{ v(0, 18.8, 8.0), v(0.4, 19.6, 9.7), v(-0.4, 20.2, 11.0), v(-0.2, 21.0, 11.9), "bloom" },
		}
		local antlerTips = {}
		for i, an in antlers do
			B:beam(back, an[1], an[2], 1.1, 1.1, BARK)
			B:beam(back, an[2], an[3], 0.85, 0.85, RIDGE)
			B:beam(back, an[3], an[4], 0.6, 0.6, CREAM)
			if an[5] == "bud" then
				B:gem(back, v(0.7, 0.7, 0.7), CFrame.new(an[4]), NEON)
			else
				antlerTips[i] = an[4]
			end
		end

		-- pink blossom blocks, each on its own sway bone
		local blooms = {
			{ "Canopy", v(3.4, 18.1, -4.75), v(0, 0, -1) },
			{ "Canopy", v(-4.3, 18.3, -4.75), v(0, 0, -1) },
			{ "Canopy", v(-2.5, 19.8, -3.15), v(0, 0, -1) },
			{ "Canopy", v(3.1, 21.1, 0.4), v(1, 0, 0) },
			{ "CanopyR", v(9.45, 18.8, -0.6), v(1, 0, 0) },
			{ "CanopyR", v(7.9, 20.3, 1.6), v(0, 1, 0) },
			{ "CanopyL", v(-9.45, 18.4, 1.3), v(-1, 0, 0) },
			{ "CanopyL", v(-7.6, 20.3, -0.6), v(0, 1, 0) },
			{ "CanopyBack", v(-2.6, 18.5, 8.55), v(0, 0, 1) },
			{ "CanopyBack", v(2.9, 17.4, 8.4), v(0, 0, 1) },
			{ "Canopy", v(6.65, 18.4, 1.0), v(1, 0, 0) },
			{ "CanopyBack", antlerTips[3], v(0, 1, 0) },
		}
		for i, bl in blooms do
			local bb = B:bone("Bloom" .. i, bl[1], bl[2])
			B:block(bb, v(1.5, 1.5, 1.5), CFrame.new(bl[2]), PINK)
			B:block(bb, v(0.7, 0.7, 0.7), CFrame.new(bl[2] + bl[3] * 0.62), PINKC)
		end

		------------------------------------------------------------------
		-- Branch arms (3 bones each), splayed out, chunky twig hands
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Chest", v(4.6, 10.6, 0.5))
			box(arm, 2.8, 2.8, 3.0, 5.6, 10.4, 0.5, BARK) -- shoulder x 4.2..7.0
			box(arm, 0.4, 2.0, 2.2, 7.05, 10.4, 0.5, DARK)
			box(arm, 3.4, 0.8, 3.4, 5.7, 12.0, 0.5, LEAF) -- mossy pauldron
			box(arm, 2.2, 0.5, 2.4, 5.8, 12.6, 0.6, LEAF2)
			B:beam(arm, v(6.2, 12.4, 1.0), v(7.4, 14.0, 1.8), 0.7, 0.7, RIDGE)
			B:gem(arm, v(0.7, 0.7, 0.7), cf(7.5, 14.2, 1.9), NEON)
			B:beam(arm, v(6.0, 10.0, 0.4), v(7.2, 8.4, -0.6), 2.0, 2.0, BARK) -- upper arm

			local fore = B:bone("Forearm" .. side, "Arm" .. side, v(7.2, 8.4, -0.6))
			box(fore, 2.4, 2.2, 2.4, 7.2, 8.4, -0.6, BARK) -- elbow knot
			box(fore, 0.4, 1.6, 1.8, 8.45, 8.4, -0.6, DARK)
			B:beam(fore, v(7.2, 8.4, -0.6), v(7.6, 6.6, -1.3), 1.9, 1.9, BARK)
			box(fore, 2.2, 0.6, 2.2, 7.45, 7.3, -1.0, LEAF) -- moss band
			neon(fore, 0.3, 0.9, 0.3, 8.55, 7.8, -0.8) -- sap vein
			B:beam(fore, v(7.7, 9.0, 0.0), v(8.7, 10.2, 1.0), 0.6, 0.6, RIDGE) -- elbow sprout
			box(fore, 1.2, 0.6, 1.2, 8.8, 10.4, 1.1, LEAF2)
			B:spike(fore, v(7.4, 7.6, -0.2), v(8.0, 8.0, 1.2), 0.6, 0.6, CREAM) -- elbow thorn

			local hand = B:bone("Hand" .. side, "Forearm" .. side, v(7.6, 6.4, -1.4))
			box(hand, 2.8, 2.2, 2.8, 7.7, 5.5, -1.6, BARK) -- y 4.4..6.6
			box(hand, 2.4, 0.5, 0.4, 7.7, 6.05, -3.05, RIDGE) -- knuckle strip
			box(hand, 0.4, 1.6, 2.2, 9.15, 5.5, -1.6, DARK)
			for k = -1, 1 do
				local a = v(7.7 + k * 0.9, 4.8, -2.4)
				local b = v(7.7 + k * 1.3, 3.7, -3.6)
				B:beam(hand, a, b, 0.9, 0.9, k == 0 and RIDGE or BARK)
				local d = (b - a).Unit
				B:block(hand, v(0.8, 0.8, 0.8), CFrame.lookAt(b + d * 0.35, b + d * 2), CREAM)
			end
			local ta, tb = v(6.4, 5.2, -2.4), v(5.9, 4.6, -3.5)
			B:beam(hand, ta, tb, 0.9, 0.9, BARK)
			local td = (tb - ta).Unit
			B:block(hand, v(0.75, 0.75, 0.75), CFrame.lookAt(tb + td * 0.3, tb + td * 2), CREAM)
			B:trail(hand, v(7.7, 3.0, -4.3), v(7.7, 4.4, -3.2), { name = "ClawTrail", color = { NEON, LEAF2 }, life = 0.3, trans = { 0.45, 1 } })
		end)

		------------------------------------------------------------------
		-- Floating voxel cubes (VFX) out on the flanks at radius ~12
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 10.5, 0.5))
		-- {x, y, z, size, main, cap/accent, style}
		local spots = {
			{ 12.0, 13.0, -1.0, 1.6, PINK, PINKC, "chunk" },
			{ -12.0, 10.0, 2.0, 1.4, BARK, LEAF2, "cap" },
			{ 10.5, 6.5, 7.5, 1.3, LEAF2, PINK, "chunk" },
			{ -10.0, 16.0, -4.0, 1.5, PINK, CREAM, "chunk" },
			{ 3.0, 15.5, 11.5, 1.3, BARK, LEAF2, "cap" },
		}
		for i, s in spots do
			local p = v(s[1], s[2], s[3])
			local sz = s[4]
			local ob = B:bone("Orb" .. i, "Orbit", p)
			B:block(ob, v(sz, sz, sz), CFrame.new(p), s[5])
			if s[7] == "cap" then
				B:block(ob, v(sz + 0.2, sz * 0.4, sz + 0.2), CFrame.new(p + v(0, sz * 0.6, 0)), s[6])
			else
				B:block(ob, v(sz * 0.55, sz * 0.55, sz * 0.55), CFrame.new(p + v(sz * 0.35, sz * 0.35, -sz * 0.35)), s[6])
			end
			if i == 1 or i == 4 then
				B:block(ob, v(sz + 0.1, 0.25, sz + 0.1), CFrame.new(p - v(0, sz * 0.2, 0)), NEON, { mat = "Neon" })
			end
		end
		local fly = box(orbit, 18, 12, 14, 0, 11, 0.5, LEAF, { tr = 1, name = "FireflyVolume" })
		B:emitter(fly, "sparkle", { name = "Fireflies", color = { "#f4ffc0", NEON }, rate = 5, life = { 1.5, 3 }, speed = { 0.2, 0.8 }, size = { 0.12, 0.35, 0 } })

		------------------------------------------------------------------
		-- Roar FX (petals blown out of the mouth) + mouth light
		------------------------------------------------------------------
		local roarAt = box(head, 3, 1, 1, 0, 12.2, -4.6, MOUTH, { tr = 1, name = "RoarFX" })
		B:emitter(roarAt, "leaf", { name = "RoarPetals", color = { PINK, "#ffd6ea" }, rate = 34, speed = { 9, 15 }, spread = 25, dir = "Front", enabled = false, accel = { 0, -3, 0 }, size = { 0.55, 0.5, 0.25 } })
		B:light(roarAt, { name = "MouthLight", color = NEON, brightness = 0.01, range = 12 })

		------------------------------------------------------------------
		-- Stepped root spikes that erupt from the ground on the stomp
		------------------------------------------------------------------
		local ground = box(B.root, 26, 0.4, 24, 0, 0.2, -1.0, BARK, { tr = 1, name = "GroundFX" })
		B:emitter(ground, "dust", { name = "RootDust", color = "#cdb58c", size = { 1.2, 2.4, 3 }, speed = { 3, 7 } })
		local ringAng = { -62, -30, 0, 30, 62, 105, -105 }
		for i, a in ringAng do
			local r = (i >= 6) and 12.0 or 11.5
			local rad = math.rad(a)
			local x, z = r * math.sin(rad), -r * math.cos(rad)
			local out = v(x, 0, z).Unit
			local axis = v(out.Z, 0, -out.X) -- tilting about this leans away from the treant
			local base = CFrame.new(x, 0, z) * CFrame.fromAxisAngle(axis, math.rad(12))
			local sp = B:bone("Sprout" .. i, "Root", base)
			local step = CFrame.fromAxisAngle(axis, math.rad(20))
			local c2 = base * CFrame.new(0, 2.0, 0) * step
			local c3 = c2 * CFrame.new(0, 1.6, 0) * step
			B:block(sp, v(1.8, 2.0, 1.8), base * CFrame.new(0, 1.0, 0), BARK, { tr = 1, name = "Sprout" .. i .. "a" })
			B:block(sp, v(1.2, 1.6, 1.2), c2 * CFrame.new(0, 0.7, 0), i % 2 == 0 and RIDGE or DARK, { tr = 1, name = "Sprout" .. i .. "b" })
			B:block(sp, v(0.6, 1.0, 0.6), c3 * CFrame.new(0, 0.4, 0), CREAM, { tr = 1, name = "Sprout" .. i .. "c" })
			B:block(sp, v(0.35, 0.35, 0.35), c3 * CFrame.new(0, 1.05, 0), NEON, { mat = "Neon", tr = 1, name = "Sprout" .. i .. "d" })
		end
	end,
}
