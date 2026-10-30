-- Stone Axe: a chunky grey flint head lashed to a wooden haft with rope,
-- a little moss growing on top. Built standing up: haft along +Y (pommel at
-- Y=0), blade facing +X. Static prop: no motion.luau.
return {
	DisplayName = "Stone Axe",
	Rarity = "Uncommon",
	Element = "Tool",
	Tool = { Name = "Stone Axe", ToolTip = "Stone Axe", GripY = -1.225 },
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local HAFT, HAFT_D, HAFT_L = "#9a6a3c", "#6b4524", "#b98450"
		local ROPE, ROPE_D = "#d8b878", "#a8874a"
		local STONE, STONE_D, STONE_L, EDGE = "#9a9b97", "#6c6e6b", "#bdbeb9", "#e4e4de"
		local MOSS, MOSS_D = "#74b83f", "#4f8a2f"
		local CORE = "#7d7f7a"

		-- haft (the Handle): pommel up through the head
		B:block("Root", v(0.38, 4.35, 0.38), cf(0, 2.475, 0), HAFT, { name = "Handle" })
		B:block("Root", v(0.08, 1.4, 0.06), cf(0.07, 2.6, 0.21), HAFT_D)
		B:block("Root", v(0.08, 1.0, 0.06), cf(-0.07, 2.75, -0.21), HAFT_D)
		-- pommel knob
		B:block("Root", v(0.54, 0.28, 0.54), cf(0, 0.17, 0), HAFT_D)
		B:block("Root", v(0.44, 0.12, 0.44), cf(0, 0.37, 0), HAFT_L)

		-- rope-wrapped grip with darker turns
		B:block("Root", v(0.46, 1.3, 0.46), cf(0, 1.25, 0), ROPE)
		for _, y in { 0.66, 1.0, 1.34, 1.68 } do
			B:block("Root", v(0.5, 0.1, 0.5), cf(0, y, 0), ROPE_D)
		end

		-- stone head core around the top of the haft
		B:block("Root", v(0.86, 1.3, 0.62), cf(0.05, 4, 0), CORE)
		B:block("Root", v(0.92, 0.14, 0.68), cf(0.05, 3.41, 0), ROPE_D) -- wrap round the core base
		B:block("Root", v(0.92, 0.14, 0.68), cf(0.05, 4.57, 0), ROPE) -- wrap round the core top
		B:block("Root", v(0.5, 0.18, 0.5), cf(0, 4.73, 0), HAFT_D) -- haft end
		-- rope lashings above + below the head
		B:block("Root", v(0.52, 0.14, 0.52), cf(0, 3.25, 0), ROPE)
		-- X lashing across both faces of the core
		for _, z in { 0.33, -0.33 } do
			B:block("Root", v(0.14, 1.35, 0.06), cf(0.05, 4, z, 0, 0, 32), ROPE)
			B:block("Root", v(0.14, 1.35, 0.06), cf(0.05, 4, z * 1.03, 0, 0, -32), ROPE_D)
		end

		-- back poll (blunt hammer end)
		B:block("Root", v(0.46, 0.9, 0.6), cf(-0.6, 4.05, 0), STONE)
		B:block("Root", v(0.24, 0.66, 0.5), cf(-0.93, 4.01, 0), STONE_D)

		-- stepped flint blade, rough-hewn and flaring toward the edge
		B:block("Root", v(0.56, 1.1, 0.6), cf(0.66, 4.07, 0), STONE)
		B:block("Root", v(0.48, 1.5, 0.54), cf(1.12, 3.99, 0), STONE)
		B:block("Root", v(0.42, 2.02, 0.48), cf(1.52, 3.93, 0), STONE_L)
		B:block("Root", v(0.26, 2.3, 0.38), cf(1.84, 3.91, 0), EDGE) -- knapped edge
		-- edge bulges (stepped, uneven like chipped flint)
		B:block("Root", v(0.16, 0.5, 0.32), cf(2.02, 4.47, 0), EDGE)
		B:block("Root", v(0.16, 0.36, 0.32), cf(2.02, 3.47, 0), EDGE)
		-- top + bottom horns
		B:block("Root", v(0.4, 0.26, 0.42), cf(1.7, 5.05, 0), STONE_L)
		B:block("Root", v(0.4, 0.26, 0.42), cf(1.7, 2.81, 0), STONE)
		B:block("Root", v(0.2, 0.2, 0.36), cf(1.96, 5.15, 0), EDGE)
		B:block("Root", v(0.2, 0.2, 0.36), cf(1.96, 2.71, 0), EDGE)
		-- darker cracks / flake scars on both faces
		for _, s in { 1, -1 } do
			B:block("Root", v(0.5, 0.08, 0.04), cf(0.9, 4.3, 0.28 * s), STONE_D)
			B:block("Root", v(0.08, 0.56, 0.04), cf(1.3, 3.7, 0.26 * s), STONE_D)
			B:block("Root", v(0.36, 0.08, 0.04), cf(1.48, 3.4, 0.245 * s), STONE_D)
			B:block("Root", v(0.26, 0.26, 0.04), cf(1.55, 4.45, 0.245 * s), STONE)
		end

		-- moss growing over the top of the head and creeping down the faces
		B:block("Root", v(0.62, 0.12, 0.66), cf(0.68, 4.67, 0), MOSS)
		B:block("Root", v(0.36, 0.12, 0.64), cf(-0.6, 4.53, 0), MOSS)
		B:block("Root", v(0.34, 0.12, 0.5), cf(1.1, 4.78, 0.02), MOSS_D)
		for _, s in { 1, -1 } do
			B:block("Root", v(0.4, 0.2, 0.06), cf(0.66, 4.53, 0.31 * s), MOSS)
			B:block("Root", v(0.18, 0.2, 0.06), cf(0.58 + 0.08 * s, 4.5, 0.31 * s), MOSS_D)
			B:block("Root", v(0.22, 0.22, 0.06), cf(-0.6, 4.39, 0.31 * s), MOSS_D)
		end

		-- loose rope tails hanging from the lower lashing
		B:bar("Root", v(0.22, 3.27, 0.24), v(0.34, 2.67, 0.3), 0.1, 0.1, ROPE)
		B:bar("Root", v(0.12, 3.27, 0.26), v(0.14, 2.81, 0.32), 0.1, 0.1, ROPE_D)
		B:block("Root", v(0.14, 0.12, 0.14), cf(0.34, 2.65, 0.3), ROPE_D)
	end,
}
