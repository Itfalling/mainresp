-- Voidreaver (#10, the ultimate axe): a massive black-purple double greataxe.
-- Jagged bat-wing blades with neon violet edges and runes, a staring void eye
-- in the socket, demon horns + a spear tip on top, floating rune cubes round
-- the head and void particles. Built standing up: haft along +Y (pommel at
-- Y=0), blades along +/-X. Static tool: no motion.luau.
return {
	DisplayName = "Voidreaver",
	Rarity = "Apex",
	Element = "Tool",
	Tool = { Name = "Voidreaver", ToolTip = "Voidreaver", GripY = -1.95 },
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

		local VOID, VOID_D, VOID_L = "#21163a", "#0f0a19", "#33244f"
		local PURP, PURP_D, PURP_L = "#6a34b8", "#3f1f6e", "#8650d6"
		local LAV = "#a77bf0"
		local VIOLET, PINK = "#c45cff", "#ff5cf0"

		------------------------------------------------------------------
		-- haft (the Handle) + grip + pommel
		------------------------------------------------------------------
		B:block("Root", v(0.46, 6.1, 0.46), cf(0, 3.5, 0), VOID, { name = "Handle" })
		-- purple bands + neon rune dots up the haft
		for _, y in { 2.95, 3.85, 4.75 } do
			B:block("Root", v(0.54, 0.14, 0.54), cf(0, y, 0), PURP)
		end
		for _, y in { 3.4, 4.3 } do
			B:block("Root", v(0.5, 0.3, 0.5), cf(0, y, 0), VOID_L)
			for _, z in { 0.255, -0.255 } do
				B:gem("Root", v(0.12, 0.12, 0.04), cf(0, y, z), VIOLET)
			end
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
		local HY = 5.5
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
				B:block("Root", v(0.05, h * CELL, 0.14), cf(sx * x, y, 0), VIOLET, { mat = "Neon", name = "Edge" })
				r += h
			end
		end
		for _, sx in { 1, -1 } do
			pixels(blade, CELL, X0, yTop, sx, pal)
			edgeStrip(sx)
			-- glowing runes on both faces: trident, eye, inverted trident
			local rf = { r = { col = VIOLET, d = 0.03, face = 0.235, mat = "Neon" } }
			local RC = 0.14
			local gx = X0 + 0.66
			pixels({ "r.r.r", "r.r.r", ".rrr.", "..r.." }, RC, gx, yTop - 1.3, sx, rf)
			pixels({ ".r.", "r.r", ".r." }, RC, gx + 0.14, HY + 0.21, sx, rf)
			pixels({ "..r..", ".rrr.", "r.r.r", "r.r.r" }, RC, gx, HY - 0.73, sx, rf)
		end

		------------------------------------------------------------------
		-- top: stepped spear tip flanked by demon horns
		------------------------------------------------------------------
		B:block("Root", v(0.44, 0.24, 0.44), cf(0, 6.74, 0), VOID_L)
		B:block("Root", v(0.32, 0.26, 0.32), cf(0, 6.98, 0), VOID)
		B:block("Root", v(0.22, 0.26, 0.22), cf(0, 7.22, 0), PURP)
		B:gem("Root", v(0.12, 0.24, 0.12), cf(0, 7.46, 0), VIOLET)

		------------------------------------------------------------------
		-- floating rune cubes
		------------------------------------------------------------------
		local cubes = {
			{ 2.3, 7.0, 0.3, 20, 35, 15 },
			{ -2.3, 6.6, -0.3, -15, 25, 30 },
			{ 2.35, 4.4, -0.3, 30, 15, -20 },
			{ -2.3, 4.0, 0.3, -25, -35, 10 },
		}
		local first
		for i, c in cubes do
			local base = cf(c[1], c[2], c[3], c[4], c[5], c[6])
			local cube = B:block("Root", v(0.42, 0.42, 0.42), base, VOID_D, { name = "RuneCube" .. i })
			first = first or cube
			for _, z in { 0.22, -0.22 } do
				B:block("Root", v(0.24, 0.24, 0.04), base * CFrame.new(0, 0, z), VIOLET, { mat = "Neon" })
			end
		end

		-- effects: void wisps, rising violet motes, twinkles, one soft glow
		B:emitter(socket, "smoke", { color = { "#3a1466", "#12061f" }, rate = 3, size = { 0.8, 2, 3 } })
		B:emitter(socket, "ember", { color = { PINK, VIOLET, "#5a1aa8" }, rate = 7, speed = { 0.6, 1.6 }, spread = 60 })
		B:emitter(first, "sparkle", { color = { "#ffffff", VIOLET }, rate = 5 })
		B:light(eye, { color = VIOLET, brightness = 1.2, range = 9 })
	end,
}
