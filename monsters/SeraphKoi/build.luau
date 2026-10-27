--!nocheck
-- Seraph Koi: a holy flying koi crossed with a seraph, stud-built in the Void
-- Leviathan voxel style. Chunky stepped koi body (pearl white with stepped
-- orange / red Kohaku patches, cream belly plates, an orange-and-gold stepped
-- dorsal ridge), a BIG cartoon fish face (bulgy sky-glow eyes with glints, a
-- coral "O" gulping mouth with lips, gold barbels), a white -> orange -> red
-- butterfly fan tail with a gold serrated edge, SIX stepped feather-block angel
-- wings with gold tips (3 pairs), and a floating gold block halo with tiny neon
-- studs. Neon is kept to the eyes, the forehead gem, halo studs and tips.
-- Hidden VFX parts (holy sun rays, splash droplets, voxel bubbles) are revealed
-- by the motion during the "Heavenly Leap".
return {
	DisplayName = "Seraph Koi",
	Rarity = "Divine",
	Element = "Holy Water",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad, cos, sin = math.rad, math.cos, math.sin

		-- palette
		local WHITE, SHADE = "#fffbf2", "#ffe2a8" -- pearl body / pale-gold shade (scales, gills)
		local FEATH, PURE = "#ffedc4", "#ffffff" -- warm alternate feather / pure white primaries
		local BROW = "#9c1d16"
		local CREAM, CREAM2 = "#f6deb0", "#ffeec8" -- belly plates
		local ORANGE, LORANGE, DORANGE = "#ff7a1a", "#ffa043", "#d4500f" -- koi patches + dark shade
		local RED, DRED = "#e8332a", "#b8211f"
		local GOLD, DGOLD = "#ffc62e", "#d68a12" -- halo, barbels, feather tips
		local LIP, LIPL, MOUTH, TONGUE = "#ff6b5a", "#ff9b85", "#2a0d18", "#ff8fb0"
		local PUPIL, BLUSH = "#10121c", "#ff9fb4"
		local SKY, GLOW = "#6fe3ff", "#ffe680" -- the two (small) neon accents
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- helpers
		------------------------------------------------------------------
		-- stepped koi body segment: white core, a coloured top cap + saddle band
		-- wrapping the upper sides, cream belly cap + band (octagon-ish profile)
		local function segment(bone, z0, z1, yc, w, h, topCol, saddle)
			local len, zc = z1 - z0, (z0 + z1) / 2
			local ch = h - 1.6
			B:block(bone, v(w, ch, len), cf(0, yc, zc), WHITE)
			B:block(bone, v(w - 1.6, 0.8, len - 0.3), cf(0, yc + ch / 2 + 0.4, zc), topCol)
			B:block(bone, v(w - 1.6, 0.8, len - 0.3), cf(0, yc - ch / 2 - 0.4, zc), CREAM)
			if saddle then
				B:block(bone, v(w + 0.12, ch * 0.3, len - 0.2), cf(0, yc + ch * 0.35, zc), saddle)
			end
			B:block(bone, v(w + 0.1, 0.9, len - 0.3), cf(0, yc - ch / 2 + 0.45, zc), CREAM)
		end
		-- one-sided patch / scale block on the flank (x sign picks the side)
		local function flank(bone, x, y, z, sy, sz, col, th)
			th = th or 0.2
			B:block(bone, v(th, sy, sz), cf(x, y, z), col)
		end
		-- stepped dorsal plate: dark base step, orange steps leaning back, gold cap
		local function plate(bone, y, z, steps, d0, tip)
			local d, zo = d0, 0
			for i = 0, steps - 1 do
				local col = i == 0 and DORANGE or (i % 2 == 1 and ORANGE or LORANGE)
				B:block(bone, v(i == 0 and 1.6 or 1.25, 1, math.max(0.9, d)), cf(0, y + i + 0.5, z + zo), col)
				if i < steps - 1 then
					d *= 0.74
					zo += 0.45
				end
			end
			if tip then
				B:block(bone, v(0.55, 0.55, 0.55), cf(0, y + steps + 0.2, z + zo + 0.25), GLOW, NEON)
			else
				B:block(bone, v(1.0, 0.6, math.max(0.9, d * 0.7)), cf(0, y + steps + 0.25, z + zo + 0.2), GOLD)
			end
		end
		-- frame from a direction (local X) with feathers/rays trailing along T (local Z)
		local function frame(pos, ax, T)
			ax = ax.Unit
			local fz = (T - ax * T:Dot(ax)).Unit
			return CFrame.fromMatrix(pos, ax, fz:Cross(ax), fz)
		end

		------------------------------------------------------------------
		-- BODY1: the chest (swim chain center)
		------------------------------------------------------------------
		local body1 = B:bone("Body1", "Root", v(0, 8.6, -1.0))
		segment(body1, -5.4, 1.6, 8.6, 7.4, 7.4, ORANGE, ORANGE)
		-- Kohaku patches (never symmetric): stepped blobs hanging off the saddle
		flank(body1, 3.78, 9.0, -3.0, 2.6, 3.4, ORANGE)
		flank(body1, 3.8, 7.4, -2.4, 1.0, 2.0, DORANGE)
		flank(body1, 3.8, 9.8, 0.6, 1.6, 1.8, RED)
		flank(body1, -3.78, 8.9, -1.2, 2.8, 3.8, RED)
		flank(body1, -3.8, 7.2, -0.8, 0.9, 2.2, DRED)
		B:block(body1, v(2.2, 0.4, 3.0), cf(1.5, 12.5, -3.4), RED) -- top patches
		B:block(body1, v(1.8, 0.4, 2.0), cf(-1.4, 12.5, -0.2), RED)
		-- pixel scales on the white flanks
		B:sym(function()
			flank(body1, 3.77, 7.3, -4.3, 0.8, 1.0, SHADE, 0.16)
			flank(body1, 3.77, 7.3, -1.0, 0.8, 1.0, SHADE, 0.16)
		end)
		-- stepped cream belly plates (like the Leviathan chest scales)
		B:block(body1, v(4.4, 0.6, 1.5), cf(0, 4.65, -4.0), CREAM2)
		B:block(body1, v(5.0, 0.6, 1.5), cf(0, 4.6, -2.4), CREAM)
		B:block(body1, v(4.4, 0.6, 1.5), cf(0, 4.65, -0.8), CREAM2)
		-- dorsal ridge
		plate(body1, 12.3, -3.7, 3, 2.8, false)
		plate(body1, 12.3, -1.2, 5, 3.6, true)
		local holy = B:block(body1, v(7, 7, 9), cf(0, 8.6, 0), WHITE, { tr = 1, name = "HolyFX" })
		B:emitter(holy, "sparkle", { name = "AmbientSparkle", color = { "#ffffff", GLOW, SKY }, rate = 4 })
		B:emitter(holy, "burst", { name = "HolyBurst", color = { "#ffffff", GLOW, SKY }, speed = { 10, 20 }, size = { 1.1, 0.7, 0 }, life = { 0.5, 1.0 } })
		B:emitter(holy, "leaf", { name = "FeatherBurst", color = { "#ffffff", "#fff3c4", GOLD }, rate = 0, size = { 0.6, 0.6, 0.4 }, speed = { 5, 10 }, life = { 1.4, 2.4 }, spread = 180 })
		B:light(holy, { name = "HolyLight", color = GLOW, brightness = 0.01, range = 18 })

		------------------------------------------------------------------
		-- BODY2 + TAIL chain
		------------------------------------------------------------------
		local body2 = B:bone("Body2", "Body1", v(0, 8.7, 1.3))
		segment(body2, 1.0, 5.4, 8.7, 6.4, 6.4, RED)
		flank(body2, 3.28, 9.4, 3.4, 2.6, 2.6, ORANGE)
		flank(body2, 3.3, 7.8, 3.8, 0.8, 1.6, DORANGE)
		flank(body2, -3.28, 10.1, 2.4, 1.6, 2.6, RED)
		flank(body2, -3.28, 8.9, 4.4, 1.2, 1.2, ORANGE)
		B:block(body2, v(4.0, 0.6, 1.4), cf(0, 5.15, 2.6), CREAM2)
		plate(body2, 12.0, 2.2, 4, 3.2, true)
		plate(body2, 12.0, 4.5, 3, 2.4, false)

		local tail1 = B:bone("Tail1", "Body2", v(0, 8.8, 5.1))
		segment(tail1, 4.9, 8.5, 8.8, 5.0, 5.0, ORANGE)
		flank(tail1, 2.58, 9.2, 6.8, 1.6, 1.6, RED)
		flank(tail1, -2.58, 9.6, 6.2, 1.4, 2.0, ORANGE)
		plate(tail1, 11.4, 6.6, 2, 2.4, false)
		-- anal fin (stepped down)
		B:block(tail1, v(0.9, 1.0, 2.4), cf(0, 5.75, 6.9), ORANGE)
		B:block(tail1, v(0.75, 1.0, 1.6), cf(0, 4.8, 7.4), WHITE)
		B:block(tail1, v(0.6, 0.6, 0.9), cf(0, 4.05, 7.9), GOLD)

		local tail2 = B:bone("Tail2", "Tail1", v(0, 8.9, 8.3))
		segment(tail2, 8.1, 10.9, 8.9, 3.8, 3.8, RED)
		flank(tail2, -1.98, 9.2, 9.4, 1.2, 1.6, ORANGE)

		local tail3 = B:bone("Tail3", "Tail2", v(0, 9.0, 10.7))
		B:block(tail3, v(2.6, 2.2, 2.4), cf(0, 9.0, 11.6), WHITE)
		B:block(tail3, v(1.8, 0.5, 2.0), cf(0, 10.35, 11.6), ORANGE)
		B:block(tail3, v(1.8, 0.5, 2.0), cf(0, 7.65, 11.6), CREAM)

		------------------------------------------------------------------
		-- FAN TAIL: two flowing butterfly lobes of stepped rows, white ->
		-- orange -> red, every row capped by a gold block (serrated gold edge)
		------------------------------------------------------------------
		local fan = B:bone("TailFan", "Tail3", v(0, 9.0, 12.4))
		B:block(fan, v(1.6, 3.6, 2.4), cf(0, 9.0, 13.3), ORANGE)
		B:block(fan, v(1.7, 1.2, 1.4), cf(0, 9.0, 14.6), GOLD)
		-- side veil fins: give the fan tail width from the back / top (3D butterfly tail)
		B:sym(function()
			B:block(fan, v(2.4, 0.7, 2.0), cf(1.5, 9.0, 14.0, 0, -18, 0), ORANGE)
			B:block(fan, v(1.9, 0.6, 1.8), cf(2.7, 9.0, 15.3, 0, -26, 0), RED)
			B:block(fan, v(1.0, 0.75, 1.1), cf(3.5, 9.0, 16.4, 0, -26, 0), GOLD)
		end)
		local function lobe(name, pivotY, rows, dir)
			local b = B:bone(name, "TailFan", v(0, pivotY, 13.6))
			for i, r in rows do
				local y, z0, z1, col = r[1], r[2], r[3], r[4]
				local th = 1.7 - i * 0.12
				B:block(b, v(th, 1.05, z1 - z0), cf(0, y, (z0 + z1) / 2), col)
				B:block(b, v(th - 0.35, 0.95, 0.9), cf(0, y, z1 + 0.35), GOLD)
			end
			local last = rows[#rows]
			B:block(b, v(0.6, 0.6, 0.6), cf(0, last[1] + 0.75 * dir, last[3] + 0.4), GLOW, NEON)
			B:trail(b, v(0, last[1] + 0.5 * dir, last[3] + 0.6), v(0, last[1] - 1.6 * dir, last[3] - 0.4), { name = name .. "Trail", color = { "#ffffff", GLOW }, life = 0.3, trans = { 0.45, 1 } })
			return b
		end
		lobe("LobeU", 10.2, {
			{ 10.9, 13.0, 16.2, WHITE }, { 11.9, 13.5, 17.2, LORANGE }, { 12.9, 14.2, 18.1, ORANGE },
			{ 13.9, 15.0, 18.9, ORANGE }, { 14.9, 16.0, 19.5, RED }, { 15.85, 17.2, 19.9, DRED },
		}, 1)
		lobe("LobeD", 7.8, {
			{ 7.1, 13.0, 16.0, WHITE }, { 6.1, 13.5, 17.0, LORANGE }, { 5.1, 14.2, 17.8, ORANGE },
			{ 4.15, 15.0, 18.4, RED }, { 3.3, 16.0, 18.8, DRED },
		}, -1)

		------------------------------------------------------------------
		-- HEAD: big cartoon fish face. Authored at 1x, scaled up HS about the
		-- head pivot so the face reads big and cute from far away.
		------------------------------------------------------------------
		local HP, HS = v(0, 8.7, -4.8), 1.15
		local function hp(x, y, z) return HP + (v(x, y, z) - HP) * HS end
		local function hb(bone, sx, sy, sz, x, y, z, col, opts, rx, ry, rz)
			return B:block(bone, v(sx, sy, sz) * HS, CFrame.new(hp(x, y, z)) * ang(rx or 0, ry or 0, rz or 0), col, opts)
		end
		local head = B:bone("Head", "Body1", HP)
		hb(head, 8.0, 6.4, 5.6, 0, 8.9, -7.8, WHITE) -- cranium
		hb(head, 6.4, 0.8, 4.8, 0, 12.5, -7.6, ORANGE) -- top step
		hb(head, 4.0, 0.6, 3.2, 0, 13.2, -7.8, RED) -- tancho crown patch
		hb(head, 2.0, 0.4, 1.6, 0.6, 13.65, -7.6, RED)
		hb(head, 6.6, 0.8, 4.6, 0, 5.3, -7.8, CREAM) -- jowl
		hb(head, 4.6, 4.2, 1.4, 0, 8.4, -11.3, WHITE) -- snout (narrow so the big eyes read from the front)
		hb(head, 3.8, 0.6, 1.3, 0, 10.8, -11.2, ORANGE) -- nose patch
		hb(head, 8.1, 1.4, 3.0, 0, 11.3, -6.6, ORANGE) -- orange saddle down the sides
		hb(head, 8.3, 0.7, 2.2, 0, 10.4, -6.2, DORANGE) -- dark step under the saddle
		hb(head, 4.0, 0.6, 1.2, 0, 6.1, -11.3, CREAM) -- chin step under the snout
		-- forehead gem in a gold diamond setting
		hb(head, 1.5, 1.5, 0.3, 0, 11.4, -10.7, GOLD, nil, 0, 0, 45)
		hb(head, 0.8, 0.8, 0.3, 0, 11.4, -10.8, SKY, { mat = "Neon", name = "Gem" }, 0, 0, 45)

		B:sym(function(side)
			-- BIG bulgy eye on the front corner: white block, glowing sky iris on
			-- the FRONT face only (one eye per side from every angle), big black
			-- pupil and a glint
			hb(head, 2.6, 3.4, 2.4, 3.5, 9.6, -9.85, PURE)
			hb(head, 2.0, 2.6, 2.0, 3.5, 9.45, -10.2, SKY, { mat = "Neon", name = "Eye" .. side })
			hb(head, 1.1, 1.8, 0.12, 3.2, 9.25, -11.25, PUPIL)
			hb(head, 0.55, 0.55, 0.1, 3.9, 10.25, -11.27, "#ffffff", NEON)
			-- chunky dark brow, inner end raised (kind / happy), stepped cap
			hb(head, 2.9, 0.7, 1.0, 3.45, 11.75, -10.75, BROW, nil, 0, 0, -10)
			hb(head, 1.4, 0.45, 0.9, 3.0, 12.25, -10.7, BROW, nil, 0, 0, -10)
			-- blush
			hb(head, 1.3, 0.6, 0.1, 3.3, 7.35, -10.66, BLUSH)
			-- gill cover (own bone: flaps open on every gulp)
			local gill = B:bone("Gill" .. side, "Head", hp(4.0, 8.6, -7.4))
			hb(gill, 0.6, 4.6, 2.6, 4.1, 8.4, -6.2, SHADE)
			hb(gill, 0.7, 4.0, 0.5, 4.15, 8.4, -5.0, DORANGE)
			-- eyelid + lash line for blinks (hidden until it closes)
			local lid = B:bone("Lid" .. side, "Head", hp(3.5, 12.6, -9.95))
			hb(lid, 3.1, 3.5, 2.9, 3.5, 12.6, -9.95, WHITE, { tr = 1, name = "Eyelid" .. side })
			hb(lid, 3.15, 0.4, 0.25, 3.5, 11.0, -11.48, BROW, { tr = 1, name = "Lash" .. side })
		end)

		------------------------------------------------------------------
		-- MOUTH: wide coral pout with two buck teeth (Mouth pushes out on a
		-- gulp, the Jaw / lower lip + tongue drop open)
		------------------------------------------------------------------
		local mouth = B:bone("Mouth", "Head", hp(0, 7.7, -11.6))
		hb(mouth, 3.6, 0.8, 1.1, 0, 8.75, -12.45, LIP)
		hb(mouth, 2.4, 0.3, 0.8, 0, 9.25, -12.4, LIPL)
		hb(mouth, 2.1, 1.9, 0.4, 0, 7.75, -12.12, MOUTH)
		B:sym(function()
			hb(mouth, 0.8, 1.9, 1.1, 1.4, 7.75, -12.45, LIP)
			hb(mouth, 0.55, 0.6, 0.3, 0.42, 8.08, -12.75, "#ffffff") -- buck tooth
		end)
		local mouthFx = hb(mouth, 1.4, 1.2, 1.0, 0, 7.3, -13.6, WHITE, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFx, "bubble", { name = "MouthBubbles", color = { "#ffffff", SKY }, rate = 0, size = { 0.35, 0.6, 0.7 }, speed = { 2, 5 }, spread = 35, dir = "Front" })
		-- long drooping gold barbels (2 bones each so they flop)
		B:sym(function(side)
			local w1 = B:bone("Whisker" .. side, "Mouth", hp(1.7, 8.4, -12.8))
			B:beam(w1, hp(1.7, 8.4, -12.8), hp(3.3, 7.9, -13.4), 0.5, 0.5, GOLD)
			local w2 = B:bone("WhiskerTip" .. side, "Whisker" .. side, hp(3.25, 7.95, -13.35))
			B:beam(w2, hp(3.25, 7.95, -13.35), hp(4.6, 5.4, -13.0), 0.45, 0.45, GOLD)
			hb(w2, 0.55, 0.55, 0.55, 4.65, 5.25, -13.0, GLOW, NEON)
		end)

		local jaw = B:bone("Jaw", "Head", hp(0, 6.9, -11.4))
		hb(jaw, 3.6, 0.8, 1.1, 0, 6.5, -12.45, LIP)
		hb(jaw, 3.6, 0.9, 1.4, 0, 5.75, -11.65, CREAM)
		hb(jaw, 1.5, 0.35, 0.8, 0, 7.05, -12.25, TONGUE)
		B:sym(function()
			B:beam(jaw, hp(0.9, 5.5, -12.4), hp(1.3, 4.1, -12.9), 0.4, 0.4, DGOLD) -- chin barbel
		end)

		------------------------------------------------------------------
		-- HALO: floating stepped ring of gold blocks with tiny neon studs
		------------------------------------------------------------------
		local HC = CFrame.new(hp(0, 15.4, -7.4)) * ang(14, 0, 0)
		local halo = B:bone("Halo", "Head", HC)
		B:ring(halo, HC, 3.2, 10, v(2.1, 0.7, 0.9), GOLD)
		B:ring(halo, HC * CFrame.new(0, -0.45, 0) * ang(0, 18, 0), 2.95, 5, v(2.3, 0.4, 0.8), DGOLD)
		for k = 0, 3 do
			B:block(halo, v(0.45, 0.45, 0.45), HC * ang(0, k * 90 + 18, 0) * CFrame.new(0, 0.5, -3.2), GLOW, NEON)
		end
		local haloFx = B:block(halo, v(6, 1, 6), HC, GOLD, { tr = 1, name = "HaloFX" })
		B:emitter(haloFx, "sparkle", { name = "HaloSparkle", color = { "#ffffff", GLOW }, rate = 3 })
		B:light(haloFx, { name = "HaloLight", color = GLOW, brightness = 0.01, range = 12 })

		------------------------------------------------------------------
		-- PECTORAL FINS: stepped fans (orange / white rays, gold tips)
		------------------------------------------------------------------
		B:sym(function(side)
			local F = frame(v(3.6, 6.6, -4.0), v(0.75, -0.55, 0.3), v(0, 0, 1))
			local f1 = B:bone("Fin" .. side, "Body1", F.Position)
			B:block(f1, v(2.6, 0.7, 1.8), F * CFrame.new(1.0, 0, 0.4), WHITE)
			B:block(f1, v(1.2, 0.8, 1.2), F * CFrame.new(0.3, 0.05, 0.2), DORANGE)
			local F2 = F * CFrame.new(2.1, 0, 0)
			local f2 = B:bone("FinTip" .. side, "Fin" .. side, F2.Position)
			local rays = { { 3.0, -0.2, ORANGE }, { 3.4, 1.0, WHITE }, { 2.8, 2.2, ORANGE } }
			for i, r in rays do
				local dy = i % 2 == 0 and 0.05 or 0
				B:block(f2, v(r[1], 0.5, 1.25), F * CFrame.new(1.9 + r[1] / 2, dy, r[2]), r[3])
				B:block(f2, v(0.9, 0.55, 1.15), F * CFrame.new(1.9 + r[1] + 0.4, dy, r[2]), GOLD)
			end
			B:trail(f2, (F * CFrame.new(5.6, 0, 1.0)).Position, (F * CFrame.new(5.0, 0, 2.4)).Position, { name = "FinTrail" .. side, color = { "#ffffff", GLOW }, life = 0.25, trans = { 0.5, 1 } })

		end)

		------------------------------------------------------------------
		-- SIX WINGS: stepped white feather blocks with gold tips. Each wing is
		-- authored in a frame (local X along the arm, local Z = feathers).
		------------------------------------------------------------------
		local function wing(name, parent, root, elev, sweep, L1, L2, f1, f2, neonEdge, trail, T)
			B:sym(function(side)
				local E, S = rad(elev), rad(sweep)
				local out = v(cos(S), 0, sin(S))
				local ax = out * cos(E) + v(0, 1, 0) * sin(E)
				local W1 = frame(root, ax, T)
				local W2 = W1 * CFrame.new(L1, 0, 0) * ang(0, -14, 0)
				-- chunky feather blocks fanning out toward the wing tip (each one
				-- splays a little more), alternating pure white / warm cream with
				-- stepped heights so the edge-on view shows a stepped, solid wing
				local function feathers(bone, Fr, list, a0, da)
					for i, f in list do
						local len = f[2]
						local dy = (i % 2 == 0) and 0.18 or -0.18
						local F = Fr * CFrame.new(f[1], dy, 1.5) * ang(0, a0 + da * (i - 1), 0)
						B:block(bone, v(1.6, 1.0, len), F * CFrame.new(0, 0, len / 2), i % 2 == 0 and FEATH or PURE)
						B:block(bone, v(1.5, 1.1, 1.0), F * CFrame.new(0, 0, len + 0.45), GOLD)
					end
				end
				local w1 = B:bone(name .. side, parent, W1.Position)
				B:block(w1, v(L1 + 0.6, 1.4, 1.4), W1 * CFrame.new(L1 / 2, 0, 0), PURE)
				B:block(w1, v(L1, 0.8, 0.7), W1 * CFrame.new(L1 / 2 + 0.2, 0.3, -0.95), GOLD) -- leading edge
				B:block(w1, v(L1, 1.2, 1.8), W1 * CFrame.new(L1 / 2 + 0.2, -0.05, 1.3), LORANGE) -- coverts
				-- calm sky glow strip under the coverts (lights up the shaded underside)
				B:block(w1, v(L1 - 0.8, 0.3, 0.4), W1 * CFrame.new(L1 / 2 + 0.3, -0.75, 1.6), SKY, NEON)
				feathers(w1, W1, f1, -8, 6)
				local w2 = B:bone(name .. "Tip" .. side, name .. side, W2.Position)
				B:block(w2, v(L2, 1.2, 1.2), W2 * CFrame.new(L2 / 2, 0, 0), PURE)
				B:block(w2, v(L2 - 0.4, 0.7, 0.6), W2 * CFrame.new(L2 / 2 - 0.1, 0.25, -0.85), GOLD)
				B:block(w2, v(L2 - 0.3, 1.1, 1.6), W2 * CFrame.new(L2 / 2, -0.05, 1.2), LORANGE)
				feathers(w2, W2, f2, 4, 10)
				if neonEdge then
					B:block(w2, v(L2 - 1.0, 0.3, 0.3), W2 * CFrame.new(L2 / 2 - 0.2, 0.62, -1.2), SKY, NEON)
				end
				if trail then
					local last = f2[#f2]
					local LF = W2 * CFrame.new(last[1], 0, 1.5) * ang(0, 4 + 10 * (#f2 - 1), 0)
					B:trail(w2, (LF * CFrame.new(0, 0, last[2] + 0.9)).Position, (LF * CFrame.new(0, 0, last[2] - 1.4)).Position,
						{ name = name .. "Trail" .. side, color = { "#ffffff", GLOW }, life = 0.3, trans = { 0.5, 1 } })
				end
			end)
		end
		wing("WingU", "Body1", v(2.3, 12.0, -2.0), 42, 6, 4.6, 5.4,
			{ { 1.2, 3.0 }, { 2.8, 3.6 } }, { { 0.7, 4.4 }, { 2.1, 5.4 }, { 3.5, 6.2 }, { 5.0, 5.8 } }, true, true, v(0, -1, 0.5))
		wing("WingM", "Body1", v(3.6, 10.2, -1.0), 2, 12, 4.4, 5.0,
			{ { 1.2, 2.8 }, { 2.8, 3.4 } }, { { 0.7, 4.0 }, { 2.1, 4.8 }, { 3.5, 5.4 }, { 4.9, 4.8 } }, true, true, v(0, 0.3, 1))
		wing("WingD", "Body1", v(3.6, 7.6, 0.4), -34, 24, 3.6, 4.0,
			{ { 1.2, 2.2 }, { 2.6, 2.6 } }, { { 0.7, 2.8 }, { 2.1, 3.3 }, { 3.4, 2.8 } }, false, false, v(0, -0.4, 1))

		------------------------------------------------------------------
		-- Floating voxel cubes (pearl cube, gold cap, thin sky neon band)
		------------------------------------------------------------------
		local orbs = { { 11.5, 13.0, -7.0, 2.0 }, { -12.0, 10.0, -4.0, 1.6 }, { 11.0, 5.5, 8.0, 1.4 }, { -10.5, 15.5, 8.5, 1.8 } }
		for i, o in orbs do
			local ob = B:bone("Orb" .. i, "Root", v(o[1], o[2], o[3]))
			local s = o[4]
			B:block(ob, v(s, s, s), cf(o[1], o[2], o[3]), WHITE)
			B:block(ob, v(s + 0.1, s * 0.3, s + 0.1), cf(o[1], o[2] + s * 0.36, o[3]), GOLD)
			B:block(ob, v(s + 0.16, s * 0.14, s + 0.16), cf(o[1], o[2] - s * 0.1, o[3]), SKY, NEON)
		end

		------------------------------------------------------------------
		-- HOLY SUN RAYS (hidden; flash at the apex of the leap). The motion
		-- carries the bone up with the leap.
		------------------------------------------------------------------
		local RC = v(0, 8.6, 1.5)
		local rays = B:bone("Rays", "Root", RC)
		for k = 1, 8 do
			local a = rad(math.floor((k - 1) / 2) * 90 + 45)
			local d = (k % 2 == 1) and v(cos(a), sin(a), 0) or v(0, sin(a), cos(a))
			local r0, r1 = 7.0, (k % 4 < 2) and 15.0 or 12.0
			B:beam(rays, RC + d * r0, RC + d * r1, 1.2, 1.2, GOLD, { mat = "Neon", tr = 1, name = "Ray" .. k })
		end

		------------------------------------------------------------------
		-- SPLASH: holy-water droplet cubes (hidden) that burst out of the
		-- splashdown, + the burst / mist emitters
		------------------------------------------------------------------
		local SC = v(0, 4.6, 0.5)
		local splashAt = B:block("Root", v(8, 0.6, 10), CFrame.new(SC), WHITE, { tr = 1, name = "SplashFX" })
		B:emitter(splashAt, "burst", { name = "SplashBurst", color = { "#ffffff", SKY, "#3fb8ff" }, speed = { 8, 16 }, size = { 1.0, 0.7, 0 }, accel = { 0, -18, 0 }, spread = 70 })
		B:emitter(splashAt, "dust", { name = "SplashMist", color = { "#ffffff", "#bfefff" }, size = { 2, 3.5, 4.5 }, speed = { 6, 12 } })
		-- odd drops: big cubes arcing up in a crown; even drops: flat ripple
		-- slabs skimming outward (a voxel splash ring)
		for k = 1, 12 do
			local sb = B:bone("Drop" .. k, "Root", SC)
			local size = k % 2 == 1 and (k % 4 == 1 and v(2.4, 2.4, 2.4) or v(1.8, 1.8, 1.8)) or v(3.0, 0.6, 1.4)
			local col = k % 4 == 1 and "#3fb8ff" or SKY
			B:block(sb, size, CFrame.new(SC), col, { tr = 1, name = "DropPart" .. k })
		end

		------------------------------------------------------------------
		-- voxel bubbles that wobble up out of the mouth after gulps (hidden)
		------------------------------------------------------------------
		local BC = v(0, 7.3, -14.8)
		for k = 1, 3 do
			local bb = B:bone("Bubble" .. k, "Root", BC)
			local s = k == 2 and 0.8 or 0.6
			B:block(bb, v(s, s, s), CFrame.new(BC), "#d8f6ff", { tr = 1, name = "BubblePart" .. k })
		end
	end,
}
