-- Treadmill09 "Cyber Treadmill" (Epic): dark navy + chrome cyber frame with cyan /
-- magenta neon, floating holographic console panels that flicker, a holo cube,
-- a laser scanner bar sweeping the deck, tower fans, chase lights, thruster pods.
-- Faces -Z (console at the front). Belt slats on "Belt" slide +Z one gap per step.
return {
	DisplayName = "Cyber Treadmill",
	Rarity = "Epic",
	Element = "Tech",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local D1, D2, D3 = "#11152a", "#1f2746", "#33406c" -- navy dark / main / light
		local S1, S2 = "#9aa7cf", "#dfe6ff" -- chrome
		local CY, MG = "#27f4ff", "#ff2fd6" -- neon cyan / magenta
		local BELT, SLAT = "#0a0d18", "#2a3358"

		---------------------------------------------------------------- base
		-- thruster pods at the corners (glow bands pulse)
		local pod = 0
		for _, x in { -2.0, 2.0 } do
			for _, z in { -4.1, 4.0 } do
				pod += 1
				B:block("Root", v(1.2, 0.42, 1.2), cf(x, 0.21, z), D1)
				local sx, sz = x > 0 and 1 or -1, z > 0 and 1 or -1
				B:block("Root", v(0.06, 0.1, 0.9), cf(x + sx * 0.6, 0.24, z), CY, { mat = "Neon", name = "Pod" .. pod .. "X" })
				B:block("Root", v(0.9, 0.1, 0.06), cf(x, 0.24, z + sz * 0.6), CY, { mat = "Neon", name = "Pod" .. pod .. "Z" })
				B:block("Root", v(0.9, 0.12, 0.9), cf(x, 0.47, z), S1)
			end
		end
		B:block("Root", v(4.7, 0.2, 9.3), cf(0, 0.48, 0), D1)
		B:block("Root", v(5.0, 0.55, 9.6), cf(0, 0.8, 0), D2)
		B:block("Root", v(5.1, 0.14, 9.7), cf(0, 1.1, 0), D3)
		-- side colour blocking + chase lights flowing toward the back
		B:sym(function()
			B:block("Root", v(0.08, 0.3, 8.6), cf(2.52, 0.8, 0), D3)
			for k = 1, 4 do
				B:block("Root", v(0.1, 0.5, 0.14), cf(2.52, 0.8, -3.6 + (k - 1) * 2.4), S1)
			end
		end)
		for k = 1, 8 do
			local z = -3.75 + (k - 1) * 1.05
			B:block("Root", v(0.1, 0.14, 0.62), cf(2.6, 0.84, z), CY, { mat = "Neon", name = "ChaseR" .. k })
			B:block("Root", v(0.1, 0.14, 0.62), cf(-2.6, 0.84, z), CY, { mat = "Neon", name = "ChaseL" .. k })
		end

		-- belt bed + moving slats with glowing data seams
		B:block("Root", v(3.5, 0.1, 7.8), cf(0, 1.2, 0.25), BELT)
		local belt = B:bone("Belt", "Root", v(0, 1.3, 0))
		for i = 0, 15 do
			local z = -3.6 + i * 0.5
			B:block(belt, v(3.4, 0.06, 0.24), cf(0, 1.28, z), SLAT)
			if i % 4 == 0 then
				B:block(belt, v(3.3, 0.04, 0.06), cf(0, 1.32, z), (i % 8 == 0) and CY or MG, { mat = "Neon" })
			end
		end

		-- foot rails with a cyan light line along the belt edge
		B:sym(function()
			B:block("Root", v(0.75, 0.32, 7.6), cf(2.12, 1.3, 0.25), D3)
			B:block("Root", v(0.5, 0.08, 7.4), cf(2.2, 1.5, 0.25), S1)
			B:block("Root", v(0.07, 0.07, 7.4), cf(1.76, 1.43, 0.25), CY, { mat = "Neon" })
		end)

		-- front hood: stepped, grille + emblem
		B:block("Root", v(5.0, 1.0, 1.6), cf(0, 1.6, -4.05), D2)
		B:block("Root", v(4.8, 0.3, 1.4), cf(0, 2.2, -4.05), D3)
		B:block("Root", v(3.2, 0.1, 1.2), cf(0, 2.4, -4.05), S1)
		for r = 0, 2 do
			B:block("Root", v(1.4, 0.1, 0.1), cf(-1.5, 1.35 + r * 0.25, -4.88), D1)
			B:block("Root", v(1.4, 0.1, 0.1), cf(1.5, 1.35 + r * 0.25, -4.88), D1)
		end
		B:block("Root", v(1.3, 0.8, 0.1), cf(0, 1.6, -4.88), D1)
		B:block("Root", v(1.0, 0.08, 0.06), cf(0, 1.92, -4.95), CY, { mat = "Neon" })
		B:block("Root", v(1.0, 0.08, 0.06), cf(0, 1.28, -4.95), CY, { mat = "Neon" })
		B:block("Root", v(0.08, 0.56, 0.06), cf(-0.46, 1.6, -4.95), CY, { mat = "Neon" })
		B:block("Root", v(0.08, 0.56, 0.06), cf(0.46, 1.6, -4.95), CY, { mat = "Neon" })
		B:block("Root", v(0.34, 0.34, 0.06), cf(0, 1.6, -4.95) * ang(0, 0, 45), MG, { mat = "Neon", name = "Emblem" })
		-- rear cap
		B:block("Root", v(5.0, 0.6, 0.9), cf(0, 1.35, 4.4), D2)
		B:block("Root", v(5.05, 0.12, 0.95), cf(0, 1.7, 4.4), S1)
		B:block("Root", v(3.6, 0.07, 0.06), cf(0, 1.35, 4.88), MG, { mat = "Neon" })

		------------------------------------------------------------- rollers
		for _, r in { { "RollFR", 1, 1.5, -4.05 }, { "RollFL", -1, 1.5, -4.05 }, { "RollRR", 1, 1.2, 4.4 }, { "RollRL", -1, 1.2, 4.4 } } do
			local x = r[2] * 2.62
			local b = B:bone(r[1], "Root", v(x, r[3], r[4]))
			local c = cf(x, r[3], r[4])
			B:block(b, v(0.2, 0.95, 0.95), c, D3)
			B:block(b, v(0.22, 0.8, 0.8), c * ang(45, 0, 0), D1)
			B:block(b, v(0.26, 0.86, 0.08), c, CY, { mat = "Neon" })
			B:block(b, v(0.26, 0.08, 0.86), c, CY, { mat = "Neon" })
			B:block(b, v(0.3, 0.3, 0.3), c, S2)
		end

		---------------------------------------------------- fan towers + struts
		for _, s in { 1, -1 } do
			local x = s * 2.15
			B:block("Root", v(1.2, 1.6, 1.4), cf(x, 3.05, -4.1), D2)
			B:block("Root", v(1.3, 0.2, 1.5), cf(x, 3.9, -4.1), D3)
			B:block("Root", v(1.0, 0.14, 1.2), cf(x, 2.3, -4.1), S1)
			B:block("Root", v(0.08, 1.5, 0.08), cf(x - s * 0.62, 3.05, -3.38), MG, { mat = "Neon" })
			-- fan in the outer face
			B:block("Root", v(0.06, 1.25, 1.25), cf(x + s * 0.6, 3.05, -4.1), D1)
			B:block("Root", v(0.05, 0.5, 0.5), cf(x + s * 0.6, 3.05, -4.1), CY, { mat = "Neon", tr = 0.3 })
			local fx = x + s * 0.68
			local fan = B:bone(s == 1 and "FanR" or "FanL", "Root", v(fx, 3.05, -4.1))
			for k = 0, 3 do
				B:block(fan, v(0.08, 1.0, 0.22), cf(fx, 3.05, -4.1) * ang(k * 45, 0, 0), S1)
			end
			B:block(fan, v(0.14, 0.3, 0.3), cf(fx + s * 0.03, 3.05, -4.1), S2)
			-- struts up to the console
			local a, b = v(x, 3.95, -4.15), v(x, 5.75, -3.85)
			B:bar("Root", a, b, 0.7, 0.7, D2)
			B:bar("Root", a + v(s * 0.37, 0, 0), b + v(s * 0.37, 0, 0), 0.08, 0.12, MG, { mat = "Neon" })
			B:bar("Root", a:Lerp(b, 0.45), a:Lerp(b, 0.6), 0.8, 0.8, S1)
		end

		-------------------------------------------------------------- console
		local con = cf(0, 6.05, -3.75) * ang(-30, 0, 0)
		local function at(x, y, z) return con * CFrame.new(x, y, z) end
		B:block("Root", v(5.0, 1.0, 1.5), con, D2)
		B:block("Root", v(5.15, 0.22, 1.65), at(0, 0.52, 0), D3)
		B:block("Root", v(4.6, 0.06, 0.12), at(0, 0.64, 0.6), CY, { mat = "Neon" })
		B:block("Root", v(5.1, 0.18, 1.55), at(0, -0.55, 0), D1)
		B:block("Root", v(3.4, 0.86, 0.06), at(0, 0, 0.77), D1)
		B:block("Root", v(3.5, 0.08, 0.08), at(0, -0.46, 0.77), S1)
		for i = 1, 10 do
			B:block("Root", v(0.2, 0.6, 0.05), at(-1.44 + (i - 1) * 0.32, -0.02, 0.81), i % 3 == 0 and MG or CY, { mat = "Neon", name = "Bar" .. i })
		end
		-- screen scanner line (slides left/right)
		local scan2 = B:bone("ScreenScan", "Root", at(0, 0, 0.84))
		B:block(scan2, v(0.06, 0.78, 0.04), at(0, 0, 0.85), "#ffffff", { mat = "Neon" })
		-- side keypads
		for _, sx in { 1, -1 } do
			for r = 0, 2 do
				B:block("Root", v(0.62, 0.16, 0.06), at(sx * 2.1, 0.26 - r * 0.25, 0.77), r == 1 and S1 or D3)
			end
			B:block("Root", v(0.18, 0.12, 0.06), at(sx * 2.1, 0.26, 0.81), sx == 1 and MG or CY, { mat = "Neon", name = sx == 1 and "KeyR" or "KeyL" })
			B:block("Root", v(0.22, 1.1, 1.3), at(sx * 2.6, 0, 0), D3)
			B:block("Root", v(0.1, 0.7, 0.08), at(sx * 2.72, 0, 0.5), CY, { mat = "Neon" })
		end

		-- holo projector on top of the console (upright)
		B:block("Root", v(1.8, 0.3, 0.8), cf(0, 6.82, -3.95), D1)
		B:block("Root", v(1.4, 0.18, 0.6), cf(0, 7.0, -3.95), S1)
		local lens = B:block("Root", v(1.0, 0.08, 0.3), cf(0, 7.1, -3.95), CY, { mat = "Neon", name = "Lens" })
		B:block("Root", v(0.16, 0.6, 0.16), cf(-2.3, 6.9, -3.8), D1)
		B:block("Root", v(0.16, 0.6, 0.16), cf(2.3, 6.9, -3.8), D1)

		-- holographic panels (translucent neon, flicker + float)
		local function holo(name, pos, w, h, yaw, col, accent)
			local b = B:bone(name, "Root", pos)
			local c = CFrame.new(pos) * ang(-12, yaw, 0)
			for k = 1, 3 do
				B:block(b, v(w - 0.1, 0.035, 0.03), c * CFrame.new(0, -h / 2 + k * h / 4, -0.02), col, { mat = "Neon", tr = 0.55, name = name .. "S" .. k })
			end
			B:block(b, v(w + 0.08, 0.06, 0.05), c * CFrame.new(0, h / 2, 0), col, { mat = "Neon" })
			B:block(b, v(w + 0.08, 0.06, 0.05), c * CFrame.new(0, -h / 2, 0), col, { mat = "Neon" })
			B:block(b, v(0.06, h, 0.05), c * CFrame.new(-w / 2, 0, 0), col, { mat = "Neon" })
			B:block(b, v(0.06, h, 0.05), c * CFrame.new(w / 2, 0, 0), col, { mat = "Neon" })
			return b, c
		end
		local hc, hcc = holo("HoloC", v(0, 8.0, -3.75), 2.6, 1.2, 0, CY)
		for i = 1, 5 do
			local hh = 0.2 + ((i * 7) % 5) * 0.14
			B:block(hc, v(0.24, hh, 0.04), hcc * CFrame.new(-0.9 + (i - 1) * 0.45, -0.45 + hh / 2, 0.03), i % 2 == 0 and MG or CY, { mat = "Neon", tr = 0.25, name = "HoloBar" .. i })
		end
		B:block(hc, v(2.2, 0.05, 0.04), hcc * CFrame.new(0, 0.35, 0.03), "#ffffff", { mat = "Neon", tr = 0.3, name = "HoloLine" })
		for _, s in { 1, -1 } do
			local nm = s == 1 and "HoloR" or "HoloL"
			local hs, hsc = holo(nm, v(s * 2.55, 7.55, -3.55), 1.3, 0.9, s * -28, s == 1 and MG or CY)
			B:block(hs, v(0.9, 0.08, 0.04), hsc * CFrame.new(0, 0.18, 0.03), "#ffffff", { mat = "Neon", tr = 0.3, name = nm .. "A" })
			B:block(hs, v(0.6, 0.08, 0.04), hsc * CFrame.new(-0.15, -0.05, 0.03), "#ffffff", { mat = "Neon", tr = 0.3, name = nm .. "B" })
			B:block(hs, v(0.25, 0.25, 0.04), hsc * CFrame.new(0.38, -0.22, 0.03), s == 1 and CY or MG, { mat = "Neon", tr = 0.2, name = nm .. "C" })
		end

		-- spinning wireframe holo cube above the panels
		local cubeP = v(0, 9.2, -3.85)
		local cube = B:bone("HoloCube", "Root", cubeP)
		local cc = CFrame.new(cubeP)
		local e, r = 0.06, 0.32
		for _, a in { -1, 1 } do
			for _, b2 in { -1, 1 } do
				B:block(cube, v(2 * r + e, e, e), cc * CFrame.new(0, a * r, b2 * r), MG, { mat = "Neon" })
				B:block(cube, v(e, 2 * r + e, e), cc * CFrame.new(a * r, 0, b2 * r), MG, { mat = "Neon" })
				B:block(cube, v(e, e, 2 * r + e), cc * CFrame.new(a * r, b2 * r, 0), MG, { mat = "Neon" })
			end
		end
		local cubeCore = B:block(cube, v(0.28, 0.28, 0.28), cc * ang(45, 45, 0), CY, { mat = "Neon", name = "CubeCore" })

		--------------------------------------------------------- deck scanner
		local scan = B:bone("Scan", "Root", v(0, 1.6, 0))
		for _, s in { 1, -1 } do
			B:block(scan, v(0.66, 0.3, 0.55), cf(s * 2.15, 1.68, 0), D1)
			B:block(scan, v(0.5, 0.1, 0.4), cf(s * 2.15, 1.87, 0), S1)
			B:block(scan, v(0.12, 0.2, 0.3), cf(s * 1.8, 1.55, 0), MG, { mat = "Neon" })
		end
		B:block(scan, v(3.5, 0.05, 0.05), cf(0, 1.52, 0), MG, { mat = "Neon", name = "Laser" })
		local sheet = B:block(scan, v(3.5, 0.32, 0.02), cf(0, 1.7, 0), MG, { mat = "Neon", tr = 0.8, name = "ScanSheet" })

		------------------------------------------------------- rear data gate
		for _, s in { 1, -1 } do
			local x, z = s * 2.25, 4.4
			B:block("Root", v(1.1, 0.4, 1.0), cf(x, 1.95, z), D3)
			B:block("Root", v(0.9, 0.2, 0.8), cf(x, 2.25, z), S1)
			B:block("Root", v(0.7, 4.3, 0.6), cf(x, 4.5, z), D2)
			B:block("Root", v(0.8, 0.25, 0.7), cf(x, 3.5, z), D3)
			B:block("Root", v(0.8, 0.25, 0.7), cf(x, 5.2, z), D3)
			B:block("Root", v(0.08, 3.7, 0.08), cf(x + s * 0.36, 4.5, z - 0.2), MG, { mat = "Neon" })
			B:block("Root", v(0.08, 3.7, 0.08), cf(x + s * 0.36, 4.5, z + 0.2), CY, { mat = "Neon" })
			-- stepped tail fins
			B:block("Root", v(0.16, 1.2, 0.9), cf(x + s * 0.5, 2.8, z + 0.3), D3)
			B:block("Root", v(0.16, 0.8, 0.7), cf(x + s * 0.5, 3.8, z + 0.45), D3)
			B:block("Root", v(0.16, 0.5, 0.5), cf(x + s * 0.5, 4.45, z + 0.55), D3)
			-- antenna on the gate corners
			B:block("Root", v(0.12, 0.7, 0.12), cf(x, 7.6, z), S1)
			B:block("Root", v(0.24, 0.24, 0.24), cf(x, 8.0, z), s == 1 and MG or CY, { mat = "Neon", name = s == 1 and "TipR" or "TipL" })
		end
		-- crossbar with a progress-bar display facing the deck
		B:block("Root", v(5.3, 0.7, 0.75), cf(0, 6.95, 4.4), D2)
		B:block("Root", v(5.5, 0.2, 0.85), cf(0, 7.38, 4.4), D3)
		B:block("Root", v(5.1, 0.12, 0.6), cf(0, 6.55, 4.4), S1)
		B:block("Root", v(3.6, 0.42, 0.06), cf(0, 6.95, 4.0), D1)
		for k = 1, 8 do
			B:block("Root", v(0.36, 0.28, 0.05), cf(-1.54 + (k - 1) * 0.44, 6.95, 3.96), k <= 6 and CY or MG, { mat = "Neon", name = "Prog" .. k })
		end
		B:block("Root", v(1.4, 0.3, 0.06), cf(0, 6.95, 4.8), D1)
		B:block("Root", v(1.0, 0.1, 0.05), cf(0, 6.95, 4.84), MG, { mat = "Neon", name = "GateBack" })
		-- projection beams from the lens up to the centre panel
		for _, bx in { -0.4, 0, 0.4 } do
			B:block("Root", v(0.04, 0.32, 0.04), cf(bx, 7.28, -3.9), CY, { mat = "Neon", tr = 0.5 })
		end

		------------------------------------------------------------ handrails
		for _, s in { 1, -1 } do
			local x = s * 2.35
			B:bar("Root", v(x, 5.4, -3.45), v(x, 4.6, -0.5), 0.4, 0.4, D3)
			B:bar("Root", v(x, 5.15, -2.4), v(x, 4.8, -1.0), 0.5, 0.5, D1)
			B:bar("Root", v(x, 5.17, -2.4), v(x, 4.82, -1.0), 0.52, 0.06, CY, { mat = "Neon", up = v(1, 0, 0) })
			B:block("Root", v(0.5, 0.42, 0.42), cf(x, 4.58, -0.45), S1)
			B:block("Root", v(0.2, 0.2, 0.08), cf(x, 4.58, -0.22), MG, { mat = "Neon" })
		end

		-------------------------------------------------------------- effects
		B:emitter(lens, "spark", { color = { CY, "#ffffff" }, rate = 6, size = { 0.2, 0.08, 0 }, speed = { 1.5, 3.5 }, spread = 25, name = "ProjSpark" })
		B:emitter(cubeCore, "sparkle", { color = { MG, CY }, rate = 6, size = { 0.12, 0.35, 0 }, name = "CubeSparkle" })
		B:emitter(cubeCore, "burst", { color = { CY, MG }, size = { 0.4, 0.2, 0 }, speed = { 4, 8 }, name = "Glitch" })
		B:emitter(sheet, "spark", { color = { MG, "#ffffff" }, rate = 5, size = { 0.18, 0.06, 0 }, speed = { 1, 3 }, name = "ScanSpark" })
		B:light(lens, { color = CY, brightness = 0.9, range = 10, name = "HoloLight" })
		B:light(sheet, { color = MG, brightness = 0.7, range = 8, name = "ScanLight" })
	end,
}
