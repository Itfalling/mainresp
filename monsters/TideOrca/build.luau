--!nocheck
-- Atlantean Tide Orca (Mythic): the mischievous royal prankster of sunken Atlantis.
-- A big bold stepped orca: crisp black / white colour blocking (white eye
-- patches, white chin + belly, white flank sweeps, grey saddle), wearing
-- Atlantean royal armour: a gold gorget collar, a marble-and-gold saddle with a
-- glowing rune row, marble shoulder shields with glyphs, gold rune bands down
-- the tail and a jeweled diamond medallion swinging under the throat.
-- On its head sits an ornate Atlantean war-crown: a marble temple ring of eight
-- little Greek columns under gold lintels, gold crown points, a pediment with a
-- gem, swept gold helm wings and a big turquoise orichalcum crystal spire.
-- The dorsal is a trident blade (tall stepped fin with a gold leading edge and
-- crystal tip, flanked by two crystal tines). The fluke is crystal tipped.
-- HEAD (original-20 style, like the Abyssal Mosasaurus / Atomic Kaiju): a
-- long chunky stepped orca head - cranium, stepped melon, short rostrum -
-- with a gold helm strap + marble jowl plate and a two-tone forehead plate.
-- FACE: ONE side-set eye per side inside the white orca patch (dark socket,
-- glowing turquoise rectangle wrapping the outer-front corner, slit pupil on
-- the side face, glint), a heavy black brow block over each eye, hidden lid
-- blocks that drop for squints / winks / blinks, and ONE long orca mouth
-- line with rows of white block teeth on both jaws, a white chin and a tongue.
-- Hidden VFX props: blowhole squirt drops, a wink star,
-- three swirling water rings, a splash crown, a wave ring, a crown beam.
return {
	DisplayName = "Atlantean Tide Orca",
	Rarity = "Mythic",
	Element = "Atlantis",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette ---------------------------------------------------------
		local BLACK, BLK2, DEEP = "#1d2333", "#2b3550", "#10141f"
		local WHITE, WSHADE, GREY = "#f4f6fb", "#d3dae8", "#8d98ae"
		local MARBLE, MSHADE, CREAM = "#fbf7ee", "#ddd2bb", "#f0e3c4"
		local GOLD, DGOLD, LGOLD = "#e9b53c", "#b07d1e", "#ffd66b"
		local TEAL, DTEAL, LTEAL = "#2bd4c4", "#17998f", "#93f3ea"
		local MOUTH, TONGUE, TONGUED = "#2a0f1a", "#ff6f8e", "#d94a6c"
		local CORAL, CORAL2, BARN = "#ff7a5c", "#ff9fb0", "#d9ccb0"
		local WATER, FOAM = "#74d9ff", "#e9fcff"
		local PUPIL = "#0b0f1a"
		local TURQ, NGOLD = "#3ff0e0", "#ffe27a" -- the two small neon accents
		local NEON = { mat = "Neon" }

		-- the whole monster is authored with its belly ~4.5 studs up, then
		-- lifted by LIFT so it floats high enough for the big jaw / bow gags;
		-- the ground VFX (splash crown, wave ring) are added with LIFT = 0
		local LIFT = 3
		local baseXf = B.xf
		B.xf = function(self, c) return CFrame.new(0, LIFT, 0) * baseXf(self, c) end

		local function blk(bone, sx, sy, sz, x, y, z, col, opts, rx, ry, rz)
			return B:block(bone, v(sx, sy, sz), cf(x, y, z, rx or 0, ry or 0, rz or 0), col, opts)
		end

		------------------------------------------------------------------
		-- BODY (chest + mid) with the royal armour
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 9.5, 0))
		-- chest
		blk(body, 9.0, 8.0, 7.0, 0, 9.6, -2.6, BLACK) -- core (x +-4.5)
		blk(body, 10.2, 5.2, 6.6, 0, 9.6, -2.4, BLACK) -- rounded side band (x +-5.1)
		blk(body, 8.4, 1.0, 6.6, 0, 14.1, -2.4, BLK2)
		blk(body, 8.6, 1.0, 6.8, 0, 5.2, -2.6, WHITE)
		blk(body, 6.4, 0.7, 5.6, 0, 4.45, -2.4, WSHADE)
		-- mid
		blk(body, 8.0, 7.2, 6.2, 0, 9.7, 3.6, BLACK) -- core (x +-4)
		blk(body, 9.2, 4.8, 5.8, 0, 9.9, 3.6, BLACK) -- side band (x +-4.6)
		blk(body, 7.4, 0.9, 5.8, 0, 13.7, 3.4, BLK2)
		blk(body, 7.4, 0.9, 6.0, 0, 5.75, 3.6, WHITE)
		blk(body, 5.6, 0.25, 1.8, 0, 14.25, 5.7, GREY) -- saddle patch
		B:sym(function()
			blk(body, 0.4, 2.2, 6.6, 5.15, 6.7, -2.6, WHITE) -- white belly sweep
			-- rear flank sweep: stepped white flame rising toward the tail
			blk(body, 0.9, 2.6, 3.0, 4.4, 7.4, 3.0, WHITE)
			blk(body, 0.9, 2.2, 2.4, 4.45, 9.0, 4.9, WHITE)
			blk(body, 0.9, 1.4, 1.2, 4.45, 10.6, 5.9, WHITE)
			blk(body, 0.5, 1.2, 1.6, 4.85, 7.7, 1.0, WHITE)
			-- grey orca saddle wrapping down the upper flank (stepped)
			blk(body, 0.5, 1.1, 4.4, 4.0, 12.8, 3.8, GREY)
			blk(body, 0.4, 0.7, 2.6, 4.55, 11.95, 4.4, GREY)
			blk(body, 0.4, 0.5, 1.2, 4.55, 11.35, 5.0, GREY)
			-- sculpted side: deep keel stripe + muscle ridges in two shades
			blk(body, 0.3, 0.6, 6.2, 5.2, 7.3, -2.4, DEEP)
			blk(body, 0.3, 0.5, 3.0, 5.2, 13.3, -4.2, BLK2)
			blk(body, 0.6, 1.0, 5.6, 4.35, 13.0, -2.4, BLK2)
			blk(body, 0.3, 0.6, 3.2, 4.7, 12.6, 0.9, BLK2)
			-- gold rivet row along the upper chest step
			for k = 0, 2 do
				blk(body, 0.5, 0.5, 0.5, 4.75, 13.7, -5.0 + k * 1.6, DGOLD)
			end
			-- marble shoulder shield with gold frame + glyph
			blk(body, 0.5, 3.0, 4.0, 5.35, 10.3, -2.6, MARBLE)
			blk(body, 0.6, 0.5, 4.6, 5.4, 12.0, -2.6, GOLD)
			blk(body, 0.6, 0.5, 4.6, 5.4, 8.6, -2.6, GOLD)
			blk(body, 0.62, 3.0, 0.5, 5.41, 10.3, -4.75, DGOLD)
			blk(body, 1.1, 0.6, 3.4, 5.2, 12.55, -2.4, GOLD) -- pauldron step
			blk(body, 0.15, 1.3, 0.4, 5.65, 10.3, -2.6, TURQ, NEON)
			blk(body, 0.15, 0.4, 1.4, 5.65, 10.3, -2.6, TURQ, NEON)
			-- rune band (mid) neon strip
			blk(body, 0.15, 4.0, 0.3, 4.98, 9.7, 6.4, TURQ, NEON)
		end)
		-- gold gorget collar (slab just bigger than the chest section)
		blk(body, 10.9, 9.1, 1.2, 0, 9.55, -5.7, GOLD)
		blk(body, 9.4, 0.5, 1.4, 0, 14.25, -5.7, LGOLD)
		blk(body, 11.0, 0.6, 1.0, 0, 7.2, -5.75, DGOLD)
		-- marble scallop bib under the collar
		for i = -1, 1 do
			blk(body, 2.2, 1.2, 0.6, i * 2.4, 4.75, -6.35, MARBLE)
			blk(body, 1.2, 0.6, 0.62, i * 2.4, 3.95, -6.35, MSHADE)
		end
		-- rune band around the mid
		blk(body, 9.7, 7.9, 0.9, 0, 9.7, 6.4, GOLD)
		-- marble saddle with gold rim, rune row and the blowhole
		blk(body, 6.0, 0.5, 4.4, 0, 14.85, -2.4, MARBLE)
		B:sym(function()
			blk(body, 0.5, 0.65, 4.8, 3.2, 14.85, -2.4, GOLD)
		end)
		blk(body, 6.9, 0.65, 0.5, 0, 14.85, -0.0, GOLD)
		for i = -1, 1 do
			blk(body, 0.45, 0.12, 0.45, i * 1.4, 15.12, -1.2, TURQ, NEON)
		end
		blk(body, 2.0, 0.4, 1.6, 0, 15.2, -3.6, GOLD) -- blowhole rim
		blk(body, 1.1, 0.12, 0.8, 0, 15.43, -3.6, MOUTH)
		local spout = blk(body, 1, 1, 1, 0, 15.8, -3.6, WATER, { tr = 1, name = "SpoutFX" })
		B:emitter(spout, "burst", { name = "SpoutBurst", color = { "#ffffff", WATER }, speed = { 12, 20 }, spread = 16, size = { 0.9, 0.7, 0.2 }, life = { 0.6, 1.1 }, accel = { 0, -30, 0 }, drag = 0.5 })
		-- barnacles + coral on the flanks
		blk(body, 0.5, 0.8, 0.8, -4.85, 10.6, 2.0, BARN)
		blk(body, 0.5, 0.55, 0.55, -4.85, 11.4, 2.9, BARN)
		blk(body, 0.2, 0.3, 0.3, -5.1, 10.7, 2.0, DEEP)
		blk(body, 0.5, 0.7, 0.7, 4.85, 10.9, 1.8, BARN)
		blk(body, 0.2, 0.3, 0.3, 5.1, 11.0, 1.8, DEEP)
		blk(body, 0.5, 0.45, 0.45, 4.85, 11.6, 2.6, BARN)
		-- sunken temple tile on each flank (carved glyph, gold frame)
		B:sym(function()
			blk(body, 0.4, 2.0, 2.0, 4.8, 9.4, 3.4, MARBLE)
			blk(body, 0.45, 0.4, 2.3, 4.82, 10.5, 3.4, GOLD)
			blk(body, 0.45, 0.4, 2.3, 4.82, 8.3, 3.4, GOLD)
			blk(body, 0.2, 1.2, 0.3, 5.05, 9.4, 3.4, DTEAL)
			blk(body, 0.2, 0.3, 1.0, 5.05, 9.7, 3.4, DTEAL)
		end)
		blk(body, 0.45, 1.1, 0.45, 4.2, 13.9, 5.6, CORAL)
		blk(body, 0.35, 0.7, 0.35, 4.55, 14.5, 5.3, CORAL2, nil, 0, 0, -25)
		-- ambient volume
		local vol = blk(body, 8, 6, 10, 0, 10, 1, BLACK, { tr = 1, name = "BodyFX" })
		B:emitter(vol, "bubble", { name = "AmbientBubbles", color = { "#ffffff", WATER }, rate = 5, size = { 0.25, 0.45, 0.6 } })

		------------------------------------------------------------------
		-- JEWELED MEDALLION on a swinging bone under the throat
		------------------------------------------------------------------
		local medal = B:bone("Medal", "Body", v(0, 4.6, -6.6))
		B:beam(medal, v(-2.2, 4.7, -6.5), v(-0.4, 3.6, -6.7), 0.4, 0.4, GOLD)
		B:beam(medal, v(2.2, 4.7, -6.5), v(0.4, 3.6, -6.7), 0.4, 0.4, GOLD)
		blk(medal, 2.0, 2.0, 0.5, 0, 2.95, -6.75, GOLD, nil, 0, 0, 45)
		blk(medal, 1.4, 1.4, 0.6, 0, 2.95, -6.78, MARBLE, nil, 0, 0, 45)
		local mg = blk(medal, 0.75, 0.75, 0.7, 0, 2.95, -6.85, TURQ, { mat = "Neon", name = "MedalGem" }, 0, 0, 45)
		B:light(mg, { name = "MedalLight", color = TURQ, brightness = 0.35, range = 8 })

		-- head geometry is authored at 1x around HP and scaled up by HS
		local HP, HS = v(0, 10, -6), 1.12
		local function hv(x, y, z) return HP + (v(x, y, z) - HP) * HS end
		local function hb(bone, sx, sy, sz, x, y, z, col, opts, rx, ry, rz)
			return B:block(bone, v(sx, sy, sz) * HS, CFrame.new(hv(x, y, z)) * ang(rx or 0, ry or 0, rz or 0), col, opts)
		end
		local function hspike(bone, a, b, w, d, col, opts) return B:spike(bone, a, b, w * HS, d * HS, col, opts) end
		local function hbeam(bone, a, b, w, h, col, opts) return B:beam(bone, a, b, w * HS, h * HS, col, opts) end
		------------------------------------------------------------------
		-- HEAD (original-20 style): a long, chunky stepped orca head.
		-- Side profile steps down cranium -> melon -> short rostrum; the
		-- long straight orca mouth line runs the whole length with a row of
		-- white block teeth top and bottom. ONE eye per side, set in the
		-- white orca patch: a dark socket with a glowing turquoise rectangle
		-- that wraps the outer-front corner (reads from side, 3/4 and front),
		-- a dark slit pupil on the side face only, a heavy black brow block
		-- overhanging it, and a hidden lid block that drops for blinks/squints.
		------------------------------------------------------------------
		local head = B:bone("Head", "Body", hv(0, 10, -6))
		hb(head, 8.8, 5.2, 8.4, 0, 11.8, -9.3, BLACK) -- cranium   x+-4.4 y 9.2..14.4 z -5.1..-13.5
		hb(head, 7.6, 1.0, 7.4, 0, 14.9, -9.5, BLACK) -- upper step y 14.4..15.4
		hb(head, 5.8, 0.7, 6.4, 0, 15.65, -9.6, BLK2) -- dome cap (under the crown)
		hb(head, 7.4, 4.4, 1.9, 0, 11.4, -14.4, BLACK) -- melon     x+-3.7 y 9.2..13.6 z -13.45..-15.35
		hb(head, 6.0, 0.8, 1.7, 0, 14.0, -14.0, BLK2) -- melon brow step
		hb(head, 5.8, 2.3, 1.8, 0, 10.35, -16.2, BLACK) -- rostrum   x+-2.9 y 9.2..11.5 z -15.3..-17.1
		hb(head, 4.4, 0.6, 1.5, 0, 11.8, -15.9, BLK2) -- rostrum top step
		-- stepped two-tone forehead plate on the melon (colour blocking)
		hb(head, 5.6, 1.2, 0.2, 0, 12.9, -15.42, BLK2)
		hb(head, 3.8, 0.8, 0.2, 0, 11.9, -15.42, BLK2)
		hb(head, 4.6, 0.25, 1.2, 0, 12.2, -16.1, BLK2) -- rostrum top stripe
		-- gold helm rim along the top of the melon
		hb(head, 6.2, 0.4, 0.4, 0, 14.2, -14.9, GOLD)
		-- white throat behind the jaw hinge (covers the gap when it gapes)
		hb(head, 7.6, 2.4, 1.8, 0, 8.0, -6.3, WHITE)
		-- mouth: dark roof + back wall
		hb(head, 7.4, 0.1, 6.4, 0, 9.15, -10.3, MOUTH)
		hb(head, 5.2, 0.1, 3.0, 0, 9.15, -15.0, MOUTH)
		hb(head, 7.0, 2.2, 0.2, 0, 8.1, -7.1, MOUTH)
		local mfx = hb(head, 2, 1, 1, 0, 9.0, -17.8, MOUTH, { tr = 1, name = "MouthFX" })
		B:emitter(mfx, "burst", { name = "Raspberry", color = { "#ffffff", WATER, TONGUE }, speed = { 6, 12 }, spread = 35, size = { 0.5, 0.35, 0 }, life = { 0.4, 0.8 }, dir = "Front", accel = { 0, -12, 0 } })
		B:sym(function(side)
			-- mouth line kicks up at the back corner (cheeky smirk)
			hb(head, 0.2, 0.3, 1.8, 4.42, 9.55, -7.9, MOUTH, nil, -16, 0, 0)
			-- royal helm strap + stepped marble jowl plate at the jaw hinge
			hb(head, 0.6, 4.6, 0.9, 4.75, 11.9, -6.6, GOLD)
			hb(head, 0.5, 1.3, 2.4, 4.85, 9.95, -7.5, MARBLE)
			hb(head, 0.55, 0.35, 2.6, 4.87, 10.6, -7.5, DGOLD)
			-- the classic white orca eye patch sweeping back + up from the eye
			hb(head, 0.5, 2.8, 3.6, 4.45, 12.4, -8.6, WHITE) -- y 11.0..13.8 z -6.8..-10.4
			hb(head, 0.5, 0.6, 2.4, 4.45, 14.1, -8.2, WHITE)
			hb(head, 0.5, 1.2, 1.4, 4.45, 12.0, -6.1, WHITE) -- tapering tail of the patch
			hb(head, 0.5, 2.2, 3.0, 4.5, 11.6, -10.9, WHITE) -- frame round the eye
			-- EYE: dark socket bump, glowing rectangle wrapping the front corner
			hb(head, 0.8, 1.6, 2.2, 4.95, 11.6, -10.8, DEEP) -- x 4.55..5.35
			hb(head, 0.2, 1.1, 1.7, 5.35, 11.6, -10.75, TURQ, { mat = "Neon", name = "Eye" .. side })
			hb(head, 0.6, 1.1, 0.2, 5.0, 11.6, -11.92, TURQ, NEON)
			hb(head, 0.08, 0.35, 0.35, 5.47, 11.95, -10.2, "#ffffff", NEON) -- glint
			local pup = B:bone("Pupil" .. side, "Head", hv(5.48, 11.6, -11.1))
			hb(pup, 0.12, 0.8, 0.5, 5.48, 11.6, -11.1, PUPIL)
			-- lid (hidden): drops half-way for squints, all the way for blinks
			local lid = B:bone("Lid" .. side, "Head", hv(5.0, 13.2, -10.85))
			hb(lid, 1.0, 1.6, 2.6, 5.05, 13.2, -10.85, BLACK, { tr = 1, name = "Lid" .. side })
			-- heavy black brow ridge overhanging the eye (front end low)
			local brow = B:bone("Brow" .. side, "Head", hv(4.8, 12.85, -10.9))
			hb(brow, 1.4, 0.9, 3.4, 4.95, 12.85, -10.9, BLK2, nil, -10, 0, 0)
			hb(brow, 1.0, 0.6, 1.6, 4.75, 13.45, -10.6, BLACK, nil, -6, 0, 0)
			-- upper teeth: a neat row of white blocks along the lip line
			local up = {
				{ 3.75, -8.6, false }, { 3.75, -9.8, true }, { 3.75, -11.0, false }, { 3.75, -12.2, true },
				{ 3.25, -13.6, false }, { 3.25, -14.8, true }, { 2.45, -16.0, false }, { 1.3, -16.7, true },
			}
			for _, t in up do
				local sx, sy = t[3] and 0.6 or 0.5, t[3] and 0.9 or 0.65
				hb(head, sx, sy, sx, t[1], 9.2 - sy / 2, t[2], WHITE)
			end
		end)
		-- wink star (hidden), pops beside the left eye
		local star = B:bone("Star", "Head", hv(-5.6, 14.2, -12.2))
		hb(star, 1.6, 0.4, 0.3, -5.6, 14.2, -12.2, NGOLD, { mat = "Neon", tr = 1, name = "StarA" })
		hb(star, 0.4, 1.6, 0.3, -5.6, 14.2, -12.2, NGOLD, { mat = "Neon", tr = 1, name = "StarB" })

		------------------------------------------------------------------
		-- JAW: long hinged orca lower jaw (black lip band, white chin) with a
		-- row of white block teeth + tongue
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", hv(0, 9.1, -6.9))
		hb(jaw, 8.0, 0.8, 5.8, 0, 8.6, -9.8, BLACK) -- lip band (back)
		hb(jaw, 6.4, 0.8, 4.2, 0, 8.6, -14.7, BLACK) -- lip band (front)
		hb(jaw, 7.8, 1.5, 5.6, 0, 7.45, -9.8, WHITE) -- white chin
		hb(jaw, 6.2, 1.3, 4.2, 0, 7.55, -14.6, WHITE)
		hb(jaw, 5.0, 0.5, 6.4, 0, 6.5, -11.4, WSHADE) -- chin step
		hb(jaw, 6.6, 0.1, 5.6, 0, 9.03, -9.9, MOUTH) -- mouth floor
		hb(jaw, 4.8, 0.1, 4.0, 0, 9.03, -14.6, MOUTH)
		B:sym(function()
			local low = {
				{ 3.35, -9.2, true }, { 3.35, -10.4, false }, { 3.35, -11.6, true },
				{ 2.75, -13.0, false }, { 2.75, -14.2, true }, { 2.75, -15.4, false },
				{ 1.9, -16.3, true }, { 0.6, -16.4, false },
			}
			for _, t in low do
				local sx, sy = t[3] and 0.6 or 0.5, t[3] and 0.85 or 0.6
				hb(jaw, sx, sy, sx, t[1], 9.0 + sy / 2, t[2], WHITE)
			end
		end)
		local tongue = B:bone("Tongue", "Jaw", hv(0, 9.1, -10.0))
		hb(tongue, 3.0, 0.4, 3.6, 0, 9.25, -11.8, TONGUE)
		hb(tongue, 0.4, 0.08, 2.8, 0, 9.48, -11.9, TONGUED)
		local ttip = B:bone("TongueTip", "Tongue", hv(0, 9.2, -13.6))
		hb(ttip, 2.4, 0.4, 1.6, 0, 9.25, -14.3, TONGUE)
		------------------------------------------------------------------
		-- WAR-CROWN: marble temple ring of columns, gold lintels + points,
		-- pediment gem, helm wings, a big orichalcum crystal spire
		------------------------------------------------------------------
		local crown = B:bone("Crown", "Head", hv(0, 15.85, -9.8))
		hb(crown, 8.0, 0.9, 7.0, 0, 16.3, -9.8, MARBLE)
		hb(crown, 8.3, 0.45, 7.3, 0, 16.95, -9.8, GOLD)
		B:sym(function()
			hb(crown, 0.45, 0.45, 0.1, 2.6, 16.3, -13.33, TEAL)
			hb(crown, 0.45, 0.45, 0.1, 1.3, 16.3, -13.33, DGOLD)
		end)
		local COLS = { { -3.4, -12.7 }, { -1.5, -12.7 }, { 1.5, -12.7 }, { 3.4, -12.7 }, { -3.5, -9.8 }, { 3.5, -9.8 }, { -3.0, -6.9 }, { 3.0, -6.9 } }
		for _, c in COLS do
			hb(crown, 1.0, 0.3, 1.0, c[1], 17.3, c[2], DGOLD)
			hb(crown, 0.7, 1.7, 0.7, c[1], 18.25, c[2], MARBLE)
			hb(crown, 1.1, 0.4, 1.1, c[1], 19.25, c[2], GOLD)
		end
		hb(crown, 8.0, 0.6, 1.2, 0, 19.7, -12.7, GOLD)
		hb(crown, 7.2, 0.6, 1.2, 0, 19.7, -6.9, GOLD)
		B:sym(function()
			hb(crown, 1.2, 0.6, 6.9, 3.5, 19.7, -9.8, GOLD)
		end)
		hb(crown, 7.0, 0.5, 0.9, 0, 20.23, -12.7, MARBLE) -- frieze
		hb(crown, 0.4, 0.2, 0.1, -2.4, 20.23, -13.17, DGOLD)
		hb(crown, 0.4, 0.2, 0.1, 2.4, 20.23, -13.17, DGOLD)
		-- crown points
		for _, x in { -3.4, 3.4 } do
			hspike(crown, hv(x, 20.1, -12.7), hv(x, 21.8, -12.7), 1.0, 0.8, GOLD)
			hspike(crown, hv(x, 20.0, -6.9), hv(x, 21.3, -6.9), 0.9, 0.7, GOLD)
		end
		-- pediment with a gem
		hspike(crown, hv(0, 20.3, -12.75), hv(0, 22.1, -12.75), 3.0, 0.7, GOLD)
		hb(crown, 0.7, 0.7, 0.3, 0, 20.95, -13.15, TURQ, NEON, 0, 0, 45)
		-- helm wings
		B:sym(function()
			hspike(crown, hv(3.9, 17.2, -9.6), hv(6.4, 19.8, -6.0), 1.8, 0.45, GOLD)
			hspike(crown, hv(3.9, 16.6, -8.6), hv(5.7, 17.8, -5.4), 1.2, 0.4, MARBLE)
		end)
		-- crystal spire
		hb(crown, 1.8, 3.2, 1.8, 0, 18.4, -9.8, TEAL)
		hb(crown, 1.3, 1.6, 1.3, 0, 20.8, -9.8, LTEAL, nil, 0, 45, 0)
		local tip = hb(crown, 0.7, 1.2, 0.7, 0, 22.2, -9.8, TURQ, { mat = "Neon", name = "CrownTip" }, 0, 45, 0)
		B:sym(function()
			hbeam(crown, hv(1.0, 16.9, -9.8), hv(2.0, 19.6, -10.4), 0.8, 0.8, DTEAL)
			hb(crown, 0.45, 0.45, 0.45, 2.05, 19.8, -10.45, TURQ, NEON)
		end)
		-- coral sprig + barnacle on the ruin
		hb(crown, 0.45, 0.9, 0.45, -2.2, 20.4, -6.6, CORAL)
		hb(crown, 0.35, 0.6, 0.35, -1.85, 20.85, -6.5, CORAL2, nil, 0, 0, -25)
		hb(crown, 0.6, 0.5, 0.6, 2.4, 20.25, -7.0, BARN)
		B:emitter(tip, "sparkle", { name = "CrystalSparkle", color = { "#ffffff", NGOLD, TURQ }, rate = 4 })
		B:emitter(tip, "burst", { name = "CrownBurst", color = { "#ffffff", NGOLD, TURQ }, speed = { 12, 22 }, size = { 1.2, 0.8, 0 } })
		B:light(tip, { name = "CrownLight", color = TURQ, brightness = 0.4, range = 14 })
		-- the crown flash beam (hidden)
		hb(crown, 0.9, 9.0, 0.9, 0, 27.3, -9.8, TURQ, { mat = "Neon", tr = 1, name = "CrownBeam" })
		B:trail(crown, hv(0, 22.8, -9.8), hv(0, 21.6, -9.8), { name = "CrownTrail", color = { "#ffffff", TURQ }, life = 0.3, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- DORSAL: tall trident blade (gold leading edge, crystal tip, two
		-- crystal tines)
		------------------------------------------------------------------
		local dorsal = B:bone("Dorsal", "Body", v(0, 14.0, 2.4))
		blk(dorsal, 1.9, 1.6, 5.8, 0, 14.7, 3.0, BLACK)
		blk(dorsal, 1.6, 2.2, 4.6, 0, 16.6, 3.6, BLACK)
		blk(dorsal, 2.05, 1.65, 0.6, 0, 14.7, 0.15, GOLD)
		blk(dorsal, 1.75, 2.25, 0.6, 0, 16.6, 1.35, GOLD)
		B:sym(function()
			B:beam(dorsal, v(0.8, 15.2, 3.2), v(2.8, 16.9, 3.6), 0.9, 0.9, GOLD)
			B:beam(dorsal, v(2.8, 16.6, 3.6), v(3.1, 19.6, 4.2), 0.9, 0.9, TEAL)
			blk(dorsal, 0.55, 0.7, 0.55, 3.15, 20.0, 4.25, TURQ, NEON)
			blk(dorsal, 0.1, 0.5, 0.5, 0.81, 16.6, 3.8, TURQ, NEON)
		end)
		local dtip = B:bone("DorsalTip", "Dorsal", v(0, 17.6, 4.3))
		blk(dtip, 1.35, 2.2, 3.4, 0, 18.7, 4.5, BLACK)
		blk(dtip, 1.1, 1.8, 2.4, 0, 20.6, 5.1, BLACK)
		blk(dtip, 1.5, 2.25, 0.6, 0, 18.7, 2.85, GOLD)
		blk(dtip, 1.25, 1.85, 0.6, 0, 20.6, 3.95, GOLD)
		blk(dtip, 0.9, 1.5, 1.2, 0, 22.2, 5.6, TEAL)
		blk(dtip, 0.55, 0.8, 0.55, 0, 23.3, 5.7, TURQ, NEON)
		B:sym(function()
			blk(dtip, 0.1, 0.45, 0.45, 0.7, 18.9, 4.8, TURQ, NEON)
		end)
		B:trail(dtip, v(0, 23.6, 5.7), v(0, 21.6, 5.6), { name = "DorsalTrail", color = { "#ffffff", TURQ }, life = 0.28, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- PECTORAL FINS (big paddles with gold bracers)
		------------------------------------------------------------------
		B:sym(function(side)
			local FR = CFrame.new(4.9, 7.0, -3.0) * ang(0, -30, -28)
			local fin = B:bone("Fin" .. side, "Body", FR)
			-- big chunky paddle (scaled up so the flourishes read)
			local SX, SZ, SY = 1.3, 1.25, 1.15
			local function fb(bone, sx, sy, sz, x, y, z, col, opts)
				return B:block(bone, v(sx * SX, sy * SY, sz * SZ), FR * CFrame.new(x * SX, y * SY, z * SZ), col, opts)
			end
			fb(fin, 2.4, 1.5, 3.0, 0.8, 0, 0, BLACK)
			fb(fin, 0.7, 1.8, 3.4, 1.9, 0, 0, GOLD)
			fb(fin, 0.75, 0.4, 3.45, 1.9, 0.75, 0, MARBLE)
			fb(fin, 3.0, 1.0, 4.2, 3.5, 0, 0.2, BLACK)
			fb(fin, 2.6, 0.3, 3.6, 3.5, -0.6, 0.2, BLK2)
			local ft = B:bone("FinTip" .. side, "Fin" .. side, FR * CFrame.new(4.9 * SX, 0, 0))
			fb(ft, 2.6, 0.9, 4.0, 6.2, 0, 0.5, BLACK)
			fb(ft, 1.8, 0.8, 2.8, 8.0, 0, 0.8, BLACK)
			fb(ft, 0.6, 0.85, 2.0, 9.1, 0, 0.9, GOLD)
			fb(ft, 0.4, 0.5, 0.6, 9.5, 0, 0.9, TURQ, NEON)
			B:trail(ft, (FR * CFrame.new(9.4 * SX, 0, -0.2)).Position, (FR * CFrame.new(9.4 * SX, 0, 2.4)).Position,
				{ name = "FinTrail" .. side, color = { "#ffffff", TURQ }, life = 0.25, trans = { 0.55, 1 } })
		end)

		------------------------------------------------------------------
		-- TAIL chain with ridge spikes and gold rune bands, crystal fluke
		------------------------------------------------------------------
		local function ridge(bone, z, y, h)
			B:spike(bone, v(0, y, z - 0.6), v(0, y + h, z + 0.9), 1.0, 1.0, MARBLE)
			blk(bone, 0.6, 0.6, 0.6, 0, y + h * 0.75, z + 0.55, GOLD)
		end
		local t1 = B:bone("Tail1", "Body", v(0, 9.8, 6.6))
		blk(t1, 7.6, 6.0, 4.4, 0, 9.9, 8.7, BLACK)
		blk(t1, 6.0, 0.8, 4.0, 0, 13.25, 8.7, BLK2)
		blk(t1, 6.0, 0.8, 4.0, 0, 6.55, 8.7, WHITE)
		B:sym(function()
			blk(t1, 0.4, 3.0, 2.4, 3.85, 9.0, 7.8, WHITE)
			blk(t1, 0.4, 1.8, 1.8, 3.85, 9.9, 9.8, WHITE)
		end)
		ridge(t1, 8.5, 13.5, 1.8)
		blk(t1, 0.5, 0.7, 0.7, 3.9, 11.6, 9.6, BARN)
		blk(t1, 0.5, 0.45, 0.45, 3.9, 12.2, 9.0, BARN)
		local t2 = B:bone("Tail2", "Tail1", v(0, 10.0, 10.8))
		blk(t2, 5.8, 4.6, 4.0, 0, 10.1, 12.7, BLACK)
		blk(t2, 4.4, 0.7, 3.6, 0, 12.7, 12.6, BLK2)
		blk(t2, 4.4, 0.6, 3.6, 0, 7.6, 12.7, WHITE)
		blk(t2, 6.3, 5.1, 0.8, 0, 10.1, 13.6, GOLD)
		B:sym(function()
			blk(t2, 0.15, 0.5, 0.5, 3.17, 10.1, 13.6, TURQ, NEON)
		end)
		ridge(t2, 11.9, 12.9, 1.5)
		local t3 = B:bone("Tail3", "Tail2", v(0, 10.1, 14.6))
		blk(t3, 4.2, 3.2, 3.6, 0, 10.1, 16.3, BLACK)
		blk(t3, 3.0, 0.6, 3.2, 0, 11.95, 16.2, BLK2)
		blk(t3, 3.0, 0.5, 3.2, 0, 8.3, 16.3, WHITE)
		blk(t3, 4.6, 3.6, 0.6, 0, 10.1, 17.5, GOLD)
		ridge(t3, 15.7, 12.1, 1.2)
		local fl = B:bone("Fluke", "Tail3", v(0, 10.1, 18.0))
		blk(fl, 3.2, 1.8, 2.6, 0, 10.1, 19.1, BLACK)
		blk(fl, 1.0, 1.5, 1.4, 0, 10.1, 20.8, TEAL)
		blk(fl, 0.5, 0.6, 0.6, 0, 10.1, 21.75, TURQ, NEON)
		blk(fl, 0.45, 0.9, 0.45, 0.6, 11.4, 18.8, CORAL)
		local ffx = blk(fl, 6, 1, 3, 0, 10.1, 19.8, BLACK, { tr = 1, name = "FlukeFX" })
		B:emitter(ffx, "burst", { name = "TailSplash", color = { "#ffffff", WATER, FOAM }, speed = { 10, 18 }, size = { 1.0, 0.7, 0 }, accel = { 0, -25, 0 }, spread = 70, life = { 0.5, 1.0 } })
		B:sym(function(side)
			local lobe = B:bone("Fluke" .. side, "Fluke", v(1.4, 10.1, 19.2))
			blk(lobe, 3.2, 1.4, 3.4, 2.9, 10.1, 19.5, BLACK)
			blk(lobe, 3.0, 1.3, 3.2, 5.6, 10.1, 20.1, BLACK)
			blk(lobe, 2.6, 1.1, 2.8, 8.0, 10.1, 20.9, BLACK)
			blk(lobe, 7.2, 0.3, 2.6, 5.4, 9.3, 20.1, WHITE)
			blk(lobe, 2.8, 0.7, 0.5, 5.6, 10.1, 21.8, GOLD)
			blk(lobe, 2.4, 0.6, 0.5, 8.0, 10.1, 22.4, GOLD)
			blk(lobe, 1.4, 1.2, 2.4, 9.8, 10.1, 21.5, TEAL, nil, 0, -40, 0)
			blk(lobe, 0.7, 0.7, 1.0, 10.75, 10.1, 22.4, TURQ, NEON, 0, -40, 0)
			B:trail(lobe, v(11.0, 10.1, 22.7), v(9.0, 10.1, 21.8), { name = "FlukeTrail" .. side, color = { "#ffffff", TURQ }, life = 0.3, trans = { 0.45, 1 } })
		end)

		------------------------------------------------------------------
		-- floating marble cubes + crystal shards
		------------------------------------------------------------------
		local ORBS = { { 11, 17, -6, 1.4, "m" }, { -12, 13, -3, 1.2, "c" }, { 10, 6, 10, 1.1, "c" }, { -10, 19, 8, 1.3, "m" }, { 1, 21.5, 14, 1.0, "m" } }
		for i, o in ORBS do
			local ob = B:bone("Orb" .. i, "Root", v(o[1], o[2], o[3]))
			local s = o[4]
			if o[5] == "m" then
				blk(ob, s, s, s, o[1], o[2], o[3], MARBLE)
				blk(ob, s + 0.1, s * 0.25, s + 0.1, o[1], o[2] + s * 0.2, o[3], GOLD)
				blk(ob, 0.3, 0.3, 0.1, o[1], o[2] - s * 0.15, o[3] - s / 2 - 0.03, TURQ, NEON)
			else
				blk(ob, s * 0.7, s * 1.6, s * 0.7, o[1], o[2], o[3], TEAL, nil, 0, 45, 0)
				blk(ob, s * 0.4, s * 0.5, s * 0.4, o[1], o[2] + s, o[3], TURQ, NEON, 0, 45, 0)
			end
		end

		------------------------------------------------------------------
		-- blowhole squirt drops (hidden, carried by the body)
		------------------------------------------------------------------
		for k = 1, 7 do
			local d = B:bone("Squirt" .. k, "Body", v(0, 15.6, -3.6))
			local s = k == 1 and 1.8 or (k % 2 == 0 and 1.4 or 1.1)
			blk(d, s, s, s, 0, 15.6, -3.6, k % 3 == 0 and FOAM or "#45bdf2", { tr = 1, name = "SquirtP" .. k })
		end

		------------------------------------------------------------------
		-- BREACH: three swirling water rings (hidden)
		------------------------------------------------------------------
		local RINGS = { { 12, 7.6 }, { 18, 8.6 }, { 24, 7.4 } }
		for k, r in RINGS do
			local rb = B:bone("Swirl" .. k, "Root", v(0, r[1], 0))
			for i = 0, 11 do
				local a = i / 12 * 360
				local c0 = cf(0, r[1], 0) * ang(0, a, 0) * CFrame.new(0, (i % 2) * 0.6 - 0.3, -r[2])
				B:block(rb, v(4.4, 1.2, 1.4), c0 * ang(0, 0, (i % 2 == 0) and 12 or -12),
					i % 3 == 0 and FOAM or WATER, { tr = 1, name = "Sw" .. k .. "_" .. i })
			end
		end

		LIFT = 0
		------------------------------------------------------------------
		-- BELLY-FLOP: splash crown columns + expanding wave ring (hidden)
		------------------------------------------------------------------
		local SC = v(0, 0, 2)
		local splash = B:bone("SplashFX", "Root", SC + v(0, 1.5, 0))
		local sp = blk(splash, 10, 1, 20, 0, 1.5, 2, WATER, { tr = 1, name = "SplashVol" })
		B:emitter(sp, "burst", { name = "SplashBurst", color = { "#ffffff", WATER, FOAM }, speed = { 14, 24 }, size = { 1.2, 0.9, 0 }, accel = { 0, -26, 0 }, spread = 60, life = { 0.7, 1.3 } })
		B:emitter(sp, "dust", { name = "SplashMist", color = { "#ffffff", "#c4f1ff" }, size = { 2.5, 4, 5 }, speed = { 8, 14 } })
		B:light(sp, { name = "SplashLight", color = WATER, brightness = 0.01, range = 22 })
		for i = 1, 12 do
			local a = (i - 0.5) / 12 * math.pi * 2
			local x, z = 11 * math.sin(a), 2 + 17 * math.cos(a)
			local cb = B:bone("Splash" .. i, "Root", v(x, 1.2, z))
			local h = (i % 2 == 0) and 9 or 6.5
			blk(cb, 2.2, h, 2.2, x, 1.2 + h / 2, z, WATER, { tr = 1, name = "SplCol" .. i })
			blk(cb, 2.9, 1.3, 2.9, x, 1.2 + h + 0.4, z, FOAM, { tr = 1, name = "SplCap" .. i })
		end
		for i = 1, 16 do
			local a = (i - 1) / 16 * math.pi * 2
			local pos = v(9 * math.sin(a), 0.55, 2 + 15 * math.cos(a))
			local tan = v(9 * math.cos(a), 0, -15 * math.sin(a)).Unit
			local wb = B:bone("Wave" .. i, "Root", pos)
			B:block(wb, v(5.0, 1.0, 1.6), CFrame.fromMatrix(pos, tan, v(0, 1, 0)), i % 2 == 0 and FOAM or WATER, { tr = 1, name = "WaveP" .. i })
		end
	end,
}
