--!nocheck
-- Solar Griffin motion.
-- Idle: bouncy knees, snappy bird head turns + curious tilts, a talon tap,
-- wing ruffles, tail swish, blinks.
-- Signature "SOLAR ASCENSION": deep crouch with wings thrown up (anticipation)
-- -> huge downbeat launches the body ~5 studs -> 3 big hover flaps ->
-- screech with beak flung open + solar/feather burst (wings held in a V) ->
-- drop and land with a big squash + dust -> wings fold with follow-through.
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave
local sqrt, atan2, acos, cos, sin, clamp, max, abs = math.sqrt, math.atan2, math.acos, math.cos, math.sin, math.clamp, math.max, math.abs
local rad, deg = math.rad, math.deg

local M = {}
M.Cycle = 9

---------------------------------------------------------------------------
-- rig data (rest pivots, must match build.luau)
---------------------------------------------------------------------------
local BODY = Vector3.new(0, 8.6, 2.0)
local CHEST = Vector3.new(0, 9.8, -0.6)

local function newLeg(hip, knee, foot)
	local leg = { hip = hip, knee = knee, foot = foot }
	local function a(dy, dz) return atan2(-dz, -dy) end -- 0 = pointing straight down
	leg.l1 = sqrt((knee.Y - hip.Y) ^ 2 + (knee.Z - hip.Z) ^ 2)
	leg.l2 = sqrt((foot.Y - knee.Y) ^ 2 + (foot.Z - knee.Z) ^ 2)
	leg.a1 = a(knee.Y - hip.Y, knee.Z - hip.Z)
	leg.a2 = a(foot.Y - knee.Y, foot.Z - knee.Z)
	local base = a(foot.Y - hip.Y, foot.Z - hip.Z)
	leg.bend = (leg.a1 - base) >= 0 and 1 or -1
	return leg
end
local HIND = newLeg(Vector3.new(2.5, 9.0, 4.8), Vector3.new(3.0, 5.6, 5.8), Vector3.new(3.0, 1.6, 5.8))
local FRONT = newLeg(Vector3.new(2.5, 9.6, -2.8), Vector3.new(2.8, 6.2, -2.6), Vector3.new(2.8, 1.5, -3.0))

-- 2-bone IK in the side (Y/Z) plane. Returns local X angles (deg) for the
-- upper bone, lower bone and foot so the foot stays planted and flat.
local function solve(leg, hipW, footY, footZ, parentPitch)
	local dy, dz = footY - hipW.Y, footZ - hipW.Z
	local d = clamp(sqrt(dy * dy + dz * dz), abs(leg.l1 - leg.l2) + 0.01, leg.l1 + leg.l2 - 0.01)
	local base = atan2(-dz, -dy)
	local cA = clamp((leg.l1 * leg.l1 + d * d - leg.l2 * leg.l2) / (2 * leg.l1 * d), -1, 1)
	local th = base + leg.bend * acos(cA)
	local ky, kz = hipW.Y - leg.l1 * cos(th), hipW.Z - leg.l1 * sin(th)
	local sh = atan2(-(footZ - kz), -(footY - ky))
	local d1 = th - leg.a1
	local d2 = sh - leg.a2
	return deg(d1) - parentPitch, deg(d2 - d1), -deg(d2)
end

-- Sideways (roll) correction so planted feet don't slide when the body sways.
-- Returns the local Z angle (deg) for the upper leg bone (all bone frames are
-- axis-aligned, so this is the same sense on both sides). s = 1 right, -1 left.
local function sideways(leg, hipW, s, roll)
	local h = leg.hip.Y - leg.foot.Y
	local want = deg(atan2(leg.foot.X * s - hipW.X, hipW.Y - leg.foot.Y))
	local restA = deg(atan2((leg.foot.X - leg.hip.X) * s, h))
	return want - restA - roll
end

---------------------------------------------------------------------------
-- keyframes (seconds inside the 9 s loop)
---------------------------------------------------------------------------
local LIFT = {
	{ 0, 0 }, { 2.85, 0 }, { 3.45, -1.9, "cubicOut" }, { 3.6, -2.0 },
	{ 4.0, 4.6, "backOut" }, { 5.95, 4.4 }, { 6.25, 5.0 }, { 6.72, -1.0, "quadIn" },
	{ 6.82, -1.8, "quadOut" }, { 7.2, 0.45, "quadOut" }, { 7.55, 0, "quadInOut" }, { 9, 0 },
}
local PITCH = {
	{ 0, 0 }, { 2.85, 0 }, { 3.45, -8, "cubicOut" }, { 3.6, -9 }, { 3.95, 14, "backOut" },
	{ 4.6, 8 }, { 5.35, 4 }, { 5.55, 6, "backOut" }, { 6.1, 5 }, { 6.72, -8, "quadIn" },
	{ 6.85, -12, "quadOut" }, { 7.6, 0, "elasticOut" }, { 9, 0 },
}
local CHESTP = {
	{ 0, 0 }, { 2.85, 0 }, { 3.45, -6 }, { 3.6, -6 }, { 3.95, 8, "backOut" }, { 4.6, 4 },
	{ 5.35, -4 }, { 5.55, 8, "backOut" }, { 6.1, 6 }, { 6.55, 0 }, { 6.85, -9, "quadOut" },
	{ 7.7, 0, "elasticOut" }, { 9, 0 },
}
local HEADP = {
	{ 0, 0 }, { 2.85, 0 }, { 3.45, -14, "cubicOut" }, { 3.6, -16 }, { 3.95, 20, "backOut" },
	{ 4.4, -4 }, { 5.3, -6 }, { 5.4, -12, "quadOut" }, { 5.55, 10, "backOut" }, { 6.1, 8 },
	{ 6.45, 0 }, { 6.7, -6 }, { 6.88, -24, "quadOut" }, { 7.7, 0, "elasticOut" }, { 9, 0 },
}
-- snappy bird head turns (yaw) and curious tilts (roll)
local HEADY = {
	{ 0, 0 }, { 0.45, 0 }, { 0.55, 32, "backOut" }, { 1.15, 32 }, { 1.25, -22, "backOut" },
	{ 1.8, -22 }, { 1.9, 10, "backOut" }, { 2.5, 10 }, { 2.62, 0, "backOut" },
	{ 4.4, 0 }, { 4.55, 18, "backOut" }, { 5.0, 18 }, { 5.15, -10, "backOut" }, { 5.4, 0 },
	{ 7.7, 0 }, { 7.8, -28, "backOut" }, { 8.3, -28 }, { 8.4, 18, "backOut" }, { 8.85, 18 },
	{ 8.97, 0, "quadOut" }, { 9, 0 },
}
local HEADR = {
	{ 0, 0 }, { 0.45, 0 }, { 0.55, -16, "backOut" }, { 1.15, -16 }, { 1.25, 20, "backOut" },
	{ 1.8, 20 }, { 1.9, 0, "backOut" }, { 7.7, 0 }, { 7.8, 18, "backOut" }, { 8.3, 18 },
	{ 8.4, -12, "backOut" }, { 8.85, -12 }, { 8.97, 0, "quadOut" }, { 9, 0 },
}
local SPREAD = { { 0, 0 }, { 2.85, 0 }, { 3.3, 1, "cubicOut" }, { 6.85, 1 }, { 7.65, 0, "cubicInOut" }, { 9, 0 } }
local FLAP = {
	{ 0, 0 }, { 2.85, 0 }, { 3.35, 80, "cubicOut" }, { 3.6, 85 },
	{ 3.82, -55, "quadOut" }, -- launch downbeat
	{ 4.08, 78, "sineInOut" }, { 4.3, -35, "quadOut" }, -- flap 1
	{ 4.66, 12, "sineInOut" }, -- glide: wings spread wide
	{ 4.86, 78, "sineInOut" }, { 5.05, -55, "quadOut" }, -- flap 2
	{ 5.25, 78, "sineInOut" }, { 5.42, -50, "quadOut" }, -- flap 3
	{ 5.62, 42, "backOut" }, { 6.1, 38 }, -- hero V during the screech
	{ 6.4, 72, "sineInOut" }, { 6.75, 8, "quadIn" }, -- parachute, slam down on landing
	{ 7.0, 35, "backOut" }, { 7.65, 0, "cubicInOut" }, { 9, 0 },
}
local TAILLIFT = {
	{ 0, 0 }, { 2.85, 0 }, { 3.45, -12, "cubicOut" }, { 3.6, -12 }, { 4.0, 10, "backOut" },
	{ 6.2, 8 }, { 6.75, -14, "quadIn" }, { 7.7, 0, "elasticOut" }, { 9, 0 },
}

-- twist about the wing's own span axis (+ = trailing edge down, shows the
-- broad feather surface to the front)
local TWIST = {
	{ 0, 0 }, { 2.85, 0 }, { 3.6, 0 }, { 3.85, 18 }, { 5.35, 18 }, { 5.6, 48, "backOut" }, { 6.1, 44 },
	{ 6.4, 25 }, { 7.0, 15 }, { 7.65, 0 }, { 9, 0 },
}

-- bank (body roll) so the spread wings show their tops while gliding
local BANK = { { 0, 0 }, { 4.25, 0 }, { 4.55, -16, "sineInOut" }, { 4.85, -4, "sineInOut" }, { 5.2, 6 }, { 5.5, 0 }, { 9, 0 } }

local WING_FOLD = ang(-26, 0, 0)
local WING_SPREAD = ang(0, -6, 0) * ang(-90, 90, 0)

function M.Update(t, pose, ctx)
	local c = t % M.Cycle
	local tr = L.track

	local idleW = 1 - L.env(c, 2.6, 0.3, 4.75, 0.6)
	local fly = L.env(c, 3.75, 0.25, 2.3, 0.4)
	local screech = L.env(c, 5.4, 0.14, 0.62, 0.3, "backOut", "cubicIn")
	local shake = L.env(c, 5.55, 0.1, 0.5, 0.25)
	local ruffle = L.env(c, 0.85, 0.12, 0.35, 0.25) + L.env(c, 7.95, 0.12, 0.3, 0.25)
	local breathe = wave(t, 4 / 9)

	-- wings: spread amount, flap angle (+ up), flap speed for follow-through
	local k = tr(c, SPREAD)
	local f = tr(c, FLAP)
	local df = f - tr((c - 0.07) % M.Cycle, FLAP)

	---------------------------------------------------------------- BODY
	local lift = tr(c, LIFT)
	local hoverBob = -0.009 * tr((c - 0.08) % M.Cycle, FLAP) * fly
	local bob = -0.45 * L.bounce(t, 1) * idleW
	local by = lift + hoverBob + bob
	local bp = tr(c, PITCH) + 1.5 * breathe * idleW
	local br = 3 * wave(t, 5 / 9) * idleW + 4 * wave(t, 6 / 9) * fly + tr(c, BANK)
	local bodyT = pa(0, by, 0, bp, 3 * wave(t, 5 / 9, 0.25) * idleW, br)
	pose.Body = bodyT

	local cp = tr(c, CHESTP) + 2 * breathe
	local chestT = ang(cp, 0, 0)
	pose.Chest = chestT

	---------------------------------------------------------------- HEAD
	local hp = tr(c, HEADP) - 4 * L.bounce(t, 1, 0.15) * idleW
	local hy = tr(c, HEADY) + 12 * shake * wave(t, 6)
	local hr = tr(c, HEADR) + 6 * shake * wave(t, 4.5)
	pose.Neck = ang(0.4 * hp - 12 * screech, 0.35 * hy, 0.3 * hr)
	pose.Head = ang(0.7 * hp + 18 * screech, 0.65 * hy, 0.7 * hr)
	local chomp = max(0, wave(t, 4 / 9, 0.3)) ^ 10 * idleW
	pose.Jaw = ang(-4 - 22 * chomp - 66 * screech + 5 * shake * wave(t, 11), 0, 0)
	pose.Crest = ang(-5 * breathe - 28 * screech + 12 * fly * wave(t, 2.5) + 0.25 * tr(c, HEADP), 0, 0)
	local blink = L.env(t % 3, 2.2, 0.06, 0.06, 0.1)
	L.both(pose, "Lid", CFrame.new(0, -1.7 * blink, 0))

	---------------------------------------------------------------- WINGS
	local flare = (5 + 16 * ruffle * (0.6 + 0.4 * wave(t, 9)) + 2 * breathe) * (1 - k)
	local kk = k + (1 - k) * 0.14 * ruffle -- wings half-lift during the feather shake
	local base = WING_FOLD:Lerp(WING_SPREAD, kk)
	local wingR = ang(0, 0, f * k) * base * ang(0, 0, flare + tr(c, TWIST) * k)
	L.both(pose, "Wing", wingR)
	local lag = clamp(df, -40, 40) * k
	local flutter = 6 * screech * wave(t, 7)
	L.both(pose, "WingMid", ang(0, 0.45 * lag + 10 * ruffle * L.wave01(t, 7) + flutter, 0))
	L.both(pose, "WingTip", ang(0, 0.9 * lag + 14 * ruffle * L.wave01(t, 7, 0.2) - 10 * screech + flutter, 0))

	---------------------------------------------------------------- LEGS
	local air = L.smoothstep(L.remap(lift, 0.3, 2.0))
	local bodyW = CFrame.new(BODY) * bodyT
	local chestW = bodyW * CFrame.new(CHEST - BODY) * chestT
	local tap = L.env(c, 1.5, 0.12, 0.05, 0.12, "quadOut", "quadIn") + L.env(c, 1.85, 0.12, 0.05, 0.12, "quadOut", "quadIn")
	for _, s in { 1, -1 } do
		local side = s == 1 and "R" or "L"
		-- hind (lion)
		local a1, a2, a3 = solve(HIND, bodyW * (Vector3.new(HIND.hip.X * s, HIND.hip.Y, HIND.hip.Z) - BODY), HIND.foot.Y, HIND.foot.Z, bp)
		local swing = 8 * wave(t, 2.2, s == 1 and 0 or 0.5) * fly
		a1 = L.lerp(a1, -35 + swing, air)
		a2 = L.lerp(a2, 20, air)
		a3 = L.lerp(a3, -35, air)
		local hz = sideways(HIND, bodyW * (Vector3.new(HIND.hip.X * s, HIND.hip.Y, HIND.hip.Z) - BODY), s, br) * (1 - air)
		pose["Thigh" .. side] = ang(a1, 0, hz)
		pose["Shin" .. side] = ang(a2, 0, 0)
		pose["Paw" .. side] = ang(a3, 0, -(br + hz))
		-- front (eagle): talon tap on the right foot during idle
		local fy = FRONT.foot.Y + (s == 1 and 1.3 * tap or 0)
		local b1, b2, b3 = solve(FRONT, chestW * (Vector3.new(FRONT.hip.X * s, FRONT.hip.Y, FRONT.hip.Z) - CHEST), fy, FRONT.foot.Z, bp + cp)
		local reach = 12 * screech
		b1 = L.lerp(b1, 25 + reach - swing, air)
		b2 = L.lerp(b2, -55 + 30 * screech, air)
		b3 = L.lerp(b3, 35 - 40 * screech, air)
		local fz = sideways(FRONT, chestW * (Vector3.new(FRONT.hip.X * s, FRONT.hip.Y, FRONT.hip.Z) - CHEST), s, br) * (1 - air)
		pose["Arm" .. side] = ang(b1, 0, fz - 6 * screech * s)
		pose["Fore" .. side] = ang(b2, 0, 0)
		pose["Foot" .. side] = ang(b3, 0, -(br + fz))
	end

	---------------------------------------------------------------- TAIL
	local tl = tr(c, TAILLIFT) - 3 * breathe
	for i = 1, 4 do
		local yaw = (1 - fly) * 14 * (0.6 + 0.2 * i) * wave(t, 2 / 3, -0.12 * i) + fly * 20 * (0.6 + 0.2 * i) * wave(t, 4 / 3, -0.15 * i)
		pose["Tail" .. i] = ang(tl + 4 * fly * wave(t, 4 / 3, -0.15 * i), yaw, 0)
	end
	pose.Flame = ang(8 * wave(t, 2), 14 * wave(t, 2 / 3, -0.6), 10 * wave(t, 4 / 3))

	---------------------------------------------------------------- CUBES
	-- cubes drop below the wings while it flies, then get flung out by the screech
	pose.Orbit = pa(0, -2.5 * fly + 2.5 * screech, 0, 0, 40 * t, 0)
	for i = 1, 4 do
		local out = 3.5 * screech
		local dir = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(out * dir * 0.6, 0.8 * wave(t, 2 / 3, i * 0.25) + out * 0.4, 0, 80 * t * dir, 120 * t, 45)
	end

	---------------------------------------------------------------- FX
	ctx.enable("ScreechSparks", c > 5.45 and c < 6.15)
	ctx.light("ScreechLight", 1.5 * screech)
	if ctx.crossed(3.62) then ctx.emit("GroundDust", 30) end
	if ctx.crossed(3.84) then ctx.emit("FeatherBurst", 10) end
	-- downbeat gusts kick up a little dust under the hovering griffin
	if ctx.crossed(4.3) or ctx.crossed(5.05) or ctx.crossed(5.42) then ctx.emit("GroundDust", 10) end
	if ctx.crossed(5.45) then
		ctx.emit("SolarBurst", 60)
		ctx.emit("FeatherBurst", 18)
	end
	if ctx.crossed(6.68) then ctx.emit("GroundDust", 35) end
end

return M
