--!nocheck
-- Party Balloon Cluster (Bunny Meadow scenery, ~18 studs). A big bouquet of
-- chunky block balloons in the Bunny Meadow party colours, tied with cream
-- strings to a stepped gold balloon weight.
-- * each balloon: a stepped rounded body (plus-shaped tiers: dark bottom, main
--   middle, light top cap), a pale shine patch on the front-upper-left and a
--   knotted tie; every balloon leans along its string so the bouquet fans out
-- * strings: two slightly kinked segments each, all meeting at the weight loop
-- * weight: dark foot, gold octagon body with a purple ribbon band and a pink
--   bow, light top, gold loop; one tiny pink neon heart gem is the only glow
-- * grounding: a small red carpet square, confetti, a curled streamer, grass tufts
-- Scenery filler: anchored, weld-free, no scripts, no effects.
return {
	DisplayName = "Party Balloon Cluster",
	Rarity = "Scenery",
	Filler = true,
	Element = "Bunny Meadow",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local R = "Root"
		-- Bunny Meadow palette (DecorBunnySpeaker / DecorBunnySign / DecorBunnyRope)
		local GOLD_LT, GOLD, GOLD_DK = "#ffe27a", "#ffc62e", "#d9961a"
		local PURP_DK, PURP, PURP_LT = "#4a1aa8", "#7e3cf0", "#a874ff"
		local PINK_DK, PINK, PINK_LT = "#c41f86", "#ff3fb4", "#ff86d4"
		local CYAN_DK, CYAN, CYAN_LT = "#0e94c0", "#16c8f0", "#72e6ff"
		local CARROT_DK, CARROT, CARROT_LT = "#d6600c", "#ff8a1c", "#ffab4a"
		local VELVET_DK, VELVET, VELVET_LT = "#860c20", "#c0162f", "#e2394f"
		local CREAM, WHITE = "#fff4c8", "#ffffff"
		local N_PINK = "#ff5cc8"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"

		local PAL = {
			pink = { PINK_DK, PINK, PINK_LT },
			purple = { PURP_DK, PURP, PURP_LT },
			cyan = { CYAN_DK, CYAN, CYAN_LT },
			gold = { GOLD_DK, GOLD, GOLD_LT },
			orange = { CARROT_DK, CARROT, CARROT_LT },
			red = { VELVET_DK, VELVET, VELVET_LT },
		}

		-- frame with local +Y along `up`, local -Z facing the front (-Z) as much as possible
		local function frame(pos, up)
			up = up.Unit
			local back = (v(0, 0, 1) - up * up:Dot(v(0, 0, 1))).Unit
			local right = up:Cross(back)
			return CFrame.new(pos.X, pos.Y, pos.Z, right.X, up.X, back.X, right.Y, up.Y, back.Y, right.Z, up.Z, back.Z)
		end

		------------------------------------------------------------ weight
		local K = 1.35 -- weight scale
		local function wb(sx, sy, sz, x, y, z, col, ry, rz)
			return B:block(R, v(sx * K, sy * K, sz * K), cf(x * K, y * K, z * K, 0, ry or 0, rz or 0), col)
		end
		local ANCHOR = v(0, 3.05 * K, 0)
		wb(2.8, 0.5, 2.8, 0, 0.25, 0, GOLD_DK)
		wb(2.5, 1.5, 1.8, 0, 1.2, 0, GOLD)
		wb(1.8, 1.5, 2.5, 0, 1.2, 0, GOLD)
		wb(2.6, 0.4, 1.9, 0, 1.15, 0, PURP)
		wb(1.9, 0.4, 2.6, 0, 1.15, 0, PURP)
		wb(1.7, 0.4, 1.7, 0, 2.15, 0, GOLD_LT)
		wb(1.0, 0.25, 1.0, 0, 2.45, 0, GOLD, 45)
		-- loop on top
		for _, s in { -1, 1 } do
			wb(0.25, 0.65, 0.25, s * 0.38, 2.85, 0, GOLD_DK)
		end
		wb(1.05, 0.25, 0.25, 0, 3.15, 0, GOLD_DK)
		-- pink bow on the ribbon + neon heart gem
		wb(0.45, 0.45, 0.3, 0, 1.15, -1.37, PINK)
		for _, s in { -1, 1 } do
			wb(0.65, 0.5, 0.25, s * 0.45, 1.2, -1.35, PINK_LT, 0, s * 15)
		end
		B:block(R, v(0.4, 0.4, 0.12), cf(0, 1.68 * K, -1.25 * K - 0.07, 0, 0, 45), N_PINK, { mat = "Neon", name = "Heart" })
		-- dark side seams + small gold studs on the corners of the foot
		for _, s in { -1, 1 } do
			wb(0.1, 0.9, 0.5, s * 1.27, 1.6, 0, GOLD_DK)
		end
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			wb(0.45, 0.2, 0.45, c[1] * 1.15, 0.58, c[2] * 1.15, GOLD_LT)
		end

		------------------------------------------------------------ balloons
		local function tier(c, y0, y1, w, col)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(R, v(w, h, w * 0.72), c * CFrame.new(0, y, 0), col)
			B:block(R, v(w * 0.72, h, w), c * CFrame.new(0, y, 0), col)
		end
		local function balloon(knot, w, h, pal, kink)
			local dir = (knot - ANCHOR)
			local up = (dir.Unit + v(0, 1.6, 0)).Unit
			local c = frame(knot, up)
			local dk, mn, lt = pal[1], pal[2], pal[3]
			-- knot + tie
			B:block(R, v(0.42, 0.42, 0.42), c * CFrame.new(0, 0.05, 0) * CFrame.Angles(0, math.rad(45), 0), dk)
			B:block(R, v(0.7, 0.22, 0.7), c * CFrame.new(0, 0.32, 0), mn)
			-- stepped body
			local b = 0.4
			tier(c, b, b + h * 0.15, w * 0.45, dk)
			tier(c, b + h * 0.13, b + h * 0.36, w * 0.86, dk)
			tier(c, b + h * 0.34, b + h * 0.8, w, mn)
			tier(c, b + h * 0.78, b + h * 0.95, w * 0.78, mn)
			B:block(R, v(w * 0.5, h * 0.08, w * 0.5), c * CFrame.new(0, b + h * 0.97, 0), lt)
			B:block(R, v(w * 0.62, 0.14, w * 0.45), c * CFrame.new(0, b + h * 0.8 + 0.04, 0), lt)
			-- shine on the front-upper-left
			B:block(R, v(w * 0.16, h * 0.26, 0.14), c * CFrame.new(-w * 0.2, b + h * 0.6, -w / 2 - 0.05), lt)
			B:block(R, v(w * 0.1, h * 0.08, 0.14), c * CFrame.new(-w * 0.2, b + h * 0.81, -w * 0.39 - 0.05), WHITE)
			-- string: two segments with a small kink
			local mid = ANCHOR + (knot - ANCHOR) * 0.5 + kink
			B:bar(R, ANCHOR + v(0, 0.1, 0), mid, 0.12, 0.12, CREAM)
			B:bar(R, mid, knot, 0.12, 0.12, CREAM)
		end
		balloon(v(0.2, 13.0, 0.4), 4.0, 4.9, PAL.pink, v(0.3, 0, 0.2))
		balloon(v(-3.0, 11.3, -0.6), 3.7, 4.4, PAL.cyan, v(-0.3, 0, -0.3))
		balloon(v(3.2, 11.6, -0.2), 3.8, 4.5, PAL.purple, v(0.35, 0, 0.1))
		balloon(v(-1.1, 9.4, -2.9), 3.4, 4.0, PAL.gold, v(-0.2, 0, -0.3))
		balloon(v(1.9, 9.0, 2.7), 3.4, 4.0, PAL.orange, v(0.3, 0, 0.2))
		balloon(v(-2.4, 9.6, 2.5), 3.3, 3.9, PAL.red, v(-0.3, 0, 0.2))
		balloon(v(1.9, 8.4, -2.8), 3.1, 3.7, PAL.pink, v(0.2, 0, -0.2))

		------------------------------------------------------------ grounding
		-- small red VIP carpet square under the weight (Gold Rope Post style)
		B:block(R, v(5.2, 0.1, 5.2), cf(0, 0.05, 0, 0, 8, 0), "#9c1028")
		B:block(R, v(4.8, 0.14, 4.8), cf(0, 0.07, 0, 0, 8, 0), "#d11a3a")
		B:block(R, v(4.2, 0.06, 0.25), cf(0, 0.15, 0, 0, 8, 0), GOLD)
		B:block(R, v(0.25, 0.06, 4.2), cf(0, 0.15, 0, 0, 8, 0), GOLD)
		local confetti = {
			{ 2.4, -2.2, PINK }, { -2.6, -1.6, CYAN }, { 1.0, 2.8, GOLD }, { -1.7, 2.6, PURP_LT },
			{ 3.1, 0.9, CARROT }, { -3.2, 0.6, PINK_LT }, { 0.4, -3.1, CYAN_LT }, { -0.9, -2.5, GOLD_LT },
		}
		for i, c in confetti do
			B:block(R, v(0.4, 0.08, 0.4), cf(c[1], 0.04, c[2], 0, i * 23, 0), c[3])
		end
		-- curled streamer on the ground
		B:block(R, v(1.2, 0.1, 0.25), cf(-2.4, 0.05, -3.0, 0, 20, 0), PINK)
		B:block(R, v(0.9, 0.1, 0.25), cf(-1.5, 0.05, -3.5, 0, -40, 0), PINK_LT)
		B:block(R, v(0.8, 0.1, 0.25), cf(-0.8, 0.05, -3.2, 0, 50, 0), PINK)
		local function tuft(x, z, h, ry)
			local b = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(ry), 0)
			B:block(R, v(0.4, h, 0.4), b * CFrame.new(0, h / 2, 0), GRASS)
			B:block(R, v(0.35, h * 0.75, 0.35), b * CFrame.new(0.32, h * 0.36, 0.05) * CFrame.Angles(0, 0, math.rad(-20)), GRASS_DK)
			B:block(R, v(0.35, h * 0.65, 0.35), b * CFrame.new(-0.3, h * 0.32, -0.05) * CFrame.Angles(0, 0, math.rad(22)), GRASS)
		end
		tuft(2.0, -1.9, 0.8, 20)
		tuft(-2.0, 1.8, 0.9, -40)
		tuft(2.3, 2.0, 0.7, 60)
	end,
}
