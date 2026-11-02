-- SolarSystem "Solar System" (Landmark, Space) - compact toy orrery that
-- hovers above a biome.
-- A chunky stud-built Sun (clean stepped voxel sphere: yellow core -> orange
-- -> red-orange rim, glowing equator notches, two counter-rotating stepped
-- corona rings, four chunky flare arcs, an expanding burst ring) with the 8
-- planets packed close together in one flat plane: Mercury, Venus, Earth +
-- Moon, Mars, the asteroid belt, Jupiter + Io/Europa, Saturn + thick rings +
-- Titan, Uranus (on its side, thin ring), Neptune, and a comet on an
-- eccentric orbit. Translucent chunky ring tracks with chase-light glints.
-- Only studded Plastic blocks (+ small Neon accents); planets are stacked
-- stepped slabs with bold 3-tone colour bands.
--
-- Rig (motion.luau, M.Cycle = 60 s):
--   Orbit<P> (Root, pivot = Sun centre) -> Carrier<P> (counter-rotated so the
--   axial tilt stays fixed in space, bobs, carries the trail) -> <P> (spins
--   about its tilted axis). Moons + Saturn's rings hang off the carriers.
--   Comet: CometPath (translated along its Kepler ellipse) -> Comet (turned so
--   the tail points away from the Sun).
--
-- NOTE: start angles / comet constants are mirrored in motion.luau.
return {
	DisplayName = "Solar System",
	Rarity = "Landmark",
	Element = "Space",
	PreviewFps = 10,
	NeonCap = 12,
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local SY = 12 -- orbit plane height
		local C = v(0, SY, 0) -- Sun centre
		local CC = CFrame.new(C)

		local seed = 4242
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		-- point on a circle (psi in degrees, CCW seen from +Y)
		local function onCircle(r, psi)
			local a = rad(psi)
			return v(r * math.cos(a), 0, -r * math.sin(a))
		end
		local function tiltRot(tilt, dir)
			return ang(0, dir, 0) * ang(0, 0, tilt)
		end

		------------------------------------------------------------------
		-- clean stepped voxel sphere: n slabs along the frame's Y, each a
		-- cross of two bars + an inset square (darker tone = rounded shading)
		------------------------------------------------------------------
		local W, S = 0.5, 0.8
		-- bandsList[i] (top -> bottom) = { main, shade[, neonSquare] }
		local function vsphere(bone, F, R, bandsList)
			local n = #bandsList
			local h = 2 * R / n
			local L = {}
			for k = 1, n do
				local y = -R + h * (k - 0.5)
				local r = (math.sqrt(math.max(0, R * R - y * y)) + h * 0.22) * 0.95
				local b = bandsList[n - k + 1]
				local c = F * CFrame.new(0, y, 0)
				B:block(bone, v(2 * r, h, 2 * W * r), c, b[1])
				B:block(bone, v(2 * W * r, h - 0.04, 2 * r), c, b[1])
				B:block(bone, v(2 * S * r, h - 0.08, 2 * S * r), c, b[2], b[3] and { mat = "Neon" } or nil)
				L[k] = { y = y, r = r, h = h }
			end
			return L
		end
		-- bold patch on the bar face of layers k1..k2 (side 0..3 = +X,-Z,-X,+Z)
		-- lateral span u0..u1 as a fraction of the (smallest) layer radius
		local function patch(bone, F, L, k1, k2, side, u0, u1, color, opts, out)
			local r, y0, y1 = math.huge, math.huge, -math.huge
			for k = k1, k2 do
				r = math.min(r, L[k].r)
				y0 = math.min(y0, L[k].y - L[k].h / 2)
				y1 = math.max(y1, L[k].y + L[k].h / 2)
			end
			local inset = 0.06
			local hgt = (y1 - y0) - 2 * inset
			local depth = 0.4
			local c = F * CFrame.Angles(0, side * math.pi / 2, 0)
				* CFrame.new(r + (out or 0.1) - depth / 2, (y0 + y1) / 2, -(u0 + u1) / 2 * r)
			return B:block(bone, v(depth, hgt, math.abs(u1 - u0) * r), c, color, opts)
		end
		-- thin band hugging layer k (cloud band, stripes): slightly bigger footprint
		local function belt(bone, F, L, k, thick, dy, color, opts, grow)
			local ly = L[k]
			local c = F * CFrame.new(0, ly.y + (dy or 0), 0)
			local g = grow or 0.14
			B:block(bone, v(2 * ly.r + g, thick, 2 * W * ly.r + g), c, color, opts)
			B:block(bone, v(2 * W * ly.r + g, thick - 0.02, 2 * ly.r + g), c, color, opts)
			B:block(bone, v(2 * S * ly.r + g, thick - 0.04, 2 * S * ly.r + g), c, color, opts)
		end
		-- chunky little moon (3 crossed slabs + core, like Treadmill13)
		local function mini(bone, pos, s, c1, c2, c3)
			local c = CFrame.new(pos)
			B:block(bone, v(s * 0.78, s * 0.78, s * 0.78), c, c1)
			B:block(bone, v(s, s * 0.5, s * 0.5), c, c2)
			B:block(bone, v(s * 0.5, s, s * 0.5), c, c3 or c1)
			B:block(bone, v(s * 0.5, s * 0.5, s), c, c1)
		end

		------------------------------------------------------------------
		-- layout: systems packed outward with small gaps (no overlaps)
		------------------------------------------------------------------
		-- name, planet radius, system radius (moons/rings), gap before, start angle, tilt, tilt dir
		local SYS = {
			{ "Mercury", 1.2, 1.3, 0, 130, 0, 0 },
			{ "Venus", 1.95, 2.1, 0.5, 235, 0, 0 },
			{ "Earth", 2.05, 3.35, 0.45, 20, 23.4, 0 },
			{ "Mars", 1.5, 1.65, 0.45, 160, 25, 200 },
			{ "Belt", 0, 1.3, 0.45, 0, 0, 0 },
			{ "Jupiter", 3.8, 6.25, 0.4, 95, 0, 0 },
			{ "Saturn", 3.1, 6.9, 0.4, 40, 26.7, 150 },
			{ "Uranus", 2.35, 3.25, 0.45, 205, 98, 20 },
			{ "Neptune", 2.25, 2.4, 0.45, 300, 28, 250 },
		}
		local ORB = {}
		local edge = 10.75 -- first orbit's inner edge (clears corona + flares)
		for _, s in SYS do
			local r = edge + s[4] + s[3]
			ORB[s[1]] = r
			edge = r + s[3]
		end

		------------------------------------------------------------------
		-- THE SUN
		------------------------------------------------------------------
		local sun = B:bone("Sun", "Root", C)
		local SUN_R = 7
		local RO, RO_D, OR, OR_D, YO, YO_D, YE = "#ff5a1a", "#e2401a", "#ff8a1f", "#f06a14", "#ffc02a", "#ff9f1c", "#ffe25a"
		vsphere(sun, CC, SUN_R, {
			{ RO, RO_D }, { OR, OR_D }, { YO, "#ffb22e", true }, { YE, "#fff3a0", true }, { YO, "#ffb22e", true }, { OR, OR_D }, { RO, RO_D },
		})
		-- crisp red-orange polar crowns
		B:block(sun, v(2.8, 0.3, 2.8), cf(0, SY + SUN_R + 0.3, 0), "#ff4012")
		B:block(sun, v(2.8, 0.3, 2.8), cf(0, SY - SUN_R - 0.3, 0), "#d93412")
		local core = B:block(sun, v(13, 13, 13), CC, YE, { tr = 1, name = "SunCore" })
		B:light(core, { color = "#ffd27a", brightness = 1.5, range = 40, name = "SunLight" })
		B:emitter(core, "glow", { color = { "#fff2a0", "#ff9f1c" }, rate = 3, size = { 5, 8, 3 }, life = { 1.5, 2.5 }, name = "SunGlow" })
		B:emitter(core, "fire", { color = { "#fff27a", "#ff7a1a", "#e8461b" }, rate = 24, size = { 1.8, 1.2, 0 }, speed = { 1.5, 3 }, spread = 180, accel = { 0, 0, 0 }, life = { 0.5, 0.9 }, name = "SunFire" })
		B:emitter(core, "burst", { color = { "#fffbe0", "#ffd23a", "#ff7a1a" }, size = { 1.2, 0.8, 0 }, speed = { 12, 20 }, life = { 0.6, 1.1 }, name = "SunBurst" })
		local sparkBox = B:block("Root", v(24, 14, 24), CC, YE, { tr = 1, name = "SunSparkBox" })
		local dustBox = B:block("Root", v(120, 8, 120), CC, "#ffffff", { tr = 1, name = "StarDustBox" })
		B:emitter(dustBox, "sparkle", { color = { "#ffffff", "#ffe27a", "#9fe8ff", "#ffb6f0" }, rate = 40, size = { 0.25, 0.7, 0 }, speed = { 0.05, 0.3 }, life = { 1.5, 3 }, name = "StarDust" })
		B:emitter(sparkBox, "sparkle", { color = { "#fffbe0", "#ffd23a" }, rate = 10, size = { 0.2, 0.6, 0 }, speed = { 0.2, 0.8 }, name = "SunSparkle" })

		-- two stepped corona rings, tilted opposite ways (counter-rotate in motion)
		for ri, spec in { { "CoronaA", ang(20, 0, 0), "#ffd23a", "#ff9f1c" }, { "CoronaB", ang(0, 0, -20) * ang(0, 22.5, 0), "#ffb22e", "#ff7a1a" } } do
			local F = CC * spec[2]
			local bone = B:bone(spec[1], sun, F)
			local segs = B:ring(bone, F, 9.1, 18, v(3.3, 0.6, 0.9), spec[3])
			for i, p in segs do
				if i % 2 == 0 then
					p.Color = P.color(spec[4])
				end
			end
			-- glowing beads that flash on the solar burst
			for k = 1, 4 do
				local a = (k - 1) * math.pi / 2 + math.pi / 16
				B:block(bone, v(0.7, 0.7, 0.7), F * CFrame.Angles(0, a, 0) * CFrame.new(0, 0.6, -9.1), "#fff3a0", { mat = "Neon", name = spec[1] .. k })
			end
		end

		-- four chunky flare arcs on their own bones (erupt + fade in turn)
		local FL = { "#ffc81e", "#ff8a14", "#ff5410", "#ff8a14", "#ffc81e" }
		local FSZ = { 1.6, 1.45, 1.3, 1.45, 1.6 }
		for i, f in { { 45, 36 }, { 135, -36 }, { 225, 36 }, { 315, -36 } } do
			-- frame on the surface: +X outward, Z along the arc
			local F = CC * CFrame.Angles(0, rad(f[1]), 0) * CFrame.Angles(0, 0, rad(f[2])) * CFrame.new(6.4, 0, 0)
			local bone = B:bone("Flare" .. i, sun, F)
			for j = 1, 5 do
				local s = (j - 1) / 4
				local phi = math.pi * s
				local p = v(3.6 * math.sin(phi), 0, -2.3 * math.cos(phi))
				local sz = FSZ[j]
				B:block(bone, v(sz, sz, sz), F * CFrame.new(p), FL[j], { mat = "Neon", name = ("Flare%d_%d"):format(i, j) })
			end
		end

		-- burst shock ring: 8 neon bars that fly outward (hidden between bursts)
		for k = 1, 8 do
			local F = CC * CFrame.Angles(0, (k - 1) * math.pi / 4, 0)
			local bone = B:bone("Wave" .. k, "Root", F)
			B:block(bone, v(0.5, 0.35, 3.0), F * CFrame.new(7.6, 0, 0), "#ffd98a", { mat = "Neon", tr = 1, name = "Wave" .. k })
		end

		------------------------------------------------------------------
		-- orbit tracks: chunky translucent rings of touching segments, each
		-- with a pair of chase-light glints riding on its own bone
		------------------------------------------------------------------
		-- each track is a soft pastel of its planet (rainbow of rings)
		local TRACKS = { Mercury = "#d8d0f0", Venus = "#ffe9a8", Earth = "#a8dcff", Mars = "#ffc0a0", Jupiter = "#ffd2a0", Saturn = "#fff0a0", Uranus = "#a8f4ff", Neptune = "#b0c4ff" }
		local function track(name, r)
			local TRACK = TRACKS[name]
			local n = math.max(16, math.floor(2 * math.pi * r / 4.6 + 0.5))
			local len = 2 * math.pi * r / n + 0.06
			for i = 0, n - 1 do
				local a = (i + 0.5) / n * 2 * math.pi
				B:block("Root", v(0.55, 0.22, len), CC * CFrame.Angles(0, a, 0) * CFrame.new(r, 0, 0), TRACK, { tr = 0.5 })
			end
			local g = B:bone("Glint" .. name, "Root", C)
			for k = 0, 1 do
				local a = k * math.pi + 0.3
				B:block(g, v(0.75, 0.32, 2.2), CC * CFrame.Angles(0, a, 0) * CFrame.new(r, 0, 0), "#ffffff", { mat = "Neon", tr = 0.25 })
			end
		end

		------------------------------------------------------------------
		-- planets
		------------------------------------------------------------------
		local ORBITS = { Mercury = 12, Venus = 9, Earth = 7, Mars = 6, Jupiter = 4, Saturn = 3, Uranus = 2, Neptune = 1 }
		local function planetRig(name, R, psi0, tilt, dir, trailCol)
			local r = ORB[name]
			local speed = 2 * math.pi * r * ORBITS[name] / 60
			local pos = C + onCircle(r, psi0)
			local orbit = B:bone("Orbit" .. name, "Root", C)
			local carrier = B:bone("Carrier" .. name, orbit, pos)
			local spin = B:bone(name, carrier, pos)
			if trailCol then
				-- trail length ~16 studs of arc whatever the orbit speed
				B:trail(carrier, pos + v(0, R * 0.45, 0), pos - v(0, R * 0.45, 0), { color = trailCol, life = math.clamp(16 / speed, 0.6, 3), width = { 1, 0.1 }, trans = { 0.35, 1 }, name = "Trail" .. name })
			end
			track(name, r)
			return spin, carrier, CFrame.new(pos) * tiltRot(tilt, dir), pos
		end
		local SPEC = {}
		for _, s in SYS do
			SPEC[s[1]] = s
		end
		local function rig(name, trailCol)
			local s = SPEC[name]
			return planetRig(name, s[2], s[5], s[6], s[7], trailCol)
		end

		-- Mercury: small grey, two big craters
		do
			local sp, _, F = rig("Mercury")
			local L = vsphere(sp, F, SPEC.Mercury[2], { { "#d4cfc8", "#b3aea8" }, { "#aaa59f", "#8e8984" }, { "#86817c", "#6c6864" } })
			patch(sp, F, L, 2, 2, 0, -0.3, 0.25, "#6c6864")
			patch(sp, F, L, 2, 2, 2, -0.3, 0.25, "#6c6864")
		end

		-- Venus: creamy yellow cloud world with one bright swirl band
		do
			local sp, _, F = rig("Venus", { "#fff0b8", "#f2c86a" })
			local L = vsphere(sp, F, SPEC.Venus[2], {
				{ "#fff4c8", "#ffe7a0" }, { "#ffe08a", "#f7cc6a" }, { "#fbcd62", "#efb648" }, { "#f2b84e", "#e0a03a" }, { "#e2a03c", "#cc882c" },
			})
			belt(sp, F, L, 3, 0.32, 0.18, "#fff8e2")
		end

		-- Earth: blue, 3 big green continents, white caps, a cloud band + Moon
		do
			local sp, carrier, F, pos = rig("Earth", { "#7fd0ff", "#2f8cff" })
			local L = vsphere(sp, F, SPEC.Earth[2], {
				{ "#ffffff", "#e8f4ff" }, { "#5cb4ff", "#3f98f2" }, { "#3a94ff", "#2a7ce6" }, { "#2f86f5", "#226ee0" },
				{ "#2474e6", "#1a5ccc" }, { "#1c60cc", "#164cb0" }, { "#f4f9ff", "#dceaf8" },
			})
			local G, G_D, G_L = "#43d14f", "#2fa540", "#7ae05a"
			-- continent 1 (+X): big and stepped
			patch(sp, F, L, 3, 5, 0, -0.48, 0.1, G)
			patch(sp, F, L, 4, 4, 0, 0.1, 0.42, G_D)
			patch(sp, F, L, 5, 6, 0, -0.3, -0.02, G_L)
			-- continent 2 (-X): with a desert corner
			patch(sp, F, L, 4, 6, 2, -0.15, 0.46, G)
			patch(sp, F, L, 4, 4, 2, -0.46, -0.15, "#d9a050")
			-- continent 3 (+Z): a chunky southern land
			patch(sp, F, L, 2, 3, 3, -0.35, 0.3, G_L)
			-- cloud band
			belt(sp, F, L, 5, 0.22, 0.05, "#ffffff")
			-- thin cyan atmosphere rim around the equator
			belt(sp, F, L, 4, 0.14, -0.12, "#7ff3ff", { mat = "Neon", tr = 0.35 }, 0.32)
			-- the Moon (tidally locked)
			local moonOrbit = B:bone("MoonOrbit", carrier, pos)
			local mp = pos + onCircle(2.9, 200)
			mini(moonOrbit, mp, 0.9, "#d6d6dc", "#b4b4bc", "#ececf0")
			local toward = (pos - mp).Unit
			B:block(moonOrbit, v(0.3, 0.3, 0.3), CFrame.new(mp + toward * 0.36), "#83838e")
		end

		-- Mars: rusty red, white polar cap, dark patch, Olympus Mons
		do
			local sp, _, F = rig("Mars", { "#ffb08a", "#e0603a" })
			local L = vsphere(sp, F, SPEC.Mars[2], {
				{ "#ffffff", "#f1ebe7" }, { "#f27c4c", "#de6438" }, { "#e0603a", "#c44c2c" }, { "#c84a2c", "#a83c24" }, { "#a83c24", "#8c301e" },
			})
			patch(sp, F, L, 3, 3, 2, -0.4, 0.3, "#8a2e1c")
			local ly = L[3]
			local base = F * CFrame.new(ly.r, 0.05, 0)
			B:block(sp, v(0.5, 0.65, 0.75), base * CFrame.new(0.1, 0, 0), "#e8784a")
			B:block(sp, v(0.4, 0.38, 0.42), base * CFrame.new(0.35, 0.02, 0), "#ff9a6a")
		end

		-- asteroid belt: rocks on one turning bone + 5 tumbling big rocks
		do
			local rb = ORB.Belt
			local ROCK = { "#a39a92", "#7f7470", "#bdb2a6", "#9a7454", "#7a5a44", "#6a5e66" }
			local bone = B:bone("Belt", "Root", C)
			local NR = 30
			for i = 1, NR do
				local a = (i - 1 + rnd() * 0.6) / NR * 360
				local r = rb - 0.85 + rnd() * 1.7
				local p = C + onCircle(r, a) + v(0, (rnd() - 0.5) * 1.0, 0)
				local s = 0.5 + rnd() * 0.45
				B:block(bone, v(s, s * 0.85, s * 0.95), CFrame.new(p) * ang(0, rnd() * 90, 0), ROCK[1 + math.floor(rnd() * #ROCK)])
			end
			for k = 1, 5 do
				local a = (k - 1) * 72 + 20
				local p = C + onCircle(rb, a)
				local tb = B:bone("Rock" .. k, bone, p)
				local s = 1.0 + (k % 2) * 0.2
				B:block(tb, v(s, s * 0.8, s * 0.9), CFrame.new(p), ROCK[k])
				B:block(tb, v(s * 0.6, s * 0.55, s * 0.6), CFrame.new(p + v(0.3 * s, 0.35 * s, -0.15 * s)), ROCK[(k + 2) % #ROCK + 1])
				-- a glowing crystal chip
				B:block(tb, v(0.3, 0.45, 0.3), CFrame.new(p + v(-0.35 * s, 0.4 * s, 0.2 * s)) * ang(0, 45, 0), ({ "#7ff3ff", "#ff8ff0", "#ffe27a", "#9f8cff", "#7fffb0" })[k], { mat = "Neon" })
			end
		end

		-- Jupiter: crisp stripes + the Great Red Spot, Io + Europa
		do
			local sp, carrier, F, pos = rig("Jupiter", { "#ffd9a0", "#d9853f" })
			local L = vsphere(sp, F, SPEC.Jupiter[2], {
				{ "#e8a860", "#d08c48" }, { "#ffd89a", "#f5c47c" }, { "#ee6a1c", "#d45812" }, { "#ffe6b4", "#f5d094" },
				{ "#a8441c", "#8c3614" }, { "#ffcc80", "#f0b464" }, { "#d8803a", "#c06a2a" },
			})
			-- Great Red Spot on the brown stripe
			local ly = L[3]
			local gs = F * CFrame.new(ly.r, ly.y, -0.3)
			B:block(sp, v(0.4, ly.h + 0.25, 2.2), gs * CFrame.new(0.06, 0, 0), "#b8321f")
			B:block(sp, v(0.4, ly.h - 0.1, 1.5), gs * CFrame.new(0.16, 0, 0), "#e5482c")
			B:block(sp, v(0.3, ly.h - 0.45, 0.8), gs * CFrame.new(0.3, 0, 0), "#ff7a4a", { mat = "Neon", tr = 0.15, name = "RedSpotGlow" })
			-- Io (yellow) and Europa (cream), 2:1 resonance in motion
			for _, m in { { "Io", 5.05, 40, 0.9, "#ffe34d", "#ff9f2a", "#fff27a" }, { "Europa", 5.85, 220, 0.8, "#f6efe0", "#c8a27a", "#fffaf0" } } do
				local mb = B:bone(m[1], carrier, pos)
				mini(mb, pos + onCircle(m[2], m[3]), m[4], m[5], m[6], m[7])
			end
		end

		-- Saturn: golden bands + thick chunky rings with a gap, Titan
		do
			local s = SPEC.Saturn
			local sp, carrier, F, pos = rig("Saturn", { "#fff0b0", "#e8b04a" })
			vsphere(sp, F, SPEC.Saturn[2], {
				{ "#ffd65a", "#f2be3a" }, { "#fff0b0", "#ffe08a" }, { "#f5b03a", "#e0962a" }, { "#ffe48a", "#f6cc5c" }, { "#e0942e", "#c47c22" },
			})
			local rf = CFrame.new(pos) * tiltRot(s[6], s[7])
			local rings = B:bone("SaturnRings", carrier, rf)
			local bR = B:ring(rings, rf, 4.35, 18, v(1.6, 0.5, 1.15), "#ffe48a")
			for i, p in bR do
				if i % 2 == 0 then
					p.Color = P.color("#f7c24a")
				end
			end
			local aR = B:ring(rings, rf, 5.7, 22, v(1.7, 0.4, 0.75), "#e8a548")
			for i, p in aR do
				if i % 2 == 0 then
					p.Color = P.color("#d08a34")
				end
			end
			-- Titan orbits in Saturn's (tilted) equatorial plane
			local tb = B:bone("Titan", carrier, rf)
			mini(tb, (rf * CFrame.new(onCircle(6.5, 110))).Position, 0.85, "#f2a23a", "#d9822a", "#ffc266")
		end

		-- Uranus: bright cyan, tipped on its side with a thin ring
		do
			local sp, carrier, F = rig("Uranus", { "#c8fbff", "#4fd2e8" })
			local L = vsphere(sp, F, SPEC.Uranus[2], {
				{ "#b8fdff", "#8ef6ff" }, { "#7ff6ff", "#5ae8fa" }, { "#4fe6fb", "#36d2ef" }, { "#33d0f0", "#24b8e0" }, { "#22b4e0", "#1a98c8" },
			})
			belt(sp, F, L, 3, 0.24, 0, "#dffdff")
			B:ring(carrier, F, 3.1, 18, v(1.15, 0.18, 0.32), "#e6fbff", { tr = 0.3 })
			local halo = B:block(carrier, v(4.8, 4.8, 4.8), F, "#9ff6ff", { tr = 1, name = "UranusHalo" })
			B:emitter(halo, "glow", { color = { "#c8fbff", "#5fe3f7" }, rate = 3, size = { 2.6, 3.4, 2 }, life = { 1.2, 2 }, locked = true, name = "UranusGlow" })
		end

		-- Neptune: deep blue, dark spot, white streak
		do
			local sp, carrier, F = rig("Neptune", { "#9fc0ff", "#2f5be0" })
			local L = vsphere(sp, F, SPEC.Neptune[2], {
				{ "#6f9bff", "#5a86f2" }, { "#4a78f5", "#3a66e0" }, { "#2f5be0", "#244cc8" }, { "#2448c4", "#1c3cac" }, { "#1c39a6", "#162e8c" },
			})
			patch(sp, F, L, 3, 3, 0, -0.42, 0.15, "#0f1c5c")
			belt(sp, F, L, 2, 0.2, 0.1, "#ffffff")
			local halo = B:block(carrier, v(4.6, 4.6, 4.6), F, "#6f9bff", { tr = 1, name = "NeptuneHalo" })
			B:emitter(halo, "glow", { color = { "#9fc0ff", "#3a66ff" }, rate = 3, size = { 2.5, 3.3, 2 }, life = { 1.2, 2 }, locked = true, name = "NeptuneGlow" })
		end

		------------------------------------------------------------------
		-- comet: Kepler ellipse in a slightly tilted plane (mirrored in motion)
		------------------------------------------------------------------
		local COMET = { q = 12.6, Q = 54, inc = 11, node = 200, w = 80, M0 = rad(300) }
		COMET.a = (COMET.q + COMET.Q) / 2
		COMET.e = (COMET.Q - COMET.q) / (COMET.Q + COMET.q)
		local function kepler(M, e)
			M = (M + math.pi) % (2 * math.pi) - math.pi
			local E = M + 0.85 * e * (M >= 0 and 1 or -1)
			for _ = 1, 10 do
				E -= (E - e * math.sin(E) - M) / (1 - e * math.cos(E))
			end
			local nu = 2 * math.atan2(math.sqrt(1 + e) * math.sin(E / 2), math.sqrt(1 - e) * math.cos(E / 2))
			return nu, 1 - e * math.cos(E)
		end
		do
			local PF = CFrame.new(C) * ang(0, COMET.node, 0) * ang(COMET.inc, 0, 0)
			local nu, rr = kepler(COMET.M0, COMET.e)
			local psi0 = math.deg(nu) + COMET.w
			local p0 = onCircle(COMET.a * rr, psi0)
			local path = B:bone("CometPath", "Root", PF)
			local hf = PF * CFrame.new(p0)
			local head = B:bone("Comet", path, hf)
			local tf = hf * ang(0, psi0, 0) -- +X = away from the Sun
			B:block(head, v(1.0, 1.0, 1.0), tf, "#bfeaff")
			B:block(head, v(1.3, 0.62, 0.62), tf, "#e6f7ff")
			B:block(head, v(0.62, 1.3, 0.62), tf, "#8fd6ff")
			B:block(head, v(0.62, 0.62, 1.3), tf, "#e6f7ff")
			local nucleus = B:block(head, v(0.7, 0.7, 0.7), tf * CFrame.new(-0.35, 0, 0), "#ffffff", { mat = "Neon", name = "CometCore" })
			B:light(nucleus, { color = "#bff4ff", brightness = 0.9, range = 10, name = "CometLight" })
			local tail = {
				{ 1.25, 0, 0.85, "#ffffff", 0.0 }, { 2.35, 0.1, 0.75, "#e6fbff", 0.08 }, { 3.45, -0.1, 0.65, "#bff4ff", 0.18 },
				{ 4.55, 0.2, 0.55, "#8fe6ff", 0.3 }, { 5.6, -0.2, 0.45, "#7fdcff", 0.42 }, { 6.6, 0.3, 0.36, "#a8c8ff", 0.55 },
			}
			local last
			for k, t in tail do
				last = B:block(head, v(1.25, t[3], t[3] * 1.5), tf * CFrame.new(t[1], 0, t[2]), t[4], { mat = "Neon", tr = t[5], name = "Tail" .. k })
			end
			B:emitter(last, "sparkle", { color = { "#ffffff", "#9fe8ff" }, rate = 10, size = { 0.2, 0.5, 0 }, speed = { 0.2, 0.6 }, name = "CometDust" })
			local up = PF.UpVector
			B:trail(head, tf.Position + up * 0.4, tf.Position - up * 0.4, { color = { "#ffffff", "#7fdcff" }, life = 1.1, width = { 1, 0.15 }, trans = { 0.3, 1 }, name = "TrailComet" })
		end
	end,
}
