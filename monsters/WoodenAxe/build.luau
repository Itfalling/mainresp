-- Wooden Axe: a common starter axe, shown standing on its pommel.
-- Handle runs up Y, the fan-shaped blade points +X. Static model (no motion).
return {
	DisplayName = "Wooden Axe",
	Rarity = "Common",
	Element = "Tool",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local HANDLE, RIVET = "#a8432a", "#6b2516"
		local BAND, CAP = "#bccbe2", "#5a2414"
		local HEAD, HEAD_D, HEAD_L, NOTCH = "#e57a2c", "#c9611c", "#f59a4c", "#8a3a10"
		local GEM, GEM_L = "#9fc4ef", "#e2f0ff"

		-- handle with rivet rows on the front and back faces
		B:block("Root", v(0.5, 5.3, 0.5), cf(0, 2.85, 0), HANDLE)
		for i = 0, 6 do
			local y = 0.9 + i * 0.5
			if math.abs(y - 2.65) > 0.3 then
				for _, z in { -0.26, 0.26 } do
					B:block("Root", v(0.14, 0.14, 0.06), cf(0, y, z), RIVET)
				end
			end
		end
		-- silver-blue bands: pommel, middle, under the head
		B:block("Root", v(0.66, 0.5, 0.66), cf(0, 0.25, 0), BAND)
		B:block("Root", v(0.62, 0.26, 0.62), cf(0, 2.65, 0), BAND)
		B:block("Root", v(0.62, 0.26, 0.62), cf(0, 4.45, 0), BAND)

		-- head socket with a diamond gem, back poll and top cap
		B:block("Root", v(1.05, 1.0, 0.8), cf(0.05, 5.05, 0), HEAD)
		B:block("Root", v(0.5, 0.75, 0.66), cf(-0.65, 5.05, 0), HEAD_D)
		B:block("Root", v(0.55, 0.22, 0.55), cf(0, 5.66, 0), CAP)
		for _, z in { -0.42, 0.42 } do
			B:block("Root", v(0.42, 0.42, 0.06), cf(0.05, 5.05, z) * ang(0, 0, 45), GEM)
			B:block("Root", v(0.18, 0.18, 0.08), cf(0.05, 5.05, z) * ang(0, 0, 45), GEM_L)
		end

		-- blade: a fan of chunky blocks arcing around the socket
		local cx, cy = 0.6, 5.05
		-- neck joining the socket to the blade, then a solid inner fill so the
		-- fan reads as one blade, not separate petals
		B:block("Root", v(1.0, 0.95, 0.56), cf(0.85, cy, 0), HEAD)
		for _, a in ipairs({ 38, 0, -38 }) do
			local r = math.rad(a)
			B:block("Root", v(0.9, 1.1, 0.52), cf(cx + 0.85 * math.cos(r), cy + 0.85 * math.sin(r), 0) * ang(0, 0, a), HEAD_D)
		end
		local angles = { 54, 27, 0, -27, -54 }
		for i, a in ipairs(angles) do
			local r = math.rad(a)
			local px, py = cx + 1.55 * math.cos(r), cy + 1.55 * math.sin(r)
			local base = cf(px, py, 0) * ang(0, 0, a)
			B:block("Root", v(1.0, 1.05, 0.6), base, i % 2 == 1 and HEAD or HEAD_D)
			B:block("Root", v(0.16, 0.9, 0.5), base * CFrame.new(0.55, 0, 0), HEAD_L)
			for _, z in { -0.31, 0.31 } do
				B:block("Root", v(0.16, 0.16, 0.05), base * CFrame.new(0.1, 0.18, z), NOTCH)
			end
		end
	end,
}
