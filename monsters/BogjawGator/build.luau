--!nocheck
-- Bogjaw Gator (Guardian #7, Secret): a huge stud-built swamp alligator that
-- guards a bog garden growing on its own back.
-- Olive swamp-green stepped body with dark gator bands, a pale yellow-green
-- belly of stepped plates, three rows of raised stepped back scutes, a double
-- tail crest, a long chunky snout lined with neat white block teeth, big amber
-- eyes on raised eye bumps under heavy brows and lazy half-lids.
-- Bog garden: moss mats, lily pads, a little pink flower and a swaying cattail;
-- algae drips hang off the lips. The tail tip curls up into a driftwood hook
-- that carries a swinging swamp lantern (the one warm neon accent).
-- Faces -Z, feet on Y=0. Rest pose = neutral "standing" stance; Idle sinks low.
return {
	DisplayName = "Bogjaw Gator",
	Rarity = "Secret",
	Element = "Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local MAIN, DARK, DEEP = "#5b7f2e", "#3a5620", "#26391a"
		local BELLY, BELLY2, SCUTE = "#e6eba6", "#c9d47f", "#e2d896"
		local MOSS, MOSS2, LILY, LILY2 = "#8cc43a", "#5f9a2a", "#3f9c3c", "#2b7430"
		local PINK, PINK2, POLLEN = "#ff74b4", "#ffc2de", "#ffd84a"
		local WOOD, WOOD2, IRON = "#6b4a2a", "#46301b", "#2b2b30"
		local TEETH, MOUTH, PALATE, TONGUE = "#f7f5e6", "#15100c", "#d65a74", "#ef8299"
		local AMBER, SLIT, RED = "#ffc21f", "#120d06", "#e8343a"
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- helpers
		------------------------------------------------------------------
		-- one body chunk: olive core, dark back stripe, pale belly band wrapping
		-- the lower sides with a dark seam, dark gator bands across the flanks,
		-- stepped belly plates underneath
		local function segment(bone, z0, z1, yc, w, h, bands, plates)
			local len, zc = z1 - z0, (z0 + z1) / 2
			B:block(bone, v(w, h, len), cf(0, yc, zc), MAIN)
			B:block(bone, v(w * 0.62, 0.3, len - 0.3), cf(0, yc + h / 2 + 0.1, zc), DARK)
			local bh = h * 0.42
			B:block(bone, v(w + 0.12, bh, len - 0.25), cf(0, yc - h / 2 + bh / 2 - 0.05, zc), BELLY)
			B:block(bone, v(w + 0.18, 0.25, len - 0.35), cf(0, yc - h / 2 + bh - 0.05, zc), DARK)
			for _, bz in bands or {} do
				B:block(bone, v(w + 0.1, h * 0.4, 0.7), cf(0, yc + h * 0.14, zc + bz), DARK)
			end
			if plates then
				local n = math.max(1, math.floor(len / 1.1))
				for i = 1, n do
					local z = z0 + (i - 0.5) * len / n
					B:block(bone, v(w * 0.68, 0.3, len / n - 0.15), cf(0, yc - h / 2 - 0.12, z), i % 2 == 0 and BELLY2 or BELLY)
				end
			end
		end

		-- raised stepped scute: dark base + light cap (y = surface under it)
		local function scute(bone, x, y, z, s)
			B:block(bone, v(s, 0.5, s), cf(x, y + 0.25, z), DEEP)
			B:block(bone, v(s * 0.6, 0.4, s * 0.6), cf(x, y + 0.68, z + 0.05), SCUTE)
		end

		------------------------------------------------------------------
		-- BODY (hips / rear torso) - the root of the whole rig
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 4.2, 1.5))
		segment(body, -0.5, 4.6, 4.1, 6.0, 3.8, { -1.2, 1.4 }, true)
		-- outer scute rows beside the garden
		for _, z in { 0.4, 1.8, 3.2 } do
			B:sym(function()
				scute(body, 2.45, 6.0, z, 0.8)
			end)
		end
		-- bog garden: stepped moss mat with tufts hanging over the flanks
		B:block(body, v(4.0, 0.45, 4.2), cf(0, 6.45, 2.0), MOSS)
		B:block(body, v(2.6, 0.35, 1.6), cf(-0.4, 6.8, 2.6), MOSS2)
		B:block(body, v(1.2, 0.4, 1.0), cf(1.6, 6.75, 0.6), MOSS2)
		B:block(body, v(0.3, 1.1, 0.9), cf(3.08, 5.5, 2.5), MOSS)
		B:block(body, v(0.3, 0.7, 0.7), cf(3.08, 4.9, 2.5), MOSS2)
		B:block(body, v(0.3, 0.9, 0.8), cf(-3.08, 5.6, 1.0), MOSS)
		B:block(body, v(0.3, 0.6, 0.6), cf(-3.08, 4.95, 1.0), MOSS2)
		local garden = B:block(body, v(4, 1.5, 4), cf(0, 7.3, 2.0), MAIN, { tr = 1, name = "GardenFX" })
		B:emitter(garden, "leaf", {
			name = "LeafBurst", color = { MOSS, LILY, PINK2 }, rate = 0.7, size = { 0.45, 0.4, 0.2 },
			speed = { 2, 5 }, life = { 1.4, 2.6 },
		})

		-- lily pad + pink flower (own bone so it bobs on the swamp water)
		local flower = B:bone("Flower", "Body", v(0.7, 6.95, 2.3))
		B:block(flower, v(2.4, 0.2, 1.6), cf(0.7, 7.05, 2.3), LILY)
		B:block(flower, v(1.6, 0.2, 2.4), cf(0.7, 7.06, 2.3), LILY)
		B:block(flower, v(0.4, 0.22, 0.9), cf(1.5, 7.08, 1.65), LILY2) -- notch
		B:block(flower, v(0.6, 0.5, 0.6), cf(0.7, 7.55, 2.3), POLLEN)
		for _, d in { { 0.55, 0 }, { -0.55, 0 }, { 0, 0.55 }, { 0, -0.55 } } do
			local w = d[1] ~= 0 and v(0.6, 0.5, 0.45) or v(0.45, 0.5, 0.6)
			B:block(flower, w, cf(0.7 + d[1], 7.4, 2.3 + d[2]), PINK)
		end
		for k = 0, 3 do
			local a = math.rad(45 + k * 90)
			B:block(flower, v(0.35, 0.45, 0.6), cf(0.7 + 0.55 * math.sin(a), 7.75, 2.3 + 0.55 * math.cos(a), 0, 45 + k * 90, 0), PINK2)
		end

		-- cattail reed + grass blades (own bone, sways)
		local reed = B:bone("Reed", "Body", v(-1.4, 6.7, 3.4))
		B:beam(reed, v(-1.4, 6.6, 3.4), v(-1.6, 9.0, 3.6), 0.3, 0.3, MOSS2)
		B:block(reed, v(0.6, 1.1, 0.6), cf(-1.62, 9.15, 3.62), WOOD)
		B:block(reed, v(0.2, 0.5, 0.2), cf(-1.64, 9.9, 3.64), MOSS2)
		B:beam(reed, v(-1.2, 6.6, 3.0), v(-0.5, 8.3, 2.5), 0.45, 0.15, MOSS)
		B:beam(reed, v(-1.7, 6.6, 3.8), v(-2.6, 8.0, 4.5), 0.45, 0.15, MOSS)

		------------------------------------------------------------------
		-- CHEST (front torso) - yaws against the hips for the S-wiggle
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Body", v(0, 4.2, -0.4))
		segment(chest, -4.5, 0.3, 4.1, 6.4, 4.0, { -1.0, 1.25 }, true)
		for _, z in { -3.6, -2.3, -1.0 } do
			scute(chest, 0, 6.35, z, 1.2)
			B:sym(function()
				scute(chest, 1.45, 6.35, z + 0.2, 0.9)
				scute(chest, 2.65, 6.1, z + 0.4, 0.75)
			end)
		end
		-- algae drips hanging off the belly line
		B:sym(function()
			B:block(chest, v(0.3, 0.9, 0.4), cf(3.28, 2.55, -3.6), MOSS2)
			B:block(chest, v(0.3, 0.5, 0.4), cf(3.28, 2.0, -3.6), MOSS)
		end)

		------------------------------------------------------------------
		-- NECK
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Chest", v(0, 4.3, -4.0))
		segment(neck, -5.8, -3.9, 4.25, 5.4, 3.4)
		B:block(neck, v(3.8, 0.4, 1.8), cf(0, 2.45, -4.9), BELLY2)
		B:sym(function()
			scute(neck, 1.0, 6.05, -4.8, 0.8)
		end)

		------------------------------------------------------------------
		-- HEAD: wide flat cranium, raised eye bumps, long chunky snout
		------------------------------------------------------------------
		local head = B:bone("Head", "Neck", v(0, 4.5, -5.4))
		B:block(head, v(5.6, 2.6, 3.4), cf(0, 4.95, -6.9), MAIN) -- cranium
		B:block(head, v(5.7, 0.4, 3.2), cf(0, 3.85, -6.9), BELLY2) -- pale cheek / lip line
		B:block(head, v(5.74, 0.9, 0.7), cf(0, 5.3, -5.6), DARK) -- dark band behind the eyes
		B:block(head, v(4.4, 1.6, 4.2), cf(0, 4.45, -10.7), MAIN) -- snout
		B:block(head, v(3.4, 0.45, 4.0), cf(0, 5.45, -10.4), MAIN) -- snout top step
		B:block(head, v(1.6, 0.3, 3.4), cf(0, 5.75, -10.0), DARK) -- snout ridge
		B:block(head, v(4.5, 0.4, 4.1), cf(0, 3.85, -10.7), BELLY2) -- pale upper lip band
		B:block(head, v(4.46, 0.3, 0.6), cf(0, 4.75, -9.2), DARK) -- snout bands
		B:block(head, v(4.46, 0.3, 0.6), cf(0, 4.75, -11.3), DARK)
		B:block(head, v(2.8, 0.6, 1.3), cf(0, 5.55, -12.1), DARK) -- nose pad
		B:block(head, v(4.0, 0.25, 4.0), cf(0, 3.55, -10.6), PALATE) -- palate
		B:block(head, v(5.0, 0.25, 3.0), cf(0, 3.55, -7.1), PALATE)
		B:block(head, v(4.4, 1.4, 0.4), cf(0, 3.0, -5.45), MOUTH) -- dark throat
		-- moss crown + a tiny lily pad behind the eye bumps
		B:block(head, v(3.0, 0.4, 1.6), cf(0, 6.4, -5.9), MOSS)
		B:block(head, v(1.4, 0.18, 1.0), cf(0.4, 6.68, -6.0), LILY)
		B:block(head, v(1.0, 0.18, 1.4), cf(0.4, 6.69, -6.0), LILY)
		B:block(head, v(0.8, 0.3, 0.6), cf(-0.9, 6.7, -5.5), MOSS2)

		B:sym(function(side)
			-- nostril on the nose pad
			B:block(head, v(0.55, 0.15, 0.5), cf(0.7, 5.9, -12.35), MOUTH)
			-- upper teeth: neat row of white blocks hanging off the lip
			for i = 0, 4 do
				local h = i % 2 == 0 and 0.75 or 0.55
				B:block(head, v(0.5, h, 0.5), cf(2.0, 3.66 - h / 2, -8.9 - i * 0.85), TEETH)
			end
			B:block(head, v(0.5, 0.7, 0.5), cf(2.45, 3.3, -7.6), TEETH) -- back tooth under the cheek
			B:block(head, v(0.45, 0.6, 0.45), cf(0.8, 3.36, -12.5), TEETH) -- front tooth
			-- raised eye bump (crocodile style)
			B:block(head, v(2.4, 1.8, 2.5), cf(1.95, 6.95, -7.25), MAIN)
			B:block(head, v(1.6, 0.3, 1.6), cf(1.7, 7.9, -6.8), DARK)
			-- BIG amber eye on the bump's front; one slit pupil on the front face
			B:block(head, v(1.6, 1.4, 1.2), cf(2.42, 7.0, -8.0), AMBER, { mat = "Neon", name = "Eye" .. side })
			B:block(head, v(0.5, 1.2, 0.12), cf(2.25, 6.95, -8.63), SLIT)
			B:block(head, v(0.3, 0.3, 0.08), cf(2.85, 7.2, -8.63), "#ffffff", NEON) -- glint
			-- algae drips off the upper lip (own bone, swings)
			local algae = B:bone("Algae" .. side, "Head", v(2.05, 3.7, -10.2))
			B:block(algae, v(0.3, 0.8, 0.35), cf(2.3, 3.3, -10.2), MOSS2)
			B:block(algae, v(0.25, 0.5, 0.3), cf(2.3, 2.7, -10.2), MOSS)
		end)
		local nose = B:block(head, v(1.8, 0.4, 0.8), cf(0, 6.1, -12.2), MAIN, { tr = 1, name = "NoseFX" })
		B:emitter(nose, "bubble", {
			name = "Bubbles", color = { "#ffffff", "#c9f2c0" }, rate = 0, size = { 0.3, 0.6, 0.8 }, speed = { 1, 2.5 },
			life = { 1.0, 1.8 }, spread = 35,
		})
		local mouthFx = B:block(head, v(2.4, 1.2, 1.2), cf(0, 3.4, -13.2), MAIN, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFx, "burst", { name = "SnapBurst", color = { "#ffffff", AMBER, MOSS } })
		B:trail(head, v(0, 5.8, -12.7), v(0, 3.7, -12.7), { name = "SnoutTrail", color = { "#ffffff", AMBER }, life = 0.2, trans = { 0.55, 1 } })
		-- cartoon CHOMP impact lines (hidden, flashed on the snap)
		for i = 1, 6 do
			local a = (i - 1) / 6 * 360 + 30
			B:block(head, v(0.3, 0.3, 1.3), CFrame.new(0, 4.2, -13.4) * ang(0, 0, a) * CFrame.new(0, 2.7, 0) * ang(90, 0, 0), "#fff8dc", { mat = "Neon", tr = 1, name = "SnapLine" .. i })
		end

		-- heavy lids (half-closed = lazy) and heavy brows, on bones
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(2.42, 8.05, -8.0))
			B:block(lid, v(1.8, 1.45, 1.45), cf(2.42, 8.05, -8.0), MAIN)
			B:block(lid, v(1.84, 0.2, 1.49), cf(2.42, 7.38, -8.0), DEEP) -- lash line
			local brow = B:bone("Brow" .. side, "Head", v(1.9, 8.9, -7.8))
			B:block(brow, v(2.8, 0.6, 1.7), cf(1.95, 8.95, -7.9), DEEP)
			B:block(brow, v(1.1, 0.45, 1.2), cf(2.85, 9.4, -7.7), DEEP)
			B:block(brow, v(0.7, 0.3, 0.8), cf(3.15, 9.7, -7.6), SCUTE)
		end)

		-- anger vein (prop) above the right brow
		local mark = B:bone("Mark", "Head", v(3.4, 10.0, -6.6))
		local MP = CFrame.new(3.4, 10.0, -6.6) * ang(0, -35, 0)
		local veins = {
			{ -0.35, 0.6, 0.75, 0.25 }, { -0.6, 0.35, 0.25, 0.75 },
			{ 0.35, 0.6, 0.75, 0.25 }, { 0.6, 0.35, 0.25, 0.75 },
			{ -0.35, -0.6, 0.75, 0.25 }, { -0.6, -0.35, 0.25, 0.75 },
			{ 0.35, -0.6, 0.75, 0.25 }, { 0.6, -0.35, 0.25, 0.75 },
		}
		for i, q in veins do
			B:block(mark, v(q[3], q[4], 0.3), MP * CFrame.new(q[1], q[2], 0), RED, { tr = 1, name = "AngryMark" .. i })
		end

		-- sleepy Zzz (prop)
		local zzz = B:bone("Zzz", "Head", v(1.6, 9.2, -5.6))
		local function zee(c0, s, n)
			B:block(zzz, v(0.9 * s, 0.24 * s, 0.24), c0 * CFrame.new(0, 0.38 * s, 0), "#eef6ff", { tr = 1, name = "Zzz" .. n })
			B:block(zzz, v(0.9 * s, 0.24 * s, 0.24), c0 * CFrame.new(0, -0.38 * s, 0), "#eef6ff", { tr = 1, name = "Zzz" .. (n + 1) })
			B:block(zzz, v(0.24 * s, 1.0 * s, 0.24), c0 * ang(0, 0, -50), "#bcd8ff", { tr = 1, name = "Zzz" .. (n + 2) })
		end
		local ZP = CFrame.new(1.6, 9.2, -5.6) * ang(0, -30, 0)
		zee(ZP, 1, 1)
		zee(ZP * CFrame.new(0.9, 1.0, 0), 0.7, 4)

		------------------------------------------------------------------
		-- JAW (hinged at the back of the mouth)
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", v(0, 3.6, -5.6))
		B:block(jaw, v(4.6, 1.1, 3.0), cf(0, 2.95, -7.1), MAIN)
		B:block(jaw, v(3.4, 1.0, 4.4), cf(0, 3.0, -10.6), MAIN)
		B:block(jaw, v(4.4, 0.35, 2.8), cf(0, 2.33, -7.1), BELLY)
		B:block(jaw, v(3.2, 0.35, 4.2), cf(0, 2.43, -10.6), BELLY)
		B:block(jaw, v(4.66, 0.3, 0.6), cf(0, 3.0, -8.0), DARK) -- jaw band
		B:block(jaw, v(4.0, 0.15, 2.6), cf(0, 3.5, -7.1), MOUTH)
		B:block(jaw, v(2.8, 0.15, 4.2), cf(0, 3.52, -10.6), MOUTH)
		B:block(jaw, v(1.8, 0.25, 4.2), cf(0, 3.62, -9.2), TONGUE)
		B:block(jaw, v(3.6, 1.4, 0.5), cf(0, 3.9, -5.9), MOUTH) -- throat back wall
		B:sym(function()
			for i = 0, 3 do
				local h = i % 2 == 0 and 0.55 or 0.7
				B:block(jaw, v(0.45, h, 0.45), cf(1.4, 3.5 + h / 2, -9.3 - i * 0.85), TEETH)
			end
			B:block(jaw, v(0.45, 0.6, 0.45), cf(1.95, 3.75, -7.4), TEETH)
			B:block(jaw, v(0.4, 0.5, 0.4), cf(0.55, 3.75, -12.45), TEETH)
		end)
		local drip = B:block(jaw, v(2.6, 0.3, 3.0), cf(0, 2.2, -9.5), MAIN, { tr = 1, name = "DripFX" })
		B:emitter(drip, "drip", { name = "AlgaeDrip", color = { MOSS, "#c9e88a" }, rate = 1.2 })

		------------------------------------------------------------------
		-- LEGS: short sprawling gator legs (3 bones each), chunky clawed feet
		------------------------------------------------------------------
		B:sym(function(side)
			-- front legs on the chest
			local arm = B:bone("Arm" .. side, "Chest", v(2.9, 3.6, -2.6))
			B:block(arm, v(2.2, 2.2, 2.2), cf(3.2, 3.7, -2.6), MAIN)
			B:block(arm, v(1.6, 0.6, 1.8), cf(3.4, 2.75, -2.6), BELLY)
			B:beam(arm, v(3.4, 3.4, -2.55), v(4.75, 2.75, -2.4), 1.7, 1.7, MAIN)
			scute(arm, 3.4, 4.8, -2.6, 0.8)
			local fore = B:bone("Forearm" .. side, "Arm" .. side, v(4.7, 2.7, -2.4))
			B:block(fore, v(1.8, 1.8, 1.8), cf(4.75, 2.7, -2.45), DARK)
			B:beam(fore, v(4.7, 2.5, -2.45), v(4.62, 0.8, -2.7), 1.5, 1.5, MAIN)
			B:block(fore, v(1.0, 1.2, 0.3), cf(4.65, 1.5, -3.5), BELLY2)
			local hand = B:bone("Hand" .. side, "Forearm" .. side, v(4.6, 0.65, -2.7))
			B:block(hand, v(2.0, 0.7, 2.6), cf(4.65, 0.35, -3.0), DARK)
			B:block(hand, v(1.6, 0.45, 1.9), cf(4.65, 0.9, -2.85), MAIN)
			for k = -1, 1 do
				B:wedge(hand, v(0.45, 0.5, 0.9), cf(4.65 + k * 0.65, 0.25, -4.7), TEETH)
			end
			local dustF = B:block(hand, v(2.0, 0.2, 2.4), cf(4.65, 0.1, -3.0), MAIN, { tr = 1, name = "DustPadF" .. side })
			B:emitter(dustF, "dust", {
				name = "DustF" .. side, color = { "#d8d0a8", "#a7a878" }, size = { 1.2, 2.4, 3.0 }, speed = { 4, 9 },
				life = { 0.5, 0.9 }, trans = { 0.3, 0.5, 1 }, spread = 80,
			})
			B:trail(hand, v(4.65, 0.55, -4.9), v(4.65, 0.05, -4.9), { name = "ClawTrail" .. side, color = { "#ffffff", MOSS }, life = 0.15, trans = { 0.5, 1 } })

			-- rear legs on the hips (bigger thighs)
			local thigh = B:bone("Thigh" .. side, "Body", v(2.8, 3.6, 3.2))
			B:block(thigh, v(2.6, 2.6, 2.8), cf(3.25, 3.75, 3.2), MAIN)
			B:block(thigh, v(0.3, 1.2, 1.8), cf(4.6, 4.0, 3.2), DARK)
			B:block(thigh, v(2.0, 0.6, 2.2), cf(3.4, 2.65, 3.2), BELLY)
			B:beam(thigh, v(3.6, 3.4, 3.1), v(4.85, 2.95, 2.9), 2.0, 2.0, MAIN)
			scute(thigh, 3.3, 5.05, 3.3, 0.85)
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(4.8, 2.9, 2.9))
			B:block(shin, v(2.0, 2.0, 2.0), cf(4.85, 2.9, 2.95), DARK)
			B:beam(shin, v(4.8, 2.7, 3.0), v(4.7, 0.8, 3.35), 1.7, 1.7, MAIN)
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(4.7, 0.65, 3.4))
			B:block(foot, v(2.2, 0.7, 3.2), cf(4.75, 0.35, 2.85), DARK)
			B:block(foot, v(1.8, 0.45, 2.4), cf(4.75, 0.9, 3.0), MAIN)
			for k = -1, 1 do
				B:wedge(foot, v(0.5, 0.5, 1.0), cf(4.75 + k * 0.72, 0.25, 0.8), TEETH)
			end
			B:wedge(foot, v(0.5, 0.45, 0.8), cf(4.75, 0.22, 4.7, 0, 180, 0), DEEP) -- heel spur
			local dustR = B:block(foot, v(2.2, 0.2, 3.0), cf(4.75, 0.1, 2.9), MAIN, { tr = 1, name = "DustPadR" .. side })
			B:emitter(dustR, "dust", {
				name = "DustR" .. side, color = { "#d8d0a8", "#a7a878" }, size = { 1.3, 2.6, 3.2 }, speed = { 4, 9 },
				life = { 0.5, 0.9 }, trans = { 0.3, 0.5, 1 }, spread = 80,
			})
		end)

		------------------------------------------------------------------
		-- TAIL: 5 tapering segments with a double crest that merges into one,
		-- then a tip that curls up into a driftwood hook holding the lantern
		------------------------------------------------------------------
		local tails = {
			-- pivot y, pivot z, z0, z1, yc, w, h, crest
			{ 4.3, 4.4, 4.2, 6.6, 4.05, 4.6, 3.2, 2 },
			{ 3.9, 6.4, 6.2, 8.4, 3.55, 3.7, 2.6, 2 },
			{ 3.3, 8.2, 8.0, 10.0, 3.0, 2.9, 2.1, 2 },
			{ 2.75, 9.8, 9.6, 11.4, 2.5, 2.2, 1.6, 1 },
			{ 2.4, 11.2, 11.0, 12.5, 2.2, 1.6, 1.3, 0 },
		}
		local parent = "Body"
		for i, s in tails do
			local name = "Tail" .. i
			local b = B:bone(name, parent, v(0, s[1], s[2]))
			segment(b, s[3], s[4], s[5], s[6], s[7], i <= 3 and { 0.2 } or nil, i <= 3)
			if i > 1 then
				B:block(b, v(s[6] + 0.25, s[7] * 0.5, 0.5), cf(0, s[5] + s[7] * 0.12, s[3] + 0.3), DEEP) -- joint band
			end
			local top = s[5] + s[7] / 2 + 0.25
			local zc = (s[3] + s[4]) / 2
			if s[8] == 2 then
				B:sym(function()
					B:block(b, v(0.5, 0.8, 1.0), cf(0.75, top + 0.4, zc - 0.4), DEEP)
					B:block(b, v(0.4, 0.4, 0.6), cf(0.75, top + 1.0, zc - 0.3), SCUTE)
					B:block(b, v(0.45, 0.5, 0.7), cf(0.75, top + 0.25, zc + 0.7), DEEP)
				end)
			elseif s[8] == 1 then
				B:block(b, v(0.5, 0.8, 1.0), cf(0, top + 0.4, s[3] + 0.6), DEEP)
				B:block(b, v(0.4, 0.4, 0.6), cf(0, top + 1.0, s[3] + 0.7), SCUTE)
			end
			parent = name
		end
		local tip = B:bone("TailTip", "Tail5", v(0, 2.3, 12.2))
		B:block(tip, v(1.3, 1.2, 1.0), cf(0, 2.5, 12.6), MAIN)
		B:block(tip, v(1.15, 0.5, 0.9), cf(0, 1.95, 12.6), BELLY)
		B:block(tip, v(1.1, 1.1, 0.9), cf(0, 3.45, 12.85), MAIN)
		B:block(tip, v(0.9, 1.0, 0.8), cf(0, 4.35, 12.95), DARK)
		B:block(tip, v(0.4, 0.5, 0.5), cf(0, 4.1, 13.45), DEEP) -- back nub
		-- driftwood hook
		B:beam(tip, v(0, 4.6, 12.95), v(0, 5.9, 12.5), 0.45, 0.45, WOOD)
		B:beam(tip, v(0, 5.85, 12.65), v(0, 5.75, 11.25), 0.42, 0.42, WOOD)
		B:block(tip, v(0.5, 0.35, 0.35), cf(0, 6.15, 12.4), MOSS) -- moss on the hook
		B:block(tip, v(0.3, 0.3, 0.3), cf(0, 5.75, 11.05), AMBER, NEON)
		B:trail(tip, v(0, 5.9, 12.5), v(0, 4.4, 13.0), { name = "TailTrail", color = { "#ffffff", AMBER }, life = 0.22, trans = { 0.5, 1 } })

		-- swamp lantern (pendulum bone)
		local lant = B:bone("Lantern", "TailTip", v(0, 5.6, 11.45))
		B:block(lant, v(0.15, 0.6, 0.15), cf(0, 5.3, 11.45), WOOD2)
		B:block(lant, v(1.1, 0.25, 1.1), cf(0, 4.9, 11.45), IRON)
		B:block(lant, v(0.6, 0.25, 0.6), cf(0, 5.1, 11.45), IRON)
		for _, q in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			B:block(lant, v(0.2, 1.0, 0.2), cf(0.42 * q[1], 4.3, 11.45 + 0.42 * q[2]), IRON)
		end
		local core = B:block(lant, v(0.62, 0.85, 0.62), cf(0, 4.3, 11.45), AMBER, { mat = "Neon", name = "LanternCore" })
		B:block(lant, v(1.1, 0.25, 1.1), cf(0, 3.7, 11.45), IRON)
		B:block(lant, v(0.4, 0.2, 0.4), cf(0, 3.5, 11.45), IRON)
		B:light(core, { name = "LanternLight", color = AMBER, brightness = 1.2, range = 10 })

		------------------------------------------------------------------
		-- Floating voxel cubes: olive cube + moss cap + thin amber band
		------------------------------------------------------------------
		local orbs = {
			{ 7.8, 7.4, -4.5, 1.7 },
			{ -7.6, 6.4, -1.5, 1.4 },
			{ 7.4, 5.8, 6.5, 1.3 },
			{ -7.2, 8.0, 6.0, 1.7 },
		}
		for i, o in orbs do
			local ob = B:bone("Orb" .. i, "Root", v(o[1], o[2], o[3]))
			local s = o[4]
			B:block(ob, v(s, s, s), cf(o[1], o[2], o[3]), i % 2 == 0 and DARK or MAIN)
			B:block(ob, v(s + 0.1, s * 0.32, s + 0.1), cf(o[1], o[2] + s * 0.36, o[3]), MOSS)
			B:block(ob, v(s + 0.14, s * 0.14, s + 0.14), cf(o[1], o[2] - s * 0.12, o[3]), AMBER, NEON)
		end

		------------------------------------------------------------------
		-- Buzzing fly (prop) for the idle snap gag
		------------------------------------------------------------------
		local fly = B:bone("Fly", "Root", v(0, 7.5, -14.5))
		B:block(fly, v(0.4, 0.35, 0.55), cf(0, 7.5, -14.5), "#1b1b1f", { tr = 1, name = "FlyBody" })
		B:block(fly, v(0.55, 0.06, 0.35), cf(0.4, 7.72, -14.4, 0, 0, 20), "#eef8ff", { tr = 1, name = "FlyWingR" })
		B:block(fly, v(0.55, 0.06, 0.35), cf(-0.4, 7.72, -14.4, 0, 0, -20), "#eef8ff", { tr = 1, name = "FlyWingL" })
		B:block(fly, v(0.42, 0.15, 0.15), cf(0, 7.58, -14.8), RED, { tr = 1, name = "FlyEyes" })

		------------------------------------------------------------------
		-- Swamp splash ring: murky water slabs with foam tops (hidden), burst
		-- outward on slams / landings
		------------------------------------------------------------------
		local SC = v(0, 0.3, -3.0)
		for k = 1, 8 do
			local a = (k - 1) / 8 * 360 + 22.5
			local sb = B:bone("Splash" .. k, "Root", SC)
			local at = CFrame.new(SC) * ang(0, a, 0) * CFrame.new(0, 0, -4.0)
			B:block(sb, v(2.0, 0.6, 1.1), at, "#6f8f4c", { tr = 1, name = "Splash" .. k })
			B:block(sb, v(1.6, 0.3, 0.8), at * CFrame.new(0, 0.42, 0), "#e2f2bf", { tr = 1, name = "Foam" .. k })
		end
	end,
}
