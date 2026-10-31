--!nocheck
-- Baby Snapper (Snap-Jaw Jungle filler).
-- A tiny flytrap plant: a low rosette of four flat leaves, a short leaning
-- stem and one chunky trap head propped open toward the front. Each jaw is a
-- green outer shell stepped with a lighter crown, a hot-pink inner pad and a
-- few cream block teeth along the rim (upper and lower teeth interleave).
-- Lightweight scenery meant to be copy-pasted many times: anchored,
-- weld-free, no scripts or effects.
return {
	DisplayName = "Baby Snapper",
	Rarity = "Filler",
	Filler = true,
	Element = "Snap-Jaw Jungle",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Snapjaw Flytrap / Flytrap Stage)
		local DIRT_DK = "#3f2516"
		local GREEN, GREEN_DK, GREEN_LT, GREEN_TOP = "#3caa3c", "#1f6e2a", "#a6e04c", "#58c447"
		local INSIDE, RIM = "#ff5c7c", "#c92a48"
		local CREAM = "#fff4d2"

		local function bar(a, b, w, h, col, ext)
			local c, len = P.aim(a, b)
			ext = ext or 0.15
			B:block(R, v(w, h, len + 2 * ext), c, col)
			return c, len
		end

		------------------------------------------------------------ rosette
		B:block(R, v(0.9, 0.35, 0.9), cf(0, 0.18, 0, 0, 30, 0), DIRT_DK)
		for i, yaw in { 35, 125, 215, 305 } do
			local a = rad(yaw)
			local dir = v(math.sin(a), 0, -math.cos(a))
			local tip = dir * 1.6 + v(0, 0.35, 0)
			local c = bar(v(0, 0.3, 0), tip, 0.8, 0.25, i % 2 == 1 and GREEN or GREEN_TOP, 0.1)
			-- lighter leaf tip
			B:block(R, v(0.55, 0.27, 0.5), CFrame.new(tip) * (c - c.Position), GREEN_LT)
		end

		------------------------------------------------------------ stem
		local H = v(0.15, 2.2, 0.4) -- hinge at the back of the head
		bar(v(0, 0.25, 0), v(0.05, 1.3, 0.15), 0.55, 0.55, GREEN_DK, 0.1)
		bar(v(0.05, 1.3, 0.15), H + v(0, -0.2, 0), 0.5, 0.5, GREEN_DK, 0.15)

		------------------------------------------------------------ head
		-- jaw frames: hinge at origin, jaw reaching toward local -Z
		local base = CFrame.new(H) * ang(0, 12, 0) * ang(8, 0, 0)
		local lower = base * ang(-6, 0, 0)
		local upper = base * ang(38, 0, 0)
		local L, W = 1.6, 1.8

		-- hinge knot
		B:block(R, v(1.1, 0.7, 0.6), base * CFrame.new(0, 0, 0.05), GREEN_DK)

		-- lower jaw: shell below, lighter belly step, pink pad on top
		B:block(R, v(W, 0.45, L), lower * CFrame.new(0, -0.2, -L / 2), GREEN)
		B:block(R, v(W - 0.6, 0.3, L - 0.5), lower * CFrame.new(0, -0.5, -L / 2 + 0.1), GREEN_TOP)
		B:block(R, v(W - 0.35, 0.12, L - 0.3), lower * CFrame.new(0, 0.06, -L / 2 - 0.05), INSIDE)
		B:block(R, v(W + 0.04, 0.2, 0.25), lower * CFrame.new(0, 0, -L + 0.1), RIM)

		-- upper jaw: shell above, lighter crown step, pink pad underneath
		B:block(R, v(W, 0.45, L), upper * CFrame.new(0, 0.2, -L / 2), GREEN)
		B:block(R, v(W - 0.6, 0.3, L - 0.5), upper * CFrame.new(0, 0.5, -L / 2 + 0.1), GREEN_LT)
		B:block(R, v(W - 0.35, 0.12, L - 0.3), upper * CFrame.new(0, -0.06, -L / 2 - 0.05), INSIDE)
		B:block(R, v(W + 0.04, 0.2, 0.25), upper * CFrame.new(0, 0, -L + 0.1), RIM)

		-- teeth: lower ones point up, upper ones point down, interleaved
		for _, x in { -0.65, 0, 0.65 } do
			B:block(R, v(0.24, 0.5, 0.24), lower * CFrame.new(x, 0.3, -L + 0.12), CREAM)
		end
		for _, x in { -0.33, 0.33 } do
			B:block(R, v(0.24, 0.5, 0.24), upper * CFrame.new(x, -0.3, -L + 0.12), CREAM)
		end
	end,
}
