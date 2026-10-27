--!nocheck
-- Temple Turtle: a sleepy, kind old grandpa sea turtle from sunken Atlantis.
-- Sea-green studded skin with a darker shade, cream belly plates, big sweeping
-- flippers with orichalcum gold bands. Its shell is a stepped temple ruin:
-- octagonal stepped tiers (mossy stone -> moss -> marble) with seam plates,
-- carved rune tiles, barnacles, moss drips and little marble stairs, crowned
-- by a tiny Atlantis shrine (marble columns, one broken, a gold-trimmed
-- stepped dome) that guards a glowing turquoise orichalcum crystal.
-- Face: big droopy-lidded kind eyes, bushy white brows, cream beak, rosy
-- cheeks, saggy jowls and a white beard with moss tufts. A snot bubble grows
-- while it dozes; blocky "Z"s float up.
-- Neon is limited to the eyes, the crystal tip, rune dots and the roof finial.
return {
	DisplayName = "Temple Turtle",
	Rarity = "Rare",
	Element = "Atlantis",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local SKIN, SKIN_D, SKIN_L = "#4fae7a", "#2f7a52", "#7fcf9a"
		local CREAM, CREAM_D = "#f3e6bf", "#d9c48f"
		local STONE, STONE_D = "#a9ad97", "#6f7663"
		local MOSS, MOSS_D, SEA, SEA_L = "#6aa64c", "#4b7f37", "#3f9a3c", "#86d65a"
		local MARBLE, MARBLE_S = "#f2eee3", "#d6cfbf"
		local GOLD, BRONZE = "#e9b63c", "#b77d33"
		local TEAL, TURQ, GOLDN = "#2fb8ae", "#3ff0e0", "#ffe27a"
		local BEAK, WHITE, DARK = "#e8cf86", "#f7f6f0", "#1d1420"
		local PINK, TONGUE, EYE = "#f29a9a", "#e2707f", "#a8fff4"
		local BUB = "#c4f4ff"
		local NEON = { mat = "Neon" }
		local CZ = 0.5 -- shell center (z)

		------------------------------------------------------------------
		-- BODY: plastron + stepped temple-ruin carapace
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 6, CZ))
		-- octagonal tier = a wide-short block + a narrow-long block
		local function tier(y, h, w, l, cut, col)
			B:block(body, v(w, h, l - cut), cf(0, y, CZ), col)
			B:block(body, v(w - cut, h, l), cf(0, y, CZ), col)
		end
		-- plastron (cream belly plates, stepped)
		tier(3.15, 0.9, 8.4, 10.6, 2.2, CREAM)
		B:block(body, v(6.2, 0.5, 8.0), cf(0, 2.5, CZ), CREAM_D)
		for _, z in { -2.1, 0.5, 3.1 } do
			B:block(body, v(8.5, 0.35, 0.3), cf(0, 3.25, CZ + z - 0.5), CREAM_D) -- plate seams
		end
		-- marginal rim
		tier(4.1, 1.0, 11.0, 13.0, 3.0, STONE_D)
		-- tier 1 stone
		tier(5.3, 1.4, 10.0, 12.0, 2.8, STONE)
		-- tier 2 moss
		tier(6.7, 1.4, 8.4, 10.2, 2.6, MOSS)
		-- tier 3 marble with an orichalcum band
		tier(8.0, 1.2, 6.6, 8.2, 2.2, MARBLE)
		tier(7.55, 0.3, 6.75, 8.35, 2.2, GOLD)
		-- tier 4 platform
		B:block(body, v(5.2, 0.5, 5.2), cf(0, 8.85, CZ), MARBLE_S)

		-- scute seams: one block shows a dark plate line on both sides
		for _, z in { -2.4, 1.0, 4.2 } do
			B:block(body, v(10.1, 1.2, 0.35), cf(0, 5.3, CZ + z - 0.5), STONE_D)
		end
		for _, z in { -1.2, 2.4 } do
			B:block(body, v(8.5, 1.25, 1.6), cf(0, 6.7, CZ + z - 0.5), MOSS_D)
		end
		-- marble stairs climbing the tiers (front and back)
		for _, s in { 1, -1 } do
			B:block(body, v(2.4, 0.3, 1.0), cf(0, 6.1, CZ + s * 5.55), MARBLE_S)
			B:block(body, v(2.4, 0.3, 1.0), cf(0, 7.5, CZ + s * 4.65), MARBLE)
			B:block(body, v(2.4, 0.3, 1.0), cf(0, 8.7, CZ + s * 3.7), MARBLE_S)
		end
		B:sym(function()
			-- carved rune tiles with a glowing dot
			for _, z in { -1.2, 2.6 } do
				B:block(body, v(0.2, 0.9, 1.0), cf(5.05, 5.3, CZ + z), TEAL)
				B:block(body, v(0.16, 0.35, 0.35), cf(5.2, 5.3, CZ + z), TURQ, NEON)
			end
			-- moss drips over the tier edges
			B:block(body, v(0.3, 0.9, 1.2), cf(4.25, 6.25, CZ - 3.2), MOSS)
			B:block(body, v(0.3, 0.6, 0.9), cf(4.25, 6.1, CZ + 0.9), MOSS)
			B:block(body, v(1.0, 0.7, 0.3), cf(2.6, 6.3, CZ - 5.15), MOSS)
			-- gold rim studs on the marginal plates
			B:block(body, v(0.25, 0.5, 0.5), cf(5.55, 4.1, CZ - 2.4), GOLD)
			B:block(body, v(0.25, 0.5, 0.5), cf(5.55, 4.1, CZ + 2.6), GOLD)
		end)
		-- marginal scallops (one block shows a plate on both sides)
		for i, z in { -3.4, 0.2, 3.8 } do
			B:block(body, v(11.4, 0.8, 1.4), cf(0, 4.1, CZ + z), i % 2 == 0 and STONE or MOSS_D)
		end
		-- Atlantis gateway over the neck opening (the head tucks in through it)
		B:sym(function()
			B:block(body, v(0.9, 3.2, 0.9), cf(3.3, 6.1, -6.0), MARBLE_S)
			B:block(body, v(1.2, 0.4, 1.2), cf(3.3, 7.75, -6.0), GOLD)
			B:block(body, v(1.1, 0.3, 1.1), cf(3.3, 4.6, -6.0), GOLD)
		end)
		B:block(body, v(7.9, 0.7, 1.0), cf(0, 8.3, -6.0), MARBLE)
		B:block(body, v(8.1, 0.25, 1.1), cf(0, 8.7, -6.0), GOLD)
		B:block(body, v(1.0, 0.9, 0.2), cf(0, 8.3, -6.55), TEAL)
		B:block(body, v(0.4, 0.4, 0.12), cf(0, 8.3, -6.68), TURQ, NEON)
		-- barnacles (little stepped cream/stone clusters)
		local barn = { { 4.2, 6.1, CZ - 4.4 }, { -4.6, 6.1, CZ + 3.4 }, { -3.0, 7.5, CZ - 3.3 }, { 3.1, 4.75, CZ + 6.1 } }
		for _, b in barn do
			B:block(body, v(0.8, 0.5, 0.8), cf(b[1], b[2] + 0.2, b[3]), CREAM_D)
			B:block(body, v(0.4, 0.3, 0.4), cf(b[1], b[2] + 0.55, b[3]), STONE_D)
		end

		-- invisible FX volumes
		local vol = B:block(body, v(10, 6, 12), cf(0, 7, CZ), STONE, { tr = 1, name = "BodyFX" })
		B:emitter(vol, "bubble", { name = "AmbientBubbles", color = { "#ffffff", "#9fe2ff" }, rate = 4, size = { 0.2, 0.4, 0.5 } })
		B:emitter(vol, "burst", { name = "BubbleBurst", color = { "#ffffff", "#9fe2ff", BUB }, size = { 0.5, 0.8, 0.2 }, speed = { 5, 11 }, life = { 0.7, 1.3 }, accel = { 0, 4, 0 } })
		local dust = B:block(body, v(6, 1, 6), cf(0, 9.2, CZ), STONE, { tr = 1, name = "TempleFX" })
		B:emitter(dust, "burst", { name = "RattleBits", color = { MARBLE, MARBLE_S, GOLD }, size = { 0.5, 0.4, 0 }, speed = { 5, 10 }, life = { 0.5, 1.0 }, accel = { 0, -18, 0 }, spread = 70 })

		------------------------------------------------------------------
		-- TEMPLE SHRINE (rattles as one, roof hops on its own)
		------------------------------------------------------------------
		local shrine = B:bone("Shrine", "Body", v(0, 9.1, CZ))
		B:block(shrine, v(4.6, 0.5, 4.6), cf(0, 9.35, CZ), MARBLE)
		B:block(shrine, v(4.7, 0.2, 4.7), cf(0, 9.2, CZ), GOLD)
		local cols = { { 1.65, -1.65, true }, { -1.65, -1.65, true }, { 1.65, 1.65, true }, { -1.65, 1.65, false } }
		for _, c in cols do
			local x, z = c[1], CZ + c[2]
			B:block(shrine, v(0.95, 0.3, 0.95), cf(x, 9.75, z), MARBLE_S)
			if c[3] then
				B:block(shrine, v(0.7, 2.4, 0.7), cf(x, 11.1, z), MARBLE)
				B:block(shrine, v(0.76, 0.3, 0.76), cf(x, 10.4, z), MARBLE_S) -- fluting ring
				B:block(shrine, v(1.0, 0.35, 1.0), cf(x, 12.45, z), GOLD)
			else
				-- broken column: short shaft with a jagged top
				B:block(shrine, v(0.7, 1.2, 0.7), cf(x, 10.5, z), MARBLE)
				B:block(shrine, v(0.4, 0.4, 0.45), cf(x + 0.12, 11.3, z - 0.1), MARBLE_S)
			end
		end
		-- architrave with gold band and rune tile (front)
		B:block(shrine, v(4.4, 0.5, 4.4), cf(0, 12.85, CZ), MARBLE)
		B:block(shrine, v(4.5, 0.25, 4.5), cf(0, 12.7, CZ), GOLD)
		B:block(shrine, v(1.6, 0.3, 0.12), cf(0, 12.9, CZ - 2.25), TEAL)
		B:block(shrine, v(0.35, 0.2, 0.1), cf(0, 12.9, CZ - 2.33), TURQ, NEON)
		-- seaweed creeping on the shrine floor
		B:block(shrine, v(0.5, 0.5, 0.5), cf(-1.0, 9.85, CZ + 1.6), SEA)

		-- roof: gold-trimmed stepped dome
		local roof = B:bone("Roof", "Shrine", v(0, 13.1, CZ))
		B:block(roof, v(4.0, 0.25, 4.0), cf(0, 13.2, CZ), GOLD)
		B:block(roof, v(3.6, 0.6, 3.6), cf(0, 13.55, CZ), MARBLE)
		B:block(roof, v(2.6, 0.5, 2.6), cf(0, 14.1, CZ), MARBLE_S)
		B:block(roof, v(1.6, 0.5, 1.6), cf(0, 14.6, CZ), GOLD)
		B:block(roof, v(0.8, 0.5, 0.8), cf(0, 15.1, CZ), BRONZE)
		B:block(roof, v(0.4, 0.5, 0.4), cf(0, 15.6, CZ), GOLDN, NEON)
		B:block(roof, v(2.7, 0.15, 2.7), cf(0, 13.92, CZ), GOLD) -- trim line between steps

		-- the orichalcum crystal inside the shrine
		local crystal = B:bone("Crystal", "Shrine", v(0, 10.0, CZ))
		B:block(crystal, v(1.1, 0.5, 1.1), cf(0, 9.85, CZ), GOLD)
		B:block(crystal, v(0.8, 1.3, 0.8), cf(0, 10.75, CZ, 0, 45, 0), TEAL)
		B:block(crystal, v(0.5, 0.6, 0.5), cf(0, 11.65, CZ, 0, 45, 0), TURQ, NEON)
		B:block(crystal, v(0.35, 0.7, 0.35), cf(0.5, 10.5, CZ - 0.1, 0, 0, -25), TURQ, NEON)
		B:block(crystal, v(0.35, 0.6, 0.35), cf(-0.45, 10.45, CZ + 0.15, 0, 0, 25), TEAL)
		local flash = B:block(crystal, v(1.3, 2.2, 1.3), cf(0, 10.9, CZ, 0, 45, 0), TURQ, { mat = "Neon", tr = 1, name = "CrystalFlash" })
		B:light(flash, { name = "CrystalLight", color = TURQ, brightness = 0.6, range = 12 })
		B:emitter(flash, "sparkle", { name = "CrystalSparkle", color = { "#ffffff", TURQ }, rate = 3 })
		B:emitter(flash, "burst", { name = "AwakeBurst", color = { "#ffffff", TURQ, GOLDN }, size = { 0.8, 0.6, 0 }, speed = { 9, 17 } })
		B:emitter(flash, "burst", {
			name = "ChargeMotes", color = { "#ffffff", TURQ }, life = { 0.3, 0.6 }, speed = { -9, -5 }, size = { 0.3, 0.4, 0 }, spread = 180, drag = 0,
		})
		-- sun rays (hidden, flashed on the awakening)
		for i = 1, 8 do
			local a = (i - 1) * 45 + 22.5
			B:block(crystal, v(0.3, 0.3, 1.8), CFrame.new(0, 10.9, CZ) * ang(0, 0, a) * CFrame.new(0, 3.4, 0) * ang(90, 0, 0), GOLDN, { mat = "Neon", tr = 1, name = "Ray" .. i })
		end

		-- fallen column drum + capital lying before the shrine entrance
		local fallen = B:bone("Fallen", "Body", v(0.2, 8.6, CZ - 2.9))
		B:block(fallen, v(2.2, 0.7, 0.7), cf(0.7, 8.95, CZ - 2.9, 0, 12, 0), MARBLE)
		B:block(fallen, v(0.3, 0.76, 0.76), cf(0.3, 8.95, CZ - 2.82, 0, 12, 0), MARBLE_S)
		B:block(fallen, v(0.9, 0.8, 0.9), cf(-1.05, 9.0, CZ - 3.0, 0, -18, 8), GOLD)

		------------------------------------------------------------------
		-- SEAWEED tufts (2 bones each) sprouting from the ruins
		------------------------------------------------------------------
		local tufts = {
			{ "WeedA", -3.6, 7.4, CZ - 2.6, 1.0 },
			{ "WeedB", 3.4, 7.4, CZ + 3.3, 0.9 },
			{ "WeedC", -2.0, 8.6, CZ + 3.9, 0.8 },
			{ "WeedD", 4.6, 6.0, CZ - 1.9, 0.8 },
		}
		for _, w in tufts do
			local x, y, z, s = w[2], w[3], w[4], w[5]
			local b1 = B:bone(w[1] .. "1", "Body", v(x, y, z))
			B:block(b1, v(0.55, 1.4 * s, 0.55), cf(x, y + 0.6 * s, z), SEA)
			B:block(b1, v(0.4, 0.9 * s, 0.4), cf(x + 0.45, y + 0.35 * s, z + 0.2), SEA_L)
			B:block(b1, v(0.4, 0.7 * s, 0.4), cf(x - 0.35, y + 0.3 * s, z - 0.3), SEA)
			local b2 = B:bone(w[1] .. "2", w[1] .. "1", v(x, y + 1.25 * s, z))
			B:block(b2, v(0.45, 1.3 * s, 0.45), cf(x, y + 1.85 * s, z), SEA_L)
			B:block(b2, v(0.35, 0.6 * s, 0.35), cf(x + 0.15, y + 2.7 * s, z), SEA)
		end

		------------------------------------------------------------------
		-- NECK + HEAD (grandpa face)
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Body", v(0, 5.4, -4.6))
		B:block(neck, v(3.0, 2.6, 3.6), cf(0, 5.6, -6.0), SKIN)
		B:block(neck, v(3.1, 2.7, 0.35), cf(0, 5.6, -6.5), SKIN_D) -- wrinkle rings
		B:block(neck, v(3.1, 2.7, 0.35), cf(0, 5.6, -7.3), SKIN_D)
		B:block(neck, v(2.2, 0.4, 3.2), cf(0, 4.25, -6.0), CREAM)

		local head = B:bone("Head", "Neck", v(0, 6.2, -7.4))
		B:block(head, v(5.6, 4.0, 4.6), cf(0, 7.2, -9.5), SKIN) -- cranium
		B:block(head, v(5.9, 1.6, 2.8), cf(0, 6.2, -9.2), SKIN) -- saggy jowls
		B:block(head, v(3.8, 0.4, 3.2), cf(0, 9.4, -9.2), SKIN_D) -- head scale plate
		B:block(head, v(1.4, 0.35, 1.2), cf(0, 9.7, -9.0), SKIN_L)
		B:block(head, v(4.2, 0.3, 4.2), cf(0, 5.1, -9.7), DARK) -- mouth roof
		-- upper beak with a little hook
		B:block(head, v(2.8, 0.9, 0.9), cf(0, 5.8, -12.2), BEAK)
		B:block(head, v(1.2, 0.5, 0.45), cf(0, 5.15, -12.45), BEAK)
		B:block(head, v(2.0, 0.2, 0.7), cf(0, 6.3, -12.25), CREAM_D)
		B:sym(function()
			B:block(head, v(0.3, 0.15, 0.3), cf(0.55, 6.42, -12.4), DARK) -- nostril
			-- side scale spots + wrinkle
			B:block(head, v(0.15, 1.0, 1.2), cf(2.85, 8.3, -8.6), SKIN_D)
			B:block(head, v(0.15, 0.6, 0.8), cf(2.85, 7.5, -7.9), SKIN_D)
			B:block(head, v(0.15, 0.25, 1.6), cf(2.97, 6.6, -9.4), SKIN_D) -- jowl crease
			-- rosy cheeks
			B:block(head, v(0.15, 0.6, 1.0), cf(2.97, 6.1, -10.0), PINK)
			B:block(head, v(0.8, 0.4, 0.12), cf(2.0, 6.15, -11.86), PINK)
			-- side whisker tufts
			B:block(head, v(0.6, 0.6, 0.8), cf(3.0, 5.6, -8.5), WHITE)
		end)
		-- snot bubble (3 nested sizes, revealed one after another while dozing)
		for i, s in { 0.5, 1.0, 1.6 } do
			B:block(head, v(s, s, s), cf(0.7, 6.6 + s * 0.3, -12.8 - s * 0.45), BUB, { tr = 1, name = "Snore" .. i })
		end
		local mouthFX = B:block(head, v(1.5, 1.0, 1.0), cf(0, 5.6, -13.2), SKIN, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFX, "bubble", { name = "YawnBubbles", color = { "#ffffff", BUB }, rate = 18, enabled = false, size = { 0.3, 0.6, 0.7 }, speed = { 2, 4 }, spread = 35 })
		B:emitter(mouthFX, "burst", { name = "SnorePop", color = { "#ffffff", BUB }, size = { 0.4, 0.3, 0 }, speed = { 4, 8 }, life = { 0.3, 0.6 } })

		-- Zzz glyphs (hidden blocky letters that float up while dozing)
		for _, zz in { { "ZzzA", 1.6 }, { "ZzzB", 1.2 } } do
			local s = zz[2]
			local o = v(3.2, 11.4, -10.6)
			local zb = B:bone(zz[1], "Head", o)
			local R = CFrame.new(o) * ang(0, -30, 0)
			local id = zz[1]
			B:block(zb, v(1.3 * s, 0.32 * s, 0.32 * s), R * CFrame.new(0, 0.55 * s, 0), "#ffffff", { tr = 1, name = id .. "1" })
			B:block(zb, v(1.3 * s, 0.32 * s, 0.32 * s), R * CFrame.new(0, -0.55 * s, 0), "#ffffff", { tr = 1, name = id .. "2" })
			B:block(zb, v(0.32 * s, 1.45 * s, 0.32 * s), R * ang(0, 0, -42), "#9fe2ff", { tr = 1, name = id .. "3" })
		end

		-- EYES (own bones so they can pop on the surprised wake-up)
		B:sym(function(side)
			local eye = B:bone("Eye" .. side, "Head", v(1.5, 7.55, -11.8))
			B:block(eye, v(2.3, 2.5, 0.2), cf(1.5, 7.55, -11.85), SKIN_D) -- socket rim
			B:block(eye, v(1.9, 2.1, 0.3), cf(1.5, 7.55, -11.92), EYE, { mat = "Neon", name = "EyeGlow" .. side })
			B:block(eye, v(0.95, 1.25, 0.12), cf(1.28, 7.3, -12.13), DARK)
			B:block(eye, v(0.4, 0.4, 0.1), cf(1.45, 7.65, -12.2), WHITE, NEON)
			B:block(eye, v(0.2, 0.2, 0.1), cf(1.0, 6.9, -12.2), WHITE, NEON)
			B:block(eye, v(0.3, 2.1, 1.1), cf(2.92, 7.55, -11.2), EYE, NEON)
			B:block(eye, v(0.12, 1.25, 0.55), cf(3.1, 7.3, -11.4), DARK)
			-- heavy droopy eyelid (a third closed at rest)
			local lid = B:bone("Lid" .. side, "Eye" .. side, v(1.5, 8.85, -12.0))
			B:block(lid, v(2.25, 1.7, 0.35), cf(1.5, 8.85, -12.25), SKIN_D, { name = "LidF" .. side })
			B:block(lid, v(0.4, 1.7, 1.4), cf(3.12, 8.85, -11.25), SKIN_D, { name = "LidS" .. side })
			B:block(lid, v(2.35, 0.25, 0.45), cf(1.5, 8.05, -12.27), DARK, { name = "Lash" .. side })
			-- bushy white grandpa brows (droop at the outer end)
			local brow = B:bone("Brow" .. side, "Head", v(0.6, 9.6, -12.0))
			B:block(brow, v(2.7, 0.9, 1.3), cf(1.55, 9.85, -12.0, 0, 0, -12), WHITE)
			B:block(brow, v(1.3, 0.55, 1.0), cf(1.0, 10.4, -11.8), WHITE)
			B:block(brow, v(1.0, 0.9, 1.0), cf(2.85, 9.3, -11.9), WHITE)
			B:block(brow, v(0.6, 0.45, 0.6), cf(3.25, 8.85, -11.8), CREAM)
		end)

		-- JAW (lower beak) + beard
		local jaw = B:bone("Jaw", "Head", v(0, 5.1, -7.6))
		B:block(jaw, v(4.6, 1.1, 4.0), cf(0, 4.45, -9.6), SKIN)
		B:block(jaw, v(2.8, 0.8, 0.9), cf(0, 4.65, -11.95), CREAM_D)
		B:block(jaw, v(4.0, 0.2, 3.6), cf(0, 5.02, -9.6), DARK)
		B:block(jaw, v(1.8, 0.3, 2.0), cf(0, 5.15, -10.2), TONGUE)
		B:block(jaw, v(3.8, 0.4, 3.4), cf(0, 3.75, -9.4), CREAM)
		local beard1 = B:bone("Beard1", "Jaw", v(0, 3.8, -10.6))
		B:block(beard1, v(2.8, 1.0, 1.2), cf(0, 3.3, -10.8), WHITE)
		B:block(beard1, v(0.8, 0.7, 0.9), cf(1.3, 3.05, -10.95), MOSS)
		B:block(beard1, v(0.7, 0.6, 0.8), cf(-1.25, 3.0, -10.9), MOSS_D)
		local beard2 = B:bone("Beard2", "Beard1", v(0, 2.9, -10.85))
		B:block(beard2, v(1.8, 0.9, 1.0), cf(0, 2.6, -10.95), WHITE)
		B:block(beard2, v(1.0, 0.7, 0.8), cf(0.1, 1.95, -11.0), MOSS)

		------------------------------------------------------------------
		-- FLIPPERS: 2 bones each (shoulder + blade)
		------------------------------------------------------------------
		local function flipper(prefix, pivot, yaw, droop, sc, band)
			B:sym(function(side)
				local F = CFrame.new(pivot) * ang(0, yaw, droop)
				local function at(x, y, z)
					return F * CFrame.new(x * sc, y * sc, z * sc)
				end
				local arm = B:bone(prefix .. side, "Body", F)
				B:block(arm, v(2.8, 1.3, 2.4) * sc, at(1.0, 0, 0), SKIN)
				B:block(arm, v(1.2, 1.35, 1.0) * sc, at(1.2, 0, 0.6), SKIN_D)
				if band then
					B:block(arm, v(0.5, 1.45, 2.55) * sc, at(2.1, 0, 0), GOLD)
					B:block(arm, v(0.52, 0.4, 0.4) * sc, at(2.1, 0.55, -0.6), TURQ, NEON)
				end
				local tip = B:bone(prefix .. "Tip" .. side, prefix .. side, at(2.4, 0, 0))
				B:block(tip, v(3.0, 1.0, 2.8) * sc, at(3.8, 0, 0.2), SKIN)
				B:block(tip, v(2.6, 0.9, 2.2) * sc, at(6.4, 0, 0.5), SKIN)
				B:block(tip, v(1.6, 0.8, 1.4) * sc, at(8.3, 0, 0.9), SKIN_D)
				B:block(tip, v(3.0, 1.05, 0.6) * sc, at(3.8, 0, -1.4), CREAM)
				B:block(tip, v(2.6, 0.95, 0.6) * sc, at(6.4, 0, -0.85), CREAM)
				B:block(tip, v(1.0, 1.1, 0.9) * sc, at(4.4, 0, 0.7), SKIN_D)
				B:block(tip, v(0.9, 1.0, 0.8) * sc, at(6.6, 0, 1.0), SKIN_D)
				B:block(tip, v(0.5, 0.5, 0.6) * sc, at(4.8, 0.2, -1.95), WHITE) -- claw
				local a, b = at(8.9, 0, 1.2), at(7.6, 0, 1.4)
				B:trail(tip, a.Position, b.Position, { name = prefix .. "Trail" .. side, color = { "#ffffff", TURQ }, life = 0.25, trans = { 0.55, 1 } })
			end)
		end
		flipper("Flip", v(4.4, 4.7, -3.0), -18, -8, 0.85, true)
		flipper("Rear", v(3.8, 4.1, 4.6), -42, -10, 0.55, false)

		-- stubby tail
		local tail1 = B:bone("Tail1", "Body", v(0, 4.3, 6.6))
		B:block(tail1, v(1.6, 1.2, 1.8), cf(0, 4.2, 7.3), SKIN)
		B:block(tail1, v(1.0, 0.3, 1.2), cf(0, 4.85, 7.3), SKIN_D)
		local tail2 = B:bone("Tail2", "Tail1", v(0, 4.1, 8.0))
		B:block(tail2, v(1.0, 0.8, 1.2), cf(0, 4.0, 8.5), SKIN_D)
		B:wedge(tail2, v(0.6, 0.6, 0.8), cf(0, 4.0, 9.4, 0, 180, 0), SKIN_D)

		------------------------------------------------------------------
		-- floating marble cubes with gold bands and crystal chips
		------------------------------------------------------------------
		local cubes = {
			{ 8.6, 10.6, -4.2, 1.4, true },
			{ -9.0, 9.4, 1.0, 1.2, false },
			{ 7.4, 13.4, 5.6, 1.0, false },
			{ -6.6, 13.6, -5.2, 1.1, true },
			{ -7.8, 6.2, 7.0, 1.0, false },
			{ 9.6, 6.4, 3.0, 0.9, true },
		}
		for i, c in cubes do
			local cb = B:bone("Cube" .. i, "Root", v(c[1], c[2], c[3]))
			local s = c[4]
			B:block(cb, v(s, s, s), cf(c[1], c[2], c[3]), i % 2 == 0 and MARBLE_S or MARBLE)
			B:block(cb, v(s + 0.1, s * 0.25, s + 0.1), cf(c[1], c[2] - s * 0.1, c[3]), GOLD)
			if c[5] then
				B:block(cb, v(0.35, 0.5, 0.35), cf(c[1], c[2] + s * 0.5 + 0.2, c[3], 0, 45, 0), TURQ, NEON)
			end
		end
	end,
}
