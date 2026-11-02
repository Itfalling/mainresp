-- SolarSystem "Solar System" (Landmark, Space).
-- The whole solar system as a stud-built voxel orrery floating above the
-- ground: the Sun (stepped voxel sphere, hot neon spots, flickering stepped
-- prominence arcs, glow), the 8 planets in order with their famous details,
-- the Moon, the 4 Galilean moons, Titan, Saturn's wide rings, Uranus' faint
-- rings, the asteroid belt, Pluto on its tilted eccentric orbit and a comet on
-- a long ellipse whose tail always points away from the Sun.
-- Everything is built from studded Plastic blocks only (planets are stacked
-- stepped slabs), every orbit has a faint dashed path ring.
--
-- Rig (see motion.luau, M.Cycle = 600 s):
--   Orbit<P> (Root, pivot = Sun centre)  ->  Carrier<P> (counter-rotated so
--   the axial tilt stays fixed in space)  ->  <P> (spin about the tilted axis)
--   moons hang off the carriers; Pluto / comet ride translated path bones in
--   their own tilted orbital planes (Kepler motion).
--
-- NOTE: every orbital constant below is mirrored in motion.luau.
return {
	DisplayName = "Solar System",
	Rarity = "Landmark",
	Element = "Space",
	PreviewFps = 2,
	NeonCap = 12,
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local CF, V3 = P.CFrame, P.Vector3
		local rad = math.rad
		local SY = 38 -- ecliptic plane height
		local C = v(0, SY, 0) -- the Sun's centre
		local CC = CFrame.new(C)

		-- deterministic pseudo random
		local seed = 12345
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end

		-- position on a circle of radius r at angle psi (deg, CCW seen from +Y)
		local function onCircle(r, psi)
			local a = rad(psi)
			return v(r * math.cos(a), 0, -r * math.sin(a))
		end
		-- tilt rotation: the planet's +Y axis tipped by `tilt` deg toward direction `dir`
		local function tiltRot(tilt, dir)
			return ang(0, dir, 0) * ang(0, 0, tilt)
		end

		------------------------------------------------------------------
		-- voxel sphere: stacked stepped-octagon slabs along the frame's Y
		------------------------------------------------------------------
		local W, S = 0.42, 0.72 -- cross half-width / square half-size (fraction of r)
		-- colorFn(k, n, piece) -> color   piece: "x" | "z" | "sq"
		local function vsphere(bone, F, R, n, colorFn, opts, sqOpts)
			local h = 2 * R / n
			local layers = {}
			for k = 1, n do
				local y = -R + h * (k - 0.5)
				local r = math.sqrt(math.max(0, R * R - y * y)) + h * 0.16
				local c = F * CFrame.new(0, y, 0)
				B:block(bone, v(2 * r, h, 2 * W * r), c, colorFn(k, n, "x"), opts)
				B:block(bone, v(2 * W * r, h - 0.04, 2 * r), c, colorFn(k, n, "z"), opts)
				B:block(bone, v(2 * S * r, h - 0.08, 2 * S * r), c, colorFn(k, n, "sq"), sqOpts and sqOpts(k) or opts)
				layers[k] = { y = y, r = r, h = h }
			end
			return layers
		end
		-- a colored patch laid on the outside of layer k.
		-- side 0..3 = +X, -Z, -X, +Z (CCW quarter turns); u0..u1 lateral span
		-- as a fraction of the layer radius (stay inside +-W for the bar face,
		-- or inside W..S for the inset square face).
		local function patch(bone, F, L, k, side, u0, u1, color, opts, dy, hk)
			local ly = L[k]
			local far = math.max(math.abs(u0), math.abs(u1))
			local face = far <= W + 1e-3 and ly.r or S * ly.r
			local depth = 0.3
			local c = F * CFrame.Angles(0, side * math.pi / 2, 0)
				* CFrame.new(face + 0.08 - depth / 2, ly.y + (dy or 0), -(u0 + u1) / 2 * ly.r)
			return B:block(bone, v(depth, ly.h * (hk or 1) + 0.06, math.abs(u1 - u0) * ly.r), c, color, opts)
		end
		-- a cap patch on the top (+1) or bottom (-1) face of layer k
		local function cap(bone, F, L, k, sgn, sx, sz, ox, oz, color, opts)
			local ly = L[k]
			local c = F * CFrame.new(ox * ly.r, ly.y + sgn * (ly.h / 2 + 0.04), oz * ly.r)
			return B:block(bone, v(sx * ly.r, 0.2, sz * ly.r), c, color, opts)
		end
		-- small moon: 3 crossed slabs + core
		local function mini(bone, pos, s, c1, c2, c3)
			local c = CFrame.new(pos)
			B:block(bone, v(s * 0.78, s * 0.78, s * 0.78), c, c1)
			B:block(bone, v(s, s * 0.5, s * 0.5), c, c2)
			B:block(bone, v(s * 0.5, s, s * 0.5), c, c3 or c1)
			B:block(bone, v(s * 0.5, s * 0.5, s), c, c1)
			return c
		end
		-- layer colors from a band list (top -> bottom), piece tint per band
		local function bands(list)
			return function(k, n, piece)
				local b = list[n - k + 1]
				if type(b) == "table" then
					return piece == "sq" and (b[2] or b[1]) or (piece == "z" and (b[3] or b[1]) or b[1])
				end
				return b
			end
		end

		------------------------------------------------------------------
		-- orbit path rings (faint dashed blocks)
		------------------------------------------------------------------
		local DASH = "#e6f3ff"
		local function orbitRing(r, spacing)
			local n = math.max(16, math.floor(2 * math.pi * r / spacing + 0.5))
			local len = 2 * math.pi * r / n * 0.45
			for i = 0, n - 1 do
				local a = i / n * 2 * math.pi
				B:block("Root", v(0.3, 0.12, len), CC * CFrame.Angles(0, a, 0) * CFrame.new(r, 0, 0), DASH, { tr = 0.5 })
			end
		end

		------------------------------------------------------------------
		-- THE SUN
		------------------------------------------------------------------
		local sun = B:bone("Sun", "Root", C)
		local SUN_R, SUN_N = 9, 9
		local SY_L, SYEL, SORA, SRO, SRO_D = "#fff27a", "#ffd23a", "#ff9f1c", "#ff6a1a", "#e8461b"
		local SYW = "#fffbd0"
		local sunBands = {
			{ SRO, SRO_D }, { SORA, SRO }, { SYEL, SORA }, { SY_L, SYEL }, { SYW, SY_L },
			{ SY_L, SYEL }, { SYEL, SORA }, { SORA, SRO }, { SRO, SRO_D },
		}
		-- the inset square of the middle layers is a hot neon core glowing in the step notches
		local coreCol = { [3] = "#ffb22e", [4] = "#ffd447", [5] = "#fff08a", [6] = "#ffd447", [7] = "#ffb22e" }
		local sunColor = function(k, n, piece)
			local b = sunBands[n - k + 1]
			return piece == "sq" and b[2] or b[1]
		end
		local SL = vsphere(sun, CC, SUN_R, SUN_N, sunColor)
		-- hot core glowing out of the step notches (staggered layer by layer)
		for k = 3, 7 do
			local ly = SL[k]
			for q = 0, 3 do
				local qc = CC * CFrame.Angles(0, q * math.pi / 2, 0)
				local nx, nz = 0.8, 0.53
				if k % 2 == 0 then
					nx, nz = 0.53, 0.8
				end
				B:block(sun, v((k % 2 == 0 and 0.22 or 0.17) * ly.r, ly.h - 0.12, (k % 2 == 0 and 0.17 or 0.22) * ly.r), qc * CFrame.new(nx * ly.r, ly.y, nz * ly.r), coreCol[k], { mat = "Neon" })
			end
		end
		-- red-orange polar caps and stepped rims
		cap(sun, CC, SL, SUN_N, 1, 0.9, 0.9, 0, 0, SRO)
		cap(sun, CC, SL, 1, -1, 0.9, 0.9, 0, 0, SRO_D)
		-- surface texture: darker red-orange cells and hot neon spots
		local HOT, HOT2 = "#fff7b8", "#ffc23a"
		local hotN = 0
		local function hot(k, side, u0, u1, col)
			hotN += 1
			patch(sun, CC, SL, k, side, u0, u1, col or HOT, { mat = "Neon", name = "Hot" .. hotN }, 0, 0.55)
		end
		for _, d in { { 3, 0, -0.3, 0.05 }, { 6, 1, 0.1, 0.38 }, { 4, 2, -0.38, -0.08 }, { 7, 3, -0.2, 0.2 }, { 5, 1, -0.4, -0.15 }, { 2, 3, 0.05, 0.38 } } do
			patch(sun, CC, SL, d[1], d[2], d[3], d[4], SRO, nil, 0, 0.8)
		end
		for _, d in { { 4, 0, 0.12, 0.36 }, { 5, 3, -0.38, -0.12 }, { 6, 2, 0.05, 0.3 }, { 3, 1, -0.32, -0.04 }, { 7, 0, -0.38, -0.15 }, { 5, 2, -0.36, -0.1 } } do
			hot(d[1], d[2], d[3], d[4], (d[1] % 2 == 0) and HOT or HOT2)
		end
		-- hot spots on the inset square faces (corner glow)
		for side = 0, 3 do
			hot(side % 2 == 0 and 5 or 4, side, 0.48, 0.66, HOT2)
		end

		-- prominences: stepped neon arcs rising off the surface (flicker in motion)
		local FL1, FL2, FL3 = "#ff4412", "#ff7418", "#ffc22a"
		local flares = {
			-- side, layer centre y, lateral axis ("u" sideways or "y" vertical), span, height, blocks
			{ side = 0, y = 1.0, axis = "u", span = 3.4, hgt = 5.0, n = 9 },
			{ side = 1, y = -1.5, axis = "y", span = 3.2, hgt = 4.4, n = 9 },
			{ side = 2, y = 2.5, axis = "u", span = 3.0, hgt = 4.2, n = 8 },
			{ side = 3, y = -1.0, axis = "u", span = 3.6, hgt = 5.2, n = 9 },
		}
		local FACE = 8.6
		for i, f in flares do
			local base = CC * CFrame.Angles(0, f.side * math.pi / 2, 0)
			for j = 1, f.n do
				local s = (j - 1) / (f.n - 1)
				local phi = math.pi * s
				local out = FACE + f.hgt * math.sin(phi)
				local lat = -f.span * math.cos(phi)
				local p = f.axis == "u" and v(out, f.y + 0.5 * math.sin(phi), lat) or v(out, f.y + lat, 0.6 * math.sin(phi))
				local sz = 1.15 - 0.3 * math.sin(phi)
				local col = (j == 1 or j == f.n) and FL3 or (j % 2 == 0 and FL1 or FL2)
				B:block(sun, v(sz, sz, sz), base * CFrame.new(p), col, { mat = "Neon", name = ("Flare%d_%d"):format(i, j) })
			end
		end

		-- glow, light, flames, sparkles
		local core = B:block(sun, v(17, 17, 17), CC, SYEL, { tr = 1, name = "SunCore" })
		B:light(core, { color = "#ffd27a", brightness = 1.5, range = 60, name = "SunLight" })
		B:emitter(core, "glow", { color = { "#fff2a0", "#ff9f1c" }, rate = 3, size = { 7, 11, 5 }, life = { 1.5, 2.5 }, name = "SunGlow" })
		B:emitter(core, "fire", { color = { "#fff27a", "#ff7a1a", "#e8461b" }, rate = 30, size = { 2.4, 1.6, 0 }, speed = { 2, 4 }, spread = 180, accel = { 0, 0, 0 }, life = { 0.5, 0.9 }, name = "SunFire" })
		local sparkPart = B:block("Root", v(26, 22, 26), CC, SYEL, { tr = 1, name = "SunSparkBox" })
		B:emitter(sparkPart, "sparkle", { color = { "#fffbe0", "#ffd23a" }, rate = 12, size = { 0.2, 0.7, 0 }, speed = { 0.2, 0.8 }, name = "SunSparkle" })

		------------------------------------------------------------------
		-- planets
		------------------------------------------------------------------
		-- name, orbit radius, start angle psi0, tilt, tilt direction
		local function planetRig(name, r, psi0, tilt, dir)
			local pos = C + onCircle(r, psi0)
			local orbit = B:bone("Orbit" .. name, "Root", C)
			local carrier = B:bone("Carrier" .. name, orbit, pos)
			local spin = B:bone(name, carrier, pos)
			local F = CFrame.new(pos) * tiltRot(tilt or 0, dir or 0)
			return spin, carrier, F, pos
		end

		---------------------------------------------------------- Mercury
		do
			local R = 1.05
			local sp, _, F = planetRig("Mercury", 15, 125, 0, 0)
			local L = vsphere(sp, F, R, 3, bands({ { "#c9c4bd", "#a19c96" }, { "#a8a39d", "#8e8a85", "#b9b4ad" }, { "#8e8a85", "#76726d" } }))
			-- craters: dark pits with light rims
			patch(sp, F, L, 2, 0, -0.3, 0.1, "#5f5b57")
			patch(sp, F, L, 2, 2, -0.05, 0.35, "#66625e")
			patch(sp, F, L, 1, 1, -0.3, 0.3, "#5f5b57", nil, 0, 0.7)
			patch(sp, F, L, 2, 3, -0.3, 0.0, "#d9d4cc", nil, 0.12, 0.45)
			cap(sp, F, L, 3, 1, 0.45, 0.45, 0.15, -0.1, "#77736e")
		end

		------------------------------------------------------------ Venus
		do
			local R = 1.9
			local sp, _, F = planetRig("Venus", 20, 235, 0, 0)
			local L = vsphere(sp, F, R, 5, bands({
				{ "#fff6d8", "#f3e2b0" }, { "#f6dfa0", "#e8c885", "#fff0c2" }, { "#fff0c2", "#f3d995" },
				{ "#e8c885", "#d9b46a", "#f6dfa0" }, { "#f3d995", "#d9b46a" },
			}))
			-- swirling cloud streaks
			patch(sp, F, L, 2, 0, -0.42, 0.2, "#fffaf0", nil, 0.1, 0.45)
			patch(sp, F, L, 3, 1, -0.1, 0.42, "#d9b46a", nil, -0.15, 0.45)
			patch(sp, F, L, 4, 2, -0.35, 0.3, "#fff6dc", nil, 0, 0.5)
			patch(sp, F, L, 3, 3, -0.42, 0.0, "#fffaf0", nil, 0.15, 0.4)
			patch(sp, F, L, 2, 2, 0.45, 0.68, "#d9b46a", nil, 0, 0.6)
		end

		------------------------------------------------------------ Earth
		do
			local R = 2.0
			local sp, carrier, F, pos = planetRig("Earth", 26, 25, 23.4, 0)
			local OC, OC_D, OC_L = "#2f8cff", "#1d62d6", "#5fb4ff"
			local L = vsphere(sp, F, R, 5, bands({
				{ OC_L, OC }, { OC_L, OC, OC_L }, { OC, OC_D, OC }, { OC_D, OC, OC_L }, { OC, OC_D },
			}))
			local G, G_D, BR, CL = "#4fcf5a", "#2f9e40", "#b07a43", "#ffffff"
			-- continents (green + brown deserts) on every side
			patch(sp, F, L, 3, 0, -0.42, 0.3, G)
			patch(sp, F, L, 2, 0, -0.42, 0.3, G_D)
			patch(sp, F, L, 2, 1, 0.46, 0.7, G)
			patch(sp, F, L, 4, 1, -0.42, 0.1, G_D)
			patch(sp, F, L, 4, 0, -0.1, 0.25, BR, nil, 0, 0.8)
			patch(sp, F, L, 3, 1, 0.0, 0.42, BR)
			patch(sp, F, L, 2, 1, -0.2, 0.42, G)
			patch(sp, F, L, 4, 2, -0.42, 0.0, G)
			patch(sp, F, L, 3, 2, -0.2, 0.2, G_D, nil, 0, 0.7)
			patch(sp, F, L, 3, 3, -0.15, 0.25, G)
			patch(sp, F, L, 2, 3, -0.4, 0.0, G_D)
			patch(sp, F, L, 3, 2, 0.46, 0.7, G)
			patch(sp, F, L, 3, 0, 0.46, 0.7, G_D)
			-- white clouds
			patch(sp, F, L, 3, 1, -0.42, -0.1, CL, nil, 0.28, 0.22)
			patch(sp, F, L, 4, 3, 0.05, 0.42, CL, nil, 0.2, 0.22)
			-- ice caps (raised)
			cap(sp, F, L, 5, 1, 1.25, 1.25, 0, 0, "#ffffff")
			cap(sp, F, L, 1, -1, 1.15, 1.15, 0, 0, "#f2f9ff")

			-- the Moon (tidally locked: rides its orbit bone, never spins on its own)
			local moonOrbit = B:bone("MoonOrbit", carrier, pos)
			local mp = pos + onCircle(3.1, 200)
			local mc = mini(moonOrbit, mp, 1.1, "#cfcfd6", "#b3b3bb", "#e2e2e8")
			-- dark maria on the near side (always faces Earth)
			local toward = (pos - mp).Unit
			B:block(moonOrbit, v(0.3, 0.3, 0.3), CFrame.new(mp + toward * 0.45 + v(0, 0.12, 0)), "#7b7b86")
			B:block(moonOrbit, v(0.22, 0.22, 0.22), CFrame.new(mp + toward * 0.43 + v(0.1, -0.18, 0.08)), "#8a8a94")
		end

		------------------------------------------------------------- Mars
		do
			local R = 1.4
			local sp, _, F = planetRig("Mars", 32, 160, 25, 200)
			local RD, RD_D, RD_L = "#e0603a", "#b8442a", "#f08050"
			local L = vsphere(sp, F, R, 5, bands({
				{ "#ffffff", "#f2ece8" }, { RD_L, RD, RD_L }, { RD, RD_D, RD_L }, { RD_D, RD, RD }, { RD, RD_D },
			}))
			local DK = "#7a2e1e"
			patch(sp, F, L, 3, 1, -0.4, 0.05, DK)
			patch(sp, F, L, 2, 2, -0.1, 0.4, DK, nil, 0, 0.7)
			patch(sp, F, L, 4, 3, -0.3, 0.25, DK)
			patch(sp, F, L, 3, 3, 0.1, 0.42, "#a33b22")
			patch(sp, F, L, 3, 2, 0.46, 0.7, DK, nil, 0, 0.7)
			-- Olympus Mons: stepped volcano bump on the +X face
			local ly = L[3]
			local base = F * CFrame.new(ly.r, 0.15, 0)
			B:block(sp, v(0.5, 0.75, 0.75), base * CFrame.new(0.1, 0, 0), "#d9714a")
			B:block(sp, v(0.4, 0.45, 0.45), base * CFrame.new(0.38, 0, 0), "#f08a5c")
			B:block(sp, v(0.2, 0.2, 0.2), base * CFrame.new(0.6, 0, 0), "#9c3a22")
			-- white polar cap (raised)
			cap(sp, F, L, 5, 1, 1.1, 1.1, 0, 0, "#ffffff")
			cap(sp, F, L, 1, -1, 0.7, 0.7, 0, 0, "#f6f0ec")
		end

		---------------------------------------------------- asteroid belt
		do
			local ROCK = { "#8d8984", "#6e6a66", "#a8a39c", "#8a6a4f", "#6f5541", "#5a544f" }
			for bi, spec in { { "BeltInner", 36.5, 39.0, 26 }, { "BeltOuter", 39.2, 41.8, 22 } } do
				local bone = B:bone(spec[1], "Root", C)
				for i = 1, spec[4] do
					local a = (i - 1 + rnd() * 0.7) / spec[4] * 360
					local r = spec[2] + rnd() * (spec[3] - spec[2])
					local p = C + onCircle(r, a) + v(0, (rnd() - 0.5) * 1.6, 0)
					local s = 0.55 + rnd() * 0.75
					if i % 7 == 3 then
						s += 0.5
					end
					local col = ROCK[1 + math.floor(rnd() * #ROCK)]
					local yaw = rnd() * 90
					B:block(bone, v(s, s * 0.8, s * 0.9), CFrame.new(p) * ang(rnd() * 20, yaw, rnd() * 20), col)
					if s > 0.8 then
						local col2 = ROCK[1 + math.floor(rnd() * #ROCK)]
						B:block(bone, v(s * 0.55, s * 0.5, s * 0.6), CFrame.new(p + v((rnd() - 0.5) * s * 0.6, s * 0.4, (rnd() - 0.5) * s * 0.6)) * ang(0, yaw + 20, 0), col2)
					end
				end
			end
		end

		---------------------------------------------------------- Jupiter
		do
			local R = 4.2
			local sp, carrier, F, pos = planetRig("Jupiter", 51, 95, 0, 0)
			local CR, TN, OR, BRN, LT = "#f6e3bf", "#e8b77d", "#d9853f", "#9c5a32", "#fff3dc"
			local L = vsphere(sp, F, R, 9, bands({
				{ "#e6d2b0", "#cdb48c" }, { TN, OR }, { CR, TN, LT }, { BRN, "#7e4626", OR }, { LT, CR, LT },
				{ OR, BRN, TN }, { CR, TN, CR }, { TN, OR }, { "#d8c09a", "#b89a72" },
			}))
			-- swirls in the bands
			patch(sp, F, L, 5, 1, -0.42, -0.05, "#e8b77d", nil, 0, 0.35)
			patch(sp, F, L, 6, 3, 0.0, 0.42, "#c96f35", nil, 0, 0.4)
			patch(sp, F, L, 4, 2, -0.42, 0.1, "#fff3dc", nil, 0, 0.35)
			patch(sp, F, L, 6, 0, 0.46, 0.7, "#f6e3bf", nil, 0, 0.4)
			-- the Great Red Spot (southern band, +X face), stepped oval
			local ly = L[4]
			local gs = F * CFrame.new(ly.r, ly.y, -0.2)
			B:block(sp, v(0.32, ly.h * 0.75, 2.0), gs * CFrame.new(0.06, 0, 0), "#d6402a")
			B:block(sp, v(0.3, ly.h * 0.45, 2.5), gs * CFrame.new(0.04, 0, 0), "#e8603a")
			B:block(sp, v(0.3, ly.h * 0.5, 1.0), gs * CFrame.new(0.12, 0, 0), "#b52f22")
			-- Galilean moons (1:2:4 resonance Io:Europa:Ganymede)
			local moons = {
				{ "Io", 5.8, 30, 0.9, "#ffe34d", "#ff9f2a", "#fff27a" },
				{ "Europa", 6.9, 150, 0.82, "#f3ead8", "#c8a27a", "#fffaf0" },
				{ "Ganymede", 8.0, 260, 1.1, "#a39580", "#7d6f5c", "#c2b6a2" },
				{ "Callisto", 9.2, 330, 1.0, "#5e5348", "#3f372f", "#9a8e80" },
			}
			for _, m in moons do
				local mb = B:bone(m[1], carrier, pos)
				mini(mb, pos + onCircle(m[2], m[3]), m[4], m[5], m[6], m[7])
			end
		end

		----------------------------------------------------------- Saturn
		do
			local R = 3.5
			local TILT, DIR = 26.7, 150
			local sp, carrier, F, pos = planetRig("Saturn", 70, 40, TILT, DIR)
			local L = vsphere(sp, F, R, 7, bands({
				{ "#f2c95e", "#d9a43a" }, { "#ffe08a", "#f5c35a" }, { "#e09a32", "#c47f22", "#eaa942" }, { "#fff1c2", "#ffe08a" },
				{ "#eaa942", "#d08a2a", "#f5c35a" }, { "#ffe08a", "#f2c95e" }, { "#d9a43a", "#b8862a" },
			}))
			patch(sp, F, L, 4, 1, -0.35, 0.1, "#f6dc9a", nil, 0, 0.4)
			patch(sp, F, L, 3, 3, -0.1, 0.4, "#c99a46", nil, 0, 0.4)
			-- the famous rings (on the carrier, in the tilted equatorial plane)
			local RF = F
			B:ring(carrier, RF, 4.3, 22, v(1.3, 0.16, 0.6), "#cdb68a", { tr = 0.35 })
			local bRing = B:ring(carrier, RF, 5.4, 28, v(1.32, 0.24, 1.3), "#f3dc9c")
			for i, p in bRing do
				if i % 2 == 0 then
					p.Color = P.color("#e8c97f")
				end
			end
			-- Cassini division (gap) then the A ring
			local aRing = B:ring(carrier, RF, 6.95, 34, v(1.38, 0.2, 0.85), "#d9b56a")
			for i, p in aRing do
				if i % 3 == 0 then
					p.Color = P.color("#c9a35a")
				end
			end
			-- Titan orbits in Saturn's equatorial plane
			local tb = B:bone("Titan", carrier, CFrame.new(pos) * tiltRot(TILT, DIR))
			local tp = (CFrame.new(pos) * tiltRot(TILT, DIR) * CFrame.new(onCircle(9.2, 110))).Position
			mini(tb, tp, 1.05, "#f2a23a", "#d9822a", "#ffc266")
		end

		----------------------------------------------------------- Uranus
		do
			local R = 2.5
			local TILT, DIR = 98, 20
			local sp, carrier, F = planetRig("Uranus", 84, 205, TILT, DIR)
			local L = vsphere(sp, F, R, 5, bands({
				{ "#c4fbff", "#9df4ff" }, { "#86efff", "#5fe3f7", "#a6f6ff" }, { "#6ae8fb", "#45d6ee" },
				{ "#86efff", "#5fe3f7" }, { "#5ad9ef", "#3cc6e0" },
			}))
			patch(sp, F, L, 3, 0, -0.3, 0.3, "#d8fdff", nil, 0, 0.4)
			patch(sp, F, L, 3, 2, -0.3, 0.3, "#d8fdff", nil, 0, 0.4)
			-- faint thin rings around the (sideways) equator
			B:ring(carrier, F, 3.45, 20, v(1.2, 0.12, 0.2), "#dff6fa", { tr = 0.4 })
			B:ring(carrier, F, 3.95, 22, v(1.2, 0.12, 0.2), "#c8ecf2", { tr = 0.5 })
		end

		---------------------------------------------------------- Neptune
		do
			local R = 2.4
			local sp, _, F = planetRig("Neptune", 95, 300, 28, 250)
			local NB, NB_D, NB_L = "#3f6ff0", "#2448c8", "#6a94ff"
			local L = vsphere(sp, F, R, 5, bands({
				{ NB_L, NB }, { NB, NB_D, NB_L }, { "#5a86ff", NB }, { NB_D, "#1c3aa8", NB }, { NB, NB_D },
			}))
			-- Great Dark Spot + white streak clouds
			patch(sp, F, L, 4, 0, -0.42, 0.2, "#101c5c", nil, 0, 0.85)
			patch(sp, F, L, 3, 0, -0.42, 0.42, "#ffffff", nil, 0.22, 0.32)
			patch(sp, F, L, 2, 1, -0.3, 0.42, "#ffffff", nil, 0, 0.32)
			patch(sp, F, L, 4, 2, -0.42, 0.3, "#ffffff", nil, 0.1, 0.32)
			patch(sp, F, L, 3, 3, -0.2, 0.42, "#eef3ff", nil, -0.22, 0.32)
			patch(sp, F, L, 3, 2, -0.42, 0.0, "#101c5c", nil, -0.1, 0.6)
			patch(sp, F, L, 3, 1, 0.46, 0.7, "#ffffff", nil, 0.15, 0.32)
		end

		-- planet orbit paths
		for _, r in { 15, 20, 26, 32, 51, 70, 84, 95 } do
			orbitRing(r, r < 40 and 4.8 or 7.2)
		end

		------------------------------------------------------------------
		-- Kepler orbits (Pluto, comet): mirrored in motion.luau
		------------------------------------------------------------------
		local function kepler(M, e)
			M = (M + math.pi) % (2 * math.pi) - math.pi
			local E = M + 0.85 * e * (M >= 0 and 1 or -1)
			for _ = 1, 10 do
				E -= (E - e * math.sin(E) - M) / (1 - e * math.cos(E))
			end
			local nu = 2 * math.atan2(math.sqrt(1 + e) * math.sin(E / 2), math.sqrt(1 - e) * math.cos(E / 2))
			return nu, 1 - e * math.cos(E)
		end
		-- returns in-plane position and polar angle (deg)
		local function orbitPos(o, M)
			local nu, rr = kepler(M, o.e)
			local psi = math.deg(nu) + o.w
			return onCircle(o.a * rr, psi), psi
		end
		local function planeCF(o)
			return CFrame.new(C) * ang(0, o.node, 0) * ang(o.inc, 0, 0)
		end
		local function ellipsePath(o, n, w, col, tr)
			local PF = planeCF(o)
			for i = 0, n - 1 do
				local m0 = (i / n) * 2 * math.pi
				local m1 = ((i + 0.5) / n) * 2 * math.pi
				-- sample by eccentric anomaly so dashes spread evenly along the curve
				local function pt(E)
					local x = o.a * (math.cos(E) - o.e)
					local z = o.a * math.sqrt(1 - o.e * o.e) * math.sin(E)
					local a = rad(o.w)
					-- rotate perihelion direction to psi = w (CCW)
					local px = x * math.cos(a) - z * math.sin(a)
					local pz = x * math.sin(a) + z * math.cos(a)
					return (PF * CFrame.new(px, 0, -pz)).Position
				end
				B:bar("Root", pt(m0), pt(m1), w, 0.12, col, { tr = tr })
			end
		end

		------------------------------------------------------------ Pluto
		local PLUTO = { a = 102, e = 0.25, inc = 17, node = 110, w = 113, M0 = rad(330) }
		do
			local PF = planeCF(PLUTO)
			local path = B:bone("PlutoPath", "Root", PF)
			local p0 = orbitPos(PLUTO, PLUTO.M0)
			local wp = PF * CFrame.new(p0)
			local pl = B:bone("Pluto", path, wp)
			local R = 0.8
			local L = vsphere(pl, wp, R, 3, bands({ { "#e7c9a0", "#d9b68a" }, { "#c99f74", "#b88c62", "#d9b68a" }, { "#9c7452", "#8a6446" } }))
			-- Tombaugh Regio: the cream heart
			local ly = L[2]
			local hc = wp * CFrame.new(ly.r + 0.05, 0, 0)
			B:block(pl, v(0.2, 0.32, 0.26), hc * CFrame.new(0, 0.1, -0.15), "#fff3e6")
			B:block(pl, v(0.2, 0.32, 0.26), hc * CFrame.new(0, 0.1, 0.15), "#fff3e6")
			B:block(pl, v(0.2, 0.26, 0.3), hc * CFrame.new(0, -0.12, 0), "#fff3e6")
			ellipsePath(PLUTO, 64, 0.3, "#f3e6d4", 0.5)
		end

		------------------------------------------------------------ Comet
		local COMET = { a = 80, e = 0.82, inc = 12, node = 200, w = 90, M0 = rad(320) }
		do
			local PF = planeCF(COMET)
			local path = B:bone("CometPath", "Root", PF)
			local p0, psi0 = orbitPos(COMET, COMET.M0)
			local hf = PF * CFrame.new(p0)
			local head = B:bone("Comet", path, hf)
			-- frame whose +X points straight away from the Sun (tail direction)
			local tf = hf * ang(0, psi0, 0)
			B:block(head, v(1.1, 1.1, 1.1), tf, "#bfeaff")
			B:block(head, v(1.4, 0.7, 0.7), tf, "#e6f7ff")
			B:block(head, v(0.7, 1.4, 0.7), tf, "#8fd6ff")
			B:block(head, v(0.7, 0.7, 1.4), tf, "#e6f7ff")
			local nucleus = B:block(head, v(0.8, 0.8, 0.8), tf * CFrame.new(-0.35, 0, 0), "#ffffff", { mat = "Neon", name = "CometCore" })
			B:light(nucleus, { color = "#bff4ff", brightness = 0.9, range = 12, name = "CometLight" })
			-- stepped tail fanning out away from the Sun
			local tail = {
				{ 1.3, 0, 0.9, "#ffffff", 0.0 }, { 2.4, 0, 0.8, "#e6fbff", 0.05 }, { 3.6, 0.15, 0.72, "#bff4ff", 0.15 },
				{ 4.9, -0.15, 0.62, "#9fe8ff", 0.25 }, { 6.2, 0.3, 0.52, "#7fdcff", 0.35 }, { 7.5, -0.3, 0.42, "#7fdcff", 0.45 },
				{ 8.8, 0.45, 0.34, "#a8c8ff", 0.55 }, { 10.0, -0.4, 0.26, "#c8b8ff", 0.62 },
			}
			local last
			for k, t in tail do
				last = B:block(head, v(1.35, t[3], t[3] * 1.6), tf * CFrame.new(t[1], 0, t[2]), t[4], { mat = "Neon", tr = t[5], name = "Tail" .. k })
			end
			-- a wider, fainter dust fan
			for k = 1, 3 do
				local d = 2.5 + k * 2.2
				B:block(head, v(1.6, 0.25, 0.4), tf * CFrame.new(d, 0, 0.55 + k * 0.35), "#fff1d6", { tr = 0.4 + k * 0.1, name = "Dust" .. k })
			end
			B:emitter(last, "sparkle", { color = { "#ffffff", "#9fe8ff" }, rate = 10, size = { 0.2, 0.55, 0 }, speed = { 0.2, 0.6 }, name = "CometDust" })
			local cp = tf.Position
			local up = PF.UpVector
			B:trail(head, cp + up * 0.45, cp - up * 0.45, { color = { "#ffffff", "#7fdcff" }, life = 1.6, width = { 1, 0.2 }, trans = { 0.3, 1 }, name = "CometTrail" })
			ellipsePath(COMET, 48, 0.22, "#d8f2ff", 0.65)
		end
	end,
}
