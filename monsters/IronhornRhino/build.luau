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

		------------------------------------------------------------------
		-- HIPS (rear barrel) — pivot at the hind hip joints
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 6.6, 3.6))
		B:block(hips, v(8.0, 5.6, 5.6), cf(0, 7.7, 3.2), SLATE)
		B:block(hips, v(7.0, 0.8, 4.6), cf(0, 4.7, 3.1), BELLY) -- belly underside
		B:block(hips, v(5.4, 0.4, 1.6), cf(0, 4.2, 2.0), STEEL)
		B:block(hips, v(4.6, 0.4, 1.4), cf(0, 4.25, 4.0), BELLY)
		B:block(hips, v(6.8, 4.2, 0.6), cf(0, 7.6, 6.15), DARK) -- rump back panel
		B:block(hips, v(4.4, 1.0, 0.4), cf(0, 9.1, 6.5), SLATE)
		-- rear armour tasset with rivets
		B:block(hips, v(6.4, 1.6, 0.4), cf(0, 9.7, 6.55), STEEL)
		B:block(hips, v(6.6, 0.35, 0.5), cf(0, 8.85, 6.6), IRON)
		B:sym(function()
			rivet(hips, 2.6, 9.9, 6.8, 0.5, 0.5, 0.2)
			rivet(hips, 1.0, 9.9, 6.8, 0.5, 0.5, 0.2)
		end)
		-- rump armour: top plate + side skirts with iron trim and gold rivets
		B:block(hips, v(8.6, 0.6, 5.0), cf(0, 10.75, 3.3), STEEL)
		B:block(hips, v(8.8, 0.4, 0.5), cf(0, 10.9, 5.85), STEELD)
		B:block(hips, v(8.8, 0.4, 0.5), cf(0, 10.9, 0.75), STEELD)
		B:sym(function()
			B:block(hips, v(0.5, 1.8, 5.0), cf(4.3, 9.75, 3.3), STEEL)
			B:block(hips, v(0.6, 0.4, 5.1), cf(4.35, 8.75, 3.3), IRON)
			B:block(hips, v(0.2, 0.25, 2.6), cf(4.6, 10.2, 3.3), NEON, N)
			for _, z in { 1.4, 5.2 } do
				rivet(hips, 4.62, 9.75, z, 0.3, 0.5, 0.5)
				rivet(hips, 3.6, 11.1, z, 0.5, 0.3, 0.5)
			end
			B:block(hips, v(0.4, 3.0, 3.6), cf(4.1, 6.0, 3.4), DARK) -- flank shadow
		end)
		stud(hips, 0, 11.05, 1.9, true)
		stud(hips, 0, 11.05, 4.3)
		-- moss growing over the rump plate
		B:block(hips, v(3.6, 0.5, 2.6), cf(-1.6, 11.25, 4.0), MOSS)
		B:block(hips, v(1.6, 0.4, 1.6), cf(-2.9, 11.2, 2.0), MOSSD)
		B:block(hips, v(2.0, 0.45, 1.4), cf(2.2, 11.2, 4.9), MOSSD)
		B:block(hips, v(0.4, 1.0, 0.8), cf(-4.3, 10.3, 4.2), MOSS) -- moss drip over the edge

		-- little flower sprouting from the rump moss (wobbles)
		local flower = B:bone("SprigB", "Hips", v(-1.8, 11.4, 4.2))
		B:block(flower, v(0.3, 1.2, 0.3), cf(-1.8, 12.0, 4.2), MOSSD)
		B:block(flower, v(0.8, 0.25, 0.4), cf(-1.4, 11.9, 4.2, 0, 0, 25), LEAF)
		B:block(flower, v(0.5, 0.5, 0.5), cf(-1.8, 12.75, 4.2), GOLD)
		for _, o in { { 0.5, 0 }, { -0.5, 0 }, { 0, 0.5 }, { 0, -0.5 } } do
			B:block(flower, v(0.5, 0.45, 0.5), cf(-1.8 + o[1], 12.75, 4.2 + o[2]), PINK)
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
		-- CHEST (front barrel + shoulder armour)
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Hips", v(0, 7.4, 0.8))
		B:block(chest, v(8.8, 6.4, 5.6), cf(0, 7.9, -1.4), SLATE)
		B:block(chest, v(7.6, 0.8, 4.8), cf(0, 4.5, -1.4), BELLY)
		for i, r in { { -3.3, 5.6 }, { -1.6, 6.4 }, { 0.1, 5.6 } } do
			B:block(chest, v(r[2], 0.4, 1.5), cf(0, 4.0 - (i % 2) * 0.1, r[1]), i % 2 == 0 and STEEL or BELLY)
		end
		-- light stepped chest scales under the neck (read from 3/4 + below)
		for i, r in { { 6.4, 4.2 }, { 5.4, 5.2 }, { 4.4, 4.2 } } do
			B:block(chest, v(r[2], 1.0, 0.6), cf(0, r[1], -4.35 - (i % 2) * 0.2), i % 2 == 0 and BELLY or STEELD)
		end
		-- back armour plate over the shoulder hump
		B:block(chest, v(9.2, 0.6, 5.4), cf(0, 11.3, -1.3), STEEL)
		B:block(chest, v(7.0, 0.5, 3.6), cf(0, 11.75, -1.0), STEEL)
		B:block(chest, v(9.4, 0.45, 0.5), cf(0, 11.4, -4.05), STEELD)
		B:block(chest, v(9.4, 0.45, 0.5), cf(0, 11.4, 1.45), STEELD)
		B:sym(function()
			rivet(chest, 3.9, 11.65, -3.4, 0.5, 0.3, 0.5)
			rivet(chest, 3.9, 11.65, 0.8, 0.5, 0.3, 0.5)
			B:block(chest, v(0.4, 3.4, 4.6), cf(4.4, 7.4, -1.2), DARK) -- flank under the pauldron
		end)
		stud(chest, 0, 12.0, -2.6, true)
		stud(chest, 0, 12.0, -0.2)
		-- moss + leaf sprig on the shoulder armour
		B:block(chest, v(3.0, 0.5, 2.4), cf(2.2, 12.05, -1.6), MOSS)
		B:block(chest, v(1.6, 0.45, 1.8), cf(-2.6, 12.0, -0.4), MOSSD)
		B:block(chest, v(1.4, 0.4, 1.2), cf(-3.4, 11.7, -3.2), MOSS)
		local sprig = B:bone("SprigA", "Chest", v(2.4, 12.2, -2.0))
		B:block(sprig, v(0.3, 1.1, 0.3), cf(2.4, 12.7, -2.0), MOSSD)
		B:block(sprig, v(1.1, 0.25, 0.6), cf(2.9, 13.05, -2.0, 0, 0, 28), LEAF)
		B:block(sprig, v(0.9, 0.25, 0.55), cf(1.95, 12.85, -2.0, 0, 0, -28), LEAF)

		local aura = B:block(chest, v(9, 3, 12), cf(0, 12.5, 1), SLATE, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "leaf", { name = "Leaves", color = { LEAF, MOSS }, rate = 1.5, size = { 0.45, 0.45, 0.3 } })
		B:emitter(aura, "sparkle", { name = "Twinkle", color = { "#ffffff", EYE }, rate = 2.5 })

		------------------------------------------------------------------
		-- NECK (thick, with an armoured top plate)
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Chest", v(0, 8.4, -3.6))
		B:block(neck, v(6.6, 5.0, 3.0), cf(0, 8.2, -4.9), SLATE)
		B:block(neck, v(5.2, 0.8, 2.8), cf(0, 5.75, -5.0), BELLY)
		B:block(neck, v(7.0, 0.6, 3.2), cf(0, 10.8, -4.9), STEEL)
		B:block(neck, v(7.2, 0.4, 0.5), cf(0, 10.9, -6.35), STEELD)
		B:sym(function()
			rivet(neck, 2.9, 11.15, -4.9, 0.5, 0.3, 0.5)
			B:block(neck, v(0.4, 2.6, 2.6), cf(3.35, 8.4, -4.9), DARK)
		end)

		------------------------------------------------------------------
		-- HEAD
		------------------------------------------------------------------
		local head = B:bone("Head", "Neck", v(0.0, 7.8, -6.0))
		B:block(head, v(7.36, 4.4, 4.2), cf(0.0, 8.0, -7.6), SLATE) -- cranium
		B:block(head, v(5.75, 0.6, 3.2), cf(0.0, 10.35, -6.9), SLATE) -- crown step
		B:block(head, v(7.475, 0.5, 2.6), cf(0.0, 6.0, -6.9), DARK) -- jowl band
		B:block(head, v(5.75, 2.8, 3.9), cf(0.0, 6.3, -11.15), SLATE) -- snout
		B:block(head, v(4.83, 0.6, 3.4), cf(0.0, 7.95, -11.05), SLATE) -- snout top step
		B:block(head, v(2.99, 0.3, 2.8), cf(0.0, 8.35, -10.9), DARK) -- snout ridge
		B:block(head, v(5.06, 1.6, 0.4), cf(0.0, 6.5, -13.2), DARK) -- nose plate
		B:block(head, v(5.865, 0.5, 3.8), cf(0.0, 5.15, -11.2), DARK) -- upper lip band
		B:block(head, v(5.06, 0.4, 3.8), cf(0.0, 4.75, -11.1), MOUTH) -- mouth roof
		B:block(head, v(4.83, 2.0, 0.4), cf(0.0, 4.6, -9.05), MOUTH) -- throat wall
		-- forehead armour plate (iron lip doubles as the brow ridge)
		B:block(head, v(6.44, 0.6, 3.2), cf(0.0, 10.45, -8.2), STEEL)
		B:block(head, v(6.67, 0.55, 0.45), cf(0.0, 10.35, -9.75), IRON)
		-- second (smaller) horn rising out of the forehead plate
		B:block(head, v(1.725, 0.7, 1.6), cf(0.0, 11.05, -8.4), IVORY)
		B:block(head, v(1.15, 0.6, 1.0), cf(0.0, 11.65, -8.2), STEEL)
		B:block(head, v(0.575, 0.35, 0.5), cf(0.0, 12.1, -8.05), STEELD)
		B:sym(function()
			rivet(head, 2.53, 10.8, -7.1, 0.575, 0.3, 0.5)
			rivet(head, 2.53, 10.8, -9.1, 0.575, 0.3, 0.5)
			-- cheek armour guard with rivets
			B:block(head, v(0.46, 2.0, 3.0), cf(3.852, 7.8, -7.3), STEEL)
			B:block(head, v(0.517, 0.4, 3.1), cf(3.887, 6.65, -7.3), IRON)
			rivet(head, 4.14, 8.3, -6.4, 0.345, 0.45, 0.45)
			rivet(head, 4.14, 8.3, -8.2, 0.345, 0.45, 0.45)
			-- snout side steps (darker) + nostril
			B:block(head, v(0.345, 1.6, 3.2), cf(2.932, 6.4, -11.3), DARK)
			B:block(head, v(0.92, 0.5, 0.2), cf(1.322, 6.85, -13.45), MOUTH)
			-- EYE: dark socket, glowing block wrapped round the cranium corner,
			-- pupil on the front face only (inner side = mean, focused look)
			B:block(head, v(1.7, 1.2, 1.1), cf(2.9, 9.0, -9.3), IRON)
			B:block(head, v(1.3, 0.95, 0.9), cf(3.15, 8.98, -9.45), EYE, { mat = "Neon", name = "Eye" })
			B:block(head, v(0.55, 0.72, 0.1), cf(2.82, 8.92, -9.92), PUPIL)
			-- heavy angry iron brow, inner end down
			B:block(head, v(2.99, 0.8, 1.4), cf(2.415, 9.8, -9.6, 0, 0, 16), STEEL)
			B:block(head, v(1.15, 0.5, 1.2), cf(3.565, 10.35, -9.4, 0, 0, 16), STEELD)
			-- upper teeth (small; the bully tusks are on the jaw)
			for i = 0, 2 do
				B:block(head, v(0.632, 0.6, 0.55), cf(2.012, 4.35, -10.2 - i * 1.15), WHITE)
			end
			B:block(head, v(0.69, 0.65, 0.5), cf(0.632, 4.35, -12.75), WHITE)
		end)

		-- the HUGE front horn: stepped ivory sweeping up/back, iron cap with gold
		-- rivets, hot neon edge strip + tip
		B:block(head, v(3.45, 0.4, 3.2), cf(0.0, 8.35, -11.8), IVORYD) -- root collar
		B:block(head, v(3.22, 1.2, 3.0), cf(0.0, 9.0, -12.0), IVORY)
		B:block(head, v(2.645, 1.1, 2.5), cf(0.0, 10.1, -12.35), IVORY)
		B:block(head, v(2.3, 0.45, 2.2), cf(0.0, 10.75, -12.4), IRON) -- iron cap band
		B:block(head, v(2.185, 1.0, 2.0), cf(0.0, 11.3, -12.4), STEEL)
		B:block(head, v(1.61, 0.8, 1.5), cf(0.0, 12.15, -12.2), STEEL)
		B:block(head, v(1.15, 0.5, 1.0), cf(0.0, 12.75, -11.85), STEELD)
		B:block(head, v(0.345, 0.8, 0.15), cf(0.0, 11.3, -13.45), NEON, N) -- neon edge accent
		B:block(head, v(0.345, 0.6, 0.15), cf(0.0, 12.15, -13.0), NEON, N)
		local hornTip = B:block(head, v(0.632, 0.4, 0.6), cf(0.0, 13.15, -11.6), NEON, { mat = "Neon", name = "HornTip" })
		B:light(hornTip, { name = "HornLight", color = NEON, brightness = 0.5, range = 7 })
		B:sym(function()
			rivet(head, 1.208, 10.75, -12.4, 0.345, 0.3, 0.3)
			rivet(head, 1.115, 11.3, -12.9, 0.23, 0.35, 0.35)
			rivet(head, 0.828, 12.2, -12.6, 0.23, 0.3, 0.3)
		end)
		B:trail(head, v(0.0, 13.25, -11.6), v(0.0, 12.0, -12.7), { name = "HornTrail", color = { NEON, "#ffffff" }, life = 0.2, trans = { 0.35, 1 } })
		local hornFX = B:block(head, v(1.38, 1.2, 1.2), cf(0.0, 13.0, -12.0), SLATE, { tr = 1, name = "HornFX" })
		B:emitter(hornFX, "burst", { name = "HornBurst", color = { "#ffffff", NEON, GOLD }, speed = { 7, 14 }, size = { 0.6, 0.4, 0 } })

		-- nostril steam (forward + a little down) and head steam (anger)
		local nostrils = B:block(head, v(2.99, 0.5, 0.4), cf(0.0, 6.7, -13.6, -25, 0, 0), SLATE, { tr = 1, name = "NostrilFX" })
		B:emitter(nostrils, "smoke", {
			name = "Steam", rate = 0, color = { "#ffffff", "#d9e2ee" }, life = { 0.45, 0.9 }, speed = { 5, 9 },
			size = { 0.5, 1.5, 2.2 }, trans = { 0.15, 0.45, 1 }, spread = 18, accel = { 0, 3, 0 }, drag = 3, dir = "Front",
		})
		local headSteam = B:block(head, v(6.9, 0.4, 2.0), cf(0.0, 11.0, -6.4), SLATE, { tr = 1, name = "HeadSteamFX" })
		B:emitter(headSteam, "smoke", {
			name = "HeadSteam", rate = 0, color = { "#ffffff", "#e6ecf4" }, life = { 0.6, 1.1 }, speed = { 5, 9 },
			size = { 0.6, 1.6, 2.4 }, trans = { 0.15, 0.5, 1 }, spread = 25, accel = { 0, 2, 0 }, drag = 2,
		})

		-- eyelids (props: shown only while blinking / squinting)
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(3.162, 9.9, -9.45))
			B:block(lid, v(1.42, 1.05, 1.1), cf(3.15, 9.95, -9.45), SLATE, { tr = 1, name = "Eyelid" .. side })
		end)

		-- ears stick out sideways (pin back when angry)
		B:sym(function(side)
			local ear = B:bone("Ear" .. side, "Head", v(3.45, 9.8, -6.3))
			B:block(ear, v(1.61, 1.0, 1.0), cf(4.025, 10.0, -6.3, 0, 0, 20), SLATE)
			B:block(ear, v(1.38, 0.9, 0.8), cf(5.175, 10.45, -6.3, 0, 0, 20), SLATE)
			B:block(ear, v(1.84, 0.6, 0.2), cf(4.6, 10.25, -6.85, 0, 0, 20), PINK)
			B:block(ear, v(0.575, 0.5, 0.7), cf(5.865, 10.85, -6.3, 0, 0, 20), DARK)
		end)

		-- anger mark (prop) floating at the top corner of the head
		local anger = B:bone("Anger", "Head", v(3.91, 12.0, -8.2))
		local ac = "#ff2d2d"
		for i, o in { { -0.45, 0.2, 0.9, 0.3 }, { 0.45, 0.2, 0.9, 0.3 }, { 0, 0.65, 0.3, 0.9 }, { 0, -0.25, 0.3, 0.9 } } do
			local a = cf(3.91, 12.0, -8.2, 0, -30, 0) * CFrame.new(o[1], o[2] - 0.2, 0)
			B:block(anger, v(o[3], o[4], 0.3), a, ac, { tr = 1, name = "Anger" .. i })
		end

		-- JAW: underbite with bully tusks
		local jaw = B:bone("Jaw", "Head", v(0.0, 5.0, -8.9))
		B:block(jaw, v(5.52, 1.1, 4.7), cf(0.0, 4.1, -11.2), BELLY)
		B:block(jaw, v(4.83, 0.45, 4.2), cf(0.0, 3.4, -11.0), DARK)
		B:block(jaw, v(4.83, 0.3, 4.2), cf(0.0, 4.7, -11.1), MOUTH)
		B:block(jaw, v(2.76, 0.3, 2.6), cf(0.0, 4.85, -10.8), TONGUE)
		B:block(jaw, v(4.6, 1.4, 0.5), cf(0.0, 5.0, -9.25), MOUTH) -- back of the mouth
		B:block(jaw, v(3.91, 0.5, 0.4), cf(0.0, 3.8, -13.65), STEEL) -- chin guard
		B:sym(function()
			B:block(jaw, v(0.862, 1.5, 0.75), cf(2.012, 5.25, -13.15), WHITE) -- tusk
			B:block(jaw, v(0.575, 0.5, 0.5), cf(2.012, 6.15, -13.15), IVORYD)
			B:block(jaw, v(0.575, 0.55, 0.5), cf(0.69, 5.05, -13.15), WHITE)
			B:block(jaw, v(0.575, 0.5, 0.5), cf(2.127, 5.0, -11.6), WHITE)
			rivet(jaw, 1.438, 3.8, -13.9, 0.402, 0.3, 0.15)
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
