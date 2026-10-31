--!nocheck
-- Honeycomb Chunk (Honey Hills filler prop, v2).
-- A broken chunk of honeycomb dropped on the grass, built like the comb on
-- HoneyCombPear / DecorHoneyHives:
-- * seven hexagonal wax cells (three crossed slabs each) at stepped heights,
--   every wall two-tone (dark wax foot band, golden wall), a pale wax lip
--   on the rim, amber honey inside with a glint; one capped with pale wax
-- * amber cell openings staggered on the outer side walls
-- * a honey drip running over a rim into a glossy puddle, a low grass
--   patch with tufts and a pebble round the foot
-- Filler: anchored, weld-free, no scripts. Scatter it over the hills.
return {
	DisplayName = "Honeycomb Chunk",
	Rarity = "Filler",
	Filler = true,
	Element = "Honey Hills",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local SQ3 = math.sqrt(3)
		local R = "Root"

		-- palette (Honey Hills: HoneyCombPear / DecorHoneyHives / HoneyButtercup)
		local WAX_LT, WAX, WAX_DK = "#ffe27a", "#ffc93c", "#e8a020"
		local CELL, CELL_DK = "#c87410", "#a65a0c"
		local HONEY_DK, HONEY, HONEY_LT = "#e08a14", "#ffa318", "#ffc54a"
		local CAP, CAP_DK = "#fff2b8", "#f6dc8c"
		local GLINT = "#fff6d0"
		local GR_DK, GR, GR_LT = "#7cae32", "#97c83e", "#b2d84c"
		local STONE, STONE_LT = "#a49a8c", "#c4bcae"

		-- hexagonal prism (flat edge facing local -Z) from three slabs
		local function hex(c, r, h, col)
			for k = 0, 2 do
				B:block(R, v(r, h - k * 0.015, SQ3 * r), c * ang(0, k * 60, 0), col)
			end
		end

		------------------------------------------------------------ grass footing
		B:block(R, v(4.6, 0.1, 2.8), cf(0.1, 0.05, 0.05, 0, 40, 0), GR_DK)
		B:block(R, v(2.8, 0.09, 4.6), cf(0.1, 0.045, 0.05, 0, 40, 0), GR_DK)
		B:block(R, v(3.7, 0.08, 3.7), cf(0.1, 0.04, 0.05, 0, 40, 0), GR_DK)

		------------------------------------------------------------ cells
		local r = 0.78
		local F = SQ3 * r -- centre-to-centre on the hex grid
		local frame = CFrame.new(0.1, 0, 0.05) * ang(0, 12, 0)
		local function at(a, d)
			return frame * ang(0, a, 0) * CFrame.new(0, 0, -d)
		end
		-- {cell frame, height, wall col, fill ("cap" for a capped cell), open sides}
		local cells = {
			{ at(0, 0), 1.25, WAX, HONEY, {} },
			{ at(0, F), 1.05, WAX_LT, HONEY_DK, { 300 } },
			{ at(60, F), 0.9, WAX, "cap", { 60 } },
			{ at(120, F), 1.1, WAX_LT, HONEY, { 120, 180 } },
			{ at(180, F), 0.75, WAX, HONEY_DK, { 180, 240 } },
			{ at(240, F), 0.95, WAX_LT, HONEY, { 240 } },
			{ at(300, F), 0.55, WAX, HONEY_DK, { 300 } },
		}
		for i, cl in cells do
			local c, h = cl[1], cl[2]
			local fb = math.min(0.3, h * 0.3)
			hex(c * CFrame.new(0, fb / 2, 0), r + 0.02, fb, WAX_DK) -- dark foot band
			hex(c * CFrame.new(0, fb + (h - fb) / 2 - 0.01, 0), r, h - fb, cl[3])
			hex(c * CFrame.new(0, h + 0.02, 0), r * 0.92, 0.06, WAX_LT) -- pale rim lip
			if cl[4] == "cap" then
				hex(c * CFrame.new(0, h + 0.06, 0), r * 0.74, 0.12, CAP_DK)
				B:block(R, v(0.55 * r, 0.1, 0.55 * r), c * CFrame.new(0, h + 0.15, 0) * ang(0, 30, 0), CAP)
			else
				hex(c * CFrame.new(0, h + 0.05, 0), r * 0.72, 0.08, cl[4])
				B:block(R, v(0.26, 0.05, 0.18), c * CFrame.new(-0.18, h + 0.09, 0.14) * ang(0, 30, 0), HONEY_LT)
			end
			-- amber cell openings on the exposed outer walls
			local apo = r * SQ3 / 2
			for j, a in cl[5] do
				local yy = (j % 2 == 1) and h * 0.58 or h * 0.42
				local q = CFrame.new(c.Position) * frame.Rotation * ang(0, a, 0) * CFrame.new(0, yy, -apo - 0.03)
				B:block(R, v(0.7 * r, math.min(0.5, h * 0.42), 0.1), q, (j % 2 == 1) and CELL or CELL_DK)
			end
		end

		------------------------------------------------------------ honey drip + puddle
		local apo = r * SQ3 / 2
		local d = CFrame.new(at(0, F).Position) * frame.Rotation * CFrame.new(0, 0, -apo - 0.05)
		local h2 = 1.05
		B:block(R, v(0.5, 0.14, 0.36), d * CFrame.new(0, h2 + 0.06, 0.08), HONEY_LT) -- spill over the rim
		B:block(R, v(0.42, 0.6, 0.14), d * CFrame.new(0, h2 - 0.28, -0.02), HONEY)
		B:block(R, v(0.3, 0.38, 0.14), d * CFrame.new(0.04, 0.3, -0.03), HONEY_DK)
		local pd = d * CFrame.new(0.05, 0, -0.65)
		B:block(R, v(1.3, 0.08, 0.85), pd * CFrame.new(0, 0.04, 0), HONEY_DK)
		B:block(R, v(1.1, 0.1, 0.65), pd * CFrame.new(0.02, 0.05, 0), HONEY)
		B:block(R, v(0.7, 0.11, 1.0), pd * CFrame.new(-0.05, 0.055, 0.05), HONEY)
		B:block(R, v(0.4, 0.12, 0.25), pd * CFrame.new(-0.2, 0.06, 0.1), GLINT)

		------------------------------------------------------------ crumb, grass, pebble
		local function tuft(c, h)
			B:block(R, v(0.22, h, 0.14), c * CFrame.new(-0.12, h / 2, 0) * ang(0, 0, 14), GR_DK)
			B:block(R, v(0.22, h * 1.25, 0.14), c * CFrame.new(0.02, h * 0.6, 0.05) * ang(-8, 0, -4), GR)
			B:block(R, v(0.2, h * 0.9, 0.14), c * CFrame.new(0.15, h * 0.45, -0.04) * ang(6, 0, -16), GR_LT)
		end
		tuft(at(90, F * 1.45) * ang(0, 20, 0), 0.55)
		tuft(at(270, F * 1.45) * ang(0, -30, 0), 0.5)
		tuft(at(150, F * 1.5) * ang(0, 70, 0), 0.45)
		local pb = at(222, F * 1.5)
		B:block(R, v(0.5, 0.3, 0.42), pb * CFrame.new(0, 0.15, 0) * ang(0, 30, 0), STONE)
		B:block(R, v(0.34, 0.1, 0.28), pb * CFrame.new(0, 0.35, 0) * ang(0, 30, 0), STONE_LT)
	end,
}
