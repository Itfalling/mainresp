--!nocheck
-- AnimLib: tiny math toolkit shared by every monster's Motion module.
-- Uses only Luau built-ins + CFrame/Vector3, so the exact same code runs in
-- Roblox (client) and in the offline preview baker.

local L = {}

local sin, cos, pi, abs, clamp, floor = math.sin, math.cos, math.pi, math.abs, math.clamp, math.floor
local TAU = pi * 2
local rad = math.rad

L.TAU = TAU

---------------------------------------------------------------------------
-- Basic helpers
---------------------------------------------------------------------------

-- Rotation from DEGREES (X, Y, Z). The workhorse of every Motion module.
function L.ang(x, y, z)
	return CFrame.Angles(rad(x or 0), rad(y or 0), rad(z or 0))
end

-- Translation + rotation (degrees) in one call.
function L.pa(px, py, pz, rx, ry, rz)
	return CFrame.new(px or 0, py or 0, pz or 0) * CFrame.Angles(rad(rx or 0), rad(ry or 0), rad(rz or 0))
end

-- Sine wave in [-1, 1]. freq in Hz, phase in cycles (0..1).
function L.wave(t, freq, phase)
	return sin(TAU * ((freq or 1) * t + (phase or 0)))
end

-- Cosine-ish wave in [0, 1].
function L.wave01(t, freq, phase)
	return 0.5 - 0.5 * cos(TAU * ((freq or 1) * t + (phase or 0)))
end

-- Sharp "bounce" wave in [0, 1] (abs of sine) – great for hops and footfalls.
function L.bounce(t, freq, phase)
	return abs(sin(pi * ((freq or 1) * t + (phase or 0))))
end

-- Sawtooth in [0, 1).
function L.saw(t, freq, phase)
	local x = (freq or 1) * t + (phase or 0)
	return x - floor(x)
end

-- Triangle wave in [-1, 1].
function L.tri(t, freq, phase)
	local x = L.saw(t, freq, phase)
	return 1 - 4 * abs(x - 0.5)
end

-- Smooth organic noise in roughly [-1, 1].
function L.noise(t, seed, freq)
	return clamp(math.noise((freq or 1) * t, (seed or 0) + 0.31, 0.77) * 2, -1, 1)
end

function L.lerp(a, b, k)
	return a + (b - a) * k
end

function L.clamp01(x)
	return clamp(x, 0, 1)
end

-- Map x from [a, b] to [0, 1] (clamped).
function L.remap(x, a, b)
	if b == a then
		return x >= b and 1 or 0
	end
	return clamp((x - a) / (b - a), 0, 1)
end

function L.smoothstep(x)
	x = clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end

---------------------------------------------------------------------------
-- Easing (all map 0..1 -> 0..1, some overshoot on purpose)
---------------------------------------------------------------------------

local E = {}
L.ease = E

function E.linear(x) return x end
function E.quadIn(x) return x * x end
function E.quadOut(x) return 1 - (1 - x) * (1 - x) end
function E.quadInOut(x)
	if x < 0.5 then return 2 * x * x end
	return 1 - (-2 * x + 2) ^ 2 / 2
end
function E.cubicIn(x) return x * x * x end
function E.cubicOut(x) return 1 - (1 - x) ^ 3 end
function E.cubicInOut(x)
	if x < 0.5 then return 4 * x * x * x end
	return 1 - (-2 * x + 2) ^ 3 / 2
end
function E.sineInOut(x) return -(cos(pi * x) - 1) / 2 end
function E.expoOut(x)
	if x >= 1 then return 1 end
	return 1 - 2 ^ (-10 * x)
end
function E.expoIn(x)
	if x <= 0 then return 0 end
	return 2 ^ (10 * x - 10)
end
-- Overshoots past 1 then settles (anticipation/follow-through).
function E.backOut(x)
	local c1, c3 = 1.70158 * 1.4, 1.70158 * 1.4 + 1
	return 1 + c3 * (x - 1) ^ 3 + c1 * (x - 1) ^ 2
end
-- Pulls back below 0 before going (wind-up).
function E.backIn(x)
	local c1, c3 = 1.70158 * 1.4, 1.70158 * 1.4 + 1
	return c3 * x * x * x - c1 * x * x
end
function E.backInOut(x)
	local c2 = 1.70158 * 1.525
	if x < 0.5 then
		return ((2 * x) ^ 2 * ((c2 + 1) * 2 * x - c2)) / 2
	end
	return ((2 * x - 2) ^ 2 * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
end
function E.elasticOut(x)
	if x <= 0 then return 0 end
	if x >= 1 then return 1 end
	return 2 ^ (-10 * x) * sin((x * 10 - 0.75) * (TAU / 3)) + 1
end
function E.bounceOut(x)
	local n1, d1 = 7.5625, 2.75
	if x < 1 / d1 then
		return n1 * x * x
	elseif x < 2 / d1 then
		x -= 1.5 / d1
		return n1 * x * x + 0.75
	elseif x < 2.5 / d1 then
		x -= 2.25 / d1
		return n1 * x * x + 0.9375
	end
	x -= 2.625 / d1
	return n1 * x * x + 0.984375
end

local function getEase(e)
	if e == nil then return E.sineInOut end
	if type(e) == "function" then return e end
	local f = E[e]
	if not f then error("AnimLib: unknown ease '" .. tostring(e) .. "'") end
	return f
end
L.getEase = getEase

---------------------------------------------------------------------------
-- Envelopes and keyframe tracks (for the big "special move" moments)
---------------------------------------------------------------------------

-- 0 -> 1 -> 0 envelope. Rises during [start, start+attack], holds for `hold`,
-- falls during `release`. Eases are optional (names or functions).
function L.env(c, start, attack, hold, release, easeIn, easeOut)
	if c < start then return 0 end
	local a = start + attack
	if c < a then return getEase(easeIn or "sineInOut")((c - start) / attack) end
	local h = a + (hold or 0)
	if c < h then return 1 end
	local r = h + (release or 0)
	if c < r then return 1 - getEase(easeOut or "sineInOut")((c - h) / release) end
	return 0
end

-- Keyframe track over numbers.
-- keys = { {time, value, easeIntoThisKey?}, ... } sorted by time.
-- Before the first key -> first value, after the last -> last value.
function L.track(c, keys)
	local n = #keys
	if n == 0 then return 0 end
	if c <= keys[1][1] then return keys[1][2] end
	for i = 2, n do
		local k = keys[i]
		if c <= k[1] then
			local p = keys[i - 1]
			local span = k[1] - p[1]
			local x = span > 0 and (c - p[1]) / span or 1
			return p[2] + (k[2] - p[2]) * getEase(k[3])(x)
		end
	end
	return keys[n][2]
end

-- Keyframe track over {x, y, z} triples (e.g. degrees). Returns x, y, z.
function L.track3(c, keys)
	local n = #keys
	if n == 0 then return 0, 0, 0 end
	local first = keys[1][2]
	if c <= keys[1][1] then return first[1], first[2], first[3] end
	for i = 2, n do
		local k = keys[i]
		if c <= k[1] then
			local p = keys[i - 1]
			local span = k[1] - p[1]
			local x = getEase(k[3])(span > 0 and (c - p[1]) / span or 1)
			local a, b = p[2], k[2]
			return a[1] + (b[1] - a[1]) * x, a[2] + (b[2] - a[2]) * x, a[3] + (b[3] - a[3]) * x
		end
	end
	local last = keys[n][2]
	return last[1], last[2], last[3]
end

-- Keyframed rotation (degrees triples) straight to a CFrame.
function L.trackAng(c, keys)
	local x, y, z = L.track3(c, keys)
	return L.ang(x, y, z)
end

---------------------------------------------------------------------------
-- Symmetry
---------------------------------------------------------------------------

-- Mirror a joint transform across the model's YZ plane (left <-> right).
-- Bones built with Builder:sym() are mirrored the same way, so
-- pose.ArmL = L.mirror(armRPose) gives perfectly symmetric motion.
function L.mirror(cf)
	local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
	return CFrame.new(-x, y, z, r00, -r01, -r02, -r10, r11, r12, -r20, r21, r22)
end

-- Set a right-side pose and its mirrored left twin in one go.
-- name is the base bone name; bones are named name.."R" and name.."L".
function L.both(pose, name, cfRight, cfLeft)
	pose[name .. "R"] = cfRight
	pose[name .. "L"] = L.mirror(cfLeft or cfRight)
end

-- Follow-through for chains (tails, tentacles, necks): returns a function
-- f(i) giving a delayed wave for segment i, so motion ripples down the chain.
function L.chain(t, freq, lag, amp)
	return function(i, phaseOffset)
		return (amp or 1) * sin(TAU * (freq * t - (lag or 0.1) * i + (phaseOffset or 0)))
	end
end

return L
