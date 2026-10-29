--!nocheck
-- Bogjaw Gator motion (guardian states). Sneaky, lazy, sudden snapper.
--   Idle   (12 s loop) lies low peeking -> HUGE lazy yawn -> dozes off (Zzz, nose
--          bubbles) -> a fly buzzes in, one eye pops open, SNAP! smug chewing ->
--          show-off: rises into a high walk and does a big double JAW CLAP.
--   Alert  eyes snap open, flinch, then rears up high, jaws gape with a hissing
--          tremble, tail lashes, leaves/dust/splash burst.
--   Chase  fast high-walk trot with a big S-wiggle through chest, hips and tail.
--   Attack lunging CHOMP (front feet hop forward) + tail-whip follow-up.
--   Catch  full DEATH ROLL (360 deg spin in a hop) then a smug grin.
--   GiveUp foot-stomping tantrum, big sigh, slumps and sinks low, sulky bubbles.
--   Return lazy waddle home.
-- Legs use a 2-bone IK with a knee pole taken from the rest pose, so feet plant
-- on the ground in every state (the body sinks if a foot can't be reached).
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease
local sqrt, max, min, abs, clamp = math.sqrt, math.max, math.min, math.abs, math.clamp
local sin, cos, rad, pi = math.sin, math.cos, math.rad, math.pi
local V = Vector3.new

local M = {}

------------------------------------------------------------------------
-- Rig constants (rest pivots, model space; keep in sync with build.luau)
------------------------------------------------------------------------
local BODY_P = V(0, 4.2, 1.5)
local CHEST_P = V(0, 4.2, -0.4)
local LOW = -1.3 -- idle "lying low" body drop

local LEGS = {}
local function addLeg(key, parent, pp, hip, knee, foot, names)
	for s = 1, -1, -2 do
		local sd = s == 1 and "R" or "L"
		local function m(p)
			return V(p.X * s, p.Y, p.Z)
		end
		local h, k, f = m(hip), m(knee), m(foot)
		local d1, d2 = k - h, f - k
		local dir = (f - h).Unit
		local pole = (d1 - dir * d1:Dot(dir)).Unit
		table.insert(LEGS, {
			key = key .. sd, parent = parent, pp = pp, hip = h, foot = f, s = s,
			d1 = d1, d2 = d2, l1 = d1.Magnitude, l2 = d2.Magnitude, pole = pole,
			b = { names[1] .. sd, names[2] .. sd, names[3] .. sd },
		})
	end
end
addLeg("F", "Chest", CHEST_P, V(2.9, 3.6, -2.6), V(4.7, 2.7, -2.4), V(4.6, 0.65, -2.7), { "Arm", "Forearm", "Hand" })
addLeg("R", "Body", BODY_P, V(2.8, 3.6, 3.2), V(4.8, 2.9, 2.9), V(4.7, 0.65, 3.4), { "Thigh", "Shin", "Foot" })
local LEG = {}
for _, lg in LEGS do
	LEG[lg.key] = lg
end

-- tucked legs for the death roll (right side; left mirrored)
local TUCK = {
	F = { ang(10, 0, 32), ang(-20, 0, -100), ang(0, 0, 45) },
	R = { ang(-10, 0, 30), ang(20, 0, -100), ang(0, 0, 45) },
}

local function rotTo(a, b)
	local axis = a:Cross(b)
	local s = axis.Magnitude
	if s < 1e-6 then
		return CFrame.new()
	end
	return CFrame.fromAxisAngle(axis / s, math.atan2(s, a:Dot(b)))
end

-- 2-bone IK: returns the 3 joint transforms that put the foot pivot at target
local function ik(leg, parentW, target, footRot)
	local R0 = parentW.Rotation
	local hipW = parentW * (leg.hip - leg.pp)
	local d = target - hipW
	local D = clamp(d.Magnitude, abs(leg.l1 - leg.l2) + 0.05, leg.l1 + leg.l2 - 0.02)
	local dir = d.Unit
	local pole = R0 * leg.pole
	local pp = pole - dir * pole:Dot(dir)
	if pp.Magnitude < 1e-4 then
		pp = R0 * V(leg.s, 0, 0)
	end
	pp = pp.Unit
	local cosA = clamp((leg.l1 ^ 2 + D * D - leg.l2 ^ 2) / (2 * leg.l1 * D), -1, 1)
	local sinA = sqrt(1 - cosA * cosA)
	local knee = hipW + dir * (leg.l1 * cosA) + pp * (leg.l1 * sinA)
	local footP = hipW + dir * D
	local Rt = rotTo((R0 * leg.d1).Unit, (knee - hipW).Unit) * R0
	local Rs = rotTo((Rt * leg.d2).Unit, (footP - knee).Unit) * Rt
	return R0:Inverse() * Rt, Rt:Inverse() * Rs, Rs:Inverse() * footRot
end

local function needDrop(leg, parentW, target)
	local hipW = parentW * (leg.hip - leg.pp)
	local d = target - hipW
	local R = (leg.l1 + leg.l2) * 0.97
	local maxDown = sqrt(max(0, R * R - d.X ^ 2 - d.Z ^ 2))
	return max(0, -d.Y - maxDown)
end

-- foot target helper: rest foot + offset (x, y, z)
local function foot(key, dx, dy, dz)
	local f = LEG[key].foot
	return V(f.X + (dx or 0) * LEG[key].s, f.Y + (dy or 0), f.Z + (dz or 0))
end

-- Body/chest + 4 IK legs. S = { bx, by, bz, bp, byaw, broll, cp, cyaw, croll,
-- feet = {FR=Vector3..}, fp = {FR=deg}, fyaw, tuck }
local function rig(pose, S)
	local chestT = ang(S.cp or 0, S.cyaw or 0, S.croll or 0)
	local function bodyT(dy)
		return pa(S.bx or 0, (S.by or 0) - dy, S.bz or 0, S.bp or 0, S.byaw or 0, S.broll or 0)
	end
	local function frames(dy)
		local bw = CFrame.new(BODY_P) * bodyT(dy)
		return bw, bw * CFrame.new(CHEST_P - BODY_P) * chestT
	end
	local feet = S.feet or {}
	local drop = 0
	if not S.free then
		local bw, cw = frames(0)
		for _, lg in LEGS do
			drop = max(drop, needDrop(lg, lg.parent == "Chest" and cw or bw, feet[lg.key] or lg.foot))
		end
	end
	local bw, cw = frames(drop)
	pose.Body = bodyT(drop)
	pose.Chest = chestT
	local tuck = S.tuck or 0
	for _, lg in LEGS do
		local pw = lg.parent == "Chest" and cw or bw
		local p = S.fp and S.fp[lg.key] or 0
		local fr = CFrame.Angles(0, rad(S.fyaw or 0), 0) * CFrame.Angles(rad(p), 0, 0)
		local a, b, c = ik(lg, pw, feet[lg.key] or lg.foot, fr)
		if tuck > 0 then
			local tk = TUCK[lg.key:sub(1, 1)]
			local ta, tb, tc = tk[1], tk[2], tk[3]
			if lg.s < 0 then
				ta, tb, tc = L.mirror(ta), L.mirror(tb), L.mirror(tc)
			end
			a, b, c = a:Lerp(ta, tuck), b:Lerp(tb, tuck), c:Lerp(tc, tuck)
		end
		pose[lg.b[1]], pose[lg.b[2]], pose[lg.b[3]] = a, b, c
	end
	return drop
end

------------------------------------------------------------------------
-- Face / secondary helpers
------------------------------------------------------------------------
-- lid: -1 closed, 0 lazy half-lid (rest), +1 wide open
-- brow: raise (studs), angry (-1 sad .. +1 angry)
local function face(pose, lidR, lidL, raiseR, angryR, raiseL, angryL)
	local function ly(l)
		return l > 0 and 0.5 * l or 0.98 * l
	end
	L.both(pose, "Lid", CFrame.new(0, ly(lidR), 0), CFrame.new(0, ly(lidL or lidR), 0))
	raiseL = raiseL or raiseR
	angryL = angryL or angryR
	raiseR = max(raiseR, 0.5 * max(0, lidR))
	raiseL = max(raiseL, 0.5 * max(0, lidL or lidR))
	L.both(pose, "Brow", pa(0, raiseR, 0, 0, 0, 16 * angryR), pa(0, raiseL, 0, 0, 0, 16 * angryL))
end

local TAILN = { "Tail1", "Tail2", "Tail3", "Tail4", "Tail5", "TailTip" }
local function tail(pose, pitch, yaw)
	local ps = 0
	for i = 1, 6 do
		pose[TAILN[i]] = ang(pitch[i] or 0, yaw[i] or 0, 0)
		ps += pitch[i] or 0
	end
	return ps
end

local function orbs(pose, bob, spin, push, jolt)
	for i = 1, 4 do
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(push * dir, bob[i] - (jolt or 0), 0, spin * dir + 20 * i, spin * 0.7 + 30 * i, 0)
	end
end

local function marks(ctx, on)
	for i = 1, 8 do
		ctx.transparency("AngryMark" .. i, on and 0 or 1)
	end
end

-- swamp splash ring burst starting at t0 (state time t)
local function splash(pose, ctx, t, t0)
	local s = (t - t0) / 0.55
	if s < 0 or s > 1 then
		return
	end
	local r = 5.0 * E.quadOut(s)
	for k = 1, 8 do
		local a = rad((k - 1) / 8 * 360 + 22.5)
		pose["Splash" .. k] = CFrame.new(-sin(a) * r, 0.5 * sin(pi * s) - 0.2 * s, -cos(a) * r)
		local tr = 0.1 + 0.85 * s * s
		ctx.transparency("Splash" .. k, tr)
		ctx.transparency("Foam" .. k, tr)
	end
end

local function snapLines(ctx, t, t0)
	local s = (t - t0) / 0.2
	if s >= 0 and s <= 1 then
		for i = 1, 6 do
			ctx.transparency("SnapLine" .. i, 0.1 + 0.85 * s)
		end
	end
end

local function dustAll(ctx, n)
	for _, e in { "DustFR", "DustFL", "DustRR", "DustRL" } do
		ctx.emit(e, n)
	end
end

local function garden(pose, sway, shake)
	pose.Flower = pa(0, 0.06 * sway, 0, 5 * sway + 10 * shake, 0, 6 * sway - 8 * shake)
	pose.Reed = ang(5 * sway - 14 * shake, 0, 7 * sway + 16 * shake)
end

local function algae(pose, swing, twist)
	L.both(pose, "Algae", ang(swing, 0, twist), ang(swing, 0, twist))
end

------------------------------------------------------------------------
-- IDLE (12 s): peek, yawn, doze, fly snap, high-walk double jaw clap
------------------------------------------------------------------------
local CLAP1, CLAP2, SNAP = 9.6, 10.16, 6.9
local function idle(t, pose, ctx)
	local c = t % 12
	local br = wave(t, 0.25)
	local yawn = L.env(c, 1.4, 0.9, 0.6, 0.7)
	local doze = L.env(c, 3.7, 0.5, 1.3, 0.4)
	local aware = L.env(c, 5.6, 0.2, 1.1, 0.4)
	local lunge = L.env(c, SNAP - 0.12, 0.12, 0.08, 0.5, "expoOut", "cubicInOut")
	local rise = L.env(c, 8.0, 0.7, 2.3, 0.9, "backOut", "cubicInOut")
	local sq = L.env(c, CLAP1, 0.04, 0.05, 0.4, "quadOut", "backOut") + L.env(c, CLAP2, 0.04, 0.05, 0.45, "quadOut", "backOut")
	local wind = L.env(c, 9.0, 0.4, 0.1, 0.1) + L.env(c, 9.72, 0.26, 0.05, 0.13)
	local lowW = 1 - rise

	-- fly path (figure-8 in front of the snout, ends in the mouth)
	local flyOn = c > 5.15 and c < SNAP
	local fu = clamp((c - 5.15) / (SNAP - 5.15), 0, 1)
	local fx = 2.8 * sin(2 * pi * 1.5 * fu)
	local fy = 0.7 * sin(2 * pi * 3 * fu) + 0.3
	local fz = 1.3 * cos(2 * pi * 1.5 * fu) - 0.6
	local home = E.cubicIn(L.remap(fu, 0.72, 1))
	fx, fy, fz = L.lerp(fx, 0, home), L.lerp(fy, -2.9, home), L.lerp(fz, 1.6, home)
	pose.Fly = pa(fx, fy, fz, 25 * wave(t, 7), 40 * wave(t, 5), 30 * wave(t, 9))
	for _, n in { "FlyBody", "FlyWingR", "FlyWingL", "FlyEyes" } do
		ctx.transparency(n, flyOn and 0 or 1)
	end
	if flyOn then
		ctx.transparency("FlyWingR", 0.2 + 0.5 * L.wave01(t, 12))
		ctx.transparency("FlyWingL", 0.2 + 0.5 * L.wave01(t, 12, 0.5))
	end

	-- body
	rig(pose, {
		by = LOW * lowW + 0.9 * rise + 0.07 * br + 0.45 * yawn - 0.55 * sq - 0.15 * wind * rise,
		bz = -0.6 * lunge + 0.2 * wind,
		bp = -1.5 * yawn + 2 * lunge,
		byaw = 2.5 * wave(t, 0.25, 0.2) * lowW,
		broll = 1.2 * wave(t, 0.25) * lowW + 2 * sq,
		cp = 1.5 * br + 7 * yawn + 8 * wind * rise - 3 * sq,
		cyaw = -3 * wave(t, 0.25, 0.1) * lowW,
		feet = { FR = foot("FR", -0.6 * rise), FL = foot("FL", -0.6 * rise), RR = foot("RR", -0.5 * rise), RL = foot("RL", -0.5 * rise) },
	})

	-- head + jaw (gators open by lifting the upper skull: head pitches up)
	local jaw = L.track(c, {
		{ 0, -4 }, { 1.5, -4 }, { 2.3, -44, "sineInOut" }, { 2.9, -50 }, { 3.25, -1, "quadIn" }, { 3.4, -9, "quadOut" }, { 3.6, -4 },
		{ 6.5, -4 }, { 6.78, -48, "cubicOut" }, { SNAP, 0, "expoIn" }, { 7.05, -9 }, { 7.2, -2 }, { 7.35, -9 }, { 7.5, -2 }, { 7.7, -7 }, { 7.9, -4 },
		{ 8.9, -5 }, { 9.4, -58, "cubicOut" }, { 9.52, -62 }, { CLAP1, 0, "expoIn" }, { 9.72, -8, "quadOut" }, { 9.98, -55, "cubicOut" },
		{ CLAP2, 0, "expoIn" }, { 10.3, -9, "quadOut" }, { 10.6, -4 }, { 12, -4 },
	})
	local hp = L.track(c, {
		{ 0, 3 }, { 1.5, 3 }, { 2.3, 34, "sineInOut" }, { 2.9, 40 }, { 3.25, 5, "quadIn" }, { 3.6, 3 },
		{ 4.0, -1 }, { 5.4, -2 }, { 5.8, 5 }, { 6.5, 6 }, { 6.78, 24, "cubicOut" }, { SNAP, -6, "expoIn" }, { 7.2, 7, "backOut" }, { 7.9, 4 },
		{ 8.9, 6 }, { 9.4, 36, "cubicOut" }, { 9.52, 39 }, { CLAP1, -9, "expoIn" }, { 9.72, 6, "quadOut" }, { 9.98, 32, "cubicOut" },
		{ CLAP2, -11, "expoIn" }, { 10.4, 6, "backOut" }, { 11.0, 5 }, { 12, 3 },
	})
	local peek = L.track(c, { { 0, 0 }, { 0.3, 14, "cubicOut" }, { 0.75, 14 }, { 1.0, -13, "cubicInOut" }, { 1.35, -13 }, { 1.6, 0, "cubicInOut" } })
	local flyLook = clamp(-5 * fx, -18, 18) * aware
	local smug = L.env(c, 7.0, 0.2, 0.7, 0.4)
	pose.Neck = ang(0.5 * hp * 0.3 - 2 * doze, 0.4 * (peek + flyLook), 0)
	pose.Head = ang(max(hp * 0.85, -jaw - 5 - 22 * rise), 0.6 * (peek + flyLook), 6 * smug + 4 * L.env(c, 2.0, 0.6, 0.3, 0.6) + 3 * doze * wave(t, 0.5))
	pose.Jaw = ang(jaw, 0, 0)

	-- eyes
	local lidR = L.track(c, {
		{ 0, 0 }, { 0.85, 0 }, { 0.9, -1 }, { 0.98, 0 }, { 1.5, 0 }, { 1.9, -1 }, { 3.35, -1 }, { 3.5, -0.2 }, { 3.7, -0.4 },
		{ 4.1, -1 }, { 5.6, -1 }, { 5.7, 0.7, "backOut" }, { 6.6, 0.6 }, { 6.75, 1 }, { SNAP + 0.05, 1 }, { 7.15, -0.4 },
		{ 7.9, -0.4 }, { 8.2, 0.1 }, { 9.3, 0.2 }, { 9.45, 1 }, { 9.75, 0.2 }, { 11.4, 0 }, { 11.45, -1 }, { 11.52, 0 }, { 12, 0 },
	})
	local lidL = L.track(c, {
		{ 0, 0 }, { 0.85, 0 }, { 0.9, -1 }, { 0.98, 0 }, { 1.5, 0 }, { 1.9, -1 }, { 3.35, -1 }, { 3.5, -0.2 }, { 3.7, -0.4 },
		{ 4.1, -1 }, { 6.05, -1 }, { 6.15, 0.7, "backOut" }, { 6.6, 0.6 }, { 6.75, 1 }, { SNAP + 0.05, 1 }, { 7.15, -0.4 },
		{ 7.9, -0.4 }, { 8.2, 0.1 }, { 9.3, 0.2 }, { 9.45, 1 }, { 9.75, 0.2 }, { 11.4, 0 }, { 11.45, -1 }, { 11.52, 0 }, { 12, 0 },
	})
	local cocky = L.env(c, 8.4, 0.3, 2.4, 0.5)
	face(pose, lidR, lidL, 0.25 * smug, 0.9 * cocky - 0.3 * doze, 0.1 * smug, 0.9 * cocky - 0.3 * doze)

	-- Zzz floats up while dozing
	local zOn = doze > 0.6
	local zk = ((c - 3.9) % 0.9) / 0.9
	pose.Zzz = pa(0.3 * sin(2 * pi * zk), 0.9 * zk, 0, 0, 0, 10 * sin(2 * pi * zk))
	for i = 1, 6 do
		ctx.transparency("Zzz" .. i, zOn and (0.05 + 0.6 * zk * zk) or 1)
	end

	-- tail: lazy swish, lash during the show-off, flick on the snap
	local pitch, yaw = {}, {}
	for i = 1, 6 do
		yaw[i] = (7 + 1.5 * i) * wave(t, 0.25, -0.07 * i) * lowW
			+ (10 + 3 * i) * rise * wave(t, 1.0, -0.08 * i)
			+ 14 * L.env(c, SNAP + 0.03 * i, 0.08, 0.05, 0.5, "backOut", "sineInOut") * (i % 2 == 0 and -1 or 1)
		pitch[i] = (i == 1 and -3 or 0) * lowW + (i == 1 and -6 or -1.5) * rise + (i <= 2 and 6 or 0) * sq
	end
	pitch[5] += 3 * lowW
	local ps = tail(pose, pitch, yaw)
	pose.Lantern = ang(-ps + 6 * wave(t, 0.5, -0.2) + 10 * sq, 0, 9 * wave(t, 0.25, -0.35) + 14 * rise * wave(t, 1.0, -0.45))

	garden(pose, wave(t, 0.5, 0.2), sq + 0.4 * yawn * wave(t, 2))
	algae(pose, 8 * wave(t, 0.5, 0.15) - 30 * lunge + 25 * sq, 6 * wave(t, 0.25))
	local bob = {}
	for i = 1, 4 do
		bob[i] = 0.6 * wave(t, 0.5, i * 0.25)
	end
	orbs(pose, bob, 30 * t, 0.8 * rise, 1.2 * sq)

	-- effects
	if ctx.crossed(3.3) then ctx.emit("Bubbles", 6) end
	if ctx.crossed(4.3) then ctx.emit("Bubbles", 4) end
	if ctx.crossed(5.0) then ctx.emit("Bubbles", 5) end
	if ctx.crossed(SNAP) then
		ctx.emit("SnapBurst", 18)
	end
	snapLines(ctx, c, SNAP)
	for _, ct in { CLAP1, CLAP2 } do
		if ctx.crossed(ct) then
			ctx.emit("SnapBurst", 30)
			ctx.emit("LeafBurst", 12)
			dustAll(ctx, 8)
		end
		snapLines(ctx, c, ct)
	end
	splash(pose, ctx, c, CLAP1)
	splash(pose, ctx, c, CLAP2 + 0.02)
	ctx.light("LanternLight", 1.0 + 0.15 * wave(t, 1.5) + 0.3 * rise)
end

------------------------------------------------------------------------
-- ALERT (1.8 s): flinch -> rear up, gape + hiss, tail lash -> ready
------------------------------------------------------------------------
local function alert(t, pose, ctx)
	local flinch = L.env(t, 0, 0.12, 0.08, 0.25, "quadOut", "quadInOut")
	local rear = L.env(t, 0.28, 0.22, 0.8, 0.45, "backOut", "cubicInOut")
	local hiss = L.env(t, 0.38, 0.14, 0.75, 0.3, "backOut", "cubicIn")
	local ready = L.env(t, 1.45, 0.15, 0.1, 0.1)
	local trem = hiss * wave(t, 15)
	rig(pose, {
		by = -0.6 * flinch + 0.9 * rear + 0.06 * trem,
		bz = 0.5 * flinch + 0.4 * rear,
		bp = 3 * flinch + 3 * rear - 4 * ready,
		broll = 2 * trem,
		cp = 4 * flinch + 8 * rear - 4 * ready,
		cyaw = 4 * hiss * wave(t, 3),
		feet = { FR = foot("FR", -0.5 * rear), FL = foot("FL", -0.5 * rear), RR = foot("RR", -0.4 * rear), RL = foot("RL", -0.4 * rear) },
	})
	pose.Neck = ang(-6 * flinch + 4 * rear, 0, 0)
	local aj = -5 - 58 * hiss + 4 * trem
	pose.Head = ang(max(10 * flinch + 16 * hiss, -aj - 20) + 3 * trem, 6 * hiss * wave(t, 4), 3 * trem)
	pose.Jaw = ang(aj, 0, 0)
	local wide = L.env(t, 0, 0.06, 0.4, 0.3, "backOut")
	face(pose, wide - 0.25 * hiss, wide - 0.25 * hiss, 0.4 * wide, hiss, 0.4 * wide, hiss)
	marks(ctx, t > 0.32 and t < 1.6)
	local pop = L.env(t, 0.32, 0.12, 0.1, 0.3, "backOut")
	pose.Mark = pa(0, 0.5 * pop, 0, 0, 0, 12 * wave(t, 6))

	local pitch, yaw = {}, {}
	local lash = max(rear, flinch * 0.5)
	for i = 1, 6 do
		yaw[i] = (12 + 5 * i) * lash * wave(t, 3.2, -0.08 * i)
		pitch[i] = (i == 1 and -10 or -2) * rear - (i == 1 and 7 or 0) * flinch
	end
	local ps = tail(pose, pitch, yaw)
	pose.Lantern = ang(-ps + 15 * flinch, 0, 30 * lash * wave(t, 3.2, -0.6))
	garden(pose, wave(t, 2), rear * wave(t, 6) + flinch)
	algae(pose, 30 * hiss * wave(t, 8) - 20 * flinch, 10 * trem)
	local bob = {}
	for i = 1, 4 do
		bob[i] = 0.5 * wave(t, 0.8, i * 0.25) + 1.2 * rear
	end
	orbs(pose, bob, 160 * E.cubicOut(clamp(t / 1.8, 0, 1)), 1.6 * rear, 0)

	if ctx.crossed(0.36) then
		ctx.emit("LeafBurst", 26)
		ctx.emit("SnapBurst", 30)
		ctx.emit("Bubbles", 10)
		dustAll(ctx, 10)
	end
	if ctx.crossed(0.05) then dustAll(ctx, 4) end
	splash(pose, ctx, t, 0.36)
	snapLines(ctx, t, 0.4)
	ctx.light("LanternLight", 1.1 + 0.6 * hiss)
end

------------------------------------------------------------------------
-- CHASE (0.5 s trot loop): high walk sprint with an S-wiggle
------------------------------------------------------------------------
local CH_T, CH_S, CH_DUTY = 0.5, 3.4, 0.5
local CH_PH = { FR = 0, RL = 0, FL = 0.5, RR = 0.5 }
local function gaitFoot(key, u, stride, duty, lift, inX)
	local k = (u + CH_PH[key]) % 1
	if k < duty then
		local s = k / duty
		return foot(key, inX, 0, -stride / 2 + stride * s), 0, k
	end
	local s = (k - duty) / (1 - duty)
	local z = stride / 2 - stride * E.sineInOut(s)
	return foot(key, inX, lift * sin(pi * s), z), -28 * sin(pi * s), k
end

local function chase(t, pose, ctx)
	local u = (t / CH_T) % 1
	local feet, fp = {}, {}
	for key in CH_PH do
		local inX = key:sub(1, 1) == "F" and -0.35 or -0.2
		feet[key], fp[key] = gaitFoot(key, u, CH_S, CH_DUTY, 1.5, inX)
	end
	local w = 2 * pi * u
	local bounce = cos(2 * w) -- footfalls at u = 0, 0.5
	rig(pose, {
		by = 0.45 - 0.3 * bounce,
		bp = -6 + 1.5 * bounce,
		byaw = -7 * cos(w),
		broll = 3 * sin(w),
		cp = -2 - 2 * bounce,
		cyaw = 15 * cos(w),
		croll = -3 * sin(w),
		feet = feet,
		fp = fp,
	})
	local sum = 15 * cos(w) - 7 * cos(w)
	pose.Neck = ang(4 + 2 * bounce, -0.55 * sum - 5 * cos(w), 0)
	local cj = -16 + 9 * sin(2 * w)
	pose.Head = ang(14 - 0.6 * (cj + 16) + 2 * cos(2 * w - 0.6), -0.45 * sum - 4 * cos(w), 4 * sin(w))
	pose.Jaw = ang(cj, 0, 0)
	face(pose, 0.3, 0.3, 0, 1)
	marks(ctx, true)
	pose.Mark = pa(0, 0.15 * cos(2 * w), 0, 0, 0, 10 * sin(w))

	local pitch, yaw = {}, {}
	for i = 1, 6 do
		yaw[i] = (14 + 3 * i) * cos(w - 0.55 * i - 0.4)
		pitch[i] = (i == 1 and -6 or -1) + 2 * bounce
	end
	local ps = tail(pose, pitch, yaw)
	pose.Lantern = ang(-ps + 10 * sin(2 * w - 1), 0, 28 * sin(w - 2.6))
	garden(pose, sin(2 * w), 0.5 * cos(2 * w))
	algae(pose, 25 + 15 * sin(2 * w - 1), 12 * sin(w))
	local bob = {}
	for i = 1, 4 do
		bob[i] = 0.4 * sin(w + i) + 0.5
	end
	orbs(pose, bob, 25 * sin(w), 0.6, 0)

	if ctx.crossed(0.01) then
		ctx.emit("DustFR", 5)
		ctx.emit("DustRL", 5)
	end
	if ctx.crossed(CH_T / 2) then
		ctx.emit("DustFL", 5)
		ctx.emit("DustRR", 5)
	end
	ctx.light("LanternLight", 1.2)
end

------------------------------------------------------------------------
-- ATTACK (1.2 s): wind-up, lunging CHOMP, tail whip follow-up
------------------------------------------------------------------------
local CHOMP = 0.46
local function attack(t, pose, ctx)
	local wind = L.env(t, 0, 0.28, 0.06, 0.12, "cubicOut", "expoIn")
	local lunge = L.env(t, 0.34, 0.12, 0.22, 0.5, "expoOut", "cubicInOut")
	local imp = L.env(t, CHOMP, 0.04, 0.05, 0.4, "quadOut", "backOut")
	local whip = L.env(t, 0.52, 0.14, 0.08, 0.45, "backOut", "cubicInOut")
	-- front feet hop forward with the lunge, step back on the recovery
	local hop = L.remap(t, 0.34, 0.5)
	local back = L.remap(t, 0.82, 1.06)
	local fz = -2.0 * E.cubicOut(hop) + 2.0 * E.sineInOut(back)
	local fy = 1.1 * sin(pi * hop) + 0.7 * sin(pi * back)
	local feet = { FR = foot("FR", 0, fy, fz), FL = foot("FL", 0, fy, fz) }
	rig(pose, {
		by = -0.4 * wind - 0.2 * lunge - 0.45 * imp,
		bz = 1.1 * wind - 2.4 * lunge,
		bp = 5 * wind - 2 * lunge + 2 * imp,
		byaw = -12 * whip,
		broll = 4 * whip,
		cp = 6 * wind - 1 * lunge - 2 * imp,
		cyaw = 8 * whip,
		feet = feet,
		fp = { FR = -20 * sin(pi * hop), FL = -20 * sin(pi * hop) },
	})
	pose.Jaw = ang(L.track(t, { { 0, -5 }, { 0.28, -64, "cubicOut" }, { 0.38, -66 }, { CHOMP, 0, "expoIn" }, { 0.56, -10, "quadOut" }, { 0.72, -3 }, { 1.2, -4 } }), 0, 0)
	local hp = L.track(t, { { 0, 0 }, { 0.28, 30, "cubicOut" }, { 0.38, 33 }, { CHOMP, 4, "expoIn" }, { 0.62, 6, "backOut" }, { 1.2, 0 } })
	pose.Neck = ang(4 * wind - 3 * imp, 6 * whip, 0)
	pose.Head = ang(hp, 8 * whip, -6 * imp)
	face(pose, -0.2 * wind + 0.8 * imp, -0.2 * wind + 0.8 * imp, 0, 1)
	marks(ctx, t < 1.0)
	pose.Mark = pa(0, 0.3 * wind, 0, 0, 0, 15 * imp)

	local pitch, yaw = {}, {}
	for i = 1, 6 do
		local wi = L.env(t, 0.52 + 0.035 * i, 0.12, 0.06, 0.45, "backOut", "cubicInOut")
		yaw[i] = -(8 + 2 * i) * wind + (14 + 6 * i) * wi
		pitch[i] = (i == 1 and -8 or -1) * wind + (i == 1 and -4 or 2) * whip
	end
	local ps = tail(pose, pitch, yaw)
	pose.Lantern = ang(-ps + 12 * imp, 0, -50 * whip + 25 * L.env(t, 0.8, 0.15, 0, 0.35))
	garden(pose, 0, imp - whip)
	algae(pose, 20 * wind - 45 * lunge, 12 * whip)
	local bob = {}
	for i = 1, 4 do
		bob[i] = 0.5 * wave(t, 1, i * 0.25)
	end
	orbs(pose, bob, 90 * E.cubicOut(clamp(t / 1.2, 0, 1)), 1.4 * imp, 0.8 * imp)

	if ctx.crossed(CHOMP) then
		ctx.emit("SnapBurst", 40)
		ctx.emit("Bubbles", 8)
	end
	if ctx.crossed(0.5) then
		ctx.emit("DustFR", 10)
		ctx.emit("DustFL", 10)
	end
	if ctx.crossed(0.66) then
		ctx.emit("LeafBurst", 14)
		ctx.emit("DustRR", 8)
		ctx.emit("DustRL", 8)
	end
	if ctx.crossed(1.06) then
		ctx.emit("DustFR", 4)
		ctx.emit("DustFL", 4)
	end
	snapLines(ctx, t, CHOMP)
	splash(pose, ctx, t, 0.5)
	ctx.light("LanternLight", 1.2 + 0.5 * imp)
end

------------------------------------------------------------------------
-- CATCH (2.2 s): DEATH ROLL then a smug grin
------------------------------------------------------------------------
local ROLL0, ROLL1 = 0.35, 1.25
local function catch(t, pose, ctx)
	local crouch = L.env(t, 0, 0.3, 0.05, 0.15, "cubicOut", "quadIn")
	local k = L.remap(t, ROLL0, ROLL1)
	local spinning = t > ROLL0 and t < ROLL1
	local roll = 360 * E.cubicInOut(k)
	local lift = spinning and 3.0 * sin(pi * k) or 0
	local tuck = L.env(t, 0.36, 0.12, 0.7, 0.15)
	local land = L.env(t, ROLL1, 0.05, 0.05, 0.45, "quadOut", "backOut")
	local grin = L.env(t, 1.35, 0.25, 0.3, 0.3, "backOut", "cubicInOut")
	rig(pose, {
		by = -0.5 * crouch + lift - 0.65 * land,
		bp = 3 * crouch,
		broll = -15 * crouch + roll,
		cp = -2 * crouch + 3 * grin,
		tuck = tuck,
		free = spinning,
	})
	pose.Neck = ang(-4 * crouch + 6 * grin, 0, 0)
	pose.Head = ang(-6 * crouch + 12 * grin, 10 * grin, -12 * grin)
	pose.Jaw = ang(-3 + 3 * tuck - 18 * grin, 0, 0)
	face(pose, -0.6 * tuck - 0.45 * grin, -0.6 * tuck - 0.45 * grin, 0.45 * grin, 0.4 * crouch - 0.5 * grin, 0, 0.8 * grin)

	local pitch, yaw = {}, {}
	for i = 1, 6 do
		yaw[i] = (10 + 3 * i) * grin * wave(t, 2.5, -0.1 * i) - 6 * crouch
		pitch[i] = (i == 1 and -6 or -1) * tuck + (i == 1 and 5 or 0) * land
	end
	local ps = tail(pose, pitch, yaw)
	pose.Lantern = ang(-ps, 0, -roll * 0.9 + 25 * grin * wave(t, 2.5, -0.5) + 20 * land)
	garden(pose, 0, tuck * wave(t, 5) + land)
	algae(pose, 20 * tuck * wave(t, 4) + 25 * land, 0)
	local bob = {}
	for i = 1, 4 do
		bob[i] = 0.5 * wave(t, 1, i * 0.25) + 1.0 * tuck
	end
	orbs(pose, bob, 400 * E.cubicInOut(k), 1.8 * tuck, 1.0 * land)

	for _, ts in { 0.55, 0.8, 1.05 } do
		if ctx.crossed(ts) then
			ctx.emit("Bubbles", 8)
			ctx.emit("LeafBurst", 8)
			ctx.emit("SnapBurst", 10)
		end
	end
	if ctx.crossed(ROLL1) then
		dustAll(ctx, 12)
		ctx.emit("LeafBurst", 16)
	end
	splash(pose, ctx, t, ROLL1)
	if ctx.crossed(1.55) then
		ctx.emit("SnapBurst", 12)
	end
	ctx.light("LanternLight", 1.2 + 0.4 * tuck)
end

------------------------------------------------------------------------
-- GIVE UP (2.6 s): stomping tantrum -> sigh -> slump + sulky bubbles
------------------------------------------------------------------------
local STOMPS = { { "FR", 0.06 }, { "FL", 0.28 }, { "FR", 0.5 }, { "FL", 0.72 } }
local function giveup(t, pose, ctx)
	local tant = L.env(t, 0, 0.1, 0.85, 0.2)
	local sigh = L.env(t, 1.0, 0.25, 0.1, 0.35, "sineInOut", "quadIn")
	local sink = L.env(t, 1.25, 0.45, 0.65, 0.3, "cubicOut", "cubicInOut")
	local feet, fp = {}, {}
	local thud = 0
	for _, st in STOMPS do
		local s = L.remap(t, st[2], st[2] + 0.2)
		if s > 0 and s < 1 then
			local h = s < 0.6 and E.cubicOut(s / 0.6) or 1 - E.expoIn((s - 0.6) / 0.4)
			feet[st[1]] = foot(st[1], 0.2, 1.5 * h, -0.4 * h)
			fp[st[1]] = -15 * h
		end
		thud += L.env(t, st[2] + 0.2, 0.03, 0.03, 0.18, "quadOut", "quadIn")
	end
	rig(pose, {
		by = 0.2 * tant - 0.3 * thud + 0.3 * sigh + LOW * sink,
		bp = -2 * thud + 2 * sigh,
		broll = 4 * tant * wave(t, 2.3),
		cp = 3 * tant * wave(t, 4.6) - 3 * thud + 6 * sigh,
		cyaw = 6 * tant * wave(t, 2.3),
		feet = feet,
		fp = fp,
	})
	local jg = L.track(t, { { 0, -4 }, { 0.12, -40, "cubicOut" }, { 0.24, 0, "expoIn" }, { 0.42, -42, "cubicOut" }, { 0.56, 0, "expoIn" }, { 0.75, -6 }, { 1.1, -14 }, { 1.4, -2 }, { 2.6, -4 } })
	local no = 18 * tant * wave(t, 4.6)
	pose.Neck = ang(4 * sigh - 1 * sink, 0.4 * no, 0)
	pose.Head = ang(14 * sigh + 2 * sink + 6 * tant + 0.9 * max(0, -jg - 6), 0.6 * no, 4 * sink)
	pose.Jaw = ang(jg, 0, 0)
	local sulkLid = -0.65 * sink
	face(pose, 0.3 * tant + sulkLid - 0.5 * sigh, 0.3 * tant + sulkLid - 0.5 * sigh, 0.15 * sink, tant - 0.9 * sink, 0.15 * sink, tant - 0.9 * sink)
	marks(ctx, t < 1.05)
	pose.Mark = pa(0, 0.2 * L.bounce(t, 4.6), 0, 0, 0, 10 * wave(t, 4.6))

	local pitch, yaw = {}, {}
	local slap = L.env(t, 0.1, 0.2, 0.05, 0.12, "cubicOut", "expoIn") + L.env(t, 0.55, 0.2, 0.05, 0.12, "cubicOut", "expoIn")
	for i = 1, 6 do
		yaw[i] = (8 + 3 * i) * tant * wave(t, 2.3, -0.08 * i) + (6 + i) * sink * wave(t, 0.77, -0.1 * i)
		pitch[i] = (i == 1 and -14 or -2) * slap + (i == 1 and 3 or 0) * sink
	end
	local ps = tail(pose, pitch, yaw)
	pose.Lantern = ang(-ps + 10 * thud, 0, 25 * tant * wave(t, 2.3, -0.5) + 8 * sink * wave(t, 0.77))
	garden(pose, 0.5 * wave(t, 1.5), thud + 0.5 * tant * wave(t, 4.6))
	algae(pose, 20 * thud + 8 * wave(t, 1.5), 8 * no / 18)
	local bob = {}
	for i = 1, 4 do
		bob[i] = 0.5 * wave(t, 0.8, i * 0.25) - 1.2 * sink
	end
	orbs(pose, bob, 60 * t, 0, 0.6 * thud)

	for _, st in STOMPS do
		if ctx.crossed(st[2] + 0.2) then
			ctx.emit("Dust" .. st[1], 10)
			ctx.emit("LeafBurst", 4)
		end
	end
	if ctx.crossed(0.24) then ctx.emit("SnapBurst", 10) end
	if ctx.crossed(0.56) then ctx.emit("SnapBurst", 10) end
	if ctx.crossed(1.3) then ctx.emit("Bubbles", 12) end
	if ctx.crossed(1.7) then ctx.emit("Bubbles", 6) end
	if ctx.crossed(2.0) then ctx.emit("Bubbles", 6) end
	splash(pose, ctx, t, 0.72)
	ctx.light("LanternLight", 1.1 - 0.5 * sink)
end

------------------------------------------------------------------------
-- RETURN (1.4 s loop): lazy grumpy waddle (4-beat walk)
------------------------------------------------------------------------
local RT_T, RT_S, RT_DUTY = 1.4, 3.0, 0.72
local RT_PH = { RL = 0, FL = 0.25, RR = 0.5, FR = 0.75 }
local function ret(t, pose, ctx)
	local u = (t / RT_T) % 1
	local feet, fp = {}, {}
	for key, ph in RT_PH do
		local k = (u + ph) % 1
		if k < RT_DUTY then
			feet[key] = foot(key, 0, 0, -RT_S / 2 + RT_S * (k / RT_DUTY))
			fp[key] = 0
		else
			local s = (k - RT_DUTY) / (1 - RT_DUTY)
			feet[key] = foot(key, 0, 0.9 * sin(pi * s), RT_S / 2 - RT_S * E.sineInOut(s))
			fp[key] = -18 * sin(pi * s)
		end
	end
	local w = 2 * pi * u
	rig(pose, {
		by = -0.35 + 0.1 * cos(4 * w),
		bp = -1,
		byaw = -4 * sin(w + 0.4),
		broll = 3.5 * sin(w),
		cp = 1 + 1 * cos(4 * w),
		cyaw = 7 * sin(w + 0.4),
		croll = -2 * sin(w),
		feet = feet,
		fp = fp,
	})
	pose.Neck = ang(-2, -3 * sin(w + 0.4), 0)
	pose.Head = ang(-1 + 2 * cos(2 * w), -3 * sin(w + 0.6), 3 * sin(w))
	pose.Jaw = ang(-4 - 5 * max(0, sin(2 * w)) ^ 4, 0, 0)
	face(pose, -0.35, -0.35, 0, 0.55)

	local pitch, yaw = {}, {}
	for i = 1, 6 do
		yaw[i] = (8 + 2.5 * i) * sin(w - 0.5 * i)
		pitch[i] = (i == 1 and -2 or 0)
	end
	local ps = tail(pose, pitch, yaw)
	pose.Lantern = ang(-ps + 5 * sin(2 * w), 0, 16 * sin(w - 2.4))
	garden(pose, sin(2 * w), 0)
	algae(pose, 10 * sin(2 * w - 0.8), 8 * sin(w))
	local bob = {}
	for i = 1, 4 do
		bob[i] = 0.5 * sin(w + i * 1.3)
	end
	orbs(pose, bob, 20 * sin(w), 0, 0)

	for key, ph in RT_PH do
		local touch = ((1 - ph) % 1) * RT_T
		if ctx.crossed(touch + 0.01) then
			ctx.emit("Dust" .. key, 3)
		end
	end
	ctx.light("LanternLight", 1.0 + 0.1 * sin(2 * w))
end

------------------------------------------------------------------------
local props = {}
for i = 1, 8 do
	props["AngryMark" .. i] = 1
	props["Splash" .. i] = 1
	props["Foam" .. i] = 1
end
for i = 1, 6 do
	props["Zzz" .. i] = 1
	props["SnapLine" .. i] = 1
end
for _, n in { "FlyBody", "FlyWingR", "FlyWingL", "FlyEyes" } do
	props[n] = 1
end
M.Props = props

M.States = {
	Idle = { Loop = true, Length = 12, Blend = 0.5, Update = idle },
	Alert = { Length = 1.8, Update = alert },
	Chase = { Loop = true, Length = CH_T, Speed = CH_S / (CH_DUTY * CH_T), Update = chase },
	Attack = { Length = 1.2, Update = attack },
	Catch = { Length = 2.2, Update = catch },
	GiveUp = { Length = 2.6, Update = giveup },
	Return = { Loop = true, Length = RT_T, Speed = RT_S / (RT_DUTY * RT_T), Update = ret },
}
M.Base = "Idle"
M.Reel = { { "Idle" }, { "Alert" }, { "Chase", 3.6 }, { "Attack" }, { "Catch" }, { "Chase", 1.8 }, { "GiveUp" }, { "Return", 3.6 } }
return L.states(M)
