-- Voidreaver (#10, the ultimate axe): a massive black-purple double greataxe.
-- Jagged bat-wing blades with neon violet edges and runes, a staring void eye
-- in the socket, demon horns + a spear tip on top, floating rune cubes round
-- the head and void particles. Built standing up: haft along +Y (pommel at
-- Y=0), blades along +/-X. Static tool: no motion.luau.
return {
	DisplayName = "Voidreaver",
	Rarity = "Apex",
	Element = "Tool",
	Tool = { Name = "Voidreaver", ToolTip = "Voidreaver", GripY = -1.9 },
	Build = function(B, P)
		local v, cf = P.v, P.cf


		-- pixel-art helper: rows of characters -> greedy-merged studded blocks.
		-- x0 = haft-side edge of column 1, sx = +1/-1 direction, yTop = top of row 1.
		local function pixels(rows, cell, x0, yTop, sx, pal)
			local H, W = #rows, 0
			for _, r in rows do
				W = math.max(W, #r)
			end
			local used = {}
			for r = 1, H do
				used[r] = {}
			end
			local function at(r, c)
				return rows[r]:sub(c, c)
			end
			for r = 1, H do
				for c = 1, W do
					local ch = at(r, c)
					local p = pal[ch]
					if p and not used[r][c] then
						local w = 1
						while c + w <= W and at(r, c + w) == ch and not used[r][c + w] do
							w += 1
						end
						local h = 1
						while r + h <= H do
							local ok = true
							for k = c, c + w - 1 do
								if at(r + h, k) ~= ch or used[r + h][k] then
									ok = false
									break
								end
							end
							if not ok then
								break
							end
							h += 1
						end
						for rr = r, r + h - 1 do
							for k = c, c + w - 1 do
								used[rr][k] = true
							end
						end
						local cx = x0 + sx * ((c - 1) + w / 2) * cell
						local cy = yTop - ((r - 1) + h / 2) * cell
						local zs = p.face and { p.face, -p.face } or { 0 }
						for _, z in zs do
							B:block("Root", v(w * cell, h * cell, p.d), cf(cx, cy, z), p.col, { mat = p.mat })
						end
					end
				end
			end
		end

		local VOID, VOID_D, VOID_L = "#24173f", "#0f0a19", "#36255a"
		local PURP, PURP_D, PURP_L = "#7036c8", "#47207e", "#9258e6"
		local LAV = "#b384ff"
		local VIOLET, PINK = "#c45cff", "#ff5cf0"

		------------------------------------------------------------------
		-- haft (the Handle) + grip + pommel
		------------------------------------------------------------------
		local HY = 5.4
		B:block("Root", v(0.46, 6.0, 0.46), cf(0, 3.45, 0), VOID, { name = "Handle" })
		-- collar above the grip, then a stepped purple spiral winding up to the head
		B:block("Root", v(0.56, 0.16, 0.56), cf(0, 2.55, 0), PURP)
		local spiral = { { 1, 0 }, { 0, 1 }, { -1, 0 }, { 0, -1 }, { 1, 0 } }
		for i, d in spiral do
			local y = 2.75 + (i - 1) * 0.27
			B:block("Root", v(d[1] ~= 0 and 0.08 or 0.5, 0.2, d[2] ~= 0 and 0.08 or 0.5), cf(d[1] * 0.25, y, d[2] * 0.25), PURP_L)
		end
		-- dark purple grip wrap with black ridges
		B:block("Root", v(0.52, 1.8, 0.52), cf(0, 1.55, 0), PURP_D)
		for _, y in { 0.72, 1.27, 1.83, 2.38 } do
			B:block("Root", v(0.58, 0.12, 0.58), cf(0, y, 0), VOID_D)
		end
		-- stepped pommel: claws + a violet gem underneath
		B:block("Root", v(0.66, 0.3, 0.66), cf(0, 0.3, 0), VOID_D)
		B:block("Root", v(0.5, 0.14, 0.5), cf(0, 0.52, 0), PURP)
		B:block("Root", v(0.44, 0.16, 0.44), cf(0, 0.08, 0), VOID_L)
		B:gem("Root", v(0.2, 0.08, 0.2), cf(0, 0.02, 0), VIOLET)
		for _, s in { -1, 1 } do
			B:block("Root", v(0.14, 0.34, 0.14), cf(0.36 * s, 0.24, 0, 0, 0, 20 * s), PURP_L)
			B:block("Root", v(0.14, 0.34, 0.14), cf(0, 0.24, 0.36 * s, -20 * s, 0, 0), PURP_L)
		end

		------------------------------------------------------------------
		-- socket + the void eye
		------------------------------------------------------------------
		local socket = B:block("Root", v(0.9, 1.9, 0.6), cf(0, HY, 0), VOID_D)
		B:block("Root", v(0.76, 0.16, 0.7), cf(0, HY + 0.98, 0), PURP)
		B:block("Root", v(0.76, 0.16, 0.7), cf(0, HY - 0.98, 0), PURP)
		B:block("Root", v(0.58, 0.14, 0.62), cf(0, HY + 1.12, 0), VOID_L)
		B:block("Root", v(0.58, 0.14, 0.62), cf(0, HY - 1.12, 0), VOID_L)
		-- eye: purple lids, glowing violet iris, black slit pupil (both faces)
		B:block("Root", v(0.62, 0.62, 0.66), cf(0, HY, 0, 0, 0, 45), PURP_D)
		local eye
		for _, z in { 0.34, -0.34 } do
			eye = B:gem("Root", v(0.42, 0.42, 0.04), cf(0, HY, z, 0, 0, 45), VIOLET, { name = "VoidEye" })
		end
		B:block("Root", v(0.1, 0.4, 0.74), cf(0, HY, 0), VOID_D)

		------------------------------------------------------------------
		-- jagged bat-wing blades (mirrored), neon edges + runes
		------------------------------------------------------------------
		local pal = {
			K = { col = VOID, d = 0.44 },
			M = { col = PURP_D, d = 0.44 },
			P = { col = PURP, d = 0.54 },
			L = { col = LAV, d = 0.34 },
		}
		local blade = {
			"......LL",
			".....LML",
			"....PMML",
			"...PKMML",
			"..PKKMML",
			".PKKKMML",
			"PKKKKKML",
			"PKKKKKML",
			"PKKKKK..",
			"PKKKKKML",
			"PKKKKKML",
			"PKKKKKML",
			"PKKKKK..",
			"PKKKKKML",
			"PKKKKKML",
			".PKKKMML",
			"..PKKMML",
			"...PKMML",
			"....PMML",
			".....LML",
			"......LL",
		}
		local CELL, X0 = 0.2, 0.34
		local yTop = HY + #blade * CELL / 2
		-- thin neon edge strip hugging the outer side of every row (incl. the teeth notches)
		local function edgeStrip(sx)
			local r = 1
			while r <= #blade do
				local last = #(blade[r]:match("^(.-)%.*$"))
				local h = 1
				while r + h <= #blade and #(blade[r + h]:match("^(.-)%.*$")) == last do
					h += 1
				end
				local x = X0 + last * CELL + 0.025
				local y = yTop - ((r - 1) + h / 2) * CELL
				B:block("Root", v(0.05, h * CELL, 0.1), cf(sx * x, y, 0), VIOLET, { mat = "Neon", name = "Edge" })
				r += h
			end
		end
		for _, sx in { 1, -1 } do
			pixels(blade, CELL, sx * X0, yTop, sx, pal)
			edgeStrip(sx)
			-- glowing runes on both faces: trident, eye, inverted trident
			local rf = { r = { col = VIOLET, d = 0.03, face = 0.235, mat = "Neon" } }
			local RC = 0.14
			local gx = X0 + 0.66
			pixels({ "r.r.r", "r.r.r", ".rrr.", "..r.." }, RC, sx * gx, yTop - 1.3, sx, rf)
			pixels({ ".r.", "r.r", ".r." }, RC, sx * (gx + 0.14), HY + 0.21, sx, { r = { col = PURP_L, d = 0.03, face = 0.235 } })
			pixels({ "..r..", ".rrr.", "r.r.r", "r.r.r" }, RC, sx * gx, HY - 0.73, sx, rf)
		end

		------------------------------------------------------------------
		-- top: stepped spear tip flanked by demon horns
		------------------------------------------------------------------
		B:block("Root", v(0.48, 0.22, 0.48), cf(0, 6.62, 0), VOID_L)
		B:block("Root", v(0.36, 0.26, 0.36), cf(0, 6.84, 0), VOID)
		B:block("Root", v(0.26, 0.26, 0.26), cf(0, 7.08, 0), PURP)
		B:block("Root", v(0.18, 0.24, 0.18), cf(0, 7.32, 0), VOID_D)
		B:gem("Root", v(0.1, 0.26, 0.1), cf(0, 7.56, 0), VIOLET, { name = "SpearTip" })
		-- demon horns curling up and out of the socket top
		for _, s in { 1, -1 } do
			B:bar("Root", v(0.26 * s, 6.45, 0), v(0.62 * s, 6.85, 0), 0.2, 0.22, VOID_L)
			B:bar("Root", v(0.6 * s, 6.80, 0), v(0.66 * s, 7.25, 0), 0.16, 0.18, PURP)
			B:bar("Root", v(0.66 * s, 7.20, 0), v(0.56 * s, 7.50, 0), 0.1, 0.12, PURP_L)
		end
		-- claws rising from the blade horn tips
		for _, s in { 1, -1 } do
			B:block("Root", v(0.26, 0.16, 0.3), cf(1.8 * s, HY + 2.18, 0), PURP)
			B:block("Root", v(0.14, 0.16, 0.18), cf(1.86 * s, HY + 2.34, 0), LAV)
			B:block("Root", v(0.26, 0.16, 0.3), cf(1.8 * s, HY - 2.18, 0), PURP)
			B:block("Root", v(0.14, 0.16, 0.18), cf(1.86 * s, HY - 2.34, 0), LAV)
		end
		-- fangs hanging under the socket
		for _, x in { -0.28, 0, 0.28 } do
			B:block("Root", v(0.14, 0.24, 0.14), cf(x, HY - 1.3, 0), PURP_L)
			B:block("Root", v(0.08, 0.14, 0.08), cf(x, HY - 1.48, 0), LAV)
		end

		------------------------------------------------------------------
		-- floating rune cubes
		------------------------------------------------------------------
		local cubes = {
			{ 2.3, HY + 1.45, 0.35, 20, 35, 15, 0.46 },
			{ -2.3, HY + 1.05, -0.35, -15, 25, 30, 0.46 },
			{ 2.35, HY - 1.15, -0.3, 30, 15, -20, 0.42 },
			{ -2.3, HY - 1.55, 0.3, -25, -35, 10, 0.42 },
			{ 1.25, HY - 2.45, 0.55, 40, 20, 35, 0.28 },
			{ -1.2, HY - 2.3, -0.55, 15, -40, 25, 0.28 },
		}
		local first
		for i, c in cubes do
			local base = cf(c[1], c[2], c[3], c[4], c[5], c[6])
			local sz = c[7]
			local cube = B:block("Root", v(sz, sz, sz), base, VOID_D, { name = "RuneCube" .. i })
			first = first or cube
			for _, z in { sz / 2 + 0.01, -sz / 2 - 0.01 } do
				B:block("Root", v(sz * 0.45, sz * 0.45, 0.04), base * CFrame.new(0, 0, z), VIOLET, { mat = "Neon" })
			end
		end

		-- effects: void wisps, rising violet motes, twinkles, one soft glow
		B:emitter(socket, "smoke", { color = { "#3a1466", "#12061f" }, rate = 3, size = { 0.8, 2, 3 } })
		B:emitter(socket, "ember", { color = { PINK, VIOLET, "#5a1aa8" }, rate = 7, speed = { 0.6, 1.6 }, spread = 60 })
		B:emitter(first, "sparkle", { color = { "#ffffff", VIOLET }, rate = 5 })
		B:light(eye, { color = VIOLET, brightness = 1.2, range = 9 })
	end,
}
