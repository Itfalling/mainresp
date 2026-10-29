--!nocheck
-- Hornet Warlord motion: a militant drill-sergeant war-hornet that never lands.
-- Every state drives one shared rig (rig()) through a table of channels, so the
-- hover, wing buzz, mandibles, brows, lance and stinger read the same everywhere.
--   Idle   : hover patrol scan -> SALUTE -> presents + polishes the lance (huff,
--            rub, gleam) -> wing-buzz "hup!" -> SHOW-OFF: windmill lance twirl
--            then a slam + STINGER FLARE (abdomen curls up, stinger glows)
--   Alert  : "!" pop + flinch -> hunch + stinger arcs up charging -> BATTLE CRY
--   Chase  : leaned dive flight, lance couched forward, wings blurring
--   Attack : rears back, then the abdomen whips forward under the body: STING
--   Catch  : victory spin loop -> lance raised, laughing, stinger flare
--   GiveUp : buzzing loop-de-loop tantrum + fist shake, then droops (sweat)
--   Return : lazy drifting hover, lance over the shoulder, grumbling
-- Arms use a small 2-bone IK (fist targets in body space); the lance is aimed in
-- model space so it stays upright/aimed while the body bobs and leans.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease
local env, track, remap, clamp01 = L.env, L.track, L.remap, L.clamp01
local max, min, abs, sin, cos, rad, deg, pi = math.max, math.min, math.abs, math.sin, math.cos, math.rad, math.deg, math.pi

local M = {}
M.Props = {
	EyelidR = 1, EyelidL = 1,
	Anger1 = 1, Anger2 = 1, Anger3 = 1, Anger4 = 1,
	Sweat1 = 1, Sweat2 = 1,
	Excl1 = 1, Excl2 = 1,
}

------------------------------------------------------------------------
-- Arm IK (right side, body-space rest coordinates; left is mirrored)
------------------------------------------------------------------------
local V = Vector3.new
local SH = V(2.9, 10.4, -1.0)
local EL = V(4.4, 8.0, -2.2)
local FI = V(4.4, 8.4, -5.1)
local U0, F0 = EL - SH, FI - EL
local LA, LB = U0.Magnitude, F0.Magnitude
local POLE0 = (function()
	local d = (FI - SH).Unit
	return (U0 - d * U0:Dot(d)).Unit
end)()

local function fromTo(a, b)
	a, b = a.Unit, b.Unit
	local d = math.clamp(a:Dot(b), -1, 1)
	if d > 0.99999 then
		return CFrame.new()
	end
	local ax = a:Cross(b)
	if ax.Magnitude < 1e-6 then
		ax = V(1, 0, 0)
	end
	return CFrame.fromAxisAngle(ax.Unit, math.acos(d))
end

local function armIK(target, pole)
	local d = target - SH
	local len = math.clamp(d.Magnitude, abs(LA - LB) + 0.05, LA + LB - 0.03)
	local dn = d.Unit
	local x = (LA * LA - LB * LB + len * len) / (2 * len)
	local h = math.sqrt(max(0, LA * LA - x * x))
	local p = pole or POLE0
	local pn = p - dn * p:Dot(dn)
	pn = pn.Magnitude > 1e-4 and pn.Unit or POLE0
	local e = SH + dn * x + pn * h
	local hnd = SH + dn * len
	local r1 = fromTo(U0, e - SH)
	local r2 = fromTo(F0, r1:Inverse() * (hnd - e))
	return r1, r2
end

local function lerpV(a, b, k)
	return a + (b - a) * k
end

------------------------------------------------------------------------
-- shared rig
------------------------------------------------------------------------
local ZERO = { __index = function() return 0 end }
local ORB_DIR = { 1, -1, 1, -1 }
local ORB_XZ = { { 10.5, -3.0 }, { -10.5, -1.5 }, { 8.5, 7.0 }, { -8.5, 5.5 } }
local SHOCK_N = 10
local NOCURL = { 0, 0, 0, 0, 0 }
local ABD_LIFT = -5 -- carried a touch higher than the build pose (hover clearance)

local function rig(pose, t, ctx, q)
	setmetatable(q, ZERO)

	-- BODY (hover offsets)
	local bodyCF = pa(q.x, q.y, q.z, q.p, q.yw, q.r)
	pose.Body = bodyCF
	pose.Head = ang(q.hp, q.hy, q.hr)

	-- MANDIBLES: hinge outward (+ a little down)
	local m = q.mand
	L.both(pose, "Mand", ang(-0.3 * m, -m, 0.1 * m))

	-- BROWS: raise / lower + angry tilt (inner end down)
	L.both(pose, "Brow", pa(0, q.browY, 0, 0, 0, q.browA), pa(0, q.browY, 0, 0, 0, q.browA))

	-- EYELIDS slide down over the eyes (props, shown only while closing)
	local close = clamp01(q.lid)
	L.both(pose, "Lid", CFrame.new(0, 1.7 * (1 - close), 0))
	local lidTr = close > 0.12 and 0 or 1
	ctx.transparency("EyelidR", lidTr)
	ctx.transparency("EyelidL", lidTr)

	-- ANTENNAE (two-bone chains)
	local apL = rawget(q, "antPL") or q.antP
	local arL = rawget(q, "antRL") or q.antR
	pose.AntAR = ang(q.antP, 0, q.antR)
	pose.AntBR = ang(0.7 * q.antP, 0, 0.6 * q.antR)
	pose.AntAL = L.mirror(ang(apL, 0, arL))
	pose.AntBL = L.mirror(ang(0.7 * apL, 0, 0.6 * arL))

	-- WINGS: buzz (flap about the body axis) + sweep back + raise
	local flapF = q.wRaise + q.wAmp * wave(t, q.wHz)
	local flapB = 0.8 * q.wRaise + 0.85 * q.wAmp * wave(t, q.wHz, 0.37)
	L.both(pose, "WingF", ang(0, -q.wSweep, flapF), ang(0, -q.wSweep, flapF))
	L.both(pose, "WingB", ang(0, -0.8 * q.wSweep, flapB), ang(0, -0.8 * q.wSweep, flapB))

	-- ARMS (IK to fist targets; right-frame coordinates for both)
	local aR, fR = armIK(rawget(q, "fistR") or FI, rawget(q, "poleR"))
	local aL, fL = armIK(rawget(q, "fistL") or FI, rawget(q, "poleL"))
	pose.ArmR, pose.ForeR = aR, fR
	pose.ArmL, pose.ForeL = L.mirror(aL), L.mirror(fL)

	-- LANCE: aimed in model space (or body space with spearBody = 1), can
	-- slide in the fist so the grip sits at its middle for the twirl
	local want = rawget(q, "spear") or CFrame.new()
	local parentR = aR * fR
	if q.spearBody < 0.5 then
		parentR = bodyCF.Rotation * parentR
	end
	pose.Spear = parentR:Inverse() * want * CFrame.new(0, -q.slide, 0)

	-- LEGS (dangling)
	local lzL = rawget(q, "legZL") or q.legZ
	local lxL = rawget(q, "legXL") or q.legX
	pose.LegR = ang(q.legX, 0, q.legZ)
	pose.LegL = L.mirror(ang(lxL, 0, lzL))
	L.both(pose, "Shin", ang(q.shinX, 0, 0))
	L.both(pose, "Foot", ang(q.footX, 0, 0))

	-- ABDOMEN + STINGER (+X curls it down/under, -X lifts it)
	local curl = rawget(q, "abdC") or NOCURL
	for i = 1, 4 do
		local w = q.abdW * wave(t, q.abdHz, -0.12 * i)
		local yw = q.abdYaw * wave(t, q.abdYHz, -0.1 * i)
		pose["Abd" .. i] = ang(q.abdP * (i == 1 and 1.2 or 1) + w + curl[i] + (i == 1 and ABD_LIFT or 0), yw, 0)
	end
	pose.Stinger = ang(q.sting + q.abdW * 1.4 * wave(t, q.abdHz, -0.6) + curl[5], 0, 0)
	local glow = clamp01(q.glow)
	ctx.transparency("StingGlow", glow > 0.05 and (0.95 - 0.8 * glow) or 1)
	ctx.light("StingLight", 1.5 * glow)
	ctx.light("SpearLight", min(1.5, q.spearLight))

	-- EXPRESSION PROPS
	local anger = q.anger > 0.5 and 0 or 1
	for k = 1, 4 do
		ctx.transparency("Anger" .. k, anger)
	end
	local sweat = q.sweat > 0.5 and 0.1 or 1
	ctx.transparency("Sweat1", sweat)
	ctx.transparency("Sweat2", sweat)
	local excl = q.excl > 0.5 and 0 or 1
	ctx.transparency("Excl1", excl)
	ctx.transparency("Excl2", excl)

	-- FLOATING CUBES
	pose.Orbit = ang(0, q.orbYaw, 0)
	for i = 1, 4 do
		local dir = ORB_DIR[i]
		local xz = ORB_XZ[i]
		local len = math.sqrt(xz[1] * xz[1] + xz[2] * xz[2])
		local bob = 0.8 * wave(t, q.orbHz, i * 0.25)
		pose["Orb" .. i] = pa(xz[1] / len * q.orbOut, bob + q.orbY, xz[2] / len * q.orbOut, q.tumble * dir, q.tumble * 1.25, 0)
	end

	-- STRIKE SHOCKWAVE (q.shock: progress 0..1, anything else = hidden)
	local sw = rawget(q, "shock")
	local on = sw ~= nil and sw > 0 and sw < 1
	local r = on and 4.5 * E.quadOut(sw) or 0
	for k = 1, SHOCK_N do
		local a = (k - 1) / SHOCK_N * 2 * pi
		pose["Shock" .. k] = CFrame.new(-sin(a) * r, cos(a) * r, on and -1.5 * sw or 0)
		local tr = on and (0.1 + 0.85 * sw * sw) or 1
		ctx.transparency("Wave" .. k, tr)
		ctx.transparency("WaveTop" .. k, tr)
	end
end

------------------------------------------------------------------------
-- IDLE (12 s): guarding the garden
------------------------------------------------------------------------
local SALUTE = V(3.3, 14.2, -5.0)
local PRESENT_R = V(3.4, 8.9, -5.7)
local RUB_L = V(4.4, 9.6, -6.0)
local TWIRL = V(6.4, 11.4, -4.2)
local SCAN = { { 0.3, 0 }, { 0.75, -26, "backOut" }, { 1.35, -26 }, { 1.85, 24, "cubicInOut" }, { 2.2, 24 }, { 2.55, 0, "cubicInOut" } }
local SPEAR_FLAT = ang(0, 0, 90)

local function idle(t, pose, ctx)
	local c = t % 12
	local q = {}

	-- envelopes
	local scan = track(c, SCAN)
	local sal = env(c, 2.75, 0.2, 1.3, 0.4, "backOut", "cubicInOut")
	local snap = env(c, 2.92, 0.05, 0.06, 0.14)
	local pol = env(c, 4.95, 0.4, 1.45, 0.4, "backOut", "cubicInOut")
	local huff = env(c, 5.35, 0.12, 0.15, 0.2)
	local rub = env(c, 5.65, 0.15, 0.7, 0.15)
	local gleam = env(c, 6.55, 0.05, 0.12, 0.35)
	local hup = env(c, 7.25, 0.16, 0.12, 0.45, "backOut", "quadInOut")
	local crouch = env(c, 8.0, 0.35, 0.1, 0.25, "cubicOut", "cubicIn")
	local twirl = env(c, 8.35, 0.3, 1.5, 0.35, "backOut", "cubicInOut")
	local spin = 720 * E.quadInOut(remap(c, 8.55, 10.1))
	local rise = env(c, 8.4, 0.4, 1.35, 0.5)
	local slam = env(c, 10.12, 0.06, 0.08, 0.45, "quadOut", "backOut")
	local flare = env(c, 10.12, 0.2, 0.85, 0.55, "backOut", "cubicInOut")
	local show = max(crouch, twirl, flare)
	local calm = 1 - max(sal, pol, show)

	-- always-on hover rhythm (seamless in 12 s)
	local bob = wave(t, 0.5)
	local sway = wave(t, 0.25)
	local pulse = wave(t, 1.0)

	-- BODY
	q.y = 0.45 * bob + 0.6 * sal + 1.1 * hup - 0.5 * crouch + 1.3 * rise - 0.9 * slam
	q.p = pulse + 6 * sal - 8 * crouch + 4 * twirl - 10 * slam + 6 * flare
	q.yw = 0.55 * scan + 10 * pol - 12 * twirl
	q.r = 3 * sway * calm + 4 * twirl
	q.z = 0.4 * crouch

	-- HEAD
	q.hp = 2 * wave(t, 0.5, 0.15) + 6 * sal - 12 * pol + 4 * huff - 6 * crouch + 8 * twirl + 22 * flare
	q.hy = 0.5 * scan + 18 * pol - 8 * twirl * wave(t, 1.5)
	q.hr = 4 * sway * calm + 6 * pol + 8 * snap

	-- FACE
	q.mand = 4 + 3 * max(0, wave(t, 0.75)) * calm + 30 * snap + 28 * huff + 8 * rub * wave(t, 6) + 48 * flare
		+ 8 * flare * wave(t, 11)
	q.browY = 0.25 * sal - 0.25 * show + 0.15 * huff
	q.browA = 3 + 12 * show - 6 * sal
	local blink = max(env(c, 1.45, 0.06, 0.05, 0.08), env(c, 6.95, 0.06, 0.04, 0.08), env(c, 7.12, 0.06, 0.04, 0.08),
		env(c, 11.7, 0.06, 0.05, 0.08))
	q.lid = max(blink, 0.35 * rub, 0.3 * crouch)

	-- ANTENNAE: idle wobble, flick up on the salute snap and on the hup
	local flick = max(env(c, 2.85, 0.08, 0.2, 0.4, "backOut"), hup)
	q.antP = 6 * wave(t, 0.75) + 25 * flick - 15 * crouch + 20 * flare
	q.antR = 5 * wave(t, 1.5, 0.2)
	q.antPL = 6 * wave(t, 0.75, 0.3) + 25 * flick - 15 * crouch + 20 * flare
	q.antRL = 5 * wave(t, 1.5, 0.55)

	-- WINGS: steady hover buzz, bursts on the hup / twirl / flare
	q.wAmp = 20 + 22 * hup + 16 * twirl + 22 * flare
	q.wHz = 13
	q.wSweep = 4 + 22 * twirl - 10 * crouch
	q.wRaise = 6 + 18 * twirl + 6 * hup

	-- ARMS
	local fistR = FI + V(0, 0.15 * bob, 0)
	fistR = lerpV(fistR, PRESENT_R, pol)
	fistR = lerpV(fistR, FI + V(0, 0.4, 1.0), crouch * (1 - twirl))
	fistR = lerpV(fistR, TWIRL, twirl)
	fistR = fistR + V(0, -0.6 * slam, -0.5 * flare)
	q.fistR = fistR
	q.poleR = (twirl > 0.01) and V(1, -0.4, 0.4) or nil
	local fistL = FI + V(0, -0.15 * bob, 0.2 * sway)
	fistL = lerpV(fistL, SALUTE, sal)
	local rubPos = RUB_L + V(-0.9 * wave(c, 3.0) * rub, 0, 0)
	fistL = lerpV(fistL, rubPos, pol)
	fistL = lerpV(fistL, V(4.8, 10.6, -3.4), max(twirl, flare) * (1 - pol))
	q.fistL = fistL
	q.poleL = sal > 0.01 and V(1, 0.1, 0.5) or nil

	-- LANCE: upright -> presented flat -> windmill twirl -> slammed upright
	local sp = CFrame.new():Lerp(SPEAR_FLAT, pol)
	sp = sp * ang(-spin * twirl, 0, 0)
	q.spear = ang(0, 0, 0) * sp
	q.slide = 1.5 * twirl
	q.spearLight = 1.4 * gleam + 0.6 * twirl * (spin > 1 and spin < 719 and 1 or 0) + 1.2 * flare

	-- LEGS: dangle + kick on the hup, tuck for the show-off
	q.legX = 6 * wave(t, 0.5, 0.2) + 18 * hup - 20 * crouch + 15 * flare
	q.legXL = 6 * wave(t, 0.5, 0.45) + 18 * hup - 20 * crouch + 15 * flare
	q.legZ = 4 * sway + 12 * twirl
	q.shinX = -6 + 5 * wave(t, 1.0, 0.1) - 18 * hup + 10 * crouch
	q.footX = 8 * wave(t, 1.0, 0.3)

	-- ABDOMEN: breathing pulse, pumps on the hup, cocks for the flare
	q.abdP = 2 * pulse - 8 * hup - 6 * crouch - 18 * flare - 7 * sal - 6 * twirl
	q.abdW = 2.5 + 4 * hup
	q.abdHz = 1.0
	q.abdYaw = 3
	q.abdYHz = 0.25
	q.sting = -40 * flare - 10 * crouch
	q.glow = max(flare, 0.5 * crouch)

	-- CUBES
	q.orbYaw = 25 * wave(t, 1 / 12)
	q.orbHz = 0.5
	q.orbY = 0.8 * rise
	q.orbOut = 1.5 * flare
	q.tumble = 120 * t

	rig(pose, t, ctx, q)

	-- EFFECTS
	if ctx.crossed(2.93) then ctx.emit("BattleBurst", 8) end
	if ctx.crossed(6.56) then ctx.emit("SpearSparks", 16) end
	if ctx.crossed(7.3) then
		ctx.emit("GroundDust", 10)
		ctx.emit("PetalBurst", 6)
	end
	for k = 0, 5 do
		if ctx.crossed(8.7 + k * 0.25) then ctx.emit("SpearSparks", 5) end
	end
	if ctx.crossed(10.14) then
		ctx.emit("StingBurst", 40)
		ctx.emit("BattleBurst", 30)
		ctx.emit("PetalBurst", 18)
		ctx.emit("GroundDust", 18)
	end
end

------------------------------------------------------------------------
-- ALERT (2.0 s): "MY PLANT GOT STOLEN!"
------------------------------------------------------------------------
local CRY_R = V(4.6, 13.6, -3.4)
local CRY_L = V(4.0, 14.2, -2.6)

local function alert(t, pose, ctx)
	local c = t
	local q = {}
	local shock = env(c, 0, 0.12, 0.18, 0.25, "backOut", "quadInOut")
	local crouch = env(c, 0.3, 0.35, 0.08, 0.15, "cubicOut", "quadIn")
	local cry = env(c, 0.72, 0.16, 0.7, 0.4, "backOut", "cubicInOut")
	local charge = env(c, 0.35, 0.45, 0.85, 0.35)
	local shake = cry * wave(t, 9)

	q.y = 0.45 * wave(t, 0.5) + 1.4 * shock - 0.6 * crouch + 1.8 * cry
	q.p = 12 * shock - 16 * crouch + 12 * cry
	q.z = 0.6 * crouch
	q.r = 3 * shake
	q.hp = 8 * shock - 12 * crouch + 22 * cry + 4 * shake
	q.hy = 6 * shock * wave(t, 6)
	q.mand = 26 * shock + 8 * crouch + cry * (48 + 12 * wave(t, 11))
	q.browY = 0.55 * shock - 0.3 * crouch - 0.2 * cry
	q.browA = -8 * shock + 12 * crouch + 16 * cry
	q.lid = 0.4 * crouch
	q.antP = 35 * shock - 15 * crouch + 25 * cry
	q.antR = 10 * shock + 8 * cry * wave(t, 7)
	q.antRL = 10 * shock + 8 * cry * wave(t, 7, 0.5)
	q.wAmp = 20 * (1 - 0.7 * shock) + 10 * crouch + 26 * cry
	q.wHz = 13 + 4 * cry
	q.wSweep = 4 + 22 * crouch
	q.wRaise = 6 + 16 * cry

	q.fistR = lerpV(FI + V(0, 0.8 * shock, 0), CRY_R, cry) + V(0, 1.0 * crouch, 0.6 * crouch)
	q.poleR = cry > 0.01 and V(1, -0.3, 0.3) or nil
	q.fistL = lerpV(FI + V(0.4 * shock, 1.0 * shock, 0), CRY_L + V(0, 0.5 * shake, 0), cry)
	q.poleL = cry > 0.01 and V(1, -0.2, 0.3) or nil
	q.spear = ang(0, 0, -6 * cry)

	q.legX = 25 * shock - 10 * crouch + 10 * cry
	q.legZ = 20 * cry + 8 * shock
	q.shinX = -10 * shock + 12 * crouch - 10 * cry

	q.abdP = 4 * crouch - 14 * charge - 12 * shock + 3 * crouch * wave(t, 13)
	q.abdW = 2
	q.abdHz = 2
	q.sting = -32 * charge
	q.glow = charge
	q.spearLight = 1.2 * cry

	q.orbYaw = 20 * cry * wave(t, 1.5)
	q.orbHz = 0.5
	q.orbOut = 2.5 * cry - 1.0 * crouch
	q.orbY = 1.5 * cry
	q.tumble = 120 * t + 360 * cry

	q.excl = c < 0.8 and 1 or 0
	q.anger = c >= 0.72 and 1 or 0
	rig(pose, t, ctx, q)

	if ctx.crossed(0.02) then ctx.emit("BattleBurst", 10) end
	if ctx.crossed(0.78) then
		ctx.emit("BattleBurst", 55)
		ctx.emit("StingBurst", 30)
		ctx.emit("PetalBurst", 30)
		ctx.emit("GroundDust", 30)
		ctx.emit("SpearSparks", 20)
	end
	for k = 0, 3 do
		if ctx.crossed(0.4 + k * 0.1) then ctx.emit("StingBurst", 4) end
	end
end

------------------------------------------------------------------------
-- CHASE (0.6 s loop): leaned dive flight, lance couched forward
------------------------------------------------------------------------
local CH = 1 / 0.6
local LANCE_R = V(3.9, 9.8, -5.4)
local LANCE = ang(-94, 0, 0)

local function chase(t, pose, ctx)
	local q = {}
	local s = wave(t, CH)
	local s2 = wave(t, 2 * CH)
	q.y = 0.25 + 0.55 * s
	q.p = -26 + 4 * wave(t, CH, 0.25)
	q.r = 4 * wave(t, CH, 0.1)
	q.hp = 18 + 4 * wave(t, CH, 0.3)
	q.hy = 3 * wave(t, CH, 0.2)
	q.mand = 12 + 20 * max(0, s2) ^ 2
	q.browY = -0.25
	q.browA = 16
	q.lid = 0.25
	q.antP = 34 + 8 * wave(t, 2 * CH)
	q.antR = 8
	q.antPL = 34 + 8 * wave(t, 2 * CH, 0.4)
	q.wAmp = 40
	q.wHz = 8 * CH
	q.wSweep = 18
	q.wRaise = 6

	q.fistR = LANCE_R + V(0, 0.2 * s, 0)
	q.spear = LANCE * ang(0, 0, 3 * wave(t, CH, 0.4))
	q.fistL = V(4.0, 10.4, -5.6) + V(0, 0.5 * wave(t, CH, 0.35), -0.3 * s)

	q.legX = -40 + 10 * wave(t, CH, 0.25)
	q.legXL = -40 + 10 * wave(t, CH, 0.4)
	q.legZ = 6
	q.shinX = 22 + 10 * wave(t, CH, 0.4)
	q.footX = 15

	q.abdP = 4
	q.abdW = 5
	q.abdHz = CH
	q.sting = -6
	q.glow = 0.35 + 0.15 * s2

	q.orbYaw = 15 * wave(t, CH)
	q.orbHz = CH
	q.orbOut = 1.2
	q.orbY = -0.6 * s
	q.tumble = 600 * t
	q.anger = 1
	rig(pose, t, ctx, q)

	if ctx.crossed(0.45) then
		ctx.emit("GroundDust", 7)
		ctx.emit("PetalBurst", 3)
	end
end

------------------------------------------------------------------------
-- ATTACK (1.2 s): stinger strike - the abdomen whips forward under the body
------------------------------------------------------------------------
local IMPACT = 0.5
local STING = { 20, 40, 55, 40, 40 } -- curl per joint (Abd1..4, Stinger) at full strike

local function attack(t, pose, ctx)
	local c = t
	local q = {}
	local cock = env(c, 0.0, 0.3, 0.04, 0.14, "cubicOut", "quadIn")
	-- whip progress: 0 -> 1 (fast), hold, then exactly back along the same path
	local k
	if c < 0.34 then
		k = 0
	elseif c < IMPACT then
		k = E.quadIn(remap(c, 0.34, IMPACT))
	elseif c < 0.74 then
		k = 1
	else
		k = 1 - E.cubicInOut(remap(c, 0.74, 1.16))
	end
	local impact = env(c, IMPACT, 0.03, 0.05, 0.55, "linear", "elasticOut")
	local lift = L.smoothstep(min(1, k * 1.5))
	local curl = {}
	for j = 1, 5 do
		curl[j] = STING[j] * L.smoothstep((k - 0.5 * (5 - j) / 4) / 0.5)
	end
	q.abdC = curl

	q.y = 0.45 * wave(t, 0.5) + 0.8 * cock + 3.5 * lift - 0.4 * impact
	q.p = 18 * cock - 20 * k + 3 * impact
	q.z = 0.8 * cock - 1.5 * k
	q.hp = 6 * cock + 10 * k - 6 * impact
	q.mand = 30 * cock + 40 * k * (1 - 0.7 * impact)
	q.browY = -0.2
	q.browA = 12 + 6 * k
	q.lid = 0.3 * cock
	q.antP = 15 * cock - 18 * k + 10 * impact
	q.wAmp = 28 + 16 * cock + 12 * k
	q.wHz = 15
	q.wSweep = 4 + 16 * cock
	q.wRaise = 6 + 10 * cock

	local reach = max(cock, k)
	q.fistR = lerpV(FI, V(5.0, 11.4, -1.8), reach)
	q.poleR = V(1, -0.3, 0.3)
	q.spear = ang(14 * k, 0, -8 * k)
	q.fistL = lerpV(FI, V(4.8, 10.2, -3.0), reach)

	q.legX = -12 * cock + 34 * k
	q.legZ = 10 * k
	q.shinX = 10 * cock - 24 * k

	q.abdP = -10 * cock + 3 * impact
	q.abdW = 1.5
	q.abdHz = 2
	q.sting = -16 * cock
	q.glow = max(cock, k)

	q.orbYaw = 10 * wave(t, 1)
	q.orbHz = 0.5
	q.orbY = -1.2 * impact
	q.orbOut = 1.5 * impact
	q.tumble = 120 * t
	q.anger = 1
	local sw = remap(c, IMPACT, IMPACT + 0.4)
	q.shock = (c > IMPACT and c < IMPACT + 0.4) and sw or nil
	rig(pose, t, ctx, q)

	if ctx.crossed(IMPACT) then
		ctx.emit("StingBurst", 45)
		ctx.emit("GroundDust", 25)
		ctx.emit("PetalBurst", 20)
		ctx.emit("BattleBurst", 10)
	end
end

------------------------------------------------------------------------
-- CATCH (2.4 s): victory spin loop, lance raised, laughing
------------------------------------------------------------------------
local function catch(t, pose, ctx)
	local c = t
	local q = {}
	local crouch = env(c, 0, 0.25, 0.05, 0.15, "cubicOut", "quadIn")
	local loopK = E.cubicInOut(remap(c, 0.3, 1.1))
	local rise = env(c, 0.25, 0.45, 0.65, 0.65, "backOut", "cubicInOut")
	local tri = env(c, 1.0, 0.25, 0.7, 0.35, "backOut", "cubicInOut")
	local pump = tri * max(0, wave(c, 2.5))
	local laugh = tri * wave(t, 9)

	q.y = 0.45 * wave(t, 0.5) - 0.4 * crouch + 2.8 * rise
	q.p = -8 * crouch + 10 * tri
	q.yw = 360 * loopK
	q.r = 15 * sin(pi * loopK)
	q.hp = -6 * crouch + 18 * tri + 5 * laugh
	q.hr = 6 * tri * wave(t, 2.5)
	q.mand = 8 * crouch + tri * (30 + 14 * laugh)
	q.browY = 0.3 * tri
	q.browA = 6 * crouch - 6 * tri
	q.lid = 0.3 * tri
	q.antP = 20 * tri + 10 * rise + 6 * laugh
	q.wAmp = 24 + 22 * rise
	q.wHz = 15
	q.wSweep = 10 * rise
	q.wRaise = 6 + 12 * rise

	q.fistR = lerpV(FI + V(0, 0.8 * crouch, 0), CRY_R, tri)
	q.poleR = tri > 0.01 and V(1, -0.3, 0.3) or nil
	q.fistL = lerpV(FI, CRY_L + V(0, 0.8 * pump, 0), tri)
	q.poleL = tri > 0.01 and V(1, -0.2, 0.3) or nil
	q.spear = ang(0, 0, -6 * tri)

	q.legX = -15 * rise + 15 * tri
	q.legZ = 10 * rise
	q.shinX = 15 * rise

	q.abdP = -4 * crouch - 12 * tri - 6 * rise
	q.abdW = 2
	q.abdHz = 2
	q.sting = -28 * tri
	q.glow = tri
	q.spearLight = 1.3 * tri

	q.orbYaw = 360 * loopK
	q.orbHz = 0.5
	q.orbY = 1.2 * rise
	q.orbOut = 2.0 * rise
	q.tumble = 120 * t + 360 * loopK
	rig(pose, t, ctx, q)

	if ctx.crossed(0.32) then
		ctx.emit("PetalBurst", 25)
		ctx.emit("GroundDust", 20)
	end
	if ctx.crossed(1.08) then
		ctx.emit("BattleBurst", 50)
		ctx.emit("SpearSparks", 25)
		ctx.emit("StingBurst", 20)
	end
	if ctx.crossed(1.5) then ctx.emit("BattleBurst", 15) end
end

------------------------------------------------------------------------
-- GIVE UP (2.6 s): buzzing loop-de-loop tantrum, fist shake, droop
------------------------------------------------------------------------
local function giveUp(t, pose, ctx)
	local c = t
	local q = {}
	local pre = env(c, 0, 0.18, 0.02, 0.12)
	local loopK = E.cubicInOut(remap(c, 0.18, 1.15))
	local th = 2 * pi * loopK
	local inLoop = env(c, 0.15, 0.1, 0.85, 0.1)
	local tant = env(c, 1.1, 0.12, 0.45, 0.2)
	local droop = env(c, 1.7, 0.35, 0.3, 0.25)
	local sigh = env(c, 1.85, 0.2, 0.05, 0.4)
	local R = 2.6

	local fold = max(0, sin(th))
	q.y = 0.45 * wave(t, 0.5) - 0.5 * pre + R * (1 - cos(th)) + 2.2 * sin(pi * loopK) + 0.4 * sigh - 0.45 * droop
		- 0.5 * tant * max(0, wave(t, 5))
	q.z = -R * sin(th)
	q.p = deg(th) - 8 * pre - 6 * droop
	q.r = 6 * tant * wave(t, 5)
	q.hp = -6 * tant - 26 * droop + 6 * pre
	q.hy = 22 * tant * wave(t, 6)
	q.hr = 8 * droop
	q.mand = (20 + 16 * wave(t, 10)) * max(inLoop, tant) + 10 * droop
	q.browY = -0.25 * max(pre, inLoop, tant) + 0.15 * droop
	q.browA = 16 * max(pre, inLoop, tant) - 14 * droop
	q.lid = 0.25 * tant + 0.5 * droop
	q.antP = 15 * inLoop - 40 * droop
	q.antR = 10 * tant * wave(t, 7)
	q.antRL = 10 * tant * wave(t, 7, 0.5)
	q.wAmp = 22 + 22 * inLoop + 16 * tant - 12 * droop
	q.wHz = 15 - 5 * droop
	q.wSweep = 4 + 12 * inLoop
	q.wRaise = 6 + 8 * inLoop - 18 * droop

	q.fistR = FI + V(0, 1.2 * tant * max(0, wave(t, 5)) - 0.9 * droop, 0.6 * droop)
	q.spear = ang(-20 * droop, 0, 4 * tant * wave(t, 5))
	q.spearBody = 1
	q.fistL = lerpV(FI, V(4.4, 12.4 + 0.6 * wave(t, 8), -4.4), tant) + V(0, -1.0 * droop, 1.0 * droop)
	q.poleL = tant > 0.01 and V(1, -0.3, 0.3) or nil

	q.legX = 20 * inLoop * wave(t, 3) - 6 * droop
	q.legXL = 20 * inLoop * wave(t, 3, 0.5) - 6 * droop
	q.legZ = 12 * tant - 4 * droop
	q.shinX = 10 * droop

	q.abdP = -6 * inLoop - 26 * fold - 4 * tant
	q.abdW = 3
	q.abdHz = 2
	q.abdYaw = 14 * tant
	q.abdYHz = 6
	q.sting = 6 * droop - 30 * fold
	q.glow = 0.4 * inLoop

	q.orbYaw = 360 * loopK
	q.orbHz = 0.5
	q.orbY = -1.2 * droop
	q.orbOut = 1.2 * inLoop
	q.tumble = 120 * t
	q.anger = c < 1.85 and 1 or 0
	q.sweat = (c > 1.9 and c < 2.55) and 1 or 0
	rig(pose, t, ctx, q)

	if ctx.crossed(0.2) then
		ctx.emit("GroundDust", 20)
		ctx.emit("PetalBurst", 15)
	end
	if ctx.crossed(0.65) then ctx.emit("BattleBurst", 15) end
	if ctx.crossed(1.2) then ctx.emit("GroundDust", 10) end
	if ctx.crossed(1.4) then ctx.emit("GroundDust", 10) end
end

------------------------------------------------------------------------
-- RETURN (1.2 s loop): lazy proud drift home, lance over the shoulder
------------------------------------------------------------------------
local RT = 1 / 1.2
local SHOULDER_R = V(4.7, 10.2, -3.6)
local ON_SHOULDER = ang(50, 0, -12)

local function ret(t, pose, ctx)
	local c = t % 1.2
	local q = {}
	local s = wave(t, RT)
	local grumble = env(c, 0.45, 0.08, 0.06, 0.18)
	q.y = 0.45 * s
	q.p = -5 + 2 * wave(t, RT, 0.2)
	q.r = 4 * wave(t, RT, 0.25)
	q.yw = 3 * wave(t, RT, 0.1)
	q.hp = 6 + 3 * wave(t, RT, 0.15)
	q.hy = 8 * wave(t, RT, 0.4)
	q.hr = -4 * wave(t, RT, 0.25)
	q.mand = 3 + 18 * grumble
	q.browY = -0.15
	q.browA = 9
	q.lid = 0.28
	q.antP = 6 * wave(t, RT, 0.3)
	q.antPL = 6 * wave(t, RT, 0.55)
	q.antR = 4 * wave(t, 2 * RT)
	q.wAmp = 18
	q.wHz = 13 * RT
	q.wSweep = 6
	q.wRaise = 4

	q.fistR = SHOULDER_R + V(0, 0.15 * s, 0)
	q.spear = ON_SHOULDER
	q.spearBody = 1
	q.fistL = FI + V(0, 0.4 * wave(t, RT, 0.25), 0.9 * wave(t, RT))

	q.legX = 8 * wave(t, RT, 0.3)
	q.legXL = 8 * wave(t, RT, 0.8)
	q.legZ = 3
	q.shinX = -4 + 6 * wave(t, RT, 0.45)

	q.abdP = 2
	q.abdW = 4
	q.abdHz = RT
	q.abdYaw = 5
	q.abdYHz = RT
	q.sting = 2
	q.glow = 0

	q.orbYaw = 20 * wave(t, RT)
	q.orbHz = RT
	q.tumble = 300 * t
	rig(pose, t, ctx, q)
end

M.States = {
	Idle = { Loop = true, Length = 12, Update = idle },
	Alert = { Length = 2.0, Update = alert },
	Chase = { Loop = true, Length = 0.6, Speed = 24, Update = chase },
	Attack = { Length = 1.2, Update = attack },
	Catch = { Length = 2.4, Update = catch },
	GiveUp = { Length = 2.6, Update = giveUp },
	Return = { Loop = true, Length = 1.2, Speed = 8, Update = ret },
}
M.Base = "Idle"
M.Reel = { { "Idle" }, { "Alert" }, { "Chase", 3.6 }, { "Attack" }, { "Catch" }, { "Chase", 1.8 }, { "GiveUp" }, { "Return", 3.6 } }
return L.states(M)
