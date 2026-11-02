-- Solar System motion: one seamless 600 s cycle.
-- Periods are the square roots of the real ratios (Earth year = 10 s) rounded
-- to whole numbers per cycle, so the loop is exact. Everything orbits
-- counter-clockwise seen from above (+Y); a positive CFrame.Angles(0, a, 0)
-- is counter-clockwise here.
--   * Orbit<P> turns about the Sun, Carrier<P> turns back by the same angle so
--     each planet's axial tilt keeps pointing the same way in space (seasons),
--     and <P> spins about its tilted axis.
--   * Moons orbit their planet's carrier (Titan in Saturn's equatorial plane)
--     and never spin on their own -> tidally locked.
--   * Pluto and the comet follow Kepler ellipses (mean anomaly -> Kepler's
--     equation -> true anomaly): fastest at perihelion. The comet's tail is
--     turned every frame to point straight away from the Sun and grows long
--     near the Sun, short far out.
--   * The Sun spins slowly, its prominences erupt and flicker, the glow pulses.
local L = require(script.Parent.AnimLib)
local M = {}
M.Cycle = 600

local TAU = 2 * math.pi
local CYCLE = M.Cycle

-- angle (radians) after `n` whole turns per cycle (negative n turns clockwise)
local function turns(t, n)
	return TAU * ((n * t / CYCLE) % 1)
end
local function rotY(a)
	return CFrame.Angles(0, a, 0)
end
-- tilted spin axis: +Y tipped `tilt` deg toward direction `dir` (matches build.luau tiltRot)
local function axisOf(tilt, dir)
	local t, d = math.rad(tilt), math.rad(dir)
	return Vector3.new(-math.sin(t) * math.cos(d), math.cos(t), math.sin(t) * math.sin(d))
end

-- name, orbits per cycle, spins per cycle, tilt, tilt direction (deg)
local PLANETS = {
	{ "Mercury", 122, 183, 0, 0 }, -- 3:2 spin-orbit resonance
	{ "Venus", 77, -20, 0, 0 }, -- retrograde spin
	{ "Earth", 60, 300, 23.4, 0 },
	{ "Mars", 44, 290, 25, 200 },
	{ "Jupiter", 17, 600, 0, 0 },
	{ "Saturn", 11, 560, 26.7, 150 },
	{ "Uranus", 7, 400, 98, 20 }, -- on its side
	{ "Neptune", 5, 420, 28, 250 },
}
for _, p in PLANETS do
	p[6] = axisOf(p[4], p[5])
end

-- moons: bone, orbits per cycle (Io:Europa:Ganymede = 4:2:1 Laplace resonance)
local MOONS = { { "MoonOrbit", 240 }, { "Io", 320 }, { "Europa", 160 }, { "Ganymede", 80 }, { "Callisto", 34 }, { "Titan", 60 } }

-- Kepler orbits (same numbers as build.luau)
local PLUTO = { a = 102, e = 0.25, w = 113, M0 = math.rad(330), n = 4, spin = 30 }
local COMET = { a = 80, e = 0.82, w = 90, M0 = math.rad(320), n = 3 }

local function kepler(Mn, e)
	Mn = (Mn + math.pi) % TAU - math.pi
	local E = Mn + 0.85 * e * (Mn >= 0 and 1 or -1)
	for _ = 1, 10 do
		E -= (E - e * math.sin(E) - Mn) / (1 - e * math.cos(E))
	end
	local nu = 2 * math.atan2(math.sqrt(1 + e) * math.sin(E / 2), math.sqrt(1 - e) * math.cos(E / 2))
	return nu, 1 - e * math.cos(E)
end
-- in-plane position, polar angle (rad), distance
local function orbitPos(o, Mn)
	local nu, rr = kepler(Mn, o.e)
	local psi = nu + math.rad(o.w)
	local r = o.a * rr
	return Vector3.new(r * math.cos(psi), 0, -r * math.sin(psi)), psi, r
end
local P0 = orbitPos(PLUTO, PLUTO.M0)
local C0, CPSI0 = orbitPos(COMET, COMET.M0)

-- prominence arcs on the Sun: blocks per arc
local FLARES = { 9, 9, 8, 9 }
local HOTS = 10

function M.Update(t, pose, ctx)
	-- planets: orbit, keep tilt fixed in space, spin about the tilted axis
	for _, p in PLANETS do
		local th = turns(t, p[2])
		pose["Orbit" .. p[1]] = rotY(th)
		pose["Carrier" .. p[1]] = rotY(-th)
		pose[p[1]] = CFrame.fromAxisAngle(p[6], turns(t, p[3])) -- negative count = retrograde (Venus)
	end
	for _, m in MOONS do
		pose[m[1]] = rotY(turns(t, m[2]))
	end
	pose.BeltInner = rotY(turns(t, 30))
	pose.BeltOuter = rotY(turns(t, 24))

	-- Pluto: tilted, eccentric, Kepler speed; slow spin in its orbital plane
	local pp = orbitPos(PLUTO, PLUTO.M0 + turns(t, PLUTO.n))
	pose.PlutoPath = CFrame.new(pp - P0)
	pose.Pluto = rotY(turns(t, PLUTO.spin))

	-- comet: Kepler speed, tail turned to point away from the Sun
	local cpos, cpsi, cr = orbitPos(COMET, COMET.M0 + turns(t, COMET.n))
	pose.CometPath = CFrame.new(cpos - C0)
	pose.Comet = rotY(cpsi - CPSI0)
	-- the tail grows as the comet nears the Sun (all 8 blocks inside ~45 studs)
	local tailBase = { 0, 0.05, 0.15, 0.25, 0.35, 0.45, 0.55, 0.62 }
	local show = math.clamp((150 - cr) / 105, 0, 1) * 8
	for k = 1, 8 do
		local on = k <= 2 or k <= show + 0.5
		ctx.transparency("Tail" .. k, on and tailBase[k] or 1)
	end
	for k = 1, 3 do
		ctx.transparency("Dust" .. k, cr < 60 and (0.4 + k * 0.1) or 1)
	end
	ctx.light("CometLight", 0.6 + 0.9 * math.clamp((60 - cr) / 45, 0, 1))

	-- Sun: slow spin, pulsing glow
	pose.Sun = rotY(turns(t, 10))
	local pulse = 0.5 + 0.5 * math.sin(turns(t, 150)) -- 4 s breathing
	ctx.light("SunLight", 1.2 + 0.3 * pulse)
	for i = 1, HOTS do
		local f = 0.5 + 0.5 * math.sin(turns(t, 150) + i * 1.7 + 0.6 * math.sin(turns(t, 420) + i))
		ctx.transparency("Hot" .. i, 0.35 * f)
	end
	-- prominences: each arc erupts from one foot over the top, holds while
	-- flickering, then fades (period 12 s, staggered), all whole per cycle
	for i, n in FLARES do
		local ph = ((t / 12) + (i - 1) * 0.27) % 1
		local grow = math.clamp(ph / 0.25, 0, 1) -- 0..3 s rise
		local fade = math.clamp((ph - 0.7) / 0.2, 0, 1) -- 8.4..10.8 s fade
		for j = 1, n do
			local s = (j - 1) / (n - 1)
			local lit = grow * 1.05 >= s and 1 or 0
			local flick = 0.5 + 0.5 * math.sin(turns(t, 900 + 60 * i) + j * 1.3)
			local tr = 1
			if lit > 0 and fade < 1 then
				tr = math.clamp(0.02 + 0.22 * flick + fade * 0.95, 0, 1)
			end
			ctx.transparency(("Flare%d_%d"):format(i, j), tr)
		end
	end
end

return M
