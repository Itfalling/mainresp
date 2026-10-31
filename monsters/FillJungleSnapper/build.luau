--!nocheck
-- Baby Snapper (Snap-Jaw Jungle filler, v2).
-- A tiny flytrap built like the Flytrap Stage plants, shrunk to scatter size:
-- * a low pixel-round bog-dirt patch with a moss layer, a stone and a tuft
-- * a rosette of five stepped leaf blades (lime midribs, tips bent down)
-- * a short stepped stem with a leafy collar and a lime growth ring
-- * one trap head propped open: pink inner pads with a darker centre, red
--   lips, a stepped oval green lobe (lighter crown, dark speckles, lime veins,
--   dark side panels), interlocking cream cilia teeth, two trigger hairs and
--   a dark throat wall; one tiny glowing lime drop on the lower lip.
-- Lightweight scenery meant to be copy-pasted many times: anchored,
-- weld-free, no scripts or effects.
return {
	DisplayName = "Baby Snapper",
	Rarity = "Filler",
	Filler = true,
	Element = "Snap-Jaw Jungle",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Flytrap Stage: FlytrapDecor / TrapPitcherPod)
		local DIRT_DK, DIRT_DK2, DIRT = "#3f2516", "#4d2d1a", "#6a4126"
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT = "#8d8174", "#a39787"
		local GREEN, GREEN_DK, GREEN_LT, GREEN_TOP = "#3caa3c", "#1f6e2a", "#a6e04c", "#58c447"
		local INSIDE, INSIDE_DK, RIM, THROAT = "#ff5c7c", "#b02448", "#c92a48", "#5c0f25"
		local HAIR, CREAM, LIME = "#ffb3c4", "#fff4d2", "#86ff3c"

		------------------------------------------------------------ footing
		-- low pixel-round dirt patch (two crossed boxes + a 45-degree box)
		B:block(R, v(3.6, 0.22, 2.3), cf(0, 0.11, 0), DIRT_DK)
		B:block(R, v(2.3, 0.21, 3.6), cf(0, 0.105, 0), DIRT_DK)
		B:block(R, v(3.0, 0.2, 3.0), cf(0, 0.1, 0, 0, 45, 0), DIRT_DK2)
		B:block(R, v(2.4, 0.16, 1.6), cf(-0.2, 0.28, 0.2, 0, 15, 0), DIRT)
		-- a few chunky edge clods so the rim isn't a perfect outline
		for _, e in { { 30, 1.75, DIRT_DK2 }, { 140, 1.8, DIRT_DK }, { 215, 1.7, DIRT }, { 300, 1.8, DIRT_DK2 } } do
			local a = rad(e[1])
			B:block(R, v(0.9, 0.3, 0.6), CFrame.new(math.sin(a) * e[2], 0.15, -math.cos(a) * e[2]) * CFrame.Angles(0, -a + rad(8), 0), e[3])
		end
		-- moss layer (two tones)
		B:block(R, v(1.8, 0.14, 1.3), cf(0.5, 0.3, -0.5, 0, -20, 0), MOSS)
		B:block(R, v(1.1, 0.14, 0.9), cf(-0.9, 0.29, 0.8, 0, 30, 0), MOSS_DK)
		-- a stone and a tuft
		B:block(R, v(0.7, 0.4, 0.6), cf(-1.45, 0.3, -0.6, 0, 25, 0), STONE)
		B:block(R, v(0.4, 0.25, 0.35), cf(-1.4, 0.55, -0.62, 0, 50, 0), STONE_LT)
		B:block(R, v(0.25, 0.7, 0.25), cf(1.35, 0.5, 0.75, 0, 20, 10), GRASS)
		B:block(R, v(0.22, 0.5, 0.22), cf(1.55, 0.4, 0.85, 0, 40, -14), GRASS_DK)

		------------------------------------------------------------ rosette
		-- stepped blade: base plate, lime midrib, tip plate bent down
		local function blade(base, a, len, w, up, col)
			local f = CFrame.new(base) * CFrame.Angles(0, -rad(a), 0) * CFrame.Angles(rad(up), 0, 0)
			B:block(R, v(w, 0.22, len * 0.55), f * CFrame.new(0, 0, -len * 0.27), col)
			B:block(R, v(0.2, 0.28, len * 0.6), f * CFrame.new(0, 0.03, -len * 0.33), GREEN_LT)
			local f2 = f * CFrame.new(0, 0, -len * 0.52) * CFrame.Angles(rad(-28), 0, 0)
			B:block(R, v(w * 0.66, 0.22, len * 0.36), f2 * CFrame.new(0, 0, -len * 0.16), col)
		end
		for _, b in { { -30, 1.9, 0.85, 24, GREEN }, { -100, 2.1, 0.9, 18, GREEN_DK }, { -170, 1.8, 0.85, 26, GREEN },
			{ 110, 2.1, 0.9, 18, GREEN_DK }, { 40, 1.8, 0.8, 24, GREEN_TOP } } do
			local a = rad(b[1])
			blade(v(0.35 * math.sin(a), 0.4, 0.2 - 0.35 * math.cos(a)), b[1], b[2], b[3], b[4], b[5])
		end

		------------------------------------------------------------ stem
		B:block(R, v(1.0, 0.35, 1.0), cf(0, 0.5, 0.2), GREEN_DK)
		B:block(R, v(0.9, 0.36, 0.9), cf(0, 0.5, 0.2, 0, 45, 0), GREEN)
		B:block(R, v(0.65, 1.1, 0.65), cf(0, 1.15, 0.2, -4, 0, 0), GREEN_DK)
		B:block(R, v(0.16, 0.7, 0.35), cf(0.34, 1.15, 0.2, -4, 0, 0), GREEN_LT)
		B:block(R, v(0.8, 0.2, 0.8), cf(0, 1.72, 0.17, -4, 0, 0), GREEN_LT)
		B:block(R, v(0.55, 0.75, 0.55), cf(0, 2.12, 0.12, -10, 0, 0), GREEN)
		-- leafy collar hugging the stem base
		for i = 0, 3 do
			local c = CFrame.new(0, 0.55, 0.2) * CFrame.Angles(0, rad(i * 90 + 45), 0) * CFrame.new(0, 0.3, -0.5) * ang(-30, 0, 0)
			B:block(R, v(0.5, 0.7, 0.2), c, (i % 2 == 0) and GREEN or GREEN_TOP)
		end

		------------------------------------------------------------ trap
		-- frame T: hinge at origin, mouth toward local -Z; lid opened by OPEN deg
		local s = 0.45
		local OPEN = 62
		local T = CFrame.new(0, 2.55, 0.15) * CFrame.Angles(rad(-10), rad(10), 0)
		local TL = T * CFrame.Angles(rad(OPEN), 0, 0)
		local function at(F, x, y, z, rx, ry, rz)
			return F * CFrame.new(x * s, y * s, z * s) * ang(rx or 0, ry or 0, rz or 0)
		end
		local function bk(F, sx, sy, sz, x, y, z, col, rx, ry, rz, opts)
			return B:block(R, v(sx * s, sy * s, sz * s), at(F, x, y, z, rx, ry, rz), col, opts)
		end
		local tw = 0.17
		local function tooth(F, x, y, z, rx, rz)
			B:block(R, v(tw, 1.05 * s, tw), at(F, x, y, z, rx, 0, rz), CREAM)
		end
		for _, k in { -1, 1 } do
			local F = k > 0 and TL or T
			-- inside: pink pad, darker centre, red lip line
			bk(F, 3.8, 0.2, 3.2, 0, 0.12 * k, -1.9, INSIDE)
			bk(F, 1.4, 0.1, 2.4, 0, 0.02 * k, -1.8, INSIDE_DK)
			bk(F, 4.4, 0.3, 3.6, 0, 0.3 * k, -1.8, RIM)
			bk(F, 5.0, 0.3, 2.2, 0, 0.3 * k, -1.8, RIM)
			-- stepped green outer lobe (oval outline) with a crown step
			bk(F, 4.2, 0.7, 3.6, 0, 0.75 * k, -1.8, GREEN)
			bk(F, 4.8, 0.6, 2.2, 0, 0.75 * k, -1.8, GREEN)
			bk(F, 3.4, 0.5, 2.8, 0, 1.3 * k, -1.7, k > 0 and GREEN_TOP or GREEN)
			bk(F, 2.0, 0.4, 1.6, 0, 1.68 * k, -1.5, k > 0 and GREEN_LT or GREEN_DK)
			-- darker front lip + side panels
			bk(F, 3.0, 0.6, 0.4, 0, 0.72 * k, -3.75, GREEN_DK)
			bk(F, 3.2, 0.3, 0.6, 0, 0.3 * k, -3.75, RIM)
			for _, sd in { -1, 1 } do
				bk(F, 0.3, 0.5, 2.0, sd * 2.5, 0.75 * k, -1.8, GREEN_DK)
			end
			-- cilia teeth: rows offset half a step so they interlock
			local ty = -0.3 * k
			for _, x in (k < 0 and { -1.5, -0.5, 0.5, 1.5 } or { -1.0, 0, 1.0 }) do
				tooth(F, x, ty, -4.0, 24 * k, 0)
			end
			for _, sd in { -1, 1 } do
				for _, z in (k < 0 and { -2.8, -1.2 } or { -2.0 }) do
					tooth(F, sd * 2.5, ty, z, 0, 24 * k * sd)
				end
				tooth(F, sd * 2.05, ty, -3.6, 17 * k, 17 * k * sd)
			end
		end
		-- lid details: lime veins + dark speckles
		for _, sd in { -1, 1 } do
			bk(TL, 0.3, 0.35, 1.7, sd * 1.55, 1.3, -1.75, GREEN_LT)
		end
		bk(TL, 0.6, 0.3, 0.7, -0.9, 1.6, -2.6, GREEN_DK)
		bk(TL, 0.5, 0.3, 0.5, 1.0, 1.55, -0.8, GREEN_DK)
		-- trigger hairs on the lower pad
		bk(T, 0.3, 1.0, 0.3, -0.9, 0.5, -1.4, HAIR)
		bk(T, 0.3, 1.0, 0.3, 0.8, 0.5, -2.4, HAIR)
		-- hinge block, throat wall, lid back
		bk(T, 2.6, 1.1, 1.0, 0, -0.65, 0.4, GREEN_DK)
		bk(T, 3.4, 1.0, 0.3, 0, 0.35, 0.0, THROAT)
		bk(TL, 2.4, 0.8, 0.8, 0, 0.6, 0.35, GREEN_DK)
		-- one tiny glowing drop hanging off the lower lip
		local lip = at(T, 1.2, -0.3, -3.95).Position
		B:block(R, v(0.18, 0.4, 0.18), CFrame.new(lip + v(0, -0.15, 0)), LIME, { mat = "Neon" })
	end,
}
