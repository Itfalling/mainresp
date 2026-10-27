--!nocheck
-- Rune Stingray: a calm, mysterious manta from sunken Atlantis, stud-built in
-- the Void Leviathan voxel style. Deep navy-teal top with darker stepped wing
-- panels, pale aqua underside, a grid of carved marble rune tiles across the
-- wings (tiny turquoise neon glyph dots), stepped orichalcum-gold leading
-- edges, curled cephalic "horn" lobes, a sleepy half-lidded wise face with a
-- forehead rune and an aloof little smirk, and a long whip tail (6 bones)
-- ending in a gold rune-blade stinger. Wings are 3 bones per side so they
-- ripple in an outward travelling wave.
-- Hidden FX parts (rune glyph flashes, a spell circle, voxel bubbles) are
-- revealed by the motion during the "Rune Surge".
return {
	DisplayName = "Rune Stingray",
	Rarity = "Rare",
	Element = "Atlantis",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad, cos, sin = math.rad, math.cos, math.sin

		-- palette
		local NAVY, DARK, DEEP = "#1f4f6b", "#143347", "#0c2232"
		local MID = "#2b6a86" -- lighter navy for raised steps
		local PALE, PALE2 = "#bfeee6", "#dcfaf4"
		local MARBLE, MARBLE2 = "#eef1e6", "#d6dccf"
		local GOLD, DGOLD = "#e9b53c", "#b98429"
		local MOUTH, PUPIL = "#081118", "#0a1822"
		local TURQ, GOLDN = "#3ff0e0", "#ffe27a" -- neon accents (small!)
		local NEON = { mat = "Neon" }

		local Y0 = 5.0 -- body center height (underside floats ~3.3 studs up)
		local function V(x, y, z) return v(x, Y0 + y, z) end
		local function C(x, y, z, rx, ry, rz) return cf(x, Y0 + y, z, rx or 0, ry or 0, rz or 0) end

		------------------------------------------------------------------
		-- BODY: stepped disc (pale belly, navy core, dark stepped dome)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", V(0, 0, 0))
		B:block(body, v(8.0, 2.0, 9.2), C(0, 0, 0.4), NAVY)
		B:block(body, v(7.2, 0.5, 8.4), C(0, -1.2, 0.4), PALE)
		B:block(body, v(4.6, 0.3, 6.0), C(0, -1.55, 0.2), PALE2)
		B:block(body, v(7.0, 0.5, 8.2), C(0, 1.2, 0.6), DARK)
		B:block(body, v(5.2, 0.5, 6.6), C(0, 1.65, 0.8), MID)
		B:block(body, v(3.4, 0.5, 5.0), C(0, 2.1, 1.0), DARK)
		-- shoulder bumps (stepped) where the wings meet the dome
		B:sym(function()
			B:block(body, v(1.4, 0.5, 4.0), C(3.0, 1.55, -0.6), DARK)
			-- little broken Atlantis column stub (stepped base, shaft, gold capital)
			B:block(body, v(1.1, 0.4, 1.1), C(2.4, 2.0, -1.6), MARBLE2)
			B:block(body, v(0.6, 0.9, 0.6), C(2.4, 2.6, -1.6), MARBLE)
			B:block(body, v(0.9, 0.3, 0.9), C(2.4, 3.15, -1.6), GOLD)
			B:block(body, v(1.0, 0.4, 1.0), C(2.4, 2.0, 1.2), MARBLE2)
			-- dark belly spots + gill slits on the pale belly
			B:block(body, v(0.8, 0.12, 0.8), C(1.3, -1.78, 2.6), MID)
			B:block(body, v(0.6, 0.12, 0.6), C(2.6, -1.52, 3.6), MID)
			-- gill slits
			for k = 0, 2 do
				B:block(body, v(1.6, 0.12, 0.25), C(2.3, -1.72, -1.6 + k * 0.9), DARK)
			end
		end)
		-- central rune medallion: gold frame, marble tile, neon glyph cross
		B:block(body, v(3.0, 0.3, 3.0), C(0, 2.45, 0.6), GOLD)
		B:block(body, v(2.3, 0.3, 2.3), C(0, 2.7, 0.6), MARBLE)
		B:block(body, v(1.5, 0.1, 0.3), C(0, 2.88, 0.6), TURQ, NEON)
		B:block(body, v(0.3, 0.1, 1.5), C(0, 2.88, 0.6), TURQ, NEON)
		B:block(body, v(0.7, 0.4, 0.7), C(0, 2.8, 0.6, 0, 45, 0), GOLD)
		-- small stepped dorsal fin at the tail base
		B:block(body, v(0.6, 1.0, 1.6), C(0, 1.9, 4.0), DARK)
		B:block(body, v(0.5, 0.7, 1.0), C(0, 2.7, 4.3), NAVY)
		B:block(body, v(0.55, 0.45, 0.6), C(0, 3.2, 4.55), GOLD)

		local fx = B:block(body, v(7, 3, 8), C(0, 0, 0.4), PALE, { tr = 1, name = "BodyFX" })
		B:emitter(fx, "bubble", { name = "AmbientBubbles", color = { "#ffffff", PALE }, rate = 1.5, size = { 0.3, 0.5, 0.6 }, speed = { 1, 3 } })
		B:emitter(fx, "sparkle", { name = "RuneSparkle", color = { "#ffffff", TURQ }, rate = 2 })
		B:emitter(fx, "burst", { name = "SurgeBurst", color = { "#ffffff", TURQ, GOLDN }, speed = { 10, 18 }, size = { 1.0, 0.6, 0 }, life = { 0.5, 1.0 } })
		B:emitter(fx, "bubble", { name = "BubbleBurst", color = { "#ffffff", PALE, TURQ }, rate = 0, size = { 0.4, 0.7, 0.8 }, speed = { 5, 10 }, spread = 180, life = { 1.0, 1.8 } })
		B:light(fx, { name = "BodyLight", color = TURQ, brightness = 0.3, range = 14 })

		------------------------------------------------------------------
		-- HEAD: wide manta head with a big sleepy wise face
		------------------------------------------------------------------
		local head = B:bone("Head", "Body", V(0, 0, -3.9))
		-- taller head front = a big face panel; the top stays low and flat so
		-- the manta silhouette is smooth from every angle
		B:block(head, v(7.2, 3.2, 3.4), C(0, 0.4, -5.5), NAVY)
		B:block(head, v(6.4, 0.4, 3.0), C(0, 2.2, -5.3), DARK)
		B:block(head, v(3.6, 0.4, 2.2), C(0, 2.6, -5.0), MID)
		B:block(head, v(6.2, 0.4, 2.6), C(0, -1.3, -5.0), PALE)
		-- forehead step (sits behind the lids, gives the brows a base)
		B:block(head, v(6.8, 0.9, 0.8), C(0, 2.35, -7.05), DARK)
		-- pale aqua muzzle (manta face) with a calm mouth and a smug raised
		-- corner on one side (aloof smirk)
		B:block(head, v(6.6, 1.5, 0.15), C(0, -0.45, -7.26), PALE)
		B:block(head, v(4.0, 0.42, 0.1), C(-0.3, -0.6, -7.36), MOUTH)
		B:block(head, v(0.6, 0.42, 0.1), C(-2.5, -0.45, -7.36), MOUTH)
		B:block(head, v(0.7, 0.42, 0.1), C(1.95, -0.4, -7.36), MOUTH)
		B:block(head, v(0.5, 0.42, 0.1), C(2.45, -0.15, -7.36), MOUTH)
		-- forehead rune: gold diamond with a turquoise glyph (the wise "third eye")
		B:block(head, v(0.95, 0.95, 0.2), C(0, 2.45, -7.52, 0, 0, 45), GOLD)
		B:block(head, v(0.42, 0.42, 0.1), C(0, 2.45, -7.65, 0, 0, 45), TURQ, { mat = "Neon", name = "ThirdEye" })

		B:sym(function(side)
			-- big glowing eye set into the face panel
			B:block(head, v(2.7, 2.1, 0.1), C(1.95, 1.15, -7.27), DEEP) -- socket
			B:block(head, v(2.3, 1.7, 0.1), C(1.95, 1.15, -7.37), TURQ, { mat = "Neon", name = "Eye" .. side })
			-- pupil on its own bone so the eyes can side-eye (aloof glance)
			local pup = B:bone("Pupil" .. side, "Head", V(1.95, 1.0, -7.46))
			B:block(pup, v(1.25, 1.25, 0.1), C(1.95, 1.0, -7.47), "#04080c")
			B:block(pup, v(0.36, 0.36, 0.06), C(2.3, 0.75, -7.54), "#ffffff", NEON) -- glint
			-- side cheek plate with a marble scale
			B:block(head, v(0.3, 1.6, 2.4), C(3.68, -0.1, -5.6), DARK)
			B:block(head, v(0.12, 0.8, 0.8), C(3.85, 0.0, -5.4), MARBLE)
			-- heavy half-closed lid (rest pose covers the top half of the eye)
			local lid = B:bone("Lid" .. side, "Head", V(1.95, 1.3, -7.56))
			B:block(lid, v(2.5, 1.8, 0.14), C(1.95, 2.2, -7.56, 0, 0, -5), MID)
			B:block(lid, v(2.6, 0.24, 0.2), C(1.95, 1.33, -7.6, 0, 0, -5), GOLD) -- lash line
			-- low heavy brow ridge in front of the lid, outer end drooping
			-- (sleepy & wise); raises when it wakes up / when it judges you
			local brow = B:bone("Brow" .. side, "Head", V(1.2, 2.5, -7.9))
			B:block(brow, v(2.5, 0.8, 0.6), C(2.05, 2.45, -7.98, 0, 0, -9), DARK)
			B:block(brow, v(2.1, 0.3, 0.5), C(2.0, 2.92, -7.9, 0, 0, -9), NAVY)
			B:block(brow, v(0.45, 0.45, 0.2), C(3.0, 2.3, -8.32, 0, 0, -9), GOLD) -- rune stud

			-- cephalic fins: horn-like lobes framing the face, scrolling UP at
			-- the tip (2 bones); pushed outboard so they never hide the eyes
			local cx = 4.05
			local ceph = B:bone("Ceph" .. side, "Head", V(cx - 0.1, -0.4, -6.9))
			B:block(ceph, v(1.1, 1.4, 2.6), C(cx, -0.1, -8.0), NAVY)
			B:block(ceph, v(0.14, 1.0, 2.2), C(cx - 0.6, -0.1, -8.0), PALE)
			B:block(ceph, v(1.15, 0.3, 0.8), C(cx, -0.65, -9.0), GOLD) -- orichalcum band
			B:block(ceph, v(1.15, 0.3, 2.2), C(cx, 0.68, -8.0), DARK)
			local tip = B:bone("CephTip" .. side, "Ceph" .. side, V(cx, -0.2, -9.1))
			B:block(tip, v(1.0, 1.5, 1.4), C(cx, 0.2, -9.6, 35, 0, 0), NAVY)
			B:block(tip, v(0.12, 1.1, 1.1), C(cx - 0.56, 0.2, -9.6, 35, 0, 0), PALE)
			B:block(tip, v(0.85, 1.3, 0.9), C(cx, 1.3, -10.0, 70, 0, 0), NAVY)
			B:block(tip, v(0.75, 0.9, 0.75), C(cx, 2.15, -9.85), GOLD)
			B:block(tip, v(0.35, 0.35, 0.35), C(cx, 2.75, -9.85), TURQ, NEON)
		end)

		-- lower lip on its own bone (calm breathing / soft "oh")
		local jaw = B:bone("Jaw", "Head", V(0, -0.9, -5.6))
		B:block(jaw, v(5.6, 0.5, 1.0), C(0, -1.15, -6.95), PALE)
		-- chin skin (pale, NOT a second dark mouth line when the lip drops)
		B:block(jaw, v(4.8, 0.2, 0.8), C(0, -0.86, -6.85), PALE2)
		-- pale filler on the head behind the lip: hidden at rest, fills the
		-- gap when the lip drops so it never reads as a second mouth
		B:block(head, v(5.4, 0.8, 0.7), C(0, -1.45, -6.95), PALE)

		-- voxel bubbles that drift up out of the mouth (hidden)
		local BC = V(0, -0.4, -8.0)
		for k = 1, 3 do
			local bb = B:bone("Bubble" .. k, "Root", BC)
			local s = k == 2 and 0.7 or 0.5
			B:block(bb, v(s, s, s), CFrame.new(BC), PALE2, { tr = 1, name = "BubblePart" .. k })
		end

		------------------------------------------------------------------
		-- WINGS: 3 bones per side, built from stepped chord strips. Each strip:
		-- navy core, dark top panel, pale underside, gold leading edge trim,
		-- and a row of marble rune tiles with tiny neon glyph dots (+ hidden
		-- glyph flash plates named Rune<side><n>).
		------------------------------------------------------------------
		B:sym(function(side)
			local n = 0
			local function strip(bone, x0, x1, zf, zb, th, yc, tiles, spots)
				local w, xc, len, zc = x1 - x0, (x0 + x1) / 2, zb - zf, (zf + zb) / 2
				B:block(bone, v(w, th, len), C(xc, yc, zc), NAVY)
				B:block(bone, v(w - 0.2, 0.3, len - 0.7), C(xc, yc + th / 2 + 0.15, zc + 0.2), DARK)
				B:block(bone, v(w - 0.2, 0.3, len - 0.7), C(xc, yc - th / 2 - 0.15, zc + 0.1), PALE)
				B:block(bone, v(w + 0.06, th * 0.8, 0.7), C(xc, yc + 0.05, zf - 0.2), GOLD)
				-- manta belly spots (so the underside reads during the roll)
				if spots then
					for _, z in spots do
						B:block(bone, v(math.min(0.9, w - 0.5), 0.12, 0.9), C(xc, yc - th / 2 - 0.35, z), MID)
					end
				end
				for _, z in tiles do
					n += 1
					local ty = yc + th / 2 + 0.4
					local ts = math.min(1.1, w - 0.4)
					B:block(bone, v(ts, 0.2, 1.1), C(xc, ty, z), n % 3 == 0 and MARBLE2 or MARBLE)
					B:block(bone, v(0.35, 0.1, 0.35), C(xc, ty + 0.12, z), TURQ, NEON)
					B:block(bone, v(ts - 0.25, 0.06, 0.85), C(xc, ty + 0.11, z), TURQ, { mat = "Neon", tr = 1, name = "Rune" .. side .. n })
				end
			end
			local w1 = B:bone("Wing1" .. side, "Body", V(3.8, 0, 0.2))
			strip(w1, 3.4, 5.2, -3.6, 4.7, 1.6, 0, { -2.0, 0.0, 2.0 }, { -1.0, 2.6 })
			strip(w1, 5.2, 6.65, -2.6, 4.3, 1.35, 0, { -1.0, 1.0, 3.0 }, { 0.6 })
			local w2 = B:bone("Wing2" .. side, "Wing1" .. side, V(6.5, 0, 0.9))
			strip(w2, 6.45, 7.65, -1.6, 3.9, 1.1, 0.05, { 0.0, 2.0 }, { 1.2 })
			strip(w2, 7.65, 8.75, -0.6, 3.5, 0.9, 0.08, { 0.8, 2.6 }, { 2.0 })
			local w3 = B:bone("Wing3" .. side, "Wing2" .. side, V(8.6, 0.1, 1.6))
			strip(w3, 8.55, 9.65, 0.4, 3.2, 0.75, 0.12, { 1.8 })
			strip(w3, 9.65, 10.65, 1.3, 3.0, 0.6, 0.16, {})
			B:block(w3, v(0.9, 0.5, 0.9), C(11.05, 0.2, 2.45), NAVY)
			B:block(w3, v(0.7, 0.45, 0.7), C(11.6, 0.25, 2.6), GOLD)
			B:block(w3, v(0.3, 0.3, 0.3), C(11.95, 0.3, 2.65), TURQ, NEON)
			B:trail(w3, V(11.7, 0.25, 2.2), V(11.0, 0.25, 3.3), { name = "WingTrail" .. side, color = { "#ffffff", TURQ }, life = 0.4, trans = { 0.5, 1 } })

			-- pelvic fins
			local pel = B:bone("Pelvic" .. side, "Body", V(1.8, -0.5, 4.6))
			B:block(pel, v(1.5, 0.45, 1.8), C(2.3, -0.5, 5.4), NAVY)
			B:block(pel, v(1.2, 0.2, 1.4), C(2.3, -0.8, 5.4), PALE)
			B:block(pel, v(0.8, 0.4, 0.6), C(2.6, -0.5, 6.5), DARK)
		end)

		------------------------------------------------------------------
		-- WHIP TAIL: 6 bones, tapering, gold orichalcum collars
		------------------------------------------------------------------
		local W = { 1.6, 1.3, 1.1, 0.9, 0.75, 0.6 }
		local z0 = 4.4
		local parent = "Body"
		local SEG = 1.9
		local lastTail
		for i = 1, 6 do
			local za = z0 + (i - 1) * SEG
			local t = B:bone("Tail" .. i, parent, V(0, 0.1, za + 0.1))
			local w = W[i]
			local h = w * 0.8
			B:block(t, v(w, h, SEG + 0.25), C(0, 0.1, za + SEG / 2 + 0.1), NAVY)
			B:block(t, v(w * 0.6, 0.2, SEG - 0.2), C(0, 0.1 + h / 2 + 0.1, za + SEG / 2 + 0.1), DARK)
			if i % 2 == 1 then
				B:block(t, v(w + 0.2, h + 0.2, 0.35), C(0, 0.1, za + 0.35), GOLD)
			elseif i < 6 then
				B:spike(t, V(0, 0.1 + h / 2, za + 0.9), V(0, 0.9 + h / 2, za + 1.6), 0.35, 0.3, DGOLD)
			end
			parent = "Tail" .. i
			lastTail = t
		end
		-- gold rune-blade stinger (flat spade with marble inlay + neon rune line)
		local zb = z0 + 6 * SEG -- 15.8
		local blade = B:bone("Sting", "Tail6", V(0, 0.1, zb - 0.1))
		B:block(blade, v(1.6, 0.4, 1.0), C(0, 0.1, zb + 0.4), GOLD)
		B:block(blade, v(1.2, 0.4, 0.9), C(0, 0.1, zb + 1.2), GOLD)
		B:block(blade, v(0.8, 0.4, 0.8), C(0, 0.1, zb + 1.9), GOLD)
		B:spike(blade, V(0, 0.1, zb + 2.2), V(0, 0.1, zb + 3.4), 0.6, 0.4, GOLD)
		B:sym(function()
			B:spike(blade, V(0.7, 0.1, zb + 0.4), V(1.3, 0.1, zb - 0.5), 0.4, 0.3, DGOLD)
		end)
		B:block(blade, v(0.6, 0.12, 1.8), C(0, 0.34, zb + 1.0), MARBLE)
		B:block(blade, v(0.22, 0.08, 1.5), C(0, 0.43, zb + 1.0), TURQ, NEON)
		local sting = B:block(blade, v(1, 1, 1), C(0, 0.1, zb + 2.0), GOLD, { tr = 1, name = "StingFX" })
		B:emitter(sting, "burst", { name = "CrackBurst", color = { "#ffffff", TURQ, GOLDN }, speed = { 8, 16 }, size = { 0.9, 0.5, 0 }, life = { 0.3, 0.7 } })
		B:light(sting, { name = "StingLight", color = GOLDN, brightness = 0.2, range = 8 })
		B:trail(blade, V(0, 0.1, zb + 3.3), V(0, 0.1, zb + 1.2), { name = "StingTrail", color = { GOLDN, TURQ }, life = 0.35, trans = { 0.35, 1 } })

		------------------------------------------------------------------
		-- Floating rune-tile cubes (marble cube, gold band, neon glyph)
		------------------------------------------------------------------
		local orbs = { { 11.5, 9.0, -5.0, 1.5 }, { -12.0, 10.0, 1.0, 1.3 }, { 8.5, 11.0, 8.5, 1.2 }, { -8.0, 8.0, -9.0, 1.4 } }
		for i, o in orbs do
			local ob = B:bone("Orb" .. i, "Root", v(o[1], o[2], o[3]))
			local s = o[4]
			B:block(ob, v(s, s, s), cf(o[1], o[2], o[3]), i % 2 == 0 and MARBLE2 or MARBLE)
			B:block(ob, v(s + 0.12, s * 0.25, s + 0.12), cf(o[1], o[2] - s * 0.25, o[3]), GOLD)
			B:block(ob, v(s * 0.4, s * 0.4, s + 0.08), cf(o[1], o[2] + s * 0.15, o[3]), TURQ, NEON)
		end

		------------------------------------------------------------------
		-- SPELL CIRCLE (hidden): turquoise rune ring under the ray, revealed
		-- and spun during the Rune Surge
		------------------------------------------------------------------
		local SC = v(0, 0.3, 0.5)
		local spell = B:bone("Spell", "Root", SC)
		for k = 0, 7 do
			local a = rad(k * 45)
			local p = SC + v(sin(a) * 7.2, 0, cos(a) * 7.2)
			B:block(spell, v(4.6, 0.15, 0.45), CFrame.new(p) * P.ang(0, k * 45, 0), TURQ, { mat = "Neon", tr = 1, name = "Spell" .. (k + 1) })
		end
		for k = 0, 3 do
			local a = rad(k * 90 + 45)
			local p = SC + v(sin(a) * 4.4, 0, cos(a) * 4.4)
			B:block(spell, v(1.1, 0.15, 1.1), CFrame.new(p) * P.ang(0, 45, 0), GOLDN, { mat = "Neon", tr = 1, name = "Spell" .. (k + 9) })
		end
		local sfx = B:block(spell, v(10, 0.4, 10), CFrame.new(SC), TURQ, { tr = 1, name = "SpellFX" })
		B:emitter(sfx, "sparkle", { name = "SpellSparkle", color = { "#ffffff", TURQ, GOLDN }, rate = 0, speed = { 2, 5 }, accel = { 0, 4, 0 } })
	end,
}
