--!nocheck
-- Mossy Roots (Snap-Jaw Jungle filler).
-- A gnarled clump of chunky jungle roots: a squat stepped knot with a moss
-- cap, five thick roots that hump up out of it and dive back into the ground
-- (alternating bark shades), moss pads draped over some of the knees and a
-- tiny pink toadstool with one small glowing lime spot tucked against the
-- knot. Lightweight scenery meant to be copy-pasted many times: anchored,
-- weld-free, no scripts or effects.
return {
	DisplayName = "Mossy Roots",
	Rarity = "Filler",
	Filler = true,
	Element = "Snap-Jaw Jungle",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		-- palette (Snap-Jaw Jungle)
		local ROOT, ROOT_DK, ROOT_LT = "#8b5a31", "#5a361d", "#a87244"
		local MOSS, MOSS_DK, GREEN_LT = "#6cb337", "#4f8f2a", "#9fd84a"
		local PINK, CREAM = "#ff6d8a", "#fff4d2"
		local LIME = "#a6ff3c"

		local function bar(a, b, w, h, col, ext, up)
			local c, len = P.aim(a, b, up)
			ext = ext or 0.2
			B:block(R, v(w, h, len + 2 * ext), c, col)
			return c, len
		end

		------------------------------------------------------------ knot
		B:block(R, v(2.0, 0.9, 1.7), cf(0, 0.45, 0, 0, 18, 0), ROOT_DK)
		B:block(R, v(1.5, 1.6, 1.3), cf(0.1, 0.8, 0.05, 0, 60, 0), ROOT)
		B:block(R, v(1.0, 0.8, 0.9), cf(-0.1, 1.8, 0.1, 6, 25, -8), ROOT_LT)
		B:block(R, v(1.6, 0.3, 1.2), cf(0.15, 1.65, -0.05, 0, 40, 0), MOSS)
		B:block(R, v(0.9, 0.25, 0.8), cf(-0.15, 2.25, 0.1, 6, 10, -8), MOSS_DK)

		------------------------------------------------------------ roots
		-- each root humps out of the knot and dives back into the ground; the
		-- bars roll a little around their own axis so the clump looks gnarled.
		-- yaw, knee distance, knee height, reach, colour, roll, moss on knee?
		local roots = {
			{ 20, 1.45, 1.4, 2.6, ROOT, 0.35, true },
			{ 95, 1.35, 1.15, 2.3, ROOT_DK, -0.3, false },
			{ 160, 1.5, 1.5, 2.7, ROOT, 0.25, true },
			{ 230, 1.3, 1.05, 2.2, ROOT_LT, -0.4, false },
			{ 300, 1.45, 1.3, 2.5, ROOT_DK, 0.3, true },
		}
		for _, r in roots do
			local a = rad(r[1])
			local dir = v(math.sin(a), 0, -math.cos(a))
			local side = v(math.cos(a), 0, math.sin(a))
			local up = v(0, 1, 0) + side * r[6]
			local p0 = dir * 0.5 + v(0, 1.0, 0)
			local p1 = dir * r[2] + v(0, r[3], 0)
			local p2 = dir * r[4] + v(0, 0.38, 0)
			local c1 = bar(p0, p1, 0.85, 0.75, r[5], 0.3, up)
			bar(p1, p2, 0.7, 0.62, r[5], 0.25, up)
			if r[7] then
				B:block(R, v(0.8, 0.22, 1.0), CFrame.new(p1) * (c1 - c1.Position) * CFrame.new(0, 0.42, 0.25), MOSS_DK)
			end
		end

		------------------------------------------------------------ toadstool
		local T = v(-0.55, 0, -1.4) -- in the gap between the front roots
		B:block(R, v(0.35, 0.9, 0.35), CFrame.new(T + v(0, 0.45, 0)), CREAM)
		B:block(R, v(0.85, 0.35, 0.85), CFrame.new(T + v(0, 1.0, 0)) * CFrame.Angles(0, rad(20), 0), PINK)
		B:block(R, v(0.22, 0.12, 0.22), CFrame.new(T + v(0.12, 1.2, -0.1)) * CFrame.Angles(0, rad(20), 0), LIME, { mat = "Neon" })
		-- little sprout on the knot
		B:block(R, v(0.25, 0.7, 0.25), cf(0.35, 2.3, -0.1, 0, 0, 14), GREEN_LT)
	end,
}
