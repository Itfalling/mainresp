--!nocheck
-- Thornback Hedgehog (Guardian #4, Epic): a big chunky GRUMPY hedgehog that
-- guards a berry bush. A round, tall stud-block body under a dome of chunky
-- stepped SPIKES (dark umber base -> warm brown -> bone/cream tip, a few tiny
-- neon-lime thorn tips) fanned backward and outward like a classic hedgehog.
-- Green thorny vines, red berries and pink flowers are woven between the
-- spikes as small accents. Round cream face, pointed stepped snout with a
-- little black nose, small beady eyes under heavy grumpy brows, small round
-- ears, pink cheeks and one jaw with a tiny underbite.
-- Rig: Body -> Front (front dome slice) / Rump (rear dome slice) + Head so the
-- hedgehog can curl into a spiky ball and ROLL; hidden "BallCover" spikes
-- close the ball's belly and sides while curled.
return {
	DisplayName = "Thornback Hedgehog",
	Rarity = "Epic",
	Element = "Nature",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		-- fur + spikes
		local FUR, FUR2 = "#9a6438", "#7d4e2c" -- body fur (warm brown) + shade
		local UMBER, UMBER2, UMBER3 = "#3e2416", "#4d2e1b", "#5d3820" -- dome skin layers
		local SP0, SP1, SP2 = "#3a2114", "#87562f", "#f1e3c2" -- spike base / mid / bone tip
		local CREAM, CREAM2, TAN = "#f6e8ca", "#fff3dc", "#d9b98a"
		local VINE, VINE2, LEAF = "#2d6b2a", "#3f8a33", "#62b847"
		local BERRY, BERRYHI, PINK, SUN = "#d42d4c", "#ff9ab3", "#ff6fa8", "#ffd447"
		local NEON = "#d2ff3c"
		local WHITE, MOUTH, TONGUE, NOSE, EYE = "#fffbea", "#1c0f12", "#e25a78", "#141012", "#120c10"
		local BLUSH, ANGER = "#f29aa6", "#ff2a3c"

		------------------------------------------------------------------
		-- Dome geometry: a tall rounded ellipsoid over the body
		------------------------------------------------------------------
		local YC, ZC = 4.6, 0.6
		local RX, RY, RZ = 4.0, 3.4, 4.6
		local ZF, ZR = -1.0, 2.2 -- slice boundaries: Front | Body | Rump

		local body = B:bone("Body", "Root", v(0, 4.0, 0.6))
		local front = B:bone("Front", "Body", v(0, 7.2, ZF))
		local rump = B:bone("Rump", "Body", v(0, 7.2, ZR))
		local slices = { F = front, M = body, R = rump }
		local function sliceOf(z)
			return z < ZF and "F" or (z > ZR and "R" or "M")
		end

		-- body core (fur) + cream belly, split so the ends curl under
		B:block(body, v(6.4, 4.4, 3.4), cf(0, 3.6, 0.6), FUR)
		B:block(front, v(6.3, 4.4, 3.2), cf(0, 3.6, -2.4), FUR)
		B:block(rump, v(6.3, 4.4, 3.2), cf(0, 3.6, 3.6), FUR)
		B:block(body, v(5.2, 0.5, 3.6), cf(0, 1.4, 0.6), CREAM)
		B:block(front, v(5.0, 0.5, 2.6), cf(0, 1.42, -2.2), CREAM)
		B:block(rump, v(5.0, 0.5, 2.6), cf(0, 1.42, 3.4), CREAM)
		B:sym(function()
			B:block(body, v(0.3, 1.4, 3.4), cf(3.2, 2.4, 0.6), FUR2)
		end)
		-- cream chest bib under the chin
		B:block(front, v(4.4, 2.4, 0.5), cf(0, 3.0, -4.05), CREAM)
		B:block(front, v(3.0, 0.8, 0.4), cf(0, 1.9, -4.15), CREAM2)
		-- stubby tail
		B:block(rump, v(1.0, 0.9, 1.0), cf(0, 3.0, 5.4), FUR2)

		-- hidden spiky covers that close the ball (props, shown while curled)
		local bc = 0
		local function cover(size, at, col)
			bc += 1
			B:block(body, size, at, col, { tr = 1, name = "BallCover" .. bc })
		end
		cover(v(6.0, 0.6, 4.4), cf(0, 0.95, 0.6), UMBER2)
		for _, p in { { 1.7, -1.0 }, { -1.7, -1.0 }, { 0, 0.4 }, { 1.7, 1.8 }, { -1.7, 1.8 }, { 0, 2.6 } } do
			local base = v(p[1], 0.75, p[2])
			local dir = v(p[1] * 0.25, -1, (p[2] - 0.6) * 0.3 + 0.35).Unit
			cover(v(0.95, 0.95, 0.8), CFrame.lookAt(base + dir * 0.2, base + dir * 2), SP1)
			cover(v(0.6, 0.6, 1.0), CFrame.lookAt(base + dir * 0.9, base + dir * 3), SP2)
		end
		for s = 1, -1, -2 do
			cover(v(0.5, 2.4, 3.6), cf(3.35 * s, 2.4, 0.6), UMBER2)
			for _, z in { -0.4, 1.6 } do
				local base = v(3.5 * s, 2.4, z)
				local dir = v(s, -0.15, 0.4).Unit
				cover(v(0.8, 0.8, 1.2), CFrame.lookAt(base + dir * 0.4, base + dir * 2), SP2)
			end
		end

		-- stepped dome skin (dark umber, lighter toward the top)
		local layers = {
			{ 3.4, 4.6, UMBER },
			{ 4.6, 5.7, UMBER },
			{ 5.7, 6.6, UMBER2 },
			{ 6.6, 7.4, UMBER3 },
			{ 7.4, 8.0, UMBER3 },
		}
		local function halfAt(y, r)
			local k = math.max(0, (y - YC) / RY)
			return r * math.sqrt(math.max(0, 1 - k * k))
		end
		for i, L in layers do
			local yb, yt = L[1], L[2]
			local hx = halfAt(yb, RX) + (i == 1 and 0.15 or 0)
			local hz = halfAt(yb, RZ)
			local z0, z1 = ZC - hz, ZC + hz
			local h = yt - yb
			local cy = (yb + yt) / 2
			if z0 < ZF then
				local a, b = z0, ZF + 0.3
				B:block(front, v(hx * 2 - 0.1, h, b - a), cf(0, cy, (a + b) / 2), L[3])
			end
			local a, b = math.max(z0, ZF), math.min(z1, ZR)
			if b > a then
				B:block(body, v(hx * 2, h, b - a), cf(0, cy, (a + b) / 2), L[3])
			end
			if z1 > ZR then
				local a2, b2 = ZR - 0.3, z1
				B:block(rump, v(hx * 2 - 0.1, h, b2 - a2), cf(0, cy, (a2 + b2) / 2), L[3])
			end
		end

		------------------------------------------------------------------
		-- SPIKES: rows over the dome, fanned back + out, grouped on bones
		------------------------------------------------------------------
		local function domeDir(phi, psi)
			local ph, ps = math.rad(phi), math.rad(psi)
			return v(math.sin(ph) * math.cos(ps), math.cos(ph) * math.cos(ps), math.sin(ps))
		end
		local function domePoint(phi, psi, out)
			local d = domeDir(phi, psi)
			return v(0, YC, ZC) + v((RX + out) * d.X, (RY + out) * d.Y, (RZ + out) * d.Z)
		end
		local groupPivot = {
			F = { c = v(0, 7.6, -2.4), s = v(2.6, 6.6, -2.2) },
			M = { c = v(0, 8.2, 0.6), s = v(3.0, 7.0, 0.6) },
			R = { c = v(0, 7.6, 3.6), s = v(2.6, 6.6, 3.4) },
		}
		for g, p in groupPivot do
			B:bone("Quill" .. g, slices[g], p.c)
			B:sym(function(side)
				B:bone("Quill" .. g .. side, slices[g], p.s)
			end)
		end
		local trails = 0
		local function spike(phi, psi, len, neonTip, trail)
			local surf = domePoint(phi, psi, 0)
			local d = domeDir(phi, psi)
			local n = v(d.X / RX, d.Y / RY, d.Z / RZ).Unit
			local dir = (n + v(0, 0, 1.15)).Unit
			local g = sliceOf(surf.Z)
			local bone = "Quill" .. g .. (math.abs(phi) < 25 and "" or (phi > 0 and "R" or "L"))
			B:beam(bone, surf - dir * 0.45, surf + dir * 0.5, 1.25, 1.25, SP0)
			B:beam(bone, surf + dir * 0.4, surf + dir * 1.15, 0.95, 0.95, SP1)
			local tip = surf + dir * (1.05 + len)
			B:spike(bone, surf + dir * 1.05, tip, 0.8, 0.8, SP2)
			if neonTip then
				B:block(bone, v(0.28, 0.28, 0.28), CFrame.lookAt(tip - dir * 0.02, tip + dir), NEON, { mat = "Neon" })
			end
			if trail then
				trails += 1
				B:trail(bone, tip, tip - dir * 0.9, { name = "SpinTrail" .. trails, color = { "#ffffff", NEON }, life = 0.14, trans = { 0.45, 1 } })
			end
		end
		local rows = {
			{ -64, { 0, 36, 72 }, 1.4 },
			{ -40, { 18, 54, 90 }, 1.8 },
			{ -14, { 0, 36, 70, 98 }, 1.55 },
			{ 12, { 18, 54, 88 }, 1.5 },
			{ 38, { 0, 36, 70, 98 }, 2.0 },
			{ 63, { 18, 54, 88 }, 1.8 },
		}
		for ri, r in rows do
			for qi, phi in r[2] do
				local neonTip = (qi + ri) % 3 == 0
				if phi == 0 then
					spike(0, r[1], r[3], ri % 2 == 1, ri % 2 == 1)
				else
					local l = r[3] * (phi > 85 and 0.8 or 1)
					spike(phi, r[1], l, neonTip, false)
					spike(-phi, r[1], l, neonTip, false)
				end
			end
		end

		------------------------------------------------------------------
		-- Accents woven between the spikes: thorny vines, berries, flowers
		------------------------------------------------------------------
		local function vine(pts)
			for i = 1, #pts - 1 do
				local a = domePoint(pts[i][1], pts[i][2], 0.2)
				local b = domePoint(pts[i + 1][1], pts[i + 1][2], 0.2)
				local bone = slices[sliceOf((a.Z + b.Z) / 2)]
				B:beam(bone, a, b, 0.4, 0.4, VINE)
				if i % 2 == 0 then
					local m = (a + b) / 2
					local n = (m - v(0, YC, ZC)).Unit
					B:block(bone, v(0.9, 0.18, 0.55), CFrame.lookAt(m + n * 0.2, m + n * 0.2 + (b - a).Unit) * P.ang(0, 0, 25), LEAF)
				end
			end
		end
		vine({ { -96, -30 }, { -70, -22 }, { -45, -28 }, { -22, -24 }, { 8, -26 } })
		vine({ { 96, 30 }, { 72, 24 }, { 45, 26 }, { 20, 22 }, { -6, 26 } })
		local function berries(phi, psi)
			local p = domePoint(phi, psi, 0.35)
			local bone = slices[sliceOf(p.Z)]
			B:block(bone, v(0.7, 0.7, 0.7), CFrame.new(p), BERRY)
			B:block(bone, v(0.6, 0.6, 0.6), CFrame.new(p + v(0.45 * math.sign(phi + 0.01), -0.3, 0.35)), BERRY)
			B:block(bone, v(0.25, 0.25, 0.25), CFrame.new(p + v(-0.15, 0.3, -0.28)), BERRYHI)
		end
		local function flower(phi, psi)
			local p = domePoint(phi, psi, 0.35)
			local bone = slices[sliceOf(p.Z)]
			local n = (p - v(0, YC, ZC)).Unit
			local fr = CFrame.lookAt(p, p + n)
			B:block(bone, v(1.1, 0.45, 0.25), fr, PINK)
			B:block(bone, v(0.45, 1.1, 0.25), fr, PINK)
			B:block(bone, v(0.42, 0.42, 0.25), fr * CFrame.new(0, 0, -0.06), SUN)
		end
		berries(-60, -26)
		berries(58, 26)
		flower(-34, -24)
		flower(32, 25)

		------------------------------------------------------------------
		-- Head: round cream face, pointed stepped snout, beady eyes
		------------------------------------------------------------------
		local head = B:bone("Head", "Body", v(0, 5.0, -3.2))
		B:block(head, v(5.0, 3.2, 3.4), cf(0, 5.8, -4.6), CREAM)
		B:block(head, v(4.2, 2.6, 0.5), cf(0, 5.8, -6.45), CREAM) -- round face plate
		B:block(head, v(3.0, 0.5, 0.45), cf(0, 7.25, -6.3), CREAM)
		B:block(head, v(5.2, 1.0, 2.8), cf(0, 7.6, -4.3), UMBER2) -- spiky hairline cap
		B:block(head, v(1.8, 0.7, 0.45), cf(0, 7.25, -5.95), UMBER2) -- widow's peak
		-- little forehead spikes poking up out of the hairline
		for _, x in { -1.5, 0, 1.5 } do
			local base = v(x, 7.9, -4.9)
			local dir = v(x * 0.25, 0.75, 0.65).Unit
			B:beam(head, base - dir * 0.3, base + dir * 0.45, 0.9, 0.9, SP1)
			B:spike(head, base + dir * 0.35, base + dir * 1.5, 0.7, 0.7, SP2)
		end
		B:sym(function()
			B:block(head, v(0.5, 2.6, 2.6), cf(2.6, 5.4, -4.8), CREAM2) -- cheek fluff
			B:block(head, v(0.7, 0.35, 0.15), cf(1.75, 5.05, -6.73), BLUSH)
			-- small beady eye + glint (front face only)
			B:block(head, v(0.6, 0.8, 0.2), cf(1.2, 6.05, -6.75), EYE)
			B:block(head, v(0.2, 0.2, 0.1), cf(1.08, 6.27, -6.88), "#ffffff", { mat = "Neon" })
			-- whiskers
			B:beam(head, v(0.9, 4.9, -7.6), v(2.2, 5.2, -7.3), 0.1, 0.1, FUR2)
			B:beam(head, v(0.9, 4.6, -7.6), v(2.2, 4.4, -7.3), 0.1, 0.1, FUR2)
		end)
		-- snout step 1 + mouth roof + hidden upper teeth
		B:block(head, v(2.6, 1.8, 1.5), cf(0, 4.9, -7.3), CREAM)
		B:block(head, v(2.2, 0.2, 3.4), cf(0, 4.05, -6.6), MOUTH)
		-- pointed snout tip (own bone: sniff wiggle)
		local nose = B:bone("Nose", "Head", v(0, 5.1, -7.9))
		B:block(nose, v(1.7, 1.2, 1.2), cf(0, 5.2, -8.5), CREAM)
		B:block(nose, v(1.0, 0.8, 0.8), cf(0, 5.3, -9.4), CREAM2)
		B:block(nose, v(0.9, 0.7, 0.5), cf(0, 5.45, -9.95), NOSE)
		B:block(nose, v(0.25, 0.2, 0.1), cf(0.2, 5.65, -10.22), WHITE)
		local noseFX = B:block(nose, v(1, 1, 1), cf(0, 5.3, -10.6), CREAM, { tr = 1, name = "NoseFX" })
		B:emitter(noseFX, "dust", {
			name = "Huff", drag = 3, color = { "#ffffff", "#e8e2d4" }, size = { 0.8, 1.6, 2.2 }, life = { 0.4, 0.8 },
			speed = { 4, 7 }, spread = 20, trans = { 0.2, 0.5, 1 }, dir = "Front", accel = { 0, 2, 0 },
		})
		B:emitter(noseFX, "burst", {
			name = "Crumbs", color = { BERRY, BERRYHI, "#7a1020" }, speed = { 3, 6 }, size = { 0.35, 0.3, 0 },
			life = { 0.4, 0.8 }, accel = { 0, -18, 0 }, spread = 70,
		})

		-- brows (own bones), lids (hidden props), small round ears
		B:sym(function(side)
			local brow = B:bone("Brow" .. side, "Head", v(1.25, 6.75, -6.8))
			B:block(brow, v(1.6, 0.5, 0.5), cf(1.3, 6.72, -6.85, 0, 0, 20), UMBER)
			local lid = B:bone("Lid" .. side, "Head", v(1.2, 6.5, -6.8))
			B:block(lid, v(0.8, 0.95, 0.15), cf(1.2, 6.05, -6.92), TAN, { tr = 1, name = "Eyelid" .. side })
			local ear = B:bone("Ear" .. side, "Head", v(2.2, 7.4, -4.6))
			B:block(ear, v(1.1, 1.1, 0.5), cf(2.45, 7.95, -4.7), FUR2)
			B:block(ear, v(0.7, 0.4, 0.5), cf(2.45, 8.6, -4.7), FUR2)
			B:block(ear, v(0.6, 0.6, 0.15), cf(2.45, 7.95, -4.98), BLUSH)
		end)

		-- anger vein (prop, own bone so it can throb)
		local vein = B:bone("Vein", "Head", v(1.9, 8.2, -5.6))
		local VC = CFrame.new(1.9, 8.3, -5.9) * P.ang(0, -20, 0)
		B:block(vein, v(0.9, 0.28, 0.25), VC * CFrame.new(-0.3, 0.6, 0), ANGER, { tr = 1, name = "AngerMark1" })
		B:block(vein, v(0.28, 0.9, 0.25), VC * CFrame.new(0.6, 0.3, 0), ANGER, { tr = 1, name = "AngerMark2" })
		B:block(vein, v(0.9, 0.28, 0.25), VC * CFrame.new(0.3, -0.6, 0), ANGER, { tr = 1, name = "AngerMark3" })
		B:block(vein, v(0.28, 0.9, 0.25), VC * CFrame.new(-0.6, -0.3, 0), ANGER, { tr = 1, name = "AngerMark4" })

		-- jaw: small round chin with a tiny underbite
		local jaw = B:bone("Jaw", "Head", v(0, 4.3, -4.6))
		B:block(jaw, v(2.6, 0.8, 3.5), cf(0, 3.65, -6.55), CREAM)
		B:block(jaw, v(2.0, 0.3, 2.8), cf(0, 3.15, -6.4), CREAM2)
		B:block(jaw, v(2.2, 0.2, 3.2), cf(0, 4.08, -6.55), MOUTH)
		B:block(jaw, v(1.4, 0.2, 2.0), cf(0, 4.15, -6.3), TONGUE)
		B:block(jaw, v(2.2, 0.9, 0.4), cf(0, 4.2, -4.95), MOUTH)
		B:sym(function()
			B:block(jaw, v(0.35, 0.5, 0.35), cf(0.55, 4.3, -8.12), WHITE)
		end)

		------------------------------------------------------------------
		-- Stubby legs (on Body): small feet peeking out under the dome
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Body", v(2.2, 2.4, -2.0))
			B:block(arm, v(1.5, 2.0, 1.5), cf(2.25, 1.6, -2.1), FUR2)
			local paw = B:bone("Paw" .. side, "Arm" .. side, v(2.25, 0.8, -2.1))
			B:block(paw, v(1.6, 0.8, 2.0), cf(2.25, 0.4, -2.5), FUR2)
			for k = -1, 1 do
				B:block(paw, v(0.42, 0.42, 0.5), cf(2.25 + k * 0.5, 0.21, -3.65), CREAM)
			end
			B:trail(paw, v(2.25, 0.5, -3.8), v(2.25, 0.1, -3.8), { name = "ClawTrail" .. side, color = { "#ffffff", NEON }, life = 0.15, trans = { 0.5, 1 } })

			local leg = B:bone("Leg" .. side, "Body", v(2.4, 2.4, 2.6))
			B:block(leg, v(1.8, 2.2, 2.0), cf(2.45, 1.8, 2.7), FUR)
			local foot = B:bone("Foot" .. side, "Leg" .. side, v(2.45, 0.8, 2.6))
			B:block(foot, v(1.8, 0.8, 2.4), cf(2.45, 0.4, 2.2), FUR2)
			for k = -1, 1 do
				B:block(foot, v(0.45, 0.42, 0.5), cf(2.45 + k * 0.55, 0.21, 0.85), CREAM)
			end
		end)

		-- berry snack for the munch gag (prop on its own free bone)
		local snack = B:bone("Snack", "Root", v(0, 0.5, -10.0))
		B:block(snack, v(1.0, 1.0, 1.0), cf(0, 0.5, -10.0), BERRY, { tr = 1, name = "Berry" })
		B:block(snack, v(0.8, 0.25, 0.5), cf(0, 1.1, -10.0), LEAF, { tr = 1, name = "BerryLeaf" })

		------------------------------------------------------------------
		-- FX volumes
		------------------------------------------------------------------
		local aura = B:block(body, v(8, 5, 9), cf(0, 6.5, 0.6), FUR, { tr = 1, name = "AuraFX" })
		B:emitter(aura, "leaf", { name = "Leaves", color = { LEAF, "#9be05a" }, rate = 1.2, size = { 0.45, 0.45, 0.3 } })
		B:emitter(aura, "sparkle", { name = "Sparkle", color = { "#ffffff", NEON }, rate = 2.5 })
		B:emitter(aura, "burst", {
			name = "QuillBurst", color = { SP2, NEON, SP1 }, speed = { 10, 18 }, size = { 0.7, 0.5, 0 }, spread = 180,
		})
		B:light(aura, { name = "BristleLight", color = NEON, brightness = 0, range = 12 })
		local ground = B:block("Root", v(7, 0.2, 8), cf(0, 0.1, 0.6), FUR, { tr = 1, name = "GroundFX" })
		B:emitter(ground, "dust", {
			name = "StompDust", color = { "#efe2c8", "#cdb98f" }, size = { 2.2, 4, 5 }, speed = { 8, 14 },
			life = { 0.6, 1.1 }, trans = { 0.3, 0.5, 1 }, spread = 85,
		})
		B:emitter(ground, "dust", {
			name = "RollDust", color = { "#efe2c8", "#cdb98f" }, size = { 1.4, 2.6, 3.2 }, speed = { 3, 6 },
			life = { 0.4, 0.8 }, trans = { 0.35, 0.6, 1 }, spread = 40, dir = "Back",
		})
		B:emitter(ground, "leaf", {
			name = "RollLeaves", rate = 0, color = { LEAF, "#9be05a", PINK }, speed = { 5, 10 }, spread = 60,
			size = { 0.55, 0.5, 0.3 }, life = { 0.8, 1.5 }, accel = { 0, -9, 0 }, dir = "Back",
		})

		------------------------------------------------------------------
		-- Floating voxel cubes: berry cubes + leaf cubes
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 5, 0.6))
		local spots = { { 8.0, 7.4, -3.0 }, { -7.8, 5.2, 1.5 }, { 7.4, 4.2, 5.0 }, { -7.2, 8.2, -4.0 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = i % 2 == 0 and 1.0 or 1.2
			local at = cf(p[1], p[2], p[3])
			if i % 2 == 1 then
				B:block(ob, v(s, s, s), at, BERRY)
				B:block(ob, v(s + 0.1, 0.3, s + 0.1), at * CFrame.new(0, s * 0.42, 0), LEAF)
				B:block(ob, v(0.3, 0.3, 0.3), at * CFrame.new(0, s * 0.7, 0), NEON, { mat = "Neon" })
			else
				B:block(ob, v(s, s, s), at, VINE2)
				B:block(ob, v(s + 0.1, 0.22, s + 0.1), at, NEON, { mat = "Neon" })
			end
		end

		------------------------------------------------------------------
		-- Slam shockwave: chunky dirt slabs with a leafy top (one bone each)
		------------------------------------------------------------------
		local SC = v(0, 0.35, -2.5)
		for k = 1, 8 do
			local a = (k - 1) / 8 * 360
			local sb = B:bone("Shock" .. k, "Root", SC)
			local at = CFrame.new(SC) * P.ang(0, a, 0) * CFrame.new(0, 0, -3.0)
			B:block(sb, v(2.4, 0.7, 1.4), at, FUR2, { tr = 1, name = "Wave" .. k })
			B:block(sb, v(2.0, 0.25, 1.0), at * CFrame.new(0, 0.45, 0), LEAF, { tr = 1, name = "WaveTop" .. k })
		end
	end,
}
