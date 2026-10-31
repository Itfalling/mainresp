--!nocheck
-- Crystal Sprout (Starlight Ruins filler).
-- A small cluster of chunky violet crystal prisms leaning out of an indigo
-- stone chip: each prism is a shaft with a lit two-tone facet and a
-- stepped point, turned 45 degrees so an edge faces out. The tallest point has one tiny neon tip.
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Crystal Sprout",
	Rarity = "Filler",
	Filler = true,
	Element = "Starlight Ruins",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		local VIO_XD, VIO_DK, VIO, VIO_LT = "#5a3fc0", "#7a58ea", "#9b7cff", "#c6b4ff"
		local TILE_DK, TILE = "#2a2550", "#3b3566"
		local STONE_DK = "#a99fc2"
		local TIP = "#b8a4ff"

		-- crystal prism rising along local +Y of a tilted frame
		local function crystal(x, z, yaw, tilt, w, h, col, colLt, neon)
			local C = CFrame.new(x, 0.25, z) * ang(0, yaw, 0) * ang(tilt, 0, 0) * ang(0, 45, 0)
			B:block(R, v(w, h, w), C * CFrame.new(0, h / 2, 0), col)
			-- lit facet: covers one side face and half of the two next to it
			B:block(R, v(w * 0.5 + 0.04, h - 0.1, w + 0.04), C * CFrame.new(w * 0.27, h / 2 - 0.05, 0), colLt)
			local t = w * 0.7
			B:block(R, v(t, t * 0.7, t), C * CFrame.new(0, h + t * 0.3, 0), VIO_LT)
			local tip = w * 0.38
			B:block(R, v(tip, tip * 0.9, tip), C * CFrame.new(0, h + t * 0.65 + tip * 0.4, 0), neon and TIP or colLt, neon and { mat = "Neon" } or nil)
		end

		-- stone chip the cluster grows from
		B:block(R, v(1.9, 0.4, 1.6), cf(0, 0.2, 0, 0, 12, 0), TILE_DK)
		B:block(R, v(1.0, 0.3, 0.8), cf(0.75, 0.15, 0.75, 0, -20, 0), TILE)

		crystal(0, 0, 10, 6, 0.8, 2.5, VIO_DK, VIO, true) -- tallest, upright
		crystal(-0.45, 0.1, 80, -28, 0.65, 1.6, VIO_DK, VIO) -- leaning left
		crystal(0.4, -0.25, -60, -30, 0.6, 1.3, VIO_DK, VIO) -- leaning front-right
		crystal(0.25, 0.45, 160, -24, 0.55, 1.2, VIO_XD, VIO_DK) -- leaning back
		crystal(-0.55, -0.6, -150, 34, 0.4, 0.8, VIO_DK, VIO) -- little one at the front

		B:block(R, v(0.35, 0.3, 0.35), cf(-0.95, 0.15, 0.75, 0, 30, 0), STONE_DK) -- pebble
	end,
}
