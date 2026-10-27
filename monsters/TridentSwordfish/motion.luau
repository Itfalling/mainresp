--!nocheck
-- Trident Swordfish motion. Personality: BRAVE HOT-HEADED KNIGHT.
-- Idle: swimming S-wave down the body chain, rippling sail, sweeping crescent
-- tail, angry-heroic brows that twitch, gritted teeth, blinks, and constant
-- "come at me!" energy: quick feint-jabs with the trident (0.75 / 1.05 and
-- 8.75 / 9.05), a bouncing battle-ready guard (fins up) and a chest-puff
-- power pose with the sail flared (2.2).
-- Signature "TRIDENT LUNGE" (every 10 s):
--   3.0  anticipation: pulls back ~3.5 studs and coils into an S, nose down,
--        sail flares, fins tuck, squint, brows slam down, crystal charges
--   3.97 LUNGE: rockets ~12 studs forward, trident thrusts out, sail folds
--        flat, tail power-strokes, long trident trail
--   4.18 IMPACT: shards + burst + bubbles, squash
--   4.25 SPINNING SLASH: the whole body rolls 360 (neon slash ring appears
--        segment by segment), crystal flashes
--   5.05 bubble / sparkle burst, RECOIL back with a wiggly follow-through
--   5.75 HEROIC VICTORY POSE: rears nose-up, trident to the sky, right fin
--        raised high in salute, left fin on the "hip", sail snaps up, "HA!"
--        grin, glint star on the tip, cheeky wink
--   7.5  settle back into the idle swim
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 10

local sin, pi, max, min = math.sin, math.pi, math.max, math.min
local TAU = 2 * pi

local CHAIN = { "Head", "Body1", "Body2", "Tail1", "Tail2", "Tail3", "TailFin" }
local CENTER = 2
local SWIM = 0.6 -- 6 whole cycles per 10 s loop
local AMP = { 4, 3, 7, 13, 20, 28, 36 } -- swim yaw (absolute), head -> tail
local COIL_YAW = { -16, -6, 10, 22, 28, 22, 4 } -- anticipation S-coil
local COIL_PITCH = { -12, -4, 4, 8, 10, 8, 2 }
local KICK = { 0, 0, 6, 14, 24, 32, 40 } -- tail power strokes on the lunge
local WIG = { 10, 4, 8, 14, 20, 26, 32 } -- recoil follow-through
local VIC = { 16, 0, -6, -12, -16, -16, -10 } -- victory: head up, tail tucked under

local JABS = { 0.75, 1.05, 8.75, 9.05 }
local BLINKS = { 0.45, 2.75, 8.45, 9.65 }

local SN = 4.18 -- impact
local BZ = {
	{ 3.0, 0 }, { 3.85, 3.4, "cubicOut" }, { 3.97, 3.6 }, { SN, -8.5, "expoOut" },
	{ 5.05, -9.6 }, { 5.55, 1.2, "cubicInOut" }, { 6.1, 0, "backOut" },
}
local BY = {
	{ 3.0, 0 }, { 3.85, 0.7, "cubicOut" }, { SN, -0.2, "expoOut" }, { 5.05, 0.4 },
	-- rears UP into the victory pose (lifted so the tail clears the floor as the nose tips up)
	{ 5.4, 0.3 }, { 6.0, 2.6, "backOut" }, { 7.5, 2.5 }, { 8.3, 0, "cubicInOut" },
}
local PITCH = {
	{ 3.0, 0 }, { 3.85, -6, "cubicOut" }, { SN, 3, "expoOut" }, { 4.35, 0 }, { 5.05, 0 },
	{ 5.5, -8, "quadOut" }, { 6.05, 26, "backOut" }, { 7.5, 24 }, { 8.3, 0, "cubicInOut" },
}
local ROLL = { { 4.25, 0 }, { 5.05, 360, "cubicInOut" } }

-- impact shard directions (x, y, z)
local SHARD_DIR = {
	{ 1.0, 0.8, -0.5 }, { -1.0, 0.9, -0.4 }, { 0.5, 1.3, -0.8 }, { -0.6, 1.2, -0.9 },
	{ 1.3, -0.1, -0.3 }, { -1.3, 0.1, -0.2 }, { 0.4, -0.6, -1.2 }, { -0.3, 0.5, -1.4 },
}
local SH_BX, SH_BY, SH_BZ = 0, L.track(SN, BY), L.track(SN, BZ)

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes
	------------------------------------------------------------------
	local coil = L.env(c, 3.0, 0.85, 0.12, 0.12, "cubicOut", "expoIn")
	local lungeE = L.env(c, 3.97, 0.15, 1.0, 0.45, "expoOut", "cubicInOut")
	local thrust = L.env(c, 3.97, 0.18, 0.15, 0.3, "backOut", "cubicInOut")
	local kick = L.env(c, 3.85, 0.1, 0.45, 0.4)
	local spinE = L.env(c, 4.2, 0.1, 0.75, 0.15)
	local squash = L.env(c, SN, 0.04, 0.03, 0.5, "linear", "elasticOut")
	local recoil = L.env(c, 5.05, 0.2, 0.2, 0.6, "quadOut", "cubicInOut")
	local victory = L.env(c, 5.75, 0.3, 1.45, 0.8, "backOut", "cubicInOut")
	local salute = L.env(c, 5.85, 0.22, 1.2, 0.6, "backOut", "cubicInOut")
	local shout = L.env(c, 5.85, 0.15, 0.55, 0.3, "backOut", "quadIn")
	local wink = L.env(c, 6.6, 0.08, 0.35, 0.12)
	local special = L.env(c, 2.95, 0.15, 5.15, 0.3)
	local idleW = 1 - special
	local swimW = 1 - 0.8 * max(coil, lungeE, spinE) - 0.5 * victory

	-- idle personality beats
	local jab, wind = 0, 0
	for _, j in JABS do
		jab += L.env(c, j, 0.07, 0.05, 0.2, "expoOut", "cubicInOut")
		wind += L.env(c, j - 0.17, 0.13, 0, 0.04, "quadOut", "linear")
	end
	local guard = max(L.env(c, 1.4, 0.25, 0.55, 0.3), L.env(c, 9.3, 0.2, 0.3, 0.2))
	local puff = L.env(c, 2.15, 0.2, 0.35, 0.25, "backOut", "cubicInOut")
	-- hot-headed "GRRR!": teeth chatter, head shake, angry gill huff
	local grr = L.env(c, 8.0, 0.12, 0.45, 0.2, "backOut", "quadIn")

	------------------------------------------------------------------
	-- absolute heading / pitch along the body
	------------------------------------------------------------------
	local kickPh = 3.2 * (c - 3.85)
	local wigPh = 2.5 * (c - 5.05)
	local vicPh = 1.2 * (c - 5.75)
	local yaw, pitch = {}, {}
	for i = 1, #CHAIN do
		local k = i - 1
		local swim = AMP[i] * sin(TAU * (SWIM * t - 0.12 * k))
		yaw[i] = swimW * swim + coil * COIL_YAW[i]
			+ kick * KICK[i] * sin(TAU * (kickPh - 0.15 * k))
			+ recoil * WIG[i] * sin(TAU * (wigPh - 0.14 * k))
			+ victory * 0.6 * AMP[i] * sin(TAU * (vicPh - 0.12 * k))
		pitch[i] = 3 * sin(TAU * (SWIM * t - 0.1 * k + 0.25)) * swimW + coil * COIL_PITCH[i] + victory * VIC[i]
	end
	-- idle: sizing up the opponent, nod into every jab, chin up on the puff
	yaw[1] += (7 * L.noise(t, 3.3, 0.4) + 4 * wave(t, 0.2, 0.3)) * idleW + 9 * grr * wave(c, 7.0)
	pitch[1] += (3 * wave(t, 1.0, 0.1)) * idleW - 12 * jab + 6 * wind + 10 * puff - 4 * guard - 5 * grr

	------------------------------------------------------------------
	-- root (Body1): hover bob, jabs, guard bounce, lunge, spin, victory
	------------------------------------------------------------------
	local bob = 0.8 * wave(t, 0.5) * (1 - 0.6 * special)
	local hop = 0.45 * L.bounce(t, 2.0) * guard
	-- extra hop while the nose snaps up (the tail swings down before its victory curl arrives)
	local rearHop = L.env(c, 5.55, 0.2, 0.05, 0.35, "quadOut", "sineInOut")
	local by = bob + hop + L.track(c, BY) - 1.4 * squash + 0.5 * puff - 0.3 * guard + 1.6 * rearHop
	local bz = L.track(c, BZ) - 2.8 * jab + 1.1 * wind
	local bx = 0.4 * wave(t, 0.3) * swimW
	local spin = L.track(c, ROLL)
	local roll = 5 * wave(t, SWIM, 0.15) * swimW + spin + 6 * guard * wave(t, 2.0)
	local bp = pitch[CENTER] + L.track(c, PITCH) - 4 * guard - 5 * puff
	pose.Body1 = pa(bx, by, bz, bp, yaw[CENTER], roll)

	pose.Head = ang(pitch[1] - pitch[2], yaw[1] - yaw[2], 0)
	for i = CENTER + 1, #CHAIN do
		pose[CHAIN[i]] = ang(pitch[i] - pitch[i - 1], yaw[i] - yaw[i - 1], 0)
	end

	-- trident: thrusts out of the collar on the lunge and every jab
	pose.Bill = pa(0, 0, -1.2 * thrust - 1.3 * jab + 0.4 * wind, 0, 0, 0)
	-- knightly flourishes: brandish wiggle in the guard, a full 360 TWIRL on
	-- the chest-puff and another one to start the victory pose
	local twirl = L.track(c, { { 2.1, 0 }, { 2.6, 360, "backOut" } }) + L.track(c, { { 5.8, 0 }, { 6.3, 360, "backOut" } })
	pose.Trident = ang(0, 0, twirl + 25 * guard * wave(t, 1.5))

	------------------------------------------------------------------
	-- face: jaw (gritted -> "HUP!" -> battle cry -> "HA!"), brows, lids
	------------------------------------------------------------------
	local jawX = -(18 * jab + 40 * thrust + 44 * shout + 8 * puff) - 10 * spinE * L.wave01(c, 4.0)
	jawX -= 6 * victory * (1 - shout) -- confident open smirk while posing
	jawX -= 14 * grr * L.wave01(c, 9.0) -- chattering grit
	pose.Jaw = ang(jawX, 0, 0)

	local browZ = 4 * wave(t, 0.7) * idleW + 10 * jab + 12 * coil + 8 * lungeE - 16 * victory - 6 * puff + 10 * grr
	local browY = -0.15 * (jab + coil) + 0.3 * victory + 0.2 * puff + 0.08 * wave(t, 1.4) * idleW
	L.both(pose, "Brow", pa(0, browY, 0, 0, 0, browZ))

	local blink = max(0.4 * coil, 0.25 * lungeE * (1 - spinE), 0.8 * L.env(c, SN - 0.02, 0.04, 0.1, 0.12))
	for _, b in BLINKS do
		blink = max(blink, L.env(c, b, 0.06, 0.06, 0.1))
	end
	local blinkL = max(blink, wink)
	pose.LidR = CFrame.new(0, -1.4 * blink, 0)
	pose.LidL = CFrame.new(0, -1.4 * blinkL, 0)
	ctx.transparency("EyelidR", blink > 0.06 and 0 or 1)
	ctx.transparency("EyelidL", blinkL > 0.06 and 0 or 1)

	------------------------------------------------------------------
	-- dorsal sail: ripple, flare on the coil / puff, fold flat on the lunge
	-- (staggered), SNAP up with overshoot for the victory pose
	------------------------------------------------------------------
	for i = 1, 6 do
		local fold = L.env(c, 3.97 + 0.025 * i, 0.12, 1.0, 0.45, "cubicOut", "backOut")
		local x = 7 * sin(TAU * (1.0 * t - 0.14 * i)) * (1 - 0.8 * fold) * (1 - 0.6 * victory)
			- 10 * coil - 12 * puff + 72 * fold - 10 * victory + 6 * jab
		local z = 4 * sin(TAU * (SWIM * t - 0.1 * i)) * swimW
		pose["Sail" .. i] = ang(x, 0, z)
	end

	------------------------------------------------------------------
	-- pectoral fins (model axes, right side): +Z raise, +Y sweep forward
	------------------------------------------------------------------
	local pad = wave(t, SWIM)
	local baseZ = 12 * pad * swimW + 48 * guard + 18 * puff - 12 * coil + 38 * spinE
	local baseY = 10 * wave(t, SWIM, 0.25) * swimW + 40 * guard - 18 * jab - 38 * coil - 55 * lungeE * (1 - spinE)
	local tipZ = 16 * wave(t, SWIM, -0.15) * swimW + 18 * guard - 15 * coil + 25 * spinE * sin(TAU * 3 * (c - 4.2))
	local rightZ = baseZ + 60 * salute + 10 * salute * wave(c, 2.0)
	local rightY = baseY + 65 * salute
	local leftZ = baseZ - 22 * salute
	local leftY = baseY - 35 * salute
	pose.PecR = ang(0, rightY, rightZ)
	pose.PecL = L.mirror(ang(0, leftY, leftZ))
	L.both(pose, "PecTip", ang(0, 0, tipZ + 20 * salute), ang(0, 0, tipZ - 30 * salute))
	L.both(pose, "Pelvic", ang(10 * wave(t, 1.2) + 20 * lungeE, 0, 12 * wave(t, 1.2, 0.2)))

	------------------------------------------------------------------
	-- floating cubes: bob + tumble, dragged in the lunge wake, flung by the spin
	------------------------------------------------------------------
	for i = 1, 6 do
		local ph = i * 0.17
		local dir = i % 2 == 0 and -1 or 1
		local out = 2.2 * spinE + 1.2 * squash
		local dx = 0.8 * wave(t, 0.2, ph) + out * dir
		local dy = 1.0 * wave(t, 0.4, ph + 0.3) + 0.6 * victory + 0.6 * coil
		local dz = 0.8 * wave(t, 0.2, ph + 0.25) - 3.0 * lungeE + 1.0 * coil
		pose["Orb" .. i] = pa(dx, dy, dz, 72 * t * dir + 30 * i, 108 * t, 35 + 20 * i)
	end

	------------------------------------------------------------------
	-- slash ring: stays upright in the world (counter-roll) while arc
	-- segments appear behind the rolling prongs and fade
	------------------------------------------------------------------
	pose.Slash = ang(0, 0, -roll)
	local slashOn = c > 4.25 and c < 5.4
	local fadeAll = L.remap(c, 5.05, 5.4)
	for i = 0, 11 do
		local tr = 1
		if slashOn then
			local age = (spin - i * 30) / 30 -- segments since this one appeared
			if age >= 0 and age < 7 then
				tr = 0.1 + 0.11 * age
			elseif c > 5.05 and age >= 0 then
				tr = 0.6
			end
			if c > 5.05 then
				tr = max(tr, 0.6 + 0.4 * fadeAll)
			end
		end
		ctx.transparency("Slash" .. i, min(1, tr))
	end

	------------------------------------------------------------------
	-- impact shards: burst from the trident tip, tumble, fall, vanish
	------------------------------------------------------------------
	local sp = L.remap(c, SN, SN + 0.8)
	local shardOn = c > SN and c < SN + 0.8
	local se = L.ease.cubicOut(sp)
	for k = 1, 8 do
		local d = SHARD_DIR[k]
		local r = 8 * se
		local spn = 540 * sp * (k % 2 == 0 and -1 or 1)
		pose["Shard" .. k] = shardOn
				and pa(SH_BX + d[1] * r, SH_BY + d[2] * r - 4 * sp * sp, SH_BZ + d[3] * r, spn, spn * 0.7, 45 * k)
			or CFrame.new()
		ctx.transparency("ShardPart" .. k, shardOn and (sp > 0.7 and (sp - 0.7) / 0.3 or 0) or 1)
	end

	------------------------------------------------------------------
	-- victory glint on the trident tip
	------------------------------------------------------------------
	local gp = L.remap(c, 5.95, 6.5)
	local glintOn = c > 5.95 and c < 6.5
	pose.Glint = ang(0, 0, 45 + 180 * gp)
	local gtr = glintOn and (0.05 + 0.95 * max(0, (gp - 0.5) / 0.5)) or 1
	ctx.transparency("GlintA", gtr)
	ctx.transparency("GlintB", gtr)

	------------------------------------------------------------------
	-- lights + bursts on the beats
	------------------------------------------------------------------
	local flash = max(L.env(c, 4.22, 0.04, 0.12, 0.3), L.env(c, 5.05, 0.04, 0.1, 0.3), L.env(c, 5.95, 0.05, 0.15, 0.4))
	ctx.light("CrystalLight", min(1.5, 0.35 + 0.5 * coil + 1.1 * flash))
	ctx.light("TipLight", min(1.5, 1.4 * L.env(c, SN - 0.04, 0.04, 0.12, 0.3) + 0.6 * L.env(c, 5.95, 0.05, 0.2, 0.3)))

	if ctx.crossed(2.45) then
		ctx.emit("CrystalFlash", 12)
		ctx.emit("AmbientSparkle", 8)
	end
	if ctx.crossed(3.05) then
		ctx.emit("BubbleBurst", 6)
	end
	if ctx.crossed(3.98) then
		ctx.emit("WakeBurst", 30)
	end
	if ctx.crossed(SN + 0.01) then
		ctx.emit("LungeBurst", 45)
		ctx.emit("BubbleBurst", 30)
	end
	if ctx.crossed(4.24) then
		ctx.emit("CrystalFlash", 25)
	end
	if ctx.crossed(5.06) then
		ctx.emit("BubbleBurst", 35)
		ctx.emit("AmbientSparkle", 14)
		ctx.emit("CrystalFlash", 15)
	end
	if ctx.crossed(5.6) then
		ctx.emit("WakeBurst", 15)
	end
	if ctx.crossed(6.0) then
		ctx.emit("VictorySparkle", 40)
		ctx.emit("CrystalFlash", 30)
	end
	if ctx.crossed(8.1) then
		ctx.emit("BubbleBurst", 10)
	end
	for _, j in JABS do
		if ctx.crossed(j + 0.06) then
			ctx.emit("BubbleBurst", 5)
		end
	end
	ctx.enable("SlashBubbles", c > 4.25 and c < 5.1)
end

return M
