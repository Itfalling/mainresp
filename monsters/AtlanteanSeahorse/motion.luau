--!nocheck
-- Column Seahorse motion. Personality: a PROUD SHOW-OFF / little dancer.
-- Idle: hovering prance (a bouncy hop every second with a sassy side lean),
-- chin held high, smug half-closed eyes with a raised brow, slow smug head
-- tilts, fast fluttering dorsal + pectoral fins, the curly tail curling and
-- uncurling, jaunty crown wobble, cartoon blinks, little bubble puffs.
-- Signature "TIDAL TWIRL" (9 s loop):
--   3.3  anticipation: plie - dips, curls into a ball, tail coils TIGHT,
--        pecs fold, squint, twists the opposite way (-45 deg)
--   4.1  SPRING: shoots up ~6 studs, tail uncurls like a whip
--   4.15 double pirouette (720 deg corkscrew, tilted), fins up like ballerina
--        arms, water ribbon whirls round it, eyes wide with delight
--   5.28 apex: facing front, the snout BLOWS a voxel bubble ring + burst
--   5.5  floats down, tail re-curls
--   6.05 lands: squash + bouncy wobble, splash
--   6.5  PROUD POSE: chest out, head high, a fin raised in a flourish,
--        3/4 turn to show off, WINK (7.0) with a sparkle
--   8.6  back to the prancing idle
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 9

local sin, cos, rad, max, min, exp, pi = math.sin, math.cos, math.rad, math.max, math.min, math.exp, math.pi
local TAU = 2 * pi

local BP = Vector3.new(0, 6.8, 0.4)
local CP = Vector3.new(0, 7.6, 0.3)
local HP = Vector3.new(0, 10.0, 0.8)
local SP = Vector3.new(0, 10.9, -1.3)
local TIP = Vector3.new(0, 10.85, -5.7)
local BC = Vector3.new(0, 10.9, -6.0)

local LAND = 6.05
local REL = 5.28 -- bubble ring release
local BLINKS = { 1.55, 8.75 }

-- the main chain (Body -> Chest -> Head -> Snout) as a pure function of (c, t)
local function rig(c, t)
	local busy = L.env(c, 3.2, 0.3, 4.4, 0.7)
	local idleW = 1 - busy
	local antic = L.env(c, 3.3, 0.7, 0.1, 0.12, "cubicOut", "quadIn")
	local spinW = L.env(c, 4.1, 0.15, 0.85, 0.3)
	local inhale = L.env(c, 4.95, 0.25, 0.0, 0.1)
	local blow = L.env(c, 5.2, 0.08, 0.25, 0.4, "backOut", "quadIn")
	local proud = L.env(c, 6.45, 0.45, 1.05, 0.6, "backOut", "cubicInOut")
	local wink = L.env(c, 7.0, 0.08, 0.2, 0.12)
	local land = L.env(c, LAND, 0.05, 0.08, 0.6, "quadOut", "backOut")
	local wob = 0
	if c > LAND and c < LAND + 1.4 then
		local u = c - LAND
		wob = exp(-u * 3.2) * sin(TAU * 2.6 * u)
	end

	local jumpY = L.track(c, {
		{ 3.3, 0 }, { 4.0, -1.3, "cubicOut" }, { 4.1, -1.4 }, { 4.6, 5.2, "cubicOut" },
		{ 5.2, 6.0, "quadOut" }, { 5.5, 5.7, "quadIn" }, { LAND, -1.1, "quadIn" },
		{ LAND + 0.1, -1.25, "quadOut" }, { 6.6, 0.5, "backOut" }, { 7.0, 0.25, "quadInOut" },
		{ 8.6, 0, "sineInOut" },
	})
	local spin = L.track(c, { { 3.3, 0 }, { 4.05, -45, "cubicOut" }, { 5.15, 720, "cubicOut" } })

	-- prance: a hop every second, sassy lean at the top
	local pr = L.bounce(t, 0.5) ^ 1.5
	local side = wave(t, 0.5)
	local hover = 0.3 * wave(t, 1 / 3)

	local by = hover * (1 - 0.6 * busy) + 0.55 * pr * idleW + jumpY
	local bz = 0.4 * antic
	local yaw = 6 * wave(t, 1 / 9) * idleW + spin + 20 * proud
	local pitch = -16 * antic + 6 * land + 9 * wob + 2 * wave(t, 1 / 3, 0.2) * idleW
	local roll = 7 * side * pr * idleW + 8 * wob * cos(TAU * 1.3 * (c - LAND))
	local tilt = 15 * spinW
	local sa = rad(spin)
	local body = CFrame.new(0, by, bz) * ang(tilt * cos(sa), 0, tilt * sin(sa)) * ang(pitch, yaw, roll)

	local chest = ang(
		3 * wave(t, 1 / 3) * idleW - 12 * antic + 6 * spinW + 18 * proud - 10 * wob + 5 * inhale,
		-4 * side * idleW,
		-4 * side * pr * idleW
	)

	local look = (8 * L.noise(t, 3.3, 0.3) + 4 * wave(t, 1 / 9, 0.3)) * idleW
	local head = ang(
		10 * idleW - 4 * pr * idleW - 18 * antic + 16 * spinW + 10 * inhale - 16 * blow + 16 * proud - 8 * wob,
		look - 14 * proud,
		6 * wave(t, 2 / 9, 0.1) * idleW + 3 * side * idleW - 10 * spinW + 12 * wink + 6 * proud
	)

	local puff = max(L.env(c, 0.8, 0.12, 0.12, 0.35), L.env(c, 2.3, 0.12, 0.12, 0.35))
	local snout = pa(0, 0, -0.5 * blow - 0.25 * puff, 6 * puff + 10 * inhale - 4 * blow, 0, 0)

	return {
		Body = body, Chest = chest, Head = head, Snout = snout,
		busy = busy, idleW = idleW, antic = antic, spinW = spinW, blow = blow, proud = proud,
		wink = wink, land = land, wob = wob, jumpY = jumpY, spin = spin, pr = pr, side = side,
		puff = puff, inhale = inhale,
	}
end

local function snoutTip(r)
	local wB = CFrame.new(BP) * r.Body
	local wC = wB * CFrame.new(CP - BP) * r.Chest
	local wH = wC * CFrame.new(HP - CP) * r.Head
	local wS = wH * CFrame.new(SP - HP) * r.Snout
	return wS * CFrame.new(TIP - SP)
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle
	local r = rig(c, t)
	pose.Body, pose.Chest, pose.Head, pose.Snout = r.Body, r.Chest, r.Head, r.Snout
	local idleW, antic, spinW, proud, wob = r.idleW, r.antic, r.spinW, r.proud, r.wob

	------------------------------------------------------------------
	-- TAIL: curl breathing; coil TIGHT, whip-uncurl, stream, re-curl
	------------------------------------------------------------------
	for i = 1, 7 do
		local whip = L.env(c, 4.1 + 0.035 * i, 0.14, 0.6, 0.55, "backOut", "cubicInOut")
		local ripple = 14 * whip * sin(TAU * (2.4 * (c - 4.1) - 0.13 * i))
		local curl = 3 + 6 * wave(t, 1 / 3, -0.07 * i) * (1 - r.busy * 0.7)
			+ 12 * antic - 36 * whip + ripple
			+ 7 * wob * (i / 7) + 6 * proud - 3 * r.pr * idleW
		local yw = 6 * wave(t, 1 / 3, -0.1 * i) * idleW - 9 * spinW * (i / 4)
		pose["Tail" .. i] = ang(curl, yw, 0)
	end

	------------------------------------------------------------------
	-- FINS: fast flutter, fold on the plie, ballerina arms on the spin,
	-- a raised flourish in the proud pose
	------------------------------------------------------------------
	for i = 1, 4 do
		local fl = 16 * wave(t, 6, -0.06 * i) + 8 * spinW * wave(t, 9, -0.06 * i)
		pose["Dorsal" .. i] = ang(-10 * antic + 14 * spinW * (i / 4) - 6 * wob, fl, 0)
	end
	local fz = 22 * wave(t, 4, 0)
	local pecZR = fz * (1 - 0.6 * spinW) - 30 * antic + 55 * spinW + 60 * proud
	local pecZL = fz * (1 - 0.6 * spinW) - 30 * antic + 55 * spinW - 15 * proud
	local pecY = -45 * antic + 10 * wave(t, 4, 0.25)
	L.both(pose, "Pec", ang(0, pecY + 20 * proud, pecZR), ang(0, pecY - 25 * proud, pecZL))

	------------------------------------------------------------------
	-- FACE: smug half lids (rest), blinks, squint, wide-eyed spin, WINK
	------------------------------------------------------------------
	local blink = 0
	for _, b in BLINKS do
		blink = max(blink, L.env(c, b, 0.06, 0.06, 0.09))
	end
	local wide = L.env(c, 4.15, 0.15, 1.2, 0.3)
	local clR = max(blink, 0.55 * antic) - 0.38 * wide + 0.12 * proud
	local clL = max(blink, 0.55 * antic, r.wink) - 0.38 * wide - 0.1 * proud
	pose.LidR = CFrame.new(0, -1.0 * clR, 0)
	pose.LidL = CFrame.new(0, -1.0 * clL, 0)
	ctx.transparency("LidFillR", clR > 0.15 and 0 or 1)
	ctx.transparency("LidFillL", clL > 0.15 and 0 or 1)
	-- brows: right flat + low, left arched up (smug); flip on the wink
	local browR = pa(0, -0.05 + 0.25 * r.wink + 0.15 * wide - 0.15 * antic, 0, 0, 0, -4 + 10 * r.wink)
	local browL = pa(0, 0.12 + 0.06 * wave(t, 2 / 9) * idleW - 0.3 * r.wink + 0.15 * wide - 0.15 * antic, 0, 0, 0, 12 - 14 * r.wink)
	L.both(pose, "Brow", browR, browL)

	------------------------------------------------------------------
	-- CROWN: jaunty wobble lagging the hops, flung out by the spin
	------------------------------------------------------------------
	pose.Crown = ang(
		-4 * r.pr * idleW + 6 * r.land + 14 * wob,
		0,
		5 * wave(t, 0.5, -0.15) * idleW - 14 * spinW + 10 * wob * sin(TAU * 1.7 * (c - LAND))
	)

	------------------------------------------------------------------
	-- FLOATING CUBES: slow orbit, bob + tumble, whirl with the twirl,
	-- jolt on the landing
	------------------------------------------------------------------
	local jolt = L.env(c, LAND, 0.05, 0.05, 0.9, "quadOut", "elasticOut")
	pose.Orbit = pa(0, 0.5 * r.jumpY, 0, 0, 40 * t + 0.5 * r.spin, 0)
	for i = 1, 4 do
		local s = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(0, 0.9 * wave(t, 1 / 3, i * 0.27) - 1.2 * jolt + 0.8 * spinW, 0,
			(40 + 15 * i) * t * s, 70 * t, 20 * i)
	end

	------------------------------------------------------------------
	-- WATER RIBBON: whirls round the body during the pirouette
	------------------------------------------------------------------
	pose.Swirl = pa(0, r.jumpY - 1.0 + 2.0 * L.remap(c, 4.1, 5.4), 0, 0, -1.4 * r.spin, 0)
	for k = 1, 10 do
		local on = c > 4.12 + 0.03 * k and c < 5.25 + 0.03 * k
		local fade = L.remap(c, 4.9 + 0.03 * k, 5.25 + 0.03 * k)
		ctx.transparency("Swirl" .. k, on and (0.15 + 0.8 * fade) or 1)
	end

	------------------------------------------------------------------
	-- BUBBLE RING: blown out of the snout at the apex, expands + drifts
	------------------------------------------------------------------
	local ringOn = c > REL and c < REL + 1.3
	if ringOn then
		local tipCF = snoutTip(rig(REL, t - c + REL))
		local u = L.remap(c, REL, REL + 1.3)
		local e = L.ease.cubicOut(u)
		local fwd, right, up = tipCF.LookVector, tipCF.RightVector, tipCF.UpVector
		for k = 1, 8 do
			local a = (k - 1) / 8 * TAU + 0.6 * u
			local rr = 0.5 + 2.4 * e + 0.15 * sin(TAU * (3 * u + k * 0.25))
			local pos = tipCF.Position + fwd * (0.4 + 7.5 * e) + (right * cos(a) + up * sin(a)) * rr + Vector3.new(0, 1.2 * u, 0)
			pose["Bub" .. k] = CFrame.new(pos - BC) * ang(90 * u * k, 60 * u, 0)
			ctx.transparency("BubP" .. k, u > 0.7 and (0.3 + 0.7 * (u - 0.7) / 0.3) or 0.3)
		end
	else
		for k = 1, 8 do
			pose["Bub" .. k] = CFrame.new()
			ctx.transparency("BubP" .. k, 1)
		end
	end

	------------------------------------------------------------------
	-- EFFECTS on the beats
	------------------------------------------------------------------
	if ctx.crossed(0.95) or ctx.crossed(2.45) then
		ctx.emit("SnoutBubbles", 4)
	end
	if ctx.crossed(4.12) then
		ctx.emit("TwirlBurst", 22)
		ctx.emit("LandSplash", 12)
	end
	if ctx.crossed(REL) then
		ctx.emit("BubbleBurst", 30)
		ctx.emit("SnoutBubbles", 14)
		ctx.emit("TwirlBurst", 30)
		ctx.emit("CrownSparkle", 12)
	end
	if ctx.crossed(LAND) then
		ctx.emit("LandSplash", 26)
		ctx.emit("TwirlBurst", 16)
	end
	if ctx.crossed(7.08) then
		ctx.emit("WinkSparkle", 14)
	end
	local flash = max(L.env(c, REL, 0.05, 0.2, 0.6), 0.6 * spinW)
	ctx.light("BodyGlow", min(1.4, 1.4 * flash))
	ctx.light("CrownLight", 0.5 + 0.4 * max(proud, flash))
end

return M
