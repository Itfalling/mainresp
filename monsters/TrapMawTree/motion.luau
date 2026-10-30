--!nocheck
-- Great Maw Tree: a calm but clearly visible, seamless 9 s showpiece idle.
-- * six hanging flytrap pods (bone PodN, pivot at the stem top) swing on their
--   stems in slow ellipses (+-10 deg) and their lids (PodNLid, hinge pivot)
--   breathe open and shut 21..53 deg, phase-offset, revealing the glowing
--   maw-fruit inside (fruit glow brightens as the lid opens)
-- * pod 1 (front) snaps shut at 2.2 s and pod 4 (back) at 6.4 s: a little
--   wind-up gape, a quick cute snap with a tiny rebound, two contented chews
--   with a lime seam glowing along the lips, then a bouncy reopen. The pod
--   jolts on its stem, the canopy gives a small shiver and a puff of spores
--   bursts out
-- * the canopy sways +-2.5 deg and breathes (0.15 stud bob); the trunk
--   follows very softly; the crown maw on top breathes wider and glows pink
-- * the green light pulses with the breathing and flashes on each snap
-- All waves use whole cycles per loop; snaps are wrap-safe, so t=0 == t=9.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local clamp, exp, sin, abs = math.clamp, math.exp, math.sin, math.abs

local M = {}
M.Cycle = 9

local TAU = math.pi * 2
local PI = math.pi
local OPEN, CROWN_OPEN = 40, 40 -- lid angles the build uses (must match build.luau)

-- n whole cycles per loop, phase in turns
local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

-- per pod: swing cycles, swing phase, breath phase, pitch amp, roll amp
local PODS = {
	{ 1, 0.00, 0.00, 10, 8 },
	{ 2, 0.37, 0.55, 9, 9 },
	{ 1, 0.62, 0.30, 10, 8 },
	{ 2, 0.15, 0.80, 9, 8 },
	{ 1, 0.81, 0.12, 10, 9 },
	{ 2, 0.49, 0.67, 9, 8 },
}
local SNAP = { [1] = 2.2, [4] = 6.4 }

-- wrap-safe time relative to a beat (in [-Cycle/2, Cycle/2))
local function rel(c, s)
	return ((c - s + M.Cycle / 2) % M.Cycle) - M.Cycle / 2
end

-- snap shaping (dt = time since the snap)
local function snapShape(dt)
	-- multiplier on the open angle: shut fast, hold, bouncy reopen
	local mul = L.track(dt, { { -0.8, 1 }, { -0.12, 1 }, { 0, 0, "cubicIn" }, { 1.0, 0 }, { 2.3, 1, "backOut" } })
	-- wind-up: gape a little wider before the snap
	local extra = L.track(dt, { { -0.9, 0 }, { -0.15, 12, "sineInOut" }, { 0, 0, "cubicIn" } })
	-- tiny rebound + two contented chews while shut
	local chew = 0
	if dt > 0 and dt < 0.24 then
		chew = 5 * sin(PI * dt / 0.24)
	elseif dt > 0.32 and dt < 0.92 then
		chew = 7 * abs(sin(PI * (dt - 0.32) / 0.3))
	end
	-- the pod jolts forward on its stem, then settles
	local kick = 0
	if dt > 0 then
		kick = 7 * exp(-3 * dt) * sin(11 * dt)
	elseif dt > -0.9 then
		kick = -2.5 * L.track(dt, { { -0.9, 0 }, { -0.15, 1, "sineInOut" }, { 0, 0 } })
	end
	-- flash for light / canopy shiver
	local flash = (dt > 0) and exp(-4 * dt) or 0
	return mul, extra, chew, kick, flash
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- snap state first (canopy + light react to it)
	local shiver, flashTot = 0, 0
	local snapState = {}
	for i, s in SNAP do
		local dt = rel(c, s)
		local mul, extra, chew, kick, flash = snapShape(dt)
		snapState[i] = { mul = mul, extra = extra, chew = chew, kick = kick }
		flashTot += flash
		shiver += (dt > 0) and (1.2 * exp(-3.5 * dt) * sin(14 * dt)) or 0
		if ctx.crossed(s + 0.02) then
			ctx.emit("SnapSpores" .. i, 36)
		end
	end

	-- trunk: very soft sway; canopy: slow sway + breathing bob + snap shiver
	pose.Crop = ang(0.6 * w(t, 1, 0.6), 0, 0.6 * w(t, 1, 0.85))
	pose.Canopy = pa(0, 0.15 * w(t, 2, 0.1), 0,
		2.4 * w(t, 1, 0.0) + shiver, 1.0 * w(t, 1, 0.35), 2.6 * w(t, 1, 0.25) + 0.5 * shiver)

	-- pods
	local glowSum = 0
	for i, p in PODS do
		local sw = w(t, p[1], p[2])
		local sw2 = w(t, p[1], p[2] + 0.25)
		local a = 37 + 16 * w(t, 2, p[3]) -- breathing lid angle 21..53
		local kick, seam = 0, 1
		local st = snapState[i]
		if st then
			a = (a + st.extra) * st.mul + st.chew
			kick = st.kick
			-- lime seam glows along the lips while the trap is shut
			seam = clamp(1 - (1 - st.mul) * 1.4, 0, 1)
			ctx.transparency("Seam" .. i, 0.05 + 0.95 * seam)
		end
		pose["Pod" .. i] = ang(p[4] * sw + kick, 3 * w(t, 1, p[2] + 0.4), p[5] * sw2)
		pose["Pod" .. i .. "Lid"] = ang(a - OPEN, 0, 0)
		-- fruit glow: brighter the wider the maw opens (0 = full glow)
		local o = clamp((a - 20) / 32, 0, 1)
		glowSum += o
		ctx.transparency("MawGlow" .. i, 0.7 * (1 - o))
		ctx.transparency("MawShine" .. i, 0.6 * (1 - o))
	end

	-- crown maw: slower, wider breathing + gentle sway
	local ca = 41 + 15 * w(t, 1, 0.6) + 4 * w(t, 3, 0.2) -- 22..60
	pose.Crown = ang(2.5 * w(t, 1, 0.45), 2 * w(t, 1, 0.7), 3 * w(t, 1, 0.2))
	pose.CrownLid = ang(ca - CROWN_OPEN, 0, 0)
	local co = clamp((ca - 22) / 38, 0, 1)
	ctx.transparency("MawGlow0", 0.7 * (1 - co))
	ctx.transparency("MawShine0", 0.6 * (1 - co))

	-- lights: green glow breathes with the pods and flashes on each snap
	ctx.light("MawLight", clamp(1.15 + 0.55 * w(t, 2, 0.1) + 0.1 * (glowSum / 6 - 0.5) + 0.4 * flashTot, 0, 2))
	ctx.light("CrownLight", 0.5 + 1.0 * co)
end

return M
