--!nocheck
-- Ghost Pumpkin Vine (Scarecrow Stage crop #8, Cosmic).
-- A tower of friendly white "ghost" pumpkins. On a stepped dirt mound with
-- hay bits, three stepped, ribbed ghost pumpkins sit stacked big-to-small,
-- each with a cute carved face glowing soft mint (the top one winks). A
-- thick pumpkin vine spirals up around the stack sprouting big rotated
-- studded leaf cubes in plum / violet / orchid, wispy pale-mint tendrils
-- curl off it with glowing tips, and a leafy crown with a tall mint wisp
-- curl tops it off. Two little ghost pumpkins sit on the mound and two tiny
-- sheet-ghosts float alongside. Static prop: no motion.luau.
return {
	DisplayName = "Ghost Pumpkin Vine",
	Rarity = "Cosmic",
	Element = "Garden",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette ---------------------------------------------------------
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local GRASS, GRASS_DK = "#7cc23a", "#5a9a2e"
		local HAY, HAY_DK, HAY_LT = "#e6bd55", "#c79634", "#f6da84"
		local VINE_DK, VINE, VINE_LT = "#365424", "#4b7230", "#679144"
		local LEAF_DK, LEAF, LEAF_LT, LEAF_HI = "#4b1f6b", "#6a2c91", "#8a43b8", "#ad6fdc"
		local GH_LT, GH, GH_SH = "#ffffff", "#f1f1f8", "#d9d9ea"
		local STEM, STEM_DK = "#7c9a84", "#5b7563"
		local MINT_N, MINT, MINT_DK = "#7dffd2", "#aef5dc", "#6fd8b4"
		local BLUSH, EYE_DK = "#ffb3c8", "#2a2440"

		local seed = 8808
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end
		local function polar(deg, r, y)
			local a = math.rad(deg)
			return v(math.sin(a) * r, y, -math.cos(a) * r)
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
				local w, d = rnd(1.5, 2.4), rnd(1.2, 1.7)
				local eh = h + rnd(-0.1, edgeH)
				local p = CFrame.Angles(0, math.rad(a), 0) * CFrame.new(0, y0 + eh / 2, -(r + rnd(-0.05, 0.35)))
				B:block(soil, v(w, eh, d), p * ang(0, rnd(-6, 6), 0), pick(edgeCols), S)
			end
		end
		tier(0, 0.8, 7.4, DIRT_DK, 16, { DIRT_DK, DIRT_DK2, DIRT_DK }, 0.35)
		tier(0.8, 0.6, 5.4, DIRT, 11, { DIRT, DIRT_LT, DIRT }, 0.3)
		tier(1.4, 0.4, 3.8, DIRT_LT, 7, { DIRT_LT, DIRT }, 0.2)
		for _, g in { { 7.0, -3.0 }, { -6.6, 3.7 }, { 4.1, 6.2 }, { -7.2, -1.6 }, { 1.0, -7.4 } } do
			B:block(soil, v(0.45, 0.9, 0.45), cf(g[1], 1.0, g[2], 0, rnd(0, 40), 0), GRASS, S)
			B:block(soil, v(0.35, 0.6, 0.35), cf(g[1] + 0.35, 0.95, g[2] + 0.2, 0, rnd(0, 40), 0), GRASS_DK, S)
		end
		for _, h in { { 6.0, 0.8, 1.4, 30 }, { -5.8, 0.8, -2.4, -40 }, { 2.2, 0.8, -6.6, 70 }, { -2.0, 0.8, 6.2, 10 },
			{ 4.4, 1.4, 2.6, 55 }, { -4.6, 1.4, 0.8, 80 }, { 5.2, 0.8, -3.8, 15 } } do
			B:block(soil, v(1.6, 0.22, 0.32), cf(h[1], h[2] + 0.12, h[3], 0, h[4], 0), HAY, S)
			B:block(soil, v(1.1, 0.2, 0.28), cf(h[1] + 0.2, h[2] + 0.13, h[3] + 0.25, 0, h[4] + 35, 0), (h[4] % 20 == 0) and HAY_DK or HAY_LT, S)
		end

		local Y0 = 1.8
		local crop = B:bone("Crop", "Root", v(0, Y0, 0))
		local function seg(a, b, w, col, opts)
			B:bar(crop, a, b, w, w, col, opts)
			B:block(crop, v(w + 0.12, w + 0.12, w + 0.12), CFrame.new(b) * ang(0, rnd(0, 90), 0), col, opts)
		end
		local leaves = {}
		local function leafAt(p, s, col, tilt)
			tilt = tilt or 22
			local c = CFrame.new(p) * ang(rnd(-tilt, tilt), rnd(0, 90), rnd(-tilt, tilt))
			B:block(crop, v(s, s, s), c, col)
			table.insert(leaves, { cf = c, s = s })
		end

		------------------------------------------------------ ghost pumpkins
		-- c = centre CFrame (faces -Z), w = width, h = height; face = "happy" | "wink" | "ooh"
		local faceGlows = {}
		local HF = { [0] = 1.0, 0.9, 0.7 }
		local DF = { [0] = 1.0, 0.95, 0.66 }
		local function pumpkin(c, w, h, face)
			local d = w * 0.92
			-- 5 vertical ribs (like the jack-o'-lanterns): inner ribs are a
			-- tall-shallow + short-deep block pair, outer ribs one rounded block
			local rw = w / 5
			for k = -2, 2 do
				local a = math.abs(k)
				local col = (a == 1) and GH_SH or GH
				local hh, dd = h * HF[a], d * DF[a]
				if a == 2 then
					B:block(crop, v(rw + 0.04, hh * 0.9, dd * 0.86), c * CFrame.new(k * rw, 0, 0), col)
				else
					B:block(crop, v(rw + 0.04, hh, dd * 0.72), c * CFrame.new(k * rw, 0, 0), col)
					B:block(crop, v(rw + 0.02, hh * 0.8, dd), c * CFrame.new(k * rw, 0, 0), (a == 0) and GH_LT or col)
				end
			end
			-- stem with a little curl
			B:block(crop, v(0.16 * w, 0.3 * h, 0.16 * w), c * CFrame.new(0.05, h / 2 + 0.12 * h, 0.05) * ang(8, 20, -10), STEM)
			B:block(crop, v(0.12 * w, 0.1 * h, 0.2 * w), c * CFrame.new(0.15, h / 2 + 0.26 * h, -0.08 * w) * ang(-25, 20, -10), STEM_DK)
			-- carved face on the front
			if face then
				local u = w / 10 -- face unit
				local zc, zd = -0.4875 * d, 0.025 * d + 0.1
				local function px(x, y, sx, sy, col, neon)
					local p = B:block(crop, v(sx * u, sy * u, zd), c * CFrame.new(x * u, y * u, zc), col,
						neon and { mat = "Neon", name = "FaceGlow" } or nil)
					if neon then table.insert(faceGlows, p) end
					return p
				end
				-- eyes: stepped triangles (wide row, narrow row, tip)
				local function eye(x)
					px(x, 0.9, 1.9, 0.6, MINT_N, true)
					px(x, 1.5, 1.2, 0.6, MINT_N, true)
					px(x, 2.05, 0.55, 0.5, MINT_N, true)
				end
				local function wink(x)
					-- a happy closed "^" eye
					px(x, 1.75, 0.7, 0.5, MINT_N, true)
					px(x - 0.65, 1.3, 0.7, 0.5, MINT_N, true)
					px(x + 0.65, 1.3, 0.7, 0.5, MINT_N, true)
				end
				if face == "wink" then
					eye(-1.9)
					wink(1.9)
				else
					eye(-1.9)
					eye(1.9)
				end
				if face == "ooh" then
					-- a little round "ooh" mouth
					px(0, -1.5, 1.2, 1.3, MINT_N, true)
					px(0, -1.5, 0.6, 1.8, MINT_N, true)
				else
					-- toothy grin: wide row, upturned corners, two teeth
					px(0, -1.55, 4.4, 0.9, MINT_N, true)
					px(-2.5, -0.95, 0.7, 0.8, MINT_N, true)
					px(2.5, -0.95, 0.7, 0.8, MINT_N, true)
					px(0, -2.2, 2.6, 0.6, MINT_N, true)
					px(-0.8, -1.25, 0.6, 0.45, GH, false)
					px(0.8, -1.95, 0.6, 0.45, GH, false)
				end
				-- rosy cheeks
				px(-3.1, 0.0, 0.9, 0.5, BLUSH, false)
				px(3.1, 0.0, 0.9, 0.5, BLUSH, false)
				if face == "wink" then
					-- cheeky tongue poking out of the grin
					px(1.0, -2.55, 0.9, 0.7, "#ff7fa8", false)
				end
			end
		end

		-- the stack: big / medium / small
		local P1 = { y = Y0 + 2.3, w = 7.2, h = 4.6 }
		local P2 = { y = P1.y + P1.h / 2 + 1.7, w = 5.6, h = 3.7 }
		local P3 = { y = P2.y + P2.h / 2 + 1.35, w = 4.3, h = 3.0 }
		pumpkin(cf(0, P1.y, 0, 0, 4, 0), P1.w, P1.h, "happy")
		pumpkin(cf(0.1, P2.y, 0.1, 0, -7, 2), P2.w, P2.h, "ooh")
		pumpkin(cf(-0.1, P3.y, 0.0, 0, 9, -3), P3.w, P3.h, "wink")
		-- two little ones on the mound
		pumpkin(cf(4.9, 0.8 + 1.15, -3.6, 0, -28, 2), 3.0, 2.3, "happy")
		pumpkin(cf(-5.2, 0.8 + 0.95, -2.6, 0, 30, -3), 2.5, 1.9, "ooh")

		--------------------------------------------- the spiralling pumpkin vine
		-- radius hugging the stack at height y
		local function hugR(y)
			if y < P1.y + P1.h / 2 then return P1.w / 2 + 0.55 end
			if y < P2.y + P2.h / 2 then return P2.w / 2 + 0.55 end
			return P3.w / 2 + 0.55
		end
		local vinePts = {}
		do
			local prev
			local N = 16
			local yA, yB = Y0 + 0.3, P3.y + P3.h / 2 + 0.6
			for i = 0, N do
				local t = i / N
				local y = yA + t * (yB - yA)
				local deg = 170 + (y - yA) * 37
				local p = polar(deg, hugR(y), y)
				if prev then seg(prev, p, 1.0 - 0.45 * t, (i % 2 == 0) and VINE or VINE_DK) end
				table.insert(vinePts, { p = p, deg = deg, y = y })
				prev = p
			end
		end
		-- root collar + runners to the little pumpkins
		B:block(crop, v(2.2, 0.7, 2.2), CFrame.new(vinePts[1].p + v(0, -0.1, 0)) * ang(0, 20, 0), VINE_DK)
		seg(vinePts[1].p, v(-3.4, 2.2, 1.6), 0.5, VINE)
		seg(v(-3.4, 2.2, 1.6), v(-4.6, 2.3, -1.4), 0.45, VINE_DK)
		seg(vinePts[1].p, v(3.6, 2.0, 1.8), 0.5, VINE_DK)
		seg(v(3.6, 2.0, 1.8), v(4.6, 2.4, -2.4), 0.45, VINE)

		-- big leaf cubes along the vine, kept off the faces (front arc)
		local leafCols = { LEAF, LEAF_DK, LEAF_LT, LEAF, LEAF_HI, LEAF_DK, LEAF_LT }
		local li = 0
		for i, q in vinePts do
			local a = ((q.deg % 360) + 360) % 360
			local nearFront = a < 75 or a > 285
			if i % 2 == 0 and i >= 2 and not nearFront then
				li += 1
				local s = 3.4 - 1.2 * (i / #vinePts) + rnd(-0.2, 0.2)
				leafAt(polar(q.deg + ((li % 2 == 0) and 12 or -12), hugR(q.y) + s * 0.35, q.y + 0.2), s, leafCols[(li - 1) % #leafCols + 1])
			end
		end
		-- a couple of big ground leaves round the back of the stack
		leafAt(polar(150, 5.4, 2.4), 3.0, LEAF_DK, 12)
		leafAt(polar(215, 5.6, 2.3), 2.8, LEAF, 12)
		leafAt(polar(95, 5.6, 2.0), 2.4, LEAF_LT, 12)
		leafAt(polar(265, 5.3, 2.1), 2.5, LEAF_HI, 12)

		-- wispy mint tendrils curling off the vine, glowing tips
		local tips = {}
		local function curl(base, outDeg, up, len, sz)
			local pts = { base }
			local a = outDeg
			local p = base
			for k = 1, 4 do
				a = a + 55
				p = p + polar(a, len * (1 - 0.18 * k), 0) + v(0, up * (k <= 2 and 1 or -0.4), 0)
				table.insert(pts, p)
			end
			for k = 1, #pts - 1 do
				seg(pts[k], pts[k + 1], sz * (1 - 0.15 * k), (k % 2 == 0) and MINT or MINT_DK)
			end
			local t = B:block(crop, v(sz * 1.1, sz * 1.1, sz * 1.1), CFrame.new(pts[#pts]) * ang(45, 0, 45), MINT_N, { mat = "Neon", name = "WispTip" })
			table.insert(tips, t)
		end
		curl(vinePts[3].p, vinePts[3].deg - 40, 0.5, 1.1, 0.34)
		curl(vinePts[6].p, vinePts[6].deg + 20, 0.6, 1.0, 0.32)
		curl(vinePts[9].p, vinePts[9].deg - 30, 0.5, 1.0, 0.3)
		curl(vinePts[12].p, vinePts[12].deg + 30, 0.5, 0.9, 0.3)
		curl(vinePts[15].p, vinePts[15].deg - 20, 0.5, 0.85, 0.28)

		------------------------------------------------------------- top crown
		local topY = P3.y + P3.h / 2
		leafAt(v(1.6, topY + 0.8, 0.9), 2.6, LEAF)
		leafAt(v(-1.5, topY + 0.7, 1.0), 2.4, LEAF_LT)
		leafAt(v(0.1, topY + 1.2, 1.9), 2.3, LEAF_DK)
		leafAt(v(0.5, topY + 2.2, 0.6), 1.9, LEAF_HI)
		-- the tall mint wisp curling up out of the crown (a ghostly "?" swirl)
		do
			local pts = {
				v(0.0, topY + 1.4, 0.2), v(0.3, topY + 2.8, 0.0), v(1.1, topY + 3.9, -0.2),
				v(1.0, topY + 5.0, -0.3), v(0.1, topY + 5.6, -0.3), v(-0.8, topY + 5.1, -0.2), v(-0.7, topY + 4.3, -0.1),
			}
			for k = 1, #pts - 1 do
				seg(pts[k], pts[k + 1], 0.55 - 0.05 * k, (k % 2 == 0) and MINT or MINT_DK)
			end
			local t = B:block(crop, v(0.6, 0.6, 0.6), CFrame.new(pts[#pts]) * ang(45, 0, 45), MINT_N, { mat = "Neon", name = "WispTip" })
			table.insert(tips, 1, t)
		end

		----------------------------------------------------- floating sheet ghosts
		local ghosts = {}
		local function ghost(p, s, yaw)
			local c = CFrame.new(p) * ang(0, yaw, 0)
			B:block(crop, v(1.6 * s, 1.5 * s, 1.4 * s), c, GH)
			B:block(crop, v(1.2 * s, 0.4 * s, 1.1 * s), c * CFrame.new(0, 0.9 * s, 0), GH)
			-- wavy hem: three little drips
			for k = -1, 1 do
				B:block(crop, v(0.45 * s, (0.5 + 0.2 * (k % 2)) * s, 1.2 * s), c * CFrame.new(k * 0.55 * s, -0.95 * s, 0), (k == 0) and GH_SH or GH)
			end
			-- eyes + tiny mouth
			B:block(crop, v(0.28 * s, 0.4 * s, 0.1), c * CFrame.new(-0.35 * s, 0.2 * s, -0.72 * s), EYE_DK)
			B:block(crop, v(0.28 * s, 0.4 * s, 0.1), c * CFrame.new(0.35 * s, 0.2 * s, -0.72 * s), EYE_DK)
			local m = B:block(crop, v(0.3 * s, 0.22 * s, 0.1), c * CFrame.new(0, -0.25 * s, -0.72 * s), MINT_N, { mat = "Neon", name = "GhostMouth" })
			table.insert(ghosts, m)
		end
		ghost(v(-5.6, 13.0, -0.6), 1.0, 25)
		ghost(v(5.4, 15.4, 0.8), 0.85, -30)

		---------------------------------------------------------------- bling
		B:emitter(tips[1], "glow", { name = "WispGlow", color = "#7dffd2", rate = 2, size = 1.2 })
		B:emitter(tips[1], "sparkle", { name = "WispSparkle", color = { "#7dffd2", "#e2b8ff" }, rate = 4, size = 0.4 })
		B:emitter(faceGlows[1], "glow", { name = "FaceGlowFx", color = "#7dffd2", rate = 1.5, size = 1.6 })
		B:emitter(tips[3], "sparkle", { name = "TendrilSparkle", color = { "#aef5dc", "#c58cf0" }, rate = 3, size = 0.35 })
		B:emitter(ghosts[1], "sparkle", { name = "GhostSparkle", color = { "#ffffff", "#7dffd2" }, rate = 2, size = 0.35 })
		B:light(faceGlows[1], { color = "#7dffd2", brightness = 1.2, range = 14, name = "GhostLight" })
	end,
}
