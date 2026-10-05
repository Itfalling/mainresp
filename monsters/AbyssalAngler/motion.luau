--!nocheck
-- Abyssal Anglerfish motion: bouncy swim idle (tail sweeps, fins paddle, the
-- lure sways with lag, chomp-chomps, googly pupils, blinks) then LURE & GULP:
-- the lure dangles forward and flashes hypnotically -> the angler pulls back and
-- coils -> LUNGES forward + up with the jaw flung ~80 deg open -> SNAPS shut with
-- a bubble burst -> elastic recoil, happy chewing and a proud wiggle.
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 8

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- signature move envelopes
	local lure = L.env(c, 1.1, 0.6, 1.75, 0.3, "backOut", "cubicIn") -- lure dangles forward + flashes
	local windup = L.env(c, 2.5, 0.55, 0.35, 0.15, "cubicOut", "expoIn") -- pull back + coil
	local gape = L.env(c, 3.42, 0.3, 0.7, 0.12, "backOut", "expoIn") -- jaw flung open, then SNAP
	local lunge = L.env(c, 3.4, 0.4, 0.6, 1.0, "backOut", "cubicInOut") -- thrust forward + up
	local snap = L.env(c, 4.52, 0.06, 0.05, 1.3, "linear", "elasticOut") -- impact recoil
	local chew = L.env(c, 4.75, 0.2, 0.8, 0.4) -- happy gulping
	local wiggle = L.env(c, 5.5, 0.25, 0.5, 0.6) -- proud wiggle
	local act = math.max(windup, gape, lunge)
	local idleW = 1 - math.min(1, math.max(act, snap * 0.7))

	-- BODY: bouncy swim bob + sway; back + coil on wind-up; lunge forward/up nose-high; slam on snap
	local swim = wave(t, 0.5)
	local by = 1.0 * swim * idleW - 0.9 * windup + 3.2 * lunge - 1.4 * snap + 0.4 * chew * wave(t, 3)
	local bz = 2.8 * windup - 4.5 * lunge + 1.6 * snap
	local brx = 6 * wave(t, 0.5, 0.2) * idleW - 10 * windup + 24 * lunge - 16 * snap
	local bry = 8 * wave(t, 0.5, 0.25) * idleW - 14 * windup + 14 * wiggle * wave(t, 2.5)
	local brz = 5 * wave(t, 0.25) * idleW + 12 * wiggle * wave(t, 2.5, 0.25) + 8 * windup + 5 * gape * wave(t, 6)
	pose.Body = pa(0, by, bz, brx, bry, brz)

	-- JAW: agape idle with chomp-chomps; clamps shut on wind-up, flung open, SNAP, chews
	local chompWin = (L.env(c, 0.3, 0.08, 0.5, 0.1) + L.env(c, 6.4, 0.08, 0.5, 0.1)) * idleW
	local chomp = chompWin * math.max(0, wave(t, 3.5))
	local jawIdle = -9 - 3 * wave(t, 0.5, 0.3) - 16 * chomp
	local shut = math.max(windup, gape)
	pose.Jaw = ang(jawIdle * (1 - shut) + 3 * windup - 82 * gape + 6 * snap - 12 * chew * math.max(0, wave(t, 3.5)) + 3 * gape * wave(t, 9), 0, 0)

	-- EYES: googly pupils look around, lock onto the lure; blinks; squint on wind-up; ^^ while chewing
	local lookX = 0.25 * L.noise(t, 3.1, 0.5) * idleW
	local lookY = 0.12 * L.noise(t, 7.7, 0.4) * idleW
	L.both(pose, "Pupil", CFrame.new(lookX - 0.15 * lure, lookY + 0.35 * lure - 0.15 * windup, 0))
	local blink = L.env(t % 3.1, 2.8, 0.06, 0.06, 0.1)
	local lidDown = math.min(1, blink + 0.45 * windup + 0.6 * chew)
	L.both(pose, "Lid", CFrame.new(0, -1.65 * lidDown * (1 - gape), 0))
	-- brows: sneaky raise while luring, angry on wind-up, wild on the gape
	local browUp = 0.35 * lure - 0.25 * windup + 0.5 * gape
	L.both(pose, "Brow", pa(0, browUp, 0, 0, 0, -10 * lure + 12 * windup - 8 * gape))

	-- LURE: always swaying with lag; dangles forward hypnotically, whips back on the lunge,
	-- flops forward on the snap (follow-through)
	local hyp = lure * (1 - gape)
	local sway = wave(t, 1.1)
	pose.Lure1 = ang(6 * wave(t, 0.5, -0.1) - 25 * hyp + 40 * lunge - 24 * snap, 0, 6 * wave(t, 0.3, 0.2) + 7 * hyp * sway)
	pose.Lure2 = ang(9 * wave(t, 0.5, -0.2) + 10 * hyp + 28 * lunge - 18 * snap, 0, 6 * wave(t, 0.3, 0.05) + 5 * hyp * wave(t, 1.1, -0.1))
	pose.Lure3 = ang(11 * wave(t, 0.5, -0.3) + 10 * hyp + 25 * lunge - 15 * snap, 0, 8 * wave(t, 0.3, -0.1) + 6 * hyp * wave(t, 1.1, -0.2))
	pose.Bulb = ang(16 * wave(t, 0.5, -0.4) + 15 * hyp * wave(t, 2.2, -0.3) - 50 * lunge + 40 * snap, 0, 18 * wave(t, 0.3, -0.25) + 18 * hyp * wave(t, 1.1, -0.3))

	-- DORSAL spines ripple; flatten on wind-up, flare up on the gape
	pose.Dorsal = ang(6 * wave(t, 0.9) + 18 * windup - 20 * gape + 10 * snap * wave(t, 4), 0, 0)

	-- PECTORAL FINS: paddling idle, brake forward on wind-up, swept back on the lunge, flare on the snap
	local function fin(ph)
		local y = 25 * wave(t, 0.9, ph) * idleW + 35 * windup - 45 * lunge + 10 * snap + 25 * wiggle * wave(t, 3, ph)
		local z = 18 * wave(t, 0.9, ph + 0.25) * idleW + 20 * windup + 10 * lunge + 35 * snap + 20 * chew * wave(t, 3.2, ph)
		return ang(0, y, z)
	end
	L.both(pose, "Pec", fin(0), fin(0.5))

	-- TAIL: lazy sweep with lag; C-curl on the wind-up, big kick on the lunge, fast happy wag after
	local hz = 0.9 + 1.4 * math.max(snap, wiggle)
	local amp = 1 + 0.6 * wiggle
	local curl = 30 * windup - 34 * lunge
	local lift = -14 * lunge + 8 * windup + 8 * snap
	pose.Tail1 = ang(lift * 0.6, 12 * wave(t, hz, -0.1) * amp + curl * 0.6, 0)
	pose.Tail2 = ang(lift * 0.8, 18 * wave(t, hz, -0.2) * amp + curl * 0.8, 0)
	pose.TailFin = ang(lift, 26 * wave(t, hz, -0.3) * amp + curl, 0)

	-- FLOATING CUBES: slow orbit, bob + tumble, flung outward by the chomp shockwave
	pose.Orbit = ang(0, 30 * t, 0)
	for i = 1, 4 do
		local out = 3 * snap
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(out * dir * 0.6, 0.8 * wave(t, 0.6, i * 0.25) + out * 0.4, 0, 90 * t * dir, 120 * t, 45)
	end

	-- EFFECTS: lure blinks a hypnotic pattern, mouth flash + bubble burst on the snap
	local flash = hyp > 0.5 and ((c > 1.85 and c < 2.12) or (c > 2.42 and c < 2.58) or (c > 2.9 and c < 3.12))
	ctx.light("LureLight", 0.8 + 0.15 * wave(t, 0.9) + (flash and 1.0 or 0))
	ctx.transparency("LureFlash", flash and 0.6 or 1)
	ctx.light("MouthLight", 1.6 * snap)
	if ctx.crossed(3.45) then
		ctx.emit("GulpBubbles", 15)
	end
	if ctx.crossed(4.52) then
		ctx.emit("GulpBubbles", 45)
		ctx.emit("ChompBurst", 30)
	end
end

return M
