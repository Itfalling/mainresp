-- Treadmill15 "Apex Hyper Treadmill" (tier 14, the ultimate). Faces -Z.
-- A black-gunmetal hyper machine with amber/orange armour trim and cyan plasma:
--   * plasma REACTOR in the nose: a tumbling plasma core held by 4 tesla
--     pylons (arcs flash), wrapped in TWO COUNTER-ROTATING ENERGY RINGS
--     (cyan outer, orange inner on a tilted axis) + orbiting plasma cubes
--   * floating HOLOGRAM console projected from a chrome projector bar
--   * ENERGY-PULSE belt: cyan seams with plasma pulses racing to the back
--   * 6 hydraulic PISTONS pumping in sequence along the sides
--   * rear gantry with rising energy collars + chevron chase lights
--   * twin rear plasma thrusters, turbine hubs, conduits that chase backward
return {
	DisplayName = "Apex Hyper Treadmill",
	Rarity = "Apex",
	Element = "Plasma",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local D1, D2, D3 = "#17191f", "#2b303b", "#474e5e" -- gunmetal
		local C1, C2 = "#ccd3df", "#8a94a6" -- chrome
		local A1, A2, A3 = "#ffd23f", "#ff9a1a", "#d4451c" -- amber armour trim
		local CY, HOT = "#3ff4ff", "#ff7a1a" -- neon: plasma cyan + hot orange
		local BED = "#0d0f14"

		------------------------------------------------------------ chassis
		B:block("Root", v(6.4, 0.3, 10.4), cf(0, 0.15, 0.6), D1)
		B:block("Root", v(6.0, 0.8, 10.0), cf(0, 0.7, 0.6), D2)
		B:block("Root", v(6.1, 0.14, 10.1), cf(0, 0.36, 0.6), A3)
		B:sym(function(side)
			-- armoured side skirt + plasma conduit on top (chases backward)
			B:block("Root", v(0.5, 1.0, 9.4), cf(3.15, 0.85, 0.6), D3)
			B:block("Root", v(0.56, 0.12, 9.46), cf(3.15, 1.3, 0.6), A2)
			for i = 1, 8 do
				B:block("Root", v(0.22, 0.06, 0.8), cf(3.15, 1.39, -3.25 + (i - 1) * 1.1), CY, { mat = "Neon", name = "Flow" .. side .. i })
			end
			-- runner rails
			B:block("Root", v(1.0, 0.34, 8.0), cf(2.25, 1.45, 0.55), D3)
			B:block("Root", v(0.3, 0.08, 8.02), cf(2.6, 1.65, 0.55), A1)
			B:block("Root", v(0.1, 0.06, 8.02), cf(1.8, 1.64, 0.55), HOT, { mat = "Neon" })
		end)
		B:block("Root", v(3.5, 0.1, 8.0), cf(0, 1.32, 0.55), BED)

		------------------------------------- energy-pulse belt (period 0.5)
		local belt = B:bone("Belt", "Root", v(0, 1.42, 0))
		for i = 0, 16 do
			local z = -3.6 + i * 0.5
			B:block(belt, v(3.36, 0.07, 0.26), cf(0, 1.41, z), D3)
			B:block(belt, v(2.6, 0.06, 0.07), cf(0, 1.4, z + 0.25), CY, { mat = "Neon", name = "Seam" .. (i + 1) })
			B:block(belt, v(0.3, 0.075, 0.27), cf(1.5, 1.412, z), A2)
			B:block(belt, v(0.3, 0.075, 0.27), cf(-1.5, 1.412, z), A2)
		end

		---------------------------------------------- front hood + rear cap
		B:block("Root", v(4.8, 0.7, 1.2), cf(0, 1.6, -3.9), D3)
		B:block("Root", v(4.9, 0.12, 1.25), cf(0, 1.98, -3.9), A2)
		B:block("Root", v(3.0, 0.1, 0.3), cf(0, 2.06, -3.45), CY, { mat = "Neon" })
		B:block("Root", v(5.0, 0.55, 1.2), cf(0, 1.45, 5.0), D3)
		B:block("Root", v(5.1, 0.1, 1.25), cf(0, 1.76, 5.0), A2)
		-- hazard stripes on the rear entry step
		B:block("Root", v(3.0, 0.45, 1.0), cf(0, 0.5, 6.1), D1)
		for i = -2, 2 do
			B:block("Root", v(0.32, 0.06, 1.02), cf(i * 0.6, 0.75, 6.1, 0, 30, 0), A1)
		end

		------------------------------------------------- twin rear thrusters
		B:sym(function(side)
			local x = 2.35
			B:block("Root", v(1.3, 1.3, 1.2), cf(x, 1.05, 6.0), D2)
			B:block("Root", v(1.4, 0.16, 1.25), cf(x, 1.75, 6.0), A2)
			B:block("Root", v(1.0, 1.0, 0.2), cf(x, 1.05, 6.62), C2)
			B:block("Root", v(0.7, 0.7, 0.2), cf(x, 1.05, 6.66), D1)
			local core = B:block("Root", v(0.46, 0.46, 0.12), cf(x, 1.05, 6.74), HOT, { mat = "Neon", name = "Nozzle" .. side })
			B:emitter(core, "fire", { color = { "#bffbff", CY, HOT }, rate = 22, size = { 0.7, 0.45, 0 }, speed = { 4, 7 }, life = { 0.25, 0.45 }, accel = { 0, 1, 0 }, spread = 8, dir = "Back", name = "Thrust" .. side })
		end)

		------------------------------------------------- turbine hubs (spin)
		for _, h in { { "HubFR", 3.45, -3.85 }, { "HubFL", -3.45, -3.85 }, { "HubRR", 3.45, 4.7 }, { "HubRL", -3.45, 4.7 } } do
			local b = B:bone(h[1], "Root", v(h[2], 0.85, h[3]))
			local c = cf(h[2], 0.85, h[3])
			local sx = h[2] > 0 and 1 or -1
			for k = 0, 2 do
				B:block(b, v(0.16, 0.95, 0.24), c * ang(k * 60, 0, 0), k == 0 and A2 or D3)
			end
			B:block(b, v(0.2, 0.42, 0.42), c * CFrame.new(sx * 0.04, 0, 0), C1)
			B:block(b, v(0.22, 0.2, 0.2), c * CFrame.new(sx * 0.07, 0, 0), CY, { mat = "Neon" })
		end

		----------------------------------------------- hydraulic pistons (6)
		B:sym(function(side)
			for i, z in { -2.8, -0.6, 1.6 } do
				local x = 3.85
				B:block("Root", v(1.1, 1.3, 1.1), cf(x, 0.65, z), D2)
				B:block("Root", v(1.2, 0.2, 1.2), cf(x, 1.35, z), A2)
				B:block("Root", v(0.8, 0.26, 0.8), cf(x, 1.56, z), C2)
				B:block("Root", v(0.12, 0.7, 0.5), cf(x + 0.56, 0.7, z), D1)
				local pb = B:bone("Piston" .. side .. i, "Root", v(x, 1.5, z))
				B:block(pb, v(0.42, 2.5, 0.42), cf(x, 1.55, z), C1)
				B:block(pb, v(0.95, 0.4, 0.95), cf(x, 2.95, z), D3)
				B:block(pb, v(0.75, 0.14, 0.75), cf(x, 3.22, z), A1)
				B:block(pb, v(0.34, 0.1, 0.34), cf(x, 3.33, z), HOT, { mat = "Neon", name = "PistonTip" .. side .. i })
			end
		end)
		local steamP = B:block("Root", v(0.4, 0.2, 5.0), cf(4.5, 1.2, -0.6), D1, { tr = 1, name = "SteamSrc" })
		B:emitter(steamP, "smoke", { color = { "#ffffff", "#c9d6e6" }, rate = 0, size = { 0.6, 1.4, 2 }, speed = { 1, 2.5 }, life = { 0.6, 1.1 }, name = "Steam" })

		------------------------------------------------------ reactor bay
		local K = v(0, 5.5, -6.6)
		B:block("Root", v(5.8, 0.3, 4.8), cf(0, 0.15, -6.6), D1)
		B:block("Root", v(5.4, 1.1, 4.4), cf(0, 0.85, -6.6), D2)
		B:block("Root", v(5.5, 0.14, 4.5), cf(0, 1.38, -6.6), A3)
		B:block("Root", v(4.6, 0.5, 3.8), cf(0, 1.65, -6.6), D3)
		B:block("Root", v(4.7, 0.1, 3.9), cf(0, 1.92, -6.6), A2)
		B:block("Root", v(2.2, 0.2, 2.2), cf(0, 2.02, -6.6), C1)
		B:ring("Root", CFrame.new(0, 2.15, -6.6), 0.75, 8, v(0.5, 0.08, 0.14), CY, { mat = "Neon" })
		-- hazard chevrons on the nose
		for i = -2, 2 do
			B:block("Root", v(0.3, 0.9, 0.06), cf(i * 0.8, 0.85, -8.83, 0, 0, 30), A1)
		end
		B:sym(function(side)
			B:block("Root", v(0.6, 0.3, 0.1), cf(2.2, 1.65, -8.52), HOT, { mat = "Neon" })
		end)
		-- four tesla pylons around the core, arcs flash from their nozzles
		local arcN = 0
		for _, pz in { -8.3, -4.9 } do
			B:sym(function(side)
				local x = 2.6
				B:block("Root", v(1.1, 0.4, 1.1), cf(x, 2.1, pz), D1)
				B:block("Root", v(0.75, 1.3, 0.75), cf(x, 2.9, pz), D3)
				B:block("Root", v(0.85, 0.18, 0.85), cf(x, 2.7, pz), A2)
				B:block("Root", v(1.0, 0.5, 1.0), cf(x, 3.7, pz), C2)
				B:block("Root", v(0.6, 0.25, 0.6), cf(x, 4.05, pz), A1)
				B:bar("Root", v(x - 0.2, 3.8, pz), v(x - 0.55, 4.25, pz + (K.Z - pz) * 0.15), 0.4, 0.4, D2)
				B:block("Root", v(0.34, 0.34, 0.34), CFrame.new(v(x - 0.6, 4.3, pz + (K.Z - pz) * 0.16)) * ang(45, 0, 45), CY, { mat = "Neon" })
			end)
			for _, sx in { 1, -1 } do
				arcN += 1
				local from = v(sx * 2.0, 4.3, pz + (K.Z - pz) * 0.16)
				local to = K + (from - K).Unit * 0.75
				local mid = (from + to) / 2 + v(sx * 0.3, -0.25, 0)
				B:bar("Root", from, mid, 0.12, 0.12, CY, { mat = "Neon", name = "ArcA" .. arcN })
				B:bar("Root", mid, to, 0.12, 0.12, CY, { mat = "Neon", name = "ArcB" .. arcN })
			end
		end

		-- plasma core (tumbles)
		local core = B:bone("Core", "Root", K)
		local heart = B:block(core, v(0.75, 0.75, 0.75), CFrame.new(K) * ang(45, 45, 0), "#e8feff", { mat = "Neon", name = "CoreHeart" })
		B:block(core, v(1.25, 1.25, 1.25), CFrame.new(K) * ang(45, 45, 0), CY, { mat = "Neon", tr = 0.55, name = "CoreShell" })
		for k = 0, 3 do
			B:block(core, v(0.3, 0.9, 0.3), CFrame.new(K) * ang(0, k * 90, 0) * CFrame.new(0, 0, -0.95), A1)
		end
		B:emitter(heart, "glow", { color = { "#dffcff", CY }, rate = 3, size = { 1.6, 3.4, 1 }, name = "CoreGlow" })
		B:emitter(heart, "spark", { color = { "#ffffff", CY }, rate = 9, name = "CoreSparks" })
		B:light(heart, { color = CY, brightness = 1.2, range = 14, name = "CoreLight" })
		local burstP = B:block("Root", v(0.4, 0.4, 0.4), CFrame.new(K + v(0, -1.0, 0)), D1, { tr = 1, name = "BurstSrc" })
		B:emitter(burstP, "burst", { color = { "#ffffff", CY, HOT }, size = { 0.9, 0.6, 0 }, name = "Burst" })

		-- outer energy ring (cyan): vertical, spins about Y
		local ringA = B:bone("RingA", "Root", K)
		local acf = CFrame.new(K) * ang(90, 0, 0)
		B:ring(ringA, acf, 2.55, 10, v(0.82, 0.38, 0.34), D3)
		B:ring(ringA, acf * ang(0, 18, 0), 2.55, 10, v(0.82, 0.35, 0.34), A2)
		B:ring(ringA, acf * ang(0, 9, 0), 2.28, 20, v(0.7, 0.1, 0.08), CY, { mat = "Neon" })
		for k = 0, 3 do
			B:block(ringA, v(0.4, 0.48, 0.46), acf * ang(0, k * 90, 0) * CFrame.new(0, 0, -2.55), CY, { mat = "Neon", name = "RingANode" .. (k + 1) })
		end
		B:trail(ringA, K + v(2.5, 0, 0), K + v(2.95, 0, 0), { color = { CY, "#ffffff" }, life = 0.3, name = "RingATrailR" })
		B:trail(ringA, K + v(-2.5, 0, 0), K + v(-2.95, 0, 0), { color = { CY, "#ffffff" }, life = 0.3, name = "RingATrailL" })

		-- inner energy ring (orange): tilted axis, counter-rotates
		local bpv = CFrame.new(K) * ang(28, 0, 0)
		local ringB = B:bone("RingB", "Root", bpv)
		local bcf = bpv * ang(0, 0, 90)
		B:ring(ringB, bcf, 1.95, 10, v(0.62, 0.32, 0.28), D2)
		B:ring(ringB, bcf * ang(0, 18, 0), 1.95, 10, v(0.62, 0.3, 0.28), A3)
		B:ring(ringB, bcf * ang(0, 9, 0), 1.72, 20, v(0.5, 0.09, 0.07), HOT, { mat = "Neon" })
		for k = 0, 3 do
			B:block(ringB, v(0.34, 0.4, 0.4), bcf * ang(0, k * 90 + 45, 0) * CFrame.new(0, 0, -1.95), A1, { name = "RingBNode" .. (k + 1) })
		end
		local tB1 = bpv * v(0, 0, -1.9)
		local tB2 = bpv * v(0, 0, 1.9)
		B:trail(ringB, tB1, bpv * v(0, 0, -2.3), { color = { HOT, A1 }, life = 0.3, name = "RingBTrailF" })
		B:trail(ringB, tB2, bpv * v(0, 0, 2.3), { color = { HOT, A1 }, life = 0.3, name = "RingBTrailB" })

		-- plasma cubes orbiting the core
		for i, o in { { 1.3, 20, CY }, { 1.3, -35, HOT } } do
			local pv = CFrame.new(K) * ang(o[2], 0, 0)
			local b = B:bone("Orbit" .. i, "Root", pv)
			local p = pv * v(o[1], 0, 0)
			B:block(b, v(0.26, 0.26, 0.26), CFrame.new(p) * ang(45, 45, 0), o[3], { mat = "Neon" })
			B:trail(b, p + v(0, 0.1, 0), p - v(0, 0.1, 0), { color = { o[3], "#ffffff" }, life = 0.25, name = "OrbitTrail" .. i })
		end

		------------------------------------------ projector + hologram console
		B:sym(function(side)
			local x = 2.1
			B:block("Root", v(0.62, 2.4, 0.62), cf(x, 2.8, -3.5), D3)
			B:block("Root", v(0.72, 0.18, 0.72), cf(x, 2.1, -3.5), A2)
			B:block("Root", v(0.72, 0.18, 0.72), cf(x, 3.3, -3.5), A2)
			-- armoured handrails with grips
			B:bar("Root", v(x + 0.25, 3.85, -3.25), v(x + 0.25, 4.2, -0.9), 0.36, 0.36, D3)
			B:bar("Root", v(x + 0.25, 3.98, -2.6), v(x + 0.25, 4.15, -1.3), 0.46, 0.46, D1)
			B:block("Root", v(0.5, 0.5, 0.5), cf(x + 0.25, 4.2, -0.88), A2)
			B:block("Root", v(0.12, 0.08, 1.0), cf(x + 0.25, 4.32, -1.95, -7, 0, 0), HOT, { mat = "Neon" })
		end)
		B:block("Root", v(4.8, 0.55, 0.9), cf(0, 4.1, -3.55), D2)
		B:block("Root", v(4.9, 0.12, 0.95), cf(0, 3.82, -3.55), A2)
		B:block("Root", v(4.4, 0.35, 0.06), cf(0, 4.1, -3.08), C2)
		for i, x in { -1.2, 0, 1.2 } do
			B:block("Root", v(0.5, 0.1, 0.4), cf(x, 4.42, -3.55), CY, { mat = "Neon" })
		end
		local HP = v(0, 5.35, -3.45)
		local holo = B:bone("Holo", "Root", HP)
		local H = CFrame.new(HP) * ang(-25, 0, 0)
		B:block(holo, v(3.4, 1.3, 0.04), H, CY, { mat = "Neon", tr = 0.6, name = "HoloPanel" })
		B:block(holo, v(3.5, 0.08, 0.06), H * CFrame.new(0, 0.68, 0), CY, { mat = "Neon", name = "HoloEdge1" })
		B:block(holo, v(3.5, 0.08, 0.06), H * CFrame.new(0, -0.68, 0), CY, { mat = "Neon", name = "HoloEdge2" })
		B:block(holo, v(0.08, 1.3, 0.06), H * CFrame.new(1.73, 0, 0), CY, { mat = "Neon", name = "HoloEdge3" })
		B:block(holo, v(0.08, 1.3, 0.06), H * CFrame.new(-1.73, 0, 0), CY, { mat = "Neon", name = "HoloEdge4" })
		for i = 1, 8 do
			local hgt = 0.12 + (i - 1) * 0.1
			B:block(holo, v(0.2, hgt, 0.05), H * CFrame.new(-1.45 + (i - 1) * 0.28, -0.5 + hgt / 2, 0.05), HOT, { mat = "Neon", name = "Bar" .. i })
		end
		B:block(holo, v(1.0, 0.08, 0.05), H * CFrame.new(1.0, 0.45, 0.05), "#ffffff", { mat = "Neon", name = "HoloText1" })
		B:block(holo, v(0.7, 0.08, 0.05), H * CFrame.new(0.85, 0.3, 0.05), "#ffffff", { mat = "Neon", name = "HoloText2" })
		local gp = H * CFrame.new(1.1, -0.18, 0.06)
		local gauge = B:bone("HoloRing", "Holo", gp)
		B:ring(gauge, gp * ang(90, 0, 0), 0.34, 6, v(0.2, 0.05, 0.07), A1, { mat = "Neon" })
		B:block(gauge, v(0.06, 0.3, 0.05), gp * CFrame.new(0, 0.15, 0.01), "#ffffff", { mat = "Neon" })
		B:sym(function(side)
			local sp = H * CFrame.new(2.2, 0.08, 0.32) * ang(0, -28, 0)
			B:block(holo, v(0.95, 1.05, 0.04), sp, CY, { mat = "Neon", tr = 0.6, name = "HoloSide" .. side })
			B:block(holo, v(0.6, 0.07, 0.05), sp * CFrame.new(0, 0.25, 0.03), HOT, { mat = "Neon" })
			B:block(holo, v(0.45, 0.07, 0.05), sp * CFrame.new(-0.07, 0.05, 0.03), HOT, { mat = "Neon" })
			B:block(holo, v(0.6, 0.07, 0.05), sp * CFrame.new(0, -0.15, 0.03), CY, { mat = "Neon" })
		end)
		-- projection beams (static, faint)
		for i, x in { -1.2, 0, 1.2 } do
			local top = H * v(x * 1.3, -0.66, 0)
			B:bar("Root", v(x, 4.45, -3.55), top, 0.05, 0.05, CY, { mat = "Neon", tr = 0.7, name = "HoloBeam" .. i })
		end

		------------------------------------------------------- rear gantry
		local GZ = 3.3
		B:sym(function(side)
			local x = 3.75
			B:block("Root", v(1.6, 0.6, 1.6), cf(x, 0.3, GZ), D1)
			B:block("Root", v(1.7, 0.12, 1.7), cf(x, 0.62, GZ), A3)
			B:block("Root", v(1.3, 1.6, 1.3), cf(x, 1.4, GZ), D2)
			B:block("Root", v(0.85, 6.0, 0.85), cf(x, 5.0, GZ), D3)
			-- chrome side plates + amber bands
			B:block("Root", v(0.1, 4.8, 0.5), cf(x + 0.45, 4.9, GZ), C2)
			B:block("Root", v(0.5, 4.8, 0.1), cf(x, 4.9, GZ + 0.45), D2)
			B:block("Root", v(0.5, 4.8, 0.1), cf(x, 4.9, GZ - 0.45), D2)
			B:block("Root", v(1.4, 0.16, 1.4), cf(x, 2.25, GZ), A2)
			B:block("Root", v(0.95, 0.16, 0.95), cf(x, 5.2, GZ), A2)
			B:block("Root", v(1.25, 0.5, 1.25), cf(x, 7.8, GZ), D2)
			B:block("Root", v(1.3, 0.1, 1.3), cf(x, 7.5, GZ), A1)
			-- rising energy collars
			for k = 1, 3 do
				local b = B:bone("Collar" .. side .. k, "Root", v(x, 2.4, GZ))
				local nm = "Collar" .. side .. k
				B:block(b, v(1.3, 0.12, 0.12), cf(x, 2.4, GZ - 0.58), CY, { mat = "Neon", name = nm .. "a" })
				B:block(b, v(1.3, 0.12, 0.12), cf(x, 2.4, GZ + 0.58), CY, { mat = "Neon", name = nm .. "b" })
				B:block(b, v(0.12, 0.12, 1.04), cf(x + 0.58, 2.4, GZ), CY, { mat = "Neon", name = nm .. "c" })
				B:block(b, v(0.12, 0.12, 1.04), cf(x - 0.58, 2.4, GZ), CY, { mat = "Neon", name = nm .. "d" })
			end
			-- stepped armour caps on the beam ends
			B:block("Root", v(0.7, 1.0, 1.3), cf(x + 0.65, 8.5, GZ), D3)
			B:block("Root", v(0.5, 0.5, 1.36), cf(x + 0.75, 9.2, GZ), D2)
			B:block("Root", v(0.74, 0.1, 1.34), cf(x + 0.65, 8.02, GZ), A2)
			B:block("Root", v(0.08, 0.5, 0.5), cf(x + 1.02, 8.5, GZ), HOT, { mat = "Neon" })
		end)
		B:block("Root", v(8.6, 0.7, 1.1), cf(0, 8.4, GZ), D2)
		B:block("Root", v(8.7, 0.1, 1.16), cf(0, 8.02, GZ), A2)
		B:block("Root", v(7.6, 0.24, 0.9), cf(0, 8.87, GZ), D3)
		B:block("Root", v(2.0, 0.5, 1.0), cf(0, 9.2, GZ), D2)
		B:block("Root", v(2.1, 0.1, 1.06), cf(0, 9.0, GZ), A1)
		B:gem("Root", v(0.4, 0.4, 1.1), cf(0, 9.2, GZ, 0, 0, 45), CY)
		for i = 1, 5 do
			local x = (i - 3) * 0.9
			B:block("Root", v(0.38, 0.38, 0.06), cf(x, 8.4, GZ + 0.56, 0, 0, 45), HOT, { mat = "Neon", name = "ChevA" .. i })
			B:block("Root", v(0.38, 0.38, 0.06), cf(x, 8.4, GZ - 0.56, 0, 0, 45), HOT, { mat = "Neon", name = "ChevB" .. i })
		end
		local glight = B:block("Root", v(1.0, 0.12, 0.5), cf(0, 7.98, GZ), CY, { mat = "Neon" })
		B:light(glight, { color = HOT, brightness = 0.9, range = 10, name = "GantryLight" })

		-- warp arches floating over the runner (light up in sequence = speed tunnel)
		for k, z in { -0.1, 1.05, 2.2 } do
			local nm = "Warp" .. k
			B:sym(function(side)
				B:block("Root", v(0.6, 0.16, 0.6), cf(2.45, 1.72, z), C2)
				B:block("Root", v(0.3, 0.06, 0.3), cf(2.45, 1.82, z), CY, { mat = "Neon" })
				B:block("Root", v(0.34, 4.6, 0.34), cf(2.45, 4.6, z), D2)
				B:block("Root", v(0.05, 4.4, 0.12), cf(2.26, 4.6, z), CY, { mat = "Neon", name = nm .. side })
				B:block("Root", v(0.44, 0.3, 0.44), cf(2.45, 2.25, z), A2)
			end)
			B:block("Root", v(5.24, 0.34, 0.34), cf(0, 7.05, z), D2)
			B:block("Root", v(4.5, 0.05, 0.12), cf(0, 6.86, z), CY, { mat = "Neon", name = nm .. "T" })
			B:block("Root", v(0.6, 0.4, 0.4), cf(0, 7.1, z), A2)
		end

		-- floating armour shards orbiting high above the reactor (3rd ring)
		local spv = CFrame.new(K + v(0, 1.75, 0)) * ang(-14, 0, 0)
		local shards = B:bone("Shards", "Root", spv)
		for k = 0, 9 do
			local sc = spv * ang(0, k * 36, 0) * CFrame.new(0, 0, -3.0)
			if k % 2 == 0 then
				B:block(shards, v(0.7, 0.36, 0.36), sc, D3)
				B:block(shards, v(0.5, 0.1, 0.4), sc * CFrame.new(0, 0.2, 0), A2)
			else
				B:block(shards, v(0.3, 0.3, 0.3), sc * ang(45, 0, 45), CY, { mat = "Neon" })
			end
		end

		-- plasma motes rising over the deck
		local field = B:block("Root", v(3.0, 0.2, 7.0), cf(0, 2.0, 0.6), D1, { tr = 1, name = "MoteField" })
		B:emitter(field, "sparkle", { color = { "#ffffff", CY, HOT }, rate = 8, speed = { 0.5, 1.4 }, life = { 1, 2 }, accel = { 0, 1.2, 0 }, name = "Motes" })
	end,
}
