--!nocheck
-- Wisp Lantern Plant (Misty Swamp crop #7, Secret).
-- A stepped mound of dark swamp mud with moss pads, mossy stones, reeds and a
-- murky little puddle with lily pads. From a clump of broad teal strap leaves
-- rise tall, jointed swamp stalks that arch over at the top like shepherd's
-- crooks; from every crook hangs a "wisp-bulb" lantern - a ribbed violet husk
-- cage with pale glassy panels and a glowing cyan wisp-flame inside, a little
-- violet calyx cap on top and a glowing drip at the bottom. Smaller closed
-- lantern buds hang lower down. VFX: wisp motes drifting up out of the
-- lanterns, a soft wisp aura, swamp fireflies, low creeping mist, puddle
-- bubbles, a cyan + a violet light. Static prop: no motion.luau.
return {
	DisplayName = "Wisp Lantern Plant",
	Rarity = "Secret",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Misty Swamp)
		local MUD_DK, MUD_DK2, MUD, MUD_LT = "#2a231d", "#33291f", "#43372a", "#56473a"
		local MOSS_DK, MOSS, MOSS_LT = "#3d6a32", "#55893c", "#7fae4c"
		local STONE_DK, STONE, STONE_LT = "#4f5a57", "#6c7773", "#8a9590"
		local WATER_DK, WATER, WATER_LT = "#1d4a4a", "#2a6a66", "#5fa59c"
		local PAD, PAD_DK, PAD_LT = "#3f8f4a", "#2d6b3a", "#6fbf5c"
		local REED, REED_DK, CATTAIL = "#6f8a3c", "#56702f", "#4a2e1c"
		local LF_DK, LF, LF_LT, LF_HI = "#2f6e3c", "#3f8a48", "#5aa856", "#86c96a"
		local STK_DK, STK, STK_LT = "#173f3d", "#215550", "#2c6a62"
		local VIO_DK, VIO, VIO_LT, VIO_HI = "#3f2466", "#5b3590", "#7d52b8", "#a982e0"
		local GLASS = "#7fefff"
		local WISP, WISP_LT = "#5ff2ff", "#c8fff8"
		local NEON = { mat = "Neon" }

		local seed = 9157
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function round(bone, c, r, h, col, opts)
			B:block(bone, v(2 * r, h, 1.1 * r), c, col, opts)
			B:block(bone, v(1.1 * r, h - 0.04, 2 * r), c, col, opts)
			B:block(bone, v(1.72 * r, h - 0.08, 1.72 * r), c, col, opts)
		end

		---------------------------------------------------------------- swamp mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			round(soil, CFrame.new(0, y0 + h / 2, 0), r, h, col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.4, 2.3), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 6.6, MUD_DK, 16, { MUD_DK, MUD_DK2, MUD_DK, MOSS_DK }, 0.35)
		tier(0.8, 0.7, 4.9, MUD, 11, { MUD, MUD_LT, MUD, MOSS_DK }, 0.3)
		tier(1.5, 0.5, 3.0, MUD_LT, 0, {}, 0)
		local TOP = 2.0

		-- moss pads draped over the tier edges
		for _, m in { { 25, 6.3, 0.82, 2.4 }, { 95, 6.4, 0.82, 1.8 }, { 160, 6.2, 0.82, 2.2 }, { 300, 6.3, 0.82, 2.0 }, { 60, 4.6, 1.52, 1.8 }, { 230, 4.6, 1.52, 2.0 }, { 330, 4.5, 1.52, 1.6 }, { 140, 2.7, 2.02, 1.5 } } do
			local c = CFrame.Angles(0, rad(m[1]), 0) * CFrame.new(0, m[3], -m[2] + 0.5)
			B:block(soil, v(m[4], 0.22, 1.3), c * ang(0, rnd(-10, 10), 0), MOSS, S)
			B:block(soil, v(m[4] * 0.6, 0.26, 0.8), c * CFrame.new(rnd(-0.3, 0.3), 0.04, -0.2), MOSS_LT, S)
			B:block(soil, v(m[4] * 0.7, 0.5, 0.25), c * CFrame.new(0, -0.18, -0.7), MOSS_DK, S)
		end

		-- moss mats + roots on the top tier
		for _, m in { { -1.8, 1.4, 2.2, 1.6, 20 }, { 1.9, 1.6, 1.8, 1.4, -30 }, { -2.0, -1.0, 1.6, 1.2, 50 } } do
			B:block(soil, v(m[3], 0.2, m[4]), cf(m[1], 2.05, m[2], 0, m[5], 0), MOSS, S)
			B:block(soil, v(m[3] * 0.5, 0.24, m[4] * 0.5), cf(m[1] + 0.2, 2.07, m[2] - 0.1, 0, m[5] + 20, 0), MOSS_LT, S)
		end
		for _, r in { 30, 150, 260 } do
			local d = v(math.sin(rad(r)), 0, -math.cos(rad(r)))
			B:bar(soil, d * 1.2 + v(0, 2.1, 0), d * 3.6 + v(0, 1.55, 0), 0.5, 0.4, "#3a2a1e", S)
			B:bar(soil, d * 3.5 + v(0, 1.6, 0), d * 4.9 + v(0, 0.95, 0), 0.4, 0.35, "#3a2a1e", S)
		end

		-- murky puddle (front-right) with lily pads
		local PC = v(3.1, 0, -3.3)
		B:block(soil, v(4.0, 0.2, 2.6), cf(PC.X, 1.5, PC.Z, 0, -35, 0), WATER, S)
		B:block(soil, v(2.8, 0.19, 3.4), cf(PC.X, 1.5, PC.Z, 0, -35, 0), WATER, S)
		B:block(soil, v(2.2, 0.21, 1.6), cf(PC.X + 0.3, 1.51, PC.Z + 0.2, 0, -10, 0), WATER_DK, S)
		B:block(soil, v(1.8, 0.22, 0.25), cf(PC.X - 0.4, 1.52, PC.Z - 0.8, 0, -30, 0), WATER_LT, S)
		local function lily(x, z, s, a, col)
			local c = cf(x, 1.63, z, 0, a, 0)
			B:block(soil, v(1.5 * s, 0.12, 1.0 * s), c, col, S)
			B:block(soil, v(1.0 * s, 0.11, 1.5 * s), c, col, S)
			B:block(soil, v(0.45 * s, 0.14, 0.6 * s), c * CFrame.new(0, 0.01, -0.55 * s), WATER, S)
			B:block(soil, v(0.35 * s, 0.15, 0.35 * s), c * CFrame.new(0.1 * s, 0.02, 0.15 * s), PAD_LT, S)
			return c
		end
		lily(PC.X + 0.9, PC.Z - 0.3, 0.9, 25, PAD)
		local lp = lily(PC.X - 0.8, PC.Z + 0.5, 0.75, -40, PAD_DK)
		B:block(soil, v(0.32, 0.32, 0.32), lp * CFrame.new(0.1, 0.2, 0.1) * ang(0, 45, 0), VIO_HI, S)
		-- puddle rim stones
		local function stone(x, y, z, s, ry, moss)
			local c = cf(x, y, z, rnd(-6, 6), ry, rnd(-6, 6))
			B:block(soil, v(1.3 * s, 0.85 * s, 1.1 * s), c, STONE, S)
			B:block(soil, v(0.9 * s, 0.4 * s, 0.8 * s), c * CFrame.new(0.15 * s, 0.5 * s, 0.05 * s) * ang(0, 20, 0), STONE_LT, S)
			B:block(soil, v(1.34 * s, 0.25 * s, 1.14 * s), c * CFrame.new(0, -0.25 * s, 0), STONE_DK, S)
			if moss then
				B:block(soil, v(1.0 * s, 0.18, 0.9 * s), c * CFrame.new(-0.1 * s, 0.5 * s, 0), MOSS_LT, S)
			end
		end
		stone(5.0, 1.2, -1.6, 0.9, 20, true)
		stone(1.4, 1.2, -4.9, 0.75, -15, false)
		stone(-5.4, 0.9, 2.2, 1.1, 40, true)
		stone(-3.6, 1.05, -4.7, 0.8, 5, false)
		stone(4.0, 0.9, 4.6, 0.85, -30, true)
		-- reeds + cattails (back-right and left)
		local function reed(x, y, z, h, tz, tx, cat)
			local base = v(x, y, z)
			local tip = base + v(-math.sin(rad(tz)) * h, h, math.sin(rad(tx)) * h)
			B:bar(soil, base, tip, 0.22, 0.22, pick({ REED, REED_DK }), S)
			if cat then
				local d = (tip - base).Unit
				B:bar(soil, tip - d * 0.2, tip + d * 0.9, 0.42, 0.42, CATTAIL, S)
				B:bar(soil, tip + d * 0.85, tip + d * 1.3, 0.12, 0.12, REED_DK, S)
			end
		end
		reed(5.2, 0.8, 1.8, 3.6, -8, 4, true)
		reed(5.6, 0.8, 2.6, 2.8, -14, -4, false)
		reed(4.8, 0.8, 2.4, 3.0, 4, 8, true)
		reed(-5.5, 0.8, -1.0, 3.2, 10, -6, true)
		reed(-5.9, 0.8, -0.2, 2.4, 16, 2, false)
		reed(-1.0, 0.8, 6.0, 3.0, 4, 12, true)
		reed(-0.4, 0.8, 6.1, 2.2, -10, 14, false)
		-- tiny teal swamp mushrooms
		local function shroom(x, y, z, k)
			B:block(soil, v(0.3 * k, 0.7 * k, 0.3 * k), cf(x, y + 0.35 * k, z), "#cfe3d6", S)
			B:block(soil, v(0.9 * k, 0.3 * k, 0.9 * k), cf(x, y + 0.8 * k, z, 0, 45, 0), "#2fa39a", S)
			B:block(soil, v(0.5 * k, 0.2 * k, 0.5 * k), cf(x, y + 1.0 * k, z, 0, 45, 0), "#57cfc0", S)
		end
		shroom(-3.4, 1.5, -2.6, 1.0)
		shroom(-2.9, 1.5, -3.2, 0.7)
		shroom(2.4, 2.0, 2.0, 0.8)
		shroom(-6.0, 0.8, -2.6, 0.8)

		---------------------------------------------------------------- the plant
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		-- root crown
		round(crop, CFrame.new(0, TOP + 0.2, 0), 1.6, 0.5, LF_DK)
		round(crop, CFrame.new(0, TOP + 0.6, 0) * ang(0, 30, 0), 1.1, 0.4, STK_DK)

		-- chunky moss/leaf clump at the root crown
		for i = 0, 5 do
			local a = i * 60 + rnd(-12, 12)
			local c = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, TOP + 0.7, -1.4)
			B:block(crop, v(1.5, 1.2, 1.5), c * ang(rnd(-20, 20), rnd(0, 45), rnd(-20, 20)), pick({ MOSS, MOSS_DK, LF_DK }))
		end
		-- broad iris-like blades fanning up out of the clump (face outward)
		local function blade(a, s, w, colA, colB)
			local dir = v(math.sin(rad(a)), 0, -math.cos(rad(a)))
			local p0 = v(0, TOP + 0.4, 0) + dir * 0.5
			local p1 = p0 + dir * 0.7 * s + v(0, 2.3 * s, 0)
			local p2 = p1 + dir * 1.0 * s + v(0, 1.7 * s, 0)
			local p3 = p2 + dir * 1.2 * s + v(0, 0.3 * s, 0)
			B:bar(crop, p0, p1, w, 0.4, colA, { up = dir })
			B:bar(crop, p1 - (p1 - p0).Unit * 0.25, p2, w * 0.8, 0.38, colB, { up = dir })
			B:bar(crop, p2 - (p2 - p1).Unit * 0.25, p3, w * 0.5, 0.36, colA, { up = dir })
			B:bar(crop, p0 + dir * 0.22, p1 + dir * 0.22, w * 0.2, 0.1, LF_HI, { up = dir })
		end
		for i = 0, 8 do
			local a = i * 40 + rnd(-8, 8)
			blade(a, 1.1 + rnd(-0.15, 0.2), 1.5, (i % 2 == 0) and LF or LF_DK, (i % 2 == 0) and LF_LT or LF)
		end
		for i = 0, 4 do
			blade(i * 72 + 20, 0.75, 1.2, LF_LT, LF_HI)
		end

		-- WISP LANTERN (hanging from point `top`, scale k)
		local cores = {}
		local function lantern(top, k, yaw, glowing)
			local F = CFrame.new(top) * CFrame.Angles(0, rad(yaw), 0)
			local function at(x, y, z)
				return F * CFrame.new(x * k, y * k, z * k)
			end
			-- hanging stem + calyx cap
			B:block(crop, v(0.3 * k, 0.7 * k, 0.3 * k), at(0, -0.3, 0), STK_DK)
			B:block(crop, v(1.3 * k, 0.4 * k, 1.3 * k), at(0, -0.75, 0) * ang(0, 45, 0), VIO_DK)
			B:block(crop, v(1.0 * k, 0.3 * k, 1.0 * k), at(0, -0.5, 0), VIO)
			for i = 0, 3 do
				B:block(crop, v(0.55 * k, 0.22 * k, 0.75 * k), F * CFrame.Angles(0, rad(i * 90), 0) * CFrame.new(0, -0.85 * k, -0.85 * k) * ang(-30, 0, 0), VIO_LT)
			end
			-- husk cage: 4 bulging corner ribs
			for i = 0, 3 do
				local q = F * CFrame.Angles(0, rad(i * 90 + 45), 0)
				local a = (q * CFrame.new(0, -0.9 * k, -0.55 * k)).Position
				local b = (q * CFrame.new(0, -1.9 * k, -1.05 * k)).Position
				local c = (q * CFrame.new(0, -3.0 * k, -0.95 * k)).Position
				local d = (q * CFrame.new(0, -3.8 * k, -0.4 * k)).Position
				B:bar(crop, a, b, 0.32 * k, 0.32 * k, VIO)
				B:bar(crop, b, c, 0.34 * k, 0.34 * k, VIO_LT)
				B:bar(crop, c, d, 0.32 * k, 0.32 * k, VIO)
			end
			-- glassy panels
			B:block(crop, v(1.9 * k, 2.0 * k, 1.9 * k), at(0, -2.45, 0), GLASS, { tr = 0.55 })
			B:block(crop, v(1.3 * k, 0.6 * k, 1.3 * k), at(0, -1.2, 0), GLASS, { tr = 0.55 })
			B:block(crop, v(1.2 * k, 0.5 * k, 1.2 * k), at(0, -3.6, 0), GLASS, { tr = 0.55 })
			-- mid band
			B:block(crop, v(2.05 * k, 0.28 * k, 2.05 * k), at(0, -2.45, 0) * ang(0, 45, 0), VIO_DK)
			-- wisp flame core
			local core
			if glowing then
				core = B:block(crop, v(1.1 * k, 1.1 * k, 1.1 * k), at(0, -2.4, 0) * ang(45, 0, 45), WISP, { mat = "Neon", name = "WispCore" })
				B:block(crop, v(0.45 * k, 0.75 * k, 0.45 * k), at(0, -1.6, 0) * ang(0, 45, 0), WISP_LT, { mat = "Neon", name = "WispFlame" })
			else
				core = B:block(crop, v(0.9 * k, 0.9 * k, 0.9 * k), at(0, -2.4, 0) * ang(45, 0, 45), VIO_HI)
			end
			-- bottom cap + glowing drip
			B:block(crop, v(0.9 * k, 0.35 * k, 0.9 * k), at(0, -4.0, 0) * ang(0, 45, 0), VIO_DK)
			if glowing then
				B:block(crop, v(0.35 * k, 0.5 * k, 0.35 * k), at(0, -4.4, 0), WISP, NEON)
			end
			table.insert(cores, core)
			return core
		end

		-- closed bud: little stepped violet pod
		local function bud(top, k)
			local F = CFrame.new(top)
			B:block(crop, v(0.25 * k, 0.6 * k, 0.25 * k), F * CFrame.new(0, -0.3 * k, 0), STK_DK)
			B:block(crop, v(0.9 * k, 0.4 * k, 0.9 * k), F * CFrame.new(0, -0.7 * k, 0) * ang(0, 45, 0), VIO_DK)
			B:block(crop, v(1.1 * k, 1.1 * k, 1.1 * k), F * CFrame.new(0, -1.4 * k, 0), VIO)
			B:block(crop, v(0.7 * k, 0.6 * k, 0.7 * k), F * CFrame.new(0, -2.1 * k, 0) * ang(0, 45, 0), VIO_LT)
			B:block(crop, v(1.15 * k, 0.25 * k, 0.4 * k), F * CFrame.new(0, -1.4 * k, 0), VIO_HI)
		end

		-- jointed stalk that arches over into a crook; returns hanging point
		local function stalk(base, a, H, lean, crook, w)
			local dir = v(math.sin(rad(a)), 0, -math.cos(rad(a)))
			local pts = {
				base,
				base + dir * lean * 0.1 + v(0, H * 0.28, 0),
				base + dir * lean * 0.3 + v(0, H * 0.55, 0),
				base + dir * lean * 0.6 + v(0, H * 0.8, 0),
				base + dir * lean + v(0, H, 0),
			}
			local tip = pts[5]
			table.insert(pts, tip + dir * crook * 0.55 + v(0, crook * 0.55, 0))
			table.insert(pts, tip + dir * crook * 1.3 + v(0, crook * 0.6, 0))
			table.insert(pts, tip + dir * crook * 1.8 + v(0, crook * 0.15, 0))
			for i = 1, #pts - 1 do
				local t = (i - 1) / (#pts - 1)
				local ww = w * (1 - 0.45 * t)
				local p, q = pts[i], pts[i + 1]
				B:bar(crop, p - (q - p).Unit * 0.12, q + (q - p).Unit * 0.12, ww, ww, (i % 2 == 0) and STK_LT or STK)
				if i < #pts - 1 then
					-- node ring
					B:block(crop, v(ww + 0.25, 0.3, ww + 0.25), CFrame.new(q) * ang(0, 45 + a, 0), STK_DK)
				end
			end
			return pts, dir
		end
		-- small leaf pair at a node
		local function nodeLeaf(p, a, len, col)
			local dir = v(math.sin(rad(a)), 0, -math.cos(rad(a)))
			local p1 = p + dir * len * 0.6 + v(0, len * 0.45, 0)
			local p2 = p1 + dir * len * 0.5 + v(0, -len * 0.05, 0)
			B:bar(crop, p, p1, 1.0, 0.26, col, { up = v(0, 1, 0) })
			B:bar(crop, p1 - (p1 - p).Unit * 0.15, p2, 0.7, 0.24, LF_LT, { up = v(0, 1, 0) })
		end

		local stalks = {
			-- base offset, yaw, height, lean, crook, width, lantern scale
			{ v(0.2, TOP + 0.5, 0.3), -10, 17.0, 1.2, 1.8, 0.95, 1.5 },
			{ v(-0.6, TOP + 0.5, -0.2), -125, 13.6, 2.8, 1.6, 0.78, 1.2 },
			{ v(0.6, TOP + 0.5, -0.4), 128, 11.4, 3.0, 1.5, 0.7, 1.1 },
			{ v(0.3, TOP + 0.5, 0.6), -172, 9.0, 3.0, 1.4, 0.64, 1.0 },
			{ v(0.4, TOP + 0.5, -0.5), 58, 6.6, 3.2, 1.2, 0.58, 0.9 },
		}
		local hangs = {}
		for i, s in stalks do
			local pts, dir = stalk(s[1], s[2], s[3], s[4], s[5], s[6])
			local hang = pts[#pts]
			table.insert(hangs, hang)
			-- little curled tendril past the crook
			local t1 = hang + dir * 0.5 * s[5] - v(0, 0.35 * s[5], 0)
			local t2 = t1 - dir * 0.15 * s[5] - v(0, 0.35 * s[5], 0)
			B:bar(crop, hang, t1, 0.28, 0.28, STK_LT)
			B:bar(crop, t1, t2, 0.22, 0.22, LF_LT)
			lantern(hang - v(0, 0.05, 0), s[7], s[2] + 20, true)
			-- leaves at the lower nodes
			nodeLeaf(pts[2], s[2] + 70, 2.4, LF)
			if i <= 3 then
				nodeLeaf(pts[3], s[2] - 80, 2.1, LF_DK)
			end
		end
		-- closed buds hanging from short side spurs on the tall stalks
		local function spur(from, a, len)
			local dir = v(math.sin(rad(a)), 0, -math.cos(rad(a)))
			local p1 = from + dir * len + v(0, len * 0.4, 0)
			B:bar(crop, from, p1, 0.32, 0.32, STK)
			return p1
		end
		bud(spur(v(0.2, TOP + 0.5, 0.3) + v(-0.2, 9.5, 0), 70, 1.6), 0.8)
		bud(spur(v(-0.6, TOP + 0.5, -0.2) + v(-1.0, 7.5, 0.8), 200, 1.4), 0.7)

		-- free-floating wisps drifting around the lanterns
		local wisps = {}
		for _, w in { { -3.6, 15.5, -1.6, 0.8 }, { 3.4, 17.6, 1.4, 0.7 }, { -1.4, 10.2, -3.6, 0.6 } } do
			local c = cf(w[1], w[2], w[3], 45, 20, 45)
			B:block(crop, v(w[4], w[4], w[4]), c, WISP_LT, { mat = "Neon", name = "Wisp" })
			B:block(crop, v(w[4] * 1.7, w[4] * 1.7, w[4] * 1.7), cf(w[1], w[2], w[3], 0, 30, 0), GLASS, { tr = 0.6 })
			table.insert(wisps, B:block(crop, v(w[4] * 0.5, w[4] * 1.1, w[4] * 0.5), cf(w[1], w[2] - w[4] * 1.15, w[3], 0, 30, 0), WISP, { tr = 0.3 }))
		end

		---------------------------------------------------------------- VFX
		local main = cores[1]
		B:emitter(main, "glow", { name = "WispAura", color = { WISP_LT, WISP }, rate = 1.6, size = { 1.6, 2.6, 0.6 }, trans = { 0.8, 0.7, 1 }, light = 1 })
		B:emitter(main, "sparkle", { name = "WispMotes", color = { "#ffffff", WISP }, rate = 5, size = { 0.15, 0.4, 0 }, speed = { 0.3, 0.8 }, life = { 1.5, 2.6 }, accel = { 0, 0.8, 0 }, light = 1 })
		B:emitter(cores[2], "sparkle", { name = "WispMotes2", color = { "#ffffff", WISP }, rate = 3, size = { 0.12, 0.35, 0 }, speed = { 0.2, 0.6 }, life = { 1.4, 2.4 }, accel = { 0, 0.8, 0 }, light = 1 })
		B:emitter(cores[3], "sparkle", { name = "WispMotes3", color = { "#ffffff", VIO_HI }, rate = 3, size = { 0.12, 0.35, 0 }, speed = { 0.2, 0.6 }, life = { 1.4, 2.4 }, accel = { 0, 0.8, 0 }, light = 1 })
		local ff = B:block(crop, v(12, 9, 12), cf(0, 11, 0), WISP, { tr = 1, name = "FireflyZone" })
		B:emitter(ff, "sparkle", { name = "Fireflies", color = { "#e6ff7a", "#9dff6a" }, rate = 4, size = { 0.12, 0.3, 0 }, speed = { 0.1, 0.4 }, life = { 2, 3.5 } })
		local mist = B:block(soil, v(11, 0.6, 11), cf(0, 1.6, 0), WATER, { tr = 1, name = "Soil" })
		B:emitter(mist, "smoke", { name = "SwampMist", color = { "#cfe9ff", "#b9a8ff" }, rate = 1.5, size = { 1.5, 3.0, 4.0 }, trans = { 0.82, 0.86, 1 }, speed = { 0.2, 0.5 }, life = { 3, 5 }, spread = 90, accel = { 0, 0.15, 0 } })
		local pud = B:block(soil, v(2.6, 0.1, 2.6), cf(PC.X, 1.62, PC.Z), WATER, { tr = 1, name = "Soil" })
		B:emitter(pud, "bubble", { name = "PuddleBubbles", color = { "#c8fff0", WISP }, rate = 1.2, size = { 0.12, 0.25, 0.3 }, speed = { 0.3, 0.7 } })
		B:light(main, { name = "WispLight", color = "#7ff4ff", brightness = 1.3, range = 16 })
		B:light(cores[3], { name = "VioletLight", color = "#b48cff", brightness = 0.8, range = 12 })
	end,
}
