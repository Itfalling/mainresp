--!nocheck
-- Harvest Fields Gate (Map landmark, stage 3 gate). A cute autumn / halloween
-- arch spanning the whole 64-stud run lane.
-- * Two giant corn-shock pillars (x = +-32..44): ring after ring of dry corn
--   stalks pinched into an hourglass by thick twine bands, flaring out into a
--   shaggy crown of stalk tips and drooping leaves; coloured corn cobs tucked in,
--   a hay-bale and pumpkin footing.
-- * A rustic double-timber lintel with iron straps, a draped garland of orange,
--   red and gold maple leaves on both faces and leaves scattered along its top.
-- * The plain cream "Sign" in a chunky dark-wood frame with twine-wrapped corners
--   (the map tool adds the stage name on its -Z face); the back has a crossed
--   pitchfork-and-cob plaque.
-- * Crown: a stacked pyramid of jack-o'-lanterns (carved on both faces, neon
--   glow inside), with a crow on a twig perch beside it and another crow on the
--   top pumpkin's stem.
-- Opening: completely clear for |x| < 32, y < 19 (lintel bottom at 19.3).
-- Static Filler landmark: no scripts, no effects.
return {
	DisplayName = "Harvest Fields Gate",
	Rarity = "Landmark",
	Filler = true,
	Element = "Harvest Fields",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		local CS, CS_DK, CS_LT, CS_DD = "#d9b45a", "#b88e3a", "#ecd28c", "#946b28"
		local TWINE, TWINE_DK = "#8a5a2a", "#6a4220"
		local WOOD, WOOD_DK, WOOD_LT = "#8a5a32", "#6b4224", "#a8723f"
		local IRON = "#3f3e46"
		local HAY, HAY_DK, HAY_LT = "#e6bd55", "#c4922e", "#f4d98a"
		local PUMP, PUMP_DK, PUMP_LT = "#ff9424", "#e06c18", "#ffb042"
		local STEM, STEM_DK = "#6b7d2a", "#4c5a1c"
		local CARVE, RIM = "#ffc232", "#6e2c08"
		local LF_OR, LF_OR_DK, LF_RED, LF_RED_DK = "#f27a1c", "#d9581a", "#d8352a", "#a8231f"
		local LF_GOLD, LF_BRN = "#f7b52c", "#8a4a22"
		local EAR_Y, EAR_O, EAR_R, EAR_P = "#ffd23a", "#f08a1c", "#c8322a", "#6a2a7a"
		local CROW, CROW_DK, CROW_LT = "#2a2833", "#1a1920", "#43404f"
		local BEAK, EYE = "#f2b234", "#fff4c8"
		local SIGN = "#fff1d2"

		local seed = 903
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		local PX = 38
		local BY0, BY1 = 19.3, 25.3
		local BD = 5

		---------------------------------------------------------------- corn-shock pillars
		local stalkCols = { CS, CS_DK, CS_LT, CS, CS_DD, CS_LT }
		local leafCols = { CS_LT, CS, CS_DK, "#c9a24a" }
		B:sym(function(side, s)
			-- solid core so nothing reads hollow
			B:block(R, v(6.6, 26, 6.6), cf(PX, 13.5, 0), CS_DK)
			B:block(R, v(5.6, 26.4, 5.6), cf(PX, 13.6, 0, 0, 45, 0), CS_DD)
			local TIE = 17.5
			local N = 16
			for i = 0, N - 1 do
				local a = (i / N) * math.pi * 2 + (s > 0 and 0 or 0.2)
				local ca, sa = math.cos(a), math.sin(a)
				-- radii: base 5.6 (fits |x| 32..44, |z| <= 5.6), tie 3.6, top 5.4
				local rb, rt, rtop = 5.0, 3.4, 5.0
				local zb = 0.88 -- squash in Z so depth stays inside +-6
				local p0 = v(PX + ca * rb, 0.2, sa * rb * zb)
				local p1 = v(PX + ca * rt, TIE, sa * rt * zb)
				local htop = 28.8 + ((i % 3 == 0) and 1.6 or ((i % 3 == 1) and 0.4 or 0.9))
				local p2 = v(PX + ca * rtop, htop, sa * rtop * zb)
				local col = stalkCols[i % #stalkCols + 1]
				B:bar(R, p0, p1, 1.1, 1.1, col, { up = v(0, 0, 1) })
				B:bar(R, p1, p2, 1.0, 1.0, col, { up = v(0, 0, 1) })
				-- stalk tip: a short drooping tassel outward
				local out = v(ca, 0, sa * zb)
				local tip = p2 + out * 0.9 + v(0, 0.9, 0)
				B:bar(R, p2, tip, 0.5, 0.5, CS_LT)
				-- drooping leaf from mid-upper stalk
				if i % 2 == 0 then
					local lp = p1 + (p2 - p1) * (0.45 + (i % 4) * 0.08)
					local le = lp + out * 2.2 + v(0, -1.8, 0)
					B:bar(R, lp, le, 0.9, 0.2, leafCols[(i / 2) % 4 + 1])
				end
				-- a few leaves near the base
				if i % 4 == 1 and ca > -0.3 then
					local lp = p0 + (p1 - p0) * 0.3
					B:bar(R, lp, lp + out * 1.4 + v(0, 1.0, 0), 0.8, 0.2, leafCols[(i % 3) + 1])
				end
			end
			-- inner ring of taller stalks so the crown is dense
			for i = 0, 7 do
				local a = (i / 8) * math.pi * 2 + 0.4
				local ca, sa = math.cos(a), math.sin(a)
				local p1 = v(PX + ca * 1.8, TIE, sa * 1.8)
				local p2 = v(PX + ca * 3.0, 30.6 + (i % 2) * 0.9, sa * 3.0)
				B:bar(R, p1, p2, 0.9, 0.9, stalkCols[(i + 2) % #stalkCols + 1], { up = v(0, 0, 1) })
			end
			-- twine bands (tie)
			for _, b in { { TIE, 8.4, 1.4 }, { TIE + 1.8, 8.0, 0.6 } } do
				B:block(R, v(b[2], b[3], b[2] * 0.95), cf(PX, b[1], 0), TWINE)
				B:block(R, v(b[2] * 0.92, b[3] + 0.02, b[2] * 0.92), cf(PX, b[1], 0, 0, 45, 0), TWINE_DK)
			end
			-- twine bow knot on the front and back
			for _, f in { -1, 1 } do
				B:block(R, v(1.2, 1.2, 0.8), cf(PX, TIE, f * 4.2), TWINE_DK)
				B:block(R, v(1.6, 0.6, 0.5), cf(PX - 1.0, TIE + 0.4, f * 4.3, 0, 0, 30), TWINE)
				B:block(R, v(1.6, 0.6, 0.5), cf(PX + 1.0, TIE + 0.4, f * 4.3, 0, 0, -30), TWINE)
				B:block(R, v(0.5, 1.6, 0.4), cf(PX - 0.5, TIE - 1.2, f * 4.3, 0, 0, -15), TWINE)
			end
			-- coloured corn cobs tucked into the band
			local cobs = { { 0.5, EAR_Y }, { 1.6, EAR_O }, { 2.8, EAR_R }, { 4.0, EAR_P }, { 5.2, EAR_Y } }
			for k, c in cobs do
				local a = c[1] + (s > 0 and 0 or 0.4)
				local ca, sa = math.cos(a), math.sin(a)
				local base = v(PX + ca * 4.0, TIE + 1.2, sa * 3.9)
				local top = base + v(ca * 0.8, 2.6, sa * 0.8)
				B:bar(R, base, top, 0.9, 0.9, c[2], { up = v(0, 0, 1) })
				B:bar(R, base - v(0, 0.3, 0), base + v(ca * 1.2, 1.2, sa * 1.2), 0.9, 0.25, "#e8d79a")
			end

			-- footing: hay bales + pumpkins at the corners
			for _, f in { -1, 1 } do
				B:block(R, v(4.0, 2.2, 2.6), cf(PX + 3.6, 1.1, f * 4.4, 0, f * 8, 0), HAY)
				B:block(R, v(4.05, 0.5, 2.65), cf(PX + 3.6, 1.8, f * 4.4, 0, f * 8, 0), HAY_LT)
				B:block(R, v(0.3, 2.25, 2.7), cf(PX + 3.0, 1.1, f * 4.4, 0, f * 8, 0), TWINE)
				-- pumpkin
				local pz = f * 4.6
				B:block(R, v(2.6, 2.0, 2.4), cf(PX - 3.5, 1.0, pz), PUMP)
				B:block(R, v(1.8, 2.1, 2.6), cf(PX - 3.5, 1.05, pz), PUMP_DK)
				B:block(R, v(0.4, 0.8, 0.4), cf(PX - 3.5, 2.4, pz, 0, 0, 15), STEM)
			end
		end)

		---------------------------------------------------------------- lintel
		local LY = (BY0 + BY1) / 2
		-- two chunky timbers + filler boards
		B:block(R, v(68, 2.6, BD), cf(0, BY1 - 1.3, 0), WOOD)
		B:block(R, v(68, 2.6, BD - 0.4), cf(0, BY0 + 1.3, 0), WOOD_DK)
		B:block(R, v(66, 1.0, BD - 0.8), cf(0, LY, 0), WOOD_DK)
		for _, f in { -1, 1 } do
			-- grain lines
			B:block(R, v(60, 0.25, 0.2), cf(0, BY1 - 0.9, f * (BD / 2 + 0.05)), WOOD_LT)
			B:block(R, v(60, 0.25, 0.2), cf(0, BY0 + 0.8, f * (BD / 2 - 0.15)), WOOD)
			-- iron straps with rivets near the pillars
			for _, x in { 31.0, -31.0, 22.5, -22.5 } do
				B:block(R, v(0.9, LY * 0 + 6.3, 0.3), cf(x, LY, f * (BD / 2 + 0.15)), IRON)
				B:block(R, v(0.4, 0.4, 0.2), cf(x, BY1 - 0.8, f * (BD / 2 + 0.35)), "#8a8996")
				B:block(R, v(0.4, 0.4, 0.2), cf(x, BY0 + 0.8, f * (BD / 2 + 0.35)), "#8a8996")
			end
		end
		-- timber ends poking out past the pillars' inner edge are hidden in the stalks

		---------------------------------------------------------------- maple leaves
		local leafPal = { LF_OR, LF_RED, LF_GOLD, LF_OR_DK, LF_RED_DK, LF_BRN }
		local function maple(pos, size, rot, col, face)
			-- 3-block stepped maple leaf in the local XY plane
			local c = CFrame.new(pos) * (face or CFrame.new()) * ang(0, 0, rot)
			B:block(R, v(size * 0.62, size * 0.62, 0.3), c * ang(0, 0, 45), col)
			B:block(R, v(size * 1.15, size * 0.36, 0.32), c * CFrame.new(0, size * 0.12, 0), col)
			B:block(R, v(size * 0.36, size * 1.0, 0.32), c * CFrame.new(0, size * 0.2, 0), col)
		end
		-- garlands on both faces: pillar -> sign frame, sagging
		B:sym(function(_, s)
			for _, f in { -1, 1 } do
				local x0, x1, y, sag = 33.5, 16.2, 24.6, 3.0
				local z = f * (BD / 2 + 0.55)
				local n = 7
				local prev
				for i = 0, n do
					local t = i / n
					local p = v(x0 + (x1 - x0) * t, y - sag * 4 * t * (1 - t), z)
					if prev then
						B:bar(R, prev, p, 0.3, 0.3, TWINE_DK)
					end
					if i > 0 and i < n then
						maple(p + v(0, -0.5, f * 0.2), 1.6 + ((i % 3) * 0.2), (i * 37) % 60 - 30, leafPal[(i + (f > 0 and 2 or 0)) % 6 + 1])
					end
					prev = p
				end
			end
		end)

		---------------------------------------------------------------- sign
		local SY = 23.4
		local SZ = -BD / 2 - 1.1
		B:block(R, v(28, 5.5, 1), cf(0, SY, SZ), SIGN, { name = "Sign" })
		B:block(R, v(27, 5, 0.8), cf(0, SY, -BD / 2 - 0.35), WOOD_DK)
		local FZ = SZ - 0.25
		B:block(R, v(31, 1.3, 1.6), cf(0, SY + 3.4, FZ), WOOD_DK)
		B:block(R, v(31, 1.3, 1.6), cf(0, SY - 3.4, FZ), WOOD_DK)
		B:block(R, v(1.5, 5.5, 1.6), cf(-14.75, SY, FZ), WOOD_DK)
		B:block(R, v(1.5, 5.5, 1.6), cf(14.75, SY, FZ), WOOD_DK)
		B:block(R, v(31.1, 0.3, 1.65), cf(0, SY + 3.9, FZ), WOOD)
		-- twine-wrapped corners
		for _, x in { -14.75, 14.75 } do
			for _, y in { SY + 3.4, SY - 3.4 } do
				B:block(R, v(2.0, 1.5, 1.9), cf(x, y, FZ), TWINE)
				B:block(R, v(2.05, 0.3, 1.95), cf(x, y + 0.4, FZ), TWINE_DK)
				B:block(R, v(2.05, 0.3, 1.95), cf(x, y - 0.4, FZ), TWINE_DK)
			end
		end
		-- a few leaves tucked on the frame corners
		maple(v(-15.8, SY + 4.4, FZ - 0.6), 1.8, 20, LF_RED)
		maple(v(-13.6, SY + 4.6, FZ - 0.7), 1.4, -15, LF_GOLD)
		maple(v(15.8, SY + 4.4, FZ - 0.6), 1.8, -20, LF_OR)
		maple(v(13.6, SY + 4.6, FZ - 0.7), 1.4, 15, LF_RED_DK)

		-- back plaque: crossed pitchforks behind a corn cob
		local bz = BD / 2 + 0.35
		B:block(R, v(20, 4.4, 0.4), cf(0, LY, bz), WOOD_LT)
		B:block(R, v(20.6, 0.5, 0.6), cf(0, LY + 2.3, bz), WOOD_DK)
		B:block(R, v(20.6, 0.5, 0.6), cf(0, LY - 2.3, bz), WOOD_DK)
		for _, k in { -1, 1 } do
			local a = v(k * 6, LY - 1.6, bz + 0.35)
			local b = v(-k * 3.5, LY + 1.6, bz + 0.35)
			B:bar(R, a, b, 0.4, 0.3, WOOD_DK)
			local hb = b + (b - a).Unit * 0.2
			B:block(R, v(1.8, 0.3, 0.3), CFrame.new(hb) * ang(0, 0, math.deg(math.atan2(b.Y - a.Y, b.X - a.X)) - 90), IRON)
			for t = -1, 1 do
				local d = (b - a).Unit
				local nrm = v(-d.Y, d.X, 0)
				B:bar(R, hb + nrm * (t * 0.7), hb + nrm * (t * 0.7) + d * 1.3, 0.22, 0.25, IRON)
			end
		end
		B:block(R, v(5.5, 1.6, 0.6), cf(0, LY, bz + 0.6), EAR_Y)
		B:block(R, v(0.3, 1.65, 0.65), cf(-1.2, LY, bz + 0.6), EAR_O)
		B:block(R, v(0.3, 1.65, 0.65), cf(1.2, LY, bz + 0.6), EAR_O)
		B:block(R, v(2.2, 1.2, 0.5), cf(3.6, LY + 0.5, bz + 0.6, 0, 0, 20), "#e8d79a")
		B:block(R, v(2.2, 1.2, 0.5), cf(3.6, LY - 0.5, bz + 0.6, 0, 0, -20), "#d6c47c")

		---------------------------------------------------------------- jack-o'-lantern crown
		local function jack(pos, w, h, d, ry, mood, lift)
			local c = CFrame.new(pos) * ang(0, ry or 0, 0)
			local cfc = c * CFrame.new(0, lift or 0, 0)
			-- body: core + rounded side lobes + ribs
			B:block(R, v(w, h, d), c, PUMP)
			B:block(R, v(w + 0.6, h * 0.7, d * 0.8), c, PUMP)
			B:block(R, v(w * 0.8, h + 0.4, d * 0.8), c, PUMP_LT)
			B:block(R, v(w * 0.2, h + 0.45, d + 0.1), c * CFrame.new(-w * 0.28, 0, 0), PUMP_DK)
			B:block(R, v(w * 0.2, h + 0.45, d + 0.1), c * CFrame.new(w * 0.28, 0, 0), PUMP_DK)
			B:block(R, v(w * 0.85, 0.4, d * 0.85), c * CFrame.new(0, -h / 2 - 0.1, 0), PUMP_DK)
			-- stem + leaf
			B:block(R, v(0.8, 1.2, 0.8), c * CFrame.new(0, h / 2 + 0.7, 0) * ang(0, 0, 12), STEM)
			B:block(R, v(0.9, 0.4, 0.9), c * CFrame.new(0, h / 2 + 0.25, 0), STEM_DK)
			-- carved faces on both sides
			for _, f in { -1, 1 } do
				local fz = f * (d / 2 + 0.06)
				local u = h / 4.1
				-- eyes (stepped triangles)
				for _, ex in { -1.3, 1.3 } do
					B:block(R, v(1.5 * u + 0.25, 1.1 * u + 0.25, 0.2), cfc * CFrame.new(ex * u, 0.9 * u, fz), RIM)
					B:block(R, v(1.1 * u, 0.75 * u, 0.24), cfc * CFrame.new(ex * u, 0.8 * u, fz + f * 0.03), CARVE, { mat = "Neon" })
				end
				-- nose
				B:block(R, v(0.6 * u, 0.6 * u, 0.24), cfc * CFrame.new(0, 0, fz + f * 0.03) * ang(0, 0, 45), CARVE, { mat = "Neon" })
				-- grin with teeth
				B:block(R, v(4.0 * u + 0.25, 1.1 * u + 0.25, 0.2), cfc * CFrame.new(0, -1.3 * u, fz), RIM)
				B:block(R, v(4.0 * u, 0.6 * u, 0.24), cfc * CFrame.new(0, -1.15 * u, fz + f * 0.03), CARVE, { mat = "Neon" })
				if mood == "grin" then
					B:block(R, v(0.6 * u, 0.5 * u, 0.24), cfc * CFrame.new(-2.2 * u, -0.85 * u, fz + f * 0.03), CARVE, { mat = "Neon" })
					B:block(R, v(0.6 * u, 0.5 * u, 0.24), cfc * CFrame.new(2.2 * u, -0.85 * u, fz + f * 0.03), CARVE, { mat = "Neon" })
				end
				B:block(R, v(0.7 * u, 0.4 * u, 0.26), cfc * CFrame.new(0, -1.45 * u, fz + f * 0.04), PUMP_LT)
			end
		end
		local CY = BY1 + 0.6
		-- bottom row
		jack(v(-8.2, CY + 1.7, 0.2), 7.4, 3.4, 4.8, 6, "grin", 0.35)
		jack(v(8.2, CY + 1.7, 0.2), 7.4, 3.4, 4.8, -6, "grin", 0.35)
		jack(v(0, CY + 1.75, 0.6), 8.0, 3.5, 5.0, 0, "o", 0.3)
		-- top pumpkin (biggest grin)
		jack(v(0, CY + 5.0, 0.3), 8.6, 3.4, 5.2, 0, "grin")
		-- little gourds at the stack feet
		for _, g in { { -12.9, LF_OR }, { 13.0, EAR_Y }, { 14.6, "#f4efe0" } } do
			B:block(R, v(1.8, 1.4, 1.8), cf(g[1], CY + 0.7, -0.6, 0, 20, 0), g[2])
			B:block(R, v(0.3, 0.6, 0.3), cf(g[1], CY + 1.6, -0.6, 0, 0, 20), STEM)
		end

		---------------------------------------------------------------- crows
		local function crow(pos, ry, scale)
			local k = scale or 1
			local c = CFrame.new(pos) * ang(0, ry, 0)
			B:block(R, v(1.6 * k, 1.5 * k, 2.2 * k), c * CFrame.new(0, 0.9 * k, 0), CROW)
			B:block(R, v(1.3 * k, 1.3 * k, 1.3 * k), c * CFrame.new(0, 2.1 * k, -0.7 * k), CROW)
			B:block(R, v(0.5 * k, 0.4 * k, 0.9 * k), c * CFrame.new(0, 2.0 * k, -1.7 * k), BEAK)
			for _, ex in { -1, 1 } do
				B:block(R, v(0.15, 0.45 * k, 0.45 * k), c * CFrame.new(ex * 0.66 * k, 2.3 * k, -0.95 * k), EYE)
				B:block(R, v(0.18, 0.22 * k, 0.22 * k), c * CFrame.new(ex * 0.68 * k, 2.28 * k, -1.02 * k), CROW_DK)
				-- folded wings
				B:block(R, v(0.3 * k, 1.1 * k, 2.0 * k), c * CFrame.new(ex * 0.85 * k, 1.0 * k, 0.2 * k) * ang(-10, 0, 0), CROW_LT)
				-- feet
				B:block(R, v(0.2, 0.5 * k, 0.5 * k), c * CFrame.new(ex * 0.35 * k, 0.05, -0.2 * k), BEAK)
			end
			-- tail
			B:block(R, v(1.0 * k, 0.3 * k, 1.4 * k), c * CFrame.new(0, 0.6 * k, 1.5 * k) * ang(20, 0, 0), CROW_DK)
			-- head tuft
			B:block(R, v(0.3 * k, 0.6 * k, 0.5 * k), c * CFrame.new(0, 2.9 * k, -0.6 * k) * ang(-20, 0, 0), CROW_DK)
		end
		-- twig perch beside the stack
		local PXC = -16.2
		B:block(R, v(0.7, 5.2, 0.7), cf(PXC, BY1 + 2.6 + 0.4, 0), WOOD_DK)
		B:block(R, v(4.4, 0.6, 0.6), cf(PXC, BY1 + 5.4, 0), WOOD)
		B:block(R, v(1.6, 0.4, 0.4), cf(PXC + 2.2, BY1 + 5.9, 0, 0, 0, 30), WOOD)
		B:block(R, v(0.9, 0.3, 0.2), cf(PXC + 2.8, BY1 + 6.4, 0, 0, 0, 10), LF_RED)
		B:block(R, v(2.0, 1.4, 2.0), cf(PXC, BY1 + 0.9, 0), WOOD_DK)
		crow(v(PXC - 0.9, BY1 + 5.7, 0), 25, 1)
		-- crow on top of the right corn shock
		crow(v(PX - 0.5, 30.4, 0.2), -60, 1.0)

		-- scattered leaves along the lintel top
		for i = 1, 8 do
			local x = (i % 2 == 0 and 1 or -1) * rnd(17, 31)
			maple(v(x, BY1 + 0.25, rnd(-1.8, 1.8)), rnd(1.2, 1.8), rnd(0, 90), leafPal[i % 6 + 1], ang(-90, 0, 0))
		end
		-- pumpkins sitting on the lintel near the pillars
		for _, x in { -24, 24 } do
			B:block(R, v(2.8, 2.0, 2.6), cf(x, BY1 + 1.0, 0.2), PUMP)
			B:block(R, v(2.0, 2.1, 2.8), cf(x, BY1 + 1.05, 0.2), PUMP_DK)
			B:block(R, v(0.4, 0.9, 0.4), cf(x, BY1 + 2.4, 0.2, 0, 0, -15), STEM)
		end
	end,
}
