-- Frost Treadmill motion (seamless 4 s loop).
-- Belt runs toward the back, snowflake hubs spin, the ice crystal spins and
-- bobs with orbiting shards, chase lights race along the frame toward the back,
-- and at 2.6 s a "freeze burst": the crystal whirls an extra turn, the shards
-- fly out and spring back, everything flashes and a snow puff pops.
local L = require(script.Parent.AnimLib)
local E = L.ease
local M = {}
M.Cycle = 4

local SPEED = 5 -- studs/s of belt travel
local PERIOD = 1.0 -- belt pattern repeat (2 slats)

local SHARD_DIR = {}
for k = 1, 3 do
	local a = math.rad(120 * (k - 1))
	SHARD_DIR[k] = Vector3.new(math.sin(a), 0, math.cos(a))
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle
	local burst = L.env(c, 2.6, 0.2, 0.25, 0.85, "backOut", "cubicInOut")
	local wind = L.env(c, 2.1, 0.5, 0.0, 0.2, "sineInOut", "quadIn") -- anticipation

	-- belt + rollers (+X spin carries the top of each hub toward the back)
	pose.Belt = CFrame.new(0, 0, (t * SPEED) % PERIOD)
	local front = L.ang((t * 360) % 360, 0, 0) -- 1 rev/s
	local rear = L.ang((t * 450) % 360, 0, 0) -- smaller hubs spin faster
	pose.HubFR, pose.HubFL, pose.HubRR, pose.HubRL = front, front, rear, rear
	-- giant rear snowflake: slow turn, whips an extra half-turn on the burst
	pose.BigFlake = L.ang((45 * c + 180 * E.backOut(L.clamp01((c - 2.6) / 0.9))) % 360, 0, 0)

	-- crystal: steady turn + an extra eased whirl through the burst
	local extra = 360 * E.cubicInOut(L.clamp01((c - 2.45) / 1.1))
	local spin = (90 * c + extra) % 360
	local bob = 0.22 * L.wave(t, 0.5) - 0.25 * wind + 0.45 * burst
	pose.Crystal = CFrame.new(0, bob, 0) * L.ang(8 * L.wave(t, 0.25) - 10 * wind, spin, 6 * L.wave(t, 0.5, 0.25))

	-- side floating crystals spin opposite ways and bob, hop up on the burst
	pose.FloatR = CFrame.new(0, 0.25 * L.wave(t, 0.5) + 0.5 * burst, 0) * L.ang(0, (c * 180) % 360, 0)
	pose.FloatL = CFrame.new(0, 0.25 * L.wave(t, 0.5, 0.5) + 0.5 * burst, 0) * L.ang(0, -(c * 180) % 360, 0)
	ctx.transparency("PyCoreR", math.max(0, 0.4 + 0.3 * L.wave(t, 1) - burst))
	ctx.transparency("PyCoreL", math.max(0, 0.4 + 0.3 * L.wave(t, 1, 0.5) - burst))

	-- shard ring orbits the other way (2 turns per loop), shards fly out on the burst
	pose.FrostHalo = L.ang(0, (t * 270) % 360, 0)
	pose.ShardRing = CFrame.new(0, 0.15 * L.wave(t, 0.5, 0.5), 0) * L.ang(0, -(180 * c) % 360, 0)
	for k = 1, 3 do
		local out = 0.9 * burst - 0.25 * wind
		local d = SHARD_DIR[k] * out
		pose["Shard" .. k] = CFrame.new(d.X, 0.2 * L.wave(t, 1, k / 3), d.Z) * L.ang(0, (t * 180 * k) % 360, 25 * burst)
	end

	-- chase lights race toward the back (2 laps per loop), all flash on the burst
	local head = (t * 4) % 8
	for i = 1, 8 do
		local d = ((i - 1) - head) % 8
		local on = (d < 2.2 or burst > 0.35) and 0 or 0.8
		ctx.transparency("ChR" .. i, on)
		ctx.transparency("ChL" .. i, on)
	end

	-- frost equalizer: rippling levels, full on the burst
	for i = 1, 8 do
		local lvl = 4.5 + 3.5 * L.wave(t, 1, i * 0.11)
		ctx.transparency("Bar" .. i, (i <= lvl or burst > 0.3) and 0 or 0.85)
	end
	-- thermometer drops toward the freeze, refills after
	local temp = c < 2.6 and (4 - math.floor(c / 0.65)) or (1 + math.floor((c - 2.6) / 0.35))
	for i = 1, 4 do
		ctx.transparency("Th" .. i, i <= temp and 0 or 0.85)
	end
	ctx.transparency("Led", (t * 2) % 1 < 0.5 and 0 or 0.7)

	-- icicle tips twinkle one after another
	for i = 1, 22 do
		local ph = (t * 1.5 + i * 0.37) % 1
		ctx.transparency("IcTip" .. i, ph < 0.18 and 0 or 0.55)
	end

	-- spire cores breathe, flash on the burst
	local br = 0.45 + 0.3 * L.wave(t, 0.5)
	ctx.transparency("SpCoreR", math.max(0, br - burst))
	ctx.transparency("SpCoreL", math.max(0, 0.45 + 0.3 * L.wave(t, 0.5, 0.5) - burst))
	ctx.transparency("SpTipR", (t * 2) % 1 < 0.5 and 0 or 0.4)
	ctx.transparency("SpTipL", (t * 2 + 0.5) % 1 < 0.5 and 0 or 0.4)
	ctx.transparency("CrysCore", 0.15 * (1 - burst) + 0.1 * L.wave01(t, 1))
	ctx.transparency("PedRing", burst > 0.2 and 0 or 0.4 + 0.3 * L.wave01(t, 1))
	ctx.transparency("BridgeGlow", burst > 0.2 and 0 or 0.3 + 0.3 * L.wave01(t, 0.5))
	ctx.light("CrystalLight", 0.8 + 1.0 * burst)

	if ctx.crossed(2.7) then
		ctx.emit("FreezeBurst", 40)
	end
end

return M
