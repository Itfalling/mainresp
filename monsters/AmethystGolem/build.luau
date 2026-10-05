--!nocheck
-- Amethyst Golem: hunched stud-built rock gorilla made of chunky slate boulders,
-- with stepped purple/lavender voxel crystal clusters (small neon tips only), a
-- glowing core gem, purple eye slits under a heavy brow, huge boulder fists and
-- floating rock/crystal cubes. Signature move: CRYSTAL QUAKE.
return {
	DisplayName = "Amethyst Golem",
	Rarity = "Epic",
	Element = "Crystal",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette
		local STONE, DARK, LIGHT = "#6b7286", "#4a5060", "#8d94a8"
		local PURPLE, LAV, PALE = "#8a4dff", "#c49bff", "#dccbff"
		local WHITE, MOUTH, TONGUE, PUPIL = "#f4f0ff", "#15121f", "#c8508e", "#1a0f2e"
		local NEON = "#b45cff"

		-- Voxel crystal: stacked square blocks turned 45deg (diamond facets) that taper
		-- from purple to pale lavender and end in a SMALL neon tip.
		-- base: model-space CFrame at the crystal's root, local +Y = growth direction.
		-- o.short = 2 blocks + tip (small crystals), o.tip = false for no neon.
		local function crystal(bone, base, h, w, o)
			o = o or {}
			local c = base * ang(0, o.twist or 45, 0)
			local sink = o.sink or 0.6
			local i = 0
			local function op()
				i += 1
				return { name = o.name and (o.name .. "_" .. i) or nil, tr = o.tr }
			end
			if o.short then
				local h1, h2 = h * 0.55, h * 0.45
				B:block(bone, v(w, h1 + sink, w), c * CFrame.new(0, (h1 - sink) / 2, 0), o.c1 or PURPLE, op())
				B:block(bone, v(w * 0.6, h2 + 0.1, w * 0.6), c * CFrame.new(0, h1 + h2 / 2, 0), o.c2 or LAV, op())
			else
				local h1, h2, h3 = h * 0.48, h * 0.3, h * 0.22
				B:block(bone, v(w, h1 + sink, w), c * CFrame.new(0, (h1 - sink) / 2, 0), o.c1 or PURPLE, op())
				B:block(bone, v(w * 0.7, h2 + 0.1, w * 0.7), c * CFrame.new(0, h1 + h2 / 2, 0), o.c2 or LAV, op())
				B:block(bone, v(w * 0.42, h3 + 0.1, w * 0.42), c * CFrame.new(0, h1 + h2 + h3 / 2, 0), o.c3 or PALE, op())
			end
			if o.tip ~= false then
				local s = math.max(0.34, w * 0.26)
				local p = op()
				p.mat = "Neon"
				B:block(bone, v(s, s * 1.3, s), c * CFrame.new(0, h + s * 0.55, 0), NEON, p)
			end
		end
		-- tiny 2-block crystal shard (knuckles, orbiting rocks)
		local function shard(bone, base, h, w, col)
			local c = base * ang(0, 45, 0)
			B:block(bone, v(w, h + 0.4, w), c * CFrame.new(0, h / 2 - 0.2, 0), col or PURPLE)
			B:block(bone, v(w * 0.5, w * 0.6, w * 0.5), c * CFrame.new(0, h + w * 0.25, 0), NEON, { mat = "Neon" })
		end

		------------------------------------------------------------------
		-- Hips + legs (short and thick, Thigh -> Shin -> Foot so it can squat)
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 6.4, 1.2))
		B:block(hips, v(7.4, 2.8, 5.2), cf(0, 6.6, 1.3), DARK)

		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Hips", v(2.8, 6.2, 1.3))
			B:block(thigh, v(3.6, 3.0, 4.0), cf(2.9, 5.0, 1.3), STONE)
			B:block(thigh, v(0.4, 2.2, 3.0), cf(4.85, 5.0, 1.3), DARK)
			B:block(thigh, v(0.2, 1.6, 0.2), cf(5.1, 5.0, 0.4), NEON, { mat = "Neon" })
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(2.9, 4.1, 1.3))
			B:block(shin, v(3.4, 3.0, 3.8), cf(2.9, 3.0, 1.4), STONE)
			B:block(shin, v(2.6, 1.4, 0.6), cf(2.9, 4.0, -0.65), LIGHT)
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(2.9, 2.0, 1.2))
			B:block(foot, v(4.2, 1.7, 5.2), cf(3.0, 1.2, 0.9), STONE)
			B:block(foot, v(4.4, 0.45, 5.4), cf(3.0, 0.22, 0.9), DARK)
			for k = -1, 1 do
				B:block(foot, v(1.1, 1.0, 1.0), cf(3.0 + k * 1.3, 0.65, -1.95), LIGHT)
			end
		end)

		------------------------------------------------------------------
		-- Torso: big hunched boulder body
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Hips", v(0, 7.8, 1.2))
		B:block(chest, v(7.8, 3.6, 5.6), cf(0, 9.2, 1.0), STONE)
		B:block(chest, v(10.6, 5.0, 7.0), cf(0, 13.2, 0.9), STONE)
		B:block(chest, v(8.6, 2.2, 6.0), cf(0, 16.6, 1.9), STONE)
		B:block(chest, v(6.4, 0.6, 4.4), cf(0, 17.9, 2.2), PURPLE)
		-- stepped light belly plate with the glowing core gem
		B:block(chest, v(5.2, 2.8, 0.5), cf(0, 9.4, -2.0), LIGHT)
		B:block(chest, v(2.4, 2.4, 0.5), cf(0, 9.5, -2.35, 0, 0, 45), PURPLE)
		B:block(chest, v(1.6, 1.6, 0.5), cf(0, 9.5, -2.55, 0, 0, 45), LAV)
		local core = B:block(chest, v(0.9, 0.9, 0.4), cf(0, 9.5, -2.75, 0, 0, 45), NEON, { mat = "Neon", name = "Core" })
		B:light(core, { name = "CoreLight", color = NEON, brightness = 0.6, range = 7 })
		B:emitter(core, "spark", { name = "CoreCharge", color = { "#ffffff", NEON }, rate = 16, enabled = false })
		B:sym(function()
			B:block(chest, v(0.5, 4.0, 5.6), cf(5.35, 12.8, 0.9), DARK)
			B:block(chest, v(4.2, 2.4, 0.7), cf(2.4, 13.4, -2.85), LIGHT)
			-- glowing crystal vein on the flank
			B:block(chest, v(0.35, 2.6, 0.6), cf(5.65, 12.6, -1.2), PURPLE)
			B:block(chest, v(0.2, 2.0, 0.2), cf(5.85, 12.6, -1.2), NEON, { mat = "Neon" })
			-- stepped back boulders
			B:block(chest, v(3.6, 2.6, 0.6), cf(2.1, 13.6, 4.55), LIGHT)
		end)
		B:block(chest, v(7.0, 1.4, 0.6), cf(0, 11.3, 4.5), DARK)
		local aura = B:block(chest, v(9, 6, 6), cf(0, 12, 1), STONE, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "Twinkle", color = { "#ffffff", LAV }, rate = 4 })

		-- crystal spine down the back (fixed to the chest)
		crystal(chest, cf(0, 13.8, 4.5, 45, 0, 0), 2.6, 1.9)
		B:sym(function()
			crystal(chest, cf(2.8, 11.6, 4.4, 45, 0, -22), 2.0, 1.4, { short = true })
			-- amethyst vein zigzag on the back
			B:beam(chest, v(0.4, 13.2, 4.5), v(1.6, 12.0, 4.5), 0.5, 0.3, PURPLE)
			B:beam(chest, v(1.6, 12.0, 4.5), v(1.0, 10.9, 4.5), 0.5, 0.3, PURPLE)
		end)
		-- crystal cluster sprouting from the lower back / hips
		crystal(chest, cf(0, 9.6, 3.6, 66, 0, 0), 2.4, 1.8)
		B:sym(function()
			crystal(chest, cf(2.3, 9.0, 3.4, 58, 0, -26), 1.8, 1.3, { short = true })
		end)

		-- crystal mane on its own bone (wobbles after the quake)
		local back = B:bone("BackCrystals", "Chest", v(0, 17.6, 2.4))
		crystal(back, cf(0, 17.6, 2.6, 22, 0, 0), 3.6, 2.8)
		B:sym(function()
			crystal(back, cf(2.5, 17.5, 2.0, 8, 0, -30), 3.0, 2.2)
			crystal(back, cf(3.8, 16.8, 3.9, 28, 0, -52), 2.4, 1.8)
		end)
		crystal(back, cf(0, 16.4, 4.9, 58, 0, 0), 2.6, 2.0)
		local motes = B:block(back, v(5, 1, 3), cf(0, 19.0, 2.8), STONE, { tr = 1, name = "MoteVolume" })
		B:emitter(motes, "ember", { name = "Motes", tex = "sparkle", color = { LAV, NEON }, rate = 3, size = { 0.35, 0.25, 0 } })

		------------------------------------------------------------------
		-- Head (big cartoon head sunk between the shoulders) + Jaw + Lids
		------------------------------------------------------------------
		local head = B:bone("Head", "Chest", v(0, 14.8, -2.0))
		B:block(head, v(6.8, 3.4, 5.2), cf(0, 16.8, -4.8), LIGHT)
		B:block(head, v(5.2, 0.5, 3.6), cf(0, 18.6, -4.6), STONE)
		B:block(head, v(6.4, 1.1, 4.8), cf(0, 14.6, -5.3), LIGHT)
		B:block(head, v(5.8, 0.4, 4.4), cf(0, 13.95, -5.2), MOUTH)
		B:block(head, v(1.4, 1.0, 0.7), cf(0, 15.2, -7.9), STONE)
		B:sym(function()
			-- heavy angry brow
			B:block(head, v(3.8, 1.4, 2.0), cf(1.8, 17.0, -7.1, 0, 0, 14), DARK)
			-- eye: dark socket, glowing slit, pupil
			B:block(head, v(2.5, 1.6, 0.3), cf(1.7, 15.85, -7.5), MOUTH)
			B:block(head, v(2.0, 1.1, 0.3), cf(1.7, 15.85, -7.6), NEON, { mat = "Neon", name = "Eye" })
			B:block(head, v(0.5, 1.0, 0.2), cf(1.35, 15.85, -7.8), PUPIL)
			-- cheek boulders
			B:block(head, v(1.2, 1.6, 2.4), cf(3.45, 15.2, -5.8), STONE)
			-- upper teeth: a fang + two small teeth
			B:block(head, v(0.8, 1.2, 0.7), cf(1.55, 13.4, -7.2), WHITE)
			B:block(head, v(0.6, 0.8, 0.6), cf(0.55, 13.6, -7.2), WHITE)
			B:block(head, v(0.6, 0.8, 0.6), cf(2.55, 13.6, -7.2), WHITE)
			-- crystal horn
			crystal(head, cf(3.1, 17.5, -4.2, 18, 0, -48), 3.0, 1.9)
		end)

		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(1.65, 16.6, -7.6))
			B:block(lid, v(2.6, 1.1, 0.5), cf(1.65, 16.95, -7.7, 0, 0, 14), LIGHT)
		end)

		local jaw = B:bone("Jaw", "Head", v(0, 14.0, -3.0))
		B:block(jaw, v(6.4, 1.9, 5.2), cf(0, 12.85, -5.6), LIGHT)
		B:block(jaw, v(5.6, 0.3, 4.6), cf(0, 13.85, -5.5), MOUTH)
		B:block(jaw, v(2.8, 0.35, 2.6), cf(0, 14.0, -5.0), TONGUE)
		B:block(jaw, v(5.4, 0.5, 4.4), cf(0, 11.75, -5.4), DARK)
		B:block(jaw, v(3.8, 0.7, 0.4), cf(0, 12.6, -8.35), STONE)
		B:sym(function()
			B:block(jaw, v(0.6, 0.8, 0.6), cf(1.0, 14.3, -7.6), WHITE)
			B:block(jaw, v(1.0, 2.0, 1.0), cf(2.65, 14.6, -8.0), PALE)
			B:block(jaw, v(0.6, 0.6, 0.6), cf(2.65, 15.85, -8.0), WHITE)
		end)

		------------------------------------------------------------------
		-- Arms: stepped boulder pauldrons, huge forearms, giant fists
		------------------------------------------------------------------
		B:sym(function(side)
			local S, E, W = v(5.6, 13.8, 0.8), v(7.7, 9.3, 1.2), v(8.5, 4.7, -1.4)
			local arm = B:bone("Arm" .. side, "Chest", S)
			B:block(arm, v(4.6, 3.4, 5.2), cf(6.8, 14.0, 0.8), STONE)
			B:block(arm, v(3.8, 0.8, 4.2), cf(7.0, 16.1, 0.9), PURPLE)
			B:block(arm, v(4.8, 0.9, 5.4), cf(6.8, 12.5, 0.8), DARK)
			B:block(arm, v(3.0, 0.25, 0.2), cf(6.9, 14.6, -1.85), NEON, { mat = "Neon" })
			crystal(arm, cf(7.5, 16.4, 1.0, 10, 0, -20), 3.4, 2.2)
			crystal(arm, cf(5.9, 16.4, 2.4, 28, 0, -4), 2.4, 1.6, { short = true })
			crystal(arm, cf(8.8, 15.3, 2.6, 30, 0, -58), 1.8, 1.2, { short = true })
			B:beam(arm, v(6.1, 12.8, 0.8), E + v(0, 0.3, 0), 3.0, 3.2, DARK)

			-- forearm: one big angled boulder (elbow back, wrist forward = gorilla stance)
			local fore = B:bone("Forearm" .. side, "Arm" .. side, E)
			local fcf, flen = P.span(E, W)
			B:block(fore, v(3.4, 1.8, 3.8), CFrame.new(E), DARK)
			B:block(fore, v(4.6, 4.2, flen + 0.4), fcf, STONE)
			B:block(fore, v(3.4, 0.5, 3.4), fcf * CFrame.new(0, 2.25, 0.2), LIGHT)
			B:block(fore, v(4.8, 4.4, 0.9), fcf * CFrame.new(0, 0, -flen / 2 + 0.5), DARK)
			B:block(fore, v(0.2, 0.3, 2.8), fcf * CFrame.new(2.35, 0.6, 0.3), NEON, { mat = "Neon" })
			crystal(fore, cf(10.1, 7.4, 0.3, 28, 0, -58), 2.8, 1.8)
			crystal(fore, cf(7.8, 6.3, 1.5, 50, 0, -6), 2.0, 1.3, { short = true })

			local fist = B:bone("Fist" .. side, "Forearm" .. side, W)
			B:block(fist, v(5.0, 3.8, 4.4), cf(8.6, 2.6, -1.5), LIGHT)
			B:block(fist, v(1.1, 1.5, 2.2), cf(6.0, 2.9, -2.7), DARK)
			local dust = B:block(fist, v(5, 0.4, 5), cf(8.6, 0.6, -2.0), STONE, { tr = 1, name = "FistFX" .. side })
			B:emitter(dust, "dust", { name = "ThumpDust" .. side, color = { "#d8d2e6", "#a59cb8" }, speed = { 4, 8 }, size = { 1, 2, 2.6 } })

			local fingers = B:bone("Fingers" .. side, "Fist" .. side, v(8.6, 4.2, -3.7))
			for k = 0, 3 do
				local x = 6.85 + k * 1.165
				B:block(fingers, v(1.15, 3.0, 1.3), cf(x, 2.75, -4.2), LIGHT)
				B:block(fingers, v(1.2, 0.7, 1.4), cf(x, 4.0, -4.2), STONE)
			end
			shard(fingers, cf(8.02, 4.3, -4.3, -40, 0, 0), 1.1, 0.85)
			shard(fingers, cf(9.18, 4.3, -4.3, -40, 0, 0), 1.1, 0.85)
			B:trail(fingers, v(8.6, 3.8, -4.8), v(8.6, 1.4, -4.8), { name = "FistTrail" .. side, color = { LAV, NEON }, life = 0.28, trans = { 0.35, 1 } })
		end)

		------------------------------------------------------------------
		-- Floating rock / crystal cubes orbiting the golem
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 10, 1))
		local spots = {
			{ 12.5, 13.0, -1.0, "rock", 1.8 },
			{ -12.0, 9.5, 2.5, "crystal", 1.3 },
			{ 7.0, 6.5, 10.0, "rock", 1.5 },
			{ -8.0, 15.5, -7.0, "crystal", 1.2 },
			{ 3.0, 18.0, 9.0, "rock", 1.3 },
		}
		for i, s in spots do
			local x, y, z, kind, size = s[1], s[2], s[3], s[4], s[5]
			local ob = B:bone("Orb" .. i, "Orbit", v(x, y, z))
			if kind == "rock" then
				B:block(ob, v(size, size, size), cf(x, y, z), STONE)
				B:block(ob, v(size + 0.1, size * 0.3, size + 0.1), cf(x, y + size * 0.36, z), LIGHT)
				shard(ob, cf(x + 0.2, y + size / 2, z, 0, 0, -20), 0.7, 0.6)
			else
				B:block(ob, v(size, size * 1.4, size), cf(x, y, z, 0, 45, 0), LAV)
				B:block(ob, v(size * 1.1, size * 0.3, size * 1.1), cf(x, y - size * 0.45, z, 0, 45, 0), PURPLE)
				B:block(ob, v(size * 0.5, size * 0.5, size * 0.5), cf(x, y + size * 0.9, z, 0, 45, 0), NEON, { mat = "Neon" })
			end
		end
		B:trail("Orb1", v(12.5, 13.5, -1.0), v(12.5, 12.5, -1.0), { name = "OrbTrail1", color = LAV, life = 0.4, trans = { 0.6, 1 } })
		B:trail("Orb2", v(-12.0, 10.0, 2.5), v(-12.0, 9.0, 2.5), { name = "OrbTrail2", color = LAV, life = 0.4, trans = { 0.6, 1 } })

		------------------------------------------------------------------
		-- Crystal Quake ground FX (hidden until the slam)
		------------------------------------------------------------------
		local IX, IZ = 9.2, -7.2 -- fist impact points (+-IX, IZ)
		local fx = B:block("Root", v(18, 0.4, 7), cf(0, 0.2, IZ), STONE, { tr = 1, name = "QuakeFX" })
		B:emitter(fx, "dust", { name = "QuakeDust", color = { "#d8d2e6", "#a59cb8" } })
		B:emitter(fx, "burst", { name = "QuakeBurst", color = { "#ffffff", LAV, NEON } })
		B:emitter(fx, "burst", { name = "QuakeRocks", color = { STONE, LAV }, speed = { 12, 20 }, spread = 35, accel = { 0, -45, 0 }, size = { 0.9, 0.8, 0.6 }, life = { 0.8, 1.2 }, light = 0, drag = 0.5 })
		B:light(fx, { name = "QuakeLight", color = NEON, brightness = 0.01, range = 16 })

		-- glowing ground cracks radiating from each fist
		B:sym(function(side)
			local cracks = {
				{ v(IX, 0, IZ), v(IX + 3.0, 0, IZ - 1.8), v(IX + 4.4, 0, IZ - 4.6) },
				{ v(IX, 0, IZ), v(IX - 2.0, 0, IZ - 3.2), v(IX - 1.2, 0, IZ - 6.0) },
				{ v(IX, 0, IZ), v(IX + 3.4, 0, IZ + 1.6), v(IX + 6.0, 0, IZ + 1.0) },
			}
			for i, cr in cracks do
				for j = 1, 2 do
					local a, b = cr[j] + v(0, 0.06, 0), cr[j + 1] + v(0, 0.06, 0)
					B:beam("Root", a, b, 0.36, 0.12, NEON, { mat = "Neon", tr = 1, name = "Crack" .. side .. i .. j })
				end
			end
		end)

		-- crystal spikes that erupt out of the ground
		local spikes = B:bone("Spikes", "Root", v(0, 0, IZ))
		B:sym(function(side)
			crystal(spikes, cf(IX + 3.4, 0, IZ - 2.6, -14, 0, -20), 4.6, 2.6, { tr = 1, name = "Spike" .. side .. "1", sink = 0.4 })
			crystal(spikes, cf(IX - 4.8, 0, IZ - 4.6, -24, 0, 14), 3.8, 2.2, { tr = 1, name = "Spike" .. side .. "2", sink = 0.4 })
			crystal(spikes, cf(IX + 4.2, 0, IZ + 2.8, 10, 0, -28), 3.2, 1.9, { tr = 1, name = "Spike" .. side .. "3", sink = 0.4 })
		end)

		-- rock debris cubes that fly out of the impact
		B:sym(function(side)
			for i = 1, 2 do
				local p = v(IX + (i == 1 and 0.8 or -0.8), 0.6, IZ + (i == 1 and -0.6 or 0.6))
				local d = B:bone("Debris" .. side .. i, "Root", p)
				B:block(d, v(1.1, 1.1, 1.1), CFrame.new(p), i == 1 and STONE or PURPLE, { tr = 1, name = "DebrisCube" .. side .. i })
			end
		end)
	end,
}
