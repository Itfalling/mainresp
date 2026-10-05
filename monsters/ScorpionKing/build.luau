--!nocheck
-- Sandstorm Scorpion King: stud-built pharaoh scorpion. Sand-gold stepped armor,
-- dark bronze joints, cream claws/spikes/teeth, a lapis-striped Egyptian
-- headdress with a gold crown, and small turquoise neon accents only on the
-- eyes, crown gems and the stinger tip. Floating gold voxel cubes orbit him.
return {
	DisplayName = "Sandstorm Scorpion King",
	Rarity = "Legendary",
	Element = "Desert",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local GOLD, DARK, BRONZE = "#d9a54a", "#a8742a", "#5c3b1a"
		local CREAM, WHITE, MOUTH, TONGUE = "#ffedc2", "#fffaf0", "#1b120c", "#d9506b"
		local CROWN, LAPIS, TURQ, PUPIL = "#ffc51f", "#2947b8", "#2ff5c8", "#0b1f1d"
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- Body (thorax + abdomen): shingled armor plates with a spike ridge
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 4.4, -2.0))
		B:block(body, v(6.6, 3.0, 11.4), cf(0, 4.4, 1.1), GOLD)
		B:block(body, v(5.4, 0.6, 10.4), cf(0, 2.75, 1.1), CREAM)
		B:sym(function()
			B:block(body, v(0.4, 1.8, 10.6), cf(3.4, 4.0, 1.1), DARK)
			B:block(body, v(0.2, 0.5, 0.5), cf(3.65, 4.3, 0.5), TURQ, NEON)
			B:block(body, v(0.2, 0.5, 0.5), cf(3.65, 4.3, 2.7), TURQ, NEON)
		end)
		local plates = { { -3.5, 7.0 }, { -1.5, 7.6 }, { 0.5, 7.9 }, { 2.5, 7.7 }, { 4.5, 7.0 }, { 6.2, 5.8 } }
		for i, p in plates do
			local z, w = p[1], p[2]
			B:block(body, v(w, 0.9, 2.2), cf(0, 6.2, z), GOLD)
			B:block(body, v(w + 0.2, 0.7, 0.5), cf(0, 6.45, z + 1.0), DARK)
			if i <= 5 then
				B:spike(body, v(0, 6.5, z - 0.2), v(0, 7.9, z + 0.5), 0.9, 0.9, CREAM)
			end
		end
		local aura = B:block(body, v(9, 4, 11), cf(0, 6, 0.5), GOLD, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { color = { "#ffffff", CROWN }, rate = 5 })

		------------------------------------------------------------------
		-- Head: big cartoon face, toothy grin, Egyptian headdress + crown
		------------------------------------------------------------------
		local head = B:bone("Head", "Body", v(0, 4.8, -4.4))
		B:block(head, v(8.0, 3.4, 5.2), cf(0, 6.5, -7.0), GOLD)
		B:block(head, v(5.0, 0.6, 0.4), cf(0, 5.25, -9.75), DARK) -- upper lip band
		-- black mouth roof + upper teeth
		B:block(head, v(6.2, 0.7, 4.3), cf(0, 4.75, -7.3), MOUTH)
		B:block(head, v(0.55, 0.75, 0.5), cf(0, 4.45, -9.3), WHITE)
		B:sym(function()
			B:block(head, v(0.55, 0.75, 0.5), cf(1.3, 4.45, -9.3), WHITE)
			B:block(head, v(0.55, 0.6, 0.5), cf(2.5, 4.5, -9.3), WHITE)
			B:spike(head, v(3.55, 4.9, -9.0), v(3.65, 3.4, -9.3), 0.6, 0.6, CREAM) -- corner fang
			-- eye: bronze socket, neon block, dark pupil, heavy angled brow
			B:block(head, v(2.3, 2.4, 0.3), cf(1.9, 6.8, -9.6), BRONZE)
			B:block(head, v(1.7, 1.95, 0.3), cf(1.9, 6.8, -9.8), TURQ, { mat = "Neon", name = "Eye" })
			B:block(head, v(0.6, 1.25, 0.1), cf(1.6, 6.7, -10.0), PUPIL)
			B:block(head, v(2.6, 0.8, 0.9), cf(1.95, 8.0, -9.95, 0, 0, 14), BRONZE)
			-- side plate behind the headdress flap
			B:block(head, v(0.4, 2.6, 2.4), cf(4.05, 6.3, -5.6), DARK)
			-- nemes headdress flap with lapis stripes
			B:block(head, v(0.7, 4.6, 2.6), cf(4.2, 6.4, -8.0), CROWN)
			for k = 0, 2 do
				B:block(head, v(0.8, 0.55, 2.7), cf(4.2, 8.0 - k * 1.3, -8.0), LAPIS)
			end
			B:block(head, v(1.1, 0.8, 2.8), cf(4.25, 4.0, -8.0), LAPIS)
		end)
		-- headband + nemes cap
		B:block(head, v(8.6, 1.3, 0.7), cf(0, 8.75, -9.9), CROWN)
		B:block(head, v(8.4, 1.0, 5.4), cf(0, 8.7, -6.9), CROWN)
		-- crown: base with a lapis stripe, stepped points with turquoise gem tips
		B:block(head, v(6.6, 1.1, 4.6), cf(0, 9.75, -6.9), CROWN)
		B:block(head, v(6.7, 0.4, 4.7), cf(0, 9.75, -6.9), LAPIS)
		local function point(x, z, steps)
			local y = 10.3
			for s = 1, steps do
				local w = 1.3 - (s - 1) * 0.35
				B:block(head, v(w, 0.9, w), cf(x, y + 0.45, z), CROWN)
				y += 0.9
			end
			B:block(head, v(0.5, 0.5, 0.5), cf(x, y + 0.2, z), TURQ, NEON)
		end
		point(0, -7.4, 2)
		B:sym(function()
			point(2.4, -8.3, 2)
		end)
		-- uraeus (royal cobra) on the brow
		B:block(head, v(0.9, 1.4, 0.6), cf(0, 9.9, -10.0), CROWN)
		B:block(head, v(1.7, 1.0, 0.5), cf(0, 10.5, -10.1), CROWN)
		B:block(head, v(0.6, 0.45, 0.15), cf(0, 10.55, -10.4), TURQ, NEON)

		-- eyelids for cartoon blinks (hidden behind the headband at rest)
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(1.9, 7.9, -10.0))
			B:block(lid, v(1.9, 1.75, 0.3), cf(1.9, 8.55, -10.0), GOLD)
		end)

		-- jaw (underbite)
		local jaw = B:bone("Jaw", "Head", v(0, 4.6, -5.0))
		B:block(jaw, v(6.4, 1.3, 4.9), cf(0, 3.65, -7.25), GOLD)
		B:block(jaw, v(5.6, 0.4, 4.4), cf(0, 2.95, -7.2), CREAM)
		B:block(jaw, v(5.6, 0.3, 4.2), cf(0, 4.35, -7.4), MOUTH)
		B:block(jaw, v(2.6, 0.3, 2.6), cf(0, 4.55, -6.9), TONGUE)
		B:sym(function()
			B:block(jaw, v(0.5, 0.6, 0.45), cf(0.65, 4.55, -9.4), WHITE)
			B:block(jaw, v(0.5, 0.6, 0.45), cf(1.95, 4.55, -9.4), WHITE)
		end)
		local mouthFX = B:block(jaw, v(4, 1, 1), cf(0, 4.6, -9.6), GOLD, { tr = 1, name = "MouthFX" })

		------------------------------------------------------------------
		-- Pincers: arm -> forearm -> claw (palm + fixed finger) -> pincer jaw
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Body", v(3.3, 4.3, -5.0))
			B:block(arm, v(1.5, 1.5, 1.5), cf(3.5, 4.3, -5.0), BRONZE)
			B:beam(arm, v(3.8, 4.4, -5.1), v(6.1, 5.0, -6.0), 1.6, 1.6, GOLD)
			local fore = B:bone("Forearm" .. side, "Arm" .. side, v(6.4, 5.1, -6.1))
			B:block(fore, v(1.5, 1.5, 1.5), cf(6.4, 5.1, -6.1), BRONZE)
			B:block(fore, v(1.7, 1.7, 2.2), cf(6.6, 5.2, -7.6), GOLD)
			B:block(fore, v(1.8, 1.8, 0.5), cf(6.6, 5.2, -7.9), DARK)
			B:spike(fore, v(7.2, 5.9, -7.0), v(8.2, 6.9, -6.2), 0.6, 0.6, CREAM)

			local claw = B:bone("Claw" .. side, "Forearm" .. side, v(6.7, 5.3, -8.6))
			B:block(claw, v(3.4, 3.0, 3.4), cf(7.0, 5.3, -10.2), GOLD)
			B:block(claw, v(2.6, 0.6, 2.6), cf(7.0, 7.1, -10.0), GOLD)
			B:block(claw, v(3.5, 3.1, 0.5), cf(7.0, 5.3, -11.3), DARK)
			B:block(claw, v(2.8, 0.5, 2.8), cf(7.0, 3.6, -10.2), CREAM)
			B:block(claw, v(2.2, 0.9, 0.2), cf(7.0, 5.3, -12.0), BRONZE)
			B:block(claw, v(0.15, 0.3, 2.6), cf(8.72, 6.2, -10.2), TURQ, NEON)
			-- fixed lower finger
			B:block(claw, v(2.4, 1.3, 2.8), cf(7.0, 4.45, -13.2), GOLD)
			B:wedge(claw, v(2.2, 1.3, 1.4), cf(7.0, 4.45, -15.3, 0, 0, 180), CREAM)
			B:block(claw, v(0.5, 0.45, 0.5), cf(7.0, 5.32, -12.7), CREAM)
			B:block(claw, v(0.5, 0.45, 0.5), cf(7.0, 5.32, -13.9), CREAM)
			-- movable upper pincer jaw
			local pin = B:bone("Pincer" .. side, "Claw" .. side, v(7.0, 6.6, -11.8))
			B:block(pin, v(2.4, 1.3, 3.0), cf(7.0, 6.15, -13.3), GOLD)
			B:block(pin, v(2.5, 0.5, 0.5), cf(7.0, 6.6, -12.3), DARK)
			B:wedge(pin, v(2.2, 1.3, 1.4), cf(7.0, 6.15, -15.5), CREAM)
			B:block(pin, v(0.5, 0.45, 0.5), cf(7.0, 5.28, -13.3), CREAM)
			B:block(pin, v(0.5, 0.45, 0.5), cf(7.0, 5.28, -14.5), CREAM)
			B:trail(pin, v(7.0, 6.6, -15.7), v(7.0, 5.6, -15.7), { name = "PincerTrail" .. side, color = { "#ffffff", CROWN }, life = 0.22, trans = { 0.4, 1 } })
			local snapAt = B:block(claw, v(1.5, 1.5, 1.5), cf(7.0, 5.3, -15.3), GOLD, { tr = 1, name = "SnapFX" .. side })
			B:emitter(snapAt, "burst", { name = "SnapBurst" .. side, color = { "#ffffff", CROWN }, size = { 0.6, 0.4, 0 }, speed = { 5, 10 } })
		end)

		------------------------------------------------------------------
		-- Legs: 4 per side, hip -> knee -> foot, bone frames yawed along each leg
		------------------------------------------------------------------
		local hipZ = { -2.6, -0.5, 1.7, 3.9 }
		local yaws = { 40, 14, -14, -42 }
		B:sym(function(side)
			for i = 1, 4 do
				local base = CFrame.new(3.1, 4.2, hipZ[i]) * ang(0, yaws[i], 0)
				local function fr(r, y)
					return base * CFrame.new(r, y - 4.2, 0)
				end
				local function at(r, y)
					return fr(r, y).Position
				end
				local leg = B:bone("Leg" .. i .. side, "Body", base)
				B:beam(leg, at(-0.3, 4.0), at(3.05, 6.75), 1.45, 1.45, DARK)
				local knee = B:bone("Knee" .. i .. side, "Leg" .. i .. side, fr(3.28, 6.75))
				B:block(knee, v(1.15, 1.15, 1.15), fr(3.28, 6.75), BRONZE)
				B:beam(knee, at(3.5, 6.65), at(5.95, 2.35), 1.3, 1.3, DARK)
				B:beam(knee, at(4.9, 4.3), at(5.5, 3.2), 1.4, 1.4, GOLD)
				local foot = B:bone("Foot" .. i .. side, "Knee" .. i .. side, fr(6.1, 2.0))
				B:block(foot, v(0.95, 0.95, 0.95), fr(6.1, 2.0), BRONZE)
				B:beam(foot, at(6.2, 1.75), at(6.55, 0.9), 1.1, 1.1, GOLD)
				B:spike(foot, at(6.55, 1.05), at(6.95, 0.38), 0.95, 0.95, CREAM)
			end
		end)

		------------------------------------------------------------------
		-- Tail: 6 segments arching high over the back, bone frames along the arc
		-- (local +Z runs down the tail, -X curls it forward, +Y sways it left)
		------------------------------------------------------------------
		local segs = { { 45, 2.46, 2.65 }, { 76, 2.35, 2.5 }, { 106, 2.24, 2.35 }, { 130, 2.13, 2.25 }, { 150, 2.02, 2.15 }, { 166, 1.9, 2.05 } }
		local pos, parent = v(0, 4.7, 6.8), "Body"
		for i, s in segs do
			local th, len, w = s[1], s[2], s[3]
			local frame = CFrame.new(pos) * ang(-th, 0, 0)
			local function T(x, y, z)
				return frame * CFrame.new(x, y, z)
			end
			local name = "Tail" .. i
			local b = B:bone(name, parent, frame)
			B:block(b, v(w * 0.82, w * 0.8, 1.1), T(0, 0, 0), BRONZE)
			B:block(b, v(w, w * 0.92, len - 0.4), T(0, 0, len / 2 + 0.2), GOLD)
			B:block(b, v(w - 0.5, 0.3, len - 0.8), T(0, w * 0.46 + 0.1, len / 2 + 0.2), CREAM)
			local sh = i <= 3 and 0.9 or 0.6
			B:spike(b, T(0, -w * 0.46 + 0.1, len * 0.45).Position, T(0, -w * 0.46 - sh, len * 0.8).Position, 0.75, 0.75, CREAM)
			if i == 2 or i == 4 then
				B:block(b, v(0.32, 0.32, 0.32), T(0, -w * 0.46 - sh - 0.05, len * 0.82), TURQ, NEON)
			end
			pos = (frame * CFrame.new(0, 0, len)).Position
			parent = name
		end
		-- telson bulb + hooked stinger (hook continues the curl toward local +Y)
		local sf = CFrame.new(pos) * ang(-178, 0, 0)
		local function S(x, y, z)
			return sf * CFrame.new(x, y, z)
		end
		local st = B:bone("Stinger", "Tail6", sf)
		B:block(st, v(1.6, 1.6, 1.1), S(0, 0, 0), BRONZE)
		B:block(st, v(2.7, 2.6, 2.3), S(0, 0, 1.45), GOLD)
		B:block(st, v(2.1, 0.3, 1.9), S(0, 1.35, 1.45), CREAM)
		B:block(st, v(2.0, 2.0, 0.9), S(0, 0.3, 2.9), DARK)
		B:block(st, v(1.4, 1.4, 1.1), S(0, 0.8, 3.5), CREAM)
		B:sym(function()
			B:block(st, v(0.15, 0.5, 1.1), S(1.38, -0.1, 1.45), TURQ, NEON)
		end)
		B:spike(st, S(0, 1.0, 3.8).Position, S(0, 2.55, 5.35).Position, 1.05, 1.05, CREAM)
		local tip = B:block(st, v(0.45, 0.45, 0.45), S(0, 2.6, 5.4), TURQ, { mat = "Neon", name = "StingerTip" })
		B:emitter(tip, "drip", { name = "VenomDrip", color = TURQ, rate = 2 })
		B:emitter(tip, "burst", { name = "VenomBurst", color = { "#ffffff", TURQ } })
		B:light(tip, { name = "StingerLight", color = TURQ, brightness = 0, range = 12 })
		B:trail(st, S(0, 2.9, 5.0).Position, S(0, 2.2, 5.7).Position, { name = "StingerTrail", color = { "#ffffff", TURQ }, life = 0.3, trans = { 0.3, 1 } })

		------------------------------------------------------------------
		-- Venom glob (hidden): spat from the stinger on the strike, arcs over the
		-- crown and splats on the sand in front of the face
		------------------------------------------------------------------
		local glob = B:bone("Venom", "Root", v(0, 13.1, -8.5))
		B:block(glob, v(1.2, 1.2, 1.2), cf(0, 13.1, -8.5), TURQ, { mat = "Neon", tr = 1, name = "VenomA" })
		B:block(glob, v(0.8, 0.8, 0.8), cf(0, 13.6, -7.6), TURQ, { mat = "Neon", tr = 1, name = "VenomB" })
		B:block(glob, v(0.5, 0.5, 0.5), cf(0, 13.95, -6.9), "#c8fff0", { mat = "Neon", tr = 1, name = "VenomC" })
		B:trail(glob, v(0, 13.5, -8.5), v(0, 12.7, -8.5), { name = "VenomTrail", color = { "#ffffff", TURQ }, life = 0.25, trans = { 0.35, 1 } })
		local splat = B:bone("Splat", "Root", v(0.8, 0.1, -16))
		B:block(splat, v(3.4, 0.15, 1.1), cf(0.8, 0.1, -16), TURQ, { mat = "Neon", tr = 1, name = "SplatA" })
		B:block(splat, v(1.1, 0.16, 3.4), cf(0.8, 0.1, -16), TURQ, { mat = "Neon", tr = 1, name = "SplatB" })
		B:block(splat, v(0.8, 0.6, 0.8), cf(2.7, 0.3, -14.6), TURQ, { mat = "Neon", tr = 1, name = "SplatC" })
		local splashAt = B:block(splat, v(2, 0.4, 2), cf(0.8, 0.3, -16), GOLD, { tr = 1, name = "SplashFX" })
		B:emitter(splashAt, "burst", { name = "VenomSplash", color = { "#ffffff", TURQ }, speed = { 6, 12 }, size = { 0.8, 0.5, 0 } })

		------------------------------------------------------------------
		-- Ground FX: sand haze + strike dust
		------------------------------------------------------------------
		local ground = B:block("Root", v(14, 0.4, 16), cf(0, 0.2, 0), GOLD, { tr = 1, name = "SandFX" })
		B:emitter(ground, "smoke", { name = "SandHaze", color = "#ead09a", rate = 2.5, size = { 1.5, 3, 4 }, speed = { 0.4, 1.2 } })
		local dustAt = B:block("Root", v(10, 0.3, 8), cf(0, 0.15, -7), GOLD, { tr = 1, name = "StrikeFX" })
		B:emitter(dustAt, "dust", { name = "StrikeDust", color = "#e3c78f" })

		------------------------------------------------------------------
		-- Floating gold voxel cubes orbiting the king (VFX)
		------------------------------------------------------------------
		-- (they hover at fixed spots clear of every limb and tumble/bob/drift, so
		-- they never pass through the face, pincers or tail)
		local orbit = B:bone("Orbit", "Root", v(0, 7, 0))
		local spots = { { 11.5, 9.0, 1.0 }, { -11.5, 7.0, 3.5 }, { 8.0, 13.5, 8.5 }, { -7.5, 14.5, -3.0 }, { -5.0, 3.8, 11.5 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = (i == 2 or i == 4) and 1.3 or 1.7
			B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), i == 3 and CREAM or CROWN)
			B:block(ob, v(s + 0.1, 0.25, s + 0.1), cf(p[1], p[2], p[3]), TURQ, NEON)
		end
	end,
}
