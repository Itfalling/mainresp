--!nocheck
-- Disco Ball Tree (Bunny Stage #10, Apex) -- the VIP showpiece, in the
-- stud-tree reference style: a big stepped dirt mound with a gold trim band,
-- gem studs, a light-up disco dance floor on its top tier and four little
-- stage spotlights aimed at the tree; a chunky brown trunk with a stepped
-- flare wrapped in a gold chain, four angled branches, and a huge crown of
-- big rotated studded leaf cubes in party purple / hot pink / club cyan.
-- Mirror disco-ball fruits sit half-sunk in the canopy and dangle on gold
-- chains, gold chain garlands swag around the crown, and a big disco ball
-- tops the tree. Spotlight-coloured sparkles and one soft party light.
-- Static prop: no motion.luau.
return {
	DisplayName = "Disco Ball Tree",
	Rarity = "Apex",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2616", "#4c2e1a", "#6b4127", "#7f5032"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local BARK_DK, BARK, BARK_LT = "#4f2c18", "#683b20", "#7d4a2a"
		local GOLD_LT, GOLD, GOLD_DK = "#ffe680", "#ffc928", "#e09a12"
		local PURP_DK, PURP, PURP_LT = "#5b1fc4", "#7e3cf0", "#a874ff"
		local PINK, PINK_LT = "#ff3fb4", "#ff86d4"
		local CYAN, CYAN_LT = "#16c8f0", "#72e6ff"
		local SILVER_LT, SILVER, SILVER_DK = "#ffffff", "#d9e2ee", "#8f9db4"
		local TINTS = { "#ffc4ec", "#bdf3ff", "#fff3b0", "#dcc4ff" }
		local FLOOR = { "#ff3fb4", "#28d2ff", "#ffe23a", "#8c4bff" }
		local N_PINK, N_CYAN, N_YELLOW, N_WHITE = "#ff5cc8", "#4fe6ff", "#fff36a", "#ffffff"
		local CAN = "#26222e"

		local seed = 11
		local function rnd()
			seed = (seed * 1103515245 + 12345) % 2147483648
			return seed / 2147483648
		end
		local function polar(r, deg, y)
			local a = rad(deg)
			return math.sin(a) * r, y, -math.cos(a) * r
		end

		---------------------------------------------------------------- mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(15, 1, 11), cf(0, 0.5, 0), DIRT_DK, S)
		B:block(soil, v(11, 1, 15), cf(0, 0.5, 0), DIRT_DK, S)
		B:block(soil, v(13, 0.98, 13), cf(0, 0.49, 0, 0, 45, 0), DIRT_DK2, S)
		for i = 0, 15 do
			local deg = i * 22.5 + rnd() * 8
			local x, _, z = polar(8.0 + rnd() * 0.5, deg, 0)
			local h = 0.7 + rnd() * 0.7
			B:block(soil, v(2.2 + rnd() * 0.9, h, 1.6 + rnd() * 0.6), cf(x, h / 2, z, 0, -deg + (rnd() - 0.5) * 20, 0),
				(i % 2 == 0) and DIRT_DK or DIRT_DK2, S)
		end
		-- gold trim band + gem studs
		for i = 0, 17 do
			local deg = i * 20
			local x, _, z = polar(7.0, deg, 0)
			B:block(soil, v(2.5, 0.5, 0.8), cf(x, 1.15, z, 0, -deg, 0), (i % 2 == 0) and GOLD or GOLD_DK, S)
			if i % 3 == 0 then
				local gx, _, gz = polar(7.45, deg, 0)
				local gc = ({ N_PINK, N_CYAN, N_YELLOW })[(i // 3) % 3 + 1]
				B:gem(soil, v(0.5, 0.5, 0.5), cf(gx, 1.15, gz, 0, -deg + 45, 0), gc, { name = "Soil" })
			end
		end
		-- middle tier
		B:block(soil, v(11.4, 1, 8.6), cf(0, 1.5, 0), DIRT, S)
		B:block(soil, v(8.6, 1, 11.4), cf(0, 1.5, 0), DIRT, S)
		for i = 0, 9 do
			local deg = i * 36 + 18 + rnd() * 10
			local x, _, z = polar(5.4, deg, 0)
			B:block(soil, v(1.9 + rnd() * 0.6, 0.9 + rnd() * 0.3, 1.5), cf(x, 1.45, z, 0, -deg, 0), (i % 2 == 0) and DIRT or DIRT_LT, S)
		end
		-- top tier: disco dance floor (4x4 tiles, centre under the trunk)
		B:block(soil, v(7.6, 0.5, 7.6), cf(0, 2.25, 0), DIRT_LT, S)
		local ti = 0
		for gx = 0, 4 do
			for gz = 0, 4 do
				local x, z = (gx - 2) * 1.45, (gz - 2) * 1.45
				if not (gx >= 1 and gx <= 3 and gz >= 1 and gz <= 3) then
					ti += 1
					local col = FLOOR[(gx + gz * 3) % 4 + 1]
					local neon = (ti % 3 == 1)
					B:block(soil, v(1.35, 0.3, 1.35), cf(x, 2.6, z), col, { name = "Soil", mat = neon and "Neon" or "Plastic" })
				end
			end
		end
		-- stage spotlights on the mound aimed up at the crown
		local spots = { { 45, N_PINK }, { 135, N_CYAN }, { 225, N_YELLOW }, { 315, N_CYAN } }
		for k, s in spots do
			local x, _, z = polar(5.9, s[1], 0)
			B:block(soil, v(1.1, 0.5, 1.1), cf(x, 2.2, z, 0, -s[1], 0), CAN, S)
			local C = cf(x, 2.95, z, 0, -s[1], 0) * ang(-55, 0, 0)
			B:block(soil, v(1.0, 1.0, 1.4), C, CAN, S)
			B:block(soil, v(0.75, 0.75, 0.2), C * CFrame.new(0, 0, 0.72), s[2], { name = "Soil", mat = "Neon" })
			B:block(soil, v(1.2, 0.2, 0.3), C * CFrame.new(0, 0.55, 0.55), GOLD, S)
			-- faint see-through light beam up into the crown
			B:block(soil, v(0.6, 0.6, 5.2), C * CFrame.new(0, 0, 0.85 + 2.6), s[2], { name = "Soil", mat = "Neon", tr = 0.78 })
		end
		-- grass tufts
		local grass = { { -8.3, 3.9 }, { 8.8, 1.6 }, { 2.4, 8.7 }, { -3.4, -8.5 }, { 6.9, -5.9 }, { -6.6, -5.4 } }
		for i, g in grass do
			local h = 0.9 + (i % 2) * 0.5
			B:block(soil, v(0.55, h, 0.55), cf(g[1], h / 2, g[2], 0, i * 23, 0), (i % 2 == 0) and GRASS or GRASS_DK, S)
			B:block(soil, v(0.45, h * 0.6, 0.45), cf(g[1] + 0.5, h * 0.3, g[2] + 0.2, 0, i * 31, 0), GRASS_DK, S)
		end

		---------------------------------------------------------------- crop
		local BASE = 2.75
		local crop = B:bone("Crop", "Root", v(0, BASE, 0))

		-- trunk: stepped flare, tapering column
		B:block(crop, v(4.4, 0.9, 4.4), cf(0, BASE + 0.35, 0), BARK_DK)
		B:block(crop, v(4.0, 1.0, 4.0), cf(0, BASE + 1.25, 0, 0, 45, 0), BARK)
		B:block(crop, v(3.5, 1.2, 3.5), cf(0, BASE + 2.3, 0), BARK_DK)
		B:block(crop, v(3.0, 3.4, 3.0), cf(0, BASE + 4.5, 0, 0, 8, 0), BARK)
		B:block(crop, v(2.6, 3.4, 2.6), cf(0.1, BASE + 7.6, 0, 0, -6, 2), BARK_LT)
		B:block(crop, v(2.3, 2.4, 2.3), cf(0.2, BASE + 10.2, 0, 0, 10, 3), BARK)
		-- roots poking out of the flare
		for k = 0, 3 do
			local deg = k * 90 + 45
			local x, _, z = polar(2.5, deg, 0)
			B:block(crop, v(1.2, 0.8, 1.8), cf(x, BASE + 0.25, z, 0, -deg, 0), BARK_DK)
		end
		-- branches into the canopy
		local branchTips = {}
		local br = { { 20, 7.5, 4.6, 13.3 }, { 110, 8.4, 4.4, 13.8 }, { 200, 7.8, 4.8, 13.2 }, { 290, 8.8, 4.2, 14.2 } }
		for _, b in br do
			local x0, _, z0 = polar(0.6, b[1], 0)
			local x1, _, z1 = polar(b[3], b[1], 0)
			B:beam(crop, v(x0, BASE + b[2], z0), v(x1, b[4], z1), 1.5, 1.5, BARK)
			B:beam(crop, v(x1 * 0.8, b[4] - 0.4, z1 * 0.8), v(x1 * 1.25, b[4] + 1.6, z1 * 1.25), 1.1, 1.1, BARK_LT)
			table.insert(branchTips, v(x1, b[4], z1))
		end
		-- gold chain spiralling up the trunk
		local function chain(pts, linkLen, name)
			local n = 0
			for i = 1, #pts - 1 do
				local a, b = pts[i], pts[i + 1]
				local len = (b - a).Magnitude
				local steps = math.max(1, math.floor(len / linkLen + 0.5))
				for s = 0, steps - 1 do
					local p0 = a:Lerp(b, s / steps)
					local p1 = a:Lerp(b, (s + 1) / steps)
					local c, l = P.span(p0, p1)
					n += 1
					local roll = (n % 2 == 0) and 90 or 0
					B:block(crop, v(0.4, 0.7, l + 0.12), c * ang(0, 0, roll), (n % 2 == 0) and GOLD or GOLD_DK, { name = name })
				end
			end
		end
		do
			local pts = {}
			for i = 0, 16 do
				local t = i / 16
				local deg = t * 540
				local rr = 1.75 - t * 0.3
				local x, _, z = polar(rr, deg, 0)
				table.insert(pts, v(x, BASE + 3.2 + t * 7.2, z))
			end
			chain(pts, 0.75, "TrunkChain")
		end

		-- canopy: big rotated studded leaf cubes in party colours
		local canopy = {
			-- lower ring
			{ 0, 6.0, 13.1, 5.2, PURP, 18, 12, 8 },
			{ 60, 6.2, 13.4, 5.0, PINK, -10, 30, 14 },
			{ 120, 6.0, 12.9, 5.4, PURP_DK, 12, -20, -10 },
			{ 180, 6.1, 13.3, 5.0, PURP_LT, -16, 8, 12 },
			{ 240, 6.0, 13.0, 5.3, CYAN, 8, 40, -14 },
			{ 300, 6.2, 13.5, 4.9, PURP, -12, -18, 10 },
			-- outer fillers for a round silhouette
			{ 30, 7.5, 15.2, 3.8, PURP_LT, 25, 15, 20 },
			{ 150, 7.4, 15.0, 3.6, PINK, -20, 35, -15 },
			{ 270, 7.5, 15.4, 3.8, PURP_DK, 15, -25, 18 },
			{ 90, 7.3, 14.8, 3.4, PURP, -25, 5, -20 },
			{ 210, 7.2, 14.6, 3.4, PURP_LT, 22, -10, 25 },
			{ 330, 7.3, 15.0, 3.5, CYAN_LT, -15, 20, -22 },
			-- middle ring
			{ 36, 3.9, 15.6, 5.6, PURP_DK, 10, 25, -8 },
			{ 108, 4.0, 16.0, 5.4, PURP_LT, -14, -12, 12 },
			{ 180, 3.8, 15.4, 5.8, PURP, 16, 40, 10 },
			{ 252, 4.0, 15.8, 5.5, PINK_LT, -8, 10, -16 },
			{ 324, 3.9, 16.1, 5.4, PURP, 12, -30, 14 },
			-- core + top
			{ 0, 0.0, 14.2, 6.0, PURP_DK, 0, 20, 0 },
			{ 70, 2.0, 18.5, 4.8, CYAN, 18, 15, -12 },
			{ 190, 2.1, 18.3, 5.0, PURP_LT, -15, -25, 10 },
			{ 300, 2.0, 18.7, 4.6, PINK, 12, 35, 16 },
			{ 0, 0.0, 19.5, 4.2, PURP, 10, 45, -8 },
		}
		local cubes = {}
		for _, c in canopy do
			local x, _, z = polar(c[2], c[1], 0)
			local C = cf(x, c[3], z, c[6], c[7], c[8])
			B:block(crop, v(c[4], c[4], c[4]), C, c[5])
			table.insert(cubes, { pos = v(x, c[3], z), size = c[4], deg = c[1], r = c[2] })
		end

		-- disco ball: a mirror cube with offset facet plates + neon glints
		local discoN = 0
		local function disco(pos, s, yaw, tilt, glint)
			discoN += 1
			local C = cf(pos.X, pos.Y, pos.Z, tilt, yaw, tilt * 0.6)
			B:block(crop, v(s, s, s), C, SILVER)
			B:block(crop, v(s * 1.08, s * 0.72, s * 0.72), C, SILVER_LT)
			B:block(crop, v(s * 0.72, s * 1.08, s * 0.72), C, SILVER_DK)
			B:block(crop, v(s * 0.72, s * 0.72, s * 1.08), C, TINTS[discoN % 4 + 1])
			local g
			if glint then
				local gc = ({ N_WHITE, N_PINK, N_CYAN, N_YELLOW })[discoN % 4 + 1]
				g = B:gem(crop, v(s * 0.22, s * 0.22, s * 0.22), C * CFrame.new(s * 0.3, s * 0.3, -s * 0.55), gc, { name = "DiscoGlint" .. discoN })
			end
			return g
		end

		-- fruit half-sunk on the canopy cube faces
		local glints = {}
		local sunk = {
			{ 1, 0, 0.2 }, { 2, 0, -0.6 }, { 3, 0, 0.4 }, { 4, 0, -0.3 }, { 5, 0, 0.5 }, { 6, 0, -0.2 },
			{ 7, 0, 0.3 }, { 8, 0, -0.4 }, { 9, 0, 0.2 }, { 13, 0, 0.8 }, { 15, 0, 0.6 }, { 16, 0, 1.0 },
			{ 19, 0, 0.9 }, { 21, 0, 0.7 },
		}
		for k, sdef in sunk do
			local c = cubes[sdef[1]]
			local a = rad(c.deg)
			local out = v(math.sin(a), 0, -math.cos(a))
			local p = c.pos + out * (c.size * 0.5 + 0.05) + v(0, sdef[3], 0)
			local g = disco(p, 1.6, c.deg + 15 * k, 12 + (k % 3) * 8, true)
			if g then table.insert(glints, g) end
		end
		-- fruit dangling under the canopy on short gold chains
		local hang = { { 30, 6.2, 10.1 }, { 95, 5.4, 10.4 }, { 160, 6.0, 10.0 }, { 220, 5.6, 10.3 }, { 280, 6.4, 10.2 }, { 345, 5.2, 10.4 } }
		for k, h in hang do
			local x, _, z = polar(h[2], h[1], 0)
			local top = v(x, h[3] + 1.9, z)
			local bot = v(x, h[3] + 0.75, z)
			chain({ top, bot }, 0.55, "HangChain")
			local g = disco(v(x, h[3], z), 1.7, h[1] * 2, 10, true)
			table.insert(glints, g)
		end

		-- gold chain garlands swagging around the crown
		for k = 0, 5 do
			local d0, d1 = k * 60 + 8, k * 60 + 52
			local x0, _, z0 = polar(8.7, d0, 0)
			local x1, _, z1 = polar(8.7, d1, 0)
			local a, b = v(x0, 12.5, z0), v(x1, 12.5, z1)
			local pts = {}
			for i = 0, 6 do
				local t = i / 6
				local p = a:Lerp(b, t)
				local mid = v(p.X, 0, p.Z).Unit * (v(p.X, 0, p.Z).Magnitude + 1.4 * math.sin(t * math.pi))
				table.insert(pts, v(mid.X, p.Y - 1.6 * math.sin(t * math.pi), mid.Z))
			end
			chain(pts, 0.8, "Garland")
			-- a small gem bead at the swag low point
			local lp = pts[4]
			B:gem(crop, v(0.45, 0.45, 0.45), cf(lp.X, lp.Y - 0.35, lp.Z, 45, k * 30, 45), (k % 2 == 0) and N_PINK or N_CYAN, { name = "GarlandGem" .. (k + 1) })
		end

		-- the big disco-ball topper on a gold cap
		local TOPY = 21.9
		B:block(crop, v(1.8, 0.6, 1.8), cf(0, TOPY - 1.9, 0, 0, 45, 0), GOLD)
		B:block(crop, v(0.5, 0.8, 0.5), cf(0, TOPY - 1.5, 0), GOLD_DK)
		disco(v(0, TOPY, 0), 3.0, 20, 15, false)
		local topGlints = {}
		local tg = { { 0.9, 0.9, -1.62, N_WHITE }, { -0.9, -0.4, -1.62, N_PINK }, { 1.62, -0.7, 0.5, N_CYAN }, { -1.62, 0.7, 0.6, N_YELLOW }, { 0.4, 1.62, 0.8, N_WHITE } }
		for i, g in tg do
			local C = cf(0, TOPY, 0, 15, 20, 9) * CFrame.new(g[1], g[2], g[3])
			table.insert(topGlints, B:gem(crop, v(0.4, 0.4, 0.4), C, g[4], { name = "TopGlint" .. i }))
		end

		-- effects: spotlight-coloured sparkles + one soft party light
		B:emitter(topGlints[1], "sparkle", { name = "DiscoSparkle", color = { N_PINK, N_CYAN, N_YELLOW, "#b47bff" }, rate = 9, size = { 0.2, 0.7, 0 }, speed = { 1.5, 3.5 }, life = { 1, 2 } })
		B:emitter(glints[1], "sparkle", { name = "CanopySparkle", color = { N_CYAN, N_WHITE, N_PINK }, rate = 6, size = { 0.15, 0.55, 0 } })
		B:emitter(glints[#glints], "sparkle", { name = "CanopySparkle2", color = { N_YELLOW, N_WHITE, "#b47bff" }, rate = 6, size = { 0.15, 0.55, 0 } })
		B:emitter(glints[8], "sparkle", { name = "CanopySparkle3", color = { N_PINK, N_CYAN }, rate = 5, size = { 0.15, 0.5, 0 } })
		B:emitter(topGlints[3], "glow", { name = "PartyGlow", color = { "#ff7ad8", "#7fe8ff" }, rate = 1.5 })
		B:light(topGlints[2], { color = "#e7a2ff", brightness = 1.4, range = 18, name = "PartyLight" })
	end,
}
