--!nocheck
-- Cyclops Warlord motion
--  IDLE: grumpy waddle-sway, belly breathing, the club bounces up and
--        TAP-TAPs into the left palm, the big eye darts around and blinks.
--  EARTHSHAKER (signature): huge lean-back wind-up with the club cocked
--        behind the head (left foot lifts) -> tremble -> SLAM down with a
--        lunge, club smashes the ground -> body squash, eye pops, crater +
--        cracks + flying rocks -> recoil -> PROUD chest-out pose (club
--        raised high, hand on hip, laughing) -> settle back to idle.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease
local clamp, floor = math.clamp, math.floor

local M = {}
M.Cycle = 8

local V = Vector3.new
-- rig constants (kept in sync with build.luau)
local HIPS_PIV = V(0, 6.4, 0.4)
local HIP_R, ANKLE_R = V(2.75, 5.4, 0.4), V(2.75, 1.1, 0.5)
local HIP_L, ANKLE_L = V(-2.75, 5.4, 0.4), V(-2.75, 1.1, 0.5)
local THIGH_LEN = 2.3
local SHIN_LEN = (V(2.75, 3.1, 0.4) - ANKLE_R).Magnitude

-- key times of the EARTHSHAKER
local T0, T1, T2, T3, T4, T5, T6, T7, T8 = 2.2, 3.0, 3.38, 3.6, 3.72, 4.35, 4.85, 6.05, 6.8

local function rotTo(a, b)
	local axis = a:Cross(b)
	local m = axis.Magnitude
	if m < 1e-6 then
		return CFrame.new()
	end
	return CFrame.fromAxisAngle(axis / m, math.atan2(m, a:Dot(b)))
end

-- 2-bone leg IK: keeps the foot planted (and flat) at `ankle` whatever the hips do
local function legIK(hipsCF, hipRest, ankle)
	local R = hipsCF.Rotation
	local hipNow = HIPS_PIV + hipsCF.Position + R * (hipRest - HIPS_PIV)
	local D = R:Inverse() * (ankle - hipNow)
	local a, b = THIGH_LEN, SHIN_LEN
	local len = math.clamp(D.Magnitude, 0.5, a + b - 0.02)
	local knee = math.acos(clamp((a * a + b * b - len * len) / (2 * a * b), -1, 1))
	local th = math.acos(clamp((a * a + len * len - b * b) / (2 * a * len), -1, 1))
	local thigh = rotTo(V(0, -1, 0), D.Unit) * CFrame.Angles(th, 0, 0)
	local shin = CFrame.Angles(-(math.pi - knee), 0, 0)
	local foot = (R * thigh * shin).Rotation:Inverse()
	return thigh, shin, foot
end

-- eye darting: hold a random spot, then snap to the next one
local function hash(i, s)
	local x = math.sin(i * 12.9898 + s * 78.233) * 43758.5453
	return (x - floor(x)) * 2 - 1
end
local function saccade(t, rate, seed)
	local k = t * rate
	local i = floor(k)
	local f = k - i
	local a, b = hash(i, seed), hash(i + 1, seed)
	return a + (b - a) * L.smoothstep(L.remap(f, 0.8, 1))
end

-- idle club tap: slow lift, fast slam into the palm, tiny rebound
local TAP_HZ = 0.8
local function tapCurve(t)
	local p = (t * TAP_HZ) % 1
	if p < 0.55 then
		return E.sineInOut(p / 0.55), 0
	elseif p < 0.66 then
		return 1 - E.quadIn((p - 0.55) / 0.11), 0
	end
	local q = (p - 0.66) / 0.34
	return 0.14 * math.sin(q * math.pi * 2) * (1 - q), (1 - q) ^ 2
end

local function headPitch(c)
	return L.track(c, {
		{ T0, 0 }, { T1, 16, "cubicOut" }, { T2, 20 }, { T3, -8, "cubicIn" }, { T4, 14, "backOut" },
		{ T5, 8 }, { T6, 18, "backOut" }, { T7, 14 }, { T8, 0, "sineInOut" },
	})
end

-- debris launch params
local DEB = {}
for i = 1, 6 do
	local a = math.rad(i * 60 + 20)
	DEB[i] = { dx = math.cos(a), dz = math.sin(a), h = 3.5 + (i % 3) * 1.6, vy = 13 + (i % 2) * 4, spin = (i % 2 == 0) and 1 or -1 }
end
local DEB_G = 34

local ROCK_DIR = {
	V(10.6, 0, 0.5).Unit, V(-10.2, 0, 2.5).Unit, V(7.0, 0, 6.0).Unit, V(-6.0, 0, -5.2).Unit,
}

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes
	------------------------------------------------------------------
	local busy = L.track(c, { { T0 - 0.25, 0 }, { T0 + 0.3, 1, "sineInOut" }, { T7 + 0.2, 1 }, { T8 + 0.25, 0, "sineInOut" } })
	local idle = 1 - busy
	local lever = L.track(c, { { T0, 0 }, { T1 - 0.1, 1, "sineInOut" }, { T7, 1 }, { T8, 0, "sineInOut" } })
	local imp = L.env(c, T3, 0.03, 0.04, 0.9, "linear", "elasticOut") -- squash on the slam
	local shake = L.env(c, T3, 0.02, 0.35, 0.35)
	local pop = L.env(c, T3, 0.05, 0.45, 0.45, "backOut", "sineInOut") -- eye pops wide
	local proud = L.env(c, T5 + 0.05, T6 - T5 - 0.05, T7 - T6, T8 - T7, "backOut", "sineInOut")
	local windup = L.env(c, T0, T1 - T0, T2 - T1, T3 - T2, "cubicOut", "cubicIn")
	local tremble = L.env(c, T1 - 0.1, 0.1, T2 - T1, 0.12) * wave(t, 14)

	local lift, hit = tapCurve(t)
	lift *= idle
	hit *= idle
	local breath = wave(t, 0.45)
	local sway = wave(t, 0.4)
	local laugh = proud * math.max(0, wave(t, 4.5))

	------------------------------------------------------------------
	-- HIPS + LEGS (IK keeps the feet planted; left foot lunges on the slam)
	------------------------------------------------------------------
	local hipY = -0.3 - 0.3 * hit + 0.15 * lift + 0.12 * breath * idle
		+ L.track(c, {
			{ T0, 0 }, { T1, -0.5, "cubicOut" }, { T2, -0.6 }, { T3, -0.7, "cubicIn" },
			{ T5, -0.6 }, { T6, 0.3, "backOut" }, { T7, 0.3 }, { T8, 0, "sineInOut" },
		})
		- 0.65 * imp + 0.15 * laugh
	local hipYaw = L.track(c, { { T0, 0 }, { T1, -10, "cubicOut" }, { T3, 10, "cubicIn" }, { T5, 8 }, { T6, 0 } })
	local hipsCF = pa(0.35 * sway * idle, hipY, 0, 0, hipYaw + 3 * sway * idle, -3 * sway * idle)
	pose.Hips = hipsCF

	local stepL = L.track(c, {
		{ T0, 0 }, { T1, 1.7, "cubicOut" }, { T2, 1.9 }, { T3, 0, "cubicIn" }, { T5, 0 },
		{ T5 + 0.22, 1.3, "quadOut" }, { T6, 0, "quadIn" },
	})
	local fwdL = L.track(c, { { T0, 0 }, { T1, 0.5 }, { T3, 1.7, "cubicIn" }, { T5, 1.7 }, { T6, 0, "sineInOut" } })
	local tR, sR, fR = legIK(hipsCF, HIP_R, ANKLE_R)
	pose.ThighR, pose.ShinR, pose.FootR = tR, sR, fR
	local tL, sL, fL = legIK(hipsCF, HIP_L, ANKLE_L + V(0, stepL, -fwdL))
	pose.ThighL, pose.ShinL, pose.FootL = tL, sL, fL * ang(-12 * stepL, 0, 0)

	-- loincloth flaps: lag behind the bounce, fly up on the slam
	local flap = 6 * wave(t, TAP_HZ, -0.15) * idle + 30 * imp + 8 * shake * wave(t, 5)
	pose.LoinF = ang(flap + 10 * L.remap(fwdL, 0, 1.7) + 3 * sway * idle, 0, 4 * sway * idle)
	pose.LoinB = ang(-flap * 0.8 - 8 * windup, 0, 4 * sway * idle)

	------------------------------------------------------------------
	-- CHEST + GUT
	------------------------------------------------------------------
	local chestX = 2.5 * breath + 3 * hit
		+ L.track(c, {
			{ T0, 0 }, { T1, 20, "cubicOut" }, { T2, 24 }, { T3, -12, "cubicIn" }, { T4, -17, "quadOut" },
			{ T5, -10 }, { T6, 14, "backOut" }, { T7, 12 }, { T8, 0, "sineInOut" },
		})
	local chestY = 4 * sway * idle + L.track(c, { { T0, 0 }, { T1, -16, "cubicOut" }, { T2, -18 }, { T3, 18, "cubicIn" }, { T4, 21, "quadOut" }, { T5, 16 }, { T6, -6, "sineInOut" }, { T7, -6 }, { T8, 0 } })
	pose.Chest = ang(chestX + 1.5 * tremble, chestY, 2 * sway * idle + 3 * shake * wave(t, 7))
	pose.Gut = pa(0, 0, -0.3 * (0.5 + 0.5 * breath) - 0.5 * proud + 0.45 * imp * wave(t, 6))

	------------------------------------------------------------------
	-- HEAD, EYE, BROWS, JAW, TOPKNOT
	------------------------------------------------------------------
	local eyeX = saccade(t, 1.3, 1) * idle
	local eyeY = saccade(t, 1.3, 7) * idle
	local hx = headPitch(c)
	local faceCam = L.env(c, T3 - 0.08, 0.12, T5 - T3, 0.4)
	pose.Head = ang(hx + 3 * breath * idle - 4 * hit + 4 * laugh, -9 * eyeX - 24 * faceCam + 10 * shake * wave(t, 6), -4 * sway * idle + 4 * proud * wave(t, 2.2))
	pose.Topknot = ang(1.2 * (headPitch(c - 0.15) - hx) + 6 * wave(t, 0.8, -0.3) - 28 * imp, 6 * sway * idle, 8 * shake * wave(t, 6, -0.2))

	pose.Eye = pa(0, 0.15 * pop, -0.85 * pop)
	pose.Iris = CFrame.new(0.8 * eyeX + 0.1 * shake * wave(t, 9), 0.45 * eyeY + 0.6 * windup - 0.3 * imp, 0)

	local bt = t % 3.7
	local blink = L.env(bt, 3.15, 0.07, 0.05, 0.1, "quadIn", "quadOut") + L.env(bt, 1.2, 0.06, 0.03, 0.08) * (floor(t / 3.7) % 2)
	blink = math.min(1, blink) * (1 - pop) * (1 - proud)
	pose.Lid = ang(96 * blink + 34 * windup - 16 * pop, 0, 0)

	L.both(pose, "Brow", pa(0, 0.12 * lift + 1.0 * pop + 0.45 * proud - 0.25 * windup, 0, 0, 0, -16 * pop - 8 * proud + 6 * windup))

	local jaw = -6 - 8 * hit + 2 * breath * idle
		+ L.track(c, {
			{ T0, 0 }, { T1, -24, "cubicOut" }, { T2, -28 }, { T3, -4, "cubicIn" }, { T4, -46, "quadOut" },
			{ T5, -36 }, { T6, -16, "backOut" }, { T7, -16 }, { T8, 0, "sineInOut" },
		})
		- 14 * laugh + 4 * shake * wave(t, 11)
	pose.Jaw = ang(jaw, 0, 0)

	------------------------------------------------------------------
	-- ARMS + CLUB
	-- lever mode (0..1): forearm straightens and the club lines up with
	-- the arm so the whole thing swings like one huge hammer.
	------------------------------------------------------------------
	local aX = L.track(c, {
		{ T0, 0 }, { T1, 116, "cubicOut" }, { T2, 122 }, { T3, 14, "cubicIn" }, { T4, 19, "quadOut" },
		{ T5, 15 }, { T6, 21, "backOut" }, { T7, 19 }, { T8, 0, "cubicInOut" },
	})
	local aZ = L.track(c, { { T0, 0 }, { T1, 12 }, { T3, -14 }, { T5, -14 }, { T6, 25, "backOut" }, { T7, 25 }, { T8, 0 } })
	local bend = L.track(c, {
		{ T0, 0 }, { T1, 75, "cubicOut" }, { T2, 85 }, { T3, 30, "cubicIn" }, { T5, 30 },
		{ T6, 90, "backOut" }, { T7, 86 }, { T8, 0, "sineInOut" },
	})
	local snap = L.track(c, { { T0, 0 }, { T1, 0 }, { T2, 0 }, { T3, -26, "cubicIn" }, { T4, -22 }, { T5, -25 }, { T6, 70, "backOut" }, { T7, 66 }, { T8, 0, "sineInOut" } })

	pose.ArmR = ang(aX + 4 * imp - 5 * lift + 2 * breath * idle + 3 * tremble, 0, aZ)
	pose.ForearmR = ang(bend + 16 * lift, 0, 0) * ang(-13.2 * lever, -31.8 * lever, 24.0 * lever)
	pose.Club = ang(snap, 0, -18 * lift) * ang(11.6 * lever, -56.7 * lever, 54.0 * lever)
	pose.Pauldron = ang(0.45 * aX, 0, 0.5 * aZ)

	-- left arm: palm catches the taps; swings up with the club; hand on hip when proud
	local leverL = L.track(c, { { T0, 0 }, { T1 - 0.1, 1, "sineInOut" }, { T5, 1 }, { T6, 0, "sineInOut" } })
	local hipHand = L.track(c, { { T5, 0 }, { T6, 1, "backOut" }, { T7, 1 }, { T8, 0, "sineInOut" } })
	local aXL = L.track(c, { { T0, 0 }, { T1, 100, "cubicOut" }, { T2, 106 }, { T3, 18, "cubicIn" }, { T5, 22 }, { T6, -25, "sineInOut" }, { T8, 0 } })
	local aZL = L.track(c, { { T0, 0 }, { T1, 24, "cubicOut" }, { T3, 12 }, { T5, 12 }, { T6, 38, "backOut" }, { T7, 38 }, { T8, 0 } })
	local bendL = L.track(c, { { T0, 0 }, { T1, 50 }, { T3, 30 }, { T5, 30 }, { T6, 0 } })
	local armL = ang(aXL + 3 * lift - 4 * hit + 2 * breath * idle, 0, aZL)
	local foreL = ang(bendL + 6 * lift - 7 * hit, 0, 0) * ang(-10.8 * leverL, -37.3 * leverL, 30.8 * leverL) * ang(0, 90 * hipHand, 0)
	pose.ArmL = L.mirror(armL)
	pose.ForearmL = L.mirror(foreL)

	------------------------------------------------------------------
	-- FLOATING ROCKS: slow orbit, bob + tumble, flung outward by the slam
	------------------------------------------------------------------
	local fling = L.env(c, T3, 0.15, 0.25, 1.3, "backOut", "sineInOut")
	pose.Orbit = ang(0, 28 * t, 0)
	for i = 1, 4 do
		local d = ROCK_DIR[i] * (3 * fling)
		local bob = 0.7 * wave(t, 0.55, i * 0.27)
		local dir = i % 2 == 0 and -1 or 1
		pose["Rock" .. i] = pa(d.X, bob + 2.2 * fling, d.Z, 70 * t * dir, 110 * t, 30 * i)
	end

	------------------------------------------------------------------
	-- IMPACT FX: crater rim, cracks, debris, dust, sparks, light
	------------------------------------------------------------------
	local tau = c - T3
	local craterOn = tau >= 0 and tau < 1.55
	local rise = L.track(c, { { T3, -1.3 }, { T3 + 0.12, 0.3, "backOut" }, { T3 + 0.3, 0 }, { T5 + 0.5, 0 }, { T3 + 1.55, -1.4, "quadIn" } })
	pose.Crater = CFrame.new(0, rise, 0)
	for i = 1, 8 do
		ctx.transparency("Crat" .. i, craterOn and 0 or 1)
	end
	local crackT = craterOn and L.remap(tau, 1.0, 1.4) or 1
	for i = 1, 4 do
		ctx.transparency("Crack" .. i, craterOn and (0.15 + 0.85 * crackT) or 1)
	end
	for i, d in DEB do
		local tt = tau - 0.01 * i
		local y = d.vy * tt - 0.5 * DEB_G * tt * tt
		local on = tt > 0 and y > -0.2
		if on then
			pose["Deb" .. i] = pa(d.dx * d.h * tt, y, d.dz * d.h * tt, 520 * tt * d.spin, 380 * tt, 260 * tt * d.spin)
		else
			pose["Deb" .. i] = CFrame.new(0, -2, 0)
		end
		ctx.transparency("Deb" .. i, on and 0 or 1)
	end
	pose.Impact = CFrame.new()

	ctx.light("ImpactLight", 1.4 * L.env(c, T3, 0.02, 0.08, 0.6))
	if ctx.crossed(T3) then
		ctx.emit("ImpactDust", 40)
		ctx.emit("ImpactSpark", 30)
	end
	if ctx.crossed(T5 + 0.1) then
		ctx.emit("Snort", 12)
	end
	if ctx.crossed(T6) then
		ctx.emit("Bling", 14)
	end
end

return M
