--!nocheck
-- Amethyst Golem: hunched stud-built rock gorilla made of chunky blue-slate
-- boulders, a big cartoon head with glowing eyes under a heavy brow, a stepped
-- lavender belly with a core gem, ONE clean stepped crystal spine, a few bold
-- crystal horns (small magenta neon tips only), huge boulder fists and glossy
-- floating crystal cubes. Signature move: CRYSTAL QUAKE.
return {
	DisplayName = "Amethyst Golem",
	Rarity = "Epic",
	Element = "Crystal",
	Build = function(B, P)
		local v, cf = P.v, P.cf

		-- palette: saturated blue-slate stone, purple/lavender crystal, ONE magenta neon
		local STONE, DARK, LIGHT = "#5a66a0", "#3b4370", "#9ba6d2"
		local PURPLE, LAV, PALE = "#8a4dff", "#c49bff", "#e4d6ff"
		local WHITE, MOUTH, TONGUE, PUPIL = "#f6f2ff", "#15121f", "#d8487a", "#1a0f2e"
		local NEON, EYE = "#ff45e6", "#ffd2fb"

		-- Voxel crystal: stacked square blocks that taper purple -> lavender -> pale
		-- and end in a SMALL neon tip. base: model-space CFrame at the root, local +Y =
		-- growth direction. o.twist (deg, default 45) turns it into a diamond.
		local function crystal(bone, base, h, w, o)
			o = o or {}
			local c = base * P.ang(0, o.twist or 45, 0)
			local sink = o.sink or 0.6
			local i = 0
			local function op()
				i += 1
				return { name = o.name and (o.name .. "_" .. i) or nil, tr = o.tr }
			end
			local h1, h2, h3 = h * 0.48, h * 0.3, h * 0.22
			B:block(bone, v(w, h1 + sink, w), c * CFrame.new(0, (h1 - sink) / 2, 0), o.c1 or PURPLE, op())
			B:block(bone, v(w * 0.7, h2 + 0.1, w * 0.7), c * CFrame.new(0, h1 + h2 / 2, 0), o.c2 or LAV, op())
			B:block(bone, v(w * 0.42, h3 + 0.1, w * 0.42), c * CFrame.new(0, h1 + h2 + h3 / 2, 0), o.c3 or PALE, op())
			if o.tip ~= false then
				local s = math.max(0.32, w * 0.24)
				local p = op()
				p.mat = "Neon"
				B:block(bone, v(s, s * 1.3, s), c * CFrame.new(0, h + s * 0.55, 0), NEON, p)
			end
		end

		------------------------------------------------------------------
		-- Hips + legs (short and thick, Thigh -> Shin -> Foot so it can squat)
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 6.4, 1.2))
		B:block(hips, v(7.4, 2.8, 5.2), cf(0, 6.6, 1.3), DARK)
		B:block(hips, v(5.0, 0.6, 0.4), cf(0, 7.4, -1.4), PURPLE) -- belt

		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Hips", v(2.8, 6.2, 1.3))
			B:block(thigh, v(3.6, 3.0, 4.0), cf(2.9, 5.0, 1.3), STONE)
			B:block(thigh, v(0.4, 2.2, 3.0), cf(4.85, 5.0, 1.3), DARK)
			B:block(thigh, v(0.2, 1.6, 0.2), cf(5.1, 5.0, 0.4), NEON, { mat = "Neon" })
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(2.9, 4.1, 1.3))
			B:block(shin, v(3.4, 3.0, 3.8), cf(2.9, 3.0, 1.4), DARK)
			B:block(shin, v(2.6, 1.4, 0.6), cf(2.9, 3.6, -0.65), LAV) -- knee plate
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(2.9, 2.0, 1.2))
			B:block(foot, v(4.2, 1.7, 5.2), cf(3.0, 1.2, 0.9), STONE)
			B:block(foot, v(4.4, 0.45, 5.4), cf(3.0, 0.22, 0.9), DARK)
			for k = -1, 1 do
				B:block(foot, v(1.1, 1.0, 1.0), cf(3.0 + k * 1.3, 0.65, -1.95), PALE) -- toes
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
		-- big stepped lavender belly (like the reference's chest scales) + core gem
		B:block(chest, v(7.0, 2.0, 0.8), cf(0, 12.6, -2.85), LAV)
		B:block(chest, v(5.6, 2.0, 1.4), cf(0, 10.7, -2.5), PALE)
		B:block(chest, v(4.2, 1.6, 1.2), cf(0, 8.9, -2.05), LAV)
		B:block(chest, v(2.2, 2.2, 0.5), cf(0, 10.7, -3.3, 0, 0, 45), PURPLE)
		local core = B:block(chest, v(1.0, 1.0, 0.4), cf(0, 10.7, -3.6, 0, 0, 45), NEON, { mat = "Neon", name = "Core" })
		B:light(core, { name = "CoreLight", color = NEON, brightness = 0.6, range = 7 })
		B:emitter(core, "spark", { name = "CoreCharge", color = { "#ffffff", NEON }, rate = 16, enabled = false })
		B:sym(function()
			B:block(chest, v(0.5, 4.0, 5.6), cf(5.35, 12.8, 0.9), DARK) -- flank panel
			B:block(chest, v(0.2, 2.0, 0.2), cf(5.7, 12.6, -1.2), NEON, { mat = "Neon" }) -- flank vein
			-- stepped back plates: shoulder humps + tiered panels
			B:block(chest, v(4.0, 2.0, 3.0), cf(3.4, 16.9, 3.7), DARK)
			B:block(chest, v(3.0, 2.2, 0.6), cf(2.4, 13.4, 4.55), LIGHT)
		end)
		B:block(chest, v(6.0, 0.5, 0.3), cf(0, 10.2, 3.95), LAV) -- lower-back stripe
		B:block(chest, v(7.0, 1.2, 0.6), cf(0, 11.4, 4.5), DARK)
		local aura = B:block(chest, v(9, 6, 6), cf(0, 12, 1), STONE, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "Twinkle", color = { "#ffffff", PALE }, rate = 4 })

		-- ONE clean stepped crystal spine down the centre of the back
		local spine = {
			{ 16.4, 5.0, 2.4, 3.0 },
			{ 14.4, 4.55, 2.0, 2.6 },
			{ 12.6, 4.55, 1.6, 2.0 },
			{ 10.9, 4.6, 1.2, 1.6 },
		}
		for _, s in spine do
			crystal(chest, cf(0, s[1], s[2], 35, 0, 0), s[4], s[3], { twist = 0 })
		end

		-- crystal mane on its own bone (wobbles after every impact)
		local back = B:bone("BackCrystals", "Chest", v(0, 17.6, 2.4))
		crystal(back, cf(0, 17.6, 2.6, 26, 0, 0), 2.6, 2.8)
		B:sym(function()
			crystal(back, cf(2.5, 17.5, 2.0, 8, 0, -30), 3.0, 2.2)
		end)
		local motes = B:block(back, v(5, 1, 3), cf(0, 19.0, 2.8), STONE, { tr = 1, name = "MoteVolume" })
		B:emitter(motes, "ember", { name = "Motes", tex = "sparkle", color = { PALE, NEON }, rate = 3, size = { 0.35, 0.25, 0 } })

		------------------------------------------------------------------
		-- Head: authored at 1x around OP, scaled 1.25x and raised so it is the
		-- big readable focal point. + Jaw + Lids
		------------------------------------------------------------------
		local OP, NP, HS = v(0, 14.8, -2.0), v(0, 16.0, -2.0), 1.25
		local function hp(p) return NP + (p - OP) * HS end
		local function hcf(x, y, z, rx, ry, rz) return CFrame.new(hp(v(x, y, z))) * P.ang(rx or 0, ry or 0, rz or 0) end
		local function hs(x, y, z) return v(x, y, z) * HS end

		local head = B:bone("Head", "Chest", hp(v(0, 14.8, -2.0)))
		B:block(head, hs(6.8, 3.4, 5.2), hcf(0, 16.8, -4.8), STONE) -- cranium
		B:block(head, hs(5.6, 3.0, 1.6), hcf(0, 16.2, -2.2), DARK) -- back of the head
		B:block(head, hs(5.2, 0.5, 3.6), hcf(0, 18.7, -4.6), PURPLE) -- top plate
		B:block(head, hs(3.2, 0.4, 2.0), hcf(0, 19.1, -4.4), LAV) -- top step
		B:block(head, hs(6.4, 1.1, 4.8), hcf(0, 14.6, -5.3), LIGHT) -- muzzle
		B:block(head, hs(5.8, 0.4, 4.4), hcf(0, 13.95, -5.2), MOUTH) -- mouth roof
		B:block(head, hs(1.6, 1.0, 0.7), hcf(0, 15.2, -7.95), STONE) -- nose
		B:block(head, hs(0.5, 0.35, 0.2), hcf(0.45, 15.2, -8.35), MOUTH) -- nostrils
		B:block(head, hs(0.5, 0.35, 0.2), hcf(-0.45, 15.2, -8.35), MOUTH)
		B:sym(function()
			-- heavy angry brow + thin glow strip under it
			B:block(head, hs(3.8, 1.4, 2.0), hcf(1.8, 17.15, -7.1, 0, 0, 14), DARK)
			B:block(head, hs(2.6, 0.2, 0.2), hcf(1.75, 16.55, -7.75, 0, 0, 14), NEON, { mat = "Neon" })
			-- eye: dark socket, big glowing rectangle, pupil toward the nose
			B:block(head, hs(2.8, 1.6, 0.3), hcf(1.75, 15.85, -7.5), MOUTH)
			B:block(head, hs(2.4, 1.3, 0.3), hcf(1.75, 15.85, -7.6), EYE, { mat = "Neon", name = "Eye" })
			B:block(head, hs(0.8, 1.1, 0.2), hcf(1.2, 15.8, -7.8), PUPIL)
			-- cheek boulders with a lavender stripe
			B:block(head, hs(1.2, 1.8, 2.6), hcf(3.45, 15.2, -5.8), STONE)
			B:block(head, hs(0.3, 0.5, 1.8), hcf(4.1, 15.5, -5.8), LAV)
			-- upper teeth: a big fang + two small teeth
			B:block(head, hs(0.8, 1.2, 0.7), hcf(1.55, 13.4, -7.2), WHITE)
			B:block(head, hs(0.6, 0.8, 0.6), hcf(0.55, 13.6, -7.2), WHITE)
			B:block(head, hs(0.6, 0.8, 0.6), hcf(2.55, 13.6, -7.2), WHITE)
			-- big crystal horn
			crystal(head, hcf(3.0, 17.6, -4.4, 14, 0, -38), 3.2 * HS, 1.9 * HS)
		end)
		-- small center crystal on the brow ridge
		crystal(head, hcf(0, 18.6, -6.4, -10, 0, 0), 1.5 * HS, 1.1 * HS)

		local mouthFX = B:block(head, hs(2, 1, 1), hcf(0, 13.8, -7.8), STONE, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFX, "burst", {
			name = "RoarSparks", color = { "#ffffff", NEON }, life = { 0.15, 0.4 }, speed = { 6, 12 }, size = { 0.45, 0.2, 0 }, drag = 4,
		})

		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", hp(v(1.75, 16.6, -7.6)))
			B:block(lid, hs(2.8, 1.2, 0.5), hcf(1.75, 17.0, -7.72, 0, 0, 14), STONE)
		end)

		local jaw = B:bone("Jaw", "Head", hp(v(0, 14.0, -3.0)))
		B:block(jaw, hs(6.4, 1.9, 5.2), hcf(0, 12.85, -5.6), LIGHT)
		B:block(jaw, hs(5.6, 0.3, 4.6), hcf(0, 13.85, -5.5), MOUTH)
		B:block(jaw, hs(2.8, 0.35, 2.6), hcf(0, 14.0, -5.0), TONGUE)
		B:block(jaw, hs(5.4, 0.5, 4.4), hcf(0, 11.75, -5.4), DARK)
		B:block(jaw, hs(3.8, 0.7, 0.4), hcf(0, 12.6, -8.35), LAV) -- chin plate
		B:sym(function()
			-- toothy grin: 3 lower teeth + a tapered tusk leaning outward
			B:block(jaw, hs(0.6, 0.8, 0.6), hcf(0.45, 14.3, -7.6), WHITE)
			B:block(jaw, hs(0.6, 0.6, 0.6), hcf(1.25, 14.2, -7.6), WHITE)
			B:block(jaw, hs(0.6, 0.8, 0.6), hcf(2.0, 14.3, -7.6), WHITE)
			B:spike(jaw, hp(v(2.65, 13.9, -7.9)), hp(v(3.1, 15.6, -8.2)), 1.0 * HS, 0.9 * HS, WHITE)
		end)

		------------------------------------------------------------------
		-- Arms: stepped boulder pauldrons, huge forearms, giant fists
		------------------------------------------------------------------
		B:sym(function(side)
			local S, E, W = v(5.6, 13.8, 0.8), v(7.7, 9.3, 1.2), v(8.5, 4.7, -1.4)
			local arm = B:bone("Arm" .. side, "Chest", S)
			B:block(arm, v(4.6, 3.4, 5.2), cf(6.8, 14.0, 0.8), STONE)
			B:block(arm, v(4.6, 1.0, 5.0), cf(7.0, 16.1, 0.9), PURPLE) -- pauldron cap
			B:block(arm, v(3.0, 0.5, 3.4), cf(7.0, 16.8, 1.0), LAV)
			B:block(arm, v(4.8, 0.9, 5.4), cf(6.8, 12.5, 0.8), DARK)
			B:block(arm, v(3.0, 0.25, 0.2), cf(6.9, 14.6, -1.85), NEON, { mat = "Neon" })
			crystal(arm, cf(7.9, 16.6, 1.2, 10, 0, -26), 2.4, 2.0)
			B:beam(arm, v(6.1, 12.8, 0.8), E + v(0, 0.3, 0), 3.0, 3.2, DARK)

			-- forearm: one big angled boulder (elbow back, wrist forward = gorilla stance)
			local fore = B:bone("Forearm" .. side, "Arm" .. side, E)
			local fcf, flen = P.span(E, W)
			B:block(fore, v(3.4, 1.8, 3.8), CFrame.new(E), DARK)
			B:block(fore, v(4.6, 4.2, flen + 0.4), fcf, STONE)
			B:block(fore, v(3.4, 0.5, 3.4), fcf * CFrame.new(0, 2.25, 0.2), LIGHT)
			B:block(fore, v(4.8, 4.4, 0.9), fcf * CFrame.new(0, 0, -flen / 2 + 0.5), PURPLE) -- wrist band
			B:block(fore, v(0.2, 0.3, 2.8), fcf * CFrame.new(2.35, 0.6, 0.3), NEON, { mat = "Neon" })
			crystal(fore, cf(10.1, 7.4, 0.3, 28, 0, -58), 2.8, 1.8)

			local fist = B:bone("Fist" .. side, "Forearm" .. side, W)
			B:block(fist, v(5.0, 3.8, 4.4), cf(8.6, 2.6, -1.5), LIGHT)
			B:block(fist, v(1.1, 1.5, 2.2), cf(6.0, 2.9, -2.7), STONE) -- thumb
			local dust = B:block(fist, v(5, 0.4, 5), cf(8.6, 0.6, -2.0), STONE, { tr = 1, name = "FistFX" .. side })
			B:emitter(dust, "dust", { name = "ThumpDust" .. side, color = { "#e2dcf0", "#aaa2c4" }, speed = { 4, 8 }, size = { 1, 2, 2.6 } })

			local fingers = B:bone("Fingers" .. side, "Fist" .. side, v(8.6, 4.2, -3.7))
			for k = 0, 3 do
				local x = 6.85 + k * 1.165
				B:block(fingers, v(1.15, 3.0, 1.3), cf(x, 2.75, -4.2), LIGHT)
				B:block(fingers, v(1.2, 0.7, 1.4), cf(x, 4.0, -4.2), PALE) -- knuckle caps
			end
			-- two little knuckle crystals
			for _, x in { 8.02, 9.18 } do
				B:block(fingers, v(0.85, 1.2, 0.85), cf(x, 4.5, -4.3, -40, 45, 0), PURPLE)
				B:block(fingers, v(0.42, 0.5, 0.42), cf(x, 5.1, -4.8, -40, 45, 0), NEON, { mat = "Neon" })
			end
			B:trail(fingers, v(8.6, 3.8, -4.8), v(8.6, 1.4, -4.8), { name = "FistTrail" .. side, color = { PALE, NEON }, life = 0.3, trans = { 0.3, 1 } })
		end)

		------------------------------------------------------------------
		-- Floating crystal cubes orbiting the golem (glossy cube + neon band)
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 10, 1))
		local spots = {
			{ 10.4, 15.0, -3.0, PURPLE },
			{ -10.6, 12.2, -2.6, LAV },
			{ 8.2, 11.6, 8.4, LAV },
			{ -8.4, 15.4, 7.8, PURPLE },
		}
		for i, s in spots do
			local x, y, z, col = s[1], s[2], s[3], s[4]
			local ob = B:bone("Orb" .. i, "Orbit", v(x, y, z))
			B:block(ob, v(2.0, 2.0, 2.0), cf(x, y, z), col)
			B:block(ob, v(1.3, 0.3, 1.3), cf(x, y + 1.1, z), col == PURPLE and LAV or PALE)
			B:block(ob, v(2.1, 0.25, 2.1), cf(x, y - 0.2, z), NEON, { mat = "Neon" })
		end
		B:trail("Orb1", v(10.4, 15.6, -3.0), v(10.4, 14.4, -3.0), { name = "OrbTrail1", color = { NEON, LAV }, life = 0.35, trans = { 0.55, 1 } })
		B:trail("Orb2", v(-10.6, 12.8, -2.6), v(-10.6, 11.6, -2.6), { name = "OrbTrail2", color = { NEON, LAV }, life = 0.35, trans = { 0.55, 1 } })

		------------------------------------------------------------------
		-- Crystal Quake ground FX (hidden until the slam)
		------------------------------------------------------------------
		local IX, IZ = 9.2, -7.2 -- fist impact points (+-IX, IZ)
		local fx = B:block("Root", v(18, 0.4, 7), cf(0, 0.2, IZ), STONE, { tr = 1, name = "QuakeFX" })
		B:emitter(fx, "dust", { name = "QuakeDust", color = { "#e2dcf0", "#aaa2c4" } })
		B:emitter(fx, "burst", { name = "QuakeBurst", color = { "#ffffff", PALE, NEON } })
		B:emitter(fx, "burst", { name = "QuakeRocks", color = { PURPLE, LAV }, speed = { 12, 20 }, spread = 35, accel = { 0, -45, 0 }, size = { 0.9, 0.8, 0.6 }, life = { 0.8, 1.2 }, light = 0, drag = 0.5 })
		B:light(fx, { name = "QuakeLight", color = NEON, brightness = 0.01, range = 16 })

		-- glowing ground cracks radiating from each fist (3 segments each)
		B:sym(function(side)
			local cracks = {
				{ v(IX, 0, IZ), v(IX + 3.0, 0, IZ - 1.8), v(IX + 4.4, 0, IZ - 4.6), v(IX + 6.6, 0, IZ - 5.8) },
				{ v(IX, 0, IZ), v(IX - 2.0, 0, IZ - 3.2), v(IX - 1.2, 0, IZ - 6.0), v(IX - 2.6, 0, IZ - 8.0) },
				{ v(IX, 0, IZ), v(IX + 3.4, 0, IZ + 1.6), v(IX + 6.0, 0, IZ + 1.0), v(IX + 8.0, 0, IZ + 2.4) },
			}
			for i, cr in cracks do
				for j = 1, 3 do
					local a, b = cr[j] + v(0, 0.08, 0), cr[j + 1] + v(0, 0.08, 0)
					B:beam("Root", a, b, 0.7, 0.15, NEON, { mat = "Neon", tr = 1, name = "Crack" .. side .. i .. j })
				end
			end
		end)

		-- crystal spikes that erupt out of the ground
		local spikes = B:bone("Spikes", "Root", v(0, 0, IZ))
		B:sym(function(side)
			crystal(spikes, cf(IX + 3.4, 0, IZ - 2.6, -14, 0, -20), 4.6, 2.6, { tr = 1, name = "Spike" .. side .. "1", sink = 0.4, twist = 0 })
			crystal(spikes, cf(IX - 4.8, 0, IZ - 4.6, -24, 0, 14), 3.8, 2.2, { tr = 1, name = "Spike" .. side .. "2", sink = 0.4, twist = 0 })
			crystal(spikes, cf(IX + 4.2, 0, IZ + 2.8, 10, 0, -28), 3.2, 1.9, { tr = 1, name = "Spike" .. side .. "3", sink = 0.4, twist = 0 })
		end)

		-- shockwave: ring of flat lavender slabs (one bone each) sliding outward
		local SC = v(0, 0.25, IZ + 1.0)
		for k = 1, 12 do
			local a = (k - 1) / 12 * 360
			local sb = B:bone("Shock" .. k, "Root", SC)
			B:block(sb, v(3.0, 0.4, 1.0), CFrame.new(SC) * P.ang(0, a, 0) * CFrame.new(0, 0, -4.0), PALE, { tr = 1, name = "Wave" .. k })
		end

		-- rock debris cubes that fly out of the impact
		B:sym(function(side)
			for i = 1, 2 do
				local p = v(IX + (i == 1 and 0.8 or -0.8), 0.6, IZ + (i == 1 and -0.6 or 0.6))
				local d = B:bone("Debris" .. side .. i, "Root", p)
				B:block(d, v(1.2, 1.2, 1.2), CFrame.new(p), i == 1 and STONE or PURPLE, { tr = 1, name = "DebrisCube" .. side .. i })
			end
		end)
	end,
}
