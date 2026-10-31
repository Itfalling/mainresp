--!nocheck
-- Little Cactus (Sandy Savanna filler).
-- A small stepped saguaro with one upturned arm, standing on a single flat
-- sand footing. The trunk and arm are ribbed columns (a square block plus a
-- darker 45-degree block so the corners read as ribs) that step narrower to
-- a light crown; a few cream spine cubes sit on the rib edges and a small
-- pink bud tops the trunk. Lightweight scenery meant to be copy-pasted many
-- times: anchored, weld-free, no scripts or effects.
return {
	DisplayName = "Little Cactus",
	Rarity = "Filler",
	Filler = true,
	Element = "Sandy Savanna",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		-- palette (Sandy Savanna)
		local SAND_DK = "#c48a45"
		local CAC_DK, CAC, CAC_LT, CAC_TOP = "#428a3a", "#5aa848", "#7cc35a", "#9ad66c"
		local SPINE = "#fbefcc"
		local PETAL, CENTER = "#ff7fb4", "#ffe066"

		-- ribbed column section: square block + darker 45-degree block
		local function column(x, z, y0, h, w, col, colDk)
			B:block(R, v(w, h, w), cf(x, y0 + h / 2, z), col)
			B:block(R, v(w * 0.92, h - 0.04, w * 0.92), cf(x, y0 + h / 2, z, 0, 45, 0), colDk)
		end

		------------------------------------------------------------ footing
		B:block(R, v(2.2, 0.25, 2.0), cf(0, 0.125, 0, 0, 15, 0), SAND_DK)

		------------------------------------------------------------ trunk
		column(0, 0, 0.1, 3.6, 1.6, CAC, CAC_DK)
		column(0, 0, 3.6, 1.9, 1.35, CAC, CAC_DK)
		column(0, 0, 5.4, 0.45, 1.0, CAC_LT, CAC)
		B:block(R, v(0.6, 0.25, 0.6), cf(0, 5.95, 0, 0, 45, 0), CAC_TOP)

		------------------------------------------------------------ arm
		-- horizontal elbow out to +X, then an upturned forearm
		B:block(R, v(1.5, 1.0, 1.0), cf(1.2, 2.4, 0), CAC)
		B:block(R, v(1.4, 0.92, 0.92), cf(1.2, 2.4, 0, 45, 0, 0), CAC_LT)
		column(1.95, 0, 1.9, 2.3, 1.0, CAC, CAC_DK)
		column(1.95, 0, 4.15, 0.35, 0.75, CAC_LT, CAC)

		------------------------------------------------------------ spines
		-- small cubes on the 45-degree rib edges
		-- yaw (deg, 0 = front), height, column width
		local spines = {
			{ 0, 1.3, 1.6 }, { 90, 1.1, 1.6 }, { 180, 1.8, 1.6 }, { 270, 3.1, 1.6 },
			{ 0, 4.5, 1.35 }, { 180, 4.2, 1.35 },
		}
		for _, s in spines do
			local a = rad(s[1])
			local r = 0.92 * s[3] / math.sqrt(2) + 0.02
			B:block(R, v(0.2, 0.2, 0.2), cf(math.sin(a) * r, s[2], -math.cos(a) * r, 0, 45, 0), SPINE)
		end
		B:block(R, v(0.2, 0.2, 0.2), cf(1.95 + 0.92 / math.sqrt(2) + 0.02, 3.4, 0, 0, 45, 0), SPINE)

		------------------------------------------------------------ bud
		B:block(R, v(0.7, 0.3, 0.7), cf(0.05, 6.2, 0, 0, 20, 0), PETAL)
		B:block(R, v(0.3, 0.2, 0.3), cf(0.05, 6.4, 0, 0, 20, 0), CENTER)
	end,
}
