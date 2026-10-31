--!nocheck
-- Round Bush (Sunny Farm filler, v2). A plump farmyard shrub in the apple-tree
-- greens, built like the crop canopies:
-- * a rounded stepped core (each tier = a square + the same square turned 45
--   degrees), shadow green at the bottom, main green, light green on top
-- * a crown of big overlapping leaf cubes tilted at a few clean angles, each
--   with a lighter highlight cap, so the outline reads lumpy and leafy
-- * a smaller second clump at the front-left (asymmetric two-lump silhouette)
-- * a handful of little red berries with dark stalk dots and a pale shine
-- * grounding: low grass tufts, two pebbles and a couple of fallen leaves
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Round Bush",
	Rarity = "Filler",
	Filler = true,
	Element = "Sunny Farm",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		-- Sunny Farm palette (CropAppleTree / DecorFarmWell)
		local LEAF_HI, LEAF_LT, LEAF, LEAF_DK = "#7be35a", "#5fd23f", "#3fb43a", "#2a8f33"
		local LEAF_SH = "#22762b"
		local RED, RED_DK, SHINE, STALK = "#e8242c", "#b8141c", "#ffd6d6", "#5a3a1a"
		local GRASS, GRASS_DK = "#5fd23f", "#3fb43a"
		local STONE_LT, STONE = "#c3c9cf", "#9aa3ad"

		local function tier(cx, cz, w, y0, y1, col, rot)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(R, v(w, h, w), cf(cx, y, cz, 0, rot, 0), col)
			B:block(R, v(w, h, w), cf(cx, y, cz, 0, rot + 45, 0), col)
		end

		------------------------------------------------------------ main clump
		local MX, MZ = 0.35, 0.25
		tier(MX, MZ, 2.8, 0, 0.7, LEAF_SH, 0)
		tier(MX, MZ, 3.7, 0.5, 2.0, LEAF_DK, 10)
		tier(MX, MZ, 3.3, 1.9, 3.0, LEAF_LT, 22)
		tier(MX, MZ, 2.2, 2.9, 3.7, LEAF_HI, 5)

		-- leaf cubes tilted at clean angles, each with a light cap on its top face
		local function leaf(x, y, z, s, rx, ry, rz, col, cap)
			local c = CFrame.new(x, y, z) * CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz))
			B:block(R, v(s, s, s), c, col)
			if cap then
				B:block(R, v(s * 0.7, 0.14, s * 0.7), c * CFrame.new(0, s / 2 + 0.05, 0), cap)
			end
		end
		local cubes = {
			-- x, y, z, size, rx, ry, rz, colour, cap
			{ MX + 1.75, 1.35, MZ - 0.55, 1.5, 15, 30, -15, LEAF, LEAF_LT },
			{ MX + 1.2, 1.5, MZ + 1.45, 1.4, -15, 15, -15, LEAF_DK, LEAF },
			{ MX - 1.3, 1.6, MZ + 1.25, 1.5, -15, -30, 15, LEAF, LEAF_LT },
			{ MX - 1.75, 1.3, MZ - 0.4, 1.3, 15, 45, 15, LEAF_DK, LEAF },
			{ MX + 0.4, 1.4, MZ - 1.8, 1.4, 15, -15, 0, LEAF, LEAF_LT },
			{ MX + 1.25, 2.7, MZ - 0.4, 1.3, 0, 30, -15, LEAF, LEAF_LT },
			{ MX - 0.9, 2.85, MZ + 0.6, 1.3, 15, 15, 15, LEAF, LEAF_LT },
			{ MX + 0.1, 2.75, MZ - 1.0, 1.2, 15, 60, 0, LEAF_LT, LEAF_HI },
			{ MX + 0.35, 3.75, MZ + 0.2, 1.3, 0, 15, 15, LEAF_LT, LEAF_HI },
			{ MX - 0.5, 3.55, MZ - 0.45, 1.0, 15, 40, 0, LEAF, LEAF_LT },
			{ MX + 0.4, 2.8, MZ + 1.2, 1.1, -15, 45, 0, LEAF, LEAF_LT },
		}
		for _, c in cubes do
			leaf(c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9])
		end

		------------------------------------------------------------ small clump
		local SX, SZ = -1.85, -1.35
		tier(SX, SZ, 1.6, 0, 0.6, LEAF_SH, 20)
		tier(SX, SZ, 1.9, 0.4, 1.3, LEAF_DK, 5)
		leaf(SX + 0.15, 1.4, SZ - 0.1, 1.2, 15, 30, -15, LEAF, LEAF_LT)
		leaf(SX - 0.55, 1.0, SZ + 0.4, 0.9, -15, 15, 15, LEAF_DK, LEAF)

		------------------------------------------------------------ berries
		local function berry(x, y, z, col)
			B:block(R, v(0.5, 0.48, 0.5), cf(x, y, z, 0, 45, 0), col)
			B:block(R, v(0.12, 0.14, 0.12), cf(x, y + 0.29, z), STALK)
			B:block(R, v(0.1, 0.1, 0.06), cf(x - 0.12, y + 0.1, z - 0.24, 0, 45, 0), SHINE)
		end
		berry(MX + 2.3, 1.75, MZ - 0.15, RED)
		berry(MX - 0.55, 2.3, MZ - 1.85, RED_DK)
		berry(MX - 2.05, 2.05, MZ + 0.55, RED)
		berry(MX + 1.2, 2.25, MZ + 1.95, RED_DK)
		berry(MX + 1.7, 3.15, MZ - 1.05, RED)
		berry(SX - 0.3, 1.55, SZ - 0.75, RED)

		------------------------------------------------------------ grounding
		local function tuft(x, z, h, ry)
			local base = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(ry), 0)
			B:block(R, v(0.32, h, 0.32), base * CFrame.new(0, h / 2, 0), GRASS)
			B:block(R, v(0.28, h * 0.75, 0.28), base * CFrame.new(0.28, h * 0.36, 0.05) * CFrame.Angles(0, 0, math.rad(-20)), GRASS_DK)
			B:block(R, v(0.28, h * 0.65, 0.28), base * CFrame.new(-0.26, h * 0.32, -0.05) * CFrame.Angles(0, 0, math.rad(22)), GRASS)
		end
		tuft(2.45, -1.55, 0.8, 20)
		tuft(-2.6, 0.9, 0.7, -35)
		tuft(0.4, 2.55, 0.6, 60)
		B:block(R, v(0.55, 0.22, 0.45), cf(-0.35, 0.11, -2.25, 0, 25, 0), STONE)
		B:block(R, v(0.35, 0.16, 0.3), cf(2.3, 0.08, 1.75, 0, -15, 0), STONE_LT)
		-- fallen leaves
		B:block(R, v(0.5, 0.08, 0.3), cf(1.6, 0.04, -2.25, 0, 30, 0), LEAF_LT)
		B:block(R, v(0.45, 0.08, 0.28), cf(-2.75, 0.04, -0.3, 0, -45, 0), LEAF)
	end,
}
