--!nocheck
-- Atlantis Sky Whale (Divine): the gentle, motherly guardian of the lost city.
-- A colossal stud-built whale hovering through the air with a whole miniature
-- Atlantis on her back. Personality: warm, kind, protective and a little
-- goofy - she hums songs, peeks back at her city, pats it with a flipper,
-- spouts fountains from her blowhole and giggles when the city fish boop her.
--
-- FACE (one pair of eyes, ONE mouth): big front-facing googly eyes with
-- sky-blue irises, glints and hidden sparkle stars, soft arched brows,
-- puffy rosy cheeks, and ONE real hinged jaw: dark mouth interior, pink
-- tongue, little block teeth top and bottom, lip rims and smile creases.
-- Hidden faces: blink lids, content half-lids, happy ^ ^ arcs, big blush.
--
-- BODY: stepped ocean-blue hull (dark back, light countershade band, cream
-- pleated belly), two gold orichalcum harness bands with rune medallions,
-- humpback flippers with gold bracers, a ridged tail chain with gold rings
-- and big stepped flukes with gold leading edges.
--
-- CITY: gold-trimmed marble island with the classic Atlantis concentric
-- rings (outer wall + corner turrets + gate, water moat, garden terrace with
-- little houses, inner moat, central island), a columned temple with a
-- stepped gold dome, a crystal spire, four towers that RISE, waterfalls
-- spilling off both flanks, coral, seaweed and broken ruins.
--
-- VFX props (hidden until used): spire beam + halo of rays, firework chunks,
-- blowhole fountain, splash crown, music notes, hearts, 3 tiny city fish.
return {
	DisplayName = "Atlantis Sky Whale",
	Rarity = "Divine",
	Element = "Atlantis",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		------------------------------------------------------------------
		-- palette
		------------------------------------------------------------------
		local MAIN, DARK, DEEPB, SPOT = "#2f74cf", "#1d4a98", "#13306a", "#7ec3f2"
		local CREAM, GROOVE = "#f4e7c6", "#d3bd8f"
		local MARBLE, MARBLE2 = "#f6f3ec", "#d8d2c4"
		local GOLD, DGOLD = "#f2c03e", "#b9862a"
		local TURQ, TURQL, TEAL = "#2ec4b6", "#86ece2", "#1f8f8a"
		local WATER, WATERF, FOAM = "#3fa9ec", "#8fdcff", "#eafcff"
		local CORAL, CORAL2, WEED, GRASS = "#ff6f91", "#ff9a4a", "#3fae5a", "#5cc96e"
		local EYEW, IRIS, PUPIL, BROW = "#fdfbf4", "#3d8ff0", "#0d1428", "#10224d"
		local MOUTH, MOUTH2, TONGUE, TONGUED = "#3a1030", "#24081e", "#ff8fa8", "#e66a8a"
		local BLUSH, BLUSHD, TOOTH = "#ff9fba", "#f06a92", "#ffffff"
		local NT, NS, NG = "#3ff0e0", "#6fe3ff", "#ffe27a" -- neon turquoise / sky / gold
		local NEON = { mat = "Neon" }
		local HIDE = function(name, extra)
			local o = { tr = 1, name = name }
			if extra then
				for k, x in extra do
					o[k] = x
				end
			end
			return o
		end

		------------------------------------------------------------------
		-- BODY: stepped hull (pivot = body centre)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 10, -1))
		local function slab(w, y0, y1, z0, z1, col, opts)
			return B:block(body, v(w, y1 - y0, z1 - z0), cf(0, (y0 + y1) / 2, (z0 + z1) / 2), col, opts)
		end
		slab(7.4, 3.9, 5.0, -7.2, 4.8, CREAM) -- belly keel
		slab(10.8, 4.9, 6.4, -8.2, 5.7, CREAM)
		slab(12.6, 6.3, 7.3, -8.5, 6.0, SPOT) -- countershade band
		slab(13.2, 7.2, 11.3, -8.5, 6.0, MAIN)
		slab(12.4, 11.2, 12.6, -8.3, 5.8, DARK)
		slab(10.4, 12.5, 13.6, -8.0, 5.4, DARK)
		slab(8.4, 13.5, 14.2, -7.6, 5.0, DEEPB)
		-- belly pleats (grooves on the sides + bottom)
		B:sym(function()
			B:block(body, v(0.12, 0.22, 12.6), cf(5.42, 5.4, -1.25), GROOVE)
			B:block(body, v(0.12, 0.22, 12.0), cf(5.42, 5.95, -1.25), GROOVE)
			B:block(body, v(0.22, 0.12, 11.4), cf(2.2, 3.85, -1.2), GROOVE)
			-- light freckles on the flanks
			B:block(body, v(0.12, 0.8, 1.6), cf(6.62, 10.2, 0.8), SPOT)
			B:block(body, v(0.12, 0.8, 0.8), cf(6.62, 9.4, 1.2), SPOT)
			B:block(body, v(0.12, 0.8, 1.0), cf(6.62, 10.5, -3.9), SPOT)
			B:block(body, v(0.12, 0.6, 0.6), cf(6.25, 11.9, -2.0), SPOT)
			-- barnacle cluster + coral on the lower flank
			B:block(body, v(0.6, 0.6, 0.6), cf(6.6, 7.9, 4.6), MARBLE2)
			B:block(body, v(0.45, 0.45, 0.45), cf(6.65, 8.5, 4.1), MARBLE)
			B:block(body, v(0.5, 0.9, 0.5), cf(6.7, 8.0, -7.2), CORAL)
			-- ORICHALCUM HARNESS: two gold bands with rune medallions
			for _, z in { -5.9, 3.5 } do
				B:block(body, v(0.5, 5.2, 1.4), cf(6.75, 9.5, z), GOLD)
				B:block(body, v(0.5, 1.6, 1.4), cf(6.35, 12.2, z), GOLD)
				B:block(body, v(0.5, 1.2, 1.4), cf(5.35, 13.3, z), GOLD)
				B:block(body, v(0.5, 1.4, 1.4), cf(5.6, 5.6, z), DGOLD)
				B:block(body, v(0.3, 1.3, 1.3), cf(7.05, 9.5, z), TEAL)
				B:block(body, v(0.2, 0.5, 0.5), cf(7.25, 9.5, z), NT, NEON)
			end
		end)
		B:block(body, v(7.6, 0.4, 1.4), cf(0, 3.75, -5.9), DGOLD)
		B:block(body, v(7.6, 0.4, 1.4), cf(0, 3.75, 3.5), DGOLD)
		local bodyFx = B:block(body, v(12, 8, 24), cf(0, 10, 1), MAIN, HIDE("BodyFX"))
		B:emitter(bodyFx, "bubble", { name = "AmbientBubbles", color = { "#ffffff", "#9fe2ff" }, rate = 5, size = { 0.3, 0.5, 0.6 } })

		-- swelling belly (deep breath)
		local belly = B:bone("Belly", "Body", v(0, 4.4, -1))
		B:block(belly, v(6.2, 0.9, 9.6), cf(0, 3.65, -1.2), CREAM)
		B:block(belly, v(4.2, 0.6, 7.0), cf(0, 3.05, -1.2), CREAM)
		for _, x in { -1.4, 0, 1.4 } do
			B:block(belly, v(0.25, 0.12, 6.6), cf(x, 2.7, -1.2), GROOVE)
		end

		------------------------------------------------------------------
		-- HEAD (big cartoon head, face on the front)
		------------------------------------------------------------------
		local head = B:bone("Head", "Body", v(0, 10, -7.6))
		local function hb(sx, sy, sz, x, y, z, col, opts, rx, ry, rz)
			return B:block(head, v(sx, sy, sz), cf(x, y, z, rx or 0, ry or 0, rz or 0), col, opts)
		end
		hb(11.6, 5.4, 2.4, 0, 11.5, -7.6, MAIN) -- neck plug
		hb(12.6, 5.0, 8.8, 0, 11.3, -12.2, MAIN) -- skull
		hb(13.2, 2.6, 5.4, 0, 10.3, -13.7, MAIN) -- cheek bulge (stepped)
		hb(11.4, 1.0, 8.2, 0, 14.25, -12.1, DARK) -- upper skull step
		hb(9.0, 0.9, 6.6, 0, 15.15, -11.9, DEEPB) -- melon top
		hb(3.0, 0.2, 1.4, 1.6, 15.65, -13.0, SPOT)
		hb(1.4, 0.2, 1.0, -2.2, 15.65, -10.4, SPOT)
		hb(11.0, 4.8, 1.2, 0, 11.2, -17.1, MAIN) -- face front
		hb(9.6, 1.1, 2.2, 0, 14.15, -16.5, MAIN) -- brow plateau
		hb(10.0, 1.5, 1.2, 0, 9.55, -18.1, MAIN) -- snout / upper lip
		hb(6.0, 0.25, 0.4, 0, 10.2, -18.6, SPOT) -- lip highlight
		hb(10.4, 0.3, 8.6, 0, 8.72, -13.4, MOUTH) -- palate (mouth roof)
		hb(10.6, 1.4, 0.3, 0, 8.3, -9.6, MOUTH2) -- back of the throat
		-- little block teeth hanging from the upper lip
		for _, x in { -2.1, -0.7, 0.7, 2.1 } do
			hb(0.6, 0.55, 0.5, x, 8.55, -18.15, TOOTH)
		end
		B:sym(function()
			hb(0.5, 0.45, 0.45, 3.4, 8.6, -17.7, TOOTH)
			-- smile creases curling up at the back corners of the mouth
			hb(0.12, 0.9, 0.5, 6.32, 9.25, -9.9, DEEPB)
			hb(0.12, 0.5, 0.5, 6.32, 9.85, -9.5, DEEPB)
			-- side freckles
			hb(0.12, 0.6, 1.2, 6.32, 12.2, -11.0, SPOT)
			hb(0.12, 0.6, 0.6, 6.62, 10.6, -12.4, SPOT)
		end)
		-- orichalcum diadem on the forehead: gold band, 3 points, turquoise gem
		hb(5.0, 0.45, 0.5, 0, 15.75, -14.9, GOLD)
		hb(1.2, 1.0, 0.5, 0, 16.4, -14.9, GOLD)
		hb(0.7, 0.75, 0.3, 0, 16.4, -15.2, TEAL)
		hb(0.35, 0.4, 0.15, 0, 16.45, -15.4, NT, NEON)
		B:sym(function()
			hb(0.6, 0.6, 0.5, 1.6, 16.15, -14.9, GOLD)
			hb(0.3, 0.3, 0.2, 1.6, 16.55, -14.9, NG, NEON)
		end)
		-- blowholes (the fountain comes out here)
		hb(0.5, 0.2, 1.0, 0.45, 15.62, -10.3, MOUTH2)
		hb(0.5, 0.2, 1.0, -0.45, 15.62, -10.3, MOUTH2)

		-- EYES: front-facing, slightly turned out, never wrapping a corner
		B:sym(function(side)
			local EF = CFrame.new(3.05, 12.35, -18.0) * ang(0, -10, 0)
			local function e(sx, sy, sz, x, y, z, col, opts, bone)
				return B:block(bone, v(sx, sy, sz), EF * CFrame.new(x, y, z), col, opts)
			end
			local eye = B:bone("Eye" .. side, "Head", EF)
			e(3.7, 3.3, 1.3, 0, 0, 0.1, BROW, nil, eye) -- dark rim (rounded = 2 crossed blocks)
			e(2.9, 4.1, 1.3, 0, 0, 0.1, BROW, nil, eye)
			e(3.3, 2.9, 1.3, 0, 0, -0.2, EYEW, nil, eye) -- white
			e(2.5, 3.7, 1.3, 0, 0, -0.21, EYEW, nil, eye)
			local pup = B:bone("Pupil" .. side, "Eye" .. side, EF * CFrame.new(0, -0.15, -0.85))
			e(2.2, 2.6, 0.2, 0, -0.15, -0.9, IRIS, nil, pup)
			e(1.6, 2.0, 0.2, 0, -0.2, -0.97, PUPIL, nil, pup)
			-- hidden sparkle star in the eye (excited / proud moments)
			e(0.3, 1.3, 0.1, 0, -0.15, -1.06, NG, HIDE("StarA" .. side, NEON), pup)
			e(1.3, 0.3, 0.1, 0, -0.15, -1.06, NG, HIDE("StarB" .. side, NEON), pup)
			-- lids (hidden): blink lid + lash, happy ^ ^ arcs, content half-lid
			local lid = B:bone("Lid" .. side, "Eye" .. side, EF)
			e(3.5, 3.9, 1.65, 0, 0, -0.35, MAIN, HIDE("Lid" .. side), lid)
			e(2.8, 0.35, 0.2, 0, -0.35, -1.15, BROW, HIDE("Lash" .. side), lid)
			e(1.3, 0.4, 0.2, 0, 0.45, -1.16, BROW, HIDE("HapA" .. side), lid)
			B:block(lid, v(1.0, 0.4, 0.2), EF * CFrame.new(-0.95, 0.0, -1.16) * ang(0, 0, 40), BROW, HIDE("HapC" .. side))
			B:block(lid, v(1.0, 0.4, 0.2), EF * CFrame.new(0.95, 0.0, -1.16) * ang(0, 0, -40), BROW, HIDE("HapD" .. side))
			e(3.5, 1.5, 1.5, 0, 1.25, -0.4, MAIN, HIDE("Half" .. side), lid)
			e(3.0, 0.3, 0.2, 0, 0.5, -1.17, BROW, HIDE("HalfLash" .. side), lid)
			-- soft lower lid under the eye
			e(2.6, 0.45, 0.5, 0, -2.15, -0.6, SPOT, nil, eye)
			-- gentle arched brow (2 pieces: kind, soft arch)
			local brow = B:bone("Brow" .. side, "Head", v(3.05, 15.0, -17.9))
			B:block(brow, v(1.7, 0.6, 0.9), cf(2.25, 14.95, -17.95, 0, 0, 14), BROW)
			B:block(brow, v(1.7, 0.6, 0.9), cf(3.75, 15.05, -17.95, 0, 0, -16), BROW)
			-- puffy rosy cheek
			local ck = B:bone("Cheek" .. side, "Head", v(5.0, 10.1, -17.6))
			B:block(ck, v(2.3, 1.7, 1.4), cf(5.0, 10.2, -17.95), SPOT)
			B:block(ck, v(1.5, 0.7, 0.1), cf(5.0, 10.25, -18.68), BLUSH)
			B:block(ck, v(2.0, 1.1, 0.1), cf(5.0, 10.25, -18.74), BLUSH, HIDE("BlushBig" .. side))
			for k = 1, 3 do
				B:block(ck, v(0.14, 0.75, 0.1), cf(4.3 + k * 0.35, 10.25, -18.8, 0, 0, -25), BLUSHD, HIDE("BlushLine" .. side .. k))
			end
		end)
		-- glints on the same side of both eyes (cartoon convention)
		local function glint(side, x)
			local EF = CFrame.new(side == "R" and 3.05 or -3.05, 12.35, -18.0) * ang(0, side == "R" and -10 or 10, 0)
			B:block("Pupil" .. side, v(0.75, 0.75, 0.1), EF * CFrame.new(x, 0.55, -1.06), "#ffffff", { mat = "Neon", name = "GlintA" .. side })
			B:block("Pupil" .. side, v(0.35, 0.35, 0.1), EF * CFrame.new(-x * 0.8, -0.85, -1.06), "#ffffff", { mat = "Neon", name = "GlintB" .. side })
		end
		glint("R", 0.5)
		glint("L", 0.5)

		-- music notes (hidden) that float out of her mouth while she hums
		for k = 1, 3 do
			local nb = B:bone("Note" .. k, "Head", v(0, 9.5, -19.2))
			local s = k == 2 and -1 or 1
			B:block(nb, v(0.3, 1.3, 0.3), cf(0.25 * s, 10.0, -19.2), NG, HIDE("NoteS" .. k, NEON))
			B:block(nb, v(0.75, 0.6, 0.3), cf(-0.05 * s, 9.4, -19.2), NG, HIDE("NoteH" .. k, NEON))
			B:block(nb, v(0.6, 0.3, 0.3), cf(0.6 * s, 10.5, -19.2), NG, HIDE("NoteF" .. k, NEON))
		end
		-- hearts (hidden) that float up when she is happy
		for k = 1, 3 do
			local hx = ({ 0, 3.2, -3.2 })[k]
			local hp = v(hx, 16.6, -14.5)
			local hbn = B:bone("Heart" .. k, "Head", hp)
			B:block(hbn, v(0.65, 0.65, 0.4), CFrame.new(hp + v(0.38, 0.3, 0)), BLUSH, HIDE("HeartA" .. k))
			B:block(hbn, v(0.65, 0.65, 0.4), CFrame.new(hp + v(-0.38, 0.3, 0)), BLUSH, HIDE("HeartB" .. k))
			B:block(hbn, v(1.4, 0.5, 0.4), CFrame.new(hp + v(0, -0.1, 0)), BLUSH, HIDE("HeartC" .. k))
			B:block(hbn, v(0.7, 0.7, 0.42), CFrame.new(hp + v(0, -0.5, 0)) * ang(0, 0, 45), BLUSHD, HIDE("HeartD" .. k))
		end
		-- blowhole fountain (hidden water column)
		local spout = B:bone("Spout", "Head", v(0, 15.6, -10.3))
		B:block(spout, v(0.9, 1.6, 0.9), cf(0, 16.5, -10.3), WATERF, HIDE("SpoutA"))
		B:block(spout, v(1.2, 1.6, 1.2), cf(0, 18.0, -10.3), WATERF, HIDE("SpoutB"))
		B:block(spout, v(1.6, 1.2, 1.6), cf(0, 19.3, -10.3), FOAM, HIDE("SpoutC"))
		B:block(spout, v(3.0, 0.6, 1.0), cf(0, 20.1, -10.3), FOAM, HIDE("SpoutD"))
		B:block(spout, v(1.0, 0.6, 3.0), cf(0, 20.15, -10.3), FOAM, HIDE("SpoutE"))
		local spoutFx = B:block(spout, v(1, 1, 1), cf(0, 19.6, -10.3), MAIN, HIDE("SpoutFX"))
		B:emitter(spoutFx, "burst", { name = "SpoutSpray", color = { "#ffffff", WATERF, NS }, speed = { 5, 10 }, size = { 0.6, 0.45, 0 }, life = { 0.6, 1.2 }, spread = 70, accel = { 0, -16, 0 } })

		------------------------------------------------------------------
		-- JAW: the ONE mouth (hinge at the back of the mouth)
		------------------------------------------------------------------
		local jaw = B:bone("Jaw", "Head", v(0, 8.75, -9.3))
		local function jb(sx, sy, sz, x, y, z, col, opts)
			return B:block(jaw, v(sx, sy, sz), cf(x, y, z), col, opts)
		end
		jb(12.0, 1.1, 9.2, 0, 7.25, -13.7, MAIN) -- jaw base
		jb(11.2, 0.95, 0.8, 0, 8.27, -17.9, SPOT) -- lower lip (front rim)
		jb(10.4, 0.3, 8.4, 0, 7.95, -13.5, MOUTH) -- mouth floor
		jb(4.4, 0.45, 5.2, 0, 8.25, -14.4, TONGUE) -- tongue
		jb(0.3, 0.1, 3.6, 0, 8.5, -14.6, TONGUED)
		jb(11.0, 1.45, 9.0, 0, 6.05, -13.4, CREAM) -- pleated throat
		jb(8.4, 0.8, 7.2, 0, 4.95, -13.3, CREAM) -- stepped chin
		jb(11.1, 0.15, 8.6, 0, 6.3, -13.4, GROOVE)
		for _, x in { -2.8, -1.0, 1.0, 2.8 } do
			jb(0.3, 0.12, 6.8, x, 4.52, -13.3, GROOVE)
		end
		for _, x in { -2.8, -1.4, 1.4, 2.8 } do
			jb(0.55, 0.5, 0.45, x, 8.95, -17.75, TOOTH)
		end
		B:sym(function()
			jb(0.8, 0.95, 8.6, 5.6, 8.27, -13.6, MAIN) -- side lip rims
			jb(0.85, 0.2, 8.0, 5.6, 8.8, -13.8, SPOT)
		end)

		------------------------------------------------------------------
		-- FLIPPERS: long humpback flippers with gold bracers
		------------------------------------------------------------------
		B:sym(function(side)
			local F = CFrame.new(6.4, 7.8, -5.0) * ang(0, -28, -12)
			local function at(x, y, z, rz)
				return F * CFrame.new(x, y, z) * ang(0, 0, rz or 0)
			end
			local arm = B:bone("Fin" .. side, "Body", F)
			B:block(arm, v(4.2, 1.2, 3.4), at(1.5, 0, 0), MAIN)
			B:block(arm, v(3.8, 0.3, 3.0), at(1.8, -0.65, 0.1), CREAM)
			B:block(arm, v(0.9, 1.6, 3.8), at(3.0, 0, 0), GOLD) -- bracer
			B:block(arm, v(0.95, 0.5, 1.2), at(3.0, 0.6, 0), TEAL)
			B:block(arm, v(0.3, 0.2, 2.6), at(3.0, 0.82, 0), NT, NEON)
			local tip = B:bone("FinTip" .. side, "Fin" .. side, at(3.4, 0, 0))
			B:block(tip, v(3.9, 0.95, 3.2), at(5.2, 0, 0.3), MAIN)
			B:block(tip, v(3.2, 0.8, 2.6), at(8.2, 0, 0.9), MAIN)
			B:block(tip, v(2.2, 0.7, 1.8), at(10.5, 0, 1.4), DARK)
			B:block(tip, v(3.4, 0.3, 2.8), at(6.6, -0.55, 0.6), CREAM)
			-- humpback tubercles (cream bumps on the leading edge)
			B:block(tip, v(1.2, 1.0, 0.7), at(4.3, 0, -1.45), CREAM)
			B:block(tip, v(1.1, 0.9, 0.7), at(6.1, 0, -1.1), CREAM)
			B:block(tip, v(1.0, 0.8, 0.6), at(7.9, 0, -0.5), CREAM)
			B:block(tip, v(0.9, 0.7, 0.55), at(9.6, 0, 0.1), CREAM)
			B:block(tip, v(0.6, 1.2, 3.3), at(7.0, 0, 0.6), GOLD)
			B:block(tip, v(1.4, 0.2, 1.2), at(8.6, 0.45, 1.1), SPOT)
			B:block(tip, v(0.6, 0.5, 0.6), at(11.6, 0, 1.7), NT, NEON)
			B:trail(tip, at(11.6, 0, 1.8).Position, at(9.8, 0, 2.2).Position, { name = "FinTrail" .. side, color = { "#ffffff", NT }, life = 0.4, trans = { 0.45, 1 } })
		end)

		------------------------------------------------------------------
		-- TAIL chain (ridged) + flukes
		------------------------------------------------------------------
		local function seg(bone, w, y0, y1, z0, z1)
			local yc, d = (y0 + y1) / 2, z1 - z0
			local zc = (z0 + z1) / 2
			local h = y1 - y0
			B:block(bone, v(w, h, d), cf(0, yc, zc), MAIN)
			B:block(bone, v(w - 1.0, h * 0.22, d - 0.1), cf(0, y1 - h * 0.11 + 0.05, zc), DARK)
			B:block(bone, v(w + 0.1, h * 0.2, d - 0.2), cf(0, y0 + h * 0.1, zc), CREAM)
			B:block(bone, v(w + 0.12, h * 0.1, d - 0.2), cf(0, y0 + h * 0.25, zc), SPOT)
		end
		local function knob(bone, y, z, s)
			B:block(bone, v(0.9 * s, 0.7 * s, 1.5 * s), cf(0, y + 0.3 * s, z), CREAM)
			B:block(bone, v(0.55 * s, 0.6 * s, 0.9 * s), cf(0, y + 0.85 * s, z + 0.2), GOLD)
		end
		local t1 = B:bone("Tail1", "Body", v(0, 10, 5.4))
		seg(t1, 10.4, 5.4, 13.4, 5.2, 10.6)
		B:block(t1, v(9.8, 7.4, 2.0), cf(0, 9.6, 5.0), MAIN) -- plug
		knob(t1, 13.4, 7.0, 1.1)
		knob(t1, 13.4, 9.4, 1.0)
		B:sym(function()
			B:block(t1, v(0.12, 0.7, 1.4), cf(5.25, 10.4, 8.0), SPOT)
			B:block(t1, v(0.5, 0.5, 0.5), cf(5.3, 7.9, 9.5), MARBLE2)
		end)

		local t2 = B:bone("Tail2", "Tail1", v(0, 10.2, 10.4))
		seg(t2, 7.6, 6.8, 12.6, 10.4, 14.8)
		B:block(t2, v(7.2, 5.4, 1.6), cf(0, 9.7, 10.4), MAIN)
		knob(t2, 12.6, 11.6, 0.9)
		knob(t2, 12.6, 13.6, 0.8)
		B:block(t2, v(7.8, 6.0, 0.6), cf(0, 9.7, 14.3), GOLD) -- orichalcum tail ring
		B:block(t2, v(7.86, 0.25, 0.3), cf(0, 9.7, 14.3), NT, NEON)

		local t3 = B:bone("Tail3", "Tail2", v(0, 10.3, 14.6))
		seg(t3, 4.8, 8.2, 12.0, 14.6, 17.8)
		B:block(t3, v(4.4, 3.6, 1.4), cf(0, 10.1, 14.6), MAIN)
		knob(t3, 12.0, 16.0, 0.7)
		B:block(t3, v(5.0, 4.2, 0.5), cf(0, 10.1, 17.4), GOLD)
		B:block(t3, v(5.06, 0.25, 0.3), cf(0, 10.1, 17.4), NT, NEON)

		local fluke = B:bone("Fluke", "Tail3", v(0, 10.1, 17.8))
		B:block(fluke, v(3.8, 1.6, 2.6), cf(0, 10.1, 18.9), MAIN)
		B:block(fluke, v(2.4, 0.3, 2.2), cf(0, 10.95, 18.9), DARK)
		B:sym(function(side)
			local lobes = {
				{ 2.6, 19.2, 2.6, 3.0, 1.2, MAIN },
				{ 4.8, 19.8, 2.2, 2.8, 1.1, MAIN },
				{ 6.8, 20.5, 2.0, 2.4, 1.0, DARK },
				{ 8.5, 21.1, 1.8, 1.8, 0.9, DARK },
				{ 9.8, 21.6, 1.2, 1.2, 0.8, DARK },
			}
			for i, l in lobes do
				B:block(fluke, v(l[3], l[5], l[4]), cf(l[1], 10.1, l[2]), l[6])
				if i <= 4 then
					-- gold leading edge (orichalcum armour)
					B:block(fluke, v(l[3] + 0.05, l[5] + 0.1, 0.45), cf(l[1], 10.1, l[2] - l[4] / 2 + 0.15), GOLD)
				end
			end
			B:block(fluke, v(4.4, 0.25, 2.4), cf(3.8, 9.4, 19.6), CREAM)
			B:block(fluke, v(1.6, 0.2, 1.2), cf(4.6, 10.72, 20.0), SPOT)
			B:block(fluke, v(0.6, 0.6, 0.6), cf(10.4, 10.1, 22.0), NT, NEON)
			B:trail(fluke, v(10.4, 10.1, 22.1), v(8.6, 10.1, 21.7), { name = "FlukeTrail" .. side, color = { "#ffffff", NS }, life = 0.45, trans = { 0.4, 1 } })
		end)

		-- splash crown at the slap point (Root-carried, hidden)
		local splash = B:bone("Splash", "Root", v(0, 0, 18.5))
		for i = 1, 8 do
			local a = math.rad((i - 1) * 45 + 22.5)
			local x, z = 7.5 * math.cos(a), 3.8 * math.sin(a)
			local yaw = math.deg(math.atan2(x, z))
			local h = (i % 2 == 0) and 2.6 or 3.8
			B:block(splash, v(0.9, h, 0.9), CFrame.new(x, 0.15, 18.5 + z) * ang(0, yaw, 0) * ang(28, 0, 0) * CFrame.new(0, h / 2, 0), i % 2 == 0 and FOAM or WATERF, HIDE("SplashCol" .. i))
		end
		local splashFx = B:block(splash, v(14, 0.6, 6), cf(0, 0.5, 18.5), MAIN, HIDE("SplashFX"))
		B:emitter(splashFx, "burst", { name = "SplashBurst", color = { "#ffffff", NS, WATERF }, size = { 1.2, 0.8, 0 }, speed = { 10, 22 }, life = { 0.6, 1.3 }, spread = 70, accel = { 0, -20, 0 } })
		B:emitter(splashFx, "dust", { name = "SplashMist", color = { "#ffffff", "#cfefff" }, speed = { 8, 14 } })

		------------------------------------------------------------------
		-- THE LOST CITY OF ATLANTIS (on her back)
		------------------------------------------------------------------
		local city = B:bone("City", "Body", v(0, 14.2, -1))
		local CZ = -1
		local function c(sx, sy, sz, x, y, z, col, opts, ry)
			return B:block(city, v(sx, sy, sz), cf(x, y, z + CZ, 0, ry or 0, 0), col, opts)
		end
		-- foundation + island
		c(10.4, 0.4, 12.8, 0, 13.8, 0, GOLD)
		c(10.0, 0.8, 12.4, 0, 14.4, 0, MARBLE2)
		-- outer moat water
		c(8.0, 0.3, 10.4, 0, 14.95, 0, WATER)
		-- outer wall (gate gap at the front)
		B:sym(function()
			c(0.8, 1.5, 12.0, 4.4, 15.55, 0, MARBLE)
			c(2.9, 1.5, 0.8, 2.55, 15.55, -5.6, MARBLE)
			c(0.1, 0.3, 11.0, 4.85, 15.0, 0, GOLD)
			for _, z in { -3.3, -1.1, 1.1, 3.3 } do
				c(0.85, 0.5, 0.8, 4.4, 16.55, z, GOLD) -- crenels
			end
			c(0.8, 0.5, 0.8, 2.2, 16.55, -5.6, GOLD)
			c(0.4, 0.8, 0.8, 4.85, 15.6, -1.1, TEAL) -- rune tile
			c(0.1, 0.4, 0.4, 5.08, 15.6, -1.1, NT, NEON)
			-- corner turrets
			for _, z in { -5.6, 5.6 } do
				c(1.5, 2.8, 1.5, 4.4, 16.2, z, MARBLE)
				c(1.75, 0.4, 1.75, 4.4, 17.7, z, GOLD)
				c(1.1, 0.7, 1.1, 4.4, 18.2, z, TEAL)
				c(0.5, 0.5, 0.5, 4.4, 18.75, z, TURQ)
			end
		end)
		c(5.4, 1.5, 0.8, 0, 15.55, 5.6, MARBLE) -- back wall
		c(0.85, 0.5, 0.8, 0, 16.55, 5.6, GOLD)
		c(0.85, 0.5, 0.8, -1.8, 16.55, 5.6, GOLD)
		c(0.85, 0.5, 0.8, 1.8, 16.55, 5.6, GOLD)
		-- front gate arch + bridge over the moat
		c(0.8, 2.6, 0.9, 1.25, 16.1, -5.6, MARBLE)
		c(0.8, 2.6, 0.9, -1.25, 16.1, -5.6, MARBLE)
		c(3.4, 0.6, 1.1, 0, 17.6, -5.6, GOLD)
		c(2.2, 0.4, 0.9, 0, 18.1, -5.6, GOLD)
		c(0.8, 0.3, 0.1, 0, 17.6, -6.18, NT, NEON)
		c(1.6, 0.3, 1.8, 0, 15.0, -4.7, MARBLE2)
		-- garden terrace (middle ring) with gold trim
		c(6.4, 0.9, 8.4, 0, 15.25, 0, MARBLE)
		c(6.6, 0.25, 8.6, 0, 15.5, 0, GOLD)
		-- inner moat + central island
		c(4.4, 0.2, 5.2, 0, 15.75, 0, WATER)
		c(3.2, 0.6, 3.6, 0, 16.0, 0, MARBLE)
		c(3.4, 0.2, 3.8, 0, 16.05, 0, GOLD)
		c(0.9, 0.25, 1.0, 0, 15.85, -2.2, GOLD) -- bridges
		c(0.9, 0.25, 1.0, 0, 15.85, 2.2, GOLD)
		-- little houses, gardens
		local houses = { { 2.3, -1.4, TEAL }, { -2.3, -1.4, GOLD }, { 2.3, 1.2, GOLD }, { -2.3, 1.2, TEAL } }
		for _, h in houses do
			c(1.0, 0.8, 1.1, h[1], 16.1, h[2], MARBLE)
			c(1.2, 0.4, 1.3, h[1], 16.65, h[2], h[3])
		end
		c(1.0, 0.4, 0.9, 1.0, 15.9, 3.4, GRASS)
		c(1.0, 0.4, 0.9, -1.0, 15.9, -3.4, GRASS)
		-- broken ruins on the back terrace
		c(0.55, 1.6, 0.55, -1.0, 16.5, 3.5, MARBLE)
		c(0.55, 0.8, 0.55, 0.0, 16.1, 3.6, MARBLE2)
		c(1.4, 0.5, 0.5, 2.6, 15.95, 3.7, MARBLE2, nil, 25)

		-- temple: stylobate, 8 columns, glowing core, gold entablature, stepped gold dome
		c(2.8, 0.4, 2.8, 0, 16.5, 0, MARBLE2)
		B:ring(city, CFrame.new(0, 17.7, CZ) * ang(0, 22.5, 0), 1.15, 8, v(0.45, 2.0, 0.45), MARBLE)
		local core = c(1.0, 1.4, 1.0, 0, 17.5, 0, TEAL)
		c(0.5, 0.5, 0.5, 0, 17.8, 0, NT, { mat = "Neon", name = "TempleCore" })
		B:light(core, { name = "TempleLight", color = NG, brightness = 0.5, range = 10 })
		c(3.0, 0.45, 3.0, 0, 18.9, 0, GOLD)
		c(2.6, 0.35, 2.6, 0, 19.3, 0, MARBLE)
		c(2.2, 0.55, 2.2, 0, 19.72, 0, GOLD)
		c(1.6, 0.55, 1.6, 0, 20.27, 0, GOLD)
		c(1.0, 0.45, 1.0, 0, 20.75, 0, DGOLD)

		-- coral tufts
		local function coral(x, z, col, col2)
			c(0.5, 1.1, 0.5, x, 15.65, z, col)
			B:block(city, v(0.4, 0.7, 0.4), cf(x + 0.4, 16.0, z + CZ, 0, 0, -25), col)
			c(0.4, 0.4, 0.4, x - 0.25, 16.35, z + 0.2, col2)
		end
		coral(3.4, 4.6, CORAL, CORAL2)
		coral(-3.3, -4.6, CORAL2, CORAL)
		coral(-3.4, 4.0, CORAL, NG)
		-- seaweed (sways)
		local weeds = { { 3.4, -4.4 }, { -3.4, 2.4 }, { 3.5, 1.8 } }
		for i, w in weeds do
			local wb = B:bone("Weed" .. i, "City", v(w[1], 15.1, w[2] + CZ))
			c(0.5, 1.0, 0.5, w[1], 15.6, w[2], WEED)
			B:block(wb, v(0.45, 1.0, 0.45), cf(w[1] + 0.15, 16.5, w[2] + CZ), WEED)
			B:block(wb, v(0.4, 0.9, 0.4), cf(w[1], 17.4, w[2] + CZ), GRASS)
		end

		-- waterfalls spilling off both flanks
		local flow = B:bone("FallFlow", "City", v(0, 14.6, CZ))
		local fi = 0
		B:sym(function()
			for _, z in { -2.4, 2.2 } do
				fi += 1
				c(2.4, 0.4, 1.6, 5.9, 14.95, z, FOAM)
				c(0.4, 6.4, 1.4, 6.95, 11.8, z, WATERF, { tr = 0.25 })
				B:block(flow, v(0.46, 2.6, 0.35), cf(7.0, 12.6, z + CZ + 0.3), FOAM, { tr = 0.15, name = "FallStreak" .. fi })
				c(1.0, 0.5, 2.0, 7.0, 8.55, z, FOAM)
			end
		end)
		local cityFx = B:block(city, v(9, 4, 11), cf(0, 17, CZ), MAIN, HIDE("CityFX"))
		B:emitter(cityFx, "sparkle", { name = "CitySparkle", color = { "#ffffff", NG, NT }, rate = 4 })
		local fwFx = B:block(city, v(10, 3, 10), cf(0, 25, CZ), MAIN, HIDE("FireworkFX"))
		B:emitter(fwFx, "burst", { name = "Fireworks", color = { "#ffffff", NG, GOLD, NT }, size = { 1.0, 0.7, 0 }, speed = { 8, 16 }, life = { 0.6, 1.4 }, accel = { 0, -6, 0 } })

		-- four towers that RISE out of the terrace
		local towers = { { 2.45, -3.3 }, { -2.45, -3.3 }, { 2.45, 3.0 }, { -2.45, 3.0 } }
		for i, tp in towers do
			local x, z = tp[1], tp[2] + CZ
			local tw = B:bone("Tower" .. i, "City", v(x, 15.7, z))
			B:block(tw, v(1.15, 4.8, 1.15), cf(x, 14.9, z), MARBLE)
			B:block(tw, v(1.3, 0.3, 1.3), cf(x, 16.6, z), GOLD)
			B:block(tw, v(0.3, 0.6, 0.12), cf(x, 16.2, z - 0.6), NS, NEON)
			B:block(tw, v(1.55, 0.4, 1.55), cf(x, 17.45, z), GOLD)
			B:block(tw, v(1.1, 0.6, 1.1), cf(x, 17.95, z), TEAL)
			B:block(tw, v(0.65, 0.55, 0.65), cf(x, 18.5, z), TURQ)
			B:block(tw, v(0.3, 0.45, 0.3), cf(x, 18.95, z), NG, NEON)
		end

		-- the orichalcum crystal spire on the dome
		local spire = B:bone("Spire", "City", v(0, 21.0, CZ))
		B:block(spire, v(1.3, 0.4, 1.3), cf(0, 21.15, CZ), GOLD)
		B:block(spire, v(1.0, 2.4, 1.0), cf(0, 22.5, CZ, 0, 45, 0), TURQ)
		B:block(spire, v(0.7, 1.5, 0.7), cf(0, 24.3, CZ, 0, 45, 0), TURQL)
		B:block(spire, v(0.42, 0.8, 0.42), cf(0, 25.35, CZ, 0, 45, 0), NT, NEON)
		B:beam(spire, v(0.3, 21.3, CZ), v(1.2, 22.7, CZ), 0.45, 0.45, TURQL)
		B:beam(spire, v(-0.3, 21.4, CZ), v(-1.0, 22.4, CZ + 0.4), 0.4, 0.4, TURQ)
		local tipFx = B:block(spire, v(1, 1, 1), cf(0, 25.4, CZ), MAIN, HIDE("TipFX"))
		B:emitter(tipFx, "sparkle", { name = "SpireCharge", color = { "#ffffff", NT, NS }, rate = 45, enabled = false, speed = { 2, 6 }, size = { 0.25, 0.6, 0 } })
		B:emitter(tipFx, "burst", { name = "BeamBurst", color = { "#ffffff", NS, NG }, size = { 1.1, 0.7, 0 }, speed = { 10, 22 } })
		B:light(tipFx, { name = "SpireLight", color = NT, brightness = 0.4, range = 16 })
		B:trail(spire, v(0, 25.6, CZ), v(0, 24.2, CZ), { name = "SpireTrail", color = { "#ffffff", NT }, life = 0.5, trans = { 0.5, 1 } })
		-- hidden beam of light from the tip
		B:block(spire, v(1.0, 15, 1.0), cf(0, 33.3, CZ), "#d8fbff", HIDE("BeamCore", NEON))
		B:block(spire, v(2.4, 15, 2.4), cf(0, 33.3, CZ), NS, HIDE("BeamGlow", NEON))
		-- halo of rays around the tip
		local halo = B:bone("Halo", "Spire", v(0, 25.2, CZ))
		for i = 1, 10 do
			local len = (i % 2 == 0) and 3.4 or 5.4
			B:block(halo, v(0.35, 0.35, len), CFrame.new(0, 25.2, CZ) * ang(0, i * 36, 0) * ang(12, 0, 0) * CFrame.new(0, 0, -1.4 - len / 2),
				(i % 2 == 0) and NT or NG, HIDE("Ray" .. i, NEON))
		end

		-- firework chunks (hidden) launched by the city
		local chunkCol = { NG, NT, NG, "#ffffff", NG, NT, GOLD, NG }
		for k = 1, 8 do
			local cb = B:bone("Chunk" .. k, "City", v(0, 17.5, CZ))
			B:block(cb, v(0.7, 0.7, 0.7), cf(0, 17.5, CZ), chunkCol[k], HIDE("ChunkP" .. k, chunkCol[k] ~= GOLD and NEON or nil))
		end

		------------------------------------------------------------------
		-- tiny city fish that swim around her (Body-carried)
		------------------------------------------------------------------
		local fishes = { { 9.0, 17.0, -8.0, CORAL2, "#ffffff" }, { -9.5, 18.0, 4.0, GOLD, TEAL }, { 8.5, 16.5, 10.0, TURQ, "#ffffff" } }
		for k, f in fishes do
			local p = v(f[1], f[2], f[3])
			local fb = B:bone("Fish" .. k, "Body", p)
			B:block(fb, v(0.9, 0.9, 1.4), CFrame.new(p), f[4])
			B:block(fb, v(0.95, 0.3, 0.4), CFrame.new(p + v(0, 0, 0.1)), f[5])
			B:block(fb, v(1.0, 0.3, 0.3), CFrame.new(p + v(0, 0.15, -0.45)), PUPIL)
			B:block(fb, v(0.25, 1.0, 0.6), CFrame.new(p + v(0, 0, 0.95)), f[4])
		end
		B:trail("Fish1", v(9.0, 17.2, -7.5), v(9.0, 16.8, -7.5), { name = "FishTrail", color = { "#ffffff", NS }, life = 0.35, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- floating marble / gold / crystal cubes orbiting her
		------------------------------------------------------------------
		local orbs = {
			{ 13.5, 15.0, -10, 1.8, "marble" },
			{ -14, 12.0, -5, 1.6, "gold" },
			{ 13, 10.0, 8, 1.4, "crystal" },
			{ -12, 19.0, 8, 1.8, "marble" },
			{ -8, 21.0, -14, 1.4, "crystal" },
		}
		for i, o in orbs do
			local p = v(o[1], o[2], o[3])
			local ob = B:bone("Orb" .. i, "Root", p)
			local s = o[4]
			if o[5] == "marble" then
				B:block(ob, v(s, s, s), CFrame.new(p), MARBLE)
				B:block(ob, v(s + 0.12, s * 0.22, s + 0.12), CFrame.new(p) * CFrame.new(0, s * 0.2, 0), GOLD)
				B:block(ob, v(s * 0.3, s * 0.3, s + 0.16), CFrame.new(p) * CFrame.new(0, -s * 0.15, 0), NT, NEON)
			elseif o[5] == "gold" then
				B:block(ob, v(s, s, s), CFrame.new(p), GOLD)
				B:block(ob, v(s + 0.12, s * 0.2, s + 0.12), CFrame.new(p), TEAL)
				B:block(ob, v(s * 0.5, s * 0.3, s * 0.5), CFrame.new(p) * CFrame.new(0, s * 0.62, 0), DGOLD)
			else
				B:block(ob, v(s * 0.8, s * 1.4, s * 0.8), CFrame.new(p) * ang(0, 45, 0), TURQ)
				B:block(ob, v(s * 0.5, s * 0.6, s * 0.5), CFrame.new(p) * CFrame.new(0, s * 0.95, 0) * ang(0, 45, 0), TURQL)
				B:block(ob, v(s * 0.3, s * 0.35, s * 0.3), CFrame.new(p) * CFrame.new(0, s * 1.35, 0) * ang(0, 45, 0), NT, NEON)
			end
		end
	end,
}
