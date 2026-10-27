--!nocheck
-- Crystal Narwhal motion. Personality: HYPER & CHEERFUL - happy-puppy energy.
-- Always on: bouncy swim-hover, paddling flippers, wagging tail + flukes,
-- flapping ear-fins, darting pupils, blinks, bouncing brows, a grin that
-- "talks", orbiting cubes, a pulsing shrine crystal.
-- Idle gags:
--   0.3  HAPPY WIGGLE   whole-body wiggle + crazy tail wag, star eyes, heart pop
--   1.9  BARREL ROLL    squash, 360 roll with a happy squint, sparkle trail
--   3.0  HOP-HOP GIGGLE two puppy hops, giggle chatter, tongue out, bubbles
--   9.9  WINK + TWIRL   leans to the viewer, winks, blep, tusk ring twirl "ting!"
--  11.0  BLOWHOLE SPOUT inhale, surprised spout fountain of water cubes,
--                      giggle and a wet shimmy
-- Signature "CRYSTAL BREACH" (4.4 - 9.6):
--   4.4  DIVE       tips nose down to the "water", eyes determined, splash
--   5.0  BREACH     huge arc up (rise 10, pitch to +52), jaw "wheee", stars
--   5.55 SPIN       2 turns on the tusk axis, tusk beam + crystal rays, sparks
--   6.85 FIREWORK   crystal shard firework burst + flash
--   7.0  FALL       flips nose down, drops
--   7.65 SPLASHDOWN squash, water cubes + splash burst, cubes flung out
--   8.0  DOUBLE HOP joyful double hop, giggle, hearts, settle (9.6)
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 13

local sin, cos, pi, max, min, abs, rad = math.sin, math.cos, math.pi, math.max, math.min, math.abs, math.rad
local TAU = 2 * pi
local F = 1 / 13 -- whole cycles per loop

-- signature beats
local DIVE, LAUNCH, SPIN0, SPIN1, FW, FALL, SPLASH, HOP1, HOP2, SETTLE = 4.4, 5.0, 5.55, 6.8, 6.85, 7.0, 7.65, 8.0, 8.5, 9.6
-- idle gag beats
local WIG, ROLL, HOPS, WINK, SPOUT = 0.3, 1.9, 3.0, 9.9, 11.0

local BLINKS = { 1.55, 4.15, 9.75, 12.6 }

-- firework shard directions (spread on a sphere)
local SHARD = {}
for i = 1, 10 do
	local a = (i - 1) * 2.39996 -- golden angle
	local yy = 1 - 2 * (i - 0.5) / 10
	local r = math.sqrt(1 - yy * yy)
	SHARD[i] = Vector3.new(r * cos(a), yy * 0.8 + 0.25, r * sin(a))
end
local SH0 = Vector3.new(0, 21, -3) -- shard rest position (build)
local BODY0 = Vector3.new(0, 9.6, -1) -- body pivot (build)

-- how much the body has to lift so a pitched body clears the floor
local function guard(p)
	local s, co = sin(rad(p)), cos(rad(p))
	local front = -15.4 * s + 8.3 * co - 9.3 -- chin / open jaw (nose down lowers it)
	local tail = 19.5 * s - 1.2 * co - 9.0 -- flukes (nose up lowers them)
	return max(0, front, tail)
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes
	------------------------------------------------------------------
	local busy = L.env(c, DIVE - 0.1, 0.25, SETTLE - DIVE - 0.3, 0.4)
	local idleW = 1 - busy
	local wig = L.env(c, WIG, 0.2, 1.0, 0.25)
	local rollE = L.env(c, ROLL, 0.1, 0.85, 0.2)
	local hops = L.env(c, HOPS, 0.1, 1.0, 0.25)
	local wink = L.env(c, WINK, 0.2, 0.7, 0.3, "backOut", "quadInOut")
	local spoutE = L.env(c, SPOUT, 0.25, 1.1, 0.3)
	local dive = L.env(c, DIVE, 0.45, 0.1, 0.25, "cubicOut", "quadIn")
	local air = L.env(c, LAUNCH, 0.35, FALL - LAUNCH - 0.2, 0.45, "backOut", "quadIn")
	local spinOn = L.env(c, SPIN0, 0.1, SPIN1 - SPIN0 - 0.15, 0.15)
	local fwE = L.env(c, FW, 0.05, 0.25, 0.6, "expoOut", "quadIn")
	local splashE = L.env(c, SPLASH, 0.06, 0.12, 0.35, "quadOut", "backOut")
	local joy = L.env(c, SPLASH + 0.25, 0.2, 1.4, 0.4)
	local giggle = max(hops, L.env(c, HOP1, 0.1, 1.2, 0.3), 0.8 * L.env(c, SPOUT + 0.9, 0.1, 0.4, 0.2))

	------------------------------------------------------------------
	-- BODY: hover-bob, gags, breach arc, spin on the tusk axis
	------------------------------------------------------------------
	local bob = 0.6 * wave(t, 6 * F) + 0.2 * wave(t, 15 * F, 0.3)
	-- puppy hops (idle) and the double hop after the splash
	local hopY = L.track(c, {
		{ HOPS, 0 }, { HOPS + 0.1, -0.7, "quadOut" }, { HOPS + 0.35, 2.4, "quadOut" }, { HOPS + 0.58, -0.6, "quadIn" },
		{ HOPS + 0.8, 1.8, "quadOut" }, { HOPS + 1.02, -0.5, "quadIn" }, { HOPS + 1.3, 0, "quadOut" },
	}) + L.track(c, {
		{ HOP1 - 0.05, 0 }, { HOP1 + 0.22, 3.2, "quadOut" }, { HOP1 + 0.45, -0.8, "quadIn" },
		{ HOP2 + 0.2, 2.4, "quadOut" }, { HOP2 + 0.42, -0.7, "quadIn" }, { HOP2 + 0.7, 0.3, "quadOut" }, { SETTLE, 0, "quadInOut" },
	})
	-- breach: dive dips the nose, then a big arc up, then splash down
	local pitchB = L.track(c, {
		{ DIVE, 0 }, { DIVE + 0.45, -34, "cubicOut" }, { LAUNCH, -36 },
		{ LAUNCH + 0.4, 50, "backOut" }, { LAUNCH + 0.55, 42, "quadInOut" }, { SPIN1, 42 },
		{ FW + 0.1, 52, "quadOut" }, { FALL + 0.15, 30, "quadInOut" }, { SPLASH - 0.22, -28, "quadIn" },
		{ SPLASH, 6, "quadOut" }, { SPLASH + 0.18, -3, "quadInOut" }, { HOP1 + 0.2, 0, "quadInOut" },
	})
	local liftB = L.track(c, {
		{ LAUNCH - 0.02, 0 }, { LAUNCH + 0.45, 14.5, "cubicOut" }, { SPIN1, 15.5, "sineInOut" },
		{ FW + 0.12, 16.5, "quadOut" }, { SPLASH, -1.2, "quadIn" }, { SPLASH + 0.15, -1.5, "quadOut" },
		{ HOP1, -0.4, "quadOut" }, { HOP1 + 0.1, 0, "quadOut" },
	})
	local zB = L.track(c, { { DIVE, 0 }, { DIVE + 0.45, -1.5, "cubicOut" }, { LAUNCH + 0.5, -3.0, "quadOut" }, { FALL, -2.0 }, { SPLASH, -1.0, "quadIn" }, { SETTLE, 0, "quadInOut" } })
	local spin = L.track(c, { { SPIN0, 0 }, { SPIN1, 720, "cubicInOut" } })

	-- idle gags: wiggle, barrel roll, wet shimmy
	local wiggle = sin(TAU * 3.2 * (c - WIG)) * wig
	local rollA = L.track(c, { { ROLL, 0 }, { ROLL + 0.2, -18, "quadOut" }, { ROLL + 0.85, 360, "backOut" }, { ROLL + 1.0, 360 } })
	if c < ROLL or c > ROLL + 1.0 then rollA = 0 end
	local shimmy = L.env(c, SPOUT + 1.0, 0.1, 0.35, 0.15) * sin(TAU * 6 * c)
	local rollDip = L.env(c, ROLL, 0.18, 0.1, 0.3, "quadOut", "quadInOut")

	local pitch = pitchB + 5 * wave(t, 6 * F, 0.25) * idleW - 8 * dive * 0
		+ 8 * L.env(c, SPOUT, 0.25, 0.3, 0.3) - 6 * hops * sin(TAU * 2.2 * (c - HOPS)) + 6 * wink
	local yaw = 14 * wiggle + 6 * wave(t, 3 * F) * idleW - 16 * wink + 6 * L.noise(t, 2.2, 0.35) * idleW
	local roll = 10 * wiggle + rollA + 5 * wave(t, 4 * F, 0.1) * idleW + 14 * shimmy + 6 * wink
	local by = bob * (1 - 0.7 * busy) + hopY + liftB - 1.0 * rollDip + 4.2 * rollE + 0.8 * spoutE * L.env(c, SPOUT + 0.35, 0.1, 0.15, 0.4)
	by = max(by + 1.6, guard(pitch))
	local bx = 0.4 * wave(t, 3 * F, 0.2) * idleW + 0.6 * wiggle
	local bz = zB
	-- spin about the tusk axis (tilted 27 deg up in the body frame)
	local spinCF = ang(27, 0, 0) * ang(0, 0, spin) * ang(-27, 0, 0)
	pose.Body = pa(bx, by, bz, 0, 0, 0) * ang(pitch, yaw, 0) * spinCF * ang(0, 0, roll)

	------------------------------------------------------------------
	-- HEAD: happy bobbing, throws back on the "wheee", nods on landings
	------------------------------------------------------------------
	local land = splashE + 0.6 * L.env(c, HOP1 + 0.42, 0.05, 0.05, 0.25) + 0.6 * L.env(c, HOP2 + 0.4, 0.05, 0.05, 0.25)
	local headP = 4 * wave(t, 12 * F, 0.15) * idleW + 10 * air + 8 * land + 8 * dive
		+ 8 * giggle * wave(t, 52 * F) - 8 * L.env(c, SPOUT, 0.25, 0.3, 0.2) + 12 * L.env(c, SPOUT + 0.4, 0.08, 0.3, 0.3)
	local headY = 7 * wave(t, 4 * F, 0.3) * idleW - 16 * wink - 10 * wiggle
	local headR = 9 * wave(t, 5 * F) * idleW - 14 * wink + 8 * wiggle
	pose.Head = ang(headP, headY, headR)

	------------------------------------------------------------------
	-- FACE: jaw shapes, tongue, eyes, lids, brows, cheeks, ears
	------------------------------------------------------------------
	-- the grin always "talks" a little; chatters when giggling; WIDE on the
	-- breach + firework; closes into a determined grin on the dive
	local talk = 6 * L.wave01(t, 26 * F) * idleW
	local chatter = 16 * giggle * L.wave01(t, 117 * F)
	local jawOpen = 21 + talk + chatter + 26 * air + 18 * fwE + 22 * wig - 10 * splashE + 20 * joy * L.wave01(t, 104 * F)
		- 12 * dive + 20 * L.env(c, SPOUT + 0.4, 0.08, 0.3, 0.3) - 10 * L.env(c, SPOUT, 0.2, 0.15, 0.1)
		+ 10 * wink + 14 * rollE
	pose.Jaw = ang(-jawOpen, 0, 0)
	local blep = max(L.env(c, WINK + 0.15, 0.15, 0.55, 0.2, "backOut", "quadIn"), L.env(c, HOPS + 0.4, 0.12, 0.5, 0.2, "backOut", "quadIn"),
		0.8 * L.env(c, HOP2 + 0.5, 0.12, 0.5, 0.2, "backOut", "quadIn"))
	pose.Tongue = pa(0, 0.05 * blep, -1.1 * blep, -25 * blep + 8 * chatter / 16, 0, 10 * blep * wave(t, 52 * F))

	-- eyes pop a little on surprises
	local pop = max(L.env(c, SPOUT + 0.4, 0.06, 0.2, 0.3, "backOut"), 0.7 * air, 0.6 * fwE)
	L.both(pose, "Eye", pa(0, 0.1 * pop, -0.35 * pop, 0, 0, 4 * wave(t, 26 * F) * giggle))
	-- pupils: puppy darting glances, look ahead on the dive, up in the breach
	local dart = math.clamp(3 * sin(TAU * 4 * F * t), -1, 1) * 0.32
	local px = (dart + 0.08 * L.noise(t, 5.1, 3)) * idleW
	local py = (0.08 * L.noise(t, 8.2, 2.5)) * idleW + 0.35 * air - 0.25 * dive
	px += 0.3 * wink
	pose.PupilR = CFrame.new(px, py, 0)
	pose.PupilL = CFrame.new(px, py, 0)
	-- star (sparkle) eyes
	local stars = (wig > 0.3 and c < WIG + 1.3) or (c > LAUNCH + 0.15 and c < FALL) or (c > WINK + 0.6 and c < WINK + 1.0)
	-- happy squint "^ ^"
	local squint = (c > ROLL + 0.15 and c < ROLL + 0.95) or (giggle > 0.4) or (c > SPLASH and c < SPLASH + 0.3)
	local blink = 0
	for _, b in BLINKS do blink = max(blink, L.env(c, b, 0.05, 0.06, 0.08)) end
	blink = max(blink, L.env(c, SPOUT + 0.05, 0.08, 0.2, 0.06))
	local blinking = blink > 0.35 and not squint
	for _, side in { "R", "L" } do
		local winking = side == "L" and wink > 0.4
		local sq = squint or winking
		local closed = sq or blinking
		local st = stars and not closed
		ctx.transparency("LidSkin" .. side, closed and 0 or 1)
		ctx.transparency("Lash" .. side, (blinking and not sq) and 0 or 1)
		ctx.transparency("CaretA" .. side, sq and 0 or 1)
		ctx.transparency("CaretB" .. side, sq and 0 or 1)
		ctx.transparency("StarA" .. side, st and 0 or 1)
		ctx.transparency("StarB" .. side, st and 0 or 1)
		ctx.transparency("StarC" .. side, st and 0 or 1)
		ctx.transparency("PupilBig" .. side, st and 1 or 0)
		ctx.transparency("Iris" .. side, st and 1 or 0)
		ctx.transparency("Glint" .. side, st and 1 or 0)
		ctx.transparency("Glint2" .. side, st and 1 or 0)
	end
	-- star eyes twinkle (spin) while on
	local starSpin = stars and 25 * sin(TAU * 3 * c) or 0
	pose.PupilR = pose.PupilR * ang(0, 0, starSpin)
	pose.PupilL = pose.PupilL * ang(0, 0, -starSpin)

	-- brows: always lifted & bouncy; determined on the dive; shoot up on surprises
	local browUp = 0.25 + 0.15 * wave(t, 13 * F) * idleW + 0.45 * pop + 0.35 * giggle + 0.3 * wig - 0.55 * dive + 0.3 * joy
	local browTilt = -10 * dive + 6 * giggle
	pose.BrowR = pa(0, browUp, 0, 0, 0, browTilt)
	pose.BrowL = L.mirror(pa(0, browUp + 0.25 * wink, 0, 0, 0, browTilt - 12 * wink))
	-- cheeks puff on giggles, inhale and the splash squash
	local puff = 0.35 * giggle + 0.6 * L.env(c, SPOUT, 0.25, 0.25, 0.15) + 0.6 * splashE + 0.2 * L.wave01(t, 13 * F) * idleW
	L.both(pose, "Cheek", pa(0.45 * puff, 0.15 * puff, -0.25 * puff, 0, 0, 0))
	local blushOn = giggle > 0.3 or wink > 0.3 or joy > 0.3 or wig > 0.5
	ctx.transparency("BlushBigR", blushOn and 0 or 1)
	ctx.transparency("BlushBigL", blushOn and 0 or 1)
	-- floppy ear-fins: flap like happy puppy ears, pin back in the breach
	local flap = 14 * wave(t, 26 * F) * idleW + 28 * wig * sin(TAU * 6 * c) + 22 * giggle * sin(TAU * 8 * c)
		- 40 * air + 35 * land + 18 * wink
	pose.EarR = ang(0, -20 * air, flap)
	pose.EarL = L.mirror(ang(0, -20 * air, flap + 10 * wink))

	------------------------------------------------------------------
	-- FLIPPERS: paddle, flail on wiggles, sweep back in the breach
	------------------------------------------------------------------
	local paddle = wave(t, 13 * F)
	local fz = 18 * paddle * idleW + 30 * wig * sin(TAU * 6.4 * c) + 35 * giggle * sin(TAU * 4 * c + 1)
		- 45 * air + 45 * land + 20 * dive + 25 * wink * sin(TAU * 5 * c)
	local fy = -30 * air + 10 * wave(t, 13 * F, 0.25) * idleW - 15 * dive - 45 * rollE
	pose.FlipperR = ang(0, fy, fz)
	pose.FlipperL = L.mirror(ang(0, fy, fz + 20 * wig * sin(TAU * 6.4 * c + 1.5)))
	local ft = 16 * wave(t, 13 * F, -0.2) * idleW + 20 * land - 20 * air + 15 * giggle * sin(TAU * 4 * c)
	pose.FlipperTipR = ang(0, 0, ft)
	pose.FlipperTipL = L.mirror(ang(0, 0, ft))

	------------------------------------------------------------------
	-- TAIL: happy wag (side to side) + fluking, whips during the breach
	------------------------------------------------------------------
	local wagAmp = 12 * idleW + 34 * wig + 26 * giggle + 30 * joy
	local wagHz = 1.6 + 2.6 * max(wig, giggle, joy)
	local spinWhip = spinOn * 18
	for i = 1, 3 do
		local lag = (i - 1) * 0.12
		local wag = wagAmp * sin(TAU * wagHz * c - i * 0.9) * (0.6 + 0.2 * i)
		local fluke = 10 * wave(t, 13 * F, -lag) * idleW - 18 * dive * (i / 3) + 22 * air * sin(TAU * 2.2 * (c - LAUNCH) - i * 0.8)
			+ 25 * land * (i / 3) + spinWhip * sin(TAU * 3 * c - i)
		pose["Tail" .. i] = ang(fluke, wag / 3, 0)
	end
	local flukeA = 18 * wave(t, 13 * F, -0.4) + 30 * land + 20 * air * sin(TAU * 3 * c)
	pose.Fluke = ang(flukeA, 0, 0)
	local lobe = 10 * wave(t, 26 * F, -0.2) + 20 * wig * sin(TAU * 6 * c) + 25 * land
	L.both(pose, "Lobe", ang(0, 0, lobe))

	------------------------------------------------------------------
	-- TUSK: twirl + the orbiting gold ring, BEAM on the spin
	------------------------------------------------------------------
	local twirl = L.track(c, { { WINK + 0.3, 0 }, { WINK + 0.95, 360, "backOut" } })
	if c < WINK + 0.3 or c > WINK + 1.2 then twirl = 0 end
	pose.Tusk = ang(0, 0, twirl + 6 * wave(t, 13 * F))
	local ringSpin = 360 * 3 * F * t + 1080 * L.track(c, { { SPIN0, 0 }, { SPIN1, 1, "cubicInOut" } }) * 0
	local slide = 2.6 * wave(t, 3 * F) * idleW - 3.0 * spinOn + 2.2 * L.env(c, WINK + 0.3, 0.3, 0.3, 0.4)
	pose.TuskRing = pa(0, 0, -slide, 0, 0, ringSpin + spin * 2 + twirl * 2)
	local beamOn = c > SPIN0 + 0.08 and c < FW
	ctx.transparency("BeamCore", beamOn and 0 or 1)
	ctx.transparency("BeamGlow", beamOn and 0.45 or 1)
	ctx.transparency("BeamRing", beamOn and (0.2 + 0.4 * L.wave01(t, 8)) or 1)
	-- crystal rays fan out from the body while spinning (perpendicular to the tusk)
	local raysOn = c > SPIN0 + 0.2 and c < FW + 0.15
	for i = 1, 8 do
		ctx.transparency("Ray" .. i, raysOn and ((i + math.floor(c * 12)) % 2 == 0 and 0.15 or 0.5) or 1)
	end
	pose.Rays = ang(27, 0, 0) * ang(0, 0, -spin * 0.5 + 200 * c)

	------------------------------------------------------------------
	-- SHRINE: wobbles with the body, crystal heart pulses + pops
	------------------------------------------------------------------
	pose.Shrine = ang(3 * land + 2 * wave(t, 6 * F, 0.4), 0, 4 * wiggle + 3 * shimmy)
	local pulse = L.wave01(t, 13 * F)
	pose.ShrineCrystal = pa(0, 0.15 * pulse + 0.6 * fwE + 0.4 * L.env(c, SPLASH, 0.05, 0.05, 0.4, "quadOut", "bounceOut"), 0, 0, 25 * pulse + 90 * fwE, 0)

	------------------------------------------------------------------
	-- HEARTS: pop above the head on giggles / wink / the double hop
	------------------------------------------------------------------
	local function heart(t0)
		local u = (c - t0) / 1.1
		if u < 0 or u > 1 then return nil end
		return u
	end
	for _, side in { "R", "L" } do
		local u = heart(side == "R" and (HOPS + 0.3) or (HOPS + 0.55))
			or heart(side == "R" and (HOP1 + 0.3) or (HOP2 + 0.2))
			or (side == "R" and heart(WIG + 0.6) or heart(WINK + 0.3))
		local on = u ~= nil
		local uu = u or 0
		local s = L.ease.backOut(min(1, uu * 4))
		local cfH = pa(0, -1.2 * (1 - s) + 2.2 * uu, 0, 0, 0, 12 * sin(TAU * 2 * uu))
		if side == "R" then pose.HeartR = cfH else pose.HeartL = L.mirror(cfH) end
		for _, k in { "A", "B", "C", "D" } do
			ctx.transparency("Heart" .. k .. side, on and (uu > 0.8 and 0.6 or 0) or 1)
		end
	end

	------------------------------------------------------------------
	-- BLOWHOLE SPOUT: fountain of water cubes
	------------------------------------------------------------------
	for k = 1, 5 do
		local u = (c - (SPOUT + 0.4) - (k - 1) * 0.06) / 1.0
		if u > 0 and u < 1 then
			local a = k * 1.3
			local r = 2.8 * u
			local y = 24 * u - 20 * u * u
			pose["Spout" .. k] = pa(r * cos(a), y, r * sin(a) * 0.6, 200 * u, 120 * u * k, 45)
			ctx.transparency("SpoutP" .. k, u > 0.85 and 0.6 or 0.05)
		else
			pose["Spout" .. k] = CFrame.new()
			ctx.transparency("SpoutP" .. k, 1)
		end
	end

	------------------------------------------------------------------
	-- FIREWORK shards: burst from the body at the apex, arc, fade
	------------------------------------------------------------------
	local origin = BODY0 + Vector3.new(0, liftB + 5, zB) -- around the shrine at the apex
	for i = 1, 10 do
		local u = (c - FW) / 1.15
		if u > 0 and u < 1 then
			local e = L.ease.expoOut(min(1, u * 1.2))
			local p = origin + SHARD[i] * (17 * e) + Vector3.new(0, -6 * u * u, 0) - SH0
			pose["Shard" .. i] = pa(p.X, p.Y, p.Z, 360 * u * (i % 2 == 0 and 1 or -1), 200 * u, 45)
			ctx.transparency("ShardP" .. i, u > 0.8 and 0.6 or 0)
		else
			pose["Shard" .. i] = CFrame.new()
			ctx.transparency("ShardP" .. i, 1)
		end
	end

	------------------------------------------------------------------
	-- SPLASH water cubes: radial parabola from the splashdown
	------------------------------------------------------------------
	for i = 1, 10 do
		local u = (c - SPLASH - (i % 3) * 0.04) / 0.95
		if u > 0 and u < 1 then
			local a = (i - 1) * TAU / 10 + 0.3
			local r = (5 + (i % 3) * 2.5) * L.ease.quadOut(u)
			local y = (8 + (i % 4) * 2) * 4 * u * (1 - u)
			pose["Splash" .. i] = pa(r * cos(a), y, r * sin(a), 300 * u, 200 * u, 0)
			ctx.transparency("SplashP" .. i, u > 0.85 and 0.6 or 0.1)
		else
			pose["Splash" .. i] = CFrame.new()
			ctx.transparency("SplashP" .. i, 1)
		end
	end

	------------------------------------------------------------------
	-- floating cubes: orbit + tumble, flung out by the splash & firework
	------------------------------------------------------------------
	local fling = L.env(c, SPLASH, 0.12, 0.25, 0.9, "quadOut", "elasticOut") + 0.6 * fwE
	local ORB = { { 1, -1 }, { -1, 0 }, { 1, 1 }, { -1, 1 }, { 0, -1 } }
	for i = 1, 5 do
		local o = ORB[i]
		local dx = 0.8 * wave(t, 2 * F, i * 0.21) + 2.5 * fling * o[1]
		local dy = 1.0 * wave(t, 4 * F, i * 0.27) + 1.5 * fling
		local dz = 0.8 * wave(t, 2 * F, i * 0.21 + 0.25) + 2.0 * fling * o[2]
		local s = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(dx, dy, dz, 360 * 2 * F * t * s + 30 * i, 360 * 3 * F * t, 25 * i + 120 * fling * s)
	end

	------------------------------------------------------------------
	-- effects on the beats
	------------------------------------------------------------------
	ctx.enable("TuskSparks", beamOn)
	if ctx.crossed(WIG + 0.6) then ctx.emit("GiggleBurst", 10) end
	if ctx.crossed(ROLL + 0.5) then ctx.emit("Sparkle", 14) end
	if ctx.crossed(HOPS + 0.35) then ctx.emit("Giggles", 8) end
	if ctx.crossed(HOPS + 0.8) then ctx.emit("GiggleBurst", 10) end
	if ctx.crossed(DIVE + 0.45) then ctx.emit("SplashBurst", 14) end
	if ctx.crossed(LAUNCH + 0.05) then ctx.emit("SplashBurst", 30) end
	if ctx.crossed(SPIN0 + 0.2) then ctx.emit("TuskSparks", 20) end
	if ctx.crossed(FW) then ctx.emit("Firework", 70) end
	if ctx.crossed(FW + 0.12) then ctx.emit("Sparkle", 20) end
	if ctx.crossed(SPLASH) then
		ctx.emit("SplashBurst", 60)
		ctx.emit("AmbientBubbles", 12)
	end
	if ctx.crossed(HOP1 + 0.45) then ctx.emit("GiggleBurst", 12) end
	if ctx.crossed(HOP2 + 0.42) then ctx.emit("GiggleBurst", 12); ctx.emit("Giggles", 8) end
	if ctx.crossed(WINK + 0.95) then ctx.emit("TuskSparks", 16) end
	if ctx.crossed(SPOUT + 0.4) then ctx.emit("AmbientBubbles", 10) end
	ctx.light("TuskLight", min(1.5, 0.4 + 1.1 * spinOn + 0.6 * L.env(c, WINK + 0.85, 0.05, 0.1, 0.3)))
	ctx.light("ShrineLight", min(1.5, 0.4 + 0.25 * pulse + 1.0 * fwE))
end

return M
