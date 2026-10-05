--!nocheck
-- Abyssal Mosasaurus: a stud-built sea reptile that "swims" through the air.
-- Navy-blue voxel body with a pale lavender-blue belly, a BIG cartoon
-- crocodilian head full of white block teeth, a coral-red mouth, big red slit
-- eyes on top of the skull under heavy angry brows, two bold lavender horns,
-- a few big stepped dorsal fins (AtomicKaiju plate idiom), four chunky
-- paddle flippers and a stepped crescent tail fluke with lavender edges.
-- Small electric-cyan neon accents only (horn/spine/fluke tips, gill dots,
-- thin edge strips, eye glints).
return {
	DisplayName = "Abyssal Mosasaurus",
	Rarity = "Mythic",
	Element = "Ocean",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local MAIN, DARK, BELLY, LAV = "#3a5aa8", "#233a73", "#b9c3ee", "#d4ccff"
		local WHITE, MOUTH, THROAT, TONGUE = "#f7f8ff", "#e0475b", "#1a1226", "#ff8a9c"
		local EYE, SLIT, CYAN = "#e8102a", "#0b0a12", "#38c8ff"
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- helpers
		------------------------------------------------------------------
		-- one body segment: navy core, dark top ridge, pale belly band that wraps
		-- the lower sides, a lavender keel and dark side spots
		local function segment(bone, z0, z1, yc, w, h, spots, noKeel)
			local len = z1 - z0
			local zc = (z0 + z1) / 2
			B:block(bone, v(w, h, len), cf(0, yc, zc), MAIN)
			B:block(bone, v(w * 0.56, 0.5, len - 0.5), cf(0, yc + h / 2 + 0.2, zc), DARK)
			local bh = h * 0.46
			B:block(bone, v(w + 0.1, bh, len - 0.3), cf(0, yc - h / 2 + bh / 2 - 0.25, zc), BELLY)
			B:block(bone, v(w + 0.16, 0.3, len - 0.4), cf(0, yc - h / 2 + bh - 0.25, zc), DARK)
			if not noKeel then
				B:block(bone, v(w * 0.6, 0.5, len - 0.9), cf(0, yc - h / 2 - 0.45, zc), LAV)
			end
			for _, s in spots or {} do
				-- s = {z offset, y offset, length}: one block shows a dark square on both sides
				B:block(bone, v(w + 0.08, 0.9, s[3] or 1.0), cf(0, yc + s[2], zc + s[1]), DARK)
			end
		end

		-- bold voxel dorsal fin (AtomicKaiju plate idiom): a DARK base step, then
		-- lavender steps that shrink and lean back, capped by a small neon tip.
		-- y = top surface under the fin, z = center of the base
		local function plate(bone, y, z, steps, d0, tip)
			local d, zo = d0, 0
			for i = 0, steps - 1 do
				B:block(bone, v(i == 0 and 1.0 or 0.8, 1, math.max(0.6, d)), cf(0, y + i + 0.5, z + zo), i == 0 and DARK or LAV)
				if i < steps - 1 then
					d *= 0.7
					zo += 0.5
				end
			end
			if tip then
				B:block(bone, v(0.6, 0.6, 0.6), cf(0, y + steps + 0.25, z + zo + 0.3), CYAN, NEON)
			else
				B:wedge(bone, v(0.6, 0.8, math.max(0.9, d)), cf(0, y + steps + 0.35, z + zo + 0.1), LAV)
			end
		end

		------------------------------------------------------------------
		-- BODY (Body2 is the swimmer's center; the chain runs both ways)
		------------------------------------------------------------------
		local body2 = B:bone("Body2", "Root", v(0, 6.5, 2.0))
		segment(body2, -0.6, 3.8, 6.6, 6.0, 5.8, { { -1.0, 1.2, 1.2 }, { 1.2, 1.9, 1.0 } })
		plate(body2, 9.9, 0.6, 5, 3.6, true) -- tallest fin
		B:block(body2, v(2.8, 0.5, 1.4), cf(0, 2.95, 0.3), BELLY)
		B:block(body2, v(2.8, 0.5, 1.2), cf(0, 2.95, 2.5), LAV)
		local bubbleVol = B:block(body2, v(10, 7, 25), cf(0, 7.5, 1.0), MAIN, { tr = 1, name = "BubbleVolume" })
		B:emitter(bubbleVol, "bubble", { name = "AmbientBubbles", color = { "#ffffff", "#9fe2ff" }, rate = 5, size = { 0.2, 0.4, 0.5 } })
		B:emitter(bubbleVol, "sparkle", { name = "AmbientSparkle", color = { "#ffffff", CYAN }, rate = 3 })

		-- Body1 = the CHEST: biggest, deepest segment with stepped belly plates
		local body1 = B:bone("Body1", "Body2", v(0, 6.6, -0.2))
		segment(body1, -4.6, 0.6, 6.5, 6.4, 6.2, { { 0.6, 1.6, 1.2 } }, true)
		plate(body1, 10.0, -2.8, 4, 3.4, true)
		-- stepped chest scales under the chest (alternating lavender / belly)
		local rows = { { -3.6, 4.2, LAV }, { -2.2, 4.8, BELLY }, { -0.8, 4.2, LAV } }
		for i, r in rows do
			B:block(body1, v(r[2], 0.8, 1.3), cf(0, 3.15 - (i == 2 and 0.15 or 0), r[1]), r[3])
		end
		B:block(body1, v(3.0, 0.6, 2.6), cf(0, 2.6, -2.2), LAV) -- keel step
		B:sym(function()
			B:block(body1, v(0.2, 0.3, 2.6), cf(3.22, 7.6, -2.0), CYAN, NEON)
		end)

		local body3 = B:bone("Body3", "Body2", v(0, 6.5, 3.4))
		segment(body3, 2.6, 7.2, 6.7, 5.0, 4.8, { { 0.6, 1.2, 1.2 } })
		B:block(body3, v(5.3, 5.1, 0.6), cf(0, 6.7, 4.1), DARK) -- joint collar
		plate(body3, 9.55, 4.6, 3, 3.0, true)
		B:sym(function()
			B:block(body3, v(0.2, 0.3, 2.2), cf(2.52, 7.3, 5.6), CYAN, NEON)
		end)

		------------------------------------------------------------------
		-- TAIL chain: Tail1..Tail4 taper into the crescent fluke; a dark collar
		-- band at each joint breaks the length into readable chunks
		------------------------------------------------------------------
		local tails = {
			-- pivot z, z0, z1, yc, w, h, fin steps, fin depth, collar z
			{ 6.6, 6.1, 9.3, 6.8, 4.2, 4.0, 3, 2.6, 7.5 },
			{ 9.0, 8.6, 11.4, 6.9, 3.4, 3.2, 2, 2.0, 9.6 },
			{ 11.1, 10.7, 13.2, 7.0, 2.6, 2.5, 0, 0, 11.7 },
			{ 12.9, 12.5, 14.8, 7.1, 1.9, 1.9, 0, 0, 13.5 },
		}
		local parent = "Body3"
		for i, s in tails do
			local name = "Tail" .. i
			local b = B:bone(name, parent, v(0, s[4] - 0.1, s[1]))
			segment(b, s[2], s[3], s[4], s[5], s[6], i <= 2 and { { 0.4, s[6] * 0.24, 0.9 } } or nil)
			B:block(b, v(s[5] + 0.3, s[6] + 0.3, 0.6), cf(0, s[4], s[9]), DARK)
			local top = s[4] + s[6] / 2 + 0.45
			if s[7] > 0 then
				plate(b, top - 0.05, s[1] + 1.1, s[7], s[8], i == 1)
			else
				B:wedge(b, v(0.6, 1.1, 1.4), cf(0, top + 0.5, s[1] + 1.0), LAV)
			end
			parent = name
		end

		-- big crescent fluke: pixel-art rows of studded blocks sweeping back,
		-- each row with a lavender leading edge (stepped lavender edge like the
		-- Leviathan's wing bones)
		local FZ, FY = 14.4, 7.1
		local fluke = B:bone("Fluke", "Tail4", v(0, FY, FZ))
		local function fb(sx, sy, sz, z, y, col, opts)
			return B:block(fluke, v(sx, sy, sz), cf(0, FY + y, FZ + z), col, opts)
		end
		local function row(y, z0, z1, th, col)
			fb(th, 1.05, z1 - z0, (z0 + z1) / 2, y, col)
			fb(th + 0.1, 1.0, 0.8, z0 + 0.2, y, LAV)
		end
		fb(1.6, 2.2, 2.6, 1.1, 0, MAIN)       -- core
		row(1.55, 0.5, 3.3, 1.35, MAIN)       -- upper lobe
		row(2.55, 1.4, 4.1, 1.2, MAIN)
		row(3.55, 2.4, 4.8, 1.05, MAIN)
		row(4.55, 3.4, 5.4, 0.95, DARK)
		row(5.55, 4.4, 5.9, 0.85, DARK)
		fb(0.7, 0.7, 0.7, 5.75, 6.35, CYAN, NEON)
		row(-1.55, 0.5, 3.1, 1.35, MAIN)      -- lower lobe
		row(-2.55, 1.3, 3.7, 1.15, MAIN)
		row(-3.55, 2.2, 4.2, 0.95, DARK)
		row(-4.55, 3.0, 4.6, 0.85, DARK)
		fb(0.7, 0.7, 0.7, 4.55, -5.2, CYAN, NEON)
		fb(0.2, 0.25, 1.9, 4.75, 3.0, CYAN, NEON) -- trailing edge strips
		fb(0.2, 0.25, 1.5, 4.25, -3.0, CYAN, NEON)
		B:trail(fluke, v(0, FY + 6.4, FZ + 5.9), v(0, FY + 4.8, FZ + 5.0), { name = "FlukeTrailTop", color = { "#ffffff", CYAN }, life = 0.3, trans = { 0.45, 1 } })
		B:trail(fluke, v(0, FY - 5.2, FZ + 4.7), v(0, FY - 3.8, FZ + 4.2), { name = "FlukeTrailBot", color = { "#ffffff", CYAN }, life = 0.3, trans = { 0.45, 1 } })
		local wake = fb(1.5, 3, 2, 2, 0, MAIN, { tr = 1, name = "WakeFX" })
		B:emitter(wake, "burst", { name = "WakeBurst", color = { "#ffffff", "#9fe2ff", LAV }, size = { 0.7, 0.5, 0 }, speed = { 4, 10 } })

		------------------------------------------------------------------
		-- NECK (pinched so the big head and chest bracket it)
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Body1", v(0, 6.9, -4.2))
		segment(neck, -7.4, -3.6, 7.4, 4.2, 4.0)
		plate(neck, 9.8, -5.8, 2, 2.4, false)
		B:sym(function()
			for i = 0, 2 do
				B:block(neck, v(0.2, 0.5, 0.5), cf(2.13, 8.3 - i * 0.35, -4.6 - i * 0.8), CYAN, NEON)
			end
		end)

		------------------------------------------------------------------
		-- HEAD: big cartoon crocodilian skull with eye bumps on top
		------------------------------------------------------------------
		local head = B:bone("Head", "Neck", v(0, 7.3, -7.0))
		B:block(head, v(4.8, 4.2, 2.0), cf(0, 7.5, -6.6), MAIN) -- collar (hides the neck joint)
		B:block(head, v(7.0, 4.2, 5.0), cf(0, 8.8, -9.3), MAIN) -- cranium
		B:block(head, v(3.4, 0.5, 4.0), cf(0, 11.1, -9.1), DARK)
		B:block(head, v(5.6, 3.0, 3.8), cf(0, 8.2, -13.6), MAIN) -- snout
		B:block(head, v(3.0, 0.4, 3.6), cf(0, 9.85, -13.6), DARK)
		B:block(head, v(4.6, 2.6, 2.2), cf(0, 8.0, -16.5), MAIN) -- nose
		B:block(head, v(3.2, 0.5, 2.0), cf(0, 9.45, -16.5), DARK)
		-- pale upper lip band (two-tone head)
		B:block(head, v(7.1, 0.9, 4.8), cf(0, 7.15, -9.3), BELLY)
		B:block(head, v(5.7, 0.9, 3.6), cf(0, 7.15, -13.6), BELLY)
		B:block(head, v(4.7, 0.9, 2.0), cf(0, 7.15, -16.5), BELLY)
		-- mouth: coral palate, black throat
		B:block(head, v(6.0, 0.3, 4.6), cf(0, 6.6, -9.3), MOUTH)
		B:block(head, v(4.2, 0.3, 6.2), cf(0, 6.6, -14.6), MOUTH)
		B:block(head, v(4.8, 2.0, 0.5), cf(0, 5.9, -7.3), THROAT)
		-- head crest: one small stepped fin between the eye bumps
		plate(head, 11.3, -8.6, 2, 2.2, false)
		local mouthFx = B:block(head, v(2.6, 1.6, 1.6), cf(0, 6.8, -18.3), MAIN, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFx, "burst", { name = "SnapBurst", color = { "#ffffff", CYAN } })
		B:emitter(mouthFx, "burst", { name = "BubbleBurst", color = { "#ffffff", "#9fe2ff" }, size = { 0.5, 0.8, 0.2 }, speed = { 5, 11 }, life = { 0.6, 1.2 } })
		local thrashFx = B:block(head, v(7, 5, 10), cf(0, 8.0, -13.0), MAIN, { tr = 1, name = "ThrashFX" })
		B:emitter(thrashFx, "bubble", { name = "ThrashBubbles", color = { "#ffffff", "#9fe2ff" }, rate = 45, enabled = false, size = { 0.3, 0.6, 0.7 }, speed = { 2, 6 }, spread = 120 })
		B:light(mouthFx, { name = "MouthLight", color = CYAN, brightness = 0.01, range = 14 })
		B:trail(head, v(0, 9.3, -17.9), v(0, 6.4, -17.9), { name = "SnoutTrail", color = { "#ffffff", CYAN }, life = 0.22, trans = { 0.55, 1 } })
		-- cartoon CHOMP impact lines (hidden, flashed on the bite)
		for i = 1, 8 do
			local a = (i - 1) / 8 * 360 + 22.5
			B:block(head, v(0.35, 0.35, 1.6), CFrame.new(0, 7.2, -19.3) * ang(0, 0, a) * CFrame.new(0, 3.6, 0) * ang(90, 0, 0), "#e8fbff", { mat = "Neon", tr = 1, name = "SnapLine" .. i })
		end

		B:sym(function(side)
			-- nostril
			B:block(head, v(0.6, 0.15, 0.7), cf(0.8, 9.75, -16.9), THROAT)
			-- upper teeth: rows of big white blocks hanging from the jaw line
			local up = {
				{ 3.0, -8.0, false }, { 3.0, -9.2, true }, { 3.0, -10.4, false },
				{ 2.45, -11.9, true }, { 2.45, -13.1, false }, { 2.45, -14.4, true },
				{ 1.95, -15.8, false },
			}
			for _, t in up do
				local s = t[3] and v(0.65, 1.3, 0.65) or v(0.5, 0.9, 0.5)
				B:block(head, s, cf(t[1], 6.85 - s.Y / 2, t[2]), WHITE)
			end
			B:block(head, v(0.7, 1.5, 0.7), cf(0.9, 6.15, -17.2), WHITE) -- buck fang
			-- eye bump on top of the skull (crocodile style); the BIG eye wraps
			-- the outer-front corner so it reads from the side AND the front
			B:block(head, v(2.4, 2.0, 2.8), cf(2.2, 11.7, -9.8), MAIN)
			B:block(head, v(1.6, 1.7, 2.1), cf(2.95, 11.3, -10.4), EYE, { mat = "Neon", name = "Eye" .. side })
			-- big black slit pupil wrapping the outer-front corner (looks forward)
			B:block(head, v(0.5, 1.45, 0.5), cf(3.52, 11.25, -11.27), SLIT)
			-- white glints so the eye pops
			B:block(head, v(0.45, 0.45, 0.1), cf(2.6, 11.75, -11.47), WHITE, NEON)
			B:block(head, v(0.1, 0.4, 0.4), cf(3.77, 11.75, -10.55), WHITE, NEON)
			-- heavy angry brow overhanging the eye (inner end low)
			B:block(head, v(2.8, 0.9, 3.2), cf(2.3, 12.7, -10.35, -10, 0, 14), DARK)
			-- dark cheek panel + snout stripe (color blocking on the big flat sides)
			B:block(head, v(0.14, 1.6, 3.0), cf(3.53, 8.8, -8.5), DARK)
			B:block(head, v(0.14, 0.5, 3.2), cf(2.83, 9.05, -13.6), DARK)
			-- bold lavender horns: 2 long collinear bars + a glowing tip
			local h0, h1 = v(2.0, 11.0, -8.0), v(3.4, 14.0, -5.9)
			local dir = (h1 - h0).Unit
			B:beam(head, h0, h1, 1.5, 1.5, LAV)
			local h2 = h1 - dir * 0.45
			local h3 = h2 + dir * 2.4
			B:beam(head, h2, h3, 1.05, 1.05, LAV)
			B:beam(head, h3 - dir * 0.15, h3 + dir * 0.6, 0.7, 0.7, CYAN, NEON)
			-- cheek frill spikes
			B:spike(head, v(3.3, 8.3, -8.0), v(5.1, 7.6, -5.4), 1.2, 1.2, LAV)
			B:spike(head, v(3.2, 9.8, -7.6), v(4.6, 10.3, -5.4), 0.9, 0.9, LAV)
		end)

		-- eyelids for cartoon blinks / angry squint (hidden until they close)
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(2.95, 13.0, -10.4))
			B:block(lid, v(1.85, 1.9, 2.3), cf(2.95, 13.0, -10.4), MAIN, { tr = 1, name = "Eyelid" .. side })
		end)

		------------------------------------------------------------------
		-- JAW (hinged at the back of the mouth)
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", v(0, 6.8, -7.5))
		B:block(jaw, v(6.0, 1.3, 4.6), cf(0, 6.05, -9.3), MAIN)
		B:block(jaw, v(4.4, 1.1, 6.4), cf(0, 6.15, -14.6), MAIN)
		B:block(jaw, v(6.1, 0.9, 4.4), cf(0, 5.2, -9.2), BELLY)
		B:block(jaw, v(4.5, 0.8, 6.2), cf(0, 5.4, -14.5), BELLY)
		B:block(jaw, v(3.4, 0.4, 3.4), cf(0, 4.6, -9.4), LAV)
		B:block(jaw, v(5.2, 0.2, 4.2), cf(0, 6.75, -9.3), MOUTH)
		B:block(jaw, v(3.6, 0.2, 6.0), cf(0, 6.75, -14.6), MOUTH)
		B:block(jaw, v(2.4, 0.4, 5.0), cf(0, 6.9, -11.0), TONGUE)
		B:sym(function()
			local low = {
				{ 2.6, -8.6, true }, { 2.6, -9.8, false }, { 2.6, -11.0, true },
				{ 1.85, -12.4, false }, { 1.85, -13.6, true }, { 1.85, -14.8, false },
				{ 1.85, -16.0, true },
			}
			for _, t in low do
				local s = t[3] and v(0.6, 1.2, 0.6) or v(0.5, 0.8, 0.5)
				B:block(jaw, s, cf(t[1], 6.65 + s.Y / 2, t[2]), WHITE)
			end
			B:block(jaw, v(0.65, 1.4, 0.65), cf(1.45, 7.3, -17.3), WHITE)
		end)

		------------------------------------------------------------------
		-- FLIPPERS: 4 chunky paddles, 2 bones each (shoulder + paddle)
		------------------------------------------------------------------
		local function flipper(prefix, parentBone, pivot, yaw, droop, sc)
			B:sym(function(side)
				local F = CFrame.new(pivot) * ang(0, yaw, droop)
				local function at(x, y, z)
					return F * CFrame.new(x * sc, y * sc, z * sc)
				end
				local arm = B:bone(prefix .. "Fin" .. side, parentBone, F)
				B:block(arm, v(2.6, 1.6, 2.2) * sc, at(1.0, 0, 0), MAIN)
				B:block(arm, v(1.4, 0.3, 1.6) * sc, at(1.3, 0.85, 0.1), DARK)
				local tip = B:bone(prefix .. "Tip" .. side, prefix .. "Fin" .. side, at(2.2, 0, 0))
				B:block(tip, v(2.4, 1.0, 3.0) * sc, at(3.4, 0, 0.3), MAIN)
				B:block(tip, v(2.0, 1.0, 2.6) * sc, at(5.4, 0, 0.7), MAIN)
				B:block(tip, v(1.4, 0.9, 1.8) * sc, at(7.0, 0, 1.2), DARK)
				B:block(tip, v(2.4, 1.1, 0.6) * sc, at(3.4, 0, -1.45), LAV)
				B:block(tip, v(2.0, 1.05, 0.6) * sc, at(5.4, 0, -0.85), LAV)
				B:block(tip, v(1.0, 0.95, 0.6) * sc, at(7.0, 0, 0.05), LAV)
				B:block(tip, v(3.4, 0.12, 0.35) * sc, at(4.4, 0.55, 0.0), BELLY)
				B:block(tip, v(3.0, 0.12, 0.35) * sc, at(4.6, 0.55, 1.0), BELLY)
				B:block(tip, v(3.6, 0.25, 0.25) * sc, at(4.6, 0.25, 2.0), CYAN, NEON)
				local a, b = at(7.6, 0, 1.6), at(6.4, 0, 2.1)
				B:trail(tip, a.Position, b.Position, { name = prefix .. "FinTrail" .. side, color = { "#ffffff", CYAN }, life = 0.25, trans = { 0.55, 1 } })
			end)
		end
		flipper("Front", "Body1", v(2.6, 5.2, -2.4), -16, -6, 1.0)
		flipper("Rear", "Body3", v(2.2, 5.4, 4.9), -26, -8, 0.8)

		------------------------------------------------------------------
		-- Floating voxel cubes (VFX) that bob and tumble around the swimmer:
		-- two-tone cube + lavender cap + thin cyan band
		------------------------------------------------------------------
		local orbs = {
			{ 8.8, 11.5, -5.0, 2.2, MAIN },
			{ -9.0, 9.0, 0.0, 1.8, DARK },
			{ 8.2, 7.2, 8.7, 1.2, MAIN },
			{ -7.8, 12.6, 8.7, 2.2, DARK },
			{ -3.8, 17.2, 3.0, 1.2, MAIN },
		}
		for i, o in orbs do
			local ob = B:bone("Orb" .. i, "Root", v(o[1], o[2], o[3]))
			local s = o[4]
			B:block(ob, v(s, s, s), cf(o[1], o[2], o[3]), o[5])
			B:block(ob, v(s + 0.1, s * 0.3, s + 0.1), cf(o[1], o[2] + s * 0.36, o[3]), LAV)
			B:block(ob, v(s + 0.16, s * 0.16, s + 0.16), cf(o[1], o[2] - s * 0.08, o[3]), CYAN, NEON)
		end

		------------------------------------------------------------------
		-- CHOMP chunks: voxel cubes (hidden) that pop out of the mouth on the
		-- snap. Carried by Body2 so they travel with the lunge.
		------------------------------------------------------------------
		local CH = v(0, 7.0, -18.8)
		local chunkCol = { LAV, WHITE, CYAN, LAV, BELLY, WHITE, CYAN, LAV }
		for k = 1, 8 do
			local cb = B:bone("Chunk" .. k, "Body2", CH)
			local s = (k % 3 == 0) and 0.6 or 0.9
			B:block(cb, v(s, s, s), CFrame.new(CH), chunkCol[k], { mat = chunkCol[k] == CYAN and "Neon" or nil, tr = 1, name = "ChunkPart" .. k })
		end
	end,
}
