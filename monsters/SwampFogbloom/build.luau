--!nocheck
-- Fogbloom Lily (Misty Swamp crop #8, Cosmic).
-- A stepped mound of dark swamp mud rimmed with mossy stones holds a murky
-- teal pond with floating lily pads and reeds. From a mossy islet in the
-- middle a tall jointed stem rises to one GIANT swamp lily: six recurved
-- lavender-to-pearl petals spotted with violet, a deep violet throat that
-- glows soft cyan and breathes out a slow plume of lilac mist, and long
-- stamens tipped with pearls. Arching side stems carry the fruits: calyx
-- cups heaped with big stepped pearl seeds (white, blush pink, sea-glass
-- cyan). Raised lily pads and lance leaves fill the middle. VFX: mist
-- breath from the throat, low fog rolling over the pond, pearl shimmer,
-- throat glow, rising mist motes, fireflies, pond bubbles, two soft lights.
-- Static prop: no motion.luau.
return {
	DisplayName = "Fogbloom Lily",
	Rarity = "Cosmic",
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
		local STM_DK, STM, STM_LT = "#1f4f45", "#2b6a58", "#3a836a"
		local LF_DK, LF, LF_LT = "#2f6e3c", "#3f8a48", "#5aa856"
		local VIO_DK, VIO, VIO_MD = "#3a2163", "#5b3590", "#7e57c2"
		local PET, PET_LT, PET_HI = "#a989ea", "#cdb8ff", "#efe8ff"
		local SPOT = "#4a2a80"
		local PEARL, PEARL_PK, PEARL_CY, PEARL_SH = "#f4f0ff", "#ffd2ea", "#c8f4ff", "#ddd4f4"
		local POD_DK, POD, POD_IN = "#1f4f45", "#2f7560", "#e3d8ff"
		local MIST, MIST2 = "#efeaff", "#dcf2ff"
		local GLOW, GLOW_LT = "#7ff0ff", "#d8fffb"
		local NEON = { mat = "Neon" }

		local seed = 8191
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
		local function dirOf(a)
			return v(math.sin(rad(a)), 0, -math.cos(rad(a)))
		end

		---------------------------------------------------------------- swamp mound + pond
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
		tier(0, 0.8, 7.0, MUD_DK, 16, { MUD_DK, MUD_DK2, MUD_DK, MOSS_DK }, 0.35)
		tier(0.8, 0.7, 5.6, MUD, 0, {}, 0)
		-- stone + moss rim around the pond
		for i = 0, 13 do
			local a = (i + rnd(-0.2, 0.2)) / 14 * 360
			local c = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0, -(5.2 + rnd(-0.1, 0.3)))
			local h = rnd(0.9, 1.4)
			local col = pick({ STONE, STONE_DK, STONE, MUD_LT, MOSS_DK })
			B:block(soil, v(rnd(1.4, 2.0), h, rnd(1.1, 1.5)), c * CFrame.new(0, 0.8 + h / 2, 0) * ang(0, rnd(-8, 8), 0), col, S)
			if i % 3 == 0 then
				B:block(soil, v(1.2, 0.2, 0.9), c * CFrame.new(0, 0.8 + h + 0.05, 0) * ang(0, rnd(-15, 15), 0), MOSS_LT, S)
			elseif i % 3 == 1 then
				B:block(soil, v(0.8, 0.35, 0.7), c * CFrame.new(rnd(-0.3, 0.3), 0.8 + h + 0.1, 0.1) * ang(0, 30, 0), STONE_LT, S)
			end
		end
		-- moss pads draped over the outer tier
		for _, m in { { 20, 2.4 }, { 100, 1.8 }, { 170, 2.2 }, { 240, 1.6 }, { 300, 2.0 } } do
			local c = CFrame.Angles(0, rad(m[1]), 0) * CFrame.new(0, 0.82, -6.5)
			B:block(soil, v(m[2], 0.22, 1.3), c, MOSS, S)
			B:block(soil, v(m[2] * 0.7, 0.5, 0.25), c * CFrame.new(0, -0.18, -0.7), MOSS_DK, S)
		end
		-- the pond
		local WY = 1.75
		round(soil, CFrame.new(0, WY - 0.12, 0), 4.7, 0.24, WATER, S)
		B:block(soil, v(3.4, 0.26, 2.4), cf(-0.8, WY - 0.11, 1.4, 0, 20, 0), WATER_DK, S)
		for _, r in { { -1.8, -2.8, 2.6, 12 }, { 2.6, 1.4, 2.0, -20 }, { -2.8, 0.6, 1.4, 70 }, { 1.2, 3.2, 1.8, 5 } } do
			B:block(soil, v(r[3], 0.27, 0.25), cf(r[1], WY - 0.1, r[2], 0, r[4], 0), WATER_LT, S)
		end
		-- floating lily pads
		local function lily(x, z, s, a, col)
			local c = cf(x, WY + 0.03, z, 0, a, 0)
			B:block(soil, v(1.9 * s, 0.13, 1.3 * s), c, col, S)
			B:block(soil, v(1.3 * s, 0.12, 1.9 * s), c, col, S)
			B:block(soil, v(0.5 * s, 0.15, 0.75 * s), c * CFrame.new(0, 0.01, -0.7 * s), WATER, S)
			B:block(soil, v(0.45 * s, 0.16, 0.45 * s), c * CFrame.new(0.1 * s, 0.02, 0.15 * s), PAD_LT, S)
			return c
		end
		lily(-2.6, -2.3, 1.15, 30, PAD)
		local fp = lily(2.7, -2.6, 0.95, -25, PAD_DK)
		lily(3.3, 1.5, 0.9, 80, PAD)
		lily(-3.2, 1.9, 0.8, -60, PAD_DK)
		-- tiny violet water flower on the front pad
		for i = 0, 1 do
			B:block(soil, v(0.75, 0.25, 0.3), fp * CFrame.new(-0.2, 0.18, 0.2) * ang(0, i * 90 + 20, 0), PET_LT, S)
		end
		B:block(soil, v(0.3, 0.3, 0.3), fp * CFrame.new(-0.2, 0.28, 0.2) * ang(0, 20, 0), PEARL, S)
		-- reeds + cattails poking out of the rim
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
		reed(-4.6, 1.5, 2.6, 3.8, 10, 8, true)
		reed(-4.2, 1.5, 3.3, 2.8, 2, 14, false)
		reed(-5.0, 1.5, 1.7, 3.0, 16, -4, true)
		reed(4.7, 1.5, 2.6, 3.4, -10, 8, true)
		reed(5.0, 1.5, 1.8, 2.4, -16, 0, false)
		reed(3.2, 0.8, -5.8, 2.6, -6, -12, true)

		---------------------------------------------------------------- the plant
		local crop = B:bone("Crop", "Root", v(0, WY, 0))
		-- mossy islet the lily grows from
		round(crop, CFrame.new(0, WY + 0.1, 0.2), 1.6, 0.5, MOSS_DK)
		round(crop, CFrame.new(0, WY + 0.35, 0.2) * ang(0, 30, 0), 1.1, 0.4, MOSS)

		-- long lance leaves fanning from the islet (broad face outward)
		local function lance(a, s, w, colA, colB)
			local dir = dirOf(a)
			local p0 = v(0, WY + 0.3, 0.2) + dir * 0.6
			local p1 = p0 + dir * 0.6 * s + v(0, 2.4 * s, 0)
			local p2 = p1 + dir * 1.1 * s + v(0, 1.6 * s, 0)
			local p3 = p2 + dir * 1.3 * s + v(0, 0.1 * s, 0)
			B:bar(crop, p0, p1, w, 0.4, colA, { up = dir })
			B:bar(crop, p1 - (p1 - p0).Unit * 0.25, p2, w * 0.85, 0.38, colB, { up = dir })
			B:bar(crop, p2 - (p2 - p1).Unit * 0.25, p3, w * 0.5, 0.36, colA, { up = dir })
		end
		for i = 0, 6 do
			lance(i * (360 / 7) + 15 + rnd(-8, 8), 1.0 + rnd(-0.1, 0.2), 1.4, (i % 2 == 0) and LF or LF_DK, (i % 2 == 0) and LF_LT or LF)
		end

		-- jointed stem through points
		local function stem(pts, w0, w1, colA, colB)
			for i = 1, #pts - 1 do
				local t = (i - 1) / math.max(1, #pts - 2)
				local w = w0 + (w1 - w0) * t
				local p, q = pts[i], pts[i + 1]
				B:bar(crop, p - (q - p).Unit * 0.12, q + (q - p).Unit * 0.12, w, w, (i % 2 == 0) and colB or colA)
				if i < #pts - 1 then
					B:block(crop, v(w + 0.25, 0.3, w + 0.25), CFrame.new(q) * ang(0, 45, 0), STM_DK)
				end
			end
		end

		-- raised lily pad on a stalk
		local function raisedPad(top, s, rx, rz, yaw, col)
			local Fr = CFrame.new(top) * CFrame.Angles(rad(rx), rad(yaw), rad(rz))
			B:block(crop, v(3.6 * s, 0.25, 2.2 * s), Fr, col)
			B:block(crop, v(2.2 * s, 0.24, 3.6 * s), Fr, col)
			B:block(crop, v(3.1 * s, 0.23, 3.1 * s), Fr, col)
			B:block(crop, v(0.9 * s, 0.28, 1.5 * s), Fr * CFrame.new(0, 0.02, -1.15 * s), PAD_DK) -- notch shade
			B:block(crop, v(0.7 * s, 0.32, 0.7 * s), Fr * ang(0, 45, 0), PAD_LT)
			for i = 0, 2 do
				B:block(crop, v(0.25 * s, 0.3, 1.4 * s), Fr * CFrame.Angles(0, rad(i * 120 + 60), 0) * CFrame.new(0, 0.02, -0.9 * s), PAD_LT)
			end
			for i = 0, 4 do
				local a = i * 72 + 36
				B:block(crop, v(1.5 * s, 0.25, 0.6 * s), Fr * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.2, -1.7 * s) * ang(30, 0, 0), PAD_DK)
			end
		end

		-- PEARL: stepped near-round pearl (cube + 45deg cube + highlight)
		local pearls = {}
		local function pearl(c, s, col)
			B:block(crop, v(s, s * 0.86, s), c, col)
			B:block(crop, v(s * 0.82, s * 1.0, s * 0.82), c * ang(0, 45, 0), col)
			B:block(crop, v(s * 1.04, s * 0.3, s * 1.04), c * CFrame.new(0, -s * 0.18, 0), PEARL_SH)
			local h = B:block(crop, v(s * 0.26, s * 0.26, s * 0.26), c * CFrame.new(-s * 0.22, s * 0.44, -s * 0.22), "#ffffff", { mat = "Neon", name = "PearlGlint" })
			table.insert(pearls, h)
		end
		local PCOLS = { PEARL, PEARL_PK, PEARL_CY }

		-- PEARL POD: a seed pod split open like a clam, cradling pearls.
		-- c: CFrame at the pod base, -Z = the side the pod opens toward
		local function pearlPod(c, k, open)
			B:block(crop, v(1.0 * k, 0.6 * k, 1.0 * k), c * CFrame.new(0, 0.2 * k, 0) * ang(0, 45, 0), POD_DK)
			B:block(crop, v(2.2 * k, 0.5 * k, 1.9 * k), c * CFrame.new(0, 0.6 * k, 0), POD_DK)
			B:block(crop, v(2.9 * k, 0.55 * k, 2.5 * k), c * CFrame.new(0, 1.05 * k, 0), POD)
			B:block(crop, v(3.0 * k, 0.2 * k, 0.3 * k), c * CFrame.new(0, 1.15 * k, -1.2 * k), VIO_MD)
			B:block(crop, v(2.5 * k, 0.2 * k, 2.1 * k), c * CFrame.new(0, 1.36 * k, 0), POD_IN)
			-- lid hinged at the back, lifted open
			local hinge = c * CFrame.new(0, 1.3 * k, 1.2 * k) * CFrame.Angles(rad(open), 0, 0)
			B:block(crop, v(2.9 * k, 0.5 * k, 2.5 * k), hinge * CFrame.new(0, 0.25 * k, -1.2 * k), POD)
			B:block(crop, v(2.1 * k, 0.45 * k, 1.7 * k), hinge * CFrame.new(0, 0.65 * k, -1.2 * k), POD_DK)
			B:block(crop, v(2.5 * k, 0.12 * k, 2.1 * k), hinge * CFrame.new(0, -0.02 * k, -1.2 * k), POD_IN)
			B:block(crop, v(0.3 * k, 0.2 * k, 2.6 * k), hinge * CFrame.new(0.7 * k, 0.88 * k, -1.2 * k), VIO_MD)
			B:block(crop, v(0.3 * k, 0.2 * k, 2.6 * k), hinge * CFrame.new(-0.7 * k, 0.88 * k, -1.2 * k), VIO_MD)
			-- pearls
			pearl(c * CFrame.new(0, 2.05 * k, 0.1 * k), 1.35 * k, PEARL)
			pearl(c * CFrame.new(0.95 * k, 1.75 * k, -0.45 * k) * ang(0, 20, 0), 0.8 * k, PEARL_PK)
			pearl(c * CFrame.new(-0.9 * k, 1.72 * k, -0.35 * k) * ang(0, -15, 0), 0.72 * k, PEARL_CY)
		end

		-- stylized mist puff: soft translucent stepped cloud
		local function puff(bone, c, sc, col, opts)
			local o = opts or {}
			o.tr = 0.5
			B:block(bone, v(2.4 * sc, 0.8 * sc, 1.6 * sc), c, col, o)
			B:block(bone, v(1.5 * sc, 0.75 * sc, 1.3 * sc), c * CFrame.new(-0.3 * sc, 0.5 * sc, 0.1 * sc), col, o)
			B:block(bone, v(1.3 * sc, 0.6 * sc, 1.9 * sc), c * CFrame.new(0.8 * sc, 0.15 * sc, 0.2 * sc), col, o)
		end

		---------------------------------------------------------------- main stem + giant lily
		local mainPts = {
			v(0, WY + 0.3, 0.2),
			v(0.5, WY + 3.6, 0.5),
			v(0.3, WY + 7.0, 0.3),
			v(-0.3, WY + 9.6, 0),
			v(0, WY + 11.5, -0.3),
		}
		stem(mainPts, 1.55, 1.15, STM, STM_LT)
		-- big lance leaves sprouting from the stem nodes
		local function stemLeaf(p, a, len, w, col, colB)
			local dir = dirOf(a)
			local p1 = p + dir * len * 0.45 + v(0, len * 0.45, 0)
			local p2 = p1 + dir * len * 0.45 + v(0, len * 0.05, 0)
			local p3 = p2 + dir * len * 0.25 - v(0, len * 0.2, 0)
			B:bar(crop, p, p1, w, 0.36, col, { up = v(0, 1, 0) })
			B:bar(crop, p1 - (p1 - p).Unit * 0.2, p2, w * 0.85, 0.34, colB, { up = v(0, 1, 0) })
			B:bar(crop, p2 - (p2 - p1).Unit * 0.2, p3, w * 0.5, 0.32, col, { up = v(0, 1, 0) })
			B:bar(crop, p + v(0, 0.2, 0), p1 + v(0, 0.2, 0), w * 0.18, 0.1, LF_LT, { up = v(0, 1, 0) })
		end
		stemLeaf(mainPts[2], 230, 4.2, 1.5, LF, LF_LT)
		stemLeaf(mainPts[3], 100, 3.8, 1.35, LF_DK, LF)
		stemLeaf(mainPts[4], 300, 3.0, 1.15, LF, LF_LT)

		local FB = mainPts[#mainPts]
		local Fr = CFrame.new(FB) * CFrame.Angles(rad(-12), rad(10), 0)
		-- receptacle
		B:block(crop, v(1.8, 0.9, 1.8), Fr * CFrame.new(0, 0.2, 0) * ang(0, 45, 0), STM_DK)
		B:block(crop, v(2.4, 0.8, 2.4), Fr * CFrame.new(0, 0.85, 0), LF_DK)
		-- green sepals under the petals
		for i = 0, 5 do
			local q = Fr * CFrame.Angles(0, rad(i * 60 + 30), 0)
			B:bar(crop, (q * CFrame.new(0, 0.6, -0.7)).Position, (q * CFrame.new(0, 1.3, -2.4)).Position, 1.2, 0.34, LF, { up = (q * CFrame.new(0, 0, -1)).Position - q.Position })
		end
		-- throat: deep violet tube with a glowing heart
		B:block(crop, v(2.4, 1.6, 2.4), Fr * CFrame.new(0, 1.7, 0), VIO_DK)
		B:block(crop, v(1.9, 0.3, 1.9), Fr * CFrame.new(0, 2.5, 0) * ang(0, 45, 0), "#24164a")
		local throat = B:block(crop, v(1.2, 0.8, 1.2), Fr * CFrame.new(0, 2.6, 0), GLOW, { mat = "Neon", name = "ThroatGlow" })
		-- six recurved petals (3 outer + 3 inner)
		local tips = {}
		local function petal(a, s, inner)
			local q = Fr * CFrame.Angles(0, rad(a), 0)
			local SR, SY = 1.35 * s, 1.22 * s
			local function P3(r, y)
				return (q * CFrame.new(0, y * SY, -r * SR)).Position
			end
			local out = (q * CFrame.new(0, 0, -1)).Position - q.Position
			local p0, p1, p2, p3, p4 = P3(0.7, 1.3), P3(1.45, 3.3), P3(2.75, 5.0), P3(4.05, 5.45), P3(4.85, 4.5)
			B:bar(crop, p0, p1, 1.9 * s, 0.5, VIO_MD, { up = out })
			B:bar(crop, p1 - (p1 - p0).Unit * 0.25, p2, 3.0 * s, 0.48, inner and PET_LT or PET, { up = out })
			B:bar(crop, p2 - (p2 - p1).Unit * 0.25, p3, 2.6 * s, 0.46, PET_LT, { up = out })
			B:bar(crop, p3 - (p3 - p2).Unit * 0.25, p4, 1.5 * s, 0.44, PET_HI, { up = out })
			-- paler inner layer + darker outer layer for a stepped, chunky petal
			B:bar(crop, p1:Lerp(p2, 0.1) - out * 0.22, p2:Lerp(p3, 0.4) - out * 0.22, 1.7 * s, 0.2, PET_HI, { up = out })
			B:bar(crop, p0:Lerp(p1, 0.4) + out * 0.24, p1:Lerp(p2, 0.6) + out * 0.24, 1.9 * s, 0.2, VIO, { up = out })
			-- violet spots on the inner face
			local f = CFrame.lookAt(p1:Lerp(p2, 0.35), p1:Lerp(p2, 0.35) + out)
			B:block(crop, v(0.45 * s, 0.45 * s, 0.3), f * CFrame.new(0.55 * s, 0.1, 0.36), SPOT)
			B:block(crop, v(0.4 * s, 0.4 * s, 0.3), f * CFrame.new(-0.6 * s, -0.3, 0.36), SPOT)
			-- dark midrib
			B:bar(crop, p0:Lerp(p1, 0.3) - out * 0.2, p2:Lerp(p3, 0.2) - out * 0.2, 0.3 * s, 0.22, VIO, { up = out })
			table.insert(tips, { p4, out })
		end
		for i = 0, 2 do
			petal(i * 120, 1.15, false)
			petal(i * 120 + 60, 1.0, true)
		end
		-- stamens with pearl anthers + a central glowing pistil
		for i = 0, 5 do
			local q = Fr * CFrame.Angles(0, rad(i * 60 + 30), 0)
			local a = (q * CFrame.new(0, 2.4, -0.3)).Position
			local b = (q * CFrame.new(0, 5.2, -1.3)).Position
			local c = (q * CFrame.new(0, 6.5, -2.3)).Position
			B:bar(crop, a, b, 0.24, 0.24, PET_HI)
			B:bar(crop, b, c, 0.22, 0.22, PET_HI)
			pearl(CFrame.new(c) * CFrame.Angles(0, rad(i * 60), 0), 0.7, PCOLS[i % 3 + 1])
		end
		B:bar(crop, (Fr * CFrame.new(0, 2.4, 0)).Position, (Fr * CFrame.new(0, 6.8, 0)).Position, 0.4, 0.4, GLOW_LT)
		local pistil = B:block(crop, v(0.7, 0.7, 0.7), Fr * CFrame.new(0, 7.0, 0) * ang(45, 0, 45), GLOW, { mat = "Neon", name = "PistilGlow" })
		-- pearl seeds dripping from the outer petal tips
		for i = 1, #tips, 2 do
			local tip, out = tips[i][1], tips[i][2]
			local t0 = tip + out * 0.15 - v(0, 0.2, 0)
			local t1 = t0 - v(0, 1.0, 0)
			B:bar(crop, t0, t1, 0.14, 0.14, PET_HI)
			pearl(CFrame.new(t1 - v(0, 0.35, 0)), 0.65, PCOLS[(i + 1) // 2 % 3 + 1])
		end

		---------------------------------------------------------------- side stems: pearl fruit + pads
		local function sideStem(base, head, bend, w)
			local mid = base:Lerp(head, 0.5) + bend
			stem({ base, base:Lerp(mid, 0.6) + v(0, 0.2, 0), mid, head }, w, w * 0.75, STM, STM_LT)
		end
		-- pearl seed heads
		local SH = {
			{ v(0.6, WY + 0.4, -0.2), v(4.4, WY + 8.0, -2.4), v(0.8, 0.8, 0), 0.7, ang(-10, 0, 0), 1.2 },
			{ v(-0.6, WY + 0.4, 0.2), v(-4.8, WY + 6.2, -0.8), v(-0.6, 1.2, -0.4), 0.64, ang(-10, 0, 0), 1.1 },
			{ v(0.4, WY + 0.4, 0.8), v(3.0, WY + 4.6, 3.6), v(0.2, 1.2, 0.6), 0.58, ang(-10, 0, 0), 1.0 },
		}
		local heads = {}
		for _, h in SH do
			sideStem(h[1], h[2], h[3], h[4])
			local out = v(h[2].X, 0, h[2].Z).Unit
			pearlPod(CFrame.lookAt(h[2], h[2] + out) * h[5], h[6], 62)
			table.insert(heads, h[2])
		end
		-- low fog banks hugging the pond + a wisp of breath curling off the bloom
		for _, f in { { -3.2, -1.0, 1.0, 20 }, { 2.6, -3.0, 0.9, -30 }, { 3.4, 2.2, 0.8, 60 }, { -1.8, 3.4, 0.85, -10 }, { 0.6, -4.3, 0.6, 5 } } do
			puff(soil, cf(f[1], WY + 0.35 * f[3] + 0.15, f[2], 0, f[4], 0), f[3], (f[4] > 0) and MIST or MIST2, { name = "Soil" })
		end
		-- raised pads
		sideStem(v(-0.4, WY + 0.4, 0.4), v(-3.0, WY + 4.6, 3.0), v(-0.2, 0.6, 0.2), 0.42)
		raisedPad(v(-3.0, WY + 4.7, 3.0), 1.15, 12, 10, 20, PAD)
		sideStem(v(0.5, WY + 0.4, 0.0), v(3.8, WY + 3.2, -0.6), v(0.2, 0.6, 0), 0.4)
		raisedPad(v(3.8, WY + 3.3, -0.6), 0.95, -6, -14, -30, PAD_DK)

		---------------------------------------------------------------- VFX
		B:emitter(throat, "smoke", { name = "FogBreath", color = { "#f4eeff", "#cdbcff", "#bfeaff" }, rate = 3, size = { 1.0, 2.6, 4.2 }, trans = { 0.55, 0.72, 1 }, speed = { 1.4, 2.4 }, life = { 3, 4.5 }, spread = 22, accel = { 0, -0.55, 0 }, rot = { -30, 30 } })
		B:emitter(throat, "glow", { name = "ThroatAura", color = { GLOW_LT, GLOW }, rate = 1.5, size = { 1.8, 2.8, 0.8 }, trans = { 0.8, 0.7, 1 }, light = 1 })
		local pondZone = B:block(soil, v(8.5, 0.4, 8.5), cf(0, WY + 0.3, 0), WATER, { tr = 1, name = "Soil" })
		B:emitter(pondZone, "smoke", { name = "PondFog", color = { "#e4f6ff", "#cfe9e4", "#d9ccff" }, rate = 2.2, size = { 2.0, 3.6, 4.6 }, trans = { 0.72, 0.8, 1 }, speed = { 0.2, 0.5 }, life = { 3.5, 6 }, spread = 90, accel = { 0, 0.12, 0 } })
		B:emitter(pondZone, "bubble", { name = "PondBubbles", color = { "#e8fff8", GLOW }, rate = 1.2, size = { 0.12, 0.25, 0.3 }, speed = { 0.3, 0.7 } })
		local pearlZone = B:block(crop, v(10, 7, 9), cf(0, WY + 7.5, 0), PEARL, { tr = 1, name = "PearlZone" })
		B:emitter(pearlZone, "sparkle", { name = "PearlShimmer", color = { "#ffffff", PEARL_PK, PEARL_CY }, rate = 5, size = { 0.12, 0.38, 0 }, speed = { 0.1, 0.4 }, life = { 1.2, 2.2 }, light = 1 })
		B:emitter(pistil, "sparkle", { name = "MistMotes", color = { "#ffffff", GLOW, PET_LT }, rate = 4, size = { 0.15, 0.4, 0 }, speed = { 0.6, 1.4 }, life = { 1.8, 3 }, spread = 40, accel = { 0, 0.6, 0 }, light = 1 })
		local ff = B:block(crop, v(13, 8, 13), cf(0, WY + 10, 0), GLOW, { tr = 1, name = "FireflyZone" })
		B:emitter(ff, "sparkle", { name = "Fireflies", color = { "#e6ff7a", "#9dff6a" }, rate = 3.5, size = { 0.12, 0.3, 0 }, speed = { 0.1, 0.4 }, life = { 2, 3.5 } })
		B:light(throat, { name = "FogLight", color = "#b9e8ff", brightness = 1.3, range = 18 })
		B:light(pearls[1], { name = "PearlLight", color = "#ffd6f0", brightness = 0.8, range = 12 })
	end,
}
