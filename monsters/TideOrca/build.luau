--!nocheck
-- Atlantean Tide Orca (Mythic): the mischievous royal prankster of sunken
-- Atlantis. Built in the SAME style as the Trident Swordfish / Temple Turtle /
-- Atlantean Pufferfish: a compact chunky stepped orca (crisp black top, white
-- belly band + stepped white belly plates, white flank sweep, grey saddle),
-- a big boxy cartoon head that is a little bigger than the body, and the
-- richness on the BODY: a bronze-and-gold royal gorget with a swinging
-- diamond medallion, rune-engraved gold flank plates, gold rune bands down the
-- tail, gold-and-marble pauldrons on the paddle flippers, a trident dorsal
-- (tall stepped black blade with a gold leading edge + crystal tip flanked by
-- two crystal tines) and crystal-tipped horizontal flukes.
-- On the head: an Atlantean war-crown = gold circlet + four little marble
-- columns under a gold lintel with crown points, guarding a turquoise
-- orichalcum crystal spire.
-- FACE (copied from the Swordfish recipe, kept simple): one white eye block on
-- each front corner with a glowing turquoise iris and ONE dark pupil (on its
-- own bone for sly glances), a heavy dark brow on its own bone, a hidden
-- eyelid for blinks / winks, the classic white orca patch running back from
-- the eye, rosy blush, and ONE small cheeky grin: buck teeth + two side
-- teeth, a smirk corner curling up on the right, a white chin with two little
-- teeth and a tongue that can poke out for raspberries.
-- Hidden VFX: blowhole squirt, wink star, crown beam + flash, three swirling
-- water rings, splash crown and an expanding wave ring.
return {
	DisplayName = "Atlantean Tide Orca",
	Rarity = "Mythic",
	Element = "Atlantis",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette ----------------------------------------------------------
		local BLACK, DARK, DEEP = "#33405f", "#222c48", "#0a0d18"
		local WHITE, WSHADE, GREY = "#f2f5fa", "#c9d3e3", "#9aa6bd"
		local GOLD, DGOLD, BRONZE, ENGRAVE = "#f2b632", "#d08a1e", "#b06a26", "#7a4310"
		local MARBLE, MSHADE, BARNACLE = "#f4efe2", "#d9cfb8", "#e3d6b8"
		local CRYSTAL, CRYSTAL_L = "#2ad1c4", "#5ff5e8"
		local PUPIL, MOUTH, TONGUE, TONGUED, PINK = "#0d1020", "#2a0d18", "#ff7f8f", "#e2606a", "#ff9db5"
		local LID, BROWRIM = "#4f6090", "#5b6c99"
		local WATER, FOAM = "#7fd8ff", "#e9fcff"
		local TURQ, GLOW = "#3ff0e0", "#ffe27a" -- the two (small) neon accents
		local NEON = { mat = "Neon" }
		local Y0 = 9.0

		------------------------------------------------------------------
		-- helpers (the Swordfish recipe)
		------------------------------------------------------------------
		-- countershaded body segment: black core, dark back band + top cap,
		-- white lower band + belly cap
		local function segment(bone, z0, z1, w, h, yc)
			local len, zc = z1 - z0, (z0 + z1) / 2
			B:block(bone, v(w, h, len), cf(0, yc, zc), BLACK)
			B:block(bone, v(w * 0.7, 0.6, len - 0.2), cf(0, yc + h / 2 + 0.25, zc), DARK)
			B:block(bone, v(w + 0.1, h * 0.3, len - 0.2), cf(0, yc + h * 0.36, zc), DARK)
			B:block(bone, v(w + 0.1, h * 0.3, len - 0.2), cf(0, yc - h * 0.36, zc), WHITE)
			B:block(bone, v(w * 0.78, 0.7, len - 0.4), cf(0, yc - h / 2 - 0.25, zc), WHITE)
		end
		-- rune-engraved orichalcum plate on the right flank (call in B:sym)
		local function plate(bone, x, y, z, h, d)
			B:block(bone, v(0.3, h, d), cf(x, y, z), BRONZE)
			B:block(bone, v(0.36, h - 0.6, d - 0.6), cf(x + 0.05, y, z), GOLD)
			B:block(bone, v(0.4, 0.25, d - 1.2), cf(x + 0.08, y + 0.35, z), ENGRAVE)
			B:block(bone, v(0.4, (h - 0.6) * 0.45, 0.25), cf(x + 0.08, y - 0.1, z - (d - 1.2) / 2 + 0.12), ENGRAVE)
			B:block(bone, v(0.42, 0.35, 0.35), cf(x + 0.1, y - 0.45, z + 0.3), TURQ, NEON)
		end
		-- gold rune band round a tail segment (neon rune dots on the flanks)
		local function band(bone, z, w, h)
			B:block(bone, v(w, h, 0.5), cf(0, Y0, z), GOLD)
			B:block(bone, v(w * 0.5, 0.2, 0.55), cf(0, Y0 + h / 2 + 0.02, z), DGOLD)
			B:sym(function()
				B:block(bone, v(0.12, 0.4, 0.3), cf(w / 2 + 0.03, Y0 + 0.2, z), TURQ, NEON)
			end)
		end

		------------------------------------------------------------------
		-- BODY1: chunky armoured chest (swim chain center)
		------------------------------------------------------------------
		local body1 = B:bone("Body1", "Root", v(0, Y0, -1.0))
		B:block(body1, v(6.6, 7.0, 6.4), cf(0, Y0, -0.6), BLACK)
		B:block(body1, v(4.6, 0.6, 6.2), cf(0, Y0 + 3.75, -0.6), DARK)
		B:block(body1, v(6.7, 2.0, 6.2), cf(0, Y0 + 2.4, -0.6), DARK)
		B:block(body1, v(6.7, 2.0, 6.2), cf(0, Y0 - 2.4, -0.6), WHITE)
		-- stepped white belly bulging down
		B:block(body1, v(6.0, 1.0, 6.0), cf(0, Y0 - 3.9, -0.8), WHITE)
		B:block(body1, v(4.4, 0.7, 4.4), cf(0, Y0 - 4.65, -1.0), WSHADE)
		B:block(body1, v(6.1, 0.2, 0.4), cf(0, Y0 - 4.0, 0.7), WSHADE)
		B:block(body1, v(6.1, 0.2, 0.4), cf(0, Y0 - 4.0, -2.1), WSHADE)
		-- royal gorget: bronze collar with gold rims, wider than head + body
		B:block(body1, v(7.6, 7.8, 0.8), cf(0, Y0, -3.55), BRONZE)
		B:block(body1, v(7.8, 0.5, 0.9), cf(0, Y0 + 3.85, -3.55), GOLD)
		B:block(body1, v(7.2, 0.5, 0.9), cf(0, Y0 - 3.85, -3.55), GOLD)
		B:block(body1, v(2.4, 0.4, 0.95), cf(0, Y0 + 4.2, -3.55), DGOLD)
		B:sym(function()
			B:block(body1, v(0.3, 1.0, 1.0), cf(3.85, Y0 + 0.4, -3.55, 45, 0, 0), GOLD) -- collar studs
			B:block(body1, v(0.34, 0.5, 0.5), cf(3.88, Y0 + 0.4, -3.55, 45, 0, 0), DGOLD)
			plate(body1, 3.3, Y0 + 0.1, -1.4, 3.2, 2.4)
			plate(body1, 3.3, Y0 - 0.1, 1.2, 2.8, 2.0)
		end)
		local bodyFx = B:block(body1, v(7, 7, 14), cf(0, Y0, 2.0), BLACK, { tr = 1, name = "BodyFX" })
		B:emitter(bodyFx, "bubble", { name = "AmbientBubbles", color = { "#ffffff", "#9fe2ff" }, rate = 4, size = { 0.2, 0.4, 0.5 } })
		B:emitter(bodyFx, "sparkle", { name = "AmbientSparkle", color = { "#ffffff", GLOW, TURQ }, rate = 3 })
		B:emitter(bodyFx, "burst", { name = "BubbleBurst", color = { "#ffffff", "#9fe2ff", WATER }, size = { 0.5, 0.8, 0.2 }, speed = { 5, 12 }, life = { 0.6, 1.2 } })

		-- swinging royal medallion under the throat
		local medal = B:bone("Medal", "Body1", v(0, Y0 - 3.6, -4.0))
		B:block(medal, v(0.4, 1.2, 0.4), cf(0, Y0 - 4.1, -4.05), DGOLD)
		B:block(medal, v(1.6, 1.6, 0.35), cf(0, Y0 - 5.1, -4.05, 0, 0, 45), GOLD)
		B:block(medal, v(1.0, 1.0, 0.4), cf(0, Y0 - 5.1, -4.06, 0, 0, 45), MARBLE)
		B:block(medal, v(0.45, 0.45, 0.2), cf(0, Y0 - 5.1, -4.28, 0, 0, 45), TURQ, NEON)

		------------------------------------------------------------------
		-- BODY2 + TAIL chain (orca white flank sweep, grey saddle, rune bands)
		------------------------------------------------------------------
		local body2 = B:bone("Body2", "Body1", v(0, Y0, 2.6))
		segment(body2, 2.4, 6.8, 6.0, 6.2, Y0)
		band(body2, 2.55, 6.3, 6.5)
		B:block(body2, v(4.2, 0.7, 2.8), cf(0, Y0 + 3.4, 4.6), GREY) -- saddle patch
		B:sym(function()
			-- white flank sweep rising toward the tail
			B:block(body2, v(0.3, 1.6, 2.6), cf(3.05, Y0 - 1.0, 5.4, -18, 0, 0), WHITE)
			B:block(body2, v(0.3, 1.2, 1.4), cf(3.05, Y0 - 0.3, 6.1, -18, 0, 0), WHITE)
			plate(body2, 2.95, Y0 + 0.6, 4.0, 2.2, 1.8)
		end)
		-- barnacles (worn ruin feel, one side only)
		B:block(body2, v(0.5, 0.6, 0.6), cf(3.05, Y0 - 2.2, 3.4), BARNACLE)
		B:block(body2, v(0.4, 0.4, 0.4), cf(3.1, Y0 - 1.8, 3.0), MARBLE)
		B:block(body2, v(0.4, 0.5, 0.5), cf(-3.05, Y0 + 1.9, 5.9), BARNACLE)

		local tail1 = B:bone("Tail1", "Body2", v(0, Y0, 6.6))
		segment(tail1, 6.4, 9.6, 5.2, 5.4, Y0)
		band(tail1, 6.65, 5.5, 5.7)
		B:sym(function()
			B:block(tail1, v(0.3, 1.2, 2.0), cf(2.65, Y0 - 0.4, 7.9, -18, 0, 0), WHITE)
		end)
		B:block(tail1, v(0.5, 0.9, 1.4), cf(0, Y0 + 2.75, 8.3), DARK) -- back ridge

		local tail2 = B:bone("Tail2", "Tail1", v(0, Y0, 9.4))
		segment(tail2, 9.2, 11.6, 4.2, 4.2, Y0)
		B:block(tail2, v(4.4, 4.4, 0.4), cf(0, Y0, 9.4), DARK)
		B:block(tail2, v(0.5, 0.8, 1.4), cf(0, Y0 + 2.6, 10.5), DARK)

		local tail3 = B:bone("Tail3", "Tail2", v(0, Y0, 11.4))
		B:block(tail3, v(3.0, 2.8, 1.8), cf(0, Y0, 12.2), BLACK)
		B:block(tail3, v(1.2, 3.6, 1.6), cf(0, Y0, 12.3), DARK) -- tall keel
		B:block(tail3, v(2.2, 0.3, 1.6), cf(0, Y0 - 1.35, 12.2), WHITE)
		B:block(tail3, v(3.2, 3.0, 0.4), cf(0, Y0, 11.45), GOLD)
		B:sym(function()
			B:block(tail3, v(0.12, 0.45, 0.3), cf(1.62, Y0 + 0.2, 11.45), TURQ, NEON)
		end)

		------------------------------------------------------------------
		-- FLUKES: horizontal stepped rows sweeping out + back, white under,
		-- gold leading edges, orichalcum crystal tips
		------------------------------------------------------------------
		local fluke = B:bone("Fluke", "Tail3", v(0, Y0, 12.9))
		B:block(fluke, v(2.6, 1.0, 1.8), cf(0, Y0, 13.6), BLACK)
		B:block(fluke, v(2.0, 0.9, 0.5), cf(0, Y0, 12.95), GOLD)
		B:block(fluke, v(1.0, 0.9, 0.8), cf(0, Y0, 14.7), DARK) -- center notch lobe
		local rows = {
			{ 1.8, 12.9, 15.0, 1.3 }, { 3.0, 13.4, 15.7, 1.2 },
			{ 4.1, 14.0, 16.3, 1.1 }, { 5.1, 14.6, 16.8, 1.0 }, { 6.0, 15.3, 17.1, 0.9 },
		}
		-- each fluke half rises in a slight V (dihedral) so its top surface
		-- shows from the 3/4 and side views instead of reading edge-on
		local DIH = 25
		for _, dir in { 1, -1 } do
			local F = CFrame.new(0, Y0, 0) * ang(0, 0, DIH * dir)
			local function fat(x, y, z)
				return F * CFrame.new(x, y, z)
			end
			for _, r in rows do
				local x, len = r[1] * dir, r[3] - r[2]
				local zc = (r[2] + r[3]) / 2
				B:block(fluke, v(r[4], 1.1, len), fat(x, 0, zc), BLACK)
				B:block(fluke, v(r[4] - 0.1, 0.25, len - 0.3), fat(x, -0.62, zc + 0.1), WHITE)
				B:block(fluke, v(r[4] + 0.1, 1.15, 0.5), fat(x, 0, r[2] + 0.2), GOLD)
			end
			B:block(fluke, v(0.9, 0.8, 1.0), fat(6.7 * dir, 0, 16.9), CRYSTAL)
			B:block(fluke, v(0.55, 0.55, 0.6), fat(7.2 * dir, 0, 17.2), TURQ, NEON)
			B:trail(fluke, fat(7.1 * dir, 0, 17.2).Position, fat(5.4 * dir, 0, 16.8).Position, { name = dir > 0 and "FlukeTrailR" or "FlukeTrailL", color = { "#ffffff", TURQ }, life = 0.3, trans = { 0.45, 1 } })
		end
		local wake = B:block(fluke, v(3, 1.5, 2), cf(0, Y0, 15.0), BLACK, { tr = 1, name = "WakeFX" })
		B:emitter(wake, "burst", { name = "WakeBurst", color = { "#ffffff", WATER, TURQ }, size = { 0.8, 0.6, 0 }, speed = { 5, 12 } })

		------------------------------------------------------------------
		-- TRIDENT DORSAL: three stepped bones (black blade, gold leading edge,
		-- crystal tip) on a gold crossguard with two crystal tines
		------------------------------------------------------------------
		local d1 = B:bone("Dorsal1", "Body1", v(0, Y0 + 3.9, 0.4))
		B:block(d1, v(1.0, 2.4, 3.6), cf(0, Y0 + 5.0, 0.8), BLACK)
		B:block(d1, v(1.1, 2.4, 0.5), cf(0, Y0 + 5.0, -0.95), GOLD)
		B:block(d1, v(3.6, 0.6, 1.2), cf(0, Y0 + 4.1, -0.3), GOLD) -- crossguard
		B:block(d1, v(1.2, 0.7, 1.3), cf(0, Y0 + 4.15, -0.3), DGOLD)
		B:sym(function()
			B:block(d1, v(0.7, 0.6, 0.9), cf(1.55, Y0 + 4.55, -0.3), DGOLD)
			B:block(d1, v(0.6, 1.6, 0.6), cf(1.75, Y0 + 5.5, -0.3, 0, 0, -14), CRYSTAL)
			B:block(d1, v(0.4, 0.6, 0.4), cf(1.98, Y0 + 6.5, -0.3, 0, 0, -14), TURQ, NEON)
		end)
		local d2 = B:bone("Dorsal2", "Dorsal1", v(0, Y0 + 6.0, 1.0))
		B:block(d2, v(0.9, 2.2, 2.6), cf(0, Y0 + 7.1, 1.5), BLACK)
		B:block(d2, v(1.0, 2.2, 0.5), cf(0, Y0 + 7.1, 0.25), GOLD)
		B:block(d2, v(0.95, 0.6, 0.6), cf(0, Y0 + 6.8, 2.2), GREY)
		local d3 = B:bone("Dorsal3", "Dorsal2", v(0, Y0 + 8.1, 1.8))
		B:block(d3, v(0.8, 1.6, 1.6), cf(0, Y0 + 8.9, 2.2), BLACK)
		B:block(d3, v(0.9, 1.6, 0.45), cf(0, Y0 + 8.9, 1.45), GOLD)
		B:block(d3, v(0.7, 0.9, 0.8), cf(0, Y0 + 10.1, 2.2), CRYSTAL)
		B:block(d3, v(0.45, 0.7, 0.5), cf(0, Y0 + 10.85, 2.2), TURQ, NEON)
		B:trail(d3, v(0, Y0 + 11.0, 2.2), v(0, Y0 + 9.6, 2.6), { name = "DorsalTrail", color = { "#ffffff", TURQ }, life = 0.3, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- HEAD: big boxy cartoon head (Swordfish recipe)
		------------------------------------------------------------------
		local head = B:bone("Head", "Body1", v(0, Y0, -3.6))
		B:block(head, v(6.6, 6.6, 1.4), cf(0, Y0, -3.8), BLACK) -- neck collar
		B:block(head, v(7.0, 6.6, 4.4), cf(0, Y0 + 0.3, -5.8), BLACK) -- cranium
		B:block(head, v(5.4, 0.6, 4.0), cf(0, Y0 + 3.85, -5.6), DARK)
		B:block(head, v(7.1, 1.4, 2.0), cf(0, Y0 + 2.6, -4.6), DARK) -- dark back band
		B:block(head, v(7.1, 1.6, 4.2), cf(0, Y0 - 2.4, -5.8), WHITE) -- white cheeks
		B:block(head, v(3.4, 3.4, 1.6), cf(0, Y0 + 0.4, -8.6), BLACK) -- melon / snout
		B:block(head, v(2.6, 0.4, 1.5), cf(0, Y0 + 2.25, -8.6), DARK)
		B:block(head, v(4.4, 0.9, 1.6), cf(0, Y0 - 1.45, -8.6), BLACK) -- upper lip
		-- ONE small cheeky grin: dark slot + two buck teeth
		B:block(head, v(4.6, 0.75, 0.4), cf(0, Y0 - 2.25, -9.2), MOUTH)
		B:block(head, v(4.0, 0.3, 3.4), cf(0, Y0 - 2.45, -7.4), MOUTH) -- palate
		B:block(head, v(0.62, 0.62, 0.3), cf(0.36, Y0 - 2.12, -9.45), WHITE)
		B:block(head, v(0.62, 0.62, 0.3), cf(-0.36, Y0 - 2.12, -9.45), WHITE)
		-- smirk: right corner curls UP, left corner stays flat
		B:block(head, v(1.3, 0.7, 0.3), cf(2.5, Y0 - 1.95, -8.95, 0, 0, 26), MOUTH)
		B:block(head, v(0.4, 0.38, 0.2), cf(2.3, Y0 - 2.0, -9.1, 0, 0, 26), WHITE)
		B:block(head, v(1.0, 0.6, 0.3), cf(-2.45, Y0 - 2.3, -8.95, 0, 0, 4), MOUTH)
		-- gold forehead circlet (the crown sits on it)
		B:block(head, v(5.2, 0.6, 0.8), cf(0, Y0 + 3.4, -7.65), GOLD)
		B:block(head, v(1.2, 0.8, 0.85), cf(0, Y0 + 3.5, -7.7), DGOLD)
		-- blowhole behind the crown
		B:block(head, v(1.2, 0.2, 0.7), cf(0, Y0 + 4.2, -3.9), DEEP)
		B:sym(function(side)
			-- BIG eye on the front corner: white block, glowing turquoise iris,
			-- ONE pupil on the front face only (own bone for sly glances)
			B:block(head, v(1.9, 2.8, 1.9), cf(2.45, Y0 + 0.8, -7.35), WHITE)
			B:block(head, v(1.25, 1.65, 1.3), cf(2.45, Y0 + 0.45, -7.72), TURQ, { mat = "Neon", name = "Eye" .. side })
			local pup = B:bone("Pupil" .. side, "Head", v(2.35, Y0 + 0.35, -8.4))
			B:block(pup, v(0.62, 1.12, 0.1), cf(2.35, Y0 + 0.3, -8.42), PUPIL)
			B:block(pup, v(0.3, 0.3, 0.1), cf(2.6, Y0 + 0.75, -8.45), WHITE, NEON)
			-- classic white orca patch sweeping back + up from the eye
			B:block(head, v(0.3, 1.6, 2.6), cf(3.5, Y0 + 1.0, -5.5, -14, 0, 0), WHITE)
			B:block(head, v(0.3, 1.1, 1.2), cf(3.5, Y0 + 1.75, -4.4, -14, 0, 0), WHITE)
			-- rosy blush under the eye
			B:block(head, v(0.9, 0.4, 0.12), cf(2.55, Y0 - 1.0, -8.03), PINK)
			-- gold cheek guard (no glowing dot: it would read as a 2nd eye)
			B:block(head, v(0.26, 2.2, 2.2), cf(3.55, Y0 - 1.0, -5.0), BRONZE)
			B:block(head, v(0.3, 1.6, 1.6), cf(3.6, Y0 - 1.0, -5.0), GOLD)
			B:block(head, v(0.34, 0.25, 0.9), cf(3.65, Y0 - 0.8, -5.0), ENGRAVE)
			-- orca mouth line running back along the cheek
			B:block(head, v(0.2, 0.55, 2.4), cf(3.55, Y0 - 2.25, -6.9), MOUTH)
			-- heavy brow on its own bone (sits on the eye, cuts its top)
			local brow = B:bone("Brow" .. side, "Head", v(2.35, Y0 + 1.75, -7.6))
			B:block(brow, v(2.8, 1.0, 1.85), cf(2.35, Y0 + 1.75, -7.75, 0, 0, 12), DEEP)
			B:block(brow, v(2.6, 0.3, 1.6), cf(2.33, Y0 + 2.33, -7.7, 0, 0, 12), BROWRIM)
			-- eyelid for blinks / winks / squints (hidden until it closes)
			local lid = B:bone("Lid" .. side, "Head", v(2.45, Y0 + 2.3, -7.35))
			B:block(lid, v(2.05, 2.5, 2.3), cf(2.45, Y0 + 2.3, -7.4), LID, { tr = 1, name = "Eyelid" .. side })
			B:block(lid, v(2.15, 0.36, 0.12), cf(2.45, Y0 + 1.22, -8.58), DEEP, { tr = 1, name = "Lash" .. side })
		end)
		local headFx = B:block(head, v(1.5, 1.0, 1.0), cf(0, Y0 - 2.2, -10.0), WHITE, { tr = 1, name = "MouthFX" })
		B:emitter(headFx, "burst", { name = "Spray", color = { "#ffffff", WATER, FOAM }, size = { 0.4, 0.3, 0 }, speed = { 5, 10 }, life = { 0.3, 0.7 }, spread = 40 })

		------------------------------------------------------------------
		-- JAW (white chin, two little teeth) + raspberry TONGUE
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", v(0, Y0 - 2.2, -4.2))
		B:block(jaw, v(5.0, 1.4, 4.8), cf(0, Y0 - 3.1, -6.9), WHITE)
		B:block(jaw, v(3.8, 0.4, 3.8), cf(0, Y0 - 3.95, -6.7), WSHADE)
		B:block(jaw, v(4.4, 0.25, 4.2), cf(0, Y0 - 2.35, -6.9), MOUTH)
		local tongue = B:bone("Tongue", "Jaw", v(0, Y0 - 2.2, -6.0))
		B:block(tongue, v(2.0, 0.4, 3.2), cf(0, Y0 - 2.15, -7.4), TONGUE)
		B:block(tongue, v(0.2, 0.42, 2.4), cf(0, Y0 - 2.13, -7.6), TONGUED)

		------------------------------------------------------------------
		-- WAR-CROWN: gold circlet, 4 marble columns, gold lintel + points,
		-- orichalcum crystal spire (own bone: tips like a hat)
		------------------------------------------------------------------
		local CZ, CY = -5.8, Y0 + 4.15
		local crown = B:bone("Crown", "Head", v(0, CY, CZ))
		B:block(crown, v(5.0, 0.7, 3.9), cf(0, CY + 0.3, CZ), GOLD)
		B:block(crown, v(4.4, 0.4, 3.4), cf(0, CY + 0.85, CZ), MARBLE)
		B:block(crown, v(1.6, 0.45, 0.14), cf(0, CY + 0.3, CZ - 1.98), ENGRAVE) -- rune tile
		B:block(crown, v(0.4, 0.3, 0.1), cf(0, CY + 0.3, CZ - 2.06), TURQ, NEON)
		for _, xz in { { 1.75, -1.3 }, { -1.75, -1.3 }, { 1.75, 1.3 }, { -1.75, 1.3 } } do
			local x, z = xz[1], CZ + xz[2]
			B:block(crown, v(0.95, 0.3, 0.95), cf(x, CY + 1.2, z), MSHADE)
			B:block(crown, v(0.7, 1.9, 0.7), cf(x, CY + 2.2, z), MARBLE)
			B:block(crown, v(0.74, 1.6, 0.12), cf(x, CY + 2.2, z - 0.3), MSHADE) -- fluting
			B:block(crown, v(1.05, 0.35, 1.05), cf(x, CY + 3.3, z), GOLD)
			B:spike(crown, v(x, CY + 3.9, z), v(x, CY + 5.0, z), 0.55, 0.55, GOLD)
		end
		-- lintel frame
		for _, z in { -1.3, 1.3 } do
			B:block(crown, v(4.6, 0.5, 0.65), cf(0, CY + 3.7, CZ + z), GOLD)
		end
		B:sym(function()
			B:block(crown, v(0.65, 0.5, 2.0), cf(1.75, CY + 3.7, CZ), GOLD)
		end)
		-- front pediment with a gem
		B:block(crown, v(2.4, 0.6, 0.4), cf(0, CY + 4.2, CZ - 1.35), GOLD)
		B:block(crown, v(1.3, 0.5, 0.4), cf(0, CY + 4.7, CZ - 1.35), DGOLD)
		B:block(crown, v(0.45, 0.45, 0.15), cf(0, CY + 4.2, CZ - 1.6, 0, 0, 45), TURQ, NEON)
		-- crystal spire
		B:block(crown, v(1.3, 0.5, 1.3), cf(0, CY + 1.3, CZ), DGOLD)
		B:block(crown, v(1.1, 1.8, 1.1), cf(0, CY + 2.4, CZ, 0, 45, 0), CRYSTAL)
		B:block(crown, v(0.8, 1.6, 0.8), cf(0, CY + 4.0, CZ, 0, 45, 0), CRYSTAL)
		B:block(crown, v(0.55, 1.2, 0.55), cf(0, CY + 5.3, CZ, 0, 45, 0), CRYSTAL_L)
		local tip = B:block(crown, v(0.4, 0.8, 0.4), cf(0, CY + 6.2, CZ, 0, 45, 0), TURQ, { mat = "Neon", name = "Spire" })
		B:emitter(tip, "burst", { name = "CrownFlash", color = { "#ffffff", GLOW, TURQ }, speed = { 7, 15 }, size = { 0.9, 0.6, 0 }, life = { 0.4, 0.9 } })
		B:light(tip, { name = "CrownLight", color = TURQ, brightness = 0.4, range = 12 })
		B:trail(crown, v(0, CY + 6.5, CZ), v(0, CY + 5.0, CZ), { name = "CrownTrail", color = { "#ffffff", GLOW, TURQ }, life = 0.35, trans = { 0.4, 1 } })
		-- crown beam + flash star (hidden)
		B:block(crown, v(0.7, 8.0, 0.7), cf(0, CY + 10.8, CZ), TURQ, { mat = "Neon", tr = 1, name = "CrownBeam" })
		B:block(crown, v(0.4, 3.4, 0.4), cf(0, CY + 6.3, CZ), "#ffffff", { mat = "Neon", tr = 1, name = "CrownStarA" })
		B:block(crown, v(3.4, 0.4, 0.4), cf(0, CY + 6.3, CZ), "#ffffff", { mat = "Neon", tr = 1, name = "CrownStarB" })

		------------------------------------------------------------------
		-- BLOWHOLE SQUIRT (hidden): a water jet that arcs at the viewer
		------------------------------------------------------------------
		local squirt = B:bone("Squirt", "Head", v(0, Y0 + 4.3, -3.9))
		for k = 1, 6 do
			local s = 1.6 - 0.1 * k
			B:block(squirt, v(s, 1.35, s), cf(0, Y0 + 4.4 + k * 1.25, -3.9), k % 2 == 0 and FOAM or "#3fb4ff", { tr = 1, name = "Jet" .. k })
		end
		local jetTop = B:block(squirt, v(1, 1, 1), cf(0, Y0 + 12.6, -3.9), WATER, { tr = 1, name = "JetFX" })
		B:emitter(jetTop, "burst", { name = "SquirtSpray", color = { "#ffffff", WATER, FOAM }, size = { 0.6, 0.45, 0 }, speed = { 6, 12 }, life = { 0.5, 1.0 }, accel = { 0, -20, 0 }, spread = 50 })

		-- wink star (hidden) by the left eye
		local star = B:bone("WinkStar", "Head", v(-4.0, Y0 + 2.6, -8.2))
		B:block(star, v(0.3, 1.8, 0.3), cf(-4.0, Y0 + 2.6, -8.2), GLOW, { mat = "Neon", tr = 1, name = "WinkA" })
		B:block(star, v(1.8, 0.3, 0.3), cf(-4.0, Y0 + 2.6, -8.2), GLOW, { mat = "Neon", tr = 1, name = "WinkB" })

		------------------------------------------------------------------
		-- PADDLE FLIPPERS with gold + marble pauldrons
		------------------------------------------------------------------
		B:sym(function(side)
			local F = CFrame.new(3.1, Y0 - 2.4, -1.8) * ang(0, -38, -18)
			local function at(x, y, z)
				return F * CFrame.new(x, y, z)
			end
			local pec = B:bone("Pec" .. side, "Body1", F.Position)
			B:block(pec, v(2.6, 1.0, 2.4), at(1.1, 0, 0.1), BLACK)
			B:block(pec, v(2.2, 1.0, 2.6), at(0.6, 0.6, 0.0), GOLD) -- pauldron
			B:block(pec, v(1.7, 0.35, 2.1), at(0.6, 1.25, 0.0), MARBLE)
			B:block(pec, v(0.5, 0.14, 0.5), at(0.6, 1.47, 0.0), TURQ, NEON)
			local tipb = B:bone("PecTip" .. side, "Pec" .. side, at(2.2, 0, 0).Position)
			B:block(tipb, v(2.4, 0.85, 2.8), at(3.2, 0, 0.25), BLACK)
			B:block(tipb, v(2.0, 0.75, 2.5), at(5.0, 0, 0.6), BLACK)
			B:block(tipb, v(1.3, 0.65, 1.7), at(6.5, 0, 0.95), DARK)
			B:block(tipb, v(0.45, 0.9, 2.9), at(4.2, 0, 0.35), GOLD) -- rune band
			B:block(tipb, v(0.5, 0.92, 0.4), at(4.2, 0, -0.9), TURQ, NEON)
			B:block(tipb, v(2.0, 0.2, 2.2), at(4.6, -0.45, 0.5), WSHADE) -- pale underside
			local a, b = at(7.1, 0, 1.0), at(6.0, 0, 1.6)
			B:trail(tipb, a.Position, b.Position, { name = "PecTrail" .. side, color = { "#ffffff", TURQ }, life = 0.25, trans = { 0.55, 1 } })
		end)

		------------------------------------------------------------------
		-- Floating voxel cubes: marble/gold, black/white orca cubes, a broken
		-- column, a crystal - each with a thin turquoise band
		------------------------------------------------------------------
		local orbs = {
			{ 9.0, 14.5, -6.0, 1.6, BLACK, WHITE }, { -9.5, 12.0, -1.5, 1.4, GOLD, MARBLE },
			{ 8.5, 6.5, 6.0, 1.1, "column" }, { -8.5, 15.5, 7.0, 1.6, MARBLE, GOLD },
			{ 4.5, 20.0, 3.0, 1.0, "column" }, { -7.5, 6.0, -9.0, 1.2, BLACK, GOLD },
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

		------------------------------------------------------------------
		-- SWIRLING WATER RINGS (hidden): three horizontal rings the orca
		-- spins up through on the breach
		------------------------------------------------------------------
		local RINGS = { { 12.0, 7.0 }, { 17.0, 6.4 }, { 22.0, 5.8 } }
		for r, rg in RINGS do
			local y, rad = rg[1], rg[2]
			local rb = B:bone("Ring" .. r, "Root", v(0, y, -1.0))
			for i = 0, 9 do
				local a = math.rad(i * 36)
				local col = (i % 5 == 0) and TURQ or (i % 2 == 0 and WATER or FOAM)
				B:block(rb, v(3.4, 0.9, 1.1), CFrame.new(0, y, -1.0) * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -rad), col,
					{ mat = col == TURQ and "Neon" or nil, tr = 1, name = "R" .. r .. "_" .. i })
			end
		end

		------------------------------------------------------------------
		-- SPLASH CROWN + WAVE RING (hidden, on the ground under the belly)
		------------------------------------------------------------------
		for k = 1, 8 do
			local a = math.rad((k - 1) * 45 + 22.5)
			local dx, dz = math.sin(a), math.cos(a)
			local p = v(dx * 4.5, 0, -1 + dz * 4.5)
			local sb = B:bone("Splash" .. k, "Root", p)
			local h = (k % 2 == 0) and 3.2 or 4.2
			B:block(sb, v(1.2, h, 1.2), CFrame.new(p + v(0, h / 2, 0)) * CFrame.Angles(0, a, 0), WATER, { tr = 1, name = "SplashA" .. k })
			B:block(sb, v(0.9, 0.8, 0.9), CFrame.new(p + v(dx * 0.3, h + 0.35, dz * 0.3)) * CFrame.Angles(0, a, 0), FOAM, { tr = 1, name = "SplashB" .. k })
			local q = v(dx * 6.0, 0, -1 + dz * 6.0)
			local wb = B:bone("Wave" .. k, "Root", q)
			B:block(wb, v(3.4, 0.6, 1.0), CFrame.new(q + v(0, 0.3, 0)) * CFrame.Angles(0, a, 0), WATER, { tr = 1, name = "WaveA" .. k })
			B:block(wb, v(3.0, 0.4, 0.6), CFrame.new(q + v(0, 0.75, 0)) * CFrame.Angles(0, a, 0), FOAM, { tr = 1, name = "WaveB" .. k })
		end
		local ground = B:block("Root", v(8, 1, 8), cf(0, 0.6, -1.0), WATER, { tr = 1, name = "SplashFX" })
		B:emitter(ground, "burst", { name = "SplashBurst", color = { "#ffffff", WATER, FOAM, TURQ }, size = { 1.0, 0.7, 0 }, speed = { 10, 20 }, life = { 0.6, 1.2 }, accel = { 0, -25, 0 }, spread = 40 })
	end,
}
