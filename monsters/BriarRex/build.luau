--!nocheck
-- Briar Rex: the THORN TYRANT guarding the rose garden. A towering, upright
-- stud-built T-rex: the torso is reared up ~25 degrees over huge drumstick
-- legs, a thick neck carries a big blocky head held high, and the tail sweeps
-- back and down as a counterweight.
-- Palette: dark bark-brown body plated in charcoal armour with light bark
-- rims, a crimson stepped belly, bone-white thorns / teeth / claws, deep green
-- only as vine + moss trim, crimson roses. Neon is kept to the amber eyes and
-- a few small pink rose hearts. Comically tiny arms (he is VERY touchy).
return {
	DisplayName = "Briar Rex",
	Rarity = "Divine",
	Element = "Thorn",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local MAIN, DARK = "#5c3a24", "#2a2220"
		local PLATE, RIM = "#3b2c25", "#9a6e45"
		local BELLY, BELLY2 = "#8a1c2c", "#b32c3e"
		local THORN, THORND = "#efe6cf", "#cfc2a2"
		local VINE, MOSS, LEAF = "#2f6b2a", "#4d8a2c", "#62b03a"
		local ROSE, ROSE2, ROSED = "#c41e3a", "#e8384f", "#6e0f1f"
		local WHITE, MOUTH, TONGUE = "#f7f2e4", "#140c0e", "#c4405e"
		local EYE, PUPIL, PINK = "#ffbf2e", "#140a06", "#ff4fb0"
		local NEON = { mat = "Neon" }

		-- rotate a local-authored CFrame / point about `pivot` (pitch only)
		local function rot(pivot, deg)
			return CFrame.new(pivot) * ang(deg, 0, 0) * CFrame.new(-pivot)
		end
		local HIPP = v(0, 10.5, 2.5)
		local TB = rot(HIPP, 32) -- reared-up torso
		local TP = rot(HIPP, 16) -- pelvis

		------------------------------------------------------------------
		-- helpers
		------------------------------------------------------------------
		-- rose blossom (upright): green sepal, 4 crimson petals, dark heart
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

		-- stepped bone-white thorn spike (AtomicKaiju plate idiom) authored in a
		-- local frame T: charcoal base step, thorn steps leaning back, tip =
		-- rose / pink glow / dark-red point
		local function plate(bone, T, x, y, z, steps, w, tip, glow)
			local d, zo = w, 0
			for i = 0, steps - 1 do
				local wide = i == 0 and 1.6 or (1.35 - 0.12 * i)
				B:block(bone, v(wide, 1, d), T * cf(x, y + i + 0.5, z + zo), i == 0 and DARK or (i % 2 == 1 and THORN or THORND))
				if i < steps - 1 then
					d = math.max(1.0, d * 0.7)
					zo += 0.45
				end
			end
			local top = T * v(x, y + steps, z + zo + 0.1)
			if tip == "rose" then
				rose(bone, top - v(0, 0.15, 0), 0.95, glow)
			elseif tip == "pink" then
				B:block(bone, v(0.55, 0.6, 0.8), CFrame.new(top + v(0, 0.25, 0.15)), PINK, NEON)
			else
				B:wedge(bone, v(0.75, 1.0, math.max(0.9, d * 0.8)), T * cf(x, y + steps + 0.45, z + zo + 0.2), ROSED)
			end
		end

		local function leaf(bone, at, ry, rz)
			B:block(bone, v(0.9, 0.25, 0.6), CFrame.new(at) * ang(0, ry or 0, rz or 0), LEAF)
		end

		------------------------------------------------------------------
		-- HIPS: tilted pelvis with charcoal armour
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", HIPP)
		B:block(hips, v(7.2, 5.8, 7.4), TP * cf(0, 10.6, 3.0), MAIN)
		B:block(hips, v(6.6, 0.8, 6.8), TP * cf(0, 7.6, 3.0), DARK)
		B:block(hips, v(5.8, 0.8, 3.0), TP * cf(0, 13.8, 1.4), DARK)
		B:block(hips, v(5.2, 0.8, 2.8), TP * cf(0, 13.8, 4.5), DARK)
		B:block(hips, v(4.0, 0.3, 0.6), TP * cf(0, 14.25, 2.6), RIM)
		B:block(hips, v(3.4, 0.3, 0.6), TP * cf(0, 14.25, 5.6), RIM)
		plate(hips, TP, 0, 14.1, 2.0, 2, 2.2, "thorn")
		plate(hips, TP, 0, 14.1, 4.6, 2, 2.0, "rose", true)
		B:sym(function()
			plate(hips, TP, 2.4, 13.9, 3.4, 1, 1.6, "thorn")
			B:block(hips, v(0.4, 3.0, 4.6), TP * cf(3.65, 11.2, 4.2), PLATE)
		end)

		------------------------------------------------------------------
		-- CHEST: reared-up barrel torso, crimson stepped belly, armour
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Hips", TB * v(0, 12, 0.5))
		B:block(chest, v(8.2, 6.4, 6.8), TB * cf(0, 13.9, -1.5), MAIN)
		B:block(chest, v(6.8, 1.0, 5.2), TB * cf(0, 10.5, -1.8), BELLY)
		local rows = { { 11.2, 4.8 }, { 12.3, 5.8 }, { 13.4, 6.2 }, { 14.5, 6.0 }, { 15.6, 5.2 }, { 16.6, 4.0 } }
		for i, r in rows do
			B:block(chest, v(r[2], 1, 0.8), TB * cf(0, r[1], -5.05 - (i % 2) * 0.22), i % 2 == 0 and BELLY2 or BELLY)
		end
		B:sym(function()
			B:block(chest, v(0.5, 4.8, 5.4), TB * cf(4.25, 13.9, -1.4), DARK)
			-- overlapping armour shields on the flank (light bark rims)
			B:block(chest, v(0.6, 2.6, 3.4), TB * cf(4.6, 15.0, -0.2), PLATE)
			B:block(chest, v(0.3, 0.5, 2.8), TB * cf(4.95, 16.1, -0.2), RIM)
			B:block(chest, v(0.6, 2.2, 2.6), TB * cf(4.6, 12.4, -2.4), PLATE)
			B:block(chest, v(0.3, 0.45, 2.2), TB * cf(4.95, 13.3, -2.4), RIM)
			B:spike(chest, TB * v(4.8, 15.4, 0.8), TB * v(6.2, 16.0, 2.2), 0.8, 0.8, THORN)
			B:spike(chest, TB * v(4.8, 12.6, -1.4), TB * v(6.0, 12.4, 0.0), 0.6, 0.6, THORN)
			-- charcoal shoulder ridge carrying the side thorn row
			B:block(chest, v(1.9, 0.6, 6.0), TB * cf(2.75, 17.3, -1.5), DARK)
			B:block(chest, v(0.5, 0.3, 5.6), TB * cf(3.55, 17.55, -1.5), RIM)
			plate(chest, TB, 2.75, 17.55, -3.6, 2, 1.6, "thorn")
			plate(chest, TB, 2.75, 17.55, -0.4, 1, 1.4, "thorn")
			-- a thorny vine draped over the shoulder
			B:block(chest, v(0.4, 0.5, 6.6), TB * cf(4.55, 16.8, -1.4), VINE)
			leaf(chest, TB * v(4.9, 17.0, -3.6), 30, -20)
			leaf(chest, TB * v(4.9, 16.7, 1.0), -25, -20)
		end)
		-- centre spikes (the front one is its own springy bone, rose crowned)
		B:block(chest, v(3.0, 0.5, 6.0), TB * cf(0, 17.3, -1.5), DARK)
		plate(B:bone("BackSpike", "Chest", TB * v(0, 17.4, -3.4)), TB, 0, 17.45, -3.4, 2, 2.6, "rose", true)
		plate(chest, TB, 0, 17.45, -0.4, 3, 2.4, "thorn")
		local backFX = B:block(chest, v(7, 3, 8), TB * cf(0, 19.0, -1.0), MAIN, { tr = 1, name = "BackFX" })
		B:emitter(backFX, "leaf", {
			name = "AmbientPetals", color = { ROSE, ROSE2, PINK }, rate = 2, size = { 0.45, 0.4, 0.25 }, life = { 2.5, 4 },
		})
		B:emitter(backFX, "leaf", {
			name = "PetalBurst", color = { ROSE, ROSE2, PINK, "#ffffff" }, rate = 0, speed = { 9, 18 }, size = { 0.7, 0.6, 0.3 },
			life = { 1.2, 2.2 }, spread = 160, accel = { 0, -6, 0 }, drag = 2,
		})
		local aura = B:block(chest, v(9, 10, 12), cf(0, 13, 0), MAIN, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "AuraSparkle", color = { "#ffffff", PINK }, rate = 3 })

		------------------------------------------------------------------
		-- NECK: thick muscular neck rising from the chest to the head
		------------------------------------------------------------------
		local HP = v(0, 17.6, -4.7) -- head pivot (back of the skull)
		local neck = B:bone("Neck", "Chest", TB * v(0, 15.0, -3.6))
		local na, nb = TB * v(0, 14.4, -2.6), v(0, 17.8, -5.9)
		B:beam(neck, na, nb, 6.6, 6.2, MAIN)
		local ncf, nlen = P.span(na, nb)
		B:block(neck, v(4.4, 0.7, nlen - 0.6), ncf * CFrame.new(0, -3.05, 0.2), BELLY) -- throat
		B:block(neck, v(3.0, 0.7, nlen - 1.0), ncf * CFrame.new(0, 3.1, 0.3), DARK) -- nape plate
		B:block(neck, v(1.8, 0.3, nlen - 1.4), ncf * CFrame.new(0, 3.55, 0.3), RIM)
		B:block(neck, v(6.9, 5.4, 0.7), ncf * CFrame.new(0, 0, nlen / 2 - 0.6), DARK) -- collar band
		B:sym(function()
			B:block(neck, v(0.4, 2.6, nlen - 1.6), ncf * CFrame.new(3.35, 0.4, 0), PLATE)
			B:block(neck, v(0.4, 0.5, 2.0), ncf * CFrame.new(3.4, -1.8, -0.6), MOSS)
		end)
		plate(neck, ncf * CFrame.new(0, 0, 0) * CFrame.new(0, -0.0, 0), 0, 3.4, 0.4, 2, 2.0, "thorn")

		------------------------------------------------------------------
		-- HEAD: big blocky skull (authored at 1x around H0, scaled HS up
		-- around the head pivot HP), heavy charcoal brow, amber slit eyes
		------------------------------------------------------------------
		local H0, HS = v(0, 18.2, -8.0), 1.14
		local function hp(p) return HP + (p - H0) * HS end
		local function hcf(x, y, z, rx, ry, rz) return CFrame.new(hp(v(x, y, z))) * ang(rx or 0, ry or 0, rz or 0) end
		local function hb(bone, sz, x, y, z, col, opts, rx, ry, rz)
			return B:block(bone, sz * HS, hcf(x, y, z, rx, ry, rz), col, opts)
		end
		local head = B:bone("Head", "Neck", HP)
		hb(head, v(7.6, 4.8, 6.0), 0, 20.1, -10.6, MAIN) -- cranium
		hb(head, v(6.8, 3.8, 0.6), 0, 19.9, -7.5, DARK)
		hb(head, v(5.4, 0.5, 4.6), 0, 22.6, -10.0, DARK) -- skull plate
		hb(head, v(3.6, 0.3, 3.2), 0, 22.95, -9.8, RIM)
		hb(head, v(6.2, 2.4, 5.0), 0, 18.9, -15.9, MAIN) -- snout (short + blocky)
		hb(head, v(3.8, 0.5, 4.2), 0, 20.35, -15.5, MAIN) -- snout top step
		hb(head, v(1.9, 0.4, 3.6), 0, 20.7, -15.2, DARK) -- snout ridge
		hb(head, v(5.4, 1.8, 0.8), 0, 19.0, -18.5, MAIN) -- nose plate
		hb(head, v(6.3, 0.5, 5.3), 0, 17.95, -15.9, DARK) -- lip band
		hb(head, v(7.7, 0.5, 5.0), 0, 17.95, -11.0, DARK)
		hb(head, v(5.6, 0.4, 10.2), 0, 17.55, -13.4, MOUTH) -- mouth roof
		hb(head, v(5.0, 2.0, 0.6), 0, 16.8, -8.4, MOUTH) -- throat wall
		for k = -1, 1 do -- thorn crown (prideful king)
			B:spike(head, hp(v(k * 1.5, 23.0, -10.6 + math.abs(k) * 0.6)), hp(v(k * 1.9, 23.2 - math.abs(k) * 0.2, -8.9 + math.abs(k) * 0.6)), 0.8, 0.8, THORN)
		end
		B:sym(function(side)
			hb(head, v(0.7, 0.4, 0.2), 1.3, 19.5, -18.95, MOUTH) -- nostril
			-- upper teeth: neat rows of white blocks, alternating long/short
			for i = 0, 5 do
				local h = i % 2 == 0 and 1.2 or 0.85
				hb(head, v(0.62, h, 0.62), 2.9, 17.75 - h / 2, -9.9 - i * 1.4, WHITE)
			end
			hb(head, v(0.62, 1.1, 0.62), 1.8, 17.25, -18.1, WHITE)
			hb(head, v(0.62, 0.8, 0.62), 0.65, 17.35, -18.3, WHITE)
			-- snout side colour blocking
			hb(head, v(0.15, 0.5, 4.0), 3.14, 19.25, -15.8, DARK)
			hb(head, v(0.15, 0.6, 0.9), 3.14, 18.5, -14.4, BELLY)
			hb(head, v(0.15, 0.6, 0.9), 3.14, 18.5, -16.8, BELLY)
			hb(head, v(0.3, 1.4, 6.6), 2.75, 16.9, -12.4, MOUTH) -- dark cheek wall
			-- charcoal cheek armour + bone frill thorns pointing back
			hb(head, v(0.6, 2.6, 3.8), 3.95, 19.7, -10.2, DARK)
			hb(head, v(0.3, 0.5, 3.0), 4.3, 20.8, -10.2, RIM)
			hb(head, v(0.3, 0.9, 1.2), 4.3, 19.2, -9.4, BELLY)
			B:spike(head, hp(v(4.0, 19.0, -9.0)), hp(v(5.4, 18.4, -6.9)), 1.1, 1.1, THORN)
			B:spike(head, hp(v(3.9, 20.4, -8.6)), hp(v(5.1, 21.0, -6.8)), 0.9, 0.9, THORN)
			-- EYE: dark socket + amber neon wrapping the cranium's front corner;
			-- the slit pupil sits on the front face only
			hb(head, v(2.3, 1.7, 1.0), 2.65, 20.95, -13.5, DARK)
			hb(head, v(1.8, 1.25, 1.0), 2.9, 20.9, -13.75, EYE, { mat = "Neon", name = "Eye" .. side })
			hb(head, v(0.6, 1.15, 0.3), 2.8, 20.9, -14.35, PUPIL)
			-- bone horns behind the brow
			B:spike(head, hp(v(3.2, 22.0, -11.6)), hp(v(4.5, 22.9, -9.6)), 1.1, 1.1, THORN)
		end)
		-- a rose tucked behind the right eye (vain!) on its own springy bone
		local rp = hp(v(4.15, 21.3, -8.6))
		rose(B:bone("HeadRose", "Head", rp), rp, 0.85, false)
		local mouthFX = B:block(head, v(3, 1.6, 1.6), CFrame.new(hp(v(0, 17.4, -19.4))), MAIN, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFX, "burst", { name = "RoarBurst", color = { "#ffffff", PINK, ROSE2 } })
		B:emitter(mouthFX, "leaf", {
			name = "MouthPetals", color = { ROSE, ROSE2, PINK }, rate = 0, speed = { 10, 20 }, size = { 0.7, 0.6, 0.3 },
			life = { 0.9, 1.8 }, spread = 40, accel = { 0, -5, 0 }, drag = 2, dir = "Front",
		})
		B:light(mouthFX, { name = "MouthLight", color = PINK, brightness = 0.01, range = 16 })
		B:trail(head, hp(v(0, 20.0, -18.9)), hp(v(0, 18.3, -18.9)), { name = "SnoutTrail", color = { "#ffffff", PINK }, life = 0.2, trans = { 0.55, 1 } })
		-- CHOMP impact lines (props, flashed on the bite)
		for i = 1, 6 do
			local a = (i - 1) / 6 * 360 + 30
			B:block(head, v(0.4, 0.4, 1.8), CFrame.new(hp(v(0, 17.6, -20.6))) * ang(0, 0, a) * CFrame.new(0, 3.8, 0) * ang(90, 0, 0), "#fff2f8", { mat = "Neon", tr = 1, name = "SnapLine" .. i })
		end
		-- ANGER MARK (prop): cartoon vein cross floating by the skull
		local AM = CFrame.new(hp(v(4.7, 22.0, -11.8))) * ang(0, -30, 45)
		for k = 0, 3 do
			local o = CFrame.Angles(0, 0, math.rad(k * 90)) * CFrame.new(0.6, 0.6, 0)
			B:block(head, v(0.4, 1.1, 0.4), AM * o * CFrame.Angles(0, 0, math.rad(45)), "#ff2e2e", { tr = 1, name = "AngryMark" .. (k + 1) })
		end
		-- SWEAT DROP (prop): the insecure tiny-arms moment
		B:block(head, v(0.8, 1.0, 0.6), CFrame.new(hp(v(4.45, 21.4, -12.7))), "#8fdcff", { tr = 1, name = "SweatDrop1" })
		B:block(head, v(0.45, 0.5, 0.4), CFrame.new(hp(v(4.45, 22.05, -12.7))), "#8fdcff", { tr = 1, name = "SweatDrop2" })

		-- heavy brows on their own bones (angry tilt / shocked raise)
		B:sym(function(side)
			local brow = B:bone("Brow" .. side, "Head", hp(v(1.5, 21.9, -13.6)))
			hb(brow, v(3.0, 1.1, 2.4), 2.7, 21.95, -13.65, DARK, nil, 0, 0, 15)
			hb(brow, v(1.5, 0.6, 1.8), 3.45, 22.6, -13.2, RIM, nil, 0, 0, 15)
			local lid = B:bone("Lid" .. side, "Head", hp(v(2.9, 20.9, -13.8)))
			hb(lid, v(2.0, 1.4, 1.1), 2.9, 20.9, -13.8, DARK, { tr = 1, name = "Eyelid" .. side })
		end)

		------------------------------------------------------------------
		-- JAW: strong lower jaw, neat teeth, tongue, mossy chin
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", hp(v(0, 17.6, -8.6)))
		hb(jaw, v(5.8, 1.6, 10.0), 0, 16.7, -13.6, DARK)
		hb(jaw, v(5.0, 0.6, 8.8), 0, 15.7, -13.4, BELLY)
		hb(jaw, v(5.9, 0.4, 8.4), 0, 16.4, -12.9, BELLY2) -- jaw stripe
		hb(jaw, v(5.0, 0.3, 9.4), 0, 17.55, -13.4, MOUTH)
		hb(jaw, v(2.6, 0.35, 4.6), 0, 17.7, -12.4, TONGUE)
		hb(jaw, v(4.6, 1.6, 1.2), 0, 17.6, -9.2, MOUTH)
		hb(jaw, v(4.6, 1.0, 1.0), 0, 16.4, -18.2, DARK) -- chin block
		B:sym(function()
			for i = 0, 5 do
				local h = i % 2 == 0 and 0.95 or 0.7
				hb(jaw, v(0.58, h, 0.58), 2.3, 17.5 + h / 2, -10.6 - i * 1.3, WHITE)
			end
			hb(jaw, v(0.58, 0.8, 0.58), 1.3, 17.9, -18.0, WHITE)
			hb(jaw, v(0.3, 0.5, 2.0), 2.95, 16.0, -15.4, MOSS)
		end)
		B:trail(jaw, hp(v(0, 17.6, -18.4)), hp(v(0, 15.8, -18.4)), { name = "ChompTrail", color = { "#ffffff", ROSE2 }, life = 0.18, trans = { 0.5, 1 } })
		-- mossy chin beard (own bone: it swings)
		local beard = B:bone("Beard", "Jaw", hp(v(0, 15.6, -16.4)))
		hb(beard, v(3.4, 0.8, 2.4), 0, 15.2, -16.9, MOSS)
		hb(beard, v(2.4, 0.8, 1.6), 0, 14.5, -17.1, LEAF)
		hb(beard, v(1.2, 0.6, 1.0), 0, 13.9, -17.3, MOSS)

		------------------------------------------------------------------
		-- TINY ARMS (comically small next to the 8-stud torso)
		------------------------------------------------------------------
		B:sym(function(side)
			local AP = TB * v(3.8, 13.2, -4.0)
			local arm = B:bone("Arm" .. side, "Chest", AP)
			B:block(arm, v(1.6, 1.4, 2.2), cf(AP.X + 0.6, AP.Y - 0.3, AP.Z - 0.6), MAIN)
			B:block(arm, v(1.8, 0.5, 1.7), cf(AP.X + 0.65, AP.Y + 0.5, AP.Z - 0.4), DARK)
			B:spike(arm, AP + v(1.2, 0.6, -0.2), AP + v(1.8, 1.4, 0.6), 0.5, 0.5, THORN)
			local FP = AP + v(0.65, -0.8, -1.5)
			local fore = B:bone("Forearm" .. side, "Arm" .. side, FP)
			B:block(fore, v(1.3, 1.2, 1.6), cf(FP.X, FP.Y - 0.3, FP.Z - 0.5), MAIN)
			B:block(fore, v(1.45, 0.9, 1.0), cf(FP.X, FP.Y - 0.7, FP.Z - 1.3), BELLY2)
			B:spike(fore, FP + v(-0.3, -0.9, -1.6), FP + v(-0.4, -1.7, -2.4), 0.45, 0.45, WHITE)
			B:spike(fore, FP + v(0.3, -0.9, -1.6), FP + v(0.4, -1.7, -2.4), 0.45, 0.45, WHITE)
			B:trail(fore, FP + v(0, -1.2, -1.7), FP + v(0, -0.4, -1.7), { name = "ClawTrail" .. side, color = { "#ffffff", PINK }, life = 0.15, trans = { 0.5, 1 } })
		end)

		------------------------------------------------------------------
		-- LEGS: huge armoured drumstick thighs, vine-wrapped shins, big feet
		------------------------------------------------------------------
		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Hips", v(3.6, 10.5, 3.0))
			B:block(thigh, v(4.8, 6.6, 6.2), cf(4.4, 8.4, 2.6), MAIN)
			B:block(thigh, v(4.0, 1.4, 4.4), cf(4.4, 5.6, 1.6), DARK)
			B:block(thigh, v(0.6, 3.6, 4.2), cf(6.95, 8.9, 2.6), DARK) -- armour
			B:block(thigh, v(0.3, 0.6, 3.6), cf(7.3, 10.5, 2.6), RIM)
			B:block(thigh, v(0.3, 0.5, 3.0), cf(7.3, 7.4, 2.6), RIM)
			B:block(thigh, v(3.4, 1.4, 0.5), cf(4.4, 8.6, -0.6), BELLY) -- front thigh plate
			B:block(thigh, v(3.0, 0.4, 0.5), cf(4.4, 9.5, -0.65), BELLY2)
			B:spike(thigh, v(7.1, 9.6, 3.4), v(8.5, 10.3, 5.0), 1.0, 1.0, THORN)
			B:spike(thigh, v(7.1, 8.0, 3.6), v(8.2, 8.1, 5.0), 0.7, 0.7, THORN)
			-- a vine coiling round the thigh
			B:block(thigh, v(5.1, 0.5, 6.5), cf(4.4, 6.7, 2.6, 0, 0, 10), VINE)
			leaf(thigh, v(7.1, 7.1, 0.4), 20, -30)

			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(4.3, 6.0, 1.5))
			local sa, sb = v(4.3, 6.4, 1.3), v(4.3, 1.9, 4.0)
			B:beam(shin, sa, sb, 3.2, 3.2, MAIN)
			B:beam(shin, sa + v(0, -0.2, -1.7), sb + v(0, 0.6, -1.45), 2.2, 0.4, DARK)
			local scf, slen = P.span(sa, sb)
			for k, f in { 0.28, 0.68 } do
				local at = scf * CFrame.new(0, 0, -slen * (f - 0.5))
				B:block(shin, v(3.5, 3.5, 0.45), at * ang(k == 1 and 14 or -14, 0, 0), VINE)
				B:spike(shin, (at * CFrame.new(1.7, 0.4, 0)).Position, (at * CFrame.new(2.6, 0.8, 0.3)).Position, 0.45, 0.45, THORN)
			end
			leaf(shin, (scf * CFrame.new(1.8, -0.5, 0.4)).Position, -20, -30)

			local foot = B:bone("Foot" .. side, "Shin" .. side, v(4.3, 2.0, 4.0))
			B:block(foot, v(2.8, 2.4, 2.6), cf(4.3, 2.0, 4.0), DARK)
			B:block(foot, v(4.0, 1.2, 5.6), cf(4.3, 0.6, 1.8), MAIN)
			B:block(foot, v(3.2, 0.6, 4.0), cf(4.3, 1.45, 1.8), DARK)
			for k = -1, 1 do
				B:block(foot, v(1.15, 1.0, 1.6), cf(4.3 + k * 1.35, 0.5, -1.6), MAIN)
				B:block(foot, v(1.17, 0.3, 1.0), cf(4.3 + k * 1.35, 1.05, -1.8), DARK)
				B:wedge(foot, v(0.9, 0.95, 1.5), cf(4.3 + k * 1.35, 0.475, -3.15), WHITE)
			end
			B:wedge(foot, v(0.8, 0.8, 1.2), cf(4.3, 0.4, 5.3, 0, 180, 0), THORN) -- heel spur
			local dfx = B:block(foot, v(3.6, 0.2, 5), cf(4.3, 0.1, 1.6), MAIN, { tr = 1, name = "StompFX" .. side })
			B:emitter(dfx, "dust", {
				name = "Dust" .. side, color = { "#e9dcc0", "#b9a27c" }, size = { 2.4, 4.4, 5.4 }, speed = { 8, 14 },
				life = { 0.6, 1.2 }, trans = { 0.25, 0.5, 1 }, spread = 85,
			})
			B:trail(foot, v(4.3, 1.0, -3.5), v(4.3, 0.1, -3.5), { name = "FootTrail" .. side, color = { "#ffffff", LEAF }, life = 0.14, trans = { 0.55, 1 } })
		end)

		------------------------------------------------------------------
		-- TAIL: sweeps back + down as a counterweight; segments follow the
		-- slope, charcoal plates, thorns, vines; thorny club tip
		------------------------------------------------------------------
		local piv = { v(0, 10.2, 6.0), v(0, 8.9, 8.6), v(0, 7.6, 11.0), v(0, 6.5, 13.2), v(0, 5.6, 15.2), v(0, 5.0, 17.0) }
		local dims = { { 5.8, 5.2, 3, "thorn" }, { 4.8, 4.3, 2, "rose" }, { 3.9, 3.5, 2, "thorn" }, { 3.1, 2.8, 1, "pink" }, { 2.4, 2.2, 1, "thorn" } }
		local parent = "Hips"
		for i = 1, 5 do
			local name = "Tail" .. i
			local b = B:bone(name, parent, piv[i])
			local a, c2 = piv[i], piv[i + 1]
			local d = c2 - a
			local len = d.Magnitude + 0.8
			local slope = math.deg(math.atan2(-d.Y, d.Z))
			local T = CFrame.new((a + c2) / 2) * ang(slope, 0, 0) -- local frame: +Z along the tail
			local w, h = dims[i][1], dims[i][2]
			B:block(b, v(w, h, len), T, MAIN)
			B:block(b, v(w - 0.8, 0.5, len - 0.6), T * CFrame.new(0, -h / 2 - 0.15, 0), BELLY)
			B:block(b, v(w - 1.0, 0.5, len - 0.8), T * CFrame.new(0, h / 2 + 0.2, 0), DARK)
			if i > 1 then
				B:block(b, v(w + 0.3, h + 0.3, 0.6), T * CFrame.new(0, 0, -len / 2 + 0.3), DARK)
			end
			plate(b, T, 0, h / 2 + 0.4, -0.2, dims[i][3], len * 0.5, dims[i][4], i == 2)
			if i % 2 == 0 then
				B:block(b, v(w + 0.25, h + 0.25, 0.45), T * CFrame.new(0, 0, 0.5) * ang(28, 0, 0), VINE)
				leaf(b, (T * CFrame.new(w / 2 + 0.3, 0.5, 0.2)).Position, 20, -30)
				leaf(b, (T * CFrame.new(-w / 2 - 0.3, -0.3, 0.9)).Position, -20, 30)
			else
				B:sym(function()
					B:spike(b, (T * CFrame.new(w / 2, 0.3, 0)).Position, (T * CFrame.new(w / 2 + 1.1, 0.7, 0.9)).Position, 0.65, 0.65, THORN)
				end)
			end
			parent = name
		end
		local TT = CFrame.new(piv[6]) * ang(8, 0, 0)
		local tip = B:bone("TailTip", "Tail5", piv[6])
		B:block(tip, v(2.2, 2.2, 0.6), TT * cf(0, 0, 0.1), DARK)
		B:block(tip, v(2.0, 1.8, 2.2), TT * cf(0, 0, 1.3), MAIN)
		B:block(tip, v(1.2, 1.2, 1.2), TT * cf(0, 0, 2.9), MAIN)
		B:block(tip, v(1.6, 0.4, 1.8), TT * cf(0, -1.0, 1.3), BELLY)
		B:block(tip, v(0.6, 0.6, 0.8), TT * cf(0, 0, 3.8), PINK, NEON)
		B:sym(function()
			B:spike(tip, TT * v(0.9, 0.1, 1.0), TT * v(2.4, 0.7, 2.2), 0.7, 0.7, THORN)
			B:spike(tip, TT * v(0.6, -0.3, 2.5), TT * v(1.7, -0.9, 3.7), 0.6, 0.6, THORN)
		end)
		B:spike(tip, TT * v(0, 0.8, 1.9), TT * v(0, 2.2, 3.2), 0.7, 0.7, THORN)
		rose(tip, TT * v(0, 0.85, 0.6), 0.75, false)
		B:trail(tip, TT * v(0, 0.9, 3.5), TT * v(0, -0.9, 3.5), { name = "TailTrail", color = { "#ffffff", PINK }, life = 0.25, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- Floating hedge cubes with roses on a tilted ring (motion orbits them)
		------------------------------------------------------------------
		B:bone("Orbit", "Root", v(0, 11, 1))
		for i = 1, 4 do
			local th = math.rad((i - 1) * 90 + 20)
			local y = 11 - 4.5 * math.cos(th) + (i % 2 == 0 and 1.0 or 0)
			local p = v(12.5 * math.sin(th), y, 1 - 11 * math.cos(th))
			local ob = B:bone("Orb" .. i, "Orbit", p)
			local s = i % 2 == 0 and 2.0 or 2.4
			B:block(ob, v(s, s * 0.7, s), CFrame.new(p), i % 2 == 0 and VINE or MOSS)
			B:block(ob, v(s + 0.1, s * 0.3, s + 0.1), CFrame.new(p + v(0, -s * 0.42, 0)), MAIN)
			B:block(ob, v(s + 0.14, s * 0.18, s + 0.14), CFrame.new(p + v(0, s * 0.3, 0)), LEAF)
			rose(ob, p + v(0, s * 0.38, 0), s * 0.55, i % 2 == 1)
		end

		------------------------------------------------------------------
		-- Stomp shockwave: ring of charcoal slabs with leafy/rose tops (props)
		------------------------------------------------------------------
		local SC = v(0, 0.4, 2.0)
		local g = B:bone("GroundFX", "Root", SC)
		local gfx = B:block(g, v(8, 0.4, 8), CFrame.new(SC), MAIN, { tr = 1, name = "GroundFXPart" })
		B:emitter(gfx, "burst", { name = "StompCubes", color = { LEAF, ROSE, THORN }, speed = { 10, 20 }, size = { 1.0, 0.7, 0 } })
		for k = 1, 12 do
			local a = (k - 1) / 12 * 360
			local sb = B:bone("Shock" .. k, "Root", SC)
			local at = CFrame.new(SC) * ang(0, a, 0) * CFrame.new(0, 0, -4.0)
			B:block(sb, v(2.6, 0.8, 1.4), at, DARK, { tr = 1, name = "Wave" .. k })
			B:block(sb, v(2.2, 0.25, 1.0), at * CFrame.new(0, 0.5, 0), k % 3 == 0 and ROSE or LEAF, { tr = 1, name = "WaveTop" .. k })
		end
	end,
}
