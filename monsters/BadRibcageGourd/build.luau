--!nocheck
-- Ribcage Gourd Vine (Bramble Badlands crop #2, Uncommon).
-- A big cartoony dinosaur ribcage lies half-buried in the badlands: a chunky
-- arched spine of cream vertebrae (stepped spinous plates on top) with four
-- pairs of thick curved ribs plunging into the mound. A thick olive gourd vine
-- grows up inside the cage, sprawls along the spine in big leaf cubes, drapes
-- over the ribs and shoots up in a tall curling tendril. Plump stepped
-- lava-orange bottle gourds (cream stripes) hang between the ribs and from
-- the top shoot; one ripe gourd rests inside the cage. Pale gourd flowers.
-- Base: stepped cracked charcoal rock / rust earth / ash mound with glowing
-- lava cracks and bone chips. Static prop: no motion.luau.
return {
	DisplayName = "Ribcage Gourd Vine",
	Rarity = "Uncommon",
	Element = "Badlands",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Bramble Badlands)
		local ROCK_DK, ROCK, ROCK_LT = "#352d2a", "#463c38", "#5e524c"
		local RUST_DK, RUST, RUST_LT = "#6e2e1f", "#8c3e28", "#a65334"
		local ASH_DK, ASH, ASH_LT = "#77706a", "#9b948c", "#bfb8ae"
		local BONE, BONE_DK, BONE_LT = "#efe2c0", "#cdb98e", "#fbf3dc"
		local LAVA, LAVA_HOT = "#ff5a14", "#ffa431"
		local VINE, VINE_DK = "#5d7a33", "#46602a"
		local LEAF = { "#6f9a3c", "#7fae45", "#5e8a34" }
		local LEAF_LT = "#a2c45e"
		local GOURD, GOURD_DK, GOURD_LT, STRIPE = "#f27a22", "#cc5718", "#ff9d45", "#ffdb9c"
		local CALYX = "#3f5a26"
		local PETAL, PETAL_LT, CENTER = "#ffd86a", "#fff0b0", "#ff9a2e"
		local NEON = { mat = "Neon" }

		local seed = 1722
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
				local w, d = rnd(1.5, 2.2), rnd(1.1, 1.5)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.3)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 5.0, ROCK_DK, 12, { ROCK_DK, ROCK, ROCK_LT, ROCK }, 0.35)
		tier(0.8, 0.6, 3.6, RUST, 9, { RUST, RUST_DK, RUST_LT }, 0.25)
		tier(1.4, 0.4, 2.4, ASH, 0, {}, 0)
		local TOP = 1.8

		B:block(soil, v(1.8, 0.14, 1.2), cf(-1.0, TOP + 0.04, -1.1, 0, 15, 0), ASH_LT, S)
		B:block(soil, v(1.3, 0.14, 1.0), cf(1.2, TOP + 0.03, 1.0, 0, -20, 0), ASH_DK, S)

		local function crack(pts, y)
			for i = 1, #pts - 1 do
				local a, b = pts[i], pts[i + 1]
				B:bar(soil, v(a[1], y, a[2]), v(b[1], y, b[2]), 0.32, 0.12, i % 2 == 0 and LAVA_HOT or LAVA, SN)
			end
		end
		crack({ { -4.0, -1.0 }, { -3.5, -1.7 }, { -3.85, -2.4 }, { -3.2, -3.0 } }, 0.83)
		crack({ { 3.6, 2.4 }, { 4.2, 1.7 }, { 4.15, 0.9 } }, 0.83)
		crack({ { 2.2, -1.5 }, { 2.8, -2.0 }, { 2.5, -2.7 } }, 1.43)
		for _, a in { 210, 340, 95 } do
			local d = dirOf(a)
			local p = d * 5.22 + v(0, 0.42, 0)
			B:block(soil, v(0.26, 0.7, 0.26), CFrame.new(p) * ang(0, -a, 0), LAVA, SN)
			B:block(soil, v(0.26, 0.22, 0.5), CFrame.new(p + v(0, 0.36, 0) - d * 0.2) * ang(0, -a, 0), LAVA_HOT, SN)
		end

		local function rock(x, z, y, s, yaw)
			local c = CFrame.new(x, y, z) * ang(0, yaw, 0)
			B:block(soil, v(1.5 * s, 0.9 * s, 1.2 * s), c * CFrame.new(0, 0.45 * s, 0), ROCK, S)
			B:block(soil, v(1.0 * s, 0.6 * s, 0.85 * s), c * CFrame.new(-0.15 * s, 1.1 * s, 0.05 * s) * ang(0, 14, 0), ROCK_LT, S)
		end
		rock(-4.1, 2.2, 0.8, 0.9, 25)
		-- bone chips
		B:block(soil, v(0.7, 0.35, 0.45), cf(1.6, 1.55, -3.0, 0, 30, 0), BONE, S)
		B:block(soil, v(0.45, 0.3, 0.4), cf(-2.6, 0.95, 3.9, 0, 60, 0), BONE_DK, S)

		------------------------------------------------------------ ribcage
		local cage = B:bone("Ribcage", "Root", v(0, TOP, 0))
		-- bar extended a little past both ends so bends overlap cleanly
		local function bone(bn, a, b, w, col)
			local d = (b - a).Unit
			B:bar(bn, a - d * w * 0.35, b + d * w * 0.35, w, w, col)
		end
		-- arched spine running front (-Z, short neck stub) to back (+Z, tail dives into the mound)
		local spine = {
			{ -3.25, 8.25, 0.85 }, { -2.45, 8.7, 0.92 }, { -1.6, 9.0, 1.0 },
			{ -0.7, 9.2, 1.0 }, { 0.3, 9.2, 1.0 }, { 1.3, 9.0, 1.0 }, { 2.25, 8.6, 0.93 },
			{ 3.05, 7.9, 0.86 }, { 3.7, 6.95, 0.78 }, { 4.15, 5.85, 0.7 }, { 4.45, 4.7, 0.62 },
			{ 4.6, 3.55, 0.55 }, { 4.65, 2.45, 0.5 },
		}
		local SP = {}
		for i, sp in spine do
			SP[i] = v(0, sp[2], sp[1])
		end
		for i, sp in spine do
			local s = sp[3]
			local a, b = SP[math.max(1, i - 1)], SP[math.min(#SP, i + 1)]
			local F0 = P.aim(a, b)
			local F = F0 - F0.Position + SP[i]
			-- centrum, darker disc, stepped spinous plate on top
			B:block(cage, v(1.3 * s, 1.15 * s, 0.95 * s), F, i % 2 == 0 and BONE or BONE_LT)
			if i < #spine then
				B:block(cage, v(1.1 * s, 0.95 * s, 0.34), F * CFrame.new(0, 0, -0.55 * s), BONE_DK)
			end
			if s > 0.6 then
				B:block(cage, v(0.7 * s, 1.15 * s, 0.55 * s), F * CFrame.new(0, 1.05 * s, 0.1) * ang(-10, 0, 0), BONE_LT)
				if s > 0.85 then
					B:block(cage, v(1.0 * s, 0.42 * s, 0.42 * s), F * CFrame.new(0, 1.6 * s, 0.15) * ang(-10, 0, 0), BONE)
				end
			end
		end
		-- rounded front end of the spine
		B:block(cage, v(0.9, 0.9, 0.5), CFrame.new(SP[1]) * P.aim(SP[2], SP[1]).Rotation * CFrame.new(0, 0, -0.5), BONE_DK)

		-- ribs: four pairs curving out (+-X) and down into the mound, middle ones longest
		for ri, idx in { 2, 4, 6, 8 } do
			local z, ys = spine[idx][1], spine[idx][2] - 0.2
			local mid = (ri == 2 or ri == 3)
			local reach = mid and 3.8 or 3.4
			local lean = (ri - 2.5) * 0.22
			for _, sg in { -1, 1 } do
				local pts = {
					v(0.5 * sg, ys, z),
					v(1.85 * sg, ys + 0.15, z + lean * 0.2),
					v(reach * 0.84 * sg, ys - 1.0, z + lean * 0.5),
					v(reach * sg, ys - 2.8, z + lean * 0.8),
					v(reach * 0.97 * sg, ys - 4.9, z + lean * 1.0),
					v(reach * 0.82 * sg, 1.1, z + lean * 1.1),
				}
				for k = 1, #pts - 1 do
					bone(cage, pts[k], pts[k + 1], 0.98 - 0.06 * k, (k % 2 == 0) and BONE or BONE_LT)
				end
				local d = (pts[4] - pts[3]).Unit
				B:bar(cage, pts[3] + v(0.42 * sg, 0, 0) + d * 0.25, pts[5] + v(0.42 * sg, 0, 0) - d * 0.1, 0.3, 0.55, BONE_DK)
			end
		end

		---------------------------------------------------------------- vine
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))
		local function vine(pts, w0, w1)
			for i = 1, #pts - 1 do
				local w = w0 + (w1 - w0) * (i - 1) / math.max(1, #pts - 2)
				local a, b = pts[i], pts[i + 1]
				local d = (b - a).Unit
				B:bar(crop, a - d * w * 0.3, b + d * w * 0.3, w, w, i % 2 == 1 and VINE or VINE_DK)
			end
		end
		-- big leaf cube: square plate + small lighter top plate turned 45
		local function leaf(p, s, tx, tz, yaw)
			local c = CFrame.new(p) * ang(0, yaw or rnd(0, 90), 0) * ang(tx or rnd(-15, 15), 0, tz or rnd(-15, 15))
			B:block(crop, v(1.8 * s, 0.8 * s, 1.8 * s), c, pick(LEAF))
			B:block(crop, v(1.0 * s, 0.86 * s, 1.0 * s), c * CFrame.new(0, 0.06, 0) * ang(0, 45, 0), LEAF_LT)
		end
		-- stepped bottle gourd, built downward from `top`
		local function gourd(top, s, yaw)
			local G = CFrame.new(top) * ang(0, yaw or rnd(0, 90), 0)
			B:block(crop, v(0.95 * s, 0.25, 0.95 * s), G * CFrame.new(0, -0.05, 0) * ang(0, 45, 0), CALYX)
			B:block(crop, v(0.62 * s, 0.9 * s, 0.62 * s), G * CFrame.new(0, -0.5 * s, 0), GOURD_LT)
			B:block(crop, v(1.05 * s, 0.75 * s, 1.05 * s), G * CFrame.new(0, -1.15 * s, 0), GOURD)
			B:block(crop, v(1.65 * s, 1.35 * s, 1.65 * s), G * CFrame.new(0, -2.15 * s, 0), GOURD)
			B:block(crop, v(1.4 * s, 1.5 * s, 1.4 * s), G * CFrame.new(0, -2.15 * s, 0) * ang(0, 45, 0), GOURD_DK)
			B:block(crop, v(1.1 * s, 0.35 * s, 1.1 * s), G * CFrame.new(0, -2.95 * s, 0), GOURD_DK)
			B:block(crop, v(0.32 * s, 1.15 * s, 0.12), G * CFrame.new(0, -2.15 * s, -0.83 * s), STRIPE)
			B:block(crop, v(0.12, 1.15 * s, 0.32 * s), G * CFrame.new(0.83 * s, -2.15 * s, 0), STRIPE)
		end
		local function hang(at, drop, s, yaw)
			B:bar(crop, at + v(0, 0.1, 0), at - v(0, drop + 0.1, 0), 0.26, 0.26, VINE_DK)
			gourd(at - v(0, drop, 0), s, yaw)
		end
		local function flower(p, s)
			local F = CFrame.new(p) * ang(rnd(-15, 15), rnd(0, 90), rnd(-15, 15))
			for k = 0, 3 do
				B:block(crop, v(0.8 * s, 0.24, 0.8 * s), F * ang(0, k * 90, 0) * CFrame.new(0, 0, -0.52 * s) * ang(-25, 45, 0), k % 2 == 0 and PETAL or PETAL_LT)
			end
			B:block(crop, v(0.42 * s, 0.38, 0.42 * s), F * CFrame.new(0, 0.1, 0), CENTER)
		end

		local Y = TOP
		-- main vine: up inside the cage (behind centre), over the spine, tall curling shoot
		vine({
			v(0.4, Y - 0.2, 0.9), v(0.9, 3.8, 1.4), v(0.3, 5.8, 0.6), v(-0.6, 7.6, 1.0),
			v(-0.9, 9.3, 0.4), v(-0.3, 10.8, -0.2), v(0.4, 12.2, -0.3), v(0.3, 13.4, -0.6),
		}, 0.8, 0.48)
		vine({ v(0.3, 13.4, -0.6), v(-0.4, 14.05, -0.5), v(-0.95, 13.75, -0.15), v(-0.75, 13.25, 0.15) }, 0.32, 0.26)
		-- arm off the shoot carrying the top gourd (out to the right-front)
		vine({ v(0.0, 11.6, -0.25), v(1.3, 12.0, -0.6), v(2.2, 11.7, -0.9) }, 0.45, 0.38)
		hang(v(2.2, 11.7, -0.9), 0.2, 0.8, 20)
		leaf(v(0.5, 12.3, -0.2), 0.95, -10, 20, 15)
		leaf(v(-0.4, 11.4, 0.4), 0.85, 15, 10, 40)
		leaf(v(-0.7, 10.0, -0.5), 0.9, 15, -15, 5)
		flower(v(0.3, 13.7, -0.6), 1.05)

		-- runners along the spine (offset to the left so the plates stay visible)
		vine({ v(-0.9, 9.6, 0.2), v(-1.0, 9.35, -1.6), v(-0.8, 8.8, -2.7), v(-0.4, 8.5, -3.3) }, 0.46, 0.36)
		vine({ v(-0.9, 9.6, 0.4), v(-1.0, 9.2, 2.0), v(-0.9, 8.1, 3.3), v(-0.8, 6.8, 4.0) }, 0.46, 0.36)
		for _, l in { { -1.4, 9.75, -1.3, 0.95 }, { -1.4, 9.3, -2.6, 0.85 }, { -1.4, 9.6, 1.6, 0.95 }, { -1.3, 8.1, 3.5, 0.85 }, { 0.9, 9.95, 1.0, 0.85 } } do
			leaf(v(l[1], l[2], l[3]), l[4])
		end
		-- the hero gourd hanging inside the front arch from the neck
		hang(v(-0.1, 8.4, -3.45), 0.35, 1.15, 0)
		-- drapes over the ribs on both sides, gourds hanging outside between ribs
		local function drape(sg, z, s, yaw)
			vine({ v(0.4 * sg, 9.55, z), v(2.1 * sg, 9.35, z), v(3.6 * sg, 8.5, z), v(4.65 * sg, 7.4, z) }, 0.38, 0.32)
			hang(v(4.65 * sg, 7.4, z), 0.25, s, yaw)
		end
		drape(1, -1.65, 0.9, 10)
		drape(-1, 2.2, 0.9, 40)
		drape(-1, -1.65, 0.8, 70)
		leaf(v(2.3, 9.7, -1.65), 0.85, 0, -25, 0)
		leaf(v(-2.3, 9.7, 2.2), 0.85, 0, 25, 30)
		leaf(v(-2.3, 9.7, -1.65), 0.8, 0, 25, 60)
		flower(v(1.1, 10.0, 2.6), 0.9)

		-- a ripe gourd resting inside the cage, a small one beside it
		vine({ v(0.4, Y + 0.6, 0.9), v(-0.6, Y + 0.4, 1.0), v(-1.3, Y + 0.3, 0.9) }, 0.38, 0.3)
		gourd(v(-1.4, Y + 2.95 * 0.95, 0.9), 0.95, 25)
		gourd(v(1.7, Y + 2.95 * 0.72, -0.2), 0.72, 60)
		-- a fallen gourd outside the cage, front-left
		gourd(v(-2.3, 1.4 + 2.95 * 0.8, -3.4) , 0.8, 35)
		leaf(v(-0.2, Y + 0.5, 0.8), 0.95, 5, 5, 10)
		leaf(v(1.2, Y + 0.45, 1.8), 0.85, 5, -5, 50)
		leaf(v(0.8, 4.5, 1.3), 0.9, 20, -15, 30)
		leaf(v(-0.6, 6.9, 0.9), 0.9, -15, 20, 70)
	end,
}
