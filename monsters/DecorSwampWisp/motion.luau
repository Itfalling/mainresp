-- Wisp Lantern Post: the will-o'-wisp circles the hanging lantern once per
-- loop, bobbing softly and keeping its tail behind it; two tiny motes circle
-- closer in (one the other way round); the lantern sways a little.
-- Calm, seamless 8 s loop (every wave is a whole multiple of 1/8 Hz).
local L = require(script.Parent.AnimLib)
local pa, ang = L.pa, L.ang
local M = {}
M.Cycle = 8

local TAU = math.pi * 2
local ORB = 2.4 -- must match build.luau

function M.Update(t, pose, ctx)
	local th = TAU * (t % M.Cycle) / M.Cycle

	-- wisp: orbit around the lantern (rest spot is at angle 0, +X of the lantern)
	local r = ORB + 0.15 * math.sin(2 * th)
	local bob = 0.55 * math.sin(2 * th) + 0.2 * math.sin(3 * th)
	local x = r * math.cos(th) - ORB
	local z = -r * math.sin(th)
	pose.Wisp = pa(x, bob, z, 7 * math.sin(4 * th), math.deg(th), 6 * math.cos(2 * th))

	-- mote 1: opposite direction, low and close (rest at angle pi, radius 1.5)
	local p1 = math.pi - th
	local r1 = 1.5
	pose.Mote1 = pa(r1 * math.cos(p1) + r1, 0.3 * math.sin(3 * th), -r1 * math.sin(p1), 0, 0, 0)

	-- mote 2: twice per loop, high (rest at angle -pi/2, radius 1.4)
	local p2 = -math.pi / 2 + 2 * th
	local r2 = 1.4
	pose.Mote2 = pa(r2 * math.cos(p2), 0.25 * math.sin(2 * th), -r2 * math.sin(p2) - r2, 0, 0, 0)

	-- lantern: gentle sway on its hook
	pose.Lantern = ang(3 * math.sin(th + 0.6), 0, 4 * math.sin(2 * th))
end

return M
