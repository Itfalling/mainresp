--!nocheck
-- Scattered Bones (Bramble Badlands filler).
-- A small spill of chunky cartoon dino bones on a low badlands footing:
-- * footing: flat rust-earth + grey ash patches (rounded: two crossed slabs +
--   a square turned 45°), two-tone charcoal pebbles, dry olive grass tufts
-- * two big "dog-bone" femurs lying crossed and a small one resting across
--   them; rounded shafts (square + 45° square), double-lobed rounded knobs
--   with a darker collar, a cream highlight ridge, cracks and a fossil stain
-- * a loose vertebra and a short curved rib poking out of the ash
-- * a thin dried bramble runner with cream thorns trailing over the bones
-- Exact Bone Pile / Ribcage Gourd palette. Sits straight on Y=0.
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Scattered Bones",
	Rarity = "Filler",
	Filler = true,
	Element = "Bramble Badlands",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Bramble Badlands: Bone Pile / Ribcage Gourd)
		local RK_DK, RK, RK_LT = "#3a3236", "#4a4044", "#625758"
		local RUST_DK, RUST, RUST_LT = "#7a3524", "#94452c", "#b05a36"
		local ASH_DK, ASH, ASH_LT = "#6c6662", "#88827c", "#a7a19a"
		local BONE_LT, BONE, BONE_DK, BONE_SH = "#fbf1d8", "#efe0bc", "#d8c398", "#b89f74"
		local STAIN = "#c08a5a"
		local BONE_MID = "#e6d4ac"
		local GRASS, GRASS_DK, GRASS_LT = "#9a8a4a", "#76693a", "#b3a35c"

		------------------------------------------------------------ footing
		-- rounded flat patch: a plus of two slabs + a square turned 45°
		local function patch(x, z, s, h, yaw, col, col2)
			B:block(R, v(s, h, s * 0.56), cf(x, h / 2, z, 0, yaw, 0), col)
			B:block(R, v(s * 0.56, h - 0.01, s), cf(x, h / 2, z, 0, yaw, 0), col)
			B:block(R, v(s * 0.68, h + 0.02, s * 0.68), cf(x, (h + 0.02) / 2, z, 0, yaw + 45, 0), col2 or col)
		end
		patch(-0.2, 0.1, 3.4, 0.14, 8, RUST_DK, RUST)
		patch(1.3, -0.9, 1.9, 0.2, 20, RUST, RUST_LT)
		patch(-1.5, 1.1, 1.6, 0.18, -10, ASH_DK, ASH)

		local function pebble(x, z, s, yaw, col, top)
			B:block(R, v(0.8 * s, 0.45 * s, 0.7 * s), cf(x, 0.22 * s, z, 0, yaw, 0), col)
			B:block(R, v(0.5 * s, 0.25 * s, 0.45 * s), cf(x - 0.05 * s, 0.55 * s, z, 0, yaw + 35, 0), top)
		end
		pebble(2.25, 0.9, 1.0, 25, RK, ASH)
		pebble(-2.3, -1.3, 0.8, -20, RK, RK_LT)
		pebble(0.9, 2.0, 0.6, 50, ASH_DK, ASH_LT)

		local function tuft(x, z, s, yaw)
			for k = 0, 2 do
				local a = yaw + k * 120
				local h = (0.55 + 0.15 * k) * s
				B:block(R, v(0.16, h, 0.16), CFrame.new(x, 0.12 + h / 2, z) * ang(0, a, 0) * ang(34, 0, 0) * CFrame.new(0, 0, -0.12), ({ GRASS, GRASS_DK, GRASS_LT })[k + 1])
			end
		end
		tuft(-0.3, -2.2, 0.9, 10)
		tuft(2.6, -0.5, 0.8, 70)

		------------------------------------------------------------ bones
		-- cartoon femur along local Z of frame F: rounded shaft, highlight
		-- ridge, darker collars, rounded double-lobed knobs at both ends
		local function femur(F, len, t, crack)
			B:block(R, v(t, t, len), F, BONE)
			B:block(R, v(t * 0.92, t * 0.92, len - 0.06), F * ang(0, 0, 45), BONE_MID)
			B:block(R, v(t * 0.5, t * 0.3, len * 0.7), F * CFrame.new(0, t * 0.42, 0), BONE_LT)
			local k = t * 1.15
			for sz = -1, 1, 2 do
				local z = sz * (len / 2 + k * 0.1)
				B:block(R, v(t * 1.12, t * 1.12, 0.24), F * CFrame.new(0, 0, sz * (len / 2 - 0.3)), BONE_SH)
				for sx = -1, 1, 2 do
					local K = F * CFrame.new(sx * k * 0.42, 0, z)
					B:block(R, v(k, k, k * 0.95), K, (sx > 0) and BONE or BONE_DK)
					B:block(R, v(k * 0.9, k * 0.9, k), K * ang(0, 0, 45), (sx > 0) and BONE_LT or BONE)
				end
			end
			if crack then
				B:bar(R, (F * CFrame.new(-t * 0.2, t * 0.52, -len * 0.15)).Position, (F * CFrame.new(t * 0.15, t * 0.52, len * 0.05)).Position, 0.08, 0.06, BONE_SH)
				B:block(R, v(t * 0.6, 0.06, t * 0.8), F * CFrame.new(t * 0.05, t * 0.5, len * 0.25), STAIN)
			end
		end

		-- two big femurs lying crossed on the footing (knob bottoms on the soil)
		femur(cf(-0.35, 0.47, 0.25, 0, 62, 0), 3.6, 0.62, true)
		femur(cf(0.75, 0.45, -0.45, 0, -26, 0), 2.9, 0.52, false)
		-- a small one resting across them
		local F = P.aim(v(-1.3, 0.55, -1.15), v(0.95, 1.25, 0.85))
		femur(F, 2.1, 0.42, false)

		-- loose vertebra
		local VB = cf(1.6, 0.14, 1.25, 0, 30, 0)
		B:block(R, v(0.8, 0.5, 0.8), VB * CFrame.new(0, 0.25, 0), BONE)
		B:block(R, v(0.8, 0.48, 0.8), VB * CFrame.new(0, 0.25, 0) * ang(0, 45, 0), BONE_DK)
		B:block(R, v(1.5, 0.22, 0.28), VB * CFrame.new(0, 0.45, 0), BONE_LT)
		B:block(R, v(0.28, 0.5, 0.36), VB * CFrame.new(0, 0.7, 0.05), BONE_LT)

		-- short curved rib poking out of the ash
		local rib = { v(-1.7, 0.1, 1.5), v(-1.95, 0.75, 1.75), v(-1.85, 1.35, 2.15), v(-1.5, 1.7, 2.45) }
		for i = 1, #rib - 1 do
			local d = (rib[i + 1] - rib[i]).Unit
			B:bar(R, rib[i] - d * 0.08, rib[i + 1] + d * 0.08, 0.36 - 0.05 * i, 0.3 - 0.04 * i, (i == 2) and BONE_LT or BONE)
		end
		B:block(R, v(0.3, 0.3, 0.3), CFrame.new(rib[4]) * ang(0, 30, 0), BONE_DK)

		-- a dried bramble runner trailing over the bones (maroon stem, thorns)
		local STEM_DK, STEM, THORN = "#4a2030", "#6a2e3c", "#e8d6ae"
		local run = { v(2.3, 0.15, -0.6), v(1.6, 0.75, -0.1), v(0.6, 1.05, 0.35), v(-0.2, 0.95, 0.9), v(-0.6, 0.3, 1.3) }
		for i = 1, #run - 1 do
			local d = (run[i + 1] - run[i]).Unit
			B:bar(R, run[i] - d * 0.06, run[i + 1] + d * 0.06, 0.2, 0.2, (i % 2 == 0) and STEM or STEM_DK)
			local m = (run[i] + run[i + 1]) / 2
			local sd = d:Cross(v(0, 1, 0)).Unit * ((i % 2 == 0) and 1 or -1)
			B:bar(R, m, m + sd * 0.32 + v(0, 0.18, 0), 0.12, 0.12, THORN)
		end
	end,
}
