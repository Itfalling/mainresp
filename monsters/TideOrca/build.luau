--!nocheck
-- Atlantean Tide Orca: a big, chunky stud-built killer whale that swims through
-- the air, dressed in sunken-Atlantis royal armor. Personality: MISCHIEVOUS
-- ROYAL PRANKSTER - cocked right brow, lowered scheming left brow, a lopsided
-- smirk (the white chin curls up on the right), pupils on bones for sly side
-- glances, a tongue on its own bone for the tongue-out tease and a blowhole that
-- squirts voxel water at the crowd.
-- Glossy black / charcoal body colour-blocked in steps with crisp white patches
-- (chin + belly, eye patches that double as cartoon "brow plates", flank patch,
-- saddle, fluke undersides). Armor: a marble-and-gold temple crown (little
-- columns + lintels + a turquoise crystal spire), a gold rune-engraved collar,
-- gold fin bands, a turquoise orichalcum gem on the forehead and a tall dorsal
-- fin with a turquoise crystal blade edge. Neon only on the eyes, gem, rune dots,
-- crystal tips and the thin blade edge strips.
-- Hidden VFX (revealed by the motion during "Tidal Crown"): a swirling double
-- water ring, a wave ring that bursts outward on the belly-flop, splash droplet
-- cubes and blowhole squirt cubes.
return {
	DisplayName = "Atlantean Tide Orca",
	Rarity = "Mythic",
	Element = "Atlantis",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad, cos, sin = math.rad, math.cos, math.sin

		-- palette
		local BLACK, CHAR = "#1c1d26", "#2c2e3a"
		local WHITE, SADDLE, PLATE = "#f4f6f8", "#d9dee6", "#e3e8ee"
		local MARBLE, MARBLE2 = "#efe9dc", "#d6cfbf"
		local GOLD, DGOLD = "#f2b632", "#b87a1e"
		local CRYSTAL, DCRYSTAL = "#2fd6c8", "#1a9c95"
		local MOUTH, GUM, TONGUE = "#2a0f1a", "#ff7d95", "#ff5f86"
		local TURQ, SKY = "#3ff0e0", "#6fe3ff" -- neon accents (turquoise main, sky for water fx)
		local AQUA = "#3aa8e8"
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- helpers
		------------------------------------------------------------------
		-- one body segment: black core, charcoal back cap, white belly band that
		-- wraps the lower sides and a pale belly keel plate
		local function segment(bone, z0, z1, yc, w, h, bellyH)
			local len, zc = z1 - z0, (z0 + z1) / 2
			B:block(bone, v(w, h, len), cf(0, yc, zc), BLACK)
			B:block(bone, v(w * 0.72, 0.6, len - 0.4), cf(0, yc + h / 2 + 0.25, zc), CHAR)
			B:block(bone, v(w + 0.12, bellyH, len - 0.2), cf(0, yc - h / 2 + bellyH / 2 - 0.05, zc), WHITE)
			B:block(bone, v(w * 0.7, 0.6, len - 0.6), cf(0, yc - h / 2 - 0.25, zc), PLATE)
		end
		-- gold armor band around a segment with marble rune tiles + neon rune dots
		local function band(bone, z, yc, w, h, d)
			B:block(bone, v(w, h, d), cf(0, yc, z), GOLD)
			B:block(bone, v(w + 0.1, 0.35, d + 0.1), cf(0, yc + h / 2 - 0.1, z), DGOLD)
			B:sym(function()
				B:block(bone, v(0.12, h * 0.42, d * 0.62), cf(w / 2 + 0.03, yc - 0.1, z), MARBLE)
				B:block(bone, v(0.1, 0.35, 0.3), cf(w / 2 + 0.1, yc - 0.1, z), TURQ, NEON)
			end)
		end

		------------------------------------------------------------------
		-- BODY2: the swim center (dorsal fin lives here)
		------------------------------------------------------------------
		local body2 = B:bone("Body2", "Root", v(0, 8.4, 0.5))
		segment(body2, -0.2, 5.3, 8.5, 8.6, 7.2, 1.4)
		-- white flank patch rising toward the tail (orca colour step)
		B:block(body2, v(8.75, 1.4, 2.4), cf(0, 6.6, 4.0), WHITE)
		B:block(body2, v(8.75, 1.2, 1.4), cf(0, 7.9, 4.5), WHITE)
		-- grey-white saddle patch behind the fin, dripping down the sides
		B:block(body2, v(6.4, 0.4, 1.6), cf(0, 12.65, 4.45), SADDLE)
		B:block(body2, v(8.75, 1.2, 1.2), cf(0, 11.2, 4.6), SADDLE)
		-- charcoal side panel (colour blocking on the big flat sides)
		B:block(body2, v(8.75, 1.6, 2.2), cf(0, 9.6, 1.4), CHAR)
		-- stepped belly plates
		B:block(body2, v(5.0, 0.5, 1.4), cf(0, 4.25, 0.8), WHITE)
		B:block(body2, v(4.2, 0.5, 1.4), cf(0, 4.25, 3.4), WHITE)
		local vol = B:block(body2, v(12, 9, 26), cf(0, 9, 0), BLACK, { tr = 1, name = "BubbleVolume" })
		B:emitter(vol, "bubble", { name = "AmbientBubbles", color = { "#ffffff", SKY }, rate = 5, size = { 0.25, 0.45, 0.6 } })
		B:emitter(vol, "sparkle", { name = "AmbientSparkle", color = { "#ffffff", TURQ, "#ffe27a" }, rate = 3 })

		------------------------------------------------------------------
		-- DORSAL FIN: tall stepped black fin leaning back, gold armor base
		-- band, turquoise crystal blade along the leading edge (thin neon)
		------------------------------------------------------------------
		local dorsal = B:bone("Dorsal", "Body2", v(0, 12.3, 1.8))
		local function finStep(bone, y0, d, zc, col)
			B:block(bone, v(1.2, 1.25, d), cf(0, y0 + 0.6, zc), col)
			local front = zc - d / 2
			B:block(bone, v(0.9, 1.25, 0.7), cf(0, y0 + 0.6, front - 0.2), CRYSTAL)
			B:block(bone, v(0.3, 1.15, 0.22), cf(0, y0 + 0.6, front - 0.62), TURQ, NEON)
		end
		finStep(dorsal, 12.0, 4.4, 2.3, BLACK)
		finStep(dorsal, 13.2, 3.6, 2.7, BLACK)
		finStep(dorsal, 14.4, 2.9, 3.1, CHAR)
		B:block(dorsal, v(1.5, 0.7, 4.6), cf(0, 12.75, 2.4), GOLD) -- armor base band
		B:block(dorsal, v(1.6, 0.25, 4.7), cf(0, 13.15, 2.4), DGOLD)
		B:sym(function()
			B:block(dorsal, v(0.1, 0.35, 0.35), cf(0.78, 12.7, 1.4), TURQ, NEON)
			B:block(dorsal, v(0.1, 0.35, 0.35), cf(0.78, 12.7, 3.4), TURQ, NEON)
		end)
		local dtip = B:bone("DorsalTip", "Dorsal", v(0, 15.6, 3.2))
		finStep(dtip, 15.6, 2.3, 3.5, BLACK)
		finStep(dtip, 16.8, 1.7, 3.9, BLACK)
		B:wedge(dtip, v(1.0, 1.2, 1.4), cf(0, 18.55, 4.3), CHAR)
		B:block(dtip, v(0.6, 0.6, 0.6), cf(0, 18.4, 3.15), TURQ, NEON)
		B:trail(dtip, v(0, 18.9, 4.6), v(0, 17.2, 4.4), { name = "DorsalTrail", color = { "#ffffff", TURQ }, life = 0.25, trans = { 0.55, 1 } })

		------------------------------------------------------------------
		-- BODY1: the chest (gold rune collar in front, blowhole on top)
		------------------------------------------------------------------
		local body1 = B:bone("Body1", "Body2", v(0, 8.4, -0.2))
		segment(body1, -6.2, 0.6, 8.4, 9.0, 7.6, 1.5)
		B:block(body1, v(9.12, 1.4, 2.0), cf(0, 6.4, -5.1), WHITE) -- white throat step up
		B:block(body1, v(9.12, 1.6, 2.6), cf(0, 9.8, -1.6), CHAR) -- side panel
		-- stepped belly plates under the chest
		B:block(body1, v(5.0, 0.5, 1.4), cf(0, 4.15, -4.8), WHITE)
		B:block(body1, v(6.0, 0.5, 1.4), cf(0, 4.1, -3.2), PLATE)
		B:block(body1, v(5.0, 0.5, 1.4), cf(0, 4.15, -1.6), WHITE)
		-- blowhole (marble rim, dark hole)
		B:block(body1, v(1.8, 0.3, 1.4), cf(0, 12.75, -3.6), MARBLE)
		B:block(body1, v(1.1, 0.32, 0.6), cf(0, 12.8, -3.6), MOUTH)
		local spoutFx = B:block(body1, v(1, 0.4, 1), cf(0, 13.1, -3.6), BLACK, { tr = 1, name = "SpoutFX" })
		B:emitter(spoutFx, "burst", { name = "SpoutBurst", color = { "#ffffff", SKY, AQUA }, speed = { 12, 20 }, spread = 14, size = { 0.8, 0.6, 0.2 }, life = { 0.6, 1.1 }, accel = { 0, -30, 0 }, drag = 0.5 })
		-- gold rune-engraved collar (frames the big head)
		B:block(body1, v(9.7, 8.4, 0.6), cf(0, 8.4, -5.65), DGOLD)
		B:block(body1, v(9.45, 8.15, 1.0), cf(0, 8.4, -6.3), GOLD)
		B:sym(function()
			for i, y in { 6.0, 8.4, 10.8 } do
				B:block(body1, v(0.12, 1.1, 0.7), cf(4.76, y, -6.3), MARBLE)
				B:block(body1, v(0.1, i == 2 and 0.6 or 0.35, 0.3), cf(4.83, y, -6.3), TURQ, NEON)
			end
			B:block(body1, v(1.2, 0.12, 0.7), cf(2.6, 12.5, -6.3), MARBLE)
			B:block(body1, v(0.4, 0.1, 0.3), cf(2.6, 12.56, -6.3), TURQ, NEON)
		end)

		------------------------------------------------------------------
		-- HEAD: big blunt orca head (black top, white chin on the Jaw)
		------------------------------------------------------------------
		local head = B:bone("Head", "Body1", v(0, 8.6, -6.2))
		B:block(head, v(8.0, 5.5, 6.5), cf(0, 9.35, -9.25), BLACK) -- cranium
		B:block(head, v(6.0, 0.5, 5.4), cf(0, 12.2, -9.6), CHAR) -- top step
		B:block(head, v(6.0, 4.4, 1.6), cf(0, 8.8, -13.3), BLACK) -- melon
		B:block(head, v(4.6, 0.8, 1.4), cf(0, 11.35, -13.1), BLACK) -- melon cap
		B:block(head, v(4.4, 2.6, 0.8), cf(0, 7.9, -14.5), BLACK) -- rostrum
		B:block(head, v(3.0, 0.4, 0.8), cf(0, 9.3, -14.5), CHAR)
		-- mouth: dark palate, pink gums, throat wall
		B:block(head, v(6.4, 0.25, 7.6), cf(0, 6.5, -10.9), MOUTH)
		B:block(head, v(4.0, 0.25, 0.7), cf(0, 6.5, -14.5), MOUTH)
		B:block(head, v(6.2, 1.8, 0.3), cf(0, 5.8, -7.2), MOUTH)
		-- forehead orichalcum gem in a gold diamond setting
		B:block(head, v(1.8, 1.8, 0.3), cf(0, 10.2, -14.2, 0, 0, 45), GOLD)
		local gem = B:block(head, v(1.0, 1.0, 0.3), cf(0, 10.2, -14.33, 0, 0, 45), TURQ, { mat = "Neon", name = "Gem" })
		B:light(gem, { name = "GemLight", color = TURQ, brightness = 0.5, range = 10 })
		B:emitter(gem, "burst", { name = "GemBurst", color = { "#ffffff", TURQ, "#ffe27a" }, speed = { 8, 15 }, size = { 0.8, 0.5, 0 } })

		B:sym(function(side)
			local R = side == "R"
			-- front upper teeth (block teeth for the cheeky toothy smile)
			B:block(head, v(0.75, 0.95, 0.6), cf(0.65, 6.15, -14.55), WHITE)
			B:block(head, v(0.6, 0.75, 0.55), cf(1.65, 6.25, -14.45), WHITE)
			-- side upper teeth
			for k, z in { -13.4, -12.0, -10.6, -9.2 } do
				local big = k % 2 == 1
				B:block(head, big and v(0.6, 0.95, 0.6) or v(0.5, 0.7, 0.5), cf(2.85, 6.5 - (big and 0.47 or 0.35), z), WHITE)
			end
			B:block(head, v(0.3, 0.2, 6.0), cf(2.85, 6.42, -11.3), GUM)
			-- the big eye: dark charcoal socket wrapping the front corner with a
			-- turquoise glowing iris, black pupil (own bone: sly glances)
			B:block(head, v(2.4, 2.6, 2.2), cf(3.6, 9.3, -12.2), CHAR)
			B:block(head, v(1.6, 1.9, 1.6), cf(4.05, 9.15, -12.59), TURQ, { mat = "Neon", name = "Eye" .. side })
			-- orca eye patch sweeping back along the side from the brow
			B:block(head, v(0.2, 1.6, 3.2), cf(4.05, 10.9, -9.7), WHITE)
			B:block(head, v(0.2, 1.0, 2.0), cf(4.05, 11.25, -7.4), WHITE)
			-- SMIRK: the white chin line curls up at the mouth corner (much
			-- higher on the right = lopsided cheeky grin) + a dark crease
			if R then
				B:block(head, v(0.2, 0.9, 2.4), cf(4.05, 7.05, -8.0), WHITE)
				B:block(head, v(0.2, 0.9, 1.2), cf(4.05, 7.85, -7.0), WHITE)
				B:beam(head, v(4.18, 6.6, -9.4), v(4.18, 8.1, -7.3), 0.12, 0.3, MOUTH)
				B:block(head, v(0.12, 0.6, 1.0), cf(4.08, 7.6, -10.0), GUM) -- blush
			else
				B:block(head, v(0.2, 0.7, 2.0), cf(4.05, 6.95, -7.6), WHITE)
				B:beam(head, v(4.18, 6.6, -9.0), v(4.18, 7.4, -7.0), 0.12, 0.28, MOUTH)
			end
			-- pupil bone (front + side pupil, white glints)
			local pu = B:bone("Pupil" .. side, "Head", v(4.1, 9.0, -12.9))
			B:block(pu, v(0.8, 1.3, 0.1), cf(4.1, 9.0, -13.44), BLACK)
			B:block(pu, v(0.1, 1.3, 0.8), cf(4.9, 9.0, -12.5), BLACK)
			B:block(pu, v(0.4, 0.4, 0.1), cf(4.35, 9.45, -13.5), "#ffffff", NEON)
			B:block(pu, v(0.1, 0.4, 0.4), cf(4.96, 9.45, -12.2), "#ffffff", NEON)
			-- chunky WHITE brow = the orca eye patch: RIGHT brow cocked high and
			-- arched, LEFT brow low and slanted (scheming)
			local by = R and 11.05 or 10.45
			local tilt = R and -10 or 16
			local brow = B:bone("Brow" .. side, "Head", v(3.8, by, -13.4))
			B:block(brow, v(3.0, 1.0, 0.6), cf(3.7, by, -13.5, 0, 0, tilt), WHITE)
			B:block(brow, v(0.6, 1.0, 2.6), cf(4.9, by + (R and -0.2 or 0.35), -12.4, 0, 0, tilt), WHITE)
			-- eyelid (hidden until it blinks / winks)
			local lid = B:bone("Lid" .. side, "Head", v(4.0, 11.3, -12.5))
			B:block(lid, v(2.1, 2.2, 2.1), cf(4.0, 11.3, -12.5), CHAR, { tr = 1, name = "Eyelid" .. side })
			B:block(lid, v(2.2, 0.3, 2.2), cf(4.0, 10.3, -12.5), WHITE, { tr = 1, name = "Lash" .. side })
		end)

		------------------------------------------------------------------
		-- CROWN / HELM: marble temple crown with gold rim, four little Greek
		-- columns carrying gold lintels, gold crown points and a turquoise
		-- orichalcum crystal spire
		------------------------------------------------------------------
		local crown = B:bone("Crown", "Head", v(0, 12.5, -9.25))
		B:block(crown, v(8.3, 0.7, 6.8), cf(0, 12.4, -9.25), GOLD) -- rim
		B:block(crown, v(8.4, 0.25, 6.9), cf(0, 12.0, -9.25), DGOLD)
		B:block(crown, v(7.2, 0.9, 5.8), cf(0, 13.2, -9.25), MARBLE) -- marble base
		B:block(crown, v(5.4, 0.6, 4.2), cf(0, 13.95, -9.25), MARBLE2) -- step
		B:block(crown, v(3.0, 0.7, 0.2), cf(0, 13.2, -12.2), DGOLD) -- rune plaque
		B:block(crown, v(1.6, 0.3, 0.1), cf(0, 13.2, -12.32), TURQ, NEON)
		for _, zc in { -11.6, -6.9 } do
			B:block(crown, v(6.6, 0.5, 0.9), cf(0, 15.8, zc), GOLD) -- lintel
			B:sym(function()
				B:block(crown, v(0.8, 2.0, 0.8), cf(2.9, 14.6, zc), MARBLE) -- column shaft
				B:block(crown, v(1.15, 0.4, 1.15), cf(2.9, 13.75, zc), MARBLE2) -- base
			end)
		end
		-- gold crown points on the front lintel
		B:block(crown, v(1.0, 1.2, 0.6), cf(0, 16.6, -11.6), GOLD)
		B:block(crown, v(0.5, 0.5, 0.5), cf(0, 17.4, -11.6), "#ffe27a", NEON)
		B:sym(function()
			B:block(crown, v(0.7, 0.8, 0.6), cf(2.2, 16.4, -11.6), GOLD)
		end)
		-- crystal spire
		B:block(crown, v(2.0, 0.6, 2.0), cf(0, 14.5, -9.25), GOLD)
		B:block(crown, v(1.3, 2.4, 1.3), cf(0, 15.9, -9.25, 0, 45, 0), CRYSTAL)
		B:block(crown, v(0.8, 1.0, 0.8), cf(0, 17.5, -9.25, 0, 45, 0), DCRYSTAL)
		B:block(crown, v(0.5, 0.6, 0.5), cf(0, 18.2, -9.25, 0, 45, 0), TURQ, NEON)

		------------------------------------------------------------------
		-- JAW (white chin, hinged at the back of the mouth)
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", v(0, 6.6, -7.0))
		B:block(jaw, v(7.0, 1.6, 7.4), cf(0, 5.75, -10.7), WHITE)
		B:block(jaw, v(5.4, 0.6, 6.2), cf(0, 4.75, -10.6), PLATE)
		B:block(jaw, v(4.6, 1.4, 0.6), cf(0, 5.85, -14.6), WHITE)
		B:block(jaw, v(5.8, 0.2, 6.6), cf(0, 6.6, -10.8), MOUTH)
		B:block(jaw, v(3.6, 0.2, 0.5), cf(0, 6.6, -14.4), GUM)
		B:sym(function()
			B:block(jaw, v(0.5, 0.25, 6.6), cf(3.0, 6.62, -10.8), GUM)
			for k, z in { -13.0, -11.6, -10.2 } do
				local big = k % 2 == 0
				B:block(jaw, big and v(0.6, 0.9, 0.6) or v(0.5, 0.65, 0.5), cf(3.0, 6.7 + (big and 0.45 or 0.32), z), WHITE)
			end
			B:block(jaw, v(0.6, 0.75, 0.55), cf(1.15, 7.0, -14.45), WHITE)
		end)
		-- tongue (own bone: tongue-out tease)
		local tongue = B:bone("Tongue", "Jaw", v(0, 6.75, -8.4))
		B:block(tongue, v(2.6, 0.5, 4.0), cf(0, 6.8, -10.5), TONGUE)
		B:block(tongue, v(2.2, 0.5, 1.4), cf(0, 6.8, -13.1), TONGUE)
		B:block(tongue, v(0.25, 0.52, 3.2), cf(0, 6.82, -11.2), "#e2406c")

		------------------------------------------------------------------
		-- PECTORAL FINS: big black paddles with gold fin bands
		------------------------------------------------------------------
		B:sym(function(side)
			local F = CFrame.new(v(4.0, 5.8, -3.6)) * ang(0, -24, -22)
			local function at(x, y, z) return F * CFrame.new(x, y, z) end
			local fin = B:bone("Fin" .. side, "Body1", F)
			B:block(fin, v(2.8, 1.3, 3.2), at(1.1, 0, 0), BLACK)
			B:block(fin, v(0.7, 1.55, 3.4), at(2.2, 0, 0), GOLD)
			B:block(fin, v(0.12, 0.4, 0.4), at(2.2, 0.82, 0), TURQ, NEON)
			local tip = B:bone("FinTip" .. side, "Fin" .. side, at(2.5, 0, 0))
			B:block(tip, v(2.4, 1.15, 3.8), at(3.6, 0, 0.3), BLACK)
			B:block(tip, v(1.8, 1.0, 3.2), at(5.6, 0, 0.7), BLACK)
			B:block(tip, v(1.2, 0.9, 2.2), at(6.9, 0, 1.1), CHAR)
			B:block(tip, v(3.6, 0.25, 3.0), at(4.5, -0.6, 0.5), WHITE) -- white underside
			B:block(tip, v(3.2, 0.2, 0.35), at(4.6, 0.62, -1.1), CHAR)
			local a, b = at(7.4, 0, 1.6), at(6.2, 0, 2.0)
			B:trail(tip, a.Position, b.Position, { name = "FinTrail" .. side, color = { "#ffffff", TURQ }, life = 0.25, trans = { 0.55, 1 } })
		end)

		------------------------------------------------------------------
		-- TAIL chain (vertical orca tail stock) + gold rune band
		------------------------------------------------------------------
		local tail1 = B:bone("Tail1", "Body2", v(0, 8.6, 5.0))
		segment(tail1, 5.0, 8.9, 8.7, 7.0, 6.0, 1.2)
		B:block(tail1, v(7.15, 2.2, 1.6), cf(0, 8.5, 5.8), WHITE) -- flank patch step
		B:block(tail1, v(7.15, 1.0, 1.2), cf(0, 10.0, 6.0), WHITE)
		B:block(tail1, v(1.0, 0.8, 3.0), cf(0, 12.0, 7.0), CHAR) -- back ridge
		local tail2 = B:bone("Tail2", "Tail1", v(0, 8.8, 8.7))
		segment(tail2, 8.6, 12.0, 8.8, 5.2, 4.8, 1.2)
		band(tail2, 11.1, 8.8, 5.5, 5.15, 0.9)
		local tail3 = B:bone("Tail3", "Tail2", v(0, 8.9, 11.9))
		B:block(tail3, v(3.4, 3.8, 2.6), cf(0, 8.9, 13.0), BLACK)
		B:block(tail3, v(0.9, 0.8, 2.2), cf(0, 11.1, 13.0), CHAR) -- top keel
		B:block(tail3, v(0.9, 0.8, 2.2), cf(0, 6.7, 13.0), WHITE) -- bottom keel

		------------------------------------------------------------------
		-- FLUKES: wide horizontal pixel-art lobes (black top, white underside,
		-- charcoal leading edge, gold armor stripe, neon tips)
		------------------------------------------------------------------
		local fluke = B:bone("Fluke", "Tail3", v(0, 8.9, 14.0))
		B:block(fluke, v(3.0, 1.6, 2.6), cf(0, 8.9, 15.0), BLACK)
		B:block(fluke, v(2.0, 0.3, 2.2), cf(0, 8.0, 15.0), WHITE)
		B:block(fluke, v(1.0, 0.6, 1.0), cf(0, 9.95, 14.6), GOLD)
		local flukeFx = B:block(fluke, v(4, 1, 3), cf(0, 8.9, 15.5), BLACK, { tr = 1, name = "FlukeFX" })
		B:emitter(flukeFx, "burst", { name = "FlukeSplash", color = { "#ffffff", SKY, AQUA }, speed = { 8, 15 }, size = { 0.9, 0.6, 0 }, accel = { 0, -20, 0 }, spread = 60 })
		B:sym(function(side)
			local lobe = B:bone("Fluke" .. side, "Fluke", v(1.3, 8.9, 14.8))
			local rows = { -- x center, width, z center, depth
				{ 2.5, 2.8, 15.4, 3.0 }, { 4.7, 2.2, 16.1, 2.6 }, { 6.5, 1.8, 16.8, 2.0 },
			}
			for i, r in rows do
				B:block(lobe, v(r[2], 1.2, r[4]), cf(r[1], 9.1, r[3]), i == 3 and CHAR or BLACK)
				B:block(lobe, v(r[2] - 0.2, 0.3, r[4] - 0.2), cf(r[1], 8.4, r[3]), WHITE)
				B:block(lobe, v(r[2] - 0.1, 1.3, 0.5), cf(r[1], 9.05, r[3] - r[4] / 2 - 0.1), CHAR)
			end
			B:block(lobe, v(0.6, 1.3, 2.4), cf(3.3, 9.1, 15.4), GOLD) -- fin band stripe
			B:block(lobe, v(0.62, 0.12, 0.4), cf(3.3, 9.76, 15.4), TURQ, NEON)
			B:wedge(lobe, v(1.0, 1.0, 1.6), cf(7.7, 9.05, 17.5, 0, 180, 0), CHAR)
			B:block(lobe, v(0.6, 0.6, 0.6), cf(7.8, 9.1, 18.2), TURQ, NEON)
			B:trail(lobe, v(7.9, 9.0, 18.0), v(6.6, 9.0, 17.5), { name = "FlukeTrail" .. side, color = { "#ffffff", TURQ }, life = 0.3, trans = { 0.45, 1 } })
		end)

		------------------------------------------------------------------
		-- Floating Atlantis voxel cubes: marble + gold cap + turquoise rune band,
		-- a gold cube, and a turquoise crystal shard
		------------------------------------------------------------------
		local orbs = {
			{ 11.0, 13.0, -6.5, 2.0, "marble" },
			{ -11.5, 10.0, -2.0, 1.8, "gold" },
			{ 10.0, 7.0, 9.0, 1.4, "crystal" },
			{ -9.5, 15.0, 8.0, 2.0, "marble" },
			{ -5.5, 18.5, -8.0, 1.3, "crystal" },
		}
		for i, o in orbs do
			local x, y, z, s = o[1], o[2], o[3], o[4]
			local ob = B:bone("Orb" .. i, "Root", v(x, y, z))
			if o[5] == "crystal" then
				B:block(ob, v(s * 0.7, s * 1.5, s * 0.7), cf(x, y, z, 0, 45, 0), CRYSTAL)
				B:block(ob, v(s * 0.75, s * 0.25, s * 0.75), cf(x, y - s * 0.6, z, 0, 45, 0), GOLD)
				B:block(ob, v(s * 0.35, s * 0.35, s * 0.35), cf(x, y + s * 0.85, z, 0, 45, 0), TURQ, NEON)
			else
				local main, cap = o[5] == "gold" and GOLD or MARBLE, o[5] == "gold" and MARBLE or GOLD
				B:block(ob, v(s, s, s), cf(x, y, z), main)
				B:block(ob, v(s + 0.1, s * 0.3, s + 0.1), cf(x, y + s * 0.36, z), cap)
				B:block(ob, v(s + 0.16, s * 0.14, s + 0.16), cf(x, y - s * 0.1, z), TURQ, NEON)
			end
		end

		------------------------------------------------------------------
		-- HIDDEN VFX
		------------------------------------------------------------------
		-- swirling double water ring around the body (spins with the leap)
		local RC = v(0, 8.4, 0.5)
		local ring = B:bone("SpinRing", "Root", RC)
		local ring2 = B:bone("SpinRing2", "Root", RC)
		local n = 0
		local function waterRing(ring, z, r, count, off, col2)
			for i = 0, count - 1 do
				n += 1
				local a = rad(i * 360 / count + off)
				local C = CFrame.new(0, RC.Y, z) * ang(0, 0, math.deg(a)) * CFrame.new(0, r, 0)
				local glow = i % 2 == 0
				B:block(ring, glow and v(3.4, 0.5, 1.2) or v(3.6, 0.9, 1.6), C, glow and SKY or col2,
					{ mat = glow and "Neon" or nil, tr = 1, name = "RingPart" .. n })
			end
		end
		waterRing(ring, -3.5, 7.4, 12, 0, AQUA)
		waterRing(ring2, 4.5, 6.4, 10, 18, WHITE)
		local ringFx = B:block(ring, v(2, 2, 2), CFrame.new(RC), AQUA, { tr = 1, name = "RingFX" })
		B:light(ringFx, { name = "RingLight", color = SKY, brightness = 0.01, range = 18 })

		-- splash volume (belly-flop)
		local SC = v(0, 3.4, 0.5)
		local splash = B:block("Root", v(10, 1, 16), CFrame.new(SC), WHITE, { tr = 1, name = "SplashFX" })
		B:emitter(splash, "burst", { name = "SplashBurst", color = { "#ffffff", SKY, AQUA }, speed = { 10, 18 }, size = { 1.1, 0.8, 0 }, accel = { 0, -22, 0 }, spread = 70, life = { 0.6, 1.1 } })
		B:emitter(splash, "dust", { name = "SplashMist", color = { "#ffffff", "#bfefff" }, size = { 2, 3.5, 4.5 }, speed = { 6, 12 } })

		-- wave ring: blue slabs with white foam crests that burst outward
		for k = 1, 8 do
			local wb = B:bone("Wave" .. k, "Root", SC)
			B:block(wb, v(4.2, 1.2, 1.2), CFrame.new(SC), AQUA, { tr = 1, name = "WavePart" .. k })
			B:block(wb, v(3.6, 0.5, 0.8), CFrame.new(SC + v(0, 0.8, -0.1)), k % 2 == 0 and SKY or WHITE,
				{ mat = k % 2 == 0 and "Neon" or nil, tr = 1, name = "FoamPart" .. k })
		end
		-- splash droplet cubes
		for k = 1, 6 do
			local db = B:bone("Drop" .. k, "Root", SC + v(0, 1, 0))
			local s = k % 3 == 0 and 1.0 or 1.5
			B:block(db, v(s, s, s), CFrame.new(SC + v(0, 1, 0)), k % 2 == 0 and WHITE or AQUA, { tr = 1, name = "DropPart" .. k })
		end
		-- blowhole squirt cubes
		local BH = v(0, 13.0, -3.6)
		for k = 1, 4 do
			local sb = B:bone("Squirt" .. k, "Body1", BH)
			local s = k == 1 and 0.9 or 0.7
			B:block(sb, v(s, s, s), CFrame.new(BH), k % 2 == 0 and WHITE or SKY, { mat = k % 2 == 1 and "Neon" or nil, tr = 1, name = "SquirtPart" .. k })
		end
	end,
}
