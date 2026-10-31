--!nocheck
-- Honeycomb Chunk (Honey Hills filler prop).
-- A broken chunk of honeycomb dropped on the grass: a cluster of chunky
-- hexagonal wax cells at stepped heights (golden wax walls, amber honey
-- filling each cell, one capped with pale wax), a honey drip running down
-- one side into a small glossy puddle. Lies straight on the ground, no base.
-- Anchored, weld-free, no scripts: scatter it everywhere.
return {
	DisplayName = "Honeycomb Chunk",
	Rarity = "Filler",
	Filler = true,
	Element = "Honey Hills",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Honey Hills)
		local WAX_DK, WAX, WAX_LT = "#f5a114", "#ffc532", "#ffd448"
		local FILL, FILL_DK = "#ff9d0a", "#f07f00"
		local CAP = "#fff2b8"
		local HONEY, HONEY_TOP = "#ffc532", "#ffe272"

		-- hexagonal prism (flat edge facing local Z) from three slabs
		local function hex(c, r, h, col)
			local f = math.sqrt(3) * r
			for k = 0, 2 do
				B:block(R, v(r, h - k * 0.02, f), c * ang(0, k * 60, 0), col)
			end
		end

		-- cells on a hex grid: flat-to-flat F, centre-to-centre F
		local r = 0.95
		local F = math.sqrt(3) * r
		local frame = CFrame.new(0.15, 0, 0.1) * ang(0, 18, 0)
		local function at(a, d) -- grid direction (degrees) + distance
			return frame * ang(0, a, 0) * CFrame.new(0, 0, -d)
		end
		-- {frame, height, wall col, fill col}
		local cells = {
			{ at(0, 0), 1.2, WAX, FILL },
			{ at(0, F), 0.95, WAX_LT, FILL_DK },
			{ at(120, F), 1.05, WAX_LT, CAP },
			{ at(240, F), 0.8, WAX_DK, FILL },
			{ at(180, F), 0.6, WAX, FILL_DK },
		}
		for _, cl in cells do
			local h = cl[2]
			hex(cl[1] * CFrame.new(0, h / 2, 0), r, h, cl[3])
			hex(cl[1] * CFrame.new(0, h + 0.01, 0), r * 0.76, 0.1, cl[4])
		end

		-- honey drip down the front of the tall cell and a puddle at its foot
		local d = at(0, 0) * ang(0, 300, 0) * CFrame.new(0, 0, -F / 2 - 0.08)
		B:block(R, v(0.55, 0.5, 0.16), d * CFrame.new(0, 0.97, 0), FILL)
		B:block(R, v(0.32, 0.55, 0.16), d * CFrame.new(0.06, 0.45, 0.01), FILL_DK)
		local pd = d * CFrame.new(0.1, 0, -0.5)
		B:block(R, v(1.3, 0.1, 0.8), pd * CFrame.new(0, 0.05, 0), FILL)
		B:block(R, v(0.8, 0.12, 1.1), pd * CFrame.new(0.05, 0.06, -0.05), FILL)
		B:block(R, v(0.45, 0.13, 0.35), pd * CFrame.new(-0.2, 0.07, 0.05), HONEY_TOP)
	end,
}
