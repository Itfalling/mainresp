-- Snappy Flytrap: a small animated decoration for the flytrap section.
-- A fly buzzes around, lands in the open trap, the trap snaps shut, chews,
-- burps and opens again. Trap faces -Z. Built closed; motion opens the lid.
return {
	DisplayName = "Snappy Flytrap",
	Rarity = "Common",
	Element = "Decor",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local DIRT, DIRT_D, DIRT_L = "#6e4024", "#4a2a16", "#8f5a33"
		local STEM, OUT, OUT_D = "#3c9a33", "#4fbf3a", "#2f8a2c"
		local INNER, INNER_D, TOOTH = "#ff5a7a", "#d8335a", "#fff1c4"

		-- stepped dirt mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		B:block(soil, v(4.4, 0.4, 4.4), cf(0, 0.2, 0), DIRT_D, { name = "Soil" })
		B:block(soil, v(3.4, 0.35, 3.4), cf(0, 0.55, 0), DIRT, { name = "Soil" })
		B:block(soil, v(2.2, 0.25, 2.2), cf(0, 0.85, 0), DIRT_L, { name = "Soil" })
		for _, c in { { 1.9, -1.2 }, { -1.7, 1.4 }, { -1.5, -1.6 } } do
			B:block(soil, v(0.7, 0.5, 0.7), cf(c[1], 0.45, c[2], 0, 25, 0), DIRT_D, { name = "Soil" })
		end
		B:block(soil, v(0.25, 0.4, 0.25), cf(1.5, 0.7, 1.4), "#5ccc3f", { name = "Soil" })

		-- little resting leaves and a closed baby trap
		B:block("Root", v(1.6, 0.15, 0.7), cf(1.2, 1.0, 0.6, 0, -30, -12), OUT_D)
		B:block("Root", v(1.5, 0.15, 0.7), cf(-1.2, 1.0, 0.8, 0, 35, 12), OUT_D)
		B:block("Root", v(0.2, 1.0, 0.2), cf(-0.9, 1.4, -0.8, 0, 0, 12), STEM)
		B:block("Root", v(0.7, 0.45, 0.6), cf(-1.05, 2.0, -0.8, 0, 20, 12), OUT)
		B:block("Root", v(0.6, 0.06, 0.5), cf(-1.05, 2.0, -0.8, 0, 20, 12), INNER_D)

		-- stem (sways) carrying the trap head
		local stem = B:bone("Stem", "Root", v(0, 1.0, 0.4))
		B:block(stem, v(0.4, 1.0, 0.4), cf(0, 1.5, 0.4), STEM)
		B:block(stem, v(0.36, 0.9, 0.36), cf(0, 2.3, 0.25, -15, 0, 0), STEM)

		-- trap: lower lobe on Head, upper lobe (Lid) hinged at the back edge
		local head = B:bone("Head", "Stem", v(0, 2.7, 0.3))
		B:block(head, v(2.0, 0.4, 1.7), cf(0, 2.8, -0.2), OUT)
		B:block(head, v(1.6, 0.25, 1.3), cf(0, 2.62, -0.2), OUT_D)
		B:block(head, v(1.8, 0.06, 1.5), cf(0, 3.03, -0.2), INNER)
		B:block(head, v(1.0, 0.04, 0.9), cf(0, 3.06, -0.15), INNER_D)
		local lid = B:bone("Lid", "Head", v(0, 3.05, 0.6))
		B:block(lid, v(2.0, 0.4, 1.7), cf(0, 3.3, -0.2), OUT)
		B:block(lid, v(1.6, 0.25, 1.3), cf(0, 3.48, -0.2), OUT_D)
		B:block(lid, v(1.8, 0.06, 1.5), cf(0, 3.07, -0.2), INNER)
		-- interlocking teeth around the rims (lower point up, upper point down)
		for i = 0, 5 do
			local x = -0.85 + i * 0.34
			B:block(head, v(0.13, 0.42, 0.13), cf(x, 3.15, -1.05), TOOTH)
			B:block(lid, v(0.13, 0.42, 0.13), cf(x + 0.17, 2.95, -1.05), TOOTH)
		end
		for _, x in { -1.02, 1.02 } do
			for j = 0, 2 do
				local z = -0.75 + j * 0.45
				B:block(head, v(0.13, 0.4, 0.13), cf(x, 3.15, z), TOOTH)
				B:block(lid, v(0.13, 0.4, 0.13), cf(x, 2.95, z + 0.22), TOOTH)
			end
		end
		local burp = B:block(head, v(0.4, 0.2, 0.4), cf(0, 3.15, -0.3), INNER, { tr = 1, name = "BurpSpot" })
		B:emitter(burp, "burst", { name = "Burp", color = { "#c8ff8a", "#7be04a" }, size = 0.35 })

		-- the fly (flies freely; its rest spot is inside the mouth)
		local fly = B:bone("Fly", "Root", v(0, 3.25, -0.25))
		B:block(fly, v(0.3, 0.25, 0.4), cf(0, 3.25, -0.25), "#1b1d24", { name = "FlyBody" })
		B:block(fly, v(0.22, 0.2, 0.2), cf(0, 3.27, -0.5), "#2b2f3a", { name = "FlyHead" })
		B:block(fly, v(0.08, 0.08, 0.04), cf(0.07, 3.3, -0.61), "#ff4040", { mat = "Neon", name = "FlyEyeR" })
		B:block(fly, v(0.08, 0.08, 0.04), cf(-0.07, 3.3, -0.61), "#ff4040", { mat = "Neon", name = "FlyEyeL" })
		local wr = B:bone("WingR", "Fly", v(0.1, 3.38, -0.25))
		B:block(wr, v(0.4, 0.04, 0.24), cf(0.3, 3.4, -0.2), "#e8f4ff", { tr = 0.35, name = "FlyWingR" })
		local wl = B:bone("WingL", "Fly", v(-0.1, 3.38, -0.25))
		B:block(wl, v(0.4, 0.04, 0.24), cf(-0.3, 3.4, -0.2), "#e8f4ff", { tr = 0.35, name = "FlyWingL" })
	end,
}
