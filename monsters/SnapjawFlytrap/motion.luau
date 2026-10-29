--!nocheck
-- Snapjaw Flytrap motion (guardian states). Always hungry, drooly, chomp-happy.
--   Idle   (12 s): sways on its root legs, a fly buzzes by -> tracks it, two
--                 misses and a CHOMP (gotcha), smug chewing; licks its lips;
--                 burps leaves; SHOW-OFF: huge wide yawn -> triple chomp ->
--                 proud pose; pot shuffle on the six roots.
--   Alert  (2.0): clamps shut + crouches -> EXPLODES: trap gapes, leaves flare,
--                 arms fling, roar shake, drool + leaf burst -> snap, ready.
--   Chase  (0.5): tripod scuttle on six roots, neck lunging, chomp per stride.
--   Attack (1.2): neck coils back, trap wide -> long lunging SNAP, thrash.
--   Catch  (2.2): smug chewing, pats its pot -> big leafy BURP.
--   GiveUp (2.6): wilts (neck sags, tongue lolls, sweat drop) -> perks back
--                 angrily with a CHOMP stomp and a "hmph" head shake.
--   Return (1.2): proud hop-shuffle walk home.
-- Root legs use a 2-bone IK so planted feet never slide when the pot moves.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, env, E = L.ang, L.pa, L.wave, L.env, L.ease
local sqrt, max, min, abs, clamp = math.sqrt, math.max, math.min, math.abs, math.clamp
local sin, cos, rad, deg, pi, atan2 = math.sin, math.cos, math.rad, math.deg, math.pi, math.atan2

local M = {}
M.Props = {
	AngryMark1 = 1, AngryMark2 = 1, AngryMark3 = 1, AngryMark4 = 1,
	SweatDrop1 = 1, SweatDrop2 = 1,
	FlyBody = 1, FlyWingR = 1, FlyWingL = 1,
	EyelidR = 1, EyelidL = 1, LashR = 1, LashL = 1,
}

local JAW0 = -12 -- neutral: trap slightly open so the pink inside + teeth read

------------------------------------------------------------------------
-- rig data (must match build.luau)
------------------------------------------------------------------------
local POT = Vector3.new(0, 2.6, 0)
local LEGA = { 45, 95, 145 }
local LEG = {}
for k, a in LEGA do
	local d = Vector3.new(sin(rad(a)), 0, -cos(rad(a)))
	local H = Vector3.new(0, 1.5, 0) + d * 1.6
	local K = Vector3.new(0, 2.8, 0) + d * 3.8
	local F = Vector3.new(0, 0.55, 0) + d * 5.0
	local u0, l0 = K - H, F - K
	local uF = (F - H).Unit
	local pole = (u0 - uF * u0:Dot(uF)).Unit
	LEG[k] = { H = H, K = K, F = F, a = u0.Magnitude, b = l0.Magnitude, u0 = u0.Unit, l0 = l0.Unit, pole = pole }
end
-- tripod gait groups: A = 1R, 2L, 3R ; B = 1L, 2R, 3L
local GROUP = { R = { 0, 0.5, 0 }, L = { 0.5, 0, 0.5 } }
local LEAFA = { 35, 95, 150 }
local PLANT = Vector3.new(0, -0.18, 0) -- feet pressed onto the ground (toes at Y~0)

local function rmin(a, b)
	local ax = a:Cross(b)
	local s = ax.Magnitude
	if s < 1e-6 then
		return CFrame.new()
	end
	return CFrame.fromAxisAngle(ax / s, atan2(s, a:Dot(b)))
end

-- right-side leg IK: target T in model space -> Leg, Shin transforms
local function solve(potW, k, T)
	local G = LEG[k]
	local q = POT + potW:PointToObjectSpace(T)
	local d = q - G.H
	local a, b = G.a, G.b
	local D = clamp(d.Magnitude, abs(a - b) + 0.05, a + b - 0.03)
	local dh = d.Unit
	local cosA = clamp((a * a + D * D - b * b) / (2 * a * D), -1, 1)
	local sinA = sqrt(1 - cosA * cosA)
	local p = G.pole - dh * G.pole:Dot(dh)
	p = p.Magnitude > 1e-4 and p.Unit or G.pole
	local kd = dh * cosA + p * sinA
	local R1 = rmin(G.u0, kd)
	local Kn = G.H + kd * a
	local cur = R1:VectorToWorldSpace(G.l0)
	local want = (G.H + dh * D - Kn).Unit
	local Rw = rmin(cur, want)
	-- foot: undo the pot + leg rotation so the root toes stay flat
	local footT = (potW.Rotation * Rw * R1):Inverse()
	return R1, R1:Inverse() * Rw * R1, footT
end

-- tripod gait: ph in [0,1) -> (dz, dy); stance first half (foot slides back)
local function gait(ph, S, lift)
	ph = ph % 1
	if ph < 0.5 then
		return -S / 2 + S * (ph / 0.5), 0
	end
	local s = (ph - 0.5) / 0.5
	return S / 2 - S * E.sineInOut(s), lift * sin(pi * s)
end

local function blinkAt(c, b)
	return env(c, b, 0.06, 0.05, 0.08)
end

------------------------------------------------------------------------
-- shared pose writer: every state fills a parameter table and calls this
------------------------------------------------------------------------
local function newP()
	return {
		pot = { 0, 0, 0, 0, 0, 0 },
		n = { { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } },
		stretch = 0, fwd = 0,
		head = { 0, 0, 0 }, headFwd = 0,
		jaw = JAW0, tongue = 0, tongueYaw = 0, tonguePitch = 0,
		brow = 0, browY = 0, browL = nil, browYL = nil,
		lid = 0,
		armR = { 0, 0, 0 }, armL = { 0, 0, 0 }, handR = { 0, 0, 0 }, handL = { 0, 0, 0 },
		flare = 0, flutter = 0,
		feet = { R = { Vector3.zero, Vector3.zero, Vector3.zero }, L = { Vector3.zero, Vector3.zero, Vector3.zero } },
		sweat = 0,
	}
end

local function apply(t, pose, ctx, P)
	local pp = P.pot
	local potPose = pa(pp[1], pp[2], pp[3], pp[4], pp[5], pp[6])
	pose.Pot = potPose
	local potW = CFrame.new(POT) * potPose
	local potWm = L.mirror(potW)

	-- LEGS (IK)
	for k = 1, 3 do
		local G = LEG[k]
		local oR = P.feet.R[k]
		local u, s, f = solve(potW, k, G.F + PLANT + oR)
		pose["Leg" .. k .. "R"], pose["Shin" .. k .. "R"], pose["Foot" .. k .. "R"] = u, s, f
		local oL = P.feet.L[k]
		local um, sm, fm = solve(potWm, k, G.F + PLANT + Vector3.new(-oL.X, oL.Y, oL.Z))
		pose["Leg" .. k .. "L"], pose["Shin" .. k .. "L"], pose["Foot" .. k .. "L"] = L.mirror(um), L.mirror(sm), L.mirror(fm)
	end

	-- NECK chain + HEAD
	local n = P.n
	pose.Neck1 = pa(0, P.stretch * 0.6, 0, n[1][1], n[1][2], n[1][3])
	pose.Neck2 = pa(0, P.stretch, -P.fwd * 0.5, n[2][1], n[2][2], n[2][3])
	pose.Neck3 = pa(0, P.stretch, -P.fwd * 0.5, n[3][1], n[3][2], n[3][3])
	-- P.head[1] is the trap's WORLD pitch: the neck/pot tilt is compensated so
	-- lunges reach forward with the mouth level instead of face-planting
	local worldTilt = pp[4] + n[1][1] + n[2][1] + n[3][1]
	pose.Head = pa(0, 0, -P.headFwd, P.head[1] - worldTilt, P.head[2], P.head[3])
	pose.Jaw = ang(min(P.jaw, 1.5), 0, 0)
	local out = P.tongue
	pose.Tongue = pa(0, 0.05 * out, -1.6 * out, -4 * out + P.tonguePitch * 0.5, P.tongueYaw * 0.5, 0)
	pose.TongueTip = pa(0, 0, -0.6 * out, P.tonguePitch + 10 * out * wave(t, 3), P.tongueYaw, 0)

	-- drool hangs (counter the trap tilt) and swings
	local tilt = P.head[1] + P.jaw
	pose.Drool = ang(clamp(-tilt * 0.85, -80, 80) + 8 * wave(t, 1, 0.1), 0, 6 * wave(t, 0.5, 0.3))
	local wide = clamp((-P.jaw - 30) / 40, 0, 1)
	pose.DroolDrop = pa(0, -0.12 * L.bounce(t, 1) + 0.5 * wide, 0, 10 * wave(t, 1, -0.05), 0, 0)

	-- FACE
	L.both(pose, "Brow", pa(0, P.browY, 0, 0, 0, P.brow), pa(0, P.browYL or P.browY, 0, 0, 0, P.browL or P.brow))
	local close = clamp(P.lid, 0, 1)
	L.both(pose, "Lid", CFrame.new(0, 1.0 * (1 - close), 0))
	local lidTr = close > 0.15 and 0 or 1
	ctx.transparency("EyelidR", lidTr)
	ctx.transparency("EyelidL", lidTr)
	ctx.transparency("LashR", lidTr)
	ctx.transparency("LashL", lidTr)

	-- ARMS
	L.both(pose, "Arm", ang(P.armR[1], P.armR[2], P.armR[3]), ang(P.armL[1], P.armL[2], P.armL[3]))
	L.both(pose, "Hand", ang(P.handR[1], P.handR[2], P.handR[3]), ang(P.handL[1], P.handL[2], P.handL[3]))

	-- COLLAR LEAVES: flare (lift outward) + flutter with lag
	for i, a in LEAFA do
		local ax = Vector3.new(cos(rad(a)), 0, sin(rad(a)))
		local fR = P.flare + P.flutter * wave(t, 2, i * 0.13)
		local fL = P.flare + P.flutter * wave(t, 2, i * 0.13 + 0.5)
		pose["Leaf" .. i .. "R"] = CFrame.fromAxisAngle(ax, rad(fR + 3 * wave(t, 0.5, i * 0.2)))
		pose["Leaf" .. i .. "L"] = L.mirror(CFrame.fromAxisAngle(ax, rad(fL + 3 * wave(t, 0.5, i * 0.2 + 0.5))))
	end
	pose.LeafB = ang(-(P.flare + P.flutter * wave(t, 2, 0.4)) - 3 * wave(t, 0.5, 0.7), 0, 0)

	-- FLOATING LEAF CUBES
	pose.Orbit = ang(0, 18 * wave(t, 0.25), 0)
	for i = 1, 4 do
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(0, 0.8 * wave(t, 0.5, i * 0.27), 0, 70 * t * dir, 100 * t, 25)
	end
end

------------------------------------------------------------------------
-- IDLE (12 s)
------------------------------------------------------------------------
local C1, C2, C3 = 1.75, 2.25, 2.8 -- fly chomps (third one gets it)
local S1, S2, S3 = 8.95, 9.27, 9.62 -- show-off triple chomp
local function snapEnv(c, at, open)
	-- open quickly, hold, then SLAM shut exactly at `at`
	return env(c, at - open, open * 0.75, open * 0.1, open * 0.15, "quadOut", "expoIn")
end

local function flyPos(c)
	local x = 2.6 * sin(2 * pi * 0.9 * c) + 0.4 * sin(2 * pi * 4.1 * c)
	local y = 11.4 + 0.9 * sin(2 * pi * 1.7 * c) + 0.25 * sin(2 * pi * 5.3 * c)
	local z = -9.0 + 1.0 * cos(2 * pi * 0.6 * c)
	-- each near-miss jinks the fly away
	x += 2.0 * env(c, C1, 0.08, 0.1, 0.3) - 2.2 * env(c, C2, 0.08, 0.1, 0.3)
	y += 1.2 * env(c, C1, 0.08, 0.1, 0.3) + 0.8 * env(c, C2, 0.08, 0.1, 0.3)
	return Vector3.new(x, y, z)
end

local function idle(t, pose, ctx)
	local c = t % 12
	local P = newP()

	local breathe = wave(t, 0.5)
	local sway = wave(t, 0.25)
	local look = L.noise(t, 3.3, 0.25) * 14

	-- gag envelopes
	local track = env(c, 0.55, 0.35, 2.15, 0.4)
	local chew = env(c, 2.85, 0.1, 0.75, 0.2)
	local lick = env(c, 4.1, 0.3, 0.65, 0.3, "backOut", "cubicInOut")
	local burpA = env(c, 5.6, 0.28, 0.04, 0.12, "quadOut", "quadIn")
	local burp = env(c, 5.98, 0.08, 0.25, 0.45, "backOut", "cubicInOut")
	local yawn = env(c, 7.0, 0.9, 0.45, 0.4, "cubicOut", "cubicIn")
	local ch1, ch2, ch3 = snapEnv(c, S1, 0.3), snapEnv(c, S2, 0.26), snapEnv(c, S3, 0.3)
	local hit1 = env(c, S1, 0.04, 0.04, 0.22, "quadOut", "quadOut")
	local hit2 = env(c, S2, 0.04, 0.04, 0.22, "quadOut", "quadOut")
	local hit3 = env(c, S3, 0.04, 0.1, 0.3, "quadOut", "quadOut")
	local proud = env(c, 9.75, 0.3, 0.4, 0.45, "backOut", "cubicInOut")
	local shuffle = env(c, 10.5, 0.15, 1.0, 0.15)
	local busy = max(track, lick, burp, burpA, yawn, ch1, ch2, ch3, proud * 0.6)
	local idleW = 1 - clamp(busy, 0, 1) * 0.7

	-- fly + head tracking
	local fp = flyPos(c)
	local flyOn = c > 0.5 and c < C3
	if flyOn then
		ctx.transparency("FlyBody", 0)
		ctx.transparency("FlyWingR", 0)
		ctx.transparency("FlyWingL", 0)
	end
	pose.Fly = pa(fp.X - 0, fp.Y - 11.5, fp.Z + 9, 15 * wave(t, 7), 25 * wave(t, 2), 20 * wave(t, 11))
	local hx, hy, hz = 0, 10.4, -2.5
	local fyaw = clamp(deg(atan2(-(fp.X - hx), -(fp.Z - hz))), -40, 40) * track
	local fpitch = clamp(deg(atan2(fp.Y - hy, -(fp.Z - hz))), -20, 30) * track
	local c1, c2, c3 = snapEnv(c, C1, 0.24), snapEnv(c, C2, 0.22), snapEnv(c, C3, 0.26)
	local lunge = env(c, C1 - 0.08, 0.08, 0.02, 0.2) + env(c, C2 - 0.08, 0.08, 0.02, 0.2) + env(c, C3 - 0.1, 0.1, 0.05, 0.3)

	-- POT: breathing, sway, squashes
	local squash = -0.3 * burpA - 0.25 * (hit1 + hit2) - 0.4 * hit3
	local hop = 0
	-- pot shuffle (10.5-11.7): four quick tripod steps in place, pot turns a bit
	local sh = L.remap(c, 10.55, 11.75)
	local stepPh = sh * 2 -- two full tripod cycles
	if sh > 0 and sh < 1 then
		hop = 0.3 * L.bounce(stepPh, 2)
	end
	P.pot = {
		0.15 * sway * idleW,
		0.08 * breathe + squash + 0.45 * yawn + hop + 0.15 * proud,
		0.3 * lunge,
		-2 * lunge + 4 * yawn - 4 * hit3 + 5 * proud,
		8 * wave(sh, 1) * shuffle,
		2.5 * sway * idleW,
	}
	for k = 1, 3 do
		for _, s in { "R", "L" } do
			local ph = stepPh + GROUP[s][k]
			local dz, dy = 0, 0
			if sh > 0 and sh < 1 then
				local p = ph % 1
				if p > 0.5 then
					dy = 0.9 * sin(pi * (p - 0.5) / 0.5)
					dz = -0.25 * sin(pi * (p - 0.5) / 0.5)
				end
			end
			P.feet[s][k] = Vector3.new(0, dy, dz)
		end
	end

	-- NECK: sway with lag, yawn stretch, lunges at the fly, triple chomp
	local headYawCh = -22 * ch1 + 22 * ch2 + (-12 * hit1 + 12 * hit2)
	P.stretch = 0.35 * yawn + 0.15 * burp + 0.2 * proud
	P.fwd = 0.9 * lunge + 0.6 * (hit1 + hit2) + 1.2 * hit3
	P.n[1] = { 2 * breathe - 5 * lunge - 6 * burpA + 6 * yawn - 4 * (hit1 + hit2) - 8 * hit3 - 4 * proud, 0.3 * look * idleW + 0.25 * fyaw, 4 * sway * idleW }
	P.n[2] = { -3 * breathe - 6 * lunge - 6 * burpA + 4 * yawn - 5 * (hit1 + hit2) - 10 * hit3 + 2 * (ch1 + ch2 + ch3), 0.3 * look * idleW + 0.3 * fyaw + 0.4 * headYawCh, 5 * wave(t, 0.25, -0.08) * idleW }
	P.n[3] = { 2 * breathe - 3 * lunge + 2 * yawn - 4 * hit3, 0.4 * look * idleW + 0.3 * fyaw + 0.6 * headYawCh, 4 * wave(t, 0.25, -0.16) * idleW }
	-- HEAD: tracking, licking tilt, burp toss, yawn tilt-back, chomp pitch
	P.head = {
		3 * breathe + fpitch * 0.6 + 8 * lunge - 10 * burpA + 24 * burp + 36 * yawn + 10 * (ch1 + ch2) + 14 * ch3 - 6 * hit3 + 10 * proud + 5 * lick,
		0.15 * fyaw + 3 * wave(t, 0.5, 0.2) * idleW,
		8 * lick * wave(t, 0.5) + 6 * sway * idleW - 8 * proud,
	}
	P.headFwd = 0.4 * hit3

	-- JAW: chomps / chewing / lick / burp / yawn
	local chewJ = -14 * L.wave01(t, 4) * chew
	local jawOpen = 48 * max(c1, c2, c3) + 22 * lick + 55 * burp + 85 * yawn + 55 * max(ch1, ch2) + 70 * ch3
	local clamp0 = max(burpA, hit1, hit2, hit3, env(c, C1, 0.01, 0.05, 0.1), env(c, C2, 0.01, 0.05, 0.1), env(c, C3, 0.01, 0.12, 0.2))
	P.jaw = JAW0 * (1 - clamp0) + chewJ - jawOpen - 2 * L.wave01(t, 0.5) * idleW
	P.tongue = lick * (0.75 + 0.15 * wave(t, 1.5)) + 0.25 * yawn
	P.tongueYaw = 40 * wave(t, 1.5) * lick
	P.tonguePitch = 12 * lick - 10 * yawn

	-- FACE
	P.brow = 4 * track - 8 * burp - 10 * yawn + 10 * (ch1 + ch2 + ch3) + 4 * hit3 - 6 * proud
	P.browY = 0.25 * burp + 0.2 * yawn - 0.1 * track + 0.15 * proud
	P.browL = P.brow + 8 * proud
	P.browYL = P.browY - 0.25 * proud
	local blink = max(blinkAt(c, 0.25), blinkAt(c, 4.0), blinkAt(c, 6.9), blinkAt(c, 7.05), blinkAt(c, 11.85))
	P.lid = max(blink, 0.5 * chew, 0.45 * lick, 1.0 * yawn, 0.4 * proud, 0.35 * burpA)

	-- ARMS: idle sway, rub belly while chewing, yawn stretch, chomp punches
	local armSw = 8 * wave(t, 0.5, 0.1)
	local pat = 18 * wave(t, 4) * chew
	P.armR = { 0, 10 * sway * idleW + 40 * chew + 20 * hit3 - 25 * proud - 30 * yawn, armSw * idleW + 42 * yawn + 15 * burp - 10 * proud }
	P.armL = { 0, -10 * sway * idleW + 40 * chew + 20 * hit3 - 25 * proud - 30 * yawn, -armSw * idleW + 42 * yawn + 15 * burp - 10 * proud }
	P.handR = { 0, 0, 6 * wave(t, 0.5, 0.25) + 25 * yawn - 10 * proud + 0.6 * pat }
	P.handL = { 0, 0, -6 * wave(t, 0.5, 0.25) + 25 * yawn - 10 * proud - 0.6 * pat }
	P.flare = 6 * yawn + 10 * burp + 8 * hit3 + 3 * breathe
	P.flutter = 4 + 8 * (hit1 + hit2 + hit3)

	apply(t, pose, ctx, P)

	-- EFFECTS
	if ctx.crossed(C1) or ctx.crossed(C2) then
		ctx.emit("ChompBurst", 8)
	end
	if ctx.crossed(C3) then
		ctx.emit("ChompBurst", 18)
		ctx.emit("DroolBurst", 8)
	end
	if ctx.crossed(4.4) then
		ctx.emit("DroolBurst", 10)
	end
	if ctx.crossed(6.0) then
		ctx.emit("LeafBurst", 30)
		ctx.emit("ChompBurst", 6)
	end
	if ctx.crossed(7.6) then
		ctx.emit("SporeSparkle", 10)
	end
	if ctx.crossed(S1) or ctx.crossed(S2) then
		ctx.emit("ChompBurst", 14)
	end
	if ctx.crossed(S3) then
		ctx.emit("ChompBurst", 30)
		ctx.emit("DroolBurst", 16)
		ctx.emit("StepDust", 12)
	end
	for i = 0, 3 do
		if ctx.crossed(10.55 + 0.3 * i + 0.3) then
			ctx.emit("StepDust", 4)
		end
	end
	ctx.light("MouthLight", 0.6 * yawn + 0.8 * hit3)
end

------------------------------------------------------------------------
-- ALERT (2.0 s)
------------------------------------------------------------------------
local function alert(t, pose, ctx)
	local P = newP()
	local antic = env(t, 0.0, 0.32, 0.06, 0.1, "quadOut", "quadIn")
	local roar = env(t, 0.38, 0.12, 0.98, 0.42, "backOut", "cubicInOut")
	local shake = env(t, 0.5, 0.08, 0.85, 0.25)
	local snap = env(t, 1.55, 0.04, 0.08, 0.3)
	local settle = env(t, 1.6, 0.1, 0.1, 0.3)

	P.pot = { 0, -0.6 * antic + 0.55 * roar - 0.25 * snap, 0.3 * antic, 6 * antic + 8 * roar - 4 * snap, 0, 2 * shake * wave(t, 9) }
	P.stretch = -0.2 * antic + 0.45 * roar
	P.n[1] = { -8 * antic + 4 * roar - 4 * settle, 0, 0 }
	P.n[2] = { 14 * antic + 2 * roar, 0, 0 }
	P.n[3] = { -12 * antic + 2 * roar, 0, 0 }
	local shk = 11 * shake * wave(t, 8)
	P.head = { -14 * antic + 30 * roar + 4 * shake * wave(t, 11) - 4 * snap, shk, 4 * shake * wave(t, 5) }
	P.jaw = JAW0 * (1 - antic) - 70 * roar + 8 * shake * wave(t, 13) + 12 * snap
	P.tongue = 0.35 * roar
	P.tongueYaw = 25 * shake * wave(t, 6)
	P.tonguePitch = 15 * roar
	P.brow = 14 * antic + 12 * roar
	P.browY = -0.15 * antic - 0.1 * roar
	P.lid = 0.35 * antic
	P.armR = { 0, -30 * antic - 25 * roar, -6 * antic + 34 * roar + 8 * shake * wave(t, 7) }
	P.armL = { 0, -30 * antic - 25 * roar, -6 * antic + 34 * roar + 8 * shake * wave(t, 7, 0.5) }
	P.handR = { 0, -10 * roar, -10 * antic + 22 * roar }
	P.handL = { 0, -10 * roar, -10 * antic + 22 * roar }
	P.flare = -10 * antic + 38 * roar
	P.flutter = 3 + 14 * shake
	if t > 0.42 then
		for i = 1, 4 do
			ctx.transparency("AngryMark" .. i, 0)
		end
	end
	apply(t, pose, ctx, P)

	if ctx.crossed(0.46) then
		ctx.emit("LeafBurst", 40)
		ctx.emit("DroolBurst", 25)
		ctx.emit("StepDust", 24)
		ctx.emit("ChompBurst", 20)
		ctx.emit("SporeSparkle", 15)
	end
	if ctx.crossed(0.9) then
		ctx.emit("DroolBurst", 10)
	end
	if ctx.crossed(1.6) then
		ctx.emit("ChompBurst", 12)
	end
	ctx.light("MouthLight", 1.2 * roar)
end

------------------------------------------------------------------------
-- CHASE (0.5 s): tripod scuttle
------------------------------------------------------------------------
local CH_T, CH_S = 0.5, 3.6
local function chase(t, pose, ctx)
	local P = newP()
	local ph = (t % CH_T) / CH_T
	local u = (ph * 2) % 1 -- 0 at each tripod landing
	local bob = sin(pi * u)
	P.pot = { 0, 0.5 * bob - 0.3, 0, -9 + 3 * cos(2 * pi * u), 0, 5 * wave(t, 2) }
	for k = 1, 3 do
		for _, s in { "R", "L" } do
			local dz, dy = gait(ph + GROUP[s][k], CH_S, 1.2)
			P.feet[s][k] = Vector3.new(0, dy, dz)
		end
	end
	-- one big chomp per stride, slammed shut at ph 0.62
	local open = L.track(ph, { { 0, 0.2 }, { 0.45, 1, "quadOut" }, { 0.56, 1 }, { 0.62, 0, "expoIn" }, { 1, 0.2, "quadIn" } })
	local hit = env(ph, 0.62, 0.03, 0.03, 0.2)
	P.fwd = 0.5 + 0.4 * hit
	P.n[1] = { -12 - 3 * hit, 3 * wave(t, 2, 0.1), 0 }
	P.n[2] = { -14 - 3 * hit + 2 * bob, 0, 3 * wave(t, 2, 0.05) }
	P.n[3] = { -6, 0, 0 }
	P.head = { -6 + 12 * open - 5 * hit, 4 * wave(t, 2, 0.15), -4 * wave(t, 2, 0.1) }
	P.jaw = JAW0 * (1 - hit) - 46 * open
	P.tongue = 0.0
	P.brow = 14
	P.browY = -0.15
	P.lid = 0.2
	local sw = wave(t, 2)
	P.armR = { 0, 35 * sw, 20 + 10 * bob }
	P.armL = { 0, -35 * sw, 20 + 10 * bob }
	P.handR = { 0, 0, 15 * wave(t, 2, -0.12) }
	P.handL = { 0, 0, -15 * wave(t, 2, -0.12) }
	P.flare = 8
	P.flutter = 10
	for i = 1, 4 do
		ctx.transparency("AngryMark" .. i, 0)
	end
	apply(t, pose, ctx, P)
	if ctx.crossed(0.02) or ctx.crossed(CH_T / 2 + 0.02) then
		ctx.emit("StepDust", 6)
	end
	if ctx.crossed(0.62 * CH_T) then
		ctx.emit("ChompBurst", 5)
		ctx.emit("DroolBurst", 4)
	end
end

------------------------------------------------------------------------
-- ATTACK (1.2 s): coil back -> long lunging SNAP -> thrash -> recover
------------------------------------------------------------------------
local SNAP = 0.57
local function attack(t, pose, ctx)
	local P = newP()
	local antic = env(t, 0.0, 0.35, 0.07, 0.13, "cubicOut", "quadIn")
	local lunge = env(t, 0.42, 0.13, 0.2, 0.42, "backOut", "cubicInOut")
	local open = env(t, 0.03, 0.3, 0.17, SNAP - 0.5, "quadOut", "expoIn")
	local hit = env(t, SNAP, 0.03, 0.1, 0.35, "quadOut", "quadOut")
	local thrash = env(t, SNAP + 0.02, 0.05, 0.18, 0.2)

	P.pot = { 0, -0.2 * antic - 0.35 * hit, 0.4 * antic - 0.9 * lunge, 8 * antic - 11 * lunge, 0, 3 * thrash * wave(t, 8) }
	P.stretch = 0.15 * antic + 0.2 * lunge
	P.fwd = -0.4 * antic + 1.6 * lunge
	P.headFwd = 0.8 * lunge
	P.n[1] = { 12 * antic - 22 * lunge, 0, 0 }
	P.n[2] = { 18 * antic - 22 * lunge, 0, 0 }
	P.n[3] = { 8 * antic - 10 * lunge, 0, 0 }
	P.head = { 22 * antic + 10 * open - 2 * lunge - 6 * hit, 12 * thrash * wave(t, 7), 6 * thrash * wave(t, 5) }
	P.jaw = JAW0 * (1 - hit) - 64 * open + 4 * thrash * wave(t, 12)
	P.brow = 16
	P.browY = -0.15
	P.lid = 0.3 * antic
	P.armR = { 0, -30 * antic + 40 * lunge, 40 * antic + 25 * lunge }
	P.armL = { 0, -30 * antic + 40 * lunge, 40 * antic + 25 * lunge }
	P.handR = { 0, 0, 20 * antic - 10 * lunge }
	P.handL = { 0, 0, 20 * antic - 10 * lunge }
	P.flare = 10 * antic + 14 * hit
	P.flutter = 4 + 12 * hit
	for i = 1, 4 do
		ctx.transparency("AngryMark" .. i, 0)
	end
	apply(t, pose, ctx, P)
	if ctx.crossed(SNAP) then
		ctx.emit("ChompBurst", 35)
		ctx.emit("DroolBurst", 20)
		ctx.emit("StepDust", 18)
	end
	ctx.light("MouthLight", 1.0 * hit)
end

------------------------------------------------------------------------
-- CATCH (2.2 s): smug chewing -> big leafy BURP
------------------------------------------------------------------------
local function catch(t, pose, ctx)
	local P = newP()
	local smug = env(t, 0.05, 0.25, 0.85, 0.25)
	local burpA = env(t, 1.15, 0.2, 0.05, 0.1, "quadOut", "quadIn")
	local burp = env(t, 1.42, 0.08, 0.3, 0.45, "backOut", "cubicInOut")
	local chewJ = (12 - 20 * L.wave01(t, 3)) * smug

	P.pot = { 0, 0.15 * L.bounce(t, 3) * smug - 0.3 * burpA + 0.35 * burp, 0, 4 * smug - 4 * burpA + 6 * burp, 0, 4 * wave(t, 1.5) * smug }
	P.stretch = 0.3 * burp
	P.n[1] = { -4 * burpA + 2 * burp, 0, 3 * wave(t, 1.5) * smug }
	P.n[2] = { -6 * burpA, 0, 4 * wave(t, 1.5, -0.08) * smug }
	P.n[3] = { 3 * wave(t, 3) * smug, 0, 0 }
	P.head = { 6 * smug + 4 * wave(t, 3) * smug - 12 * burpA + 26 * burp, 6 * wave(t, 0.75) * smug, 9 * wave(t, 1.5, -0.15) * smug }
	P.jaw = JAW0 * (1 - burpA) + chewJ - 56 * burp
	P.tongue = 0.2 * burp
	P.brow = -6 * smug - 8 * burp
	P.browY = 0.25 * smug + 0.25 * burp
	P.browL = 8 * smug - 8 * burp
	P.browYL = -0.05 * smug + 0.25 * burp
	P.lid = max(0.55 * smug, 0.4 * burpA)
	local pat = 16 * wave(t, 3) * smug
	P.armR = { 0, 45 * smug - 10 * burp, -15 * smug + 35 * burp }
	P.armL = { 0, 45 * smug - 10 * burp, -15 * smug + 35 * burp }
	P.handR = { pat, 0, -10 * smug + 20 * burp }
	P.handL = { -pat, 0, -10 * smug + 20 * burp }
	P.flare = 4 * smug + 18 * burp
	P.flutter = 3 + 10 * burp
	apply(t, pose, ctx, P)
	if ctx.crossed(1.44) then
		ctx.emit("LeafBurst", 45)
		ctx.emit("ChompBurst", 8)
		ctx.emit("DroolBurst", 10)
	end
	if ctx.crossed(1.6) then
		ctx.emit("StepDust", 8)
	end
	for _, k in { 0.5, 0.83, 1.17 } do
		if ctx.crossed(k) then
			ctx.emit("DroolBurst", 3)
		end
	end
end

------------------------------------------------------------------------
-- GIVEUP (2.6 s): wilt -> perk back angrily with a CHOMP stomp
------------------------------------------------------------------------
local function giveup(t, pose, ctx)
	local P = newP()
	local wilt = env(t, 0.15, 0.75, 0.5, 0.2, "cubicOut", "quadIn")
	local sigh = env(t, 0.95, 0.25, 0.05, 0.3)
	local perk = env(t, 1.45, 0.12, 0.25, 0.6, "backOut", "cubicInOut")
	local open = env(t, 1.35, 0.12, 0.05, 0.08, "quadOut", "expoIn")
	local hit = env(t, 1.62, 0.03, 0.08, 0.3)
	local hmph = env(t, 1.85, 0.1, 0.3, 0.3)

	P.pot = { 0, -0.45 * wilt - 0.1 * sigh + 0.45 * perk - 0.35 * hit, 0, -4 * wilt + 4 * perk, 0, 0 }
	P.stretch = -0.2 * wilt + 0.25 * perk
	P.n[1] = { -8 * wilt + 4 * perk, 0, 0 }
	P.n[2] = { -20 * wilt - 6 * sigh + 6 * perk, 0, 5 * wilt }
	P.n[3] = { -18 * wilt + 4 * perk, 0, 5 * wilt }
	P.head = { -24 * wilt + 5 * sigh + 14 * perk + 12 * open, 14 * hmph * wave(t, 5) - 8 * wilt, 14 * wilt }
	P.jaw = JAW0 * (1 - hit) - 16 * wilt - 50 * open
	P.tongue = 0.9 * wilt
	P.tonguePitch = -28 * wilt
	P.tongueYaw = 15 * wilt
	P.brow = -14 * wilt + 18 * perk
	P.browY = 0.15 * wilt - 0.15 * perk
	P.lid = max(0.5 * wilt, 0.7 * sigh * wilt)
	P.sweat = 0.8 * L.remap(t, 0.4, 1.45)
	P.armR = { 0, 12 * wilt - 15 * perk, -6 * wilt + 40 * perk - 20 * hit }
	P.armL = { 0, 12 * wilt - 15 * perk, -6 * wilt + 40 * perk - 20 * hit }
	P.handR = { 0, 15 * wilt, 15 * perk }
	P.handL = { 0, 15 * wilt, 15 * perk }
	P.flare = -16 * wilt + 25 * perk
	P.flutter = 2 + 10 * perk
	if t > 0.4 and t < 1.45 then
		ctx.transparency("SweatDrop1", 0)
		ctx.transparency("SweatDrop2", 0)
	end
	if t > 1.5 and t < 2.45 then
		for i = 1, 4 do
			ctx.transparency("AngryMark" .. i, 0)
		end
	end
	apply(t, pose, ctx, P)
	if ctx.crossed(1.62) then
		ctx.emit("ChompBurst", 20)
		ctx.emit("StepDust", 20)
		ctx.emit("DroolBurst", 10)
	end
	if ctx.crossed(0.5) then
		ctx.emit("LeafBurst", 6)
	end
end

------------------------------------------------------------------------
-- RETURN (1.2 s): proud hop-shuffle walk
------------------------------------------------------------------------
local RT_T, RT_S = 1.2, 3.0
local function ret(t, pose, ctx)
	local P = newP()
	local f = 1 / RT_T
	local ph = (t % RT_T) / RT_T
	local u = (ph * 2) % 1
	local hop = sin(pi * u) ^ 1.3
	P.pot = { 0, 0.55 * hop - 0.15, 0, 4 - 3 * cos(2 * pi * u), 6 * wave(t, f), 5 * wave(t, f, 0.1) }
	for k = 1, 3 do
		for _, s in { "R", "L" } do
			local dz, dy = gait(ph + GROUP[s][k], RT_S, 1.0)
			P.feet[s][k] = Vector3.new(0, dy, dz)
		end
	end
	local nib = env(ph, 0.7, 0.08, 0.02, 0.1)
	P.n[1] = { 2, -3 * wave(t, f), 3 * wave(t, f, 0.05) }
	P.n[2] = { -2 + 2 * hop, 0, 4 * wave(t, f, 0.1) }
	P.n[3] = { 2, 0, 3 * wave(t, f, 0.15) }
	P.head = { 8 + 3 * hop, -4 * wave(t, f, 0.2), -5 * wave(t, f, 0.2) }
	P.jaw = JAW0 - 14 * nib + 2 * hop
	P.brow = 6
	P.browY = 0.05
	P.lid = 0.35
	local sw = wave(t, f)
	P.armR = { 0, 22 * sw, 10 + 6 * hop }
	P.armL = { 0, -22 * sw, 10 + 6 * hop }
	P.handR = { 0, 0, 10 * wave(t, f, -0.15) }
	P.handL = { 0, 0, -10 * wave(t, f, -0.15) }
	P.flare = 2
	P.flutter = 6
	apply(t, pose, ctx, P)
	if ctx.crossed(0.03) or ctx.crossed(RT_T / 2 + 0.03) then
		ctx.emit("StepDust", 3)
	end
end

M.States = {
	Idle = { Loop = true, Length = 12, Update = idle },
	Alert = { Length = 2.0, Update = alert },
	Chase = { Loop = true, Length = CH_T, Speed = CH_S / (CH_T * 0.5), Update = chase },
	Attack = { Length = 1.2, Update = attack },
	Catch = { Length = 2.2, Update = catch },
	GiveUp = { Length = 2.6, Update = giveup },
	Return = { Loop = true, Length = RT_T, Speed = RT_S / (RT_T * 0.5), Update = ret },
}
M.Base = "Idle"
M.Reel = { { "Idle" }, { "Alert" }, { "Chase", 3.6 }, { "Attack" }, { "Catch" }, { "Chase", 1.8 }, { "GiveUp" }, { "Return", 3.6 } }
return L.states(M)
