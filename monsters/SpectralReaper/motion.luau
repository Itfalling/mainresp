--!nocheck
-- Spectral Reaper motion: spooky-goofy float (bob, rippling hem "flames",
-- head tilts, chattering grin, swinging soul lantern, blinking) then the
-- SOUL HARVEST: crouch -> rise with the scythe raised overhead and a twist
-- back (anticipation) -> full 360 spinning sweep with arms out and a mint
-- slash ring drawn behind the blade -> overshoot -> soul burst + cackling
-- dramatic pose -> drop back down with a squash and an elastic settle.
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 8

-- hem strip positions (x, z) around the robe -> phase for the travelling ripple
local HEMS = {
	{ -2.4, -2.35 }, { -0.8, -2.35 }, { 0.8, -2.35 }, { 2.4, -2.35 },
	{ 3.15, -1.55 }, { 3.15, 0.1 }, { 3.15, 1.75 },
	{ 2.4, 2.55 }, { 0.8, 2.55 }, { -0.8, 2.55 }, { -2.4, 2.55 },
	{ -3.15, 1.75 }, { -3.15, 0.1 }, { -3.15, -1.55 },
}
local HEM_PHASE = {}
for i, h in HEMS do
	HEM_PHASE[i] = math.atan2(h[1], -h[2]) / (2 * math.pi)
end

-- floating cubes (x, z) relative to the Orbit pivot, for the outward fling
local ORBS = { { 8.6, 1.5 }, { -8.2, 2.5 }, { 5.5, 6.8 }, { -6.4, -4.6 }, { 5.6, 4.2 } }
-- resting tilt of the scythe (top leans out, away from the face)
local SC_REST = CFrame.Angles(0, 0, math.rad(-8))

local SLASH_N = 18
local SPIN_FROM, SPIN_TO = -45, 380
local BLADE_OFF = 25

-- orientation whose +Y (snath) points along s and +X (blade) along b
local function orient(s, b)
	s = s.Unit
	b = (b - s * b:Dot(s)).Unit
	return CFrame.fromMatrix(Vector3.new(), b, s, b:Cross(s))
end
-- scythe targets in chest space
local SC_UP = orient(Vector3.new(0.3, 1, 0.35), Vector3.new(1, -0.1, -0.2))
local SC_SWEEP = orient(Vector3.new(1, -0.12, 0), Vector3.new(0, -0.5, -1))
local SC_POSE = orient(Vector3.new(0.8, 1, -0.1), Vector3.new(1, -0.6, 0))

-- shortest-arc rotation taking direction a onto direction b
local function aim(a, b)
	a, b = a.Unit, b.Unit
	local axis = a:Cross(b)
	local s = axis.Magnitude
	if s < 1e-5 then
		return CFrame.new()
	end
	return CFrame.fromAxisAngle(axis / s, math.atan2(s, a:Dot(b)))
end
-- rest directions of the (right) upper arm and forearm, chest space
local UA = Vector3.new(1.5, -2.4, -0.6)
local FA = Vector3.new(0.6, -1.3, -3.4)
local function armPose(dU, dF)
	if not dU then
		return CFrame.new(), CFrame.new()
	end
	local ra = aim(UA, dU)
	return ra, aim(FA, ra:Inverse() * dF)
end
local function poses(list)
	local arms, fores = {}, {}
	for i, p in list do
		arms[i], fores[i] = armPose(p[1], p[2])
	end
	return arms, fores
end
-- rest, wind-up, sweep, finale
local ARM_R, FORE_R = poses({
	{},
	{ Vector3.new(0.75, 0.65, -0.1), Vector3.new(0.35, 1, -0.15) },
	{ Vector3.new(1, 0.08, -0.1), Vector3.new(1, 0.05, -0.25) },
	{ Vector3.new(0.75, 0.55, -0.2), Vector3.new(0.4, 1, -0.3) },
})
-- left arm in right-side terms (mirrored when applied)
local ARM_L, FORE_L = poses({
	{},
	{ Vector3.new(0.75, -0.1, 0.65), Vector3.new(0.55, 0.35, 0.75) },
	{ Vector3.new(1, 0.08, 0.05), Vector3.new(1, 0.1, 0) },
	{ Vector3.new(0.35, 0.35, -0.85), Vector3.new(0.25, 0.75, -0.6) },
})

local function rot(cf)
	return cf.Rotation
end

local function yawAt(c)
	return L.track(c, {
		{ 0, 0 },
		{ 2.7, 0 },
		{ 3.6, SPIN_FROM, "backOut" },
		{ 4.4, SPIN_FROM },
		{ 5.35, SPIN_TO, "quadInOut" },
		{ 5.8, 360, "sineInOut" },
	})
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- signature move envelopes ------------------------------------------
	local dip = L.env(c, 2.45, 0.3, 0.0, 0.3, "quadOut", "quadIn")
	local windup = L.env(c, 2.7, 0.9, 0.75, 0.3, "backOut", "cubicIn")
	local spinW = L.env(c, 4.35, 0.25, 0.65, 0.35, "cubicOut", "quadInOut")
	local finale = L.env(c, 5.3, 0.3, 1.0, 0.75, "backOut", "cubicInOut")
	local cackle = L.env(c, 5.4, 0.15, 1.1, 0.4, "backOut", "quadIn")
	local land = L.env(c, 7.0, 0.2, 0.0, 0.8, "quadIn", "elasticOut")
	local shake = L.env(c, 3.6, 0.1, 0.7, 0.1)
	local move = math.min(1, math.max(windup, spinW, finale))
	local idleW = 1 - move

	local yaw = yawAt(c)
	local spinSpeed = math.clamp(math.abs(yawAt(c + 0.03) - yawAt(c - 0.03)) / 0.06 / 700, 0, 1)

	-- idle drivers ------------------------------------------------------
	local bobW = wave(t, 0.4)
	local sway = wave(t, 0.4, 0.25)
	local breathe = wave(t, 0.4, 0.1)

	-- BODY: float bob, rise on the wind-up, spin, pop up, squash on landing
	local twirlHop = math.sin(math.pi * L.remap(c, 4.4, 5.35)) * 0.9
	local bodyY = 0.85 * bobW * (1 - 0.6 * move) + twirlHop - 0.8 * dip + 1.6 * windup + 0.3 * spinW + 1.4 * finale - 1.3 * land
	local lean = -6 * dip + 9 * windup - 4 * spinW + 7 * finale + 5 * land
	local roll = 4 * sway * idleW + 2 * shake * wave(t, 11)
	pose.Body = CFrame.new(0, bodyY, 0) * ang(0, yaw, 0) * ang(lean, 0, roll)

	-- CHEST: breathing, extra twist on the wind-up, leads the spin
	pose.Chest = ang(2 * breathe + 6 * windup - 3 * spinW + 6 * finale, 4 * sway * idleW - 15 * windup + 12 * spinW, -2 * sway * idleW)

	-- HEAD: curious tilts + looking around, looks up at the scythe, thrown back cackling
	local look = L.noise(t, 3.3, 0.3) * 22 * idleW
	local tilt = 13 * wave(t, 0.3, 0.1) * idleW
	local laughShake = cackle * wave(t, 6)
	pose.Head = ang(-4 * bobW * idleW + 16 * windup - 5 * spinW + 22 * cackle + 5 * laughShake, look - 18 * windup, tilt + 9 * laughShake + 4 * shake * wave(t, 9))

	-- JAW: occasional teeth chatter, flung open while cackling
	local chatterWin = L.env(t % 4.3, 1.4, 0.08, 0.5, 0.12) * idleW
	local chatter = chatterWin * (0.5 + 0.5 * wave(t, 8))
	local open = 0.35 * chatter + 0.35 * windup + 1.35 * cackle * (0.8 + 0.2 * wave(t, 6, 0.25))
	pose.Jaw = pa(0, -open, -0.15 * open, -8 * cackle, 0, 0)
	ctx.transparency("MouthGlow", 1 - 0.8 * math.max(cackle, 0.5 * windup))

	-- EYES: cartoon blinks, evil squint while laughing
	local blink = L.env(t % 3.1, 2.7, 0.06, 0.06, 0.1)
	local lid = -1.65 * math.max(blink * (1 - cackle), 0.42 * cackle)
	L.both(pose, "Lid", CFrame.new(0, lid, 0))

	-- ARMS -------------------------------------------------------------
	-- each arm blends rest -> wind-up -> sweep -> finale (aimed rotations, slerped)
	local sw = 5 * sway * idleW
	local armR = ARM_R[1]:Lerp(ARM_R[2], windup):Lerp(ARM_R[3], spinW):Lerp(ARM_R[4], finale)
	local foreR = FORE_R[1]:Lerp(FORE_R[2], windup):Lerp(FORE_R[3], spinW):Lerp(FORE_R[4], finale)
	armR = ang(sw, 0, 0.6 * sw + 6 * shake * wave(t, 7)) * armR
	foreR = ang(4 * breathe * idleW, 0, 0) * foreR
	local handR = ang(0, 0, 0)
	pose.ArmR, pose.ForeR, pose.HandR = armR, foreR, handR

	-- left arm (lantern), authored in right-side terms then mirrored
	local armL = ARM_L[1]:Lerp(ARM_L[2], windup):Lerp(ARM_L[3], spinW):Lerp(ARM_L[4], finale)
	local foreL = FORE_L[1]:Lerp(FORE_L[2], windup):Lerp(FORE_L[3], spinW):Lerp(FORE_L[4], finale)
	armL = ang(-sw, 0, 0.6 * sw) * armL
	foreL = ang(-4 * breathe * idleW, 0, 0) * foreL
	pose.ArmL = L.mirror(armL)
	pose.ForeL = L.mirror(foreL)
	pose.HandL = CFrame.new()

	-- SCYTHE: orientation is authored in chest space, then the arm chain is undone
	local target = SC_REST:Lerp(SC_UP, windup)
	target = target:Lerp(SC_SWEEP, spinW)
	target = target:Lerp(SC_POSE, finale)
	target = ang(3 * sway * idleW, 0, -3 * sway * idleW + 3 * shake * wave(t, 10)) * target
	pose.Scythe = rot(armR * foreR * handR):Inverse() * target

	-- LANTERN: hangs with gravity, swings like a pendulum, flung out by the spin
	local swingX = 12 * wave(t, 0.8, 0.3) * idleW + 25 * spinW * spinSpeed - 20 * finale
	local swingZ = 7 * wave(t, 0.55) * idleW + 55 * spinW
	local worldL = ang(0, yaw, 0) * L.mirror(ang(swingX, 0, swingZ))
	local chainL = rot(pose.Body) * rot(pose.Chest) * rot(pose.ArmL) * rot(pose.ForeL) * rot(pose.HandL)
	pose.Lantern = chainL:Inverse() * worldL

	-- BELT CHAIN: gravity + lagging swing
	local chainSwing = ang(10 * wave(t, 0.7, 0.4) + 35 * spinW, 0, 6 * wave(t, 0.5) - 40 * spinW)
	pose.ChainA = rot(pose.Body):Inverse() * ang(0, yaw, 0) * chainSwing
	pose.ChainB = ang(14 * wave(t, 0.7, 0.2) + 15 * spinW, 0, 8 * wave(t, 0.5, -0.2))

	-- CAPE: flutters behind, streams back during the spin
	pose.Cape = ang(-4 - 5 * wave(t, 0.6, 0.2) * idleW + 8 * windup - 38 * spinW - 18 * finale - 12 * land, 0, 3 * wave(t, 0.45) * idleW - 8 * spinSpeed)
	pose.Cape2 = ang(-6 - 9 * wave(t, 0.6, 0.0) * idleW + 6 * windup - 25 * spinW - 12 * finale - 15 * land, 0, 4 * wave(t, 0.45, -0.15) * idleW - 6 * spinSpeed)

	-- SOUL GEM: heartbeat wiggle
	local beat = math.max(0, wave(t, 1.1)) ^ 6
	pose.Soul = pa(0, 0.05 * beat, -0.12 * beat, 0, 0, 25 * beat)

	-- HEM STRIPS: flame-like ripple travelling around the robe; flare out on the spin
	local flare = 52 * spinW + 28 * finale + 40 * land - 10 * windup + 6 * dip
	local trailing = 32 * spinSpeed
	for i = 1, #HEMS do
		local ph = HEM_PHASE[i]
		local rip = wave(t, 0.9, -2 * ph)
		local rip2 = wave(t, 0.9, -2 * ph - 0.18)
		local side = 7 * wave(t, 0.55, ph)
		local flick = 5 * wave(t, 2.3, 3 * ph)
		pose["HemA" .. i] = ang(12 + 3 * breathe + 11 * rip + flare, 0, side + trailing)
		pose["HemB" .. i] = ang(8 + 20 * rip2 + flick + 0.5 * flare, 0, 1.3 * side + 0.6 * trailing - flick)
	end

	-- FLOATING CUBES: orbit (swept along by the spin), bob, tumble, flung outward
	pose.Orbit = ang(0, 28 * t + yaw, 0)
	for i, o in ORBS do
		local r = math.sqrt(o[1] * o[1] + o[2] * o[2])
		local out = 2.6 * spinW + 1.2 * finale
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(o[1] / r * out, 0.8 * wave(t, 0.5, i * 0.21) + 0.4 * out, o[2] / r * out, 60 * t * dir, 85 * t + i * 40, 25 + 20 * i)
	end

	-- SLASH RING: segments light up as the blade passes them, then fade
	pose.Slash = pa(0, bodyY, 0, 0, 0, 0)
	local fade = L.remap(c, 5.35, 6.0)
	for k = 1, SLASH_N do
		local tr = 1
		if c > 4.4 and c < 6.0 then
			local a = (k - 1) * 360 / SLASH_N
			local blade = yaw + BLADE_OFF
			local age = (blade - a) % 360
			if blade - age >= SPIN_FROM + BLADE_OFF then
				tr = 0.4 + 0.55 * (age / 360)
			end
			tr = tr + (1 - tr) * fade
		end
		ctx.transparency("Slash" .. k, tr)
	end

	-- EFFECTS ------------------------------------------------------------
	ctx.enable("BladeSparks", c > 4.45 and c < 5.4)
	ctx.enable("SpinMist", c > 4.5 and c < 5.45)
	ctx.light("SoulLight", 1.5 * L.env(c, 5.3, 0.08, 0.25, 0.6))
	ctx.light("LanternLight", 0.8 + 0.15 * wave(t, 3.3) + 0.4 * finale)
	if ctx.crossed(3.62) then
		ctx.emit("SoulBurst", 18)
	end
	if ctx.crossed(5.36) then
		ctx.emit("SoulBurst", 70)
	end
	if ctx.crossed(7.15) then
		ctx.emit("LandDust", 26)
	end
end

return M
