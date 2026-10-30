-- Wooden Axe: the starter tool. A chunky stud-built axe, sized for a player's
-- hand. Built standing up: haft along +Y (pommel at Y=0), blade facing +X.
-- spec.Tool turns it into a Roblox Tool (the part named "Handle" is gripped).
return {
	DisplayName = "Wooden Axe",
	Rarity = "Common",
	Element = "Tool",
	Tool = { Name = "Wooden Axe", ToolTip = "Wooden Axe", GripY = -1.25, Swing = true },
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local HAFT, HAFT_D, HAFT_L = "#a5703f", "#7a4f2a", "#c48d58"
		local WRAP, WRAP_D = "#3f7a3a", "#2d5a2a"
		local HEAD, HEAD_D, HEAD_L, EDGE = "#d9a35e", "#a8743c", "#ebc283", "#f6e2b8"
		local ROPE = "#e0c27e"

		-- haft (the Handle): runs from the pommel up through the head
		B:block("Root", v(0.36, 4.0, 0.36), cf(0, 2.3, 0), HAFT, { name = "Handle" })
		-- grain strips on the front and back faces
		B:block("Root", v(0.08, 1.5, 0.06), cf(0.06, 2.55, 0.2), HAFT_D)
		B:block("Root", v(0.08, 1.1, 0.06), cf(-0.06, 2.75, -0.2), HAFT_D)
		-- pommel knob
		B:block("Root", v(0.5, 0.26, 0.5), cf(0, 0.17, 0), HAFT_D)
		B:block("Root", v(0.42, 0.12, 0.42), cf(0, 0.36, 0), HAFT_L)

		-- green cloth grip with raised bands
		B:block("Root", v(0.44, 1.2, 0.44), cf(0, 1.15, 0), WRAP)
		for _, y in { 0.62, 1.15, 1.68 } do
			B:block("Root", v(0.5, 0.13, 0.5), cf(0, y, 0), WRAP_D)
		end

		-- head socket wrapped round the top of the haft, rope bindings + cap
		B:block("Root", v(0.66, 1.05, 0.54), cf(0, 3.95, 0), HEAD_D)
		B:block("Root", v(0.48, 0.16, 0.48), cf(0, 4.4, 0), HAFT_D)
		B:block("Root", v(0.72, 0.12, 0.6), cf(0, 3.48, 0), ROPE)
		B:block("Root", v(0.72, 0.12, 0.6), cf(0, 4.4, 0), ROPE)

		-- back poll (blunt end)
		B:block("Root", v(0.36, 0.66, 0.48), cf(-0.48, 3.95, 0), HEAD)
		B:block("Root", v(0.16, 0.46, 0.4), cf(-0.72, 3.95, 0), HEAD_D)

		-- bearded blade: steps out and down toward a pale cutting edge
		B:block("Root", v(0.5, 0.8, 0.46), cf(0.52, 3.98, 0), HEAD)
		B:block("Root", v(0.42, 1.12, 0.42), cf(0.93, 3.9, 0), HEAD)
		B:block("Root", v(0.36, 1.5, 0.38), cf(1.3, 3.8, 0), HEAD_L)
		B:block("Root", v(0.3, 0.42, 0.36), cf(1.28, 2.92, 0), HEAD) -- beard
		B:block("Root", v(0.2, 1.86, 0.32), cf(1.56, 3.72, 0), EDGE) -- cutting edge
		B:block("Root", v(0.2, 0.32, 0.3), cf(1.48, 2.66, 0), EDGE) -- beard tip
		B:block("Root", v(0.2, 0.22, 0.3), cf(1.62, 4.72, 0), EDGE) -- top horn
		-- darker grain lines on both blade faces
		for _, z in { 0.205, -0.205 } do
			B:block("Root", v(0.62, 0.08, 0.04), cf(0.95, 4.18, z), HEAD_D)
			B:block("Root", v(0.46, 0.08, 0.04), cf(1.05, 3.62, z), HEAD_D)
		end
	end,
}
