-- Magma Axe: a jagged obsidian head split by glowing lava cracks, with a
-- molten orange edge, lava drips, smouldering embers and smoke. Built standing
-- up: haft along +Y (pommel at Y=0), blade facing +X. Static: no motion.luau.
return {
	DisplayName = "Magma Axe",
	Rarity = "Secret",
	Element = "Tool",
	Tool = { Name = "Magma Axe", ToolTip = "Magma Axe", GripY = -1.65 },
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local OB_D, OB, OB_M, OB_L = "#17141c", "#2b2433", "#41374d", "#62566f"
		local BASALT, BASALT_L = "#2b2420", "#463a33"
		local GRIP, GRIP_D = "#7a2416", "#4e150c"
		local IRON, IRON_D = "#5a5560", "#3a363f"
		local RIM, HOT_D, HOT, HOT_L = "#b8320c", "#d4480f", "#ff8a1f", "#ffc35a"
		local LAVA, LAVA_Y = "#ff5a00", "#ffb81f" -- neon
		local CY = 4.7 -- head centre height

		-- slab from a to b in the blade plane: w = width in plane, t = thickness (Z)
		local function slab(a, b, w, t, col, opts)
			return B:bar("Root", a, b, t, w, col, opts)
		end
		-- a lava crack on both faces at depth z: dark-red hot rim + thin neon core
		local function crack(a, b, z, w)
			w = w or 0.16
			for _, s in { 1, -1 } do
				B:bar("Root", v(a.X, a.Y, s * z), v(b.X, b.Y, s * z), 0.04, w, RIM)
				B:bar("Root", v(a.X, a.Y, s * (z + 0.03)), v(b.X, b.Y, s * (z + 0.03)), 0.03, w * 0.4, LAVA, { mat = "Neon" })
			end
		end

		-- haft (the Handle): charred basalt from the pommel up through the head
		B:block("Root", v(0.44, 5.2, 0.44), cf(0, 3.05, 0), BASALT, { name = "Handle" })
		B:block("Root", v(0.08, 1.0, 0.06), cf(-0.1, 3.4, 0.23), BASALT_L)
		B:block("Root", v(0.08, 0.8, 0.06), cf(0.09, 3.3, -0.23), BASALT_L)
		-- a glowing seam zig-zagging up the haft
		crack(v(-0.06, 2.45, 0), v(0.06, 3.0, 0), 0.22, 0.12)
		crack(v(0.06, 3.0, 0), v(-0.05, 3.55, 0), 0.22, 0.12)
		-- iron band with a hot rivet below the socket
		B:block("Root", v(0.52, 0.16, 0.52), cf(0, 3.7, 0), IRON)
		B:block("Root", v(0.14, 0.12, 0.06), cf(0, 3.7, -0.27), HOT)

		-- pommel: stepped obsidian chunk with a molten core
		B:block("Root", v(0.64, 0.34, 0.64), cf(0, 0.17, 0), OB)
		B:block("Root", v(0.68, 0.1, 0.68), cf(0, 0.2, 0), RIM)
		B:block("Root", v(0.52, 0.16, 0.52), cf(0, 0.42, 0), IRON_D)
		B:gem("Root", v(0.7, 0.04, 0.24), cf(0, 0.2, 0), LAVA)

		-- dark red leather grip, charred bands
		B:block("Root", v(0.5, 1.6, 0.5), cf(0, 1.4, 0), GRIP)
		for _, y in { 0.72, 1.12, 1.52, 1.92 } do
			B:block("Root", v(0.54, 0.1, 0.54), cf(0, y, 0), GRIP_D)
		end
		B:block("Root", v(0.58, 0.16, 0.58), cf(0, 2.26, 0), IRON)

		-- socket: blackened iron block with obsidian collars and a molten eye
		B:block("Root", v(0.84, 1.6, 0.7), cf(0, CY, 0), IRON_D)
		B:block("Root", v(0.94, 0.2, 0.78), cf(0, CY - 0.82, 0), OB)
		B:block("Root", v(0.94, 0.2, 0.78), cf(0, CY + 0.82, 0), OB)
		for _, s in { 1, -1 } do
			B:block("Root", v(0.46, 0.46, 0.06), cf(0, CY, s * 0.37), OB_M)
			B:block("Root", v(0.28, 0.28, 0.06), cf(0, CY, s * 0.41), HOT_D)
			B:gem("Root", v(0.12, 0.12, 0.04), cf(0, CY, s * 0.45), LAVA_Y)
		end
		-- top spike: stepped obsidian with a molten tip
		B:block("Root", v(0.52, 0.36, 0.52), cf(0, CY + 1.08, 0), OB)
		B:block("Root", v(0.36, 0.34, 0.36), cf(0, CY + 1.42, 0), OB_M)
		B:block("Root", v(0.22, 0.26, 0.22), cf(0, CY + 1.7, 0), HOT_D)
		local tip = B:gem("Root", v(0.1, 0.14, 0.1), cf(0, CY + 1.88, 0), LAVA_Y)

		-- back spike: stepped obsidian pointing back, molten tip
		B:block("Root", v(0.4, 0.9, 0.6), cf(-0.58, CY, 0), OB)
		B:block("Root", v(0.34, 0.6, 0.48), cf(-0.92, CY + 0.05, 0), OB_M)
		B:block("Root", v(0.26, 0.34, 0.36), cf(-1.15, CY + 0.12, 0), OB_L)
		B:block("Root", v(0.1, 0.18, 0.22), cf(-1.3, CY + 0.15, 0), HOT_D)
		crack(v(-0.45, CY - 0.2, 0), v(-0.95, CY + 0.12, 0), 0.31, 0.14)

		-- obsidian blade: stepped columns flaring into a big bearded crescent
		B:block("Root", v(0.5, 1.3, 0.56), cf(0.6, CY, 0), OB)
		B:block("Root", v(0.48, 1.8, 0.5), cf(1.02, CY - 0.05, 0), OB_M)
		B:block("Root", v(0.46, 2.5, 0.46), cf(1.44, CY - 0.15, 0), OB)
		B:block("Root", v(0.42, 3.2, 0.42), cf(1.86, CY - 0.2, 0), OB_M)
		-- horn sweeping up and the beard hooking down
		slab(v(1.45, CY + 0.7, 0), v(2.25, CY + 1.8, 0), 0.62, 0.42, OB)
		slab(v(1.4, CY - 1.0, 0), v(2.1, CY - 2.55, 0), 0.62, 0.42, OB)
		-- jagged obsidian teeth along the top of the horn
		slab(v(1.52, CY + 1.0, 0), v(1.38, CY + 1.55, 0), 0.24, 0.3, OB_L)
		slab(v(1.88, CY + 1.42, 0), v(1.78, CY + 1.98, 0), 0.24, 0.3, OB_L)
		-- and jagged teeth hooking under the beard
		slab(v(1.5, CY - 1.55, 0), v(1.3, CY - 2.0, 0), 0.24, 0.3, OB_L)
		slab(v(1.12, CY - 0.7, 0), v(0.95, CY - 1.1, 0), 0.22, 0.3, OB_M)
		-- lighter obsidian facets on both faces
		for _, s in { 1, -1 } do
			B:block("Root", v(0.3, 0.5, 0.04), cf(1.02, CY + 0.55, s * 0.26), OB_L)
			B:block("Root", v(0.28, 0.7, 0.04), cf(1.86, CY - 1.1, s * 0.22), OB_L)
			B:block("Root", v(0.3, 0.36, 0.04), cf(1.44, CY - 0.6, s * 0.24), OB_D)
		end

		-- molten edge: hot orange plastic stepping out to a neon cutting line
		B:block("Root", v(0.26, 3.4, 0.36), cf(2.2, CY - 0.2, 0), HOT_D)
		B:block("Root", v(0.18, 3.1, 0.3), cf(2.4, CY - 0.2, 0), HOT)
		slab(v(2.08, CY + 1.5, 0), v(2.42, CY + 2.05, 0), 0.34, 0.32, HOT)
		slab(v(1.96, CY - 2.25, 0), v(2.2, CY - 2.85, 0), 0.34, 0.32, HOT)
		B:block("Root", v(0.08, 2.8, 0.24), cf(2.5, CY - 0.2, 0), HOT_L)
		B:gem("Root", v(0.05, 2.4, 0.1), cf(2.55, CY - 0.2, 0), LAVA_Y)

		-- lava cracks zig-zagging through the obsidian on both faces
		crack(v(0.42, CY + 0.25, 0), v(0.95, CY - 0.15, 0), 0.29)
		crack(v(0.95, CY - 0.15, 0), v(1.4, CY + 0.35, 0), 0.26)
		crack(v(1.4, CY + 0.35, 0), v(2.1, CY + 0.05, 0), 0.22)
		crack(v(1.05, CY - 0.55, 0), v(1.65, CY - 1.2, 0), 0.24)
		crack(v(1.65, CY - 1.2, 0), v(2.08, CY - 1.0, 0), 0.22)
		crack(v(1.7, CY - 1.4, 0), v(1.92, CY - 2.25, 0), 0.22)
		crack(v(1.62, CY + 0.95, 0), v(2.08, CY + 1.4, 0), 0.22)

		-- lava drips oozing off the beard
		B:block("Root", v(0.2, 0.3, 0.2), cf(1.62, CY - 2.1, 0), HOT_D)
		B:block("Root", v(0.14, 0.2, 0.14), cf(1.62, CY - 2.33, 0), HOT)
		B:gem("Root", v(0.1, 0.12, 0.1), cf(1.62, CY - 2.48, 0), LAVA_Y)
		B:block("Root", v(0.16, 0.22, 0.16), cf(-1.0, CY - 0.36, 0), HOT_D)
		B:gem("Root", v(0.1, 0.12, 0.1), cf(-1.0, CY - 0.53, 0), LAVA_Y)

		-- molten pool where the cracks meet, on both faces
		for _, s in { 1, -1 } do
			B:block("Root", v(0.42, 0.42, 0.04), cf(1.4, CY + 0.35, s * 0.25), RIM)
			B:block("Root", v(0.28, 0.28, 0.04), cf(1.4, CY + 0.35, s * 0.28), HOT)
			B:gem("Root", v(0.14, 0.14, 0.03), cf(1.4, CY + 0.35, s * 0.31), LAVA_Y)
		end

		-- effects: embers rising off the edge, fire licking the top spike, smoke
		local edge = B:block("Root", v(0.3, 2.4, 0.3), cf(2.2, CY - 0.2, 0), HOT, { tr = 1, name = "EmberCore" })
		B:emitter(edge, "ember", { color = { LAVA_Y, LAVA }, rate = 9, name = "Embers" })
		B:emitter(tip, "fire", { color = { LAVA_Y, "#ff4a10" }, rate = 10, size = { 0.45, 0.3, 0 }, speed = { 0.6, 1.4 }, name = "TipFire" })
		local top = B:block("Root", v(0.3, 0.3, 0.3), cf(0, CY + 2.1, 0), OB, { tr = 1, name = "SmokeCore" })
		B:emitter(top, "smoke", { color = { "#4a3a36", "#1c1718" }, rate = 3, size = { 0.5, 1.2, 1.8 }, name = "Smoke" })
		B:light(edge, { color = LAVA, brightness = 0.9, range = 7, name = "LavaLight" })
	end,
}
