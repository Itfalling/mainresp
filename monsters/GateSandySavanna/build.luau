--!nocheck
-- Sandy Savanna Gate (map stage gate, static landmark).
-- A grand sandstone gateway the player runs under at the start of the stage:
-- * two carved totem posts (|x| 33..43) on stepped sandstone plinths: four
--   painted animal faces stacked up each post (bear, owl, sun-mask, eagle),
--   separated by protruding stripe bands with turquoise / red diamonds, faces
--   carved on BOTH sides
-- * a thunderbird crowns each post: stepped head with a hooked beak and big
--   spread wings with red / cream / turquoise feather tips
-- * a thick sandstone lintel (y 19.6..27.6) painted with tribal stripes and
--   diamond chains; the stage-name "Sign" sits in a chunky wooden frame on
--   its front, a carved sun tablet on the back
-- * a big rising sun disc half-sunk in the lintel cap with a fan of rays
-- * bead strings with feathers hang from the wing tips; barrel cacti, rocks
--   and dry grass at the feet
-- Opening x -32..32 is clear up to y 19.6. Static landmark (Filler).
return {
	DisplayName = "Sandy Savanna Gate",
	Rarity = "Landmark",
	Filler = true,
	Element = "Sandy Savanna",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		local SAND_DK, SAND, SAND_LT, SAND_TOP = "#c48a45", "#d9a95c", "#e8c27a", "#f0d08e"
		local RED_DK, RED, TERRA, PEACH, CREAM = "#963f24", "#c4532c", "#d6683a", "#efae72", "#f7d6a0"
		local TURQ, TURQ_DK, TURQ_LT = "#2fa79a", "#1f7f76", "#6fd6c6"
		local OCHRE, OCHRE_DK = "#e8a838", "#c9852a"
		local INK, WHITE = "#3a2418", "#fff6e2"
		local SUN, SUN_LT, SUN_DK, SUN_GLOW = "#f2b048", "#ffe0a0", "#d9822e", "#ffd25a"
		local BEAK, BEAK_DK = "#ffb43a", "#e0812a"
		local WOOD, WOOD_DK = "#8a5a36", "#6a4228"
		local CAC_DK, CAC, CAC_LT = "#3f7d35", "#5aa848", "#7cc35a"
		local PINK, SPINE = "#ff7fb4", "#fbefcc"
		local GRASS, GRASS_DK, GRASS_LT = "#d9b84a", "#b8963a", "#f0d872"
		local SIGN = "#fbefd2"
		local NEON = { mat = "Neon" }

		local seed = 9061
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		local PX = 38 -- post centre |x|
		local PD = 8 -- post depth

		-- frame on a post face: side -1 = front (-Z), +1 = back. local -Z = outward
		local function faceAt(x, y, d, side)
			local base = CFrame.new(x, y, side * d / 2)
			if side == 1 then
				base = base * ang(0, 180, 0)
			end
			return function(lx, ly, out)
				return base * CFrame.new(lx, ly, -out)
			end
		end

		------------------------------------------------------------ plinths
		for _, sx in { 1, -1 } do
			local x = sx * PX
			B:block(R, v(12.4, 1.0, 11.0), cf(x + sx * 0.4, 0.5, 0), SAND_DK)
			B:block(R, v(11.6, 0.9, 10.0), cf(x + sx * 0.2, 1.45, 0), SAND)
			B:block(R, v(11.8, 0.3, 10.2), cf(x + sx * 0.2, 2.05, 0), RED)
			B:block(R, v(11.0, 0.6, 9.4), cf(x, 2.5, 0), SAND_LT)
			-- painted triangle teeth on the plinth faces
			for _, side in { -1, 1 } do
				local at = faceAt(x, 1.45, 10.0, side)
				for k = -1, 1 do
					B:block(R, v(1.1, 1.1, 0.2), at(k * 3.0, 0, 0.05) * ang(0, 0, 45), (k % 2 == 0) and TURQ or RED)
				end
			end
		end

		------------------------------------------------------------ totem posts
		-- segment: {y0, y1, width, depth, colour, dark, style}
		local SEGS = {
			{ 2.8, 8.2, 10.0, 8.0, RED, RED_DK, "bear" },
			{ 9.0, 14.4, 9.4, 7.6, TURQ, TURQ_DK, "owl" },
			{ 15.2, 20.6, 10.0, 8.0, OCHRE, OCHRE_DK, "sun" },
			{ 21.4, 26.0, 9.2, 7.4, TERRA, RED_DK, "eagle" },
		}
		local BANDS = { { 8.2, 9.0 }, { 14.4, 15.2 }, { 20.6, 21.4 } }

		local function eye(at, lx, ly, s, iris)
			B:block(R, v(1.8 * s, 1.8 * s, 0.4), at(lx, ly, 0.1), WHITE)
			B:block(R, v(1.3 * s, 1.3 * s, 0.4), at(lx, ly, 0.2) * ang(0, 0, 45), WHITE)
			B:block(R, v(0.9 * s, 0.9 * s, 0.3), at(lx, ly - 0.1 * s, 0.38), iris or INK)
		end

		for _, sx in { 1, -1 } do
			local x = sx * PX
			for _, s in SEGS do
				local y0, y1, w, d, col, dk, style = s[1], s[2], s[3], s[4], s[5], s[6], s[7]
				local h = y1 - y0
				local yc = (y0 + y1) / 2
				B:block(R, v(w, h, d), cf(x, yc, 0), col)
				-- darker carved side panels (outer X faces)
				B:block(R, v(w + 0.3, h - 1.2, d - 2.4), cf(x, yc, 0), dk)
				if style == "bear" then -- ears on the top corners
					B:block(R, v(1.8, 1.4, d - 3.0), cf(x - 3.9, y1 + 0.5, 0), RED_DK)
					B:block(R, v(1.8, 1.4, d - 3.0), cf(x + 3.9, y1 + 0.5, 0), RED_DK)
				end
				for _, side in { -1, 1 } do
					local at = faceAt(x, yc, d, side)
					if style == "bear" then
						B:block(R, v(7.4, 1.0, 0.6), at(0, 1.9, 0.1), RED_DK) -- brow
						eye(at, -2.2, 0.6, 1.0)
						eye(at, 2.2, 0.6, 1.0)
						B:block(R, v(3.4, 2.4, 1.6), at(0, -1.0, 0.6), PEACH) -- snout
						B:block(R, v(1.6, 0.9, 0.6), at(0, -0.2, 1.5), INK) -- nose
						B:block(R, v(5.6, 0.9, 0.5), at(0, -2.35, 0.1), INK) -- mouth
						for k = -1, 1 do
							B:block(R, v(0.8, 0.8, 0.4), at(k * 1.6, -2.15, 0.3), WHITE)
						end
					elseif style == "owl" then
						B:block(R, v(3.4, 3.4, 0.4), at(-2.1, 0.6, 0.05), CREAM)
						B:block(R, v(3.4, 3.4, 0.4), at(2.1, 0.6, 0.05), CREAM)
						B:block(R, v(2.6, 2.6, 0.4), at(-2.1, 0.6, 0.2) * ang(0, 0, 45), SUN)
						B:block(R, v(2.6, 2.6, 0.4), at(2.1, 0.6, 0.2) * ang(0, 0, 45), SUN)
						B:block(R, v(1.2, 1.2, 0.3), at(-2.1, 0.6, 0.45), INK)
						B:block(R, v(1.2, 1.2, 0.3), at(2.1, 0.6, 0.45), INK)
						B:block(R, v(1.3, 1.6, 1.6), at(0, -0.6, 0.7), BEAK) -- beak
						B:block(R, v(0.8, 1.0, 1.4), at(0, -1.7, 0.9), BEAK_DK)
						-- chest feather chevrons
						B:block(R, v(3.6, 0.5, 0.3), at(0, -2.2, 0.1), TURQ_LT)
					elseif style == "sun" then
						-- sun mask: rayed face with red cheek stripes
						B:block(R, v(5.4, 4.6, 0.5), at(0, 0, 0.1), SUN)
						B:block(R, v(4.4, 4.4, 0.5), at(0, 0, 0.15) * ang(0, 0, 45), SUN_DK)
						B:block(R, v(4.2, 3.6, 0.5), at(0, 0, 0.3), SUN_LT)
						B:block(R, v(1.0, 0.7, 0.3), at(-1.1, 0.6, 0.6), INK)
						B:block(R, v(1.0, 0.7, 0.3), at(1.1, 0.6, 0.6), INK)
						B:block(R, v(2.2, 0.5, 0.3), at(0, -0.9, 0.6), RED_DK)
						for _, cx in { -1, 1 } do
							B:block(R, v(0.4, 1.2, 0.3), at(cx * 1.65, -0.2, 0.6), RED)
							B:block(R, v(0.4, 1.2, 0.3), at(cx * 2.15, -0.2, 0.55), TURQ)
						end
					else -- eagle
						B:block(R, v(7.0, 0.8, 0.6), at(0, 1.4, 0.1), INK)
						B:block(R, v(2.2, 1.2, 0.5), at(-2.0, 0.5, 0.1), WHITE)
						B:block(R, v(2.2, 1.2, 0.5), at(2.0, 0.5, 0.1), WHITE)
						B:block(R, v(0.9, 0.9, 0.3), at(-1.7, 0.4, 0.35), INK)
						B:block(R, v(0.9, 0.9, 0.3), at(1.7, 0.4, 0.35), INK)
						B:block(R, v(1.8, 1.4, 1.8), at(0, -0.4, 0.8), BEAK)
						B:block(R, v(1.4, 1.2, 1.4), at(0, -1.4, 1.3), BEAK_DK) -- hooked tip
					end
				end
			end
			-- protruding stripe bands with diamonds
			for bi, b in BANDS do
				local yc = (b[1] + b[2]) / 2
				B:block(R, v(10.8, b[2] - b[1], 8.8), cf(x, yc, 0), CREAM)
				B:block(R, v(11.0, 0.22, 9.0), cf(x, b[1] + 0.11, 0), RED_DK)
				for _, side in { -1, 1 } do
					local at = faceAt(x, yc, 8.8, side)
					for k = -1, 1 do
						B:block(R, v(0.62, 0.62, 0.25), at(k * 3.0, 0, 0.05) * ang(0, 0, 45), ((k + bi) % 2 == 0) and TURQ or RED)
					end
				end
			end

			---------------------------------------------------- thunderbird
			local hy = 26.0
			B:block(R, v(6.4, 1.2, 6.0), cf(x, hy + 0.6, 0), RED_DK) -- shoulders
			B:block(R, v(5.0, 3.6, 5.2), cf(x, hy + 2.8, 0), TERRA) -- head
			B:block(R, v(4.0, 1.2, 4.4), cf(x, hy + 5.0, 0), RED) -- crown
			B:block(R, v(1.0, 1.4, 3.0), cf(x, hy + 6.2, 0.4), TURQ) -- crest
			B:block(R, v(0.8, 1.0, 1.6), cf(x, hy + 6.9, 1.4), TURQ_LT)
			for _, side in { -1, 1 } do
				local at = faceAt(x, hy + 2.8, 5.2, side)
				B:block(R, v(1.2, 1.0, 0.4), at(-1.3, 0.6, 0.1), WHITE)
				B:block(R, v(1.2, 1.0, 0.4), at(1.3, 0.6, 0.1), WHITE)
				B:block(R, v(0.6, 0.6, 0.3), at(-1.2, 0.5, 0.3), INK)
				B:block(R, v(0.6, 0.6, 0.3), at(1.2, 0.5, 0.3), INK)
				B:block(R, v(4.6, 0.5, 0.3), at(0, 1.4, 0.05), INK)
				if side == -1 then
					B:block(R, v(1.6, 1.2, 1.6), at(0, -0.3, 0.7), BEAK)
					B:block(R, v(1.2, 1.2, 1.0), at(0, -1.0, 1.2), BEAK_DK)
				else
					-- back: painted feather chevrons
					for k = -1, 1 do
						B:block(R, v(1.0, 1.0, 0.3), at(k * 1.4, -0.6, 0.05) * ang(0, 0, 45), (k == 0) and TURQ or RED)
					end
				end
			end
			-- spread wings (outward + inward), stepped feathers rising to the tips
			for _, dir in { 1, -1 } do -- 1 = outward, -1 = toward centre
				local wx = sx * dir
				local reach = (dir == 1) and 6.0 or 6.6
				local steps = 4
				for k = 1, steps do
					local t = k / steps
					local cx = x + wx * (2.6 + t * reach)
					local cy = hy + 1.2 + t * 2.4
					local len = 3.2 + (1 - t) * 1.8
					B:block(R, v(reach / steps + 0.4, 1.2, 4.6 - t * 0.6), cf(cx, cy, 0), (k % 2 == 0) and TERRA or RED)
					-- hanging feather tips under each step
					local tipCol = ({ CREAM, TURQ, CREAM, RED_DK })[k]
					B:block(R, v(reach / steps * 0.8, len, 0.6), cf(cx, cy - len / 2 - 0.4, -1.4), tipCol)
					B:block(R, v(reach / steps * 0.8, len, 0.6), cf(cx, cy - len / 2 - 0.4, 1.4), tipCol)
				end
				-- wing tip
				local tx = x + wx * (2.6 + reach + 0.9)
				B:block(R, v(1.4, 2.2, 3.8), cf(tx, hy + 4.4, 0), RED_DK)
				B:block(R, v(1.0, 1.4, 2.8), cf(tx + wx * 0.7, hy + 5.4, 0), TURQ)
			end

			---------------------------------------------------- bead strings
			for si, st in { { x - sx * 9.8, 29.6, 8.0, 4.3 }, { x + sx * 9.3, 29.5, 11.0, 2.6 } } do
				local bx, by, len, zo = st[1], st[2], st[3], st[4]
				B:block(R, v(0.5, 0.5, zo * 2 + 0.6), cf(bx, by + 0.1, 0), WOOD_DK) -- peg through the wing tip
				for _, zz in { -zo, zo } do
					local n = math.floor(len / 0.9)
					B:block(R, v(0.14, len - 1.6, 0.14), cf(bx, by - (len - 1.6) / 2, zz), WOOD_DK)
					for k = 2, n - 2, 3 do
						local cols = { TURQ, RED, SUN, WHITE }
						B:block(R, v(0.6, 0.6, 0.6), cf(bx, by - k * 0.9, zz, 0, 45, 0), cols[(k // 3) % 4 + 1])
					end
					-- feather at the end
					local fy = by - len + 0.7
					B:block(R, v(0.7, 1.8, 0.2), cf(bx, fy, zz, 0, 0, 8), WHITE)
					B:block(R, v(0.72, 0.6, 0.22), cf(bx - 0.05, fy - 0.8, zz, 0, 0, 8), RED)
				end
			end
		end

		------------------------------------------------------------ lintel
		local LY0, LY1 = 19.6, 26.6
		local LZ = 3.2 -- half depth
		B:block(R, v(68.0, LY1 - LY0, LZ * 2), cf(0, (LY0 + LY1) / 2, 0), SAND_LT)
		B:block(R, v(68.4, 0.8, LZ * 2 + 0.4), cf(0, LY0 + 0.4, 0), RED) -- red soffit band
		B:block(R, v(70.0, 1.0, LZ * 2 + 1.0), cf(0, LY1 + 0.5, 0), SAND) -- cap
		B:block(R, v(70.4, 0.3, LZ * 2 + 1.3), cf(0, LY1 + 0.15, 0), SAND_DK)
		-- painted stripes + diamond chains on both faces, either side of the sign
		for _, side in { -1, 1 } do
			local zf = side * LZ
			for _, sx in { 1, -1 } do
				local x0, x1 = 16.4, 33.0
				local xm, wl = sx * (x0 + x1) / 2, x1 - x0
				B:block(R, v(wl, 0.7, 0.3), cf(xm, 21.4, zf), TURQ)
				B:block(R, v(wl, 0.5, 0.3), cf(xm, 22.2, zf + side * 0.02), INK)
				B:block(R, v(wl, 0.7, 0.3), cf(xm, 25.4, zf), RED)
				B:block(R, v(wl, 0.3, 0.3), cf(xm, 24.7, zf + side * 0.02), INK)
				for k = 0, 5 do
					local dx = sx * (x0 + 1.5 + k * 2.75)
					B:block(R, v(1.5, 1.5, 0.3), cf(dx, 23.45, zf + side * 0.04, 0, 0, 45), (k % 2 == 0) and RED_DK or TURQ_DK)
				end
			end
		end
		-- back face: carved sun tablet where the sign is on the front
		do
			local zb = LZ
			B:block(R, v(14, 5.0, 0.4), cf(0, 23.2, zb + 0.1), RED_DK)
			B:block(R, v(13, 4.0, 0.4), cf(0, 23.2, zb + 0.3), PEACH)
			B:block(R, v(2.8, 2.8, 0.4), cf(0, 23.2, zb + 0.5), SUN)
			B:block(R, v(2.6, 2.6, 0.4), cf(0, 23.2, zb + 0.55, 0, 0, 45), SUN_DK)
			B:block(R, v(1.8, 1.8, 0.3), cf(0, 23.2, zb + 0.75), SUN_LT)
			for k = -2, 2 do
				if k ~= 0 then
					B:block(R, v(1.6, 0.6, 0.3), cf(k * 2.6, 23.2, zb + 0.5), (k % 2 == 0) and TURQ or RED)
				end
			end
		end

		------------------------------------------------------------ the Sign
		local SY, SW, SH = 23.4, 28.0, 5.4
		local SZ = -LZ - 0.5 -- sign centre (front face at -LZ - 1.0)
		B:block(R, v(SW, SH, 1.0), cf(0, SY, SZ), SIGN, { name = "Sign" })
		local FZ = SZ - 0.15
		local FD = 1.6
		B:block(R, v(SW + 3.0, 1.3, FD), cf(0, SY + SH / 2 + 0.65, FZ), WOOD) -- top
		B:block(R, v(SW + 3.0, 1.1, FD), cf(0, SY - SH / 2 - 0.55, FZ), WOOD) -- bottom
		B:block(R, v(1.5, SH, FD), cf(SW / 2 + 0.75, SY, FZ), WOOD)
		B:block(R, v(1.5, SH, FD), cf(-SW / 2 - 0.75, SY, FZ), WOOD)
		for _, sx in { 1, -1 } do
			B:block(R, v(2.0, 2.0, FD + 0.3), cf(sx * (SW / 2 + 0.9), SY + SH / 2 + 0.65, FZ), RED) -- corner caps
			B:block(R, v(2.0, 1.8, FD + 0.3), cf(sx * (SW / 2 + 0.9), SY - SH / 2 - 0.55, FZ), RED)
			B:block(R, v(1.0, 1.0, FD + 0.5), cf(sx * (SW / 2 + 0.9), SY + SH / 2 + 0.65, FZ, 0, 0, 45), TURQ)
			B:block(R, v(0.9, 0.9, FD + 0.5), cf(sx * (SW / 2 + 0.9), SY - SH / 2 - 0.55, FZ, 0, 0, 45), TURQ)
		end

		------------------------------------------------------------ rising sun
		-- stepped tiers climbing to the sun
		B:block(R, v(46, 1.0, LZ * 2 - 0.2), cf(0, LY1 + 1.5, 0), SAND_LT)
		B:block(R, v(46.4, 0.3, LZ * 2 + 0.1), cf(0, LY1 + 1.15, 0), RED)
		B:block(R, v(26, 1.0, LZ * 2 - 0.8), cf(0, LY1 + 2.5, 0), SAND)
		B:block(R, v(26.4, 0.3, LZ * 2 - 0.5), cf(0, LY1 + 2.15, 0), TURQ)
		local SUNY = 27.0
		B:block(R, v(7.8, 7.8, 5.0), cf(0, SUNY, 0), SUN_DK)
		B:block(R, v(7.4, 7.4, 4.8), cf(0, SUNY, 0, 0, 0, 45), SUN_DK)
		B:block(R, v(6.8, 6.8, 6.0), cf(0, SUNY, 0), SUN)
		B:block(R, v(6.6, 6.6, 5.8), cf(0, SUNY, 0, 0, 0, 45), SUN)
		B:block(R, v(5.2, 5.2, 6.6), cf(0, SUNY + 0.4, 0), SUN_LT)
		B:block(R, v(3.8, 3.8, 6.4), cf(0, SUNY + 0.4, 0, 0, 0, 45), SUN_LT)
		B:block(R, v(1.2, 1.2, 7.0), cf(0, SUNY + 3.2, 0, 0, 0, 45), SUN_GLOW, NEON)
		for k = -4, 4 do
			local a = k * 22.5
			local long = (k % 2 == 0)
			local c = CFrame.new(0, SUNY, 0) * ang(0, 0, a) * CFrame.new(0, long and 5.7 or 5.3, 0)
			B:block(R, v(long and 1.5 or 1.0, long and 2.4 or 1.6, 2.6), c, long and SUN_LT or RED)
			if long then
				B:block(R, v(0.9, 0.9, 2.8), c * CFrame.new(0, 0.2, 0) * ang(0, 0, 45), SUN)
			end
		end
		-- sun face (front + back): eyes and a smile
		for _, side in { -1, 1 } do
			local z = side * 3.35
			B:block(R, v(0.7, 1.0, 0.2), cf(-1.1, SUNY + 1.9, z), INK)
			B:block(R, v(0.7, 1.0, 0.2), cf(1.1, SUNY + 1.9, z), INK)
			B:block(R, v(0.7, 0.6, 0.2), cf(-2.0, SUNY + 0.9, z), RED)
			B:block(R, v(0.7, 0.6, 0.2), cf(2.0, SUNY + 0.9, z), RED)
			B:block(R, v(1.8, 0.5, 0.2), cf(0, SUNY + 0.6, z), RED_DK)
		end

		------------------------------------------------------------ feet dressing
		local function tuft(x, z, s)
			local base = CFrame.new(x, 0, z) * ang(0, rnd(0, 90), 0)
			B:block(R, v(0.4, 1.8 * s, 0.4), base * CFrame.new(0, 0.9 * s, 0), GRASS)
			B:block(R, v(0.36, 1.5 * s, 0.36), base * CFrame.new(0.4, 0.7 * s, 0) * ang(0, 0, -25), GRASS_LT)
			B:block(R, v(0.36, 1.4 * s, 0.36), base * CFrame.new(-0.4, 0.65 * s, 0.05) * ang(0, 0, 25), GRASS_DK)
		end
		local function barrel(x, z, k)
			local y = 0
			for _, t in { { 0.6, 2.0, CAC_DK }, { 1.4, 2.5, CAC }, { 1.0, 2.3, CAC }, { 0.6, 1.7, CAC_LT } } do
				local th, w = t[1] * k, t[2] * k
				B:block(R, v(w, th + 0.02, w), cf(x, y + th / 2, z), t[3])
				B:block(R, v(w * 0.86, th + 0.04, w * 0.86), cf(x, y + th / 2, z, 0, 45, 0), CAC_DK)
				y += th
			end
			B:block(R, v(0.9 * k, 0.5 * k, 0.9 * k), cf(x, y + 0.2 * k, z, 0, 45, 0), PINK)
		end
		local function rock(x, z, s, yaw)
			local c = CFrame.new(x, 0, z) * ang(0, yaw, 0)
			B:block(R, v(2.4 * s, 1.2 * s, 2.0 * s), c * CFrame.new(0, 0.6 * s, 0), RED)
			B:block(R, v(1.6 * s, 0.8 * s, 1.4 * s), c * CFrame.new(0.2 * s, 1.5 * s, 0) * ang(0, 15, 0), PEACH)
		end
		for _, sx in { 1, -1 } do
			barrel(sx * 46.0, -3.0, 1.0)
			barrel(sx * 45.6, 3.4, 0.75)
			rock(sx * 46.4, 0.4, 0.9, 20 * sx)
			tuft(sx * 36.4, -5.0, 1.0)
			tuft(sx * 41.0, 5.0, 0.9)
			tuft(sx * 47.0, -5.0, 1.0)
		end
	end,
}
