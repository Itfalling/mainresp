--!nocheck
-- Temple Turtle motion: a sleepy, kind old grandpa.
-- Idle: slow lazy paddling, hover bob, the head keeps nodding off (droops
-- lower and lower, droopy lids sink, a snot bubble swells, blocky Zzz float
-- up) and then SNAPS awake, followed by a huge yawn. Seaweed sways, bubbles.
-- Signature "SHRINE AWAKENING" (12 s loop):
--   2.32  snaps awake (bubble pops), 2.6 big YAWN (jaw 60, flippers stretch)
--   4.1   anticipation: the head tucks INTO the shell, flippers fold, body
--         sinks, the shrine shivers while the crystal charges (motes suck in)
--   5.0   crystal FLASH (sun rays + burst), 5.05 head SHOOTS out surprised:
--         eyes pop, brows fly up, mouth "O"
--   5.3   leaps up, flippers flap hard, a happy 360 FLIP-ROLL, the temple
--         rattles (roof hops, fallen column bounces)
--   6.85  lands: squash, bubble + marble burst, roof slams, bounce back
--   7.0   happy wiggle + grin + clapping flippers
--   8.2   sighs and dozes back off (nod, "huh?" at 10.6, zzz...)
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 12

local sin, pi, max, min, abs = math.sin, math.pi, math.max, math.min, math.abs
local TAU = 2 * pi
local HOVER = 1.7 -- extra hover height so flippers/beard clear the floor in the big beats

local FLASH = 5.0
local LAND = 6.85
local BLINKS = { 4.0, 7.75, 8.6, 9.3 }
local WEEDS = { { "WeedA", 0.0 }, { "WeedB", 0.3 }, { "WeedC", 0.55 }, { "WeedD", 0.8 } }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes
	------------------------------------------------------------------
	-- how sleepy he is (0 awake .. 1 nodding right off). Continuous over the loop.
	local drowsy = L.track(c, {
		{ 0, 0.55 }, { 2.2, 1.0, "quadIn" }, { 2.32, 0, "expoOut" },
		{ 8.2, 0 }, { 9.8, 0.7, "sineInOut" }, { 10.5, 0.95, "quadIn" },
		{ 10.62, 0.3, "expoOut" }, { 12, 0.55, "sineInOut" },
	})
	local jolt = max(L.env(c, 2.3, 0.06, 0.15, 0.5, "expoOut", "cubicInOut"), 0.5 * L.env(c, 10.58, 0.06, 0.1, 0.4, "expoOut", "cubicInOut"))
	local yawn = L.env(c, 2.6, 0.55, 0.55, 0.45, "cubicOut", "backIn")
	local stretch = L.env(c, 2.7, 0.5, 0.6, 0.5, "backOut", "cubicInOut")
	local tuck = L.env(c, 4.1, 0.55, 0.35, 0.08, "backIn", "expoIn")
	local charge = L.env(c, 4.2, 0.8, 0.05, 0.6, "quadIn", "cubicOut")
	local flash = L.env(c, FLASH, 0.04, 0.12, 0.45, "linear", "quadOut")
	local shoot = L.env(c, 5.05, 0.18, 1.6, 0.6, "backOut", "cubicInOut")
	local surprise = L.env(c, 5.05, 0.1, 0.55, 0.35, "backOut", "cubicInOut")
	local air = L.env(c, 5.2, 0.15, 1.35, 0.2)
	local rattle = max(L.env(c, 5.15, 0.1, 1.5, 0.6), 0.25 * charge)
	local land = L.env(c, LAND, 0.04, 0.06, 0.8, "linear", "elasticOut")
	local happy = L.env(c, 6.95, 0.2, 1.05, 0.5)
	local busy = L.env(c, 4.0, 0.2, 4.1, 0.5)
	local idleW = 1 - busy
	local paddleW = 1 - 0.85 * max(tuck, air) - 0.5 * yawn

	------------------------------------------------------------------
	-- BODY: hover bob, sink in the tuck, leap + barrel flip-roll, squash
	------------------------------------------------------------------
	local jumpY = L.track(c, {
		{ 4.1, 0 }, { 4.9, -1.1, "cubicOut" }, { 5.1, -1.2 }, { 5.75, 4.8, "cubicOut" },
		{ 6.2, 5.5, "quadOut" }, { LAND, -1.3, "quadIn" }, { 7.0, -1.4 },
		{ 7.35, 0.7, "backOut" }, { 7.8, 0, "quadInOut" },
	})
	local roll = L.track(c, { { 5.35, 0 }, { 6.5, 360, "cubicInOut" } })
	if c > 6.5 then roll = 0 end
	local sigh = L.env(c, 8.5, 0.6, 0.2, 0.9, "sineInOut", "sineInOut")
	local by = HOVER + 0.5 * wave(t, 0.25) * (1 - 0.6 * busy) + jumpY - 0.4 * drowsy + 0.5 * sigh
	by += 0.25 * L.wave(t, 0.5, 0.25) * stretch
	local pitchB = 3 * wave(t, 0.25, 0.2) * idleW - 3 * drowsy - 6 * tuck + 14 * air * (1 - L.remap(c, 6.0, 6.8)) - 9 * land
		+ 6 * sigh
	local yawB = 4 * wave(t, 1 / 6, 0.1) * idleW + 14 * happy * sin(TAU * 2.5 * (c - 6.95))
	local rollB = 4 * wave(t, 0.25, 0.05) * idleW + roll + 6 * happy * sin(TAU * 2.5 * (c - 7.05))
	pose.Body = pa(0, by, 0, pitchB, yawB, rollB)

	------------------------------------------------------------------
	-- NECK + HEAD: nodding off, snap awake, yawn, tuck in, SHOOT out
	------------------------------------------------------------------
	local ns = L.saw(t, 0.42)
	local sink = ns < 0.82 and (ns / 0.82) ^ 1.6 or (1 - (ns - 0.82) / 0.18)
	local nod = drowsy * (0.5 + 0.5 * sink)
	local headBob = 3 * wave(t, 0.5, 0.15) * idleW
	local nz = 4.3 * tuck - 1.3 * shoot
	local ny = -0.5 * nod - 0.9 * tuck + 0.3 * shoot
	pose.Neck = pa(0, ny, nz, -11 * nod + 10 * yawn + 8 * jolt - 6 * tuck + 8 * surprise,
		2 * wave(t, 1 / 6), 0)
	local happyBob = happy * sin(TAU * 2.5 * (c - 7.0))
	pose.Head = ang(
		-24 * nod + headBob + 18 * jolt + 26 * yawn + 4 * tuck + 14 * surprise - 8 * land + 8 * abs(happyBob) - 10 * sigh,
		6 * wave(t, 1 / 6, 0.4) * idleW - 10 * happyBob,
		7 * drowsy * wave(t, 0.25, 0.3) + 12 * happyBob - 6 * yawn
	)

	-- jaw: snoring agape while dozing, huge yawn, surprised "O", happy chomps
	local jaw = -7 * drowsy - 62 * yawn - 30 * surprise
	jaw += -14 * happy * L.wave01(c, 3.0, 0.25)
	jaw += -8 * L.env(c, 3.75, 0.1, 0.1, 0.2) * (1 - yawn) -- lip smack
	pose.Jaw = ang(min(0, jaw), 0, 0)
	-- beard swings with follow-through
	local bsw = 8 * wave(t, 0.5, 0.35) + 20 * air * sin(TAU * 1.6 * (c - 5.3)) + 14 * jaw / -62 * 0.5
	pose.Beard1 = ang(bsw * 0.6 - 10 * jolt - 14 * land - 16 * nod, 0, 6 * wave(t, 0.25, 0.2) + 8 * happyBob)
	pose.Beard2 = ang(bsw - 14 * jolt - 20 * land - 26 * nod, 0, 10 * wave(t, 0.25, 0.45) - 10 * happyBob)

	------------------------------------------------------------------
	-- FACE: droopy lids, blinks, squeeze in the yawn, wide eyes on surprise
	------------------------------------------------------------------
	local close = drowsy * 0.85
	close = max(close, yawn * 1.0, 0.3 * happy, 0.95 * tuck)
	for _, b in BLINKS do
		close = max(close, L.env(c, b, 0.07, 0.06, 0.12))
	end
	local wide = max(surprise, 0.8 * jolt)
	close = close * (1 - wide)
	local lidY = -1.5 * close + 1.4 * wide
	L.both(pose, "Lid", CFrame.new(0, lidY, 0))
	local lidTr = lidY > 0.55 and 1 or 0
	for _, s in { "R", "L" } do
		ctx.transparency("LidF" .. s, lidTr)
		ctx.transparency("Lash" .. s, lidTr)
	end
	L.both(pose, "Eye", CFrame.new(0, 0.12 * surprise, -0.7 * surprise))
	local browUp = 0.45 * surprise + 0.45 * jolt - 0.15 * drowsy + 0.25 * happy
	L.both(pose, "Brow", pa(0, browUp, -0.1 * surprise, 0, 0, -8 * drowsy + 14 * surprise + 10 * jolt - 8 * yawn + 4 * happyBob))

	-- snot bubble: swells and shrinks with each snore, POPS on the snap awake
	local br = L.wave01(c, 0.6, 0.75)
	local lvl = 0
	if c < 2.32 then
		local grow = L.remap(c, 0, 2.1)
		lvl = 1 + math.floor(L.clamp01((grow * 1.7 + br * 0.9) / 3) * 2.99)
		if c > 1.95 then lvl = 3 end
	elseif c > 9.9 and c < 10.57 then
		lvl = 1 + math.floor(L.clamp01(L.remap(c, 9.9, 10.45) * 0.8 + 0.4 * br) * 1.99)
	elseif c > 11.1 then
		lvl = 1
	end
	ctx.transparency("SnoreDrip", lvl > 0 and 0.3 or 1)
	for i = 1, 3 do
		local on = i == lvl
		ctx.transparency("Snore" .. i .. "a", on and 0.25 or 1)
		ctx.transparency("Snore" .. i .. "b", on and 0.25 or 1)
		ctx.transparency("Snore" .. i .. "c", on and 0.25 or 1)
		ctx.transparency("Snore" .. i .. "g", on and 0.05 or 1)
	end

	-- Zzz: small -> medium -> big letters pop in one after another, drift up and fade
	local zzW = drowsy > 0.45 and not (c > 2.25 and c < 9.6)
	for k = 1, 3 do
		local n = "Zzz" .. k
		local p = (t * 0.45 - (k - 1) / 3) % 1
		local pop = L.ease.backOut(L.remap(p, 0, 0.15))
		pose[n] = pa(0.5 * p + 0.2 * wave(t, 0.8, k * 0.3), 1.0 * p - 0.4 * (1 - pop), 0.3 * p,
			0, 15 * wave(t, 0.4, k * 0.25), 12 * wave(t, 0.6, k * 0.2))
		local tr = 1
		if zzW then
			tr = p < 0.1 and (1 - p / 0.1) or (p > 0.72 and (p - 0.72) / 0.28 or 0)
		end
		for j = 1, 5 do
			ctx.transparency(n .. "f" .. j, tr)
			ctx.transparency(n .. "b" .. j, tr)
		end
	end

	------------------------------------------------------------------
	-- FLIPPERS: lazy paddle, stretch in the yawn, fold in the tuck, flap
	-- hard through the flip, clap when happy
	------------------------------------------------------------------
	local flapT = c - 5.2
	-- hard flapping eases off right before touchdown so the blades don't stab the floor
	local hardW = air * (1 - 0.7 * L.smoothstep(L.remap(c, 6.4, 6.8)))
	local function fin(prefix, phase, amp, hz)
		local s = wave(t, hz, phase)
		local sw = wave(t, hz, phase + 0.25)
		local hard = hardW * sin(TAU * 3.0 * flapT + phase * TAU)
		local clap = happy * sin(TAU * 2.5 * (c - 7.0) + phase * TAU)
		local flap = amp * (0.25 + 0.75 * s) * paddleW - 6 * drowsy * idleW + 40 * stretch - 10 * tuck + 60 * hard + 12 * happy + 22 * clap + 20 * land
		local sweep = 0.8 * amp * sw * paddleW + 20 * stretch - 55 * tuck + 20 * air + 30 * happy + 20 * clap
		local tip = 0.8 * amp * (0.25 + 0.75 * wave(t, hz, phase - 0.15)) * paddleW + 25 * stretch - 20 * tuck
			+ 45 * hardW * sin(TAU * 3.0 * flapT + phase * TAU - 1.0) + 10 * happy + 16 * clap - 10 * land
		L.both(pose, prefix, ang(0, sweep, flap))
		L.both(pose, prefix .. "Tip", ang(0, 0, tip))
	end
	fin("Flip", 0, 26, 0.25)
	fin("Rear", 0.5, 22, 0.25)

	-- stubby tail wag
	local wag = 12 * wave(t, 0.5) * idleW + 30 * happy * sin(TAU * 3 * (c - 7.0)) + 20 * air * sin(TAU * 2 * flapT)
	pose.Tail1 = ang(-8 * tuck + 10 * land, wag, 0)
	pose.Tail2 = ang(-10 * land, 1.3 * wag + 8 * wave(t, 0.5, -0.2), 0)

	------------------------------------------------------------------
	-- TEMPLE: shiver while charging, rattle through the flip, roof hops
	------------------------------------------------------------------
	local shiverR = rattle * (5 * sin(TAU * 9 * c) + 3 * sin(TAU * 13 * c + 1))
	local shiverZ = rattle * (4 * sin(TAU * 11 * c + 0.5))
	pose.Shrine = pa(0, 0.25 * rattle * abs(sin(TAU * 6 * c)), 0, shiverR, 0, shiverZ)
	local roofPop = L.env(c, LAND, 0.08, 0.05, 0.6, "quadOut", "bounceOut")
	local roofY = 0.8 * rattle * abs(sin(TAU * 4.5 * c + 0.4)) + 1.2 * roofPop + 0.5 * flash
	pose.Roof = pa(0, roofY, 0, 8 * rattle * sin(TAU * 5 * c + 0.2) + 10 * roofPop, 25 * roofPop, 7 * rattle * sin(TAU * 6 * c + 1.3) - 8 * roofPop)
	local fallenPop = L.env(c, LAND + 0.04, 0.1, 0.05, 0.55, "quadOut", "bounceOut")
	pose.Fallen = pa(0, 0.5 * rattle * abs(sin(TAU * 5.5 * c + 1.0)) + 1.0 * fallenPop, 0, 10 * rattle * sin(TAU * 7 * c), 15 * fallenPop, -15 * fallenPop)
	-- crystal: slow spin + bob, rises and whirls while charging
	local spin = 20 * t + 720 * L.ease.cubicInOut(L.remap(c, 4.2, 5.6))
	pose.Crystal = pa(0, 0.12 * wave(t, 0.5) + 0.45 * charge + 0.3 * flash, 0, 0, spin, 0)

	-- seaweed sway (whips around in the flip)
	for _, w in WEEDS do
		local ph = w[2]
		local whip = air * 28 * sin(TAU * 1.5 * (c - 5.3) + ph * TAU)
		local a1 = 9 * wave(t, 0.5, ph) + whip + 12 * land
		local b1 = 7 * wave(t, 0.25, ph + 0.2) + 0.6 * whip
		pose[w[1] .. "1"] = ang(a1, 0, b1)
		pose[w[1] .. "2"] = ang(1.5 * 9 * wave(t, 0.5, ph - 0.15) + 1.3 * whip + 16 * land, 0, 1.4 * 7 * wave(t, 0.25, ph + 0.05))
	end

	------------------------------------------------------------------
	-- floating marble cubes: bob + tumble, drawn in by the charge, flung
	-- out by the flash and the landing
	------------------------------------------------------------------
	local out = 2.2 * flash + 1.8 * land
	local pull = 0.35 * charge
	local CUBEP = { { 8.6, 10.6, -4.2 }, { -9.0, 9.4, 1.0 }, { 7.4, 13.4, 5.6 }, { -6.6, 13.6, -5.2 }, { -7.8, 6.2, 7.0 }, { 9.6, 6.4, 3.0 } }
	for i = 1, 6 do
		local p = CUBEP[i]
		local ph = i * 0.17
		local dir = i % 2 == 0 and -1 or 1
		local nx, nz = p[1] / 10, (p[3] - 0.5) / 10
		local k = out - 10 * pull
		local dx = 0.6 * wave(t, 0.25, ph) + nx * k
		local dy = 0.8 * wave(t, 0.5, ph + 0.3) + 0.5 * out + 0.4 * air * 5
		local dz = 0.6 * wave(t, 0.25, ph + 0.25) + nz * k
		pose["Cube" .. i] = pa(dx, dy * 0.6, dz, 30 * t * dir + 25 * i, 45 * t, 20 + 15 * i + 360 * flash * dir)
	end

	------------------------------------------------------------------
	-- effects on the beats
	------------------------------------------------------------------
	if ctx.crossed(2.32) then
		ctx.emit("SnorePop", 16)
		ctx.emit("BubbleBurst", 6)
	end
	if ctx.crossed(10.62) then
		ctx.emit("SnorePop", 6)
	end
	ctx.enable("YawnBubbles", c > 2.75 and c < 3.7)
	for k = 0, 5 do
		if ctx.crossed(4.25 + k * 0.13) then
			ctx.emit("ChargeMotes", 8)
		end
	end
	if ctx.crossed(FLASH + 0.01) then
		ctx.emit("AwakeBurst", 50)
		ctx.emit("BubbleBurst", 30)
		ctx.emit("CrystalSparkle", 12)
	end
	if ctx.crossed(5.6) then
		ctx.emit("RattleBits", 8)
	end
	if ctx.crossed(LAND + 0.01) then
		ctx.emit("BubbleBurst", 40)
		ctx.emit("RattleBits", 26)
		ctx.emit("AwakeBurst", 18)
	end
	if ctx.crossed(7.4) then
		ctx.emit("CrystalSparkle", 8)
	end
	ctx.transparency("CrystalFlash", flash > 0.02 and (1 - 0.75 * flash) or (charge > 0.3 and (1 - 0.35 * charge) or 1))
	local raysOn = c > FLASH and c < FLASH + 0.42
	for i = 1, 8 do
		ctx.transparency("Ray" .. i, raysOn and (0.1 + 0.8 * L.remap(c, FLASH + 0.2, FLASH + 0.42)) or 1)
	end
	ctx.light("CrystalLight", min(1.5, 0.45 + 0.1 * wave(t, 0.5) + 0.7 * charge + 1.0 * flash))
end

return M
