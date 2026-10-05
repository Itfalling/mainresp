--!nocheck
-- Magma Crab motion
-- IDLE: bouncy sideways shuffle in place (tripod leg steps, feet stay planted),
--   claws pump like a boxer and clack in bursts, eye stalks wobble with lag,
--   cartoon blinks, mandibles chew, vents puff.
-- SIGNATURE "ERUPTION": crouch + rumble (anticipation) -> vents ERUPT (fire,
--   embers, smoke) as the crab rears back roaring with claws flung up ->
--   claws SLAM together overhead (clap burst) -> squash -> big JUMP ->
--   GROUND POUND landing (claws smash down, dust) -> elastic settle with
--   wobbling eye stalks and a dazed double blink.
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave
local rad, deg = math.rad, math.deg

local M = {}
M.Cycle = 8

-- Crab legs (right side, model rest coords): hip, knee, foot tip. Legs are
-- driven by planar 2-bone IK about the Z axis so the feet stay planted while
-- the body shuffles, crouches, rears and squashes.
local V = Vector3.new
local LEGS = {
	{ h = V(5.4, 4.4, -0.6), k = V(7.8, 6.6, -1.4), f = V(10.0, 0.1, -2.4) },
	{ h = V(5.4, 4.4, 1.4), k = V(8.0, 6.8, 1.6), f = V(10.3, 0.1, 1.9) },
	{ h = V(5.4, 4.4, 3.4), k = V(7.6, 6.5, 4.4), f = V(9.7, 0.1, 5.8) },
}
for _, g in LEGS do
	g.l1 = math.sqrt((g.k.X - g.h.X) ^ 2 + (g.k.Y - g.h.Y) ^ 2)
	g.l2 = math.sqrt((g.f.X - g.k.X) ^ 2 + (g.f.Y - g.k.Y) ^ 2)
	g.a1 = math.atan2(g.k.Y - g.h.Y, g.k.X - g.h.X)
	g.a2 = math.atan2(g.f.Y - g.k.Y, g.f.X - g.k.X)
end
-- returns hip/knee Z rotations (deg) that put the foot tip at (tx, ty)
local function legIK(g, tx, ty)
	local dx, dy = tx - g.h.X, ty - g.h.Y
	local d = math.clamp(math.sqrt(dx * dx + dy * dy), math.abs(g.l1 - g.l2) + 0.05, g.l1 + g.l2 - 0.05)
	local cosA = math.clamp((g.l1 * g.l1 + d * d - g.l2 * g.l2) / (2 * g.l1 * d), -1, 1)
	local th1 = math.atan2(dy, dx) + math.acos(cosA)
	local kx, ky = g.h.X + g.l1 * math.cos(th1), g.h.Y + g.l1 * math.sin(th1)
	local th2 = math.atan2(ty - ky, tx - kx)
	local A = th1 - g.a1
	return deg(A), deg(th2 - g.a2 - A)
end
local BODY_PIVOT = CFrame.new(0, 4.8, 0.5)

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	--------------------------------------------------------------------
	-- signature move envelopes
	--------------------------------------------------------------------
	local crouch = L.env(c, 2.6, 0.6, 0.42, 0.2, "cubicOut", "expoIn") -- anticipation
	local rumble = L.env(c, 2.7, 0.4, 0.55, 0.15)
	local erupt = L.env(c, 3.62, 0.14, 0.75, 0.45, "backOut", "cubicInOut") -- rear back + roar
	local fire = L.env(c, 3.62, 0.1, 1.2, 0.4)
	local preJump = L.env(c, 4.35, 0.12, 0.04, 0.1, "quadOut", "quadIn")
	local jumpY = L.track(c, {
		{ 4.55, 0 },
		{ 4.98, 4.2, "cubicOut" }, -- big jump
		{ 5.38, 0, "quadIn" }, -- GROUND POUND
		{ 5.62, 1.3, "cubicOut" }, -- rubbery rebound hop
		{ 5.86, 0, "quadIn" },
	})
	local air = math.max(L.env(c, 4.5, 0.15, 0.6, 0.15), 0.6 * L.env(c, 5.42, 0.08, 0.26, 0.1))
	local hop = L.env(c, 5.4, 0.22, 0, 0.24, "cubicOut", "quadIn")
	local impact = math.max(L.env(c, 5.38, 0.04, 0.03, 0.2, "linear", "quadOut"), 0.75 * L.env(c, 5.86, 0.04, 0.06, 0.9, "linear", "elasticOut"))
	local dazed = L.env(c, 5.9, 0.1, 0.5, 0.6)
	local special = L.env(c, 2.5, 0.3, 4.0, 0.8)
	local idleW = 1 - special

	--------------------------------------------------------------------
	-- idle shuffle
	--------------------------------------------------------------------
	local sx = 1.1 * wave(t, 0.5) * idleW -- sideways sway (2 s period)
	local bob = L.bounce(t, 2) * idleW -- a bounce per step
	local lift1 = math.max(0, wave(t, 1)) ^ 1.5 * idleW -- tripod 1R 2L 3R
	local lift2 = math.max(0, -wave(t, 1)) ^ 1.5 * idleW -- tripod 1L 2R 3L
	local breathe = wave(t, 0.6)

	--------------------------------------------------------------------
	-- BODY
	--------------------------------------------------------------------
	local tremble = rumble * 0.12 * wave(t, 13)
	local groundY = 0.35 * bob - 0.15 + 0.06 * breathe - 1.5 * crouch + 0.4 * erupt * (1 - air) - 1.0 * preJump - 1.8 * impact
	local bodyY = groundY + jumpY
	local pitchMove = L.track(c, {
		{ 2.6, 0 },
		{ 3.2, -9, "cubicOut" }, -- crouch: lean in
		{ 3.62, -9 },
		{ 3.8, 16, "backOut" }, -- ERUPT: rear back roaring
		{ 4.24, 18 },
		{ 4.34, -5, "expoIn" }, -- slam forward with the clap
		{ 4.5, -4 },
		{ 4.85, 9, "cubicOut" }, -- airborne, belly up
		{ 5.25, 4 },
		{ 5.38, -8, "quadIn" }, -- nose-first landing
		{ 5.62, 5, "quadOut" }, -- rebound
		{ 5.86, -5, "quadIn" },
		{ 6.1, 0, "quadOut" },
	})
	local pitch = 2 * breathe * idleW + pitchMove - 6 * impact + 40 * tremble
	local roll = -4 * wave(t, 0.5, 0.25) * idleW + 3 * wave(t, 1) * idleW + 30 * tremble
	local yaw = 6 * wave(t, 0.5) * idleW + 8 * L.noise(t, 2.2, 0.3) * idleW
	local bodyCF = pa(sx + 1.5 * tremble, bodyY, 0, pitch, yaw, roll)
	pose.Body = bodyCF

	--------------------------------------------------------------------
	-- LEGS: planted feet via IK + tripod steps + dangling in the air
	--------------------------------------------------------------------
	local toBody = BODY_PIVOT * bodyCF:Inverse() * BODY_PIVOT:Inverse() -- world -> rest body coords
	for i, g in LEGS do
		for _, side in { "R", "L" } do
			local s = side == "R" and 1 or -1
			local lift = ((i == 2) == (side == "R")) and lift2 or lift1
			local foot = toBody * V(s * g.f.X, g.f.Y + jumpY, g.f.Z)
			local tx = s * foot.X + 0.4 * lift + 0.5 * impact
			local ty = foot.Y + 1.3 * lift
			local hipA, kneeA = legIK(g, tx, ty)
			local kick = wave(t, 3, i * 0.21 + (side == "R" and 0 or 0.5))
			local fwd = (i - 2) * 8 * air
			local A = ang(0, fwd, hipA + air * (-18 + 8 * kick))
			local Bk = ang(0, 0, kneeA + air * (-28 - 10 * kick))
			local C = ang(0, 0, 10 * lift - 14 * air)
			if side == "R" then
				pose["Leg" .. i .. "AR"], pose["Leg" .. i .. "BR"], pose["Leg" .. i .. "CR"] = A, Bk, C
			else
				pose["Leg" .. i .. "AL"], pose["Leg" .. i .. "BL"], pose["Leg" .. i .. "CL"] = L.mirror(A), L.mirror(Bk), L.mirror(C)
			end
		end
	end

	--------------------------------------------------------------------
	-- CLAWS
	--------------------------------------------------------------------
	-- idle boxer pump (alternating) + gentle sway
	local pumpR = wave(t, 1, 0.1) * idleW
	local pumpL = wave(t, 1, 0.6) * idleW
	-- keyframes (right-side convention; the left claw is smaller so it gets its
	-- own track that still meets the big claw overhead)
	local T_REST, T_TUCK, T_TUCK2, T_WIDE, T_WIDE2, T_CLAP, T_PRESS, T_HOLD, T_HOLD2, T_SMASH, T_DOWN, T_BACK =
		2.6, 3.2, 3.62, 3.95, 4.24, 4.34, 4.42, 4.55, 5.12, 5.38, 5.9, 6.7
	local function armTrack(tuck, wide, wide2, clap, press, smash, hold)
		return {
			{ T_REST, { 0, 0, 0 } },
			{ T_TUCK, tuck, "cubicOut" }, -- guard low in front of the face (anticipation)
			{ T_TUCK2, tuck },
			{ T_WIDE, wide, "backOut" }, -- flung up overhead, wide apart
			{ T_WIDE2, wide2 }, -- a little extra spread (wind-up for the clap)
			{ T_CLAP, clap, "expoIn" }, -- SLAM together overhead
			{ T_PRESS, press }, -- overshoot
			{ T_HOLD, clap },
			{ T_HOLD2, hold or clap },
			{ T_SMASH, smash, "expoIn" }, -- smash the ground on landing
			{ T_DOWN, smash },
			{ T_BACK, { 0, 0, 0 }, "backOut" },
		}
	end
	local armR = armTrack({ 4, -25, 0 }, { 40, 0, -10 }, { 40, 0, -20 }, { 40, 0, 50 }, { 42, 0, 54 }, { 3, 0, -5 })
	local foreR = armTrack({ -5, 0, 0 }, { 20, 0, 0 }, { 20, 0, -10 }, { 20, 0, 20 }, { 20, 0, 24 }, { 0, 0, 0 })
	local clawR = armTrack({ -5, 0, 0 }, { 20, 0, 0 }, { 25, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { -10, 0, 0 })
	local armL = armTrack({ 4, -25, 0 }, { 40, 10, -10 }, { 40, 10, -20 }, { 40, 20, 70 }, { 42, 20, 74 }, { -2, 0, -8 })
	local foreL = armTrack({ -5, 0, 0 }, { 20, 0, -10 }, { 20, 0, -20 }, { 0, 0, -20 }, { 0, 0, -16 }, { 0, 0, 0 })
	local clawL = armTrack({ -5, 0, 0 }, { 20, 0, 0 }, { 25, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { -15, 0, 0 })
	local shakeA = 4 * rumble * wave(t, 11)
	local function setArm(side, aT, fT, cT, pump, sh, ph)
		local ax, ay, az = L.track3(c, aT)
		local fx, fy, fz = L.track3(c, fT)
		local cx = L.track3(c, cT)
		local arm = ang(ax + 10 * pump + 3 * bob + sh + 14 * hop, ay - 6 * pump, az + 6 * pump)
		local fore = ang(fx + 8 * pump, fy, fz)
		local claw = ang(cx - 6 * pump, 0, 8 * wave(t, 1, ph) * idleW)
		if side == "R" then
			pose.ArmR, pose.ForeR, pose.ClawR = arm, fore, claw
		else
			pose.ArmL, pose.ForeL, pose.ClawL = L.mirror(arm), L.mirror(fore), L.mirror(claw)
		end
	end
	setArm("R", armR, foreR, clawR, pumpR, shakeA, 0.3)
	setArm("L", armL, foreL, clawL, pumpL, -shakeA, 0.8)

	-- pincers: clack in bursts at idle, wide open on the wind-up, SNAP on clap
	local gateR = math.max(0, wave(t, 0.5, 0.05))
	local gateL = math.max(0, wave(t, 0.5, 0.55))
	local clackR = math.max(0, wave(t, 3.5)) ^ 0.6 * gateR * idleW
	local clackL = math.max(0, wave(t, 4.2)) ^ 0.6 * gateL * idleW
	local open = L.track(c, {
		{ 3.62, 0 },
		{ 3.85, 1, "backOut" },
		{ 4.26, 1 },
		{ 4.34, 0, "expoIn" },
		{ 4.9, 0 },
		{ 5.02, 0.35, "backOut" },
		{ 5.14, 0, "expoIn" },
		{ 5.24, 0.6, "backOut" },
		{ 5.3, 0.6 },
		{ 5.38, 0, "expoIn" },
	})
	pose.PincerR = ang(32 * clackR + 45 * open, 0, 0)
	pose.PincerL = L.mirror(ang(32 * clackL + 45 * open, 0, 0))

	--------------------------------------------------------------------
	-- FACE: jaw, mandibles, eye stalks, blinks
	--------------------------------------------------------------------
	local mumble = math.max(0, wave(t, 0.7, 0.2)) ^ 4 * idleW
	local roar = math.max(erupt * (1 - preJump), 0)
	pose.Jaw = ang(-14 * mumble - 52 * roar - 30 * air + 4 * crouch - 34 * impact + 6 * rumble * wave(t, 12), 0, 0)
	local chew = 16 * wave(t, 2.5) * idleW
	L.both(pose, "Mand", ang(30 * crouch, chew - 30 * roar - 20 * air, 0), ang(30 * crouch, -chew - 30 * roar - 20 * air, 0))

	local wobZ = 10 * wave(t, 0.5, 0.35) * idleW
	local wobX = 7 * wave(t, 1.3) * idleW
	local whip = 30 * impact * wave(t, 3.2) + 12 * dazed * wave(t, 2.1)
	local stalkY = -0.8 * crouch + 0.6 * air - 0.8 * impact
	local stalkX = 10 * crouch - 25 * erupt * (1 - air) + 30 * air - 20 * impact
	pose.StalkR = pa(0, stalkY, 0, stalkX + wobX + whip, 0, wobZ + 0.6 * whip)
	pose.StalkL = L.mirror(pa(0, stalkY, 0, stalkX + wobX * 0.8 + whip, 0, -wobZ + 0.5 * whip))
	local look = 18 * L.noise(t, 6.1, 0.35) * idleW
	local eyeLagX = 9 * wave(t, 1.3, -0.15) * idleW + 25 * impact * wave(t, 3.2, -0.12) - 15 * erupt * (1 - air)
	local eyeLagZ = 12 * wave(t, 0.5, 0.2) * idleW + 15 * dazed * wave(t, 2.1, -0.1)
	pose.EyeR = ang(eyeLagX, look - 10 * dazed * wave(t, 1.5), eyeLagZ)
	pose.EyeL = L.mirror(ang(eyeLagX, -look - 10 * dazed * wave(t, 1.5, 0.5), -eyeLagZ))

	local blink = L.env(t % 3.2, 2.85, 0.05, 0.08, 0.07)
	local squint = math.max(L.env(c, 3.0, 0.05, 0.5, 0.06), L.env(c, 6.15, 0.05, 0.08, 0.05), L.env(c, 6.4, 0.05, 0.08, 0.05))
	local shut = math.max(blink * idleW, squint)
	L.both(pose, "Lid", CFrame.new(0, 0, -1.15 * shut))

	--------------------------------------------------------------------
	-- VENTS: rumble, pop on the eruption, wobble after
	--------------------------------------------------------------------
	local pop = L.env(c, 3.6, 0.1, 0.25, 0.8, "backOut", "elasticOut")
	local puff = 0.1 * math.max(0, wave(t, 0.8)) ^ 3 * idleW
	pose.Vent = pa(0.15 * rumble * wave(t, 17), 1.2 * pop + puff + 0.1 * rumble * wave(t, 19), 0, 6 * rumble * wave(t, 9), 0, 8 * pop * wave(t, 4))
	local popR = L.env(c, 3.66, 0.1, 0.2, 0.8, "backOut", "elasticOut")
	local popL = L.env(c, 3.72, 0.1, 0.2, 0.8, "backOut", "elasticOut")
	pose.VentR = pa(0, 0.9 * popR + 0.08 * rumble * wave(t, 15), 0, 0, 0, 10 * popR * wave(t, 5))
	pose.VentL = L.mirror(pa(0, 0.9 * popL + 0.08 * rumble * wave(t, 14), 0, 0, 0, 10 * popL * wave(t, 5, 0.3)))

	--------------------------------------------------------------------
	-- FLOATING VOXEL CUBES: orbit + tumble, flung up by the eruption
	--------------------------------------------------------------------
	pose.Orbit = ang(0, 32 * t, 0)
	local fling = L.env(c, 3.65, 0.3, 0.9, 1.2, "backOut", "bounceOut")
	for i = 1, 5 do
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(0, 0.7 * wave(t, 0.55, i * 0.21) + 2.5 * fling - 0.6 * impact, 0, 70 * t * dir + 20 * i, 95 * t, 30 * i)
	end

	--------------------------------------------------------------------
	-- EFFECTS
	--------------------------------------------------------------------
	ctx.enable("EruptFire", fire > 0.05)
	ctx.light("VentLight", 0.45 + 0.15 * L.noise(t, 1.7, 3) + 1.2 * fire)
	if ctx.crossed(3.64) then
		ctx.emit("EruptBurst", 55)
		ctx.emit("VentSmoke", 10)
		ctx.emit("VentEmbersR", 14)
		ctx.emit("VentEmbersL", 14)
	end
	if ctx.crossed(4.34) then
		ctx.emit("ClapBurst", 45)
	end
	if ctx.crossed(5.39) then
		ctx.emit("SlamDust", 45)
		ctx.emit("VentSmoke", 6)
		ctx.emit("EruptBurst", 20)
	end
	if ctx.crossed(5.87) then
		ctx.emit("SlamDust", 22)
	end
end

return M
