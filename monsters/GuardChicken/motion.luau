--!nocheck
-- Coop Guard Chicken motion: an overconfident, jittery, dramatic little guard.
-- Guardian gameplay states (see docs/AUTHORING.md "Guardians"):
--   Idle   (12 s loop) suspicious head-bob march + look-arounds, PECK PECK the
--          ground, SCRATCH the dirt (dust + leaf bits), eyes DART left-right,
--          chest puff + stiff SALUTE (badge gleams), then the show-off: crouch ->
--          big wing-flapping HOP -> CROW mid-air -> squash landing, helmet clank.
--   Alert  (1.8 s) FREEZE (eyes pop, tiny pupils, "!") -> crouch -> feathers
--          EXPLODE, jumps screaming beak-wide, helmet flies off its head ->
--          lands, anger mark, steam, leans into a run.
--   Chase  (0.4 s loop) cartoon wheel-legs (feet plant, no skating), body
--          leaning hard, head locked forward, wings flapping, dust per footfall.
--   Attack (1.0 s) rear back -> PECK PECK PECK lunge flurry with sparks.
--   Catch  (2.0 s) tiptoe victory CROW with wings spread, eyes squeezed, smug nod.
--   GiveUp (2.6 s) slumps, flops on its back kicking + flapping in a tantrum,
--          hops up, stomps and huffs steam.
--   Return (1.2 s loop) proud chest-out high-knee strut with chicken head-bob.
-- Legs use a 2-bone IK so planted feet never slide or sink into the ground.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease

local sqrt, max, min, abs, clamp = math.sqrt, math.max, math.min, math.abs, math.clamp
local atan2, acos, sin, cos, pi, floor = math.atan2, math.acos, math.sin, math.cos, math.pi, math.floor
local IDENT = CFrame.new()

------------------------------------------------------------------------
-- Leg IK (rest pivots in model space, right side; left is mirrored)
------------------------------------------------------------------------
local HIP = Vector3.new(0, 2.2, 0.3)
local THIGH = Vector3.new(0.75, 1.9, 0.2)
local SHIN = Vector3.new(0.75, 1.15, 0.5)
local FOOT = Vector3.new(0.75, 0.3, 0.2)
local SEG1, SEG2 = SHIN - THIGH, FOOT - SHIN
local L1 = sqrt(SEG1.Y ^ 2 + SEG1.Z ^ 2)
local L2 = sqrt(SEG2.Y ^ 2 + SEG2.Z ^ 2)
local A1 = atan2(SEG1.Z, SEG1.Y)
local A2 = atan2(SEG2.Z, SEG2.Y)
local REST_X = FOOT.X - THIGH.X
local REST_DOWN = THIGH.Y - FOOT.Y
local REACH = (L1 + L2) * 0.97

local function wrap(a)
	return (a + pi) % (2 * pi) - pi
end
local KNEE = wrap(A2 - A1) >= 0 and 1 or -1 -- chicken "knee" (hock) bends backward

local function sideV(p, s)
	return Vector3.new(p.X * s, p.Y, p.Z)
end

local function reachDrop(hipsW, s, target)
	local th = (hipsW * CFrame.new(sideV(THIGH, s) - HIP)).Position
	local d = target - th
	local h2 = d.X ^ 2 + d.Z ^ 2
	local maxDown = sqrt(max(0, REACH * REACH + REST_X * REST_X - h2))
	return max(0, -d.Y - maxDown)
end

local function legIK(hipsW, s, target, footRot)
	local frame = hipsW * CFrame.new(sideV(THIGH, s) - HIP)
	local q = frame:PointToObjectSpace(target)
	local gamma = atan2(q.X, -q.Y) - atan2(REST_X * s, REST_DOWN)
	local rz = CFrame.Angles(0, 0, gamma)
	local q2 = rz:PointToObjectSpace(q)
	local D = clamp(sqrt(q2.Y ^ 2 + q2.Z ^ 2), abs(L1 - L2) + 0.05, L1 + L2 - 1e-4)
	local delta = KNEE * acos(clamp((D * D - L1 * L1 - L2 * L2) / (2 * L1 * L2), -1, 1))
	local phi = atan2(q2.Z, q2.Y)
	local s1 = phi - atan2(L2 * sin(delta), L1 + L2 * cos(delta))
	local th1 = wrap(s1 - A1)
	local th2 = wrap(delta - (A2 - A1))
	local thighT = rz * CFrame.Angles(th1, 0, 0)
	local shinT = CFrame.Angles(th2, 0, 0)
	local footT = (hipsW.Rotation * thighT * shinT):Inverse() * footRot
	return thighT, shinT, footT
end

local function bodyCF(b)
	return CFrame.new(HIP) * pa(b.x, b.y, b.z, b.p, b.yaw, b.r)
end

-- planted foot target (model space) with a lift / forward offset
local function planted(s, lift, fwd, side)
	return sideV(FOOT, s) + Vector3.new((side or 0) * s, lift or 0, -(fwd or 0))
end

-- body params b = {x,y,z,p,yaw,r}; fR/fL = foot targets; rR/rL = foot world rotations
local function rig(pose, b, fR, fL, rR, rL)
	local hw = bodyCF(b)
	local drop = max(reachDrop(hw, 1, fR), reachDrop(hw, -1, fL))
	if drop > 0 then
		b.y -= drop
		hw = bodyCF(b)
	end
	pose.Body = pa(b.x, b.y, b.z, b.p, b.yaw, b.r)
	local tR, sR, ftR = legIK(hw, 1, fR, rR or IDENT)
	local tL, sL, ftL = legIK(hw, -1, fL, rL or IDENT)
	pose.ThighR, pose.ShinR, pose.FootR = tR, sR, ftR
	pose.ThighL, pose.ShinL, pose.FootL = tL, sL, ftL
	return hw
end

-- run / walk foot cycle: phase p in [0,1), stance first (front -> back)
local function stride(p, duty, S, H, z0)
	if p < duty then
		local u = p / duty
		return 0, z0 - S / 2 + S * u, 0, u
	end
	local u = (p - duty) / (1 - duty)
	local lift = H * sin(pi * u) ^ 0.8
	return lift, z0 + S / 2 - S * E.sineInOut(u), 1, u
end

------------------------------------------------------------------------
-- Face: eyes pop, pupils dart, brows, blinks, shocked dot-pupils
------------------------------------------------------------------------
-- f = { pop, lx, ly, browY, browR (deg, + = angrier), browYL, browRL, blink, shock }
local function face(pose, ctx, f)
	L.both(pose, "Eye", CFrame.new(0, 0, -(f.pop or 0)))
	local lx, ly = f.lx or 0, f.ly or 0
	L.both(pose, "Pupil", CFrame.new(lx, ly, 0), CFrame.new(-lx, ly, 0))
	local by, br = f.browY or 0, f.browR or 0
	L.both(pose, "Brow", pa(0, by, 0, 0, 0, br), pa(0, f.browYL or by, 0, 0, 0, f.browRL or br))
	ctx.light("BadgeLight", 0) -- states that want the badge gleam set it after face()
	local closed = (f.blink or 0) > 0.35
	local lt = closed and 0 or 1
	ctx.transparency("EyelidR", lt)
	ctx.transparency("EyelidL", lt)
	ctx.transparency("LashR", lt)
	ctx.transparency("LashL", lt)
	if f.shock then
		for _, s in { "R", "L" } do
			ctx.transparency("PupilDisc" .. s, 1)
			ctx.transparency("Glint" .. s, 1)
			ctx.transparency("Dot" .. s, 0)
		end
	end
end

local function blinkAt(c, list)
	local b = 0
	for _, s in list do
		b = max(b, L.env(c, s, 0.04, 0.06, 0.05))
	end
	return b
end

local function showAnger(ctx, on)
	if on then
		for k = 1, 8 do
			ctx.transparency("Anger" .. k, 0)
		end
	end
end

-- floating garden cubes: bob + tumble around their spots (hz must suit the loop)
local SPOTS = { { 2.9, 1.2 }, { -3.1, 1.6 }, { 2.8, 2.8 } }
local function orbs(pose, t, hz, fling, sink)
	for i = 1, 3 do
		local dir = i % 2 == 0 and -1 or 1
		local sp = SPOTS[i]
		local len = sqrt(sp[1] ^ 2 + sp[2] ^ 2)
		local out = 1.4 * (fling or 0)
		local bob = 0.35 * wave(t, hz, i * 0.3) + 1.0 * (fling or 0) - 0.4 * (sink or 0)
		pose["Orb" .. i] = pa(out * sp[1] / len, bob, out * sp[2] / len, 360 * hz * t * dir, 720 * hz * t, 20)
	end
end

------------------------------------------------------------------------
-- IDLE (12 s): guarding the plant
------------------------------------------------------------------------
local IL = 12
local function ihz(n) return n / IL end
local LOOK = {
	{ 0.0, 0 }, { 0.5, 0 }, { 0.6, -32, "backOut" }, { 1.3, -32 }, { 1.4, 30, "backOut" }, { 2.05, 30 },
	{ 2.15, 0, "backOut" }, { 10.9, 0 }, { 11.0, 28, "backOut" }, { 11.55, 28 }, { 11.65, 0, "backOut" }, { 12, 0 },
}
local DART = {
	{ 5.2, 0 }, { 5.35, -0.2, "expoOut" }, { 5.7, -0.2 }, { 5.76, 0.2, "expoOut" }, { 6.0, 0.2 },
	{ 6.05, -0.2, "expoOut" }, { 6.2, -0.2 }, { 6.25, 0.2, "expoOut" }, { 6.45, 0.2 }, { 6.6, 0, "quadOut" },
}
local PECKS = { 2.75, 3.3 }
local SCR = { { 3.95, 1 }, { 4.35, 1 }, { 4.8, -1 } }
local IBLINK = { 1.1, 4.6, 10.25, 11.8 }
local LAUNCH, ILAND = 8.85, 9.7

-- one dirt scratch: lift forward, then drag back hard, then return
local SCRK = { { 0, 0 }, { 0.1, 1, "quadOut" }, { 0.2, 2, "quadIn" }, { 0.36, 3, "sineInOut" } }
local function scratch(c, t0)
	local u = c - t0
	if u < 0 or u > 0.36 then
		return 0, 0
	end
	local k = L.track(u, SCRK)
	if k < 1 then
		return 0.35 * k, 0.35 * k
	elseif k < 2 then
		local a = k - 1
		return 0.35 - 0.3 * a, 0.35 - 1.1 * a
	end
	local a = k - 2
	return 0.05 + 0.15 * sin(pi * a), -0.75 * (1 - a)
end

local function idle(t, pose, ctx)
	local c = t % IL

	local peck = L.env(c, 2.4, 0.25, 0.85, 0.3)
	local scr = L.env(c, 3.75, 0.2, 1.25, 0.25)
	local dart = L.env(c, 5.15, 0.15, 1.35, 0.25)
	local puff = L.env(c, 6.8, 0.3, 1.05, 0.3, "backOut", "cubicInOut")
	local salute = L.env(c, 6.95, 0.18, 0.95, 0.3, "backOut", "quadInOut")
	local show = L.env(c, 8.4, 0.15, 1.95, 0.4)
	local march = clamp(1 - max(peck, scr, dart, puff, show), 0, 1)

	-- show-off envelopes
	local crouch = L.env(c, 8.45, 0.4, 0.0, 0.12, "cubicOut", "quadIn")
	local hop = L.env(c, LAUNCH, 0.38, 0.04, 0.43, "quadOut", "quadIn")
	local flap = L.env(c, LAUNCH - 0.05, 0.1, 0.75, 0.2)
	local crow = L.env(c, 9.12, 0.12, 0.5, 0.25, "backOut", "quadIn")
	local land = L.env(c, ILAND, 0.04, 0.03, 0.5, "linear", "elasticOut")
	local proud = L.env(c, 9.8, 0.2, 0.6, 0.4)

	-- march in place: 1 Hz steps, chicken head thrust twice a second
	local step = wave(t, ihz(12))
	local liftR = 0.5 * max(0, step) ^ 1.5 * march
	local liftL = 0.5 * max(0, -step) ^ 1.5 * march
	local hb = L.saw(t, ihz(24))
	local thrust = (hb < 0.25 and E.quadOut(hb / 0.25) or 1 - E.sineInOut((hb - 0.25) / 0.75)) * march

	-- pecks
	local dip = 0
	for _, p in PECKS do
		dip = max(dip, L.env(c, p, 0.1, 0.04, 0.2, "quadIn", "quadOut"))
	end
	local clack = 0
	for _, p in PECKS do
		clack = max(clack, L.env(c, p - 0.06, 0.08, 0.02, 0.06))
	end

	-- scratches
	local sLiftR, sZR, sLiftL, sZL = 0, 0, 0, 0
	for _, s in SCR do
		local ly, lz = scratch(c, s[1])
		if s[2] > 0 then
			sLiftR, sZR = max(sLiftR, ly), sZR + lz
		else
			sLiftL, sZL = max(sLiftL, ly), sZL + lz
		end
	end

	-- body
	local breathe = wave(t, ihz(6))
	local tremble = 0.6 * wave(t, 14) * salute
	local b = {
		x = 0.12 * step * march + 0.1 * (sLiftL - sLiftR),
		y = -0.08 * (1 - abs(step)) * march - 0.12 * peck - 0.25 * dip - 0.12 * scr - 0.08 * dart + 0.15 * puff
			- 0.5 * crouch + 1.5 * hop - 0.45 * land + 0.03 * breathe,
		z = -0.1 * dip,
		p = 2 * breathe * march - 8 * peck - 26 * dip - 12 * scr - 5 * dart + 12 * puff - 12 * crouch + 14 * hop
			- 10 * land + 8 * proud + 3 * crow,
		yaw = 7 * step * march + 10 * (sLiftL - sLiftR) * scr,
		r = -5 * step * march + 2 * tremble,
	}
	local tuck = hop * 0.95
	-- planted(s, lift, fwd) moves the foot toward -Z by fwd; scratch z is +back
	local fR = planted(1, liftR + sLiftR + tuck, 0.12 * liftR - sZR)
	local fL = planted(-1, liftL + sLiftL + tuck, 0.12 * liftL - sZL)
	rig(pose, b, fR, fL, ang(-25 * liftR - 30 * sLiftR - 30 * hop, 0, 0), ang(-25 * liftL - 30 * sLiftL - 30 * hop, 0, 0))

	-- neck + head
	local look = L.track(c, LOOK)
	local dartX = L.track(c, DART)
	local headYawDart = 0
	if dart > 0 then
		headYawDart = -55 * L.track(c - 0.05, DART)
	end
	pose.Neck = pa(0, -0.05 * dart, -0.25 * thrust - 0.15 * dip,
		-6 * thrust - 8 * dip - 6 * peck - 8 * dart - 10 * puff + 8 * crow - 10 * crouch + 8 * land,
		0.4 * look, 0)
	pose.Head = pa(0, 0.05 * thrust, -0.15 * thrust,
		4 * thrust - 4 * dip - 4 * peck - 18 * scr + 10 * puff + 6 * salute + 20 * crow - 12 * land + 2 * breathe
			+ 6 * wave(t, 18) * crow,
		0.6 * look + headYawDart * dart + 8 * wave(t, ihz(36)) * scr,
		4 * wave(t, ihz(12), 0.2) * march + 6 * dart * wave(t, ihz(48)) * 0.3)

	-- beak
	local chirp = max(0, wave(t, ihz(5), 0.3)) ^ 12 * march
	pose.Jaw = ang(-22 * chirp - 35 * clack - 72 * crow - 6 * crow * wave(t, 16) - 18 * land, 0, 0)

	-- comb / helmet secondary
	pose.Comb = ang(5 * wave(t, ihz(24), -0.2) * march + 14 * dip - 22 * crow + 16 * land * wave(t, 6), 0,
		6 * wave(t, ihz(12), -0.15) * march + 8 * tremble)
	local clank = L.env(c, ILAND, 0.06, 0.02, 0.6, "quadOut", "elasticOut")
	pose.Helmet = pa(0, 0.35 * clank + 0.12 * hop, 0, -12 * clank + 4 * dip, 0, 10 * clank + 1.5 * tremble)

	-- wings: idle fidget, tucked on the pecks, salute (right), flaps on the hop
	local fid = 8 * L.wave01(t, ihz(12)) * march
	local fl = flap * (0.5 + 0.5 * wave(t, 6))
	local wingZ = 6 + fid + 12 * scr + 10 * puff + 55 * fl - 10 * crouch + 25 * proud + 10 * land
	local wingX = -10 * crouch - 5 * fl
	local salR = ang(0, 20 * salute, 0) * ang(0, 0, -5 * salute) * ang(185 * salute, 0, 0) * ang(0, 0, wingZ * (1 - salute)) * ang(0, 75 * flap, 0)
	local wR = ang(wingX, 0, 0) * salR
	local wL = ang(wingX, 0, 0) * ang(0, 0, wingZ + 4 * puff) * ang(0, 75 * flap, 0)
	L.both(pose, "Wing", wR, wL)
	local tipLag = 25 * flap * wave(t, 6, -0.15)
	L.both(pose, "WingTip", ang(-25 * salute, 0, tipLag), ang(0, 0, tipLag))

	-- tail
	pose.Tail = ang(-6 * puff + 8 * crouch - 10 * hop + 6 * land, 10 * wave(t, ihz(12), -0.1) * march + 18 * wave(t, 5) * scr, 0)
	pose.TailTip = ang(4 * wave(t, ihz(24), -0.3) - 15 * crow + 14 * land, 12 * wave(t, ihz(12), -0.3) * march, 0)

	-- face
	local blink = blinkAt(c, IBLINK)
	local proudEyes = L.env(c, 7.25, 0.06, 0.6, 0.08) -- smug eyes-shut during the salute hold
	local squint = 0.6 * march + 0.4 * dart
	-- one brow cocked up while looking around (suspicious)
	local cock = clamp(abs(look) / 30, 0, 1) * march
	face(pose, ctx, {
		pop = 0.12 * crow + 0.05 * dart,
		lx = (look / 32) * 0.12 + dartX + (sLiftR > 0 and 0.08 or 0) * scr, ly = -0.1 * peck - 0.12 * scr,
		browY = -0.06 * squint + 0.12 * crow + 0.06 * cock, browR = 6 * squint + 6 * dart - 12 * crow,
		browYL = -0.06 * squint + 0.12 * crow - 0.04 * cock, browRL = 6 * squint + 6 * dart - 12 * crow + 10 * cock,
		blink = max(blink, proudEyes, 0.0),
	})

	orbs(pose, t, ihz(5), 0.8 * hop, 0.5 * land)

	-- effects
	for _, p in PECKS do
		if ctx.crossed(p + 0.1) then
			ctx.emit("StepDust", 4)
			ctx.emit("LeafKick", 3)
		end
	end
	for _, s in SCR do
		if ctx.crossed(s[1] + 0.14) then
			ctx.emit("StepDust", 5)
			ctx.emit("LeafKick", 6)
		end
	end
	if ctx.crossed(7.12) then
		ctx.emit("AuraSparkle", 8)
	end
	ctx.light("BadgeLight", 1.2 * L.env(c, 7.05, 0.1, 0.5, 0.4))
	if ctx.crossed(LAUNCH + 0.02) then
		ctx.emit("StepDust", 8)
		ctx.emit("FeatherBurst", 8)
	end
	if ctx.crossed(9.18) then
		ctx.emit("CrowBurst", 16)
	end
	if ctx.crossed(9.45) then
		ctx.emit("CrowBurst", 8)
	end
	if ctx.crossed(ILAND) then
		ctx.emit("StepDust", 12)
	end
end

------------------------------------------------------------------------
-- ALERT (1.8 s): MY PLANT GOT STOLEN!
------------------------------------------------------------------------
local AJUMP, ALAND = 0.45, 1.02
local function alert(t, pose, ctx)
	local freeze = L.env(t, 0, 0.07, 0.33, 0.1, "backOut", "quadIn")
	local crouch = L.env(t, 0.18, 0.24, 0.03, 0.1, "cubicOut", "quadIn")
	local boom = L.env(t, AJUMP, 0.1, 0.5, 0.4, "backOut", "cubicInOut")
	local hop = L.env(t, AJUMP, 0.26, 0.04, 0.27, "quadOut", "quadIn")
	local land = L.env(t, ALAND, 0.04, 0.03, 0.4, "linear", "elasticOut")
	local ready = L.env(t, 1.15, 0.2, 0.25, 0.2)
	local helmetUp = L.env(t, AJUMP, 0.2, 0.15, 0.3, "quadOut", "bounceOut")
	local shake = wave(t, 9) * boom

	local b = {
		x = 0.08 * shake,
		y = -0.18 * freeze - 0.5 * crouch + 1.3 * hop - 0.45 * land - 0.1 * ready,
		z = 0.1 * crouch,
		p = 4 * freeze - 10 * crouch + 6 * boom - 10 * land - 16 * ready,
		yaw = 6 * shake,
		r = 3 * wave(t, 23) * freeze,
	}
	local fR = planted(1, 0.9 * hop, 0.15 * hop - 0.2 * ready)
	local fL = planted(-1, 0.9 * hop, 0.15 * hop + 0.25 * ready)
	rig(pose, b, fR, fL, ang(-30 * hop, 0, 0), ang(-30 * hop, 0, 0))

	pose.Neck = pa(0, -0.25 * crouch + 0.1 * boom, 0, -10 * crouch + 14 * boom - 6 * land + 10 * ready, 0, 0)
	pose.Head = pa(0, 0, 0, 6 * freeze - 6 * crouch + 14 * boom - 10 * land + 6 * ready + 5 * wave(t, 17) * boom,
		16 * shake, 8 * wave(t, 7) * boom)
	pose.Jaw = ang(-28 * freeze - 78 * boom - 8 * boom * wave(t, 18) - 20 * land - 18 * ready, 0, 0)
	pose.Comb = ang(-25 * boom + 18 * land * wave(t, 7) + 10 * freeze * wave(t, 20), 0, 12 * shake)
	pose.Helmet = pa(0.15 * helmetUp, 1.0 * helmetUp, 0.1 * helmetUp, -25 * helmetUp, 0, -30 * helmetUp)

	local wingZ = 4 - 6 * crouch + 45 * boom + 30 * boom * wave(t, 8) + 15 * land + 10 * ready
	L.both(pose, "Wing", ang(0, 0, wingZ) * ang(0, 85 * boom, 0))
	L.both(pose, "WingTip", ang(0, 0, 30 * boom * wave(t, 8, -0.2)))
	pose.Tail = ang(-30 * boom + 10 * crouch + 8 * land, 10 * shake, 0)
	pose.TailTip = ang(-20 * boom + 12 * land * wave(t, 6), 0, 0)

	face(pose, ctx, {
		pop = 0.35 * freeze + 0.25 * boom, lx = 0, ly = 0,
		browY = 0.25 * freeze + 0.15 * boom - 0.08 * ready, browR = -10 * freeze - 4 * boom + 18 * ready,
		blink = 0, shock = t > 0.03 and t < 0.95,
	})
	ctx.transparency("Exclaim1", (t > 0.03 and t < 1.25) and 0 or 1)
	ctx.transparency("Exclaim2", (t > 0.03 and t < 1.25) and 0 or 1)
	showAnger(ctx, t > 1.0)

	orbs(pose, t, 0.5, 1.2 * boom, 0.4 * land)

	if ctx.crossed(AJUMP + 0.02) then
		ctx.emit("FeatherBurst", 45)
		ctx.emit("CrowBurst", 22)
		ctx.emit("StepDust", 8)
	end
	if ctx.crossed(0.7) then
		ctx.emit("FeatherBurst", 12)
	end
	if ctx.crossed(ALAND) then
		ctx.emit("StepDust", 14)
		ctx.emit("LeafKick", 8)
	end
	if ctx.crossed(1.15) then
		ctx.emit("SteamPuff", 6)
	end
end

------------------------------------------------------------------------
-- CHASE (0.4 s loop): cartoon wheel-legs
------------------------------------------------------------------------
local CL, CDUTY, CS, CH = 0.4, 0.5, 1.6, 0.85
local CSPEED = CS / (CDUTY * CL) -- 8 studs/s
local function chase(t, pose, ctx)
	local ph = (t % CL) / CL
	local lR, zR, swR, uR = stride(ph, CDUTY, CS, CH, FOOT.Z - 0.15)
	local lL, zL, swL, uL = stride((ph + 0.5) % 1, CDUTY, CS, CH, FOOT.Z - 0.15)
	local s2 = (ph * 2) % 1
	local hz = 1 / CL
	local b = {
		x = 0.06 * wave(t, hz),
		y = -0.12 + 0.18 * sin(pi * s2),
		z = 0,
		p = -20 - 4 * sin(pi * s2),
		yaw = 7 * wave(t, hz),
		r = -4 * wave(t, hz),
	}
	local fR = Vector3.new(FOOT.X, FOOT.Y + lR, zR)
	local fL = Vector3.new(-FOOT.X, FOOT.Y + lL, zL)
	local function frot(sw, u)
		return sw == 1 and ang((-45 + 85 * u) * sin(pi * u), 0, 0) or IDENT
	end
	rig(pose, b, fR, fL, frot(swR, uR), frot(swL, uL))

	pose.Neck = pa(0, 0.05, -0.25, 12 + 3 * sin(pi * s2), -4 * wave(t, hz), 0)
	pose.Head = pa(0, 0, 0, 8 - 3 * sin(pi * s2), -3 * wave(t, hz), 3 * wave(t, hz))
	pose.Jaw = ang(-30 - 14 * wave(t, 2 * hz), 0, 0)
	pose.Comb = ang(28 + 10 * wave(t, 4 * hz), 0, 6 * wave(t, 2 * hz))
	pose.Helmet = pa(0, 0.06 * abs(wave(t, 2 * hz)), 0, 6, 0, 5 * wave(t, hz))

	local flapW = wave(t, 2 * hz)
	L.both(pose, "Wing", ang(-10, 0, 0) * ang(0, 0, 30 + 35 * flapW) * ang(0, 50, 0))
	L.both(pose, "WingTip", ang(0, 0, 25 * wave(t, 2 * hz, -0.2)))
	pose.Tail = ang(-18 + 6 * wave(t, 2 * hz, -0.15), 8 * wave(t, hz, -0.1), 0)
	pose.TailTip = ang(-10 + 10 * wave(t, 2 * hz, -0.3), 10 * wave(t, hz, -0.25), 0)

	face(pose, ctx, { pop = 0.08, lx = 0, ly = -0.04, browY = -0.08, browR = 16, blink = 0 })
	showAnger(ctx, true)
	orbs(pose, t, hz, 0, 0)

	if ctx.crossed(0.01) or ctx.crossed(CL * 0.5 + 0.01) then
		ctx.emit("StepDust", 3)
	end
end

------------------------------------------------------------------------
-- ATTACK (1.0 s): PECK PECK PECK
------------------------------------------------------------------------
local PK = { 0.3, 0.49, 0.68 }
local function attack(t, pose, ctx)
	local wind = L.env(t, 0, 0.24, 0.03, 0.08, "cubicOut", "quadIn")
	local flurry = L.env(t, 0.24, 0.06, 0.52, 0.18)
	local peck, open = 0, 0
	for _, p in PK do
		peck = max(peck, L.env(t, p, 0.06, 0.03, 0.1, "quadIn", "quadOut"))
		open = max(open, L.env(t, p - 0.05, 0.05, 0.02, 0.04, "quadOut", "quadIn"))
	end
	local b = {
		x = 0,
		y = -0.15 * wind - 0.2 * flurry - 0.12 * peck,
		z = 0.25 * wind - 0.7 * peck,
		p = 16 * wind - 6 * flurry - 10 * peck,
		yaw = 4 * wave(t, 5) * flurry,
		r = 0,
	}
	local fR = planted(1, 0, 0.15 * flurry)
	local fL = planted(-1, 0, -0.1 * flurry)
	rig(pose, b, fR, fL)
	pose.Neck = pa(0, 0, 0.3 * wind - 0.45 * peck, 22 * wind - 12 * peck - 2 * flurry, 0, 0)
	pose.Head = ang(10 * wind + 6 * peck + 4 * flurry, 0, 6 * wave(t, 5) * flurry)
	pose.Jaw = ang(-14 * wind - 55 * open, 0, 0)
	pose.Comb = ang(-12 * wind + 18 * peck, 0, 8 * wave(t, 6) * flurry)
	pose.Helmet = pa(0, 0.08 * peck, 0, 6 * peck, 0, 3 * wave(t, 10) * flurry)
	local wingZ = 10 + 40 * wind + 30 * flurry + 35 * peck
	L.both(pose, "Wing", ang(20 * wind - 15 * peck, 0, 0) * ang(0, 0, wingZ))
	L.both(pose, "WingTip", ang(0, 0, 20 * peck))
	pose.Tail = ang(-14 * peck + 8 * wind, 0, 0)
	pose.TailTip = ang(10 * peck * wave(t, 8), 0, 0)
	face(pose, ctx, { pop = 0.06 * peck, ly = -0.04, browY = -0.1 * (wind + flurry), browR = 20 * max(wind, flurry), blink = 0 })
	showAnger(ctx, t > 0.05 and t < 0.92)
	orbs(pose, t, 1, 0, 0.3 * peck)
	for _, p in PK do
		if ctx.crossed(p + 0.06) then
			ctx.emit("PeckSpark", 12)
			ctx.emit("CrowBurst", 5)
			ctx.emit("FeatherBurst", 2)
		end
	end
end

------------------------------------------------------------------------
-- CATCH (2.0 s): tiptoe victory crow
------------------------------------------------------------------------
local function catch(t, pose, ctx)
	local antic = L.env(t, 0, 0.25, 0.05, 0.15, "cubicOut", "quadIn")
	local up = L.env(t, 0.3, 0.25, 1.05, 0.35, "backOut", "cubicInOut")
	local crow = L.env(t, 0.5, 0.12, 0.8, 0.25, "backOut", "quadIn")
	local nod = L.env(t, 1.55, 0.1, 0.05, 0.25, "quadOut", "backOut")
	local b = {
		x = 0, y = -0.3 * antic + 0.35 * up, z = 0.1 * up,
		p = -8 * antic + 14 * up, yaw = 4 * wave(t, 3) * crow, r = 3 * wave(t, 2) * up,
	}
	local tip = 0.5 * up
	local fR = planted(1, tip, 0.05 * up)
	local fL = planted(-1, tip, 0.05 * up)
	rig(pose, b, fR, fL, ang(-38 * up, 0, 0), ang(-38 * up, 0, 0))
	pose.Neck = ang(-8 * antic + 6 * crow - 8 * nod, 0, 0)
	pose.Head = ang(-6 * antic + 20 * crow - 18 * nod + 4 * wave(t, 14) * crow, 6 * wave(t, 3) * crow, 0)
	pose.Jaw = ang(-74 * crow - 8 * crow * wave(t, 16) - 10 * nod, 0, 0)
	pose.Comb = ang(-24 * crow + 10 * wave(t, 6) * up, 0, 6 * wave(t, 4) * up)
	pose.Helmet = pa(0, 0.1 * crow, 0, -8 * crow, 0, 5 * wave(t, 4) * up)
	local wingZ = 5 - 8 * antic + 42 * up + 10 * wave(t, 4) * up
	L.both(pose, "Wing", ang(0, 0, wingZ) * ang(0, 88 * up, 0))
	L.both(pose, "WingTip", ang(0, 0, 20 * up + 12 * wave(t, 4, -0.2) * up))
	pose.Tail = ang(-20 * up, 8 * wave(t, 3) * up, 0)
	pose.TailTip = ang(-12 * up + 8 * wave(t, 6, -0.2) * up, 0, 0)
	local shut = L.env(t, 0.62, 0.05, 0.65, 0.06)
	face(pose, ctx, {
		pop = 0, lx = 0.08 * nod, browY = 0.1 * crow + 0.08 * nod, browR = -8 * crow - 6 * nod,
		browYL = 0.1 * crow - 0.05 * nod, browRL = -8 * crow + 10 * nod,
		blink = max(shut, blinkAt(t, { 1.85 })),
	})
	orbs(pose, t, 1, 0.6 * up, 0)
	ctx.light("BadgeLight", 1.3 * up)
	if ctx.crossed(0.6) then
		ctx.emit("CrowBurst", 22)
		ctx.emit("AuraSparkle", 12)
	end
	if ctx.crossed(0.95) or ctx.crossed(1.25) then
		ctx.emit("CrowBurst", 10)
	end
	if ctx.crossed(0.32) then
		ctx.emit("StepDust", 6)
	end
end

------------------------------------------------------------------------
-- GIVEUP (2.6 s): flop on the back + kicking tantrum, hop up, huff
------------------------------------------------------------------------
local function giveup(t, pose, ctx)
	local slump = L.env(t, 0, 0.15, 0.15, 0.15)
	local flop = L.env(t, 0.3, 0.3, 1.0, 0.3, "quadIn", "backOut") -- on its back 0.6 - 1.6
	local tant = L.env(t, 0.6, 0.1, 0.9, 0.15)
	local hop = L.env(t, 1.6, 0.18, 0.02, 0.2, "quadOut", "quadIn")
	local huff = L.env(t, 1.95, 0.15, 0.3, 0.2)
	local stomp1 = L.env(t, 1.98, 0.08, 0.02, 0.1, "quadOut", "quadIn")
	local stomp2 = L.env(t, 2.2, 0.08, 0.02, 0.1, "quadOut", "quadIn")
	local kick = wave(t, 6)
	local b = {
		x = 0.06 * kick * tant,
		y = -0.15 * slump - 0.08 * flop + 0.7 * hop + 0.04 * abs(kick) * tant,
		z = 0.7 * flop,
		p = -8 * slump + 74 * flop + 6 * huff * wave(t, 4),
		yaw = 8 * kick * tant,
		r = 0,
	}
	-- feet: planted on the ground, blended toward body-relative kicks while lying
	local hw0 = bodyCF(b)
	local function kickT(s, k)
		local loc = sideV(FOOT, s) - HIP + Vector3.new(0, 0.55 + 0.25 * k, -0.55 + 0.35 * k)
		return hw0 * loc
	end
	local fw = clamp(flop * 1.15, 0, 1)
	local gR = planted(1, 0.45 * stomp1 + 0.5 * hop, 0)
	local gL = planted(-1, 0.45 * stomp2 + 0.5 * hop, 0)
	local fR = gR:Lerp(kickT(1, kick * tant), fw)
	local fL = gL:Lerp(kickT(-1, -kick * tant), fw)
	local legRot = hw0.Rotation * ang(-30 * tant, 0, 0)
	rig(pose, b, fR, fL, IDENT:Lerp(legRot, fw), IDENT:Lerp(legRot, fw))

	pose.Neck = ang(-14 * slump - 30 * flop + 10 * huff, 0, 0)
	pose.Head = ang(-10 * slump - 16 * flop + 8 * huff * wave(t, 4) + 10 * huff, 30 * wave(t, 3.5) * tant, 10 * wave(t, 7) * tant)
	pose.Jaw = ang(-20 * slump - 30 * tant - 25 * tant * max(0, wave(t, 7)) - 12 * huff * L.wave01(t, 4), 0, 0)
	pose.Comb = ang(-10 * slump + 20 * wave(t, 7) * tant + 10 * huff, 0, 8 * wave(t, 5) * tant)
	pose.Helmet = pa(0, 0.15 * tant, 0, -15 * flop, 0, -12 * flop + 6 * wave(t, 7) * tant)
	local slap = wave(t, 5)
	local wingZ = 12 * slump + 45 * tant + 45 * slap * tant - 8 * huff
	local cross = huff -- wings folded across the chest, arms-crossed style
	L.both(pose, "Wing", ang(40 * cross, 0, 0) * ang(0, 0, wingZ) * ang(0, 30 * cross, 0))
	L.both(pose, "WingTip", ang(0, 0, 25 * slap * tant))
	pose.Tail = ang(-50 * flop + 8 * huff, 12 * kick * tant, 0)
	pose.TailTip = ang(-20 * flop, 0, 0)

	local worried = clamp(slump + flop * 0.5, 0, 1)
	face(pose, ctx, {
		pop = 0.15 * slump, lx = 0.12 * wave(t, 3.5) * tant, ly = 0.05 * tant,
		browY = 0.12 * worried - 0.1 * huff, browR = -14 * slump + 12 * tant + 22 * huff,
		blink = max(blinkAt(t, { 0.62 }), L.env(t, 2.0, 0.05, 0.35, 0.05)), shock = t > 0.04 and t < 0.32,
	})
	ctx.transparency("Sweat1", (t > 0.05 and t < 1.7) and 0 or 1)
	ctx.transparency("Sweat2", (t > 0.05 and t < 1.7) and 0 or 1)
	showAnger(ctx, t > 0.6 and t < 2.45)
	orbs(pose, t, 1, 0, 0.6 * flop)

	if ctx.crossed(0.58) then
		ctx.emit("StepDust", 12)
		ctx.emit("FeatherBurst", 10)
	end
	for k = 0, 4 do
		if ctx.crossed(0.7 + k * 0.2) then
			ctx.emit("StepDust", 3)
			ctx.emit("LeafKick", 2)
		end
	end
	if ctx.crossed(1.98) or ctx.crossed(2.2) then
		ctx.emit("StepDust", 5)
	end
	if ctx.crossed(1.85) or ctx.crossed(2.15) or ctx.crossed(2.4) then
		ctx.emit("SteamPuff", 4)
	end
end

------------------------------------------------------------------------
-- RETURN (1.2 s loop): proud chest-out strut
------------------------------------------------------------------------
local RL, RDUTY, RS, RH = 1.2, 0.5, 1.4, 0.7
local RSPEED = RS / (RDUTY * RL) -- 2.33 studs/s
local function ret(t, pose, ctx)
	local ph = (t % RL) / RL
	local lR, zR, swR, uR = stride(ph, RDUTY, RS, RH, FOOT.Z - 0.05)
	local lL, zL, swL, uL = stride((ph + 0.5) % 1, RDUTY, RS, RH, FOOT.Z - 0.05)
	local hz = 1 / RL
	local s2 = (ph * 2) % 1
	local b = {
		x = 0.12 * wave(t, hz),
		y = -0.08 + 0.14 * sin(pi * s2),
		z = 0,
		p = 9 + 2 * sin(pi * s2),
		yaw = 9 * wave(t, hz),
		r = -6 * wave(t, hz),
	}
	local fR = Vector3.new(FOOT.X, FOOT.Y + lR, zR)
	local fL = Vector3.new(-FOOT.X, FOOT.Y + lL, zL)
	local function frot(sw, u)
		return sw == 1 and ang(-35 * sin(pi * u), 0, 0) or IDENT
	end
	rig(pose, b, fR, fL, frot(swR, uR), frot(swL, uL))
	local hb = L.saw(t, 2 * hz)
	local thrust = hb < 0.3 and E.quadOut(hb / 0.3) or 1 - E.sineInOut((hb - 0.3) / 0.7)
	pose.Neck = pa(0, 0.04 * thrust, -0.3 * thrust, -8 - 6 * thrust, -6 * wave(t, hz), 0)
	pose.Head = ang(6 + 4 * thrust, -8 * wave(t, hz), 5 * wave(t, hz, 0.15))
	pose.Jaw = ang(-14 * max(0, wave(t, hz, 0.3)) ^ 6, 0, 0)
	pose.Comb = ang(8 * wave(t, 2 * hz, -0.2), 0, 8 * wave(t, hz, -0.15))
	pose.Helmet = pa(0, 0.03 * abs(wave(t, 2 * hz)), 0, 0, 0, 3 * wave(t, hz, -0.1))
	L.both(pose, "Wing", ang(-12, 0, 0) * ang(0, 0, 28 + 6 * wave(t, 2 * hz)))
	L.both(pose, "WingTip", ang(0, 0, 10 * wave(t, 2 * hz, -0.2)))
	pose.Tail = ang(-8, 14 * wave(t, hz, -0.12), 0)
	pose.TailTip = ang(4 * wave(t, 2 * hz, -0.3), 12 * wave(t, hz, -0.3), 0)
	face(pose, ctx, {
		lx = 0.14 * wave(t, hz, 0.1), browY = 0.06, browR = 8, browYL = -0.04, browRL = 18,
		blink = blinkAt(ph * RL, { 0.75 }),
	})
	orbs(pose, t, hz, 0, 0)
	if ctx.crossed(0.01) or ctx.crossed(RL * 0.5 + 0.01) then
		ctx.emit("StepDust", 2)
	end
end

------------------------------------------------------------------------
local M = {}
M.Props = {
	Exclaim1 = 1, Exclaim2 = 1,
	Anger1 = 1, Anger2 = 1, Anger3 = 1, Anger4 = 1, Anger5 = 1, Anger6 = 1, Anger7 = 1, Anger8 = 1,
	Sweat1 = 1, Sweat2 = 1,
	EyelidR = 1, EyelidL = 1, LashR = 1, LashL = 1,
	PupilDiscR = 0, PupilDiscL = 0, GlintR = 0, GlintL = 0, DotR = 1, DotL = 1,
}
M.States = {
	Idle = { Loop = true, Length = IL, Update = idle },
	Alert = { Length = 1.8, Update = alert },
	Chase = { Loop = true, Length = CL, Speed = CSPEED, Update = chase },
	Attack = { Length = 1.0, Update = attack },
	Catch = { Length = 2.0, Update = catch },
	GiveUp = { Length = 2.6, Update = giveup },
	Return = { Loop = true, Length = RL, Speed = RSPEED, Update = ret },
}
M.Base = "Idle"
M.Reel = { { "Idle" }, { "Alert" }, { "Chase", 3.6 }, { "Attack" }, { "Catch" }, { "Chase", 1.8 }, { "GiveUp" }, { "Return", 3.6 } }
return L.states(M)
