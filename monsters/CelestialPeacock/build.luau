--!nocheck
-- Celestial Peacock: a chunky stud-built holy peacock. White plastic body with
-- cream + tan two-tone shading, gold + deep-gold accents, a pixel-ring halo of
-- gold blocks, and a huge stepped voxel tail fan whose pointed feathers each
-- carry a stepped diamond "peacock eye" (white > royal teal > tiny pale-gold
-- neon core). Calm glow: neon only on eye shines, tips and small gems.
-- Signature move: FAN DISPLAY (fold + crouch -> SNAP open with a hidden
-- sunburst that shoots out behind the fan -> landing shockwave -> strut).
return {
	DisplayName = "Celestial Peacock",
	Rarity = "Divine",
	Element = "Holy",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local WHITE, CREAM, TAN = "#f4f2ec", "#e2d6bd", "#c9ad7f"
		local GOLD, DGOLD, TEAL = "#f2b632", "#c98a1c", "#2a8fb8"
		local BLACK, ROSE, PINK = "#1a1620", "#e2677c", "#f5a3ad"
		local NEON = "#fff0a8" -- the ONE neon accent: pale gold-white (pops on gold)

		------------------------------------------------------------------
		-- Body (pivot at the hips so the whole bird pitches + bounces)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 6.2, 0.6))
		B:block(body, v(5.4, 4.6, 6.4), cf(0, 7.6, 0.6), WHITE)
		B:block(body, v(4.4, 0.9, 5.2), cf(0, 10.3, 0.9), WHITE)
		B:block(body, v(4.4, 0.9, 5.0), cf(0, 4.95, 0.8), TAN)
		-- chest base + stepped breast-feather rows (alternating white / cream)
		B:block(body, v(4.6, 4.4, 1.0), cf(0, 8.0, -3.0), WHITE)
		local rows = { { 6.4, 2.6 }, { 7.3, 3.6 }, { 8.2, 4.2 }, { 9.1, 3.6 }, { 10.0, 2.6 } }
		for i, r in rows do
			B:block(body, v(r[2], 0.9, 0.8), cf(0, r[1], -3.55 - (i % 2) * 0.25), i % 2 == 0 and CREAM or WHITE)
		end
		-- rump under the fan
		B:block(body, v(4.4, 3.6, 1.0), cf(0, 7.8, 4.2), WHITE)
		-- stepped cream scale plates on the back
		B:block(body, v(3.4, 0.35, 1.2), cf(0, 10.9, 0.3), CREAM)
		B:block(body, v(2.4, 0.35, 1.0), cf(0, 10.9, 2.0), CREAM)
		-- two-tone flanks: tan low panel + cream step
		B:sym(function()
			B:block(body, v(0.4, 2.2, 5.6), cf(2.85, 6.1, 1.0), TAN)
			B:block(body, v(0.3, 0.8, 4.4), cf(2.82, 7.6, 1.6), CREAM)
		end)
		-- golden chest V (stepped) with a glowing diamond gem
		local vrows = { { 8.8, 1.3 }, { 8.1, 0.9 }, { 7.4, 0.5 } }
		for _, r in vrows do
			B:sym(function()
				B:block(body, v(0.8, 0.75, 0.8), cf(r[2], r[1], -4.3), GOLD)
			end)
		end
		B:block(body, v(1.0, 0.75, 0.8), cf(0, 6.7, -4.3), GOLD)
		B:block(body, v(1.25, 1.25, 0.3), cf(0, 8.25, -4.75, 0, 0, 45), DGOLD)
		B:gem(body, v(0.7, 0.7, 0.2), cf(0, 8.25, -4.95, 0, 0, 45), NEON, { name = "ChestGem" })
		local aura = B:block(body, v(5, 4, 6), cf(0, 8, 0.6), WHITE, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "BodySparkle", color = { "#ffffff", NEON }, rate = 3 })

		------------------------------------------------------------------
		-- Neck (visible, stepped) + big cartoon head
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Body", v(0, 9.8, -2.0))
		B:block(neck, v(3.2, 2.4, 3.0), cf(0, 10.9, -2.3), WHITE)
		B:block(neck, v(3.2, 2.4, 2.6), cf(0, 12.5, -2.7), WHITE)
		B:block(neck, v(1.9, 3.2, 0.4), cf(0, 11.8, -4.05), CREAM)
		B:block(neck, v(3.5, 0.5, 3.3), cf(0, 10.15, -2.3), GOLD)

		local H = 0.4 -- head lift above the original layout
		local function hc(x, y, z, rx, ry, rz) return cf(x, y + H, z, rx, ry, rz) end
		local head = B:bone("Head", "Neck", v(0, 12.4 + H, -2.8))
		B:block(head, v(4.6, 3.8, 4.4), hc(0, 14.3, -3.6), WHITE)
		B:block(head, v(3.8, 0.8, 3.6), hc(0, 16.55, -3.4), WHITE)
		B:block(head, v(3.8, 3.0, 0.8), hc(0, 14.4, -1.1), WHITE)
		-- throat / wattle so the head never reads as a box on a stick
		B:block(head, v(3.4, 1.0, 2.6), hc(0, 12.6, -3.6), CREAM)
		B:sym(function()
			-- cheek shading + gold face stripe running back from the eye
			B:block(head, v(0.4, 1.6, 2.4), hc(2.35, 13.3, -3.0), CREAM)
			B:block(head, v(0.35, 0.45, 2.6), hc(2.38, 15.0, -2.6), GOLD)
			-- BIG cartoon eye wrapped round the front corner of the head so it
			-- reads from the front AND the side: gold rim, white, black pupils
			B:block(head, v(1.9, 2.2, 1.6), hc(1.55, 14.7, -5.2), DGOLD)
			B:block(head, v(1.6, 1.8, 1.4), hc(1.78, 14.7, -5.38), WHITE)
			B:block(head, v(0.9, 1.25, 0.12), hc(1.55, 14.55, -6.1), BLACK) -- front pupil
			B:block(head, v(0.12, 1.25, 0.8), hc(2.6, 14.55, -5.45), BLACK) -- side pupil
			B:gem(head, v(0.35, 0.35, 0.1), hc(1.8, 14.95, -6.16), NEON, { name = "EyeShine" })
			B:gem(head, v(0.1, 0.35, 0.35), hc(2.66, 14.95, -5.65), NEON, { name = "EyeShineSide" })
			-- heavy gold brow, also wrapped round the corner
			B:block(head, v(2.1, 0.5, 1.7), hc(1.6, 16.0, -5.25, 0, 0, 10), GOLD)
			-- rosy cartoon blush (front + side)
			B:block(head, v(0.9, 0.4, 0.12), hc(1.4, 13.35, -5.86), PINK)
			B:block(head, v(0.12, 0.4, 0.9), hc(2.58, 13.4, -3.9), PINK)
		end)
		-- narrow hooked gold beak: base, ridge, mid step, hooked wedge tip
		B:block(head, v(1.5, 1.0, 1.2), hc(0, 13.65, -6.35), GOLD)
		B:block(head, v(0.7, 0.35, 1.6), hc(0, 14.2, -6.5), DGOLD)
		B:block(head, v(1.0, 0.8, 0.8), hc(0, 13.6, -7.3), GOLD)
		B:wedge(head, v(0.8, 0.8, 0.8), hc(0, 13.45, -7.95, -20, 0, 0), DGOLD)
		B:block(head, v(1.3, 0.3, 1.9), hc(0, 13.05, -6.6), BLACK)
		-- silly bird teeth (a brain-rot staple)
		B:sym(function()
			B:block(head, v(0.3, 0.35, 0.3), hc(0.5, 12.95, -6.55), WHITE)
			B:block(head, v(0.3, 0.35, 0.3), hc(0.32, 12.95, -7.4), WHITE)
		end)
		local beakFX = B:block(head, v(1.2, 0.8, 1.0), hc(0, 13.2, -8.6), WHITE, { tr = 1, name = "BeakFX" })
		B:emitter(beakFX, "burst", { name = "CallBurst", color = { "#ffffff", NEON }, size = { 0.6, 0.4, 0 }, speed = { 5, 10 } })

		-- eyelids: hidden, shown (and slid down) only while blinking
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(1.6, 15.8 + H, -5.3))
			B:block(lid, v(2.05, 2.3, 1.75), hc(1.62, 14.75, -5.3), WHITE, { tr = 1, name = "Eyelid" .. side })
			B:block(lid, v(2.1, 0.25, 1.8), hc(1.62, 13.62, -5.3), BLACK, { tr = 1, name = "Lash" .. side })
		end)

		-- lower beak
		local jaw = B:bone("Jaw", "Head", v(0, 13.0 + H, -5.6))
		B:block(jaw, v(1.3, 0.6, 2.2), hc(0, 12.45, -6.6), GOLD)
		B:block(jaw, v(0.8, 0.5, 0.8), hc(0, 12.5, -7.95), GOLD)
		B:block(jaw, v(1.0, 0.3, 2.0), hc(0, 12.05, -6.5), DGOLD)
		B:block(jaw, v(1.1, 0.15, 2.0), hc(0, 12.8, -6.6), BLACK)
		B:block(jaw, v(0.7, 0.2, 1.2), hc(0, 12.9, -6.4), ROSE)

		-- crest: three gold stalks fanning up and back, staggered in depth
		local crest = B:bone("Crest", "Head", v(0, 16.9 + H, -3.5))
		for k = -1, 1 do
			local bz = -3.6 + k * 0.3
			local base = v(k * 0.3, 16.8 + H, bz)
			local tip = v(k * 1.1, 18.25 + H - math.abs(k) * 0.35, bz + 0.45)
			B:beam(crest, base, tip, 0.4, 0.4, DGOLD)
			B:block(crest, v(0.8, 0.8, 0.8), CFrame.new(tip) * ang(15, 0, -k * 18), GOLD)
			B:gem(crest, v(0.36, 0.36, 0.12), CFrame.new(tip) * ang(15, 0, -k * 18) * CFrame.new(0, 0, -0.42) * ang(0, 0, 45), NEON, { name = "CrestTip" })
		end

		-- halo: an axis-aligned PIXEL ring (5x5 outline, corners removed) of
		-- gold/deep-gold blocks with tiny neon squares on the 4 cardinal blocks
		local HC = CFrame.new(0, 20.4, -1.9) * ang(-28, 0, 0)
		local halo = B:bone("Halo", "Head", HC)
		local ring = {
			{ 0, -2, true }, { 1, -2 }, { 2, -1 }, { 2, 0, true }, { 2, 1 }, { 1, 2 },
			{ 0, 2, true }, { -1, 2 }, { -2, 1 }, { -2, 0, true }, { -2, -1 }, { -1, -2 },
		}
		for i, o in ring do
			local seg = HC * CFrame.new(o[1], 0, o[2])
			B:block(halo, v(1, 0.6, 1), seg, i % 2 == 0 and DGOLD or GOLD)
			if o[3] then
				B:gem(halo, v(0.4, 0.12, 0.4), seg * CFrame.new(0, 0.34, 0), NEON, { name = "HaloGem" })
			end
		end
		local haloFX = B:block(halo, v(4.6, 0.4, 4.6), HC, WHITE, { tr = 1, name = "HaloFX" })
		B:emitter(haloFX, "sparkle", { name = "HaloSparkle", color = { "#ffffff", NEON }, rate = 2 })
		B:light(haloFX, { name = "HaloLight", color = "#ffe7a6", brightness = 0.6, range = 9 })

		------------------------------------------------------------------
		-- Wings (folded on the flanks; two bones each for follow-through)
		------------------------------------------------------------------
		B:sym(function(side)
			local wing = B:bone("Wing" .. side, "Body", v(2.7, 9.8, -1.4))
			B:block(wing, v(1.0, 2.6, 3.4), cf(3.15, 8.8, -0.2), WHITE)
			-- covert rows (cream / tan), stepped back
			B:block(wing, v(1.05, 0.6, 3.0), cf(3.2, 9.3, -0.1), CREAM)
			B:block(wing, v(1.05, 0.6, 3.0), cf(3.22, 8.6, 0.25), TAN)
			B:block(wing, v(1.05, 0.5, 3.5), cf(3.18, 7.45, -0.1), GOLD)
			B:block(wing, v(0.9, 1.3, 3.6), cf(3.2, 6.6, 0.3), TAN)
			B:block(wing, v(0.85, 0.6, 1.0), cf(3.2, 5.75, -0.9), GOLD)
			B:block(wing, v(0.85, 0.6, 1.0), cf(3.2, 5.75, 0.8), DGOLD)
			-- stepped primaries: three staggered feathers + a deep-gold tip cube
			local tip = B:bone("WingTip" .. side, "Wing" .. side, v(3.2, 8.4, 1.3))
			B:block(tip, v(0.7, 1.2, 3.2), cf(3.2, 8.9, 3.0), WHITE)
			B:block(tip, v(0.7, 1.2, 2.6), cf(3.18, 8.0, 2.7), CREAM)
			B:block(tip, v(0.7, 1.2, 2.0), cf(3.16, 7.1, 2.4), GOLD)
			B:block(tip, v(0.75, 0.7, 0.7), cf(3.2, 9.15, 4.5), DGOLD)
			B:trail(tip, v(3.2, 9.4, 4.4), v(3.2, 6.6, 3.4), { name = "WingTrail" .. side, color = { "#ffffff", NEON }, life = 0.22, trans = { 0.45, 1 } })
		end)

		------------------------------------------------------------------
		-- Legs: tan feathered thighs, gold shins, chunky gold toes + white claws
		------------------------------------------------------------------
		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Body", v(1.8, 5.6, 1.0))
			B:block(thigh, v(2.0, 2.0, 2.2), cf(1.8, 4.6, 1.1), TAN)
			B:block(thigh, v(1.6, 0.6, 1.8), cf(1.8, 3.55, 1.25), CREAM)
			local shin = B:bone("Shin" .. side, "Thigh" .. side, v(1.8, 3.6, 1.4))
			B:block(shin, v(1.2, 1.0, 1.2), cf(1.8, 3.5, 1.4), DGOLD)
			B:beam(shin, v(1.8, 3.4, 1.35), v(1.8, 0.9, 0.7), 0.9, 0.9, GOLD)
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(1.8, 0.8, 0.7))
			B:block(foot, v(1.3, 0.8, 1.3), cf(1.8, 0.6, 0.7), DGOLD)
			local toes = { v(1.8, 0.35, -1.5), v(2.9, 0.35, -1.0), v(0.75, 0.35, -1.0), v(1.8, 0.35, 2.1) }
			for _, tp in toes do
				local from = v(1.8, 0.35, 0.6)
				B:beam(foot, from, tp, 0.7, 0.7, GOLD)
				local dir = (tp - from).Unit
				local ccf = P.span(tp - dir * 0.1, tp + dir * 0.75)
				B:wedge(foot, v(0.55, 0.6, 0.85), ccf * CFrame.new(0, -0.05, 0), WHITE)
			end
		end)
		local dustAt = B:block("Root", v(6, 0.2, 5), cf(0, 0.1, 0.6), WHITE, { tr = 1, name = "DustFX" })
		B:emitter(dustAt, "dust", { name = "StepDust", color = "#e8dcc4" })

		------------------------------------------------------------------
		-- Tail fan: 11 radiating feather bones off a tilted fan root.
		-- Each feather: white/cream vane, stepped gold plume ringed in deep
		-- gold, pointed tip with a tiny neon bead, and a stepped diamond
		-- PEACOCK EYE (white > royal teal > pale-gold neon core).
		------------------------------------------------------------------
		local NF, SPREAD, CUP = 11, 85, 7 -- keep in sync with motion.luau
		local FR = CFrame.new(0, 7.6, 4.8) * ang(16, 0, 0)
		local fan = B:bone("FanRoot", "Body", FR)
		B:block(fan, v(4.4, 3.4, 1.4), FR * CFrame.new(0, 0.8, 0), WHITE)
		B:block(fan, v(3.2, 2.2, 1.0), FR * CFrame.new(0, 0.3, 0.9), CREAM)
		B:block(fan, v(4.5, 0.5, 1.5), FR * CFrame.new(0, 2.2, 0), GOLD)
		local fanFX = B:block(fan, v(19, 9, 1), FR * CFrame.new(0, 6.5, 0.3), WHITE, { tr = 1, name = "FanFX" })
		B:emitter(fanFX, "sparkle", { name = "FanShimmer", color = { "#ffffff", NEON }, rate = 30, enabled = false })
		B:emitter(fanFX, "burst", { name = "FanBurst", color = { "#ffffff", NEON, GOLD } })
		B:emitter(fanFX, "leaf", { name = "FeatherFall", color = { GOLD, "#ffffff" }, rate = 6, size = { 0.5, 0.45, 0.3 }, enabled = false })
		B:light(fanFX, { name = "FanLight", color = "#ffe7a6", brightness = 0, range = 16 })

		for i = 1, NF do
			local a = -SPREAD + (i - 1) * (2 * SPREAD / (NF - 1))
			local u = math.abs(a) / SPREAD
			local cup = CUP * u
			local Lf = 10.9 - 1.6 * u * u
			local s = Lf / 10
			local w = 0.55 + 0.45 * s
			local F = FR * ang(0, 0, a) * ang(-cup, 0, 0)
			local fb = B:bone("Feather" .. i, "FanRoot", F)
			local zo = (i % 2 == 0) and 0.22 or 0
			local function at(x, y, z, rz)
				return F * CFrame.new(x, y * s, z + zo) * ang(0, 0, rz or 0)
			end
			local alt = (i % 2 == 0) and CREAM or WHITE
			B:block(fb, v(2.0 * w, 3.8 * s, 0.4), at(0, 3.4, 0.12), alt)
			B:block(fb, v(1.8 * w, 0.9 * s, 0.5), at(0, 5.1, 0), GOLD)
			B:block(fb, v(2.6 * w, 1.0 * s, 0.5), at(0, 6.0, 0), DGOLD)
			B:block(fb, v(3.0 * w, 1.7 * s, 0.5), at(0, 7.35, 0), GOLD)
			B:block(fb, v(2.3 * w, 0.9 * s, 0.5), at(0, 8.6, 0), DGOLD)
			local normal = F.LookVector * -1
			B:spike(fb, at(0, 8.95, 0).Position, at(0, 10.9, 0).Position, 1.0 * w, 0.5, GOLD, { up = normal })
			B:gem(fb, v(0.35, 0.35, 0.35), at(0, 10.55, 0), NEON, { name = "FeatherTip" })
			-- white diamond on the back so the rear view keeps the pattern
			B:block(fb, v(1.5 * w, 1.5 * w, 0.2), at(0, 7.35, 0.32, 45), WHITE)
			-- stepped peacock eye
			B:block(fb, v(1.7 * w, 1.7 * w, 0.3), at(0, 7.35, -0.3, 45), WHITE)
			B:block(fb, v(1.15 * w, 1.15 * w, 0.2), at(0, 7.35, -0.48, 45), TEAL)
			B:gem(fb, v(0.6, 0.6, 0.12), at(0, 7.35, -0.62, 45), NEON, { name = "FeatherEye" })
			if i == 1 or i == 6 or i == NF then
				B:trail(fb, at(0, 8.8, 0).Position, at(0, 10.9, 0).Position,
					{ name = "FanTrail" .. i, color = { "#ffffff", NEON }, life = 0.25, trans = { 0.5, 1 } })
			end
		end

		------------------------------------------------------------------
		-- SUNBURST (hidden): 10 white/pale-gold rays in the gaps between the
		-- feathers, behind the vanes. They shoot outward on the snap.
		------------------------------------------------------------------
		local FC = FR * CFrame.new(0, 1, 0.6)
		for k = 1, NF - 1 do
			local a = -SPREAD + (k - 0.5) * (2 * SPREAD / (NF - 1))
			local RC = FC * ang(0, 0, a)
			local rb = B:bone("Ray" .. k, "FanRoot", RC)
			local long = k % 2 == 1
			B:block(rb, v(long and 1.2 or 0.9, long and 4.4 or 3.2, 0.4), RC * CFrame.new(0, 3, 0.4), long and WHITE or "#ffe9a0", { tr = 1, name = "Ray" .. k })
			B:block(rb, v(0.6, 0.6, 0.44), RC * CFrame.new(0, 3 + (long and 2.4 or 1.8), 0.4) * ang(0, 0, 45), NEON, { mat = "Neon", tr = 1, name = "RayTip" .. k })
		end

		------------------------------------------------------------------
		-- Landing shockwave: ring of flat slabs that slides out from the feet
		------------------------------------------------------------------
		local SC = v(0, 0.2, 0.6)
		for k = 1, 10 do
			local a = (k - 1) / 10 * 360
			local sb = B:bone("Shock" .. k, "Root", SC)
			B:block(sb, v(2.6, 0.5, 1.0), CFrame.new(SC) * ang(0, a, 0) * CFrame.new(0, 0, -2.0), k % 2 == 0 and GOLD or CREAM, { tr = 1, name = "Wave" .. k })
		end

		------------------------------------------------------------------
		-- Voxel confetti: 8 hidden cubes that burst out of the fan on the snap
		------------------------------------------------------------------
		for k = 1, 8 do
			local sp = B:bone("Confetti" .. k, "Body", v(0, 12.5, 2.6))
			local sz = k % 2 == 0 and 0.9 or 1.15
			local col = k % 3 == 0 and WHITE or (k % 3 == 1 and GOLD or TEAL)
			B:block(sp, v(sz, sz, sz), cf(0, 12.5, 2.6), col, { tr = 1, name = "Confetti" .. k })
		end

		------------------------------------------------------------------
		-- Floating voxel cubes hovering around the bird (VFX)
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 6, 0.6))
		local spots = { { 6.6, 8.2, -3.8 }, { -7.4, 4.0, -1.0 }, { 7.6, 3.6, 1.4 }, { -6.2, 9.0, -4.4 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local sz = i % 2 == 0 and 1.1 or 1.4
			local gold = i == 2 or i == 3
			B:block(ob, v(sz, sz, sz), cf(p[1], p[2], p[3]), gold and GOLD or WHITE)
			B:block(ob, v(sz + 0.08, sz * 0.2, sz + 0.08), cf(p[1], p[2], p[3]), gold and WHITE or TEAL)
			B:gem(ob, v(0.35, 0.35, 0.35), cf(p[1], p[2] + sz * 0.5 + 0.1, p[3]), NEON, { name = "OrbGem" })
		end
	end,
}
