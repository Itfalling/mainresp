--!nocheck
-- Ironhorn Rhino motion (Guardian states). Stubborn, hot-headed bully.
--   Idle   (12 s): steam snorts, paws the ground (dust), suspicious looks,
--                  head shake with armour clank (leaves fall), tail swish and
--                  the SHOW-OFF: rears up on the hind legs, roars, SLAMS the
--                  front hooves down (shockwave ring, dust, cubes, debris),
--                  then a smug double snort.
--   Alert  (2.0 s): jolt -> big inhale -> FURIOUS steam blast + roar ->
--                  scrapes the ground twice -> lowers the horn.
--   Chase  (0.6 s): thundering rotary gallop, head down horn forward, dust on
--                  every footfall, steam puffs.
--   Attack (1.1 s): rock back + tuck the horn -> lunge + HORN UPPERCUT toss.
--   Catch  (2.2 s): triumphant rear + roar -> stomp slam -> smug snort.
--   GiveUp (2.6 s): skids to a stop -> steam from the head -> tantrum stomps
--                  -> big huff, calms.
--   Return (1.2 s): heavy grumpy stomp-walk.
-- Every leg is solved with a 2-bone IK so planted hooves never slide or sink.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, env, E = L.ang, L.pa, L.wave, L.env, L.ease
local deg, rad, atan2, acos, sqrt = math.deg, math.rad, math.atan2, math.acos, math.sqrt
local clamp, max, min, abs, sin, cos, pi = math.clamp, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local V = Vector3.new

-- rest pivots (must match build.luau; right side)
local H0 = V(0, 6.6, 3.6) -- Hips
local C0 = V(0, 7.4, 0.8) -- Chest
local SH = V(3.6, 6.6, -2.2) -- ArmR (shoulder)
local EL = V(3.6, 3.9, -2.7) -- ForeR (knee, points forward)
local WR = V(3.6, 1.3, -2.2) -- HoofR (wrist)
local HP = V(3.6, 6.6, 3.8) -- ThighR
local KN = V(3.6, 3.9, 3.4) -- ShinR
local AN = V(3.6, 1.3, 4.0) -- FootR
local NK = V(0, 8.4, -3.6) -- Neck
local HD = V(0, 7.8, -6.0) -- Head
local JW = V(0, 5.0, -8.9) -- Jaw
-- lowest corners of the jaw / snout (model rest space) for the ground clamp
local JAW_LOW = { V(2.75, 3.18, -8.9), V(-2.75, 3.18, -8.9), V(2.75, 3.18, -13.3), V(-2.75, 3.18, -13.3), V(0, 3.55, -13.85) }
local HEAD_LOW = { V(2.9, 4.9, -13.1), V(-2.9, 4.9, -13.1), V(2.3, 4.05, -12.75) }
local HEAD_FLOOR = 0.35

-- angle of a hanging limb segment (0 = straight down, + = swung forward / -Z)
local function segAng(dy, dz)
	return deg(atan2(-dz, -dy))
end
local function len2(dy, dz)
	return sqrt(dy * dy + dz * dz)
end
local F_UP, F_LO = segAng(EL.Y - SH.Y, EL.Z - SH.Z), segAng(WR.Y - EL.Y, WR.Z - EL.Z)
local F_L1, F_L2 = len2(EL.Y - SH.Y, EL.Z - SH.Z), len2(WR.Y - EL.Y, WR.Z - EL.Z)
local B_UP, B_LO = segAng(KN.Y - HP.Y, KN.Z - HP.Z), segAng(AN.Y - KN.Y, AN.Z - KN.Z)
local B_L1, B_L2 = len2(KN.Y - HP.Y, KN.Z - HP.Z), len2(AN.Y - KN.Y, AN.Z - KN.Z)
local F_REACH, B_REACH = (F_L1 + F_L2) * 0.985, (B_L1 + B_L2) * 0.985

-- 2-bone IK in the side plane: world angles of the upper and lower segment.
-- bend = -1 elbow points back, +1 knee points forward.
local function ik2(sy, sz, ty, tz, l1, l2, bend)
	local dy, dz = ty - sy, tz - sz
	local d = clamp(len2(dy, dz), abs(l1 - l2) + 0.01, l1 + l2 - 0.001)
	local a = deg(acos(clamp((l1 * l1 + d * d - l2 * l2) / (2 * l1 * d), -1, 1)))
	local up = segAng(dy, dz) + bend * a
	local ur = rad(up)
	local ey, ez = sy - l1 * cos(ur), sz - l1 * sin(ur)
	return up, segAng(ty - ey, tz - ez)
end

-- how far the body must drop so a hoof at (ty, tz) stays reachable
local function needDrop(p, ty, tz, reach)
	local dz = tz - p.Z
	local maxDown = sqrt(max(0, reach * reach - dz * dz))
	return max(0, (p.Y - ty) - maxDown)
end

local LEGS = {
	{ "ArmR", "ForeR", "HoofR", 1, true },
	{ "ArmL", "ForeL", "HoofL", -1, true },
	{ "ThighR", "ShinR", "FootR", 1, false },
	{ "ThighL", "ShinL", "FootL", -1, false },
}
local FOOTKEY = { "FR", "FL", "HR", "HL" }
local ZERO3 = { 0, 0, 0 }

------------------------------------------------------------------------
-- Shared pose solver. S fields (all optional, degrees / studs):
--   hx hy hz hp hyaw hroll  hips      cp cyaw croll  chest
--   np nyaw nroll  neck      dp dyaw droll  head      jaw (neg = open)
--   lid (0..1) earP earZ  tailP tailY tuftY   sprig
--   FR FL HR HL = { dy, dz, pitch } hoof target offsets from rest (model space)
--   airR airL = { w, arm, fore, hoof } front leg keyframe pose blended over IK
------------------------------------------------------------------------
local function solve(pose, ctx, S)
	local function g(k)
		return S[k] or 0
	end
	local drop = 0
	local hipsCF, hipsW, chestW
	for _ = 1, 2 do
		hipsCF = pa(g("hx"), g("hy") - drop, g("hz"), g("hp"), g("hyaw"), g("hroll"))
		hipsW = CFrame.new(H0) * hipsCF
		chestW = hipsW * CFrame.new(C0 - H0) * ang(g("cp"), g("cyaw"), g("croll"))
		local need = 0
		for i, lg in LEGS do
			local f = S[FOOTKEY[i]] or ZERO3
			local air = (lg[4] == 1 and S.airR or S.airL)
			if not (lg[5] and air and air[1] > 0.5) and f[1] < 0.3 then
				local piv = lg[5] and SH or HP
				local w = lg[5] and (chestW * (V(piv.X * lg[4], piv.Y, piv.Z) - C0)) or (hipsW * (V(piv.X * lg[4], piv.Y, piv.Z) - H0))
				local rest = lg[5] and WR or AN
				need = max(need, needDrop(w, rest.Y + f[1], rest.Z + f[2], lg[5] and F_REACH or B_REACH))
			end
		end
		if need < 0.01 then
			break
		end
		drop += need
	end
	pose.Hips = hipsCF
	pose.Chest = ang(g("cp"), g("cyaw"), g("croll"))

	for i, lg in LEGS do
		local f = S[FOOTKEY[i]] or ZERO3
		local s = lg[4]
		local front = lg[5]
		local parentW = front and chestW or hipsW
		local ppiv = front and C0 or H0
		local piv = front and SH or HP
		local rest = front and WR or AN
		local p = parentW * (V(piv.X * s, piv.Y, piv.Z) - ppiv)
		local up, lo = ik2(p.Y, p.Z, rest.Y + f[1], rest.Z + f[2], front and F_L1 or B_L1, front and F_L2 or B_L2, 1)
		local rUp, rLo = front and F_UP or B_UP, front and F_LO or B_LO
		local upperIK = parentW.Rotation:Inverse() * ang(up - rUp, 0, 0)
		local lowerA = (lo - rLo) - (up - rUp)
		local footA = -(lo - rLo) + (f[3] or 0)
		local air = front and (s == 1 and S.airR or S.airL) or nil
		if air and air[1] > 0 then
			local w = clamp(air[1], 0, 1)
			pose[lg[1]] = upperIK:Lerp(ang(air[2], 0, 0), w)
			pose[lg[2]] = ang(L.lerp(lowerA, air[3], w), 0, 0)
			pose[lg[3]] = ang(L.lerp(footA, air[4], w), 0, 0)
		else
			pose[lg[1]] = upperIK
			pose[lg[2]] = ang(lowerA, 0, 0)
			pose[lg[3]] = ang(footA, 0, 0)
		end
	end

	-- head/jaw ground clamp: lift the neck until the jaw clears the floor
	local np = g("np")
	local headR = ang(g("dp"), g("dyaw"), g("droll"))
	local jawR = ang(-4 + g("jaw"), 0, 0)
	for _ = 1, 10 do
		local neckW = chestW * CFrame.new(NK - C0) * ang(np, g("nyaw"), g("nroll"))
		local jawW = neckW * CFrame.new(HD - NK) * headR * CFrame.new(JW - HD) * jawR
		local headW = neckW * CFrame.new(HD - NK) * headR
		local low = math.huge
		for _, p in JAW_LOW do
			low = min(low, (jawW * (p - JW)).Y)
		end
		for _, p in HEAD_LOW do
			low = min(low, (headW * (p - HD)).Y)
		end
		if low >= HEAD_FLOOR then
			break
		end
		np += max(1.5, (HEAD_FLOOR - low) * 7)
	end
	pose.Neck = ang(np, g("nyaw"), g("nroll"))
	pose.Head = headR
	pose.Jaw = jawR

	-- eyelids (props): slide down over the eye
	local lid = clamp(g("lid"), 0, 1)
	L.both(pose, "Lid", CFrame.new(0, -0.95 * lid, 0))
	if lid > 0.12 then
		ctx.transparency("EyelidR", 0)
		ctx.transparency("EyelidL", 0)
	end

	-- ears: +earZ flares them up/out, -earP pins them back
	L.both(pose, "Ear", ang(g("earP"), 0, g("earZ") + (S.earR or 0)), ang(g("earP"), 0, g("earZ") + (S.earL or 0)))

	-- tail: lift (-X) + swish (Y) with lag down the chain
	pose.Tail1 = ang(g("tailP"), g("tailY"), 0)
	pose.Tail2 = ang(0.6 * g("tailP2"), g("tailY2"), 0)
	pose.Tuft = ang(0, g("tuftY"), g("tuftZ"))
	pose.SprigA = ang(g("sprig"), 0, 1.4 * g("sprig2"))
	pose.SprigB = ang(-g("sprig2"), 0, g("sprig"))
end

------------------------------------------------------------------------
-- shared FX helpers
------------------------------------------------------------------------
local ORB_DIR = { 1, -1, 1, -1 }
local function orbs(t, pose, out, lift)
	pose.Orbit = ang(0, 22 * wave(t, 1 / 12), 0)
	for i = 1, 4 do
		local dir = ORB_DIR[i]
		local bob = 0.9 * wave(t, 0.5, i * 0.25)
		pose["Orb" .. i] = pa(out * dir * 0.6, bob + (lift or 0) + 0.4 * out, 0, 70 * t * dir, 100 * t, 15 * i)
	end
end

-- shockwave ring + debris, `since` = seconds since the impact
local function slamFX(pose, ctx, since)
	local on = since >= 0 and since < 0.5
	local sw = clamp(since / 0.5, 0, 1)
	local r = 5.5 * E.quadOut(sw)
	for k = 1, 10 do
		local a = (k - 1) / 10 * 2 * pi
		if on then
			pose["Shock" .. k] = CFrame.new(-sin(a) * r, 0.3 * (1 - sw), -cos(a) * r)
			local tr = 0.05 + 0.9 * sw * sw
			ctx.transparency("Wave" .. k, tr)
			ctx.transparency("WaveTop" .. k, tr)
		else
			pose["Shock" .. k] = CFrame.new()
		end
	end
	local dp = since / 0.8
	for i = 1, 4 do
		if dp >= 0 and dp < 1 then
			local a = rad(-60 + (i - 1) * 40)
			local u = E.quadOut(dp)
			local rr = 3.0 * u * (0.8 + 0.15 * (i % 3))
			local h = (3.4 + 0.7 * (i % 2)) * 4 * u * (1 - u)
			pose["Debris" .. i] = pa(rr * sin(a), h, -rr * cos(a), 400 * dp, 280 * dp * (i % 2 == 0 and 1 or -1), 0)
			ctx.transparency("Debris" .. i, dp < 0.8 and 0 or (dp - 0.8) * 5)
		else
			pose["Debris" .. i] = CFrame.new()
		end
	end
end

local function angerMark(pose, ctx, t, on)
	if on > 0.5 then
		local pulse = L.bounce(t, 3)
		pose.Anger = CFrame.new(0.15 * pulse, 0.25 * pulse, 0)
		for i = 1, 4 do
			ctx.transparency("Anger" .. i, 0)
		end
	else
		pose.Anger = CFrame.new()
	end
end

local function blinkAt(c, times)
	local k = 0
	for _, s in times do
		k = max(k, env(c, s, 0.05, 0.04, 0.07))
	end
	return k
end

-- stance/swing gait for one foot. u in [0,1) cycle phase, duty = stance fraction
local function gait(u, duty, sweep, lift)
	if u < duty then
		local s = u / duty
		return 0, -sweep / 2 + sweep * s, 0, false
	end
	local s = (u - duty) / (1 - duty)
	local k = L.smoothstep(s)
	return lift * sin(pi * s), sweep / 2 - sweep * k, -35 * sin(pi * s), true
end

------------------------------------------------------------------------
-- STATES
------------------------------------------------------------------------
local M = {}
M.Props = {
	EyelidR = 1, EyelidL = 1,
	Anger1 = 1, Anger2 = 1, Anger3 = 1, Anger4 = 1,
	Debris1 = 1, Debris2 = 1, Debris3 = 1, Debris4 = 1,
}
for k = 1, 10 do
	M.Props["Wave" .. k] = 1
	M.Props["WaveTop" .. k] = 1
end

------------------------------------------------------------------------
-- IDLE (12 s): guarding the plant
------------------------------------------------------------------------
local IDLE_LEN = 12
local IMPACT_I = 9.25
local function idle(t, pose, ctx)
	local c = t % IDLE_LEN
	local S = {}
	local br = wave(t, 0.5)

	-- show-off envelopes
	local crouch = env(c, 7.6, 0.45, 0.05, 0.25, "cubicOut", "quadIn")
	local rear = env(c, 8.1, 0.4, 0.62, 0.13, "backOut", "quadIn") -- slams at ~9.25
	local impact = env(c, IMPACT_I, 0.04, 0.05, 0.9, "quadOut", "elasticOut")
	local roar = env(c, 8.45, 0.15, 0.5, 0.2, "backOut", "quadIn")
	local show = clamp(max(crouch, rear, impact * 0.8), 0, 1)
	local idleW = 1 - show

	-- gags
	local inhale = env(c, 0.3, 0.4, 0.05, 0.1, "quadOut", "quadIn")
	local snort = env(c, 0.75, 0.06, 0.08, 0.4, "quadOut", "backOut") + env(c, 0.98, 0.05, 0.05, 0.35, "quadOut", "backOut") * 0.7
	local paw = env(c, 1.8, 0.2, 1.0, 0.3)
	local look = L.track(c, {
		{ 3.8, 0 }, { 3.98, 30, "backOut" }, { 4.45, 30 }, { 4.62, -30, "backOut" }, { 5.05, -30 }, { 5.25, 0, "backOut" },
	})
	local shake = env(c, 5.4, 0.1, 0.8, 0.35)
	local swish = env(c, 6.5, 0.15, 0.8, 0.3)
	local smug = env(c, 9.7, 0.25, 0.6, 0.6, "backOut", "quadInOut")
	local nod = env(c, 10.6, 0.2, 0.1, 0.4, "quadOut", "backOut")

	-- paw the ground: right front hoof lifts forward and scrapes back twice
	local pz = L.track(c, { { 1.8, 0 }, { 2.0, -1.2, "quadOut" }, { 2.22, 1.0, "quadIn" }, { 2.42, -1.0, "quadOut" }, { 2.64, 1.0, "quadIn" }, { 2.9, 0, "quadInOut" } })
	local py = L.track(c, { { 1.8, 0 }, { 2.0, 1.3, "quadOut" }, { 2.2, 0.05, "quadIn" }, { 2.4, 1.1, "quadOut" }, { 2.62, 0.05, "quadIn" }, { 2.75, 0.3 }, { 2.9, 0, "quadIn" } })

	-- body
	S.hy = 0.12 * br * idleW - 0.8 * crouch - 1.3 * impact + 0.3 * inhale - 0.2 * snort
	S.hz = 0.7 * crouch - 0.4 * rear + 0.25 * paw
	S.hp = 40 * rear - 4 * crouch - 3 * impact + 1.0 * br * idleW
	S.hyaw = 6 * swish * wave(t, 3) + 3 * shake * wave(t, 5, 0.2)
	S.hroll = 2 * wave(t, 0.5, 0.25) * idleW - 2.5 * paw + 3 * shake * wave(t, 5)
	S.cp = 1.5 * br + 5 * inhale - 3 * snort + 8 * rear - 5 * impact
	S.croll = -2 * paw + 3 * shake * wave(t, 5, 0.1)

	-- hooves: planted, right front paws the ground
	S.FR = { py, pz, -25 * py / 1.3 }
	S.FL = ZERO3
	S.HR, S.HL = ZERO3, ZERO3

	-- front legs in the air while reared: paddle like a bucking bronco
	local airW = L.smoothstep(clamp((rear - 0.15) / 0.45, 0, 1))
	local pad = wave(t, 3)
	S.airR = { airW, -20 + 35 * pad, 45 + 25 * pad, -20 }
	S.airL = { airW, -20 - 35 * pad, 45 - 25 * pad, -20 }

	-- neck / head
	local shakeRoll = 24 * shake * wave(t, 5)
	S.np = -2 * br * idleW + 6 * inhale - 8 * snort - 10 * paw - 6 * crouch - 8 * rear + 6 * impact - 4 * nod
	S.nyaw = 0.35 * look
	S.dp = 2 * br + 10 * inhale - 12 * snort - 10 * paw - 8 * crouch + 22 * roar - 10 * impact + 14 * smug - 14 * nod
	S.dyaw = 0.65 * look + 8 * shake * wave(t, 5, 0.25) - 10 * smug
	S.droll = shakeRoll + 12 * smug + 3 * L.noise(t, 3.1, 0.4) * idleW
	S.jaw = -6 * snort - 55 * roar - 8 * shake * max(0, wave(t, 10)) - 10 * impact

	-- face
	S.lid = max(blinkAt(c, { 1.5, 4.4, 7.0, 11.2 }) * (1 - roar), 0.35 * paw + 0.45 * crouch + 0.4 * smug)
	S.earP = -14 * paw - 25 * crouch + 25 * roar - 10 * smug
	S.earZ = 8 * wave(t, 0.5) * idleW + 35 * shake * wave(t, 5, 0.3) + 10 * inhale - 20 * crouch
	local flick = env(c, 3.25, 0.06, 0.04, 0.3, "quadOut", "elasticOut") + env(c, 6.1, 0.06, 0.04, 0.3, "quadOut", "elasticOut")
	S.earR = 25 * flick

	-- tail: lazy wag, big swish beat, lifts while reared
	S.tailP = -8 - 20 * rear + 10 * impact + 3 * br
	S.tailY = 10 * wave(t, 0.75) + 45 * swish * wave(t, 3)
	S.tailY2 = 12 * wave(t, 0.75, -0.12) + 30 * swish * wave(t, 3, -0.1)
	S.tuftY = 18 * wave(t, 0.75, -0.25) + 30 * swish * wave(t, 3, -0.2)
	S.sprig = 10 * wave(t, 1, 0.1) + 30 * shake * wave(t, 5, 0.4) - 25 * impact
	S.sprig2 = 8 * wave(t, 0.75) + 20 * shake * wave(t, 5, 0.6)
	solve(pose, ctx, S)

	-- props + FX
	angerMark(pose, ctx, t, (c > 8.3 and c < 9.6) and 1 or 0)
	slamFX(pose, ctx, c - IMPACT_I)
	orbs(t, pose, 2.4 * impact, 1.0 * rear)

	if ctx.crossed(0.76) then ctx.emit("Steam", 10) end
	if ctx.crossed(0.99) then ctx.emit("Steam", 7) end
	if ctx.crossed(2.2) then ctx.emit("DustFront", 6) end
	if ctx.crossed(2.62) then ctx.emit("DustFront", 6) end
	if ctx.crossed(5.6) then ctx.emit("Leaves", 8) end
	if ctx.crossed(5.9) then ctx.emit("Twinkle", 6) end
	if ctx.crossed(8.5) then ctx.emit("Steam", 18) end
	if ctx.crossed(IMPACT_I) then
		ctx.emit("DustFront", 30)
		ctx.emit("SlamCubes", 18)
		ctx.emit("Leaves", 10)
	end
	if ctx.crossed(9.95) then ctx.emit("Steam", 8) end
	if ctx.crossed(10.15) then ctx.emit("Steam", 8) end
	ctx.light("HornLight", min(1.8, 0.5 + 0.6 * roar))
end

------------------------------------------------------------------------
-- ALERT (2.0 s): MY PLANT GOT STOLEN!
------------------------------------------------------------------------
local function alert(t, pose, ctx)
	local S = {}
	local jolt = env(t, 0.0, 0.08, 0.06, 0.2, "backOut", "quadIn")
	local inhale = env(t, 0.15, 0.35, 0.05, 0.12, "cubicOut", "quadIn")
	local blast = env(t, 0.55, 0.08, 0.35, 0.3, "backOut", "cubicInOut")
	local scrape = env(t, 0.95, 0.15, 0.55, 0.2)
	local lower = env(t, 1.45, 0.25, 0.2, 0.15, "backOut", "quadInOut")
	local rumble = (blast + scrape) * wave(t, 14)

	local pz = L.track(t, { { 0.95, 0 }, { 1.08, -1.2, "quadOut" }, { 1.22, 1.1, "quadIn" }, { 1.36, -1.1, "quadOut" }, { 1.5, 1.1, "quadIn" }, { 1.68, 0, "quadInOut" } })
	local py = L.track(t, { { 0.95, 0 }, { 1.08, 1.4, "quadOut" }, { 1.21, 0.05, "quadIn" }, { 1.35, 1.2, "quadOut" }, { 1.49, 0.05, "quadIn" }, { 1.68, 0 } })

	S.hy = 0.9 * jolt + 0.4 * inhale - 0.9 * blast - 0.5 * lower + 0.08 * rumble
	S.hz = 0.8 * inhale - 0.7 * blast + 0.3 * scrape
	S.hp = 6 * jolt + 6 * inhale - 6 * blast - 3 * lower
	S.hroll = 1.5 * rumble - 2 * scrape
	S.cp = 5 * jolt + 9 * inhale - 6 * blast
	S.croll = 1.2 * rumble
	S.FR = { py, pz, -25 * py / 1.4 }

	S.np = 10 * jolt + 10 * inhale - 6 * blast - 5 * scrape - 4 * lower
	S.dp = 18 * jolt + 22 * inhale - 10 * blast - 8 * scrape - 12 * lower
	S.dyaw = 6 * blast * wave(t, 7)
	S.droll = 6 * blast * wave(t, 6) + 3 * rumble
	S.jaw = -8 * jolt - 62 * blast + 8 * inhale
	S.lid = max(0.5 * scrape + 0.4 * lower, 0.25 * blast)
	S.earP = 30 * jolt + 10 * inhale - 40 * blast - 30 * scrape - 30 * lower
	S.earZ = 40 * jolt - 20 * blast + 25 * blast * wave(t, 9)
	S.tailP = -10 - 45 * max(jolt, blast, scrape) - 20 * lower
	S.tailY = 20 * blast * wave(t, 9)
	S.tuftY = 30 * blast * wave(t, 9, -0.2)
	S.tuftZ = 20 * jolt
	S.sprig = 25 * jolt * wave(t, 8) + 25 * blast * wave(t, 9)
	S.sprig2 = 20 * jolt
	solve(pose, ctx, S)

	angerMark(pose, ctx, t, (t > 0.08 and t < 1.9) and 1 or 0)
	orbs(t, pose, 1.6 * blast, 0.8 * jolt)
	slamFX(pose, ctx, -1)
	if ctx.crossed(0.04) then ctx.emit("Twinkle", 8) end
	if ctx.crossed(0.57) then
		ctx.emit("Steam", 30)
		ctx.emit("HornBurst", 14)
	end
	if ctx.crossed(0.7) then ctx.emit("HeadSteam", 12) end
	if ctx.crossed(0.8) then ctx.emit("Steam", 14) end
	if ctx.crossed(1.21) then ctx.emit("DustFront", 10) end
	if ctx.crossed(1.49) then ctx.emit("DustFront", 10) end
	if ctx.crossed(1.75) then ctx.emit("Steam", 8) end
	ctx.light("HornLight", min(1.8, 0.5 + 1.2 * blast))
end

------------------------------------------------------------------------
-- CHASE (0.6 s loop): thundering rotary gallop
------------------------------------------------------------------------
local CH_LEN, CH_SPEED, CH_DUTY = 0.6, 16, 0.42
local CH_SWEEP = CH_SPEED * CH_DUTY * CH_LEN -- hoof travel during stance (no skating)
local CH_PHASE = { FR = 0.5, FL = 0.6, HR = 0.0, HL = 0.1 }
local function chase(t, pose, ctx)
	local S = {}
	local u = (t / CH_LEN) % 1
	for k, ph in CH_PHASE do
		local front = k == "FR" or k == "FL"
		local dy, dz, pitch = gait((u - ph) % 1, CH_DUTY, CH_SWEEP, front and 2.2 or 1.8)
		S[k] = { dy, dz + (front and -0.6 or 0.4), pitch }
	end
	-- body: two heavy bumps per stride (hind push, front landing)
	local f = 1 / CH_LEN
	local bump = wave(t, 2 * f, -0.27) -- high at each pair's mid-stance
	local pitchW = wave(t, f, -0.05) -- nose up on the hind push, down on the front landing
	S.hy = -0.15 + 0.55 * bump
	S.hz = -0.2
	S.hp = -3 + 7 * pitchW
	S.hroll = 2.5 * wave(t, f, 0.3)
	S.hyaw = 2 * wave(t, f)
	S.cp = 3 * wave(t, f, -0.15)
	S.np = -8 - 3 * pitchW
	S.dp = -16 - 5 * wave(t, f, -0.12)
	S.droll = 3 * wave(t, f, 0.2)
	S.jaw = -14 - 8 * max(0, wave(t, f, 0.5))
	S.lid = 0.42
	S.earP = -45
	S.earZ = -10 + 6 * wave(t, 2 * f)
	S.tailP = -55 + 6 * wave(t, 2 * f)
	S.tailY = 14 * wave(t, f, 0.1)
	S.tailP2 = -60
	S.tuftY = 25 * wave(t, f, -0.1)
	S.sprig = -20 + 15 * wave(t, 2 * f, 0.2)
	S.sprig2 = 10 * wave(t, f)
	solve(pose, ctx, S)

	angerMark(pose, ctx, t, 1)
	orbs(t, pose, 0.6, 0.3 * bump)
	slamFX(pose, ctx, -1)
	for k, ph in CH_PHASE do
		if ctx.crossed(ph * CH_LEN + 0.001) then
			ctx.emit((k == "FR" or k == "FL") and "DustFront" or "DustBack", 5)
		end
	end
	if ctx.crossed(0.05) then ctx.emit("Steam", 4) end
end

------------------------------------------------------------------------
-- ATTACK (1.1 s): horn uppercut toss
------------------------------------------------------------------------
local function attack(t, pose, ctx)
	local S = {}
	local wind = env(t, 0.0, 0.33, 0.04, 0.12, "cubicOut", "quadIn")
	local hit = env(t, 0.37, 0.12, 0.25, 0.36, "backOut", "cubicInOut")
	local toss = env(t, 0.45, 0.1, 0.12, 0.3)
	S.hy = -0.7 * wind - 0.3 * hit
	S.hz = 1.0 * wind - 1.5 * hit
	S.hp = -4 * wind + 9 * hit
	S.cp = -4 * wind + 8 * hit
	S.FR = { 0.6 * hit, -0.4 * hit, 0 }
	S.np = -12 * wind + 12 * hit
	S.nyaw = 6 * wind
	S.dp = -30 * wind + 30 * hit
	S.dyaw = 8 * wind - 6 * hit + 12 * toss * wave(t, 6)
	S.droll = -12 * wind + 18 * hit
	S.jaw = 4 * wind - 40 * hit
	S.lid = 0.6 * wind + 0.2 * hit
	S.earP = -40 * wind + 25 * hit
	S.earZ = -15 * wind + 25 * hit
	S.tailP = -15 - 25 * hit
	S.tailY = 25 * hit * wave(t, 5)
	S.tuftY = 30 * hit * wave(t, 5, -0.2)
	S.sprig = -20 * wind + 30 * hit * wave(t, 7)
	solve(pose, ctx, S)

	angerMark(pose, ctx, t, t < 0.9 and 1 or 0)
	orbs(t, pose, 1.4 * hit, 0)
	slamFX(pose, ctx, -1)
	if ctx.crossed(0.1) then ctx.emit("Steam", 8) end
	if ctx.crossed(0.4) then ctx.emit("DustFront", 12) end
	if ctx.crossed(0.47) then
		ctx.emit("HornBurst", 26)
		ctx.emit("Twinkle", 6)
	end
	ctx.light("HornLight", min(1.8, 0.5 + 1.3 * hit))
end

------------------------------------------------------------------------
-- CATCH (2.2 s): triumphant rear + stomp + snort
------------------------------------------------------------------------
local IMPACT_C = 1.25
local function catch(t, pose, ctx)
	local S = {}
	local crouch = env(t, 0.0, 0.28, 0.02, 0.12, "cubicOut", "quadIn")
	local rear = env(t, 0.3, 0.32, 0.5, 0.13, "backOut", "quadIn")
	local roar = env(t, 0.45, 0.12, 0.45, 0.15, "backOut", "quadIn")
	local impact = env(t, IMPACT_C, 0.04, 0.05, 0.6, "quadOut", "elasticOut")
	local smug = env(t, 1.45, 0.2, 0.35, 0.3, "backOut", "quadInOut")
	local snort = env(t, 1.6, 0.05, 0.05, 0.2) + env(t, 1.78, 0.05, 0.05, 0.2)
	S.hy = -0.7 * crouch - 1.3 * impact
	S.hz = 0.6 * crouch - 0.4 * rear
	S.hp = -4 * crouch + 42 * rear - 3 * impact
	S.cp = 10 * rear - 5 * impact
	local airW = L.smoothstep(clamp((rear - 0.15) / 0.45, 0, 1))
	local pad = wave(t, 3.5)
	S.airR = { airW, -25 + 40 * pad, 50 + 25 * pad, -20 }
	S.airL = { airW, -25 - 40 * pad, 50 - 25 * pad, -20 }
	S.np = -6 * crouch - 6 * rear + 6 * impact + 4 * smug
	S.dp = -8 * crouch + 26 * roar - 12 * impact + 16 * smug - 8 * snort
	S.dyaw = 6 * roar * wave(t, 5) - 18 * smug
	S.droll = 14 * smug
	S.jaw = -66 * roar - 12 * impact - 6 * snort
	S.lid = 0.4 * crouch + 0.55 * smug
	S.earP = -25 * crouch + 30 * roar - 10 * smug
	S.earZ = 25 * roar + 20 * smug * wave(t, 4)
	S.tailP = -10 - 25 * rear + 12 * impact
	S.tailY = 35 * smug * wave(t, 3)
	S.tuftY = 40 * smug * wave(t, 3, -0.2)
	S.sprig = 25 * rear * wave(t, 4) - 25 * impact
	solve(pose, ctx, S)

	angerMark(pose, ctx, t, 0)
	slamFX(pose, ctx, t - IMPACT_C)
	orbs(t, pose, 2.4 * impact, rear)
	if ctx.crossed(0.55) then ctx.emit("Steam", 18) end
	if ctx.crossed(IMPACT_C) then
		ctx.emit("DustFront", 30)
		ctx.emit("SlamCubes", 18)
		ctx.emit("Leaves", 8)
	end
	if ctx.crossed(1.62) then ctx.emit("Steam", 10) end
	if ctx.crossed(1.8) then ctx.emit("Steam", 10) end
	if ctx.crossed(1.65) then ctx.emit("Twinkle", 8) end
	ctx.light("HornLight", min(1.8, 0.5 + 0.8 * roar))
end

------------------------------------------------------------------------
-- GIVEUP (2.6 s): skid, steam from the head, tantrum stomps, huff
------------------------------------------------------------------------
local function giveUp(t, pose, ctx)
	local S = {}
	local skid = env(t, 0.0, 0.08, 0.3, 0.25, "quadOut", "quadInOut")
	local seethe = env(t, 0.4, 0.15, 0.45, 0.2)
	local stompR = env(t, 0.95, 0.12, 0.02, 0.08, "quadOut", "quadIn") + env(t, 1.55, 0.12, 0.02, 0.08, "quadOut", "quadIn")
	local stompL = env(t, 1.25, 0.12, 0.02, 0.08, "quadOut", "quadIn")
	local tantrum = env(t, 0.9, 0.1, 0.85, 0.2)
	local huff = env(t, 1.9, 0.12, 0.15, 0.4, "quadOut", "quadInOut")
	local droop = env(t, 2.0, 0.2, 0.15, 0.3)
	local thud = env(t, 1.07, 0.03, 0.03, 0.2) + env(t, 1.37, 0.03, 0.03, 0.2) + env(t, 1.67, 0.03, 0.03, 0.2)
	local rumble = seethe * wave(t, 13)

	S.hy = -0.6 * skid - 0.5 * thud + 0.1 * rumble - 0.3 * huff
	S.hz = -0.3 * skid
	S.hp = 9 * skid - 2 * thud
	S.hroll = 2 * rumble + 4 * (stompR - stompL)
	S.cp = 4 * skid + 5 * huff
	S.FR = { 2.6 * stompR, -1.8 * skid - 0.6 * stompR, -25 * stompR }
	S.FL = { 2.6 * stompL, -1.8 * skid - 0.6 * stompL, -25 * stompL }
	S.HR = { 0, 0.5 * skid, 0 }
	S.HL = { 0, 0.5 * skid, 0 }
	S.np = 8 * skid + 6 * seethe - 6 * thud - 6 * droop
	S.dp = 6 * skid + 12 * seethe - 10 * thud + 10 * huff - 14 * droop
	S.dyaw = 10 * tantrum * wave(t, 3.3)
	S.droll = 8 * tantrum * wave(t, 3.3, 0.25) + 3 * rumble
	S.jaw = -20 * seethe - 30 * thud - 25 * huff
	S.lid = 0.55 * seethe + 0.4 * tantrum + 0.6 * droop
	S.earP = -35 * seethe - 30 * tantrum + 20 * huff - 30 * droop
	S.earZ = -25 * droop + 15 * tantrum * wave(t, 6)
	S.tailP = -10 - 20 * seethe + 10 * droop
	S.tailY = 30 * tantrum * wave(t, 3.3)
	S.tuftY = 35 * tantrum * wave(t, 3.3, -0.2)
	S.sprig = 25 * thud - 10 * droop
	solve(pose, ctx, S)

	angerMark(pose, ctx, t, (t > 0.4 and t < 1.95) and 1 or 0)
	orbs(t, pose, 0.6 * tantrum, -0.6 * droop)
	slamFX(pose, ctx, -1)
	for _, k in { 0.04, 0.14, 0.24, 0.34 } do
		if ctx.crossed(k) then ctx.emit("DustFront", 7) end
	end
	for _, k in { 0.5, 0.66, 0.82 } do
		if ctx.crossed(k) then ctx.emit("HeadSteam", 9) end
	end
	for _, k in { 1.07, 1.37, 1.67 } do
		if ctx.crossed(k) then ctx.emit("DustFront", 10) end
	end
	if ctx.crossed(1.95) then ctx.emit("Steam", 20) end
end

------------------------------------------------------------------------
-- RETURN (1.2 s loop): heavy grumpy stomp-walk
------------------------------------------------------------------------
local RT_LEN, RT_SPEED, RT_DUTY = 1.2, 4.5, 0.72
local RT_SWEEP = RT_SPEED * RT_DUTY * RT_LEN
local RT_PHASE = { HL = 0.0, FL = 0.25, HR = 0.5, FR = 0.75 }
local function walkBack(t, pose, ctx)
	local S = {}
	local u = (t / RT_LEN) % 1
	for k, ph in RT_PHASE do
		local dy, dz, pitch = gait((u - ph) % 1, RT_DUTY, RT_SWEEP, 1.3)
		S[k] = { dy, dz, pitch * 0.7 }
	end
	local f = 1 / RT_LEN
	S.hy = -0.25 + 0.2 * wave(t, 2 * f, 0.15)
	S.hroll = 3 * wave(t, f, 0.1)
	S.hyaw = 3 * wave(t, f, 0.35)
	S.hp = -1
	S.croll = -2 * wave(t, f, 0.2)
	S.np = -6
	S.dp = -6 + 4 * wave(t, 2 * f, 0.3)
	S.dyaw = 6 * wave(t, f, 0.4)
	S.droll = -4 * wave(t, f, 0.25)
	S.jaw = -3 * max(0, wave(t, 2 * f))
	S.lid = 0.5
	S.earP = -15
	S.earZ = -8 + 6 * wave(t, 2 * f, 0.2)
	S.tailP = -6
	S.tailY = 18 * wave(t, f, 0.1)
	S.tailY2 = 12 * wave(t, f, -0.05)
	S.tuftY = 22 * wave(t, f, -0.2)
	S.sprig = 10 * wave(t, 2 * f, 0.3)
	S.sprig2 = 8 * wave(t, f)
	solve(pose, ctx, S)

	angerMark(pose, ctx, t, 0)
	orbs(t, pose, 0, 0)
	slamFX(pose, ctx, -1)
	if ctx.crossed(RT_PHASE.FL * RT_LEN + 0.001) or ctx.crossed(RT_PHASE.FR * RT_LEN + 0.001) then
		ctx.emit("DustFront", 3)
	end
	if ctx.crossed(0.6) then ctx.emit("Steam", 3) end
end

M.States = {
	Idle = { Loop = true, Length = IDLE_LEN, Update = idle },
	Alert = { Length = 2.0, Update = alert },
	Chase = { Loop = true, Length = CH_LEN, Speed = CH_SPEED, Update = chase },
	Attack = { Length = 1.1, Update = attack },
	Catch = { Length = 2.2, Update = catch },
	GiveUp = { Length = 2.6, Update = giveUp },
	Return = { Loop = true, Length = RT_LEN, Speed = RT_SPEED, Update = walkBack },
}
M.Base = "Idle"
M.Reel = { { "Idle" }, { "Alert" }, { "Chase", 3.6 }, { "Attack" }, { "Catch" }, { "Chase", 1.8 }, { "GiveUp" }, { "Return", 3.6 } }
return L.states(M)
