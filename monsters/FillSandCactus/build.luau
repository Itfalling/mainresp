--!nocheck
-- Little Cactus (Sandy Savanna filler, v2).
-- A small stepped saguaro with one upturned arm, built like the Date Cactus
-- crop at scatter size, on a low pixel-round golden sand patch:
-- * ribbed trunk columns (a square block plus a darker 45-degree block so
--   the corners read as ribs) stepping narrower toward a light crown, with
--   light growth bands at the steps and cream spine cubes on the rib edges
-- * one arm: a ribbed horizontal stub, an inner-elbow fillet and an
--   upturned ribbed forearm with its own light crown and a pink bud
-- * a small pink cactus flower (cupped petals, yellow centre) on top
-- * a layered sandstone rock, pebbles and a dry grass tuft on the patch
-- Lightweight scenery meant to be copy-pasted many times: anchored,
-- weld-free, no scripts or effects.
return {
	DisplayName = "Little Cactus",
	Rarity = "Filler",
	Filler = true,
	Element = "Sandy Savanna",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Sandy Savanna: SandDateCactus)
		local SAND_DK, SAND_DK2, SAND, SAND_LT, SAND_TOP = "#c48a45", "#b77d3c", "#d9a95c", "#e8c27a", "#f0d08e"
		local ROCK, ROCK_DK, ROCK_LT = "#cf9358", "#a8703f", "#e6b27a"
		local GRASS, GRASS_DK, GRASS_LT = "#d9b84a", "#b8963a", "#f0d872"
		local PEBBLE, PEBBLE_DK = "#bfae94", "#968670"
		local CAC_DK, CAC, CAC_LT, CAC_TOP = "#428a3a", "#5aa848", "#7cc35a", "#9ad66c"
		local SPINE = "#fbefcc"
		local PETAL, PETAL_DK, PETAL_LT, CENTER = "#ff7fb4", "#e4528f", "#ffc6de", "#ffe066"

		------------------------------------------------------------ footing
		B:block(R, v(3.8, 0.2, 2.4), cf(0.3, 0.1, 0), SAND_DK)
		B:block(R, v(2.4, 0.19, 3.6), cf(0.3, 0.095, 0), SAND_DK)
		B:block(R, v(3.2, 0.18, 3.2), cf(0.3, 0.09, 0, 0, 45, 0), SAND_DK2)
		B:block(R, v(2.2, 0.14, 1.6), cf(0.1, 0.25, 0.3, 0, 15, 0), SAND)
		B:block(R, v(1.2, 0.12, 0.9), cf(1.2, 0.24, -0.8, 0, -20, 0), SAND_LT)
		B:block(R, v(0.6, 0.08, 0.5), cf(-0.9, 0.32, -0.7, 0, 30, 0), SAND_TOP)
		-- layered sandstone rock (back-left)
		local rc = CFrame.new(-1.25, 0.18, 0.75) * ang(0, 25, 0)
		B:block(R, v(0.95, 0.22, 0.8), rc * CFrame.new(0, 0.11, 0), ROCK_DK)
		B:block(R, v(0.85, 0.45, 0.7), rc * CFrame.new(0, 0.42, 0), ROCK)
		B:block(R, v(0.6, 0.28, 0.5), rc * CFrame.new(0.08, 0.76, -0.03) * ang(0, 14, 0), ROCK_LT)
		-- pebbles + a dry tuft
		B:block(R, v(0.4, 0.3, 0.35), cf(1.75, 0.28, 0.6, 0, 40, 0), PEBBLE)
		B:block(R, v(0.3, 0.22, 0.28), cf(-0.6, 0.25, -1.3, 0, 15, 0), PEBBLE_DK)
		local tb = CFrame.new(1.5, 0.22, -1.05) * ang(0, 30, 0)
		B:block(R, v(0.24, 0.95, 0.24), tb * CFrame.new(0, 0.42, 0), GRASS)
		B:block(R, v(0.22, 0.75, 0.22), tb * CFrame.new(0.2, 0.32, 0) * ang(0, 0, -25), GRASS_LT)
		B:block(R, v(0.22, 0.7, 0.22), tb * CFrame.new(-0.2, 0.3, 0.04) * ang(0, 0, 25), GRASS_DK)

		------------------------------------------------------------ cactus
		-- ribbed column: square block + darker 45-degree block + spine rows
		local function column(x, z, y0, y1, w, rows)
			local h = y1 - y0
			local c = CFrame.new(x, (y0 + y1) / 2, z)
			B:block(R, v(w, h, w), c, CAC)
			local s = w * 0.86
			B:block(R, v(s, h + 0.04, s), c * ang(0, 45, 0), CAC_DK)
			for r = 1, #rows do
				local y = y0 + h * rows[r][1]
				local off = rows[r][2]
				for _, k in rows[r][3] do
					local a = rad(off + k * 90)
					local d = (off == 45) and (w / math.sqrt(2) + 0.05) or (s / math.sqrt(2) + 0.05)
					B:block(R, v(0.18, 0.18, 0.18), CFrame.new(x + math.sin(a) * d, y, z - math.cos(a) * d) * ang(0, -math.deg(a), 0), SPINE)
				end
			end
		end
		-- trunk steps narrower toward the top
		column(0, 0, 0.25, 2.9, 1.5, { { 0.22, 0, { 0, 1, 2, 3 } }, { 0.5, 45, { 0, 1, 2, 3 } }, { 0.8, 0, { 0, 1, 2, 3 } } })
		column(0, 0, 2.85, 4.6, 1.35, { { 0.3, 45, { 0, 1, 2, 3 } }, { 0.72, 0, { 0, 1, 2, 3 } } })
		column(0, 0, 4.55, 5.55, 1.2, { { 0.45, 45, { 0, 1, 2, 3 } } })
		B:block(R, v(1.0, 0.35, 1.0), cf(0, 5.7, 0), CAC_LT)
		B:block(R, v(0.85, 0.37, 0.85), cf(0, 5.7, 0, 0, 45, 0), CAC)
		B:block(R, v(0.65, 0.22, 0.65), cf(0, 5.95, 0), CAC_TOP)
		-- light growth bands where the trunk steps in
		B:block(R, v(1.42, 0.2, 1.42), cf(0, 2.9, 0), CAC_LT)
		B:block(R, v(1.27, 0.2, 1.27), cf(0, 4.6, 0), CAC_LT)
		-- base collar (shadow) where the trunk meets the sand
		B:block(R, v(1.65, 0.25, 1.65), cf(0, 0.38, 0, 0, 22.5, 0), CAC_DK)

		------------------------------------------------------------ arm
		local aw = 0.85
		local yOut, reach, yTop = 2.05, 1.8, 3.95
		B:block(R, v(reach - 0.3, aw, aw), cf(0.6 + (reach - 0.6) / 2, yOut, 0), CAC)
		B:block(R, v(reach - 0.75, aw * 0.86, aw * 0.86), cf(0.62 + (reach - 0.95) / 2, yOut, 0, 45, 0, 0), CAC_DK)
		column(reach, 0, yOut - aw / 2, yTop, aw, { { 0.35, 0, { 0, 1, 2 } }, { 0.75, 45, { 0, 1, 2, 3 } } })
		-- fillet in the inner elbow so the arm curves up
		B:block(R, v(aw * 0.7, aw * 0.7, aw * 0.9), cf(reach - aw * 0.48, yOut + aw * 0.45, 0, 0, 0, 45), CAC)
		B:block(R, v(aw * 0.75, 0.3, aw * 0.75), cf(reach, yTop + 0.13, 0), CAC_LT)
		B:block(R, v(aw * 0.45, 0.22, aw * 0.45), cf(reach, yTop + 0.36, 0), CAC_TOP)
		-- small closed bud on the arm
		B:block(R, v(0.4, 0.42, 0.4), cf(reach, yTop + 0.65, 0, 0, 20, 0), PETAL_DK)
		B:block(R, v(0.28, 0.28, 0.28), cf(reach, yTop + 0.92, 0, 0, 65, 0), PETAL)

		------------------------------------------------------------ flower
		local F = CFrame.new(0, 6.15, 0) * ang(0, 15, 0)
		B:block(R, v(0.9, 0.2, 0.9), F, CAC_LT)
		for k = 0, 5 do
			local G = F * ang(0, k * 60, 0)
			local outer = k % 2 == 0
			B:block(R, v(0.65, 0.18, 0.8), G * CFrame.new(0, 0.16, -0.5) * ang(outer and 18 or 30, 0, 0), outer and PETAL or PETAL_LT)
		end
		B:block(R, v(0.65, 0.2, 0.65), F * CFrame.new(0, 0.2, 0) * ang(0, 45, 0), PETAL_DK)
		B:block(R, v(0.36, 0.2, 0.36), F * CFrame.new(0, 0.34, 0), CENTER)
	end,
}
