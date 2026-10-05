--!nocheck
-- Abyssal Mosasaurus: a stud-built sea reptile that "swims" through the air.
-- Navy-blue voxel body with a pale lavender-blue belly, a huge crocodilian
-- snout full of white block teeth, a coral-red mouth, red slit eyes on top
-- of the head under heavy brows, swept-back lavender horns, jagged stepped
-- dorsal spines, four paddle flippers and a stepped crescent tail fluke.
-- Small electric-cyan neon accents only (horn/spine/fluke tips, gill dots,
-- fin edge strips).
return {
	DisplayName = "Abyssal Mosasaurus",
	Rarity = "Mythic",
	Element = "Ocean",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local MAIN, DARK, BELLY, LAV = "#3a5aa8", "#233a73", "#b9c3ee", "#d4ccff"
		local WHITE, MOUTH, THROAT, TONGUE = "#f7f8ff", "#e0475b", "#1a1226", "#ff8a9c"
		local EYE, SLIT, CYAN = "#ff2b3d", "#0b0a12", "#38c8ff"
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- helpers
		------------------------------------------------------------------
		-- one body segment: navy core, dark top ridge, pale belly band that wraps
		-- the lower sides, a stepped lavender belly plate and dark side spots
		local function segment(bone, z0, z1, yc, w, h, spots)
			local len = z1 - z0
			local zc = (z0 + z1) / 2
			B:block(bone, v(w, h, len), cf(0, yc, zc), MAIN)
			B:block(bone, v(w * 0.56, 0.5, len - 0.5), cf(0, yc + h / 2 + 0.2, zc), DARK)
			local bh = h * 0.46
			B:block(bone, v(w + 0.1, bh, len - 0.3), cf(0, yc - h / 2 + bh / 2 - 0.25, zc), BELLY)
			B:block(bone, v(w + 0.16, 0.3, len - 0.4), cf(0, yc - h / 2 + bh - 0.25, zc), DARK)
			B:block(bone, v(w * 0.6, 0.5, len - 0.9), cf(0, yc - h / 2 - 0.45, zc), LAV)
			for _, s in spots or {} do
				-- s = {z offset, y offset, length}: one block shows a dark square on both sides
				B:block(bone, v(w + 0.08, 0.9, s[3] or 1.0), cf(0, yc + s[2], zc + s[1]), DARK)
			end
		end

		-- jagged stepped dorsal spine: a tall narrow stack of studded blocks that
		-- narrows and leans back, ending in a small neon cube or a lavender
		-- sawtooth wedge. y = top surface under the spine, z = center of the base
		local function spine(bone, z, y, steps, len, neonTip)
			local hgt = 1.0
			for i = 0, steps - 1 do
				local k = i / steps
				local d = math.max(0.6, len * (1 - 0.6 * k))
				local wx = math.max(0.6, 1.1 - 0.12 * i)
				B:block(bone, v(wx, hgt, d), cf(0, y + hgt * (i + 0.5) - 0.12, z + 0.32 * i), i == 0 and DARK or LAV)
			end
			local top = y + hgt * steps - 0.12
			local zt = z + 0.32 * steps
			if neonTip then
				B:block(bone, v(0.55, 0.55, 0.55), cf(0, top + 0.2, zt), CYAN, NEON)
			else
				local d = math.max(0.8, len * 0.55)
				B:wedge(bone, v(0.6, 0.9, d), cf(0, top + 0.4, zt - 0.1), LAV)
			end
		end

		------------------------------------------------------------------
		-- BODY (Body2 is the swimmer's center; the chain runs both ways)
		------------------------------------------------------------------
		local body2 = B:bone("Body2", "Root", v(0, 6.5, 2.0))
		segment(body2, -0.6, 3.8, 6.6, 5.8, 5.6, { { -1.0, 1.2, 1.2 }, { 1.2, 1.9, 1.0 } })
		spine(body2, 0.5, 9.65, 5, 1.7, true)
		spine(body2, 1.9, 9.65, 2, 1.2, false)
		spine(body2, 3.2, 9.65, 4, 1.6, true)
		B:block(body2, v(2.6, 0.5, 1.4), cf(0, 2.95, 0.3), BELLY)
		B:block(body2, v(2.6, 0.5, 1.2), cf(0, 2.95, 2.5), LAV)
		local bubbleVol = B:block(body2, v(10, 7, 25), cf(0, 7.5, 1.0), MAIN, { tr = 1, name = "BubbleVolume" })
		B:emitter(bubbleVol, "bubble", { name = "AmbientBubbles", color = { "#ffffff", "#9fe2ff" }, rate = 5, size = { 0.2, 0.4, 0.5 } })
		B:emitter(bubbleVol, "sparkle", { name = "AmbientSparkle", color = { "#ffffff", CYAN }, rate = 3 })

		local body1 = B:bone("Body1", "Body2", v(0, 6.6, -0.2))
		segment(body1, -4.6, 0.6, 6.8, 5.4, 5.2, { { 0.4, 1.5, 1.2 } })
		spine(body1, -2.6, 9.65, 4, 1.6, true)
		spine(body1, -0.9, 9.65, 2, 1.2, false)
		B:block(body1, v(2.4, 0.5, 1.4), cf(0, 3.45, -3.0), BELLY)
		B:block(body1, v(2.4, 0.5, 1.2), cf(0, 3.45, -0.8), LAV)
		B:sym(function()
			B:block(body1, v(0.2, 0.3, 2.6), cf(2.72, 7.4, -2.0), CYAN, NEON)
		end)

		local body3 = B:bone("Body3", "Body2", v(0, 6.5, 3.4))
		segment(body3, 2.6, 7.2, 6.7, 5.0, 4.8, { { 0.6, 1.2, 1.2 } })
		spine(body3, 4.8, 9.35, 4, 1.6, true)
		spine(body3, 6.4, 9.35, 2, 1.1, false)
		B:sym(function()
			B:block(body3, v(0.2, 0.3, 2.2), cf(2.52, 7.3, 5.0), CYAN, NEON)
		end)

		------------------------------------------------------------------
		-- TAIL chain: Tail1..Tail4 taper into the crescent fluke
		------------------------------------------------------------------
		local tails = {
			-- pivot z, z0, z1, yc, w, h, spine steps, spine len
			{ 6.6, 6.1, 9.3, 6.8, 4.2, 4.0, 3, 1.4 },
			{ 9.0, 8.6, 11.4, 6.9, 3.4, 3.2, 2, 1.2 },
			{ 11.1, 10.7, 13.2, 7.0, 2.6, 2.5, 1, 1.1 },
			{ 12.9, 12.5, 14.8, 7.1, 1.9, 1.9, 0, 1.1 },
		}
		local parent = "Body3"
		for i, s in tails do
			local name = "Tail" .. i
			local b = B:bone(name, parent, v(0, s[4] - 0.1, s[1]))
			segment(b, s[2], s[3], s[4], s[5], s[6], i <= 2 and { { 0.2, s[6] * 0.24, 0.9 } } or nil)
			local top = s[4] + s[6] / 2 + 0.45
			if s[7] > 0 then
				spine(b, s[1] + (s[3] - s[2]) * 0.35, top, s[7], s[8], false)
			else
				B:wedge(b, v(0.6, 1.0, 1.2), cf(0, top + 0.45, s[1] + 1.1), LAV)
			end
			parent = name
		end

		-- big crescent fluke: pixel-art rows of studded blocks sweeping back
		local FZ, FY = 14.4, 7.1
		local fluke = B:bone("Fluke", "Tail4", v(0, FY, FZ))
		local function fb(sx, sy, sz, z, y, col, opts)
			return B:block(fluke, v(sx, sy, sz), cf(0, FY + y, FZ + z), col, opts)
		end
		local function row(y, z0, z1, th, col)
			return fb(th, 1.05, z1 - z0, (z0 + z1) / 2, y, col)
		end
		fb(1.6, 2.2, 2.6, 1.1, 0, MAIN)       -- core
		row(1.55, 0.5, 3.3, 1.35, MAIN)       -- upper lobe
		row(2.55, 1.4, 4.1, 1.2, MAIN)
		row(3.55, 2.4, 4.8, 1.05, MAIN)
		row(4.55, 3.4, 5.4, 0.95, DARK)
		row(5.55, 4.4, 5.9, 0.85, DARK)
		fb(0.6, 0.6, 0.6, 5.6, 6.3, CYAN, NEON)
		row(-1.55, 0.5, 3.1, 1.35, MAIN)      -- lower lobe
		row(-2.55, 1.3, 3.7, 1.15, MAIN)
		row(-3.55, 2.2, 4.2, 0.95, DARK)
		fb(0.55, 0.55, 0.55, 3.9, -4.3, CYAN, NEON)
		fb(0.2, 0.25, 1.9, 4.7, 3.0, CYAN, NEON) -- trailing edge strip
		B:trail(fluke, v(0, FY + 6.3, FZ + 5.8), v(0, FY + 4.8, FZ + 5.0), { name = "FlukeTrailTop", color = { "#ffffff", CYAN }, life = 0.3, trans = { 0.45, 1 } })
		B:trail(fluke, v(0, FY - 4.3, FZ + 4.1), v(0, FY - 3.0, FZ + 3.9), { name = "FlukeTrailBot", color = { "#ffffff", CYAN }, life = 0.3, trans = { 0.45, 1 } })
		local wake = fb(1.5, 3, 2, 2, 0, MAIN, { tr = 1, name = "WakeFX" })
		B:emitter(wake, "burst", { name = "WakeBurst", color = { "#ffffff", "#9fe2ff" }, size = { 0.6, 0.4, 0 }, speed = { 4, 9 } })

		------------------------------------------------------------------
		-- NECK
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Body1", v(0, 6.9, -4.2))
		segment(neck, -7.4, -3.6, 7.1, 4.8, 4.6)
		spine(neck, -5.8, 9.65, 2, 1.3, false)
		spine(neck, -4.3, 9.65, 3, 1.4, false)
		B:block(neck, v(2.2, 0.5, 1.6), cf(0, 4.1, -5.6), BELLY)
		B:sym(function()
			for i = 0, 2 do
				B:block(neck, v(0.2, 0.5, 0.5), cf(2.43, 8.0 - i * 0.35, -4.5 - i * 0.8), CYAN, NEON)
			end
		end)

		------------------------------------------------------------------
		-- HEAD: big cartoon crocodilian skull with eye bumps on top
		------------------------------------------------------------------
		local head = B:bone("Head", "Neck", v(0, 7.3, -7.0))
		B:block(head, v(4.4, 3.8, 2.0), cf(0, 7.4, -6.6), MAIN) -- collar (hides the neck joint)
		B:block(head, v(6.0, 3.8, 4.8), cf(0, 8.6, -9.2), MAIN) -- cranium
		B:block(head, v(3.0, 0.5, 3.8), cf(0, 10.7, -8.9), DARK)
		B:block(head, v(4.8, 2.8, 3.6), cf(0, 8.1, -13.4), MAIN) -- snout
		B:block(head, v(2.6, 0.4, 3.4), cf(0, 9.65, -13.4), DARK)
		B:block(head, v(4.0, 2.4, 2.0), cf(0, 7.9, -16.1), MAIN) -- nose
		B:block(head, v(3.0, 0.5, 1.6), cf(0, 9.3, -16.1), DARK)
		-- pale upper lip band (two-tone head)
		B:block(head, v(6.1, 0.9, 4.6), cf(0, 7.15, -9.2), BELLY)
		B:block(head, v(4.9, 0.9, 3.4), cf(0, 7.15, -13.4), BELLY)
		B:block(head, v(4.1, 0.9, 1.8), cf(0, 7.15, -16.1), BELLY)
		-- mouth: coral palate, black throat
		B:block(head, v(5.0, 0.3, 4.4), cf(0, 6.6, -9.2), MOUTH)
		B:block(head, v(3.4, 0.3, 5.8), cf(0, 6.6, -14.2), MOUTH)
		B:block(head, v(4.0, 2.0, 0.5), cf(0, 5.9, -7.3), THROAT)
		local mouthFx = B:block(head, v(2.6, 1.6, 1.6), cf(0, 6.8, -17.4), MAIN, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFx, "burst", { name = "SnapBurst", color = { "#ffffff", CYAN } })
		B:emitter(mouthFx, "burst", { name = "BubbleBurst", color = { "#ffffff", "#9fe2ff" }, size = { 0.5, 0.8, 0.2 }, speed = { 5, 11 }, life = { 0.6, 1.2 } })
		local thrashFx = B:block(head, v(6, 5, 9), cf(0, 8.0, -12.5), MAIN, { tr = 1, name = "ThrashFX" })
		B:emitter(thrashFx, "bubble", { name = "ThrashBubbles", color = { "#ffffff", "#9fe2ff" }, rate = 45, enabled = false, size = { 0.3, 0.6, 0.7 }, speed = { 2, 6 }, spread = 120 })
		B:light(mouthFx, { name = "MouthLight", color = CYAN, brightness = 0.01, range = 14 })
		B:trail(head, v(0, 9.0, -17.2), v(0, 6.4, -17.2), { name = "SnoutTrail", color = { "#ffffff", CYAN }, life = 0.22, trans = { 0.55, 1 } })
		-- cartoon CHOMP impact lines (hidden, flashed on the bite)
		for i = 1, 8 do
			local a = (i - 1) / 8 * 360 + 22.5
			B:block(head, v(0.3, 0.3, 1.4), CFrame.new(0, 7.2, -18.4) * ang(0, 0, a) * CFrame.new(0, 3.2, 0) * ang(90, 0, 0), "#e8fbff", { mat = "Neon", tr = 1, name = "SnapLine" .. i })
		end

		B:sym(function(side)
			-- nostril
			B:block(head, v(0.5, 0.15, 0.6), cf(0.7, 9.6, -16.4), THROAT)
			-- upper teeth: rows of big white blocks hanging from the jaw line
			local up = {
				{ 2.55, -8.0, false }, { 2.55, -9.2, true }, { 2.55, -10.4, false },
				{ 2.0, -11.8, true }, { 2.0, -13.0, false }, { 2.0, -14.3, true },
				{ 1.6, -15.5, false },
			}
			for _, t in up do
				local s = t[3] and v(0.65, 1.3, 0.65) or v(0.5, 0.9, 0.5)
				B:block(head, s, cf(t[1], 6.85 - s.Y / 2, t[2]), WHITE)
			end
			B:block(head, v(0.7, 1.5, 0.7), cf(0.75, 6.15, -16.6), WHITE)
			-- eye bump on top of the skull (crocodile style); the eye wraps the
			-- outer-front corner so it reads from the side AND the front
			B:block(head, v(2.2, 1.7, 2.8), cf(1.9, 11.25, -9.8), MAIN)
			B:block(head, v(0.12, 1.75, 2.2), cf(3.03, 11.2, -10.2), DARK)
			B:block(head, v(0.9, 1.3, 1.5), cf(2.75, 11.2, -10.55), EYE, { mat = "Neon", name = "Eye" })
			-- one slit pupil wrapping the outer-front corner (looks forward)
			B:block(head, v(0.32, 1.1, 0.48), cf(3.1, 11.2, -11.13), SLIT)
			B:block(head, v(0.1, 0.34, 0.34), cf(3.25, 11.62, -10.45), WHITE)
			B:block(head, v(0.3, 0.32, 0.1), cf(2.6, 11.62, -11.35), WHITE)
			-- dark cheek panel + snout stripe (color blocking on the big flat sides)
			B:block(head, v(0.14, 1.5, 2.8), cf(3.03, 8.7, -8.4), DARK)
			B:block(head, v(0.14, 0.5, 3.0), cf(2.43, 8.95, -13.3), DARK)
			-- heavy angry brow
			B:block(head, v(2.6, 1.1, 3.2), cf(1.95, 12.45, -9.9, -12, 0, -10), DARK)
			-- swept-back lavender horns with cyan tips
			B:beam(head, v(1.9, 11.7, -8.9), v(2.9, 13.7, -7.3), 1.4, 1.4, LAV)
			B:beam(head, v(2.85, 13.5, -7.45), v(3.7, 14.9, -5.9), 1.05, 1.05, LAV)
			B:beam(head, v(3.65, 14.75, -6.05), v(4.0, 15.4, -5.0), 0.75, 0.75, LAV)
			B:block(head, v(0.55, 0.55, 0.55), cf(4.05, 15.6, -4.75, 40, 0, -15), CYAN, NEON)
			-- cheek frill spikes
			B:spike(head, v(2.8, 8.2, -7.9), v(4.5, 7.7, -5.7), 1.1, 1.1, LAV)
		end)

		-- eyelids for cartoon blinks (tucked under the brow at rest)
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(2.75, 12.55, -10.55))
			B:block(lid, v(1.12, 1.4, 1.82), cf(2.75, 12.55, -10.55), MAIN)
		end)

		------------------------------------------------------------------
		-- JAW (hinged at the back of the mouth)
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", v(0, 6.8, -7.5))
		B:block(jaw, v(5.2, 1.3, 4.6), cf(0, 6.05, -9.3), MAIN)
		B:block(jaw, v(3.8, 1.1, 5.6), cf(0, 6.15, -14.3), MAIN)
		B:block(jaw, v(5.3, 0.9, 4.4), cf(0, 5.2, -9.2), BELLY)
		B:block(jaw, v(3.9, 0.8, 5.4), cf(0, 5.4, -14.2), BELLY)
		B:block(jaw, v(2.8, 0.4, 3.4), cf(0, 4.6, -9.4), LAV)
		B:block(jaw, v(4.4, 0.2, 4.2), cf(0, 6.75, -9.3), MOUTH)
		B:block(jaw, v(3.0, 0.2, 5.2), cf(0, 6.75, -14.2), MOUTH)
		B:block(jaw, v(2.0, 0.4, 4.8), cf(0, 6.9, -10.8), TONGUE)
		B:sym(function()
			local low = {
				{ 2.2, -8.6, true }, { 2.2, -9.8, false }, { 2.2, -11.0, true },
				{ 1.5, -12.4, false }, { 1.5, -13.6, true }, { 1.5, -14.8, false },
			}
			for _, t in low do
				local s = t[3] and v(0.6, 1.2, 0.6) or v(0.5, 0.8, 0.5)
				B:block(jaw, s, cf(t[1], 6.65 + s.Y / 2, t[2]), WHITE)
			end
			B:block(jaw, v(0.65, 1.4, 0.65), cf(1.3, 7.3, -16.4), WHITE)
		end)

		------------------------------------------------------------------
		-- FLIPPERS: 4 broad paddles, 2 bones each (shoulder + paddle)
		------------------------------------------------------------------
		local function flipper(prefix, parentBone, pivot, yaw, droop, sc)
			B:sym(function(side)
				local F = CFrame.new(pivot) * ang(0, yaw, droop)
				local function at(x, y, z)
					return F * CFrame.new(x * sc, y * sc, z * sc)
				end
				local arm = B:bone(prefix .. "Fin" .. side, parentBone, F)
				B:block(arm, v(2.6, 1.3, 2.0) * sc, at(1.0, 0, 0), MAIN)
				B:block(arm, v(1.2, 0.3, 1.4) * sc, at(1.3, 0.7, 0.1), DARK)
				local tip = B:bone(prefix .. "Tip" .. side, prefix .. "Fin" .. side, at(2.2, 0, 0))
				B:block(tip, v(2.4, 0.8, 3.0) * sc, at(3.4, 0, 0.3), MAIN)
				B:block(tip, v(2.0, 0.7, 2.6) * sc, at(5.4, 0, 0.7), MAIN)
				B:block(tip, v(1.4, 0.6, 1.8) * sc, at(7.0, 0, 1.2), DARK)
				B:block(tip, v(2.4, 0.9, 0.5) * sc, at(3.4, 0, -1.4), LAV)
				B:block(tip, v(2.0, 0.8, 0.5) * sc, at(5.4, 0, -0.8), LAV)
				B:block(tip, v(3.4, 0.12, 0.35) * sc, at(4.4, 0.46, 0.0), BELLY)
				B:block(tip, v(3.0, 0.12, 0.35) * sc, at(4.6, 0.42, 1.0), BELLY)
				B:block(tip, v(3.6, 0.25, 0.25) * sc, at(4.6, 0.25, 1.95), CYAN, NEON)
				local a, b = at(7.6, 0, 1.6), at(6.4, 0, 2.1)
				B:trail(tip, a.Position, b.Position, { name = prefix .. "FinTrail" .. side, color = { "#ffffff", CYAN }, life = 0.25, trans = { 0.55, 1 } })
			end)
		end
		flipper("Front", "Body1", v(2.5, 5.4, -2.4), -16, -14, 1.0)
		flipper("Rear", "Body3", v(2.2, 5.4, 4.9), -26, -16, 0.8)

		------------------------------------------------------------------
		-- Floating voxel cubes (VFX) that bob and tumble around the swimmer
		------------------------------------------------------------------
		local orbs = {
			{ 8.4, 11.0, -5.0, 1.6, MAIN },
			{ -8.6, 9.0, 0.0, 1.3, LAV },
			{ 8.0, 6.8, 8.7, 1.3, BELLY },
			{ -7.6, 12.2, 8.7, 1.6, MAIN },
			{ 0.0, 15.6, 3.0, 1.1, DARK },
		}
		for i, o in orbs do
			local ob = B:bone("Orb" .. i, "Root", v(o[1], o[2], o[3]))
			B:block(ob, v(o[4], o[4], o[4]), cf(o[1], o[2], o[3]), o[5])
			B:block(ob, v(o[4] + 0.1, o[4] * 0.22, o[4] + 0.1), cf(o[1], o[2], o[3]), CYAN, NEON)
		end
	end,
}
