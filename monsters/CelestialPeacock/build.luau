--!nocheck
-- Celestial Peacock: a chunky stud-built holy peacock. White plastic body with
-- cream shading, gold + deep-gold accents, a gold block halo, and a huge stepped
-- voxel tail fan whose pointed feathers each carry a stepped diamond "eye" with
-- a tiny neon-gold core. Calm glow: neon only on eyes/tips/small gems.
-- Signature move: FAN DISPLAY (fold + crouch -> SNAP open -> strut + rattle).
return {
	DisplayName = "Celestial Peacock",
	Rarity = "Divine",
	Element = "Holy",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local WHITE, CREAM, GOLD, DGOLD = "#f4f2ec", "#e2d6bd", "#f2b632", "#c98a1c"
		local BLACK, ROSE, PINK, NEON = "#1a1620", "#e2677c", "#f5a3ad", "#ffd34d"

		------------------------------------------------------------------
		-- Body (pivot at the hips so the whole bird pitches + bounces)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 6.2, 0.6))
		B:block(body, v(5.4, 4.6, 6.4), cf(0, 7.6, 0.6), WHITE)
		B:block(body, v(4.4, 0.9, 5.2), cf(0, 10.3, 0.9), WHITE)
		B:block(body, v(4.4, 0.9, 5.0), cf(0, 4.95, 0.8), CREAM)
		-- stepped round chest
		B:block(body, v(4.6, 4.0, 1.0), cf(0, 7.9, -3.0), WHITE)
		B:block(body, v(3.4, 3.0, 0.8), cf(0, 7.7, -3.8), WHITE)
		B:block(body, v(3.8, 0.7, 0.8), cf(0, 5.55, -2.9), CREAM)
		-- rump under the fan
		B:block(body, v(4.4, 3.6, 1.0), cf(0, 7.8, 4.2), WHITE)
		-- stepped cream scale plates on the back
		B:block(body, v(3.4, 0.35, 1.2), cf(0, 10.9, 0.3), CREAM)
		B:block(body, v(2.4, 0.35, 1.0), cf(0, 10.9, 2.0), CREAM)
		-- cream shading panels low on the flanks
		B:sym(function()
			B:block(body, v(0.4, 2.4, 5.2), cf(2.85, 6.2, 1.0), CREAM)
		end)
		-- golden chest V (stepped) with a small glowing diamond
		local vrows = { { 8.8, 1.3 }, { 8.1, 0.9 }, { 7.4, 0.5 } }
		for _, r in vrows do
			B:sym(function()
				B:block(body, v(0.8, 0.75, 0.4), cf(r[2], r[1], -4.3), GOLD)
			end)
		end
		B:block(body, v(1.0, 0.75, 0.4), cf(0, 6.7, -4.3), GOLD)
		B:block(body, v(1.25, 1.25, 0.2), cf(0, 8.25, -4.25, 0, 0, 45), DGOLD)
		B:gem(body, v(0.7, 0.7, 0.2), cf(0, 8.25, -4.4, 0, 0, 45), NEON, { name = "ChestGem" })
		local aura = B:block(body, v(5, 4, 6), cf(0, 8, 0.6), WHITE, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "BodySparkle", color = { "#ffffff", NEON }, rate = 3 })

		------------------------------------------------------------------
		-- Neck (visible, stepped) + big cartoon head
		------------------------------------------------------------------
		local neck = B:bone("Neck", "Body", v(0, 9.8, -2.0))
		B:block(neck, v(3.2, 2.4, 3.0), cf(0, 10.9, -2.3), WHITE)
		B:block(neck, v(2.6, 2.4, 2.4), cf(0, 12.5, -2.7), WHITE)
		B:block(neck, v(1.9, 3.2, 0.4), cf(0, 11.8, -4.0), CREAM)
		B:block(neck, v(3.5, 0.5, 3.3), cf(0, 10.15, -2.3), GOLD)

		local H = 0.4 -- head lift above the original layout
		local function hc(x, y, z, rx, ry, rz) return cf(x, y + H, z, rx, ry, rz) end
		local head = B:bone("Head", "Neck", v(0, 12.4 + H, -2.8))
		B:block(head, v(4.6, 3.8, 4.4), hc(0, 14.3, -3.6), WHITE)
		B:block(head, v(3.8, 0.8, 3.6), hc(0, 16.55, -3.4), WHITE)
		B:block(head, v(3.8, 3.0, 0.8), hc(0, 14.4, -1.1), WHITE)
		B:sym(function()
			-- cheek shading + gold face stripe running back from the eye
			B:block(head, v(0.4, 1.6, 2.8), hc(2.35, 13.3, -3.2), CREAM)
			B:block(head, v(0.35, 0.45, 2.6), hc(2.38, 15.0, -2.6), GOLD)
			-- big cartoon eye: gold rim, white, black pupil, tiny neon highlight
			B:block(head, v(1.8, 2.1, 0.2), hc(1.2, 14.7, -5.85), DGOLD)
			B:block(head, v(1.4, 1.7, 0.2), hc(1.2, 14.7, -5.98), WHITE)
			B:block(head, v(0.9, 1.2, 0.2), hc(1.05, 14.6, -6.1), BLACK)
			B:gem(head, v(0.35, 0.35, 0.1), hc(1.25, 14.95, -6.23), NEON, { name = "EyeShine" })
			-- heavy gold brow
			B:block(head, v(1.8, 0.5, 0.7), hc(1.25, 16.0, -5.8, 0, 0, 8), GOLD)
			-- rosy cartoon blush
			B:block(head, v(0.9, 0.4, 0.12), hc(1.55, 13.35, -5.86), PINK)
		end)
		-- stepped gold beak: base, ridge, mid step, hooked wedge tip
		B:block(head, v(1.8, 1.0, 1.4), hc(0, 13.65, -6.45), GOLD)
		B:block(head, v(0.8, 0.35, 1.8), hc(0, 14.25, -6.6), DGOLD)
		B:block(head, v(1.3, 0.85, 0.9), hc(0, 13.55, -7.55), GOLD)
		B:wedge(head, v(1.0, 0.8, 0.9), hc(0, 13.5, -8.4), DGOLD)
		B:block(head, v(1.5, 0.3, 2.4), hc(0, 13.0, -6.7), BLACK)
		local beakFX = B:block(head, v(1.2, 0.8, 1.0), hc(0, 13.2, -8.6), WHITE, { tr = 1, name = "BeakFX" })
		B:emitter(beakFX, "burst", { name = "CallBurst", color = { "#ffffff", NEON }, size = { 0.6, 0.4, 0 }, speed = { 5, 10 } })

		-- eyelids (hidden inside the face, pop forward for cartoon blinks)
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(1.2, 14.7 + H, -5.6))
			B:block(lid, v(1.9, 2.2, 0.25), hc(1.2, 14.7, -5.55), WHITE)
			B:block(lid, v(1.9, 0.25, 0.3), hc(1.2, 14.45, -5.55), BLACK)
		end)

		-- lower beak
		local jaw = B:bone("Jaw", "Head", v(0, 13.0 + H, -5.6))
		B:block(jaw, v(1.6, 0.6, 2.2), hc(0, 12.45, -6.6), GOLD)
		B:block(jaw, v(1.0, 0.5, 0.8), hc(0, 12.5, -8.0), GOLD)
		B:block(jaw, v(1.2, 0.3, 2.0), hc(0, 12.05, -6.5), DGOLD)
		B:block(jaw, v(1.3, 0.15, 2.0), hc(0, 12.8, -6.6), BLACK)
		B:block(jaw, v(0.8, 0.2, 1.2), hc(0, 12.9, -6.4), ROSE)

		-- crest: three gold stalks fanning up, gold tips with tiny neon faces
		local crest = B:bone("Crest", "Head", v(0, 16.9 + H, -3.5))
		for k = -1, 1 do
			local base = v(k * 0.3, 16.8 + H, -3.7)
			local tip = v(k * 1.0, 17.95 + H - math.abs(k) * 0.3, -3.6 + math.abs(k) * 0.1)
			B:beam(crest, base, tip, 0.4, 0.4, DGOLD)
			B:block(crest, v(0.8, 0.8, 0.8), CFrame.new(tip) * ang(0, 0, -k * 18), GOLD)
			B:gem(crest, v(0.36, 0.36, 0.12), CFrame.new(tip + v(0, 0, -0.42)) * ang(0, 0, 45 - k * 18), NEON, { name = "CrestTip" })
		end

		-- halo: gold blocks with tiny neon squares on top (NOT a neon ring)
		local HC = CFrame.new(0, 19.15, -3.2) * ang(-14, 0, 0) -- tipped toward the viewer
		local halo = B:bone("Halo", "Head", HC)
		for i = 0, 9 do
			local a = (i / 10) * math.pi * 2
			local seg = HC * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -2.2)
			B:block(halo, v(1.4, 0.55, 0.6), seg, i % 2 == 0 and GOLD or DGOLD)
			if i % 2 == 0 then
				B:gem(halo, v(0.4, 0.12, 0.3), seg * CFrame.new(0, 0.32, 0), NEON, { name = "HaloGem" })
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
			B:block(wing, v(1.05, 0.5, 3.5), cf(3.18, 7.45, -0.1), GOLD)
			B:block(wing, v(0.9, 1.3, 3.6), cf(3.2, 6.6, 0.3), CREAM)
			B:block(wing, v(0.85, 0.6, 1.0), cf(3.2, 5.75, -0.9), GOLD)
			B:block(wing, v(0.85, 0.6, 1.0), cf(3.2, 5.75, 0.8), DGOLD)
			local tip = B:bone("WingTip" .. side, "Wing" .. side, v(3.2, 8.4, 1.3))
			B:block(tip, v(0.8, 1.8, 2.4), cf(3.2, 8.7, 2.5), WHITE)
			B:block(tip, v(0.75, 1.5, 2.4), cf(3.15, 7.1, 2.8), CREAM)
			B:block(tip, v(0.8, 1.6, 0.9), cf(3.2, 8.7, 4.1), GOLD)
			B:block(tip, v(0.7, 1.3, 0.9), cf(3.15, 7.1, 4.35), DGOLD)
			B:trail(tip, v(3.2, 9.4, 4.4), v(3.2, 6.6, 4.6), { name = "WingTrail" .. side, color = { "#ffffff", NEON }, life = 0.22, trans = { 0.45, 1 } })
		end)

		------------------------------------------------------------------
		-- Legs: feathered thighs, gold shins, chunky gold toes + white claws
		------------------------------------------------------------------
		B:sym(function(side)
			local thigh = B:bone("Thigh" .. side, "Body", v(1.8, 5.6, 1.0))
			B:block(thigh, v(2.0, 2.0, 2.2), cf(1.8, 4.6, 1.1), CREAM)
			B:block(thigh, v(1.6, 0.6, 1.8), cf(1.8, 3.55, 1.25), WHITE)
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
		-- Each feather: white shaft + vane, stepped gold leaf plume, pointed
		-- deep-gold tip, stepped diamond "eye" (white > deep gold > tiny neon).
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
			B:block(fb, v(0.8, 4.8 * s, 0.45), at(0, 3.6, 0.05), WHITE)
			B:block(fb, v(2.0 * w, 3.2 * s, 0.4), at(0, 3.8, 0.12), alt)
			B:block(fb, v(1.8 * w, 0.9 * s, 0.5), at(0, 5.1, 0), GOLD)
			B:block(fb, v(2.6 * w, 1.0 * s, 0.5), at(0, 6.0, 0), GOLD)
			B:block(fb, v(3.0 * w, 1.7 * s, 0.5), at(0, 7.35, 0), GOLD)
			B:block(fb, v(2.3 * w, 0.9 * s, 0.5), at(0, 8.6, 0), GOLD)
			B:block(fb, v(1.4 * w, 0.7 * s, 0.5), at(0, 9.35, 0), DGOLD)
			local normal = F.LookVector * -1
			B:spike(fb, at(0, 9.55, 0).Position, at(0, 10.9, 0).Position, 1.0 * w, 0.5, GOLD, { up = normal })
			-- white diamond on the back so the rear view keeps the pattern
			B:block(fb, v(1.5 * w, 1.5 * w, 0.2), at(0, 7.35, 0.32, 45), WHITE)
			-- stepped diamond eye
			B:block(fb, v(1.7 * w, 1.7 * w, 0.3), at(0, 7.35, -0.3, 45), WHITE)
			B:block(fb, v(1.05 * w, 1.05 * w, 0.2), at(0, 7.35, -0.48, 45), DGOLD)
			B:gem(fb, v(0.5, 0.5, 0.12), at(0, 7.35, -0.62, 45), NEON, { name = "FeatherEye" })
			if i == 1 or i == 6 or i == NF then
				B:trail(fb, at(0, 8.8, 0).Position, at(0, 10.9, 0).Position,
					{ name = "FanTrail" .. i, color = { "#ffffff", NEON }, life = 0.25, trans = { 0.5, 1 } })
			end
		end

		------------------------------------------------------------------
		-- Voxel confetti: 8 hidden cubes that burst out of the fan on the snap
		------------------------------------------------------------------
		for k = 1, 8 do
			local sp = B:bone("Confetti" .. k, "Body", v(0, 12.5, 2.6))
			local sz = k % 2 == 0 and 0.9 or 1.15
			B:block(sp, v(sz, sz, sz), cf(0, 12.5, 2.6), k % 3 == 0 and WHITE or GOLD, { tr = 1, name = "Confetti" .. k })
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
			B:block(ob, v(sz + 0.08, sz * 0.2, sz + 0.08), cf(p[1], p[2], p[3]), gold and WHITE or GOLD)
			B:gem(ob, v(0.35, 0.35, 0.35), cf(p[1], p[2] + sz * 0.5 + 0.1, p[3]), NEON, { name = "OrbGem" })
		end
	end,
}
