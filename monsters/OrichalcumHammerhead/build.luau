--!nocheck
-- Orichalcum Hammerhead: a MEAN GRUMPY BULLY of a shark from sunken Atlantis.
-- Steel-teal stud-built body with a pale belly, a huge flat HAMMER head plated
-- in orichalcum-gold war-helmet armor (stepped scowl visor, rune engravings,
-- a bronze helmet crest), narrow glaring turquoise slit eyes at the hammer
-- ends under heavy angled gold brows, a big interlocking grin of white block
-- teeth with two jutting underbite tusks, bronze battle-plates down the back,
-- a tall dorsal fin with a gold blade edge and a crescent tail.
-- Neon only on the eye slits, rune dots and fin tips. The slam shockwave rings
-- and the debris are hidden parts revealed by the motion.
return {
	DisplayName = "Orichalcum Hammerhead",
	Rarity = "Legendary",
	Element = "Atlantis",
	Build = function(B, P)
		local ang = P.ang
		-- the whole shark hovers LIFT studs higher than it was authored so the
		-- prowl, head-butts and fin strokes never scrape the floor
		local LIFT = 1
		local v = P.v -- sizes
		local function pv(x, y, z) -- positions (lifted)
			return P.v(x, y + LIFT, z)
		end
		local function cf(x, y, z, rx, ry, rz)
			return P.cf(x, y + LIFT, z, rx, ry, rz)
		end
		local MAIN, DARK, BELLY = "#3d7d8f", "#24505d", "#e4ece6"
		local GOLD, GOLD2, BRONZE, BRONZED = "#f2b632", "#c98a1e", "#b8732e", "#6e3f17"
		local WHITE, MOUTH, PUPIL = "#f8f6ea", "#120d14", "#071216"
		local MARBLE = "#efe9dc"
		local TURQ, SKY, NGOLD = "#3ff0e0", "#6fe3ff", "#ffe27a"
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- helpers
		------------------------------------------------------------------
		-- one body segment: steel-teal core, dark top ridge, pale belly band
		-- that wraps the lower sides, a thin dark counter-shade line
		local function segment(bone, z0, z1, yc, w, h)
			local len = z1 - z0
			local zc = (z0 + z1) / 2
			B:block(bone, v(w, h, len), cf(0, yc, zc), MAIN)
			B:block(bone, v(w * 0.6, 0.5, len - 0.4), cf(0, yc + h / 2 + 0.2, zc), DARK)
			local bh = h * 0.42
			B:block(bone, v(w + 0.1, bh, len - 0.3), cf(0, yc - h / 2 + bh / 2 - 0.2, zc), BELLY)
			B:block(bone, v(w + 0.16, 0.3, len - 0.4), cf(0, yc - h / 2 + bh - 0.2, zc), DARK)
		end

		-- bronze battle-plate on the back: slab, shark-tooth ridge (wedge rising
		-- toward the back), gold front rim and two glowing rune dots
		local function battlePlate(bone, y, z, w, d)
			B:block(bone, v(w, 0.5, d), cf(0, y + 0.25, z), BRONZE)
			B:wedge(bone, v(0.9, 1.1, d - 0.3), cf(0, y + 1.0, z + 0.1), BRONZED)
			B:block(bone, v(w + 0.1, 0.6, 0.4), cf(0, y + 0.3, z - d / 2 + 0.1), GOLD)
			B:sym(function()
				B:block(bone, v(0.4, 0.12, 0.4), cf(w / 2 - 0.55, y + 0.55, z + 0.2), TURQ, NEON)
			end)
		end

		------------------------------------------------------------------
		-- BODY (Body2 is the swimmer's center; the chain runs both ways)
		------------------------------------------------------------------
		local body2 = B:bone("Body2", "Root", pv(0, 8, 0.5))
		segment(body2, -1.6, 3.4, 8.0, 6.2, 6.2)
		B:sym(function()
			B:block(body2, v(0.12, 1.0, 1.6), cf(3.12, 9.0, 1.6), DARK) -- side spot
			B:block(body2, v(0.5, 0.6, 0.6), cf(3.2, 10.2, -0.6), MARBLE) -- barnacles
			B:block(body2, v(0.4, 0.4, 0.4), cf(3.2, 10.5, 0.1), MARBLE)
			B:block(body2, v(0.2, 0.3, 2.6), cf(3.15, 7.6, 0.2), TURQ, NEON) -- lateral line
		end)
		local bubbleVol = B:block(body2, v(10, 8, 24), cf(0, 9, 1), MAIN, { tr = 1, name = "BubbleVolume" })
		B:emitter(bubbleVol, "bubble", { name = "AmbientBubbles", color = { "#ffffff", SKY }, rate = 5, size = { 0.2, 0.4, 0.5 } })
		B:emitter(bubbleVol, "sparkle", { name = "AmbientSparkle", color = { "#ffffff", NGOLD, TURQ }, rate = 3 })

		-- tall stepped dorsal fin with a gold blade leading edge (own bone for
		-- follow-through)
		local dorsal = B:bone("Dorsal", "Body2", pv(0, 11.2, 0.6))
		do
			local d, zo = 4.6, 0
			for i = 0, 4 do
				local y = 11.25 + i + 0.5
				local zc = 0.8 + zo
				B:block(dorsal, v(1.2 - 0.08 * i, 1.0, d), cf(0, y, zc), i == 0 and DARK or MAIN)
				B:block(dorsal, v(1.3 - 0.08 * i, 1.0, 0.6), cf(0, y, zc - d / 2 - 0.15), GOLD)
				if i == 1 or i == 3 then
					B:block(dorsal, v(1.25 - 0.08 * i, 0.3, d * 0.6), cf(0, y - 0.1, zc + d * 0.15), DARK)
				end
				d = math.max(1.2, d * 0.74)
				zo += 0.75
			end
			B:wedge(dorsal, v(0.8, 1.0, 1.6), cf(0, 16.75, 0.8 + zo - 0.3), GOLD)
			B:block(dorsal, v(0.6, 0.6, 0.6), cf(0, 17.4, 0.8 + zo + 0.2), TURQ, NEON)
			B:trail(dorsal, pv(0, 17.4, 0.8 + zo + 0.3), pv(0, 16.3, 0.8 + zo + 0.6), { name = "DorsalTrail", color = { "#ffffff", TURQ }, life = 0.22, trans = { 0.55, 1 } })
		end

		-- Body1 = the chest: biggest segment, gill slits, shoulder armor
		local body1 = B:bone("Body1", "Body2", pv(0, 8, -1.5))
		segment(body1, -7.0, -1.2, 8.0, 6.6, 6.6)
		battlePlate(body1, 11.5, -5.4, 4.2, 2.0)
		battlePlate(body1, 11.5, -2.8, 4.0, 2.0)
		-- stepped belly plates under the chest
		local rows = { { -6.0, 3.6, MARBLE }, { -4.6, 4.4, BELLY }, { -3.2, 4.0, MARBLE }, { -1.9, 3.2, BELLY } }
		for _, r in rows do
			B:block(body1, v(r[2], 0.6, 1.3), cf(0, 4.55, r[1]), r[3])
		end
		B:sym(function()
			-- five dark gill slits (the classic shark read)
			for i = 0, 4 do
				B:block(body1, v(0.14, 2.2 - 0.15 * i, 0.32), cf(3.33, 8.5, -6.4 + i * 0.62, 0, 0, 0), DARK)
			end
			-- bronze shoulder pauldron with a gold rim above the pectoral fin
			B:block(body1, v(0.5, 1.6, 2.8), cf(3.42, 6.9, -2.9), BRONZE)
			B:block(body1, v(0.56, 0.4, 2.9), cf(3.45, 7.85, -2.9), GOLD)
			B:block(body1, v(0.6, 0.35, 0.35), cf(3.5, 6.9, -2.9), TURQ, NEON)
		end)

		local body3 = B:bone("Body3", "Body2", pv(0, 8.1, 3.3))
		segment(body3, 3.0, 6.4, 8.2, 5.0, 5.0)
		B:block(body3, v(5.3, 5.3, 0.6), cf(0, 8.2, 3.3), DARK) -- joint collar
		battlePlate(body3, 10.7, 4.9, 3.4, 1.8)
		-- small pelvic fins + marble barnacle clusters (sunken-ruin crust)
		B:sym(function()
			B:block(body3, v(0.5, 0.7, 0.7), cf(2.6, 9.3, 4.2), MARBLE)
			B:block(body3, v(0.4, 0.5, 0.5), cf(2.6, 8.7, 4.8), MARBLE)
			B:block(body3, v(0.35, 0.35, 0.35), cf(2.75, 9.4, 4.25), DARK)
			B:beam(body3, pv(1.8, 5.8, 4.2), pv(3.0, 4.6, 6.0), 0.5, 1.4, DARK)
		end)

		------------------------------------------------------------------
		-- TAIL chain + crescent fluke
		------------------------------------------------------------------
		local tails = {
			-- pivot z, z0, z1, yc, w, h
			{ 6.0, 5.8, 8.2, 8.4, 3.8, 3.8 },
			{ 8.0, 7.8, 10.0, 8.6, 2.8, 2.8 },
			{ 9.8, 9.6, 11.5, 8.8, 2.0, 2.0 },
		}
		local parent = "Body3"
		for i, s in tails do
			local name = "Tail" .. i
			local b = B:bone(name, parent, pv(0, s[4] - 0.1, s[1]))
			segment(b, s[2], s[3], s[4], s[5], s[6])
			B:block(b, v(s[5] + 0.3, s[6] + 0.3, 0.5), cf(0, s[4], s[2] + 0.25), DARK)
			if i == 1 then
				battlePlate(b, s[4] + s[6] / 2 + 0.4, 7.2, 2.6, 1.6)
				-- small anal fin below
				B:wedge(b, v(0.6, 1.4, 1.6), cf(0, s[4] - s[6] / 2 - 0.6, 7.2, 180, 0, 0), DARK)
			elseif i == 2 then
				B:wedge(b, v(0.6, 1.0, 1.2), cf(0, s[4] + s[6] / 2 + 0.6, 9.0), GOLD)
			end
			parent = name
		end

		-- heterocercal crescent fluke: pixel-art rows sweeping back, each row
		-- with a dark leading edge; the big upper lobe has a gold blade edge
		local FZ, FY = 11.2, 8.8
		local fluke = B:bone("Fluke", "Tail3", pv(0, FY, FZ))
		local function fb(sx, sy, sz, z, y, col, opts)
			return B:block(fluke, v(sx, sy, sz), cf(0, FY + y, FZ + z), col, opts)
		end
		local function row(y, z0, z1, th, col, edge)
			fb(th, 1.05, z1 - z0, (z0 + z1) / 2, y, col)
			fb(th + 0.1, 1.0, 0.7, z0 + 0.15, y, edge or DARK)
		end
		fb(1.5, 2.0, 2.2, 0.9, 0, MAIN) -- core
		row(1.5, 0.4, 2.6, 1.3, MAIN, GOLD) -- upper lobe
		row(2.5, 1.1, 3.3, 1.2, MAIN, GOLD)
		row(3.5, 1.8, 3.9, 1.05, MAIN, GOLD)
		row(4.5, 2.5, 4.4, 0.95, DARK, GOLD)
		row(5.5, 3.2, 4.8, 0.85, DARK, GOLD)
		fb(0.7, 0.7, 0.7, 4.6, 6.3, TURQ, NEON)
		row(-1.5, 0.4, 2.4, 1.3, MAIN) -- lower lobe
		row(-2.5, 1.0, 3.0, 1.1, MAIN)
		row(-3.5, 1.6, 3.4, 0.9, DARK)
		fb(0.6, 0.6, 0.6, 3.2, -4.2, TURQ, NEON)
		fb(0.2, 0.25, 1.6, 3.6, 3.0, TURQ, NEON) -- trailing edge strip
		B:trail(fluke, pv(0, FY + 6.3, FZ + 4.8), pv(0, FY + 4.5, FZ + 4.2), { name = "FlukeTrailTop", color = { "#ffffff", TURQ }, life = 0.3, trans = { 0.45, 1 } })
		B:trail(fluke, pv(0, FY - 4.2, FZ + 3.4), pv(0, FY - 3.0, FZ + 3.2), { name = "FlukeTrailBot", color = { "#ffffff", TURQ }, life = 0.3, trans = { 0.45, 1 } })

		------------------------------------------------------------------
		-- HEAD: skull + the huge gold-armored HAMMER
		------------------------------------------------------------------
		local head = B:bone("Head", "Body1", pv(0, 8.2, -6.4))
		B:block(head, v(6.2, 5.2, 2.0), cf(0, 8.2, -7.0), MAIN) -- jowl (hides the neck joint)
		B:block(head, v(5.8, 4.3, 5.2), cf(0, 8.55, -9.2), MAIN) -- skull
		B:block(head, v(3.6, 0.4, 4.8), cf(0, 10.85, -8.6), DARK)
		-- upper lip with a lopsided SNEER notch on the right: the lip is hiked
		-- up, showing a red gum line and a long fang, plus snarl creases
		B:block(head, v(4.0, 1.6, 2.6), cf(-0.8, 7.2, -12.1), MAIN) -- upper lip
		B:block(head, v(1.6, 1.1, 2.6), cf(2.0, 7.45, -12.1), MAIN)
		B:block(head, v(1.5, 0.5, 2.4), cf(2.0, 6.65, -12.0), MOUTH)
		B:block(head, v(1.5, 0.3, 0.3), cf(2.0, 6.75, -13.2), "#a8323f")
		B:block(head, v(0.62, 1.45, 0.62), cf(2.0, 6.0, -13.15), WHITE) -- sneer fang
		B:block(head, v(1.3, 0.25, 0.1), cf(1.7, 7.75, -13.43, 0, 0, 28), DARK)
		B:block(head, v(1.0, 0.25, 0.1), cf(2.25, 7.3, -13.43, 0, 0, 28), DARK)
		B:block(head, v(5.0, 0.8, 6.4), cf(0, 6.0, -9.9), MOUTH) -- mouth gap (black)
		B:block(head, v(6.3, 0.9, 1.8), cf(0, 6.0, -7.1), BELLY) -- pale throat under jowl
		-- the hammer
		B:block(head, v(5.4, 2.6, 4.0), cf(0, 9.3, -12.4), MAIN) -- center
		B:block(head, v(3.6, 0.3, 3.0), cf(0, 8.1, -12.6), DARK)
		B:sym(function(side)
			B:block(head, v(4.0, 2.4, 3.4), cf(4.6, 9.3, -12.1), MAIN) -- wing
			B:block(head, v(4.1, 0.4, 3.3), cf(4.6, 8.0, -12.1), BELLY) -- pale underside
			B:block(head, v(2.2, 3.0, 3.6), cf(7.6, 9.3, -11.9), MAIN) -- eye pod
			B:block(head, v(2.3, 0.4, 3.5), cf(7.6, 7.75, -11.9), BELLY)
			B:block(head, v(2.0, 0.4, 0.6), cf(7.6, 7.75, -10.0), DARK)
			-- gold helmet plates on top, engraved with bronze glyph bars + a rune dot
			B:block(head, v(4.1, 0.5, 3.0), cf(4.6, 10.7, -12.3), GOLD)
			B:block(head, v(2.6, 0.1, 0.3), cf(4.6, 11.0, -12.9), BRONZED)
			B:block(head, v(0.3, 0.1, 1.0), cf(3.5, 11.0, -12.2), BRONZED)
			B:block(head, v(0.3, 0.1, 1.0), cf(5.7, 11.0, -12.2), BRONZED)
			B:block(head, v(0.4, 0.12, 0.4), cf(4.6, 11.0, -11.7), TURQ, NEON)
			B:block(head, v(2.3, 0.5, 3.2), cf(7.6, 10.9, -11.6), GOLD2)
			-- SCOWL LINE: a dark bronze stepped brow ridge across the whole
			-- hammer front, high at the eyes and plunging to a V over the
			-- nose -> from the front the hammer itself is one big angry frown
			B:block(head, v(1.35, 0.75, 0.5), cf(5.95, 10.3, -13.95), BRONZED)
			B:block(head, v(1.35, 0.75, 0.5), cf(4.7, 9.95, -13.95), BRONZED)
			B:block(head, v(1.35, 0.75, 0.5), cf(3.45, 9.6, -13.95), BRONZED)
			B:block(head, v(1.3, 0.75, 0.5), cf(2.2, 9.35, -14.55), BRONZED)
			B:block(head, v(1.05, 0.75, 0.5), cf(1.05, 9.05, -14.55), BRONZED)
			B:block(head, v(3.6, 0.25, 0.1), cf(4.7, 10.48, -13.92, 0, 0, 16), GOLD) -- gold glint on the ridge
			-- gold cheek guard + bronze helmet spike at the hammer end
			B:block(head, v(0.3, 1.0, 3.0), cf(8.75, 8.35, -11.8), GOLD)
			B:spike(head, pv(8.4, 10.8, -10.6), pv(10.0, 12.2, -9.2), 1.0, 1.0, BRONZE)
			-- EYE: dark socket, glowing narrow slit wrapping the outer-front
			-- corner, pupils pushed inward/forward = a mean glare
			B:block(head, v(2.5, 1.45, 2.5), cf(7.6, 9.15, -12.6, 0, 0, 12), PUPIL)
			B:block(head, v(2.1, 0.75, 2.3), cf(7.85, 9.15, -12.75, 0, 0, 12), TURQ, { mat = "Neon", name = "Eye" .. side })
			B:block(head, v(0.8, 0.85, 0.1), cf(7.25, 9.1, -13.92, 0, 0, 12), PUPIL)
			B:block(head, v(0.8, 0.25, 0.1), cf(5.4, 9.0, -13.85), PUPIL) -- nostril
			B:trail(head, pv(8.7, 10.6, -10.2), pv(8.7, 8.0, -10.2), { name = "HammerTrail" .. side, color = { "#ffffff", TURQ }, life = 0.2, trans = { 0.55, 1 } })
			-- upper teeth (side rows), hang from the lip line into the gap
			for i, z in { -11.9, -10.3, -8.7, -7.3 } do
				local h = i % 2 == 1 and 0.95 or 0.75
				B:block(head, v(0.6, h, 0.6), cf(2.55, 6.4 - h / 2, z), WHITE)
			end
		end)
		-- center: gold scowl visor (lowest in the middle = furrowed), nasal
		-- guard and an orichalcum gem
		B:block(head, v(5.5, 0.6, 3.6), cf(0, 10.8, -12.5), GOLD)
		-- gold widow's-peak helmet brow above the V + nasal guard + gem
		B:block(head, v(3.0, 0.8, 0.4), cf(0, 10.2, -14.55), GOLD)
		B:block(head, v(1.6, 0.6, 0.4), cf(0, 9.6, -14.55), GOLD)
		B:block(head, v(1.2, 1.6, 0.5), cf(0, 8.7, -14.6), GOLD2)
		B:block(head, v(0.6, 0.6, 0.2), cf(0, 8.75, -14.9), TURQ, NEON)
		B:block(head, v(0.5, 0.3, 0.1), cf(-1.0, 10.2, -14.78), BRONZED)
		B:block(head, v(0.5, 0.3, 0.1), cf(1.0, 10.2, -14.78), BRONZED)
		-- helmet dome + bronze crest over the skull
		B:block(head, v(5.0, 0.6, 5.0), cf(0, 11.0, -8.9), GOLD)
		B:block(head, v(5.1, 0.3, 0.4), cf(0, 10.9, -6.5), BRONZED)
		B:block(head, v(1.4, 0.8, 7.6), cf(0, 11.6, -10.0), GOLD2)
		B:block(head, v(1.0, 1.0, 6.0), cf(0, 12.5, -9.6), DARK)
		B:block(head, v(1.06, 0.3, 5.6), cf(0, 12.6, -9.5), BRONZE)
		B:block(head, v(0.9, 1.0, 4.0), cf(0, 13.5, -8.6), DARK)
		B:block(head, v(0.8, 1.0, 2.2), cf(0, 14.5, -7.8), DARK)
		B:block(head, v(0.86, 0.3, 2.0), cf(0, 14.6, -7.8), BRONZE)
		B:block(head, v(0.6, 0.6, 0.9), cf(0, 15.25, -7.3), TURQ, NEON)
		-- front teeth (upper)
		for _, x in { -2.0, -0.7, 0.7 } do
			B:block(head, v(0.62, 0.9, 0.62), cf(x, 5.95, -13.15), WHITE)
		end
		local mouthFx = B:block(head, v(3, 2, 1.5), cf(0, 6.0, -14.5), MAIN, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFx, "burst", { name = "ChompBurst", color = { "#ffffff", SKY }, size = { 0.5, 0.6, 0.1 }, speed = { 4, 9 }, life = { 0.4, 0.8 } })
		local rushVol = B:block(head, v(14, 4, 4), cf(0, 9.0, -12.0), MAIN, { tr = 1, name = "RushVolume" })
		B:emitter(rushVol, "bubble", { name = "RushBubbles", color = { "#ffffff", SKY }, rate = 50, enabled = false, size = { 0.3, 0.6, 0.6 }, speed = { 2, 6 }, spread = 90 })

		-- brows (bones): heavy gold brow plates slanted down toward the middle
		B:sym(function(side)
			local brow = B:bone("Brow" .. side, "Head", pv(7.4, 10.5, -13.2))
			B:block(brow, v(4.4, 1.25, 1.2), cf(7.6, 10.45, -14.0, 0, 0, 22), BRONZED)
			B:block(brow, v(4.5, 0.35, 1.3), cf(7.45, 11.15, -14.0, 0, 0, 22), GOLD)
			B:block(brow, v(3.6, 0.8, 2.2), cf(7.75, 10.95, -12.5, 0, 0, 22), BRONZE)
		end)
		-- eyelids (hidden until they close)
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", cf(7.85, 9.95, -12.8, 0, 0, 12))
			B:block(lid, v(2.2, 0.85, 2.4), cf(7.85, 9.95, -12.8, 0, 0, 12), MAIN, { tr = 1, name = "Eyelid" .. side })
		end)

		------------------------------------------------------------------
		-- JAW (hinged at the back of the mouth) with an underbite + tusks
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", pv(0, 6.0, -6.4))
		B:block(jaw, v(5.6, 1.4, 6.8), cf(0, 4.9, -10.0), MAIN)
		B:block(jaw, v(5.6, 1.3, 1.3), cf(0, 4.95, -13.95), MAIN) -- jutting underbite chin
		B:block(jaw, v(5.5, 0.5, 1.1), cf(0, 4.15, -14.0), BELLY)
		B:block(jaw, v(5.7, 0.5, 6.6), cf(0, 4.15, -10.2), BELLY)
		B:block(jaw, v(3.4, 0.3, 4.0), cf(0, 3.85, -10.6), MARBLE)
		B:block(jaw, v(4.6, 0.2, 6.0), cf(0, 5.65, -10.0), MOUTH)
		B:block(jaw, v(2.4, 0.3, 4.2), cf(0, 5.75, -9.6), "#c8485c") -- tongue
		for _, x in { -1.35, 0, 1.35 } do
			B:block(jaw, v(0.6, 0.85, 0.6), cf(x, 6.0, -14.05), WHITE)
		end
		B:sym(function()
			for i, z in { -11.1, -9.5, -7.9 } do
				local h = i % 2 == 1 and 0.85 or 0.7
				B:block(jaw, v(0.6, h, 0.6), cf(2.5, 5.6 + h / 2, z), WHITE)
			end
			-- jutting underbite tusks
			B:block(jaw, v(0.9, 2.4, 0.9), cf(2.65, 6.5, -14.15), WHITE)
			B:block(jaw, v(0.55, 0.55, 0.55), cf(2.65, 7.95, -14.15), WHITE)
		end)

		------------------------------------------------------------------
		-- PECTORAL FINS: 2 bones each (shoulder + blade)
		------------------------------------------------------------------
		B:sym(function(side)
			local F = CFrame.new(pv(3.0, 5.8, -3.4)) * ang(0, -28, -12)
			local function at(x, y, z)
				return F * CFrame.new(x, y, z)
			end
			local fin = B:bone("Pec" .. side, "Body1", F)
			B:block(fin, v(2.8, 1.0, 3.4), at(1.1, 0, 0.3), MAIN)
			B:block(fin, v(2.6, 0.3, 2.6), at(1.2, 0.55, 0.3), DARK)
			local tip = B:bone("PecTip" .. side, "Pec" .. side, at(2.3, 0, 0))
			B:block(tip, v(2.2, 0.8, 3.0), at(3.3, 0, 0.7), MAIN)
			B:block(tip, v(2.0, 0.7, 2.3), at(5.2, 0, 1.2), MAIN)
			B:block(tip, v(1.6, 0.6, 1.5), at(6.9, 0, 1.7), DARK)
			B:block(tip, v(2.2, 0.85, 0.5), at(3.3, 0, -0.95), BRONZE)
			B:block(tip, v(2.0, 0.75, 0.5), at(5.2, 0, 0.1), BRONZE)
			B:block(tip, v(1.2, 0.65, 0.5), at(6.8, 0, 0.8), GOLD)
			B:block(tip, v(3.4, 0.82, 0.3), at(4.5, 0.0, 2.4), DARK)
			B:block(tip, v(3.0, 0.12, 0.25), at(4.6, 0.46, 1.4), TURQ, NEON)
			local a, b = at(7.7, 0, 2.2), at(6.6, 0, 2.6)
			B:trail(tip, a.Position, b.Position, { name = "PecTrail" .. side, color = { "#ffffff", TURQ }, life = 0.25, trans = { 0.55, 1 } })
		end)

		------------------------------------------------------------------
		-- Floating voxel cubes: gold / teal cubes with a cap and a thin band
		------------------------------------------------------------------
		local orbs = {
			{ 10.5, 13.0, -6.0, 2.0, GOLD, MAIN },
			{ -10.5, 10.5, -1.0, 1.8, MAIN, GOLD },
			{ 8.8, 6.5, 7.5, 1.4, MARBLE, GOLD },
			{ -8.5, 14.5, 7.0, 2.0, GOLD, DARK },
			{ 4.0, 18.0, 4.0, 1.2, MAIN, GOLD },
			{ -9.0, 5.5, -9.0, 1.3, MARBLE, MAIN },
		}
		for i, o in orbs do
			local ob = B:bone("Orb" .. i, "Root", pv(o[1], o[2], o[3]))
			local s = o[4]
			B:block(ob, v(s, s, s), cf(o[1], o[2], o[3]), o[5])
			B:block(ob, v(s + 0.1, s * 0.3, s + 0.1), cf(o[1], o[2] + s * 0.36, o[3]), o[6])
			B:block(ob, v(s + 0.16, s * 0.16, s + 0.16), cf(o[1], o[2] - s * 0.1, o[3]), i % 2 == 0 and NGOLD or TURQ, NEON)
		end

		------------------------------------------------------------------
		-- SLAM FX (on Root at the impact point): 3 hidden neon shockwave
		-- rings (revealed one after another = an expanding wave), debris
		-- cubes, dust / burst / bubble emitters and a flash light
		------------------------------------------------------------------
		local IMP = P.v(0, 0.35, -16.5) -- on the ground (not lifted)
		local impBone = B:bone("Impact", "Root", IMP)
		local impFx = B:block(impBone, v(6, 1, 6), CFrame.new(IMP), MAIN, { tr = 1, name = "ImpactFX" })
		B:emitter(impFx, "dust", { name = "ImpactDust", color = { MARBLE, "#cfc3a6" } })
		B:emitter(impFx, "burst", { name = "ImpactBurst", color = { "#ffffff", NGOLD, TURQ }, speed = { 8, 16 }, size = { 0.7, 0.5, 0 } })
		B:emitter(impFx, "burst", { name = "BubbleBurst", color = { "#ffffff", SKY }, size = { 0.5, 0.8, 0.2 }, speed = { 5, 11 }, life = { 0.6, 1.2 } })
		B:light(impFx, { name = "ImpactLight", color = TURQ, brightness = 0.01, range = 18 })
		local rings = { { "ShockA", 3.5, 10, TURQ }, { "ShockB", 6.5, 14, NGOLD }, { "ShockC", 9.5, 18, TURQ } }
		for _, r in rings do
			local rb = B:bone(r[1], "Impact", IMP)
			local chord = 2 * math.pi * r[2] / r[3]
			for i = 0, r[3] - 1 do
				local a = i / r[3] * 360
				B:block(rb, v(chord * 0.92, 0.3, 0.55), CFrame.new(IMP) * ang(0, a, 0) * CFrame.new(0, 0, -r[2]), r[4], { mat = "Neon", tr = 1, name = r[1] .. i })
			end
		end
		-- orichalcum crystal shards that erupt from the ground around the slam
		for k = 1, 6 do
			local a = (k - 0.5) / 6 * 360
			local base = CFrame.new(IMP) * ang(0, a, 0) * CFrame.new(0, 0, -4.2) * ang(-24, 0, 0)
			local cb = B:bone("Crystal" .. k, "Impact", base)
			local hgt = k % 2 == 0 and 2.2 or 3.0
			B:block(cb, v(1.0, hgt, 1.0), base * CFrame.new(0, hgt / 2, 0), "#5fd6d0", { tr = 1, name = "CrystalBody" .. k })
			B:block(cb, v(0.6, 0.8, 0.6), base * CFrame.new(0, hgt + 0.35, 0), TURQ, { mat = "Neon", tr = 1, name = "CrystalTip" .. k })
		end
		local chunkCol = { MARBLE, GOLD, MAIN, MARBLE, BRONZE, GOLD, MARBLE, DARK }
		for k = 1, 8 do
			local cb = B:bone("Chunk" .. k, "Impact", IMP)
			local s = (k % 3 == 0) and 0.7 or 1.0
			B:block(cb, v(s, s, s), CFrame.new(IMP + v(0, 0.3, 0)), chunkCol[k], { tr = 1, name = "ChunkPart" .. k })
		end
	end,
}
