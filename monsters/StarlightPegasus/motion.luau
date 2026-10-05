--!nocheck
-- Starlight Pegasus motion: bouncy happy idle (body bob, breathing, mane and
-- tail flowing with lag, wing ruffle, sassy head toss / hair flip, hoof paw,
-- blinks, ear flicks) then the CELESTIAL REAR: deep crouch wind-up -> rears
-- up ~55 deg on the hind legs with wings flung wide, two huge wing beats,
-- bicycle front kicks, neigh with the jaw open + star burst -> crashes down
-- with a front-hoof STOMP, dust and a squashy elastic settle.
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave
local rad, sin, deg, acos, clamp, max = math.rad, math.sin, math.deg, math.acos, math.clamp, math.max

local M = {}
M.Cycle = 8

-- knee bend (degrees) that lowers a 2-segment leg of total length `len` by `d`
local function bend(d, len)
	return deg(acos(clamp(1 - max(0, d) / len, -1, 1)))
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- Envelopes
	------------------------------------------------------------------
	local crouch = L.env(c, 2.85, 0.45, 0.1, 0.25, "cubicOut", "quadIn") -- anticipation
	local rear = L.env(c, 3.4, 0.45, 1.6, 0.4, "backOut", "quadIn") -- up 3.85, hold, drop 5.45-5.85
	local impact = L.env(c, 5.85, 0.05, 0.05, 1.0, "linear", "elasticOut") -- stomp squash
	local hold = L.env(c, 3.7, 0.2, 1.45, 0.25) -- wing beats live
	local neigh = L.env(c, 3.7, 0.15, 1.35, 0.3, "backOut", "cubicInOut")
	local toss = L.env(c, 0.6, 0.22, 0.12, 0.7, "backOut", "cubicInOut") -- hair flip
	local paw = L.env(c, 1.85, 0.2, 0.75, 0.25)
	local ruffle = L.env(c, 0.1, 0.08, 0.35, 0.15) * wave(t, 9)
	local idleW = 1 - clamp(max(crouch, rear, impact), 0, 1)
	local kw = clamp(rear * 1.3, 0, 1) -- front legs leave the ground

	local breathe = wave(t, 0.5)
	local bob = L.wave01(t, 1.2) * idleW * 1.3

	------------------------------------------------------------------
	-- BODY: pivots at the hind hips -> rears up nose-first
	------------------------------------------------------------------
	local P = 1.5 * wave(t, 0.6) * idleW - 9 * crouch + 55 * rear - 7 * impact
	local dy = -0.35 * bob - 1.1 * crouch + 0.25 * rear - 1.1 * impact
	local roll = 2.5 * wave(t, 0.6, 0.25) * idleW
	pose.Body = pa(0, dy, 0, P, 0, roll)

	local flex = 2 * breathe - 5 * crouch + 6 * rear + 5 * impact
	pose.Chest = ang(flex, 0, -roll * 0.5)

	------------------------------------------------------------------
	-- LEGS
	------------------------------------------------------------------
	-- hind: stay planted (counter the body pitch), crouch with hocks back
	local dH = -dy + 0.6 * crouch
	local aH = bend(dH, 5.6) + 10 * rear
	local hThigh = -P - aH
	L.both(pose, "HLeg", ang(hThigh, 0, -roll), ang(hThigh, 0, -roll))
	L.both(pose, "HKnee", ang(2 * aH - 8 * rear, 0, 0))
	L.both(pose, "HHoof", ang(-aH + 8 * rear, 0, 0))

	-- front: planted pose vs. bicycle kicks while reared
	local dF = -dy - 6.0 * sin(rad(P)) - 3.0 * sin(rad(flex))
	local aF = bend(dF, 5.6)
	local plantThigh = -(P + flex) + aF
	local function front(phase, pawW)
		local k = wave(c, 2.6, phase)
		local k2 = wave(c, 2.6, phase - 0.15)
		local thigh = (plantThigh) * (1 - kw) + (15 + 38 * k) * kw
		local knee = (-2 * aF) * (1 - kw) + (-75 - 30 * k2) * kw
		local hoof = aF * (1 - kw) + (-25 + 10 * k) * kw
		-- hoof paw (idle, right leg): lift and scrape twice
		local scrape = wave(c - 1.85, 2.5)
		thigh += pawW * (32 + 18 * scrape)
		knee += pawW * -70
		hoof += pawW * (-15 + 10 * scrape)
		return thigh, knee, hoof
	end
	local tR, kR, hR = front(0, paw)
	local tL, kL, hL = front(0.5, 0)
	L.both(pose, "FLeg", ang(tR, 0, -roll * 0.5), ang(tL, 0, -roll * 0.5))
	L.both(pose, "FKnee", ang(kR, 0, 0), ang(kL, 0, 0))
	L.both(pose, "FHoof", ang(hR, 0, 0), ang(hL, 0, 0))

	------------------------------------------------------------------
	-- NECK / HEAD / JAW
	------------------------------------------------------------------
	local look = L.noise(t, 3.3, 0.3) * 18 * idleW
	local shakeYaw = 7 * hold * wave(c, 5)
	pose.Neck1 = ang(-4 * bob + 14 * toss - 2 * crouch - 20 * rear - 8 * impact, look * 0.35, 0)
	pose.Neck2 = ang(2 * breathe + 6 * toss + 2 * crouch - 10 * rear - 4 * impact, look * 0.35, 0)
	pose.Head = ang(
		3 * bob + 18 * toss + 8 * crouch - 8 * rear + 10 * neigh - 10 * impact,
		look * 0.5 + 24 * toss + shakeYaw,
		-16 * toss + 5 * L.noise(t, 8.2, 0.4) * idleW
	)

	local chomp = max(0, wave(t, 0.45, 0.2)) ^ 6 * idleW
	pose.Jaw = ang(-4 - 12 * chomp - 20 * toss - 48 * neigh - 8 * neigh * wave(c, 7) - 14 * impact * (1 - neigh), 0, 0)

	-- blinks + determined brows during the rear, squint on the stomp
	local blink = L.env(t % 3.4, 3.0, 0.06, 0.05, 0.1)
	local lidDrop = -1.7 * blink * (1 - neigh) - 0.45 * impact
	local wink = L.env(c, 0.78, 0.07, 0.4, 0.15) -- sassy wink during the hair flip
	local browTilt = ang(0, 0, 16 * rear + 10 * crouch)
	L.both(pose, "Lid", CFrame.new(0, lidDrop - 1.6 * wink, 0) * browTilt, CFrame.new(0, lidDrop + 0.3 * toss, 0) * browTilt)

	-- ears: little flicks, pinned back while rearing
	local flick = L.env(t % 4.3, 3.9, 0.08, 0.05, 0.15)
	L.both(pose, "Ear", ang(35 * rear + 15 * crouch - 20 * flick, 0, -10 * flick + 6 * wave(t, 0.7)),
		ang(35 * rear + 15 * crouch, 0, 6 * wave(t, 0.7, 0.3)))

	------------------------------------------------------------------
	-- MANE: flows with lag, whips on the toss and the stomp
	------------------------------------------------------------------
	for i = 1, 4 do
		local lag = (i - 1) * 0.08
		local tossLag = L.env(c, 0.68 + lag, 0.25, 0.1, 0.8, "backOut", "cubicInOut")
		local hitLag = L.env(c, 5.88 + lag, 0.08, 0.05, 0.9, "linear", "elasticOut")
		pose["Mane" .. i] = ang(
			6 * wave(t, 1.1, -0.15 * i) + 12 * rear - 10 * crouch - 22 * hitLag + 10 * tossLag,
			0,
			9 * wave(t, 0.8, -0.12 * i) - 22 * tossLag + 8 * hold * wave(c, 2.5, -0.1 * i)
		)
	end

	------------------------------------------------------------------
	-- TAIL: swish with lag; lifts + streams back while rearing
	------------------------------------------------------------------
	local swishAmp = 12 + 10 * hold + 14 * impact
	for i = 1, 4 do
		local lag = wave(t, 0.75 + 0.8 * hold, -0.11 * i)
		local hitLag = L.env(c, 5.88 + 0.07 * i, 0.08, 0.05, 0.8, "linear", "elasticOut")
		local lift = (i == 1 and (-68 * rear + 12 * crouch) or (-18 * rear)) - 14 * hitLag + 4 * breathe
		pose["Tail" .. i] = ang(lift, swishAmp * lag * (0.5 + 0.15 * i), 0)
	end

	------------------------------------------------------------------
	-- WINGS: breathe + ruffle; tuck on the wind-up; spread + 2 big beats
	------------------------------------------------------------------
	-- (wing bones use model axes: +Z raises the wing, -Y sweeps it back)
	local bt = c - 3.85
	local spread = L.env(c, 3.45, 0.4, 1.7, 0.45, "backOut", "cubicInOut")
	for i = 1, 3 do
		local beat = wave(bt, 1.5, -0.07 * (i - 1)) * hold
		local idleFlap = (3 + 2 * i) * wave(t, 0.6, -0.08 * i) * idleW
		local hitLag = L.env(c, 5.85 + 0.06 * i, 0.06, 0.05, 0.9, "linear", "elasticOut")
		local zA, yA, xA
		if i == 1 then
			zA = idleFlap + 5 * ruffle - 38 * crouch + 12 * spread + 40 * beat - 28 * hitLag
			yA = -22 * crouch + 22 * spread
			xA = -18 * spread
		elseif i == 2 then
			zA = idleFlap + 8 * ruffle - 8 * crouch + 6 * spread - 22 * beat + 20 * hitLag
			yA = -22 * crouch + 6 * spread
			xA = 0
		else
			zA = idleFlap + 10 * ruffle - 6 * crouch + 4 * spread - 26 * beat + 26 * hitLag
			yA = -18 * crouch
			xA = 0
		end
		L.both(pose, "Wing" .. i, ang(xA, yA, zA))
	end

	------------------------------------------------------------------
	-- ORBITING VOXEL CUBES + STARS: spin, bob, tumble, flung out by the burst
	------------------------------------------------------------------
	pose.Orbit = ang(0, 32 * t, 0)
	local fling = L.env(c, 3.85, 0.25, 1.2, 0.8, "backOut", "cubicInOut")
	for i = 1, 5 do
		local dir = i % 2 == 0 and -1 or 1
		local bobO = 0.8 * wave(t, 0.55, i * 0.21)
		pose["Orb" .. i] = pa(2.2 * fling * dir, bobO + 1.5 * fling, 0, 70 * t * dir, 110 * t, 30 * i)
	end

	------------------------------------------------------------------
	-- EFFECTS
	------------------------------------------------------------------
	local sparksOn = hold > 0.15
	ctx.enable("WingSparksR", sparksOn)
	ctx.enable("WingSparksL", sparksOn)
	ctx.light("BurstLight", 1.5 * L.env(c, 3.85, 0.08, 0.35, 0.9))
	if ctx.crossed(3.9) then
		ctx.emit("StarBurst", 55)
	end
	if ctx.crossed(4.35) or ctx.crossed(5.02) then
		ctx.emit("StarBurst", 15)
	end
	-- stomp shockwave bars fly outward and fade
	local sw = L.remap(c, 5.85, 6.45)
	local swOn = c >= 5.85 and c < 6.45
	local out = 6 * L.ease.cubicOut(sw)
	local waveTr = swOn and (0.25 + 0.75 * sw) or 1
	for k = 1, 12 do
		local a = math.rad((k - 1) / 12 * 360)
		pose["Shock" .. k] = CFrame.new(-math.sin(a) * out, 0, -math.cos(a) * out)
		ctx.transparency("Wave" .. k, waveTr)
	end
	if ctx.crossed(5.86) then
		ctx.emit("StompDust", 36)
	end
	if ctx.crossed(2.2) or ctx.crossed(2.6) then
		ctx.emit("StompDust", 6)
	end
end

return M
