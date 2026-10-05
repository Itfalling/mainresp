--!nocheck
-- Elder Treant: a stud-built walking oak. Chunky bark trunk with a big carved
-- cartoon face (mossy brows, lime slit eyes, buck teeth, upturned tusks, mossy
-- beard), a huge stepped voxel canopy with pink blossom blocks on sway bones,
-- long branch arms with twig fingers and splayed root feet. Calm neon: only
-- the eyes, a few bud tips and thin sap veins glow.
return {
	DisplayName = "Elder Treant",
	Rarity = "Legendary",
	Element = "Nature",
	Build = function(B, P)
		local v, cf = P.v, P.cf

		-- palette
		local BARK, DARK, RIDGE = "#7a5230", "#4e341e", "#9a6d42"
		local CREAM = "#ecd9a6" -- light contrast: claws, toe tips
		local FACE = "#c4925a" -- heartwood face mask
		local MOSS, MOSSD = "#4f9a3a", "#3b7d2b"
		local LEAF, LEAF2, LEAFD = "#4fae3a", "#7ad15a", "#3a8a2c"
		local PINK, PINKC = "#ff8fc8", "#fff1a8"
		local WHITE, MOUTH, TONGUE = "#f7f2e2", "#1c120b", "#d9507a"
		local NEON = "#c6ff5c"

		local function box(bone, sx, sy, sz, x, y, z, col, opts)
			return B:block(bone, v(sx, sy, sz), cf(x, y, z), col, opts)
		end

		-- a tapered claw/tip continuing the direction a -> b
		local function tip(bone, a, b, len, w, col)
			local d = (b - a).Unit
			return B:spike(bone, b - d * 0.25, b + d * len, w, w, col)
		end

		------------------------------------------------------------------
		-- Hips (lower trunk)
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 6.2, 0.5))
		box(hips, 7.2, 3.0, 5.8, 0, 6.1, 0.5, BARK) -- y 4.6..7.6
		box(hips, 6.4, 0.6, 5.2, 0, 4.5, 0.5, DARK)
		B:sym(function()
			box(hips, 0.4, 2.4, 4.8, 3.65, 6.0, 0.5, DARK)
			box(hips, 0.8, 2.2, 0.3, 2.0, 6.0, -2.45, RIDGE)
		end)

		------------------------------------------------------------------
		-- Root legs (thigh -> shin -> foot -> toes)
		------------------------------------------------------------------
		B:sym(function(side)
			local th = B:bone("Thigh" .. side, "Hips", v(2.4, 5.6, 0.6))
			box(th, 3.0, 3.2, 3.2, 2.6, 4.4, 0.6, BARK) -- y 2.8..6.0
			box(th, 0.4, 2.4, 2.6, 4.15, 4.4, 0.6, DARK)
			box(th, 1.0, 2.2, 0.3, 2.6, 4.3, -1.05, RIDGE)

			local sh = B:bone("Shin" .. side, "Thigh" .. side, v(2.7, 2.9, 0.6))
			box(sh, 2.6, 2.2, 2.8, 2.75, 2.0, 0.5, BARK) -- y 0.9..3.1
			box(sh, 3.2, 0.8, 3.4, 2.75, 3.0, 0.5, MOSS) -- mossy knee cuff
			B:spike(sh, v(2.75, 3.0, -1.0), v(2.75, 3.5, -2.3), 0.6, 0.6, CREAM) -- knee thorn

			local ft = B:bone("Foot" .. side, "Shin" .. side, v(2.8, 1.1, 0.4))
			box(ft, 3.8, 1.2, 4.2, 2.9, 0.6, 0.1, BARK) -- y 0..1.2
			box(ft, 2.6, 0.5, 1.8, 2.9, 1.3, -1.1, MOSS)
			B:beam(ft, v(3.0, 0.6, 1.6), v(3.7, 0.4, 3.5), 1.1, 0.8, DARK) -- back root spur

			local toe = B:bone("Toe" .. side, "Foot" .. side, v(2.9, 0.6, -1.7))
			for k = -1, 1 do
				local a = v(2.9 + k * 1.15, 0.5, -1.6)
				local b = v(2.9 + k * 1.9, 0.45, -3.5 + math.abs(k) * 0.5)
				B:beam(toe, a, b, 0.95, 0.9, BARK)
				local d = (b - a).Unit
				B:wedge(toe, v(0.8, 0.7, 1.0), CFrame.lookAt(b + d * 0.35, b + d * 2) * CFrame.new(0, -0.08, 0), CREAM)
			end
			if side == "R" then
				local dustAt = box(ft, 3.6, 0.3, 4, 2.9, 0.15, 0.1, BARK, { tr = 1, name = "StompFX" })
				B:emitter(dustAt, "dust", { name = "StompDust", color = "#cdb58c" })
			end
		end)

		------------------------------------------------------------------
		-- Chest (upper trunk) + mossy collar
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Hips", v(0, 7.4, 0.5))
		box(chest, 7.8, 4.6, 6.2, 0, 9.6, 0.5, BARK) -- y 7.3..11.9, z -2.6..3.6
		box(chest, 9.0, 1.4, 7.6, 0, 11.8, 0.5, MOSS) -- collar (covers the neck seam)
		B:sym(function()
			box(chest, 0.4, 3.8, 5.2, 4.05, 9.5, 0.6, DARK)
			box(chest, 0.9, 3.4, 0.3, 3.0, 9.3, -2.75, RIDGE)
			box(chest, 1.2, 1.0, 0.5, 3.6, 10.7, -2.9, MOSS) -- moss drip
			box(chest, 1.4, 1.2, 0.5, 2.4, 10.6, 3.95, MOSS)
		end)
		-- back: knot hole, moss patch, branch stub with a leaf tuft, twig spines
		box(chest, 1.8, 2.2, 0.3, -1.4, 9.2, 3.7, DARK)
		box(chest, 0.9, 1.2, 0.3, -1.4, 9.2, 3.85, MOUTH)
		box(chest, 2.6, 1.2, 0.3, 1.5, 8.2, 3.7, MOSS)
		box(chest, 0.8, 3.4, 0.3, 0.6, 9.8, 3.7, RIDGE)
		box(chest, 0.8, 2.6, 0.3, -2.9, 9.4, 3.7, RIDGE)
		B:beam(chest, v(1.6, 10.2, 3.2), v(2.8, 11.6, 5.4), 0.9, 0.9, RIDGE)
		box(chest, 1.8, 1.4, 1.8, 2.9, 11.9, 5.5, LEAF2)
		B:beam(chest, v(-0.6, 8.0, 3.3), v(-0.9, 8.9, 5.0), 0.7, 0.7, RIDGE)
		B:gem(chest, v(0.45, 0.45, 0.45), cf(-0.95, 9.05, 5.15), NEON)

		------------------------------------------------------------------
		-- Head: the carved face on the top of the trunk
		------------------------------------------------------------------
		local head = B:bone("Head", "Chest", v(0, 11.8, 0.8))
		box(head, 8.6, 5.4, 7.0, 0, 14.4, 0.3, BARK) -- y 11.7..17.1, z -3.2..3.8, face at z=-3.2
		-- light heartwood face mask (stepped) so the face pops against the bark
		box(head, 7.0, 3.4, 0.25, 0, 14.0, -3.32, FACE) -- y 12.3..15.7
		box(head, 5.4, 0.8, 0.25, 0, 16.0, -3.32, FACE) -- forehead step
		B:sym(function()
			box(head, 0.4, 4.6, 6.0, 4.45, 14.4, 0.5, DARK)
			-- side of the head: bark grain + a little twig "ear" with a leaf
			box(head, 0.3, 3.0, 0.8, 4.75, 14.0, 2.2, RIDGE)
			box(head, 0.3, 1.2, 2.0, 4.75, 12.7, -0.4, MOSS)
			B:beam(head, v(4.4, 14.6, 0.6), v(5.9, 15.5, 1.8), 0.7, 0.7, RIDGE)
			box(head, 1.3, 0.8, 1.3, 6.0, 15.7, 1.9, LEAF2)
			-- heavy angled brow with a moss tuft
			local brow = cf(2.0, 16.25, -3.75, 0, 0, 14)
			B:block(head, v(3.2, 1.0, 1.3), brow, DARK)
			B:block(head, v(1.6, 0.45, 1.0), brow * CFrame.new(0.5, 0.65, 0.1), MOSS)
			-- eye: dark socket, lime slit, dark pupil
			box(head, 2.6, 1.8, 0.2, 1.9, 14.85, -3.5, MOUTH)
			box(head, 1.8, 1.0, 0.2, 1.9, 14.8, -3.6, NEON, { mat = "Neon", name = "Eye" })
			box(head, 0.6, 1.0, 0.2, 1.75, 14.8, -3.7, MOUTH)
			-- upper teeth: big goofy buck teeth in the middle
			box(head, 0.9, 1.1, 0.5, 0.5, 12.95, -3.75, WHITE)
			box(head, 0.7, 0.6, 0.5, 1.6, 13.2, -3.75, WHITE)
			box(head, 0.7, 0.9, 0.5, 2.6, 13.05, -3.75, WHITE)
		end)
		-- knobby nose
		box(head, 1.4, 1.6, 1.2, 0, 14.3, -3.8, RIDGE)
		box(head, 1.0, 1.0, 0.6, 0, 14.1, -4.6, BARK)
		-- carved dark mouth + cavity behind the jaw
		box(head, 6.6, 1.8, 0.3, 0, 12.6, -3.45, MOUTH) -- y 11.7..13.5
		box(head, 6.0, 2.4, 2.4, 0, 11.9, -2.2, MOUTH, { name = "MouthCavity" })
		-- back of the head: bark grain, moss patch, a twig spine with a glowing bud
		box(head, 0.8, 3.6, 0.3, -1.6, 14.4, 3.9, RIDGE)
		box(head, 0.8, 2.4, 0.3, 2.2, 13.8, 3.9, RIDGE)
		box(head, 2.8, 1.4, 0.3, 0.4, 12.6, 3.9, MOSS)
		B:beam(head, v(0.4, 15.0, 3.5), v(0.6, 16.4, 5.3), 0.7, 0.7, RIDGE)
		B:gem(head, v(0.45, 0.45, 0.45), cf(0.62, 16.55, 5.45), NEON)

		-- eyelids (hidden behind the brows, drop for blinks)
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(1.9, 16.0, -3.7))
			box(lid, 2.7, 1.9, 0.3, 1.9, 16.7, -3.72, FACE)
		end)

		-- jaw: underbite with big upturned tusks, pink tongue
		local jaw = B:bone("Jaw", "Head", v(0, 12.0, -0.8))
		box(jaw, 6.8, 1.5, 3.6, 0, 11.2, -2.5, BARK) -- y 10.45..11.95, z -4.3..-0.7
		box(jaw, 5.6, 0.3, 2.6, 0, 12.0, -2.2, MOUTH)
		box(jaw, 2.6, 0.3, 1.6, 0, 12.15, -2.0, TONGUE)
		box(jaw, 6.2, 0.4, 3.2, 0, 10.35, -2.5, DARK)
		box(jaw, 5.6, 0.5, 0.25, 0, 11.2, -4.38, FACE) -- chin highlight
		B:sym(function()
			box(jaw, 0.9, 1.5, 0.8, 3.15, 12.4, -3.95, WHITE) -- tusk
			box(jaw, 0.6, 0.4, 0.6, 3.15, 13.3, -3.95, CREAM) -- tusk tip step
			box(jaw, 0.6, 0.6, 0.5, 1.3, 12.2, -4.0, WHITE)
		end)

		-- mossy beard (stepped like the reference's chest scales)
		local beard = B:bone("Beard", "Jaw", v(0, 10.4, -3.0))
		box(beard, 6.4, 1.2, 1.6, 0, 9.95, -3.3, MOSS)
		box(beard, 5.0, 1.1, 1.4, 0, 8.9, -3.35, MOSSD)
		box(beard, 3.6, 1.0, 1.2, 0, 7.95, -3.4, MOSS)
		box(beard, 2.0, 0.9, 1.0, 0, 7.05, -3.45, MOSSD)
		box(beard, 0.9, 0.9, 0.6, 1.6, 9.05, -4.1, PINK)
		box(beard, 0.4, 0.4, 0.3, 1.6, 9.05, -4.45, PINKC)

		------------------------------------------------------------------
		-- Canopy: puffy stepped voxel cloud with sway bones
		------------------------------------------------------------------
		local canopy = B:bone("Canopy", "Head", v(0, 17.0, 0.4))
		box(canopy, 10.4, 1.0, 9.0, 0, 17.3, 0.5, LEAFD) -- skirt y 16.8..17.8
		box(canopy, 12.0, 2.6, 10.4, 0, 19.0, 0.5, LEAF) -- core y 17.7..20.3
		-- front fringe over the brows
		B:sym(function()
			box(canopy, 3.2, 1.6, 1.4, 2.6, 18.7, -5.0, LEAF2)
			box(canopy, 1.6, 1.2, 1.4, 5.1, 17.4, -4.2, LEAFD)
		end)
		box(canopy, 2.0, 1.2, 1.2, 0, 18.9, -5.0, LEAF)
		local leafVol = box(canopy, 12, 1, 10, 0, 17.4, 0.4, LEAF, { tr = 1, name = "CanopyFX" })
		B:emitter(leafVol, "leaf", { name = "Leaves", color = { LEAF2, LEAF }, rate = 4, size = { 0.5, 0.5, 0.3 } })
		B:emitter(leafVol, "leaf", { name = "Petals", color = { PINK, "#ffc8e4" }, rate = 1.5, size = { 0.4, 0.4, 0.2 } })
		B:emitter(leafVol, "leaf", { name = "LeafBurst", color = { LEAF2, LEAF }, rate = 0, speed = { 9, 18 }, spread = 180, size = { 0.7, 0.6, 0.3 }, life = { 1.2, 2.2 }, accel = { 0, -8, 0 } })
		B:emitter(leafVol, "burst", { name = "SparkleBurst", color = { "#ffffff", NEON } })

		-- top lumps: uneven heights make a cloud silhouette
		local top = B:bone("CanopyTop", "Canopy", v(0, 20.2, 0.5))
		box(top, 4.6, 2.2, 4.4, -2.5, 21.3, -0.3, LEAF2) -- y 20.2..22.4
		box(top, 4.2, 1.6, 4.0, 2.4, 21.0, 0.0, LEAF2)
		box(top, 3.8, 1.6, 3.6, 0.2, 21.0, 3.5, LEAF)
		box(top, 3.0, 1.0, 2.6, 1.0, 20.7, -3.2, LEAF)
		B:beam(top, v(3.0, 21.2, 0.2), v(3.9, 22.4, -0.4), 0.6, 0.6, RIDGE)
		B:gem(top, v(0.5, 0.5, 0.5), cf(4.0, 22.6, -0.5), NEON)
		B:beam(top, v(-3.8, 21.8, 1.0), v(-4.7, 22.6, 1.8), 0.6, 0.6, RIDGE)
		B:gem(top, v(0.5, 0.5, 0.5), cf(-4.8, 22.75, 1.9), NEON)

		B:sym(function(side)
			local cl = B:bone("Canopy" .. side, "Canopy", v(5.4, 18.6, 0.4))
			box(cl, 3.0, 3.0, 4.0, 6.8, 19.1, -0.6, LEAF2) -- x 5.3..8.3, y 17.6..20.6
			box(cl, 2.4, 0.6, 3.4, 6.8, 17.4, -0.6, LEAFD)
			box(cl, 2.4, 2.2, 3.0, 6.6, 17.8, 2.8, LEAF) -- lower back lump
		end)

		local back = B:bone("CanopyBack", "Canopy", v(0, 18.5, 5.0))
		box(back, 4.2, 2.6, 2.4, -2.2, 18.6, 6.6, LEAF2)
		box(back, 3.2, 2.2, 2.2, 2.4, 19.4, 6.4, LEAF)
		box(back, 3.0, 1.4, 2.0, 0.4, 17.3, 6.2, LEAFD)
		B:beam(back, v(0, 20.0, 5.6), v(0.3, 21.4, 7.2), 0.6, 0.6, RIDGE)
		B:gem(back, v(0.5, 0.5, 0.5), cf(0.35, 21.6, 7.4), NEON)

		-- pink blossom blocks, each on its own sway bone
		local blooms = {
			{ "Canopy", v(3.8, 19.2, -4.85), v(0, 0, -1) },
			{ "Canopy", v(-3.6, 19.6, -4.85), v(0, 0, -1) },
			{ "CanopyR", v(8.3, 19.6, -1.2), v(1, 0, 0) },
			{ "CanopyL", v(-7.8, 17.6, 2.6), v(-1, 0, 0) },
			{ "CanopyTop", v(2.6, 21.85, -0.6), v(0, 1, 0) },
			{ "CanopyTop", v(-1.2, 22.25, -1.4), v(0, 1, 0) },
			{ "CanopyBack", v(-2.4, 19.0, 7.8), v(0, 0, 1) },
		}
		for i, bl in blooms do
			local bb = B:bone("Bloom" .. i, bl[1], bl[2])
			B:block(bb, v(1.3, 1.3, 1.3), CFrame.new(bl[2]), PINK)
			B:block(bb, v(0.6, 0.6, 0.6), CFrame.new(bl[2] + bl[3] * 0.65), PINKC)
		end

		------------------------------------------------------------------
		-- Branch arms (3 bones each) with twig fingers
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Chest", v(4.4, 10.6, 0.5))
			box(arm, 2.8, 2.8, 3.0, 5.2, 10.4, 0.5, BARK) -- shoulder
			box(arm, 0.4, 2.0, 2.2, 6.65, 10.4, 0.5, DARK)
			box(arm, 3.2, 0.8, 3.4, 5.3, 12.0, 0.5, MOSS) -- mossy pauldron
			box(arm, 2.2, 0.6, 2.4, 5.4, 12.6, 0.6, LEAF2)
			B:beam(arm, v(5.8, 12.4, 1.0), v(7.0, 14.0, 1.8), 0.6, 0.6, RIDGE)
			B:gem(arm, v(0.5, 0.5, 0.5), cf(7.1, 14.2, 1.9), NEON)
			B:beam(arm, v(5.6, 10.0, 0.4), v(6.6, 7.0, -0.2), 2.0, 2.0, BARK) -- upper arm

			local fore = B:bone("Forearm" .. side, "Arm" .. side, v(6.6, 7.2, -0.2))
			box(fore, 2.3, 2.1, 2.3, 6.6, 7.2, -0.2, BARK) -- elbow knot
			box(fore, 0.4, 1.5, 1.7, 7.8, 7.2, -0.2, DARK)
			B:beam(fore, v(6.6, 7.2, -0.2), v(7.0, 4.6, -0.9), 1.8, 1.8, BARK)
			box(fore, 2.0, 0.6, 2.0, 6.9, 5.6, -0.65, MOSS) -- moss band
			box(fore, 0.25, 1.6, 0.3, 7.82, 6.4, -0.55, NEON, { mat = "Neon" }) -- sap vein
			B:beam(fore, v(7.1, 7.6, 0.4), v(8.0, 8.8, 1.5), 0.5, 0.5, RIDGE) -- elbow sprout
			B:spike(fore, v(7.0, 5.9, 0.0), v(7.6, 6.4, 1.2), 0.5, 0.5, CREAM) -- forearm thorn
			box(fore, 1.2, 0.5, 1.2, 8.1, 9.0, 1.6, LEAF2)

			local hand = B:bone("Hand" .. side, "Forearm" .. side, v(7.0, 4.7, -0.9))
			box(hand, 2.4, 1.8, 2.4, 7.05, 4.1, -1.0, BARK) -- y 3.2..5.0
			box(hand, 2.0, 0.5, 0.4, 7.05, 4.5, -2.25, RIDGE)
			for k = -1, 1 do
				local a = v(7.05 + k * 0.75, 3.5, -1.7)
				local b = v(7.15 + k * 1.3, 2.3, -3.1)
				B:beam(hand, a, b, 0.7, 0.7, BARK)
				tip(hand, a, b, 0.9, 0.6, CREAM)
			end
			local ta, tb = v(6.0, 3.9, -1.6), v(5.4, 3.0, -2.6)
			B:beam(hand, ta, tb, 0.7, 0.7, BARK)
			tip(hand, ta, tb, 0.8, 0.6, CREAM)
			B:trail(hand, v(7.1, 1.9, -3.5), v(7.1, 3.3, -2.4), { name = "ClawTrail", color = { NEON, LEAF2 }, life = 0.3, trans = { 0.45, 1 } })
		end)

		------------------------------------------------------------------
		-- Floating voxel leaf cubes (VFX)
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 10.5, 0.5))
		local spots = {
			{ 9.8, 12.0, -1.0, 1.6, LEAF2, LEAFD },
			{ -9.6, 9.0, 2.0, 1.4, LEAF, LEAF2 },
			{ 7.0, 6.0, 7.0, 1.2, PINK, PINKC },
			{ -7.0, 14.5, -5.5, 1.5, LEAF2, LEAF },
			{ 3.5, 4.0, -8.5, 1.2, LEAF, LEAF2 },
		}
		for i, s in spots do
			local p = v(s[1], s[2], s[3])
			local ob = B:bone("Orb" .. i, "Orbit", p)
			B:block(ob, v(s[4], s[4], s[4]), CFrame.new(p), s[5])
			B:block(ob, v(s[4] * 0.55, s[4] * 0.55, s[4] * 0.55), CFrame.new(p + v(s[4] * 0.35, s[4] * 0.35, -s[4] * 0.35)), s[6])
			if i == 1 or i == 4 then
				B:block(ob, v(s[4] + 0.1, 0.25, s[4] + 0.1), CFrame.new(p - v(0, s[4] * 0.2, 0)), NEON, { mat = "Neon" })
			end
		end
		local fly = box(orbit, 16, 12, 12, 0, 11, 0.5, LEAF, { tr = 1, name = "FireflyVolume" })
		B:emitter(fly, "sparkle", { name = "Fireflies", color = { "#f4ffc0", NEON }, rate = 5, life = { 1.5, 3 }, speed = { 0.2, 0.8 }, size = { 0.12, 0.35, 0 } })

		------------------------------------------------------------------
		-- Roar FX (petals blown out of the mouth) + mouth light
		------------------------------------------------------------------
		local roarAt = box(head, 3, 1, 1, 0, 12.2, -4.6, MOUTH, { tr = 1, name = "RoarFX" })
		B:emitter(roarAt, "leaf", { name = "RoarPetals", color = { PINK, "#ffd6ea" }, rate = 30, speed = { 8, 14 }, spread = 25, dir = "Front", enabled = false, accel = { 0, -3, 0 } })
		B:light(roarAt, { name = "MouthLight", color = NEON, brightness = 0, range = 12 })

		------------------------------------------------------------------
		-- Root sprouts that erupt from the ground on the stomp (hidden at rest)
		------------------------------------------------------------------
		local ground = box(B.root, 18, 0.4, 16, 0, 0.2, -1.0, BARK, { tr = 1, name = "GroundFX" })
		B:emitter(ground, "leaf", { name = "GroundLeaves", color = { LEAF2, PINK }, rate = 0, speed = { 6, 12 }, spread = 40, life = { 1, 2 }, accel = { 0, -10, 0 }, size = { 0.6, 0.5, 0.3 } })
		local ringAng = { -60, -28, 4, 34, 62, 100, -100 }
		for i, a in ringAng do
			local r = (i >= 6) and 8.4 or 8.0
			local rad = math.rad(a)
			local x, z = r * math.sin(rad), -r * math.cos(rad)
			local out = v(x, 0, z).Unit
			local tilt = CFrame.fromAxisAngle(v(out.Z, 0, -out.X), math.rad(16)) -- lean away from the treant
			local base = CFrame.new(x, 0, z) * tilt
			local sp = B:bone("Sprout" .. i, "Root", base)
			local yaw = P.ang(0, 25 * i, 0)
			B:block(sp, v(1.7, 2.2, 1.7), base * CFrame.new(0, 1.0, 0) * yaw, BARK, { tr = 1, name = "Sprout" .. i .. "a" })
			B:block(sp, v(1.1, 1.5, 1.1), base * CFrame.new(0.15, 2.7, 0) * yaw, RIDGE, { tr = 1, name = "Sprout" .. i .. "b" })
			B:block(sp, v(1.9, 1.0, 1.9), base * CFrame.new(0.2, 3.8, 0) * yaw, i % 2 == 0 and PINK or LEAF2, { tr = 1, name = "Sprout" .. i .. "c" })
		end
	end,
}
