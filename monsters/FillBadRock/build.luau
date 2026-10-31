--!nocheck
-- Lava-Crack Rock (Bramble Badlands filler).
-- A clustered charcoal boulder in the crop-mound style:
-- * main boulder: three rounded tiers (two crossed slabs + a square turned
--   45°) that shrink and drift off-centre, dark at the foot, lighter at the
--   top, with stepped ledge chunks round the base, a rust stratum band on
--   one flank and grey ash dusting the top
-- * a smaller two-tier boulder leaning against it and a loose stone
-- * one thin glowing lava crack zig-zagging down the front, set in a darker
--   recessed crack line
-- * footing: flat rust-earth + ash patch, pebbles, dry olive grass tufts,
--   a small bone chip
-- Filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Lava-Crack Rock",
	Rarity = "Filler",
	Filler = true,
	Element = "Bramble Badlands",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		-- palette (Bramble Badlands crops)
		local RK_XD = "#2a2326"
		local ROCK_DK, ROCK, ROCK_LT, ROCK_HI = "#352d2a", "#463c38", "#5e524c", "#74685f"
		local RUST_DK, RUST, RUST_LT = "#6e2e1f", "#8c3e28", "#a65334"
		local ASH_DK, ASH, ASH_LT = "#77706a", "#9b948c", "#bfb8ae"
		local LAVA, LAVA_HOT = "#ff5a14", "#ffa431"
		local GRASS, GRASS_DK, GRASS_LT = "#9a8a4a", "#76693a", "#b3a35c"
		local NEON = { mat = "Neon" }

		-- rounded tier: two crossed slabs + a square turned 45° (y0 = bottom)
		local function tier(x, z, y0, s, h, yaw, col, col45)
			local c = cf(x, y0 + h / 2, z, 0, yaw, 0)
			B:block(R, v(s, h, s * 0.6), c, col)
			B:block(R, v(s * 0.6, h - 0.02, s), c, col)
			B:block(R, v(s * 0.7, h + 0.02, s * 0.7), c * ang(0, 45, 0), col45 or col)
		end

		------------------------------------------------------------ footing
		local function patch(x, z, s, h, yaw, col, col2)
			B:block(R, v(s, h, s * 0.56), cf(x, h / 2, z, 0, yaw, 0), col)
			B:block(R, v(s * 0.56, h - 0.01, s), cf(x, h / 2, z, 0, yaw, 0), col)
			B:block(R, v(s * 0.68, h + 0.02, s * 0.68), cf(x, (h + 0.02) / 2, z, 0, yaw + 45, 0), col2 or col)
		end
		patch(0.1, 0.1, 4.6, 0.12, 12, RUST_DK, RUST)
		patch(-1.6, -1.3, 1.6, 0.16, -15, ASH_DK, ASH)

		local function pebble(x, z, s, yaw, col, top)
			B:block(R, v(0.8 * s, 0.45 * s, 0.7 * s), cf(x, 0.22 * s, z, 0, yaw, 0), col)
			B:block(R, v(0.5 * s, 0.25 * s, 0.45 * s), cf(x - 0.05 * s, 0.55 * s, z, 0, yaw + 35, 0), top)
		end
		pebble(2.3, -1.2, 0.8, 30, ROCK, ROCK_LT)
		pebble(-2.4, 0.9, 0.7, -25, ROCK_DK, ASH_DK)
		pebble(0.4, 2.3, 0.55, 60, RUST, RUST_LT)

		local function tuft(x, z, s, yaw)
			for k = 0, 2 do
				local h = (0.5 + 0.15 * k) * s
				B:block(R, v(0.16, h, 0.16), CFrame.new(x, 0.12 + h / 2, z) * ang(0, yaw + k * 120, 0) * ang(34, 0, 0) * CFrame.new(0, 0, -0.12), ({ GRASS, GRASS_DK, GRASS_LT })[k + 1])
			end
		end
		tuft(-2.1, -0.4, 1.0, 15)
		tuft(1.6, 1.9, 0.9, 80)
		tuft(2.5, 0.4, 0.75, 40)

		------------------------------------------------------------ main boulder
		tier(0, 0.1, 0.05, 3.2, 1.0, 10, ROCK, ROCK_DK)
		tier(-0.2, 0.25, 1.0, 2.5, 0.9, 25, ROCK_LT, ROCK)
		tier(-0.35, 0.4, 1.85, 1.6, 0.6, 5, ROCK_HI, ROCK_LT)
		-- ash dusting on top
		B:block(R, v(0.9, 0.14, 0.8), cf(-0.4, 2.48, 0.45, 0, 20, 0), ASH)
		B:block(R, v(0.5, 0.16, 0.45), cf(-0.55, 2.52, 0.6, 0, 50, 0), ASH_LT)
		B:block(R, v(0.6, 0.12, 0.5), cf(-1.15, 1.92, 0.75, 0, 10, 0), ASH)
		B:block(R, v(0.7, 0.12, 0.6), cf(0.65, 1.92, -0.35, 0, 30, 0), ASH_DK)

		-- stepped ledge chunks round the base (alternating tones)
		local ledges = {
			{ 1.55, -0.3, 1.0, 0.75, 0.8, 30, ROCK },
			{ 0.9, 1.35, 1.1, 0.6, 0.8, -15, ROCK_DK },
			{ -1.45, 0.75, 0.9, 0.9, 0.9, 20, ROCK_LT },
			{ -0.85, -1.4, 1.0, 0.55, 0.7, 5, ROCK_DK },
		}
		for _, l in ledges do
			B:block(R, v(l[3], l[4], l[5]), cf(l[1], 0.05 + l[4] / 2, l[2], 0, l[6], 0), l[7])
		end

		-- rust stratum band on the back-right flank
		B:block(R, v(1.6, 0.22, 0.5), cf(0.75, 0.62, 1.05, 0, 35, 0), RUST)
		B:block(R, v(1.0, 0.2, 0.45), cf(1.25, 0.45, 0.5, 0, 70, 0), RUST_LT)
		B:block(R, v(1.1, 0.16, 0.4), cf(0.2, 1.35, 1.05, 0, 25, 0), RUST_DK)

		------------------------------------------------------------ side boulder
		tier(1.65, -0.85, 0.05, 1.4, 0.7, 40, ROCK_DK, ROCK)
		tier(1.7, -0.8, 0.7, 0.9, 0.5, 15, ROCK, ROCK_LT)
		B:block(R, v(0.45, 0.12, 0.4), cf(1.75, 1.25, -0.75, 0, 30, 0), ASH)
		-- loose stone
		B:block(R, v(0.7, 0.5, 0.6), cf(-1.75, 0.3, -0.6, 0, -30, 0), ROCK)
		B:block(R, v(0.45, 0.25, 0.4), cf(-1.8, 0.66, -0.6, 0, 0, 0), ROCK_HI)

		-- a little bone chip on the ash
		B:bar(R, v(-1.95, 0.24, -1.55), v(-1.25, 0.24, -1.85), 0.22, 0.2, "#efe2c0")
		B:block(R, v(0.3, 0.28, 0.3), cf(-1.95, 0.25, -1.55, 0, 20, 0), "#fbf3dc")
		B:block(R, v(0.28, 0.26, 0.28), cf(-1.25, 0.24, -1.85, 0, 40, 0), "#cdb98e")

		------------------------------------------------------------ lava crack
		-- a flat-faced cliff chunk at the front carries the crack: a dark
		-- recessed line with one thin glowing seam inside it
		B:block(R, v(1.5, 1.3, 0.7), cf(0.35, 0.7, -1.35), ROCK)
		B:block(R, v(1.1, 0.3, 0.6), cf(0.25, 1.5, -1.25, 0, 10, 0), ROCK_LT)
		local Z = -1.72
		local pts = { v(0.5, 1.15, Z), v(0.28, 0.78, Z), v(0.48, 0.42, Z) }
		for i = 1, #pts - 1 do
			B:bar(R, pts[i], pts[i + 1], 0.24, 0.24, RK_XD)
		end
		local f = v(0, 0, -0.1)
		B:bar(R, pts[1] + f, pts[2] + f, 0.1, 0.1, LAVA_HOT, NEON)
		B:bar(R, pts[2] + f, pts[3] + f, 0.1, 0.1, LAVA, NEON)
	end,
}
