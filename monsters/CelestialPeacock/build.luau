--!nocheck
-- Celestial Peacock: a holy white-and-gold bird whose tail is a living sunburst.
return {
	DisplayName = "Celestial Peacock",
	Rarity = "Divine",
	Element = "Holy",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local WHITE, PEARL, GOLD, DGOLD, GLOW = "#f6f3ec", "#e4ded2", "#f5b62e", "#c9821c", "#fff1a0"

		------------------------------------------------------------------
		-- Body
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 10, 0.5))
		B:ellipsoid(body, v(7.2, 8.4, 9), cf(0, 10.4, 0.6), WHITE)
		-- chunky studded plates layered on the torso
		B:block(body, v(5.6, 5.4, 7), cf(0, 10.2, 0.8), WHITE)
		B:block(body, v(4.6, 3, 5.6), cf(0, 13, 0.4, 0, 0, 0), PEARL)
		B:wedge(body, v(5.6, 2.6, 3), cf(0, 7.4, -2.2, 180, 0, 0), WHITE)
		-- gold chest shield (V shape) + glowing diamond
		B:tri(body, v(-2.6, 13.4, -3.65), v(2.6, 13.4, -3.65), v(0, 7.2, -3.65), 0.8, GOLD)
		B:tri(body, v(-1.8, 12.6, -4.0), v(1.8, 12.6, -4.0), v(0, 8.3, -4.0), 0.4, WHITE, { studs = false, mat = "SmoothPlastic" })
		local chestGem = B:gem(body, v(1.5, 1.5, 0.6), cf(0, 10.2, -4.3, 0, 0, 45), GLOW, { name = "ChestGem", brightness = 3, range = 14 })
		B:block(body, v(2.3, 2.3, 0.4), cf(0, 10.2, -4.05, 0, 0, 45), GOLD)
		B:emitter(chestGem, "sparkle", { color = GLOW, rate = 8 })
		B:emitter(chestGem, "burst", { name = "DisplayBurst", color = { GLOW, "#ffffff" }, speed = { 14, 28 }, size = { 1.8, 1.2, 0 } })
		-- side feather plates
		B:sym(function(side)
			for i = 0, 2 do
				local y = 12.2 - i * 1.9
				B:wedge(body, v(0.8, 1.8, 3.4), cf(3.4, y, 1.2 + i * 0.4, 0, 0, -8) * ang(180, 0, 0), i % 2 == 0 and WHITE or PEARL)
				B:block(body, v(0.5, 0.9, 1.4), cf(3.75, y - 0.2, -0.2 + i * 0.4), GOLD)
			end
		end)

		------------------------------------------------------------------
		-- Legs (gold, bird-jointed)
		------------------------------------------------------------------
		B:sym(function(side)
			local hip = B:bone("Thigh" .. side, "Body", v(1.8, 7.4, 0.8))
			B:ellipsoid(hip, v(2.2, 3.2, 2.6), cf(1.9, 6.8, 0.8), WHITE)
			B:beam(hip, v(1.9, 6.6, 0.9), v(1.9, 3.9, 1.6), 0.9, 0.9, GOLD)
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(1.9, 3.9, 1.6))
			B:ball(shin, 1.1, cf(1.9, 3.9, 1.6), DGOLD)
			B:beam(shin, v(1.9, 3.9, 1.6), v(1.9, 0.7, 0.6), 0.7, 0.7, GOLD)
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(1.9, 0.7, 0.6))
			B:ball(foot, 0.9, cf(1.9, 0.7, 0.6), DGOLD)
			for k = -1, 1 do
				local tip = v(1.9 + k * 1.1, 0.25, 0.6 - 2.2 + math.abs(k) * 0.5)
				B:beam(foot, v(1.9, 0.5, 0.6), tip, 0.45, 0.4, GOLD)
				B:spike(foot, tip, tip + v(k * 0.25, -0.15, -0.8), 0.35, 0.35, DGOLD)
			end
			B:beam(foot, v(1.9, 0.5, 0.6), v(1.9, 0.25, 1.9), 0.4, 0.35, GOLD)
		end)

		------------------------------------------------------------------
		-- Neck + head
		------------------------------------------------------------------
		local neck1 = B:bone("Neck1", "Body", v(0, 13.6, -1.6))
		B:ellipsoid(neck1, v(3.4, 3.6, 3.4), cf(0, 14.4, -1.9), WHITE)
		B:block(neck1, v(2.4, 2.6, 2.6), cf(0, 14.8, -2.1, -10, 0, 0), PEARL)
		B:tri(neck1, v(-1.2, 15.6, -3.25), v(1.2, 15.6, -3.25), v(0, 13.6, -3.4), 0.5, GOLD)
		local neck2 = B:bone("Neck2", "Neck1", v(0, 15.8, -2.3))
		B:ellipsoid(neck2, v(2.6, 3.4, 2.6), cf(0, 16.8, -2.6), WHITE)
		B:block(neck2, v(1.8, 2.4, 2), cf(0, 17, -2.7, -6, 0, 0), WHITE)
		local head = B:bone("Head", "Neck2", v(0, 18.3, -2.9))
		B:ellipsoid(head, v(2.9, 2.7, 3.4), cf(0, 19.1, -3.2), WHITE)
		B:block(head, v(2.3, 1.8, 2.6), cf(0, 19.4, -3.1), WHITE)
		B:block(head, v(1.6, 0.5, 1.8), cf(0, 20.35, -3.2), GOLD)
		-- beak: upper (wedge) + lower jaw bone
		B:wedge(head, v(1.2, 0.8, 2.2), cf(0, 19.05, -5.6) * ang(0, 0, 0), GOLD)
		B:block(head, v(1.3, 0.5, 0.8), cf(0, 18.75, -4.7), DGOLD)
		local beak = B:bone("Beak", "Head", v(0, 18.6, -4.4))
		B:wedge(beak, v(1.0, 0.45, 1.8), cf(0, 18.45, -5.4, 180, 0, 0), DGOLD)
		-- glowing eyes with gold brows
		B:sym(function(side)
			B:gem(head, v(0.55, 0.75, 0.4), cf(1.1, 19.45, -4.55, 0, 25, 0), "#fff7c2", { name = "Eye", light = false })
			B:block(head, v(0.9, 0.3, 0.9), cf(1.05, 20.0, -4.35, 0, 25, -12), GOLD)
		end)
		-- crest: three stalks with glowing orbs
		local crest = B:bone("Crest", "Head", v(0, 20.4, -3.2))
		for k = -1, 1 do
			local base = v(0, 20.4, -3.2)
			local tip = v(k * 1.5, 23.4 - math.abs(k) * 0.5, -2.6 + math.abs(k) * 0.3)
			B:beam(crest, base, tip, 0.22, 0.22, GOLD)
			local orb = B:ball(crest, 0.95, tip, GLOW, { mat = "Neon", name = "CrestOrb" })
			if k == 0 then
				B:light(orb, { color = GLOW, brightness = 2, range = 10 })
				B:emitter(orb, "sparkle", { color = GLOW, rate = 6 })
			end
		end

		-- halo floating above the head
		local halo = B:bone("Halo", "Head", v(0, 24.6, -3.0))
		B:ring(halo, cf(0, 24.6, -3.0, 8, 0, 0), 2.6, 18, v(1.0, 0.35, 0.35), GLOW, { mat = "Neon", name = "HaloSeg" })
		B:ring(halo, cf(0, 24.6, -3.0, 8, 0, 0), 2.6, 9, v(0.5, 0.55, 0.55), GOLD, { mat = "SmoothPlastic" })
		local haloCore = B:block(halo, v(0.2, 0.2, 0.2), cf(0, 24.6, -3.0), GLOW, { mat = "Neon", tr = 1, name = "HaloCore" })
		B:light(haloCore, { color = GLOW, brightness = 2.5, range = 16, name = "HaloLight" })
		B:emitter(haloCore, "glow", { color = GLOW, rate = 2, size = { 3, 5, 2 } })

		------------------------------------------------------------------
		-- Wings (folded against the body)
		------------------------------------------------------------------
		B:sym(function(side)
			local wing = B:bone("Wing" .. side, "Body", v(3.2, 12.6, -0.6))
			B:ellipsoid(wing, v(1.6, 3.2, 4.2), cf(3.6, 11.6, 0.4, 10, 0, -6), WHITE)
			for i = 0, 4 do
				local z0 = -0.8 + i * 1.1
				local len = 5.6 - i * 0.5
				B:tri(wing, v(3.9, 12.8, z0), v(3.9, 12.8, z0 + 1.7), v(4.3, 12.8 - len, z0 + 2.6), 0.4, i % 2 == 0 and WHITE or PEARL)
				B:tri(wing, v(4.15, 12.3 - len * 0.35, z0 + 0.6), v(4.15, 12.3 - len * 0.35, z0 + 1.9), v(4.4, 12.7 - len, z0 + 2.5), 0.3, GOLD)
			end
			B:trail(wing, v(4.3, 7.4, 3), v(4.3, 9.5, 2.4), { name = "WingTrail", color = GLOW, life = 0.3, trans = { 0.4, 1 } })
		end)

		------------------------------------------------------------------
		-- The sunburst tail fan: 13 big gold "eye" feathers behind 12 white ones
		------------------------------------------------------------------
		local tailBase = B:bone("TailBase", "Body", v(0, 9.6, 4.2))
		B:ellipsoid(tailBase, v(4.2, 3.6, 3.4), cf(0, 9.6, 4.6), WHITE)
		B:block(tailBase, v(3, 1.2, 2.4), cf(0, 8.6, 5.4), GOLD)

		local function feather(name, angleDeg, len, layer)
			-- pivot frame: local +Y runs along the feather, fan leans back 18deg (+Z).
			local pivot = CFrame.new(0, 9.8, 4.8 - layer * 0.9) * ang(18 - layer * 4, 0, angleDeg)
			local bone = B:bone(name, "TailBase", pivot)
			local function at(x, y, z, rz)
				return pivot * CFrame.new(x, y, z) * ang(0, 0, rz or 0)
			end
			local function pt(x, y, z)
				return (pivot * CFrame.new(x, y, z)).Position
			end
			if layer == 0 then
				-- long gold feather: shaft + leaf blade + glowing eye
				B:block(bone, v(0.45, len * 0.62, 0.4), at(0, len * 0.31, 0), WHITE)
				local w = 3.6
				local y0, y1, y2 = len * 0.42, len * 0.72, len
				B:poly(bone, { pt(0, y0, 0), pt(w / 2, y1, 0), pt(0, y2, 0), pt(-w / 2, y1, 0) }, 0.7, GOLD)
				B:poly(bone, { pt(0, y0 + 1.4, -0.3), pt(w / 2 - 0.6, y1, -0.3), pt(0, y2 - 1.2, -0.3), pt(-w / 2 + 0.6, y1, -0.3) }, 0.3, DGOLD, { mat = "SmoothPlastic" })
				-- stud "scale" squares like the reference
				B:block(bone, v(0.7, 0.7, 0.2), at(0.85, y1 - 1.0, -0.45, 45), GOLD)
				B:block(bone, v(0.7, 0.7, 0.2), at(-0.85, y1 - 1.0, -0.45, 45), GOLD)
				local eye = B:gem(bone, v(1.25, 1.25, 0.5), at(0, y1 + 0.2, -0.55, 45), GLOW, { name = "FeatherEye", light = false })
				B:block(bone, v(1.9, 1.9, 0.3), at(0, y1 + 0.2, -0.4, 45), WHITE, { mat = "SmoothPlastic" })
				if math.abs(angleDeg) < 1 or math.abs(math.abs(angleDeg) - 52) < 8 then
					B:light(eye, { color = GLOW, brightness = 1.6, range = 12 })
				end
				if math.abs(angleDeg) > 60 then
					B:emitter(eye, "sparkle", { color = GLOW, rate = 4 })
				end
				B:trail(bone, pt(0, y2 - 0.3, 0), pt(0, y2 - 2.5, 0), { name = "FeatherTrail", color = GLOW, life = 0.25, trans = { 0.5, 1 } })
			else
				-- inner white feather with gold edge
				B:block(bone, v(0.4, len * 0.5, 0.35), at(0, len * 0.25, 0), WHITE)
				local w = 2.4
				B:poly(bone, { pt(0, len * 0.3, 0), pt(w / 2, len * 0.68, 0), pt(0, len, 0), pt(-w / 2, len * 0.68, 0) }, 0.6, WHITE)
				B:poly(bone, { pt(0, len * 0.78, -0.35), pt(0.7, len * 0.88, -0.35), pt(0, len + 0.2, -0.35), pt(-0.7, len * 0.88, -0.35) }, 0.3, GOLD)
			end
		end

		local N = 13
		for i = 1, N do
			local a = -84 + (i - 1) * (168 / (N - 1))
			local len = 14.5 - math.abs(a) / 84 * 2.5
			feather("Fan" .. i, a, len, 0)
		end
		for i = 1, 12 do
			local a = -77 + (i - 1) * (154 / 11)
			local len = 9.5 - math.abs(a) / 77 * 1.5
			feather("Inner" .. i, a, len, 1)
		end
	end,
}
