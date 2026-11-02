-- Solar System motion: one seamless 60 s loop, every count whole per loop.
-- * Planets orbit counter-clockwise seen from above (+Y; a positive
--   CFrame.Angles(0, a, 0) is CCW here), inner ones faster. Carrier<P> turns
--   back by the orbit angle so each axial tilt keeps pointing the same way in
--   space, bobs gently and carries the planet's trail; <P> spins about its
--   tilted axis (Venus backwards, Uranus about its sideways axis).
-- * Moons orbit briskly (Io:Europa 2:1), tidally locked. Saturn's rings
--   slowly turn and wobble. The belt turns, five big rocks tumble.
-- * Chase-light glints race along every orbit track.
-- * Sun: slow spin, counter-rotating corona rings, glow breathing, flare
--   arcs erupt (backOut) and fade one after another, and every 20 s a SOLAR
--   BURST: wind-up, flash, burst emitter, shock ring flying outward, corona
--   beads flare, light peaks.
-- * Comet: Kepler ellipse (fast near the Sun), tail always points away from
--   the Sun and grows near it.
local L = require(script.Parent.AnimLib)
local E = L.ease
local M = {}
M.Cycle = 60

local TAU = 2 * math.pi
local function turns(t, n) -- angle after n whole turns per loop (n < 0 = clockwise)
	return TAU * ((n * t / M.Cycle) % 1)
end
local function wav(t, n, ph) -- sine with n whole repeats per loop
	return math.sin(turns(t, n) + (ph or 0))
end
local function rotY(a)
	return CFrame.Angles(0, a, 0)
end
local function axisOf(tilt, dir) -- matches build.luau tiltRot
	local t, d = math.rad(tilt), math.rad(dir)
	return Vector3.new(-math.sin(t) * math.cos(d), math.cos(t), math.sin(t) * math.sin(d))
end

-- name, orbits, spins, tilt, tilt dir, bob repeats, bob amplitude
local PLANETS = {
	{ "Mercury", 12, 36, 0, 0, 6, 0.3 },
	{ "Venus", 9, -12, 0, 0, 5, 0.35 },
	{ "Earth", 7, 35, 23.4, 0, 4, 0.4 },
	{ "Mars", 6, 30, 25, 200, 5, 0.35 },
	{ "Jupiter", 4, 30, 0, 0, 3, 0.5 },
	{ "Saturn", 3, 24, 26.7, 150, 3, 0.5 },
	{ "Uranus", 2, -16, 98, 20, 4, 0.4 }, -- on its side (spins backwards like the real one)
	{ "Neptune", 1, 15, 28, 250, 3, 0.4 },
}
for i, p in PLANETS do
	p[8] = axisOf(p[4], p[5])
	p[9] = i * 1.3 -- bob phase
end
local MOONS = { { "MoonOrbit", 21 }, { "Io", 24 }, { "Europa", 12 }, { "Titan", 10 } }
local GLINTS = { Mercury = 10, Venus = 9, Earth = 8, Mars = 7, Jupiter = 6, Saturn = 5, Uranus = 4, Neptune = 3 }
local ROCKS = {
	{ Vector3.new(1, 1, 0).Unit, 8 },
	{ Vector3.new(0, 1, 1).Unit, -7 },
	{ Vector3.new(1, 0, 1).Unit, 9 },
	{ Vector3.new(-1, 1, 0.5).Unit, -6 },
	{ Vector3.new(0.3, 1, -1).Unit, 10 },
}

-- comet (same numbers as build.luau)
local COMET = { q = 12.6, Q = 54, w = 80, M0 = math.rad(300), n = 2 }
COMET.a = (COMET.q + COMET.Q) / 2
COMET.e = (COMET.Q - COMET.q) / (COMET.Q + COMET.q)
local function kepler(Mn, e)
	Mn = (Mn + math.pi) % TAU - math.pi
	local Ea = Mn + 0.85 * e * (Mn >= 0 and 1 or -1)
	for _ = 1, 10 do
		Ea -= (Ea - e * math.sin(Ea) - Mn) / (1 - e * math.cos(Ea))
	end
	local nu = 2 * math.atan2(math.sqrt(1 + e) * math.sin(Ea / 2), math.sqrt(1 - e) * math.cos(Ea / 2))
	return nu, 1 - e * math.cos(Ea)
end
local function cometPos(Mn)
	local nu, rr = kepler(Mn, COMET.e)
	local psi = nu + math.rad(COMET.w)
	local r = COMET.a * rr
	return Vector3.new(r * math.cos(psi), 0, -r * math.sin(psi)), psi, r
end
local C0, CPSI0 = cometPos(COMET.M0)
local TAILTR = { 0, 0.08, 0.18, 0.3, 0.42, 0.55 }

local BURST = 20 -- solar burst period (s)
local FLARE = 10 -- each flare erupts once per 10 s, staggered

function M.Update(t, pose, ctx)
	-- planets
	for _, p in PLANETS do
		local th = turns(t, p[2])
		pose["Orbit" .. p[1]] = rotY(th)
		pose["Carrier" .. p[1]] = CFrame.new(0, p[7] * wav(t, p[6], p[9]), 0) * rotY(-th)
		pose[p[1]] = CFrame.fromAxisAngle(p[8], turns(t, p[3]))
	end
	for _, m in MOONS do
		pose[m[1]] = rotY(turns(t, m[2]))
	end
	pose.SaturnRings = CFrame.Angles(math.rad(3) * wav(t, 2), turns(t, 2), math.rad(3) * wav(t, 2, 1.57))
	for name, n in GLINTS do
		pose["Glint" .. name] = rotY(turns(t, n))
	end
	pose.Belt = rotY(turns(t, 3))
	for k, r in ROCKS do
		pose["Rock" .. k] = CFrame.fromAxisAngle(r[1], turns(t, r[2]))
	end

	-- comet
	local cpos, cpsi, cr = cometPos(COMET.M0 + turns(t, COMET.n))
	pose.CometPath = CFrame.new(cpos - C0)
	pose.Comet = rotY(cpsi - CPSI0)
	local show = math.clamp((44 - cr) / 26, 0, 1) * 6
	for k = 1, 6 do
		ctx.transparency("Tail" .. k, (k <= 2 or k <= show + 0.5) and TAILTR[k] or 1)
	end
	ctx.light("CometLight", 0.5 + 0.9 * math.clamp((30 - cr) / 16, 0, 1))

	-- SOLAR BURST every 20 s: wind-up 18.8-20, flash at 0
	local b = t % BURST
	local wind = L.clamp01((b - (BURST - 1.2)) / 1.2)
	local flash = b < 2.5 and (1 - E.cubicOut(b / 2.5)) or 0
	if ctx.crossed(0.02) or ctx.crossed(20.02) or ctx.crossed(40.02) then
		ctx.emit("SunBurst", 90)
	end
	local breathe = 0.5 + 0.5 * wav(t, 15)
	ctx.light("SunLight", 1.0 + 0.3 * breathe + 0.7 * flash)

	-- Sun spin: steady, a little shiver during the wind-up, a kick on the burst
	-- each burst whips the Sun an extra 1/3 turn (3 bursts = 1 whole turn per loop)
	local nb = math.floor(t / BURST) % 3
	local kick = math.rad(120) * (nb + E.cubicOut(L.clamp01(b / 1.6)))
	pose.Sun = CFrame.new(0, 0.12 * wind * math.sin(turns(t, 1800)), 0) * rotY(turns(t, 3) + kick)
	-- corona rings counter-rotate and whirl on the burst
	local whirl = math.rad(120) * (nb + E.cubicOut(L.clamp01(b / 2.2)))
	pose.CoronaA = rotY(turns(t, 4) + whirl)
	pose.CoronaB = rotY(turns(t, -5) - whirl)
	for k = 1, 4 do
		local tw = 0.5 + 0.5 * wav(t, 30, k * 1.57)
		local tr = math.clamp(0.55 - 0.35 * tw - 0.6 * flash - 0.3 * wind, 0, 1)
		ctx.transparency("CoronaA" .. k, tr)
		ctx.transparency("CoronaB" .. k, math.clamp(0.55 - 0.35 * (1 - tw) - 0.6 * flash - 0.3 * wind, 0, 1))
	end

	-- shock ring: 8 bars fly outward from the surface and fade
	local wv = L.clamp01(b / 1.4)
	local out = 2.8 * E.cubicOut(wv)
	for k = 1, 8 do
		pose["Wave" .. k] = CFrame.new(out, 0, 0)
		ctx.transparency("Wave" .. k, b < 1.4 and (0.05 + 0.95 * E.quadIn(wv)) or 1)
	end

	-- flare arcs erupt one after another (and all together on the burst)
	for i = 1, 4 do
		local f = (t + (i - 1) * 2.5) % FLARE
		local burstF = b < 3 and 1 or 0
		local up = math.max(L.env(f, 0, 0.6, 2.6, 1.4, "backOut", "cubicIn"), burstF * L.env(b, 0, 0.3, 1.2, 1.2, "backOut", "cubicIn"))
		pose["Flare" .. i] = CFrame.new(-3.8 * (1 - up), 0, 0)
		for j = 1, 5 do
			local fl = 0.5 + 0.5 * math.sin(turns(t, 120 + 15 * i) + j * 1.4)
			local tr = up < 0.05 and 1 or math.clamp(0.1 * fl + 0.85 * (1 - up), 0, 1)
			ctx.transparency(("Flare%d_%d"):format(i, j), tr)
		end
	end
end

return M
