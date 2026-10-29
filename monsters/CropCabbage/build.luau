--!nocheck
-- Cabbage (Crop #2, Uncommon): a plump round cabbage head on a tilled soil
-- patch. The head is a stack of plus-shaped slabs (reads round) in fresh
-- pale lime / cream, wrapped by mint inner leaves and big teal-green outer
-- leaves that curl outward and flop over with violet-tinted rims so it pops
-- on grass. Light vein lines on the leaves and a few dew-drop highlights.
-- Static prop: no motion.
return {
	DisplayName = "Cabbage",
	Rarity = "Uncommon",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		-- palette
		local HEAD, HEADL, HEADD, CREAM = "#acec6c", "#d8f89a", "#8ccf48", "#f2fbcc" -- inner head
		local MINT, MINTL = "#7ee3a4", "#a8f2c4" -- wrapping inner leaves
		local OUT, OUTD, OUTL = "#36b07c", "#22805a", "#62d29c" -- outer leaves (teal, NOT grass green)
		local VIO, VIOD = "#a274e6", "#7650b8" -- violet-tinted leaf rims
		local VEIN = "#e8ffd8"
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
		-- leaf-seam veins on the ball's four faces (midrib + one side rib)
		for i, a in { 0, 90, 180, 270 } do
			local rot = CFrame.Angles(0, math.rad(a), 0)
			B:block(crop, v(0.16, 0.9, 0.06), rot * CFrame.new(-0.55, 3.0, 1.86), VEIN)
		end

		-- mint wrapper leaves hugging the lower ball, with curled-out lips;
		-- staggered heights so the layers read
		for i, a in { 0, 90, 180, 270 } do
			local rot = CFrame.Angles(0, math.rad(a), 0)
			local top = (i % 2 == 1) and 2.75 or 2.35
			local function at(x, y, z)
				return rot * CFrame.new(x, y, z)
			end
			B:block(crop, v(2.6, top - 0.8, 0.3), at(0, (top + 0.8) / 2, 1.92), MINT)
			B:block(crop, v(1.3, 0.45, 0.3), at(0, top + 0.22, 1.92), MINT) -- pointed leaf tip
			B:block(crop, v(1.3, 0.1, 0.34), at(0, top + 0.48, 1.92), VIO) -- violet tint on the tip
			B:block(crop, v(2.6, 0.16, 0.36), at(0, top - 0.08, 1.95), MINTL) -- lighter upper edge
			B:block(crop, v(0.16, top - 0.95, 0.06), at(0, (top + 1.25) / 2, 2.09), VEIN) -- midrib
			B:block(crop, v(0.6, 0.12, 0.06), at(0.3, top - 0.5, 2.09) * CFrame.Angles(0, 0, math.rad(35)), VEIN) -- side ribs in a V
			B:block(crop, v(0.6, 0.12, 0.06), at(-0.3, top - 0.5, 2.09) * CFrame.Angles(0, 0, math.rad(-35)), VEIN)
		end

		------------------------------------------------------------------
		-- Outer leaves: big pads splaying out on the soil, tips curling up
		-- with violet edges. 4 big (diagonal) + 4 smaller (cardinal).
		------------------------------------------------------------------
		local function pad(a, r0, s)
			local rot = CFrame.Angles(0, math.rad(a), 0)
			local function at(x, y, z)
				return rot * CFrame.new(x, y, z)
			end
			local L = 1.5 * s
			B:block(crop, v(2.2 * s, 0.35, L), at(0, 0.78, r0 + L / 2), OUT) -- flat pad
			B:block(crop, v(1.6 * s, 0.3, 0.6), at(0, 1.05, r0 + 0.2), OUTD) -- where it meets the ball
			B:block(crop, v(2.0 * s, 0.5, 0.45), at(0, 1.12, r0 + L + 0.1), OUTL) -- curled-up tip
			B:block(crop, v(2.0 * s, 0.14, 0.5), at(0, 1.42, r0 + L + 0.1), VIO) -- violet edge
			B:block(crop, v(0.16, 0.06, L), at(0, 0.98, r0 + L / 2), VEIN) -- midrib
			B:block(crop, v(0.6 * s, 0.06, 0.14), at(0.25 * s, 0.98, r0 + L * 0.62) * CFrame.Angles(0, math.rad(-35), 0), VEIN) -- side rib
		end
		for _, a in { 45, 135, 225, 315 } do
			pad(a, 1.75, 1.0)
		end
		for _, a in { 0, 90, 180, 270 } do
			pad(a, 1.95, 0.7)
		end

		------------------------------------------------------------------
		-- Dew drops (two tiny glowing ones for Uncommon bling)
		------------------------------------------------------------------
		local dews = {
			{ 0.7, 3.45, -1.82, false },
			{ -1.93, 3.0, -0.5, true },
			{ 0.4, 1.09, -2.6, false },
			{ -1.75, 1.09, -1.95, true },
			{ -0.3, 4.53, -0.2, false },
			{ 0.8, 3.0, 1.93, false },
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
