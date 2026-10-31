--!nocheck
-- Vine Totem (Snap-Jaw Jungle decoration #2, medium).
-- A mossy stepped jungle-stone totem on a flagstone footing:
-- * three stacked, slightly skewed stone drums with darker bands and moss
--   caps dripping over their edges
-- * a carved flytrap-jaw motif on the front and back: a stepped lens-shaped
--   groove, crimson painted lobes, a dark throat with a thin glowing lime
--   seam, interlocking cream stone teeth and little cilia on the lobe rims
--   (a teeth pattern only - no eyes, no face)
-- * a smaller jaw carving on the top drum, a wide cap stone and a closed
--   stone flytrap-bud finial with teeth poking from the seam
-- * two leafy vines spiralling up the shaft, with tiny pink buds
-- Static prop: no motion.luau.
return {
	DisplayName = "Vine Totem",
	Rarity = "Decor",
	Element = "Snap-Jaw Jungle",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (shared with the Snap-Jaw Jungle crops)
		local DIRT_DK, DIRT = "#3f2516", "#4d2d1a"
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK, STONE_XDK = "#9a9180", "#b8ae98", "#757062", "#4e4a40"
		local GREEN, GREEN_DK, GREEN_LT = "#3caa3c", "#1f6e2a", "#9fd84a"
		local INSIDE, RIM, THROAT = "#ff5c7c", "#c92a48", "#5c0f25"
		local CREAM = "#fff4d2"
		local LIME = "#a6ff3c"
		local NEON = { mat = "Neon" }
		local root = "Root"

		local seed = 4242
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		------------------------------------------------------------ footing
		B:block(root, v(6.4, 0.45, 4.4), cf(0, 0.225, 0), DIRT_DK)
		B:block(root, v(4.4, 0.44, 6.4), cf(0, 0.22, 0), DIRT_DK)
		B:block(root, v(5.6, 0.43, 5.6), cf(0, 0.215, 0, 0, 45, 0), DIRT)
		-- flagstone slabs (slightly rotated, two tones)
		B:block(root, v(4.6, 0.5, 4.6), cf(0, 0.6, 0, 0, 4, 0), STONE)
		B:block(root, v(2.2, 0.12, 2.0), cf(-1.15, 0.9, -1.2, 0, 4, 0), STONE_LT)
		B:block(root, v(2.0, 0.12, 2.1), cf(1.2, 0.9, 1.1, 0, 4, 0), STONE_LT)
		-- moss creeping over the slab edges
		B:block(root, v(2.4, 0.3, 1.2), cf(1.4, 0.82, -2.0, -10, 4, 0), MOSS)
		B:block(root, v(1.2, 0.3, 2.6), cf(-2.1, 0.8, 0.9, 0, 4, 10), MOSS_DK)
		B:block(root, v(1.6, 0.28, 1.0), cf(-0.6, 0.78, 2.15, 10, 4, 0), MOSS)
		-- loose stones
		B:block(root, v(1.1, 0.7, 0.9), cf(2.9, 0.42, -1.9, 0, 30, 6), STONE)
		B:block(root, v(0.7, 0.5, 0.6), cf(3.3, 0.25, -0.9, 0, 60, 0), STONE_LT)
		B:block(root, v(0.9, 0.6, 0.8), cf(-3.0, 0.36, 2.0, 0, -25, -6), STONE_DK)
		-- grass tufts + a fern
		for _, g in { { -3.0, -1.6 }, { 2.9, 1.8 }, { -1.2, -3.0 }, { 1.4, 3.0 } } do
			B:block(root, v(0.4, 1.0, 0.4), cf(g[1], 0.56, g[2], 0, 20, 8), GRASS)
			B:block(root, v(0.32, 0.7, 0.32), cf(g[1] + 0.32, 0.35, g[2] + 0.15, 0, 40, -10), GRASS_DK)
			B:block(root, v(0.3, 0.55, 0.3), cf(g[1] - 0.28, 0.32, g[2] - 0.18, 0, 10, 12), GRASS)
		end
		local fr = CFrame.new(2.0, 0.9, 1.9) * CFrame.Angles(0, rad(140), 0) * CFrame.Angles(rad(25), 0, 0)
		B:block(root, v(0.3, 0.3, 2.8), fr * CFrame.new(0, 0, -1.3), GREEN_DK)
		for i = 1, 3 do
			B:block(root, v(1.8 - 0.35 * i, 0.2, 0.45), fr * CFrame.new(0, 0.05, -0.6 * i - 0.2), i % 2 == 1 and GREEN or GREEN_LT)
		end

		------------------------------------------------------------ carved jaw
		-- F: frame at the face centre, local -Z pointing out of the face; k = scale
		local glows = {}
		local function jaw(F, k)
			local function at(x, y, z) return F * CFrame.new(x * k, y * k, -z) end
			-- stepped lens groove (dark carved stone), rows: y, width
			for _, r in { { 0.95, 1.1 }, { 0.62, 2.0 }, { 0.25, 2.5 }, { -0.25, 2.5 }, { -0.62, 2.0 }, { -0.95, 1.1 } } do
				B:block(root, v(r[2] * k, 0.38 * k, 0.1), at(0, r[1], 0.05), STONE_XDK)
			end
			-- crimson painted lobes (upper + lower), pink inner edge
			B:block(root, v(1.6 * k, 0.32 * k, 0.1), at(0, 0.62, 0.12), RIM)
			B:block(root, v(2.1 * k, 0.36 * k, 0.1), at(0, 0.3, 0.12), INSIDE)
			B:block(root, v(2.1 * k, 0.36 * k, 0.1), at(0, -0.3, 0.12), INSIDE)
			B:block(root, v(1.6 * k, 0.32 * k, 0.1), at(0, -0.62, 0.12), RIM)
			-- dark throat with a thin glowing seam
			B:block(root, v(1.9 * k, 0.26 * k, 0.1), at(0, 0, 0.17), THROAT)
			table.insert(glows, B:block(root, v(1.4 * k, 0.08 * k, 0.1), at(0, 0, 0.22), LIME, NEON))
			-- interlocking teeth: upper row hangs down, lower row points up
			for _, x in { -0.75, -0.25, 0.25, 0.75 } do
				B:block(root, v(0.22 * k, 0.42 * k, 0.16), at(x, 0.12, 0.3), CREAM)
			end
			for _, x in { -0.5, 0, 0.5 } do
				B:block(root, v(0.22 * k, 0.42 * k, 0.16), at(x, -0.12, 0.3), CREAM)
			end
			-- cilia on the outer lobe rims (top + bottom)
			for _, x in { -0.4, 0, 0.4 } do
				B:block(root, v(0.16 * k, 0.32 * k, 0.12), at(x, 1.26, 0.08), CREAM)
				B:block(root, v(0.16 * k, 0.32 * k, 0.12), at(x, -1.26, 0.08), CREAM)
			end
			for _, s in { -1, 1 } do
				B:block(root, v(0.16 * k, 0.3 * k, 0.12), at(0.82 * s, 1.0, 0.08) * CFrame.Angles(0, 0, rad(-35 * s)), CREAM)
				B:block(root, v(0.16 * k, 0.3 * k, 0.12), at(0.82 * s, -1.0, 0.08) * CFrame.Angles(0, 0, rad(35 * s)), CREAM)
			end
		end

		------------------------------------------------------------ shaft
		-- drum: centre y, height, width, yaw, colour
		local function drum(y0, h, w, yaw, col, band)
			local F = CFrame.new(0, y0 + h / 2, 0) * CFrame.Angles(0, rad(yaw), 0)
			B:block(root, v(w, h, w), F, col)
			-- chamfered corners (studded pillars) give a stepped silhouette
			for _, s in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
				B:block(root, v(0.5, h - 0.3, 0.5), F * CFrame.new(s[1] * (w / 2 - 0.15), 0, s[2] * (w / 2 - 0.15)), band)
			end
			-- darker base band
			B:block(root, v(w + 0.2, 0.35, w + 0.2), F * CFrame.new(0, -h / 2 + 0.175, 0), band)
			return F
		end
		local F1 = drum(0.85, 2.6, 3.0, 3, STONE, STONE_DK)
		local F2 = drum(3.45, 3.2, 3.2, -4, STONE_LT, STONE)
		local F3 = drum(6.65, 2.4, 2.7, 6, STONE, STONE_DK)
		-- jaws front + back on the big drum, a small one front on the top drum
		jaw(F2 * CFrame.new(0, 0.1, -1.6), 1.0)
		jaw(F2 * CFrame.Angles(0, rad(180), 0) * CFrame.new(0, 0.1, -1.6), 1.0)
		jaw(F3 * CFrame.new(0, 0.05, -1.35), 0.72)
		-- bottom drum: a carved teeth frieze (zigzag of cream teeth in a dark band)
		for _, a in { 0, 90, 180, 270 } do
			local Fa = F1 * CFrame.Angles(0, rad(a), 0)
			B:block(root, v(2.3, 0.7, 0.1), Fa * CFrame.new(0, 0.35, -1.53), STONE_XDK)
			for i, x in { -0.9, -0.45, 0, 0.45, 0.9 } do
				local up = i % 2 == 0
				B:block(root, v(0.26, 0.4, 0.12), Fa * CFrame.new(x, up and 0.22 or 0.48, -1.6), CREAM)
			end
		end

		-- cap stone (stepped) + closed flytrap bud finial
		local capY = 9.05
		B:block(root, v(3.8, 0.55, 3.8), cf(0, capY + 0.275, 0, 0, 2, 0), STONE_DK)
		B:block(root, v(3.3, 0.45, 3.3), cf(0, capY + 0.775, 0, 0, 2, 0), STONE)
		B:block(root, v(1.6, 0.5, 1.6), cf(0, capY + 1.25, 0, 0, 2, 0), STONE_DK)
		-- bud: a closed flytrap carved in stone - two stepped lobes meeting at a
		-- vertical seam (facing front), crimson lips and teeth poking out
		local BF = CFrame.new(0, capY + 1.5, 0) * CFrame.Angles(0, rad(2), 0)
		for _, s in { -1, 1 } do
			B:block(root, v(0.9, 0.7, 1.6), BF * CFrame.new(0.5 * s, 0.35, 0), STONE)
			B:block(root, v(1.1, 1.0, 2.0), BF * CFrame.new(0.6 * s, 1.15, 0), STONE_LT)
			B:block(root, v(0.9, 0.7, 1.6), BF * CFrame.new(0.5 * s, 1.95, 0), STONE_LT)
			B:block(root, v(0.6, 0.45, 1.0), BF * CFrame.new(0.38 * s, 2.5, 0), STONE)
			-- moss on the shoulders
			B:block(root, v(0.7, 0.2, 1.2), BF * CFrame.new(0.65 * s, 2.32, 0.1 * s), s > 0 and MOSS or MOSS_DK)
			-- crimson lips along the seam (front, back)
			for _, z in { -1, 1 } do
				B:block(root, v(0.22, 1.7, 0.1), BF * CFrame.new(0.14 * s, 1.15, 1.02 * z), RIM)
			end
			B:block(root, v(0.22, 0.1, 1.0), BF * CFrame.new(0.14 * s, 2.74, 0), RIM)
		end
		B:block(root, v(0.1, 2.5, 2.06), BF * CFrame.new(0, 1.35, 0), THROAT)
		local budGlow = B:block(root, v(0.08, 1.2, 0.1), BF * CFrame.new(0, 1.15, -1.07), LIME, NEON)
		-- teeth interlocking across the seam (front, back) and along the top
		for i, y in { 0.45, 0.85, 1.25, 1.65 } do
			local sx = (i % 2 == 0) and 1 or -1
			B:block(root, v(0.42, 0.2, 0.3), BF * CFrame.new(0.13 * sx, y, -1.12), CREAM)
			B:block(root, v(0.42, 0.2, 0.3), BF * CFrame.new(-0.13 * sx, y, 1.12), CREAM)
		end
		for i, z in { -0.36, 0, 0.36 } do
			local sx = (i % 2 == 0) and 1 or -1
			B:block(root, v(0.2, 0.42, 0.2), BF * CFrame.new(0.12 * sx, 2.86, z), CREAM)
		end

		------------------------------------------------------------ moss
		local function mossCap(F, w, h, list)
			B:block(root, v(w + 0.15, 0.3, w + 0.15), F * CFrame.new(0, h / 2 - 0.1, 0), MOSS)
			for _, m in list do
				-- m: face angle, along-offset, drip length
				local Fa = F * CFrame.Angles(0, rad(m[1]), 0)
				B:block(root, v(0.7, m[3], 0.2), Fa * CFrame.new(m[2], h / 2 - m[3] / 2, -w / 2 - 0.12), m[4] or MOSS_DK)
			end
		end
		mossCap(F1, 3.0, 2.6, { { 90, 0.3, 1.2 }, { 180, -0.6, 0.8, MOSS }, { 270, 0.8, 1.4 } })
		mossCap(F2, 3.2, 3.2, { { 0, 1.1, 0.7, MOSS }, { 90, -0.4, 1.6 }, { 270, 0.2, 1.0, MOSS } })
		mossCap(F3, 2.7, 2.4, { { 0, -0.9, 0.6 }, { 180, 0.5, 1.2, MOSS }, { 90, 0.2, 0.9 } })
		B:block(root, v(1.4, 0.3, 1.2), cf(-1.0, capY + 1.1, -1.2, 0, 2, 0), MOSS)
		B:block(root, v(1.2, 0.3, 1.4), cf(1.2, capY + 1.1, 1.0, 0, 2, 0), MOSS_DK)

		------------------------------------------------------------ vines
		-- point on a square perimeter (half-size hs) at angle a, height y
		local function sq(a, hs, y)
			local dx, dz = math.sin(rad(a)), -math.cos(rad(a))
			local m = math.max(math.abs(dx), math.abs(dz))
			return v(dx / m * hs, y, dz / m * hs)
		end
		local function vine(a0, a1, y0, y1, steps, hs, leafEvery, budAt)
			local prev = sq(a0, hs, y0)
			for i = 1, steps do
				local f = i / steps
				local p = sq(a0 + (a1 - a0) * f, hs, y0 + (y1 - y0) * f)
				B:bar(root, prev, p, 0.32, 0.32, GREEN_DK)
				if i % leafEvery == 0 then
					local out = v(p.X, 0, p.Z).Unit
					local lf = CFrame.lookAt(p + out * 0.35, p + out * 2) * CFrame.Angles(rad(-25), 0, rad(rnd(-30, 30)))
					B:block(root, v(0.65, 0.16, 0.85), lf * CFrame.new(0, 0, -0.2), (i % (2 * leafEvery) == 0) and GREEN_LT or GREEN)
				end
				if budAt and budAt[i] then
					local out = v(p.X, 0, p.Z).Unit
					B:block(root, v(0.4, 0.45, 0.4), CFrame.new(p + out * 0.3 + v(0, 0.25, 0)), INSIDE)
					B:block(root, v(0.22, 0.2, 0.22), CFrame.new(p + out * 0.3 + v(0, 0.55, 0)), RIM)
				end
				prev = p
			end
		end
		-- main vine: starts at the back-left foot, winds up 1.25 turns (crosses
		-- the front just under the big jaw, leaves the small jaw clear)
		vine(200, 200 + 450, 1.0, 9.0, 20, 1.78, 2, { [7] = true, [17] = true })
		-- second vine: shorter, from the front-right, winds the other way
		vine(130, 130 - 300, 1.0, 5.6, 12, 1.82, 3, { [9] = true })

		------------------------------------------------------------ fx
		B:emitter(glows[1], "glow", { name = "JawGlow", color = { "#e6ffb0", LIME }, rate = 1.0, size = 0.8, speed = { 0.1, 0.3 } })
		B:emitter(budGlow, "sparkle", { name = "BudSparkle", color = { "#eaffb0", LIME }, rate = 2, size = 0.25, speed = { 0.2, 0.6 } })
		B:light(glows[1], { color = "#c8ff7a", brightness = 0.6, range = 8, name = "TotemLight" })
	end,
}
