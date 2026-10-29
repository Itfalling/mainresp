--!nocheck
-- Apple Tree (Crop #9, Divine): a chunky storybook apple tree on a grassy
-- soil mound. Thick stepped brown trunk with bark colour blocking and exposed
-- roots, a few chunky L-shaped branches, and a big puffy stepped canopy in
-- bright yellow-greens with dark-green undersides. Lots of shiny stepped red
-- apples (white shine square, brown stem, leaf), a few fallen apples and a
-- little wooden basket of apples on the mound. Divine bling: a few apples
-- with tiny neon shines, sparkles, drifting leaves and floating voxel cubes.
-- Static prop: no motion.luau. Soil parts live on the "Soil" bone.
return {
	DisplayName = "Apple Tree",
	Rarity = "Divine",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf

		-- palette ---------------------------------------------------------
		local DIRT, DIRTL, DIRTD, CLOD = "#8b5530", "#a5683a", "#6e3f21", "#4f2c15"
		local PEBBLE, PEBBLED = "#b9b2a6", "#8f877c"
		local TUFT, TUFTL = "#3c9e2f", "#79d43a" -- grass tufts on the mound
		local MOSS, MOSSL = "#3a9a33", "#58b83a" -- grassy cap of the mound
		local BARK, BARKL, BARKD, BARKX = "#8c5427", "#b37a42", "#653817", "#43230d"
		local LEAFX, LEAFD, LEAF, LEAFL, LEAFH = "#1b6230", "#2b8a3a", "#6fc72b", "#b4e83a", "#e4fa74"
		local RED, REDL, DRED = "#e3202b", "#ff4b3e", "#a01220"
		local SHINE, STEM = "#ffffff", "#5a3416"
		local WOOD, WOODL, WOODD = "#c98b46", "#e3a95c", "#8e5a28"
		local NEONSHINE = "#ffe4e4"

		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local crop = B:bone("Crop", "Root", v(0, 0, 0))

		-- stepped octagon slab: plus shape + inner square (reads round)
		local function oct(bone, y0, y1, w, color, opts, ox, oz)
			ox, oz = ox or 0, oz or 0
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(bone, v(w, h, w * 0.6), cf(ox, y, oz), color, opts)
			B:block(bone, v(w * 0.6, h, w), cf(ox, y + 0.01, oz), color, opts)
			B:block(bone, v(w * 0.82, h - 0.04, w * 0.82), cf(ox, y, oz), color, opts)
		end
		local SOIL = { name = "Soil" }

		------------------------------------------------------------------
		-- SOIL MOUND (stepped, grassy edges, clods, pebbles)
		------------------------------------------------------------------
		oct(soil, 0, 0.6, 12, DIRTD, SOIL)
		oct(soil, 0.6, 1.15, 9.6, DIRT, SOIL)
		oct(soil, 1.15, 1.5, 6.6, DIRTL, SOIL)
		oct(soil, 1.5, 1.68, 6.3, MOSS, SOIL) -- grassy cap
		B:block(soil, v(1.4, 0.06, 1.0), cf(-2.0, 1.7, -1.4), MOSSL, SOIL)
		B:block(soil, v(1.0, 0.06, 1.2), cf(1.9, 1.7, 1.9), MOSSL, SOIL)
		-- darker clods + pebbles
		for _, c in { { -4.6, 0.62, 1.2, 0.8 }, { 3.9, 0.62, 2.6, 0.7 }, { -1.8, 0.62, 5.0, 0.7 }, { 4.6, 0.62, -1.5, 0.6 },
			{ -3.1, 1.17, -2.6, 0.6 }, { 2.4, 1.17, 3.0, 0.65 }, { -2.0, 1.62, 1.9, 0.5 } } do
			B:block(soil, v(c[4], 0.35, c[4] * 0.8), cf(c[1], c[2] + 0.12, c[3]), CLOD, SOIL)
		end
		B:block(soil, v(0.6, 0.4, 0.5), cf(-5.2, 0.75, -1.8), PEBBLE, SOIL)
		B:block(soil, v(0.35, 0.3, 0.35), cf(-4.8, 0.7, -2.3), PEBBLED, SOIL)
		B:block(soil, v(0.5, 0.35, 0.5), cf(1.2, 1.3, 4.5), PEBBLE, SOIL)
		-- grass tufts poking out of the mound edges (two-tone)
		for _, t in { { -5.4, 0.6, 2.4 }, { 5.3, 0.6, 1.0 }, { 0.6, 0.6, -5.6 }, { -2.8, 1.15, -4.1 }, { 4.0, 1.15, 2.9 },
			{ -4.2, 1.15, 0.3 }, { 1.6, 0.6, 5.5 } } do
			B:block(soil, v(0.3, 0.6, 0.3), cf(t[1], t[2] + 0.28, t[3]), TUFT, SOIL)
			B:block(soil, v(0.25, 0.85, 0.25), cf(t[1] + 0.28, t[2] + 0.4, t[3] + 0.1), TUFTL, SOIL)
		end

		------------------------------------------------------------------
		-- TRUNK (stepped, bark colour blocking)
		------------------------------------------------------------------
		B:block(crop, v(4.2, 1.0, 3.0), cf(0, 1.9, 0), BARKD) -- root flare
		B:block(crop, v(3.0, 1.0, 4.2), cf(0, 1.91, 0), BARKD)
		B:block(crop, v(3.6, 3.2, 3.6), cf(0, 3.6, 0), BARK) -- lower trunk
		B:block(crop, v(3.2, 3.0, 3.2), cf(0.15, 6.6, 0.1), BARK) -- mid trunk
		B:block(crop, v(2.8, 2.0, 2.8), cf(0.25, 9.0, 0.15), BARK) -- crown of the trunk
		B:block(crop, v(3.7, 0.5, 3.7), cf(0, 5.25, 0), BARKD) -- step rings
		B:block(crop, v(3.3, 0.4, 3.3), cf(0.15, 8.1, 0.1), BARKD)
		-- vertical bark strips (dark grooves + light ridges) on all 4 faces.
		-- trunk segments: {cx, cz, half}
		local SEG = { { 0, 0, 1.8 }, { 0.15, 0.1, 1.6 }, { 0.25, 0.15, 1.4 } }
		local function strip(seg, face, off, y, w, h, col)
			local g = SEG[seg]
			local d = g[3] + 0.06
			local fx, fz = ({ { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 0 } })[face][1], ({ { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 0 } })[face][2]
			local size = fz ~= 0 and v(w, h, 0.2) or v(0.2, h, w)
			B:block(crop, size, cf(g[1] + fx * d + (fz ~= 0 and off or 0), y, g[2] + fz * d + (fx ~= 0 and off or 0)), col)
		end
		for face = 1, 4 do
			local k = face % 2 == 0 and -1 or 1
			strip(1, face, -0.8 * k, 3.5, 0.5, 2.4, BARKD)
			strip(1, face, 0.7 * k, 3.9, 0.4, 1.6, BARKL)
			strip(2, face, 0.55 * k, 6.7, 0.5, 2.2, BARKD)
			strip(3, face, -0.3 * k, 9.1, 0.4, 1.4, face % 2 == 0 and BARKD or BARKL)
		end
		strip(2, 1, -0.75, 6.4, 0.4, 1.4, BARKL)
		-- knot hole on the front
		B:block(crop, v(0.9, 0.9, 0.2), cf(-0.6, 6.0, -1.62), BARKD)
		B:block(crop, v(0.5, 0.5, 0.2), cf(-0.6, 6.0, -1.7), BARKX)

		-- exposed roots: stepped, running down the mound
		for _, r in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
			local dx, dz = r[1], r[2]
			local function rb(dist, y, len, w, h, col)
				local sx = dx ~= 0 and len or w
				local sz = dz ~= 0 and len or w
				B:block(crop, v(sx, h, sz), cf(dx * dist + dz * 0.3, y, dz * dist - dx * 0.2), col)
			end
			rb(2.3, 1.85, 1.6, 1.3, 1.2, BARK)
			rb(3.5, 1.65, 1.4, 1.0, 0.8, BARKD)
			rb(4.5, 1.3, 1.0, 0.8, 0.5, BARK)
		end
		-- two smaller diagonal roots (45 deg)
		for _, a in { 45, 225 } do
			local r = math.rad(a)
			local c, s = math.cos(r), math.sin(r)
			B:block(crop, v(2.2, 0.8, 0.8), cf(c * 2.4, 1.7, s * 2.4, 0, -a, 0), BARKD)
			B:block(crop, v(1.2, 0.6, 0.6), cf(c * 3.6, 1.5, s * 3.6, 0, -a, 0), BARK)
		end

		-- chunky L-shaped branches up into the canopy
		B:block(crop, v(2.8, 1.2, 1.3), cf(2.3, 9.2, 0.1), BARK)
		B:block(crop, v(1.3, 2.6, 1.3), cf(3.6, 10.6, 0.1), BARK)
		B:block(crop, v(0.35, 1.0, 1.32), cf(2.6, 9.2, 0.1), BARKD)
		B:block(crop, v(2.6, 1.1, 1.2), cf(-2.1, 8.6, -0.2), BARK)
		B:block(crop, v(1.2, 3.0, 1.2), cf(-3.3, 10.1, -0.2), BARK)
		B:block(crop, v(0.35, 0.9, 1.22), cf(-2.0, 8.6, -0.2), BARKD)
		B:block(crop, v(1.2, 1.1, 2.6), cf(0.3, 9.6, 2.2), BARK)
		B:block(crop, v(1.2, 2.4, 1.2), cf(0.3, 10.8, 3.3), BARKD)
		B:block(crop, v(1.0, 1.0, 2.2), cf(0.0, 10.2, -2.0), BARK)
		B:block(crop, v(1.0, 1.6, 1.0), cf(0.0, 10.9, -2.9), BARKD)

		------------------------------------------------------------------
		-- CANOPY (stepped round mass + puffy leaf clusters)
		------------------------------------------------------------------
		local boxes = {} -- canopy volumes for placing apples on the surface
		local function leaf(size, pos, color)
			B:block(crop, size, cf(pos.X, pos.Y, pos.Z), color)
			table.insert(boxes, { c = pos, h = size / 2 })
		end
		local function layer(y0, y1, w, color, ox, oz)
			ox, oz = ox or 0, oz or 0
			local h, y = y1 - y0, (y0 + y1) / 2
			leaf(v(w, h, w * 0.6), v(ox, y, oz), color)
			leaf(v(w * 0.6, h, w), v(ox, y + 0.01, oz), color)
			leaf(v(w * 0.82, h - 0.04, w * 0.82), v(ox, y, oz), color)
		end
		-- dark core (shows only in the crevices between clusters)
		layer(10.4, 11.4, 8.4, LEAFX)
		leaf(v(11.0, 4.2, 6.6), v(0, 13.5, 0), LEAFD)
		leaf(v(6.6, 4.2, 11.0), v(0, 13.51, 0), LEAFD)
		leaf(v(8.6, 1.8, 5.2), v(0, 16.5, 0), LEAFD)
		leaf(v(5.2, 1.8, 8.6), v(0, 16.51, 0), LEAFD)

		-- puffy stepped leaf clusters: dark underside, two-tone body, light cap
		local function puff(a, r, y, s, body, top, under)
			local rad = math.rad(a)
			local x, z = math.cos(rad) * r, math.sin(rad) * r
			body = body or LEAF
			if under ~= false then
				leaf(v(s * 0.74, s * 0.24, s * 0.74), v(x, y - s * 0.36, z), LEAFD) -- dark underside
			end
			leaf(v(s, s * 0.52, s * 0.7), v(x, y, z), body)
			leaf(v(s * 0.7, s * 0.52 + 0.04, s), v(x, y, z), body)
			leaf(v(s * 0.68, s * 0.24, s * 0.68), v(x, y + s * 0.36, z), top or LEAFL) -- light cap
		end
		-- lower ring (alternating heights + greens)
		for i = 0, 7 do
			local a = i * 45 + (i % 2) * 8
			if i % 2 == 0 then
				puff(a, 5.5, 13.0, 4.4, LEAF, LEAFL)
			else
				puff(a, 5.3, 14.1, 4.0, LEAFL, LEAFH)
			end
		end
		-- upper ring
		for i = 0, 4 do
			puff(i * 72 + 20, 3.5, 16.3 + (i % 2) * 0.4, 3.8, i % 2 == 0 and LEAFL or LEAF, LEAFH, false)
		end
		-- crown
		puff(0, 0, 17.6, 3.6, LEAFL, LEAFH, false)

		-- farthest canopy surface along a horizontal ray from the trunk axis
		local function surface(a, y)
			local rad = math.rad(a)
			local dx, dz = math.cos(rad), math.sin(rad)
			local best = 0
			for _, b in boxes do
				if math.abs(y - b.c.Y) <= b.h.Y then
					local t0, t1 = -math.huge, math.huge
					local ok = true
					for _, ax in { { dx, b.c.X, b.h.X }, { dz, b.c.Z, b.h.Z } } do
						local d, c, h = ax[1], ax[2], ax[3]
						if math.abs(d) < 1e-6 then
							if math.abs(c) > h then ok = false end
						else
							local ta, tb = (c - h) / d, (c + h) / d
							if ta > tb then ta, tb = tb, ta end
							t0, t1 = math.max(t0, ta), math.min(t1, tb)
						end
					end
					if ok and t1 >= math.max(t0, 0) then best = math.max(best, t1) end
				end
			end
			return best
		end

		------------------------------------------------------------------
		-- APPLES
		------------------------------------------------------------------
		-- stepped round apple facing outward (shine on its outward face)
		local function apple(bone, x, y, z, yaw, s, opts)
			opts = opts or {}
			local base = CFrame.new(x, y, z) * CFrame.Angles(0, math.rad(yaw), 0)
			local function pb(size, ox, oy, oz, col, o)
				return B:block(bone, size * s, base * CFrame.new(ox * s, oy * s, oz * s), col, o)
			end
			if opts.simple then
				pb(v(1.25, 0.85, 1.25), 0, 0, 0, RED)
			else -- plus-shaped middle tier reads round
				pb(v(1.32, 0.85, 0.95), 0, 0, 0, RED)
				pb(v(0.95, 0.86, 1.3), 0, 0, 0, RED)
			end
			pb(v(0.9, 0.3, 0.9), 0, 0.55, 0, REDL)
			pb(v(0.85, 0.3, 0.85), 0, -0.55, 0, DRED)
			if opts.neon then
				B:gem(bone, v(0.38, 0.38, 0.06) * s, base * CFrame.new(-0.3 * s, 0.18 * s, -0.64 * s), NEONSHINE, { name = "AppleGlint" })
			else
				pb(v(0.3, 0.3, 0.06), -0.3, 0.18, -0.64, SHINE)
			end
			if not opts.simple then
				pb(v(0.14, 0.4, 0.14), 0.05, 0.85, 0, STEM)
				pb(v(0.45, 0.1, 0.24), 0.32, 0.82, 0, LEAFD)
			end
		end
		local function yawFor(a)
			-- local -Z faces outward along angle a (snapped to 45 deg)
			local rad = math.rad(a)
			local yaw = math.deg(math.atan2(-math.cos(rad), -math.sin(rad)))
			return math.floor(yaw / 45 + 0.5) * 45
		end
		-- {angle, y, neon}
		local APPLES = {
			{ -95, 13.4, true }, { -60, 15.3 }, { -128, 12.2 }, { 0, 14.4 }, { -150, 15.6 },
			{ 10, 15.6 }, { 35, 13.0, true }, { 70, 15.4 }, { 100, 12.4 }, { 140, 13.4 },
			{ 180, 14.6 }, { 205, 12.6, true }, { 240, 14.2 }, { 300, 12.2 }, { -75, 11.4 }, { 160, 11.6 },
			{ -110, 16.6 }, { 55, 11.4, true },
		}
		local S = 1.05
		for _, ap in APPLES do
			local r = surface(ap[1], ap[2]) - 0.25
			local rad = math.rad(ap[1])
			apple(crop, math.cos(rad) * r, ap[2], math.sin(rad) * r, yawFor(ap[1]), S, { neon = ap[3] })
		end
		-- two apples nestled on top
		apple(crop, -2.6, 18.2, -1.4, 0, S)
		apple(crop, 2.9, 17.5, 2.6, 180, S)

		-- fallen apples on the mound / grass
		apple(crop, -4.2, 1.1, -2.9, 30, 1.0, { simple = true })
		apple(crop, 5.6, 0.72, 2.6, -60, 1.0, { simple = true })
		apple(crop, -1.6, 1.62, -3.6, 0, 0.9)

		------------------------------------------------------------------
		-- BASKET of apples (front right)
		------------------------------------------------------------------
		local bx, bz, by = 3.3, -3.3, 1.15
		B:block(crop, v(2.2, 1.0, 1.6), cf(bx, by + 0.5, bz), WOOD)
		B:block(crop, v(2.3, 0.25, 1.7), cf(bx, by + 0.35, bz), WOODD) -- weave band
		B:block(crop, v(2.45, 0.25, 1.85), cf(bx, by + 1.05, bz), WOODL) -- rim
		B:block(crop, v(0.22, 1.3, 0.22), cf(bx - 1.0, by + 1.7, bz), WOODD) -- handle
		B:block(crop, v(0.22, 1.3, 0.22), cf(bx + 1.0, by + 1.7, bz), WOODD)
		B:block(crop, v(2.2, 0.22, 0.22), cf(bx, by + 2.35, bz), WOODD)
		for _, a in { { -0.5, -0.25 }, { 0.5, 0.25 }, { 0.15, -0.35 } } do
			apple(crop, bx + a[1], by + 1.35, bz + a[2], 0, 0.62, { simple = true })
		end
		apple(crop, bx - 0.1, by + 1.85, bz, 0, 0.62, { simple = true })

		------------------------------------------------------------------
		-- DIVINE BLING: floating cubes + sparkles + drifting leaves
		------------------------------------------------------------------
		local fl = B:bone("Floaters", "Crop", v(0, 14, 0))
		B:block(fl, v(0.9, 0.9, 0.9), cf(8.2, 16.4, -2.0, 45, 45, 0), LEAFL)
		B:block(fl, v(0.7, 0.7, 0.7), cf(-8.0, 12.2, 2.5, 30, 45, 0), LEAF)
		B:block(fl, v(0.85, 0.85, 0.85), cf(-6.5, 18.2, -3.5, 45, 0, 45), RED)
		B:gem(fl, v(0.25, 0.25, 0.25), cf(-6.5, 18.2, -3.5, 45, 0, 45) * CFrame.new(0, 0, -0.38), NEONSHINE, { name = "FloatGlint" })

		local aura = B:block(crop, v(13, 7, 13), cf(0, 14.5, 0), LEAF, { tr = 1, name = "CanopyAura" })
		B:emitter(aura, "sparkle", { name = "AppleSparkle", color = { "#ffffff", "#ffe36b", "#ff8fa0" }, rate = 5, size = { 0.15, 0.5, 0 } })
		B:emitter(aura, "leaf", { name = "FallingLeaves", color = { LEAFL, LEAF }, rate = 1.2, size = { 0.35, 0.35, 0.2 }, speed = { 0.3, 1 }, accel = { 0, -1.5, 0 } })
	end,
}
