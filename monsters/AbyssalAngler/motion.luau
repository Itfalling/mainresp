--!nocheck
-- Abyssal Anglerfish motion: bouncy cartoon swim idle (big bob + bounce, tail
-- sweeps synced to the body yaw, fins paddling, lure swaying with lag,
-- chomp-chomps, googly pupils, blinks) then LURE & GULP:
--   lure   - the bulb dangles forward and flashes hypnotically, pupils lock on
--   windup - big pull back + coil, angry squint, pecs braking, tail C-curl
--   lunge  - thrust forward + up nose-high, jaw flung ~85 deg open and trembling,
--            the lure dips INTO the open mouth (nearly eats its own bait!)
--   snap   - jaw SNAPS shut, squash, shockwave ring + cubes + bubbles, the lure
--            pops back out and blinks twice, elastic wobble, happy chewing
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease

local M = {}
M.Cycle = 8

local max, min, sin, cos, pi = math.max, math.min, math.sin, math.cos, math.pi
local SNAP = 4.52
local SHOCK_N = 8
local ORB_DIR = { 1, -1, 1, -1 }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	--------------------------------------------------------------------
	-- envelopes
	--------------------------------------------------------------------
	local lure = L.env(c, 1.1, 0.6, 1.75, 0.3, "backOut", "cubicIn") -- lure dangles forward + flashes
	local windup = L.env(c, 2.45, 0.6, 0.35, 0.15, "cubicOut", "expoIn") -- pull back + coil
	local gape = L.env(c, 3.42, 0.3, 0.7, 0.12, "cubicOut", "expoIn") -- jaw flung open, then SNAP
	local lunge = L.env(c, 3.4, 0.4, 0.6, 1.0, "backOut", "cubicInOut") -- thrust forward + up
	local snap = L.env(c, SNAP, 0.06, 0.05, 1.3, "linear", "elasticOut") -- impact recoil
	local chew = L.env(c, 4.75, 0.2, 0.8, 0.4) -- happy gulping
	local wiggle = L.env(c, 5.5, 0.25, 0.5, 0.6) -- proud wiggle
	local act = max(windup, gape, lunge)
	local idleW = 1 - min(1, max(act, snap * 0.7))
	local hold = gape * E.sineInOut(L.remap(c, 3.72, 4.42)) -- builds during the gape hold
	local wob = snap * sin((c - SNAP) * 17) -- elastic wobble after the snap

	--------------------------------------------------------------------
	-- BODY: bouncy swim, coil back on the wind-up, lunge nose-high, squash on the snap
	--------------------------------------------------------------------
	local swim = wave(t, 0.6)
	local by = (1.4 * swim + 0.6 * L.bounce(t, 1.2) - 0.3) * idleW
		- 1.8 * windup + 3.2 * lunge - 2.0 * snap + 0.5 * chew * wave(t, 3)
	local bz = 4.2 * windup - 4.5 * lunge - 1.2 * hold + 1.6 * snap
	local brx = 10 * wave(t, 0.6, 0.2) * idleW - 20 * windup + 24 * lunge - 16 * snap
	local bry = 12 * wave(t, 0.9, -0.05) * idleW - 14 * windup + 16 * wiggle * wave(t, 2.5)
	local brz = (5 * wave(t, 0.3) + 6 * wave(t, 1.2)) * idleW + 14 * wiggle * wave(t, 2.5, 0.25)
		+ 12 * windup + 5 * gape * wave(t, 6) + 12 * wob
	pose.Body = pa(0, by, bz, brx, bry, brz)

	--------------------------------------------------------------------
	-- JAW: agape idle with chomp-chomps; clamps shut on wind-up, flung open
	-- and trembling, SNAP, chews
	--------------------------------------------------------------------
	local chompWin = (L.env(c, 0.3, 0.08, 0.5, 0.1) + L.env(c, 6.3, 0.08, 0.4, 0.1) + L.env(c, 7.2, 0.08, 0.4, 0.1)) * idleW
	local chomp = chompWin * max(0, wave(t, 3.5))
	local jawIdle = -9 - 4 * wave(t, 0.6, 0.3) - 18 * chomp
	local shut = max(windup, gape)
	pose.Jaw = ang(
		jawIdle * (1 - shut) + 3 * windup - 80 * gape + 2 * snap - 14 * chew * max(0, wave(t, 3.5)) + 6 * gape * wave(t, 12),
		0,
		0
	)

	--------------------------------------------------------------------
	-- EYES: googly pupils look around, lock UP onto the lure, squint on the
	-- wind-up, pop wide on the gape; blinks; happy squint while chewing
	--------------------------------------------------------------------
	local lookX = 0.3 * L.noise(t, 3.1, 0.5) * idleW
	local lookY = 0.2 * L.noise(t, 7.7, 0.4) * idleW
	local px = lookX - 0.2 * lure * (1 - gape)
	local py = lookY + 0.45 * lure * (1 - windup) * (1 - gape) - 0.25 * windup + 0.55 * gape
	L.both(pose, "Pupil", CFrame.new(px, py, 0))
	local blink = max(L.env(t % 3.1, 2.75, 0.06, 0.05, 0.08), L.env(t % 3.1, 2.98, 0.06, 0.05, 0.08))
	local lidDown = min(1, max(blink * (1 - gape), 0.6 * windup, 0.6 * chew))
	L.both(pose, "Lid", CFrame.new(0, -2.4 * lidDown, 0))
	local lidTr = lidDown > 0.04 and 0 or 1
	for _, s in { "R", "L" } do
		ctx.transparency("Eyelid" .. s, lidTr)
		ctx.transparency("EyelidS" .. s, lidTr)
	end
	-- brows: sneaky raise while luring, angry slam on the wind-up, wide-eyed on the gape
	local browUp = 0.35 * lure * (1 - windup) - 0.35 * windup + 0.9 * gape + 0.3 * wob
	L.both(pose, "Brow", pa(0, browUp, 0, 0, 0, -10 * lure * (1 - windup) + 14 * windup - 12 * gape))

	--------------------------------------------------------------------
	-- LURE: always swaying with lag; dangles forward hypnotically; stays in
	-- front during the lunge, dips INTO the open mouth on the gape hold, pops
	-- back out with an elastic flop when the jaw snaps
	--------------------------------------------------------------------
	local hyp = lure * (1 - gape)
	local sway = wave(t, 1.1)
	-- dip: the stalk curls down so the bulb dangles right in front of the open mouth
	local dip = L.env(c, 3.62, 0.42, 0.4, 0.1, "backOut", "quadIn")
	local lng = lunge * (1 - dip)
	local idl = 1 - 0.6 * dip
	pose.Lure1 = ang(
		6 * wave(t, 0.6, -0.1) * idl + 3 - 8 * hyp + 18 * windup + 10 * lng - 63 * dip + 20 * snap,
		0,
		6 * wave(t, 0.3, 0.2) * idl + 7 * hyp * sway
	)
	pose.Lure2 = ang(
		7 * wave(t, 0.6, -0.2) * idl + 4 * hyp + 6 * lng - 18 * snap,
		0,
		6 * wave(t, 0.3, 0.05) * idl + 5 * hyp * wave(t, 1.1, -0.1)
	)
	pose.Lure3 = ang(
		9 * wave(t, 0.6, -0.3) * idl + 12 * hyp - 12 * lng - 20 * dip - 15 * snap,
		0,
		8 * wave(t, 0.3, -0.1) * idl + 6 * hyp * wave(t, 1.1, -0.2)
	)
	pose.Bulb = ang(
		18 * wave(t, 0.6, -0.4) * idl + 15 * hyp * wave(t, 2.2, -0.3) - 20 * lng + 75 * dip + 12 * dip * wave(t, 2.5) + 40 * snap,
		0,
		18 * wave(t, 0.3, -0.25) * idl + 18 * hyp * wave(t, 1.1, -0.3) + 15 * dip * wave(t, 1.6)
	)

	-- DORSAL plates ripple; flatten on the wind-up, flare up on the gape, quiver on the snap
	pose.Dorsal = ang(8 * wave(t, 0.9) + 20 * windup - 22 * gape + 12 * wob, 0, 0)

	--------------------------------------------------------------------
	-- PECTORAL FINS: big paddling idle, flared forward to brake on the wind-up,
	-- swept back on the lunge, flare out on the snap, flap while chewing
	--------------------------------------------------------------------
	local function fin(ph)
		local y = 25 * wave(t, 0.9, ph) * idleW + 45 * windup - 45 * lunge + 10 * snap + 30 * wiggle * wave(t, 3, ph)
		local z = 35 * wave(t, 0.9, ph + 0.25) * idleW + 25 * windup + 10 * lunge + 40 * snap + 25 * chew * wave(t, 3.2, ph)
		return ang(0, y, z)
	end
	L.both(pose, "Pec", fin(0), fin(0.5))

	--------------------------------------------------------------------
	-- TAIL: big sweep with lag (in sync with the body yaw); C-curl on the
	-- wind-up, big kick on the lunge, fast happy wag after
	--------------------------------------------------------------------
	local hz = 0.9 + 1.4 * max(snap, wiggle)
	local amp = 1 + 0.5 * wiggle
	local curl = 45 * windup - 40 * lunge
	local lift = -14 * lunge + 8 * windup + 10 * snap
	pose.Tail1 = ang(lift * 0.6, -16 * wave(t, hz, -0.1) * amp + curl * 0.6, 0)
	pose.Tail2 = ang(lift * 0.8, -26 * wave(t, hz, -0.2) * amp + curl * 0.8, 0)
	pose.TailFin = ang(lift, -42 * wave(t, hz, -0.3) * amp + curl, 0)

	--------------------------------------------------------------------
	-- FLOATING CUBES: drift on the flanks (never across the face), bob +
	-- tumble, rise with the wind-up, blasted outward along x by the snap
	--------------------------------------------------------------------
	pose.Orbit = ang(0, 20 * wave(t, 0.07), 0)
	for i = 1, 4 do
		local dir = ORB_DIR[i]
		local bob = 1.0 * wave(t, 0.5, i * 0.27)
		pose["Orb" .. i] = pa(3 * snap * dir, bob + 1.0 * windup, 0, (90 + 10 * i) * t * dir, 120 * t, 0)
	end

	--------------------------------------------------------------------
	-- EFFECTS
	--------------------------------------------------------------------
	local flash = (hyp > 0.5 and ((c > 1.85 and c < 2.12) or (c > 2.42 and c < 2.58) or (c > 2.9 and c < 3.12)))
		or (c > 4.6 and c < 4.7)
		or (c > 4.8 and c < 4.9)
	ctx.light("LureLight", 0.7 + 0.1 * wave(t, 0.9) + (flash and 0.6 or 0))
	ctx.transparency("LureFlash", flash and 0.72 or 1)
	ctx.light("MouthLight", 1.2 * snap)
	if ctx.crossed(3.45) then
		ctx.emit("GulpBubbles", 15)
	end
	if ctx.crossed(SNAP) then
		ctx.emit("GulpBubbles", 45)
		ctx.emit("ChompBurst", 30)
		ctx.emit("ChompCubes", 16)
		ctx.emit("AuraSparkle", 12)
	end

	-- gulp shockwave ring: slabs burst outward from the mouth, fading
	local sw = L.remap(c, SNAP, SNAP + 0.35)
	local swOn = c > SNAP and c < SNAP + 0.35
	local r = 4.0 * E.quadOut(sw)
	for k = 1, SHOCK_N do
		local a = (k - 1) / SHOCK_N * 2 * pi
		pose["Shock" .. k] = CFrame.new(-sin(a) * r, cos(a) * r, -1.5 * sw)
		ctx.transparency("Wave" .. k, swOn and (0.1 + 0.85 * sw * sw) or 1)
	end
end

return M
