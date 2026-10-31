--!nocheck
-- Thorny Woods Gate (Map landmark, stage 4 gate). Two gnarled old tree trunks
-- (x = +-32..44) whose branches braid together into a great elliptical arch over
-- the whole 64-stud run lane.
-- * Trunks: stepped, slightly twisted bark segments in three browns with dark
--   bark ridges, a knothole, flaring roots and mossy caps; leafy canopy clumps
--   crown each trunk top.
-- * Arch: three branches per side twist around a shared elliptical centreline
--   and interlace at the apex; moss rides on top, leaf clumps sit at the apex and
--   the shoulders.
-- * Thorny briar vines (dark green with cream thorns) spiral up both trunks and
--   along the arch, blooming with red and pink roses.
-- * Four iron lanterns with warm neon cores hang from the arch.
-- * The plain parchment "Sign" hangs from the apex on two ropes in a chunky log
--   frame with moss and roses (the map tool adds the stage name on its -Z face);
--   its back is a dark plank board with a carved rose.
-- Opening: completely clear for |x| < 32, y < 19 (lowest part: sign frame 19.35).
-- Static Filler landmark: no scripts, no effects.
return {
	DisplayName = "Thorny Woods Gate",
	Rarity = "Landmark",
	Filler = true,
	Element = "Thorny Woods",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"
		local rad = math.rad

		local BARK, BARK_DK, BARK_LT, BARK_DD = "#6b4a32", "#553a26", "#7f5a3c", "#3e2a1b"
		local MOSS, MOSS_DK, MOSS_LT = "#5fae3a", "#3f8a2c", "#86c94a"
		local LEAF_DK, LEAF, LEAF_MID, LEAF_LT = "#1d6a35", "#26803e", "#33984a", "#52b457"
		local VINE, VINE_DK = "#3f7a2e", "#2c5a22"
		local THORN = "#ecdfb8"
		local ROSE, ROSE_DK, ROSE_LT = "#d8203e", "#9a1430", "#ff5a77"
		local PINK, PINK_DK, PINK_LT = "#ff86b3", "#e8588f", "#ffc4da"
		local IRON, IRON_LT = "#3a3640", "#5a5662"
		local GLOW = "#ffcf5a"
		local ROPE = "#c9a46a"
		local SIGN = "#f6ecd4"
		local STONE, STONE_DK = "#8d8a80", "#686660"

		local seed = 904
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function look(p, dir)
			local d = dir.Unit
			return (P.aim(p - d, p + d))
		end

		-- arch centreline (right side), theta 0 = trunk top, pi/2 = apex
		local AX, AY0, AH = 36.5, 17.2, 12.2
		local function arch(th)
			local p = v(AX * math.cos(th), AY0 + AH * math.sin(th), 0)
			local t = v(-AX * math.sin(th), AH * math.cos(th), 0).Unit
			local n = v(math.cos(th) / AX, math.sin(th) / AH, 0).Unit
			return p, t, n
		end

		---------------------------------------------------------------- trunks
		B:sym(function(side, s)
			local TX = 38.2
			-- roots (stay outside the lane: x >= 32)
			local roots = { { 0.0, 5.6 }, { 0.9, 5.4 }, { 1.7, 5.6 }, { 2.6, 5.4 }, { 3.5, 5.2 }, { 4.4, 5.4 }, { 5.4, 5.6 } }
			for i, r in roots do
				local a = r[1]
				local ca, sa = math.cos(a), math.sin(a)
				local foot = v(TX + ca * r[2], 0.45, sa * r[2] * 0.88)
				if foot.X < 32.8 then
					foot = v(32.8, foot.Y, foot.Z)
				end
				B:bar(R, v(TX + ca * 2.4, 3.2, sa * 2.4), foot, 1.8, 1.4, (i % 2 == 0) and BARK_DK or BARK, { up = v(0, 1, 0) })
				B:block(R, v(1.4, 0.9, 1.4), cf(foot.X, 0.45, foot.Z, 0, math.deg(a), 0), BARK_DD)
			end
			-- stacked gnarled trunk segments
			local segs = { { 0, 4, 8.6 }, { 4, 8, 8.0 }, { 8, 12, 7.4 }, { 12, 16, 7.0 }, { 16, 20, 7.2 }, { 20, 24.5, 7.8 } }
			for i, sg in segs do
				local y0, y1, w = sg[1], sg[2], sg[3]
				local x = TX + ((i % 2 == 0) and 0.3 or -0.2)
				local ry = (i % 2 == 0) and 7 or -6
				B:block(R, v(w, y1 - y0 + 0.3, w * 0.92), cf(x, (y0 + y1) / 2, 0, 0, ry, 0), (i % 3 == 0) and BARK or ((i % 3 == 1) and BARK_LT or BARK))
				-- bark ridges on all four faces
				for _, f in { -1, 1 } do
					B:block(R, v(0.7, y1 - y0 + 0.2, 0.4), cf(x + w * 0.18 * f, (y0 + y1) / 2, f * (w * 0.46 + 0.1), 0, ry, 0), BARK_DK)
					B:block(R, v(0.4, y1 - y0 + 0.2, 0.7), cf(x + f * (w / 2 + 0.1), (y0 + y1) / 2, -f * w * 0.15, 0, ry, 0), BARK_DD)
				end
			end
			-- knothole on the front and back
			for _, f in { -1, 1 } do
				B:block(R, v(2.4, 3.0, 0.6), cf(TX + 0.4, 17.5, f * 3.6), BARK_DD)
				B:block(R, v(1.6, 2.2, 0.62), cf(TX + 0.4, 17.4, f * 3.65), "#1c130c")
				B:block(R, v(2.8, 0.6, 0.8), cf(TX + 0.4, 19.2, f * 3.55), BARK_LT)
			end
			-- shoulder: where the arch leaves the trunk
			B:block(R, v(6.6, 3.2, 6.2), cf(36.4, 20.6, 0, 0, 0, 22), BARK)
			B:block(R, v(5.0, 2.6, 5.4), cf(35.2, 22.4, 0, 0, 0, 40), BARK_LT)
			-- outer limb up to the canopy
			B:bar(R, v(39.5, 23.0, 0.5), v(41.5, 29.5, 1.2), 3.2, 3.0, BARK_DK)
			B:bar(R, v(38.0, 23.5, -0.4), v(37.4, 28.5, -1.8), 2.8, 2.6, BARK)
			-- mossy caps on the trunk shoulders
			B:block(R, v(4.6, 0.6, 4.2), cf(40.6, 24.95, 0.6, 0, 10, 0), MOSS)
			B:block(R, v(3.0, 0.5, 2.8), cf(41.2, 25.3, -1.2, 0, -15, 0), MOSS_LT)
			-- canopy clump on the trunk top
			local clump = {
				{ 39.8, 30.6, 0.0, 4.6, LEAF }, { 42.6, 29.4, 1.6, 3.6, LEAF_DK }, { 37.4, 29.6, -1.9, 3.8, LEAF_MID },
				{ 40.4, 31.8, -1.5, 3.0, LEAF_LT }, { 43.0, 28.0, -1.9, 2.8, LEAF_MID }, { 36.6, 31.0, 1.8, 3.2, LEAF },
				{ 39.2, 27.8, 2.6, 3.0, LEAF_DK }, { 41.2, 27.6, -3.0, 2.6, LEAF },
			}
			for _, c in clump do
				B:block(R, v(c[4] * 1.15, c[4] * 1.15, c[4] * 1.15), cf(c[1] - 0.3, c[2] - 0.6, c[3] * 0.9, rnd(-20, 20), rnd(0, 90), rnd(-20, 20)), c[5])
			end
			-- briar vine spiralling up the trunk with thorns + roses
			local prev
			for i = 0, 16 do
				local t = i / 16
				local a = t * math.pi * 3.2 + 0.5
				local y = 1.0 + t * 22.5
				local r = 4.4 - t * 0.4
				local p = v(TX + math.cos(a) * r, y, math.sin(a) * r * 0.92)
				if p.X < 32.4 then
					p = v(32.4, p.Y, p.Z)
				end
				if prev then
					B:bar(R, prev, p, 0.55, 0.55, (i % 2 == 0) and VINE or VINE_DK)
				end
				if i % 2 == 1 then
					local out = v(math.cos(a), 0.3, math.sin(a)).Unit
					B:block(R, v(0.3, 0.3, 0.6), look(p + out * 0.45, out), THORN)
				end
				prev = p
			end
		end)

		---------------------------------------------------------------- braided arch branches
		local cols = { BARK, BARK_DK, BARK_LT }
		local Z = v(0, 0, 1)
		local NS = 14
		B:sym(function(side, s)
			-- thick core
			local prev
			for i = 0, 8 do
				local p = arch((math.pi / 2) * i / 8)
				if prev then
					B:bar(R, prev, p + (p - prev).Unit * 0.6, 2.6, 2.6, BARK_DD)
				end
				prev = p
			end
			-- three twisting branches
			for k = 0, 2 do
				local last
				for i = 0, NS do
					local th = (math.pi / 2) * i / NS
					local p, t, n = arch(th)
					local phi = k * rad(120) + th * 4.2 + (s < 0 and rad(60) or 0)
					local rr = 1.55 - 0.3 * (i / NS)
					local q = p + (n * math.cos(phi) + Z * math.sin(phi)) * rr
					if last then
						local w = 1.7 - 0.5 * (i / NS)
						B:bar(R, last, q + (q - last).Unit * 0.3, w, w, cols[(i + k) % 3 + 1])
					end
					last = q
				end
				-- branch tip overshoots past the apex and curls up
				local p = arch(math.pi / 2)
				local phi = k * rad(120) + (math.pi / 2) * 4.2 + (s < 0 and rad(60) or 0)
				local q = p + (v(0, 1, 0) * math.cos(phi) + Z * math.sin(phi)) * 1.0
				B:bar(R, q, q + v(-3.2, 0.6 + k * 0.4, 0), 0.7, 0.7, cols[k + 1])
			end
			-- moss riding on top of the arch
			for _, th in { 0.25, 0.55, 0.85, 1.15, 1.42 } do
				local p, t, n = arch(th)
				local f = look(p + n * 1.3, t)
				B:block(R, v(1.8, 0.5, 2.6), f, (th > 0.8) and MOSS or MOSS_LT)
			end
			-- briar vine looping along the arch
			local lastv
			for i = 0, 18 do
				local th = (math.pi / 2) * i / 18
				local p, t, n = arch(th)
				local phi = th * 7 + 1.0
				local q = p + (n * math.cos(phi) + Z * math.sin(phi)) * 2.3
				if lastv then
					B:bar(R, lastv, q, 0.45, 0.45, (i % 2 == 0) and VINE or VINE_DK)
				end
				if i % 3 == 1 then
					local out = (n * math.cos(phi) + Z * math.sin(phi)).Unit
					B:block(R, v(0.3, 0.3, 0.55), look(q + out * 0.4, out), THORN)
				end
				lastv = q
			end
			-- leaf clumps on the arch shoulder
			for _, c in { { 0.42, 1.8, 3.2, LEAF_MID }, { 0.5, -1.6, 2.8, LEAF }, { 0.95, 1.4, 2.6, LEAF_LT }, { 0.78, -1.5, 2.4, LEAF_MID }, { 1.22, 0.4, 2.4, LEAF } } do
				local p, t, n = arch(c[1])
				B:block(R, v(c[3], c[3], c[3]), CFrame.new(p + n * 1.6 + Z * c[2]) * ang(rnd(-25, 25), rnd(0, 90), rnd(-25, 25)), c[4])
			end
		end)
		-- hanging ivy strands under the arch
		B:sym(function()
			for i, hx in { 22.5, 29.5 } do
				local th = math.acos(hx / AX)
				local p = arch(th)
				local z = (i == 1) and 1.0 or -1.0
				local y = p.Y - 1.6
				local len = 2.6
				B:block(R, v(0.3, len, 0.3), cf(hx, y - len / 2, z), VINE_DK)
				B:block(R, v(1.0, 0.8, 0.5), cf(hx + 0.3, y - 0.8, z, 0, 0, 25), LEAF_LT)
				B:block(R, v(1.0, 0.8, 0.5), cf(hx - 0.3, y - 1.8, z, 0, 0, -25), LEAF_MID)
				B:block(R, v(0.9, 0.7, 0.5), cf(hx, y - len - 0.1, z, 0, 0, 45), LEAF)
			end
		end)
		-- apex leaf crown + braid knot
		local apex = v(0, AY0 + AH, 0)
		B:block(R, v(3.2, 2.6, 3.0), CFrame.new(apex) * ang(0, 45, 0), BARK_DK)
		B:block(R, v(2.6, 2.2, 2.6), CFrame.new(apex + v(0, 0.6, 0)) * ang(15, 0, 20), BARK)
		for _, c in { { -2.6, 31.9, 0.6, 3.2, LEAF }, { 2.4, 31.7, -0.6, 3.0, LEAF_MID }, { 0, 31.9, 1.4, 2.6, LEAF_LT }, { -5.2, 31.0, -1.0, 2.4, LEAF_DK }, { 5.0, 31.1, 1.0, 2.4, LEAF } } do
			B:block(R, v(c[4], c[4], c[4]), cf(c[1], c[2], c[3], rnd(-20, 20), rnd(0, 90), rnd(-20, 20)), c[5])
		end

		---------------------------------------------------------------- roses
		local function rose(p, k, pal)
			local c1, c2, c3 = ROSE_DK, ROSE, ROSE_LT
			if pal == "pink" then
				c1, c2, c3 = PINK_DK, PINK, PINK_LT
			end
			local r0 = CFrame.new(p) * ang(rnd(-20, 20), rnd(0, 90), rnd(-20, 20))
			B:block(R, v(1.3 * k, 1.0 * k, 1.3 * k), r0, c1)
			B:block(R, v(1.1 * k, 0.9 * k, 1.1 * k), r0 * CFrame.new(0, 0.25 * k, 0) * ang(0, 45, 0), c2)
			B:block(R, v(0.55 * k, 0.5 * k, 0.55 * k), r0 * CFrame.new(0, 0.6 * k, 0), c3)
			B:block(R, v(1.2 * k, 0.2, 0.6 * k), r0 * CFrame.new(0.6 * k, -0.4 * k, 0) * ang(0, 0, -20), LEAF)
		end
		B:sym(function()
			-- on the trunks
			for i, rp in { { 33.6, 14.5, -2.6, "red" }, { 42.6, 9.8, 2.8, "pink" }, { 34.0, 6.2, 2.2, "red" }, { 42.4, 18.2, -3.0, "red" }, { 37.4, 21.6, -4.1, "pink" }, { 38.0, 12.0, 4.2, "red" } } do
				rose(v(rp[1], rp[2], rp[3]), 1.15, rp[4])
			end
			-- along the arch
			for i, th in { 0.3, 0.68, 1.0, 1.3 } do
				local p, t, n = arch(th)
				local z = (i % 2 == 0) and 1.9 or -1.9
				rose(p + n * 0.8 + v(0, 0, z), 1.2, (i % 2 == 0) and "pink" or "red")
			end
		end)

		---------------------------------------------------------------- hanging lanterns
		local function lantern(x)
			local th = math.acos(math.clamp(x / AX, -1, 1))
			local p = arch(th)
			local top = p.Y - 1.4
			local ly = math.max(top - 3.8, 21.6)
			B:block(R, v(0.25, 1.8, 0.25), cf(x, top - 0.6, 0), IRON)
			B:block(R, v(0.6, 0.6, 0.6), cf(x, top - 1.6, 0, 0, 45, 0), IRON_LT)
			-- lantern body
			B:block(R, v(2.3, 0.6, 2.3), cf(x, ly + 1.6, 0), IRON)
			B:block(R, v(1.5, 0.6, 1.5), cf(x, ly + 2.0, 0, 0, 45, 0), IRON)
			B:block(R, v(1.6, 2.1, 1.6), cf(x, ly + 0.25, 0), GLOW, { mat = "Neon" })
			for _, cx in { -1, 1 } do
				for _, cz in { -1, 1 } do
					B:block(R, v(0.35, 2.6, 0.35), cf(x + cx * 0.9, ly + 0.25, cz * 0.9), IRON)
				end
			end
			B:block(R, v(2.3, 0.5, 2.3), cf(x, ly - 1.1, 0), IRON)
			B:block(R, v(0.5, 0.4, 0.5), cf(x, ly - 1.55, 0), IRON_LT)
		end
		for _, x in { -25.5, -18.6, 18.6, 25.5 } do
			lantern(x)
		end

		---------------------------------------------------------------- sign (hangs from the apex)
		local SY = 23.4
		local SZ = -1.3
		B:block(R, v(28, 5.5, 1), cf(0, SY, SZ), SIGN, { name = "Sign" })
		-- dark plank back board
		B:block(R, v(28.6, 6.0, 0.8), cf(0, SY, SZ + 0.85), BARK_DK)
		for _, x in { -9.5, 0, 9.5 } do
			B:block(R, v(0.3, 6.0, 0.85), cf(x, SY, SZ + 0.9), BARK_DD)
		end
		-- carved rose on the back
		local bz = SZ + 1.3
		B:block(R, v(2.2, 2.2, 0.3), cf(0, SY + 0.4, bz, 0, 0, 45), ROSE_DK)
		B:block(R, v(1.4, 1.4, 0.35), cf(0, SY + 0.4, bz + 0.02), ROSE)
		B:block(R, v(0.35, 2.6, 0.3), cf(0, SY - 1.4, bz), VINE)
		B:block(R, v(1.2, 0.5, 0.3), cf(0.7, SY - 1.2, bz, 0, 0, 25), LEAF)
		-- chunky log frame
		local FZ = SZ - 0.1
		B:block(R, v(31.2, 1.4, 1.8), cf(0, SY + 3.45, FZ), BARK)
		B:block(R, v(31.2, 1.4, 1.8), cf(0, SY - 3.45, FZ), BARK)
		B:block(R, v(1.6, 5.6, 1.8), cf(-14.8, SY, FZ), BARK_LT)
		B:block(R, v(1.6, 5.6, 1.8), cf(14.8, SY, FZ), BARK_LT)
		for _, x in { -14.8, 14.8 } do
			for _, y in { SY + 3.45, SY - 3.45 } do
				B:block(R, v(2.0, 1.8, 2.0), cf(x, y, FZ), BARK_DK)
			end
		end
		-- log end rings (lighter) on the top/bottom logs
		B:block(R, v(0.4, 1.2, 1.6), cf(-15.7, SY + 3.45, FZ), BARK_LT)
		B:block(R, v(0.4, 1.2, 1.6), cf(15.7, SY + 3.45, FZ), BARK_LT)
		-- moss on the top log + roses at the corners
		B:block(R, v(9, 0.5, 1.6), cf(-7.5, SY + 4.35, FZ), MOSS)
		B:block(R, v(5, 0.5, 1.4), cf(9.0, SY + 4.35, FZ), MOSS_LT)
		B:block(R, v(1.0, 1.4, 0.4), cf(-11.0, SY + 3.0, FZ - 0.95), MOSS_DK)
		rose(v(-14.6, SY + 4.5, FZ - 0.4), 1.1, "red")
		rose(v(14.4, SY + 4.5, FZ - 0.4), 1.1, "pink")
		rose(v(-12.8, SY + 4.6, FZ + 0.2), 0.8, "pink")
		-- hanging ropes to the arch
		for _, x in { -10.5, 10.5 } do
			local th = math.acos(math.abs(x) / AX)
			local p = arch(th)
			B:block(R, v(0.35, p.Y - (SY + 4.1), 0.35), cf(x, (p.Y + SY + 4.1) / 2, FZ), ROPE)
			B:block(R, v(0.8, 0.5, 0.8), cf(x, SY + 4.35, FZ), IRON)
		end
	end,
}
