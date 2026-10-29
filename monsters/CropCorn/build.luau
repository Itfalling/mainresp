--!nocheck
-- Corn Stalk (Epic crop): a tall corn plant on a stepped soil mound. Thick
-- stepped green stalk with node rings and little brace roots, long arching
-- blade leaves built as stepped block staircases (no wedges), three big cobs
-- half-wrapped in pale green husks showing golden kernel rows, brown-gold
-- silk tufts, a golden tassel on top with one tiny neon gold sparkle.
-- Static prop: no motion.luau. Soil parts live on the "Soil" bone.
return {
	DisplayName = "Corn Stalk",
	Rarity = "Epic",
	Element = "Nature",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad

		local STALK, STALK_DK, STALK_LT = "#2f9a3e", "#1c6a2e", "#6fd04a"
		local LEAF, LEAF_DK, LEAF_LT = "#2aa848", "#17703a", "#8fe85a"
		local KER, KER_LT, KER_DK = "#ffbb00", "#ffe552", "#e08a00"
		local HUSK, HUSK_DK, HUSK_LT = "#b9e070", "#86c24f", "#ddf2a0"
		local SILK, SILK_DK = "#d39a3c", "#8f5a21"
		local TAS, TAS_LT, TAS_DK = "#e9b843", "#ffe08a", "#b9852a"
		local GOLD_NEON = "#ffd84a"
		local SOIL, SOIL_DK, SOIL_LT, PEBBLE = "#6e4227", "#472915", "#8d5a33", "#a49a8c"

		local root = "Root"
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }

		------------------------------------------------------------------
		-- SOIL MOUND: stepped, with clods and a pebble
		------------------------------------------------------------------
		B:block(soil, v(5.0, 0.45, 5.0), cf(0, 0.225, 0), SOIL_DK, S)
		B:block(soil, v(4.0, 0.4, 4.0), cf(0, 0.62, 0), SOIL, S)
		B:block(soil, v(2.8, 0.35, 2.8), cf(0, 0.97, 0), SOIL_LT, S)
		B:block(soil, v(0.7, 0.35, 0.6), cf(-1.7, 0.95, -1.3), SOIL_DK, S)
		B:block(soil, v(0.6, 0.3, 0.7), cf(1.6, 0.9, 1.4), SOIL_DK, S)
		B:block(soil, v(0.5, 0.3, 0.5), cf(1.1, 1.25, -1.0), SOIL_DK, S)
		B:block(soil, v(0.5, 0.35, 0.45), cf(-2.1, 0.6, 1.9), PEBBLE, S)
		B:block(soil, v(0.4, 0.25, 0.4), cf(2.3, 0.55, -2.0), PEBBLE, S)

		------------------------------------------------------------------
		-- STALK: three stepped segments, node rings, front highlight strip
		------------------------------------------------------------------
		B:block(root, v(1.4, 2.6, 1.4), cf(0, 2.3, 0), STALK)
		B:block(root, v(1.2, 2.6, 1.2), cf(0, 4.9, 0), STALK)
		B:block(root, v(1.0, 2.3, 1.0), cf(0, 7.35, 0), STALK)
		B:block(root, v(1.6, 0.3, 1.6), cf(0, 3.6, 0), STALK_DK)
		B:block(root, v(1.4, 0.3, 1.4), cf(0, 6.2, 0), STALK_DK)
		B:block(root, v(1.2, 0.3, 1.2), cf(0, 8.4, 0), STALK_DK)
		B:block(root, v(0.35, 2.2, 0.1), cf(-0.3, 2.3, -0.72), STALK_LT)
		B:block(root, v(0.3, 2.2, 0.1), cf(-0.25, 4.9, -0.62), STALK_LT)
		B:block(root, v(0.28, 1.9, 0.1), cf(-0.2, 7.3, -0.52), STALK_LT)
		-- brace roots at the base
		for _, d in { { 0.85, 0.3 }, { -0.85, -0.3 }, { -0.3, 0.85 }, { 0.3, -0.85 } } do
			B:block(root, v(0.4, 0.7, 0.4), cf(d[1], 1.3, d[2]), STALK_DK)
		end

		------------------------------------------------------------------
		-- LEAVES: long arching blades = chained chunky block segments that
		-- rise, level off and droop (absolute pitch per segment, no wedges)
		------------------------------------------------------------------
		-- {length, width, pitch (deg), color}
		local SEG = {
			{ 1.3, 1.3, 40, LEAF },
			{ 1.0, 1.25, 18, LEAF },
			{ 1.0, 1.15, -2, LEAF },
			{ 0.9, 1.0, -25, LEAF },
			{ 0.8, 0.8, -50, LEAF_DK },
			{ 0.6, 0.55, -75, LEAF_DK },
		}
		local function leaf(y, yaw, sc)
			local pos = (CFrame.new(0, y, 0) * CFrame.Angles(0, rad(yaw), 0) * CFrame.new(0.35, 0, 0))
			local base = CFrame.new(0, y, 0) * CFrame.Angles(0, rad(yaw), 0)
			for i, s in SEG do
				local g = CFrame.new(pos.Position) * base.Rotation * CFrame.Angles(0, 0, rad(s[3]))
				B:block(root, v(s[1] * sc + 0.15, 0.45, s[2]), g * CFrame.new(s[1] * sc / 2, 0, 0), s[4])
				if i <= 2 then
					B:block(root, v(s[1] * sc, 0.12, 0.3), g * CFrame.new(s[1] * sc / 2 + 0.05, 0.25, 0), LEAF_LT) -- midrib
				end
				pos = g * CFrame.new(s[1] * sc, 0, 0)
			end
		end
		leaf(1.8, 270, 0.7)
		leaf(2.2, 20, 1.0)
		leaf(3.0, 200, 1.05)
		leaf(5.6, 225, 0.95)
		leaf(6.2, 315, 0.9)
		leaf(7.0, 340, 0.8)
		leaf(7.6, 135, 0.75)
		leaf(8.1, 160, 0.6)

		------------------------------------------------------------------
		-- COBS: golden kernel rows, half-wrapped in pale husk, silk tufts
		------------------------------------------------------------------
		local function cob(attach, yaw, tilt)
			local f = CFrame.new(attach) * CFrame.Angles(0, rad(yaw), 0) * CFrame.new(0.95, 0, 0) * CFrame.Angles(0, 0, -rad(tilt))
			local function put(size, x, y, z, col, opts)
				return B:block(root, size, f * CFrame.new(x, y, z), col, opts)
			end
			put(v(0.5, 0.6, 0.5), -0.15, 0.05, 0, HUSK_DK) -- shank
			local W = { 1.15, 1.25, 1.25, 1.25, 1.15, 1.0, 0.8 }
			for i, w in W do
				put(v(w, 0.4, w), 0, 0.35 + (i - 0.5) * 0.38, 0, i % 2 == 1 and KER or KER_LT)
			end
			put(v(0.55, 0.3, 0.55), 0, 3.06, 0, KER_DK) -- tip
			-- husk (lower ~40%)
			put(v(0.25, 2.0, 1.35), -0.7, 1.15, 0, HUSK_DK) -- back (stalk side)
			put(v(1.35, 0.95, 0.24), 0, 0.6, 0.72, HUSK) -- side
			put(v(1.35, 0.95, 0.24), 0, 0.6, -0.72, HUSK) -- side
			put(v(0.24, 0.5, 1.35), 0.72, 0.4, 0, HUSK_LT) -- outer lower flap
			put(v(0.5, 0.8, 0.22), -0.35, 1.4, 0.78, HUSK_LT) -- husk leaf tips
			put(v(0.5, 0.8, 0.22), -0.35, 1.4, -0.78, HUSK_LT)
			-- silk tuft
			put(v(0.5, 0.5, 0.5), 0, 3.35, 0, SILK)
			put(v(0.2, 0.6, 0.2), 0.25, 3.5, 0.15, SILK_DK)
			put(v(0.55, 0.18, 0.18), 0.4, 3.65, -0.1, SILK)
		end
		cob(v(0, 3.6, 0), 30, 25) -- right-front
		cob(v(0, 4.9, 0), 150, 25) -- left-front
		cob(v(0, 4.2, 0), 270, 22) -- back

		------------------------------------------------------------------
		-- TASSEL: golden spikes fanning from the top
		------------------------------------------------------------------
		B:block(root, v(0.6, 0.35, 0.6), cf(0, 8.7, 0), TAS_DK)
		B:block(root, v(0.35, 1.0, 0.35), cf(0, 9.1, 0), TAS)
		for i = 0, 3 do
			local f = CFrame.new(0, 8.75, 0) * CFrame.Angles(0, rad(45 + 90 * i), 0) * CFrame.Angles(0, 0, -rad(40))
			B:block(root, v(0.2, 1.1, 0.2), f * CFrame.new(0, 0.55, 0), TAS)
			B:block(root, v(0.22, 0.35, 0.22), f * CFrame.new(0, 1.2, 0), TAS_LT)
		end
		local top = B:block(root, v(0.3, 0.3, 0.3), cf(0, 9.72, 0), GOLD_NEON, { mat = "Neon" })
		B:emitter(top, "sparkle", { name = "TasselSparkle", color = { "#fff3b0", GOLD_NEON }, rate = 2.5, size = { 0.3, 0.35, 0 } })
	end,
}
