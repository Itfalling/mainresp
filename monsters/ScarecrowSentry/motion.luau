--!nocheck
-- Scarecrow Sentry motion (guardian states).
--  Idle   : PRETENDS to be a normal scarecrow (arms out, head slumped, one
--           stake foot dangling, swaying in the breeze) - then gives itself
--           away: jerky twitches, the head CREAKS 90 deg round to stare,
--           a polite hat tip, an "ah-ah-CHOO" straw sneeze, and the show-off:
--           a baton PITCHFORK TWIRL with a hop, a stamp and a proud pose,
--           then it snaps back into the scarecrow pose like nothing happened.
--  Alert  : startle crouch -> star JUMP (hat flies off, "!" pops, eyes flare,
--           straw burst) -> land -> head spins 360 while the limbs jerk
--           wildly -> hat lands -> leans into a ready-to-run glare.
--  Chase  : gangly flailing run, left arm windmilling, fork levelled like a
--           lance, straw flying, feet plant (IK) with dust on every footfall.
--  Attack : wind-up (twist + cock the fork back) -> lunge THRUST -> sparks.
--  Catch  : the hat spins up in the air while it dances a heel-kick jig.
--  GiveUp : collapses into a slumped heap of straw, then pops back up and
--           stomps twice in a tantrum, then calms.
--  Return : loose, limp-swinging trudge home with the fork over its shoulder.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease
local env, track = L.env, L.track
local V = Vector3.new
local sin, cos, pi, max, min, abs, floor, clamp = math.sin, math.cos, math.pi, math.max, math.min, math.abs, math.floor, math.clamp

------------------------------------------------------------------------
-- rig constants (kept in sync with build.luau)
------------------------------------------------------------------------
local HIPS_PIV = V(0, 3.7, 0)
local HIP_R, HIP_L = V(0.65, 3.55, 0), V(-0.65, 3.55, 0)
local ANKLE_R, ANKLE_L = V(0.65, 0.6, 0), V(-0.65, 0.6, 0)
local THIGH_LEN, SHIN_LEN = 1.55, 1.4
local LMAX = THIGH_LEN + SHIN_LEN - 0.04

local function rotTo(a, b)
	local axis = a:Cross(b)
	local m = axis.Magnitude
	if m < 1e-6 then
		return CFrame.new()
	end
	return CFrame.fromAxisAngle(axis / m, math.atan2(m, a:Dot(b)))
end

local function hipWorld(hipsCF, hipRest)
	return HIPS_PIV + hipsCF.Position + hipsCF.Rotation * (hipRest - HIPS_PIV)
end

-- how far the hips must drop so the ankle target is reachable
local function needDrop(hipsCF, hipRest, ankle)
	local h = hipWorld(hipsCF, hipRest)
	local d = ankle - h
	local h2 = d.X * d.X + d.Z * d.Z
	local vert = math.sqrt(max(0, LMAX * LMAX - h2))
	return max(0, -d.Y - vert)
end

-- 2-bone leg IK: foot pivot lands on `ankle` and stays flat (then toe pitch)
local function legIK(hipsCF, hipRest, ankle, toe)
	local R = hipsCF.Rotation
	local D = R:Inverse() * (ankle - hipWorld(hipsCF, hipRest))
	local a, b = THIGH_LEN, SHIN_LEN
	local len = clamp(D.Magnitude, 0.4, a + b - 0.02)
	local knee = math.acos(clamp((a * a + b * b - len * len) / (2 * a * b), -1, 1))
	local th = math.acos(clamp((a * a + len * len - b * b) / (2 * a * len), -1, 1))
	local thigh = rotTo(V(0, -1, 0), D.Unit) * CFrame.Angles(th, 0, 0)
	local shin = CFrame.Angles(-(pi - knee), 0, 0)
	local foot = (R * thigh * shin).Rotation:Inverse() * ang(toe or 0, 0, 0)
	return thigh, shin, foot
end

-- stepped "jerky" random value (holds, then snaps to the next)
local function hash(i, s)
	local x = sin(i * 12.9898 + s * 78.233) * 43758.5453
	return (x - floor(x)) * 2 - 1
end
local function jerk(t, rate, seed)
	local k = t * rate
	local i = floor(k)
	local f = k - i
	local a, b = hash(i, seed), hash(i + 1, seed)
	return a + (b - a) * L.smoothstep(L.remap(f, 0.7, 1))
end

local function rot(c)
	return c.Rotation
end

local function gust01(t)
	return 0.5 + 0.5 * wave(t, 0.25, 0.3)
end

------------------------------------------------------------------------
-- q: high level pose controls (all default to the neutral standing pose)
------------------------------------------------------------------------
local function Q()
	return {
		hipX = 0, hipY = 0, hipZ = 0, hipP = 0, hipYaw = 0, hipR = 0,
		footR = V(0, 0, 0), footL = V(0, 0, 0), toeR = 0, toeL = 0,
		chestP = 0, chestY = 0, chestR = 0,
		headP = 0, headY = 0, headR = 0, headUp = 0, neckK = 0.35,
		jaw = 5, browUp = 0, browAng = 0, browUpL = nil, browAngL = nil, lid = 0, eyePop = 0, eyeGlow = 0,
		armR = V(0, 0, 0), foreR = V(0, 0, 0), handR = V(0, 0, 0),
		armL = V(0, 0, 0), foreL = V(0, 0, 0), handL = V(0, 0, 0),
		forkW = nil, forkK = 0, forkSlide = 0,
		hatX = 0, hatUp = 0, hatZ = 0, hatP = 0, hatSpin = 0, hatR = 0,
		flop = 1, flopHz = 0.5, brimDroop = 0,
		orbOut = 0,
		angry = false, exclaim = false, mouthGlow = 0, strawFly = false, forkLight = 0,
		popY = 0, popR = 0,
	}
end

local function A(v)
	return ang(v.X, v.Y, v.Z)
end

-- applies q to every bone (+ shared secondary motion and props)
local function apply(pose, ctx, q, t)
	-- HIPS (+ keep both ankle targets reachable)
	local tR = ANKLE_R + q.footR
	local tL = ANKLE_L + q.footL
	local hipsCF = pa(q.hipX, q.hipY, q.hipZ, q.hipP, q.hipYaw, q.hipR)
	local drop = max(needDrop(hipsCF, HIP_R, tR), needDrop(hipsCF, HIP_L, tL))
	if drop > 0 then
		hipsCF = pa(q.hipX, q.hipY - drop, q.hipZ, q.hipP, q.hipYaw, q.hipR)
	end
	pose.Hips = hipsCF
	pose.ThighR, pose.ShinR, pose.FootR = legIK(hipsCF, HIP_R, tR, q.toeR)
	pose.ThighL, pose.ShinL, pose.FootL = legIK(hipsCF, HIP_L, tL, q.toeL)

	pose.Chest = ang(q.chestP, q.chestY, q.chestR)
	local nk = q.neckK
	pose.Neck = ang(nk * q.headP, nk * q.headY, nk * q.headR)
	pose.Head = pa(0, q.headUp, 0, (1 - nk) * q.headP, (1 - nk) * q.headY, (1 - nk) * q.headR)
	pose.Jaw = ang(-q.jaw, 0, 0)

	-- face
	local bu, ba = q.browUp, q.browAng
	pose.BrowR = pa(0, bu, 0, 0, 0, ba)
	pose.BrowL = L.mirror(pa(0, q.browUpL or bu, 0, 0, 0, q.browAngL or ba))
	local lid = clamp(q.lid, 0, 1)
	L.both(pose, "Lid", CFrame.new(0, -0.62 * lid, 0))
	if lid > 0.12 then
		ctx.transparency("LidR", 0)
		ctx.transparency("LidL", 0)
	end
	L.both(pose, "Eye", CFrame.new(0, 0.04 * q.eyePop, -0.22 * q.eyePop))
	ctx.light("EyeLight", clamp(0.5 + q.eyeGlow, 0, 1.8))
	if q.mouthGlow > 0.02 then
		ctx.transparency("MouthGlow", 1 - clamp(q.mouthGlow, 0, 0.85))
	end

	-- arms
	pose.ArmR, pose.ForearmR, pose.HandR = A(q.armR), A(q.foreR), A(q.handR)
	pose.ArmL, pose.ForearmL, pose.HandL = L.mirror(A(q.armL)), L.mirror(A(q.foreL)), L.mirror(A(q.handL))

	-- pitchfork: either follows the hand or is locked to a world orientation
	local fork = CFrame.new()
	if q.forkW and q.forkK > 0 then
		local chain = rot(hipsCF) * rot(pose.Chest) * rot(pose.ArmR) * rot(pose.ForearmR) * rot(pose.HandR)
		fork = CFrame.new():Lerp(chain:Inverse() * q.forkW, q.forkK)
	end
	pose.Fork = fork * CFrame.new(0, q.forkSlide, 0)

	-- hat + floppy brim (secondary)
	pose.Hat = pa(q.hatX, q.hatUp, q.hatZ, 7 + q.hatP, q.hatSpin, q.hatR)
	local f, hz = q.flop, q.flopHz
	local d = q.brimDroop
	pose.BrimF = ang(-6 - d - 6 * f * wave(t, hz, 0.1), 0, 0)
	pose.BrimB = ang(5 + d + 5 * f * wave(t, hz, 0.35), 0, 0)
	pose.BrimR = ang(0, 0, -9 - d - 6 * f * wave(t, hz, 0.6))
	pose.BrimL = L.mirror(ang(0, 0, -9 - d - 6 * f * wave(t, hz, 0.85)))
	pose.Hair = ang(4 * f * wave(t, hz, 0.2), 0, 3 * f * wave(t, hz * 0.5, 0.4))
	pose.RopeEnd = ang(10 * f * wave(t, hz, 0.3) + 8 * q.hipP / 20, 0, 8 * f * wave(t, hz * 0.5))

	-- floating harvest cubes
	pose.Orbit = ang(0, 30 * t, 0)
	for i = 1, 4 do
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(0, 0.6 * wave(t, 0.5, i * 0.27) + 0.8 * q.orbOut, 0, 50 * t * dir, 80 * t + 30 * i, 15 * i)
	end

	-- props + toggles
	if q.angry then
		for i = 1, 4 do
			ctx.transparency("AngryMark" .. i, 0)
		end
	end
	if q.exclaim then
		ctx.transparency("Exclaim", 0)
		ctx.transparency("ExclaimDot", 0)
	end
	pose.Pop = pa(0, q.popY, 0, 0, 0, q.popR)
	ctx.enable("StrawFly", q.strawFly)
	ctx.light("ForkLight", clamp(q.forkLight, 0, 1.6))
end

-- the classic "I'm just a scarecrow" pose (Idle)
local function pretend(q, k, t)
	local breeze = wave(t, 1 / 6)
	local gust = wave(t, 0.5, 0.2)
	q.armR = q.armR + V(4 * gust, 0, 70 + 3 * breeze) * k
	q.foreR = q.foreR + V(0, 0, -10 - 4 * gust) * k
	q.handR = q.handR + V(0, 0, -20) * k
	q.armL = q.armL + V(-3 * gust, 0, 66 - 3 * breeze) * k
	q.foreL = q.foreL + V(0, 0, -16 + 4 * gust) * k
	q.handL = q.handL + V(10, 0, -32 + 6 * wave(t, 0.5, 0.6)) * k
	q.headP += (-3 + 2 * breeze) * k
	q.headR += (-17 + 3 * breeze) * k
	q.headY += 6 * k
	q.hipR += 2.5 * breeze * k
	q.chestR += (-2 * breeze) * k
	q.footL = q.footL + V(0.12, 0.32, -0.05) * k
	q.toeL += -28 * k
	q.hipY += -0.05 * k
	q.jaw += 2 * k
end

------------------------------------------------------------------------
-- STATES
------------------------------------------------------------------------
local M = {}
M.Props = {
	LidR = 1, LidL = 1, MouthGlow = 1, Exclaim = 1, ExclaimDot = 1,
	AngryMark1 = 1, AngryMark2 = 1, AngryMark3 = 1, AngryMark4 = 1,
}

local UP = CFrame.new()

------------------------------------------------------------------------
-- IDLE (12 s): pretending + gags + pitchfork twirl show-off
------------------------------------------------------------------------
local IDLE_LEN = 12
local DEBUG_REST = false
local function idle(t, pose, ctx)
	local c = t % IDLE_LEN
	local q = Q()
	if DEBUG_REST then
		apply(pose, ctx, q, t)
		return
	end

	-- envelopes
	local twitch = env(c, 1.35, 0.05, 1.0, 0.15)
	local creak = track(c, { { 3.0, 0 }, { 4.3, 1, "linear" }, { 4.95, 1 }, { 5.12, 0, "backIn" } })
	local stare = env(c, 4.2, 0.15, 0.65, 0.1)
	local snapBack = env(c, 5.12, 0.04, 0.05, 0.4, "linear", "elasticOut")
	local tip = env(c, 5.75, 0.35, 0.5, 0.35, "backOut", "cubicInOut")
	local ah = env(c, 7.25, 0.55, 0.15, 0.05, "sineInOut", "quadIn")
	local choo = env(c, 7.95, 0.05, 0.12, 0.45, "quadOut", "cubicInOut")
	local show = track(c, { { 8.55, 0 }, { 8.85, 1, "backOut" }, { 11.15, 1 }, { 11.3, 0, "cubicIn" } })
	local twirlA = track(c, { { 8.9, 0 }, { 10.25, -1080, "quadInOut" } })
	local slideK = track(c, { { 8.6, 0 }, { 8.9, 1, "quadOut" }, { 10.25, 1 }, { 10.45, 0, "quadIn" } })
	local stamp = env(c, 10.45, 0.05, 0.08, 0.5, "quadOut", "backOut")
	local proud = env(c, 10.5, 0.2, 0.55, 0.25, "backOut", "cubicIn")
	local freeze = env(c, 11.3, 0.04, 0.04, 0.5, "linear", "elasticOut")
	local hop = max(0, sin(pi * L.remap(c, 9.2, 9.6))) + max(0, sin(pi * L.remap(c, 9.75, 10.15)))
	local hopping = (c > 9.2 and c < 10.15) and 1 or 0
	local P = 1 - max(show, 0.45 * tip)

	pretend(q, P, t)

	-- breeze + idle breathing everywhere
	q.chestP += 1.5 * wave(t, 0.25)
	q.flop = 1 + 0.6 * gust01(t)
	q.flopHz = 0.5

	-- GAG 1: jerky twitches (snap the head upright, arm/knee jerks)
	local j1 = jerk(c, 9, 3) * twitch
	local j2 = jerk(c, 9, 7) * twitch
	q.armL = q.armL + V(18 * j1, 0, 22 * j2)
	q.foreL = q.foreL + V(0, 0, 25 * j1)
	q.headR += 22 * twitch + 6 * j2
	q.headP += 8 * twitch * j1
	q.hipY += 0.12 * abs(j1)
	q.footL = q.footL + V(0, 0.2 * abs(j2), 0)
	q.armR = q.armR + V(0, 0, 10 * j2)

	-- GAG 2: head creaks round 90 deg (stuttered) to STARE, then snaps back
	local steps = 7
	local u = creak * steps
	local stepped = (floor(u) + L.smoothstep(u - floor(u)) ^ 3) / steps
	if creak >= 1 then
		stepped = 1
	end
	q.headY += -95 * stepped
	q.headR += 16 * stepped -- un-slump while staring
	q.headP += 8 * stepped
	q.neckK = 0.25
	q.eyePop += 0.6 * stare
	q.eyeGlow += 0.9 * stare
	q.browUp += 0.14 * stare
	q.jaw += 14 * stare
	q.mouthGlow = max(q.mouthGlow, 0.6 * stare)
	q.headR += -10 * snapBack
	q.hatUp += 0.25 * snapBack

	-- GAG 3: polite hat tip with the left hand
	q.armL = q.armL + V(118, 0, -36) * tip
	q.foreL = q.foreL + V(95, 0, 0) * tip
	q.handL = q.handL + V(-20, 0, 0) * tip
	q.hatUp += 0.45 * tip
	q.hatP += 22 * tip
	q.hatZ += -0.2 * tip
	q.headP += -10 * tip
	q.headR += 12 * tip
	q.lid = max(q.lid, 0.5 * tip)
	q.jaw += 8 * tip
	q.hipP += -4 * tip

	-- GAG 4: ah... ah... CHOO! (straw sneeze)
	q.headP += 24 * ah - 34 * choo
	q.headR += 10 * ah
	q.jaw += 12 * ah + 30 * choo
	q.browUp += 0.12 * ah
	q.lid = max(q.lid, 0.75 * ah)
	q.chestP += 8 * ah - 14 * choo
	q.hipZ += 0.25 * choo
	q.hatUp += 0.7 * choo
	q.hatSpin += 40 * choo
	q.hatP += -12 * choo
	q.armR = q.armR + V(0, 0, 14 * choo)
	q.armL = q.armL + V(0, 0, 18 * choo)

	-- SHOW-OFF: pitchfork baton twirl, hop, stamp, proud pose
	q.armR = q.armR + V(70 + 10 * proud, 0, -40 - 20 * proud) * show
	q.foreR = q.foreR + V(18 - 18 * proud, 0, 10) * show
	q.handR = q.handR + V(-10, 0, 0) * show
	q.armL = q.armL + V(-10 + 30 * hopping * wave(t, 2.5), 0, 40 * hopping) * show
	q.foreL = q.foreL + V(40, 0, 0) * show
	q.headP += (6 + 8 * proud) * show
	q.headY += -14 * show * (1 - proud)
	q.headR += 6 * show * wave(t, 1.25)
	q.jaw += (10 + 18 * proud) * show
	q.mouthGlow = max(q.mouthGlow, 0.5 * proud)
	q.browAng += -6 * show
	q.browUp += 0.1 * proud
	q.lid = max(q.lid, 0.45 * proud)
	q.hipY += 0.7 * hop - 0.35 * show * (1 - hopping) - 0.45 * stamp + 0.15 * proud
	q.footR = q.footR + V(0, 0.55 * hop, 0)
	q.footL = q.footL + V(0, 0.55 * hop, 0)
	q.toeR += -18 * hop
	q.toeL += -18 * hop
	q.chestP += 6 * proud - 6 * stamp
	q.hipP += 3 * proud
	q.orbOut += 0.8 * stamp + 0.5 * show * hopping

	-- fork: world-upright staff, twirled in the frontal plane round its middle
	local tw = UP * ang(0, 0, twirlA)
	q.forkW = ang(0, 0, -5 * P) * tw
	q.forkK = 1
	q.forkSlide = -1.2 * slideK

	-- snap back into the pretend pose with a wobble
	q.headR += -8 * freeze
	q.armR = q.armR + V(0, 0, 8 * freeze)
	q.armL = q.armL + V(0, 0, 8 * freeze)
	q.hipY += -0.1 * freeze

	-- blinks (not while staring)
	local bl = max(env(t % 3.4, 2.9, 0.06, 0.05, 0.09), env(t % 7.1, 1.6, 0.06, 0.05, 0.09))
	q.lid = max(q.lid, bl * (1 - stare))
	q.eyeGlow += 0.15 * wave(t, 0.5)

	apply(pose, ctx, q, t)

	-- effects
	if ctx.crossed(5.13) then
		ctx.emit("StrawBurst", 6)
	end
	if ctx.crossed(7.96) then
		ctx.emit("Sneeze", 34)
		ctx.emit("StrawBurst", 10)
	end
	for _, s in { 9.36, 9.81, 10.25 } do
		if ctx.crossed(s) then
			ctx.emit("ForkSpark", 8)
		end
	end
	if ctx.crossed(9.6) or ctx.crossed(10.15) then
		ctx.emit("DustR", 6)
		ctx.emit("DustL", 6)
	end
	if ctx.crossed(10.47) then
		ctx.emit("DustR", 12)
		ctx.emit("DustL", 12)
		ctx.emit("ForkSpark", 16)
		ctx.emit("Sparkle", 14)
	end
	if ctx.crossed(4.25) then
		ctx.emit("EyeEmbers", 8)
	end
	ctx.light("ForkLight", 1.2 * stamp)
end

------------------------------------------------------------------------
-- ALERT (2.0 s): MY PLANT!
------------------------------------------------------------------------
local ALERT_LEN = 2.0
local function alert(t, pose, ctx)
	local q = Q()
	local crouch = env(t, 0.0, 0.14, 0.02, 0.12, "quadOut", "quadIn")
	local jump = env(t, 0.14, 0.16, 0.05, 0.16, "quadOut", "quadIn")
	local star = env(t, 0.14, 0.12, 0.2, 0.25, "backOut", "cubicInOut")
	local land = env(t, 0.5, 0.04, 0.06, 0.35, "quadOut", "backOut")
	local spin = track(t, { { 0.6, 0 }, { 1.25, 360, "cubicInOut" } })
	local wild = env(t, 0.55, 0.08, 0.7, 0.15)
	local hatFly = track(t, { { 0.16, 0 }, { 0.45, 1.9, "quadOut" }, { 0.7, 2.1 }, { 0.98, 0, "bounceOut" } })
	local hatSpin = track(t, { { 0.16, 0 }, { 0.98, 540, "quadOut" } })
	local ready = track(t, { { 1.25, 0 }, { 1.5, 1, "backOut" }, { 1.75, 1 }, { 2.0, 0.35, "sineInOut" } })
	local flare = env(t, 0.18, 0.08, 1.0, 0.5, "backOut", "quadIn")
	local stomp = env(t, 1.45, 0.04, 0.05, 0.3, "quadOut", "backOut")
	local pop = env(t, 0.16, 0.12, 1.35, 0.15, "backOut", "quadIn")

	-- body: crouch, star jump, land squash, jitter, lean into the run
	local jx = jerk(t, 14, 1) * wild
	local jy = jerk(t, 14, 2) * wild
	local jz = jerk(t, 14, 3) * wild
	local jw = jerk(t, 14, 4) * wild
	q.hipY = -0.45 * crouch + 1.5 * jump - 0.55 * land + 0.08 * jy - 0.35 * ready - 0.2 * stomp
	q.hipP = -4 * crouch - 12 * ready
	q.hipR = 6 * jx
	q.hipYaw = 10 * jw
	q.chestP = -10 * crouch + 10 * star - 10 * ready + 6 * jz
	q.chestR = 6 * jy
	-- legs: tuck on the crouch, spread in the air (star), jittery stomps
	local airR = V(0.55, 1.1, 0) * star + V(0, 0.35 * max(0, jx), 0)
	local airL = V(-0.55, 1.1, 0) * star + V(0, 0.35 * max(0, -jx), 0)
	q.footR = airR + V(0, 0, -0.5 * ready)
	q.footL = airL + V(0, 0.9 * env(t, 1.33, 0.1, 0.0, 0.08, "quadOut", "quadIn"), 0.4 * ready)
	q.toeR = -25 * star
	q.toeL = -25 * star
	-- arms: thrown up and out, then wild jerks, then ready
	q.armR = V(20 * star + 45 * jx, 0, 120 * star + 40 * jy) + V(55, 0, 10) * ready
	q.foreR = V(-10 * star + 40 * jz, 0, 0) + V(25, 0, 0) * ready
	q.handR = V(0, 0, 25 * jw)
	q.armL = V(20 * star - 50 * jy, 0, 125 * star + 45 * jx) + V(-30, 0, 35) * ready
	q.foreL = V(-10 * star + 50 * jw, 0, 30 * jz) + V(60, 0, 0) * ready
	q.handL = V(30 * jx, 0, -30 * star)
	-- head: snaps up, spins 360, glares
	q.headP = -12 * crouch + 22 * star - 12 * ready + 8 * jy
	q.headY = spin
	q.headR = 10 * jz
	q.headUp = -0.15 * crouch + 0.35 * star
	q.neckK = 0.15
	q.jaw = 4 + 50 * star + 20 * wild * (0.5 + 0.5 * wave(t, 9)) + 14 * ready
	q.eyePop = flare
	q.eyeGlow = 1.2 * flare
	q.browUp = 0.25 * star - 0.05 * ready
	q.browAng = -12 * star + 26 * min(1, wild + ready)
	q.lid = 0.5 * crouch
	q.mouthGlow = flare
	q.angry = t > 0.8
	q.exclaim = t > 0.16 and t < 1.7
	q.popY = 0.9 * pop - 0.2
	q.popR = 14 * wave(t, 3) * pop
	-- hat flies off and comes back down
	q.hatUp = hatFly
	q.hatSpin = hatSpin
	q.hatP = 18 * star
	q.flop = 2.5
	q.flopHz = 4
	q.brimDroop = -10 * jump
	q.orbOut = 1.4 * star + 0.4 * wild
	-- fork: shaken high, then levelled forward
	q.forkW = ang(0, 0, -10 * star) * ang(-75 * ready, 0, 0)
	q.forkK = math.max(ready, 0.6 * star)

	apply(pose, ctx, q, t)

	if ctx.crossed(0.17) then
		ctx.emit("StrawBurst", 45)
		ctx.emit("EyeEmbers", 22)
		ctx.emit("Sparkle", 10)
	end
	if ctx.crossed(0.52) then
		ctx.emit("DustR", 14)
		ctx.emit("DustL", 14)
	end
	if ctx.crossed(0.98) then
		ctx.emit("StrawBurst", 12)
	end
	if ctx.crossed(1.47) then
		ctx.emit("DustL", 12)
		ctx.emit("ForkSpark", 10)
	end
	ctx.light("ForkLight", 0.8 * stomp)
end

------------------------------------------------------------------------
-- CHASE (0.6 s loop): flailing run
------------------------------------------------------------------------
local RUN_T, RUN_DUTY, RUN_D, RUN_H = 0.6, 0.42, 3.2, 1.35
local RUN_SPEED = RUN_D / (RUN_DUTY * RUN_T)

local function stride(p, duty, D, H)
	-- returns z offset (model, -Z forward), lift y, toe pitch, and swing 0..1
	if p < duty then
		local s = p / duty
		return -D / 2 + D * s, 0, 0, 0
	end
	local s = (p - duty) / (1 - duty)
	local z = D / 2 - D * E.sineInOut(s)
	local y = H * sin(pi * s) ^ 0.9
	local toe = -30 * sin(pi * s) + 18 * L.smoothstep(L.remap(s, 0.7, 1))
	return z, y, toe, sin(pi * s)
end

local function chase(t, pose, ctx)
	local q = Q()
	local p = (t / RUN_T) % 1
	local zR, yR, toeR = stride(p, RUN_DUTY, RUN_D, RUN_H)
	local zL, yL, toeL = stride((p + 0.5) % 1, RUN_DUTY, RUN_D, RUN_H)
	local f2 = 2 / RUN_T
	-- body bobs twice a cycle: low just after each footfall, high in the air
	local bob = cos(2 * pi * 2 * (p - 0.12))
	q.hipY = -0.15 - 0.3 * bob
	q.hipP = -16
	q.hipZ = -0.2
	q.hipYaw = 12 * sin(2 * pi * p)
	q.hipR = 5 * sin(2 * pi * p + 0.6)
	q.footR = V(0.08, yR, zR)
	q.footL = V(-0.08, yL, zL)
	q.toeR, q.toeL = toeR, toeL
	q.chestP = -10 + 4 * bob
	q.chestY = -16 * sin(2 * pi * p)
	q.chestR = -4 * sin(2 * pi * p + 0.6)
	-- floppy head lagging the bounce, angry face, chomping grin
	q.headP = -2 - 8 * cos(2 * pi * 2 * (p - 0.25)) + 10
	q.headY = 12 * sin(2 * pi * p - 0.6)
	q.headR = 10 * sin(2 * pi * p - 0.9)
	q.headUp = 0.08 * cos(2 * pi * 2 * (p - 0.3))
	q.jaw = 14 + 14 * (0.5 + 0.5 * wave(t, f2, 0.1))
	q.browAng = 26
	q.browUp = -0.04
	q.eyeGlow = 0.5
	q.mouthGlow = 0.65
	q.angry = true
	-- left arm WINDMILLS, right arm levels the fork like a lance
	q.armL = V(360 * p, 0, 28 + 10 * sin(2 * pi * p))
	q.foreL = V(-25 - 30 * (0.5 + 0.5 * sin(2 * pi * p - 1.2)), 0, 0)
	q.handL = V(-30 * sin(2 * pi * p - 1.6), 0, -20)
	q.armR = V(62 + 8 * bob, 0, 12)
	q.foreR = V(22, 0, 0)
	q.handR = V(-5, 0, 0)
	q.forkW = ang(-82 + 5 * bob, -6, 0)
	q.forkK = 1
	q.forkSlide = 0.3
	q.hatUp = 0.12 + 0.12 * cos(2 * pi * 2 * (p - 0.35))
	q.hatP = 10
	q.flop = 2.4
	q.flopHz = f2
	q.brimDroop = -8
	q.orbOut = 0.3
	q.strawFly = true

	apply(pose, ctx, q, t)

	if ctx.crossed(0.01) then
		ctx.emit("DustR", 8)
	end
	if ctx.crossed(0.5 * RUN_T + 0.01) then
		ctx.emit("DustL", 8)
	end
end

------------------------------------------------------------------------
-- ATTACK (1.1 s): pitchfork jab
------------------------------------------------------------------------
local ATK_LEN = 1.1
local function attack(t, pose, ctx)
	local q = Q()
	local cock = track(t, { { 0, 0 }, { 0.38, 1, "cubicOut" }, { 0.42, 1 }, { 0.5, 0, "quadIn" } })
	local thrust = track(t, { { 0.4, 0 }, { 0.5, 1, "quadIn" }, { 0.72, 1 }, { 1.05, 0, "cubicInOut" } })
	local impact = env(t, 0.5, 0.03, 0.06, 0.35, "linear", "elasticOut")
	local shake = env(t, 0.5, 0.02, 0.2, 0.1)
	local stepL = track(t, { { 0.32, 0 }, { 0.5, 1, "quadOut" }, { 0.78, 1 }, { 1.02, 0, "sineInOut" } })
	local liftL = env(t, 0.28, 0.12, 0.0, 0.1, "quadOut", "quadIn") + env(t, 0.8, 0.1, 0.0, 0.12, "quadOut", "quadIn")
	local vib = shake * wave(t, 22)

	q.hipZ = 0.45 * cock - 1.1 * thrust
	q.hipY = -0.3 * cock - 0.55 * thrust - 0.2 * impact
	q.hipP = 6 * cock - 18 * thrust
	q.hipYaw = -22 * cock + 18 * thrust
	q.chestP = 6 * cock - 10 * thrust + 2 * vib
	q.chestY = -12 * cock + 10 * thrust
	q.footL = V(0, 0.55 * liftL, -1.5 * stepL)
	q.toeL = -15 * liftL
	q.footR = V(0, 0, 0)
	q.armR = V(-30 * cock + 88 * thrust + 3 * vib, 0, 22 * cock + 6 * thrust)
	q.foreR = V(75 * cock + 4 * thrust, 0, 0)
	q.armL = V(45 * cock - 25 * thrust, 0, 25 * cock + 50 * thrust)
	q.foreL = V(30 * cock + 30 * thrust, 0, 0)
	q.handL = V(0, 0, -30 * thrust)
	q.headP = 10 * cock - 10 * thrust + 4 * vib
	q.headY = -10 * cock + 8 * thrust
	q.headR = 6 * vib
	q.jaw = 4 - 2 * cock + 48 * thrust + 10 * impact
	q.lid = 0.45 * cock
	q.browAng = 18 * cock + 26 * thrust
	q.eyePop = 0.7 * impact
	q.eyeGlow = 0.6 * cock + 1.0 * impact + 0.3 * thrust
	q.mouthGlow = thrust
	q.angry = thrust > 0.3
	q.forkW = ang(-88 + 4 * vib, 0, 0)
	q.forkK = clamp(math.max(cock, thrust) * 1.4, 0, 1)
	q.forkSlide = -0.5 * cock + 1.1 * thrust
	q.hatP = -8 * cock + 12 * thrust
	q.hatUp = 0.3 * impact
	q.flop = 1 + 2 * shake
	q.flopHz = 3
	q.orbOut = 0.9 * impact
	q.forkLight = 1.5 * impact

	apply(pose, ctx, q, t)

	if ctx.crossed(0.5) then
		ctx.emit("ForkSpark", 34)
		ctx.emit("DustL", 14)
		ctx.emit("StrawBurst", 12)
		ctx.emit("EyeEmbers", 10)
	end
end

------------------------------------------------------------------------
-- CATCH (2.0 s): hat-spin jig
------------------------------------------------------------------------
local CATCH_LEN = 2.0
local KICKS = { 0.32, 0.64, 0.96, 1.28 }
local function catch(t, pose, ctx)
	local q = Q()
	local prep = env(t, 0, 0.18, 0.0, 0.14, "quadOut", "quadIn")
	local jig = track(t, { { 0.15, 0 }, { 0.3, 1, "quadOut" }, { 1.5, 1 }, { 1.7, 0, "quadIn" } })
	local hatY = track(t, { { 0.18, 0 }, { 0.55, 2.2, "quadOut" }, { 1.25, 2.4 }, { 1.62, 0, "quadIn" } })
	local hatSpin = track(t, { { 0.18, 0 }, { 1.62, 1440, "sineInOut" } })
	local landHat = env(t, 1.62, 0.04, 0.05, 0.3, "quadOut", "backOut")
	local proud = env(t, 1.6, 0.12, 0.12, 0.25, "backOut", "sineInOut")

	-- kick beat: which foot kicks and how much
	local beat = (t - 0.16) / 0.32
	local bi = floor(beat)
	local bf = beat - bi
	local kickAmt = (t > 0.16 and t < 1.45) and sin(pi * clamp(bf, 0, 1)) or 0
	local right = bi % 2 == 0
	local kR = right and kickAmt or 0
	local kL = right and 0 or kickAmt
	local bounce = abs(sin(pi * clamp(bf, 0, 1))) * jig

	q.hipY = -0.35 * prep + 0.3 * bounce - 0.2 * landHat
	q.hipR = (right and -1 or 1) * 7 * kickAmt * jig
	q.hipYaw = 14 * wave(t, 1 / 0.64) * jig
	q.footR = V(0.55 * kR, 0.85 * kR, -0.35 * kR) * jig
	q.footL = V(-0.55 * kL, 0.85 * kL, -0.35 * kL) * jig
	q.toeR = 25 * kR * jig
	q.toeL = 25 * kL * jig
	q.chestR = (right and 1 or -1) * 8 * kickAmt * jig
	q.chestP = 4 * jig + 6 * proud
	-- arms: left elbow-flapping "hand on hip", right pumps the fork
	q.armL = V(10, 0, 50 + 25 * wave(t, 1 / 0.32)) * jig + V(0, 0, 60) * proud
	q.foreL = V(80, 40, 0) * jig
	q.armR = V(25 + 40 * (0.5 + 0.5 * wave(t, 1 / 0.32, 0.25)), 0, 20) * jig + V(60, 0, 40) * proud
	q.foreR = V(20, 0, 0) * jig
	-- head bobbing side to side, cackling, eyes squeezed happy
	q.headR = 16 * wave(t, 1 / 0.64) * jig
	q.headP = 10 * jig - 6 * prep + 10 * proud
	q.headY = 8 * wave(t, 1 / 0.64, 0.25) * jig
	q.jaw = 6 + (14 + 22 * (0.5 + 0.5 * wave(t, 1 / 0.16))) * jig + 25 * proud
	q.lid = 0.5 * jig + 0.4 * proud
	q.browUp = 0.12 * jig
	q.browAng = -10 * jig
	q.mouthGlow = 0.5 * jig
	q.eyeGlow = 0.4 * jig
	-- the hat spins up above the head and drops back on
	q.hatUp = hatY - 0.15 * landHat
	q.hatSpin = hatSpin
	q.hatR = 12 * wave(t, 1.5) * (hatY / 2.4)
	q.flop = 1.5 + 2 * jig
	q.flopHz = 1 / 0.16
	q.orbOut = 0.6 * jig
	q.forkW = ang(0, 0, -10)
	q.forkK = jig

	apply(pose, ctx, q, t)

	for _, k in KICKS do
		if ctx.crossed(k) then
			ctx.emit("Sparkle", 6)
			ctx.emit(((k / 0.32) % 2 == 1) and "DustL" or "DustR", 5)
		end
	end
	if ctx.crossed(1.63) then
		ctx.emit("StrawBurst", 18)
		ctx.emit("Sparkle", 14)
	end
end

------------------------------------------------------------------------
-- GIVE UP (2.6 s): collapse into a heap, pop back up, stomp, calm down
------------------------------------------------------------------------
local GU_LEN = 2.6
local function giveUp(t, pose, ctx)
	local q = Q()
	local shock = env(t, 0, 0.08, 0.15, 0.1, "backOut", "quadIn")
	local heap = track(t, { { 0.3, 0 }, { 0.72, 1, "quadIn" }, { 0.8, 0.94, "quadOut" }, { 1.45, 1 }, { 1.68, 0, "backIn" } })
	local popUp = env(t, 1.55, 0.15, 0.05, 0.3, "quadOut", "backOut")
	local slump = env(t, 0.72, 0.08, 0.6, 0.25, "backOut", "quadInOut")
	local tantrum = track(t, { { 1.7, 0 }, { 1.8, 1, "quadOut" }, { 2.3, 1 }, { 2.6, 0, "sineInOut" } })
	local liftR = env(t, 1.78, 0.14, 0.02, 0.05, "quadOut", "quadIn")
	local liftL = env(t, 2.04, 0.14, 0.02, 0.05, "quadOut", "quadIn")
	local slamR = env(t, 1.99, 0.03, 0.04, 0.2, "linear", "backOut")
	local slamL = env(t, 2.25, 0.03, 0.04, 0.2, "linear", "backOut")
	local breath = wave(t, 1.6) * slump

	-- collapse: hips sink to the floor, legs splay out forward
	q.hipY = 0.15 * shock - 2.25 * heap + 0.06 * breath + 0.55 * popUp - 0.25 * (slamR + slamL)
	q.hipP = 12 * heap - 6 * tantrum
	q.hipR = -6 * heap
	q.footR = V(0.45, 0, -1.25) * heap + V(0, 1.0 * liftR, -0.2 * liftR)
	q.footL = V(-0.45, 0, -1.0) * heap + V(0, 1.0 * liftL, -0.2 * liftL)
	q.footR = q.footR + V(0, 0.45 * popUp, 0)
	q.footL = q.footL + V(0, 0.45 * popUp, 0)
	q.toeR = 30 * heap - 10 * liftR
	q.toeL = 25 * heap - 10 * liftL
	q.chestP = -6 * shock - 38 * heap + 3 * breath + 12 * popUp - 8 * tantrum
	q.chestR = 10 * heap
	-- arms flop out to the sides on the ground, fist shaking in the tantrum
	q.armR = V(-6 * shock, 0, 30 * heap + 60 * popUp) + V(25, 0, 15) * tantrum
	q.foreR = V(0, 0, -20 * heap) + V(20, 0, 0) * tantrum
	q.handR = V(0, 0, -25 * heap)
	local shakeFist = tantrum * wave(t, 12)
	q.armL = V(-6 * shock, 0, 42 * heap + 70 * popUp) + V(105, 0, 20) * tantrum + V(8 * shakeFist, 0, 0)
	q.foreL = V(0, 0, -25 * heap) + V(70 + 15 * shakeFist, 0, 0) * tantrum
	q.handL = V(0, 0, -30 * heap)
	-- head: shocked jerk back, then droops to the side, hat slides over the eyes
	q.headP = 14 * shock - 26 * heap + 18 * popUp - 10 * tantrum
	q.headR = 30 * heap + 4 * breath + 10 * tantrum * wave(t, 7)
	q.headY = 15 * heap
	q.jaw = 22 * shock + 10 * heap + 30 * popUp + (12 + 14 * (0.5 + 0.5 * wave(t, 10))) * tantrum
	q.eyePop = 0.8 * shock + 0.5 * popUp
	q.eyeGlow = 0.6 * shock - 0.35 * slump + 0.6 * tantrum
	q.browUp = 0.2 * shock + 0.05 * slump
	q.browAng = -20 * shock - 22 * heap + 34 * tantrum
	q.lid = 0.62 * slump
	q.mouthGlow = 0.6 * tantrum
	q.angry = t > 1.75 and t < 2.45
	q.hatP = -24 * heap
	q.hatUp = -0.28 * heap + 1.0 * popUp
	q.hatZ = -0.25 * heap
	q.hatSpin = 90 * popUp
	q.brimDroop = 8 * heap
	q.flop = 1 + 2 * tantrum + 2 * popUp
	q.flopHz = 3
	q.orbOut = -0.6 * heap + 1.0 * popUp
	-- the pitchfork drops flat beside it
	q.forkW = ang(-90, 25, 0)
	q.forkK = heap
	q.forkLight = 0.6 * (slamR + slamL)

	apply(pose, ctx, q, t)

	if ctx.crossed(0.74) then
		ctx.emit("StrawBurst", 50)
		ctx.emit("DustR", 16)
		ctx.emit("DustL", 16)
	end
	if ctx.crossed(1.1) then
		ctx.emit("StrawBurst", 6)
	end
	if ctx.crossed(1.58) then
		ctx.emit("StrawBurst", 26)
		ctx.emit("Sparkle", 8)
	end
	if ctx.crossed(2.0) then
		ctx.emit("DustR", 16)
		ctx.emit("StrawBurst", 8)
	end
	if ctx.crossed(2.26) then
		ctx.emit("DustL", 16)
		ctx.emit("StrawBurst", 8)
	end
end

------------------------------------------------------------------------
-- RETURN (1.2 s loop): loose limp-swing trudge home
------------------------------------------------------------------------
local WALK_T, WALK_DUTY, WALK_D, WALK_H = 1.2, 0.58, 2.6, 0.55
local WALK_SPEED = WALK_D / (WALK_DUTY * WALK_T)

local function returnHome(t, pose, ctx)
	local q = Q()
	local p = (t / WALK_T) % 1
	local zR, yR, toeR = stride(p, WALK_DUTY, WALK_D, WALK_H)
	local zL, yL, toeL = stride((p + 0.5) % 1, WALK_DUTY, WALK_D, WALK_H)
	local w = 2 * pi * p
	local bob = cos(2 * w - 0.6)
	q.hipY = -0.12 - 0.14 * bob
	q.hipP = -5
	q.hipYaw = 9 * sin(w)
	q.hipR = 7 * sin(w + 0.9) -- big loose waddle
	q.footR = V(0.05, yR, zR)
	q.footL = V(-0.05, yL, zL)
	q.toeR, q.toeL = toeR * 0.7, toeL * 0.7
	q.chestP = -9 + 2 * bob
	q.chestY = -10 * sin(w)
	q.chestR = -5 * sin(w + 0.5)
	-- head hangs low, bobbing and lolling with lag, grumbling
	q.headP = -12 - 5 * cos(2 * w - 1.4)
	q.headR = 12 * sin(w - 0.8)
	q.headY = -6 * sin(w - 1.2)
	q.jaw = 6 + 6 * (0.5 + 0.5 * wave(t, 5 / WALK_T))
	q.browAng = 16
	q.browUp = -0.05
	q.lid = 0.35
	-- left arm dangles and swings like a rope, right shoulders the fork
	q.armL = V(-30 * sin(w - 0.4), 0, 8 + 6 * sin(w + 1))
	q.foreL = V(-14 - 22 * (0.5 + 0.5 * sin(w - 1.4)), 0, 0)
	q.handL = V(-25 * sin(w - 2.0), 0, -10)
	q.armR = V(38 + 4 * bob, 0, 12)
	q.foreR = V(105, 0, 0)
	q.forkW = ang(58, 0, -14) * ang(0, 0, 4 * sin(w))
	q.forkK = 1
	q.forkSlide = -0.6
	q.hatP = -6
	q.flop = 1.6
	q.flopHz = 2 / WALK_T

	apply(pose, ctx, q, t)

	if ctx.crossed(0.01) then
		ctx.emit("DustR", 3)
	end
	if ctx.crossed(0.5 * WALK_T + 0.01) then
		ctx.emit("DustL", 3)
	end
end

M.States = {
	Idle = { Loop = true, Length = IDLE_LEN, Update = idle },
	Alert = { Length = ALERT_LEN, Update = alert },
	Chase = { Loop = true, Length = RUN_T, Speed = RUN_SPEED, Update = chase },
	Attack = { Length = ATK_LEN, Update = attack },
	Catch = { Length = CATCH_LEN, Update = catch },
	GiveUp = { Length = GU_LEN, Update = giveUp },
	Return = { Loop = true, Length = WALK_T, Speed = WALK_SPEED, Update = returnHome },
}
M.Base = "Idle"
M.Reel = { { "Idle" }, { "Alert" }, { "Chase", 3.6 }, { "Attack" }, { "Catch" }, { "Chase", 1.8 }, { "GiveUp" }, { "Return", 3.6 } }
return L.states(M)
