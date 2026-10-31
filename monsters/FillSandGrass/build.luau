--!nocheck
-- Dry Grass Tuft (Sandy Savanna filler, v2).
-- Three clustered tufts of dry savanna grass (big, medium, small) on a low
-- pixel-round golden sand patch with pebbles. Every blade is two segments:
-- a darker straw base and a lighter upper half that bends outward (pale
-- tips = highlight), so each tuft shades from dark at the root to bright at
-- the tips; the big and medium tufts carry tall stalks with stepped
-- golden-orange seed heads.
-- Lightweight scenery meant to be copy-pasted many times: anchored,
-- weld-free, no scripts or effects.
return {
	DisplayName = "Dry Grass Tuft",
	Rarity = "Filler",
	Filler = true,
	Element = "Sandy Savanna",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		-- palette (Sandy Savanna crops: SandDateCactus / SandPricklyPear)
		local SAND_DK, SAND_DK2, SAND, SAND_LT, SAND_TOP = "#c48a45", "#b77d3c", "#d9a95c", "#e8c27a", "#f0d08e"
		local GRASS, GRASS_DK, GRASS_LT = "#d9b84a", "#b8963a", "#f0d872"
		local PEBBLE, PEBBLE_DK = "#bfae94", "#968670"
		local SEED, SEED_LT = "#e8a33c", "#ffc35a" -- date-stalk orange + date gold (SandDateCactus)

		local function bar(a, b, w, h, col, ext)
			local c, len = P.aim(a, b)
			ext = ext or 0.1
			B:block(R, v(w, h, len + 2 * ext), c, col)
			return c, len
		end

		------------------------------------------------------------ footing
		B:block(R, v(3.8, 0.2, 2.4), cf(0.1, 0.1, 0), SAND_DK)
		B:block(R, v(2.4, 0.19, 3.6), cf(0.1, 0.095, 0), SAND_DK)
		B:block(R, v(3.2, 0.18, 3.2), cf(0.1, 0.09, 0, 0, 45, 0), SAND_DK2)
		B:block(R, v(2.4, 0.14, 1.6), cf(-0.2, 0.25, 0.2, 0, 15, 0), SAND)
		B:block(R, v(1.3, 0.12, 1.0), cf(0.7, 0.24, -0.6, 0, -20, 0), SAND_LT)
		B:block(R, v(0.7, 0.08, 0.5), cf(-0.6, 0.34, 0.4, 0, 30, 0), SAND_TOP)
		-- pebbles
		B:block(R, v(0.5, 0.35, 0.45), cf(1.45, 0.3, 0.7, 0, 40, 0), PEBBLE)
		B:block(R, v(0.3, 0.15, 0.28), cf(1.47, 0.52, 0.68, 0, 65, 0), SAND_TOP)
		B:block(R, v(0.4, 0.3, 0.35), cf(-1.4, 0.26, -0.7, 0, 15, 0), PEBBLE_DK)

		------------------------------------------------------------ tufts
		-- one blade: base segment (dark) rising to a knee, tip segment (light)
		-- bending outward
		local function blade(base, a, knee, kh, tipR, tipH, w, colA, colB)
			local dir = v(math.sin(rad(a)), 0, -math.cos(rad(a)))
			local p0 = base + dir * 0.08
			local p1 = base + dir * knee + v(0, kh, 0)
			local p2 = base + dir * tipR + v(0, tipH, 0)
			bar(p0, p1, w, w, colA, 0.08)
			bar(p1, p2, w * 0.85, w * 0.85, colB, 0.06)
		end
		local function stalk(base, a, r, h)
			local dir = v(math.sin(rad(a)), 0, -math.cos(rad(a)))
			local top = base + dir * r + v(0, h, 0)
			local c, len = bar(base, top, 0.14, 0.14, GRASS_DK, 0.05)
			-- stepped seed head: main + lighter tip
			B:block(R, v(0.3, 0.3, 0.55), c * CFrame.new(0, 0, -len / 2 + 0.12), SEED)
			B:block(R, v(0.22, 0.22, 0.35), c * CFrame.new(0, 0.04, -len / 2 - 0.22), SEED_LT)
		end
		-- base point, scale, yaw offset, blade count, stalks
		local function tuft(base, s, yo, n, stalks)
			B:block(R, v(0.6 * s, 0.25, 0.6 * s), CFrame.new(base + v(0, 0.12, 0)) * CFrame.Angles(0, rad(yo + 20), 0), GRASS_DK)
			for i = 1, n do
				local a = yo + (i - 1) * 360 / n + ((i % 2 == 0) and 12 or -8)
				local inner = i % 3 == 0
				if inner then
					-- steep inner blade
					blade(base, a, 0.12 * s, 1.1 * s, 0.4 * s, 2.0 * s, 0.26, GRASS_DK, GRASS)
				else
					local tall = i % 2 == 0
					blade(base, a, 0.3 * s, (tall and 1.15 or 0.85) * s, 0.85 * s, (tall and 1.6 or 1.15) * s, 0.26,
						tall and GRASS_DK or GRASS, GRASS_LT)
				end
			end
			for _, st in stalks do
				stalk(base, yo + st[1], st[2] * s, st[3] * s)
			end
		end
		tuft(v(-0.1, 0.25, 0.15), 1.25, 0, 9, { { 70, 0.3, 2.3 }, { 230, 0.25, 2.0 } })
		tuft(v(0.95, 0.25, -0.65), 0.9, 25, 7, { { 140, 0.25, 2.2 } })
		tuft(v(-1.0, 0.22, -0.55), 0.7, 50, 5, {})
	end,
}
