--!nocheck
-- Seraph Koi motion: swims through the air with an S-wave rolling down the
-- body, six wings rippling, whiskers swaying, mouth "blooping" bubbles and
-- cartoon blinks. Signature "Heavenly Leap": coils down with wings folded
-- (anticipation) -> launches up into a full backflip with all six wings
-- flared and beating -> holy burst at the top -> splashdown squash ->
-- wiggly settle.
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease

local M = {}
M.Cycle = 9

local CHAIN = { "Body2", "Tail1", "Tail2", "TailFin" }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- signature envelopes
	local coil = L.env(c, 3.0, 0.8, 0.15, 0.25, "cubicOut", "expoIn") -- dip + curl, wings fold
	local leap = L.env(c, 4.0, 0.55, 0.25, 0.8, "backOut", "cubicInOut") -- rises up
	local flip = E.cubicInOut(L.remap(c, 4.05, 5.15)) -- 0 -> 1 = one full backflip
	local flare = L.env(c, 3.95, 0.25, 1.2, 0.6, "backOut", "sineInOut") -- wings spread wide
	local splash = L.env(c, 5.6, 0.07, 0.05, 0.9, "linear", "elasticOut") -- landing squash
	local idleW = 1 - math.max(coil, leap)

	-- BODY (center of the fish): hover bob, swim roll, coil dip, leap arc + flip
	local bob = 0.55 * wave(t, 0.45)
	local y = bob - 1.6 * coil + 6 * leap - 1.4 * splash
	local pitch = 3 * wave(t, 0.45, 0.2) - 14 * coil + 360 * flip + 10 * splash
	local yaw = 9 * wave(t, 0.3) * idleW
	local roll = 6 * wave(t, 0.6) * idleW + 8 * splash * wave(t, 5)
	pose.Body1 = pa(0.6 * wave(t, 0.3) * idleW, y, 0, pitch, yaw, roll)

	-- S-WAVE down the body chain; curls hard to one side in the coil
	local swimHz = 0.9 + 1.8 * flare
	for i, name in CHAIN do
		local amp = (6 + i * 4) * (0.6 + 0.4 * idleW)
		local s = amp * wave(t, swimHz, -0.13 * i)
		local curl = 18 * coil * (0.5 + i * 0.25)
		local lift = -10 * coil + 8 * leap * wave(t, 2, -0.1 * i) + 12 * splash * wave(t, 3, -0.12 * i)
		pose[name] = ang(lift, s + curl, 0)
	end

	-- HEAD counter-swings so the fish "steers" with its nose, looks around
	local look = L.noise(t, 2.3, 0.3) * 14 * idleW
	pose.Head = ang(-6 * coil + 8 * leap - 6 * splash + 3 * wave(t, 0.45, 0.4), -0.5 * 6 * wave(t, 0.9) + look, 4 * wave(t, 0.6, 0.3) * idleW)

	-- MOUTH: bloop bloop (fish gulping), wide open on the leap
	local bloop = L.bounce(t, 0.9) ^ 3 * idleW
	pose.Jaw = ang(-25 * bloop - 35 * leap, 0, 0)

	-- BLINKS
	local blink = L.env(t % 3.7, 3.2, 0.06, 0.06, 0.1)
	L.both(pose, "Lid", CFrame.new(0, -1.9 * blink * (1 - leap), 0))

	-- WHISKERS: lazy sway, whip back during the leap
	local wA = ang(10 * wave(t, 0.7) - 30 * leap, 12 * wave(t, 0.5, 0.2), 8 * wave(t, 0.8))
	local wB = ang(16 * wave(t, 0.7, -0.15) - 25 * leap, 18 * wave(t, 0.5, 0.05), 12 * wave(t, 0.8, -0.2))
	L.both(pose, "WhiskerA", wA, ang(10 * wave(t, 0.7, 0.5) - 30 * leap, 12 * wave(t, 0.5, 0.7), 8 * wave(t, 0.8, 0.5)))
	L.both(pose, "WhiskerB", wB, ang(16 * wave(t, 0.7, 0.35) - 25 * leap, 18 * wave(t, 0.5, 0.55), 12 * wave(t, 0.8, 0.3)))

	-- PECTORAL FINS paddle
	local paddle = 25 * wave(t, 1.2) * idleW + 40 * flare * wave(t, 4)
	L.both(pose, "Fin", ang(0, -10 * paddle / 25, paddle - 20 * coil), ang(0, -10 * paddle / 25, -paddle * 0.8 - 20 * coil))

	-- SIX WINGS: rippling idle flaps (upper -> middle -> lower), folded back in
	-- the coil, flared wide and beating hard during the leap
	local beatHz = 0.8 + 2.4 * flare
	local fold = -55 * coil
	local function wing(phase, base, spread)
		local f = wave(t, beatHz, phase)
		local flap = (18 + 30 * flare) * f
		return ang(0, fold + 10 * flare, base + flap + spread * flare - 25 * coil)
	end
	L.both(pose, "WingU", wing(0, 4, 20))
	L.both(pose, "WingM", wing(-0.12, 0, 12))
	L.both(pose, "WingL", wing(-0.24, -4, -18))

	-- HALO bobs, spins and whirls during the leap
	pose.Halo = pa(0, 0.4 * wave(t, 0.6) + 1.2 * leap, 0, 6 * wave(t, 0.4), 50 * t + 720 * flip, 6 * wave(t, 0.4, 0.25))

	-- FLOATING CUBES orbit and tumble, burst outward at the top of the leap
	pose.Orbit = ang(0, 35 * t, 0)
	for i = 1, 4 do
		local dir = i % 2 == 0 and -1 or 1
		local out = 3 * flare
		pose["Orb" .. i] = pa(out * dir * 0.5, 0.8 * wave(t, 0.5, i * 0.25) + out * 0.5, 0, 90 * t * dir, 110 * t, 30)
	end

	-- EFFECTS
	ctx.light("HolyLight", math.min(1.6, 1.6 * flare))
	if ctx.crossed(4.6) then
		ctx.emit("HolyBurst", 60)
	end
	if ctx.crossed(5.62) then
		ctx.emit("BubbleBurst", 30)
	end
end

return M
