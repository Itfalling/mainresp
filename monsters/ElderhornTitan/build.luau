--!nocheck
-- Elderhorn Titan (Guardian #10, the FINAL BOSS): a colossal ancient forest
-- god-stag that guards the World Tree's sacred grove. Stud-built in the Void
-- Leviathan style at boss scale (~43 studs tall, a player is 5).
-- Heroic bull-bison-stag mass: a huge raised chest and hulking withers, a thick
-- neck carrying the head HIGH, long armoured legs. Dark ancient palette that
-- reads on grass: deep bark-brown hide under charcoal/obsidian layered armour,
-- a bone-white skull mask, a crown of MASSIVE stepped antlers (obsidian/bark
-- bases -> bone tips -> emerald glow), green only as moss trim + vines.
-- Face: ONE pair of deep-set emerald slit eyes under a heavy obsidian brow,
-- ONE strong jaw with a few blunt teeth.
-- Neon only on eyes, small runes, the chest core gem, antler tips, lanterns and
-- blossom hearts. Big VFX (glowing thorns, rune pulse, quake rocks) are hidden
-- props the motion reveals on the beats.
return {
	DisplayName = "Elderhorn Titan",
	Rarity = "Apex",
	Element = "Ancient",
	Build = function(B, P)
		local v, cf = P.v, P.cf

		-- palette
		local BARK, BARK_D, FUR = "#4a3326", "#2e1f17", "#36261c"
		local OBSID, OBSID_L = "#1d1f26", "#353944"
		local STONE, STONE_D = "#6d727a", "#4a4f57"
		local MOSS, MOSS_L, MOSS_D = "#4f9a2c", "#8fd14a", "#2f6a1f"
		local BONE, BONE_D, BONE_DD = "#ece4cc", "#c4b48e", "#8c7a58"
		local MASK_D = "#bdb39a"
		local PINK, PINK_L = "#ff7fc4", "#ffc4e6"
		local EMER = "#3dffa0"
		local MOUTH, TEETH, PUPIL, TONGUE = "#0e0a08", "#f2ecd8", "#02130a", "#6e2b33"

		local function box(bone, sx, sy, sz, x, y, z, col, opts)
			return B:block(bone, v(sx, sy, sz), cf(x, y, z), col, opts)
		end
		local function neon(bone, sx, sy, sz, x, y, z, name)
			return B:block(bone, v(sx, sy, sz), cf(x, y, z), EMER, { mat = "Neon", name = name })
		end
		local function blossom(bone, x, y, z, s)
			box(bone, s, s * 0.55, s, x, y, z, PINK)
			B:block(bone, v(s * 0.78, s * 0.5, s * 0.78), cf(x, y + 0.1, z, 0, 45, 0), PINK_L)
			neon(bone, s * 0.36, s * 0.36, s * 0.36, x, y + s * 0.32, z)
		end
		local function strand(bone, x, y, z, len)
			box(bone, 0.8, len, 0.8, x, y - len / 2, z, MOSS_D)
			box(bone, 0.55, len * 0.5, 0.55, x, y - len * 1.2, z, MOSS)
			box(bone, 0.9, 0.55, 0.9, x, y - len * 1.45, z, MOSS_L)
		end
		-- ogham-style rune CUT into a plate facing +X: a thin glowing stem line
		-- with short notches above/below (no frame, just carved light)
		local function algiz(bone, x, y, z, s)
			neon(bone, 0.2, 0.25, 3.6 * s, x, y, z)
			for k, o in { -1.2, -0.4, 0.4, 1.2 } do
				local up = (k % 2 == 1) and 1 or -1
				neon(bone, 0.2, 0.8 * s, 0.25, x, y + up * 0.5 * s, z + o * s)
			end
		end
		-- layered armour on a side face (+X): 3 overlapping shingle plates that
		-- step narrower + further out toward the bottom, each with a bone-trimmed
		-- lower edge; a bone ridge on top with spikes, a moss tuft clinging to
		-- one corner, and a rune CUT through the plates as a glowing zig-zag line
		local function sidePlates(bone, x, y, z, h, d, spikes)
			local ph = h / 3 + 0.6
			local faces = {}
			for i = 0, 2 do
				local py = y + h / 2 - ph / 2 - i * (h / 3)
				local pd = d - i * 1.6
				local px = x + i * 0.3
				local pz = z + i * 0.35
				box(bone, 1.0, ph, pd, px, py, pz, i == 1 and OBSID_L or OBSID)
				box(bone, 1.1, 0.4, pd - 0.4, px + 0.06, py - ph / 2 + 0.2, pz, BONE_DD)
				faces[i] = px + 0.53
			end
			box(bone, 1.3, 0.5, d * 0.92, x, y + h / 2 + 0.15, z, BONE_D)
			box(bone, 1.6, 0.8, d * 0.42, x + 0.6, y - h / 2 - 0.1, z - d * 0.22, MOSS)
			box(bone, 0.7, 0.5, d * 0.22, x + 1.0, y - h / 2 - 0.6, z - d * 0.3, MOSS_L)
			local y0, y1, y2, y3 = y + h / 2 - 0.5, y + h / 6, y - h / 6, y - h / 2 + 0.7
			B:beam(bone, v(faces[0], y0, z - 0.9), v(faces[0], y1, z + 0.5), 0.22, 0.22, EMER, { mat = "Neon" })
			B:beam(bone, v(faces[1], y1, z + 0.5), v(faces[1], y2, z - 0.5), 0.22, 0.22, EMER, { mat = "Neon" })
			B:beam(bone, v(faces[2], y2, z - 0.5), v(faces[2], y3, z + 0.4), 0.22, 0.22, EMER, { mat = "Neon" })
			for _, sp in spikes or {} do
				B:spike(bone, v(x + 0.4, y + h / 2 + 0.3, z + sp[1]), v(x + 2.6, y + h / 2 + sp[2], z + sp[1] + sp[3]), 1.4, 1.4, BONE)
			end
		end

		------------------------------------------------------------------
		-- BODY (rump; pivots at the hind hips so it can REAR UP)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 17, 11))
		box(body, 12.4, 10, 11, 0, 21, 10.5, BARK) -- y16..26 z5..16
		box(body, 10, 1, 9, 0, 15.6, 10.2, BARK_D) -- belly
		box(body, 9, 6, 0.8, 0, 21.5, 16.3, BARK_D) -- rump back
		-- overlapping stepped back plates with a bone spine ridge + moss trim
		box(body, 12.0, 1.2, 4.4, 0, 26.5, 6.6, OBSID)
		box(body, 11.2, 1.2, 4.4, 0, 26.3, 10.4, OBSID_L)
		box(body, 10.2, 1.2, 4.2, 0, 25.9, 14.0, OBSID)
		box(body, 12.6, 0.6, 12, 0, 25.7, 10.4, MOSS)
		for i, z in { 6.0, 9.6, 13.2 } do
			B:spike(body, v(0, 26.9, z), v(0, 30.0 - i * 0.5, z + 1.8), 1.6, 1.6, BONE)
		end
		B:sym(function()
			box(body, 0.6, 3.2, 9.0, 6.05, 17.6, 10.5, BARK_D)
			sidePlates(body, 6.5, 21.4, 10.4, 6.6, 8.4, { { -2.4, 2.2, -1.6 }, { 1.8, 1.8, -1.2 } })
		end)
		local tail = B:bone("Tail", "Body", v(0, 24, 16))
		box(tail, 3.6, 3.6, 2.6, 0, 22.8, 17.0, BARK)
		box(tail, 4.2, 1.6, 3.2, 0, 24.4, 17.2, FUR)
		box(tail, 3.0, 0.8, 2.4, 0, 25.4, 17.3, MOSS)
		box(tail, 2.6, 2.4, 2.0, 0, 20.2, 17.6, FUR)
		box(tail, 1.4, 1.0, 1.4, 0, 18.6, 17.8, MOSS_L)

		------------------------------------------------------------------
		-- CHEST: massive raised chest, hulking shoulders + withers hump
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Body", v(0, 18, 0))
		box(chest, 13, 10.5, 9.6, 0, 21.6, 1.6, BARK) -- barrel
		box(chest, 16, 13.6, 11, 0, 22.3, -8.5, BARK) -- shoulders y15.5..29.1 z-14..-3
		box(chest, 14, 2.6, 10, 0, 30.2, -7.5, BARK) -- withers hump y28.9..31.5
		box(chest, 12, 5, 2.4, 0, 18.5, -14.8, BARK) -- brisket
		box(chest, 11, 1, 17, 0, 15.3, -4, BARK_D) -- belly
		box(chest, 12.4, 0.6, 7, 0, 27.1, 2.0, MOSS) -- mossy back
		B:spike(chest, v(0, 27.2, 0.4), v(0, 30.4, 2.4), 1.6, 1.6, BONE)
		B:sym(function()
			box(chest, 0.6, 4, 15, 8.05, 17.6, -5, BARK_D) -- lower flank shade
			-- stepped rib plates on the barrel, each with a bone ridge
			for i, z in { -0.8, 2.0, 4.8 } do
				box(chest, 0.8, 5.6 - i * 0.6, 2.4, 6.75, 22.6 - i * 0.3, z, i == 2 and OBSID_L or OBSID)
				box(chest, 0.6, 0.6, 2.6, 7.0, 25.6 - i * 0.6, z, BONE_D)
			end
			-- flowering vine wrapped round the barrel
			B:beam(chest, v(7.45, 26.0, -1.8), v(7.45, 16.6, 5.6), 0.7, 0.7, MOSS_D)
			for k, p in { { 23.6, 0.2 }, { 20.6, 2.6 }, { 17.9, 4.7 } } do
				box(chest, 0.5, 0.5, 1.6, 7.65, p[1] + 0.5, p[2] + (k % 2 == 0 and 0.7 or -0.7), MOSS_L)
			end
			box(chest, 0.6, 1.1, 1.1, 7.8, 21.8, 1.6, PINK)
			box(chest, 0.3, 0.45, 0.45, 8.15, 21.8, 1.6, EMER, { mat = "Neon" })
			-- hulking layered pauldrons with bone spikes + a small rune
			box(chest, 1.6, 8.4, 10, 8.3, 24.4, -8.5, OBSID)
			sidePlates(chest, 9.3, 24.3, -8.5, 8.0, 9.6, {})
			box(chest, 3.0, 1.0, 10.6, 8.8, 28.9, -8.5, STONE)
			box(chest, 2.6, 0.7, 10.2, 8.6, 20.2, -8.5, MOSS)
			box(chest, 1.2, 0.5, 4.0, 9.2, 19.6, -10.0, MOSS_L)
			B:spike(chest, v(9.4, 29.3, -5.6), v(12.6, 34.0, -3.2), 1.9, 1.9, BONE)
			B:spike(chest, v(9.4, 29.3, -10.6), v(12.2, 32.8, -12.8), 1.6, 1.6, BONE)
			B:spike(chest, v(10.6, 27.0, -13.2), v(12.8, 27.8, -16.2), 1.2, 1.2, BONE_D)
		end)
		-- layered breastplate, tree-of-life rune, rune core gem
		box(chest, 12, 10, 1, 0, 21.4, -16.2, OBSID) -- front -16.7
		box(chest, 9, 7.4, 0.6, 0, 21.4, -16.95, OBSID_L)
		box(chest, 6, 1.4, 1, 0, 15.9, -16.0, OBSID)
		box(chest, 14, 1.2, 1.8, 0, 26.8, -16.0, STONE) -- collar trim
		B:block(chest, v(4.2, 4.2, 0.6), cf(0, 20.4, -17.4, 0, 0, 45), STONE_D)
		local core = B:block(chest, v(2.2, 2.2, 0.5), cf(0, 20.4, -17.75, 0, 0, 45), EMER, { mat = "Neon", name = "RuneCore" })
		B:light(core, { name = "CoreLight", color = EMER, brightness = 0.6, range = 16 })
		B:emitter(core, "burst", { name = "RuneBurst", color = { "#ffffff", EMER, PINK }, speed = { 10, 22 }, size = { 1.4, 0.9, 0 }, life = { 0.5, 1.1 } })
		neon(chest, 0.35, 1.8, 0.2, 0, 17.6, -17.35)
		neon(chest, 4.4, 0.35, 0.2, 0, 16.8, -17.35)
		B:sym(function()
			B:block(chest, v(3.0, 0.35, 0.2), cf(2.2, 22.2, -17.35, 0, 0, 35), EMER, { mat = "Neon" })
			neon(chest, 0.35, 1.8, 0.2, 3.4, 23.9, -17.35)
			-- bone tusk-spikes jutting forward from the chest corners
			B:spike(chest, v(5.2, 24.6, -16.4), v(6.6, 26.0, -20.0), 1.4, 1.4, BONE)
			B:spike(chest, v(5.4, 18.2, -16.2), v(6.4, 17.6, -19.0), 1.1, 1.1, BONE_D)
		end)
		box(chest, 8.8, 7.0, 0.2, 0, 21.4, -17.3, EMER, { mat = "Neon", tr = 1, name = "RuneGlow" })
		local aura = box(chest, 16, 12, 22, 0, 24, -3, BARK, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "Sparkles", color = { "#ffffff", EMER, PINK_L }, rate = 5 })

		-- shaggy fur + moss mane over the withers
		local m1 = B:bone("Mane1", "Chest", v(0, 31.2, -8))
		box(m1, 14.6, 1.4, 11.2, 0, 31.9, -7.6, FUR)
		box(m1, 11.6, 1.0, 8.8, 0, 32.9, -8.0, MOSS_D)
		box(m1, 6.6, 0.8, 5.6, 0, 33.6, -8.6, MOSS)
		B:sym(function()
			box(m1, 1.2, 3.2, 9.6, 7.5, 30.3, -7.8, FUR)
			for k, z in { -11.6, -8.8, -6.0, -3.4 } do
				local len = (k % 2 == 0) and 2.0 or 2.8
				box(m1, 1.0, len, 1.6, 7.8, 28.8 - len / 2, z, FUR)
				box(m1, 0.8, 0.6, 1.0, 7.8, 28.5 - len, z, MOSS)
			end
			blossom(m1, 4.0, 33.3, -5.4, 1.6)
		end)

		------------------------------------------------------------------
		-- NECK: thick and rising, carrying the head high
		------------------------------------------------------------------
		local n1 = B:bone("Neck1", "Chest", v(0, 26, -13))
		box(n1, 10.4, 12, 8.6, 0, 30.5, -16.4, BARK) -- y24.5..36.5 z-20.7..-12.1
		box(n1, 8, 1, 7.4, 0, 23.6, -16.2, BARK_D)
		B:sym(function()
			box(n1, 0.8, 6.2, 6.4, 5.4, 29.6, -16.2, OBSID)
			box(n1, 0.7, 4.2, 4.4, 5.9, 29.3, -16.4, OBSID_L)
			box(n1, 1.0, 0.6, 6.6, 5.45, 33.0, -16.2, STONE)
		end)
		local m2 = B:bone("Mane2", "Neck1", v(0, 36.2, -15))
		box(m2, 9.0, 1.6, 9.0, 0, 36.6, -15.8, FUR)
		box(m2, 6.6, 1.0, 6.6, 0, 37.7, -15.4, MOSS_D)
		box(m2, 3.4, 0.8, 3.8, 0, 38.5, -15.0, MOSS)
		B:spike(m2, v(0, 38.6, -13.6), v(0, 41.2, -11.2), 1.4, 1.4, BONE)
		B:sym(function()
			strand(m2, 5.2, 36.2, -12.6, 2.8)
			strand(m2, 5.4, 36.2, -17.8, 2.2)
		end)
		local beard = B:bone("Beard", "Neck1", v(0, 25, -19.5))
		box(beard, 7.6, 4.0, 3.8, 0, 23.4, -20.4, FUR)
		box(beard, 6.0, 2.8, 3.2, 0, 20.4, -20.6, FUR)
		box(beard, 4.0, 2.2, 2.6, 0, 18.0, -20.8, MOSS_D)
		box(beard, 2.0, 1.2, 1.8, 0, 16.4, -20.9, MOSS)
		B:sym(function()
			box(beard, 1.0, 2.4, 2.2, 3.3, 20.6, -20.5, MOSS)
		end)

		local n2 = B:bone("Neck2", "Neck1", v(0, 33, -20))
		box(n2, 9.4, 10, 7.8, 0, 37.5, -22.4, BARK) -- steep: y32.5..42.5 z-26.3..-18.5
		box(n2, 7.0, 0.8, 6.2, 0, 32.4, -22.8, BARK_D)
		box(n2, 6.6, 6.0, 0.8, 0, 35.6, -26.5, BARK_D) -- throat front
		local m3 = B:bone("Mane3", "Neck2", v(0, 42, -20.2))
		box(m3, 7.6, 1.4, 5.0, 0, 42.6, -20.2, FUR)
		box(m3, 5.0, 0.8, 3.4, 0, 43.5, -19.8, MOSS_D)
		B:sym(function()
			strand(m3, 4.8, 42.0, -19.6, 3.0)
		end)

		------------------------------------------------------------------
		-- HEAD: bone-white skull mask on a dark bark head. Face parts are
		-- tilted a little nose-down about the head pivot (HT): it looks
		-- forward and DOWN at the thief from up high.
		------------------------------------------------------------------
		local HO = v(0, 4.0, 0.5) -- head carried high on the neck (authored at HP)
		local HP = v(0, 33, -23.5)
		local HT = CFrame.new(HO) * CFrame.new(HP) * P.ang(-18, 0, 0) * CFrame.new(-HP) -- muzzle forward-down
		local function ab(bone, sx, sy, sz, x, y, z, col, opts, rz)
			return B:block(bone, v(sx, sy, sz), CFrame.new(HO) * cf(x, y, z, 0, 0, rz or 0), col, opts)
		end
		local function av(x, y, z)
			return v(x, y, z) + HO
		end
		local HS = 1.12 -- big cartoon head: face authored at 1x, scaled about HP
		local function hp(x, y, z)
			return HP + (v(x, y, z) - HP) * HS
		end
		local function hb(bone, sx, sy, sz, x, y, z, col, opts, rz)
			return B:block(bone, v(sx, sy, sz) * HS, HT * CFrame.new(hp(x, y, z)) * P.ang(0, 0, rz or 0), col, opts)
		end
		local function hv(x, y, z)
			return (HT * CFrame.new(hp(x, y, z))).Position
		end
		local head = B:bone("Head", "Neck2", HP + HO)
		hb(head, 10, 7, 8.6, 0, 34, -27.6, BARK_D) -- skull y30.5..37.5 z-31.9..-23.3
		hb(head, 8.6, 5.6, 1.0, 0, 34.2, -23.0, BARK)
		hb(head, 7.2, 0.9, 5.6, 0, 37.9, -27.2, OBSID) -- crown step
		hb(head, 3.2, 0.7, 2.8, 0, 38.6, -25.6, MOSS)
		-- skull mask: forehead plate + crest + 3 tapering muzzle tiers
		hb(head, 9.4, 5.2, 0.6, 0, 34.8, -32.2, BONE) -- front -32.5
		hb(head, 3.2, 2.2, 0.6, 0, 38.4, -32.0, BONE) -- mask crest
		hb(head, 1.8, 1.2, 0.6, 0, 40.0, -31.8, BONE)
		hb(head, 8.0, 4.4, 4.0, 0, 32.6, -34.4, BONE) -- muzzle 1 y30.4..34.8
		hb(head, 6.6, 3.8, 2.8, 0, 32.3, -37.7, BONE) -- muzzle 2
		hb(head, 5.2, 3.2, 1.6, 0, 32.0, -39.8, BONE) -- muzzle 3
		hb(head, 6.0, 0.6, 3.6, 0, 35.1, -34.2, MASK_D) -- muzzle top step
		hb(head, 2.6, 0.6, 6.8, 0, 34.6, -37.2, MASK_D) -- nose ridge
		hb(head, 2.8, 0.9, 0.6, 0, 33.25, -40.85, OBSID) -- nose pad
		B:sym(function(side)
			hb(head, 0.7, 0.4, 0.2, 0.75, 33.2, -41.2, MOUTH) -- nostril
			hb(head, 0.4, 2.8, 3.8, 4.05, 32.4, -34.4, MASK_D)
			hb(head, 0.4, 2.4, 2.6, 3.35, 32.2, -37.7, MASK_D)
			hb(head, 0.3, 1.8, 0.3, 4.3, 33.2, -33.2, BONE_DD) -- ancient crack
			hb(head, 0.3, 0.3, 1.6, 4.3, 32.4, -34.0, BONE_DD)
			-- cheek armour + a bone cheek spike sweeping back
			hb(head, 0.8, 4.8, 6.4, 5.4, 33.6, -27.6, OBSID)
			hb(head, 0.6, 3.0, 4.2, 5.9, 33.4, -27.6, OBSID_L)
			hb(head, 1.0, 0.6, 6.6, 5.45, 36.2, -27.6, STONE)
			B:spike(head, hv(5.6, 32.2, -25.6), hv(8.2, 31.4, -21.6), 1.3, 1.3, BONE)
			-- upper blunt teeth
			hb(head, 1.1, 1.2, 1.0, 1.5, 29.95, -40.35, TEETH)
			hb(head, 1.1, 0.9, 1.1, 3.0, 30.0, -35.6, TEETH)
			hb(head, 0.3, 1.4, 8.6, 3.3, 29.9, -36.0, MOUTH) -- cheek wall
			-- EYE: deep dark socket, emerald slit wrapping the skull corner
			-- (reads from the side), pupil on the FRONT face only
			hb(head, 3.2, 2.1, 1.4, 3.4, 35.2, -32.6, MOUTH)
			hb(head, 3.0, 0.95, 1.3, 3.7, 35.15, -32.75, EMER, { mat = "Neon", name = "Eye" }, 10)
			hb(head, 0.45, 0.95, 0.15, 3.0, 35.1, -33.45, PUPIL)
			hb(head, 3.2, 0.5, 0.2, 3.6, 35.4, -33.5, "#c8ffe4", { mat = "Neon", tr = 1, name = "EyeFlare" .. side }, 10)
		end)
		hb(head, 6.8, 0.4, 9.0, 0, 30.2, -36.2, MOUTH) -- mouth roof
		hb(head, 5.4, 0.45, 0.3, 0, 30.2, -40.8, MOUTH) -- mouth line
		local roarFX = hb(head, 3, 2, 2, 0, 29.4, -40.6, STONE, { tr = 1, name = "RoarFX" })
		B:emitter(roarFX, "burst", { name = "RoarBurst", color = { "#ffffff", EMER, MOSS_L }, speed = { 12, 24 }, size = { 1.6, 1.0, 0 }, life = { 0.4, 0.9 }, spread = 35, dir = "Front" })
		B:light(roarFX, { name = "MouthLight", color = EMER, brightness = 0, range = 18 })

		-- heavy brow (own bones: drop + tilt for the angry squint) + blink lids
		B:sym(function(side)
			local brow = B:bone("Brow" .. side, "Head", hv(3.3, 36.8, -33.0))
			hb(brow, 5.0, 1.6, 2.2, 3.2, 36.8, -33.0, OBSID, nil, 14)
			hb(brow, 2.6, 0.8, 1.8, 4.2, 37.8, -32.6, OBSID_L, nil, 14)
			local lid = B:bone("Lid" .. side, "Head", hv(3.5, 36.4, -32.8))
			hb(lid, 3.3, 2.0, 1.6, 3.5, 36.3, -32.75, BARK_D, { tr = 1, name = "Eyelid" .. side })
		end)

		-- ears
		B:sym(function(side)
			local ear = B:bone("Ear" .. side, "Head", hv(4.8, 35.6, -25.2))
			hb(ear, 3.4, 1.6, 2.2, 6.4, 35.9, -25.2, BARK, nil, 14)
			hb(ear, 2.4, 0.4, 1.4, 6.4, 35.9, -26.35, MOSS, nil, 14)
			hb(ear, 1.8, 1.0, 1.6, 8.2, 36.4, -25.2, OBSID, nil, 14)
		end)

		-- strong jaw (hinged at the back of the mouth)
		local jaw = B:bone("Jaw", "Head", hv(0, 30.4, -31.6))
		hb(jaw, 7.4, 2.4, 9.2, 0, 29.0, -36.1, BARK_D) -- y27.8..30.2
		hb(jaw, 6.0, 1.0, 7.6, 0, 27.4, -35.8, OBSID) -- chin plate
		hb(jaw, 5.4, 0.9, 1.0, 0, 28.8, -40.8, BONE_D) -- chin lip
		hb(jaw, 6.6, 0.3, 8.6, 0, 30.25, -36.1, MOUTH)
		hb(jaw, 3.2, 0.3, 5.4, 0, 30.45, -35.6, TONGUE)
		hb(jaw, 6.0, 2.6, 1.0, 0, 30.6, -32.0, MOUTH) -- throat wall
		B:sym(function()
			hb(jaw, 1.1, 0.9, 1.1, 2.2, 30.75, -38.6, TEETH)
			hb(jaw, 1.0, 0.8, 1.0, 3.0, 30.7, -34.4, TEETH)
			hb(jaw, 0.3, 1.2, 8.4, 3.5, 30.6, -36.1, MOUTH)
			B:spike(jaw, hv(3.4, 28.6, -33.0), hv(5.0, 27.4, -30.6), 1.0, 1.0, BONE_D) -- jaw barb
		end)

		------------------------------------------------------------------
		-- ANTLERS: a TALL Irish-elk / ancient-tree crown rising ~14 studs
		-- above the skull. 3 bones per side (base -> mid -> crown) so they
		-- flare. Beams sweep up + back; each tier throws big tines up/forward
		-- and out that STEP thinner (dark bark -> bone -> bone-white) to an
		-- emerald glow tip, with open gaps between them.
		------------------------------------------------------------------
		local function tine(bone, a, b, w, col, tipped)
			B:beam(bone, a, b, w, w, col)
			if tipped then
				local d = (b - a).Unit
				B:block(bone, v(w * 0.66, w * 0.66, w * 0.66), CFrame.new(b + d * (w * 0.3)), EMER, { mat = "Neon" })
			end
		end
		-- a stepped tine: thick lower segment, thinner upper segment, glow tip
		local function tine2(bone, a, m, b, w, c1, c2)
			tine(bone, a, m, w, c1, false)
			tine(bone, m - (m - a).Unit * 0.4, b, w * 0.68, c2, true)
		end
		local function thorn(bone, a, b, name)
			B:beam(bone, a, b, 0.55, 0.55, EMER, { mat = "Neon", tr = 1, name = name })
		end
		B:sym(function(side)
			local a1 = B:bone("Antler1" .. side, "Head", v(3.6, 40.6, -28))
			box(a1, 4.2, 1.6, 4.2, 3.6, 40.6, -28, STONE) -- burr
			box(a1, 4.6, 0.6, 4.6, 3.6, 40.0, -28, OBSID)
			B:beam(a1, v(3.6, 41.0, -28), v(7.6, 46.4, -25.0), 3.4, 3.4, BARK_D)
			B:beam(a1, v(4.0, 40.6, -28.4), v(6.8, 44.4, -26.0), 2.4, 3.6, OBSID) -- stepped underside
			tine2(a1, v(4.8, 42.0, -29.0), v(6.0, 44.4, -33.0), v(6.6, 46.8, -35.0), 2.3, BARK, BONE_D) -- brow tine
			thorn(a1, v(6.4, 44.6, -26.0), v(8.6, 46.0, -28.2), "Thorn1" .. side)

			local a2 = B:bone("Antler2" .. side, "Antler1" .. side, v(7.6, 46.4, -25.0))
			B:beam(a2, v(7.2, 46.0, -25.2), v(11.0, 50.6, -21.6), 2.8, 2.8, BARK)
			B:beam(a2, v(7.8, 45.6, -24.6), v(10.2, 48.8, -22.2), 1.6, 2.6, BARK_D)
			tine2(a2, v(8.4, 47.4, -24.8), v(9.2, 50.4, -28.4), v(9.6, 52.6, -30.2), 2.1, BONE_DD, BONE_D) -- forward tine
			tine2(a2, v(9.8, 48.8, -23.0), v(14.2, 50.6, -23.6), v(17.0, 52.4, -24.6), 1.9, BONE_DD, BONE) -- outward tine
			tine2(a2, v(10.0, 49.4, -21.6), v(11.4, 51.0, -18.0), v(12.0, 52.4, -15.8), 1.6, BONE_DD, BONE) -- back tine
			blossom(a2, 8.0, 47.8, -24.6, 1.8)
			thorn(a2, v(9.6, 48.4, -23.2), v(10.4, 51.0, -25.6), "Thorn2" .. side)
			local lan = B:bone("Lantern" .. side, "Antler2" .. side, v(13.4, 50.4, -23.5))
			box(lan, 0.35, 1.6, 0.35, 13.4, 49.6, -23.5, MOSS_D)
			box(lan, 1.5, 0.35, 1.5, 13.4, 48.7, -23.5, OBSID)
			neon(lan, 0.85, 1.3, 0.85, 13.4, 47.9, -23.5, "Lamp" .. side)
			box(lan, 1.5, 0.35, 1.5, 13.4, 47.1, -23.5, OBSID)
			box(lan, 0.5, 0.4, 0.5, 13.4, 46.7, -23.5, OBSID)

			local a3 = B:bone("Antler3" .. side, "Antler2" .. side, v(11.0, 50.6, -21.6))
			B:beam(a3, v(10.6, 50.2, -21.8), v(13.4, 53.0, -17.8), 2.2, 2.2, BONE_D)
			tine(a3, v(11.6, 51.2, -21.0), v(12.0, 54.4, -23.6), 1.6, BONE, true) -- crown tine (up/forward)
			tine(a3, v(12.6, 52.0, -19.6), v(17.4, 53.6, -19.8), 1.4, BONE, true) -- crown tine (out)
			tine(a3, v(13.2, 52.8, -18.2), v(14.0, 54.4, -15.6), 1.4, BONE, true) -- beam end
			blossom(a3, 12.2, 52.4, -20.4, 1.4)
			thorn(a3, v(12.4, 52.4, -19.4), v(13.6, 55.0, -20.8), "Thorn3" .. side)
			thorn(a3, v(13.4, 52.6, -18.0), v(16.4, 54.2, -16.4), "Thorn4" .. side)
			local st = B:bone("Strand" .. side, "Antler3" .. side, v(11.8, 51.0, -20.8))
			strand(st, 11.8, 50.8, -20.8, 3.2)
			B:trail(a3, v(14.1, 54.6, -15.4), v(13.4, 53.0, -17.8), { name = "AntlerTrail" .. side, color = { EMER, PINK_L }, life = 0.22, trans = { 0.45, 1 } })
		end)
		local crown = box(head, 30, 10, 12, 0, 48, -23, STONE, { tr = 1, name = "CrownFX" })
		B:emitter(crown, "leaf", { name = "LeafStorm", color = { MOSS_L, "#c8f07a", PINK }, rate = 2, size = { 0.7, 0.7, 0.4 }, speed = { 2, 5 } })

		------------------------------------------------------------------
		-- LEGS: long and powerful. Bark-brown upper with layered armour,
		-- obsidian greaves, shaggy moss fetlock, chunky stone hoof.
		------------------------------------------------------------------
		local function hoof(h, x, z)
			box(h, 6.2, 1.6, 6.4, x, 3.4, z, FUR) -- fetlock shag
			box(h, 6.5, 0.8, 6.7, x, 2.8, z - 0.1, MOSS)
			box(h, 5.8, 2.0, 6.8, x, 1.4, z - 0.4, STONE) -- y0.4..2.4
			box(h, 6.2, 0.6, 7.2, x, 0.3, z - 0.4, STONE_D) -- y0..0.6
			box(h, 6.1, 0.4, 7.1, x, 2.25, z - 0.4, OBSID)
			box(h, 0.6, 1.6, 0.3, x, 1.3, z - 3.9, MOUTH) -- cloven split
		end
		B:sym(function(side)
			-- front leg
			local fu = B:bone("FLeg" .. side, "Chest", v(6.4, 17.5, -10))
			box(fu, 5.8, 9.4, 6.4, 6.5, 13.3, -10.4, BARK) -- y8.6..18
			box(fu, 0.4, 6.6, 5.0, 9.55, 13.4, -10.4, BARK_D)
			box(fu, 5.0, 4.2, 0.8, 6.5, 14.2, -13.9, OBSID)
			box(fu, 3.6, 2.6, 0.6, 6.5, 14.0, -14.5, OBSID_L)
			box(fu, 5.2, 3.0, 0.9, 6.5, 10.2, -14.0, STONE) -- knee guard
			B:spike(fu, v(6.5, 10.6, -14.4), v(6.5, 12.0, -17.0), 1.4, 1.4, BONE)
			local fk = B:bone("FKnee" .. side, "FLeg" .. side, v(6.4, 10, -12.2))
			box(fk, 4.6, 7.8, 4.8, 6.4, 6.3, -10.6, OBSID) -- y2.4..10.2
			box(fk, 4.0, 5.6, 0.8, 6.4, 6.6, -13.3, OBSID_L)
			box(fk, 4.8, 0.6, 5.0, 6.4, 9.2, -10.6, STONE)
			box(fk, 0.4, 4.6, 3.4, 8.75, 6.2, -10.6, OBSID_L)
			neon(fk, 0.3, 2.2, 0.2, 6.4, 6.4, -13.8)
			local fh = B:bone("FHoof" .. side, "FKnee" .. side, v(6.4, 2.5, -10))
			hoof(fh, 6.4, -10)
			local dust = box(fh, 5, 0.3, 6, 6.4, 0.15, -10.4, STONE, { tr = 1, name = "HoofFX" .. side })
			B:emitter(dust, "dust", { name = "Dust" .. side, color = { "#cbbd98", "#9c8f70" }, size = { 2.5, 4.5, 6 }, speed = { 8, 15 }, life = { 0.7, 1.3 }, spread = 85 })
			B:trail(fh, v(6.4, 0.4, -14.0), v(6.4, 2.6, -13.8), { name = "HoofTrail" .. side, color = { EMER, MOSS_L }, life = 0.2, trans = { 0.55, 1 } })

			-- hind leg
			local hu = B:bone("HLeg" .. side, "Body", v(6.2, 17, 11))
			box(hu, 6.2, 9.6, 7.4, 6.3, 13.2, 11.2, BARK) -- y8.4..18
			sidePlates(hu, 9.4, 13.8, 11.2, 5.6, 6.0, {})
			local hk = B:bone("HKnee" .. side, "HLeg" .. side, v(6.2, 9.5, 13.4))
			box(hk, 4.6, 7.2, 4.8, 6.2, 6.0, 11.6, OBSID) -- y2.4..9.6
			box(hk, 4.0, 5.0, 0.8, 6.2, 6.0, 8.9, OBSID_L)
			box(hk, 0.4, 4.6, 3.4, 8.55, 6.0, 11.6, OBSID_L)
			box(hk, 4.8, 0.6, 5.0, 6.2, 8.8, 11.6, STONE)
			B:spike(hk, v(6.2, 8.6, 13.8), v(6.2, 10.6, 16.6), 1.5, 1.5, BONE) -- hock thorn
			local hh = B:bone("HHoof" .. side, "HKnee" .. side, v(6.2, 2.5, 11))
			hoof(hh, 6.2, 11)
			B:trail(hh, v(6.2, 0.4, 7.2), v(6.2, 2.6, 7.4), { name = "HindTrail" .. side, color = { EMER, MOSS_L }, life = 0.18, trans = { 0.6, 1 } })
		end)
		local hindFX = box("Root", 15, 0.3, 12, 0, 0.15, 11, STONE, { tr = 1, name = "HindFX" })
		B:emitter(hindFX, "dust", { name = "HindDust", color = { "#cbbd98", "#9c8f70" }, size = { 2.5, 4.5, 6 }, speed = { 8, 14 }, life = { 0.7, 1.2 }, spread = 85 })
		local quake = box("Root", 22, 0.3, 16, 0, 0.15, -12, STONE, { tr = 1, name = "QuakeFX" })
		B:emitter(quake, "dust", { name = "QuakeDust", color = { "#d6c9a6", "#9c8f70" }, size = { 4, 7, 9 }, speed = { 14, 26 }, life = { 0.9, 1.7 }, spread = 88, trans = { 0.3, 0.5, 1 } })

		------------------------------------------------------------------
		-- QUAKE ROCKS: ring of mossy stone slabs bursting out of the ground
		------------------------------------------------------------------
		local SC = v(0, 0.6, -11)
		for k = 1, 14 do
			local a = (k - 1) / 14 * 360
			local rb = B:bone("Rock" .. k, "Root", SC)
			local at = CFrame.new(SC) * P.ang(0, a, 0) * CFrame.new(0, 0, -4.0) * P.ang(-18, 0, 0)
			B:block(rb, v(3.0, 1.5, 2.0), at, k % 2 == 0 and STONE or STONE_D, { tr = 1, name = "Rock" .. k })
			local glow = k % 3 == 0
			B:block(rb, v(2.4, 0.5, 1.6), at * CFrame.new(0, 0.95, 0), glow and EMER or MOSS, { mat = glow and "Neon" or "Plastic", tr = 1, name = "RockTop" .. k })
		end

		------------------------------------------------------------------
		-- SPIRIT WISPS: obsidian voxel cubes with moss caps + an emerald band
		------------------------------------------------------------------
		B:bone("Orbit", "Root", v(0, 20, 0))
		local spots = {
			{ 19, 11, -10, 2.6 }, { -19.5, 16, -2, 2.2 }, { 17, 28, 10, 2.0 },
			{ -16, 31, -16, 2.4 }, { 4, 8, 22, 2.2 }, { -10, 25, 20, 1.8 },
		}
		for i, s in spots do
			local p = v(s[1], s[2], s[3])
			local ob = B:bone("Orb" .. i, "Orbit", p)
			local z = s[4]
			B:block(ob, v(z, z, z), CFrame.new(p), i % 2 == 0 and OBSID_L or BARK)
			B:block(ob, v(z + 0.1, z * 0.3, z + 0.1), CFrame.new(p + v(0, z * 0.36, 0)), MOSS)
			B:block(ob, v(z + 0.16, z * 0.14, z + 0.16), CFrame.new(p + v(0, -z * 0.1, 0)), EMER, { mat = "Neon" })
		end
	end,
}
