--!nocheck
-- Royal Bee Queen motion: a haughty, bossy bumblebee queen who never lands.
-- Every state fills a table of channels (q) and one shared rig() turns it into
-- the pose, so the hover bob, wing buzz, face, scepter and crown read the same
-- everywhere.
--   Idle   : royal hover + haughty look-around -> inspects her honey scepter
--            (and sneaks a lick) -> royal wave -> crown slips, she fixes it ->
--            SHOW-OFF: crouch, rising spin with a scepter twirl, HONEY BURST
--   Alert  : gasp (crown pops off her head!) -> furious buzz -> points the
--            scepter: "GET THEM!"
--   Chase  : leans forward and zooms, wings blur, abdomen swings, scepter lance
--   Attack : rears back -> scepter BONK + stinger jab -> recoil
--   Catch  : royal victory spin -> crown sparkle -> posh "ho ho ho"
--   GiveUp : royal tantrum (stomps the air, shakes the scepter) -> pouts
--   Return : dignified hover-glide home, nose in the air
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease
local env, track, remap, clamp01 = L.env, L.track, L.remap, L.clamp01
local max, min, abs, sin = math.max, math.min, math.abs, math.sin

local M = {}
M.Props = {
	EyelidR = 1, EyelidL = 1, LashR = 1, LashL = 1,
	HalfR = 1, HalfL = 1, HalfLashR = 1, HalfLashL = 1,
	Anger1 = 1, Anger2 = 1, Anger3 = 1, Anger4 = 1,
	Sweat1 = 1, Sweat2 = 1,
	Excl1 = 1, Excl2 = 1,
	StingGlow = 1,
}

------------------------------------------------------------------------
-- shared rig
------------------------------------------------------------------------
local ZERO = { __index = function() return 0 end }
local ORB_DIR = { 1, -1, 1, -1, 1, -1 }

-- 2-bone arm IK (right-side model rest coordinates; the left arm is mirrored)
local V = Vector3.new
local SH = V(2.6, 9.0, -1.0) -- shoulder pivot
local EL = V(3.65, 7.25, -1.3) -- elbow pivot
local FI = V(3.9, 6.95, -3.25) -- fist (scepter grip)
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
	local pp = pole or POLE0
	local pn = pp - dn * pp:Dot(dn)
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

local function rig(pose, t, ctx, q)
	setmetatable(q, ZERO)

	pose.Body = pa(q.x, q.y, q.z, q.p, q.yw, q.r)
	pose.Head = ang(q.hp, q.hy, q.hr)
	pose.Jaw = ang(-q.jaw, 0, 0)
	L.both(pose, "Mand", ang(0, 0, q.mand))

	-- brows: raise + angry tilt (positive = inner end down); left can differ
	local byL = rawget(q, "browYL") or q.browY
	local baL = rawget(q, "browAL") or q.browA
	pose.BrowR = pa(0, q.browY, 0, 0, 0, q.browA)
	pose.BrowL = L.mirror(pa(0, byL, 0, 0, 0, baL))

	-- pupils look the same world direction
	local look = CFrame.new(math.clamp(q.pupX, -0.35, 0.35), math.clamp(q.pupY, -0.25, 0.5), 0)
	pose.PupilR = look
	pose.PupilL = look
	-- eye pop (shock)
	local pop = q.eyePop
	L.both(pose, "Eye", CFrame.new(0, 0.1 * pop, -0.25 * pop))

	-- lids: full blink lids (props) + haughty half-lids (shown unless wide/blinking)
	local closed = q.lid > 0.5
	local lt = closed and 0 or 1
	ctx.transparency("EyelidR", lt)
	ctx.transparency("EyelidL", lt)
	ctx.transparency("LashR", lt)
	ctx.transparency("LashL", lt)
	local ht = (closed or q.smug < 0.5) and 1 or 0
	ctx.transparency("HalfR", ht)
	ctx.transparency("HalfL", ht)
	ctx.transparency("HalfLashR", ht)
	ctx.transparency("HalfLashL", ht)

	-- antennae (2-bone stacks)
	local apL = rawget(q, "antPL") or q.antP
	local arL = rawget(q, "antRL") or q.antR
	pose.AntR1 = ang(q.antP, 0, q.antR)
	pose.AntR2 = ang(0.8 * q.antP, 0, 0.6 * q.antR)
	pose.AntL1 = L.mirror(ang(apL, 0, arL))
	pose.AntL2 = L.mirror(ang(0.8 * apL, 0, 0.6 * arL))

	-- crown (pops / tilts)
	pose.Crown = pa(q.crX, q.crY, q.crZ, q.crP, q.crYw, q.crR)

	-- wings: buzz (tip up/down in the plate) + sweep + raise
	local fF = q.wRaise + q.wAmp * wave(t, q.wHz)
	local fB = 0.7 * q.wRaise + 0.9 * q.wAmp * wave(t, q.wHz, 0.4)
	local bz = 0.35 * q.wAmp * wave(t, q.wHz, 0.25)
	L.both(pose, "WingF", ang(0, -q.wSweep + bz, fF))
	L.both(pose, "WingB", ang(0, -0.8 * q.wSweep + bz, fB))
	L.both(pose, "WingFT", ang(0, 0.4 * bz, 0.35 * q.wAmp * wave(t, q.wHz, -0.2) + 0.3 * q.wRaise))
	L.both(pose, "WingBT", ang(0, 0.4 * bz, 0.35 * q.wAmp * wave(t, q.wHz, 0.2)))

	-- arms (IK to fist targets, body space, right-frame coords for both)
	local aR, fR = armIK(rawget(q, "fistR") or FI, rawget(q, "poleR"))
	local aL, fL = armIK(rawget(q, "fistL") or FI, rawget(q, "poleL"))
	pose.ArmR, pose.ForeR = aR, fR
	pose.ArmL, pose.ForeL = L.mirror(aL), L.mirror(fL)
	-- scepter: aimed in body space (or world space with scepW = 1)
	local want = rawget(q, "scep") or CFrame.new()
	local parent = aR * fR
	if q.scepW > 0.5 then
		parent = pose.Body.Rotation * parent
	end
	pose.Scepter = parent.Rotation:Inverse() * want

	-- legs: dangle (front pair can move independently for stomps)
	local lxL = rawget(q, "legXL") or q.legX
	pose.LegFR = ang(q.legX, 0, q.legZ)
	pose.LegFL = L.mirror(ang(lxL, 0, q.legZ))
	pose.ShinFR = ang(q.shinX, 0, 0)
	pose.ShinFL = L.mirror(ang(rawget(q, "shinXL") or q.shinX, 0, 0))
	pose.LegBR = ang(0.7 * q.legX + 3, 0, 4 + q.legZ)
	pose.LegBL = L.mirror(ang(0.7 * lxL + 3, 0, 4 + q.legZ))

	-- abdomen (hanging: +X swings it forward) + stinger
	local sw1 = q.abdW * wave(t, q.abdHz)
	local sw2 = q.abdW * wave(t, q.abdHz, -0.15)
	local yw1 = q.abdS * wave(t, q.abdSHz)
	local yw2 = q.abdS * wave(t, q.abdSHz, -0.15)
	pose.Abd1 = ang(q.abdP + sw1, 0, yw1)
	pose.Abd2 = ang(q.abdP2 + 0.8 * q.abdP + sw2, 0, 1.2 * yw2)
	pose.Stinger = ang(q.sting + 1.4 * q.abdW * wave(t, q.abdHz, -0.3), 0, 0)

	-- cape (hanging: -X flares it back)
	pose.Cape = ang(-q.cape, 0, 0)
	pose.Cape2 = ang(-0.8 * q.cape - q.cape2, 0, 0)

	-- glows
	local g = clamp01(q.glow)
	ctx.transparency("StingGlow", g > 0.05 and (0.9 - 0.75 * g) or 1)
	ctx.light("StingLight", 1.5 * g)
	ctx.light("ScepterLight", min(1.5, q.sLight))
	ctx.light("CrownLight", min(1.5, q.cLight))

	-- expression props
	local anger = q.anger > 0.5 and 0 or 1
	for k = 1, 4 do
		ctx.transparency("Anger" .. k, anger)
	end
	local sweat = q.sweat > 0.5 and 0.1 or 1
	ctx.transparency("Sweat1", sweat)
	ctx.transparency("Sweat2", sweat)
	local ex = q.excl > 0.5 and 0 or 1
	ctx.transparency("Excl1", ex)
	ctx.transparency("Excl2", ex)

	-- floating garden voxels
	pose.Orbit = ang(0, q.orbYaw, 0)
	for i = 1, 6 do
		local d = ORB_DIR[i]
		pose["Orb" .. i] = pa(0, 0.6 * wave(t, q.orbHz, i * 0.25) + q.orbY, 0, q.tumble * d, q.tumble * 1.3, 0)
	end
end

-- shared always-on defaults (hover, buzz, dangle, sway)
local function base(t, q, bobHz)
	q.y = 0.3 * wave(t, bobHz)
	q.p = 1.5 * wave(t, bobHz, 0.2)
	q.hp = 4 -- chin a little up: haughty
	q.wAmp, q.wHz, q.wRaise, q.wSweep = 18, 13, 4, 0
	q.abdP, q.abdW, q.abdHz = 0, 3, bobHz
	q.abdS, q.abdSHz = 2.5, bobHz * 0.5
	q.sting = 4
	q.legX = 6 * wave(t, bobHz * 2, 0.15)
	q.shinX = -8 + 6 * wave(t, bobHz * 2, 0.35)
	q.antP = 5 * wave(t, bobHz * 1.5)
	q.antR = 4 * wave(t, bobHz * 3, 0.2)
	q.cape = 4 + 3 * wave(t, bobHz * 2, 0.3)
	q.cape2 = 3 * wave(t, bobHz * 2, 0.1)
	q.browA = -4 -- regal arch
	q.mand = 3 * wave(t, bobHz * 2, 0.4)
	q.aRx, q.aLx = 3 * wave(t, bobHz, 0.3), 3 * wave(t, bobHz, 0.5)
	q.orbYaw = 0
	q.orbHz = 0.5
	q.tumble = 0
end

------------------------------------------------------------------------
-- IDLE (12 s): guarding the honey garden
------------------------------------------------------------------------
local SCAN = {
	{ 0.2, 0 }, { 0.6, -24, "backOut" }, { 1.1, -24 }, { 1.45, 20, "cubicInOut" }, { 1.8, 20 }, { 2.05, 0, "cubicInOut" },
}

local function idle(t, pose, ctx)
	local c = t % 12
	local q = {}
	base(t, q, 0.5)

	local scan = track(c, SCAN)
	-- B: inspect scepter (+ lick)
	local insp = env(c, 2.1, 0.45, 1.35, 0.45, "backOut", "cubicInOut")
	local lick = env(c, 3.05, 0.12, 0.35, 0.15)
	-- C: royal wave
	local wv = env(c, 4.3, 0.4, 1.3, 0.4, "backOut", "cubicInOut")
	-- D: crown slips + fix
	local slip = env(c, 6.25, 0.12, 0.55, 0.35, "backOut", "elasticOut")
	local fix = env(c, 6.45, 0.35, 0.55, 0.35, "backOut", "cubicInOut")
	local tap = env(c, 6.95, 0.06, 0.04, 0.12)
	-- E: show-off
	local crouch = env(c, 7.75, 0.4, 0.1, 0.3, "cubicOut", "cubicIn")
	local rise = env(c, 8.15, 0.45, 1.4, 0.9, "backOut", "cubicInOut")
	local twirl = env(c, 8.2, 0.3, 1.45, 0.3, "backOut", "cubicInOut")
	local spin = 360 * E.cubicInOut(remap(c, 8.25, 9.75))
	local scepSpin = 720 * E.quadInOut(remap(c, 8.3, 9.8))
	local strike = env(c, 9.85, 0.1, 0.9, 0.7, "backOut", "cubicInOut")
	local burst = env(c, 9.85, 0.06, 0.15, 0.6, "quadOut", "cubicOut")
	local show = max(crouch, twirl, strike)
	local calm = 1 - max(insp, wv, fix, show)

	-- BODY
	q.y += -0.5 * crouch + 1.2 * rise + 0.3 * wv
	q.p += 7 * crouch - 4 * twirl + 6 * strike - 4 * insp
	q.yw = 0.3 * scan - 8 * insp + 10 * wv + spin
	q.r = 3 * wave(t, 0.25) * calm + 5 * wv - 4 * insp - 6 * slip

	-- HEAD
	q.hp += 3 * wave(t, 0.5, 0.15) + 6 * wv - 8 * insp + 5 * lick - 8 * crouch + 14 * strike - 6 * fix
	q.hy = 0.8 * scan - 22 * insp + 8 * wv - 6 * twirl
	q.hr = 3 * wave(t, 0.25, 0.3) * calm - 10 * insp + 8 * wv + 9 * slip
	q.pupX = scan / 70 + 0.35 * insp - 0.25 * fix
	q.pupY = 0.25 * insp + 0.45 * fix + 0.2 * strike
	q.jaw = 22 * lick + 30 * burst + 12 * strike * max(0, wave(t, 6)) + 10 * wv
	q.mand += 10 * lick + 18 * strike
	q.browY = 0.15 * insp - 0.2 * crouch + 0.2 * strike
	q.browYL = q.browY + 0.35 * fix + 0.25 * slip
	q.browA += 10 * crouch + 6 * twirl - 4 * wv
	q.browAL = q.browA - 10 * fix
	local blink = max(env(c, 1.25, 0.04, 0.02, 0.06), env(c, 11.55, 0.04, 0.02, 0.06))
	q.lid = max(blink, lick > 0.6 and 1 or 0, wv > 0.6 and 1 or 0)
	q.wide = (slip > 0.3 or burst > 0.2) and 1 or 0
	q.eyePop = 0.8 * slip

	-- CROWN: slips sideways, fixed with a tap, pops on the strike
	q.crR = 16 * slip * (1 - 0.8 * tap) - 4 * tap
	q.crX = -0.4 * slip
	q.crY = 0.1 * slip + 0.5 * burst + 0.15 * tap
	q.cLight = 1.5 * burst + 0.4 * strike

	-- ANTENNAE
	q.antP += 15 * lick - 15 * crouch + 22 * burst + 25 * slip
	q.antR += 10 * slip

	-- WINGS
	q.wAmp = 18 - 8 * crouch + 14 * twirl + 18 * burst
	q.wRaise = 4 - 14 * crouch + 14 * twirl + 18 * strike
	q.wSweep = 12 * crouch - 6 * strike

	-- RIGHT ARM + SCEPTER: inspect (bring it to the face) / twirl overhead / thrust up
	q.aRx += 38 * insp + 20 * crouch + 60 * twirl + 115 * strike * (1 - twirl)
	q.aRz = -14 * insp + 20 * twirl + 10 * strike - 6 * crouch
	q.fRx = 35 * insp - 10 * crouch + 50 * twirl - 60 * strike * (1 - twirl)
	q.sz = 28 * insp
	q.sx = -15 * crouch - scepSpin * twirl
	q.sLight = 1.0 * twirl + 1.5 * burst + 0.4 * lick

	-- LEFT ARM: royal wave / crown fix / balance during show-off
	local wag = wave(c, 2.5)
	q.aLx += 25 * wv + 150 * fix + 10 * crouch + 15 * strike
	q.aLz = 65 * wv + 12 * wag * wv - 10 * fix + 45 * twirl + 35 * strike
	q.fLx = 80 * wv + 55 * fix + 40 * twirl + 30 * strike
	q.fLy = 25 * wag * wv

	-- LEGS
	q.legX += -18 * crouch + 15 * burst + 10 * twirl
	q.shinX += 10 * crouch - 20 * burst

	-- ABDOMEN + CAPE
	q.abdP = -8 * crouch + 18 * burst - 8 * twirl + 6 * strike
	q.abdW = 3 + 3 * twirl
	q.sting += 20 * burst
	q.glow = 0.6 * burst
	q.cape += 12 * twirl + 10 * burst + 8 * rise

	-- CUBES
	q.orbYaw = 30 * wave(t, 1 / 12) + 60 * E.cubicInOut(remap(c, 8.2, 10.2))
	q.orbY = 0.8 * rise
	q.tumble = 30 * t

	rig(pose, t, ctx, q)

	if ctx.crossed(3.1) then ctx.emit("HoneyBurst", 6) end
	if ctx.crossed(6.97) then ctx.emit("CrownSparkle", 10) end
	for k = 0, 5 do
		if ctx.crossed(8.4 + k * 0.24) then ctx.emit("HoneyBurst", 4) end
	end
	if ctx.crossed(9.86) then
		ctx.emit("HoneyBurst", 40)
		ctx.emit("RoyalBurst", 30)
		ctx.emit("CrownSparkle", 20)
		ctx.emit("PetalBurst", 14)
	end
end

------------------------------------------------------------------------
-- ALERT (2.0 s): "MY HONEY!" -> crown pops -> furious buzz -> "GET THEM!"
------------------------------------------------------------------------
local function alert(t, pose, ctx)
	local q = {}
	base(t, q, 0.5)
	local gasp = env(t, 0.0, 0.14, 0.3, 0.3, "backOut", "cubicInOut")
	local crownUp = track(t, { { 0.05, 0 }, { 0.3, 1.6, "quadOut" }, { 0.62, 0, "bounceOut" } })
	local crownSpin = track(t, { { 0.05, 0 }, { 0.62, 180, "quadOut" } })
	local fury = env(t, 0.5, 0.12, 0.6, 0.2, "backOut", "cubicInOut")
	local point = env(t, 1.15, 0.14, 0.45, 0.3, "backOut", "cubicInOut")
	local shake = fury * (L.noise(t, 3, 16))

	q.y += 0.6 * gasp + 0.5 * fury * wave(t, 12) * 0.3 + 0.3 * point
	q.z = 0.8 * gasp - 0.7 * point
	q.p += 14 * gasp - 6 * fury - 14 * point
	q.x = 0.25 * shake
	q.r = 6 * shake

	q.hp += 18 * gasp - 10 * fury + 8 * point
	q.hy = 10 * shake
	q.jaw = 40 * gasp + 18 * fury * max(0, wave(t, 8)) + 40 * point
	q.mand += 25 * gasp + 20 * fury * max(0, wave(t, 10))
	q.browY = 0.4 * gasp - 0.15 * fury
	q.browA = -10 * gasp + 26 * max(fury, point)
	q.wide = gasp > 0.1 and 1 or 0
	q.eyePop = gasp
	q.pupY = -0.1 * gasp
	q.excl = (t > 0.08 and t < 1.0) and 1 or 0
	q.anger = (t > 0.55) and 1 or 0

	q.crY = crownUp
	q.crYw = crownSpin
	q.crR = 10 * crownUp
	q.cLight = 0.6 * crownUp

	q.antP += 35 * gasp - 15 * fury
	q.antR += 15 * shake

	q.wAmp = 18 + 10 * gasp + 22 * fury + 12 * point
	q.wHz = 20
	q.wRaise = 4 + 16 * gasp + 10 * fury
	q.wSweep = -8 * gasp + 10 * point

	-- arms: fling up in shock -> fists clenched shaking -> scepter points forward
	q.aRx += 30 * gasp + 40 * fury + 72 * point
	q.aRz = 30 * gasp + 15 * fury - 4 * point
	q.fRx = 30 * gasp + 40 * fury * (1 - point) - 40 * point + 10 * fury * wave(t, 12)
	q.sx = -95 * point
	q.sLight = 1.2 * point
	q.aLx += 30 * gasp + 40 * fury + 20 * point
	q.aLz = 30 * gasp + 15 * fury + 25 * point
	q.fLx = 40 * gasp + 70 * fury + 60 * point + 12 * fury * wave(t, 12, 0.3)

	q.legX += 25 * gasp - 15 * fury
	q.shinX += -25 * gasp
	q.abdP = -12 * gasp + 10 * fury + 12 * point
	q.abdW = 3 + 4 * fury
	q.abdHz = 6
	q.sting += 25 * fury
	q.glow = 0.7 * fury
	q.cape += 18 * gasp + 10 * fury + 10 * point

	q.tumble = 60 * t
	q.orbY = 0.6 * gasp

	rig(pose, t, ctx, q)

	if ctx.crossed(0.08) then ctx.emit("RoyalBurst", 20) end
	if ctx.crossed(0.62) then ctx.emit("CrownSparkle", 12) end
	if ctx.crossed(0.6) then ctx.emit("Steam", 10) end
	if ctx.crossed(0.95) then ctx.emit("Steam", 8) end
	if ctx.crossed(1.25) then
		ctx.emit("RoyalBurst", 30)
		ctx.emit("HoneyBurst", 20)
		ctx.emit("StingSpark", 12)
	end
end

------------------------------------------------------------------------
-- CHASE (0.6 s loop): leaned-forward zoom
------------------------------------------------------------------------
local CH = 1 / 0.6
local function chase(t, pose, ctx)
	local q = {}
	base(t, q, CH)
	local bob = wave(t, 2 * CH)
	q.y = 0.35 * bob + 0.2
	q.p = -24 + 3 * wave(t, 2 * CH, 0.2)
	q.r = 4 * wave(t, CH)
	q.yw = 3 * wave(t, CH, 0.25)
	q.z = 0

	q.hp = 16 + 3 * wave(t, 2 * CH, 0.1)
	q.hy = -3 * wave(t, CH, 0.25)
	q.jaw = 14 + 12 * max(0, wave(t, 2 * CH))
	q.mand = 12 + 8 * wave(t, 2 * CH)
	q.browA = 24
	q.browY = -0.1
	q.wide = 1
	q.pupY = 0.2
	q.anger = 1

	q.antP = 32 + 6 * wave(t, 2 * CH, 0.3)
	q.antR = 4 * wave(t, CH)
	q.wAmp, q.wHz, q.wRaise, q.wSweep = 32, 15 * CH, 6, 20

	-- scepter couched forward like a lance, left arm pumping
	q.aRx = 55 + 5 * wave(t, CH, 0.1)
	q.aRz = -4
	q.fRx = -20
	q.sx = -80 + 6 * wave(t, 2 * CH)
	q.sLight = 0.4
	q.aLx = -25 + 30 * wave(t, CH)
	q.aLz = 12
	q.fLx = 50 + 20 * wave(t, CH, 0.2)

	q.legX = -30 + 12 * wave(t, 2 * CH, 0.2)
	q.legXL = -30 + 12 * wave(t, 2 * CH, 0.7)
	q.shinX = -25 + 10 * wave(t, 2 * CH, 0.4)
	q.abdP = 12
	q.abdW = 10
	q.abdHz = CH
	q.abdS = 6
	q.abdSHz = CH
	q.sting = 10
	q.glow = 0.3
	q.cape = 30 + 10 * wave(t, 2 * CH)
	q.cape2 = 10 * wave(t, 2 * CH, 0.25)

	q.orbYaw = 0
	q.tumble = 240 * t
	rig(pose, t, ctx, q)

	if ctx.crossed(0.05) then ctx.emit("PetalBurst", 3) end
end

------------------------------------------------------------------------
-- ATTACK (1.2 s): rear back -> scepter BONK + stinger jab -> recoil
------------------------------------------------------------------------
local function attack(t, pose, ctx)
	local q = {}
	base(t, q, 0.5)
	local wind = env(t, 0.0, 0.38, 0.04, 0.1, "cubicOut", "quadIn")
	local hit = env(t, 0.4, 0.1, 0.22, 0.5, "expoOut", "cubicInOut")
	local impact = env(t, 0.48, 0.04, 0.08, 0.3, "quadOut", "backOut")

	q.y += 0.9 * wind - 0.2 * hit - 0.3 * impact
	q.z = 0.9 * wind - 2.0 * hit
	q.p += 16 * wind - 24 * hit
	q.r = 6 * impact * wave(t, 10)

	q.hp += 10 * wind - 4 * hit
	q.jaw = 8 * wind + 42 * hit
	q.mand += 20 * wind + 25 * hit
	q.browA = 28 * max(wind, hit)
	q.browY = -0.15 * wind
	q.wide = hit > 0.2 and 1 or 0
	q.anger = (t > 0.05 and t < 1.0) and 1 or 0
	q.eyePop = 0.4 * impact

	q.crY = 0.4 * impact
	q.crR = 6 * impact

	q.antP += -20 * wind + 35 * hit
	q.wAmp = 18 + 18 * wind + 14 * hit
	q.wHz = 16
	q.wRaise = 4 + 18 * wind - 8 * hit
	q.wSweep = -10 * wind + 16 * hit

	-- scepter raised behind the head -> chops down in front
	q.aRx += 150 * wind + 40 * hit
	q.aRz = 10 * wind - 6 * hit
	q.fRx = 30 * wind - 30 * hit
	q.sx = 35 * wind - 105 * hit
	q.sLight = 1.5 * impact + 0.4 * wind
	q.aLx += 15 * wind + 20 * hit
	q.aLz = 30 * wind + 20 * hit
	q.fLx = 40 * wind + 30 * hit

	q.legX += -15 * wind + 25 * hit
	q.shinX += -15 * hit
	-- abdomen cocks back, then whips forward: STINGER JAB
	q.abdP = -18 * wind + 48 * hit
	q.abdP2 = 22 * hit
	q.sting += -20 * wind + 40 * hit
	q.abdW = 2
	q.glow = max(0.6 * wind, hit)
	q.cape += 10 * wind + 25 * hit

	q.tumble = 60 * t
	rig(pose, t, ctx, q)

	if ctx.crossed(0.5) then
		ctx.emit("HoneyBurst", 30)
		ctx.emit("StingSpark", 22)
		ctx.emit("RoyalBurst", 12)
	end
end

------------------------------------------------------------------------
-- CATCH (2.2 s): royal victory spin -> crown sparkle -> "ho ho ho"
------------------------------------------------------------------------
local function catch(t, pose, ctx)
	local q = {}
	base(t, q, 0.5)
	local crouch = env(t, 0.0, 0.25, 0.05, 0.2, "cubicOut", "cubicIn")
	local up = env(t, 0.25, 0.4, 1.15, 0.4, "backOut", "cubicInOut")
	local spin = 360 * E.cubicInOut(remap(t, 0.3, 1.25))
	local spark = env(t, 1.25, 0.08, 0.2, 0.5, "backOut", "cubicInOut")
	local gloat = env(t, 1.3, 0.2, 0.45, 0.25, "backOut", "cubicInOut")
	local ho = gloat * max(0, wave(t, 5))

	q.y += -0.5 * crouch + 1.5 * up
	q.p += 6 * crouch - 6 * up + 6 * gloat
	q.yw = spin
	q.r = 6 * gloat * wave(t, 2.5)

	q.hp += -8 * crouch + 8 * up + 16 * gloat + 4 * ho
	q.hr = 8 * gloat
	q.jaw = 10 * up + 30 * ho
	q.mand += 15 * ho
	q.browY = 0.2 * up
	q.browYL = 0.2 * up + 0.3 * gloat
	q.browA = -6 * up
	q.lid = gloat > 0.3 and 1 or 0
	q.wide = (spark > 0.3 and gloat < 0.3) and 1 or 0

	q.crY = 0.6 * spark
	q.crYw = 0
	q.cLight = 1.5 * spark

	q.antP += 25 * up - 10 * crouch
	q.wAmp = 18 + 16 * up
	q.wRaise = 4 + 20 * up - 12 * crouch
	q.wSweep = 10 * crouch

	-- scepter raised high, then held proudly; left hand to the mouth (posh laugh)
	q.aRx += 140 * up * (1 - gloat) + 25 * gloat
	q.aRz = 25 * up * (1 - gloat)
	q.fRx = 40 * up * (1 - gloat) + 10 * gloat
	q.sLight = 1.2 * up
	q.aLx += 20 * up + 70 * gloat
	q.aLz = 60 * up * (1 - gloat) - 12 * gloat
	q.fLx = 30 * up + 75 * gloat
	q.fLy = -25 * gloat

	q.legX += 20 * up
	q.shinX += -15 * up
	q.abdP = -6 * crouch + 10 * up
	q.abdW = 3 + 4 * up
	q.cape += 20 * up

	q.orbYaw = 120 * E.cubicInOut(remap(t, 0.3, 1.4))
	q.orbY = up
	q.tumble = 90 * t
	rig(pose, t, ctx, q)

	if ctx.crossed(1.27) then
		ctx.emit("CrownSparkle", 30)
		ctx.emit("RoyalBurst", 25)
		ctx.emit("HoneyBurst", 10)
	end
end

------------------------------------------------------------------------
-- GIVEUP (2.6 s): royal tantrum (stomps the air, scepter shake) -> pout
------------------------------------------------------------------------
local function giveUp(t, pose, ctx)
	local q = {}
	base(t, q, 0.5)
	local tan = env(t, 0.0, 0.15, 1.15, 0.25, "backOut", "cubicInOut")
	local pout = env(t, 1.35, 0.3, 0.6, 0.3, "backOut", "cubicInOut")
	local stomp = max(0, wave(t, 5))
	local stompL = max(0, wave(t, 5, 0.5))

	q.y += -0.35 * tan * (stomp + stompL) * 0.6 - 0.25 * pout
	q.p += -6 * tan + 3 * pout
	q.yw = 18 * pout
	q.r = 5 * tan * wave(t, 5)

	q.hp += -6 * tan + 16 * pout
	q.hy = 14 * tan * wave(t, 4) + 30 * pout
	q.hr = 6 * tan * wave(t, 5, 0.2) - 8 * pout
	q.jaw = tan * (25 + 12 * wave(t, 7))
	q.mand += 18 * tan
	q.browA = 28 * tan + 14 * pout
	q.browY = -0.2 * tan + 0.1 * pout
	q.lid = pout > 0.4 and 1 or 0
	q.wide = 0
	q.anger = tan > 0.2 and 1 or 0
	q.sweat = pout > 0.3 and 1 or 0
	q.pupX = -0.3 * pout

	q.crR = 8 * tan * wave(t, 5)
	q.crY = 0.15 * tan * stomp

	q.antP += 20 * tan * wave(t, 5) - 10 * pout
	q.wAmp = 18 + 18 * tan - 8 * pout
	q.wHz = 15
	q.wRaise = 4 + 8 * tan - 14 * pout
	q.wSweep = 10 * pout

	-- scepter shaken overhead, left fist pumping; then arms folded (pout)
	q.aRx += 120 * tan + 40 * pout
	q.aRz = 15 * tan - 12 * pout
	q.fRx = 20 * tan + 20 * tan * wave(t, 8) + 70 * pout
	q.fRy = 50 * pout
	q.sx = 20 * tan * wave(t, 8, 0.2) - 20 * pout
	q.sLight = 0.6 * tan
	q.aLx += 90 * tan + 40 * pout
	q.aLz = 25 * tan - 12 * pout
	q.fLx = 60 * tan + 25 * tan * wave(t, 8, 0.5) + 70 * pout
	q.fLy = 50 * pout

	-- stomping the air: legs kick down alternately
	q.legX = tan * (-10 + 40 * wave(t, 5)) - 6 * pout
	q.legXL = tan * (-10 + 40 * wave(t, 5, 0.5)) - 6 * pout
	q.shinX = -8 + tan * (25 * stomp - 20)
	q.shinXL = -8 + tan * (25 * stompL - 20)
	q.abdP = 6 * tan * wave(t, 5) - 6 * pout
	q.abdW = 4
	q.abdS = 6 * tan
	q.abdSHz = 2.5
	q.cape += 10 * tan * wave(t, 5)

	q.tumble = 20 * t
	rig(pose, t, ctx, q)

	for k = 0, 5 do
		if ctx.crossed(0.05 + k * 0.2) then ctx.emit("PetalBurst", 3) end
	end
	if ctx.crossed(0.25) then ctx.emit("Steam", 8) end
	if ctx.crossed(0.85) then ctx.emit("Steam", 10) end
	if ctx.crossed(1.6) then ctx.emit("Steam", 5) end
end

------------------------------------------------------------------------
-- RETURN (1.4 s loop): dignified hover-glide home
------------------------------------------------------------------------
local RT = 1 / 1.4
local function ret(t, pose, ctx)
	local q = {}
	base(t, q, RT)
	q.y = 0.3 * wave(t, RT)
	q.p = -7 + 2 * wave(t, RT, 0.2)
	q.r = 3 * wave(t, RT, 0.1)
	q.hp = 12 + 2 * wave(t, RT, 0.15)
	q.hr = 3 * wave(t, RT, 0.3)
	q.browY = 0.1
	q.browYL = 0.25
	q.browA = -6
	q.wAmp, q.wHz, q.wRaise, q.wSweep = 16, 16 * RT, 4, 8

	q.aRx = 6 + 4 * wave(t, RT)
	q.aLx = 10 + 10 * wave(t, RT, 0.25)
	q.aLz = 10
	q.fLx = 20 + 10 * wave(t, RT, 0.4)

	q.legX = -14 + 6 * wave(t, 2 * RT, 0.15)
	q.abdP = 4
	q.abdW = 4
	q.cape = 12 + 5 * wave(t, 2 * RT, 0.3)
	q.tumble = 30 * t
	rig(pose, t, ctx, q)
end

M.States = {
	Idle = { Loop = true, Length = 12, Update = idle },
	Alert = { Length = 2.0, Update = alert },
	Chase = { Loop = true, Length = 0.6, Speed = 24, Update = chase },
	Attack = { Length = 1.2, Update = attack },
	Catch = { Length = 2.2, Update = catch },
	GiveUp = { Length = 2.6, Update = giveUp },
	Return = { Loop = true, Length = 1.4, Speed = 9, Update = ret },
}
M.Base = "Idle"
M.Reel = { { "Idle" }, { "Alert" }, { "Chase", 3.6 }, { "Attack" }, { "Catch" }, { "Chase", 1.8 }, { "GiveUp" }, { "Return", 4.2 } }
return L.states(M)
