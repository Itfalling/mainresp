-- Celestial Axe (#9): white-gold double crescent blades with a star cutout on
-- one bit and a moon cutout on the other, a glowing cyan core, midnight-blue
-- haft. Built standing up: haft along +Y (pommel at Y=0), blades along +/-X.
-- Static tool: no motion.luau.
return {
	DisplayName = "Celestial Axe",
	Rarity = "Divine",
	Element = "Tool",
	Tool = { Name = "Celestial Axe", ToolTip = "Celestial Axe", GripY = -1.7 },
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

		local NAVY, NAVY_D, NAVY_L = "#26357a", "#18224f", "#3a4fa3"
		local PEARL, PEARL_D = "#fbf8f0", "#ddd3bd"
		local GOLD, GOLD_D, GOLD_L = "#f2c548", "#c99227", "#ffe08a"
		local CYAN = "#5ff4ff"

		------------------------------------------------------------------
		-- haft (the Handle) + grip + pommel
		------------------------------------------------------------------
		B:block("Root", v(0.42, 5.7, 0.42), cf(0, 3.25, 0), NAVY, { name = "Handle" })
		-- gold star studs + thin trim lines up the haft
		for _, y in { 2.85, 3.55 } do
			B:block("Root", v(0.5, 0.14, 0.5), cf(0, y, 0), GOLD)
		end
		B:block("Root", v(0.48, 0.5, 0.48), cf(0, 3.2, 0), NAVY_L)
		for _, z in { 0.22, -0.22 } do
			B:block("Root", v(0.14, 0.14, 0.04), cf(0, 3.2, z), GOLD_L)
			B:block("Root", v(0.08, 0.7, 0.04), cf(0, 4.2, z), NAVY_D)
		end
		-- white leather grip with gold rings
		B:block("Root", v(0.48, 1.6, 0.48), cf(0, 1.55, 0), PEARL)
		for _, y in { 0.8, 1.55, 2.3 } do
			B:block("Root", v(0.54, 0.12, 0.54), cf(0, y, 0), GOLD)
		end
		for _, y in { 1.18, 1.92 } do
			B:block("Root", v(0.52, 0.08, 0.52), cf(0, y, 0), PEARL_D)
		end
		-- stepped gold pommel with cyan gems
		B:block("Root", v(0.6, 0.28, 0.6), cf(0, 0.14, 0), GOLD_D)
		B:block("Root", v(0.5, 0.16, 0.5), cf(0, 0.36, 0), GOLD)
		B:block("Root", v(0.36, 0.1, 0.36), cf(0, 0.49, 0), GOLD_L)
		for _, z in { 0.31, -0.31 } do
			B:gem("Root", v(0.16, 0.12, 0.04), cf(0, 0.14, z), CYAN)
		end

		------------------------------------------------------------------
		-- head socket + glowing core
		------------------------------------------------------------------
		local HY = 5.1
		local socket = B:block("Root", v(0.8, 1.6, 0.5), cf(0, HY, 0), GOLD)
		B:block("Root", v(0.66, 0.14, 0.6), cf(0, HY + 0.86, 0), GOLD_D)
		B:block("Root", v(0.66, 0.14, 0.6), cf(0, HY - 0.86, 0), GOLD_D)
		B:block("Root", v(0.5, 0.12, 0.52), cf(0, HY + 0.99, 0), PEARL)
		B:block("Root", v(0.5, 0.12, 0.52), cf(0, HY - 0.99, 0), PEARL)
		-- diamond frame + cyan core through the socket
		B:block("Root", v(0.5, 0.5, 0.56), cf(0, HY, 0, 0, 0, 45), PEARL)
		local core = B:gem("Root", v(0.26, 0.26, 0.62), cf(0, HY, 0), CYAN, { name = "Core" })

		------------------------------------------------------------------
		-- crescent blades: star bit (+X) and moon bit (-X)
		------------------------------------------------------------------
		local pal = {
			W = { col = PEARL, d = 0.3 },
			G = { col = GOLD_D, d = 0.38 },
			E = { col = GOLD_L, d = 0.24 },
			n = { col = NAVY, d = 0.1 }, -- night sky seen through the star / moon cutouts
		}
		local star = {
			"EEE......",
			"GWWEE....",
			".GWWWEE..",
			"..GWWWWE.",
			"..GWWWWWE",
			"..GWWWWWE",
			".GWWWWWWE",
			"GGWWWWWWE",
			"GWWWWnWWE",
			"GWWWnnnWE",
			"GWWWWnWWE",
			"GGWWWWWWE",
			".GWWWWWWE",
			"..GWWWWWE",
			"..GWWWWWE",
			"..GWWWWE.",
			".GWWWEE..",
			"GWWEE....",
			"EEE......",
		}
		local moon = {
			"EEE......",
			"GWWEE....",
			".GWWWEE..",
			"..GWWWWE.",
			"..GWWWWWE",
			"..GWWWWWE",
			".GWWWWWWE",
			"GGWWWnWWE",
			"GWWWnWWWE",
			"GWWnnWWWE",
			"GWWWnWWWE",
			"GGWWWnWWE",
			".GWWWWWWE",
			"..GWWWWWE",
			"..GWWWWWE",
			"..GWWWWE.",
			".GWWWEE..",
			"GWWEE....",
			"EEE......",
		}
		local CELL = 0.18
		local yTop = HY + #star * CELL / 2
		pixels(star, CELL, 0.32, yTop, 1, pal)
		pixels(moon, CELL, -0.32, yTop, -1, pal)
		-- face inlays: cyan glow line inside the edge, gold frames round the cutouts
		local face = {
			c = { col = CYAN, d = 0.04, face = 0.17, mat = "Neon" },
			g = { col = GOLD, d = 0.04, face = 0.17 },
		}
		local edgeLine = {
			".........", ".........", ".........",
			".....g...",
			"....gcg..",
			".....g.c.",
			".......c.", ".......c.", ".......c.", ".......c.", ".......c.", ".......c.", ".......c.",
			".....g.c.",
			"....gcg..",
			".....g...",
		}
		pixels(edgeLine, CELL, 0.32, yTop, 1, face)
		pixels(edgeLine, CELL, -0.32, yTop, -1, face)

		------------------------------------------------------------------
		-- top finial: stepped gold spire with a cyan star
		------------------------------------------------------------------
		B:block("Root", v(0.42, 0.22, 0.42), cf(0, 6.2, 0), GOLD)
		B:block("Root", v(0.3, 0.14, 0.3), cf(0, 6.36, 0), GOLD_L)
		-- little gold crescent moon cradling a cyan star
		pixels({
			"X.......X",
			"XX.....XX",
			".XX...XX.",
			"..XXXXX..",
		}, 0.11, -0.495, 6.87, 1, { X = { col = GOLD, d = 0.2 } })
		B:gem("Root", v(0.16, 0.16, 0.16), cf(0, 6.74, 0, 0, 0, 45), CYAN, { name = "StarTip" })
		B:block("Root", v(0.05, 0.42, 0.05), cf(0, 6.74, 0), PEARL)
		B:block("Root", v(0.42, 0.05, 0.05), cf(0, 6.74, 0), PEARL)

		-- effects
		B:emitter(socket, "sparkle", { color = { "#ffffff", CYAN, GOLD_L }, rate = 7, size = { 0.12, 0.4, 0 } })
		B:emitter(core, "glow", { color = CYAN, rate = 1.2 })
		B:light(core, { color = CYAN, brightness = 0.9, range = 8 })
	end,
}
