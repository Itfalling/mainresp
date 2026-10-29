--!nocheck
-- Royal Bee Queen (Guardian #8, Cosmic): a COMPACT, chunky, upright cartoon
-- bumblebee queen hovering over her honey garden. Built 100% from blocks
-- (stepped stacks for the stinger, crown points, antennae and wing plates).
--
-- Proportion sheet (measured from GuardChicken / BunnyBouncer, scaled ~2.4x):
--   * stacked silhouette, bottom -> top: stinger (3 stepped cubes) -> plump
--     striped abdomen hanging straight BELOW the thorax -> fluffy round thorax
--     -> white ermine ruff collar -> BIG head (~28% of the height) -> crown.
--   * total height ~16 (stinger tip ~1.5 above the ground), depth ~10.
--   * head 6.2 wide x 3.8 tall, as wide as the thorax (chicken: head = body).
--   * eyes 2.1 wide (34% of the head width), 0.9 apart, centres at 60% of the
--     head height; ONE dark pupil + glints on the FRONT face only; heavy
--     arched black brows sitting right on top of the eyes; haughty half-lids.
--   * one small mouth under the eyes (dark slit + hinged chin), two tiny
--     mandible blocks at the corners, pink blush under the outer eye corners.
-- Royal touches: gold stepped crown with neon gems + velvet cap, standing
-- ermine collar, dark-purple mantle, honey-dipper scepter in the right hand.
return {
	DisplayName = "Royal Bee Queen",
	Rarity = "Cosmic",
	Element = "Honey",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local OY = 0.3 -- global lift (hover clearance)
		local function V(x, y, z)
			return v(x, y + OY, z)
		end
		local function C(x, y, z, rx, ry, rz)
			return cf(x, y + OY, z, rx, ry, rz)
		end

		-- palette ---------------------------------------------------------
		local HONEY, HONEYD, HONEYL = "#ffb71c", "#e08a12", "#ffd864" -- bee yellow, shade, fuzz highlight
		local BLACK, BLACK2 = "#1f1a24", "#352d3c" -- stripes / limbs
		local CREAM, CREAM2 = "#fff8e8", "#ecdfc4" -- ermine fur
		local GOLD, GOLDD = "#ffe36a", "#c7871a" -- crown / scepter metal
		local PURPLE, PURPLED, VELVET = "#6a2f96", "#46206a", "#7d38ad" -- royal mantle / crown cap
		local AMBER, AMBERD = "#ff9d14", "#d86f0a" -- honey on the dipper
		local WING, VEIN = "#fff3d2", "#f0b94a"
		local WHITE, PUPIL, MOUTH = "#ffffff", "#1c1024", "#2a0f1c"
		local TONGUE, BLUSH = "#ff6f8f", "#ff8fb4"
		local IVORY, RED, SWEAT = "#f6ecd4", "#ff3040", "#86d8ff"
		local PINK, LEAF, LEAFD = "#ff7ac8", "#5cc94a", "#3b9a34"
		local MAG = "#ff3fd2" -- neon accent 1 (gems)
		local NEONAMB = "#ffb020" -- neon accent 2 (honey glow)
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- THORAX (Body): fluffy round stepped honey ball (narrower than the
		-- head and the abdomen so the silhouette pinches at the waist)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", V(0, 8.4, 0.3))
		B:block(body, v(5.2, 2.2, 4.2), C(0, 8.3, 0.2), HONEY)
		B:block(body, v(4.4, 3.0, 3.8), C(0, 8.3, 0.2), HONEY)
		B:block(body, v(4.4, 2.1, 5.0), C(0, 8.3, 0.2), HONEY)
		-- fuzz tufts (light/dark) for a fluffy read
		B:sym(function()
			B:block(body, v(0.5, 0.7, 0.9), C(2.7, 8.6, -0.6), HONEYL)
			B:block(body, v(0.5, 0.6, 0.8), C(2.7, 7.8, 0.9), HONEYD)
			B:block(body, v(0.9, 0.6, 0.5), C(1.3, 7.5, -2.25), HONEYL)
			B:block(body, v(0.8, 0.5, 0.5), C(1.9, 8.6, 2.75), HONEYD)
		end)
		B:block(body, v(1.0, 0.6, 0.5), C(0, 8.0, -2.3), HONEYD)
		B:block(body, v(0.6, 0.5, 0.5), C(-0.8, 8.7, -2.3), HONEYL)
		B:block(body, v(0.6, 0.5, 0.5), C(0.9, 7.4, -2.3), HONEYL)
		B:block(body, v(3.6, 0.5, 0.4), C(0, 8.3, 2.75), BLACK) -- back stripe (under the cape edge)
		B:block(body, v(3.8, 0.6, 3.4), C(0, 6.95, 0.4), BLACK) -- black waist band

		local aura = B:block(body, v(7, 8, 7), C(0, 8, 0.5), HONEY, { tr = 1, name = "AuraFX" })
		B:emitter(aura, "sparkle", { name = "Sparkle", color = { "#ffffff", GOLD }, rate = 3, size = { 0.1, 0.35, 0 } })
		B:emitter(aura, "burst", {
			name = "RoyalBurst", color = { "#ffffff", GOLD, MAG }, size = { 0.7, 0.45, 0 }, speed = { 8, 15 },
		})

		------------------------------------------------------------------
		-- ERMINE RUFF COLLAR (scalloped, two tiers) + standing Medici collar
		------------------------------------------------------------------
		B:block(body, v(7.2, 0.6, 5.8), C(0, 9.4, 0.2), CREAM2) -- lower tier
		B:block(body, v(6.4, 0.7, 5.2), C(0, 9.95, 0.15), CREAM) -- upper tier
		for k = -2, 2 do -- scallops along the front
			B:block(body, v(1.0, 0.55, 0.4), C(k * 1.4, 9.35, -2.95), k % 2 == 0 and CREAM or CREAM2)
		end
		B:sym(function()
			for k = 0, 2 do -- scallops along the sides
				B:block(body, v(0.4, 0.55, 1.0), C(3.65, 9.35, -1.6 + k * 1.6), k % 2 == 0 and CREAM or CREAM2)
			end
		end)
		-- standing collar (stepped fan behind the head)
		B:block(body, v(6.8, 2.2, 0.5), C(0, 11.5, 2.55), CREAM)
		B:block(body, v(5.4, 0.7, 0.5), C(0, 12.95, 2.6), CREAM)
		B:block(body, v(3.4, 0.5, 0.5), C(0, 13.5, 2.65), CREAM2)
		B:block(body, v(7.0, 0.3, 0.6), C(0, 10.55, 2.55), GOLD) -- gold trim at its base
		B:sym(function()
			B:block(body, v(0.8, 1.4, 0.5), C(3.7, 11.6, 2.45), CREAM2) -- collar wing tips
			B:block(body, v(0.5, 1.4, 1.6), C(3.35, 11.0, 1.7), CREAM) -- collar side
		end)
		-- ermine spots (black tails)
		local spots = {
			{ -2.1, 9.95, -2.48 }, { 2.1, 9.95, -2.48 }, { -2.8, 9.35, -3.0 }, { 2.8, 9.35, -3.0 },
			{ -2.0, 11.8, 2.25 }, { 2.0, 11.8, 2.25 }, { 0, 12.5, 2.25 }, { -1.0, 10.95, 2.25 }, { 1.0, 10.95, 2.25 },
			{ -3.0, 12.6, 2.25 }, { 3.0, 12.6, 2.25 },
		}
		for _, s in spots do
			B:block(body, v(0.28, 0.42, 0.1), C(s[1], s[2], s[3]), BLACK)
		end
		-- gold brooch with a magenta gem at the collar front
		B:block(body, v(1.0, 0.9, 0.3), C(0, 9.55, -3.05), GOLD)
		B:block(body, v(1.3, 0.3, 0.25), C(0, 9.55, -3.02), GOLDD)
		B:gem(body, v(0.45, 0.45, 0.15), C(0, 9.55, -3.25), MAG, { name = "BroochGem" })

		------------------------------------------------------------------
		-- ROYAL MANTLE (cape) hanging from the collar at the back
		------------------------------------------------------------------
		local cape = B:bone("Cape", "Body", V(0, 9.9, 2.7))
		B:block(cape, v(5.0, 2.4, 0.5), C(0, 8.7, 2.95), PURPLE)
		B:block(cape, v(5.8, 0.7, 1.4), C(0, 9.75, 2.5), PURPLED) -- shoulder drape
		B:sym(function()
			B:block(cape, v(0.55, 2.4, 0.6), C(2.55, 8.7, 2.95), CREAM) -- ermine edge
			B:block(cape, v(0.2, 0.36, 0.1), C(2.55, 8.4, 3.28), BLACK)
		end)
		local cape2 = B:bone("Cape2", "Cape", V(0, 7.6, 3.1))
		B:block(cape2, v(5.2, 0.45, 1.6), C(0, 7.45, 3.6), PURPLED) -- shelf over the abdomen
		B:block(cape2, v(6.0, 1.6, 0.5), C(0, 6.55, 4.25), PURPLE) -- flared hem
		B:block(cape2, v(6.2, 0.3, 0.55), C(0, 5.65, 4.25), GOLD) -- gold hem
		B:block(cape2, v(3.6, 0.6, 0.5), C(0, 5.25, 4.25), PURPLE) -- stepped point
		B:block(cape2, v(3.8, 0.2, 0.55), C(0, 4.9, 4.25), GOLD)
		B:block(cape2, v(1.6, 0.5, 0.5), C(0, 4.6, 4.25), PURPLED)
		B:sym(function()
			B:block(cape2, v(0.55, 1.6, 0.6), C(3.05, 6.55, 4.25), CREAM) -- ermine edge
			B:block(cape2, v(0.2, 0.36, 0.1), C(3.05, 6.7, 4.58), BLACK)
		end)
		B:gem(cape2, v(0.35, 0.35, 0.12), C(0, 6.55, 4.55), MAG)

		------------------------------------------------------------------
		-- ABDOMEN: plump stepped stripes hanging straight below the thorax
		------------------------------------------------------------------
		local abd1 = B:bone("Abd1", "Body", V(0, 7.0, 0.5))
		local function band(bone, y, h, w, z, col)
			local d = w - 0.4
			B:block(bone, v(w, h, d - 1.2), C(0, y, z), col)
			B:block(bone, v(w - 0.6, h - 0.06, d - 0.6), C(0, y, z), col)
			B:block(bone, v(w - 1.2, h - 0.12, d), C(0, y, z), col)
		end
		band(abd1, 6.35, 0.9, 5.8, 0.7, HONEY)
		band(abd1, 5.35, 1.1, 6.6, 0.8, BLACK)
		B:sym(function()
			B:block(abd1, v(0.12, 0.35, 1.6), C(2.93, 6.4, 0.7), HONEYL) -- fuzz highlight
		end)
		local abd2 = B:bone("Abd2", "Abd1", V(0, 4.8, 0.9))
		band(abd2, 4.3, 1.0, 6.2, 0.9, HONEY)
		band(abd2, 3.4, 0.8, 5.0, 1.0, BLACK)
		B:block(abd2, v(3.4, 0.5, 3.0), C(0, 2.8, 1.05), HONEYD)
		B:block(abd2, v(2.4, 0.3, 2.2), C(0, 2.45, 1.05), HONEYD)
		B:sym(function()
			B:block(abd2, v(0.12, 0.35, 1.6), C(3.13, 4.4, 0.9), HONEYL)
		end)
		-- stinger: stepped stack pointing down (+ a touch back)
		local sting = B:bone("Stinger", "Abd2", V(0, 2.35, 1.1))
		B:block(sting, v(1.2, 0.5, 1.2), C(0, 2.1, 1.12), IVORY)
		B:block(sting, v(0.7, 0.5, 0.7), C(0, 1.7, 1.2), IVORY)
		B:block(sting, v(0.36, 0.45, 0.36), C(0, 1.35, 1.28), BLACK2)
		B:gem(sting, v(0.62, 0.9, 0.62), C(0, 1.75, 1.2), NEONAMB, { tr = 1, name = "StingGlow" })
		local stingFX = B:block(sting, v(0.6, 0.6, 0.6), C(0, 1.4, 1.3), WHITE, { tr = 1, name = "StingFX" })
		B:emitter(stingFX, "spark", { name = "StingSpark", rate = 0, color = { "#ffffff", NEONAMB }, size = { 0.45, 0.25, 0 }, speed = { 5, 11 } })
		B:light(stingFX, { name = "StingLight", color = NEONAMB, brightness = 0, range = 9 })
		B:trail(sting, V(0, 1.4, 1.28), V(0, 2.1, 1.12), { name = "StingTrail", color = { "#ffffff", NEONAMB }, life = 0.18, trans = { 0.45, 1 } })

		------------------------------------------------------------------
		-- HEAD: big chunky honey head on top
		------------------------------------------------------------------
		local head = B:bone("Head", "Body", V(0, 10.3, -0.3))
		B:block(head, v(6.4, 3.4, 4.4), C(0, 12.1, -0.4), HONEY) -- skull (front face z = -2.6)
		B:block(head, v(5.4, 4.2, 4.2), C(0, 12.1, -0.35), HONEY) -- rounding step
		B:block(head, v(4.2, 4.6, 3.8), C(0, 12.1, -0.3), HONEY) -- dome step
		B:block(head, v(6.8, 2.4, 3.6), C(0, 12.0, -0.3), HONEY) -- cheek step
		B:block(head, v(3.6, 0.3, 3.0), C(0, 14.45, -0.3), HONEYD) -- crown seat
		B:block(head, v(4.4, 2.2, 0.3), C(0, 12.3, 1.9), HONEYD) -- back-of-head fuzz
		B:block(head, v(3.0, 0.5, 0.3), C(0, 13.65, 2.0), BLACK) -- back stripe
		B:block(head, v(3.0, 0.5, 0.3), C(0, 12.5, 2.0), BLACK)

		-- EYES (one pair, front face only)
		B:sym(function(side)
			local EY = 12.45
			local eye = B:bone("Eye" .. side, "Head", V(1.55, EY, -2.7))
			B:block(eye, v(2.5, 2.5, 0.3), C(1.55, EY, -2.62), BLACK) -- outline
			B:block(eye, v(2.3, 2.3, 0.4), C(1.55, EY, -2.78), WHITE)
			local pupil = B:bone("Pupil" .. side, "Eye" .. side, V(1.32, EY - 0.15, -3.0))
			B:block(pupil, v(1.05, 1.5, 0.12), C(1.32, EY - 0.15, -3.02), PUPIL)
			B:block(pupil, v(0.42, 0.42, 0.08), C(1.52, EY + 0.28, -3.1), WHITE, { name = "Glint" .. side })
			B:block(pupil, v(0.2, 0.2, 0.08), C(1.08, EY - 0.62, -3.1), WHITE)
			-- royal lashes at the outer corner (stepped up/out)
			B:block(eye, v(0.45, 0.3, 0.25), C(2.85, EY + 1.0, -2.75), BLACK)
			B:block(eye, v(0.3, 0.3, 0.25), C(3.1, EY + 1.25, -2.75), BLACK)
			-- smug half-lid (prop: shown only for haughty moments)
			B:block(eye, v(2.56, 1.05, 0.12), C(1.55, EY + 0.75, -3.04), HONEY, { tr = 1, name = "Half" .. side })
			B:block(eye, v(2.4, 0.22, 0.14), C(1.55, EY + 0.25, -3.05), BLACK, { tr = 1, name = "HalfLash" .. side })
			-- full blink lid (prop)
			B:block(eye, v(2.56, 2.56, 0.12), C(1.55, EY, -3.16), HONEY, { tr = 1, name = "Eyelid" .. side })
			B:block(eye, v(2.1, 0.3, 0.14), C(1.55, EY - 0.3, -3.2), BLACK, { tr = 1, name = "Lash" .. side })
			-- heavy, regal arched brow (inner low, outer stepped up)
			local brow = B:bone("Brow" .. side, "Head", V(1.6, 14.1, -2.9))
			B:block(brow, v(2.2, 0.6, 0.5), C(1.65, 14.12, -2.88, 0, 0, 9), BLACK)
			-- blush
			B:block(head, v(0.85, 0.4, 0.1), C(2.45, 11.12, -2.63), BLUSH)
		end)

		-- MOUTH: small open "D" mouth on the head + hinged chin (Jaw)
		B:block(head, v(1.6, 0.75, 0.1), C(0, 10.85, -2.62), MOUTH)
		B:block(head, v(1.0, 0.12, 0.08), C(0, 11.15, -2.67), WHITE) -- two little front teeth line
		local jaw = B:bone("Jaw", "Head", V(0, 11.0, -2.2))
		B:block(jaw, v(1.9, 0.5, 0.5), C(0, 10.3, -2.72), HONEY) -- chin
		B:block(jaw, v(1.4, 0.12, 0.3), C(0, 10.55, -2.6), MOUTH)
		B:block(jaw, v(0.9, 0.18, 0.12), C(0, 10.6, -2.69), TONGUE)
		-- tiny mandibles at the mouth corners
		B:sym(function(side)
			local mand = B:bone("Mand" .. side, "Head", V(1.0, 11.0, -2.7))
			B:block(mand, v(0.35, 0.5, 0.4), C(1.0, 10.8, -2.75), HONEYD)
			B:block(mand, v(0.25, 0.25, 0.3), C(0.9, 10.5, -2.8), BLACK2)
		end)

		-- ANTENNAE: stepped stacks rising beside the crown, tipping forward
		B:sym(function(side)
			local a1 = B:bone("Ant" .. side .. "1", "Head", V(2.2, 14.2, -1.2))
			B:block(a1, v(0.4, 0.9, 0.4), C(2.25, 14.6, -1.2), BLACK)
			local a2 = B:bone("Ant" .. side .. "2", "Ant" .. side .. "1", V(2.3, 15.0, -1.3))
			B:block(a2, v(0.36, 0.36, 0.7), C(2.4, 15.15, -1.55), BLACK)
			B:block(a2, v(0.6, 0.6, 0.6), C(2.55, 15.3, -1.95), HONEY)
			B:block(a2, v(0.3, 0.3, 0.3), C(2.7, 15.5, -2.25), HONEYL)
		end)

		-- head FX + steam (tantrum)
		local headFx = B:block(head, v(5, 1, 3), C(0, 14.6, -0.3), HONEY, { tr = 1, name = "SteamFX" })
		B:emitter(headFx, "smoke", {
			name = "Steam", rate = 0, color = { "#ffffff", "#ffe9c0" }, size = { 0.6, 1.4, 1.8 },
			speed = { 3, 6 }, life = { 0.5, 1.0 }, spread = 30, trans = { 0.3, 0.5, 1 },
		})

		-- expression props --------------------------------------------
		B:block(head, v(0.5, 1.1, 0.5), C(3.9, 15.0, -1.6), RED, { tr = 1, name = "Excl1" })
		B:block(head, v(0.5, 0.45, 0.5), C(3.9, 14.0, -1.6), RED, { tr = 1, name = "Excl2" })
		local AM = { { -3.25, 14.3 }, { -2.75, 14.3 }, { -3.0, 14.55 }, { -3.0, 14.05 } }
		for i, a in AM do
			local horiz = i > 2
			B:block(head, horiz and v(0.42, 0.13, 0.12) or v(0.13, 0.42, 0.12), C(a[1], a[2], -2.75), RED, { mat = "Neon", tr = 1, name = "Anger" .. i })
		end
		B:block(head, v(0.35, 0.5, 0.3), C(3.45, 13.3, -2.1), SWEAT, { tr = 1, name = "Sweat1" })
		B:block(head, v(0.22, 0.22, 0.22), C(3.45, 13.65, -2.1), SWEAT, { tr = 1, name = "Sweat2" })

		------------------------------------------------------------------
		-- CROWN: gold stepped band, velvet cap, stepped points, neon gems
		------------------------------------------------------------------
		local crown = B:bone("Crown", "Head", V(0, 14.4, -0.3))
		B:block(crown, v(3.8, 0.25, 3.4), C(0, 14.5, -0.3), GOLDD)
		B:block(crown, v(3.6, 0.65, 3.2), C(0, 14.85, -0.3), GOLD)
		B:block(crown, v(2.8, 0.55, 2.4), C(0, 15.2, -0.3), VELVET) -- velvet cap
		B:block(crown, v(1.6, 0.25, 1.4), C(0, 15.5, -0.3), PURPLED)
		B:block(crown, v(0.4, 0.4, 0.4), C(0, 15.65, -0.3), GOLD) -- top orb
		-- points: {x, z, tall}
		local PTS = { { 1.5, -1.65, false }, { -1.5, -1.65, false }, { 0, -1.65, true }, { 1.5, 1.05, false }, { -1.5, 1.05, false }, { 0, 1.05, true } }
		for _, p in PTS do
			B:block(crown, v(0.6, 0.4, 0.6), C(p[1], 15.35, p[2]), GOLD)
			B:block(crown, v(0.36, 0.3, 0.36), C(p[1], 15.7, p[2]), p[3] and GOLD or GOLDD)
		end
		B:sym(function()
			B:block(crown, v(0.6, 0.4, 0.6), C(1.65, 15.35, -0.3), GOLD) -- side points
			B:block(crown, v(0.36, 0.3, 0.36), C(1.65, 15.7, -0.3), GOLDD)
		end)
		for k = -1, 1, 2 do
			B:block(crown, v(0.3, 0.3, 0.1), C(k * 0.55, 14.85, -1.93), GOLDD)
			B:block(crown, v(0.3, 0.3, 0.1), C(k * 1.45, 14.85, -1.93), GOLDD)
		end
		local cg = B:gem(crown, v(0.55, 0.45, 0.14), C(0, 14.85, -1.95), MAG, { name = "CrownGem" })
		B:light(cg, { name = "CrownLight", color = MAG, brightness = 0, range = 8 })
		B:sym(function()
			B:gem(crown, v(0.14, 0.38, 0.38), C(1.86, 14.85, -0.3), NEONAMB)
			B:gem(crown, v(0.3, 0.3, 0.12), C(1.0, 14.85, -1.95), NEONAMB)
		end)
		local crownFx = B:block(crown, v(3.6, 1.2, 3.2), C(0, 15.2, -0.3), GOLD, { tr = 1, name = "CrownFX" })
		B:emitter(crownFx, "burst", { name = "CrownSparkle", color = { "#ffffff", GOLD, MAG }, size = { 0.5, 0.3, 0 }, speed = { 4, 9 } })

		------------------------------------------------------------------
		-- WINGS: two pairs of stepped translucent plates, buzzing
		------------------------------------------------------------------
		B:sym(function(side)
			-- upper pair: inner plates + a tip bone (follow-through)
			local WF = CFrame.new(V(1.5, 10.2, 2.4)) * ang(0, -25, 0) * ang(0, 0, 40)
			local wf = B:bone("WingF" .. side, "Body", WF)
			local FW = { 1.3, 2.1, 2.6, 2.8, 2.5, 1.8 }
			local WFT = WF * CFrame.new(3.3, 0.25, 0)
			local wft = B:bone("WingFT" .. side, "WingF" .. side, WFT)
			for i, w in FW do
				B:block(i <= 3 and wf or wft, v(1.06, w, 0.16), WF * CFrame.new(0.3 + (i - 0.5) * 1.0, 0.25, 0), WING, { tr = 0.3 })
			end
			B:block(wf, v(2.9, 0.22, 0.26), WF * CFrame.new(1.9, 0.35, 0), VEIN) -- vein
			B:block(wft, v(2.6, 0.22, 0.26), WF * CFrame.new(4.6, 0.35, 0), VEIN)
			B:block(wft, v(1.0, 0.2, 0.22), WF * CFrame.new(5.6, 1.05, 0), VEIN) -- tip rim
			B:block(wft, v(0.2, 1.4, 0.22), WF * CFrame.new(6.2, 0.25, 0), VEIN)
			B:block(wf, v(0.9, 0.9, 0.7), WF * CFrame.new(0.2, 0.2, 0), BLACK) -- wing root
			B:block(wf, v(0.5, 0.5, 0.8), WF * CFrame.new(0.2, 0.2, 0), HONEYL)
			B:trail(wft, (WF * CFrame.new(6.2, 1.0, 0)).Position, (WF * CFrame.new(6.2, -0.4, 0)).Position,
				{ name = "WingTrail" .. side, color = { "#ffffff", WING }, life = 0.1, trans = { 0.55, 1 } })
			-- lower pair (smaller, swept further back)
			local WB = CFrame.new(V(1.4, 9.2, 2.6)) * ang(0, -45, 0) * ang(0, 0, 10)
			local wb = B:bone("WingB" .. side, "Body", WB)
			local wbt = B:bone("WingBT" .. side, "WingB" .. side, WB * CFrame.new(2.1, -0.1, 0))
			local BW = { 1.1, 1.7, 2.0, 1.8, 1.2 }
			for i, w in BW do
				B:block(i <= 2 and wb or wbt, v(0.96, w, 0.16), WB * CFrame.new(0.3 + (i - 0.5) * 0.9, -0.1, 0), WING, { tr = 0.3 })
			end
			B:block(wb, v(2.0, 0.2, 0.24), WB * CFrame.new(1.2, 0.0, 0), VEIN)
			B:block(wbt, v(2.3, 0.2, 0.24), WB * CFrame.new(3.3, 0.0, 0), VEIN)
			B:block(wbt, v(0.2, 1.0, 0.22), WB * CFrame.new(4.65, -0.1, 0), VEIN)
			B:block(wb, v(0.8, 0.8, 0.6), WB * CFrame.new(0.15, 0, 0), BLACK)
		end)

		------------------------------------------------------------------
		-- ARMS: fluffy shoulder, black segments, little fists with claws
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Body", V(2.6, 8.7, -1.0))
			B:block(arm, v(1.3, 1.1, 1.3), C(2.95, 8.75, -1.05), HONEYL) -- fluffy shoulder
			B:block(arm, v(1.1, 0.3, 1.1), C(2.95, 9.35, -1.05), HONEY)
			B:block(arm, v(0.75, 1.6, 0.75), C(3.45, 7.75, -1.2), BLACK) -- upper arm
			local fore = B:bone("Fore" .. side, "Arm" .. side, V(3.65, 6.95, -1.3))
			B:block(fore, v(0.95, 0.5, 0.95), C(3.65, 7.0, -1.3), HONEYL) -- elbow fuzz
			B:block(fore, v(0.7, 0.7, 1.5), C(3.8, 6.7, -2.1), BLACK) -- forearm
			B:block(fore, v(0.95, 0.95, 0.3), C(3.85, 6.65, -2.75), GOLD) -- gold cuff
			B:block(fore, v(1.0, 1.0, 0.9), C(3.9, 6.65, -3.25), BLACK2) -- fist
			for k = -1, 1 do
				B:block(fore, v(0.24, 0.26, 0.22), C(3.9 + k * 0.3, 6.45, -3.75), IVORY) -- little claws
			end
			B:block(fore, v(0.3, 0.45, 0.5), C(3.35, 6.8, -3.2), BLACK) -- thumb
		end)

		-- HONEY-DIPPER SCEPTER (right hand)
		local sc = B:bone("Scepter", "ForeR", V(3.9, 6.65, -3.25))
		local SX, SZ = 3.9, -3.25
		B:block(sc, v(0.36, 4.8, 0.36), C(SX, 6.9, SZ), GOLD) -- handle
		B:block(sc, v(0.6, 0.5, 0.6), C(SX, 4.45, SZ), GOLDD) -- bottom knob
		B:block(sc, v(0.5, 0.2, 0.5), C(SX, 8.0, SZ), GOLDD)
		B:block(sc, v(0.5, 0.2, 0.5), C(SX, 8.8, SZ), GOLDD)
		-- grooved dipper head, dripping honey
		B:block(sc, v(0.7, 0.3, 0.7), C(SX, 9.35, SZ), GOLDD)
		B:block(sc, v(1.3, 0.45, 1.3), C(SX, 9.7, SZ), AMBER)
		B:block(sc, v(0.95, 0.3, 0.95), C(SX, 10.05, SZ), AMBERD)
		B:block(sc, v(1.45, 0.45, 1.45), C(SX, 10.4, SZ), AMBER)
		B:block(sc, v(0.95, 0.3, 0.95), C(SX, 10.75, SZ), AMBERD)
		B:block(sc, v(1.25, 0.45, 1.25), C(SX, 11.1, SZ), AMBER)
		B:block(sc, v(0.6, 0.35, 0.6), C(SX, 11.5, SZ), GOLD)
		B:gem(sc, v(0.36, 0.36, 0.36), C(SX, 11.85, SZ), MAG, { name = "ScepterGem" })
		B:block(sc, v(0.35, 0.5, 0.35), C(SX + 0.4, 9.3, SZ - 0.35), AMBER, { tr = 0.15 }) -- honey drips
		B:block(sc, v(0.25, 0.3, 0.25), C(SX + 0.4, 8.9, SZ - 0.35), AMBER, { tr = 0.15 })
		B:block(sc, v(0.3, 0.4, 0.3), C(SX - 0.45, 9.35, SZ + 0.3), AMBERD, { tr = 0.15 })
		local dip = B:block(sc, v(1.2, 1.4, 1.2), C(SX, 10.4, SZ), AMBER, { tr = 1, name = "DipperFX" })
		B:emitter(dip, "drip", { name = "HoneyDrip", color = { "#ffc040", AMBER }, rate = 1.2, size = { 0.3, 0.25, 0.12 } })
		B:emitter(dip, "burst", { name = "HoneyBurst", color = { "#ffd060", AMBER, "#ffffff" }, size = { 0.6, 0.4, 0 }, speed = { 6, 12 } })
		B:light(dip, { name = "ScepterLight", color = NEONAMB, brightness = 0, range = 9 })
		B:trail(sc, V(SX, 11.8, SZ), V(SX, 9.5, SZ), { name = "ScepterTrail", color = { "#ffffff", NEONAMB }, life = 0.18, trans = { 0.45, 1 } })
		B:trail("ForeL", V(-3.9, 7.1, -3.3), V(-3.9, 6.2, -3.3), { name = "FistTrailL", color = { "#ffffff", GOLD }, life = 0.14, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- LEGS: 2 front + 2 back short legs dangling under the thorax
		------------------------------------------------------------------
		B:sym(function(side)
			local lf = B:bone("LegF" .. side, "Body", V(1.3, 7.0, -2.5))
			B:block(lf, v(0.6, 1.1, 0.6), C(1.3, 6.5, -2.6), BLACK)
			local sf = B:bone("ShinF" .. side, "LegF" .. side, V(1.3, 6.0, -2.6))
			B:block(sf, v(0.85, 0.4, 0.85), C(1.3, 5.95, -2.6), HONEYL) -- knee fuzz
			B:block(sf, v(0.55, 1.1, 0.55), C(1.3, 5.35, -2.62), BLACK)
			B:block(sf, v(0.75, 0.5, 1.0), C(1.3, 4.75, -2.75), BLACK2) -- little boot
			B:block(sf, v(0.55, 0.22, 0.2), C(1.3, 4.62, -3.3), GOLD) -- gold toe cap
			-- tiny back legs tucked against the sides of the abdomen
			local lb = B:bone("LegB" .. side, "Body", V(2.4, 7.0, -1.2))
			B:block(lb, v(0.5, 0.9, 0.5), C(2.55, 6.55, -1.9), BLACK)
			B:block(lb, v(0.65, 0.3, 0.65), C(2.55, 6.05, -1.9), HONEYL)
			B:block(lb, v(0.45, 0.8, 0.45), C(2.6, 5.5, -2.2), BLACK)
			B:block(lb, v(0.6, 0.4, 0.8), C(2.6, 5.0, -2.35), BLACK2)
		end)

		------------------------------------------------------------------
		-- Floating garden voxels: honeycomb chunks, a honey drop, a flower
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", V(0, 8, 0.5))
		local ORBS = { { 5.6, 12.0, -2.2 }, { -5.9, 9.5, 0.8 }, { 5.0, 4.6, 2.2 }, { -5.2, 4.2, -2.4 }, { -4.6, 13.4, -1.6 }, { 4.4, 7.6, 4.2 } }
		for i, p in ORBS do
			local ob = B:bone("Orb" .. i, "Orbit", V(p[1], p[2], p[3]))
			local x, y, z = p[1], p[2], p[3]
			if i >= 5 then -- little flower bud
				B:block(ob, v(0.4, 0.4, 0.4), C(x, y, z), HONEYL)
				B:block(ob, v(0.9, 0.25, 0.3), C(x, y, z), i == 5 and PINK or CREAM)
				B:block(ob, v(0.3, 0.25, 0.9), C(x, y, z), i == 5 and PINK or CREAM)
				B:block(ob, v(0.14, 0.5, 0.14), C(x, y - 0.4, z), LEAFD)
			elseif i == 1 or i == 3 then -- honeycomb chunk
				B:block(ob, v(0.9, 0.8, 0.9), C(x, y, z), AMBER)
				B:block(ob, v(0.95, 0.2, 0.95), C(x, y + 0.45, z), HONEYL)
				B:block(ob, v(0.4, 0.4, 0.1), C(x, y, z - 0.47), AMBERD)
			elseif i == 2 then -- flower
				B:block(ob, v(0.45, 0.45, 0.45), C(x, y, z), GOLD)
				B:block(ob, v(1.25, 0.3, 0.4), C(x, y, z), PINK)
				B:block(ob, v(0.4, 0.3, 1.25), C(x, y, z), PINK)
				B:block(ob, v(0.18, 0.7, 0.18), C(x, y - 0.55, z), LEAFD)
				B:block(ob, v(0.45, 0.12, 0.25), C(x + 0.2, y - 0.6, z), LEAF)
			else -- honey drop (stepped)
				B:block(ob, v(0.75, 0.6, 0.75), C(x, y, z), AMBER)
				B:block(ob, v(0.45, 0.35, 0.45), C(x, y + 0.45, z), AMBER)
				B:gem(ob, v(0.2, 0.2, 0.2), C(x + 0.2, y + 0.15, z - 0.35), NEONAMB)
			end
		end
		local petals = B:block("Root", v(6, 0.3, 6), cf(0, 0.2, 0), WHITE, { tr = 1, name = "PetalFX" })
		B:emitter(petals, "leaf", {
			name = "PetalBurst", rate = 0, color = { PINK, LEAF, HONEYL }, size = { 0.45, 0.4, 0.25 },
			speed = { 4, 9 }, spread = 70, life = { 1.0, 2.0 }, accel = { 0, -5, 0 },
		})
	end,
}
