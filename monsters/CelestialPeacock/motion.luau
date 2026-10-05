--!nocheck
-- Celestial Peacock motion (9 s loop, every always-on wave is a multiple of
-- 1/9 Hz so the loop is seamless).
-- Idle (0 - 2.9, 7.0 - 9): bouncy march in place with a big chicken head-bob,
-- snappy look-arounds, a goofy tail-fan WIGGLE, a big happy hop, a feather
-- RUFFLE shiver, wing flicks, blinks, halo spin, hovering voxel cubes.
-- FAN DISPLAY (signature):
--   2.9-3.75  anticipation: deep crouch, fan folds DOWN + closes, head tucks
--   3.75-4.2  hold: trembling, eyes squeezed shut, fan quivering
--   4.2       SNAP: fan whips open (crisp backOut spread, springy pitch and a
--             centre-out depth ripple), SUNBURST rays shoot out behind the
--             fan, hop, wings flung open, beak CALL, crest whips, halo spin,
--             voxel confetti + particle burst
--   4.68      land: big squash, fan dips, ground SHOCKWAVE ring + dust
--   4.7-6.7   snappy side-to-side strut with pose holds, fan rattles,
--             wing flaps, two more calls
--   6.7-7.2   settle back into the idle
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease

local sin, cos, rad, deg, max, min, abs, sqrt = math.sin, math.cos, math.rad, math.deg, math.max, math.min, math.abs, math.sqrt
local atan2, acos, clamp, floor = math.atan2, math.acos, math.clamp, math.floor

local M = {}
M.Cycle = 9
local function hz(n) return n / 9 end -- n whole waves per loop

-- fan layout (must match build.luau)
local NF, SPREAD, CUP = 11, 85, 7

-- leg rig (must match build.luau) for the planted-feet IK
local BPY, BPZ = 6.2, 0.6
local HX, HY, HZ = 1.8, 5.6, 1.0
local KY, KZ = 3.6, 1.4
local AY, AZ = 0.8, 0.7
local L1 = sqrt((KY - HY) ^ 2 + (KZ - HZ) ^ 2)
local L2 = sqrt((AY - KY) ^ 2 + (AZ - KZ) ^ 2)
local T0 = atan2(KZ - HZ, KY - HY)
local S0 = atan2(AZ - KZ, AY - KY)

local function wrap(a)
	while a > math.pi do a -= 2 * math.pi end
	while a < -math.pi do a += 2 * math.pi end
	return a
end

-- 2-bone IK in the side plane so the feet stay planted while the body bobs,
-- crouches and sways. Inputs are for the RIGHT leg (mirror them for the left).
-- Angles use phi = atan2(z, y); a +X rotation increases phi.
local function leg(bx, by, bz, pitch, roll, lift, fwd, side, footTilt)
	local p = rad(pitch)
	local ry, rz = HY - BPY, HZ - BPZ
	local hy = BPY + by + ry * cos(p) - rz * sin(p) + HX * sin(rad(roll))
	local hz_ = BPZ + bz + ry * sin(p) + rz * cos(p)
	local hx = HX * cos(rad(roll)) + bx
	local ty, tz, tx = AY + lift, AZ + fwd, HX + side
	local dy, dz = ty - hy, tz - hz_
	local D = clamp(sqrt(dy * dy + dz * dz), abs(L1 - L2) + 0.02, L1 + L2 - 0.002)
	local phiD = atan2(dz, dy)
	local alpha = acos(clamp((L1 * L1 + D * D - L2 * L2) / (2 * L1 * D), -1, 1))
	local phiT = phiD - alpha
	local ky, kz = hy + L1 * cos(phiT), hz_ + L1 * sin(phiT)
	local phiS = atan2(tz - kz, ty - ky)
	local dT, dS = deg(wrap(phiT - T0)), deg(wrap(phiS - S0))
	local zW = deg(atan2(tx - hx, hy - ty))
	return ang(dT - pitch, 0, zW - roll), ang(dS - dT, 0, 0), ang(-dS + (footTilt or 0), 0, -zW)
end

-- snappy look-around keys (degrees of head yaw)
local LOOK = {
	{ 0.0, 0 }, { 0.35, 0 }, { 0.47, -40, "backOut" }, { 1.2, -40 }, { 1.32, 36, "backOut" },
	{ 1.95, 36 }, { 2.07, 0, "backOut" }, { 7.5, 0 }, { 7.62, 34, "backOut" }, { 7.95, 34 },
	{ 8.07, 0, "backOut" }, { 9, 0 },
}
local BLINKS = { 0.7, 2.62, 7.3, 8.75 }

local SNAP = 4.2
local LAND = SNAP + 0.48

-- strut: snappy side-to-side sway with a short pose HOLD at each extreme
local S0T, SHZ = 4.7, 1.6
local SWAY = {
	{ 0, -1 }, { 0.19, -1 }, { 0.5, 1, "backOut" }, { 0.69, 1 }, { 1.0, -1, "backOut" },
}
local function strutSway(c)
	local p = (c - S0T) * SHZ
	p -= floor(p)
	return L.track(p, SWAY)
end

local RAY_N, SHOCK_N = NF - 1, 10

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- Signature move envelopes
	------------------------------------------------------------------
	local crouch = L.env(c, 2.9, 0.85, SNAP - 3.75, 0.14, "cubicInOut", "quadIn")
	-- fold: 1 = fan closed + folded down. Spread uses a crisp backOut snap
	-- (about 10% overshoot, clamped); the bounce lives in pitch + depth.
	local fold
	if c < 2.9 then
		fold = 0
	elseif c < 3.75 then
		fold = E.cubicInOut((c - 2.9) / 0.85)
	elseif c < SNAP then
		fold = 1
	else
		fold = 1 - E.backOut(clamp((c - SNAP) / 0.35, 0, 1))
	end
	local tremble = L.env(c, 3.7, 0.1, SNAP - 3.8, 0.05)
	local squeeze = L.env(c, 3.6, 0.1, SNAP - 3.72, 0.05)
	local hop = L.env(c, SNAP, 0.17, 0.06, 0.25, "quadOut", "quadIn") -- airborne -> lands at SNAP+0.48
	local land = L.env(c, LAND, 0.04, 0.02, 0.7, "linear", "elasticOut")
	local puff = L.env(c, SNAP, 0.25, 2.55, 0.5, "backOut", "cubicInOut")
	local strut = L.env(c, S0T, 0.25, 1.55, 0.4)
	local rattle = L.env(c, SNAP + 0.15, 0.15, 2.4, 0.45)
	local wingSnap = L.env(c, SNAP, 0.12, 0.5, 0.45, "backOut", "quadInOut")
	local fanBoing = L.env(c, SNAP, 0.06, 0.04, 0.5, "quadOut", "elasticOut")
	local call = max(
		L.env(c, SNAP + 0.02, 0.08, 0.42, 0.3, "backOut", "quadIn"),
		0.85 * L.env(c, 5.3, 0.07, 0.25, 0.25, "backOut", "quadIn"),
		0.95 * L.env(c, 6.25, 0.07, 0.3, 0.3, "backOut", "quadIn")
	)
	-- idle gags
	local wiggle = L.env(c, 0.85, 0.15, 0.5, 0.2)
	local ihop = L.env(c, 1.95, 0.2, 0.05, 0.24, "quadOut", "quadIn")
	local iland = L.env(c, 2.44, 0.04, 0.02, 0.45, "linear", "elasticOut")
	local shiver = L.env(c, 8.15, 0.05, 0.3, 0.1)
	local idleW = clamp(1 - max(crouch, puff, strut, hop), 0, 1)

	------------------------------------------------------------------
	-- Stepping: idle march + strut steps
	------------------------------------------------------------------
	local step = wave(t, hz(8))
	local sStep = strutSway(c)
	local march = idleW * (1 - ihop) * (1 - shiver)
	local liftR = 1.6 * max(0, step) ^ 2 * march + 1.8 * strut * max(0, sStep) ^ 1.5 + 1.3 * hop + 1.8 * ihop
	local liftL = 1.6 * max(0, -step) ^ 2 * march + 1.8 * strut * max(0, -sStep) ^ 1.5 + 1.3 * hop + 1.8 * ihop

	------------------------------------------------------------------
	-- Body: bob, crouch, hop, squash, chest puff, strut sway, wiggle
	------------------------------------------------------------------
	local bob = abs(step)
	local wig = wave(t, 5) * wiggle
	local shake = wave(t, 14) * shiver
	local bx = 0.35 * step * march - 1.5 * strut * sStep + 0.4 * wig + 0.15 * shake
	local by = -0.7 * (1 - bob) * march - 1.7 * crouch + 2.2 * hop - 1.6 * land - 0.45 * strut * (1 - abs(sStep))
		+ 2.2 * ihop - 1.2 * iland - 0.3 * wiggle - 0.3 * shiver
	local pitch = 2 * wave(t, hz(4)) * idleW - 15 * crouch + 14 * puff - 10 * land + 2.5 * tremble * wave(t, 17)
		- 6 * wiggle + 8 * ihop - 7 * iland
	local roll = -8 * step * march + 9 * strut * sStep + 5 * wig + 5 * shake
	local yaw = 6 * step * march - 18 * strut * sStep - 8 * wig
	pose.Body = pa(bx, by, 0, pitch, yaw, roll)

	-- legs (feet planted via IK; lifted feet step slightly forward)
	local th, sh, ft = leg(bx, by, 0, pitch, roll, liftR, -0.5 * liftR, 0, 25 * liftR)
	pose.ThighR, pose.ShinR, pose.FootR = th, sh, ft
	th, sh, ft = leg(-bx, by, 0, pitch, -roll, liftL, -0.5 * liftL, 0, 25 * liftL)
	pose.ThighL, pose.ShinL, pose.FootL = L.mirror(th), L.mirror(sh), L.mirror(ft)

	------------------------------------------------------------------
	-- Neck + head: chicken bob, snappy turns, tuck on the wind-up, call on the snap
	------------------------------------------------------------------
	local hb = L.saw(t, hz(16))
	local thrust = hb < 0.22 and E.quadOut(hb / 0.22) or 1 - E.sineInOut((hb - 0.22) / 0.78)
	local bobW = march + strut
	local look = L.track(c, LOOK) * idleW + 18 * strut * sStep
	local neckX = -5 * thrust * bobW + 20 * crouch - 10 * puff - 6 * call - 10 * ihop + 8 * iland
	local headX = -8 * crouch + 20 * call + 6 * puff - 10 * thrust * bobW + 3 * wave(t, hz(4)) * idleW - 10 * land + 12 * ihop
	pose.Neck = ang(neckX, look * 0.35 + 6 * wig, 0)
	pose.Head = pa(0, 0.3 * thrust * bobW, -1.4 * thrust * bobW, headX, look * 0.65,
		look * 0.25 + 4 * tremble * wave(t, 15) + 8 * strut * sStep - 8 * wig + 6 * shake)

	-- beak: little idle chirps, wide open calls
	local chirp = max(0, wave(t, hz(3), 0.15)) ^ 10 * idleW
	pose.Jaw = ang(-24 * chirp - 62 * call + 5 * call * wave(t, 12) - 30 * ihop - 20 * shiver, 0, 0)

	-- blinks + eyes squeezed shut at the peak of the wind-up (lids slide down
	-- over the wrap-around eyes and are only shown while closing)
	local blink = squeeze
	for _, b in BLINKS do
		blink = max(blink, L.env(c, b, 0.05, 0.07, 0.08))
	end
	L.both(pose, "Lid", CFrame.new(0, 1.2 * (1 - blink), 0))
	local lidTr = blink > 0.15 and 0 or 1
	ctx.transparency("EyelidR", lidTr)
	ctx.transparency("EyelidL", lidTr)
	ctx.transparency("LashR", lidTr)
	ctx.transparency("LashL", lidTr)

	-- crest: springy sway, whips back on the snap
	local whip = L.env(c, SNAP + 0.02, 0.08, 0.05, 0.9, "quadOut", "elasticOut")
	pose.Crest = ang(6 * wave(t, hz(10), 0.2) - 12 * crouch + 34 * whip - 8 * hop - 24 * ihop + 14 * iland, 0,
		8 * wave(t, hz(7)) + 12 * strut * wave(c, 1.6, -0.15) + 14 * wave(t, 5, -0.15) * wiggle + 10 * shake)

	-- halo: stays roughly level, bobs + spins, pops up and does an extra spin on the snap
	local haloPop = L.env(c, SNAP + 0.02, 0.15, 0.45, 0.7, "backOut", "cubicInOut")
	local spinExtra = 360 * E.cubicOut(L.remap(c, SNAP, SNAP + 1.1))
	local level = -(pitch + neckX + headX) * 0.85
	pose.Halo = pa(0, 0.3 * wave(t, hz(6)) + 1.4 * haloPop - 0.3 * crouch + 0.5 * iland, 0,
		level + 5 * wave(t, hz(4)), 40 * t + spinExtra, 4 * wave(t, hz(4), 0.25))

	------------------------------------------------------------------
	-- Wings: idle flicks, tucked on the wind-up, flung OPEN on the snap
	-- (trailing ends swing out so the broad side faces the front), strut flaps
	------------------------------------------------------------------
	local flick = L.env(c, 2.0, 0.1, 0.12, 0.25, "backOut", "quadIn") + L.env(c, 8.2, 0.1, 0.08, 0.25, "backOut", "quadIn")
	local flap = strut * (0.5 + 0.5 * wave(c, 3.2))
	local wingZ = 3 * wave(t, hz(4)) * idleW + 45 * flick - 4 * crouch + 105 * wingSnap + 55 * flap + 8 * wiggle
	local wingY = 40 * wingSnap + 15 * flap
	local wingX = -10 * wingSnap - 6 * flap
	L.both(pose, "Wing", ang(wingX, 0, 0) * ang(0, 0, wingZ) * ang(0, wingY, 0))
	local open = clamp((wingZ - 10) / 80, 0, 1)
	local tipF = 18 * wave(c, 3.2, -0.18) * strut - 18 * wingSnap
	L.both(pose, "WingTip", ang(25 * open, tipF, 0))

	------------------------------------------------------------------
	-- Fan: breathing at idle, wiggles, folds down/closed, SNAPS open,
	-- boings in pitch, ripples centre-out, rattles + sways during the strut
	------------------------------------------------------------------
	local breathe = 0.12 * L.wave01(t, hz(3))
	pose.FanRoot = ang(62 * max(fold, 0) - 10 * fanBoing + 8 * land + 3 * wave(t, hz(3)) * idleW - 6 * puff
		+ 2 * tremble * wave(t, 21) + 8 * ihop - 6 * iland,
		6 * strut * sStep + 16 * wave(t, 5, -0.12) * wiggle,
		-10 * strut * sStep + 1.5 * wave(t, hz(4)) * idleW - 6 * wave(t, 5, -0.2) * wiggle)
	local f = max(fold + breathe * idleW, -0.1)
	for i = 1, NF do
		local a = -SPREAD + (i - 1) * (2 * SPREAD / (NF - 1))
		local cup = CUP * abs(a) / SPREAD
		local ripple = L.env(c, SNAP + 0.03 * abs(i - 6), 0.05, 0.02, 0.7, "quadOut", "elasticOut")
		local rx = 1.5 * wave(t, hz(8), -i * 0.07) + 5 * rattle * wave(t, 9, i * 0.31) + 3 * tremble * wave(t, 18, i * 0.5)
			+ 4 * wiggle * wave(t, 5, -0.25 - i * 0.03) + 10 * ripple
		local rz = 4 * rattle * wave(t, 11, i * 0.19) + 6 * shiver * wave(t, 14, i * 0.23)
		pose["Feather" .. i] = ang(cup, 0, 0) * ang(0, 0, -a * f) * ang(-cup * (1 - f), 0, 0) * ang(rx, 0, rz)
	end

	------------------------------------------------------------------
	-- SUNBURST: rays shoot outward from the fan centre on the snap and fade
	------------------------------------------------------------------
	local sw = L.remap(c, SNAP + 0.04, SNAP + 0.75)
	local swOn = c > SNAP + 0.04 and c < SNAP + 0.75
	for k = 1, RAY_N do
		local r = 11 * E.quadOut(sw) + (k % 2 == 1 and 1.2 or 0)
		pose["Ray" .. k] = CFrame.new(0, r, 0)
		local tr = swOn and (0.05 + 0.9 * sw ^ 3) or 1
		ctx.transparency("Ray" .. k, tr)
		ctx.transparency("RayTip" .. k, tr)
	end

	------------------------------------------------------------------
	-- Landing shockwave ring
	------------------------------------------------------------------
	local sk = L.remap(c, LAND, LAND + 0.5)
	local skOn = c > LAND and c < LAND + 0.5
	local rr = 6 * E.quadOut(sk)
	for k = 1, SHOCK_N do
		local a = (k - 1) / SHOCK_N * 2 * math.pi
		pose["Shock" .. k] = CFrame.new(-sin(a) * rr, 0.25 * (1 - sk), -cos(a) * rr)
		ctx.transparency("Wave" .. k, skOn and (0.1 + 0.85 * sk * sk) or 1)
	end

	------------------------------------------------------------------
	-- Voxel confetti: bursts out radially from the fan on the snap, tumbles,
	-- falls and fades out
	------------------------------------------------------------------
	local cp = (c - SNAP) / 0.9
	for k = 1, 8 do
		local name = "Confetti" .. k
		if cp > 0 and cp < 1 then
			local th2 = rad(-78 + (k - 1) * (156 / 7))
			local d = (7.5 + 1.5 * (k % 3)) * E.cubicOut(cp)
			pose[name] = pa(sin(th2) * d * 1.1, cos(th2) * d * 0.85 - 6 * cp * cp, -3 * E.cubicOut(cp), 400 * cp * (k % 2 == 0 and 1 or -1), 300 * cp, 200 * cp)
			ctx.transparency(name, cp < 0.55 and 0 or (cp - 0.55) / 0.45)
		else
			pose[name] = CFrame.new()
			ctx.transparency(name, 1)
		end
	end

	------------------------------------------------------------------
	-- Hovering voxel cubes: gentle drift, bob + tumble, flung out on the snap
	------------------------------------------------------------------
	pose.Orbit = ang(0, 22 * wave(t, hz(1)), 0)
	local fling = L.env(c, SNAP + 0.02, 0.2, 0.4, 1.0, "backOut", "cubicInOut")
	local jolt = L.env(c, LAND, 0.05, 0, 0.8, "quadOut", "elasticOut")
	local spots = { { 6.6, -3.8 }, { -7.4, -1.0 }, { 7.6, 1.4 }, { -6.2, -4.4 } }
	for i = 1, 4 do
		local dir = i % 2 == 0 and -1 or 1
		local sp = spots[i]
		local len = sqrt(sp[1] * sp[1] + sp[2] * sp[2])
		local out = 2.2 * fling
		local bobO = 0.8 * wave(t, hz(5), i * 0.27) + 1.6 * fling - 0.8 * crouch - 1.0 * jolt
		pose["Orb" .. i] = pa(out * sp[1] / len, bobO, out * sp[2] / len, 80 * t * dir, 120 * t, 25)
	end

	------------------------------------------------------------------
	-- Effects
	------------------------------------------------------------------
	ctx.enable("FanShimmer", c > SNAP + 0.05 and c < 6.9)
	ctx.enable("FeatherFall", c > SNAP + 0.05 and c < 7.0)
	ctx.light("FanLight", 1.4 * L.env(c, SNAP, 0.06, 0.15, 0.9))
	if ctx.crossed(SNAP + 0.02) then
		ctx.emit("FanBurst", 70)
		ctx.emit("CallBurst", 18)
	end
	if ctx.crossed(LAND) then
		ctx.emit("StepDust", 28)
	end
	if ctx.crossed(2.46) then
		ctx.emit("StepDust", 14)
	end
	if ctx.crossed(8.17) then
		ctx.emit("FanShimmer", 8)
		ctx.emit("BodySparkle", 6)
	end
	if ctx.crossed(5.32) or ctx.crossed(6.27) then
		ctx.emit("CallBurst", 12)
	end
	-- strut footfalls: when the sway lands at each extreme
	for k = 0, 5 do
		local s = S0T + (0.5 + 0.5 * k) / SHZ
		if s < 6.7 and ctx.crossed(s) then
			ctx.emit("StepDust", 6)
		end
	end
end

return M
