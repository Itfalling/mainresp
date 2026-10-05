--!nocheck
-- Elder Treant motion.
-- Idle: big bouncy plod (hips drop on each footfall, canopy hops a beat
-- late), wind sway that lags up the tree (hips -> chest -> head -> canopy
-- -> clusters -> blossoms), swinging branch arms, nods + look-arounds,
-- flexing root toes, cartoon blinks and munches.
-- Signature "FOREST AWAKENING":
--   anticipation - deep crouch, chest hunched, head looking down, arms swept
--                  back, eyes squint, body shivers
--   action       - springs up: chest arches back, arms flung HIGH, jaw drops
--                  into a huge roar (canopy counter-tilts so the face reads),
--                  the crown RATTLES violently + leaf / sparkle burst
--   stomp        - right root leg hikes up, then a HEAVY slam: squash, dust,
--                  a ring of stepped roots erupts from the ground
--   settle       - long lingering sway with blossoms bobbing on springs.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, env = L.ang, L.pa, L.wave, L.env

local M = {}
M.Cycle = 8

local LEG = 4.5 -- thigh (2.7) + shin (1.8) length
local SPROUT_DELAY = { 0.28, 0.14, 0.0, 0.07, 0.2, 0.3, 0.35 }
local NBLOOM = 12

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
	local crouch = env(c, 2.3, 0.8, 0.2, 0.22, "cubicOut", "expoIn") -- sink 2.3-3.1, spring 3.3-3.52
	local up = env(c, 3.3, 0.26, 0.64, 0.38, "backOut", "cubicInOut") -- arms flung high 3.56-4.2, down by 4.58
	local roar = env(c, 3.38, 0.2, 0.78, 0.36, "backOut", "cubicInOut")
	local shake = env(c, 3.48, 0.08, 0.74, 0.3)
	local lift = env(c, 4.22, 0.48, 0.06, 0.16, "backOut", "expoIn") -- leg hike, slams at ~4.92
	local impact = env(c, 4.92, 0.04, 0.06, 1.1, "linear", "elasticOut")
	local linger = env(c, 4.95, 0.1, 0.9, 1.7)
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
	local tremble = 0.14 * crouch * wave(t, 13) -- shivering with built-up energy
	local hipY = -0.9 * (1 - bob) * idleW - 2.2 * crouch + tremble + 0.6 * up * (1 - crouch) + 0.5 * lift - 1.9 * impact
	local roll = 9 * sway * idleW + 13 * lift - 3 * lingerW
	local yaw = 7 * sway * idleW + 6 * lift
	local tiltX = -7 * crouch + 3 * up - 3 * lift + 5 * impact
	pose.Hips = pa(-0.45 * sway * idleW - 0.7 * lift, hipY, 0, tiltX, yaw, roll)

	------------------------------------------------------------------
	-- LEGS: keep feet planted (simple 2-bone fold), hike the right leg
	------------------------------------------------------------------
	local sr = math.sin(math.rad(roll))
	local drop = -hipY
	local dR = drop - 2.4 * sr + 1.4 * liftR
	local dL = drop + 2.4 * sr + 1.4 * liftL
	local aR, aL = bend(math.max(0, dR)), bend(math.max(0, dL))
	pose.ThighR = ang(aR - tiltX + 62 * lift, -yaw * 0.6, -roll + 50 * lift)
	pose.ShinR = ang(-2 * aR - 70 * lift, 0, -10 * lift)
	pose.FootR = ang(aR + 12 * lift, 0, -12 * lift)
	pose.ThighL = ang(aL - tiltX, -yaw * 0.6, -roll)
	pose.ShinL = ang(-2 * aL, 0, 0)
	pose.FootL = ang(aL, 0, 0)
	-- root toes flex: curl up when the foot lifts, splay on the stomp
	pose.ToeR = ang(6 + 8 * wave(t, 0.8) + 34 * liftR + 45 * lift - 10 * impact, 0, 0)
	pose.ToeL = ang(6 + 8 * wave(t, 0.8, 0.5) + 34 * liftL + 14 * crouch, 0, 0)

	------------------------------------------------------------------
	-- CHEST: breathe, hunch on the crouch, ARCH back on the awakening
	------------------------------------------------------------------
	local rumble = 3 * shake * wave(t, 9)
	local chestX = 3 * breathe - 18 * crouch + 16 * up - 10 * impact + rumble
	pose.Chest = ang(chestX, -5 * sway * idleW, -4 * sway * idleW - 6 * lift + 3 * lingerW)

	------------------------------------------------------------------
	-- HEAD: lagging sway, nods + look-arounds, looks DOWN in anticipation,
	-- thrown back on the roar, thrashes while the crown rattles
	------------------------------------------------------------------
	local look = 14 * L.noise(t, 7.1, 0.3) * idleW + 6 * wave(t, 0.23) * idleW
	local headShake = 16 * shake * wave(t, 4.5)
	local nod = 7 * wave(t, 1.0, 0.1) * idleW -- nods with each plod
	local headRoar = 12 * roar
	local headX = nod + 2 * breathe - 9 * crouch + headRoar - 6 * lift - 7 * impact
	pose.Head = ang(headX, look + headShake, 7 * wave(t, 0.5, -0.12) * idleW - 5 * lift + 4 * lingerW + 6 * shake * wave(t, 3.1))

	-- JAW: slightly open at idle (teeth + black mouth read), munches, HUGE roar
	local munch = math.max(0, wave(t, 0.6, 0.2)) ^ 6 * idleW
	local jawX = -12 * (1 - roar) - 14 * munch - 66 * roar + 6 * crouch
	pose.Jaw = ang(jawX + 5 * shake * wave(t, 11), 0, 0)
	-- beard hangs and swings (counter the jaw so it keeps dangling) and is
	-- pushed forward (in jaw space) so it stays in front of the chest
	local jr = math.rad(-jawX)
	local dy, dz = -0.3 * roar, -1.2 * roar
	pose.Beard = CFrame.new(0, dy * math.cos(jr) - dz * math.sin(jr), dy * math.sin(jr) + dz * math.cos(jr))
		* ang(-0.75 * (jawX + 12) + 8 * wave(t, 0.5, -0.3) * idleW + 14 * lingerW - 8 * crouch - 10 * impact, 0, 8 * wave(t, 0.5, -0.35) * idleW + 10 * shake * wave(t, 6))

	-- cartoon blinks (double blink every other cycle) + squint on the crouch
	local bt = t % 3.2
	local blink = math.max(env(bt, 2.7, 0.06, 0.06, 0.08), env(t % 6.4, 3.05, 0.05, 0.05, 0.08))
	local lid = math.max(blink * (1 - roar), 0.45 * crouch)
	L.both(pose, "Lid", CFrame.new(0, 1.9 * (1 - lid), 0))
	local lidVis = lid > 0.03 and 0 or 1
	ctx.transparency("EyelidR", lidVis)
	ctx.transparency("EyelidL", lidVis)

	------------------------------------------------------------------
	-- CANOPY: wind lag + footfall hops + VIOLENT rattle + whip on the stomp.
	-- It counter-tilts against the head/chest throw so the roar face reads.
	------------------------------------------------------------------
	local counter = -0.6 * (headRoar + 16 * up)
	local hop = 0.45 * L.bounce(t, 1.0, -0.12) * idleW
	local cx = 4 * wind + 20 * crouch + counter - 4 * impact + 9 * lingerW + 22 * shake * wave(t, 7) + 4 * crouch * wave(t, 11)
	local cy = 4 * L.noise(t, 2.2, 0.2) + 20 * shake * wave(t, 5.3)
	local cz = 14 * wave(t, 0.5, -0.2) * idleW + 3 * wind + 22 * shake * wave(t, 6.1, 0.3) + 7 * lingerW - 7 * lift
	pose.Canopy = pa(
		0.5 * shake * wave(t, 9),
		hop + 0.6 * shake + 0.8 * shake * L.bounce(t, 6) - 0.6 * impact - 0.4 * crouch,
		0,
		cx, cy, cz
	)
	pose.CanopyTop = pa(0, 0.3 * L.bounce(t, 1.0, -0.2) * idleW, 0,
		6 * wave(t, 0.5, -0.3) * idleW + 28 * shake * wave(t, 7.5, 0.2) + 8 * lingerW - 8 * impact,
		10 * shake * wave(t, 5),
		12 * wave(t, 0.5, -0.34) * idleW + 26 * shake * wave(t, 6.6))
	local side = 9 * wave(t, 0.5, -0.3) * idleW + 3 * wind
	pose.CanopyR = ang(4 * wind + 20 * shake * wave(t, 6.4), 0, side + 28 * shake * wave(t, 7.2, 0.1) + 12 * lingerW + 10 * up - 8 * crouch)
	pose.CanopyL = L.mirror(ang(4 * wind + 20 * shake * wave(t, 6.4, 0.4), 0, -side + 28 * shake * wave(t, 7.2, 0.6) - 12 * lingerW + 10 * up - 8 * crouch))
	pose.CanopyBack = ang(-7 * wave(t, 0.5, -0.35) * idleW + 26 * shake * wave(t, 6.8, 0.3) - 10 * lingerW + 10 * impact, 6 * shake * wave(t, 4.4), 0)

	-- blossoms bob on their own springs
	for i = 1, NBLOOM do
		local ph = i * 0.137
		pose["Bloom" .. i] = ang(
			12 * wave(t, 0.9, ph) + 45 * shake * wave(t, 8, ph) + 16 * lingerW,
			22 * wave(t, 0.4, ph),
			12 * wave(t, 0.7, ph + 0.3) + 40 * shake * wave(t, 7, ph * 2)
		)
	end

	------------------------------------------------------------------
	-- ARMS: big dangly swing, swept back on the crouch, flung HIGH in a
	-- goalpost "awakening" pose, swung out for balance, slammed down
	------------------------------------------------------------------
	local armShake = 9 * shake * wave(t, 6)
	local function armPose(s)
		local swing = 28 * s * wave(t, 0.5, 0.25) * idleW
		return ang(swing - 58 * crouch + 8 * up + 10 * lift + 40 * impact,
			-10 * crouch,
			10 + 6 * wave(t, 0.5) * idleW + 8 * crouch + 85 * up + armShake + 50 * lift - 8 * impact + 3 * crouch * wave(t, 12))
	end
	L.both(pose, "Arm", armPose(1), armPose(-1))
	local function forePose(s)
		local lag = 14 * wave(t, 0.5, 0.15 + (s < 0 and 0.5 or 0)) * idleW
		return ang(10 + lag + 28 * crouch - 12 * up + 28 * impact + 12 * lingerW, 0, 50 * up + 10 * shake * wave(t, 7) + 25 * lift)
	end
	L.both(pose, "Forearm", forePose(1), forePose(-1))
	local function handPose(s)
		local lag = 14 * wave(t, 0.5, 0.05 + (s < 0 and 0.5 or 0)) * idleW
		-- little finger wiggle at idle, hands splay open on the roar
		return ang(lag + 22 * crouch - 18 * up + 22 * impact, 0, 28 * up + 14 * shake * wave(t, 8) + 5 * wave(t, 1.3) * idleW)
	end
	L.both(pose, "Hand", handPose(1), handPose(-1))

	------------------------------------------------------------------
	-- FLOATING VOXEL CUBES: drift on the flanks, tumble, flung out on beats
	------------------------------------------------------------------
	pose.Orbit = ang(0, 20 * wave(t, 0.07) + 10 * up, 0)
	for i = 1, 5 do
		local out = 2.4 * up + 2.2 * impact
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(out * dir * 0.5, 1.0 * wave(t, 0.55, i * 0.21) + out * 0.6, 0, 70 * t * dir + 90 * i, 100 * t, 30 * i)
	end

	------------------------------------------------------------------
	-- ROOT SPIKES erupt in a ring, rippling out from the stomping foot
	------------------------------------------------------------------
	for i = 1, 7 do
		local d = SPROUT_DELAY[i]
		local start = 4.92 + d
		local e = env(c, start, 0.14, 0.5, 0.3, "backOut", "backIn")
		local over = 0.6 * math.sin(math.clamp((c - start) / 0.3, 0, 1) * math.pi) -- extra pop overshoot
		pose["Sprout" .. i] = pa(0, -5.4 * (1 - e) + over * e, 0, 0, 0, 7 * wave(t, 2.5, i * 0.2) * e)
		local vis = (e > 0.02) and 0 or 1
		ctx.transparency("Sprout" .. i .. "a", vis)
		ctx.transparency("Sprout" .. i .. "b", vis)
		ctx.transparency("Sprout" .. i .. "c", vis)
		ctx.transparency("Sprout" .. i .. "d", vis)
		if ctx.crossed(start + 0.03) then
			ctx.emit("RootDust", 6)
		end
	end

	------------------------------------------------------------------
	-- EFFECTS on the beats
	------------------------------------------------------------------
	ctx.enable("RoarPetals", c > 3.5 and c < 4.4)
	ctx.light("MouthLight", 1.2 * roar)
	if ctx.crossed(3.5) then
		ctx.emit("LeafBurst", 55)
		ctx.emit("SparkleBurst", 40)
	end
	if ctx.crossed(4.93) then
		ctx.emit("StompDust", 40)
		ctx.emit("SparkleBurst", 20)
	end
	if ctx.crossed(5.05) then
		ctx.emit("LeafBurst", 25)
	end
end

return M
