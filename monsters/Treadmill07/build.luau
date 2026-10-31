-- Treadmill07 "Turbo Treadmill": racing-yellow hot-rod treadmill. Faces -Z.
-- Animated: fast belt, 4 spinning racing wheels (light streaks), turbo compressor,
-- pumping engine pistons, rev-up tachometer + boost gauge needles with gear
-- shifts, shift lights, zoomie exhausts that puff smoke and backfire on each shift.
return {
	DisplayName = "Turbo Treadmill",
	Rarity = "Rare",
	Element = "Speed",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local Y_L, Y, Y_D = "#fff07a", "#ffcc1a", "#d99400"
		local BK_L, BK, BK_D = "#3d3d44", "#232327", "#121214"
		local CH_L, CH = "#eef1f5", "#b9bfc8"
		local RED, WHITE = "#ff3b2f", "#f4f4f4"
		local FLAME = "#ff8a1f"

		------------------------------------------------------------------ chassis
		B:sym(function(side)
			for _, z in { -2.4, 2.4 } do
				B:block("Root", v(0.8, 0.25, 0.8), cf(1.8, 0.125, z), BK_D)
			end
			-- yellow side skirt with black racing stripe
			B:block("Root", v(0.45, 0.85, 6.4), cf(2.15, 0.7, 0.1), Y)
			B:block("Root", v(0.49, 0.2, 6.2), cf(2.15, 0.75, 0.1), BK)
			B:block("Root", v(0.5, 0.06, 6.2), cf(2.15, 0.88, 0.1), WHITE)
			B:block("Root", v(0.5, 0.14, 6.5), cf(2.16, 0.32, 0.1), Y_D)
			-- number roundel "1"
			B:block("Root", v(0.52, 0.5, 0.7), cf(2.16, 0.62, -1.4), WHITE)
			B:block("Root", v(0.56, 0.38, 0.14), cf(2.16, 0.62, -1.4), BK)
			B:block("Root", v(0.56, 0.1, 0.12), cf(2.16, 0.76, -1.5), BK)
			-- wheel arches
			for _, z in { -4.0, 4.2 } do
				B:block("Root", v(0.75, 0.22, 1.7), cf(2.6, 1.82, z), Y)
				B:block("Root", v(0.78, 0.08, 1.75), cf(2.6, 1.68, z), BK)
				B:block("Root", v(0.3, 0.5, 0.3), cf(2.3, 1.6, z), BK_L)
				-- red brake caliper behind the wheel
				B:block("Root", v(0.2, 0.4, 0.35), cf(2.35, 1.1, z + 0.3), RED)
			end
			-- foot rail
			B:block("Root", v(0.62, 0.26, 7.3), cf(1.96, 1.12, 0.3), Y_L)
			B:block("Root", v(0.44, 0.06, 7.0), cf(1.96, 1.27, 0.3), BK)
		end)
		B:block("Root", v(4.0, 0.8, 9.1), cf(0, 0.66, 0), BK)
		B:block("Root", v(4.2, 0.14, 9.3), cf(0, 0.3, 0), BK_D)
		B:block("Root", v(3.3, 0.1, 7.8), cf(0, 1.05, 0.2), BK_D)

		------------------------------------------------------------------ belt (2-tone, period 1.0)
		local belt = B:bone("Belt", "Root", v(0, 1.1, 0))
		for i = 0, 15 do
			B:block(belt, v(3.2, 0.07, 0.4), cf(0, 1.135, -3.75 + i * 0.5), i % 2 == 0 and "#2c2c31" or "#3a3a41")
			if i % 2 == 0 then
				B:block(belt, v(0.5, 0.04, 0.18), cf(0, 1.17, -3.75 + i * 0.5), Y_D)
			end
		end

		------------------------------------------------------------------ hood: engine bay, pistons, turbo, headlights
		B:block("Root", v(4.6, 1.1, 1.7), cf(0, 1.35, -4.05), Y)
		B:block("Root", v(4.65, 0.16, 1.75), cf(0, 0.84, -4.05), BK)
		B:block("Root", v(4.4, 0.16, 1.55), cf(0, 1.98, -4.05), Y_D)
		-- checker stripe across the hood top
		for i = 0, 7 do
			for r = 0, 1 do
				B:block("Root", v(0.3, 0.06, 0.3), cf(-1.05 + i * 0.3, 2.08, -4.65 + r * 0.3), (i + r) % 2 == 0 and BK or WHITE)
			end
		end
		-- engine bay with two pistons
		B:block("Root", v(1.8, 0.2, 0.8), cf(0, 2.12, -3.85), BK_D)
		for k, px in { -0.45, 0.45 } do
			B:block("Root", v(0.62, 0.2, 0.62), cf(px, 2.25, -3.85), CH)
			local pb = B:bone("Piston" .. k, "Root", v(px, 2.3, -3.85))
			B:block(pb, v(0.18, 0.6, 0.18), cf(px, 2.45, -3.85), CH)
			B:block(pb, v(0.46, 0.22, 0.46), cf(px, 2.78, -3.85), CH_L)
			B:block(pb, v(0.5, 0.06, 0.5), cf(px, 2.9, -3.85), RED)
		end
		-- turbo on the front face
		local fz = -4.92
		B:block("Root", v(1.3, 1.0, 0.24), cf(0, 1.4, fz + 0.04), CH)
		B:block("Root", v(1.0, 1.0, 0.24), cf(0, 1.4, fz + 0.04) * ang(0, 0, 45), CH)
		B:block("Root", v(0.8, 0.8, 0.06), cf(0, 1.4, fz - 0.1), BK_D)
		B:block("Root", v(0.6, 0.35, 0.5), cf(0.75, 1.75, fz + 0.2), CH_L) -- snail outlet
		local tb = B:bone("Turbo", "Root", v(0, 1.4, fz - 0.14))
		local tc = cf(0, 1.4, fz - 0.14)
		for i = 0, 5 do
			B:block(tb, v(0.34, 0.12, 0.04), tc * ang(0, 0, i * 60) * CFrame.new(0.2, 0, 0) * ang(30, 0, 0), CH_L)
		end
		B:block(tb, v(0.16, 0.16, 0.1), tc * CFrame.new(0, 0, -0.04), RED)
		-- headlights + grille slots
		B:sym(function(side)
			B:block("Root", v(0.7, 0.4, 0.08), cf(1.6, 1.55, fz + 0.06), BK_D)
			B:block("Root", v(0.5, 0.26, 0.06), cf(1.6, 1.55, fz + 0.02), "#fffbe0", { mat = "Neon", name = "Head" .. side })
			B:block("Root", v(0.3, 0.16, 0.06), cf(1.95, 1.15, fz + 0.06), FLAME, { mat = "Neon", name = "Amber" .. side })
			for k = 0, 2 do
				B:block("Root", v(0.8, 0.07, 0.06), cf(1.25, 1.2 - k * 0.14, fz + 0.06), BK_D)
			end
		end)

		------------------------------------------------------------------ racing wheels (spin)
		for _, h in { { "WheelFR", 2.62, -4.0 }, { "WheelFL", -2.62, -4.0 }, { "WheelRR", 2.62, 4.2 }, { "WheelRL", -2.62, 4.2 } } do
			local s = h[2] > 0 and 1 or -1
			local c = cf(h[2], 0.82, h[3])
			local w = B:bone(h[1], "Root", c)
			B:block(w, v(0.46, 1.2, 1.2), c, BK)
			B:block(w, v(0.46, 1.2, 1.2), c * ang(45, 0, 0), BK_D)
			B:block(w, v(0.5, 0.78, 0.78), c * ang(22.5, 0, 0), Y)
			B:block(w, v(0.5, 0.78, 0.78), c * ang(67.5, 0, 0), Y_D)
			for i = 0, 2 do
				B:block(w, v(0.54, 0.6, 0.14), c * ang(i * 120, 0, 0) * CFrame.new(s * 0.01, 0.2, 0), CH_L)
			end
			B:block(w, v(0.58, 0.24, 0.24), c, CH)
			B:block(w, v(0.62, 0.12, 0.12), c, RED)
			local tip = (c * CFrame.new(s * 0.26, 0.42, 0)).Position
			B:trail(w, tip + Vector3.new(0, 0.1, 0), tip - Vector3.new(0, 0.1, 0), { color = { Y_L, FLAME }, life = 0.18, name = "Streak" .. h[1] })
		end

		------------------------------------------------------------------ zoomie exhausts (smoke + backfire)
		B:sym(function(side)
			local x = 2.72
			B:block("Root", v(0.3, 0.3, 0.5), cf(2.45, 0.6, -2.6), BK_L) -- header out of the chassis
			B:bar("Root", v(x, 0.6, -2.75), v(x, 0.6, 2.3), 0.38, 0.38, CH)
			B:bar("Root", v(x + 0.02, 0.68, -1.8), v(x + 0.02, 0.68, 1.6), 0.42, 0.3, BK_L) -- heat shield
			for k = 0, 3 do
				B:block("Root", v(0.46, 0.08, 0.14), cf(x + 0.02, 0.84, -1.4 + k * 0.9), Y_D)
			end
			local a, b = v(x, 0.6, 2.2), v(x + 0.15, 2.35, 3.25)
			B:bar("Root", a, b, 0.4, 0.4, CH)
			local tipCF = P.aim(a, b)
			local tipC = tipCF * CFrame.new(0, 0, -((b - a).Magnitude / 2))
			B:block("Root", v(0.58, 0.58, 0.4), tipC, CH_L)
			B:block("Root", v(0.36, 0.36, 0.06), tipC * CFrame.new(0, 0, -0.19), BK_D)
			B:block("Root", v(0.3, 0.3, 0.1), tipC * CFrame.new(0, 0, -0.27), FLAME, { mat = "Neon", name = "Flame" .. side, tr = 1 })
			local src = B:block("Root", v(0.3, 0.3, 0.1), tipC * CFrame.new(0, 0, -0.35), BK, { tr = 1, name = "Pipe" .. side })
			B:emitter(src, "smoke", { name = "Smoke" .. side, dir = "Front", rate = 3, color = { "#d8d8d8", "#7a7a7a" }, size = { 0.5, 1.4, 2.2 }, speed = { 1.5, 2.5 }, life = { 0.8, 1.5 }, trans = { 0.4, 0.6, 1 } })
			B:emitter(src, "fire", { name = "Backfire" .. side, dir = "Front", rate = 0, color = { "#fff0a0", FLAME, RED }, size = { 0.7, 0.4, 0 }, speed = { 4, 7 }, life = { 0.15, 0.3 }, accel = { 0, 0, 0 } })
		end)

		------------------------------------------------------------------ rear: tail lights, diffuser, spoiler
		B:block("Root", v(4.6, 0.62, 1.15), cf(0, 1.05, 4.4), BK)
		B:block("Root", v(4.4, 0.1, 0.95), cf(0, 1.41, 4.4), Y)
		B:sym(function(side)
			B:block("Root", v(0.7, 0.22, 0.08), cf(1.45, 1.15, 4.99), RED, { mat = "Neon", name = "Tail" .. side })
			B:block("Root", v(0.14, 0.4, 0.5), cf(0.5, 0.65, 4.8), BK_L)
			B:block("Root", v(0.14, 0.4, 0.5), cf(1.1, 0.65, 4.8), BK_L)
			-- spoiler struts + endplates
			B:bar("Root", v(1.2, 1.4, 4.5), v(1.2, 2.25, 4.75), 0.22, 0.3, BK_L)
			B:block("Root", v(0.14, 0.7, 1.1), cf(2.45, 2.4, 4.78), BK)
		end)
		B:block("Root", v(4.8, 0.18, 1.0), cf(0, 2.38, 4.78) * ang(-8, 0, 0), Y)
		B:block("Root", v(4.6, 0.1, 0.3), cf(0, 2.53, 4.55) * ang(-8, 0, 0), BK)
		for i = 0, 7 do
			B:block("Root", v(0.3, 0.06, 0.3), cf(-1.05 + i * 0.3, 2.51, 4.95) * ang(-8, 0, 0), i % 2 == 0 and BK or WHITE)
		end

		------------------------------------------------------------------ uprights + NOS bottles
		B:sym(function(side)
			B:bar("Root", v(2.15, 1.6, -4.45), v(2.15, 5.75, -3.95), 0.6, 0.6, Y)
			B:bar("Root", v(2.15, 2.4, -4.35), v(2.15, 5.0, -4.03), 0.64, 0.18, BK, { up = v(0, 0, 1) })
			B:block("Root", v(0.85, 0.5, 0.85), cf(2.15, 2.25, -4.42), BK_L)
			-- NOS bottle strapped outside the upright
			B:block("Root", v(0.42, 1.3, 0.42), cf(2.72, 3.4, -4.3), "#2f6bff")
			B:block("Root", v(0.46, 0.12, 0.46), cf(2.72, 3.0, -4.3), CH_L)
			B:block("Root", v(0.46, 0.12, 0.46), cf(2.72, 3.8, -4.3), CH_L)
			B:block("Root", v(0.2, 0.25, 0.2), cf(2.72, 4.17, -4.3), CH)
			B:block("Root", v(0.24, 0.1, 0.24), cf(2.72, 4.32, -4.3), RED)
			B:block("Root", v(0.44, 0.3, 0.05), cf(2.72, 3.45, -4.53), WHITE)
		end)
		B:bar("Root", v(-2.15, 4.4, -4.12), v(2.15, 4.4, -4.12), 0.4, 0.4, BK_L)

		------------------------------------------------------------------ racing dash console
		local con = cf(0, 6.1, -3.95) * ang(-30, 0, 0)
		local function C(x, y, z) return con * CFrame.new(x, y, z) end
		B:block("Root", v(6.0, 1.8, 1.3), con, BK)
		B:block("Root", v(6.1, 1.6, 1.0), C(0, -0.05, -0.3), Y)
		B:block("Root", v(6.15, 0.18, 1.4), C(0, 0.95, 0), BK_D)
		B:block("Root", v(6.15, 0.12, 1.32), C(0, -0.92, 0), BK_D)
		-- back: black stripes + checker on the yellow shell (seen from the front)
		B:block("Root", v(0.5, 1.62, 0.06), C(-0.45, -0.05, -0.82), BK)
		B:block("Root", v(0.5, 1.62, 0.06), C(0.45, -0.05, -0.82), BK)
		for i = 0, 3 do
			for r = 0, 1 do
				B:block("Root", v(0.3, 0.3, 0.06), C(1.75 + i * 0.3, 0.3 - r * 0.3, -0.82), (i + r) % 2 == 0 and BK or WHITE)
			end
		end
		B:block("Root", v(0.9, 0.5, 0.06), C(-2.0, 0.15, -0.82), WHITE)
		B:block("Root", v(0.14, 0.38, 0.08), C(-2.0, 0.15, -0.84), RED)
		-- yellow side wings
		B:sym(function()
			B:block("Root", v(0.5, 1.3, 1.1), C(3.2, -0.1, 0), Y_D)
			B:block("Root", v(0.52, 0.12, 1.12), C(3.2, 0.2, 0), BK)
		end)
		-- tachometer: yellow stepped bezel, white stepped face, long needle
		local TX, TY = -0.2, 0.0
		local function disc(r, z, col)
			B:block("Root", v(r * 2, r * 1.2, 0.06), C(TX, TY, z), col)
			B:block("Root", v(r * 1.2, r * 2, 0.06), C(TX, TY, z), col)
			B:block("Root", v(r * 1.7, r * 1.7, 0.06), C(TX, TY, z), col)
		end
		disc(0.8, 0.67, Y)
		disc(0.68, 0.69, WHITE)
		for i = 0, 6 do
			local a = 210 - i * 40
			B:block("Root", v(0.07, 0.18, 0.04), C(TX, TY, 0.73) * ang(0, 0, a - 90) * CFrame.new(0, 0.52, 0), i >= 5 and RED or BK)
		end
		local nd = B:bone("Needle", "Root", C(TX, TY, 0.76))
		B:block(nd, v(0.09, 0.62, 0.04), C(TX, TY, 0.76) * CFrame.new(0, 0.28, 0), RED, { mat = "Neon" })
		B:block(nd, v(0.2, 0.2, 0.06), C(TX, TY, 0.78), BK)
		-- boost gauge (small) with a needle
		local GX, GY = 1.55, 0.1
		B:block("Root", v(0.9, 0.56, 0.06), C(GX, GY, 0.67), CH)
		B:block("Root", v(0.56, 0.9, 0.06), C(GX, GY, 0.67), CH)
		B:block("Root", v(0.76, 0.76, 0.06), C(GX, GY, 0.67), CH)
		B:block("Root", v(0.62, 0.62, 0.06), C(GX, GY, 0.69), "#1d2a44")
		local bn = B:bone("Boost", "Root", C(GX, GY, 0.74))
		B:block(bn, v(0.06, 0.34, 0.04), C(GX, GY, 0.74) * CFrame.new(0, 0.15, 0), "#3dd6ff", { mat = "Neon" })
		-- shift lights over the tach
		local SL = { "#3dff6a", "#3dff6a", "#ffe23d", "#ffe23d", RED }
		for i = 1, 5 do
			B:block("Root", v(0.3, 0.2, 0.06), C(TX - 0.76 + (i - 1) * 0.38, 0.86, 0.66), SL[i], { mat = "Neon", name = "Shift" .. i })
		end
		-- gear indicator left of the tach + start button
		B:block("Root", v(0.8, 0.9, 0.06), C(-1.75, 0.15, 0.67), BK_D)
		for g = 1, 4 do
			B:block("Root", v(0.5, 0.14, 0.05), C(-1.75, -0.18 + (g - 1) * 0.22, 0.7), Y, { mat = "Neon", name = "Gear" .. g })
		end
		B:block("Root", v(0.5, 0.3, 0.12), C(-1.75, -0.6, 0.66), RED)
		B:block("Root", v(0.5, 0.3, 0.12), C(1.55, -0.6, 0.66), CH)
		B:sym(function()
			B:block("Root", v(0.36, 0.36, 0.1), C(2.5, 0.2, 0.66), BK_L)
			B:block("Root", v(0.2, 0.2, 0.12), C(2.5, 0.2, 0.67), Y)
		end)
		local glow = B:block("Root", v(0.2, 0.2, 0.2), C(TX, TY, 0.4), BK, { tr = 1, name = "DashGlowSrc" })
		B:light(glow, { color = FLAME, brightness = 0.5, range = 6, name = "DashGlow" })

		------------------------------------------------------------------ race start-light gantry over the dash
		B:sym(function()
			B:block("Root", v(0.45, 2.3, 0.45), cf(2.9, 7.65, -4.4), BK)
			B:block("Root", v(0.5, 0.5, 0.5), cf(2.9, 7.3, -4.4), Y)
			B:block("Root", v(0.6, 0.3, 0.6), cf(2.9, 6.6, -4.4), BK_L)
		end)
		B:block("Root", v(6.4, 0.5, 0.6), cf(0, 8.95, -4.4), Y)
		B:block("Root", v(6.2, 0.14, 0.64), cf(0, 8.72, -4.4), BK)
		for i, gx in { -1.65, -0.55, 0.55, 1.65 } do
			B:block("Root", v(0.8, 0.95, 0.5), cf(gx, 8.2, -4.4), BK_D)
			B:block("Root", v(0.5, 0.34, 0.56), cf(gx, 8.38, -4.4), RED, { mat = "Neon", name = "Start" .. i })
			B:block("Root", v(0.5, 0.26, 0.56), cf(gx, 7.96, -4.4), "#3dff6a", { mat = "Neon", name = "Go" .. i })
		end

		------------------------------------------------------------------ handrails
		B:sym(function(side)
			local x = 2.35
			B:bar("Root", v(x, 5.4, -3.55), v(x, 4.45, -0.45), 0.44, 0.44, BK_L)
			B:bar("Root", v(x, 4.45, -0.45), v(x, 1.3, -0.2), 0.38, 0.38, BK)
			B:bar("Root", v(x, 5.15, -2.75), v(x, 4.67, -1.1), 0.56, 0.56, Y)
			B:bar("Root", v(x, 5.05, -2.45), v(x, 4.95, -2.1), 0.6, 0.6, BK)
			B:block("Root", v(0.55, 0.4, 0.6), cf(x, 1.3, -0.2), BK_L)
		end)
	end,
}
