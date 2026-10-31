--!nocheck
-- Jungle Fern (Snap-Jaw Jungle filler).
-- A low clump of chunky fern fronds fanning out from a dark root crown. Each
-- frond is two flat studded blades (a wide green inner blade with a dark
-- midrib, a narrower lime tip that droops back toward the ground) plus two
-- short young fronds standing up in the middle. Lightweight scenery meant to
-- be copy-pasted many times: anchored, weld-free, no scripts or effects.
return {
	DisplayName = "Jungle Fern",
	Rarity = "Filler",
	Filler = true,
	Element = "Snap-Jaw Jungle",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		-- palette (Snap-Jaw Jungle crops)
		local DIRT_DK = "#3f2516"
		local GREEN, GREEN_DK, GREEN_LT, GREEN_TOP = "#3caa3c", "#1f6e2a", "#9fd84a", "#58c447"

		-- flat blade from a to b, extended a little past both ends so the
		-- segments overlap at the joints
		local function blade(a, b, w, h, col, ext, lift)
			local cfr, len = P.aim(a, b)
			ext = ext or 0.15
			B:block(R, v(w, h, len + 2 * ext), cfr * CFrame.new(0, lift or 0, 0), col)
			return cfr, len
		end

		------------------------------------------------------------ crown
		B:block(R, v(1.3, 0.5, 1.3), cf(0, 0.25, 0, 0, 20, 0), DIRT_DK)
		B:block(R, v(0.9, 0.7, 0.9), cf(0, 0.45, 0, 0, 65, 0), GREEN_DK)

		------------------------------------------------------------ fronds
		-- each frond: a dark midrib in two arching segments with crosswise
		-- leaflet blocks that step narrower toward the drooping tip
		-- yaw, length, rise, base leaflet colour, tip leaflet colour
		local fronds = {
			{ 10, 3.2, 2.1, GREEN, GREEN_LT },
			{ 68, 2.8, 1.8, GREEN_TOP, GREEN_LT },
			{ 128, 3.3, 2.0, GREEN, GREEN_LT },
			{ 190, 2.9, 2.3, GREEN_TOP, GREEN_LT },
			{ 250, 3.1, 1.9, GREEN, GREEN_LT },
			{ 308, 2.7, 2.2, GREEN_TOP, GREEN_LT },
		}
		local widths = { 1.9, 1.6, 1.25, 0.8 }
		for _, f in fronds do
			local a = rad(f[1])
			local dir = v(math.sin(a), 0, -math.cos(a))
			local p0 = v(0, 0.55, 0) + dir * 0.3
			local p1 = dir * (f[2] * 0.45) + v(0, f[3], 0)
			local p2 = dir * f[2] + v(0, f[3] * 0.4, 0)
			local c1, l1 = blade(p0, p1, 0.35, 0.35, GREEN_DK, 0.15)
			local c2, l2 = blade(p1, p2, 0.3, 0.3, GREEN_DK, 0.05)
			local at = {
				c1 * CFrame.new(0, 0.1, l1 * (0.5 - 0.42)),
				c1 * CFrame.new(0, 0.1, l1 * (0.5 - 0.85)),
				c2 * CFrame.new(0, 0.1, l2 * (0.5 - 0.35)),
				c2 * CFrame.new(0, 0.1, l2 * (0.5 - 0.82)),
			}
			for i, c in at do
				B:block(R, v(widths[i], 0.25, 0.85), c, i <= 2 and f[4] or f[5])
			end
		end

		------------------------------------------------------------ young fronds
		for _, y in { { 0.15, 0.1, 2.3, 8 } } do
			local base = v(y[1], 0.5, y[2])
			local top = v(y[1] + math.sin(rad(y[4])) * 0.6, y[3], y[2] - 0.3)
			blade(base, top, 0.55, 0.3, GREEN_LT, 0.1)
			B:block(R, v(0.55, 0.45, 0.55), CFrame.new(top + v(0, 0.12, -0.1)), GREEN_TOP)
		end
	end,
}
