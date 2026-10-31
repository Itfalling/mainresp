--!nocheck
-- Lava-Crack Rock (Bramble Badlands filler).
-- A lumpy stepped charcoal boulder: a dark tilted base, an offset middle
-- block and a lighter top cap, two jutting side chunks, a flat rust-earth
-- footing, grey ash dusting and one tiny glowing lava seam.
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Lava-Crack Rock",
	Rarity = "Filler",
	Filler = true,
	Element = "Bramble Badlands",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"

		local RK_DK, RK, RK_LT, RK_HI = "#3a3236", "#4a4044", "#625758", "#776b69"
		local RUST_DK, RUST = "#7a3524", "#94452c"
		local ASH, ASH_LT = "#88827c", "#a7a19a"
		local LAVA, LAVA_HOT = "#ff5a14", "#ffa431"
		local NEON = { mat = "Neon" }

		-- stepped, slightly tilted body
		B:block(R, v(3.2, 1.2, 2.6), cf(0, 0.5, 0, 0, 10, 3), RK)
		local M = cf(-0.25, 1.45, 0.05, -4, -12, 5)
		B:block(R, v(2.5, 1.1, 2.1), M, RK_LT)
		B:block(R, v(1.5, 0.8, 1.4), cf(-0.55, 2.25, 0.25, 3, 22, 6), RK_HI)
		B:block(R, v(0.9, 0.2, 0.8), cf(-0.6, 2.7, 0.3, 3, 35, 6), ASH) -- ash dusting
		B:block(R, v(0.8, 0.2, 0.7), cf(0.75, 2.02, -0.2, 0, 15, 0), ASH_LT)

		-- jutting side chunks
		B:block(R, v(1.4, 1.5, 1.5), cf(1.5, 0.7, -0.3, 0, 32, -6), RK_DK)
		B:block(R, v(0.9, 0.5, 0.9), cf(1.4, 1.55, -0.25, 0, 50, -6), RK)
		B:block(R, v(1.3, 0.9, 1.2), cf(-1.75, 0.4, 0.55, 0, -22, 4), RK_DK)
		-- flat rust-earth footing peeking out from under the rock
		B:block(R, v(3.6, 0.14, 2.4), cf(0.15, 0.07, -0.1, 0, -18, 0), RUST)
		B:block(R, v(1.4, 0.18, 1.0), cf(-1.2, 0.09, -1.15, 0, 20, 0), RUST_DK)

		-- one tiny lava seam on the front face of the middle block
		local z = -1.07
		local a = (M * CFrame.new(0.3, -0.45, z)).Position
		local b = (M * CFrame.new(0.08, 0.0, z)).Position
		local c = (M * CFrame.new(0.3, 0.38, z)).Position
		B:bar(R, a, b, 0.18, 0.18, LAVA, NEON)
		B:bar(R, b, c, 0.16, 0.16, LAVA_HOT, NEON)
	end,
}
