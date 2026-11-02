--!nocheck
-- Ember Pepper: calm, clearly visible, seamless 8 s loop.
-- * the bush sways softly; the four leaf-cluster branches sway with a lag
--   and breathe; the five magma peppers swing on their stems in
--   phase-offset ellipses; pepper stripes, tips and leaf embers pulse
-- * FLARE beat once per loop (peak 5.0 s): the big front pepper heats up
--   (3.9-5.0 s) - trembles, rises on its stem, every glow goes full bright -
--   then KICKS back and spits a burst of sparks + fire from its tip, its
--   branch recoils, the light flashes; it swings out and settles by ~7.3 s
-- Waves use whole cycles per loop; envelopes are 0 at both loop ends.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, exp, clamp = math.sin, math.exp, math.clamp

local M = {}
M.Cycle = 8

local TAU = math.pi * 2
local FLARE = 5.0

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

local BRANCHES = { BranchA = 0.0, BranchB = 0.37, BranchC = 0.18, BranchD = 0.62 }
local PEPPERS = { { 2, 0.1 }, { 2, 0.55 }, { 2, 0.3 }, { 3, 0.8 }, { 3, 0.42 } }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	local heat = L.track(c, { { 3.9, 0 }, { 4.95, 1, "quadIn" }, { 5.1, 0, "cubicOut" } })
	local glow = L.track(c, { { 3.9, 0 }, { 4.95, 1, "quadIn" }, { 5.4, 0.8 }, { 7.0, 0, "sineInOut" } })
	local dt = c - FLARE
	local kick = 0
	if dt > 0 and dt < 2.8 then
		kick = exp(-2.2 * dt) * sin(7 * dt) * (1 - dt / 2.8)
	end
	local tremble = heat * sin(TAU * 12 * c)

	pose.Crop = ang(1.2 * w(t, 1, 0.6) - 1.5 * kick, 0, 1.4 * w(t, 1, 0.85))

	for name, ph in BRANCHES do
		local k = (name == "BranchD") and 1 or 0.35
		pose[name] = pa(0, 0.12 * w(t, 2, ph), 0, 3 * w(t, 1, ph) - 9 * kick * k + 1.5 * tremble * k, 2 * w(t, 1, ph + 0.25), 3.5 * w(t, 1, ph + 0.4))
	end

	for i, p in PEPPERS do
		local rx = 9 * w(t, p[1], p[2])
		local rz = 7 * w(t, p[1], p[2] + 0.25)
		local y = 0
		if i == 3 then
			-- hero pepper: trembles + lifts while heating, kicks back on the flare
			rx = rx * (1 - heat) + 4 * tremble + 62 * kick
			rz = rz * (1 - heat) + 6 * heat * sin(TAU * 10 * c + 1)
			y = 0.35 * heat
		else
			rx += 8 * kick
		end
		pose["Pepper" .. i] = pa(0, y, 0, rx, 3 * w(t, 1, p[2]), rz)
		local base = clamp(0.25 + 0.2 * w(t, 2, p[2]), 0, 1)
		local tr = (i == 3) and base * (1 - glow) or base * (1 - 0.6 * glow)
		ctx.transparency("PepGlow" .. i, tr)
		ctx.transparency("PepTip" .. i, tr * 0.6)
	end

	for k = 1, 4 do
		ctx.transparency("LeafEmber" .. k, clamp(0.3 + 0.3 * w(t, 2, k * 0.25) - 0.3 * glow, 0, 1))
	end
	ctx.transparency("TrunkGlow", clamp(0.2 + 0.2 * w(t, 2, 0.1) - 0.2 * glow, 0, 1))
	ctx.transparency("TrunkGlow2", clamp(0.2 + 0.2 * w(t, 2, 0.35) - 0.2 * glow, 0, 1))
	ctx.transparency("Puddle", clamp(0.2 + 0.2 * w(t, 1, 0.5), 0, 1))

	ctx.light("FlareLight", clamp(0.5 + 0.1 * w(t, 2, 0.3) + 0.8 * heat + 1.2 * clamp(glow - heat, 0, 1), 0, 2))
	ctx.light("BushLight", clamp(0.8 + 0.15 * w(t, 2, 0.6) + 0.5 * glow, 0, 2))

	if ctx.crossed(4.4) then
		ctx.emit("FlareSparks", 6)
	end
	if ctx.crossed(FLARE) then
		ctx.emit("FlareSparks", 40)
		ctx.emit("FlareFire", 14)
		ctx.emit("Embers", 12)
		ctx.emit("Drip3", 4)
	end
end

return M
