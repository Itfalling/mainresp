--!nocheck
-- VIP Rope Line (Bunny Meadow decoration, small/medium accent).
-- Three shiny gold stanchion posts on a short red-carpet runner, joined by two
-- sagging red velvet ropes with gold clips. The centre post carries a little
-- carrot-shaped "VIP" sign (pixel letters on an orange stepped carrot board
-- with green leaf tufts). Tiny party-neon caps on the outer posts.
-- Static prop: no motion.luau.
return {
	DisplayName = "VIP Rope Line",
	Rarity = "Decor",
	Element = "Bunny Meadow",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		local GOLD_LT, GOLD, GOLD_DK = "#ffe27a", "#ffc62e", "#d9961a"
		local VELVET, VELVET_DK = "#c0162f", "#860c20"
		local CARPET, CARPET_DK = "#d11a3a", "#9c1028"
		local CARROT, CARROT_DK, CARROT_LT = "#ff8a1c", "#d6600c", "#ffab4a"
		local LEAF, LEAF_DK = "#5fd645", "#349a2c"
		local PURP_DK = "#5b1fc4"
		local STONE, STONE_DK = "#8d8a9c", "#6c6a7c"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local N_PINK, N_CYAN = "#ff5cc8", "#4fe6ff"

		------------------------------------------------------------ footing
		local CZ = -0.6 -- carpet centre (posts stand on its back half)
		B:block(R, v(11.6, 0.2, 3.0), cf(0, 0.1, CZ), CARPET)
		for _, s in { -1, 1 } do
			B:block(R, v(11.8, 0.26, 0.3), cf(0, 0.13, CZ + s * 1.55), GOLD_DK)
		end
		-- darker carpet pile stripe down the middle
		B:block(R, v(11.0, 0.22, 0.5), cf(0, 0.11, CZ - 0.55), CARPET_DK)
		-- flat stones + tufts at the runner ends
		local stones = { { -6.6, -1.4, 1.4, 0 }, { -6.5, 0.4, 1.1, 20 }, { 6.7, -0.2, 1.5, -15 }, { 6.4, -1.8, 1.0, 30 } }
		for i, s in stones do
			B:block(R, v(s[3], 0.3, s[3] * 0.8), cf(s[1], 0.15, s[2], 0, s[4], 0), (i % 2 == 0) and STONE or STONE_DK)
		end
		local tufts = { { -6.9, 1.4 }, { 7.0, 1.0 }, { 6.0, -2.6 }, { -5.9, -2.5 } }
		for i, t in tufts do
			local h = 0.8 + (i % 2) * 0.4
			B:block(R, v(0.45, h, 0.45), cf(t[1], h / 2, t[2], 0, i * 27, 0), (i % 2 == 0) and GRASS or GRASS_DK)
			B:block(R, v(0.35, h * 0.6, 0.35), cf(t[1] + 0.4, h * 0.3, t[2] + 0.2, 0, i * 41, 0), GRASS_DK)
		end

		------------------------------------------------------------ posts
		local YB = 0.2
		local HOOK = YB + 3.15
		local XS = { -4.2, 0, 4.2 }
		local caps = { N_PINK, nil, N_CYAN }
		for i, x in XS do
			B:block(R, v(1.7, 0.35, 1.7), cf(x, YB + 0.175, 0), GOLD_DK)
			B:block(R, v(1.25, 0.3, 1.25), cf(x, YB + 0.5, 0, 0, 45, 0), GOLD)
			B:block(R, v(0.8, 0.25, 0.8), cf(x, YB + 0.75, 0), GOLD_LT)
			local top = (i == 2) and YB + 4.3 or YB + 3.6
			B:block(R, v(0.55, top - YB - 0.8, 0.55), cf(x, (YB + 0.8 + top) / 2, 0), GOLD)
			B:block(R, v(0.85, 0.3, 0.85), cf(x, HOOK, 0, 0, 45, 0), GOLD_DK)
			if i ~= 2 then
				B:block(R, v(1.0, 1.0, 1.0), cf(x, top + 0.35, 0, 0, 45, 0), GOLD)
				B:block(R, v(0.6, 0.45, 0.6), cf(x, top + 1.05, 0), GOLD_LT)
				B:gem(R, v(0.3, 0.3, 0.3), cf(x, top + 1.4, 0, 0, 45, 0), caps[i], { name = "Cap" .. i })
			end
		end

		------------------------------------------------------------ ropes
		local SAG = 1.0
		for i = 1, 2 do
			local x0, x1 = XS[i] + 0.45, XS[i + 1] - 0.45
			local pts = {}
			local N = 4
			for k = 0, N do
				local t = k / N
				pts[k] = v(x0 + (x1 - x0) * t, HOOK - SAG * 4 * t * (1 - t), -0.05)
			end
			for k = 0, N - 1 do
				B:bar(R, pts[k], pts[k + 1], 0.55, 0.55, VELVET)
			end
			for k = 1, N - 1 do
				B:block(R, v(0.62, 0.62, 0.62), CFrame.new(pts[k]) * ang(45, 0, 0), VELVET_DK)
			end
			-- gold clips at both ends
			for _, k in { 0, N } do
				B:block(R, v(0.55, 0.5, 0.7), CFrame.new(pts[k]), GOLD_DK)
				B:block(R, v(0.3, 0.3, 0.75), CFrame.new(pts[k] + v(0, 0.05, 0)), GOLD_LT)
			end
		end

		------------------------------------------------------------ VIP carrot sign
		-- screen coords: column -> viewer's right (= -X), the sign faces -Z.
		local PX = 0.36
		local SIGN_BOT = YB + 4.15
		local ROWS = { { 1, 9 }, { 0, 12 }, { 0, 14 }, { 0, 15 }, { 0, 14 }, { 0, 12 }, { 1, 9 } }
		local TOP = SIGN_BOT + #ROWS * PX
		local function sx(col) return -((col - 7.5) * PX) end
		local function sy(row) return TOP - (row + 0.5) * PX end
		local D = 0.5
		for r, span in ROWS do
			local row = r - 1
			local c0, c1 = span[1], span[2]
			local w = (c1 - c0 + 1) * PX
			B:block(R, v(w, PX + 0.02, D), cf((sx(c0) + sx(c1)) / 2, sy(row), 0), (row == 3) and CARROT_LT or CARROT)
		end
		-- carrot ridges near the tip
		local ridges = { { 1, 11.6 }, { 5, 11.6 }, { 2, 13.2 }, { 4, 13.2 }, { 3, 14.4 } }
		for _, rd in ridges do
			B:block(R, v(PX * 1.2, PX * 0.45, D + 0.08), cf(sx(rd[2]), sy(rd[1]) - PX * 0.1, 0), CARROT_DK)
		end
		-- gold mounting plate on the post
		B:block(R, v(1.1, 0.35, 0.9), cf(0, SIGN_BOT - 0.05, 0), GOLD_DK)
		-- leaves at the viewer's left (+X)
		local LX = sx(-0.5)
		local leaves = {
			-- angle (deg, 0 = straight out to the viewer's left, + = up), length, colour
			{ 0, 1.5, LEAF }, { 38, 1.3, LEAF_DK }, { -36, 1.2, LEAF_DK }, { 70, 1.0, LEAF },
		}
		for i, l in leaves do
			local a = math.rad(l[1])
			local base = v(LX - 0.15, sy(3), 0)
			local dir = v(math.cos(a), math.sin(a), 0)
			local mid = base + dir * (l[2] * 0.55)
			local tip = base + dir * l[2]
			B:bar(R, base, mid, 0.75, 0.6, l[3])
			B:bar(R, mid - dir * 0.1, tip, 0.5, 0.45, (l[3] == LEAF) and LEAF_DK or LEAF)
		end
		-- pixel letters V I P (3x5 each) on rows 1..5, cols 1..11
		local GLYPHS = {
			{ 1, { "X...X", "X...X", ".X.X.", ".X.X.", "..X.." } },
			{ 7, { "X", "X", "X", "X", "X" } },
			{ 9, { "XXX", "X.X", "XXX", "X..", "X.." } },
		}
		-- mirrored copy on the back so it also reads from behind
		local BACK = {
			{ 7, { "X...X", "X...X", ".X.X.", ".X.X.", "..X.." }, true },
			{ 5, { "X", "X", "X", "X", "X" }, true },
			{ 1, { "XXX", "X.X", "XXX", "..X", "..X" }, true },
		}
		for _, gl in BACK do
			table.insert(GLYPHS, gl)
		end
		for _, gl in GLYPHS do
			local col0, rows = gl[1], gl[2]
			local FZ = gl[3] and (D / 2 + 0.06) or (-D / 2 - 0.06)
			local W = #rows[1]
			for rr, line in rows do
				-- merge horizontal runs into single blocks
				local c = 1
				while c <= W do
					if line:sub(c, c) == "X" then
						local e = c
						while e < W and line:sub(e + 1, e + 1) == "X" do
							e += 1
						end
						local a, b = sx(col0 + c - 1), sx(col0 + e - 1)
						B:block(R, v((e - c + 1) * PX - 0.04, PX - 0.04, 0.16), cf((a + b) / 2, sy(rr), FZ), PURP_DK)
						c = e + 1
					else
						c += 1
					end
				end
			end
		end
		local star = B:block(R, v(0.35, 0.35, 0.35), cf(sx(15.6), sy(3), -0.2, 0, 0, 45), GOLD_LT)
		B:emitter(star, "sparkle", { name = "VipSparkle", color = { "#ffe27a", "#ff86d4" }, rate = 2, size = 0.3 })
	end,
}
