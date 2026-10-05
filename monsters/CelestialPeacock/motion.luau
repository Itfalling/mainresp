--!nocheck
-- Celestial Peacock motion: twitchy bird idle, then a huge tail-fan display:
-- crouch + fold (anticipation) -> SNAP open with overshoot -> rattling shimmer
-- while strutting side to side -> settle.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease

local M = {}
M.Cycle = 9

local FAN_N, INNER_N = 13, 12
local fanAngle, innerAngle = {}, {}
for i = 1, FAN_N do
	fanAngle[i] = -84 + (i - 1) * (168 / (FAN_N - 1))
end
for i = 1, INNER_N do
	innerAngle[i] = -77 + (i - 1) * (154 / (INNER_N - 1))
end

-- crisp bird head turns: hold, then snap to a new random target
local function snappy(t, rate, amp, seed)
	local s = t * rate
	local i = math.floor(s)
	local f = s - i
	local a = math.noise(i * 0.37, seed, 0.5) * 2
	local b = math.noise((i + 1) * 0.37, seed, 0.5) * 2
	return amp * L.lerp(a, b, E.expoOut(math.min(1, f * 5)))
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- phase envelopes
	local crouch = L.env(c, 2.9, 0.8, 0.05, 0.35, "cubicInOut", "expoOut") -- wind-up
	local open = L.env(c, 3.75, 0.45, 2.2, 1.0, "backOut", "cubicInOut") -- fan display
	local fold = L.env(c, 2.9, 0.75, 0.1, 0.12, "cubicInOut", "quadIn") -- fan closes before snapping open
	local rear = L.env(c, 3.75, 0.35, 2.3, 1.0, "backOut", "sineInOut")
	local shimmer = L.env(c, 4.1, 0.2, 1.9, 0.4)
	local strut = L.env(c, 4.2, 0.6, 1.4, 0.6) -- show-off turning

	-- idle breathing / weight shift
	local breathe = wave(t, 0.45)
	local shift = wave(t, 0.3)
	local yawShow = 24 * strut * wave(c - 4.2, 0.45)

	-- BODY
	local bodyY = 0.25 * breathe - 1.5 * crouch + 1.3 * rear + 0.25 * shimmer * wave(t, 7)
	local bodyPitch = -16 * crouch + 13 * rear + 1.5 * breathe
	pose.Body = pa(0.35 * shift, bodyY, 0, bodyPitch, yawShow, 3 * shift)

	-- LEGS: knees bend in the crouch, little marching shuffle while strutting
	local stepR = math.max(0, wave(c, 0.9)) * strut
	local stepL = math.max(0, -wave(c, 0.9)) * strut
	local knee = crouch * 1.0 + rear * -0.35
	pose.ThighR = ang(28 * knee - 30 * stepR, 0, -3 * shift)
	pose.ShinR = ang(-50 * knee + 40 * stepR, 0, 0)
	pose.FootR = ang(22 * knee - 10 * stepR, 0, 0)
	pose.ThighL = ang(28 * knee - 30 * stepL, 0, 3 * shift)
	pose.ShinL = ang(-50 * knee + 40 * stepL, 0, 0)
	pose.FootL = ang(22 * knee - 10 * stepL, 0, 0)

	-- NECK + HEAD: bird head snaps around in idle, thrusts skyward on display
	local idleW = 1 - math.max(crouch, open)
	local headYaw = snappy(t, 1.4, 34, 3.1) * idleW
	local headTilt = snappy(t, 1.1, 18, 7.7) * idleW
	local peck = math.max(0, wave(t, 0.5, 0.2)) ^ 6 * idleW -- occasional quick dip
	pose.Neck1 = ang(-14 * peck - 20 * crouch + 22 * open + 2 * breathe, headYaw * 0.35 - yawShow * 0.4, 0)
	pose.Neck2 = ang(-26 * peck - 10 * crouch + 14 * open, headYaw * 0.35, 0)
	pose.Head = ang(10 * peck + 18 * crouch - 6 * open + 4 * wave(t, 6) * shimmer, headYaw * 0.3, headTilt)
	local call = L.env(c, 3.8, 0.12, 0.5, 0.3, "backOut") + 0.4 * L.env(c, 5.0, 0.1, 0.15, 0.2)
	pose.Beak = ang(-34 * call, 0, 0)

	-- crest springs around (secondary motion)
	local snapFlop = L.env(c, 3.75, 0.08, 0, 0.9, "quadOut", "elasticOut")
	pose.Crest = ang(-10 * wave(t, 1.3, 0.1) - 35 * snapFlop + 14 * crouch, 0, 8 * wave(t, 0.9) - headTilt * 0.4)

	-- HALO: always spinning, whips extra turns during the display
	local spin = 70 * t + 540 * E.cubicInOut(L.remap(c, 3.75, 6.6))
	pose.Halo = pa(0, 0.45 * wave(t, 0.6) + 0.8 * open, 0, 6 * wave(t, 0.35), spin, 6 * wave(t, 0.35, 0.25))

	-- WINGS: tucked idle twitch, flare + flap on the display
	local flare = L.env(c, 3.75, 0.4, 2.0, 1.0, "backOut", "cubicInOut")
	local flap = 18 * flare * wave(c, 2.6)
	local wingR = ang(-6 * flare, -10 * flare, 6 * crouch + 78 * flare + flap + 2 * breathe)
	L.both(pose, "Wing", wingR)

	-- TAIL: the fan lowers & folds, then snaps open
	pose.TailBase = ang(40 * fold - 10 * open + 2 * breathe, yawShow * -0.3, 0)
	local rattle = shimmer * 3.5
	for i = 1, FAN_N do
		local a = fanAngle[i]
		local d = math.abs(i - (FAN_N + 1) / 2) * 0.03 -- center opens first, edges follow
		local o = L.env(c, 3.75 + d, 0.45, 2.2 - d, 1.0, "backOut", "cubicInOut")
		local spread = 1 - 0.9 * fold + 0.14 * o -- 1 = rest spread, overshoots past rest on snap
		local idleSway = 3 * wave(t, 0.5, i * 0.07)
		local zRot = a * (spread - 1) + idleSway
		local xRot = 4 * wave(t, 0.5, i * 0.09) + rattle * wave(t, 13, i * 0.37) - 8 * o
		pose["Fan" .. i] = ang(xRot, 0, zRot)
	end
	for i = 1, INNER_N do
		local a = innerAngle[i]
		local d = math.abs(i - (INNER_N + 1) / 2) * 0.03
		local o = L.env(c, 3.85 + d, 0.45, 2.1 - d, 1.0, "backOut", "cubicInOut")
		local spread = 1 - 0.9 * fold + 0.18 * o
		local zRot = a * (spread - 1) + 4 * wave(t, 0.5, 0.5 + i * 0.07)
		local xRot = 3 * wave(t, 0.5, i * 0.11) + rattle * 1.3 * wave(t, 13, 0.5 + i * 0.41) - 6 * o
		pose["Inner" .. i] = ang(xRot, 0, zRot)
	end

	-- EFFECTS
	if ctx.crossed(3.8) then
		ctx.emit("DisplayBurst", 70)
	end
	ctx.light("HaloLight", 2.5 + 4 * open)
end

return M
