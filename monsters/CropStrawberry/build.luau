--!nocheck
-- Strawberry Bush (Crop #7, Secret): a lush round bush of stepped emerald leaf
-- clumps growing out of a little wooden planter box. Oversized stepped
-- strawberries (plus-shaped tiers that read round, cap on top, tip down) dangle
-- all around it with light shine squares, tiny yellow seed dots and leafy
-- star caps. White strawberry flowers with yellow centres dot the leaves and a
-- giant hero strawberry crowns the top. Secret bling: a few neon pink sparkle
-- stars, two tiny floating berries and a pink/white sparkle emitter.
-- Static prop: no motion.
return {
	DisplayName = "Strawberry Bush",
	Rarity = "Secret",
	Element = "Garden",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		-- palette
		local RED, RED_DK, RED_LT, SHINE = "#ff1f3d", "#b30f2c", "#ff6a80", "#ffffff"
		local SEED = "#ffe14d"
		local RED_TOP, BERRY_SHINE = "#ff4a5e", "#ffb3bd"
		local CAP, CAP_DK = "#36c94a", "#178a35"
		local GREEN, GREEN_DK, GREEN_LT, LIME = "#1fb356", "#0e6a37", "#55dc6a", "#b4f25a"
		local WHITE, CENTER = "#ffffff", "#ffc61a"
		local WOOD, WOOD_LT, WOOD_DK = "#c47a38", "#e09c55", "#80481f"
		local DIRT, DIRT_DK = "#5a3520", "#3a2213"
		local PINK = "#ff4fd8"
		local NEON = { mat = "Neon", name = "Sparkle" }

		------------------------------------------------------------------
		-- Planter box + soil (own bone so the game can remove it)
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local H = 3.2 -- half size of the box
		-- four walls: two plank strips each (lower darker, upper lighter)
		for i = 0, 3 do
			local f = CFrame.Angles(0, rad(i * 90), 0)
			B:block(soil, v(5.8, 0.5, 0.5), f * CFrame.new(0, 0.25, -H), WOOD, S)
			B:block(soil, v(5.8, 0.5, 0.6), f * CFrame.new(0, 0.75, -H - 0.05), WOOD_LT, S)
		end
		-- chunky corner posts with light caps
		for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			B:block(soil, v(1.0, 1.2, 1.0), cf(c[1] * H, 0.6, c[2] * H), WOOD_DK, S)
			B:block(soil, v(1.1, 0.25, 1.1), cf(c[1] * H, 1.25, c[2] * H), WOOD_LT, S)
		end
		-- soil fill + clods
		B:block(soil, v(6.0, 0.4, 6.0), cf(0, 0.8, 0), DIRT, S)
		B:block(soil, v(0.8, 0.3, 0.7), cf(2.3, 1.05, -2.3), DIRT_DK, S)
		B:block(soil, v(0.5, 0.25, 0.45), cf(-2.35, 1.03, -2.4), "#a39787", S)

		------------------------------------------------------------------
		-- Bush: stepped round core + trifoliate leaf clusters
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, 1.0, 0))
		local CZ = 0.15 -- bush centre z (slightly back so the front berries read)
		local function plus(bone, w, d, y0, y1, col, x, z)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(bone, v(w, h, d), cf(x or 0, y, z or CZ), col)
			B:block(bone, v(d, h, w), cf(x or 0, y, z or CZ), col)
		end
		plus(crop, 4.4, 3.2, 0.9, 1.5, GREEN_DK)
		plus(crop, 5.6, 4.2, 1.5, 2.7, GREEN_DK)
		plus(crop, 5.4, 4.0, 2.7, 3.7, GREEN)
		plus(crop, 4.2, 3.0, 3.7, 4.4, GREEN)

		-- a leaf cluster: three stepped leaflets fanned outward + lime midrib
		-- a = angle around the bush (0 = front), tilt = droop of the tip (deg)
		local function cluster(a, r, y, s, tilt, col, rib)
			local f = CFrame.new(r * math.sin(rad(a)), y, CZ - r * math.cos(rad(a))) * CFrame.Angles(0, -rad(a), 0) * CFrame.Angles(-rad(tilt), 0, 0)
			B:block(crop, v(1.1 * s, 0.4, 1.8 * s), f * CFrame.new(0, 0, -0.7 * s), col)
			B:block(crop, v(0.95 * s, 0.4, 1.3 * s), f * CFrame.new(0.9 * s, -0.12, -0.35 * s), col)
			B:block(crop, v(0.95 * s, 0.4, 1.3 * s), f * CFrame.new(-0.9 * s, -0.12, -0.35 * s), col)
			if rib then
				B:block(crop, v(0.3, 0.1, 1.3 * s), f * CFrame.new(0, 0.22, -0.8 * s), rib)
			end
		end
		-- lower skirt ring (dark, droops over the berries)
		for i = 0, 7 do
			local a = i * 45 + 22.5
			cluster(a, 2.6, 2.55 + (i % 2) * 0.35, 1.05, 15, i % 2 == 0 and GREEN or GREEN_DK)
		end
		-- middle ring breaks up the core's flat faces
		for i = 0, 3 do
			cluster(i * 90, 2.45, 3.35, 0.95, 8, i % 2 == 0 and GREEN_LT or GREEN, i % 2 == 0 and LIME or nil)
		end
		-- upper ring (brighter, catches the sun)
		for i = 0, 5 do
			local a = i * 60
			cluster(a, 1.5, 4.2, 0.95, -25, i % 2 == 0 and GREEN_LT or GREEN, i % 2 == 0 and LIME or nil)
		end

		------------------------------------------------------------------
		-- Strawberry: plus-shaped stepped tiers, leafy star cap on top, tip
		-- down. f = frame at the top centre, local -Z faces outward.
		------------------------------------------------------------------
		local function berry(f, s, stalkTo)
			local function at(x, y, z) return f * CFrame.new(x * s, y * s, z * s) end
			B:block(crop, v(1.4 * s, 0.5 * s, 1.0 * s), at(0, -0.25, 0), RED)
			B:block(crop, v(1.0 * s, 0.5 * s, 1.4 * s), at(0, -0.25, 0), RED)
			B:block(crop, v(1.05 * s, 0.45 * s, 1.05 * s), at(0, -0.72, 0), RED)
			B:block(crop, v(0.6 * s, 0.4 * s, 0.6 * s), at(0, -1.12, 0), RED_DK)
			-- shine + seeds on the outward face
			B:block(crop, v(0.32 * s, 0.26 * s, 0.1), at(-0.24, -0.18, -0.72), BERRY_SHINE)
			B:block(crop, v(0.16, 0.2, 0.1), at(0.26, -0.32, -0.72), SEED)
			B:block(crop, v(0.16, 0.2, 0.1), at(-0.1, -0.72, -0.55), SEED)
			-- leafy star cap + stalk
			B:block(crop, v(1.45 * s, 0.18, 0.42 * s), at(0, 0.05, 0), CAP)
			B:block(crop, v(0.42 * s, 0.18, 1.45 * s), at(0, 0.05, 0), CAP)
			local top = (f * CFrame.new(0, 0.1, 0)).Position
			B:beam(crop, top, stalkTo, 0.22, 0.22, CAP_DK)
		end
		-- dangling berries: {angle, radius, top y, scale}
		local BERRIES = {
			{ 0, 3.45, 2.7, 1.3 }, { 45, 3.5, 2.45, 1.15 }, { 90, 3.45, 2.75, 1.2 }, { 135, 3.4, 2.5, 1.1 },
			{ 180, 3.4, 2.7, 1.15 }, { 225, 3.4, 2.5, 1.1 }, { 270, 3.45, 2.75, 1.2 }, { 315, 3.5, 2.45, 1.15 },
		}
		for _, b in BERRIES do
			local a = rad(b[1])
			local d = v(math.sin(a), 0, -math.cos(a))
			local pos = v(0, b[3], CZ) + d * b[2]
			local f = CFrame.new(pos) * CFrame.Angles(0, -a, 0)
			berry(f, b[4], pos - d * 0.9 + v(0, 0.8, 0))
		end

		------------------------------------------------------------------
		-- White strawberry flowers (plus of petals + yellow centre)
		------------------------------------------------------------------
		local function flower(a, r, y, tilt)
			local f = CFrame.new(r * math.sin(rad(a)), y, CZ - r * math.cos(rad(a))) * CFrame.Angles(0, -rad(a), 0) * CFrame.Angles(-rad(tilt), 0, 0)
			B:block(crop, v(1.3, 0.25, 0.5), f, WHITE)
			B:block(crop, v(0.5, 0.25, 1.3), f, WHITE)
			B:block(crop, v(0.5, 0.35, 0.5), f * CFrame.new(0, 0.08, 0), CENTER)
		end
		for _, a in { 67.5, 157.5, 247.5, 337.5 } do
			flower(a, 3.25, 3.5, 30)
		end
		for _, a in { 30, 150, 270 } do
			flower(a, 2.55, 4.05, 35)
		end

		------------------------------------------------------------------
		-- Giant hero strawberry on top
		------------------------------------------------------------------
		local HZ, HY = -0.1, -0.25
		plus(crop, 0.8, 0.8, 3.7, 4.1, RED_DK, 0, HZ)
		plus(crop, 1.4, 0.9, 4.05, 4.55, RED_DK, 0, HZ)
		plus(crop, 2.2, 1.4, 4.5, 5.05, RED, 0, HZ)
		plus(crop, 3.1, 2.1, 5.0, 5.6, RED, 0, HZ)
		plus(crop, 3.3, 2.3, 5.55, 6.1, RED, 0, HZ)
		plus(crop, 2.8, 1.8, 6.05, 6.4, RED_TOP, 0, HZ)
		-- shine squares (front-left) + side highlight
		B:block(crop, v(0.7, 0.45, 0.12), cf(-0.65, 5.85, HZ - 1.67), BERRY_SHINE)
		B:block(crop, v(0.3, 0.25, 0.14), cf(-0.85, 5.95, HZ - 1.72), SHINE)
		B:block(crop, v(0.35, 0.35, 0.12), cf(-1.0, 5.3, HZ - 1.57), BERRY_SHINE)
		B:block(crop, v(0.12, 0.4, 0.6), cf(-1.67, 5.85, HZ - 0.45), RED_LT)
		-- seed dots
		local SEEDS = {
			{ 0.6, 5.9, -1.65 }, { 0.0, 5.72, -1.65 }, { 0.7, 5.3, -1.55 }, { -0.35, 5.25, -1.55 },
			{ 0.25, 4.75, -1.1 }, { -0.4, 4.8, -1.1 },
		}
		for _, sd in SEEDS do
			B:block(crop, v(0.2, 0.26, 0.12), cf(sd[1], sd[2], HZ + sd[3] - 0.04), SEED)
		end
		for _, sx in { 1, -1 } do
			B:block(crop, v(0.12, 0.26, 0.2), cf(sx * 1.69, 5.85, HZ + 0.5 * sx), SEED)
			B:block(crop, v(0.12, 0.26, 0.2), cf(sx * 1.59, 5.3, HZ - 0.4 * sx), SEED)
		end
		HY = -0.2
		-- big leafy star cap + stalk
		B:block(crop, v(2.9, 0.25, 0.75), cf(0, 6.7 + HY, HZ), CAP)
		B:block(crop, v(0.75, 0.25, 2.9), cf(0, 6.7 + HY, HZ), CAP)
		B:block(crop, v(1.8, 0.3, 1.8), cf(0, 6.75 + HY, HZ, 0, 45, 0), CAP_DK)
		B:block(crop, v(0.4, 0.55, 0.4), cf(0.05, 7.1 + HY, HZ), CAP_DK)

		------------------------------------------------------------------
		-- Secret bling: neon pink sparkle stars, floating mini berries, FX
		------------------------------------------------------------------
		local function star(x, y, z, s)
			B:block(crop, v(0.18, 0.9 * s, 0.18), cf(x, y, z), PINK, NEON)
			B:block(crop, v(0.9 * s, 0.18, 0.18), cf(x, y, z), PINK, NEON)
		end
		star(1.9, 6.55, -0.9, 1)
		star(-2.3, 5.9, -1.4, 0.8)
		star(2.9, 5.3, 1.6, 0.7)
		local function miniBerry(x, y, z, a)
			local f = CFrame.new(x, y, z) * CFrame.Angles(0, rad(a), rad(12))
			B:block(crop, v(0.7, 0.6, 0.7), f, RED)
			B:block(crop, v(0.4, 0.3, 0.4), f * CFrame.new(0, -0.42, 0), RED_DK)
			B:block(crop, v(0.8, 0.14, 0.3), f * CFrame.new(0, 0.36, 0), CAP)
		end
		miniBerry(-3.0, 6.4, 0.4, 25)
		miniBerry(3.4, 6.0, -1.2, -20)

		local fx = B:block(crop, v(6, 4, 6), cf(0, 4.0, CZ), RED, { tr = 1, name = "SparkleFX" })
		B:emitter(fx, "sparkle", { name = "PinkSparkle", color = { PINK, "#ffffff" }, rate = 5 })
		local glowFx = B:block(crop, v(2.5, 2, 2.5), cf(0, 5.8, HZ), RED, { tr = 1, name = "HeroFX" })
		B:emitter(glowFx, "glow", { name = "HeroGlow", color = "#ff7ab8", rate = 1.2 })
		B:light(glowFx, { color = "#ff7ab8", brightness = 0.8, range = 9, name = "HeroLight" })
	end,
}
