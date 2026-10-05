--!nocheck
-- Magma Crab: stud-built volcanic crab. Obsidian stepped shell plates with
-- color-blocked lava seams, block vent cones that smoke and erupt, one giant
-- crusher claw + one small claw, 6 arched legs, wobbly eye stalks and a big
-- toothy grin. Only small neon accents (eyes, vent pools, a few thin cracks).
return {
	DisplayName = "Magma Crab",
	Rarity = "Epic",
	Element = "Fire",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette
		local OBS = "#3a3436" -- main: obsidian black-grey
		local DARK = "#2a2526" -- darker shade
		local LAVA = "#ff6a1a" -- orange lava (plastic color blocking)
		local GOLD = "#ffd23a" -- yellow lava (plastic color blocking)
		local CREAM = "#ffe4bd" -- light contrast: spikes, claw tips, knobs
		local WHITE = "#fffaf2" -- teeth
		local MOUTH = "#160f10" -- black mouth / pupils
		local NEON = "#ffc23a" -- the ONE neon accent (eyes, vent pools, thin cracks)

		local function blk(bone, sx, sy, sz, x, y, z, col, opts)
			return B:block(bone, v(sx, sy, sz), cf(x, y, z), col, opts)
		end
		local function neon(bone, sx, sy, sz, x, y, z, name)
			return B:block(bone, v(sx, sy, sz), cf(x, y, z), NEON, { mat = "Neon", name = name })
		end

		------------------------------------------------------------------
		-- BODY: stepped obsidian carapace with lava seams
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 4.8, 0.5))
		-- core shell: two crossed blocks give stepped (voxel-rounded) corners
		blk(body, 12, 3.4, 7, 0, 5.3, 0.5, OBS)
		blk(body, 10, 3.4, 9, 0, 5.3, 0.5, OBS)
		blk(body, 10.4, 0.6, 7.0, 0, 3.3, 0.5, DARK) -- underside
		blk(body, 8, 0.6, 5.6, 0, 2.75, 0.8, LAVA) -- lava belly
		blk(body, 4, 0.4, 3.6, 0, 2.35, 0.9, GOLD)
		blk(body, 10.8, 0.3, 8.0, 0, 7.1, 0.6, LAVA) -- seam L0/L1
		blk(body, 10.4, 1.2, 6.4, 0, 7.8, 0.6, OBS) -- L1 plate (cross)
		blk(body, 8.8, 1.2, 7.6, 0, 7.8, 0.6, OBS)
		blk(body, 8.0, 0.3, 6.0, 0, 8.5, 1.0, GOLD) -- seam L1/L2
		blk(body, 7.6, 1.0, 5.6, 0, 9.0, 1.0, DARK) -- L2 plate
		blk(body, 5.6, 0.3, 4.0, 0, 9.55, 1.2, LAVA) -- seam under the vent
		-- brow visor across the front of the shell
		blk(body, 11.2, 0.8, 1.2, 0, 7.0, -4.1, DARK)
		B:sym(function()
			-- dark side panels with color-blocked lava cracks
			blk(body, 0.5, 2.2, 6.0, 6.1, 5.2, 0.5, DARK)
			blk(body, 0.4, 0.4, 3.0, 6.3, 5.8, 1.0, LAVA)
			blk(body, 0.4, 1.2, 0.4, 6.3, 5.0, 2.3, LAVA)
			blk(body, 0.4, 0.4, 1.4, 6.3, 4.6, 2.9, GOLD)
			-- color-blocked lava cracks + one thin neon crack on the L1 plate
			blk(body, 0.4, 0.2, 1.2, 1.6, 8.45, -2.6, LAVA)
			blk(body, 1.2, 0.2, 0.4, 3.9, 8.45, 3.6, LAVA)
			neon(body, 0.25, 0.2, 2.2, 4.65, 8.45, 1.0)
			neon(body, 0.8, 0.2, 0.25, 4.35, 8.45, 2.0)
			-- lateral shell spikes (cream)
			B:spike(body, v(5.6, 6.4, -2.8), v(7.9, 7.3, -4.4), 1.1, 1.1, CREAM)
			B:spike(body, v(4.8, 7.8, -2.4), v(6.4, 9.2, -3.4), 0.9, 0.9, CREAM)
			-- rostrum spikes over the face
			B:spike(body, v(1.0, 7.2, -4.4), v(1.2, 8.0, -6.0), 0.8, 0.8, CREAM)
			-- back-edge spikes
			B:spike(body, v(2.8, 6.4, 4.6), v(3.2, 7.9, 6.5), 1.0, 1.0, CREAM)
			B:spike(body, v(5.2, 5.8, 3.6), v(6.4, 6.8, 5.6), 0.9, 0.9, CREAM)
			B:spike(body, v(3.4, 8.2, 3.8), v(3.8, 9.6, 5.2), 0.8, 0.8, CREAM)
			-- front face: lava blush cheeks
			blk(body, 1.4, 0.8, 0.2, 3.9, 6.0, -4.75, LAVA)
			-- upper teeth (white blocks hanging from the lip)
			blk(body, 0.7, 0.7, 0.5, 0.55, 5.0, -4.55, WHITE)
			blk(body, 0.7, 0.8, 0.5, 1.65, 4.95, -4.55, WHITE)
			blk(body, 0.8, 1.1, 0.6, 2.75, 4.8, -4.6, WHITE)
		end)
		B:spike(body, v(0, 6.6, 4.8), v(0, 8.3, 6.8), 1.2, 1.2, CREAM)
		-- face: upper lip + black mouth interior
		blk(body, 9.6, 1.4, 0.8, 0, 6.0, -4.3, OBS)
		blk(body, 7.2, 1.8, 0.8, 0, 4.6, -4.1, MOUTH)

		------------------------------------------------------------------
		-- JAW + mandibles
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Body", v(0, 4.6, -3.6))
		blk(jaw, 8.4, 1.2, 1.8, 0, 3.8, -4.3, OBS)
		blk(jaw, 7.6, 0.4, 1.4, 0, 3.05, -4.2, DARK)
		blk(jaw, 6.4, 0.3, 0.2, 0, 3.7, -5.25, LAVA)
		blk(jaw, 3.2, 0.3, 1.2, 0, 4.5, -3.9, LAVA) -- lava tongue
		blk(jaw, 1.2, 0.3, 0.6, 0, 4.55, -4.5, GOLD)
		blk(jaw, 0.6, 0.6, 0.5, 0, 4.7, -4.85, WHITE)
		B:sym(function()
			blk(jaw, 0.6, 0.6, 0.5, 1.1, 4.7, -4.85, WHITE)
			blk(jaw, 0.6, 0.7, 0.5, 2.2, 4.75, -4.85, WHITE)
		end)

		B:sym(function(side)
			local m = B:bone("Mand" .. side, "Body", v(3.9, 4.6, -4.7))
			blk(m, 1.0, 0.8, 1.0, 3.9, 4.6, -4.9, DARK)
			blk(m, 0.7, 1.2, 0.7, 4.05, 3.8, -5.3, CREAM)
			B:wedge(m, v(0.7, 0.6, 0.9), cf(3.7, 3.2, -5.3, 0, -90, 180), CREAM)
		end)

		------------------------------------------------------------------
		-- EYE STALKS with big chunky cartoon eyes (+ blink lids)
		------------------------------------------------------------------
		B:sym(function(side)
			local stalk = B:bone("Stalk" .. side, "Body", v(2.5, 7.4, -3.6))
			blk(stalk, 1.8, 0.6, 1.8, 2.5, 7.6, -3.6, DARK)
			blk(stalk, 1.0, 1.6, 1.0, 2.5, 8.5, -3.6, OBS)
			blk(stalk, 1.2, 0.4, 1.2, 2.5, 8.5, -3.6, LAVA)
			local eye = B:bone("Eye" .. side, "Stalk" .. side, v(2.5, 9.2, -3.6))
			blk(eye, 3.0, 2.8, 2.6, 2.6, 10.5, -3.7, OBS)
			blk(eye, 3.1, 0.4, 2.7, 2.6, 9.15, -3.7, DARK)
			B:block(eye, v(2.2, 2.0, 0.2), cf(2.6, 10.45, -5.08), NEON, { mat = "Neon", name = "EyeGlow" })
			blk(eye, 0.8, 1.3, 0.15, 2.25, 10.3, -5.22, MOUTH)
			blk(eye, 0.3, 0.3, 0.1, 2.45, 10.7, -5.33, WHITE)
			B:block(eye, v(3.3, 0.8, 0.9), cf(2.6, 11.7, -4.8, 0, 0, 12), DARK)
			B:spike(eye, v(2.9, 11.8, -3.0), v(3.4, 12.9, -2.0), 0.8, 0.8, CREAM)
			local lid = B:bone("Lid" .. side, "Eye" .. side, v(2.6, 10.45, -4.0))
			blk(lid, 2.3, 2.1, 0.2, 2.6, 10.45, -4.0, OBS)
		end)

		------------------------------------------------------------------
		-- VOLCANIC VENTS (stepped block cones)
		------------------------------------------------------------------
		local vent = B:bone("Vent", "Body", v(0, 9.7, 1.4))
		blk(vent, 3.6, 0.9, 3.6, 0, 10.1, 1.4, DARK)
		blk(vent, 2.6, 0.9, 2.6, 0, 10.95, 1.4, OBS)
		blk(vent, 2.0, 0.5, 2.0, 0, 11.6, 1.4, LAVA)
		neon(vent, 1.2, 0.2, 1.2, 0, 11.82, 1.4)
		-- color-blocked lava drips running down the cone
		blk(vent, 0.6, 0.9, 0.2, 0.4, 10.95, 0.05, LAVA)
		blk(vent, 0.6, 0.6, 0.2, 0.4, 10.3, -0.45, GOLD)
		blk(vent, 0.2, 0.9, 0.6, 1.35, 10.95, 1.9, LAVA)
		blk(vent, 0.2, 0.9, 0.6, -1.35, 10.95, 0.9, LAVA)
		local ventFX = blk(vent, 1.2, 0.4, 1.2, 0, 12.1, 1.4, OBS, { tr = 1, name = "VentFX" })
		B:emitter(ventFX, "ember", { name = "VentEmbers", color = { GOLD, LAVA }, rate = 5 })
		B:emitter(ventFX, "smoke", { name = "VentSmoke", color = "#5a5052", rate = 1.2, size = { 0.8, 2.2, 3.2 } })
		B:emitter(ventFX, "fire", { name = "EruptFire", color = { GOLD, LAVA, "#c4300c" }, rate = 40, speed = { 8, 14 }, size = { 1.6, 1.2, 0 }, life = { 0.4, 0.8 }, enabled = false })
		B:emitter(ventFX, "burst", { name = "EruptBurst", color = { GOLD, LAVA }, speed = { 10, 18 }, accel = { 0, -18, 0 } })
		B:light(ventFX, { name = "VentLight", color = "#ff8a2a", brightness = 0.5, range = 12 })

		B:sym(function(side)
			local sv = B:bone("Vent" .. side, "Body", v(4.1, 8.4, 3.0))
			blk(sv, 1.8, 0.8, 1.8, 4.1, 8.8, 3.0, DARK)
			blk(sv, 1.2, 0.6, 1.2, 4.1, 9.5, 3.0, LAVA)
			neon(sv, 0.7, 0.15, 0.7, 4.1, 9.85, 3.0)
			local fx = blk(sv, 0.7, 0.3, 0.7, 4.1, 10.0, 3.0, OBS, { tr = 1, name = "SmallVentFX" .. side })
			B:emitter(fx, "ember", { name = "VentEmbers" .. side, color = { GOLD, LAVA }, rate = 2.5, size = { 0.25, 0.15, 0 } })
		end)

		------------------------------------------------------------------
		-- CLAWS: right = giant crusher, left = small pincer
		------------------------------------------------------------------
		local S = v(5.4, 5.2, -2.8) -- shoulder
		local E = v(8.4, 3.9, -4.2) -- elbow (arms fold down at rest, long reach when raised)
		local W = v(8.8, 6.3, -6.2) -- wrist
		B:sym(function(side)
			local k = side == "R" and 1 or 0.75 -- claw scale
			local ka = side == "R" and 1 or 0.85 -- arm thickness
			local arm = B:bone("Arm" .. side, "Body", S)
			B:block(arm, v(2, 2, 2) * ka, CFrame.new(S + v(0.2, 0, -0.2)), LAVA)
			B:beam(arm, S + v(0.3, 0, -0.3), E, 1.8 * ka, 1.8 * ka, OBS)

			local fore = B:bone("Fore" .. side, "Arm" .. side, E)
			B:block(fore, v(2.1, 2.1, 2.1) * ka, CFrame.new(E), LAVA)
			B:beam(fore, E, W, 2.0 * ka, 2.0 * ka, OBS)
			B:spike(fore, E + v(0.5, 0.6, 0.2), E + v(1.6, 1.8, 0.8), 0.8 * ka, 0.8 * ka, CREAM)

			-- claw frame: pitched up, turned a touch outward; claw points along local -Z
			local CL = CFrame.new(W) * ang(26, -6, 0)
			local function c(x, y, z, rx, ry, rz) return CL * CFrame.new(x * k, y * k, z * k) * ang(rx or 0, ry or 0, rz or 0) end
			local function sz(x, y, z) return v(x, y, z) * k end
			local function pt(x, y, z) return (CL * CFrame.new(x * k, y * k, z * k)).Position end

			local claw = B:bone("Claw" .. side, "Fore" .. side, CL)
			B:block(claw, sz(3.0, 3.6, 0.7), c(0, 0.6, 0.0), GOLD) -- wrist cuff
			B:block(claw, sz(3.4, 4.4, 3.6), c(0, 0.6, -2.0), LAVA) -- molten palm
			B:block(claw, sz(3.5, 1.7, 3.7), c(0, 2.2, -2.0), OBS) -- obsidian armor top
			B:block(claw, sz(2.6, 0.8, 2.6), c(0, 3.4, -2.0), OBS) -- stepped hump
			B:block(claw, sz(3.5, 0.6, 3.7), c(0, -1.45, -2.0), DARK) -- dark underside
			B:block(claw, sz(0.3, 0.5, 2.6), c(1.75, 1.1, -2.0), GOLD) -- hot seam under the armor
			B:block(claw, sz(0.3, 0.5, 2.6), c(-1.75, 1.1, -2.0), GOLD)
			B:block(claw, sz(2.2, 1.6, 0.2), c(0, 0.5, -3.85), LAVA) -- molten glow inside the pincer notch
			B:spike(claw, pt(-0.5, 3.7, -1.3), pt(-0.6, 5.1, -0.7), 1.0 * k, 1.0 * k, CREAM)
			B:spike(claw, pt(0.6, 3.7, -2.6), pt(0.7, 4.8, -2.2), 0.8 * k, 0.8 * k, CREAM)
			-- fingers are authored open (V notch) by rotating about their hinges
			local function hinge(hy, rx)
				local h = CL * CFrame.new(0, hy * k, -3.8 * k)
				local rot = h * ang(rx, 0, 0) * h:Inverse()
				return function(x, y, z) return rot * c(x, y, z) end, function(x, y, z) return (rot * c(x, y, z)).Position end
			end
			-- fixed (lower) finger: stepped + tapered, cream hook tip, teeth on top
			local lc, lp = hinge(-0.2, -8)
			B:block(claw, sz(2.4, 1.5, 2.0), lc(0, -0.65, -4.8), OBS)
			B:block(claw, sz(1.7, 1.1, 1.4), lc(0, -0.45, -6.4), OBS)
			B:spike(claw, lp(0, -0.45, -6.9), lp(0, 0.5, -8.7), 1.2 * k, 1.0 * k, CREAM)
			B:block(claw, sz(0.6, 0.6, 0.6), lc(-0.5, 0.3, -4.5), CREAM)
			B:block(claw, sz(0.6, 0.6, 0.6), lc(0.4, 0.2, -6.0), CREAM)

			-- movable (upper) pincer
			local uc, up = hinge(1.9, 12)
			local pin = B:bone("Pincer" .. side, "Claw" .. side, c(0, 1.9, -3.8))
			B:block(pin, sz(2.4, 1.7, 2.2), uc(0, 1.85, -4.9), OBS)
			B:block(pin, sz(1.8, 1.3, 1.4), uc(0, 1.6, -6.6), OBS)
			B:spike(pin, up(0, 1.6, -7.1), up(0, 0.6, -9.0), 1.3 * k, 1.1 * k, CREAM)
			B:block(pin, sz(0.6, 0.6, 0.6), uc(0.5, 0.8, -5.0), CREAM)
			B:block(pin, sz(0.6, 0.6, 0.6), uc(-0.4, 0.85, -6.4), CREAM)
			B:trail(pin, up(0, 1.6, -8.4), up(0, 0.6, -8.4), { name = "ClawTrail" .. side, color = { GOLD, LAVA }, life = 0.25, trans = { 0.35, 1 } })
			if side == "R" then
				local fx = B:block(pin, sz(2, 2, 2), c(0, 1.2, -6.0), OBS, { tr = 1, name = "ClapFX" })
				B:emitter(fx, "burst", { name = "ClapBurst", color = { "#ffffff", GOLD, LAVA } })
			end
		end)

		------------------------------------------------------------------
		-- LEGS: 3 per side, 3 bones each, arched crab legs
		------------------------------------------------------------------
		local LEGS = {
			{ hip = v(5.4, 4.4, -0.6), knee = v(7.8, 6.6, -1.4), ankle = v(9.4, 3.2, -2.0), tip = v(10.0, 0.1, -2.4) },
			{ hip = v(5.4, 4.4, 1.4), knee = v(8.0, 6.8, 1.6), ankle = v(9.7, 3.2, 1.8), tip = v(10.3, 0.1, 1.9) },
			{ hip = v(5.4, 4.4, 3.4), knee = v(7.6, 6.5, 4.4), ankle = v(9.1, 3.1, 5.2), tip = v(9.7, 0.1, 5.8) },
		}
		B:sym(function(side)
			for i, L in LEGS do
				local a = B:bone("Leg" .. i .. "A" .. side, "Body", L.hip)
				B:beam(a, L.hip, L.knee, 1.6, 1.6, OBS)
				local b = B:bone("Leg" .. i .. "B" .. side, "Leg" .. i .. "A" .. side, L.knee)
				B:block(b, v(1.8, 1.8, 1.8), CFrame.new(L.knee), LAVA)
				B:spike(b, L.knee + v(0, 0.6, 0), L.knee + v(0.5, 2.0, 0.4), 0.8, 0.8, CREAM)
				B:beam(b, L.knee, L.ankle, 1.4, 1.4, OBS)
				local mid = L.knee + (L.ankle - L.knee) * 0.55
				local dir = (L.ankle - L.knee).Unit
				B:beam(b, mid - dir * 0.25, mid + dir * 0.25, 1.55, 1.55, GOLD)
				local cc = B:bone("Leg" .. i .. "C" .. side, "Leg" .. i .. "B" .. side, L.ankle)
				B:block(cc, v(1.35, 1.35, 1.35), CFrame.new(L.ankle), DARK)
				local m2 = L.ankle + (L.tip - L.ankle) * 0.45
				B:beam(cc, L.ankle, m2, 1.1, 1.1, OBS)
				B:spike(cc, m2 + (L.ankle - L.tip).Unit * 0.3, L.tip, 1.0, 1.0, CREAM)
			end
		end)

		------------------------------------------------------------------
		-- Ground FX (dust on the ground pound)
		------------------------------------------------------------------
		local ground = B:block("Root", v(16, 0.4, 12), cf(0, 0.2, -1), OBS, { tr = 1, name = "GroundFX" })
		B:emitter(ground, "dust", { name = "SlamDust", color = { "#e8d8c0", "#a89a8a" } })

		------------------------------------------------------------------
		-- Floating obsidian / lava voxel cubes
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 10, 0.5))
		local spots = { { 10.5, 10.5, -2 }, { -9.5, 12, 1 }, { 7, 12.5, 7 }, { -7.5, 9.5, 7.5 }, { 1, 13.5, -7.5 } }
		for i, s in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(s[1], s[2], s[3]))
			local lava = i % 2 == 0
			local size = lava and 1.2 or 1.6
			B:block(ob, v(size, size, size), cf(s[1], s[2], s[3]), lava and LAVA or OBS)
			B:block(ob, v(size + 0.1, size * 0.28, size + 0.1), cf(s[1], s[2], s[3]), lava and GOLD or LAVA)
		end
	end,
}
