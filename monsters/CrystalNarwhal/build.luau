--!nocheck
-- Crystal Narwhal: a hyper, cheerful Atlantis narwhal, stud-built in the Void
-- Leviathan voxel style. Chunky stepped body in pale blue-grey with a darker
-- speckled back (colour-blocked spots), a white belly, horizontal flukes and
-- flippers wrapped in gold orichalcum bands. Its long tusk is a twisted spiral
-- of stacked turquoise crystal + gold rune bands with a small neon tip, set in
-- a marble-and-gold Atlantis collar. Big happy face: sparkly eyes with star
-- glints, a huge open smile, rosy cheeks. Crystal growths on a little marble
-- temple plinth on its back, a marble rune cuff on the tail.
-- Hidden VFX (tusk beam, star rays, crystal shards, splash cubes, bubble cubes,
-- happy-squint "^ ^" eyes, blink lids) are revealed by the motion.
return {
	DisplayName = "Crystal Narwhal",
	Rarity = "Legendary",
	Element = "Atlantis",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad, cos, sin = math.rad, math.cos, math.sin

		-- palette
		local BODY, DARK, DEEP = "#9fc3d9", "#5f87a3", "#46697f" -- pale blue-grey / dark speckle / deepest
		local FLECK = "#c9e1ee" -- pale speckles on the dark back
		local WHITE, CREAM = "#f4f8fb", "#dfeaf1" -- belly
		local GOLD, DGOLD = "#f2c14e", "#c98d26" -- orichalcum
		local MARBLE, MARBLE2 = "#f3efe6", "#d9d1c1"
		local TURQ, LTURQ, DTEAL = "#2ec4b6", "#86ece2", "#17878f" -- crystal
		local MOUTH, TONGUE, TONGUE2 = "#2a1020", "#ff7fa8", "#ffa9c6"
		local PUPIL, BLUSH, BROW = "#0f2232", "#ff9fc0", "#3e5d75"
		local NTURQ, NGOLD = "#3ff0e0", "#ffe27a" -- the two (small) neon accents
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- helpers
		------------------------------------------------------------------
		-- stepped body segment: pale core, dark top cap + dark saddle band on the
		-- upper sides, white belly cap + belly band (octagon-ish voxel profile)
		local function segment(bone, z0, z1, yc, w, h)
			local len, zc = z1 - z0, (z0 + z1) / 2
			local ch = h - 1.6
			B:block(bone, v(w, ch, len), cf(0, yc, zc), BODY)
			B:block(bone, v(w - 1.6, 0.8, len - 0.3), cf(0, yc + ch / 2 + 0.4, zc), DARK)
			B:block(bone, v(w - 1.6, 0.8, len - 0.3), cf(0, yc - ch / 2 - 0.4, zc), WHITE)
			B:block(bone, v(w + 0.12, ch * 0.32, len - 0.2), cf(0, yc + ch * 0.34, zc), DARK)
			B:block(bone, v(w + 0.1, 0.9, len - 0.3), cf(0, yc - ch / 2 + 0.45, zc), WHITE)
		end
		-- thin colour-block spot on a side face (x picks the side) or the top
		local function spot(bone, x, y, z, sy, sz, col)
			B:block(bone, v(0.16, sy, sz), cf(x, y, z), col)
		end
		local function topSpot(bone, x, y, z, sx, sz, col)
			B:block(bone, v(sx, 0.16, sz), cf(x, y, z), col)
		end
		-- flipper / fluke frame: local X along `ax`, local Z toward T
		local function frame(pos, ax, T)
			ax = ax.Unit
			local fz = (T - ax * T:Dot(ax)).Unit
			return CFrame.fromMatrix(pos, ax, fz:Cross(ax), fz)
		end
		-- crystal cluster: tilted turquoise blocks with a neon tip on the tallest
		local function crystals(bone, base, list)
			for i, c in list do
				local s, hgt = c[4], c[5]
				local C = CFrame.new(base + v(c[1], c[2], c[3])) * ang(c[6], c[7], c[8])
				B:block(bone, v(s, hgt, s), C * CFrame.new(0, hgt / 2, 0), c[9])
				if c[10] then
					B:block(bone, v(s * 0.55, 0.5, s * 0.55), C * CFrame.new(0, hgt + 0.2, 0), NTURQ, NEON)
				end
			end
		end

		------------------------------------------------------------------
		-- BODY1: chunky chest (swim chain centre)
		------------------------------------------------------------------
		local body1 = B:bone("Body1", "Root", v(0, 8, -1.5))
		segment(body1, -4.2, 1.2, 8, 9.0, 8.8)
		-- speckles: pale spots on the dark saddle, dark spots on the pale flanks
		B:sym(function()
			spot(body1, 4.6, 10.4, -2.8, 1.0, 1.2, FLECK)
			spot(body1, 4.6, 10.0, 0.0, 0.8, 0.8, FLECK)
			spot(body1, 4.56, 7.8, -3.3, 1.0, 1.0, DEEP)
			spot(body1, 4.56, 6.6, -1.4, 0.8, 1.4, DARK)
			spot(body1, 4.56, 8.6, -0.6, 0.6, 0.6, DEEP)
			spot(body1, 4.56, 6.2, 0.6, 0.6, 0.6, DARK)
		end)
		topSpot(body1, 2.2, 12.42, -3.0, 1.2, 1.0, FLECK)
		topSpot(body1, -2.6, 12.42, 0.2, 1.0, 1.2, FLECK)
		topSpot(body1, -2.4, 12.42, -3.4, 0.8, 0.8, FLECK)
		-- stepped white belly plates (like the Leviathan chest scales)
		B:block(body1, v(4.6, 0.6, 1.5), cf(0, 3.35, -3.0), CREAM)
		B:block(body1, v(5.2, 0.6, 1.5), cf(0, 3.3, -1.4), WHITE)
		B:block(body1, v(4.6, 0.6, 1.4), cf(0, 3.35, 0.1), CREAM)
		-- Atlantis temple plinth on the back carrying a crystal growth
		B:block(body1, v(3.2, 0.4, 3.2), cf(0, 12.55, -1.6), DGOLD)
		B:block(body1, v(2.8, 0.7, 2.8), cf(0, 13, -1.6), MARBLE)
		B:block(body1, v(2.0, 0.5, 2.0), cf(0, 13.55, -1.6), MARBLE2)
		crystals(body1, v(0, 13.8, -1.6), {
			{ 0, 0, 0, 1.1, 2.6, 0, 45, 6, TURQ, true },
			{ 0.7, 0, 0.5, 0.8, 1.6, 10, 20, -28, LTURQ, false },
			{ -0.7, 0, -0.4, 0.7, 1.4, -14, 0, 26, DTEAL, true },
		})
		-- barnacles
		B:block(body1, v(0.7, 0.4, 0.7), cf(3.0, 12.55, 0.4), MARBLE2)
		B:block(body1, v(0.5, 0.3, 0.5), cf(-3.2, 12.5, -3.2), MARBLE2)
		local fx = B:block(body1, v(8, 7, 9), cf(0, 8, -1), BODY, { tr = 1, name = "BodyFX" })
		B:emitter(fx, "sparkle", { name = "AmbientSparkle", color = { "#ffffff", NTURQ, NGOLD }, rate = 4 })
		B:emitter(fx, "burst", { name = "ShardBurst", color = { "#ffffff", NTURQ, LTURQ }, speed = { 12, 22 }, size = { 1.2, 0.8, 0 }, life = { 0.5, 1.1 } })
		B:light(fx, { name = "GlowLight", color = NTURQ, brightness = 0.01, range = 18 })

		------------------------------------------------------------------
		-- HEAD: big chunky melon head with a happy cartoon face
		------------------------------------------------------------------
		local head = B:bone("Head", "Body1", v(0, 8, -3.8))
		B:block(head, v(9.4, 7.0, 5.8), cf(0, 8.0, -6.7), BODY) -- core
		B:block(head, v(7.8, 0.8, 5.2), cf(0, 11.9, -6.6), DARK) -- top cap
		B:block(head, v(7.8, 0.8, 5.0), cf(0, 4.1, -6.6), WHITE) -- under cap
		B:block(head, v(9.52, 1.9, 5.4), cf(0, 10.4, -6.5), DARK) -- dark saddle
		B:block(head, v(9.5, 1.0, 5.4), cf(0, 5.0, -6.6), WHITE) -- belly band
		B:block(head, v(8.0, 6.0, 0.6), cf(0, 7.6, -9.9), BODY) -- face slab
		B:block(head, v(6.6, 1.8, 0.8), cf(0, 11.1, -10.0), BODY) -- melon bulge
		B:block(head, v(5.0, 0.6, 0.6), cf(0, 12.0, -9.6), DARK) -- melon cap step
		B:block(head, v(7.0, 0.7, 0.6), cf(0, 4.35, -9.9), WHITE) -- chin step
		-- speckles on the head
		B:sym(function()
			spot(head, 4.8, 10.5, -5.4, 0.9, 1.1, FLECK)
			spot(head, 4.8, 10.7, -7.8, 0.6, 0.6, FLECK)
			spot(head, 4.76, 7.4, -7.0, 0.9, 0.9, DEEP)
			spot(head, 4.76, 8.6, -4.8, 0.7, 1.1, DARK)
		end)
		topSpot(head, 1.8, 12.32, -7.4, 1.1, 0.9, FLECK)
		topSpot(head, -1.8, 12.32, -5.6, 0.9, 1.1, FLECK)
		-- blowhole (bubbles puff out of it)
		B:block(head, v(1.2, 0.2, 0.7), cf(0, 12.36, -5.0), MOUTH)
		local blow = B:block(head, v(1, 0.6, 0.6), cf(0, 12.8, -5.0), BODY, { tr = 1, name = "BlowFX" })
		B:emitter(blow, "bubble", { name = "BlowBubbles", color = { "#ffffff", LTURQ }, rate = 0, size = { 0.35, 0.6, 0.7 }, speed = { 3, 6 }, spread = 25 })

		-- EYES: big white blocks on the front corners, neon turquoise iris,
		-- dark pupil, sparkly white glints + a spinning star sparkle
		B:sym(function(side)
			local ex, ey = 2.75, 8.95
			B:block(head, v(2.6, 3.0, 1.0), cf(ex, ey, -10.3), "#ffffff")
			B:block(head, v(1.9, 2.3, 0.12), cf(ex, ey - 0.05, -10.85), NTURQ, { mat = "Neon", name = "Iris" .. side })
			B:block(head, v(0.12, 2.2, 0.8), cf(ex + 1.33, ey - 0.05, -10.3), NTURQ, NEON)
			B:block(head, v(1.0, 1.4, 0.1), cf(ex - 0.2, ey - 0.15, -10.93), PUPIL)
			B:block(head, v(0.6, 0.6, 0.1), cf(ex + 0.35, ey + 0.55, -10.99), "#ffffff", NEON)
			B:block(head, v(0.35, 0.35, 0.1), cf(ex - 0.45, ey - 0.65, -10.99), "#ffffff", NEON)
			-- arched happy brows (raised)
			B:block(head, v(1.4, 0.5, 0.5), cf(ex, 10.95, -10.42), BROW)
			B:block(head, v(0.7, 0.5, 0.5), cf(ex + 1.0, 10.65, -10.44), BROW)
			B:block(head, v(0.7, 0.5, 0.5), cf(ex - 1.0, 10.65, -10.44), BROW)
			-- rosy cheek
			B:block(head, v(0.9, 0.6, 0.12), cf(3.6, 6.2, -10.27), BLUSH)
			-- blink lid / happy squint cover (hidden until used)
			B:block(head, v(2.8, 3.2, 1.8), cf(ex, ey, -10.26), BODY, { tr = 1, name = "Lid" .. side })
			B:block(head, v(2.4, 0.4, 0.12), cf(ex, ey - 0.4, -11.2), BROW, { tr = 1, name = "BlinkLine" .. side })
			-- "^" happy squint arcs
			B:block(head, v(1.5, 0.5, 0.12), cf(ex - 0.55, ey + 0.05, -11.2) * ang(0, 0, 35), BROW, { tr = 1, name = "HappyA" .. side })
			B:block(head, v(1.5, 0.5, 0.12), cf(ex + 0.55, ey + 0.05, -11.2) * ang(0, 0, -35), BROW, { tr = 1, name = "HappyB" .. side })
			-- star sparkle in the eye (spins + twinkles)
			local sp = B:bone("EyeStar" .. side, "Head", v(ex + 0.95, ey + 1.1, -11.0))
			B:block(sp, v(0.95, 0.22, 0.1), cf(ex + 0.95, ey + 1.1, -11.02), "#ffffff", { mat = "Neon", name = "StarA" .. side })
			B:block(sp, v(0.22, 0.95, 0.1), cf(ex + 0.95, ey + 1.1, -11.03), "#ffffff", { mat = "Neon", name = "StarB" .. side })
		end)

		-- HUGE SMILE: stepped black "D" mouth, white top teeth, pink tongue,
		-- curled-up corners. The lower rows + tongue ride the Jaw (laughs).
		B:block(head, v(5.0, 2.8, 0.1), cf(0, 5.8, -10.25), MOUTH) -- dark backing
		B:block(head, v(6.2, 0.65, 0.2), cf(0, 6.95, -10.32), MOUTH)
		B:block(head, v(5.4, 0.6, 0.2), cf(0, 6.4, -10.32), MOUTH)
		B:block(head, v(5.0, 0.4, 0.12), cf(0, 7.05, -10.45), "#ffffff") -- teeth strip
		B:sym(function()
			B:block(head, v(0.6, 0.7, 0.2), cf(3.25, 7.45, -10.32), MOUTH) -- curled-up corner
			B:block(head, v(0.5, 0.45, 0.2), cf(3.55, 7.85, -10.32), MOUTH)
			B:block(head, v(0.12, 0.4, 0.13), cf(1.25, 7.05, -10.46), "#c9d6de") -- tooth gaps
		end)
		local jaw = B:bone("Jaw", "Head", v(0, 6.6, -10.0))
		B:block(jaw, v(4.4, 0.6, 0.2), cf(0, 5.8, -10.32), MOUTH)
		B:block(jaw, v(3.0, 0.6, 0.2), cf(0, 5.22, -10.32), MOUTH)
		B:block(jaw, v(3.2, 0.9, 0.1), cf(0, 5.6, -10.45), TONGUE)
		B:block(jaw, v(1.2, 0.4, 0.1), cf(0, 5.85, -10.5), TONGUE2)

		------------------------------------------------------------------
		-- TUSK: twisted spiral of stacked crystal blocks + gold rune bands,
		-- spinning inside a marble Atlantis collar on the forehead
		------------------------------------------------------------------
		local TB = v(0, 11.0, -10.3)
		local tdir = v(0, sin(rad(15)), -cos(rad(15)))
		local TF = CFrame.fromMatrix(TB, v(1, 0, 0), v(0, cos(rad(15)), sin(rad(15))), -tdir) -- local -Z along the tusk
		-- collar (on the head, does not spin)
		local CC = TF * CFrame.new(0, 0, -0.2) * ang(90, 0, 0)
		B:ring(head, CC, 1.6, 8, v(1.4, 1.0, 0.8), MARBLE)
		B:ring(head, CC * CFrame.new(0, 0.6, 0) * ang(0, 22.5, 0), 1.75, 8, v(1.45, 0.4, 0.8), GOLD)
		B:ring(head, CC * CFrame.new(0, -0.6, 0) * ang(0, 22.5, 0), 1.5, 8, v(1.2, 0.3, 0.6), DGOLD)
		for k = 0, 3 do
			B:block(head, v(0.32, 0.4, 0.12), CC * ang(0, k * 90, 0) * CFrame.new(0, 0, -2.03), NTURQ, NEON)
		end
		local tusk = B:bone("Tusk", "Head", TF)
		local N, STEP = 12, 0.78
		for i = 0, N - 1 do
			local s = 1.95 - i * 0.095
			local z = -(0.5 + i * STEP)
			local band = (i == 2 or i == 6 or i == 10)
			if band then
				B:block(tusk, v(s + 0.25, s + 0.25, 0.55), TF * CFrame.new(0, 0, z) * ang(0, 0, i * 25), GOLD)
				B:block(tusk, v(0.2, 0.28, 0.28), TF * CFrame.new(0, 0, z) * ang(0, 0, i * 25) * CFrame.new((s + 0.25) / 2 + 0.05, 0, 0), NGOLD, NEON)
			else
				B:block(tusk, v(s, s, STEP + 0.12), TF * CFrame.new(0, 0, z) * ang(0, 0, i * 25), (i % 2 == 0) and TURQ or LTURQ)
			end
			-- gold helix ridge winding up the tusk
			if not band then
				B:block(tusk, v(0.32, 0.32, STEP), TF * CFrame.new(0, 0, z) * ang(0, 0, i * 25 + 45) * CFrame.new(s * 0.62, 0, 0), DGOLD)
			end
		end
		local tipZ = -(0.5 + (N - 1) * STEP) - 0.75
		B:block(tusk, v(0.55, 0.55, 0.7), TF * CFrame.new(0, 0, tipZ) * ang(0, 0, 45), LTURQ)
		local tip = B:block(tusk, v(0.4, 0.4, 0.6), TF * CFrame.new(0, 0, tipZ - 0.55) * ang(0, 0, 45), NTURQ, { mat = "Neon", name = "TuskTip" })
		B:emitter(tip, "sparkle", { name = "TuskSparkle", color = { "#ffffff", NTURQ, NGOLD }, rate = 3, size = { 0.15, 0.5, 0 } })
		B:light(tip, { name = "TuskLight", color = NTURQ, brightness = 0.4, range = 9 })
		B:trail(tusk, (TF * CFrame.new(0.3, 0, tipZ)).Position, (TF * CFrame.new(-0.3, 0, tipZ + 1.2)).Position, { name = "TuskTrail", color = { "#ffffff", NTURQ }, life = 0.3, trans = { 0.4, 1 } })
		-- hidden beam + spinning star rays (revealed by the Crystal Breach)
		B:block(tusk, v(0.7, 0.7, 9), TF * CFrame.new(0, 0, tipZ - 5.0) * ang(0, 0, 45), NTURQ, { mat = "Neon", tr = 1, name = "TuskBeam" })
		for k = 1, 6 do
			local R = TF * CFrame.new(0, 0, -5.5) * ang(0, 0, k * 60)
			B:block(tusk, v(0.45, 3.6, 0.45), R * CFrame.new(0, 3.0, 0), k % 2 == 0 and NGOLD or NTURQ, { mat = "Neon", tr = 1, name = "Ray" .. k })
		end

		------------------------------------------------------------------
		-- BODY2 + TAIL chain
		------------------------------------------------------------------
		local body2 = B:bone("Body2", "Body1", v(0, 8.2, 1.0))
		segment(body2, 0.8, 4.8, 8.2, 7.6, 6.8)
		B:sym(function()
			spot(body2, 3.88, 9.8, 2.0, 0.9, 1.1, FLECK)
			spot(body2, 3.84, 7.4, 3.6, 0.9, 0.9, DEEP)
			spot(body2, 3.84, 6.6, 1.8, 0.6, 0.8, DARK)
		end)
		topSpot(body2, -1.4, 11.62, 3.6, 1.0, 0.9, FLECK)
		crystals(body2, v(1.0, 11.5, 2.4), {
			{ 0, 0, 0, 0.8, 1.6, 8, 30, -18, TURQ, true },
			{ -0.6, 0, 0.5, 0.6, 1.0, -10, 0, 22, LTURQ, false },
		})
		B:block(body2, v(0.6, 0.35, 0.6), cf(-1.6, 11.7, 1.6), MARBLE2)
		-- low stepped dorsal ridge (narwhals have a bumpy ridge, not a fin)
		B:block(body2, v(1.4, 0.6, 1.2), cf(0, 11.85, 4.1), DEEP)
		B:block(body2, v(0.9, 0.4, 0.8), cf(0, 12.3, 4.2), FLECK)

		local tail1 = B:bone("Tail1", "Body2", v(0, 8.5, 4.6))
		segment(tail1, 4.4, 7.8, 8.5, 6.0, 5.4)
		-- marble rune cuff with gold rims (Atlantis orichalcum band)
		B:block(tail1, v(6.25, 5.6, 1.0), cf(0, 8.5, 6.2), MARBLE)
		B:block(tail1, v(6.4, 5.75, 0.3), cf(0, 8.5, 5.55), GOLD)
		B:block(tail1, v(6.4, 5.75, 0.3), cf(0, 8.5, 6.85), GOLD)
		B:sym(function()
			B:block(tail1, v(0.12, 0.6, 0.4), cf(3.15, 8.5, 6.2), NTURQ, NEON)
			spot(tail1, 3.06, 7.4, 4.9, 0.6, 0.5, DARK)
		end)
		B:block(tail1, v(0.4, 0.12, 0.6), cf(0, 11.33, 6.2), NTURQ, NEON)
		B:block(tail1, v(1.2, 0.6, 0.9), cf(0, 11.3, 7.4), DEEP)
		B:block(tail1, v(1.0, 0.5, 1.0), cf(0, 11.0, 5.0), DEEP)

		local tail2 = B:bone("Tail2", "Tail1", v(0, 8.8, 7.6))
		segment(tail2, 7.4, 10.0, 8.8, 4.4, 4.0)
		B:sym(function()
			spot(tail2, 2.26, 8.0, 8.6, 0.5, 0.6, DARK)
		end)
		topSpot(tail2, 0.6, 10.82, 8.4, 0.8, 0.8, FLECK)

		local tail3 = B:bone("Tail3", "Tail2", v(0, 9.0, 9.8))
		B:block(tail3, v(2.4, 2.8, 2.2), cf(0, 9.0, 10.7), BODY)
		B:block(tail3, v(1.6, 0.5, 2.0), cf(0, 10.6, 10.7), DARK)
		B:block(tail3, v(1.6, 0.5, 2.0), cf(0, 7.4, 10.7), WHITE)
		B:block(tail3, v(2.6, 0.5, 0.6), cf(0, 9.0, 11.4), GOLD)

		------------------------------------------------------------------
		-- FLUKES: horizontal stepped lobes with a gold orichalcum band
		------------------------------------------------------------------
		local fluke = B:bone("Fluke", "Tail3", v(0, 9.0, 11.4))
		B:block(fluke, v(2.6, 1.2, 2.2), cf(0, 9.0, 12.6), BODY)
		B:block(fluke, v(1.8, 1.3, 0.8), cf(0, 9.0, 13.6), DARK)
		B:block(fluke, v(2.8, 1.35, 0.5), cf(0, 9.0, 12.0), DGOLD)
		B:sym(function(side)
			local lob = B:bone("FlukeLobe" .. side, "Fluke", v(1.2, 9.0, 12.4))
			local rows = {
				{ 2.0, 1.6, 11.6, 14.2, DARK, 1.0 }, { 3.5, 1.6, 12.0, 14.9, BODY, 0.9 },
				{ 5.0, 1.6, 12.6, 15.5, DARK, 0.8 }, { 6.3, 1.2, 13.4, 15.9, BODY, 0.7 },
				{ 7.2, 0.8, 14.4, 16.2, DARK, 0.6 },
			}
			for _, r in rows do
				B:block(lob, v(r[2], r[6], r[4] - r[3]), cf(r[1], 9.0, (r[3] + r[4]) / 2), r[5])
				B:block(lob, v(r[2] - 0.2, r[6] - 0.1, 0.6), cf(r[1], 9.0, r[4] + 0.25), WHITE) -- pale trailing edge
			end
			-- gold orichalcum band across the lobe, with a rune dot
			B:block(lob, v(5.0, 1.12, 0.8), cf(3.7, 9.0, 13.9), GOLD)
			B:block(lob, v(0.4, 0.12, 0.4), cf(3.7, 9.6, 13.9), NTURQ, NEON)
			B:block(lob, v(0.5, 0.5, 0.5), cf(7.5, 9.0, 16.7), NTURQ, NEON)
			B:trail(lob, v(7.4, 9.0, 16.3), v(6.0, 9.0, 15.0), { name = "FlukeTrail" .. side, color = { "#ffffff", NTURQ }, life = 0.28, trans = { 0.45, 1 } })
		end)

		------------------------------------------------------------------
		-- FLIPPERS: stepped paddles with gold orichalcum bands
		------------------------------------------------------------------
		B:sym(function(side)
			local F = frame(v(4.3, 5.6, -2.4), v(0.82, -0.3, 0.5), v(0, 0, 1))
			local f1 = B:bone("Flipper" .. side, "Body1", F.Position)
			B:block(f1, v(2.8, 1.0, 2.6), F * CFrame.new(1.0, 0, 0.4), BODY)
			B:block(f1, v(2.0, 0.3, 1.8), F * CFrame.new(1.1, 0.55, 0.3), DARK)
			B:block(f1, v(0.7, 1.15, 2.8), F * CFrame.new(2.3, 0, 0.45), GOLD)
			B:block(f1, v(0.2, 0.25, 0.35), F * CFrame.new(2.3, 0.62, 0.0), NGOLD, NEON)
			local F2 = F * CFrame.new(2.5, 0, 0)
			local f2 = B:bone("FlipperTip" .. side, "Flipper" .. side, F2.Position)
			B:block(f2, v(2.4, 0.85, 2.2), F * CFrame.new(3.7, 0, 0.5), BODY)
			B:block(f2, v(2.4, 0.7, 0.9), F * CFrame.new(3.7, -0.03, 1.95), WHITE)
			B:block(f2, v(1.3, 0.3, 1.0), F * CFrame.new(3.4, 0.5, 0.3), FLECK)
			B:block(f2, v(0.55, 0.95, 2.4), F * CFrame.new(5.0, 0, 0.75), DGOLD)
			B:block(f2, v(1.2, 0.7, 1.9), F * CFrame.new(5.8, 0, 1.0), BODY)
			B:block(f2, v(0.8, 0.6, 1.0), F * CFrame.new(6.6, 0, 1.4), WHITE)
			B:block(f2, v(0.45, 0.4, 0.45), F * CFrame.new(7.05, 0, 1.6), NTURQ, NEON)
			B:trail(f2, (F * CFrame.new(6.9, 0, 1.2)).Position, (F * CFrame.new(6.3, 0, 2.2)).Position, { name = "FlipperTrail" .. side, color = { "#ffffff", NTURQ }, life = 0.22, trans = { 0.5, 1 } })
		end)

		------------------------------------------------------------------
		-- Floating cubes: orichalcum crystal cubes + marble ruin cubes
		------------------------------------------------------------------
		local orbs = {
			{ 10.5, 13.0, -6.0, 1.6, true }, { -11.0, 10.0, -3.0, 1.4, false }, { 10.0, 6.0, 7.0, 1.3, false },
			{ -9.5, 14.0, 6.0, 1.6, true }, { 1.0, 17.0, 3.5, 1.2, true },
		}
		for i, o in orbs do
			local ob = B:bone("Orb" .. i, "Root", v(o[1], o[2], o[3]))
			local s = o[4]
			if o[5] then
				B:block(ob, v(s, s, s), cf(o[1], o[2], o[3]) * ang(0, 45, 0), TURQ)
				B:block(ob, v(s * 0.6, s + 0.1, s * 0.6), cf(o[1], o[2], o[3]) * ang(0, 45, 0), LTURQ)
				B:block(ob, v(s * 0.35, s * 0.35, s * 0.35), cf(o[1], o[2] + s * 0.62, o[3]), NTURQ, NEON)
			else
				B:block(ob, v(s, s, s), cf(o[1], o[2], o[3]), MARBLE)
				B:block(ob, v(s + 0.1, s * 0.28, s + 0.1), cf(o[1], o[2] + s * 0.32, o[3]), GOLD)
				B:block(ob, v(s * 0.3, s * 0.3, 0.12), cf(o[1], o[2] - 0.1, o[3] - s / 2 - 0.02), NTURQ, NEON)
			end
		end

		------------------------------------------------------------------
		-- CRYSTAL SHARDS (hidden) that burst out at the top of the breach
		------------------------------------------------------------------
		local SH = v(0, 8, -1.5)
		for k = 1, 10 do
			local sb = B:bone("Shard" .. k, "Root", SH)
			local big = k % 3 == 1
			B:block(sb, big and v(1.0, 1.8, 1.0) or v(0.8, 1.3, 0.8), CFrame.new(SH) * ang(0, 45, 0), k % 2 == 0 and LTURQ or TURQ, { tr = 1, name = "ShardPart" .. k })
		end

		------------------------------------------------------------------
		-- SPLASH: water cubes + ripple slabs (hidden) and the burst emitters
		------------------------------------------------------------------
		local SC = v(0, 4.0, 0.5)
		local splashAt = B:block("Root", v(8, 0.6, 10), CFrame.new(SC), WHITE, { tr = 1, name = "SplashFX" })
		B:emitter(splashAt, "burst", { name = "SplashBurst", color = { "#ffffff", "#9feaff", NTURQ }, speed = { 8, 16 }, size = { 1.0, 0.7, 0 }, accel = { 0, -18, 0 }, spread = 70 })
		B:emitter(splashAt, "dust", { name = "SplashMist", color = { "#ffffff", "#bfefff" }, size = { 2, 3.5, 4.5 }, speed = { 6, 12 } })
		B:emitter(splashAt, "bubble", { name = "BubbleBurst", color = { "#ffffff", LTURQ, NTURQ }, rate = 0, size = { 0.4, 0.7, 0.8 }, speed = { 4, 9 }, spread = 80, life = { 1.2, 2.2 } })
		for k = 1, 10 do
			local sb = B:bone("Drop" .. k, "Root", SC)
			local size = k % 2 == 1 and (k % 4 == 1 and v(2.0, 2.0, 2.0) or v(1.5, 1.5, 1.5)) or v(2.8, 0.6, 1.3)
			local col = k % 4 == 1 and "#7fd8f0" or "#bdf1ff"
			B:block(sb, size, CFrame.new(SC), col, { tr = 1, name = "DropPart" .. k })
		end

		------------------------------------------------------------------
		-- voxel bubbles that puff out of the blowhole (hidden)
		------------------------------------------------------------------
		local BC = v(0, 12.9, -5.0)
		for k = 1, 3 do
			local bb = B:bone("Bubble" .. k, "Root", BC)
			local s = k == 2 and 0.8 or 0.6
			B:block(bb, v(s, s, s), CFrame.new(BC), "#d8f6ff", { tr = 1, name = "BubblePart" .. k })
		end
	end,
}
