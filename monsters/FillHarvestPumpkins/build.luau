--!nocheck
-- Pumpkin Pair (Harvest Fields filler prop).
-- Two small ribbed orange pumpkins sitting side by side on the grass, a
-- bigger one and a smaller one nudged against it, each with a crooked stem.
-- A short vine links the two stems and one broad pumpkin leaf lies across the
-- big one's shoulder. Uncarved, so twenty of them in a row look like a
-- pumpkin patch rather than a party. No motion, no effects.
return {
	DisplayName = "Pumpkin Pair",
	Rarity = "Filler",
	Filler = true,
	Element = "Harvest Fields",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		-- palette (Harvest Fields pumpkins)
		local PUMP, PUMP_DK, PUMP_LT = "#ff9424", "#e06c18", "#ffb042"
		local STEM, STEM_DK = "#6b7d2a", "#4f5e1e"
		local VINE = "#3f7a2a"
		local LEAF, LEAF_DK = "#4f9a34", "#3d7f2a"

		-- ribbed pumpkin: an octagon body (square + 45-degree square in two
		-- shades = alternating ribs) under a smaller stepped-in octagon shoulder
		local function pumpkin(x, z, w, yaw)
			local h = w * 0.74
			local hb = h * 0.72
			local C = cf(x, 0, z, 0, yaw, 0)
			B:block(R, v(w, hb, w), C * CFrame.new(0, hb / 2, 0), PUMP)
			B:block(R, v(w - 0.04, hb - 0.06, w - 0.04), C * CFrame.new(0, hb / 2, 0) * CFrame.Angles(0, rad(45), 0), PUMP_DK)
			local ws, hs = w * 0.72, h - hb + 0.15
			B:block(R, v(ws, hs - 0.06, ws), C * CFrame.new(0, h - hs / 2 - 0.03, 0) * CFrame.Angles(0, rad(45), 0), PUMP_LT)
			B:block(R, v(ws - 0.04, hs, ws - 0.04), C * CFrame.new(0, h - hs / 2, 0), PUMP)
			return C * CFrame.new(0, h, 0), w
		end

		local topA = pumpkin(-0.95, 0.25, 2.7, 10)
		local topB = pumpkin(1.5, -0.45, 1.9, -18)

		-- crooked stems
		local sA = topA * CFrame.new(0, 0.3, 0) * CFrame.Angles(0, 0, rad(-12))
		B:block(R, v(0.5, 0.75, 0.5), sA, STEM)
		B:block(R, v(0.36, 0.4, 0.36), sA * CFrame.new(0.14, 0.45, 0) * CFrame.Angles(0, 0, rad(-32)), STEM_DK)
		local sB = topB * CFrame.new(0, 0.24, 0) * CFrame.Angles(0, 0, rad(14))
		B:block(R, v(0.4, 0.55, 0.4), sB, STEM)
		-- little curled vine tendril off the small stem
		local t0 = (sB * CFrame.new(0.05, 0.1, 0)).Position
		local t1 = t0 + v(0.15, 0.25, 0.7)
		B:bar(R, t0, t1, 0.16, 0.16, VINE)
		B:bar(R, t1, t1 + v(0.45, -0.15, 0.05), 0.16, 0.16, VINE)

		-- one broad leaf lying on the big pumpkin's front-left shoulder, its tip
		-- drooping over the edge
		local lf = topA * CFrame.new(-0.5, 0.08, -0.5) * CFrame.Angles(rad(16), rad(25), rad(10))
		B:block(R, v(1.6, 0.16, 1.2), lf, LEAF)
		B:block(R, v(0.9, 0.14, 0.7), lf * CFrame.new(-0.4, -0.12, -0.75) * CFrame.Angles(rad(22), rad(-15), 0), LEAF_DK)
	end,
}
