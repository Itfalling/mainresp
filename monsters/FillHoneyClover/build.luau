--!nocheck
-- Clover Patch (Honey Hills filler prop, v2).
-- A low spreading patch of chunky three-leaf clovers in the HoneyClover style:
-- * six trefoils at three sizes and heights; every leaflet is a heart (a
--   base block + two rounded lobes) with a pale chevron, one leaflet per
--   clover in the light green, a dark knot in the middle
-- * three white clover blossoms: pink-tinted base, white stepped pom, pale
--   tip, on a dark calyx; one still a closed pink bud
-- * a low grassy footing: three-tone grass patch, soil peek, grass tufts and
--   a pebble
-- Filler: anchored, weld-free, no scripts. Scatter it over the hills.
return {
	DisplayName = "Clover Patch",
	Rarity = "Filler",
	Filler = true,
	Element = "Honey Hills",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Honey Hills: HoneyClover / DecorHoneySign)
		local SOIL = "#94583a"
		local GRASS_DK, GRASS, GRASS_LT = "#8fb83a", "#a8cf46", "#c4e35e"
		local PEBBLE, PEBBLE_DK = "#d8ccb4", "#ab9e86"
		local STEM, STEM_DK = "#3f9440", "#2f7a34"
		local LEAF_DK, LEAF, LEAF_LT, LEAF_V = "#2f8a42", "#47ad57", "#64c468", "#dcf7c4"
		local CLV_FL, CLV_TIP, CLV_PK = "#fff4f8", "#ffb6d0", "#ff9ec8"

		------------------------------------------------------------ footing
		-- rounded grass patch (three crossed slabs) + two ragged edge bits
		B:block(R, v(3.0, 0.12, 1.7), cf(0, 0.06, 0, 0, 15, 0), GRASS_DK)
		B:block(R, v(1.7, 0.11, 3.0), cf(0, 0.055, 0, 0, 15, 0), GRASS_DK)
		B:block(R, v(2.5, 0.1, 2.5), cf(0, 0.05, 0, 0, 15, 0), GRASS_DK)
		B:block(R, v(1.0, 0.13, 0.7), cf(1.55, 0.065, -0.5, 0, 40, 0), GRASS_DK)
		B:block(R, v(0.9, 0.13, 0.7), cf(-0.9, 0.065, -1.45, 0, -20, 0), GRASS)
		B:block(R, v(1.6, 0.16, 1.3), cf(0.4, 0.08, -0.3, 0, 30, 0), GRASS)
		B:block(R, v(0.8, 0.15, 0.6), cf(-0.7, 0.075, 0.7, 0, -10, 0), SOIL)
		local function tuft(x, z, yaw, h)
			local c = CFrame.new(x, 0, z) * ang(0, yaw, 0)
			B:block(R, v(0.22, h, 0.14), c * CFrame.new(-0.12, h / 2, 0) * ang(0, 0, 14), GRASS_DK)
			B:block(R, v(0.22, h * 1.25, 0.14), c * CFrame.new(0.02, h * 0.6, 0.05) * ang(-8, 0, -4), GRASS)
			B:block(R, v(0.2, h * 0.9, 0.14), c * CFrame.new(0.15, h * 0.45, -0.04) * ang(6, 0, -16), GRASS_LT)
		end
		tuft(1.45, 0.75, 30, 0.5)
		tuft(-1.4, -0.5, -60, 0.55)
		B:block(R, v(0.5, 0.3, 0.42), cf(-1.2, 0.15, 1.15, 0, 30, 0), PEBBLE_DK)
		B:block(R, v(0.34, 0.1, 0.28), cf(-1.21, 0.35, 1.14, 0, 30, 0), PEBBLE)
		-- tiny lavender wildflower at the edge
		B:block(R, v(0.14, 0.5, 0.14), cf(1.35, 0.3, 0.2), STEM)
		B:block(R, v(0.5, 0.14, 0.22), cf(1.35, 0.58, 0.2, 0, 30, 0), "#c3a2ff")
		B:block(R, v(0.22, 0.15, 0.5), cf(1.35, 0.58, 0.2, 0, 30, 0), "#c3a2ff")
		B:block(R, v(0.18, 0.18, 0.18), cf(1.35, 0.66, 0.2, 0, 30, 0), "#ffd23a")

		------------------------------------------------------------ clovers
		local function clover(x, z, y, s, yaw, col, tilt)
			if y > 0.35 then
				B:bar(R, v(x, 0.12, z), v(x, y, z), 0.18, 0.18, STEM_DK)
			end
			local F = CFrame.new(x, y, z) * ang(0, yaw, 0)
			for k = 0, 2 do
				local G = F * ang(0, k * 120, 0) * ang(tilt, 0, 0)
				local lc = (k == 1) and LEAF_LT or col
				B:block(R, v(1.45 * s, 0.2, 1.3 * s), G * CFrame.new(0, 0, -1.05 * s), lc)
				B:block(R, v(0.82 * s, 0.22, 0.9 * s), G * CFrame.new(0.45 * s, 0, -1.95 * s) * ang(0, -10, 0), lc)
				B:block(R, v(0.82 * s, 0.22, 0.9 * s), G * CFrame.new(-0.45 * s, 0, -1.95 * s) * ang(0, 10, 0), lc)
				if s > 0.4 then
					B:block(R, v(0.95 * s, 0.24, 0.24 * s), G * CFrame.new(0, 0, -1.3 * s), LEAF_V)
				end
			end
			B:block(R, v(0.5 * s, 0.24, 0.5 * s), F * ang(0, 45, 0), LEAF_DK)
		end
		clover(0.05, 0.05, 0.95, 0.5, 15, LEAF, 14)
		clover(1.15, -0.55, 0.55, 0.42, 60, LEAF_DK, 10)
		clover(-1.1, -0.35, 0.65, 0.44, -25, LEAF, 12)
		clover(0.75, 1.05, 0.4, 0.38, 95, LEAF, 8)
		clover(-0.55, 1.0, 0.3, 0.34, 30, LEAF_DK, 6)
		clover(-0.1, -1.25, 0.3, 0.34, 140, LEAF, 6)

		------------------------------------------------------------ blossoms
		local function blossom(x, z, y, lean, s)
			local top = v(x + lean.X, y, z + lean.Z)
			B:bar(R, v(x, 0.12, z), top, 0.16, 0.16, STEM)
			local c = CFrame.new(top) * ang(lean.Z * 30, 0, -lean.X * 30)
			B:block(R, v(0.36 * s, 0.18, 0.36 * s), c * CFrame.new(0, 0.05, 0) * ang(0, 45, 0), STEM_DK) -- calyx
			B:block(R, v(0.6 * s, 0.3 * s, 0.6 * s), c * CFrame.new(0, 0.25 * s, 0), CLV_TIP)
			B:block(R, v(0.5 * s, 0.28 * s, 0.5 * s), c * CFrame.new(0, 0.25 * s, 0) * ang(0, 45, 0), CLV_PK)
			B:block(R, v(0.68 * s, 0.34 * s, 0.68 * s), c * CFrame.new(0, 0.52 * s, 0) * ang(0, 20, 0), CLV_FL)
			B:block(R, v(0.56 * s, 0.32 * s, 0.56 * s), c * CFrame.new(0, 0.52 * s, 0) * ang(0, 65, 0), CLV_FL)
			B:block(R, v(0.36 * s, 0.18 * s, 0.36 * s), c * CFrame.new(0, 0.78 * s, 0) * ang(0, 45, 0), "#ffffff")
			-- floret nubs bulging out so the head reads round, pink-tipped low
			for k = 0, 3 do
				local q = c * ang(0, k * 90 + 42, 0) * CFrame.new(0, 0.42 * s, -0.36 * s) * ang(-25, 0, 0)
				B:block(R, v(0.26 * s, 0.24 * s, 0.22 * s), q, (k % 2 == 0) and CLV_FL or CLV_TIP)
			end
		end
		blossom(0.35, -0.2, 1.75, v(0.3, 0, -0.2), 1.0)
		blossom(-0.45, 0.45, 1.4, v(-0.3, 0, 0.2), 0.9)
		-- closed bud
		local bb, bt = v(0.3, 0.12, 0.45), v(0.55, 1.05, 0.7)
		B:bar(R, bb, bt, 0.14, 0.14, STEM)
		B:block(R, v(0.3, 0.18, 0.3), CFrame.new(bt + v(0, 0.05, 0)) * ang(0, 45, 0), STEM_DK)
		B:block(R, v(0.3, 0.36, 0.3), CFrame.new(bt + v(0, 0.28, 0)), CLV_PK)
		B:block(R, v(0.18, 0.14, 0.18), CFrame.new(bt + v(0, 0.5, 0)) * ang(0, 45, 0), CLV_TIP)
	end,
}
