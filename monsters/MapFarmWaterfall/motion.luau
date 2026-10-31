--!nocheck
-- Sunny Falls motion (4 s loop, seamless).
-- * MainA / MainB / Upper: the falling streak + foam dashes slide DOWN by
--   whole dash periods per loop (MainA 1 period, MainB and Upper 2) and fade
--   in under the lip / out into the splash, so the water pours continuously
-- * splash churn bobs, ripple rings slide outward and fade, lily pads bob,
--   the water wheel turns once per loop
local L = require(script.Parent.AnimLib)
local wave, ang = L.wave, L.ang

local M = {}
M.Cycle = 4

local function frac(x)
	return x - math.floor(x)
end
local function c01(x)
	return math.clamp(x, 0, 1)
end

-- MUST match build.luau
local FLOWS = {
	{ bone = "MainA", pre = "MA", S = 4, k = 2, yBot = 5.6, yTop = 23.4, n = 14, subs = 1, fT = 1.6, fB = 1.6, base = 0.1 },
	{ bone = "MainB", pre = "MB", S = 4, k = 3, yBot = 5.6, yTop = 23.4, n = 6, subs = 1, fT = 1.4, fB = 1.4, base = 0 },
	{ bone = "Upper", pre = "UP", S = 4, k = 3, yBot = 24.8, yTop = 39.8, n = 7, subs = 2, fT = 1.2, fB = 1.0, base = 0 },
}
local function dashSpec(Lr, c, s)
	if Lr.pre == "MA" then
		return -5.55 + (c - 1) * 0.85 + 0.25 * (frac(c * 0.71) - 0.5), 0.3 + 0.25 * frac(c * 0.37), Lr.S * frac(c * 0.618 + 0.1), 2.2 + 1.3 * frac(c * 0.377 + 0.2)
	elseif Lr.pre == "MB" then
		local ph = Lr.S * frac(c * 0.414 + 0.3) + (s - 1) * (Lr.S / 2 + 1.2 * (frac(c * 0.83) - 0.5))
		return -4.6 + (c - 1) * 1.85 + 0.5 * (frac(c * 0.53) - 0.5), 0.45 + 0.3 * frac(c * 0.29), ph % Lr.S, 0.8 + 0.9 * frac(c * 0.61 + s * 0.27)
	else
		local ph = Lr.S * frac(c * 0.57 + 0.2) + (s - 1) * Lr.S * 0.5
		return -3.1 + (c - 1) * 1.03 + 0.2 * (frac(c * 0.47) - 0.5), (s == 1) and (0.3 + 0.2 * frac(c * 0.37)) or (0.45 + 0.25 * frac(c * 0.59)), ph % Lr.S, (s == 1) and (1.6 + 1.0 * frac(c * 0.33)) or (0.9 + 0.7 * frac(c * 0.71))
	end
end

-- precompute every dash that can ever reach a fade zone
local DASH = {}
for _, Lr in FLOWS do
	local rows = math.ceil((Lr.yTop - Lr.yBot) / Lr.S) + 1
	Lr.list = {}
	for c = 1, Lr.n do
		for s = 1, Lr.subs do
			local _, _, ph, len = dashSpec(Lr, c, s)
			for j = 0, rows do
				local y = Lr.yBot + ph + j * Lr.S
				if y + len / 2 - Lr.S >= Lr.yTop then
					continue
				end
				local alwaysIn = (y + len / 2 <= Lr.yTop - Lr.fT) and (y - Lr.S - len / 2 >= Lr.yBot + Lr.fB)
				if not alwaysIn then
					table.insert(Lr.list, { ("%s%d_%d_%d"):format(Lr.pre, c, s, j), y, len })
				end
			end
		end
	end
end

-- ripples (MUST match build.luau)
local R0, D = 4.5, 3.5
local DIRS = { 180, 220, 270, 320, 360 }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	for _, Lr in FLOWS do
		local o = (t * Lr.k * Lr.S / M.Cycle) % Lr.S
		pose[Lr.bone] = CFrame.new(0, -o, 0)
		for _, d in Lr.list do
			local yc = d[2] - o
			local a = c01((Lr.yTop - (yc + d[3] / 2)) / Lr.fT) * c01(((yc - d[3] / 2) - Lr.yBot) / Lr.fB)
			ctx.transparency(d[1], Lr.base + (1 - Lr.base) * (1 - a))
		end
	end

	-- splash churn
	for k = 1, 3 do
		local ph = k * 0.31
		pose["Churn" .. k] = CFrame.new(0.15 * wave(t, 0.5, ph), 0.35 * wave(t, 1, ph), 0) * ang(0, 8 * wave(t, 0.5, ph + 0.2), 4 * wave(t, 0.75, ph))
	end
	pose.ChurnUp = CFrame.new(0, 0.2 * wave(t, 1.25, 0.1), 0) * ang(0, 6 * wave(t, 0.5), 0)

	-- ripple rings: slide outward one spacing per loop, fade in/out
	local o = (t * D / M.Cycle) % D
	for di, th in DIRS do
		local dx, dz = math.cos(math.rad(th)), math.sin(math.rad(th))
		pose["Ripple" .. di] = CFrame.new(dx * o, 0, dz * o)
		for i = 0, 1 do
			local r = R0 + i * D + o
			local a = c01((r - R0) / 1.5) * c01((R0 + 2 * D - r) / 2.2)
			ctx.transparency(("Rip%d_%d"):format(di, i), 1 - 0.85 * a)
		end
	end

	-- lily pads
	for k = 1, 4 do
		local ph = k * 0.23
		pose["Pad" .. k] = CFrame.new(0.2 * wave(t, 0.25, ph), 0.05 * wave(t, 0.5, ph), 0.15 * wave(t, 0.25, ph + 0.25)) * ang(0, 10 * wave(t, 0.25, ph + 0.1), 0)
	end

	-- water wheel: one turn per loop (water lands on its -X side)
	pose.Wheel = ang(0, 0, 360 * c / M.Cycle)
end

return M
