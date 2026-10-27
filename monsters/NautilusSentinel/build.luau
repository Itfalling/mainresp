--!nocheck
-- Nautilus Sentinel: a giant, CURIOUS & PLAYFUL nautilus that guards sunken
-- Atlantis. Its shell is a stepped voxel log-spiral of cream marble chambers
-- (core block + raised side ring + keel cap per chamber) with rust tiger
-- stripes on the older whorl, orichalcum gold hoops with thin turquoise edge
-- strips, glowing turquoise rune windows on the chambers and a gold
-- umbilicus boss. A tiny gold temple spire (marble columns around a
-- glowing crystal) sits on top. Out of the aperture peeks a cute face under a
-- spotted teal hood with a gold diadem: HUGE sparkly rectangle eyes, raised
-- brows, a little curious "o" mouth (swaps to a big surprised O or a happy
-- smile), happy-squint lids and 12 three-bone teal/cream tentacles.
-- Hidden face parts are swapped by the motion with ctx.transparency.
return {
	DisplayName = "Nautilus Sentinel",
	Rarity = "Epic",
	Element = "Atlantis",
	Build = function(B0, P)
		local v, cf, ang = P.v, P.cf, P.ang
		-- everything is authored around y = 9 and lifted by OY through this thin
		-- wrapper (positions only, never sizes)
		local OY = 0.8
		local function up(x)
			if typeof(x) == "Vector3" then return x + Vector3.new(0, OY, 0) end
			return CFrame.new(0, OY, 0) * x
		end
		local B = {}
		function B:block(bone, size, c, col, o) return B0:block(bone, size, up(c), col, o) end
		function B:beam(bone, a, b, w, h, col, o) return B0:beam(bone, up(a), up(b), w, h, col, o) end
		function B:bone(name, parent, pivot) return B0:bone(name, parent, up(pivot)) end
		function B:trail(bone, a, b, o) return B0:trail(bone, up(a), up(b), o) end
		function B:sym(fn) return B0:sym(fn) end
		function B:emitter(...) return B0:emitter(...) end
		function B:light(...) return B0:light(...) end
		local rad, cos, sin, exp, log = math.rad, math.cos, math.sin, math.exp, math.log

		-- palette
		local MARBLE, MARBLE2, WHITE = "#f4ead6", "#e3d2b2", "#fffaf0"
		local RUST, DRUST = "#d9682a", "#a8471c"
		local GOLD, BRONZE = "#f2b53a", "#b77a26"
		local TEAL, TEAL2, DTEAL, HOOD = "#2bb3a6", "#5fd0c0", "#13706b", "#1c8f87"
		local CREAM = "#f3e3c3"
		local BROW = "#10202a"
		local PUPIL, MOUTH, TONGUE, BLUSH = "#0d1a22", "#2a0f16", "#ff7a8a", "#ff9aa6"
		local TURQ, SKY, GLOW = "#3ff0e0", "#6fe3ff", "#ffe27a"
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- SHELL: log spiral in the YZ plane around the umbilicus C.
		-- clock angle a (deg, clockwise from up, +90 = back), psi runs along
		-- the coil from the aperture's lower lip (a = 240) back over the
		-- bottom, the back and the top to the aperture's upper lip (a = -60).
		------------------------------------------------------------------
		local C = v(0, 9.0, 1.5)
		local R0, GROW = 6.4, log(1.7) / 300
		local function r(psi) return R0 * exp(-GROW * psi) end
		local function dir(a) return v(0, cos(rad(a)), sin(rad(a))) end
		local function frameAt(a, rr) -- local Y = radial, local Z = tangential
			return CFrame.fromMatrix(C + dir(a) * rr, v(1, 0, 0), dir(a))
		end

		local shell = B:bone("Shell", "Root", C)
		local N, SPAN = 16, 300
		local DPSI = SPAN / N
		local W = 7.0
		local RUNES = { 1, 5, 7, 11, 13 }
		local SEAM = exp(-GROW * 360) -- previous whorl's rim, as a fraction of r
		for i = 1, N do
			local psi = (i - 0.5) * DPSI
			local a = 240 - psi
			local rr = r(psi)
			local alt = (i % 2) * 0.08
			local chord = 2 * sin(rad(DPSI / 2))
			local striped = psi > 75 and i % 2 == 0
			local deep = psi > 75 and i % 2 == 1 and i % 4 == 1
			-- core chamber (cream marble), from near the umbilicus to the rim
			local r0, r1 = 0.3 * rr, rr
			B:block(shell, v(W + alt, r1 - r0, rr * chord + 0.4), frameAt(a, (r0 + r1) / 2), MARBLE)
			-- raised side ring (outer whorl), leaves the umbilicus recessed
			local b0, b1 = SEAM * rr, 0.87 * rr
			local bx = (W + 1.2 + alt * 1.5) / 2
			B:block(shell, v(bx * 2, b1 - b0, b1 * chord + 0.35), frameAt(a, (b0 + b1) / 2), deep and MARBLE2 or MARBLE)
			-- rounded keel cap (tiger stripes wrap over the keel)
			B:block(shell, v(W - 1.6 + alt, 0.9, (rr + 0.7) * chord + 0.3), frameAt(a, rr + 0.25),
				striped and DRUST or (psi < 75 and WHITE or MARBLE))
			-- thin rust tiger-stripe flames running in from the rim (both sides)
			if striped then
				local f = frameAt(a, 0.77 * rr)
				for s = -1, 1, 2 do
					B:block(shell, v(0.2, 0.22 * rr, 0.7), f * CFrame.new(s * (bx + 0.08), 0, 0), RUST)
				end
			end
			-- rune windows on some chambers (both sides)
			local k = table.find(RUNES, i)
			if k then
				local f = frameAt(a, (SEAM + 0.87) / 2 * rr)
				for s = -1, 1, 2 do
					B:block(shell, v(0.3, 1.1, 1.1), f * CFrame.new(s * (bx + 0.1), 0, 0), BRONZE)
					B:block(shell, v(0.2, 0.6, 0.6), f * CFrame.new(s * (bx + 0.3), 0, 0), TURQ,
						{ mat = "Neon", name = "Rune" .. (s > 0 and k or k + 5) })
				end
			end
		end
		-- previous (inner) whorl: one full turn, raised a step less than the outer
		-- whorl so the side reads as a stepped spiral winding into the boss
		local NI = 12
		for i = 1, NI do
			local psi = SPAN + (i - 0.5) * (360 / NI)
			local a = 240 - psi
			local rr = r(psi)
			local r0, r1 = SEAM * rr, rr + 0.1
			local chord = 2 * sin(rad(180 / NI))
			B:block(shell, v(W + 0.55 + (i % 2) * 0.06, r1 - r0, r1 * chord + 0.3), frameAt(a, (r0 + r1) / 2),
				i % 2 == 0 and RUST or "#c45a22")
		end
		-- orichalcum gold hoops between chambers, a thin turquoise strip on the keel
		local hoopTop = {}
		for n, i in { 3, 7, 11, 15 } do
			local psi = i * DPSI
			local a = 240 - psi
			local rr = r(psi)
			B:block(shell, v(W + 1.5, rr * 0.2 + 0.9, 0.7), frameAt(a, rr * 0.9 + 0.45), GOLD)
			B:block(shell, v(1.2, 0.3, 0.5), frameAt(a, rr + 1.0), TURQ, NEON)
			hoopTop[n] = { a = a, rr = rr }
		end
		-- aperture lips (gold bottom, bronze top)
		do
			local rr = r(0)
			B:block(shell, v(W + 0.5, rr * 0.2 + 0.8, 0.7), frameAt(240, rr * 0.9 + 0.4) * CFrame.new(0, 0, 0.1), GOLD)
			B:block(shell, v(2.4, 0.3, 0.4), frameAt(240, rr + 0.95) * CFrame.new(0, 0, 0.1), TURQ, NEON)
			local ru = r(SPAN)
			B:block(shell, v(W + 1.0, ru * 0.6 + 0.6, 0.8), frameAt(-60, ru * 0.7 + 0.3) * CFrame.new(0, 0, -0.1), BRONZE)
		end
		-- hood "door": closes the aperture while the head hides inside the shell
		-- (hidden until the Sentinel Spiral)
		local door = CFrame.new(0, 8.35, -3.3) * ang(24, 0, 0)
		B:block(shell, v(W - 0.8, 5.6, 0.6), door, HOOD, { tr = 1, name = "Door1" })
		B:block(shell, v(W - 0.6, 0.45, 0.3), door * CFrame.new(0, 0.9, -0.38), GOLD, { tr = 1, name = "Door2" })
		B:block(shell, v(0.9, 0.9, 0.25), door * CFrame.new(0, 0.9, -0.55) * ang(0, 0, 45), GOLD, { tr = 1, name = "Door3" })
		B:block(shell, v(0.45, 0.45, 0.15), door * CFrame.new(0, 0.9, -0.7) * ang(0, 0, 45), TURQ, { mat = "Neon", tr = 1, name = "Door4" })
		B:block(shell, v(1.0, 0.8, 0.2), door * CFrame.new(1.6, -1.2, -0.38), CREAM, { tr = 1, name = "Door5" })
		B:block(shell, v(0.8, 0.7, 0.2), door * CFrame.new(-1.4, -0.4, -0.38), CREAM, { tr = 1, name = "Door6" })
		-- dark mantle cavity inside the aperture (shows when the head pulls in)
		B:block(shell, v(5.4, 4.2, 1.2), cf(0, 8.1, -1.6), "#2a3a3a")
		-- umbilicus boss on each side: bronze -> gold -> turquoise eye
		B:sym(function()
			local x = W / 2 + 0.3
			B:block(shell, v(0.8, 2.4, 2.4), cf(x, C.Y, C.Z), BRONZE)
			B:block(shell, v(0.5, 1.5, 1.5), cf(x + 0.4, C.Y, C.Z), GOLD)
			B:block(shell, v(0.2, 0.7, 0.7), cf(x + 0.7, C.Y, C.Z), TURQ, NEON)
		end)
		local shellFx = B:block(shell, v(6, 9, 10), cf(0, 9.5, 2), MARBLE, { tr = 1, name = "ShellFX" })
		B:emitter(shellFx, "sparkle", { name = "AmbientSparkle", color = { "#ffffff", TURQ, GLOW }, rate = 3 })
		B:emitter(shellFx, "burst", { name = "SpinBurst", color = { "#ffffff", TURQ, GLOW }, speed = { 10, 18 }, size = { 0.9, 0.6, 0 } })
		B:light(shellFx, { name = "RuneLight", color = TURQ, brightness = 0.3, range = 16 })
		local jet = B:block(shell, v(3, 0.4, 3), cf(0, 2.6, 1.5), MARBLE, { tr = 1, name = "JetFX" })
		B:emitter(jet, "bubble", {
			name = "JetBubbles", rate = 0, color = { "#ffffff", SKY }, size = { 0.5, 0.8, 0.9 }, speed = { 6, 12 },
			life = { 1.0, 2.0 }, spread = 40, dir = "Bottom", accel = { 0, 6, 0 }, drag = 1.5,
		})
		-- spin trails on two keel hoops
		for n, h in { hoopTop[2], hoopTop[4] } do
			local p0 = C + dir(h.a) * (h.rr + 1.1)
			B:trail(shell, p0 + v(1.2, 0, 0), p0 - v(1.2, 0, 0), { name = "KeelTrail" .. n, color = { GLOW, TURQ }, life = 0.22, trans = { 0.5, 1 } })
		end

		------------------------------------------------------------------
		-- TEMPLE SPIRE on top of the shell (own bone, jiggles)
		------------------------------------------------------------------
		local topY = C.Y + r(240) + 0.55
		local spire = B:bone("Spire", "Shell", v(0, topY, C.Z))
		B:block(spire, v(2.6, 0.7, 2.6), cf(0, topY + 0.2, C.Z), BRONZE)
		B:block(spire, v(2.0, 0.5, 2.0), cf(0, topY + 0.75, C.Z), GOLD)
		B:sym(function()
			B:block(spire, v(0.45, 0.8, 0.45), cf(0.65, topY + 1.4, C.Z - 0.65), WHITE)
			B:block(spire, v(0.45, 0.8, 0.45), cf(0.65, topY + 1.4, C.Z + 0.65), WHITE)
		end)
		local crystal = B:block(spire, v(0.6, 0.8, 0.6), cf(0, topY + 1.4, C.Z), TURQ, { mat = "Neon", name = "SpireCrystal" })
		B:light(crystal, { name = "SpireLight", color = TURQ, brightness = 0.6, range = 7 })
		B:block(spire, v(2.2, 0.5, 2.2), cf(0, topY + 2.0, C.Z), GOLD)
		B:block(spire, v(1.4, 0.5, 1.4), cf(0, topY + 2.45, C.Z), GOLD)
		B:block(spire, v(0.45, 0.5, 0.45), cf(0, topY + 2.9, C.Z), TURQ, NEON)
		B:trail(spire, v(0, topY + 3.1, C.Z - 0.2), v(0, topY + 2.4, C.Z - 0.2), { name = "SpireTrail", color = { TURQ, GLOW }, life = 0.3, trans = { 0.45, 1 } })

		------------------------------------------------------------------
		-- HEAD: peeks out of the aperture (pulls back in along +Z)
		------------------------------------------------------------------
		local head = B:bone("Head", "Shell", v(0, 8.4, -2.6))
		B:block(head, v(5.6, 4.6, 4.4), cf(0, 8.7, -4.2), TEAL) -- y 6.4..11, front z -6.4
		B:block(head, v(5.0, 1.1, 4.0), cf(0, 6.05, -4.15), CREAM) -- chin step, front z -6.15
		B:sym(function()
			B:block(head, v(0.25, 0.9, 0.9), cf(2.85, 9.6, -3.4), CREAM) -- side spots
			B:block(head, v(0.25, 0.6, 0.6), cf(2.85, 8.4, -4.6), CREAM)
			B:block(head, v(0.8, 0.4, 0.1), cf(2.25, 7.0, -6.45), BLUSH) -- blush
		end)
		-- spotted hood with a gold diadem
		local hood = B:bone("Hood", "Head", v(0, 11.0, -2.2))
		B:block(hood, v(6.2, 1.3, 5.0), cf(0, 11.55, -4.3), HOOD)
		B:block(hood, v(5.0, 0.7, 3.8), cf(0, 12.5, -3.9), HOOD)
		B:block(hood, v(6.4, 0.45, 0.6), cf(0, 11.12, -6.6), CREAM) -- pale hood rim (brows read against it)
		B:block(hood, v(5.2, 1.6, 3.8), cf(0, 10.6, -4.3), DTEAL) -- under-hood filler: no gap when it lifts
		B:block(hood, v(6.3, 0.4, 0.2), cf(0, 11.55, -6.88), GOLD) -- diadem band
		B:block(hood, v(1.1, 1.1, 0.25), cf(0, 11.7, -6.95, 0, 0, 45), GOLD)
		B:block(hood, v(0.55, 0.55, 0.15), cf(0, 11.7, -7.1, 0, 0, 45), TURQ, { mat = "Neon", name = "HoodGem" })
		B:block(hood, v(1.1, 0.2, 1.0), cf(1.6, 12.95, -4.4), CREAM)
		B:block(hood, v(0.8, 0.2, 0.8), cf(-1.3, 12.95, -3.2), CREAM)
		B:block(hood, v(0.6, 0.2, 0.6), cf(-0.4, 12.95, -5.1), CREAM)
		B:block(hood, v(0.25, 0.9, 1.0), cf(3.1, 11.6, -5.0), CREAM)
		B:block(hood, v(0.25, 0.7, 0.8), cf(-3.1, 11.5, -3.4), CREAM)
		-- little stepped gold crest
		B:block(hood, v(0.7, 0.5, 2.4), cf(0, 13.05, -3.8), GOLD)
		B:block(hood, v(0.5, 0.5, 1.4), cf(0, 13.5, -3.4), GOLD)

		-- EYES: huge sparkly rectangles
		B:sym(function(side)
			B:block(head, v(2.5, 3.0, 0.3), cf(1.4, 8.9, -6.5), DTEAL) -- frame
			B:block(head, v(2.2, 2.7, 0.3), cf(1.4, 8.9, -6.68), WHITE) -- sclera
			B:block(head, v(1.7, 2.1, 0.12), cf(1.35, 8.85, -6.86), TURQ, { mat = "Neon", name = "Eye" .. side })
			local pupil = B:bone("Pupil" .. side, "Head", v(1.35, 8.8, -6.95))
			B:block(pupil, v(1.1, 1.5, 0.1), cf(1.35, 8.8, -6.95), PUPIL, { name = "Pupil" .. side .. "Big" })
			B:block(pupil, v(0.55, 0.7, 0.1), cf(1.35, 8.8, -6.95), PUPIL, { tr = 1, name = "Pupil" .. side .. "Dot" })
			B:block(pupil, v(0.5, 0.5, 0.06), cf(1.65, 9.25, -7.02), "#ffffff", NEON)
			B:block(pupil, v(0.28, 0.28, 0.06), cf(1.0, 8.3, -7.02), "#ffffff", NEON)
			-- blink lid (hidden while open) + lash line
			local lid = B:bone("Lid" .. side, "Head", v(1.4, 10.4, -7.1))
			B:block(lid, v(2.6, 3.1, 0.2), cf(1.4, 8.9, -7.12), HOOD, { tr = 1, name = "Eyelid" .. side })
			B:block(lid, v(2.6, 0.3, 0.22), cf(1.4, 7.45, -7.14), DTEAL, { tr = 1, name = "Lash" .. side })
			-- happy closed eyes: a teal cover with a glowing "^" (hidden until happy)
			B:block(head, v(2.6, 3.1, 0.2), cf(1.4, 8.9, -7.22), TEAL, { tr = 1, name = "Happy" .. side .. "1" })
			B:block(head, v(1.45, 0.45, 0.12), cf(0.95, 9.0, -7.36, 0, 0, 38), TURQ, { mat = "Neon", tr = 1, name = "Happy" .. side .. "2" })
			B:block(head, v(1.45, 0.45, 0.12), cf(1.85, 9.0, -7.36, 0, 0, -38), TURQ, { mat = "Neon", tr = 1, name = "Happy" .. side .. "3" })
			-- brows
			local brow = B:bone("Brow" .. side, "Head", v(1.4, 10.6, -7.0))
			B:block(brow, v(2.3, 0.55, 0.4), cf(1.4, 10.62, -7.05), BROW)
			B:block(brow, v(1.1, 0.5, 0.4), cf(1.4, 10.95, -7.05), BROW) -- stepped arch (curious)
		end)
		-- MOUTH: curious little "o" (idle), big surprised O, happy smile
		B:block(head, v(0.9, 0.6, 0.12), cf(0, 6.85, -6.45), MOUTH, { name = "MouthO" })
		B:block(head, v(1.9, 1.5, 0.12), cf(0, 6.95, -6.47), MOUTH, { tr = 1, name = "MouthBig" })
		B:block(head, v(1.0, 0.45, 0.1), cf(0, 6.45, -6.53), TONGUE, { tr = 1, name = "MouthBigTongue" })
		B:block(head, v(1.5, 0.5, 0.12), cf(0, 6.8, -6.47), MOUTH, { tr = 1, name = "Smile1" })
		B:block(head, v(0.35, 0.35, 0.12), cf(0.9, 7.1, -6.47), MOUTH, { tr = 1, name = "Smile2" })
		B:block(head, v(0.35, 0.35, 0.12), cf(-0.9, 7.1, -6.47), MOUTH, { tr = 1, name = "Smile3" })
		B:block(head, v(0.8, 0.25, 0.1), cf(0, 6.65, -6.53), TONGUE, { tr = 1, name = "SmileTongue" })
		local faceFx = B:block(head, v(4, 3, 0.6), cf(0, 9, -5.2), TEAL, { tr = 1, name = "FaceFX" })
		B:emitter(faceFx, "burst", { name = "PopBurst", color = { "#ffffff", TURQ, SKY }, speed = { 8, 15 } })
		local starFx = B:block(head, v(5, 1, 3), cf(0, 14.2, -4.0), TEAL, { tr = 1, name = "StarFX" })
		B:emitter(starFx, "sparkle", {
			name = "DizzyStars", rate = 0, color = { GLOW, "#ffffff" }, size = { 0.5, 0.8, 0 }, speed = { 1.5, 3 },
			life = { 0.6, 1.1 }, spread = 60,
		})

		-- SIPHON (bubbles)
		local siphon = B:bone("Siphon", "Head", v(2.5, 6.8, -2.8))
		B:beam(siphon, v(2.3, 6.9, -2.6), v(3.4, 6.2, -3.3), 1.1, 1.1, CREAM)
		B:beam(siphon, v(3.2, 6.35, -3.15), v(3.75, 6.0, -3.5), 1.3, 1.3, TEAL2)
		local sipFx = B:block(siphon, v(0.6, 0.6, 0.6), cf(3.9, 5.9, -3.6), TEAL, { tr = 1, name = "SiphonFX" })
		B:emitter(sipFx, "bubble", { name = "SiphonBubbles", color = { "#ffffff", SKY }, rate = 2.5, size = { 0.25, 0.45, 0.55 } })

		------------------------------------------------------------------
		-- TENTACLES: 12 x 3 bones. Six front ones hang in a tidy, nearly
		-- parallel fringe under the face (a "beard"); three per side splay
		-- out wide as a stepped skirt. Each bone's pivot frame is yawed so
		-- local -Z points OUTWARD: +X rot flares a tentacle out/up, -X tucks
		-- it in, Z sways it sideways. Clean dark->light->cream gradient per
		-- tentacle (no mid bands) keeps the cluster readable from the front.
		------------------------------------------------------------------
		local BETAS = { -112, -90, -68, -36, -21, -7, 7, 21, 36, 68, 90, 112 }
		local CC = v(0, 5.7, -4.3)
		for k = 1, 12 do
			local beta = BETAS[k]
			local rot = CFrame.Angles(0, rad(beta), 0)
			local front = math.abs(beta) < 45
			local base = front and v(-sin(rad(beta)) * 3.6, CC.Y, -5.55)
				or CC + v(-sin(rad(beta)) * 2.45, 0.15, -cos(rad(beta)) * 1.5)
			local poker = k == 6 or k == 7
			local lens = poker and { 1.9, 1.8, 1.5 } or (front and { 1.7, 1.5, 1.2 } or { 1.6, 1.5, 1.3 })
			local th = front and { 12, 16, 62 } or { 58, 22, 50 }
			local wid = { 1.15, 0.9, 0.7 }
			local p = base
			local parent = "Head"
			for j = 1, 3 do
				local name = "T" .. k .. string.char(96 + j)
				local b = B:bone(name, parent, CFrame.new(p) * rot)
				local d = rot:VectorToWorldSpace(v(0, -cos(rad(th[j])), -sin(rad(th[j]))))
				local q = p + d * lens[j]
				local col = j == 1 and TEAL or TEAL2
				B:beam(b, p - d * 0.3, q, wid[j], wid[j], col)
				if j == 3 then
					B:beam(b, q - d * 0.1, q + d * 0.45, 0.6, 0.6, CREAM)
					if poker or k == 1 or k == 12 then
						B:trail(b, q + v(0, 0.3, 0), q - v(0, 0.3, 0), { name = "TipTrail" .. k, color = { TURQ, "#ffffff" }, life = 0.2, trans = { 0.55, 1 } })
					end
					if poker then
						local tip = B:block(b, v(0.5, 0.5, 0.5), CFrame.new(q), CREAM, { tr = 1, name = "PokeFX" .. k })
						B:emitter(tip, "burst", { name = "Poke" .. (k == 6 and "R" or "L"), color = { "#ffffff", SKY }, speed = { 3, 6 }, size = { 0.5, 0.3, 0 } })
					end
				end
				p = q
				parent = name
			end
		end

		------------------------------------------------------------------
		-- FLOATING marble cubes + orichalcum crystals
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 9, 1))
		local spots = {
			{ v(8.5, 12.5, -4.0), "marble" }, { v(-8.8, 11.0, -2.5), "crystal" }, { v(-7.5, 5.0, 6.5), "marble" },
			{ v(8.0, 6.0, 7.0), "crystal" }, { v(0.5, 15.0, 9.5), "marble" },
		}
		for i, s in spots do
			local p = s[1]
			local ob = B:bone("Cube" .. i, "Orbit", p)
			if s[2] == "marble" then
				B:block(ob, v(1.7, 1.7, 1.7), CFrame.new(p), MARBLE)
				B:block(ob, v(1.8, 0.4, 1.8), CFrame.new(p + v(0, 0.35, 0)), GOLD)
				B:block(ob, v(0.4, 0.4, 1.85), CFrame.new(p + v(0, -0.35, 0)), TURQ, NEON)
			else
				B:block(ob, v(0.9, 1.9, 0.9), CFrame.new(p), TEAL2)
				B:block(ob, v(1.1, 0.5, 1.1), CFrame.new(p + v(0, -0.9, 0)), BRONZE)
				B:block(ob, v(0.5, 0.6, 0.5), CFrame.new(p + v(0, 1.2, 0)), TURQ, NEON)
			end
		end
	end,
}
