--!nocheck
-- Sport Treadmill (tier 2 of the treadmill ladder). Racing red with white
-- twin stripes: a chunkier deck, wide raised side foot rails with grip tread,
-- sport rims on the rollers, a checkered rear cap, a big #7 race plate on the
-- hood, and a console with a spinning cooling fan, 8-bar speed meter, heart-rate
-- light and a lap counter. Faces -Z (console at the front).
-- Animated: belt slats (Belt), rim hubs, console Fan, safety Key swing,
-- speed bars / heart / lap / LED lights.
return {
	DisplayName = "Sport Treadmill",
	Rarity = "Common",
	Element = "Gym",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local RED, RED_D, RED_L = "#e3242b", "#a3151b", "#ff5c5c"
		local WHITE, WHITE_D = "#f6f7fa", "#d2d6de"
		local CHAR, CHAR_L, BLACK = "#2c2e34", "#474a52", "#16171a"
		local SLAT, BED = "#3d4048", "#1a1b1f"

		-- chunky feet
		B:sym(function()
			for _, z in { -4.4, 4.3 } do
				B:block("Root", v(0.9, 0.25, 0.9), cf(2.0, 0.125, z), BLACK)
				B:block("Root", v(0.6, 0.12, 0.6), cf(2.0, 0.3, z), RED_D)
			end
		end)
		-- chunkier deck: red body, charcoal skirt, twin white racing stripes
		B:block("Root", v(4.8, 1.0, 9.6), cf(0, 0.8, -0.05), RED)
		B:block("Root", v(4.9, 0.22, 9.7), cf(0, 0.38, -0.05), CHAR)
		B:sym(function()
			B:block("Root", v(0.06, 0.16, 8.6), cf(2.41, 1.02, 0.1), WHITE)
			B:block("Root", v(0.06, 0.16, 8.6), cf(2.41, 0.76, 0.1), WHITE)
			B:block("Root", v(0.05, 0.08, 1.6), cf(2.43, 0.89, -2.6), RED_L)
		end)
		-- belt bed
		B:block("Root", v(3.5, 0.1, 7.6), cf(0, 1.28, 0.2), BED)

		-- moving belt slats (slide +Z one gap, then repeat: seamless)
		local belt = B:bone("Belt", "Root", v(0, 1.33, 0))
		for i = 0, 15 do
			B:block(belt, v(3.4, 0.06, 0.22), cf(0, 1.36, -3.75 + i * 0.5), SLAT)
		end

		-- wide raised side foot rails: white with black grip tread + red edge
		B:sym(function()
			B:block("Root", v(0.9, 0.3, 7.15), cf(2.2, 1.32, 0.17), WHITE)
			B:block("Root", v(0.12, 0.32, 7.17), cf(1.78, 1.33, 0.17), RED)
			for i = 0, 5 do
				B:block("Root", v(0.62, 0.06, 0.8), cf(2.24, 1.49, -2.9 + i * 1.2), BLACK)
			end
		end)

		-- motor hood: red with white lid, twin stripes, vents, #7 race plate
		B:block("Root", v(4.8, 1.0, 1.5), cf(0, 1.5, -4.1), RED)
		B:block("Root", v(4.6, 0.22, 1.35), cf(0, 2.1, -4.15), WHITE)
		B:block("Root", v(4.0, 0.1, 1.1), cf(0, 2.25, -4.2), RED)
		for _, x in { -0.35, 0.35 } do
			B:block("Root", v(0.3, 0.06, 1.12), cf(x, 2.32, -4.2), WHITE)
		end
		for i = 0, 3 do
			B:block("Root", v(0.1, 0.5, 0.08), cf(-2.0 + i * 0.25, 1.5, -4.87), BLACK)
			B:block("Root", v(0.1, 0.5, 0.08), cf(1.25 + i * 0.25, 1.5, -4.87), BLACK)
		end
		-- race plate with a pixel "7"
		B:block("Root", v(1.3, 0.85, 0.08), cf(0, 1.0, -4.88), WHITE)
		B:block("Root", v(0.7, 0.14, 0.06), cf(0, 1.3, -4.94), BLACK)
		B:block("Root", v(0.14, 0.32, 0.06), cf(-0.25, 1.1, -4.94), BLACK)
		B:block("Root", v(0.14, 0.3, 0.06), cf(-0.12, 0.82, -4.94), BLACK)
		-- rear end cap: charcoal with checkered flag face + red tail lights
		B:block("Root", v(4.8, 0.6, 0.85), cf(0, 1.2, 4.32), CHAR)
		B:block("Root", v(4.4, 0.14, 0.75), cf(0, 1.56, 4.32), WHITE)
		for i = 0, 7 do
			for r = 0, 1 do
				B:block("Root", v(0.36, 0.2, 0.06), cf(-1.26 + i * 0.36, 1.07 + r * 0.2, 4.76), (i + r) % 2 == 0 and WHITE or BLACK)
			end
		end
		B:sym(function()
			B:block("Root", v(0.55, 0.3, 0.08), cf(1.95, 1.17, 4.77), RED_L)
		end)

		-- sport rims on the rollers (they spin): black tyre ring, red rim, white spokes
		for _, h in { { "HubFR", 2.5, 1.1, -4.1 }, { "HubFL", -2.5, 1.1, -4.1 }, { "HubRR", 2.5, 1.0, 4.32 }, { "HubRL", -2.5, 1.0, 4.32 } } do
			local b = B:bone(h[1], "Root", v(h[2], h[3], h[4]))
			local sx = h[2] > 0 and 1 or -1
			local c = cf(h[2], h[3], h[4])
			B:ring(b, c * ang(0, 0, 90), 0.42, 8, v(0.18, 0.18, 0.2), BLACK)
			B:block(b, v(0.16, 0.66, 0.66), c, RED)
			B:block(b, v(0.2, 0.7, 0.14), c, WHITE)
			B:block(b, v(0.2, 0.14, 0.7), c, WHITE)
			B:block(b, v(0.26, 0.24, 0.24), c * CFrame.new(sx * 0.03, 0, 0), RED_D)
		end

		-- stepped uprights: red with white outside stripe
		B:sym(function()
			B:block("Root", v(0.95, 0.45, 0.95), cf(2.1, 2.3, -4.45), WHITE)
			B:block("Root", v(0.75, 0.2, 0.75), cf(2.1, 2.6, -4.42), CHAR)
			B:bar("Root", v(2.1, 2.0, -4.5), v(2.1, 5.6, -4.0), 0.68, 0.68, RED)
			B:bar("Root", v(2.46, 2.6, -4.42), v(2.46, 5.3, -4.05), 0.06, 0.24, WHITE)
			B:bar("Root", v(2.1, 3.9, -4.29), v(2.1, 4.3, -4.23), 0.76, 0.76, CHAR)
		end)

		-- console (tilted to face the runner)
		local con = cf(0, 5.95, -3.9) * ang(-30, 0, 0)
		local function cp(x, y, z) return con * CFrame.new(x, y, z) end
		B:block("Root", v(5.4, 1.15, 1.4), con, RED)
		B:block("Root", v(5.5, 0.22, 1.5), cp(0, 0.62, 0), WHITE)
		B:block("Root", v(4.6, 0.08, 1.1), cp(0, 0.76, 0), RED)
		for _, x in { -0.35, 0.35 } do
			B:block("Root", v(0.3, 0.06, 1.12), cp(x, 0.82, 0), WHITE)
		end
		B:block("Root", v(5.3, 0.14, 1.42), cp(0, -0.6, 0), CHAR)
		B:block("Root", v(5.0, 0.95, 0.06), cp(0, 0.02, 0.71), BLACK)
		B:block("Root", v(5.42, 0.2, 0.06), cp(0, 0.1, -0.71), WHITE)
		-- left: 8-bar speed meter
		for i = 1, 8 do
			local hgt = 0.12 + (i - 1) * 0.07
			B:block("Root", v(0.16, hgt, 0.06), cp(-2.25 + (i - 1) * 0.22, -0.32 + hgt / 2, 0.75), "#3ff0ff", { mat = "Neon", name = "Bar" .. i })
		end
		-- centre: cooling fan in a white frame (blades spin on bone Fan)
		B:block("Root", v(1.2, 1.0, 0.06), cp(0, 0.02, 0.74), CHAR)
		B:block("Root", v(1.2, 0.12, 0.16), cp(0, 0.52, 0.78), WHITE)
		B:block("Root", v(1.2, 0.12, 0.16), cp(0, -0.48, 0.78), WHITE)
		B:block("Root", v(0.12, 1.0, 0.16), cp(0.6, 0.02, 0.78), WHITE)
		B:block("Root", v(0.12, 1.0, 0.16), cp(-0.6, 0.02, 0.78), WHITE)
		local fpiv = cp(0, 0.02, 0.8)
		local fan = B:bone("Fan", "Root", fpiv)
		for k = 0, 3 do
			B:block(fan, v(0.86, 0.2, 0.04), fpiv * ang(0, 0, 45 * k), k == 0 and RED or WHITE_D)
		end
		B:block(fan, v(0.26, 0.26, 0.08), fpiv * CFrame.new(0, 0, 0.03), RED)
		B:block(fan, v(0.12, 0.12, 0.06), fpiv * CFrame.new(0, 0, 0.08), WHITE)
		-- right: heart light, lap counter (4 cells in a square), LED, buttons
		B:block("Root", v(0.3, 0.26, 0.06), cp(1.0, 0.22, 0.75), "#ff3d7f", { mat = "Neon", name = "Heart" })
		for i, o in { { 0, 1 }, { 1, 1 }, { 1, 0 }, { 0, 0 } } do
			B:block("Root", v(0.2, 0.16, 0.06), cp(1.45 + o[1] * 0.24, -0.25 + o[2] * 0.2, 0.75), "#ffb02e", { mat = "Neon", name = "Lap" .. i })
		end
		B:block("Root", v(0.18, 0.18, 0.08), cp(1.0, -0.2, 0.75), "#5dff6a", { mat = "Neon", name = "Led" })
		B:block("Root", v(0.42, 0.34, 0.12), cp(2.2, -0.15, 0.74), RED_L)
		B:block("Root", v(0.36, 0.2, 0.1), cp(2.2, 0.27, 0.74), WHITE)

		-- safety key on a cord (swings)
		local kp = cp(0, -0.6, 0.62).Position
		local key = B:bone("Key", "Root", kp)
		B:block(key, v(0.12, 0.6, 0.06), cf(kp.X, kp.Y - 0.3, kp.Z + 0.05), "#ffd23a")
		B:block(key, v(0.38, 0.28, 0.1), cf(kp.X, kp.Y - 0.68, kp.Z + 0.05), RED)
		B:block(key, v(0.2, 0.1, 0.12), cf(kp.X, kp.Y - 0.68, kp.Z + 0.05), WHITE)

		-- chunky handrails: red bar, white pulse-sensor plates, black grips
		B:sym(function()
			local x = 2.45
			B:bar("Root", v(2.15, 5.35, -3.95), v(x, 5.2, -3.4), 0.46, 0.46, RED)
			B:bar("Root", v(x, 5.2, -3.4), v(x, 4.5, -0.5), 0.42, 0.42, RED)
			B:bar("Root", v(x, 5.07, -2.85), v(x, 4.62, -1.0), 0.54, 0.54, BLACK)
			B:bar("Root", v(x, 5.18, -3.25), v(x, 5.08, -2.85), 0.56, 0.56, WHITE_D)
			for i = 0, 3 do
				local f = 0.12 + i * 0.25
				local y, z = 5.07 + (4.62 - 5.07) * f, -2.85 + (-1.0 + 2.85) * f
				B:bar("Root", v(x, y + 0.03, z - 0.06), v(x, y - 0.02, z + 0.1), 0.6, 0.6, CHAR_L)
			end
			B:bar("Root", v(x, 4.58, -0.85), v(x, 4.46, -0.4), 0.5, 0.5, RED_D)
		end)

		-- sports bottle in a cage on the right upright
		local hx, hy, hz = 2.98, 4.6, -3.75
		B:bar("Root", v(2.3, 4.55, -4.15), v(hx - 0.3, hy - 0.05, hz - 0.1), 0.25, 0.25, CHAR)
		B:block("Root", v(0.75, 0.12, 0.75), cf(hx, hy - 0.32, hz), CHAR)
		B:block("Root", v(0.1, 0.55, 0.1), cf(hx + 0.32, hy, hz + 0.32), CHAR)
		B:block("Root", v(0.1, 0.55, 0.1), cf(hx - 0.32, hy, hz + 0.32), CHAR)
		B:block("Root", v(0.1, 0.55, 0.1), cf(hx + 0.32, hy, hz - 0.32), CHAR)
		B:block("Root", v(0.1, 0.55, 0.1), cf(hx - 0.32, hy, hz - 0.32), CHAR)
		B:block("Root", v(0.74, 0.1, 0.74), cf(hx, hy + 0.1, hz), CHAR)
		B:block("Root", v(0.48, 1.0, 0.48), cf(hx, hy + 0.25, hz), RED)
		B:block("Root", v(0.5, 0.2, 0.5), cf(hx, hy + 0.35, hz), WHITE)
		B:block("Root", v(0.3, 0.2, 0.3), cf(hx, hy + 0.85, hz), WHITE)
		B:block("Root", v(0.14, 0.14, 0.14), cf(hx, hy + 1.0, hz), RED)

		-- sport towel draped over the left handrail
		local tz = -1.75
		B:block("Root", v(0.1, 1.0, 0.95), cf(-2.84, 4.45, tz), WHITE)
		B:block("Root", v(0.1, 0.8, 0.95), cf(-2.06, 4.55, tz), WHITE)
		B:block("Root", v(0.88, 0.1, 0.95), cf(-2.45, 5.2, tz), WHITE)
		B:block("Root", v(0.11, 0.16, 0.97), cf(-2.84, 4.05, tz), RED)
		B:block("Root", v(0.11, 0.16, 0.97), cf(-2.06, 4.25, tz), RED)
	end,
}
