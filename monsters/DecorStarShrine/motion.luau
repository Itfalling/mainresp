--!nocheck
-- Floating Crystal Shrine: a calm, seamless 8 s loop.
-- * the big crystal turns one full turn per loop and bobs gently (one slow
--   bob + a tiny tilt sway)
-- * the four stars orbit the other way (one turn per loop), each twirling about
--   its vertical axis (two turns per loop) and bobbing with its own phase
-- * the crystal light breathes softly
-- All waves use whole cycles per loop, so t = 0 matches t = 8.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin = math.sin

local M = {}
M.Cycle = 8
local TAU = math.pi * 2

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle
	local turn = 360 * c / M.Cycle

	pose.Crystal = CFrame.new(0, 0.55 * w(t, 1), 0) * CFrame.Angles(0, math.rad(turn), 0) * ang(2.5 * w(t, 1, 0.25), 0, 2.5 * w(t, 1, 0.5))
	pose.Orbit = CFrame.new(0, 0.2 * w(t, 1, 0.5), 0) * ang(0, -turn, 0)
	for i = 1, 4 do
		pose["Star" .. i] = CFrame.new(0, 0.35 * w(t, 2, i * 0.25), 0) * ang(0, 2 * turn * ((i % 2 == 0) and -1 or 1), 0)
	end
	ctx.light("CrystalLight", 1.1 + 0.25 * w(t, 2))
end

return M
