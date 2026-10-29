--!nocheck
-- Cabbage (Crop #2, Uncommon): a plump round cabbage head on a tilled soil
-- patch. The head is a stack of plus-shaped slabs (reads round) in fresh
-- pale lime / cream, hugged by curved stepped mint leaf shells whose tips curl
-- outward, sitting in a rosette of rounded teal leaves. Subtle light midribs,
-- a few thin violet hints on leaf edges, and tiny glowing dew drops.
-- Static prop: no motion.
return {
	DisplayName = "Cabbage",
	Rarity = "Uncommon",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		-- palette
		local HEAD, HEADL, HEADD, CREAM = "#acec6c", "#d8f89a", "#8ccf48", "#f2fbcc" -- inner head
		local MINT, MINTL, MINTD = "#7ee3a4", "#aef4c8", "#58c88a" -- wrapping leaves
		local OUT, OUTD, OUTL = "#3abb84", "#22805a", "#7ee0b0" -- outer leaves (teal, NOT grass green)
		local VIO = "#a274e6" -- a few thin violet hints on leaf edges
		local VEIN, VEIN2 = "#e8ffd8", "#b8f2cc" -- crown veins / subtle leaf midribs
		local DEW = "#dcf8ff"
		local DIRT, DIRTD, DIRTL = "#83502b", "#5a331b", "#a8703f"
		local PEBBLE = "#a9a39a"

		local function plus(bone, w, inset, y0, y1, col, opts)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(bone, v(w, h, w - inset), cf(0, y, 0), col, opts)
			B:block(bone, v(w - inset, h, w), cf(0, y, 0), col, opts)
		end

		-- round tier: three blocks (wide-thin, square, thin-wide) give a stepped circle
		local function round(bone, w, d, y0, y1, col)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(bone, v(w, h, w - 2 * d), cf(0, y, 0), col)
			B:block(bone, v(w - d, h, w - d), cf(0, y, 0), col)
			B:block(bone, v(w - 2 * d, h, w), cf(0, y, 0), col)
		end

		------------------------------------------------------------------
		-- Soil patch (own bone so the game can remove it)
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		plus(soil, 5.6, 1.4, 0, 0.35, DIRTD, S)
		plus(soil, 4.6, 1.2, 0.35, 0.6, DIRT, S)
		B:block(soil, v(0.55, 0.32, 0.5), cf(1.25, 0.62, -2.05), DIRTD, S)
		B:block(soil, v(0.45, 0.28, 0.45), cf(-2.2, 0.45, 1.3), DIRTL, S)
		B:block(soil, v(0.4, 0.25, 0.4), cf(-1.15, 0.72, -2.1), DIRTL, S)
		B:block(soil, v(0.42, 0.3, 0.4), cf(2.45, 0.45, 0.4), PEBBLE, S)
		B:block(soil, v(0.24, 0.16, 0.24), cf(2.4, 0.65, 0.55), "#cfc9be", S)

		------------------------------------------------------------------
		-- Head: a plump stepped ball, lighter toward the crown
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, 0.6, 0))
		plus(crop, 2.6, 0.8, 0.6, 1.15, HEADD)
		round(crop, 3.3, 0.45, 1.15, 1.7, HEAD)
		round(crop, 3.7, 0.5, 1.7, 3.2, HEAD)
		round(crop, 3.5, 0.5, 3.2, 3.65, HEADL)
		round(crop, 3.0, 0.45, 3.65, 4.0, HEADL)
		round(crop, 2.2, 0.35, 4.0, 4.25, HEADL)
		plus(crop, 1.3, 0.35, 4.25, 4.42, CREAM)
		-- leaf folds swirling over the crown
		B:block(crop, v(1.5, 0.1, 0.22), cf(0.15, 4.03, -1.3), VEIN)
		B:block(crop, v(0.22, 0.1, 1.4), cf(-1.3, 4.03, 0.05), VEIN)
		B:block(crop, v(1.0, 0.1, 0.2), cf(-0.1, 4.28, 0.85), VEIN)
		B:block(crop, v(0.2, 0.1, 0.9), cf(1.62, 3.68, 0.3), VEIN)

		------------------------------------------------------------------
		-- Wrapper leaves: curved stepped shells hugging the ball (narrow at
		-- the base, widest in the middle, side blocks set back to follow the
		-- ball's curve) with the tip curling outward. Darker at the bottom,
		-- lighter toward the curled edge.
		------------------------------------------------------------------
		local function wrap(a, s, T, push, hint)
			local rot = CFrame.Angles(0, math.rad(a), 0)
			local function at(x, y, z)
				return rot * CFrame.new(x, y, z + push)
			end
			B:block(crop, v(1.5 * s, 0.6, 0.4), at(0, 0.88, 1.62), OUT) -- narrow stem end
			B:block(crop, v(2.5 * s, 0.7, 0.4), at(0, 1.5, 1.98), MINTD)
			if T - 2.1 > 0.1 then
				B:block(crop, v(2.7 * s, T - 2.1, 0.4), at(0, (1.85 + T - 0.25) / 2, 2.02), MINT)
			end
			B:block(crop, v(0.45, T - 1.6, 0.4), at(1.45 * s, (1.3 + T - 0.3) / 2, 1.78), MINTD) -- sides curving back
			B:block(crop, v(0.45, T - 1.6, 0.4), at(-1.45 * s, (1.3 + T - 0.3) / 2, 1.78), MINTD)
			B:block(crop, v(2.1 * s, 0.32, 0.6), at(0, T - 0.12, 2.2), MINTL) -- tip curling outward
			B:block(crop, v(0.14, T - 1.5, 0.05), at(0, (1.3 + T - 0.2) / 2, 2.24), VEIN2) -- subtle midrib
			if hint then
				B:block(crop, v(1.6 * s, 0.07, 0.12), at(0, T + 0.07, 2.42), VIO) -- thin violet hint on the edge
			end
		end
		wrap(0, 1.0, 3.05, 0, false) -- back
		wrap(90, 1.0, 2.75, 0, true) -- right (+X)
		wrap(180, 1.0, 2.9, 0, true) -- front
		wrap(270, 1.0, 2.65, 0, false) -- left (-X)

		------------------------------------------------------------------
		-- Base rosette: rounded leaves splaying out on the soil, ends curling up
		------------------------------------------------------------------
		local function pad(a, r0, s, hint)
			local rot = CFrame.Angles(0, math.rad(a), 0)
			local function at(x, y, z)
				return rot * CFrame.new(x, y, z)
			end
			B:block(crop, v(1.3 * s, 0.3, 0.8 * s), at(0, 0.72, r0 + 0.4 * s), OUTD) -- narrow base
			B:block(crop, v(2.1 * s, 0.3, 1.0 * s), at(0, 0.76, r0 + 1.2 * s), OUT) -- wide rounded middle
			B:block(crop, v(1.5 * s, 0.3, 0.45 * s), at(0, 0.9, r0 + 1.9 * s), OUTL) -- rounded end curling up
			B:block(crop, v(0.14, 0.05, 1.5 * s), at(0, 0.93, r0 + 1.05 * s), VEIN2) -- subtle midrib
			if hint then
				B:block(crop, v(1.0 * s, 0.07, 0.12), at(0, 1.08, r0 + 2.08 * s), VIO)
			end
		end
		for i, a in { 45, 135, 225, 315 } do
			pad(a, 1.75, 1.0, i == 3)
		end
		for i, a in { 0, 90, 180, 270 } do
			pad(a, 1.75, 0.8, i == 2)
		end

		------------------------------------------------------------------
		-- Dew drops (two tiny glowing ones for Uncommon bling)
		------------------------------------------------------------------
		local dews = {
			{ 0.75, 3.5, -1.82, false },
			{ -1.85, 3.38, -0.5, true },
			{ 0.4, 1.02, -2.65, false },
			{ -2.05, 1.02, -2.05, true },
			{ -0.3, 4.53, -0.2, false },
			{ -0.8, 3.45, 1.82, false },
		}
		for _, d in dews do
			-- tiny dew glints: the two "true" ones are a touch bigger
			local sz = d[4] and 0.26 or 0.2
			B:block(crop, v(sz, sz, sz), cf(d[1], d[2], d[3]), DEW, { mat = "Neon", name = "Dew" })
		end
		local fx = B:block(crop, v(3.6, 2.5, 3.6), cf(0, 2.6, 0), HEAD, { tr = 1, name = "DewFX" })
		B:emitter(fx, "sparkle", { name = "Dew", color = { "#ffffff", "#c8f4ff" }, rate = 1.2, size = { 0.05, 0.25, 0 } })
	end,
}
