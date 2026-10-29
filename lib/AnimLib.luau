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

---------------------------------------------------------------------------
-- Gameplay states (guardians / NPCs)
---------------------------------------------------------------------------
-- A Motion module can define named states instead of one loop:
--
--   M.States = {
--     Idle  = { Loop = true, Length = 12, Update = function(t, pose, ctx) end },
--     Chase = { Loop = true, Length = 0.6, Speed = 22, Update = ... }, -- Speed: studs/s the stride matches
--     Alert = { Length = 1.6, Update = ... },  -- one-shot: plays once, then back to the looping state
--   }
--   M.Base  = "Idle"                          -- looping state at spawn
--   M.Props = { AngryMark = 1 }               -- parts states show/hide + their resting transparency
--   M.Reel  = { { "Idle" }, { "Alert" }, { "Chase", 3 } }  -- showcase demo order (seconds per entry)
--   return L.states(M)
--
-- Inside a state's Update, t is the time since the state started (it keeps
-- growing in looping states, so use t % Length or waves of t) and
-- ctx.crossed(sec) fires once per pass in that state's own clock.
-- L.states fills in M.Cycle / M.Update so the reel plays as one long loop
-- (previews + showcase); the Animator drives the real states in game.

local BLEND = 0.2
local EPS = 1e-4
local IDENT = CFrame.new()

local function noop() end
local MUTED = { crossed = function() return false end, emit = noop, enable = noop, light = noop, transparency = noop }

function L.runner(M)
	local states = M.States
	local props = M.Props or {}
	local R = { base = M.Base or "Idle", auto = true }
	local cur, curT, prevT, fresh = nil, 0, 0, false
	local from, fromT, blendT, blendLen = nil, 0, 0, 0
	local poseA = {}
	local outer = MUTED
	local propNow = {}

	local sub = {}
	function sub.crossed(at)
		local st = states[cur]
		if st.Loop then
			local len = st.Length
			if curT - prevT >= len then
				return true
			end
			local p, c = prevT % len, curT % len
			if c >= p then
				return p < at and at <= c
			end
			return at > p or at <= c
		end
		return prevT < at and at <= curT
	end
	function sub.emit(n, k) outer.emit(n, k) end
	function sub.enable(n, on) outer.enable(n, on) end
	function sub.light(n, b) outer.light(n, b) end
	function sub.transparency(n, v)
		if props[n] ~= nil then
			propNow[n] = v
		else
			outer.transparency(n, v)
		end
	end

	-- Start a state from its first frame, blending out of the current pose.
	function R.enter(name)
		if not states[name] then
			return
		end
		if cur and not fresh then
			from, fromT, blendT = cur, curT, 0
		end
		blendLen = states[name].Blend or BLEND
		cur, curT, prevT, fresh = name, 0, -EPS, true
	end
	-- Jump straight into a state at time st (no blend, no effects replayed).
	function R.jump(name, st)
		cur, curT, prevT, fresh, from = name, st, st, false, nil
	end
	-- Looping "base" state the monster returns to after one-shots.
	function R.setBase(name)
		if not states[name] then
			return
		end
		R.base = name
		if cur == nil or (states[cur].Loop and cur ~= name) then
			R.enter(name)
		end
	end
	-- Play any state now (a looping one also becomes the new base).
	function R.play(name)
		local st = states[name]
		if not st then
			return
		end
		if st.Loop then
			R.base = name
		end
		R.enter(name)
	end
	function R.current()
		return cur, curT
	end

	local function eval(name, t, pose, ctx)
		local st = states[name]
		if not st.Loop then
			t = math.min(t, st.Length)
		end
		st.Update(t, pose, ctx)
	end

	function R.step(dt, pose, ctx)
		outer = ctx or MUTED
		if cur == nil then
			R.enter(R.base)
		end
		if fresh then
			fresh = false
		else
			prevT = curT
			curT += dt
		end
		local st = states[cur]
		if R.auto and not st.Loop and curT >= st.Length then
			R.enter(R.base)
			fresh = false
		end

		table.clear(propNow)
		for n, v in props do
			propNow[n] = v
		end
		eval(cur, curT, pose, sub)
		for n, v in propNow do
			outer.transparency(n, v)
		end

		if from then
			fromT += dt
			blendT += dt
			local k = blendT / blendLen
			if k >= 1 then
				from = nil
			else
				k = k * k * (3 - 2 * k)
				table.clear(poseA)
				eval(from, fromT, poseA, MUTED)
				for n, a in poseA do
					pose[n] = a:Lerp(pose[n] or IDENT, k)
				end
				for n, b in pose do
					if poseA[n] == nil then
						pose[n] = IDENT:Lerp(b, k)
					end
				end
			end
		end
	end
	return R
end

-- Validates M.States and builds the showcase reel: M.Cycle + M.Update(t, pose, ctx).
function L.states(M)
	assert(type(M.States) == "table", "L.states: M.States missing")
	for name, st in M.States do
		assert(type(st.Update) == "function", "state " .. name .. " needs Update(t, pose, ctx)")
		assert(type(st.Length) == "number" and st.Length > 0, "state " .. name .. " needs Length > 0")
	end
	M.Base = M.Base or "Idle"
	assert(M.States[M.Base] and M.States[M.Base].Loop, "M.Base must be a looping state")
	local reel = M.Reel or { { M.Base } }
	local segs, total = {}, 0
	for _, e in reel do
		local name = e[1]
		assert(M.States[name], "M.Reel: unknown state " .. tostring(name))
		local d = e[2] or M.States[name].Length
		table.insert(segs, { name = name, start = total, dur = d })
		total += d
	end
	M.ReelSegments = segs
	total = math.floor(total * 1e6 + 0.5) / 1e6
	M.Cycle = total
	local rr = L.runner(M)
	rr.auto = false
	local lastT, idx = nil, 0
	local function segAt(c)
		for i = #segs, 1, -1 do
			if c >= segs[i].start then
				return i
			end
		end
		return 1
	end
	function M.Update(t, pose, ctx)
		local c = t % total
		local i = segAt(c)
		local dt = lastT and (t - lastT) or 0
		if lastT == nil or dt < 0 or dt > 1 then
			idx = i
			rr.jump(segs[i].name, c - segs[i].start)
			dt = 0
		elseif i ~= idx then
			idx = i
			rr.enter(segs[i].name)
		end
		lastT = t
		rr.step(dt, pose, ctx)
	end
	return M
end

return L
