--!nocheck
-- Obsidian Corn: seamless 9 s loop.
-- * the three obsidian stalks sway in a two-bone chain (base + top) with
--   different phases; charred husk leaves flap; the cobs bob on their stems
-- * glow waves run UP every cob all the time (the spiralling neon kernels
--   light row by row, bottom to top); veins, tassels and puddle pulse
-- * POP beat (4.3-7.6 s): the cobs charge (kernel waves speed up and
--   brighten, cobs tremble), then pop in sequence (5.2 / 5.65 / 6.1 / 6.55 s):
--   each cob's rows flash bottom->top, the cob jolts on its stem, a burst of
--   sparks fires and two glowing popcorn kernels shoot out of it in arcs
--   (trails) and drop back in; the lights flash with each pop
-- Waves use whole cycles per loop; envelopes are 0 at both loop ends.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, exp, clamp, pi = math.sin, math.exp, math.clamp, math.pi

local M = {}
M.Cycle = 9

local TAU = math.pi * 2
local ROWS = 6
local POP0, GAP = 5.2, 0.45
local FLY = 1.15

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end
local function spring(dt, k, f, len)
	if dt <= 0 or dt > len then
		return 0
	end
	return exp(-k * dt) * sin(f * dt) * (1 - dt / len)
end
local function spike(dt, up, down)
	if dt < 0 or dt > up + down then
		return 0
	end
	if dt < up then
		return dt / up
	end
	return 1 - (dt - up) / down
end

-- cob outward directions (deg, must match build.luau) -> pop arcs
local COBDEG = { 330, 280, 80, 140 }
local POPS = { { 1, -35 }, { 1, 40 }, { 2, -30 }, { 2, 35 }, { 3, -40 }, { 3, 30 } }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	local charge = L.track(c, { { 4.3, 0 }, { 5.2, 1, "quadIn" }, { 6.9, 0.6 }, { 7.6, 0, "sineInOut" } })
	local tremble = charge * sin(TAU * 11 * c)

	-- stalk chains
	local PH = { 0.0, 0.33, 0.6 }
	for si = 1, 3 do
		local ph = PH[si]
		local jolt = spring(c - (POP0 + (si - 1) * GAP), 3.5, 10, 2.0)
		pose["Stalk" .. si] = ang(1.6 * w(t, 1, ph) + 0.6 * tremble, 0.8 * w(t, 1, ph + 0.5), 2.0 * w(t, 1, ph + 0.25))
		pose["Stalk" .. si .. "Top"] = ang(3.4 * w(t, 1, ph + 0.12) - 4 * jolt, 1.2 * w(t, 2, ph), 3.0 * w(t, 1, ph + 0.37) + 0.8 * tremble)
	end

	-- leaves flap
	for li = 1, 11 do
		local ph = li * 0.137
		pose["Leaf" .. li] = ang(7 * w(t, 2, ph) + 2 * tremble, 3 * w(t, 1, ph + 0.3), 4 * w(t, 2, ph + 0.25))
	end

	-- cobs: bob, tremble, jolt; kernel glow waves + pop flashes
	local flashSum = 0
	for ci = 1, 4 do
		local T = POP0 + (ci - 1) * GAP
		local jolt = spring(c - T, 3.2, 12, 2.2)
		pose["Cob" .. ci] = ang(4 * w(t, 2, ci * 0.21) + 3 * tremble + 14 * jolt, 2 * w(t, 1, ci * 0.3), 3 * w(t, 2, ci * 0.21 + 0.25) - 2 * tremble)
		for r = 1, ROWS do
			local wave = 0.5 + 0.5 * sin(TAU * (3 * t / M.Cycle - r * 0.16 + ci * 0.25))
			local fast = 0.5 + 0.5 * sin(TAU * (9 * t / M.Cycle - r * 0.2))
			local glow = (1 - charge) * wave + charge * (0.6 + 0.4 * fast)
			local flash = spike(c - (T + (r - 1) * 0.06), 0.05, 0.35)
			flashSum += flash / ROWS
			ctx.transparency("K" .. ci .. "_" .. r, clamp(0.7 - 0.65 * glow - flash, 0, 1))
		end
		ctx.transparency("CobTip" .. ci, clamp(0.4 - 0.4 * charge - spike(c - (T + 0.36), 0.05, 0.5), 0, 1))
		if ci <= 3 and ctx.crossed(T + 0.36) then
			ctx.emit("PopSparks" .. ci, 30)
		end
	end
	if ctx.crossed(POP0 + 3 * GAP + 0.36) then
		ctx.emit("Embers", 20)
	end

	-- popcorn kernels fly out of the cobs and fall back in
	for pi_, pp in POPS do
		local ci, side = pp[1], pp[2]
		local T = POP0 + (ci - 1) * GAP + 0.36
		local u = (c - T) / FLY
		if u > 0 and u < 1 then
			local a = math.rad(COBDEG[ci] + side)
			local out = 2.4 * sin(pi * u)
			local y = 4 * 3.4 * u * (1 - u)
			pose["Pop" .. pi_] = pa(math.sin(a) * out, y, -math.cos(a) * out, 540 * u, 360 * u, 200 * u)
			ctx.transparency("PopGlow" .. pi_, 0)
		else
			pose["Pop" .. pi_] = pa(0, 0, 0, 0, 0, 0)
			ctx.transparency("PopGlow" .. pi_, 0.3)
		end
	end

	-- veins, tassels, puddle
	for si = 1, 3 do
		ctx.transparency("Vein" .. si, clamp(0.25 + 0.25 * w(t, 2, si * 0.3) - 0.3 * charge, 0, 1))
		ctx.transparency("Tassel" .. si .. "_top", clamp(0.2 + 0.3 * w(t, 3, si * 0.2), 0, 1))
		for k = 0, (si == 1) and 6 or 4, 2 do
			ctx.transparency("Tassel" .. si .. "_" .. k, clamp(0.25 + 0.35 * w(t, 3, si * 0.2 + k * 0.1), 0, 1))
		end
	end
	ctx.transparency("Puddle", clamp(0.2 + 0.2 * w(t, 1, 0.5), 0, 1))

	ctx.light("CobLight1", clamp(0.8 + 0.15 * w(t, 3, 0.1) + 0.5 * charge + 2.5 * flashSum, 0, 2))
	ctx.light("CobLight2", clamp(0.6 + 0.15 * w(t, 3, 0.4) + 0.4 * charge + 2.0 * flashSum, 0, 2))
	ctx.light("GroundLight", clamp(0.8 + 0.15 * w(t, 2, 0.7) + 0.3 * charge, 0, 2))
end

return M
