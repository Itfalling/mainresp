--!nocheck
-- Overgrown Jungle Arch (Snap-Jaw Jungle decoration #3, hero piece).
-- A crumbling stepped jungle-stone ruin arch, wide and tall enough to walk
-- through, swallowed by the bog jungle:
-- * flagstone path + two mossy plinths, fallen stones, tufts and ferns
-- * two stacked stone pillars (skewed drums, dark bands, carved teeth
--   friezes under the capitals) carrying stepped corbels, a three-block
--   lintel (one slab sagging), a broken second course and a stepped crest
-- * a protruding keystone with the carved flytrap-jaw motif (crimson lobes,
--   cream interlocking teeth, glowing lime seam) - teeth only, no face
-- * moss caps and drips, vines climbing both pillars and looping along the
--   lintel, leafy canopy clusters and fronds on top
-- * three hanging pitcher plants (same design as the Pitcher Pod crop) on
--   tendrils from under the lintel, plus three hanging vine strands - these
--   sway gently in motion.luau (bones Pitcher1-3, Strand1-3)
return {
	DisplayName = "Overgrown Jungle Arch",
	Rarity = "Decor",
	Element = "Snap-Jaw Jungle",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (shared with the Snap-Jaw Jungle crops + Vine Totem)
		local DIRT_DK, DIRT = "#3f2516", "#4d2d1a"
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK, STONE_XDK = "#9a9180", "#b8ae98", "#757062", "#4e4a40"
		local GREEN, GREEN_DK, GREEN_LT, GREEN_TOP = "#3caa3c", "#1f6e2a", "#9fd84a", "#58c447"
		local RED, RED_DK, RIM, HOOD = "#c92a48", "#8e1a33", "#ff5c7c", "#ff6d8a"
		local INSIDE, THROAT = "#ff5c7c", "#5c0f25"
		local CREAM = "#fff4d2"
		local LIME = "#a6ff3c"
		local NEON = { mat = "Neon" }
		local root = "Root"

		local seed = 9157
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		local PX = 6.0 -- pillar centre |x|
		local TOP = 13.6 -- lintel underside

		------------------------------------------------------------ footing
		-- low ground slab + flagstone path through the arch
		B:block(root, v(18.0, 0.4, 4.6), cf(0, 0.2, 0), DIRT_DK)
		B:block(root, v(16.4, 0.39, 5.6), cf(0, 0.195, 0), DIRT)
		for i, x in { -3.3, -1.1, 1.1, 3.3 } do
			B:block(root, v(2.0, 0.2, 2.2 + (i % 2) * 0.4), cf(x, 0.48, rnd(-0.3, 0.3), 0, rnd(-6, 6), 0), (i % 2 == 0) and STONE_LT or STONE)
		end
		-- plinths
		for _, s in { -1, 1 } do
			B:block(root, v(4.4, 1.0, 4.4), cf(PX * s, 0.9, 0), STONE_DK)
			B:block(root, v(3.9, 0.3, 3.9), cf(PX * s, 1.55, 0), STONE)
		end
		-- moss creeping over the slab
		B:block(root, v(3.0, 0.3, 1.4), cf(-4.6, 0.45, -2.4, -8, 0, 0), MOSS)
		B:block(root, v(2.4, 0.3, 1.2), cf(5.2, 0.45, 2.4, 8, 0, 0), MOSS_DK)
		B:block(root, v(1.4, 0.3, 2.6), cf(8.6, 0.45, -0.6, 0, 0, -8), MOSS)
		B:block(root, v(1.6, 0.28, 1.1), cf(0.2, 0.5, 2.5, 8, 0, 0), MOSS_DK)
		-- fallen stones (one is the missing crest chunk)
		B:block(root, v(1.6, 1.1, 1.4), cf(4.4, 0.85, -3.1, 4, 28, -10), STONE)
		B:block(root, v(0.8, 0.6, 0.7), cf(5.4, 0.55, -3.4, 0, 60, 0), STONE_LT)
		B:block(root, v(1.0, 0.7, 0.9), cf(-8.6, 0.5, 1.8, 0, -25, 6), STONE_DK)
		B:block(root, v(0.7, 0.5, 0.6), cf(-2.4, 0.5, -2.6, 0, 35, 0), STONE)
		-- grass tufts
		for _, g in { { -8.4, -1.6 }, { 8.6, 1.6 }, { -3.8, 2.8 }, { 2.6, -2.8 }, { -0.4, -2.9 } } do
			B:block(root, v(0.42, 1.1, 0.42), cf(g[1], 0.7, g[2], 0, 20, 8), GRASS)
			B:block(root, v(0.34, 0.75, 0.34), cf(g[1] + 0.34, 0.55, g[2] + 0.16, 0, 40, -10), GRASS_DK)
			B:block(root, v(0.3, 0.6, 0.3), cf(g[1] - 0.3, 0.5, g[2] - 0.18, 0, 10, 12), GRASS)
		end
		-- ferns at the pillar feet
		local function fern(x, z, yaw, len)
			local fr = CFrame.new(x, 0.6, z) * CFrame.Angles(0, rad(yaw), 0) * CFrame.Angles(rad(28), 0, 0)
			B:block(root, v(0.3, 0.3, len), fr * CFrame.new(0, 0, -len / 2), GREEN_DK)
			for i = 1, 3 do
				B:block(root, v(1.9 - 0.35 * i, 0.2, 0.48), fr * CFrame.new(0, 0.05, -len * 0.22 * i - 0.2), i % 2 == 1 and GREEN or GREEN_LT)
			end
		end
		fern(-7.6, -2.0, 40, 2.8)
		fern(7.8, -1.6, -50, 2.6)
		fern(-4.6, 1.8, -150, 2.4)

		------------------------------------------------------------ pillars
		local drums = { { 1.7, 2.9, 3.3, 3, STONE }, { 4.6, 2.7, 3.0, -4, STONE_LT }, { 7.3, 2.7, 3.3, 5, STONE }, { 10.0, 2.4, 3.0, -3, STONE_LT } }
		for _, s in { -1, 1 } do
			for i, d in drums do
				local y0, h, w, yaw, col = d[1], d[2], d[3], d[4] * s, d[5]
				local F = CFrame.new(PX * s, y0 + h / 2, 0) * CFrame.Angles(0, rad(yaw), 0)
				B:block(root, v(w, h, w), F, col)
				B:block(root, v(w + 0.16, 0.3, w + 0.16), F * CFrame.new(0, -h / 2 + 0.15, 0), STONE_DK)
				-- a couple of masonry accents (lighter / darker bricks)
				if i % 2 == 1 then
					B:block(root, v(1.2, 0.9, 0.1), F * CFrame.new(-0.6 * s, 0.4, -w / 2 - 0.05), STONE_DK)
				else
					B:block(root, v(1.0, 0.8, 0.1), F * CFrame.new(0.7 * s, -0.2, w / 2 + 0.05), STONE)
				end
			end
			-- capital (stepped) with a carved teeth frieze on front + back
			local CY = 12.4
			B:block(root, v(3.7, 0.6, 3.7), cf(PX * s, CY + 0.3, 0), STONE_DK)
			B:block(root, v(4.3, 0.6, 4.1), cf(PX * s, CY + 0.9, 0), STONE)
			for _, z in { -1, 1 } do
				B:block(root, v(3.0, 0.55, 0.1), cf(PX * s, CY - 0.1, z * 1.56), STONE_XDK)
				for k, x in { -1.0, -0.33, 0.33, 1.0 } do
					B:block(root, v(0.3, 0.42, 0.12), cf(PX * s + x, CY - 0.1 + ((k % 2 == 0) and -0.08 or 0.08), z * 1.62), CREAM)
				end
			end
			-- corbel stepping into the opening (makes the arch read)
			B:block(root, v(1.3, 1.0, 3.0), cf((PX - 2.1) * s, TOP - 0.5, 0), STONE_DK)
			B:block(root, v(0.7, 0.5, 2.8), cf((PX - 3.05) * s, TOP - 0.25, 0), STONE)
		end

		------------------------------------------------------------ lintel + crest
		B:block(root, v(5.0, 2.0, 3.2), cf(-5.1, TOP + 1.0, 0), STONE)
		B:block(root, v(5.2, 2.1, 3.3), cf(0, TOP + 1.05, 0), STONE_LT)
		B:block(root, v(5.0, 2.0, 3.2), cf(5.1, TOP + 0.95, 0, 0, 0, -2.5), STONE) -- sagging slab
		B:block(root, v(15.6, 0.3, 3.36), cf(0, TOP + 0.15, 0), STONE_DK)
		-- broken second course
		B:block(root, v(5.8, 1.2, 2.6), cf(-2.4, TOP + 2.7, 0), STONE_DK)
		B:block(root, v(3.2, 1.2, 2.6), cf(2.1, TOP + 2.65, 0, 0, 0, -1.5), STONE)
		B:block(root, v(1.4, 0.9, 2.4), cf(-6.0, TOP + 2.5, 0.2, 0, 10, 0), STONE)
		-- stepped crest
		B:block(root, v(3.4, 1.1, 2.4), cf(0, TOP + 3.85, 0), STONE)
		B:block(root, v(2.0, 0.6, 2.0), cf(0, TOP + 4.7, 0), STONE_DK)

		------------------------------------------------------------ keystone jaw
		local KF = CFrame.new(0, TOP + 1.6, -1.65)
		B:block(root, v(2.8, 3.8, 0.5), KF * CFrame.new(0, -0.1, 0.05), STONE_LT)
		B:block(root, v(3.1, 0.4, 0.7), KF * CFrame.new(0, 1.85, 0.05), STONE_DK)
		local glows = {}
		local function jaw(F, k)
			local function at(x, y, z) return F * CFrame.new(x * k, y * k, -z) end
			for _, r in { { 0.95, 1.1 }, { 0.62, 2.0 }, { 0.25, 2.5 }, { -0.25, 2.5 }, { -0.62, 2.0 }, { -0.95, 1.1 } } do
				B:block(root, v(r[2] * k, 0.38 * k, 0.1), at(0, r[1], 0.05), STONE_XDK)
			end
			B:block(root, v(1.6 * k, 0.32 * k, 0.1), at(0, 0.62, 0.12), RED)
			B:block(root, v(2.1 * k, 0.36 * k, 0.1), at(0, 0.3, 0.12), INSIDE)
			B:block(root, v(2.1 * k, 0.36 * k, 0.1), at(0, -0.3, 0.12), INSIDE)
			B:block(root, v(1.6 * k, 0.32 * k, 0.1), at(0, -0.62, 0.12), RED)
			B:block(root, v(1.9 * k, 0.26 * k, 0.1), at(0, 0, 0.17), THROAT)
			table.insert(glows, B:block(root, v(1.4 * k, 0.08 * k, 0.1), at(0, 0, 0.22), LIME, NEON))
			for _, x in { -0.75, -0.25, 0.25, 0.75 } do
				B:block(root, v(0.22 * k, 0.42 * k, 0.16), at(x, 0.12, 0.3), CREAM)
			end
			for _, x in { -0.5, 0, 0.5 } do
				B:block(root, v(0.22 * k, 0.42 * k, 0.16), at(x, -0.12, 0.3), CREAM)
			end
			for _, x in { -0.4, 0, 0.4 } do
				B:block(root, v(0.16 * k, 0.32 * k, 0.12), at(x, 1.26, 0.08), CREAM)
				B:block(root, v(0.16 * k, 0.32 * k, 0.12), at(x, -1.26, 0.08), CREAM)
			end
		end
		jaw(KF * CFrame.new(0, -0.15, -0.2), 0.95)
		-- plain keystone face at the back
		B:block(root, v(2.6, 3.4, 0.3), cf(0, TOP + 1.5, 1.75), STONE_LT)
		B:block(root, v(1.6, 0.6, 0.12), cf(0, TOP + 1.5, 1.95), STONE_XDK)

		------------------------------------------------------------ moss
		B:block(root, v(10.0, 0.3, 3.0), cf(-1.2, TOP + 3.4, 0), MOSS)
		B:block(root, v(2.2, 0.3, 2.6), cf(5.8, TOP + 2.1, 0, 0, 0, -2.5), MOSS_DK)
		B:block(root, v(2.6, 0.3, 2.4), cf(-6.6, TOP + 2.1, 0), MOSS)
		for _, m in { { -6.2, -1, 1.4, MOSS_DK }, { -3.6, -1, 0.8, MOSS }, { 3.4, -1, 1.1, MOSS }, { 6.6, -1, 0.7, MOSS_DK }, { -4.6, 1, 1.3, MOSS }, { 4.8, 1, 1.0, MOSS_DK } } do
			B:block(root, v(0.9, m[3], 0.2), cf(m[1], TOP + 2.0 - m[3] / 2, m[2] * 1.72), m[4])
		end
		for _, s in { -1, 1 } do
			B:block(root, v(4.5, 0.3, 4.3), cf(PX * s, 13.35, 0), MOSS_DK)
			B:block(root, v(1.2, 1.8, 0.2), cf(PX * s - 1.0 * s, 11.3, -1.72), MOSS)
			B:block(root, v(1.4, 0.3, 1.0), cf(PX * s + 0.8, 1.8, -1.6), MOSS)
		end

		------------------------------------------------------------ vines
		local function leafAt(p, out, i)
			local lf = CFrame.lookAt(p + out * 0.3, p + out * 2) * CFrame.Angles(rad(-25), 0, rad(rnd(-35, 35)))
			B:block(root, v(0.7, 0.16, 0.9), lf * CFrame.new(0, 0, -0.25), (i % 2 == 0) and GREEN_LT or GREEN)
		end
		-- climbing vines on the pillar fronts + backs (wavy, with leaves)
		for _, s in { -1, 1 } do
			for _, zs in { -1, 1 } do
				local ph = zs > 0 and 2.1 or 0
				local prev = v(PX * s + 0.9 * math.cos(ph) * s, 1.6, 1.8 * zs)
				for i = 1, 8 do
					local y = 1.6 + i * 1.45
					local p = v(PX * s + (0.9 * math.cos(i * 1.3 + ph)) * s, y, ((i % 3 == 0) and 1.9 or 1.75) * zs)
					B:bar(root, prev, p, 0.34, 0.34, GREEN_DK)
					if i % 2 == 0 then leafAt(p, v(s * 0.6, 0, 0.8 * zs).Unit, i) end
					prev = p
				end
			end
		end
		-- vine loops sagging along the lintel front
		local function loop(x0, x1, y0, y1, sag, z)
			local n = 6
			local prev = v(x0, y0, z)
			for i = 1, n do
				local f = i / n
				local p = v(x0 + (x1 - x0) * f, y0 + (y1 - y0) * f - sag * 4 * f * (1 - f), z)
				B:bar(root, prev, p, 0.32, 0.32, GREEN_DK)
				if i == 2 or i == 4 then leafAt(p, v(0, -0.3, -1).Unit, i) end
				prev = p
			end
		end
		loop(-7.6, -1.6, 15.2, 15.4, 2.0, -1.78)
		loop(1.5, 7.6, 15.3, 14.9, 1.7, -1.78)
		loop(-7.4, 7.2, 15.0, 14.8, 2.2, 1.78)

		------------------------------------------------------------ canopy on top
		local function leafCube(c, s, col)
			B:block(root, v(s, s, s), CFrame.new(c) * ang(rnd(-25, 25), rnd(0, 90), rnd(-25, 25)), col)
		end
		leafCube(v(-6.6, 16.5, 0.2), 2.2, GREEN)
		leafCube(v(-5.2, 17.2, -0.6), 1.8, GREEN_TOP)
		leafCube(v(-7.3, 17.4, 0.6), 1.5, GREEN_LT)
		leafCube(v(-4.6, 16.4, 0.9), 1.5, GREEN_DK)
		leafCube(v(6.2, 16.3, -0.2), 2.0, GREEN_DK)
		leafCube(v(7.0, 17.0, 0.6), 1.6, GREEN)
		leafCube(v(5.0, 16.6, 0.5), 1.4, GREEN_LT)
		leafCube(v(1.9, 18.3, 0.3), 1.3, GREEN_TOP)
		-- big fronds arching out of the crest
		local function frond(base, yaw, up, len, col)
			local fr = CFrame.new(base) * CFrame.Angles(0, rad(yaw), 0) * CFrame.Angles(rad(up), 0, 0)
			B:block(root, v(0.34, 0.3, len), fr * CFrame.new(0, 0, -len / 2), GREEN_DK)
			for i = 1, 3 do
				B:block(root, v(2.0 - 0.4 * i, 0.22, 0.6), fr * CFrame.new(0, 0.06, -len * 0.24 * i - 0.1), (i % 2 == 1) and col or GREEN_LT)
			end
		end
		leafCube(v(-1.7, 18.9, -0.1), 1.5, GREEN)
		leafCube(v(-0.2, 19.3, 0.5), 1.2, GREEN_LT)
		leafCube(v(-3.2, 18.3, 0.4), 1.3, GREEN_DK)
		frond(v(0, TOP + 5.0, 0.3), 180, 40, 2.8, GREEN)
		frond(v(0, TOP + 4.9, -0.3), 10, 46, 2.4, GREEN_TOP)

		------------------------------------------------------------ hanging pitchers
		local nectars, drips = {}, {}
		-- stepped pitcher cup (same design as the Pitcher Pod crop); F = foot frame
		local function cup(bone, F, s, idx)
			local function at(px, py, pz) return F * CFrame.new(px * s, py * s, pz * s) end
			B:block(bone, v(0.9 * s, 0.4 * s, 0.9 * s), at(0, 0.2, 0), GREEN_DK)
			B:block(bone, v(1.15 * s, 1.0 * s, 1.15 * s), at(0, 0.9, 0), GREEN)
			B:block(bone, v(1.5 * s, 1.0 * s, 1.5 * s), at(0, 1.9, 0), GREEN)
			B:block(bone, v(1.8 * s, 1.2 * s, 1.8 * s), at(0, 3.0, 0), GREEN_LT)
			for _, k in { -0.4, 0.4 } do
				B:block(bone, v(0.24 * s, 1.2 * s + 0.06, 1.8 * s + 0.08), at(k, 3.0, 0), RED)
				B:block(bone, v(1.8 * s + 0.08, 1.2 * s + 0.06, 0.24 * s), at(0, 3.0, k), RED)
			end
			-- neck + rim ring
			B:block(bone, v(1.6 * s, 0.35 * s, 1.6 * s), at(0, 3.78, 0), RED)
			local rt, rw, rh, ry = 0.38, 2.1, 0.4, 4.12
			B:block(bone, v(rw * s, rh * s, rt * s), at(0, ry, -(rw - rt) / 2), RIM)
			B:block(bone, v(rw * s, rh * s, rt * s), at(0, ry, (rw - rt) / 2), RIM)
			B:block(bone, v(rt * s, rh * s - 0.04, (rw - 2 * rt) * s + 0.02), at(-(rw - rt) / 2, ry, 0), RIM)
			B:block(bone, v(rt * s, rh * s - 0.04, (rw - 2 * rt) * s + 0.02), at((rw - rt) / 2, ry, 0), RIM)
			-- nectar + spill drop
			table.insert(nectars, B:block(bone, v(1.36 * s, 0.3 * s, 1.36 * s), at(0, 4.06, 0), LIME, { mat = "Neon", name = "Nectar" .. idx }))
			table.insert(drips, B:block(bone, v(0.26 * s, 0.55 * s, 0.14), at(0.35, 3.9, -rw / 2 - 0.07 / s), LIME, { mat = "Neon", name = "NectarDrip" .. idx }))
			-- hooded lid hinged at the back rim
			local H = at(0, 4.3, 0.9) * CFrame.Angles(rad(62), 0, 0)
			local Ln = 1.6 * s
			B:block(bone, v(1.7 * s, 0.3, Ln), H * CFrame.new(0, 0.15, -Ln / 2), GREEN_LT)
			B:block(bone, v(1.3 * s, 0.28, Ln * 0.85), H * CFrame.new(0, -0.06, -Ln / 2 - 0.08), HOOD)
			B:block(bone, v(0.26 * s, 0.3, Ln * 0.7), H * CFrame.new(0, 0.2, -Ln / 2), RED_DK)
		end
		-- hanging pitcher: tendril from under the lintel curling into the foot
		local function pitcher(idx, x, z, len, s, yaw)
			local bone = B:bone("Pitcher" .. idx, "Root", v(x, TOP, z))
			local foot = v(x, TOP - len, z - 0.75 * s)
			local F = CFrame.new(foot) * CFrame.Angles(0, -rad(yaw), 0)
			local t0 = v(x, TOP + 0.2, z)
			local t1 = v(x + 0.25, TOP - len * 0.55, z + 0.15)
			local t2 = v(x, TOP - len - 0.35, z + 0.1)
			B:bar(bone, t0, t1, 0.3, 0.3, GREEN_DK)
			B:bar(bone, t1, t2, 0.28, 0.28, GREEN_DK)
			B:bar(bone, t2, (F * CFrame.new(0, 0.05 * s, 0)).Position, 0.28, 0.28, GREEN_DK)
			B:block(bone, v(0.7, 0.16, 0.5), CFrame.new(t1) * ang(0, 30, 25) * CFrame.new(0.4, 0, 0), GREEN)
			cup(bone, F, s, idx)
		end
		pitcher(1, -2.9, -0.3, 6.4, 0.85, 15)
		pitcher(2, 0.2, 0.6, 7.4, 1.0, 0)
		pitcher(3, 3.0, -0.4, 5.9, 0.78, -20)
		-- a little pitcher growing at the right pillar's foot + a leaf rosette
		local SF = CFrame.new(8.3, 0.4, -2.4) * CFrame.Angles(0, rad(-25), 0)
		cup(root, SF * CFrame.Angles(rad(-8), 0, 0), 0.6, 4)
		for k, a in { 0, 120, 240 } do
			local lf = SF * CFrame.Angles(0, rad(a + 30), 0) * CFrame.Angles(rad(18), 0, 0)
			B:block(root, v(0.7, 0.2, 1.4), lf * CFrame.new(0, 0.1, -0.7), (k % 2 == 0) and GREEN or GREEN_DK)
		end
		-- leafy bushes at the pillar feet
		leafCube(v(-8.0, 1.2, -1.9), 1.5, GREEN_DK)
		leafCube(v(-7.1, 1.15, -2.6), 1.2, GREEN)
		leafCube(v(4.0, 1.15, 2.2), 1.4, GREEN)
		leafCube(v(7.9, 1.1, 1.9), 1.3, GREEN_TOP)
		-- pink buds on the pillar vines
		for _, b in { { -6.9, 6.0, -2.1 }, { 5.2, 9.1, -2.1 }, { -5.2, 10.2, -2.0 } } do
			B:block(root, v(0.42, 0.45, 0.42), cf(b[1], b[2], b[3]), INSIDE)
			B:block(root, v(0.24, 0.2, 0.24), cf(b[1], b[2] + 0.3, b[3]), RED)
		end

		------------------------------------------------------------ hanging strands
		local function strand(idx, x, z, len)
			local bone = B:bone("Strand" .. idx, "Root", v(x, TOP + 0.6, z))
			local prev = v(x, TOP + 0.8, z)
			local n = 3
			for i = 1, n do
				local p = v(x + ((i % 2 == 0) and 0.2 or -0.15), TOP + 0.6 - len * i / n, z)
				B:bar(bone, prev, p, 0.26, 0.26, GREEN_DK)
				local lf = CFrame.new(p) * ang(0, (i % 2 == 0) and 40 or -40, (i % 2 == 0) and 30 or -30)
				B:block(bone, v(0.8, 0.16, 0.5), lf * CFrame.new((i % 2 == 0) and 0.4 or -0.4, 0, 0), (i % 2 == 0) and GREEN_LT or GREEN)
				prev = p
			end
			B:block(bone, v(0.4, 0.4, 0.4), CFrame.new(prev - v(0, 0.15, 0)), INSIDE)
		end
		strand(1, -5.4, -1.85, 3.6)
		strand(2, 1.6, -1.95, 2.4)
		strand(3, 5.5, -1.85, 4.2)

		------------------------------------------------------------ fx
		B:emitter(glows[1], "glow", { name = "KeystoneGlow", color = { "#e6ffb0", LIME }, rate = 1.0, size = 0.9, speed = { 0.1, 0.3 } })
		B:emitter(drips[2], "drip", { name = "NectarDripFx", color = { "#d8ff8a", LIME }, rate = 1.2, size = 0.25 })
		B:emitter(nectars[1], "sparkle", { name = "NectarSparkle", color = { "#eaffb0", LIME }, rate = 2, size = 0.3 })
		local canopy = B:block(root, v(10, 0.2, 2.5), cf(0, 17.6, 0), GREEN, { tr = 1, name = "CanopyFx" })
		B:emitter(canopy, "leaf", { name = "FallingLeaves", color = { GREEN_LT, GREEN }, rate = 1.2, size = 0.4 })
		B:light(glows[1], { color = "#c8ff7a", brightness = 0.7, range = 10, name = "KeystoneLight" })
		B:light(nectars[2], { color = "#c8ff7a", brightness = 0.6, range = 8, name = "PitcherLight" })
	end,
}
