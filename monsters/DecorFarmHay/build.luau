--!nocheck
-- Hay Bale Stack (Sunny Farm decoration, small accent ~6 studs). Chunky golden
-- hay bales -- two on the ground and one on top, turned a little -- each with
-- darker cut ends, brown twine bands and loose straw poking out. A pitchfork
-- leans against the stack and a bright blue watering can sits in front.
-- Footing: a scatter of loose straw and a few grass tufts (bone "Base").
-- Faces -Z. Static prop: no motion.luau.
return {
	DisplayName = "Hay Bale Stack",
	Rarity = "Decor",
	Element = "Sunny Farm",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local HAY_LT, HAY, HAY_DK = "#fff0a0", "#f7d462", "#e2ad38"
		local TWINE = "#d2452e"
		local WOOD, WOOD_DK = "#b8773a", "#6b4220"
		local METAL, METAL_DK = "#c9d1d9", "#8f98a3"
		local CAN, CAN_DK, CAN_LT = "#2f9be0", "#1f74b5", "#7fd0ff"
		local GRASS, GRASS_DK = "#5fd23f", "#3fb43a"

		------------------------------------------------------------------
		-- footing: loose straw + grass tufts
		------------------------------------------------------------------
		local base = B:bone("Base", "Root", v(0, 0, 0))
		local straw = {
			{ -3.4, -2.2, 1.4, 25 }, { 3.0, -2.6, 1.2, -30 }, { -1.0, -3.0, 1.0, 70 },
			{ 3.6, 1.6, 1.3, 10 }, { -3.6, 1.8, 1.1, -50 }, { 0.6, 2.8, 1.2, 40 },
		}
		for i, s in straw do
			B:block(base, v(s[3], 0.15, 0.35), cf(s[1], 0.075, s[2], 0, s[4], 0), (i % 2 == 0) and HAY_LT or HAY)
		end
		local function tuft(x, z, h)
			B:block(base, v(0.5, h, 0.5), cf(x, h / 2, z), GRASS)
			B:block(base, v(0.4, h * 0.7, 0.4), cf(x + 0.35, h * 0.35 + 0.08, z + 0.2, 0, 0, -18), GRASS_DK)
			B:block(base, v(0.4, h * 0.75, 0.4), cf(x - 0.35, h * 0.37 + 0.08, z - 0.15, 0, 0, 18), GRASS)
		end
		tuft(-3.9, -0.6, 0.9)
		tuft(4.0, 0.0, 0.8)
		tuft(-2.2, 3.0, 0.8)

		------------------------------------------------------------------
		-- hay bales
		------------------------------------------------------------------
		local stack = "Root"
		local L, H, D = 3.6, 1.8, 2.2 -- length (local X), height, depth
		local function bale(x, y, z, yaw)
			local c = CFrame.new(x, y + H / 2, z) * CFrame.Angles(0, math.rad(yaw), 0)
			B:block(stack, v(L, H, D), c, HAY)
			-- darker cut ends
			B:block(stack, v(0.2, H - 0.3, D - 0.3), c * CFrame.new(L / 2 + 0.02, 0, 0), HAY_DK)
			B:block(stack, v(0.2, H - 0.3, D - 0.3), c * CFrame.new(-L / 2 - 0.02, 0, 0), HAY_DK)
			-- lighter top layer
			B:block(stack, v(L - 0.4, 0.2, D - 0.4), c * CFrame.new(0, H / 2 + 0.02, 0), HAY_LT)
			-- straw streaks along the long sides
			for _, sz in { -1, 1 } do
				B:block(stack, v(L - 0.6, 0.14, 0.1), c * CFrame.new(-0.1, 0.35, sz * (D / 2 + 0.03)), HAY_LT)
				B:block(stack, v(L - 1.2, 0.14, 0.1), c * CFrame.new(0.3, -0.35, sz * (D / 2 + 0.03)), HAY_DK)
			end
			-- two twine bands
			for _, bx in { -0.85, 0.85 } do
				B:block(stack, v(0.22, H + 0.12, D + 0.12), c * CFrame.new(bx, 0, 0), TWINE)
			end
			-- straw poking out of the ends
			B:block(stack, v(0.5, 0.15, 0.15), c * CFrame.new(L / 2 + 0.2, 0.35, -0.4) * CFrame.Angles(0, 0, math.rad(20)), HAY_LT)
			B:block(stack, v(0.5, 0.15, 0.15), c * CFrame.new(-L / 2 - 0.2, -0.3, 0.5) * CFrame.Angles(0, 0, math.rad(-25)), HAY_LT)
			return c
		end
		bale(-1.85, 0.06, 0.3, 4)
		bale(1.9, 0.06, 0.1, -6)
		local top = bale(0.1, H + 0.18, 0.25, 12)
		-- loose tufts on top of the stack
		B:block(stack, v(0.2, 0.6, 0.2), top * CFrame.new(-0.6, H / 2 + 0.35, 0.3) * CFrame.Angles(0, 0, math.rad(15)), HAY_LT)
		B:block(stack, v(0.2, 0.5, 0.2), top * CFrame.new(0.4, H / 2 + 0.3, -0.4) * CFrame.Angles(math.rad(-20), 0, 0), HAY)

		-- a small loose hay heap at the back-left
		local hp = CFrame.new(-3.3, 0, 2.1) * CFrame.Angles(0, math.rad(15), 0)
		B:block(stack, v(2.2, 0.5, 1.8), hp * CFrame.new(0, 0.25, 0), HAY_DK)
		B:block(stack, v(1.6, 0.45, 1.3), hp * CFrame.new(0.1, 0.7, 0.05), HAY)
		B:block(stack, v(0.9, 0.35, 0.8), hp * CFrame.new(0.05, 1.08, 0), HAY_LT)
		B:block(stack, v(0.15, 0.6, 0.15), hp * CFrame.new(-0.2, 1.4, 0.1) * CFrame.Angles(0, 0, math.rad(25)), HAY_LT)
		B:block(stack, v(0.7, 0.15, 0.15), hp * CFrame.new(1.2, 0.3, -0.5) * CFrame.Angles(0, math.rad(30), math.rad(15)), HAY_LT)

		------------------------------------------------------------------
		-- pitchfork leaning on the right of the stack
		------------------------------------------------------------------
		local a = v(4.7, 0.22, -1.3) -- butt on the ground
		local b = v(2.75, 4.5, -1.5) -- top of the handle (tines go on from here)
		B:bar(stack, a, b, 0.32, 0.32, WOOD)
		local fcf, len = P.aim(a, b)
		local head = fcf * CFrame.new(0, 0, -len / 2) -- local -Z = up the handle
		B:block(stack, v(0.45, 0.45, 0.35), head * CFrame.new(0, 0, -0.1), METAL_DK)
		B:block(stack, v(1.4, 0.22, 0.25), head * CFrame.new(0, 0, -0.4), METAL)
		for _, tx in { -0.6, 0, 0.6 } do
			B:block(stack, v(0.18, 0.18, 1.1), head * CFrame.new(tx, 0, -1.0), METAL)
		end

		------------------------------------------------------------------
		-- watering can in front-left
		------------------------------------------------------------------
		local cc = CFrame.new(-2.2, 0, -2.6) * CFrame.Angles(0, math.rad(-25), 0)
		local function at(x, y, z) return cc * CFrame.new(x, y, z) end
		B:block(stack, v(1.7, 1.5, 1.2), at(0, 0.85, 0), CAN)
		B:block(stack, v(1.8, 0.25, 1.3), at(0, 0.15, 0), CAN_DK)
		B:block(stack, v(1.8, 0.2, 1.3), at(0, 1.55, 0), CAN_DK)
		B:block(stack, v(0.6, 0.6, 0.1), at(-0.3, 1.0, -0.62), CAN_LT)
		-- carry handle (arch on top)
		B:block(stack, v(0.25, 0.7, 0.25), at(-0.55, 1.95, 0), CAN_DK)
		B:block(stack, v(0.25, 0.7, 0.25), at(0.45, 1.95, 0), CAN_DK)
		B:block(stack, v(1.25, 0.25, 0.25), at(-0.05, 2.3, 0), CAN_DK)
		-- spout + rose
		local s0 = cc * Vector3.new(0.75, 0.6, 0)
		local s1 = cc * Vector3.new(1.85, 1.75, 0)
		B:bar(stack, s0, s1, 0.3, 0.3, CAN)
		B:block(stack, v(0.35, 0.6, 0.6), at(2.0, 1.9, 0) * CFrame.Angles(0, 0, math.rad(-40)), CAN_DK)
	end,
}
