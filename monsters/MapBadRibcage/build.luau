--!nocheck
-- Giant Ribcage (Map set-piece, Bramble Badlands hero landmark).
-- The fossil skeleton of a colossal dinosaur lying over the hallway, so the
-- player runs THROUGH its ribcage:
-- * a chunky backbone high over the lane centre (z -58..58), gently arched,
--   neck vertebrae tapering toward -Z (the approaching player) and a longer
--   tail tapering toward +Z; each vertebra is a stepped spool (centrum with
--   rims), neural arch, a tall stepped dorsal spine plate, transverse
--   processes and a ventral keel, with dark gaps between the vertebrae
-- * eight pairs of curved ribs, each a chain of short rotated blocks: out of
--   the spine sideways, bulging out to |x| ~42, then curling down and in to
--   plant in the first cliff tier (y 14) beside the lane, longest in the
--   middle; a light outer ridge, a darker inner groove, dark joint bands,
--   cracks, a rubble collar where each tip sinks into the cliff
-- * one rib snapped: the upper half ends in a jagged break in mid air, its
--   stump and broken-off piece lie on the cliff top
-- * dark bramble vines with red berries climbing two ribs and dangling from
--   the backbone (all well above the run lane), olive moss patches
-- Run lane |x| < 31, y < 19 stays empty. Static: Filler (flattened, anchored).
return {
	DisplayName = "Giant Ribcage",
	Rarity = "Landmark",
	Filler = true,
	Element = "Bramble Badlands",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad, deg = math.rad, math.deg
		local R = "Root"

		-- palette -------------------------------------------------------
		local BONE_LT, BONE, BONE_DK = "#f3ead2", "#e2d6b5", "#c9b98f"
		local BONE_SH = "#ad9b72" -- joint bands
		local CRACK, CRACK_DK = "#7d6b4f", "#5a4a38"
		local GAP = "#8a7756"
		local BR, BR_LT = "#3b2a28", "#523a35"
		local BERRY, BERRY_DK, BERRY_HI = "#d8323a", "#a3202c", "#ff6b5e"
		local LEAF, LEAF_DK = "#6b7d34", "#4f5f28"
		local MOSS, MOSS_DK, MOSS_LT = "#6f8a3a", "#566e2e", "#8aa64a"
		local GND, GND_DK = "#b5523c", "#a64833"
		local ROCK, ROCK_DK = "#5a3b36", "#4c312d"

		local seed = 920117
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function clamp(x, a, b)
			return math.max(a, math.min(b, x))
		end

		------------------------------------------------------------------
		-- SPINE CURVE
		------------------------------------------------------------------
		local function yC(z) -- centrum centre height
			local y = 36.0 - 0.0011 * (z + 4) ^ 2
			if z > 26 then
				y -= 0.0022 * (z - 26) ^ 2
			end
			return y
		end
		local function slope(z)
			return (yC(z + 0.5) - yC(z - 0.5))
		end
		local function scaleAt(z)
			if z < -32 then
				return 1 - 0.42 * clamp((-32 - z) / 26, 0, 1)
			elseif z > 24 then
				return 1 - 0.5 * clamp((z - 24) / 34, 0, 1) ^ 0.9
			end
			return 1 + 0.06 * (1 - ((z + 4) / 28) ^ 2)
		end
		local G = 1.28 -- global vertebra chunkiness
		local function frameAt(z)
			return CFrame.new(0, yC(z), z) * CFrame.Angles(-math.atan(slope(z)), 0, 0)
		end

		-- vertebra positions: cage part every 8 studs, then shrinking spacing
		local VZ = {}
		for k = 0, 7 do
			table.insert(VZ, -32 + 8 * k)
		end
		do
			local z = -32
			while true do
				local s = scaleAt(z)
				z -= 8 * s * 0.92
				if z < -58 then break end
				table.insert(VZ, 1, z)
			end
			z = 24
			while true do
				local s = scaleAt(z)
				z += 8 * s * 0.9
				if z > 58.5 then break end
				table.insert(VZ, z)
			end
		end

		------------------------------------------------------------------
		-- VERTEBRAE
		------------------------------------------------------------------
		local spineTop = {}
		for i, z in VZ do
			local s = scaleAt(z) * G
			local F = frameAt(z)
			local function blk(sz, x, y, zz, col, rx)
				return B:block(R, sz, F * CFrame.new(x, y, zz) * CFrame.Angles(rad(rx or 0), 0, 0), col)
			end
			local L = 5.6 * s
			-- centrum spool
			blk(v(6.0 * s, 5.0 * s, L), 0, 0, 0, BONE)
			blk(v(6.8 * s, 5.8 * s, 1.1 * s), 0, 0, -L / 2 + 0.55 * s, BONE_LT)
			blk(v(6.8 * s, 5.8 * s, 1.1 * s), 0, 0, L / 2 - 0.55 * s, BONE_LT)
			blk(v(6.15 * s, 5.15 * s, 0.7 * s), 0, 0, jit(0.6) * s, BONE_SH)
			-- ventral keel (seen from the lane below)
			blk(v(3.0 * s, 1.4 * s, 3.4 * s), 0, -3.0 * s, 0, BONE_DK)
			-- neural arch
			blk(v(4.0 * s, 3.2 * s, 4.4 * s), 0, 3.6 * s, 0, BONE)
			-- dorsal spine plate, stepped, leaning back toward the tail
			local h = 0.86
			if i % 2 == 0 then h = 0.78 end
			blk(v(2.4 * s, 3.4 * s * h, 4.6 * s), 0, 6.4 * s * h, 0.2 * s, BONE_DK, -6)
			blk(v(1.8 * s, 3.0 * s * h, 3.6 * s), 0, 9.0 * s * h, 0.7 * s, BONE_LT, -10)
			blk(v(1.3 * s, 1.4 * s, 2.4 * s), 0, 10.9 * s * h, 1.1 * s, BONE, -12)
			spineTop[i] = (F * CFrame.new(0, 11.5 * s * h, 1.1 * s)).Position
			-- transverse processes (rib heads sit on these)
			for _, sx in { -1, 1 } do
				blk(v(4.2 * s, 1.8 * s, 2.8 * s), sx * 4.6 * s, 1.5 * s, 0, BONE_LT)
				-- zygapophysis knobs bridging to the next vertebra
				blk(v(1.0 * s, 1.3 * s, 2.6 * s), sx * 1.7 * s, 4.7 * s, L / 2, BONE_DK)
			end
			-- dark disc in the gap to the next vertebra
			local zn = VZ[i + 1]
			if zn then
				local a = Vector3.new(0, yC(z), z)
				local b = Vector3.new(0, yC(zn), zn)
				local sn = (s + scaleAt(zn) * G) / 2
				B:bar(R, a, b, 4.2 * sn, 3.4 * sn, GAP)
			end
		end

		------------------------------------------------------------------
		-- RIBS
		------------------------------------------------------------------
		local function bez(p0, p1, p2, p3, t)
			local u = 1 - t
			return p0 * (u * u * u) + p1 * (3 * u * u * t) + p2 * (3 * u * t * t) + p3 * (t * t * t)
		end
		-- 2D rib curve (x outward, y up) for one side
		local function ribCurve(x0, y0, bx, tx, ty)
			local function build(p2x)
				local p0 = Vector2.new(x0, y0)
				local p1 = Vector2.new(x0 + 0.45 * (bx - x0), y0 - 0.5)
				local p2 = Vector2.new(p2x, y0 - 0.42 * (y0 - ty))
				local p3 = Vector2.new(tx, ty)
				local pts, mx = {}, -1e9
				for k = 0, 80 do
					local p = bez(p0, p1, p2, p3, k / 80)
					table.insert(pts, p)
					mx = math.max(mx, p.X)
				end
				return pts, mx
			end
			local lo, hi = bx - 4, bx + 20
			local pts
			for _ = 1, 30 do
				local mid = (lo + hi) / 2
				local p, mx = build(mid)
				pts = p
				if mx > bx then hi = mid else lo = mid end
			end
			return pts
		end
		-- resample a dense polyline into n equal-length pieces
		local function resample(pts, n)
			local acc = { 0 }
			for k = 2, #pts do
				acc[k] = acc[k - 1] + (pts[k] - pts[k - 1]).Magnitude
			end
			local total = acc[#pts]
			local out = {}
			local j = 1
			for k = 0, n do
				local d = total * k / n
				while j < #pts - 1 and acc[j + 1] < d do
					j += 1
				end
				local f = (d - acc[j]) / math.max(acc[j + 1] - acc[j], 1e-6)
				table.insert(out, pts[j]:Lerp(pts[j + 1], clamp(f, 0, 1)))
			end
			return out
		end

		local ZUP = Vector3.new(0, 0, 1)
		local tips = {}
		local ribPaths = {}
		local function rockCollar(p, s)
			local yTop = 14
			B:block(R, v(3.6 * s, 1.1, 3.0 * s), CFrame.new(p.X, yTop + 0.25, p.Z) * ang(0, jit(30), 0), GND_DK)
			B:block(R, v(2.2 * s, 1.0, 2.0 * s), CFrame.new(p.X + jit(1.2), yTop + 0.7, p.Z + jit(1.2)) * ang(jit(6), 45 + jit(20), jit(6)), ROCK)
			B:block(R, v(1.4, 0.9, 1.2), CFrame.new(p.X + jit(2), yTop + 0.45, p.Z + jit(2)) * ang(0, jit(40), 0), (rnd() > 0.5) and ROCK_DK or GND)
		end

		local N = 12
		for k = 1, 8 do
			local z = -32 + 8 * (k - 1)
			local f = 1 - ((k - 4.5) / 3.5) ^ 2 -- 0 at ends, ~1 in the middle
			local s = scaleAt(z)
			local y0 = yC(z) + 1.6 * s * G
			for _, sx in { -1, 1 } do
				local bx = 39.6 + 3.0 * f + jit(0.8)
				local tx = 36.6 + 2.2 * f + jit(1.0)
				local ty = 12.6 - 2.4 * f + jit(0.8)
				local sweep = 1.0 + 0.7 * k + jit(1.0) -- tip slides toward the tail
				local x0 = 6.4 * s * G
				local pts2 = resample(ribCurve(x0, y0, bx, tx, ty), N)
				local pts = {}
				for i, p in pts2 do
					local t = (i - 1) / N
					table.insert(pts, Vector3.new(sx * p.X, p.Y, z + sweep * t * t))
				end
				local broken = (k == 6 and sx == -1)
				local base = (rnd() > 0.45) and BONE or BONE_LT
				local thick = 0.86 + 0.16 * f
				local last = broken and 6 or N
				for i = 1, last do
					local a, b = pts[i], pts[i + 1]
					local d = (b - a).Unit
					local t = (i - 1) / (N - 1)
					local tr = (4.3 - 2.5 * t) * thick -- radial thickness
					local tz = (3.4 - 1.8 * t) * thick -- fore-aft width
					local e = tr * 0.38
					local a0 = a - d * ((i == 1) and 0.6 or e)
					local b0 = b + d * e
					local col = base
					if i % 5 == 3 then col = BONE_DK end
					B:bar(R, a0, b0, tr, tz, col, { up = ZUP })
					-- outward normal in the rib plane
					local out = d:Cross(ZUP).Unit
					if out.X * sx + out.Y * 0.6 < 0 then out = -out end
					if i <= N - 1 then
						-- light outer ridge
						B:bar(R, a0 + out * tr * 0.3 + d * 0.1, b0 + out * tr * 0.3 - d * 0.1, tr * 0.5, tz * 0.72, BONE_LT, { up = ZUP })
					end
					if i <= N - 2 then
						-- darker groove along the inner face (what the player looks at)
						B:bar(R, a0 - out * tr * 0.3 + d * 0.15, b0 - out * tr * 0.3 - d * 0.15, tr * 0.46, tz * 0.5, BONE_DK, { up = ZUP })
					end
					-- dark joint bands
					if i == 3 or i == 8 then
						B:bar(R, a - d * 0.35, a + d * 0.35, tr * 1.1, tz * 1.1, BONE_SH, { up = ZUP })
					end
				end
				-- rib head on the transverse process
				local hp = pts[1]
				B:block(R, v(3.6 * thick, 3.2 * thick, 3.2 * thick), CFrame.new(hp + Vector3.new(-sx * 0.4, 0.2, 0)) * ang(0, 0, sx * 12), BONE_LT)
				B:block(R, v(2.2, 1.6, 2.4), CFrame.new(hp + Vector3.new(-sx * 1.4, 1.7, 0)) * ang(0, 0, -sx * 20), BONE_DK)
				if broken then
					-- jagged break in mid air
					local a, b = pts[last], pts[last + 1]
					local d = (b - a).Unit
					local tr = (4.3 - 2.5 * ((last - 1) / (N - 1))) * thick
					B:block(R, v(tr * 0.7, tr * 0.6, tr * 0.6), CFrame.new(b - d * 0.2) * ang(25, 10, 35), BONE_DK)
					B:block(R, v(tr * 0.45, tr * 0.8, tr * 0.4), CFrame.new(b + d * 0.35 + Vector3.new(0, 0, 0.5)) * ang(-15, 30, 20), BONE_SH)
					B:block(R, v(tr * 0.35, tr * 0.5, tr * 0.35), CFrame.new(b + d * 0.25 + Vector3.new(0.3, 0.2, -0.6)) * ang(10, -20, -25), BONE)
					-- stump still planted in the cliff (last 2 segments)
					local sa, sb = pts[N], pts[N + 1]
					local sd = (sb - sa).Unit
					local stumpTop = sa:Lerp(sb, -0.6)
					B:bar(R, stumpTop, sb, 2.0 * thick, 1.7 * thick, BONE, { up = ZUP })
					B:block(R, v(1.5, 1.0, 1.4), CFrame.new(stumpTop) * ang(20, 30, 30), BONE_DK)
					-- broken-off piece lying on the cliff top
					local px = sb.X + sx * 5
					local BF = CFrame.new(px, 14.75, z + 6.5) * ang(0, 28, 4)
					B:block(R, v(1.8, 1.5, 9.0), BF, BONE)
					B:block(R, v(1.0, 0.6, 7.6), BF * CFrame.new(0, 0.85, 0), BONE_LT)
					B:block(R, v(2.0, 1.4, 1.2), BF * CFrame.new(0, 0.05, -4.6) * ang(15, 25, 0), BONE_DK)
					B:block(R, v(1.5, 1.6, 1.6), BF * CFrame.new(0, 0.1, 4.6) * ang(0, 45, 0), BONE_LT)
					B:block(R, v(1.95, 1.55, 0.6), BF * CFrame.new(0, 0, 1.5), BONE_SH)
					rockCollar(sb, 1)
				else
					-- knobby tip sinking into the cliff + rubble collar
					local tip = pts[N + 1]
					B:block(R, v(1.9, 1.9, 1.9), CFrame.new(tip) * ang(0, 45, 0), BONE_DK)
					rockCollar(Vector3.new(tip.X, 14, tip.Z), 1)
				end
				local tipP = pts[N + 1]
				table.insert(tips, string.format("(%.1f, %.1f, %.1f)%s", tipP.X, tipP.Y, tipP.Z, broken and " broken" or ""))
				ribPaths[k .. (sx > 0 and "R" or "L")] = pts
				-- cracks: small dark slivers on the outer face
				if rnd() > 0.35 then
					local i = 4 + math.floor(rnd() * 5)
					if i <= last then
						local a, b = pts[i], pts[i + 1]
						local d = (b - a).Unit
						local out = d:Cross(ZUP).Unit
						if out.X * sx + out.Y * 0.6 < 0 then out = -out end
						local tr = (4.3 - 2.5 * ((i - 1) / (N - 1))) * thick
						local tz = (3.4 - 1.8 * ((i - 1) / (N - 1))) * thick
						local c = a:Lerp(b, 0.5) + out * (tr * 0.52)
						B:block(R, v(0.3, tz * 0.75, 0.25), CFrame.lookAt(c, c + d, ZUP) * ang(0, 0, 0) * CFrame.Angles(0, 0, rad(25)), CRACK_DK)
						B:block(R, v(0.28, tz * 0.4, 0.22), CFrame.lookAt(c, c + d, ZUP) * CFrame.new(0, tz * 0.35, -0.5) * CFrame.Angles(0, 0, rad(-30)), CRACK)
					end
				end
			end
		end

		------------------------------------------------------------------
		-- BRAMBLE climbing two ribs
		------------------------------------------------------------------
		local function berries(p, s)
			B:block(R, v(0.8 * s, 0.8 * s, 0.8 * s), CFrame.new(p) * ang(0, 30, 0), BERRY)
			B:block(R, v(0.7 * s, 0.7 * s, 0.7 * s), CFrame.new(p + Vector3.new(0.5 * s, -0.4 * s, 0.3 * s)) * ang(0, 10, 0), BERRY_DK)
			B:block(R, v(0.35 * s, 0.35 * s, 0.35 * s), CFrame.new(p + Vector3.new(-0.1, 0.42 * s, -0.1)), BERRY_HI)
		end
		local function vineOnRib(pts, sx, i0, i1, turns, ph)
			local vp = {}
			local n = (i1 - i0) * 2
			for k = 0, n do
				local u = i0 + (i1 - i0) * k / n
				local i = math.floor(u)
				local fr = u - i
				local a, b = pts[i], pts[math.min(i + 1, #pts)]
				local c = a:Lerp(b, fr)
				local d = (b - a).Unit
				local out = d:Cross(ZUP).Unit
				local t = (u - 1) / (N - 1)
				local r = (4.3 - 2.5 * t) * 0.5 + 0.35
				local th = ph + turns * 2 * math.pi * k / n
				table.insert(vp, c + out * (math.cos(th) * r) + ZUP * (math.sin(th) * r * 0.9))
			end
			for k = 1, #vp - 1 do
				local d = (vp[k + 1] - vp[k]).Unit
				B:bar(R, vp[k] - d * 0.2, vp[k + 1] + d * 0.2, 0.6, 0.6, (k % 2 == 0) and BR_LT or BR)
				if k % 2 == 1 then
					B:bar(R, vp[k + 1], vp[k + 1] + Vector3.new(0, 0.5, 0) + d:Cross(Vector3.new(0, 1, 0)).Unit * 0.7, 0.28, 0.28, BONE_DK)
				end
				if k % 3 == 0 then
					berries(vp[k] + Vector3.new(0, -0.5, 0), 1)
				end
				if k % 4 == 2 then
					B:block(R, v(1.2, 0.25, 0.8), CFrame.new(vp[k] + Vector3.new(0, 0.3, 0.4)) * ang(20, 40 * k, 15), (k % 8 == 2) and LEAF or LEAF_DK)
				end
			end
		end
		vineOnRib(ribPaths["3R"], 1, 5, 12.6, 2.2, 0.4)
		vineOnRib(ribPaths["7L"], -1, 6, 12.6, 1.8, 2.0)
		vineOnRib(ribPaths["5L"], -1, 2, 5.5, 1.0, 1.0)

		------------------------------------------------------------------
		-- BRAMBLE STRANDS dangling from the backbone (bottom >= y 26)
		------------------------------------------------------------------
		local function strand(z, x, len, phase)
			local top = Vector3.new(x, yC(z) - 2.2, z)
			local prev = top
			local segs = 5
			for k = 1, segs do
				local p = top + Vector3.new(math.sin(phase + k * 1.1) * 0.8, -len * k / segs, math.cos(phase + k * 0.9) * 0.6)
				local d = (p - prev).Unit
				B:bar(R, prev - d * 0.15, p + d * 0.15, 0.55, 0.55, (k % 2 == 0) and BR_LT or BR)
				if k % 2 == 0 then
					B:bar(R, p, p + Vector3.new(0.7, 0.3, 0), 0.25, 0.25, BONE_DK)
				end
				prev = p
			end
			berries(prev + Vector3.new(0, -0.5, 0), 1.1)
			B:block(R, v(1.2, 0.25, 0.9), CFrame.new(top + Vector3.new(0.4, -len * 0.45, 0)) * ang(15, 30, 20), LEAF)
		end
		strand(-20, 2.2, 9, 0.3)
		strand(4, -2.4, 11, 1.7)
		strand(12, 3.0, 7, 2.9)

		------------------------------------------------------------------
		-- MOSS patches on the backbone and rib tops
		------------------------------------------------------------------
		for _, z in { -24, 0, 16, 31.5 } do
			local s = scaleAt(z) * G
			local F = frameAt(z)
			B:block(R, v(4.2 * s, 0.5, 3.8 * s), F * CFrame.new(-0.6 * s, 5.3 * s, 0.6), MOSS)
			B:block(R, v(2.4 * s, 0.6, 2.2 * s), F * CFrame.new(1.4 * s, 5.4 * s, -1.0), MOSS_LT)
			B:block(R, v(1.6, 0.9, 1.4), F * CFrame.new(-2.4 * s, 4.0 * s, 1.6), MOSS_DK)
		end
		for _, key in { "2L", "4R", "6R", "8L" } do
			local pts = ribPaths[key]
			for _, i in { 2, 3 } do
				local c = pts[i]:Lerp(pts[i + 1], 0.5)
				B:block(R, v(2.2, 0.6, 2.4), CFrame.new(c + Vector3.new(0, 1.55, 0)) * ang(0, jit(20), 0), (i == 2) and MOSS or MOSS_DK)
			end
		end

		print("RIB TIPS: " .. table.concat(tips, "  "))
		print("VERTEBRAE: " .. #VZ)
	end,
}
