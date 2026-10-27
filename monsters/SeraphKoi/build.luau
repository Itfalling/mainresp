--!nocheck
-- Seraph Koi: a holy flying koi fish with six angel wings, a gold halo,
-- whiskers and a big fan tail. Stud style, floats ~3 studs off the ground.
return {
	DisplayName = "Seraph Koi",
	Rarity = "Divine",
	Element = "Holy Water",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local WHITE, CREAM, ORANGE, RED = "#f7f4ee", "#efe2c8", "#ff7a2a", "#e8442e"
		local DORANGE, GOLD, DGOLD, BLACK = "#c9551c", "#f2c230", "#c98a1c", "#14121a"
		local MOUTH, GLOW, SKY = "#b8324a", "#ffe27a", "#9fe3ff"

		------------------------------------------------------------------
		-- Body chain (center of the fish is Body1; head forward, tail back)
		------------------------------------------------------------------
		local body = B:bone("Body1", "Root", v(0, 9, -2))
		B:block(body, v(5.6, 5.4, 4.6), cf(0, 9, -0.3), WHITE)
		B:block(body, v(4.4, 0.6, 3.8), cf(0, 6.05, -0.3), CREAM)
		B:block(body, v(4.2, 0.6, 3.2), cf(0, 11.95, -0.5), ORANGE)
		B:block(body, v(2.4, 0.6, 2.2), cf(0.6, 12.5, -0.2), RED)
		-- koi patches: orange on the right, red on the left (koi are never symmetric)
		B:block(body, v(0.4, 2.6, 2.8), cf(2.95, 9.8, 0.1), ORANGE)
		B:block(body, v(0.4, 1.4, 1.4), cf(3.0, 8.1, -1.6), RED)
		B:block(body, v(0.4, 2.2, 2.2), cf(-2.95, 9.4, -0.8), RED)
		B:block(body, v(0.4, 1.2, 1.4), cf(-2.95, 10.9, 1.2), ORANGE)
		-- stepped scale rows (color blocking, not part spam)
		B:sym(function()
			B:block(body, v(0.3, 0.6, 3.6), cf(2.9, 7.3, -0.3), CREAM)
		end)
		-- dorsal fin
		B:tri(body, v(0, 11.9, -2.2), v(0, 15.2, -0.2), v(0, 11.9, 2.0), 0.6, ORANGE)
		B:tri(body, v(0, 12.2, -1.4), v(0, 14.2, -0.4), v(0, 12.2, 0.8), 0.7, WHITE)
		B:block(body, v(0.5, 0.5, 0.5), cf(0, 15.0, -0.2), GLOW, { mat = "Neon" })
		local core = B:block(body, v(4, 4, 4), cf(0, 9, -0.3), WHITE, { tr = 1, name = "HolyFX" })
		B:emitter(core, "burst", { name = "HolyBurst", color = { "#ffffff", GLOW, SKY } })
		B:emitter(core, "sparkle", { color = { "#ffffff", GLOW }, rate = 4 })
		B:light(core, { name = "HolyLight", color = GLOW, brightness = 0, range = 16 })

		local body2 = B:bone("Body2", "Body1", v(0, 9, 2))
		B:block(body2, v(4.6, 4.6, 3.8), cf(0, 9, 3.7), WHITE)
		B:block(body2, v(3.4, 0.6, 2.6), cf(0, 11.55, 3.6), ORANGE)
		B:block(body2, v(0.4, 1.8, 2.0), cf(2.45, 9.2, 4.0), RED)
		B:block(body2, v(0.4, 2.0, 2.4), cf(-2.45, 9.6, 3.4), ORANGE)
		B:block(body2, v(3.6, 0.5, 3.0), cf(0, 6.5, 3.7), CREAM)

		local tail1 = B:bone("Tail1", "Body2", v(0, 9, 5.5))
		B:block(tail1, v(3.4, 3.4, 3.2), cf(0, 9, 7.0), WHITE)
		B:block(tail1, v(2.4, 0.5, 2.2), cf(0, 10.9, 6.9), RED)
		B:block(tail1, v(0.4, 1.4, 1.6), cf(1.85, 9.1, 7.2), ORANGE)

		local tail2 = B:bone("Tail2", "Tail1", v(0, 9, 8.5))
		B:block(tail2, v(2.2, 2.4, 2.8), cf(0, 9, 9.8), WHITE)
		B:block(tail2, v(1.6, 0.4, 1.8), cf(0, 10.35, 9.8), ORANGE)

		-- big flowing fan tail (two lobes) with white tips and gold edge
		local fin = B:bone("TailFin", "Tail2", v(0, 9, 11))
		B:block(fin, v(1.2, 1.6, 1.4), cf(0, 9, 11.4), ORANGE)
		B:poly(fin, { v(0, 9.6, 11.2), v(0, 15.6, 15.6), v(0, 13.4, 17.2), v(0, 9.6, 13.4) }, 0.6, ORANGE)
		B:poly(fin, { v(0, 8.4, 11.2), v(0, 8.4, 13.4), v(0, 4.6, 17.2), v(0, 2.4, 15.6) }, 0.6, ORANGE)
		B:tri(fin, v(0, 14.4, 15.4), v(0, 15.6, 15.6), v(0, 13.4, 17.2), 0.7, WHITE)
		B:tri(fin, v(0, 3.6, 15.4), v(0, 2.4, 15.6), v(0, 4.6, 17.2), 0.7, WHITE)
		B:tri(fin, v(0, 11.2, 12.6), v(0, 13.6, 15.4), v(0, 10.6, 14.8), 0.7, DORANGE)
		B:tri(fin, v(0, 6.8, 12.6), v(0, 7.4, 14.8), v(0, 4.4, 15.4), 0.7, DORANGE)
		B:block(fin, v(0.5, 0.5, 0.5), cf(0, 15.5, 15.7), GLOW, { mat = "Neon" })
		B:block(fin, v(0.5, 0.5, 0.5), cf(0, 2.5, 15.7), GLOW, { mat = "Neon" })
		B:trail(fin, v(0, 15.2, 15.8), v(0, 13.6, 16.8), { name = "TailTrailTop", color = { GLOW, SKY }, life = 0.3, trans = { 0.45, 1 } })
		B:trail(fin, v(0, 2.8, 15.8), v(0, 4.4, 16.8), { name = "TailTrailBot", color = { GLOW, SKY }, life = 0.3, trans = { 0.45, 1 } })

		------------------------------------------------------------------
		-- Head, mouth, whiskers, eyes, halo
		------------------------------------------------------------------
		local head = B:bone("Head", "Body1", v(0, 9, -2.6))
		B:block(head, v(5.2, 4.8, 4.2), cf(0, 9.1, -4.6), WHITE)
		B:block(head, v(4.2, 3.6, 1.4), cf(0, 8.9, -7.3), WHITE)
		B:block(head, v(3.2, 2.4, 0.8), cf(0, 8.6, -8.4), CREAM)
		B:block(head, v(3.8, 0.6, 3.2), cf(0, 11.75, -4.9), ORANGE)
		B:block(head, v(2.2, 0.6, 1.6), cf(-0.6, 11.75, -6.9), RED)
		B:block(head, v(1.4, 0.4, 1.4), cf(1.0, 12.2, -4.6), RED)
		-- open "O" fish mouth
		B:block(head, v(2.0, 1.0, 0.3), cf(0, 8.25, -8.85), MOUTH)
		B:block(head, v(2.6, 0.5, 0.9), cf(0, 9.0, -8.6), ORANGE) -- upper lip
		-- forehead gem
		B:block(head, v(0.7, 0.7, 0.3), cf(0, 10.6, -7.95, 0, 0, 45), GLOW, { mat = "Neon", name = "ForeheadGem" })
		B:block(head, v(1.1, 1.1, 0.25), cf(0, 10.6, -7.88, 0, 0, 45), GOLD)
		B:sym(function(side)
			-- big cartoon eye: white, black pupil, tiny glint
			B:block(head, v(0.4, 2.2, 2.2), cf(2.55, 9.8, -5.9), "#ffffff")
			B:block(head, v(0.42, 1.4, 1.2), cf(2.6, 9.6, -6.2), BLACK)
			B:block(head, v(0.44, 0.45, 0.45), cf(2.63, 10.05, -6.5), GLOW, { mat = "Neon" })
			-- gill plate
			B:block(head, v(0.4, 3.0, 0.5), cf(2.65, 8.9, -3.0), CREAM)
			-- eyelid (sits as an orange brow, drops for blinks)
			local lid = B:bone("Lid" .. side, "Head", v(2.6, 11.3, -5.9))
			B:block(lid, v(0.5, 0.8, 2.5), cf(2.62, 11.3, -5.9), ORANGE)
			-- whiskers (barbels): two segments each
			local w1 = B:bone("WhiskerA" .. side, "Head", v(1.3, 8.4, -8.7))
			B:beam(w1, v(1.3, 8.4, -8.7), v(2.9, 7.4, -9.8), 0.55, 0.55, GOLD)
			local w2 = B:bone("WhiskerB" .. side, "WhiskerA" .. side, v(2.9, 7.4, -9.8))
			B:beam(w2, v(2.9, 7.4, -9.8), v(4.0, 5.6, -10.2), 0.5, 0.5, DGOLD)
			B:block(w2, v(0.45, 0.45, 0.45), cf(4.0, 5.6, -10.2), GLOW, { mat = "Neon" })
		end)
		local jaw = B:bone("Jaw", "Head", v(0, 8.0, -7.6))
		B:block(jaw, v(2.6, 0.6, 1.2), cf(0, 7.5, -8.3), ORANGE)
		B:block(jaw, v(1.8, 0.3, 0.8), cf(0, 7.9, -8.3), MOUTH)
		local mouthFX = B:block(jaw, v(1.2, 0.6, 0.4), cf(0, 8.2, -9.0), WHITE, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFX, "bubble", { name = "Bubbles", color = { "#ffffff", SKY }, rate = 3 })
		B:emitter(mouthFX, "burst", { name = "BubbleBurst", color = { "#ffffff", SKY }, speed = { 5, 10 }, size = { 0.7, 0.5, 0 } })

		-- halo floating above the head: gold blocks with tiny neon studs
		local halo = B:bone("Halo", "Head", v(0, 14.6, -5))
		B:ring(halo, cf(0, 14.6, -5, 10, 0, 0), 2.6, 10, v(1.5, 0.45, 0.45), GOLD)
		for i = 0, 4 do
			local a = i / 5 * math.pi * 2
			B:block(halo, v(0.35, 0.5, 0.35), CFrame.new(0, 14.6, -5) * P.ang(10, 0, 0) * CFrame.new(math.sin(a) * 2.6, 0.1, -math.cos(a) * 2.6), GLOW, { mat = "Neon", name = "HaloGem" })
		end
		local haloFX = B:block(halo, v(4, 0.4, 4), cf(0, 14.6, -5), GOLD, { tr = 1, name = "HaloFX" })
		B:emitter(haloFX, "sparkle", { color = GLOW, rate = 3 })

		------------------------------------------------------------------
		-- Pectoral fins
		------------------------------------------------------------------
		B:sym(function(side)
			local pf = B:bone("Fin" .. side, "Body1", v(2.8, 7.4, -1.6))
			B:tri(pf, v(2.8, 7.6, -2.4), v(6.0, 5.4, 0.2), v(2.8, 7.4, 0.6), 0.5, ORANGE)
			B:tri(pf, v(4.6, 6.4, -0.8), v(6.0, 5.4, 0.2), v(4.4, 6.5, 0.4), 0.6, WHITE)
		end)

		------------------------------------------------------------------
		-- Six seraph wings (3 pairs) — white feathers, cream layer, gold tips
		------------------------------------------------------------------
		B:sym(function(side)
			-- upper pair: sweeps up and out
			local wu = B:bone("WingU" .. side, "Body1", v(2.6, 11.4, -1.2))
			B:poly(wu, { v(2.6, 11.0, -1.2), v(2.6, 12.0, -0.4), v(7.4, 17.4, 0.2), v(10.4, 16.2, 0.6), v(10.0, 13.0, 0.8), v(5.2, 11.0, 0.2) }, 0.5, WHITE)
			B:poly(wu, { v(3.4, 11.6, -0.9), v(7.6, 16.3, -0.5), v(9.4, 15.3, -0.3), v(5.4, 11.7, -0.6) }, 0.3, CREAM)
			B:block(wu, v(1.6, 0.9, 0.7), cf(9.8, 15.8, 0.6, 0, 0, 40), GOLD)
			B:block(wu, v(1.4, 0.8, 0.7), cf(10.2, 13.6, 0.8, 0, 0, 15), GOLD)
			B:block(wu, v(0.45, 0.45, 0.45), cf(10.5, 16.4, 0.6), GLOW, { mat = "Neon" })
			B:trail(wu, v(10.3, 16.4, 0.6), v(9.6, 13.4, 0.8), { name = "WingTrailU" .. side, color = { "#ffffff", GLOW }, life = 0.28, trans = { 0.5, 1 } })
			-- middle pair: straight out to the side, the longest
			local wm = B:bone("WingM" .. side, "Body1", v(2.8, 9.4, 0.4))
			B:poly(wm, { v(2.8, 10.0, 0.2), v(8.0, 11.0, 0.8), v(12.0, 10.4, 1.4), v(11.4, 8.0, 1.6), v(2.8, 8.6, 0.8) }, 0.5, WHITE)
			B:poly(wm, { v(3.6, 9.8, 0.0), v(8.2, 10.4, 0.5), v(10.8, 9.6, 0.9), v(3.6, 9.0, 0.4) }, 0.3, CREAM)
			B:block(wm, v(1.6, 0.9, 0.7), cf(11.6, 10.0, 1.5, 0, 0, 10), GOLD)
			B:block(wm, v(1.4, 0.8, 0.7), cf(11.0, 8.4, 1.6, 0, 0, -12), GOLD)
			B:block(wm, v(0.45, 0.45, 0.45), cf(12.3, 10.3, 1.5), GLOW, { mat = "Neon" })
			-- lower pair: sweeps down and out
			local wl = B:bone("WingL" .. side, "Body1", v(2.6, 7.2, 0.6))
			B:poly(wl, { v(2.6, 7.8, 0.6), v(5.6, 7.0, 1.2), v(8.6, 4.4, 1.8), v(6.6, 2.8, 1.8), v(2.6, 6.6, 1.0) }, 0.5, WHITE)
			B:poly(wl, { v(3.4, 7.2, 0.4), v(5.6, 6.5, 0.9), v(7.4, 4.4, 1.3), v(3.4, 6.6, 0.6) }, 0.3, CREAM)
			B:block(wl, v(1.4, 0.8, 0.7), cf(7.8, 3.6, 1.8, 0, 0, -40), GOLD)
			B:block(wl, v(0.45, 0.45, 0.45), cf(8.4, 4.2, 1.8), GLOW, { mat = "Neon" })
		end)

		------------------------------------------------------------------
		-- Floating voxel cubes (VFX)
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 9, 1))
		local spots = { { 12, 13, -2 }, { -12.5, 8, 2 }, { 9, 5, 8 }, { -8.5, 15, -5 } }
		local cols = { WHITE, ORANGE, CREAM, ORANGE }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = i % 2 == 0 and 1.2 or 1.6
			B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), cols[i])
			B:block(ob, v(s + 0.1, s * 0.25, s + 0.1), cf(p[1], p[2], p[3]), GLOW, { mat = "Neon" })
		end
	end,
}
