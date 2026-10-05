--!nocheck
-- Thunderhorn Beetle: chunky stud-built rhino beetle. Blue head + thorax,
-- stepped violet elytra domes with gold rims and thin neon-yellow lightning
-- bolts, a massive lavender forked horn, a big toothy cartoon face, six
-- chunky legs, flight wings folded under the shell and floating cubes.
return {
	DisplayName = "Thunderhorn Beetle",
	Rarity = "Epic",
	Element = "Thunder",
	Build = function(RB, P)
		local v, cf = P.v, P.cf
		-- Authored at 1x, then scaled to pet-pen size (~14 studs tall) through this
		-- thin wrapper so every position, size and thickness shrinks together.
		local S = 0.88
		local function sc(x)
			if typeof(x) == "Vector3" then
				return x * S
			elseif typeof(x) == "CFrame" then
				return CFrame.new(x.Position * S) * (x - x.Position)
			end
			return x
		end
		local B = {}
		function B:bone(name, parent, pivot) return RB:bone(name, parent, sc(pivot)) end
		function B:block(bone, size, c, col, o) return RB:block(bone, sc(size), sc(c), col, o) end
		function B:wedge(bone, size, c, col, o) return RB:wedge(bone, sc(size), sc(c), col, o) end
		function B:gem(bone, size, c, col, o) return RB:gem(bone, sc(size), sc(c), col, o) end
		function B:beam(bone, a, b, w, h, col, o) return RB:beam(bone, sc(a), sc(b), w * S, (h or w) * S, col, o) end
		function B:spike(bone, a, b, w, d, col, o) return RB:spike(bone, sc(a), sc(b), w * S, (d or w) * S, col, o) end
		function B:trail(bone, a, b, o) return RB:trail(bone, sc(a), sc(b), o) end
		function B:emitter(part, preset, o) return RB:emitter(part, preset, o) end
		function B:light(part, o) return RB:light(part, o) end
		function B:sym(fn) return RB:sym(fn) end
		local BLUE, VIOLET, DARK, UNDER = "#3346d6", "#5a2bd1", "#1f237a", "#1a1b2e"
		local VIOLET_HI = "#6c3ce6"
		local GOLD, LAV, WHITE, MOUTH = "#f2c230", "#d6d0ff", "#f6f4ff", "#120f1c"
		local NEON, PUPIL, TONGUE, WING = "#ffe94a", "#120d33", "#e2507f", "#ffe066"

		------------------------------------------------------------------
		-- Body: dark underbody + abdomen core (the elytra cover the top)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 4.4, 1.0))
		B:block(body, v(7.6, 1.8, 8.4), cf(0, 3.2, 2.0), UNDER)
		B:block(body, v(5.4, 1.4, 1.4), cf(0, 3.8, 6.6), UNDER)
		B:block(body, v(9.0, 2.2, 8.0), cf(0, 5.0, 2.0), DARK)
		for i = 0, 2 do
			B:block(body, v(8.2, 0.3, 0.8), cf(0, 6.2, 0.4 + i * 1.9), VIOLET)
		end
		local aura = B:block(body, v(8, 3, 8), cf(0, 7, 2.5), DARK, { tr = 1, name = "AuraFX" })
		B:emitter(aura, "sparkle", { name = "Sparkles", color = { "#ffffff", NEON }, rate = 3 })
		B:emitter(aura, "spark", { name = "ChargeSparks", color = { "#ffffff", NEON }, rate = 22, enabled = false })
		B:emitter(aura, "spark", { name = "ShellCrackle", color = { "#ffffff", NEON }, rate = 2.5, size = { 0.25, 0.1, 0 } })

		------------------------------------------------------------------
		-- Pronotum (stepped thorax shield) + thorax horn + side spikes
		------------------------------------------------------------------
		local pro = B:bone("Pronotum", "Body", v(0, 6.0, -1.4))
		B:block(pro, v(8.8, 4.4, 5.4), cf(0, 6.2, -3.9), BLUE)
		B:block(pro, v(7.4, 1.2, 4.8), cf(0, 9.0, -3.8), BLUE)
		B:block(pro, v(5.2, 0.9, 3.6), cf(0, 10.05, -3.6), BLUE)
		B:block(pro, v(9.0, 0.4, 0.4), cf(0, 8.3, -1.25), GOLD)
		B:sym(function()
			B:block(pro, v(0.4, 3.0, 4.8), cf(4.45, 5.8, -3.9), DARK)
			B:block(pro, v(0.45, 0.4, 5.0), cf(4.5, 7.5, -3.9), GOLD)
			B:spike(pro, v(3.3, 9.1, -3.2), v(5.0, 10.3, -2.6), 0.9, 0.9, LAV)
			-- small neon lightning bolt on the dark side panel
			B:beam(pro, v(4.72, 6.9, -5.7), v(4.72, 5.7, -3.9), 0.14, 0.38, NEON, { mat = "Neon" })
			B:beam(pro, v(4.72, 5.65, -4.0), v(4.72, 6.4, -3.25), 0.14, 0.38, NEON, { mat = "Neon" })
			B:spike(pro, v(4.72, 6.4, -3.35), v(4.72, 4.7, -1.9), 0.14, 0.55, NEON, { mat = "Neon" })
		end)
		B:block(pro, v(2.2, 1.0, 2.2), cf(0, 10.9, -3.8), LAV)
		B:spike(pro, v(0, 11.0, -4.0), v(0, 12.0, -6.6), 1.6, 1.3, LAV)
		B:gem(pro, v(0.55, 0.55, 0.55), cf(0, 12.0, -6.6, 30, 0, 0), NEON)

		------------------------------------------------------------------
		-- Head: big cartoon face with a stepped muzzle
		------------------------------------------------------------------
		local head = B:bone("Head", "Pronotum", v(0, 5.8, -6.2))
		B:block(head, v(8.2, 5.0, 5.0), cf(0, 6.1, -8.6), BLUE)
		B:block(head, v(6.4, 0.7, 4.2), cf(0, 8.95, -8.4), BLUE)
		B:block(head, v(6.4, 1.5, 1.0), cf(0, 4.35, -11.6), BLUE) -- muzzle
		B:block(head, v(6.4, 1.2, 4.8), cf(0, 3.55, -9.6), MOUTH) -- mouth cavity
		B:sym(function()
			B:block(head, v(0.4, 3.2, 4.2), cf(4.2, 5.9, -8.6), DARK)
			B:spike(head, v(4.0, 5.0, -9.4), v(5.7, 5.5, -7.4), 0.9, 0.9, LAV)
			B:block(head, v(0.6, 0.4, 0.2), cf(0.9, 4.75, -12.15), MOUTH) -- nostril
			-- eye: glowing rectangle + dark pupil + shine + heavy brow
			B:block(head, v(1.9, 2.1, 0.3), cf(2.1, 6.85, -11.2), NEON, { mat = "Neon" })
			B:block(head, v(0.85, 1.35, 0.2), cf(1.85, 6.75, -11.4), PUPIL)
			B:block(head, v(0.35, 0.35, 0.1), cf(2.05, 7.2, -11.52), WHITE)
			B:block(head, v(2.6, 0.75, 0.7), cf(2.1, 8.3, -11.35, 0, 0, 17), DARK)
			-- teeth hanging from the muzzle (+ a big fang)
			B:block(head, v(0.7, 0.7, 0.45), cf(0.75, 3.25, -11.8), WHITE)
			B:block(head, v(0.7, 0.7, 0.45), cf(2.0, 3.25, -11.8), WHITE)
			B:block(head, v(0.75, 1.05, 0.5), cf(3.05, 3.1, -11.75), WHITE)
		end)

		------------------------------------------------------------------
		-- The massive forked rhino horn (2 bones), leaning forward
		------------------------------------------------------------------
		local horn1 = B:bone("Horn1", "Head", v(0, 9.1, -9.9))
		B:block(horn1, v(3.4, 0.7, 3.2), cf(0, 9.3, -9.9), GOLD)
		B:beam(horn1, v(0, 9.2, -9.9), v(0, 11.2, -10.7), 3.2, 3.2, LAV)
		B:block(horn1, v(2.95, 0.45, 2.95), cf(0, 11.05, -10.65, -22, 0, 0), GOLD)
		B:beam(horn1, v(0, 10.9, -10.6), v(0, 12.5, -11.1), 2.7, 2.7, LAV)
		local horn2 = B:bone("Horn2", "Horn1", v(0, 12.3, -11.05))
		B:beam(horn2, v(0, 12.2, -11.1), v(0, 13.3, -11.2), 2.2, 2.2, LAV)
		B:sym(function(side)
			B:beam(horn2, v(0.35, 12.8, -11.2), v(1.75, 15.1, -10.85), 1.3, 1.3, LAV)
			B:block(horn2, v(0.85, 0.85, 0.85), cf(1.85, 15.35, -10.8, 0, 0, -31), NEON, { mat = "Neon" })
			B:trail(horn2, v(1.9, 15.6, -10.8), v(1.6, 14.9, -10.9), { name = "HornTrail" .. side, color = { "#ffffff", NEON }, life = 0.22, trans = { 0.35, 1 } })
		end)
		local hornFX = B:block(horn2, v(3.0, 1.2, 1.2), cf(0, 14.4, -11.0), LAV, { tr = 1, name = "HornFX" })
		B:emitter(hornFX, "spark", { name = "HornSparks", color = { "#ffffff", NEON }, rate = 5 })
		B:emitter(hornFX, "burst", { name = "TossBurst", color = { "#ffffff", NEON } })
		B:light(hornFX, { name = "HornLight", color = NEON, brightness = 0, range = 12 })
		-- zig-zag lightning bolt shot up from the fork (hidden until each toss)
		local bolt = { v(0, 13.7, -11.1), v(1.3, 15.4, -11.2), v(-0.9, 16.9, -11.2), v(1.0, 18.6, -11.2), v(-0.5, 20.4, -11.2) }
		for i = 1, 4 do
			B:beam(horn2, bolt[i], bolt[i + 1], 0.7, 0.7, NEON, { mat = "Neon", tr = 1, name = "Bolt" .. i })
		end

		------------------------------------------------------------------
		-- Eyelids (blink) + antennae with gold clubs
		------------------------------------------------------------------
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(2.1, 8.0, -11.55))
			B:block(lid, v(2.0, 0.3, 2.2), cf(2.1, 8.0, -10.45), BLUE)
			local ant = B:bone("Ant" .. side, "Head", v(3.6, 8.4, -10.4))
			B:beam(ant, v(3.4, 8.2, -10.2), v(4.6, 10.0, -11.0), 0.5, 0.5, DARK)
			B:beam(ant, v(4.6, 10.0, -11.0), v(5.8, 10.6, -12.0), 0.45, 0.45, DARK)
			B:block(ant, v(1.1, 0.3, 1.0), cf(6.0, 10.5, -12.2), GOLD)
			B:block(ant, v(1.1, 0.3, 1.0), cf(6.0, 10.95, -12.2), GOLD)
		end)

		------------------------------------------------------------------
		-- Jaw: big toothy grin + little lavender mandibles
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", v(0, 3.4, -7.4))
		B:block(jaw, v(6.8, 1.3, 5.2), cf(0, 2.15, -10.0), BLUE)
		B:block(jaw, v(6.2, 0.4, 4.6), cf(0, 1.35, -9.9), DARK)
		B:block(jaw, v(6.2, 0.3, 4.8), cf(0, 2.9, -10.0), MOUTH)
		B:block(jaw, v(2.8, 0.25, 2.6), cf(0, 3.1, -9.6), TONGUE)
		B:sym(function()
			B:block(jaw, v(0.65, 0.6, 0.45), cf(1.35, 3.2, -12.2), WHITE)
			B:block(jaw, v(0.65, 0.6, 0.45), cf(2.55, 3.2, -12.2), WHITE)
			B:spike(jaw, v(3.3, 2.2, -11.6), v(2.2, 2.4, -13.8), 0.9, 0.8, LAV)
		end)

		------------------------------------------------------------------
		-- Elytra (stepped wing-case domes) + flight wings folded underneath
		------------------------------------------------------------------
		B:sym(function(side)
			local ely = B:bone("Elytron" .. side, "Body", v(0.15, 7.4, -1.6))
			-- stepped dome: 4 layers shrinking toward the top + rounded rear
			B:block(ely, v(5.05, 1.6, 8.6), cf(2.675, 6.2, 2.7), VIOLET)
			B:block(ely, v(4.55, 1.4, 7.8), cf(2.425, 7.7, 2.4), VIOLET)
			B:block(ely, v(3.65, 1.2, 6.4), cf(1.975, 9.0, 2.0), VIOLET)
			B:block(ely, v(2.25, 0.9, 4.6), cf(1.275, 10.05, 1.5), VIOLET_HI)
			B:block(ely, v(4.05, 1.2, 1.0), cf(2.175, 6.2, 7.5), VIOLET)
			B:block(ely, v(2.65, 0.8, 0.7), cf(1.475, 6.2, 8.35), VIOLET)
			B:block(ely, v(0.35, 0.4, 8.7), cf(5.2, 5.6, 2.7), GOLD)
			B:block(ely, v(4.1, 0.35, 0.35), cf(2.2, 5.75, 8.0), GOLD)
			B:block(ely, v(0.3, 0.3, 4.7), cf(0.3, 10.55, 1.5), GOLD)
			for k = 0, 2 do
				B:spike(ely, v(4.2, 8.3, 0.2 + k * 2.2), v(5.4, 9.3, 0.7 + k * 2.2), 0.7, 0.7, LAV)
			end
			-- thin neon lightning bolts: one along the side, one on top
			B:beam(ely, v(4.75, 8.1, -0.9), v(4.75, 7.35, 2.2), 0.14, 0.4, NEON, { mat = "Neon" })
			B:beam(ely, v(4.75, 7.3, 2.1), v(4.75, 8.05, 2.9), 0.14, 0.4, NEON, { mat = "Neon" })
			B:spike(ely, v(4.75, 8.0, 2.8), v(4.75, 7.2, 6.0), 0.14, 0.6, NEON, { mat = "Neon" })
			B:beam(ely, v(2.0, 10.55, -0.5), v(0.9, 10.55, 1.3), 0.4, 0.14, NEON, { mat = "Neon" })
			B:beam(ely, v(0.85, 10.55, 1.2), v(1.95, 10.55, 1.7), 0.4, 0.14, NEON, { mat = "Neon" })
			B:spike(ely, v(1.9, 10.55, 1.6), v(0.8, 10.55, 3.6), 0.14, 0.55, NEON, { mat = "Neon", up = v(1, 0, 0) })

			local wing = B:bone("Wing" .. side, "Body", v(0.9, 6.6, -1.2))
			B:block(wing, v(3.0, 0.2, 3.0), cf(2.3, 6.6, 0.4), WING, { tr = 0.1 })
			B:block(wing, v(4.2, 0.2, 3.1), cf(2.7, 6.6, 3.45), WING, { tr = 0.1 })
			B:block(wing, v(3.2, 0.2, 1.8), cf(2.5, 6.6, 5.9), WING, { tr = 0.1 })
			B:block(wing, v(2.0, 0.2, 1.0), cf(2.1, 6.6, 7.3), WING, { tr = 0.1 })
			B:block(wing, v(0.35, 0.34, 7.6), cf(4.25, 6.6, 2.8), GOLD)
			B:block(wing, v(0.24, 0.3, 6.6), cf(2.3, 6.6, 3.6), GOLD)
			B:trail(wing, v(2.1, 6.6, 7.8), v(3.4, 6.6, 6.6), { name = "WingTrail" .. side, color = { "#fff7c0", NEON }, life = 0.12, trans = { 0.55, 1 } })
		end)

		------------------------------------------------------------------
		-- Legs: 6 chunky legs, 3 bones each (femur, tibia, foot)
		------------------------------------------------------------------
		local legs = {
			{ "F", v(3.8, 3.6, -3.6), v(6.8, 4.6, -5.0), v(7.6, 1.0, -6.4), v(0.45, 0, -1) },
			{ "M", v(4.1, 3.5, 0.2), v(7.2, 4.6, 0.0), v(8.1, 1.0, -0.2), v(1, 0, -0.15) },
			{ "B", v(4.1, 3.5, 3.6), v(7.0, 4.6, 4.8), v(7.8, 1.0, 6.2), v(0.6, 0, 1) },
		}
		B:sym(function(side)
			for _, lg in legs do
				local n, hip, knee, ankle, dir = lg[1], lg[2], lg[3], lg[4], lg[5].Unit
				local femur = B:bone("Leg" .. n .. "1" .. side, "Body", hip)
				local fdir = (knee - hip).Unit
				B:beam(femur, hip - fdir * 0.8, knee, 1.8, 1.8, BLUE)
				local tibia = B:bone("Leg" .. n .. "2" .. side, "Leg" .. n .. "1" .. side, knee)
				local tdir = (ankle - knee).Unit
				B:block(tibia, v(1.9, 1.9, 1.9), CFrame.lookAt(knee, knee + v(dir.X, 0, dir.Z)), BLUE)
				B:beam(tibia, knee, ankle + tdir * 0.5, 1.4, 1.4, DARK)
				local outward = v(dir.X, 0, dir.Z).Unit
				local mid = knee + (ankle - knee) * 0.5
				B:spike(tibia, mid + outward * 0.5, mid + outward * 1.5 + v(0, -0.5, 0), 0.55, 0.55, LAV)
				local foot = B:bone("Leg" .. n .. "3" .. side, "Leg" .. n .. "2" .. side, ankle)
				local fc = v(ankle.X, 0.5, ankle.Z) + dir * 0.6
				B:block(foot, v(1.8, 1.0, 2.6), CFrame.lookAt(fc, fc + dir), BLUE)
				B:block(foot, v(1.6, 0.3, 1.0), CFrame.lookAt(fc + v(0, 0.55, 0) - dir * 0.5, fc + v(0, 0.55, 0)), GOLD)
				local side2 = v(-dir.Z, 0, dir.X)
				for k = -1, 1, 2 do
					local cp = v(ankle.X, 0.35, ankle.Z) + dir * 2.35 + side2 * (0.45 * k)
					B:wedge(foot, v(0.55, 0.7, 1.1), CFrame.lookAt(cp, cp + dir), WHITE)
				end
			end
		end)

		------------------------------------------------------------------
		-- Ground FX (landing dust + spark pop)
		------------------------------------------------------------------
		local ground = B:block("Root", v(10, 0.2, 12), cf(0, 0.1, 1.5), DARK, { tr = 1, name = "GroundFX" })
		B:emitter(ground, "dust", { name = "LandDust", color = "#e4dccb" })
		B:emitter(ground, "burst", { name = "LandBurst", color = { "#ffffff", NEON } })

		------------------------------------------------------------------
		-- Floating voxel cubes (blue + gold) orbiting the beetle
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 7, 1))
		local spots = { { 10.0, 9.5, -1.5 }, { -9.5, 6.5, 2.5 }, { 8.0, 4.5, 7 }, { -7.5, 11.0, -5.5 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = i % 2 == 0 and 1.3 or 1.7
			B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), i % 2 == 0 and GOLD or BLUE)
			B:block(ob, v(s + 0.1, 0.22, s + 0.1), cf(p[1], p[2], p[3]), NEON, { mat = "Neon" })
		end
	end,
}
