--!nocheck
-- Volcano Melon: seamless 10 s loop with THREE eruptions in turn.
-- * idle: the vine sways (VineA base, VineB top, VineC side branch), the
--   broad leaves flap, the melons bob; lava visibly FLOWS up the vine (the
--   VineGlow seam segments chase upward into the melons), melon seams and
--   lava streams pulse; the lava pool bobs and its neon ripple rings run
--   outward from the centre
-- * eruptions at 2.3 s (ground melon), 4.9 s (side melon), 7.5 s (crown
--   melon, the biggest): each melon RUMBLES for ~1.2 s (shakes harder and
--   harder, its crater + seams glow up), dips (anticipation), then ERUPTS -
--   it jolts upward, its branch recoils, a fire/lava-spatter burst + smoke
--   puff shoot out, the light flashes and two lava blobs are flung up out of
--   the crater (trails), tumble and fall back in with a small splash; every
--   eruption also sends a bright ripple across the pool
-- Waves use whole cycles per loop; every envelope is 0 at both loop ends.
local L = require(script.Parent.AnimLib)
local ang, pa = L.ang, L.pa
local sin, exp, clamp, pi = math.sin, math.exp, math.clamp, math.pi

local M = {}
M.Cycle = 10

local TAU = math.pi * 2

local function w(t, n, ph)
	return sin(TAU * (n * t / M.Cycle + (ph or 0)))
end
local function spring(dt, k, f, len)
	if dt <= 0 or dt > len then
		return 0
	end
	return exp(-k * dt) * sin(f * dt) * (1 - dt / len)
end
local function spike(dt, up, down)
	if dt < 0 or dt > up + down then
		return 0
	end
	if dt < up then
		return dt / up
	end
	return 1 - (dt - up) / down
end

-- eruption time, flight time, blob height, blob spread, branch bone, burst size
local ERUPT = {
	{ 2.3, 1.2, 4.5, 1.6, nil, 40 },
	{ 4.9, 1.3, 5.5, 2.0, "VineC", 50 },
	{ 7.5, 1.45, 7.0, 2.4, "VineB", 70 },
}
-- blob launch directions (deg) per melon
local BLOBDIR = { { 60, 230 }, { 300, 120 }, { 20, 200 } }
local RINGS = { 4, 6, 8 }

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	local rumbles, flashes, recoil = {}, {}, {}
	for i, e in ERUPT do
		local T = e[1]
		rumbles[i] = L.track(c, { { T - 1.2, 0 }, { T - 0.05, 1, "quadIn" }, { T + 0.12, 0, "cubicOut" } })
		flashes[i] = L.track(c, { { T - 0.05, 0 }, { T + 0.08, 1, "quadOut" }, { T + 0.6, 0.7 }, { T + 1.8, 0, "sineInOut" } })
		recoil[i] = spring(c - T, 3.0, 10, 2.2)
	end

	-- vine sway + recoils
	pose.VineA = ang(1.2 * w(t, 1, 0.6) + 0.6 * recoil[3], 0.6 * w(t, 1, 0.1), 1.5 * w(t, 1, 0.85) + 0.5 * recoil[2])
	pose.VineB = ang(2.4 * w(t, 1, 0.7) - 3.5 * recoil[3] + 0.8 * rumbles[3] * sin(TAU * 9 * c), 1.2 * w(t, 1, 0.3), 2.8 * w(t, 1, 0.95))
	pose.VineC = ang(2.0 * w(t, 1, 0.2) + 1.0 * rumbles[2] * sin(TAU * 9 * c), 1.5 * w(t, 2, 0.4), 3.2 * w(t, 1, 0.45) - 5 * recoil[2])

	-- leaves
	for li = 1, 9 do
		local ph = li * 0.113
		local amp = (li >= 8) and 2.5 or 6
		pose["Leaf" .. li] = ang(amp * w(t, 2, ph) + 4 * (recoil[2] + recoil[3]) * ((li % 2 == 0) and 1 or -1), 2 * w(t, 1, ph + 0.3), amp * 0.7 * w(t, 2, ph + 0.25))
	end

	-- melons: idle bob, rumble shake, anticipation dip, eruption jolt
	for i, e in ERUPT do
		local T = e[1]
		local r = rumbles[i]
		local shake = r * sin(TAU * 13 * c + i)
		local shake2 = r * sin(TAU * 11 * c + 2 * i)
		local dip = L.track(c, { { T - 0.45, 0 }, { T - 0.02, 1, "sineInOut" }, { T + 0.1, 0, "cubicOut" } })
		local jolt = spring(c - T, 3.4, 11, 2.0)
		pose["Melon" .. i] = pa(0.06 * shake, 0.05 * w(t, 2, i * 0.3) - 0.25 * dip + 0.45 * jolt, 0.06 * shake2,
			1.5 * w(t, 1, i * 0.27) + 7 * shake - 7 * jolt, 0, 1.5 * w(t, 1, i * 0.27 + 0.25) + 7 * shake2)

		-- glow: crater, seams, lava streams
		local fl = flashes[i]
		ctx.transparency("Crater" .. i, clamp(0.3 + 0.15 * w(t, 2, i * 0.2) - 0.35 * r - 0.4 * fl, 0, 1))
		for k = 1, 4 do
			ctx.transparency("Seam" .. i .. "_" .. k, clamp(0.35 + 0.25 * w(t, 3, i * 0.17 + k * 0.25) - 0.5 * r - 0.5 * fl, 0, 1))
		end
		for k = 1, 2 do
			ctx.transparency("Flow" .. i .. "_" .. k, clamp(0.2 + 0.2 * w(t, 4, k * 0.5 + i * 0.1) - 0.4 * fl, 0, 1))
		end
		ctx.light("MelonLight" .. i, clamp(0.55 + 0.1 * w(t, 2, i * 0.3) + 0.6 * r + 1.3 * fl, 0, 2))

		-- lava blobs fly out and fall back in
		for k = 1, 2 do
			local u = (c - T - 0.02 * k) / e[2]
			local name = "Blob" .. i .. "_" .. k
			if u > 0 and u < 1 then
				local a = math.rad(BLOBDIR[i][k])
				local out = e[4] * sin(pi * u)
				local y = 4 * e[3] * u * (1 - u) * ((k == 1) and 1 or 0.8)
				pose[name] = pa(math.sin(a) * out, y, -math.cos(a) * out, 400 * u, 300 * u * ((k == 1) and 1 or -1), 160 * u)
				ctx.transparency("BlobGlow" .. i .. "_" .. k, 0)
			else
				pose[name] = pa(0, 0, 0, 0, 0, 0)
				ctx.transparency("BlobGlow" .. i .. "_" .. k, 0.3)
			end
		end

		if ctx.crossed(T - 0.6) then
			ctx.emit("Smoke" .. i, 3)
		end
		if ctx.crossed(T) then
			ctx.emit("Erupt" .. i, e[6])
			ctx.emit("Smoke" .. i, 10 + 2 * i)
		end
		if ctx.crossed(T + e[2]) then
			ctx.emit("Erupt" .. i, 10)
		end
	end
	if ctx.crossed(7.6) then
		ctx.emit("PoolEmbers", 18)
	end

	-- lava flowing UP the vine (5 trunk segments, then 3 branch segments)
	local fl = math.max(flashes[1], flashes[2], flashes[3])
	for g = 1, 8 do
		local idx = (g <= 5) and g or (g - 5 + 2.5)
		local pulse = 0.5 + 0.5 * sin(TAU * (5 * t / M.Cycle - idx * 0.22))
		ctx.transparency("VineGlow" .. g, clamp(0.65 - 0.6 * pulse - 0.3 * fl, 0, 1))
	end

	-- lava pool: bob + ripples running outward + an eruption ripple
	pose.Pool = pa(0, 0.06 * w(t, 2, 0.1), 0, 0, 0, 0)
	-- crust bits drift round the pool, bubbles swell up and sink (rest = sunk)
	for ci = 1, 3 do
		pose["Crust" .. ci] = ang(0, 36 * w(t, 1, ci * 0.3), 0)
	end
	for bi = 1, 3 do
		local u = ((t / M.Cycle) * 3 + bi * 0.31) % 1 -- 3 bubbles per loop each
		local up = (u < 0.6) and sin(pi * u / 0.6) or 0
		pose["Bubble" .. bi] = pa(0, -0.45 + 0.75 * up, 0, 0, 40 * u, 0)
	end
	for ri, n in RINGS do
		local wave = 0.5 + 0.5 * sin(TAU * (4 * t / M.Cycle - ri * 0.28))
		local hit = 0
		for _, e in ERUPT do
			hit = math.max(hit, spike(c - (e[1] + 0.15 + ri * 0.14), 0.08, 0.5))
		end
		for i = 1, n do
			ctx.transparency("Rip" .. ri .. "_" .. i, clamp(0.85 - 0.75 * wave - hit, 0, 1))
		end
	end
	for k = 1, 2 do
		ctx.transparency("Pour" .. k, clamp(0.5 - 0.45 * (0.5 + 0.5 * sin(TAU * (6 * t / M.Cycle - k * 0.3))) - 0.3 * flashes[2], 0, 1))
	end
	ctx.transparency("PoolCore", clamp(0.2 + 0.2 * w(t, 2, 0.4) - 0.3 * fl, 0, 1))
	ctx.light("PoolLight", clamp(0.9 + 0.2 * w(t, 2, 0.4) + 0.5 * fl, 0, 2))
end

return M
