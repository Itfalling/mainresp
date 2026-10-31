--!nocheck
-- Basalt Spire (Bramble Badlands scenery, big copy-paste filler).
-- A tall charcoal rock spire seen from far across the badlands:
-- * a stepped core that narrows and drifts as it rises (each tier two crossed
--   slabs + a square turned 45°, like the badlands boulders), dark at the
--   foot and lighter toward the crooked tip, with ash dusting on the ledges
-- * rust-red strata bands wrapping it at three heights, slightly proud of the
--   rock so they read as rings from a distance
-- * a cluster of basalt columns of different heights hugging the base, light
--   flat tops, plus a smaller leaning side pinnacle
-- * two tiny glowing lava seams set in dark cracks on the columns
-- * footing: flat rust earth, charcoal plates, scree chunks, ash, dry grass
-- Scenery filler: anchored, weld-free, no scripts, no effects, no motion.
return {
	DisplayName = "Basalt Spire",
	Rarity = "Scenery",
	Filler = true,
	Element = "Bramble Badlands",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Bramble Badlands) ----------------------------------------
		local RK_XD, RK_DK, RK, RK_LT, RK_HI = "#241e22", "#3a3236", "#4a4044", "#625758", "#776a68"
		local RUST_DK, RUST, RUST_LT = "#7a3524", "#94452c", "#b05a36"
		local ASH_DK, ASH, ASH_LT = "#6c6662", "#88827c", "#a7a19a"
		local GRASS, GRASS_DK, GRASS_LT = "#9a8a4a", "#76693a", "#b3a35c"
		local LAVA, LAVA_Y = "#ff7a1a", "#ffb43a"
		local NEON = { mat = "Neon" }

		local seed = 90127
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end

		-- rounded tier: two crossed slabs + a square turned 45° (y0 = bottom)
		local function tier(x, z, y0, s, h, yaw, col, col45)
			local c = cf(x, y0 + h / 2, z, 0, yaw, 0)
			B:block(R, v(s, h, s * 0.62), c, col)
			B:block(R, v(s * 0.62, h - 0.02, s), c, col)
			B:block(R, v(s * 0.72, h + 0.02, s * 0.72), c * ang(0, 45, 0), col45 or col)
		end

		------------------------------------------------------------------
		-- FOOTING (flat, under Y = 0.45)
		------------------------------------------------------------------
		B:block(R, v(13.0, 0.12, 7.6), cf(0, 0.06, 0, 0, 15, 0), RUST_DK)
		B:block(R, v(7.6, 0.13, 13.0), cf(0, 0.065, 0, 0, 15, 0), RUST_DK)
		B:block(R, v(10.4, 0.14, 10.4), cf(0, 0.07, 0, 0, 60, 0), RUST)
		local plates = {
			{ 4.8, -1.6, 2.6, 2.2, 20, RK }, { -4.6, 1.4, 2.8, 2.0, -12, RK_DK }, { 1.6, 4.9, 2.4, 2.0, 8, RK_LT },
			{ -1.8, -5.0, 2.6, 1.8, -20, RK }, { 4.0, 3.6, 1.8, 1.6, 35, ASH_DK }, { -4.2, -3.4, 2.0, 1.6, 15, RK_LT },
		}
		for _, p in plates do
			local h = 0.26 + jit(0.04)
			B:block(R, v(p[3], h, p[4]), cf(p[1], 0.14 + h / 2, p[2], 0, p[5], 0), p[6])
		end
		-- scree chunks tumbling off the base
		for _, p in { { 5.6, 0.6, 1.1, RK }, { -5.8, -1.2, 1.0, RK_DK }, { 2.4, -5.6, 0.9, RK_LT }, { -2.4, 5.6, 0.8, RUST }, { 6.0, -3.6, 0.7, ASH_DK }, { -5.0, 4.4, 0.7, RK } } do
			B:block(R, v(p[3] * 1.3, p[3] * 0.75, p[3]), cf(p[1], p[3] * 0.38, p[2], 0, jit(40), 0), p[4])
			B:block(R, v(p[3] * 0.7, p[3] * 0.35, p[3] * 0.6), cf(p[1] - 0.1, p[3] * 0.85, p[2], 0, jit(40), 0), RK_HI)
		end
		-- ash drifts
		for _, a in { { 3.6, -3.8, 1.6, 20 }, { -3.6, 3.4, 1.4, -30 }, { -5.4, -4.6, 1.1, 50 } } do
			B:block(R, v(a[3], 0.14, a[3] * 0.6), cf(a[1], 0.45, a[2], 0, a[4], 0), ASH)
			B:block(R, v(a[3] * 0.55, 0.12, a[3] * 0.4), cf(a[1] + 0.1, 0.55, a[2], 0, a[4] + 35, 0), ASH_LT)
		end
		local function tuft(x, z, s, yaw)
			for k = 0, 2 do
				local h = (0.9 + 0.25 * k) * s
				B:block(R, v(0.24, h, 0.24), CFrame.new(x, 0.3 + h / 2, z) * ang(0, yaw + k * 120, 0) * ang(28, 0, 0) * CFrame.new(0, 0, -0.15), ({ GRASS, GRASS_DK, GRASS_LT })[k + 1])
			end
		end
		tuft(5.4, 2.4, 1.2, 10)
		tuft(-5.6, 0.2, 1.1, 70)
		tuft(0.4, -6.0, 1.1, 30)
		tuft(-1.2, 5.8, 1.0, 50)

		------------------------------------------------------------------
		-- MAIN SPIRE CORE (stepped, narrowing, drifting)
		------------------------------------------------------------------
		-- {y0, h, size, x, z, colour, 45 colour}
		local TIERS = {
			{ 0.1, 2.2, 6.8, 0.0, 0.0, RK_DK, RK_XD },
			{ 2.3, 2.0, 6.0, 0.2, 0.1, RK, RK_DK },
			{ 4.3, 1.9, 5.3, 0.45, 0.0, RK_DK, RK },
			{ 6.2, 1.8, 4.7, 0.6, -0.15, RK, RK_LT },
			{ 8.0, 1.8, 4.1, 0.45, -0.3, RK_LT, RK },
			{ 9.8, 1.7, 3.6, 0.15, -0.35, RK, RK_LT },
			{ 11.5, 1.7, 3.1, -0.2, -0.25, RK_LT, RK },
			{ 13.2, 1.6, 2.7, -0.4, 0.0, RK, RK_LT },
			{ 14.8, 1.5, 2.3, -0.3, 0.25, RK_LT, RK_HI },
			{ 16.3, 1.3, 1.9, 0.0, 0.4, RK_HI, RK_LT },
			{ 17.6, 1.1, 1.4, 0.3, 0.45, RK_LT, RK_HI },
		}
		for i, t in TIERS do
			tier(t[4], t[5], t[1], t[3], t[2] + 0.06, i * 23, t[6], t[7])
		end
		-- crooked tip
		B:block(R, v(1.0, 1.2, 0.9), cf(0.5, 19.2, 0.4, 0, 20, 8), RK_HI)
		B:block(R, v(0.6, 0.8, 0.6), cf(0.75, 20.1, 0.35, 0, 50, 14), RK_LT)

		-- rust strata bands (slightly proud of the rock)
		for _, b in { { 5.0, 3 }, { 10.4, 6 }, { 14.0, 8 } } do
			local t = TIERS[b[2]]
			local s = t[3] + 0.35
			local c = cf(t[4], b[1], t[5], 0, b[2] * 23, 0)
			B:block(R, v(s, 0.55, s * 0.62), c, RUST)
			B:block(R, v(s * 0.62, 0.53, s), c, RUST_DK)
			B:block(R, v(s * 0.72, 0.57, s * 0.72), c * ang(0, 45, 0), RUST_LT)
		end
		-- ash dusting on the step ledges (lighter on top)
		for i = 2, #TIERS - 1, 2 do
			local t = TIERS[i]
			local a = rad(i * 67)
			local r = t[3] * 0.42
			B:block(R, v(1.1, 0.14, 0.8), cf(t[4] + math.sin(a) * r, t[1] + 0.02, t[5] - math.cos(a) * r, 0, i * 40, 0), (i % 4 == 0) and ASH_LT or ASH)
		end
		-- jutting ledge chunks breaking the outline
		local ledges = {
			{ 3.2, 3.0, -0.8, 1.6, 1.0, 1.4, 20, RK },
			{ -2.6, 7.4, 1.0, 1.4, 0.9, 1.6, -15, RK_LT },
			{ 1.6, 11.2, 1.8, 1.2, 0.8, 1.2, 30, RK },
			{ -1.9, 13.6, -1.0, 1.0, 0.8, 1.1, 10, RK_LT },
			{ 2.7, 7.0, 1.5, 1.2, 1.2, 1.2, 45, RK_DK },
		}
		for _, l in ledges do
			B:block(R, v(l[4], l[5], l[6]), cf(l[1], l[2], l[3], 0, l[7], 0), l[8])
			B:block(R, v(l[4] * 0.7, 0.14, l[6] * 0.7), cf(l[1], l[2] + l[5] / 2 + 0.05, l[3], 0, l[7] + 20, 0), ASH)
		end

		------------------------------------------------------------------
		-- BASALT COLUMNS hugging the base
		------------------------------------------------------------------
		-- {x, z, height, width, yaw, colour}
		local COLS = {
			{ 3.1, -2.2, 6.6, 1.9, 15, RK },
			{ 1.0, -3.4, 4.6, 1.8, 40, RK_DK },
			{ -1.6, -3.1, 7.8, 2.0, 5, RK_LT },
			{ -3.4, -1.0, 5.4, 1.8, 30, RK },
			{ -3.0, 1.8, 3.8, 1.7, 55, RK_DK },
			{ 3.5, 1.2, 4.2, 1.8, 25, RK_LT },
			{ 0.8, 3.4, 5.8, 1.9, 10, RK },
			{ 4.4, -0.6, 2.8, 1.5, 60, RK_DK },
			{ -1.4, 3.6, 2.6, 1.5, 35, RK_LT },
		}
		local colFace = {}
		for i, c in COLS do
			local h, w = c[3], c[4]
			local base = cf(c[1], 0.1 + h / 2, c[2], 0, c[5], 0)
			B:block(R, v(w, h, w), base, c[6])
			-- chamfered corners (square turned 45°, slightly darker)
			B:block(R, v(w * 1.12, h - 0.25, w * 1.12) * v(0.82, 1, 0.82), base * ang(0, 45, 0), (c[6] == RK_LT) and RK or RK_DK)
			-- light flat top
			B:block(R, v(w * 0.92, 0.2, w * 0.92), cf(c[1], 0.1 + h + 0.08, c[2], 0, c[5], 0), (i % 2 == 0) and ASH or RK_HI)
			colFace[i] = base
		end
		-- slimmer basalt columns climbing the core (columnar jointing higher up)
		for i, c in {
			{ 2.0, -1.2, 5.6, 6.8, 1.4, 20, RK_LT },
			{ -1.7, -1.3, 7.2, 6.2, 1.3, 40, RK },
			{ 0.5, 1.9, 8.2, 6.4, 1.3, 10, RK_DK },
			{ -1.4, 1.3, 5.2, 5.0, 1.25, 30, RK_LT },
		} do
			local h, w = c[4], c[5]
			local base = cf(c[1], c[3] + h / 2, c[2], 0, c[6], 0)
			B:block(R, v(w, h, w), base, c[7])
			B:block(R, v(w * 0.92, h - 0.2, w * 0.92), base * ang(0, 45, 0), (c[7] == RK_LT) and RK or RK_DK)
			B:block(R, v(w * 0.9, 0.18, w * 0.9), cf(c[1], c[3] + h + 0.07, c[2], 0, c[6], 0), (i % 2 == 0) and ASH or RK_HI)
		end

		-- rust band crossing two columns (the stratum continues outside)
		B:block(R, v(2.2, 0.45, 2.2), cf(3.1, 3.6, -2.2, 0, 15, 0), RUST)
		B:block(R, v(2.3, 0.45, 2.3), cf(-1.6, 3.4, -3.1, 0, 5, 0), RUST_LT)
		B:block(R, v(2.1, 0.45, 2.1), cf(0.8, 3.5, 3.4, 0, 10, 0), RUST)

		-- two tiny lava seams in dark cracks on the front columns
		local function seam(i, y0, y1, dx)
			local c = COLS[i]
			local F = colFace[i]
			local zf = -(c[4] / 2) - 0.02
			local a = F * CFrame.new(dx, y0 - (0.1 + c[3] / 2), zf)
			local b = F * CFrame.new(dx + 0.25, y1 - (0.1 + c[3] / 2), zf)
			local mid = F * CFrame.new(dx + 0.12, (y0 + y1) / 2 - (0.1 + c[3] / 2), zf)
			B:bar(R, a.Position, mid.Position, 0.5, 0.12, RK_XD, { up = F.LookVector })
			B:bar(R, mid.Position, b.Position, 0.5, 0.12, RK_XD, { up = F.LookVector })
			local f = F.LookVector * 0.07
			B:bar(R, a.Position + f, b.Position + f, 0.2, 0.1, LAVA, { mat = "Neon", up = F.LookVector })
		end
		seam(3, 1.3, 3.2, 0.5)
		seam(1, 0.8, 2.6, -0.62)

		------------------------------------------------------------------
		-- SIDE PINNACLE (smaller, leaning out back-left)
		------------------------------------------------------------------
		local px, pz = -3.6, 2.6
		local PT = {
			{ 0.1, 1.6, 3.0, RK_DK, RK },
			{ 1.7, 1.5, 2.5, RK, RK_LT },
			{ 3.2, 1.4, 2.1, RK_LT, RK },
			{ 4.6, 1.3, 1.7, RK, RK_LT },
			{ 5.9, 1.2, 1.3, RK_LT, RK_HI },
		}
		for i, t in PT do
			tier(px - (i - 1) * 0.28, pz + (i - 1) * 0.22, t[1], t[3], t[2] + 0.05, i * 31, t[4], t[5])
		end
		B:block(R, v(1.6, 0.4, 1.6), cf(px - 0.55, 3.3, pz + 0.45, 0, 20, 0), RUST)
		B:block(R, v(0.8, 0.9, 0.7), cf(px - 1.3, 7.4, pz + 1.1, 0, 30, 10), RK_HI)
	end,
}
