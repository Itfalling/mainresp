--!nocheck
-- Magma Bone Colossus: the Magma showpiece, seamless 10 s loop.
-- Idle (always moving):
-- * LAVA FLOWS: the hot bands inside the hollow spine climb 3 band spacings
--   per loop (Flow1..4 slide up), the two lavafalls pour down 4 spacings per
--   loop (FallR/L slide down), glow pulses chase out along every rib and arm
--   channel toward the skulls, roots suck lava up from the pool, the front
--   spill runs down the mound, the pool hot spots pulse
-- * the MOLTEN HEART beats "lub-dub" and each beat pushes a glow wave up the
--   spine windows (bottom -> top)
-- * the spine and ribs BREATHE (2 breaths per loop, lagging up the spine);
--   the arms rise and fall; the skull-fruits sway on their claws and CHATTER
--   their jaws; the King skull bobs and looks around; the crown claws flex
-- * four ember shards orbit the ribcage on fiery trails
-- Signature ROAR (heart surge 6.6 s, roar 6.85 s):
-- * 4.8-6.55 build-up: the heartbeat races, the whole colossus trembles
--   harder and harder, the ribs draw in, the arms sink, the skulls bow and
--   clench, the channels dim, the shards are pulled in
-- * 6.6 s HEART SURGE: the heart pumps huge, a white-hot wave races up the
--   spine (the lava column surges one extra band), every channel flares,
--   ember burst + light flash
-- * 6.85 s ROAR: all three skulls throw their heads up, jaws gape, FIRE
--   bursts from their mouths; the arms fling up, the crown claws open, the
--   ribs flare out, the shards are flung outward and race an extra lap
-- * settles by ~9.4 s.
-- Seamless: whole wave cycles per loop, envelopes 0 at both ends, flows move
-- whole band spacings per loop, shards whole laps.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, cos, exp, clamp, rad = math.sin, math.cos, math.exp, math.clamp, math.rad

local M = {}
M.Cycle = 10

local TAU = math.pi * 2
local SURGE = 6.6
local ROAR = 6.85
local BS = 2.0 -- spine band spacing (build.luau)
local FS = 1.5 -- lavafall band spacing (build.luau)

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end
local function rel(c, s)
	return ((c - s + M.Cycle / 2) % M.Cycle) - M.Cycle / 2
end
local function lub(dt)
	if dt < -0.3 or dt > 0.7 then
		return 0
	end
	return exp(-(dt / 0.07) ^ 2) + 0.6 * exp(-((dt - 0.22) / 0.08) ^ 2)
end
local function smooth(x)
	x = clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end
local function polar(r, d)
	local a = rad(d)
	return sin(a) * r, -cos(a) * r
end

local BEATS = { 0.4, 1.6, 2.8, 4.0, 4.95, 5.55, 6.0, 6.35 }
local NV = 9
local SHARDS = { { 20, 14 }, { 110, -10 }, { 200, 12 }, { 290, -16 } } -- deg, orbit tilt

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- envelopes ----------------------------------------------------------
	local hb = 0
	for _, b in BEATS do
		hb += lub(rel(c, b))
		if ctx.crossed(b) then
			ctx.emit("HeartBurst", 6)
		end
	end
	hb = clamp(hb, 0, 1.2)
	local gather = L.track(c, { { 4.8, 0 }, { 6.5, 1, "quadIn" }, { 6.65, 0, "cubicOut" } })
	local pump = L.track(c, { { 6.5, 0 }, { 6.65, 1, "quadOut" }, { 7.1, 0.7, "sineInOut" }, { 8.4, 0, "sineInOut" } })
	local roar = L.track(c, { { 6.7, 0 }, { 7.0, 1, "backOut" }, { 7.9, 0.85, "sineInOut" }, { 8.9, 0, "sineInOut" } })
	local flash = L.track(c, { { 6.55, 0 }, { 6.7, 1, "quadOut" }, { 7.4, 0.8 }, { 9.3, 0, "sineInOut" } })
	local flare = L.track(c, { { 6.55, 0 }, { 6.9, 1, "quadOut" }, { 8.0, 0.8 }, { 9.5, 0, "sineInOut" } })
	local shake = gather * gather
	local sh1 = shake * w(t, 47, 0.1)
	local sh2 = shake * w(t, 53, 0.4)
	local dt = c - ROAR
	local kick = dt > 0 and exp(-1.4 * dt) * sin(7 * dt) or 0
	local breath = w(t, 2, 0.0) -- two breaths per loop

	-- whole colossus -----------------------------------------------------
	pose.Crop = ang(0.3 * w(t, 1, 0.2) + 0.4 * sh1, 0, 0.3 * w(t, 1, 0.45) + 0.4 * sh2)
	for s = 1, 4 do
		local lag = s * 0.06
		local back = (s >= 3) and (4 * roar - 2.5 * gather + 2 * kick) or (1.5 * roar - gather)
		pose["Spine" .. s] = pa(0, 0.05 * w(t, 2, -lag) * s, 0,
			0.9 * w(t, 1, 0.1 - lag) + back * 0.5 + 0.6 * sh1, 1.5 * w(t, 1, 0.3 - lag), 0.9 * w(t, 1, 0.35 - lag) + 0.6 * sh2)
	end

	-- the flowing lava: whole spacings per loop (+1 extra on the surge)
	local extra = smooth((c - SURGE) / 0.9)
	local up = (BS * (3 * c / M.Cycle + extra)) % BS
	for s = 1, 4 do
		pose["Flow" .. s] = CFrame.new(0, up, 0)
	end
	local down = (FS * (4 * c / M.Cycle + extra)) % FS
	pose.FallR = CFrame.new(0, -down, 0)
	pose.FallL = CFrame.new(0, -down, 0)

	-- ribs breathe; draw in on the build-up, flare on the roar
	local rb = 3 * breath - 6 * gather + 9 * roar + 3 * kick
	for lv = 0, 3 do
		local k = 1 - 0.12 * lv
		L.both(pose, "Rib" .. lv, ang(0, -rb * k, 1.5 * rb * k + 0.4 * sh1))
	end

	-- the heart --------------------------------------------------------------
	pose.Heart = pa(0.08 * sh1, 0.15 * hb + 0.5 * pump - 0.2 * gather, -0.4 * pump, 3 * w(t, 1, 0.2) + 2 * sh2, 5 * w(t, 1, 0.55), 2 * w(t, 1, 0.7))
	local P = 0.24 * hb + 0.9 * pump
	pose.HeartL = pa(-P, 0.4 * P, 0, 0, 0, 10 * P)
	pose.HeartR = pa(P, 0.4 * P, 0, 0, 0, -10 * P)
	pose.HeartB = pa(0, -0.8 * P, 0, 0, 0, 0)

	-- arms, skull-fruits, jaws -------------------------------------------------
	local armUp = 3 * w(t, 1, 0.15) - 7 * gather + 16 * roar + 4 * kick
	L.both(pose, "Arm", ang(0, 1.5 * w(t, 1, 0.4), armUp + 0.6 * sh1))
	L.both(pose, "Fore", ang(0, 0, 2.5 * w(t, 1, 0.05) - 4 * gather + 8 * roar))
	local chatter = 0
	for _, ch in { { 1.2, 0.7 }, { 3.3, 0.6 }, { 9.0, 0.5 } } do
		local e = smooth((c - ch[1]) / 0.12) * (1 - smooth((c - ch[1] - ch[2]) / 0.12))
		chatter += e * (0.5 + 0.5 * sin(TAU * 7 * (c - ch[1])))
	end
	for i, sd in { "R", "L" } do
		local sx = (sd == "R") and 1 or -1
		local swX = 7 * w(t, 2, i * 0.3) - 10 * kick
		local swZ = 6 * w(t, 1, i * 0.4 + 0.1)
		pose["Skull" .. sd] = ang(swX + 14 * roar - 12 * gather + 2 * sh1, 3 * w(t, 1, i * 0.2), sx * swZ - 2 * sh2)
		pose["Jaw" .. sd] = ang(-(16 * chatter + 48 * roar) * (1 - 0.6 * gather) + 2 * gather, 0, 0)
	end
	pose.King = pa(0, 0.2 * w(t, 2, 0.2) - 0.3 * gather + 0.4 * roar, 0,
		3 * w(t, 1, 0.6) - 8 * gather + 18 * roar + 1.5 * sh1, 7 * w(t, 1, 0.3), 2.5 * w(t, 1, 0.85) + 1.5 * sh2)
	local kchat = smooth((c - 2.2) / 0.12) * (1 - smooth((c - 2.9) / 0.12)) * (0.5 + 0.5 * sin(TAU * 6 * (c - 2.2)))
	pose.KingJaw = ang(-(14 * kchat + 50 * roar), 0, 0)
	for i = 1, 5 do
		local a = rad((i - 1) * 72 + 36)
		local ox, oz = sin(a), -cos(a)
		local th = 3 * w(t, 2, i * 0.15) + 3 * hb - 6 * gather + 22 * roar
		pose["Finger" .. i] = CFrame.fromAxisAngle(Vector3.new(oz, 0, -ox), rad(th))
	end

	-- ember shards orbit (1 lap + 1 extra on the roar), flung out on the roar
	local lap = 360 * (c / M.Cycle + smooth((c - ROAR) / 2.2))
	local fling = 3.2 * roar - 1.5 * gather
	for i, sh in SHARDS do
		local T = CFrame.Angles(rad(sh[2]), 0, 0)
		local R = T * CFrame.Angles(0, -rad(lap), 0) * T:Inverse()
		local x, z = polar(1, sh[1])
		local dir = R * Vector3.new(x, 0, z)
		pose["Shard" .. i] = CFrame.new(dir * fling + Vector3.new(0, 0.5 * w(t, 2, i * 0.25), 0)) * R
	end

	-- glow: hot crests of magma climb the spine (2 per loop, pool -> King),
	-- heartbeats add a pulse, the surge floods everything
	local function crest(y)
		local g = 0
		for _, ph in { 0, 0.5 } do
			local u = (2 * c / M.Cycle + ph) % 1
			local yc = 3 + 33 * u
			g += exp(-((y - yc) / 3.4) ^ 2)
		end
		return clamp(g, 0, 1)
	end
	local surgeY = 4 + 40 * clamp((c - SURGE) / 0.6, 0, 1)
	local surgeOn = (c > SURGE and c < 9.3) and 1 or 0
	local function surgeAt(y)
		return surgeOn * smooth((surgeY - y) / 2) * (1 - smooth((c - 8.4) / 0.9))
	end
	for j = 1, 14 do
		local y = 3 + BS * (j - 1) + up
		local g = math.max(crest(y), surgeAt(y))
		ctx.transparency("ColBand" .. j, clamp(1 - 1.1 * g, 0, 1))
	end
	for k = 1, NV do
		local y = 6.75 + 3 * (k - 1)
		local p = 0
		for _, b in BEATS do
			p += lub(rel(c, b + 0.05 * k))
		end
		local g = math.max(crest(y), surgeAt(y), clamp(0.6 * p, 0, 1))
		local tr = clamp(0.7 - 0.7 * g + 0.2 * gather, 0, 0.8)
		ctx.transparency(("VGlow%dR"):format(k), tr)
		ctx.transparency(("VGlow%dL"):format(k), tr)
	end
	-- lavafall crests pour down (3 per loop)
	for _, sd in { "R", "L" } do
		for j = 1, 6 do
			local y = 13.45 - FS * (j - 1) - down
			local g = 0
			for _, ph in { 0, 1 / 3, 2 / 3 } do
				local u = (3 * c / M.Cycle + ph + (sd == "L" and 0.17 or 0)) % 1
				g += exp(-((y - (14.5 - 11 * u)) / 1.6) ^ 2)
			end
			g = math.max(clamp(g, 0, 1), flare)
			ctx.transparency(("FallBand%s%d"):format(sd, j), clamp(1 - 1.1 * g, 0, 1))
		end
	end
	-- chase pulses out along the ribs / arms, up the roots, down the spill
	local dim = 0.3 * gather
	for lv = 0, 3 do
		local n = (lv == 0) and 3 or 4
		for _, sd in { "R", "L" } do
			for k = 1, n do
				local band = 0.5 + 0.5 * sin(TAU * (5 * t / M.Cycle - k * 0.22 + lv * 0.17))
				ctx.transparency(("RibGlow%d%s_%d"):format(lv, sd, k), clamp((0.08 + 0.55 * band + dim) * (1 - flare), 0, 0.75))
			end
		end
	end
	for _, sd in { "R", "L" } do
		for k = 1, 4 do
			local band = 0.5 + 0.5 * sin(TAU * (5 * t / M.Cycle - k * 0.24))
			ctx.transparency(("ArmGlow%s%d"):format(sd, k), clamp((0.08 + 0.55 * band + dim) * (1 - flare), 0, 0.75))
		end
	end
	for i = 1, 6 do
		for k = 1, 2 do
			local band = 0.5 + 0.5 * sin(TAU * (4 * t / M.Cycle + k * 0.3 + i * 0.13))
			ctx.transparency(("RootGlow%d_%d"):format(i, k), clamp((0.1 + 0.5 * band) * (1 - flare), 0, 0.7))
		end
	end
	for k = 1, 7 do
		local band = 0.5 + 0.5 * sin(TAU * (6 * t / M.Cycle - k * 0.2))
		ctx.transparency("Spill_" .. k, clamp((0.08 + 0.55 * band) * (1 - flare), 0, 0.75))
		band = 0.5 + 0.5 * sin(TAU * (6 * t / M.Cycle - k * 0.2 + 0.5))
		ctx.transparency("SpillB_" .. k, clamp((0.08 + 0.55 * band) * (1 - flare), 0, 0.75))
	end
	for i = 1, 6 do
		ctx.transparency("PoolGlow" .. i, clamp((0.25 + 0.25 * w(t, 3, i * 0.17)) * (1 - flare), 0, 0.7))
	end
	for i = 1, 5 do
		ctx.transparency("FingerGlow" .. i, clamp(0.4 - 0.3 * hb - 0.45 * flare + 0.15 * w(t, 2, i * 0.2), 0, 0.75))
	end
	for i = 1, 4 do
		ctx.transparency("ShardGlow" .. i, clamp(0.25 + 0.2 * w(t, 3, i * 0.25) - 0.3 * flare, 0, 0.7))
	end
	for _, sd in { "R", "L" } do
		ctx.transparency("Splash" .. sd, clamp(0.2 + 0.2 * w(t, 4, sd == "R" and 0 or 0.5) - 0.2 * flare, 0, 0.6))
		ctx.transparency("Spout" .. sd, clamp(0.15 - 0.15 * flare + 0.1 * w(t, 4, 0.2), 0, 0.5))
	end
	-- heart, vessel, eyes, throats
	local core = clamp(0.45 * (1 - clamp(hb, 0, 1)) * (1 - pump) - 0.1 * gather, 0, 0.6)
	ctx.transparency("HeartCore", core)
	ctx.transparency("HeartInner", clamp(core - 0.2, 0, 0.5))
	ctx.transparency("Vessel", clamp(0.5 - 0.5 * hb - 0.6 * flare, 0, 0.7))
	local eyes = clamp(0.2 + 0.15 * w(t, 5, 0.1) - 0.35 * flare + 0.35 * gather, 0, 0.7)
	for _, tag in { "K", "R", "L" } do
		ctx.transparency("Eye" .. tag .. "R", eyes)
		ctx.transparency("Eye" .. tag .. "L", eyes)
		ctx.transparency("Throat" .. tag, clamp(0.7 - 0.7 * roar - 0.3 * chatter, 0, 0.75))
	end

	-- lights + effects -------------------------------------------------------
	ctx.light("HeartLight", clamp(1.0 + 0.6 * hb + 0.4 * gather + 1.0 * flash, 0, 2))
	ctx.light("KingLight", clamp(0.9 + 0.15 * w(t, 3, 0.2) + 1.1 * roar, 0, 2))
	ctx.light("PoolLight", clamp(1.0 + 0.2 * w(t, 3, 0.6) + 0.8 * flare, 0, 2))
	ctx.light("SpineLight", clamp(0.7 + 0.3 * hb + 1.0 * flare, 0, 2))
	ctx.enable("KingFire", c > ROAR + 0.05 and c < ROAR + 1.3)
	ctx.enable("FireR", c > ROAR + 0.12 and c < ROAR + 1.2)
	ctx.enable("FireL", c > ROAR + 0.18 and c < ROAR + 1.25)
	if ctx.crossed(SURGE) then
		ctx.emit("HeartBurst", 90)
		ctx.emit("PoolSmoke", 6)
	end
	if ctx.crossed(ROAR + 0.1) then
		ctx.emit("HeartBurst", 50)
	end
end

return M
