--!nocheck
-- Owlbear: chunky stud-built bear body with a GIANT cartoon owl head.
-- Warm brown fur with dark lower limbs, cream face disc + stepped belly
-- feather scallops, huge amber voxel eyes, a big dark grey hooked beak with
-- white block teeth, clean stepped ear tufts and spine crests with tiny lime
-- tips, black claws with cream tips and floating forest voxel cubes.
-- Signature: HOOT RAMPAGE.
return {
	DisplayName = "Owlbear",
	Rarity = "Epic",
	Element = "Forest",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local BROWN, DARK, DEEP = "#8a5a32", "#5e3d22", "#462c18"
		local CREAM, TAN = "#f0e0bf", "#d9bd8e"
		local AMBER, AMBER2, PUPIL, GLINT = "#ffb21e", "#ff8a12", "#141018", "#fff3c4"
		local BEAK, BEAK2, BEAK3, MOUTH, TONGUE, WHITE = "#3a3a40", "#4d4d57", "#6c6c78", "#120d10", "#e0607a", "#fffaf0"
		local CLAW, LIME, LEAF = "#1b171a", "#a6ff3a", "#5fb43a"

		-- axis-aligned stepped feather crest (a little voxel staircase leaning back)
		local function crest(bone, y, z, w, neon)
			B:block(bone, v(1.6, 1.0, w), cf(0, y + 0.5, z), DARK)
			B:block(bone, v(1.2, 1.0, w - 0.6), cf(0, y + 1.5, z + 0.4), TAN)
			B:block(bone, v(0.8, 0.8, w - 1.2), cf(0, y + 2.4, z + 0.8), CREAM)
			if neon then
				B:block(bone, v(0.4, 0.4, 0.4), cf(0, y + 3.0, z + 0.9), LIME, { mat = "Neon" })
			end
		end

		------------------------------------------------------------------
		-- HIPS (bear rump) — root of the body, pivot at the hind hip joints
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 5.6, 5.2))
		B:block(hips, v(7.6, 5.6, 6.4), cf(0, 7.2, 4.8), BROWN)
		B:block(hips, v(6.4, 0.8, 5.0), cf(0, 10.4, 4.6), DARK)
		B:block(hips, v(6.2, 4.0, 0.8), cf(0, 7.3, 8.4), BROWN)
		-- light belly band wrapping the underside (reads from the side)
		B:block(hips, v(7.7, 1.4, 6.3), cf(0, 4.9, 4.8), TAN)
		-- cream belly feather plates underneath (they face forward when it rears up)
		for i, r in { { 2.9, 3.4, CREAM }, { 4.6, 3.8, WHITE }, { 6.3, 3.4, CREAM } } do
			B:block(hips, v(r[2], 0.5, 1.75), cf(0, 4.05 - (i % 2) * 0.08, r[1]), r[3])
		end
		-- darker fur saddle stripes across the rump + chevron on the back face
		B:block(hips, v(7.8, 2.0, 0.9), cf(0, 8.9, 7.3), DARK)
		B:block(hips, v(7.8, 2.0, 0.9), cf(0, 8.9, 5.6), DARK)
		B:block(hips, v(6.2, 0.8, 0.3), cf(0, 6.4, 8.9), DARK)
		crest(hips, 10.8, 5.5, 2.0, true)

		-- chunky stepped feather-fan tail with a tiny lime tip
		local tail = B:bone("Tail", "Hips", v(0, 8.6, 8.5))
		B:block(tail, v(3.4, 2.6, 2.0), cf(0, 8.8, 9.6), BROWN)
		B:block(tail, v(3.0, 1.6, 1.4), cf(0, 9.7, 11.0), TAN)
		B:block(tail, v(2.2, 1.2, 1.0), cf(0, 10.5, 11.9), CREAM)
		B:sym(function()
			B:block(tail, v(0.8, 0.8, 0.8), cf(1.4, 10.5, 11.75), CREAM)
		end)
		B:block(tail, v(0.4, 0.4, 0.4), cf(0, 11.2, 12.1), LIME, { mat = "Neon" })

		------------------------------------------------------------------
		-- CHEST (front half: shoulder hump + feather bib)
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Hips", v(0, 7.2, 1.6))
		B:block(chest, v(8.8, 6.4, 7.0), cf(0, 7.4, -1.6), BROWN)
		B:block(chest, v(7.4, 5.2, 2.2), cf(0, 7.4, 2.2), BROWN)
		B:block(chest, v(7.6, 1.4, 5.2), cf(0, 11.3, 0.2), DARK)
		B:block(chest, v(5.4, 0.8, 3.6), cf(0, 12.4, 0.5), DEEP)
		-- lighter feathered underside band wrapping the chest
		B:block(chest, v(8.9, 1.8, 6.9), cf(0, 5.1, -1.6), TAN)
		for i, r in { { -4.15, 4.4, CREAM }, { -2.4, 4.8, WHITE }, { -0.65, 5.4, CREAM }, { 1.1, 5.0, WHITE } } do
			B:block(chest, v(r[2], 0.5, 1.8), cf(0, 4.0 - (i % 2) * 0.08, r[1]), r[3])
		end
		-- stepped cream feather scallops on the chest (owl bib)
		B:block(chest, v(5.6, 1.3, 0.5), cf(0, 6.75, -5.3), CREAM)
		for k = -1, 1 do
			B:block(chest, v(1.2, 0.6, 0.5), cf(k * 1.8, 5.85, -5.32), TAN)
		end
		B:block(chest, v(4.2, 1.1, 0.5), cf(0, 5.1, -5.3), CREAM)
		for k = -1, 1, 2 do
			B:block(chest, v(1.1, 0.6, 0.5), cf(k * 1.05, 4.3, -5.32), TAN)
		end
		B:sym(function()
			-- feather scallops stepping up the chest side (tan -> brown)
			for i = 0, 2 do
				B:block(chest, v(0.3, 0.7, 0.9), cf(4.5, 6.3, -0.75 + i * 1.15), TAN)
			end
		end)
		crest(chest, 12.8, -0.5, 2.4, true)
		crest(chest, 12.0, 2.5, 2.2, false)
		local aura = B:block(chest, v(9, 6, 12), cf(0, 9, 2), BROWN, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "leaf", { name = "Leaves", color = { LEAF, "#9be05a" }, rate = 2.5, size = { 0.45, 0.45, 0.3 } })
		B:emitter(aura, "leaf", { name = "Feathers", color = { CREAM, TAN }, rate = 1.2, size = { 0.5, 0.5, 0.3 } })
		B:emitter(aura, "sparkle", { name = "Sparkles", color = { "#ffffff", LIME }, rate = 3 })
		local featherAt = B:block(chest, v(6, 4, 6), cf(0, 8, -1), BROWN, { tr = 1, name = "FeatherFX" })
		B:emitter(featherAt, "leaf", {
			name = "FeatherBurst", rate = 0, color = { CREAM, TAN, BROWN }, speed = { 8, 15 }, spread = 180,
			size = { 0.7, 0.7, 0.4 }, life = { 1.2, 2.2 }, accel = { 0, -7, 0 },
		})

		------------------------------------------------------------------
		-- NECK (feather ruff) + BIG HEAD
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Chest", v(0, 9.4, -4.8))
		B:block(neck, v(6.0, 5.0, 3.0), cf(0, 9.5, -5.0), BROWN)
		B:block(neck, v(8.0, 1.8, 2.6), cf(0, 8.3, -5.5), CREAM)

		local head = B:bone("Head", "Neck", v(0, 9.4, -7.8))
		B:block(head, v(10.6, 7.2, 6.6), cf(0, 11.3, -8.0), BROWN)
		B:block(head, v(8.8, 0.9, 5.4), cf(0, 15.3, -7.9), BROWN)
		B:block(head, v(9.0, 5.6, 0.6), cf(0, 11.3, -4.5), BROWN)
		B:block(head, v(7.6, 0.6, 5.0), cf(0, 7.55, -8.6), CREAM)
		B:block(head, v(6.0, 0.4, 3.8), cf(0, 15.9, -7.6), DARK)
		-- cream facial disc (stepped so it reads round-ish)
		B:block(head, v(9.4, 5.4, 0.5), cf(0, 11.3, -11.5), CREAM)
		B:block(head, v(7.6, 7.0, 0.4), cf(0, 11.2, -11.45), CREAM)
		B:sym(function()
			-- head side steps + cheek feather tufts
			B:block(head, v(0.7, 5.4, 5.2), cf(5.5, 11.2, -8.0), BROWN)
			B:block(head, v(1.2, 2.8, 3.0), cf(6.0, 9.9, -9.0), DARK)
			B:block(head, v(1.0, 1.8, 2.4), cf(6.6, 8.9, -9.3), TAN)
			B:block(head, v(0.8, 1.0, 1.6), cf(7.1, 8.0, -9.6), CREAM)
			-- eye: dark ring, amber iris (voxel circles = two crossed blocks)
			B:block(head, v(4.2, 3.0, 0.3), cf(2.6, 12.0, -11.85), DARK)
			B:block(head, v(3.0, 4.2, 0.3), cf(2.6, 12.0, -11.88), DARK)
			B:block(head, v(3.6, 2.4, 0.3), cf(2.6, 12.0, -12.05), AMBER)
			B:block(head, v(2.4, 3.6, 0.3), cf(2.6, 12.0, -12.08), AMBER)
			B:block(head, v(2.4, 0.6, 0.3), cf(2.6, 10.7, -12.1), AMBER2) -- lower iris shade
			-- heavy angled brow with a cream top edge
			B:block(head, v(4.4, 1.0, 2.0), cf(2.6, 14.45, -11.8, 0, 0, 12), DARK)
			B:block(head, v(4.0, 0.4, 1.7), cf(2.6, 14.45, -11.8, 0, 0, 12) * CFrame.new(0.1, 0.65, 0.1), CREAM)
		end)
		-- pupils on their own bones so they can dart around
		B:sym(function(side)
			local pu = B:bone("Pupil" .. side, "Head", v(2.5, 11.9, -12.3))
			B:block(pu, v(1.5, 1.7, 0.3), cf(2.4, 11.85, -12.3), PUPIL)
			B:block(pu, v(0.6, 0.6, 0.2), cf(2.85, 12.4, -12.42), GLINT, { mat = "Neon" })
			B:block(pu, v(0.35, 0.35, 0.2), cf(1.95, 11.3, -12.42), GLINT, { mat = "Neon" })
		end)
		-- eyelids: thin plates hidden under the brow, they swing down to blink
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(2.6, 14.15, -12.6))
			B:block(lid, v(4.4, 0.3, 4.4), cf(2.6, 14.15, -10.4), BROWN)
		end)
		-- beak bridge + black mouth cavity (hidden behind the beak until it opens)
		B:block(head, v(1.2, 1.0, 1.0), cf(0, 11.75, -12.0), BEAK3)
		B:block(head, v(2.8, 2.6, 0.5), cf(0, 9.3, -11.65), MOUTH)
		B:block(head, v(1.4, 0.3, 0.2), cf(0, 8.6, -11.95), LIME, { mat = "Neon", name = "MouthGlow" })
		-- back of the head: dark feather chevrons + cream nape
		B:sym(function()
			B:block(head, v(3.6, 0.7, 0.3), cf(1.6, 12.8, -4.1, 0, 0, 18), DARK)
			B:block(head, v(3.0, 0.7, 0.3), cf(1.35, 10.9, -4.1, 0, 0, 18), DARK)
		end)
		B:block(head, v(6.4, 0.8, 0.3), cf(0, 9.2, -4.1), TAN)

		-- upper beak: BIG stepped voxel triangle that hooks down, with block teeth
		local beakTop = B:bone("BeakTop", "Head", v(0, 11.2, -11.4))
		B:block(beakTop, v(3.4, 1.0, 2.2), cf(0, 10.7, -12.5), BEAK2)
		B:block(beakTop, v(2.6, 0.9, 2.0), cf(0, 9.85, -12.9), BEAK)
		B:block(beakTop, v(1.6, 0.8, 1.4), cf(0, 9.1, -13.3), BEAK)
		B:block(beakTop, v(0.5, 0.2, 2.0), cf(0, 11.25, -12.6), BEAK3) -- highlight ridge
		B:sym(function()
			B:block(beakTop, v(0.35, 0.3, 0.15), cf(0.75, 10.9, -13.65), MOUTH) -- nostril
			B:block(beakTop, v(0.4, 0.5, 0.4), cf(1.05, 9.2, -13.3), WHITE)
			B:block(beakTop, v(0.4, 0.5, 0.4), cf(1.05, 9.2, -12.45), WHITE)
		end)

		-- lower beak (opens wide for the hoot)
		local beak = B:bone("Beak", "Head", v(0, 9.2, -11.3))
		B:block(beak, v(2.8, 0.9, 2.2), cf(0, 8.75, -12.35), BEAK)
		B:block(beak, v(2.0, 0.2, 1.4), cf(0, 9.25, -12.2), TONGUE)
		B:sym(function()
			B:block(beak, v(0.4, 0.5, 0.4), cf(1.1, 9.35, -12.9), WHITE)
			B:block(beak, v(0.4, 0.5, 0.4), cf(1.1, 9.35, -12.05), WHITE)
		end)

		-- hoot FX + hidden "sound wave" voxel squares that fly out of the beak
		local hootAt = B:block(head, v(1.5, 1.5, 1.5), cf(0, 9.6, -14.4), BROWN, { tr = 1, name = "HootFX" })
		B:emitter(hootAt, "burst", { name = "HootBurst", color = { "#ffffff", LIME }, speed = { 6, 12 } })
		local function waveSquare(boneName, id, s, color)
			local wb = B:bone(boneName, "Head", v(0, 9.6, -14.2))
			local o = { mat = "Neon", tr = 1 }
			local h = s / 2
			o.name = id .. "1"; B:block(wb, v(s + 0.3, 0.3, 0.3), cf(0, 9.6 + h, -14.2), color, o)
			o.name = id .. "2"; B:block(wb, v(s + 0.3, 0.3, 0.3), cf(0, 9.6 - h, -14.2), color, o)
			o.name = id .. "3"; B:block(wb, v(0.3, s - 0.3, 0.3), cf(h, 9.6, -14.2), color, o)
			o.name = id .. "4"; B:block(wb, v(0.3, s - 0.3, 0.3), cf(-h, 9.6, -14.2), color, o)
		end
		waveSquare("HootWaveA", "HootA", 3.0, LIME)
		waveSquare("HootWaveB", "HootB", 4.6, GLINT)

		-- ear-feather tufts (clean stepped horns, flick on their own bones)
		B:sym(function(side)
			local ear = B:bone("Ear" .. side, "Head", v(3.8, 15.4, -8.2))
			local E = CFrame.new(3.8, 15.2, -8.0) * ang(8, 0, -15)
			B:block(ear, v(2.6, 1.4, 2.6), E * CFrame.new(0, 0.3, 0), DARK)
			B:block(ear, v(2.0, 1.2, 2.0), E * CFrame.new(0.3, 1.4, 0.15), BROWN)
			B:block(ear, v(1.5, 1.1, 1.5), E * CFrame.new(0.55, 2.4, 0.3), TAN)
			B:block(ear, v(1.0, 1.0, 1.0), E * CFrame.new(0.8, 3.35, 0.45), CREAM)
			B:block(ear, v(0.5, 0.5, 0.5), E * CFrame.new(0.95, 4.05, 0.55), LIME, { mat = "Neon" })
		end)

		------------------------------------------------------------------
		-- FRONT LEGS (Arm -> Forearm -> Paw): brown upper, dark lower limb
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Chest", v(3.7, 8.4, -2.6))
			B:block(arm, v(3.0, 4.6, 3.4), cf(3.95, 6.8, -2.7), BROWN)
			B:block(arm, v(3.3, 1.4, 3.7), cf(4.0, 8.6, -2.6), DARK)
			B:block(arm, v(0.4, 2.2, 2.6), cf(5.5, 6.9, -2.7), TAN)
			local fore = B:bone("Forearm" .. side, "Arm" .. side, v(3.95, 4.8, -2.8))
			B:block(fore, v(2.7, 3.8, 2.9), cf(3.95, 3.2, -2.85), DARK)
			B:block(fore, v(3.1, 0.8, 3.3), cf(3.95, 4.6, -2.85), CREAM)
			B:spike(fore, v(4.1, 4.3, -1.7), v(4.6, 5.3, 0.3), 0.9, 0.8, TAN)
			local paw = B:bone("Paw" .. side, "Forearm" .. side, v(3.95, 1.5, -2.8))
			B:block(paw, v(3.2, 1.4, 3.8), cf(3.95, 0.7, -3.2), DARK)
			for k = -1, 1 do
				B:block(paw, v(0.9, 0.6, 0.9), cf(3.95 + k * 1.05, 1.1, -4.75), TAN)
				B:spike(paw, v(3.95 + k * 1.05, 0.6, -4.9), v(3.95 + k * 1.25, 0.35, -7.2), 0.9, 0.8, CLAW)
				B:block(paw, v(0.4, 0.4, 0.4), cf(3.95 + k * 1.24, 0.4, -7.0), CREAM)
			end
			B:trail(paw, v(3.95 + 1.25, 0.45, -7.0), v(3.95 + 1.1, 0.6, -5.4), { name = "ClawTrailA" .. side, color = { LIME, CREAM }, life = 0.32, width = { 1.2, 0 }, trans = { 0.1, 1 } })
			B:trail(paw, v(3.95 - 1.25, 0.45, -7.0), v(3.95 - 1.1, 0.6, -5.4), { name = "ClawTrailB" .. side, color = { LIME, CREAM }, life = 0.32, width = { 1.2, 0 }, trans = { 0.1, 1 } })
			local swipeAt = B:block(paw, v(2.4, 1, 1.4), cf(3.95, 0.5, -6.2), BROWN, { tr = 1, name = "SwipeFX" .. side })
			B:emitter(swipeAt, "burst", { name = "Swipe" .. side, color = { LIME, "#ffffff" }, speed = { 5, 10 }, size = { 0.6, 0.4, 0 } })
		end)

		------------------------------------------------------------------
		-- HIND LEGS (Thigh -> Shin -> Foot)
		------------------------------------------------------------------
		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Hips", v(3.3, 5.6, 5.2))
			B:block(thigh, v(3.4, 5.0, 4.8), cf(3.65, 5.7, 5.0), BROWN)
			B:block(thigh, v(0.5, 3.6, 3.6), cf(5.55, 5.9, 5.1), BROWN)
			B:block(thigh, v(0.6, 1.0, 3.8), cf(5.55, 7.9, 5.1), DARK)
			B:block(thigh, v(0.3, 2.0, 2.0), cf(5.9, 5.4, 5.1), TAN) -- light hip patch
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(3.65, 3.4, 5.4))
			B:block(shin, v(2.8, 2.8, 3.0), cf(3.65, 2.3, 5.5), DARK)
			B:block(shin, v(3.1, 0.6, 3.3), cf(3.65, 3.3, 5.5), CREAM)
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(3.65, 1.2, 5.4))
			B:block(foot, v(3.2, 1.3, 4.4), cf(3.65, 0.65, 4.8), DARK)
			B:wedge(foot, v(1.6, 0.8, 1.0), cf(3.65, 0.4, 7.45, 0, 180, 0), DEEP)
			for k = -1, 1 do
				B:block(foot, v(0.9, 0.5, 0.8), cf(3.65 + k * 1.05, 1.05, 2.95), TAN)
				B:wedge(foot, v(0.7, 0.7, 1.5), cf(3.65 + k * 1.05, 0.35, 1.85), CLAW)
			end
		end)

		------------------------------------------------------------------
		-- Ground FX + floating forest voxel cubes
		------------------------------------------------------------------
		local dustAt = B:block("Root", v(12, 0.3, 6), cf(0, 0.15, -3), BROWN, { tr = 1, name = "DustFX" })
		B:emitter(dustAt, "dust", { name = "ImpactDust", color = "#d9c9a8" })

		-- voxel ground debris that bursts out of the floor on the slam (hidden until then)
		local debrisCol = { LEAF, BROWN, TAN, LEAF, DARK, TAN }
		for i = 1, 6 do
			local a = math.rad(-95 + (i - 1) * 38)
			local pos = v(6.2 * math.sin(a), 0.6, -4.5 - 5.8 * math.cos(a))
			local db = B:bone("Debris" .. i, "Root", pos)
			local sz = (i % 2 == 0) and 1.2 or 1.5
			B:block(db, v(sz, sz, sz), CFrame.new(pos), debrisCol[i], { tr = 1, name = "Debris" .. i })
		end

		-- cartoon claw-scratch marks that flash in the air after each slash (hidden)
		for _, sd in { { "R", 35 }, { "L", -35 } } do
			local sb = B:bone("Slash" .. sd[1], "Root", v(0, 10.5, -8.5))
			for k = -1, 1 do
				local base = cf(0, 10.5, -8.5, 0, 0, sd[2]) * CFrame.new(0, k * 1.1, 0)
				B:block(sb, v(6.0 - math.abs(k) * 1.2, 0.35, 0.3), base, GLINT, { mat = "Neon", tr = 1, name = "Slash" .. sd[1] .. (k + 2) })
			end
		end

		local orbit = B:bone("Orbit", "Root", v(0, 8, 1))
		local spots = {
			{ 12, 11, -2, BROWN }, { -12, 8, 2, DARK }, { 9, 5.5, 9, LEAF },
			{ -9, 14, -8, BROWN }, { -6, 17, 8, LEAF },
		}
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = (i % 2 == 0) and 1.4 or 1.8
			B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), p[4])
			B:block(ob, v(s + 0.1, s * 0.3, s + 0.1), cf(p[1], p[2] + s * 0.36, p[3]), (i % 2 == 0) and TAN or CREAM)
			B:block(ob, v(s + 0.12, s * 0.15, s + 0.12), cf(p[1], p[2] - s * 0.1, p[3]), LIME, { mat = "Neon" })
		end
	end,
}
