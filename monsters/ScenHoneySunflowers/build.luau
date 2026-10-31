--!nocheck
-- Sunflower Clump (Honey Hills scenery, big copy-paste filler).
-- Five tall sunflowers of staggered heights growing in one clump: chunky green
-- stems (two crossed bars per segment, slight bends), big stepped leaves with
-- pale midribs, and huge heads tilted up toward the sun: a green sepal back,
-- two rings of golden petals (main + darker back ring with orange tips) and
-- a stepped brown seed disc with a lighter seed ring. Low flat meadow footing
-- with clover, daisies and pebbles. Filler: anchored, weld-free, no scripts.
return {
	DisplayName = "Sunflower Clump",
	Rarity = "Scenery",
	Filler = true,
	Element = "Honey Hills",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Honey Hills: DecorHoneyHives sunflower / FillHoneyDaisies)
		local SOIL_DK, SOIL = "#6b4226", "#875533"
		local GR_DK, GR, GR_LT, GR_XL = "#7cae32", "#97c83e", "#b2d84c", "#d2e872"
		local LEAF_DK, LEAF, LEAF_LT = "#46a83a", "#5dbd40", "#7fcf4e"
		local MIDRIB = "#a6dd78"
		local STEM, STEM_DK = "#3f9440", "#2f7a34"
		local CLOVER, CLOVER_DK = "#3f9a3c", "#2f7f30"
		local PEB, PEB_LT = "#a49a8c", "#c4bcae"
		local DAISY, DAISY_EYE = "#fffaf2", "#ffc93a"
		local SUN_LT, SUN, SUN_DK, SUN_TIP = "#ffe46b", "#ffd23a", "#f5b81f", "#f5a623"
		local DISC_DK, DISC, DISC_LT = "#4f2e16", "#7a4a22", "#9a6030"

		local seed = 4233
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function round(c, r, h, col)
			B:block(R, v(2 * r, h, 1.1 * r), c, col)
			B:block(R, v(1.1 * r, h - 0.02, 2 * r), c, col)
			B:block(R, v(1.72 * r, h - 0.04, 1.72 * r), c, col)
		end
		-- flat disc in the local XY plane (thickness along local Z)
		local function disc(c, r, d, col, c2)
			B:block(R, v(2 * r, 1.1 * r, d), c, col)
			B:block(R, v(1.1 * r, 2 * r, d - 0.02), c, c2 or col)
			B:block(R, v(1.72 * r, 1.72 * r, d - 0.04), c, col)
		end

		------------------------------------------------------------ footing (low + flat)
		round(cf(0, 0.06, 0, 0, 10, 0), 5.2, 0.12, GR_DK)
		round(cf(-0.2, 0.12, 0.2, 0, 35, 0), 3.8, 0.12, GR)
		for _, m in { { -3.2, -2.4, 2.2, 1.6, 20, GR_LT }, { 3.0, 2.4, 2.4, 1.6, -25, GR_LT }, { 3.4, -2.2, 1.8, 1.2, 40, GR_XL }, { -2.8, 3.0, 2.0, 1.4, -10, GR_XL } } do
			B:block(R, v(m[3], 0.16, m[4]), cf(m[1], 0.17, m[2], 0, m[5], 0), m[6])
		end
		B:block(R, v(2.4, 0.16, 1.8), cf(0.2, 0.16, 0.4, 0, 15, 0), SOIL)
		B:block(R, v(1.4, 0.18, 1.0), cf(0.6, 0.18, 0.6, 0, 40, 0), SOIL_DK)
		local function pebble(x, z, s, ry)
			B:block(R, v(1.2 * s, 0.5 * s, 0.9 * s), cf(x, 0.25 * s, z, 0, ry, 0), PEB)
			B:block(R, v(0.7 * s, 0.25 * s, 0.5 * s), cf(x + 0.1, 0.55 * s, z, 0, ry + 20, 0), PEB_LT)
		end
		pebble(4.2, 0.2, 1.0, 20)
		pebble(-4.0, 1.2, 0.8, -30)
		local function daisy(x, z, h)
			B:bar(R, v(x, 0.15, z), v(x + 0.1, h, z), 0.2, 0.2, CLOVER)
			B:block(R, v(0.9, 0.2, 0.36), cf(x + 0.1, h, z, 0, 20, 0), DAISY)
			B:block(R, v(0.36, 0.22, 0.9), cf(x + 0.1, h, z, 0, 20, 0), DAISY)
			B:block(R, v(0.32, 0.26, 0.32), cf(x + 0.1, h + 0.06, z, 0, 20, 0), DAISY_EYE)
		end
		daisy(-3.6, -1.2, 0.8)
		daisy(-1.6, 3.8, 0.9)
		local function clover(x, z)
			for k = 0, 2 do
				B:block(R, v(0.6, 0.18, 0.6), cf(x + math.sin(rad(k * 120)) * 0.35, 0.3, z - math.cos(rad(k * 120)) * 0.35, 0, k * 120 + 45, 0), (k == 0) and CLOVER_DK or CLOVER)
			end
		end
		clover(-2.0, -3.4)
		clover(3.6, 1.8)

		------------------------------------------------------------ sunflower
		-- base (ground point), H height of head centre, lean (horizontal offset of
		-- the head), yaw (face direction, 0 = -Z), r head radius
		local function sunflower(base, H, lean, yaw, r, leaves)
			local top = base + lean + v(0, H, 0)
			local mid = base + lean * 0.3 + v(0, H * 0.55, 0)
			local w = 0.65 + r * 0.12
			B:bar(R, base - v(0, 0.1, 0), mid + v(0, 0.15, 0), w, w, STEM)
			B:bar(R, mid - v(0, 0.15, 0), top - v(0, 0.2, 0), w * 0.9, w * 0.9, STEM_DK, { up = v(1, 0, 1).Unit })
			-- leaves
			for k, L in leaves do
				local p = base:Lerp(mid, L[1]) + (mid - base) * 0
				if L[1] > 1 then p = mid:Lerp(top, L[1] - 1) end
				local s = L[3]
				local c = CFrame.new(p) * ang(0, L[2], 0) * ang(14, 0, 0)
				-- short leaf stalk, then a wide stepped heart-shaped blade drooping at the tip
				B:block(R, v(0.35, 0.3, 0.9 * s), c * CFrame.new(0, 0, -0.45 * s), STEM)
				B:block(R, v(2.0 * s, 0.3, 1.6 * s), c * CFrame.new(0, 0, -1.6 * s), LEAF)
				B:block(R, v(1.4 * s, 0.3, 1.4 * s), c * CFrame.new(0, -0.02, -2.9 * s) * ang(-12, 0, 0), LEAF_DK)
				B:block(R, v(0.7 * s, 0.3, 0.8 * s), c * CFrame.new(0, -0.25, -3.8 * s) * ang(-24, 0, 0), LEAF_DK)
				B:block(R, v(1.2 * s, 0.32, 1.0 * s), c * CFrame.new(0.2 * s, 0.03, -1.7 * s), LEAF_LT)
				B:block(R, v(0.22, 0.36, 2.4 * s), c * CFrame.new(0, 0.05, -1.9 * s), MIDRIB)
			end
			-- head: local -Z = face direction, tilted up
			local F = CFrame.new(top) * ang(0, yaw, 0) * ang(22, 0, 0)
			-- green sepal back
			disc(F * CFrame.new(0, 0, 0.35), r * 0.62, 0.5, STEM_DK, STEM)
			-- back petal ring (darker, offset, longer)
			for k = 0, 7 do
				local a = k * 45 + 22.5
				local q = F * ang(0, 0, a) * CFrame.new(0, r * 0.82, 0.12)
				B:block(R, v(r * 0.42, r * 0.72, 0.28), q, (k % 2 == 0) and SUN_DK or SUN_TIP)
			end
			-- front petal ring
			for k = 0, 7 do
				local a = k * 45
				local q = F * ang(0, 0, a) * CFrame.new(0, r * 0.72, -0.08)
				B:block(R, v(r * 0.44, r * 0.66, 0.3), q, (k % 2 == 0) and SUN or SUN_LT)
			end
			-- seed disc: stepped
			disc(F * CFrame.new(0, 0, -0.25), r * 0.5, 0.45, DISC_DK)
			disc(F * CFrame.new(0, 0, -0.45), r * 0.36, 0.4, DISC, DISC_LT)
			B:block(R, v(r * 0.3, r * 0.3, 0.3), F * CFrame.new(0, 0, -0.62) * ang(0, 0, 45), DISC_DK)
		end

		-- big ground leaves around the clump
		for k, a in { 20, 115, 200, 290 } do
			local c = CFrame.new(0.2, 0.3, 0.4) * ang(0, a, 0) * ang(10, 0, 0)
			B:block(R, v(2.2, 0.3, 3.2), c * CFrame.new(0, 0, -3.0), (k % 2 == 0) and LEAF_DK or LEAF)
			B:block(R, v(1.2, 0.32, 2.4), c * CFrame.new(0.2, 0.03, -3.2), (k % 2 == 0) and LEAF or LEAF_LT)
		end

		sunflower(v(0.0, 0.1, 0.8), 14.6, v(0.2, 0, -0.4), 5, 2.6, { { 0.5, 60, 1.2 }, { 0.85, 220, 1.1 }, { 1.4, 130, 0.9 } })
		sunflower(v(-2.4, 0.1, 1.6), 11.8, v(-1.5, 0, 0.2), 70, 2.3, { { 0.45, 260, 1.1 }, { 0.9, 20, 1.0 } })
		sunflower(v(2.2, 0.1, 1.4), 12.6, v(1.4, 0, 0.6), -110, 2.4, { { 0.55, 100, 1.1 }, { 1.2, 300, 0.9 } })
		sunflower(v(-1.4, 0.1, -1.4), 8.6, v(-1.0, 0, -0.9), 22, 2.0, { { 0.5, 200, 1.0 }, { 0.9, 330, 0.8 } })
		sunflower(v(1.6, 0.1, -1.0), 6.6, v(0.9, 0, -1.1), -20, 1.8, { { 0.55, 80, 0.9 } })
	end,
}
