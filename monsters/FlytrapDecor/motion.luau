-- Snappy Flytrap motion (8 s loop): fly buzzes around, lands, SNAP, chew,
-- burp, reopen; the fly flies back in from afar so the loop is seamless.
local L = require(script.Parent.AnimLib)
local ang, wave, E = L.ang, L.wave, L.ease
local M = {}
M.Cycle = 8

local OPEN = 58
local FAR = Vector3.new(7, 2.5, -6)
local FLY_PARTS = { "FlyBody", "FlyHead", "FlyEyeR", "FlyEyeL" }

-- buzzing figure-8 around the trap (offset from the fly's rest spot in the mouth)
local function orbit(c)
	local a = c / 3.5 * math.pi * 2
	return Vector3.new(1.9 * math.sin(a), 1.1 + 0.45 * math.sin(2 * a), -0.6 - 1.4 * math.cos(a))
end

local function lerpV(a, b, k)
	return a + (b - a) * k
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- lid angle: open, SNAP shut with overshoot, chew bobs, burp pop, reopen
	local lid
	if c < 4.25 then
		lid = OPEN
	elseif c < 4.4 then
		lid = OPEN * (1 - E.quadIn((c - 4.25) / 0.15)) - 4
	elseif c < 6.1 then
		local k = (c - 4.4) / 1.7
		lid = -4 * (1 - math.min(1, k * 4)) + 7 * math.max(0, math.sin(k * math.pi * 3))
	elseif c < 6.5 then
		lid = 16 * math.sin((c - 6.1) / 0.4 * math.pi)
	elseif c < 7.6 then
		lid = OPEN * E.backOut((c - 6.6) / 1.0 > 0 and math.min(1, (c - 6.6) / 1.0) or 0)
	else
		lid = OPEN
	end
	pose.Lid = ang(lid, 0, 0)

	-- head: gentle idle bob, jolt on the snap, squash while chewing
	local snap = L.env(c, 4.25, 0.08, 0.05, 0.4, "quadOut", "backOut")
	local chew = (c > 4.4 and c < 6.1) and math.max(0, math.sin((c - 4.4) / 1.7 * math.pi * 3)) or 0
	local look = c < 4.25 and 10 * math.sin(c / 3.5 * math.pi * 2) or 0
	pose.Head = L.pa(0, 0.06 * wave(t, 0.5) - 0.12 * chew, 0, -12 * snap + 4 * chew, look, 3 * wave(t, 0.25))
	pose.Stem = ang(2 * wave(t, 0.25, 0.3), 0, 2.5 * wave(t, 0.375))

	-- fly path
	local off, visible = Vector3.new(), true
	if c < 3.5 then
		off = orbit(c)
	elseif c < 4.2 then
		off = lerpV(orbit(3.5), Vector3.new(), E.cubicInOut((c - 3.5) / 0.7))
	elseif c < 7.0 then
		visible = c < 4.32
	else
		off = lerpV(FAR, orbit(0), E.cubicOut((c - 7.0) / 1.0))
	end
	pose.Fly = CFrame.new(off) * ang(0, 20 * wave(t, 2), 0)
	local flap = visible and 50 * wave(t, 12) or 0
	pose.WingR = ang(0, 0, flap)
	pose.WingL = ang(0, 0, -flap)
	for _, n in FLY_PARTS do
		ctx.transparency(n, visible and 0 or 1)
	end
	ctx.transparency("FlyWingR", visible and 0.35 or 1)
	ctx.transparency("FlyWingL", visible and 0.35 or 1)

	if ctx.crossed(6.3) then
		ctx.emit("Burp", 12)
	end
end

return M
