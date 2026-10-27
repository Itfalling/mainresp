--!nocheck
-- Atlantean Pufferfish motion. Personality: SHY & JUMPY.
-- Idle: nervous bobbing hover, buzzing fins, cheeks puffing in and out,
-- darting / wobbly googly pupils, blinks, worried brows, little burp bubbles,
-- a shy "hide behind the fins and peek out" and a tiny hiccup-startle.
-- Signature "PUFF PANIC" (every 10 s):
--   3.4  STARTLE: jolts up, eyes pop, pupils shrink, "!" pops, fins flare
--   3.75 SUCK IN: squash, panels pull in, cheeks balloon, lips pucker
--   4.15 INFLATE: panels + spines punch outward (overshoot), marble chips burst
--   4.6  PANIC SPIN: 360 spin while puffed, pupils spin, fins buzz, jitter
--   5.9  "PFFT": deflates, bubble jet out of the lips, zips backwards, wobbles
--   6.5  EMBARRASSED: big blush "///", sweat drop, half lids, hides behind
--        both fins, turns away, peeks out with one eye (7.9), "eep" (8.95),
--        settles back into the idle (9.3 - 10)
local L = require(script.Parent.AnimLib)
local ang, pa, wave = L.ang, L.pa, L.wave

local M = {}
M.Cycle = 10

local sin, cos, pi, max, min, abs = math.sin, math.cos, math.pi, math.max, math.min, math.abs
local TAU = 2 * pi
local F = 1 / 10 -- whole cycles per loop

local STARTLE, SUCK, INFL, SPIN0, SPIN1, PFFT = 3.4, 3.75, 4.15, 4.6, 5.5, 5.9
local PEEK, EEP = 7.9, 8.95

-- spines: name, dir (right side), kind ("Body" spines sit on the core edges
-- and must also travel with the swelling corner), mirrored
local SPINES = {
	{ "SpTopA", { 0.45, 1, 0.4 }, 0, true },
	{ "SpTopB", { 0.45, 1, -0.45 }, 0, true },
	{ "SpEdgeU", { 1, 1, 0 }, 1.7, true },
	{ "SpEdgeD", { 1, -1, 0 }, 1.7, true },
	{ "SpEdgeB", { 1, 0, 1 }, 1.7, true },
	{ "SpCorner", { 1, 1, 1 }, 2.4, true },
	{ "SpChin", { 0, -1, -1 }, 1.5, false },
	{ "SpSideA", { 1, 0.35, -0.1 }, 0, true },
	{ "SpSideB", { 1, -0.35, 0.1 }, 0, true },
	{ "SpSideC", { 1, 0.1, 0.6 }, 0, true },
	{ "SpRearU", { 0.35, 0.35, 1 }, 0, true },
	{ "SpRearD", { 0.35, -0.35, 1 }, 0, true },
	{ "SpBellyA", { 0.35, -1, 0.1 }, 0, true },
	{ "SpBellyB", { 0, -1, -0.3 }, 0, false },
}
for _, s in SPINES do
	s[2] = Vector3.new(s[2][1], s[2][2], s[2][3]).Unit
end

local BLINKS = { 0.55, 2.2, 9.55 }
local CUBES = { { 1, 1 }, { -1, 1 }, { 1, -1 }, { -1, -1 } }

-- the puff amount (with overshoot) at cycle time cc
local function puffAt(cc)
	return L.track(cc, {
		{ INFL, 0 }, { INFL + 0.16, 1.2, "quadOut" }, { INFL + 0.34, 0.92, "quadInOut" },
		{ INFL + 0.5, 1.03, "quadInOut" }, { INFL + 0.62, 1.0, "quadInOut" },
		{ PFFT, 1.0 }, { PFFT + 0.2, -0.15, "quadIn" }, { PFFT + 0.42, 0.08, "quadOut" },
		{ PFFT + 0.62, 0, "quadInOut" },
	})
end

function M.Update(t, pose, ctx)
	local c = t % M.Cycle

	------------------------------------------------------------------
	-- envelopes
	------------------------------------------------------------------
	local busy = L.env(c, 3.25, 0.15, 6.0, 0.6)
	local idleW = 1 - busy
	local startle = L.env(c, STARTLE, 0.07, 0.25, 0.3, "backOut", "quadIn")
	local suck = L.env(c, SUCK, 0.32, 0.08, 0.1, "cubicOut", "expoIn")
	local P = puffAt(c)
	local Pc = max(0, min(1, P))
	local panic = L.env(c, INFL + 0.15, 0.1, PFFT - INFL - 0.2, 0.1)
	local spin = L.track(c, { { SPIN0, 0 }, { SPIN1, 360, "cubicInOut" } })
	local pfft = L.env(c, PFFT, 0.04, 0.4, 0.3, "quadOut", "quadIn")
	local wob = L.env(c, PFFT + 0.1, 0.1, 0.5, 0.9, "quadOut", "quadIn")
	local embar = L.env(c, PFFT + 0.45, 0.3, 2.7, 0.55)
	local hideL = L.env(c, 6.55, 0.3, 2.3, 0.45, "backOut", "quadInOut")
	local peek = L.env(c, PEEK, 0.3, 0.6, 0.15, "backOut", "backIn")
	local eep = L.env(c, EEP, 0.06, 0.08, 0.35, "backOut", "quadInOut")
	local hideR = hideL * (1 - peek)
	-- idle shyness: half-hides behind the fins, then a tiny hiccup startle
	local shy = 0.7 * L.env(c, 0.95, 0.3, 0.75, 0.4, "backOut", "quadInOut")
	local shyPeek = L.env(c, 1.35, 0.15, 0.3, 0.15)
	local hic = L.env(c, 2.65, 0.06, 0.06, 0.35, "backOut", "quadInOut")
	local hideAll = max(hideL, shy)

	------------------------------------------------------------------
	-- BODY: bob, startle hop, squash, puff rise, spin, pfft zip, hide
	------------------------------------------------------------------
	local bob = 0.55 * wave(t, 5 * F) + 0.15 * wave(t, 13 * F, 0.3)
	local hopY = L.track(c, {
		{ STARTLE, 0 }, { STARTLE + 0.12, 1.9, "quadOut" }, { STARTLE + 0.32, 1.0, "quadInOut" },
		{ SUCK, 1.0 }, { SUCK + 0.32, 0.1, "cubicOut" }, { INFL, 0.1 }, { INFL + 0.22, 1.5, "backOut" },
		{ PFFT, 1.2 }, { PFFT + 0.22, -0.7, "quadIn" }, { PFFT + 0.6, 0.4, "quadOut" },
		{ PFFT + 1.0, -0.2, "quadInOut" }, { 6.9, -0.7, "quadInOut" }, { 9.1, -0.7 }, { 9.7, 0, "quadInOut" },
	})
	local by = bob * (1 - 0.6 * busy) + hopY + 0.6 * hic + 0.7 * eep - 0.4 * shy
	local bz = L.track(c, { { PFFT, 0 }, { PFFT + 0.35, 3.2, "cubicOut" }, { PFFT + 1.5, 0.4, "cubicInOut" }, { 9.6, 0, "quadInOut" } })
		+ 0.8 * startle + 0.4 * hic
	local bx = 0.3 * wave(t, 3 * F, 0.2) * idleW - 0.6 * hideL
	local jit = 6 * panic * L.noise(t, 3.3, 9) + 4 * startle * sin(TAU * 18 * c)
	local wobble = sin(TAU * 2.6 * (c - PFFT - 0.1))
	local yaw = spin + 10 * hideAll + 10 * eep * sin(TAU * 8 * c)
		+ (10 * L.noise(t, 1.7, 0.4) + 6 * wave(t, 2 * F)) * idleW
		+ 14 * wob * wobble - 8 * peek
	local pitch = -5 * hideAll + 14 * startle - 10 * suck + 5 * wave(t, 5 * F, 0.25) * idleW
		+ 8 * hic + 10 * wob * sin(TAU * 2.6 * (c - PFFT))
	local roll = 6 * wave(t, 4 * F, 0.1) * idleW + jit + 24 * wob * wobble - 8 * hideAll
	pose.Body = pa(bx, by, bz, pitch, yaw, roll)

	------------------------------------------------------------------
	-- INFLATE: panels push outward (with a soft breathing pulse)
	------------------------------------------------------------------
	local breathe = 0.08 * wave(t, 5 * F, 0.5) * idleW
	local d = 1.7 * P - 0.5 * suck + breathe
	local jx = 0.12 * panic * sin(TAU * 11 * c)
	pose.Top = pa(0, d, 0, 0, 0, 0)
	pose.Belly = pa(0, -d, 0, 0, 0, 0)
	L.both(pose, "Side", pa(d + jx, 0, 0, 0, 0, 0))
	pose.Rear = pa(0, 0, d, 0, 0, 0)
	pose.Face = pa(0, 0, -(1.4 * P - 0.3 * suck + breathe), 0, 0, 0)
	local fillOn = P > 0.3 and 0 or 1
	ctx.transparency("FillTop", fillOn)
	ctx.transparency("FillBot", fillOn)
	ctx.transparency("FillBelt", fillOn)

	-- spines pop out with a little stagger (and wiggle while puffed)
	for i, s in SPINES do
		local delay = ((i * 7) % 5) * 0.025
		local ps = puffAt(c - delay)
		local ext = (1.3 + s[3]) * ps - 0.4 * suck + 0.15 * panic * sin(TAU * (7 * c + i * 0.17))
		local dir = s[2]
		local cfR = CFrame.new(dir * ext)
		if s[4] then
			L.both(pose, s[1], cfR)
		else
			pose[s[1]] = cfR
		end
	end

	------------------------------------------------------------------
	-- CHEEKS: puff in & out at idle, balloon on the suck-in
	------------------------------------------------------------------
	local cp = 0.45 * L.wave01(t, 5 * F, 0.1) * idleW + 1.0 * suck
	L.both(pose, "Cheek", pa(0.5 * cp + 1.5 * P, -0.25 * P, -0.25 * cp - 1.3 * P, 0, 0, 0))
	local blushOn = max(embar, shy * 1.3) > 0.3
	for _, side in { "R", "L" } do
		ctx.transparency("BlushBig" .. side, blushOn and 0 or 1)
		for k = 1, 3 do
			ctx.transparency("BlushLine" .. side .. k, (blushOn and embar > 0.3) and 0 or 1)
		end
	end

	------------------------------------------------------------------
	-- EYES: googly bulge, nervous pupils, blinks, half lids
	------------------------------------------------------------------
	local pop = max(startle, 0.7 * hic, 0.8 * eep, 0.5 * peek)
	local eyeWob = 5 * wave(t, 23 * F) * (0.4 + panic)
	L.both(pose, "Eye", pa(0, 0.15 * pop, -0.6 * pop - 0.3 * Pc, 0, 0, eyeWob))

	-- pupils: nervous darting glances + jitter, look at the viewer when
	-- peeking, spin in circles in the panic
	local dart = math.clamp(3 * sin(TAU * 3 * F * t), -1, 1) * 0.3
	local px = (dart + 0.1 * L.noise(t, 5.1, 6)) * idleW
	local py = (-0.15 + 0.08 * L.noise(t, 8.2, 5)) * idleW
	local ang2 = TAU * 2.2 * (c - INFL)
	px += 0.38 * cos(ang2) * panic + 0.3 * peek * (1 - eep) + 0.25 * shyPeek
	px += -0.4 * hideL * (1 - peek)
	py += 0.38 * sin(ang2) * panic - 0.3 * hideL * (1 - peek) + 0.2 * startle
	pose.PupilR = CFrame.new(px, py, 0)
	pose.PupilL = CFrame.new(px - 0.7 * panic * cos(ang2), py, 0)
	local tiny = (c > STARTLE + 0.02 and c < PFFT + 0.35) or (c > EEP and c < EEP + 0.3) or (c > 2.66 and c < 2.85)
	for _, side in { "R", "L" } do
		ctx.transparency("PupilBig" .. side, tiny and 1 or 0)
		ctx.transparency("Glint" .. side, tiny and 1 or 0)
		ctx.transparency("PupilSmall" .. side, tiny and 0 or 1)
	end

	local blink = max(L.env(c, PFFT + 0.22, 0.05, 0.3, 0.12), L.env(c, SUCK + 0.15, 0.06, 0.15, 0.08))
	for _, b in BLINKS do
		blink = max(blink, L.env(c, b, 0.06, 0.06, 0.1))
	end
	L.both(pose, "Lid", CFrame.new(0, 1.2 * (1 - blink), 0))
	local lidOn = blink > 0.35 and 0 or 1
	for _, side in { "R", "L" } do
		ctx.transparency("Lid" .. side, lidOn)
		ctx.transparency("Lash" .. side, lidOn)
		ctx.transparency("LashA" .. side, lidOn)
		ctx.transparency("LashB" .. side, lidOn)
	end

	-- worried brows: always a bit worried, shoot up on frights
	local fright = max(startle, panic, hic, eep)
	local browUp = 0.55 * fright + 0.25 * peek + 0.1 * wave(t, 7 * F) * idleW
	L.both(pose, "Brow", pa(0, browUp, -0.1 * fright, 0, 0, -10 * fright - 8 * embar + 4 * wave(t, 7 * F, 0.3) * idleW))

	------------------------------------------------------------------
	-- LIPS: pucker on the suck-in, flubbering "pfft"
	------------------------------------------------------------------
	local flub = pfft * sin(TAU * 14 * (c - PFFT))
	local gulp = L.wave01(t, 5 * F, 0.6) * idleW
	pose.Lips = pa(0.08 * flub, -0.1 * fright, -0.55 * suck - 0.6 * pfft - 0.25 * Pc - 0.15 * gulp,
		10 * flub - 6 * suck, 0, 14 * flub)

	------------------------------------------------------------------
	-- FINS: buzzing flutter, flare on frights, hide the face, peek
	------------------------------------------------------------------
	local buzz = wave(t, 40 * F)
	local function fin(hide, side)
		local fl = 14 * buzz * (1 - 0.6 * hide) + 30 * Pc * wave(t, 70 * F)
		local y = 165 * hide - 25 * startle + 10 * wave(t, 5 * F, side) * idleW
		local z = fl + 50 * startle + 25 * Pc + 10 * hide + 20 * eep + 30 * pfft
		local x = 12 * hide
		local tipY = 98 * hide + 12 * wave(t, 40 * F, 0.15) * (1 - hide) - 20 * Pc
		-- hide: the fins swing to the front AND drop down so they cover the
		-- mouth + cheeks while the big worried eyes peek out over the top
		return pa(0.4 * hide, -2.0 * hide, 0, x, y, z), ang(0, tipY, 10 * wave(t, 40 * F, 0.2))
	end
	local fR, tR = fin(max(hideR, shy * (1 - shyPeek)), 0)
	local fL, tL = fin(max(hideL, shy), 0.25)
	pose.FinR, pose.FinL = fR, L.mirror(fL)
	pose.FinTipR, pose.FinTipL = tR, L.mirror(tL)

	local fb = wave(t, 50 * F)
	pose.Dorsal = ang(8 * wave(t, 20 * F), 22 * fb, 0)
	pose.Anal = ang(-8 * wave(t, 20 * F), -22 * fb, 0)

	-- tail swish (+ frantic wag while puffed, streaming on the zip)
	local tw = 18 * wave(t, 10 * F) * idleW + 40 * panic * sin(TAU * 4 * c) + 28 * wob * sin(TAU * 3 * (c - PFFT))
		+ 25 * hideAll * wave(t, 20 * F)
	pose.Tail = ang(-12 * pfft, tw, 0)
	pose.TailFin = ang(0, 0.8 * tw + 12 * wave(t, 10 * F, -0.2), 0)

	------------------------------------------------------------------
	-- CROWN: jaunty wobble, pops up on the inflate, askew when embarrassed
	------------------------------------------------------------------
	local crownPop = L.env(c, INFL + 0.08, 0.12, 0.1, 0.6, "backOut", "bounceOut")
	local spinCrown = L.track(c, { { INFL + 0.1, 0 }, { INFL + 0.8, 360, "cubicOut" } })
	pose.Crown = pa(0, 1.4 * crownPop + 0.5 * startle, 0,
		4 * wave(t, 5 * F, 0.4) + 10 * wob * wobble, spinCrown, 3 * wave(t, 5 * F, 0.1) + 14 * embar - 10 * startle)

	------------------------------------------------------------------
	-- "!" startle mark + sweat drop
	------------------------------------------------------------------
	local alertA = L.env(c, STARTLE, 0.08, 0.5, 0.1, "backOut", "quadIn")
	local alertB = L.env(c, EEP, 0.06, 0.4, 0.1, "backOut", "quadIn")
	local al = max(alertA, alertB)
	pose.Alert = pa(0, -1.5 * (1 - al), 0, 0, 0, -15 * sin(TAU * 6 * c) * al)
	ctx.transparency("Alert1", al > 0.05 and 0 or 1)
	ctx.transparency("Alert2", al > 0.05 and 0 or 1)
	local sweatOn = embar > 0.3 or shy > 0.4
	local su = ((c - 0.5) % 1.3) / 1.3
	pose.Sweat = CFrame.new(0, -1.4 * su, -0.1 * su)
	ctx.transparency("SweatA", sweatOn and (su > 0.8 and 0.6 or 0) or 1)
	ctx.transparency("SweatB", sweatOn and (su > 0.8 and 0.6 or 0) or 1)

	------------------------------------------------------------------
	-- floating marble cubes: bob + tumble, flung out by the inflate
	------------------------------------------------------------------
	local jolt = L.env(c, INFL + 0.05, 0.12, 0.3, 0.9, "quadOut", "elasticOut")
	for i = 1, 4 do
		local od = CUBES[i]
		local out = 2.4 * jolt + 1.2 * pfft
		local dx = 0.7 * wave(t, 2 * F, i * 0.21) + out * od[1]
		local dy = 0.9 * wave(t, 4 * F, i * 0.27) + by * 0.4
		local dz = 0.7 * wave(t, 2 * F, i * 0.21 + 0.25) - out * 0.5 * od[2]
		local s = i % 2 == 0 and -1 or 1
		pose["Cube" .. i] = pa(dx, dy, dz, 360 * 2 * F * t * s + 30 * i, 360 * 3 * F * t, 25 * i + 120 * jolt * s)
	end

	------------------------------------------------------------------
	-- voxel bubbles: little burps at idle, a jet stream on the "pfft"
	------------------------------------------------------------------
	for k = 1, 5 do
		local cfk, tr = CFrame.new(), 1
		local u = (c - PFFT - (k - 1) * 0.07) / 0.9
		if u > 0 and u < 1 then
			local e = L.ease.cubicOut(u)
			cfk = pa(0.6 * sin(TAU * (2 * u + k * 0.3)), by + 1.5 * u + 0.3 * (k - 3), bz - 8 * e, 0, 120 * u, 45)
			tr = u > 0.8 and 0.7 or 0.25
		else
			-- idle burps (two per loop, before the move and after settling)
			for _, b0 in { 0.2, 2.0 } do
				local ub = (c - b0 - (k - 1) * 0.18) / 1.3
				if ub > 0 and ub < 1 and k <= 3 then
					cfk = pa(0.5 * sin(TAU * (1.5 * ub + k * 0.3)), by + 4.5 * ub, -0.6 - 2.6 * ub, 0, 90 * ub, 45)
					tr = ub > 0.85 and 0.8 or 0.35
				end
			end
		end
		pose["Bub" .. k] = cfk
		ctx.transparency("BubP" .. k, tr)
	end

	------------------------------------------------------------------
	-- effects on the beats
	------------------------------------------------------------------
	if ctx.crossed(STARTLE) then
		ctx.emit("StartleBurst", 16)
	end
	if ctx.crossed(INFL + 0.12) then
		ctx.emit("PuffBurst", 45)
		ctx.emit("MarbleChips", 16)
	end
	if ctx.crossed(5.05) then
		ctx.emit("Sparkle", 12)
	end
	if ctx.crossed(PFFT) then
		ctx.emit("Pfft", 40)
		ctx.emit("PuffBurst", 14)
	end
	if ctx.crossed(EEP) then
		ctx.emit("StartleBurst", 8)
	end
	if ctx.crossed(2.66) then
		ctx.emit("Pfft", 6)
	end
	ctx.light("PuffLight", min(1.5, 0.3 + 1.1 * max(jolt, pfft * 0.6)))
end

return M
