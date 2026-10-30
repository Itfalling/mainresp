-- Crystal Axe: an amethyst / ice crystal blade growing out of a silver
-- socket, with glowing facet lines. Built standing up: haft along +Y (pommel
-- at Y=0), blade facing +X. Static prop: no motion.luau.
return {
	DisplayName = "Crystal Axe",
	Rarity = "Mythic",
	Element = "Tool",
	Tool = { Name = "Crystal Axe", ToolTip = "Crystal Axe", GripY = -1.25 },
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local HAFT, HAFT_L = "#2f2752", "#463a72"
		local WRAP, WRAP_D = "#6a44a8", "#4a2d7c"
		local SIL, SIL_D, SIL_L = "#c3cad6", "#8b94a6", "#eef1f6"
		local AM_D, AM, AM_M, AM_L = "#5e2f9e", "#7d45c9", "#9a66e0", "#b58cf0"
		local ICE, ICE_L = "#7fd6ff", "#a9eaff"
		local GLOW, GLOW_ICE = "#f0b8ff", "#aef0ff"
		local CY = 4.35 -- head centre height

		-- a crystal prism from a to b: w = width in the blade plane, t = thickness (Z)
		local function shard(a, b, w, t, col, opts)
			return B:bar("Root", a, b, t, w, col, opts)
		end

		-- haft (the Handle): pommel up through the socket
		B:block("Root", v(0.42, 4.6, 0.42), cf(0, 2.75, 0), HAFT, { name = "Handle" })
		for _, s in { 1, -1 } do
			-- amethyst inlay strips up the haft, front and back
			B:block("Root", v(0.1, 1.0, 0.04), cf(0, 3.08, s * 0.22), AM_D)
			B:block("Root", v(0.04, 1.0, 0.1), cf(s * 0.22, 3.08, 0), HAFT_L)
		end

		-- pommel: silver cap holding a little amethyst cube
		B:block("Root", v(0.4, 0.3, 0.4), cf(0, 0.15, 0), AM)
		B:block("Root", v(0.6, 0.22, 0.6), cf(0, 0.4, 0), SIL)
		B:block("Root", v(0.5, 0.12, 0.5), cf(0, 0.57, 0), SIL_D)
		B:gem("Root", v(0.14, 0.14, 0.04), cf(0, 0.15, -0.21), GLOW)

		-- grip wrap with darker bands, silver ferrule on top
		B:block("Root", v(0.5, 1.6, 0.5), cf(0, 1.5, 0), WRAP)
		for _, y in { 0.76, 1.24, 1.76, 2.24 } do
			B:block("Root", v(0.54, 0.12, 0.54), cf(0, y, 0), WRAP_D)
		end
		B:block("Root", v(0.56, 0.16, 0.56), cf(0, 2.36, 0), SIL)
		-- little lavender diamonds woven into the wrap
		for _, y in { 1.0, 1.5, 2.0 } do
			for _, s in { 1, -1 } do
				B:block("Root", v(0.16, 0.16, 0.04), cf(0, y, s * 0.26), AM_L)
			end
		end
		-- silver ring with a tiny crystal partway up the haft
		B:block("Root", v(0.5, 0.14, 0.5), cf(0, 3.12, 0), SIL_D)
		B:block("Root", v(0.16, 0.2, 0.08), cf(0, 3.12, -0.27), AM_L)

		-- silver socket round the top of the haft, stepped collars
		B:block("Root", v(0.8, 1.5, 0.66), cf(0, CY, 0), SIL)
		B:block("Root", v(0.9, 0.18, 0.74), cf(0, CY - 0.75, 0), SIL_D)
		B:block("Root", v(0.9, 0.18, 0.74), cf(0, CY + 0.75, 0), SIL_D)
		for _, z in { 0.34, -0.34 } do
			B:block("Root", v(0.44, 0.44, 0.06), cf(0, CY, z), SIL_L)
			B:block("Root", v(0.24, 0.24, 0.06), cf(0, CY, z * 1.18), AM)
		end

		-- crystal crown growing out of the top of the socket
		B:block("Root", v(0.44, 0.4, 0.4), cf(0, CY + 1.02, 0), AM)
		B:block("Root", v(0.3, 0.36, 0.28), cf(0, CY + 1.38, 0), AM_L)
		B:block("Root", v(0.16, 0.22, 0.16), cf(0, CY + 1.66, 0), ICE)
		shard(v(-0.05, CY + 0.95, 0), v(-0.42, CY + 1.4, 0), 0.24, 0.24, AM_M)

		-- back: silver poll with a fanned cluster of crystal spurs
		B:block("Root", v(0.36, 0.9, 0.56), cf(-0.5, CY, 0), SIL_D)
		shard(v(-0.55, CY + 0.05, 0), v(-1.12, CY + 0.05, 0.001), 0.46, 0.4, AM)
		shard(v(-1.0, CY + 0.05, 0), v(-1.24, CY + 0.05, 0.001), 0.26, 0.26, ICE)
		shard(v(-0.5, CY + 0.25, 0), v(-0.98, CY + 0.78, 0), 0.3, 0.3, AM_M)
		shard(v(-0.9, CY + 0.68, 0), v(-1.06, CY + 0.88, 0), 0.18, 0.2, ICE_L)
		shard(v(-0.5, CY - 0.25, 0), v(-0.9, CY - 0.7, 0), 0.26, 0.28, AM_D)
		shard(v(-0.82, CY - 0.6, 0), v(-0.96, CY - 0.78, 0), 0.16, 0.18, AM_L)

		-- silver setting + claws gripping the crystal
		B:block("Root", v(0.4, 1.1, 0.58), cf(0.54, CY, 0), SIL_D)
		B:block("Root", v(0.36, 0.2, 0.6), cf(0.86, CY + 0.6, 0), SIL)
		B:block("Root", v(0.36, 0.2, 0.6), cf(0.86, CY - 0.6, 0), SIL)
		B:block("Root", v(0.14, 0.14, 0.62), cf(1.02, CY + 0.47, 0), SIL_L)
		B:block("Root", v(0.14, 0.14, 0.62), cf(1.02, CY - 0.47, 0), SIL_L)

		-- crystal blade: stepped columns flaring into a crescent
		B:block("Root", v(0.48, 1.2, 0.46), cf(0.92, CY, 0), AM_D)
		B:block("Root", v(0.48, 1.7, 0.42), cf(1.34, CY, 0), AM)
		B:block("Root", v(0.46, 2.3, 0.38), cf(1.76, CY, 0), AM_M)
		B:block("Root", v(0.34, 2.7, 0.34), cf(2.14, CY, 0), AM_L)
		B:block("Root", v(0.22, 2.9, 0.28), cf(2.38, CY, 0), ICE)

		-- big corner shards: the top horn and the beard grow out at angles
		shard(v(1.5, CY + 0.6, 0), v(2.42, CY + 1.9, 0), 0.62, 0.36, AM_M)
		shard(v(2.2, CY + 1.62, 0), v(2.56, CY + 2.14, 0), 0.36, 0.28, ICE)
		shard(v(1.5, CY - 0.6, 0), v(2.36, CY - 1.85, 0), 0.62, 0.36, AM_M)
		shard(v(2.16, CY - 1.58, 0), v(2.5, CY - 2.08, 0), 0.36, 0.28, ICE)
		-- small shards poking out of the cutting edge
		B:block("Root", v(0.16, 0.9, 0.24), cf(2.54, CY + 0.25, 0), ICE)
		-- a cluster sprouting from the socket on each face
		for _, s in { 1, -1 } do
			B:bar("Root", v(0.6, CY + 0.15, s * 0.25), v(0.9, CY + 0.5, s * 0.48), 0.2, 0.2, AM_M)
			B:bar("Root", v(0.62, CY - 0.2, s * 0.25), v(0.84, CY - 0.45, s * 0.42), 0.16, 0.16, AM_L)
		end

		-- facet highlights + glowing facet lines on both faces
		for _, s in { 1, -1 } do
			B:bar("Root", v(1.2, CY + 0.2, s * 0.21), v(1.86, CY + 0.95, s * 0.21), 0.04, 0.14, AM_L)
			B:bar("Root", v(1.2, CY - 0.2, s * 0.21), v(1.86, CY - 0.95, s * 0.21), 0.04, 0.14, AM_L)
			shard(v(1.58, CY + 0.78, s * 0.19), v(2.38, CY + 1.82, s * 0.19), 0.24, 0.03, AM_L)
			shard(v(1.58, CY - 0.78, s * 0.19), v(2.32, CY - 1.76, s * 0.19), 0.24, 0.03, AM_L)
			shard(v(1.66, CY + 0.85, s * 0.21), v(2.32, CY + 1.72, s * 0.21), 0.07, 0.04, GLOW, { mat = "Neon" })
			shard(v(1.66, CY - 0.85, s * 0.21), v(2.3, CY - 1.68, s * 0.21), 0.07, 0.04, GLOW, { mat = "Neon" })
			B:gem("Root", v(0.07, 1.6, 0.04), cf(1.98, CY, s * 0.2), GLOW)
			B:gem("Root", v(0.05, 1.0, 0.04), cf(2.24, CY, s * 0.18), GLOW_ICE)
		end
		-- glowing crystal tips
		local tipTop = B:gem("Root", v(0.14, 0.14, 0.14), cf(2.58, CY + 2.18, 0), GLOW_ICE)
		B:gem("Root", v(0.14, 0.14, 0.14), cf(2.52, CY - 2.12, 0), GLOW_ICE)
		B:gem("Root", v(0.12, 0.12, 0.12), cf(0, CY + 1.8, 0), GLOW_ICE)

		-- effects: twinkles off the blade, a soft violet glow
		local core = B:block("Root", v(0.3, 1.0, 0.3), cf(1.9, CY, 0), AM_M, { tr = 1, name = "SparkleCore" })
		B:emitter(core, "sparkle", { color = { GLOW, GLOW_ICE }, rate = 7, spread = 180, name = "CrystalSparkle" })
		B:emitter(tipTop, "glow", { color = GLOW, rate = 1.2, size = { 0.6, 1.2, 0.3 }, name = "TipGlow" })
		B:light(core, { color = GLOW, brightness = 0.7, range = 7, name = "CrystalLight" })
	end,
}
