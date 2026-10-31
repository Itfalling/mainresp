--!nocheck
-- Giant Honey Pot (Honey Hills decoration, medium, static).
-- A big clay honey pot lying tipped over on a little meadow pad, a glossy
-- honey puddle spilling out of its mouth, with a wooden honey dipper resting
-- in the honey against the pot.
-- * footing (bone "Soil", parts "Soil"): a thin stepped turf pad with a soil
--   rim, flat stones, grass tufts, daisies and clover
-- * the POT (bone "Pot"): built upright from stepped octagon discs in its own
--   frame, then tipped onto its belly so the lip also touches the grass:
--   foot, belly, a cream label band with honeycomb emblems, a rope-tied neck
--   and a fat lip; dark amber interior with honey pooling out
-- * the SPILL: a honey tongue over the lip into a wide stepped puddle with
--   lighter glossy highlights and a few stray drops
-- * the DIPPER: handle + ridged head dunked in the puddle, honey dripping
-- * one block bee perched on top of the pot
-- VFX: a slow honey drip from the upper lip, faint golden sparkles.
return {
	DisplayName = "Giant Honey Pot",
	Rarity = "Decor",
	Element = "Honey Hills",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local SQ3 = math.sqrt(3)

		-- palette (Honey Hills) ------------------------------------------
		local SOIL_DK, SOIL = "#6b4226", "#875533"
		local GR_DK, GR, GR_LT, GR_XL = "#7cae32", "#97c83e", "#b2d84c", "#d2e872"
		local CLOVER, CLOVER_DK = "#3f9a3c", "#2f7f30"
		local STONE, STONE_LT = "#a49a8c", "#c4bcae"
		local DAISY, DAISY_EYE = "#fffaf2", "#ffc93a"
		local FL_PINK = "#ff9cc4"
		local POT_DK, POT, POT_LT, LIP = "#a8522a", "#cf713a", "#e38c4c", "#f2a35e"
		local LABEL, LABEL_DK = "#ffdc78", "#e8a83a"
		local ROPE, ROPE_DK = "#e0bf7e", "#b8945a"
		local INSIDE = "#5c2e0c"
		local HONEY_DK, HONEY, HONEY_LT, HONEY_HI = "#e08a14", "#ffa318", "#ffc54a", "#fff0b8"
		local WAX, CELL = "#f5a623", "#a65a0c"
		local DIP, DIP_DK = "#c99a62", "#9f7444"
		local BEE_Y, BEE_K, WING = "#ffd23a", "#2a2126", "#f4fbff"

		local seed = 22201
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
		local function polar(r, deg)
			local a = rad(deg)
			return math.sin(a) * r, -math.cos(a) * r
		end

		------------------------------------------------------------------
		-- FOOTING: thin stepped turf pad (bone "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function pad(bone, c, r, h, col, opts)
			B:block(bone, v(2 * r, h, 1.15 * r), c, col, opts)
			B:block(bone, v(1.15 * r, h - 0.02, 2 * r), c, col, opts)
			B:block(bone, v(1.72 * r, h - 0.04, 1.72 * r), c, col, opts)
		end
		-- the pad is a little oval stretched along the pot -> puddle axis
		local YAW = 100 -- the pot's mouth points this way (deg, clockwise from -Z toward +X)
		local dx, dz = polar(1, YAW)
		local D = v(dx, 0, dz) -- horizontal mouth direction
		local PADF = CFrame.new(0, 0, 0) * CFrame.Angles(0, -rad(YAW), 0)
		-- the scatter below was laid out for a mouth at 35 deg; rotate it along
		local RL = CFrame.Angles(0, -rad(YAW - 35), 0)
		local function rpx(x, z)
			return (RL * v(x, 0, z)).X
		end
		local function rpz(x, z)
			return (RL * v(x, 0, z)).Z
		end
		-- soil rim + grass cap, two overlapping ovals
		for _, o in { { -2.4, 5.0 }, { 2.6, 5.4 } } do
			local c = PADF * CFrame.new(0, 0.25, -o[1])
			pad(soil, c, o[2], 0.5, SOIL_DK, S)
			pad(soil, c * CFrame.new(0, 0.2, 0), o[2] - 0.35, 0.3, GR_DK, S)
		end
		-- chunky sods around the rim
		for i = 0, 15 do
			local a = i / 16 * 360 + jit(6)
			local lx, lz = polar(1, a)
			local p = PADF * CFrame.new(lx * 5.4, 0, lz * 7.6 - 0.1)
			local h = 0.55 + rnd() * 0.25
			B:block(soil, v(1.8 + rnd() * 0.6, h, 1.3), CFrame.new(p.Position + v(0, h / 2, 0)) * CFrame.Angles(0, -rad(a + YAW), 0) * ang(0, jit(10), 0), pick({ GR, GR_DK, GR_LT }), S)
		end
		local TOP = 0.55
		-- flat stones
		for _, s in { { -4.6, -1.0, 1.4, STONE }, { -3.9, 2.8, 1.0, STONE_LT }, { 4.4, -2.6, 1.1, STONE_LT }, { 1.2, 5.8, 0.9, STONE } } do
			B:block(soil, v(s[3], 0.32, s[3] * 0.8), cf(rpx(s[1], s[2]), TOP + 0.1, rpz(s[1], s[2]), 0, jit(40), 0), s[4], S)
		end
		-- grass tufts
		for _, g0 in { { -5.2, 1.4 }, { -1.0, 5.0 }, { 5.3, 0.4 }, { -2.6, -4.6 }, { 3.6, 4.4 } } do
			local g = { rpx(g0[1], g0[2]), rpz(g0[1], g0[2]) }
			B:block(soil, v(0.35, 1.1, 0.35), cf(g[1], TOP + 0.5, g[2], 0, jit(30), -8), GR_LT, S)
			B:block(soil, v(0.3, 0.8, 0.3), cf(g[1] + 0.32, TOP + 0.38, g[2] + 0.2, 0, jit(30), 14), GR, S)
			B:block(soil, v(0.28, 0.9, 0.28), cf(g[1] - 0.3, TOP + 0.42, g[2] - 0.15, 10, jit(30), 0), GR_XL, S)
		end
		-- daisies (8 petals) and clover
		local function daisy(x, z, s, col)
			s = s or 1
			x, z = rpx(x, z), rpz(x, z)
			local y = TOP
			B:block(soil, v(0.18, 0.8 * s, 0.18), cf(x, y + 0.4 * s, z), GR_DK, S)
			local yaw = rnd() * 90
			local c = cf(x, y + 0.82 * s, z, 0, yaw, 0)
			B:block(soil, v(1.0 * s, 0.16, 0.34 * s), c, col or DAISY, S)
			B:block(soil, v(0.34 * s, 0.17, 1.0 * s), c, col or DAISY, S)
			B:block(soil, v(0.9 * s, 0.15, 0.3 * s), c * ang(0, 45, 0), col or DAISY, S)
			B:block(soil, v(0.3 * s, 0.155, 0.9 * s), c * ang(0, 45, 0), col or DAISY, S)
			B:block(soil, v(0.36 * s, 0.26, 0.36 * s), c * CFrame.new(0, 0.05, 0), DAISY_EYE, S)
		end
		local function clover(x, z)
			local yaw = rnd() * 120
			x, z = rpx(x, z), rpz(x, z)
			for k = 0, 2 do
				local c = cf(x, TOP + 0.3, z, 0, yaw + k * 120, 0) * CFrame.new(0, 0, -0.3)
				B:block(soil, v(0.5, 0.14, 0.5), c * ang(0, 45, 0), (k == 0) and CLOVER_DK or CLOVER, S)
			end
		end
		daisy(-4.4, 0.6, 1.1)
		daisy(-1.9, 4.6, 1.0)
		daisy(4.7, -0.8, 0.9)
		daisy(-3.0, -3.4, 1.0)
		daisy(2.6, 5.0, 0.9, FL_PINK)
		daisy(-5.0, -2.2, 0.8, FL_PINK)
		clover(-4.0, 2.0)
		clover(3.3, 3.6)
		clover(5.0, -2.0)
		clover(-1.0, -4.8)

		------------------------------------------------------------------
		-- THE POT (bone "Pot"): built upright along local +Y, then tipped
		------------------------------------------------------------------
		local pot = B:bone("Pot", "Root", v(0, 3, 0))
		-- layers: y0, y1, radius, colour
		local LAYERS = {
			{ 0.0, 0.6, 2.6, POT_DK },
			{ 0.5, 1.3, 3.3, POT },
			{ 1.2, 2.2, 3.9, POT },
			{ 2.1, 4.1, 4.35, POT },
			{ 4.0, 5.0, 3.9, POT },
			{ 4.9, 5.7, 3.2, POT },
			{ 5.6, 6.3, 2.4, POT_DK },
			{ 6.2, 7.2, 3.1, POT_LT },
			{ 6.45, 6.95, 3.35, LIP },
		}
		local YB = 3.1 -- local y of the belly centre
		local MOUTH = 7.2
		-- tilt so the belly and the lip both rest on the grass
		local tilt = math.deg(math.atan((4.35 - 3.35) / (6.7 - YB)))
		local ROT = CFrame.Angles(0, -rad(YAW), 0) * CFrame.Angles(rad(-90 - tilt), 0, 0)
		-- find the lowest corner of the bottom (local -Z) faces with the pot at the origin
		local low = math.huge
		for _, L in LAYERS do
			for _, yy in { L[1], L[2] } do
				for _, xx in { -0.575, 0.575 } do
					local p = ROT * v(xx * L[3], yy - YB, -L[3])
					low = math.min(low, p.Y)
				end
			end
		end
		local CEN = -D * 2.0 + v(0, TOP + 0.05 - low, 0)
		local F = CFrame.new(CEN) * ROT -- pot frame, origin = belly centre
		local function at(x, y, z)
			return F * CFrame.new(x, y - YB, z)
		end
		for _, L in LAYERS do
			pad(pot, at(0, (L[1] + L[2]) / 2, 0), L[3], L[2] - L[1], L[4])
		end
		-- labels on the belly
		-- honeycomb emblems on the label (top, both sides): three hex cells
		local function hexFlat(c, R, col)
			for k = 0, 2 do
				B:block(pot, v(R, 0.12, R * SQ3), c * CFrame.Angles(0, rad(k * 60), 0), col)
			end
		end
		for _, face in { 0, 90, -90 } do
			-- face frame: local +Y = outward normal (pot local +Z rotated about the pot axis)
			local Fc = at(0, YB, 0) * CFrame.Angles(0, rad(face), 0) * CFrame.new(0, 0, 4.35) * CFrame.Angles(rad(90), 0, 0)
			B:block(pot, v(3.8, 0.1, 3.0), Fc * CFrame.new(0, 0.03, 0), LABEL_DK)
			B:block(pot, v(3.4, 0.1, 2.6), Fc * CFrame.new(0, 0.09, 0), LABEL)
			Fc = Fc * CFrame.new(0, 0.1, 0)
			for k, o in { { 0, -0.55, WAX }, { -0.62, 0.0, WAX }, { 0.62, 0.0, WAX } } do
				local c = Fc * CFrame.new(o[2] * 1.1, 0.06, o[1] * 1.1 - 0.1) * CFrame.Angles(0, rad(30), 0)
				hexFlat(c, 0.62, o[3])
				hexFlat(c * CFrame.new(0, 0.05, 0), 0.32, (k == 1) and HONEY or CELL)
			end
		end
		-- rope tied round the neck with a bow knot on top
		pad(pot, at(0, 5.95, 0), 2.55, 0.4, ROPE)
		do
			local k = at(0, 5.95, 2.65)
			B:block(pot, v(0.6, 0.6, 0.5), k, ROPE_DK)
			B:block(pot, v(0.9, 0.35, 0.3), k * CFrame.new(0.55, 0, 0.1) * ang(0, 0, 25), ROPE)
			B:block(pot, v(0.9, 0.35, 0.3), k * CFrame.new(-0.55, 0, 0.1) * ang(0, 0, -25), ROPE)
			B:block(pot, v(0.25, 1.0, 0.25), k * CFrame.new(0.3, 0.6, 0.15) * ang(0, 0, -15), ROPE_DK)
			B:block(pot, v(0.25, 0.9, 0.25), k * CFrame.new(-0.25, 0.55, 0.15) * ang(0, 0, 20), ROPE_DK)
		end
		-- the mouth: dark interior, honey pooling over the lower half
		pad(pot, at(0, MOUTH + 0.03, 0), 2.25, 0.1, INSIDE)
		B:block(pot, v(3.0, 0.14, 1.6), at(0, MOUTH + 0.06, -1.5), HONEY)
		B:block(pot, v(1.0, 0.16, 0.8), at(-0.6, MOUTH + 0.08, -1.2), HONEY_LT)
		-- honey oozing over the upper lip and dribbling down the mouth face
		B:block(pot, v(1.2, 0.5, 0.9), at(0.8, MOUTH - 0.05, 3.05), HONEY)
		B:block(pot, v(0.6, 0.55, 0.6), at(0.8, MOUTH + 0.12, 2.5), HONEY)
		local dripTop = CFrame.new(at(0.8, MOUTH + 0.3, 2.6).Position)
		B:block(pot, v(0.38, 1.2, 0.38), dripTop * CFrame.new(0, -0.5, 0), HONEY)
		-- honey drips down the shoulder on the top side
		B:block(pot, v(0.9, 0.9, 0.3), at(-1.4, 6.7, 3.4), HONEY)
		B:block(pot, v(0.5, 0.5, 0.3), at(-1.4, 6.05, 2.6), HONEY_LT)

		------------------------------------------------------------------
		-- THE SPILL: honey tongue over the lower lip + a wide puddle
		------------------------------------------------------------------
		local lipLow = (at(0, MOUTH - 0.2, -2.9)).Position
		local spillEnd = v(lipLow.X, TOP + 0.12, lipLow.Z) + D * 1.6
		local sideV = v(-D.Z, 0, D.X)
		B:bar(pot, (at(0, MOUTH + 0.05, -1.7)).Position, lipLow + D * 0.3 + v(0, -0.05, 0), 1.5, 0.45, HONEY)
		B:block(pot, v(2.6, 0.6, 1.1), at(0, MOUTH + 0.05, -3.05), HONEY)
		B:block(pot, v(1.3, 0.62, 0.7), at(-0.9, MOUTH + 0.25, -3.1), HONEY_LT)
		B:bar(pot, lipLow + D * 0.25, spillEnd, 1.7, 0.45, HONEY)
		B:bar(pot, lipLow + D * 0.25 + sideV * 0.8, spillEnd + sideV * 1.0 - D * 0.3, 1.0, 0.4, HONEY_DK)
		B:bar(pot, lipLow + D * 0.3 - sideV * 0.5 + v(0, 0.1, 0), spillEnd - sideV * 0.6 + v(0, 0.05, 0), 0.6, 0.5, HONEY_LT)
		local PC = CEN * v(1, 0, 1) + D * 6.6
		local PF = CFrame.new(PC.X, TOP + 0.08, PC.Z) * CFrame.Angles(0, -rad(YAW), 0)
		-- puddle blobs (local -Z = away from the pot)
		local blobs = {
			{ 0, 0, 4.6, 3.6, 0 },
			{ -0.6, 1.4, 3.6, 3.0, 25 },
			{ 1.6, -0.8, 3.0, 2.6, -20 },
			{ -1.9, -0.9, 2.6, 2.2, 40 },
			{ 0.4, -2.0, 3.0, 1.8, 10 },
			{ 0.9, 2.4, 2.4, 2.2, -10 },
		}
		for i, b in blobs do
			B:block(pot, v(b[3], 0.22 + i * 0.006, b[4]), PF * CFrame.new(b[1], 0, b[2]) * ang(0, b[5], 0), HONEY)
		end
		-- darker rim at the edges, lighter glossy top
		B:block(pot, v(5.0, 0.16, 2.2), PF * CFrame.new(0.2, -0.02, -1.4) * ang(0, 8, 0), HONEY_DK)
		B:block(pot, v(2.6, 0.26, 2.0), PF * CFrame.new(-0.3, 0.04, 0.4) * ang(0, 20, 0), HONEY_LT)
		B:block(pot, v(1.6, 0.27, 1.0), PF * CFrame.new(0.8, 0.05, -0.6) * ang(0, -15, 0), HONEY_LT)
		B:block(pot, v(0.5, 0.29, 0.5), PF * CFrame.new(-0.6, 0.07, 0.8) * ang(0, 40, 0), HONEY_HI)
		B:block(pot, v(0.35, 0.29, 0.35), PF * CFrame.new(1.1, 0.07, -0.8) * ang(0, 10, 0), HONEY_HI)
		-- stray drops around the puddle
		for _, d in { { 3.1, -1.6, 0.5 }, { -3.0, -1.9, 0.4 }, { 2.4, 2.4, 0.45 }, { -0.5, -3.4, 0.35 } } do
			B:block(pot, v(d[3], 0.24, d[3]), PF * CFrame.new(d[1], 0, d[2]) * ang(0, 45, 0), HONEY_LT)
		end
		-- a glinting drop at the lip (tiny neon accent)
		B:gem(pot, v(0.4, 0.4, 0.4), CFrame.new(lipLow + D * 0.45 + v(0.4, 0.3, 0)) * ang(0, 45, 0), "#ffb52e", { name = "HoneyGlint" })

		------------------------------------------------------------------
		-- HONEY DIPPER resting in the puddle, leaning on the pot
		------------------------------------------------------------------
		do
			local side = v(-D.Z, 0, D.X) -- to the right of the mouth direction
			local head = PC - D * 1.0 + side * 0.9 + v(0, TOP + 0.6, 0)
			local tipP = head + side * 3.2 + D * 1.4 + v(0, 0.6, 0)
			B:bar(pot, head, tipP, 0.4, 0.4, DIP)
			B:block(pot, v(0.62, 0.62, 0.62), CFrame.new(tipP) * ang(0, 30, 0), DIP_DK)
			local d = (tipP - head).Unit
			local ac = P.aim(head, tipP)
			local hc = CFrame.new(head) * (ac - ac.Position) * CFrame.Angles(math.pi / 2, 0, 0) -- local +Y along the handle
			for k = 0, 3 do
				local r = (k == 1 or k == 2) and 1.3 or 1.0
				B:block(pot, v(r, 0.28, r), hc * CFrame.new(0, -0.45 + k * 0.38, 0) * ang(0, k * 30, 0), (k % 2 == 1) and DIP_DK or DIP)
			end
			B:block(pot, v(0.9, 1.5, 0.9), hc * CFrame.new(0, 0.05, 0) * ang(0, 45, 0), HONEY_LT)
			-- honey dripping off the head into the puddle
			B:block(pot, v(0.35, 0.6, 0.35), CFrame.new(head + v(0.1, -0.45, 0)), HONEY)
			local _ = d
		end

		------------------------------------------------------------------
		-- a little bee perched on top of the pot
		------------------------------------------------------------------
		do
			local top = at(-1.6, 4.4, 4.75).Position
			local Fb = CFrame.new(top + v(0, 0.35, 0)) * CFrame.Angles(0, rad(-YAW - 70), 0)
			B:block(pot, v(0.95, 0.9, 1.3), Fb, BEE_Y)
			B:block(pot, v(0.99, 0.94, 0.26), Fb * CFrame.new(0, 0, 0.05), BEE_K)
			B:block(pot, v(0.99, 0.94, 0.22), Fb * CFrame.new(0, 0, 0.5), BEE_K)
			B:block(pot, v(0.8, 0.78, 0.5), Fb * CFrame.new(0, 0.02, -0.82), BEE_K)
			B:block(pot, v(0.18, 0.18, 0.3), Fb * CFrame.new(0, -0.1, 0.78), BEE_K)
			B:block(pot, v(0.1, 0.5, 0.1), Fb * CFrame.new(0.2, 0.55, -1.0) * ang(-25, 0, -15), BEE_K)
			B:block(pot, v(0.1, 0.5, 0.1), Fb * CFrame.new(-0.2, 0.55, -1.0) * ang(-25, 0, 15), BEE_K)
			for sgn = -1, 1, 2 do
				B:block(pot, v(0.7, 0.08, 0.5), Fb * CFrame.new(sgn * 0.48, 0.6, -0.05) * ang(0, 0, sgn * 25), WING, { tr = 0.25 })
			end
		end

		------------------------------------------------------------------
		-- VFX
		------------------------------------------------------------------
		local dz = B:block(pot, v(0.3, 0.2, 0.3), dripTop * CFrame.new(0, -1.25, 0), HONEY, { tr = 1, name = "DripZone" })
		B:emitter(dz, "drip", { name = "HoneyDrip", color = { "#ffc23a", "#ff9a14" }, rate = 0.8, size = { 0.34, 0.3, 0.16 }, life = { 0.5, 0.75 } })
		local motes = B:block(pot, v(9, 5, 9), CFrame.new(CEN + D * 2 + v(0, 1.5, 0)), HONEY, { tr = 1, name = "SparkleZone" })
		B:emitter(motes, "sparkle", { name = "HoneySparkle", color = { "#ffe57a", "#fff6c8" }, rate = 2.5, size = { 0.12, 0.35, 0.05 }, life = { 1.2, 2.2 }, speed = { 0.1, 0.4 } })
	end,
}
