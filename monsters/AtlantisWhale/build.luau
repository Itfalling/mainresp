--!nocheck
-- Atlantis Sky Whale (Divine): the gentle, motherly guardian of the lost city.
-- Built in the same family style as the Trident Swordfish / Temple Turtle /
-- Atlantean Pufferfish: a compact, chunky, stepped-voxel whale with a BIG
-- blunt cartoon head whose front is one readable face (two big corner eyes:
-- dark socket rim, white block, glowing sky iris, one pupil + glint, soft
-- kind brows, little lashes; rosy blush; one gentle smile with a tidy comb of
-- cream baleen plates; cream lower jaw with throat pleats) and a gold tiara.
-- All the richness lives on the BODY: ocean-blue hull with dark back and
-- cream pleated belly, bronze/gold harness collar and rune-engraved armour
-- plates, barnacles, humpback flippers with gold bracers, ridged tail and
-- stepped horizontal flukes with gold leading edges ...
-- ... and the miniature LOST CITY OF ATLANTIS on her back: a gold-trimmed
-- stone island with ring walls, gate, corner towers (they RISE), moat,
-- garden terrace with little houses, inner moat, a columned temple with a
-- stepped gold dome and a glowing crystal spire, waterfalls spilling down
-- both flanks, coral, seaweed and a broken column.
-- Hidden props for the motion: blowhole fountain, music notes, a heart, a
-- little clownfish friend, spire beam + halo of rays, firework chunks and a
-- splash crown.
return {
	DisplayName = "Atlantis Sky Whale",
	Rarity = "Divine",
	Element = "Atlantis",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		------------------------------------------------------------------
		-- palette (family colours: Swordfish/Turtle/Puffer)
		------------------------------------------------------------------
		local MAIN, DARK, NAVY, SPOT = "#3b82d9", "#25599f", "#173a73", "#8fc9f3"
		local CREAM, CREAM_D, PLEAT = "#f4ead0", "#dccb9f", "#c9b487"
		local GOLD, DGOLD, BRONZE, ENGRAVE = "#f2b632", "#d08a1e", "#b06a26", "#7a4310"
		local MARBLE, MARBLE_S, STONE, BARNACLE = "#f4efe2", "#d9d1bf", "#c9bfa6", "#e3d6b8"
		local CRYSTAL, TEAL, ROOF = "#2ad1c4", "#2fb8ae", "#2a9d8f"
		local WATER, WATERL = "#3fc9da", "#a8ecff"
		local SEA, SEA_L, CORAL = "#3f9a3c", "#86d65a", "#ff7a5c"
		local WHITE, PUPIL, MOUTH, TONGUE = "#ffffff", "#0d1020", "#2a0d18", "#ff7f8f"
		local PINK, BALEEN, BROW = "#ff9db5", "#e6dbc0", "#13284f"
		local TURQ, SKY, GOLDN = "#3ff0e0", "#6fe3ff", "#ffe27a" -- small neon accents
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- helpers
		------------------------------------------------------------------
		-- countershaded hull segment: blue core, dark back band + top cap,
		-- cream lower band + belly cap
		local function segment(bone, z0, z1, w, h, yc)
			local len, zc = z1 - z0, (z0 + z1) / 2
			B:block(bone, v(w, h, len), cf(0, yc, zc), MAIN)
			B:block(bone, v(w * 0.72, 0.6, len - 0.2), cf(0, yc + h / 2 + 0.25, zc), DARK)
			B:block(bone, v(w + 0.1, h * 0.28, len - 0.2), cf(0, yc + h * 0.36, zc), DARK)
			B:block(bone, v(w + 0.1, h * 0.28, len - 0.2), cf(0, yc - h * 0.36, zc), CREAM)
			B:block(bone, v(w * 0.78, 0.7, len - 0.4), cf(0, yc - h / 2 - 0.25, zc), CREAM)
		end
		-- rune-engraved orichalcum armour plate on the right flank (call in B:sym)
		local function plate(bone, x, y, z, h, d)
			B:block(bone, v(0.3, h, d), cf(x, y, z), BRONZE)
			B:block(bone, v(0.36, h - 0.6, d - 0.6), cf(x + 0.05, y, z), GOLD)
			B:block(bone, v(0.4, 0.25, d - 1.2), cf(x + 0.08, y + 0.35, z), ENGRAVE) -- rune bar
			B:block(bone, v(0.4, (h - 0.6) * 0.45, 0.25), cf(x + 0.08, y - 0.1, z - (d - 1.2) / 2 + 0.12), ENGRAVE) -- rune stem
			B:block(bone, v(0.42, 0.35, 0.35), cf(x + 0.1, y - 0.45, z + 0.3), TURQ, NEON) -- rune dot
		end
		-- octagonal tier = a wide-short block + a narrow-long block
		local function tier(bone, y, h, w, l, cut, z, col)
			B:block(bone, v(w, h, l - cut), cf(0, y, z), col)
			B:block(bone, v(w - cut, h, l), cf(0, y, z), col)
		end

		------------------------------------------------------------------
		-- BODY: the chunky hull (swim-chain centre, carries the city)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 9.3, 0))
		B:block(body, v(10.0, 7.8, 7.2), cf(0, 9.4, 0.4), MAIN)
		B:block(body, v(10.6, 4.4, 5.6), cf(0, 9.6, 0.4), MAIN) -- stepped side bulge
		B:block(body, v(10.1, 1.4, 7.0), cf(0, 12.4, 0.4), DARK) -- dark back band
		B:block(body, v(10.1, 1.6, 7.0), cf(0, 6.4, 0.4), CREAM) -- cream lower band
		B:block(body, v(8.2, 0.9, 6.8), cf(0, 5.1, 0.4), CREAM) -- belly cap
		for _, x in { -2.4, -0.8, 0.8, 2.4 } do
			B:block(body, v(0.3, 0.12, 6.6), cf(x, 4.62, 0.4), PLEAT) -- belly pleats
		end
		-- harness collar (bronze, gold rims) between head and hull
		B:block(body, v(10.9, 8.4, 0.8), cf(0, 9.3, -3.0), BRONZE)
		B:block(body, v(11.1, 0.5, 0.9), cf(0, 13.35, -3.0), GOLD)
		B:block(body, v(9.0, 0.5, 0.9), cf(0, 5.25, -3.0), GOLD)
		-- rear harness band
		B:block(body, v(10.3, 7.6, 0.5), cf(0, 9.4, 3.85), BRONZE)
		B:block(body, v(10.5, 0.4, 0.6), cf(0, 13.0, 3.85), GOLD)
		B:sym(function()
			B:block(body, v(0.2, 0.6, 0.6), cf(5.5, 9.6, -3.0), TURQ, NEON)
			plate(body, 5.3, 9.7, -0.6, 3.2, 2.6)
			plate(body, 5.3, 9.4, 2.1, 2.6, 2.0)
		end)
		-- barnacles (one side more than the other: worn ruin feel)
		B:block(body, v(0.5, 0.6, 0.7), cf(5.35, 7.6, 1.0), BARNACLE)
		B:block(body, v(0.4, 0.4, 0.4), cf(5.4, 7.2, 1.7), MARBLE)
		B:block(body, v(0.5, 0.5, 0.6), cf(-5.35, 7.7, -1.6), BARNACLE)
		local bodyFx = B:block(body, v(10, 8, 12), cf(0, 10, 2), MAIN, { tr = 1, name = "BodyFX" })
		B:emitter(bodyFx, "bubble", { name = "AmbientBubbles", color = { "#ffffff", "#9fe2ff" }, rate = 4, size = { 0.25, 0.45, 0.55 } })
		B:emitter(bodyFx, "sparkle", { name = "AmbientSparkle", color = { "#ffffff", GOLDN, TURQ }, rate = 3 })
		-- waterfall mist (both flanks, low on the hull)
		local mist = B:block(body, v(11.6, 0.4, 1.2), cf(0, 7.0, 0.6), MAIN, { tr = 1, name = "FallFX" })
		B:emitter(mist, "drip", { name = "FallMist", color = { "#ffffff", WATERL }, rate = 6, size = { 0.3, 0.4, 0.2 } })

		------------------------------------------------------------------
		-- BODY2 + TAIL chain (vertical whale stroke)
		------------------------------------------------------------------
		local body2 = B:bone("Body2", "Body", v(0, 9.4, 4.0))
		segment(body2, 3.9, 8.9, 8.8, 7.0, 9.5)
		B:sym(function()
			plate(body2, 4.45, 9.4, 6.4, 2.4, 2.0)
		end)
		B:block(body2, v(0.7, 0.12, 0.7), cf(1.2, 13.37, 5.6), SPOT) -- pale back spots
		B:block(body2, v(0.6, 0.12, 0.6), cf(-1.5, 13.37, 7.6), SPOT)
		B:block(body2, v(0.5, 0.6, 0.6), cf(-4.45, 7.4, 7.3), BARNACLE)
		-- little dorsal hump with a gold cap
		B:block(body2, v(1.2, 1.0, 2.2), cf(0, 13.8, 7.6), DARK)
		B:block(body2, v(1.3, 0.45, 1.3), cf(0, 14.4, 7.9), GOLD)
		B:block(body2, v(0.45, 0.45, 0.45), cf(0, 14.8, 7.9), TURQ, NEON)

		local tail1 = B:bone("Tail1", "Body2", v(0, 9.6, 8.8))
		segment(tail1, 8.6, 12.4, 6.6, 5.2, 9.9)
		B:block(tail1, v(6.8, 5.4, 0.4), cf(0, 9.9, 8.8), BRONZE)
		B:block(tail1, v(0.6, 0.12, 0.6), cf(0.9, 12.87, 10.6), SPOT)
		B:block(tail1, v(0.5, 0.8, 1.6), cf(0, 6.7, 11.0), CREAM) -- keel ridge

		local tail2 = B:bone("Tail2", "Tail1", v(0, 10.2, 12.3))
		segment(tail2, 12.2, 15.2, 4.6, 3.6, 10.6)
		B:block(tail2, v(4.8, 3.8, 0.35), cf(0, 10.6, 12.3), GOLD)
		B:block(tail2, v(0.5, 0.6, 1.4), cf(0, 13.0, 13.8), DARK) -- ridge knuckles
		B:block(tail2, v(0.45, 0.45, 0.45), cf(0, 13.45, 13.8), GOLD)

		local tail3 = B:bone("Tail3", "Tail2", v(0, 11.0, 15.1))
		B:block(tail3, v(3.0, 2.6, 2.2), cf(0, 11.3, 16.0), MAIN)
		B:block(tail3, v(2.2, 0.4, 2.0), cf(0, 12.7, 16.0), DARK)
		B:block(tail3, v(2.2, 0.4, 2.0), cf(0, 9.9, 16.0), CREAM)
		B:block(tail3, v(3.2, 2.8, 0.35), cf(0, 11.3, 15.15), BRONZE)

		------------------------------------------------------------------
		-- FLUKES: horizontal stepped rows sweeping back, gold leading edges
		------------------------------------------------------------------
		local FY = 11.4
		local fluke = B:bone("Fluke", "Tail3", v(0, FY, 16.9))
		local FC = CFrame.new(0, FY, 16.9) * ang(-10, 0, 0) -- tips tilt up a little
		local function fa(x, y, z)
			return FC * CFrame.new(x, y, z - 16.9)
		end
		B:block(fluke, v(2.6, 1.5, 1.8), fa(0, 0, 17.5), MAIN)
		B:block(fluke, v(1.8, 0.4, 1.2), fa(0, 0.9, 17.5), DARK)
		local rows = {
			{ 1.7, 16.9, 19.2, 1.4, 1.1, MAIN }, { 3.0, 17.2, 20.0, 1.3, 1.0, MAIN },
			{ 4.3, 17.7, 20.8, 1.3, 0.9, DARK }, { 5.6, 18.3, 21.4, 1.3, 0.8, DARK },
			{ 6.8, 19.0, 21.8, 1.1, 0.7, NAVY },
		}
		B:sym(function(side)
			for _, r in rows do
				B:block(fluke, v(r[4], r[5], r[3] - r[2]), fa(r[1], 0, (r[2] + r[3]) / 2), r[6])
				B:block(fluke, v(r[4] + 0.05, r[5] + 0.1, 0.5), fa(r[1], 0, r[2] + 0.2), GOLD)
			end
			B:block(fluke, v(2.4, 0.2, 1.6), fa(3.0, -0.6, 19.0), CREAM) -- pale underside
			B:block(fluke, v(0.55, 0.55, 0.6), fa(7.4, 0, 21.6), TURQ, NEON)
			B:trail(fluke, fa(7.4, 0.2, 21.7).Position, fa(6.0, 0.2, 21.7).Position, { name = "FlukeTrail" .. side, color = { "#ffffff", TURQ }, life = 0.3, trans = { 0.45, 1 } })
		end)

		------------------------------------------------------------------
		-- HEAD: big blunt cartoon head, the front is the face
		------------------------------------------------------------------
		local head = B:bone("Head", "Body", v(0, 9.3, -3.0))
		B:block(head, v(9.6, 5.2, 6.4), cf(0, 10.05, -6.2), MAIN) -- cranium (y 7.45..12.65)
		B:block(head, v(8.8, 1.0, 6.0), cf(0, 13.1, -6.0), MAIN) -- stepped forehead
		B:block(head, v(6.8, 0.5, 5.2), cf(0, 13.8, -5.6), DARK) -- crown cap
		B:block(head, v(9.7, 1.4, 2.6), cf(0, 12.0, -4.3), DARK) -- dark back band
		B:block(head, v(8.9, 0.5, 2.0), cf(0, 13.2, -4.2), DARK)
		B:block(head, v(0.6, 0.12, 0.6), cf(-1.6, 14.1, -6.6), SPOT)
		B:block(head, v(0.5, 0.12, 0.5), cf(2.0, 14.1, -5.1), SPOT)
		B:block(head, v(9.2, 0.8, 6.0), cf(0, 7.3, -6.1), MAIN) -- upper lip
		B:block(head, v(7.8, 0.3, 5.4), cf(0, 6.6, -6.2), MOUTH) -- palate
		-- the gentle smile: dark mouth slot with a tidy comb of baleen plates
		B:block(head, v(4.8, 0.7, 0.4), cf(0, 6.75, -9.0), MOUTH)
		for _, x in { -1.6, -0.8, 0, 0.8, 1.6 } do
			B:block(head, v(0.42, 0.36, 0.2), cf(x, 6.92, -9.22), BALEEN)
		end
		-- gold tiara with a turquoise gem on the forehead
		B:block(head, v(5.6, 0.45, 0.35), cf(0, 13.0, -9.15), GOLD)
		B:block(head, v(1.3, 1.3, 0.3), cf(0, 13.55, -9.2, 0, 0, 45), GOLD)
		B:block(head, v(0.6, 0.6, 0.2), cf(0, 13.55, -9.38, 0, 0, 45), TURQ, NEON)
		-- blowhole (gold rim)
		B:block(head, v(1.8, 0.3, 1.1), cf(0, 14.15, -4.2), GOLD)
		B:block(head, v(1.1, 0.1, 0.5), cf(0, 14.33, -4.2), MOUTH)
		local blow = B:block(head, v(1.0, 0.6, 1.0), cf(0, 14.6, -4.2), MAIN, { tr = 1, name = "BlowFX" })
		B:emitter(blow, "burst", { name = "SpoutBurst", color = { "#ffffff", WATERL }, size = { 0.6, 0.5, 0.2 }, speed = { 9, 15 }, spread = 22, life = { 0.8, 1.3 }, accel = { 0, -22, 0 } })
		local nose = B:block(head, v(1.5, 1.0, 0.6), cf(0, 8.6, -9.9), MAIN, { tr = 1, name = "NoseFX" })
		B:emitter(nose, "burst", { name = "BoopBurst", color = { "#ffffff", PINK, GOLDN }, size = { 0.6, 0.4, 0 }, speed = { 4, 9 }, life = { 0.4, 0.8 } })

		B:sym(function(side)
			-- smile corners curling up into the cheeks + side mouth line
			B:block(head, v(1.2, 0.5, 0.3), cf(2.85, 6.95, -9.05, 0, 0, 22), MOUTH)
			B:block(head, v(1.2, 0.45, 0.3), cf(3.95, 7.28, -9.05, 0, 0, 6), MOUTH)
			B:block(head, v(0.2, 0.45, 2.4), cf(4.62, 7.2, -7.9), MOUTH)
			-- rosy blush
			B:block(head, v(1.1, 0.45, 0.12), cf(3.75, 8.15, -9.43), PINK)
			-- gold cheek guard (no glowing dot: it would read as a second eye)
			B:block(head, v(0.26, 2.6, 2.4), cf(4.85, 9.6, -5.0), BRONZE)
			B:block(head, v(0.3, 2.0, 1.8), cf(4.9, 9.6, -5.0), GOLD)
			B:block(head, v(0.34, 0.25, 1.0), cf(4.93, 9.9, -5.0), ENGRAVE)
			-- BIG eye on the front corner: dark socket rim, white block, glowing
			-- sky iris, ONE pupil + glint on the front face only
			B:block(head, v(3.0, 3.4, 0.2), cf(3.45, 10.3, -9.4), NAVY)
			B:block(head, v(2.5, 3.0, 2.2), cf(3.55, 10.3, -8.45), WHITE)
			B:block(head, v(1.7, 2.3, 1.4), cf(3.45, 10.2, -9.0), SKY, { mat = "Neon", name = "Eye" .. side })
			local pup = B:bone("Pupil" .. side, "Head", v(3.4, 10.05, -9.76))
			B:block(pup, v(0.95, 1.5, 0.12), cf(3.4, 10.05, -9.76), PUPIL)
			B:block(pup, v(0.42, 0.42, 0.1), cf(3.68, 10.55, -9.83), WHITE, NEON)
			B:block(pup, v(0.2, 0.2, 0.1), cf(3.15, 9.55, -9.83), WHITE, NEON)
			-- little motherly lashes at the outer corner
			B:block(head, v(0.3, 0.6, 0.3), cf(4.9, 11.75, -9.3, 0, 0, -32), BROW)
			B:block(head, v(0.3, 0.5, 0.3), cf(5.1, 11.15, -9.2, 0, 0, -60), BROW)
			-- soft kind brow (outer end lower) on its own bone
			local brow = B:bone("Brow" .. side, "Head", v(3.4, 12.3, -9.2))
			B:block(brow, v(2.9, 0.7, 1.2), cf(3.5, 12.3, -9.15, 0, 0, -12), BROW)
			B:block(brow, v(1.0, 0.35, 1.0), cf(2.5, 12.7, -9.05, 0, 0, -12), DARK)
			-- eyelid (hidden above the eye until it blinks / squints)
			local lid = B:bone("Lid" .. side, "Head", v(3.55, 13.4, -8.55))
			B:block(lid, v(2.65, 3.1, 2.7), cf(3.55, 13.45, -8.55), MAIN, { tr = 1, name = "Eyelid" .. side })
			B:block(lid, v(2.75, 0.3, 2.75), cf(3.55, 11.95, -8.55), BROW, { tr = 1, name = "Lash" .. side })
		end)

		------------------------------------------------------------------
		-- JAW (hinged at the back of the mouth): cream with throat pleats
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", v(0, 6.9, -3.4))
		B:block(jaw, v(8.6, 1.5, 6.0), cf(0, 5.9, -6.15), CREAM)
		B:block(jaw, v(7.4, 0.7, 5.4), cf(0, 4.9, -5.9), CREAM_D)
		B:block(jaw, v(7.6, 0.2, 5.2), cf(0, 6.6, -6.1), MOUTH)
		B:block(jaw, v(4.4, 0.25, 4.0), cf(0, 6.75, -6.8), TONGUE)
		for _, x in { -2.4, -0.8, 0.8, 2.4 } do
			B:block(jaw, v(0.3, 0.12, 5.0), cf(x, 4.5, -5.9), PLEAT)
		end
		B:sym(function()
			B:block(jaw, v(0.12, 0.2, 5.0), cf(4.31, 5.5, -6.0), PLEAT)
		end)

		------------------------------------------------------------------
		-- HUMPBACK FLIPPERS with gold bracers (2 bones each)
		------------------------------------------------------------------
		B:sym(function(side)
			local F = CFrame.new(5.0, 7.4, -1.6) * ang(0, -25, -22)
			local function at(x, y, z)
				return F * CFrame.new(x, y, z)
			end
			local fin = B:bone("Fin" .. side, "Body", F.Position)
			B:block(fin, v(2.8, 1.1, 2.4), at(1.0, 0, 0.1), MAIN)
			B:block(fin, v(0.7, 1.45, 2.7), at(1.95, 0, 0.1), GOLD) -- bracer
			B:block(fin, v(0.75, 0.5, 0.5), at(1.95, 0.55, -0.9), TURQ, NEON)
			B:block(fin, v(1.4, 0.35, 1.8), at(0.9, 0.6, 0.1), DARK)
			local tip = B:bone("FinTip" .. side, "Fin" .. side, at(2.3, 0, 0).Position)
			B:block(tip, v(2.4, 0.85, 2.7), at(3.4, 0, 0.35), MAIN)
			B:block(tip, v(2.2, 0.75, 2.4), at(5.5, 0, 0.65), MAIN)
			B:block(tip, v(1.8, 0.65, 2.0), at(7.3, 0, 1.0), DARK)
			B:block(tip, v(1.0, 0.55, 1.1), at(8.6, 0, 1.1), NAVY)
			B:block(tip, v(6.0, 0.8, 0.5), at(5.2, 0.02, -0.95), CREAM) -- pale leading edge
			for _, k in { { 3.6, -1.25 }, { 5.4, -1.15 }, { 7.2, -0.6 } } do
				B:block(tip, v(0.6, 0.6, 0.5), at(k[1], 0, k[2]), CREAM) -- humpback knobs
			end
			B:block(tip, v(4.8, 0.3, 1.6), at(5.0, -0.45, 0.5), CREAM) -- pale underside
			B:block(tip, v(0.45, 0.95, 2.3), at(6.4, 0, 0.55), GOLD)
			local a, b = at(9.1, 0, 1.2), at(8.0, 0, 1.6)
			B:trail(tip, a.Position, b.Position, { name = "FinTrail" .. side, color = { "#ffffff", TURQ }, life = 0.25, trans = { 0.55, 1 } })
		end)

		------------------------------------------------------------------
		-- THE LOST CITY OF ATLANTIS (rides on the hull)
		------------------------------------------------------------------
		local CZ = 0.6
		local city = B:bone("City", "Body", v(0, 13.3, CZ))
		-- stone island foundation with a gold trim
		tier(city, 13.6, 0.6, 9.4, 7.6, 2.0, CZ, STONE)
		tier(city, 13.95, 0.15, 9.5, 7.7, 2.0, CZ, GOLD)
		-- outer moat
		B:block(city, v(7.2, 0.3, 5.6), cf(0, 14.1, CZ), WATER)
		-- ring wall (gate in front, spillways on the sides)
		local WZ = 3.15
		B:sym(function()
			B:block(city, v(2.5, 1.2, 0.7), cf(1.95, 14.6, CZ - WZ), MARBLE)
			B:block(city, v(2.5, 0.2, 0.8), cf(1.95, 15.25, CZ - WZ), GOLD)
			B:block(city, v(0.7, 1.2, 1.9), cf(3.9, 14.6, CZ - 1.55), MARBLE)
			B:block(city, v(0.7, 1.2, 1.9), cf(3.9, 14.6, CZ + 1.55), MARBLE)
			B:block(city, v(0.6, 0.45, 0.6), cf(3.9, 15.4, CZ - 1.2), MARBLE_S) -- merlons
			B:block(city, v(0.6, 0.45, 0.6), cf(3.9, 15.4, CZ + 1.9), MARBLE_S)
			-- rune tile on the foundation side
			B:block(city, v(0.15, 0.4, 1.0), cf(4.72, 13.6, CZ - 2.0), TEAL)
		end)
		B:block(city, v(6.4, 1.2, 0.7), cf(0, 14.6, CZ + WZ), MARBLE) -- back wall
		B:block(city, v(6.4, 0.2, 0.8), cf(0, 15.25, CZ + WZ), GOLD)
		-- gate: gold arch with a rune tile over a dark doorway
		B:block(city, v(1.6, 0.9, 0.3), cf(0, 14.4, CZ - WZ + 0.1), "#1d5e66")
		B:block(city, v(2.2, 0.5, 0.9), cf(0, 15.1, CZ - WZ), GOLD)
		B:block(city, v(0.4, 0.3, 0.1), cf(0, 15.1, CZ - WZ - 0.47), TURQ, NEON)
		-- garden terrace + little houses + hedges
		tier(city, 14.5, 0.8, 5.6, 4.8, 1.4, CZ, MARBLE)
		for _, h in { { 2.1, -1.7 }, { -2.1, -1.7 }, { -2.1, 1.75 } } do
			B:block(city, v(0.8, 0.7, 0.8), cf(h[1], 15.25, CZ + h[2]), MARBLE)
			B:block(city, v(1.0, 0.3, 1.0), cf(h[1], 15.7, CZ + h[2]), ROOF)
		end
		B:block(city, v(0.7, 0.5, 0.7), cf(2.1, 15.15, CZ + 1.75), SEA)
		B:block(city, v(0.4, 0.35, 0.4), cf(1.85, 15.5, CZ + 1.6), SEA_L)
		-- inner moat + central island
		tier(city, 15.0, 0.2, 4.0, 3.6, 1.0, CZ, WATER)
		tier(city, 15.35, 0.5, 3.2, 3.0, 0.8, CZ, MARBLE_S)
		B:block(city, v(3.0, 0.2, 2.8), cf(0, 15.65, CZ), GOLD)
		-- columned temple
		for _, p in { { 1.0, -1.0 }, { -1.0, -1.0 }, { 1.0, 1.0 }, { -1.0, 1.0 } } do
			B:block(city, v(0.5, 1.8, 0.5), cf(p[1], 16.6, CZ + p[2]), MARBLE)
			B:block(city, v(0.75, 0.25, 0.75), cf(p[1], 17.55, CZ + p[2]), GOLD)
		end
		B:block(city, v(0.7, 1.0, 0.7), cf(0, 16.3, CZ, 0, 45, 0), TEAL) -- sanctum crystal
		B:block(city, v(2.9, 0.45, 2.9), cf(0, 17.85, CZ), MARBLE)
		B:block(city, v(1.2, 0.3, 0.1), cf(0, 17.85, CZ - 1.48), TEAL)
		B:block(city, v(0.35, 0.2, 0.1), cf(0, 17.85, CZ - 1.55), TURQ, NEON)
		-- stepped gold dome
		B:block(city, v(2.6, 0.5, 2.6), cf(0, 18.3, CZ), GOLD)
		B:block(city, v(2.0, 0.5, 2.0), cf(0, 18.8, CZ), DGOLD)
		B:block(city, v(1.3, 0.5, 1.3), cf(0, 19.3, CZ), GOLD)
		B:block(city, v(0.7, 0.4, 0.7), cf(0, 19.75, CZ), BRONZE)
		-- broken column, fallen drum and coral on the terrace
		B:block(city, v(0.5, 1.1, 0.5), cf(0.4, 15.45, CZ + 2.0), MARBLE)
		B:block(city, v(0.35, 0.3, 0.4), cf(0.5, 16.1, CZ + 1.95), MARBLE_S)
		B:block(city, v(1.2, 0.45, 0.45), cf(-0.8, 15.1, CZ + 2.3, 0, 15, 0), MARBLE_S)
		B:block(city, v(0.4, 0.7, 0.4), cf(-3.3, 14.6, CZ + 2.5), CORAL)
		B:block(city, v(0.3, 0.45, 0.3), cf(-3.05, 15.0, CZ + 2.5, 0, 0, -25), CORAL)
		-- waterfalls spilling over the spillways and down both flanks
		B:sym(function(side)
			B:block(city, v(0.9, 0.35, 1.2), cf(4.45, 14.15, CZ), GOLD) -- spout lip
			B:block(city, v(0.7, 0.25, 1.0), cf(4.95, 14.0, CZ), WATERL, { tr = 0.2 })
			B:block(city, v(0.35, 2.2, 1.0), cf(5.25, 12.95, CZ), WATERL, { tr = 0.3 })
			B:block(city, v(0.35, 4.6, 1.0), cf(5.6, 9.6, CZ), WATERL, { tr = 0.3 })
			B:block(city, v(0.7, 0.4, 1.4), cf(5.65, 7.2, CZ), WHITE, { tr = 0.15 }) -- foam
			-- flowing streaks (slide down the fall, on their own bone)
			local flow = B:bone("Flow" .. side, "City", v(5.7, 12.0, CZ))
			B:block(flow, v(0.42, 0.6, 1.05), cf(5.7, 12.0, CZ), WHITE, { tr = 0.25 })
			B:block(flow, v(0.42, 0.6, 1.05), cf(5.7, 9.7, CZ), WHITE, { tr = 0.25 })
		end)
		-- seaweed tufts (2 bones each)
		for i, w in { { -2.7, 14.9, CZ - 1.2, 0.9 }, { 2.6, 14.9, CZ + 0.4, 0.8 } } do
			local x, y, z, s = w[1], w[2], w[3], w[4]
			local b1 = B:bone("Weed" .. i .. "a", "City", v(x, y, z))
			B:block(b1, v(0.5, 1.3 * s, 0.5), cf(x, y + 0.55 * s, z), SEA)
			B:block(b1, v(0.35, 0.8 * s, 0.35), cf(x + 0.4, y + 0.35 * s, z), SEA_L)
			local b2 = B:bone("Weed" .. i .. "b", "Weed" .. i .. "a", v(x, y + 1.15 * s, z))
			B:block(b2, v(0.4, 1.2 * s, 0.4), cf(x, y + 1.75 * s, z), SEA_L)
		end

		-- corner towers (shaft runs deep into the hull so they can RISE)
		local TW = { { 3.9, -WZ }, { -3.9, -WZ }, { 3.9, WZ }, { -3.9, WZ } }
		for i, p in TW do
			local x, z = p[1], CZ + p[2]
			local tw = B:bone("Tower" .. i, "City", v(x, 13.3, z))
			B:block(tw, v(1.4, 5.0, 1.4), cf(x, 13.6, z), MARBLE)
			B:block(tw, v(1.5, 0.25, 1.5), cf(x, 15.3, z), GOLD)
			B:block(tw, v(0.4, 0.6, 0.1), cf(x, 14.7, z - 0.72), "#1d5e66") -- window
			B:block(tw, v(1.7, 0.4, 1.7), cf(x, 16.3, z), ROOF)
			B:block(tw, v(1.2, 0.5, 1.2), cf(x, 16.75, z), ROOF)
			B:block(tw, v(0.6, 0.55, 0.6), cf(x, 17.25, z), GOLD)
			B:block(tw, v(0.3, 0.4, 0.3), cf(x, 17.7, z), GOLDN, NEON)
		end

		-- the crystal spire on the dome (its own bone: glows, beams)
		local spire = B:bone("Spire", "City", v(0, 19.9, CZ))
		B:block(spire, v(0.9, 1.4, 0.9), cf(0, 20.6, CZ, 0, 45, 0), CRYSTAL)
		B:block(spire, v(0.65, 1.2, 0.65), cf(0, 21.8, CZ, 0, 45, 0), CRYSTAL)
		local tipc = B:block(spire, v(0.42, 0.7, 0.42), cf(0, 22.7, CZ, 0, 45, 0), TURQ, { mat = "Neon", name = "SpireTip" })
		B:block(spire, v(0.35, 0.8, 0.35), cf(0.5, 20.4, CZ - 0.1, 0, 0, -25), TEAL)
		B:block(spire, v(0.35, 0.7, 0.35), cf(-0.45, 20.35, CZ + 0.15, 0, 0, 25), TURQ, NEON)
		B:light(tipc, { name = "SpireLight", color = TURQ, brightness = 0.5, range = 14 })
		B:emitter(tipc, "sparkle", { name = "SpireSparkle", color = { "#ffffff", TURQ, GOLDN }, rate = 3 })
		-- beam of light (hidden)
		B:block(spire, v(0.9, 16, 0.9), cf(0, 31.0, CZ), "#dffcff", { mat = "Neon", tr = 1, name = "Beam" })
		-- halo of rays (hidden), facing front
		local halo = B:bone("Halo", "Spire", v(0, 22.7, CZ))
		for i = 1, 8 do
			local a = (i - 1) * 45 + 22.5
			B:block(halo, v(0.35, 1.8, 0.35), CFrame.new(0, 22.7, CZ) * ang(0, 0, a) * CFrame.new(0, 2.9, 0), GOLDN, { mat = "Neon", tr = 1, name = "Ray" .. i })
		end
		local fw = B:block(city, v(9, 2, 7), cf(0, 19.5, CZ), STONE, { tr = 1, name = "FireworkFX" })
		B:emitter(fw, "burst", { name = "Fireworks", color = { "#ffffff", GOLDN, GOLD, TURQ }, size = { 0.9, 0.6, 0 }, speed = { 8, 16 }, life = { 0.6, 1.2 }, accel = { 0, -8, 0 } })
		B:light(fw, { name = "FireworkLight", color = GOLDN, brightness = 0.01, range = 16 })

		-- firework chunks (hidden): gold / crystal / marble cubes
		local chunkCol = { GOLD, TURQ, MARBLE, GOLDN, GOLD, TURQ, MARBLE, GOLDN }
		for k = 1, 8 do
			local cb = B:bone("Chunk" .. k, "City", v(0, 21.0, CZ))
			local s = (k % 3 == 0) and 0.7 or 1.0
			local neon = chunkCol[k] == TURQ or chunkCol[k] == GOLDN
			B:block(cb, v(s, s, s), cf(0, 21.0, CZ), chunkCol[k], { mat = neon and "Neon" or nil, tr = 1, name = "ChunkPart" .. k })
		end

		------------------------------------------------------------------
		-- blowhole fountain (hidden water column on the head)
		------------------------------------------------------------------
		local spout = B:bone("Spout", "Head", v(0, 14.3, -4.2))
		B:block(spout, v(0.9, 1.4, 0.9), cf(0, 15.0, -4.2), WATERL, { tr = 1, name = "Spout1" })
		B:block(spout, v(1.2, 1.4, 1.2), cf(0, 16.3, -4.2), WATERL, { tr = 1, name = "Spout2" })
		B:block(spout, v(1.6, 1.0, 1.6), cf(0, 17.5, -4.2), WHITE, { tr = 1, name = "Spout3" })
		B:block(spout, v(2.6, 0.6, 2.6), cf(0, 18.2, -4.2), WATERL, { tr = 1, name = "Spout4" })
		B:block(spout, v(0.6, 0.6, 0.6), cf(1.4, 17.7, -4.2), WHITE, { tr = 1, name = "Spout5" })
		B:block(spout, v(0.6, 0.6, 0.6), cf(-1.4, 17.7, -4.2), WHITE, { tr = 1, name = "Spout6" })

		------------------------------------------------------------------
		-- splash crown for the tail slap (hidden), around the flukes
		------------------------------------------------------------------
		local SPC = v(0, 4.0, 19.0)
		local splash = B:bone("Splash", "Root", SPC)
		for i = 0, 9 do
			local a = math.rad(i * 36)
			local h = (i % 2 == 0) and 2.4 or 1.6
			local p = SPC + v(math.cos(a) * 3.6, h / 2, math.sin(a) * 3.0)
			B:block(splash, v(0.8, h, 0.8), CFrame.new(p) * ang(0, -i * 36, 0), i % 2 == 0 and WATERL or WHITE, { tr = 1, name = "SplashP" .. i })
		end
		local spfx = B:block(splash, v(6, 1, 6), CFrame.new(SPC), MAIN, { tr = 1, name = "SplashFX" })
		B:emitter(spfx, "burst", { name = "SplashBurst", color = { "#ffffff", WATERL, "#9fe2ff" }, size = { 0.8, 0.6, 0.1 }, speed = { 8, 16 }, spread = 50, life = { 0.6, 1.2 }, accel = { 0, -20, 0 } })

		------------------------------------------------------------------
		-- music notes (hidden): glowing gold face + navy backing
		------------------------------------------------------------------
		for k, n in { { 2.2, 15.0, -10.8 }, { -2.6, 15.6, -10.6 } } do
			local o = v(n[1], n[2], n[3])
			local nb = B:bone("Note" .. k, "Root", o)
			local cells = { { 0, 0, 0.8, 0.65 }, { 0.3, 0.9, 0.22, 1.5 }, { 0.6, 1.5, 0.5, 0.3 } }
			for j, c in cells do
				local p = o + v(c[1], c[2], 0)
				B:block(nb, v(c[3], c[4], 0.25), CFrame.new(p), GOLDN, { mat = "Neon", tr = 1, name = "Note" .. k .. "f" .. j })
				B:block(nb, v(c[3] + 0.2, c[4] + 0.2, 0.2), CFrame.new(p + v(0, 0, 0.2)), NAVY, { tr = 1, name = "Note" .. k .. "b" .. j })
			end
		end

		------------------------------------------------------------------
		-- a heart (hidden) that pops after the nose boop
		------------------------------------------------------------------
		local HO = v(0, 16.2, -10.6)
		local heart = B:bone("Heart", "Root", HO)
		local hp = { { -0.4, 0.35, 0.75, 0.7 }, { 0.4, 0.35, 0.75, 0.7 }, { 0, -0.15, 1.5, 0.6 }, { 0, -0.6, 0.7, 0.45 } }
		for j, c in ipairs(hp) do
			B:block(heart, v(c[3], c[4], 0.35), CFrame.new(HO + v(c[1], c[2], 0)), "#ff6f9a", { mat = "Neon", tr = 1, name = "HeartP" .. j })
		end

		------------------------------------------------------------------
		-- little clownfish friend (always visible, swims around her)
		------------------------------------------------------------------
		local FO = v(0, 16.5, -12.0)
		local fish = B:bone("Fish", "Root", FO)
		B:block(fish, v(0.8, 0.9, 1.4), CFrame.new(FO), "#ff8a2a")
		B:block(fish, v(0.85, 0.95, 0.3), CFrame.new(FO + v(0, 0, -0.1)), WHITE)
		B:block(fish, v(0.2, 0.9, 0.5), CFrame.new(FO + v(0, 0, 0.9)), "#ff8a2a")
		B:block(fish, v(0.22, 0.4, 0.4), CFrame.new(FO + v(0, 0.55, 0.15)), "#ff8a2a")
		B:block(fish, v(0.86, 0.2, 0.2), CFrame.new(FO + v(0, 0.15, -0.45)), PUPIL)

		------------------------------------------------------------------
		-- floating voxel cubes (blue with gold caps, gold with blue caps,
		-- a broken marble column) each with a thin turquoise band
		------------------------------------------------------------------
		local orbs = {
			{ 10.5, 15.0, -6.0, 1.6, MAIN, GOLD }, { -10.5, 13.0, -2.0, 1.4, GOLD, MAIN },
			{ 9.5, 7.5, 7.0, 1.1, "column" }, { -9.5, 16.5, 7.5, 1.6, MAIN, GOLD },
			{ 4.5, 21.5, 7.5, 1.0, "column" }, { -8.0, 6.5, -9.0, 1.2, DARK, GOLD },
		}
		for i, o in orbs do
			local ob = B:bone("Orb" .. i, "Root", v(o[1], o[2], o[3]))
			local s = o[4]
			if o[5] == "column" then
				B:block(ob, v(s, s * 2.0, s), cf(o[1], o[2], o[3]), MARBLE)
				B:block(ob, v(s * 1.5, s * 0.35, s * 1.5), cf(o[1], o[2] + s * 1.1, o[3]), GOLD)
				B:block(ob, v(s * 1.35, s * 0.35, s * 1.35), cf(o[1], o[2] - s * 1.1, o[3]), BARNACLE)
				B:block(ob, v(s + 0.12, s * 0.16, s + 0.12), cf(o[1], o[2] + s * 0.3, o[3]), TURQ, NEON)
			else
				B:block(ob, v(s, s, s), cf(o[1], o[2], o[3]), o[5])
				B:block(ob, v(s + 0.1, s * 0.3, s + 0.1), cf(o[1], o[2] + s * 0.36, o[3]), o[6])
				B:block(ob, v(s + 0.16, s * 0.14, s + 0.16), cf(o[1], o[2] - s * 0.1, o[3]), TURQ, NEON)
			end
		end
	end,
}
