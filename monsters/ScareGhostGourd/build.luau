--!nocheck
-- Harvest Moon Melon (Scarecrow Stage crop #7, Secret).
-- A night-sky melon vine climbing a rustic garden tepee. A stepped dirt
-- mound strewn with hay; three weathered wooden stakes lashed together with
-- straw twine; two teal-green vines spiral up the stakes, sprouting big
-- rotated studded leaf cubes in indigo / purple / violet speckled with tiny
-- glowing star dots, and a leafy cluster where the stakes cross. The melons
-- are pale cream with silver-blue stripes and a softly glowing crescent moon
-- on each flank: three big ones resting on hay at the foot, three hanging
-- off the vine. A chunky pale-gold crescent moon (with a sleepy smile) is
-- hooked on top, little star crosses twinkle around it.
-- Static prop: no motion.luau.
return {
	DisplayName = "Harvest Moon Melon",
	Rarity = "Secret",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette ---------------------------------------------------------
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local GRASS, GRASS_DK = "#7cc23a", "#5a9a2e"
		local HAY, HAY_DK, HAY_LT = "#e6bd55", "#c79634", "#f6da84"
		local WOOD, WOOD_DK, WOOD_LT = "#9a7046", "#7a5534", "#b88a5c"
		local VINE_DK, VINE, VINE_LT = "#22524a", "#2f6c5f", "#468a70"
		local LEAF_NT, LEAF_DK, LEAF, LEAF_LT, LEAF_HI = "#2c2368", "#3f2c8c", "#5a3cb0", "#7656cf", "#9c80e6"
		local MEL, MEL_SH = "#f3ebd3", "#e0d5b9"
		local STRIPE, STRIPE_DK = "#aebbd8", "#8f9cc0"
		local MOON_N = "#fff0a0"
		local MOON, MOON_DK = "#ffe28c", "#efc65e"
		local FACE = "#7a5426"
		local STAR_N, STAR_BLUE = "#fff7cc", "#bfe0ff"

		local seed = 7707
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
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
				local w, d = rnd(1.5, 2.4), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, math.rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 6.6, DIRT_DK, 16, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.6, 4.6, DIRT, 10, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.4, 0.4, 2.8, DIRT_LT, 6, { DIRT_LT, DIRT }, 0.2)
		for _, g in { { 6.4, -2.9 }, { -5.8, 3.7 }, { 3.9, 5.6 }, { -6.7, -0.6 } } do
			B:block(soil, v(0.45, 0.9, 0.45), cf(g[1], 1.0, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.35, 0.6, 0.35), cf(g[1] + 0.35, 0.95, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end
		-- loose straw bits scattered over the tiers
		for _, h in { { 5.3, 0.8, 1.6, 30 }, { -5.0, 0.8, -2.6, -40 }, { 0.4, 0.8, -6.0, 70 }, { -1.9, 0.8, 5.5, 10 },
			{ -3.2, 1.4, 1.6, 55 }, { 1.0, 1.8, 2.2, 80 } } do
			B:block(soil, v(1.6, 0.22, 0.32), cf(h[1], h[2] + 0.12, h[3], 0, h[4], 0), HAY, S)
			B:block(soil, v(1.1, 0.2, 0.28), cf(h[1] + 0.2, h[2] + 0.13, h[3] + 0.25, 0, h[4] + 35, 0), (h[4] % 20 == 0) and HAY_DK or HAY_LT, S)
		end
		-- hay pads the big melons rest on
		local function pad(x, z, yaw, y)
			B:block(soil, v(3.2, 0.3, 2.4), cf(x, y + 0.15, z, 0, yaw, 0), HAY, S)
			B:block(soil, v(2.5, 0.34, 3.0), cf(x, y + 0.17, z, 0, yaw + 8, 0), HAY_DK, S)
		end
		do
			local a = math.rad(-20)
			pad(math.sin(a) * 4.3, -math.cos(a) * 4.3, 20, 1.25)
		end

		------------------------------------------------------- tepee stakes
		local Y0 = 1.8
		local crop = B:bone("Crop", "Root", v(0, Y0, 0))
		local APEX = v(0, 13.0, 0.2)
		local BASE_R = 3.6
		local stakeAngles = { 60, 180, 300 } -- degrees around Y (0 = front, -Z)
		local function polar(deg, r, y)
			local a = math.rad(deg)
			return v(math.sin(a) * r, y, -math.cos(a) * r)
		end
		for i, deg in stakeAngles do
			local foot = polar(deg, BASE_R, 1.0)
			local dir = (APEX - foot).Unit
			local top = APEX + dir * 1.5
			B:beam(crop, foot, top, 0.9, 0.9, (i == 2) and WOOD_DK or WOOD)
			-- a lighter tip where it pokes out above the lashing
			B:beam(crop, APEX + dir * 0.9, top + dir * 0.15, 0.98, 0.98, WOOD_LT)
		end
		-- straw twine lashing at the crossing
		B:block(crop, v(1.5, 0.45, 1.5), CFrame.new(APEX + v(0, -0.15, 0)) * ang(0, 20, 0), HAY)
		B:block(crop, v(1.3, 0.4, 1.3), CFrame.new(APEX + v(0, 0.35, 0)) * ang(0, 65, 0), HAY_DK)
		B:block(crop, v(0.3, 0.9, 0.3), CFrame.new(APEX + v(0.5, -0.75, -0.6)) * ang(0, 0, 12), HAY_LT)

			end,
}
