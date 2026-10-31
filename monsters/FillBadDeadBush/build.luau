--!nocheck
-- Dead Thorn Bush (Bramble Badlands filler).
-- A dried-out bramble clump in the Ash Thistle / Bone Pile style:
-- * a rounded, two-tier root crown (two crossed slabs + a square turned 45°)
--   with stubby roots flaring into the ground
-- * five kinked dusky-maroon branches of three tapering segments each, lighter
--   knuckle blocks at every kink (like the thistle stalk joints), a hooked
--   bleached tip, a pale grey side twig and cream bone thorns
-- * a few curled dry olive leaves and shrivelled dark blackberry husks
-- * footing: flat rust-earth + ash patch, pebbles, dry grass tufts
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Dead Thorn Bush",
	Rarity = "Filler",
	Filler = true,
	Element = "Bramble Badlands",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Bramble Badlands: Bone Pile bramble + crops)
		local STEM_DK, STEM, STEM_LT = "#4a2030", "#6a2e3c", "#86445a"
		local TWIG, TWIG_LT = "#9b948c", "#bfb8ae"
		local THORN, THORN_DK = "#e8d6ae", "#d3c19a"
		local LEAF_DK, LEAF_DRY = "#4c5e2a", "#8a7a40"
		local BERRY_DK, BERRY = "#3c1630", "#5a2346"
		local ROCK_DK, ROCK, ROCK_LT = "#352d2a", "#463c38", "#5e524c"
		local RUST_DK, RUST, RUST_LT = "#6e2e1f", "#8c3e28", "#a65334"
		local ASH_DK, ASH = "#77706a", "#9b948c"
		local GRASS, GRASS_DK, GRASS_LT = "#9a8a4a", "#76693a", "#b3a35c"

		local function dir(deg)
			return v(math.sin(rad(deg)), 0, -math.cos(rad(deg)))
		end

		------------------------------------------------------------ footing
		local function patch(x, z, s, h, yaw, col, col2)
			B:block(R, v(s, h, s * 0.56), cf(x, h / 2, z, 0, yaw, 0), col)
			B:block(R, v(s * 0.56, h - 0.01, s), cf(x, h / 2, z, 0, yaw, 0), col)
			B:block(R, v(s * 0.68, h + 0.02, s * 0.68), cf(x, (h + 0.02) / 2, z, 0, yaw + 45, 0), col2 or col)
		end
		patch(0, 0, 3.4, 0.12, 15, RUST_DK, RUST)
		patch(0.9, 0.9, 1.4, 0.16, -20, ASH_DK, ASH)
		patch(-0.9, -0.6, 1.3, 0.15, 30, RUST, RUST_LT)

		local function pebble(x, z, s, yaw, col, top)
			B:block(R, v(0.8 * s, 0.45 * s, 0.7 * s), cf(x, 0.22 * s, z, 0, yaw, 0), col)
			B:block(R, v(0.5 * s, 0.25 * s, 0.45 * s), cf(x - 0.05 * s, 0.55 * s, z, 0, yaw + 35, 0), top)
		end
		pebble(1.35, -1.05, 0.85, 25, ROCK_LT, ASH)
		pebble(-1.5, 0.7, 0.65, -30, ROCK, ROCK_LT)
		pebble(-0.4, 1.6, 0.5, 60, RUST, RUST_LT)

		local function tuft(x, z, s, yaw)
			for k = 0, 2 do
				local h = (0.5 + 0.15 * k) * s
				B:block(R, v(0.16, h, 0.16), CFrame.new(x, 0.12 + h / 2, z) * ang(0, yaw + k * 120, 0) * ang(34, 0, 0) * CFrame.new(0, 0, -0.12), ({ GRASS, GRASS_DK, GRASS_LT })[k + 1])
			end
		end
		tuft(-1.4, -0.9, 1.0, 20)
		tuft(1.6, 0.4, 0.8, 75)

		------------------------------------------------------------ root crown
		B:block(R, v(1.1, 0.45, 0.66), cf(0, 0.3, 0, 0, 10, 0), STEM_DK)
		B:block(R, v(0.66, 0.44, 1.1), cf(0, 0.3, 0, 0, 10, 0), STEM_DK)
		B:block(R, v(0.78, 0.47, 0.78), cf(0, 0.3, 0, 0, 55, 0), STEM)
		B:block(R, v(0.7, 0.35, 0.7), cf(0.05, 0.65, 0, 0, 30, 0), STEM)
		B:block(R, v(0.5, 0.36, 0.5), cf(0.05, 0.65, 0, 0, 75, 0), STEM_LT)
		-- stubby roots flaring into the soil
		for _, a in { 40, 150, 260 } do
			local d = dir(a)
			B:bar(R, v(0, 0.35, 0) + d * 0.3, d * 0.95 + v(0, 0.08, 0), 0.26, 0.22, STEM_DK)
		end

		------------------------------------------------------------ branches
		local function knuckle(p, w, col)
			B:block(R, v(w + 0.07, 0.2, w + 0.07), CFrame.new(p) * ang(0, 45, 0), col)
		end
		local nth = 0
		local function thorn(p, d)
			nth += 1
			B:bar(R, p, p + d * 0.42, 0.15, 0.15, (nth % 3 == 0) and THORN_DK or THORN)
		end

		-- { yaw, p1 r, p1 h, p2 r, p2 h, tip r, tip h, side }
		local br = {
			{ 15, 0.45, 1.5, 0.75, 2.6, 1.25, 3.5, 1 },
			{ 95, 0.55, 1.1, 1.2, 1.9, 1.85, 2.5, -1 },
			{ 165, 0.5, 1.3, 0.95, 2.3, 1.55, 3.0, 1 },
			{ 240, 0.6, 1.0, 1.3, 1.6, 1.9, 2.1, -1 },
			{ 305, 0.45, 1.4, 0.9, 2.4, 1.3, 3.1, 1 },
		}
		for i, b in br do
			local d, side = dir(b[1]), dir(b[1] + 90) * b[8]
			local p0 = v(0, 0.75, 0)
			local p1 = d * b[2] + v(0, b[3], 0) + side * 0.25
			local p2 = d * b[4] + v(0, b[5], 0) - side * 0.2
			local p3 = d * b[6] + v(0, b[7], 0) + side * 0.15
			local tipHook = p3 + d * 0.4 - side * 0.3 + v(0, 0.2, 0)
			local pts = { p0, p1, p2, p3 }
			local ws = { 0.34, 0.26, 0.2 }
			for k = 1, 3 do
				local a, c = pts[k], pts[k + 1]
				local u = (c - a).Unit
				B:bar(R, a - u * 0.06, c + u * 0.06, ws[k], ws[k], (k % 2 == 1) and STEM or STEM_DK)
			end
			knuckle(p1, 0.26, STEM_LT)
			knuckle(p2, 0.2, STEM_LT)
			B:bar(R, p3, tipHook, 0.15, 0.15, STEM_LT)
			B:block(R, v(0.14, 0.14, 0.14), CFrame.new(tipHook), TWIG_LT)
			-- pale grey side twig off the first kink
			local tw = p1 + d * 0.6 - side * 0.6 + v(0, 0.7, 0)
			B:bar(R, p1, tw, 0.17, 0.17, TWIG)
			-- cream thorns sticking out sideways
			thorn(p0:Lerp(p1, 0.6), (side + v(0, 0.3, 0)).Unit)
			thorn(p1:Lerp(p2, 0.5), (-side + v(0, 0.3, 0)).Unit)
			thorn(p2:Lerp(p3, 0.55), (side + d * 0.3 + v(0, 0.35, 0)).Unit)
		end

		------------------------------------------------------------ dry leaves + husks
		local function leaf(p, yaw, pitch, col)
			local F = CFrame.new(p) * ang(0, yaw, 0) * ang(pitch, 0, 0)
			B:block(R, v(0.45, 0.1, 0.7), F * CFrame.new(0, 0, -0.3), col)
			B:block(R, v(0.12, 0.14, 0.5), F * CFrame.new(0, 0.03, -0.28), LEAF_DK)
		end
		leaf(v(0.55, 1.75, -0.3), 40, -30, LEAF_DRY)
		leaf(v(-0.6, 1.3, 0.5), 200, -20, LEAF_DRY)
		leaf(v(-0.9, 0.17, -0.5), 110, 0, LEAF_DRY) -- fallen leaf on the soil

		local function husk(p)
			B:block(R, v(0.28, 0.28, 0.28), CFrame.new(p + v(0, -0.12, 0)) * ang(0, 45, 0), BERRY_DK)
			B:block(R, v(0.17, 0.1, 0.17), CFrame.new(p + v(0, 0.06, 0)), BERRY)
		end
		husk(dir(95) * 1.25 + v(0, 1.75, 0))
		husk(dir(305) * 0.95 + v(0.1, 2.15, 0))
		husk(dir(165) * 1.0 + v(0, 2.05, 0))
	end,
}
