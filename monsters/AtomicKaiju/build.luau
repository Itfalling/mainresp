--!nocheck
-- Atomic Kaiju: hunched stud-built titan with lavender shark-fin dorsal plates,
-- cyan atomic accents and floating voxel cubes. Stud style reference monster.
-- Detail comes from two-tone colour blocking (royal blue + deep navy), light
-- lavender plates/horns/claws, white block teeth and a black mouth; neon is
-- kept to eyes, tips and thin strips. The big VFX (charge strips, beam,
-- shockwave) are hidden parts revealed by the motion during the signature move.
return {
	DisplayName = "Atomic Kaiju",
	Rarity = "Secret",
	Element = "Nuclear",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local NAVY, DARK = "#3550c4", "#222f80"
		local LAV, BELLY = "#c2b4ff", "#a89cf2"
		local WHITE, MOUTH, TONGUE, CYAN = "#f4f4ff", "#15121f", "#d8487a", "#3fe6ff"
		local PUPIL, CORE = "#0b1030", "#e6fdff"

		-- Voxel shark-fin plate: a DARK base step, then lavender steps that shrink
		-- and lean back, capped by a small glowing tip. `charge` adds a hidden
		-- neon core strip (Charge<n>) that lights up during the atomic charge.
		local function plate(bone, x, y, z, steps, w, rz, charge)
			local base = CFrame.new(x, y, z) * P.ang(0, 0, rz or 0)
			local d, zo = w, 0
			for i = 0, steps - 1 do
				B:block(bone, v(0.8, 1, math.max(0.6, d)), base * CFrame.new(0, i + 0.5, zo), i == 0 and DARK or LAV)
				if i < steps - 1 then
					d *= 0.62
					zo += 0.35
				end
			end
			B:block(bone, v(0.6, 0.6, 0.6), base * CFrame.new(0, steps + 0.25, zo + 0.3), CYAN, { mat = "Neon" })
			if charge then
				B:block(bone, v(0.9, steps - 0.3, 0.45), base * CFrame.new(0, steps / 2 + 0.15, zo), CYAN, { mat = "Neon", tr = 1, name = "Charge" .. charge })
			end
		end

		------------------------------------------------------------------
		-- Hips + chest
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 7, 2))
		B:block(hips, v(6, 4, 5), cf(0, 7, 2.5), NAVY)
		B:block(hips, v(5, 1, 4), cf(0, 4.6, 2.5), DARK)
		plate(hips, 0, 9, 3.3, 2, 2.4, 0, 6)
		local spine = B:block(hips, v(2, 3, 16), cf(0, 11, 9), NAVY, { tr = 1, name = "SpineFX" })
		B:emitter(spine, "burst", {
			name = "ChargeMotes", color = { "#ffffff", CYAN }, tex = "fire", life = { 0.8, 1.4 }, speed = { 1, 2.5 },
			size = { 0.35, 0.25, 0 }, trans = { 0.1, 0.2, 1 }, spread = 30, accel = { 0, 3, 0 }, drag = 0,
		})

		local chest = B:bone("Chest", "Hips", v(0, 9, 1.5))
		B:block(chest, v(7, 5, 6), cf(0, 11.5, 0), NAVY)
		B:block(chest, v(6, 1.5, 4.6), cf(0, 14.6, 0.6), NAVY)
		-- stepped light belly scales (like the reference's chest)
		local rows = { { 9.6, 3 }, { 10.7, 4 }, { 11.8, 4.6 }, { 12.9, 4 }, { 14, 3 } }
		for i, r in rows do
			B:block(chest, v(r[2], 1, 0.8), cf(0, r[1], -3.2 - (i % 2) * 0.25), i % 2 == 0 and BELLY or LAV)
		end
		B:sym(function()
			B:block(chest, v(0.6, 4, 5), cf(3.55, 11.4, 0.2), DARK)
			B:block(chest, v(0.3, 0.3, 2.6), cf(3.9, 13.1, -0.4), CYAN, { mat = "Neon" })
			plate(chest, 2.0, 15.2, 1.8, 2, 1.4, -16)
		end)
		plate(chest, 0, 15.3, -0.7, 4, 2.6, 0, 8)
		plate(chest, 0, 15.3, 2.1, 3, 2.2, 0, 7)
		local spark = B:block(chest, v(5, 3, 4), cf(0, 12, 0.5), NAVY, { tr = 1, name = "AuraVolume" })
		B:emitter(spark, "sparkle", { name = "AuraSparkle", color = { "#ffffff", CYAN }, rate = 4 })

		------------------------------------------------------------------
		-- Neck + head
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Chest", v(0, 13.5, -2.5))
		B:block(neck, v(4.6, 3.6, 3.6), cf(0, 14, -3.6), NAVY)
		B:block(neck, v(3.2, 1.6, 0.6), cf(0, 12.9, -5.2), BELLY)
		B:block(neck, v(5.0, 4.0, 0.7), cf(0, 14.1, -2.4), DARK) -- collar band
		plate(neck, 0, 15.75, -3.7, 2, 2.0, 0, 9)

		-- head geometry is authored at 1x and scaled up around the head pivot for a
		-- big, readable cartoon head
		local HP, HS = v(0, 14.5, -5), 1.3
		local function hp(p) return HP + (p - HP) * HS end
		local function hcf(x, y, z, rx, ry, rz) return CFrame.new(hp(v(x, y, z))) * P.ang(rx, ry, rz) end
		local function hs(sz) return sz * HS end
		local head = B:bone("Head", "Neck", hp(v(0, 14.5, -5)))
		B:block(head, hs(v(5, 3, 4.6)), hcf(0, 15.6, -6.8), NAVY) -- cranium
		B:block(head, hs(v(4, 1, 3.6)), hcf(0, 17.4, -6.4), NAVY) -- crown
		B:block(head, hs(v(4, 2, 3.6)), hcf(0, 15.2, -10.6), NAVY) -- snout
		B:block(head, hs(v(3, 0.8, 3)), hcf(0, 16.5, -10.0), NAVY) -- snout top step
		B:block(head, hs(v(1.8, 0.4, 2.4)), hcf(0, 17.05, -9.7), DARK) -- snout ridge
		B:block(head, hs(v(4.1, 0.5, 3.0)), hcf(0, 14.45, -10.9), DARK) -- dark lip band
		B:block(head, hs(v(3.4, 1.6, 1)), hcf(0, 15.1, -12.8), NAVY) -- nose plate
		B:block(head, hs(v(3.6, 0.6, 5.2)), hcf(0, 14.0, -10.2), MOUTH) -- mouth roof
		B:sym(function(side)
			-- upper teeth: big white blocks, alternating long/short
			for i = 0, 3 do
				local h = i % 2 == 0 and 1.1 or 0.75
				B:block(head, hs(v(0.6, h, 0.6)), hcf(1.5, 13.8 - h / 2, -8.4 - i * 1.25), WHITE)
			end
			B:block(head, hs(v(0.6, 1.0, 0.6)), hcf(0.65, 13.35, -12.55), WHITE) -- buck fang
			-- nostril
			B:block(head, hs(v(0.6, 0.35, 0.15)), hcf(0.8, 15.55, -13.33), MOUTH)
			-- dark cheek wall so the open mouth reads black, not see-through
			B:block(head, hs(v(0.3, 1.2, 3.0)), hcf(1.75, 13.6, -8.0), MOUTH)
			-- EYE: one glowing block wrapped round the cranium's front corner so it
			-- reads from the front AND the side, with dark pupils and a heavy brow
			B:block(head, hs(v(1.1, 1.0, 1.3)), hcf(2.05, 16.7, -8.65), CYAN, { mat = "Neon", name = "Eye" .. side })
			B:block(head, hs(v(0.45, 0.62, 0.2)), hcf(2.0, 16.68, -9.33), PUPIL)
			B:block(head, hs(v(1.6, 0.6, 1.9)), hcf(2.05, 17.45, -8.7, 0, 0, 10), DARK)
			-- cheek stripe + cheek frill spikes
			B:block(head, hs(v(0.3, 0.3, 2.0)), hcf(2.55, 15.0, -7.2), CYAN, { mat = "Neon" })
			B:beam(head, hp(v(2.4, 15.4, -5.6)), hp(v(4.1, 14.8, -3.8)), 1.04, 1.04, LAV)
			B:beam(head, hp(v(2.3, 14.4, -5.9)), hp(v(3.5, 13.5, -4.4)), 0.78, 0.78, LAV)
			-- horns: two lavender segments, cyan tip
			B:beam(head, hp(v(1.6, 17.6, -6.2)), hp(v(2.6, 19.6, -5.0)), 1.56, 1.56, LAV)
			B:beam(head, hp(v(2.6, 19.4, -5.1)), hp(v(3.0, 20.5, -4.0)), 1.17, 1.17, LAV)
			B:block(head, hs(v(0.7, 0.7, 0.7)), hcf(3.05, 20.8, -3.8, 30, 0, -20), CYAN, { mat = "Neon" })
		end)
		plate(head, 0, 18.85, -6.4, 2, 2.6, 0, 10)
		local mouthFX = B:block(head, hs(v(2, 1, 1)), hcf(0, 13.2, -12.6), NAVY, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFX, "burst", { name = "RoarBurst", color = { "#ffffff", CYAN } })
		B:emitter(mouthFX, "burst", {
			name = "RoarSparks", color = CYAN, life = { 0.12, 0.3 }, speed = { 5, 11 }, size = { 0.35, 0.15, 0 }, drag = 4,
		})
		B:light(mouthFX, { name = "MouthLight", color = CYAN, brightness = 0.01, range = 14 })
		-- glowing throat (shown while charging)
		B:block(head, hs(v(1.4, 0.3, 1.0)), hcf(0, 13.55, -7.6), CYAN, { mat = "Neon", tr = 1, name = "ThroatGlow" })
		-- the atomic breath: 3 core segments + 3 soft glow sleeves, hidden until
		-- the roar, revealed one after another so the beam shoots out of the mouth
		local beam = {
			{ 0.8, 4, -13.0, 1.5 },
			{ 1.1, 5, -17.5, 2.1 },
			{ 1.5, 7, -23.5, 2.8 },
		}
		for i, b in beam do
			B:block(head, hs(v(b[1], b[1], b[2])), hcf(0, 13.1, b[3]), CORE, { mat = "Neon", tr = 1, name = "Beam" .. i })
			B:block(head, hs(v(b[4], b[4], b[2] - 0.2)), hcf(0, 13.1, b[3]), CYAN, { mat = "Neon", tr = 1, name = "BeamGlow" .. i })
		end

		local beamTip = B:block(head, hs(v(1.6, 1.6, 0.6)), hcf(0, 13.1, -26.6), NAVY, { tr = 1, name = "BeamTip" })
		B:emitter(beamTip, "burst", {
			name = "BeamSpray", color = { "#ffffff", CYAN }, life = { 0.25, 0.55 }, speed = { 4, 10 }, size = { 1.1, 0.5, 0 }, drag = 3,
		})

		-- eyelids for cartoon blinks / the wind-up squint (shown only while closing)
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", hp(v(2.05, 17.2, -8.65)))
			B:block(lid, hs(v(1.35, 1.05, 1.6)), hcf(2.1, 16.7, -8.7), DARK, { tr = 1, name = "Eyelid" .. side })
		end)

		local jaw = B:bone("Jaw", "Head", hp(v(0, 14.2, -5.8)))
		B:block(jaw, hs(v(3.8, 1.2, 6)), hcf(0, 13.2, -9.2), DARK)
		B:block(jaw, hs(v(3.2, 0.6, 5)), hcf(0, 12.4, -8.9), BELLY)
		B:block(jaw, hs(v(3.2, 0.3, 5.2)), hcf(0, 13.9, -9.3), MOUTH)
		B:block(jaw, hs(v(2, 0.3, 3)), hcf(0, 14.1, -8.6), TONGUE)
		B:block(jaw, hs(v(3.0, 2.0, 1.4)), hcf(0, 14.4, -6.6), MOUTH) -- throat back wall
		B:sym(function()
			for i = 0, 3 do
				B:block(jaw, hs(v(0.55, 0.8, 0.55)), hcf(1.45, 14.3, -7.8 - i * 1.25), WHITE)
			end
		end)
		B:block(jaw, hs(v(1.1, 0.8, 0.55)), hcf(0, 14.3, -11.9), WHITE)

		------------------------------------------------------------------
		-- Arms
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Chest", v(3.7, 12.5, -1.5))
			B:block(arm, v(2.2, 2.4, 2.4), cf(4.2, 12.4, -1.5), NAVY)
			B:block(arm, v(0.4, 1.6, 1.6), cf(5.35, 12.5, -1.5), DARK)
			B:block(arm, v(2.4, 0.6, 2.0), cf(4.3, 13.8, -1.5), LAV) -- shoulder pad
			B:spike(arm, v(5.0, 13.7, -1.4), v(6.4, 14.4, -1.0), 0.7, 0.7, LAV)
			B:beam(arm, v(4.3, 12, -1.8), v(4.6, 9.4, -3.4), 2.2, 2.2, NAVY)
			local fore = B:bone("Forearm" .. side, "Arm" .. side, v(4.6, 9.5, -3.4))
			B:beam(fore, v(4.6, 9.6, -3.3), v(4.3, 8.2, -5.6), 1.8, 1.8, DARK)
			B:block(fore, v(2.2, 1.3, 2.0), cf(4.3, 7.9, -6.1), NAVY)
			B:block(fore, v(1.8, 0.4, 1.6), cf(4.3, 7.15, -6.0), BELLY)
			B:beam(fore, v(4.7, 9.4, -2.9), v(5.5, 10.8, -1.7), 0.7, 0.7, LAV)
			for k = -1, 1 do
				B:spike(fore, v(4.3 + k * 0.65, 7.7, -6.9), v(4.3 + k * 0.8, 6.8, -8.2), 0.6, 0.5, LAV)
			end
			B:trail(fore, v(4.3, 7.6, -7.4), v(4.3, 6.9, -8.2), { name = "ClawTrail" .. side, color = CYAN, life = 0.18, trans = { 0.5, 1 } })
		end)

		------------------------------------------------------------------
		-- Legs (two-tone: blue thigh, deep navy shin + foot, white claws)
		------------------------------------------------------------------
		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Hips", v(2.8, 7.5, 2.5))
			B:block(thigh, v(3.2, 4.6, 4), cf(3.3, 6.2, 2.3), NAVY)
			B:block(thigh, v(0.4, 3, 3), cf(4.95, 6.3, 2.3), DARK)
			B:block(thigh, v(0.3, 0.3, 2.4), cf(5.2, 7.2, 2.3), CYAN, { mat = "Neon" })
			B:block(thigh, v(2.2, 1, 0.4), cf(3.3, 4.4, 0.2), LAV) -- knee plate
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(3.3, 3.9, 2.8))
			B:block(shin, v(2.6, 3, 2.6), cf(3.3, 2.5, 3.0), DARK)
			B:block(shin, v(2.2, 0.8, 0.4), cf(3.3, 2.6, 1.55), BELLY)
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(3.3, 1.0, 2.6))
			B:block(foot, v(3.2, 0.8, 4.4), cf(3.3, 1.0, 1.8), DARK)
			B:block(foot, v(3.4, 0.6, 4.6), cf(3.3, 0.3, 1.8), NAVY)
			B:block(foot, v(3.0, 0.8, 1), cf(3.3, 0.4, -0.9), DARK)
			for k = -1, 1 do
				B:wedge(foot, v(0.7, 0.8, 1.4), cf(3.3 + k * 1.05, 0.4, -2.0), WHITE)
			end
			B:wedge(foot, v(0.6, 0.6, 1.0), cf(3.3, 0.3, 4.5, 0, 180, 0), LAV)
			if side == "R" then
				local dustAt = B:block(foot, v(3, 0.2, 4), cf(3.3, 0.1, 1.8), NAVY, { tr = 1, name = "StompFX" })
				B:emitter(dustAt, "dust", { name = "StompDust", color = "#d8d0c0" })
				B:emitter(dustAt, "burst", { name = "StompCubes", color = { LAV, CYAN }, speed = { 10, 18 }, size = { 0.8, 0.6, 0 } })
				B:trail(foot, v(3.3, 0.9, -2.3), v(3.3, 0.1, -2.3), { name = "StompTrail", color = LAV, life = 0.15, trans = { 0.45, 1 } })
			end
		end)

		------------------------------------------------------------------
		-- Tail (5 segments) with dark joint bands and dorsal plates
		------------------------------------------------------------------
		local seg = {
			{ v(0, 7.0, 4.6), v(5.0, 4.2, 4.0), 3 },
			{ v(0, 6.4, 8.2), v(4.2, 3.4, 4.0), 3 },
			{ v(0, 5.4, 11.8), v(3.4, 2.8, 4.0), 2 },
			{ v(0, 4.4, 15.4), v(2.6, 2.2, 3.8), 2 },
			{ v(0, 3.5, 18.8), v(2.0, 1.6, 3.6), 1 },
		}
		local parent = "Hips"
		for i, s in seg do
			local name = "Tail" .. i
			local b = B:bone(name, parent, s[1])
			local sz = s[2]
			local c = s[1] + v(0, -0.3, sz.Z / 2)
			B:block(b, sz, CFrame.new(c), NAVY)
			B:block(b, v(sz.X - 0.6, 0.4, sz.Z - 0.4), CFrame.new(c + v(0, -sz.Y / 2 - 0.1, 0)), BELLY)
			if i > 1 then
				B:block(b, v(sz.X + 0.3, sz.Y + 0.3, 0.6), CFrame.new(s[1] + v(0, -0.3, 0.1)), DARK)
			end
			plate(b, 0, c.Y + sz.Y / 2, c.Z - 0.3, s[3], sz.Z * 0.6, 0, 6 - i)
			parent = name
		end
		-- stepped lavender spade with a glowing tip
		local tip = B:bone("TailTip", "Tail5", v(0, 3.2, 22))
		B:block(tip, v(2.0, 1.9, 0.6), cf(0, 3.2, 22.2), DARK)
		B:block(tip, v(1.2, 1.2, 1.6), cf(0, 3.2, 22.6), NAVY)
		B:block(tip, v(0.6, 2.6, 1), cf(0, 3.2, 23.0), LAV)
		B:block(tip, v(0.6, 1.8, 1), cf(0, 3.2, 24.0), LAV)
		B:block(tip, v(0.6, 1.0, 1), cf(0, 3.2, 25.0), LAV)
		B:block(tip, v(0.5, 0.5, 0.6), cf(0, 3.2, 25.7), CYAN, { mat = "Neon" })
		B:trail(tip, v(0, 4.0, 24.6), v(0, 2.4, 24.6), { name = "TailTrail", color = CYAN, life = 0.25, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- Floating voxel cubes hovering on the flanks (VFX)
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 9, 2))
		local spots = { { 10, 14, -2 }, { -10, 12, 1 }, { 10, 8, 6 }, { -9, 16, 6 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = i % 2 == 0 and 1.4 or 1.8
			B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), DARK)
			B:block(ob, v(s + 0.1, s * 0.3, s + 0.1), cf(p[1], p[2] + s * 0.36, p[3]), LAV)
			B:block(ob, v(s + 0.16, s * 0.16, s + 0.16), cf(p[1], p[2] - s * 0.08, p[3]), CYAN, { mat = "Neon" })
		end

		------------------------------------------------------------------
		-- Stomp shockwave: a ring of flat lavender slabs (one bone each) that
		-- slide outward from the right foot on impact, hidden otherwise
		------------------------------------------------------------------
		local SC = v(3.3, 0.2, 1.6)
		for k = 1, 12 do
			local a = (k - 1) / 12 * 360
			local sb = B:bone("Shock" .. k, "Root", SC)
			B:block(sb, v(2.4, 0.4, 0.9), CFrame.new(SC) * P.ang(0, a, 0) * CFrame.new(0, 0, -3.0), LAV, { tr = 1, name = "Wave" .. k })
		end
	end,
}
