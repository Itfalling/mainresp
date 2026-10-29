--!nocheck
-- Carrot (Crop #1, Common): a big chunky carrot poking out of a small tilled
-- soil mound. Bright orange stepped root with a plus-shaped (round-reading)
-- cross-section, darker orange ring bands, a light orange highlight strip,
-- and a lush bushy leafy top of stepped leaf clumps in three greens. A tiny
-- baby carrot top peeks out of the soil beside it. Static prop: no motion.
return {
	DisplayName = "Carrot",
	Rarity = "Common",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		-- palette
		local OR, ORD, ORL, ORT = "#ff8a14", "#dc5a08", "#ffa328", "#ffa030" -- main / band+shadow / highlight / shoulder
		local LEAF, LEAFD, LEAFL, LEAFL2 = "#2cb84c", "#167a3c", "#b6f03c", "#5fd640" -- leaf main / deep / lime tips / light frond
		local STEM = "#3c8f2c"
		local DIRT, DIRTD, DIRTL = "#83502b", "#5a331b", "#a8703f"
		local PEBBLE = "#a9a39a"

		------------------------------------------------------------------
		-- Soil mound (own bone so the game can remove it): 3 stepped plus-shaped tiers
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function plus(bone, w, inset, y0, y1, col, opts)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(bone, v(w, h, w - inset), cf(0, y, 0), col, opts)
			B:block(bone, v(w - inset, h, w), cf(0, y, 0), col, opts)
		end
		plus(soil, 3.9, 0.9, 0, 0.35, DIRTD, S)
		plus(soil, 3.1, 0.8, 0.35, 0.65, DIRT, S)
		plus(soil, 1.9, 0.5, 0.65, 0.85, DIRTL, S) -- tilled lip hugging the root
		-- clods + pebble
		B:block(soil, v(0.5, 0.32, 0.5), cf(1.25, 0.6, -1.05), DIRTD, S)
		B:block(soil, v(0.4, 0.28, 0.4), cf(-1.45, 0.42, 0.95), DIRTL, S)
		B:block(soil, v(0.42, 0.26, 0.42), cf(-0.95, 0.82, -0.95), DIRTD, S)
		B:block(soil, v(0.35, 0.22, 0.35), cf(0.75, 0.86, 1.05), DIRTD, S)
		B:block(soil, v(0.42, 0.3, 0.38), cf(-1.75, 0.45, -0.65), PEBBLE, S)
		B:block(soil, v(0.24, 0.16, 0.24), cf(-1.62, 0.66, -0.5), "#cfc9be", S)

		------------------------------------------------------------------
		-- Carrot root: wide shoulders stepping down to a buried tip
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, 0.8, 0))
		plus(crop, 0.9, 0.4, 0.45, 1.05, ORD) -- tip disappearing into the soil
		plus(crop, 1.2, 0.4, 1.05, 1.55, OR)
		plus(crop, 1.5, 0.5, 1.55, 2.05, OR)
		plus(crop, 1.8, 0.5, 2.05, 2.55, OR)
		plus(crop, 2.1, 0.6, 2.55, 3.05, OR)
		plus(crop, 1.75, 0.6, 3.05, 3.25, ORT) -- rounded shoulder cap
		plus(crop, 1.0, 0.3, 3.25, 3.35, ORD) -- crown where the leaves sprout
		-- darker ring bands: thin plus-shaped slabs standing just proud of the root
		plus(crop, 1.26, 0.4, 1.24, 1.36, ORD)
		plus(crop, 1.86, 0.5, 2.24, 2.36, ORD)
		plus(crop, 2.16, 0.6, 2.76, 2.88, ORD)
		-- light highlight: a stepped strip down the lit front-right face of each tier
		B:block(crop, v(0.75, 0.5, 0.2), cf(0.3, 2.8, -1.1), ORL)
		B:block(crop, v(0.65, 0.5, 0.2), cf(0.25, 2.3, -0.95), ORL)
		B:block(crop, v(0.5, 0.5, 0.2), cf(0.2, 1.8, -0.8), ORL)
		B:block(crop, v(0.2, 0.2, 0.06), cf(0.5, 2.92, -1.21), "#fff0c8") -- tiny shine square
		B:block(crop, v(0.5, 0.06, 0.4), cf(0.4, 3.27, -0.45), "#ffe0a0") -- shine on the shoulder
		B:block(crop, v(0.1, 0.5, 0.6), cf(1.07, 2.8, -0.3), ORL) -- highlight wraps round the right side
		-- a gentle "freshly grown" twinkle (also: the previewer needs at least one effect)
		local shine = B:block(crop, v(2.0, 1.2, 2.0), cf(0, 2.6, 0), OR, { tr = 1, name = "ShineFX" })
		B:emitter(shine, "sparkle", { name = "Fresh", color = { "#ffffff", "#fff2b0" }, rate = 0.8, size = { 0.05, 0.22, 0 } })

		------------------------------------------------------------------
		-- Leafy top: a bushy fan of stepped zig-zag fronds
		------------------------------------------------------------------
		plus(crop, 0.8, 0.3, 3.3, 3.58, STEM)
		local function frond(x, z, rx, rz, s, col, dark)
			local base = CFrame.new(x, 3.45, z) * CFrame.Angles(math.rad(rx), 0, math.rad(rz))
			local function at(lx, ly)
				return base * CFrame.new(lx * s, ly * s, 0)
			end
			B:block(crop, v(0.22, 1.45 * s, 0.22), at(0, 0.72), STEM)
			B:block(crop, v(0.85 * s, 0.38 * s, 0.5), at(0.18, 0.5), dark)
			B:block(crop, v(0.8 * s, 0.38 * s, 0.48), at(-0.18, 0.88), col)
			B:block(crop, v(0.62 * s, 0.32 * s, 0.44), at(0.14, 1.22), col)
			B:block(crop, v(0.36, 0.3 * s, 0.36), at(-0.02, 1.52), LEAFL)
		end
		frond(0, 0, 0, 0, 0.92, LEAF, LEAFD) -- tall centre
		frond(0.3, 0, 0, -36, 0.86, LEAF, LEAFD) -- right
		frond(-0.3, 0, 0, 36, 0.86, LEAF, LEAFD) -- left
		frond(0.25, -0.25, -26, -14, 0.8, LEAFL2, LEAF) -- front right
		frond(-0.25, -0.25, -26, 16, 0.76, LEAFL2, LEAF) -- front left
		frond(0.2, 0.3, 28, -18, 0.84, LEAFD, LEAF) -- back right
		frond(-0.2, 0.3, 28, 18, 0.8, LEAFD, LEAF) -- back left

		------------------------------------------------------------------
		-- Baby carrot top peeking out of the soil beside it
		------------------------------------------------------------------
		B:block(crop, v(0.6, 0.28, 0.6), cf(1.3, 0.78, 0.95), OR)
		B:block(crop, v(0.38, 0.1, 0.38), cf(1.3, 0.96, 0.95), ORT)
		B:block(crop, v(0.16, 0.5, 0.16), cf(1.3, 1.25, 0.95), STEM)
		B:block(crop, v(0.45, 0.3, 0.3), cf(1.38, 1.38, 0.95), LEAF)
		B:block(crop, v(0.4, 0.28, 0.3), cf(1.2, 1.62, 0.95), LEAF)
		B:block(crop, v(0.24, 0.22, 0.24), cf(1.3, 1.85, 0.95), LEAFL)
	end,
}
