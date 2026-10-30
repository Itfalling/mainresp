--!nocheck
-- Sundew Candy Plant (Flytrap Stage crop #3, Rare).
-- A chunky sundew rosette on a stepped bog mound. A ring of six spoon
-- leaves splays out low over the soil, each green pad rimmed in red with
-- sticky red tentacles holding glossy pink dew-drop candies. From the
-- heart rise three tall strap leaves (red-fringed, curling outward at the
-- tip) that each dangle one BIG glossy pink candy drop. Moss pads, stones
-- and a little bog puddle with a lily pad on the mound.
-- Static prop: no motion.luau.
return {
	DisplayName = "Sundew Candy Plant",
	Rarity = "Rare",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ---------------------------------------------------------
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT = "#8d8174", "#a39787"
		local BOG, BOG_LT = "#2f6a50", "#6fb58a"
		local LEAF_DK, LEAF, LEAF_LT = "#2f8a32", "#4fb43a", "#8fd14a"
		local RED_DK, RED, RED_LT = "#9c1f3c", "#d23450", "#ff5c7c"
		local CANDY_DK, CANDY, CANDY_LT, CANDY_HI = "#e0368a", "#ff5fae", "#ff9ccd", "#ffe3f1"
		local GLINT = "#fff0f7"

		local seed = 3303
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function polar(deg, r, y)
			local a = rad(deg)
			return v(math.sin(a) * r, y, -math.cos(a) * r)
		end

		---------------------------------------------------------------- mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.5, 2.3), rnd(1.2, 1.6)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.3)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 5.4, DIRT_DK, 12, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.6, 3.8, DIRT, 8, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.4, 0.4, 2.3, DIRT_LT, 0, {}, 0)

		-- moss pads draped over the tier edges
		for _, m in { { 70, 5.3, 1.12, 2.0, MOSS }, { 160, 5.2, 1.1, 1.8, MOSS_DK }, { 290, 5.3, 1.12, 1.9, MOSS }, { 215, 3.7, 1.7, 1.5, MOSS_DK } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], m[3], -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[4], 0.3, 1.3), c * ang(-12, 0, 0), m[5], S)
		end
		-- stones
		for _, s in { { 4.6, 0.95, 1.6, 0.8, 25, STONE }, { -4.3, 0.95, 2.4, 0.7, -20, STONE_LT } } do
			B:block(soil, v(s[4] * 1.2, s[4], s[4]), cf(s[1], s[2], s[3], rnd(-10, 10), s[5], rnd(-10, 10)), s[6], S)
		end
		-- tiny grass tufts
		for _, g in { { 5.2, -1.6 }, { -5.5, 0.4 }, { 1.4, 5.4 } } do
			B:block(soil, v(0.45, 0.9, 0.45), cf(g[1], 0.95, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.35, 0.6, 0.35), cf(g[1] + 0.35, 0.9, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end
		-- little bog puddle sunk into the front-left of the middle tier
		local BC = v(-2.4, 1.42, -3.1)
		B:block(soil, v(2.2, 0.3, 1.4), CFrame.new(BC) * ang(0, -18, 0), BOG, S)
		B:block(soil, v(1.3, 0.28, 2.0), CFrame.new(BC + v(0.05, -0.02, 0)) * ang(0, -18, 0), BOG, S)
		B:block(soil, v(0.8, 0.1, 0.3), CFrame.new(BC + v(0.35, 0.15, -0.2)) * ang(0, -18, 0), BOG_LT, S)
		B:block(soil, v(0.9, 0.1, 0.9), CFrame.new(BC + v(-0.45, 0.17, 0.15)) * ang(0, 30, 0), LEAF, S)

		------------------------------------------------------------- plant
		local Y0 = 1.8
		local crop = B:bone("Crop", "Root", v(0, Y0, 0))

		-- glossy dew-drop candy: a stepped round drop (light top, glint)
		local function candy(p, s, col, big)
			local c = CFrame.new(p) * ang(0, 45, 0)
			local core = B:block(crop, v(s, s * 0.7, s), c, col)
			if s < 0.75 then
				return core
			end
			B:block(crop, v(s * 0.7, s, s * 0.7), c, col)
			if big then
				B:block(crop, v(s * 1.06, s * 0.36, s * 0.7), c * CFrame.new(0, -s * 0.1, 0), CANDY_DK)
				B:block(crop, v(s * 0.7, s * 0.36, s * 1.06), c * CFrame.new(0, -s * 0.1, 0), CANDY_DK)
				-- drop "neck" on top, light glossy cap and a tiny neon glint
				B:block(crop, v(s * 0.4, s * 0.34, s * 0.4), c * CFrame.new(0, s * 0.6, 0), CANDY_LT)
				B:block(crop, v(s * 0.24, s * 0.24, s * 0.12), CFrame.new(p) * CFrame.new(-s * 0.2, s * 0.22, -s * 0.5),
					GLINT, { mat = "Neon", name = "CandyGlint" })
			end
			return core
		end

		-- heart of the rosette
		B:block(crop, v(2.0, 0.6, 2.0), cf(0, Y0 + 0.3, 0, 0, 45, 0), LEAF_DK)
		B:block(crop, v(1.4, 0.5, 1.4), cf(0, Y0 + 0.75, 0, 0, 20, 0), RED_DK)
		-- chunky leaf cubes bunched around the heart (mass, like the stage plants)
		B:block(crop, v(1.9, 1.9, 1.9), cf(0.7, Y0 + 1.0, 0.8, 14, 30, -10), LEAF_DK)
		B:block(crop, v(1.7, 1.7, 1.7), cf(-0.9, Y0 + 0.95, 0.5, -12, 15, 12), LEAF)
		B:block(crop, v(1.6, 1.6, 1.6), cf(0.1, Y0 + 0.9, -0.9, 10, 50, 8), LEAF_DK)
		-- low leaf cubes tucked between the spoons
		for k, d in { 26, 98, 170, 242, 314 } do
			local sz = rnd(1.4, 1.8)
			B:block(crop, v(sz, sz, sz), CFrame.new(polar(d, 2.2, Y0 + sz * 0.3)) * ang(rnd(-15, 15), rnd(0, 90), rnd(-15, 15)),
				(k % 2 == 0) and LEAF or LEAF_DK)
		end

		------------------------------------------------ low spoon leaves
		local function spoon(deg, len, elev, col)
			local base = polar(deg, 0.6, Y0 + 0.35)
			local f = CFrame.new(base) * CFrame.Angles(0, -rad(deg), 0) * CFrame.Angles(rad(elev), 0, 0)
			local p1 = (f * CFrame.new(0, 0, -len)).Position
			B:bar(crop, base, p1, 0.8, 0.5, LEAF_DK)
			-- pad: flatter than the stalk, tip curling up a little
			local pf = CFrame.new(p1) * CFrame.Angles(0, -rad(deg), 0) * CFrame.Angles(rad(elev * 0.3 + 4), 0, 0)
			local function at(x, y, z)
				return pf * CFrame.new(x, y, z)
			end
			B:block(crop, v(2.7, 0.3, 2.9), at(0, -0.06, -1.2), RED)
			B:block(crop, v(2.2, 0.44, 2.4), at(0, 0.06, -1.15), col)
			B:block(crop, v(0.5, 0.5, 1.8), at(0, 0.1, -1.0), LEAF_DK)
			-- stubby red tentacles along the tip, each holding a candy drop
			for _, q in { { -1.0, -2.3, CANDY_LT }, { 0, -2.6, CANDY }, { 1.0, -2.3, CANDY_LT } } do
				local stub = at(q[1], 0.5, q[2])
				B:block(crop, v(0.36, 0.8, 0.36), stub, RED)
				candy((stub * CFrame.new(0, 0.62, 0)).Position, 0.66, q[3])
			end
			-- one candy resting in the sticky middle of the pad
			candy(at(0, 0.66, -1.2).Position, 1.0, CANDY)
		end
		local SPOONS = {
			{ -10, 2.2, 12, LEAF },
			{ 62, 2.0, 16, LEAF_LT },
			{ 134, 2.2, 12, LEAF },
			{ 206, 2.0, 16, LEAF_LT },
			{ 278, 2.2, 12, LEAF },
		}
		for _, s in SPOONS do
			spoon(s[1], s[2], s[3], s[4])
		end

		------------------------------------------- tall strap leaves
		local function strap(deg, h, reach)
			-- flat strap in a vertical plane facing `deg`: rising, then hooking outward
			local function pt(r, y)
				return polar(deg, r, Y0 + y)
			end
			local pts = {
				pt(0.2, 0.4),
				pt(0.55, h * 0.45),
				pt(1.2, h * 0.8),
				pt(2.2 + reach * 0.4, h),
				pt(3.0 + reach * 0.6, h * 0.88),
			}
			local W = { 1.7, 1.55, 1.35, 1.1 }
			local C = { LEAF_DK, LEAF, LEAF_LT, LEAF }
			for i = 1, #pts - 1 do
				local w = W[i]
				B:bar(crop, pts[i], pts[i + 1], w, 0.65, C[i])
				-- red tentacle fringe: a wider, thinner slab just behind the leaf
				if i >= 2 then
					B:bar(crop, pts[i], pts[i + 1], w + 0.44, 0.34, (i >= 3) and RED or RED_DK)
					local j = P.aim(pts[i - 1], pts[i + 1])
					B:block(crop, v(w + 0.04, 0.72, 0.9), j - j.Position + pts[i], C[i])
				end
			end
			-- the big candy drop dangling from the hooked tip
			local tipP = pts[#pts]
			local hang = tipP + v(0, -0.9, 0)
			B:bar(crop, tipP + v(0, 0.2, 0), hang, 0.36, 0.36, RED_DK)
			return candy(hang + v(0, -1.05, 0), 1.85, CANDY, true)
		end
		local big1 = strap(-40, 8.0, 0.2)
		strap(80, 7.0, 0.0)
		strap(200, 7.6, 0.3)

		---------------------------------------------------------------- bling
		B:emitter(big1, "sparkle", { name = "CandySparkle", color = { "#ffffff", "#ffb3d9" }, rate = 3, size = 0.4 })
		B:light(big1, { name = "CandyGlow", color = "#ff9ccd", brightness = 0.8, range = 10 })
	end,
}
