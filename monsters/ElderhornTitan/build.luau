--!nocheck
-- Elderhorn Titan (Guardian #10, the final boss): a colossal ancient forest
-- stag that guards the World Tree's sacred grove. Stud-built in the Void
-- Leviathan style, scaled up to boss size (~40 studs tall, a player is 5).
-- Deep forest-green body under charcoal bark and obsidian/stone armour plates,
-- a shaggy stepped moss mane + beard, enormous 3-tier branching bone antlers
-- (one bone per tier so they can flare) hung with moss strands, lanterns and
-- pink crystal blossoms, emerald rune lines + a rune core gem on the chest
-- armour, a stern pale stone skull-mask face with a heavy obsidian brow, ONE
-- pair of narrow emerald eyes and ONE jaw with a few blunt teeth. Huge
-- armoured legs end in stone hooves with shaggy moss fetlocks.
-- Neon only on eyes, rune lines, the core gem, antler tips, lanterns and
-- blossom hearts. Big VFX (glowing thorns, rune pulse, quake rocks) are hidden
-- props the motion reveals on the beats.
return {
	DisplayName = "Elderhorn Titan",
	Rarity = "Apex",
	Element = "Ancient",
	Build = function(B, P)
		local v, cf = P.v, P.cf

		-- palette
		local FOREST, FOREST_D = "#2f7a47", "#1c4a2e"
		local MOSS, MOSS_L, MOSS_D = "#4c8f2c", "#86c447", "#33661f"
		local BARK, BARK_D = "#3b302a", "#26201c"
		local OBSID, OBSID_L = "#25272f", "#3a3e4a"
		local STONE, STONE_D = "#6b7178", "#4a4f55"
		local MASK, MASK_D = "#bdb9a8", "#8f8b7c"
		local BONE, BONE_D = "#dccfa9", "#a8987a"
		local PINK, PINK_L = "#ff7fc4", "#ffc4e6"
		local EMER = "#3dffa0"
		local MOUTH, TEETH, PUPIL, TONGUE = "#110c0a", "#e8e2cc", "#03140b", "#6e2b33"

		local function box(bone, sx, sy, sz, x, y, z, col, opts)
			return B:block(bone, v(sx, sy, sz), cf(x, y, z), col, opts)
		end
		local function neon(bone, sx, sy, sz, x, y, z, name)
			return B:block(bone, v(sx, sy, sz), cf(x, y, z), EMER, { mat = "Neon", name = name })
		end
		-- pink crystal blossom: two crossed petal blocks + an emerald neon heart
		local function blossom(bone, x, y, z, s)
			box(bone, s, s * 0.55, s, x, y, z, PINK)
			B:block(bone, v(s * 0.78, s * 0.5, s * 0.78), cf(x, y + 0.1, z, 0, 45, 0), PINK_L)
			neon(bone, s * 0.36, s * 0.36, s * 0.36, x, y + s * 0.32, z)
		end
		-- moss tuft: stepped dark -> mid -> light block stack
		local function tuft(bone, sx, sz, x, y, z)
			box(bone, sx, 0.9, sz, x, y, z, MOSS_D)
			box(bone, sx * 0.75, 0.8, sz * 0.75, x, y + 0.75, z, MOSS)
			box(bone, sx * 0.45, 0.6, sz * 0.45, x, y + 1.4, z, MOSS_L)
		end
		-- hanging moss strand (stepped, light leaf tip)
		local function strand(bone, x, y, z, len)
			box(bone, 0.8, len, 0.8, x, y - len / 2, z, MOSS_D)
			box(bone, 0.55, len * 0.5, 0.55, x, y - len * 1.2, z, MOSS)
			box(bone, 0.9, 0.55, 0.9, x, y - len * 1.45, z, MOSS_L)
		end

		-- elk rune (algiz) glyph on a side plate facing +X: stem + 2 raised arms
		local function algiz(bone, x, y, z, s)
			neon(bone, 0.25, 2.8 * s, 0.35, x, y, z)
			B:block(bone, v(0.25, 1.6 * s, 0.35), cf(x, y + 0.75 * s, z - 0.55 * s, -40, 0, 0), EMER, { mat = "Neon" })
			B:block(bone, v(0.25, 1.6 * s, 0.35), cf(x, y + 0.75 * s, z + 0.55 * s, 40, 0, 0), EMER, { mat = "Neon" })
		end

		------------------------------------------------------------------
		-- BODY (rump; pivots at the hind hips so it can REAR UP)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 15, 9))
		box(body, 12, 9, 10, 0, 18.5, 9, FOREST) -- y14..23 z4..14
		box(body, 10, 1, 8.4, 0, 13.7, 8.6, FOREST_D) -- belly
		box(body, 9, 5.6, 0.8, 0, 19.0, 14.3, FOREST_D) -- rump back
		-- mossy back with an obsidian spine ridge + bone spines
		box(body, 10.8, 1.0, 9.0, 0, 23.4, 8.8, MOSS_D)
		box(body, 8.0, 0.8, 7.0, 0, 24.2, 8.6, MOSS)
		box(body, 2.6, 1.0, 8.4, 0, 24.6, 8.8, OBSID)
		for i, z in { 5.6, 8.8, 12.0 } do
			B:spike(body, v(0, 24.9, z), v(0, 27.6 - i * 0.5, z + 1.6), 1.4, 1.4, BONE)
		end
		B:sym(function()
			box(body, 0.6, 3.6, 8.6, 6.05, 15.9, 9.0, FOREST_D) -- lower flank shade
			-- haunch armour plate (stepped) with a rune glyph
			box(body, 1, 5.6, 6.4, 6.5, 18.8, 9.0, OBSID)
			box(body, 1, 1.0, 4.0, 6.5, 15.5, 9.0, OBSID) -- shield point
			box(body, 1.2, 1, 7.0, 6.6, 22.0, 9.0, STONE)
			box(body, 0.4, 4.2, 4.6, 7.15, 18.8, 9.0, OBSID_L)
			algiz(body, 7.4, 18.6, 9.0, 1.1)
			tuft(body, 2.8, 3.6, 4.0, 23.6, 12.0)
		end)

		-- short stag tail with a moss tuft
		local tail = B:bone("Tail", "Body", v(0, 21.5, 14))
		box(tail, 3.4, 3.4, 2.4, 0, 20.4, 15.0, BARK)
		box(tail, 4.0, 1.8, 3.0, 0, 22.0, 15.2, MOSS_D)
		box(tail, 3.0, 0.8, 2.2, 0, 23.1, 15.3, MOSS_L)
		box(tail, 2.4, 2.0, 1.8, 0, 18.1, 15.6, MOSS)
		box(tail, 1.4, 1.0, 1.2, 0, 16.7, 15.8, MOSS_L)

		------------------------------------------------------------------
		-- CHEST (barrel, shoulders, withers hump, rune breastplate)
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Body", v(0, 16, 0))
		box(chest, 13, 10, 8.6, 0, 18.5, 0, FOREST) -- barrel y13.5..23.5
		box(chest, 15, 13, 10, 0, 19.5, -8.5, FOREST) -- shoulders y13..26 z-13.5..-3.5
		box(chest, 13, 2.4, 10.4, 0, 27.0, -7.4, FOREST) -- withers hump y25.8..28.2
		box(chest, 11, 1, 17, 0, 12.6, -4.2, FOREST_D) -- belly
		box(chest, 11.6, 1.0, 7.4, 0, 24.0, 0.8, MOSS_D) -- mossy back
		box(chest, 8.4, 0.8, 5.4, 0, 24.8, 0.8, MOSS)
		B:sym(function()
			box(chest, 0.6, 4, 15, 7.3, 15.6, -4.6, FOREST_D) -- lower flank shade
			for i = 0, 2 do -- stepped obsidian rib plates
				box(chest, 0.8, 1.6, 4.6 - i * 0.6, 7.65, 21.4 - i * 2.2, -0.6 + i * 0.4, i == 1 and OBSID_L or OBSID)
			end
		end)
		-- bone spines down the back + flowering vines wrapped round the flanks
		for i, z in { -1.6, 2.2 } do
			B:spike(chest, v(0, 25.2, z), v(0, 28.0 - i * 0.4, z + 1.8), 1.5, 1.5, BONE)
		end
		B:sym(function()
			B:beam(chest, v(7.75, 24.2, -5.0), v(7.75, 14.6, 3.0), 0.7, 0.7, MOSS_D)
			for k, p in { { 22.3, -3.4 }, { 19.4, -1.0 }, { 16.6, 1.3 } } do
				box(chest, 0.5, 0.5, 1.6, 7.95, p[1] + 0.5, p[2] + (k % 2 == 0 and 0.7 or -0.7), MOSS_L)
			end
			box(chest, 0.6, 1.1, 1.1, 8.1, 20.9, -2.2, PINK)
			box(chest, 0.3, 0.45, 0.45, 8.45, 20.9, -2.2, EMER, { mat = "Neon" })
		end)
		-- breastplate: obsidian slab, stone inner plate, tree-of-life rune, core gem
		box(chest, 11.6, 10.6, 1, 0, 19.2, -14, OBSID) -- z -14.5..-13.5
		box(chest, 8.2, 7.8, 0.6, 0, 19.2, -14.75, STONE_D)
		box(chest, 13.6, 1.2, 1.8, 0, 25.0, -13.8, STONE) -- collar trim
		box(chest, 9.4, 0.8, 1.2, 0, 13.7, -14.1, STONE)
		B:block(chest, v(3.8, 3.8, 0.6), cf(0, 18.9, -15.2, 0, 0, 45), OBSID_L)
		local core = B:block(chest, v(2.0, 2.0, 0.5), cf(0, 18.9, -15.5, 0, 0, 45), EMER, { mat = "Neon", name = "RuneCore" })
		B:light(core, { name = "CoreLight", color = EMER, brightness = 0.6, range = 14 })
		B:emitter(core, "burst", { name = "RuneBurst", color = { "#ffffff", EMER, PINK }, speed = { 10, 22 }, size = { 1.4, 0.9, 0 }, life = { 0.5, 1.1 } })
		neon(chest, 0.35, 1.6, 0.2, 0, 16.1, -15.1) -- trunk
		neon(chest, 4.2, 0.35, 0.2, 0, 15.2, -15.1) -- roots
		B:sym(function()
			neon(chest, 0.35, 0.9, 0.2, 1.95, 14.7, -15.1)
			B:block(chest, v(2.8, 0.35, 0.2), cf(2.1, 20.4, -15.1, 0, 0, 35), EMER, { mat = "Neon" })
			neon(chest, 0.35, 1.8, 0.2, 3.25, 22.0, -15.1)
		end)
		-- hidden rune glow overlay (pulses on the show-off / roars)
		box(chest, 7.8, 7.4, 0.2, 0, 19.2, -15.15, EMER, { mat = "Neon", tr = 1, name = "RuneGlow" })
		-- armoured pauldrons with bone thorns + rune cross
		B:sym(function()
			box(chest, 2.4, 6, 8.4, 8.0, 22.2, -8.5, OBSID)
			box(chest, 2.8, 1.2, 8.8, 8.2, 25.7, -8.5, STONE)
			box(chest, 2.6, 0.8, 8.0, 8.1, 18.9, -8.5, STONE_D)
			box(chest, 0.4, 3.6, 5.6, 9.3, 22.2, -8.5, OBSID_L)
			algiz(chest, 9.55, 21.9, -8.5, 1.0)
			B:spike(chest, v(8.7, 26.1, -6.4), v(11.4, 29.8, -4.4), 1.5, 1.5, BONE)
			B:spike(chest, v(8.7, 26.1, -10.4), v(10.9, 28.8, -12.0), 1.2, 1.2, BONE)
		end)
		local aura = box(chest, 14, 10, 20, 0, 22, -3, FOREST, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "Sparkles", color = { "#ffffff", EMER, PINK_L }, rate = 5 })

		-- shaggy moss mane over the withers hump
		local m1 = B:bone("Mane1", "Chest", v(0, 28, -8))
		box(m1, 13.6, 1.6, 11.2, 0, 28.9, -7.6, MOSS_D)
		box(m1, 10.8, 1.2, 9.2, 0, 30.1, -8.0, MOSS)
		box(m1, 6.8, 1.0, 6.6, 0, 31.1, -8.4, MOSS_L)
		B:sym(function()
			box(m1, 1.2, 3.6, 9.4, 7.0, 27.4, -7.8, MOSS_D)
			for k, z in { -11.6, -8.8, -6.0, -3.4 } do
				local len = (k % 2 == 0) and 2.0 or 2.8
				box(m1, 1.0, len, 1.6, 7.3, 26.6 - len / 2, z, MOSS)
				box(m1, 0.8, 0.6, 1.0, 7.3, 26.3 - len, z, MOSS_L)
			end
			blossom(m1, 3.8, 31.1, -5.6, 1.6)
		end)
		blossom(m1, 0, 31.9, -10.4, 1.4)

		------------------------------------------------------------------
		-- NECK (2 bones) with a moss crest and a shaggy moss beard
		------------------------------------------------------------------
		local n1 = B:bone("Neck1", "Chest", v(0, 23, -12))
		box(n1, 9.4, 10, 8.4, 0, 27, -15.3, FOREST) -- y22..32 z-19.5..-11.1
		box(n1, 7.0, 1, 7.0, 0, 21.6, -15.4, FOREST_D)
		B:sym(function()
			box(n1, 0.8, 5.4, 5.2, 4.9, 27.0, -15.2, OBSID)
			box(n1, 0.9, 0.6, 5.4, 4.95, 30.0, -15.2, STONE)
			box(n1, 0.9, 0.6, 5.4, 4.95, 24.0, -15.2, STONE_D)
		end)
		local m2 = B:bone("Mane2", "Neck1", v(0, 32, -14))
		box(m2, 8.6, 1.6, 8.4, 0, 32.4, -14.8, MOSS_D)
		box(m2, 6.4, 1.2, 6.4, 0, 33.7, -14.6, MOSS)
		box(m2, 3.6, 1.0, 4.2, 0, 34.7, -14.2, MOSS_L)
		B:spike(m2, v(0, 34.6, -13.0), v(0, 37.0, -10.8), 1.3, 1.3, BONE)
		B:spike(m2, v(0, 34.0, -16.4), v(0, 36.0, -14.8), 1.0, 1.0, BONE)
		B:sym(function()
			strand(m2, 5.0, 31.8, -12.2, 2.8)
			strand(m2, 5.2, 31.8, -17.0, 2.2)
		end)
		local beard = B:bone("Beard", "Neck1", v(0, 23, -18.5))
		box(beard, 7.0, 3.8, 3.6, 0, 22.1, -19.2, MOSS_D)
		box(beard, 5.2, 2.6, 3.0, 0, 19.3, -19.4, MOSS)
		box(beard, 3.6, 2.0, 2.4, 0, 17.2, -19.6, MOSS_D)
		box(beard, 1.8, 1.2, 1.6, 0, 15.7, -19.7, MOSS_L)
		B:sym(function()
			box(beard, 1.0, 2.2, 2.0, 3.0, 19.3, -19.3, MOSS_L)
		end)

		local n2 = B:bone("Neck2", "Neck1", v(0, 28, -18))
		box(n2, 8.6, 7.6, 6.8, 0, 31.2, -20.4, FOREST) -- y27.4..35 z-23.8..-17
		box(n2, 6.2, 0.8, 5.4, 0, 27.1, -20.6, FOREST_D)
		local m3 = B:bone("Mane3", "Neck2", v(0, 34.5, -19))
		box(m3, 7.0, 1.4, 6.0, 0, 35.3, -19.6, MOSS_D)
		box(m3, 4.6, 1.0, 4.2, 0, 36.4, -19.2, MOSS)
		B:sym(function()
			strand(m3, 4.2, 34.8, -18.0, 2.4)
		end)

		------------------------------------------------------------------
		-- HEAD: stern pale stone skull-mask face on a charcoal-bark head.
		-- Authored around the old pivot HP0, then moved forward by HO and the
		-- face tilted nose-down (HT) so the titan glares DOWN at the thief.
		------------------------------------------------------------------
		local HO = v(0, 0, -2.6)
		local HP0 = v(0, 31, -19)
		local HT = CFrame.new(HO) * CFrame.new(HP0) * P.ang(-12, 0, 0) * CFrame.new(-HP0)
		local function hb(bone, sx, sy, sz, x, y, z, col, opts, rz)
			return B:block(bone, v(sx, sy, sz), HT * cf(x, y, z, 0, 0, rz or 0), col, opts)
		end
		local function hv(x, y, z)
			return (HT * CFrame.new(x, y, z)).Position
		end
		local function ab(bone, sx, sy, sz, x, y, z, col, opts, rz)
			return B:block(bone, v(sx, sy, sz), CFrame.new(HO) * cf(x, y, z, 0, 0, rz or 0), col, opts)
		end
		local function av(x, y, z)
			return v(x, y, z) + HO
		end
		local head = B:bone("Head", "Neck2", HP0 + HO)
		hb(head, 9.6, 7.4, 7.6, 0, 32.7, -21.6, BARK) -- skull y29..36.4
		hb(head, 8.2, 5.6, 1.0, 0, 32.8, -17.4, BARK_D)
		ab(head, 7.6, 1.0, 5.8, 0, 36.8, -21.4, BARK_D) -- crown step
		ab(head, 3.6, 0.9, 3.2, 0, 37.5, -20.8, MOSS_D)
		ab(head, 2.7, 0.8, 2.4, 0, 38.2, -20.8, MOSS)
		ab(head, 1.6, 0.6, 1.4, 0, 38.8, -20.8, MOSS_L)
		-- skull mask: pale forehead plate + 3 tapering pale muzzle tiers
		hb(head, 9.0, 4.6, 0.6, 0, 33.7, -25.6, MASK) -- front z -25.9
		hb(head, 2.4, 2.4, 0.4, 0, 36.6, -25.5, MASK) -- pale nasal stripe up to the crown
		hb(head, 7.4, 4.2, 3.8, 0, 30.0, -27.2, MASK) -- muzzle 1
		hb(head, 6.0, 3.6, 3.4, 0, 29.7, -30.6, MASK) -- muzzle 2
		hb(head, 4.6, 3.0, 2.0, 0, 29.4, -33.0, MASK) -- muzzle 3
		hb(head, 5.6, 0.6, 3.4, 0, 32.4, -27.0, MASK_D) -- muzzle top step
		hb(head, 2.4, 0.6, 7.2, 0, 31.8, -30.2, MASK_D) -- nose ridge
		hb(head, 3.2, 1.0, 0.8, 0, 30.6, -34.2, OBSID) -- nose pad
		B:sym(function(side)
			hb(head, 0.8, 0.45, 0.2, 0.85, 30.55, -34.65, MOUTH) -- nostril
			hb(head, 0.4, 2.6, 3.6, 3.75, 29.6, -27.2, MASK_D) -- muzzle cheek shade
			hb(head, 0.4, 2.2, 3.0, 3.05, 29.4, -30.6, MASK_D)
			-- cheek armour + stone trim
			hb(head, 0.8, 4.2, 5.2, 5.0, 32.0, -21.8, OBSID)
			hb(head, 0.9, 0.6, 5.4, 5.05, 34.3, -21.8, STONE)
			hb(head, 0.5, 2.2, 2.8, 5.5, 31.8, -21.8, OBSID_L)
			-- upper blunt teeth (just a few)
			hb(head, 1.1, 1.0, 1.1, 1.7, 27.4, -32.6, TEETH)
			hb(head, 1.0, 0.8, 1.0, 2.7, 27.5, -28.4, TEETH)
			hb(head, 0.3, 1.4, 7.6, 3.0, 27.4, -29.6, MOUTH) -- cheek wall
			-- EYE: dark socket, narrow emerald slit, slit pupil (front face only)
			-- (socket + slit wrap round the skull's front corner so the eye also
			-- reads from the side; the pupil is on the FRONT face only)
			hb(head, 2.9, 1.9, 1.4, 3.5, 33.25, -25.4, MOUTH)
			hb(head, 2.9, 0.9, 1.3, 3.8, 33.15, -25.45, EMER, { mat = "Neon", name = "Eye" }, 10)
			hb(head, 0.45, 0.9, 0.15, 3.0, 33.1, -26.2, PUPIL)
			-- hidden rage flare: the eye slit blazes wider when enraged
			hb(head, 3.0, 0.5, 0.2, 3.6, 33.35, -26.25, "#c8ffe4", { mat = "Neon", tr = 1, name = "EyeFlare" .. side }, 10)
		end)
		hb(head, 5.8, 0.4, 8.6, 0, 27.7, -29.4, MOUTH) -- mouth roof
		local roarFX = hb(head, 3, 2, 2, 0, 27.0, -34.0, STONE, { tr = 1, name = "RoarFX" })
		B:emitter(roarFX, "burst", { name = "RoarBurst", color = { "#ffffff", EMER, MOSS_L }, speed = { 12, 24 }, size = { 1.6, 1.0, 0 }, life = { 0.4, 0.9 }, spread = 35, dir = "Front" })
		B:light(roarFX, { name = "MouthLight", color = EMER, brightness = 0, range = 16 })

		-- heavy brows (own bones: they drop + tilt for the angry squint)
		B:sym(function(side)
			local brow = B:bone("Brow" .. side, "Head", hv(3.4, 34.8, -26.0))
			hb(brow, 4.4, 1.2, 1.4, 3.3, 34.8, -26.15, OBSID, nil, 16)
			hb(brow, 2.2, 0.7, 1.6, 4.1, 35.65, -25.8, OBSID_L, nil, 16)
			-- blink lid: hidden until the eye is mostly closed
			local lid = B:bone("Lid" .. side, "Head", hv(3.55, 34.2, -26.2))
			hb(lid, 3.1, 1.9, 1.6, 3.55, 34.05, -25.45, BARK_D, { tr = 1, name = "Eyelid" .. side })
		end)

		-- ears
		B:sym(function(side)
			local ear = B:bone("Ear" .. side, "Head", av(4.8, 34.2, -19.6))
			ab(ear, 3.6, 1.8, 2.4, 6.4, 34.6, -19.6, FOREST, nil, 14)
			ab(ear, 2.6, 0.4, 1.6, 6.4, 34.6, -20.85, MOSS, nil, 14)
			ab(ear, 1.9, 1.1, 1.8, 8.3, 35.1, -19.6, BARK, nil, 14)
		end)

		-- jaw (hinged at the back of the mouth)
		local jaw = B:bone("Jaw", "Head", hv(0, 27.9, -25.2))
		hb(jaw, 6.0, 1.8, 8.6, 0, 26.6, -29.4, BARK_D)
		hb(jaw, 4.8, 0.8, 7.0, 0, 25.4, -29.0, OBSID) -- chin plate
		hb(jaw, 5.4, 0.3, 8.0, 0, 27.55, -29.4, MOUTH)
		hb(jaw, 2.8, 0.3, 4.8, 0, 27.75, -28.6, TONGUE)
		hb(jaw, 5.0, 2.4, 1.0, 0, 27.9, -25.6, MOUTH) -- throat wall
		B:sym(function()
			hb(jaw, 1.0, 0.8, 1.0, 1.8, 28.0, -31.4, TEETH)
			hb(jaw, 0.9, 0.7, 0.9, 2.6, 28.0, -27.4, TEETH)
			hb(jaw, 0.3, 1.2, 7.4, 2.9, 27.9, -29.4, MOUTH)
		end)

		------------------------------------------------------------------
		-- ANTLERS: 3 bones per side (base -> mid -> crown) so they flare.
		-- Angled bone beams with STEPPED voxel tines (shrinking block stacks)
		-- capped by emerald tips; blossoms, moss strands and a lantern hang off.
		------------------------------------------------------------------
		local function beam(bone, a, b, w, h, col)
			return B:beam(bone, av(a[1], a[2], a[3]), av(b[1], b[2], b[3]), w, h, col)
		end
		local function tine(bone, x, y, z, s, n)
			local yy = y
			for i = 1, n do
				local w = s * (1 - (i - 1) * 0.25)
				ab(bone, w, 1.2, w, x, yy + 0.6, z - (i - 1) * 0.15, i == 1 and BONE_D or BONE)
				yy += 1.1
			end
			ab(bone, s * 0.5, 0.8, s * 0.5, x, yy + 0.35, z - n * 0.15, EMER, { mat = "Neon" })
		end
		local function thorn(bone, a, b, name)
			B:beam(bone, av(a[1], a[2], a[3]), av(b[1], b[2], b[3]), 0.5, 0.5, EMER, { mat = "Neon", tr = 1, name = name })
		end
		local function hblossom(bone, x, y, z, s)
			blossom(bone, x + HO.X, y + HO.Y, z + HO.Z, s)
		end
		local function hstrand(bone, x, y, z, len)
			strand(bone, x + HO.X, y + HO.Y, z + HO.Z, len)
		end
		B:sym(function(side)
			local a1 = B:bone("Antler1" .. side, "Head", av(3.0, 36.2, -21))
			ab(a1, 3.4, 1.4, 3.4, 3.0, 36.6, -21, STONE) -- burr
			ab(a1, 3.8, 0.6, 3.8, 3.0, 36.0, -21, BONE_D)
			beam(a1, { 3.0, 36.8, -21 }, { 7.4, 39.2, -19.6 }, 2.6, 2.6, BONE)
			beam(a1, { 3.4, 36.4, -21.2 }, { 6.4, 37.8, -19.8 }, 1.6, 3.0, BONE_D) -- stepped underside
			beam(a1, { 4.4, 37.6, -21.6 }, { 5.6, 38.0, -25.8 }, 1.8, 1.8, BONE) -- brow tine (forward)
			tine(a1, 5.6, 37.6, -26.0, 1.7, 1)
			hstrand(a1, 5.8, 37.4, -20.2, 2.4)
			thorn(a1, { 5.8, 38.6, -20.2 }, { 5.0, 41.0, -22.2 }, "Thorn1" .. side)

			local a2 = B:bone("Antler2" .. side, "Antler1" .. side, av(7.4, 39.2, -19.6))
			beam(a2, { 6.9, 39.0, -19.8 }, { 12.0, 40.2, -17.6 }, 2.2, 2.2, BONE)
			beam(a2, { 7.6, 38.6, -19.6 }, { 10.8, 39.2, -18.2 }, 1.4, 2.4, BONE_D)
			tine(a2, 9.6, 39.4, -18.8, 2.0, 2)
			hblossom(a2, 7.8, 40.3, -19.5, 1.7)
			hstrand(a2, 11.2, 39.0, -17.9, 2.6)
			thorn(a2, { 11.4, 40.2, -17.8 }, { 12.0, 42.4, -15.8 }, "Thorn2" .. side)

			local a3 = B:bone("Antler3" .. side, "Antler2" .. side, av(12.0, 40.2, -17.6))
			beam(a3, { 11.5, 40.1, -17.8 }, { 16.4, 40.7, -14.6 }, 1.9, 1.9, BONE)
			tine(a3, 13.6, 40.2, -16.8, 1.8, 1)
			tine(a3, 15.6, 40.4, -15.2, 1.5, 1)
			beam(a3, { 16.2, 40.6, -14.7 }, { 18.4, 41.6, -13.4 }, 1.3, 1.3, BONE) -- beam end
			ab(a3, 0.9, 0.9, 0.9, 18.6, 41.7, -13.3, EMER, { mat = "Neon" })
			hblossom(a3, 14.6, 41.1, -16.0, 1.4)
			thorn(a3, { 17.2, 41.0, -14.2 }, { 19.6, 42.6, -15.6 }, "Thorn3" .. side)
			thorn(a3, { 12.4, 40.4, -17.4 }, { 11.8, 42.6, -19.8 }, "Thorn4" .. side)
			-- hanging lantern (own bone so it swings)
			local lan = B:bone("Lantern" .. side, "Antler3" .. side, av(17.4, 40.2, -14.0))
			ab(lan, 0.35, 1.0, 0.35, 17.4, 39.7, -14.0, MOSS_D)
			ab(lan, 1.4, 0.35, 1.4, 17.4, 39.1, -14.0, BARK)
			neon(lan, 0.8, 1.3, 0.8, 17.4 + HO.X, 38.3 + HO.Y, -14.0 + HO.Z, "Lamp" .. side)
			ab(lan, 1.4, 0.35, 1.4, 17.4, 37.5, -14.0, BARK)
			ab(lan, 0.5, 0.4, 0.5, 17.4, 37.1, -14.0, BARK)
			-- hanging moss strand on its own bone
			local st = B:bone("Strand" .. side, "Antler3" .. side, av(14.4, 39.8, -16.2))
			hstrand(st, 14.4, 39.8, -16.2, 3.0)
			B:trail(a3, av(18.6, 41.7, -13.3), av(16.4, 40.7, -14.6), { name = "AntlerTrail" .. side, color = { EMER, PINK_L }, life = 0.22, trans = { 0.45, 1 } })
		end)
		-- falling leaves from the antler crown (ambient + bloom bursts)
		local crown = ab(head, 34, 3, 8, 0, 39.5, -17, STONE, { tr = 1, name = "CrownFX" })
		B:emitter(crown, "leaf", { name = "LeafStorm", color = { MOSS_L, "#c8f07a", PINK }, rate = 2, size = { 0.7, 0.7, 0.4 }, speed = { 2, 5 } })
		------------------------------------------------------------------
		-- LEGS: upper / lower / hoof. Forest-green upper, charcoal-bark lower
		-- with obsidian shin armour, shaggy moss fetlock, chunky stone hoof.
		------------------------------------------------------------------
		local function hoof(h, x, z)
			box(h, 5.8, 1.6, 6.0, x, 3.3, z, MOSS_D) -- fetlock shag
			box(h, 6.1, 0.8, 6.3, x, 2.7, z - 0.1, MOSS)
			box(h, 5.4, 2.0, 6.4, x, 1.4, z - 0.4, STONE) -- y0.4..2.4
			box(h, 5.8, 0.6, 6.8, x, 0.3, z - 0.4, STONE_D) -- y0..0.6
			box(h, 5.7, 0.4, 6.7, x, 2.25, z - 0.4, OBSID)
			box(h, 0.6, 1.6, 0.3, x, 1.3, z - 3.7, MOUTH) -- cloven split
		end
		B:sym(function(side)
			-- front leg
			local fu = B:bone("FLeg" .. side, "Chest", v(5.6, 14.5, -9))
			box(fu, 5.4, 8.2, 6.0, 5.7, 11.6, -9.2, FOREST) -- y7.5..15.7
			box(fu, 0.4, 6.0, 4.8, 8.45, 11.4, -9.2, FOREST_D)
			box(fu, 4.6, 3.0, 0.8, 5.7, 9.2, -12.5, STONE) -- knee guard
			B:spike(fu, v(5.7, 9.6, -12.8), v(5.7, 10.8, -15.0), 1.3, 1.3, BONE)
			local fk = B:bone("FKnee" .. side, "FLeg" .. side, v(5.6, 8, -11.2))
			box(fk, 4.2, 6.6, 4.4, 5.6, 5.0, -9.3, BARK) -- y1.7..8.3
			box(fk, 3.8, 4.6, 0.8, 5.6, 5.4, -11.8, OBSID)
			box(fk, 4.0, 0.6, 1.0, 5.6, 7.9, -11.8, STONE)
			box(fk, 0.4, 4.4, 3.2, 7.75, 5.2, -9.3, BARK_D)
			neon(fk, 0.3, 2.2, 0.2, 5.6, 5.3, -12.25)
			local fh = B:bone("FHoof" .. side, "FKnee" .. side, v(5.6, 2.5, -9))
			hoof(fh, 5.6, -9)
			local dust = box(fh, 5, 0.3, 6, 5.6, 0.15, -9.4, STONE, { tr = 1, name = "HoofFX" .. side })
			B:emitter(dust, "dust", { name = "Dust" .. side, color = { "#cbbd98", "#9c8f70" }, size = { 2.5, 4.5, 6 }, speed = { 8, 15 }, life = { 0.7, 1.3 }, spread = 85 })
			B:trail(fh, v(5.6, 0.4, -12.8), v(5.6, 2.6, -12.6), { name = "HoofTrail" .. side, color = { EMER, MOSS_L }, life = 0.2, trans = { 0.55, 1 } })

			-- hind leg
			local hu = B:bone("HLeg" .. side, "Body", v(5.6, 14.5, 10))
			box(hu, 5.8, 8.6, 7.0, 5.7, 11.8, 10, FOREST) -- y7.5..16.1
			box(hu, 0.8, 5.0, 5.4, 8.75, 12.4, 10, OBSID) -- thigh armour
			box(hu, 0.9, 0.6, 5.6, 8.8, 15.1, 10, STONE)
			algiz(hu, 9.2, 12.2, 10, 0.9)
			local hk = B:bone("HKnee" .. side, "HLeg" .. side, v(5.6, 8, 12.2))
			box(hk, 4.2, 6.6, 4.4, 5.6, 5.0, 10.4, BARK)
			box(hk, 3.8, 4.4, 0.8, 5.6, 5.2, 7.9, OBSID)
			box(hk, 0.4, 4.4, 3.2, 7.75, 5.2, 10.4, BARK_D)
			B:spike(hk, v(5.6, 7.6, 12.4), v(5.6, 9.4, 14.8), 1.4, 1.4, BONE) -- hock thorn
			local hh = B:bone("HHoof" .. side, "HKnee" .. side, v(5.6, 2.5, 10))
			hoof(hh, 5.6, 10)
			B:trail(hh, v(5.6, 0.4, 6.4), v(5.6, 2.6, 6.6), { name = "HindTrail" .. side, color = { EMER, MOSS_L }, life = 0.18, trans = { 0.6, 1 } })
		end)
		local hindFX = box("Root", 14, 0.3, 12, 0, 0.15, 10, STONE, { tr = 1, name = "HindFX" })
		B:emitter(hindFX, "dust", { name = "HindDust", color = { "#cbbd98", "#9c8f70" }, size = { 2.5, 4.5, 6 }, speed = { 8, 14 }, life = { 0.7, 1.2 }, spread = 85 })
		local quake = box("Root", 20, 0.3, 14, 0, 0.15, -11, STONE, { tr = 1, name = "QuakeFX" })
		B:emitter(quake, "dust", { name = "QuakeDust", color = { "#d6c9a6", "#9c8f70" }, size = { 4, 7, 9 }, speed = { 14, 26 }, life = { 0.9, 1.7 }, spread = 88, trans = { 0.3, 0.5, 1 } })

		------------------------------------------------------------------
		-- QUAKE ROCKS: a ring of mossy stone slabs (one bone each) that burst
		-- out of the ground around the front hooves on the slams
		------------------------------------------------------------------
		local SC = v(0, 0.6, -10)
		for k = 1, 14 do
			local a = (k - 1) / 14 * 360
			local rb = B:bone("Rock" .. k, "Root", SC)
			local at = CFrame.new(SC) * P.ang(0, a, 0) * CFrame.new(0, 0, -4.0) * P.ang(-18, 0, 0)
			B:block(rb, v(2.8, 1.4, 1.8), at, k % 2 == 0 and STONE or STONE_D, { tr = 1, name = "Rock" .. k })
			local glow = k % 3 == 0
			B:block(rb, v(2.2, 0.5, 1.4), at * CFrame.new(0, 0.9, 0), glow and EMER or MOSS, { mat = glow and "Neon" or "Plastic", tr = 1, name = "RockTop" .. k })
		end

		------------------------------------------------------------------
		-- SPIRIT WISPS: mossy stone voxel cubes with an emerald band
		------------------------------------------------------------------
		B:bone("Orbit", "Root", v(0, 18, 0))
		local spots = {
			{ 17, 10, -9, 2.6 }, { -17.5, 15, -2, 2.2 }, { 15, 26, 9, 2.0 },
			{ -14, 29, -15, 2.4 }, { 3, 8, 20, 2.2 }, { -9, 22, 18, 1.8 },
		}
		for i, s in spots do
			local p = v(s[1], s[2], s[3])
			local ob = B:bone("Orb" .. i, "Orbit", p)
			local z = s[4]
			B:block(ob, v(z, z, z), CFrame.new(p), i % 2 == 0 and STONE or FOREST)
			B:block(ob, v(z + 0.1, z * 0.3, z + 0.1), CFrame.new(p + v(0, z * 0.36, 0)), MOSS_L)
			B:block(ob, v(z + 0.16, z * 0.14, z + 0.16), CFrame.new(p + v(0, -z * 0.1, 0)), EMER, { mat = "Neon" })
		end
	end,
}
