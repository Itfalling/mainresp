--!nocheck
-- Toxic Ape King: a hulking stud-built gorilla king in a knuckle-walking
-- stance. Royal navy voxel fur with stepped, axis-aligned fur tufts, a light
-- lavender-silver back, tan face / chest plates / fists, angry red neon eyes
-- under heavy brows, a big black mouth packed with white block teeth, a
-- chunky gold block crown with a toxic green gem, and only small toxic-green
-- neon accents (slime drips, spine tips, veins). Detail comes from colour
-- blocking and stepped blocks, not part spam.
return {
	DisplayName = "Toxic Ape King",
	Rarity = "Mythic",
	Element = "Toxic",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		-- palette
		local NAVY, DARK, HI = "#3b4196", "#22255a", "#5f68c8" -- fur, deep fur, fur highlight
		local SILVER, LAV = "#9aa0e2", "#c4c8f6" -- silverback, lavender tips
		local TAN, TANS = "#e0c9a8", "#b99c78" -- face / chest / hands, tan shade
		local WHITE, MOUTH, TONGUE = "#ffffff", "#120e16", "#d8405e"
		local GOLD, GOLDD, VELVET = "#f6bd34", "#c4841a", "#c22f3f"
		local BROW = "#14152e"
		local RED, TOX = "#ff2a10", "#5dff3b" -- neon: eyes, toxic accents
		local SLIME, SLIMED = "#9dff7a", "#62e04a" -- plastic slime (no glow)
		local NEON = { mat = "Neon" }

		-- stepped voxel fur tuft from a (base) to b (tip): three axis-aligned
		-- blocks that shrink toward the tip. Each block is stretched along the
		-- tuft direction so the steps always overlap (no floating pieces).
		local function fur(bone, a, b, w, c0, c1, c2)
			local d = b - a
			local ext = v(math.abs(d.X), math.abs(d.Y), math.abs(d.Z)) * 0.35
			B:block(bone, v(w, 1.0, w) + ext, CFrame.new(a), c0 or NAVY)
			B:block(bone, v(0.65 * w, 1.0, 0.65 * w) + ext, CFrame.new(a + d * 0.45), c1 or HI)
			return B:block(bone, v(0.35 * w, 0.8, 0.35 * w) + ext, CFrame.new(b), c2 or LAV)
		end

		------------------------------------------------------------------
		-- Hips / rump + short legs
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 6.0, 3.4))
		B:block(hips, v(6.4, 3.8, 4.6), cf(0, 6.6, 3.8), NAVY)
		B:block(hips, v(5.2, 0.8, 3.2), cf(0, 8.8, 4.1), SILVER) -- silverback saddle step
		B:block(hips, v(5.4, 2.6, 0.5), cf(0, 6.8, 6.2), DARK)
		B:block(hips, v(5.6, 0.8, 3.8), cf(0, 4.5, 3.8), DARK)
		-- royal gold belt with a toxic buckle gem
		B:block(hips, v(6.8, 0.8, 5.0), cf(0, 6.3, 3.8), GOLD)
		B:block(hips, v(5.8, 0.35, 0.3), cf(0, 6.3, 6.45), GOLDD)
		B:block(hips, v(1.3, 1.1, 0.3), cf(0, 6.3, 1.2), GOLDD)
		B:block(hips, v(0.7, 0.7, 0.3), cf(0, 6.3, 1.05), TOX, NEON)
		fur(hips, v(0, 8.9, 5.7), v(0, 9.6, 7.4), 1.6, NAVY, HI, LAV)

		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Hips", v(2.6, 5.8, 3.6))
			B:block(thigh, v(3.0, 3.2, 3.6), cf(3.0, 4.3, 3.8), NAVY)
			B:block(thigh, v(0.5, 2.2, 2.6), cf(4.55, 4.4, 3.8), DARK)
			B:block(thigh, v(2.4, 0.9, 0.4), cf(3.0, 3.3, 1.9), HI) -- knee plate
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(3.0, 2.9, 3.7))
			B:block(shin, v(2.6, 2.0, 2.8), cf(3.0, 2.0, 3.8), DARK)
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(3.0, 1.1, 3.4))
			B:block(foot, v(3.0, 1.2, 4.2), cf(3.0, 0.6, 3.0), DARK)
			B:block(foot, v(3.2, 0.4, 4.4), cf(3.0, 0.2, 3.0), NAVY)
			for k = -1, 1 do
				B:block(foot, v(0.8, 0.7, 0.7), cf(3.2 + k * 0.92, 0.35, 0.6), TAN)
			end
			B:block(foot, v(0.8, 0.8, 1.0), cf(1.45, 0.4, 1.4), TAN) -- big toe
			B:block(foot, v(2.4, 0.5, 1.6), cf(3.0, 1.35, 2.2), NAVY)
		end)

		------------------------------------------------------------------
		-- Chest / torso (stepped hunched back, silverback saddle, pot belly)
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Hips", v(0, 7.6, 1.6))
		B:block(chest, v(8.4, 5.4, 5.4), cf(0, 9.6, -0.4), NAVY)
		B:block(chest, v(7.2, 1.4, 4.4), cf(0, 12.9, 0.2), NAVY)
		B:block(chest, v(5.4, 0.8, 3.2), cf(0, 13.9, 0.7), SILVER)
		B:block(chest, v(5.4, 1.2, 0.4), cf(0, 13.3, 2.55), SILVER)
		B:block(chest, v(7.0, 4.2, 3.0), cf(0, 9.0, 2.6), NAVY)
		B:block(chest, v(5.8, 0.8, 2.4), cf(0, 11.4, 2.9), SILVER)
		B:block(chest, v(5.0, 1.4, 0.4), cf(0, 10.6, 4.25), SILVER)
		B:block(chest, v(6.0, 1.4, 4.0), cf(0, 6.5, -0.7), NAVY) -- pot belly
		B:block(chest, v(2.4, 0.9, 0.5), cf(0, 6.55, -2.9), TANS) -- lowest ab row
		B:sym(function()
			B:block(chest, v(0.5, 4.0, 4.0), cf(4.3, 9.9, -0.3), DARK)
			B:block(chest, v(0.3, 0.3, 2.6), cf(4.6, 10.6, -0.4), TOX, NEON) -- toxic vein
			-- tan chest plates: big pecs (with a lit top step) + stepped abs
			B:block(chest, v(3.6, 2.4, 0.6), cf(1.9, 9.4, -3.3), TAN)
			B:block(chest, v(3.0, 0.6, 0.4), cf(1.9, 10.75, -3.25), TAN)
			B:block(chest, v(1.6, 1.0, 0.5), cf(0.9, 7.6, -3.25), TANS)
		end)
		-- spine: stepped lavender-silver plates with small toxic tips
		local spine = { { v(0, 14.1, -0.4), v(0, 15.8, 0.9), 1.8 }, { v(0, 13.9, 1.9), v(0, 15.2, 3.2), 1.6 }, { v(0, 11.6, 3.9), v(0, 12.8, 5.3), 1.4 } }
		for _, s in spine do
			fur(chest, s[1], s[2], s[3], SILVER, LAV, LAV)
			B:block(chest, v(0.45, 0.45, 0.45), CFrame.new(s[2] + v(0, 0.55, 0)), TOX, NEON)
		end
		local aura = B:block(chest, v(9, 6, 8), cf(0, 10, 1), NAVY, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "bubble", { name = "ToxicBubbles", color = { TOX, "#c8ff9a" }, rate = 3, size = { 0.2, 0.4, 0.5 } })
		local poundAt = B:block(chest, v(5, 2.5, 0.5), cf(0, 9.6, -3.9), NAVY, { tr = 1, name = "PoundFX" })
		B:emitter(poundAt, "burst", { name = "PoundBurst", color = { "#ffffff", TOX }, speed = { 6, 12 }, size = { 0.7, 0.4, 0 } })

		------------------------------------------------------------------
		-- Head: authored at 1x around a design pivot DP, then scaled up 1.3x
		-- about HP for a big, readable cartoon head that clears the shoulders.
		------------------------------------------------------------------
		local DP, HP, HS = v(0, 12.4, -2.8), v(0, 11.6, -3.4), 1.3
		local function hp(p) return HP + (p - DP) * HS end
		local function hcf(x, y, z, rx, ry, rz) return CFrame.new(hp(v(x, y, z))) * P.ang(rx, ry, rz) end
		local function hs(sz) return sz * HS end
		local function hblock(bone, sz, x, y, z, col, opts, rx, ry, rz)
			return B:block(bone, hs(sz), hcf(x, y, z, rx, ry, rz), col, opts)
		end

		local head = B:bone("Head", "Chest", HP)
		-- stretchy neck: hidden inside the chest at rest, shows when the head rises
		B:block(head, v(5.0, 6.0, 3.0), cf(0, 9.4, -1.6), NAVY)
		B:block(head, v(5.4, 0.8, 3.2), cf(0, 11.0, -1.6), DARK)
		hblock(head, v(6.4, 4.4, 4.8), 0, 14.0, -5.0, NAVY) -- cranium
		hblock(head, v(5.2, 0.6, 4.0), 0, 16.05, -4.8, DARK) -- under the crown
		hblock(head, v(5.0, 2.2, 0.6), 0, 14.3, -7.55, TAN) -- upper face
		hblock(head, v(4.8, 1.6, 2.2), 0, 12.7, -8.3, TAN) -- muzzle
		hblock(head, v(2.8, 0.9, 0.6), 0, 13.1, -9.6, TANS) -- wide flat nose
		hblock(head, v(1.6, 0.5, 0.5), 0, 13.7, -9.45, TANS)
		hblock(head, v(0.9, 1.3, 0.3), 0, 14.25, -7.9, TANS) -- nose bridge between the eyes
		hblock(head, v(4.2, 0.4, 2.6), 0, 11.8, -8.0, MOUTH) -- mouth roof
		hblock(head, v(4.6, 2.8, 0.6), 0, 10.9, -6.6, MOUTH) -- throat
		-- upper teeth: a full row of white blocks (alternating long / short)
		for i = -2, 2 do
			local h = i % 2 == 0 and 0.75 or 0.55
			hblock(head, v(0.45, h, 0.5), i * 0.5, 11.95 - h / 2, -9.0, WHITE)
		end
		B:sym(function()
			hblock(head, v(0.7, 0.3, 0.14), 0.62, 12.85, -9.92, MOUTH) -- nostril
			-- heavy angry brow (tilted down toward the middle, overhangs the eye)
			hblock(head, v(3.2, 1.4, 1.8), 1.4, 15.55, -7.3, BROW, nil, 0, 0, 22)
			-- glowing red eye in a dark socket + square pupil + glint
			hblock(head, v(1.9, 1.2, 0.2), 1.4, 14.35, -7.9, DARK)
			hblock(head, v(1.5, 0.9, 0.3), 1.4, 14.35, -7.95, RED, { mat = "Neon", name = "Eye" })
			hblock(head, v(0.55, 0.55, 0.1), 1.15, 14.25, -8.13, "#1a0606")
			hblock(head, v(0.25, 0.25, 0.08), 1.8, 14.55, -8.12, WHITE) -- glint
			-- big fangs at the corners of the upper row
			hblock(head, v(0.7, 1.3, 0.7), 1.6, 11.35, -8.95, WHITE)
			-- stepped sideburns / cheek fluff framing the face
			hblock(head, v(0.6, 3.4, 3.4), 3.25, 13.4, -5.4, DARK)
			hblock(head, v(0.7, 2.2, 2.6), 3.6, 12.6, -5.7, NAVY)
			hblock(head, v(0.6, 1.2, 1.6), 3.95, 11.9, -5.9, HI)
			hblock(head, v(0.6, 1.2, 1.0), 3.45, 14.3, -3.8, TANS) -- ear
		end)
		local mouthAt = B:block(head, v(2.5, 1, 1), hcf(0, 11.2, -9.9), NAVY, { tr = 1, name = "MouthFX" })
		B:emitter(mouthAt, "burst", { name = "ToxicBreath", tex = "smoke", color = { TOX, "#b6ff8c" }, enabled = false, rate = 26, speed = { 7, 12 }, spread = 20, size = { 1.2, 2.6, 3.4 }, life = { 0.5, 0.9 }, trans = { 0.45, 0.6, 1 }, light = 0.25, dir = "Front", drag = 2 })
		B:emitter(mouthAt, "burst", { name = "RoarBurst", color = { "#ffffff", TOX } })
		B:light(mouthAt, { name = "MouthLight", color = TOX, brightness = 0.01, range = 12 })

		-- eyelids for cartoon blinks: hidden at rest, shown + dropped to blink.
		-- Their front face sits in front of the pupil and glint (no poke-through).
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", hp(v(1.4, 15.2, -8.0)))
			hblock(lid, v(1.75, 1.0, 0.45), 1.4, 15.25, -8.15, NAVY, { tr = 1, name = "Eyelid" .. side })
		end)

		-- lower jaw
		local jaw = B:bone("Jaw", "Head", hp(v(0, 11.8, -6.0)))
		hblock(jaw, v(4.4, 1.4, 3.6), 0, 10.9, -7.8, TAN)
		hblock(jaw, v(3.6, 0.6, 2.8), 0, 10.0, -7.6, TANS)
		hblock(jaw, v(3.8, 0.3, 3.0), 0, 11.6, -7.6, MOUTH)
		hblock(jaw, v(2.2, 0.3, 2.0), 0, 11.8, -7.2, TONGUE)
		B:sym(function()
			for _, x in { 0.35, 1.05 } do
				hblock(jaw, v(0.5, 0.6, 0.5), x, 11.9, -9.1, WHITE)
			end
			hblock(jaw, v(0.65, 1.1, 0.65), 2.0, 12.15, -9.0, WHITE) -- tusk
		end)
		-- toxic slime drip hanging off the lip corner (plastic blob + tiny neon tip)
		hblock(jaw, v(0.6, 0.6, 0.5), 1.55, 10.95, -9.75, SLIME)
		local droolTip = hblock(jaw, v(0.35, 0.6, 0.35), 1.55, 10.45, -9.75, TOX, NEON)
		B:emitter(droolTip, "drip", { name = "Drool", color = TOX, rate = 3 })

		------------------------------------------------------------------
		-- Crown: chunky gold band + 5 stepped block points + toxic gem
		------------------------------------------------------------------
		local crown = B:bone("Crown", "Head", hp(v(0, 16.2, -5.0)))
		hblock(crown, v(5.8, 0.5, 4.6), 0, 16.3, -5.0, GOLDD)
		hblock(crown, v(5.4, 0.8, 4.2), 0, 16.9, -5.0, GOLD)
		hblock(crown, v(4.0, 0.6, 3.0), 0, 17.45, -4.9, VELVET)
		local function point(x, z, tall)
			local k = tall and 1.5 or 1
			hblock(crown, v(1.0, 0.6 * k, 1.0), x, 17.25 + 0.3 * k, z, GOLD)
			hblock(crown, v(0.7, 0.8 * k, 0.7), x, 17.5 + 0.6 * k + 0.4 * k, z, GOLD)
			hblock(crown, v(0.45, 0.5 * k, 0.45), x, 17.5 + 1.4 * k + 0.25 * k, z, tall and TOX or GOLDD, tall and NEON or nil)
		end
		point(0, -6.7, true)
		B:sym(function()
			point(2.25, -6.6)
			point(2.4, -4.6)
		end)
		-- front gem in a diamond setting
		hblock(crown, v(1.3, 1.3, 0.25), 0, 16.9, -7.2, GOLDD, nil, 0, 0, 45)
		hblock(crown, v(0.75, 0.75, 0.25), 0, 16.9, -7.32, TOX, NEON, 0, 0, 45)
		B:sym(function()
			hblock(crown, v(0.2, 0.6, 0.6), 2.75, 16.9, -5.0, VELVET)
		end)
		local crownFx = B:block(crown, v(6, 2.5, 5), hcf(0, 17.3, -5.0), NAVY, { tr = 1, name = "CrownFX" })
		B:emitter(crownFx, "sparkle", { name = "RoyalSparkle", color = { "#ffffff", "#ffe08a" }, rate = 4 })

		------------------------------------------------------------------
		-- Huge arms + fists (knuckle walking)
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Chest", v(4.6, 11.4, -0.8))
			B:block(arm, v(3.6, 3.4, 3.8), cf(5.1, 11.3, -0.8), NAVY)
			B:block(arm, v(3.0, 0.8, 3.0), cf(5.3, 13.3, -0.6), HI)
			B:block(arm, v(0.5, 2.4, 3.0), cf(6.95, 11.2, -0.8), DARK)
			-- shoulder fur: stepped tufts sweeping BACK, kept under the eye line
			fur(arm, v(4.6, 13.4, 0.3), v(4.8, 13.75, 2.3), 1.5, NAVY, HI, LAV)
			fur(arm, v(6.2, 13.2, 0.1), v(6.6, 13.5, 1.9), 1.3, NAVY, HI, LAV)
			-- slime blob on the shoulder (plastic) with a tiny glowing drip
			B:block(arm, v(1.2, 0.3, 1.0), cf(5.6, 13.8, -1.3), SLIME)
			B:block(arm, v(0.4, 0.8, 0.4), cf(5.9, 13.2, -2.55), SLIMED)
			B:block(arm, v(0.3, 0.35, 0.3), cf(5.9, 12.65, -2.55), TOX, NEON)
			B:block(arm, v(3.0, 3.6, 3.0), cf(5.6, 8.2, -1.2), NAVY)
			B:block(arm, v(0.5, 2.6, 2.2), cf(7.15, 8.4, -1.2), DARK)

			local fore = B:bone("Forearm" .. side, "Arm" .. side, v(5.8, 6.8, -1.4))
			B:block(fore, v(3.8, 4.0, 3.8), cf(6.0, 4.6, -1.8), NAVY)
			B:block(fore, v(3.2, 1.0, 3.2), cf(6.0, 6.7, -1.6), NAVY)
			B:block(fore, v(0.5, 2.6, 2.6), cf(7.95, 4.8, -1.8), DARK)
			fur(fore, v(6.2, 5.6, 0.1), v(6.4, 5.1, 2.0), 1.4, NAVY, HI, LAV) -- elbow fur
			B:block(fore, v(0.3, 2.0, 0.3), cf(8.25, 4.8, -2.6), TOX, NEON) -- toxic vein
			-- slime dribbles on the dark side panel (plastic, no glow)
			B:block(fore, v(0.3, 0.7, 0.6), cf(8.3, 5.6, -1.3), SLIME)
			B:block(fore, v(0.3, 0.5, 0.35), cf(8.3, 4.9, -1.25), SLIMED)
			B:block(fore, v(0.25, 0.3, 0.3), cf(8.3, 4.3, -1.3), SLIME)
			B:block(fore, v(4.1, 0.9, 4.1), cf(6.0, 3.1, -1.8), GOLD) -- royal wrist cuff
			B:block(fore, v(4.3, 0.35, 4.3), cf(6.0, 3.55, -1.8), GOLDD)

			local fist = B:bone("Fist" .. side, "Forearm" .. side, v(6.0, 2.6, -1.8))
			B:block(fist, v(3.4, 2.5, 3.6), cf(6.0, 1.3, -2.1), TAN)
			for k = 0, 3 do
				B:block(fist, v(0.75, 1.1, 0.5), cf(4.85 + k * 0.77, 1.0, -4.05), k % 2 == 0 and TANS or TAN)
			end
			B:block(fist, v(0.9, 0.9, 1.4), cf(4.05, 1.6, -3.0), TANS) -- thumb
			B:block(fist, v(3.0, 0.4, 3.0), cf(6.0, 2.55, -2.1), DARK)
			B:trail(fist, v(6.0, 2.2, -4.2), v(6.0, 0.3, -4.2), { name = "FistTrail" .. side, color = { TOX, "#ffffff" }, life = 0.22, trans = { 0.35, 1 } })
		end)

		------------------------------------------------------------------
		-- Slam FX on the ground in front (fixed to Root): burst, dust, light,
		-- a ring of voxel debris cubes and turf chunks blasted outward.
		------------------------------------------------------------------
		local SC = v(0, 0.4, -6.2)
		local slamAt = B:block("Root", v(6, 0.3, 4), cf(0, 0.3, -6.2), NAVY, { tr = 1, name = "SlamFX" })
		B:emitter(slamAt, "burst", { name = "SlamBurst", color = { TOX, "#ffffff" }, speed = { 10, 20 }, size = { 1.1, 0.7, 0 } })
		B:emitter(slamAt, "dust", { name = "SlamDust", color = "#d8d0c0" })
		B:light(slamAt, { name = "SlamLight", color = TOX, brightness = 0.01, range = 16 })
		for k = 1, 8 do
			local a = (k - 1) * 45 + 22.5
			local wb = B:bone("Wave" .. k, "Root", SC)
			local base = CFrame.new(SC) * P.ang(0, a, 0) * CFrame.new(0, 0, -2.2)
			B:block(wb, v(1.0, 0.8, 1.0), base, SLIME, { tr = 1, name = "Shock" .. k })
			B:block(wb, v(0.9, 0.2, 0.9), base * CFrame.new(0, 0.48, 0), TOX, { mat = "Neon", tr = 1, name = "ShockCap" .. k })
		end
		-- chunks of turf / dirt blasted up by the fists (hidden until the slam)
		local rocks = { { 4.4, 0.6, -8.4, 1.4, "#7a5636" }, { 2.0, 0.6, -9.2, 1.0, "#4cc23a" }, { 4.4, 0.6, -5.6, 1.2, "#8c6a44" } }
		B:sym(function(side)
			for i, r in rocks do
				local rb = B:bone("Rock" .. side .. i, "Root", v(r[1], r[2], r[3]))
				B:block(rb, v(r[4], r[4], r[4]), cf(r[1], r[2], r[3]), r[5], { tr = 1, name = "Rock" .. side .. i })
			end
		end)

		------------------------------------------------------------------
		-- Floating voxel cubes orbiting the king
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 9, 1))
		local spots = { { 11, 10, -2 }, { -11, 8, 4 }, { 8.5, 5, 10 }, { -8, 13, -8 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			if i % 2 == 1 then
				B:block(ob, v(1.6, 1.6, 1.6), cf(p[1], p[2], p[3]), DARK)
				B:block(ob, v(1.7, 0.45, 1.7), cf(p[1], p[2] + 0.6, p[3]), LAV)
				B:block(ob, v(1.68, 0.2, 1.68), cf(p[1], p[2] - 0.1, p[3]), TOX, NEON)
			else
				B:block(ob, v(1.3, 1.3, 1.3), cf(p[1], p[2], p[3]), GOLD)
				B:block(ob, v(1.4, 0.3, 1.4), cf(p[1], p[2], p[3]), GOLDD)
			end
		end
	end,
}
