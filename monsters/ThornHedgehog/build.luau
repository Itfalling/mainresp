--!nocheck
-- Thornback Hedgehog (Guardian #4, Epic): a big chunky GRUMPY hedgehog that
-- guards a berry bush. Umber stud-block body, cream face + belly, a small
-- stepped pointy snout with a black nose and an underbite with two little
-- fangs, small glaring eyes in brown mask patches under heavy dark brows.
-- Its back is a stepped dome of green vine plates covered in rows of
-- thorny-vine quills (stepped collar + pale tapered thorn, small neon-lime
-- tips) grouped on bones so they can ripple and BRISTLE, with little red
-- berries and pink flowers tucked between the thorns.
-- Rig: Body -> Front (front dome slice + head) / Rump (rear dome slice) so the
-- hedgehog can curl into a spiky ball and ROLL.
return {
	DisplayName = "Thornback Hedgehog",
	Rarity = "Epic",
	Element = "Nature",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local BROWN, DARK, DEEP = "#7a4a2b", "#553220", "#3b2216"
		local CREAM, TAN = "#f3e3c3", "#dcbc8c"
		local VINE0, VINE1, VINE2, VINE3 = "#2a5a25", "#367a2e", "#45933a", "#56aa44"
		local THORN, COLLAR = "#a6dc5c", "#24501f"
		local BERRY, BERRYHI, PINK, PINK2, SUN = "#d42d4c", "#ff9ab3", "#ff6fa8", "#ffb3d1", "#ffd447"
		local NEON = "#d2ff3c"
		local WHITE, MOUTH, TONGUE, NOSE, PUPIL = "#fffbea", "#1c0f12", "#e25a78", "#141012", "#120c10"
		local ANGER = "#ff2a3c"

		------------------------------------------------------------------
		-- Dome (quill mantle) geometry: a squat ellipsoid over the body
		------------------------------------------------------------------
		local YC, ZC = 4.3, 0.6
		local RX, RY, RZ = 4.7, 3.6, 5.4
		local ZF, ZR = -1.3, 2.5 -- slice boundaries: Front | Body | Rump

		local body = B:bone("Body", "Root", v(0, 4.0, 0.6))
		local front = B:bone("Front", "Body", v(0, 7.4, ZF))
		local rump = B:bone("Rump", "Body", v(0, 7.4, ZR))

		-- body core + belly, split so the ends curl under with the dome slices
		B:block(body, v(7.6, 3.8, 4.2), cf(0, 3.7, 0.6), BROWN)
		B:block(front, v(7.5, 3.8, 2.8), cf(0, 3.7, -2.25), BROWN)
		B:block(rump, v(7.5, 3.8, 2.8), cf(0, 3.7, 3.45), BROWN)
		B:block(body, v(6.4, 0.6, 4.4), cf(0, 1.6, 0.5), CREAM)
		B:block(front, v(6.3, 0.6, 2.4), cf(0, 1.62, -2.3), CREAM)
		B:block(rump, v(6.3, 0.6, 2.4), cf(0, 1.62, 3.3), CREAM)
		B:block(body, v(5.0, 0.5, 5.6), cf(0, 1.25, 0.5), TAN)
		B:sym(function()
			B:block(body, v(0.4, 1.8, 4.4), cf(3.85, 2.9, 0.6), DARK)
		end)
		-- cream chest bib (stepped) under the chin
		B:block(front, v(5.8, 2.4, 0.6), cf(0, 3.0, -3.75), CREAM)
		B:block(front, v(4.0, 1.0, 0.5), cf(0, 1.9, -3.95), TAN)

		-- hidden thorny belly plates: only shown while curled into the ball so
		-- the rolling ball is spiky all the way round (props)
		B:block(body, v(7.0, 0.7, 5.6), cf(0, 0.95, 0.5), VINE1, { tr = 1, name = "BallCover1" })
		B:block(body, v(5.2, 0.6, 3.8), cf(0, 0.35, 0.5), VINE2, { tr = 1, name = "BallCover2" })
		local bc = 2
		for _, p in { { 2.2, -1.2 }, { -2.2, -1.2 }, { 2.2, 2.2 }, { -2.2, 2.2 } } do
			bc += 1
			local base = v(p[1], 0.5, p[2])
			local dir = v(p[1] * 0.18, -1, p[2] * 0.12 + 0.35).Unit
			B:block(body, v(0.7, 0.7, 1.1), CFrame.lookAt(base + dir * 0.35, base + dir * 2), THORN, { tr = 1, name = "BallCover" .. bc })
		end

		-- stepped dome layers, split into the three slices
		local layers = {
			{ 3.7, 5.0, VINE0 },
			{ 5.0, 6.0, VINE1 },
			{ 6.0, 6.8, VINE2 },
			{ 6.8, 7.4, VINE3 },
			{ 7.4, 7.9, VINE2 },
		}
		local function halfAt(y, r)
			local k = math.max(0, (y - YC) / RY)
			return r * math.sqrt(math.max(0, 1 - k * k))
		end
		for i, L in layers do
			local yb, yt = L[1], L[2]
			local hx = halfAt(yb, RX) + (i == 1 and 0.2 or 0)
			local hz = halfAt(yb, RZ)
			local z0, z1 = ZC - hz, ZC + hz
			local h = yt - yb
			local cy = (yb + yt) / 2
			local col = L[3]
			-- front slice (a hair narrower so the faces are never coplanar)
			if z0 < ZF then
				local a, b = z0, ZF + 0.3
				B:block(front, v(hx * 2 - 0.1, h, b - a), cf(0, cy, (a + b) / 2), col)
			end
			local a, b = math.max(z0, ZF), math.min(z1, ZR)
			if b > a then
				B:block(body, v(hx * 2, h, b - a), cf(0, cy, (a + b) / 2), col)
			end
			if z1 > ZR then
				local a2, b2 = ZR - 0.3, z1
				B:block(rump, v(hx * 2 - 0.1, h, b2 - a2), cf(0, cy, (a2 + b2) / 2), col)
			end
		end
		-- dark vine band + little thorns along the skirt edge
		B:sym(function()
			B:block(body, v(0.3, 0.5, 3.6), cf(4.95, 3.95, 0.6), COLLAR)
			B:block(front, v(0.3, 0.5, 2.4), cf(4.85, 3.95, -2.6), COLLAR)
			B:block(rump, v(0.3, 0.5, 2.4), cf(4.85, 3.95, 3.9), COLLAR)
			for k = 0, 2 do
				B:spike(body, v(4.9, 4.0, -0.6 + k * 1.3), v(5.6, 3.5, -0.3 + k * 1.3), 0.45, 0.45, THORN)
			end
		end)
		B:block(rump, v(6.6, 0.5, 0.3), cf(0, 3.95, 6.05), COLLAR)
		-- stubby tail
		B:block(rump, v(1.4, 1.2, 1.2), cf(0, 3.2, 5.6), BROWN)
		B:block(rump, v(0.8, 0.6, 0.6), cf(0, 3.0, 6.3), DARK)

		------------------------------------------------------------------
		-- Quills: rows over the dome, grouped on bones (row slice x side)
		------------------------------------------------------------------
		local rows = {
			{ -58, { 0, 34, 68 }, "F", 1.9 },
			{ -30, { 17, 50, 80 }, "F", 2.4 },
			{ 2, { 0, 34, 66, 90 }, "M", 2.5 },
			{ 32, { 17, 50, 80 }, "R", 2.6 },
			{ 60, { 0, 34, 68 }, "R", 2.3 },
		}
		local groupParent = { F = "Front", M = "Body", R = "Rump" }
		local groupPivot = {
			F = { c = v(0, 8.0, -2.6), s = v(3.0, 7.0, -2.4) },
			M = { c = v(0, 8.6, 0.6), s = v(3.4, 7.4, 0.6) },
			R = { c = v(0, 8.0, 3.8), s = v(3.0, 7.0, 3.8) },
		}
		for g, p in groupPivot do
			B:bone("Quill" .. g, groupParent[g], p.c)
			B:sym(function(side)
				B:bone("Quill" .. g .. side, groupParent[g], p.s)
			end)
		end
		local trails = 0
		local function quill(boneName, phi, psi, len, neonTip, trail)
			local ph, ps = math.rad(phi), math.rad(psi)
			local d = v(math.sin(ph) * math.cos(ps), math.cos(ph) * math.cos(ps), math.sin(ps))
			local surf = v(0, YC, ZC) + v(RX * d.X, RY * d.Y, RZ * d.Z)
			local n = v(d.X / RX, d.Y / RY, d.Z / RZ).Unit
			local dir = (n + v(0, 0.1, 0.75)).Unit
			local base = surf - dir * 0.45
			local mid = surf + dir * 0.45
			local tip = surf + dir * len
			B:beam(boneName, base, mid, 1.15, 1.15, COLLAR)
			B:spike(boneName, mid - dir * 0.15, tip, 1.0, 1.0, THORN)
			if neonTip then
				B:block(boneName, v(0.3, 0.3, 0.3), CFrame.lookAt(tip - dir * 0.05, tip + dir), NEON, { mat = "Neon" })
			end
			if trail then
				trails += 1
				B:trail(boneName, tip, tip - dir * 0.9, { name = "SpinTrail" .. trails, color = { "#ffffff", NEON }, life = 0.14, trans = { 0.45, 1 } })
			end
		end
		for ri, r in rows do
			for qi, phi in r[2] do
				local tipNeon = (qi + ri) % 2 == 0
				if phi == 0 then
					quill("Quill" .. r[3], 0, r[1], r[4], true, ri % 2 == 1)
				else
					local grp = phi < 30 and ("Quill" .. r[3]) or nil
					-- right then mirrored left (manual mirror so the centre group
					-- can hold the near-centre pair)
					for s = 1, -1, -2 do
						local bn = grp or ("Quill" .. r[3] .. (s > 0 and "R" or "L"))
						quill(bn, phi * s, r[1], r[4] * (phi > 75 and 0.8 or 1), tipNeon, false)
					end
				end
			end
		end

		------------------------------------------------------------------
		-- Berries + pink flowers tucked between the thorns
		------------------------------------------------------------------
		local function domePoint(phi, psi, out)
			local ph, ps = math.rad(phi), math.rad(psi)
			local d = v(math.sin(ph) * math.cos(ps), math.cos(ph) * math.cos(ps), math.sin(ps))
			return v(0, YC, ZC) + v((RX + out) * d.X, (RY + out) * d.Y, (RZ + out) * d.Z)
		end
		local function berries(bone, phi, psi)
			local p = domePoint(phi, psi, 0.15)
			B:block(bone, v(0.8, 0.8, 0.8), CFrame.new(p), BERRY)
			B:block(bone, v(0.7, 0.7, 0.7), CFrame.new(p + v(0.55 * math.sign(phi + 0.01), -0.25, 0.45)), BERRY)
			B:block(bone, v(0.3, 0.3, 0.3), CFrame.new(p + v(-0.18, 0.3, -0.3)), BERRYHI)
			B:block(bone, v(1.0, 0.2, 0.6), CFrame.new(p + v(0, 0.45, 0.4)) * P.ang(0, 25, 0), VINE3)
		end
		local function flower(bone, phi, psi)
			local p = domePoint(phi, psi, 0.2)
			local n = (p - v(0, YC, ZC)).Unit
			local fr = CFrame.lookAt(p, p + n)
			B:block(bone, v(1.3, 0.5, 0.3), fr, PINK)
			B:block(bone, v(0.5, 1.3, 0.3), fr, PINK)
			B:block(bone, v(0.5, 0.5, 0.3), fr * CFrame.new(0, 0, -0.08), SUN)
		end
		berries("Front", 22, -44)
		berries("Rump", -24, 46)
		berries("Body", 50, 16)
		berries("Body", -50, -12)
		flower("Front", -46, -40)
		flower("Rump", 44, 44)
		flower("Body", 8, 18)

		------------------------------------------------------------------
		-- Head: cream face, brown cap + eye mask, stepped pointy snout
		------------------------------------------------------------------
		local head = B:bone("Head", "Body", v(0, 4.3, -3.4))
		B:block(head, v(5.4, 3.8, 3.8), cf(0, 4.7, -4.9), CREAM)
		B:block(head, v(5.8, 1.4, 3.0), cf(0, 6.85, -4.5), BROWN)
		B:block(head, v(4.4, 0.6, 2.2), cf(0, 7.65, -4.3), DARK)
		B:block(head, v(2.2, 0.7, 0.4), cf(0, 6.45, -6.85), BROWN) -- widow's peak
		B:sym(function()
			B:block(head, v(0.7, 2.2, 2.8), cf(2.75, 3.9, -5.1), TAN) -- cheek fluff
			B:block(head, v(0.5, 1.2, 1.6), cf(3.15, 3.5, -5.0), CREAM)
			B:block(head, v(2.1, 1.9, 0.3), cf(1.5, 5.55, -6.9), BROWN) -- eye mask
			B:block(head, v(1.5, 1.35, 0.2), cf(1.5, 5.5, -7.08), "#ffffff") -- eye
			B:block(head, v(0.7, 0.9, 0.15), cf(1.28, 5.38, -7.18), PUPIL)
			B:block(head, v(0.25, 0.25, 0.1), cf(1.42, 5.62, -7.27), NEON, { mat = "Neon" })
			-- whiskers
			B:beam(head, v(1.3, 3.9, -8.1), v(2.7, 4.3, -7.8), 0.12, 0.12, DEEP)
			B:beam(head, v(1.3, 3.6, -8.1), v(2.7, 3.4, -7.8), 0.12, 0.12, DEEP)
		end)
		-- snout step 1 + upper lip / mouth roof + hidden upper teeth
		B:block(head, v(3.4, 2.0, 1.7), cf(0, 3.9, -7.6), CREAM)
		B:block(head, v(2.4, 0.4, 1.5), cf(0, 5.0, -7.5), TAN)
		B:block(head, v(3.0, 0.2, 4.4), cf(0, 2.8, -6.4), MOUTH)
		for _, x in { -1.1, -0.4, 0.4, 1.1 } do
			B:block(head, v(0.45, 0.4, 0.4), cf(x, 2.65, -8.05), WHITE)
		end
		-- nose (own bone: sniff wiggle)
		local nose = B:bone("Nose", "Head", v(0, 4.2, -8.4))
		B:block(nose, v(2.2, 1.2, 1.5), cf(0, 4.2, -9.0), CREAM)
		B:block(nose, v(1.6, 0.3, 1.2), cf(0, 4.9, -8.9), TAN)
		B:block(nose, v(1.3, 1.0, 0.7), cf(0, 4.4, -9.95), NOSE)
		B:block(nose, v(0.35, 0.25, 0.1), cf(0.3, 4.7, -10.32), WHITE)
		-- huff / sneeze / crumbs FX at the nose
		local noseFX = B:block(nose, v(1, 1, 1), cf(0, 4.2, -10.6), CREAM, { tr = 1, name = "NoseFX" })
		B:emitter(noseFX, "smoke", {
			name = "Huff", rate = 0, color = { "#ffffff", "#e8e2d4" }, size = { 0.8, 1.6, 2.2 }, life = { 0.4, 0.8 },
			speed = { 4, 7 }, spread = 20, trans = { 0.2, 0.5, 1 }, dir = "Front", accel = { 0, 2, 0 },
		})
		B:emitter(noseFX, "burst", {
			name = "Crumbs", color = { BERRY, BERRYHI, "#7a1020" }, speed = { 3, 6 }, size = { 0.35, 0.3, 0 },
			life = { 0.4, 0.8 }, accel = { 0, -18, 0 }, spread = 70,
		})

		-- brows (own bones: scrunch / raise), lids are hidden props
		B:sym(function(side)
			local brow = B:bone("Brow" .. side, "Head", v(1.5, 6.45, -7.1))
			B:block(brow, v(2.3, 0.6, 0.6), cf(1.55, 6.4, -7.2, 0, 0, 18), DEEP)
			B:block(brow, v(1.5, 0.35, 0.5), cf(1.8, 6.78, -7.1, 0, 0, 18), DARK)
			local lid = B:bone("Lid" .. side, "Head", v(1.5, 6.0, -7.15))
			B:block(lid, v(1.6, 1.45, 0.15), cf(1.5, 5.5, -7.19), BROWN, { tr = 1, name = "Eyelid" .. side })
			-- ears peeking out of the quills
			local ear = B:bone("Ear" .. side, "Head", v(2.2, 7.2, -4.6))
			B:block(ear, v(1.3, 1.2, 0.6), cf(2.45, 7.75, -4.7, 0, 0, -15), BROWN)
			B:block(ear, v(0.7, 0.7, 0.2), cf(2.45, 7.7, -5.05, 0, 0, -15), TAN)
		end)

		-- anger vein (prop, own bone so it can throb)
		local vein = B:bone("Vein", "Head", v(2.0, 7.9, -6.0))
		local VC = CFrame.new(1.9, 8.0, -6.3) * P.ang(0, -20, 0)
		B:block(vein, v(0.7, 0.22, 0.2), VC * CFrame.new(-0.25, 0.5, 0), ANGER, { tr = 1, name = "AngerMark1" })
		B:block(vein, v(0.22, 0.7, 0.2), VC * CFrame.new(0.5, 0.25, 0), ANGER, { tr = 1, name = "AngerMark2" })
		B:block(vein, v(0.7, 0.22, 0.2), VC * CFrame.new(0.25, -0.5, 0), ANGER, { tr = 1, name = "AngerMark3" })
		B:block(vein, v(0.22, 0.7, 0.2), VC * CFrame.new(-0.5, -0.25, 0), ANGER, { tr = 1, name = "AngerMark4" })

		-- jaw: underbite with two little fangs
		local jaw = B:bone("Jaw", "Head", v(0, 2.95, -4.4))
		B:block(jaw, v(3.6, 1.0, 4.6), cf(0, 2.3, -6.9), CREAM)
		B:block(jaw, v(3.0, 0.3, 3.8), cf(0, 1.68, -6.8), TAN)
		B:block(jaw, v(3.0, 0.2, 4.0), cf(0, 2.82, -6.9), MOUTH)
		B:block(jaw, v(1.8, 0.2, 2.4), cf(0, 2.9, -6.6), TONGUE)
		B:block(jaw, v(3.0, 1.0, 0.4), cf(0, 2.9, -4.8), MOUTH)
		B:sym(function()
			B:block(jaw, v(0.5, 0.75, 0.5), cf(0.95, 3.15, -8.85), WHITE)
			B:block(jaw, v(0.4, 0.35, 0.4), cf(0.35, 2.95, -8.95), WHITE)
		end)

		------------------------------------------------------------------
		-- Stubby legs (on Body): front arms + hind legs, each with a paw bone
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Body", v(2.7, 2.6, -2.3))
			B:block(arm, v(1.8, 2.2, 1.8), cf(2.7, 1.8, -2.4), BROWN)
			B:block(arm, v(1.9, 0.5, 1.9), cf(2.7, 2.65, -2.4), DARK)
			local paw = B:bone("Paw" .. side, "Arm" .. side, v(2.7, 0.9, -2.4))
			B:block(paw, v(2.0, 0.8, 2.4), cf(2.7, 0.42, -2.75), DARK)
			B:block(paw, v(1.6, 0.3, 1.0), cf(2.7, 0.95, -3.3), TAN)
			for k = -1, 1 do
				B:wedge(paw, v(0.42, 0.45, 0.7), cf(2.7 + k * 0.6, 0.23, -4.2), WHITE)
			end
			B:trail(paw, v(2.7, 0.5, -4.4), v(2.7, 0.1, -4.4), { name = "ClawTrail" .. side, color = { "#ffffff", NEON }, life = 0.15, trans = { 0.5, 1 } })

			local leg = B:bone("Leg" .. side, "Body", v(2.9, 2.6, 2.6))
			B:block(leg, v(2.2, 2.4, 2.6), cf(2.9, 2.1, 2.7), BROWN)
			B:block(leg, v(0.3, 1.4, 1.8), cf(4.05, 2.2, 2.7), DARK)
			local foot = B:bone("Foot" .. side, "Leg" .. side, v(2.9, 0.9, 2.6))
			B:block(foot, v(2.2, 0.8, 3.0), cf(2.9, 0.42, 2.2), DARK)
			for k = -1, 1 do
				B:wedge(foot, v(0.45, 0.45, 0.7), cf(2.9 + k * 0.65, 0.23, 0.45), WHITE)
			end
		end)

		-- berry snack for the munch gag (prop on its own free bone)
		local snack = B:bone("Snack", "Root", v(0, 0.5, -10.0))
		B:block(snack, v(1.0, 1.0, 1.0), cf(0, 0.5, -10.0), BERRY, { tr = 1, name = "Berry" })
		B:block(snack, v(0.8, 0.25, 0.5), cf(0, 1.1, -10.0), VINE3, { tr = 1, name = "BerryLeaf" })

		------------------------------------------------------------------
		-- FX volumes
		------------------------------------------------------------------
		local aura = B:block(body, v(9, 5, 10), cf(0, 6.5, 0.6), BROWN, { tr = 1, name = "AuraFX" })
		B:emitter(aura, "leaf", { name = "Leaves", color = { VINE3, "#9be05a" }, rate = 1.5, size = { 0.45, 0.45, 0.3 } })
		B:emitter(aura, "sparkle", { name = "Sparkle", color = { "#ffffff", NEON }, rate = 2.5 })
		B:emitter(aura, "burst", {
			name = "QuillBurst", color = { THORN, NEON, VINE3 }, speed = { 10, 18 }, size = { 0.7, 0.5, 0 }, spread = 180,
		})
		B:light(aura, { name = "BristleLight", color = NEON, brightness = 0, range = 12 })
		local ground = B:block("Root", v(8, 0.2, 9), cf(0, 0.1, 0.6), BROWN, { tr = 1, name = "GroundFX" })
		B:emitter(ground, "dust", {
			name = "StompDust", color = { "#efe2c8", "#cdb98f" }, size = { 2.2, 4, 5 }, speed = { 8, 14 },
			life = { 0.6, 1.1 }, trans = { 0.3, 0.5, 1 }, spread = 85,
		})
		B:emitter(ground, "dust", {
			name = "RollDust", color = { "#efe2c8", "#cdb98f" }, size = { 1.4, 2.6, 3.2 }, speed = { 3, 6 },
			life = { 0.4, 0.8 }, trans = { 0.35, 0.6, 1 }, spread = 40, dir = "Back",
		})
		B:emitter(ground, "leaf", {
			name = "RollLeaves", rate = 0, color = { VINE3, "#9be05a", PINK }, speed = { 5, 10 }, spread = 60,
			size = { 0.55, 0.5, 0.3 }, life = { 0.8, 1.5 }, accel = { 0, -9, 0 }, dir = "Back",
		})

		------------------------------------------------------------------
		-- Floating voxel cubes: berry cubes + leaf cubes
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 5, 0.6))
		local spots = { { 9.0, 7.6, -3.0 }, { -8.8, 5.4, 1.5 }, { 8.2, 4.2, 5.5 }, { -8.0, 8.6, -4.5 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = i % 2 == 0 and 1.1 or 1.3
			local at = cf(p[1], p[2], p[3])
			if i % 2 == 1 then
				B:block(ob, v(s, s, s), at, BERRY)
				B:block(ob, v(s + 0.1, 0.3, s + 0.1), at * CFrame.new(0, s * 0.42, 0), VINE3)
				B:block(ob, v(0.35, 0.35, 0.35), at * CFrame.new(0, s * 0.7, 0), NEON, { mat = "Neon" })
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
			B:block(sb, v(2.4, 0.7, 1.4), at, BROWN, { tr = 1, name = "Wave" .. k })
			B:block(sb, v(2.0, 0.25, 1.0), at * CFrame.new(0, 0.45, 0), VINE3, { tr = 1, name = "WaveTop" .. k })
		end
	end,
}
