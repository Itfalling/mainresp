--!nocheck
-- Atomic Kaiju motion: stompy cartoon idle (marching in place, tail wagging,
-- head bobbing, blinking) then the ATOMIC ROAR: big lean-back wind-up ->
-- lunge with the jaw flung open + glowing breath beam + head shake ->
-- huge stomp that bounces the whole body.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease

local M = {}
M.Cycle = 8

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- signature move envelopes
	local windup = L.env(c, 2.8, 0.7, 0.1, 0.25, "cubicOut", "expoIn") -- lean back, head up
	local roar = L.env(c, 3.55, 0.2, 1.65, 0.45, "backOut", "cubicInOut") -- jaw open, beam
	local shake = L.env(c, 3.7, 0.15, 1.4, 0.3)
	local stompUp = L.env(c, 5.75, 0.4, 0.05, 0.12, "cubicOut", "expoIn") -- right leg lifts high
	local impact = L.env(c, 6.3, 0.05, 0.05, 0.9, "linear", "elasticOut") -- squash on landing
	local idleW = 1 - math.max(windup, roar, stompUp)

	-- idle march: alternate little steps, body bounces on each
	local step = wave(t, 0.75)
	local liftR = math.max(0, step) ^ 2 * idleW
	local liftL = math.max(0, -step) ^ 2 * idleW
	local bounce = L.bounce(t, 1.5) * idleW
	local breathe = wave(t, 0.5)

	-- HIPS: bob + side-to-side waddle, crouch on wind-up, squash on stomp
	local hipY = 0.45 * bounce - 0.3 - 1.1 * windup + 0.4 * roar - 1.3 * impact + 0.5 * stompUp
	pose.Hips = pa(0.5 * step * idleW, hipY, 0, 0, 6 * step * idleW, -5 * step * idleW + 6 * stompUp)

	-- CHEST: breathing, big lean back then lunge forward, rumble during the roar
	local rumble = 2.5 * shake * wave(t, 9)
	pose.Chest = ang(3 * breathe + 22 * windup - 10 * roar + 8 * impact + rumble, -4 * step * idleW, 0)

	-- NECK/HEAD: bobbing idle, snaps up on wind-up, thrusts forward + shakes on roar
	local look = L.noise(t, 4.2, 0.35) * 25 * idleW
	local shakeYaw = 14 * shake * wave(t, 5.5)
	pose.Neck = ang(-6 * bounce + 10 * windup + 2 * roar, look * 0.4, 0)
	pose.Head = ang(4 * breathe + 28 * windup + 14 * roar - 10 * impact, look * 0.6 + shakeYaw, 6 * L.noise(t, 9.1, 0.4) * idleW + 5 * shake * wave(t, 3))

	-- JAW: little chomps in idle, flung WIDE open on the roar
	local chomp = math.max(0, wave(t, 0.4, 0.3)) ^ 8 * idleW
	pose.Jaw = ang(-18 * chomp - 8 * windup - 58 * roar + 6 * shake * wave(t, 11), 0, 0)

	-- blinks (cartoon eyelids drop over the eyes)
	local blink = L.env(t % 3.3, 2.9, 0.06, 0.06, 0.1)
	L.both(pose, "Lid", CFrame.new(0, -1.4 * blink * (1 - roar), 0))

	-- ARMS: dangly swing in idle, thrown up in the wind-up, spread wide during the roar
	local swing = 14 * step * idleW
	local armR = ang(swing - 35 * windup + 10 * roar, 0, 8 + 45 * windup + 35 * roar + 10 * shake * wave(t, 6))
	local armL = ang(-swing - 35 * windup + 10 * roar, 0, 8 + 45 * windup + 35 * roar + 10 * shake * wave(t, 6, 0.5))
	L.both(pose, "Arm", armR, armL)
	local foreR = ang(-25 - 40 * windup + 20 * roar + 10 * wave(t, 0.75, 0.2) * idleW, 0, 0)
	L.both(pose, "Forearm", foreR, ang(-25 - 40 * windup + 20 * roar - 10 * wave(t, 0.75, 0.2) * idleW, 0, 0))

	-- LEGS: marching in place; right leg hikes up for the stomp
	local kneeR = liftR + 1.6 * stompUp
	local kneeL = liftL + 0.35 * windup
	pose.ThighR = ang(30 * kneeR + 12 * windup - 10 * impact, 0, -4 * stompUp)
	pose.ShinR = ang(-45 * kneeR - 20 * windup + 12 * impact, 0, 0)
	pose.FootR = ang(15 * kneeR + 8 * windup, 0, 0)
	pose.ThighL = ang(30 * kneeL + 12 * windup - 10 * impact, 0, 0)
	pose.ShinL = ang(-45 * kneeL - 20 * windup + 12 * impact, 0, 0)
	pose.FootL = ang(15 * kneeL + 8 * windup, 0, 0)

	-- TAIL: happy wag with lag down the chain, lifts and lashes during the roar
	local wagAmp = 11 + 10 * shake
	local wagHz = 0.75 + 1.6 * shake
	for i = 1, 5 do
		local lag = wave(t, wagHz, -0.09 * i)
		local lift = -7 * windup - 5 * roar + 6 * impact * wave(t, 3, -0.1 * i) + 2 * breathe
		pose["Tail" .. i] = ang(lift - 2, wagAmp * lag * (0.6 + i * 0.12), 0)
	end
	pose.TailTip = ang(0, 20 * wave(t, wagHz, -0.55), 0)

	-- ORBITING CUBES: slow spin, each bobbing and tumbling; flung outward by the roar
	pose.Orbit = ang(0, 40 * t, 0)
	for i = 1, 4 do
		local out = 2.5 * roar
		local bob = 0.8 * wave(t, 0.6, i * 0.25)
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(out * dir * 0.6, bob + out * 0.4, 0, 90 * t * dir, 120 * t, 45)
	end

	-- EFFECTS: beam + sparks during the roar, burst on the lunge, dust on the stomp
	local beamOn = c > 3.65 and c < 5.25
	ctx.transparency("AtomicBeam", beamOn and 0.1 or 1)
	ctx.transparency("AtomicBeamOuter", beamOn and 0.55 or 1)
	ctx.enable("RoarSparks", beamOn)
	ctx.light("MouthLight", math.min(1.8, 1.8 * roar))
	if ctx.crossed(3.62) then
		ctx.emit("RoarBurst", 45)
	end
	if ctx.crossed(6.32) then
		ctx.emit("StompDust", 30)
	end
end

return M
