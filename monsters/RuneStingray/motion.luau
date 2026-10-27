--!nocheck
-- Rune Stingray motion. Personality: CALM & MYSTERIOUS.
-- Idle: slow serene wing ripple (a wave travelling outward through the 3
-- wing bones), glide bob counter to the strokes, lazy whip-tail sway, sleepy
-- half-lidded slow blinks, an aloof little head tilt / look-away, curling
-- cephalic lobes, soft breathing lip, mouth bubbles, orbiting rune cubes.
-- Signature "RUNE SURGE" (12 s loop) - a slow, elegant spell:
--   3.2  anticipation: wings curl down like a cloak, sinks, eyes close
--        (meditating), rune tiles + spell circle start to glow
--   4.45 wings sweep UP overhead (big, slow), eyes open wide
--   4.85 one huge downstroke: lifts ~6 studs, rune tiles FLASH root->tip,
--        surge burst + bubbles
--   5.2  slow graceful BARREL ROLL (360) at the apex, wings spread
--   6.2  tail winds up ... 6.7 WHIP CRACK (travelling snap, burst)
--   6.9  glides back down on V-held wings, runes fade
--   9.2  soft landing dip, settles; aloof head tilt to finish
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 12

local sin, max, min = math.sin, math.max, math.min
local TAU = 2 * math.pi
local F = 1 / 12 -- every always-on wave runs whole cycles per loop

local WAMP = { 12, 26, 40 } -- idle absolute wing angles (deg), root -> tip
local DIHED = { 3, 6, 9 }
local CURL = { -18, -48, -78 }
local UP = { 50, 72, 90 }
local DOWN = { -26, -38, -46 }
local SPREAD = { 6, 10, 14 }
local GLIDE = { 12, 16, 20 }

local TYAW = { 4, 7, 11, 16, 22, 28 }
local TCURL = { 6, 9, 12, 15, 18, 20 }
local TSTREAM = { 8, 8, 6, 5, 4, 4 }
local TCRACK = { 14, 22, 30, 38, 46, 54 }
local TWHIP = { 6, 10, 14, 18, 24, 30 }
local BLINKS = { 2.1, 7.6, 10.9 }
local RUNES = 11 -- rune glyph plates per side

local function wingTrack(c, k)
	return L.track(c, {
		{ 3.2, 0 }, { 4.3, CURL[k], "sineInOut" }, { 4.45, CURL[k] },
		{ 4.85, UP[k], "cubicOut" }, { 5.2, DOWN[k], "cubicIn" }, { 5.7, SPREAD[k], "backOut" },
		{ 6.7, SPREAD[k] }, { 7.2, GLIDE[k], "sineInOut" }, { 9.0, GLIDE[k] }, { 9.8, 0, "sineInOut" },
	})
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes
	------------------------------------------------------------------
	local busy = L.env(c, 3.0, 0.4, 6.4, 0.6, "sineInOut", "sineInOut") -- 3.0 .. 10.4
	local idleW = 1 - busy
	local curl = L.env(c, 3.2, 1.1, 0.15, 0.4, "sineInOut", "cubicOut")
	local glide = L.env(c, 5.6, 0.5, 3.4, 0.6, "sineInOut", "sineInOut")
	local awake = L.env(c, 4.45, 0.2, 2.3, 0.8, "backOut", "sineInOut")
	local launch = L.env(c, 4.85, 0.35, 0.3, 0.5, "cubicOut", "sineInOut")
	local spellOn = L.env(c, 3.4, 0.9, 3.6, 1.3, "sineInOut", "sineInOut")
	local preGlow = L.env(c, 3.4, 1.0, 0.45, 0.2)
	local land = L.env(c, 9.1, 0.25, 0.1, 0.7, "quadOut", "sineInOut")

	local bodyY = L.track(c, {
		{ 3.2, 0 }, { 4.4, -1.2, "sineInOut" }, { 4.95, -1.4 }, { 5.8, 6.2, "backOut" },
		{ 6.8, 5.8, "sineInOut" }, { 9.05, 0.3, "sineInOut" }, { 9.35, -0.6, "quadOut" }, { 10.2, 0, "sineInOut" },
	})
	local bodyPitch = L.track(c, {
		{ 3.2, 0 }, { 4.4, -9, "sineInOut" }, { 4.85, 4 }, { 5.3, 16, "cubicOut" }, { 6.0, 0, "sineInOut" },
		{ 6.9, 0 }, { 7.4, -7, "sineInOut" }, { 8.8, -5 }, { 9.35, 5, "sineInOut" }, { 10.2, 0, "sineInOut" },
	})
	local roll = L.track(c, { { 5.25, 0 }, { 6.75, 360, "sineInOut" } })

	------------------------------------------------------------------
	-- BODY: serene glide bob (rises on the downstroke), slight sway
	------------------------------------------------------------------
	local stroke = 4 * F -- wing stroke frequency (3 s period: slow & calm)
	local bob = (0.55 * wave(t, stroke, 0.35)) * (1 - 0.6 * busy)
	local sway = 2.5 * wave(t, 2 * F, 0.1) * (1 - busy) + 7 * glide * sin(TAU * 0.5 * (c - 6.9))
	pose.Body = pa(0, bodyY + bob - 0.5 * land, 0,
		2.5 * wave(t, stroke, 0.1) * idleW + bodyPitch,
		3 * wave(t, F, 0.2) * idleW,
		roll + sway)

	------------------------------------------------------------------
	-- WINGS: outward-travelling ripple; surge track on top
	------------------------------------------------------------------
	local waveW = max(idleW, 0.4 * glide)
	local prev = 0
	for k = 1, 3 do
		local a = DIHED[k] * idleW + WAMP[k] * wave(t, stroke, -0.11 * (k - 1)) * waveW + wingTrack(c, k)
			- 10 * land * (k - 1) * 0.5
		L.both(pose, "Wing" .. k, ang(0, 0, a - prev))
		prev = a
	end

	------------------------------------------------------------------
	-- PELVIC FINS
	------------------------------------------------------------------
	L.both(pose, "Pelvic", ang(6 * wave(t, stroke, -0.2), 0, 14 * wave(t, stroke, -0.3) - 20 * curl + 18 * launch))

	------------------------------------------------------------------
	-- TAIL: lazy whip sway, curls under on the anticipation, streams on the
	-- launch, winds up and CRACKS after the roll (snap travels down the chain)
	------------------------------------------------------------------
	local tailF = 3 * F
	local prevY, prevP = 0, 0
	for i = 1, 6 do
		local ck = L.track(c - 0.035 * (i - 1), {
			{ 6.2, 0 }, { 6.55, -1, "cubicOut" }, { 6.72, 1.1, "quadIn" }, { 7.6, 0, "elasticOut" },
		})
		local y = TYAW[i] * wave(t, tailF, -0.09 * i) * (1 - 0.5 * busy)
			+ 0.4 * TYAW[i] * glide * sin(TAU * (0.5 * (c - 6.9) - 0.09 * i))
			+ TWHIP[i] * ck
		local p = 3 * wave(t, 2 * tailF, -0.1 * i) + TCURL[i] * curl + TSTREAM[i] * launch + TCRACK[i] * ck
		pose["Tail" .. i] = ang(p - prevP, y - prevY, 0)
		prevY, prevP = y, p
	end
	do
		local ck = L.track(c - 0.21, { { 6.2, 0 }, { 6.55, -1, "cubicOut" }, { 6.72, 1.1, "quadIn" }, { 7.6, 0, "elasticOut" } })
		pose.Sting = ang(45 * ck, 10 * wave(t, tailF, -0.7) * (1 - 0.5 * busy), 0)
	end

	------------------------------------------------------------------
	-- HEAD: aloof little tilt + look-away, chin slightly raised
	------------------------------------------------------------------
	local tilt = L.track(c, {
		{ 0.6, 0 }, { 1.4, 1, "sineInOut" }, { 2.7, 1 }, { 3.2, 0, "sineInOut" },
		{ 10.2, 0 }, { 10.9, -1, "sineInOut" }, { 11.6, -1 }, { 12.0, 0, "sineInOut" },
	})
	-- eyes lead, head follows: a slow side-eye, then the aloof head turn
	local glance = L.track(c, {
		{ 0.3, 0 }, { 0.7, 1, "sineInOut" }, { 2.8, 1 }, { 3.2, 0, "sineInOut" },
		{ 9.9, 0 }, { 10.3, -1, "sineInOut" }, { 11.6, -1 }, { 11.95, 0, "sineInOut" },
	})
	pose.Head = ang(
		2 * wave(t, stroke, 0.3) + 6 * math.abs(tilt) - 10 * curl + 12 * launch + 5 * awake,
		14 * tilt + 3 * L.noise(t, 3.3, 0.25) * idleW,
		17 * tilt + 2 * wave(t, 2 * F, 0.4) * idleW)

	-- sleepy half-lids: slow blinks, closed while meditating, wide awake in the surge
	local blink = curl
	for _, b in BLINKS do
		blink = max(blink, L.env(c, b, 0.2, 0.18, 0.3, "sineInOut", "sineInOut"))
	end
	local wide = awake * (1 - curl)
	local lidY = -0.88 * blink + 0.62 * wide
	-- one lid droops a touch lower during the look-away: lopsided, unimpressed
	pose.LidR = CFrame.new(0, lidY - 0.18 * idleW * math.abs(tilt), 0)
	pose.LidL = CFrame.new(0, lidY + 0.05 * idleW * math.abs(tilt), 0)
	-- brows: rise when it wakes up; one brow cocks up while it judges you
	local cock = idleW * math.abs(tilt)
	pose.BrowR = pa(0, 0.55 * wide - 0.12 * blink - 0.05 * cock, 0, 0, 0, -4 * cock + 6 * wide)
	pose.BrowL = pa(0, 0.55 * wide - 0.12 * blink + 0.4 * cock, 0, 0, 0, -12 * cock + 6 * wide)
	-- pupils: lazy drift, side-eye glance, look up when wide awake
	local gx = -0.55 * glance + 0.12 * L.noise(t, 7.1, 0.3) * idleW
	local gy = 0.3 * wide - 0.1 * blink
	pose.PupilR = CFrame.new(gx, gy, 0)
	pose.PupilL = CFrame.new(gx, gy, 0)

	-- cephalic lobes: slow curling, unfurl outward on the surge
	local cw = wave(t, 2 * F, 0.2)
	-- (base pose splays them outboard + down so they frame the face, not hide it)
	L.both(pose, "Ceph", ang(2 + 4 * cw + 14 * awake - 10 * curl, -20 - 4 * awake + 6 * curl, 0))
	L.both(pose, "CephTip", ang(6 * wave(t, 2 * F, 0.05), 12 * wave(t, 2 * F, 0.0) - 16 * awake + 20 * curl, 0))

	-- lower lip: calm breathing, soft "oh" while casting
	pose.Jaw = ang(-3 - 4 * L.wave01(t, stroke, 0.2) - 16 * awake - 6 * curl, 0, 0)

	------------------------------------------------------------------
	-- RUNE TILES: faint pre-glow, then a flash rippling root -> tip, a
	-- second pulse on the whip crack
	------------------------------------------------------------------
	for n = 1, RUNES do
		local d = 0.05 * (n - 1)
		local g = max(0.35 * preGlow, L.env(c, 4.9 + d, 0.12, 1.4, 1.2, "quadOut", "sineInOut"),
			0.8 * L.env(c, 6.75 + 0.5 * d, 0.06, 0.1, 0.5))
		local tr = g < 0.03 and 1 or (1 - 0.85 * g)
		ctx.transparency("RuneR" .. n, tr)
		ctx.transparency("RuneL" .. n, tr)
	end

	------------------------------------------------------------------
	-- SPELL CIRCLE: fades in under the ray and turns slowly
	------------------------------------------------------------------
	pose.Spell = pa(0, 0.6 * launch, 0, 0, 25 * c + 60 * launch, 0)
	local str = spellOn < 0.03 and 1 or (1 - 0.7 * spellOn)
	for k = 1, 12 do
		ctx.transparency("Spell" .. k, str)
	end

	------------------------------------------------------------------
	-- floating rune cubes: slow bob + tumble; rise and swirl with the spell
	------------------------------------------------------------------
	local OD = { { 1, -1 }, { -1, 0.2 }, { 1, 1 }, { -1, -1 } }
	for i = 1, 4 do
		local d = OD[i]
		local lift = 0.6 * max(0, bodyY)
		local out = 1.5 * awake - 1.2 * curl
		local dx = 0.7 * wave(t, F, i * 0.23) + out * d[1]
		local dy = 0.8 * wave(t, 2 * F, i * 0.29) + lift
		local dz = 0.7 * wave(t, F, i * 0.23 + 0.25) + out * 0.5 * d[2]
		local s = i % 2 == 0 and -1 or 1
		pose["Orb" .. i] = pa(dx, dy, dz, 360 * F * t * s + 25 * i, 360 * 2 * F * t + 180 * awake * s, 20 * i)
	end

	------------------------------------------------------------------
	-- voxel bubbles drifting up from the mouth (idle only)
	------------------------------------------------------------------
	local gp = (t / 4) % 1
	for k = 1, 3 do
		local u = (gp - (k - 1) * 0.12) / 0.6
		local on = u > 0 and u < 1 and idleW > 0.95
		pose["Bubble" .. k] = on and pa(0.6 * sin(TAU * (1.2 * u + k * 0.3)) + 0.5 * (k - 2), 4.5 * u + bob, -1.5 * u, 0, 80 * u, 45) or CFrame.new()
		ctx.transparency("BubblePart" .. k, on and (u > 0.85 and 1 or 0.4) or 1)
	end

	------------------------------------------------------------------
	-- effects on the beats
	------------------------------------------------------------------
	if ctx.crossed(3.6) then ctx.emit("SpellSparkle", 12) end
	if ctx.crossed(4.5) then
		ctx.emit("SpellSparkle", 20)
		ctx.emit("RuneSparkle", 10)
	end
	if ctx.crossed(5.0) then
		ctx.emit("SurgeBurst", 45)
		ctx.emit("BubbleBurst", 30)
		ctx.emit("SpellSparkle", 25)
	end
	if ctx.crossed(6.0) then ctx.emit("RuneSparkle", 14) end
	if ctx.crossed(6.88) then
		ctx.emit("CrackBurst", 40)
		ctx.emit("RuneSparkle", 10)
	end
	if ctx.crossed(9.2) then ctx.emit("BubbleBurst", 16) end

	local flash = L.env(c, 4.9, 0.12, 1.2, 1.4)
	ctx.light("BodyLight", min(1.5, 0.3 + 1.1 * flash + 0.3 * preGlow))
	ctx.light("StingLight", min(1.5, 0.2 + 1.2 * L.env(c, 6.8, 0.06, 0.15, 0.6)))
end

return M
