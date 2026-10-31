--!nocheck
-- Daisy Clump (Honey Hills filler prop).
-- A small bunch of five chunky white daisies on green stems at different
-- heights, heads tilted outward, each with a cross of cream petals, a shaded
-- diagonal petal layer and a golden centre. A few flat leaf blades and one
-- flat grass footing slab. Anchored, weld-free, no scripts: scatter freely.
return {
	DisplayName = "Daisy Clump",
	Rarity = "Filler",
	Filler = true,
	Element = "Honey Hills",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Honey Hills, from DecorHoneySign / HoneyClover)
		local GR_DK, GR = "#7cae32", "#97c83e"
		local LEAF, LEAF_DK, LEAF_LT = "#5dbd40", "#46a83a", "#7fcf4e"
		local STEM = "#3f9440"
		local DAISY, DAISY_SH, DAISY_EYE, EYE_DK = "#fffaf2", "#f1e6dc", "#ffc93a", "#f5a114"

		-- flat grass footing
		B:block(R, v(1.8, 0.16, 1.2), cf(0, 0.08, 0, 0, 20, 0), GR_DK)
		B:block(R, v(1.2, 0.18, 1.7), cf(0.05, 0.09, 0, 0, 20, 0), GR)

		-- leaf blades fanning out low
		for i, l in { { 0, 1.3, LEAF }, { 72, 1.1, LEAF_DK }, { 150, 1.25, LEAF_LT }, { 215, 1.0, LEAF }, { 290, 1.2, LEAF_DK } } do
			local d = v(math.sin(rad(l[1])), 0, -math.cos(rad(l[1])))
			B:bar(R, d * 0.2 + v(0, 0.2, 0), d * 1.35 + v(0, l[2], 0), 0.5, 0.12, l[3], { up = d })
		end

		-- daisy: stem bar + head tilted along the stem direction
		local function daisy(bx, bz, tx, ty, tz, s, spin)
			local base, top = v(bx, 0.2, bz), v(tx, ty, tz)
			B:bar(R, base, top, 0.22, 0.22, STEM)
			local lean = v(tx - bx, 0, tz - bz)
			local tilt = math.clamp(lean.Magnitude * 18, 0, 35)
			local yaw = lean.Magnitude > 0.01 and math.deg(math.atan2(-lean.X, -lean.Z)) or 0
			local h = CFrame.new(top) * ang(0, yaw, 0) * ang(-tilt, 0, 0) * ang(0, spin, 0)
			B:block(R, v(1.5 * s, 0.18, 0.55 * s), h, DAISY)
			B:block(R, v(0.55 * s, 0.17, 1.5 * s), h, DAISY)
			B:block(R, v(1.05 * s, 0.14, 1.05 * s), h * CFrame.new(0, -0.04, 0) * ang(0, 45, 0), DAISY_SH)
			B:block(R, v(0.55 * s, 0.28, 0.55 * s), h * CFrame.new(0, 0.08, 0), (spin > 20) and EYE_DK or DAISY_EYE)
		end
		daisy(0.0, 0.0, 0.1, 2.6, -0.1, 1.1, 10)
		daisy(0.3, -0.2, 1.0, 2.0, -0.7, 1.0, 30)
		daisy(-0.3, -0.1, -1.0, 1.8, -0.6, 0.95, -15)
		daisy(0.2, 0.3, 0.8, 1.5, 0.9, 0.9, 50)
		daisy(-0.2, 0.3, -0.7, 2.2, 0.8, 1.0, 5)
	end,
}
