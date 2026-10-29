--!nocheck
-- Elderhorn Titan motion (Guardian #10 / final boss). A silent ancient judge:
-- slow and majestic until angered, then terrifying.
--   Idle   - slow majestic breathing, head slowly scans left/right, antlers sway
--            with their lanterns + blossoms, ear flicks, tail flicks, a hoof
--            scrape gag, then the SHOW-OFF: head dips, lifts high, antlers flare
--            and BLOOM (leaf/flower burst, rune core light pulse, low bellow),
--            closing hoof stamp.
--   Alert  - startle, crouch, REARS UP on the hind legs, colossal roar with the
--            antlers flaring glowing thorns, leaf storm + rune pulse, front hooves
--            bicycle, then crashes down: ground quake (rock ring + dust).
--   Chase  - a real 4-beat rotary GALLOP (hind L, hind R, fore L, fore R, then a
--            gathered suspension); hooves plant + push (IK), dust on every strike,
--            body rocks, mane/beard/strands stream back, snarling jaw.
--   Attack - wind-up, lowered ANTLER CHARGE SWEEP, then the right fore hoof rears
--            and STOMPS: quake shockwave.
--   Catch  - rears triumphantly, front hooves paw the air, huge bellow + bloom.
--   GiveUp - slams both front hooves (quake), roars at the line, snorts, then
--            turns its head away proudly.
--   Return - slow majestic 4-beat walk, chin up.
-- All legs are driven by a 2-bone IK so planted hooves never slide or sink.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, env, E = L.ang, L.pa, L.wave, L.env, L.ease

local sqrt, max, min, abs, clamp = math.sqrt, math.max, math.min, math.abs, math.clamp
local atan2, acos, sin, cos, rad, pi = math.atan2, math.acos, math.sin, math.cos, math.rad, math.pi
local V3, CF = Vector3.new, CFrame.new

------------------------------------------------------------------------
-- Rig (rest pivots, model space)
------------------------------------------------------------------------
local BODYP = V3(0, 15, 9)
local CHESTP = V3(0, 16, 0)
local LEGS = {
	-- name, upper bone, knee bone, hoof bone, parent, upper pivot, knee pivot, hoof pivot, bend
	FR = { "FLegR", "FKneeR", "FHoofR", "Chest", V3(5.6, 14.5, -9), V3(5.6, 8, -11.2), V3(5.6, 2.5, -9), -1 },
	FL = { "FLegL", "FKneeL", "FHoofL", "Chest", V3(-5.6, 14.5, -9), V3(-5.6, 8, -11.2), V3(-5.6, 2.5, -9), -1 },
	HR = { "HLegR", "HKneeR", "HHoofR", "Body", V3(5.6, 14.5, 10), V3(5.6, 8, 12.2), V3(5.6, 2.5, 10), 1 },
	HL = { "HLegL", "HKneeL", "HHoofL", "Body", V3(-5.6, 14.5, 10), V3(-5.6, 8, 12.2), V3(-5.6, 2.5, 10), 1 },
}
local LEG_ORDER = { "FR", "FL", "HR", "HL" }
for _, g in LEGS do
	local s1, s2 = g[6] - g[5], g[7] - g[6]
	g.L1 = sqrt(s1.Y ^ 2 + s1.Z ^ 2)
	g.L2 = sqrt(s2.Y ^ 2 + s2.Z ^ 2)
	g.A1 = atan2(s1.Z, s1.Y)
	g.A2 = atan2(s2.Z, s2.Y)
end

local function wrap(a)
	return (a + pi) % (2 * pi) - pi
end

-- 2-bone leg IK (sagittal plane + a lateral swing). Puts the hoof pivot at
-- `target` (model space) with world rotation `footRot`.
local function legIK(g, parentW, parentP, target, footRot)
	local frame = parentW * CF(g[5] - parentP)
	local q = frame:PointToObjectSpace(target)
	local gamma = atan2(q.X, -q.Y)
	local rz = CFrame.Angles(0, 0, gamma)
	local q2 = rz:PointToObjectSpace(q)
	local L1, L2 = g.L1, g.L2
	local D = clamp(sqrt(q2.Y ^ 2 + q2.Z ^ 2), abs(L1 - L2) + 0.05, L1 + L2 - 1e-3)
	local delta = g[8] * acos(clamp((D * D - L1 * L1 - L2 * L2) / (2 * L1 * L2), -1, 1))
	local phi = atan2(q2.Z, q2.Y)
	local s1 = phi - atan2(L2 * sin(delta), L1 + L2 * cos(delta))
	local upT = rz * CFrame.Angles(wrap(s1 - g.A1), 0, 0)
	local knT = CFrame.Angles(wrap(delta - (g.A2 - g.A1)), 0, 0)
	local hfT = (parentW.Rotation * upT * knT):Inverse() * footRot
	return upT, knT, hfT
end

------------------------------------------------------------------------
-- Pose description shared by every state (all zeros = neutral stance)
------------------------------------------------------------------------
local function newS()
	return {
		bx = 0, by = 0, bz = 0, bp = 0, byaw = 0, br = 0, -- body (hind-hip pivot)
		cp = 0, cyaw = 0, cr = 0, -- chest
		n1 = 0, n2 = 0, hp = 0, look = 0, tilt = 0, -- neck / head pitch, yaw, roll
		jaw = 0, anger = 0, blink = 0, squint = 0, earX = 0, earZ = 0,
		flare = 0, sweep = 0, sway = 0, wind = 0, tail = 0, wag = 0,
		thorn = 0, glow = 0, eyeFlare = 0, core = 0.6, mouth = 0,
		orbit = 0, fling = 0, quake = -1, legs = {},
	}
end

-- leg helpers: planted at rest + offsets, or tucked relative to its shoulder
local function rest(n)
	return LEGS[n][7]
end
local function plant(S, n, dx, dy, dz, pitch)
	local r = LEGS[n][7]
	S.legs[n] = { p = V3(r.X + (dx or 0), r.Y + (dy or 0), r.Z + (dz or 0)), hp = pitch or 0 }
end
-- tuck: blend k (0 = planted at rest, 1 = hoof at `rel` from its upper pivot,
-- in the parent's frame)
local function tuck(S, n, k, rel, pitch)
	local cur = S.legs[n] or { p = rest(n), hp = 0 }
	S.legs[n] = { p = cur.p, hp = (cur.hp or 0) * (1 - k) + (pitch or -60) * k, rel = rel, k = k }
end

local function quakeFX(ctx, S, t, at)
	local q = t - at
	if q >= 0 and q < 1.0 then
		S.quake = q
	end
	if ctx.crossed(at) then
		ctx.emit("QuakeDust", 45)
		ctx.emit("DustR", 14)
		ctx.emit("DustL", 14)
		ctx.emit("HindDust", 8)
		ctx.emit("RuneBurst", 25)
	end
end

local function blinkAt(c, starts)
	local b = 0
	for _, s in starts do
		b = max(b, env(c, s, 0.06, 0.05, 0.1))
	end
	return b
end

------------------------------------------------------------------------
-- Apply: body + IK legs + head + all secondary motion + FX
------------------------------------------------------------------------
local ORB_DIR = { 1, -1, 1, -1, 1, -1 }
local function apply(S, t, pose, ctx)
	local bodyT = CF(S.bx, S.by, S.bz) * ang(S.bp, S.byaw, S.br)
	pose.Body = bodyT
	local chestT = ang(S.cp, S.cyaw, S.cr)
	pose.Chest = chestT
	local bodyW = CF(BODYP) * bodyT
	local chestW = bodyW * CF(CHESTP - BODYP) * chestT

	-- legs
	for _, n in LEG_ORDER do
		local g = LEGS[n]
		local parentW, parentP = bodyW, BODYP
		if g[4] == "Chest" then
			parentW, parentP = chestW, CHESTP
		end
		local d = S.legs[n] or { p = g[7], hp = 0 }
		local target = d.p
		if d.rel and d.k and d.k > 0 then
			local relW = (parentW * CF(g[5] - parentP)) * d.rel
			target = target:Lerp(relW, d.k)
		end
		local up, kn, hf = legIK(g, parentW, parentP, target, CFrame.Angles(rad(d.hp or 0), 0, 0))
		pose[g[1]] = up
		pose[g[2]] = kn
		pose[g[3]] = hf
	end

	-- neck / head (look = yaw, shared down the neck)
	pose.Neck1 = ang(S.n1, S.look * 0.3, S.tilt * 0.3)
	pose.Neck2 = ang(S.n2, S.look * 0.3, S.tilt * 0.3)
	pose.Head = ang(S.hp, S.look * 0.4, S.tilt * 0.4)
	pose.Jaw = ang(S.jaw, 0, 0)

	-- brows: drop + tilt inner end down when angry; lids blink / squint
	L.both(pose, "Brow", CF(0, -0.35 * S.anger, 0.1 * S.anger) * ang(0, 0, 9 * S.anger))
	local lidY, lidShow = 0, false
	if S.blink > 0.45 then
		lidY, lidShow = -0.75 * S.blink, true
	elseif S.squint > 0.2 then
		lidY, lidShow = 0.25 - 0.2 * S.squint, true
	end
	L.both(pose, "Lid", CF(0, lidY, 0))
	if lidShow then
		ctx.transparency("EyelidR", 0)
		ctx.transparency("EyelidL", 0)
	end
	if S.eyeFlare > 0.05 then
		ctx.transparency("EyeFlareR", 1 - 0.85 * S.eyeFlare)
		ctx.transparency("EyeFlareL", 1 - 0.85 * S.eyeFlare)
	end

	-- ears
	L.both(pose, "Ear", ang(S.earX, 0, S.earZ))

	-- antlers: idle sway + flare (raise/spread) + sweep (tips forward)
	local sw = S.sway
	L.both(pose, "Antler1", ang(-2 * S.flare, 6 * S.sweep, 9 * S.flare + 1.5 * sw * wave(t, 0.25)))
	L.both(pose, "Antler2", ang(0, 5 * S.sweep, 8 * S.flare + 2.0 * sw * wave(t, 0.25, -0.08)))
	L.both(pose, "Antler3", ang(3 * S.flare, 4 * S.sweep, 9 * S.flare + 2.5 * sw * wave(t, 0.25, -0.16)))
	-- hanging lanterns + moss strands: pendulums that hang back against the
	-- head pitch and swing with the wind
	local hang = -(S.n1 + S.n2 + S.hp + S.bp) * 0.6
	L.both(pose, "Lantern", ang(hang + 8 * S.wind + 6 * wave(t, 0.5, 0.1), 0, -(9 * S.flare * 1.8) + 5 * wave(t, 0.25, 0.3)))
	L.both(pose, "Strand", ang(hang + 14 * S.wind + 7 * wave(t, 0.5, 0.25), 0, -(9 * S.flare * 2.6) + 6 * wave(t, 0.25, 0.45)))

	-- mane, beard, tail
	local gust = 0.5 + S.wind
	for i = 1, 3 do
		pose["Mane" .. i] = ang(S.wind * 10 + 3 * gust * wave(t, 0.5 + S.wind * 2, -0.12 * i), 0, 3 * gust * wave(t, 0.25, -0.1 * i))
	end
	pose.Beard = ang(-S.wind * 24 + 4 * gust * wave(t, 0.5 + S.wind * 2, -0.2), 0, 4 * wave(t, 0.25, -0.3))
	pose.Tail = ang(-S.tail, S.wag, 0)

	-- orbiting spirit wisps
	pose.Orbit = ang(0, S.orbit, 0)
	for i = 1, 6 do
		local dir = ORB_DIR[i]
		pose["Orb" .. i] = pa(2.5 * S.fling * dir, 0.8 * wave(t, 0.5, i * 0.17) + 2 * S.fling, 0, 40 * t * dir, 70 * t, 20 * i)
	end

	-- quake rocks burst out of the ground in a ring and fall back
	local q = S.quake
	for k = 1, 14 do
		local a = rad((k - 1) / 14 * 360)
		if q >= 0 then
			local u = q / 1.0
			local out = 1 + 9 * E.cubicOut(u)
			local up = 3.2 * sin(pi * min(1, u * 1.15)) - 0.4 * u
			pose["Rock" .. k] = CF(-sin(a) * out, up, -cos(a) * out) * ang(-40 * u, 0, (k % 2 == 0 and 30 or -30) * u)
			local tr = u < 0.65 and 0 or (u - 0.65) / 0.35
			ctx.transparency("Rock" .. k, tr)
			ctx.transparency("RockTop" .. k, tr)
		else
			pose["Rock" .. k] = CF()
		end
	end

	-- glow FX
	if S.thorn > 0.05 then
		local tr = 1 - S.thorn
		for i = 1, 4 do
			ctx.transparency("Thorn" .. i .. "R", tr)
			ctx.transparency("Thorn" .. i .. "L", tr)
		end
	end
	if S.glow > 0.05 then
		ctx.transparency("RuneGlow", 1 - 0.6 * S.glow)
	end
	ctx.light("CoreLight", clamp(S.core, 0, 1.8))
	ctx.light("MouthLight", clamp(S.mouth, 0, 1.6))
end

-- common idle-ish secondary values
local function breathe(S, t, amt)
	local b = wave(t, 0.25)
	S.by += -0.25 * b * amt
	S.cp += 1.2 * b * amt
	S.n1 += -1.2 * b * amt
	S.hp += 0.8 * b * amt
	return b
end

------------------------------------------------------------------------
-- IDLE (12 s): guarding the grove
------------------------------------------------------------------------
local function idle(t, pose, ctx)
	local c = t % 12
	local S = newS()
	S.sway = 1
	S.orbit = 30 * t
	local b = breathe(S, t, 1)
	S.core = 0.55 + 0.15 * b

	-- slow scanning look: left, hold, right, hold, centre
	S.look = L.track(c, { { 0.8, 0 }, { 2.2, 28, "sineInOut" }, { 3.6, 28 }, { 4.9, -26, "sineInOut" }, { 6.2, -26 }, { 7.0, 0, "sineInOut" } })
	S.tilt = -0.15 * S.look
	-- squints while scanning (judging)
	S.squint = env(c, 1.6, 0.3, 1.4, 0.3) + env(c, 4.6, 0.3, 1.2, 0.3)
	S.anger = 0.3 * S.squint

	-- gag: snort + ear flicks at the end of the left look
	local snort = env(c, 3.0, 0.1, 0.05, 0.35, "backOut", "quadInOut")
	S.hp += 6 * snort
	S.jaw -= 6 * snort
	local flick = env(c, 2.7, 0.08, 0.05, 0.2) + env(c, 9.6, 0.08, 0.05, 0.2)
	S.earX = -14 * flick + 3 * wave(t, 0.5)
	S.earZ = 12 * flick + 2 * wave(t, 0.25, 0.2)
	if ctx.crossed(3.05) then ctx.emit("Sparkles", 6) end

	-- gag: right fore hoof scrapes the ground twice (head glances down at it)
	local paw = env(c, 5.2, 0.25, 0.9, 0.3)
	local scrape = wave(c - 5.45, 1.25)
	S.hp -= 6 * paw
	S.n1 -= 4 * paw
	S.br += -1.0 * paw
	plant(S, "FR", 0, paw * (2.4 + 1.2 * scrape), paw * (-1.0 + 1.8 * scrape), paw * -25)
	if ctx.crossed(5.85) or ctx.crossed(6.65) then ctx.emit("DustR", 6) end

	-- SHOW-OFF: dip, rise, antlers flare + bloom, low bellow, hoof stamp
	local dip = env(c, 7.0, 0.55, 0.05, 0.35, "sineInOut", "quadIn")
	local rise = env(c, 7.55, 0.6, 1.6, 0.8, "backOut", "sineInOut")
	local bloom = env(c, 8.05, 0.25, 1.3, 0.9, "backOut", "sineInOut")
	local bellow = env(c, 8.3, 0.35, 0.9, 0.4, "quadOut", "quadInOut")
	S.n1 += -10 * dip + 16 * rise
	S.n2 += -6 * dip + 6 * rise
	S.hp += -10 * dip + 12 * rise
	S.by += -0.7 * dip + 0.2 * rise
	S.bp += 1.0 * rise
	S.cp += 3 * rise
	S.flare = -0.3 * dip + 1.0 * bloom
	S.sweep = 0.6 * dip
	S.glow = bloom * (0.75 + 0.25 * wave(c, 2))
	S.core += 1.1 * bloom
	S.jaw += -28 * bellow
	S.mouth = 0.5 * bellow
	S.squint = max(S.squint * (1 - rise), 0)
	S.earX += -18 * rise
	S.fling = 0.7 * bloom
	S.wag = 10 * bloom * wave(c, 1.5)
	if ctx.crossed(8.1) then
		ctx.emit("LeafStorm", 70)
		ctx.emit("RuneBurst", 45)
	end
	if ctx.crossed(8.9) then ctx.emit("LeafStorm", 25) end
	-- closing stamp of the left fore hoof
	local lift = env(c, 9.95, 0.25, 0.05, 0.12, "quadOut", "quadIn")
	local stampHit = env(c, 10.37, 0.04, 0.04, 0.6, "linear", "elasticOut")
	plant(S, "FL", 0, 3.2 * lift, -0.8 * lift, -20 * lift)
	S.by -= 0.5 * stampHit
	S.br += 1.2 * lift
	if ctx.crossed(10.37) then
		ctx.emit("DustL", 16)
		ctx.emit("QuakeDust", 8)
	end

	-- tail flicks
	S.tail = 8 + 14 * env(c, 2.9, 0.12, 0.1, 0.3) + 14 * env(c, 6.9, 0.12, 0.1, 0.3)
	S.wag += 10 * wave(t, 0.5) * (env(c, 2.9, 0.1, 0.5, 0.2) + env(c, 6.9, 0.1, 0.5, 0.2))

	-- blinks (quick lid drop, a double one mid loop)
	S.blink = blinkAt(c, { 1.2, 4.3, 4.55, 11.0 })
	apply(S, t, pose, ctx)
end

------------------------------------------------------------------------
-- ALERT (2.4 s): MY PLANT! rear up, colossal roar, quake slam
------------------------------------------------------------------------
local ALERT_HIT = 1.72
local function alert(t, pose, ctx)
	local S = newS()
	S.orbit = 30 * t
	local jolt = env(t, 0.0, 0.12, 0.06, 0.25, "backOut", "quadInOut")
	local crouch = env(t, 0.22, 0.3, 0.05, 0.25, "cubicOut", "quadIn")
	local rear = env(t, 0.5, 0.42, 0.62, 0.2, "backOut", "quadIn") -- up 0.92, down by 1.74
	local roar = env(t, 0.78, 0.14, 0.72, 0.3, "backOut", "quadInOut")
	local hit = env(t, ALERT_HIT, 0.04, 0.04, 0.6, "linear", "elasticOut")
	local ready = env(t, 1.85, 0.2, 0.15, 0.2)
	local rage = env(t, 0.05, 0.12, 2.0, 0.2)

	S.bz = 0.6 * jolt - 0.4 * crouch
	S.by = -1.4 * crouch - 1.0 * rear - 1.6 * hit
	S.bp = -4 * crouch + 33 * rear - 3 * hit
	S.cp = 2 * jolt + 4 * rear - 3 * hit
	S.n1 = 10 * jolt - 10 * crouch - 22 * rear + 6 * roar - 8 * hit - 6 * ready
	S.n2 = 6 * jolt - 4 * crouch - 8 * rear + 4 * roar - 4 * hit
	S.hp = 14 * jolt - 6 * crouch + 9 * roar - 8 * hit
	S.look = 9 * roar * wave(t, 4.5)
	S.tilt = 6 * roar * wave(t, 4.5, 0.25)
	S.jaw = -8 * jolt - 58 * roar - 6 * roar * wave(t, 9) - 12 * hit
	S.anger = rage
	S.squint = 0.6 * crouch + 0.7 * hit
	S.eyeFlare = rage
	S.earX = 20 * roar + 14 * crouch
	S.earZ = -16 * jolt
	S.flare = -0.4 * crouch + 1.2 * roar
	S.thorn = env(t, 0.82, 0.12, 1.0, 0.3)
	S.glow = env(t, 0.82, 0.1, 0.8, 0.4)
	S.core = 0.6 + 1.2 * roar
	S.mouth = 1.5 * roar
	S.wind = 0.6 * roar
	S.tail = 10 + 22 * rear
	S.wag = 12 * roar * wave(t, 5)
	S.fling = env(t, ALERT_HIT, 0.08, 0.2, 0.45, "backOut", "quadInOut")

	-- front legs: tuck + bicycle while reared, crash down
	local kw = clamp(rear * 1.25, 0, 1)
	local cyc = (t - 0.75) * 3.2
	tuck(S, "FR", kw, V3(0, -7.4 + 2.0 * sin(2 * pi * cyc), -3.2 - 2.2 * cos(2 * pi * cyc)), -40)
	tuck(S, "FL", kw, V3(0, -7.4 + 2.0 * sin(2 * pi * cyc + pi), -3.2 - 2.2 * cos(2 * pi * cyc + pi)), -40)

	if ctx.crossed(0.86) then
		ctx.emit("RoarBurst", 60)
		ctx.emit("LeafStorm", 90)
		ctx.emit("RuneBurst", 50)
	end
	if ctx.crossed(1.2) then ctx.emit("RoarBurst", 30) end
	if ctx.crossed(0.3) then ctx.emit("HindDust", 10) end
	quakeFX(ctx, S, t, ALERT_HIT)
	apply(S, t, pose, ctx)
end

------------------------------------------------------------------------
-- CHASE (0.8 s loop): rotary gallop
------------------------------------------------------------------------
local CH_LEN = 0.8
local CH_STRIDE = 10.0 -- hoof travel while planted
local CH_DUTY = 0.38
local CH_SPEED = CH_STRIDE / (CH_DUTY * CH_LEN) -- 32.9 studs/s
local GAIT = { HL = 0.0, HR = 0.1, FL = 0.38, FR = 0.48 }
local DUST = { HL = "HindDust", HR = "HindDust", FL = "DustL", FR = "DustR" }

local function gaitLeg(S, n, f, off, stride, duty, lift, curl)
	local u = (f - off) % 1
	local z, y, hp
	if u < duty then
		local s = u / duty
		z = -stride / 2 + stride * s
		y = 0
		hp = 0
	else
		local w = (u - duty) / (1 - duty)
		local e = L.smoothstep(w)
		z = stride / 2 - stride * e
		y = lift * sin(pi * w) ^ 0.8
		hp = curl * sin(pi * w)
	end
	plant(S, n, 0, y, z, hp)
end

local function chase(t, pose, ctx)
	local f = (t % CH_LEN) / CH_LEN
	local S = newS()
	local w = 2 * pi * f
	S.orbit = 30 * t
	S.by = -0.9 + 0.8 * cos(w - 2 * pi * 0.9)
	S.bp = -3 + 6 * cos(w - 2 * pi * 0.2)
	S.br = 1.2 * sin(w)
	S.cp = 1.5 * cos(w - 2 * pi * 0.55)
	S.n1 = -5 + 6 * cos(w - 2 * pi * 0.7)
	S.n2 = -2 + 3 * cos(w - 2 * pi * 0.8)
	S.hp = -4 + 4 * cos(w - 2 * pi * 0.85)
	S.jaw = -18 - 8 * (0.5 + 0.5 * cos(w - 2 * pi * 0.65))
	S.anger = 1
	S.squint = 0.6
	S.eyeFlare = 0.7
	S.earX = 28
	S.flare = 0.15
	S.sweep = 0.4
	S.wind = 1
	S.tail = 26 + 6 * cos(w)
	S.wag = 6 * sin(w)
	S.core = 0.9 + 0.3 * cos(2 * w)
	for n, off in GAIT do
		local front = n:sub(1, 1) == "F"
		gaitLeg(S, n, f, off, CH_STRIDE, CH_DUTY, front and 4.4 or 3.6, front and -28 or -18)
		if ctx.crossed(off * CH_LEN + 0.01) then
			ctx.emit(DUST[n], front and 9 or 6)
		end
	end
	if ctx.crossed(0.39 * CH_LEN) then ctx.emit("LeafStorm", 4) end
	apply(S, t, pose, ctx)
end

------------------------------------------------------------------------
-- ATTACK (1.4 s): antler charge sweep + fore hoof stomp shockwave
------------------------------------------------------------------------
local ATK_HIT = 0.92
local function attack(t, pose, ctx)
	local S = newS()
	S.orbit = 30 * t
	local wind = env(t, 0.0, 0.32, 0.03, 0.15, "cubicOut", "quadIn")
	local lunge = env(t, 0.3, 0.16, 0.12, 0.45, "backOut", "sineInOut")
	local yaw = L.track(t, { { 0.0, 0 }, { 0.32, -32, "cubicOut" }, { 0.56, 38, "backOut" }, { 0.85, 4, "sineInOut" }, { 1.3, 0, "sineInOut" } })
	local raise = env(t, 0.56, 0.24, 0.05, 0.07, "quadOut", "quadIn") -- hoof up, slams at 0.92
	local hit = env(t, ATK_HIT, 0.04, 0.04, 0.45, "linear", "elasticOut")

	S.bz = 1.4 * wind - 3.2 * lunge
	S.by = -0.5 * wind - 1.2 * lunge - 1.5 * hit
	S.bp = 3 * wind - 4 * lunge + 2 * raise - 3 * hit
	S.byaw = 0.15 * yaw
	S.br = -2.5 * raise
	S.cp = -3 * lunge + 2 * raise
	S.n1 = 8 * wind - 22 * lunge + 4 * raise - 8 * hit
	S.n2 = 4 * wind - 8 * lunge
	S.hp = 10 * wind - 16 * lunge + 6 * raise - 6 * hit
	S.look = yaw
	S.tilt = -0.35 * yaw
	S.jaw = -10 * wind - 30 * lunge - 40 * hit
	S.anger = 1
	S.squint = 0.8 * wind + 0.6
	S.eyeFlare = 1
	S.earX = 30
	S.flare = 0.5 * lunge
	S.sweep = 1.2 * lunge
	S.thorn = env(t, 0.36, 0.08, 0.3, 0.3)
	S.glow = env(t, ATK_HIT, 0.04, 0.1, 0.4)
	S.core = 0.7 + 1.1 * hit
	S.mouth = 1.2 * hit
	S.wind = 0.5 * lunge
	S.tail = 14 + 14 * lunge
	S.wag = 10 * hit
	S.fling = env(t, ATK_HIT, 0.06, 0.1, 0.35, "backOut", "quadInOut")
	-- right fore hoof rears up then stomps
	tuck(S, "FR", raise, V3(0, -6.2, -4.5), -45)
	if ctx.crossed(0.5) then ctx.emit("LeafStorm", 35) end
	if ctx.crossed(ATK_HIT) then ctx.emit("RoarBurst", 30) end
	quakeFX(ctx, S, t, ATK_HIT)
	apply(S, t, pose, ctx)
end

------------------------------------------------------------------------
-- CATCH (2.2 s): rears triumphantly and bellows
------------------------------------------------------------------------
local CATCH_LAND = 1.98
local function catch(t, pose, ctx)
	local S = newS()
	S.orbit = 30 * t
	local crouch = env(t, 0.0, 0.32, 0.05, 0.2, "cubicOut", "quadIn")
	local rear = env(t, 0.35, 0.45, 0.85, 0.33, "backOut", "quadIn") -- down by 1.98
	local bellow = env(t, 0.7, 0.18, 0.85, 0.3, "backOut", "quadInOut")
	local land = env(t, CATCH_LAND, 0.04, 0.03, 0.2, "linear", "quadOut")
	S.by = -1.2 * crouch - 0.9 * rear - 0.9 * land
	S.bp = -3 * crouch + 37 * rear - 2 * land
	S.cp = 5 * rear
	S.n1 = -8 * crouch - 24 * rear + 5 * bellow
	S.n2 = -3 * crouch - 8 * rear + 4 * bellow
	S.hp = -6 * crouch + 12 * bellow
	S.look = 12 * bellow * wave(t, 2.2)
	S.tilt = 8 * bellow * wave(t, 2.2, 0.2)
	S.jaw = -62 * bellow - 6 * bellow * wave(t, 8) - 4 * crouch
	S.anger = 0.4 * (1 - bellow)
	S.squint = 0.5 * crouch
	S.eyeFlare = bellow
	S.earX = 24 * bellow
	S.flare = 1.2 * bellow
	S.thorn = env(t, 0.72, 0.12, 0.85, 0.35)
	S.glow = env(t, 0.75, 0.12, 0.85, 0.35) * (0.8 + 0.2 * wave(t, 4))
	S.core = 0.6 + 1.2 * bellow
	S.mouth = 1.4 * bellow
	S.wind = 0.5 * bellow
	S.tail = 10 + 24 * rear
	S.wag = 14 * bellow * wave(t, 3)
	S.fling = env(t, 0.8, 0.2, 0.7, 0.4, "backOut", "quadInOut")
	local kw = clamp(rear * 1.25, 0, 1)
	local cyc = (t - 0.5) * 2.6
	tuck(S, "FR", kw, V3(0, -7.0 + 2.2 * sin(2 * pi * cyc), -3.6 - 2.4 * cos(2 * pi * cyc)), -40)
	tuck(S, "FL", kw, V3(0, -7.0 + 2.2 * sin(2 * pi * cyc + 2.2), -3.6 - 2.4 * cos(2 * pi * cyc + 2.2)), -40)
	if ctx.crossed(0.8) then
		ctx.emit("RoarBurst", 55)
		ctx.emit("LeafStorm", 80)
		ctx.emit("RuneBurst", 60)
	end
	if ctx.crossed(1.3) then ctx.emit("LeafStorm", 30) end
	if ctx.crossed(CATCH_LAND) then
		ctx.emit("DustR", 12)
		ctx.emit("DustL", 12)
		ctx.emit("QuakeDust", 14)
	end
	S.blink = 0
	apply(S, t, pose, ctx)
end

------------------------------------------------------------------------
-- GIVE UP (2.8 s): double hoof slam, roar at the line, proud turn away
------------------------------------------------------------------------
local GU_HIT = 0.5
local function giveUp(t, pose, ctx)
	local S = newS()
	S.orbit = 30 * t
	local hop = env(t, 0.0, 0.3, 0.02, 0.18, "cubicOut", "quadIn") -- slam at 0.5
	local hit = env(t, GU_HIT, 0.04, 0.04, 0.5, "linear", "elasticOut")
	local roar = env(t, 0.72, 0.14, 0.62, 0.25, "backOut", "quadInOut")
	local snort = env(t, 1.75, 0.1, 0.05, 0.3, "backOut", "quadInOut")
	local proud = env(t, 1.95, 0.4, 0.25, 0.2, "sineInOut", "sineInOut")
	S.by = -0.4 * hop - 1.6 * hit
	S.bp = 12 * hop - 3 * hit - 2 * roar
	S.bz = -0.8 * roar
	S.byaw = 5 * proud
	S.cp = 3 * hop - 3 * roar
	S.n1 = 4 * hop - 8 * hit - 14 * roar + 10 * proud
	S.n2 = -4 * roar + 4 * proud
	S.hp = 6 * hop - 4 * hit - 4 * roar + 8 * snort + 10 * proud
	S.look = 8 * roar * wave(t, 4) + 40 * proud
	S.tilt = -10 * proud
	S.jaw = -16 * hit - 60 * roar - 6 * roar * wave(t, 9) - 10 * snort
	S.anger = max(1 - proud, 0.3)
	S.squint = 0.5 + 0.4 * proud
	S.eyeFlare = max(hit, roar)
	S.earX = 26 * roar - 10 * proud
	S.flare = 0.9 * roar
	S.thorn = env(t, 0.74, 0.1, 0.6, 0.3)
	S.glow = env(t, GU_HIT, 0.05, 0.5, 0.4)
	S.core = 0.6 + 1.0 * max(hit, roar)
	S.mouth = 1.4 * roar
	S.wind = 0.5 * roar
	S.tail = 10 + 16 * roar - 8 * proud
	S.wag = 10 * snort
	S.fling = env(t, GU_HIT, 0.06, 0.1, 0.35, "backOut", "quadInOut")
	-- both fore hooves rise then SLAM
	local kw = hop
	tuck(S, "FR", kw, V3(0, -8.5, -2.5), -20)
	tuck(S, "FL", kw, V3(0, -8.5, -2.5), -20)
	if ctx.crossed(0.78) then
		ctx.emit("RoarBurst", 60)
		ctx.emit("LeafStorm", 50)
	end
	if ctx.crossed(1.1) then ctx.emit("RoarBurst", 30) end
	if ctx.crossed(1.8) then ctx.emit("Sparkles", 10) end
	quakeFX(ctx, S, t, GU_HIT)
	apply(S, t, pose, ctx)
end

------------------------------------------------------------------------
-- RETURN (1.6 s loop): slow majestic 4-beat walk
------------------------------------------------------------------------
local RT_LEN = 1.6
local RT_STRIDE = 6.8
local RT_DUTY = 0.72
local RT_SPEED = RT_STRIDE / (RT_DUTY * RT_LEN) -- 5.9 studs/s
local WALK = { HL = 0.0, FL = 0.25, HR = 0.5, FR = 0.75 }

local function returnWalk(t, pose, ctx)
	local f = (t % RT_LEN) / RT_LEN
	local w = 2 * pi * f
	local S = newS()
	S.sway = 1
	S.orbit = 30 * t
	S.by = -0.35 + 0.3 * cos(2 * w)
	S.br = 1.6 * sin(w)
	S.byaw = 1.2 * sin(w)
	S.cp = 0.8 * cos(2 * w)
	S.n1 = 6 + 2.5 * cos(2 * w - 0.6)
	S.n2 = 2
	S.hp = 4 - 2.0 * cos(2 * w - 0.9)
	S.look = -2.5 * sin(w)
	S.tilt = -2 * sin(w)
	S.anger = 0.45
	S.squint = 0.35
	S.earX = -6 + 4 * cos(2 * w)
	S.wind = 0.15
	S.tail = 8
	S.wag = 8 * sin(w)
	for n, off in WALK do
		local front = n:sub(1, 1) == "F"
		gaitLeg(S, n, f, off, RT_STRIDE, RT_DUTY, front and 2.6 or 2.0, front and -35 or -20)
		if ctx.crossed(off * RT_LEN + 0.02) then
			ctx.emit(DUST[n], 3)
		end
	end
	S.blink = blinkAt(t % RT_LEN, { 1.1 }) * (((t // RT_LEN) % 3 == 0) and 1 or 0)
	apply(S, t, pose, ctx)
end

------------------------------------------------------------------------
local M = {}
local PROPS = { RuneGlow = 1, EyelidR = 1, EyelidL = 1, EyeFlareR = 1, EyeFlareL = 1 }
for i = 1, 4 do
	PROPS["Thorn" .. i .. "R"] = 1
	PROPS["Thorn" .. i .. "L"] = 1
end
for k = 1, 14 do
	PROPS["Rock" .. k] = 1
	PROPS["RockTop" .. k] = 1
end
M.Props = PROPS
M.States = {
	Idle = { Loop = true, Length = 12, Update = idle },
	Alert = { Length = 2.4, Update = alert },
	Chase = { Loop = true, Length = CH_LEN, Speed = CH_SPEED, Update = chase },
	Attack = { Length = 1.4, Blend = 0.3, Update = attack },
	Catch = { Length = 2.2, Update = catch },
	GiveUp = { Length = 2.8, Blend = 0.12, Update = giveUp },
	Return = { Loop = true, Length = RT_LEN, Speed = RT_SPEED, Update = returnWalk },
}
M.Base = "Idle"
M.Reel = { { "Idle" }, { "Alert" }, { "Chase", 3.6 }, { "Attack" }, { "Catch" }, { "Chase", 1.8 }, { "GiveUp" }, { "Return", 3.6 } }
return L.states(M)
