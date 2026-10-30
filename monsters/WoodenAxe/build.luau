-- Wooden Axe ("sprout hatchet"): a common garden hatchet with a bearded,
-- crescent-edged wooden head. Curved shapes are Roblox unions: parts that share
-- an opts.union name are merged by the UnionBaker, opts.negate parts carve.
-- Stands on its pommel; handle runs up Y, blade points +X. Static model.
return {
	DisplayName = "Wooden Axe",
	Rarity = "Common",
	Element = "Tool",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local WOOD, WOOD_D = "#a8693a", "#7a4a26"
		local HEAD, EDGE, SOCKET = "#d9a462", "#f3dba8", "#c48a4c"
		local WRAP, WRAP_D, ROPE = "#4a8f3a", "#356b2b", "#d6b67c"
		local LEAF = "#5cc93f"
		local AXIS_Y, AXIS_Z = ang(0, 0, 90), ang(0, 90, 0)

		-- round haft with a knob pommel and a ball cap
		local H = { union = "Haft" }
		B:cyl("Root", v(5.3, 0.46, 0.46), cf(0, 2.95, 0) * AXIS_Y, WOOD, H)
		B:cyl("Root", v(0.3, 0.64, 0.64), cf(0, 0.55, 0) * AXIS_Y, WOOD_D, H)
		B:ball("Root", 0.72, cf(0, 0.36, 0), WOOD_D, H)
		B:ball("Root", 0.5, cf(0, 5.62, 0), WOOD_D, H)

		-- green cloth grip: three raised rings over a wrap
		local G = { union = "Grip" }
		B:cyl("Root", v(1.15, 0.54, 0.54), cf(0, 1.4, 0) * AXIS_Y, WRAP_D, G)
		for _, y in { 0.95, 1.4, 1.85 } do
			B:cyl("Root", v(0.2, 0.62, 0.62), cf(0, y, 0) * AXIS_Y, WRAP, G)
		end

		-- studded socket block the head is mounted in, with rope bindings
		B:block("Root", v(0.85, 1.1, 0.7), cf(0, 4.9, 0), SOCKET)
		local R = { union = "Rope" }
		for _, y in { 4.25, 5.52 } do
			B:cyl("Root", v(0.16, 0.66, 0.66), cf(0, y, 0) * AXIS_Y, ROPE, R)
		end

		-- bearded head: a disc trimmed flat on top, cut away behind the haft,
		-- and scooped underneath so the beard sweeps down
		local cx, cy = 0.95, 4.75
		local function headShape(group, color, thick, keepFrom)
			local o = { union = group }
			local n = { union = group, negate = true }
			B:cyl("Root", v(thick, 3.0, 3.0), cf(cx, cy - 0.35, 0) * AXIS_Z, color, o)
			B:block("Root", v(4, 2, 2), cf(cx, cy + 1.55, 0), color, n) -- flat top edge
			B:block("Root", v(2, 6, 2), cf(keepFrom - 1, cy, 0), color, n) -- nothing behind
			B:cyl("Root", v(2, 1.6, 1.6), cf(0.55, cy - 1.45, 0) * AXIS_Z, color, n) -- beard scoop
			B:block("Root", v(1.3, 3, 2), cf(-0.35, cy - 1.9, 0), color, n) -- clear the haft below the socket
			return o, n
		end
		headShape("Head", HEAD, 0.42, -0.3)
		B:block("Root", v(0.95, 0.95, 0.5), cf(0.7, cy + 0.07, 0), HEAD, { union = "Head" }) -- neck into the socket
		-- pale cutting edge: the same outline, hollowed out to a thin crescent
		local _, en = headShape("Edge", EDGE, 0.46, cx + 0.35)
		B:cyl("Root", v(2, 2.6, 2.6), cf(cx - 0.12, cy - 0.35, 0) * AXIS_Z, EDGE, en)

		-- a little sprout growing from the cap
		B:block("Root", v(0.1, 0.42, 0.1), cf(0, 5.98, 0), "#3f9a35")
		local L = { union = "Leaves" }
		for _, s in { { -1, 6.13, 28 }, { 1, 6.24, -28 } } do
			local base = cf(0.27 * s[1], s[2], 0) * ang(0, 0, s[3])
			B:cyl("Root", v(0.08, 0.5, 0.5), base * AXIS_Z, LEAF, L)
			B:block("Root", v(0.36, 0.36, 0.08), base * CFrame.new(0.2 * s[1], 0.05, 0) * ang(0, 0, 45), LEAF, L)
		end
	end,
}
