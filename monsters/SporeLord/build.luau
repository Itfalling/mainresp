--!nocheck
-- Spore Lord: a squat stud-built mushroom bruiser. Huge stepped magenta cap
-- with cream spots, warm two-tone stalk body (cream + toasted tan panels,
-- stepped belly plates, a magenta mushroom ring skirt), big black cartoon
-- mouth full of white block teeth, framed lime eyes, magenta boots/gloves,
-- little mushrooms sprouting from its back, floating pink/green voxel cubes,
-- an opaque voxel spore cloud and a landing shockwave for its SPORE BURST.
return {
	DisplayName = "Spore Lord",
	Rarity = "Epic",
	Element = "Fungus",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local MAIN, DARK = "#d63a6a", "#a8244f"
		local SPOT, GILL = "#fff3e2", "#f2d9c4"
		local STALK, STALK_DK, BELLY, FACE = "#f7e2bf", "#c99a6a", "#fff6e6", "#fbe9cc"
		local MOUTH, WHITE, TONGUE = "#1a0f17", "#ffffff", "#ff6f9a"
		local LIME, GREEN, BLUSH, PUPIL = "#b6ff5c", "#86cf45", "#ff7aa2", "#120c10"
		local PINK = "#ff8fb4"

		-- voxel "round" slab: two crossed blocks give a chamfered (pixel-circle) outline.
		-- the second block is a hair shorter so the shared top/bottom faces never z-fight.
		local function slab(bone, w, h, d, ch, x, y, z, color)
			B:block(bone, v(w, h, d - 2 * ch), cf(x, y, z), color)
			B:block(bone, v(w - 2 * ch, h - 0.06, d), cf(x, y, z), color)
		end

		local function cslab(bone, w, h, d, ch, x, y, z, color, xf)
			B:block(bone, v(w, h, d - 2 * ch), xf(x, y, z), color)
			B:block(bone, v(w - 2 * ch, h - 0.06, d), xf(x, y, z), color)
		end

		------------------------------------------------------------------
		-- Hips (lower stalk) + chest (upper stalk)
		------------------------------------------------------------------
		local hips = B:bone("Hips", "Root", v(0, 3.0, 0.5))
		slab(hips, 6.4, 2.6, 5.4, 0.8, 0, 3.6, 0.5, STALK)
		B:block(hips, v(3.0, 0.5, 3.6), cf(0, 2.15, 0.5), STALK_DK)
		-- Leviathan-style stepped belly plates on a toasted backing panel
		B:block(hips, v(4.2, 2.3, 0.3), cf(0, 3.35, -2.3), STALK_DK)
		B:block(hips, v(3.6, 0.7, 0.3), cf(0, 4.05, -2.5), BELLY)
		B:block(hips, v(2.8, 0.7, 0.3), cf(0, 3.3, -2.6), SPOT)
		B:block(hips, v(1.8, 0.6, 0.3), cf(0, 2.6, -2.5), BELLY)
		-- back panel + magenta freckles
		B:block(hips, v(4.4, 1.9, 0.3), cf(0, 3.5, 3.3), STALK_DK)
		B:block(hips, v(0.9, 0.9, 0.2), cf(-1.1, 3.75, 3.5), DARK)
		B:block(hips, v(0.6, 0.6, 0.2), cf(1.2, 3.1, 3.5), MAIN)
		B:sym(function()
			B:block(hips, v(0.3, 1.9, 2.8), cf(3.25, 3.5, 0.5), STALK_DK)
			B:block(hips, v(0.2, 0.8, 0.8), cf(3.45, 3.8, 1.2), DARK)
			B:block(hips, v(0.2, 0.5, 0.5), cf(3.45, 3.0, -0.2), MAIN)
		end)

		local chest = B:bone("Chest", "Hips", v(0, 4.8, 0.5))
		slab(chest, 5.8, 2.6, 4.8, 0.7, 0, 6.0, 0.5, STALK)
		B:block(chest, v(3.8, 1.8, 0.3), cf(0, 6.1, 2.95), STALK_DK)
		B:sym(function()
			B:block(chest, v(0.3, 1.6, 2.4), cf(2.95, 6.1, 0.5), STALK_DK)
		end)
		-- the mushroom RING (annulus): stepped magenta skirt round the waist
		B:block(chest, v(6.6, 0.5, 5.8), cf(0, 5.15, 0.5), DARK)
		B:block(chest, v(7.4, 0.45, 6.6), cf(0, 4.72, 0.5), MAIN)
		B:block(chest, v(1.0, 0.2, 0.2), cf(-1.6, 4.72, -2.85), SPOT)
		B:block(chest, v(0.7, 0.2, 0.2), cf(1.9, 4.72, -2.85), SPOT)
		B:block(chest, v(1.0, 0.2, 0.2), cf(0.8, 4.72, 3.85), SPOT)

		------------------------------------------------------------------
		-- Head: big face under the brim, wide black toothy grin
		------------------------------------------------------------------
		local head = B:bone("Head", "Chest", v(0, 7.0, 0.5))
		slab(head, 7.6, 2.6, 6.2, 0.8, 0, 9.5, -0.1, FACE) -- upper face (y 8.2..10.8)
		B:block(head, v(5.4, 1.6, 3.6), cf(0, 7.5, 1.2), FACE) -- neck / back of the jaw
		-- black mouth: deep interior + a throat wall in front of the chest so the
		-- open jaw always shows a big black cartoon maw
		B:block(head, v(5.6, 2.0, 2.6), cf(0, 7.2, -1.85), MOUTH)
		B:block(head, v(5.4, 2.3, 0.3), cf(0, 7.05, -2.1), MOUTH)
		-- upper teeth hang from the lip, big fangs at +-1.44
		for i = 0, 5 do
			local x = -2.4 + i * 0.96
			local fang = (i == 1 or i == 4)
			local h = fang and 1.05 or 0.7
			B:block(head, v(0.6, h, 0.45), cf(x, 8.3 - h / 2 + 0.02, -3.3), WHITE)
		end
		B:sym(function()
			-- cheeks close the sides of the grin
			B:block(head, v(0.9, 1.4, 2.2), cf(3.35, 7.6, -1.5), FACE)
			-- eye: black frame, lime neon panel, big dark pupil, white glint
			B:block(head, v(2.2, 2.1, 0.25), cf(1.85, 9.45, -3.25), PUPIL)
			B:block(head, v(1.8, 1.7, 0.3), cf(1.85, 9.45, -3.3), LIME, { mat = "Neon", name = "Eye" })
			B:block(head, v(0.9, 1.4, 0.2), cf(1.7, 9.4, -3.5), PUPIL)
			B:block(head, v(0.4, 0.4, 0.1), cf(1.95, 9.85, -3.62), WHITE)
			-- angry brow (inner end lower)
			B:block(head, v(2.6, 0.7, 0.9), cf(1.85, 10.6, -3.55, 0, 0, 16), DARK)
			-- blush on the face corner step + freckles on the side of the head
			B:block(head, v(0.8, 0.6, 0.2), cf(3.4, 8.85, -2.5), BLUSH)
			B:block(head, v(0.2, 0.9, 0.9), cf(3.85, 9.6, -0.6), DARK)
			B:block(head, v(0.2, 0.6, 0.6), cf(3.85, 8.9, 1.2), MAIN)
		end)

		-- eyelids (hidden under the cap at rest, revealed while closing)
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(1.85, 10.5, -3.4))
			B:block(lid, v(2.3, 2.2, 0.7), cf(1.85, 11.95, -3.6), FACE, { tr = 1, name = "Eyelid" .. side })
			-- squeezed-shut lash line (reads as a cartoon > < squint)
			B:block(lid, v(2.0, 0.3, 0.2), cf(1.85, 11.75, -4.0, 0, 0, -14), PUPIL, { tr = 1, name = "Lash" .. side })
		end)

		local jaw = B:bone("Jaw", "Head", v(0, 7.4, -0.4))
		B:block(jaw, v(5.8, 1.2, 3.4), cf(0, 6.4, -1.9), STALK)
		B:block(jaw, v(4.6, 0.3, 2.8), cf(0, 5.7, -1.9), STALK_DK)
		B:block(jaw, v(5.6, 0.3, 3.2), cf(0, 7.0, -1.95), MOUTH)
		B:block(jaw, v(2.6, 0.25, 2.0), cf(0, 7.2, -1.6), TONGUE)
		B:block(jaw, v(1.0, 0.15, 1.2), cf(0, 7.33, -1.8), DARK)
		for i = 0, 4 do
			B:block(jaw, v(0.6, 0.6, 0.45), cf(-1.92 + i * 0.96, 7.25, -3.3), WHITE)
		end
		B:sym(function()
			-- underbite tusks at the corners of the grin
			B:block(jaw, v(0.6, 1.25, 0.5), cf(2.6, 7.45, -3.4), WHITE)
		end)
		-- spore glow deep in the throat, only shown during the yell / blast
		B:block(head, v(3.0, 0.6, 0.2), cf(0, 7.3, -2.3), LIME, { mat = "Neon", tr = 1, name = "ThroatGlow" })

		------------------------------------------------------------------
		-- The cap (own bone so it wobbles and pumps)
		------------------------------------------------------------------
		local CZ, Y0 = 0.9, 10.7 -- cap center z, cap underside y
		local cap = B:bone("Cap", "Head", v(0, 10.8, 0.6))
		-- the whole cap sits pushed back a few degrees so the face reads from above
		local TILT = CFrame.new(0, 10.8, 0.6) * P.ang(5, 0, 0) * CFrame.new(0, -10.8, -0.6)
		local function ccf(x, y, z) return TILT * cf(x, y, z) end
		-- stalk plug hidden inside the head: fills the gap when the cap pumps up / tilts
		B:block(cap, v(6.0, 1.8, 4.8), ccf(0, 10.1, -0.1), FACE)
		cslab(cap, 10.6, 0.5, 9.6, 1.4, 0, Y0 + 0.25, CZ, GILL, ccf)
		cslab(cap, 12.8, 1.0, 11.8, 1.8, 0, Y0 + 0.9, CZ, DARK, ccf)
		cslab(cap, 12.0, 1.3, 11.0, 1.8, 0, Y0 + 2.0, CZ, MAIN, ccf)
		cslab(cap, 9.8, 1.1, 9.0, 1.6, 0, Y0 + 3.15, CZ, MAIN, ccf)
		cslab(cap, 7.0, 0.9, 6.4, 1.2, 0, Y0 + 4.1, CZ, MAIN, ccf)
		cslab(cap, 3.8, 0.5, 3.4, 0.6, 0, Y0 + 4.75, CZ, MAIN, ccf)
		-- glowing gill lines on the underside (bioluminescent, only seen from below / on tilts)
		for k = 0, 7 do
			local ga = math.rad(22.5 + k * 45)
			local gx, gz = math.sin(ga) * 4.55, CZ - math.cos(ga) * 4.15
			B:block(cap, v(0.2, 0.1, 1.5), TILT * CFrame.new(gx, Y0 - 0.04, gz) * CFrame.Angles(0, -ga, 0), LIME, { mat = "Neon" })
		end
		-- cream spots on the tier faces
		local y2, y3, y4 = Y0 + 2.0, Y0 + 3.15, Y0 + 4.6
		B:block(cap, v(1.8, 0.9, 0.2), ccf(-2.4, y2, CZ - 5.55), SPOT)
		B:block(cap, v(1.2, 0.7, 0.2), ccf(2.6, y2 + 0.05, CZ - 5.55), SPOT)
		B:block(cap, v(0.2, 0.9, 1.8), ccf(6.05, y2, -0.4), SPOT)
		B:block(cap, v(0.2, 0.7, 1.2), ccf(6.05, y2, 3.2), SPOT)
		B:block(cap, v(0.2, 0.9, 1.6), ccf(-6.05, y2, 1.4), SPOT)
		B:block(cap, v(1.6, 0.9, 0.2), ccf(1.0, y2, CZ + 5.55), SPOT)
		B:block(cap, v(1.4, 0.8, 0.2), ccf(0.6, y3, CZ - 4.55), SPOT)
		B:block(cap, v(0.2, 0.8, 1.4), ccf(4.95, y3, 2.0), SPOT)
		B:block(cap, v(0.2, 0.8, 1.4), ccf(-4.95, y3, -1.2), SPOT)
		B:block(cap, v(1.2, 0.2, 1.2), ccf(2.6, y4, 1.5), SPOT)
		B:block(cap, v(1.2, 0.2, 1.2), ccf(-2.6, y4, 0.2), SPOT)
		B:block(cap, v(1.0, 0.2, 1.0), ccf(3.9, Y0 + 3.75, -1.6), SPOT)
		-- spots on the step ledges (what players see from above)
		local t2, t3 = Y0 + 2.7, Y0 + 3.75
		B:block(cap, v(0.9, 0.2, 0.9), ccf(5.45, t2, CZ + 1.0), SPOT)
		B:block(cap, v(1.0, 0.2, 0.9), ccf(-2.0, t2, CZ - 5.0), SPOT)
		B:block(cap, v(1.0, 0.2, 0.9), ccf(2.5, t2, CZ + 5.0), SPOT)
		B:block(cap, v(0.9, 0.2, 1.0), ccf(-5.45, t2, CZ - 2.4), SPOT)
		B:block(cap, v(0.9, 0.2, 0.9), ccf(-4.2, t3, CZ + 1.0), SPOT)
		B:block(cap, v(1.0, 0.2, 0.9), ccf(1.0, t3, CZ + 3.85), SPOT)
		B:block(cap, v(0.9, 0.2, 0.9), ccf(-1.5, t3, CZ - 3.85), SPOT)
		-- a few small lime neon spots
		B:block(cap, v(0.8, 0.2, 0.8), ccf(0.6, Y0 + 5.05, 0.5), LIME, { mat = "Neon" })
		B:block(cap, v(0.2, 0.7, 0.7), ccf(-6.05, y2 + 0.1, -1.8), LIME, { mat = "Neon" })
		B:block(cap, v(0.2, 0.6, 0.6), ccf(4.95, y3 + 0.05, -1.2), LIME, { mat = "Neon" })

		-- cap VFX: drifting spores + the burst
		local aura = B:block(cap, v(12, 4, 11), ccf(0, Y0 + 2.5, CZ), MAIN, { tr = 1, name = "SporeAura" })
		B:emitter(aura, "sparkle", { name = "SporeSparkle", color = { "#ffffff", LIME }, rate = 4 })
		local under = B:block(cap, v(10, 1, 9), ccf(0, Y0 - 0.3, CZ), MAIN, { tr = 1, name = "SporeUnder" })
		B:emitter(under, "bubble", { name = "SporeDrift", color = { LIME, "#ffc2d6" }, rate = 3, size = { 0.12, 0.3, 0 }, speed = { 0.3, 0.9 }, accel = { 0, 1.2, 0 } })
		local top = B:block(cap, v(6, 1, 6), ccf(0, Y0 + 4.7, CZ), MAIN, { tr = 1, name = "SporeVent" })
		B:emitter(top, "burst", { name = "SporeBurst", color = { "#ffffff", LIME, PINK } })
		B:emitter(top, "smoke", { name = "SporeCloud", rate = 0, color = { "#ff9fc0", "#c9f58f" }, speed = { 3, 7 }, size = { 2, 4, 6 }, spread = 70 })
		B:emitter(top, "spark", { name = "SporeSparks", color = LIME, enabled = false, rate = 25 })
		B:light(top, { name = "SporeLight", color = LIME, brightness = 0, range = 14 })
		B:sym(function()
			B:trail(cap, ccf(6.3, Y0 + 0.5, CZ).Position, ccf(6.3, Y0 + 2.4, CZ).Position, { name = "CapTrail", color = { PINK, "#ffffff" }, life = 0.2, trans = { 0.6, 1 }, light = 0.2 })
		end)

		------------------------------------------------------------------
		-- Arms with little mushroom-cap shoulder pads, magenta gloves
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Chest", v(2.9, 6.0, 0.5))
			B:block(arm, v(2.4, 0.3, 2.4), cf(4.0, 6.45, 0.5), GILL)
			B:block(arm, v(3.0, 0.5, 3.0), cf(4.0, 6.75, 0.5), DARK)
			B:block(arm, v(2.2, 0.6, 2.2), cf(4.0, 7.25, 0.5), MAIN)
			B:block(arm, v(0.8, 0.2, 0.8), cf(4.25, 7.6, 0.3), SPOT)
			B:block(arm, v(1.7, 2.2, 1.7), cf(3.75, 5.3, 0.5), STALK)
			B:block(arm, v(0.2, 1.0, 1.0), cf(4.65, 5.2, 0.5), STALK_DK)

			local hand = B:bone("Hand" .. side, "Arm" .. side, v(3.8, 4.4, 0.5))
			B:block(hand, v(2.2, 0.45, 2.2), cf(3.85, 4.25, 0.45), MAIN)
			B:block(hand, v(1.9, 1.4, 1.9), cf(3.85, 3.6, 0.4), DARK)
			B:block(hand, v(2.4, 1.6, 2.6), cf(3.9, 2.5, 0.2), DARK)
			B:block(hand, v(0.7, 0.7, 0.9), cf(2.85, 2.8, -0.6), DARK)
			B:block(hand, v(0.2, 0.6, 0.7), cf(5.15, 2.7, 0.5), SPOT)
			B:block(hand, v(0.2, 0.4, 0.4), cf(4.85, 3.7, -0.2), SPOT)
			for k = -1, 1 do
				B:spike(hand, v(3.9 + k * 0.72, 1.95, -0.9), v(3.9 + k * 0.8, 1.35, -1.9), 0.45, 0.45, WHITE)
			end
			B:trail(hand, v(3.9, 1.7, -1.3), v(3.9, 3.1, -1.3), { name = "ClawTrail", color = { PINK, "#ffffff" }, life = 0.18, trans = { 0.65, 1 }, light = 0.2 })
		end)

		------------------------------------------------------------------
		-- Stubby legs (Hips) + boots (Root, so they stay planted on squash)
		------------------------------------------------------------------
		B:sym(function(side)
			local leg = B:bone("Leg" .. side, "Hips", v(1.8, 2.8, 0.5))
			B:block(leg, v(2.0, 2.4, 2.0), cf(1.85, 1.8, 0.5), STALK)

			local foot = B:bone("Foot" .. side, "Root", v(1.9, 0.6, 0.3))
			B:block(foot, v(2.9, 1.1, 3.6), cf(1.9, 0.55, 0.2), DARK)
			B:block(foot, v(2.9, 0.7, 1.0), cf(1.9, 0.35, -1.9), DARK)
			B:block(foot, v(2.5, 0.45, 2.5), cf(1.9, 1.3, 0.5), MAIN)
			-- volva cup: a stepped lip round the boot cuff
			B:block(foot, v(2.7, 0.4, 2.7), cf(1.9, 1.7, 0.5), DARK)
			B:block(foot, v(0.2, 0.3, 0.6), cf(3.17, 1.3, 0.5), SPOT)
			for k = -1, 1 do
				B:wedge(foot, v(0.6, 0.55, 0.9), cf(1.9 + k * 0.9, 0.28, -2.85), WHITE)
			end
		end)
		local fill = B:block(head, v(1, 1, 1), cf(0, 9.0, -6.0), STALK, { tr = 1, name = "FaceFill" })
		B:light(fill, { name = "FaceLight", color = "#fff1de", brightness = 0.45, range = 7 })
		local dust = B:block("Root", v(7, 0.2, 6), cf(0, 0.1, 0.5), STALK, { tr = 1, name = "DustFX" })
		B:emitter(dust, "dust", { name = "LandDust", color = "#e3d6bd" })

		------------------------------------------------------------------
		-- Little mushrooms sprouting from the back (own bones -> jiggle)
		------------------------------------------------------------------
		local function shroom(name, parent, base, tx, tz, s)
			local b = B:bone(name, parent, base)
			local f = CFrame.new(base) * P.ang(tx, 0, tz)
			B:block(b, v(1.0 * s, 3.4 * s, 1.0 * s), f * CFrame.new(0, 1.3 * s, 0), STALK)
			B:block(b, v(1.3 * s, 0.3 * s, 1.3 * s), f * CFrame.new(0, 1.6 * s, 0), DARK) -- tiny ring
			B:block(b, v(2.2 * s, 0.25, 2.2 * s), f * CFrame.new(0, 3.05 * s, 0), GILL)
			B:block(b, v(2.8 * s, 0.6 * s, 2.8 * s), f * CFrame.new(0, 3.35 * s, 0), DARK)
			B:block(b, v(2.2 * s, 0.6 * s, 2.2 * s), f * CFrame.new(0, 3.9 * s, 0), MAIN)
			B:block(b, v(1.2 * s, 0.4 * s, 1.2 * s), f * CFrame.new(0, 4.35 * s, 0), MAIN)
			B:block(b, v(0.6 * s, 0.15, 0.6 * s), f * CFrame.new(0.6 * s, 4.25 * s, 0.5 * s), SPOT)
			B:block(b, v(0.5 * s, 0.2, 0.5 * s), f * CFrame.new(0, 4.55 * s + 0.1, 0), LIME, { mat = "Neon" })
			return b
		end
		shroom("Shroom1", "Chest", v(1.4, 6.3, 2.8), 24, -40, 1.15)
		shroom("Shroom2", "Chest", v(-1.4, 5.7, 2.8), 20, 42, 1.0)
		shroom("Shroom3", "Hips", v(0.4, 3.6, 3.2), 32, -10, 0.9)

		------------------------------------------------------------------
		-- Floating pink / green voxel cubes
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 8, 0.5))
		local spots = { { 10.0, 11.0, 0.5 }, { -9.5, 6.0, 2.5 }, { 6.5, 5.0, 8.5 }, { -6.5, 15.0, -6.5 }, { -3.0, 9.5, 9.8 }, { 4.5, 16.0, -7.0 } }
		for i, p in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(p[1], p[2], p[3]))
			local pink = i % 2 == 1
			local s = (pink and 1.3 or 1.2) * (i > 4 and 0.75 or 1)
			B:block(ob, v(s, s, s), cf(p[1], p[2], p[3]), pink and PINK or GREEN)
			if pink then
				B:block(ob, v(0.6, 0.6, 0.2), cf(p[1] + 0.25, p[2] + 0.25, p[3] - s / 2 - 0.05), SPOT)
			else
				B:block(ob, v(s + 0.1, s * 0.25, s + 0.1), cf(p[1], p[2], p[3]), LIME, { mat = "Neon" })
			end
		end

		------------------------------------------------------------------
		-- Spore cloud: hidden OPAQUE voxel puffs that blast out of the cap
		------------------------------------------------------------------
		local PUFF = { MAIN, GREEN, SPOT, "#ff9fc0" }
		for i = 1, 12 do
			local pb = B:bone("Puff" .. i, "Root", v(0, Y0 + 3.7, CZ))
			local s = (i % 3 == 0) and 1.5 or ((i % 2 == 0) and 1.0 or 1.25)
			B:block(pb, v(s, s, s), cf(0, Y0 + 3.7, CZ), PUFF[(i - 1) % 4 + 1], { tr = 1, name = "Puff" .. i })
		end
		for i = 1, 2 do
			local cy = Y0 + 4.1
			local cb = B:bone("Cloud" .. i, "Root", v(0, cy, CZ))
			B:block(cb, v(3.0, 1.6, 2.4), cf(0, cy, CZ), "#ff9fc0", { tr = 1, name = "Cloud" .. i })
			B:block(cb, v(1.8, 0.9, 1.6), cf(i == 1 and 0.3 or -0.3, cy + 1.2, CZ), GILL, { tr = 1, name = "CloudTop" .. i })
		end

		------------------------------------------------------------------
		-- Landing shockwave: flat cream/pink slabs (one bone each) that slide
		-- outward along the ground and sink, hidden otherwise
		------------------------------------------------------------------
		local SC = v(0, 0.2, 0.5)
		for k = 1, 10 do
			local a = (k - 1) / 10 * 360
			local sb = B:bone("Shock" .. k, "Root", SC)
			B:block(sb, v(2.2, 0.4, 0.9), CFrame.new(SC) * P.ang(0, a, 0) * CFrame.new(0, 0, -4.2), k % 2 == 0 and PINK or GILL, { tr = 1, name = "Wave" .. k })
		end
	end,
}
