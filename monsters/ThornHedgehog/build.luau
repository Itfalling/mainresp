--!nocheck
-- Thornback Hedgehog (Guardian #4, Epic): a CHUBBY, ROUND, GRUMPY hedgehog that
-- guards a berry bush. The whole hedgehog is one big rounded-stepped ball (dark
-- spiny skin on top, warm fur below) with a cream face patch on its FRONT: big
-- cartoon eyes under heavy grumpy brows, a short stepped snout with a black
-- button nose, one small jaw with a tiny underbite, pink blush and small round
-- ears. Short stubby feet peek out underneath, tiny paws are held in front.
-- Quills are ONLY stepped block stacks (dark brown -> tan -> cream tip), on a
-- regular grid of rings radiating back from the face; a few have tiny neon-lime
-- tips. Berries, a flower and a little vine are tucked between them.
-- 100% blocks: zero wedges.
-- Rig: the Head bone pivots at the BALL CENTRE, so the face slides around the
-- ball like a mask (look / nod) and tucks inside it to curl up. Hidden
-- "BallCover" props (a spiny face plate + belly quills) close the ball while it
-- rolls.
return {
	DisplayName = "Thornback Hedgehog",
	Rarity = "Epic",
	Element = "Nature",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local sin, cos, rad, sqrt = math.sin, math.cos, math.rad, math.sqrt

		-- palette ---------------------------------------------------------
		local SKIN = "#3d2415" -- dark spiny skin (top of the ball)
		local FUR, FURD = "#a86d3c", "#8a5530" -- warm fur (lower ball, feet, ears)
		local SP0, SP1, SP2 = "#6a4126", "#b8854f", "#f6e8c8" -- quill base / mid / cream tip
		local CREAM, CREAM2, TAN = "#f7e7c6", "#fff3dd", "#dcbf92" -- face patch
		local INK, BLACK = "#2a170e", "#141012" -- brows + eye rims / pupils + nose
		local WHITE = "#fffdf6"
		local MOUTH, TONGUE = "#22100f", "#e2587a"
		local BLUSH, PINK = "#f59aa9", "#ff78ae"
		local VINE, LEAF = "#2f7a2c", "#5fbf45"
		local BERRY, BERRYHI, SUN = "#d6304d", "#ff9fb6", "#ffd447"
		local NEON = "#c8ff3a" -- the one neon accent (lime)
		local ANGER = "#ff2a3c"

		------------------------------------------------------------------
		-- THE BALL: rounded-stepped body (horizontal slabs, each an octagon
		-- made of two crossing boxes)
		------------------------------------------------------------------
		local C = v(0, 4.6, 0.4) -- ball centre
		local RX, RY, RZ = 4.0, 3.8, 4.2
		local body = B:bone("Body", "Root", v(0, 1.3, 0.4))
		local ys = { 0.8, 1.5, 2.4, 3.5, 5.7, 6.8, 7.7, 8.4 }
		for i = 1, #ys - 1 do
			local a, b = ys[i], ys[i + 1]
			local yy = math.clamp(C.Y, a, b)
			local k = (yy - C.Y) / RY
			local r = sqrt(1 - k * k)
			local col = b <= 3.5 and FUR or SKIN
			local cy = (a + b) / 2
			B:block(body, v(2 * RX * r, b - a, 2 * RZ * r * 0.74), cf(0, cy, C.Z), col)
			B:block(body, v(2 * RX * r * 0.74, b - a + 0.06, 2 * RZ * r), cf(0, cy, C.Z), col)
		end
		-- stubby tail
		local tail = B:bone("Tail", "Body", v(0, 2.4, 4.2))
		B:block(tail, v(1.1, 0.9, 1.0), cf(0, 2.35, 4.6), FUR)
		B:block(tail, v(0.6, 0.5, 0.5), cf(0, 2.25, 5.25), FURD)

		------------------------------------------------------------------
		-- QUILLS: stepped block stacks on rings radiating back from the face
		------------------------------------------------------------------
		-- direction on the ball: gamma = angle from the face (front pole, -Z),
		-- phi = angle around it (0 = up, +90 = right/+X)
		local function dirAt(g, f)
			local G, F = rad(g), rad(f)
			return v(sin(G) * sin(F), sin(G) * cos(F), -cos(G))
		end
		local function surf(g, f, out)
			local n = dirAt(g, f)
			out = out or 0
			return C + v((RX + out) * n.X, (RY + out) * n.Y, (RZ + out) * n.Z), n
		end
		for _, g in { "F", "B" } do
			B:bone("Quill" .. g, "Body", C)
			B:bone("Quill" .. g .. "R", "Body", C)
			B:bone("Quill" .. g .. "L", "Body", C)
		end
		local function groupOf(g, f)
			local grp = g <= 95 and "F" or "B"
			if math.abs(f) <= 26 then
				return "Quill" .. grp
			end
			return "Quill" .. grp .. (f > 0 and "R" or "L")
		end
		local trails = 0
		local function quill(g, f, len, neon, trail)
			local s, n = surf(g, f, 0)
			local d = (n + v(0, 0.1, 0.6)).Unit
			local bone = groupOf(g, f)
			-- axis-aligned cubes stepped along the quill direction (3D pixel art)
			local function at(dist)
				return CFrame.new(s + d * dist)
			end
			-- step lengths: as long as possible while the axis-aligned cubes
			-- still overlap along the diagonal
			local m = math.max(math.abs(d.X), math.abs(d.Y), math.abs(d.Z))
			local d1 = math.min(1.6 * len, 0.96 * (1.6 + 1.15) / 2 / m)
			local d2 = d1 + math.min(1.15 * len, 0.96 * (1.15 + 0.75) / 2 / m)
			B:block(bone, v(1.6, 1.6, 1.6), at(0.1), SP0)
			B:block(bone, v(1.15, 1.15, 1.15), at(0.1 + d1), SP1)
			B:block(bone, v(0.75, 0.75, 0.75), at(0.1 + d2), SP2)
			if neon then
				B:block(bone, v(0.36, 0.36, 0.36), at(0.1 + d2 + 0.5), NEON, { mat = "Neon" })
			end
			if trail then
				trails += 1
				local tip = s + d * (d2 + 0.5)
				B:trail(bone, tip, tip - d * 0.9, { name = "SpinTrail" .. trails, color = { "#ffffff", NEON }, life = 0.14, trans = { 0.45, 1 } })
			end
		end
		-- {gamma, {phi...}, length}
		local RINGS = {
			{ 68, { 0, 38, -38, 76, -76 }, 0.55 },
			{ 92, { 19, -19, 57, -57, 95, -95 }, 0.75 },
			{ 118, { 0, 38, -38, 76, -76, 112, -112 }, 1.0 },
			{ 144, { 25, -25, 75, -75, 125, -125 }, 0.92 },
			{ 168, { 0 }, 0.85 },
		}
		local NEONTIP = { ["68:0"] = true, ["92:57"] = true, ["92:-57"] = true, ["118:0"] = true, ["144:75"] = true, ["144:-75"] = true }
		for _, ring in RINGS do
			for _, f in ring[2] do
				local key = ring[1] .. ":" .. f
				quill(ring[1], f, ring[3], NEONTIP[key], f == 0 and (ring[1] == 68 or ring[1] == 118))
			end
		end

		------------------------------------------------------------------
		-- Garden accents between the quills: berries, a flower, a little vine
		------------------------------------------------------------------
		local function onBall(g, f, out)
			local p, n = surf(g, f, out)
			return CFrame.lookAt(p, p + n), n
		end
		-- berry cluster on the back-left
		do
			local base = onBall(131, -52, 0.35)
			B:block("QuillBL", v(0.8, 0.8, 0.8), base, BERRY)
			B:block("QuillBL", v(0.65, 0.65, 0.65), base * CFrame.new(0.55, -0.35, 0.15), BERRY)
			B:block("QuillBL", v(0.25, 0.25, 0.25), base * CFrame.new(-0.15, 0.2, -0.4), BERRYHI)
			B:block("QuillBL", v(0.5, 0.18, 0.3), base * CFrame.new(0, 0.5, -0.1), LEAF)
		end
		-- flower on the top-right
		do
			local fr = onBall(104, 36, 0.4)
			B:block("QuillFR", v(1.1, 0.45, 0.25), fr, PINK)
			B:block("QuillFR", v(0.45, 1.1, 0.25), fr, PINK)
			B:block("QuillFR", v(0.42, 0.42, 0.25), fr * CFrame.new(0, 0, -0.06), SUN)
		end
		-- little vine curling along the lower right side, with two leaves
		do
			local pts = { { 92, 118 }, { 110, 132 }, { 130, 140 }, { 150, 145 } }
			for i = 1, #pts - 1 do
				local a = surf(pts[i][1], pts[i][2], 0.15)
				local b = surf(pts[i + 1][1], pts[i + 1][2], 0.15)
				B:beam(body, a, b, 0.42, 0.42, VINE)
			end
			for i, p in { { 104, 128 }, { 140, 143 } } do
				local c, n = onBall(p[1], p[2], 0.3)
				B:block(body, v(0.85, 0.2, 0.55), c * CFrame.new(0, 0, -0.05), i == 1 and LEAF or VINE)
			end
		end

		------------------------------------------------------------------
		-- HEAD = the face patch on the FRONT of the ball. Pivot at the ball
		-- centre: turning / nodding slides the whole face around the ball.
		------------------------------------------------------------------
		local head = B:bone("Head", "Body", C)
		B:block(head, v(5.6, 3.4, 0.6), cf(0, 4.5, -3.75), CREAM) -- main face
		B:block(head, v(4.2, 0.85, 0.6), cf(0, 6.6, -3.55), CREAM) -- forehead step
		B:block(head, v(4.6, 1.0, 0.6), cf(0, 2.35, -3.55), CREAM) -- chin step
		B:block(head, v(1.6, 0.6, 0.4), cf(0, 6.95, -3.95), SKIN) -- widow's peak hairline
		B:sym(function()
			B:block(head, v(0.6, 2.6, 1.0), cf(2.85, 4.2, -3.3), CREAM2) -- cheek fluff
			B:block(head, v(0.9, 0.45, 0.12), cf(2.05, 3.7, -4.1), BLUSH) -- blush
		end)
		-- mouth: dark slit between snout and jaw + throat (seen when open)
		B:block(head, v(1.8, 0.3, 1.0), cf(0, 2.75, -4.5), MOUTH)
		B:block(head, v(1.6, 0.9, 0.25), cf(0, 2.45, -3.95), MOUTH)

		-- EYES: big white eye block + dark rim, one dark pupil (own bone) with
		-- a glint, heavy grumpy brow right on top (own bone), hidden lids
		local EY, EX = 5.25, 1.5
		B:sym(function(side)
			B:block(head, v(2.0, 2.2, 0.5), cf(EX, EY, -4.05), WHITE)
			B:block(head, v(2.25, 2.45, 0.3), cf(EX, EY - 0.02, -3.95), INK) -- rim
			local pupil = B:bone("Pupil" .. side, "Head", v(EX - 0.2, EY - 0.15, -4.35))
			B:block(pupil, v(0.95, 1.4, 0.12), cf(EX - 0.2, EY - 0.15, -4.34), BLACK)
			B:block(pupil, v(0.34, 0.34, 0.08), cf(EX - 0.02, EY + 0.22, -4.42), WHITE)
			-- lids (props)
			B:block(head, v(2.08, 2.28, 0.5), cf(EX, EY, -4.24), TAN, { tr = 1, name = "Eyelid" .. side })
			B:block(head, v(2.1, 0.24, 0.1), cf(EX, EY - 0.95, -4.52), INK, { tr = 1, name = "Lash" .. side })
			-- heavy brow, inner end low = grumpy
			local brow = B:bone("Brow" .. side, "Head", v(EX, EY + 1.15, -4.45))
			B:block(brow, v(2.5, 0.7, 0.8), cf(EX + 0.05, EY + 1.2, -4.4, 0, 0, 16), INK)
			-- small round ear
			local ear = B:bone("Ear" .. side, "Head", v(2.7, 7.0, -2.6))
			B:block(ear, v(1.3, 1.1, 0.6), cf(3.0, 7.5, -2.7), FUR)
			B:block(ear, v(0.8, 0.4, 0.6), cf(3.0, 8.2, -2.7), FUR)
			B:block(ear, v(0.65, 0.6, 0.12), cf(3.0, 7.45, -3.03), BLUSH)
		end)

		-- SNOUT: short stepped snout + black button nose (own bone: sniffing)
		local nose = B:bone("Nose", "Head", v(0, 3.6, -4.0))
		B:block(nose, v(2.4, 1.4, 1.0), cf(0, 3.6, -4.45), CREAM2)
		B:block(nose, v(1.6, 1.1, 0.8), cf(0, 3.68, -5.25), CREAM2)
		B:block(nose, v(1.0, 0.8, 0.5), cf(0, 3.85, -5.8), BLACK)
		B:block(nose, v(0.3, 0.22, 0.1), cf(0.22, 4.1, -6.06), WHITE)
		local noseFX = B:block(nose, v(1, 1, 1), cf(0, 3.8, -6.6), CREAM, { tr = 1, name = "NoseFX" })
		B:emitter(noseFX, "dust", {
			name = "Huff", drag = 3, color = { "#ffffff", "#e8e2d4" }, size = { 0.7, 1.4, 2.0 }, life = { 0.4, 0.8 },
			speed = { 4, 7 }, spread = 20, trans = { 0.2, 0.5, 1 }, dir = "Front", accel = { 0, 2, 0 },
		})
		B:emitter(noseFX, "burst", {
			name = "Crumbs", color = { BERRY, BERRYHI, "#7a1020" }, speed = { 3, 6 }, size = { 0.35, 0.3, 0 },
			life = { 0.4, 0.8 }, accel = { 0, -18, 0 }, spread = 70,
		})

		-- JAW: one small jaw with a tiny underbite (two little teeth up front)
		local jaw = B:bone("Jaw", "Head", v(0, 2.85, -3.9))
		B:block(jaw, v(1.9, 0.7, 1.2), cf(0, 2.35, -4.45), CREAM)
		B:block(jaw, v(1.4, 0.3, 0.9), cf(0, 1.9, -4.35), TAN)
		B:block(jaw, v(1.1, 0.1, 0.7), cf(0, 2.72, -4.4), TONGUE)
		B:sym(function()
			B:block(jaw, v(0.3, 0.42, 0.25), cf(0.42, 2.85, -4.95), WHITE)
		end)

		-- anger mark (props) floating at the top-right of the forehead
		local vein = B:bone("Vein", "Head", v(1.2, 8.5, -3.4))
		local VC = CFrame.new(1.2, 8.5, -3.4) * P.ang(0, -15, 0)
		B:block(vein, v(0.8, 0.26, 0.22), VC * CFrame.new(-0.25, 0.5, 0), ANGER, { tr = 1, name = "AngerMark1" })
		B:block(vein, v(0.26, 0.8, 0.22), VC * CFrame.new(0.5, 0.25, 0), ANGER, { tr = 1, name = "AngerMark2" })
		B:block(vein, v(0.8, 0.26, 0.22), VC * CFrame.new(0.25, -0.5, 0), ANGER, { tr = 1, name = "AngerMark3" })
		B:block(vein, v(0.26, 0.8, 0.22), VC * CFrame.new(-0.5, -0.25, 0), ANGER, { tr = 1, name = "AngerMark4" })

		------------------------------------------------------------------
		-- tiny front paws + stubby feet
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Body", v(2.2, 2.7, -3.2))
			B:block(arm, v(0.9, 1.1, 0.9), cf(2.4, 2.2, -3.7), FUR)
			B:block(arm, v(1.1, 0.75, 1.0), cf(2.45, 1.55, -4.0), TAN)
			for k = -1, 1 do
				B:block(arm, v(0.24, 0.24, 0.26), cf(2.45 + 0.32 * k, 1.3, -4.55), WHITE)
			end
			B:trail(arm, v(2.45, 1.7, -4.6), v(2.45, 1.2, -4.6), { name = "ClawTrail" .. side, color = { "#ffffff", NEON }, life = 0.14, trans = { 0.5, 1 } })

			local leg = B:bone("Leg" .. side, "Body", v(1.75, 1.3, 0.0))
			B:block(leg, v(1.4, 1.2, 1.4), cf(1.75, 1.15, -0.1), FURD)
			local foot = B:bone("Foot" .. side, "Leg" .. side, v(1.8, 0.45, -0.2))
			B:block(foot, v(1.7, 0.8, 2.6), cf(1.8, 0.4, -0.9), FUR)
			for k = -1, 1 do
				B:block(foot, v(0.42, 0.36, 0.42), cf(1.8 + 0.5 * k, 0.18, -2.35), CREAM)
			end
		end)

		------------------------------------------------------------------
		-- BALL COVERS (props): spiny plate over the tucked face + belly
		-- quills, shown only while curled into a ball
		------------------------------------------------------------------
		local nc = 0
		local function cover(size, at, col)
			nc += 1
			B:block(body, size, at, col, { tr = 1, name = "BallCover" .. nc })
		end
		cover(v(5.8, 4.2, 0.5), cf(0, 4.5, -3.95), SKIN)
		cover(v(4.4, 5.8, 0.4), cf(0, 4.5, -3.85), SKIN)
		local function coverQuill(s)
			local d = (s - C).Unit
			local m = math.max(math.abs(d.X), math.abs(d.Y), math.abs(d.Z))
			local d1 = math.min(1.5, 0.96 * (1.6 + 1.15) / 2 / m)
			local d2 = d1 + math.min(1.05, 0.96 * (1.15 + 0.75) / 2 / m)
			cover(v(1.6, 1.6, 1.6), CFrame.new(s + d * 0.1), SP0)
			cover(v(1.15, 1.15, 1.15), CFrame.new(s + d * (0.1 + d1)), SP1)
			cover(v(0.75, 0.75, 0.75), CFrame.new(s + d * (0.1 + d2)), SP2)
		end
		for _, p in { { 0, 6.3 }, { 2.2, 5.2 }, { -2.2, 5.2 }, { 0, 4.1 }, { 1.9, 2.8 }, { -1.9, 2.8 } } do
			coverQuill(v(p[1], p[2], -4.0))
		end
		for _, p in { { 50, 180 }, { 76, 180 }, { 98, 150 }, { 98, -150 }, { 122, 180 }, { 148, 155 }, { 148, -155 } } do
			coverQuill((surf(p[1], p[2], 0)))
		end

		------------------------------------------------------------------
		-- props + FX
		------------------------------------------------------------------
		-- berry snack for the munch gag (on its own free bone)
		local snack = B:bone("Snack", "Root", v(0, 0.5, -8.0))
		B:block(snack, v(1.0, 1.0, 1.0), cf(0, 0.5, -8.0), BERRY, { tr = 1, name = "Berry" })
		B:block(snack, v(0.8, 0.25, 0.5), cf(0, 1.1, -8.0), LEAF, { tr = 1, name = "BerryLeaf" })

		local aura = B:block(body, v(7, 6, 7), cf(0, 5.0, 0.6), FUR, { tr = 1, name = "AuraFX" })
		B:emitter(aura, "leaf", { name = "Leaves", color = { LEAF, "#9be05a" }, rate = 1.0, size = { 0.45, 0.45, 0.3 } })
		B:emitter(aura, "sparkle", { name = "Sparkle", color = { "#ffffff", NEON }, rate = 2.0 })
		B:emitter(aura, "burst", {
			name = "QuillBurst", color = { SP2, NEON, SP1 }, speed = { 10, 18 }, size = { 0.7, 0.5, 0 }, spread = 180,
		})
		B:light(aura, { name = "BristleLight", color = NEON, brightness = 0, range = 12 })
		local ground = B:block("Root", v(7, 0.2, 8), cf(0, 0.1, 0.4), FUR, { tr = 1, name = "GroundFX" })
		B:emitter(ground, "dust", {
			name = "StompDust", color = { "#efe2c8", "#cdb98f" }, size = { 2.0, 3.6, 4.6 }, speed = { 8, 14 },
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

		-- floating voxel cubes: berry cubes + leaf cubes
		local orbit = B:bone("Orbit", "Root", v(0, 5, 0.4))
		local spots = { { 7.0, 7.0, -2.5 }, { -6.8, 5.0, 1.5 }, { 6.4, 3.8, 4.0 }, { -6.4, 8.0, -3.0 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = i % 2 == 0 and 0.9 or 1.1
			local at = cf(p[1], p[2], p[3])
			if i % 2 == 1 then
				B:block(ob, v(s, s, s), at, BERRY)
				B:block(ob, v(s + 0.1, 0.3, s + 0.1), at * CFrame.new(0, s * 0.42, 0), LEAF)
				B:block(ob, v(0.28, 0.28, 0.28), at * CFrame.new(0, s * 0.7, 0), NEON, { mat = "Neon" })
			else
				B:block(ob, v(s, s, s), at, VINE)
				B:block(ob, v(s + 0.1, 0.22, s + 0.1), at, NEON, { mat = "Neon" })
			end
		end

		-- slam shockwave: chunky dirt slabs with a leafy top (one bone each)
		local SC = v(0, 0.35, -2.5)
		for k = 1, 8 do
			local a = (k - 1) / 8 * 360
			local sb = B:bone("Shock" .. k, "Root", SC)
			local at = CFrame.new(SC) * P.ang(0, a, 0) * CFrame.new(0, 0, -3.0)
			B:block(sb, v(2.4, 0.7, 1.4), at, FURD, { tr = 1, name = "Wave" .. k })
			B:block(sb, v(2.0, 0.25, 1.0), at * CFrame.new(0, 0.45, 0), LEAF, { tr = 1, name = "WaveTop" .. k })
		end
	end,
}
