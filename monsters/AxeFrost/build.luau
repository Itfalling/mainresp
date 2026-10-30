-- Frostbite Axe (#7): a huge icy blue blade bristling with stepped icicle spikes,
-- set in a steel socket on a frost-crusted haft, with snow sparkles drifting off it.
-- Built standing up: haft along +Y (pommel at Y=0), blade facing +X. Static: no motion.
return {
	DisplayName = "Frostbite Axe",
	Rarity = "Cosmic",
	Element = "Tool",
	Tool = { Name = "Frostbite Axe", ToolTip = "Frostbite Axe", GripY = -1.65 },
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local HAFT, HAFT_D = "#3d5f8f", "#2b4670"
		local FROST, FROST_B = "#eef9ff", "#bfe6fb"
		local WRAP, WRAP_D = "#1e2f5c", "#152246"
		local FUR = "#f4fbff"
		local STEEL, STEEL_D = "#9fb4cc", "#4d6385"
		local ICE_DD, ICE_D, ICE, ICE_L, EDGE = "#1c58c2", "#2a7fe6", "#45a6f7", "#7fd0ff", "#c4efff"
		local GLOW = "#8ff6ff"

		-- stepped icicle: tapering blocks stacked from (x, y) along a direction
		-- `deg` degrees from +Y (positive leans toward +X)
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
		B:block("Root", v(0.4, 5.4, 0.4), cf(0, 3.1, 0), HAFT, { name = "Handle" })
		B:block("Root", v(0.08, 1.3, 0.06), cf(0.07, 3.25, 0.21), HAFT_D)
		B:block("Root", v(0.08, 0.9, 0.06), cf(-0.07, 3.45, -0.21), HAFT_D)
		-- frost crust patches creeping down the haft
		B:block("Root", v(0.46, 0.36, 0.46), cf(0, 3.62, 0), FROST_B)
		B:block("Root", v(0.44, 0.2, 0.44), cf(0.02, 3.3, 0), FROST)
		B:block("Root", v(0.12, 0.5, 0.46), cf(0.17, 3.0, 0.02), FROST)
		B:block("Root", v(0.46, 0.14, 0.12), cf(0, 2.86, -0.17), FROST_B)
		B:block("Root", v(0.46, 0.5, 0.46), cf(0, 3.92, 0), FROST)

		-- pommel: steel cap with an icicle hanging under it
		B:block("Root", v(0.58, 0.24, 0.58), cf(0, 0.5, 0), STEEL_D)
		B:block("Root", v(0.5, 0.1, 0.5), cf(0, 0.67, 0), STEEL)
		icicle(0, 0.42, 180, { { 0.18, 0.44, ICE_D }, { 0.16, 0.3, ICE }, { 0.14, 0.16, ICE_L } })

		-- dark blue grip with white fur cuffs and icy bands
		B:block("Root", v(0.48, 1.6, 0.48), cf(0, 1.55, 0), WRAP)
		for _, y in { 1.08, 1.55, 2.02 } do
			B:block("Root", v(0.54, 0.12, 0.54), cf(0, y, 0), WRAP_D)
		end
		B:block("Root", v(0.66, 0.28, 0.66), cf(0, 0.8, 0), FUR)
		B:block("Root", v(0.66, 0.3, 0.66), cf(0, 2.42, 0), FUR)
		B:block("Root", v(0.54, 0.12, 0.54), cf(0, 2.6, 0), FROST_B)

		-- steel socket clamped round the haft, ice cap crystal on top
		B:block("Root", v(0.74, 1.7, 0.6), cf(0, 4.7, 0), STEEL)
		B:block("Root", v(0.8, 0.16, 0.66), cf(0, 3.9, 0), STEEL_D)
		B:block("Root", v(0.8, 0.16, 0.66), cf(0, 5.5, 0), STEEL_D)
		B:block("Root", v(0.5, 0.2, 0.5), cf(0, 5.66, 0), STEEL_D)
		icicle(0, 5.7, 0, { { 0.22, 0.46, ICE_D }, { 0.2, 0.32, ICE }, { 0.18, 0.18, ICE_L } })
		-- glowing frost gem on both socket faces
		for _, z in { 0.31, -0.31 } do
			B:block("Root", v(0.36, 0.36, 0.06), cf(0, 4.7, z), STEEL_D)
			B:gem("Root", v(0.2, 0.2, 0.06), cf(0, 4.7, z * 1.13), GLOW)
		end

		-- back poll: a steel block with a sideways icicle spike
		B:block("Root", v(0.4, 0.8, 0.52), cf(-0.52, 4.7, 0), STEEL)
		B:block("Root", v(0.12, 0.9, 0.56), cf(-0.36, 4.7, 0), STEEL_D)
		icicle(-0.68, 4.7, -90, {
			{ 0.24, 0.58, ICE_D, 0.44 }, { 0.22, 0.4, ICE, 0.34 }, { 0.2, 0.22, ICE_L, 0.24 },
		})

		-- the big ice blade: columns step out and grow taller toward a white edge
		local cols = {
			{ 0.6, 0.5, 1.2, 4.72, 0.5, ICE_DD },
			{ 1.02, 0.42, 1.7, 4.7, 0.46, ICE_D },
			{ 1.4, 0.4, 2.2, 4.68, 0.42, ICE },
			{ 1.76, 0.36, 2.6, 4.66, 0.38, ICE },
			{ 2.08, 0.32, 2.9, 4.65, 0.34, ICE_L },
		}
		local blade = {}
		for i, c in cols do
			blade[i] = B:block("Root", v(c[2] + 0.02, c[3], c[5]), cf(c[1], c[4], 0), c[6])
		end
		B:block("Root", v(0.2, 3.1, 0.28), cf(2.32, 4.65, 0), EDGE) -- cutting edge

		-- icicle spikes: up off the top horn and crest, hanging off the beard and belly
		icicle(2.22, 6.1, 24, { { 0.26, 0.34, ICE }, { 0.24, 0.24, ICE_L }, { 0.22, 0.16, EDGE }, { 0.16, 0.08, EDGE } })
		icicle(2.22, 3.2, 156, { { 0.28, 0.34, ICE }, { 0.26, 0.24, ICE_L }, { 0.22, 0.16, EDGE }, { 0.16, 0.08, EDGE } })
		icicle(1.76, 5.9, 8, { { 0.2, 0.26, ICE }, { 0.18, 0.16, ICE_L } })
		icicle(1.4, 5.72, 0, { { 0.16, 0.22, ICE }, { 0.14, 0.12, ICE_L } })
		icicle(1.76, 3.42, 180, { { 0.22, 0.26, ICE }, { 0.2, 0.16, ICE_L }, { 0.16, 0.08, EDGE } })
		icicle(1.4, 3.64, 180, { { 0.18, 0.22, ICE }, { 0.14, 0.12, ICE_L } })

		-- blade faces: pale facets, frost patches and a glowing crack inside the edge
		for _, s in { 1, -1 } do
			local function z(t) return s * (t / 2 + 0.02) end
			B:block("Root", v(0.34, 1.1, 0.04), cf(1.4, 5.0, z(0.42)), ICE_L)
			B:block("Root", v(0.3, 1.6, 0.04), cf(1.76, 4.9, z(0.38)), ICE_L)
			B:block("Root", v(0.36, 0.5, 0.04), cf(1.02, 4.3, z(0.46)), ICE)
			B:block("Root", v(0.26, 0.14, 0.04), cf(0.62, 5.2, z(0.5)), FROST)
			B:block("Root", v(0.4, 0.14, 0.04), cf(0.85, 4.0, z(0.5)), FROST_B)
			B:block("Root", v(0.14, 0.36, 0.04), cf(1.05, 5.25, z(0.46)), FROST)
			B:block("Root", v(0.06, 2.3, 0.04), cf(2.16, 4.65, z(0.34)), GLOW, { mat = "Neon" })
			B:block("Root", v(0.4, 0.06, 0.04), cf(1.9, 5.7, z(0.38)), GLOW, { mat = "Neon" })
			B:block("Root", v(0.4, 0.06, 0.04), cf(1.9, 3.6, z(0.38)), GLOW, { mat = "Neon" })
		end

		-- snow sparkle + a little cold mist, soft icy light
		local fx = blade[4]
		B:emitter(fx, "sparkle", { color = { "#ffffff", "#9fe9ff" }, rate = 9, size = { 0.08, 0.3, 0 }, name = "Snow" })
		B:emitter(fx, "smoke", { color = "#dff6ff", rate = 2, size = { 0.4, 1.0, 1.4 }, speed = { 0.2, 0.5 },
			accel = { 0, -0.6, 0 }, trans = { 0.8, 0.85, 1 }, name = "ColdMist" })
		B:light(fx, { color = "#9fe9ff", brightness = 0.8, range = 7, name = "FrostLight" })
	end,
}
