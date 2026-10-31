--!nocheck
-- Dino Skull Gate (Bramble Badlands decoration, HERO piece).
-- A giant friendly T-rex skull you can walk straight through:
-- * the jaws gape wide facing -Z: the upper jaw / snout is a stepped bone
--   canopy with a fringe of chunky block teeth, the lower jaw lies on the
--   ground as a U of bone with teeth standing up on both sides, and a muted
--   red tongue makes the path into the mouth
-- * the hollow cranium is the tunnel (7 studs wide, 8 tall) and comes out at
--   a bone arch in the back of the skull; three neck vertebrae trail away
--   behind like stepping stones
-- * big round eye sockets glowing teal (matches the Skull Pumpkin Patch),
--   heavy brows, little horn bumps, nostrils, side openings, cracks + stains
-- * a dead twisted tree with gnarled roots and bare thorny branches on the
--   right, a bramble climbing the left cheek
-- * a glowing lava crack zig-zagging across the ground from a little lava
--   vent on the left, past the jaw, to the roots of the tree
-- * footing: charcoal / ash flagstones, rubble, ash piles, dry grass tufts
--   and loose bones (bone "Soil", removable)
-- Teal socket wisps, lava embers + a little smoke, two soft lights.
-- Static prop: no motion.luau.
return {
	DisplayName = "Dino Skull Gate",
	Rarity = "Decor",
	Element = "Bramble Badlands",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Bramble Badlands) --------------------------------------
		local RK_XD, RK_DK, RK, RK_LT = "#241e22", "#3a3236", "#4a4044", "#625758"
		local RUST_DK, RUST, RUST_LT = "#7a3524", "#94452c", "#b05a36"
		local ASH_DK, ASH, ASH_LT = "#6c6662", "#88827c", "#a7a19a"
		local BONE_LT, BONE, BONE_DK, BONE_SH = "#fbf1d8", "#efe0bc", "#d8c398", "#b89f74"
		local STAIN = "#c08a5a"
		local SOCK, MOUTH = "#2a1f24", "#3a2228"
		local TONGUE, TONGUE_DK = "#9a4450", "#7a3340"
		local TEAL, TEAL_LT, TEAL_DK = "#2fe0c8", "#9affee", "#1f8f86"
		local LAVA, LAVA_Y = "#ff7a1a", "#ffb43a"
		local WOOD_DK, WOOD, WOOD_LT = "#3a2f2c", "#54443e", "#6e5c54"
		local STEM, STEM_DK = "#6a2e3c", "#4a2030"
		local THORN = "#e8d6ae"
		local LEAF_DK, LEAF, LEAF_LT = "#4c5e2a", "#62763a", "#7d9248"
		local BERRY, BERRY_DK = "#5a2346", "#3c1630"
		local GRASS, GRASS_DK = "#9a8a4a", "#76693a"
		local WHITE = "#ffffff"
		local NEON = { mat = "Neon" }

		local seed = 90127
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
		local R = "Root"

		-- key dimensions --------------------------------------------------
		local GW = 3.5 -- half width of the walk-through tunnel
		local GH = 8.0 -- tunnel height (underside of the jaw / cranium)
		local ZF = -8.8 -- front of the snout
		local ZC = -1.4 -- front face of the cranium
		local ZB = 5.4 -- back of the skull

		------------------------------------------------------------------
		-- FOOTING (bone "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local SN = { name = "Soil", mat = "Neon" }
		-- flagstones scattered round the skull, tree and vent
		for _, s in {
			{ -7.4, -1.0, 3.2, 2.6, 15, RK }, { -7.6, 3.6, 2.8, 2.6, -10, ASH_DK }, { 7.4, -1.6, 3.0, 2.6, -20, RK_DK },
			{ 7.2, 3.8, 3.2, 2.8, 12, RK }, { -9.6, -4.2, 2.6, 2.2, 25, RK_DK }, { 10.0, 1.6, 3.4, 3.2, -8, ASH_DK },
			{ -3.4, 7.6, 2.4, 2.0, 20, RK_LT }, { 3.0, 8.0, 2.6, 2.2, -25, RK }, { 0, -10.8, 2.8, 1.8, 4, ASH_DK },
			{ -5.6, -9.6, 2.0, 1.8, -20, RK }, { 5.8, -9.2, 2.2, 1.8, 30, RK_LT },
		} do
			B:block(soil, v(s[3], 0.35, s[4]), cf(s[1], 0.17 + jit(0.02), s[2], jit(1.5), s[5], jit(1.5)), s[6], S)
		end
		-- rubble chunks along the skull walls
		for _, r in {
			{ -6.9, -2.4, 1.0, RK }, { 7.0, 5.6, 0.9, RK_DK }, { -7.1, 5.8, 1.1, RUST_DK }, { 6.8, -2.6, 0.8, ASH },
			{ -10.6, 0.8, 1.2, RK_DK }, { -11.0, -2.2, 0.8, RUST }, { 11.8, -1.6, 0.9, RK }, { 4.5, -10.6, 0.7, RK_LT },
		} do
			B:block(soil, v(r[3] * 1.3, r[3], r[3] * 1.1), cf(r[1], 0.3 + r[3] / 2, r[2], jit(8), jit(40), jit(8)), r[4], S)
		end
		-- ash piles + pebbles
		for _, a in { { -8.6, 1.6 }, { 8.2, -3.8 }, { -2.4, -11.4 }, { 1.8, 10.0 } } do
			B:block(soil, v(1.4, 0.2, 1.0), cf(a[1], 0.42, a[2], 0, jit(40), 0), ASH_LT, S)
			B:block(soil, v(0.7, 0.2, 0.6), cf(a[1] + 0.1, 0.6, a[2], 0, jit(40), 0), ASH_LT, S)
		end
		-- dry grass tufts
		local function tuft(x, z, s)
			for k = 0, 2 do
				local a = k * 120 + jit(20)
				local h = (1.0 + rnd() * 0.6) * s
				B:block(soil, v(0.22, h, 0.22), CFrame.new(x, 0.3 + h / 2, z) * CFrame.Angles(0, rad(a), 0) * CFrame.Angles(rad(18), 0, 0) * CFrame.new(0, 0, -0.14), (k == 1) and GRASS_DK or GRASS, S)
			end
		end
		tuft(-6.6, -4.4, 1.1)
		tuft(6.4, -5.0, 1.0)
		tuft(-8.8, 5.6, 1.2)
		tuft(11.4, 4.2, 1.0)
		tuft(-1.2, 9.6, 0.9)

		-- loose bones on the ground
		local function smallBone(c, yaw, len, s)
			local F = CFrame.new(c) * CFrame.Angles(0, rad(yaw), 0)
			B:block(soil, v(len, 0.42 * s, 0.42 * s), F, BONE, S)
			for sx = -1, 1, 2 do
				B:block(soil, v(0.5 * s, 0.6 * s, 0.5 * s), F * CFrame.new(sx * len / 2, 0, 0.2 * s), BONE_LT, S)
				B:block(soil, v(0.5 * s, 0.6 * s, 0.5 * s), F * CFrame.new(sx * len / 2, 0, -0.2 * s), BONE_DK, S)
			end
		end
		smallBone(v(-8.4, 0.55, -6.8), 35, 1.8, 1)
		smallBone(v(8.6, 0.55, 6.8), -20, 1.6, 0.9)

		------------------------------------------------------------------
		-- LAVA CRACK (Soil) from the vent on the left to the tree roots
		------------------------------------------------------------------
		local crackPts = {
			{ -9.4, -3.6 }, { -8.6, -6.0 }, { -7.0, -7.6 }, { -6.2, -9.8 }, { -4.0, -10.4 },
			{ -2.0, -12.0 }, { 0.6, -11.6 }, { 2.6, -12.4 }, { 4.8, -11.0 }, { 6.6, -11.4 },
			{ 7.6, -8.8 }, { 8.8, -7.2 }, { 8.6, -4.6 }, { 9.6, -2.6 },
		}
		local CY = 0.08
		for i = 1, #crackPts - 1 do
			local a, b = crackPts[i], crackPts[i + 1]
			local w = (i < 4 or i > 11) and 0.95 or 0.8
			B:bar(soil, v(a[1], CY + 0.06, a[2]), v(b[1], CY + 0.06, b[2]), w + 0.2, 0.14, RK_XD, S)
			B:bar(soil, v(a[1], CY + 0.12, a[2]), v(b[1], CY + 0.12, b[2]), w * 0.45, 0.14, (i % 2 == 0) and LAVA_Y or LAVA, SN)
		end
		-- the little lava vent on the left: crusted ring round a glowing pool
		local VX, VZ = -9.8, -2.6
		for i = 0, 7 do
			local a = rad(i * 45 + 10)
			local hh = 0.7 + rnd() * 0.5
			B:block(soil, v(1.1, hh, 0.8), CFrame.new(VX + math.sin(a) * 1.35, hh / 2, VZ - math.cos(a) * 1.35) * CFrame.Angles(0, -a, 0) * ang(jit(6), jit(8), jit(6)), pick({ RK_DK, RK, RK_XD, RUST_DK }), S)
		end
		B:block(soil, v(2.0, 0.4, 2.0), cf(VX, 0.25, VZ, 0, 20, 0), RK_XD, S)
		B:block(soil, v(1.8, 0.12, 1.8), cf(VX, 0.5, VZ, 0, 20, 0), LAVA, SN)
		B:block(soil, v(1.1, 0.12, 1.1), cf(VX, 0.56, VZ, 0, 65, 0), LAVA_Y, SN)
		local vent = B:block(soil, v(1.6, 0.4, 1.6), cf(VX, 0.9, VZ), LAVA, { tr = 1, name = "VentFx" })
		-- glowing pool where the crack ends at the roots
		B:block(soil, v(1.6, 0.3, 1.3), cf(9.8, 0.16, -2.2, 0, 30, 0), RK_XD, S)
		B:block(soil, v(1.1, 0.12, 0.85), cf(9.8, 0.3, -2.2, 0, 30, 0), LAVA_Y, SN)

		------------------------------------------------------------------
		-- LOWER JAW: a U of bone lying on the ground
		------------------------------------------------------------------
		local function jawSide(sg)
			local a, b = v(sg * 4.0, 0, ZF - 0.8), v(sg * 5.0, 0, 1.0)
			local F, len = P.aim(a, b)
			B:block(R, v(1.8, 0.9, len), F * CFrame.new(0, 0.45, 0), BONE_DK)
			B:block(R, v(1.5, 0.6, len - 0.4), F * CFrame.new(0, 1.15, 0), BONE)
			B:block(R, v(0.5, 0.5, len - 1.6), F * CFrame.new(sg * 0.65, 1.2, 0), BONE_LT)
			-- teeth standing up along the jaw
			for i = 0, 4 do
				local f = 0.06 + i * 0.16
				local p = a:Lerp(b, f)
				local th = 1.25 - i * 0.08
				B:block(R, v(0.62, th, 0.62), CFrame.new(p + v(-sg * 0.15, 1.4 + th / 2, 0)) * CFrame.Angles(0, rad(45), rad(-sg * 6)), WHITE)
				B:block(R, v(0.36, 0.4, 0.36), CFrame.new(p + v(-sg * 0.22, 1.45 + th + 0.12, 0)) * CFrame.Angles(0, rad(45), 0), BONE_LT)
			end
		end
		jawSide(1)
		jawSide(-1)
		-- chin: low bone step you walk over
		B:block(R, v(8.6, 0.55, 1.6), cf(0, 0.28, ZF - 0.9), BONE_DK)
		B:block(R, v(7.8, 0.2, 1.3), cf(0, 0.62, ZF - 0.9), BONE)
		-- tongue path into the mouth
		B:block(R, v(4.6, 0.18, 10.2), cf(0, 0.45, ZF + 5.2), TONGUE_DK)
		B:block(R, v(3.8, 0.18, 9.8), cf(0, 0.55, ZF + 5.1), TONGUE)
		B:block(R, v(3.0, 0.18, 1.2), cf(0, 0.55, ZF - 0.2), TONGUE)
		B:block(R, v(0.35, 0.1, 8.0), cf(0, 0.66, ZF + 4.8), TONGUE_DK)

		------------------------------------------------------------------
		-- SIDE WALLS (cheeks / jaw hinges) framing the tunnel
		------------------------------------------------------------------
		for sg = -1, 1, 2 do
			local xin, xout = GW, 7.0
			local xm, xw = sg * (xin + xout) / 2, xout - xin
			local zl, zh = ZC - 0.6, ZB
			local zm, zd = (zl + zh) / 2, zh - zl
			B:block(R, v(xw, GH + 1, zd), cf(xm, (GH + 1) / 2, zm), BONE)
			B:block(R, v(xw + 0.3, 1.4, zd + 0.3), cf(xm, 0.7, zm), BONE_DK)
			B:block(R, v(xw + 0.2, 2.2, zd - 1.6), cf(xm + sg * 0.1, 3.0, zm), BONE_LT)
			-- jaw hinge knob at the front corner
			B:block(R, v(xw + 0.6, 2.2, 2.0), cf(xm + sg * 0.2, 1.8, zl + 0.2), BONE_DK)
			B:block(R, v(xw + 0.2, 1.4, 1.4), cf(xm + sg * 0.35, 2.4, zl - 0.2), BONE_SH)
			-- dark inner lining of the tunnel
			B:block(R, v(0.12, GH - 0.2, zd + 0.4), cf(sg * (xin - 0.04), (GH - 0.2) / 2 + 0.05, zm), MOUTH)
			-- outer side opening (fenestra) with a bone frame
			local fx = sg * (xout + 0.02)
			B:block(R, v(0.14, 2.4, 3.2), cf(fx, 5.3, zm + 0.6), SOCK)
			B:block(R, v(0.5, 0.55, 4.0), cf(fx + sg * 0.15, 6.75, zm + 0.6), BONE_LT)
			B:block(R, v(0.5, 0.55, 3.6), cf(fx + sg * 0.15, 3.85, zm + 0.6), BONE)
			B:block(R, v(0.5, 2.6, 0.55), cf(fx + sg * 0.15, 5.3, zm + 2.45), BONE_LT)
			B:block(R, v(0.5, 2.6, 0.55), cf(fx + sg * 0.15, 5.3, zm - 1.25), BONE)
		end

		------------------------------------------------------------------
		-- UPPER JAW / SNOUT canopy
		------------------------------------------------------------------
		local SB = GH -- underside
		-- underside lip that carries the upper teeth
		B:block(R, v(10.2, 0.9, ZC - ZF + 0.4), cf(0, SB + 0.45, (ZF + ZC) / 2 + 0.1), BONE_DK)
		-- the snout steps up toward the eyes in three segments
		local segs = {
			{ ZF, ZF + 2.7, 10.5, 8.6 },
			{ ZF + 2.6, ZF + 5.2, 11.1, 9.4 },
			{ ZF + 5.1, ZC + 0.3, 11.7, 10.2 },
		}
		for i, g in segs do
			local zm, zd = (g[1] + g[2]) / 2, g[2] - g[1]
			local top = g[3]
			B:block(R, v(g[4], top - SB - 0.5, zd), cf(0, (SB + 0.5 + top) / 2 - 0.25, zm), BONE)
			B:block(R, v(g[4] - 1.2, 0.6, zd - 0.1), cf(0, top - 0.05, zm), (i == 2) and BONE or BONE_LT)
			B:block(R, v(g[4] + 0.3, 1.2, zd - 0.6), cf(0, SB + 1.4, zm), BONE_DK)
		end
		-- rounded snout tip
		B:block(R, v(7.4, 1.8, 0.6), cf(0, SB + 1.3, ZF - 0.2), BONE_LT)
		B:block(R, v(5.4, 0.9, 0.5), cf(0, SB + 2.25, ZF - 0.05), BONE)
		-- nostrils
		for sg = -1, 1, 2 do
			B:block(R, v(1.2, 0.2, 0.9), cf(sg * 1.5, 10.8, ZF + 1.1, 0, sg * 15, 0), SOCK)
			B:block(R, v(1.6, 0.36, 0.45), cf(sg * 1.5, 10.85, ZF + 0.45, 0, sg * 15, 0), BONE_LT)
		end
		-- mouth roof (dark) over the tunnel
		B:block(R, v(GW * 2 + 2.4, 0.12, ZB - ZF - 0.4), cf(0, SB - 0.06, (ZF + ZB) / 2 + 0.2), MOUTH)
		-- upper teeth: fringe hanging from the front and sides of the snout
		for i = -3, 3 do
			local x = i * 1.2
			local th = (math.abs(i) == 3) and 1.6 or 1.15
			B:block(R, v(0.62, th, 0.62), cf(x, SB - th / 2, ZF + 0.4, 0, 45, 0), WHITE)
			B:block(R, v(0.34, 0.35, 0.34), cf(x, SB - th - 0.12, ZF + 0.4, 0, 45, 0), BONE_LT)
		end
		for sg = -1, 1, 2 do
			for i = 0, 4 do
				local z = ZF + 1.6 + i * 1.3
				local th = 1.8 - i * 0.12
				B:block(R, v(0.66, th, 0.66), cf(sg * 4.55, SB - th / 2, z, 0, 45, 0), WHITE)
				B:block(R, v(0.36, 0.4, 0.36), cf(sg * 4.55, SB - th - 0.15, z, 0, 45, 0), BONE_LT)
			end
		end
		-- crack + stain on the snout
		B:bar(R, v(2.4, 11.52, ZF + 2.4), v(3.2, 11.52, ZF + 3.6), 0.16, 0.12, BONE_SH)
		B:bar(R, v(3.2, 11.52, ZF + 3.6), v(2.9, 11.52, ZF + 4.3), 0.16, 0.12, BONE_SH)
		B:block(R, v(1.6, 0.12, 1.2), cf(-2.4, 11.52, ZF + 3.4, 0, 15, 0), STAIN)

		------------------------------------------------------------------
		-- CRANIUM (the tunnel runs underneath it)
		------------------------------------------------------------------
		local CB = GH -- bottom of the cranium
		-- stepped layers: wide cheeks at the bottom, tapering to a crest; the
		-- back of the skull steps down so it reads as a long low T-rex head
		local layers = {
			{ CB, 11.6, 14.2, ZC - 0.2, ZB + 0.6, BONE_DK },
			{ 11.4, 14.6, 13.2, ZC, ZB + 0.2, BONE },
			{ 14.4, 16.2, 11.6, ZC + 0.1, ZB - 0.6, BONE },
			{ 16.0, 17.2, 9.4, ZC + 0.5, ZB - 1.8, BONE_LT },
			{ 17.0, 17.8, 5.0, ZC + 1.2, ZB - 3.0, BONE_LT },
		}
		for _, l in layers do
			local h, zm, zd = l[2] - l[1], (l[4] + l[5]) / 2, l[5] - l[4]
			B:block(R, v(l[3], h, zd), cf(0, (l[1] + l[2]) / 2, zm), l[6])
			-- chamfer block: a bit narrower, a bit longer -> rounded corners
			B:block(R, v(l[3] - 1.2, h - 0.04, zd + 0.7), cf(0, (l[1] + l[2]) / 2, zm), l[6])
		end
		local CT = 16.2
		-- occipital bulge at the back + condyle knob over the arch
		B:block(R, v(9.0, 4.0, 1.0), cf(0, 11.6, ZB + 1.0), BONE_DK)
		B:block(R, v(6.0, 2.0, 0.8), cf(0, 14.4, ZB + 0.4), BONE)
		-- cheek horns (jugal) and a stepped bump behind each eye
		for sg = -1, 1, 2 do
			B:block(R, v(1.2, 2.0, 2.4), cf(sg * 7.4, 10.2, ZC + 1.6), BONE_LT)
			B:block(R, v(1.0, 1.0, 1.2), cf(sg * 8.1, 9.6, ZC + 1.4, 0, 0, sg * 20), BONE)
			B:block(R, v(0.8, 2.6, 2.6), cf(sg * 6.7, 13.2, ZC + 1.7), BONE_LT)
			-- upper side opening
			B:block(R, v(0.14, 1.8, 2.4), cf(sg * 6.62, 13.0, ZC + 4.8), SOCK)
			B:block(R, v(0.45, 0.5, 3.2), cf(sg * 6.7, 14.1, ZC + 4.8), BONE_LT)
			B:block(R, v(0.45, 0.5, 3.0), cf(sg * 6.7, 11.9, ZC + 4.8), BONE)
			-- little horn bumps above the brows
			B:block(R, v(1.4, 1.0, 1.4), cf(sg * 4.4, CT + 0.6, ZC + 0.9, 0, 0, sg * -12), BONE_LT)
			B:block(R, v(0.9, 0.8, 0.9), cf(sg * 4.8, CT + 1.35, ZC + 1.0, 0, 0, sg * -25), BONE)
		end

		-- big round eye sockets with teal glow crystals
		local sockets = {}
		local FZ = ZC
		for sg = -1, 1, 2 do
			local x, y = sg * 3.3, 13.7
			B:block(R, v(3.2, 3.2, 0.3), cf(x, y, FZ - 0.1), SOCK)
			B:block(R, v(3.2, 0.8, 0.9), cf(x, y + 1.95, FZ - 0.35), BONE_LT)
			B:block(R, v(3.2, 0.8, 0.9), cf(x, y - 1.95, FZ - 0.35), BONE)
			B:block(R, v(0.8, 3.2, 0.9), cf(x + 1.95, y, FZ - 0.35), BONE)
			B:block(R, v(0.8, 3.2, 0.9), cf(x - 1.95, y, FZ - 0.35), BONE_LT)
			for cx = -1, 1, 2 do
				for cy = -1, 1, 2 do
					B:block(R, v(0.8, 0.8, 0.9), cf(x + cx * 1.3, y + cy * 1.3, FZ - 0.38), BONE)
				end
			end
			local g = B:block(R, v(1.2, 1.2, 0.3), cf(x - sg * 0.15, y - 0.15, FZ - 0.25, 0, 0, 45), TEAL, { mat = "Neon", name = "SocketGlow" })
			B:block(R, v(0.45, 0.45, 0.3), cf(x + sg * 0.7, y + 0.7, FZ - 0.3), TEAL_LT, { mat = "Neon", name = "SocketGlow" })
			B:block(R, v(0.7, 0.4, 0.3), cf(x - sg * 0.75, y - 0.95, FZ - 0.2, 0, 0, 30), TEAL_DK)
			-- heavy brow ridge, outer end dipping a touch (friendly, not angry)
			B:block(R, v(4.4, 1.0, 1.8), cf(x + sg * 0.2, y + 2.6, FZ - 0.25, 0, 0, sg * -5), BONE)
			B:block(R, v(3.6, 0.5, 1.4), cf(x + sg * 0.1, y + 3.2, FZ - 0.05, 0, 0, sg * -5), BONE_LT)
			table.insert(sockets, g)
		end
		-- bridge between the sockets + snout base
		B:block(R, v(1.1, 4.0, 0.6), cf(0, 13.5, FZ - 0.25), BONE)
		B:block(R, v(9.0, 0.9, 0.7), cf(0, 10.6, FZ - 0.3), BONE_DK)
		-- cracks + stains on the cranium
		B:bar(R, v(-2.4, 16.24, ZC + 3.4), v(-3.6, 16.24, ZC + 4.6), 0.2, 0.12, BONE_SH)
		B:bar(R, v(-3.6, 16.24, ZC + 4.6), v(-3.4, 16.24, ZC + 5.6), 0.2, 0.12, BONE_SH)
		B:block(R, v(0.12, 1.4, 1.6), cf(7.12, 9.4, ZC + 4.6), STAIN)
		B:block(R, v(2.0, 1.2, 0.12), cf(-3.4, 12.4, ZB + 0.86), STAIN)

		------------------------------------------------------------------
		-- BACK ARCH + trailing neck vertebrae
		------------------------------------------------------------------
		local AZ = ZB + 0.95
		for sg = -1, 1, 2 do
			B:block(R, v(1.0, GH + 0.6, 1.2), cf(sg * (GW + 0.4), (GH + 0.6) / 2, AZ), BONE_LT)
		end
		B:block(R, v(GW * 2 + 1.8, 1.0, 1.2), cf(0, GH + 0.5, AZ), BONE_LT)
		B:block(R, v(2.4, 1.4, 1.0), cf(0, GH + 1.6, AZ + 0.2), BONE)
		for sg = -1, 1, 2 do
			B:block(R, v(1.0, 1.0, 1.0), cf(sg * 1.0, GH + 1.3, AZ + 0.7), BONE_DK)
		end
		local function vert(c, yaw, s)
			local F = CFrame.new(c) * CFrame.Angles(0, rad(yaw), 0) * CFrame.Angles(rad(-18), 0, 0)
			B:block(R, v(2.0 * s, 1.4 * s, 1.6 * s), F * CFrame.new(0, 0.7 * s, 0), BONE)
			B:block(R, v(2.2 * s, 0.4 * s, 1.8 * s), F * CFrame.new(0, 0.2 * s, 0), BONE_DK)
			B:block(R, v(0.7 * s, 1.0 * s, 0.9 * s), F * CFrame.new(0, 1.7 * s, 0.2 * s), BONE_LT)
			B:block(R, v(4.0 * s, 0.5 * s, 0.6 * s), F * CFrame.new(0, 1.0 * s, 0), BONE_LT)
		end
		vert(v(-0.4, 0.2, ZB + 3.2), 8, 1.1)
		vert(v(-1.9, 0.2, ZB + 5.6), 25, 0.95)
		vert(v(-4.0, 0.2, ZB + 7.4), 45, 0.8)

		------------------------------------------------------------------
		-- DEAD TWISTED TREE (right side)
		------------------------------------------------------------------
		local TX, TZ = 9.8, 1.8
		local trunk = {
			v(TX, 0.2, TZ), v(TX - 0.5, 2.6, TZ - 0.4), v(TX + 0.5, 5.0, TZ + 0.3),
			v(TX - 0.2, 7.6, TZ - 0.3), v(TX + 0.4, 10.0, TZ + 0.4), v(TX - 0.3, 12.2, TZ), v(TX + 0.1, 13.6, TZ - 0.2),
		}
		for i = 1, #trunk - 1 do
			local d = (trunk[i + 1] - trunk[i]).Unit
			local w = 1.9 - i * 0.24
			B:bar(R, trunk[i] - d * 0.3, trunk[i + 1] + d * 0.3, w, w, (i % 2 == 0) and WOOD or WOOD_DK)
			-- bark ridge twisting around the trunk
			local a = rad(i * 75)
			local o = v(math.cos(a), 0, math.sin(a)) * (w * 0.42)
			B:bar(R, trunk[i] + o, trunk[i + 1] + o * 0.8, w * 0.35, w * 0.35, WOOD_LT)
		end
		-- gnarled roots
		for _, rt in { { 0, 2.2 }, { 80, 2.0 }, { 160, 2.4 }, { 250, 2.1 }, { 320, 1.8 } } do
			local a = rad(rt[1])
			local d = v(math.sin(a), 0, -math.cos(a))
			local p1 = v(TX, 1.2, TZ) + d * 0.5
			local p2 = v(TX, 0.5, TZ) + d * rt[2]
			local p3 = v(TX, 0.25, TZ) + d * (rt[2] + 1.0) + d:Cross(v(0, 1, 0)) * 0.4
			B:bar(R, p1, p2, 0.8, 0.7, WOOD_DK)
			B:bar(R, p2, p3, 0.5, 0.45, WOOD)
		end
		-- bare branches with thorny twigs
		local function branch(from, pts, w0)
			local prev = from
			for i, p in pts do
				local w = w0 * (1 - (i - 1) / (#pts + 0.5))
				local d = (p - prev).Unit
				B:bar(R, prev - d * 0.15, p + d * 0.1, w, w, (i % 2 == 0) and WOOD_DK or WOOD)
				-- a thorn on each segment
				local side = d:Cross(v(0, 1, 0))
				if side.Magnitude > 0.1 then
					local m = (prev + p) / 2
					B:bar(R, m, m + side.Unit * ((i % 2 == 0) and 0.5 or -0.5) + v(0, 0.25, 0), 0.16, 0.16, THORN)
				end
				prev = p
			end
			return prev
		end
		branch(trunk[3], { v(TX + 2.0, 6.4, TZ - 0.4), v(TX + 3.2, 7.8, TZ - 0.2), v(TX + 3.6, 9.2, TZ + 0.3) }, 0.75)
		branch(trunk[4], { v(TX - 1.8, 9.0, TZ - 0.8), v(TX - 3.0, 10.6, TZ - 1.0), v(TX - 3.4, 12.0, TZ - 0.6) }, 0.7)
		branch(trunk[5], { v(TX + 1.8, 11.2, TZ + 1.0), v(TX + 2.4, 12.8, TZ + 1.8) }, 0.6)
		branch(trunk[6], { v(TX - 1.4, 13.6, TZ + 0.6), v(TX - 2.6, 14.4, TZ + 0.4), v(TX - 3.6, 14.1, TZ + 0.2) }, 0.5)
		branch(trunk[7], { v(TX + 0.8, 15.0, TZ - 0.4), v(TX + 0.5, 16.2, TZ - 0.9) }, 0.45)
		branch(trunk[2], { v(TX + 1.6, 3.6, TZ + 1.2), v(TX + 2.4, 4.6, TZ + 1.8) }, 0.5)
		-- a hollow knot in the trunk
		B:block(R, v(0.7, 0.9, 0.3), CFrame.new(trunk[3] + v(0, 0.6, -0.85)), SOCK)

		------------------------------------------------------------------
		-- BRAMBLE climbing the left cheek
		------------------------------------------------------------------
		local bp = {
			v(-7.0, 0.3, -1.6), v(-7.0, 2.6, -1.2), v(-7.0, 4.4, -2.2), v(-7.2, 6.6, -1.6),
			v(-7.4, 8.6, -2.1), v(-7.6, 10.6, -1.4), v(-7.3, 12.2, -2.0),
		}
		for i = 1, #bp - 1 do
			local d = (bp[i + 1] - bp[i]).Unit
			local w = 0.55 - i * 0.05
			B:bar(R, bp[i] - d * 0.1, bp[i + 1] + d * 0.1, w, w, (i % 2 == 0) and STEM or STEM_DK)
			local m = (bp[i] + bp[i + 1]) / 2
			local sd = (i % 2 == 0) and 1 or -1
			B:bar(R, m, m + v(-0.45, 0.2, sd * 0.45), 0.2, 0.2, THORN)
		end
		local bt = bp[#bp]
		B:bar(R, bt, bt + v(-0.3, 0.8, -0.5), 0.26, 0.26, STEM)
		B:bar(R, bt + v(-0.3, 0.8, -0.5), bt + v(-0.4, 0.5, -1.1), 0.22, 0.22, STEM_DK)
		local function leaf(p, dir, s, col)
			dir = v(dir.X, 0, dir.Z).Unit
			local c = p + dir * 0.7 * s + v(0, 0.1, 0)
			local o = CFrame.lookAt(c, c + dir) * CFrame.Angles(rad(20), 0, 0)
			B:block(R, v(0.9 * s, 0.2, 1.2 * s), o, col)
			B:block(R, v(0.55 * s, 0.2, 1.6 * s), o * CFrame.new(0, 0.03, -0.1 * s), col)
			B:block(R, v(0.12, 0.24, 1.2 * s), o * CFrame.new(0, 0.06, 0), LEAF_DK)
		end
		leaf(bp[2], v(-1, 0, -0.6), 1.2, LEAF)
		leaf(bp[4], v(-1, 0, 0.5), 1.1, LEAF_LT)
		leaf(bp[6], v(-1, 0, -0.4), 1.0, LEAF)
		for _, b in { bp[3] + v(-0.5, -0.3, 0.4), bp[5] + v(-0.5, -0.4, -0.4) } do
			B:block(R, v(0.5, 0.5, 0.5), CFrame.new(b), BERRY)
			B:block(R, v(0.35, 0.35, 0.35), CFrame.new(b + v(0, -0.25, 0.25)), BERRY_DK)
			B:block(R, v(0.32, 0.32, 0.32), CFrame.new(b + v(0.05, -0.2, -0.3)), BERRY)
		end

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		for i, g in sockets do
			B:emitter(g, "sparkle", { name = "SocketWisps" .. i, color = { TEAL_LT, TEAL, "#5fd8ff" }, rate = 2.5, size = { 0.2, 0.45, 0 }, life = { 1.4, 2.4 }, speed = { 0.3, 0.7 }, spread = 25, accel = { 0, 1.0, 0 } })
		end
		B:light(sockets[1], { name = "SocketLight", color = "#4fe8d4", brightness = 1.0, range = 12 })
		B:emitter(vent, "ember", { name = "VentEmbers", color = { "#ffe27a", "#ff8a24", "#e8401f" }, rate = 4, size = { 0.22, 0.14, 0 }, speed = { 1.0, 2.0 }, life = { 1.4, 2.4 }, spread = 25, accel = { 0, 0.8, 0 } })
		B:emitter(vent, "smoke", { name = "VentSmoke", color = { "#5a5254", "#8a8280" }, rate = 1.2, size = { 0.6, 1.4, 2.0 }, speed = { 0.8, 1.4 }, life = { 1.8, 2.8 }, spread = 12, accel = { 0.2, 0.5, 0 } })
		B:light(vent, { name = "LavaLight", color = "#ff8a3a", brightness = 1.2, range = 14 })
		local cz = B:block(soil, v(10, 0.4, 2), cf(0, 0.5, -11.4), LAVA, { tr = 1, name = "CrackFx" })
		B:emitter(cz, "ember", { name = "CrackEmbers", color = { "#ffd26a", "#ff7a1a" }, rate = 3, size = { 0.18, 0.12, 0 }, speed = { 0.4, 1.0 }, life = { 1.2, 2.0 }, spread = 40, accel = { 0, 0.8, 0 } })
	end,
}
