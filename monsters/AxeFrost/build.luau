-- Frostbite Axe (#7): a huge icy blue blade with snow on its steps and stepped
-- icicles hanging off it, set in a navy steel socket with a snowflake emblem, on a
-- frost-crusted haft. Snow sparkles and cold mist drift off the blade.
-- Built standing up: haft along +Y (pommel at Y=0), blade facing +X. Static: no motion.
return {
	DisplayName = "Frostbite Axe",
	Rarity = "Cosmic",
	Element = "Tool",
	Tool = { Name = "Frostbite Axe", ToolTip = "Frostbite Axe", GripY = -1.52 },
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local HAFT, HAFT_D = "#36588c", "#25406c"
		local FROST, FROST_B = "#f2fbff", "#c4e9fd"
		local WRAP, WRAP_D = "#1b2b55", "#121e40"
		local FUR = "#f4fbff"
		local NAVY, NAVY_D, SILVER = "#2b4374", "#1a2a4f", "#c9d6e6"
		local ICE_DD, ICE_D, ICE, ICE_L, EDGE = "#1c58c2", "#2a7fe6", "#45a6f7", "#7fd0ff", "#bdeeff"
		local GLOW = "#8ff6ff"

		-- stepped icicle: tapering blocks stacked from (x, y) along a direction
		-- `deg` degrees from +Y (positive leans toward +X; 180 hangs straight down)
		local function icicle(x, y, deg, segs, z)
			local r = math.rad(deg)
			local dx, dy = math.sin(r), math.cos(r)
			local t = 0
			for _, s in segs do
				local len, w, col = s[1], s[2], s[3]
				local c = t + len / 2
				B:block("Root", v(w, len, s[4] or w), cf(x + dx * c, y + dy * c, z or 0, 0, 0, -deg), col)
				t += len - 0.04
			end
		end

		-- haft (the Handle)
		B:block("Root", v(0.42, 5.4, 0.42), cf(0, 3.1, 0), HAFT, { name = "Handle" })
		B:block("Root", v(0.08, 1.0, 0.06), cf(0.08, 3.1, 0.22), HAFT_D)
		B:block("Root", v(0.08, 0.7, 0.06), cf(-0.08, 3.3, -0.22), HAFT_D)
		-- frost crust creeping down the haft from the socket
		B:block("Root", v(0.48, 0.42, 0.48), cf(0, 3.66, 0), FROST)
		B:block("Root", v(0.46, 0.22, 0.46), cf(0.02, 3.34, 0), FROST_B)
		B:block("Root", v(0.14, 0.5, 0.47), cf(-0.17, 3.12, 0.01), FROST)
		B:block("Root", v(0.47, 0.18, 0.14), cf(0.01, 2.9, 0.17), FROST_B)

		-- pommel: silver collar and a big stepped ice crystal hanging under it
		B:block("Root", v(0.62, 0.22, 0.62), cf(0, 0.58, 0), NAVY_D)
		B:block("Root", v(0.68, 0.1, 0.68), cf(0, 0.72, 0), SILVER)
		icicle(0, 0.42, 180, { { 0.16, 0.5, ICE_D }, { 0.14, 0.38, ICE }, { 0.12, 0.26, ICE_L }, { 0.12, 0.14, EDGE } })

		-- dark blue grip with white fur cuffs and icy bands
		B:block("Root", v(0.48, 1.5, 0.48), cf(0, 1.58, 0), WRAP)
		for _, y in { 1.14, 1.58, 2.02 } do
			B:block("Root", v(0.54, 0.12, 0.54), cf(0, y, 0), WRAP_D)
		end
		B:block("Root", v(0.66, 0.26, 0.66), cf(0, 0.88, 0), FUR)
		B:block("Root", v(0.68, 0.3, 0.68), cf(0, 2.42, 0), FUR)
		B:block("Root", v(0.56, 0.1, 0.56), cf(0, 2.62, 0), SILVER)

		-- navy steel socket with silver trim
		B:block("Root", v(0.78, 1.8, 0.62), cf(0, 4.7, 0), NAVY)
		B:block("Root", v(0.84, 0.14, 0.68), cf(0, 3.84, 0), SILVER)
		B:block("Root", v(0.84, 0.14, 0.68), cf(0, 5.56, 0), SILVER)
		B:block("Root", v(0.52, 0.2, 0.52), cf(0, 5.72, 0), NAVY_D)
		-- ice crystal cap on top of the haft
		icicle(0, 5.76, 0, { { 0.2, 0.48, ICE_D }, { 0.18, 0.34, ICE }, { 0.16, 0.2, ICE_L }, { 0.14, 0.1, EDGE } })
		-- snowflake emblem on both socket faces (glowing heart)
		for _, s in { 1, -1 } do
			local z = s * 0.33
			B:block("Root", v(0.08, 0.6, 0.04), cf(0, 4.75, z), FROST)
			B:block("Root", v(0.6, 0.08, 0.04), cf(0, 4.75, z), FROST)
			B:block("Root", v(0.07, 0.5, 0.03), cf(0, 4.75, z + s * 0.01, 0, 0, 45), FROST_B)
			B:block("Root", v(0.07, 0.5, 0.03), cf(0, 4.75, z + s * 0.01, 0, 0, -45), FROST_B)
			B:gem("Root", v(0.16, 0.16, 0.06), cf(0, 4.75, z + s * 0.02), GLOW)
			-- little icicles dripping off the socket rim
			icicle(-0.24, 3.8, 180, { { 0.14, 0.14, ICE_L }, { 0.12, 0.08, EDGE } }, s * 0.26)
			icicle(0.22, 3.8, 180, { { 0.18, 0.14, ICE_L }, { 0.14, 0.08, EDGE } }, s * 0.26)
		end

		-- back poll: navy block with a long stepped ice spike
		B:block("Root", v(0.36, 0.8, 0.54), cf(-0.52, 4.7, 0), NAVY)
		B:block("Root", v(0.1, 0.9, 0.58), cf(-0.38, 4.7, 0), SILVER)
		icicle(-0.66, 4.72, -84, {
			{ 0.18, 0.64, ICE_D, 0.46 }, { 0.16, 0.46, ICE, 0.38 }, { 0.14, 0.28, ICE_L, 0.28 }, { 0.12, 0.14, EDGE, 0.2 },
		})

		-- the big ice blade: columns step out and grow taller toward a pale edge
		local cols = {
			{ 0.62, 0.5, 1.4, 0.52, ICE_DD },
			{ 1.06, 0.44, 2.0, 0.48, ICE_D },
			{ 1.48, 0.44, 2.6, 0.44, ICE },
			{ 1.88, 0.42, 3.1, 0.4, ICE },
			{ 2.24, 0.36, 3.45, 0.36, ICE_L },
		}
		local blade = {}
		for i, c in cols do
			blade[i] = B:block("Root", v(c[2] + 0.02, c[3], c[4]), cf(c[1], 4.7, 0), c[5])
			-- snow lying on each step
			B:block("Root", v(c[2] + 0.04, 0.14, c[4] + 0.06), cf(c[1], 4.7 + c[3] / 2 + 0.03, 0), FROST)
		end
		B:block("Root", v(0.22, 3.7, 0.3), cf(2.5, 4.7, 0), EDGE) -- cutting edge

		-- curling icicle horns off the top and bottom of the edge
		icicle(2.46, 6.46, 30, { { 0.24, 0.34, ICE_L }, { 0.2, 0.24, EDGE }, { 0.18, 0.14, EDGE } })
		icicle(2.46, 2.94, 148, { { 0.24, 0.34, ICE_L }, { 0.22, 0.24, EDGE }, { 0.2, 0.14, EDGE }, { 0.16, 0.08, EDGE } })
		-- icicles hanging from the underside of the blade steps
		icicle(1.06, 3.74, 180, { { 0.16, 0.3, ICE }, { 0.14, 0.2, ICE_L }, { 0.12, 0.1, EDGE } })
		icicle(1.48, 3.44, 180, { { 0.2, 0.32, ICE }, { 0.18, 0.22, ICE_L }, { 0.16, 0.12, EDGE } })
		icicle(1.88, 3.19, 180, { { 0.16, 0.3, ICE_L }, { 0.14, 0.18, EDGE } })

		-- blade faces: pale ice facets, a frost snowflake and a glowing crack inside the edge
		for _, s in { 1, -1 } do
			local function z(t) return s * (t / 2 + 0.02) end
			B:block("Root", v(0.3, 0.7, 0.04), cf(1.48, 5.55, z(0.44)), ICE_L)
			B:block("Root", v(0.28, 0.8, 0.04), cf(1.88, 3.95, z(0.4)), ICE_L)
			B:block("Root", v(0.36, 0.6, 0.04), cf(1.06, 4.15, z(0.48)), ICE)
			B:block("Root", v(0.3, 0.5, 0.04), cf(0.66, 5.0, z(0.52)), ICE_D)
			-- snowflake on the blade (white arms, glowing heart)
			local fz = z(0.44) + s * 0.01
			B:block("Root", v(0.07, 0.72, 0.04), cf(1.68, 4.8, fz), FROST)
			B:block("Root", v(0.72, 0.07, 0.04), cf(1.68, 4.8, fz), FROST)
			B:block("Root", v(0.06, 0.58, 0.03), cf(1.68, 4.8, fz + s * 0.01, 0, 0, 45), FROST_B)
			B:block("Root", v(0.06, 0.58, 0.03), cf(1.68, 4.8, fz + s * 0.01, 0, 0, -45), FROST_B)
			B:block("Root", v(0.14, 0.14, 0.04), cf(1.68, 4.8, fz + s * 0.02), GLOW, { mat = "Neon" })
			B:block("Root", v(0.06, 2.9, 0.04), cf(2.36, 4.7, z(0.36)), GLOW, { mat = "Neon" })
			B:block("Root", v(0.36, 0.06, 0.04), cf(2.04, 6.1, z(0.4)), GLOW, { mat = "Neon" })
			B:block("Root", v(0.36, 0.06, 0.04), cf(2.04, 3.3, z(0.4)), GLOW, { mat = "Neon" })
		end

		-- snow sparkle + a little sinking cold mist, soft icy light
		local fx = blade[4]
		B:emitter(fx, "sparkle", { color = { "#ffffff", "#9fe9ff" }, rate = 10, size = { 0.08, 0.3, 0 }, name = "Snow" })
		B:emitter(fx, "smoke", { color = "#dff6ff", rate = 2, size = { 0.4, 1.0, 1.4 }, speed = { 0.2, 0.5 },
			accel = { 0, -0.6, 0 }, trans = { 0.8, 0.85, 1 }, name = "ColdMist" })
		B:light(fx, { color = "#9fe9ff", brightness = 0.8, range = 7, name = "FrostLight" })
	end,
}
