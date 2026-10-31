-- Treadmill13 "Galaxy Treadmill" (tier 12, Cosmic).
-- Deep-space frame with gold trim, a stepped ring arch over the deck crowned by
-- a spinning star, three voxel planets on a tilted orbit around the arch (one
-- ringed, one with a moon), a comet sweeping along the arch, nebula glow and a
-- starfield belt. Faces -Z (console at the front).
-- Animated: starfield belt (3-slat pattern with stars slides +Z), star hubs,
-- orbiting + self-spinning planets with orbit trails, moon, comet, spiral
-- galaxy on the console screen, chase lights over the arch, pulsing thrusters
-- and a "supernova" beat (star flare, burst, everything flashes).
return {
	DisplayName = "Galaxy Treadmill",
	Rarity = "Cosmic",
	Element = "Cosmic",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local SP, SP_D, SP_L = "#2e2368", "#161038", "#5b4bb8"
		local VIO = "#8b5cf0"
		local GOLD, GOLD_D, GOLD_L = "#ffc94a", "#c98a1c", "#ffe6a0"
		local SILVER = "#d9d6f2"
		local PINK, CYAN, STAR = "#ff5ce1", "#5ce8ff", "#fffbe6"
		local ZA = 0.3 -- arch plane

		---------------------------------------------------------------- base
		B:block("Root", v(5.4, 0.3, 11.0), cf(0, 0.15, 0.1), SP_D)
		B:block("Root", v(5.0, 0.8, 10.6), cf(0, 0.7, 0.1), SP)
		B:block("Root", v(5.1, 0.12, 10.7), cf(0, 1.06, 0.1), GOLD)
		for _, s in { 1, -1 } do
			B:block("Root", v(0.12, 0.5, 10.0), cf(s * 2.53, 0.55, 0.1), SP_D)
			B:block("Root", v(0.16, 0.14, 10.4), cf(s * 2.56, 0.22, 0.1), GOLD_D)
			-- star specks on the side panels
			for k, p in { { -4.2, 0.7 }, { -3.1, 0.4 }, { -1.7, 0.65 }, { -0.4, 0.38 }, { 1.0, 0.7 }, { 2.3, 0.45 }, { 3.6, 0.68 }, { 4.6, 0.4 } } do
				B:block("Root", v(0.08, 0.12, 0.12), cf(s * 2.6, p[2], p[1]), k % 3 == 0 and GOLD_L or STAR, { mat = "Neon" })
			end
			-- outriggers carrying the arch pillars
			B:block("Root", v(1.8, 0.6, 2.0), cf(s * 3.2, 0.3, ZA), SP_D)
			B:block("Root", v(1.9, 0.12, 2.1), cf(s * 3.2, 0.65, ZA), GOLD)
		end
		for i = 1, 8 do
			local z = -4.3 + (i - 1) * 1.22
			local col = i % 2 == 0 and PINK or CYAN
			B:block("Root", v(0.1, 0.12, 0.8), cf(2.66, 0.92, z), col, { mat = "Neon", name = "ChR" .. i })
			B:block("Root", v(0.1, 0.12, 0.8), cf(-2.66, 0.92, z), col, { mat = "Neon", name = "ChL" .. i })
		end
		B:sym(function()
			B:block("Root", v(0.8, 0.3, 7.0), cf(2.1, 1.35, 0.1), SP_L)
			B:block("Root", v(0.84, 0.08, 7.0), cf(2.1, 1.52, 0.1), GOLD_L)
		end)
		B:block("Root", v(3.5, 0.1, 9.0), cf(0, 1.17, 0.1), SP_D)

		------------------------------------------- starfield belt (+Z)
		-- 3-slat pattern (period 1.5) with stars scattered on it; the pattern is
		-- identical every 3 slats so a 1.5-stud slide loops seamlessly.
		local belt = B:bone("Belt", "Root", v(0, 1.3, 0))
		local slatCol = { "#1b1546", "#241c5a", "#1b1546" }
		local stars = {
			{ { -1.2, 0.05, STAR }, { 0.7, -0.08, CYAN } },
			{ { 0.1, 0.0, PINK }, { 1.35, 0.06, STAR }, { -0.6, -0.05, GOLD_L } },
			{ { -1.45, -0.04, CYAN }, { 0.9, 0.08, STAR } },
		}
		for i = 0, 17 do
			local z = -4.9 + i * 0.5
			local k = i % 3 + 1
			B:block(belt, v(3.4, 0.08, 0.4), cf(0, 1.27, z), slatCol[k])
			for _, st in stars[k] do
				B:block(belt, v(0.12, 0.03, 0.12), cf(st[1], 1.32, z + st[2]), st[3], { mat = "Neon" })
			end
			if k == 2 then
				B:block(belt, v(3.3, 0.025, 0.05), cf(0, 1.32, z + 0.22), VIO, { mat = "Neon" })
			end
		end

		-------------------------------------------- motor hood + rear cap
		B:block("Root", v(5.0, 0.9, 1.8), cf(0, 1.45, -4.3), SP)
		B:block("Root", v(4.8, 0.2, 1.7), cf(0, 2.0, -4.3), SP_L)
		B:block("Root", v(5.05, 0.1, 1.85), cf(0, 1.9, -4.3), GOLD)
		B:block("Root", v(3.0, 0.12, 0.9), cf(0, 2.15, -4.4), SP_D)
		B:block("Root", v(2.4, 0.05, 0.16), cf(0, 2.23, -4.05), PINK, { mat = "Neon", name = "HoodGlow" })
		B:block("Root", v(5.0, 0.6, 1.8), cf(0, 1.35, 4.5), SP)
		B:block("Root", v(5.1, 0.12, 1.9), cf(0, 1.68, 4.5), GOLD)

		-- rear thrusters (pulsing exhaust)
		local thr = {}
		for n, x in { 1.3, -1.3 } do
			B:block("Root", v(1.2, 1.0, 1.0), cf(x, 2.2, 5.0), SP_L)
			B:block("Root", v(1.3, 0.15, 1.1), cf(x, 2.75, 5.0), GOLD)
			B:block("Root", v(1.0, 0.8, 0.5), cf(x, 2.2, 5.6), SILVER)
			B:block("Root", v(0.8, 0.6, 0.3), cf(x, 2.2, 5.9), SP_D)
			thr[n] = B:block("Root", v(0.55, 0.4, 0.1), cf(x, 2.2, 6.06), CYAN, { mat = "Neon", name = "Thrust" .. n })
		end

		---------------------------------------------- star roller hubs (4)
		local function hub(name, x, y, z, r)
			local b = B:bone(name, "Root", v(x, y, z))
			local c = cf(x, y, z)
			B:block(b, v(0.2, r * 1.2, r * 1.2), c * ang(45, 0, 0), SP_L)
			for k = 0, 3 do
				B:block(b, v(0.22, 0.24, r), c * ang(90 * k, 0, 0) * CFrame.new(0.01, 0, -r * 0.5), GOLD)
				B:block(b, v(0.24, 0.16, 0.16), c * ang(90 * k, 0, 0) * CFrame.new(0.02, 0, -r), GOLD_L)
			end
			B:block(b, v(0.28, 0.26, 0.26), c * ang(45, 0, 0), PINK, { mat = "Neon" })
		end
		hub("HubFR", 2.62, 1.45, -4.3, 0.75)
		hub("HubFL", -2.62, 1.45, -4.3, 0.75)
		hub("HubRR", 2.62, 1.3, 4.5, 0.6)
		hub("HubRL", -2.62, 1.3, 4.5, 0.6)

		-------------------------------------------------- the ring arch
		local AR, AY = 3.3, 4.6 -- arch radius / spring height
		for _, s in { 1, -1 } do
			local x = AR * s
			B:block("Root", v(1.3, 0.8, 1.3), cf(x, 1.05, ZA), SP_L)
			B:block("Root", v(1.4, 0.15, 1.4), cf(x, 1.5, ZA), GOLD)
			B:block("Root", v(0.8, 3.7, 0.9), cf(x, 3.3, ZA), SP)
			B:block("Root", v(0.3, 3.5, 0.95), cf(x - 0.28 * s, 3.3, ZA), GOLD_D)
			for _, y in { 2.4, 4.0 } do
				B:block("Root", v(1.0, 0.25, 1.05), cf(x, y, ZA), SP_L)
			end
			-- nebula crystals at the pillar feet
			B:block("Root", v(0.5, 1.3, 0.5), cf(x + 0.65 * s, 1.0, ZA - 0.55, 0, 45, -18 * s), VIO, { tr = 0.15 })
			B:block("Root", v(0.4, 1.0, 0.4), cf(x + 0.55 * s, 0.85, ZA + 0.7, 15, 45, -10 * s), PINK, { tr = 0.25 })
			B:block("Root", v(0.18, 0.3, 0.18), cf(x + 0.88 * s, 1.68, ZA - 0.6, 0, 45, -18 * s), STAR, { mat = "Neon" })
		end
		-- stepped semicircle: 13 segments, gold inner rim, star nodes on the face
		for i = 0, 12 do
			local a = math.rad(i * 15) -- 0 = right spring, 180 = left
			local c = CFrame.new(0, AY, ZA) * CFrame.Angles(0, 0, a) * CFrame.new(AR, 0, 0)
			B:block("Root", v(0.8, 1.0, 0.9), c, SP)
			B:block("Root", v(0.18, 0.95, 1.0), c * CFrame.new(-0.42, 0, 0), GOLD)
			B:block("Root", v(0.2, 0.9, 0.6), c * CFrame.new(0.42, 0, 0), SP_L)
			B:block("Root", v(0.2, 0.2, 0.06), c * CFrame.new(0.05, 0, -0.47), i % 2 == 0 and PINK or CYAN, { mat = "Neon", name = "ArchF" .. i })
			B:block("Root", v(0.2, 0.2, 0.06), c * CFrame.new(0.05, 0, 0.47), i % 2 == 0 and CYAN or PINK, { mat = "Neon", name = "ArchB" .. i })
		end
		-- keystone
		B:block("Root", v(1.3, 0.9, 1.2), cf(0, AY + AR + 0.25, ZA), SP_L)
		B:block("Root", v(1.4, 0.15, 1.3), cf(0, AY + AR + 0.75, ZA), GOLD)

		-- spinning star on the keystone (+ hidden supernova flare)
		local SY = AY + AR + 1.6
		local star = B:bone("Star", "Root", v(0, SY, ZA))
		B:block(star, v(0.42, 1.6, 0.35), cf(0, SY, ZA), GOLD)
		B:block(star, v(1.6, 0.42, 0.35), cf(0, SY, ZA), GOLD)
		B:block(star, v(0.3, 1.1, 0.28), cf(0, SY, ZA, 0, 0, 45), GOLD_L)
		B:block(star, v(1.1, 0.3, 0.28), cf(0, SY, ZA, 0, 0, 45), GOLD_L)
		local starCore = B:block(star, v(0.45, 0.45, 0.4), cf(0, SY, ZA, 0, 0, 45), STAR, { mat = "Neon", name = "StarCore" })
		B:block(star, v(0.2, 2.4, 0.12), cf(0, SY, ZA), STAR, { mat = "Neon", tr = 1, name = "Nova1" })
		B:block(star, v(2.4, 0.2, 0.12), cf(0, SY, ZA), STAR, { mat = "Neon", tr = 1, name = "Nova2" })
		B:block(star, v(0.14, 1.6, 0.1), cf(0, SY, ZA, 0, 0, 45), PINK, { mat = "Neon", tr = 1, name = "Nova3" })
		B:block(star, v(1.6, 0.14, 0.1), cf(0, SY, ZA, 0, 0, 45), CYAN, { mat = "Neon", tr = 1, name = "Nova4" })
		-- hidden supernova shock ring (8 rays around the star, faces the runner)
		for k = 1, 8 do
			local rc = CFrame.new(0, SY, ZA) * CFrame.Angles(0, 0, math.rad(k * 45 + 22.5)) * CFrame.new(0, 1.45, 0)
			B:block(star, v(0.5, 0.18, 0.12), rc, k % 2 == 0 and PINK or CYAN, { mat = "Neon", tr = 1, name = "NovaR" .. k })
		end
		B:light(starCore, { color = "#ffb8f0", brightness = 1.0, range = 14, name = "StarLight" })
		B:emitter(starCore, "burst", { color = { STAR, PINK, CYAN }, size = { 0.7, 0.4, 0 }, speed = { 8, 15 }, name = "Supernova" })
		B:emitter(starCore, "sparkle", { color = { STAR, GOLD_L }, rate = 8, size = { 0.15, 0.45, 0 }, name = "StarSparkle" })

		-- comet sweeping back and forth along the arch face
		local comet = B:bone("Comet", "Root", v(0, AY, ZA))
		local cp = v(AR + 0.05, AY, ZA - 0.75)
		B:block(comet, v(0.42, 0.42, 0.42), CFrame.new(cp) * ang(45, 45, 0), GOLD_L, { mat = "Neon" })
		B:block(comet, v(0.24, 0.24, 0.5), CFrame.new(cp), STAR, { mat = "Neon" })
		B:trail(comet, cp + v(0, 0.22, 0), cp - v(0, 0.22, 0), { color = { STAR, PINK, VIO }, life = 0.7, width = { 1, 0 }, trans = { 0.1, 1 }, name = "CometTrail" })

		------------------------------------------------- orbiting planets
		local OY, OR, TILT = 7.2, 4.8, 15
		local orbitCF = CFrame.new(0, OY, ZA) * ang(TILT, 0, 0)
		local orbit = B:bone("Orbit", "Root", orbitCF)
		local function voxelSphere(bone, c, d, main, light, dark)
			B:block(bone, v(d * 0.75, d * 0.75, d * 0.75), c, main)
			B:block(bone, v(d, d * 0.5, d * 0.5), c, dark)
			B:block(bone, v(d * 0.5, d, d * 0.5), c, light)
			B:block(bone, v(d * 0.5, d * 0.5, d), c, main)
		end
		local planetPos = {}
		for k = 1, 3 do
			local a = math.rad(120 * (k - 1) + 60)
			planetPos[k] = orbitCF * CFrame.new(math.sin(a) * OR, 0, -math.cos(a) * OR)
		end
		-- 1: ringed gold/orange gas giant
		local p1c = CFrame.new(planetPos[1].Position)
		local p1 = B:bone("Planet1", orbit, p1c * ang(0, 0, 20))
		voxelSphere(p1, p1c, 1.7, "#ff9a3c", "#ffc46b", "#d96a1e")
		B:block(p1, v(1.74, 0.2, 1.74), p1c, "#fff0c0")
		B:ring(p1, p1c * ang(0, 0, 20), 1.4, 12, v(0.5, 0.14, 0.36), GOLD_L)
		B:ring(p1, p1c * ang(0, 15, 20), 1.68, 12, v(0.46, 0.1, 0.24), "#f7d9a0")
		B:trail(orbit, p1c.Position + v(0, 0.35, 0), p1c.Position - v(0, 0.35, 0), { color = { GOLD_L, "#ff9a3c" }, life = 0.9, trans = { 0.45, 1 }, name = "OrbitTrail1" })
		-- 2: ocean world with green land and a moon
		local p2c = CFrame.new(planetPos[2].Position)
		local p2 = B:bone("Planet2", orbit, p2c)
		voxelSphere(p2, p2c, 1.55, "#2e8bff", "#6fc3ff", "#1d5ed0")
		B:block(p2, v(0.5, 0.35, 0.3), p2c * CFrame.new(0.25, 0.3, -0.65), "#52d66a")
		B:block(p2, v(0.3, 0.4, 0.45), p2c * CFrame.new(-0.65, -0.1, 0.2), "#3bbf56")
		B:block(p2, v(0.45, 0.3, 0.3), p2c * CFrame.new(0.1, -0.35, 0.65), "#52d66a")
		B:block(p2, v(0.8, 0.16, 0.8), p2c * CFrame.new(0, 0.75, 0), "#ffffff")
		local moon = B:bone("Moon", p2, p2c)
		local mp = p2c * CFrame.new(1.4, 0.25, 0)
		B:block(moon, v(0.34, 0.34, 0.34), mp, SILVER)
		B:block(moon, v(0.24, 0.42, 0.24), mp, "#b4b0d0")
		B:trail(moon, mp.Position + v(0, 0.12, 0), mp.Position - v(0, 0.12, 0), { color = { SILVER, CYAN }, life = 0.5, trans = { 0.5, 1 }, name = "MoonTrail" })
		B:trail(orbit, p2c.Position + v(0, 0.3, 0), p2c.Position - v(0, 0.3, 0), { color = { CYAN, "#2e8bff" }, life = 0.9, trans = { 0.45, 1 }, name = "OrbitTrail2" })
		-- 3: banded pink/violet giant with a glowing storm spot
		local p3c = CFrame.new(planetPos[3].Position)
		local p3 = B:bone("Planet3", orbit, p3c)
		voxelSphere(p3, p3c, 1.85, "#c04fe0", "#ff8fe8", "#7a2fb8")
		B:block(p3, v(1.9, 0.24, 1.4), p3c * CFrame.new(0, 0.4, 0), "#ffb3f0")
		B:block(p3, v(1.4, 0.22, 1.9), p3c * CFrame.new(0, -0.36, 0), "#9a3dd0")
		B:block(p3, v(0.4, 0.28, 0.1), p3c * CFrame.new(0.3, -0.02, -0.95), PINK, { mat = "Neon", name = "StormSpot" })
		B:trail(orbit, p3c.Position + v(0, 0.4, 0), p3c.Position - v(0, 0.4, 0), { color = { PINK, VIO }, life = 0.9, trans = { 0.45, 1 }, name = "OrbitTrail3" })

		-- tilted asteroid belt circling the keystone (counter-orbit)
		local belt2CF = CFrame.new(0, 7.9, ZA) * ang(0, 0, -18)
		local ast = B:bone("Asteroids", "Root", belt2CF)
		for k = 0, 9 do
			local c = belt2CF * CFrame.Angles(0, math.rad(k * 36), 0) * CFrame.new(0, 0, -3.5)
			local big = k % 2 == 0
			if k % 5 == 2 then
				B:block(ast, v(0.26, 0.26, 0.26), c * ang(45, 45, 0), k < 5 and CYAN or PINK, { mat = "Neon" })
			else
				B:block(ast, v(big and 0.45 or 0.32, big and 0.38 or 0.3, big and 0.42 or 0.3), c * ang(k * 23, k * 41, 0), k % 3 == 0 and "#7a6f9c" or "#5d5578")
				B:block(ast, v(0.22, 0.22, 0.22), c * CFrame.new(0.15, 0.17, 0) * ang(k * 31, 0, 20), "#9b92bd")
			end
		end

		------------------------------------------------------ uprights
		B:sym(function()
			B:bar("Root", v(2.15, 1.6, -4.6), v(2.15, 5.4, -4.0), 0.7, 0.7, SP)
			B:bar("Root", v(2.15, 1.7, -4.6), v(2.15, 5.3, -4.0), 0.74, 0.25, GOLD_D)
			B:block("Root", v(1.0, 0.5, 1.0), cf(2.15, 1.85, -4.6), SP_L)
			for k = 0, 1 do
				local y = 3.0 + k * 1.3
				B:block("Root", v(0.82, 0.2, 0.82), cf(2.15, y, -4.6 + (y - 1.6) / 3.8 * 0.6), GOLD)
			end
		end)

		------------------------------------------------------- console
		local con = cf(0, 5.8, -3.9) * ang(-30, 0, 0)
		B:block("Root", v(4.8, 1.0, 1.4), con, SP)
		B:block("Root", v(4.9, 0.22, 1.5), con * CFrame.new(0, 0.58, 0), SP_L)
		B:block("Root", v(4.95, 0.1, 1.55), con * CFrame.new(0, 0.45, 0), GOLD)
		B:block("Root", v(4.6, 0.2, 1.3), con * CFrame.new(0, -0.58, 0), SP_D)
		B:block("Root", v(3.6, 0.82, 0.06), con * CFrame.new(0, 0, 0.7), "#07051a")
		B:block("Root", v(3.75, 0.08, 0.08), con * CFrame.new(0, 0.44, 0.7), GOLD)
		B:block("Root", v(3.75, 0.08, 0.08), con * CFrame.new(0, -0.44, 0.7), GOLD)
		-- spiral galaxy (left of the screen) turning about the screen normal
		local gc = con * CFrame.new(-0.95, 0, 0.74)
		local gal = B:bone("Galaxy", "Root", gc)
		B:block(gal, v(0.16, 0.16, 0.03), gc * ang(0, 0, 45), STAR, { mat = "Neon" })
		for arm = 0, 1 do
			for k = 1, 4 do
				local a = math.rad(arm * 180 + k * 38)
				local r = 0.08 + k * 0.075
				local sz = 0.09 - k * 0.01
				B:block(gal, v(sz + 0.03, sz, 0.03), gc * CFrame.new(math.cos(a) * r, math.sin(a) * r, 0) * ang(0, 0, math.deg(a)), k % 2 == 0 and PINK or CYAN, { mat = "Neon" })
			end
		end
		-- stardust level bars
		for i = 1, 8 do
			local hgt = 0.1 + (i - 1) * 0.065
			B:block("Root", v(0.18, hgt, 0.05), con * CFrame.new(-0.25 + (i - 1) * 0.25, -0.33 + hgt / 2, 0.74), i > 6 and PINK or CYAN, { mat = "Neon", name = "Bar" .. i })
		end
		-- tiny star icon + buttons
		B:block("Root", v(0.28, 0.08, 0.05), con * CFrame.new(1.65, 0.18, 0.74), GOLD_L, { mat = "Neon" })
		B:block("Root", v(0.08, 0.28, 0.05), con * CFrame.new(1.65, 0.18, 0.74), GOLD_L, { mat = "Neon" })
		B:block("Root", v(0.4, 0.4, 0.14), con * CFrame.new(-2.05, 0.05, 0.7), GOLD)
		B:block("Root", v(0.22, 0.22, 0.06), con * CFrame.new(-2.05, 0.05, 0.79), PINK, { mat = "Neon", name = "Led" })
		B:block("Root", v(0.34, 0.22, 0.12), con * CFrame.new(2.05, 0.15, 0.7), SILVER)
		B:block("Root", v(0.34, 0.22, 0.12), con * CFrame.new(2.05, -0.17, 0.7), VIO)
		-- console crown: little gold orrery posts with star tips
		for _, s in { 1, -1 } do
			local base = (con * CFrame.new(1.8 * s, 0.6, -0.2)).Position
			B:block("Root", v(0.45, 0.3, 0.45), CFrame.new(base + v(0, 0.1, 0)), SP_L)
			B:block("Root", v(0.14, 0.8, 0.14), CFrame.new(base + v(0, 0.6, 0)), GOLD)
			B:block("Root", v(0.28, 0.28, 0.28), CFrame.new(base + v(0, 1.1, 0)) * ang(45, 45, 0), s > 0 and CYAN or PINK, { mat = "Neon", name = s > 0 and "PostR" or "PostL" })
		end
		local cl = B:block("Root", v(0.3, 0.2, 0.3), con * CFrame.new(0, 0.7, -0.1), SP_L)
		B:light(cl, { color = CYAN, brightness = 0.8, range = 10, name = "ConsoleLight" })

		----------------------------------------------- handrails
		B:sym(function()
			B:bar("Root", v(2.35, 5.15, -3.5), v(2.35, 4.4, -0.7), 0.4, 0.4, SP_L)
			B:bar("Root", v(2.35, 4.95, -2.6), v(2.35, 4.5, -1.0), 0.5, 0.5, SP_D)
			B:block("Root", v(0.55, 0.3, 0.55), cf(2.35, 4.4, -0.75), GOLD)
		end)

		---------------------------------------------- nebula glow + motes
		local nebR = B:block("Root", v(1.2, 1.2, 1.2), cf(2.4, 7.4, ZA), PINK, { tr = 1 })
		local nebL = B:block("Root", v(1.2, 1.2, 1.2), cf(-2.4, 7.4, ZA), CYAN, { tr = 1 })
		B:emitter(nebR, "glow", { color = { PINK, VIO }, rate = 2.5, size = { 1.5, 2.6, 0.8 }, name = "NebulaPink" })
		B:emitter(nebL, "glow", { color = { CYAN, VIO }, rate = 2.5, size = { 1.5, 2.6, 0.8 }, name = "NebulaCyan" })
		B:emitter(B:block("Root", v(6.5, 3.0, 2.0), cf(0, 6.5, ZA), STAR, { tr = 1 }), "sparkle", { color = { STAR, CYAN, PINK }, rate = 10, size = { 0.1, 0.35, 0 }, speed = { 0.1, 0.5 }, name = "Starfield" })
		B:emitter(thr[1], "ember", { color = { CYAN, VIO }, rate = 10, speed = { 2, 4 }, accel = { 0, 0.5, 4 }, spread = 12, dir = "Back", name = "ThrustR" })
		B:emitter(thr[2], "ember", { color = { PINK, VIO }, rate = 10, speed = { 2, 4 }, accel = { 0, 0.5, 4 }, spread = 12, dir = "Back", name = "ThrustL" })
	end,
}
