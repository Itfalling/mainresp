--!nocheck
-- Widow Queen: a stud-built spider queen in the Void Leviathan style.
-- Colour blocking: glossy black + lifted charcoal shades, a big crimson mass
-- (head plate, abdomen dome, side panels, cheeks, leg bands), light lavender
-- horns / crown spires / fangs / belly plates / leg tips, white block teeth in
-- a black mouth, and only small red neon accents (8 eyes, horn + spire tips).
-- 8 three-bone legs, chelicerae fang bones, jaw, brows, a wobbly crown,
-- orbiting voxel cubes, and a strike VFX kit (expanding voxel shock rings,
-- popping debris blocks, ground flash) revealed on the ambush impact.
--
-- NOTE: the leg rest geometry (LEGS table) is mirrored in motion.luau, which
-- uses it to keep the feet planted on the ground. Keep both in sync.
return {
	DisplayName = "Widow Queen",
	Rarity = "Mythic",
	Element = "Shadow",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local BLACK, CHAR, CHAR2 = "#1c1c24", "#3b3b50", "#5a5a74"
		local CRIM, CRIMD = "#d1123f", "#8c0b2b"
		local LIGHT, LIGHT2, WHITE = "#ddd3ea", "#b4a7cc", "#f6f2fb"
		local MOUTH, TONGUE = "#0b0a10", "#e0446a"
		local NEON = "#ff1438"

		-- CFrame.lookAt in the offline (Lune) runtime returns a wrongly oriented
		-- matrix, so P.span / B:beam / B:spike tilt parts the wrong way. These
		-- local versions build the frame with CFrame.fromMatrix instead.
		local function span(a, b)
			local d = b - a
			local f = d.Unit
			local up = Vector3.new(0, 1, 0)
			if math.abs(f:Dot(up)) > 0.98 then
				up = Vector3.new(0, 0, 1)
			end
			local right = f:Cross(up).Unit
			local up2 = right:Cross(f).Unit
			return CFrame.fromMatrix((a + b) / 2, right, up2, -f), d.Magnitude
		end
		local function beam(bone, a, b, w, h, color, opts)
			local c, len = span(a, b)
			return B:block(bone, v(w, h or w, len), c, color, opts)
		end
		local function spike(bone, a, b, w, d, color, opts)
			local c, len = span(a, b)
			d = d or w
			B:wedge(bone, v(w, d / 2, len), c * CFrame.new(0, d / 4, 0), color, opts)
			B:wedge(bone, v(w, d / 2, len), c * CFrame.new(0, -d / 4, 0) * CFrame.Angles(0, 0, math.pi), color, opts)
		end
		local function neon(bone, size, c, name)
			return B:block(bone, size, c, NEON, { mat = "Neon", name = name })
		end

		------------------------------------------------------------------
		-- Cephalothorax (Body)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 5, 0.3))
		B:block(body, v(6.6, 3.2, 7.0), cf(0, 5.1, -0.1), BLACK)
		B:block(body, v(5.2, 0.9, 5.6), cf(0, 7.1, 0), CHAR2)
		B:block(body, v(2.6, 0.4, 2.6), cf(0, 7.65, 0.6, 0, 45, 0), CRIM)
		B:block(body, v(5.0, 0.8, 5.4), cf(0, 3.2, -0.1), CHAR)
		B:block(body, v(2.6, 2.2, 2.6), cf(0, 5.6, 3.8), BLACK)
		-- light stepped belly plates
		B:block(body, v(4.4, 0.5, 4.8), cf(0, 2.75, -0.2), LIGHT)
		B:block(body, v(3.0, 0.5, 3.2), cf(0, 2.35, -0.2), LIGHT2)
		B:sym(function()
			B:block(body, v(0.5, 2.2, 6.2), cf(3.4, 5.2, -0.1), CRIMD)
		end)

		------------------------------------------------------------------
		-- Head: stepped voxel tiers (back mass, wide face, forehead step,
		-- crimson top plate, crimson cheek blocks), big lavender horns
		------------------------------------------------------------------
		local head = B:bone("Head", "Body", v(0, 6.6, -3.6))
		B:block(head, v(8.0, 5.4, 3.6), cf(0, 8.0, -5.2), BLACK) -- back mass
		B:block(head, v(9.0, 4.6, 2.8), cf(0, 7.6, -8.3), BLACK) -- front face
		B:block(head, v(7.6, 1.4, 3.6), cf(0, 10.55, -7.7), CHAR) -- forehead step
		B:block(head, v(6.4, 0.9, 4.4), cf(0, 11.6, -6.6), CRIM) -- crimson top plate
		B:block(head, v(6.0, 4.0, 1.4), cf(0, 7.4, -3.2), BLACK) -- neck
		B:sym(function()
			B:block(head, v(0.5, 3.4, 3.0), cf(4.1, 8.2, -5.0), CHAR2) -- side panel
			B:block(head, v(1.2, 2.4, 3.0), cf(4.9, 6.6, -8.0), CRIMD) -- cheek block
			spike(head, v(5.3, 6.9, -7.0), v(6.7, 6.3, -5.6), 0.8, 0.8, LIGHT) -- cheek frill
			-- big stepped lavender horns sweeping out + back, small neon tip
			beam(head, v(2.9, 11.0, -6.8), v(4.1, 12.9, -5.8), 1.4, 1.4, LIGHT2)
			beam(head, v(4.0, 12.7, -5.85), v(5.0, 14.2, -4.75), 1.0, 1.0, LIGHT)
			beam(head, v(4.95, 14.05, -4.85), v(5.55, 15.0, -3.7), 0.7, 0.7, LIGHT)
			neon(head, v(0.4, 0.4, 0.4), cf(5.6, 15.1, -3.6, 30, 0, -20))
		end)
		-- mouth: black slot, crimson upper lip, white block teeth (long/short)
		B:block(head, v(6.0, 1.4, 0.4), cf(0, 5.95, -9.75), MOUTH)
		B:block(head, v(5.6, 0.2, 4.0), cf(0, 5.05, -7.6), MOUTH)
		B:block(head, v(6.4, 0.45, 0.5), cf(0, 6.8, -9.8), CRIM)
		B:sym(function()
			B:block(head, v(0.55, 0.7, 0.35), cf(0.45, 6.25, -10.03), WHITE)
			B:block(head, v(0.55, 1.05, 0.35), cf(1.25, 6.08, -10.03), WHITE)
			B:block(head, v(0.55, 0.7, 0.35), cf(2.05, 6.25, -10.03), WHITE)
			B:block(head, v(0.6, 1.2, 0.35), cf(2.75, 6.0, -10.03), WHITE)
		end)
		-- eyes: 2 big framed neon eyes with slit pupils + a tight stepped row
		-- of 3 small eyes above each brow (8 eyes)
		B:sym(function(side)
			B:block(head, v(2.4, 2.6, 0.3), cf(1.65, 8.2, -9.8), CRIMD)
			neon(head, v(1.6, 1.8, 0.3), cf(1.65, 8.2, -9.95), "Eye" .. side)
			B:block(head, v(0.55, 1.4, 0.2), cf(1.65, 8.15, -10.12), MOUTH, { name = "Pupil" .. side })
			B:block(head, v(1.9, 0.45, 0.3), cf(1.65, 8.0, -10.0), BLACK, { name = "Shut" .. side, tr = 1 })
			neon(head, v(0.6, 0.6, 0.6), cf(0.75, 10.4, -9.6), "EyeS" .. side)
			neon(head, v(0.6, 0.6, 0.6), cf(1.65, 10.65, -9.6), "EyeM" .. side)
			neon(head, v(0.6, 0.6, 0.6), cf(2.55, 10.9, -9.6), "EyeL" .. side)
		end)
		local faceFX = B:block(head, v(3, 1, 0.5), cf(0, 6.5, -10.6), BLACK, { tr = 1, name = "FaceFX" })
		B:light(faceFX, { name = "FaceLight", color = NEON, brightness = 0.01, range = 7 })
		B:emitter(faceFX, "ember", { name = "RageEmbers", color = { NEON, "#ffd0d8" }, rate = 14, enabled = false })

		-- brows (heavy angry blocks, animated)
		B:sym(function(side)
			local brow = B:bone("Brow" .. side, "Head", v(1.65, 9.6, -9.9))
			B:block(brow, v(3.2, 0.9, 0.9), cf(1.7, 9.6, -10.0, 0, 0, 16), CHAR2)
		end)

		-- jaw (lower lip with teeth, opens wide on the ambush)
		local jaw = B:bone("Jaw", "Head", v(0, 5.9, -5.0))
		B:block(jaw, v(5.2, 1.4, 4.6), cf(0, 4.85, -7.3), BLACK)
		B:block(jaw, v(4.4, 0.4, 3.4), cf(0, 3.95, -7.3), CRIMD)
		B:block(jaw, v(4.6, 0.3, 4.0), cf(0, 5.6, -7.5), MOUTH)
		B:block(jaw, v(2.4, 0.3, 2.8), cf(0, 5.75, -8.0), TONGUE)
		B:block(jaw, v(3.6, 0.25, 0.3), cf(0, 5.8, -5.9), NEON, { mat = "Neon" }) -- throat glow
		B:sym(function()
			B:block(jaw, v(0.55, 0.65, 0.35), cf(0.85, 5.8, -9.75), WHITE)
			B:block(jaw, v(0.55, 0.85, 0.35), cf(1.95, 5.9, -9.75), WHITE)
		end)

		-- chelicerae: crimson base + a 2-step bone-white hook fang
		B:sym(function(side)
			local fang = B:bone("Fang" .. side, "Head", v(3.3, 5.3, -8.6))
			B:block(fang, v(1.5, 1.5, 1.5), cf(3.3, 4.6, -8.9), CRIMD)
			beam(fang, v(3.3, 4.1, -9.1), v(2.75, 1.9, -10.0), 1.2, 1.2, LIGHT)
			spike(fang, v(2.8, 2.25, -10.0), v(1.7, 0.8, -10.1), 0.85, 0.85, WHITE)
			B:trail(fang, v(2.0, 1.25, -10.1), v(1.7, 0.8, -10.1), { name = "FangTrail" .. side, color = { "#ffffff", CRIM }, life = 0.22, trans = { 0.3, 1 } })
		end)

		------------------------------------------------------------------
		-- Crown: black ring with stepped lavender spires
		------------------------------------------------------------------
		local crown = B:bone("Crown", "Head", v(0, 12.05, -6.4))
		B:block(crown, v(5.2, 0.9, 0.7), cf(0, 12.4, -8.4), BLACK)
		B:block(crown, v(5.2, 0.9, 0.7), cf(0, 12.4, -4.4), BLACK)
		B:sym(function()
			B:block(crown, v(0.7, 0.9, 3.4), cf(2.25, 12.4, -6.4), BLACK)
			B:block(crown, v(1.0, 1.2, 0.8), cf(2.25, 13.4, -8.4), LIGHT)
			B:block(crown, v(0.7, 1.0, 0.6), cf(2.25, 14.4, -8.4), LIGHT)
			B:block(crown, v(0.6, 0.8, 0.6), cf(1.15, 13.2, -8.4), LIGHT2)
			B:block(crown, v(0.7, 1.0, 0.7), cf(2.25, 13.3, -6.4), LIGHT2)
			B:block(crown, v(0.6, 0.8, 0.6), cf(2.25, 13.2, -4.4), LIGHT2)
		end)
		B:block(crown, v(1.2, 1.2, 1.0), cf(0, 13.4, -8.4), LIGHT)
		B:block(crown, v(0.9, 1.0, 0.8), cf(0, 14.45, -8.4), LIGHT)
		B:block(crown, v(0.6, 0.9, 0.6), cf(0, 15.35, -8.4), LIGHT)
		neon(crown, v(0.4, 0.4, 0.4), cf(0, 15.95, -8.4))
		neon(crown, v(0.9, 0.5, 0.2), cf(0, 12.4, -8.8))

		------------------------------------------------------------------
		-- Abdomen: big stepped voxel egg, crimson dome + side panels,
		-- light belly plates, black rear cap with crimson hourglass, spikes
		------------------------------------------------------------------
		local abd = B:bone("Abdomen", "Body", v(0, 5.8, 3.6))
		-- slices front -> back: z, depth, width, height, centre y, colour
		local slices = {
			{ 4.8, 2.0, 5.0, 4.0, 7.4, BLACK },
			{ 6.7, 1.8, 7.4, 6.0, 7.8, BLACK },
			{ 8.0, 0.8, 9.2, 7.8, 8.1, CRIM },
			{ 10.4, 4.0, 9.8, 8.4, 8.2, BLACK },
			{ 12.8, 0.8, 9.2, 7.8, 8.2, CRIM },
			{ 14.1, 1.8, 7.4, 6.0, 8.2, BLACK },
			{ 15.7, 1.4, 5.2, 4.2, 8.3, BLACK },
		}
		for _, s in slices do
			B:block(abd, v(s[3], s[4], s[2]), cf(0, s[5], s[1]), s[6])
		end
		-- crimson stepped dome on top
		B:block(abd, v(8.0, 0.8, 6.0), cf(0, 12.7, 10.4), CRIM)
		B:block(abd, v(5.6, 0.7, 4.0), cf(0, 13.4, 10.4), CRIMD)
		B:block(abd, v(3.0, 0.6, 1.6), cf(0, 13.95, 10.4), CRIM)
		B:block(abd, v(5.4, 0.6, 1.6), cf(0, 11.05, 6.7), CRIMD)
		B:block(abd, v(5.4, 0.6, 1.6), cf(0, 11.45, 14.1), CRIMD)
		-- light stepped belly plates
		B:block(abd, v(6.4, 0.6, 4.6), cf(0, 3.75, 10.4), LIGHT)
		B:block(abd, v(4.6, 0.6, 1.8), cf(0, 4.1, 7.2), LIGHT2)
		B:block(abd, v(4.0, 0.6, 1.8), cf(0, 4.3, 13.6), LIGHT2)
		-- crimson side panels with a darker outer step
		B:sym(function()
			B:block(abd, v(0.6, 5.0, 3.6), cf(5.05, 8.2, 10.4), CRIM)
			B:block(abd, v(0.4, 3.0, 2.0), cf(5.45, 8.0, 10.4), CRIMD)
		end)
		-- stepped rear cap with the hourglass
		B:block(abd, v(3.6, 3.6, 0.6), cf(0, 8.3, 16.7), BLACK)
		local hg = { { 3.0, 9.7 }, { 2.0, 9.0 }, { 1.0, 8.3 }, { 2.0, 7.6 }, { 3.0, 6.9 } }
		for _, r in hg do
			B:block(abd, v(r[1], 0.7, 0.3), cf(0, r[2], 17.1), CRIM)
		end
		-- dorsal spikes (black base, tall lavender spike, a couple glow tips)
		local function dspike(y, z, h, glow)
			B:block(abd, v(1.3, 0.6, 1.3), cf(0, y + 0.3, z), BLACK)
			spike(abd, v(0, y + 0.5, z), v(0, y + 0.6 + h, z + 0.8), 1.2, 1.2, LIGHT)
			if glow then
				neon(abd, v(0.32, 0.32, 0.32), cf(0, y + 0.55 + h, z + 0.76))
			end
		end
		dspike(11.35, 6.6, 1.8, false)
		dspike(13.75, 8.8, 2.2, true)
		dspike(14.25, 10.4, 2.4, false)
		dspike(13.75, 12.0, 2.2, true)
		dspike(11.75, 14.2, 1.8, false)
		-- side spikes
		B:sym(function()
			for _, z in { 9.4, 11.4 } do
				spike(abd, v(5.5, 9.8, z), v(7.1, 11.1, z + 0.5), 0.8, 0.8, LIGHT)
			end
		end)
		local wisp = B:block(abd, v(7, 5, 8), cf(0, 8.3, 10.4), BLACK, { tr = 1, name = "AbdomenFX" })
		B:emitter(wisp, "smoke", { name = "Wisps", color = { "#2a1622", "#120b12" }, rate = 3 })
		B:emitter(wisp, "sparkle", { name = "Motes", color = { "#ffffff", NEON }, rate = 6, size = { 0.4, 0 } })

		------------------------------------------------------------------
		-- Legs: 4 per side, 3 bones each (femur up to a high knee, tibia
		-- down-out, tarsus to a lavender tip). Bones are yawed so local +X
		-- runs along the leg: +Z = raise, +Y = swing forward.
		-- Two-tone: charcoal femur, black tibia/tarsus, crimson bands + knees.
		------------------------------------------------------------------
		local LEGS = {
			{ z = -1.9, yaw = -44, knee = { 4.2, 10.2 }, ankle = { 8.9, 4.4 }, tip = { 11.0, 0.1 } },
			{ z = -0.5, yaw = -15, knee = { 4.0, 9.7 }, ankle = { 8.4, 4.1 }, tip = { 10.4, 0.1 } },
			{ z = 0.9, yaw = 16, knee = { 4.0, 9.5 }, ankle = { 8.4, 4.0 }, tip = { 10.4, 0.1 } },
			{ z = 2.3, yaw = 46, knee = { 4.2, 9.9 }, ankle = { 8.9, 4.2 }, tip = { 11.0, 0.1 } },
		}
		B:sym(function(side)
			for i, L in LEGS do
				local hip = v(3.3, 5.3, L.z)
				local a = math.rad(L.yaw)
				local dir = v(math.cos(a), 0, math.sin(a))
				local function lp(r, y)
					return v(hip.X + dir.X * r, y, hip.Z + dir.Z * r)
				end
				local rot = P.ang(0, -L.yaw, 0)
				local knee = lp(L.knee[1], L.knee[2])
				local ankle = lp(L.ankle[1], L.ankle[2])
				local tip = lp(L.tip[1], L.tip[2])
				local n = "Leg" .. i

				local A = B:bone(n .. "A" .. side, "Body", CFrame.new(hip) * rot)
				local fs = lp(-0.4, 5.3)
				beam(A, fs, knee, 1.4, 1.4, CHAR)
				beam(A, fs:Lerp(knee, 0.6), fs:Lerp(knee, 0.8), 1.55, 1.55, CRIM)
				spike(A, knee + v(0, 0.6, 0), knee + v(0, 2.6, 0) + dir * 0.9, 0.85, 0.85, LIGHT)

				local Bn = B:bone(n .. "B" .. side, n .. "A" .. side, CFrame.new(knee) * rot)
				B:block(Bn, v(1.8, 1.8, 1.8), CFrame.new(knee) * rot, CRIMD)
				beam(Bn, knee, ankle, 1.2, 1.2, BLACK)
				beam(Bn, knee:Lerp(ankle, 0.68), knee:Lerp(ankle, 0.86), 1.35, 1.35, CRIM)
				if i == 1 or i == 4 then
					local hs = knee:Lerp(ankle, 0.36) + dir * 0.35 + v(0, 0.3, 0)
					spike(Bn, hs, hs + dir * 1.1 + v(0, 0.9, 0), 0.55, 0.55, LIGHT2)
				end

				local C = B:bone(n .. "C" .. side, n .. "B" .. side, CFrame.new(ankle) * rot)
				B:block(C, v(1.35, 1.35, 1.35), CFrame.new(ankle) * rot, CHAR)
				beam(C, ankle, ankle:Lerp(tip, 0.56), 1.0, 1.0, BLACK)
				spike(C, ankle:Lerp(tip, 0.5), tip, 0.95, 0.95, LIGHT)
				if i <= 2 then
					B:trail(C, tip + v(0, 0.9, 0), tip + v(0, 0.1, 0), { name = "TipTrail" .. i .. side, color = { "#ffffff", CRIM }, life = 0.25, trans = { 0.35, 1 } })
				end
			end
		end)

		------------------------------------------------------------------
		-- Strike FX (ground in front of the face), all hidden until impact:
		--  * ground flash (white core on a crimson diamond)
		--  * 2 voxel shock rings (crimson + neon top strip, lavender outer),
		--    one bone per segment so the motion slides them outward
		--  * 6 debris blocks on their own bones that pop up and tumble
		------------------------------------------------------------------
		local SZ = -13
		local SC = v(0, 0.2, SZ)
		local shock = B:bone("Shock", "Root", SC)
		local sfx = B:block(shock, v(6, 0.2, 4), cf(0, 0.2, SZ), BLACK, { tr = 1, name = "StrikeFX" })
		B:emitter(sfx, "burst", { name = "AmbushBurst", color = { "#ffffff", NEON, CRIMD }, size = { 1.2, 0 } })
		B:emitter(sfx, "dust", { name = "AmbushDust", color = "#cfc6b8" })
		B:light(sfx, { name = "StrikeLight", color = NEON, brightness = 0.01, range = 16 })
		B:block(shock, v(7.0, 0.12, 7.0), cf(0, 0.08, SZ, 0, 45, 0), CRIM, { tr = 1, name = "Flash" })
		B:block(shock, v(4.2, 0.16, 4.2), cf(0, 0.12, SZ), WHITE, { tr = 1, name = "FlashCore" })
		for k = 1, 10 do
			local a = (k - 1) / 10 * 360
			local wb = B:bone("Wave" .. k, "Root", SC)
			local base = CFrame.new(SC) * P.ang(0, a, 0)
			B:block(wb, v(1.5, 0.4, 1.0), base * CFrame.new(0, 0, -2.2), CRIM, { tr = 1, name = "RingA_" .. k })
			B:block(wb, v(1.3, 0.2, 0.45), base * CFrame.new(0, 0.28, -2.2), NEON, { mat = "Neon", tr = 1, name = "RingN_" .. k })
			B:block(wb, v(2.4, 0.4, 1.0), base * CFrame.new(0, 0, -4.2), LIGHT, { tr = 1, name = "RingB_" .. k })
		end
		local DEBRIS = {
			{ 1.6, -1.2, 1.2, CRIM }, { -1.8, -0.6, 1.0, BLACK }, { 0.6, 1.9, 1.1, CHAR },
			{ -0.9, 1.6, 0.8, CRIM }, { 2.3, 0.9, 0.9, BLACK }, { -2.4, -1.9, 1.2, CRIMD },
		}
		for i, d in DEBRIS do
			local p = v(d[1], 0.6, SZ + d[2])
			local db = B:bone("Debris" .. i, "Root", p)
			B:block(db, v(d[3], d[3], d[3]), CFrame.new(p), d[4], { tr = 1, name = "Debris" .. i })
		end
		local feet = B:block("Root", v(16, 0.2, 16), cf(0, 0.1, 0), BLACK, { tr = 1, name = "FeetFX" })
		B:emitter(feet, "dust", { name = "SplayDust", color = "#d6cec2" })

		------------------------------------------------------------------
		-- Floating voxel cubes (black / crimson / charcoal) orbiting the queen
		------------------------------------------------------------------
		B:bone("Orbit", "Root", v(0, 9, 3))
		local spots = {
			{ 10.5, 10.5, 1 }, { -9.5, 12.5, 6 }, { 6.5, 14.0, 11 }, { -8.0, 8.5, -6 },
			{ 4.0, 12.5, -9 }, { -6.0, 7.5, 13 }, { 11.0, 7.5, 7 },
		}
		local sizes = { 1.7, 1.3, 1.0, 1.7, 1.3, 1.0, 1.7 }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = sizes[i]
			local main = (i % 2 == 0) and CRIM or BLACK
			local band = (i % 2 == 0) and BLACK or CRIM
			B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), main)
			B:block(ob, v(s + 0.1, s * 0.28, s + 0.1), cf(p[1], p[2], p[3]), band)
			if i % 2 == 1 then
				neon(ob, v(s + 0.14, 0.14, s + 0.14), cf(p[1], p[2], p[3]))
			end
		end
	end,
}
