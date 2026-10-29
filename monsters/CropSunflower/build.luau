--!nocheck
-- Sunflower (Crop #8, Cosmic): a tall majestic sunflower on a stepped soil
-- mound. Thick stepped green stem with darker node rings and big stepped
-- leaves (two-part blades that droop at the tip, lime midribs). A huge flower
-- head faces forward and slightly up: a stepped round dark-brown seed disc with
-- a checker of brown shades, a glowing golden neon centre ring, ringed by two
-- layers of block petals (golden back layer, bright yellow two-step front
-- petals) over green bracts. A smaller half-open bud on a side branch.
-- Cosmic bling: neon gold centre ring + petal-tip studs, a soft warm light,
-- gold sparkles + glow, and a few floating petal / seed cubes.
-- Static prop: no motion.
return {
	DisplayName = "Sunflower",
	Rarity = "Cosmic",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		-- palette
		local YEL, YEL_LT, GOLD, GOLD_DK = "#ffd60a", "#fff15a", "#ffa412", "#e07800"
		local DISC, DISC_MID, DISC_LT, DISC_C = "#3a1d0c", "#6e3a15", "#8f5420", "#7a6a1a"
		local NEON_GOLD = "#ffcf33"
		local STEM, STEM_DK, STEM_LT = "#2fa83e", "#1b7330", "#7fd650"
		local LEAF, LEAF_DK, LEAF_LT, LIME = "#26a845", "#167a34", "#4cc957", "#b6f05a"
		local DIRT, DIRT_DK, DIRT_LT = "#7c4a28", "#5a331b", "#9a6438"
		local NEON = { mat = "Neon", name = "Glow" }

		------------------------------------------------------------------
		-- Soil mound (own bone so the game can remove it)
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(6.0, 0.45, 4.6), cf(0, 0.22, 0.3), DIRT_DK, S)
		B:block(soil, v(4.6, 0.45, 6.0), cf(0, 0.22, 0.3), DIRT_DK, S)
		B:block(soil, v(4.6, 0.4, 3.4), cf(0, 0.62, 0.3), DIRT, S)
		B:block(soil, v(3.4, 0.4, 4.6), cf(0, 0.62, 0.3), DIRT, S)
		B:block(soil, v(2.6, 0.2, 2.6), cf(0, 0.9, 0.5), DIRT_LT, S)
		B:block(soil, v(0.6, 0.35, 0.6), cf(2.1, 0.6, -1.5), DIRT_DK, S)
		B:block(soil, v(0.5, 0.3, 0.5), cf(-2.2, 0.55, 1.6), DIRT_LT, S)
		B:block(soil, v(0.45, 0.3, 0.45), cf(-1.3, 0.9, -1.1), DIRT_DK, S)
		B:block(soil, v(0.5, 0.3, 0.4), cf(2.5, 0.5, 1.4), "#a9a39a", S)

		------------------------------------------------------------------
		-- Stem: stepped segments with node rings
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, 0.9, 0.5))
		local SEGS = { -- {x, z, y0, y1, width}
			{ 0.0, 0.6, 0.8, 3.3, 1.4 },
			{ 0.1, 0.65, 3.2, 5.7, 1.3 },
			{ 0.0, 0.75, 5.6, 8.1, 1.2 },
			{ -0.05, 0.9, 8.0, 9.6, 1.1 },
		}
		for i, sg in SEGS do
			local h, y = sg[4] - sg[3], (sg[3] + sg[4]) / 2
			B:block(crop, v(sg[5], h, sg[5]), cf(sg[1], y, sg[2]), STEM)
			B:block(crop, v(0.35, h - 0.3, 0.12), cf(sg[1] - 0.2, y, sg[2] - sg[5] / 2 - 0.04), STEM_LT) -- lit strip
			if i < #SEGS then
				B:block(crop, v(sg[5] + 0.3, 0.4, sg[5] + 0.3), cf(sg[1], sg[4], sg[2]), STEM_DK) -- node ring
			end
		end

		------------------------------------------------------------------
		-- Big stepped leaves: inner blade rises, outer blade droops
		------------------------------------------------------------------
		local function leaf(base, a, s, lift)
			local f = CFrame.new(base) * CFrame.Angles(0, -rad(a), 0) * CFrame.Angles(rad(lift), 0, 0)
			B:block(crop, v(0.5, 0.4, 1.2 * s), f * CFrame.new(0, 0, -0.5 * s), STEM_DK) -- petiole
			local rows1 = { { 1.6, 0.8 }, { 2.6, 0.9 }, { 3.0, 1.0 } }
			local z = -1.0 * s
			for i, r in rows1 do
				B:block(crop, v(r[1] * s, 0.4, r[2] * s + 0.05), f * CFrame.new(0, 0, z - r[2] * s / 2), i == 2 and LEAF_LT or LEAF)
				z -= r[2] * s
			end
			B:block(crop, v(0.3, 0.12, 2.6 * s), f * CFrame.new(0, 0.24, -2.4 * s), LIME) -- midrib
			local f2 = f * CFrame.new(0, 0, z) * CFrame.Angles(-rad(lift + 28), 0, 0)
			local rows2 = { { 2.5, 0.9 }, { 1.7, 0.8 }, { 0.8, 0.7 } }
			z = 0
			for i, r in rows2 do
				B:block(crop, v(r[1] * s, 0.4, r[2] * s + 0.05), f2 * CFrame.new(0, 0, z - r[2] * s / 2), i == 1 and LEAF or LEAF_DK)
				z -= r[2] * s
			end
		end
		leaf(v(-0.6, 2.5, 0.6), 265, 1.15, 22)
		leaf(v(0.6, 3.5, 0.65), 80, 1.1, 22)
		leaf(v(0.5, 5.9, 0.8), 120, 0.9, 26)
		leaf(v(-0.4, 7.0, 0.9), 215, 0.8, 30)

		------------------------------------------------------------------
		-- Flower head: faces -Z, tilted 15 deg up. Local XY = disc plane.
		------------------------------------------------------------------
		local C = v(0, 8.8, -0.45)
		local F = CFrame.new(C) * CFrame.Angles(rad(15), 0, 0)
		local function at(x, y, z) return F * CFrame.new(x, y, z) end
		local function radial(theta, r, z) return F * CFrame.Angles(0, 0, rad(theta)) * CFrame.new(0, r, z) end
		-- green calyx back (stepped dish) + bracts
		B:block(crop, v(4.8, 3.6, 0.6), at(0, 0, 0.55), STEM_DK)
		B:block(crop, v(3.6, 4.8, 0.6), at(0, 0, 0.55), STEM_DK)
		B:block(crop, v(3.6, 2.6, 0.6), at(0, 0, 1.05), STEM)
		B:block(crop, v(2.6, 3.6, 0.6), at(0, 0, 1.05), STEM)
		B:block(crop, v(1.8, 1.8, 0.5), at(0, 0, 1.5), STEM_DK)
		for i = 0, 7 do
			B:block(crop, v(0.9, 1.4, 0.35), radial(i * 45 + 22.5, 3.7, 0.5), LEAF)
		end
		-- back petal layer (golden), offset half a step
		for i = 0, 15 do
			B:block(crop, v(1.15, 2.6, 0.45), radial(i * 22.5 + 11.25, 3.55, 0.2), i % 2 == 0 and GOLD or GOLD_DK)
		end
		-- front petal layer (bright yellow, two stepped blocks each)
		for i = 0, 15 do
			local th = i * 22.5
			B:block(crop, v(1.25, 1.9, 0.5), radial(th, 3.1, -0.1), YEL)
			B:block(crop, v(0.75, 1.2, 0.5), radial(th, 4.55, -0.08), i % 2 == 0 and YEL_LT or YEL)
			if i % 2 == 0 then
				B:block(crop, v(0.3, 0.3, 0.12), radial(th, 4.85, -0.37), NEON_GOLD, NEON) -- glowing tip stud
			end
		end
		-- seed disc: stepped round base + raised dome + checker tiles
		B:block(crop, v(4.6, 3.2, 0.7), at(0, 0, -0.15), DISC)
		B:block(crop, v(3.2, 4.6, 0.7), at(0, 0, -0.15), DISC)
		B:block(crop, v(4.0, 4.0, 0.7), at(0, 0, -0.15), DISC)
		B:block(crop, v(3.2, 2.2, 0.3), at(0, 0, -0.6), DISC_MID)
		B:block(crop, v(2.2, 3.2, 0.3), at(0, 0, -0.6), DISC_MID)
		for i = -2, 2 do
			for j = -2, 2 do
				local x, y = i * 0.8, j * 0.8
				if math.abs(i) + math.abs(j) <= 3 and (i + j) % 2 ~= 0 then
					local inDome = (math.abs(x) <= 1.6 and math.abs(y) <= 1.1) or (math.abs(x) <= 1.1 and math.abs(y) <= 1.6)
					if inDome then
						B:block(crop, v(0.75, 0.75, 0.16), at(x, y, -0.76), DISC)
					else
						B:block(crop, v(0.75, 0.75, 0.16), at(x, y, -0.54), DISC_LT)
					end
				end
			end
		end
		-- glowing golden centre ring + olive centre
		B:block(crop, v(0.9, 0.9, 0.3), at(0, 0, -0.85), DISC_C)
		for i = 0, 7 do
			B:block(crop, v(0.4, 0.4, 0.2), radial(i * 45, 1.2, -0.85), NEON_GOLD, NEON)
		end

		------------------------------------------------------------------
		-- Second smaller bud on a side branch (half open)
		------------------------------------------------------------------
		local bud = v(-3.6, 4.8, -0.4)
		B:beam(crop, v(-0.3, 4.0, 0.7), bud + v(0.5, -0.3, 0.5), 0.55, 0.55, STEM)
		local Fb = CFrame.new(bud) * CFrame.Angles(0, rad(30), 0) * CFrame.Angles(rad(20), 0, 0)
		B:block(crop, v(1.8, 1.3, 0.7), Fb * CFrame.new(0, 0, 0.35), STEM_DK)
		B:block(crop, v(1.3, 1.8, 0.7), Fb * CFrame.new(0, 0, 0.35), STEM_DK)
		for i = 0, 7 do
			B:block(crop, v(0.55, 0.8, 0.3), Fb * CFrame.Angles(0, 0, rad(i * 45)) * CFrame.new(0, 1.0, 0.0), i % 2 == 0 and YEL or GOLD)
		end
		B:block(crop, v(1.2, 0.9, 0.3), Fb * CFrame.new(0, 0, -0.1), DISC)
		B:block(crop, v(0.9, 1.2, 0.3), Fb * CFrame.new(0, 0, -0.1), DISC)
		B:block(crop, v(0.4, 0.4, 0.2), Fb * CFrame.new(0, 0, -0.3), DISC_MID)

		------------------------------------------------------------------
		-- Cosmic bling: floating petal / seed cubes, fallen petals, FX
		------------------------------------------------------------------
		local FLOAT = {
			{ 4.9, 11.6, -0.8, YEL, 0.55, 20 }, { -5.0, 12.4, 0.3, GOLD, 0.5, -25 }, { 3.6, 13.3, 1.2, YEL_LT, 0.4, 40 },
			{ -4.4, 9.4, -1.6, DISC_MID, 0.4, 30 }, { 5.2, 8.4, 0.6, DISC, 0.35, -15 },
		}
		for _, fl in FLOAT do
			B:block(crop, v(fl[5], fl[5], fl[5]), cf(fl[1], fl[2], fl[3], fl[6], fl[6], 0), fl[4])
		end
		B:block(crop, v(0.6, 0.12, 0.35), cf(1.7, 0.92, -1.1, 0, 30, 0), YEL)
		B:block(crop, v(0.55, 0.12, 0.3), cf(-1.5, 0.92, -0.5, 0, -20, 0), GOLD)

		local fx = B:block(crop, v(8, 8, 1), at(0, 0, 0), YEL, { tr = 1, name = "SparkleFX" })
		B:emitter(fx, "sparkle", { name = "GoldSparkle", color = { NEON_GOLD, "#ffffff" }, rate = 6 })
		B:emitter(fx, "glow", { name = "WarmGlow", color = "#ffc24a", rate = 1.2 })
		local core = B:block(crop, v(1, 1, 1), at(0, 0, -1.2), YEL, { tr = 1, name = "CoreLight" })
		B:light(core, { color = "#ffcf66", brightness = 1.2, range = 12, name = "SunLight" })
	end,
}
