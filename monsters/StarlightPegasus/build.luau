--!nocheck
-- Starlight Pegasus: chunky stud-built winged horse. Pearly white body with
-- lavender shading, stepped pastel aurora mane + tail, gold hooves and armor
-- bits, big stepped white->lavender feather wings, a tiny neon star gem on the
-- forehead, goofy buck teeth and big cartoon eyes. Glow is accent only.
return {
	DisplayName = "Starlight Pegasus",
	Rarity = "Cosmic",
	Element = "Celestial",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local WHITE, SHADE, LAVD = "#f4f2ff", "#d9d0ff", "#b59bff"
		local PALE, PALE2 = "#ece8ff", "#ddd5ff"
		local PINK, CYAN = "#ff9bd8", "#8fe9ff"
		local GOLD, GOLDD = "#f2c230", "#c9941c"
		local MOUTH, TOOTH, TONGUE, PUPIL = "#1c1430", "#ffffff", "#ff6fa8", "#1a1240"
		local NEONC, NEONP = "#6ff3ff", "#ff7fe0"

		-- 4-point twinkle star (thin points + diamond core) facing `face` axis
		local function twinkle(bone, c, size, color, coreColor, face, neonCore)
			local t = size * 0.16
			if face == "x" then
				B:block(bone, v(t, size, t * 1.6), c, color)
				B:block(bone, v(t, t * 1.6, size), c, color)
				B:block(bone, v(t * 1.4, size * 0.38, size * 0.38), c * P.ang(45, 0, 0), coreColor, neonCore and { mat = "Neon" } or nil)
			else
				B:block(bone, v(size, t * 1.6, t), c, color)
				B:block(bone, v(t * 1.6, size, t), c, color)
				B:block(bone, v(size * 0.38, size * 0.38, t * 1.4), c * P.ang(0, 0, 45), coreColor, neonCore and { mat = "Neon" } or nil)
			end
		end

		------------------------------------------------------------------
		-- Body (rump, pivots at the hind hips so it can REAR UP) + chest
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 7.0, 3.4))
		B:block(body, v(5.2, 4.6, 5.4), cf(0, 7.7, 2.7), WHITE)
		B:block(body, v(4.2, 0.6, 4.0), cf(0, 10.25, 3.0), WHITE)
		B:block(body, v(4.4, 3.4, 0.6), cf(0, 7.9, 5.65), WHITE)
		B:block(body, v(4.2, 0.6, 4.6), cf(0, 5.15, 2.5), SHADE)
		-- royal gold girth band with little cyan gems
		B:block(body, v(5.6, 5.4, 0.8), cf(0, 7.9, 0.7), GOLD)
		B:sym(function()
			B:block(body, v(0.2, 0.7, 0.7), cf(2.85, 8.4, 0.7, 45, 0, 0), NEONC, { mat = "Neon" })
			B:block(body, v(0.3, 1.8, 4.8), cf(2.62, 6.2, 2.7), SHADE)
			-- twinkle-star "cutie mark" on each flank
			twinkle(body, cf(2.7, 8.4, 3.3), 2.0, PINK, LAVD, "x")
		end)

		local chest = B:bone("Chest", "Body", v(0, 7.6, 0.4))
		B:block(chest, v(5.4, 4.8, 5.0), cf(0, 7.75, -2.0), WHITE)
		B:block(chest, v(4.4, 0.6, 3.6), cf(0, 10.4, -1.4), WHITE)
		B:block(chest, v(4.4, 0.6, 4.4), cf(0, 5.2, -2.1), SHADE)
		-- stepped lavender chest plates
		B:block(chest, v(4.0, 1.0, 0.5), cf(0, 6.1, -4.6), SHADE)
		B:block(chest, v(3.0, 1.0, 0.5), cf(0, 5.3, -4.4), SHADE)
		-- gold breast collar with a tiny cyan gem
		B:block(chest, v(5.6, 0.7, 0.7), cf(0, 8.6, -4.3), GOLD)
		B:block(chest, v(1.6, 1.4, 0.4), cf(0, 7.7, -4.75), GOLD)
		B:block(chest, v(0.6, 0.6, 0.2), cf(0, 7.7, -5.0), NEONC, { mat = "Neon" })
		B:sym(function()
			B:block(chest, v(0.3, 1.8, 4.2), cf(2.72, 6.3, -2.2), SHADE)
			B:block(chest, v(0.7, 0.7, 3.2), cf(2.75, 8.6, -2.6), GOLD)
		end)
		local aura = B:block(chest, v(6, 5, 8), cf(0, 9, 0), WHITE, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "Sparkles", color = { "#ffffff", PINK, CYAN }, rate = 5 })

		------------------------------------------------------------------
		-- Neck (2 bones)
		------------------------------------------------------------------
		local neck1 = B:bone("Neck1", "Chest", v(0, 9.4, -3.6))
		B:block(neck1, v(3.8, 3.4, 3.6), cf(0, 10.6, -4.3), WHITE)
		B:block(neck1, v(2.8, 2.4, 0.4), cf(0, 10.2, -6.15), SHADE)
		local neck2 = B:bone("Neck2", "Neck1", v(0, 11.4, -5.0))
		B:block(neck2, v(3.4, 3.0, 3.2), cf(0, 12.2, -5.6), WHITE)
		B:block(neck2, v(2.4, 2.0, 0.4), cf(0, 11.9, -7.25), SHADE)

		------------------------------------------------------------------
		-- Head: authored at 1x around the pivot, scaled 1.3x for a big cartoon head
		------------------------------------------------------------------
		local HP, HS = v(0, 12.5, -6.3), 1.3
		local function H(x, y, z) return HP + v(x, y, z) * HS end
		local function hcf(x, y, z, rx, ry, rz) return CFrame.new(H(x, y, z)) * P.ang(rx or 0, ry or 0, rz or 0) end
		local function hs(x, y, z) return v(x, y, z) * HS end

		local head = B:bone("Head", "Neck2", HP)
		B:block(head, hs(4.6, 3.8, 4.2), hcf(0, 1.9, -1.2), WHITE) -- skull
		B:block(head, hs(3.2, 2.2, 3.4), hcf(0, -0.1, -4.6), WHITE) -- snout
		B:block(head, hs(2.6, 0.6, 2.4), hcf(0, 1.25, -4.0), WHITE) -- nose bridge step
		B:block(head, hs(3.4, 1.4, 0.9), hcf(0, 0.0, -6.2), SHADE) -- muzzle
		B:block(head, hs(3.0, 0.6, 3.2), hcf(0, -1.4, -4.6), MOUTH) -- open grin
		B:block(head, hs(0.75, 0.8, 0.3), hcf(0.42, -1.5, -6.08), TOOTH) -- buck teeth
		B:block(head, hs(0.75, 0.8, 0.3), hcf(-0.42, -1.5, -6.08), TOOTH)
		-- star gem on the forehead: gold setting + neon pink 4-point twinkle
		B:block(head, hs(1.0, 1.0, 0.3), hcf(0, 3.0, -3.38, 0, 0, 45), GOLD)
		local star = B:block(head, hs(0.62, 0.62, 0.2), hcf(0, 3.0, -3.56, 0, 0, 45), NEONP, { mat = "Neon", name = "StarGem" })
		B:block(head, hs(1.9, 0.22, 0.14), hcf(0, 3.0, -3.6), NEONP, { mat = "Neon" })
		B:block(head, hs(0.22, 1.9, 0.14), hcf(0, 3.0, -3.6), NEONP, { mat = "Neon" })
		B:light(star, { name = "StarLight", color = NEONP, brightness = 0.6, range = 8 })
		B:sym(function()
			B:block(head, hs(0.5, 0.3, 0.15), hcf(0.9, 0.45, -6.68), MOUTH) -- nostril
			B:block(head, hs(0.4, 0.4, 0.4), hcf(1.25, -1.3, -5.3), TOOTH)
			B:block(head, hs(0.2, 0.7, 1.2), hcf(2.35, 0.9, -2.0), PINK) -- blush
			-- big cartoon eye on the front corner: sclera, neon iris, pupil, shine
			B:block(head, hs(1.9, 2.2, 1.4), hcf(1.5, 2.25, -3.3), TOOTH)
			B:block(head, hs(1.0, 1.55, 0.2), hcf(1.6, 2.2, -4.05), NEONC, { mat = "Neon", name = "Eye" })
			B:block(head, hs(0.5, 1.0, 0.12), hcf(1.38, 2.1, -4.18), PUPIL)
			B:block(head, hs(0.3, 0.3, 0.1), hcf(1.88, 2.7, -4.19), TOOTH)
			B:block(head, hs(0.12, 1.5, 0.8), hcf(2.5, 2.2, -3.35), NEONC, { mat = "Neon" })
			B:block(head, hs(0.1, 1.0, 0.4), hcf(2.57, 2.1, -3.55), PUPIL)
		end)
		local mouthFX = B:block(head, hs(2, 1, 1), hcf(0, -0.5, -6.0), WHITE, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFX, "burst", { name = "StarBurst", color = { "#ffffff", NEONP, NEONC } })
		B:light(mouthFX, { name = "BurstLight", color = "#ffe6fb", brightness = 0, range = 16 })

		-- heavy brows that drop over the eyes for blinks
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", H(1.5, 3.9, -3.3))
			B:block(lid, hs(2.05, 1.3, 1.5), hcf(1.5, 3.9, -3.3), LAVD)
		end)

		-- ears
		B:sym(function(side)
			local EF = hcf(1.45, 3.4, -0.3, 0, 0, -18)
			local ear = B:bone("Ear" .. side, "Head", EF)
			B:block(ear, hs(1.3, 1.6, 1.0), EF * CFrame.new(hs(0, 0.75, 0)), WHITE)
			B:block(ear, hs(0.9, 0.8, 0.8), EF * CFrame.new(hs(0.05, 1.85, 0.05)), WHITE)
			B:block(ear, hs(0.5, 0.5, 0.5), EF * CFrame.new(hs(0.1, 2.45, 0.1)), SHADE)
			B:block(ear, hs(0.75, 1.5, 0.2), EF * CFrame.new(hs(0, 1.0, -0.52)), PINK)
		end)

		-- jaw (hinges at the back of the mouth)
		local jaw = B:bone("Jaw", "Head", H(0, -1.2, -2.8))
		B:block(jaw, hs(3.0, 0.9, 3.2), hcf(0, -2.05, -4.5), WHITE)
		B:block(jaw, hs(2.6, 0.4, 2.6), hcf(0, -2.6, -4.4), SHADE)
		B:block(jaw, hs(1.8, 0.3, 2.2), hcf(0, -1.5, -4.2), TONGUE)
		B:sym(function()
			B:block(jaw, hs(0.4, 0.35, 0.4), hcf(1.2, -1.45, -5.6), TOOTH)
		end)

		------------------------------------------------------------------
		-- Aurora mane: chunky stepped locks on their own bones (flow with lag)
		------------------------------------------------------------------
		local m1 = B:bone("Mane1", "Chest", v(0, 10.6, -1.6))
		B:block(m1, v(2.2, 2.0, 2.0), cf(0, 11.5, -0.9), PINK)
		B:block(m1, v(1.6, 1.1, 1.5), cf(0, 12.8, -0.2), CYAN)
		local m2 = B:bone("Mane2", "Neck1", v(0, 12.0, -3.2))
		B:block(m2, v(2.4, 2.8, 2.2), cf(0, 13.2, -2.9), CYAN)
		B:block(m2, v(1.8, 1.3, 1.8), cf(0, 15.0, -2.1), LAVD)
		B:sym(function()
			B:block(m2, v(0.5, 2.6, 2.4), cf(2.0, 11.2, -3.6), CYAN)
		end)
		local m3 = B:bone("Mane3", "Neck2", v(0, 13.5, -5.0))
		B:block(m3, v(2.4, 3.2, 2.2), cf(0, 15.0, -4.3), LAVD)
		B:block(m3, v(1.8, 1.4, 1.8), cf(0, 17.0, -3.5), PINK)
		B:sym(function()
			B:block(m3, v(0.5, 2.4, 2.2), cf(1.8, 12.9, -5.0), LAVD)
		end)
		local m4 = B:bone("Mane4", "Head", H(0, 3.8, -0.8))
		-- forelock: a chunky pompadour curling forward over the brow
		B:block(m4, hs(2.6, 1.2, 2.8), hcf(0, 4.3, -1.2), PINK)
		B:block(m4, hs(2.0, 1.1, 1.4), hcf(0, 4.6, -2.9), CYAN)

		------------------------------------------------------------------
		-- Legs: upper / lower / hoof (3 bones each)
		------------------------------------------------------------------
		local function leg(prefix, parent, x, z, upperH, side)
			local up = B:bone(prefix .. "Leg" .. side, parent, v(x, 7.0, z))
			B:block(up, v(2.3, upperH, 2.5), cf(x, 7.3 - upperH / 2, z), WHITE)
			B:block(up, v(2.4, 0.8, 2.6), cf(x, 7.3 - upperH + 0.5, z), SHADE)
			local knee = B:bone(prefix .. "Knee" .. side, prefix .. "Leg" .. side, v(x, 4.1, z))
			B:block(knee, v(1.8, 2.9, 1.8), cf(x, 2.75, z), WHITE)
			local hoof = B:bone(prefix .. "Hoof" .. side, prefix .. "Knee" .. side, v(x, 1.4, z))
			B:block(hoof, v(2.4, 0.9, 2.4), cf(x, 1.75, z), LAVD) -- fluffy fetlock
			B:block(hoof, v(2.5, 1.3, 2.7), cf(x, 0.65, z - 0.1), GOLD)
			B:block(hoof, v(2.6, 0.3, 0.2), cf(x, 0.95, z - 1.5), NEONC, { mat = "Neon" })
			B:block(hoof, v(2.7, 0.4, 2.9), cf(x, 0.2, z - 0.1), GOLDD)
			return hoof
		end
		B:sym(function(side)
			local fh = leg("F", "Chest", 1.75, -2.6, 3.4, side)
			B:block("FLeg" .. side, v(1.0, 0.8, 0.3), cf(1.75, 4.3, -3.9), GOLD) -- knee guard
			B:trail(fh, v(1.75, 0.2, -2.6), v(1.75, 1.6, -2.6), { name = "HoofTrail" .. side, color = { NEONC, NEONP }, life = 0.22, trans = { 0.55, 1 } })
			leg("H", "Body", 1.85, 3.9, 3.6, side)
		end)
		-- stomp shockwave: 4 hidden neon bars that fly outward on the landing
		local shock = B:bone("Shock", "Root", v(0, 0.12, -2.6))
		local bars = { { "N", v(0, 0, -2.2), v(5.6, 0.2, 0.35) }, { "S", v(0, 0, 2.2), v(5.6, 0.2, 0.35) },
			{ "E", v(2.2, 0, 0), v(0.35, 0.2, 5.6) }, { "W", v(-2.2, 0, 0), v(0.35, 0.2, 5.6) } }
		for _, b in bars do
			local sb = B:bone("Shock" .. b[1], "Shock", v(0, 0.12, -2.6))
			B:block(sb, b[3], CFrame.new(v(0, 0.12, -2.6) + b[2]), "#f3e6ff", { mat = "Neon", tr = 1, name = "Wave" .. b[1] })
		end
		local dustAt = B:block("Root", v(5, 0.2, 3), cf(0, 0.1, -2.8), WHITE, { tr = 1, name = "StompFX" })
		B:emitter(dustAt, "dust", { name = "StompDust", color = "#efe9ff" })

		------------------------------------------------------------------
		-- Aurora tail (4 bones)
		------------------------------------------------------------------
		local t1 = B:bone("Tail1", "Body", v(0, 9.8, 5.4))
		B:block(t1, v(1.8, 1.8, 2.2), cf(0, 10.7, 6.4), PINK)
		B:block(t1, v(1.4, 0.8, 1.6), cf(0, 11.9, 6.6), LAVD)
		local t2 = B:bone("Tail2", "Tail1", v(0, 11.0, 7.4))
		B:block(t2, v(2.4, 2.4, 2.2), cf(0, 11.4, 8.4), LAVD)
		B:block(t2, v(1.8, 0.8, 1.8), cf(0, 12.9, 8.6), CYAN)
		B:block(t2, v(1.8, 0.8, 1.6), cf(0, 9.9, 8.8), PINK)
		local t3 = B:bone("Tail3", "Tail2", v(0, 10.6, 9.4))
		B:block(t3, v(2.6, 2.6, 2.2), cf(0, 9.6, 10.3), CYAN)
		B:block(t3, v(2.2, 1.8, 0.6), cf(0, 9.8, 11.6), PINK)
		B:block(t3, v(2.0, 0.8, 1.6), cf(0, 8.0, 10.5), LAVD)
		local t4 = B:bone("Tail4", "Tail3", v(0, 8.4, 10.6))
		B:block(t4, v(2.4, 2.2, 2.0), cf(0, 7.0, 10.9), PINK)
		B:block(t4, v(1.8, 1.6, 1.6), cf(0, 5.3, 11.1), LAVD)
		B:block(t4, v(1.2, 1.2, 1.2), cf(0, 4.0, 11.2), CYAN)
		B:block(t4, v(0.6, 0.6, 0.6), cf(0, 3.2, 11.25), NEONP, { mat = "Neon" })
		B:trail(t4, v(0, 3.6, 11.2), v(0, 5.8, 11.1), { name = "TailTrail", color = { PINK, CYAN }, life = 0.3, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- Wings: 3 bones each, stepped feather blocks white -> lavender.
		-- Authored in a wing frame: local X = along the arm, local Z = feathers.
		------------------------------------------------------------------
		B:sym(function(side)
			-- each segment has its own frame: X along the arm, Z toward the feather tips
			-- wing plane faces front-outward (reads from the front, side and 3/4)
			local E, SW = math.rad(44), math.rad(42)
			local u1 = v(math.cos(SW), 0, math.sin(SW))
			local up = v(0, 1, 0)
			local ax = u1 * math.cos(E) + up * math.sin(E)
			local fz = u1 * math.sin(E) - up * math.cos(E)
			local W1 = CFrame.fromMatrix(v(2.2, 10.4, -1.0), ax, fz:Cross(ax), fz)
			local W2 = W1 * CFrame.new(4.6, 0, 0) * P.ang(0, 4, 0)
			local W3 = W2 * CFrame.new(4.2, 0, 0) * P.ang(0, -12, 0)
			local function feathers(bone, F, list, tipColor)
				for i, f in list do
					local len = f[2]
					B:block(bone, v(1.6, 0.7, len), F * CFrame.new(f[1], -0.1, 2.0 + len / 2), i % 2 == 0 and PALE2 or PALE)
					B:block(bone, v(1.5, 0.6, 1.3), F * CFrame.new(f[1], -0.12, 2.0 + len + 0.45), tipColor)
				end
			end
			local w1 = B:bone("Wing1" .. side, "Chest", W1.Position)
			B:block(w1, v(5.0, 1.4, 1.6), W1 * CFrame.new(2.3, 0, 0), WHITE)
			B:block(w1, v(1.8, 1.7, 1.9), W1 * CFrame.new(0.5, 0.05, 0.1), GOLD)
			B:block(w1, v(4.4, 1.0, 2.4), W1 * CFrame.new(2.6, 0.15, 1.7), WHITE)
			feathers(w1, W1, { { 1.2, 2.4 }, { 2.8, 3.0 }, { 4.4, 3.6 } }, "#cfc4ff")
			local w2 = B:bone("Wing2" .. side, "Wing1" .. side, W2.Position)
			B:block(w2, v(4.6, 1.3, 1.5), W2 * CFrame.new(2.0, 0, 0), WHITE)
			B:block(w2, v(4.4, 1.0, 2.4), W2 * CFrame.new(2.1, 0.15, 1.7), WHITE)
			B:block(w2, v(3.8, 0.25, 0.25), W2 * CFrame.new(2.0, 0.55, -0.65), NEONC, { mat = "Neon" })
			feathers(w2, W2, { { 0.9, 4.2 }, { 2.5, 4.8 }, { 4.1, 5.4 } }, "#c3b3ff")
			local w3 = B:bone("Wing3" .. side, "Wing2" .. side, W3.Position)
			B:block(w3, v(4.6, 1.2, 1.4), W3 * CFrame.new(2.1, 0, -0.1), WHITE)
			B:block(w3, v(4.0, 0.9, 2.0), W3 * CFrame.new(2.0, 0.15, 1.5), WHITE)
			B:block(w3, v(0.7, 0.7, 0.7), W3 * CFrame.new(4.5, 0.1, -0.1), NEONC, { mat = "Neon" })
			feathers(w3, W3, { { 1.0, 5.6 }, { 2.6, 4.6 } }, LAVD)
			B:block(w3, v(1.4, 0.7, 2.4), W3 * CFrame.new(4.0, -0.1, 2.5), PALE)
			B:block(w3, v(1.3, 0.6, 1.1), W3 * CFrame.new(4.0, -0.12, 4.1), LAVD)
			local wfx = B:block(w3, v(1.2, 1.2, 3.0), W3 * CFrame.new(4.0, 0, 2.0), WHITE, { tr = 1, name = "WingFX" .. side })
			B:emitter(wfx, "sparkle", { name = "WingSparks" .. side, color = { "#ffffff", NEONP, NEONC }, rate = 16, size = { 0.15, 0.55, 0 }, enabled = false })
			B:trail(w3, (W3 * CFrame.new(4.4, 0, 0)).Position, (W3 * CFrame.new(4.4, 0, 4.4)).Position, { name = "WingTrail" .. side, color = { NEONC, NEONP }, life = 0.3, trans = { 0.55, 1 } })
		end)

		------------------------------------------------------------------
		-- Floating voxel cubes + little twinkle stars orbiting (VFX)
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 9, 1))
		local spots = {
			{ 9.5, 12.0, -1, "cube", PINK, NEONC },
			{ -9.5, 9.5, 2.5, "star", GOLD },
			{ 7.5, 6.5, 7, "cube", CYAN, NEONP },
			{ -8.0, 14.0, -4, "cube", LAVD, NEONC },
			{ 3.0, 16.5, 7.5, "star", GOLD },
		}
		for i, s in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(s[1], s[2], s[3]))
			if s[4] == "cube" then
				local sz = i == 4 and 1.6 or 1.3
				B:block(ob, v(sz, sz, sz), cf(s[1], s[2], s[3]), s[5])
				B:block(ob, v(sz + 0.1, sz * 0.22, sz + 0.1), cf(s[1], s[2], s[3]), s[6], { mat = "Neon" })
			else
				twinkle(ob, cf(s[1], s[2], s[3]), 2.4, s[5], "#fff6c8", "z", true)
			end
		end
	end,
}
