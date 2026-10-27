--!nocheck
-- Nautilus Sentinel motion. Personality: CURIOUS & PLAYFUL.
-- Idle: hovering bob with a slow rock, tentacles wiggle with phase lag, the
-- head keeps peeking around ("what's that?" head tilts with one brow up),
-- the front tentacles reach out and poke-poke at things, a quick duck into
-- the shell and pop back out with an "oh!", blinks, siphon bubble puffs.
-- Signature "SENTINEL SPIRAL" (giddy spin):
--   4.3  anticipation - giddy squint, sink + wind-up twist, head and
--                       tentacles pull into the shell
--   4.95 action       - the shell spins like a top (4 turns) while rising,
--                       rune windows chase around the spiral, bubble jet
--   6.55 pop          - head shoots back out, tentacles flare WIDE, big
--                       surprised O face, sparkle pop
--   6.9  follow-thru  - dizzy circular wobble, pupils swirling, stars
--   7.7  settle       - happy smile + squinty eyes, little tentacle wave
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease

local M = {}
M.Cycle = 10

local rad, max, min, sin, cos, floor, pi, abs = math.rad, math.max, math.min, math.sin, math.cos, math.floor, math.pi, math.abs

local SPIN0, SPIN1, POP = 4.95, 6.55, 6.55
local TURNS = 4
local BLINKS = { 0.9, 3.0, 3.2, 9.35 }
local BETAS = { -112, -90, -68, -36, -21, -7, 7, 21, 36, 68, 90, 112 }

local function blinkAt(c)
	local b = 0
	for _, s in BLINKS do
		b = max(b, L.env(c, s, 0.06, 0.05, 0.09))
	end
	return b
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	--------------------------------------------------------------------
	-- envelopes
	--------------------------------------------------------------------
	local busy = L.env(c, 4.15, 0.3, 4.3, 0.5) -- fades the idle out/in
	local idleW = 1 - busy
	local giddy = L.env(c, 4.25, 0.15, 0.3, 0.15) -- squinty excited face before pulling in
	local retract = L.track(c, {
		{ 2.0, 0 }, { 2.15, 1.7, "quadOut" }, { 2.45, 1.7 }, { 2.62, 0, "backOut" }, -- the peek
		{ 4.5, 0 }, { 4.88, 4.8, "backIn" }, { SPIN1, 4.8 }, { SPIN1 + 0.22, 0, "backOut" },
	})
	local tuck = L.env(c, 4.45, 0.4, SPIN1 - 4.85, 0.12, "backIn", "quadOut")
	local peekTuck = L.env(c, 2.0, 0.12, 0.3, 0.2)
	local spinE = L.env(c, SPIN0, 0.3, SPIN1 - SPIN0 - 0.55, 0.25)
	local flare = L.env(c, POP, 0.16, 0.35, 0.9, "backOut", "cubicInOut")
	local surprise = L.env(c, POP, 0.08, 0.55, 0.25, "backOut")
	local peekOh = L.env(c, 2.55, 0.08, 0.2, 0.2, "backOut")
	local dizzy = L.env(c, 6.8, 0.25, 0.55, 0.9)
	local happy = L.env(c, 7.6, 0.2, 1.0, 0.35, "backOut")

	--------------------------------------------------------------------
	-- SHELL: hover, rock, twist wind-up, spin like a top, rise, dizzy wobble
	--------------------------------------------------------------------
	local spinYaw = L.track(c, {
		{ 4.3, 0 }, { 4.85, -45, "quadOut" }, { SPIN0, -45 }, { SPIN1, TURNS * 360, "quadInOut" },
	})
	if c > SPIN1 then
		spinYaw = 0
	end
	local lift = L.track(c, {
		{ 4.3, 0 }, { 4.8, -1.3, "quadOut" }, { 5.05, -1.5 }, { 6.3, 4.2, "quadOut" }, { 6.75, 4.5, "quadOut" },
		{ 7.55, 0, "quadInOut" }, { 7.72, -0.9, "quadOut" }, { 8.15, 0, "backOut" },
	})
	local hop = 0.8 * L.env(c, 8.0, 0.2, 0.0, 0.3, "quadOut", "bounceOut")
	local bob = 0.5 * wave(t, 0.4) + 0.25 * wave(t, 0.8, 0.2) * idleW
	-- look track (deg, + = monster's left) shared by shell, head and pupils
	local look = L.track(c, {
		{ 0.35, 0 }, { 0.6, -30, "backOut" }, { 1.75, -30 }, { 2.0, 0 },
		{ 2.75, 0 }, { 3.05, 32, "backOut" }, { 4.0, 32 }, { 4.3, 0 },
		{ 8.9, 0 }, { 9.15, -14, "backOut" }, { 9.6, -14 }, { 9.85, 0 },
	}) + 6 * L.noise(t, 3.3, 0.5) * idleW
	local lookUp = L.track(c, { { 8.9, 0 }, { 9.15, 16, "backOut" }, { 9.6, 16 }, { 9.85, 0 } })
		+ L.track(c, { { 0.6, 0 }, { 0.9, -10 }, { 1.7, -10 }, { 2.0, 0 }, { 3.05, 0 }, { 3.3, -8 }, { 3.95, -8 }, { 4.2, 0 } })

	local tilt = 7 * spinE + 13 * dizzy
	local prec = rad(-720 * c) -- precession of the wobble
	local wobX = tilt * cos(prec * (dizzy > spinE and 0.35 or 1))
	local wobZ = tilt * sin(prec * (dizzy > spinE and 0.35 or 1))
	local rockX = (4 * wave(t, 0.4, 0.25) + 2 * wave(t, 0.2)) * (1 - spinE) - 8 * L.env(c, 4.3, 0.4, 0.2, 0.3) + 6 * flare
	local rockZ = 3 * wave(t, 0.3) * (1 - spinE)
	local shellYaw = spinYaw + 0.3 * look + 8 * wave(t, 0.1) * idleW
	pose.Shell = CFrame.new(0, bob + lift + hop, 0)
		* CFrame.Angles(rad(rockX + wobX), 0, rad(rockZ + wobZ))
		* CFrame.Angles(0, rad(shellYaw), 0)

	-- spire: follow-through jiggle
	pose.Spire = ang(
		-4 * wave(t, 0.4, 0.05) - 10 * dizzy * cos(prec * 0.35 - 0.8) + 6 * spinE * wave(t, 5) + 8 * L.env(c, 7.55, 0.1, 0, 0.5, "quadOut", "elasticOut"),
		0,
		3 * wave(t, 0.3, -0.1) - 10 * dizzy * sin(prec * 0.35 - 0.8)
	)

	--------------------------------------------------------------------
	-- HEAD: peeking, curious tilts, pulled in, pops out, dizzy wobble
	--------------------------------------------------------------------
	local tiltRoll = L.track(c, {
		{ 0.4, 0 }, { 0.65, -17, "backOut" }, { 1.75, -17 }, { 2.0, 0 },
		{ 2.8, 0 }, { 3.1, 19, "backOut" }, { 4.0, 19 }, { 4.3, 0 },
		{ 8.95, 0 }, { 9.2, 12, "backOut" }, { 9.6, 12 }, { 9.85, 0 },
	})
	local headYaw = 0.7 * look
	local headPitch = 0.6 * lookUp + 4 * wave(t, 0.4, 0.1) + 10 * surprise - 6 * giddy
	local headRoll = tiltRoll + 8 * giddy * wave(t, 4) + 14 * dizzy * sin(prec * 0.35 + 1.2) + 6 * happy * wave(t, 1.2)
	pose.Head = pa(0, 0.2 * surprise - 0.2 * retract, retract - 0.4 * flare, headPitch, headYaw, headRoll)
	pose.Hood = ang(-15 * tuck + 5 * wave(t, 0.4, 0.3) + 15 * surprise + 9 * peekOh + 6 * happy + 4 * abs(tiltRoll) / 17, 0, 0)

	-- eyes: darting pupils that follow the look, swirl when dizzy
	local dz = dizzy * (c > 6.8 and 1 or 0)
	local dart = L.noise(t, 7.7, 1.3) * 0.12 * idleW
	local px = math.clamp(-look / 32 * 0.3 + dart, -0.3, 0.3)
	local py = math.clamp(lookUp / 16 * 0.3, -0.3, 0.3) - 0.15 * happy
	local sw = 2 * pi * 2.2 * c
	pose.PupilR = CFrame.new(px * (1 - dz) + 0.28 * dz * cos(sw), py * (1 - dz) + 0.28 * dz * sin(sw), 0)
	pose.PupilL = CFrame.new(px * (1 - dz) - 0.28 * dz * cos(sw), py * (1 - dz) + 0.28 * dz * sin(sw), 0)

	local close = max(blinkAt(c), 0.45 * giddy, 0.5 * L.env(c, 2.05, 0.08, 0.3, 0.1))
	L.both(pose, "Lid", CFrame.new(0, 3.1 * (1 - close), 0))
	local lidTr = close > 0.12 and 0 or 1
	for _, s in { "R", "L" } do
		ctx.transparency("Eyelid" .. s, lidTr)
		ctx.transparency("Lash" .. s, lidTr)
	end

	-- brows: one brow cocked up when curious, both shoot up on "oh!"
	local cockR = max(0, -tiltRoll) / 17
	local cockL = max(0, tiltRoll) / 19
	local up = surprise + 0.7 * peekOh + 0.4 * happy
	pose.BrowR = pa(0, 0.45 * cockR + 0.5 * up - 0.15 * giddy, 0, 0, 0, 12 * cockR - 6 * cockL + 8 * giddy)
	pose.BrowL = L.mirror(pa(0, 0.45 * cockL + 0.5 * up - 0.15 * giddy, 0, 0, 0, 12 * cockL - 6 * cockR + 8 * giddy))

	-- mouth swaps: "o" -> big O (surprise) / smile (happy, giddy)
	local isOh = surprise > 0.3 or peekOh > 0.3
	local isHappy = not isOh and (happy > 0.3 or giddy > 0.3)
	ctx.transparency("MouthO", (isOh or isHappy) and 1 or 0)
	ctx.transparency("MouthBig", isOh and 0 or 1)
	ctx.transparency("MouthBigTongue", isOh and 0 or 1)
	for _, n in { "Smile1", "Smile2", "Smile3", "SmileTongue" } do
		ctx.transparency(n, isHappy and 0 or 1)
	end
	local shock = surprise > 0.3
	for _, sd in { "R", "L" } do
		ctx.transparency("Pupil" .. sd .. "Big", shock and 1 or 0)
		ctx.transparency("Pupil" .. sd .. "Dot", shock and 0 or 1)
	end
	local squint = isHappy
	for _, s in { "R", "L" } do
		for k = 1, 3 do
			ctx.transparency("Happy" .. s .. k, squint and 0 or 1)
		end
	end

	-- hood door shuts the aperture while the head hides
	local doorOn = c > 4.86 and c < SPIN1 + 0.02
	for k = 1, 6 do
		ctx.transparency("Door" .. k, doorOn and 0 or 1)
	end

	-- dizzy stars circle the hood and wobble
	local starsOn = dizzy > 0.12
	for i = 1, 4 do
		for _, sfx in { "a", "b", "c" } do
			ctx.transparency("Star" .. i .. sfx, starsOn and 0 or 1)
		end
	end
	local starPop = L.clamp01(dizzy * 1.6)
	pose.StarRing = CFrame.new(0, -1.2 * (1 - starPop), 0) * ang(8 * sin(sw * 0.5), -300 * c, 10 * cos(sw * 0.5))

	-- siphon puffs
	local puff = max(L.env(c, 1.2, 0.1, 0.05, 0.3, "backOut"), L.env(c, 3.6, 0.1, 0.05, 0.3, "backOut"), L.env(c, 9.5, 0.1, 0.05, 0.3, "backOut"))
	pose.Siphon = ang(-14 * puff + 4 * wave(t, 0.8), 0, -10 * puff)
	for _, s in { 1.2, 3.6, 9.5 } do
		if ctx.crossed(s + 0.05) then
			ctx.emit("SiphonBubbles", 8)
		end
	end

	--------------------------------------------------------------------
	-- TENTACLES
	--------------------------------------------------------------------
	local pokeR = L.env(c, 0.7, 0.22, 0.85, 0.3, "backOut")
	local pokeL = L.env(c, 3.0, 0.22, 0.75, 0.3, "backOut")
	local tapR = pokeR > 0.9 and max(0, wave(c - 0.92, 3.0)) or 0
	local tapL = pokeL > 0.9 and max(0, wave(c - 3.22, 3.0)) or 0
	for k = 1, 12 do
		local wigA = (1 - tuck) * (1 - 0.6 * dizzy)
		local poke, tap = 0, 0
		if k == 6 then poke, tap = pokeR, tapR end
		if k == 7 then poke, tap = pokeL, tapL end
		local sideSign = k <= 6 and 1 or -1
		local outer = math.abs(BETAS[k]) / 112
		for j = 1, 3 do
			local ph = -0.13 * j - 0.083 * k
			local rx = 10 * wave(t, 0.8, ph) * wigA * (0.7 + 0.25 * j)
			local rz = 7 * wave(t, 0.6, ph * 0.8 + 0.3) * wigA * (0.6 + 0.3 * j)
			-- tuck in (curl under), flare out wide, dizzy dangle, happy wave
			rx += (j == 1 and -38 or (j == 2 and -30 or -45)) * tuck - 12 * peekTuck
			rx += (j == 1 and (10 + 60 * outer) or (j == 2 and 12 + 10 * outer or 40)) * flare
			rz += sideSign * (j == 1 and 50 or 12) * (1 - outer) * flare
			rx += 22 * happy * wave(t, 1.6, -0.08 * k - 0.1 * j) * (j == 1 and 0.6 or 1) * (0.25 + 0.75 * outer)
			rz += sideSign * 18 * happy * (1 - outer) * (j == 1 and 1 or 0.3)
			rx += 20 * dizzy * wave(t, 1.4, -0.15 * j) * (j == 1 and 0.4 or 1)
			rz += 14 * dizzy * wave(t, 1.4, -0.15 * j + 0.25) * (j == 1 and 0.4 or 1)
			-- the curious pokes: reach out, straighten, tap tap
			local ry = 0
			if poke > 0 then
				rx += (j == 1 and 62 or (j == 2 and 8 or -45)) * poke + (j == 1 and 9 or -6) * tap
				ry = (j == 1 and -18 or 0) * poke * sideSign
			end
			pose["T" .. k .. string.char(96 + j)] = ang(rx, ry, rz)
		end
	end
	if ctx.crossed(1.05) or ctx.crossed(1.38) then
		ctx.emit("PokeR", 6)
	end
	if ctx.crossed(3.35) or ctx.crossed(3.68) then
		ctx.emit("PokeL", 6)
	end

	--------------------------------------------------------------------
	-- FLOATING CUBES: orbit + bob + tumble, whipped round by the spin
	--------------------------------------------------------------------
	local whirl = L.track(c, { { SPIN0, 0 }, { SPIN1 + 0.4, 360, "quadInOut" } })
	if c > SPIN1 + 0.4 then
		whirl = 0
	end
	pose.Orbit = ang(0, 36 * t + whirl, 0)
	for i = 1, 5 do
		local b = 0.8 * wave(t, 0.4, i * 0.21) + 1.2 * L.env(c, SPIN0, 0.5, 1.0, 0.8)
		pose["Cube" .. i] = pa(0, b, 0, (40 + 9 * i) * t, (60 + 7 * i) * t * (i % 2 == 0 and -1 or 1), 0)
	end

	--------------------------------------------------------------------
	-- EFFECTS
	--------------------------------------------------------------------
	-- rune windows: soft twinkle, chase around the spiral while spinning
	local spinning = c > SPIN0 and c < SPIN1 + 0.1
	local chase = floor((c - SPIN0) * 14) % 5 + 1
	for k = 1, 10 do
		local idx = (k - 1) % 5 + 1
		local tr
		if spinning then
			tr = idx == chase and 0 or 0.7
		elseif c > POP and c < POP + 0.35 then
			tr = 0
		else
			tr = 0.2 + 0.2 * wave(t, 0.5, k * 0.1)
		end
		ctx.transparency("Rune" .. k, tr)
	end
	ctx.light("RuneLight", 0.3 + 1.3 * spinE + 0.9 * flare)
	ctx.light("SpireLight", 0.6 + 0.4 * wave(t, 0.5) + 0.8 * spinE)

	if ctx.crossed(SPIN0) then
		ctx.emit("JetBubbles", 40)
		ctx.emit("SpinBurst", 25)
	end
	for k = 1, 14 do
		if ctx.crossed(SPIN0 + k * 0.11) then
			ctx.emit("JetBubbles", 6)
		end
	end
	if ctx.crossed(POP + 0.02) then
		ctx.emit("PopBurst", 35)
		ctx.emit("SpinBurst", 30)
		ctx.emit("JetBubbles", 20)
	end
	if ctx.crossed(2.6) then
		ctx.emit("PopBurst", 10)
	end
	for k = 0, 6 do
		if ctx.crossed(6.95 + k * 0.17) then
			ctx.emit("DizzyStars", 3)
		end
	end
	if ctx.crossed(7.75) then
		ctx.emit("PopBurst", 14)
	end
end

return M
