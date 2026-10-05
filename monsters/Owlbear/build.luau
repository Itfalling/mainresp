--!nocheck
-- Owlbear: chunky stud-built bear body with a giant cartoon owl head.
-- Warm brown fur, cream face disc + stepped belly feather scallops, huge amber
-- voxel eyes, dark grey hooked beak, ear-feather tufts with tiny lime tips,
-- black claws and floating forest voxel cubes. Signature: HOOT RAMPAGE.
return {
	DisplayName = "Owlbear",
	Rarity = "Epic",
	Element = "Forest",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local BROWN, DARK, DEEP = "#8a5a32", "#5e3d22", "#462c18"
		local CREAM, TAN = "#f0e0bf", "#d9bd8e"
		local AMBER, PUPIL, GLINT = "#ffb21e", "#141018", "#fff3c4"
		local BEAK, BEAK2, BEAK3, MOUTH, TONGUE, WHITE = "#3a3a40", "#4d4d57", "#6c6c78", "#120d10", "#e0607a", "#fffaf0"
		local CLAW, LIME, LEAF = "#1b171a", "#a6ff3a", "#5fb43a"

		-- stepped feather plate (crest along the spine): brown -> dark -> cream tip (+ tiny neon)
		local function crest(bone, x, y, z, w, tilt, neon)
			local base = CFrame.new(x, y, z) * ang(tilt or 22, 0, 0)
			B:block(bone, v(1.6, 1.1, w), base * CFrame.new(0, 0.5, 0), DARK)
			B:block(bone, v(1.2, 1.0, w * 0.72), base * CFrame.new(0, 1.5, 0.2), TAN)
			B:block(bone, v(0.8, 0.9, w * 0.46), base * CFrame.new(0, 2.4, 0.4), CREAM)
			if neon then
				B:block(bone, v(0.45, 0.45, 0.45), base * CFrame.new(0, 3.05, 0.55), LIME, { mat = "Neon" })
			end
		end

		------------------------------------------------------------------
		-- HIPS (bear rump) — root of the body, pivot at the hind hip joints
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 5.6, 5.2))
		B:block(hips, v(7.6, 5.6, 6.4), cf(0, 7.2, 4.8), BROWN)
		B:block(hips, v(6.4, 0.8, 5.0), cf(0, 10.4, 4.6), DARK)
		B:block(hips, v(6.2, 4.0, 0.8), cf(0, 7.3, 8.4), BROWN)
		-- cream belly feather plates underneath (they face forward when it rears up)
		for i, r in { { 2.9, 3.4, CREAM }, { 4.6, 3.8, TAN }, { 6.3, 3.4, CREAM } } do
			B:block(hips, v(r[2], 0.5, 1.75), cf(0, 4.2 - (i % 2) * 0.08, r[1]), r[3])
		end
		-- darker fur saddle stripes across the rump
		B:block(hips, v(7.8, 1.2, 0.9), cf(0, 9.3, 7.3), DARK)
		crest(hips, 0, 10.7, 3.4, 1.8, 24, false)
		crest(hips, 0, 10.6, 5.8, 1.5, 28, true)

		local tail = B:bone("Tail", "Hips", v(0, 8.6, 8.5))
		B:block(tail, v(3.0, 2.6, 2.0), cf(0, 8.8, 9.4), BROWN)
		B:block(tail, v(2.2, 2.0, 1.4), cf(0, 9.35, 10.8), DARK)
		B:block(tail, v(1.5, 1.4, 1.0), cf(0, 9.9, 11.8), TAN)
		B:block(tail, v(0.9, 0.9, 0.7), cf(0, 10.4, 12.4), CREAM)

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
		for i, r in { { -4.15, 4.4, CREAM }, { -2.4, 4.8, TAN }, { -0.65, 5.4, CREAM }, { 1.1, 5.0, TAN } } do
			B:block(chest, v(r[2], 0.5, 1.8), cf(0, 4.0 - (i % 2) * 0.08, r[1]), r[3])
		end
		-- stepped cream feather scallops on the chest (owl bib)
		B:block(chest, v(5.0, 1.3, 0.5), cf(0, 6.75, -5.3), CREAM)
		for k = -1, 1 do
			B:block(chest, v(1.1, 0.6, 0.5), cf(k * 1.65, 5.85, -5.32), TAN)
		end
		B:block(chest, v(3.8, 1.1, 0.5), cf(0, 5.1, -5.3), CREAM)
		for k = -1, 1, 2 do
			B:block(chest, v(1.1, 0.6, 0.5), cf(k * 0.95, 4.3, -5.32), TAN)
		end
		B:sym(function()
			-- feather scallops stepping up the chest side (tan -> brown)
			for i = 0, 2 do
				B:block(chest, v(0.3, 0.7, 0.9), cf(4.5, 6.3, -0.75 + i * 1.15), TAN)
			end
		end)
		crest(chest, 0, 12.6, -0.4, 2.2, 20, true)
		crest(chest, 0, 12.5, 1.9, 2.0, 24, false)
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
		-- NECK (feather ruff) + HEAD
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Chest", v(0, 9.4, -4.8))
		B:block(neck, v(6.0, 5.0, 3.0), cf(0, 9.5, -5.0), BROWN)
		B:block(neck, v(7.0, 1.8, 2.6), cf(0, 8.4, -5.5), CREAM)

		local head = B:bone("Head", "Neck", v(0, 9.4, -7.8))
		B:block(head, v(9.0, 6.2, 6.2), cf(0, 11.0, -8.0), BROWN)
		B:block(head, v(7.4, 0.9, 5.0), cf(0, 14.5, -7.9), BROWN)
		B:block(head, v(7.4, 5.0, 0.6), cf(0, 11.2, -4.7), BROWN)
		B:block(head, v(6.4, 0.6, 4.6), cf(0, 7.65, -8.6), CREAM)
		B:block(head, v(5.2, 0.4, 3.4), cf(0, 15.1, -7.6), DARK)
		-- cream facial disc (stepped so it reads round-ish)
		B:block(head, v(8.0, 4.6, 0.5), cf(0, 10.9, -11.25), CREAM)
		B:block(head, v(6.4, 6.0, 0.4), cf(0, 10.6, -11.2), CREAM)
		B:sym(function()
			-- head side steps + cheek feather tufts
			B:block(head, v(0.7, 4.6, 5.0), cf(4.75, 10.8, -8.0), BROWN)
			B:block(head, v(1.2, 2.6, 3.0), cf(5.2, 9.7, -8.9), DARK)
			B:block(head, v(1.0, 1.6, 2.4), cf(5.85, 8.75, -9.2), TAN)
			B:block(head, v(0.8, 1.0, 1.6), cf(6.35, 7.95, -9.5), CREAM)
			-- eye: dark ring, amber iris (voxel circles = two crossed blocks)
			B:block(head, v(3.6, 2.6, 0.3), cf(2.1, 11.3, -11.6), DARK)
			B:block(head, v(2.6, 3.6, 0.3), cf(2.1, 11.3, -11.63), DARK)
			B:block(head, v(3.0, 2.0, 0.3), cf(2.1, 11.3, -11.8), AMBER)
			B:block(head, v(2.0, 3.0, 0.3), cf(2.1, 11.3, -11.83), AMBER)
			-- heavy angled brow
			B:block(head, v(3.8, 1.0, 1.9), cf(2.2, 13.45, -11.5, 0, 0, 12), DARK)
			B:block(head, v(3.4, 0.4, 1.6), cf(2.2, 13.45, -11.5, 0, 0, 12) * CFrame.new(0.1, 0.65, 0.1), CREAM)
		end)
		-- pupils on their own bones so they can dart around
		B:sym(function(side)
			local pu = B:bone("Pupil" .. side, "Head", v(2.0, 11.2, -11.9))
			B:block(pu, v(1.25, 1.45, 0.3), cf(1.95, 11.15, -11.95), PUPIL)
			B:block(pu, v(0.5, 0.5, 0.2), cf(2.3, 11.6, -12.02), GLINT, { mat = "Neon" })
		end)
		-- eyelids: thin plates hidden under the brow, they swing down to blink
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(2.1, 13.1, -12.4))
			B:block(lid, v(3.5, 0.3, 3.6), cf(2.1, 13.1, -10.6), BROWN)
		end)
		-- beak bridge + black mouth cavity (hidden behind the beak until it opens)
		B:block(head, v(0.9, 0.7, 0.9), cf(0, 11.4, -11.85), BEAK3)
		B:block(head, v(1.3, 1.45, 0.45), cf(0, 9.62, -11.68), MOUTH)
		-- back of the head: dark feather chevrons + cream nape
		B:sym(function()
			B:block(head, v(3.2, 0.7, 0.3), cf(1.45, 12.4, -4.3, 0, 0, 18), DARK)
			B:block(head, v(2.6, 0.7, 0.3), cf(1.2, 10.6, -4.3, 0, 0, 18), DARK)
		end)
		B:block(head, v(5.6, 0.8, 0.3), cf(0, 9.1, -4.3), TAN)

		-- upper beak: stepped voxel triangle that hooks down
		local beakTop = B:bone("BeakTop", "Head", v(0, 10.9, -11.3))
		B:block(beakTop, v(2.2, 0.8, 1.5), cf(0, 10.6, -12.05), BEAK2)
		B:block(beakTop, v(1.6, 0.7, 1.4), cf(0, 9.85, -12.2), BEAK)
		B:block(beakTop, v(0.9, 0.6, 0.8), cf(0, 9.2, -12.5), BEAK)
		B:block(beakTop, v(1.4, 0.2, 1.1), cf(0, 11.1, -12.0), BEAK3)
		B:sym(function()
			B:block(beakTop, v(0.25, 0.25, 0.15), cf(0.6, 10.75, -12.85), MOUTH)
			B:block(beakTop, v(0.3, 0.35, 0.3), cf(0.5, 9.35, -12.0), WHITE)
		end)

		-- lower beak (opens wide for the hoot)
		local beak = B:bone("Beak", "Head", v(0, 9.6, -11.1))
		B:block(beak, v(1.5, 0.7, 1.6), cf(0, 9.22, -11.9), BEAK)
		B:block(beak, v(1.0, 0.15, 1.1), cf(0, 9.62, -11.8), TONGUE)
		B:sym(function()
			B:block(beak, v(0.3, 0.3, 0.3), cf(0.5, 9.7, -12.35), WHITE)
		end)

		-- hoot FX + hidden "sound wave" voxel squares that fly out of the beak
		local hootAt = B:block(head, v(1.5, 1.5, 1.5), cf(0, 9.6, -13.2), BROWN, { tr = 1, name = "HootFX" })
		B:emitter(hootAt, "burst", { name = "HootBurst", color = { "#ffffff", LIME }, speed = { 6, 12 } })
		local function waveSquare(boneName, id, s, color)
			local wb = B:bone(boneName, "Head", v(0, 9.5, -13.6))
			local o = { mat = "Neon", tr = 1 }
			local h = s / 2
			o.name = id .. "1"; B:block(wb, v(s + 0.3, 0.3, 0.3), cf(0, 9.5 + h, -13.6), color, o)
			o.name = id .. "2"; B:block(wb, v(s + 0.3, 0.3, 0.3), cf(0, 9.5 - h, -13.6), color, o)
			o.name = id .. "3"; B:block(wb, v(0.3, s - 0.3, 0.3), cf(h, 9.5, -13.6), color, o)
			o.name = id .. "4"; B:block(wb, v(0.3, s - 0.3, 0.3), cf(-h, 9.5, -13.6), color, o)
		end
		waveSquare("HootWaveA", "HootA", 2.4, LIME)
		waveSquare("HootWaveB", "HootB", 3.8, GLINT)

		-- ear-feather tufts (stepped, flick on their own bones)
		B:sym(function(side)
			local ear = B:bone("Ear" .. side, "Head", v(3.3, 13.9, -8.2))
			local E = CFrame.new(3.3, 13.6, -8.0) * ang(12, 0, -30)
			B:block(ear, v(2.6, 1.6, 2.6), E * CFrame.new(0, 0.3, 0), DARK)
			B:block(ear, v(2.0, 1.3, 2.0), E * CFrame.new(0.3, 1.5, 0.15), BROWN)
			B:block(ear, v(1.5, 1.2, 1.5), E * CFrame.new(0.55, 2.6, 0.3), TAN)
			B:block(ear, v(1.0, 1.0, 1.0), E * CFrame.new(0.8, 3.6, 0.45), CREAM)
			B:block(ear, v(0.6, 0.6, 0.6), E * CFrame.new(0.95, 4.35, 0.55), LIME, { mat = "Neon" })
			B:block(ear, v(1.1, 1.3, 1.1), E * CFrame.new(-0.6, 1.3, 1.3) * ang(35, 0, 0), DARK)
			B:block(ear, v(0.7, 0.7, 0.7), E * CFrame.new(-0.6, 2.2, 1.9) * ang(35, 0, 0), TAN)
		end)

		------------------------------------------------------------------
		-- FRONT LEGS (Arm -> Forearm -> Paw)
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Chest", v(3.7, 8.4, -2.6))
			B:block(arm, v(3.0, 4.6, 3.4), cf(3.95, 6.8, -2.7), BROWN)
			B:block(arm, v(3.3, 1.4, 3.7), cf(4.0, 8.6, -2.6), DARK)
			B:block(arm, v(0.4, 2.2, 2.6), cf(5.5, 6.9, -2.7), BROWN)
			local fore = B:bone("Forearm" .. side, "Arm" .. side, v(3.95, 4.8, -2.8))
			B:block(fore, v(2.7, 3.8, 2.9), cf(3.95, 3.2, -2.85), BROWN)
			B:block(fore, v(3.1, 0.8, 3.3), cf(3.95, 2.0, -2.85), CREAM)
			B:block(fore, v(0.25, 2.0, 0.25), cf(5.3, 3.5, -4.25), LIME, { mat = "Neon" })
			B:spike(fore, v(4.1, 4.3, -1.7), v(4.6, 5.3, 0.3), 0.9, 0.8, TAN)
			local paw = B:bone("Paw" .. side, "Forearm" .. side, v(3.95, 1.5, -2.8))
			B:block(paw, v(3.2, 1.4, 3.8), cf(3.95, 0.7, -3.2), BROWN)
			for k = -1, 1 do
				B:block(paw, v(0.9, 0.6, 0.9), cf(3.95 + k * 1.05, 1.1, -4.75), DARK)
				B:spike(paw, v(3.95 + k * 1.05, 0.6, -4.9), v(3.95 + k * 1.2, 0.3, -6.5), 0.6, 0.6, CLAW)
			end
			B:trail(paw, v(3.95 + 1.2, 0.45, -6.1), v(3.95 + 1.1, 0.55, -5.2), { name = "ClawTrailA" .. side, color = { LIME, CREAM }, life = 0.22, trans = { 0.25, 1 }, light = 0.4 })
			B:trail(paw, v(3.95 - 1.2, 0.45, -6.1), v(3.95 - 1.1, 0.55, -5.2), { name = "ClawTrailB" .. side, color = { LIME, CREAM }, life = 0.22, trans = { 0.25, 1 }, light = 0.4 })
			local swipeAt = B:block(paw, v(2.4, 1, 1.4), cf(3.95, 0.5, -5.8), BROWN, { tr = 1, name = "SwipeFX" .. side })
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
			B:block(thigh, v(0.25, 2.4, 0.25), cf(5.75, 5.6, 3.25), LIME, { mat = "Neon" })
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(3.65, 3.4, 5.4))
			B:block(shin, v(2.8, 2.8, 3.0), cf(3.65, 2.3, 5.5), BROWN)
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(3.65, 1.2, 5.4))
			B:block(foot, v(3.2, 1.3, 4.4), cf(3.65, 0.65, 4.8), BROWN)
			B:wedge(foot, v(1.6, 0.8, 1.0), cf(3.65, 0.4, 7.45, 0, 180, 0), DARK)
			for k = -1, 1 do
				B:block(foot, v(0.9, 0.5, 0.8), cf(3.65 + k * 1.05, 1.05, 2.95), DARK)
				B:wedge(foot, v(0.6, 0.7, 1.3), cf(3.65 + k * 1.05, 0.35, 1.95), CLAW)
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
			local sb = B:bone("Slash" .. sd[1], "Root", v(0, 10.5, -7.5))
			for k = -1, 1 do
				local base = cf(0, 10.5, -7.5, 0, 0, sd[2]) * CFrame.new(0, k * 0.95, 0)
				B:block(sb, v(5.2 - math.abs(k) * 1.0, 0.3, 0.3), base, GLINT, { mat = "Neon", tr = 1, name = "Slash" .. sd[1] .. (k + 2) })
			end
		end

		local orbit = B:bone("Orbit", "Root", v(0, 8, 1))
		local spots = {
			{ 9.5, 11.0, -2, BROWN }, { -9.5, 8.0, 2, CREAM }, { 7.5, 5.5, 7.5, LEAF },
			{ -7.0, 13.0, -6, DARK }, { 1.5, 16.0, 5.5, LEAF },
		}
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = (i % 2 == 0) and 1.3 or 1.7
			B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), p[4])
			B:block(ob, v(s + 0.1, s * 0.22, s + 0.1), cf(p[1], p[2], p[3]), LIME, { mat = "Neon" })
		end
	end,
}
