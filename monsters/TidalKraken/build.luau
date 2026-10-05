--!nocheck
-- Tidal Kraken: a floating stud-built cartoon octopus. Big blocky head with a
-- bulging stepped mantle, coral spots, a crown of stepped fins, huge cartoon eyes
-- and a toothy beak grin. Eight 5-segment tentacles (teal top, cream underside,
-- coral suckers, curled hook tips).
-- VFX: bubbles, floating voxel cubes, a hidden blocky whirlpool for the Maelstrom.
return {
	DisplayName = "Tidal Kraken",
	Rarity = "Mythic",
	Element = "Ocean",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local TEAL, DARK, CORAL, CREAM = "#1f9c9a", "#136563", "#ff7a4d", "#f3e2c6"
		local WHITE, BLACK, OUTLINE, NEON = "#f7fbff", "#11171d", "#0c3a3c", "#ffb347"
		local TONGUE, AQUA, FOAM = "#e8546a", "#62dbe8", "#e6fbff"

		------------------------------------------------------------------
		-- Body (head): rounded voxel box, face on the front
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 11, 0))
		B:block(body, v(9, 5.6, 7), cf(0, 10.8, 0.5), TEAL) -- core X+-4.5 Y8..13.6 Z-3..4
		B:block(body, v(8, 5.2, 1.1), cf(0, 10.8, -3.5), TEAL) -- front slab, face at Z=-4.05
		B:block(body, v(8, 5.0, 0.8), cf(0, 10.8, 4.3), TEAL) -- back slab
		B:block(body, v(9.4, 0.8, 7.8), cf(0, 8.2, 0.4), DARK) -- dark base band
		B:block(body, v(8.6, 1.4, 7.4), cf(0, 14.1, 0.6), DARK) -- neck filler (hidden under the mantle)
		B:block(body, v(8.2, 0.5, 7.0), cf(0, 7.65, 0.4), CREAM) -- underside
		B:sym(function()
			B:block(body, v(0.3, 1.4, 1.4), cf(4.6, 11.4, 1.0), CORAL)
			B:block(body, v(0.2, 1.9, 1.9), cf(4.55, 11.4, 1.0), DARK) -- spot outline
			B:block(body, v(0.3, 0.7, 0.7), cf(4.6, 10.2, 2.2), CORAL)
		end)

		-- mouth: black grin, upper teeth, hooked cream beak
		B:block(body, v(6.2, 1.4, 0.4), cf(0, 9.0, -4.15), BLACK)
		B:sym(function()
			B:block(body, v(0.55, 0.6, 0.3), cf(1.3, 9.35, -4.4), WHITE)
			B:block(body, v(0.6, 1.1, 0.3), cf(2.05, 9.15, -4.4), WHITE) -- fang
			B:block(body, v(0.55, 0.6, 0.3), cf(2.8, 9.35, -4.4), WHITE)
		end)
		B:wedge(body, v(1.8, 1.3, 1.3), cf(0, 9.95, -4.7), CREAM) -- upper beak ramp
		B:block(body, v(1.8, 0.5, 1.3), cf(0, 9.05, -4.7), CREAM)
		B:spike(body, v(0, 9.1, -5.05), v(0, 8.0, -5.35), 1.5, 0.9, CREAM) -- beak hook

		------------------------------------------------------------------
		-- Eyes: socket outline, white, neon rim, pupil + glint, hinged lid, brow
		------------------------------------------------------------------
		local EY = 11.75
		B:sym(function(side)
			local eye = B:bone("Eye" .. side, "Body", v(2.35, EY, -4.1))
			B:block(eye, v(3.7, 4.1, 0.3), cf(2.35, EY, -4.15), OUTLINE)
			B:block(eye, v(3.2, 3.6, 0.5), cf(2.35, EY, -4.45), WHITE)
			B:block(eye, v(3.2, 0.3, 0.3), cf(2.35, EY - 1.95, -4.42), NEON, { mat = "Neon" })

			local pupil = B:bone("Pupil" .. side, "Eye" .. side, v(2.15, EY - 0.2, -4.7))
			B:block(pupil, v(1.7, 2.1, 0.3), cf(2.15, EY - 0.2, -4.8), BLACK)
			B:block(pupil, v(0.6, 0.6, 0.2), cf(2.55, EY + 0.4, -4.98), WHITE)
			B:block(pupil, v(0.3, 0.3, 0.2), cf(1.75, EY - 0.85, -4.98), WHITE)

			-- lid: lies flat (pointing back into the head) at rest, swings down +X to blink
			local lid = B:bone("Lid" .. side, "Eye" .. side, v(2.35, EY + 1.85, -5.1))
			B:block(lid, v(3.5, 0.4, 3.9), cf(2.35, EY + 1.65, -3.15), TEAL)
			B:block(lid, v(3.6, 0.5, 0.35), cf(2.35, EY + 1.6, -1.3), BLACK) -- lash line (bottom edge when closed)
			B:block(lid, v(3.55, 0.12, 1.0), cf(2.35, EY + 1.9, -4.6), DARK) -- rim line on top of the eye

			local brow = B:bone("Brow" .. side, "Body", v(2.35, EY + 2.2, -4.6))
			B:block(brow, v(3.8, 0.9, 1.4), cf(2.35, EY + 2.25, -4.55, 0, 0, 10), DARK)

			-- coral blush under the outer eye corner
			B:block(body, v(1.0, 0.6, 0.3), cf(4.0, 9.35, -4.1), CORAL)
		end)

		------------------------------------------------------------------
		-- Jaw (lower beak + lower teeth)
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Body", v(0, 8.7, -3.0))
		B:block(jaw, v(5.6, 0.8, 1.6), cf(0, 7.95, -3.95), CREAM)
		B:block(jaw, v(5.0, 1.0, 1.2), cf(0, 8.4, -3.3), BLACK) -- throat (shows when open)
		B:block(jaw, v(3.0, 0.3, 1.0), cf(0, 8.45, -3.9), TONGUE)
		B:sym(function()
			B:block(jaw, v(0.5, 0.55, 0.3), cf(0.75, 8.6, -4.55), WHITE)
			B:block(jaw, v(0.5, 0.75, 0.3), cf(1.6, 8.65, -4.55), WHITE)
			B:block(jaw, v(0.5, 0.55, 0.3), cf(2.45, 8.6, -4.55), WHITE)
		end)

		------------------------------------------------------------------
		-- Mantle: bulging stepped dome leaning back, big coral spots
		------------------------------------------------------------------
		local mantle = B:bone("Mantle", "Body", v(0, 13.6, 0.6))
		B:block(mantle, v(10.4, 2.0, 9.0), cf(0, 14.5, 1.0), TEAL) -- Y13.5..15.5 Z-3.5..5.5
		B:block(mantle, v(9.6, 1.6, 8.2), cf(0, 16.25, 1.8), TEAL) -- Y15.45..17.05 Z-2.3..5.9
		B:block(mantle, v(7.8, 1.1, 6.8), cf(0, 17.55, 2.3), TEAL) -- Y17.0..18.1 Z-1.1..5.7
		B:block(mantle, v(5.4, 0.6, 4.8), cf(0, 18.35, 2.5), DARK) -- Y18.05..18.65
		B:block(mantle, v(9.8, 0.4, 8.4), cf(0, 13.45, 1.0), DARK) -- shadow lip under the bulge
		B:block(mantle, v(9.7, 0.3, 8.3), cf(0, 15.55, 1.75), DARK) -- tier lip
		B:block(mantle, v(7.9, 0.3, 6.9), cf(0, 17.1, 2.3), DARK) -- tier lip
		B:block(mantle, v(1.6, 1.2, 0.3), cf(0, 14.6, -3.6), CORAL) -- forehead spot
		B:block(mantle, v(2.1, 1.7, 0.2), cf(0, 14.6, -3.55), DARK)
		B:sym(function()
			B:block(mantle, v(0.3, 1.6, 1.6), cf(5.25, 14.5, 1.4), CORAL)
			B:block(mantle, v(0.2, 2.1, 2.1), cf(5.2, 14.5, 1.4), DARK)
			B:block(mantle, v(0.3, 0.8, 0.8), cf(5.25, 14.9, 3.6), CORAL)
			B:block(mantle, v(1.6, 1.4, 0.3), cf(2.0, 14.5, 5.55), CORAL)
			B:block(mantle, v(2.1, 1.9, 0.2), cf(2.0, 14.5, 5.5), DARK)
			B:block(mantle, v(0.9, 0.9, 0.3), cf(3.2, 16.3, 5.95), CORAL)
			B:block(mantle, v(1.2, 0.9, 0.3), cf(2.6, 16.3, -2.45), CORAL)
			B:block(mantle, v(0.3, 0.8, 1.0), cf(3.95, 17.55, 3.4), CORAL)
		end)

		-- little stepped spines running down the back of the mantle
		for i, sp in { { 16.6, 5.9, 1.0 }, { 14.6, 5.5, 0.85 } } do
			local y, z, sc = sp[1], sp[2], sp[3]
			local base = CFrame.new(0, y, z) * P.ang(55, 0, 0)
			B:block(mantle, v(0.9, 1.2 * sc, 1.4 * sc), base * CFrame.new(0, 0.4 * sc, 0), CORAL)
			B:block(mantle, v(0.7, 1.0 * sc, 0.9 * sc), base * CFrame.new(0, 1.3 * sc, 0.15), CREAM)
		end

		-- stepped fin-ears sweeping up, out and back like horns (flap)
		B:sym(function(side)
			local ear = B:bone("Ear" .. side, "Mantle", v(4.6, 15.8, 2.2))
			B:block(ear, v(1.6, 2.0, 2.8), cf(5.0, 16.1, 2.3), TEAL)
			B:block(ear, v(1.4, 1.7, 2.3), cf(6.0, 17.2, 3.0), CORAL)
			B:block(ear, v(1.2, 1.4, 1.8), cf(6.75, 18.25, 3.7), CREAM)
			B:block(ear, v(0.9, 1.0, 1.2), cf(7.3, 19.15, 4.4), CREAM)
			B:block(ear, v(0.45, 0.45, 0.45), cf(7.65, 19.75, 4.85), NEON, { mat = "Neon" })
		end)

		-- crown: ring of five stepped triangular fins tilted outward (coral base,
		-- cream steps, tiny neon tip)
		local CC = v(0, 18.6, 2.5)
		local crown = B:bone("Crown", "Mantle", CC)
		for i = 0, 4 do
			local big = i == 0 and 1.2 or 1
			local base = CFrame.new(CC) * P.ang(0, -i * 72, 0) * CFrame.new(0, -0.1, -1.75) * P.ang(-20, 0, 0)
			B:block(crown, v(2.4, 0.9, 0.9), base * CFrame.new(0, 0.45, 0), CORAL)
			B:block(crown, v(1.6, 0.9 * big, 0.8), base * CFrame.new(0, 0.9 + 0.45 * big, 0), CREAM)
			B:block(crown, v(0.8, 0.8 * big, 0.7), base * CFrame.new(0, 0.9 + 0.9 * big + 0.4 * big, 0), CREAM)
			B:block(crown, v(0.4, 0.4, 0.4), base * CFrame.new(0, 0.9 + 1.7 * big + 0.2, 0), NEON, { mat = "Neon" })
		end

		------------------------------------------------------------------
		-- Tentacles: 8 x 5 segments (4 authored on the right, mirrored)
		------------------------------------------------------------------
		local DIRS = { -62, -46, -30, 15, 72 } -- rest angle of each segment (deg from horizontal)
		local LENS = { 1.8, 2.3, 2.4, 2.1, 1.8 }
		local WS = { 2.1, 1.85, 1.6, 1.35, 1.1 }
		local HS = { 1.7, 1.5, 1.3, 1.1, 0.95 }
		local SEGCOL = { DARK, TEAL, TEAL, TEAL, CORAL }
		local AZ = { 30, 70, 110, 150 } -- azimuth from forward (-Z) toward +X
		B:sym(function(side)
			for k, az in AZ do
				local rot = P.ang(0, -az, 0) -- local -Z points outward
				local function W(r, y)
					return (rot * CFrame.new(0, y, -r)).Position
				end
				local r, y = 3.1, 7.9
				local parent = "Body"
				for i = 1, 5 do
					local a = math.rad(DIRS[i])
					local dr, dy = math.cos(a), math.sin(a)
					local r2, y2 = r + LENS[i] * dr, y + LENS[i] * dy
					local name = ("T%dS%d%s"):format(k, i, side)
					local bn = B:bone(name, parent, CFrame.new(W(r, y)) * rot)
					local back = HS[i] * 0.35
					local fwd = 0.2
					local scf, len = P.span(W(r - dr * back, y - dy * back), W(r2 + dr * fwd, y2 + dy * fwd))
					local w, h = WS[i], HS[i]
					B:block(bn, v(w, h, len), scf, SEGCOL[i])
					if i >= 2 then
						B:block(bn, v(w + 0.1, 0.5, len - 0.25), scf * CFrame.new(0, -h / 2 + 0.2, 0), CREAM)
					end
					if i >= 3 then
						B:block(bn, v(0.7, 0.2, 0.7), scf * CFrame.new(0, -h / 2 - 0.15, i == 5 and -0.2 or 0), CORAL)
					end
					if i == 5 then
						-- hooked tip curling back inward
						local hd = math.rad(150)
						local hx, hy = r2 + 1.0 * math.cos(hd), y2 + 1.0 * math.sin(hd)
						local hcf, hlen = P.span(W(r2, y2), W(hx, hy))
						B:block(bn, v(0.85, 0.8, hlen + 0.3), hcf * CFrame.new(0, 0, 0.1), CORAL)
						B:block(bn, v(0.4, 0.4, 0.4), hcf * CFrame.new(0, -0.35, -hlen / 2 + 0.05), NEON, { mat = "Neon" })
						B:trail(bn, W(r2, y2 + 0.4), W(r2, y2 - 0.4), {
							name = "TipTrail" .. k,
							color = { FOAM, AQUA },
							life = 0.25,
							trans = { 0.5, 1 },
							light = 0.35,
						})
					end
					parent = name
					r, y = r2, y2
				end
			end
		end)

		------------------------------------------------------------------
		-- Floating voxel cubes (orbit + tumble)
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 11, 0))
		local spots = {
			{ 9.5, 17.5, -2, TEAL, AQUA },
			{ -10.0, 6.5, 3, CORAL, CREAM },
			{ 7.5, 5.5, 8.0, AQUA, TEAL },
			{ -7.0, 18.5, -6.0, TEAL, CORAL },
			{ 2.0, 20.0, 8.5, CORAL, AQUA },
		}
		for i, s in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(s[1], s[2], s[3]))
			local sz = i % 2 == 1 and 1.6 or 1.2
			B:block(ob, v(sz, sz, sz), cf(s[1], s[2], s[3]), s[4])
			B:block(ob, v(sz * 0.55, sz * 0.55, sz * 0.55), cf(s[1] + sz * 0.45, s[2] + sz * 0.45, s[3] - sz * 0.45), s[5])
		end

		------------------------------------------------------------------
		-- Maelstrom whirlpool (hidden blocky water rings, revealed by motion)
		------------------------------------------------------------------
		local swirl = B:bone("Swirl", "Root", v(0, 0, 0))
		for i = 0, 9 do
			local a = i * 36
			local c0 = CFrame.new(0, 1.0, 0) * P.ang(0, a, 0) * CFrame.new(0, 0, -8.5) * P.ang(0, 0, 14)
			B:block(swirl, v(3.6, 0.8, 1.2), c0, i % 3 == 0 and FOAM or AQUA, { tr = 1, name = "SwirlA" .. i })
		end
		for i = 0, 7 do
			local a = i * 45 + 22
			local c0 = CFrame.new(0, 3.2, 0) * P.ang(0, a, 0) * CFrame.new(0, 0, -6.2) * P.ang(0, 0, -18)
			B:block(swirl, v(2.8, 0.7, 1.0), c0, i % 2 == 0 and AQUA or FOAM, { tr = 1, name = "SwirlB" .. i })
		end

		------------------------------------------------------------------
		-- Effects
		------------------------------------------------------------------
		local aura = B:block(body, v(15, 11, 14), cf(0, 12.5, 0.5), TEAL, { tr = 1, name = "AuraVol" })
		B:emitter(aura, "bubble", { name = "Bubbles", color = { FOAM, AQUA }, rate = 3 })
		B:emitter(aura, "sparkle", { name = "Twinkles", color = { "#ffffff", NEON }, rate = 2 })
		local core = B:block(body, v(6, 4, 6), cf(0, 10, 0), TEAL, { tr = 1, name = "BurstVol" })
		B:emitter(core, "burst", { name = "WaterBurst", color = { FOAM, AQUA } })
		B:emitter(core, "bubble", { name = "SpinBubbles", color = { FOAM, AQUA }, rate = 45, speed = { 3, 7 }, spread = 180, enabled = false })
		B:light(core, { name = "SwirlLight", color = AQUA, brightness = 0, range = 16 })
		local mouthFx = B:block(jaw, v(2, 0.6, 0.6), cf(0, 8.6, -4.8), TEAL, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFx, "bubble", { name = "MouthBubbles", color = { FOAM, AQUA }, rate = 0, speed = { 1, 2.5 } })
		local under = B:block(body, v(7, 0.4, 6), cf(0, 7.3, 0.4), TEAL, { tr = 1, name = "UnderVol" })
		B:emitter(under, "drip", { name = "Drips", color = { FOAM, AQUA }, rate = 2.5 })
		local splash = B:block("Root", v(16, 0.4, 16), cf(0, 0.4, 0), TEAL, { tr = 1, name = "SplashVol" })
		B:emitter(splash, "dust", { name = "SplashSpray", color = { FOAM, AQUA } })
		B:emitter(splash, "burst", { name = "SplashDrops", color = { FOAM, AQUA }, speed = { 10, 18 }, spread = 40, accel = { 0, -35, 0 } })
	end,
}
