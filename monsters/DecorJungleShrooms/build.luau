--!nocheck
-- Glowshroom Cluster (Snap-Jaw Jungle decoration #1, small accent).
-- A tight cluster of chunky stepped jungle mushrooms on a mossy footing of
-- flat bog stones, tufts and a fern frond:
-- * one big hot-pink toadstool (cream spots, glowing lime gills)
-- * a medium crimson cap with glowing lime spots, leaning outward
-- * a slim lime-green cap and three little pink/lime buttons around the feet
-- Stems are cream with a frilly skirt ring. Lime spores drift up from the
-- caps. Static prop: no motion.luau.
return {
	DisplayName = "Glowshroom Cluster",
	Rarity = "Decor",
	Element = "Snap-Jaw Jungle",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (shared with the Snap-Jaw Jungle crops)
		local DIRT_DK, DIRT = "#3f2516", "#6a4126"
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local GREEN, GREEN_DK, GREEN_LT = "#3caa3c", "#1f6e2a", "#9fd84a"
		local PINK, PINK_DK, CRIMSON, CRIMSON_DK = "#ff6d8a", "#e8456a", "#c92a48", "#8e1a33"
		local CREAM, CREAM_DK = "#fff4d2", "#e8d7a8"
		local LIME = "#a6ff3c"
		local NEON = { mat = "Neon" }

		local root = "Root"

		------------------------------------------------------------ footing
		-- low mossy patch (pixel-round), flat stones, tufts, a fern frond
		B:block(root, v(5.6, 0.3, 3.6), cf(0, 0.15, 0), DIRT_DK)
		B:block(root, v(3.6, 0.29, 5.4), cf(0, 0.15, 0), DIRT_DK)
		B:block(root, v(4.8, 0.28, 4.8), cf(0, 0.14, 0, 0, 45, 0), DIRT)
		B:block(root, v(4.4, 0.25, 3.0), cf(-0.2, 0.36, 0.1, 0, 12, 0), MOSS)
		B:block(root, v(2.8, 0.24, 4.2), cf(0.3, 0.35, -0.1, 0, 12, 0), MOSS_DK)
		-- flat stones
		B:block(root, v(1.5, 0.45, 1.2), cf(2.5, 0.28, 1.4, 0, 25, 0), STONE)
		B:block(root, v(0.9, 0.35, 0.8), cf(3.0, 0.5, 0.5, 0, 50, 4), STONE_LT)
		B:block(root, v(1.3, 0.4, 1.1), cf(-2.6, 0.25, -1.3, 0, -20, 0), STONE_DK)
		B:block(root, v(1.0, 0.36, 0.9), cf(-1.2, 0.22, -2.6, 0, 35, 0), STONE)
		B:block(root, v(0.7, 0.3, 0.6), cf(1.6, 0.2, -2.6, 0, 10, 0), STONE_LT)
		-- grass tufts
		for _, g in { { -2.7, 1.4 }, { 2.9, -1.3 }, { 0.6, 2.7 }, { -0.4, -2.9 } } do
			B:block(root, v(0.35, 0.9, 0.35), cf(g[1], 0.6, g[2], 0, 20, 8), GRASS)
			B:block(root, v(0.3, 0.6, 0.3), cf(g[1] + 0.3, 0.45, g[2] + 0.15, 0, 40, -10), GRASS_DK)
			B:block(root, v(0.28, 0.5, 0.28), cf(g[1] - 0.25, 0.4, g[2] - 0.15, 0, 10, 12), GRASS)
		end
		-- fern frond arching out the back-left
		local fr = CFrame.new(-1.6, 0.45, 1.6) * CFrame.Angles(0, rad(-140), 0)
		B:block(root, v(0.3, 0.3, 2.6), fr * CFrame.Angles(rad(28), 0, 0) * CFrame.new(0, 0, -1.2), GREEN_DK)
		for i = 1, 3 do
			local leaf = fr * CFrame.Angles(rad(28), 0, 0) * CFrame.new(0, 0.05, -0.55 * i - 0.2)
			B:block(root, v(1.6 - 0.3 * i, 0.2, 0.42), leaf, i % 2 == 1 and GREEN or GREEN_LT)
		end

		------------------------------------------------------------ mushrooms
		-- pixel-round tier: two crossed boxes + a 45-deg box
		local function tier(F, w, h, col, opts)
			B:block(root, v(w, h, w * 0.62), F, col, opts)
			B:block(root, v(w * 0.62, h - 0.02, w), F, col, opts)
			B:block(root, v(w * 0.8, h - 0.04, w * 0.8), F * CFrame.Angles(0, rad(45), 0), col, opts)
		end

		-- base: foot point, yaw, lean (deg), stem height, cap width
		local caps = {}
		local function shroom(base, yaw, lean, sh, cw, capC, capDk, spotC, spotNeon, sw)
			sw = sw or math.max(0.6, cw * 0.28)
			local F = CFrame.new(base) * CFrame.Angles(0, rad(yaw), 0) * CFrame.Angles(0, 0, rad(lean))
			local function at(y) return F * CFrame.new(0, y, 0) end
			-- bulb foot + stem + skirt
			B:block(root, v(sw * 1.35, 0.5, sw * 1.35), at(0.25), CREAM_DK)
			B:block(root, v(sw, sh, sw), at(sh / 2), CREAM)
			if sh > 1.5 then
				-- frilly skirt ring: a flat collar with a drooping lower lip
				B:block(root, v(sw * 1.5, 0.2, sw * 1.5), at(sh * 0.68), CREAM_DK)
				B:block(root, v(sw * 1.5 - 0.1, 0.25, sw * 1.5 - 0.1), at(sh * 0.68 - 0.2) * CFrame.Angles(0, rad(45), 0), CREAM)
			end
			-- glowing gill plate tucked under the cap
			B:block(root, v(cw * 0.6, 0.16, cw * 0.6), at(sh + 0.02) * CFrame.Angles(0, rad(45), 0), LIME, NEON)
			-- stepped cap: wide brim, dome, crown
			local ch = math.max(0.5, cw * 0.22)
			tier(at(sh + 0.1 + ch / 2), cw, ch, capDk)
			tier(at(sh + 0.1 + ch * 1.45), cw * 0.8, ch, capC)
			B:block(root, v(cw * 0.5, ch * 0.8, cw * 0.5), at(sh + 0.1 + ch * 2.3), capC)
			-- spots: on the dome top and brim sides
			local so = spotNeon and NEON or nil
			local s = math.max(0.3, cw * 0.17)
			local top = sh + 0.1 + ch * 2.7 + 0.02
			B:block(root, v(s, 0.1, s), at(top) * CFrame.new(cw * 0.08, 0, -cw * 0.06), spotC, so)
			-- side spots sit on the dome's flat faces (0/90/180/270) and on the
			-- brim's diagonal faces (45/225), alternating heights
			for i, a in { 0, 90, 180, 270 } do
				local y = sh + 0.1 + ch * 1.45 + (i % 2 == 0 and 0.08 or -0.08)
				local p = at(y) * CFrame.Angles(0, rad(a), 0) * CFrame.new((i % 2 == 0 and 0.15 or -0.15) * cw, 0, -cw * 0.4 - 0.05)
				B:block(root, v(s * 1.1, s, 0.12), p, spotC, so)
			end
			for _, a in { 45, 225 } do
				local p = at(sh + 0.1 + ch / 2) * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0, -cw * 0.4 - 0.05)
				B:block(root, v(s * 1.1, math.min(s, ch - 0.1), 0.12), p, spotC, so)
			end
			for _, a in { 80, 200, 320 } do
				local p = at(sh + 0.1 + ch * 2.05) * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0, -cw * 0.4 + 0.08)
				B:block(root, v(s * 1.1, 0.1, s * 1.1), p, spotC, so)
			end
			local capTop = B:block(root, v(cw * 0.3, 0.1, cw * 0.3), at(top + 0.05), capC, { tr = 1, name = "CapTop" .. #caps + 1 })
			table.insert(caps, capTop)
		end

		-- big hot-pink toadstool (cream spots, lime gills)
		shroom(v(-0.3, 0.4, 0.3), 10, 4, 4.0, 3.4, PINK, PINK_DK, CREAM, false, 0.95)
		-- medium crimson cap with glowing spots, leaning right-front
		shroom(v(1.6, 0.4, -0.7), -20, -14, 2.3, 2.5, CRIMSON, CRIMSON_DK, LIME, true, 0.7)
		-- slim lime-green cap, leaning back-left
		shroom(v(-1.7, 0.4, -0.8), 30, 16, 1.9, 1.8, GREEN_LT, GREEN, PINK, false, 0.55)
		-- little buttons
		shroom(v(0.8, 0.4, 1.7), 0, -8, 0.8, 1.2, PINK, PINK_DK, CREAM, false, 0.45)
		shroom(v(-1.0, 0.4, -2.0), 45, 10, 0.6, 1.0, CRIMSON, CRIMSON_DK, CREAM, false, 0.4)
		shroom(v(2.2, 0.4, 1.0), -30, -12, 0.5, 0.9, GREEN_LT, GREEN, PINK, false, 0.4)

		------------------------------------------------------------ fx
		B:emitter(caps[1], "glow", { name = "SporeGlow", color = { "#e6ffb0", LIME }, rate = 1.2, size = 0.7, speed = { 0.2, 0.5 } })
		B:emitter(caps[1], "sparkle", { name = "Spores", color = { "#eaffb0", LIME }, rate = 3, size = 0.25, speed = { 0.3, 0.8 }, accel = { 0, 0.6, 0 } })
		B:emitter(caps[2], "sparkle", { name = "Spores2", color = { "#ffd0dc", LIME }, rate = 1.5, size = 0.22, speed = { 0.2, 0.6 }, accel = { 0, 0.5, 0 } })
		B:light(caps[1], { color = "#c8ff7a", brightness = 0.7, range = 8, name = "ShroomLight" })
	end,
}
