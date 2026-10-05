--!nocheck
-- Atomic Kaiju: hunched stud-built titan with lavender dorsal plates, cyan
-- atomic accents and floating voxel cubes. Stud style reference monster.
return {
	DisplayName = "Atomic Kaiju",
	Rarity = "Secret",
	Element = "Nuclear",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local NAVY, DARK, LAV, BELLY = "#3550c4", "#222f80", "#cdc8ff", "#9fa8ec"
		local WHITE, MOUTH, TONGUE, CYAN = "#f4f4ff", "#15121f", "#d8487a", "#3fe6ff"

		-- voxel "plate": stacked steps that taper to a glowing tip
		local function plate(bone, x, y, z, steps, w, rz)
			local rot = P.ang(0, 0, rz or 0)
			local base = CFrame.new(x, y, z) * rot
			for i = 0, steps - 1 do
				local d = w * (1 - i / steps)
				B:block(bone, v(1.0, 1.1, math.max(0.7, d)), base * CFrame.new(0, i * 1.1 + 0.55, 0.2 * i), i == 0 and NAVY or LAV)
			end
			B:block(bone, v(0.7, 0.7, 0.7), base * CFrame.new(0, steps * 1.1 + 0.3, 0.2 * steps), CYAN, { mat = "Neon" })
		end

		------------------------------------------------------------------
		-- Hips + chest
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 7, 2))
		B:block(hips, v(6, 4, 5), cf(0, 7, 2.5), NAVY)
		B:block(hips, v(5, 1, 4), cf(0, 4.6, 2.5), DARK)
		plate(hips, 0, 9, 3.4, 2, 1.8)

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
			plate(chest, 1.4, 15.1, 0.2, 2, 1.6, -18)
		end)
		plate(chest, 0, 15.3, -1.2, 4, 2.4)
		plate(chest, 0, 15.3, 1.6, 3, 2.2)
		local spark = B:block(chest, v(5, 3, 4), cf(0, 12, 0.5), NAVY, { tr = 1, name = "AuraVolume" })
		B:emitter(spark, "sparkle", { color = { "#ffffff", CYAN }, rate = 4 })

		------------------------------------------------------------------
		-- Neck + head
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Chest", v(0, 13.5, -2.5))
		B:block(neck, v(4.6, 3.6, 3.6), cf(0, 14, -3.6), NAVY)
		B:block(neck, v(3.2, 1.6, 0.6), cf(0, 12.9, -5.2), BELLY)
		plate(neck, 0, 15.6, -3.4, 2, 1.6)

		-- head geometry is authored at 1x and scaled up around the head pivot for a
		-- big, readable cartoon head
		local HP, HS = v(0, 14.5, -5), 1.3
		local function hp(p) return HP + (p - HP) * HS end
		local function hcf(x, y, z, rx, ry, rz) return CFrame.new(hp(v(x, y, z))) * P.ang(rx, ry, rz) end
		local function hs(sz) return sz * HS end
		local head = B:bone("Head", "Neck", hp(v(0, 14.5, -5)))
		B:block(head, hs(v(5, 3, 4.6)), hcf(0, 15.6, -6.8), NAVY)
		B:block(head, hs(v(4, 1, 3.6)), hcf(0, 17.4, -6.4), NAVY)
		B:block(head, hs(v(4, 2, 3.6)), hcf(0, 15.2, -10.6), NAVY)
		B:block(head, hs(v(3, 0.8, 3)), hcf(0, 16.5, -10.0), NAVY)
		B:block(head, hs(v(3.4, 1.6, 1)), hcf(0, 15.1, -12.8), DARK)
		B:block(head, hs(v(3.6, 0.6, 5.2)), hcf(0, 14.0, -10.2), MOUTH)
		-- upper teeth (white voxel fangs hanging down)
		B:sym(function()
			for i = 0, 3 do
				B:block(head, hs(v(0.5, i % 2 == 0 and 0.9 or 0.6, 0.5)), hcf(1.55, 13.45 - (i % 2 == 0 and 0.15 or 0), -8.4 - i * 1.25), WHITE)
			end
			B:block(head, hs(v(0.5, 0.8, 0.5)), hcf(0.65, 13.5, -12.6), WHITE)
			-- nostril
			B:block(head, hs(v(0.6, 0.4, 0.2)), hcf(0.8, 15.6, -13.35), MOUTH)
			-- eye: glowing slit + dark pupil + heavy brow
			B:block(head, hs(v(0.4, 1.1, 1.2)), hcf(2.42, 16.1, -8.6), CYAN, { mat = "Neon", name = "Eye" })
			B:block(head, hs(v(0.42, 0.9, 0.3)), hcf(2.45, 16.05, -8.75), "#0b1030")
			B:block(head, hs(v(1.4, 0.8, 2.6)), hcf(2.2, 17.15, -8.5, 0, 0, -14), DARK)
			-- cheek stripe + cheek spike
			B:block(head, hs(v(0.3, 0.3, 2.2)), hcf(2.55, 15.0, -7.4), CYAN, { mat = "Neon" })
			B:beam(head, hp(v(2.4, 15.4, -5.6)), hp(v(4.1, 14.8, -3.8)), 1.04, 1.04, LAV)
			-- horns: two lavender segments, cyan tip
			B:beam(head, hp(v(1.6, 17.6, -6.2)), hp(v(2.6, 19.6, -5.0)), 1.56, 1.56, LAV)
			B:beam(head, hp(v(2.6, 19.4, -5.1)), hp(v(3.0, 20.5, -4.0)), 1.17, 1.17, LAV)
			B:block(head, hs(v(0.7, 0.7, 0.7)), hcf(3.05, 20.8, -3.8, 30, 0, -20), CYAN, { mat = "Neon" })
		end)
		plate(head, 0, 18.9, -5.5, 3, 1.8)
		local snout = B:block(head, hs(v(2, 1, 1)), hcf(0, 14.4, -12.6), NAVY, { tr = 1, name = "MouthFX" })
		B:emitter(snout, "burst", { name = "RoarBurst", color = { "#ffffff", CYAN } })
		B:emitter(snout, "spark", { name = "RoarSparks", color = CYAN, enabled = false, rate = 30 })
		B:light(snout, { name = "MouthLight", color = CYAN, brightness = 0, range = 14 })
		-- the atomic breath (hidden until the roar)
		B:block(head, hs(v(1.4, 1.4, 12)), hcf(0, 14.3, -19), "#e6fdff", { mat = "Neon", tr = 1, name = "AtomicBeam" })
		B:block(head, hs(v(2.4, 2.4, 11)), hcf(0, 14.3, -18.6), CYAN, { mat = "Neon", tr = 1, name = "AtomicBeamOuter" })

		-- eyelids for cartoon blinks (tucked under the brow at rest)
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", hp(v(2.42, 17.2, -8.6)))
			B:block(lid, hs(v(0.5, 1.1, 1.3)), hcf(2.45, 17.3, -8.6), NAVY)
		end)

		local jaw = B:bone("Jaw", "Head", hp(v(0, 14.2, -5.8)))
		B:block(jaw, hs(v(3.8, 1.2, 6)), hcf(0, 13.2, -9.2), NAVY)
		B:block(jaw, hs(v(3.2, 0.6, 5)), hcf(0, 12.4, -8.9), BELLY)
		B:block(jaw, hs(v(3.2, 0.3, 5.2)), hcf(0, 13.9, -9.3), MOUTH)
		B:block(jaw, hs(v(2, 0.3, 3)), hcf(0, 14.1, -8.6), TONGUE)
		B:sym(function()
			for i = 0, 3 do
				B:block(jaw, hs(v(0.5, 0.7, 0.5)), hcf(1.45, 14.25, -7.8 - i * 1.25), WHITE)
			end
		end)
		B:block(jaw, hs(v(1, 0.7, 0.5)), hcf(0, 14.25, -11.9), WHITE)

		------------------------------------------------------------------
		-- Arms
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Chest", v(3.7, 12.5, -1.5))
			B:block(arm, v(2.2, 2.4, 2.4), cf(4.2, 12.4, -1.5), NAVY)
			B:block(arm, v(0.4, 1.6, 1.6), cf(5.35, 12.5, -1.5), DARK)
			B:beam(arm, v(4.3, 12, -1.8), v(4.6, 9.4, -3.4), 1.8, 1.8, NAVY)
			local fore = B:bone("Forearm" .. side, "Arm" .. side, v(4.6, 9.5, -3.4))
			B:beam(fore, v(4.6, 9.6, -3.3), v(4.3, 8.2, -5.6), 1.6, 1.6, NAVY)
			B:block(fore, v(2, 1.2, 1.8), cf(4.3, 7.9, -6.1), NAVY)
			B:block(fore, v(1.6, 0.4, 1.4), cf(4.3, 7.2, -6.0), BELLY)
			B:beam(fore, v(4.7, 9.4, -2.9), v(5.4, 10.6, -1.8), 0.6, 0.6, LAV)
			for k = -1, 1 do
				B:spike(fore, v(4.3 + k * 0.6, 7.7, -6.9), v(4.3 + k * 0.7, 7.0, -7.9), 0.4, 0.4, WHITE)
			end
		end)

		------------------------------------------------------------------
		-- Legs
		------------------------------------------------------------------
		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Hips", v(2.8, 7.5, 2.5))
			B:block(thigh, v(3.2, 4.6, 4), cf(3.3, 6.2, 2.3), NAVY)
			B:block(thigh, v(0.4, 3, 3), cf(4.95, 6.3, 2.3), DARK)
			B:block(thigh, v(0.3, 0.3, 2.4), cf(5.2, 7.2, 2.3), CYAN, { mat = "Neon" })
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(3.3, 3.9, 2.8))
			B:block(shin, v(2.6, 3, 2.6), cf(3.3, 2.5, 3.0), NAVY)
			B:block(shin, v(2.2, 0.8, 0.4), cf(3.3, 2.6, 1.55), BELLY)
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(3.3, 1.0, 2.6))
			B:block(foot, v(3.2, 1.4, 4.4), cf(3.3, 0.7, 1.8), NAVY)
			B:block(foot, v(3.2, 0.8, 1), cf(3.3, 0.4, -0.9), DARK)
			for k = -1, 1 do
				B:wedge(foot, v(0.6, 0.7, 1.3), cf(3.3 + k * 1.05, 0.35, -2.0), WHITE)
			end
			B:wedge(foot, v(0.6, 0.6, 1.0), cf(3.3, 0.3, 4.4, 0, 180, 0), LAV)
			if side == "R" then
				local dustAt = B:block(foot, v(3, 0.2, 4), cf(3.3, 0.1, 1.8), NAVY, { tr = 1, name = "StompFX" })
				B:emitter(dustAt, "dust", { name = "StompDust", color = "#d8d0c0" })
			end
		end)

		------------------------------------------------------------------
		-- Tail (5 segments) with dorsal plates
		------------------------------------------------------------------
		local seg = {
			{ v(0, 7.0, 4.6), v(4.4, 3.6, 4), 6.0, 3 },
			{ v(0, 6.4, 8.2), v(3.6, 3.0, 4), 5.4, 3 },
			{ v(0, 5.4, 11.8), v(2.8, 2.4, 4), 4.4, 2 },
			{ v(0, 4.4, 15.4), v(2.2, 1.8, 3.8), 3.6, 2 },
			{ v(0, 3.5, 18.8), v(1.6, 1.4, 3.4), 2.8, 1 },
		}
		local parent = "Hips"
		for i, s in seg do
			local name = "Tail" .. i
			local b = B:bone(name, parent, s[1])
			local c = s[1] + v(0, -0.3, s[2].Z / 2)
			B:block(b, s[2], CFrame.new(c), NAVY)
			B:block(b, v(s[2].X - 0.6, 0.4, s[2].Z - 0.4), CFrame.new(c + v(0, -s[2].Y / 2 - 0.1, 0)), BELLY)
			plate(b, 0, c.Y + s[2].Y / 2, c.Z, s[4], s[2].Z * 0.45)
			parent = name
		end
		local tip = B:bone("TailTip", "Tail5", v(0, 3.2, 22))
		B:wedge(tip, v(1.2, 1.0, 2.2), cf(0, 3.2, 23.0, 0, 180, 0), NAVY)
		B:block(tip, v(0.5, 0.5, 0.5), cf(0, 3.4, 24.0), CYAN, { mat = "Neon" })
		B:trail(tip, v(0, 3.7, 23.5), v(0, 2.7, 23.5), { name = "TailTrail", color = CYAN, life = 0.25, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- Floating voxel cubes orbiting the kaiju (VFX)
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 9, 2))
		local spots = { { 9.5, 10.5, 0 }, { -9.0, 7.5, 3 }, { 7.5, 6.0, 9 }, { -6.5, 12.0, -5 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = i % 2 == 0 and 1.4 or 1.8
			B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), i % 2 == 0 and LAV or NAVY)
			B:block(ob, v(s + 0.1, s * 0.25, s + 0.1), cf(p[1], p[2], p[3]), CYAN, { mat = "Neon" })
		end
	end,
}
