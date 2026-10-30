--!nocheck
-- Candy Corn Stalk (Scarecrow Stage plant #2, Uncommon).
-- One thick corn stalk with node rings on a straw-strewn stepped mound, six
-- broad arching leaf blades (twisted to face the front, straw-gold tips) and
-- a single small golden tassel. The hero is three big candy-corn cobs fanning
-- out at the front: yellow base, orange middle, white tip with a glowing cap,
-- in small peeled husks. Two loose candy-corn kernels lie on the soil.
-- Static prop: no motion.luau.
return {
	DisplayName = "Candy Corn Stalk",
	Rarity = "Uncommon",
	Element = "Harvest",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette
		local DIRT_DK, DIRT, DIRT_LT = "#4a2a16", "#744526", "#93603a"
		local GRASS = "#6fbf3a"
		local HAY, HAY_DK = "#e8c45a", "#c99a35"
		local STALK_DK, STALK, STALK_LT = "#3f7a2a", "#56963a", "#7cb848"
		local LEAF_DK, LEAF, LEAF_TIP = "#3a8530", "#5aa83e", "#b5b444"
		local HUSK, HUSK_LT = "#7fae45", "#b9cf68"
		local TASSEL, TASSEL_DK = "#f0cc5a", "#c9962e"
		local CC_Y, CC_O, CC_W = "#ffc61f", "#ff7a14", "#fff9ec"
		local SHINE = "#fffbe6"

		local seed = 202
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		------------------------------------------------------------ soil mound
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		B:block(soil, v(6.8, 0.7, 4.8), cf(0, 0.35, 0), DIRT_DK, S)
		B:block(soil, v(4.8, 0.7, 6.8), cf(0, 0.35, 0), DIRT_DK, S)
		local edge = 10
		for i = 0, edge - 1 do
			local a = (i + 0.5) / edge * math.pi * 2
			local r = 3.25 + rnd(-0.15, 0.2)
			local h = 0.6 + rnd(0, 0.35)
			local col = (i % 3 == 0) and DIRT or DIRT_DK
			B:block(soil, v(rnd(1.3, 1.8), h, rnd(1.0, 1.4)), cf(math.cos(a) * r, h / 2, math.sin(a) * r, 0, -math.deg(a) + rnd(-12, 12), 0), col, S)
		end
		B:block(soil, v(4.6, 0.6, 3.4), cf(0, 0.95, 0), DIRT, S)
		B:block(soil, v(3.4, 0.6, 4.6), cf(0, 0.95, 0), DIRT, S)
		B:block(soil, v(2.6, 0.4, 2.6), cf(0, 1.4, 0, 0, 15, 0), DIRT_LT, S)
		-- grass tufts
		B:block(soil, v(0.35, 0.7, 0.35), cf(-3.5, 0.35, -1.5), GRASS, S)
		B:block(soil, v(0.3, 0.5, 0.3), cf(-3.2, 0.25, -1.95), GRASS, S)
		B:block(soil, v(0.35, 0.6, 0.35), cf(3.2, 0.3, 2.2), GRASS, S)
		-- straw bits
		for _, h in { { -2.3, 1.27, 1.5, 30 }, { 2.6, 0.72, -1.6, -55 }, { 1.3, 1.27, 1.9, 75 }, { -2.9, 0.72, -0.4, 10 } } do
			B:block(soil, v(1.4, 0.14, 0.18), cf(h[1], h[2] + 0.07, h[3], 0, h[4], 0), HAY, S)
			B:block(soil, v(1.0, 0.12, 0.16), cf(h[1] + 0.1, h[2] + 0.09, h[3] + 0.15, 0, h[4] + 25, 0), HAY_DK, S)
		end
		-- loose candy-corn kernels on the soil
		local function kernel(x, y, z, ry)
			local c = cf(x, y, z, 0, ry, 70)
			B:block(soil, v(0.5, 0.3, 0.5), c * CFrame.new(0, -0.2, 0), CC_Y, S)
			B:block(soil, v(0.4, 0.25, 0.4), c * CFrame.new(0, 0.07, 0), CC_O, S)
			B:block(soil, v(0.26, 0.2, 0.26), c * CFrame.new(0, 0.28, 0), CC_W, S)
		end
		kernel(-1.4, 1.5, -1.9, 20)
		kernel(2.3, 0.95, -2.4, -40)

		------------------------------------------------------------ stalk
		local crop = B:bone("Crop", "Root", v(0, 1.6, 0))
		local leafParts = {}
		local SX, SZ = 0, 0.5

		-- one thick stalk: stacked segments with darker node rings
		local segH, n = 1.4, 5
		for i = 0, n - 1 do
			local y = 1.5 + i * segH
			local w = 1.5 - i * 0.08
			B:block(crop, v(w, segH + 0.05, w), cf(SX, y + segH / 2, SZ, 0, i * 8, 0), (i % 2 == 0) and STALK or STALK_LT)
			if i > 0 then
				B:block(crop, v(w + 0.25, 0.3, w + 0.25), cf(SX, y, SZ, 0, i * 8 + 45, 0), STALK_DK)
			end
		end
		local topY = 1.5 + n * segH

		-- broad arching leaf blade: 3 wide stepped slabs, same arch for every leaf
		local function blade(y, yaw, s)
			local c = CFrame.new(SX, y, SZ) * ang(0, yaw, 0) * ang(38, 0, 0) * CFrame.new(0, 0, -0.5)
			local widths = { 2.1, 1.75, 1.3 }
			local lens = { 1.9, 1.6, 1.3 }
			-- twist the blade so its broad face turns toward the front of the plant
			local roll = (math.sin(math.rad(yaw)) > 0) and -40 or 40
			for i = 1, 3 do
				local col = (i == 3) and LEAF_TIP or ((i == 1) and LEAF or LEAF_DK)
				local L = lens[i] * s
				local part = B:block(crop, v(widths[i] * s, 0.4, L + 0.15), c * CFrame.new(0, 0, -L / 2) * ang(0, 0, roll), col)
				table.insert(leafParts, part)
				c = c * CFrame.new(0, 0, -L) * ang(-26, 0, 0)
			end
		end
		-- leaves go out to the sides and back, keeping the front clear for the cobs
		blade(2.6, 90, 1.0)
		blade(3.6, 270, 1.0)
		blade(4.8, 145, 0.95)
		blade(5.8, 215, 0.9)
		blade(6.7, 110, 0.8)
		blade(7.2, 250, 0.75)

		-- one small tassel on top
		local tp = v(SX, topY, SZ)
		B:block(crop, v(0.6, 0.8, 0.6), CFrame.new(tp + v(0, 0.35, 0)), TASSEL)
		B:block(crop, v(0.36, 0.7, 0.36), CFrame.new(tp + v(0, 1.05, 0)) * ang(0, 45, 0), TASSEL_DK)
		for i = 0, 2 do
			local c = CFrame.new(tp + v(0, 0.55, 0)) * ang(0, i * 120 + 30, 0) * ang(40, 0, 0)
			B:block(crop, v(0.32, 0.32, 1.0), c * CFrame.new(0, 0, -0.5), TASSEL)
		end

		-- candy-corn cob, local +Y along the cob
		local shines = 0
		local function cob(p, yaw, tilt, s)
			local c = CFrame.new(p) * ang(0, yaw, 0) * ang(-tilt, 0, 0) * CFrame.new(0, 0, -0.5)
			-- husk collar + two husk leaves peeled back behind the cob
			B:block(crop, v(1.0 * s, 0.5 * s, 1.0 * s), c * CFrame.new(0, 0.2 * s, 0), HUSK)
			B:block(crop, v(0.22, 0.8 * s, 0.6 * s), c * CFrame.new(0.6 * s, 0.45 * s, 0.15 * s) * ang(0, 0, -20), HUSK_LT)
			B:block(crop, v(0.22, 0.8 * s, 0.6 * s), c * CFrame.new(-0.6 * s, 0.45 * s, 0.15 * s) * ang(0, 0, 20), HUSK_LT)
			-- candy corn: yellow base, orange middle, white tip
			B:block(crop, v(1.25 * s, 1.0 * s, 1.25 * s), c * CFrame.new(0, 0.9 * s, 0), CC_Y)
			B:block(crop, v(1.0 * s, 0.95 * s, 1.0 * s), c * CFrame.new(0, 1.85 * s, 0), CC_O)
			B:block(crop, v(0.75 * s, 0.75 * s, 0.75 * s), c * CFrame.new(0, 2.65 * s, 0), CC_W)
			shines += 1
			B:block(crop, v(0.42 * s, 0.4 * s, 0.42 * s), c * CFrame.new(0, 3.2 * s, 0), SHINE, { mat = "Neon", name = "Shine" .. shines })
		end
		-- three big cobs, all facing the front
		cob(v(SX - 0.5, 2.8, SZ - 0.3), 300, 44, 1.4)
		cob(v(SX + 0.5, 4.4, SZ - 0.3), 60, 44, 1.3)
		cob(v(SX, 6.2, SZ - 0.6), 0, 18, 1.05)

		------------------------------------------------------------ fx
		B:emitter(leafParts[1], "sparkle", { name = "CandySparkle", color = { "#fff6d6", "#ffb347" }, rate = 2.5, size = 0.3 })
		B:light(leafParts[1], { color = "#ffc46b", brightness = 0.8, range = 9, name = "CandyLight" })
	end,
}
