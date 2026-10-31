--!nocheck
-- Corn Shock Gate (Harvest Fields decoration, HERO piece).
-- A rustic wooden gate arch for the entrance of the harvest fields:
-- * two chunky stepped posts on stone footings, a long crossbeam with knee
--   braces (stepped arch silhouette) and a stepped gable on top crowned by a
--   grinning jack-o'-lantern that glows warm from inside
-- * a draped garland of orange / red / gold autumn leaves with mini pumpkins
-- * a hanging wooden sign on twine reading "HARVEST" in chunky pixel letters
--   (readable from both sides)
-- * a low ranch gate between the posts, one leaf swung invitingly ajar
-- * a big tied corn-shock bundle flanking each post: stepped flared base,
--   twine tie, dry stalk tops fanning out, drooping leaves, colourful corn
--   ears and a pumpkin at the foot
-- * a stepping-stone path through the gate, grass tufts, hay bits, leaves.
-- Static prop: no motion.luau.
return {
	DisplayName = "Corn Shock Gate",
	Rarity = "Decor",
	Element = "Harvest Fields",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad

		-- palette (Harvest Fields crops)
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local HAY, HAY_DK, HAY_LT = "#e6bd55", "#c4922e", "#f4d98a"
		local POST_DK, POST, POST_LT = "#55331d", "#7a4a2a", "#9a6438"
		local WOOD_DK, WOOD, WOOD_LT = "#6b4224", "#8a5a32", "#a8723f"
		local IRON = "#3f3e46"
		local TWINE, TWINE_DK = "#d9b56a", "#b08a42"
		local SIGN, SIGN_DK, LETTER = "#7a4a2a", "#4a2a17", "#ffe7a8"
		local LF_OR, LF_OR_DK, LF_RED, LF_RED_DK = "#f27a1c", "#d9581a", "#d8352a", "#a8231f"
		local LF_GOLD, LF_GOLD_LT, LF_PLUM = "#f7b52c", "#ffd34f", "#7b2e6e"
		local PUMP, PUMP_DK, PUMP_LT = "#ff9424", "#e06c18", "#ffb042"
		local STEM, VINE = "#6b7d2a", "#3f7a2a"
		local GLOW, GLOW_HOT = "#ffb12e", "#ffe066"
		local CS, CS_DK, CS_LT, CS_DD = "#d9b45a", "#b88e3a", "#ecd28c", "#946b28" -- dry corn stalks
		local EAR_Y, EAR_O, EAR_R, EAR_P = "#ffd23a", "#f08a1c", "#c8322a", "#6a2a7a"

		local seed = 209
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local root = "Root"

		------------------------------------------------------------ helpers
		local function pumpkin(C, w, cols)
			cols = cols or { PUMP, PUMP_DK, PUMP_LT }
			local h = w * 0.78
			B:block(root, v(w, h, w * 0.7), C, cols[2])
			B:block(root, v(w * 0.7, h + 0.04, w), C, cols[1])
			B:block(root, v(w * 0.66, h - 0.12, w * 0.66), C * CFrame.Angles(0, rad(45), 0), cols[2])
			B:block(root, v(w * 0.46, 0.2, w * 0.46), C * CFrame.new(0, h * 0.5 + 0.06, 0), cols[3])
			local s = w / 2.6
			local top = C * CFrame.new(0, h * 0.5, 0)
			B:block(root, v(0.42 * s, 0.7 * s, 0.42 * s), top * CFrame.new(0, 0.3 * s, 0) * CFrame.Angles(0, rad(20), rad(10)), STEM)
			B:block(root, v(0.9 * s, 0.14, 0.6 * s), top * CFrame.new(0.45 * s, 0.14, 0.1) * CFrame.Angles(0, rad(50), rad(-12)), VINE)
			return h
		end
		local function face(C, w)
			local s = w / 2.8
			local fz = -(w * 0.5) - 0.02
			local function fp(x, y, sx, sy, col, name)
				return B:block(root, v(sx * s, sy * s, 0.12), C * CFrame.new(x * s, y * s, fz), col, { mat = "Neon", name = name or "JackFace" })
			end
			for side = -1, 1, 2 do
				B:block(root, v(0.9 * s, 0.62 * s, 0.1), C * CFrame.new(side * 0.62 * s, 0.38 * s, fz + 0.03), "#6e2c08")
				fp(side * 0.62, 0.22, 0.74, 0.26, GLOW)
				fp(side * 0.62, 0.44, 0.44, 0.22, GLOW_HOT)
				fp(side * 0.62, 0.6, 0.16, 0.14, GLOW_HOT)
			end
			fp(0, -0.02, 0.3, 0.16, GLOW)
			B:block(root, v(2.0 * s, 0.5 * s, 0.1), C * CFrame.new(0, -0.4 * s, fz + 0.03), "#6e2c08")
			local core = fp(0, -0.42, 1.7, 0.32, GLOW_HOT, "JackGrin")
			fp(-0.91, -0.26, 0.26, 0.3, GLOW)
			fp(0.91, -0.26, 0.26, 0.3, GLOW)
			local tz = fz - 0.04
			B:block(root, v(0.26 * s, 0.17 * s, 0.14), C * CFrame.new(-0.3 * s, -0.33 * s, tz), PUMP)
			B:block(root, v(0.26 * s, 0.17 * s, 0.14), C * CFrame.new(0.3 * s, -0.33 * s, tz), PUMP)
			B:block(root, v(0.26 * s, 0.15 * s, 0.14), C * CFrame.new(0, -0.52 * s, tz), PUMP)
			return core
		end

		------------------------------------------------------------ footing + path
		local PX = 5.0 -- post centres at +-PX
		for _, sx in { -1, 1 } do
			B:block(root, v(2.6, 0.5, 2.6), cf(sx * PX, 0.25, 0, 0, 6 * sx, 0), STONE_DK)
			B:block(root, v(2.2, 0.4, 2.2), cf(sx * PX, 0.65, 0, 0, -8 * sx, 0), STONE)
		end
		for i, st in { { 0.2, -4.2, 1.9, 1.5, 12 }, { -0.4, -1.8, 2.0, 1.6, -8 }, { 0.3, 0.7, 2.1, 1.6, 20 }, { -0.2, 3.2, 1.9, 1.5, -15 }, { 0.6, 5.4, 1.5, 1.2, 30 } } do
			B:block(root, v(st[3], 0.3, st[4]), cf(st[1], 0.15, st[2], 0, st[5], 0), i % 2 == 0 and STONE or STONE_LT)
			B:block(root, v(st[3] * 0.55, 0.14, st[4] * 0.5), cf(st[1] - 0.2, 0.36, st[2] + 0.1, 0, st[5] + 15, 0), i % 2 == 0 and STONE_LT or STONE)
		end
		for _, g in { { -3.2, -2.6 }, { 3.0, -3.2 }, { -2.6, 2.8 }, { 2.4, 2.2 }, { -6.6, -2.8 }, { 6.8, 2.6 }, { -9.9, 1.6 }, { 10.0, -1.2 } } do
			local yaw = rnd() * 60
			B:block(root, v(0.45, 1.0, 0.45), cf(g[1], 0.5, g[2], 0, yaw, 6), GRASS)
			B:block(root, v(0.35, 0.7, 0.35), cf(g[1] + 0.35, 0.35, g[2] + 0.2, 0, yaw + 25, -10), GRASS_DK)
		end
		for _, h in { { -2.0, -4.4 }, { 2.2, -0.6 }, { -1.8, 4.6 }, { 3.4, 4.4 } } do
			local yaw = rnd() * 180
			B:block(root, v(1.5, 0.16, 0.22), cf(h[1], 0.08, h[2], 0, yaw, 0), HAY)
			B:block(root, v(1.2, 0.16, 0.22), cf(h[1] + 0.1, 0.22, h[2] + 0.1, 0, yaw + 50, 0), HAY_LT)
		end
		for i, l in { { -1.6, -3.0, LF_OR }, { 1.8, -2.2, LF_RED }, { 1.2, 1.8, LF_GOLD }, { -2.0, 0.6, LF_RED }, { -3.6, -4.0, LF_GOLD }, { 3.8, -4.2, LF_OR } } do
			B:block(root, v(0.8, 0.12, 0.8), cf(l[1], 0.06 + (i % 2) * 0.03, l[2], 0, rnd() * 90, 0), l[3])
		end

		------------------------------------------------------------ posts
		local PTOP = 13.6
		for _, sx in { -1, 1 } do
			local x = sx * PX
			B:block(root, v(1.8, 1.2, 1.8), cf(x, 1.3, 0), POST_DK) -- plinth
			B:block(root, v(1.4, PTOP - 1.6, 1.4), cf(x, (PTOP + 1.6) / 2, 0), POST)
			B:block(root, v(1.5, 0.3, 1.5), cf(x, 2.05, 0), POST_LT)
			-- weathered grain strips on the front and the inner side
			B:block(root, v(0.3, 6.0, 0.12), cf(x - sx * 0.3, 6.5, -0.72), POST_DK)
			B:block(root, v(0.3, 3.4, 0.12), cf(x + sx * 0.35, 10.6, -0.72), POST_LT)
			B:block(root, v(0.12, 5.0, 0.3), cf(x - sx * 0.72, 8.0, 0.25), POST_DK)
			-- stepped cap
			B:block(root, v(1.7, 0.4, 1.7), cf(x, PTOP + 0.2, 0), POST_DK)
			B:block(root, v(1.1, 0.4, 1.1), cf(x, PTOP + 0.6, 0), POST_LT)
			-- iron hinge straps for the gate
			for _, y in { 1.6, 3.9 } do
				B:block(root, v(0.4, 0.3, 1.5), cf(x - sx * 0.62, y, 0), IRON)
			end
		end

		------------------------------------------------------------ crossbeam, braces, gable
		local BY = 12.8 -- crossbeam centre
		B:block(root, v(13.6, 1.2, 1.25), cf(0, BY, 0), POST)
		B:block(root, v(13.7, 0.25, 1.3), cf(0, BY + 0.62, 0), POST_LT)
		B:block(root, v(0.5, 1.26, 1.32), cf(-6.6, BY, 0), POST_DK) -- end grain
		B:block(root, v(0.5, 1.26, 1.32), cf(6.6, BY, 0), POST_DK)
		for _, sx in { -1, 1 } do
			-- knee brace + stepped corner block -> arch silhouette
			B:bar(root, v(sx * (PX - 0.6), 10.2, 0), v(sx * 2.7, BY - 0.45, 0), 0.6, 0.8, POST_DK)
			B:block(root, v(1.2, 0.6, 1.0), cf(sx * (PX - 1.1), BY - 0.85, 0), POST)
		end
		-- stepped gable
		B:block(root, v(7.2, 0.8, 1.05), cf(0, BY + 1.15, 0), POST_DK)
		B:block(root, v(4.2, 0.7, 0.95), cf(0, BY + 1.9, 0), POST)
		B:block(root, v(1.8, 0.5, 1.0), cf(0, BY + 2.45, 0), POST_LT)

		-- jack-o'-lantern crowning the arch
		local JW = 2.6
		local JH = JW * 0.78
		local JC = CFrame.new(0, BY + 2.7 + JH / 2, -0.1) * CFrame.Angles(rad(-3), 0, rad(2))
		pumpkin(JC, JW)
		local core = face(JC, JW)
		B:light(core, { color = "#ffa64a", brightness = 1.0, range = 16, name = "JackLight" })
		-- two little pumpkins sitting on the gable steps
		for _, sx in { -1, 1 } do
			pumpkin(CFrame.new(sx * 2.7, BY + 1.55 + 0.5, -0.05) * CFrame.Angles(0, rad(25 * sx), 0), 1.3)
		end

		------------------------------------------------------------ leaf garland
		local LEAF = { LF_OR, LF_RED, LF_GOLD, LF_OR_DK, LF_GOLD_LT, LF_RED_DK, LF_OR, LF_PLUM }
		local GZ = -0.72
		local n = 0
		for _, seg in { { -6.3, -0.2 }, { 0.2, 6.3 } } do
			for i = 0, 5 do
				local t = i / 5
				local x = seg[1] + (seg[2] - seg[1]) * t
				local sag = 1.0 * math.sin(t * math.pi)
				n += 1
				local s = 0.75 + 0.15 * ((n * 7) % 3) / 2
				B:block(root, v(s, s, 0.35), cf(x, BY - 0.2 - sag, GZ, jit(10), jit(15), 45 + jit(15)), LEAF[(n - 1) % #LEAF + 1])
			end
		end
		-- a lighter swag on the back so the arch dresses both sides
		for i = 0, 6 do
			local t = i / 6
			local x = -5.6 + 11.2 * t
			local sag = 0.9 * math.sin(t * math.pi)
			B:block(root, v(0.8, 0.8, 0.35), cf(x, BY - 0.25 - sag, 0.72, jit(10), jit(15), 45 + jit(15)), LEAF[(i + 2) % #LEAF + 1])
		end
		-- drooping ends down the posts
		for _, sx in { -1, 1 } do
			for k = 1, 2 do
				B:block(root, v(0.7, 0.7, 0.3), cf(sx * (PX + 0.3), BY - 0.6 - k * 0.8, -0.82, 0, 0, 45 + k * 10 * sx), LEAF[(k + (sx > 0 and 2 or 0)) % #LEAF + 1])
			end
		end

		------------------------------------------------------------ hanging sign
		local SY = 10.25 -- sign centre
		local SW, SH = 6.6, 2.1
		for _, sx in { -1, 1 } do
			B:bar(root, v(sx * 2.6, BY - 0.6, 0), v(sx * 2.8, SY + SH / 2 - 0.1, 0), 0.16, 0.16, TWINE)
			B:block(root, v(0.36, 0.36, 0.5), cf(sx * 2.8, SY + SH / 2 - 0.05, 0), TWINE_DK)
		end
		B:block(root, v(SW, SH, 0.4), cf(0, SY, 0), SIGN)
		B:block(root, v(SW + 0.3, 0.3, 0.5), cf(0, SY + SH / 2, 0), SIGN_DK)
		B:block(root, v(SW + 0.3, 0.3, 0.5), cf(0, SY - SH / 2, 0), SIGN_DK)
		B:block(root, v(0.3, SH + 0.3, 0.5), cf(-SW / 2, SY, 0), SIGN_DK)
		B:block(root, v(0.3, SH + 0.3, 0.5), cf(SW / 2, SY, 0), SIGN_DK)
		-- pixel letters, 3x5 font, greedy rectangles
		local FONT = {
			H = { "X.X", "X.X", "XXX", "X.X", "X.X" },
			A = { ".X.", "X.X", "XXX", "X.X", "X.X" },
			R = { "XX.", "X.X", "XX.", "X.X", "X.X" },
			V = { "X.X", "X.X", "X.X", "X.X", ".X." },
			E = { "XXX", "X..", "XX.", "X..", "XXX" },
			S = { ".XX", "X..", ".X.", "..X", "XX." },
			T = { "XXX", ".X.", ".X.", ".X.", ".X." },
		}
		local PIX = 0.24
		local WORD = "HARVEST"
		local step = 4 * PIX
		local totalW = #WORD * step - PIX
		local function letters(fz)
			local dir = fz < 0 and -1 or 1 -- seen from -Z, +X is on the left: flip so both faces read correctly
			for li = 1, #WORD do
				local g = FONT[string.sub(WORD, li, li)]
				local used = {}
				local function px(c, r)
					return string.sub(g[r], c, c) == "X"
				end
				local x0 = -totalW / 2 + (li - 1) * step
				local function put(c0, r0, c1, r1)
					local cx = x0 + ((c0 + c1) / 2 - 0.5) * PIX
					local cy = SY + (3 - (r0 + r1) / 2) * PIX
					B:block(root, v((c1 - c0 + 1) * PIX + 0.01, (r1 - r0 + 1) * PIX + 0.01, 0.14), cf(dir * cx, cy, fz), LETTER)
				end
				-- vertical runs (>=2) first
				for c = 1, 3 do
					local r = 1
					while r <= 5 do
						if px(c, r) then
							local r1 = r
							while r1 + 1 <= 5 and px(c, r1 + 1) do
								r1 += 1
							end
							if r1 > r then
								put(c, r, c, r1)
								for k = r, r1 do
									used[c .. "," .. k] = true
								end
							end
							r = r1 + 1
						else
							r += 1
						end
					end
				end
				-- leftovers merged horizontally
				for r = 1, 5 do
					local c = 1
					while c <= 3 do
						if px(c, r) and not used[c .. "," .. r] then
							local c1 = c
							while c1 + 1 <= 3 and px(c1 + 1, r) and not used[(c1 + 1) .. "," .. r] do
								c1 += 1
							end
							put(c, r, c1, r)
							c = c1 + 1
						else
							c += 1
						end
					end
				end
			end
		end
		letters(-0.25)
		letters(0.25)

		------------------------------------------------------------ gate leaves
		local GW = PX - 0.7 -- leaf width (hinge at the post face to the centre)
		local function gateLeaf(sx, open)
			-- frame: hinge at x = sx*(PX-0.7), leaf extends toward the centre
			local H = CFrame.new(sx * (PX - 0.72), 0, 0) * CFrame.Angles(0, rad(-sx * open), 0)
			local function at(lx, y, lz)
				return H * CFrame.new(-sx * lx, y, lz or 0)
			end
			B:block(root, v(0.45, 4.2, 0.45), at(0.25, 2.6), WOOD_DK) -- hinge stile
			B:block(root, v(0.45, 3.9, 0.45), at(GW - 0.3, 2.55), WOOD_DK) -- latch stile
			for _, y in { 1.1, 2.6, 4.1 } do
				B:block(root, v(GW - 0.2, 0.45, 0.32), at(GW / 2, y), y == 2.6 and WOOD or WOOD_LT)
			end
			-- Z brace
			local a = at(0.45, 1.2, 0).Position
			local b = at(GW - 0.5, 3.95, 0).Position
			B:bar(root, a, b, 0.36, 0.3, WOOD)
			-- picket tips on the top rail
			for k = 1, 3 do
				B:block(root, v(0.36, 0.5, 0.36), at(k * (GW / 4), 4.5), WOOD_LT)
			end
			-- latch
			if sx < 0 then
				B:block(root, v(0.7, 0.2, 0.2), at(GW - 0.1, 3.3, -0.3), IRON)
			end
		end
		gateLeaf(-1, 4)
		gateLeaf(1, 32)

		------------------------------------------------------------ corn shocks
		local function shock(sx)
			local X = sx * 8.1
			local Z = 0.2
			local yaw = sx * 12
			local C = CFrame.new(X, 0, Z) * CFrame.Angles(0, rad(yaw), 0)
			local function at(x, y, z)
				return C * CFrame.new(x, y, z)
			end
			-- flared stepped base (cross-shaped tiers stepping in toward the tie)
			local tiers = {
				{ 0.0, 1.5, 4.2, CS_DK },
				{ 1.5, 1.4, 3.6, CS },
				{ 2.9, 1.3, 2.9, CS_DK },
				{ 4.2, 1.2, 2.3, CS },
				{ 5.4, 1.0, 1.75, CS_DK },
			}
			for _, tr in tiers do
				local y, h, w, col = tr[1] + tr[2] / 2, tr[2], tr[3], tr[4]
				B:block(root, v(w, h, w * 0.7), at(0, y, 0), col)
				B:block(root, v(w * 0.7, h + 0.02, w), at(0, y, 0), col)
			end
			-- bundle of stalks: bold lines leaning in from the flared foot to the tie
			for k = 0, 11 do
				local a = rad(k * 30 + 15)
				local sa, ca = math.sin(a), -math.cos(a)
				local col = ({ CS_DD, HAY_LT, CS_LT })[k % 3 + 1]
				B:bar(root, at(sa * 2.35, 0.15, ca * 2.35).Position, at(sa * 0.85, 6.3, ca * 0.85).Position, 0.42, 0.42, col)
			end
			-- twine tie
			B:block(root, v(1.9, 0.45, 1.9), at(0, 6.3, 0) * CFrame.Angles(0, rad(10), 0), TWINE)
			B:block(root, v(1.95, 0.25, 1.95), at(0, 6.7, 0) * CFrame.Angles(0, rad(-20), 0), TWINE_DK)
			B:block(root, v(0.3, 0.9, 0.2), at(0.4, 5.85, -1.0) * CFrame.Angles(0, 0, rad(18)), TWINE) -- dangling knot end
			-- stalk tops fanning out above the tie
			B:block(root, v(1.3, 1.6, 1.3), at(0, 7.5, 0), CS)
			local tops = 11
			for k = 0, tops - 1 do
				local a = rad(k * (360 / tops) + 15)
				local lean = 14 + (k % 3) * 8
				local len = 3.2 + (k % 3) * 0.6
				local base = at(math.sin(a) * 0.3, 6.9, -math.cos(a) * 0.3)
				local dir = (C.Rotation * CFrame.Angles(0, -a, 0) * CFrame.Angles(rad(-lean), 0, 0)).LookVector
				local up = v(0, 1, 0)
				local tip = base.Position + (up * math.cos(rad(lean)) + v(math.sin(a), 0, -math.cos(a)) * math.sin(rad(lean))) * len
				local col = ({ CS, CS_LT, CS_DK })[k % 3 + 1]
				B:bar(root, base.Position, tip, 0.45, 0.45, col)
				-- tassel tuft at the tip
				B:block(root, v(0.4, 0.5, 0.4), CFrame.new(tip) * CFrame.Angles(0, a, rad(15)), (k % 2 == 0) and HAY_LT or CS_DD)
			end
			-- dry leaves drooping out of the bundle
			for k = 0, 4 do
				local a = rad(k * 72 + 40)
				local y0 = 3.6 + (k % 2) * 1.2
				local o = v(math.sin(a), 0, -math.cos(a))
				local base = at(0, y0, 0).Position + (C.Rotation * CFrame.new(o * 1.5)).Position
				local mid = base + (C.Rotation * CFrame.new(o * 1.0)).Position + v(0, 0.6, 0)
				local tip = mid + (C.Rotation * CFrame.new(o * 0.9)).Position + v(0, -0.9, 0)
				B:bar(root, base, mid, 0.38, 0.38, CS_LT)
				B:bar(root, mid, tip, 0.34, 0.34, CS_DK)
			end
			-- colourful corn ears leaning against the base
			local ears = sx < 0 and { { -1.3, -1.7, EAR_Y, 22, -18 }, { 0.2, -2.1, EAR_R, -8, -24 }, { 1.4, -1.6, EAR_P, -26, -14 } }
				or { { -1.2, -1.7, EAR_O, 24, -16 }, { 0.3, -2.1, EAR_Y, -6, -22 }, { 1.4, -1.5, EAR_R, -24, -18 } }
			for _, e in ears do
				local E = at(e[1], 1.15, e[2]) * CFrame.Angles(rad(e[5]), 0, rad(e[4]))
				B:block(root, v(0.55, 1.7, 0.55), E, e[3])
				B:block(root, v(0.6, 0.35, 0.6), E * CFrame.new(0, 0.45, 0), e[3] == EAR_P and "#8a3c9a" or (e[3] == EAR_R and "#e0503a" or LF_GOLD_LT))
				B:block(root, v(0.25, 1.3, 0.7), E * CFrame.new(0.3, -0.5, 0.1) * CFrame.Angles(0, 0, rad(-14)), HAY_LT) -- husk
			end
			-- pumpkin at the outer foot
			pumpkin(CFrame.new(X + sx * 1.5, 0.82, Z - 2.75) * CFrame.Angles(0, rad(-30 * sx), 0), 2.1)
			-- leaves around the foot
			for k = 0, 3 do
				local a = rad(k * 90 + 30)
				B:block(root, v(0.75, 0.12, 0.75), cf(X + math.sin(a) * 2.4, 0.07, Z - math.cos(a) * 2.4, 0, k * 33, 0), LEAF[(k + (sx > 0 and 3 or 0)) % #LEAF + 1])
			end
		end
		shock(-1)
		shock(1)
	end,
}
