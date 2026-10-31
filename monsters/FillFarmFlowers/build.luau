--!nocheck
-- Flower Patch (Sunny Farm filler). A small loose cluster of tulips in red,
-- yellow and white on short green stems, with a few broad upright leaves and
-- one flat leafy footing so the patch sits on the grass. Each tulip head is a
-- cup block topped by two crossed petal blocks (a lighter shade), which reads
-- as the pointy tulip crown from any angle.
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Flower Patch",
	Rarity = "Filler",
	Filler = true,
	Element = "Sunny Farm",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		local STEM, LEAF, LEAF_DK = "#3fb43a", "#2f9f34", "#2a8f33"
		local COLS = {
			red = { "#e8242c", "#ff5a4f" },
			yellow = { "#ffcc1f", "#ffe35c" },
			white = { "#f2f2f2", "#ffffff" },
		}

		-- flat leafy footing
		B:block(R, v(2.4, 0.14, 1.9), cf(0, 0.07, 0, 0, 12, 0), LEAF_DK)

		local function tulip(x, z, h, col, ry)
			local c = COLS[col]
			B:block(R, v(0.22, h, 0.22), cf(x, h / 2, z), STEM)
			local head = CFrame.new(x, h, z) * CFrame.Angles(0, math.rad(ry), 0)
			B:block(R, v(0.6, 0.6, 0.6), head * CFrame.new(0, 0.25, 0), c[1])
			B:block(R, v(0.7, 0.35, 0.22), head * CFrame.new(0, 0.62, 0) * CFrame.Angles(0, math.rad(45), 0), c[2])
			B:block(R, v(0.22, 0.35, 0.7), head * CFrame.new(0, 0.62, 0) * CFrame.Angles(0, math.rad(45), 0), c[2])
		end
		tulip(-0.75, -0.55, 1.5, "red", 10)
		tulip(0.35, -0.85, 1.25, "yellow", 30)
		tulip(1.05, 0.05, 1.6, "white", 5)
		tulip(-0.1, 0.25, 1.85, "red", 40)
		tulip(-1.1, 0.6, 1.2, "yellow", 20)
		tulip(0.55, 0.95, 1.35, "red", 15)
		tulip(-0.2, -1.35, 1.0, "white", 25)

		-- broad upright leaves, tilted out from the patch centre
		local leaves = {
			{ -0.45, -0.1, 0.9, 30, 0, -20, LEAF },
			{ 0.75, -0.45, 0.8, -25, 50, 18, LEAF_DK },
			{ 0.25, 0.6, 0.85, -22, -30, 0, LEAF },
			{ -0.9, 0.05, 0.7, 15, 70, 22, LEAF_DK },
		}
		for _, l in leaves do
			B:block(R, v(0.5, l[3], 0.16), cf(l[1], l[3] / 2 + 0.05, l[2], l[4], l[5], l[6]), l[7])
		end
	end,
}
