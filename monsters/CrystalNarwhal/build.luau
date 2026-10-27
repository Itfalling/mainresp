--!nocheck
-- Crystal Narwhal: a hyper, cheerful Atlantis narwhal, stud-built in the Void
-- Leviathan voxel style. A curved "banana" body: a smaller stepped melon head,
-- a big humped chest carrying a ruined marble crystal SHRINE (columns, gold
-- frieze, crystals erupting through the roof), then a tail that steps down and
-- curls up into horizontal flukes. Pale blue-grey with a darker back saddle,
-- a few big narwhal mottles, white stepped belly/keel, gold orichalcum trims,
-- marble rune cuffs and rune tiles, a row of crystal dorsal spikes and crystal
-- growths on the flanks. Long twisted turquoise-crystal + gold spiral tusk in a
-- marble/gold Atlantis collar. Big happy face: sparkly eyes with star glints,
-- a real hinged "D" smile (white teeth, pink tongue), rosy cheeks.
-- Hidden VFX (tusk beam, star rays, crystal shards, splash cubes, bubble cubes,
-- happy-squint "^ ^" eyes, blink lids) are revealed by the motion.
return {
	DisplayName = "Crystal Narwhal",
	Rarity = "Legendary",
	Element = "Atlantis",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad, cos, sin = math.rad, math.cos, math.sin

		-- palette
		local BODY, DARK, DEEP = "#9fc3d9", "#5f87a3", "#46697f" -- pale blue-grey / dark back / deepest
		local FLECK = "#c9e1ee" -- pale mottles on the dark back
		local WHITE, CREAM = "#f4f8fb", "#dfeaf1" -- belly
		local GOLD, DGOLD = "#f2c14e", "#c98d26" -- orichalcum
		local MARBLE, MARBLE2 = "#f3efe6", "#d9d1c1"
		local TURQ, LTURQ, DTEAL = "#2ec4b6", "#86ece2", "#17878f" -- crystal
		local MOUTH, TONGUE, TONGUE2 = "#2a1020", "#ff7fa8", "#ffa9c6"
		local PUPIL, BLUSH, BROW = "#0f2232", "#ff9fc0", "#3e5d75"
		local CORAL, CORAL2 = "#ff8a6e", "#ffb199"
		local NTURQ, NGOLD = "#3ff0e0", "#ffe27a" -- the two (small) neon accents
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- helpers
		------------------------------------------------------------------
		-- stepped body segment (octagon-ish voxel profile from the side AND the
		-- front): pale core, dark top cap + deep ridge, white belly cap + cream
		-- keel, dark saddle band on the upper sides, white belly band, and a thin
		-- gold orichalcum trim line under the saddle.
		local function segment(bone, z0, z1, yc, w, h, o)
			o = o or {}
			local len, zc = z1 - z0, (z0 + z1) / 2
			local ch = h - 2
			B:block(bone, v(w, ch, len), cf(0, yc, zc), BODY)
			B:block(bone, v(w - 2, 1.0, len - 0.4), cf(0, yc + ch / 2 + 0.5, zc), DARK)
			B:block(bone, v(w - 2, 1.0, len - 0.4), cf(0, yc - ch / 2 - 0.5, zc), WHITE)
			if not o.noRidge then
				B:block(bone, v(w - 4.4, 0.6, len - 1.2), cf(0, yc + h / 2 + 0.3, zc), DEEP)
			end
			if not o.noKeel then
				B:block(bone, v(w - 4.4, 0.6, len - 1.2), cf(0, yc - h / 2 - 0.3, zc), CREAM)
			end
			local sh = ch * 0.36
			local sy = yc + ch / 2 - sh / 2
			B:block(bone, v(w + 0.5, sh, len - 0.2), cf(0, sy, zc), DARK)
			B:block(bone, v(w + 0.4, 1.0, len - 0.3), cf(0, yc - ch / 2 + 0.5, zc), WHITE)
			if not o.noTrim then
				B:block(bone, v(w + 0.6, 0.3, len - 0.1), cf(0, sy - sh / 2 - 0.05, zc), GOLD)
			end
		end
		-- thin colour-block mottle on a side face
		local function spot(bone, x, y, z, sy, sz, col)
			B:block(bone, v(0.16, sy, sz), cf(x, y, z), col)
		end
		-- flipper / fluke frame: local X along `ax`, local Z toward T
		local function frame(pos, ax, T)
			ax = ax.Unit
			local fz = (T - ax * T:Dot(ax)).Unit
			return CFrame.fromMatrix(pos, ax, fz:Cross(ax), fz)
		end
		-- crystal cluster: tilted turquoise blocks with an optional neon tip
		-- {x, y, z, width, height, rx, ry, rz, colour, neonTip}
		local function crystals(bone, base, list)
			for _, c in list do
				local s, hgt = c[4], c[5]
				local C = CFrame.new(base + v(c[1], c[2], c[3])) * ang(c[6], c[7], c[8])
				B:block(bone, v(s, hgt, s), C * CFrame.new(0, hgt / 2, 0), c[9])
				if c[10] then
					B:block(bone, v(s * 0.55, 0.5, s * 0.55), C * CFrame.new(0, hgt + 0.2, 0), NTURQ, NEON)
				end
			end
		end
		-- dorsal crystal spike: leaning back, stepped (base block + lighter tip)
		local function dspike(bone, y, z, s, hgt, lean, neon)
			local C = CFrame.new(0, y, z) * ang(lean, 45, 0)
			B:block(bone, v(s, hgt, s), C * CFrame.new(0, hgt / 2, 0), TURQ)
			B:block(bone, v(s * 0.6, hgt * 0.45, s * 0.6), C * CFrame.new(0, hgt + hgt * 0.18, 0), neon and NTURQ or LTURQ, neon and NEON or nil)
		end

		------------------------------------------------------------------
		-- BODY1: big humped chest (swim chain centre)
		------------------------------------------------------------------
		local body1 = B:bone("Body1", "Root", v(0, 8, -1.5))
		segment(body1, -4.6, 1.2, 8.2, 10.0, 9.8)
		-- marble neck cuff with gold rims + rune dots (Atlantis band)
		B:block(body1, v(10.3, 8.0, 0.9), cf(0, 8.2, -4.0), MARBLE)
		B:block(body1, v(8.3, 9.9, 0.9), cf(0, 8.2, -4.0), MARBLE)
		B:block(body1, v(10.45, 8.15, 0.3), cf(0, 8.2, -3.45), GOLD)
		-- big narwhal mottles (few, bold)
		B:sym(function()
			spot(body1, 5.1, 7.0, -2.5, 1.4, 1.6, DEEP)
			spot(body1, 5.1, 5.75, -1.2, 0.8, 1.0, DARK)
			spot(body1, 5.3, 11.0, -0.6, 0.8, 1.2, FLECK)
			-- carved marble rune tile with a gold frame and a glowing glyph
			B:block(body1, v(0.3, 2.0, 2.0), cf(5.1, 7.3, 0.0), MARBLE)
			B:block(body1, v(0.2, 2.3, 2.3), cf(5.04, 7.3, 0.0), DGOLD)
			B:block(body1, v(0.14, 1.1, 0.3), cf(5.28, 7.3, 0.0), NTURQ, NEON)
			B:block(body1, v(0.14, 0.3, 0.9), cf(5.28, 7.6, 0.0), NTURQ, NEON)
			-- crystal growths bursting out of the flanks
			crystals(body1, v(4.7, 10.4, -2.2), {
				{ 0, 0, 0, 1.0, 2.4, 12, 25, -42, TURQ, true },
				{ 0.1, -0.5, 1.1, 0.7, 1.5, -18, 0, -62, LTURQ, false },
			})
		end)
		-- stepped white belly scales
		B:block(body1, v(4.6, 0.6, 1.5), cf(0, 2.5, -3.0), CREAM)
		B:block(body1, v(5.0, 0.6, 1.5), cf(0, 2.45, -1.4), WHITE)
		B:block(body1, v(4.4, 0.6, 1.4), cf(0, 2.5, 0.1), CREAM)

		-- ATLANTIS CRYSTAL SHRINE on the hump: stepped base, 4 marble columns,
		-- gold frieze, stepped roof, crystals glowing inside + erupting on top
		local SZ = -1.7
		B:block(body1, v(4.6, 0.4, 4.6), cf(0, 13.9, SZ), DGOLD)
		B:block(body1, v(4.0, 0.5, 4.0), cf(0, 14.35, SZ), MARBLE2)
		for _, q in { { 1, 1 }, { -1, 1 }, { 1, -1 }, { -1, -1 } } do
			B:block(body1, v(0.7, 1.7, 0.7), cf(1.45 * q[1], 15.4, SZ + 1.45 * q[2]), MARBLE)
		end
		B:block(body1, v(4.2, 0.35, 4.2), cf(0, 16.4, SZ), GOLD)
		B:block(body1, v(4.6, 0.5, 4.6), cf(0, 16.8, SZ), MARBLE)
		B:block(body1, v(3.2, 0.4, 3.2), cf(0, 17.2, SZ), MARBLE2)
		B:block(body1, v(1.4, 1.8, 1.4), cf(0, 15.4, SZ) * ang(0, 45, 0), TURQ)
		B:block(body1, v(0.7, 0.7, 0.7), cf(0, 15.6, SZ) * ang(0, 45, 0) * CFrame.new(0, 0, -0.55), NTURQ, NEON)
		crystals(body1, v(0, 17.35, SZ), {
			{ 0, 0, 0, 1.2, 2.6, 0, 45, 6, TURQ, true },
			{ 0.8, 0, 0.6, 0.8, 1.7, 10, 20, -30, LTURQ, false },
			{ -0.8, 0, -0.5, 0.75, 1.5, -14, 0, 28, DTEAL, true },
		})
		-- coral tuft + barnacles on the ruin base
		B:block(body1, v(0.5, 0.9, 0.5), cf(2.2, 14.3, SZ - 2.0), CORAL)
		B:block(body1, v(0.4, 0.6, 0.4), cf(2.55, 14.6, SZ - 1.6) * ang(0, 0, -25), CORAL2)
		B:block(body1, v(0.7, 0.4, 0.7), cf(-3.6, 13.25, 0.3), MARBLE2)

		local fx = B:block(body1, v(8, 7, 9), cf(0, 8, -1), BODY, { tr = 1, name = "BodyFX" })
		B:emitter(fx, "sparkle", { name = "AmbientSparkle", color = { "#ffffff", NTURQ, NGOLD }, rate = 4 })
		B:emitter(fx, "burst", { name = "ShardBurst", color = { "#ffffff", NTURQ, LTURQ }, speed = { 12, 22 }, size = { 1.2, 0.8, 0 }, life = { 0.5, 1.1 } })
		B:light(fx, { name = "GlowLight", color = NTURQ, brightness = 0.01, range = 18 })

		------------------------------------------------------------------
		-- HEAD: stepped melon head with a big happy cartoon face
		------------------------------------------------------------------
		local head = B:bone("Head", "Body1", v(0, 8, -3.8))
		B:block(head, v(9.0, 6.8, 5.8), cf(0, 8.0, -6.5), BODY) -- core
		B:block(head, v(7.2, 0.9, 6.4), cf(0, 11.85, -7.2), DARK) -- top cap
		B:block(head, v(5.0, 0.5, 4.4), cf(0, 12.5, -7.0), DEEP) -- melon ridge
		B:block(head, v(7.2, 0.8, 5.0), cf(0, 4.2, -6.3), WHITE) -- under cap
		B:block(head, v(9.5, 2.3, 5.6), cf(0, 10.25, -6.5), DARK) -- dark saddle
		B:block(head, v(9.4, 1.0, 5.6), cf(0, 5.1, -6.5), WHITE) -- belly band
		B:block(head, v(9.6, 0.3, 5.7), cf(0, 8.95, -6.5), GOLD) -- gold trim line
		B:block(head, v(8.2, 4.6, 1.4), cf(0, 9.3, -10.1), BODY) -- face / melon slab
		B:block(head, v(6.4, 0.6, 0.6), cf(0, 11.75, -10.75), DARK) -- forehead step
		-- cheeks framing the mouth, with a stepped chin under them
		B:sym(function()
			B:block(head, v(1.9, 2.8, 1.4), cf(3.6, 5.8, -10.0), BODY)
			B:block(head, v(1.5, 0.6, 1.2), cf(3.5, 4.1, -9.9), WHITE)
			B:block(head, v(1.0, 0.6, 0.12), cf(3.6, 6.4, -10.74), BLUSH)
			spot(head, 4.8, 10.4, -5.6, 0.9, 1.2, FLECK)
			spot(head, 4.56, 6.8, -7.2, 1.0, 1.2, DEEP)
		end)
		-- mouth interior + top teeth + curled-up smile corners
		B:block(head, v(5.4, 3.6, 0.4), cf(0, 5.4, -9.6), MOUTH)
		for _, tx in { -1.6, -0.5, 0.5, 1.6 } do
			B:block(head, v(0.8, 0.7, 0.5), cf(tx, 6.7, -10.15), "#ffffff")
		end
		B:sym(function()
			B:block(head, v(0.5, 0.8, 0.12), cf(2.95, 7.3, -10.84), MOUTH)
			B:block(head, v(0.45, 0.45, 0.12), cf(3.3, 7.8, -10.84), MOUTH)
		end)
		-- little crystal crest on the melon (behind the tusk collar)
		dspike(head, 12.7, -8.0, 0.8, 1.4, 35, false)
		dspike(head, 12.7, -6.5, 0.95, 1.9, 35, true)
		-- blowhole (bubbles puff out of it)
		B:block(head, v(1.2, 0.2, 0.7), cf(0, 12.36, -4.4), MOUTH)
		local blow = B:block(head, v(1, 0.6, 0.6), cf(0, 12.8, -4.4), BODY, { tr = 1, name = "BlowFX" })
		B:emitter(blow, "bubble", { name = "BlowBubbles", color = { "#ffffff", LTURQ }, rate = 0, size = { 0.35, 0.6, 0.7 }, speed = { 3, 6 }, spread = 25 })

		-- EYES: big white blocks, neon turquoise iris, dark pupil, sparkly
		-- glints + a spinning star sparkle
		B:sym(function(side)
			local ex, ey, ez = 2.75, 9.1, -11.0
			B:block(head, v(2.6, 3.0, 1.0), cf(ex, ey, ez), "#ffffff")
			B:block(head, v(1.9, 2.3, 0.12), cf(ex, ey - 0.05, ez - 0.55), NTURQ, { mat = "Neon", name = "Iris" .. side })
			B:block(head, v(0.12, 2.2, 0.8), cf(ex + 1.33, ey - 0.05, ez), NTURQ, NEON)
			B:block(head, v(1.0, 1.4, 0.1), cf(ex - 0.2, ey - 0.15, ez - 0.63), PUPIL)
			B:block(head, v(0.6, 0.6, 0.1), cf(ex + 0.35, ey + 0.55, ez - 0.69), "#ffffff", NEON)
			B:block(head, v(0.35, 0.35, 0.1), cf(ex - 0.45, ey - 0.65, ez - 0.69), "#ffffff", NEON)
			-- arched happy brows (raised)
			B:block(head, v(1.4, 0.5, 0.5), cf(ex, 11.15, -11.0), BROW)
			B:block(head, v(0.7, 0.5, 0.5), cf(ex + 1.0, 10.85, -11.02), BROW)
			B:block(head, v(0.7, 0.5, 0.5), cf(ex - 1.0, 10.85, -11.02), BROW)
			-- blink lid / happy squint cover (hidden until used)
			B:block(head, v(2.8, 3.2, 1.8), cf(ex, ey, ez + 0.04), BODY, { tr = 1, name = "Lid" .. side })
			B:block(head, v(2.4, 0.4, 0.12), cf(ex, ey - 0.4, ez - 0.95), BROW, { tr = 1, name = "BlinkLine" .. side })
			-- "^" happy squint arcs
			B:block(head, v(1.5, 0.5, 0.12), cf(ex - 0.55, ey + 0.05, ez - 0.95) * ang(0, 0, 35), BROW, { tr = 1, name = "HappyA" .. side })
			B:block(head, v(1.5, 0.5, 0.12), cf(ex + 0.55, ey + 0.05, ez - 0.95) * ang(0, 0, -35), BROW, { tr = 1, name = "HappyB" .. side })
			-- star sparkle in the eye (spins + twinkles)
			local sp = B:bone("EyeStar" .. side, "Head", v(ex + 0.95, ey + 1.1, ez - 0.72))
			B:block(sp, v(0.95, 0.22, 0.1), cf(ex + 0.95, ey + 1.1, ez - 0.74), "#ffffff", { mat = "Neon", name = "StarA" .. side })
			B:block(sp, v(0.22, 0.95, 0.1), cf(ex + 0.95, ey + 1.1, ez - 0.75), "#ffffff", { mat = "Neon", name = "StarB" .. side })
		end)

		-- JAW: hinged lower jaw whose stepped lip makes the "D" smile, with a
		-- pink tongue. Opens (-X) for laughs.
		local jaw = B:bone("Jaw", "Head", v(0, 5.0, -7.2))
		B:block(jaw, v(5.2, 1.0, 3.4), cf(0, 4.3, -9.0), WHITE)
		B:block(jaw, v(4.0, 0.5, 2.4), cf(0, 3.57, -9.2), BODY)
		B:block(jaw, v(2.0, 0.5, 1.8), cf(0, 4.95, -9.8), TONGUE)
		B:block(jaw, v(0.8, 0.2, 0.8), cf(0, 5.25, -10.2), TONGUE2)
		B:sym(function()
			B:block(jaw, v(0.9, 1.1, 0.8), cf(2.2, 5.3, -10.3), WHITE)
			B:block(jaw, v(0.8, 0.5, 0.8), cf(1.35, 4.95, -10.3), WHITE)
		end)

		------------------------------------------------------------------
		-- TUSK: twisted spiral of stacked crystal blocks + gold rune bands,
		-- spinning inside a marble Atlantis collar on the forehead
		------------------------------------------------------------------
		local TB = v(0, 11.3, -10.9)
		local tdir = v(0, sin(rad(15)), -cos(rad(15)))
		local TF = CFrame.fromMatrix(TB, v(1, 0, 0), v(0, cos(rad(15)), sin(rad(15))), -tdir) -- local -Z along the tusk
		local CC = TF * CFrame.new(0, 0, -0.2) * ang(90, 0, 0)
		B:ring(head, CC, 1.6, 8, v(1.4, 1.0, 0.9), MARBLE)
		B:ring(head, CC * CFrame.new(0, 0.6, 0) * ang(0, 22.5, 0), 1.8, 8, v(1.5, 0.45, 0.8), GOLD)
		for k = 0, 3 do
			B:block(head, v(0.32, 0.4, 0.12), CC * ang(0, k * 90, 0) * CFrame.new(0, 0, -2.08), NTURQ, NEON)
		end
		local tusk = B:bone("Tusk", "Head", TF)
		local N, STEP = 13, 0.78
		for i = 0, N - 1 do
			local s = 2.1 - i * 0.1
			local z = -(0.5 + i * STEP)
			local band = (i == 2 or i == 6 or i == 10)
			if band then
				B:block(tusk, v(s + 0.25, s + 0.25, 0.55), TF * CFrame.new(0, 0, z) * ang(0, 0, i * 25), GOLD)
				B:block(tusk, v(0.2, 0.28, 0.28), TF * CFrame.new(0, 0, z) * ang(0, 0, i * 25) * CFrame.new((s + 0.25) / 2 + 0.05, 0, 0), NGOLD, NEON)
			else
				B:block(tusk, v(s, s, STEP + 0.12), TF * CFrame.new(0, 0, z) * ang(0, 0, i * 25), (i % 2 == 0) and TURQ or LTURQ)
				-- gold helix ridge winding up the tusk
				B:block(tusk, v(0.32, 0.32, STEP), TF * CFrame.new(0, 0, z) * ang(0, 0, i * 25 + 45) * CFrame.new(s * 0.62, 0, 0), DGOLD)
			end
		end
		local tipZ = -(0.5 + (N - 1) * STEP) - 0.75
		B:block(tusk, v(0.55, 0.55, 0.7), TF * CFrame.new(0, 0, tipZ) * ang(0, 0, 45), LTURQ)
		local tip = B:block(tusk, v(0.4, 0.4, 0.6), TF * CFrame.new(0, 0, tipZ - 0.55) * ang(0, 0, 45), NTURQ, { mat = "Neon", name = "TuskTip" })
		B:emitter(tip, "sparkle", { name = "TuskSparkle", color = { "#ffffff", NTURQ, NGOLD }, rate = 3, size = { 0.15, 0.5, 0 } })
		B:light(tip, { name = "TuskLight", color = NTURQ, brightness = 0.4, range = 9 })
		B:trail(tusk, (TF * CFrame.new(0.3, 0, tipZ)).Position, (TF * CFrame.new(-0.3, 0, tipZ + 1.2)).Position, { name = "TuskTrail", color = { "#ffffff", NTURQ }, life = 0.3, trans = { 0.4, 1 } })
		-- hidden beam + spinning star rays (revealed by the Crystal Breach)
		B:block(tusk, v(0.7, 0.7, 9), TF * CFrame.new(0, 0, tipZ - 5.0) * ang(0, 0, 45), NTURQ, { mat = "Neon", tr = 1, name = "TuskBeam" })
		for k = 1, 6 do
			local R = TF * CFrame.new(0, 0, -6.0) * ang(0, 0, k * 60)
			B:block(tusk, v(0.45, 3.6, 0.45), R * CFrame.new(0, 3.0, 0), k % 2 == 0 and NGOLD or NTURQ, { mat = "Neon", tr = 1, name = "Ray" .. k })
		end

		------------------------------------------------------------------
		-- BODY2 + TAIL chain (steps down and curls up)
		------------------------------------------------------------------
		local body2 = B:bone("Body2", "Body1", v(0, 8.3, 1.0))
		segment(body2, 0.8, 5.0, 8.3, 8.6, 8.2)
		B:sym(function()
			spot(body2, 4.38, 6.9, 3.2, 1.2, 1.4, DEEP)
			spot(body2, 4.6, 10.6, 2.2, 0.7, 1.0, FLECK)
			crystals(body2, v(4.0, 10.6, 3.4), {
				{ 0, 0, 0, 0.7, 1.6, 20, 20, -50, TURQ, false },
			})
		end)
		dspike(body2, 12.9, 1.9, 1.05, 2.4, 32, true)
		dspike(body2, 12.9, 3.2, 0.9, 2.0, 34, false)
		dspike(body2, 12.9, 4.4, 0.8, 1.6, 36, true)
		B:block(body2, v(0.6, 0.35, 0.6), cf(-2.2, 12.5, 1.8), MARBLE2)

		local tail1 = B:bone("Tail1", "Body2", v(0, 8.8, 4.6))
		segment(tail1, 4.4, 7.8, 8.8, 6.6, 6.2, { noRidge = true, noTrim = true })
		-- marble rune cuff with gold rims (Atlantis orichalcum band)
		B:block(tail1, v(7.3, 6.5, 1.0), cf(0, 8.8, 6.0), MARBLE)
		B:block(tail1, v(7.45, 6.65, 0.3), cf(0, 8.8, 5.35), GOLD)
		B:block(tail1, v(7.45, 6.65, 0.3), cf(0, 8.8, 6.65), GOLD)
		B:sym(function()
			B:block(tail1, v(0.12, 0.6, 0.4), cf(3.68, 8.8, 6.0), NTURQ, NEON)
			spot(tail1, 3.38, 8.4, 7.2, 0.8, 0.8, DEEP)
		end)
		B:block(tail1, v(0.4, 0.12, 0.6), cf(0, 12.08, 6.0), NTURQ, NEON)
		dspike(tail1, 11.6, 7.2, 0.8, 1.6, 38, false)

		local tail2 = B:bone("Tail2", "Tail1", v(0, 9.3, 7.6))
		segment(tail2, 7.4, 10.0, 9.3, 4.6, 4.4, { noRidge = true, noKeel = true })
		dspike(tail2, 11.3, 8.8, 0.7, 1.3, 40, true)

		local tail3 = B:bone("Tail3", "Tail2", v(0, 9.7, 9.8))
		B:block(tail3, v(2.6, 3.0, 2.2), cf(0, 9.7, 10.7), BODY)
		B:block(tail3, v(1.6, 0.5, 2.0), cf(0, 11.4, 10.7), DARK)
		B:block(tail3, v(1.6, 0.5, 2.0), cf(0, 8.0, 10.7), WHITE)
		B:block(tail3, v(2.8, 0.5, 0.6), cf(0, 9.7, 11.4), GOLD)
		dspike(tail3, 11.5, 10.6, 0.55, 1.0, 45, false)

		------------------------------------------------------------------
		-- FLUKES: horizontal stepped lobes with a gold orichalcum band
		------------------------------------------------------------------
		local FY = 9.9
		local fluke = B:bone("Fluke", "Tail3", v(0, FY, 11.4))
		B:block(fluke, v(2.6, 1.2, 2.2), cf(0, FY, 12.6), BODY)
		B:block(fluke, v(1.8, 1.3, 0.8), cf(0, FY, 13.6), DARK)
		B:block(fluke, v(2.8, 1.35, 0.5), cf(0, FY, 12.0), DGOLD)
		B:sym(function(side)
			local lob = B:bone("FlukeLobe" .. side, "Fluke", v(1.2, FY, 12.4))
			local rows = {
				{ 2.0, 1.6, 11.6, 14.2, DARK, 1.0 }, { 3.5, 1.6, 12.0, 14.9, BODY, 0.9 },
				{ 5.0, 1.6, 12.6, 15.5, DARK, 0.8 }, { 6.4, 1.3, 13.4, 16.0, BODY, 0.7 },
				{ 7.5, 1.0, 14.4, 16.5, DARK, 0.6 },
			}
			for _, r in rows do
				B:block(lob, v(r[2], r[6], r[4] - r[3]), cf(r[1], FY, (r[3] + r[4]) / 2), r[5])
				B:block(lob, v(r[2] - 0.2, r[6] - 0.1, 0.6), cf(r[1], FY, r[4] + 0.25), WHITE) -- pale trailing edge
			end
			-- gold orichalcum band across the lobe, with a rune dot
			B:block(lob, v(5.0, 1.12, 0.8), cf(3.7, FY, 13.9), GOLD)
			B:block(lob, v(0.4, 0.12, 0.4), cf(3.7, FY + 0.6, 13.9), NTURQ, NEON)
			-- crystal spikes on the lobe tips
			B:beam(lob, v(6.9, FY, 15.6), v(9.0, FY + 0.3, 18.2), 0.7, 0.7, TURQ)
			B:beam(lob, v(4.9, FY, 15.8), v(5.6, FY + 0.2, 17.9), 0.55, 0.55, LTURQ)
			B:block(lob, v(0.6, 0.6, 0.6), cf(9.1, FY + 0.3, 18.35) * ang(0, 45, 0), NTURQ, NEON)
			B:trail(lob, v(8.9, FY, 18.0), v(7.0, FY, 16.0), { name = "FlukeTrail" .. side, color = { "#ffffff", NTURQ }, life = 0.28, trans = { 0.45, 1 } })
		end)

		------------------------------------------------------------------
		-- FLIPPERS: broad stepped paddles with gold orichalcum bands
		------------------------------------------------------------------
		B:sym(function(side)
			local F = frame(v(4.9, 5.4, -2.6), v(0.82, -0.35, 0.45), v(0, 0, 1))
			local f1 = B:bone("Flipper" .. side, "Body1", F.Position)
			B:block(f1, v(3.0, 1.1, 3.0), F * CFrame.new(1.0, 0, 0.5), BODY)
			B:block(f1, v(2.2, 0.3, 2.2), F * CFrame.new(1.1, 0.6, 0.4), DARK)
			B:block(f1, v(0.7, 1.25, 3.2), F * CFrame.new(2.3, 0, 0.5), GOLD)
			B:block(f1, v(0.25, 0.25, 0.4), F * CFrame.new(2.3, 0.68, 0.1), NGOLD, NEON)
			local f2 = B:bone("FlipperTip" .. side, "Flipper" .. side, (F * CFrame.new(2.5, 0, 0)).Position)
			B:block(f2, v(2.4, 0.95, 3.2), F * CFrame.new(3.7, 0, 0.8), BODY)
			B:block(f2, v(2.4, 0.75, 1.0), F * CFrame.new(3.7, -0.03, 2.85), WHITE)
			B:block(f2, v(1.4, 0.3, 1.2), F * CFrame.new(3.5, 0.55, 0.5), FLECK)
			B:block(f2, v(0.55, 1.05, 3.6), F * CFrame.new(5.0, 0, 1.1), DGOLD)
			B:block(f2, v(1.6, 0.8, 2.6), F * CFrame.new(6.0, 0, 1.3), BODY)
			B:block(f2, v(1.6, 0.6, 0.9), F * CFrame.new(6.0, -0.02, 3.0), WHITE)
			B:block(f2, v(1.1, 0.7, 1.8), F * CFrame.new(7.3, 0, 1.9), BODY)
			B:block(f2, v(0.7, 0.55, 1.0), F * CFrame.new(8.1, 0, 2.3), WHITE)
			B:block(f2, v(0.45, 0.4, 0.45), F * CFrame.new(8.55, 0, 2.6), NTURQ, NEON)
			B:beam(f2, (F * CFrame.new(6.4, 0.35, 0.3)).Position, (F * CFrame.new(8.9, 0.5, 0.6)).Position, 0.55, 0.55, TURQ)
			B:trail(f2, (F * CFrame.new(8.3, 0, 2.2)).Position, (F * CFrame.new(7.6, 0, 3.2)).Position, { name = "FlipperTrail" .. side, color = { "#ffffff", NTURQ }, life = 0.22, trans = { 0.5, 1 } })
		end)

		------------------------------------------------------------------
		-- Floating cubes: orichalcum crystal cubes + marble ruin cubes
		------------------------------------------------------------------
		local orbs = {
			{ 11.0, 13.5, -6.0, 1.6, true }, { -11.5, 10.5, -3.0, 1.4, false }, { 10.5, 6.5, 7.0, 1.3, false },
			{ -10.0, 14.5, 6.0, 1.6, true }, { 1.5, 19.0, 5.5, 1.2, true },
		}
		for i, o in orbs do
			local ob = B:bone("Orb" .. i, "Root", v(o[1], o[2], o[3]))
			local s = o[4]
			if o[5] then
				B:block(ob, v(s, s, s), cf(o[1], o[2], o[3]) * ang(0, 45, 0), TURQ)
				B:block(ob, v(s * 0.6, s + 0.1, s * 0.6), cf(o[1], o[2], o[3]) * ang(0, 45, 0), LTURQ)
				B:block(ob, v(s * 0.35, s * 0.35, s * 0.35), cf(o[1], o[2] + s * 0.62, o[3]), NTURQ, NEON)
			else
				B:block(ob, v(s, s, s), cf(o[1], o[2], o[3]), MARBLE)
				B:block(ob, v(s + 0.1, s * 0.28, s + 0.1), cf(o[1], o[2] + s * 0.32, o[3]), GOLD)
				B:block(ob, v(s * 0.3, s * 0.3, 0.12), cf(o[1], o[2] - 0.1, o[3] - s / 2 - 0.02), NTURQ, NEON)
			end
		end

		------------------------------------------------------------------
		-- CRYSTAL SHARDS (hidden) that burst out at the top of the breach
		------------------------------------------------------------------
		local SH = v(0, 8, -1.5)
		for k = 1, 10 do
			local sb = B:bone("Shard" .. k, "Root", SH)
			local big = k % 3 == 1
			B:block(sb, big and v(1.2, 2.2, 1.2) or v(0.9, 1.5, 0.9), CFrame.new(SH) * ang(0, 45, 0), k % 2 == 0 and LTURQ or TURQ, { tr = 1, name = "ShardPart" .. k })
		end

		------------------------------------------------------------------
		-- SPLASH: water cubes + ripple slabs (hidden) and the burst emitters
		------------------------------------------------------------------
		local SC = v(0, 4.0, 0.5)
		local splashAt = B:block("Root", v(8, 0.6, 10), CFrame.new(SC), WHITE, { tr = 1, name = "SplashFX" })
		B:emitter(splashAt, "burst", { name = "SplashBurst", color = { "#ffffff", "#9feaff", NTURQ }, speed = { 10, 20 }, size = { 1.4, 1.0, 0 }, accel = { 0, -18, 0 }, spread = 70 })
		B:emitter(splashAt, "dust", { name = "SplashMist", color = { "#ffffff", "#bfefff" }, size = { 2.5, 4, 5 }, speed = { 6, 12 } })
		B:emitter(splashAt, "bubble", { name = "BubbleBurst", color = { "#ffffff", LTURQ, NTURQ }, rate = 0, size = { 0.5, 0.8, 0.9 }, speed = { 4, 9 }, spread = 80, life = { 1.2, 2.2 } })
		for k = 1, 12 do
			local sb = B:bone("Drop" .. k, "Root", SC)
			local size = k % 2 == 1 and (k % 4 == 1 and v(2.4, 2.4, 2.4) or v(1.8, 1.8, 1.8)) or v(3.6, 0.7, 1.6)
			local col = k % 4 == 1 and "#7fd8f0" or (k % 2 == 0 and "#e6fbff" or "#bdf1ff")
			B:block(sb, size, CFrame.new(SC), col, { tr = 1, name = "DropPart" .. k })
		end

		------------------------------------------------------------------
		-- voxel bubbles that puff out of the blowhole (hidden)
		------------------------------------------------------------------
		local BC = v(0, 12.9, -4.4)
		for k = 1, 3 do
			local bb = B:bone("Bubble" .. k, "Root", BC)
			local s = k == 2 and 0.8 or 0.6
			B:block(bb, v(s, s, s), CFrame.new(BC), "#d8f6ff", { tr = 1, name = "BubblePart" .. k })
		end
	end,
}
