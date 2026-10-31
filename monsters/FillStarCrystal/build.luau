--!nocheck
-- Crystal Sprout (Starlight Ruins filler).
-- A cluster of violet crystals pushing out of a broken temple stone, in the
-- style of the crystal sprouts on the Stardust Sprout / Broken Star Pillar:
-- * six prisms in three sizes (one small cyan one for variety), leaning out at a few clean angles; each is a
--   dark core square + a mid-violet square turned 45° (faceted, rounded
--   silhouette), a pale highlight edge, and a stepped two-tier point
-- * the tallest point ends in one tiny glowing tip
-- * a rounded indigo rock the cluster grows from, a cracked white-violet
--   paving slab with gold trim, teal moss
-- * footing: low indigo night-soil patch, silver-blue grass tufts, loose
--   crystal shards and gold/cyan star-dust specks
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Crystal Sprout",
	Rarity = "Filler",
	Filler = true,
	Element = "Starlight Ruins",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		-- palette (Starlight Ruins)
		local EARTH_DK, EARTH, EARTH_LT = "#2a2550", "#3b3566", "#4d4684"
		local STONE, STONE2, STONE_DK, STONE_LT = "#e3dcef", "#d0c7e2", "#a99fc2", "#f4f0fb"
		local GOLD, GOLD_DK = "#f2c24f", "#c9952e"
		local MOSS, MOSS_DK, MOSS_LT = "#4f9e7c", "#367a62", "#78c79a"
		local VIO_XD, VIO_DK, VIO, VIO_LT, VIO_HI = "#5a3fc0", "#7a58ea", "#9b7cff", "#c6b4ff", "#e4dbff"
		local DUST_G, DUST_C = "#ffe27a", "#b8f4ff"
		local GRASS, GRASS_DK = "#8ea9dc", "#6f87c2"
		local TIP = "#d8ccff"
		local CY, CY_LT = "#4fd8f2", "#a8f3ff"

		------------------------------------------------------------ footing
		local function patch(x, z, s, h, yaw, col, col2)
			B:block(R, v(s, h, s * 0.56), cf(x, h / 2, z, 0, yaw, 0), col)
			B:block(R, v(s * 0.56, h - 0.01, s), cf(x, h / 2, z, 0, yaw, 0), col)
			B:block(R, v(s * 0.68, h + 0.02, s * 0.68), cf(x, (h + 0.02) / 2, z, 0, yaw + 45, 0), col2 or col)
		end
		patch(0, 0, 3.6, 0.12, 20, EARTH_DK, EARTH)

		-- cracked paving slab with gold trim (front-right)
		B:block(R, v(1.4, 0.22, 1.1), cf(1.0, 0.11, -0.95, 0, 15, 0), STONE2)
		B:block(R, v(0.7, 0.24, 0.9), cf(0.2, 0.12, -1.25, 0, 30, 0), STONE_DK)
		B:block(R, v(1.2, 0.06, 0.14), cf(1.05, 0.25, -1.3, 0, 15, 0), GOLD)

		local function tuft(x, z, s, yaw)
			for k = 0, 2 do
				local h = (0.55 + 0.18 * k) * s
				B:block(R, v(0.15, h, 0.15), CFrame.new(x, 0.1 + h / 2, z) * ang(0, yaw + k * 120, 0) * ang(30, 0, 0) * CFrame.new(0, 0, -0.12), (k == 1) and GRASS_DK or GRASS)
			end
		end
		tuft(-1.5, -0.9, 0.95, 15)
		tuft(1.4, 0.9, 0.8, 70)

		for _, d in { { -0.4, -1.55, DUST_G }, { 1.6, 0.0, DUST_C }, { -1.45, 1.1, DUST_G } } do
			B:block(R, v(0.18, 0.12, 0.18), cf(d[1], 0.12, d[2], 0, 45, 0), d[3])
		end

		------------------------------------------------------------ rock base
		B:block(R, v(1.8, 0.5, 1.1), cf(-0.1, 0.3, 0.15, 0, 10, 0), EARTH)
		B:block(R, v(1.1, 0.49, 1.8), cf(-0.1, 0.3, 0.15, 0, 10, 0), EARTH)
		B:block(R, v(1.25, 0.52, 1.25), cf(-0.1, 0.31, 0.15, 0, 55, 0), EARTH_LT)
		B:block(R, v(1.1, 0.25, 0.9), cf(-0.2, 0.62, 0.3, 0, 30, 0), EARTH_LT)
		B:block(R, v(0.6, 0.27, 0.5), cf(0.45, 0.6, 0.55, 0, 10, 0), STONE_DK) -- embedded stone chunk
		B:block(R, v(0.4, 0.12, 0.35), cf(0.45, 0.76, 0.55, 0, 40, 0), STONE_LT)
		-- moss on the rock
		B:block(R, v(0.7, 0.14, 0.55), cf(0.55, 0.6, -0.45, 0, 20, 0), MOSS)
		B:block(R, v(0.4, 0.16, 0.35), cf(0.6, 0.66, -0.5, 0, 50, 0), MOSS_LT)
		B:block(R, v(0.12, 0.35, 0.4), cf(0.95, 0.42, -0.4, 0, 20, 0), MOSS_DK) -- drip over the edge
		B:block(R, v(0.7, 0.12, 0.5), cf(-1.05, 0.16, 0.85, 0, 10, 0), MOSS_DK)
		B:block(R, v(0.4, 0.14, 0.3), cf(-1.1, 0.18, 0.9, 0, 40, 0), MOSS)

		------------------------------------------------------------ crystals
		-- prism rising along local +Y of a tilted frame at base p
		local function crystal(p, yaw, tilt, w, h, core, mid, neon)
			local C = CFrame.new(p) * ang(0, yaw, 0) * ang(tilt, 0, 0)
			B:block(R, v(w, h, w), C * CFrame.new(0, h / 2, 0), core)
			B:block(R, v(w * 0.92, h - 0.06, w * 0.92), C * CFrame.new(0, h / 2, 0) * ang(0, 45, 0), mid)
			-- pale highlight edge on the front corner of the turned square
			B:block(R, v(0.1, h * 0.7, 0.1), C * CFrame.new(0, h * 0.45, -w * 0.62) * ang(0, 45, 0), VIO_LT)
			-- stepped point
			local t1 = w * 0.72
			B:block(R, v(t1, t1 * 0.75, t1), C * CFrame.new(0, h + t1 * 0.3, 0), mid)
			B:block(R, v(t1 * 0.9, t1 * 0.72, t1 * 0.9), C * CFrame.new(0, h + t1 * 0.3, 0) * ang(0, 45, 0), VIO_LT)
			local t2 = w * 0.38
			B:block(R, v(t2, t2 * 1.1, t2), C * CFrame.new(0, h + t1 * 0.7 + t2 * 0.5, 0) * ang(0, 45, 0), neon and TIP or VIO_HI, neon and { mat = "Neon" } or nil)
		end

		local base = v(-0.1, 0.55, 0.15)
		crystal(base + v(0.05, 0, 0), 15, 5, 0.7, 2.4, VIO_DK, VIO, true) -- tallest
		crystal(base + v(-0.45, -0.05, 0.1), 75, -26, 0.6, 1.6, VIO_XD, VIO_DK) -- left
		crystal(base + v(0.4, -0.05, -0.15), -55, -28, 0.55, 1.35, VIO_DK, VIO) -- front-right
		crystal(base + v(0.2, -0.05, 0.45), 165, -24, 0.5, 1.2, VIO_XD, VIO_DK) -- back
		crystal(base + v(-0.35, -0.1, -0.4), -140, 32, 0.38, 0.8, VIO_DK, VIO) -- small front
		crystal(base + v(0.55, -0.1, 0.25), 120, -38, 0.35, 0.7, CY, CY_LT) -- small cyan one

		-- loose shards on the soil
		B:block(R, v(0.3, 0.45, 0.3), cf(1.3, 0.3, 0.45, 0, 45, 25), VIO_DK)
		B:block(R, v(0.18, 0.2, 0.18), cf(1.42, 0.55, 0.45, 0, 45, 25), VIO_LT)
		B:block(R, v(0.25, 0.3, 0.25), cf(-1.2, 0.22, -0.3, 20, 45, 0), VIO)
	end,
}
