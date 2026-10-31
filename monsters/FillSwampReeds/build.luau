--!nocheck
-- Cattail Reeds (Misty Swamp filler prop).
-- A small clump of swamp reeds: five leaning green stalks of different heights
-- with chunky brown cattail heads (pale fluff tips) and a few flat reed blades
-- fanning out low. One flat mud footing block, no mound. Built to be scattered
-- dozens of times along swamp banks: anchored, weld-free, no scripts.
return {
	DisplayName = "Cattail Reeds",
	Rarity = "Filler",
	Filler = true,
	Element = "Misty Swamp",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Misty Swamp, matches SwampReedBerry / SwampGlowcap)
		local MUD_DK, MUD = "#3b2a1e", "#4c3626"
		local REED, REED_DK, REED_LT = "#4c9a52", "#367a42", "#7dbb5e"
		local OLIVE = "#7a8a3e"
		local CAT, CAT_DK, CAT_LT, CAT_TIP = "#6a3f24", "#4f2d1a", "#875330", "#d9c99a"

		-- flat mud footing (two crossed slabs = rough octagon)
		B:block(R, v(2.6, 0.2, 1.7), cf(0, 0.1, 0, 0, 12, 0), MUD_DK)
		B:block(R, v(1.6, 0.24, 2.2), cf(0.1, 0.12, 0.05, 0, 12, 0), MUD)

		-- stalks: {base x, base z, height, lean x, lean z, head col}
		local stalks = {
			{ -0.1, 0.0, 5.6, 0.25, -0.2, CAT },
			{ 0.7, -0.35, 4.7, 0.9, -0.5, CAT_DK },
			{ -0.75, -0.25, 4.2, -0.95, -0.3, CAT_LT },
			{ 0.35, 0.55, 3.7, 0.6, 0.9, CAT },
			{ -0.5, 0.6, 3.1, -0.8, 0.85, CAT_DK },
		}
		for i, s in stalks do
			local base = v(s[1], 0.15, s[2])
			local top = v(s[1] + s[4], s[3], s[2] + s[5])
			local headC = CFrame.new(top) * (P.aim(base, top)).Rotation -- -Z along stalk
			B:bar(R, base, top, 0.24, 0.24, (i % 2 == 0) and REED_DK or REED)
			-- cattail head: two crossed brown blocks (stepped octagon), a dark
			-- collar underneath, then a thin pale spike above it
			B:block(R, v(0.62, 0.62, 1.5), headC * CFrame.new(0, 0, 0.25), s[6])
			B:block(R, v(0.5, 0.5, 1.6), headC * CFrame.new(0, 0, 0.22) * ang(0, 0, 45), (s[6] == CAT_DK) and CAT or CAT_DK)
			B:block(R, v(0.14, 0.14, 0.7), headC * CFrame.new(0, 0, -0.75), CAT_TIP)
		end

		-- flat reed blades fanning out low (no head)
		local blades = {
			{ 0.2, 0.2, 3.4, 1.5, -0.2, REED_LT },
			{ -0.3, -0.1, 2.8, -1.3, -0.9, REED },
			{ 0.4, -0.2, 2.5, 0.9, -1.3, REED },
			{ -0.2, 0.3, 2.2, -1.2, 1.2, OLIVE },
			{ 0.3, 0.4, 2.0, 1.3, 1.1, REED_DK },
		}
		for _, b in blades do
			local out = v(b[4], 0, b[5]).Unit -- blade's flat face looks outward
			B:bar(R, v(b[1], 0.15, b[2]), v(b[1] + b[4], b[3], b[2] + b[5]), 0.5, 0.1, b[6], { up = out })
		end
	end,
}
