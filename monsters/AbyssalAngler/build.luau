--!nocheck
-- Abyssal Anglerfish: a giant stud-built deep-sea angler. Chunky stepped teal
-- body, a HUGE underbite jaw full of white block needle teeth, a glowing lure
-- on a 3-bone stalk, stepped spiky fins and a few small cyan bio-dots.
return {
	DisplayName = "Abyssal Anglerfish",
	Rarity = "Legendary",
	Element = "Deep Sea",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local MAIN, DARK, BELLY, LIGHT = "#1d6f88", "#11455a", "#5fb8c4", "#b4f4ec"
		local WHITE, MOUTH, THROAT, TONGUE = "#f4f7f2", "#5c1424", "#140a10", "#d0506a"
		local CYAN, LURE = "#4dfff3", "#fff36b"
		local NEON = { mat = "Neon" }

		-- stepped voxel spine: stacked blocks that shrink and lean back, small neon tip
		local function spine(bone, x, y, z, steps, d, lean)
			for i = 0, steps - 1 do
				local dd = math.max(0.6, d * (1 - i / (steps + 0.5)))
				local w = math.max(0.6, 1.0 - i * 0.1)
				B:block(bone, v(w, 1.1, dd), cf(x, y + i * 1.05 + 0.55, z + lean * i), i == 0 and MAIN or LIGHT)
			end
			B:block(bone, v(0.5, 0.5, 0.5), cf(x, y + steps * 1.05 + 0.2, z + lean * steps), CYAN, NEON)
		end
		-- stepped horn: a thick block beam + a thinner tip beam (no smooth shapes)
		local function horn(bone, a, m, b, w, col)
			B:beam(bone, a, m, w, w, col)
			B:beam(bone, m + (m - a).Unit * -0.15, b, w * 0.68, w * 0.68, col)
		end

		------------------------------------------------------------------
		-- Body = the big round head (upper skull + belly)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 9, 0))
		B:block(body, v(10, 4.6, 10.6), cf(0, 9.8, -1.2), MAIN) -- core
		B:block(body, v(8.4, 3.6, 0.5), cf(0, 9.9, -6.7), MAIN) -- face plate (rounds the front)
		B:block(body, v(8.4, 1.4, 8.8), cf(0, 12.8, -1.3), MAIN) -- upper step
		B:block(body, v(5.6, 1.0, 6.0), cf(0, 14.0, -1.6), DARK) -- crown cap
		B:block(body, v(8.0, 3.4, 0.8), cf(0, 9.9, 4.4), DARK) -- rear step
		B:block(body, v(10.2, 3.0, 4.8), cf(0, 6.1, 1.6), MAIN) -- belly behind the jaw
		B:block(body, v(8.6, 0.5, 4.2), cf(0, 4.45, 1.8), BELLY) -- belly plate
		B:block(body, v(10.1, 0.7, 0.4), cf(0, 7.85, -6.6), DARK) -- upper lip band
		B:block(body, v(8.8, 0.3, 6.4), cf(0, 7.4, -3.2), MOUTH) -- mouth roof
		B:block(body, v(8.0, 2.8, 0.3), cf(0, 6.2, -0.95), THROAT) -- throat
		B:block(body, v(1.8, 0.8, 1.8), cf(0, 14.85, -2.4), DARK) -- lure mount

		B:sym(function()
			-- stepped side panel (rounds the silhouette) + bio-dots
			B:block(body, v(0.6, 3.2, 9.0), cf(5.2, 10.2, -1.4), DARK)
			B:block(body, v(0.2, 0.5, 0.5), cf(5.55, 10.9, -3.6), CYAN, NEON)
			B:block(body, v(0.2, 0.5, 0.5), cf(5.55, 9.7, -1.4), CYAN, NEON)
			B:block(body, v(0.2, 0.5, 0.5), cf(5.55, 10.7, 0.8), CYAN, NEON)
			B:block(body, v(0.5, 0.5, 0.2), cf(3.0, 10.9, 4.85), CYAN, NEON)
			-- upper needle teeth (front row + side row)
			for _, tt in { { 0.7, 1.5 }, { 2.1, 1.0 }, { 3.5, 1.3 } } do
				B:block(body, v(0.5, tt[2], 0.5), cf(tt[1], 7.6 - tt[2] / 2, -6.1), WHITE)
			end
			for _, tt in { { -5.2, 1.0 }, { -4.0, 1.2 }, { -2.8, 0.8 }, { -1.6, 0.9 } } do
				B:block(body, v(0.5, tt[2], 0.5), cf(4.2, 7.6 - tt[2] / 2, tt[1]), WHITE)
			end
			-- eye: dark socket, glowing rectangle, slit pupil looking in at the lure
			B:block(body, v(2.3, 2.2, 0.3), cf(2.6, 10.35, -7.05), DARK)
			B:block(body, v(1.4, 1.6, 0.2), cf(2.6, 10.35, -7.25), CYAN, NEON)
			-- nostril
			B:block(body, v(0.6, 0.4, 0.2), cf(0.9, 8.85, -7.0), THROAT)
			-- head horns swept back (light, neon tip)
			horn(body, v(3.3, 12.6, -4.6), v(4.8, 14.9, -3.0), v(5.4, 16.1, -1.7), 1.4, LIGHT)
			B:block(body, v(0.6, 0.6, 0.6), cf(5.5, 16.4, -1.45, 30, 0, -20), CYAN, NEON)
		end)

		-- heavy brows + eyelids (cartoon blinks/expressions)
		B:sym(function(side)
			local brow = B:bone("Brow" .. side, "Body", v(2.6, 12.0, -7.3))
			B:block(brow, v(3.4, 1.6, 1.2), cf(2.6, 11.95, -7.3, 0, 0, 14), DARK)
			local pupil = B:bone("Pupil" .. side, "Body", v(2.6, 10.35, -7.38))
			B:block(pupil, v(0.55, 0.85, 0.1), cf(2.35, 10.25, -7.38), "#081018")
			local lid = B:bone("Lid" .. side, "Body", v(2.6, 12.0, -7.5))
			B:block(lid, v(1.6, 1.6, 0.2), cf(2.6, 11.95, -7.5), MAIN)
		end)

		-- dorsal spines (own bone so they ripple)
		local dorsal = B:bone("Dorsal", "Body", v(0, 13.6, 1.2))
		-- stepped sail stepping down the back + light spine rays with small neon tips
		for _, d in {
			{ v(0.6, 1.8, 2.2), v(0, 15.3, 0.4), v(0, 15.8, 0.1), v(0, 18.0, 1.1) },
			{ v(0.6, 2.0, 1.9), v(0, 14.4, 2.4), v(0, 15.2, 2.2), v(0, 17.0, 3.1) },
			{ v(0.6, 1.8, 1.6), v(0, 12.9, 4.1), v(0, 13.6, 3.9), v(0, 15.2, 4.8) },
		} do
			B:block(dorsal, d[1], CFrame.new(d[2]), DARK)
			B:beam(dorsal, d[3], d[4], 0.7, 0.7, LIGHT)
			B:block(dorsal, v(0.5, 0.5, 0.5), CFrame.new(d[4] + (d[4] - d[3]).Unit * 0.3), CYAN, NEON)
		end

		------------------------------------------------------------------
		-- Lure: 3-bone stalk + dangling glowing bulb
		------------------------------------------------------------------
		local l1 = B:bone("Lure1", "Body", v(0, 14.6, -2.4))
		B:beam(l1, v(0, 14.6, -2.4), v(0, 17.4, -3.6), 0.8, 0.8, MAIN)
		local l2 = B:bone("Lure2", "Lure1", v(0, 17.4, -3.6))
		B:block(l2, v(1.0, 1.0, 1.0), cf(0, 17.4, -3.6), LIGHT)
		B:beam(l2, v(0, 17.4, -3.6), v(0, 17.9, -7.0), 0.7, 0.7, MAIN)
		local l3 = B:bone("Lure3", "Lure2", v(0, 17.9, -7.0))
		B:block(l3, v(0.9, 0.9, 0.9), cf(0, 17.9, -7.0), LIGHT)
		B:beam(l3, v(0, 17.9, -7.0), v(0, 16.4, -9.4), 0.6, 0.6, MAIN)
		local bulb = B:bone("Bulb", "Lure3", v(0, 16.4, -9.4))
		B:block(bulb, v(0.4, 0.9, 0.4), cf(0, 16.05, -9.4), DARK)
		B:block(bulb, v(1.5, 0.45, 1.5), cf(0, 15.55, -9.4), LIGHT)
		local esca = B:block(bulb, v(1.4, 1.4, 1.4), cf(0, 14.65, -9.4), LURE, { mat = "Neon", name = "Esca" })
		B:block(bulb, v(0.7, 0.4, 0.7), cf(0, 13.8, -9.4), LIGHT)
		B:sym(function()
			B:beam(bulb, v(0.5, 14.2, -9.4), v(1.3, 13.4, -9.4), 0.3, 0.3, LIGHT) -- little filaments
		end)
		B:block(bulb, v(2.2, 2.2, 2.2), cf(0, 14.65, -9.4), LURE, { mat = "Neon", tr = 1, name = "LureFlash" })
		B:light(esca, { name = "LureLight", color = LURE, brightness = 1, range = 10 })
		B:emitter(esca, "sparkle", { name = "LureSparkle", color = { "#ffffff", LURE }, rate = 4 })
		B:trail(bulb, v(0, 15.1, -9.4), v(0, 14.2, -9.4), { name = "LureTrail", color = LURE, life = 0.3, trans = { 0.4, 1 } })

		------------------------------------------------------------------
		-- Jaw: huge underbite scoop
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Body", v(0, 7.3, 0.2))
		B:block(jaw, v(10.6, 1.8, 8.6), cf(0, 4.7, -4.2), MAIN) -- floor
		B:block(jaw, v(9.2, 0.5, 7.6), cf(0, 3.6, -4.4), BELLY) -- chin plate
		B:block(jaw, v(6.6, 0.5, 5.6), cf(0, 3.15, -4.6), LIGHT) -- chin plate 2
		B:block(jaw, v(10.6, 2.0, 1.0), cf(0, 6.55, -8.0), DARK) -- front lip
		B:block(jaw, v(9.4, 1.2, 0.3), cf(0, 4.7, -8.6), BELLY) -- chin band
		B:block(jaw, v(9.0, 0.2, 7.0), cf(0, 5.7, -4.1), MOUTH) -- mouth floor
		B:block(jaw, v(3.2, 0.5, 4.0), cf(0, 5.95, -3.4), TONGUE)
		B:sym(function()
			B:block(jaw, v(0.8, 1.9, 8.0), cf(4.9, 6.5, -4.3), DARK) -- side wall
			for _, tt in { { 0.8, 1.6 }, { 2.2, 1.1 }, { 3.6, 1.5 } } do
				B:block(jaw, v(0.55, tt[2], 0.55), cf(tt[1], 7.45 + tt[2] / 2, -8.0), WHITE)
			end
			for _, tt in { { -7.0, 1.3 }, { -5.8, 0.9 }, { -4.6, 1.1 }, { -3.4, 0.7 }, { -2.2, 0.8 } } do
				B:block(jaw, v(0.5, tt[2], 0.5), cf(5.15, 7.35 + tt[2] / 2, tt[1]), WHITE)
			end
			B:block(jaw, v(0.2, 0.5, 0.5), cf(5.35, 4.7, -6.4), CYAN, NEON)
		end)
		local mouthFX = B:block(jaw, v(6, 1, 1), cf(0, 7.0, -8.6), MAIN, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFX, "burst", { name = "ChompBurst", color = { "#ffffff", CYAN }, size = { 1.1, 0.7, 0 } })

		-- bubbles from the mouth (idle) + a big burst on the gulp
		local bubbleAt = B:block(body, v(7, 1.5, 1), cf(0, 7.4, -7.6), MAIN, { tr = 1, name = "BubbleFX" })
		B:emitter(bubbleAt, "bubble", { name = "IdleBubbles", color = { "#ffffff", "#bff9ff" }, rate = 2.5, dir = "Front", speed = { 1, 2.5 } })
		B:emitter(bubbleAt, "bubble", { name = "GulpBubbles", color = { "#ffffff", CYAN }, rate = 0, dir = "Front", speed = { 5, 13 }, size = { 0.5, 1.0, 1.3 }, spread = 70, life = { 0.8, 1.8 } })
		B:light(bubbleAt, { name = "MouthLight", color = CYAN, brightness = 0, range = 12 })
		local aura = B:block(body, v(9, 6, 9), cf(0, 10, -1), MAIN, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "AuraSparkle", color = { "#ffffff", CYAN }, rate = 3 })

		------------------------------------------------------------------
		-- Pectoral fins: stepped rows of blocks (pixel-art fan) with light tips
		------------------------------------------------------------------
		B:sym(function(side)
			local pec = B:bone("Pec" .. side, "Body", v(4.9, 7.2, 1.6))
			B:block(pec, v(1.4, 1.8, 1.8), cf(5.1, 7.2, 1.6), DARK)
			local fin = CFrame.new(5.5, 7.3, 1.9) * P.ang(0, 55, 0)
			for i, r in { { 1.65, 2.8 }, { 0.55, 3.7 }, { -0.55, 3.3 }, { -1.65, 2.3 } } do
				B:block(pec, v(0.4, 1.1, r[2]), fin * CFrame.new(0, r[1], r[2] / 2), i % 2 == 0 and DARK or MAIN)
			end
			B:block(pec, v(0.6, 0.5, 3.0), fin * CFrame.new(0, 2.3, 1.4), LIGHT) -- leading edge
			B:block(pec, v(0.55, 0.55, 0.55), fin * CFrame.new(0, 2.3, 3.1), CYAN, NEON)
			local gill = B:block(body, v(0.4, 1.4, 1.4), cf(5.4, 7.9, 1.0), MAIN, { tr = 1, name = "GillFX" .. side })
			B:emitter(gill, "bubble", { name = "GillBubbles" .. side, color = { "#ffffff", "#bff9ff" }, rate = 1.2, dir = side == "R" and "Right" or "Left", speed = { 0.5, 1.5 } })
		end)

		------------------------------------------------------------------
		-- Tail (2 segments) + voxel forked tail fin
		------------------------------------------------------------------
		local t1 = B:bone("Tail1", "Body", v(0, 9.4, 3.6))
		B:block(t1, v(6.4, 4.4, 5.0), cf(0, 9.4, 4.5), MAIN)
		B:block(t1, v(5.4, 0.6, 3.2), cf(0, 11.8, 5.4), DARK)
		B:block(t1, v(5.0, 0.5, 3.0), cf(0, 7.0, 5.3), BELLY)
		B:sym(function()
			B:block(t1, v(0.2, 0.5, 0.5), cf(3.25, 9.6, 5.5), CYAN, NEON)
		end)
		B:block(t1, v(0.8, 1.0, 1.8), cf(0, 6.4, 5.8), MAIN)
		B:block(t1, v(0.6, 1.0, 1.2), cf(0, 5.5, 6.3), LIGHT)
		local t2 = B:bone("Tail2", "Tail1", v(0, 9.4, 6.7))
		B:block(t2, v(4.4, 3.2, 4.6), cf(0, 9.4, 7.3), MAIN)
		B:block(t2, v(3.6, 0.5, 2.8), cf(0, 11.15, 8.1), DARK)
		spine(t2, 0, 11.3, 7.8, 1, 1.4, 0.3)
		local tf = B:bone("TailFin", "Tail2", v(0, 9.4, 9.3))
		B:block(tf, v(1.8, 3.6, 2.2), cf(0, 9.4, 9.5), DARK)
		B:block(tf, v(1.0, 6.8, 1.4), cf(0, 9.4, 11.2), MAIN)
		B:block(tf, v(1.1, 0.5, 1.5), cf(0, 9.4, 11.2), LIGHT)
		B:block(tf, v(0.9, 3.0, 1.4), cf(0, 12.9, 12.5), MAIN)
		B:block(tf, v(0.9, 2.6, 1.4), cf(0, 6.0, 12.5), MAIN)
		B:block(tf, v(0.8, 2.2, 1.4), cf(0, 14.6, 13.8), LIGHT)
		B:block(tf, v(0.8, 1.8, 1.3), cf(0, 5.0, 13.7), LIGHT)
		B:block(tf, v(0.5, 0.5, 0.5), cf(0, 15.9, 14.3), CYAN, NEON)
		B:block(tf, v(0.5, 0.5, 0.5), cf(0, 4.0, 14.2), CYAN, NEON)
		B:trail(tf, v(0, 15.6, 14.1), v(0, 13.8, 14.1), { name = "TailTrailU", color = CYAN, life = 0.25, trans = { 0.5, 1 } })
		B:trail(tf, v(0, 5.6, 14.0), v(0, 4.2, 14.0), { name = "TailTrailL", color = CYAN, life = 0.25, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- Floating teal voxel cubes (VFX)
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 9, 0))
		local spots = { { 12, 12.5, -3 }, { -11.5, 8, 4 }, { 9.5, 6.5, 10 }, { -9.5, 14.5, -7 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = i % 2 == 0 and 1.2 or 1.6
			B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), i % 2 == 0 and LIGHT or MAIN)
			B:block(ob, v(s + 0.1, s * 0.22, s + 0.1), cf(p[1], p[2], p[3]), CYAN, NEON)
		end
	end,
}
