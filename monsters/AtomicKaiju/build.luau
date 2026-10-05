--!nocheck
-- Atomic Kaiju: hunched stud-built titan with chunky lavender stepped dorsal
-- fins, cyan atomic accents and voxel cubes orbiting like electrons. This is the
-- stud style reference monster.
-- Detail comes from two-tone colour blocking (royal blue + deep navy), light
-- lavender fins/horns, white block teeth/claws and a black mouth. Neon is kept
-- to the eyes, tips and thin strips. The big VFX (charge strips, beam, beam bits,
-- shockwave) are hidden parts that the motion reveals during the signature move.
return {
	DisplayName = "Atomic Kaiju",
	Rarity = "Secret",
	Element = "Nuclear",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local NAVY, DARK = "#3550c4", "#222f80"
		local LAV, BELLY = "#c2b4ff", "#a89cf2"
		local WHITE, MOUTH, TONGUE, CYAN = "#f4f4ff", "#15121f", "#d8487a", "#3fe6ff"
		local PUPIL, CORE, CORE2 = "#0b1030", "#e6fdff", "#9ff4ff"

		-- Chunky voxel shark-fin plate: a wide DARK base step, then lavender steps
		-- (each at least 1 stud) that shrink and lean back, capped by a small
		-- glowing tip laid along Z. `charge` adds a hidden neon core strip
		-- (Charge<n>) through the lavender steps that lights up during the charge.
		local function plate(bone, x, y, z, steps, w, charge)
			local d, zo = w, 0
			local lo, hi = -math.huge, math.huge
			for i = 0, steps - 1 do
				B:block(bone, v(i == 0 and 1.2 or 1.0, 1, d), cf(x, y + i + 0.5, z + zo), i == 0 and DARK or LAV)
				if i >= 1 or steps == 1 then
					lo, hi = math.max(lo, zo - d / 2), math.min(hi, zo + d / 2)
				end
				if i < steps - 1 then
					d = math.max(1.0, d * 0.72)
					zo += 0.4
				end
			end
			B:block(bone, v(0.5, 0.5, 0.8), cf(x, y + steps + 0.2, z + zo + 0.2), CYAN, { mat = "Neon" })
			if charge then
				local depth = math.clamp(hi - lo - 0.1, 0.3, 0.5)
				local zc = (lo + hi) / 2
				if steps == 1 then
					B:block(bone, v(1.3, 0.4, depth), cf(x, y + 0.5, z + zc), CYAN, { mat = "Neon", tr = 1, name = "Charge" .. charge })
				else
					B:block(bone, v(1.1, steps - 1.2, depth), cf(x, y + 1 + (steps - 1) / 2, z + zc), CYAN, { mat = "Neon", tr = 1, name = "Charge" .. charge })
				end
			end
		end

		------------------------------------------------------------------
		-- Hips + chest
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 7, 2))
		B:block(hips, v(6, 4, 5), cf(0, 7, 2.5), NAVY)
		B:block(hips, v(5, 1, 4), cf(0, 4.6, 2.5), DARK)
		plate(hips, 0, 8.95, 3.3, 2, 2.4, 6)
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
			plate(chest, 2.6, 15.2, 1.8, 2, 1.6)
		end)
		plate(chest, 0, 15.3, -0.7, 5, 2.8, 8)
		plate(chest, 0, 15.3, 2.3, 4, 2.4, 7)
		local spark = B:block(chest, v(5, 3, 4), cf(0, 12, 0.5), NAVY, { tr = 1, name = "AuraVolume" })
		B:emitter(spark, "sparkle", { name = "AuraSparkle", color = { "#ffffff", CYAN }, rate = 4 })

		------------------------------------------------------------------
		-- Neck + head
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Chest", v(0, 13.5, -2.5))
		B:block(neck, v(4.6, 3.6, 3.6), cf(0, 14, -3.6), NAVY)
		B:block(neck, v(3.2, 1.6, 0.6), cf(0, 12.9, -5.2), BELLY)
		B:block(neck, v(5.0, 4.0, 0.7), cf(0, 14.1, -2.4), DARK) -- collar band
		plate(neck, 0, 15.75, -3.7, 2, 2.0, 9)

		-- head geometry is authored at 1x around HP0 and scaled up (HS) around the
		-- head pivot HPW for a big, readable cartoon head
		local HP0, HPW, HS = v(0, 14.5, -5), v(0, 14.0, -5.2), 1.4
		local function hp(p) return HPW + (p - HP0) * HS end
		local function hcf(x, y, z, rx, ry, rz) return CFrame.new(hp(v(x, y, z))) * P.ang(rx, ry, rz) end
		local function hs(sz) return sz * HS end
		local head = B:bone("Head", "Neck", HPW)
		B:block(head, hs(v(5, 3, 4.6)), hcf(0, 15.6, -6.8), NAVY) -- cranium
		B:block(head, hs(v(4, 1, 3.6)), hcf(0, 17.4, -6.4), NAVY) -- crown
		B:block(head, hs(v(2, 0.6, 2.4)), hcf(0, 18.15, -6.3), DARK) -- crest
		B:block(head, hs(v(1.0, 0.3, 2.0)), hcf(0, 18.5, -6.3), CYAN, { mat = "Neon", tr = 1, name = "Charge10" })
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
			-- EYE (own bone so it can pop out on the roar): a dark frame with a
			-- glowing rectangle wrapped round the cranium's front corner, a slit
			-- pupil on the front face and a second pupil on the side face
			local eb = B:bone("EyeBall" .. side, "Head", hp(v(2.2, 16.7, -8.7)))
			B:block(eb, hs(v(1.4, 1.1, 1.3)), hcf(2.1, 16.7, -8.7), DARK)
			B:block(eb, hs(v(1.0, 0.8, 1.1)), hcf(2.35, 16.7, -8.9), CYAN, { mat = "Neon", name = "Eye" .. side })
			B:block(eb, hs(v(0.35, 0.55, 0.2)), hcf(2.1, 16.7, -9.5), PUPIL)
			B:block(eb, hs(v(0.2, 0.55, 0.35)), hcf(2.9, 16.7, -9.0), PUPIL)
			-- heavy stepped brow, on the grid, raised at the outer edge (angry)
			B:block(head, hs(v(1.8, 0.5, 1.7)), hcf(2.05, 17.4, -8.75), DARK)
			B:block(head, hs(v(0.9, 0.5, 1.5)), hcf(2.5, 17.85, -8.7), DARK)
			-- cheek stripe + cheek frill spikes
			B:block(head, hs(v(0.3, 0.3, 2.0)), hcf(2.55, 15.0, -7.2), CYAN, { mat = "Neon" })
			B:beam(head, hp(v(2.4, 15.4, -5.6)), hp(v(4.1, 14.8, -3.8)), 1.04, 1.04, LAV)
			B:beam(head, hp(v(2.3, 14.4, -5.9)), hp(v(3.5, 13.5, -4.4)), 0.78, 0.78, LAV)
			-- horns: three stepped lavender segments sweeping back, cyan tip
			B:beam(head, hp(v(1.6, 17.5, -6.3)), hp(v(2.4, 18.8, -5.0)), hs(1.6), hs(1.6), LAV)
			B:beam(head, hp(v(2.3, 18.6, -5.2)), hp(v(2.8, 19.3, -4.0)), hs(1.2), hs(1.2), LAV)
			B:beam(head, hp(v(2.75, 19.15, -4.15)), hp(v(3.0, 19.6, -3.2)), hs(0.8), hs(0.8), LAV)
			B:beam(head, hp(v(2.97, 19.5, -3.45)), hp(v(3.1, 19.8, -2.8)), hs(0.5), hs(0.5), CYAN, { mat = "Neon" })
			B:trail(head, hp(v(3.05, 19.75, -3.0)), hp(v(3.05, 19.35, -3.2)), { name = "HornTrail" .. side, color = CYAN, life = 0.16, trans = { 0.55, 1 } })
		end)
		local mouthFX = B:block(head, hs(v(2, 1, 1)), hcf(0, 13.2, -12.6), NAVY, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFX, "burst", { name = "RoarBurst", color = { "#ffffff", CYAN } })
		B:emitter(mouthFX, "burst", {
			name = "RoarSparks", color = CYAN, life = { 0.12, 0.3 }, speed = { 5, 11 }, size = { 0.35, 0.15, 0 }, drag = 4,
		})
		B:light(mouthFX, { name = "MouthLight", color = CYAN, brightness = 0.01, range = 14 })
		-- glowing throat (shown while charging)
		B:block(head, hs(v(1.4, 0.3, 1.0)), hcf(0, 13.55, -7.6), CYAN, { mat = "Neon", tr = 1, name = "ThroatGlow" })
		-- the atomic breath: 3 core segments + 3 thin glow sleeves, hidden until
		-- the roar, revealed one after another. Segments are staggered by a
		-- fraction of a stud so the beam reads voxel-stepped, not a smooth bar.
		local beam = {
			{ 0.8, 4.0, -13.2, 1.2, 0, CORE },
			{ 1.0, 5.0, -17.6, 1.6, 0.15, CORE2 },
			{ 1.3, 7.0, -23.6, 2.0, -0.15, CORE2 },
		}
		for i, b in beam do
			B:block(head, hs(v(b[1], b[1], b[2])), hcf(0, 13.1 + b[5], b[3]), b[6], { mat = "Neon", tr = 1, name = "Beam" .. i })
			B:block(head, hs(v(b[4], b[4], b[2] - 0.2)), hcf(0, 13.1 + b[5], b[3]), CYAN, { mat = "Neon", tr = 1, name = "BeamGlow" .. i })
		end
		local beamTip = B:block(head, hs(v(1.6, 1.6, 0.6)), hcf(0, 13.0, -27.4), NAVY, { tr = 1, name = "BeamTip" })
		B:emitter(beamTip, "burst", {
			name = "BeamSpray", color = { "#ffffff", CYAN }, life = { 0.25, 0.55 }, speed = { 4, 10 }, size = { 1.1, 0.5, 0 }, drag = 3,
		})
		-- voxel bits that tumble off the beam's tip (hidden, cycled by the motion)
		for i = 1, 3 do
			local bit = B:bone("Bit" .. i, "Head", hp(v(0, 13.0, -26.0)))
			B:block(bit, hs(v(0.6, 0.6, 0.6)), hcf(0, 13.0, -26.0), i == 2 and CORE or CYAN, { mat = "Neon", tr = 1, name = "BeamBit" .. i })
		end

		-- eyelids for cartoon blinks / the wind-up squint (shown only while closing)
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", hp(v(2.4, 16.7, -8.9)))
			B:block(lid, hs(v(1.3, 0.9, 1.4)), hcf(2.4, 16.7, -8.92), DARK, { tr = 1, name = "Eyelid" .. side })
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
		-- Arms: chunky two-tone T-rex arms, big hands with white claws
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Chest", v(3.7, 12.5, -1.5))
			B:block(arm, v(2.2, 2.4, 2.4), cf(4.2, 12.4, -1.5), NAVY)
			B:block(arm, v(0.4, 1.6, 1.6), cf(5.35, 12.5, -1.5), DARK)
			B:block(arm, v(2.4, 0.6, 2.0), cf(4.3, 13.8, -1.5), LAV) -- shoulder pad
			B:spike(arm, v(5.0, 13.7, -1.4), v(6.4, 14.4, -1.0), 0.7, 0.7, LAV)
			B:beam(arm, v(4.3, 12, -1.8), v(4.6, 9.4, -3.4), 2.2, 2.2, NAVY)
			local fore = B:bone("Forearm" .. side, "Arm" .. side, v(4.6, 9.5, -3.4))
			B:beam(fore, v(4.6, 9.6, -3.3), v(4.3, 8.2, -5.6), 2.0, 2.0, DARK)
			B:beam(fore, v(5.62, 9.35, -3.6), v(5.36, 8.25, -5.4), 0.3, 0.3, CYAN, { mat = "Neon" })
			B:block(fore, v(2.6, 1.6, 2.4), cf(4.3, 7.9, -6.2), NAVY)
			B:block(fore, v(2.2, 0.4, 2.0), cf(4.3, 6.95, -6.1), BELLY) -- palm
			B:beam(fore, v(4.7, 9.4, -2.9), v(5.5, 10.8, -1.7), 0.7, 0.7, LAV)
			for k = -1, 1 do
				B:spike(fore, v(4.3 + k * 0.8, 7.6, -7.2), v(4.3 + k * 0.95, 6.5, -8.9), 0.7, 0.55, WHITE)
			end
			B:trail(fore, v(4.3, 7.4, -7.8), v(4.3, 6.6, -8.8), { name = "ClawTrail" .. side, color = CYAN, life = 0.18, trans = { 0.5, 1 } })
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
				B:emitter(dustAt, "dust", {
					name = "StompDust", color = { "#efe6d2", "#cfc3a8" }, size = { 2.5, 4.5, 5.5 }, speed = { 9, 16 },
					life = { 0.7, 1.3 }, trans = { 0.25, 0.45, 1 }, spread = 85,
				})
				B:emitter(dustAt, "burst", { name = "StompCubes", color = { LAV, CYAN }, speed = { 10, 18 }, size = { 0.9, 0.7, 0 } })
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
			plate(b, 0, c.Y + sz.Y / 2 - 0.05, c.Z - 0.4, s[3], sz.Z * 0.6, 6 - i)
			parent = name
		end
		-- stepped lavender spade with a glowing tip
		local tip = B:bone("TailTip", "Tail5", v(0, 3.2, 22))
		B:block(tip, v(2.0, 1.9, 0.6), cf(0, 3.2, 22.2), DARK)
		B:block(tip, v(1.2, 1.2, 1.6), cf(0, 3.2, 22.6), NAVY)
		B:block(tip, v(0.8, 2.6, 1), cf(0, 3.2, 23.0), LAV)
		B:block(tip, v(0.8, 1.8, 1), cf(0, 3.2, 24.0), LAV)
		B:block(tip, v(0.8, 1.0, 1), cf(0, 3.2, 25.0), LAV)
		B:block(tip, v(0.5, 0.5, 0.6), cf(0, 3.2, 25.7), CYAN, { mat = "Neon" })
		B:trail(tip, v(0, 4.0, 24.6), v(0, 2.4, 24.6), { name = "TailTrail", color = CYAN, life = 0.25, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- Floating voxel cubes orbiting like electrons on a tilted ring (low in
		-- front, high behind) so they circle the monster without crossing it.
		-- The motion uses the same ring formula (keep in sync).
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 9, 1))
		for i = 1, 4 do
			local th = math.rad((i - 1) * 90 + 20)
			local y = 8.5 - 5.0 * math.cos(th) + (i % 2 == 0 and 0.8 or 0)
			local p = v(10.5 * math.sin(th), y, 1 - 12 * math.cos(th))
			local ob = B:bone("Orb" .. i, "Orbit", p)
			local s = i % 2 == 0 and 2.0 or 2.4
			B:block(ob, v(s, s, s), CFrame.new(p), NAVY)
			B:block(ob, v(s + 0.1, s * 0.3, s + 0.1), CFrame.new(p + v(0, s * 0.36, 0)), LAV)
			B:block(ob, v(s + 0.16, s * 0.14, s + 0.16), CFrame.new(p + v(0, -s * 0.1, 0)), CYAN, { mat = "Neon" })
		end

		------------------------------------------------------------------
		-- Stomp shockwave: a ring of chunky dark slabs with a thin cyan top
		-- (one bone each) that burst outward from the right foot on impact
		------------------------------------------------------------------
		local SC = v(3.3, 0.4, 1.6)
		for k = 1, 12 do
			local a = (k - 1) / 12 * 360
			local sb = B:bone("Shock" .. k, "Root", SC)
			local at = CFrame.new(SC) * P.ang(0, a, 0) * CFrame.new(0, 0, -3.0)
			B:block(sb, v(2.0, 0.8, 1.4), at, DARK, { tr = 1, name = "Wave" .. k })
			B:block(sb, v(1.7, 0.2, 1.0), at * CFrame.new(0, 0.48, 0), CYAN, { mat = "Neon", tr = 1, name = "WaveTop" .. k })
		end
	end,
}
