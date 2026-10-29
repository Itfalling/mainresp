--!nocheck
-- Ironhorn Rhino (Guardian #6, Mythic): a massive armoured rhino knight that
-- guards an orchard. Chunky stepped blue-slate body, bright steel armour plates
-- with dark iron trim and gold rivets over the shoulders, back, neck and
-- forehead, a HUGE stepped ivory front horn with an iron cap (hot-orange neon
-- edge + tip), a smaller iron-capped second horn, moss patches + leaf sprigs +
-- a little flower growing on the armour, pillar legs with ivory-nailed hooves
-- and a tufted tail. Small mean eyes under heavy iron brows, ONE underbite
-- jaw with bully tusks. Steam snorts out of the nostrils (smoke bursts).
return {
	DisplayName = "Ironhorn Rhino",
	Rarity = "Mythic",
	Element = "Earth",
	Build = function(B, P)
		local v, cf = P.v, P.cf

		-- palette
		local SLATE, DARK, BELLY = "#5c6b92", "#3a4466", "#9aa6c8"
		local STEEL, STEELD, IRON = "#d3d9e6", "#9aa3b8", "#2c303c"
		local GOLD, GOLDD = "#ffc531", "#c98d1a"
		local IVORY, IVORYD = "#f1e6c8", "#d2bf94"
		local MOSS, MOSSD, LEAF = "#5fae3a", "#3f8a2c", "#8fdc4a"
		local MOUTH, TONGUE, WHITE, PUPIL = "#16121c", "#d9486e", "#fffaf0", "#1a0c06"
		local HAIR, PINK = "#262a36", "#e88aa4"
		local NEON, EYE = "#ff6a1a", "#ffc93a"
		local N = { mat = "Neon" }

		local function rivet(bone, x, y, z, sx, sy, sz)
			B:block(bone, v(sx or 0.5, sy or 0.5, sz or 0.5), cf(x, y, z), GOLD)
		end

		-- stepped iron spine stud with a gold or neon tip
		local function stud(bone, x, y, z, neon)
			B:block(bone, v(1.3, 0.6, 1.5), cf(x, y + 0.3, z), DARK)
			B:block(bone, v(0.8, 0.5, 0.9), cf(x, y + 0.8, z + 0.15), STEELD)
			B:block(bone, v(0.4, 0.4, 0.45), cf(x, y + 1.2, z + 0.25), neon and NEON or GOLD, neon and N or nil)
		end

		local head_
		-- beam along a->b plus an optional thin neon strip on its front (-Z) edge
		local function hornSeg(a, b, w, col, edge)
			B:beam(head_, a, b, w, w, col)
			if edge then
				local d = (b - a).Unit
				local n = v(0, -d.Z, d.Y) -- perpendicular in the side plane
				if n.Z > 0 then n = -n end
				local o = n * (w / 2 + 0.05)
				local m = (a + b) / 2
				local half = (b - a) * 0.3
				B:beam(head_, m - half + o, m + half + o, 0.32, 0.15, NEON, N)
			end
		end

		------------------------------------------------------------------
		-- HIPS (rear barrel, rounded by stepped hide plates) — pivot at the hind hips
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 6.6, 3.6))
		B:block(hips, v(8.0, 5.6, 5.6), cf(0, 7.7, 3.2), SLATE)
		B:block(hips, v(7.0, 0.8, 4.8), cf(0, 10.85, 3.1), SLATE) -- rounded back steps
		B:block(hips, v(5.0, 0.6, 3.6), cf(0, 11.5, 3.1), SLATE)
		B:block(hips, v(6.8, 0.8, 4.6), cf(0, 4.6, 3.1), BELLY) -- belly underside
		B:block(hips, v(5.4, 0.4, 1.6), cf(0, 4.1, 2.0), STEELD)
		B:block(hips, v(4.6, 0.4, 1.4), cf(0, 4.15, 4.0), BELLY)
		B:block(hips, v(7.0, 4.4, 0.5), cf(0, 7.5, 6.1), SLATE) -- rump
		B:block(hips, v(5.4, 3.2, 0.5), cf(0, 7.6, 6.45), DARK)
		B:sym(function()
			-- hide folds: stepped darker plates down the flank
			B:block(hips, v(0.5, 4.6, 0.8), cf(4.05, 7.6, 1.2), DARK) -- waist fold
			B:block(hips, v(0.4, 3.0, 2.6), cf(4.1, 8.2, 4.4), DARK) -- haunch plate
			B:block(hips, v(0.5, 0.6, 4.2), cf(3.65, 10.6, 3.2), DARK) -- back-step edge
			B:block(hips, v(0.4, 0.5, 2.0), cf(4.1, 5.6, 3.4), BELLY) -- lower flank fold
		end)
		-- steel saddle plate over the waist fold, with rivets, neon seam and moss
		B:block(hips, v(8.0, 0.5, 2.8), cf(0, 11.5, 1.2), STEEL)
		B:block(hips, v(8.2, 0.35, 0.4), cf(0, 11.45, 2.65), IRON)
		B:block(hips, v(8.2, 0.35, 0.4), cf(0, 11.45, -0.25), IRON)
		B:sym(function()
			B:block(hips, v(0.4, 2.2, 2.8), cf(4.15, 10.2, 1.2), STEEL)
			B:block(hips, v(0.45, 0.35, 2.9), cf(4.17, 9.0, 1.2), IRON)
			B:block(hips, v(0.2, 0.25, 2.0), cf(4.4, 10.5, 1.2), NEON, N)
			rivet(hips, 4.42, 9.6, 0.4, 0.3, 0.45, 0.45)
			rivet(hips, 4.42, 9.6, 2.0, 0.3, 0.45, 0.45)
			rivet(hips, 3.2, 11.8, 1.2, 0.5, 0.3, 0.5)
		end)
		stud(hips, 0, 11.75, 1.2, true)
		-- moss growing over the rump
		B:block(hips, v(3.4, 0.5, 2.6), cf(-1.2, 11.95, 3.6), MOSS)
		B:block(hips, v(1.8, 0.45, 1.6), cf(1.7, 11.85, 4.3), MOSSD)
		B:block(hips, v(1.2, 0.45, 1.2), cf(-3.0, 11.3, 4.6), MOSS)
		B:block(hips, v(0.4, 1.2, 0.9), cf(-3.75, 10.4, 4.6), MOSS) -- moss drip over the edge

		-- little flower sprouting from the rump moss (wobbles)
		local flower = B:bone("SprigB", "Hips", v(-1.6, 12.1, 3.8))
		B:block(flower, v(0.3, 1.2, 0.3), cf(-1.6, 12.7, 3.8), MOSSD)
		B:block(flower, v(0.8, 0.25, 0.4), cf(-1.2, 12.6, 3.8, 0, 0, 25), LEAF)
		B:block(flower, v(0.5, 0.5, 0.5), cf(-1.6, 13.45, 3.8), GOLD)
		for _, o in { { 0.5, 0 }, { -0.5, 0 }, { 0, 0.5 }, { 0, -0.5 } } do
			B:block(flower, v(0.5, 0.45, 0.5), cf(-1.6 + o[1], 13.45, 3.8 + o[2]), PINK)
		end

		------------------------------------------------------------------
		-- TAIL (short, with a dark hair tuft)
		------------------------------------------------------------------
		local tail1 = B:bone("Tail1", "Hips", v(0, 9.2, 6.1))
		B:block(tail1, v(1.4, 1.4, 1.6), cf(0, 9.1, 6.7), SLATE)
		local tail2 = B:bone("Tail2", "Tail1", v(0, 9.0, 7.3))
		B:block(tail2, v(1.0, 2.4, 1.0), cf(0, 8.0, 7.5), SLATE)
		B:block(tail2, v(1.1, 0.4, 1.1), cf(0, 8.9, 7.5), IRON) -- iron tail ring
		rivet(tail2, 0, 8.9, 8.0, 0.35, 0.3, 0.2)
		local tuft = B:bone("Tuft", "Tail2", v(0, 6.9, 7.5))
		B:block(tuft, v(1.6, 1.4, 1.5), cf(0, 6.3, 7.5), HAIR)
		B:block(tuft, v(1.1, 1.0, 1.1), cf(0, 5.2, 7.55), HAIR)
		B:block(tuft, v(0.6, 0.6, 0.6), cf(0, 4.5, 7.6), DARK)
		B:block(tuft, v(0.8, 0.25, 0.5), cf(0.75, 6.9, 7.5, 0, 0, 30), LEAF)
		B:trail(tuft, v(0, 6.2, 7.6), v(0, 4.4, 7.6), { name = "TailTrail", color = { STEEL, MOSS }, life = 0.22, trans = { 0.45, 1 } })

		------------------------------------------------------------------
		-- CHEST (front barrel with the big shoulder hump + steel pauldrons)
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Hips", v(0, 7.4, 0.8))
		B:block(chest, v(8.8, 6.4, 5.6), cf(0, 7.9, -1.4), SLATE)
		B:block(chest, v(7.8, 0.9, 5.0), cf(0, 11.5, -1.3), SLATE) -- hump steps
		B:block(chest, v(6.0, 0.8, 3.8), cf(0, 12.3, -1.1), SLATE)
		B:block(chest, v(4.0, 0.4, 2.6), cf(0, 12.8, -0.9), DARK)
		B:block(chest, v(7.6, 0.8, 4.8), cf(0, 4.5, -1.4), BELLY)
		for i, r in { { -3.3, 5.6 }, { -1.6, 6.4 }, { 0.1, 5.6 } } do
			B:block(chest, v(r[2], 0.4, 1.5), cf(0, 4.0 - (i % 2) * 0.1, r[1]), i % 2 == 0 and STEELD or BELLY)
		end
		-- light stepped chest scales under the neck (read from 3/4 + below)
		for i, r in { { 6.4, 4.2 }, { 5.4, 5.2 }, { 4.4, 4.2 } } do
			B:block(chest, v(r[2], 1.0, 0.6), cf(0, r[1], -4.35 - (i % 2) * 0.2), i % 2 == 0 and BELLY or SLATE)
		end
		B:sym(function()
			B:block(chest, v(0.5, 0.7, 4.6), cf(3.65, 11.35, -1.3), DARK) -- hump edge fold
			B:block(chest, v(0.5, 4.8, 0.8), cf(4.45, 7.6, 1.0), DARK) -- shoulder fold
			B:block(chest, v(0.4, 3.0, 1.0), cf(4.5, 6.4, 0.0), BELLY)
		end)
		stud(chest, 0, 13.0, -1.8, true)
		stud(chest, 0, 12.7, 0.2)
		-- moss + leaf sprig on the hump
		B:block(chest, v(2.6, 0.5, 2.2), cf(1.6, 12.85, -2.2), MOSS)
		B:block(chest, v(1.6, 0.45, 1.8), cf(-2.2, 12.6, -0.3), MOSSD)
		B:block(chest, v(1.4, 0.4, 1.2), cf(-3.0, 11.95, -3.2), MOSS)
		local sprig = B:bone("SprigA", "Chest", v(2.2, 13.0, -2.4))
		B:block(sprig, v(0.3, 1.1, 0.3), cf(2.2, 13.5, -2.4), MOSSD)
		B:block(sprig, v(1.1, 0.25, 0.6), cf(2.7, 13.85, -2.4, 0, 0, 28), LEAF)
		B:block(sprig, v(0.9, 0.25, 0.55), cf(1.75, 13.65, -2.4, 0, 0, -28), LEAF)

		local aura = B:block(chest, v(9, 3, 12), cf(0, 12.5, 1), SLATE, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "leaf", { name = "Leaves", color = { LEAF, MOSS }, rate = 1.5, size = { 0.45, 0.45, 0.3 } })
		B:emitter(aura, "sparkle", { name = "Twinkle", color = { "#ffffff", EYE }, rate = 2.5 })

		------------------------------------------------------------------
		-- NECK (thick, with hide folds and an armoured top plate)
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Chest", v(0, 8.4, -3.6))
		B:block(neck, v(6.6, 5.0, 3.0), cf(0, 8.2, -4.9), SLATE)
		B:block(neck, v(7.0, 4.6, 0.6), cf(0, 8.1, -4.3), DARK) -- neck fold
		B:block(neck, v(5.2, 0.8, 2.8), cf(0, 5.75, -5.0), BELLY)
		B:block(neck, v(6.2, 0.5, 2.6), cf(0, 10.85, -5.0), STEEL)
		B:sym(function()
			rivet(neck, 2.6, 11.15, -5.0, 0.5, 0.3, 0.5)
		end)

		------------------------------------------------------------------
		-- HEAD: long, low wedge (tall cranium -> mid face -> snout), the big
		-- scimitar horn on the snout tip, small mean eyes on the sides behind
		-- it, tube ears on top, a hooked upper lip.
		------------------------------------------------------------------
		local head = B:bone("Head", "Neck", v(0, 7.8, -6.0))
		head_ = head
		B:block(head, v(6.6, 4.6, 3.8), cf(0, 8.1, -7.2), SLATE) -- cranium
		B:block(head, v(6.9, 4.0, 0.5), cf(0, 7.9, -5.6), DARK) -- hide fold behind the head
		B:block(head, v(5.4, 0.6, 3.0), cf(0, 10.6, -7.2), SLATE) -- crown step
		B:block(head, v(5.6, 3.8, 3.4), cf(0, 7.3, -10.4), SLATE) -- mid face
		B:block(head, v(4.8, 3.0, 3.4), cf(0, 6.6, -13.4), SLATE) -- snout
		B:block(head, v(4.0, 0.5, 3.0), cf(0, 8.3, -13.3), SLATE) -- snout top step (horn seat)
		B:block(head, v(5.7, 0.5, 3.3), cf(0, 5.6, -10.4), DARK) -- lip line (mid face)
		B:block(head, v(4.9, 0.5, 3.3), cf(0, 5.35, -13.4), DARK) -- lip line (snout)
		B:block(head, v(4.4, 0.3, 6.0), cf(0, 5.0, -12.2), MOUTH) -- mouth roof
		-- hooked prehensile upper lip
		B:block(head, v(2.6, 1.2, 1.0), cf(0, 5.6, -15.5), SLATE)
		B:block(head, v(1.8, 0.8, 0.8), cf(0, 4.8, -15.6), DARK)
		B:block(head, v(1.0, 0.5, 0.6), cf(0, 4.35, -15.5), DARK)
		-- forehead armour plate
		B:block(head, v(5.0, 0.5, 2.8), cf(0, 11.1, -7.4), STEEL)
		B:block(head, v(5.2, 0.35, 0.4), cf(0, 11.05, -8.8), IRON)
		B:sym(function()
			rivet(head, 2.1, 11.4, -6.6, 0.5, 0.3, 0.5)
			rivet(head, 2.1, 11.4, -8.2, 0.5, 0.3, 0.5)
			-- cheek armour guard behind the eye
			B:block(head, v(0.4, 2.4, 2.6), cf(3.4, 8.0, -7.2), STEEL)
			B:block(head, v(0.45, 0.35, 2.7), cf(3.42, 6.75, -7.2), IRON)
			rivet(head, 3.65, 8.6, -6.4, 0.3, 0.45, 0.45)
			rivet(head, 3.65, 8.6, -8.0, 0.3, 0.45, 0.45)
			-- hide folds: stepped plates down the face side
			B:block(head, v(0.3, 2.8, 0.6), cf(2.85, 7.0, -11.9), DARK)
			B:block(head, v(0.3, 2.2, 3.0), cf(2.45, 6.9, -13.6), DARK)
			-- nostril on the snout side near the tip
			B:block(head, v(0.25, 0.5, 0.9), cf(2.5, 7.3, -14.6), MOUTH)
			-- blunt front tooth (only seen when the mouth opens)
			B:block(head, v(0.7, 0.5, 0.6), cf(1.1, 4.75, -14.6), IVORY)
			-- EYE on the side of the face behind the horn: a bump, dark socket,
			-- glow wrapping its front/outer corner, pupil on the front face only
			B:block(head, v(1.3, 2.0, 2.2), cf(2.95, 8.2, -9.9), SLATE)
			B:block(head, v(1.2, 1.1, 1.2), cf(3.2, 8.3, -10.5), IRON)
			B:block(head, v(0.9, 0.8, 0.9), cf(3.4, 8.3, -10.7), EYE, { mat = "Neon", name = "Eye" })
			B:block(head, v(0.4, 0.55, 0.1), cf(3.15, 8.25, -11.18), PUPIL)
			-- heavy angry steel brow, inner end down
			B:block(head, v(2.2, 0.6, 1.7), cf(2.95, 9.3, -10.45, 0, 0, 16), STEEL)
			B:block(head, v(1.0, 0.45, 1.3), cf(3.55, 9.75, -10.2, 0, 0, 16), STEELD)
		end)

		-- second (smaller) horn on the mid face, iron capped
		B:block(head, v(2.0, 0.6, 2.0), cf(0, 9.4, -10.6), IVORYD)
		B:beam(head, v(0, 9.3, -10.6), v(0, 10.7, -10.9), 1.6, 1.6, IVORY)
		B:beam(head, v(0, 10.55, -10.85), v(0, 11.35, -10.55), 1.0, 1.0, STEELD)

		-- the HUGE front horn: a scimitar of ivory beams curving forward then up
		-- and back, a riveted steel cap band, neon front edge and tip
		local H = { v(0, 7.9, -13.3), v(0, 9.7, -14.4), v(0, 11.5, -14.9), v(0, 12.9, -14.6), v(0, 13.8, -13.9), v(0, 14.25, -13.2) }
		B:block(head, v(3.6, 0.5, 3.4), cf(0, 8.6, -13.4), IVORYD) -- root collar
		hornSeg(H[1], H[2], 3.0, IVORY)
		hornSeg(H[2], H[3], 2.3, IVORY, true)
		hornSeg(H[3], H[4], 1.7, IVORY, true)
		hornSeg(H[4], H[5], 1.2, IVORYD)
		B:beam(head, v(0, 9.45, -14.27), v(0, 10.05, -14.47), 2.75, 2.75, STEEL) -- cap band
		B:beam(head, v(0, 9.3, -14.2), v(0, 9.5, -14.27), 2.95, 2.95, IRON)
		local hornTip = B:beam(head, H[5], H[6], 0.7, 0.7, NEON, { mat = "Neon", name = "HornTip" })
		B:light(hornTip, { name = "HornLight", color = NEON, brightness = 0.5, range = 7 })
		B:sym(function()
			rivet(head, 1.38, 9.75, -14.37, 0.3, 0.4, 0.4)
		end)
		rivet(head, 0, 9.85, -15.8, 0.4, 0.4, 0.3)
		B:trail(head, v(0, 14.2, -13.3), v(0, 12.6, -14.9), { name = "HornTrail", color = { NEON, "#ffffff" }, life = 0.2, trans = { 0.35, 1 } })
		local hornFX = B:block(head, v(1.4, 1.2, 1.2), cf(0, 13.6, -14.2), SLATE, { tr = 1, name = "HornFX" })
		B:emitter(hornFX, "burst", { name = "HornBurst", color = { "#ffffff", NEON, GOLD }, speed = { 7, 14 }, size = { 0.6, 0.4, 0 } })

		-- nostril steam (forward + a little down) and head steam (anger)
		local nostrils = B:block(head, v(4.4, 0.5, 0.4), cf(0, 7.0, -15.0, -25, 0, 0), SLATE, { tr = 1, name = "NostrilFX" })
		B:emitter(nostrils, "smoke", {
			name = "Steam", rate = 0, color = { "#ffffff", "#d9e2ee" }, life = { 0.45, 0.9 }, speed = { 5, 9 },
			size = { 0.5, 1.5, 2.2 }, trans = { 0.15, 0.45, 1 }, spread = 18, accel = { 0, 3, 0 }, drag = 3, dir = "Front",
		})
		local headSteam = B:block(head, v(5.0, 0.4, 2.0), cf(0, 11.6, -6.6), SLATE, { tr = 1, name = "HeadSteamFX" })
		B:emitter(headSteam, "smoke", {
			name = "HeadSteam", rate = 0, color = { "#ffffff", "#e6ecf4" }, life = { 0.6, 1.1 }, speed = { 5, 9 },
			size = { 0.6, 1.6, 2.4 }, trans = { 0.15, 0.5, 1 }, spread = 25, accel = { 0, 2, 0 }, drag = 2,
		})

		-- eyelids (props: shown only while blinking / squinting)
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(3.42, 9.2, -10.7))
			B:block(lid, v(1.05, 1.0, 1.15), cf(3.42, 9.2, -10.7), SLATE, { tr = 1, name = "Eyelid" .. side })
		end)

		-- tube ears on top of the head
		B:sym(function(side)
			local ear = B:bone("Ear" .. side, "Head", v(2.2, 10.6, -6.6))
			local e = cf(2.2, 10.6, -6.6, 0, 0, -18)
			B:block(ear, v(1.2, 1.4, 1.0), e * CFrame.new(0, 0.6, 0), SLATE)
			B:block(ear, v(1.0, 1.0, 0.8), e * CFrame.new(0, 1.7, 0), SLATE)
			B:block(ear, v(0.6, 1.4, 0.15), e * CFrame.new(0, 1.2, -0.48), PINK)
			B:block(ear, v(0.6, 0.5, 0.6), e * CFrame.new(0, 2.4, 0), DARK)
		end)

		-- anger mark (prop) floating at the top corner of the head
		local anger = B:bone("Anger", "Head", v(3.6, 12.2, -8.8))
		local ac = "#ff2d2d"
		for i, o in { { -0.45, 0.2, 0.9, 0.3 }, { 0.45, 0.2, 0.9, 0.3 }, { 0, 0.65, 0.3, 0.9 }, { 0, -0.25, 0.3, 0.9 } } do
			local a = cf(3.6, 12.2, -8.8, 0, -30, 0) * CFrame.new(o[1], o[2] - 0.2, 0)
			B:block(anger, v(o[3], o[4], 0.3), a, ac, { tr = 1, name = "Anger" .. i })
		end

		-- JAW: a long rhino lower lip, no tusk row
		local jaw = B:bone("Jaw", "Head", v(0, 5.3, -9.6))
		B:block(jaw, v(4.4, 1.2, 5.0), cf(0, 4.4, -12.2), BELLY)
		B:block(jaw, v(3.8, 0.45, 4.4), cf(0, 3.7, -12.0), DARK)
		B:block(jaw, v(3.8, 0.25, 4.6), cf(0, 5.05, -12.2), MOUTH)
		B:block(jaw, v(2.2, 0.3, 2.8), cf(0, 5.15, -11.8), TONGUE)
		B:block(jaw, v(3.8, 1.3, 0.4), cf(0, 5.55, -9.9), MOUTH) -- back of the mouth
		B:block(jaw, v(3.4, 0.5, 0.5), cf(0, 4.55, -14.75), BELLY) -- lower lip
		B:sym(function()
			B:block(jaw, v(0.6, 0.45, 0.6), cf(1.2, 5.25, -14.1), IVORY) -- blunt tooth
		end)

		------------------------------------------------------------------
		-- FRONT LEGS (Arm -> Fore -> Hoof) with steel pauldrons
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Chest", v(3.6, 6.6, -2.2))
			B:block(arm, v(3.2, 3.8, 3.4), cf(3.6, 5.2, -2.0), SLATE)
			B:block(chest, v(1.0, 3.4, 4.2), cf(5.0, 8.3, -2.1), STEEL) -- pauldron
			B:block(chest, v(2.8, 0.6, 4.2), cf(4.3, 10.0, -2.1), STEEL)
			B:block(chest, v(1.1, 0.45, 4.3), cf(5.05, 6.55, -2.1), IRON)
			B:block(chest, v(0.3, 0.3, 2.8), cf(5.55, 9.2, -2.1), STEELD)
			B:block(chest, v(0.2, 0.25, 2.2), cf(5.55, 7.3, -2.1), NEON, N)
			rivet(chest, 5.6, 8.4, -3.6, 0.3, 0.5, 0.5)
			rivet(chest, 5.6, 8.4, -0.6, 0.3, 0.5, 0.5)
			B:block(chest, v(1.8, 0.45, 2.4), cf(4.3, 10.45, -1.6), MOSS)
			B:block(chest, v(0.4, 0.9, 0.9), cf(5.6, 9.7, -0.9), MOSSD)
			local fore = B:bone("Fore" .. side, "Arm" .. side, v(3.6, 3.9, -2.7))
			B:block(fore, v(2.9, 3.0, 2.9), cf(3.6, 2.7, -2.0), DARK)
			B:block(fore, v(2.2, 1.2, 0.4), cf(3.6, 3.3, -3.55), STEEL) -- knee plate
			rivet(fore, 3.6, 3.3, -3.8, 0.4, 0.4, 0.15)
			local hoof = B:bone("Hoof" .. side, "Fore" .. side, v(3.6, 1.3, -2.2))
			B:block(hoof, v(3.4, 1.2, 3.6), cf(3.6, 0.7, -2.3), DARK)
			B:block(hoof, v(3.6, 0.35, 3.8), cf(3.6, 0.17, -2.3), IRON)
			B:block(hoof, v(3.1, 0.4, 3.3), cf(3.6, 1.45, -2.2), SLATE)
			for k = -1, 1 do
				B:block(hoof, v(0.9, 0.8, 0.6), cf(3.6 + k * 1.15, 0.5, -4.2), IVORY)
			end
			B:trail(hoof, v(3.6, 1.2, -4.4), v(3.6, 0.2, -4.4), { name = "HoofTrail" .. side, color = { STEEL, "#ffffff" }, life = 0.14, trans = { 0.5, 1 } })
		end)

		------------------------------------------------------------------
		-- HIND LEGS (Thigh -> Shin -> Foot)
		------------------------------------------------------------------
		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Hips", v(3.6, 6.6, 3.8))
			B:block(thigh, v(3.4, 4.0, 3.8), cf(3.6, 5.2, 3.9), SLATE)
			B:block(thigh, v(0.4, 2.4, 2.8), cf(5.35, 5.6, 4.0), DARK)
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(3.6, 3.9, 3.4))
			B:block(shin, v(2.9, 3.0, 2.9), cf(3.6, 2.7, 3.8), DARK)
			B:block(shin, v(2.2, 0.9, 0.4), cf(3.6, 3.5, 2.25), STEELD)
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(3.6, 1.3, 4.0))
			B:block(foot, v(3.4, 1.2, 3.6), cf(3.6, 0.7, 3.7), DARK)
			B:block(foot, v(3.6, 0.35, 3.8), cf(3.6, 0.17, 3.7), IRON)
			B:block(foot, v(3.1, 0.4, 3.3), cf(3.6, 1.45, 3.8), SLATE)
			for k = -1, 1 do
				B:block(foot, v(0.9, 0.8, 0.6), cf(3.6 + k * 1.15, 0.5, 1.8), IVORY)
			end
		end)

		------------------------------------------------------------------
		-- Ground FX (fixed to Root): footfall dust front/back, slam cubes,
		-- a shockwave ring and turf/rock debris (hidden until a stomp)
		------------------------------------------------------------------
		local dustF = B:block("Root", v(10, 0.4, 5), cf(0, 0.2, -2.4), SLATE, { tr = 1, name = "DustFrontFX" })
		B:emitter(dustF, "dust", { name = "DustFront", color = { "#e4dac2", "#b9a888" }, size = { 1.6, 3.2, 4.2 } })
		local dustB = B:block("Root", v(10, 0.4, 5), cf(0, 0.2, 3.8), SLATE, { tr = 1, name = "DustBackFX" })
		B:emitter(dustB, "dust", { name = "DustBack", color = { "#e4dac2", "#b9a888" }, size = { 1.4, 2.8, 3.6 } })
		local slamAt = B:block("Root", v(6, 0.4, 4), cf(0, 0.3, -4.5), SLATE, { tr = 1, name = "SlamFX" })
		B:emitter(slamAt, "burst", {
			name = "SlamCubes", color = { STEEL, MOSS, GOLD }, speed = { 10, 18 }, size = { 0.9, 0.7, 0 },
			spread = 60, accel = { 0, -30, 0 }, life = { 0.7, 1.1 }, light = 0,
		})

		local SC = v(0, 0.35, -3.2)
		for k = 1, 10 do
			local a = (k - 1) / 10 * 360
			local sb = B:bone("Shock" .. k, "Root", SC)
			local at = CFrame.new(SC) * P.ang(0, a, 0) * CFrame.new(0, 0, -3.4)
			B:block(sb, v(2.4, 0.7, 1.3), at, DARK, { tr = 1, name = "Wave" .. k })
			B:block(sb, v(2.0, 0.25, 1.0), at * CFrame.new(0, 0.45, 0), MOSS, { tr = 1, name = "WaveTop" .. k })
		end

		local debris = { { 3.6, -5.6, 1.3, MOSS }, { -3.8, -5.2, 1.1, "#7a5a3a" }, { 1.4, -6.6, 1.0, DARK }, { -1.6, -6.4, 1.2, MOSSD } }
		for i, d in debris do
			local p = v(d[1], 0.6, d[2])
			local db = B:bone("Debris" .. i, "Root", p)
			B:block(db, v(d[3], d[3], d[3]), CFrame.new(p), d[4], { tr = 1, name = "Debris" .. i })
		end

		------------------------------------------------------------------
		-- Floating voxel cubes: armour cubes + mossy cubes
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 8, 1))
		local spots = { { 10, 9.5, -1 }, { -10, 7.5, 3 }, { 10, 6, 9.5 }, { -9.5, 11, -2.5 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			if i % 2 == 1 then
				B:block(ob, v(1.8, 1.8, 1.8), cf(p[1], p[2], p[3]), STEELD)
				B:block(ob, v(1.9, 0.45, 1.9), cf(p[1], p[2] + 0.7, p[3]), STEEL)
				B:block(ob, v(1.88, 0.22, 1.88), cf(p[1], p[2] - 0.15, p[3]), NEON, N)
				B:block(ob, v(0.4, 0.4, 0.4), cf(p[1], p[2] + 1.05, p[3]), GOLD)
			else
				B:block(ob, v(1.5, 1.5, 1.5), cf(p[1], p[2], p[3]), "#7a5a3a")
				B:block(ob, v(1.6, 0.5, 1.6), cf(p[1], p[2] + 0.55, p[3]), MOSS)
				B:block(ob, v(0.7, 0.25, 0.4), cf(p[1] + 0.3, p[2] + 1.0, p[3], 0, 0, 25), LEAF)
			end
		end
	end,
}
