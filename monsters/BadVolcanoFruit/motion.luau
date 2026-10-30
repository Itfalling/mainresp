--!nocheck
-- Volcano Fruit Cone: a lively, clearly visible, seamless 10 s idle.
-- * the teal frond collar sways in a ripple running around the cone; the
--   upper cone (ConeTop) breathes with a tiny bob; the slope fruits swing on
--   their stalks; lava channels, fruit cracks and the crater glow pulse
-- * little PUFF at 2.6 s: the cone hiccups, a small smoke puff pops out
-- * ERUPTION once per loop: a rumble builds (5.0-6.35 s) - the upper cone
--   shakes harder and harder, fronds tremble, fruits jiggle, the crater
--   fruit rattles and peeks up, lava + light glow up; the cone dips
--   (anticipation) then JOLTS up at 6.35 s: a big smoke puff + 55 lava
--   sparks burst out and the crater fruit is POPPED ~9 studs into the air,
--   tumbling (trail), the fronds flare up; it falls back into the crater at
--   8.05 s with a little bounce, wobble and a ring of landing sparks; all
--   settles by ~9.3 s
-- Waves use whole cycles per loop; every envelope is 0 at both loop ends.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, exp, clamp, pi = math.sin, math.exp, math.clamp, math.pi

local M = {}
M.Cycle = 10

local TAU = math.pi * 2
local PUFF = 2.6
local POP = 6.35
local FLIGHT = 1.7
local LAND = POP + FLIGHT
local HEIGHT = 9

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

local FRONDS = { 0.0, 0.17, 0.33, 0.5, 0.67, 0.83 }
local FRUITS = { { 2, 0.1 }, { 3, 0.45 }, { 2, 0.7 }, { 3, 0.25 }, { 2, 0.9 } }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- envelopes
	local rumble = L.track(c, { { 5.0, 0 }, { 6.3, 1, "quadIn" }, { 6.45, 0, "cubicOut" } })
	local dip = L.track(c, { { 5.9, 0 }, { 6.3, 1, "sineInOut" }, { 6.38, 0, "cubicOut" } })
	local flash = L.track(c, { { 6.3, 0 }, { 6.42, 1, "quadOut" }, { 7.0, 0.6 }, { 8.8, 0, "sineInOut" } })
	-- springy jolt after the pop / after the small puff / after the landing
	local function spring(dt, k, f)
		if dt <= 0 or dt > 3 then
			return 0
		end
		return exp(-k * dt) * sin(f * dt)
	end
	local jolt = spring(c - POP, 3.2, 9)
	local hic = spring(c - PUFF, 4.5, 11)
	local thud = spring(c - LAND, 5, 13)
	local shake = rumble * sin(TAU * 13 * c / 1) -- 13 Hz rattle (0 outside the rumble)
	local shake2 = rumble * sin(TAU * 11 * c + 1.3)

	pose.Crop = ang(0.3 * w(t, 1, 0.6) + 0.4 * shake2 * rumble, 0, 0.3 * w(t, 1, 0.85) + 0.4 * shake * rumble)

	-- upper cone: breathing bob, rumble rattle, anticipation dip, pop jolt
	pose.ConeTop = pa(0.05 * shake, 0.06 * w(t, 2, 0.1) - 0.3 * dip + 0.45 * jolt + 0.15 * hic - 0.1 * thud, 0.05 * shake2,
		1.0 * w(t, 1, 0.0) + 1.8 * shake, 0.6 * w(t, 1, 0.3), 1.0 * w(t, 1, 0.25) + 1.8 * shake2)

	-- fronds: ripple sway, tremble on the rumble, flare up on the pop
	for i, ph in FRONDS do
		local lift = 18 * jolt + 6 * hic - 8 * dip + 4 * thud
		pose["Frond" .. i] = ang(3 * w(t, 2, ph) + lift + 4 * rumble * sin(TAU * 9 * c + i), 2 * w(t, 1, ph + 0.3), 3 * w(t, 1, ph + 0.2) + 3 * shake * (i % 2 == 0 and 1 or -1))
	end

	-- slope fruits: swing on their stalks, jiggle on the rumble, kick on the pop
	for i, f in FRUITS do
		local jig = 7 * rumble * sin(TAU * 10 * c + i * 1.7)
		pose["Fruit" .. i] = ang(5 * w(t, f[1], f[2]) + jig + 10 * jolt, 3 * w(t, 1, f[2] + 0.4), 4 * w(t, f[1], f[2] + 0.25) - 0.6 * jig + 3 * hic)
		local tr = clamp(0.35 + 0.15 * w(t, 2, f[2]) - 0.3 * rumble - 0.35 * flash, 0, 0.6)
		ctx.transparency("FruitCore" .. i, tr)
		ctx.transparency("FruitCore" .. i .. "B", tr)
	end

	-- crater fruit: rattles + peeks during the rumble, flies on the pop
	local fy, rx, ry, rz = 0, 0, 0, 0
	local dt = c - POP
	if dt > 0 and dt < FLIGHT then
		local u = dt / FLIGHT
		fy = 4 * HEIGHT * u * (1 - u)
		rx = 360 * L.ease.sineInOut(u)
		ry = 720 * u
		rz = 25 * sin(pi * u)
	else
		fy = 0.4 * rumble + 0.25 * math.abs(shake)
		rx = 6 * shake
		rz = 6 * shake2
	end
	local dl = c - LAND
	if dl > 0 and dl < 0.7 then
		fy += 0.9 * sin(pi * dl / 0.7) * (1 - dl / 0.7)
	end
	rx += 10 * thud
	rz += 8 * thud
	pose.PopFruit = pa(0, fy, 0, rx, ry, rz)
	local popTr = clamp(0.3 + 0.1 * w(t, 3, 0.3) - 0.3 * rumble - 0.3 * flash, 0, 0.5)
	ctx.transparency("PopCore", popTr)
	ctx.transparency("PopCoreB", popTr)

	-- lava glow: channels pulse downhill, flare on the eruption
	local idle = 0.12 + 0.12 * w(t, 2, 0.15)
	for ch = 1, 3 do
		for seg = 1, 5 do
			local ripple = 0.1 * w(t, 4, seg * 0.12 + ch * 0.33)
			ctx.transparency("Lava" .. ch .. "_" .. seg, clamp((idle + ripple) * (1 - rumble) * (1 - flash), 0, 0.45))
		end
		ctx.transparency("Drip" .. ch, clamp((idle + 0.05) * (1 - flash), 0, 0.4))
	end
	ctx.transparency("CraterCore", clamp((0.25 + 0.15 * w(t, 2, 0.4)) * (1 - rumble) * (1 - flash), 0, 0.5))

	ctx.light("CraterLight", clamp(1.0 + 0.2 * w(t, 2, 0.4) + 0.5 * rumble + 1.0 * flash, 0, 2))
	ctx.light("ConeLight", clamp(0.75 + 0.15 * w(t, 3, 0.1) + 0.3 * rumble + 0.6 * flash, 0, 2))

	if ctx.crossed(PUFF) then
		ctx.emit("SmokePuff", 5)
		ctx.emit("LandSparks", 8)
	end
	if ctx.crossed(POP) then
		ctx.emit("SmokePuff", 16)
		ctx.emit("EruptSparks", 55)
	end
	if ctx.crossed(LAND) then
		ctx.emit("LandSparks", 18)
		ctx.emit("SmokePuff", 4)
	end
end

return M
