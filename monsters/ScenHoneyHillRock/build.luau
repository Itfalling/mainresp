--!nocheck
-- Meadow Boulder (Honey Hills scenery, big copy-paste filler).
-- A big warm-grey boulder of stepped stone masses (a tall back crag, a broad
-- middle and a low front shelf, plus a small loose rock), each with a dark
-- base band, chamfered corners, a lighter top shoulder and cracks, all
-- capped with thick meadow grass that drips over the edges. Daisies, pink
-- clover blossoms, clover leaves and grass tufts grow on top and around the
-- foot. Low flat meadow footing with pebbles. Filler: anchored, weld-free,
-- no scripts.
return {
	DisplayName = "Meadow Boulder",
	Rarity = "Scenery",
	Filler = true,
	Element = "Honey Hills",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Honey Hills: DecorHoneySign / FillHoneyClover / FillHoneyDaisies)
		local SOIL_DK, SOIL = "#6b4226", "#875533"
		local GR_DK, GR, GR_LT, GR_XL = "#7cae32", "#97c83e", "#b2d84c", "#d2e872"
		local STONE_DK, STONE, STONE_LT, STONE_XL = "#857b6e", "#a49a8c", "#c4bcae", "#d8d0c2"
		local CRACK = "#6a6156"
		local STEM = "#3f9440"
		local CLOVER, CLOVER_DK = "#3f9a3c", "#2f7f30"
		local DAISY, DAISY_SH, DAISY_EYE = "#fffaf2", "#f1e6dc", "#ffc93a"
		local CLV_FL, CLV_TIP = "#fff4f8", "#ffb6d0"

		local seed = 4241
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function round(c, r, h, col)
			B:block(R, v(2 * r, h, 1.1 * r), c, col)
			B:block(R, v(1.1 * r, h - 0.02, 2 * r), c, col)
			B:block(R, v(1.72 * r, h - 0.04, 1.72 * r), c, col)
		end

		------------------------------------------------------------ footing (low + flat)
		round(cf(0, 0.06, 0, 0, 10, 0), 7.4, 0.12, GR_DK)
		round(cf(0.3, 0.12, -0.2, 0, 35, 0), 5.8, 0.12, GR)
		for _, m in { { -5.6, -3.4, 2.6, 1.6, 20, GR_LT }, { 5.2, 3.4, 2.6, 1.8, -25, GR_LT }, { 5.8, -3.2, 2.0, 1.4, 40, GR_XL }, { -4.4, 4.4, 2.2, 1.4, -10, GR_XL } } do
			B:block(R, v(m[3], 0.16, m[4]), cf(m[1], 0.17, m[2], 0, m[5], 0), m[6])
		end
		B:block(R, v(1.8, 0.16, 1.1), cf(1.6, 0.16, -5.6, 0, 20, 0), SOIL)
		B:block(R, v(1.2, 0.16, 0.9), cf(-6.6, 0.16, 0.8, 0, -30, 0), SOIL_DK)
		local function pebble(x, z, s, ry)
			B:block(R, v(1.2 * s, 0.5 * s, 0.9 * s), cf(x, 0.25 * s, z, 0, ry, 0), STONE)
			B:block(R, v(0.7 * s, 0.25 * s, 0.5 * s), cf(x + 0.1, 0.55 * s, z, 0, ry + 20, 0), STONE_LT)
		end
		pebble(6.4, 0.4, 1.0, 20)
		pebble(-2.0, -5.6, 0.8, -30)
		pebble(2.8, 5.4, 0.7, 50)

		------------------------------------------------------------ stone masses
		local tops = {}
		-- stepped octagonal tier: two crossed slabs + a chamfer square (3 tones)
		local function tier(c, sx, h, sz, cA, cB)
			B:block(R, v(sx, h, sz * 0.56), c, cA)
			B:block(R, v(sx * 0.56, h - 0.02, sz), c, cA)
			B:block(R, v(sx * 0.86, h - 0.04, sz * 0.86), c, cB)
		end
		-- x, z: ground centre; sx, h, sz: footprint + height; yaw
		local function mass(x, z, sx, h, sz, yaw, drips, nt)
			nt = nt or 3
			local base = CFrame.new(x, 0, z) * ang(0, yaw, 0)
			local spec = { { 1.0, 0.5, 0, STONE, STONE_DK }, { 0.88, 0.3, 10, STONE, STONE_LT }, { 0.72, 0.2, -6, STONE_LT, STONE } }
			local y = 0
			local tc, tsx, tsz
			for i = 1, nt do
				local t = spec[i]
				local th = h * t[2] * ((nt == 2) and 1.4 or 1)
				tsx, tsz = sx * t[1], sz * t[1]
				tc = base * ang(0, t[3], 0) * CFrame.new(0, y + th / 2, 0)
				tier(tc, tsx, th + 0.02, tsz, t[4], t[5])
				if i == 1 then
					-- darker foot band
					tier(base * CFrame.new(0, 0.4, 0), sx * 1.04, 0.8, sz * 1.04, STONE_DK, CRACK)
				end
				if i == 1 then
					-- a couple of grass patches growing on the first ledge
					for k, a in { 30 + yaw, 200 + yaw } do
						local q = base * ang(0, a, 0) * CFrame.new(0, th + 0.1, -math.min(sx, sz) * 0.44)
						B:block(R, v(2.2, 0.3, 1.0), q, (k == 1) and GR or GR_DK)
						B:block(R, v(1.2, 0.34, 0.6), q * CFrame.new(0.3, 0.05, 0.1), GR_LT)
					end
				end
				y += th
			end
			-- grass cap on top
			local capC = base * CFrame.new(0, y + 0.22, 0)
			tier(capC * ang(0, spec[nt][3], 0), tsx * 1.04, 0.45, tsz * 1.04, GR, GR_DK)
			B:block(R, v(tsx * 0.5, 0.35, tsz * 0.5), capC * CFrame.new(-0.2, 0.3, 0.15) * ang(0, 25, 0), GR_LT)
			-- grass drips over the top edge
			for _, d in drips do
				local face, off, len = d[1], d[2], d[3]
				local half = (face % 2 == 0) and tsz * 0.5 or tsx * 0.5
				local q = base * ang(0, spec[nt][3] + face * 90, 0) * CFrame.new(off, y + 0.1 - len / 2, -half - 0.1)
				B:block(R, v(1.2, len, 0.3), q, (face % 2 == 0) and GR or GR_DK)
				B:block(R, v(0.6, len * 0.5, 0.32), q * CFrame.new(0.3, -len * 0.55, 0), GR_DK)
			end
			table.insert(tops, { base = base, sx = sx, sz = sz, h = h, y = y, tsx = tsx, tsz = tsz })
		end
		mass(-2.2, 2.0, 7.0, 8.4, 6.4, -18, { { 0, 0.3, 1.4 }, { 1, -0.3, 1.0 } })
		mass(0.8, -0.2, 9.0, 5.4, 7.6, 12, { { 0, -0.6, 1.2 }, { 1, 0.5, 1.0 }, { 2, 0.3, 1.0 } })
		mass(4.6, -2.2, 5.4, 3.2, 5.0, 32, { { 0, 0.2, 0.9 } }, 2)
		mass(-5.8, -2.4, 3.0, 2.0, 2.6, 40, {}, 2)

		-- cracks on the lower tiers
		for _, c in { { 2, 0, -1.4, 1.6, 0.9 }, { 1, 0, 0.9, 2.2, 1.0 }, { 2, 1, 0.6, 1.4, 0.9 }, { 3, 0, -0.5, 1.2, 0.8 } } do
			local t = tops[c[1]]
			local half = (c[2] % 2 == 0) and t.sz * 0.5 or t.sx * 0.5
			local q = t.base * ang(0, c[2] * 90, 0) * CFrame.new(c[3], c[5] + c[4] / 2, -half - 0.04)
			B:block(R, v(0.22, c[4], 0.2), q * ang(0, 0, 12), CRACK)
			B:block(R, v(0.22, c[4] * 0.5, 0.2), q * CFrame.new(0.35, c[4] * 0.4, 0) * ang(0, 0, -28), CRACK)
		end

		------------------------------------------------------------ flowers + clover
		local function onTop(i, fx, fz)
			local t = tops[i]
			return (t.base * CFrame.new(fx * t.tsx * 0.42, t.y + 0.45, fz * t.tsz * 0.42)).Position
		end
		local function daisy(p, h, s)
			s = (s or 1) * 1.7
			local top = p + v(0.1, h, 0)
			B:bar(R, p, top, 0.22, 0.22, STEM)
			local q = CFrame.new(top) * ang(0, rnd(0, 90), 0)
			B:block(R, v(1.1 * s, 0.24, 0.5 * s), q, DAISY)
			B:block(R, v(0.5 * s, 0.26, 1.1 * s), q, DAISY_SH)
			B:block(R, v(0.8 * s, 0.22, 0.8 * s), q * ang(0, 45, 0), DAISY)
			B:block(R, v(0.42 * s, 0.34, 0.42 * s), q * CFrame.new(0, 0.08, 0), DAISY_EYE)
		end
		local function cloverFlower(p, h)
			local top = p + v(0, h, 0)
			B:bar(R, p, top, 0.2, 0.2, STEM)
			B:block(R, v(0.8, 0.7, 0.8), CFrame.new(top + v(0, 0.3, 0)) * ang(0, 30, 0), CLV_FL)
			B:block(R, v(0.6, 0.4, 0.6), CFrame.new(top + v(0, 0.8, 0)) * ang(0, 10, 0), CLV_TIP)
		end
		local function clover(p, s)
			s = s or 1
			for k = 0, 2 do
				local a = rad(k * 120)
				B:block(R, v(0.65 * s, 0.18, 0.65 * s), CFrame.new(p + v(math.sin(a) * 0.38 * s, 0.05, -math.cos(a) * 0.38 * s)) * ang(0, k * 120 + 45, 0), (k == 0) and CLOVER_DK or CLOVER)
			end
		end
		local function tuft(p)
			for k = 0, 2 do
				B:bar(R, p + v((k - 1) * 0.25, 0, 0), p + v((k - 1) * 0.45, 0.9 + 0.25 * (k % 2), rnd(-0.2, 0.2)), 0.22, 0.22, (k == 1) and GR_LT or GR_DK)
			end
		end
		-- on top of the boulder
		daisy(onTop(1, -0.3, -0.2), 0.9)
		daisy(onTop(1, 0.4, 0.3), 0.6, 0.85)
		cloverFlower(onTop(1, 0.1, -0.6), 0.7)
		tuft(onTop(1, -0.6, 0.5))
		daisy(onTop(2, 0.5, -0.4), 0.8)
		daisy(onTop(2, -0.5, -0.6), 0.6, 0.85)
		daisy(onTop(2, 0.7, 0.5), 0.9)
		cloverFlower(onTop(2, 0.0, 0.1), 0.8)
		cloverFlower(onTop(2, -0.7, 0.2), 0.6)
		clover(onTop(2, 0.25, -0.75))
		tuft(onTop(2, -0.2, 0.7))
		daisy(onTop(3, 0.1, -0.2), 0.7)
		clover(onTop(3, -0.5, 0.4))
		cloverFlower(onTop(3, 0.5, 0.5), 0.6)
		-- around the foot
		daisy(v(-4.0, 0.15, -4.4), 1.0)
		daisy(v(-3.4, 0.15, -4.9), 0.7, 0.85)
		daisy(v(6.4, 0.15, -2.2), 0.9)
		daisy(v(-6.4, 0.15, 2.6), 0.8)
		cloverFlower(v(2.6, 0.15, -5.0), 0.8)
		cloverFlower(v(5.4, 0.15, 2.8), 0.7)
		clover(v(0.4, 0.2, -5.4))
		clover(v(-6.8, 0.2, -0.4))
		clover(v(4.0, 0.2, 4.6))
		tuft(v(-1.4, 0.15, -4.6))
		tuft(v(6.6, 0.15, -0.8))
		tuft(v(-3.4, 0.15, 5.0))
	end,
}
