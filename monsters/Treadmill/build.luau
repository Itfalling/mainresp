-- Treadmill: a plain gray gym treadmill. Faces -Z (console at the front).
-- Animated parts: the belt slats (Belt bone), the four roller hubs, and the
-- console speed display / running light.
return {
	DisplayName = "Treadmill",
	Rarity = "Common",
	Element = "Gym",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local MAIN, DARK, LIGHT = "#8c919b", "#5e636c", "#b9bec7"
		local BELT, SLAT, RUBBER = "#1f2125", "#6a6f7a", "#1c1d21"

		-- feet + frame
		B:sym(function(side)
			local x = 1.9
			for _, z in { -4.2, 4.1 } do
				B:block("Root", v(0.6, 0.2, 0.6), cf(x, 0.1, z), RUBBER)
			end
		end)
		B:block("Root", v(4.4, 0.8, 9.1), cf(0, 0.6, -0.05), MAIN)
		B:block("Root", v(4.5, 0.15, 9.2), cf(0, 0.28, -0.05), DARK)
		-- foot rails either side of the belt
		B:block("Root", v(0.55, 0.25, 7.2), cf(1.92, 1.12, 0.2), LIGHT)
		B:block("Root", v(0.55, 0.25, 7.2), cf(-1.92, 1.12, 0.2), LIGHT)
		-- belt bed
		B:block("Root", v(3.3, 0.1, 7.4), cf(0, 1.05, 0.2), BELT)

		-- moving belt slats (slide +Z one gap, then repeat: seamless)
		local belt = B:bone("Belt", "Root", v(0, 1.1, 0))
		for i = 0, 14 do
			B:block(belt, v(3.2, 0.06, 0.18), cf(0, 1.13, -3.5 + i * 0.5), SLAT)
		end

		-- motor hood (front) and rear end cap hide the slat ends
		B:block("Root", v(4.4, 0.9, 1.4), cf(0, 1.25, -3.9), MAIN)
		B:block("Root", v(4.2, 0.2, 1.2), cf(0, 1.8, -3.95), LIGHT)
		B:block("Root", v(4.4, 0.5, 0.7), cf(0, 1.05, 4.15), DARK)

		-- roller hubs on both sides, front and back (they spin)
		for _, h in { { "HubFR", 2.28, 1.2, -3.9 }, { "HubFL", -2.28, 1.2, -3.9 }, { "HubRR", 2.28, 0.95, 4.15 }, { "HubRL", -2.28, 0.95, 4.15 } } do
			local b = B:bone(h[1], "Root", v(h[2], h[3], h[4]))
			local c = cf(h[2], h[3], h[4])
			B:block(b, v(0.16, 0.7, 0.7), c, LIGHT)
			B:block(b, v(0.16, 0.7, 0.7), c * P.ang(45, 0, 0), LIGHT)
			B:block(b, v(0.2, 0.62, 0.14), c, DARK)
		end

		-- uprights
		B:beam("Root", v(1.9, 1.6, -4.3), v(1.9, 5.3, -3.8), 0.5, 0.5, MAIN)
		B:beam("Root", v(-1.9, 1.6, -4.3), v(-1.9, 5.3, -3.8), 0.5, 0.5, MAIN)

		-- console, tilted so the screen faces the runner
		local con = cf(0, 5.6, -3.7) * P.ang(-30, 0, 0)
		B:block("Root", v(4.6, 0.9, 1.3), con, MAIN)
		B:block("Root", v(4.7, 0.2, 1.4), con * CFrame.new(0, 0.5, 0), DARK)
		B:block("Root", v(2.4, 0.7, 0.06), con * CFrame.new(0, 0.02, 0.66), RUBBER)
		-- speed display: 6 rising bars, lit in turn by the motion
		for i = 1, 6 do
			local hgt = 0.12 + (i - 1) * 0.06
			B:block("Root", v(0.26, hgt, 0.06), con * CFrame.new(-0.9 + (i - 1) * 0.36, -0.22 + hgt / 2, 0.7), "#3ff0ff", { mat = "Neon", name = "Bar" .. i })
		end
		-- running light + buttons
		B:block("Root", v(0.2, 0.2, 0.08), con * CFrame.new(1.65, 0.15, 0.68), "#5dff6a", { mat = "Neon", name = "Led" })
		B:block("Root", v(0.4, 0.3, 0.1), con * CFrame.new(1.65, -0.18, 0.68), "#e8333a")
		B:block("Root", v(0.35, 0.22, 0.1), con * CFrame.new(-1.75, 0.12, 0.68), LIGHT)
		B:block("Root", v(0.35, 0.22, 0.1), con * CFrame.new(-1.75, -0.18, 0.68), LIGHT)

		-- side handrails with dark grips
		B:sym(function(side)
			local x = 2.2
			B:beam("Root", v(x, 5.0, -3.3), v(x, 4.3, -0.6), 0.35, 0.35, LIGHT)
			B:beam("Root", v(x, 4.75, -2.3), v(x, 4.4, -0.9), 0.45, 0.45, RUBBER)
		end)
	end,
}
