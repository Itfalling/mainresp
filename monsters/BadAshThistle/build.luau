--!nocheck
-- Ash Thistle (Bramble Badlands crop #1, Common).
-- A clump of tall, jagged ash-green thistle stalks rising from a basal
-- rosette of big spiny lobed leaves. Each stalk ends in a spiky bract bulb
-- (cream spine tips) topped by a stepped ember-red brush that brightens to
-- orange at the tips, with a tiny glowing ember core. Side branches carry
-- smaller heads; a young bud pokes out at the front.
-- Base: stepped mound of cracked charcoal rock, rust earth and grey ash,
-- with thin glowing lava cracks, bone fragments and basalt chunks.
-- Static prop: no motion.luau.
return {
	DisplayName = "Ash Thistle",
	Rarity = "Common",
	Element = "Badlands",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Bramble Badlands)
		local ROCK_DK, ROCK, ROCK_LT = "#352d2a", "#463c38", "#5e524c"
		local RUST_DK, RUST, RUST_LT = "#6e2e1f", "#8c3e28", "#a65334"
		local ASH_DK, ASH, ASH_LT = "#77706a", "#9b948c", "#bfb8ae"
		local BONE, BONE_DK = "#f1e5c6", "#d3c19a"
		local LAVA, LAVA_HOT = "#ff5a14", "#ffa431"
		local STEM, STEM_DK, STEM_LT = "#5a7b63", "#48644f", "#7a9c80"
		local LEAF, LEAF_DK, LEAF_LT = "#6a9280", "#4e7464", "#93b8a2"
		local BRACT, BRACT_DK = "#557a5e", "#3c5a45"
		local SPINE = "#f3e7c4"
		local RED_DK, RED, RED_LT, ORANGE = "#9e1f14", "#d4321c", "#f0522a", "#ff8a2e"
		local NEON = { mat = "Neon" }

		local seed = 1711
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function dirOf(deg)
			local a = rad(deg)
			return v(math.sin(a), 0, -math.cos(a))
		end

		---------------------------------------------------------------- mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local SN = { name = "Soil", mat = "Neon" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.4, 2.1), rnd(1.1, 1.5)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.3)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 4.4, ROCK_DK, 11, { ROCK_DK, ROCK, ROCK_LT, ROCK }, 0.35)
		tier(0.8, 0.6, 3.1, RUST, 8, { RUST, RUST_DK, RUST_LT }, 0.25)
		tier(1.4, 0.4, 2.0, ASH, 0, {}, 0)
		local TOP = 1.8

		-- grey ash drifts on the top tier
		B:block(soil, v(1.7, 0.14, 1.2), cf(-0.8, TOP + 0.04, -0.9, 0, 20, 0), ASH_LT, S)
		B:block(soil, v(1.2, 0.14, 1.0), cf(0.9, TOP + 0.03, 1.0, 0, -15, 0), ASH_DK, S)

		-- glowing lava cracks: thin zigzags sunk into the tier tops
		local function crack(pts, y)
			for i = 1, #pts - 1 do
				local a, b = pts[i], pts[i + 1]
				B:bar(soil, v(a[1], y, a[2]), v(b[1], y, b[2]), 0.32, 0.12, i % 2 == 0 and LAVA_HOT or LAVA, SN)
			end
		end
		crack({ { -3.2, -1.9 }, { -2.6, -2.5 }, { -2.85, -3.15 }, { -2.2, -3.7 } }, 0.83)
		crack({ { 2.9, 1.6 }, { 3.6, 1.2 }, { 3.7, 0.4 } }, 0.83)
		crack({ { 1.9, -1.2 }, { 2.5, -1.75 }, { 2.25, -2.3 } }, 1.43)
		crack({ { -2.4, 0.9 }, { -2.0, 1.6 }, { -2.55, 2.1 } }, 1.43)
		-- glowing seams running down the outer rock tier
		for _, a in { 200, 335, 80 } do
			local d = dirOf(a)
			local p = d * 4.62 + v(0, 0.42, 0)
			B:block(soil, v(0.26, 0.7, 0.26), CFrame.new(p) * ang(0, -a, 0), LAVA, SN)
			B:block(soil, v(0.26, 0.22, 0.5), CFrame.new(p + v(0, 0.36, 0) - d * 0.2) * ang(0, -a, 0), LAVA_HOT, SN)
		end

		-- basalt chunks (stepped)
		local function rock(x, z, y, s, yaw)
			local c = CFrame.new(x, y, z) * ang(0, yaw, 0)
			B:block(soil, v(1.5 * s, 0.9 * s, 1.2 * s), c * CFrame.new(0, 0.45 * s, 0), ROCK, S)
			B:block(soil, v(1.0 * s, 0.6 * s, 0.85 * s), c * CFrame.new(-0.15 * s, 1.1 * s, 0.05 * s) * ang(0, 14, 0), ROCK_LT, S)
		end
		rock(-3.4, 1.6, 0.8, 0.95, 25)
		rock(3.3, -1.9, 0.8, 0.75, -35)

		-- bone fragments: a little bone with knobbly ends + a stray rib
		local function bone(a, b, w)
			B:bar(soil, a, b, w, w, BONE, S)
			local d = (b - a).Unit
			local side = v(d.Z, 0, -d.X) * (w * 0.45)
			for _, p in { a, b } do
				B:block(soil, v(w * 0.9, w * 0.9, w * 0.9), CFrame.new(p + side) * ang(0, rnd(0, 90), 0), BONE_DK, S)
				B:block(soil, v(w * 0.9, w * 0.9, w * 0.9), CFrame.new(p - side) * ang(0, rnd(0, 90), 0), BONE, S)
			end
		end
		bone(v(-1.6, 1.62, -2.4), v(0.2, 1.62, -2.75), 0.42)
		bone(v(2.2, 0.98, 2.6), v(3.4, 0.98, 1.9), 0.36)
		-- a curved rib poking out of the ash at the back-left
		B:bar(soil, v(-2.5, 1.2, 2.4), v(-2.8, 2.3, 2.9), 0.36, 0.36, BONE, S)
		B:bar(soil, v(-2.8, 2.3, 2.9), v(-2.4, 3.0, 3.5), 0.32, 0.32, BONE_DK, S)

		----------------------------------------------------------- thistles
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		-- jagged stalk through a list of points, tapering
		local function stalk(pts, w0, w1)
			for i = 1, #pts - 1 do
				local w = w0 + (w1 - w0) * (i - 1) / math.max(1, #pts - 2)
				B:bar(crop, pts[i], pts[i + 1], w, w, i % 2 == 1 and STEM or STEM_DK)
				if i > 1 then
					B:block(crop, v(w + 0.16, 0.3, w + 0.16), CFrame.new(pts[i]) * ang(0, 45, 0), STEM_LT)
				end
			end
		end

		-- spiny lobed thistle leaf: blade + paired lobes, cream spine tips
		local function leaf(at, yaw, pitch, len, w, lobes, big)
			local d = dirOf(yaw) * math.cos(rad(pitch)) + v(0, math.sin(rad(pitch)), 0)
			local F0 = P.aim(at, at + d)
			local F = F0 - F0.Position + at
			B:block(crop, v(w, 0.34, len), F * CFrame.new(0, 0, -len / 2), big and LEAF or LEAF_DK)
			if big then
				B:block(crop, v(0.3, 0.42, len * 0.85), F * CFrame.new(0, 0.03, -len * 0.45), LEAF_LT)
			end
			for i = 1, lobes do
				local z = -len * (i / (lobes + 0.6))
				local lw = w * (0.85 - 0.15 * i)
				for _, s in { 1, -1 } do
					local L = F * CFrame.new(s * w * 0.32, 0, z) * ang(0, s * 34, 0)
					B:block(crop, v(lw, 0.3, 0.7), L * CFrame.new(s * lw / 2, 0, 0), (i + (s > 0 and 1 or 0)) % 2 == 0 and LEAF or LEAF_LT)
					B:block(crop, v(0.26, 0.26, 0.26), L * CFrame.new(s * (lw + 0.1), 0, 0), SPINE)
				end
			end
			B:block(crop, v(0.22, 0.22, 0.3), F * CFrame.new(0, 0, -len - 0.12), SPINE)
		end

		-- thistle head: spiky bract bulb + stepped ember brush
		local function head(at, s, tx, tz, ripe)
			local H = CFrame.new(at) * ang(tx or 0, rnd(0, 45), tz or 0)
			B:block(crop, v(0.9 * s, 0.5 * s, 0.9 * s), H * CFrame.new(0, 0.2 * s, 0), BRACT_DK)
			B:block(crop, v(1.45 * s, 0.75 * s, 1.45 * s), H * CFrame.new(0, 0.75 * s, 0) * ang(0, 45, 0), BRACT)
			B:block(crop, v(1.2 * s, 0.4 * s, 1.2 * s), H * CFrame.new(0, 1.2 * s, 0), BRACT_DK)
			for k = 0, 3 do
				local a = rad(k * 90)
				local o = 1.12 * s
				B:block(crop, v(0.22, 0.22, 0.22) * math.max(1, s), H * CFrame.new(math.sin(a) * o, 0.7 * s, -math.cos(a) * o) * ang(0, k * 90 + 45, 0), SPINE)
			end
			if not ripe then
				B:block(crop, v(0.6 * s, 0.5 * s, 0.6 * s), H * CFrame.new(0, 1.55 * s, 0) * ang(0, 45, 0), RED)
				return
			end
			B:block(crop, v(1.15 * s, 0.6 * s, 1.15 * s), H * CFrame.new(0, 1.6 * s, 0) * ang(0, 45, 0), RED_DK)
			B:block(crop, v(1.5 * s, 0.6 * s, 1.5 * s), H * CFrame.new(0, 2.1 * s, 0), RED)
			B:block(crop, v(1.75 * s, 0.5 * s, 1.75 * s), H * CFrame.new(0, 2.6 * s, 0) * ang(0, 45, 0), RED_LT)
			for k = 0, 3 do
				local a = rad(k * 90)
				local o = 0.62 * s
				B:block(crop, v(0.5 * s, 0.5 * s, 0.5 * s), H * CFrame.new(math.sin(a) * o, 3.0 * s, -math.cos(a) * o) * ang(0, 45, 0), k % 2 == 0 and ORANGE or RED_LT)
			end
			B:block(crop, v(0.5 * s, 0.4 * s, 0.5 * s), H * CFrame.new(0, 3.0 * s, 0) * ang(0, 45, 0), LAVA_HOT, NEON)
		end

		local Y = TOP
		-- basal rosette of big spiny leaves
		for i, yaw in { 15, 85, 160, 230, 300 } do
			leaf(v(0, Y + 0.3, 0), yaw + rnd(-8, 8), 14 + rnd(-4, 6), 3.3 + rnd(-0.2, 0.3), 1.35, 2, true)
		end

		-- main stalk + two side branches
		stalk({ v(0, Y, 0), v(0.25, 4.6, 0.1), v(-0.1, 7.2, 0), v(0.1, 9.4, 0) }, 0.85, 0.7)
		head(v(0.1, 9.35, 0), 1.15, 0, 0, true)
		stalk({ v(0.2, 5.6, 0.05), v(1.5, 6.5, -0.3), v(2.4, 7.4, -0.5) }, 0.55, 0.5)
		head(v(2.4, 7.35, -0.5), 0.85, 0, -14, true)
		stalk({ v(-0.05, 7.6, 0), v(-1.2, 8.3, -0.3), v(-1.7, 8.7, -0.4) }, 0.5, 0.45)
		head(v(-1.7, 8.65, -0.4), 0.7, 0, 14, true)
		leaf(v(0.2, 4.4, 0.1), 70, 22, 2.3, 1.0, 2)
		leaf(v(0.0, 6.4, 0.0), 210, 25, 2.1, 0.95, 2)

		-- second plant (back left)
		stalk({ v(-1.5, Y, 0.9), v(-1.8, 4.4, 1.1), v(-2.5, 6.6, 0.9) }, 0.7, 0.6)
		head(v(-2.5, 6.55, 0.9), 0.95, 0, 12, true)
		leaf(v(-1.75, 4.0, 1.05), 255, 20, 2.1, 0.95, 2)

		-- third plant (back right)
		stalk({ v(1.4, Y, 1.2), v(1.8, 3.6, 1.6), v(2.6, 5.1, 2.0) }, 0.65, 0.55)
		head(v(2.6, 5.05, 2.0), 0.8, -10, -12, true)
		leaf(v(1.75, 3.4, 1.55), 130, 18, 1.9, 0.9, 2)

		-- young bud at the front
		stalk({ v(-0.8, Y, -1.3), v(-1.3, 3.0, -1.7), v(-1.6, 3.9, -2.0) }, 0.5, 0.45)
		head(v(-1.6, 3.85, -2.0), 0.62, 0, 10, false)
	end,
}
