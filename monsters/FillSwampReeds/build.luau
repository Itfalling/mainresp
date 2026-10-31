--!nocheck
-- Cattail Reeds (Misty Swamp filler prop, v2).
-- A clump of swamp cattails in the SwampReedBerry style:
-- * six cattails at three heights on gently bent two-tone stalks; every head
--   is a rounded octagon (block + the same block turned 45 deg) in three
--   browns with a dark collar, a light cap and a two-step pale spike; one
--   young green-brown head for variety
-- * long two-segment reed blades fanning out and bending over, dark at the
--   base, lighter towards the tip
-- * a low flat footing: dark mud patch, moss pads and two little stones
-- Filler: anchored, weld-free, no scripts. Copy-paste it along swamp banks.
return {
	DisplayName = "Cattail Reeds",
	Rarity = "Filler",
	Filler = true,
	Element = "Misty Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Misty Swamp: SwampReedBerry / SwampGlowcap)
		local MUD_XD, MUD_DK, MUD = "#3b2a1e", "#4c3626", "#5e4430"
		local MOSS_DK, MOSS, MOSS_LT = "#3b7034", "#4f8f3e", "#6fae4c"
		local STONE_DK, STONE, STONE_LT = "#565f59", "#6f7a72", "#8c9893"
		local STALK_DK, STALK = "#3d7238", "#4f8f46"
		local REED_DK, REED, REED_LT = "#367a42", "#4c9a52", "#7dbb5e"
		local CAT_XD, CAT_DK, CAT, CAT_LT = "#3d2214", "#4f2d1a", "#6a3f24", "#875330"
		local TIP, TIP_LT = "#d9c99a", "#efe3bd"
		local YOUNG_DK, YOUNG, YOUNG_LT = "#5d6e30", "#7a8a3e", "#97a352"
		local WATER_DK, WATER, WATER_LT = "#24524f", "#2d6f6a", "#62a9a0"

		------------------------------------------------------------ footing
		local function oct(c, s, h, col)
			B:block(R, v(s, h, s), c, col)
			B:block(R, v(s * 0.8, h - 0.02, s * 0.8), c * ang(0, 45, 0), col)
		end
		oct(cf(0, 0.07, 0, 0, 10, 0), 3.1, 0.14, MUD_XD)
		oct(cf(-0.25, 0.1, 0.2, 0, 30, 0), 2.2, 0.2, MUD_DK)
		-- little murky puddle on the front-left
		oct(cf(-1.2, 0.09, -1.15, 0, 20, 0), 1.3, 0.18, WATER_DK)
		oct(cf(-1.2, 0.11, -1.15, 0, 20, 0), 1.05, 0.2, WATER)
		B:block(R, v(0.55, 0.22, 0.12), cf(-1.05, 0.11, -1.35, 0, 20, 0), WATER_LT)
		-- tiny lily pad with a notch floating in it
		B:block(R, v(0.6, 0.1, 0.6), cf(-1.4, 0.24, -1.0, 0, 30, 0), "#3f9a4c")
		B:block(R, v(0.48, 0.11, 0.48), cf(-1.4, 0.24, -1.0, 0, 75, 0), "#62b85a")
		B:block(R, v(0.16, 0.13, 0.3), cf(-1.4, 0.25, -1.0, 0, 30, 0) * CFrame.new(0, 0, -0.2), WATER)
		B:block(R, v(1.1, 0.22, 0.8), cf(0.75, 0.11, 0.6, 0, 25, 0), MUD)
		-- moss pads (main + highlight)
		B:block(R, v(1.2, 0.24, 0.9), cf(-0.95, 0.12, -0.55, 0, -20, 0), MOSS)
		B:block(R, v(0.7, 0.28, 0.55), cf(-1.0, 0.14, -0.6, 0, 10, 0), MOSS_LT)
		B:block(R, v(0.9, 0.22, 0.7), cf(0.95, 0.11, -0.75, 0, 35, 0), MOSS_DK)
		-- stones (body + lit cap)
		B:block(R, v(0.6, 0.38, 0.5), cf(1.25, 0.19, 0.15, 0, 20, 0), STONE)
		B:block(R, v(0.42, 0.1, 0.34), cf(1.22, 0.42, 0.13, 0, 20, 0), STONE_LT)
		B:block(R, v(0.42, 0.26, 0.38), cf(-1.2, 0.13, 0.75, 0, -15, 0), STONE_DK)

		------------------------------------------------------------ cattails
		local BROWN = { CAT, CAT_DK, CAT_LT }
		local BROWN2 = { CAT_DK, CAT_XD, CAT }
		local GREEN = { YOUNG, YOUNG_DK, YOUNG_LT }
		-- {x, z, height, lean x, lean z, head length, head width, tones}
		local cats = {
			{ -0.05, 0.05, 5.6, 0.2, -0.25, 1.6, 0.66, BROWN },
			{ 0.55, -0.3, 4.7, 0.85, -0.45, 1.45, 0.62, BROWN2 },
			{ -0.6, -0.2, 4.3, -0.9, -0.35, 1.4, 0.6, BROWN },
			{ 0.35, 0.5, 3.8, 0.65, 0.85, 1.3, 0.58, BROWN2 },
			{ -0.45, 0.55, 3.2, -0.8, 0.8, 1.2, 0.56, BROWN },
			{ 0.1, -0.55, 2.7, 0.15, -1.0, 0.9, 0.46, GREEN },
		}
		for i, c in cats do
			local b0 = v(c[1], 0.15, c[2])
			local m = v(c[1] + c[4] * 0.3, c[3] * 0.55, c[2] + c[5] * 0.3)
			local t = v(c[1] + c[4], c[3], c[2] + c[5])
			B:bar(R, b0, m, 0.26, 0.26, STALK_DK)
			B:bar(R, m - (m - b0).Unit * 0.12, t, 0.22, 0.22, STALK)
			local L, w, tone = c[6], c[7], c[8]
			local hc = CFrame.new(t) * P.aim(m, t).Rotation * CFrame.new(0, 0, -(L / 2 - 0.1))
			B:block(R, v(w, w, L), hc, tone[1])
			B:block(R, v(w * 0.82, w * 0.82, L - 0.12), hc * ang(0, 0, 45), tone[2])
			B:block(R, v(0.14, w * 0.5, L * 0.62), hc * CFrame.new(w * 0.5, 0.06, -0.05), tone[3]) -- lit streak
			B:block(R, v(w * 0.66, w * 0.66, 0.22), hc * CFrame.new(0, 0, L / 2 + 0.06), tone[2]) -- collar
			B:block(R, v(w * 0.66, w * 0.66, 0.2), hc * CFrame.new(0, 0, -L / 2 - 0.05) * ang(0, 0, 45), tone[3]) -- cap
			if tone ~= GREEN then
				B:block(R, v(0.18, 0.18, 0.5), hc * CFrame.new(0, 0, -L / 2 - 0.35), TIP)
				B:block(R, v(0.1, 0.1, 0.32), hc * CFrame.new(0, 0, -L / 2 - 0.74), TIP_LT)
			else
				B:block(R, v(0.12, 0.12, 0.35), hc * CFrame.new(0, 0, -L / 2 - 0.25), YOUNG_LT)
			end
		end

		------------------------------------------------------------ reed blades
		-- {yaw deg, height, reach, width, base col, tip col}
		local blades = {
			{ 15, 3.4, 1.5, 0.46, REED_DK, REED_LT },
			{ 75, 2.6, 1.6, 0.42, REED_DK, REED },
			{ 130, 3.0, 1.4, 0.44, REED, REED_LT },
			{ 190, 2.4, 1.5, 0.4, REED_DK, REED },
			{ 245, 3.2, 1.3, 0.46, REED, REED_LT },
			{ 300, 2.2, 1.6, 0.4, REED_DK, REED },
			{ 350, 2.0, 1.2, 0.38, REED, REED_LT },
		}
		for _, b in blades do
			local d = v(math.sin(rad(b[1])), 0, -math.cos(rad(b[1])))
			local p0 = d * 0.25 + v(0, 0.15, 0)
			local p1 = p0 + d * b[3] * 0.3 + v(0, b[2] * 0.62, 0)
			local p2 = p0 + d * b[3] + v(0, b[2], 0)
			local p3 = p2 + d * 0.4 + v(0, -0.1, 0) -- tip bending over
			B:bar(R, p0, p1, b[4] * 1.1, 0.12, b[5], { up = d })
			B:bar(R, p1, p2, b[4] * 0.92, 0.11, b[6], { up = d })
			B:bar(R, p2 - (p2 - p1).Unit * 0.12, p3, b[4] * 0.6, 0.1, b[6], { up = d })
		end
	end,
}
