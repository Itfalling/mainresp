--!nocheck
-- Tidal Kraken motion.
-- Idle: jellyfish-style swim pulses (tentacles squeeze down -> body bobs up ->
-- tentacles relax and flare), a travelling wave around the tentacle skirt,
-- mantle breathing, ear flaps, pupils looking around, blinks and beak chomps.
-- Signature "MAELSTROM":
--   3.3  anticipation  sinks down, twists back, all 8 tentacles fountain up HIGH, squint
--   4.65 action        full 360 spin while rising, tentacles whip out in a trailing
--                      spiral, whirlpool + bubble burst, eyes pop wide, dizzy pupils, yell
--   6.15 splash down   tentacles + body slam down (squash), splash spray + droplets
--   6.85 settle        elastic overshoot everywhere, crown/ears/mantle follow-through
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 9

-- per-joint curl deltas (deg) for each key pose; + = curl up/out (local +X)
local RAISE = { 57, 4, 4, -25, -37 }
local FLARE = { 42, -8, -9, -30, -27 }
local SLAM = { 22, -1, 1, -37, -27 }
-- yaw (deg) that swings the raised tentacles back into a fan behind the head
local RAISE_YAW = { -45, -30, -15, -5 }
local SWIM = { 14, 8, 6, 3, -6 }
local WAVE_AMP = { 4, 5, 7, 9, 11 }
local SWAY_AMP = { 3, 4, 5, 6, 8 }
local TRAIL = { 12, 16, 20, 22, 24 }

local REST_DEBUG = false

local function raiseW(c)
	return L.track(c, { { 3.3, 0 }, { 4.25, 1, "backOut" }, { 4.65, 1 }, { 5.0, 0, "quadInOut" } })
end
local function flareW(c)
	return L.track(c, { { 4.65, 0 }, { 5.0, 1, "quadInOut" }, { 6.1, 1 }, { 6.4, 0, "cubicIn" } })
end
local function slamW(c)
	return L.track(c, { { 6.15, 0 }, { 6.5, 1, "cubicIn" }, { 6.85, 1 }, { 8.2, 0, "elasticOut" } })
end
local function bodyY(c)
	return L.track(c, {
		{ 3.3, 0 },
		{ 4.25, -1.5, "cubicOut" },
		{ 4.65, -1.3 },
		{ 5.2, 2.8, "backOut" },
		{ 6.1, 3.0 },
		{ 6.5, -1.9, "cubicIn" },
		{ 6.85, -1.6 },
		{ 8.2, 0, "elasticOut" },
	})
end
-- swim pulse: quick squeeze (0->1) then slow relax, ~1.8s period
local function swim(t)
	local p = (t * 0.55) % 1
	return L.env(p, 0, 0.22, 0.04, 0.74, "quadOut", "sineInOut")
end

function M.Update(t, pose, ctx)
	if REST_DEBUG then
		return
	end
	local c = t % M.Cycle

	local raise, flare, slam = raiseW(c), flareW(c), slamW(c)
	local idleW = L.clamp01(1 - math.max(raise, flare, slam) * 1.3)
	local yaw = L.track(c, { { 3.3, 0 }, { 4.3, -40, "cubicOut" }, { 4.65, -45 }, { 6.2, 370, "cubicInOut" }, { 6.8, 360, "backOut" } })
	local spinning = L.track(c, { { 4.7, 0 }, { 5.0, 1 }, { 5.95, 1 }, { 6.25, 0 } })
	local dizzy = L.track(c, { { 4.9, 0 }, { 5.2, 1 }, { 7.0, 1 }, { 7.9, 0 } })
	local wide = L.track(c, { { 4.55, 0 }, { 4.8, 1, "backOut" }, { 6.1, 1 }, { 6.35, 0 } })
	local squint = L.track(c, { { 3.4, 0 }, { 3.9, 1 }, { 4.55, 1 }, { 4.7, 0 } })
	local flinch = L.track(c, { { 6.35, 0 }, { 6.45, 1 }, { 6.6, 1 }, { 6.7, 0 } })

	------------------------------------------------------------------
	-- BODY: swim bob + drift, crouch, spin with top-like wobble, slam squash
	------------------------------------------------------------------
	local sw = swim(t)
	local swLag = swim(t - 0.12)
	local by = bodyY(c) + idleW * (1.3 * swLag - 0.55)
	local dx = 0.6 * L.noise(t, 1.7, 0.25) * idleW
	local dz = 0.5 * L.noise(t, 5.3, 0.2) * idleW
	local pitch = idleW * (5 * sw - 2) + 10 * raise - 6 * slam
	local roll = 5 * wave(t, 0.27) * idleW
	local wob = 10 * spinning
	local wph = L.TAU * t * 2.3
	local tilt = ang(pitch + wob * math.cos(wph), 0, roll + wob * math.sin(wph))
	pose.Body = CFrame.new(dx, by, dz) * tilt * ang(0, yaw + 10 * L.noise(t, 2.2, 0.2) * idleW, 0)

	-- velocity proxy (studs/s) for follow-through on the soft parts
	local vel = (bodyY(c) - bodyY(c - 0.12)) / 0.12 + idleW * (swim(t) - swim(t - 0.1)) * 13
	local follow = math.clamp(vel * 0.12, -1, 1)

	------------------------------------------------------------------
	-- MANTLE: jet squeeze, squash/stretch lag, crown + ears follow-through
	------------------------------------------------------------------
	pose.Mantle = pa(0, 0.35 * sw * idleW - 0.5 * raise + 0.5 * flare - 0.7 * slam - 0.3 * follow, 0.15 * follow,
		-5 * sw * idleW + 6 * raise - 10 * follow - 4 * slam, 0, 7 * spinning * math.sin(wph - 0.9))
	local jig = slam * wave(t, 4.5)
	pose.Crown = ang(12 * jig - 16 * follow + 3 * wave(t, 0.55, -0.3) * idleW, 14 * spinning, 12 * spinning * math.sin(wph - 1.8) + 8 * jig)
	local flap = idleW * (16 * wave(t, 1.1) + 10 * sw)
	local earR = ang(0, 22 * spinning, flap + 30 * raise + 20 * flare - 45 * slam * (1 - 0.4 * wave(t, 3)) - 22 * follow)
	L.both(pose, "Ear", earR)

	------------------------------------------------------------------
	-- FACE: eyes pop + go wide, dizzy pupils, blinks, brows, beak
	------------------------------------------------------------------
	L.both(pose, "Eye", CFrame.new(0, 0.25 * wide, -0.7 * wide))
	local look = L.noise(t, 3.3, 0.45) * idleW
	local lookY = L.noise(t, 7.7, 0.35) * idleW
	local dzA = L.TAU * 2.4 * t
	-- the idle look is shared (not mirrored) so both eyes look the same way;
	-- dizzy circles run out of phase for a goofy cross-eyed swirl
	local py = 0.4 * lookY + 0.35 * raise - 0.2 * slam
	pose.PupilR = CFrame.new(0.6 * look + 0.5 * dizzy * math.cos(dzA), py + 0.5 * dizzy * math.sin(dzA), 0)
	pose.PupilL = CFrame.new(0.6 * look + 0.5 * dizzy * math.cos(dzA + 2.2), py + 0.5 * dizzy * math.sin(dzA + 2.2), 0)

	local blink = L.env(t % 3.4, 3.0, 0.07, 0.05, 0.1) * idleW
	local lid = math.max(blink, 0.42 * squint, 0.62 * flinch)
	L.both(pose, "Lid", ang(92 * lid, 0, 0))
	L.both(pose, "Brow", pa(0, -0.3 * squint + 0.9 * wide - 0.35 * flinch + 0.12 * sw * idleW, 0, 0, 0, 10 * squint - 16 * wide + 6 * flinch))

	local chomp = math.max(0, wave(t, 0.33, 0.2)) ^ 6 * idleW
	pose.Jaw = ang(-5 - 24 * chomp + 5 * squint - 50 * wide - 12 * slam * math.abs(wave(t, 2.2)) - 6 * sw * idleW, 0, 0)

	------------------------------------------------------------------
	-- TENTACLES
	------------------------------------------------------------------
	for k = 1, 4 do
		for s = 1, 2 do
			local side = s == 1 and "R" or "L"
			local kk = s == 1 and k or 9 - k -- index around the skirt for the travelling wave
			local ph = kk / 8
			for i = 1, 5 do
				local ci = c - 0.05 * (i - 1)
				local r, f, sl = raiseW(ci), flareW(ci), slamW(ci)
				local curl = RAISE[i] * r + FLARE[i] * f + SLAM[i] * sl
				-- idle: swim squeeze (lags down the chain) + travelling wave around the skirt
				local swi = swim(t - 0.06 * i)
				curl += idleW * (SWIM[i] * (0.7 - swi) + WAVE_AMP[i] * wave(t, 0.45, ph - 0.09 * i))
				local sway = idleW * SWAY_AMP[i] * wave(t, 0.35, ph * 2 + 0.07 * i)
				local yawSym = sway + (i == 1 and RAISE_YAW[k] * r or 0)
				-- spin whip: every joint trails behind the spin direction -> spiral
				local yawSpin = -spinning * TRAIL[i] * (1 + 0.3 * wave(t, 3, -0.1 * i))
				local y = (s == 1 and yawSym or -yawSym) + yawSpin
				pose[("T%dS%d%s"):format(k, i, side)] = ang(0, y, 0) * ang(curl, 0, 0)
			end
		end
	end

	------------------------------------------------------------------
	-- VFX: orbiting cubes, whirlpool rings
	------------------------------------------------------------------
	local whirl = L.track(c, { { 4.65, 0 }, { 6.4, 2, "cubicInOut" } })
	pose.Orbit = CFrame.new(0, by * 0.5, 0) * ang(0, 30 * t + 360 * whirl, 0)
	for i = 1, 5 do
		local out = 2.6 * flare
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(0, 0.8 * wave(t, 0.45, i * 0.21) + out * 0.3, 0, 70 * t * dir, 95 * t, 30 * wave(t, 0.3, i * 0.1))
	end
	local swirlVis = L.track(c, { { 4.75, 0 }, { 5.1, 1 }, { 6.0, 1 }, { 6.6, 0 } })
	local swirlTurn = L.track(c, { { 4.6, 0 }, { 6.7, 3, "quadInOut" } })
	pose.Swirl = CFrame.new(0, -1.2 + 1.2 * swirlVis, 0) * ang(0, 360 * swirlTurn, 0)
	local trA = 1 - 0.6 * swirlVis
	local trB = 1 - 0.55 * L.track(c, { { 4.9, 0 }, { 5.25, 1 }, { 5.95, 1 }, { 6.4, 0 } })
	for i = 0, 9 do
		ctx.transparency("SwirlA" .. i, trA)
	end
	for i = 0, 7 do
		ctx.transparency("SwirlB" .. i, trB)
	end

	ctx.enable("SpinBubbles", c > 4.8 and c < 6.2)
	ctx.light("SwirlLight", 1.3 * swirlVis)
	if ctx.crossed(4.72) then
		ctx.emit("WaterBurst", 40)
	end
	if ctx.crossed(6.5) then
		ctx.emit("SplashSpray", 30)
		ctx.emit("SplashDrops", 45)
	end
	if ctx.crossed(1.3) or ctx.crossed(8.5) then
		ctx.emit("MouthBubbles", 6)
	end
end

return M
