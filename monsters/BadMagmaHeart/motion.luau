--!nocheck
-- Magma Heart Tree: the Bramble Badlands showpiece, seamless 10 s loop.
-- Idle (always visible):
-- * the MAGMA HEART beats "lub-dub" (7 beats in the loop): its three lobes
--   pump outward around the glowing core, the core + lobe cracks flare, the
--   claws flex open a little, the heart light throbs and a few sparks pop
-- * each beat sends a glow down the trunk's magma veins (top -> bottom)
-- * the four lava rivers flow: a ripple of hot bands runs down every
--   cascade (10 waves per loop) and the pools pulse
-- * the canopy sways +-2 deg with lag and breathes; six magma-heart fruits
--   swing on their stems and glow with the beat; ash flakes fall
-- Signature ERUPTION (peak 6.0 s):
-- * 4.4-6.0 s build-up: the heartbeat races (beats closer and closer), the
--   whole tree trembles harder and harder, magma climbs the veins level by
--   level, the crater light swells, the canopy and fruits draw in
-- * 6.0 s BOOM: the heart leaps up (backOut) with a giant pump, the claws
--   fling open, the canopy puffs, the crater ERUPTS - fire jets for ~1.3 s,
--   90 arcing lava sparks + a smoke puff, five LAVA BOMBS fly out on fiery
--   trails and splash down on the slopes, the rivers surge white-hot, the
--   fruits kick outward and every light flashes
-- * settles back by ~9.4 s (bombs sink and return through the rock unseen)
-- Whole wave cycles per loop and envelopes 0 at both ends: t=0 == t=10.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, cos, exp, clamp, rad, abs = math.sin, math.cos, math.exp, math.clamp, math.rad, math.abs

local M = {}
M.Cycle = 10

local TAU = math.pi * 2
local ERUPT = 6.0

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end
-- wrap-safe time relative to a beat
local function rel(c, s)
	return ((c - s + M.Cycle / 2) % M.Cycle) - M.Cycle / 2
end
-- one "lub-dub" heartbeat shape (dt = time since the beat)
local function lub(dt)
	if dt < -0.3 or dt > 0.7 then
		return 0
	end
	return exp(-(dt / 0.07) ^ 2) + 0.6 * exp(-((dt - 0.24) / 0.08) ^ 2)
end
local function smooth(x)
	x = clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end

-- idle beats + the racing build-up (the eruption beat itself is separate)
local BEATS = { 0.5, 1.7, 2.9, 4.0, 4.75, 5.3, 5.7 }

-- bombs: angle (matches build.luau), landing radius, landing y (bomb centre), arc height
local BOMBS = {
	{ 18, 8.0, 5.35, 9.0 },
	{ 90, 9.8, 3.55, 10.0 },
	{ 162, 8.0, 5.35, 8.5 },
	{ 234, 9.8, 3.55, 9.5 },
	{ 306, 8.0, 5.35, 10.5 },
}
local BOMB_R0, BOMB_Y0 = 3.2, 8.0 - 1.1
local LAND_ANG = { 38, 125, 205, 305, 160 }

-- fruit: deg (matches build.luau), swing cycles, phase
local FRUITS = {
	{ 30, 2, 0.00 },
	{ 90, 3, 0.31 },
	{ 150, 2, 0.58 },
	{ 210, 3, 0.12 },
	{ 270, 2, 0.83 },
	{ 330, 3, 0.47 },
}

local function polar(r, d)
	local a = rad(d)
	return sin(a) * r, -cos(a) * r
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	-- heartbeat --------------------------------------------------------
	local hb = 0
	for _, b in BEATS do
		hb += lub(rel(c, b))
		if ctx.crossed(b) then
			ctx.emit("HeartBurst", 8)
		end
	end
	hb = clamp(hb, 0, 1.2)

	-- eruption envelopes (0 outside ~4.4..9.6 s)
	local gather = L.track(c, { { 4.4, 0 }, { 5.95, 1, "quadIn" }, { 6.05, 0, "cubicOut" } })
	local pump = L.track(c, { { 5.9, 0 }, { 6.05, 1, "quadOut" }, { 6.5, 0.7, "sineInOut" }, { 7.8, 0, "sineInOut" } })
	local jump = L.track(c, { { 5.95, 0 }, { 6.35, 1, "backOut" }, { 7.0, 0.7, "sineInOut" }, { 8.8, 0, "sineInOut" } })
	local flash = L.track(c, { { 5.95, 0 }, { 6.08, 1, "quadOut" }, { 6.8, 0.75 }, { 9.0, 0, "sineInOut" } })
	local surge = L.track(c, { { 5.95, 0 }, { 6.2, 1, "quadOut" }, { 7.4, 0.8 }, { 9.4, 0, "sineInOut" } })
	local puff = L.track(c, { { 6.0, 0 }, { 6.4, 1, "backOut" }, { 7.1, 0.6, "sineInOut" }, { 9.0, 0, "sineInOut" } })
	local clawOpen = L.track(c, { { 5.95, 0 }, { 6.25, 1, "backOut" }, { 7.2, 0.6, "sineInOut" }, { 9.2, 0, "sineInOut" } })
	local dt = c - ERUPT
	local kick = 0
	if dt > 0 then
		kick = exp(-1.3 * dt) * sin(6 * dt)
	end
	-- trembling during the build-up (whole cycles per loop -> seamless)
	local shake = gather * gather
	local sh1 = shake * w(t, 47, 0.1)
	local sh2 = shake * w(t, 53, 0.4)

	-- trunk + canopy ----------------------------------------------------
	pose.Crop = ang(0.5 * w(t, 1, 0.6) + 0.7 * sh1 - 0.8 * kick, 0, 0.6 * w(t, 1, 0.85) + 0.7 * sh2)
	pose.Canopy = pa(0.06 * sh2, 0.15 * w(t, 2, 0.1) - 0.3 * gather + 0.6 * puff, 0.06 * sh1,
		2.0 * w(t, 1, 0.0) + 1.4 * sh1 + 1.5 * kick, 0.8 * w(t, 1, 0.35), 2.2 * w(t, 1, 0.25) + 1.4 * sh2)
	pose.CanopyTop = pa(0, 0.08 * w(t, 2, 0.35) - 0.15 * gather + 0.4 * puff, 0,
		1.1 * w(t, 1, 0.12) + 1.0 * sh2 - 1.0 * kick, 0, 1.2 * w(t, 1, 0.4) + 1.0 * sh1)

	-- the heart ---------------------------------------------------------
	pose.Heart = pa(0.12 * sh1, 0.2 * hb + 1.6 * jump - 0.3 * gather, 0.12 * sh2,
		2.5 * w(t, 1, 0.2) + 3 * sh2, 6 * w(t, 1, 0.55), 2.5 * w(t, 1, 0.7) + 3 * sh1)
	local P = 0.22 * hb + 0.85 * pump
	pose.HeartL = pa(-P, 0.4 * P, 0, 0, 0, 10 * P)
	pose.HeartR = pa(P, 0.4 * P, 0, 0, 0, -10 * P)
	pose.HeartB = pa(0, -0.8 * P, 0, 0, 0, 0)
	local coreT = clamp(0.4 * (1 - clamp(hb, 0, 1)) * (1 - pump) - 0.1 * gather, 0, 0.6)
	ctx.transparency("HeartCore", coreT)
	ctx.transparency("HeartCoreB", coreT)
	for _, n in { "LobeCrackL1", "LobeCrackL2", "LobeCrackR1", "LobeCrackR2" } do
		ctx.transparency(n, clamp(0.5 * (1 - clamp(hb, 0, 1)) * (1 - pump), 0, 0.6))
	end

	-- claws flex open on every beat, fling open on the eruption
	for i = 1, 5 do
		local a = rad((i - 1) * 72 + 36)
		local ox, oz = sin(a), -cos(a)
		local th = 3 * hb + 22 * clawOpen - 4 * gather + 1.5 * w(t, 2, i * 0.2)
		pose["Claw" .. i] = CFrame.fromAxisAngle(Vector3.new(oz, 0, -ox), rad(th))
		ctx.transparency("ClawVein" .. i, clamp(0.5 - 0.4 * hb - 0.5 * flash, 0, 0.7))
	end

	-- magma veins: each beat runs down the trunk; the build-up climbs it
	for lv = 1, 6 do
		local down = 0
		for _, b in BEATS do
			down += lub(rel(c, b + (6 - lv) * 0.05))
		end
		local climb = smooth((c - (4.5 + lv * 0.22)) / 0.25) * (1 - smooth((c - 7.6) / 1.2))
		local tr = clamp(0.6 - 0.45 * down - 0.6 * climb - 0.6 * flash, 0, 0.7)
		for s = 1, 4 do
			ctx.transparency(("Vein%d_%d"):format(lv, s), tr)
		end
	end
	for k = 0, 5 do
		ctx.transparency("RootVein" .. k, clamp(0.45 - 0.3 * hb - 0.5 * flash - 0.3 * gather, 0, 0.7))
	end
	for vi = 1, 2 do
		for _, k in { 2, 6, 10 } do
			ctx.transparency(("Berry%d_%d"):format(vi, k), clamp(0.3 + 0.25 * w(t, 3, vi * 0.3 + k * 0.07) - 0.3 * flash - 0.3 * hb, 0, 0.7))
		end
	end
	for n = 1, 4 do
		ctx.transparency("Ember" .. n, clamp(0.35 + 0.2 * w(t, 2, n * 0.27) - 0.35 * flash, 0, 0.7))
	end

	-- lava rivers: bands of heat flowing down, surge on the eruption
	for r = 1, 4 do
		for k = 1, 9 do
			local band = 0.5 + 0.5 * sin(TAU * (10 * t / M.Cycle - k * 0.17 + r * 0.25))
			ctx.transparency(("Flow%d_%d"):format(r, k), clamp((0.08 + 0.5 * band) * (1 - surge), 0, 0.7))
		end
		ctx.transparency("Pool" .. r, clamp((0.25 + 0.2 * w(t, 4, r * 0.25)) * (1 - surge), 0, 0.6))
	end

	-- hanging magma-heart fruits ----------------------------------------
	for i, f in FRUITS do
		local a = rad(f[1])
		local ox, oz = sin(a), -cos(a)
		local sw = w(t, f[2], f[3])
		local sw2 = w(t, f[2], f[3] + 0.25)
		local K = 14 * kick - 6 * gather
		pose["Fruit" .. i] = ang(10 * sw - K * oz + 2 * sh1, 4 * w(t, 1, f[3] + 0.4), 9 * sw2 + K * ox + 2 * sh2)
		local fb = 0
		for _, b in BEATS do
			fb += lub(rel(c, b + 0.08 + i * 0.02))
		end
		local tr = clamp(0.45 * (1 - clamp(fb, 0, 1)) * (1 - flash), 0, 0.6)
		ctx.transparency("FruitCore" .. i, tr)
		ctx.transparency("FruitCore" .. i .. "B", tr)
	end

	-- lava bombs ---------------------------------------------------------
	for i, b in BOMBS do
		local la = LAND_ANG[i]
		local x0, z0 = polar(BOMB_R0, b[1])
		local x1, z1 = polar(b[2], la)
		local T0 = ERUPT + 0.05 * (i - 1)
		local dur = 0.95 + 0.08 * i
		local u = (c - T0) / dur
		local off = Vector3.new(0, 0, 0)
		local vis = 1
		if u > 0 and u <= 1 then
			-- ballistic arc out of the crater
			local h = b[4] * 4 * u * (1 - u)
			off = Vector3.new((x1 - x0) * u, (b[3] - BOMB_Y0) * u + h, (z1 - z0) * u)
			vis = 0
		elseif u > 1 then
			local s = c - (T0 + dur) -- seconds since splashdown
			local land = Vector3.new(x1 - x0, b[3] - BOMB_Y0, z1 - z0)
			if s < 0.45 then
				-- sink into the rock
				off = land + Vector3.new(0, -2.0 * smooth(s / 0.45), 0)
				vis = smooth((s - 0.15) / 0.3)
			else
				-- travel back through the volcano, unseen
				local k = smooth((s - 0.45) / 1.6)
				off = (land + Vector3.new(0, -2.0, 0)) * (1 - k)
				vis = 1
			end
		end
		pose["Bomb" .. i] = CFrame.new(off) * ang(0, (u > 0 and u <= 1) and 540 * u or 0, (u > 0 and u <= 1) and 360 * u or 0)
		ctx.transparency("Bomb" .. i, vis)
		ctx.transparency("Bomb" .. i .. "N", vis)
	end

	-- lights ------------------------------------------------------------
	ctx.light("HeartLight", clamp(1.1 + 0.6 * hb + 0.2 * gather + 0.9 * flash, 0, 2))
	ctx.light("CraterLight", clamp(0.9 + 0.15 * w(t, 3, 0.1) + 0.6 * gather + 1.0 * flash, 0, 2))
	ctx.light("LavaLight", clamp(0.8 + 0.15 * w(t, 4, 0.3) + 0.9 * surge, 0, 2))

	-- the eruption -------------------------------------------------------
	ctx.enable("CraterFire", c > 5.95 and c < 7.3)
	if ctx.crossed(ERUPT) then
		ctx.emit("EruptBurst", 90)
		ctx.emit("HeartBurst", 60)
		ctx.emit("CraterSmoke", 10)
	end
	if ctx.crossed(ERUPT + 0.35) then
		ctx.emit("EruptBurst", 40)
	end
end

return M
