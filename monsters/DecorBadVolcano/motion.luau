-- Mini Smoking Volcano: calm 8 s loop.
-- The crater lava glow pulses hot/cool (2 pulses per loop), the hot core runs
-- down the lava drip in a wave, the crater light breathes with it, and a lava
-- bubble swells and plops once per pulse.
local L = require(script.Parent.AnimLib)
local M = {}
M.Cycle = 8

local DRIPS = 5

function M.Update(t, pose, ctx)
	-- 0.25 Hz = 2 full pulses per 8 s loop (seamless)
	local hot = L.wave01(t, 0.25)
	ctx.transparency("LavaGlow", 0.08 + 0.8 * (1 - hot))
	ctx.transparency("LavaGlowB", 0.05 + 0.9 * (1 - L.wave01(t, 0.25, -0.08)))
	ctx.transparency("PuddleGlow", 0.1 + 0.75 * (1 - L.wave01(t, 0.25, -0.45)))
	ctx.light("CraterLight", 0.7 + 0.7 * hot)
	-- glow travels down the drip (top segment first)
	for i = 1, DRIPS do
		ctx.transparency("DripGlow" .. i, 0.05 + 0.9 * (1 - L.wave01(t, 0.25, -0.08 * i)))
	end
	-- lava bubble: swells while the glow builds, plops back down
	local c = t % 4
	local swell = L.env(c, 0.6, 1.6, 0.2, 0.5, "sineInOut", "quadIn")
	pose.Bubble = L.pa(0, 0.45 * swell - 0.15, 0, 0, 40 * swell, 0)
end
return M
