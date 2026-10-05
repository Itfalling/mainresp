--!nocheck
-- Jade Mantis: stud-built warrior praying mantis. Emerald voxel exoskeleton with
-- gold trims, a big triangular cartoon head with gold eyes, huge stepped
-- pale-jade scythe blades with thin mint neon cutting edges, folded light-green
-- wing membranes over a segmented abdomen, and floating green voxel cubes.
return {
	DisplayName = "Jade Mantis",
	Rarity = "Legendary",
	Element = "Wind",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local MAIN, DARK, DEEP = "#2fbf71", "#1d8a4f", "#156b3c"
		local GOLD, JADE, JADE2 = "#f2c230", "#c8ffe6", "#9fe8c4"
		local WING, WHITE, MOUTH, TONGUE = "#8fe8a9", "#f6fff9", "#11151a", "#ff6f91"
		local MINT, EYE, PUPIL = "#7dffc8", "#ffd23f", "#0b0b14"
		local NEON = { mat = "Neon" }

		-- NOTE: CFrame.lookAt is unreliable in the offline builder, so beams and
		-- spikes are built here from an explicit orthonormal basis instead.
		local function span(a, b, up)
			local dir = b - a
			local len = dir.Magnitude
			local look = dir.Unit
			local upv = (up or v(0, 1, 0)).Unit
			if math.abs(look:Dot(upv)) > 0.98 then
				upv = math.abs(look.Z) < 0.9 and v(0, 0, 1) or v(1, 0, 0)
			end
			local right = look:Cross(upv).Unit
			local up2 = right:Cross(look).Unit
			return CFrame.fromMatrix((a + b) / 2, right, up2, -look), len
		end
		local function beam(bone, a, b, w, h, col, opts)
			local c, len = span(a, b, opts and opts.up)
			return B:block(bone, v(w, h or w, len), c, col, opts)
		end
		-- tapered blade/claw (2 wedges back to back), tip at b
		local function spike(bone, a, b, width, depth, col, opts)
			local c, len = span(a, b, opts and opts.up)
			local d = depth or width
			B:wedge(bone, v(width, d / 2, len), c * CFrame.new(0, d / 4, 0), col, opts)
			B:wedge(bone, v(width, d / 2, len), c * CFrame.new(0, -d / 4, 0) * CFrame.Angles(0, 0, math.pi), col, opts)
		end

		------------------------------------------------------------------
		-- THORAX (main body the walking legs, wings and abdomen hang from)
		------------------------------------------------------------------
		local thorax = B:bone("Thorax", "Root", v(0, 5.8, 1.0))
		B:block(thorax, v(4.0, 3.0, 5.5), cf(0, 5.9, 0.9), MAIN)
		B:block(thorax, v(3.0, 0.5, 4.5), cf(0, 4.25, 0.9), JADE)
		B:sym(function()
			B:block(thorax, v(0.3, 2.0, 4.5), cf(2.1, 5.7, 0.9), DEEP)
			B:block(thorax, v(0.35, 0.4, 4.7), cf(2.15, 6.95, 0.9), GOLD)
		end)
		local aura = B:block(thorax, v(8, 8, 13), cf(0, 8.5, 3), MAIN, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "WindSparkle", color = { "#ffffff", MINT }, rate = 5 })
		B:emitter(aura, "leaf", { name = "WindLeaves", color = { MINT, MAIN }, rate = 2, size = { 0.45, 0.4, 0.2 }, accel = { 2.5, -1.2, 1 } })
		-- ground plate for the landing dust (stays on the ground under the body)
		local dustAt = B:block("Root", v(10, 0.2, 14), cf(0, 0.1, 2), MAIN, { tr = 1, name = "DustFX" })
		B:emitter(dustAt, "dust", { name = "LandDust", color = "#e6efe0" })

		------------------------------------------------------------------
		-- CHEST (prothorax): stepped voxel stalk rising up and forward
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Thorax", v(0, 6.8, -1.2))
		B:block(chest, v(3.5, 2.0, 3.0), cf(0, 7.4, -1.8), MAIN)
		B:block(chest, v(3.1, 2.0, 2.7), cf(0, 9.1, -2.3), MAIN)
		B:block(chest, v(2.8, 1.8, 2.5), cf(0, 10.6, -2.8), MAIN)
		B:block(chest, v(2.6, 1.6, 2.4), cf(0, 11.9, -3.3), MAIN)
		-- stepped pale belly plates on the front
		B:block(chest, v(2.6, 1.4, 0.4), cf(0, 7.4, -3.45), JADE)
		B:block(chest, v(2.3, 1.4, 0.4), cf(0, 9.1, -3.8), JADE2)
		B:block(chest, v(2.0, 1.2, 0.4), cf(0, 10.6, -4.2), JADE)
		B:block(chest, v(1.8, 1.0, 0.4), cf(0, 11.85, -4.65), JADE2)
		B:block(chest, v(3.0, 0.5, 2.8), cf(0, 12.65, -3.3), GOLD) -- warrior collar
		B:sym(function()
			B:block(chest, v(0.3, 1.6, 2.3), cf(1.6, 9.1, -2.3), DARK)
			B:block(chest, v(0.3, 1.2, 2.0), cf(1.45, 10.6, -2.8), DARK)
		end)
		spike(chest, v(0, 9.6, -1.1), v(0, 10.8, 0.0), 0.8, 0.8, DARK)
		B:gem(chest, v(0.45, 0.45, 0.45), cf(0, 10.85, 0.05), MINT)
		spike(chest, v(0, 11.5, -2.1), v(0, 12.6, -0.6), 0.7, 0.7, DARK)
		B:gem(chest, v(0.4, 0.4, 0.4), cf(0, 12.65, -0.55), MINT)

		------------------------------------------------------------------
		-- HEAD: big triangular cartoon head (authored at 1x, scaled 1.3x)
		------------------------------------------------------------------
		local OLDP, HP, HS = v(0, 12.2, -3.4), v(0, 12.5, -4.2), 1.3
		local function hp(x, y, z) return HP + (v(x, y, z) - OLDP) * HS end
		local function hcf(x, y, z, rx, ry, rz) return CFrame.new(hp(x, y, z)) * P.ang(rx or 0, ry or 0, rz or 0) end
		local function hs(x, y, z) return v(x, y, z) * HS end

		local head = B:bone("Head", "Chest", HP)
		B:block(head, hs(1.8, 1.4, 1.8), hcf(0, 12.0, -3.2), DARK) -- neck stub covers the joint
		B:block(head, hs(4.8, 1.6, 3.0), hcf(0, 15.0, -4.2), MAIN) -- top row (between the eyes)
		B:block(head, hs(3.8, 1.6, 2.8), hcf(0, 13.5, -4.3), MAIN) -- middle row
		B:block(head, hs(3.0, 1.4, 2.6), hcf(0, 12.1, -4.5), MAIN) -- snout
		B:block(head, hs(3.6, 0.5, 2.4), hcf(0, 15.95, -4.0), DARK) -- forehead cap
		B:block(head, hs(2.7, 0.4, 2.1), hcf(0, 11.3, -4.85), MOUTH) -- mouth roof
		B:block(head, hs(2.0, 0.7, 0.2), hcf(0, 12.25, -5.85), JADE) -- pale clypeus plate
		-- ocelli (three little mint gems on the forehead)
		B:gem(head, hs(0.4, 0.4, 0.2), hcf(0, 15.3, -5.75), MINT)
		B:sym(function()
			B:gem(head, hs(0.4, 0.4, 0.2), hcf(0.6, 14.8, -5.75), MINT)
		end)
		-- gold crest
		B:block(head, hs(1.6, 0.6, 1.6), hcf(0, 16.45, -3.9), GOLD)
		B:block(head, hs(1.0, 0.6, 1.0), hcf(0, 17.0, -3.7), GOLD)
		B:gem(head, hs(0.5, 0.5, 0.5), hcf(0, 17.5, -3.6), MINT)
		-- upper teeth
		B:sym(function()
			B:block(head, hs(0.5, 0.75, 0.45), hcf(0.32, 10.9, -5.62), WHITE)
			B:block(head, hs(0.45, 0.55, 0.45), hcf(0.92, 11.0, -5.58), WHITE)
			B:block(head, hs(0.4, 0.65, 0.45), hcf(1.38, 10.95, -5.5), WHITE)
		end)
		B:sym(function(side)
			-- big gold compound eye (stepped bulge)
			B:block(head, hs(2.2, 2.6, 2.6), hcf(3.1, 15.0, -4.4), GOLD)
			B:block(head, hs(0.5, 1.8, 1.8), hcf(4.4, 15.0, -4.4), GOLD)
			B:block(head, hs(1.6, 0.4, 1.8), hcf(3.1, 13.55, -4.4), GOLD)
			-- glowing iris + dark pupil + highlight
			B:block(head, hs(1.6, 1.9, 0.2), hcf(3.15, 14.95, -5.75), EYE, { mat = "Neon", name = "Eye" .. side })
			B:block(head, hs(0.85, 1.35, 0.2), hcf(2.95, 14.8, -5.9), PUPIL)
			B:block(head, hs(0.38, 0.38, 0.1), hcf(3.12, 15.22, -6.04), WHITE)
			-- heavy angled brow
			B:block(head, hs(3.2, 0.75, 1.0), hcf(2.35, 16.45, -5.75, 0, 0, 20), DEEP)
			-- cheek panel + thin mint cheek stripe
			B:block(head, hs(0.3, 1.2, 2.0), hcf(1.95, 13.4, -4.3), DARK)
			B:block(head, hs(0.2, 0.25, 1.6), hcf(2.12, 12.85, -4.3), MINT, NEON)
		end)

		-- eyelids: flat plates resting on top of the eyes, hinge down to blink
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", hp(3.15, 16.35, -6.2))
			B:block(lid, hs(2.0, 0.3, 2.5), hcf(3.15, 16.2, -4.95), MAIN)
		end)

		-- antennae (2 bones each), arching out like horns, mint tips
		B:sym(function(side)
			local a1 = B:bone("AntA" .. side, "Head", hp(0.6, 15.9, -5.0))
			beam(a1, hp(0.6, 15.8, -5.0), hp(1.2, 17.6, -5.8), 0.75, 0.75, JADE)
			local a2 = B:bone("AntB" .. side, "AntA" .. side, hp(1.2, 17.5, -5.8))
			beam(a2, hp(1.15, 17.4, -5.75), hp(3.1, 18.35, -4.9), 0.6, 0.6, JADE)
			B:gem(a2, hs(0.55, 0.55, 0.55), hcf(3.18, 18.4, -4.85), MINT, { name = "AntTip" .. side })
		end)

		-- jaw with mandibles, teeth and a tongue
		local jaw = B:bone("Jaw", "Head", hp(0, 11.3, -3.6))
		B:block(jaw, hs(2.8, 0.9, 2.4), hcf(0, 10.75, -4.6), DARK)
		B:block(jaw, hs(2.4, 0.2, 2.0), hcf(0, 11.22, -4.7), MOUTH)
		B:block(jaw, hs(1.2, 0.2, 1.3), hcf(0, 11.3, -4.5), TONGUE)
		B:sym(function()
			B:block(jaw, hs(0.45, 0.55, 0.45), hcf(0.62, 11.45, -5.5), WHITE)
			B:block(jaw, hs(0.4, 0.45, 0.4), hcf(1.15, 11.4, -5.45), WHITE)
			spike(jaw, hp(1.15, 10.8, -5.0), hp(0.45, 10.6, -6.7), 0.75, 0.9, JADE)
		end)
		local mouthFX = B:block(jaw, v(1.6, 0.6, 1.0), hcf(0, 11.0, -6.0), MAIN, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFX, "burst", { name = "ShoutBurst", color = { "#ffffff", MINT }, size = { 0.6, 0.4, 0 } })

		------------------------------------------------------------------
		-- RAPTORIAL SCYTHE ARMS: coxa -> femur -> scythe blade (3 bones)
		------------------------------------------------------------------
		B:sym(function(side)
			local SH, EL, WR = v(1.7, 9.6, -2.8), v(2.9, 7.3, -5.4), v(3.9, 10.4, -7.0)
			local arm = B:bone("Arm" .. side, "Chest", SH)
			B:block(arm, v(1.6, 1.6, 2.0), cf(2.05, 9.7, -2.8), DARK) -- pauldron
			B:block(arm, v(1.0, 0.5, 1.5), cf(2.05, 10.75, -2.8), GOLD)
			beam(arm, v(2.05, 9.5, -3.0), EL, 1.5, 1.5, MAIN)

			local fore = B:bone("Fore" .. side, "Arm" .. side, EL)
			B:block(fore, v(1.8, 1.8, 1.8), CFrame.new(EL), DARK) -- elbow cap
			beam(fore, EL, WR, 1.8, 1.5, MAIN)
			beam(fore, EL + v(0.55, 0.4, 0.15), WR + v(0.55, -0.4, 0.15), 0.45, 1.0, DARK)
			B:block(fore, v(1.95, 0.45, 1.65), CFrame.new(EL:Lerp(WR, 0.62)) * P.ang(-21, 0, -11), GOLD) -- femur band

			local scy = B:bone("Scythe" .. side, "Fore" .. side, WR)
			B:block(scy, v(1.7, 1.5, 1.7), CFrame.new(WR), DARK) -- wrist guard
			B:block(scy, v(1.85, 0.45, 1.85), CFrame.new(WR + v(0, 0.35, 0)), GOLD)
			-- blade frame: local -Y runs down the blade, +X is the convex back
			local fr = CFrame.new(WR) * P.ang(-6, -40, 0)
			local rows = {
				{ -1.15, 0.6, 2.0 },
				{ -2.4, 1.45, 2.5 },
				{ -3.65, 2.1, 2.6 },
				{ -4.9, 2.35, 2.3 },
				{ -6.15, 2.05, 1.8 },
			}
			for i, r in rows do
				local y, x, w = r[1], r[2], r[3]
				B:block(scy, v(w, 1.3, 0.7), fr * CFrame.new(x, y, 0), JADE)
				if i >= 2 then
					B:block(scy, v(0.18, 1.1, 0.46), fr * CFrame.new(x - w / 2 - 0.07, y, 0), MINT, NEON)
				end
				if i >= 2 and i <= 4 then -- serrated spines on the cutting edge
					local a = (fr * CFrame.new(x - w / 2 + 0.1, y + 0.25, 0)).Position
					local b = (fr * CFrame.new(x - w / 2 - 0.75, y - 0.45, 0)).Position
					spike(scy, a, b, 0.4, 0.55, WHITE, { up = fr.XVector * 0.64 - fr.YVector * 0.77 })
				end
				if i <= 4 then
					B:block(scy, v(0.4, 1.3, 0.8), fr * CFrame.new(x + w / 2 + 0.15, y, 0), GOLD)
				end
			end
			spike(scy, (fr * CFrame.new(1.8, -6.7, 0)).Position, (fr * CFrame.new(0.0, -8.9, 0)).Position, 0.7, 1.4, JADE, { up = fr.XVector })
			B:trail(scy, (fr * CFrame.new(2.4, -4.6, 0)).Position, (fr * CFrame.new(0.1, -8.6, 0)).Position, {
				name = "BladeTrail" .. side,
				color = { MINT, "#ffffff" },
				life = 0.25,
				trans = { 0.4, 1 },
				light = 0.7,
			})
		end)

		------------------------------------------------------------------
		-- WALKING LEGS: two pairs, femur + shin bones, chunky gold knees
		------------------------------------------------------------------
		local legs = {
			{ "M", v(1.9, 5.4, -0.6), v(5.2, 7.6, -1.6), v(6.2, 0.0, -3.0) },
			{ "B", v(1.9, 5.4, 2.6), v(5.2, 7.4, 4.8), v(6.4, 0.0, 7.2) },
		}
		B:sym(function(side)
			for _, lg in legs do
				local id, hip, knee, foot = lg[1], lg[2], lg[3], lg[4]
				local leg = B:bone("Leg" .. id .. side, "Thorax", hip)
				B:block(leg, v(1.8, 1.8, 1.8), CFrame.new(hip), DEEP)
				beam(leg, hip, knee, 1.8, 1.7, DARK)
				local shin = B:bone("Shin" .. id .. side, "Leg" .. id .. side, knee)
				B:block(shin, v(2.1, 2.0, 2.1), CFrame.new(knee), DEEP)
				B:block(shin, v(2.2, 0.4, 2.2), CFrame.new(knee + v(0, 0.2, 0)), GOLD)
				beam(shin, knee, foot + v(0, 0.9, 0), 1.6, 1.5, DEEP)
				local mid = knee:Lerp(foot, 0.4)
				spike(shin, mid + v(0.2, 0, 0.5), mid + v(0.6, -0.9, 1.6), 0.45, 0.5, JADE)
				B:block(shin, v(2.2, 1.0, 2.4), CFrame.new(foot + v(0, 0.5, -0.1)), "#0f4d2b")
				for k = -1, 1, 2 do
					B:wedge(shin, v(0.65, 0.7, 1.0), CFrame.new(foot + v(k * 0.6, 0.35, -1.8)), JADE)
				end
			end
		end)

		------------------------------------------------------------------
		-- ABDOMEN: 4 segments with pale belly plates and gold rings
		------------------------------------------------------------------
		local seg = {
			{ v(0, 5.9, 3.5), v(4.4, 3.2, 3.0), 5.8, 5.0 },
			{ v(0, 6.0, 6.4), v(5.0, 3.4, 3.0), 6.0, 7.9 },
			{ v(0, 6.2, 9.3), v(4.2, 3.0, 2.8), 6.3, 10.7 },
			{ v(0, 6.5, 12.0), v(3.0, 2.4, 2.6), 6.8, 13.2 },
		}
		local parent = "Thorax"
		for i, s in seg do
			local name = "Abd" .. i
			local b = B:bone(name, parent, s[1])
			local sz, y, z = s[2], s[3], s[4]
			B:block(b, sz, cf(0, y, z), MAIN)
			B:block(b, v(sz.X - 0.8, 0.4, sz.Z - 0.5), cf(0, y - sz.Y / 2 - 0.15, z), i % 2 == 0 and JADE2 or JADE)
			B:block(b, v(sz.X + 0.1, sz.Y - 0.6, 0.4), cf(0, y - 0.25, z + sz.Z / 2 - 0.25), i == 4 and DARK or GOLD)
			B:sym(function()
				B:block(b, v(0.2, sz.Y - 1.0, sz.Z - 0.9), cf(sz.X / 2 + 0.05, y - 0.1, z - 0.15), DEEP)
			end)
			parent = name
		end
		-- tail tip + cerci with mint tips
		local abd4 = B.bones.Abd4
		B:block(abd4, v(1.8, 1.6, 1.2), cf(0, 7.3, 14.9), DARK)
		B:sym(function()
			spike(abd4, v(0.5, 7.6, 15.2), v(1.1, 8.8, 16.8), 0.55, 0.55, JADE)
			B:gem(abd4, v(0.45, 0.45, 0.45), cf(1.15, 8.85, 16.9), MINT)
		end)

		------------------------------------------------------------------
		-- WINGS: folded flat membranes over the abdomen
		------------------------------------------------------------------
		B:sym(function(side)
			local w = B:bone("Wing" .. side, "Thorax", v(0.4, 8.2, 0.8))
			-- planar membrane: slight roof slope sideways, tips rising toward the back
			local function y(x, z) return 8.4 - 0.15 * x + 0.09 * math.max(0, z - 4) end
			local function wp(x, z, dy) return v(x, y(x, z) + (dy or 0), z) end
			local pts = {
				wp(0.25, 0.6),
				wp(2.0, 1.2),
				wp(3.1, 4.5),
				wp(3.0, 9.5),
				wp(2.0, 13.4),
				wp(0.25, 14.0),
			}
			B:poly(w, pts, 0.35, WING)
			-- veins + gold leading edge + small mint spots
			local function vein(x0, z0, x1, z1, col, wd)
				local a, b = wp(x0, z0, 0.2), wp(x1, z1, 0.2)
				beam(w, a, b, wd or 0.25, 0.14, col, { up = (wp(0, 5) - wp(1, 5)):Cross(wp(0, 6) - wp(0, 5)) })
			end
			vein(0.45, 0.9, 0.45, 13.6, DARK, 0.4)
			vein(1.1, 1.3, 1.35, 12.9, DARK)
			vein(2.0, 1.6, 2.35, 11.8, DARK)
			vein(3.1, 4.4, 3.0, 9.6, GOLD, 0.4)
			B:block(w, v(0.55, 0.14, 0.55), CFrame.new(wp(1.7, 7.0, 0.2)) * P.ang(-5, 0, -8.5), MINT, NEON)
			B:block(w, v(0.45, 0.14, 0.45), CFrame.new(wp(1.75, 10.0, 0.2)) * P.ang(-5, 0, -8.5), MINT, NEON)
			B:trail(w, wp(2.0, 13.4), wp(3.0, 9.5), { name = "WingTrail" .. side, color = { "#ffffff", MINT }, life = 0.15, trans = { 0.6, 1 } })
		end)

		------------------------------------------------------------------
		-- FLOATING VOXEL CUBES orbiting the mantis
		------------------------------------------------------------------
		-- they hover beside / behind the body and sway (never through the head or blades)
		local orbit = B:bone("Orbit", "Root", v(0, 9, 4))
		local spots = {
			{ 9.0, 11.0, 2.5, 1.6, MAIN },
			{ -9.2, 8.0, 4.5, 1.3, JADE },
			{ 6.5, 5.5, 12.5, 1.2, GOLD },
			{ -7.0, 14.0, 10.5, 1.5, MAIN },
		}
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local s = p[4]
			B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), p[5])
			B:block(ob, v(s + 0.1, s * 0.22, s + 0.1), cf(p[1], p[2], p[3]), MINT, NEON)
		end

		------------------------------------------------------------------
		-- SIGNATURE VFX (hidden until the Twin Crescent move)
		------------------------------------------------------------------
		local slash = B:bone("SlashFX", "Root", v(0, 10, -10))
		-- crossing crescents (an "X" of wind blades) + a wide horizontal one
		local function crescent(prefix, a, b, bow, n, width)
			local pts = {}
			for i = 0, n do
				local f = i / n
				local p = a:Lerp(b, f)
				local perp = v(-(b - a).Y, (b - a).X, 0).Unit
				table.insert(pts, p + perp * bow * math.sin(math.pi * f))
			end
			for i = 1, n do
				local f = (i - 0.5) / n
				local wd = width * (0.35 + 0.65 * math.sin(math.pi * f))
				beam(slash, pts[i], pts[i + 1] + (pts[i + 1] - pts[i]).Unit * 0.3, wd, 0.3, MINT, { mat = "Neon", tr = 1, name = prefix .. i })
			end
		end
		crescent("SlashA", v(-5, 13.8, -10.5), v(5, 3.8, -10.5), 1.6, 5, 0.7)
		crescent("SlashB", v(5, 13.8, -10.8), v(-5, 3.8, -10.8), -1.6, 5, 0.7)
		crescent("SlashC", v(-7, 9.5, -9.5), v(7, 9.5, -9.5), -2.0, 5, 0.6)
		local core = B:block(slash, v(1, 1, 1), cf(0, 10, -10.6), MINT, { tr = 1, name = "SlashCore" })
		B:emitter(core, "burst", { name = "SlashBurst", color = { "#ffffff", MINT }, size = { 1.0, 0.6, 0 } })
		B:light(core, { name = "SlashLight", color = MINT, brightness = 0, range = 16 })

		-- whirlwind ring revealed during the spinning flourish
		local whirl = B:bone("Whirl", "Root", v(0, 9.5, 1))
		for i = 0, 11 do
			local a = i / 12 * math.pi * 2
			local p = v(math.sin(a) * 7.5, 9.5 + (i % 2) * 0.5, 1 + math.cos(a) * 7.5)
			B:block(whirl, v(3.2, 0.6, 0.3), CFrame.new(p) * P.ang(0, math.deg(a) + 90, (i % 2) * 14 - 7), i % 3 == 0 and "#ffffff" or MINT, { mat = "Neon", tr = 1, name = "Whirl" .. (i + 1) })
		end
		local spinFX = B:block(whirl, v(8, 1, 8), cf(0, 9.5, 1), MAIN, { tr = 1, name = "SpinFX" })
		B:emitter(spinFX, "burst", { name = "SpinBurst", color = { "#ffffff", MINT, GOLD }, size = { 0.8, 0.5, 0 } })
	end,
}
