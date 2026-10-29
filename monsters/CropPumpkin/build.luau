--!nocheck
-- Giant Pumpkin (Crop #5, Legendary): a huge prize pumpkin sitting on a straw
-- bed in a tilled soil patch. The pumpkin is a stepped round "3D pixel" body
-- made of full-depth rib slices (front/back ribs = X slices, side ribs = Z
-- slices, small corner ribs), alternating bright / darker orange so the
-- classic vertical ribs read from every side, with darker bottom tiers and
-- pale shine squares up top. A chunky curled olive-brown stem, curly vine
-- tendrils, two big lobed pumpkin leaves, a blue "1st prize" rosette and a few
-- tiny neon-gold sparkle stars + one sparkle emitter for the Legendary bling.
-- Static prop: no motion.luau. Soil + straw live on the "Soil" bone.
return {
	DisplayName = "Giant Pumpkin",
	Rarity = "Legendary",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette ---------------------------------------------------------
		local O, O2 = "#ff8a1c", "#ff9d33" -- main rib orange / lit top tier
		local D, D2 = "#e2581a", "#bf4214" -- darker rib orange / bottom shadow
		local SHINE, SHINE2 = "#fff2bd", "#ffb43c" -- shine squares
		local STEM, STEMD, STEML, STEMB = "#7f8f2c", "#58651a", "#b0b34e", "#6b4f22"
		local LEAF, LEAFD, LEAFL, VEIN = "#2c9a45", "#1d7136", "#3fb556", "#9fe875"
		local VINE, TENDRIL = "#3a8a2c", "#b5e04a"
		local DIRT, DIRTD, DIRTL, CLOD = "#8a5530", "#68391f", "#a46a3d", "#4f2c17"
		local STRAW, STRAWD, STRAWL = "#f2c94c", "#d29b2a", "#ffe282"
		local BLUE, BLUED, BLUEL = "#2f6ff0", "#1d47b8", "#5c95ff"
		local GOLD, GOLDD, WHITE = "#ffd23d", "#d99a1c", "#ffffff"
		local NEON = "#ffd84a"

		local function box(bone, x0, y0, z0, x1, y1, z1, col, opts)
			x0, x1 = math.min(x0, x1), math.max(x0, x1)
			z0, z1 = math.min(z0, z1), math.max(z0, z1)
			return B:block(bone, v(x1 - x0, y1 - y0, z1 - z0), cf((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), col, opts)
		end

		------------------------------------------------------------------
		-- SOIL PATCH + STRAW BED (removable "Soil" bone)
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function sb(size, c, col) return B:block(soil, size, c, col, S) end
		sb(v(11, 0.45, 9.6), cf(0, 0.225, 0), DIRTD) -- wide dark base
		sb(v(10, 0.5, 8.6), cf(0, 0.7, 0), DIRT) -- tilled top
		sb(v(8.6, 0.5, 10.2), cf(0, 0.45, 0), DIRTD) -- plus-shaped base (stepped corners)
		sb(v(9.2, 0.15, 7.6), cf(0, 1.0, 0), DIRTL) -- lighter crown under the straw
		-- dark clods + light crumbs round the rim
		for _, c in {
			{ -4.9, -3.6, 0.8, CLOD }, { 4.6, -4.0, 0.7, DIRTD }, { 5.0, 2.4, 0.9, CLOD }, { -4.5, 3.9, 0.75, DIRTD },
			{ 1.4, -4.6, 0.6, CLOD }, { -2.2, 4.6, 0.6, CLOD }, { 5.1, -1.2, 0.5, DIRTL }, { -5.2, 0.8, 0.55, DIRTL },
		} do
			sb(v(c[3], c[3] * 0.8, c[3]), cf(c[1], 0.75 + c[3] * 0.25, c[2]), c[4])
		end
		-- straw bed: a stepped golden mat under the pumpkin + loose straws
		sb(v(9.0, 0.16, 6.4), cf(0, 1.06, 0), STRAW)
		sb(v(6.4, 0.16, 9.0), cf(0, 1.07, 0), STRAW)
		sb(v(7.6, 0.16, 7.6), cf(0, 1.08, 0, 0, 45, 0), STRAWD)
		for _, s in {
			{ -4.6, -2.0, 0, 2.2, STRAWL }, { 4.5, 1.6, 0, 2.0, STRAWL }, { -1.8, -4.6, 90, 1.8, STRAWL },
			{ 2.6, 4.5, 90, 2.0, STRAWD }, { 3.8, -3.6, 45, 2.0, STRAWL }, { -3.7, 3.6, 45, 1.8, STRAWD },
			{ -3.9, -3.7, -45, 1.6, STRAW }, { 4.0, 3.4, -45, 1.7, STRAWL },
		} do
			sb(v(0.28, 0.14, s[4]), cf(s[1], 1.2, s[2], 0, s[3], 0), s[5])
		end

		------------------------------------------------------------------
		-- PUMPKIN BODY
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, 1, 0))
		local R = 4.0
		-- vertical tiers: {y0, y1, inset per end}
		local TIERS = {
			{ 1.0, 1.55, 1.6 }, { 1.55, 2.2, 0.75 }, { 2.2, 2.8, 0.25 }, { 2.8, 3.85, 0 },
			{ 3.85, 4.45, 0.25 }, { 4.45, 5.05, 0.8 }, { 5.05, 5.55, 1.7 },
		}
		-- tier colours for a bright rib and a dark rib (bottom = shadow, top = lit)
		local function tierCol(bright, t)
			if bright then
				return (t == 1 and D) or (t >= 6 and O2) or O
			end
			return (t == 1 and D2) or D
		end
		-- X slices: ribs that face front/back. Z slices: ribs that face the sides.
		local SLICES = { { 0, 2 * R, true }, { 1.5, 7.4, false }, { -1.5, 7.4, false } }
		for _, s in SLICES do
			for t, T in TIERS do
				local L = s[2] - 2 * T[3]
				box(crop, s[1] - 0.75, T[1], -L / 2, s[1] + 0.75, T[2], L / 2, tierCol(s[3], t))
				-- side ribs sit 0.06 lower so their tops never z-fight the front ribs
				box(crop, -L / 2, T[1] - 0.06, s[1] - 0.75, L / 2, T[2] - 0.06, s[1] + 0.75, tierCol(s[3], t))
			end
		end
		-- small bright corner ribs (diagonals)
		for _, sx in { -1, 1 } do
			for _, sz in { -1, 1 } do
				box(crop, sx * 2.15, 2.2, sz * 2.15, sx * 3.25, 4.45, sz * 3.25, O)
				box(crop, sx * 2.15, 1.3, sz * 2.15, sx * 2.9, 2.2, sz * 2.9, D)
				box(crop, sx * 2.15, 4.45, sz * 2.15, sx * 2.9, 5.1, sz * 2.9, O2)
			end
		end
		-- stem dimple
		box(crop, -1.0, 5.5, -1.0, 1.0, 5.6, 1.0, D)

		-- glossy highlight: a vertical lit strip + a white glint on the upper-left
		-- of the big bright ribs (light comes from the front-left)
		local function shine(x0, y0, z0, x1, y1, z1, col) box(crop, x0, y0, z0, x1, y1, z1, col or SHINE) end
		shine(-0.6, 2.95, -4.07, -0.2, 4.15, -3.95, SHINE2) -- front centre rib
		shine(-0.6, 4.2, -3.82, -0.2, 4.6, -3.7) -- glint on the tier above
		shine(-4.07, 2.95, 0.2, -3.95, 4.15, 0.6, SHINE2) -- left side centre rib
		shine(-3.82, 4.2, 0.2, -3.7, 4.6, 0.6)
		shine(-3.3, 3.2, -3.3, -3.18, 4.2, -2.95, SHINE2) -- front-left corner rib
		shine(-0.6, 5.55, -2.3, -0.1, 5.61, -1.6, SHINE) -- top glint
		shine(-2.3, 5.49, -0.6, -1.6, 5.55, -0.1, SHINE2)

		------------------------------------------------------------------
		-- STEM (chunky, curled)
		------------------------------------------------------------------
		box(crop, -0.75, 5.5, -0.75, 0.75, 5.95, 0.75, STEMB) -- woody collar
		box(crop, -0.55, 5.9, -0.55, 0.55, 6.65, 0.55, STEM) -- column
		box(crop, -0.58, 5.9, -0.2, -0.5, 6.55, 0.2, STEMD) -- groove (left)
		box(crop, -0.2, 5.9, -0.58, 0.2, 6.55, -0.5, STEMD) -- groove (front)
		box(crop, 0.5, 5.9, -0.2, 0.58, 6.55, 0.2, STEMD) -- groove (right)
		box(crop, -0.45, 6.55, -0.45, 1.55, 7.0, 0.45, STEM) -- curl over to the right
		box(crop, -0.45, 6.98, -0.3, 1.2, 7.06, 0.3, STEML) -- lit top of the curl
		box(crop, 1.1, 6.15, -0.4, 1.6, 6.6, 0.4, STEML) -- hooked dried tip
		box(crop, 1.15, 5.95, -0.3, 1.55, 6.2, 0.3, "#c9b569")

		------------------------------------------------------------------
		-- LEAVES (big, lobed, lying on the ground) + vines and tendrils
		------------------------------------------------------------------
		local function leaf(x, z, yaw, tilt, s)
			local F = cf(x, 1.22, z, 0, yaw, 0) * ang(tilt, 0, 0)
			local function lb(size, px, py, pz, col) B:block(crop, size * s, F * CFrame.new(px * s, py, pz * s), col) end
			lb(v(2.4, 0.25, 2.2), 0, 0, 0, LEAF) -- centre
			lb(v(1.1, 0.25, 1.5), -1.55, 0, 0.15, LEAFD) -- side lobes
			lb(v(1.1, 0.25, 1.5), 1.55, 0, 0.15, LEAFD)
			lb(v(1.5, 0.25, 1.0), 0, 0, -1.5, LEAF) -- tip lobe (away from the pumpkin)
			lb(v(0.7, 0.25, 0.6), -1.6, 0, -0.95, LEAF)
			lb(v(0.7, 0.25, 0.6), 1.6, 0, -0.95, LEAF)
			lb(v(1.5, 0.1, 1.3), -0.2, 0.16, -0.25, LEAFL) -- lit inner patch
			lb(v(0.2, 0.08, 3.0), 0, 0.22, -0.4, VEIN) -- midrib
			lb(v(1.8, 0.08, 0.18), 0, 0.22, 0.2, VEIN) -- cross vein
			lb(v(0.3, 0.3, 1.3), 0, 0.05, 1.6, VINE) -- leaf stalk toward the pumpkin
		end
		leaf(-4.4, -3.4, 50, 6, 1.0) -- front-left
		leaf(4.6, 2.6, -120, 8, 1.05) -- back-right
		leaf(4.9, -2.9, -60, 10, 0.75) -- small front-right

		-- vines along the ground from the pumpkin base
		box(crop, -3.9, 1.1, -0.35, -2.6, 1.45, 0.05, VINE)
		box(crop, -4.3, 1.1, -0.35, -3.9, 1.45, 1.8, VINE)
		box(crop, 2.7, 1.1, 2.6, 3.6, 1.45, 3.0, VINE)
		box(crop, 3.0, 1.1, -3.5, 3.4, 1.45, -2.7, VINE)
		-- curly tendrils: little upright square spirals (pixel-art curls)
		local function tendril(x, z, yaw, s)
			local F = cf(x, 1.3, z, 0, yaw, 0)
			local function tb(x0, y0, x1, y1) local c = F * CFrame.new((x0 + x1) / 2 * s, (y0 + y1) / 2 * s, 0)
				B:block(crop, v((x1 - x0) * s, (y1 - y0) * s, 0.18), c, TENDRIL) end
			tb(0, 0, 0.18, 1.1) -- up
			tb(0, 0.95, 0.85, 1.13) -- over
			tb(0.67, 0.45, 0.85, 1.1) -- down
			tb(0.3, 0.45, 0.85, 0.62) -- back
			tb(0.3, 0.6, 0.47, 0.8) -- tiny up
		end
		tendril(-4.6, 1.6, 90, 0.9)
		tendril(3.3, 3.4, 0, 0.8)
		tendril(3.3, -3.9, 180, 0.75)

		------------------------------------------------------------------
		-- "1st PRIZE" blue rosette pinned on the front-right rib
		------------------------------------------------------------------
		local RX, RY, RZ = 1.55, 3.3, -3.78
		B:block(crop, v(1.0, 0.35, 0.1), cf(RX - 0.25, RY - 0.85, RZ - 0.02, 0, 0, 70), BLUED) -- tails
		B:block(crop, v(1.0, 0.35, 0.1), cf(RX + 0.25, RY - 0.85, RZ - 0.02, 0, 0, -70), BLUED)
		B:block(crop, v(1.25, 1.25, 0.1), cf(RX, RY, RZ - 0.06, 0, 0, 45), BLUED) -- ruffle (8-point)
		B:block(crop, v(1.25, 1.25, 0.1), cf(RX, RY, RZ - 0.1), BLUE)
		B:block(crop, v(0.8, 0.8, 0.1), cf(RX, RY, RZ - 0.16, 0, 0, 45), BLUEL)
		B:block(crop, v(0.62, 0.62, 0.1), cf(RX, RY, RZ - 0.22), GOLD) -- gold button
		B:block(crop, v(0.14, 0.42, 0.06), cf(RX + 0.02, RY + 0.01, RZ - 0.29), BLUED) -- "1"
		B:block(crop, v(0.14, 0.1, 0.06), cf(RX + 0.13, RY + 0.15, RZ - 0.29), BLUED)
		B:block(crop, v(0.34, 0.09, 0.06), cf(RX + 0.02, RY - 0.17, RZ - 0.29), BLUED)

		------------------------------------------------------------------
		-- LEGENDARY BLING: neon-gold sparkle stars + a sparkle emitter
		------------------------------------------------------------------
		local NO = { mat = "Neon" }
		local function star(x, y, z, s)
			B:block(crop, v(0.13, 0.8 * s, 0.13), cf(x, y, z), NEON, NO)
			B:block(crop, v(0.8 * s, 0.13, 0.13), cf(x, y, z), NEON, NO)
			B:block(crop, v(0.13, 0.13, 0.8 * s), cf(x, y, z), NEON, NO)
		end
		star(-3.3, 5.9, -2.6, 1.0)
		star(3.9, 4.9, -1.8, 0.8)
		star(-4.3, 3.3, 2.2, 0.7)
		star(2.6, 6.5, 1.6, 0.85)

		local aura = box(crop, -3.8, 2.0, -3.8, 3.8, 6.5, 3.8, WHITE, { tr = 1, name = "SparkleVolume" })
		B:emitter(aura, "sparkle", { name = "PrizeSparkle", color = { "#ffffff", NEON }, rate = 5, size = { 0.1, 0.4, 0 } })
	end,
}
