--!nocheck
-- Watermelon Patch (Crop #6, Mythic): a big striped watermelon lying in a
-- tilled soil patch. The melon is a stepped oval built from plus-shaped
-- horizontal layers that alternate deep green / pale lime, so the stripes run
-- end to end like a real melon, with jagged dark "teeth" on the stripe edges
-- and pale shine squares. Beside it: a juicy half melon (cut face up, tipped
-- toward the viewer: pink-red flesh, white rind ring, green skin, black
-- seeds), a big upright wedge slice and a little baby melon, with vines,
-- lobed leaves and curly tendrils. Mythic bling: glowing neon juice drops,
-- floating melon cubes, a sparkle emitter and a juice drip.
-- Static prop: no motion.luau. Soil lives on the "Soil" bone.
return {
	DisplayName = "Watermelon Patch",
	Rarity = "Mythic",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette ---------------------------------------------------------
		local DARK, DARKS = "#1d6e31", "#145424" -- deep green stripe / its shadow
		local LIGHT, LIGHTL, LIGHTS = "#c4f06e", "#dcf994", "#98c94a" -- pale lime stripe: main / lit / shadow
		local GLINT = "#f4ffd6"
		local RIND = "#f3fbe2"
		local FLESH, FLESHP, FLESHD = "#ff2e55", "#ff6f8c", "#e8173f" -- red / pink near rind / deep centre
		local SEED = "#1a1414"
		local STEM, STEMD = "#7c8a2c", "#5a6a1c"
		local LEAF, LEAFD, LEAFL, VEIN = "#2a9446", "#1b6b33", "#3cb55a", "#a3ec7a"
		local VINE, TENDRIL = "#3a8a2c", "#d3ef5a"
		local DIRT, DIRTD, DIRTL, CLOD = "#8a5530", "#68391f", "#a46a3d", "#4f2c17"
		local PEBBLE = "#b9b2a6"
		local NEON = "#ff4f8b"
		local NO = { mat = "Neon" }

		local function box(bone, x0, y0, z0, x1, y1, z1, col, opts)
			x0, x1 = math.min(x0, x1), math.max(x0, x1)
			z0, z1 = math.min(z0, z1), math.max(z0, z1)
			return B:block(bone, v(x1 - x0, y1 - y0, z1 - z0), cf((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), col, opts)
		end
		-- part in a local frame F (centre px,py,pz, size sx,sy,sz)
		local function pl(bone, F, px, py, pz, sx, sy, sz, col, opts)
			return B:block(bone, v(sx, sy, sz), F * CFrame.new(px, py, pz), col, opts)
		end

		------------------------------------------------------------------
		-- SOIL PATCH (removable "Soil" bone)
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function sb(size, c, col) return B:block(soil, size, c, col, S) end
		sb(v(13.2, 0.45, 9.6), cf(0, 0.225, 0), DIRTD)
		sb(v(11.8, 0.45, 10.6), cf(0, 0.3, 0), DIRTD) -- stepped corners
		sb(v(12.2, 0.5, 8.8), cf(0, 0.7, 0), DIRT)
		sb(v(11.0, 0.12, 7.6), cf(0, 1.0, 0.2), DIRTL) -- lighter crown
		-- tilled furrow ridges front and back
		sb(v(11.4, 0.22, 0.7), cf(0, 1.0, -4.0), DIRTL)
		sb(v(11.4, 0.22, 0.7), cf(0, 1.0, 4.1), DIRTL)
		for _, c in {
			{ -6.0, -3.2, 0.8, CLOD }, { 5.9, -3.9, 0.7, DIRTD }, { 6.1, 3.0, 0.85, CLOD }, { -5.7, 4.0, 0.7, DIRTD },
			{ 0.8, -4.7, 0.6, CLOD }, { -1.4, 4.8, 0.6, CLOD }, { 6.3, -0.6, 0.5, DIRTL }, { -6.3, 1.0, 0.55, DIRTL },
		} do
			sb(v(c[3], c[3] * 0.8, c[3]), cf(c[1], 0.75 + c[3] * 0.25, c[2]), c[4])
		end
		sb(v(0.45, 0.3, 0.45), cf(1.9, 1.1, -4.6, 0, 30, 0), PEBBLE)
		sb(v(0.35, 0.25, 0.35), cf(-0.2, 1.08, 4.7, 0, 15, 0), PEBBLE)

		local crop = B:bone("Crop", "Root", v(0, 1, 0))

		------------------------------------------------------------------
		-- BIG STRIPED WATERMELON (long axis = X)
		------------------------------------------------------------------
		local MX, MZ = 0.7, 1.0
		-- {y0, y1, width (Z), length (X), colour}; each layer is a plus shape
		local LAYERS = {
			{ 0.95, 1.65, 3.0, 5.4, LIGHTS },
			{ 1.65, 2.4, 4.2, 6.6, DARKS },
			{ 2.4, 3.6, 4.8, 7.2, LIGHT },
			{ 3.6, 4.4, 4.2, 6.6, DARK },
			{ 4.4, 5.0, 3.0, 5.6, LIGHTL },
		}
		for _, l in LAYERS do
			local W, L = l[3], l[4]
			box(crop, MX - L / 2, l[1], MZ - W * 0.36, MX + L / 2, l[2], MZ + W * 0.36, l[5])
			box(crop, MX - L / 2 + 0.6, l[1], MZ - W / 2, MX + L / 2 - 0.6, l[2], MZ + W / 2, l[5])
		end
		box(crop, MX - 2.2, 5.0, MZ - 0.5, MX + 2.2, 5.25, MZ + 0.5, DARK) -- top ridge stripe
		-- jagged stripe teeth: dark notches biting into the pale middle band
		for _, side in { -1, 1 } do
			local zf = MZ + side * 2.4
			for i, x in { -2.4, -1.0, 0.4, 1.8 } do
				local up = (i % 2 == 1)
				local y0, y1 = up and 3.25 or 2.4, up and 3.6 or 2.75
				box(crop, MX + x - 0.45, y0, zf, MX + x + 0.45, y1, zf + side * 0.08, i % 2 == 1 and DARK or DARKS)
			end
		end
		-- teeth on the lime top band too (seen from above)
		for i, x in { -1.6, 0.0, 1.6 } do
			local zs = (i % 2 == 1) and -1 or 1
			box(crop, MX + x - 0.4, 5.0, MZ + zs * 0.5, MX + x + 0.4, 5.08, MZ + zs * 0.95, DARK)
		end
		-- shine
		box(crop, MX - 2.6, 3.05, MZ - 2.48, MX - 1.8, 3.4, MZ - 2.4, GLINT)
		box(crop, MX - 1.6, 5.0, MZ - 1.35, MX - 0.9, 5.06, MZ - 0.8, GLINT)
		-- stem nub on the +X end, pale blossom spot on the -X end
		box(crop, MX + 3.55, 2.75, MZ - 0.35, MX + 4.05, 3.25, MZ + 0.35, STEMD)
		box(crop, MX + 4.0, 2.85, MZ - 0.2, MX + 4.4, 3.2, MZ + 0.2, STEM)
		box(crop, MX - 3.68, 2.8, MZ - 0.35, MX - 3.58, 3.2, MZ + 0.35, LIGHTL)

		------------------------------------------------------------------
		-- HALF MELON (cut face up, tipped toward the viewer)
		------------------------------------------------------------------
		local H = cf(-3.3, 0.95, -2.7, 0, 12, 0) * ang(-14, 0, 0)
		local function plus(F, y, h, a, b, col)
			pl(crop, F, 0, y, 0, a, h, b * 0.72, col)
			pl(crop, F, 0, y, 0, a - 0.8, h, b, col)
		end
		pl(crop, H, 0, 0.25, 0, 2.6, 0.5, 1.9, DARKS) -- skin bottom
		plus(H, 0.72, 0.5, 3.6, 3.0, LIGHTS) -- pale stripe
		plus(H, 1.2, 0.46, 4.2, 3.4, DARK) -- dark rim stripe
		plus(H, 1.5, 0.16, 4.0, 3.2, RIND) -- white rind ring
		plus(H, 1.62, 0.14, 3.6, 2.85, FLESHP) -- pink flesh near the rind
		plus(H, 1.72, 0.12, 2.8, 2.1, FLESH) -- red flesh
		pl(crop, H, 0, 1.8, 0, 1.6, 0.1, 1.1, FLESHD) -- juicy deep centre
		for _, s in { { -1.1, -0.5 }, { -0.4, 0.75 }, { 0.5, -0.8 }, { 1.15, 0.35 }, { -1.25, 0.45 }, { 0.3, 0.2 }, { -0.3, -0.25 } } do
			pl(crop, H, s[1], 1.83, s[2], 0.22, 0.08, 0.34, SEED)
		end

		------------------------------------------------------------------
		-- WEDGE SLICE (standing on its rind)
		------------------------------------------------------------------
		local W = cf(3.6, 1.0, -3.1, 0, -18, 0)
		pl(crop, W, 0, 0.2, 0, 3.4, 0.4, 1.0, DARK) -- green skin
		pl(crop, W, -1.85, 0.45, 0, 0.5, 0.5, 1.0, DARK) -- skin curls up at the ends
		pl(crop, W, 1.85, 0.45, 0, 0.5, 0.5, 1.0, DARK)
		pl(crop, W, 0, 0.52, 0, 3.4, 0.25, 0.96, RIND) -- white rind line
		pl(crop, W, -1.6, 0.82, 0, 0.3, 0.4, 0.96, RIND)
		pl(crop, W, 1.6, 0.82, 0, 0.3, 0.4, 0.96, RIND)
		pl(crop, W, 0, 0.95, 0, 3.0, 0.6, 0.92, FLESHP) -- stepped flesh triangle
		pl(crop, W, 0, 1.55, 0, 2.3, 0.6, 0.92, FLESH)
		pl(crop, W, 0, 2.15, 0, 1.55, 0.6, 0.92, FLESH)
		pl(crop, W, 0, 2.7, 0, 0.8, 0.5, 0.92, FLESHD)
		for _, s in { { -0.75, 1.35 }, { 0.55, 1.4 }, { -0.2, 1.95 }, { 0.35, 2.5 }, { -1.15, 1.0 }, { 1.05, 1.0 } } do
			pl(crop, W, s[1], s[2], -0.48, 0.2, 0.3, 0.06, SEED)
			pl(crop, W, -s[1], s[2] + 0.1, 0.48, 0.2, 0.3, 0.06, SEED)
		end
		local tip = pl(crop, W, 0, 2.97, 0, 0.3, 0.06, 0.3, FLESHD, { tr = 1, name = "JuiceTip" })
		B:emitter(tip, "drip", { name = "JuiceDrip", color = { "#ff6f9a", NEON }, rate = 1.5, size = { 0.2, 0.16, 0.08 } })

		------------------------------------------------------------------
		-- BABY MELON
		------------------------------------------------------------------
		local BX, BZ = -4.5, 2.9
		box(crop, BX - 0.8, 0.95, BZ - 0.55, BX + 0.8, 1.35, BZ + 0.55, LIGHTS)
		box(crop, BX - 1.15, 1.3, BZ - 0.8, BX + 1.15, 1.85, BZ + 0.8, DARK)
		box(crop, BX - 0.95, 1.3, BZ - 0.95, BX + 0.95, 1.85, BZ + 0.95, DARK)
		box(crop, BX - 1.0, 1.85, BZ - 0.75, BX + 1.0, 2.3, BZ + 0.75, LIGHT)
		box(crop, BX - 0.7, 2.3, BZ - 0.25, BX + 0.7, 2.45, BZ + 0.25, DARK)
		box(crop, BX - 0.7, 1.95, BZ - 0.8, BX - 0.35, 2.15, BZ - 0.75, GLINT)
		box(crop, BX + 1.1, 1.65, BZ - 0.15, BX + 1.45, 1.95, BZ + 0.15, STEM)

		------------------------------------------------------------------
		-- LEAVES, VINES, TENDRILS
		------------------------------------------------------------------
		local function leaf(x, z, yaw, tilt, s)
			local F = cf(x, 1.2, z, 0, yaw, 0) * ang(tilt, 0, 0)
			local function lb(sx, sy, sz, px, py, pz, col) B:block(crop, v(sx * s, sy, sz * s), F * CFrame.new(px * s, py, pz * s), col) end
			lb(2.0, 0.25, 2.0, 0, 0, 0, LEAF)
			lb(1.0, 0.25, 1.6, -1.45, 0, -0.1, LEAFD) -- deep side lobes
			lb(1.0, 0.25, 1.6, 1.45, 0, -0.1, LEAFD)
			lb(0.6, 0.25, 0.7, -2.1, 0, -0.5, LEAF)
			lb(0.6, 0.25, 0.7, 2.1, 0, -0.5, LEAF)
			lb(1.1, 0.25, 1.2, 0, 0, -1.55, LEAF) -- tip lobe
			lb(0.5, 0.25, 0.6, 0, 0, -2.4, LEAFD)
			lb(1.3, 0.1, 1.2, -0.2, 0.16, -0.3, LEAFL)
			lb(0.18, 0.08, 3.2, 0, 0.22, -0.7, VEIN)
			lb(2.6, 0.08, 0.16, 0, 0.22, -0.1, VEIN)
			lb(0.3, 0.3, 1.2, 0, 0.05, 1.55, VINE)
		end
		leaf(6.2, 2.2, -110, 8, 0.95) -- back-right, off the stem end
		leaf(-6.0, -0.4, 95, 6, 0.85) -- left
		leaf(1.0, 4.6, 180, 10, 0.75) -- small one at the back

		-- vines from the stem end along the ground
		box(crop, MX + 4.3, 1.05, MZ - 0.18, MX + 5.2, 1.35, MZ + 0.18, VINE)
		box(crop, MX + 4.3, 1.05, MZ - 0.18, MX + 4.62, 2.9, MZ + 0.18, VINE)
		box(crop, -3.2, 1.05, 2.9, -1.9, 1.35, 3.2, VINE) -- to the baby melon
		box(crop, -2.6, 1.05, -0.6, -2.3, 1.35, 0.6, VINE)
		local function tendril(x, z, yaw, s)
			local F = cf(x, 1.25, z, 0, yaw, 0)
			local function tb(x0, y0, x1, y1)
				B:block(crop, v((x1 - x0) * s, (y1 - y0) * s, 0.18), F * CFrame.new((x0 + x1) / 2 * s, (y0 + y1) / 2 * s, 0), TENDRIL)
			end
			tb(0, 0, 0.18, 1.1)
			tb(0, 0.95, 0.85, 1.13)
			tb(0.67, 0.45, 0.85, 1.1)
			tb(0.3, 0.45, 0.85, 0.62)
			tb(0.3, 0.6, 0.47, 0.8)
		end
		tendril(5.8, -1.0, 0, 0.85)
		tendril(-1.7, 4.0, 90, 0.8)
		tendril(-6.0, -3.6, 180, 0.7)

		------------------------------------------------------------------
		-- MYTHIC BLING: neon juice drops, floating melon cubes, sparkles
		------------------------------------------------------------------
		local function drop(x, y, z, s)
			B:block(crop, v(0.36, 0.36, 0.36) * s, cf(x, y, z), NEON, NO)
			B:block(crop, v(0.22, 0.22, 0.22) * s, cf(x, y + 0.27 * s, z), NEON, NO)
			B:block(crop, v(0.11, 0.16, 0.11) * s, cf(x, y + 0.45 * s, z), NEON, NO)
		end
		drop(-1.7, 3.0, -4.2, 1.0)
		drop(5.3, 3.4, -2.8, 0.85)
		drop(-5.5, 2.6, -2.0, 0.8)

		local function cube(x, y, z, rx, ry, rz, s)
			local F = cf(x, y, z, rx, ry, rz)
			pl(crop, F, 0, -0.05 * s, 0, 0.8 * s, 0.7 * s, 0.8 * s, FLESH)
			pl(crop, F, 0, 0.36 * s, 0, 0.82 * s, 0.1 * s, 0.82 * s, RIND)
			pl(crop, F, 0, 0.5 * s, 0, 0.84 * s, 0.18 * s, 0.84 * s, DARK)
			pl(crop, F, 0.1 * s, -0.05 * s, -0.41 * s, 0.14 * s, 0.22 * s, 0.04, SEED)
		end
		cube(-1.4, 5.7, -2.0, 20, 30, 15, 0.9)
		cube(4.0, 5.2, -0.4, -15, -25, 20, 0.8)
		cube(-4.9, 4.2, 0.9, 10, 40, -20, 0.7)

		local aura = box(crop, -5.0, 1.5, -4.0, 5.0, 5.8, 4.0, RIND, { tr = 1, name = "SparkleVolume" })
		B:emitter(aura, "sparkle", { name = "MelonSparkle", color = { "#ffffff", NEON }, rate = 6, size = { 0.1, 0.4, 0 } })
	end,
}
