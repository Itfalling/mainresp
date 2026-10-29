--!nocheck
-- Hornet Warlord (Guardian #8, Cosmic): a giant armoured war-hornet that
-- hovers over its flower garden like a drill-sergeant commander. Black thorax
-- under stepped dark-gold breastplates with medals and epaulettes, a big
-- yellow helmet-head (black helmet, gold brim + crest), ONE pair of big angular
-- dark eyes with small magenta glints under heavy black brows, and ONE mouth:
-- two hinged gold mandibles over a black mouth with white teeth. Yellow/black
-- stepped abdomen ending in a huge stinger with a neon tip. Two pairs of amber
-- translucent wings that buzz, rear legs dangling, and the right hand grips a
-- honey-dipped stinger lance. Honeycomb + flower voxel cubes orbit it.
return {
	DisplayName = "Hornet Warlord",
	Rarity = "Cosmic",
	Element = "Insect",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		-- palette
		local YEL, YEL2 = "#ffc81f", "#f0a812" -- hornet yellow + its darker shade
		local BLK, BLK2 = "#211c27", "#332b3d" -- armour black + lighter black
		local DGOLD, GOLD = "#c98a12", "#f5cf4a" -- dark-gold plates + bright gold trims
		local CREAM, WHITE = "#fff2cc", "#fffaf0" -- spikes / claws / teeth
		local MOUTH, EYE = "#120c14", "#1c1030"
		local HONEY, HONEY2 = "#ff9f12", "#ffb938"
		local WINGC, PINK, LEAF = "#ffd86e", "#ff7ad2", "#4fc35a"
		local MAG = "#ff2fd8" -- the one neon accent
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- THORAX (Body): black core, stepped dark-gold breastplate, medals
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 9.0, 0.2))
		B:block(body, v(5.6, 4.8, 4.6), cf(0, 9.0, 0.2), BLK)
		B:block(body, v(4.4, 0.8, 3.8), cf(0, 11.6, 0.6), BLK2)
		B:block(body, v(4.4, 0.6, 3.6), cf(0, 6.4, 0.3), DGOLD) -- belly plate
		-- breastplate rows (stepped, alternating dark gold / gold)
		B:block(body, v(5.0, 1.3, 0.7), cf(0, 10.6, -2.3), DGOLD)
		B:block(body, v(4.4, 1.3, 0.7), cf(0, 9.3, -2.45), GOLD)
		B:block(body, v(3.6, 1.2, 0.7), cf(0, 8.05, -2.35), DGOLD)
		B:block(body, v(2.4, 0.9, 0.6), cf(0, 7.0, -2.25), GOLD)
		B:block(body, v(0.5, 3.6, 0.3), cf(0, 9.0, -2.85), BLK) -- centre seam
		-- medals on the left breast (one magenta neon ribbon)
		B:block(body, v(0.8, 0.45, 0.2), cf(-1.35, 10.95, -2.75), MAG, NEON)
		B:block(body, v(0.7, 0.7, 0.25), cf(-1.35, 10.35, -2.8), GOLD)
		B:block(body, v(0.8, 0.45, 0.2), cf(-2.2, 10.95, -2.72), YEL)
		B:block(body, v(0.6, 0.6, 0.25), cf(-2.2, 10.4, -2.78), CREAM)
		-- back plate (scutellum)
		B:block(body, v(4.8, 0.8, 2.4), cf(0, 11.2, 2.0), DGOLD)
		B:block(body, v(3.0, 0.6, 1.6), cf(0, 11.8, 2.3), GOLD)
		B:sym(function()
			B:block(body, v(0.4, 0.9, 4.0), cf(2.85, 9.9, 0.2), YEL)
			B:block(body, v(0.4, 0.9, 3.6), cf(2.85, 8.0, 0.2), YEL)
			B:spike(body, v(1.6, 11.9, 1.6), v(2.4, 13.0, 2.6), 0.7, 0.7, CREAM)
		end)
		local aura = B:block(body, v(7, 6, 9), cf(0, 9.0, 3.0), BLK, { tr = 1, name = "AuraFX" })
		B:emitter(aura, "sparkle", { name = "Pollen", color = { "#ffffff", YEL }, rate = 5, size = { 0.12, 0.4, 0 } })

		------------------------------------------------------------------
		-- HEAD: big yellow helmet-head
		------------------------------------------------------------------
		local head = B:bone("Head", "Body", v(0, 11.2, -1.4))
		B:block(head, v(3.2, 1.4, 3.0), cf(0, 11.0, -1.8), BLK) -- neck
		B:block(head, v(6.4, 4.6, 4.8), cf(0, 13.3, -3.5), YEL) -- big face / skull
		B:block(head, v(5.2, 0.8, 4.0), cf(0, 10.8, -3.6), YEL2) -- chin step
		-- helmet: one dark-gold cap + a low black crest (kept simple so the eyes rule)
		B:block(head, v(6.8, 1.4, 5.4), cf(0, 16.2, -3.3), DGOLD)
		B:block(head, v(1.0, 0.45, 4.6), cf(0, 17.1, -3.2), BLK)
		-- black mouth between the mandibles
		B:block(head, v(2.6, 1.1, 0.5), cf(0, 11.65, -5.85), MOUTH)
		B:sym(function(side)
			-- cheek guards hanging from the cap + one horn spike
			B:block(head, v(0.5, 3.0, 3.2), cf(3.35, 14.1, -2.8), DGOLD)
			B:block(head, v(0.6, 0.5, 3.3), cf(3.4, 14.6, -2.8), BLK)
			B:spike(head, v(3.3, 16.3, -2.6), v(4.6, 17.2, -1.4), 0.9, 0.9, CREAM)
			B:gem(head, v(0.35, 0.35, 0.35), cf(4.6, 17.2, -1.4), MAG)
			-- EYE: big angular dark eye (stepped up toward the outer corner) with
			-- magenta glints on the front face only; it wraps the corner in plain dark
			B:block(head, v(2.7, 1.9, 0.4), cf(1.65, 13.45, -6.0, 0, 0, 14), EYE)
			B:block(head, v(1.3, 0.6, 0.4), cf(2.45, 14.45, -6.0, 0, 0, 14), EYE)
			B:block(head, v(0.5, 1.8, 1.6), cf(3.15, 13.75, -5.2), EYE)
			B:block(head, v(0.75, 0.75, 0.12), cf(1.25, 13.75, -6.25, 0, 0, 14), MAG, { mat = "Neon", name = "Glint" .. side })
			B:block(head, v(0.35, 0.35, 0.12), cf(2.3, 13.0, -6.25, 0, 0, 14), WHITE)
			-- eyelid (shown only while blinking / squinting)
			local lid = B:bone("Lid" .. side, "Head", v(1.65, 13.6, -6.3))
			B:block(lid, v(2.9, 2.6, 0.3), cf(1.75, 13.65, -6.3, 0, 0, 14), YEL2, { tr = 1, name = "Eyelid" .. side })
			-- heavy black brow on its own bone (angry: inner end low)
			local brow = B:bone("Brow" .. side, "Head", v(1.6, 15.05, -6.0))
			B:block(brow, v(3.2, 0.85, 1.0), cf(1.7, 15.05, -6.2, 0, 0, 18), BLK)
			-- antennae: two-bone chains, bent forward, yellow clubs
			local a1 = B:bone("AntA" .. side, "Head", v(1.1, 16.6, -4.6))
			B:beam(a1, v(1.1, 16.4, -4.6), v(1.6, 17.2, -5.6), 0.55, 0.55, BLK)
			local a2 = B:bone("AntB" .. side, "AntA" .. side, v(1.6, 17.2, -5.6))
			B:beam(a2, v(1.55, 17.15, -5.55), v(2.8, 16.9, -6.7), 0.5, 0.5, BLK)
			B:block(a2, v(0.8, 0.8, 0.8), cf(2.9, 16.9, -6.85), YEL)
			B:gem(a2, v(0.4, 0.4, 0.4), cf(3.1, 16.95, -7.25), MAG)
		end)

		-- MANDIBLES (the jaw): two big hinged gold hooks with cream blade tips
		B:sym(function(side)
			local m = B:bone("Mand" .. side, "Head", v(2.1, 11.8, -5.7))
			B:block(m, v(1.9, 1.6, 1.8), cf(2.2, 11.7, -6.4), DGOLD)
			B:block(m, v(1.6, 1.3, 1.6), cf(1.6, 11.6, -7.6), GOLD)
			B:spike(m, v(1.35, 11.6, -8.1), v(0.15, 11.5, -9.2), 1.1, 1.0, CREAM)
			B:block(m, v(0.5, 0.6, 0.5), cf(1.0, 11.0, -7.1), WHITE) -- one fang
		end)
		local mouthFX = B:block(head, v(2, 1, 1), cf(0, 11.8, -7.5), YEL, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFX, "burst", { name = "BattleBurst", color = { "#ffffff", YEL, MAG }, size = { 0.8, 0.5, 0 } })

		-- expression props (hidden; states show them)
		B:block(head, v(1.7, 0.45, 0.45), cf(2.4, 17.0, -5.0, 0, 0, 45), "#ff2b2b", { tr = 1, name = "Anger1" })
		B:block(head, v(1.7, 0.45, 0.45), cf(2.4, 17.0, -5.0, 0, 0, -45), "#ff2b2b", { tr = 1, name = "Anger2" })
		B:block(head, v(1.2, 0.4, 0.4), cf(3.4, 17.8, -4.6, 0, 0, 45), "#ff2b2b", { tr = 1, name = "Anger3" })
		B:block(head, v(1.2, 0.4, 0.4), cf(3.4, 17.8, -4.6, 0, 0, -45), "#ff2b2b", { tr = 1, name = "Anger4" })
		B:block(head, v(0.55, 0.9, 0.45), cf(-3.6, 15.0, -4.4), "#8fdcff", { tr = 1, name = "Sweat1" })
		B:block(head, v(0.4, 0.4, 0.35), cf(-3.6, 14.4, -4.4), "#8fdcff", { tr = 1, name = "Sweat2" })
		B:block(head, v(0.9, 2.2, 0.9), cf(0, 20.4, -3.4), "#ff3b3b", { tr = 1, name = "Excl1" })
		B:block(head, v(0.9, 0.9, 0.9), cf(0, 18.7, -3.4), "#ff3b3b", { tr = 1, name = "Excl2" })

		------------------------------------------------------------------
		-- ARMS (front pair): epaulettes, gauntlets; right hand holds the lance
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Body", v(2.9, 10.4, -1.0))
			B:block(arm, v(2.0, 2.0, 2.0), cf(3.4, 10.4, -1.0), BLK)
			B:block(arm, v(2.5, 0.6, 2.5), cf(3.55, 11.4, -1.0), GOLD) -- epaulette
			B:block(arm, v(1.6, 0.4, 1.6), cf(3.55, 11.85, -1.0), DGOLD)
			for k = -1, 1 do
				B:block(arm, v(0.35, 0.75, 0.35), cf(4.65, 10.8, -1.0 + k * 0.75), CREAM)
			end
			B:beam(arm, v(3.6, 10.2, -1.2), v(4.4, 8.0, -2.2), 1.5, 1.5, BLK)
			B:block(arm, v(1.7, 0.5, 1.7), cf(4.05, 9.1, -1.75, -24, 0, 0), YEL)
			local fore = B:bone("Fore" .. side, "Arm" .. side, v(4.4, 8.0, -2.2))
			B:block(fore, v(1.7, 1.7, 1.7), cf(4.4, 8.0, -2.2), DGOLD)
			B:beam(fore, v(4.4, 8.0, -2.4), v(4.4, 8.4, -4.6), 1.5, 1.5, DGOLD)
			B:block(fore, v(1.9, 1.9, 0.6), cf(4.4, 8.3, -3.7), GOLD)
			B:spike(fore, v(4.9, 8.4, -3.2), v(5.9, 8.9, -2.4), 0.6, 0.6, CREAM)
			B:block(fore, v(1.5, 1.5, 1.5), cf(4.4, 8.4, -5.1), BLK) -- fist
			B:block(fore, v(1.0, 0.5, 0.6), cf(4.4, 8.9, -5.95), CREAM) -- knuckle claws
			B:block(fore, v(1.0, 0.5, 0.6), cf(4.4, 8.0, -5.95), CREAM)

			if side == "R" then
				-- the honey-dipped stinger lance (own bone at the fist)
				local sp = B:bone("Spear", "ForeR", v(4.4, 8.4, -5.1))
				B:beam(sp, v(4.4, 3.4, -5.1), v(4.4, 13.6, -5.1), 0.6, 0.6, BLK2)
				for _, y in { 4.7, 7.0, 10.0, 12.4 } do
					B:block(sp, v(0.8, 0.35, 0.8), cf(4.4, y, -5.1), GOLD)
				end
				B:block(sp, v(0.9, 0.6, 0.9), cf(4.4, 3.3, -5.1), DGOLD) -- butt cap
				B:block(sp, v(0.5, 0.5, 0.5), cf(4.4, 2.8, -5.1), GOLD)
				B:block(sp, v(1.1, 0.8, 1.1), cf(4.4, 13.6, -5.1), DGOLD) -- socket
				-- honey dip: amber blobs + drips over the socket
				B:block(sp, v(1.4, 0.5, 1.4), cf(4.4, 13.9, -5.1), HONEY)
				B:block(sp, v(0.4, 0.8, 0.4), cf(4.95, 13.4, -5.4), HONEY2)
				B:block(sp, v(0.35, 0.55, 0.35), cf(3.9, 13.5, -4.7), HONEY2)
				-- stepped cross-bladed stinger head
				B:block(sp, v(1.8, 1.1, 0.5), cf(4.4, 14.6, -5.1), CREAM)
				B:block(sp, v(0.5, 1.1, 1.8), cf(4.4, 14.6, -5.1), CREAM)
				B:block(sp, v(1.2, 1.0, 0.45), cf(4.4, 15.6, -5.1), CREAM)
				B:block(sp, v(0.45, 1.0, 1.2), cf(4.4, 15.6, -5.1), CREAM)
				B:block(sp, v(1.9, 0.18, 0.35), cf(4.4, 15.1, -5.1), MAG, NEON)
				B:spike(sp, v(4.4, 15.9, -5.1), v(4.4, 17.3, -5.1), 0.8, 0.8, CREAM)
				B:gem(sp, v(0.35, 0.35, 0.35), cf(4.4, 17.25, -5.1), MAG)
				local tipFX = B:block(sp, v(1.2, 1.6, 1.2), cf(4.4, 15.4, -5.1), CREAM, { tr = 1, name = "SpearFX" })
				B:emitter(tipFX, "burst", { name = "SpearSparks", color = { "#ffffff", MAG, YEL }, size = { 0.6, 0.35, 0 }, speed = { 5, 10 } })
				B:light(tipFX, { name = "SpearLight", color = MAG, brightness = 0, range = 10 })
				local honeyFX = B:block(sp, v(1.2, 0.3, 1.2), cf(4.4, 13.3, -5.1), HONEY, { tr = 1, name = "HoneyFX" })
				B:emitter(honeyFX, "drip", { name = "HoneyDrip", color = { HONEY2, HONEY }, rate = 2.5, size = { 0.35, 0.3, 0.15 } })
				B:trail(sp, v(4.4, 17.2, -5.1), v(4.4, 14.4, -5.1), { name = "SpearTrail", color = { "#ffffff", MAG }, life = 0.2, trans = { 0.45, 1 } })
			end
		end)

		------------------------------------------------------------------
		-- REAR LEGS (dangling while it hovers)
		------------------------------------------------------------------
		B:sym(function(side)
			local leg = B:bone("Leg" .. side, "Body", v(1.8, 7.0, 0.8))
			B:block(leg, v(1.5, 1.5, 1.5), cf(1.9, 7.0, 0.8), BLK)
			B:beam(leg, v(1.9, 7.0, 0.8), v(3.2, 5.4, 0.0), 1.2, 1.2, BLK)
			local shin = B:bone("Shin" .. side, "Leg" .. side, v(3.2, 5.4, 0.0))
			B:block(shin, v(1.5, 1.5, 1.5), cf(3.2, 5.4, 0.0), DGOLD)
			B:beam(shin, v(3.2, 5.4, 0.0), v(3.0, 3.1, 0.9), 1.0, 1.0, YEL)
			B:spike(shin, v(3.5, 4.4, 0.4), v(4.4, 4.0, 1.2), 0.45, 0.45, CREAM)
			local foot = B:bone("Foot" .. side, "Shin" .. side, v(3.0, 3.1, 0.9))
			B:block(foot, v(1.1, 0.8, 1.6), cf(3.0, 2.9, 0.5), BLK)
			B:wedge(foot, v(0.45, 0.6, 1.0), cf(2.75, 2.65, -0.6), CREAM)
			B:wedge(foot, v(0.45, 0.6, 1.0), cf(3.25, 2.65, -0.6), CREAM)
		end)

		------------------------------------------------------------------
		-- ABDOMEN: 4 stepped yellow/black segments + the giant stinger
		------------------------------------------------------------------
		local segs = {
			{ v(0, 8.2, 2.6), 4.4, 3.8, 7.6, 4.0 },
			{ v(0, 7.3, 5.2), 5.6, 4.6, 6.6, 6.6 },
			{ v(0, 6.0, 7.8), 5.0, 4.0, 5.3, 9.1 },
			{ v(0, 4.8, 10.2), 3.6, 3.0, 4.2, 11.3 },
		}
		B:block("Body", v(1.8, 1.8, 1.6), cf(0, 8.1, 2.6), BLK) -- petiole waist
		local parent = "Body"
		for i, s in segs do
			local name = "Abd" .. i
			local b = B:bone(name, parent, s[1])
			local w, h, y, z = s[2], s[3], s[4], s[5]
			B:block(b, v(w, h, 2.6), cf(0, y, z), YEL)
			B:block(b, v(w - 1.0, 0.5, 1.8), cf(0, y + h / 2 + 0.2, z - 0.2), i % 2 == 0 and YEL2 or YEL) -- top step
			B:block(b, v(w + 0.3, h + 0.2, 0.9), cf(0, y + 0.05, z - 1.0), BLK) -- black stripe ring
			B:block(b, v(1.2, 0.35, 1.0), cf(0, y + h / 2 + 0.55, z - 0.3), BLK) -- chevron mark
			B:block(b, v(w - 1.0, 0.4, 2.0), cf(0, y - h / 2 - 0.15, z - 0.1), DGOLD) -- belly plate
			if i <= 3 then
				B:spike(b, v(0, y + h / 2 + 0.6, z + 0.6), v(0, y + h / 2 + 1.7, z + 1.6), 0.8, 0.8, CREAM)
				B:gem(b, v(0.35, 0.35, 0.35), cf(0, y + h / 2 + 1.7, z + 1.6), MAG)
			end
			if i == 2 or i == 3 then
				B:sym(function()
					B:block(b, v(0.2, 0.3, 1.6), cf(w / 2 + 0.05, y + 0.7, z - 0.2), MAG, NEON)
					B:block(b, v(0.3, 1.0, 1.2), cf(w / 2 + 0.1, y - 0.5, z - 0.2), BLK)
				end)
			end
			parent = name
		end
		local st = B:bone("Stinger", "Abd4", v(0, 4.0, 12.3))
		-- clean stepped taper: yellow band -> black band -> yellow band -> long sharp blade
		B:block(st, v(2.7, 2.3, 1.1), cf(0, 3.95, 12.85, 20, 0, 0), YEL)
		B:block(st, v(2.1, 1.75, 1.0), cf(0, 3.62, 13.75, 20, 0, 0), BLK)
		B:block(st, v(1.5, 1.25, 0.9), cf(0, 3.32, 14.6, 20, 0, 0), YEL)
		B:spike(st, v(0, 3.2, 14.9), v(0, 2.35, 17.9), 1.05, 1.05, CREAM)
		B:gem(st, v(0.45, 0.45, 0.7), cf(0, 2.45, 17.65, 16, 0, 0), MAG)
		local stingFX = B:block(st, v(0.8, 0.8, 0.8), cf(0, 2.5, 17.5), CREAM, { tr = 1, name = "StingFX" })
		B:emitter(stingFX, "burst", { name = "StingBurst", color = { "#ffffff", MAG }, size = { 0.9, 0.5, 0 } })
		B:light(stingFX, { name = "StingLight", color = MAG, brightness = 0, range = 12 })
		B:block(st, v(1.25, 1.0, 0.95), cf(0, 3.33, 14.6, 20, 0, 0), MAG, { mat = "Neon", tr = 1, name = "StingGlow" })
		B:trail(st, v(0, 2.9, 16.9), v(0, 2.3, 17.8), { name = "StingTrail", color = { "#ffffff", MAG }, life = 0.22, trans = { 0.4, 1 } })

		------------------------------------------------------------------
		-- WINGS: two pairs of amber translucent membranes with dark veins
		------------------------------------------------------------------
		local function wing(name, piv, sdir, cguess, pts, veins, spot)
			local S = sdir.Unit
			local C = (cguess - S * S:Dot(cguess)).Unit
			local N = S:Cross(C).Unit
			local function wp(u, w, dn) return piv + S * u + C * w + N * (dn or 0) end
			local b = B:bone(name, "Body", piv)
			local poly = {}
			for _, p in pts do
				table.insert(poly, wp(p[1], p[2]))
			end
			B:poly(b, poly, 0.22, WINGC, { tr = 0.3 })
			for _, vn in veins do
				B:beam(b, wp(vn[1], vn[2], 0.12), wp(vn[3], vn[4], 0.12), vn[5], 0.16, vn[6], { up = N })
			end
			if spot then
				B:block(b, v(0.5, 0.18, 0.5), CFrame.fromMatrix(wp(spot[1], spot[2], 0.16), S, N), MAG, NEON)
			end
			return b, wp
		end
		B:sym(function(side)
			-- chord tilted up-back so the membranes face the camera from the front / 3/4
			local _, fw = wing("WingF" .. side, v(1.2, 11.9, 0.9), v(0.85, 0.32, 0.4), v(0, 0.4, 0.9),
				{ { 0, -0.3 }, { 3.4, -0.9 }, { 8.4, -0.8 }, { 11.2, 0.3 }, { 11.4, 2.0 }, { 8.5, 3.3 }, { 3.4, 2.9 }, { 0, 1.4 } },
				{
					{ 0, -0.35, 11.0, 0.1, 0.4, BLK },
					{ 0.3, 1.1, 10.6, 1.7, 0.28, BLK },
					{ 3.2, 2.85, 8.4, 3.1, 0.28, DGOLD },
					{ 5.5, -0.5, 6.2, 2.9, 0.22, DGOLD },
				}, { 9.6, 1.1 })
			B:trail("WingF" .. side, fw(11.3, 0.6), fw(10.3, 2.6), { name = "WingTrailF" .. side, color = { "#fff6c8", WINGC }, life = 0.1, trans = { 0.5, 1 } })
			local _, hw = wing("WingB" .. side, v(1.2, 11.1, 1.7), v(0.85, 0.1, 0.6), v(0, 0.35, 0.95),
				{ { 0, -0.2 }, { 2.8, -0.7 }, { 6.7, -0.35 }, { 8.3, 0.9 }, { 7.4, 2.2 }, { 2.8, 2.2 }, { 0, 1.1 } },
				{
					{ 0, -0.2, 7.9, 0.35, 0.36, BLK },
					{ 0.4, 1.0, 7.2, 1.55, 0.24, DGOLD },
				}, nil)
			B:trail("WingB" .. side, hw(8.2, 0.7), hw(7.2, 2.1), { name = "WingTrailB" .. side, color = { "#fff6c8", WINGC }, life = 0.1, trans = { 0.55, 1 } })
		end)

		------------------------------------------------------------------
		-- GROUND FX (downdraft dust + petal/leaf bursts)
		------------------------------------------------------------------
		local ground = B:block("Root", v(10, 0.2, 12), cf(0, 0.1, 2), BLK, { tr = 1, name = "GroundFX" })
		B:emitter(ground, "dust", { name = "GroundDust", color = { "#f3e7c9", "#d9c79c" }, size = { 1.6, 3.2, 4.2 } })
		B:emitter(ground, "leaf", { name = "PetalBurst", color = { PINK, LEAF, YEL }, rate = 0, speed = { 4, 9 }, size = { 0.5, 0.45, 0.25 }, life = { 1.2, 2.4 }, accel = { 0, -4, 0 } })

		-- sting shockwave: a ring of dark-gold slabs with magenta faces that
		-- bursts open in the air in front of the stinger on the strike
		local SC = v(0, 6.8, -3.4)
		for k = 1, 10 do
			local a = (k - 1) / 10 * 360
			local sb = B:bone("Shock" .. k, "Root", SC)
			local at = CFrame.new(SC) * P.ang(0, 0, a) * CFrame.new(0, 1.6, 0)
			B:block(sb, v(1.4, 0.6, 0.8), at, DGOLD, { tr = 1, name = "Wave" .. k })
			B:block(sb, v(1.1, 0.2, 0.5), at * CFrame.new(0, 0.38, 0), MAG, { mat = "Neon", tr = 1, name = "WaveTop" .. k })
		end

		------------------------------------------------------------------
		-- FLOATING VOXEL CUBES: honeycomb cubes + little flower blossoms
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 9, 2))
		local spots = { { 10.5, 11.5, -1.0, "honey" }, { -10.5, 8.5, 0.5, "flower" }, { 8.5, 6.5, 9.0, "flower" }, { -8.5, 13.5, 7.5, "honey" } }
		for i, p in spots do
			local pos = v(p[1], p[2], p[3])
			local ob = B:bone("Orb" .. i, "Orbit", pos)
			if p[4] == "honey" then
				B:block(ob, v(1.8, 1.8, 1.8), CFrame.new(pos), HONEY)
				B:block(ob, v(1.9, 0.5, 1.9), CFrame.new(pos + v(0, 0.75, 0)), YEL)
				B:block(ob, v(0.7, 0.2, 0.7), CFrame.new(pos + v(0, 1.05, 0)), HONEY2)
				B:block(ob, v(1.95, 0.2, 1.95), CFrame.new(pos + v(0, -0.3, 0)), MAG, NEON)
			else
				B:block(ob, v(0.9, 0.9, 0.9), CFrame.new(pos), YEL)
				for k = 0, 3 do
					local a = math.rad(k * 90)
					B:block(ob, v(0.9, 0.5, 0.9), CFrame.new(pos + v(math.sin(a) * 0.85, -0.1, math.cos(a) * 0.85)), PINK)
				end
				B:block(ob, v(0.4, 1.4, 0.4), CFrame.new(pos + v(0, -1.0, 0)), LEAF)
				B:block(ob, v(1.0, 0.25, 0.5), CFrame.new(pos + v(0.5, -1.2, 0)), LEAF)
				B:block(ob, v(0.35, 0.35, 0.35), CFrame.new(pos + v(0, 0.55, 0)), MAG, NEON)
			end
		end
	end,
}
