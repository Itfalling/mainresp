-- Treadmill06 "Neon Runner": dark navy frame with neon edge strips that chase
-- along both sides, glowing belt seams, pumping speaker pylons with equalizers,
-- twin glowing hood fans and a track-map screen. Faces -Z (console at the front).
return {
	DisplayName = "Neon Runner",
	Rarity = "Rare",
	Element = "Neon",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local DK_L, DK, DK_D = "#3a3f5e", "#24273b", "#121320"
		local MET = "#5b6282"
		local CY, MG = "#2ef2ff", "#ff3df0"
		local SCREEN = "#060912"

		------------------------------------------------------------------ base frame
		B:sym(function(side)
			for _, z in { -4.3, 0, 4.3 } do
				B:block("Root", v(0.8, 0.25, 0.8), cf(1.95, 0.125, z), DK_D)
			end
			-- stepped side skirt
			B:block("Root", v(0.45, 0.8, 9.0), cf(2.15, 0.62, 0), DK)
			B:block("Root", v(0.5, 0.18, 9.1), cf(2.17, 0.3, 0), DK_D)
			B:block("Root", v(0.3, 0.12, 8.6), cf(2.3, 0.62, 0), DK_L)
			-- lower magenta pin-stripe
			B:block("Root", v(0.06, 0.08, 8.4), cf(2.43, 0.42, 0), MG, { mat = "Neon" })
			-- chase segments along the top outer edge
			for i = 1, 14 do
				B:block("Root", v(0.14, 0.14, 0.4), cf(2.42, 0.9, -3.4 + (i - 1) * 0.52), CY, { mat = "Neon", name = ("Chase%s%d"):format(side, i) })
			end
			-- foot rail with a neon inner lip
			B:block("Root", v(0.62, 0.26, 7.3), cf(1.96, 1.12, 0.3), DK_L)
			B:block("Root", v(0.44, 0.06, 7.0), cf(1.96, 1.27, 0.3), DK_D)
			B:block("Root", v(0.06, 0.08, 7.0), cf(1.62, 1.2, 0.3), CY, { mat = "Neon" })
		end)
		B:block("Root", v(4.0, 0.75, 9.1), cf(0, 0.62, 0), DK_D)
		B:block("Root", v(4.6, 0.12, 9.5), cf(0, 0.25, 0), DK_D)
		B:block("Root", v(3.3, 0.1, 7.8), cf(0, 1.05, 0.2), "#0b0c14")

		------------------------------------------------------------------ belt with glowing seams
		local belt = B:bone("Belt", "Root", v(0, 1.1, 0))
		for i = 0, 15 do
			local z = -3.75 + i * 0.5
			B:block(belt, v(3.2, 0.07, 0.38), cf(0, 1.135, z), "#2a2d40")
			B:block(belt, v(3.1, 0.05, 0.07), cf(0, 1.15, z + 0.25), CY, { mat = "Neon", name = "Seam" .. (i + 1) })
		end

		------------------------------------------------------------------ motor hood: twin fans + neon chevron
		local fz = -4.86
		B:block("Root", v(4.6, 1.05, 1.6), cf(0, 1.32, -4.05), DK)
		B:block("Root", v(4.4, 0.22, 1.5), cf(0, 1.92, -4.05), DK_L)
		B:block("Root", v(3.4, 0.1, 1.1), cf(0, 2.06, -4.1), DK)
		B:block("Root", v(3.0, 0.06, 0.1), cf(0, 2.12, -4.6), MG, { mat = "Neon" })
		B:block("Root", v(4.65, 0.14, 1.65), cf(0, 0.84, -4.05), DK_D)
		B:bar("Root", v(-0.55, 1.75, fz - 0.03), v(0, 1.1, fz - 0.03), 0.12, 0.08, MG, { mat = "Neon", name = "ChevL", up = v(0, 0, -1) })
		B:bar("Root", v(0.55, 1.75, fz - 0.03), v(0, 1.1, fz - 0.03), 0.12, 0.08, MG, { mat = "Neon", name = "ChevR", up = v(0, 0, -1) })
		B:sym(function(side)
			local fx = 1.35
			B:block("Root", v(1.0, 0.9, 0.06), cf(fx, 1.34, fz + 0.06), DK_D)
			-- glowing ring (square)
			B:block("Root", v(1.06, 0.08, 0.08), cf(fx, 1.81, fz), CY, { mat = "Neon" })
			B:block("Root", v(1.06, 0.08, 0.08), cf(fx, 0.87, fz), CY, { mat = "Neon" })
			B:block("Root", v(0.08, 0.86, 0.08), cf(fx + 0.5, 1.34, fz), DK_L)
			B:block("Root", v(0.08, 0.86, 0.08), cf(fx - 0.5, 1.34, fz), DK_L)
			local fan = B:bone("Fan" .. side, "Root", v(fx, 1.34, fz - 0.05))
			local fc = cf(fx, 1.34, fz - 0.05)
			for i = 0, 3 do
				B:block(fan, v(0.38, 0.18, 0.05), fc * ang(0, 0, i * 90) * CFrame.new(0.23, 0.04, 0) * ang(20, 0, 0), MET)
			end
			B:block(fan, v(0.2, 0.2, 0.08), fc * CFrame.new(0, 0, -0.03), CY, { mat = "Neon" })
		end)

		------------------------------------------------------------------ rear end cap + tail lights
		local tail = B:block("Root", v(4.6, 0.62, 1.15), cf(0, 1.05, 4.4), DK)
		B:block("Root", v(4.4, 0.1, 0.95), cf(0, 1.41, 4.4), DK_L)
		B:block("Root", v(3.6, 0.1, 0.08), cf(0, 1.1, 4.99), MG, { mat = "Neon", name = "TailBar" })
		B:sym(function()
			B:block("Root", v(0.3, 0.3, 0.08), cf(2.0, 1.1, 4.99), CY, { mat = "Neon" })
		end)
		B:light(tail, { color = MG, brightness = 0.8, range = 7, name = "TailGlow" })
		local mote = B:block("Root", v(3.0, 0.2, 0.4), cf(0, 1.4, 4.9), DK, { tr = 1, name = "MoteSrc" })
		B:emitter(mote, "sparkle", { name = "Motes", color = { CY, MG }, rate = 5, speed = { 0.5, 1.5 }, size = { 0.15, 0.3, 0 }, life = { 0.6, 1.2 }, accel = { 0, 1, 2 } })

		------------------------------------------------------------------ roller hubs (spin + light trails)
		for _, h in { { "HubFR", 2.45, 1.32, -4.05 }, { "HubFL", -2.45, 1.32, -4.05 }, { "HubRR", 2.45, 1.05, 4.4 }, { "HubRL", -2.45, 1.05, 4.4 } } do
			local s = h[2] > 0 and 1 or -1
			local b = B:bone(h[1], "Root", v(h[2], h[3], h[4]))
			local c = cf(h[2], h[3], h[4])
			B:block(b, v(0.16, 0.82, 0.82), c, DK_L)
			B:block(b, v(0.16, 0.82, 0.82), c * ang(45, 0, 0), DK)
			B:block(b, v(0.2, 0.3, 0.3), c * CFrame.new(s * 0.04, 0, 0), DK_D)
			B:block(b, v(0.22, 0.16, 0.16), c * CFrame.new(s * 0.05, 0.3, 0), CY, { mat = "Neon" })
			B:block(b, v(0.22, 0.16, 0.16), c * CFrame.new(s * 0.05, -0.3, 0), MG, { mat = "Neon" })
			local tip = (c * CFrame.new(s * 0.12, 0.3, 0)).Position
			B:trail(b, tip + Vector3.new(0, 0.08, 0), tip - Vector3.new(0, 0.08, 0), { color = CY, life = 0.2, name = "Trail" .. h[1] })
		end

		------------------------------------------------------------------ uprights + speaker pylons
		B:sym(function(side)
			B:bar("Root", v(2.15, 1.6, -4.45), v(2.15, 5.75, -3.95), 0.6, 0.6, DK)
			B:bar("Root", v(2.48, 2.0, -4.4), v(2.48, 5.4, -4.0), 0.06, 0.12, CY, { mat = "Neon" })
			B:block("Root", v(0.85, 0.5, 0.85), cf(2.15, 1.95, -4.42), DK_L)
			-- speaker pylon beside the upright
			local px, pz = 3.05, -4.25
			B:block("Root", v(0.9, 4.4, 1.0), cf(px, 2.3, pz), DK)
			B:block("Root", v(1.0, 0.3, 1.1), cf(px, 0.15, pz), DK_D)
			B:block("Root", v(1.0, 0.2, 1.1), cf(px, 4.55, pz), DK_L)
			B:block("Root", v(0.7, 0.1, 0.8), cf(px, 4.7, pz), MG, { mat = "Neon", name = "Cap" .. side })
			B:block("Root", v(0.4, 0.5, 0.4), cf(2.6, 2.4, pz), DK_D) -- brace to the upright
			-- woofers on the front face (pump on the beat)
			for k, wy in { 1.25, 3.35 } do
				B:block("Root", v(0.8, 0.8, 0.06), cf(px, wy, pz - 0.52), DK_D)
				local w = B:bone(("Woofer%s%d"):format(side, k), "Root", v(px, wy, pz - 0.54))
				B:block(w, v(0.6, 0.6, 0.08), cf(px, wy, pz - 0.56), DK_L)
				B:block(w, v(0.36, 0.36, 0.1), cf(px, wy, pz - 0.6), MET)
				B:block(w, v(0.16, 0.16, 0.1), cf(px, wy, pz - 0.65), CY, { mat = "Neon" })
			end
			-- equalizer: 2 columns x 6 cells on the outer face
			local EQC = { CY, CY, "#8f9bff", "#c46bff", MG, MG }
			for col = 1, 2 do
				for row = 1, 6 do
					B:block("Root", v(0.06, 0.22, 0.32), cf(px + 0.46, 1.65 + (row - 1) * 0.36, pz - 0.22 + (col - 1) * 0.44), EQC[row], { mat = "Neon", name = ("Eq%s%d_%d"):format(side, col, row) })
				end
			end
		end)
		B:bar("Root", v(-2.15, 4.4, -4.12), v(2.15, 4.4, -4.12), 0.4, 0.4, DK_L)
		B:block("Root", v(3.6, 0.06, 0.1), cf(0, 4.6, -4.12), CY, { mat = "Neon" })

		------------------------------------------------------------------ console
		local con = cf(0, 6.1, -3.95) * ang(-30, 0, 0)
		local function C(x, y, z) return con * CFrame.new(x, y, z) end
		B:block("Root", v(6.0, 1.7, 1.3), con, DK)
		B:block("Root", v(6.1, 1.5, 1.0), C(0, -0.05, -0.3), DK_L)
		B:block("Root", v(6.15, 0.18, 1.4), C(0, 0.9, 0), DK_D)
		B:block("Root", v(6.0, 0.06, 0.1), C(0, 1.0, 0.66), CY, { mat = "Neon" })
		B:block("Root", v(6.15, 0.12, 1.32), C(0, -0.88, 0), DK_D)
		-- stepped side wings
		B:sym(function()
			B:block("Root", v(0.5, 1.2, 1.1), C(3.2, -0.1, 0), DK_L)
			B:block("Root", v(0.52, 0.08, 0.6), C(3.2, 0.2, 0.3), MG, { mat = "Neon" })
		end)
		-- back face: neon logo stripes (seen from the front of the machine)
		B:block("Root", v(3.8, 0.9, 0.06), C(0, 0, -0.83), DK_D)
		B:block("Root", v(3.2, 0.1, 0.06), C(0, 0.2, -0.87), CY, { mat = "Neon", name = "LogoA" })
		B:block("Root", v(2.2, 0.1, 0.06), C(-0.5, -0.1, -0.87), MG, { mat = "Neon", name = "LogoB" })
		-- screen
		local SX, SY = -0.2, 0.15
		local scr = B:block("Root", v(4.0, 1.35, 0.06), C(SX, SY, 0.67), SCREEN)
		B:block("Root", v(4.2, 0.1, 0.1), C(SX, SY + 0.72, 0.68), DK_L)
		B:block("Root", v(4.2, 0.1, 0.1), C(SX, SY - 0.72, 0.68), DK_L)
		B:block("Root", v(0.1, 1.54, 0.1), C(SX + 2.05, SY, 0.68), DK_L)
		B:block("Root", v(0.1, 1.54, 0.1), C(SX - 2.05, SY, 0.68), DK_L)
		B:light(scr, { color = CY, brightness = 0.6, range = 7, name = "ScreenGlow" })
		-- track map: a loop of 14 segments, the lit one is the runner
		local TX, TY = SX - 0.75, SY + 0.05
		local trk = {}
		for i = 0, 4 do table.insert(trk, { -0.96 + i * 0.48, 0.42, 0.42, 0.1 }) end -- top, left->right
		table.insert(trk, { 1.2, 0.14, 0.1, 0.4 })
		table.insert(trk, { 1.2, -0.28, 0.1, 0.4 })
		for i = 4, 0, -1 do table.insert(trk, { -0.96 + i * 0.48, -0.48, 0.42, 0.1 }) end -- bottom, right->left
		table.insert(trk, { -1.2, -0.28, 0.1, 0.4 })
		table.insert(trk, { -1.2, 0.14, 0.1, 0.4 })
		for i, sg in trk do
			B:block("Root", v(sg[3], sg[4], 0.05), C(TX + sg[1], TY + sg[2], 0.7), CY, { mat = "Neon", name = "Trk" .. i })
		end
		B:block("Root", v(2.0, 0.55, 0.05), C(TX, TY - 0.03, 0.695), "#10203a")
		-- rising speed bars
		for i = 1, 6 do
			local hgt = 0.18 + (i - 1) * 0.15
			B:block("Root", v(0.17, hgt, 0.05), C(SX + 0.85 + (i - 1) * 0.22, SY - 0.55 + hgt / 2, 0.7), i <= 3 and CY or MG, { mat = "Neon", name = "Spd" .. i })
		end
		-- buttons
		for k, bx in { -1.6, -0.8, 0, 0.8, 1.6 } do
			B:block("Root", v(0.44, 0.2, 0.1), C(SX + bx, -0.72, 0.66), k == 1 and CY or (k == 5 and MG or DK_L), k ~= 1 and k ~= 5 and {} or { mat = "Neon" })
		end

		------------------------------------------------------------------ handrails
		B:sym(function(side)
			local x = 2.35
			B:bar("Root", v(x, 5.4, -3.55), v(x, 4.45, -0.45), 0.44, 0.44, DK_L)
			B:bar("Root", v(x, 5.4, -3.55) + v(0, 0.24, 0), v(x, 4.45, -0.45) + v(0, 0.24, 0), 0.1, 0.06, CY, { mat = "Neon", name = "Rail" .. side })
			B:bar("Root", v(x, 4.45, -0.45), v(x, 1.3, -0.2), 0.38, 0.38, DK)
			B:bar("Root", v(x, 5.15, -2.75), v(x, 4.67, -1.1), 0.56, 0.56, DK_D)
			B:block("Root", v(0.55, 0.4, 0.6), cf(x, 1.3, -0.2), DK_L)
		end)
	end,
}
