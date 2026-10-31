-- Treadmill12 "Storm Treadmill" (tier 11, Mythic).
-- Two tesla pylons hold a big stepped storm cloud over the deck. Lightning
-- bolts (hidden Neon zig-zags) crack down from the cloud onto four copper
-- lightning rods, an electric arc jumps between the coil tops, rain falls.
-- Faces -Z (console at the front).
-- Animated: storm belt (slats + electric seams slide +Z), turbine hubs, twin
-- wind turbines on the pylons, a big rear exhaust fan, a radar sweep on the
-- console, capacitor gauges that charge up over the loop, then a triple-strike
-- finale (bolts flicker, arc crackles, cloud flashes + rumbles, spark bursts).
return {
	DisplayName = "Storm Treadmill",
	Rarity = "Mythic",
	Element = "Storm",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local SLATE, SLATE_D, SLATE_L = "#5b6479", "#2c3244", "#9eaac2"
		local INK, STEEL = "#181c27", "#c9d2e3"
		local COPPER, COPPER_D, COPPER_L = "#d9893a", "#9a5a22", "#f2b46a"
		local HAZ = "#ffd23a"
		local CL_W, CL_L, CL_M, CL_D = "#eef1f7", "#c8cfdc", "#8b94a9", "#5c647c"
		local BOLT, ELEC = "#fff6a0", "#7fe3ff"

		---------------------------------------------------------------- base
		B:block("Root", v(5.4, 0.3, 10.2), cf(0, 0.15, -0.1), INK)
		B:block("Root", v(5.0, 0.8, 9.8), cf(0, 0.7, -0.1), SLATE)
		B:block("Root", v(5.1, 0.12, 9.9), cf(0, 1.06, -0.1), SLATE_L)
		for _, s in { 1, -1 } do
			-- dark side panel with a yellow lightning-bolt decal (stepped zig-zag)
			B:block("Root", v(0.12, 0.5, 9.2), cf(s * 2.53, 0.55, -0.1), SLATE_D)
			for _, z0 in { -2.6, 2.4 } do
				B:block("Root", v(0.1, 0.14, 0.7), cf(s * 2.6, 0.72, z0 - 0.3), HAZ)
				B:block("Root", v(0.1, 0.14, 0.5), cf(s * 2.6, 0.58, z0 + 0.1), HAZ)
				B:block("Root", v(0.1, 0.14, 0.7), cf(s * 2.6, 0.44, z0 + 0.45), HAZ)
			end
			B:block("Root", v(0.16, 0.16, 9.6), cf(s * 2.56, 0.92, -0.1), INK)
			-- outrigger brackets for the pylons and lightning rods
			B:block("Root", v(1.6, 0.5, 1.8), cf(s * 3.05, 0.25, 1.0), SLATE_D)
			for _, z in { -1.6, 3.6 } do
				B:block("Root", v(1.2, 0.4, 0.9), cf(s * 2.9, 0.2, z), SLATE_D)
				B:block("Root", v(1.3, 0.1, 1.0), cf(s * 2.9, 0.42, z), HAZ)
			end
		end
		for i = 1, 8 do
			local z = -4.1 + (i - 1) * 1.15
			B:block("Root", v(0.1, 0.12, 0.8), cf(2.66, 0.92, z), ELEC, { mat = "Neon", name = "ChR" .. i })
			B:block("Root", v(0.1, 0.12, 0.8), cf(-2.66, 0.92, z), ELEC, { mat = "Neon", name = "ChL" .. i })
		end
		-- foot rails with yellow/black hazard ends
		B:sym(function()
			B:block("Root", v(0.8, 0.3, 7.0), cf(2.1, 1.35, 0.1), SLATE_L)
			B:block("Root", v(0.82, 0.06, 6.0), cf(2.1, 1.52, 0.1), STEEL)
			for k = 0, 3 do
				B:block("Root", v(0.84, 0.32, 0.25), cf(2.1, 1.36, 3.0 + k * 0.25), k % 2 == 0 and HAZ or INK)
			end
		end)
		B:block("Root", v(3.5, 0.1, 8.4), cf(0, 1.17, 0.1), INK)

		-------------------------------------------------- belt (slides +Z)
		local belt = B:bone("Belt", "Root", v(0, 1.3, 0))
		for i = 0, 16 do
			local z = -4.4 + i * 0.5
			if i % 2 == 0 then
				B:block(belt, v(3.4, 0.08, 0.4), cf(0, 1.27, z), "#3a4152")
			else
				B:block(belt, v(3.4, 0.08, 0.4), cf(0, 1.27, z), "#4b5367")
				-- electric seam with a little zig in the middle
				B:block(belt, v(1.4, 0.03, 0.07), cf(-0.95, 1.32, z + 0.22), BOLT, { mat = "Neon" })
				B:block(belt, v(0.5, 0.03, 0.07), cf(0, 1.32, z + 0.12), BOLT, { mat = "Neon" })
				B:block(belt, v(1.4, 0.03, 0.07), cf(0.95, 1.32, z + 0.02), BOLT, { mat = "Neon" })
			end
		end

		-------------------------------------------- motor hood + rear cap
		B:block("Root", v(5.0, 0.9, 1.6), cf(0, 1.45, -4.2), SLATE_D)
		B:block("Root", v(4.8, 0.2, 1.5), cf(0, 2.0, -4.2), SLATE_L)
		for k = 0, 7 do -- hazard stripe across the hood front
			B:block("Root", v(0.55, 0.3, 0.1), cf(-1.93 + k * 0.55, 1.55, -5.02), k % 2 == 0 and HAZ or INK)
		end
		B:block("Root", v(3.0, 0.12, 0.8), cf(0, 2.15, -4.3), INK)
		B:block("Root", v(2.4, 0.05, 0.16), cf(0, 2.23, -4.0), ELEC, { mat = "Neon" })
		B:block("Root", v(5.0, 0.6, 1.3), cf(0, 1.35, 4.25), SLATE_D)
		B:block("Root", v(5.1, 0.12, 1.4), cf(0, 1.68, 4.25), SLATE_L)

		------------------------------------------ turbine roller hubs (4)
		local function hub(name, x, y, z, r)
			local b = B:bone(name, "Root", v(x, y, z))
			local c = cf(x, y, z)
			B:block(b, v(0.2, 2 * r * 0.75, 2 * r * 0.75), c, SLATE_L)
			B:block(b, v(0.2, 2 * r * 0.75, 2 * r * 0.75), c * ang(45, 0, 0), SLATE_L)
			for k = 0, 3 do
				B:block(b, v(0.24, 0.18, r), c * ang(90 * k, 0, 0) * CFrame.new(0.02, 0, -r * 0.5) * ang(0, 0, 0), HAZ)
			end
			B:block(b, v(0.28, 0.26, 0.26), c, BOLT, { mat = "Neon" })
		end
		hub("HubFR", 2.62, 1.45, -4.2, 0.7)
		hub("HubFL", -2.62, 1.45, -4.2, 0.7)
		hub("HubRR", 2.62, 1.3, 4.25, 0.55)
		hub("HubRL", -2.62, 1.3, 4.25, 0.55)

		---------------------------------------------------- tesla pylons
		local TOP = 7.9
		for _, s in { 1, -1 } do
			local x, z = 3.2 * s, 1.0
			local tag = s > 0 and "R" or "L"
			B:block("Root", v(1.6, 0.9, 1.6), cf(x, 0.95, z), SLATE_D)
			B:block("Root", v(1.75, 0.2, 1.75), cf(x, 1.45, z), HAZ)
			B:block("Root", v(1.1, 5.0, 1.1), cf(x, 4.0, z), SLATE)
			B:block("Root", v(0.5, 4.6, 1.16), cf(x, 4.0, z), SLATE_L)
			for _, y in { 2.4, 4.3, 6.4 } do
				B:block("Root", v(1.4, 0.3, 1.4), cf(x, y, z), SLATE_D)
			end
			-- copper coil stack under the cloud
			for k = 0, 4 do
				local w = 1.35 - k * 0.12
				B:block("Root", v(w, 0.18, w), cf(x, 6.75 + k * 0.24, z), k % 2 == 0 and COPPER or COPPER_D)
			end
			B:block("Root", v(0.7, 0.7, 0.7), cf(x, 7.65, z), COPPER_L)
			B:block("Root", v(0.45, 0.45, 0.45), cf(x, 7.65, z, 0, 45, 0), ELEC, { mat = "Neon", name = "Coil" .. tag })
			-- capacitor gauge on the inner face (charges up over the loop)
			B:block("Root", v(0.14, 2.9, 0.75), cf(x - 0.6 * s, 3.35, z), INK)
			for k = 1, 6 do
				B:block("Root", v(0.08, 0.36, 0.5), cf(x - 0.69 * s, 2.1 + (k - 1) * 0.47, z), k > 4 and BOLT or ELEC, { mat = "Neon", name = "Cap" .. tag .. k })
			end
			-- charge flowing up the pylon front (chase lights)
			B:block("Root", v(0.55, 3.3, 0.1), cf(x, 3.6, z - 0.6), INK)
			for k = 1, 6 do
				B:block("Root", v(0.36, 0.34, 0.08), cf(x, 2.2 + (k - 1) * 0.55, z - 0.66), ELEC, { mat = "Neon", name = "Up" .. tag .. k })
			end
			-- wind turbine on the outer face (spins about X)
			B:block("Root", v(0.7, 0.8, 1.3), cf(x + 0.85 * s, 5.2, z), SLATE_D)
			B:block("Root", v(0.75, 0.2, 1.35), cf(x + 0.85 * s, 5.65, z), HAZ)
			local tx = x + 1.35 * s
			local tb = B:bone("Turb" .. tag, "Root", v(tx, 5.2, z))
			B:block(tb, v(0.35, 0.55, 0.55), cf(tx, 5.2, z, 45, 0, 0), STEEL)
			B:block(tb, v(0.4, 0.3, 0.3), cf(tx + 0.05 * s, 5.2, z), ELEC, { mat = "Neon" })
			for k = 0, 3 do
				local a = cf(tx, 5.2, z) * ang(90 * k + 45, 0, 0)
				B:block(tb, v(0.12, 0.45, 1.35), a * CFrame.new(0, 0, -0.95) * ang(0, 0, 18), STEEL)
				B:block(tb, v(0.14, 0.47, 0.3), a * CFrame.new(0, 0, -1.55) * ang(0, 0, 18), k % 2 == 0 and HAZ or "#e8413a")
			end
			B:trail(tb, (cf(tx, 5.2, z) * ang(45, 0, 0) * CFrame.new(0, 0, -1.2)).Position, (cf(tx, 5.2, z) * ang(45, 0, 0) * CFrame.new(0, 0, -1.7)).Position, { color = { "#ffffff", ELEC }, life = 0.25, trans = { 0.4, 1 }, name = "TurbTrail" .. tag .. "1" })
			B:trail(tb, (cf(tx, 5.2, z) * ang(225, 0, 0) * CFrame.new(0, 0, -1.2)).Position, (cf(tx, 5.2, z) * ang(225, 0, 0) * CFrame.new(0, 0, -1.7)).Position, { color = { "#ffffff", ELEC }, life = 0.25, trans = { 0.4, 1 }, name = "TurbTrail" .. tag .. "2" })
		end

		-------------------------------------------------- lightning rods (4)
		local rods = { { 3.0, -1.6 }, { -3.0, -1.6 }, { 3.0, 3.6 }, { -3.0, 3.6 } }
		local rodTips = {}
		for n, r in rods do
			local x, z = r[1], r[2]
			B:block("Root", v(0.5, 2.6, 0.5), cf(x, 1.7, z), SLATE_D)
			B:block("Root", v(0.62, 0.3, 0.62), cf(x, 0.6, z), SLATE_L)
			for k = 0, 2 do
				B:block("Root", v(0.8 - k * 0.12, 0.16, 0.8 - k * 0.12), cf(x, 2.55 + k * 0.24, z), k % 2 == 0 and COPPER or COPPER_D)
			end
			B:block("Root", v(0.16, 0.6, 0.16), cf(x, 3.35, z), COPPER_L)
			rodTips[n] = B:block("Root", v(0.34, 0.34, 0.34), cf(x, 3.75, z, 0, 45, 0), BOLT, { mat = "Neon", name = "RodTip" .. n })
		end

		------------------------------------------------------- storm cloud
		local CZ = 1.0
		local cloud = B:bone("Cloud", "Root", v(0, 8.6, CZ))
		-- lumpy stepped cloud: dark belly, mid-gray body lumps, bright tops
		B:block(cloud, v(6.2, 0.5, 5.6), cf(0, 8.05, CZ), CL_D)
		B:block(cloud, v(5.6, 0.9, 5.0), cf(0, 8.6, CZ), CL_M)
		local lumps = {
			-- x, z, w, d, h, y, color
			{ -3.0, -1.4, 2.0, 2.2, 1.1, 8.45, CL_M }, { -3.3, 1.2, 1.8, 2.4, 0.9, 8.35, CL_D }, { 3.1, -1.0, 2.0, 2.6, 1.0, 8.4, CL_D },
			{ 3.2, 1.6, 1.8, 2.0, 1.1, 8.5, CL_M }, { -1.0, -3.0, 2.6, 1.6, 0.9, 8.4, CL_D }, { 1.4, -2.9, 2.0, 1.6, 1.1, 8.5, CL_M },
			{ -1.4, 3.1, 2.4, 1.6, 1.0, 8.45, CL_M }, { 1.4, 3.0, 2.2, 1.8, 0.9, 8.35, CL_D },
			{ -2.4, -0.2, 2.4, 2.6, 0.9, 9.25, CL_L }, { 0.2, -1.2, 2.8, 2.4, 1.0, 9.35, CL_W }, { 2.3, 0.7, 2.4, 2.6, 0.9, 9.25, CL_L },
			{ -0.8, 1.7, 2.6, 2.0, 0.8, 9.2, CL_W }, { 1.9, -2.2, 1.6, 1.4, 0.7, 9.1, CL_W }, { -2.3, 2.3, 1.6, 1.4, 0.7, 9.05, CL_W },
			{ 3.4, -1.0, 1.1, 1.4, 0.6, 9.05, CL_L }, { -3.4, -1.6, 1.2, 1.2, 0.6, 9.1, CL_L },
			{ -0.6, 0.2, 1.8, 1.8, 0.6, 9.95, CL_W }, { 1.5, 1.2, 1.2, 1.2, 0.5, 9.85, CL_W }, { -1.9, -1.2, 1.2, 1.2, 0.5, 9.7, CL_W },
		}
		for _, p in lumps do
			B:block(cloud, v(p[3], p[5], p[4]), cf(p[1], p[6], CZ + p[2]), p[7])
		end
		-- dark hanging underside lumps
		for _, p in { { -2.2, -1.5, 1.6 }, { 1.0, -2.2, 1.4 }, { 2.4, 1.0, 1.8 }, { -0.8, 1.9, 1.6 }, { 0.2, -0.2, 1.2 } } do
			B:block(cloud, v(p[3], 0.35, p[3]), cf(p[1], 7.68, CZ + p[2]), "#474e64")
		end
		-- hidden flash patches inside the cloud underside
		for k, p in { { -2.2, -1.5 }, { 2.4, 1.0 }, { -0.8, 1.9 }, { 1.0, -2.2 } } do
			B:block(cloud, v(1.1, 0.06, 1.1), cf(p[1], 7.48, CZ + p[2]), BOLT, { mat = "Neon", tr = 1, name = "Flash" .. k })
		end
		-- sheet-lightning strips glowing along the cloud belly edges
		for k, p in { { 0, -1.75, 5.0, 0.12 }, { 0, 3.75, 5.0, 0.12 }, { 3.0, 1.0, 0.12, 4.6 }, { -3.0, 1.0, 0.12, 4.6 }, { -1.6, 1.6, 1.6, 0.1 }, { 1.4, -0.5, 1.4, 0.1 } } do
			B:block(cloud, v(p[3], 0.08, p[4]), cf(p[1], 7.78, p[2]), k % 2 == 0 and ELEC or BOLT, { mat = "Neon", name = "Sheet" .. k })
		end
		local rainPlate = B:block(cloud, v(5.6, 0.2, 5.4), cf(0, 7.7, CZ), CL_D, { tr = 1 })
		B:emitter(rainPlate, "drip", { color = { "#bfe8ff", "#7fc8ff" }, rate = 22, size = { 0.12, 0.1, 0.06 }, life = { 0.35, 0.55 }, speed = { 4, 6 }, accel = { 0, -30, 0 }, name = "Rain" })
		B:emitter(B:block(cloud, v(6.5, 0.6, 5.5), cf(0, 8.8, CZ), CL_M, { tr = 1 }), "smoke", { color = { "#c9d0dc", "#8a93a6" }, rate = 3, size = { 1.5, 3, 4 }, speed = { 0.2, 0.6 }, accel = { 0, 0.2, 0 }, name = "CloudMist" })
		-- two little cloudlets drifting round the big one
		local wisps = B:bone("Wisps", "Root", v(0, 8.9, CZ))
		for k, a in { 30, 210 } do
			local wc = cf(0, 8.9, CZ) * ang(0, a, 0) * CFrame.new(0, 0, -4.6)
			B:block(wisps, v(1.4, 0.5, 1.0), wc, CL_L)
			B:block(wisps, v(0.9, 0.4, 0.8), wc * CFrame.new(0.3, 0.38, 0), CL_W)
			B:block(wisps, v(0.8, 0.3, 0.7), wc * CFrame.new(-0.55, -0.15, 0.1), CL_M)
			B:block(wisps, v(0.06, 0.6, 0.06), wc * CFrame.new(0.2, -0.55, 0) * ang(0, 0, 15), BOLT, { mat = "Neon", tr = 1, name = "WispBolt" .. k })
		end
		local flashCore = B:block(cloud, v(0.4, 0.2, 0.4), cf(0, 7.55, CZ), BOLT, { tr = 1 })
		B:light(flashCore, { color = "#fff4c2", brightness = 0.4, range = 16, name = "StormLight" })

		---------------------------------------------- lightning bolts (hidden)
		-- each bolt: 4 zig-zag segments from the cloud underside to a rod tip,
		-- plus a short fork. Revealed with ctx.transparency on strikes.
		for n, r in rods do
			local x, z = r[1], r[2]
			local s = x > 0 and 1 or -1
			local pts = {
				v(x + 0.1 * s, 7.75, z + 0.1),
				v(x + 0.55 * s, 6.75, z + 0.35),
				v(x - 0.2 * s, 5.8, z - 0.25),
				v(x + 0.45 * s, 4.75, z + 0.2),
				v(x, 3.85, z),
			}
			for k = 1, 4 do
				B:bar("Root", pts[k], pts[k + 1], 0.2, 0.2, BOLT, { mat = "Neon", tr = 1, name = ("Bolt%d_%d"):format(n, k) })
			end
			B:bar("Root", pts[3], pts[3] + v(0.75 * s, -0.7, -0.35), 0.13, 0.13, BOLT, { mat = "Neon", tr = 1, name = ("Bolt%d_f"):format(n) })
		end
		-- electric arc jumping between the two coil tops (over the runner's head)
		local arc = B:bone("Arc", "Root", v(0, 7.4, 1.0))
		local apts = { v(-2.75, 7.65, 1.0), v(-1.9, 7.15, 1.2), v(-0.9, 7.55, 0.8), v(0.1, 7.05, 1.15), v(1.0, 7.5, 0.85), v(1.9, 7.1, 1.15), v(2.75, 7.65, 1.0) }
		for k = 1, 6 do
			B:bar(arc, apts[k], apts[k + 1], 0.2, 0.2, ELEC, { mat = "Neon", tr = 1, name = "Arc" .. k })
		end

		------------------------------------------------- rear exhaust fan
		local FY, FZ = 3.0, 5.25
		B:block("Root", v(3.4, 0.3, 0.5), cf(0, FY + 1.55, FZ), SLATE_D)
		B:block("Root", v(3.4, 0.3, 0.5), cf(0, FY - 1.55, FZ), SLATE_D)
		B:block("Root", v(0.3, 3.4, 0.5), cf(1.55, FY, FZ), SLATE_D)
		B:block("Root", v(0.3, 3.4, 0.5), cf(-1.55, FY, FZ), SLATE_D)
		B:block("Root", v(3.5, 0.12, 0.55), cf(0, FY + 1.75, FZ), HAZ)
		for _, x in { 1.2, -1.2 } do
			B:block("Root", v(0.4, 0.6, 0.9), cf(x, 1.7, 4.95), SLATE)
		end
		B:block("Root", v(0.3, 0.3, 0.9), cf(0, FY, FZ - 0.35), SLATE)
		local fan = B:bone("Fan", "Root", v(0, FY, FZ))
		B:block(fan, v(0.6, 0.6, 0.4), cf(0, FY, FZ + 0.05, 0, 0, 45), STEEL)
		B:block(fan, v(0.32, 0.32, 0.46), cf(0, FY, FZ + 0.05), ELEC, { mat = "Neon" })
		for k = 0, 3 do
			local a = cf(0, FY, FZ) * ang(0, 0, 90 * k + 20)
			B:block(fan, v(0.5, 1.2, 0.1), a * CFrame.new(0, 0.75, 0) * ang(0, 20, 0), SLATE_L)
			B:block(fan, v(0.52, 0.22, 0.12), a * CFrame.new(0, 1.28, 0) * ang(0, 20, 0), k % 2 == 0 and HAZ or "#e8413a")
		end
		B:trail(fan, (cf(0, FY, FZ) * ang(0, 0, 20) * CFrame.new(0, 0.9, 0)).Position, (cf(0, FY, FZ) * ang(0, 0, 20) * CFrame.new(0, 1.35, 0)).Position, { color = { "#ffffff", ELEC }, life = 0.2, trans = { 0.4, 1 }, name = "FanTrail1" })
		B:trail(fan, (cf(0, FY, FZ) * ang(0, 0, 200) * CFrame.new(0, 0.9, 0)).Position, (cf(0, FY, FZ) * ang(0, 0, 200) * CFrame.new(0, 1.35, 0)).Position, { color = { "#ffffff", ELEC }, life = 0.2, trans = { 0.4, 1 }, name = "FanTrail2" })

		------------------------------------------------------ uprights
		B:sym(function()
			B:bar("Root", v(2.15, 1.6, -4.5), v(2.15, 5.4, -4.0), 0.7, 0.7, SLATE)
			B:bar("Root", v(2.15, 1.7, -4.5), v(2.15, 5.3, -4.0), 0.74, 0.3, SLATE_D)
			B:block("Root", v(1.0, 0.5, 1.0), cf(2.15, 1.85, -4.5), SLATE_D)
			for k = 0, 2 do
				local y = 2.6 + k * 0.9
				local zz = -4.5 + (y - 1.6) / 3.8 * 0.5
				B:block("Root", v(0.8, 0.22, 0.8), cf(2.15, y, zz), HAZ)
			end
		end)

		------------------------------------------------------- console
		local con = cf(0, 5.8, -3.9) * ang(-30, 0, 0)
		B:block("Root", v(4.8, 1.0, 1.4), con, SLATE_D)
		B:block("Root", v(4.9, 0.22, 1.5), con * CFrame.new(0, 0.58, 0), SLATE_L)
		B:block("Root", v(4.6, 0.2, 1.3), con * CFrame.new(0, -0.58, 0), INK)
		for k = 0, 8 do
			B:block("Root", v(0.55, 0.12, 0.2), con * CFrame.new(-2.2 + k * 0.55, 0.7, 0.62), k % 2 == 0 and HAZ or INK)
		end
		B:block("Root", v(3.6, 0.8, 0.06), con * CFrame.new(0, 0, 0.7), "#0d1726")
		B:block("Root", v(3.75, 0.08, 0.08), con * CFrame.new(0, 0.43, 0.7), SLATE_L)
		B:block("Root", v(3.75, 0.08, 0.08), con * CFrame.new(0, -0.43, 0.7), SLATE_L)
		-- radar scope (left): grid + sweeping arm on its own bone
		local rc = con * CFrame.new(-1.05, 0, 0.74)
		B:block("Root", v(0.72, 0.03, 0.03), rc, "#2c6b5a")
		B:block("Root", v(0.03, 0.72, 0.03), rc, "#2c6b5a")
		B:block("Root", v(0.6, 0.6, 0.02), rc * CFrame.new(0, 0, -0.01) * ang(0, 0, 45), "#123326")
		local radar = B:bone("Radar", "Root", rc)
		B:block(radar, v(0.05, 0.36, 0.03), rc * CFrame.new(0, 0.18, 0.02), "#6dff9a", { mat = "Neon" })
		B:block(radar, v(0.1, 0.1, 0.03), rc * CFrame.new(0, 0, 0.02), "#6dff9a", { mat = "Neon" })
		for k, p in { { 0.18, 0.2 }, { -0.22, 0.08 }, { 0.05, -0.24 } } do
			B:block("Root", v(0.07, 0.07, 0.03), rc * CFrame.new(p[1], p[2], 0.015), BOLT, { mat = "Neon", name = "Blip" .. k })
		end
		-- storm level bars (right)
		for i = 1, 8 do
			local hgt = 0.1 + (i - 1) * 0.065
			B:block("Root", v(0.18, hgt, 0.05), con * CFrame.new(-0.35 + (i - 1) * 0.25, -0.33 + hgt / 2, 0.74), i > 6 and BOLT or ELEC, { mat = "Neon", name = "Bar" .. i })
		end
		-- lightning icon
		B:block("Root", v(0.12, 0.3, 0.05), con * CFrame.new(1.65, 0.12, 0.74) * ang(0, 0, -20), BOLT, { mat = "Neon" })
		B:block("Root", v(0.12, 0.3, 0.05), con * CFrame.new(1.6, -0.12, 0.74) * ang(0, 0, -20), BOLT, { mat = "Neon" })
		B:block("Root", v(0.2, 0.07, 0.05), con * CFrame.new(1.62, 0.0, 0.74), BOLT, { mat = "Neon" })
		-- buttons
		B:block("Root", v(0.42, 0.42, 0.14), con * CFrame.new(-2.05, 0.05, 0.7), "#e8413a")
		B:block("Root", v(0.24, 0.24, 0.06), con * CFrame.new(-2.05, 0.05, 0.79), "#ff8a7a", { mat = "Neon", name = "Led" })
		B:block("Root", v(0.34, 0.22, 0.12), con * CFrame.new(2.05, 0.15, 0.7), STEEL)
		B:block("Root", v(0.34, 0.22, 0.12), con * CFrame.new(2.05, -0.17, 0.7), HAZ)
		-- antennas on the console with spark tips
		for _, s in { 1, -1 } do
			local base = (con * CFrame.new(1.7 * s, 0.6, -0.3)).Position
			B:block("Root", v(0.35, 0.3, 0.35), CFrame.new(base + v(0, 0.1, 0)), SLATE)
			B:block("Root", v(0.12, 1.2, 0.12), CFrame.new(base + v(0, 0.8, 0)), COPPER)
			B:block("Root", v(0.3, 0.1, 0.3), CFrame.new(base + v(0, 0.75, 0)), COPPER_D)
			B:block("Root", v(0.24, 0.24, 0.24), CFrame.new(base + v(0, 1.45, 0)) * ang(0, 45, 0), ELEC, { mat = "Neon", name = s > 0 and "AntR" or "AntL" })
		end

		----------------------------------------------- handrails
		B:sym(function()
			B:bar("Root", v(2.35, 5.15, -3.5), v(2.35, 4.4, -0.7), 0.4, 0.4, SLATE_L)
			B:bar("Root", v(2.35, 4.95, -2.6), v(2.35, 4.5, -1.0), 0.5, 0.5, INK)
			B:block("Root", v(0.55, 0.3, 0.55), cf(2.35, 4.4, -0.75), HAZ)
		end)

		---------------------------------------------------- spark effects
		B:emitter(rodTips[3], "spark", { color = { "#ffffff", BOLT }, rate = 6, name = "SparkR" })
		B:emitter(rodTips[4], "spark", { color = { "#ffffff", ELEC }, rate = 6, name = "SparkL" })
		B:emitter(rodTips[1], "burst", { color = { "#ffffff", BOLT }, size = { 0.6, 0.3, 0 }, speed = { 6, 12 }, name = "StrikeR" })
		B:emitter(rodTips[2], "burst", { color = { "#ffffff", BOLT }, size = { 0.6, 0.3, 0 }, speed = { 6, 12 }, name = "StrikeL" })
		B:emitter(B:block("Root", v(0.4, 0.4, 0.4), cf(0, 7.4, 1.0), ELEC, { tr = 1 }), "spark", { color = { "#ffffff", ELEC }, rate = 0, speed = { 4, 9 }, name = "ArcSpark" })
	end,
}
