--!nocheck
-- Daisy Meadow Sign (Honey Hills decoration, small, static).
-- A cute chunky wooden signboard on two capped posts, framed by daisies:
-- * footing (bone "Soil", parts "Soil"): a little oval turf pad with a soil
--   rim, flat stepping stones and grass tufts
-- * the SIGN (bone "Sign"): two dark posts with stepped caps, a board of
--   three warm planks inside a darker frame with nail heads; the front is
--   painted with a tiny meadow scene (green hill, a big + small daisy and a
--   happy bee with a dotted flight path); plain planks on the back
-- * a daisy garland along the top edge, daisies climbing the left post,
--   tall daisies + clover (with white clover blossoms) bunched at the base
-- * a little pink butterfly resting on the right post cap
return {
	DisplayName = "Daisy Meadow Sign",
	Rarity = "Decor",
	Element = "Honey Hills",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette ------------------------------------------------------------
		local SOIL_DK = "#6b4226"
		local GR_DK, GR, GR_LT, GR_XL = "#7cae32", "#97c83e", "#b2d84c", "#d2e872"
		local LEAF, LEAF_DK = "#5dbd40", "#46a83a"
		local CLOVER, CLOVER_DK = "#3f9a3c", "#2f7f30"
		local STONE, STONE_LT = "#a49a8c", "#c4bcae"
		local DAISY, DAISY_SH, DAISY_EYE = "#fffaf2", "#f1e6dc", "#ffc93a"
		local CLV_FL, CLV_TIP = "#fff4f8", "#ffb6d0"
		local POST, POST_DK = "#8a5a32", "#6e4527"
		local WOOD_DK, WOOD, WOOD_LT = "#b47a44", "#cf9356", "#e2a96a"
		local FRAME = "#7a4c2b"
		local NAIL = "#4a3a30"
		local PAINT_GR, PAINT_GR2 = "#7cc443", "#5fae36"
		local BEE_Y, BEE_K, WING = "#ffd23a", "#2a2126", "#ffffff"
		local BFLY, BFLY_DK = "#ff9cc4", "#e46aa0"

		local seed = 22301
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function pick(t)
			return t[math.floor(rnd() * #t) + 1]
		end

		------------------------------------------------------------------
		-- FOOTING (bone "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function pad(bone, c, r, h, col, opts)
			B:block(bone, v(2 * r, h, 1.15 * r), c, col, opts)
			B:block(bone, v(1.15 * r, h - 0.02, 2 * r), c, col, opts)
			B:block(bone, v(1.72 * r, h - 0.04, 1.72 * r), c, col, opts)
		end
		for _, x in { -1.5, 1.5 } do
			pad(soil, cf(x, 0.22, 0), 3.4, 0.44, SOIL_DK, S)
			pad(soil, cf(x, 0.42, 0), 3.1, 0.3, GR_DK, S)
		end
		for i = 0, 11 do
			local a = i / 12 * 360 + jit(8)
			local ar = rad(a)
			local x, z = math.sin(ar) * 4.6, -math.cos(ar) * 3.2
			local h = 0.5 + rnd() * 0.2
			B:block(soil, v(1.6 + rnd() * 0.5, h, 1.2), cf(x, h / 2, z, 0, -a + jit(8), 0), pick({ GR, GR_DK, GR_LT }), S)
		end
		local TOP = 0.57
		-- stepping stones in front
		B:block(soil, v(1.3, 0.3, 1.0), cf(-0.6, TOP + 0.05, -2.4, 0, 12, 0), STONE_LT, S)
		B:block(soil, v(1.0, 0.3, 0.9), cf(0.9, TOP + 0.04, -3.0, 0, -18, 0), STONE, S)
		B:block(soil, v(0.8, 0.3, 0.7), cf(3.6, TOP + 0.03, 1.6, 0, 30, 0), STONE, S)
		-- grass tufts
		for _, g in { { -4.2, 1.2 }, { 4.3, -0.9 }, { -2.6, 2.4 }, { 1.8, 2.6 } } do
			B:block(soil, v(0.35, 1.1, 0.35), cf(g[1], TOP + 0.45, g[2], 0, jit(30), -8), GR_LT, S)
			B:block(soil, v(0.3, 0.8, 0.3), cf(g[1] + 0.32, TOP + 0.35, g[2] + 0.2, 0, jit(30), 14), GR, S)
			B:block(soil, v(0.28, 0.9, 0.28), cf(g[1] - 0.3, TOP + 0.4, g[2] - 0.15, 10, jit(30), 0), GR_XL, S)
		end

		------------------------------------------------------------------
		-- THE SIGN (bone "Sign")
		------------------------------------------------------------------
		local sign = B:bone("Sign", "Root", v(0, TOP, 0))
		local PX = 2.75 -- post x
		local POST_TOP = 6.6
		for _, sx in { -1, 1 } do
			local x = sx * PX
			B:block(sign, v(0.9, POST_TOP - TOP + 0.1, 0.9), cf(x, (POST_TOP + TOP) / 2 - 0.05, 0), POST)
			B:block(sign, v(1.2, 0.5, 1.2), cf(x, TOP + 0.2, 0, 0, 8 * sx, 0), POST_DK) -- footing collar
			B:block(sign, v(1.25, 0.4, 1.25), cf(x, POST_TOP + 0.15, 0), POST_DK)
			B:block(sign, v(0.8, 0.35, 0.8), cf(x, POST_TOP + 0.5, 0), POST)
			-- grain lines
			B:block(sign, v(0.1, 1.6, 0.92), cf(x + 0.2 * sx, 1.9, 0), POST_DK)
		end
		-- board: three planks inside a frame
		local BY0, BH, BW = 2.9, 3.0, 5.0
		local PL = { WOOD, WOOD_LT, WOOD_DK }
		for i = 0, 2 do
			local w = BW - ((i == 1) and 0 or 0.0) + jit(0.1)
			B:block(sign, v(w, BH / 3 - 0.04, 0.5), cf(jit(0.05), BY0 + BH / 6 + i * BH / 3, 0), PL[i + 1])
		end
		local FY0, FY1 = BY0 - 0.15, BY0 + BH + 0.15
		B:block(sign, v(BW + 1.0, 0.4, 0.62), cf(0, FY1, 0), FRAME)
		B:block(sign, v(BW + 0.7, 0.36, 0.62), cf(0, FY0, 0), FRAME)
		for _, sx in { -1, 1 } do
			B:block(sign, v(0.36, BH + 0.5, 0.62), cf(sx * (BW / 2 + 0.05), BY0 + BH / 2, 0), FRAME)
			-- nail heads (front + back)
			for _, y in { FY0, FY1 } do
				for _, z in { -0.33, 0.33 } do
					B:block(sign, v(0.22, 0.22, 0.06), cf(sx * (BW / 2 + 0.05), y, z), NAIL)
				end
			end
		end
		-- ---- painted meadow scene on the front (z < 0) ----
		local ZP = -0.29
		local function paint(w, h, x, y, col, rz, dz)
			return B:block(sign, v(w, h, 0.08), cf(x, y, ZP - (dz or 0), 0, 0, rz or 0), col)
		end
		-- green hill along the bottom
		paint(4.9, 0.55, 0, BY0 + 0.3, PAINT_GR2)
		paint(2.6, 0.45, -1.0, BY0 + 0.75, PAINT_GR)
		paint(1.2, 0.3, -1.0, BY0 + 1.1, PAINT_GR)
		paint(1.6, 0.35, 1.7, BY0 + 0.7, PAINT_GR, 0, 0.005)
		-- painted daisies
		local function pDaisy(x, y, s, stem)
			paint(0.16, stem, x, y - stem / 2, PAINT_GR2, 0, 0.01)
			paint(0.42 * s, 0.24 * s, x + 0.25 * s, y - stem * 0.55, PAINT_GR2, 25, 0.01)
			for k = 0, 3 do
				paint(1.0 * s, 0.3 * s, x, y, (k % 2 == 0) and DAISY or DAISY_SH, k * 45, 0.02 + k * 0.004)
			end
			paint(0.38 * s, 0.38 * s, x, y, DAISY_EYE, 45, 0.04)
		end
		pDaisy(-1.3, BY0 + 2.05, 1.35, 1.0)
		pDaisy(0.15, BY0 + 1.55, 0.85, 0.6)
		-- painted bee + dotted flight path
		do
			local bx, by = 1.45, BY0 + 2.25
			paint(1.0, 0.72, bx, by, BEE_Y, 0, 0.0)
			paint(0.18, 0.74, bx - 0.05, by, BEE_K, 0, 0.01)
			paint(0.18, 0.74, bx + 0.3, by, BEE_K, 0, 0.01)
			paint(0.46, 0.5, bx - 0.68, by + 0.03, BEE_K, 0, 0.0)
			paint(0.42, 0.34, bx - 0.05, by + 0.48, WING, -20, 0.02)
			paint(0.36, 0.3, bx + 0.32, by + 0.45, WING, 20, 0.02)
			paint(0.14, 0.14, bx + 0.55, by - 0.05, BEE_K, 0, 0.01)
			for k, d in { { 0.95, -0.5 }, { 1.4, -0.75 }, { 1.85, -0.55 } } do
				paint(0.2, 0.12, bx + 0.0 + d[1] * 0.55, by + d[2], "#8a5a32", 0, 0)
				local _ = k
			end
		end
		-- back side: a single painted daisy so the back is not blank
		do
			local zb = 0.29
			for k = 0, 1 do
				B:block(sign, v(1.1, 0.32, 0.08), cf(0, BY0 + 1.5, zb, 0, 0, k * 90 + 45), DAISY)
				B:block(sign, v(1.1, 0.32, 0.08), cf(0, BY0 + 1.5, zb + 0.01, 0, 0, k * 90), DAISY_SH)
			end
			B:block(sign, v(0.4, 0.4, 0.08), cf(0, BY0 + 1.5, zb + 0.03, 0, 0, 45), DAISY_EYE)
		end

		------------------------------------------------------------------
		-- DAISIES (3D): face along local -Z of frame c
		------------------------------------------------------------------
		local function daisyF(bone, c, s, opts)
			B:block(bone, v(1.05 * s, 0.34 * s, 0.16), c, DAISY, opts)
			B:block(bone, v(0.34 * s, 1.05 * s, 0.17), c, DAISY, opts)
			B:block(bone, v(0.95 * s, 0.3 * s, 0.15), c * ang(0, 0, 45), DAISY_SH, opts)
			B:block(bone, v(0.3 * s, 0.95 * s, 0.155), c * ang(0, 0, 45), DAISY_SH, opts)
			B:block(bone, v(0.38 * s, 0.38 * s, 0.26), c * CFrame.new(0, 0, -0.05), DAISY_EYE, opts)
		end
		-- a raised crest plank on top of the board with a big daisy medallion
		local CY0 = FY1 + 0.18
		B:block(sign, v(2.5, 0.95, 0.5), cf(0, CY0 + 0.45, 0), WOOD_LT)
		B:block(sign, v(3.1, 0.34, 0.62), cf(0, CY0 + 1.05, 0), FRAME)
		for _, sx in { -1, 1 } do
			B:block(sign, v(0.32, 1.05, 0.62), cf(sx * 1.38, CY0 + 0.45, 0), FRAME)
		end
		daisyF(sign, cf(0, CY0 + 0.5, -0.4, 0, 0, 10), 1.45)
		-- garland along the top of the frame: daisies + leaves either side
		local GY = FY1 + 0.32
		for _, g in { { -1.95, "d" }, { 1.95, "d" }, { -2.85, "l" }, { 2.85, "l" } } do
			if g[2] == "d" then
				daisyF(sign, cf(g[1], GY + 0.05 + jit(0.08), -0.36, 0, 0, jit(20)), 0.95)
			else
				local sx = (g[1] > 0) and 1 or -1
				B:block(sign, v(0.9, 0.3, 0.5), cf(g[1], GY - 0.02, -0.2, 0, jit(15), 25 * sx), (math.abs(g[1]) > 2) and LEAF or LEAF_DK)
			end
		end
		B:block(sign, v(6.6, 0.25, 0.35), cf(0, GY - 0.12, -0.15), LEAF_DK)
		-- leaves + daisies trailing down the left post
		for k, y in { 5.6, 4.6, 3.6 } do
			local sx = (k % 2 == 0) and 1 or -1
			B:block(sign, v(0.7, 0.25, 0.45), cf(-PX + 0.35 * sx, y, -0.55, 0, 0, 30 * sx), (k % 2 == 0) and LEAF or LEAF_DK)
		end
		daisyF(sign, cf(-PX - 0.1, 5.0, -0.62, 0, 0, 15), 0.75)
		daisyF(sign, cf(-PX + 0.15, 3.1, -0.62, 0, 0, -10), 0.65)
		-- a vine strand on the post
		B:bar(sign, v(-PX - 0.1, 6.2, -0.5), v(-PX + 0.15, 2.4, -0.5), 0.18, 0.18, LEAF_DK)

		------------------------------------------------------------------
		-- tall daisies + clover around the base (on Soil)
		------------------------------------------------------------------
		local function stemDaisy(x, z, h, s, lean)
			local base = v(x, TOP, z)
			local tip = base + v(lean or 0, h, 0)
			B:bar(soil, base, tip, 0.18, 0.18, GR_DK, S)
			B:block(soil, v(0.55, 0.14, 0.3), CFrame.new(base:Lerp(tip, 0.4)) * ang(0, jit(60), 25), LEAF, S)
			-- head tilted up toward the viewer
			daisyF(soil, CFrame.new(tip) * ang(0, jit(20), 0) * ang(55, 0, jit(30)), s, S)
		end
		stemDaisy(-3.9, -0.6, 1.4, 1.0, 0.1)
		stemDaisy(-3.3, -1.5, 2.0, 1.1, -0.2)
		stemDaisy(-1.9, -1.2, 1.1, 0.85, 0.0)
		stemDaisy(3.7, -0.9, 1.8, 1.1, 0.2)
		stemDaisy(2.6, -1.6, 1.2, 0.9, 0.0)
		stemDaisy(4.1, 0.6, 1.3, 0.9, 0.1)
		stemDaisy(-4.2, 1.0, 1.0, 0.8, 0.0)
		stemDaisy(0.7, -1.4, 0.8, 0.8, 0.1)
		stemDaisy(-0.4, 1.6, 1.2, 0.85, 0.0)
		-- clover patches + white clover blossoms
		local function clover(x, z, flower)
			local yaw = rnd() * 120
			for k = 0, 2 do
				local c = cf(x, TOP + 0.32, z, 0, yaw + k * 120, 0) * CFrame.new(0, 0, -0.32)
				B:block(soil, v(0.55, 0.14, 0.55), c * ang(0, 45, 0), (k == 0) and CLOVER_DK or CLOVER, S)
			end
			if flower then
				B:block(soil, v(0.14, 0.7, 0.14), cf(x + 0.3, TOP + 0.45, z + 0.2), CLOVER_DK, S)
				B:block(soil, v(0.5, 0.45, 0.5), cf(x + 0.3, TOP + 0.9, z + 0.2, 0, 45, 0), CLV_FL, S)
				B:block(soil, v(0.36, 0.22, 0.36), cf(x + 0.3, TOP + 1.18, z + 0.2, 0, 45, 0), CLV_TIP, S)
			end
		end
		clover(-1.0, -1.9, true)
		clover(1.6, -2.2, false)
		clover(3.1, -2.0, true)
		clover(-2.6, -2.3, false)
		clover(-3.6, 1.9, true)
		clover(2.8, 1.5, false)
		clover(0.4, 2.0, true)
		clover(-4.5, -0.1, false)

		------------------------------------------------------------------
		-- a little pink butterfly on the right post cap
		------------------------------------------------------------------
		do
			local c = cf(PX, POST_TOP + 0.75, -0.05, 0, 25, 0)
			B:block(sign, v(0.18, 0.18, 0.7), c, BEE_K)
			for _, sx in { -1, 1 } do
				B:block(sign, v(0.08, 0.8, 0.65), c * ang(0, 0, -sx * 25) * CFrame.new(0, 0.45, -0.1), BFLY)
				B:block(sign, v(0.09, 0.5, 0.45), c * ang(0, 0, -sx * 25) * CFrame.new(0, 0.3, 0.3), BFLY_DK)
				B:block(sign, v(0.06, 0.4, 0.06), c * CFrame.new(sx * 0.08, 0.2, -0.45) * ang(-30, 0, sx * -15), BEE_K)
			end
		end
	end,
}
