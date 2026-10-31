--!nocheck
-- Blue Treadmill (tier 1 of the treadmill ladder). The base gray treadmill,
-- upgraded: painted blue frame with white pinstripes, rubber handle grips with
-- steel end caps, a cup holder with a water bottle, 8 speed bars (2 more), a
-- calorie readout, a dangling safety key, rubber tread pads on the foot rails.
-- Faces -Z (console at the front). Animated: belt slats (Belt), roller hubs,
-- safety key swing, speed bars / calorie lights / running LED.
return {
	DisplayName = "Blue Treadmill",
	Rarity = "Common",
	Element = "Gym",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local BLUE, BLUE_D, BLUE_L = "#2f72dc", "#1d4b9e", "#69a5ff"
		local WHITE, STEEL, STEEL_D = "#eef2f8", "#b9c0cb", "#7d8590"
		local BELT, SLAT, RUBBER = "#1f2125", "#5b6270", "#1c1d21"

		-- feet
		B:sym(function()
			for _, z in { -4.2, 4.1 } do
				B:block("Root", v(0.7, 0.2, 0.7), cf(1.9, 0.1, z), RUBBER)
				B:block("Root", v(0.5, 0.1, 0.5), cf(1.9, 0.24, z), STEEL_D)
			end
		end)
		-- deck frame: blue body, dark skirt, white pinstripe
		B:block("Root", v(4.4, 0.8, 9.1), cf(0, 0.62, -0.05), BLUE)
		B:block("Root", v(4.5, 0.18, 9.2), cf(0, 0.3, -0.05), BLUE_D)
		B:sym(function()
			B:block("Root", v(0.06, 0.16, 8.2), cf(2.21, 0.8, 0.05), WHITE)
			B:block("Root", v(0.05, 0.08, 7.4), cf(2.23, 0.62, 0.25), BLUE_L)
			-- speed chevrons on the side panel
			for i = 0, 2 do
				B:block("Root", v(0.06, 0.14, 0.4), cf(2.22, 0.52, 0.6 + i * 0.55), WHITE)
			end
			B:block("Root", v(0.06, 0.3, 0.3), cf(2.21, 0.6, -2.2), BLUE_L)
			B:block("Root", v(0.06, 0.3, 0.3), cf(2.21, 0.6, 2.4), BLUE_L)
		end)
		-- foot rails with rubber tread pads
		B:sym(function()
			B:block("Root", v(0.6, 0.25, 7.2), cf(1.92, 1.12, 0.2), WHITE)
			for i = 0, 3 do
				B:block("Root", v(0.46, 0.06, 1.3), cf(1.92, 1.27, -2.3 + i * 1.7), RUBBER)
			end
		end)
		-- belt bed
		B:block("Root", v(3.3, 0.1, 7.4), cf(0, 1.05, 0.2), BELT)

		-- moving belt slats (slide +Z one gap, then repeat: seamless)
		local belt = B:bone("Belt", "Root", v(0, 1.1, 0))
		for i = 0, 14 do
			B:block(belt, v(3.2, 0.06, 0.2), cf(0, 1.13, -3.5 + i * 0.5), SLAT)
		end

		-- motor hood (front): blue with white lid, vent slots, badge
		B:block("Root", v(4.4, 0.9, 1.4), cf(0, 1.25, -3.9), BLUE)
		B:block("Root", v(4.2, 0.2, 1.2), cf(0, 1.8, -3.95), WHITE)
		B:block("Root", v(3.0, 0.1, 0.8), cf(0, 1.93, -4.0), BLUE_L)
		for i = -1, 1 do
			B:block("Root", v(0.7, 0.12, 0.08), cf(i * 0.9, 1.25, -4.62), RUBBER)
		end
		B:block("Root", v(0.9, 0.35, 0.08), cf(0, 0.6, -4.63), WHITE)
		B:block("Root", v(0.5, 0.15, 0.06), cf(0, 0.6, -4.68), BLUE)
		-- rear end cap with reflectors
		B:block("Root", v(4.4, 0.5, 0.7), cf(0, 1.05, 4.15), BLUE_D)
		B:block("Root", v(4.0, 0.12, 0.6), cf(0, 1.36, 4.15), WHITE)
		B:sym(function()
			B:block("Root", v(0.5, 0.2, 0.06), cf(1.5, 1.0, 4.52), "#e8333a")
		end)

		-- roller hubs both sides, front and back (they spin)
		for _, h in { { "HubFR", 2.28, 1.2, -3.9 }, { "HubFL", -2.28, 1.2, -3.9 }, { "HubRR", 2.28, 0.95, 4.15 }, { "HubRL", -2.28, 0.95, 4.15 } } do
			local b = B:bone(h[1], "Root", v(h[2], h[3], h[4]))
			local c = cf(h[2], h[3], h[4])
			local sx = h[2] > 0 and 1 or -1
			B:block(b, v(0.16, 0.74, 0.74), c, WHITE)
			B:block(b, v(0.16, 0.74, 0.74), c * P.ang(45, 0, 0), BLUE_L)
			B:block(b, v(0.2, 0.66, 0.14), c, BLUE_D)
			B:block(b, v(0.24, 0.26, 0.26), c * CFrame.new(sx * 0.04, 0, 0), STEEL)
		end

		-- uprights with white base collars and steel caps
		B:sym(function()
			B:block("Root", v(0.8, 0.4, 0.8), cf(1.9, 1.95, -4.25), WHITE)
			B:bar("Root", v(1.9, 1.7, -4.3), v(1.9, 5.3, -3.8), 0.55, 0.55, BLUE)
			B:bar("Root", v(1.9, 3.2, -4.12), v(1.9, 3.8, -4.04), 0.62, 0.62, BLUE_D)
		end)

		-- console, tilted so the screen faces the runner
		local con = cf(0, 5.6, -3.7) * P.ang(-30, 0, 0)
		B:block("Root", v(4.6, 0.9, 1.3), con, BLUE)
		B:block("Root", v(4.7, 0.2, 1.4), con * CFrame.new(0, 0.5, 0), BLUE_D)
		B:block("Root", v(4.0, 0.08, 1.0), con * CFrame.new(0, 0.62, 0), BLUE_L)
		B:block("Root", v(4.4, 0.12, 1.36), con * CFrame.new(0, -0.47, 0), WHITE)
		-- console back: white band, vent slots, blue badge
		B:block("Root", v(4.62, 0.18, 0.06), con * CFrame.new(0, 0.12, -0.66), WHITE)
		for i = -2, 2 do
			B:block("Root", v(0.4, 0.08, 0.06), con * CFrame.new(i * 0.7, -0.18, -0.67), BLUE_D)
		end
		B:block("Root", v(0.7, 0.28, 0.08), con * CFrame.new(0, 0.12, -0.69), BLUE_L)
		B:block("Root", v(2.9, 0.78, 0.06), con * CFrame.new(-0.05, 0.02, 0.66), RUBBER)
		-- speed display: 8 rising bars, lit in turn by the motion
		for i = 1, 8 do
			local hgt = 0.12 + (i - 1) * 0.06
			B:block("Root", v(0.24, hgt, 0.06), con * CFrame.new(-1.2 + (i - 1) * 0.32, -0.26 + hgt / 2, 0.7), "#3ff0ff", { mat = "Neon", name = "Bar" .. i })
		end
		-- calorie readout: 3 amber cells above the bars
		for i = 1, 3 do
			B:block("Root", v(0.22, 0.1, 0.06), con * CFrame.new(-1.2 + (i - 1) * 0.28, 0.3, 0.7), "#ffb02e", { mat = "Neon", name = "Cal" .. i })
		end
		-- running light + buttons (+ / - speed, stop)
		B:block("Root", v(0.2, 0.2, 0.08), con * CFrame.new(1.75, 0.18, 0.68), "#5dff6a", { mat = "Neon", name = "Led" })
		B:block("Root", v(0.42, 0.3, 0.1), con * CFrame.new(1.75, -0.16, 0.68), "#e8333a")
		B:block("Root", v(0.34, 0.2, 0.1), con * CFrame.new(-1.88, 0.16, 0.68), WHITE)
		B:block("Root", v(0.34, 0.2, 0.1), con * CFrame.new(-1.88, -0.16, 0.68), WHITE)
		B:block("Root", v(0.14, 0.06, 0.04), con * CFrame.new(-1.88, 0.16, 0.74), BLUE)
		B:block("Root", v(0.14, 0.06, 0.04), con * CFrame.new(-1.88, -0.16, 0.74), BLUE)
		B:block("Root", v(0.06, 0.14, 0.04), con * CFrame.new(-1.88, 0.16, 0.75), BLUE)

		-- safety key on a cord, clipped under the console front (swings)
		local keyPivot = con * CFrame.new(0, -0.45, 0.6)
		local key = B:bone("Key", "Root", keyPivot.Position)
		local kp = keyPivot.Position
		B:block(key, v(0.12, 0.6, 0.06), cf(kp.X, kp.Y - 0.3, kp.Z + 0.05), "#e8333a")
		B:block(key, v(0.36, 0.28, 0.1), cf(kp.X, kp.Y - 0.68, kp.Z + 0.05), "#e8333a")
		B:block(key, v(0.2, 0.1, 0.12), cf(kp.X, kp.Y - 0.68, kp.Z + 0.05), WHITE)

		-- side handrails: blue bar, chunky rubber grip, steel end cap
		B:sym(function()
			local x = 2.2
			B:bar("Root", v(1.95, 5.1, -3.75), v(x, 5.0, -3.3), 0.4, 0.4, BLUE)
			B:bar("Root", v(x, 5.0, -3.3), v(x, 4.3, -0.6), 0.36, 0.36, BLUE)
			B:bar("Root", v(x, 4.85, -2.7), v(x, 4.38, -0.85), 0.5, 0.5, RUBBER)
			for i = 0, 2 do
				local f = 0.15 + i * 0.32
				local y, z = 4.85 + (4.38 - 4.85) * f, -2.7 + (-0.85 + 2.7) * f
				B:bar("Root", v(x, y + 0.05, z - 0.08), v(x, y - 0.02, z + 0.12), 0.56, 0.56, "#2a2c31")
			end
			B:bar("Root", v(x, 4.33, -0.75), v(x, 4.25, -0.45), 0.44, 0.44, STEEL)
		end)

		-- cup holder on the right upright, with a water bottle
		local hx, hy, hz = 2.75, 4.35, -3.55
		B:bar("Root", v(2.05, 4.3, -3.95), v(hx - 0.3, hy - 0.05, hz - 0.1), 0.25, 0.25, STEEL_D)
		B:block("Root", v(0.75, 0.12, 0.75), cf(hx, hy - 0.3, hz), BLUE_D)
		B:block("Root", v(0.12, 0.5, 0.75), cf(hx + 0.32, hy, hz), BLUE)
		B:block("Root", v(0.12, 0.5, 0.75), cf(hx - 0.32, hy, hz), BLUE)
		B:block("Root", v(0.55, 0.5, 0.12), cf(hx, hy, hz + 0.32), BLUE)
		B:block("Root", v(0.55, 0.5, 0.12), cf(hx, hy, hz - 0.32), BLUE)
		B:block("Root", v(0.4, 0.9, 0.4), cf(hx, hy + 0.25, hz), "#9fd6ff", { tr = 0.25 })
		B:block("Root", v(0.42, 0.25, 0.42), cf(hx, hy + 0.3, hz), WHITE)
		B:block("Root", v(0.26, 0.16, 0.26), cf(hx, hy + 0.78, hz), BLUE_L)
		B:block("Root", v(0.14, 0.12, 0.14), cf(hx, hy + 0.9, hz), WHITE)
	end,
}
