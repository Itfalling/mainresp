--!nocheck
-- Toxic Ape King: a hulking stud-built gorilla king in a knuckle-walking
-- stance. Dark navy voxel fur with jagged stepped tufts, tan face / chest
-- plates / fists, angry red neon eyes under heavy brows, a big black mouth
-- full of white block fangs, a gold block crown with a toxic green gem, and
-- only small toxic-green neon accents (slime drips, spine tips, veins).
return {
	DisplayName = "Toxic Ape King",
	Rarity = "Mythic",
	Element = "Toxic",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		-- palette
		local NAVY, DARK, HI = "#33377a", "#1f2148", "#5a62b0" -- fur, deep fur, fur highlight
		local SILVER = "#868ccf" -- silverback saddle
		local TAN, TANS = "#d9c3a5", "#b79c7b" -- face / chest / hands, tan shade
		local WHITE, MOUTH, TONGUE = "#f7f4ec", "#120e16", "#d2405a"
		local GOLD, GOLDD, VELVET = "#f2b632", "#c4841a", "#c22f3f"
		local RED, TOX = "#ff3b1f", "#5dff3b" -- neon: eyes, toxic accents
		local NEON = { mat = "Neon" }

		-- jagged fur tuft: a blade spike from base a to tip b, two-tone
		-- (lit top wedge, deep shadow underside) for free voxel shading
		local function fur(bone, a, b, w, col)
			local top, bot = B:spike(bone, a, b, w, w * 0.75, col or NAVY)
			bot.Color = P.color(DARK)
			return top, bot
		end

		------------------------------------------------------------------
		-- Hips / rump + short legs
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 6.0, 3.4))
		B:block(hips, v(6.4, 3.8, 4.6), cf(0, 6.6, 3.8), NAVY)
		B:block(hips, v(5.2, 0.8, 3.2), cf(0, 8.8, 4.1), SILVER) -- silverback saddle step
		B:block(hips, v(5.4, 2.6, 0.5), cf(0, 6.8, 6.2), DARK)
		B:block(hips, v(5.6, 0.8, 3.8), cf(0, 4.5, 3.8), DARK)
		fur(hips, v(0, 9.0, 5.0), v(0, 10.4, 7.0), 1.6, HI)
		B:sym(function()
			fur(hips, v(2.4, 8.0, 5.8), v(3.4, 8.6, 7.6), 1.3, NAVY)
		end)

		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Hips", v(2.6, 5.8, 3.6))
			B:block(thigh, v(3.0, 3.2, 3.6), cf(3.0, 4.3, 3.8), NAVY)
			B:block(thigh, v(0.5, 2.2, 2.6), cf(4.55, 4.4, 3.8), DARK)
			fur(thigh, v(4.4, 5.2, 4.8), v(5.6, 4.4, 6.6), 1.2)
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(3.0, 2.9, 3.7))
			B:block(shin, v(2.6, 2.0, 2.8), cf(3.0, 2.0, 3.8), NAVY)
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(3.0, 1.1, 3.4))
			B:block(foot, v(3.0, 1.2, 4.2), cf(3.0, 0.6, 3.0), DARK)
			for k = -1, 1 do
				B:block(foot, v(0.8, 0.7, 0.7), cf(3.2 + k * 0.92, 0.35, 0.6), TAN)
			end
			B:block(foot, v(0.8, 0.8, 1.0), cf(1.45, 0.4, 1.4), TAN) -- big toe
			B:block(foot, v(2.4, 0.5, 1.6), cf(3.0, 1.35, 2.2), NAVY)
		end)

		------------------------------------------------------------------
		-- Chest / torso (stepped hunched back)
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Hips", v(0, 7.6, 1.6))
		B:block(chest, v(8.4, 5.4, 5.4), cf(0, 9.6, -0.4), NAVY)
		B:block(chest, v(7.2, 1.4, 4.4), cf(0, 12.9, 0.2), NAVY)
		B:block(chest, v(5.4, 0.8, 3.2), cf(0, 13.9, 0.7), SILVER)
		B:block(chest, v(5.4, 1.2, 0.4), cf(0, 13.3, 2.55), SILVER)
		B:block(chest, v(7.0, 4.2, 3.0), cf(0, 9.0, 2.6), NAVY)
		B:block(chest, v(5.8, 0.8, 2.4), cf(0, 11.4, 2.9), SILVER)
		B:block(chest, v(5.0, 1.4, 0.4), cf(0, 10.6, 4.25), SILVER)
		B:sym(function()
			B:block(chest, v(0.5, 4.0, 4.0), cf(4.3, 9.9, -0.3), DARK)
			-- tan chest plates: big pecs + stepped abs
			B:block(chest, v(3.6, 2.4, 0.6), cf(1.9, 9.4, -3.3), TAN)
			B:block(chest, v(1.6, 1.0, 0.5), cf(0.9, 7.6, -3.25), TANS)
		end)
		-- spine fur spikes with small toxic tips
		local spine = { { v(0, 14.2, -0.6), v(0, 16.4, 0.8), 1.8 }, { v(0, 14.2, 1.6), v(0, 15.9, 3.4), 1.6 }, { v(0, 11.7, 3.4), v(0, 13.2, 5.3), 1.4 } }
		for i, s in spine do
			fur(chest, s[1], s[2], s[3], HI)
			if i < 3 then
				B:block(chest, v(0.45, 0.45, 0.45), CFrame.new(s[2]), TOX, NEON)
			end
		end
		local aura = B:block(chest, v(9, 6, 8), cf(0, 10, 1), NAVY, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "bubble", { name = "ToxicBubbles", color = { TOX, "#c8ff9a" }, rate = 3, size = { 0.2, 0.4, 0.5 } })
		local poundAt = B:block(chest, v(4, 2.5, 0.5), cf(0, 10, -3.8), NAVY, { tr = 1, name = "PoundFX" })
		B:emitter(poundAt, "burst", { name = "PoundBurst", color = { "#ffffff", TOX }, speed = { 6, 12 }, size = { 0.7, 0.4, 0 } })

		------------------------------------------------------------------
		-- Head: authored at 1x around a design pivot, then scaled up 1.15x
		-- for a big readable cartoon head.
		------------------------------------------------------------------
		local DP, HP, HS = v(0, 12.4, -2.8), v(0, 11.0, -2.8), 1.15
		local function hp(p) return HP + (p - DP) * HS end
		local function hcf(x, y, z, rx, ry, rz) return CFrame.new(hp(v(x, y, z))) * P.ang(rx, ry, rz) end
		local function hs(sz) return sz * HS end
		local function hblock(bone, sz, x, y, z, col, opts, rx, ry, rz)
			return B:block(bone, hs(sz), hcf(x, y, z, rx, ry, rz), col, opts)
		end

		local head = B:bone("Head", "Chest", hp(DP))
		-- stretchy neck: hidden inside the chest at rest, shows when the head rises
		B:block(head, v(5.0, 4.4, 3.0), cf(0, 9.6, -1.5), NAVY)
		hblock(head, v(6.4, 4.4, 4.8), 0, 14.0, -5.0, NAVY)
		hblock(head, v(5.0, 2.2, 0.6), 0, 14.3, -7.55, TAN) -- upper face
		hblock(head, v(4.8, 1.6, 2.2), 0, 12.7, -8.3, TAN) -- muzzle
		hblock(head, v(2.8, 0.9, 0.6), 0, 13.1, -9.6, TANS) -- wide flat nose
		hblock(head, v(1.6, 0.5, 0.5), 0, 13.7, -9.45, TANS)
		hblock(head, v(0.9, 1.3, 0.3), 0, 14.25, -7.9, TANS) -- nose bridge between the eyes
		hblock(head, v(4.2, 0.4, 2.6), 0, 11.8, -8.0, MOUTH) -- mouth roof
		hblock(head, v(4.6, 2.8, 0.6), 0, 10.9, -6.6, MOUTH) -- throat
		B:sym(function()
			hblock(head, v(0.7, 0.4, 0.14), 0.62, 12.85, -9.92, MOUTH) -- nostril
			-- heavy angry brow (tilted down toward the middle)
			hblock(head, v(3.0, 1.2, 1.6), 1.4, 15.55, -7.9, DARK, nil, 0, 0, 14)
			-- glowing red eye in a dark socket + pupil
			hblock(head, v(1.9, 1.2, 0.2), 1.4, 14.35, -7.9, DARK)
			hblock(head, v(1.5, 0.9, 0.3), 1.4, 14.35, -7.95, RED, { mat = "Neon", name = "Eye" })
			hblock(head, v(0.45, 0.85, 0.1), 1.05, 14.3, -8.13, "#1a0606")
			hblock(head, v(0.25, 0.25, 0.08), 1.85, 14.6, -8.12, WHITE) -- glint
			-- upper fangs (stepped white blocks) + incisors
			hblock(head, v(0.8, 0.9, 0.8), 1.65, 11.5, -8.9, WHITE)
			hblock(head, v(0.5, 0.6, 0.5), 1.65, 10.8, -8.9, WHITE)
			hblock(head, v(0.55, 0.65, 0.55), 0.55, 11.6, -9.0, WHITE)
			-- dark sideburns + jagged cheek tufts framing the face
			hblock(head, v(0.6, 3.4, 3.4), 3.25, 13.4, -5.4, DARK)
			fur(head, hp(v(3.1, 12.6, -6.0)), hp(v(5.0, 11.4, -4.6)), 1.6)
			fur(head, hp(v(3.1, 14.6, -4.6)), hp(v(4.8, 15.0, -2.8)), 1.5, NAVY)
			hblock(head, v(0.6, 1.2, 1.0), 3.45, 13.6, -3.6, TANS) -- ear
		end)
		local mouthAt = B:block(head, v(2.5, 1, 1), hcf(0, 11.2, -9.9), NAVY, { tr = 1, name = "MouthFX" })
		B:emitter(mouthAt, "burst", { name = "ToxicBreath", tex = "smoke", color = { TOX, "#b6ff8c" }, enabled = false, rate = 26, speed = { 7, 12 }, spread = 20, size = { 1.2, 2.6, 3.4 }, life = { 0.5, 0.9 }, trans = { 0.35, 0.5, 1 }, light = 0.35, dir = "Front", drag = 2 })
		B:emitter(mouthAt, "burst", { name = "RoarBurst", color = { "#ffffff", TOX } })
		B:light(mouthAt, { name = "MouthLight", color = TOX, brightness = 0.01, range = 12 })

		-- eyelids for cartoon blinks (tucked inside the brow at rest)
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", hp(v(1.35, 15.2, -7.95)))
			hblock(lid, v(1.4, 0.95, 0.3), 1.35, 15.25, -8.0, DARK)
		end)

		-- lower jaw
		local jaw = B:bone("Jaw", "Head", hp(v(0, 11.8, -6.0)))
		hblock(jaw, v(4.4, 1.4, 3.6), 0, 10.9, -7.8, TAN)
		hblock(jaw, v(3.6, 0.6, 2.8), 0, 10.0, -7.6, TANS)
		hblock(jaw, v(3.8, 0.3, 3.0), 0, 11.6, -7.6, MOUTH)
		hblock(jaw, v(2.2, 0.3, 2.0), 0, 11.8, -7.2, TONGUE)
		B:sym(function()
			hblock(jaw, v(0.6, 1.0, 0.6), 1.85, 12.0, -9.0, WHITE)
			hblock(jaw, v(0.45, 0.5, 0.45), 0.75, 11.85, -9.15, WHITE)
		end)
		-- toxic drool hanging off the lip corner
		hblock(jaw, v(0.35, 1.4, 0.35), 2.35, 10.4, -9.3, TOX, NEON)
		local droolTip = B:block(jaw, hs(v(0.5, 0.5, 0.5)), hcf(2.35, 9.55, -9.3), TOX, NEON)
		B:emitter(droolTip, "drip", { name = "Drool", color = TOX, rate = 3 })

		------------------------------------------------------------------
		-- Crown (gold blocks, stepped points, toxic gem) sits on the head
		------------------------------------------------------------------
		local crown = B:bone("Crown", "Head", hp(v(0, 16.2, -5.0)))
		hblock(crown, v(5.8, 0.5, 4.6), 0, 16.3, -5.0, GOLDD)
		hblock(crown, v(5.4, 0.8, 4.2), 0, 16.9, -5.0, GOLD)
		hblock(crown, v(4.0, 0.6, 3.0), 0, 17.45, -5.0, VELVET)
		local pts = { { 0, -7.0, 1.0 }, { 2.4, -6.9, 0.7 }, { 2.6, -5.0, 0.8 }, { 2.4, -3.1, 0.7 }, { 0, -3.0, 0.8 } }
		for i, p in pts do
			local function point()
				local x, z, h = p[1], p[2], p[3]
				hblock(crown, v(0.9, 0.5, 0.9), x, 17.5, z, GOLD)
				hblock(crown, v(0.55, h * 0.8, 0.55), x, 17.75 + h * 0.4, z, GOLD)
				if i == 1 then
					hblock(crown, v(0.4, 0.4, 0.4), x, 17.95 + h * 0.8, z, TOX, NEON)
				else
					hblock(crown, v(0.35, 0.35, 0.35), x, 17.9 + h * 0.8, z, GOLDD)
				end
			end
			if p[1] == 0 then
				point()
			else
				B:sym(point)
			end
		end
		-- front gem in a diamond setting
		hblock(crown, v(1.2, 1.2, 0.25), 0, 16.9, -7.2, GOLDD, nil, 0, 0, 45)
		hblock(crown, v(0.7, 0.7, 0.25), 0, 16.9, -7.32, TOX, NEON, 0, 0, 45)
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
			fur(arm, v(4.6, 13.4, -1.4), v(5.2, 15.8, -2.2), 1.5, HI)
			fur(arm, v(5.8, 13.4, 0.0), v(7.2, 15.3, 0.8), 1.4, HI)
			fur(arm, v(6.6, 12.0, -1.0), v(8.8, 12.8, -1.2), 1.3)
			-- slime blob on the shoulder
			B:block(arm, v(1.2, 0.3, 1.0), cf(5.6, 13.8, -1.3), TOX, NEON)
			B:block(arm, v(0.35, 1.0, 0.35), cf(5.9, 13.1, -2.65), TOX, NEON)
			B:block(arm, v(3.0, 3.6, 3.0), cf(5.6, 8.2, -1.2), NAVY)
			B:block(arm, v(0.5, 2.6, 2.2), cf(7.15, 8.4, -1.2), DARK)
			fur(arm, v(7.0, 9.2, -0.2), v(8.6, 7.4, 0.8), 1.2)

			local fore = B:bone("Forearm" .. side, "Arm" .. side, v(5.8, 6.8, -1.4))
			B:block(fore, v(3.8, 4.0, 3.8), cf(6.0, 4.6, -1.8), NAVY)
			B:block(fore, v(3.2, 1.0, 3.2), cf(6.0, 6.7, -1.6), NAVY)
			B:block(fore, v(0.5, 2.6, 2.6), cf(7.95, 4.8, -1.8), DARK)
			fur(fore, v(6.4, 5.8, 0.0), v(7.4, 5.0, 2.4), 1.4)
			fur(fore, v(7.7, 5.2, -0.8), v(9.4, 4.2, 0.2), 1.2)
			B:block(fore, v(0.3, 2.0, 0.3), cf(8.25, 4.8, -2.6), TOX, NEON) -- toxic vein
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
		-- Slam FX on the ground in front (fixed to Root): burst, dust,
		-- light and a voxel shockwave square that expands outward.
		------------------------------------------------------------------
		local slamAt = B:block("Root", v(6, 0.3, 4), cf(0, 0.3, -6.5), NAVY, { tr = 1, name = "SlamFX" })
		B:emitter(slamAt, "burst", { name = "SlamBurst", color = { TOX, "#ffffff" }, speed = { 10, 20 }, size = { 1.1, 0.7, 0 } })
		B:emitter(slamAt, "dust", { name = "SlamDust", color = "#d8d0c0" })
		B:light(slamAt, { name = "SlamLight", color = TOX, brightness = 0.01, range = 16 })
		local waves = { { 0, -3, 7.0, 1.0 }, { 0, 3, 7.0, 1.0 }, { 3, 0, 1.0, 7.0 }, { -3, 0, 1.0, 7.0 } }
		for i, w in waves do
			local wb = B:bone("Wave" .. i, "Root", v(0, 0.15, -6.5))
			B:block(wb, v(w[3], 0.3, w[4]), cf(w[1], 0.15, -6.5 + w[2]), TOX, { mat = "Neon", tr = 1, name = "Shock" .. i })
		end
		-- chunks of turf / dirt blasted up by the fists (hidden until the slam)
		local rocks = { { 5.6, 0.5, -8.6, 1.1, "#7a5636" }, { 3.4, 0.5, -9.2, 0.8, "#4cc23a" }, { 5.4, 0.5, -6.2, 0.9, "#8c6a44" } }
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
				B:block(ob, v(1.7, 0.3, 1.7), cf(p[1], p[2], p[3]), TOX, NEON)
			else
				B:block(ob, v(1.3, 1.3, 1.3), cf(p[1], p[2], p[3]), GOLD)
				B:block(ob, v(1.4, 0.3, 1.4), cf(p[1], p[2], p[3]), GOLDD)
			end
		end
	end,
}
