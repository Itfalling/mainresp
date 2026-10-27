--!nocheck
-- Trident Swordfish: a brave, hot-headed knight of sunken Atlantis. A sleek
-- stud-built swordfish (royal blue back, dark blue top, silver-white belly)
-- whose bill is a long ORICHALCUM GOLD TRIDENT with a turquoise crystal set in
-- its bronze collar. Bronze/gold armor plates engraved with runes run along the
-- flanks, a knight's gorget rings the neck, gold pauldrons cap the sickle pec
-- fins, a tall stepped multi-bone sail fin (gold trim) rides the back and a
-- crescent tail sweeps behind. Big determined cartoon face: angry-heroic brows,
-- half-lidded glowing turquoise eyes, gritted white teeth, a crystal helm plume.
-- Neon is kept to the eyes, the crystal, rune dots and tips. Hidden VFX (slash
-- ring, impact shards, victory glint) are revealed by the "Trident Lunge".
return {
	DisplayName = "Trident Swordfish",
	Rarity = "Epic",
	Element = "Atlantis",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette
		local BLUE, DARK, NAVY = "#2f5fd0", "#1c3a8a", "#132a66"
		local BELLY, SILVER = "#e8eef5", "#bccadc"
		local GOLD, DGOLD, BRONZE, ENGRAVE = "#f2b632", "#d08a1e", "#b06a26", "#7a4310"
		local MARBLE, BARNACLE = "#f4efe2", "#e3d6b8"
		local CRYSTAL = "#2ad1c4"
		local WHITE, PUPIL, BROW, MOUTH, TONGUE = "#ffffff", "#0d1020", "#0b1538", "#2a0d18", "#ff7f8f"
		local TURQ, GLOW = "#3ff0e0", "#ffe27a" -- the two (small) neon accents
		local NEON = { mat = "Neon" }
		local Y0 = 7.5

		------------------------------------------------------------------
		-- helpers
		------------------------------------------------------------------
		-- countershaded body segment: blue core, dark back band + top cap,
		-- silver-white lower band + belly cap
		local function segment(bone, z0, z1, w, h, yc)
			local len, zc = z1 - z0, (z0 + z1) / 2
			B:block(bone, v(w, h, len), cf(0, yc, zc), BLUE)
			B:block(bone, v(w * 0.7, 0.6, len - 0.2), cf(0, yc + h / 2 + 0.25, zc), DARK)
			B:block(bone, v(w + 0.1, h * 0.3, len - 0.2), cf(0, yc + h * 0.36, zc), DARK)
			B:block(bone, v(w + 0.1, h * 0.3, len - 0.2), cf(0, yc - h * 0.36, zc), BELLY)
			B:block(bone, v(w * 0.78, 0.7, len - 0.4), cf(0, yc - h / 2 - 0.25, zc), BELLY)
		end
		-- rune-engraved orichalcum armor plate on the right flank (call in B:sym)
		local function plate(bone, x, y, z, h, d)
			B:block(bone, v(0.3, h, d), cf(x, y, z), BRONZE)
			B:block(bone, v(0.36, h - 0.6, d - 0.6), cf(x + 0.05, y, z), GOLD)
			B:block(bone, v(0.4, 0.25, d - 1.2), cf(x + 0.08, y + 0.35, z), ENGRAVE) -- rune bar
			B:block(bone, v(0.4, (h - 0.6) * 0.45, 0.25), cf(x + 0.08, y - 0.1, z - (d - 1.2) / 2 + 0.12), ENGRAVE) -- rune stem
			B:block(bone, v(0.42, 0.35, 0.35), cf(x + 0.1, y - 0.45, z + 0.3), TURQ, NEON) -- rune dot
		end

		------------------------------------------------------------------
		-- BODY1: the puffed-out armored chest (swim chain center)
		------------------------------------------------------------------
		local body1 = B:bone("Body1", "Root", v(0, Y0, -1.0))
		B:block(body1, v(4.8, 5.6, 5.0), cf(0, 7.5, -0.9), BLUE)
		B:block(body1, v(3.4, 0.6, 4.8), cf(0, 10.55, -0.9), DARK)
		B:block(body1, v(4.9, 1.6, 4.8), cf(0, 9.55, -0.9), DARK)
		B:block(body1, v(4.9, 1.6, 4.8), cf(0, 5.5, -0.9), BELLY)
		-- puffed chest: stepped silver belly bulging down and forward
		B:block(body1, v(4.4, 1.0, 4.8), cf(0, 4.3, -1.1), BELLY)
		B:block(body1, v(3.2, 0.7, 3.6), cf(0, 3.5, -1.5), SILVER)
		B:block(body1, v(4.5, 0.2, 0.4), cf(0, 4.2, 0.3), SILVER) -- belly scale lines
		B:block(body1, v(4.5, 0.2, 0.4), cf(0, 4.2, -1.6), SILVER)
		-- gold plastron on the chest front with a rune crystal
		B:block(body1, v(3.8, 1.8, 0.6), cf(0, 4.5, -3.55), GOLD)
		B:block(body1, v(2.6, 0.4, 0.65), cf(0, 5.3, -3.6), BRONZE)
		B:block(body1, v(0.6, 0.6, 0.2), cf(0, 4.4, -3.9), TURQ, NEON)
		-- knight's gorget: bronze collar with gold rims (wider than head + body)
		B:block(body1, v(5.4, 6.2, 0.7), cf(0, 7.4, -2.95), BRONZE)
		B:block(body1, v(5.6, 0.5, 0.8), cf(0, 10.5, -2.95), GOLD)
		B:block(body1, v(5.0, 0.5, 0.8), cf(0, 4.35, -2.95), GOLD)
		B:sym(function()
			B:block(body1, v(0.2, 0.5, 0.5), cf(2.75, 7.6, -2.95), TURQ, NEON)
			plate(body1, 2.45, 7.5, -1.8, 2.8, 2.2)
			plate(body1, 2.45, 7.3, 0.5, 2.4, 2.0)
		end)
		local bodyFx = B:block(body1, v(6, 6, 12), cf(0, 7.5, 1.0), BLUE, { tr = 1, name = "BodyFX" })
		B:emitter(bodyFx, "bubble", { name = "AmbientBubbles", color = { "#ffffff", "#9fe2ff" }, rate = 4, size = { 0.2, 0.4, 0.5 } })
		B:emitter(bodyFx, "sparkle", { name = "AmbientSparkle", color = { "#ffffff", GLOW, TURQ }, rate = 3 })
		B:emitter(bodyFx, "bubble", { name = "SlashBubbles", color = { "#ffffff", "#9fe2ff" }, rate = 40, enabled = false, size = { 0.3, 0.6, 0.7 }, speed = { 2, 6 }, spread = 140 })
		B:emitter(bodyFx, "burst", { name = "VictorySparkle", color = { "#ffffff", GLOW, TURQ }, speed = { 6, 14 }, size = { 1.0, 0.7, 0 }, life = { 0.6, 1.2 } })

		------------------------------------------------------------------
		-- BODY2 + TAIL chain
		------------------------------------------------------------------
		local body2 = B:bone("Body2", "Body1", v(0, Y0, 1.5))
		segment(body2, 1.3, 5.1, 4.2, 4.8, 7.6)
		B:block(body2, v(4.4, 5.0, 0.4), cf(0, 7.6, 1.45), BRONZE) -- armor seam ring
		B:sym(function()
			plate(body2, 2.15, 7.4, 3.3, 2.2, 1.8)
		end)
		-- barnacles (worn ruin feel, one side only)
		B:block(body2, v(0.5, 0.6, 0.6), cf(2.15, 5.4, 4.5), BARNACLE)
		B:block(body2, v(0.4, 0.4, 0.4), cf(2.2, 5.7, 3.9), MARBLE)
		B:block(body2, v(0.4, 0.5, 0.5), cf(-2.15, 9.0, 4.4), BARNACLE)
		-- pelvic fins
		B:sym(function(side)
			local pv = B:bone("Pelvic" .. side, "Body2", v(0.9, 4.7, 2.2))
			B:beam(pv, v(0.9, 4.8, 2.0), v(1.5, 3.5, 3.7), 0.5, 0.45, BLUE)
			B:block(pv, v(0.55, 0.5, 0.6), cf(1.5, 3.45, 3.75), GOLD)
		end)

		local tail1 = B:bone("Tail1", "Body2", v(0, 7.6, 5.0))
		segment(tail1, 4.8, 7.6, 3.2, 3.6, 7.6)
		B:block(tail1, v(3.4, 3.8, 0.4), cf(0, 7.6, 5.0), BRONZE)
		B:block(tail1, v(0.5, 1.0, 1.2), cf(0, 10.25, 6.6), GOLD) -- second dorsal
		B:block(tail1, v(0.4, 0.5, 0.6), cf(0, 10.9, 6.9), DGOLD)
		B:block(tail1, v(0.5, 1.0, 1.2), cf(0, 4.7, 6.6), BLUE) -- anal fin
		B:block(tail1, v(0.5, 0.45, 0.6), cf(0, 4.05, 6.9), GOLD)

		local tail2 = B:bone("Tail2", "Tail1", v(0, 7.6, 7.4))
		segment(tail2, 7.2, 9.2, 2.3, 2.5, 7.6)
		B:block(tail2, v(2.5, 2.7, 0.35), cf(0, 7.6, 7.3), BRONZE)
		B:block(tail2, v(0.4, 0.6, 0.7), cf(0, 9.55, 8.6), GOLD) -- finlets
		B:block(tail2, v(0.4, 0.6, 0.7), cf(0, 5.65, 8.6), GOLD)

		local tail3 = B:bone("Tail3", "Tail2", v(0, 7.6, 9.0))
		B:block(tail3, v(1.5, 1.6, 1.6), cf(0, 7.6, 9.7), BLUE)
		B:block(tail3, v(1.0, 0.3, 1.5), cf(0, 8.5, 9.7), DARK)
		B:block(tail3, v(2.4, 0.5, 1.3), cf(0, 7.6, 9.8), DARK) -- caudal keel
		B:block(tail3, v(1.7, 1.8, 0.3), cf(0, 7.6, 9.0), GOLD)

		------------------------------------------------------------------
		-- CRESCENT TAIL: stepped rows sweeping back, gold leading edges
		------------------------------------------------------------------
		local FY = 7.6
		local fin = B:bone("TailFin", "Tail3", v(0, FY, 10.3))
		B:block(fin, v(1.2, 2.6, 1.4), cf(0, FY, 10.9), BLUE)
		B:block(fin, v(1.3, 0.8, 0.6), cf(0, FY, 11.5), GOLD)
		local rows = {
			{ 1.6, 10.4, 12.0, 1.0, BLUE }, { 2.6, 11.0, 12.6, 0.9, BLUE },
			{ 3.6, 11.6, 13.1, 0.8, DARK }, { 4.5, 12.2, 13.5, 0.7, DARK },
		}
		for _, dir in { 1, -1 } do
			for _, r in rows do
				local y = FY + r[1] * dir
				B:block(fin, v(r[4], 1.05, r[3] - r[2]), cf(0, y, (r[2] + r[3]) / 2), r[5])
				B:block(fin, v(r[4] + 0.1, 1.0, 0.5), cf(0, y, r[2] + 0.2), GOLD)
			end
			B:block(fin, v(0.5, 0.5, 0.6), cf(0, FY + 5.2 * dir, 13.6), TURQ, NEON)
			B:trail(fin, v(0, FY + 5.2 * dir, 13.6), v(0, FY + 3.8 * dir, 13.0), { name = dir > 0 and "TailTrailTop" or "TailTrailBot", color = { "#ffffff", TURQ }, life = 0.3, trans = { 0.45, 1 } })
		end
		local wake = B:block(fin, v(1.5, 3, 2), cf(0, FY, 12.0), BLUE, { tr = 1, name = "WakeFX" })
		B:emitter(wake, "burst", { name = "WakeBurst", color = { "#ffffff", "#9fe2ff", TURQ }, size = { 0.7, 0.5, 0 }, speed = { 4, 10 } })

		------------------------------------------------------------------
		-- DORSAL SAIL: six stepped spine bones (dark ray, blue membrane with a
		-- navy spot, gold trim cap) - ripples, folds flat, flares up
		------------------------------------------------------------------
		local SAILS = {
			{ -2.5, 2.6, "Body1", 10.8 }, { -1.2, 3.4, "Body1", 10.8 }, { 0.1, 3.8, "Body1", 10.8 },
			{ 1.4, 3.4, "Body2", 10.5 }, { 2.7, 2.7, "Body2", 10.5 }, { 4.0, 1.8, "Body2", 10.5 },
		}
		for i, s in SAILS do
			local z, h, base = s[1], s[2], s[4]
			local sb = B:bone("Sail" .. i, s[3], v(0, base, z))
			B:block(sb, v(0.8, h + 0.3, 0.5), cf(0, base + h / 2, z), DARK)
			B:block(sb, v(0.5, h - 0.3, 1.1), cf(0, base + (h - 0.3) / 2, z + 0.75), BLUE)
			B:block(sb, v(0.55, 1.0, 1.05), cf(0, base + 0.5, z + 0.75), DARK)
			if h > 2 then
				B:block(sb, v(0.6, 0.6, 0.6), cf(0, base + h * 0.55, z + 0.7), NAVY)
			end
			B:block(sb, v(0.9, 0.5, 1.5), cf(0, base + h + 0.1, z + 0.45), GOLD)
			if i == 2 or i == 3 or i == 4 then
				B:block(sb, v(0.45, 0.45, 0.45), cf(0, base + h + 0.55, z + 0.1), TURQ, NEON)
			end
		end

		------------------------------------------------------------------
		-- HEAD: big determined cartoon face with a knight's helm crest.
		-- Authored at 1x, scaled up HS about the head pivot (cartoon big head;
		-- the trident bill scales with it).
		------------------------------------------------------------------
		local HP, HS = v(0, Y0, -3.4), 1.15
		local function hp(x, y, z) return HP + (v(x, y, z) - HP) * HS end
		local function H(x, y, z, rx, ry, rz) return CFrame.new(hp(x, y, z)) * ang(rx or 0, ry or 0, rz or 0) end
		local function S(x, y, z) return v(x, y, z) * HS end
		local head = B:bone("Head", "Body1", HP)
		B:block(head, S(4.6, 5.0, 1.2), H(0, 7.8, -3.4), BLUE) -- neck collar
		B:block(head, S(5.0, 5.2, 4.0), H(0, 8.2, -5.2), BLUE) -- cranium
		B:block(head, S(3.8, 0.6, 3.6), H(0, 11.05, -5.0), DARK)
		B:block(head, S(5.1, 1.2, 2.0), H(0, 10.05, -4.2), DARK) -- dark back band (behind the brows)
		B:block(head, S(5.1, 1.0, 3.8), H(0, 6.2, -5.1), BELLY) -- silver cheeks
		B:block(head, S(3.0, 3.0, 1.4), H(0, 8.7, -7.8), BLUE) -- snout
		B:block(head, S(2.2, 0.4, 1.3), H(0, 10.35, -7.8), DARK)
		B:block(head, S(3.4, 0.9, 1.4), H(0, 6.75, -7.8), BELLY) -- upper lip
		-- gritted teeth on a dark mouth slot (determined grimace)
		B:block(head, S(3.2, 0.7, 0.4), H(0, 5.95, -8.3), MOUTH)
		B:block(head, S(3.0, 0.3, 3.4), H(0, 5.75, -6.2), MOUTH) -- palate
		for _, x in { -1.2, -0.4, 0.4, 1.2 } do
			B:block(head, S(0.5, 0.5, 0.3), H(x, 6.1, -8.5), WHITE)
		end
		-- helm crest: gold ridge + stepped crystal plume
		B:block(head, S(1.0, 0.6, 3.2), H(0, 11.6, -5.0), GOLD)
		B:block(head, S(0.8, 1.0, 1.4), H(0, 12.3, -5.6), CRYSTAL)
		B:block(head, S(0.7, 1.0, 1.2), H(0, 13.1, -5.0), CRYSTAL)
		B:block(head, S(0.6, 0.8, 1.0), H(0, 13.8, -4.4), "#5ff5e8")
		B:block(head, S(4.4, 0.6, 0.8), H(0, 10.95, -6.9), GOLD) -- helm brim
		B:sym(function(side)
			-- BIG eye on the front corner: white block, glowing turquoise iris,
			-- black pupils (front + side) and a glint
			B:block(head, S(1.5, 2.2, 1.8), H(2.1, 8.6, -6.6), WHITE)
			B:block(head, S(1.0, 1.4, 1.3), H(2.4, 8.5, -6.95), TURQ, { mat = "Neon", name = "Eye" .. side })
			B:block(head, S(0.55, 1.0, 0.1), H(2.2, 8.4, -7.65), PUPIL)
			B:block(head, S(0.1, 1.0, 0.55), H(2.95, 8.4, -7.0), PUPIL)
			B:block(head, S(0.3, 0.3, 0.1), H(2.6, 8.95, -7.68), WHITE, NEON)
			-- static angry half-lid cutting the inner top of the eye
			B:block(head, S(1.7, 0.7, 2.0), H(2.05, 9.6, -6.65, 0, 0, 24), BLUE)
			-- gold cheek guard with a rune dot + dark gill slit
			B:block(head, S(0.26, 2.4, 2.2), H(2.55, 7.3, -4.6), BRONZE)
			B:block(head, S(0.3, 1.8, 1.6), H(2.6, 7.3, -4.6), GOLD)
			B:block(head, S(0.34, 0.4, 0.4), H(2.65, 7.5, -4.6), TURQ, NEON)
			B:block(head, S(0.2, 3.4, 0.4), H(2.55, 8.0, -3.35), DARK)
			-- heavy angry-heroic brow on its own bone (inner end low)
			local brow = B:bone("Brow" .. side, "Head", hp(2.0, 10.0, -7.4))
			B:block(brow, S(2.9, 0.85, 1.3), H(2.0, 10.0, -7.5, 0, 0, 22), BROW)
			-- eyelid for blinks / squints (hidden until it closes)
			local lid = B:bone("Lid" .. side, "Head", hp(2.1, 10.0, -6.6))
			B:block(lid, S(1.7, 2.3, 1.95), H(2.1, 10.0, -6.6), BLUE, { tr = 1, name = "Eyelid" .. side })
		end)

		------------------------------------------------------------------
		-- JAW (hinged at the back of the mouth)
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", hp(0, 6.0, -4.0))
		B:block(jaw, S(3.8, 1.2, 4.4), H(0, 5.2, -6.2), BELLY)
		B:block(jaw, S(3.0, 0.4, 3.6), H(0, 4.45, -6.0), SILVER)
		B:block(jaw, S(2.0, 0.3, 2.6), H(0, 5.85, -6.0), TONGUE)
		for _, x in { -0.8, 0, 0.8 } do
			B:block(jaw, S(0.5, 0.45, 0.3), H(x, 5.95, -8.45), WHITE)
		end

		------------------------------------------------------------------
		-- BILL: the orichalcum trident with a turquoise crystal in the collar
		------------------------------------------------------------------
		local bill = B:bone("Bill", "Head", hp(0, 8.0, -8.5))
		B:block(bill, S(2.4, 2.8, 0.8), H(0, 8.6, -8.75), BRONZE)
		B:block(bill, S(2.6, 0.5, 0.9), H(0, 10.0, -8.75), GOLD)
		B:block(bill, S(2.6, 0.5, 0.9), H(0, 7.2, -8.75), GOLD)
		B:block(bill, S(1.4, 1.4, 0.3), H(0, 9.0, -9.25, 0, 0, 45), GOLD)
		B:block(bill, S(1.0, 1.0, 0.3), H(0, 9.0, -9.38, 0, 0, 45), CRYSTAL)
		local gem = B:block(bill, S(0.5, 0.5, 0.2), H(0, 9.0, -9.5, 0, 0, 45), TURQ, { mat = "Neon", name = "Crystal" })
		B:emitter(gem, "burst", { name = "CrystalFlash", color = { "#ffffff", TURQ }, speed = { 5, 11 }, size = { 0.7, 0.5, 0 }, life = { 0.3, 0.7 } })
		B:light(gem, { name = "CrystalLight", color = TURQ, brightness = 0.4, range = 10 })
		-- the trident itself sits on its own bone so it can twirl about its shaft
		local tri = B:bone("Trident", "Bill", hp(0, 7.9, -9.1))
		B:block(tri, S(0.8, 0.8, 3.0), H(0, 7.9, -10.6), GOLD) -- shaft
		B:block(tri, S(1.05, 1.05, 0.4), H(0, 7.9, -9.8), DGOLD)
		B:block(tri, S(1.05, 1.05, 0.4), H(0, 7.9, -11.4), DGOLD)
		-- the trident stands upright (prongs fan up / down) so it reads from the side
		B:block(tri, S(0.7, 3.9, 0.7), H(0, 7.9, -12.35), GOLD) -- crossbar
		B:block(tri, S(0.9, 1.1, 0.9), H(0, 7.9, -12.35), DGOLD)
		B:block(tri, S(0.75, 0.75, 2.0), H(0, 7.9, -13.6), GOLD) -- center prong
		B:spike(tri, H(0, 7.9, -14.5).Position, H(0, 7.9, -16.0).Position, 0.85 * HS, 0.85 * HS, GOLD)
		B:trail(tri, hp(0, 8.6, -15.3), hp(0, 7.2, -15.3), { name = "TridentTrail", color = { "#ffffff", GLOW, TURQ }, life = 0.45, trans = { 0.3, 1 } })
		for _, d in { 1, -1 } do
			local y = 7.9 + 1.75 * d
			B:block(tri, S(0.95, 0.55, 0.9), H(0, 7.9 + 1.95 * d, -12.35), BRONZE)
			B:block(tri, S(0.65, 0.65, 1.7), H(0, y, -13.3), GOLD)
			B:spike(tri, H(0, y, -14.1).Position, H(0, y + 0.15 * d, -15.4).Position, 0.75 * HS, 0.75 * HS, GOLD)
			B:spike(tri, H(0, y + 0.3 * d, -13.6).Position, H(0, y + 0.9 * d, -12.9).Position, 0.5 * HS, 0.5 * HS, DGOLD) -- barb
			B:trail(tri, hp(0.6, y, -14.8), hp(-0.6, y, -14.8), { name = d > 0 and "ProngTrailTop" or "ProngTrailBot", color = { "#ffffff", TURQ }, life = 0.3, trans = { 0.45, 1 } })
		end
		local tipFx = B:block(tri, S(1.6, 1.6, 1.6), H(0, 7.9, -15.4), GOLD, { tr = 1, name = "TipFX" })
		B:emitter(tipFx, "burst", { name = "LungeBurst", color = { "#ffffff", GLOW, TURQ } })
		B:emitter(tipFx, "burst", { name = "BubbleBurst", color = { "#ffffff", "#9fe2ff" }, size = { 0.5, 0.8, 0.2 }, speed = { 5, 11 }, life = { 0.6, 1.2 } })
		B:light(tipFx, { name = "TipLight", color = GLOW, brightness = 0.01, range = 12 })
		-- victory glint star on the trident tip (hidden)
		local glint = B:bone("Glint", "Trident", hp(0, 7.9, -16.4))
		B:block(glint, v(0.35, 2.8, 0.35), H(0, 7.9, -16.4), "#ffffff", { mat = "Neon", tr = 1, name = "GlintA" })
		B:block(glint, v(2.8, 0.35, 0.35), H(0, 7.9, -16.4), "#ffffff", { mat = "Neon", tr = 1, name = "GlintB" })

		------------------------------------------------------------------
		-- PECTORAL FINS: long sickle fins with gold knight pauldrons
		------------------------------------------------------------------
		B:sym(function(side)
			local F = CFrame.new(2.3, 6.3, -1.6) * ang(0, -34, -6)
			local function at(x, y, z)
				return F * CFrame.new(x, y, z)
			end
			local pec = B:bone("Pec" .. side, "Body1", F.Position)
			B:block(pec, v(2.2, 0.6, 1.6), at(1.0, 0, 0.1), BLUE)
			B:block(pec, v(1.9, 0.9, 2.0), at(0.5, 0.45, 0.0), GOLD) -- pauldron
			B:block(pec, v(1.4, 0.3, 1.5), at(0.5, 0.95, 0.0), BRONZE)
			B:block(pec, v(0.4, 0.12, 0.4), at(0.5, 1.12, 0.0), TURQ, NEON)
			local tip = B:bone("PecTip" .. side, "Pec" .. side, at(2.0, 0, 0).Position)
			B:block(tip, v(2.0, 0.5, 1.3), at(2.9, 0, 0.35), BLUE)
			B:block(tip, v(1.8, 0.45, 1.0), at(4.6, 0, 0.8), DARK)
			B:block(tip, v(1.2, 0.4, 0.7), at(5.9, 0, 1.3), DARK)
			B:block(tip, v(3.6, 0.55, 0.35), at(4.0, 0.02, -0.25), GOLD) -- leading edge
			local a, b = at(6.4, 0, 1.5), at(5.4, 0, 2.0)
			B:trail(tip, a.Position, b.Position, { name = "PecTrail" .. side, color = { "#ffffff", TURQ }, life = 0.25, trans = { 0.55, 1 } })
		end)

		------------------------------------------------------------------
		-- Floating voxel cubes: blue cubes with gold caps, gold cubes with
		-- blue caps, marble cube - each with a thin turquoise neon band
		------------------------------------------------------------------
		local orbs = {
			{ 8.0, 12.5, -6.0, 1.6, BLUE, GOLD }, { -8.5, 10.0, -1.0, 1.4, GOLD, BLUE },
			{ 7.5, 5.5, 6.0, 1.2, GOLD, DARK }, { -7.5, 13.5, 7.0, 1.6, BLUE, GOLD },
			{ 3.5, 17.0, 2.0, 1.0, MARBLE, GOLD }, { -6.5, 5.0, -9.0, 1.1, DARK, GOLD },
		}
		for i, o in orbs do
			local ob = B:bone("Orb" .. i, "Root", v(o[1], o[2], o[3]))
			local s = o[4]
			B:block(ob, v(s, s, s), cf(o[1], o[2], o[3]), o[5])
			B:block(ob, v(s + 0.1, s * 0.3, s + 0.1), cf(o[1], o[2] + s * 0.36, o[3]), o[6])
			B:block(ob, v(s + 0.16, s * 0.14, s + 0.16), cf(o[1], o[2] - s * 0.1, o[3]), TURQ, NEON)
		end

		------------------------------------------------------------------
		-- SPINNING SLASH RING (hidden): neon arc segments around the trident,
		-- revealed one by one while the body rolls 360
		------------------------------------------------------------------
		local SC = CFrame.new(0, Y0, -14.8) * ang(90, 0, 0)
		local slash = B:bone("Slash", "Body1", v(0, Y0, -14.8))
		for i = 0, 11 do
			local a = math.rad(i * 30)
			local col = i % 2 == 0 and TURQ or GLOW
			B:block(slash, v(2.4, 0.45, 0.6), SC * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -4.4), col, { mat = "Neon", tr = 1, name = "Slash" .. i })
		end

		------------------------------------------------------------------
		-- IMPACT SHARDS (hidden): gold / crystal / marble / bubble voxel cubes
		-- that burst from the trident tip on the lunge impact
		------------------------------------------------------------------
		local SH = v(0, 7.96, -17.2)
		local shardCol = { GOLD, TURQ, MARBLE, "#bfefff", GOLD, TURQ, MARBLE, "#bfefff" }
		for k = 1, 8 do
			local sb = B:bone("Shard" .. k, "Root", SH)
			local s = (k % 3 == 0) and 0.6 or 0.9
			B:block(sb, v(s, s, s), CFrame.new(SH), shardCol[k], { mat = shardCol[k] == TURQ and "Neon" or nil, tr = 1, name = "ShardPart" .. k })
		end
	end,
}
