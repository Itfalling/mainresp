--!nocheck
-- Crystal Narwhal (Legendary, Atlantis) - a HYPER & CHEERFUL puppy of a narwhal.
-- Rebuilt from scratch around a sculpted cartoon HEAD: a stepped melon
-- forehead that overhangs two big sparkly eyes (white, dark rim, big pupil,
-- neon glints) with arched brows, round cheek pads with blush, a short
-- stepped snout and ONE real hinged jaw: a happy "D" smile with a dark
-- interior, a pink tongue (own bone for "bleps"), four clean upper teeth and
-- two lower ones, U-stepped lower lip and upturned corners.
-- Periwinkle body with an indigo back, cream belly, narwhal mottles, gold
-- orichalcum collar and rune plates. On the forehead sits a stepped marble
-- Atlantis ring holding the long twisted turquoise-crystal tusk wrapped in a
-- gold spiral, with a little gold ring orbiting it. On the back: a ruined
-- marble shrine (columns, broken lintel) with a crystal cluster bursting out.
-- Crystal spikes run down the back to stepped flukes.
-- Hidden extras for the motion: blink lids, "^ ^" happy-squint carets, star
-- pupils, a wink, hearts, blowhole spout cubes, the tusk beam, crystal rays,
-- firework shards and splash water cubes.
return {
	DisplayName = "Crystal Narwhal",
	Rarity = "Legendary",
	Element = "Atlantis",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad, cos, sin = math.rad, math.cos, math.sin

		-- palette
		local MAIN, SHADE, DEEP, LIGHT = "#a3a9ff", "#6c70e0", "#4743ad", "#cfd3ff"
		local BELLY, BELLY2 = "#f7f2ea", "#ddd3c2"
		local GOLD, DGOLD = "#f2c14e", "#c98d26"
		local MARBLE, MARBLE2 = "#f4f0e8", "#d4ccbb"
		local TURQ, LTURQ, DTEAL = "#2ec4b6", "#8af0e6", "#15858c"
		local MOUTH, TONGUE, TONGUE2 = "#2a0f22", "#ff6f9a", "#ffa3c0"
		local TEETH, EYEW, PUPIL, RIM = "#ffffff", "#ffffff", "#141b3d", "#26206b"
		local BLUSH, CORAL, WEED = "#ff8fb5", "#ff7a5c", "#3fae6a"
		local WATER, WATER2 = "#8fe6ff", "#d9f8ff"
		local NTURQ, NGOLD = "#3ff0e0", "#ffe27a" -- the two small neon accents
		local NEON = { mat = "Neon" }

		local function bx(bone, sx, sy, sz, x, y, z, col, opts)
			return B:block(bone, v(sx, sy, sz), cf(x, y, z), col, opts)
		end
		local function bxr(bone, sx, sy, sz, x, y, z, rx, ry, rz, col, opts)
			return B:block(bone, v(sx, sy, sz), cf(x, y, z, rx, ry, rz), col, opts)
		end

		-- stepped body segment: rounded-octagon voxel profile, colour blocked
		-- (cream belly, periwinkle flank, indigo saddle + back, deep ridge)
		local function seg(bone, z0, z1, yc, w, h, o)
			o = o or {}
			local L, zc = z1 - z0, (z0 + z1) / 2
			local y0, y1 = yc - h / 2, yc + h / 2
			local inner = h - 2
			local bh = inner * 0.36
			local sh = inner * 0.3
			local mh = inner - bh - sh
			bx(bone, w - 2, 1, L, 0, y0 + 0.5, zc, BELLY)
			bx(bone, w, bh, L, 0, y0 + 1 + bh / 2, zc, BELLY)
			bx(bone, w, mh, L, 0, y0 + 1 + bh + mh / 2, zc, MAIN)
			bx(bone, w, sh, L, 0, y1 - 1 - sh / 2, zc, SHADE)
			bx(bone, w - 2, 1, L, 0, y1 - 0.5, zc, SHADE)
			if not o.noRidge then bx(bone, w - 4.4, 0.5, L - 0.8, 0, y1 + 0.25, zc, DEEP) end
			if not o.noKeel then bx(bone, w - 4.4, 0.5, L - 0.8, 0, y0 - 0.25, zc, BELLY2) end
			if o.trim then bx(bone, w + 0.12, 0.3, L - 0.3, 0, y0 + 1 + bh, zc, GOLD) end
		end

		-- crystal cluster: {x,y,z, width, height, rx,ry,rz, colour, neonTip}
		local function crystals(bone, list)
			for _, c in list do
				local s, hgt = c[4], c[5]
				local C = CFrame.new(v(c[1], c[2], c[3])) * ang(c[6], c[7], c[8])
				B:block(bone, v(s, hgt, s), C * CFrame.new(0, hgt / 2, 0), c[9])
				B:block(bone, v(s * 0.62, hgt * 0.35, s * 0.62), C * CFrame.new(0, hgt + hgt * 0.15, 0), c[9] == TURQ and LTURQ or TURQ)
				if c[10] then
					B:block(bone, v(s * 0.36, s * 0.36, s * 0.36), C * CFrame.new(0, hgt * 1.36, 0), NTURQ, NEON)
				end
			end
		end

		------------------------------------------------------------------
		-- BODY (chest, belly, rear) + gold collar + rune plates
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 9.6, -1))
		seg(body, -6, -1, 9.8, 10.4, 8.6, { trim = true })
		seg(body, -1, 4, 9.9, 9.6, 8.0, { trim = true })
		seg(body, 4, 7.4, 10.1, 7.8, 6.8)

		-- orichalcum collar between head and chest (gold rim + marble studs)
		bx(body, 11.2, 7.6, 0.8, 0, 9.6, -5.6, GOLD)
		bx(body, 9.0, 10.0, 0.8, 0, 9.6, -5.6, GOLD)
		bx(body, 9.6, 8.8, 0.9, 0, 9.6, -5.62, DGOLD)
		B:sym(function()
			bx(body, 0.6, 1.6, 1.4, 5.65, 10.2, -5.6, MARBLE)
			bx(body, 0.2, 0.6, 0.6, 5.98, 10.2, -5.6, NTURQ, NEON)
		end)
		bx(body, 1.6, 0.6, 1.4, 0, 14.65, -5.6, MARBLE)

		-- rune plates on the flanks (marble, gold frame, neon glyph)
		B:sym(function()
			bx(body, 0.3, 3.6, 4.0, 4.97, 9.4, 1.5, GOLD)
			bx(body, 0.4, 3.0, 3.4, 5.08, 9.4, 1.5, MARBLE)
			bx(body, 0.12, 1.8, 0.3, 5.32, 9.4, 1.5, NTURQ, NEON)
			bx(body, 0.12, 0.3, 1.6, 5.32, 9.9, 1.5, NTURQ, NEON)
			bx(body, 0.12, 0.3, 0.9, 5.32, 8.8, 1.85, NTURQ, NEON)
			-- narwhal mottles (deep indigo patches on the flanks / back)
			bx(body, 0.16, 0.9, 1.2, 5.24, 11.4, -3.2, DEEP)
			bx(body, 0.16, 0.7, 0.8, 5.24, 12.2, -1.8, DEEP)
			bx(body, 0.16, 0.8, 1.0, 3.94, 11.6, 5.6, DEEP)
			bx(body, 1.0, 0.16, 0.9, 2.6, 13.7, -2.6, LIGHT)
			-- barnacles on the belly flank
			bx(body, 0.5, 0.7, 0.8, 4.0, 7.4, 5.2, MARBLE2)
			bx(body, 0.2, 0.3, 0.3, 4.26, 7.5, 5.2, DEEP)
		end)

		-- back crystal spikes (chest/rear) and flank crystal growths
		crystals(body, {
			{ 0, 13.3, 5.6, 1.3, 2.4, 22, 45, 0, TURQ, true },
			{ 0, 13.2, 6.9, 0.9, 1.4, 35, 45, 0, LTURQ, false },
		})
		B:sym(function()
			crystals(body, {
				{ 4.3, 11.8, 4.6, 1.0, 1.8, 0, 30, -40, TURQ, true },
				{ 4.5, 11.0, 5.6, 0.7, 1.1, 10, 20, -60, LTURQ, false },
				{ 4.8, 12.6, -3.8, 0.8, 1.4, -15, 15, -35, LTURQ, true },
			})
		end)

		-- ambient effects carrier
		local fx = bx(body, 5, 5, 5, 0, 10, 0, MAIN, { tr = 1, name = "BodyFX" })
		B:emitter(fx, "bubble", { name = "AmbientBubbles", color = { "#ffffff", WATER }, rate = 2.5, size = { 0.25, 0.45, 0.55 } })
		B:emitter(fx, "burst", { name = "GiggleBurst", color = { "#ffffff", BLUSH, NGOLD }, speed = { 6, 12 }, size = { 0.8, 0.5, 0 } })

		------------------------------------------------------------------
		-- HEAD: sculpted cartoon head (melon, brow ridge, cheeks, muzzle)
		------------------------------------------------------------------
		local head = B:bone("Head", "Body", v(0, 9.6, -5.6))
		-- cranium (cross section = rounded stepped box)
		bx(head, 11.4, 7.5, 7.6, 0, 9.9, -9.4, MAIN)
		bx(head, 9.4, 9.5, 7.6, 0, 9.9, -9.4, MAIN)
		bx(head, 8.6, 7.5, 0.8, 0, 9.9, -13.6, MAIN) -- front step (face plane z -14)
		-- indigo back + top
		bx(head, 11.5, 2.0, 7.4, 0, 12.7, -9.3, SHADE)
		bx(head, 9.5, 1.2, 7.4, 0, 14.1, -9.3, SHADE)
		bx(head, 6.4, 0.9, 6.4, 0, 15.05, -9.6, SHADE) -- crown step
		bx(head, 4.2, 0.6, 4.0, 0, 15.75, -9.3, DEEP)
		bx(head, 1.4, 0.15, 0.6, 0, 16.08, -8.4, MOUTH) -- blowhole
		-- cream throat / underside
		bx(head, 8.0, 1.0, 7.0, 0, 5.0, -9.0, BELLY)
		bx(head, 11.5, 1.6, 7.0, 0, 6.85, -9.3, BELLY)
		bx(head, 11.6, 0.3, 7.1, 0, 7.75, -9.3, GOLD) -- gold circlet line
		-- MELON forehead: bulges forward over the eyes (brow ridge)
		bx(head, 7.0, 3.4, 2.4, 0, 13.7, -14.6, MAIN)
		bx(head, 5.0, 2.6, 1.0, 0, 13.9, -16.2, MAIN)
		bx(head, 3.0, 1.6, 0.6, 0, 14.1, -16.9, LIGHT)
		bx(head, 6.6, 0.5, 2.2, 0, 15.45, -14.4, SHADE)
		bx(head, 7.1, 0.4, 2.5, 0, 12.05, -14.6, LIGHT) -- brow ridge
		-- nose bridge, cream puppy MUZZLE (snout + cheek pads)
		bx(head, 1.6, 3.4, 1.4, 0, 10.2, -14.6, MAIN)
		bx(head, 6.6, 2.0, 2.4, 0, 7.6, -15.3, BELLY) -- upper muzzle
		bx(head, 2.4, 0.7, 1.8, 0, 8.9, -15.5, BELLY) -- snout top step
		bx(head, 1.2, 0.35, 0.12, 0, 8.3, -16.55, BELLY2) -- muzzle crease
		bx(head, 6.7, 0.3, 2.45, 0, 6.7, -15.3, SHADE) -- upper lip line
		-- mouth cavity on the head: dark roof, back wall, side walls
		bx(head, 6.0, 0.3, 4.4, 0, 6.45, -13.9, MOUTH)
		bx(head, 6.0, 2.8, 0.4, 0, 5.3, -11.7, MOUTH)
		B:sym(function()
			bx(head, 0.3, 2.2, 4.2, 2.95, 5.5, -13.8, MOUTH)
			-- upturned smile corners tucked under the cheeks
			bxr(head, 0.55, 1.2, 0.7, 3.45, 6.65, -15.45, 0, 0, 32, MOUTH)
		end)
		-- four clean upper teeth
		for _, x in { -1.65, -0.55, 0.55, 1.65 } do
			bx(head, 0.85, 0.8, 0.5, x, 6.2, -16.05, TEETH)
		end
		-- cheeks: side bulges + cream front pads with blush (own bones: they puff)
		B:sym(function(side)
			local ck = B:bone("Cheek" .. side, "Head", v(4.0, 7.6, -13.5))
			bx(ck, 1.4, 3.0, 3.6, 5.4, 7.7, -12.2, MAIN)
			bx(ck, 2.0, 2.0, 1.4, 4.1, 7.6, -14.7, BELLY)
			bx(ck, 1.4, 0.6, 0.1, 4.15, 7.95, -15.44, BLUSH)
			bx(ck, 1.8, 0.9, 0.1, 4.15, 7.95, -15.5, BLUSH, { tr = 1, name = "BlushBig" .. side })
		end)
		-- head crystals (little crown behind the melon) + head mottles
		crystals(head, {
			{ 1.7, 15.3, -7.0, 0.9, 1.6, 25, 45, -20, TURQ, true },
			{ -1.7, 15.3, -7.0, 0.9, 1.6, 25, 45, 20, TURQ, true },
			{ 0, 15.8, -6.6, 1.0, 2.2, 30, 45, 0, LTURQ, true },
		})
		B:sym(function(side)
			-- Atlantis medallion on each side of the head (gold rim, marble, rune)
			bx(head, 0.3, 2.4, 2.4, 5.75, 10.4, -9.6, GOLD)
			bx(head, 0.4, 1.8, 1.8, 5.85, 10.4, -9.6, MARBLE)
			bx(head, 0.12, 1.0, 0.25, 6.08, 10.4, -9.6, NTURQ, NEON)
			bx(head, 0.12, 0.25, 1.0, 6.08, 10.6, -9.6, NTURQ, NEON)
			bx(head, 0.16, 0.9, 1.2, 5.78, 12.4, -6.8, DEEP)
			bx(head, 0.16, 0.6, 0.8, 5.78, 8.9, -6.6, DEEP)
			-- floppy ear-fins (puppy ears!) with gold tips
			local EF = CFrame.new(5.2, 13.8, -9.0) * ang(0, 45, 18)
			local ear = B:bone("Ear" .. side, "Head", EF)
			B:block(ear, v(1.6, 0.8, 2.4), EF * CFrame.new(0.6, 0, 0), SHADE)
			B:block(ear, v(1.6, 0.7, 2.2), EF * CFrame.new(1.9, 0, 0.4), MAIN)
			B:block(ear, v(1.2, 0.75, 1.3), EF * CFrame.new(1.9, 0.05, 0.3), LIGHT)
			B:block(ear, v(1.2, 0.6, 1.6), EF * CFrame.new(3.0, 0, 0.9), MAIN)
			B:block(ear, v(0.7, 0.65, 1.0), EF * CFrame.new(3.75, 0, 1.3), GOLD)
		end)

		------------------------------------------------------------------
		-- EYES: big sparkly googly eyes (front face only - no wrap)
		------------------------------------------------------------------
		B:sym(function(side)
			local E = v(2.6, 10.0, -14.3)
			local eye = B:bone("Eye" .. side, "Head", E)
			bx(eye, 3.5, 3.0, 0.9, 2.6, 10.0, -14.55, RIM)
			bx(eye, 2.9, 3.7, 0.9, 2.6, 10.0, -14.55, RIM)
			bx(eye, 3.1, 2.6, 0.9, 2.6, 10.0, -14.85, EYEW, { name = "ScleraA" .. side })
			bx(eye, 2.5, 3.3, 0.9, 2.6, 10.0, -14.87, EYEW, { name = "ScleraB" .. side })
			local pup = B:bone("Pupil" .. side, "Eye" .. side, v(2.5, 9.85, -15.25))
			bx(pup, 1.5, 1.9, 0.2, 2.5, 9.8, -15.36, PUPIL, { name = "PupilBig" .. side })
			bx(pup, 0.9, 0.9, 0.1, 2.5, 9.45, -15.48, "#3350b8", { name = "Iris" .. side })
			-- star pupils (sparkle eyes, hidden)
			bx(pup, 0.5, 2.0, 0.2, 2.5, 9.85, -15.5, NGOLD, { mat = "Neon", tr = 1, name = "StarA" .. side })
			bx(pup, 2.0, 0.5, 0.2, 2.5, 9.85, -15.51, NGOLD, { mat = "Neon", tr = 1, name = "StarB" .. side })
			bxr(pup, 0.9, 0.9, 0.2, 2.5, 9.85, -15.52, 0, 0, 45, NGOLD, { mat = "Neon", tr = 1, name = "StarC" .. side })
			-- lid: skin cover + lash line (blink) / "^" carets (happy squint)
			local lid = B:bone("Lid" .. side, "Eye" .. side, E)
			bx(lid, 3.6, 3.8, 0.5, 2.6, 10.0, -15.35, MAIN, { tr = 1, name = "LidSkin" .. side })
			bx(lid, 2.8, 0.45, 0.2, 2.6, 9.6, -15.7, RIM, { tr = 1, name = "Lash" .. side })
			bxr(lid, 1.7, 0.55, 0.2, 1.95, 10.05, -15.7, 0, 0, 35, RIM, { tr = 1, name = "CaretA" .. side })
			bxr(lid, 1.7, 0.55, 0.2, 3.25, 10.05, -15.71, 0, 0, -35, RIM, { tr = 1, name = "CaretB" .. side })
			-- arched brow on the brow ridge
			local brow = B:bone("Brow" .. side, "Head", v(2.9, 12.7, -15.9))
			bxr(brow, 1.4, 0.6, 0.6, 2.35, 12.75, -15.95, 0, 0, -14, RIM)
			bxr(brow, 1.4, 0.6, 0.6, 3.55, 12.65, -15.97, 0, 0, 16, RIM)
		end)
		-- glints: same side on both eyes (not mirrored)
		bx("PupilR", 0.6, 0.6, 0.1, 2.1, 10.35, -15.5, "#ffffff", { mat = "Neon", name = "GlintR" })
		bx("PupilR", 0.3, 0.3, 0.1, 2.95, 9.15, -15.5, NTURQ, { mat = "Neon", name = "Glint2R" })
		bx("PupilL", 0.6, 0.6, 0.1, -2.9, 10.35, -15.5, "#ffffff", { mat = "Neon", name = "GlintL" })
		bx("PupilL", 0.3, 0.3, 0.1, -2.05, 9.15, -15.5, NTURQ, { mat = "Neon", name = "Glint2L" })

		------------------------------------------------------------------
		-- JAW: ONE real hinged "D" smile (U lip, dark floor, teeth, tongue)
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", v(0, 6.3, -11.4))
		bx(jaw, 6.2, 1.6, 5.0, 0, 4.85, -13.7, MAIN)
		bx(jaw, 4.8, 0.8, 4.6, 0, 3.75, -13.9, BELLY) -- rounded chin underside
		bx(jaw, 4.4, 1.5, 0.5, 0, 4.75, -16.35, BELLY) -- chin front
		bx(jaw, 2.8, 0.6, 0.5, 0, 3.75, -16.3, BELLY)
		bx(jaw, 5.6, 0.3, 4.6, 0, 5.65, -13.6, MOUTH) -- floor
		bx(jaw, 5.6, 1.4, 0.3, 0, 6.2, -11.6, MOUTH) -- back
		B:sym(function()
			bx(jaw, 0.3, 1.0, 4.4, 2.95, 6.1, -13.7, MOUTH)
			-- U-stepped lower lip: middle rises toward the corners
			bx(jaw, 1.2, 0.75, 0.6, 1.95, 5.9, -15.95, BELLY)
			bx(jaw, 0.8, 1.15, 0.6, 2.9, 6.1, -15.75, BELLY)
			bx(jaw, 0.6, 0.6, 0.45, 1.75, 6.5, -15.75, TEETH) -- lower tooth
		end)
		bx(jaw, 2.8, 0.55, 0.6, 0, 5.6, -16.0, BELLY)
		local tongue = B:bone("Tongue", "Jaw", v(0, 5.9, -13.0))
		bx(tongue, 3.0, 0.5, 2.8, 0, 5.95, -14.0, TONGUE)
		bx(tongue, 2.2, 0.45, 1.0, 0, 6.0, -15.6, TONGUE2)
		bx(tongue, 0.25, 0.1, 1.6, 0, 6.22, -14.4, "#e0507c")
		local mfx = bx(jaw, 1.5, 1, 1, 0, 6, -15.5, MOUTH, { tr = 1, name = "MouthFX" })
		B:emitter(mfx, "bubble", { name = "Giggles", color = { "#ffffff", WATER }, rate = 0, size = { 0.4, 0.6, 0.7 }, speed = { 4, 8 }, spread = 35, dir = "Front", life = { 0.8, 1.4 } })

		------------------------------------------------------------------
		-- TUSK: marble Atlantis ring + twisted crystal tusk with gold spiral
		------------------------------------------------------------------
		local TB = v(0, 14.1, -17.1)
		local TF = CFrame.new(TB) * ang(27, 0, 0) -- local -Z runs up the tusk
		-- marble ring collar (on the head)
		B:block(head, v(3.0, 3.0, 0.6), TF * CFrame.new(0, 0, 0.3), MARBLE2)
		local RF = TF * CFrame.new(0, 0, -0.35) * ang(90, 0, 0)
		B:ring(head, RF, 1.3, 8, v(1.1, 1.0, 0.9), MARBLE)
		for k = 0, 3 do
			local a = rad(45 + k * 90)
			B:block(head, v(0.45, 0.45, 0.3), TF * CFrame.new(1.3 * cos(a), 1.3 * sin(a), -0.85), GOLD)
			local b2 = rad(k * 90)
			B:block(head, v(0.3, 0.3, 0.2), TF * CFrame.new(1.3 * cos(b2), 1.3 * sin(b2), -0.83), NTURQ, NEON)
		end
		local tusk = B:bone("Tusk", "Head", TF)
		local LEN, N = 10.6, 9
		B:block(tusk, v(1.7, 1.7, 0.5), TF * CFrame.new(0, 0, -0.6), GOLD) -- gold base band
		for i = 0, N - 1 do
			local d0 = 0.2 + i * LEN / N
			local w = 1.45 - i * 0.11
			local sc = TF * CFrame.new(0, 0, -(d0 + LEN / N / 2)) * ang(0, 0, i * 20)
			B:block(tusk, v(w, w, LEN / N + 0.05), sc, (i % 2 == 0) and TURQ or LTURQ)
			-- gold spiral groove: one strip per segment, winding round the tusk
			local a = rad(i * 62)
			B:block(tusk, v(0.36, 0.36, LEN / N + 0.1), TF * CFrame.new((w / 2) * cos(a), (w / 2) * sin(a), -(d0 + LEN / N / 2)) * ang(0, 0, i * 62), GOLD)
		end
		local tipD = 0.2 + LEN
		B:block(tusk, v(0.5, 0.5, 0.9), TF * CFrame.new(0, 0, -(tipD + 0.4)), NTURQ, NEON)
		B:block(tusk, v(0.3, 0.3, 0.6), TF * CFrame.new(0, 0, -(tipD + 1.05)), "#ffffff", NEON)
		local tipP = (TF * CFrame.new(0, 0, -(tipD + 1.0))).Position
		B:trail(tusk, (TF * CFrame.new(0.4, 0, -(tipD + 0.6))).Position, (TF * CFrame.new(-0.4, 0, -(tipD + 0.6))).Position,
			{ name = "TuskTrail", color = { "#ffffff", NTURQ }, life = 0.3, trans = { 0.3, 1 } })
		local tfx = B:block(tusk, v(0.8, 0.8, 0.8), CFrame.new(tipP), TURQ, { tr = 1, name = "TuskFX" })
		B:light(tfx, { name = "TuskLight", color = NTURQ, brightness = 0.4, range = 12 })
		B:emitter(tfx, "spark", { name = "TuskSparks", color = { "#ffffff", NTURQ }, rate = 0 })
		-- hidden tusk beam (revealed during the spin)
		B:block(tusk, v(0.7, 0.7, 10), TF * CFrame.new(0, 0, -(tipD + 6.0)), "#ffffff", { mat = "Neon", tr = 1, name = "BeamCore" })
		B:block(tusk, v(1.4, 1.4, 9.6), TF * CFrame.new(0, 0, -(tipD + 5.8)), NTURQ, { mat = "Neon", tr = 1, name = "BeamGlow" })
		B:block(tusk, v(2.0, 2.0, 0.5), TF * CFrame.new(0, 0, -(tipD + 1.6)), NTURQ, { mat = "Neon", tr = 1, name = "BeamRing" })
		-- little orichalcum ring orbiting the tusk
		local ring = B:bone("TuskRing", "Tusk", TF * CFrame.new(0, 0, -5.5))
		B:ring(ring, TF * CFrame.new(0, 0, -5.5) * ang(90, 0, 0), 1.15, 6, v(0.75, 0.35, 0.35), GOLD)
		B:block(ring, v(0.3, 0.3, 0.3), TF * CFrame.new(0, 1.2, -5.5), NGOLD, NEON)
		B:block(ring, v(0.3, 0.3, 0.3), TF * CFrame.new(0, -1.2, -5.5), NGOLD, NEON)
		------------------------------------------------------------------
		-- TAIL: stepped segments -> horizontal stepped flukes
		------------------------------------------------------------------
		local t1 = B:bone("Tail1", "Body", v(0, 10.2, 7.2))
		seg(t1, 7.2, 10.2, 10.3, 6.4, 5.8)
		crystals(t1, { { 0, 13.4, 8.6, 1.0, 1.8, 30, 45, 0, TURQ, true } })
		local t2 = B:bone("Tail2", "Tail1", v(0, 10.5, 10.0))
		seg(t2, 10.0, 12.6, 10.6, 4.8, 4.4)
		bx(t2, 5.0, 0.3, 0.6, 0, 10.6, 10.4, GOLD) -- gold tail band
		bx(t2, 4.0, 4.6, 0.6, 0, 10.6, 10.4, GOLD)
		crystals(t2, { { 0, 12.9, 11.6, 0.8, 1.3, 30, 45, 0, LTURQ, true } })
		local t3 = B:bone("Tail3", "Tail2", v(0, 10.7, 12.4))
		seg(t3, 12.4, 14.4, 10.8, 3.2, 3.2, { noRidge = true, noKeel = true })
		local fl = B:bone("Fluke", "Tail3", v(0, 10.8, 14.2))
		bx(fl, 2.6, 1.6, 1.8, 0, 10.8, 15.0, SHADE)
		bx(fl, 1.0, 0.9, 1.0, 0, 10.8, 16.1, DEEP)
		B:sym(function(side)
			local lobe = B:bone("Lobe" .. side, "Fluke", v(1.0, 10.8, 15.0))
			bx(lobe, 3.0, 0.9, 2.6, 2.3, 10.8, 15.6, SHADE)
			bx(lobe, 2.7, 0.8, 2.4, 4.6, 10.8, 16.4, MAIN)
			bx(lobe, 2.0, 0.7, 2.0, 6.4, 10.8, 17.3, MAIN)
			bx(lobe, 1.2, 0.6, 1.4, 7.6, 10.8, 18.1, LIGHT)
			bx(lobe, 3.6, 0.95, 0.4, 4.2, 10.8, 17.65, GOLD) -- gold trailing edge
			bx(lobe, 0.5, 0.5, 0.5, 8.2, 10.8, 18.7, NTURQ, NEON)
			B:trail(lobe, v(8.2, 11.1, 18.7), v(8.2, 10.5, 18.7), { name = "FlukeTrail" .. side, color = { "#ffffff", NTURQ }, life = 0.25, trans = { 0.5, 1 } })
		end)

		------------------------------------------------------------------
		-- FLIPPERS: chunky paddles with gold + marble cuffs and crystal tips
		------------------------------------------------------------------
		B:sym(function(side)
			local FR = CFrame.new(4.6, 7.6, -3.0) * ang(0, -32, -18)
			local fp = B:bone("Flipper" .. side, "Body", FR)
			B:block(fp, v(2.4, 1.5, 2.6), FR * CFrame.new(1.0, 0, 0), MAIN)
			B:block(fp, v(2.0, 0.4, 2.2), FR * CFrame.new(1.0, -0.8, 0), BELLY)
			B:block(fp, v(0.5, 1.8, 2.8), FR * CFrame.new(1.9, 0, 0), GOLD)
			B:block(fp, v(0.4, 1.6, 2.7), FR * CFrame.new(2.35, 0, 0), MARBLE)
			B:block(fp, v(0.12, 0.4, 0.4), FR * CFrame.new(2.35, 0.82, 0), NTURQ, NEON)
			local tf = FR * CFrame.new(2.4, 0, 0)
			local tip = B:bone("FlipperTip" .. side, "Flipper" .. side, tf)
			B:block(tip, v(2.4, 1.1, 2.6), FR * CFrame.new(3.6, 0, 0.2), MAIN)
			B:block(tip, v(2.0, 0.3, 2.2), FR * CFrame.new(3.6, -0.6, 0.2), BELLY)
			B:block(tip, v(1.8, 0.9, 2.0), FR * CFrame.new(5.4, 0, 0.6), SHADE)
			B:block(tip, v(1.2, 0.7, 1.3), FR * CFrame.new(6.7, 0, 1.0), LIGHT)
			B:block(tip, v(0.45, 0.45, 0.45), FR * CFrame.new(7.4, 0, 1.3), NTURQ, NEON)
			B:trail(tip, (FR * CFrame.new(7.4, 0.3, 1.3)).Position, (FR * CFrame.new(7.4, -0.3, 1.3)).Position,
				{ name = "FlipTrail" .. side, color = { "#ffffff", NTURQ }, life = 0.2, trans = { 0.55, 1 } })
		end)

		------------------------------------------------------------------
		-- SHRINE: little ruined marble temple with a crystal heart
		------------------------------------------------------------------
		local shrine = B:bone("Shrine", "Body", v(0, 14.4, 1.2))
		bx(shrine, 7.4, 0.4, 6.2, 0, 14.45, 1.2, GOLD)
		bx(shrine, 7.0, 0.8, 5.8, 0, 15.05, 1.2, MARBLE)
		bx(shrine, 5.6, 0.7, 4.6, 0, 15.8, 1.2, MARBLE2)
		bx(shrine, 1.2, 0.5, 0.1, 0, 15.05, -1.75, DTEAL)
		bx(shrine, 0.6, 0.15, 0.1, 0, 15.15, -1.82, NTURQ, NEON)
		bx(shrine, 0.15, 0.4, 0.1, 0, 15.0, -1.82, NTURQ, NEON)
		-- columns: {x, z, shaft height, broken}
		local COLS = { { 2.1, -0.5, 2.8 }, { -2.1, -0.5, 2.8 }, { -2.1, 2.9, 2.8 }, { 2.1, 2.9, 1.3, true } }
		for _, c in COLS do
			local x, z, hgt = c[1], c[2], c[3]
			bx(shrine, 1.2, 0.4, 1.2, x, 16.35, z, MARBLE)
			bx(shrine, 0.85, hgt, 0.85, x, 16.55 + hgt / 2, z, MARBLE)
			bx(shrine, 0.2, hgt - 0.2, 0.1, x, 16.55 + hgt / 2, z - 0.45, MARBLE2)
			if c[4] then
				bxr(shrine, 0.85, 0.7, 0.85, x + 0.15, 16.55 + hgt + 0.25, z, 0, 20, 18, MARBLE2)
			else
				bx(shrine, 1.35, 0.45, 1.35, x, 16.55 + hgt + 0.22, z, MARBLE)
				bx(shrine, 1.0, 0.2, 1.0, x, 16.55 + hgt - 0.05, z, GOLD)
			end
		end
		-- front lintel with rune frieze, broken back fragment
		bx(shrine, 5.6, 0.7, 1.5, 0, 20.0, -0.5, MARBLE)
		bx(shrine, 5.7, 0.25, 1.55, 0, 19.55, -0.5, GOLD)
		bx(shrine, 0.9, 0.4, 0.1, 0, 20.0, -1.27, DTEAL)
		bx(shrine, 0.5, 0.12, 0.1, 0, 20.05, -1.33, NTURQ, NEON)
		bxr(shrine, 2.4, 0.6, 1.3, -1.3, 20.05, 2.9, 0, 8, -10, MARBLE)
		bx(shrine, 1.6, 0.25, 1.35, -1.5, 19.6, 2.9, GOLD)
		-- coral sprig + seaweed on the ruin
		bx(shrine, 0.5, 0.9, 0.5, 2.8, 16.55, 3.2, CORAL)
		bxr(shrine, 0.35, 0.6, 0.35, 3.05, 17.2, 3.2, 0, 0, -25, CORAL)
		bxr(shrine, 0.35, 1.2, 0.35, -3.0, 16.6, 0.2, 0, 0, 12, WEED)
		bxr(shrine, 0.3, 0.8, 0.3, -3.2, 17.5, 0.2, 0, 0, 25, WEED)
		-- crystal heart bursting out of the ruin (own bone: it pulses)
		local sc = B:bone("ShrineCrystal", "Shrine", v(0, 16.0, 1.2))
		crystals(sc, {
			{ 0, 15.9, 1.3, 1.6, 3.4, 0, 45, 0, TURQ, true },
			{ 0.9, 15.9, 1.9, 1.0, 2.2, 18, 30, -22, LTURQ, true },
			{ -0.9, 15.9, 1.7, 1.0, 2.4, -10, 60, 24, TURQ, true },
			{ 0.2, 15.9, 0.3, 0.7, 1.4, -28, 20, -8, LTURQ, false },
		})
		local cfx = bx(sc, 1.2, 1.2, 1.2, 0, 18.5, 1.3, TURQ, { tr = 1, name = "ShrineFX" })
		B:emitter(cfx, "sparkle", { name = "Sparkle", color = { "#ffffff", NGOLD, NTURQ }, rate = 4 })
		B:light(cfx, { name = "ShrineLight", color = NTURQ, brightness = 0.5, range = 12 })

		------------------------------------------------------------------
		-- hidden props: hearts (giggle), crystal rays, blowhole spout cubes
		------------------------------------------------------------------
		B:sym(function(side)
			local H = v(5.6, 15.8, -12.5)
			local hb = B:bone("Heart" .. side, "Head", H)
			bx(hb, 0.7, 0.7, 0.4, 5.25, 16.15, -12.5, BLUSH, { tr = 1, name = "HeartA" .. side })
			bx(hb, 0.7, 0.7, 0.4, 5.95, 16.15, -12.5, BLUSH, { tr = 1, name = "HeartB" .. side })
			bx(hb, 1.4, 0.6, 0.4, 5.6, 15.7, -12.5, BLUSH, { tr = 1, name = "HeartC" .. side })
			bx(hb, 0.6, 0.5, 0.4, 5.6, 15.2, -12.5, BLUSH, { tr = 1, name = "HeartD" .. side })
		end)
		local rays = B:bone("Rays", "Body", v(0, 9.6, -1))
		for i = 1, 8 do
			local a = rad((i - 1) * 45 + 22.5)
			local dir = v(cos(a), sin(a), 0)
			local p0 = v(0, 9.6, -1) + dir * 7.0
			local p1 = v(0, 9.6, -1) + dir * (i % 2 == 0 and 12.5 or 14.5)
			B:beam(rays, p0, p1, 0.75, 0.75, NTURQ, { mat = "Neon", tr = 1, name = "Ray" .. i })
		end
		for k = 1, 5 do
			local S = v(0, 16.2, -8.4)
			local sb = B:bone("Spout" .. k, "Head", S)
			local s = (k % 2 == 1) and 1.0 or 0.75
			B:block(sb, v(s, s, s), CFrame.new(S), k == 1 and WATER2 or "#5fd8ff", { tr = 1, name = "SpoutP" .. k })
		end

		------------------------------------------------------------------
		-- floating orbiting cubes (marble w/ gold band, crystal cubes)
		------------------------------------------------------------------
		local ORBS = { { 9.5, 15.5, -6, 1.4, 1 }, { -9.0, 13.0, -2.0, 1.2, 2 }, { 8.2, 7.0, 6.5, 1.0, 2 }, { -8.0, 17.0, 6.0, 1.1, 1 }, { 0.5, 20.5, -12.0, 0.9, 2 } }
		for i, o in ORBS do
			local ob = B:bone("Orb" .. i, "Root", v(o[1], o[2], o[3]))
			local s = o[4]
			if o[5] == 1 then
				bx(ob, s, s, s, o[1], o[2], o[3], MARBLE)
				bx(ob, s + 0.1, s * 0.25, s + 0.1, o[1], o[2] + s * 0.2, o[3], GOLD)
				bx(ob, 0.3, 0.3, 0.1, o[1], o[2] - s * 0.15, o[3] - s / 2 - 0.03, NTURQ, NEON)
			else
				bx(ob, s, s, s, o[1], o[2], o[3], TURQ)
				bx(ob, s * 0.5, s * 0.5, s + 0.06, o[1], o[2], o[3], LTURQ)
			end
		end

		------------------------------------------------------------------
		-- Crystal Breach VFX: firework shards (apex) + splash water cubes
		------------------------------------------------------------------
		local SH = v(0, 21, -3)
		for i = 1, 14 do
			local sb = B:bone("Shard" .. i, "Root", SH)
			local col = (i % 3 == 0) and NGOLD or ((i % 3 == 1) and NTURQ or LTURQ)
			B:block(sb, v(1.2, 2.6, 1.2), CFrame.new(SH) * ang(0, 45, 0), col, { mat = col ~= LTURQ and "Neon" or nil, tr = 1, name = "ShardP" .. i })
		end
		local fw = B:block("Shard1", v(1, 1, 1), CFrame.new(SH), TURQ, { tr = 1, name = "FireworkFX" })
		B:emitter(fw, "burst", { name = "Firework", color = { "#ffffff", NTURQ, NGOLD }, speed = { 14, 26 }, size = { 1.3, 0.8, 0 }, life = { 0.6, 1.2 } })
		local SP = v(0, 2.2, -4)
		for i = 1, 10 do
			local sb = B:bone("Splash" .. i, "Root", SP)
			local s = (i % 2 == 0) and 1.6 or 1.1
			B:block(sb, v(s, s, s), CFrame.new(SP), (i % 2 == 0) and WATER2 or WATER, { tr = 1, name = "SplashP" .. i })
		end
		local spfx = B:block("Splash1", v(4, 1, 4), CFrame.new(SP), WATER, { tr = 1, name = "SplashFX" })
		B:emitter(spfx, "burst", { name = "SplashBurst", color = { "#ffffff", WATER, NTURQ }, speed = { 10, 20 }, size = { 1.2, 0.8, 0 }, spread = 70, accel = { 0, -25, 0 } })
	end,
}
