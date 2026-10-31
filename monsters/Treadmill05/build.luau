-- Treadmill05 "Steel Pro Treadmill": brushed steel + black gym machine.
-- Faces -Z (console at the front). Belt slats on the Belt bone run toward +Z.
-- Animated: belt, 4 roller hubs, motor cooling fan, scrolling bar-graph screen,
-- pulsing pixel heart + ECG sweep, grip pulse sensors, swinging safety key.
return {
	DisplayName = "Steel Pro Treadmill",
	Rarity = "Uncommon",
	Element = "Gym",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		-- brushed steel (3 tones) + black (3 tones)
		local ST_L, ST, ST_D = "#dde1e6", "#aeb3bb", "#7b818a"
		local BK_L, BK, BK_D = "#3c3f46", "#26282d", "#141518"
		local RED, SCREEN = "#e3343c", "#0c1726"

		------------------------------------------------------------------ base
		B:sym(function()
			for _, z in { -4.3, 0, 4.3 } do
				B:block("Root", v(0.8, 0.25, 0.8), cf(1.95, 0.125, z), BK_D)
			end
			-- steel side skirt with brushed light/dark bands
			B:block("Root", v(0.4, 0.75, 9.0), cf(2.15, 0.62, 0), ST)
			B:block("Root", v(0.44, 0.14, 8.6), cf(2.15, 0.86, 0), ST_L)
			B:block("Root", v(0.44, 0.12, 8.6), cf(2.15, 0.4, 0), ST_D)
			B:block("Root", v(0.46, 0.08, 8.2), cf(2.15, 0.74, 0), RED)
			-- black bolt row on the skirt
			for i = -3, 3, 2 do
				B:block("Root", v(0.48, 0.16, 0.16), cf(2.15, 0.56, i * 1.15), BK)
			end
			-- foot rail: steel with a black rubber anti-slip strip
			B:block("Root", v(0.62, 0.26, 7.3), cf(1.96, 1.12, 0.3), ST_L)
			B:block("Root", v(0.44, 0.06, 7.0), cf(1.96, 1.27, 0.3), BK)
		end)
		B:block("Root", v(4.0, 0.75, 9.1), cf(0, 0.62, 0), BK)
		B:block("Root", v(4.6, 0.12, 9.5), cf(0, 0.29, 0), BK_D)
		-- belt bed
		B:block("Root", v(3.3, 0.1, 7.8), cf(0, 1.05, 0.2), BK_D)

		------------------------------------------------------------------ belt
		-- 2-tone slats, period 1.0 stud (motion slides +Z by 1.0 then wraps)
		local belt = B:bone("Belt", "Root", v(0, 1.1, 0))
		for i = 0, 15 do
			B:block(belt, v(3.2, 0.07, 0.24), cf(0, 1.135, -3.75 + i * 0.5), i % 2 == 0 and "#43464e" or "#5c616a")
		end

		------------------------------------------------------------------ motor hood (front)
		B:block("Root", v(4.6, 1.0, 1.6), cf(0, 1.3, -4.05), BK)
		B:block("Root", v(4.4, 0.22, 1.5), cf(0, 1.88, -4.05), ST)
		B:block("Root", v(4.0, 0.08, 1.2), cf(0, 2.02, -4.05), ST_L)
		B:block("Root", v(4.65, 0.12, 1.65), cf(0, 0.84, -4.05), ST_D)
		-- PRO badge on the hood top
		B:block("Root", v(1.4, 0.08, 0.4), cf(0, 2.08, -4.55), BK_D)
		B:block("Root", v(1.0, 0.1, 0.14), cf(0, 2.1, -4.55), RED)
		-- motor flywheel spinning under a smoked window
		B:block("Root", v(2.2, 0.1, 0.9), cf(0, 2.08, -3.85), BK_D)
		B:block("Root", v(2.0, 0.08, 0.7), cf(0, 2.15, -3.85), "#5a6a80", { tr = 0.55 })
		local fw = B:bone("Flywheel", "Root", v(0, 1.95, -3.85))
		for k, fx in { -0.55, 0.55 } do
			B:block(fw, v(0.25, 0.62, 0.62), cf(fx, 1.95, -3.85), ST_L)
			B:block(fw, v(0.25, 0.62, 0.62), cf(fx, 1.95, -3.85) * ang(45, 0, 0), ST)
			B:block(fw, v(0.29, 0.16, 0.16), cf(fx, 2.17, -3.85), RED)
		end
		B:block(fw, v(1.5, 0.16, 0.16), cf(0, 1.95, -3.85), ST_D)
		-- front face: fan grille + vent slots
		local fz = -4.86
		B:block("Root", v(1.2, 0.12, 0.1), cf(0, 1.82, fz), ST_L)
		B:block("Root", v(1.2, 0.12, 0.1), cf(0, 0.86, fz), ST_L)
		B:block("Root", v(0.12, 1.08, 0.1), cf(0.54, 1.34, fz), ST_L)
		B:block("Root", v(0.12, 1.08, 0.1), cf(-0.54, 1.34, fz), ST_L)
		B:block("Root", v(1.0, 0.85, 0.06), cf(0, 1.34, fz + 0.06), BK_D)
		local fan = B:bone("Fan", "Root", v(0, 1.34, fz - 0.02))
		local fc = cf(0, 1.34, fz - 0.05)
		for i = 0, 3 do
			B:block(fan, v(0.4, 0.2, 0.05), fc * ang(0, 0, i * 90) * CFrame.new(0.25, 0.04, 0) * ang(20, 0, 0), ST_L)
		end
		B:block(fan, v(0.24, 0.24, 0.08), fc * CFrame.new(0, 0, -0.03), RED)
		B:sym(function()
			for k = 0, 2 do
				B:block("Root", v(1.1, 0.1, 0.06), cf(1.35, 1.6 - k * 0.25, fz + 0.02), BK_D)
			end
		end)

		------------------------------------------------------------------ rear end cap
		B:block("Root", v(4.6, 0.6, 1.15), cf(0, 1.05, 4.4), BK)
		B:block("Root", v(4.4, 0.1, 0.95), cf(0, 1.4, 4.4), ST)
		for i = 0, 4 do
			B:block("Root", v(0.4, 0.05, 0.14), cf(-1.6 + i * 0.8, 1.47, 4.25 + (i % 2) * 0.3), ST_L)
		end
		B:block("Root", v(1.2, 0.3, 0.08), cf(0, 1.02, 4.99), ST_L)
		B:block("Root", v(0.8, 0.1, 0.1), cf(0, 1.02, 5.02), BK_D)
		B:sym(function()
			B:block("Root", v(0.6, 0.24, 0.08), cf(1.55, 1.05, 4.99), RED)
		end)

		------------------------------------------------------------------ roller hubs (spin)
		for _, h in { { "HubFR", 2.4, 1.3, -4.05 }, { "HubFL", -2.4, 1.3, -4.05 }, { "HubRR", 2.4, 1.05, 4.4 }, { "HubRL", -2.4, 1.05, 4.4 } } do
			local s = h[2] > 0 and 1 or -1
			local b = B:bone(h[1], "Root", v(h[2], h[3], h[4]))
			local c = cf(h[2], h[3], h[4])
			B:block(b, v(0.16, 0.8, 0.8), c, ST_L)
			B:block(b, v(0.16, 0.8, 0.8), c * ang(45, 0, 0), ST)
			B:block(b, v(0.2, 0.72, 0.14), c * CFrame.new(s * 0.04, 0, 0), BK)
			B:block(b, v(0.24, 0.2, 0.2), c * CFrame.new(s * 0.06, 0.24, 0), RED)
		end

		------------------------------------------------------------------ uprights
		B:sym(function()
			B:bar("Root", v(2.15, 1.6, -4.45), v(2.15, 5.7, -3.95), 0.6, 0.6, ST)
			B:bar("Root", v(2.15, 2.4, -4.35), v(2.15, 5.0, -4.03), 0.64, 0.2, RED, { up = v(0, 0, 1) })
			B:block("Root", v(0.85, 0.5, 0.85), cf(2.15, 1.95, -4.42), BK_L)
			B:block("Root", v(0.9, 0.12, 0.9), cf(2.15, 2.24, -4.42), ST_L)
		end)
		B:bar("Root", v(-2.15, 4.4, -4.12), v(2.15, 4.4, -4.12), 0.4, 0.4, BK_L)

		------------------------------------------------------------------ console (tilted to face the runner)
		local con = cf(0, 6.25, -3.95) * ang(-30, 0, 0)
		local function C(x, y, z) return con * CFrame.new(x, y, z) end
		B:block("Root", v(6.4, 2.0, 1.3), con, BK)
		B:block("Root", v(6.5, 1.8, 1.0), C(0, -0.05, -0.3), ST)
		B:block("Root", v(6.55, 0.18, 1.4), C(0, 1.05, 0), ST_L)
		B:block("Root", v(6.6, 0.1, 0.2), C(0, 1.0, -0.62), RED)
		B:block("Root", v(6.0, 0.16, 0.5), C(0, 1.16, -0.2), BK_L)
		B:block("Root", v(6.55, 0.12, 1.32), C(0, -1.02, 0), ST_D)
		-- stepped side wings with speaker grilles
		B:sym(function()
			B:block("Root", v(0.45, 1.5, 1.15), C(3.35, -0.1, 0), BK_L)
			B:block("Root", v(0.5, 0.14, 1.2), C(3.35, 0.7, 0), ST_L)
			for k = 0, 3 do
				B:block("Root", v(0.48, 0.08, 0.9), C(3.36, 0.35 - k * 0.27, 0.05), BK_D)
			end
		end)
		-- back panel (seen from the front of the machine): black inset, red stripe,
		-- cooling fan, vents, status LED and a PRO plate
		B:block("Root", v(5.0, 1.3, 0.06), C(0, -0.05, -0.82), BK)
		B:block("Root", v(5.0, 0.12, 0.08), C(0, 0.68, -0.83), RED)
		B:block("Root", v(1.0, 1.0, 0.06), C(-1.6, -0.05, -0.86), BK_D)
		B:block("Root", v(1.1, 0.08, 0.08), C(-1.6, 0.48, -0.87), ST_L)
		B:block("Root", v(1.1, 0.08, 0.08), C(-1.6, -0.58, -0.87), ST_L)
		local bf = B:bone("BackFan", "Root", C(-1.6, -0.05, -0.9))
		for i = 0, 3 do
			B:block(bf, v(0.38, 0.18, 0.04), C(-1.6, -0.05, -0.9) * ang(0, 0, i * 90) * CFrame.new(0.23, 0.04, 0) * ang(-20, 0, 0), ST_L)
		end
		B:block(bf, v(0.2, 0.2, 0.06), C(-1.6, -0.05, -0.93), RED)
		for k = 0, 3 do
			B:block("Root", v(2.4, 0.1, 0.06), C(0.75, 0.3 - k * 0.24, -0.86), BK_D)
		end
		B:block("Root", v(0.22, 0.22, 0.08), C(2.25, 0.3, -0.87), "#3dff73", { mat = "Neon", name = "Status" })
		B:block("Root", v(0.7, 0.3, 0.06), C(2.25, -0.25, -0.86), ST_L)
		B:block("Root", v(0.5, 0.1, 0.08), C(2.25, -0.25, -0.88), RED)
		-- heart-rate beacon on top (pulses with the heartbeat, seen from all sides)
		local bc = C(0, 1.24, -0.2)
		B:block("Root", v(1.0, 0.18, 0.5), bc, ST_D)
		local HB = { { -1, 4, 1 }, { 1, 4, 1 }, { 0, 3, 5 }, { 0, 2, 3 }, { 0, 1, 1 } }
		local hp = 0.16
		local bcU = CFrame.new(bc.Position) -- upright, facing +-Z
		for i, h in HB do
			B:block("Root", v(hp * h[3], hp, 0.14), bcU * CFrame.new(h[1] * hp, 0.02 + h[2] * hp, 0), RED, { mat = "Neon", name = "Beacon" .. i })
		end
		-- big screen with steel bezel
		local SX, SY = -0.15, 0.15
		local scr = B:block("Root", v(4.1, 1.5, 0.06), C(SX, SY, 0.67), SCREEN)
		B:block("Root", v(4.3, 0.1, 0.1), C(SX, SY + 0.8, 0.68), ST_L)
		B:block("Root", v(4.3, 0.1, 0.1), C(SX, SY - 0.8, 0.68), ST_L)
		B:block("Root", v(0.1, 1.7, 0.1), C(SX + 2.1, SY, 0.68), ST_L)
		B:block("Root", v(0.1, 1.7, 0.1), C(SX - 2.1, SY, 0.68), ST_L)
		-- scrolling bar graph: 12 columns x 5 cells (green -> yellow -> red)
		local ROWC = { "#3dff73", "#8dff3d", "#e6ff3d", "#ffb43d", "#ff4d3d" }
		for col = 1, 12 do
			for row = 1, 5 do
				B:block("Root", v(0.25, 0.15, 0.05), C(SX - 1.65 + (col - 1) * 0.3, SY - 0.12 + (row - 1) * 0.19, 0.7), ROWC[row], { mat = "Neon", name = ("Cell%d_%d"):format(col, row) })
			end
		end
		-- ECG trace along the bottom of the screen
		local ECG = { 0, 0, 0, 0, 0.08, 0.26, -0.12, 0.05, 0, 0, 0, 0, 0 }
		for j = 1, #ECG do
			local hgt = 0.05 + math.abs(ECG[j]) * 0.6
			B:block("Root", v(0.28, hgt, 0.05), C(SX - 1.8 + (j - 1) * 0.3, SY - 0.48 + ECG[j] * 0.35, 0.7), "#5dffb0", { mat = "Neon", name = "Ecg" .. j })
		end
		-- pulsing pixel heart (right of the screen)
		local HX, HY, px = 2.55, 0.45, 0.13
		local heart = { { -1, 1, 1 }, { 1, 1, 1 }, { 0, 0, 5 }, { 0, -1, 3 }, { 0, -2, 1 } }
		B:block("Root", v(0.8, 0.8, 0.06), C(HX, HY - 0.08, 0.67), SCREEN)
		for i, hp2 in heart do
			B:block("Root", v(px * hp2[3], px, 0.05), C(HX + hp2[1] * px, HY + hp2[2] * px, 0.7), RED, { mat = "Neon", name = "Heart" .. i })
		end
		-- program LEDs (left)
		for k = 1, 3 do
			B:block("Root", v(0.3, 0.18, 0.06), C(-2.75, 0.6 - (k - 1) * 0.32, 0.68), "#4db8ff", { mat = "Neon", name = "Prog" .. k })
		end
		-- button row under the screen
		local btn = { { -1.4, "#3dd36a" }, { -0.7, ST_L }, { 0, ST_L }, { 0.7, ST_L }, { 1.4, RED } }
		for _, bt in btn do
			B:block("Root", v(0.42, 0.2, 0.1), C(bt[1] - 0.15, -0.8, 0.66), bt[2])
		end
		B:block("Root", v(0.6, 0.3, 0.1), C(2.55, -0.45, 0.66), BK_L)
		B:block("Root", v(0.36, 0.14, 0.12), C(2.55, -0.45, 0.67), ST_L)
		B:light(scr, { color = "#7fd8ff", brightness = 0.5, range = 6, name = "ScreenGlow" })

		------------------------------------------------------------------ safety key on a cord (swings)
		local kp = C(2.0, -1.0, 0.5).Position
		local key = B:bone("Key", "Root", kp)
		B:block(key, v(0.08, 0.6, 0.08), CFrame.new(kp + Vector3.new(0, -0.28, 0)), BK_D)
		B:block(key, v(0.22, 0.14, 0.22), CFrame.new(kp + Vector3.new(0, -0.6, 0)), "#ffd23d")
		B:block(key, v(0.36, 0.4, 0.14), CFrame.new(kp + Vector3.new(0, -0.86, 0)), RED)

		------------------------------------------------------------------ handrails with pulse grips
		B:sym(function(side)
			local x = 2.35
			B:bar("Root", v(x, 5.35, -3.55), v(x, 4.45, -0.45), 0.42, 0.42, ST)
			B:bar("Root", v(x, 4.45, -0.45), v(x, 1.3, -0.2), 0.36, 0.36, ST_D)
			B:bar("Root", v(x, 5.1, -2.75), v(x, 4.62, -1.1), 0.54, 0.54, BK)
			-- steel pulse sensor plates + LED
			B:bar("Root", v(x, 5.02, -2.45), v(x, 4.86, -1.9), 0.58, 0.3, ST_L)
			B:block("Root", v(0.2, 0.12, 0.2), cf(x, 5.08, -2.3) * ang(-17, 0, 0), RED, { mat = "Neon", name = "Grip" .. side })
			B:block("Root", v(0.55, 0.4, 0.6), cf(x, 1.3, -0.2), BK_L)
		end)
		-- wrap-around front handlebar
		B:bar("Root", v(-2.35, 5.0, -3.25), v(2.35, 5.0, -3.25), 0.4, 0.4, ST)
		B:bar("Root", v(-1.2, 5.0, -3.25), v(1.2, 5.0, -3.25), 0.5, 0.5, BK)
		-- towel draped over the left handrail
		B:block("Root", v(0.62, 0.12, 0.9), cf(-2.35, 4.95, -1.75) * ang(-17, 0, 0), "#f4f6f8")
		B:block("Root", v(0.1, 0.85, 0.9), cf(-2.68, 4.5, -1.7) * ang(-17, 0, 0), "#f4f6f8")
		B:block("Root", v(0.12, 0.12, 0.92), cf(-2.68, 4.25, -1.62) * ang(-17, 0, 0), "#3d8dff")
		B:block("Root", v(0.1, 0.65, 0.9), cf(-2.02, 4.62, -1.72) * ang(-17, 0, 0), "#f4f6f8")
		-- water bottle in a steel cage (right upright)
		B:block("Root", v(0.7, 0.12, 0.7), cf(2.95, 3.0, -4.15), ST_L)
		B:block("Root", v(0.12, 1.1, 0.12), cf(3.25, 3.5, -4.15), ST_L)
		B:block("Root", v(0.45, 1.0, 0.45), cf(2.95, 3.55, -4.15), "#3d8dff")
		B:block("Root", v(0.48, 0.2, 0.48), cf(2.95, 3.6, -4.15), "#9fd0ff")
		B:block("Root", v(0.26, 0.22, 0.26), cf(2.95, 4.15, -4.15), "#f2f2f2")
		B:block("Root", v(0.5, 0.15, 0.3), cf(2.6, 3.0, -4.15), ST)
	end,
}
