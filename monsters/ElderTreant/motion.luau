--!nocheck
-- Elder Treant motion.
-- Idle: heavy plodding weight-shift with wind sway that lags up the tree
-- (hips -> chest -> head -> canopy -> clusters -> blossoms), dangly branch
-- arms, flexing root toes, blinks and little munches.
-- Signature "FOREST AWAKENING": deep crouch with arms swept back (anticipation)
-- -> springs up, arms flung HIGH, head thrown back with a wide roar, canopy
-- shaking violently + leaf/sparkle burst -> right root leg hikes up -> HEAVY
-- stomp (squash, dust, roots erupt from the ground) -> long lingering sway.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, env = L.ang, L.pa, L.wave, L.env

local M = {}
M.Cycle = 8

local LEG = 4.5 -- thigh (2.7) + shin (1.8) length
local SPROUT_DELAY = { 0.2, 0.14, 0.08, 0.04, 0.0, 0.03, 0.25 }

-- knee bend (deg) that lowers the hip by `drop` studs while the foot stays put
local function bend(drop)
	local k = math.clamp((LEG - drop) / LEG, 0.3, 1)
	return math.deg(math.acos(k))
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- signature envelopes
	------------------------------------------------------------------
	local crouch = env(c, 2.35, 0.75, 0.2, 0.25, "cubicOut", "expoIn") -- sink 2.35-3.1, spring 3.3-3.55
	local up = env(c, 3.3, 0.28, 0.62, 0.38, "backOut", "cubicInOut") -- arms flung high 3.58-4.2, down by 4.58
	local roar = env(c, 3.4, 0.2, 0.75, 0.35, "backOut", "cubicInOut")
	local shake = env(c, 3.5, 0.1, 0.7, 0.3)
	local lift = env(c, 4.22, 0.48, 0.06, 0.16, "backOut", "expoIn") -- sumo leg hike, slams at ~4.92
	local impact = env(c, 4.92, 0.04, 0.06, 1.1, "linear", "elasticOut")
	local linger = env(c, 4.95, 0.1, 0.9, 1.6)
	local sig = math.max(crouch, up, lift, math.abs(impact))
	local idleW = math.clamp(1 - sig, 0, 1)

	------------------------------------------------------------------
	-- idle drivers
	------------------------------------------------------------------
	local sway = wave(t, 0.5) -- weight shift: + = right foot lifts, lean left
	local liftR = math.max(0, sway) ^ 2 * idleW
	local liftL = math.max(0, -sway) ^ 2 * idleW
	local bob = L.bounce(t, 1.0) * idleW -- high mid-step, low at footfalls
	local breathe = wave(t, 0.35)
	local wind = L.noise(t, 3.3, 0.25)
	local lingerW = linger * wave(t, 1.6)

	------------------------------------------------------------------
	-- HIPS: plod, crouch, spring, stomp squash
	------------------------------------------------------------------
	local tremble = 0.12 * crouch * wave(t, 13) -- shivering with built-up energy
	local hipY = -0.55 * (1 - bob) * idleW - 2.1 * crouch + tremble + 0.5 * up * (1 - crouch) + 0.5 * lift - 1.8 * impact
	local roll = 8 * sway * idleW + 13 * lift - 3 * lingerW
	local yaw = 6 * sway * idleW + 6 * lift
	local tiltX = -6 * crouch + 3 * up - 3 * lift + 6 * impact
	pose.Hips = pa(-0.4 * sway * idleW - 0.7 * lift, hipY, 0, tiltX, yaw, roll)

	------------------------------------------------------------------
	-- LEGS: keep feet planted (simple 2-bone fold), hike the right leg
	------------------------------------------------------------------
	local sr = math.sin(math.rad(roll))
	local drop = -hipY
	local dR = drop - 2.4 * sr + 1.3 * liftR
	local dL = drop + 2.4 * sr + 1.3 * liftL
	local aR, aL = bend(math.max(0, dR)), bend(math.max(0, dL))
	pose.ThighR = ang(aR - tiltX + 62 * lift, -yaw * 0.6, -roll + 50 * lift)
	pose.ShinR = ang(-2 * aR - 70 * lift, 0, -10 * lift)
	pose.FootR = ang(aR + 12 * lift, 0, -12 * lift)
	pose.ThighL = ang(aL - tiltX, -yaw * 0.6, -roll)
	pose.ShinL = ang(-2 * aL, 0, 0)
	pose.FootL = ang(aL, 0, 0)
	-- root toes flex: curl up when the foot lifts, splay on the stomp
	pose.ToeR = ang(6 + 6 * wave(t, 0.8) + 30 * liftR + 40 * lift, 0, 0)
	pose.ToeL = ang(6 + 6 * wave(t, 0.8, 0.5) + 30 * liftL + 12 * crouch, 0, 0)

	------------------------------------------------------------------
	-- CHEST: breathe, hunch on the crouch, arch back on the awakening
	------------------------------------------------------------------
	local rumble = 2.5 * shake * wave(t, 9)
	pose.Chest = ang(2.5 * breathe - 8 * crouch + 8 * up + 10 * impact + rumble, -4 * sway * idleW, -3 * sway * idleW - 5 * lift + 2 * lingerW)

	------------------------------------------------------------------
	-- HEAD: lagging sway, looking around, thrown back on the roar
	------------------------------------------------------------------
	local look = 18 * L.noise(t, 7.1, 0.3) * idleW
	local headShake = 9 * shake * wave(t, 4.5)
	local nod = 3 * wave(t, 1.0, 0.1) * idleW -- nods with each plod
	pose.Head = ang(nod + 2 * breathe + 2 * crouch + 19 * roar - 6 * lift - 10 * impact, look + headShake, 6 * wave(t, 0.5, -0.12) * idleW - 4 * lift + 3 * lingerW)

	-- JAW: idle munching, clenched on the crouch, WIDE roar
	local munch = math.max(0, wave(t, 0.6, 0.2)) ^ 6 * idleW
	local jawX = -14 * munch - 42 * roar
	pose.Jaw = ang(jawX + 4 * crouch + 5 * shake * wave(t, 11), 0, 0)
	-- beard hangs and swings (counter the jaw so it keeps dangling)
	-- push the beard forward (in head space) so it stays in front of the chest while the jaw drops
	local jr = math.rad(-jawX)
	local dy, dz = -0.3 * roar, -1.1 * roar
	pose.Beard = CFrame.new(0, dy * math.cos(jr) - dz * math.sin(jr), dy * math.sin(jr) + dz * math.cos(jr)) * ang(-0.75 * jawX + 6 * wave(t, 0.5, -0.3) * idleW + 12 * lingerW - 6 * crouch + 8 * impact, 0, 6 * wave(t, 0.5, -0.35) * idleW + 6 * shake * wave(t, 6))

	-- blinks + squint on the crouch
	local blink = env(t % 3.2, 2.7, 0.06, 0.08, 0.1)
	local lid = math.max(blink * (1 - roar), 0.4 * crouch)
	L.both(pose, "Lid", CFrame.new(0, -1.85 * lid, 0))

	------------------------------------------------------------------
	-- CANOPY: wind lag + VIOLENT shake + whip on the stomp
	------------------------------------------------------------------
	local cx = 3 * wind - 6 * crouch + 2 * up - 11 * impact + 8 * lingerW + 10 * shake * wave(t, 7) + 3 * crouch * wave(t, 11)
	local cy = 3 * L.noise(t, 2.2, 0.2) + 12 * shake * wave(t, 5.3)
	local cz = 8 * wave(t, 0.5, -0.18) * idleW + 2 * wind + 11 * shake * wave(t, 6.1, 0.3) + 6 * lingerW - 6 * lift
	pose.Canopy = pa(0, 0.35 * shake * L.bounce(t, 6) - 0.5 * impact - 0.3 * crouch, 0, cx, cy, cz)
	pose.CanopyTop = ang(4 * wave(t, 0.5, -0.3) * idleW + 14 * shake * wave(t, 7.5, 0.2) + 6 * lingerW, 0, 6 * wave(t, 0.5, -0.32) * idleW + 12 * shake * wave(t, 6.6))
	local side = 6 * wave(t, 0.5, -0.3) * idleW + 3 * wind
	pose.CanopyR = ang(3 * wind + 10 * shake * wave(t, 6.4), 0, side + 16 * shake * wave(t, 7.2, 0.1) + 10 * lingerW + 6 * up)
	pose.CanopyL = L.mirror(ang(3 * wind + 10 * shake * wave(t, 6.4, 0.4), 0, -side + 16 * shake * wave(t, 7.2, 0.6) - 10 * lingerW + 6 * up))
	pose.CanopyBack = ang(-5 * wave(t, 0.5, -0.35) * idleW + 14 * shake * wave(t, 6.8, 0.3) - 8 * lingerW, 0, 0)

	-- blossoms bob on their own springs
	for i = 1, 7 do
		local ph = i * 0.137
		pose["Bloom" .. i] = ang(
			10 * wave(t, 0.9, ph) + 30 * shake * wave(t, 8, ph) + 14 * lingerW,
			20 * wave(t, 0.4, ph),
			10 * wave(t, 0.7, ph + 0.3) + 25 * shake * wave(t, 7, ph * 2)
		)
	end

	------------------------------------------------------------------
	-- ARMS: dangle swing, swept back on the crouch, flung HIGH in a big
	-- goalpost "awakening" pose, swung out for balance, slammed down
	------------------------------------------------------------------
	local armShake = 7 * shake * wave(t, 6)
	local function armPose(s)
		local swing = 16 * s * wave(t, 0.5, 0.25) * idleW
		return ang(swing - 55 * crouch + 6 * up + 10 * lift + 40 * impact,
			0,
			9 + 4 * wave(t, 0.5) * idleW + 6 * crouch + 82 * up + armShake + 50 * lift - 8 * impact + 3 * crouch * wave(t, 12))
	end
	L.both(pose, "Arm", armPose(1), armPose(-1))
	local function forePose(s)
		local lag = 10 * wave(t, 0.5, 0.15 + (s < 0 and 0.5 or 0)) * idleW
		return ang(8 + lag + 25 * crouch - 12 * up + 25 * impact + 10 * lingerW, 0, 48 * up + 8 * shake * wave(t, 7) + 25 * lift)
	end
	L.both(pose, "Forearm", forePose(1), forePose(-1))
	local function handPose(s)
		local lag = 10 * wave(t, 0.5, 0.05 + (s < 0 and 0.5 or 0)) * idleW
		return ang(lag + 20 * crouch - 10 * up + 20 * impact, 0, 25 * up + 12 * shake * wave(t, 8))
	end
	L.both(pose, "Hand", handPose(1), handPose(-1))

	------------------------------------------------------------------
	-- FLOATING LEAF CUBES: slow orbit, tumbling, flung out on the beats
	------------------------------------------------------------------
	pose.Orbit = ang(0, 30 * t + 40 * up, 0)
	for i = 1, 5 do
		local out = 2.2 * up + 2.0 * impact
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(out * dir * 0.5, 0.8 * wave(t, 0.55, i * 0.21) + out * 0.5, 0, 70 * t * dir + 90 * i, 100 * t, 30 * i)
	end

	------------------------------------------------------------------
	-- ROOT SPROUTS erupt in a ring, rippling out from the stomping foot
	------------------------------------------------------------------
	for i = 1, 7 do
		local d = SPROUT_DELAY[i]
		local e = env(c, 4.92 + d, 0.22, 0.95 - d, 0.4, "backOut", "backIn")
		pose["Sprout" .. i] = pa(0, -4.8 * (1 - e), 0, 0, 70 * (1 - e), 6 * wave(t, 2.5, i * 0.2) * e)
		local vis = (e > 0.02) and 0 or 1
		ctx.transparency("Sprout" .. i .. "a", vis)
		ctx.transparency("Sprout" .. i .. "b", vis)
		ctx.transparency("Sprout" .. i .. "c", vis)
	end

	------------------------------------------------------------------
	-- EFFECTS on the beats
	------------------------------------------------------------------
	ctx.enable("RoarPetals", c > 3.5 and c < 4.4)
	ctx.light("MouthLight", 1.5 * roar)
	if ctx.crossed(3.52) then
		ctx.emit("LeafBurst", 50)
		ctx.emit("SparkleBurst", 40)
	end
	if ctx.crossed(4.93) then
		ctx.emit("StompDust", 35)
		ctx.emit("GroundLeaves", 30)
		ctx.emit("SparkleBurst", 20)
	end
	if ctx.crossed(5.05) then
		ctx.emit("LeafBurst", 25)
	end
end

return M
