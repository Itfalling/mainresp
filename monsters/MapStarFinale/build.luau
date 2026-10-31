--!nocheck
-- Starlight Sanctum (Map landmark: THE END of the hallway, Starlight Ruins).
-- A giant ruined celestial star-gate temple that caps the hallway end. Faces
-- -Z (toward the runner). Footprint x -60..60, z -22..16, floor y = 0.
-- * STAIRS: four worn moonstone steps (z -22 .. -12, 1 stud rise each) with
--   gold nosing and a glowing cyan rune strip on every riser (StepRune1..4,
--   chase upward into the gate), corner plinths with broken column stumps
--   and crystal clusters, fallen rubble
-- * DAIS (y 4) carrying the STAR GATE: a stepped pedestal, a static moonstone
--   frame ring with gold rim, blue-violet keystones and eight gold chevron
--   stars with neon cores (Chevron1..8, light up one by one = "dialling"),
--   two counter-rotating rings (RingA blue-violet with cyan runes, RingB
--   moonstone with gold teeth and pink gems), a deep void disc with a
--   three-armed galaxy SWIRL that spins and a pulsing star CORE (CoreRay1..4
--   flash on the beat)
-- * two huge fluted COLUMNS (gold bands, cyan rune glyphs that chase upward):
--   the left one whole with a broken lintel, the right one snapped with its
--   chunks floating (FloatA)
-- * a ruined back wall with a stepped jagged pediment
-- * OUTER RUINS over the cliffs (|x| 32..60): curtain walls with gold-framed
--   star-chart panels, tall towers with diamond star windows, broken
--   battlements and crystals, end walls; four constellations (Con1..4) on
--   them light up in sequence
-- * floating CRESCENT MOON with a spinning gold star in its bite, four big
--   floating star crystals, six orbiting star shards with trails
-- Blocks only.
return {
	DisplayName = "Starlight Sanctum",
	Rarity = "Landmark",
	Element = "Starlight Ruins",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad, sin, cos, sqrt, floor, max, min = math.rad, math.sin, math.cos, math.sqrt, math.floor, math.max, math.min
		local R = "Root"

		-- palette -----------------------------------------------------------
		local ST_DK, ST, ST_MD = "#30275e", "#3a2f6e", "#463a88"
		local BL, BL_DK, BL_LT = "#4b56c9", "#3f48b0", "#6672e0"
		local VOID, VOID2, VOID3 = "#191338", "#221a4e", "#2e2470"
		local MS_DK, MS, MS_LT = "#aaa3d2", "#c9c4e6", "#e6e3f7"
		local GOLD, GOLD_DK, GOLD_LT = "#ffd34d", "#e8b53a", "#fff0a0"
		local CYAN, PINK, STARW = "#7fe8ff", "#ff8fd8", "#eaf8ff"
		local CY_DK, CY, CY_LT = "#2aa9cf", "#4fd8f2", "#a8f3ff"
		local VIO_DK, VIO, VIO_LT = "#7a58ea", "#9b7cff", "#c6b4ff"
		local PK_DK, PK, PK_LT = "#e05cb8", "#ff8fd8", "#ffc4ee"
		local NEON = { mat = "Neon" }
		local function N(name, tr)
			return { mat = "Neon", name = name, tr = tr }
		end

		local seed = 92301
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[floor(rnd(1, #t + 0.999))]
		end
		-- vertical span block: x/z centre, y0..y1
		local function col(bone, sx, sz, x, z, y0, y1, c, opts)
			return B:block(bone, v(sx, y1 - y0, sz), cf(x, (y0 + y1) / 2, z), c, opts)
		end
		-- frame in the XY plane: angle a (deg, 0 = up, clockwise toward +X),
		-- radius r; local X = tangent, local Y = radial (outward)
		local function pxy(cx, cy, z, a, r)
			return CFrame.new(cx, cy, z) * CFrame.Angles(0, 0, -rad(a)) * CFrame.new(0, r, 0)
		end
		local FWD = Vector3.new(0, 0, -1)

		-- stepped crystal (static), base point + tilt; returns nothing
		local function sprout(bone, x, y, z, h, w, tx, tz, cols)
			local base = CFrame.new(x, y, z) * CFrame.Angles(rad(tx), rad(rnd(0, 90)), rad(tz))
			B:block(bone, v(w, h * 0.5, w), base * CFrame.new(0, h * 0.25, 0), cols[1])
			B:block(bone, v(w * 0.7, h * 0.35, w * 0.7), base * CFrame.new(0, h * 0.62, 0), cols[2])
			B:block(bone, v(w * 0.38, h * 0.22, w * 0.38), base * CFrame.new(0, h * 0.86, 0), cols[3])
		end
		local CR_V = { VIO_DK, VIO, VIO_LT }
		local CR_C = { CY_DK, CY, CY_LT }
		local CR_P = { PK_DK, PK, PK_LT }
		local function cluster(bone, x, y, z, n, s)
			local sets = { CR_V, CR_C, CR_P, CR_V }
			for i = 1, n do
				local a = (i / n) * 360 + rnd(-20, 20)
				local d = (i == 1) and 0 or rnd(0.8, 1.6) * s
				local h = (i == 1) and 4.2 * s or rnd(2.2, 3.4) * s
				local tx = (i == 1) and rnd(-6, 6) or -cos(rad(a)) * rnd(18, 32)
				local tz = (i == 1) and rnd(-6, 6) or -sin(rad(a)) * rnd(18, 32)
				sprout(bone, x + sin(rad(a)) * d, y, z + cos(rad(a)) * d, h, (i == 1) and 1.5 * s or 1.05 * s, tx, tz, sets[(i - 1) % #sets + 1])
			end
		end

		------------------------------------------------------------------
		-- STAIRS (z -22 .. -12) + DAIS (y 4, z -12 .. 16)
		------------------------------------------------------------------
		local ZD = -12
		for k = 1, 4 do
			local zf = -22 + (k - 1) * 2.5
			local x = -31
			local i = 0
			while x < 30.99 do
				local w = rnd(9, 15)
				if 31 - (x + w) < 5 then
					w = 31 - x
				end
				local c = ((i + k) % 2 == 0) and MS or MS_LT
				if rnd(0, 1) < 0.18 then
					c = MS_DK
				end
				B:block(R, v(w - 0.1, k, ZD - zf), cf(x + w / 2, k / 2, (zf + ZD) / 2), c)
				if rnd(0, 1) < 0.7 then
					B:block(R, v(w - 1.2, 0.16, 0.4), cf(x + w / 2 + rnd(-0.3, 0.3), k + 0.08, zf + 0.32), (i % 2 == 0) and GOLD or GOLD_DK)
				end
				x += w
				i += 1
			end
			-- rune strip on the riser
			B:block(R, v(34 - k * 2, 0.3, 0.12), cf(0, k - 0.5, zf - 0.07), CYAN, N("StepRune" .. k))
		end
		-- dais body + floor details
		B:block(R, v(64, 4, 28), cf(0, 2, 2), ST_MD)
		B:block(R, v(64.2, 0.3, 0.5), cf(0, 3.85, -12.1), GOLD_DK)
		for _, t in { { -16, -9, 6, 5, 4 }, { 16.5, -8.5, 5.5, 5, -5 }, { -13, 1, 5, 6, -8 }, { 14, 2, 5.5, 5.5, 7 }, { -7.5, 4, 4, 4, 12 }, { 8, 5, 4.5, 4, -10 } } do
			B:block(R, v(t[3], 0.3, t[4]), cf(t[1], 4.15, t[2], 0, t[5], 0), pick({ BL_DK, ST, MS_DK }))
		end
		-- gold star inlay in front of the pedestal
		for kk = 0, 3 do
			local len = (kk % 2 == 0) and 7 or 4.6
			B:block(R, v(0.5, 0.12, len), cf(0, 4.06, -14.5 + 3.2, 0, kk * 45, 0), GOLD)
		end

		-- corner plinths with broken stumps + crystals
		for _, s in { -1, 1 } do
			local px = s * 28
			col(R, 6, 6, px, -18.5, 0, 5.5, ST)
			col(R, 6.4, 6.4, px, -18.5, 5.5, 6.1, GOLD_DK)
			col(R, 5.6, 5.6, px, -18.5, 6.1, 7.0, MS)
			local sh = (s < 0) and 5.5 or 3.2
			col(R, 4, 1.8, px, -18.5, 7.0, 7.0 + sh, MS_LT)
			col(R, 1.8, 4, px, -18.5, 7.0, 7.0 + sh - 0.04, MS_LT)
			B:block(R, v(2.9, sh - 0.08, 2.9), cf(px, 7.0 + sh / 2, -18.5, 0, 45, 0), MS)
			B:block(R, v(3.0, 1.3, 2.0), cf(px - s * 0.6, 7.0 + sh + 0.4, -18.3, 8, 20, s * 14), MS_LT)
			B:block(R, v(4.2, 0.4, 1.7), cf(px, 7.0 + sh * 0.55, -18.5 - 2.0), GOLD)
			cluster(R, px - s * 4.6, 1.0, -19.6, 4, 1.0)
			cluster(R, px - s * 3.5, 4.0, -9.5, 3, 0.9)
			-- fallen drum chunk on the steps
			B:block(R, v(3.2, 2.4, 2.4), cf(px - s * 6.5, 2.2, -19.2, 10, s * 25, 80), MS)
			B:block(R, v(1.6, 1.0, 1.4), cf(px - s * 9.0, 1.5, -20.6, 15, 30, 10), MS_DK)
		end
		-- rubble bits
		for _, r in { { -12, -19.6, 1 }, { 9, -17.2, 2 }, { -4, -14.7, 3 }, { 19, -20.4, 1 }, { -20, -14.8, 3 } } do
			B:block(R, v(rnd(1.0, 1.8), rnd(0.6, 1.0), rnd(0.9, 1.5)), cf(r[1], r[3] + 0.35, r[2], rnd(-10, 10), rnd(0, 90), rnd(-10, 10)), pick({ MS, MS_DK, ST_MD }))
		end

		------------------------------------------------------------------
		-- STAR GATE
		------------------------------------------------------------------
		local PY, PZ = 28.5, -5
		-- pedestal
		B:block(R, v(22, 1.4, 11), cf(0, 4.7, -5), ST)
		B:block(R, v(18, 1.1, 9), cf(0, 5.95, -5), MS)
		B:block(R, v(18.4, 0.3, 9.4), cf(0, 6.55, -5), GOLD)
		-- cradle claws hugging the frame bottom
		for _, s in { -1, 1 } do
			local a = 180 - s * 26
			B:block(R, v(4.2, 4.2, 6), pxy(0, PY, PZ, a, 23.8), ST)
			B:block(R, v(4.6, 0.5, 6.4), pxy(0, PY, PZ, a, 26.0), GOLD)
			B:block(R, v(3.2, 2.8, 5), pxy(0, PY, PZ, 180 - s * 40, 24.6), ST_DK)
			B:block(R, v(3.6, 0.5, 5.4), pxy(0, PY, PZ, 180 - s * 40, 26.2), GOLD_DK)
		end

		-- static frame ring: r 19.8 .. 23, z -7 .. -3
		local NF = 24
		for i = 0, NF - 1 do
			local a = i * 360 / NF
			local odd = i % 2
			B:block(R, v(2 * math.pi * 23 / NF + 0.12, 3.2, 4 + odd * 0.12), pxy(0, PY, PZ, a, 21.4), odd == 0 and MS or MS_LT)
			B:block(R, v(2 * math.pi * 20.1 / NF + 0.1, 0.6, 4.3 + odd * 0.1), pxy(0, PY, PZ, a, 19.75), odd == 0 and GOLD or GOLD_DK)
		end
		-- keystones + chevron stars (8, offset 22.5 so none hides in the pedestal)
		for i = 1, 8 do
			local a = 22.5 + (i - 1) * 45
			B:block(R, v(4.6, 2.4, 4.8), pxy(0, PY, PZ, a, 23.8), BL)
			B:block(R, v(5.0, 0.5, 5.0), pxy(0, PY, PZ, a, 25.1), GOLD)
			B:block(R, v(2.4, 1.0, 5.2), pxy(0, PY, PZ, a, 25.7), BL_DK)
			local c0 = pxy(0, PY, PZ - 2.1, a, 21.4)
			B:block(R, v(0.8, 4.6, 0.4), c0 * CFrame.new(0, 0, -0.1), GOLD)
			B:block(R, v(3.2, 0.8, 0.4), c0 * CFrame.new(0, 0, -0.12), GOLD_LT)
			B:block(R, v(1.4, 1.4, 0.4), c0 * CFrame.new(0, 0, -0.3) * CFrame.Angles(0, 0, rad(45)), CYAN, N("Chevron" .. i, 0.7))
		end

		-- void disc behind the rings (pixel circle rows), z -2.3 .. -1.3
		for k = 0, 19 do
			local y0, y1 = -20 + k * 2, -18 + k * 2
			local ye = max(math.abs(y0), math.abs(y1))
			local hw = sqrt(math.max(0, 20.6 ^ 2 - ye ^ 2))
			local dc = math.abs((y0 + y1) / 2)
			local c = dc < 5 and VOID3 or (dc < 12 and VOID2 or VOID)
			B:block(R, v(2 * hw, 2, 1 + (k % 2) * 0.1), cf(0, PY + (y0 + y1) / 2, -1.8), c)
		end
		-- starfield specks on the void
		for i = 1, 16 do
			local a = i * 137.5
			local r = 3.5 + (i % 8) * 1.1 + rnd(-0.4, 0.4)
			local sz = (i % 3 == 0) and 0.5 or 0.35
			B:block(R, v(sz, sz, 0.15), pxy(0, PY, -2.4, a, r) * CFrame.Angles(0, 0, rad(45)), (i % 4 == 0) and PK_LT or STARW, NEON)
		end
		-- inner glow halo plates on the void (static, subtle depth rings)
		for i = 0, 11 do
			local a = i * 30 + 15
			B:block(R, v(2.2, 0.5, 0.3), pxy(0, PY, -2.45, a, 12.2), (i % 2 == 0) and VIO_DK or BL_DK)
		end

		-- RingA (blue-violet, cyan runes): r 15.8 .. 19.0, z centre -6
		local ringA = B:bone("RingA", R, CFrame.new(0, PY, -6))
		local NA = 20
		for i = 0, NA - 1 do
			local a = i * 360 / NA
			local odd = i % 2
			B:block(ringA, v(2 * math.pi * 19 / NA + 0.1, 3.2, 2.4 + odd * 0.12), pxy(0, PY, -6, a, 17.4), odd == 0 and BL or BL_DK)
			B:block(ringA, v(0.7, 3.5, 2.75), pxy(0, PY, -6, a + 9, 17.4), MS_LT)
			if odd == 0 then
				local g = pxy(0, PY, -7.35, a, 17.4)
				B:block(ringA, v(0.5, 2.0, 0.2), g * CFrame.new(rnd(-0.9, -0.3), 0, 0), CYAN, NEON)
				B:block(ringA, v(1.6, 0.45, 0.22), g * CFrame.new(rnd(0.0, 0.5), rnd(-0.6, 0.6), 0), GOLD_LT)
			else
				local g = pxy(0, PY, -7.4, a, 17.4)
				B:block(ringA, v(0.9, 0.9, 0.2), g * CFrame.Angles(0, 0, rad(45)), GOLD)
			end
		end

		-- RingB (moonstone, gold teeth, pink gems): r 12.6 .. 15.4, z centre -6.6
		local ringB = B:bone("RingB", R, CFrame.new(0, PY, -6.6))
		local NB = 16
		for i = 0, NB - 1 do
			local a = i * 360 / NB
			local odd = i % 2
			B:block(ringB, v(2 * math.pi * 15.4 / NB + 0.1, 2.8, 2 + odd * 0.1), pxy(0, PY, -6.6, a, 14.0), odd == 0 and MS_LT or MS)
			if odd == 0 then
				B:block(ringB, v(1.3, 1.8, 2.3), pxy(0, PY, -6.6, a, 12.2), GOLD)
				B:block(ringB, v(0.7, 0.8, 2.4), pxy(0, PY, -6.6, a, 11.2), GOLD_LT)
			else
				B:block(ringB, v(0.9, 0.9, 0.2), pxy(0, PY, -7.72, a, 14.0) * CFrame.Angles(0, 0, rad(45)), PINK, NEON)
			end
		end

		-- SWIRL: three galaxy arms (chains of aimed bars), z -2.6 (centre) .. -4.2 (rim)
		local swirl = B:bone("Swirl", R, CFrame.new(0, PY, -3))
		local ARM_C = { CY_LT, CY_LT, CY, CY, VIO_LT, VIO, VIO, PK, PK_LT }
		local ARM_D = { CY, CY, CY_DK, CY_DK, VIO, VIO_DK, VIO_DK, PK_DK, PK }
		local function armPt(k, u, dr, da)
			local r = 1.6 + 10.6 * u + (dr or 0)
			local a = k * 120 + 290 * u + (da or 0)
			return Vector3.new(sin(rad(a)) * r, PY + cos(rad(a)) * r, -2.7 - 1.5 * u)
		end
		for k = 0, 2 do
			local nseg = 9
			for j = 0, nseg - 1 do
				local u0, u1 = j / nseg, (j + 1) / nseg
				local a, b = armPt(k, u0), armPt(k, u1)
				B:bar(swirl, a, b, 1.0 + 0.9 * u0, 0.7, ARM_C[j + 1], { up = FWD })
				if j >= 1 then
					local a2, b2 = armPt(k, u0, -1.2, -7), armPt(k, u1, -1.2, -7)
					B:bar(swirl, a2 + Vector3.new(0, 0, 0.12), b2 + Vector3.new(0, 0, 0.12), 0.7 + 0.5 * u0, 0.6, ARM_D[j + 1], { up = FWD })
				end
				if j == 2 or j == 5 or j == 8 then
					B:block(swirl, v(0.6, 0.6, 0.2), CFrame.new(b + Vector3.new(0, 0, -0.45)) * CFrame.Angles(0, 0, rad(45)), STARW, NEON)
				end
			end
		end

		-- CORE: pulsing star at the swirl centre
		local core = B:bone("Core", R, CFrame.new(0, PY, -3.6))
		B:block(core, v(4.4, 4.4, 0.8), cf(0, PY, -3.0, 0, 0, 45), VIO_LT)
		B:block(core, v(3.2, 3.2, 0.8), cf(0, PY, -3.35), CY)
		B:block(core, v(2.0, 2.0, 0.8), cf(0, PY, -3.7, 0, 0, 45), STARW, N("CoreGem"))
		for i = 1, 4 do
			local a = (i - 1) * 90
			B:block(core, v(0.7, 4.4, 0.4), pxy(0, PY, -3.75, a, 3.8), STARW, N("CoreRay" .. i, 1))
			B:block(core, v(0.8, 2.0, 0.6), pxy(0, PY, -3.3, a + 45, 3.0), GOLD)
		end

		-- six star shards orbiting the gate (in front of it)
		local orbit = B:bone("Orbit", R, CFrame.new(0, PY, -11))
		local TRC = { { STARW, CYAN, CY }, { STARW, PK_LT, PINK }, { STARW, GOLD_LT, GOLD } }
		for i = 1, 6 do
			local a = 30 + (i - 1) * 60
			local S = pxy(0, PY, -11, a, 21.8)
			local sb = B:bone("Shard" .. i, "Orbit", S)
			local gc = (i % 2 == 0) and GOLD or MS_LT
			B:block(sb, v(3.4, 0.7, 0.7), S, gc)
			B:block(sb, v(0.7, 3.4, 0.7), S, gc)
			B:block(sb, v(0.7, 0.7, 2.4), S, GOLD_DK)
			B:block(sb, v(1.3, 1.3, 1.3), S * CFrame.Angles(rad(45), rad(45), 0), (i % 3 == 1) and CYAN or ((i % 3 == 2) and PINK or GOLD_LT), NEON)
			local tc = TRC[(i - 1) % 3 + 1]
			B:trail(sb, (S * CFrame.new(0, 1.3, 0)).Position, (S * CFrame.new(0, -1.3, 0)).Position, { name = "ShardTrail" .. i, color = tc, life = 0.55, width = { 1, 0.05 }, trans = { 0.15, 1 } })
		end

		------------------------------------------------------------------
		-- COLUMNS (x = +-26.5, z = -5)
		------------------------------------------------------------------
		local function column(side, xc, zc, shaftTop, whole)
			col(R, 8, 8, xc, zc, 4, 5.4, ST_DK)
			col(R, 7, 7, xc, zc, 5.4, 6.6, MS)
			col(R, 7.4, 7.4, xc, zc, 6.6, 7.1, GOLD)
			col(R, 6.2, 6.2, xc, zc, 7.1, 7.9, MS_LT)
			local y = 7.9
			local k = 0
			while y < shaftTop - 0.01 do
				local h = min(5, shaftTop - y)
				k += 1
				local c1 = (k % 2 == 1) and MS or MS_LT
				local dx = rnd(-0.12, 0.12)
				col(R, 5.2, 2.2, xc + dx, zc, y, y + h, c1)
				col(R, 2.2, 5.2, xc + dx, zc, y, y + h - 0.03, c1)
				B:block(R, v(3.8, h - 0.06, 3.8), cf(xc + dx, y + h / 2, zc, 0, 45, 0), (k % 2 == 1) and MS_DK or MS)
				if h > 3 then
					B:block(R, v(0.45, 2.6, 0.12), cf(xc + dx, y + h / 2, zc - 2.67), CYAN, N("ColRune" .. side .. k, 0.6))
					B:block(R, v(1.1, 0.3, 0.12), cf(xc + dx, y + h / 2 + 1.0, zc - 2.67), GOLD_LT)
				end
				if k == 2 or k == 5 then
					col(R, 5.5, 2.5, xc + dx, zc, y + h - 0.35, y + h + 0.35, GOLD)
					col(R, 2.5, 5.5, xc + dx, zc, y + h - 0.35, y + h + 0.33, GOLD)
					B:block(R, v(4.1, 0.66, 4.1), cf(xc + dx, y + h, zc, 0, 45, 0), GOLD_DK)
				end
				y += h
			end
			if whole then
				col(R, 6, 6, xc, zc, y, y + 1, MS_LT)
				col(R, 6.6, 6.6, xc, zc, y + 1, y + 1.4, GOLD)
				col(R, 7.6, 7.6, xc, zc, y + 1.4, y + 2.8, MS)
				col(R, 8.4, 8.4, xc, zc, y + 2.8, y + 3.8, BL)
				for _, q in { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } } do
					B:block(R, v(1.2, 1.2, 1.2), cf(xc + q[1] * 3.4, y + 1.8, zc + q[2] * 3.4, 0, 45, 0), GOLD_DK)
				end
				return y + 3.8
			else
				-- jagged break
				B:block(R, v(4.6, 1.4, 3.2), cf(xc - 0.4, y + 0.5, zc + 0.3, 6, 15, -9), MS)
				B:block(R, v(2.6, 2.2, 2.4), cf(xc + 1.2, y + 1.2, zc - 0.6, -8, 30, 12), MS_LT)
				B:block(R, v(1.6, 1.2, 1.6), cf(xc - 1.6, y + 1.3, zc - 1.0, 12, 10, -15), MS_DK)
				sprout(R, xc + 0.8, y + 0.6, zc + 1.4, 3.2, 1.0, -10, 20, CR_C)
				return y
			end
		end
		local topL = column("L", -26.5, PZ, 44, true)
		local topR = column("R", 26.5, PZ, 36, false)
		-- broken lintel on the left column
		B:block(R, v(13, 3, 7), cf(-26, topL + 1.5, PZ), MS)
		B:block(R, v(13.6, 0.9, 7.6), cf(-26.1, topL + 3.45, PZ), BL)
		B:block(R, v(12.4, 0.35, 0.2), cf(-26.2, topL + 1.0, PZ - 3.58), GOLD)
		B:block(R, v(3.6, 2.4, 6.2), cf(-18.6, topL + 1.1, PZ + 0.2, 4, 8, -12), MS_LT)
		B:block(R, v(2.0, 1.4, 4.6), cf(-16.8, topL + 0.5, PZ - 0.1, -6, 14, -24), MS_DK)
		-- gold star medallion on the lintel
		B:block(R, v(1.6, 1.6, 0.3), cf(-27.5, topL + 1.7, PZ - 3.6, 0, 0, 45), GOLD)
		B:block(R, v(0.6, 2.6, 0.25), cf(-27.5, topL + 1.7, PZ - 3.7), GOLD_LT)
		B:block(R, v(2.6, 0.6, 0.25), cf(-27.5, topL + 1.7, PZ - 3.72), GOLD_LT)
		-- floating chunks above the snapped right column
		local fa = B:bone("FloatA", R, CFrame.new(26.5, topR + 4.5, PZ))
		B:block(fa, v(5.0, 2.2, 4.4), cf(26.0, topR + 4.0, PZ, 8, 20, -10), MS_LT)
		B:block(fa, v(4.0, 0.5, 2.0), cf(26.0, topR + 4.0, PZ - 1.9, 8, 20, -10), GOLD)
		B:block(fa, v(2.4, 1.8, 2.2), cf(28.4, topR + 6.4, PZ + 0.5, -14, 40, 18), MS)

		------------------------------------------------------------------
		-- BACK WALL (z 8 .. 14) with stepped jagged pediment
		------------------------------------------------------------------
		col(R, 68, 6, 0, 11, 4, 34, ST)
		for i = 0, 16 do
			local xc = -32 + i * 4
			local ax = math.abs(xc)
			local h = (ax < 12) and 57 or (ax < 20 and 52 or (ax < 28 and 44 or 39))
			h += (ax > 12 and ax < 20) and rnd(0, 1.2) or rnd(-2.2, 1.2)
			if i == 3 or i == 12 then
				h -= 5
			end
			col(R, 4, 6 - (i % 2) * 0.1, xc, 11, 33.9, h, (i % 2 == 0) and ST or ST_DK)
			if rnd(0, 1) < 0.7 then
				B:block(R, v(4.2, 0.8, 6.4), cf(xc + rnd(-0.2, 0.2), h + 0.3, 11, 0, 0, rnd(-4, 4)), (i % 3 == 0) and MS or MS_DK)
			end
		end
		col(R, 68.4, 6.4, 0, 11, 8.4, 9.8, MS)
		col(R, 68.6, 6.5, 0, 11, 9.8, 10.15, GOLD_DK)
		col(R, 68.4, 6.4, 0, 11, 29.4, 30.6, MS)
		-- ashlar bricks on the front face
		for _ = 1, 26 do
			local x = rnd(-33, 33)
			local ax = math.abs(x)
			local top = (ax < 12) and 55 or (ax < 20 and 50 or (ax < 28 and 42 or 37))
			local y = rnd(11, top - 1)
			B:block(R, v(rnd(2.5, 4.5), rnd(1.2, 2), 0.5), cf(x, y, 7.85), pick({ ST_MD, ST_DK, BL_DK, ST_MD }))
		end

		-- gold star medallions on the pediment, flanking the moon
		for _, s in { -1, 1 } do
			local mx, my = s * 16, 48.6
			B:block(R, v(3.0, 3.0, 0.4), cf(mx, my, 7.7, 0, 0, 45), GOLD_DK)
			B:block(R, v(0.9, 5.2, 0.3), cf(mx, my, 7.5), GOLD)
			B:block(R, v(5.2, 0.9, 0.3), cf(mx, my, 7.48), GOLD)
			B:block(R, v(1.6, 1.6, 0.3), cf(mx, my, 7.35, 0, 0, 45), GOLD_LT)
			B:block(R, v(0.8, 0.8, 0.3), cf(mx, my, 7.2, 0, 0, 45), PINK, N("Medal" .. (s < 0 and "L" or "R"), 0.3))
		end

		------------------------------------------------------------------
		-- OUTER RUINS over the cliffs (|x| 32 .. 60)
		------------------------------------------------------------------
		local CON = {
			{ { -3.8, 1.6 }, { -2.2, 2.4 }, { -0.5, 1.5 }, { 0.9, 0.2 }, { 2.7, 0.8 }, { 3.7, -2.0 } },
			{ { -3.9, -2.2 }, { -2.4, 0.4 }, { -0.4, -0.8 }, { 1.0, 1.9 }, { 2.8, 0.5 }, { 3.9, 2.4 } },
			{ { -4.2, 0.3 }, { -2.4, 2.0 }, { -0.4, 0.9 }, { -1.0, -1.8 }, { 1.8, -2.2 }, { 4.0, -0.2 } },
			{ { -4.0, 2.0 }, { -2.2, -1.2 }, { 0.0, 1.0 }, { 2.0, -1.6 }, { 4.0, 1.6 }, { 2.6, 2.6 } },
		}
		local function constellation(j, cx, cy, zf, sx, sy, lineCol)
			local pts = {}
			for k, q in CON[j] do
				local p = Vector3.new(cx + q[1] * sx, cy + q[2] * sy, zf)
				pts[k] = p
				B:block(R, v(0.9, 0.9, 0.25), CFrame.new(p + Vector3.new(0, 0, -0.2)) * CFrame.Angles(0, 0, rad(45)), (k % 2 == 0) and CYAN or STARW, N("Con" .. j .. "S" .. k, 0.5))
				if k == 1 or k == 4 then
					B:block(R, v(2.2, 0.22, 0.15), CFrame.new(p + Vector3.new(0, 0, -0.1)), GOLD_LT)
					B:block(R, v(0.22, 2.2, 0.15), CFrame.new(p + Vector3.new(0, 0, -0.12)), GOLD_LT)
				end
			end
			for k = 1, #pts - 1 do
				local a, b = pts[k], pts[k + 1]
				local d = (b - a).Unit
				B:bar(R, a + d * 0.45 + Vector3.new(0, 0, -0.08), b - d * 0.45 + Vector3.new(0, 0, -0.08), 0.28, 0.12, lineCol, N("Con" .. j .. "L" .. k, 0.75))
			end
		end

		local function outer(s, Hw, Ht, H2, conWall, conTower, flip)
			-- curtain wall x 32..44, z -2..8
			local wx = s * 38
			col(R, 12, 10, wx, 3, 0, Hw - 0.8, ST_DK)
			col(R, 12.4, 10.4, wx, 3, Hw - 0.8, Hw, MS)
			for m = -1, 1 do
				local mx = wx + s * m * 4.2
				if m == flip then
					B:block(R, v(2.6, 1.6, 2.2), cf(mx + s * 0.4, Hw + 0.6, -0.8, 6, 10, s * 18), ST)
				else
					col(R, 2.6, 2.2, mx, -0.8, Hw, Hw + 2.6, ST)
					col(R, 2.9, 2.5, mx, -0.8, Hw + 2.6, Hw + 3.0, MS_DK)
				end
			end
			col(R, 2.6, 2.2, wx - s * 4.2, 6.8, Hw, Hw + 2.2, ST)
			col(R, 12.3, 10.3, wx, 3, 18, 19, MS)
			col(R, 12.4, 10.4, wx, 3, 17.6, 18.0, GOLD_DK)
			-- star chart panel
			B:block(R, v(9, 7.4, 0.2), cf(wx, 24.3, -2.1), VOID2)
			B:block(R, v(9.6, 0.5, 0.4), cf(wx, 28.2, -2.15), GOLD)
			B:block(R, v(9.6, 0.5, 0.4), cf(wx, 20.4, -2.15), GOLD)
			B:block(R, v(0.5, 7.4, 0.4), cf(wx - 4.55, 24.3, -2.15), GOLD_DK)
			B:block(R, v(0.5, 7.4, 0.4), cf(wx + 4.55, 24.3, -2.15), GOLD_DK)
			constellation(conWall, wx, 24.3, -2.2, 0.95, 1.2, PINK)
			-- inner face bricks (visible from the lane)
			for _ = 1, 3 do
				B:block(R, v(0.5, rnd(1.2, 1.8), rnd(2.5, 4)), cf(s * 31.9, rnd(15, Hw - 3), rnd(-1, 7)), pick({ ST, ST_MD }))
			end
			B:block(R, v(rnd(2.5, 3.5), 1.4, 0.5), cf(wx + rnd(-4, 4), 15.6, -2.1), ST)

			-- tower x 44..56, z -6..8
			local tx = s * 50
			col(R, 12, 14, tx, 1, 0, Ht - 7.4, ST)
			col(R, 13.4, 15.4, tx, 1, 26, 27.6, MS)
			col(R, 12.8, 14.8, tx, 1, 27.6, 28.6, BL)
			col(R, 12.6, 14.6, tx, 1, 36.6, 37.8, MS)
			col(R, 12.7, 14.7, tx, 1, 36.2, 36.6, GOLD)
			col(R, 13.4, 15.4, tx, 1, Ht - 7.4, Ht - 6, BL)
			col(R, 14, 16, tx, 1, Ht - 6, Ht - 5.2, MS)
			col(R, 1.5, 1.5, s * 44.4, -6.1, 28.6, Ht - 7.4, MS_LT)
			col(R, 1.5, 1.5, s * 55.6, -6.1, 28.6, Ht - 7.4, MS_LT)
			-- battlement
			local mz = { { -4.6, -6.2 }, { 0, -6.2 }, { 4.6, -6.2 }, { -6.2, 0.5 }, { 6.2, 0.5 }, { -6.2, 6.5 }, { 6.2, 6.5 }, { 0, 8.2 } }
			for n, q in mz do
				local mx, mzz = tx + s * q[1], q[2]
				local w = (math.abs(q[1]) > 6) and 1.6 or 2.8
				local d = (math.abs(q[1]) > 6) and 2.8 or 1.6
				if n == 2 + flip then
					B:block(R, v(w, 1.6, d), cf(mx, Ht - 4.3, mzz, 8, 0, s * 12), ST_MD)
				else
					col(R, w, d, mx, mzz, Ht - 5.2, Ht - 1.6 + rnd(-0.6, 0.4), (n % 2 == 0) and ST or ST_MD)
				end
			end
			cluster(R, tx + s * 1.5, Ht - 5.2, 2, 4, 1.3)
			-- diamond star window
			local wy = (37.8 + Ht - 7.4) / 2
			B:block(R, v(4.4, 4.4, 0.2), cf(tx, wy, -6.1, 0, 0, 45), VOID)
			local dv = { Vector3.new(tx, wy + 3.4, -6.3), Vector3.new(tx + 3.4, wy, -6.3), Vector3.new(tx, wy - 3.4, -6.3), Vector3.new(tx - 3.4, wy, -6.3) }
			for n = 1, 4 do
				B:bar(R, dv[n], dv[n % 4 + 1], 0.9, 0.6, MS_LT, { up = FWD })
			end
			B:block(R, v(1.2, 1.2, 0.3), cf(tx, wy, -6.35, 0, 0, 45), CYAN, N("TowerStar" .. (s < 0 and "L" or "R"), 0.3))
			B:block(R, v(0.3, 3.2, 0.2), cf(tx, wy, -6.28), GOLD_LT)
			B:block(R, v(3.2, 0.3, 0.2), cf(tx, wy, -6.3), GOLD_LT)
			constellation(conTower, tx, 32.4, -6.05, 1.15, 1.15, CYAN)
			-- ashlar on tower front + inner side
			for _ = 1, 5 do
				local bx = tx + rnd(-4.5, 4.5)
				local by = rnd(38.6, Ht - 8.5)
				if math.abs(by - wy) > 3.2 or math.abs(bx - tx) > 3.8 then
					B:block(R, v(rnd(2, 3.4), rnd(1.1, 1.6), 0.5), cf(bx, by, -6.15), pick({ ST_MD, ST_DK, BL_DK }))
				end
			end
			for _ = 1, 3 do
				B:block(R, v(0.5, rnd(1.2, 1.8), rnd(2.5, 4)), cf(s * 43.85, rnd(Hw + 2, Ht - 9), rnd(-4, 6)), pick({ ST_MD, ST_DK }))
			end

			-- end wall x 56..60
			local ex = s * 58
			col(R, 4, 12, ex, 4, 0, H2 - 3, ST_DK)
			col(R, 2.2, 11.6, s * 57.1, 4, H2 - 3, H2, ST_DK)
			B:block(R, v(2.0, 1.6, 10), cf(s * 59, H2 - 2.6, 4.5, 0, 0, s * 8), ST)
			col(R, 4.3, 12.3, ex, 4, 32, 33, MS)
			B:block(R, v(2.2, 0.7, 11.8), cf(s * 57.1, H2 + 0.3, 4), MS_DK)
		end
		outer(-1, 33, 58, 43, 1, 3, 1)
		outer(1, 30, 54, 40, 2, 4, -1)

		-- floating ruin blocks above the towers
		local fb = B:bone("FloatB", R, CFrame.new(50, 54 + 3.5, 6))
		B:block(fb, v(2.6, 2.0, 2.2), cf(52.5, 57.5, 5.5, 12, 30, 8), ST_MD)
		B:block(fb, v(1.6, 1.2, 1.4), cf(48.0, 59.0, 7.0, -10, 15, 20), MS)
		local fc = B:bone("FloatC", R, CFrame.new(-50, 58 + 3.5, 6))
		B:block(fc, v(2.8, 1.8, 2.4), cf(-47.5, 61.5, 6.5, -8, 25, -12), ST)
		B:block(fc, v(1.4, 1.4, 1.4), cf(-52.5, 63.0, 5.0, 20, 40, 10), MS_LT)

		------------------------------------------------------------------
		-- CRESCENT MOON + gold star
		------------------------------------------------------------------
		local MX, MY, MZ = 0, 64.6, -4
		local moon = B:bone("Moon", R, CFrame.new(MX, MY, MZ))
		local function crescentRows(Ro, cxI, cyI, ri, z, depth, colA, colB, rowH)
			local nrows = math.floor(2 * Ro / rowH)
			local y0 = -nrows * rowH / 2
			for r = 0, nrows - 1 do
				local yc = y0 + (r + 0.5) * rowH
				local xo = sqrt(math.max(0, Ro * Ro - yc * yc))
				if xo > 0.3 then
					local segs = {}
					local dy = yc - cyI
					if math.abs(dy) < ri then
						local wI = sqrt(ri * ri - dy * dy)
						local l1, r1 = -xo, min(xo, cxI - wI)
						local l2, r2 = max(-xo, cxI + wI), xo
						if r1 - l1 > 0.35 then
							table.insert(segs, { l1, r1 })
						end
						if r2 - l2 > 0.35 then
							table.insert(segs, { l2, r2 })
						end
					else
						table.insert(segs, { -xo, xo })
					end
					for _, sg in segs do
						B:block(moon, v(sg[2] - sg[1], rowH + 0.02, depth + (r % 2) * 0.06), cf(MX + (sg[1] + sg[2]) / 2, MY + yc, z), (r % 2 == 0) and colA or colB)
					end
				end
			end
		end
		crescentRows(9.4, 3.7, 1.5, 7.6, MZ, 2.8, MS, MS_DK, 1.25)
		crescentRows(8.3, 3.7, 1.5, 8.6, MZ - 1.9, 1.0, MS_LT, MS_LT, 1.25)
		-- craters
		for _, q in { { -5.6, 2.4, 1.3 }, { -4.4, -3.9, 1.0 }, { -7.0, -1.0, 0.8 }, { -2.2, -6.4, 0.9 }, { -3.6, 5.6, 0.7 } } do
			B:block(moon, v(q[3], q[3], 0.2), cf(MX + q[1], MY + q[2], MZ - 2.4), MS_DK)
		end
		-- gold rim on the outer back edge
		for i = 0, 9 do
			local a = 200 + i * 22
			B:block(moon, v(2.4, 0.5, 0.4), pxy(MX, MY, MZ - 1.6, a, 9.3), (i % 2 == 0) and GOLD or GOLD_DK)
		end
		-- horn tip twinkles
		do
			local cx, cy, Ro, ri = 3.7, 1.5, 9.4, 7.6
			local d = sqrt(cx * cx + cy * cy)
			local a = (Ro * Ro - ri * ri + d * d) / (2 * d)
			local h = sqrt(Ro * Ro - a * a)
			local ux, uy = cx / d, cy / d
			local p1 = { a * ux - h * uy, a * uy + h * ux }
			local p2 = { a * ux + h * uy, a * uy - h * ux }
			B:block(moon, v(0.9, 0.9, 0.4), cf(MX + p1[1] - 0.5, MY + p1[2] - 0.6, MZ - 1.6, 0, 0, 45), STARW, N("MoonTip1"))
			B:block(moon, v(0.9, 0.9, 0.4), cf(MX + p2[1] - 0.8, MY + p2[2] + 0.3, MZ - 1.6, 0, 0, 45), STARW, N("MoonTip2"))
		end
		-- tilted gold orbit ring around the moon (precesses about Y)
		local mring = B:bone("MoonRing", "Moon", CFrame.new(MX, MY, MZ))
		local RC = CFrame.new(MX, MY, MZ) * CFrame.Angles(rad(72), 0, rad(22))
		B:ring(mring, RC, 12.6, 22, v(3.75, 0.45, 0.75), GOLD)
		for i = 0, 5 do
			local bc = RC * CFrame.Angles(0, rad(i * 60 + 8), 0) * CFrame.new(0, 0, -12.6)
			B:block(mring, v(0.9, 0.9, 0.9), bc * CFrame.Angles(rad(45), rad(45), 0), (i % 2 == 0) and CYAN or PINK, NEON)
			if i == 0 or i == 3 then
				B:trail(mring, (bc * CFrame.new(0, 0.6, 0)).Position, (bc * CFrame.new(0, -0.6, 0)).Position, { name = "MoonRingTrail" .. (i == 0 and 1 or 2), color = (i == 0) and { STARW, CYAN } or { STARW, PINK }, life = 0.5, width = { 1, 0.05 }, trans = { 0.2, 1 } })
			end
		end
		local SXp, SYp, SZp = MX + 5.6, MY + 1.0, MZ - 1.2
		local star = B:bone("StarTop", "Moon", CFrame.new(SXp, SYp, SZp))
		B:block(star, v(2.4, 2.4, 1.4), cf(SXp, SYp, SZp, 0, 0, 45), GOLD)
		for i = 0, 3 do
			local a = i * 90
			B:block(star, v(1.5, 2.0, 1.2), pxy(SXp, SYp, SZp, a, 2.0), GOLD)
			B:block(star, v(0.8, 1.4, 1.0), pxy(SXp, SYp, SZp, a, 3.5), GOLD_LT)
			B:block(star, v(0.8, 1.7, 0.9), pxy(SXp, SYp, SZp, a + 45, 1.9), GOLD_DK)
		end
		B:block(star, v(1.5, 1.5, 0.2), cf(SXp, SYp, SZp - 0.75, 0, 0, 45), GOLD_LT)
		B:block(star, v(0.8, 0.8, 0.3), cf(SXp, SYp, SZp - 0.9, 0, 0, 45), STARW, N("StarCore"))

		------------------------------------------------------------------
		-- FLOATING STAR CRYSTALS
		------------------------------------------------------------------
		local function crystal(name, pos, s, set, band)
			local cb = B:bone(name, R, CFrame.new(pos))
			local function L(sz, sy, y, c, o)
				return B:block(cb, v(sz * s, sy * s, sz * s), CFrame.new(pos + Vector3.new(0, y * s, 0)) * CFrame.Angles(0, rad(45), 0), c, o)
			end
			L(0.6, 0.8, -4.4, set[1])
			L(1.3, 1.2, -3.5, set[1])
			L(2.1, 1.4, -2.3, set[2])
			L(2.9, 2.4, -0.4, set[2])
			L(3.1, 0.5, 1.0, band, N(name .. "Band", 0.2))
			L(2.7, 2.2, 2.3, set[3])
			L(2.1, 1.6, 4.1, set[2])
			L(1.4, 1.4, 5.6, set[3])
			L(0.7, 1.2, 6.8, STARW)
			-- facet highlights (front faces)
			B:block(cb, v(0.4 * s, 2.6 * s, 0.2 * s), CFrame.new(pos + Vector3.new(-0.55 * s, 2.3 * s, -0.55 * s - 0.9 * s)) * CFrame.Angles(0, rad(45), 0), STARW)
			B:block(cb, v(0.35 * s, 1.6 * s, 0.2 * s), CFrame.new(pos + Vector3.new(0.5 * s, -0.6 * s, -0.5 * s - 1.0 * s)) * CFrame.Angles(0, rad(45), 0), set[3])
			-- satellite chips
			B:block(cb, v(0.7 * s, 0.7 * s, 0.7 * s), CFrame.new(pos + Vector3.new(3.4 * s, 1.5 * s, 0)) * CFrame.Angles(rad(45), rad(30), 0), GOLD_LT)
			B:block(cb, v(0.6 * s, 0.6 * s, 0.6 * s), CFrame.new(pos + Vector3.new(-3.0 * s, -1.8 * s, 1.0 * s)) * CFrame.Angles(rad(30), rad(45), 0), set[3])
		end
		crystal("CrystalL", Vector3.new(-26.5, topL + 11.5, PZ), 1.2, CR_V, CYAN)
		crystal("CrystalR", Vector3.new(26.5, topR + 14.5, PZ), 1.2, CR_C, PINK)
		crystal("CrystalL2", Vector3.new(-50, 58 + 7.5, 1), 0.95, CR_P, CYAN)
		crystal("CrystalR2", Vector3.new(50, 54 + 9.0, 1), 1.0, CR_V, PINK)

		------------------------------------------------------------------
		-- VFX: 7 emitters, 2 lights, 6 trails
		------------------------------------------------------------------
		local pfx = B:block(R, v(16, 16, 1), cf(0, PY, -4.5), VIO, { tr = 1, name = "PortalFx" })
		B:emitter(pfx, "sparkle", { name = "PortalSparkle", color = { STARW, CYAN, PINK }, rate = 22, size = { 0.4, 1.1, 0 }, life = { 0.8, 1.6 }, speed = { 0.5, 2 }, light = 1 })
		B:emitter(pfx, "glow", { name = "PortalGlow", color = { VIO_LT, CY_LT }, rate = 5, size = { 3, 6, 0 }, life = { 1.5, 2.5 }, speed = { 0.2, 0.6 }, light = 1, trans = { 0.6, 0.75, 1 } })
		B:emitter(pfx, "burst", { name = "PortalBurst", color = { STARW, CY_LT, PK_LT }, size = { 1.4, 0.8, 0 }, speed = { 16, 32 }, life = { 0.8, 1.5 }, drag = 2.0, light = 1, dir = "Front" })
		local mfx = B:block(R, v(110, 3, 30), cf(0, 7, -3), VIO, { tr = 1, name = "MoteFx" })
		B:emitter(mfx, "ember", { name = "StarMotes", tex = "sparkle", color = { STARW, CYAN, PINK }, rate = 16, size = { 0.5, 0.35, 0 }, life = { 3, 5 }, speed = { 0.6, 1.6 }, accel = { 0, 1.6, 0 }, light = 1 })
		local sfx = B:block(R, v(112, 22, 12), cf(0, 55, 0), VIO, { tr = 1, name = "SkyFx" })
		B:emitter(sfx, "sparkle", { name = "SkySparkle", color = { STARW, GOLD_LT, CY_LT }, rate = 16, size = { 0.3, 1.0, 0 }, life = { 0.6, 1.4 }, speed = { 0.1, 0.4 }, light = 1 })
		local mofx = B:block(moon, v(12, 12, 2), cf(MX + 1, MY, MZ - 1), VIO, { tr = 1, name = "MoonFx" })
		B:emitter(mofx, "sparkle", { name = "MoonSparkle", color = { STARW, GOLD_LT, GOLD }, rate = 8, size = { 0.3, 0.9, 0 }, life = { 0.7, 1.4 }, speed = { 0.3, 1 }, light = 1 })
		local stfx = B:block(R, v(52, 1, 9), cf(0, 2.5, -17), VIO, { tr = 1, name = "StairFx" })
		B:emitter(stfx, "burst", { name = "StairBurst", color = { STARW, CYAN, CY_LT }, size = { 0.8, 0.4, 0 }, speed = { 5, 11 }, life = { 0.6, 1.2 }, spread = 40, drag = 1.5, accel = { 0, -4, 0 }, light = 1 })
		local pl = B:block(core, v(0.4, 0.4, 0.4), cf(0, PY, -6), VIO, { tr = 1, name = "PortalLightCore" })
		B:light(pl, { name = "PortalLight", color = "#bfb0ff", brightness = 1.0, range = 40 })
		local ml = B:block(moon, v(0.4, 0.4, 0.4), cf(MX + 2, MY, MZ - 3), VIO, { tr = 1, name = "MoonLightCore" })
		B:light(ml, { name = "MoonLight", color = "#fff0c4", brightness = 0.8, range = 26 })
	end,
}
