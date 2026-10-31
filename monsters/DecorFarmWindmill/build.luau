--!nocheck
-- Farm Windmill (Sunny Farm decoration, HERO piece ~21 studs). A cute wooden
-- smock windmill:
-- * footing: an octagonal stone plinth, stepping stones to the door, grass
--   tufts with little flowers (bone "Base")
-- * a tapered three-tier octagonal tower of warm wood planks (each tier is two
--   crossed blocks, one turned 45 deg = a clean octagon) with dark corner
--   battens and dark trim ledges between the tiers
-- * a dark wooden door with a frame, gold knob and a little awning; cream
--   framed windows with flower boxes on the sides
-- * a stepped red octagonal cap roof with a gold finial
-- * four lattice sails (spar + cream cloth + rails + crossbars) on bone
--   "Sails", pivoting on the hub at the front of the cap; motion.luau turns
--   them slowly (one full turn per 10 s loop)
-- Faces -Z.
return {
	DisplayName = "Farm Windmill",
	Rarity = "Decor",
	Element = "Sunny Farm",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad, cos, sin = math.rad, math.cos, math.sin
		local STONE_LT, STONE, STONE_DK = "#c3c9cf", "#9aa3ad", "#7c858f"
		local WOOD_LT, WOOD, WOOD_DK, WOOD_XDK = "#e0a866", "#c98a4b", "#8a5a2b", "#5e3a1c"
		local ROOF, ROOF_DK, ROOF_LT = "#e0392e", "#b02720", "#f25a44"
		local CREAM, CREAM_DK = "#fff4dc", "#ecdcb8"
		local GLASS = "#8fd8ff"
		local GOLD = "#ffcf3a"
		local GRASS, GRASS_DK = "#5fd23f", "#3fb43a"

		------------------------------------------------------------------
		-- footing
		------------------------------------------------------------------
		local base = B:bone("Base", "Root", v(0, 0, 0))
		-- regular octagon slab = union of four strips (width = side length)
		-- through the centre, at 0/45/90/135 deg
		local TAN = math.tan(math.rad(22.5))
		local function octo(bone, apo, y0, y1, col, col2)
			local h, yc, side = y1 - y0, (y0 + y1) / 2, 2 * apo * TAN + 0.02
			for k = 0, 3 do
				local c = (k % 2 == 0) and col or (col2 or col)
				B:block(bone, v(apo * 2, h, side), cf(0, yc + 0.004 * k, 0, 0, 45 * k, 0), c)
			end
		end
		octo(base, 4.3, 0, 0.4, STONE_DK, STONE)
		octo(base, 4.0, 0.4, 0.7, STONE_LT)
		-- stepping stones to the door
		B:block(base, v(1.8, 0.3, 1.2), cf(0.1, 0.15, -5.0, 0, 6, 0), STONE_LT)
		B:block(base, v(1.5, 0.3, 1.1), cf(-0.3, 0.15, -6.4, 0, -10, 0), STONE)
		local function tuft(x, z, h, flower)
			B:block(base, v(0.5, h, 0.5), cf(x, h / 2, z), GRASS)
			B:block(base, v(0.4, h * 0.7, 0.4), cf(x + 0.35, h * 0.35 + 0.08, z + 0.2, 0, 0, -18), GRASS_DK)
			B:block(base, v(0.4, h * 0.75, 0.4), cf(x - 0.35, h * 0.37 + 0.08, z - 0.15, 0, 0, 18), GRASS)
			if flower then
				B:block(base, v(0.55, 0.3, 0.55), cf(x, h + 0.1, z), flower)
				B:block(base, v(0.25, 0.32, 0.25), cf(x, h + 0.12, z), GOLD)
			end
		end
		tuft(-2.6, -4.6, 1.0, "#ff7eb6")
		tuft(3.3, -3.9, 0.9, "#ffffff")
		tuft(-4.3, 1.5, 1.1)
		tuft(4.6, -1.0, 1.0, "#ff7eb6")
		tuft(3.4, 3.6, 0.9)
		tuft(-3.2, 3.8, 1.0, "#ffffff")

		------------------------------------------------------------------
		-- tower: three tapered octagonal tiers
		------------------------------------------------------------------
		local tw = "Root"
		local tiers = {
			{ apo = 3.4, y0 = 0.7, y1 = 4.7, col = WOOD },
			{ apo = 2.8, y0 = 4.95, y1 = 8.7, col = CREAM },
			{ apo = 2.45, y0 = 8.95, y1 = 12.4, col = WOOD },
		}
		local R8 = 1 / cos(rad(22.5))
		for i, t in tiers do
			octo(tw, t.apo, t.y0, t.y1 + 0.05, t.col)
			-- corner battens on the 8 vertices
			for k = 0, 7 do
				local a = rad(22.5 + 45 * k)
				local r = t.apo * R8 - 0.05
				B:block(tw, v(0.4, t.y1 - t.y0, 0.4), cf(r * sin(a), (t.y0 + t.y1) / 2, r * cos(a), 0, 22.5 + 45 * k, 0), WOOD_DK)
			end
			-- trim ledge on top of the tier
			local ledgeApo = (tiers[i + 1] and tiers[i + 1].apo or t.apo) + 0.5
			if i == #tiers then ledgeApo = t.apo + 0.35 end
			octo(tw, ledgeApo, t.y1, t.y1 + 0.3, WOOD_XDK)
		end
		-- bottom skirt under tier 1
		octo(tw, 3.65, 0.7, 1.2, WOOD_DK)

		------------------------------------------------------------------
		-- door (front, tier 1)
		------------------------------------------------------------------
		local fz = -3.4
		B:block(tw, v(2.4, 3.2, 0.3), cf(0, 2.5, fz - 0.1), CREAM)
		B:block(tw, v(1.8, 2.8, 0.3), cf(0, 2.3, fz - 0.2), WOOD_XDK)
		B:block(tw, v(0.2, 2.5, 0.1), cf(-0.45, 2.3, fz - 0.38), WOOD_DK)
		B:block(tw, v(0.2, 2.5, 0.1), cf(0.45, 2.3, fz - 0.38), WOOD_DK)
		B:block(tw, v(0.3, 0.3, 0.2), cf(0.6, 2.2, fz - 0.45), GOLD)
		B:block(tw, v(3.0, 0.3, 1.0), cf(0, 4.3, fz - 0.45), ROOF)
		B:block(tw, v(3.0, 0.2, 0.3), cf(0, 4.1, fz - 0.95), ROOF_DK)

		-- flour sacks by the door
		local function sack(x, z, yaw, h)
			local c = CFrame.new(x, 0.7, z) * CFrame.Angles(0, rad(yaw), 0)
			B:block(tw, v(1.2, h, 0.9), c * CFrame.new(0, h / 2, 0), CREAM)
			B:block(tw, v(1.0, 0.2, 0.7), c * CFrame.new(0, h + 0.05, 0), CREAM_DK)
			B:block(tw, v(0.45, 0.35, 0.45), c * CFrame.new(0, h + 0.3, 0), CREAM)
			B:block(tw, v(0.55, 0.12, 0.55), c * CFrame.new(0, h + 0.2, 0), "#b8773a")
			B:block(tw, v(0.5, 0.4, 0.1), c * CFrame.new(0, h * 0.5, -0.47), ROOF)
		end
		sack(2.0, -3.25, -20, 1.3)
		sack(2.95, -2.2, -55, 1.1)

		------------------------------------------------------------------
		-- side windows with flower boxes (tier 2 and tier 3, on +X / -X)
		------------------------------------------------------------------
		local function window(s, apo, y, flowers)
			local x = s * apo
			local frame = flowers and WOOD_DK or CREAM
			B:block(tw, v(0.3, 1.8, 1.6), cf(x + s * 0.1, y, 0), frame)
			B:block(tw, v(0.3, 1.3, 1.1), cf(x + s * 0.2, y, 0), GLASS)
			B:block(tw, v(0.3, 1.3, 0.15), cf(x + s * 0.28, y, 0), frame)
			B:block(tw, v(0.3, 0.15, 1.1), cf(x + s * 0.28, y, 0), frame)
			if flowers then
				-- little red shutters
				for _, sz in { -1, 1 } do
					B:block(tw, v(0.25, 1.7, 0.6), cf(x + s * 0.1, y, sz * 1.15), ROOF)
					B:block(tw, v(0.1, 1.2, 0.15), cf(x + s * 0.25, y, sz * 1.15), ROOF_DK)
				end
				B:block(tw, v(0.7, 0.5, 1.9), cf(x + s * 0.4, y - 1.15, 0), WOOD_DK)
				local cols = { "#ff7eb6", "#ffffff", "#ff4d4d" }
				for j = -1, 1 do
					B:block(tw, v(0.45, 0.4, 0.45), cf(x + s * 0.4, y - 0.75, j * 0.6), GRASS)
					B:block(tw, v(0.4, 0.3, 0.4), cf(x + s * 0.4, y - 0.5, j * 0.6), cols[j + 2])
				end
			end
		end
		window(1, 2.8, 6.9, true)
		window(-1, 2.8, 6.9, true)
		window(1, 2.45, 10.7, false)
		window(-1, 2.45, 10.7, false)
		-- small round-ish attic window at the back
		B:block(tw, v(1.2, 1.2, 0.3), cf(0, 10.7, 2.5), CREAM)
		B:block(tw, v(0.8, 0.8, 0.3), cf(0, 10.7, 2.6), GLASS)

		------------------------------------------------------------------
		-- cap: stepped red octagon roof + finial
		------------------------------------------------------------------
		local capY = 12.7
		local steps = { { 3.0, ROOF_DK }, { 2.5, ROOF }, { 1.95, ROOF_LT }, { 1.4, ROOF }, { 0.85, ROOF_LT } }
		local y = capY
		for _, s in steps do
			octo(tw, s[1], y, y + 0.9, s[2])
			y += 0.9
		end
		B:block(tw, v(0.5, 0.6, 0.5), cf(0, y + 0.3, 0), WOOD_XDK)
		B:block(tw, v(0.7, 0.7, 0.7), cf(0, y + 0.9, 0, 0, 45, 0), GOLD)

		------------------------------------------------------------------
		-- hub + sails (bone "Sails")
		------------------------------------------------------------------
		local HY, HZ = 13.4, -3.75
		B:block(tw, v(1.0, 1.0, 1.4), cf(0, HY, -2.9), WOOD_XDK) -- axle box
		local sails = B:bone("Sails", "Root", v(0, HY, HZ))
		B:block(sails, v(1.6, 1.6, 0.6), cf(0, HY, HZ - 0.1), WOOD_DK)
		B:block(sails, v(0.9, 0.9, 0.4), cf(0, HY, HZ - 0.45), ROOF)
		B:block(sails, v(0.4, 0.4, 0.3), cf(0, HY, HZ - 0.7), GOLD)
		local LEN = 7.6
		for k = 0, 3 do
			local a = 45 + 90 * k
			local arm = CFrame.new(0, HY, HZ) * CFrame.Angles(0, 0, rad(a))
			local function at(x, yy, z) return arm * CFrame.new(x, yy, z) end
			-- spar
			B:block(sails, v(LEN, 0.5, 0.4), at(LEN / 2 + 0.3, 0, 0), WOOD_DK)
			-- cloth panel on the trailing side
			local r0, r1, W = 1.9, LEN + 0.1, 2.5
			B:block(sails, v(r1 - r0, W, 0.14), at((r0 + r1) / 2, 0.25 + W / 2, 0.12), CREAM)
			-- outer rail + crossbars
			B:block(sails, v(r1 - r0 + 0.2, 0.25, 0.3), at((r0 + r1) / 2, 0.25 + W, -0.05), WOOD)
			for j = 0, 4 do
				local r = r0 + (r1 - r0) * j / 4
				B:block(sails, v(0.25, W + 0.1, 0.3), at(r, 0.25 + W / 2, -0.05), WOOD)
			end
			-- red tip
			B:block(sails, v(0.5, 0.6, 0.5), at(LEN + 0.3, 0, 0), ROOF)
		end
	end,
}
