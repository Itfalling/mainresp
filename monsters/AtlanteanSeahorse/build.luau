--!nocheck
-- Column Seahorse: a proud little show-off seahorse from sunken Atlantis,
-- stud-built in the Void Leviathan voxel style. Upright stepped coral-orange
-- body (dark ridge rings between the segments), cream belly plates with an
-- orichalcum gem, a fluted marble Greek column running down its back (gold
-- trims), orichalcum gold armour rings, a long snout with a gold band and a
-- smug little smirk, BIG cute eyes under heavy half-closed "smug" lids, and a
-- broken Ionic column capital worn as a jaunty tilted crown (marble + gold,
-- with a glowing orichalcum crystal growing out of the break and a seaweed
-- tuft). Curly 7-bone tail, fluttering aqua dorsal + pectoral fins with gold
-- tips. Neon is kept to the eyes, rune dots, crystals and the tail tip.
-- Hidden VFX (a water swirl ribbon and a voxel bubble ring) are revealed by
-- the motion during the "Tidal Twirl".
return {
	DisplayName = "Column Seahorse",
	Rarity = "Uncommon",
	Element = "Atlantis",
	Build = function(B0, P)
		local v, cf, ang = P.v, P.cf, P.ang
		-- everything is authored at 1x and scaled down by S (Uncommon pet
		-- size, ~12 studs incl. the crown), lifted so it still hovers at 1.8.
		-- motion.luau uses the same S / OY (keep in sync).
		local S, OY = 0.82, 1.8 * (1 - 0.82)
		local function sp(p) return Vector3.new(p.X * S, p.Y * S + OY, p.Z * S) end
		local function scf(c)
			if typeof(c) == "Vector3" then
				return CFrame.new(sp(c))
			end
			return CFrame.new(sp(c.Position)) * c.Rotation
		end
		local B = {}
		function B:bone(n, parent, piv) return B0:bone(n, parent, scf(piv)) end
		function B:block(bone, size, c, col, opts) return B0:block(bone, size * S, scf(c), col, opts) end
		function B:beam(bone, a, b, w, h, col, opts) return B0:beam(bone, sp(a), sp(b), w * S, (h or w) * S, col, opts) end
		function B:spike(bone, a, b, w, d, col, opts) return B0:spike(bone, sp(a), sp(b), w * S, (d or w) * S, col, opts) end
		function B:trail(bone, a, b, o) return B0:trail(bone, sp(a), sp(b), o) end
		function B:emitter(...) return B0:emitter(...) end
		function B:light(...) return B0:light(...) end
		function B:sym(fn) return B0:sym(fn) end
		local rad, cos, sin = math.rad, math.cos, math.sin

		-- palette
		local ORANGE, DARK, LORANGE = "#ff8a3d", "#c85a1f", "#ffab6b"
		local CREAM, CREAM2 = "#f6e2bd", "#fff1d6"
		local MARBLE, MGREY = "#f4efe4", "#cbc2b2"
		local GOLD, DGOLD = "#ffc83a", "#c98a1a"
		local AQUA, TEAL = "#5fe0cf", "#22a597"
		local WHITE, PUPIL, MOUTH = "#ffffff", "#141018", "#2a0d10"
		local BROW, BLUSH, WEED = "#7a2e0c", "#ff9fae", "#3fbf6a"
		local TURQ, GOLDN = "#3ff0e0", "#ffe27a" -- the two (small) neon accents
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- BODY (lower belly) + CHEST (upper body): stepped segments
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 6.8, 0.4))
		local chest = B:bone("Chest", "Body", v(0, 7.6, 0.3))

		-- { bone, y0, height, width, depth, zCenter, ringColor }
		local segs = {
			{ body, 5.6, 1.0, 2.8, 2.8, 0.5, GOLD },
			{ body, 6.6, 1.0, 3.3, 3.5, 0.05, DARK },
			{ chest, 7.6, 1.0, 3.6, 4.2, -0.3, DARK }, -- puffed-out proud chest
			{ chest, 8.6, 1.0, 3.0, 3.0, 0.3, DARK },
			{ chest, 9.6, 0.8, 2.4, 2.2, 0.7, GOLD },
		}
		for i, s in segs do
			local bone, y0, h, w, d, zc, ring = s[1], s[2], s[3], s[4], s[5], s[6], s[7]
			local yc = y0 + h / 2
			local front, back = zc - d / 2, zc + d / 2
			B:block(bone, v(w, h, d), cf(0, yc, zc), ORANGE)
			-- ridge ring at the bottom of every segment (gold armour rings at
			-- the waist and the neck collar)
			local rw = ring == GOLD and 0.35 or 0.2
			B:block(bone, v(w + rw, 0.32, d + rw), cf(0, y0 + 0.16, zc), ring)
			-- cream belly plate
			if i < 5 then
				B:block(bone, v(w - 0.9, h - 0.3, 0.4), cf(0, yc + 0.08, front - 0.1), i % 2 == 0 and CREAM or CREAM2)
				-- fluted marble column down the back: grey core + 3 white flutes
				B:block(bone, v(1.9, h, 0.3), cf(0, yc, back + 0.1), MGREY)
				for k = -1, 1 do
					B:block(bone, v(0.42, h - 0.06, 0.3), cf(k * 0.58, yc, back + 0.26), MARBLE)
				end
			end
			-- knobbly seahorse ridge: little marble knobs at the back corners
			if i >= 2 and i <= 4 then
				B:sym(function()
					B:block(bone, v(0.55, 0.55, 0.55), cf(w / 2 + 0.05, y0 + 0.2, back - 0.45), i == 3 and GOLD or MARBLE)
				end)
			end
		end
		-- neon rune dots on the gold waist ring + the neck collar
		B:sym(function()
			B:block(body, v(0.32, 0.18, 0.1), cf(0.6, 5.76, 0.5 - 1.4 - 0.2), TURQ, NEON)
		end)
		B:block(chest, v(0.35, 0.18, 0.1), cf(0, 9.76, 0.7 - 1.1 - 0.2), TURQ, NEON)
		-- column trims (gold base + capital band)
		B:block(body, v(2.3, 0.4, 0.75), cf(0, 5.78, 2.15), GOLD)
		B:block(chest, v(2.3, 0.4, 0.75), cf(0, 9.42, 2.05), GOLD)
		B:block(chest, v(2.0, 0.25, 0.6), cf(0, 9.12, 2.0), DGOLD)
		-- darker seahorse spots on the flanks
		B:sym(function()
			B:block(body, v(0.15, 0.5, 0.9), cf(1.69, 7.15, -0.2), DARK)
			B:block(chest, v(0.15, 0.45, 0.7), cf(1.79, 8.3, 0.6), DARK)
			B:block(chest, v(0.15, 0.35, 0.55), cf(1.79, 8.05, -0.6), LORANGE)
			-- dark rear side panels (two-tone colour blocking)
			B:block(body, v(0.15, 0.7, 1.2), cf(1.69, 7.1, 1.2), DARK)
			B:block(chest, v(0.15, 0.7, 1.0), cf(1.54, 9.1, 1.15), DARK)
		end)
		-- orichalcum chest gem in a gold diamond setting
		B:block(chest, v(1.1, 1.1, 0.2), cf(0, 8.15, -2.62, 0, 0, 45), GOLD)
		B:block(chest, v(0.55, 0.55, 0.2), cf(0, 8.15, -2.7, 0, 0, 45), TURQ, NEON)

		local bodyFX = B:block(body, v(3, 5, 3), cf(0, 8.2, 0.4), ORANGE, { tr = 1, name = "BodyFX" })
		B:emitter(bodyFX, "bubble", { name = "AmbientBubbles", color = { WHITE, "#bff6ff" }, rate = 1.5, size = { 0.2, 0.4, 0.5 } })
		B:emitter(bodyFX, "burst", { name = "TwirlBurst", color = { WHITE, GOLDN, TURQ }, speed = { 9, 16 }, size = { 0.9, 0.6, 0 }, life = { 0.5, 1.0 } })
		B:light(bodyFX, { name = "BodyGlow", color = TURQ, brightness = 0.01, range = 14 })

		------------------------------------------------------------------
		-- DORSAL FIN: 4 fluttering aqua rays with gold tips on the lower back
		------------------------------------------------------------------
		B:block(body, v(0.7, 2.6, 0.5), cf(0, 6.95, 2.4), GOLD)
		local rays = { { 5.95, -0.25, 1.7 }, { 6.6, -0.05, 2.15 }, { 7.25, 0.2, 2.35 }, { 7.9, 0.45, 2.05 } }
		for i, r in rays do
			local y, rise, len = r[1], r[2], r[3]
			local fb = B:bone("Dorsal" .. i, "Body", v(0, y, 2.55))
			local a, b = v(0, y, 2.4), v(0, y + rise, 2.55 + len)
			B:beam(fb, a, b, 0.3, 0.72, i % 2 == 1 and AQUA or TEAL)
			local dir = (b - a).Unit
			B:block(fb, v(0.4, 0.66, 0.6), CFrame.lookAt(b + dir * 0.2, b + dir * 2), GOLD)
		end

		------------------------------------------------------------------
		-- TAIL: 7-bone curl (authored curled forward under the belly). Each
		-- segment: orange core, cream inner (belly) strip, ridge ring.
		------------------------------------------------------------------
		local TH = { -5, 15, 40, 75, 115, 160, 205 } -- direction (deg): 0 = down, 90 = forward
		local LEN = { 1.2, 1.15, 1.05, 0.95, 0.85, 0.75, 0.7 }
		local THK = { 2.0, 1.8, 1.6, 1.4, 1.2, 1.0, 0.85 }
		local p = v(0, 5.9, 0.7)
		local parent = "Body"
		for i = 1, 7 do
			local th = rad(TH[i])
			local d = v(0, -cos(th), -sin(th))
			local n = v(0, sin(th), -cos(th)) -- inner side of the curl (belly side)
			local q = p + d * LEN[i]
			local tb = B:bone("Tail" .. i, parent, p)
			local T = THK[i]
			B:beam(tb, p - d * 0.3, q + d * 0.12, T, T, ORANGE, { up = n })
			B:beam(tb, p - d * 0.05 + n * (T / 2), q + n * (T / 2), T * 0.7, 0.3, CREAM, { up = n })
			if i >= 2 then
				local gold = i % 2 == 0
				local rw = gold and 0.3 or 0.2
				B:beam(tb, p - d * 0.12, p + d * 0.2, T + rw, T + rw, gold and GOLD or DARK, { up = n })
			end
			if i <= 5 and i % 2 == 1 then
				B:block(tb, v(0.55, 0.55, 0.55), P.span(p, q, n) * CFrame.new(0, -(T / 2 + 0.05), 0), MARBLE)
			end
			if i == 7 then
				B:block(tb, v(0.5, 0.5, 0.5), P.span(p, q, n) * CFrame.new(0, 0, -(LEN[i] / 2 + 0.3)), TURQ, NEON)
				B:trail(tb, q + n * 0.4, q - n * 0.4, { name = "TailTrail", color = { WHITE, TURQ }, life = 0.3, trans = { 0.4, 1 } })
			end
			p = q
			parent = "Tail" .. i
		end

		------------------------------------------------------------------
		-- HEAD: big cute head with a long snout
		------------------------------------------------------------------
		local head = B:bone("Head", "Chest", v(0, 10.0, 0.8))
		B:block(head, v(3.8, 3.0, 3.4), cf(0, 11.6, 0.3), ORANGE) -- cranium
		B:block(head, v(3.0, 0.5, 2.6), cf(0, 13.35, 0.45), ORANGE) -- top step
		B:block(head, v(2.0, 0.3, 2.9), cf(0, 13.2, 0.3), DARK) -- crest stripe
		B:block(head, v(3.3, 0.9, 2.9), cf(0, 10.0, 0.1), CREAM) -- jowl
		B:block(head, v(2.6, 2.2, 0.9), cf(0, 11.9, 2.3), DARK) -- occiput
		B:block(head, v(1.6, 1.0, 0.6), cf(0, 12.4, 2.85), ORANGE)
		B:block(head, v(0.6, 0.6, 0.6), cf(0, 13.3, 2.1), MARBLE) -- head knobs
		B:block(head, v(0.5, 0.5, 0.5), cf(0, 12.9, 3.0), GOLD)
		-- spiny marble crest down the back of the head + neck (gold-tipped)
		local crest = { { head, v(0, 12.7, 2.7), v(0, 13.6, 3.9), 0.8 }, { head, v(0, 11.5, 2.6), v(0, 11.8, 3.8), 0.7 },
			{ chest, v(0, 9.9, 1.9), v(0, 10.4, 3.0), 0.7 } }
		for _, k in crest do
			B:spike(k[1], k[2], k[3], k[4], k[4], MARBLE)
			B:block(k[1], v(0.4, 0.4, 0.4), CFrame.new(k[3]), GOLD)
		end

		-- snout (own bone: it tilts and pushes out to blow bubbles). The
		-- geometry is authored straight and then angled DOWN by SNT degrees
		-- about the pivot, so the eyes stay readable above it from the front.
		-- motion.luau uses the same SNT for the bubble-ring aim (keep in sync).
		local SNT = -15
		local SNR = CFrame.new(0, 10.6, -1.3) * ang(SNT, 0, 0)
		local function snc(x, y, z, rx, ry, rz)
			return SNR * CFrame.new(x, y - 10.6, z + 1.3) * ang(rx or 0, ry or 0, rz or 0)
		end
		local function snp(x, y, z) return snc(x, y, z).Position end
		local snout = B:bone("Snout", "Head", v(0, 10.6, -1.3))
		B:block(snout, v(1.6, 1.4, 3.8), snc(0, 10.6, -3.1), ORANGE)
		B:block(snout, v(1.0, 0.25, 3.2), snc(0, 11.4, -3.3), DARK)
		B:block(snout, v(1.2, 0.25, 3.4), snc(0, 9.82, -3.1), CREAM)
		B:block(snout, v(1.95, 1.75, 0.5), snc(0, 10.6, -2.4), GOLD) -- orichalcum band
		B:block(snout, v(0.35, 0.12, 0.3), snc(0, 11.53, -2.4), TURQ, NEON)
		B:block(snout, v(2.0, 1.8, 0.7), snc(0, 10.6, -5.1), LORANGE) -- puckered tip
		-- smug lopsided smirk (rest) / round "O" (revealed while blowing)
		B:block(snout, v(0.8, 0.22, 0.12), snc(-0.1, 10.42, -5.48), MOUTH, { name = "Smirk" })
		B:block(snout, v(0.42, 0.22, 0.12), snc(0.42, 10.56, -5.48, 0, 0, 32), MOUTH, { name = "Smirk2" })
		B:block(snout, v(0.85, 0.8, 0.12), snc(0, 10.55, -5.5), MOUTH, { tr = 1, name = "MouthO" })
		local mouthFX = B:block(snout, v(0.8, 0.8, 0.6), snc(0, 10.6, -5.9), ORANGE, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFX, "bubble", { name = "SnoutBubbles", color = { WHITE, "#bff6ff" }, rate = 0, size = { 0.3, 0.55, 0.65 }, speed = { 2, 4 }, spread = 30, dir = "Front" })
		B:emitter(mouthFX, "burst", { name = "BubbleBurst", color = { WHITE, "#bff6ff", TURQ }, speed = { 6, 13 }, size = { 0.8, 0.6, 0 }, spread = 35, dir = "Front", life = { 0.4, 0.9 } })
		B:trail(snout, snp(0, 11.3, -5.4), snp(0, 9.9, -5.4), { name = "SnoutTrail", color = { WHITE, TURQ }, life = 0.2, trans = { 0.55, 1 } })

		B:sym(function(side)
			-- BIG eye on the front corner: white block, glowing turquoise iris
			-- wrapping the corner, black pupils (front + side) and glints
			B:block(head, v(2.0, 2.1, 2.0), cf(1.75, 11.98, -1.2), WHITE)
			B:block(head, v(1.38, 1.4, 1.3), cf(2.09, 11.9, -1.58), TURQ, { mat = "Neon", name = "Eye" .. side })
			B:block(head, v(0.7, 0.95, 0.1), cf(1.88, 11.8, -2.28), PUPIL)
			B:block(head, v(0.1, 0.95, 0.7), cf(2.83, 11.8, -1.65), PUPIL)
			B:block(head, v(0.3, 0.3, 0.08), cf(2.2, 11.75, -2.3), WHITE, NEON)
			B:block(head, v(0.08, 0.3, 0.3), cf(2.85, 11.75, -1.2), WHITE, NEON)
			-- blush + gill plate
			B:block(head, v(0.9, 0.42, 0.12), cf(1.95, 10.65, -1.42), BLUSH)
			B:block(head, v(0.2, 1.4, 1.5), cf(1.95, 10.9, 0.9), DARK)
			B:block(head, v(0.2, 0.9, 0.9), cf(2.0, 11.2, 0.9), LORANGE)
			-- heavy SMUG lid: rests half closed; slides down for blinks / winks
			local lid = B:bone("Lid" .. side, "Head", v(1.75, 13.0, -1.2))
			B:block(lid, v(2.36, 1.08, 2.36), cf(1.75, 12.54, -1.2), ORANGE, { name = "LidTop" .. side })
			B:block(lid, v(2.46, 0.22, 2.46), cf(1.75, 12.0, -1.2), BROW, { name = "Lash" .. side })
			B:block(lid, v(2.04, 0.9, 2.04), cf(1.75, 13.5, -1.2), ORANGE, { tr = 1, name = "LidFill" .. side })
			-- brow (own bone: the smug arch)
			local brow = B:bone("Brow" .. side, "Head", v(1.75, 13.25, -2.05))
			B:block(brow, v(2.1, 0.42, 0.65), cf(1.75, 13.28, -2.05), BROW)
			B:block(brow, v(0.8, 0.3, 0.6), cf(2.35, 13.55, -2.0), BROW)
			-- pectoral fins behind the head: fan of 3 aqua blades, gold tips
			local pec = B:bone("Pec" .. side, "Head", v(1.95, 10.8, 1.2))
			local tips = { v(3.8, 12.05, 2.0), v(4.15, 10.87, 2.43), v(3.8, 9.7, 2.15) }
			for k, tp in tips do
				B:beam(pec, v(1.9, 10.8, 1.2), tp, 0.8, 0.3, k == 2 and TEAL or AQUA, { up = v(0, 0, 1) })
				B:block(pec, v(0.6, 0.6, 0.45), CFrame.new(tp + (tp - v(1.9, 10.8, 1.2)).Unit * 0.15), GOLD)
			end
			B:trail(pec, v(4.2, 11.4, 2.4), v(4.2, 10.3, 2.4), { name = "PecTrail" .. side, color = { WHITE, AQUA }, life = 0.18, trans = { 0.55, 1 } })
		end)
		local winkFX = B:block(head, v(0.6, 0.6, 0.6), cf(2.3, 12.6, -2.3), ORANGE, { tr = 1, name = "WinkFX" })
		B:emitter(winkFX, "burst", { name = "WinkSparkle", color = { WHITE, GOLDN }, speed = { 3, 6 }, size = { 0.8, 0.5, 0 }, life = { 0.3, 0.6 }, drag = 4 })

		------------------------------------------------------------------
		-- CROWN: a broken Ionic column capital worn at a jaunty tilt
		------------------------------------------------------------------
		local CR = CFrame.new(0, 13.6, 0.45) * ang(0, 0, -8)
		local crown = B:bone("Crown", "Head", CR)
		local function cb(sx, sy, sz, x, y, z, col, opts, rx, ry, rz)
			return B:block(crown, v(sx, sy, sz), CR * CFrame.new(x, y, z) * ang(rx or 0, ry or 0, rz or 0), col, opts)
		end
		cb(2.4, 0.4, 2.2, 0, 0.2, 0, GOLD) -- gold base band
		cb(1.6, 0.9, 1.6, 0, 0.85, 0, MGREY) -- shaft core
		B:sym(function()
			cb(0.4, 0.84, 0.15, 0.42, 0.85, -0.85, MARBLE)
			cb(0.4, 0.84, 0.15, 0.42, 0.85, 0.85, MARBLE)
		end)
		cb(0.15, 0.84, 0.5, 0.85, 0.85, 0, MARBLE)
		cb(0.15, 0.84, 0.5, -0.85, 0.85, 0, MARBLE)
		cb(2.0, 0.25, 2.0, 0, 1.42, 0, GOLD) -- echinus trim
		cb(2.7, 0.7, 2.2, -0.4, 1.9, 0, MARBLE) -- abacus slab
		cb(0.9, 0.45, 1.7, 1.3, 1.78, 0.1, MARBLE) -- broken end (lower)
		cb(0.45, 0.3, 0.6, 1.55, 2.08, -0.35, MGREY) -- chip
		cb(0.8, 0.18, 0.08, -0.4, 1.9, -1.12, GOLDN, NEON) -- rune
		-- volutes (scrolls): left whole, right broken
		cb(0.8, 1.35, 1.5, -2.0, 1.55, 0, MARBLE)
		cb(0.5, 0.5, 1.62, -2.0, 1.55, 0, GOLD) -- volute eye (front + back)
		cb(0.7, 0.9, 1.2, 2.0, 1.45, 0.1, MARBLE)
		cb(0.42, 0.42, 1.32, 2.0, 1.45, 0.1, GOLD)
		-- orichalcum crystal growing out of the break + a seaweed tuft
		cb(0.45, 1.0, 0.45, 1.1, 2.25, 0.25, TURQ, NEON, 0, 0, -20)
		cb(0.3, 0.6, 0.3, 1.55, 2.1, -0.25, TURQ, NEON, 15, 0, -35)
		cb(0.3, 0.8, 0.3, -1.1, 2.45, 0.55, WEED, nil, 0, 0, 10)
		cb(0.3, 0.55, 0.3, -1.3, 2.95, 0.55, WEED, nil, 0, 0, 25)
		local crownFX = cb(2.6, 1.0, 2.0, 0, 1.6, 0, MARBLE, { tr = 1, name = "CrownFX" })
		B:emitter(crownFX, "sparkle", { name = "CrownSparkle", color = { WHITE, GOLDN, TURQ }, rate = 2.5 })
		B:light(crownFX, { name = "CrownLight", color = TURQ, brightness = 0.6, range = 8 })

		------------------------------------------------------------------
		-- Floating Atlantis voxel cubes (marble cubes, a crystal, a column bit)
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 8.5, 0.4))
		local function orb(i, x, y, z, kind)
			local ob = B:bone("Orb" .. i, "Orbit", v(x, y, z))
			if kind == "cube" then
				local s = i == 1 and 1.4 or 1.2
				B:block(ob, v(s, s, s), cf(x, y, z), MARBLE)
				B:block(ob, v(s + 0.1, s * 0.3, s + 0.1), cf(x, y + s * 0.36, z), GOLD)
				B:block(ob, v(s + 0.16, s * 0.14, s + 0.16), cf(x, y - s * 0.1, z), TURQ, NEON)
			elseif kind == "crystal" then
				B:block(ob, v(1.0, 0.4, 1.0), cf(x, y - 0.6, z), GOLD)
				B:block(ob, v(0.6, 1.3, 0.6), cf(x, y + 0.2, z, 0, 45, 0), TURQ, NEON)
			else
				B:block(ob, v(1.0, 1.6, 1.0), cf(x, y, z), MARBLE)
				B:block(ob, v(0.3, 1.5, 1.04), cf(x, y, z), MGREY)
				B:block(ob, v(1.3, 0.3, 1.3), cf(x, y + 0.9, z), GOLD)
				B:block(ob, v(1.3, 0.3, 1.3), cf(x, y - 0.9, z), DGOLD)
			end
		end
		-- wide orbit, two cubes ABOVE the head and two BELOW the chest so
		-- they never cross the face band (y 10-14) from any camera angle
		orb(1, 8.5, 15.8, 0.4, "cube")
		orb(2, -8.5, 6.0, 0.4, "cube")
		orb(3, 6.2, 5.0, 6.6, "crystal")
		orb(4, -6.2, 15.5, 6.6, "column")

		------------------------------------------------------------------
		-- TIDAL TWIRL VFX (hidden): a spiral water ribbon that whirls round
		-- the body during the pirouette, and a voxel bubble ring blown out of
		-- the snout at the apex.
		------------------------------------------------------------------
		local SWC = v(0, 8.0, 0.4)
		local swirl = B:bone("Swirl", "Root", SWC)
		for k = 0, 11 do
			local a = rad(k * 60)
			local y = 4.4 + k * 0.75
			local r = 3.3 + 0.2 * sin(k)
			B:block(swirl, v(3.5, 0.4, 0.5), cf(sin(a) * r, y, 0.4 + cos(a) * r, 0, k * 60, -10),
				k % 3 == 2 and WHITE or TURQ, { mat = "Neon", tr = 1, name = "Swirl" .. (k + 1) })
		end
		local BC = v(0, 10.6, -6.0)
		for k = 1, 8 do
			local bb = B:bone("Bub" .. k, "Root", BC)
			local s = k % 2 == 0 and 0.5 or 0.65
			B:block(bb, v(s, s, s), CFrame.new(BC), "#c8f8ff", { tr = 1, name = "BubP" .. k })
		end

		-- landing splash (stays on the ground)
		local splashAt = B:block("Root", v(4, 0.4, 4), cf(0, 1.4, 0), WHITE, { tr = 1, name = "SplashFX" })
		B:emitter(splashAt, "dust", { name = "LandSplash", color = { WHITE, "#bff6ff", AQUA }, size = { 1.5, 2.8, 3.5 }, speed = { 6, 11 }, life = { 0.5, 1.0 }, trans = { 0.35, 0.5, 1 } })
	end,
}
