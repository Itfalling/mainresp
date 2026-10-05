--!nocheck
-- Widow Queen: a stud-built spider queen. Glossy black + charcoal voxel body,
-- crimson colour-blocked hourglass / stripes / leg bands, bone-white fangs,
-- teeth, spikes and crown, and only tiny red neon accents (8 eyes + tips).
-- 8 three-bone legs, chelicerae fang bones, a jaw, brows, a wobbly crown and
-- orbiting black/crimson voxel cubes.
--
-- NOTE: the leg rest geometry (LEGS table) is mirrored in motion.luau, which
-- uses it to keep the feet planted on the ground. Keep both in sync.
return {
	DisplayName = "Widow Queen",
	Rarity = "Mythic",
	Element = "Shadow",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local BLACK, CHAR, CHAR2 = "#1c1c24", "#2e2e3a", "#434356"
		local CRIM, CRIMD = "#d1123f", "#8c0b2b"
		local BONE, BONE2 = "#f4ede4", "#d8cdc2"
		local MOUTH, TONGUE = "#0b0a10", "#e0446a"
		local NEON = "#ff2a4d"

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
		B:block(body, v(2.4, 0.4, 2.4), cf(0, 7.65, 0.6, 0, 45, 0), CRIM)
		B:block(body, v(5.0, 0.8, 5.4), cf(0, 3.2, -0.1), CHAR)
		B:block(body, v(2.6, 2.2, 2.6), cf(0, 5.6, 3.8), BLACK)
		B:sym(function()
			B:block(body, v(0.5, 2.2, 6.2), cf(3.4, 5.2, -0.1), CHAR)
		end)

		------------------------------------------------------------------
		-- Head (big cartoon face)
		------------------------------------------------------------------
		local head = B:bone("Head", "Body", v(0, 6.6, -3.6))
		B:block(head, v(9.0, 5.6, 6.0), cf(0, 7.9, -6.6), BLACK)
		B:block(head, v(6.0, 4.0, 1.4), cf(0, 7.4, -3.2), BLACK)
		B:block(head, v(7.2, 1.0, 4.6), cf(0, 11.2, -6.4), CHAR2)
		B:sym(function()
			B:block(head, v(0.6, 3.4, 4.6), cf(4.75, 7.6, -6.4), CHAR)
		end)
		-- mouth: black slot, crimson upper lip, white block teeth
		B:block(head, v(6.0, 1.4, 0.4), cf(0, 5.95, -9.7), MOUTH)
		B:block(head, v(5.6, 0.2, 4.0), cf(0, 5.05, -7.6), MOUTH)
		B:block(head, v(6.4, 0.45, 0.5), cf(0, 6.8, -9.75), CRIM)
		B:sym(function()
			B:block(head, v(0.55, 0.65, 0.35), cf(0.5, 6.3, -9.98), BONE)
			B:block(head, v(0.55, 0.6, 0.35), cf(1.45, 6.32, -9.98), BONE)
			B:block(head, v(0.6, 1.05, 0.35), cf(2.45, 6.1, -9.98), BONE)
		end)
		-- eyes: 8 small neon blocks (2 big + 2 medium + 2 small + 2 lateral)
		B:sym(function(side)
			neon(head, v(2.0, 2.2, 0.4), cf(1.65, 8.2, -9.7), "Eye" .. side)
			B:block(head, v(0.8, 1.5, 0.2), cf(1.4, 8.0, -9.95), MOUTH, { name = "Pupil" .. side })
			B:block(head, v(2.1, 0.4, 0.3), cf(1.65, 7.9, -9.8), CRIM, { name = "Shut" .. side, tr = 1 })
			neon(head, v(1.0, 1.0, 0.4), cf(3.65, 9.0, -9.7), "EyeM" .. side)
			neon(head, v(0.7, 0.7, 0.4), cf(0.7, 10.25, -9.7), "EyeS" .. side)
			neon(head, v(0.3, 0.8, 0.8), cf(5.1, 8.8, -7.8), "EyeL" .. side)
		end)
		local faceFX = B:block(head, v(3, 1, 0.5), cf(0, 6.5, -10.6), BLACK, { tr = 1, name = "FaceFX" })
		B:light(faceFX, { name = "FaceLight", color = NEON, brightness = 0.01, range = 7 })
		B:emitter(faceFX, "ember", { name = "RageEmbers", color = { NEON, "#ffd0d8" }, rate = 14, enabled = false })

		-- brows (angry crimson blocks, animated)
		B:sym(function(side)
			local brow = B:bone("Brow" .. side, "Head", v(1.65, 9.4, -9.9))
			B:block(brow, v(3.0, 0.85, 0.7), cf(1.7, 9.35, -10.0, 0, 0, 16), CHAR2)
		end)

		-- jaw (lower lip with teeth, opens wide on the ambush)
		local jaw = B:bone("Jaw", "Head", v(0, 5.9, -5.0))
		B:block(jaw, v(5.2, 1.4, 4.6), cf(0, 4.85, -7.3), BLACK)
		B:block(jaw, v(4.4, 0.4, 3.4), cf(0, 3.95, -7.3), CHAR)
		B:block(jaw, v(4.6, 0.3, 4.0), cf(0, 5.6, -7.5), MOUTH)
		B:block(jaw, v(2.4, 0.3, 2.8), cf(0, 5.75, -8.0), TONGUE)
		B:sym(function()
			B:block(jaw, v(0.55, 0.6, 0.35), cf(0.9, 5.8, -9.75), BONE)
			B:block(jaw, v(0.55, 0.75, 0.35), cf(1.9, 5.85, -9.75), BONE)
		end)

		-- chelicerae fangs
		B:sym(function(side)
			local fang = B:bone("Fang" .. side, "Head", v(3.3, 5.3, -8.6))
			B:block(fang, v(1.8, 2.0, 1.8), cf(3.3, 4.5, -8.6), CHAR)
			B:block(fang, v(1.9, 0.5, 1.9), cf(3.3, 3.4, -8.6), CRIM)
			B:block(fang, v(1.3, 1.1, 1.3), cf(3.2, 2.65, -8.7), BLACK)
			spike(fang, v(3.15, 2.3, -8.75), v(2.3, 0.6, -9.6), 1.0, 1.0, BONE)
			B:trail(fang, v(2.3, 1.0, -9.5), v(2.4, 0.5, -9.7), { name = "FangTrail" .. side, color = { "#ffffff", CRIM }, life = 0.22, trans = { 0.3, 1 } })
		end)

		------------------------------------------------------------------
		-- Crown
		------------------------------------------------------------------
		local crown = B:bone("Crown", "Head", v(0, 11.7, -6.4))
		B:block(crown, v(5.0, 1.0, 0.6), cf(0, 12.2, -8.4), CRIM)
		B:block(crown, v(5.0, 1.0, 0.6), cf(0, 12.2, -4.4), CRIMD)
		B:sym(function()
			B:block(crown, v(0.6, 1.0, 3.4), cf(2.2, 12.2, -6.4), CRIMD)
			B:block(crown, v(0.75, 1.0, 0.6), cf(2.2, 13.2, -8.4), BONE)
			B:block(crown, v(0.45, 0.6, 0.4), cf(2.2, 13.95, -8.4), BONE)
			B:block(crown, v(0.55, 0.7, 0.5), cf(1.1, 13.05, -8.4), BONE2)
			B:block(crown, v(0.6, 0.8, 0.6), cf(2.2, 13.1, -6.4), BONE2)
			B:block(crown, v(0.6, 0.7, 0.6), cf(2.2, 13.05, -4.4), BONE2)
		end)
		B:block(crown, v(0.9, 1.1, 0.6), cf(0, 13.25, -8.4), BONE)
		B:block(crown, v(0.55, 0.9, 0.45), cf(0, 14.2, -8.4), BONE)
		neon(crown, v(0.35, 0.35, 0.35), cf(0, 14.82, -8.4))
		neon(crown, v(0.8, 0.55, 0.2), cf(0, 12.2, -8.75))

		------------------------------------------------------------------
		-- Abdomen (big stepped egg with crimson pattern + spikes)
		------------------------------------------------------------------
		local abd = B:bone("Abdomen", "Body", v(0, 5.8, 3.6))
		-- voxel egg built from slices front -> back, crimson bands between them
		local slices = {
			{ 4.8, 2.0, 5.2, 4.4, 7.4, BLACK },
			{ 6.7, 1.8, 7.8, 6.4, 7.8, CHAR },
			{ 8.0, 0.8, 9.0, 7.4, 8.0, CRIM },
			{ 10.4, 4.0, 9.8, 8.0, 8.2, BLACK },
			{ 12.8, 0.8, 9.0, 7.4, 8.3, CRIM },
			{ 14.1, 1.8, 7.8, 6.6, 8.4, CHAR },
			{ 15.7, 1.4, 5.6, 5.0, 8.4, BLACK },
		}
		for _, s in slices do
			B:block(abd, v(s[3], s[4], s[2]), cf(0, s[5], s[1]), s[6])
		end
		-- stepped dome on top, side + belly plates
		B:block(abd, v(7.0, 0.8, 3.4), cf(0, 12.6, 10.4), CHAR)
		B:block(abd, v(4.2, 0.6, 2.4), cf(0, 13.3, 10.4), CRIM)
		B:block(abd, v(5.4, 0.6, 1.6), cf(0, 11.3, 6.7), CHAR)
		B:block(abd, v(5.4, 0.6, 1.6), cf(0, 12.0, 14.1), CHAR)
		B:block(abd, v(6.4, 0.6, 3.0), cf(0, 3.9, 10.4), CHAR)
		B:sym(function()
			B:block(abd, v(0.6, 5.0, 3.0), cf(5.2, 8.2, 10.4), CHAR2)
		end)
		-- rear hourglass
		local hg = { { 3.4, 0.9, 10.15 }, { 2.4, 0.8, 9.3 }, { 1.2, 0.9, 8.45 }, { 2.4, 0.8, 7.6 }, { 3.4, 0.9, 6.75 } }
		for _, r in hg do
			B:block(abd, v(r[1], r[2], 0.3), cf(0, r[3], 16.5), CRIM)
		end
		-- dorsal spikes
		local function dspike(y, z, h, glow)
			B:block(abd, v(1.3, 0.6, 1.3), cf(0, y + 0.3, z), CRIMD)
			spike(abd, v(0, y + 0.5, z), v(0, y + 0.6 + h, z + 0.7), 1.2, 1.2, BONE)
			if glow then
				neon(abd, v(0.3, 0.3, 0.3), cf(0, y + 0.55 + h, z + 0.66))
			end
		end
		dspike(11.6, 6.7, 1.1, false)
		dspike(13.6, 9.6, 1.5, true)
		dspike(13.6, 11.4, 1.3, false)
		dspike(12.3, 14.1, 1.1, false)
		-- side spikes
		B:sym(function()
			for _, z in { 9.4, 11.4 } do
				B:block(abd, v(0.6, 1.0, 1.0), cf(5.6, 9.6, z), CRIMD)
				spike(abd, v(5.7, 9.7, z), v(7.1, 10.8, z + 0.4), 0.8, 0.8, BONE)
			end
		end)
		local wisp = B:block(abd, v(7, 5, 8), cf(0, 8.3, 10.4), BLACK, { tr = 1, name = "AbdomenFX" })
		B:emitter(wisp, "smoke", { name = "Wisps", color = { "#2a1622", "#120b12" }, rate = 3 })
		B:emitter(wisp, "sparkle", { name = "Motes", color = { "#ffffff", NEON }, rate = 4 })

		------------------------------------------------------------------
		-- Legs: 4 per side, 3 bones each (femur up to a high knee, tibia
		-- down-out, tarsus to a bone-white tip). Bones are yawed so local +X
		-- runs along the leg: +Z = raise, +Y = swing forward.
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
				beam(A, fs, knee, 1.4, 1.4, BLACK)
				beam(A, fs:Lerp(knee, 0.6), fs:Lerp(knee, 0.8), 1.55, 1.55, CRIM)
				spike(A, knee + v(0, 0.6, 0), knee + v(0, 2.4, 0) + dir * 0.8, 0.8, 0.8, BONE)

				local Bn = B:bone(n .. "B" .. side, n .. "A" .. side, CFrame.new(knee) * rot)
				B:block(Bn, v(1.7, 1.7, 1.7), CFrame.new(knee) * rot, CHAR)
				beam(Bn, knee, ankle, 1.2, 1.2, BLACK)
				beam(Bn, knee:Lerp(ankle, 0.7), knee:Lerp(ankle, 0.86), 1.35, 1.35, CRIM)
				local hs = knee:Lerp(ankle, 0.36) + dir * 0.35 + v(0, 0.3, 0)
				spike(Bn, hs, hs + dir * 1.1 + v(0, 0.9, 0), 0.55, 0.55, BONE2)

				local C = B:bone(n .. "C" .. side, n .. "B" .. side, CFrame.new(ankle) * rot)
				B:block(C, v(1.3, 1.3, 1.3), CFrame.new(ankle) * rot, CHAR)
				beam(C, ankle, ankle:Lerp(tip, 0.56), 1.0, 1.0, BLACK)
				spike(C, ankle:Lerp(tip, 0.5), tip, 0.95, 0.95, BONE)
				if i <= 2 then
					B:trail(C, tip + v(0, 0.9, 0), tip + v(0, 0.1, 0), { name = "TipTrail" .. i .. side, color = { "#ffffff", CRIM }, life = 0.25, trans = { 0.35, 1 } })
				end
			end
		end)

		------------------------------------------------------------------
		-- Strike FX (ground in front of the face): shock rings revealed on impact
		------------------------------------------------------------------
		local SZ = -13
		local shock = B:bone("Shock", "Root", v(0, 0.15, SZ))
		local sfx = B:block(shock, v(6, 0.2, 4), cf(0, 0.2, SZ), BLACK, { tr = 1, name = "StrikeFX" })
		B:emitter(sfx, "burst", { name = "AmbushBurst", color = { "#ffffff", NEON, CRIMD } })
		B:emitter(sfx, "dust", { name = "AmbushDust", color = "#cfc6b8" })
		B:light(sfx, { name = "StrikeLight", color = NEON, brightness = 0.01, range = 16 })
		for ring = 1, 2 do
			local r = ring == 1 and 2.6 or 4.6
			local n = ring == 1 and 8 or 10
			for k = 0, n - 1 do
				local c = CFrame.new(0, 0.15, SZ) * P.ang(0, (k / n) * 360, 0) * CFrame.new(0, 0, -r)
				B:block(shock, v(r * 0.62, 0.2, 0.45), c, ring == 1 and NEON or CRIM, { mat = ring == 1 and "Neon" or "Plastic", tr = 1, name = ("Shock%d_%d"):format(ring, k + 1) })
			end
		end
		local feet = B:block("Root", v(16, 0.2, 16), cf(0, 0.1, 0), BLACK, { tr = 1, name = "FeetFX" })
		B:emitter(feet, "dust", { name = "SplayDust", color = "#d6cec2" })

		------------------------------------------------------------------
		-- Floating voxel cubes (black / crimson) orbiting the queen
		------------------------------------------------------------------
		B:bone("Orbit", "Root", v(0, 9, 3))
		local spots = { { 10.5, 10.5, 1 }, { -9.5, 12.5, 6 }, { 6.5, 13.0, 11 }, { -8.0, 9.5, -6 }, { 4.0, 12.0, -9 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = (i % 2 == 0) and 1.3 or 1.7
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
