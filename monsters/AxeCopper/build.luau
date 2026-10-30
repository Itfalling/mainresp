-- Copper Axe: a polished orange-copper bearded head with a weathered teal
-- patina edge, copper rivets, and a leather-wrapped grip. Built standing up:
-- haft along +Y (pommel at Y=0), blade facing +X. Static prop: no motion.luau.
return {
	DisplayName = "Copper Axe",
	Rarity = "Rare",
	Element = "Tool",
	Tool = { Name = "Copper Axe", ToolTip = "Copper Axe", GripY = -1.3 },
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local HAFT, HAFT_D = "#7a4a2a", "#55321c"
		local LEATHER, LEATHER_D = "#6a4128", "#41281a"
		local COPPER, COPPER_D, COPPER_L, SHINE = "#d9733a", "#a4502a", "#f09a5c", "#ffd3a6"
		local PATINA, PATINA_D = "#46c4a8", "#2a8f80"

		-- haft (the Handle)
		B:block("Root", v(0.38, 4.6, 0.38), cf(0, 2.6, 0), HAFT, { name = "Handle" })
		B:block("Root", v(0.08, 1.2, 0.06), cf(0.07, 2.7, 0.21), HAFT_D)
		B:block("Root", v(0.08, 0.9, 0.06), cf(-0.07, 2.9, -0.21), HAFT_D)

		-- copper pommel cap
		B:block("Root", v(0.58, 0.3, 0.58), cf(0, 0.17, 0), COPPER)
		B:block("Root", v(0.46, 0.1, 0.46), cf(0, 0.36, 0), COPPER_L)
		B:block("Root", v(0.62, 0.08, 0.62), cf(0, 0.12, 0), PATINA_D)

		-- leather grip, spiral wraps, copper ferrules with rivets
		B:block("Root", v(0.46, 1.5, 0.46), cf(0, 1.3, 0), LEATHER)
		for _, y in { 0.8, 1.15, 1.5, 1.85 } do
			B:block("Root", v(0.5, 0.08, 0.5), cf(0, y, 0, 0, 0, 14), LEATHER_D)
		end
		for _, y in { 0.5, 2.1 } do
			B:block("Root", v(0.54, 0.16, 0.54), cf(0, y, 0), COPPER)
			for _, z in { 0.28, -0.28 } do
				B:block("Root", v(0.12, 0.1, 0.06), cf(0, y, z), SHINE)
			end
		end

		-- copper collar halfway up the haft
		B:block("Root", v(0.5, 0.18, 0.5), cf(0, 2.85, 0), COPPER)
		B:block("Root", v(0.44, 0.08, 0.44), cf(0, 3, 0), COPPER_D)
		B:block("Root", v(0.12, 0.1, 0.06), cf(0, 2.85, 0.26), SHINE)
		B:block("Root", v(0.12, 0.1, 0.06), cf(0, 2.85, -0.26), SHINE)

		-- socket sleeve around the top of the haft
		B:block("Root", v(0.72, 1.5, 0.6), cf(0, 4.2, 0), COPPER_D)
		B:block("Root", v(0.78, 0.14, 0.66), cf(0, 3.48, 0), COPPER_L)
		B:block("Root", v(0.78, 0.14, 0.66), cf(0, 4.92, 0), COPPER_L)
		B:block("Root", v(0.5, 0.16, 0.5), cf(0, 5.04, 0), COPPER)
		B:block("Root", v(0.26, 0.12, 0.26), cf(0, 5.16, 0), PATINA)

		-- back poll: hammer face gone green with age
		B:block("Root", v(0.44, 0.84, 0.56), cf(-0.56, 4.25, 0), COPPER)
		B:block("Root", v(0.2, 0.66, 0.5), cf(-0.86, 4.25, 0), PATINA)
		B:block("Root", v(0.08, 0.66, 0.4), cf(-0.97, 4.25, 0), PATINA_D)

		-- blade: a narrow neck that fans out into a big crescent edge
		B:block("Root", v(0.5, 0.82, 0.54), cf(0.58, 4.2, 0), COPPER)
		B:block("Root", v(0.4, 0.96, 0.5), cf(1.02, 4.16, 0), COPPER)
		B:block("Root", v(0.38, 1.56, 0.46), cf(1.4, 4.14, 0), COPPER_L)
		B:block("Root", v(0.36, 2.26, 0.42), cf(1.76, 4.12, 0), COPPER)
		B:block("Root", v(0.24, 2.66, 0.38), cf(2.05, 4.1, 0), COPPER_L)
		B:block("Root", v(0.16, 2.86, 0.32), cf(2.24, 4.1, 0), PATINA) -- teal patina edge
		-- crescent horns curling back toward the haft, tipped green
		B:block("Root", v(0.44, 0.24, 0.38), cf(1.98, 5.5, 0), COPPER)
		B:block("Root", v(0.44, 0.24, 0.38), cf(1.98, 2.7, 0), COPPER)
		B:block("Root", v(0.2, 0.2, 0.34), cf(1.7, 5.58, 0), COPPER_L)
		B:block("Root", v(0.2, 0.2, 0.34), cf(1.7, 2.62, 0), COPPER_D)
		B:block("Root", v(0.16, 0.2, 0.3), cf(2.24, 5.6, 0), PATINA)
		B:block("Root", v(0.16, 0.2, 0.3), cf(2.24, 2.6, 0), PATINA)

		-- face detail on both sides
		for _, s in { 1, -1 } do
			-- teal diamond inlay on the socket with a polished centre
			B:block("Root", v(0.28, 0.28, 0.06), cf(0, 4.2, 0.31 * s, 0, 0, 45), PATINA)
			B:block("Root", v(0.1, 0.1, 0.04), cf(0, 4.2, 0.345 * s), SHINE)
			-- copper rivets
			for _, y in { 3.9, 4.2, 4.5 } do
				B:block("Root", v(0.12, 0.12, 0.06), cf(0.64, y, 0.285 * s), SHINE)
			end
			-- polish glints + engraved line
			B:block("Root", v(0.32, 0.1, 0.04), cf(1.4, 4.7, 0.245 * s), SHINE)
			B:block("Root", v(0.1, 0.6, 0.04), cf(1.76, 4.6, 0.225 * s), SHINE)
			B:block("Root", v(0.36, 0.08, 0.04), cf(1.06, 3.9, 0.265 * s), COPPER_D)
			-- patina creeping in from the edge (irregular stepped patches)
			B:block("Root", v(0.14, 1.4, 0.04), cf(2.1, 3.9, 0.205 * s), PATINA_D)
			B:block("Root", v(0.14, 0.5, 0.04), cf(2.1, 5.0, 0.205 * s), PATINA_D)
			B:block("Root", v(0.16, 0.36, 0.04), cf(1.92, 3.4, 0.225 * s), PATINA_D)
		end

		-- leather thong with a copper bead hanging from the collar
		B:bar("Root", v(0.2, 2.85, 0.2), v(0.32, 2.36, 0.26), 0.09, 0.09, LEATHER_D)
		B:block("Root", v(0.17, 0.17, 0.17), cf(0.32, 2.3, 0.26), COPPER_L)
	end,
}
