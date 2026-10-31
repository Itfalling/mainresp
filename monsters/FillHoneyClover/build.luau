--!nocheck
-- Clover Patch (Honey Hills filler prop).
-- A low spreading patch of five chunky three-leaf clovers at slightly
-- different heights: every leaflet is a little heart of two overlapping lobes,
-- tilted up, in two leaf greens. Two white-and-pink clover blossoms poke up
-- from the middle. One flat grass footing slab, no mound. Anchored,
-- weld-free, no scripts: scatter it everywhere.
return {
	DisplayName = "Clover Patch",
	Rarity = "Filler",
	Filler = true,
	Element = "Honey Hills",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		-- palette (Honey Hills, from HoneyClover / DecorHoneySign)
		local GR_DK = "#7cae32"
		local STEM, STEM_DK = "#3f9440", "#2f7a34"
		local LEAF_DK, LEAF, LEAF_LT = "#2f8a42", "#47ad57", "#64c468"
		local CLV_FL, CLV_TIP = "#fff4f8", "#ffb6d0"

		-- flat grass footing
		B:block(R, v(2.2, 0.16, 1.6), cf(0, 0.08, 0, 0, 25, 0), GR_DK)

		-- clover: three heart leaflets around a point (stem only if raised)
		local function clover(x, z, y, s, yaw, col)
			if y > 0.6 then
				B:bar(R, v(x, 0.15, z), v(x, y, z), 0.18, 0.18, STEM_DK)
			end
			local c = CFrame.new(x, y, z) * ang(0, yaw, 0)
			for k = 0, 2 do
				local q = c * ang(0, k * 120, 0) * ang(18, 0, 0)
				local lc = (k == 1) and LEAF_LT or col
				B:block(R, v(0.6 * s, 0.22, 0.8 * s), q * CFrame.new(0.2 * s, 0, -0.5 * s) * ang(0, -22, 0), lc)
				B:block(R, v(0.6 * s, 0.2, 0.8 * s), q * CFrame.new(-0.2 * s, 0.01, -0.5 * s) * ang(0, 22, 0), lc)
			end
		end
		clover(0.0, 0.1, 1.0, 1.2, 10, LEAF)
		clover(1.25, -0.45, 0.55, 1.0, 50, LEAF_DK)
		clover(-1.2, -0.3, 0.7, 1.05, -30, LEAF)
		clover(0.7, 1.05, 0.45, 0.9, 80, LEAF_LT)
		clover(-0.6, -1.25, 0.4, 0.9, 25, LEAF_DK)

		-- clover blossoms: pink base under a white stepped pom
		local function blossom(x, z, y, lean)
			local top = v(x + lean.X, y, z + lean.Z)
			B:bar(R, v(x, 0.15, z), top, 0.16, 0.16, STEM)
			B:block(R, v(0.55, 0.3, 0.55), CFrame.new(top + v(0, 0.1, 0)), CLV_TIP)
			B:block(R, v(0.5, 0.62, 0.5), CFrame.new(top + v(0, 0.5, 0)) * ang(0, 45, 0), CLV_FL)
		end
		blossom(0.4, -0.2, 1.65, v(0.3, 0, -0.15))
		blossom(-0.5, 0.5, 1.35, v(-0.3, 0, 0.25))
	end,
}
