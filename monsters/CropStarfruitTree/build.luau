--!nocheck
-- Golden Starfruit Tree (Crop #10, Apex): the most magical crop in the pack.
-- A twisting stepped trunk of pale birch-white / silver bark with spiralling
-- gold veins rises from a mound of rich dark soil ringed with little crystal
-- and gold stones. Its layered canopy is vivid teal-turquoise and mint with
-- pink blossom clusters, hung with glowing golden STARFRUIT (stepped five-point
-- stars), crowned by a golden star. Neon only on small accents (star
-- highlights, a few vein bits, crystal tips); a soft golden light, sparkles,
-- glowing motes, drifting petals and floating star/leaf voxel cubes.
-- Static prop: no motion.luau. Soil parts live on the "Soil" bone.
return {
	DisplayName = "Golden Starfruit Tree",
	Rarity = "Apex",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad

		-- palette ---------------------------------------------------------
		local DIRT, DIRTD, DIRTL, CLOD = "#6e3c22", "#4c2815", "#8a512c", "#2f180b"
		local CRYS, CRYSD, CRYSP, CRYSN = "#7af0ff", "#33b2e0", "#c7a0ff", "#a8fbff"
		local GOLD, GOLDD, GOLDL, GOLDN = "#ffc21f", "#d68b0e", "#ffe57a", "#ffd84a"
		local BIRCH, SILVER, SILVERD, BMARK = "#f3efe6", "#cfd5e0", "#9fa6b8", "#4a4556"
		local TEALX, TEALD, TEAL, TURQ, MINT, MINTH = "#08606c", "#0c94a0", "#14bcbc", "#3fe6d6", "#7cf2c8", "#d4ffec"
		local MINTM = "#5fe0c2"
		local PINK, PINKL, PINKD, POLLEN = "#ff63b4", "#ffadd8", "#d83c8a", "#fff0a0"
		local SGOLD, SYEL, SORA = "#ffd01c", "#fff27a", "#ffa21a"

		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local crop = B:bone("Crop", "Root", v(0, 0, 0))
		local SOIL = { name = "Soil" }

		-- stepped octagon slab: plus shape + inner square (reads round)
		local function oct(bone, y0, y1, w, color, opts)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(bone, v(w, h, w * 0.6), cf(0, y, 0), color, opts)
			B:block(bone, v(w * 0.6, h, w), cf(0, y + 0.01, 0), color, opts)
			B:block(bone, v(w * 0.82, h - 0.04, w * 0.82), cf(0, y, 0), color, opts)
		end
		local TIERS = { { 1.9, 7.6 }, { 1.35, 11 }, { 0.7, 14 } } -- {top y, width}, top tier first
		local function topAt(x, z)
			for _, t in TIERS do
				local w = t[2]
				local ax, az = math.abs(x), math.abs(z)
				if (ax <= w / 2 and az <= w * 0.3) or (ax <= w * 0.3 and az <= w / 2) or (ax <= w * 0.41 and az <= w * 0.41) then
					return t[1]
				end
			end
			return 0
		end

		------------------------------------------------------------------
		-- SOIL MOUND: rich dark soil ringed with crystal + gold stones
		------------------------------------------------------------------
		oct(soil, 0, 0.7, 14, DIRTD, SOIL)
		oct(soil, 0.7, 1.35, 11, DIRT, SOIL)
		oct(soil, 1.35, 1.9, 7.6, DIRTL, SOIL)
		for _, c in { { -3.2, 2.4, 0.7 }, { 2.6, -2.9, 0.6 }, { 3.4, 2.2, 0.55 }, { -4.6, -1.6, 0.6 }, { 0.6, 4.4, 0.6 }, { -2.0, -4.7, 0.5 } } do
			B:block(soil, v(c[3], 0.3, c[3] * 0.8), cf(c[1], topAt(c[1], c[2]) + 0.1, c[2]), CLOD, SOIL)
		end
		-- ring of stones: crystal clusters alternate with gold nuggets
		for i = 0, 9 do
			local a = rad(i * 36 + 12)
			local r = i % 2 == 0 and 6.1 or 5.6
			local x, z = math.cos(a) * r, math.sin(a) * r
			local y = topAt(x, z)
			if i % 2 == 0 then
				local col = (i % 4 == 0) and CRYS or CRYSP
				B:block(soil, v(1.1, 0.55, 1.1), cf(x, y + 0.22, z), CRYSD, SOIL)
				B:block(soil, v(0.75, 1.4, 0.75), cf(x - 0.1, y + 1.1, z + 0.05), col, SOIL)
				B:block(soil, v(0.5, 0.8, 0.5), cf(x + 0.45, y + 0.75, z - 0.3), col, SOIL)
				B:gem(soil, v(0.4, 0.5, 0.4), cf(x - 0.1, y + 2.0, z + 0.05), CRYSN, { name = "Soil" })
			else
				B:block(soil, v(1.0, 0.55, 0.8), cf(x, y + 0.22, z), GOLDD, SOIL)
				B:block(soil, v(0.7, 0.35, 0.6), cf(x, y + 0.62, z), GOLD, SOIL)
				B:block(soil, v(0.3, 0.12, 0.3), cf(x - 0.12, y + 0.82, z - 0.08), GOLDL, SOIL)
			end
		end

		------------------------------------------------------------------
		-- TWISTING TRUNK: stacked birch segments, each yawed + shifted a
		-- little more, with gold veins that spiral up as the stack twists
		------------------------------------------------------------------
		B:block(crop, v(4.8, 1.0, 3.4), cf(0, 2.2, 0), SILVER) -- root flare
		B:block(crop, v(3.4, 1.02, 4.8), cf(0, 2.2, 0), SILVER)
		local SEGN = 8
		local segs = {}
		for i = 0, SEGN - 1 do
			local w = 3.7 - i * 0.16
			local h = 1.45
			local y = 2.6 + i * h + h / 2
			local a = rad(i * 52)
			local ox, oz = math.cos(a) * 0.45 * math.min(i, 3) / 3, math.sin(a) * 0.45 * math.min(i, 3) / 3
			local seg = CFrame.new(ox, y, oz) * CFrame.Angles(0, rad(i * 12), 0)
			segs[i] = { cf = seg, w = w, h = h }
			B:block(crop, v(w, h + 0.06, w), seg, i % 3 == 2 and SILVER or BIRCH)
			local d = w / 2 + 0.05
			-- spiralling gold veins on two faces
			local veinNeon = (i == 2 or i == 5)
			if veinNeon then
				B:gem(crop, v(0.3, h + 0.1, 0.12), seg * CFrame.new(0.4, 0, -d), GOLDN, { name = "VeinGlow" })
			else
				B:block(crop, v(0.32, h + 0.1, 0.14), seg * CFrame.new(0.4, 0, -d), GOLD)
			end
			B:block(crop, v(0.32, h + 0.1, 0.14), seg * CFrame.new(-0.5, 0, d), GOLD)
			-- dark birch dashes on the other two faces
			B:block(crop, v(0.14, 0.24, 0.9), seg * CFrame.new(d, (i % 2) * 0.4 - 0.2, 0.3), BMARK)
			B:block(crop, v(0.14, 0.24, 0.7), seg * CFrame.new(-d, 0.3 - (i % 2) * 0.5, -0.4), BMARK)
		end
		local trunkTop = 2.6 + SEGN * 1.45 -- ~14.2

		-- silver-white roots running down the mound
		for k = 0, 3 do
			local a = rad(k * 90 + 20)
			local c, s = math.cos(a), math.sin(a)
			local yaw = -(k * 90 + 20)
			B:block(crop, v(2.0, 1.1, 1.1), cf(c * 2.4, 2.1, s * 2.4, 0, yaw, 0), BIRCH)
			B:block(crop, v(1.3, 0.75, 0.8), cf(c * 3.6, 1.75, s * 3.6, 0, yaw, 0), SILVER)
			B:block(crop, v(0.9, 0.5, 0.6), cf(c * 4.5, 1.45, s * 4.5, 0, yaw, 0), SILVERD)
			B:block(crop, v(0.5, 0.14, 0.2), cf(c * 2.4, 2.66, s * 2.4, 0, yaw, 0), GOLD)
		end

		-- twisting branches fanning up into the lower canopy tier
		for k = 0, 4 do
			local a = rad(k * 72 + 30)
			local c, s = math.cos(a), math.sin(a)
			local yaw = -(k * 72 + 30)
			B:block(crop, v(3.0, 1.0, 1.0), cf(c * 2.4, 12.6 + (k % 2) * 0.5, s * 2.4, 0, yaw, 0), BIRCH)
			B:block(crop, v(1.0, 2.0, 1.0), cf(c * 3.9, 13.6 + (k % 2) * 0.5, s * 3.9, 0, yaw, 0), SILVER)
			B:block(crop, v(0.14, 0.9, 0.3), cf(c * 3.9, 13.4 + (k % 2) * 0.5, s * 3.9, 0, yaw, 0) * CFrame.new(-0.52, 0, 0), GOLD)
		end
		-- the trunk continues up through the tiers
		B:block(crop, v(2.0, 6.0, 2.0), cf(0.1, trunkTop + 2.5, 0.1, 0, 30, 0), BIRCH)

		------------------------------------------------------------------
		-- LAYERED CANOPY: three tiers of teal / turquoise / mint clusters
		------------------------------------------------------------------
		local function puff(a, r, y, s, body, top, under)
			local ar = rad(a)
			local x, z = math.cos(ar) * r, math.sin(ar) * r
			if under ~= false then
				B:block(crop, v(s * 0.74, s * 0.24, s * 0.74), cf(x, y - s * 0.36, z), TEALD) -- dark underside
			end
			-- the two arms of the plus take neighbouring shades: notched corners read as shading
			local shade = ({ [TEAL] = TEALD, [TURQ] = TEAL, [MINT] = MINTM })[body] or body
			B:block(crop, v(s, s * 0.52, s * 0.7), cf(x, y, z), (a // 45) % 2 == 0 and body or shade)
			B:block(crop, v(s * 0.7, s * 0.52 + 0.04, s), cf(x, y, z), (a // 45) % 2 == 0 and shade or body)
			B:block(crop, v(s * 0.68, s * 0.24, s * 0.68), cf(x, y + s * 0.36, z), top) -- light cap
			return v(x, y, z)
		end
		local tierA, tierB, tierC = {}, {}, {}
		-- tier A (lowest, widest)
		B:block(crop, v(12.4, 2.4, 7.4), cf(0, 14.6, 0), TEALX)
		B:block(crop, v(7.4, 2.42, 12.4), cf(0, 14.6, 0), TEALX)
		for i = 0, 7 do
			local big = i % 2 == 0
			tierA[i] = puff(i * 45 + 22.5, big and 6.6 or 6.3, big and 14.6 or 15.2, big and 4.4 or 4.0, big and TEAL or TURQ, big and TURQ or MINT)
		end
		-- tier B
		B:block(crop, v(9.0, 2.2, 5.4), cf(0, 18.4, 0), TEALD)
		B:block(crop, v(5.4, 2.22, 9.0), cf(0, 18.4, 0), TEALD)
		for i = 0, 5 do
			tierB[i] = puff(i * 60, 4.6, 18.5 + (i % 2) * 0.4, 3.8, i % 2 == 0 and TURQ or TEAL, MINT)
		end
		-- tier C (top crown)
		B:block(crop, v(4.6, 2.6, 4.6), cf(0, 20.6, 0), MINTM)
		for i = 0, 3 do
			tierC[i] = puff(i * 90 + 45, 2.3, 21.6, 3.2, MINT, MINTH, false)
		end
		puff(0, 0, 22.6, 3.0, MINT, MINTH, false)

		------------------------------------------------------------------
		-- PINK BLOSSOM CLUSTERS (plus-shaped petals + pollen centre)
		------------------------------------------------------------------
		local function blossom(c, big)
			local s = big and 1.7 or 1.35
			B:block(crop, v(1.1 * s, 0.45 * s, 0.34), c, PINK)
			B:block(crop, v(0.45 * s, 1.1 * s, 0.36), c, PINKL)
			B:block(crop, v(0.4 * s, 0.4 * s, 0.2), c * CFrame.new(0, 0, -0.22), POLLEN)
		end
		local UP = CFrame.Angles(rad(90), 0, 0) -- local -Z points up
		-- a stepped pink blossom clump sitting on top of a cluster
		local function topBlossom(p, s, dx, dz, big)
			local k = big and 1 or 0.8
			local x, y, z = p.X + dx, p.Y + s * 0.48, p.Z + dz
			B:block(crop, v(1.8, 0.7, 1.2) * k, cf(x, y + 0.3 * k, z), PINK)
			B:block(crop, v(1.2, 0.72, 1.8) * k, cf(x, y + 0.3 * k, z), PINK)
			B:block(crop, v(1.0, 0.4, 1.0) * k, cf(x, y + 0.8 * k, z), PINKL)
			B:block(crop, v(0.4, 0.2, 0.4) * k, cf(x + 0.15, y + 1.05 * k, z - 0.1), POLLEN)
		end
		local function sideBlossom(a, r, y, big)
			local ar = rad(a)
			local yaw = math.deg(math.atan2(-math.cos(ar), -math.sin(ar)))
			blossom(CFrame.new(math.cos(ar) * r, y, math.sin(ar) * r) * CFrame.Angles(0, rad(yaw), 0), big)
		end
		for i = 0, 7, 2 do
			topBlossom(tierA[i], 4.4, 0.4, -0.3, true)
		end
		for i = 1, 5, 2 do
			topBlossom(tierB[i], 3.8, -0.3, 0.3, false)
		end
		topBlossom(tierC[1], 3.2, 0, 0, true)
		topBlossom(tierC[3], 3.2, 0, 0, false)
		for _, b in { { 0, 15.8, 8.7 }, { 135, 14.9, 8.4 }, { 250, 15.4, 8.5 }, { 205, 18.9, 6.6 }, { 30, 19.3, 6.5 } } do
			sideBlossom(b[1], b[3], b[2], true)
		end

		------------------------------------------------------------------
		-- GOLDEN STARFRUIT: stepped five-point stars facing outward
		------------------------------------------------------------------
		local function star(base, s, neon)
			local function pb(size, x, y, col)
				B:block(crop, size * s, base * CFrame.new(x * s, y * s, 0), col)
			end
			pb(v(1.1, 1.1, 0.8), 0, 0, SGOLD) -- body
			pb(v(0.5, 0.55, 0.62), 0, 0.8, SGOLD) -- top point
			if neon then -- glowing top tip
				B:gem(crop, v(0.26, 0.32, 0.44) * s, base * CFrame.new(0, 1.2 * s, 0), GOLDN, { name = "StarTip" })
			else
				pb(v(0.26, 0.32, 0.44), 0, 1.2, SYEL)
			end
			for _, sd in { -1, 1 } do
				pb(v(0.6, 0.48, 0.62), sd * 0.82, 0.14, SGOLD) -- arms
				pb(v(0.3, 0.28, 0.44), sd * 1.24, 0.2, SYEL)
				pb(v(0.48, 0.55, 0.62), sd * 0.46, -0.78, SGOLD) -- legs
				pb(v(0.28, 0.3, 0.44), sd * 0.68, -1.16, SORA)
			end
			local hl = base * CFrame.new(-0.18 * s, 0.18 * s, -0.42 * s)
			if neon then
				B:gem(crop, v(0.42, 0.42, 0.1) * s, hl, GOLDN, { name = "StarGlow" })
			else
				B:block(crop, v(0.42, 0.42, 0.1) * s, hl, SYEL)
			end
		end
		local function facing(a)
			local ar = rad(a)
			return math.deg(math.atan2(-math.cos(ar), -math.sin(ar)))
		end
		-- hanging under tier A: stem down from the cluster, star below
		for i = 0, 7 do
			local p = tierA[i]
			local a = i * 45 + 22.5
			local ar = rad(a)
			local px, pz = p.X + math.cos(ar) * 0.9, p.Z + math.sin(ar) * 0.9
			local top = p.Y - (i % 2 == 0 and 4.4 or 4.0) * 0.4
			B:block(crop, v(0.22, 1.0, 0.22), cf(px, top - 0.4, pz), GOLDD) -- stem
			star(CFrame.new(px, top - 2.0, pz) * CFrame.Angles(0, rad(facing(a)), 0), 1.1, true)
		end
		-- nestled on the sides of tier B
		for i = 0, 5, 2 do
			local a = i * 60 + 30
			local ar = rad(a)
			star(CFrame.new(math.cos(ar) * 6.2, 18.0, math.sin(ar) * 6.2) * CFrame.Angles(0, rad(facing(a)), 0), 0.85, true)
		end
		-- crowning star on the very top (faces front)
		B:block(crop, v(0.4, 0.6, 0.4), cf(0, 24.2, 0), GOLDD)
		star(CFrame.new(0, 24.75, 0), 0.85, true)
		B:gem(crop, v(0.2, 0.2, 0.1), cf(0.2, 24.9, 0.38), GOLDN, { name = "StarGlowBack" })

		------------------------------------------------------------------
		-- FX: floating star + leaf cubes, golden light, sparkles, petals
		------------------------------------------------------------------
		local fl = B:bone("Floaters", "Crop", v(0, 17, 0))
		local function floatStar(x, y, z, tilt)
			local c = CFrame.new(x, y, z) * CFrame.Angles(0, rad(tilt), rad(15))
			B:block(fl, v(1.4, 0.45, 0.4), c, SGOLD)
			B:block(fl, v(0.45, 1.4, 0.42), c, SGOLD)
			B:gem(fl, v(0.3, 0.3, 0.12), c * CFrame.new(0, 0, -0.24), GOLDN, { name = "FloatGlow" })
		end
		floatStar(9.4, 18.6, -2.5, 30)
		floatStar(-9.0, 16.4, 3.0, -30)
		floatStar(-3.5, 23.0, -7.0, 0)
		B:block(fl, v(0.8, 0.8, 0.8), cf(-8.4, 20.6, -3.5, 45, 45, 0), MINT)
		B:block(fl, v(0.7, 0.7, 0.7), cf(7.5, 21.8, 4.0, 45, 0, 45), TURQ)
		B:block(fl, v(0.6, 0.6, 0.6), cf(5.0, 13.0, -8.6, 30, 45, 0), PINKL)

		local glowCore = B:block(crop, v(1, 1, 1), cf(0, 16.5, 0), SGOLD, { tr = 1, name = "GlowCore" })
		B:light(glowCore, { name = "GoldenGlow", color = "#ffd75a", brightness = 1.3, range = 20 })
		local aura = B:block(crop, v(16, 10, 16), cf(0, 17.5, 0), TEAL, { tr = 1, name = "CanopyAura" })
		B:emitter(aura, "sparkle", { name = "StarSparkle", color = { "#ffffff", "#ffe36b", "#ffc21f" }, rate = 9, size = { 0.15, 0.55, 0 } })
		B:emitter(aura, "glow", { name = "GoldenMotes", color = { "#ffe36b", "#ffc21f" }, rate = 2, size = { 0.8, 1.6, 0.4 } })
		B:emitter(aura, "leaf", { name = "BlossomPetals", color = { PINKL, PINK }, rate = 1.6, size = { 0.3, 0.3, 0.2 }, speed = { 0.3, 1 }, accel = { 0, -1.4, 0 } })
		local ringFx = B:block(soil, v(12, 1, 12), cf(0, 1.4, 0), CRYS, { tr = 1, name = "Soil" })
		B:emitter(ringFx, "sparkle", { name = "CrystalTwinkle", color = { "#ffffff", CRYS, CRYSP }, rate = 3, size = { 0.1, 0.35, 0 } })
	end,
}
