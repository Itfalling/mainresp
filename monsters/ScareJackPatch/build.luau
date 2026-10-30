--!nocheck
-- Jack-o'-Lantern Patch (Scarecrow Stage crop #5, Legendary).
-- A cosy pumpkin patch on a wide stepped dirt mound strewn with hay bits.
-- Three chunky ribbed jack-o'-lanterns sit in front of a leafy hump of big
-- rotated studded pumpkin-leaf cubes: a big grinning one in the middle, a
-- happy squinty one on the left and a delighted wide-eyed one on the right,
-- every face carved in stepped pixel blocks glowing warm neon orange from
-- inside. Twisting vines run between them, curly tendrils spiral out of the
-- leaves, yellow pumpkin blossoms and a little uncarved baby pumpkin peek out.
-- Static prop: no motion.luau.
return {
	DisplayName = "Jack-o'-Lantern Patch",
	Rarity = "Legendary",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local HAY, HAY_DK, HAY_LT = "#e2b64a", "#c4922e", "#f2d27a"
		local VINE_DK, VINE, VINE_LT = "#2b6a24", "#3d8a2c", "#5aa83a"
		local LEAF_DK, LEAF, LEAF_LT, LEAF_HI = "#2f7d2a", "#43a23a", "#62bf48", "#86d65e"
		local PUMP, PUMP_DK, PUMP_LT = "#f07a1a", "#d25f12", "#ff9a3a"
		local STEM, STEM_DK = "#6b5a2a", "#4c3f1c"
		local CARVE = "#ffc232" -- neon glow inside the carving
		local RIM = "#6e2c08" -- dark shadowy edge of the carved holes
		local BLOSSOM, BLOSSOM_DK = "#ffd23a", "#f0a81c"

		local seed = 3105
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end

		---------------------------------------------------------------- mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function tier(y0, h, r, col, nEdge, edgeCols, edgeH)
			B:block(soil, v(2 * r, h, 1.1 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.1 * r, h - 0.04, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.08, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
			for i = 0, nEdge - 1 do
				local a = (i + rnd(-0.2, 0.2)) / nEdge * 360
				local w, d = rnd(1.4, 2.3), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, math.rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 7.0, DIRT_DK, 17, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.6, 4.8, DIRT, 11, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.4, 0.4, 2.9, DIRT_LT, 0, {}, 0)
		for _, c in { { 7.4, 0.35, 1.8, 20 }, { -7.2, 0.3, -2.4, -15 }, { 1.6, 0.3, 7.5, 35 }, { -2.4, 0.3, -7.4, 10 } } do
			B:block(soil, v(1.1, 0.6, 0.9), cf(c[1], c[2], c[3], 0, c[4], 0), DIRT_DK2, S)
		end
		for _, g in { { 6.6, -3.0 }, { -6.2, 3.4 }, { 3.6, 6.0 }, { -6.6, -1.2 }, { 5.6, 3.6 } } do
			B:block(soil, v(0.45, 0.9, 0.45), cf(g[1], 1.0, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.35, 0.6, 0.35), cf(g[1] + 0.35, 0.95, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end
		-- scattered hay bits: little crossed straw sticks lying on the tiers
		for _, h in { { -5.8, 0.85, -4.0 }, { 4.6, 0.85, -5.6 }, { 6.2, 0.85, 0.8 }, { -4.2, 1.45, 3.4 }, { 0.6, 0.85, -6.6 }, { -6.4, 0.85, 1.8 } } do
			local yaw = rnd(0, 180)
			B:block(soil, v(1.6, 0.18, 0.22), cf(h[1], h[2] + 0.06, h[3], 0, yaw, rnd(-4, 4)), HAY, S)
			B:block(soil, v(1.3, 0.18, 0.22), cf(h[1] + 0.1, h[2] + 0.2, h[3] + 0.1, 0, yaw + rnd(35, 70), 0), HAY_LT, S)
		end

		---------------------------------------------------------------- helpers
		local crop = B:bone("Crop", "Root", v(0, 1.8, 0))
		-- one block spanning a -> b (overlaps a little at both ends so chains don't gap)
		local function seg(a, b, w, col, bone)
			local c, len = P.span(a, b)
			return B:block(bone or crop, v(w, w, len + w * 0.7), c, col)
		end
		-- curly tendril: a shrinking spiral of thin segments
		local function tendril(base, up, side, r0, turns, n, rise, w, col)
			local fwd = up:Cross(side).Unit
			local prev = base
			for i = 1, n do
				local t = i / n
				local a = t * turns * 2 * math.pi
				local r = r0 * (1 - 0.65 * t)
				local p = base + up * (rise * t) + side * (math.sin(a) * r) + fwd * ((1 - math.cos(a)) * r)
				seg(prev, p, w * (1 - 0.3 * t), col)
				prev = p
			end
			return prev
		end

		------------------------------------------------------- jack-o'-lanterns
		-- ribbed pumpkin: 5 vertical ribs, each a tall-shallow + short-deep block
		-- (stepped round from front, side and top). Face = pixel art on a 15-col
		-- grid (unit W/15), each lit run placed on the front of the rib it sits on.
		local HF = { [0] = 1.0, 0.9, 0.7 }
		local DF = { [0] = 1.0, 0.95, 0.66 }
		local carves = {}
		local function pumpkin(c, W, H, D, face, faceY, carved)
			local nr = carved and 2 or 1 -- 5 ribs on the jacks, 3 on the babies
			local rw = W / (2 * nr + 1)
			for k = -nr, nr do
				local a = math.abs(k) * (nr == 1 and 2 or 1)
				local col = (a == 1) and PUMP_DK or PUMP
				local x = k * rw
				local hh, dd = H * HF[a], D * DF[a]
				if a == 2 then
					-- outer ribs: one rounded-off block
					B:block(crop, v(rw + 0.04, hh * 0.9, dd * 0.86), c * CFrame.new(x, 0, 0), col)
				else
					B:block(crop, v(rw + 0.04, hh, dd * 0.72), c * CFrame.new(x, 0, 0), col)
					B:block(crop, v(rw + 0.02, hh * 0.78, dd), c * CFrame.new(x, 0, 0), (a == 0) and PUMP_LT or col)
				end
			end
			-- stem with a little curl
			B:block(crop, v(0.7, 1.1, 0.7), c * CFrame.new(0.05, H / 2 + 0.45, 0.05) * ang(8, 20, -10), STEM)
			B:block(crop, v(0.5, 0.45, 0.85), c * CFrame.new(0.15, H / 2 + 1.0, -0.3) * ang(-25, 20, -10), STEM_DK)
			if not carved then return end
			local u = W / 15
			local z0 = -D / 2
			local nRows = #face
			for ri, row in face do
				local ry = (math.floor(nRows / 2) + 1 - ri) * u + faceY
				local col = -7
				while col <= 7 do
					local ch = string.sub(row, col + 8, col + 8)
					if ch ~= "." then
						local c1 = col
						while c1 + 1 <= 7 and string.sub(row, c1 + 9, c1 + 9) ~= "." do
							c1 += 1
						end
						local n = c1 - col + 1
						local cx = (col + c1) / 2 * u
						-- dark carved rim, then the glowing hole in front of it
						B:block(crop, v((n + 0.55) * u, 1.5 * u, 0.3), c * CFrame.new(cx, ry, z0 + 0.03), RIM)
						local g = B:block(crop, v(n * u + 0.01, u + 0.01, 0.3), c * CFrame.new(cx, ry, z0 - 0.04), CARVE, { mat = "Neon", name = "Carve" })
						table.insert(carves, g)
						for k = col, c1 do
							local kc = string.sub(row, k + 8, k + 8)
							if kc == "T" then
								B:block(crop, v(u * 0.9, u + 0.02, 0.36), c * CFrame.new(k * u, ry + 0.02, z0 - 0.08), PUMP_LT)
							elseif kc == "p" then
								B:block(crop, v(u * 0.95, u + 0.02, 0.34), c * CFrame.new(k * u, ry, z0 - 0.07), "#ff6f8e")
							end
						end
						col = c1 + 1
					else
						col += 1
					end
				end
			end
		end

		-- big grinning jack (centre front): triangle eyes, triangle nose, toothy grin
		local FACE_GRIN = {
			"...#.......#...",
			"..###.....###..",
			".#####...#####.",
			".......#.......",
			"......###......",
			".#...........#.",
			".###T#####T###.",
			"..###########..",
			"....###T###....",
		}
		-- happy squinty jack (left): ^ ^ eyes, big open smile with a tongue
		local FACE_HAPPY = {
			"...............",
			"...#.......#...",
			"..#.#.....#.#..",
			".#...#...#...#.",
			"...............",
			"..#.........#..",
			"...#########...",
			"...####p####...",
			".....##p##.....",
		}
		-- delighted wide-eyed jack (right): big square eyes, small toothy smile
		local FACE_WOW = {
			"..##.......##..",
			".####.....####.",
			".####.....####.",
			"..##.......##..",
			"...............",
			"..#.........#..",
			"...##T###T##...",
			"....#######....",
			"......###......",
		}

		local BIG = cf(0, 1.4 + 2.3 - 0.12, -2.9, 0, 0, 0)
		pumpkin(BIG, 5.6, 4.6, 5.0, FACE_GRIN, 0.15, true)
		local LEFT = cf(-5.0, 1.4 + 1.9 - 0.12, -0.1, 0, 38, 3)
		pumpkin(LEFT, 4.6, 3.8, 4.1, FACE_HAPPY, 0.1, true)
		local RIGHT = cf(5.0, 1.4 + 1.9 - 0.12, -0.1, 0, -38, -3)
		pumpkin(RIGHT, 4.6, 3.8, 4.1, FACE_WOW, 0.1, true)
		-- uncarved baby pumpkins tucked in at the back
		pumpkin(cf(3.4, 0.8 + 1.05 - 0.1, 5.2, 0, 150, 4), 2.6, 2.1, 2.4, nil, 0, false)
		pumpkin(cf(-3.9, 0.8 + 0.9 - 0.1, 4.8, 0, -140, -3), 2.2, 1.8, 2.0, nil, 0, false)

		------------------------------------------------------------ leafy hump
		local HUB = v(0, 2.2, 2.0)
		local function cube(x, y, z, s, rx, ry, rz, col)
			B:block(crop, v(s, s, s), cf(x, y, z, rx, ry, rz), col)
		end
		-- chunky leaf-cube core behind the big jack
		cube(0.0, 4.2, 2.7, 4.4, 10, 20, 6, LEAF_DK)
		cube(-1.7, 6.3, 2.4, 3.4, -14, 40, 16, LEAF)
		cube(1.8, 6.1, 2.1, 3.2, 16, -15, -14, LEAF_LT)
		-- big pumpkin leaves: thick studded slabs on stalks, fanned out and tipped up
		local function bigLeaf(deg, out, up, tilt, s, col)
			local a = math.rad(deg)
			local d = v(math.sin(a), 0, -math.cos(a))
			local p = HUB + d * out + v(0, up, 0)
			local c = CFrame.new(p) * ang(0, -deg, 0) * ang(tilt, 0, rnd(-10, 10))
			seg(HUB + v(0, up * 0.35, 0), p, 0.45, VINE)
			B:block(crop, v(s, 1.0, s * 0.92), c, col)
			B:block(crop, v(s * 0.55, 1.05, s * 0.5), c * CFrame.new(0, 0.06, -s * 0.12), LEAF_HI)
		end
		bigLeaf(180, 3.4, 2.6, 38, 4.4, LEAF)
		bigLeaf(232, 4.0, 2.2, 32, 4.0, LEAF_LT)
		bigLeaf(128, 4.0, 2.4, 32, 4.0, LEAF_DK)
		bigLeaf(282, 3.4, 4.4, 44, 3.8, LEAF)
		bigLeaf(78, 3.4, 4.6, 44, 3.8, LEAF_LT)
		bigLeaf(10, 0.6, 6.6, 18, 4.0, LEAF)
		bigLeaf(205, 2.0, 5.8, 50, 3.6, LEAF_DK)
		bigLeaf(150, 2.2, 6.4, 46, 3.4, LEAF_LT)
		-- small leaves tucked between the jacks
		-- flat pumpkin leaves lying on the mound in front
		local function flatLeaf(x, y, z, yaw, tilt, s, col)
			local c = cf(x, y, z, 0, yaw, 0) * ang(tilt, 0, 0)
			B:block(crop, v(s, 0.6, s * 0.9), c, col)
			B:block(crop, v(s * 0.5, 0.64, s * 0.45), c * CFrame.new(0, 0.1, -s * 0.12), LEAF_LT)
		end
		flatLeaf(-3.6, 1.6, -4.6, 35, -12, 2.8, LEAF)
		flatLeaf(3.8, 1.6, -4.4, -30, -12, 2.8, LEAF_DK)
		flatLeaf(-6.4, 1.15, 2.4, 110, -10, 2.4, LEAF_LT)
		flatLeaf(6.4, 1.15, 2.6, -110, -10, 2.4, LEAF)

		--------------------------------------------------------------- vines
		-- thick twisting main vine climbing out of the centre of the hump
		local prev = HUB
		for i = 1, 5 do
			local t = i / 5
			local a = math.rad(t * 260)
			local p = v(math.cos(a) * 0.7, 2.2 + t * 6.0, 2.0 + math.sin(a) * 0.7)
			seg(prev, p, 1.0 - 0.3 * t, (i % 2 == 0) and VINE_DK or VINE)
			prev = p
		end
		-- runners from the hump to each jack's stem
		local function runner(pts, w)
			for i = 1, #pts - 1 do
				seg(pts[i], pts[i + 1], w, (i % 2 == 0) and VINE or VINE_DK)
			end
		end
		runner({ v(0, 2.0, 1.4), v(0.3, 4.2, 0.4), v(0.5, 6.0, -0.8), v(0.2, 6.6, -2.4) }, 0.5)
		runner({ v(-1.4, 2.0, 1.6), v(-2.8, 3.2, 1.4), v(-4.2, 4.9, 0.8), v(-5.0, 5.5, 0.0) }, 0.45)
		runner({ v(1.4, 2.0, 1.6), v(2.8, 3.2, 1.4), v(4.2, 4.9, 0.8), v(5.0, 5.5, 0.0) }, 0.45)
		runner({ v(0.8, 2.0, 2.8), v(2.0, 2.4, 4.0), v(3.2, 3.0, 5.0) }, 0.4)
		runner({ v(-0.8, 2.0, 2.8), v(-2.2, 2.2, 3.8), v(-3.7, 2.7, 4.7) }, 0.4)

		-- curly tendrils spiralling out of the leaves
		tendril(v(0.4, 9.4, 2.0), v(0.15, 1, -0.1).Unit, v(1, 0, 0), 1.0, 1.25, 6, 2.0, 0.34, VINE_LT)
		tendril(v(-1.6, 9.0, 3.6), v(-0.4, 1, 0.3).Unit, v(0, 0, 1), 0.9, 1.2, 5, 1.7, 0.32, VINE_LT)
		tendril(v(4.6, 8.2, 2.4), v(0.7, 1, -0.2).Unit, v(0, 0, -1), 0.9, 1.2, 5, 1.5, 0.32, VINE_LT)
		tendril(v(-4.6, 8.0, 2.4), v(-0.7, 1, -0.2).Unit, v(0, 0, 1), 0.9, 1.2, 5, 1.5, 0.32, VINE_LT)

		------------------------------------------------------------ blossoms
		local blossoms = {}
		local function blossom(p, yaw, tilt)
			local c = CFrame.new(p) * ang(tilt, yaw, 0)
			B:block(crop, v(1.3, 0.25, 0.5), c, BLOSSOM)
			B:block(crop, v(0.5, 0.25, 1.3), c * CFrame.new(0, 0.02, 0), BLOSSOM)
			table.insert(blossoms, B:block(crop, v(0.35, 0.35, 0.35), c * CFrame.new(0, 0.2, 0), "#fff1a8"))
		end
		blossom(v(-2.4, 8.4, 0.9), 20, -30)
		blossom(v(2.6, 8.0, 1.0), -30, 25)
		blossom(v(-6.4, 3.4, 0.9), 60, 20)

		---------------------------------------------------------------- glow
		-- warm candle light inside the big jack, soft glow + ember motes at the faces
		local core = B:block(crop, v(0.6, 0.6, 0.6), BIG * CFrame.new(0, -0.6, 0), CARVE, { mat = "Neon", name = "Candle" })
		B:light(core, { color = "#ff9a2e", brightness = 1.2, range = 12, name = "LanternLight" })
		B:emitter(carves[5], "glow", { name = "JackGlow", color = "#ffb340", rate = 2, size = 0.9 })
		B:emitter(carves[1], "sparkle", { name = "JackSparkle", color = { "#ffd27a", "#ff8a2a" }, rate = 3, size = 0.35 })
		B:emitter(blossoms[1], "ember", { name = "PatchEmbers", color = { "#ffcf5a", "#ff7a1a" }, rate = 2, size = 0.22, speed = { 0.4, 1.0 } })
	end,
}
