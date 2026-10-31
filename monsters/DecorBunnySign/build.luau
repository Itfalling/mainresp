--!nocheck
-- Neon Carrot Sign (Bunny Meadow decoration, HERO piece).
-- A big party billboard on two gold-banded purple legs over a stepped stage
-- plinth: a night-purple board in a gold marquee frame showing a chunky pixel
-- carrot (orange plastic pixels with ridge stripes and green leaf fronds),
-- traced by thin neon tubes like a real neon sign. A pixel sparkle twinkles
-- in the corner, a gold star tops the board and two little stage spotlights
-- on the plinth aim up at it. Static prop: no motion.luau.
return {
	DisplayName = "Neon Carrot Sign",
	Rarity = "Decor",
	Element = "Bunny Meadow",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		local STAGE, STAGE_LT = "#26222e", "#3a3546"
		local GOLD_LT, GOLD, GOLD_DK = "#ffe27a", "#ffc62e", "#d9961a"
		local PURP_DK, PURP, PURP_LT = "#4a1aa8", "#7e3cf0", "#a874ff"
		local BOARD, BOARD_LT = "#24104e", "#34196e"
		local CARROT, CARROT_DK = "#ff8a1c", "#d6600c"
		local LEAF, LEAF_DK = "#5fd645", "#349a2c"
		local CREAM = "#fff4c8"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local N_ORANGE, N_GREEN, N_YELLOW, N_PINK, N_CYAN = "#ffa040", "#8dff5a", "#fff36a", "#ff5cc8", "#4fe6ff"
		local CAN = "#26222e"

		------------------------------------------------------------ plinth
		B:block(R, v(11.4, 0.5, 5.2), cf(0, 0.25, 0), STAGE)
		B:block(R, v(10.0, 0.4, 4.0), cf(0, 0.7, 0), STAGE_LT)
		for _, s in { -1, 1 } do
			B:block(R, v(11.6, 0.3, 0.3), cf(0, 0.32, s * 2.65), GOLD_DK)
			B:block(R, v(0.3, 0.3, 5.4), cf(s * 5.75, 0.32, 0), GOLD_DK)
			B:block(R, v(10.2, 0.2, 0.25), cf(0, 0.85, s * 2.0), GOLD)
		end
		-- spotlights aimed up at the board
		for k, sx in { -1, 1 } do
			local x, z = sx * 3.3, -1.9
			B:block(R, v(1.0, 0.4, 1.0), cf(x, 1.1, z), CAN)
			local C = cf(x, 1.75, z) * ang(0, 180, 0) * ang(50, 0, 0)
			B:block(R, v(0.9, 0.9, 1.3), C, CAN)
			B:block(R, v(0.7, 0.7, 0.2), C * CFrame.new(0, 0, -0.68), (k == 1) and N_PINK or N_CYAN, { mat = "Neon", name = "Spot" .. k })
			B:block(R, v(1.1, 0.2, 0.3), C * CFrame.new(0, 0.5, -0.5), GOLD)
		end
		-- tufts + little flowers
		local tufts = { { -6.1, -2.4 }, { 6.0, 2.5 }, { 6.2, -1.2 }, { -6.0, 2.0 }, { 0.8, 2.9 }, { -1.5, -2.9 } }
		for i, t in tufts do
			local h = 0.8 + (i % 2) * 0.45
			B:block(R, v(0.45, h, 0.45), cf(t[1], h / 2, t[2], 0, i * 27, 0), (i % 2 == 0) and GRASS or GRASS_DK)
			B:block(R, v(0.35, h * 0.6, 0.35), cf(t[1] + 0.35, h * 0.3, t[2] + 0.25, 0, i * 41, 0), GRASS_DK)
		end
		local flowers = { { -6.3, -1.4, "#ff86d4" }, { 6.4, 1.4, "#fff36a" }, { 5.9, -2.6, "#ff86d4" } }
		for _, f in flowers do
			B:block(R, v(0.2, 0.9, 0.2), cf(f[1], 0.45, f[2]), GRASS_DK)
			B:block(R, v(0.55, 0.4, 0.55), cf(f[1], 1.0, f[2], 0, 45, 0), f[3])
			B:block(R, v(0.25, 0.25, 0.25), cf(f[1], 1.25, f[2]), GOLD_LT)
		end

		------------------------------------------------------------ legs
		local BW, BH, BD = 12.0, 12.6, 0.8
		local BOT = 5.8
		local CY = BOT + BH / 2
		for _, sx in { -1, 1 } do
			local x = sx * 3.8
			B:block(R, v(1.8, 0.4, 1.8), cf(x, 1.1, 0.6), GOLD_DK)
			B:block(R, v(1.2, 0.3, 1.2), cf(x, 1.45, 0.6, 0, 45, 0), GOLD)
			-- leg runs up behind the board as a strut
			B:block(R, v(1.1, BOT + BH - 1.4 - 1.3, 1.1), cf(x, (1.3 + BOT + BH - 1.4) / 2, 0.95), PURP_DK)
			for _, y in { 2.4, 4.6 } do
				B:block(R, v(1.3, 0.35, 1.3), cf(x, y, 0.95), GOLD)
			end
			B:block(R, v(1.3, 0.35, 1.3), cf(x, BOT + 0.3, 0.95), GOLD_DK)
		end
		-- X brace between the legs
		B:bar(R, v(-3.5, 1.9, 1.0), v(3.5, BOT - 0.4, 1.0), 0.45, 0.45, PURP)
		B:bar(R, v(3.5, 1.9, 1.05), v(-3.5, BOT - 0.4, 1.05), 0.45, 0.45, PURP)
		B:block(R, v(0.7, 0.7, 0.7), cf(0, (1.9 + BOT - 0.4) / 2, 1.05, 0, 0, 45), GOLD)

		------------------------------------------------------------ board + frame
		B:block(R, v(BW, BH, BD), cf(0, CY, 0), BOARD)
		B:block(R, v(BW - 2.2, BH - 2.2, 0.1), cf(0, CY, BD / 2 + 0.03), BOARD_LT) -- back panel
		local FW = 0.6
		local FZ = -0.05
		B:block(R, v(BW + 0.4, FW, BD + 0.3), cf(0, CY + BH / 2, FZ), GOLD)
		B:block(R, v(BW + 0.4, FW, BD + 0.3), cf(0, CY - BH / 2, FZ), GOLD)
		B:block(R, v(FW, BH - FW + 0.02, BD + 0.3), cf(BW / 2, CY, FZ), GOLD)
		B:block(R, v(FW, BH - FW + 0.02, BD + 0.3), cf(-BW / 2, CY, FZ), GOLD)
		for _, sx in { -1, 1 } do
			for _, sy in { -1, 1 } do
				B:block(R, v(1.0, 1.0, BD + 0.5), cf(sx * BW / 2, CY + sy * BH / 2, FZ), GOLD_DK)
			end
		end
		-- marquee bulbs along the frame front
		local front = -(BD + 0.3) / 2 + FZ
		local bulbs = {}
		local function bulb(x, y, i)
			local neon = (i % 2 == 0)
			local p = B:block(R, v(0.34, 0.34, 0.2), cf(x, y, front - 0.08), neon and N_YELLOW or CREAM, neon and { mat = "Neon", name = "Bulb" } or nil)
			table.insert(bulbs, p)
		end
		local bi = 0
		for k = -4, 4 do
			bi += 1
			bulb(k * 1.25, CY + BH / 2, bi)
			bulb(k * 1.25, CY - BH / 2, bi + 1)
		end
		for k = -4, 4 do
			bi += 1
			bulb(BW / 2, CY + k * 1.3, bi)
			bulb(-BW / 2, CY + k * 1.3, bi + 1)
		end

		------------------------------------------------------------ pixel carrot
		local GRID = {
			"......LL..LL...",
			".......LL.LL.LL",
			"........LLGGLL.",
			"........GGGLL..",
			"........OOOO...",
			".......OOOOOO..",
			"......OOOODOO..",
			".....DOOOOODO..",
			".....ODOOOOO...",
			"....OOOODOO....",
			"....OOOOOD.....",
			"...DOOOOO......",
			"...ODOOO.......",
			"..OOOOO........",
			"..OOO..........",
			".OO............",
		}
		local NC, NR = #GRID[1], #GRID
		local PX = 0.68
		local OX, OY = 0.0, 0.0 -- art offset on the board (screen space)
		local PZ = -BD / 2 - 0.15
		local PFRONT = -BD / 2 - 0.3
		local COL = { O = CARROT, D = CARROT_DK, L = LEAF, G = LEAF_DK }
		local function cell(r, c)
			if r < 1 or r > NR or c < 1 or c > NC then return "." end
			return GRID[r]:sub(c, c)
		end
		local function isLeaf(ch) return ch == "L" or ch == "G" end
		-- screen (column c, row r; edges at half steps) -> world x/y. Viewer's right = -X.
		local function wx(c) return -(OX + (c - (NC + 1) / 2) * PX) end
		local function wy(r) return CY + OY + ((NR + 1) / 2 - r) * PX end
		-- pixels: merge horizontal runs of one colour
		for r = 1, NR do
			local c = 1
			while c <= NC do
				local ch = cell(r, c)
				if ch ~= "." then
					local e = c
					while cell(r, e + 1) == ch do
						e += 1
					end
					B:block(R, v((e - c + 1) * PX + 0.02, PX + 0.02, 0.3), cf((wx(c) + wx(e)) / 2, wy(r), PZ), COL[ch])
					c = e + 1
				else
					c += 1
				end
			end
		end
		-- neon outline: edges where a filled cell meets empty space
		local T = 0.2
		local TZ = PFRONT + 0.02
		local function tubeKind(a, b) -- a = this cell, b = neighbour across the edge
			if a == "." or b ~= "." then return nil end
			return isLeaf(a) and "G" or "O"
		end
		local NEONC = { O = N_ORANGE, G = N_GREEN }
		local tubes = {}
		-- horizontal edges: between row r and r+1 (r = 0..NR)
		for r = 0, NR do
			local c = 1
			while c <= NC do
				local k = tubeKind(cell(r, c), cell(r + 1, c)) or tubeKind(cell(r + 1, c), cell(r, c))
				if k then
					local e = c
					while e < NC do
						local k2 = tubeKind(cell(r, e + 1), cell(r + 1, e + 1)) or tubeKind(cell(r + 1, e + 1), cell(r, e + 1))
						if k2 ~= k then break end
						e += 1
					end
					local x0, x1 = wx(c - 0.5), wx(e + 0.5)
					local p = B:block(R, v(math.abs(x1 - x0) + T, T, T), cf((x0 + x1) / 2, wy(r + 0.5), TZ), NEONC[k], { mat = "Neon", name = "Tube" })
					table.insert(tubes, p)
					c = e + 1
				else
					c += 1
				end
			end
		end
		-- vertical edges: between column c and c+1 (c = 0..NC)
		for c = 0, NC do
			local r = 1
			while r <= NR do
				local k = tubeKind(cell(r, c), cell(r, c + 1)) or tubeKind(cell(r, c + 1), cell(r, c))
				if k then
					local e = r
					while e < NR do
						local k2 = tubeKind(cell(e + 1, c), cell(e + 1, c + 1)) or tubeKind(cell(e + 1, c + 1), cell(e + 1, c))
						if k2 ~= k then break end
						e += 1
					end
					local y0, y1 = wy(r - 0.5), wy(e + 0.5)
					local p = B:block(R, v(T, math.abs(y1 - y0) + T, T), cf(wx(c + 0.5), (y0 + y1) / 2, TZ), NEONC[k], { mat = "Neon", name = "Tube" })
					table.insert(tubes, p)
					r = e + 1
				else
					r += 1
				end
			end
		end

		------------------------------------------------------------ back
		-- two gold rails across the struts and a small plain pixel-carrot badge
		for _, y in { CY - 3.6, CY + 3.6 } do
			B:block(R, v(8.8, 0.5, 0.5), cf(0, y, 1.55), GOLD_DK)
		end
		local MP = 0.3
		for r = 1, NR do
			local c = 1
			while c <= NC do
				local ch = cell(r, c)
				if ch ~= "." then
					local e = c
					while cell(r, e + 1) == ch do
						e += 1
					end
					local x0 = (c - (NC + 1) / 2) * MP
					local x1 = (e - (NC + 1) / 2) * MP
					B:block(R, v((e - c + 1) * MP + 0.02, MP + 0.02, 0.2), cf((x0 + x1) / 2, CY + ((NR + 1) / 2 - r) * MP, BD / 2 + 0.15), COL[ch])
					c = e + 1
				else
					c += 1
				end
			end
		end
		B:block(R, v(NC * MP + 1.0, NR * MP + 1.0, 0.12), cf(0, CY, BD / 2 + 0.06), PURP)

		------------------------------------------------------------ sparkles
		-- big 4-point pixel sparkle in the empty upper-left corner (screen space)
		local function sparkle(c, r, s, name)
			local x, y = wx(c), wy(r)
			B:block(R, v(PX * s * 0.5, PX * s * 2.2, 0.2), cf(x, y, PZ - 0.05), CREAM)
			B:block(R, v(PX * s * 2.2, PX * s * 0.5, 0.2), cf(x, y, PZ - 0.05), CREAM)
			return B:gem(R, v(PX * s * 0.55, PX * s * 0.55, 0.2), cf(x, y, PZ - 0.12, 0, 0, 45), N_YELLOW, { name = name })
		end
		local spark1 = sparkle(3, 4.5, 1.6, "SparkleBig")
		sparkle(12.5, 13, 1.1, "SparkleSmall")
		sparkle(4.5, 1.5, 0.6, "SparkleTiny")

		------------------------------------------------------------ top star
		local SY = CY + BH / 2 + 1.25
		B:block(R, v(0.8, 0.9, 0.6), cf(0, CY + BH / 2 + 0.55, 0), GOLD_DK)
		B:block(R, v(1.8, 0.6, 0.6), cf(0, SY, 0), GOLD)
		B:block(R, v(0.6, 1.8, 0.6), cf(0, SY, 0), GOLD)
		B:block(R, v(1.1, 1.1, 0.62), cf(0, SY, 0, 0, 0, 45), GOLD_LT)
		local starGem = B:gem(R, v(0.4, 0.4, 0.4), cf(0, SY, -0.35, 0, 0, 45), N_YELLOW, { name = "StarGem" })

		------------------------------------------------------------ fx
		B:emitter(spark1, "sparkle", { name = "CornerSparkle", color = { "#fff6b0", "#ffd04a" }, rate = 3, size = 0.45 })
		B:emitter(starGem, "sparkle", { name = "StarSparkle", color = { "#ffe27a", "#ff86d4", "#72e6ff" }, rate = 2.5, size = 0.4 })
		B:emitter(tubes[1], "glow", { name = "NeonGlow", color = "#ffa040", rate = 1, size = 0.8 })
		B:light(spark1, { color = "#ffb060", brightness = 1.0, range = 14, name = "SignLight" })
	end,
}
