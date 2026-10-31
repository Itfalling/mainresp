--!nocheck
-- Sandstone Rocks (Sandy Savanna filler).
-- A cluster of three sandstone rocks (big, medium, small) huddled together,
-- each a main body over a darker crossed skirt (shaded corner facets at the
-- foot), a pale sandstone band on the big one and a lighter cap twisted off-axis,
-- plus two pebbles. Lightweight
-- scenery meant to be copy-pasted many times: anchored, weld-free, no
-- scripts or effects.
return {
	DisplayName = "Sandstone Rocks",
	Rarity = "Filler",
	Filler = true,
	Element = "Sandy Savanna",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		-- palette (Sandy Savanna decorations)
		local ROCK, ROCK_DK, ROCK_LT = "#c9774a", "#a9573a", "#e0a06a"
		local BAND = "#e8c27a"
		local PEBBLE, PEBBLE_DK = "#bfae94", "#968670"

		-- one rock: a main body, a darker body crossed at an angle so its corners
		-- poke out as shaded facets (pixel-round silhouette), an optional pale
		-- sandstone band and a lighter cap knocked slightly off-axis.
		-- x, z, scale, yaw, height factor, lean (deg), band?
		local function rock(x, z, s, yaw, hf, lean, band)
			local c = CFrame.new(x, 0, z) * ang(0, yaw, 0)
			local h = 1.0 * s * hf
			local base = c * ang(0, 0, lean)
			B:block(R, v(1.5 * s, h, 1.2 * s), base * CFrame.new(0, h / 2, 0), ROCK)
			B:block(R, v(1.25 * s, h * 0.5, 1.6 * s), c * ang(0, 40, 0) * CFrame.new(0, h * 0.25, 0), ROCK_DK)
			if band then
				B:block(R, v(1.55 * s, 0.2 * s, 1.25 * s), base * CFrame.new(0, h * 0.62, 0), BAND)
			end
			B:block(R, v(1.1 * s, 0.4 * s, 0.9 * s), base * CFrame.new(0.1 * s, h + 0.15 * s, -0.05 * s) * ang(4, 16, -3), ROCK_LT)
		end

		rock(-0.75, 0.3, 1.5, 20, 1.25, 4, true)
		rock(1.4, -0.6, 1.05, -28, 0.95, -5, false)
		rock(0.75, 1.5, 0.7, 55, 0.85, 8, false)

		B:block(R, v(0.55, 0.4, 0.5), cf(-2.3, 0.2, -0.9, 0, 35, 0), PEBBLE)
		B:block(R, v(0.45, 0.35, 0.45), cf(2.0, 0.18, 0.9, 0, 15, 0), PEBBLE_DK)
	end,
}
