-- Golden Axe: a royal double-bit axe. Two flared crescent blades of polished
-- gold step out from an ornate socket set with a big red gem, on a crimson haft
-- with gold bands and a white grip. Gold sparkles drift off the head.
-- Built standing up: haft along +Y (pommel at Y=0), blades facing +X and -X.
return {
	DisplayName = "Golden Axe",
	Rarity = "Legendary",
	Element = "Tool",
	Tool = { Name = "Golden Axe", ToolTip = "Golden Axe", GripY = -1.55 },
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local GOLD, GOLD_D, GOLD_L, EDGE = "#f5c22b", "#c48a14", "#ffe27a", "#fff1a6"
		local RED, RED_D = "#9a2230", "#5e1219"
		local WHITE, WHITE_D = "#f6f3ec", "#d8d1c2"
		local GEM, GEM_SET = "#ff2338", "#6e0c18"

		local HY = 4.8 -- head centre height

		-- haft (the Handle): crimson lacquered wood, pommel up through the head
		B:block("Root", v(0.44, 5.2, 0.44), cf(0, 2.8, 0), RED, { name = "Handle" })
		B:block("Root", v(0.08, 1.2, 0.06), cf(0.08, 3.0, 0.24), RED_D)
		B:block("Root", v(0.08, 1.2, 0.06), cf(-0.08, 3.0, -0.24), RED_D)

		-- gold pommel: stepped cap with a gem on each face
		B:block("Root", v(0.68, 0.26, 0.68), cf(0, 0.13, 0), GOLD_D)
		B:block("Root", v(0.56, 0.14, 0.56), cf(0, 0.33, 0), GOLD)
		B:block("Root", v(0.4, 0.1, 0.4), cf(0, -0.04, 0), GOLD_L)
		for _, s in { 1, -1 } do
			B:gem("Root", v(0.16, 0.12, 0.04), cf(0, 0.13, s * 0.35), GEM, { name = "PommelGem" })
		end

		-- white grip with soft grey wrap bands and a gold ring in the middle
		B:block("Root", v(0.52, 1.7, 0.52), cf(0, 1.25, 0), WHITE)
		for _, y in { 0.62, 0.98, 1.52, 1.88 } do
			B:block("Root", v(0.57, 0.1, 0.57), cf(0, y, 0), WHITE_D)
		end
		B:block("Root", v(0.58, 0.12, 0.58), cf(0, 1.25, 0), GOLD)
		B:block("Root", v(0.6, 0.14, 0.6), cf(0, 2.14, 0), GOLD_D)
		B:block("Root", v(0.52, 0.08, 0.52), cf(0, 2.25, 0), GOLD_L)

		-- gold bands up the haft
		for _, y in { 2.75, 3.3 } do
			B:block("Root", v(0.54, 0.14, 0.54), cf(0, y, 0), GOLD)
		end
		-- gold langets down from the socket
		for _, z in { 0.245, -0.245 } do
			B:block("Root", v(0.26, 1.0, 0.08), cf(0, HY - 1.2, z), GOLD_D)
			B:block("Root", v(0.14, 0.14, 0.1), cf(0, HY - 1.55, z * 1.1), GOLD_L)
		end

		-- ornate socket: stepped gold collar blocks round the haft
		B:block("Root", v(0.88, 1.62, 0.64), cf(0, HY, 0), GOLD_D)
		B:block("Root", v(0.96, 0.14, 0.7), cf(0, HY - 0.75, 0), GOLD_L)
		B:block("Root", v(0.96, 0.14, 0.7), cf(0, HY + 0.75, 0), GOLD_L)
		B:block("Root", v(0.76, 0.12, 0.6), cf(0, HY - 0.88, 0), GOLD)
		-- the big red gem, set in a gold diamond frame on both faces
		for _, s in { 1, -1 } do
			B:block("Root", v(0.6, 0.6, 0.04), cf(0, HY, s * 0.33, 0, 0, 45), GOLD_L)
			B:block("Root", v(0.44, 0.44, 0.04), cf(0, HY, s * 0.36, 0, 0, 45), GEM_SET)
			local g = B:gem("Root", v(0.3, 0.3, 0.06), cf(0, HY, s * 0.38, 0, 0, 45), GEM, { name = "Gem" })
			if s == 1 then
				B:light(g, { color = GEM, brightness = 0.6, range = 6, name = "GemGlow" })
			end
			B:block("Root", v(0.08, 0.08, 0.04), cf(-0.06, HY + 0.06, s * 0.42), WHITE) -- glint
		end

		-- top finial: stepped gold spire
		B:block("Root", v(0.56, 0.2, 0.56), cf(0, HY + 0.9, 0), GOLD)
		B:block("Root", v(0.4, 0.26, 0.4), cf(0, HY + 1.12, 0), GOLD_L)
		B:block("Root", v(0.24, 0.24, 0.24), cf(0, HY + 1.36, 0), GOLD)
		B:gem("Root", v(0.14, 0.14, 0.14), cf(0, HY + 1.54, 0), GEM, { name = "TipGem" })

		-- two crescent blades (s = +1 front bit, -1 back bit), stepping taller and
		-- thinner toward a pale polished edge, with horns curling back at each tip
		for _, s in { 1, -1 } do
			B:block("Root", v(0.34, 1.0, 0.5), cf(s * 0.59, HY, 0), GOLD)         -- neck
			B:block("Root", v(0.34, 1.52, 0.46), cf(s * 0.92, HY, 0), GOLD_L)      -- step 1
			B:block("Root", v(0.3, 2.12, 0.42), cf(s * 1.23, HY, 0), GOLD)        -- step 2
			B:block("Root", v(0.26, 2.72, 0.38), cf(s * 1.51, HY, 0), GOLD_L)      -- step 3
			B:block("Root", v(0.24, 3.12, 0.3), cf(s * 1.75, HY, 0), EDGE)         -- edge
			for _, t in { 1, -1 } do
				B:block("Root", v(0.32, 0.26, 0.3), cf(s * 1.68, HY + t * 1.66, 0), EDGE)
				B:block("Root", v(0.3, 0.22, 0.28), cf(s * 1.44, HY + t * 1.84, 0), EDGE)
			end
			-- ornate face work on both faces of each blade
			for _, z in { 1, -1 } do
				-- engraved groove along step 2 and step 3
				B:block("Root", v(0.06, 1.8, 0.04), cf(s * 1.37, HY, z * 0.22), GOLD_D)
				-- stepped scroll plates above and below the gem dot
				B:block("Root", v(0.26, 0.12, 0.04), cf(s * 0.92, HY + 0.5, z * 0.245), GOLD_D)
				B:block("Root", v(0.26, 0.12, 0.04), cf(s * 0.92, HY - 0.5, z * 0.245), GOLD_D)
				B:block("Root", v(0.2, 0.2, 0.04), cf(s * 0.92, HY, z * 0.245, 0, 0, 45), GOLD_D)
				B:gem("Root", v(0.1, 0.1, 0.04), cf(s * 0.92, HY, z * 0.265, 0, 0, 45), GEM, { name = "BladeGem" })
				-- small gold studs on step 3
				B:block("Root", v(0.1, 0.1, 0.04), cf(s * 1.51, HY + 0.95, z * 0.205), GOLD_D)
				B:block("Root", v(0.1, 0.1, 0.04), cf(s * 1.51, HY - 0.95, z * 0.205), GOLD_D)
			end
		end

		-- golden sparkles drifting off the head
		local aura = B:block("Root", v(3.6, 3.4, 0.5), cf(0, HY, 0), GOLD, { tr = 1, name = "SparkleBox" })
		B:emitter(aura, "sparkle", { color = { "#fff3b0", "#ffc83a" }, rate = 6, size = { 0.3, 0 }, life = { 0.6, 1.1 }, speed = { 0.1, 0.4 }, name = "GoldSparkle" })
	end,
}
