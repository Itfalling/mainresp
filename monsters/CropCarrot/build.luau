--!nocheck
-- Carrot (Crop #1, Common): a classic cartoon carrot, half pulled out of a
-- small tilled soil mound and leaning slightly, its pointy tip still in the
-- dirt. Bright orange root that tapers in clear steps from the shoulder to the
-- tip (plus-shaped cross-sections read round), 3 thin darker ring lines, a
-- light orange highlight, and a tall bushy fan of stepped leaf fronds with
-- lime tips. A baby carrot top peeks out beside it. Static prop: no motion.
return {
	DisplayName = "Carrot",
	Rarity = "Common",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		-- palette
		local OR, ORD, ORL, ORT = "#ff8a14", "#dc5a08", "#ffa328", "#ffa030" -- main / rings+tip / highlight / shoulder
		local LEAF, LEAFD, LEAFL, LEAFL2 = "#2cb84c", "#167a3c", "#b6f03c", "#5fd640" -- leaf main / deep / lime / light
		local STEM = "#3c8f2c"
		local DIRT, DIRTD, DIRTL = "#83502b", "#5a331b", "#a8703f"
		local PEBBLE = "#a9a39a"

		-- plus-shaped slab (two crossed blocks) centred on the frame `f`
		local function plus(bone, f, w, inset, y0, y1, col, opts)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(bone, v(w, h, math.max(w - inset, 0.2)), f * CFrame.new(0, y, 0), col, opts)
			B:block(bone, v(math.max(w - inset, 0.2), h, w), f * CFrame.new(0, y, 0), col, opts)
		end

		------------------------------------------------------------------
		-- Soil mound (own bone so the game can remove it)
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local O = CFrame.new()
		plus(soil, O, 3.6, 0.82, 0, 0.28, DIRTD, S)
		plus(soil, O, 2.8, 0.8, 0.28, 0.5, DIRT, S)
		plus(soil, CFrame.new(0.4, 0, 0), 1.3, 0.4, 0.5, 0.6, DIRTL, S) -- loosened dirt round the pulled carrot
		B:block(soil, v(0.5, 0.3, 0.5), cf(1.15, 0.55, -0.95), DIRTD, S)
		B:block(soil, v(0.42, 0.28, 0.42), cf(-1.35, 0.42, 0.85), DIRTL, S)
		B:block(soil, v(0.38, 0.24, 0.38), cf(-0.6, 0.58, -1.05), DIRTD, S)
		B:block(soil, v(0.32, 0.2, 0.32), cf(1.05, 0.66, 0.55), DIRTD, S)
		B:block(soil, v(0.42, 0.3, 0.38), cf(-1.6, 0.45, -0.55), PEBBLE, S)
		B:block(soil, v(0.24, 0.16, 0.24), cf(-1.5, 0.66, -0.4), "#cfc9be", S)

		------------------------------------------------------------------
		-- Carrot root, built along its own leaning axis (tip at local y=0)
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, 0.6, 0))
		local base = CFrame.new(0.45, 0.4, 0) * CFrame.Angles(0, 0, math.rad(14)) -- top leans toward -X
		plus(crop, base, 0.42, 0.0, 0.0, 0.3, ORD) -- pointy tip in the dirt
		plus(crop, base, 0.72, 0.3, 0.3, 0.72, OR)
		plus(crop, base, 1.02, 0.36, 0.72, 1.2, OR)
		plus(crop, base, 1.3, 0.4, 1.2, 1.7, OR)
		plus(crop, base, 1.55, 0.44, 1.7, 2.2, OR)
		plus(crop, base, 1.72, 0.5, 2.2, 2.6, OR) -- shoulder
		plus(crop, base, 1.42, 0.44, 2.6, 2.76, ORT) -- rounded shoulder cap
		plus(crop, base, 0.82, 0.24, 2.76, 2.86, ORD) -- crown where the leaves sprout
		-- three thin darker ring lines
		plus(crop, base, 1.08, 0.36, 0.94, 1.02, ORD)
		plus(crop, base, 1.36, 0.4, 1.46, 1.54, ORD)
		plus(crop, base, 1.61, 0.44, 1.96, 2.04, ORD)
		-- light highlight: a stepped strip down the front, catching the light
		B:block(crop, v(0.5, 0.4, 0.14), base * CFrame.new(0.28, 2.4, -0.86), ORL)
		B:block(crop, v(0.45, 0.42, 0.14), base * CFrame.new(0.24, 1.86, -0.78), ORL)
		B:block(crop, v(0.36, 0.36, 0.14), base * CFrame.new(0.2, 1.32, -0.65), ORL)
		B:block(crop, v(0.16, 0.16, 0.06), base * CFrame.new(0.38, 2.48, -0.95), "#fff0c8") -- tiny shine square

		------------------------------------------------------------------
		-- Leafy top: a tall bushy fan of stepped zig-zag fronds
		------------------------------------------------------------------
		local top = base * CFrame.new(0, 2.8, 0)
		plus(crop, top, 0.7, 0.24, 0.0, 0.3, STEM)
		local function frond(x, z, rx, rz, s, col, dark)
			local f = top * CFrame.new(x, 0.15, z) * CFrame.Angles(math.rad(rx), 0, math.rad(rz))
			local function at(lx, ly)
				return f * CFrame.new(lx * s, ly * s, 0)
			end
			B:block(crop, v(0.22, 1.5 * s, 0.22), at(0, 0.75), STEM)
			B:block(crop, v(0.8 * s, 0.36 * s, 0.46), at(0.18, 0.5), dark)
			B:block(crop, v(0.82 * s, 0.36 * s, 0.46), at(-0.18, 0.86), col)
			B:block(crop, v(0.7 * s, 0.32 * s, 0.44), at(0.16, 1.2), col)
			B:block(crop, v(0.5 * s, 0.26 * s, 0.4), at(-0.1, 1.48), LEAFL)
			B:block(crop, v(0.34, 0.28 * s, 0.34), at(0.02, 1.74), LEAFL2)
		end
		-- the fan is set slightly upright against the root's lean
		frond(0, 0, 0, -8, 0.93, LEAF, LEAFD) -- tall centre
		frond(0.2, 0, 0, -36, 0.88, LEAF, LEAFD) -- right
		frond(-0.2, 0, 0, 22, 0.88, LEAF, LEAFD) -- left
		frond(0.15, -0.2, -24, -20, 0.84, LEAFL2, LEAF) -- front right
		frond(-0.15, -0.2, -24, 6, 0.82, LEAFL2, LEAF) -- front left
		frond(0.15, 0.22, 26, -24, 0.86, LEAFD, LEAF) -- back right
		frond(-0.15, 0.22, 26, 8, 0.84, LEAFD, LEAF) -- back left

		------------------------------------------------------------------
		-- Baby carrot top peeking out of the soil beside it
		------------------------------------------------------------------
		B:block(crop, v(0.55, 0.26, 0.55), cf(-0.95, 0.58, 0.85), OR)
		B:block(crop, v(0.36, 0.1, 0.36), cf(-0.95, 0.75, 0.85), ORT)
		B:block(crop, v(0.16, 0.5, 0.16), cf(-0.95, 1.02, 0.85), STEM)
		B:block(crop, v(0.45, 0.3, 0.3), cf(-0.87, 1.16, 0.85), LEAF)
		B:block(crop, v(0.4, 0.28, 0.3), cf(-1.03, 1.4, 0.85), LEAFL2)
		B:block(crop, v(0.24, 0.22, 0.24), cf(-0.95, 1.62, 0.85), LEAFL)
	end,
}
