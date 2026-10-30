-- Iron Axe: a proper forged war axe. A broad bearded steel head with a bright
-- honed edge, iron langets and bands strapping it to a dark hardwood haft, and
-- a red leather grip. Built standing up: haft along +Y (pommel at Y=0), blade +X.
return {
	DisplayName = "Iron Axe",
	Rarity = "Epic",
	Element = "Tool",
	Tool = { Name = "Iron Axe", ToolTip = "Iron Axe", GripY = -1.6 },
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local WOOD, WOOD_D, WOOD_L = "#5c3a22", "#3d2616", "#7b5233"
		local IRON, IRON_D = "#4d535c", "#30343a"
		local STEEL, STEEL_D, STEEL_L, EDGE = "#a3acb7", "#7d8692", "#c8cfd8", "#f4f8fc"
		local LEATHER, LEATHER_D = "#8c2b25", "#5c1915"
		local RIVET = "#dde2e8"
		local RUNE = "#7fd8ff"

		local HY = 4.8 -- head centre height

		-- haft (the Handle): dark hardwood from the pommel up through the head
		B:block("Root", v(0.42, 5.1, 0.42), cf(0, 2.8, 0), WOOD, { name = "Handle" })
		-- grain strips on the front and back faces
		B:block("Root", v(0.08, 1.3, 0.06), cf(0.07, 2.75, 0.23), WOOD_D)
		B:block("Root", v(0.08, 0.8, 0.06), cf(-0.08, 3.45, -0.23), WOOD_D)
		B:block("Root", v(0.06, 0.6, 0.06), cf(-0.23, 2.6, 0.06), WOOD_L)

		-- iron pommel: stepped cap
		B:block("Root", v(0.6, 0.26, 0.6), cf(0, 0.13, 0), IRON_D)
		B:block("Root", v(0.52, 0.14, 0.52), cf(0, 0.33, 0), IRON)
		B:block("Root", v(0.3, 0.08, 0.3), cf(0, -0.02, 0), STEEL)

		-- red leather grip with darker wrap bands, an iron collar on top
		B:block("Root", v(0.5, 1.6, 0.5), cf(0, 1.2, 0), LEATHER)
		for _, y in { 0.62, 1.01, 1.4, 1.79 } do
			B:block("Root", v(0.55, 0.11, 0.55), cf(0, y, 0), LEATHER_D)
		end
		B:block("Root", v(0.56, 0.12, 0.56), cf(0, 2.04, 0), IRON)

		-- iron bands up the haft
		B:block("Root", v(0.52, 0.14, 0.52), cf(0, 2.5, 0), IRON)
		B:block("Root", v(0.52, 0.14, 0.52), cf(0, 3.0, 0), IRON)
		-- langets: iron straps running down from the head on both edges of the haft
		for _, x in { 0.235, -0.235 } do
			B:block("Root", v(0.08, 1.2, 0.24), cf(x, HY - 1.1, 0), IRON_D)
			B:block("Root", v(0.1, 0.12, 0.12), cf(x * 1.1, HY - 1.5, 0), RIVET)
			B:block("Root", v(0.1, 0.12, 0.12), cf(x * 1.1, HY - 0.95, 0), RIVET)
		end

		-- socket (the eye) wrapped round the haft, bands and a riveted top cap
		B:block("Root", v(0.76, 1.4, 0.58), cf(0, HY, 0), STEEL_D)
		B:block("Root", v(0.82, 0.13, 0.64), cf(0, HY - 0.66, 0), IRON)
		B:block("Root", v(0.82, 0.13, 0.64), cf(0, HY + 0.66, 0), IRON)
		B:block("Root", v(0.48, 0.14, 0.48), cf(0, HY + 0.78, 0), IRON_D)
		B:block("Root", v(0.2, 0.08, 0.2), cf(0, HY + 0.88, 0), RIVET)
		for _, z in { 0.305, -0.305 } do
			B:block("Root", v(0.14, 0.14, 0.06), cf(0, HY - 0.28, z), RIVET)
			B:block("Root", v(0.14, 0.14, 0.06), cf(0, HY + 0.28, z), RIVET)
		end

		-- back poll: a squared hammer face
		B:block("Root", v(0.44, 0.86, 0.52), cf(-0.56, HY, 0), STEEL)
		B:block("Root", v(0.2, 1.0, 0.6), cf(-0.86, HY, 0), STEEL_D)
		B:block("Root", v(0.06, 0.7, 0.44), cf(-0.98, HY, 0), STEEL_L)

		-- bearded blade: the top flares up toward the edge, the underside drops into
		-- a long hooked beard; it thins step by step toward the edge
		B:block("Root", v(0.5, 0.85, 0.48), cf(0.61, HY + 0.125, 0), STEEL)        -- neck
		B:block("Root", v(0.44, 1.07, 0.44), cf(1.08, HY + 0.085, 0), STEEL)       -- step 1
		B:block("Root", v(0.42, 1.62, 0.4), cf(1.51, HY - 0.09, 0), STEEL_L)       -- step 2
		B:block("Root", v(0.38, 2.48, 0.36), cf(1.91, HY - 0.36, 0), STEEL_L)      -- step 3
		-- the beard: two angled plates sweep the underside down to the beard tip
		B:bar("Root", v(0.4, HY - 0.3, 0), v(1.3, HY - 0.62, 0), 0.34, 0.5, STEEL)
		B:bar("Root", v(1.22, HY - 0.5, 0), v(1.74, HY - 1.72, 0), 0.3, 0.5, STEEL_L)
		-- honed edge: runs down the front and round under the beard, top horn
		B:block("Root", v(0.28, 3.1, 0.28), cf(2.24, HY - 0.45, 0), EDGE)
		B:block("Root", v(0.84, 0.14, 0.3), cf(1.82, HY - 1.95, 0), EDGE)
		B:block("Root", v(0.44, 0.22, 0.28), cf(2.2, HY + 1.2, 0), EDGE)           -- top horn
		-- iron rib across the top of the neck
		B:block("Root", v(1.0, 0.12, 0.52), cf(0.8, HY + 0.6, 0), IRON)

		-- face details on both sides of the blade
		for _, s in { 1, -1 } do
			-- forge line where the hardened edge starts
			B:block("Root", v(0.07, 2.2, 0.04), cf(1.75, HY - 0.45, s * 0.2), STEEL_D)
			-- fuller groove along the upper blade
			B:block("Root", v(1.05, 0.08, 0.04), cf(1.1, HY + 0.38, s * 0.23), STEEL_D)
			-- hammered dents
			B:block("Root", v(0.14, 0.14, 0.04), cf(1.5, HY - 0.55, s * 0.215), STEEL_D)
			B:block("Root", v(0.12, 0.12, 0.04), cf(1.92, HY - 1.3, s * 0.195), STEEL)
			-- maker's mark: a small glowing rune diamond
			B:block("Root", v(0.28, 0.28, 0.04), cf(0.98, HY - 0.06, s * 0.235, 0, 0, 45), IRON_D)
			B:gem("Root", v(0.14, 0.14, 0.04), cf(0.98, HY - 0.06, s * 0.255, 0, 0, 45), RUNE, { name = "Rune" })
		end

		-- a faint glint running along the freshly honed edge
		local glintBox = B:block("Root", v(0.1, 2.6, 0.1), cf(2.3, HY - 0.45, 0), EDGE, { tr = 1, name = "Glint" })
		B:emitter(glintBox, "sparkle", { color = { "#ffffff", "#bfe9ff" }, rate = 2, size = { 0.35, 0 }, life = { 0.4, 0.7 }, speed = { 0, 0.1 }, name = "EdgeGlint" })
	end,
}
