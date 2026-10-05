--!nocheck
-- Abyssal Anglerfish: a giant stud-built deep-sea angler. Chunky stepped teal
-- body, a HUGE underbite jaw full of white block needle teeth, a glowing lure
-- dangling from a long 3-bone stalk, stepped voxel dorsal plates, a solid
-- stepped swallow-tail and a single row of small cyan bio-dots. Neon is kept
-- to the eyes, the bulb, tips and a couple of thin strips.
return {
	DisplayName = "Abyssal Anglerfish",
	Rarity = "Legendary",
	Element = "Deep Sea",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local MAIN, DARK, BELLY, LIGHT = "#1d6f88", "#11455a", "#5fb8c4", "#b4f4ec"
		local WHITE, MOUTH, THROAT, TONGUE = "#f4f7f2", "#5c1424", "#140a10", "#d0506a"
		local CYAN, LURE, PUPIL = "#4dfff3", "#fff36b", "#081018"
		local NEON = { mat = "Neon" }

		-- stepped voxel dorsal plate: a MAIN base step, LIGHT steps that shrink
		-- and lean back, a small neon tip
		local function spine(bone, x, y, z, steps, d, lean)
			local dd, zo = d, 0
			for i = 0, steps - 1 do
				local w = math.max(0.6, 1.0 - i * 0.12)
				B:block(bone, v(w, 1.1, math.max(0.6, dd)), cf(x, y + i * 1.05 + 0.55, z + zo), i == 0 and MAIN or LIGHT)
				if i < steps - 1 then
					dd *= 0.66
					zo += lean
				end
			end
			B:block(bone, v(0.5, 0.5, 0.5), cf(x, y + steps * 1.05 + 0.15, z + zo + 0.25), CYAN, NEON)
		end
		-- stepped horn: a thick block beam + a thinner tip beam (no smooth shapes)
		local function horn(bone, a, m, b, w, col)
			B:beam(bone, a, m, w, w, col)
			B:beam(bone, m + (m - a).Unit * -0.15, b, w * 0.68, w * 0.68, col)
		end

		------------------------------------------------------------------
		-- Body = the big boxy head (upper skull + belly)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 9, 0))
		B:block(body, v(10, 4.6, 10.6), cf(0, 9.8, -1.2), MAIN) -- core
		B:block(body, v(8.4, 3.6, 0.5), cf(0, 9.9, -6.7), MAIN) -- face plate
		B:block(body, v(8.4, 1.4, 8.8), cf(0, 12.8, -1.3), MAIN) -- upper step
		B:block(body, v(5.6, 1.0, 6.0), cf(0, 14.0, -1.6), DARK) -- crown cap
		B:block(body, v(8.0, 3.4, 0.8), cf(0, 9.9, 4.4), DARK) -- rear step
		B:block(body, v(10.9, 3.0, 4.8), cf(0, 6.1, 1.6), MAIN) -- belly behind the jaw (covers the jaw hinge)
		B:block(body, v(8.6, 0.5, 4.2), cf(0, 4.45, 1.8), BELLY) -- belly plate
		B:block(body, v(10.1, 0.7, 0.4), cf(0, 7.85, -6.6), DARK) -- upper lip band
		B:block(body, v(8.8, 0.3, 6.4), cf(0, 7.4, -3.2), MOUTH) -- mouth roof
		B:block(body, v(8.0, 2.8, 0.3), cf(0, 6.2, -0.95), THROAT) -- throat
		B:block(body, v(1.8, 0.8, 1.8), cf(0, 14.85, -2.4), DARK) -- lure mount
		B:block(body, v(4.4, 0.4, 0.3), cf(0, 12.7, -5.8), LIGHT) -- forehead ridge accent

		B:sym(function()
			-- dark side panel + ONE tidy row of bio-dots + gill slits
			B:block(body, v(0.6, 3.2, 9.0), cf(5.2, 10.2, -1.4), DARK)
			for _, z in { -2.6, -1.0, 0.6 } do
				B:block(body, v(0.2, 0.5, 0.5), cf(5.6, 9.2, z), CYAN, NEON)
			end
			for _, z in { 1.6, 2.4 } do
				B:block(body, v(0.3, 2.2, 0.35), cf(5.6, 10.3, z), THROAT)
			end
			-- upper needle teeth: front row interlocks with the lower row, side row
			for _, tt in { { 1.5, 1.5 }, { 2.9, 1.1 }, { 4.3, 1.3 } } do
				B:block(body, v(0.5, tt[2], 0.5), cf(tt[1], 7.6 - tt[2] / 2, -6.1), WHITE)
			end
			B:block(body, v(0.6, 1.9, 0.6), cf(0.45, 7.6 - 0.95, -6.15), WHITE) -- buck fang
			for _, tt in { { -5.2, 1.0 }, { -4.0, 1.2 }, { -2.8, 0.8 }, { -1.6, 0.9 } } do
				B:block(body, v(0.5, tt[2], 0.5), cf(4.2, 7.6 - tt[2] / 2, tt[1]), WHITE)
			end
			-- FRONT EYE: dark socket, big glowing rectangle
			B:block(body, v(3.0, 2.9, 0.3), cf(2.7, 10.5, -7.05), DARK)
			B:block(body, v(2.0, 2.2, 0.2), cf(2.7, 10.5, -7.25), CYAN, NEON)
			-- SIDE EYE: wraps round the face so it reads from the side too
			B:block(body, v(0.25, 2.6, 2.2), cf(5.6, 10.6, -4.9), DARK)
			B:block(body, v(0.2, 1.8, 1.5), cf(5.75, 10.6, -5.05), CYAN, NEON)
			B:block(body, v(0.12, 1.0, 0.55), cf(5.88, 10.5, -5.45), PUPIL)
			-- nostril
			B:block(body, v(0.6, 0.4, 0.2), cf(0.9, 8.75, -7.0), THROAT)
			-- head horns swept back (light, neon tip)
			horn(body, v(3.3, 12.6, -4.6), v(4.8, 14.9, -3.0), v(5.4, 16.1, -1.7), 1.4, LIGHT)
			B:block(body, v(0.6, 0.6, 0.6), cf(5.5, 16.4, -1.45, 30, 0, -20), CYAN, NEON)
		end)

		-- heavy brows, pupils and eyelids (cartoon blinks/expressions)
		B:sym(function(side)
			local brow = B:bone("Brow" .. side, "Body", v(2.7, 12.1, -7.3))
			B:block(brow, v(3.8, 1.5, 1.2), cf(2.7, 12.15, -7.3, 0, 0, 14), DARK)
			local pupil = B:bone("Pupil" .. side, "Body", v(2.7, 10.5, -7.42))
			B:block(pupil, v(0.8, 1.2, 0.12), cf(2.45, 10.4, -7.42), PUPIL)
			-- eyelids are hidden until a blink / squint slides them down over the eye
			local lid = B:bone("Lid" .. side, "Body", v(2.7, 12.9, -7.5))
			B:block(lid, v(2.3, 2.5, 0.2), cf(2.7, 12.9, -7.52), MAIN, { tr = 1, name = "Eyelid" .. side })
			B:block(lid, v(0.2, 2.0, 1.7), cf(5.9, 12.6, -5.05), MAIN, { tr = 1, name = "EyelidS" .. side })
		end)

		-- dorsal plates (own bone so they ripple): stepped voxel plates down the back
		local dorsal = B:bone("Dorsal", "Body", v(0, 13.6, 1.2))
		spine(dorsal, 0, 14.4, 0.4, 3, 2.6, 0.4)
		spine(dorsal, 0, 13.4, 2.6, 3, 2.2, 0.4)
		spine(dorsal, 0, 11.9, 4.4, 2, 1.8, 0.4)

		------------------------------------------------------------------
		-- Lure: long 3-bone stalk arcing out in front + dangling glowing bulb
		------------------------------------------------------------------
		local l1 = B:bone("Lure1", "Body", v(0, 14.6, -2.4))
		B:beam(l1, v(0, 14.6, -2.4), v(0, 19.2, -3.2), 0.8, 0.8, MAIN)
		local l2 = B:bone("Lure2", "Lure1", v(0, 19.2, -3.2))
		B:block(l2, v(0.95, 0.95, 0.95), cf(0, 19.2, -3.2), DARK)
		B:beam(l2, v(0, 19.2, -3.2), v(0, 20.0, -7.6), 0.7, 0.7, MAIN)
		local l3 = B:bone("Lure3", "Lure2", v(0, 20.0, -7.6))
		B:block(l3, v(0.85, 0.85, 0.85), cf(0, 20.0, -7.6), DARK)
		B:beam(l3, v(0, 20.0, -7.6), v(0, 18.4, -11.0), 0.6, 0.6, MAIN)
		local bulb = B:bone("Bulb", "Lure3", v(0, 18.4, -11.0))
		B:block(bulb, v(0.4, 0.9, 0.4), cf(0, 18.05, -11.0), DARK)
		B:block(bulb, v(1.6, 0.45, 1.6), cf(0, 17.55, -11.0), LIGHT)
		local esca = B:block(bulb, v(1.4, 1.4, 1.4), cf(0, 16.65, -11.0), LURE, { mat = "Neon", name = "Esca" })
		B:block(bulb, v(0.8, 0.4, 0.8), cf(0, 15.8, -11.0), LIGHT)
		B:sym(function()
			B:beam(bulb, v(0.5, 16.2, -11.0), v(1.3, 15.4, -11.0), 0.3, 0.3, LIGHT) -- little filaments
		end)
		B:block(bulb, v(2.2, 2.2, 2.2), cf(0, 16.65, -11.0), LURE, { mat = "Neon", tr = 1, name = "LureFlash" })
		B:light(esca, { name = "LureLight", color = LURE, brightness = 0.7, range = 10 })
		B:emitter(esca, "sparkle", { name = "LureSparkle", color = { "#ffffff", LURE }, rate = 4 })
		B:trail(bulb, v(0, 17.1, -11.0), v(0, 16.2, -11.0), { name = "LureTrail", color = LURE, life = 0.3, trans = { 0.4, 1 } })

		------------------------------------------------------------------
		-- Jaw: huge underbite scoop with a stepped chin
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Body", v(0, 7.3, 0.2))
		B:block(jaw, v(10.6, 1.8, 8.6), cf(0, 4.7, -4.2), MAIN) -- floor
		B:block(jaw, v(9.2, 0.5, 7.6), cf(0, 3.6, -4.4), BELLY) -- chin plate
		B:block(jaw, v(6.6, 0.5, 5.6), cf(0, 3.15, -4.6), LIGHT) -- chin plate 2
		B:block(jaw, v(10.6, 2.0, 1.0), cf(0, 6.55, -8.0), DARK) -- front lip
		B:block(jaw, v(9.8, 0.9, 0.4), cf(0, 5.0, -8.65), BELLY) -- stepped chin row 1
		B:block(jaw, v(8.2, 0.8, 0.4), cf(0, 4.1, -8.55), LIGHT) -- stepped chin row 2
		B:block(jaw, v(5.0, 0.6, 0.4), cf(0, 3.3, -8.0), LIGHT) -- stepped chin row 3
		B:block(jaw, v(9.0, 0.2, 7.0), cf(0, 5.7, -4.1), MOUTH) -- mouth floor
		B:block(jaw, v(3.2, 0.5, 4.0), cf(0, 5.95, -3.4), TONGUE)
		B:block(jaw, v(1.6, 0.3, 1.4), cf(0, 6.3, -4.8), "#e57a90") -- tongue tip
		B:sym(function()
			B:block(jaw, v(0.8, 1.9, 8.0), cf(4.9, 6.5, -4.3), DARK) -- side wall
			B:block(jaw, v(0.2, 0.3, 4.2), cf(5.35, 5.35, -5.6), CYAN, NEON) -- thin jaw edge strip
			for _, tt in { { 0.8, 1.6 }, { 2.2, 1.1 }, { 3.6, 1.5 } } do
				B:block(jaw, v(0.55, tt[2], 0.55), cf(tt[1], 7.45 + tt[2] / 2, -8.0), WHITE)
			end
			for _, tt in { { -7.0, 1.3 }, { -5.8, 0.9 }, { -4.6, 1.1 }, { -3.4, 0.6 }, { -2.2, 0.6 } } do
				B:block(jaw, v(0.5, tt[2], 0.5), cf(5.15, 7.35 + tt[2] / 2, tt[1]), WHITE)
			end
		end)
		local mouthFX = B:block(jaw, v(6, 1, 1), cf(0, 7.0, -8.6), MAIN, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFX, "burst", { name = "ChompBurst", color = { "#ffffff", CYAN }, size = { 1.1, 0.7, 0 } })
		B:emitter(mouthFX, "burst", { name = "ChompCubes", color = { LIGHT, CYAN }, size = { 0.8, 0.6, 0 }, speed = { 10, 18 } })
		B:sym(function(side)
			B:trail(jaw, v(5.0, 7.3, -8.4), v(5.0, 4.0, -8.4), { name = "JawTrail" .. side, color = CYAN, life = 0.15, trans = { 0.5, 1 } })
		end)

		-- bubbles from the mouth (idle) + a big burst on the gulp
		local bubbleAt = B:block(body, v(7, 1.5, 1), cf(0, 7.4, -7.6), MAIN, { tr = 1, name = "BubbleFX" })
		B:emitter(bubbleAt, "bubble", { name = "IdleBubbles", color = { "#ffffff", "#bff9ff" }, rate = 2.5, dir = "Front", speed = { 1, 2.5 } })
		B:emitter(bubbleAt, "bubble", { name = "GulpBubbles", color = { "#ffffff", CYAN }, rate = 0, dir = "Front", speed = { 5, 13 }, size = { 0.5, 1.0, 1.3 }, spread = 70, life = { 0.8, 1.8 } })
		B:light(bubbleAt, { name = "MouthLight", color = CYAN, brightness = 0.01, range = 12 })
		local aura = B:block(body, v(9, 6, 9), cf(0, 10, -1), MAIN, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "AuraSparkle", color = { "#ffffff", CYAN }, rate = 3 })

		-- gulp shockwave: a ring of light slabs at the mouth (one bone each), hidden
		-- until the snap, then they burst outward
		local SC = v(0, 7.2, -9.2)
		for k = 1, 8 do
			local a = (k - 1) / 8 * 360
			local sb = B:bone("Shock" .. k, "Body", SC)
			B:block(sb, v(2.0, 0.6, 0.4), CFrame.new(SC) * P.ang(0, 0, a) * CFrame.new(0, 2.6, 0), LIGHT, { tr = 1, name = "Wave" .. k })
		end

		------------------------------------------------------------------
		-- Pectoral fins: stepped rows of blocks (pixel-art fan) facing forward-out
		------------------------------------------------------------------
		B:sym(function(side)
			local pec = B:bone("Pec" .. side, "Body", v(4.9, 8.6, 1.4))
			B:block(pec, v(1.4, 2.0, 2.0), cf(5.3, 8.6, 1.4), DARK)
			local fin = CFrame.new(5.75, 8.7, 1.5) * P.ang(0, 40, -15)
			for i, r in { { 1.65, 3.4 }, { 0.55, 4.5 }, { -0.55, 4.0 }, { -1.65, 2.8 } } do
				B:block(pec, v(0.5, 1.1, r[2]), fin * CFrame.new(0, r[1], r[2] / 2), i % 2 == 0 and BELLY or MAIN)
			end
			B:block(pec, v(0.5, 0.5, 2.0), fin * CFrame.new(0, 2.45, 1.0), LIGHT) -- leading edge
			B:block(pec, v(0.5, 0.5, 0.5), fin * CFrame.new(0, 0.55, 4.75), CYAN, NEON)
			local gill = B:block(body, v(0.4, 1.4, 1.4), cf(5.7, 10.3, 2.0), MAIN, { tr = 1, name = "GillFX" .. side })
			B:emitter(gill, "bubble", { name = "GillBubbles" .. side, color = { "#ffffff", "#bff9ff" }, rate = 1.2, dir = side == "R" and "Right" or "Left", speed = { 0.5, 1.5 } })
		end)

		------------------------------------------------------------------
		-- Tail (2 segments) + solid stepped swallow-tail fin
		------------------------------------------------------------------
		local t1 = B:bone("Tail1", "Body", v(0, 9.4, 3.6))
		B:block(t1, v(6.4, 4.4, 5.0), cf(0, 9.4, 4.5), MAIN)
		B:block(t1, v(5.4, 0.6, 3.2), cf(0, 11.8, 5.4), DARK)
		B:block(t1, v(5.0, 0.5, 3.0), cf(0, 7.0, 5.3), BELLY)
		B:sym(function()
			B:block(t1, v(0.3, 3.0, 0.6), cf(3.15, 9.5, 6.2), DARK) -- side band
		end)
		B:block(t1, v(0.8, 1.0, 1.8), cf(0, 6.4, 5.8), MAIN)
		B:block(t1, v(0.6, 1.0, 1.2), cf(0, 5.5, 6.3), LIGHT)
		local t2 = B:bone("Tail2", "Tail1", v(0, 9.4, 6.7))
		B:block(t2, v(4.4, 3.2, 4.6), cf(0, 9.4, 7.3), MAIN)
		B:block(t2, v(3.6, 0.5, 2.8), cf(0, 11.15, 8.1), DARK)
		B:block(t2, v(3.4, 0.4, 2.8), cf(0, 7.65, 7.6), BELLY)
		spine(t2, 0, 11.3, 7.6, 2, 1.6, 0.4)
		local tf = B:bone("TailFin", "Tail2", v(0, 9.4, 9.3))
		B:block(tf, v(1.8, 3.6, 1.6), cf(0, 9.4, 9.6), DARK) -- root
		-- stepped swallow-tail: short centre rows = the V notch, long outer rows = the lobes
		for _, r in {
			{ 0, 1.6, DARK, 1.3 },
			{ 1.1, 2.6, MAIN, 1.2 },
			{ 2.2, 3.6, DARK, 1.1 },
			{ 3.3, 4.4, LIGHT, 1.0 },
		} do
			for _, s in (r[1] == 0 and { 1 } or { 1, -1 }) do
				B:block(tf, v(r[4], 1.1, r[2]), cf(0, 9.4 + s * r[1], 10.0 + r[2] / 2), r[3])
			end
		end
		B:block(tf, v(0.6, 0.6, 0.6), cf(0, 12.85, 14.35), CYAN, NEON)
		B:block(tf, v(0.6, 0.6, 0.6), cf(0, 5.95, 14.35), CYAN, NEON)
		B:trail(tf, v(0, 13.4, 14.2), v(0, 11.6, 14.2), { name = "TailTrailU", color = CYAN, life = 0.25, trans = { 0.5, 1 } })
		B:trail(tf, v(0, 7.2, 14.2), v(0, 5.4, 14.2), { name = "TailTrailL", color = CYAN, life = 0.25, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- Floating voxel cubes drifting on the flanks (never in front of the face)
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 9, 2))
		local spots = { { 11, 12.5, -1 }, { -11, 8, 3 }, { 9.5, 6, 9 }, { -9.5, 14, 6 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = i % 2 == 0 and 1.3 or 1.7
			B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), DARK)
			B:block(ob, v(s + 0.1, s * 0.3, s + 0.1), cf(p[1], p[2] + s * 0.36, p[3]), LIGHT)
			B:block(ob, v(s + 0.16, s * 0.16, s + 0.16), cf(p[1], p[2] - s * 0.08, p[3]), CYAN, NEON)
		end
	end,
}
