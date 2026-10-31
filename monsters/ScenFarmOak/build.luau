--!nocheck
-- Big Oak Tree (Sunny Farm scenery, ~18 studs). A chunky farmyard oak in the
-- apple-tree / round-bush greens, meant to be pasted around the farm:
-- * a stout octagonal trunk (square + 45-degree square) in three bark tones,
--   with darker bark grooves, a light sunny edge, a knot hole and a stepped
--   root flare; flat roots run out along the ground (no mound)
-- * three thick branches carry a big round canopy built from stepped
--   rounded lobes (plus-shaped tiers: shadow green underneath, main, light,
--   a pale highlight cap) -- one big crown, four side lobes and a top puff
-- * big tilted leaf cubes with light caps break up the outline so it reads
--   lumpy and leafy from far away; a few acorns lie in the grass
-- * grounding: grass tufts, a couple of pebbles, fallen leaves and acorns
-- Scenery filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Big Oak Tree",
	Rarity = "Scenery",
	Filler = true,
	Element = "Sunny Farm",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		-- Sunny Farm palette (CropAppleTree / FillFarmBush / DecorFarmWell)
		local LEAF_HI, LEAF_LT, LEAF, LEAF_DK, LEAF_SH = "#7be35a", "#5fd23f", "#3fb43a", "#2a8f33", "#22762b"
		local BARK_LT, BARK, BARK_DK, BARK_XDK = "#a8692f", "#8a5a2b", "#6b4220", "#4a2c14"
		local ACORN, ACORN_CAP = "#c98a4b", "#6b4220"
		local GRASS, GRASS_DK = "#5fd23f", "#3fb43a"
		local STONE_LT, STONE = "#c3c9cf", "#9aa3ad"

		-- tiny deterministic random so the lumps look hand placed
		local seed = 7
		local function rnd()
			seed = (seed * 1103515245 + 12345) % 2147483648
			return seed / 2147483648
		end
		local ANG = { -20, -10, 0, 10, 20 }
		local function pick() return ANG[1 + math.floor(rnd() * #ANG)] end

		------------------------------------------------------------ trunk
		local TW = 2.8
		local TOPY = 12
		local function oct(x, y0, y1, z, w, col, col2)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(R, v(w, h, w), cf(x, y, z), col)
			B:block(R, v(w * 0.84, h - 0.04, w * 0.84), cf(x, y, z, 0, 45, 0), col2 or col)
		end
		-- root flare (stepped) + trunk
		oct(0, 0, 0.9, 0, 4.2, BARK_DK, BARK_DK)
		oct(0, 0.85, 2.0, 0, 3.5, BARK, BARK_DK)
		oct(0, 1.9, TOPY, 0, TW, BARK, BARK_DK)
		-- sunny edge strip + dark grooves on the faces
		B:block(R, v(0.45, 7.5, 0.3), cf(-0.75, 6.2, -TW / 2 - 0.08), BARK_LT)
		B:block(R, v(0.3, 5.0, 0.3), cf(-TW / 2 - 0.08, 5.5, -0.6), BARK_LT)
		B:block(R, v(0.3, 6.0, 0.3), cf(0.55, 7.0, -TW / 2 - 0.06), BARK_DK)
		B:block(R, v(0.3, 4.5, 0.3), cf(TW / 2 + 0.06, 5.0, 0.3), BARK_DK)
		B:block(R, v(0.3, 5.5, 0.3), cf(-0.4, 6.5, TW / 2 + 0.06), BARK_DK)
		B:block(R, v(0.3, 4.0, 0.3), cf(-TW / 2 - 0.06, 8.6, 0.7), BARK_DK)
		-- knot hole
		B:block(R, v(1.0, 1.2, 0.3), cf(0.45, 4.3, -TW / 2 - 0.1), BARK_DK)
		B:block(R, v(0.6, 0.8, 0.3), cf(0.45, 4.3, -TW / 2 - 0.2), BARK_XDK)
		-- flat roots out along the ground
		local roots = { { 25, 3.8 }, { 100, 3.2 }, { 170, 3.6 }, { 235, 3.0 }, { 305, 3.4 } }
		for i, r in roots do
			local a = math.rad(r[1])
			local dx, dz = math.cos(a), math.sin(a)
			B:bar(R, v(dx * 1.2, 0.55, dz * 1.2), v(dx * r[2], 0.4, dz * r[2]), 1.0, 0.8, (i % 2 == 0) and BARK or BARK_DK)
			B:block(R, v(0.7, 0.35, 0.7), cf(dx * (r[2] - 0.1), 0.17, dz * (r[2] - 0.1), 0, r[1], 0), BARK_DK)
		end

		------------------------------------------------------------ branches
		B:bar(R, v(0, 8.5, 0), v(3.8, 11.2, -1.6), 1.3, 1.3, BARK)
		B:bar(R, v(0, 9.0, 0), v(-3.8, 11.6, 1.2), 1.3, 1.3, BARK)
		B:bar(R, v(0, 9.5, 0), v(0.8, 12.0, 3.4), 1.1, 1.1, BARK_DK)
		B:bar(R, v(0, 9.8, 0), v(-1.2, 12.2, -3.2), 1.0, 1.0, BARK_DK)

		------------------------------------------------------------ canopy
		-- one stepped round lobe: plus-shaped tiers, dark underneath, light on top
		local function tier(x, y0, y1, z, w, col, rot)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(R, v(w, h, w * 0.7), cf(x, y, z, 0, rot, 0), col)
			B:block(R, v(w * 0.7, h, w), cf(x, y, z, 0, rot, 0), col)
		end
		local function lobe(x, yb, z, w, h, rot)
			tier(x, yb, yb + h * 0.18, z, w * 0.68, LEAF_SH, rot)
			tier(x, yb + h * 0.15, yb + h * 0.5, z, w * 0.95, LEAF_DK, rot + 10)
			tier(x, yb + h * 0.45, yb + h * 0.8, z, w, LEAF, rot)
			tier(x, yb + h * 0.75, yb + h, z, w * 0.75, LEAF_LT, rot + 20)
			B:block(R, v(w * 0.42, 0.3, w * 0.42), cf(x, yb + h + 0.1, z, 0, rot + 45, 0), LEAF_HI)
		end
		-- big crown
		lobe(0, 10.0, 0, 10.5, 7.4, 0)
		-- side lobes (lower, pushing the silhouette out into a round oak)
		local lobes = {
			{ 4.4, 9.4, -1.8, 6.6, 5.6, 15 },
			{ -4.4, 9.7, 1.6, 6.8, 5.6, -10 },
			{ 1.6, 9.9, 4.3, 6.2, 5.4, 30 },
			{ -1.8, 10.1, -4.2, 6.2, 5.2, 5 },
		}
		for _, l in lobes do
			lobe(l[1], l[2], l[3], l[4], l[5], l[6])
		end
		-- top puff
		lobe(0.5, 16.6, -0.3, 6.2, 2.8, 25)

		-- big tilted leaf cubes with light caps, scattered over the lobe surfaces
		local function leaf(x, y, z, s, col, cap)
			local c = CFrame.new(x, y, z) * CFrame.Angles(math.rad(pick()), math.rad(pick() + 45), math.rad(pick()))
			B:block(R, v(s, s, s), c, col)
			B:block(R, v(s * 0.7, 0.2, s * 0.7), c * CFrame.new(0, s / 2 + 0.07, 0), cap)
		end
		-- ring of cubes around the crown's waist + upper ring
		local function ring(cx, cy, cz, rad, n, s, off, col, cap)
			for i = 1, n do
				local a = math.rad(off + (i - 1) * 360 / n + rnd() * 14)
				local ss = s * (0.85 + rnd() * 0.3)
				leaf(cx + math.cos(a) * rad, cy + (rnd() - 0.5) * 0.8, cz + math.sin(a) * rad, ss, col, cap)
			end
		end
		ring(0, 14.0, 0, 5.3, 8, 2.8, 10, LEAF, LEAF_LT)
		ring(0, 16.6, 0, 3.6, 6, 2.5, 40, LEAF_LT, LEAF_HI)
		for _, l in lobes do
			local a = math.atan2(l[3], l[1])
			for k = -1, 1 do
				local aa = a + k * 0.75
				local rr = l[4] * 0.45
				leaf(l[1] + math.cos(aa) * rr, l[2] + l[5] * 0.55 + (rnd() - 0.3) * 0.8, l[3] + math.sin(aa) * rr, 2.2 + rnd() * 0.5, (k == 0) and LEAF or LEAF_DK, (k == 0) and LEAF_LT or LEAF)
			end
		end
		-- darker cubes softening the underside edge
		for i = 1, 6 do
			local a = math.rad(20 + i * 60 + rnd() * 20)
			local rr = 4.0 + rnd() * 1.0
			leaf(math.cos(a) * rr, 10.3 + rnd() * 0.4, math.sin(a) * rr, 2.0 + rnd() * 0.4, LEAF_SH, LEAF_DK)
		end
		-- a couple of cubes on the top puff
		leaf(1.6, 19.0, 0.5, 2.0, LEAF_LT, LEAF_HI)
		leaf(-0.8, 18.8, -1.3, 1.8, LEAF_LT, LEAF_HI)

		------------------------------------------------------------ acorns
		local function acorn(x, y, z)
			B:block(R, v(0.55, 0.6, 0.55), cf(x, y + 0.3, z, 0, 45, 0), ACORN)
			B:block(R, v(0.65, 0.25, 0.65), cf(x, y + 0.7, z), ACORN_CAP)
		end
		acorn(0.6, 0, -3.1)
		acorn(-3.3, 0, -1.4)

		------------------------------------------------------------ grounding
		local function tuft(x, z, h, ry)
			local b = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(ry), 0)
			B:block(R, v(0.45, h, 0.45), b * CFrame.new(0, h / 2, 0), GRASS)
			B:block(R, v(0.4, h * 0.75, 0.4), b * CFrame.new(0.38, h * 0.36, 0.05) * CFrame.Angles(0, 0, math.rad(-20)), GRASS_DK)
			B:block(R, v(0.4, h * 0.65, 0.4), b * CFrame.new(-0.36, h * 0.32, -0.05) * CFrame.Angles(0, 0, math.rad(22)), GRASS)
		end
		tuft(2.6, -2.9, 1.1, 20)
		tuft(-3.4, -2.2, 1.0, -35)
		tuft(3.4, 2.6, 0.9, 60)
		tuft(-2.2, 3.6, 1.0, 10)
		B:block(R, v(0.9, 0.35, 0.7), cf(-1.4, 0.17, -3.6, 0, 25, 0), STONE)
		B:block(R, v(0.6, 0.25, 0.5), cf(4.3, 0.12, -0.8, 0, -15, 0), STONE_LT)
		-- fallen leaves + acorns
		B:block(R, v(0.7, 0.1, 0.45), cf(1.6, 0.05, -4.2, 0, 30, 0), LEAF_LT)
		B:block(R, v(0.6, 0.1, 0.4), cf(-4.4, 0.05, 0.4, 0, -45, 0), LEAF)
		B:block(R, v(0.6, 0.1, 0.4), cf(4.0, 0.05, 3.9, 0, 10, 0), LEAF_DK)
	end,
}
