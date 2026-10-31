--!nocheck
-- Daisy Clump (Honey Hills filler prop, v2).
-- A bunch of chunky meadow daisies in the DecorHoneySign / HoneyClover style:
-- * five daisies at three heights, heads tilted outward: eight separate cream
--   petals (alternating two whites, tips lifted), a stepped golden heart
--   (amber base, gold dome, pale top) and a green calyx under each head
-- * two-segment stems, a little stem leaf on the tall ones, a closed bud
-- * a rosette of spoon-shaped basal leaves with pale midribs
-- * a low grassy footing: soil peek, three-tone grass tufts and a pebble
-- Filler: anchored, weld-free, no scripts. Scatter it over the hills.
return {
	DisplayName = "Daisy Clump",
	Rarity = "Filler",
	Filler = true,
	Element = "Honey Hills",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Honey Hills: DecorHoneySign / HoneyClover)
		local SOIL_DK, SOIL = "#6b4226", "#875533"
		local GR_DK, GR, GR_LT, GR_XL = "#7cae32", "#97c83e", "#b2d84c", "#d2e872"
		local LEAF_DK, LEAF, LEAF_LT = "#46a83a", "#5dbd40", "#7fcf4e"
		local MIDRIB = "#a6dd78"
		local STEM, STEM_DK = "#3f9440", "#2f7a34"
		local STONE, STONE_LT = "#a49a8c", "#c4bcae"
		local DAISY, DAISY_SH = "#fffaf2", "#f1e6dc"
		local EYE_DK, EYE, EYE_LT = "#f5a114", "#ffc93a", "#ffe27a"

		------------------------------------------------------------ footing
		B:block(R, v(2.6, 0.12, 2.6), cf(0.05, 0.06, 0.05, 0, 20, 0), GR_DK)
		B:block(R, v(2.1, 0.11, 2.1), cf(0.05, 0.055, 0.05, 0, 65, 0), GR_DK)
		B:block(R, v(1.5, 0.16, 1.2), cf(-0.3, 0.08, -0.25, 0, 35, 0), GR)
		B:block(R, v(0.8, 0.15, 0.6), cf(0.45, 0.075, 0.5, 0, 10, 0), SOIL)
		local function tuft(x, z, yaw, h)
			local c = CFrame.new(x, 0, z) * ang(0, yaw, 0)
			B:block(R, v(0.22, h, 0.14), c * CFrame.new(-0.12, h / 2, 0) * ang(0, 0, 14), GR_DK)
			B:block(R, v(0.22, h * 1.25, 0.14), c * CFrame.new(0.02, h * 0.6, 0.05) * ang(-8, 0, -4), GR)
			B:block(R, v(0.2, h * 0.9, 0.14), c * CFrame.new(0.15, h * 0.45, -0.04) * ang(6, 0, -16), GR_LT)
		end
		tuft(1.2, 0.5, 20, 0.5)
		tuft(-1.15, -0.65, -40, 0.55)
		tuft(-0.6, 1.15, 70, 0.45)
		tuft(0.75, -1.1, 110, 0.4)
		B:block(R, v(0.5, 0.3, 0.42), cf(1.15, 0.15, -0.45, 0, 30, 0), STONE)
		B:block(R, v(0.34, 0.1, 0.28), cf(1.14, 0.35, -0.46, 0, 30, 0), STONE_LT)
		-- tiny pink wildflower at the edge
		B:block(R, v(0.14, 0.5, 0.14), cf(-1.25, 0.3, 0.45), STEM)
		B:block(R, v(0.5, 0.14, 0.22), cf(-1.25, 0.58, 0.45, 0, 20, 0), "#ff9ec8")
		B:block(R, v(0.22, 0.15, 0.5), cf(-1.25, 0.58, 0.45, 0, 20, 0), "#ff9ec8")
		B:block(R, v(0.18, 0.18, 0.18), cf(-1.25, 0.66, 0.45, 0, 20, 0), EYE)

		------------------------------------------------------------ basal leaves
		for i, l in { { 10, 1.35, LEAF }, { 80, 1.15, LEAF_DK }, { 150, 1.3, LEAF_LT }, { 220, 1.2, LEAF }, { 290, 1.25, LEAF_DK } } do
			local c = CFrame.new(0, 0.18, 0) * ang(0, l[1], 0) * ang(16, 0, 0)
			B:block(R, v(0.32, 0.12, l[2]), c * CFrame.new(0, 0, -l[2] / 2 - 0.1), l[3]) -- stalk
			B:block(R, v(0.62, 0.13, 0.62), c * CFrame.new(0, 0.01, -l[2] - 0.15) * ang(0, 45, 0), l[3]) -- spoon tip
			if i % 2 == 1 then
				B:block(R, v(0.08, 0.14, l[2] * 0.85), c * CFrame.new(0, 0.01, -l[2] * 0.6), MIDRIB)
			end
		end

		------------------------------------------------------------ daisies
		local function daisy(bx, bz, tx, ty, tz, s, spin, leaf)
			local b0, t = v(bx, 0.15, bz), v(tx, ty, tz)
			local m = b0:Lerp(t, 0.5) + v(0, 0.1, 0) - (t - b0) * v(0.15, 0, 0.15)
			B:bar(R, b0, m, 0.2, 0.2, STEM_DK)
			B:bar(R, m - (m - b0).Unit * 0.08, t, 0.18, 0.18, STEM)
			if leaf then
				local d = (t - b0) * v(1, 0, 1)
				local side = d.Magnitude > 0.01 and v(-d.Z, 0, d.X).Unit or v(1, 0, 0)
				B:bar(R, m, m + side * 0.55 + v(0, 0.3, 0), 0.32, 0.1, LEAF, { up = v(0, 1, 0) })
			end
			local lean = v(tx - bx, 0, tz - bz)
			local tilt = math.clamp(lean.Magnitude * 26, 0, 38)
			local yaw = lean.Magnitude > 0.01 and math.deg(math.atan2(-lean.X, -lean.Z)) or 0
			local h = CFrame.new(t) * ang(0, yaw, 0) * ang(-tilt, 0, 0) * ang(0, spin, 0)
			B:block(R, v(0.45 * s, 0.22, 0.45 * s), h * CFrame.new(0, -0.12, 0) * ang(0, 45, 0), STEM) -- calyx
			for k = 0, 7 do
				local q = h * ang(0, k * 45, 0) * CFrame.new(0, 0, -0.55 * s) * ang(7, 0, 0)
				B:block(R, v(0.34 * s, 0.12, 0.78 * s), q, (k % 2 == 0) and DAISY or DAISY_SH)
			end
			B:block(R, v(0.6 * s, 0.16, 0.6 * s), h * CFrame.new(0, 0.05, 0), EYE_DK)
			B:block(R, v(0.48 * s, 0.24, 0.48 * s), h * CFrame.new(0, 0.1, 0) * ang(0, 45, 0), EYE)
			B:block(R, v(0.24 * s, 0.1, 0.24 * s), h * CFrame.new(-0.06, 0.25, 0.06) * ang(0, 20, 0), EYE_LT)
		end
		daisy(0.0, 0.0, 0.1, 2.7, -0.1, 1.05, 10, true)
		daisy(0.25, -0.2, 1.05, 2.05, -0.75, 0.95, 30, true)
		daisy(-0.25, -0.1, -1.05, 1.75, -0.55, 0.9, -15, false)
		daisy(0.2, 0.3, 0.85, 1.4, 0.95, 0.8, 50, false)
		daisy(-0.2, 0.3, -0.7, 2.25, 0.85, 0.95, 5, true)

		------------------------------------------------------------ closed bud
		local bb, bt = v(0.1, 0.15, 0.2), v(0.35, 1.2, 0.5)
		B:bar(R, bb, bt, 0.16, 0.16, STEM)
		B:block(R, v(0.34, 0.3, 0.34), CFrame.new(bt + v(0, 0.12, 0)) * ang(0, 20, 0), STEM_DK)
		B:block(R, v(0.26, 0.32, 0.26), CFrame.new(bt + v(0, 0.36, 0)) * ang(0, 65, 0), DAISY_SH)
	end,
}
